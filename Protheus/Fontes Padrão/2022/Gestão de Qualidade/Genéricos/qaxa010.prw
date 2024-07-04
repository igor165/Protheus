#INCLUDE "TOTVS.CH"
#INCLUDE "QAXA010.CH"
#INCLUDE "REPORT.CH"

Static __cEmpAnt
Static __cFilAnt

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 �QAXA010   � Autor �Aldo Marini Junior     � Data � 13/05/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Cadastro de Responsaveis                                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 �QAXA010()                                                   ���
�������������������������������������������������������������������������Ĵ��
���Uso		 �Siga Quality ( Generico )                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Eduardo S.  �25/03/02� META � Otimizacao, Melhoria e Alteracao na utili���
���            �        �      � zacao dos arquivos de Usuarios/Centro C./���
���            �        �      � Transf. conforme novo Conceito Quality.  ���
���Eduardo S.  �22/05/02�      � Acertado para transf. corretamente os des���
���            �        �      � tinatarios do Docto.                     ���
���Eduardo S.  �01/07/02�      � Acerto para transferir tambem doctos bai-���
���            �        �      � xados e vigentes.                        ���
���Eduardo S.  �16/07/02�      � Incluido o campo QAA_TPUSR defindo o tipo���
���            �        �      � do Usuario, permitindo somente a inclusao���
���            �        �      � do Tipo Outros qdo integrado com SIGAGPE.���
���Aldo Marini �01/08/02�      � Transf. das funcoes QX10VldEmp() e       ���
���            �        �      � QA010VRCFG()para o fonte QAXFUN.PRW      ���
���Eduardo S.  �05/09/02� ---- � Acerto para validar exclusao de usuarios ���
���            �        �      � do tipo funcionario qdo integrado SIGAGPE���
���Eduardo S.  �07/01/03� ---- � Acerto para transferir corretamente os   ���
���            �        �      � destinatarios dos doctos em elaboracao.  ���
���Eduardo S.  �11/02/03�062340� Acerto para permitir somente a transf. de���
���            �        �      � Doctos em etapa Leitura Qdo selecionado  ���
���            �        �      � Transf. e Baixar / Baixar s/ Transf.     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function MenuDef()
Local aRotina   := {}
Private lIntLox := GetMv("MV_QALOGIX") == "1"

	If lIntLox
		aRotina  := { {OemToAnsi(STR0001),"AxPesqui"  , 0 , 1,,.F.},; // "Pesquisar"
					  {OemToAnsi(STR0002),"QA010Telas", 0 , 2},;      // "Visualizar"
					  {OemToAnsi(STR0004),"QA010Telas", 0 , 4},;      // "Alterar"
					  {OemToAnsi(STR0047),"QAXA010Vrf", 0 , 3,,.F.},; // "Mostrar Demitido"
					  {OemToAnsi(STR0005),"QAXA010Trf", 0 , 6},;      // "Transferir"
					  {OemToAnsi(STR0100),"QAXA010Leg", 0 , 6,,.F.},; // "Legenda"
					  {OemToAnsi(STR0153),"MsDocument", 0 , 4}}       // "Conhecimento"
	Else
		aRotina  := { {OemToAnsi(STR0001),"AxPesqui"  , 0 , 1,,.F.},; // "Pesquisar"
					  {OemToAnsi(STR0002),"QA010Telas", 0 , 2},;      // "Visualizar"
					  {OemToAnsi(STR0003),"QA010Telas", 0 , 3},;      // "Incluir" 
					  {OemToAnsi(STR0004),"QA010Telas", 0 , 4},;      // "Alterar"
					  {OemToAnsi(STR0006),"QA010Telas", 0 , 5},;      // "Excluir"
					  {OemToAnsi(STR0047),"QAXA010Vrf", 0 , 3,,.F.},; // "Mostrar Demitido"
					  {OemToAnsi(STR0005),"QAXA010Trf", 0 , 6},;      // "Transferir"
					  {OemToAnsi(STR0100),"QAXA010Leg", 0 , 6,,.F.},; // "Legenda"
					  {OemToAnsi(STR0153),"MsDocument", 0 , 4}}		  // "Conhecimento"
	Endif

Return aRotina

Function QAXA010()

Private aFltDoc   := {}
Private aRotina   := MenuDef()
Private cCadastro := OemtoAnsi(STR0007) // "Respons�veis/Usu�rios"
Private cFilQAD   := If(Alltrim(FWModeAccess("QAD"))=="C",FWFILIAL("QAD"),QAA->QAA_FILIAL) // mudado para private pois combinado com cursorarrow
Private lIntGPE   := If(GetMv("MV_QGINT") == "S",.T.,.F.)
Private lUsrInat  := .F.
Private lVldPer   := .F. // Valida se a tela de filtro foi preenchida ou n�o(Tras todos os registros de Doctos)		 
				                                                                                            // Causa lentid�o.
DbSelectArea("QAA")
DbSetOrder(1)

//�����������������������������������������Ŀ
//�Filtra Usuarios Inativos                 �
//�������������������������������������������

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'QAA' )
oBrowse:SetDescription( cCadastro )  
oBrowse:AddLegend( "Qaxa010Vld(1) == 1", 'ENABLE'    ,"Verde - Normal,sem nenhum lacto de pendencia")		//Verde - Normal,sem nenhum lacto de pendencia
oBrowse:AddLegend( "Qaxa010Vld(2) == 2", 'DISABLE'   ,"Vermelho - Demitido, sem nenhum lacto de pendencia") // Vermelho - Demitido, sem nenhum lacto de pendencia
oBrowse:AddLegend( "Qaxa010Vld(3) == 3", 'BR_AMARELO',"Amarelo - Normal,com lacto de pendencia")  			// Amarelo - Normal,com lacto de pendencia
oBrowse:AddLegend( "Qaxa010Vld(4) == 4", 'BR_AZUL'   ,"Azul - Transferido,com lacto de pendencia")  	    // Azul - Transferido,com lacto de pendencia
oBrowse:AddLegend( "Qaxa010Vld(5) == 5", 'BR_PRETO'  ,"Preta - Demitido, com lacto de pendencia")  	        // Preta - Demitido, com lacto de pendencia
oBrowse:SetFilterDefault( "QAA->QAA_STATUS == '1'" )

DbselectArea("QAA")
QAA->(DbSetOrder(1))
DbSeek(xFilial("QAA"))                                                                     
oBrowse:Activate()

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QA010Telas� Autor � Eduardo de Souza      � Data � 22/03/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tela Cadastro de Usuarios                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QA010Telas(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - Alias do arquivo                                   ���
���          � ExpN1 - Numero do registro                                 ���
���          � ExpN2 - Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QAXA010 - Siga Quality (Generico)                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QA010Telas(cAlias,nReg,nOpc)

Local aMsSize   := MsAdvSize()
Local cModoQAA  := ""
Local lAchouSRA := .F.
Local lIntLox   := GetMv("MV_QALOGIX") == "1"
Local nOpcao    := 0
Local nSaveSx8  := GetSX8Len()
Local oDlg
Local oEnchoice
Private aGETS[0]
Private aTELA[0][0]
Private bCampo  :={|nCPO| Field( nCPO ) }
Private lAltUsr := .F.

	If lIntLox
	nOpc := 4
	Endif

DbSelectArea("QAA")
DbSetOrder(1)

RegToMemory("QAA", nOpc = 3)

	If nOpc == 3
	M->QAA_FILIAL:= xFilial("QAA")    	
	EndIf

//������������������������������������������������������������������������Ŀ
//�Variavel utilizada para bloquear os campos que nao podem ser alterados. �
//��������������������������������������������������������������������������
	If lIntGPE .And. (INCLUI .Or. M->QAA_TPUSR == "1")
	lAltUsr:= .T.
	EndIf

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0007) FROM 000,000 To aMsSize[6]-40,aMsSize[5]-350  OF oMainWnd PIXEL

oDlg:lMaximized := .T.

oEnchoice := Msmget():New("QAA",nReg,nOpc,,,,,{014,002,190,312})

oEnchoice:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	If nOpc == 2 .Or. nOpc == 5
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcao:= 1,oDlg:End() },{|| oDlg:End()}) CENTERED	
	ElseIf nOpc == 3 .Or. nOpc == 4
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(QAX010TOK(nOpc),(nOpcao:= 1,oDlg:End()),)},{|| oDlg:End()}) CENTERED	
	EndIf
	

	If nOpc <> 2
		If nOpcao == 1				// Ok
			If nOpc == 3 .Or. nOpc == 4
			QAX010GUsr(nOpc)	//Grava Usuario
				While (GetSX8Len() > nSaveSx8)
		      	ConfirmSX8()		
				Enddo
			ElseIf nOpc == 5
				If !lIntGpe .Or. M->QAA_TPUSR <> "1"
				QAX010Dele() //Exclui Usuario
				ElseIf lIntGpe .And. M->QAA_TPUSR == "1"
					If SubStr(QAA->QAA_MAT,1,4) <> cEmpAnt+cFilAnt
					__cFilAnt := cFilAnt
					__cEmpAnt := cEmpAnt

						IF !fAbrEmpresa("SRA",1,SubStr(QAA->QAA_MAT,1,2),SubStr(QAA->QAA_MAT,3,FWSizeFilial()),@cModoQAA)
						MsgAlert(OemToAnsi(STR0126)+" SRA",OemToAnsi(STR0127))  //"Nao foi possivel encontrar o arquivo"###"Atencao"
						Return .F.
						Endif
						If QUASRA->(dbSeek(SubStr(QAA->QAA_MAT,3,2)+SubStr(QAA->QAA_MAT,5,6)))
						lAchouSRA := .T.
						Endif

					cFilAnt := __cFilAnt
					cEmpAnt := __cEmpAnt

					fFecEmpresa("QUASRA")
					
					Else
						If SRA->(dbSeek(SubStr(QAA->QAA_MAT,3,2)+SubStr(QAA->QAA_MAT,5,6)))
						lAchouSRA := .T.
						Endif
					Endif

					If !lAchouSRA
						QAX010Dele() 			//Exclui Usuario
					Else
						Help(" ",1,"QX10EXGPE")	// "O Usuario somente podera ser excluido pelo modulo Gestao de Pessoal."
					Endif
				Else
					Help(" ",1,"QX10EXGPE") 	// "O Usuario somente podera ser excluido pelo modulo Gestao de Pessoal."
				EndIf
			EndIf
		Else
			While (GetSX8Len() > nSaveSx8)
				RollBackSX8()
			Enddo
		EndIf
	Endif
	If nOpc == 3
		Qaxa010Fil()
	EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QAX010GUsr� Autor � Eduardo de Souza      � Data � 22/03/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava Usuarios                                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QAX010GUsr(ExpN1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 - Opcao do Browse                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QAXA010 - Siga Quality (Generico)                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QAX010GUsr(nOpc)

Local lRecLock:= .F.
Local nI      := 0

	If nOpc == 3
	lRecLock:= .T.
	EndIf

	Begin Transaction

	DbSelectArea("QAA")
		If nOpc == 4 .And. QAA->QAA_MAT <> M->QAA_MAT
		QAA->(dbSetOrder(1))
		QAA->(dbSeek(xFilial('QAA')+M->QAA_MAT))
		EndIf
	
If valAltFunc()==.T.
EndIf

	M->QAA_LOGIN:= UPPER(M->QAA_LOGIN)
	RecLock("QAA",lRecLock)
		For nI := 1 TO FCount()
		FieldPut(nI,M->&(Eval(bCampo,nI)))
		Next nI
	MsUnLock()      
	FKCOMMIT()
	
	End Transaction
	
	If ExistBlock("QAX010OK")
	ExecBlock("QAX010OK",.F.,.F.,{nOpc})
	EndIf
	

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 � QAX010Dele � Autor � Eduardo de Souza    � Data � 22/03/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Exclusao de registros do Cadastro de Usuarios              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QAX010Dele()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QAXA010 - Siga Quality (Generico)                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QAX010Dele()
Local lRet := .F.

MsgRun(OemToAnsi(STR0114),OemToAnsi(STR0009),{|| lRet:= QAAValExc() }) // "Validando Exclusao de Usuarios..." ### "Aguarde..."	
	If lRet
		Begin Transaction
			If RecLock("QAA",.F.)
				QAA->(DbDelete())
				QAA->(MsUnlock())
				QAA->(FKCOMMIT())
				QAA->(DbSkip())
			Endif
		End Transaction
		//��������������������������������������������������������������Ŀ
		//� Exclui a amarracao com os conhecimentos                      �
		//����������������������������������������������������������������
		MsDocument( Alias(), RecNo(), 2, , 3 ) 
	EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 � Qaxa010Fil� Autor �Aldo Marini Junior    � Data � 06/07/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Filtra os Usuarios/Responsaveis Inativos                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Qaxa010Fil()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QAXA010 - Siga Quality (Generico)                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/                      
Function Qaxa010Fil()
Local cFiltro    := Qa_FilSitF() // "Filtra Ativo"
DEFAULT lUsrInat := .F.

DbSelectArea("QAA")
Set Filter to &(cFiltro)
	If FwIsInCallStack("QAXA010") .And. lUsrInat 
		DbClearFilter()
		oBrowse:SetFilterDefault("QAA->QAA_STATUS <> '*'") 
	EndIf
DbSeek(xFilial("QAA"))

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 �Qaxa010Vld � Autor �Aldo Marini Junior    � Data � 13/05/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Retorna o numero da opcao correspondente a cor da situacao ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Qaxa010Vld(ExpN1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 - Situacao do Registro                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QAXA010 - Siga Quality (Generico)                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/                      
Function Qaxa010Vld(nOpcQAB)

Local nRet   	:= nOpcQAB
Local cFilQAD	:= If(Alltrim(FWModeAccess("QAD"))=="C",FWFILIAL("QAD"),QAA->QAA_FILIAL) //Empty(xFilial("QAD")
Local lAtivo    := QA_SitFolh()
Local aBuscaTra := {}
Local aRecTra	:= {}
Local cFilTra	:= Space(FWSizeFilial())
Local cMatTra   := ''
Local cDepTra   := ''
Local nTra		:= 1

//1 Verde   - Normal,sem nenhum lacto de pendencia
//2 Vermelho- Demitido, sem nenhum lacto de pendencia
//3 Amarelo - Normal,com lacto de pendencia
//4 Azul 	- Transferido,com lacto de pendencia
//5 Preta 	- Demitido, com lacto de pendencia

	If nOpcQAB = 1 .And. ! lAtivo
	Return 0
	ElseIf nOpcQAB = 2 .And. lAtivo
	Return 0
	ElseIf nOpcQAB = 3 .And. ! lAtivo
	Return 0
	ElseIf nOpcQAB = 4 .And. ! lAtivo
	Return 0
	ElseIf nOpcQAB = 5 .And. lAtivo
	Return 0
	Endif

QD1->(DbSetOrder(3))
QAB->(DbSetOrder(2))
QAD->(DbSetOrder(2))

	DO CASE
	CASE nOpcQAB == 1 .Or. nOpcQAB == 3		//1 Verde - Normal,sem nenhum lacto de pendencia
											//3 Amarelo - Normal,com lacto de pendencia
		
		If QD1->(DbSeek(QAA->QAA_FILIAL+QAA->QAA_MAT+"P"))
			If QAA->QAA_CC == QD1->QD1_DEPTO
				If nOpcQAB == 1
					nRet:= 0
				Endif
			Endif
		Else
			If nOpcQAB == 3
				nRet:= 0
			Endif
		Endif
	CASE nOpcQAB == 2 .Or. nOpcQAB == 5 	//2 Vermelho- Demitido, sem nenhum lacto de pendencia
											//5 Preta 	- Demitido, com lacto de pendencia
		If QD1->(DbSeek(QAA->QAA_FILIAL+QAA->QAA_MAT+"P"))
			If nOpcQAB == 2
				nRet:= 0
			Endif
		Else
			If nOpcQAB == 5
				nRet:= 0
				If QAD->(DbSeek(cFilQAD+QAA->QAA_MAT))
					nRet := 5
				Endif
			Endif
		Endif
		
	CASE nOpcQAB == 4  //4 Azul 	- Transferido,com lacto de pendencia
		
		cFilTra :=	QAA->QAA_FILIAL
		cMatTra :=	QAA->QAA_MAT
		cDepTra :=	QAA->QAA_CC
		
		//��������������������������������������������������������������Ŀ
		//� Carrega os Lactos de Transferencia e Matricula atual         �
		//����������������������������������������������������������������
		If QAB->(DbSeek(cFilTra+cMatTra))
			While QAB->(!Eof()) .And. QAB->QAB_FILP+QAB->QAB_MATP == cFilTra+cMatTra
				If Ascan(aRecTra,QAB->(Recno())) > 0
					QAB->(DbSkip())
					Loop
				Else
					Aadd(aRecTra,QAB->(Recno()))
				Endif
				If QAB->QAB_FILP+QAB->QAB_MATP == cFilTra+cMatTra
					If QAB->QAB_FILP+QAB->QAB_MATP+QAB->QAB_CCP <> QAB->QAB_FILD+QAB->QAB_MATD+QAB->QAB_CCD
						If Ascan(aBuscaTra,{|X| X[1]+X[2]+X[3] == QAB->QAB_FILD+QAB->QAB_MATD+QAB->QAB_CCD}) == 0
							IF QAB->QAB_FILD+QAB->QAB_MATD+QAB->QAB_CCD <> QAA->QAA_FILIAL+QAA->QAA_MAT+QAA->QAA_CC
								Aadd(aBuscaTra,{QAB->QAB_FILD,QAB->QAB_MATD,QAB->QAB_CCD})
							Endif
						Endif
					EndIf
				Else
					QAB->(DbSkip())
				EndIf
			EndDo
		EndIf
		
		nRet:= 0
		For nTra:=1 To Len(aBuscaTra)
			If QD1->(DbSeek(aBuscaTra[nTra,1]+aBuscaTra[nTra,2]+"P"))
				While QD1->(!Eof()) .And. aBuscaTra[nTra,1]+aBuscaTra[nTra,2]+"P" == QD1->QD1_FILMAT+QD1->QD1_MAT+QD1->QD1_PENDEN
					If QD1->QD1_SIT == "I" .OR. (aBuscaTra[nTra,3] <> QD1->QD1_DEPTO)
						QD1->(DbSkip())
						Loop
					Else
						nRet:= 4
					Endif
					QD1->(DbSkip())
				Enddo
			Endif
		Next
	EndCASE

QD1->(DbSetOrder(1))
QAB->(DbSetOrder(1))
QAD->(DbSetOrder(1))

Return nRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 �Qaxa010Vrf� Autor �Aldo Marini Junior     � Data � 13/05/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Filtra aleatoriamente funcionarios Inativos e/ou Normais   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Qaxa010Vrf()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QAXA010 - Siga Quality (Generico)                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/                      
Function Qaxa010Vrf()
Default lUsrInat := .F.

	If !VerSenha(102)
   		Help(" ",1,"QDFUNCNP") 	// Funcionario nao tem permissao p/ responsavel
		Return
	Endif

	If !lUsrInat
		lUsrInat := .T.
	Endif

	MsgRun(OemToAnsi(STR0008),OemToAnsi(STR0009),{ || Qaxa010Fil() } ) //"Selecionando Usu�rios" ### "Aguarde..."


Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 �Qaxa010Trf� Autor �Aldo Marini Junior     � Data � 13/05/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Efetua Transferir/Inativar Usuario                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Qaxa010Trf()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QAXA010 - Siga Quality (Generico)                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function Qaxa010Trf()

Local oDlgFolder
Local oTransf
Local oTpPen
Local oDoctos
Local oUsuarios
Local oCombOrd
Local oFnt
Local oItem2
Local oItem3
Local oItem4
Local oItem5
Local oMarcar
Local oPesq
Local oNome
Local oChk03
Local oCcFilial
Local oCcPara
Local oCcMatr
Local oHistCC
Local cNDepto   := " "
Local nItem2	:= 2
Local nItem3	:= 2
Local nItem4	:= 1
Local nItem5	:= 1
Local nOldOrdU  := 1
Local cUsr		:= " "
Local cCcPara	:= Space(TAMSX3("QAA_CC")[1])
Local cCcMatr	:= Space(TAMSX3("QAA_MAT")[1])
Local cDoc		:= " "
Local cCombOrd  := OemToAnsi(STR0091) 	// "Matricula"
Local cTpPen    := " "
Local nOpcao	:= 2
Local lChk03   	:= .F.
Local lChk04   	:= .F.
Local aDoctos  	:= { {.F.,.F., Space(16) , Space(3) , OemToAnsi(STR0089), Space(8), Space(2), Space(2), 0, "P" } }	// "N�o ha Lan�amentos"
Local aPenDoc  	:= {}
Local nPosQAA  	:= QAA->(Recno())
Local cSitAtu  	:= " "
Local aRecTrf  	:= {}
Local aCombOrd 	:= {OemToAnsi(STR0091),;	// "Matricula"
				    OemToAnsi(STR0092),;	// "Nome"
				    OemToAnsi(STR0084),;	// "Nome Reduzido"
				    OemToAnsi(STR0085) } 	// "C.Custo"
				    				 
Local aTpPen := { { .T.,.F., OemToAnsi(STR0070),"D",Space(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1]) },;		//	"Digita��o"
				  { .T.,.F., OemToAnsi(STR0071),"E",Space(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1]) },;	// "Elabora��o"
				  { .T.,.F., OemToAnsi(STR0072),"R",Space(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1]) },;	// "Revis�o"
				  { .T.,.F., OemToAnsi(STR0073),"A",Space(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1]) },;	// "Aprova��o"
				  { .T.,.F., OemToAnsi(STR0074),"H",Space(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1]) },;	// "Homologa��o"
				  { .T.,.F., OemToAnsi(STR0075),"I",Space(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1]) },;	// "Distribui��o"
				  { .T.,.F., OemToAnsi(STR0076),"L",Space(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1]) },;	// "Leitura"
				  { .T.,.F., OemToAnsi(STR0038),"P",Space(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1]) },;	// "Resp.Depto"   
				  { .T.,.F., OemToAnsi(STR0116),"G",Space(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1]) },; 	// "Destinatario"
				  { .T.,.F., OemToAnsi("Aviso"),"S",Space(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1]) }} 
						
Local aObjects 	:= {{1,1,.T.,.T.}}					
Local aSize	  	:= MsAdvSize()
Local aInfo		:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local aPosObj 	:= MsObjSize(aInfo,aObjects,.T.)
Local cFilINI  	:= Space(FWSizeFilial())
Local cFilFIM  	:= Space(FWSizeFilial())
Local nI       	:= 0
Local oPanOpcao
Local oPanPende
Local oPanDoc
Local oSayT1
Local oSayT3
Local oSayUsu
Local oSayHtr                      
Local oAvisos                 
Local cAvi	  		:=""
Local aAviAux 		:= {{ Space(TamSx3("QDS_FILIAL")[1]),Space(TamSx3("QDS_DOCTO")[1]),Space(TamSx3("QDS_RV")[1]),Space(TamSx3("QDS_PENDEN")[1]),Space(TamSx3("QDS_DTGERA")[1])+" "+Space(TamSx3("QDS_HRGERA")[1]), OemToAnsi(STR0089)}}
Local cFiltro   	:= ""
Local aSaveArea 	:= GetArea()
Local lIntGPE	    := If(GetMv("MV_QGINT") == "S",.T.,.F.)

Private aAvisos		:={}                
Private cFilMat 	:= cFilAnt
Private aUsrMat 	:= QA_USUARIO()
Private cMatFil 	:= aUsrMat[2]
Private cMatCod 	:= aUsrMat[3]
Private cMatDep 	:= aUsrMat[4]
Private aHeadDoc	:= { " "," ",OemToAnsi(STR0086)+"/"+OemToAnsi(STR0039),OemToAnsi(STR0087)+"/"+OemToAnsi(STR0033),OemToAnsi(STR0088)+"/"+OemToAnsi(STR0079)}	// "No.Docto" ### "Rv" ### "Titulo"
Private aHeadRes	:= { " "," ",OemToAnsi(STR0039),OemToAnsi(STR0033),OemToAnsi(STR0079)}	// "Depto" ### "Fil" ### "Descri��o"
Private oOK     	:= LoadBitmap( GetResources(), "ENABLE" )
Private oNo     	:= LoadBitmap( GetResources(), "DISABLE" )
Private hOK       	:= LoadBitmap( GetResources(), "LBTIK" )
Private hNo       	:= LoadBitmap( GetResources(), "LBNO" )
Private cMatAtu   	:= ""
Private cNomAtu   	:= ""
Private cFilAtu   	:= Space(FWSizeFilial())
Private cDepAtu   	:= ""
Private cFilNov   	:= Space(FWSizeFilial())
Private cDepNov   	:= ""
Private lFil      	:= .f.
Private lDep      	:= .f.
Private aBuscaQD1 	:= {}
Private cMotTransf	:= Space(30)
Private cFilDep   	:= xFilial("QAD")
Private nQaConpad 	:= 2
Private cCcFilial 	:= Space(FWSizeFilial()) //Space(2)
Private bQDSLine
Private oSayT2
Private aPenCri		:= {} // Vetor com o indice das pendencias com criticas de status "pendente"
 
If !VerSenha(102)
	Help(" ",1,"QDFUNCNP") 	// Funcionario nao tem permissao p/ responsavel
	Return .F.
Endif

//��������������������������������������������������������������Ŀ
//�Verifica se o usuario logado esta transferindo suas pendencias�
//����������������������������������������������������������������
If cMatFil + cMatcod == QAA->QAA_FILIAL + QAA->QAA_MAT
   	Help(" ",1,"QD_USRNTRF")
	Return .F.
Endif

DbSelectArea("QDZ")
DbSetOrder(1)

DbSelectArea("QAB")
DbSetOrder(2)

DbSelectArea("QAA")
DbSetOrder(1)

cFilMat	:= QAA->QAA_FILIAL
cFilAtu	:= QAA->QAA_FILIAL
cMatAtu	:= QAA->QAA_MAT
cNomAtu	:= QAA->QAA_NOME           
cDepAtu	:= QAA->QAA_CC
cSitAtu	:= QAA->QAA_STATUS
cCcFilial:= cFilAtu
cCcMatr	:= cMatAtu
cCcPara	:= cDepAtu 
aBuscaQD1:= { {cFilAtu , cMatAtu , cDepAtu } }

//��������������������������������������������������������������Ŀ
//� Carrega os Lactos de Transferencia e Matricula atual         �
//����������������������������������������������������������������
If QAB->(DbSeek(cFilAtu+cMatAtu))
	While QAB->(!Eof()) .And. QAB->QAB_FILP+QAB->QAB_MATP == cFilAtu+cMatAtu
		If Ascan(aRecTrf,QAB->(Recno())) > 0
			QAB->(DbSkip())
			Loop
		Else
			Aadd(aRecTrf,QAB->(Recno()))
		Endif
		If QAB->QAB_FILP+QAB->QAB_MATP == cFilAtu+cMatAtu
			If QAB->QAB_FILP+QAB->QAB_MATP+QAB->QAB_CCP <> QAB->QAB_FILD+QAB->QAB_MATD+QAB->QAB_CCD
				If Ascan(aBuscaQD1,{|X| X[1]+X[2]+X[3] == QAB->QAB_FILD+QAB->QAB_MATD+QAB->QAB_CCD}) == 0
					Aadd(aBuscaQD1,{QAB->QAB_FILD,QAB->QAB_MATD,QAB->QAB_CCD})
				Endif
			EndIf
		Else
			QAB->(DbSkip())
		EndIf
	EndDo
	cFilAtu	:= QAA->QAA_FILIAL
	cMatAtu	:= QAA->QAA_MAT
EndIf

MsgRun(OemToAnsi(STR0031),OemToAnsi(STR0009),{|| QAXA010CkPen(@aTpPen,@aPenDoc,@aDoctos,1,oDoctos,@aAvisos,oAvisos,@aAviAux)}) //"Verificando pendencias" ### "Aguarde..."

DEFINE FONT oFnt NAME "Courier New" BOLD SIZE 6,30 

DEFINE MSDIALOG oDlgFolder TITLE OemToAnsi(STR0020)+" - "+OemToAnsi(STR0021)+": "+AllTrim(cMatAtu)+" - "+AllTrim(cNomAtu)+" "+OemToAnsi(STR0085)+": "+cDepAtu FROM aSize[7],000 TO aSize[6],aSize[5] OF oMainWnd PIXEL // "Transferencia de Usuarios" ### "Usuario"

//������������������������������������Ŀ
//�Folder Usuarios                     �
//��������������������������������������
@ 000,000 FOLDER oTransf PROMPTS OemToAnsi(STR0021),OemToAnsi(STR0027) SIZE 315,183 OF oDlgFolder PIXEL // "Usuarios" ### "Departamento"
oTransf:Align := CONTROL_ALIGN_ALLCLIENT

//������������������������������������Ŀ
//�Tipos de Pendencia	               �
//��������������������������������������
@000,000 MSPANEL oPanPende PROMPT "" SIZE 080,050 OF oTransf:aDialogs[1] 
oPanPende:Align := CONTROL_ALIGN_LEFT

@ 000,010 Say oSayT1 VAR ""  SIZE 010,008 OF oPanPende PIXEL  
oSayT1:SetText(" "+OemToAnsi(STR0078)) //"Tipos de Pendencia"
oSayT1:Align := CONTROL_ALIGN_TOP	

@ 009,006 LISTBOX oTpPen VAR cTpPen ;
			FIELDS ;
		  	HEADER " "," "," ",OemToAnsi(STR0079);	// "Descri��o"
			SIZE 080, aPosObj[1,4]-aPosObj[1,2] OF oPanPende PIXEL ; 
		  	ON DBLCLICK If( nItem2 == 2 ,;
			  			( aTpPen[oTpPen:nAt,1] := !(aTpPen[oTpPen:nAt,1]) ,;
			  			oTpPen:SetArray(aTpPen),;
						oTpPen:bLine:= { || { If( aTpPen[ oTpPen:nAt, 1], hOk, hNo ), If( aTpPen[ oTpPen:nAt, 2 ], oOk, oNo ), If(!Empty(aTpPen[ oTpPen:nAt, 5 ]),oOk ,oNo ), aTpPen[ oTpPen:nAt, 3 ] } } ,;
						oTpPen:Refresh()),"")
						
			  
oTpPen:Align := CONTROL_ALIGN_ALLCLIENT
oTpPen:SetArray(aTpPen)
oTpPen:bLine:= { || { If( aTpPen[ oTpPen:nAt, 1], hOk, hNo ), If( aTpPen[ oTpPen:nAt, 2 ], oOk, oNo ), If(!Empty(aTpPen[ oTpPen:nAt, 5 ]),oOk ,oNo ), aTpPen[ oTpPen:nAt, 3 ] } }

//������������������������������������Ŀ
//�Marcar Todos                        �
//��������������������������������������                                         
oTpPen:bChange := { || (IF(!Empty(aTpPen[oTpPen:nAt,5]),FQAXA010Fun(@oUsuarios,aTpPen[oTpPen:nAt,5]) ,""),;
								  FQAXA010Doc(@oDoctos,@aDoctos,aPenDoc,aTpPen,oTpPen:nAt,nItem4,,,aAvisos,@oAvisos,@aAviAux),;
	If(aTpPen[oTpPen:nAt,2],oMarcar:Enable(),oMarcar:Disable() ),;
			If(!Empty(aDoctos[oDoctos:nAt,6]),FQAXA010Fun(@oUsuarios,aDoctos[oDoctos:nAt,6]),"") ) }

//����������������������������Ŀ
//�Documentos / Pastas /Avisos �
//������������������������������
@000,000 MSPANEL oPanDoc PROMPT "" SIZE 100,015 OF oTransf:aDialogs[1]
oPanDoc:Align := CONTROL_ALIGN_ALLCLIENT


@ 000,010 Say oSayT2 VAR ""  SIZE 010,008 OF oPanDoc PIXEL  
oSayT2:Align := CONTROL_ALIGN_TOP	

@ 009,083 LISTBOX oDoctos VAR cDoc ;
			  FIELDS ;
			  HEADER " "," "," "," "," " ;	
			  ON DBLCLICK (aDoctos[oDoctos:nAt,1] := !aDoctos[oDoctos:nAt,1],;
							   oDoctos:Refresh() ,;
							   nPosT := 0 ,;
							   nPosT := aScan(aPenDoc,{ |x| x[8]+x[2]+x[3]+x[1]+x[10]+cvaltochar(x[7]) == aDoctos[oDoctos:nAt,7]+aDoctos[oDoctos:nAt,If(x[1]=="P",4,3)]+aDoctos[oDoctos:nAt,If(x[1]=="P",3,4)]+aDoctos[oDoctos:nAt,8]+aDoctos[oDoctos:nAt,10]+cvaltochar(aDoctos[oDoctos:nAt,9])}) ,;
			If(nPosT > 0,aPenDoc[nPosT,4] := aDoctos[oDoctos:nAt,1],"")   );
			SIZE aPosObj[1,4]-aPosObj[1,2] , aPosObj[1,4]-aPosObj[1,2]OF oPanDoc PIXEL
				
oDoctos:SetArray(aDoctos)
oDoctos:bLine:= { || { If( aDoctos[ oDoctos:nAt, 1], hOk, hNo ),If( aDoctos[ oDoctos:nAt, 2], oOk, oNo ), aDoctos[ oDoctos:nAt, 3], aDoctos[ oDoctos:nAt, 4 ], aDoctos[ oDoctos:nAt, 5 ] } }
oDoctos:Align:= CONTROL_ALIGN_ALLCLIENT

//������������������������������������Ŀ
//�Marcar                              �
//��������������������������������������                                         
oDoctos:bChange := { || IF(!Empty(aDoctos[oDoctos:nAt,6]),FQAXA010Fun(@oUsuarios,aDoctos[oDoctos:nAt,6]),;
					IF(!Empty(aTpPen[oTpPen:nAt,5]),FQAXA010Fun(@oUsuarios,aTpPen[oTpPen:nAt,5]),"")),;
								FQAXA010Avs(aTpPen[oTpPen:nAt,4]=="S",oDoctos,aDoctos,@oAvisos,aAvisos,@aAviAux,nItem4)}



@ 009,090 LISTBOX oAvisos VAR cAvi ;
			  FIELDS ;
			  HEADER TitSx3("QDS_DTGERA")[1],;
			   		 OemToAnsi(STR0133);  //"Avisos"
        	  COLSIZES 40 ;
			  SIZE 150,(aPosObj[1,4]-aPosObj[1,2]) OF oPanDoc PIXEL 

bQDSLine:={ || { DTOC(STOD(SUBS(aAviAux[oAvisos:nAt,5],1,8)))+SUBS(aAviAux[oAvisos:nAt,5],9),QAX010MsgA(aAviAux[oAvisos:nAt,6]) } }
oAvisos:SetArray(aAviAux)          
oAvisos:bLine:= bQDSLine
oAvisos:Align:= CONTROL_ALIGN_RIGHT
oAvisos:Hide()

IF GETMV("MV_QDOFFIL",.F.,"2")=="1" //Define se na Transferencia Filtra os Funcionarios apenas a Filial Atual 1=SIM 2=NAO
	cFilINI :=xFilial("QAA")
	cFilFIM :=xFilial("QAA")
Else
 	cFilINI := Space(FWSizeFilial())//SPACE(2)
	cFilFIM := Repl("z",FWSizeFilial())
Endif

cFiltro:= Qa_FilSitF() // "Filtra Usuarios Ativo"
DbSelectArea("QAA")
Set Filter to &(cFiltro)
DbSeek(xFilial("QAA"))
@ 101,006 LISTBOX oUsuarios VAR cUsr;
			  FIELDS QAA->QAA_FILIAL,QAA->QAA_MAT,QAA->QAA_NOME,QAA->QAA_APELID,QAA->QAA_CC ;
			  HEADER OemToAnsi(STR0033),OemToAnsi(STR0082),OemToAnsi(STR0083),OemToAnsi(STR0084),OemToAnsi(STR0085) ;	// "Fil" ### "C�digo" ### "Nome" ### "Nome Reduzido" ### "C.Custo"
			  SELECT QAA->QAA_FILIAL FOR cFilINI TO cFilFIM ;				  
			  ALIAS "QAA" ;
			  SIZE (aPosObj[1,4]-aPosObj[1,2]),(aSize[4]/3) OF oPanDoc PIXEL  
			  			  
QAA->(DBSeek(cFilAtu+cMatAtu))
oUsuarios:Align := CONTROL_ALIGN_BOTTOM
oUsuarios:UpStable()
oUsuarios:Refresh()

//������������������������������������Ŀ
//�Usuarios Destinos		    	   �
//��������������������������������������
@ 093,005 Say oSayUsu VAR ""  SIZE 010,010 OF oPanDoc PIXEL  
oSayUsu:SetText(" "+OemToAnsi(STR0081)) //"Usuarios Destino"
oSayUsu:Align := CONTROL_ALIGN_BOTTOM

//������������������������������������Ŀ
//�MARCAR/DESMARCAR USUARIOS		   �
//��������������������������������������
@ 000,003 BUTTON oMarcar PROMPT OemToAnsi(STR0090) ; //"MARCAR/DESMARCAR USUARIOS"
			  ACTION QAX10MarU(lChk03,@aDoctos,@oDoctos,@aPenDoc,@oTpPen,@aTpPen,cFilAtu,cMatAtu) ;
			   SIZE 012,012 OF oPanDoc PIXEL  
oMarcar:Align := CONTROL_ALIGN_BOTTOM


//������������������������������������Ŀ
//�Op�oes							   �
//��������������������������������������
@000,000 MSPANEL oPanOpcao PROMPT "" SIZE 065,050 OF oTransf:aDialogs[1]
oPanOpcao:Align := CONTROL_ALIGN_RIGHT

@ 000,010 Say oSayT3 VAR ""  SIZE 010,008 OF oPanOpcao PIXEL  
oSayT3:SetText(" "+OemToAnsi(STR0060)) //"Op��es"
oSayT3:Align := CONTROL_ALIGN_TOP	


@ 012,003 RADIO oItem3 VAR nItem3 3D SIZE 055,007 OF oPanOpcao PIXEL;
           ITEMS OemToAnsi( STR0065 ),; //"Filial/C.Custo"
                 OemToAnsi( STR0066 ) ; //"Pendencias"
			  ON CHANGE If(nItem3 == 1,oTransf:nOption:=2,"") 

//�����������������������������
//�o When o RADIO nao funciona�
//�����������������������������
					IF !lIntGpe .Or. (lIntGpe .And. QAA->QAA_TPUSR <> "1")
	oItem3:Enable()	
					Else
	oItem3:Disable()
					Endif

@ 028,002 SAY Replicate(Oemtoansi("_"),19) SIZE 061,007 OF oPanOpcao PIXEL
@ 038,003 RADIO oItem2 VAR nItem2 3D SIZE 055,007 OF oPanOpcao PIXEL ;
		     ITEMS 	OemToAnsi( STR0063 ),; //"Todas Pendencias"
                 	OemToAnsi( STR0064 )   //"Selecionar"
//������������������������������������Ŀ
//�Marcar Todos                        �
//��������������������������������������                                         
oItem2:bChange:= {|| QAX10MarT(nItem2,@oItem2,@aTpPen,@oTpPen,cFilAtu,cMatAtu,@aDoctos), oItem2:Refresh(.T.)}
                 
                                 
@ 055,002 SAY Replicate(Oemtoansi("_"),19) SIZE 61,07 OF oPanOpcao PIXEL

//������������������������������������Ŀ
//�Pendencias						   �
//��������������������������������������
@ 062,004 SAY OemToAnsi(STR0066) SIZE 050,010 OF oPanOpcao PIXEL //"Filial/Depto"
@ 071,002 RADIO oItem4 VAR nItem4 3D SIZE 055,007 OF oPanOpcao PIXEL;
           ITEMS OemToAnsi( STR0067 ),; //"Ambas"
                 OemToAnsi( STR0068 ),; //"Baixadas"
                 OemToAnsi( STR0069 )   //"Pendentes"

oItem4:bChange:={||(FQAXA010Doc(@oDoctos,@aDoctos,aPenDoc,@aTpPen,oTpPen:nAt,nItem4,,.T.,aAvisos,@oAvisos,@aAviAux),;
  					     oTpPen:SetArray(aTpPen) ,;
						  oTpPen:bLine:= { || { If( aTpPen[ oTpPen:nAt, 1], hOk, hNo ), If( aTpPen[ oTpPen:nAt, 2 ], oOk, oNo ), If(!Empty(aTpPen[ oTpPen:nAt, 5 ]),oOk ,oNo ), aTpPen[ oTpPen:nAt, 3 ] } } ,;
						  oTpPen:Refresh() ) }

@ 098,001 SAY Replicate(Oemtoansi("_"),19) SIZE 61,07 OF oPanOpcao PIXEL

//������������������������������������Ŀ
//�Transferir						   �
//��������������������������������������
@ 0105,003 SAY OemToAnsi(STR0046) SIZE 050,010 OF oPanOpcao PIXEL //"Transferir:"
@ 0115,003 RADIO oItem5 VAR nItem5 3D SIZE 055,007 OF oPanOpcao PIXEL;
           ITEMS OemToAnsi( STR0048 ),;  //"Transf. e Ativar"
                 OemToAnsi( STR0043 ),;  //"Transf. s/Baixar"
                 OemToAnsi( STR0044 ),;  //"Transf. e Baixar"
                 OemToAnsi( STR0045 )    //"Baixar. s/Transf."

@ 150,002 SAY Replicate(Oemtoansi("_"),19) SIZE 61,07 OF oPanOpcao PIXEL

//������������������������������������Ŀ
//�Por Documento					   �
//��������������������������������������
@ 160,003 CHECKBOX oChk03 VAR lChk03 FONT oFnt SIZE 053,008 OF oPanOpcao PIXEL  ;
			  PROMPT OemToAnsi(STR0041) //"Por Documento"	 					 

@ 170,002 SAY Replicate(Oemtoansi("_"),19) SIZE 61,07 OF oPanOpcao PIXEL
						   
//������������������������������������Ŀ
//�Pesquisar Usuario				   �
//��������������������������������������
@ 180,001 BUTTON oPesq PROMPT OemToAnsi(STR0035) ;  //"Pesquisar Usuario"
			  ACTION ( If(QAX010PUS()== .F.,QAA->(DbGotop()),"") ,;
					If( oCombOrd:nAt == 1 .And. QAA->(IndexOrd()) <> 1, QAA->(dbSetOrder(1)),;
							If( oCombOrd:nAt == 2 .And. QAA->(IndexOrd()) <> 3, QAA->(dbSetOrder(3)),;
								If( oCombOrd:nAt == 3 .And. QAA->(IndexOrd()) <> 6, QAA->(dbSetOrder(6)),;
									If( oCombOrd:nAt == 4 .And. QAA->(IndexOrd()) <> 5, QAA->(dbSetOrder(5)),"")))), ;
			  			nOldOrdU := oCombOrd:nAt,oUsuarios:UpsTable(),oUsuarios:Refresh() ) ;
			  SIZE 061,012 OF oPanOpcao PIXEL 

//������������������������������������Ŀ
//�Ordena��o Usuarios				   �
//��������������������������������������
@ 195,002 SAY OemToAnsi(STR0032) SIZE 55,010 OF oPanOpcao PIXEL  //"Ordena��o Usuarios:"
@ 205,002 COMBOBOX oCombOrd VAR cCombOrd ITEMS aCombOrd SIZE 58,70 OF oPanOpcao PIXEL ;
			  ON CHANGE If( nOldOrdU <> oCombOrd:nAt,;
			  				(nOldOrdU := oCombOrd:nAt,;
										If( oCombOrd:nAt == 1, QAA->(dbSetOrder(1)) ,;
											If( oCombOrd:nAt == 2, QAA->(dbSetOrder(3)) ,;
												If( oCombOrd:nAt == 3, QAA->(dbSetOrder(6)) ,;
							                       QAA->(dbSetOrder(5)) ))) ,;
						   oUsuarios:UpsTable(),oUsuarios:Refresh() ) ,"") 


//���������������������������������������Ŀ
//�Folder Centros de Custo                �
//�����������������������������������������
cNDepto  := QA_NDEPT(cCcPara,.F.,cCcFilial)

//�������������������������������������������������Ŀ
//�Transferencia de Centro de Custo                 �
//���������������������������������������������������
@000,000 MSPANEL oPanTras PROMPT " "+OemToAnsi(STR0107) SIZE 080,060 OF oTransf:aDialogs[2] // "Transferencia de Centro de Custo"
oPanTras:Align := CONTROL_ALIGN_TOP

@ 015,006 SAY OemToAnsi(STR0026) SIZE 025,007 OF oPanTras PIXEL //"Filial"
@ 014,040 MSGET oCcFilial VAR cCcFilial F3 "SM0" SIZE  60, 08 OF oPanTras PIXEL ;
			  VALID (QA_CHKFIL(cCcFilial,@cFilDep) .And. FQAXA010USU(cCcFilial,cCcMatr))
			  
@ 028,006 SAY OemToAnsi(STR0021) SIZE 025,007 OF oPanTras PIXEL //"Usuario"
@ 027,040 MSGET oCcMatr VAR cCcMatr SIZE 040,008 OF oPanTras PIXEL
oCcMatr:lReadOnly:= .T.
			  			  
@ 027,095 MSGET oNome   VAR cNomAtu SIZE 096,008 OF oPanTras PIXEL
			  
@ 040,006 SAY OemToAnsi(STR0059) SIZE 035,007 OF oPanTras PIXEL //"Depto"
@ 039,040 MSGET oCcPara VAR cCcPara F3 "QDD" SIZE 055,008 OF oPanTras PIXEL ;
			  VALID (FQAXA010QAD(cCcFilial,cCcPara,@cNDepto,cCcMatr),oNDepto:Refresh()) ;
			  ON CHANGE (oNDepto:cText:=cNDepto,oNDepto:Refresh())
@ 039,095 MSGET oNDepto VAR cNDepto SIZE 096,008 OF oPanTras PIXEL
oNDepto:lReadOnly:= .T.


//�������������������������������������������������Ŀ
//�Historico de Transferencias de Centros de Custo  �
//���������������������������������������������������
@ 000,010 Say oSayHtr VAR ""  SIZE 010,010 OF oTransf:aDialogs[2] PIXEL 
oSayHtr:SetText(" "+OemToAnsi(STR0108)) // "Historico de Transferencias de Centros de Custo" 
oSayHtr:Align := CONTROL_ALIGN_TOP	

@ 075,006 LISTBOX oHistCC VAR cUsr;
			  FIELDS QAB->QAB_FILD,QAB->QAB_CCD,QAB->QAB_FILP,QAB->QAB_CCP,QAB->QAB_DATA;
			  HEADER ;
				  OemToAnsi(STR0109),; 	// "De Filial"
				  OemToAnsi(STR0110),; 	// "De Centro de Custo"
				  OemToAnsi(STR0111),; 	// "Para Filial"
				  OemToAnsi(STR0112),;	// "Para Centro de Custo"
				  OemToAnsi(STR0113);	// "Data"
			  ALIAS "QAB" ;
			  SIZE 300,085 OF oTransf:aDialogs[2] PIXEL

oHistCC:Align := CONTROL_ALIGN_ALLCLIENT			  
oHistCC:SetFilter("QAB->QAB_FILD+QAB->QAB_MATD",cFilAtu+cMatAtu,cFilAtu+cMatAtu)
oHistCC:UpStable()
oHistCC:GoTop()
oHistCC:Refresh()

		  
oTransf:bChange := {|| If( nItem3==2 .And. oTransf:nOption == 2,;
							(oTransf:nOption:=1),)}
		  
ACTIVATE MSDIALOG oDlgFolder CENTERED ;
         ON INIT EnchoiceBar( oDlgFolder, { || nOpcao:=QAX010FIM(nItem2,nItem3,nItem4,nItem5,aPenDoc,aTpPen,cCcFilial,cCcPara,cNDepto,cCcMatr,cFilAtu,cMatAtu,cDepAtu,oDlgFolder,lChk03,aAvisos),;
													IF(nOpcao==1,oDlgFolder:End(),"")},{ || nOpcao:=2,oDlgFolder:End() } )
         
If nOpcao == 1
	MsgRun( OemToAnsi( STR0036 ), OemToAnsi( STR0009 ),;
	        { || FQAXA010Grv(aPenDoc,aTpPen,cCcFilial,cCcMatr,cCcPara,lChk03,lChk04,nItem2,nItem3,nItem4,nItem5) } )  // "Transferindo Pendencias..." ### "Aguarde..."
	//���������������������������������������������������������������������������������Ŀ
	//� Ponto de Entrada para executar acoes apos a transferencia                       �
	//�����������������������������������������������������������������������������������
	IF ExistBlock( "QDOAX010" )
		ExecBlock( "QDOAX010", .f., .f., {aPenDoc} )
	Endif
Endif

MsgRun( OemToAnsi( STR0008 ), OemToAnsi( STR0009 ), { || QAXA010FIL() } )  //"Selecionando Usu�rios" ### "Aguarde..."

DbClearFilter()
RestArea(aSaveArea)

If cCcFilial == cFilAtu
	DbGoTo(nPosQAA)
Else
	QAA->(DbSeek(xFilial()))
Endif

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FQAXA010Grv � Autor � Aldo Marini Junior  � Data � 21.05.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Carrega os Lactos de Transferencia                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FQAXA010     (aTpPen,aPenDoc,aDoctos,nItem4)               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aPenDoc  = Array contendo os Lactos das Pendencias         ���
���          � aTpPen   = Array contendo os Tp.Pendencias selecionadas    ���
���          � cCcFilial= Caracter contendo filial destino                ���
���          � cCcMatr  = Caracter contendo Matricula destino             ���
���          � cCcPara  = Caracter contendo C.Custo destino               ���
���          � lChk03   = Logico Selecao de Destinatarios for por Docto   ���
���          � lChk04   = Logico indicando se Gera Revisao qdo Responsav. ���
���          � nItem2   = Numero indicando opcao (Todas Pend./Selec.Pend.)���
���          � nItem3   = Numero indicando opcao (Fil.C.Custo/Pendencias) ���
���          � nItem4   = Numero indicando opcao (Ambas/Baixadas/Pendente)���
���          � nItem5   = Numero indicando opcao de Transferencias        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function FQAXA010Grv(aPenDoc,aTpPen,cCcFilial,cCcMatr,cCcPara,lChk03,lChk04,nItem2,nItem3,nItem4,nItem5)
Local aAvPos     := 0
Local aQD0Tran   := {}
Local aQDGTran   := {}
Local cCampo     := ""
Local cCcAtu     := Space(TAMSX3("QAA_CC")[1])
Local cCcCargo   := Space(TAMSX3("QAA_CODFUN")[1])
Local cCcFilAtu  := Space(FWSizeFilial()) //Space(2)
Local cCcMatAtu  := Space(TAMSX3("QAA_MAT")[1])
Local cChkFil    := Space(FWSizeFilial()) //Space(2)
Local cChkMat    := Space(TAMSX3("QAA_MAT")[1])
Local cChkTpPnd  := Space(3)
Local cDepBsc    := Space(TAMSX3("QAA_CC")[1])
Local cFilBsc    := Space(FWSizeFilial()) //Space(2)
Local cMatBsc    := Space(TAMSX3("QAA_MAT")[1])
Local cQuery     := ""
Local cTpQDJ     := "D"
Local lMvQdoRevd := GetMv("MV_QDOREVD",.F.,"2") == "1" //1=SIM ; 2=NAO Denife se o Digitador pode Gerar Revisao.							
Local lQDGDup    := .F.
Local n0         := 1
Local n0_1       := 0
Local nA         := 1
Local nCnt       := 0
Local nOrdQDG    := 0
Local nPosA      := 1
Local nPosM1     := 0
Local nPosM2     := 0
Local nU         := 1

Private aUsrMail := {}
Private bCampo   := {|nCPO| Field( nCPO ) }

QD0->(dbSetOrder(2))
QDG->(dbSetOrder(3))
QAD->(dbSetOrder(1))
QAA->(dbSetOrder(1))
QD1->(dbSetOrder(2))
QDR->(DbSetOrder(1))
QDZ->(DbSetOrder(1))

	Begin Transaction

		//�����������������������������������������������������������������������Ŀ
		//� Transfere o Funcionario de Centro de Custo                            �
		//�������������������������������������������������������������������������
		If nItem3 == 1
	
			DbSelectArea("QAA")
			DbSetOrder(1)
			If DbSeek( cFilAtu + cMatAtu )
				RecLock("QAA",.F.)
				QAA->QAA_FILIAL:= cCcFilial
				QAA->QAA_MAT   := cCcMatr
				QAA->QAA_CC    := cCcPara
				MsUnlock()
				FKCOMMIT()
			Endif
	
			cQuery := "UPDATE"
			cQuery += " "+RetSqlName("QDP")+""
			cQuery += " SET QDP_FILMAT = '"+cCCFilial+"',"
			cQuery += " QDP_DEPTO = '"+cCcPara+"'
			cQuery += " WHERE QDP_FILIAL = '"+xFilial("QDP")+"'"
			cQuery += " AND QDP_MAT = '"+cCcMatr+"'"
			cQuery += " AND D_E_L_E_T_ <> '*'"
						
			TcSqlExec( cQuery )
			TcRefresh( RetSqlName("QDP") )
						
			cQuery := "UPDATE"
			cQuery += " "+RetSqlName("QDP")+""
			cQuery += " SET QDP_FMATBX = '"+cCCFilial+"',"
			cQuery += " QDP_DEPBX = '"+cCcPara+"'
			cQuery += " WHERE QDP_FILIAL = '"+xFilial("QDP")+"'"
			cQuery += " AND QDP_MATBX <> ' '"
			cQuery += " AND QDP_MATBX = '"+cCcMatr+"'"
			cQuery += " AND D_E_L_E_T_ <> '*'" 

			TcSqlExec( cQuery )
			TcRefresh( RetSqlName("QDP") )
	
			If cFilAtu+cMatAtu+cDepAtu <> cCcFilial+cCcMatr+cCcPara
				DbSelectArea("QAB")
				RecLock("QAB",.T.)
				QAB->QAB_FILD := cFilAtu
				QAB->QAB_MATD := cMatAtu
				QAB->QAB_CCD  := cDepAtu
				QAB->QAB_FILP := cCcFilial
				QAB->QAB_MATP := cCcMatr
				QAB->QAB_CCP  := cCcPara
				QAB->QAB_DATA := dDataBase
				MsUnlock()
				FKCOMMIT()
			EndIf
	
			//���������������������������������������Ŀ
			//�Cria e-mail de Transferencia			  �
			//�����������������������������������������
			IF nItem5 <> 3 .AND. nItem5 <> 4
				QAX10Email(QDH->QDH_DOCTO,QDH->QDH_RV,cCcFilial,cCcMatr)
			Endif
		Endif

		//�����������������������������������������������������������������������Ŀ
		//� Transfere as Pendencias 			                                  �
		//�������������������������������������������������������������������������
		If Len(aPenDoc) > 0
			For nA := 1 to Len(aTpPen)
		
				If (nItem3 == 2) .And. ( aTpPen[nA,1] == .F. .Or. aTpPen[nA,2] == .F. )
					Loop
				Endif
		
				nPosA := aScan(aPenDoc, { |x| Left(x[1],1) == aTpPen[nA,4] } )
				nPosA := If(nPosA == 0,Len(aPenDoc),nPosA)
		
				For nU := nPosA to Len(aPenDoc)
					If Left(aPenDoc[nU,1],1) <> aTpPen[nA,4]
						Exit
					Endif
			
					If nItem3 == 2
				
						If (aPenDoc[nU,4]) == .F. .Or. ;
						   ( Empty(aTpPen[nA,5]) .And. Empty(aPenDoc[nU,6]) .And. nItem5 <> 4)
							Loop
						Endif
				
					Endif
			
					cCcFilAtu := cCcFilial
					cCcMatAtu := cCcMatr
					cCcAtu    := cCcPara
			
					If !Empty(aTpPen[nA,5])
						cCcFilAtu := SubStr(aTpPen[nA,5],1,FWSizeFilial())
						cCcMatAtu := SubStr(aTpPen[nA,5],FWSizeFilial()+1)
						If QAA->(dbSeek(aTpPen[nA,5]))
							cCcAtu := QAA->QAA_CC
						Endif
					Endif
			
					If !Empty(aPenDoc[nU,6])
						cCcFilAtu := SubStr(aPenDoc[nU,6],1,FWSizeFilial())
						cCcMatAtu := SubStr(aPenDoc[nU,6],FWSizeFilial()+1)
						If QAA->(dbSeek(aPenDoc[nU,6]))
							cCcAtu := QAA->QAA_CC
						Endif
					Endif
			
					If aTpPen[nA,4] == "P"	// Pasta-Centro de Custo
						dbSelectArea("QAD")
						dbGoTo(aPenDoc[nU,7])
						If QAD->QAD_FILMAT+QAD->QAD_MAT <> cCcFilAtu+cCcMatAtu .And. nItem5 <> 4
							RecLock("QAD",.F.)
							QAD->QAD_FILMAT := cCcFilAtu
							QAD->QAD_MAT  	:= cCcMatAtu
							MsUnlock()
							FKCOMMIT()
						Endif
						Loop
					Endif

					cCcCargo  := Posicione("QAA",1,cCcFilAtu+cCcMatAtu,"QAA_CODFUN")

					// Posiciona no Docto para verificacao posterior
					dbSelectArea("QDH")
					dbSetOrder(1)
					dbSeek(aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3])
			
					// Transferencia de Destinatarios antes da Distribuicao
					If aTpPen[nA,4] == "G" .And. aPenDoc[nU,1] == "G  "
						dbSelectArea("QDG")
						dbGoTo(aPenDoc[nU,7])
				
						If QDG->QDG_FILMAT+QDG->QDG_DEPTO+QDG->QDG_MAT <> cCcFilAtu+cCcMatAtu+cCcAtu
					
							//���������������������������������������Ŀ
							//�Grava Log de Transferencia			  �
							//�����������������������������������������
							FQAXA010Log(QDG->QDG_FILIAL,QDG->QDG_DOCTO,QDG->QDG_RV,"QDG",QDG->QDG_FILMAT,QDG->QDG_MAT,QDG->QDG_DEPTO,cCcFilAtu,cCcMatAtu,cCcAtu)
							//���������������������������������������Ŀ
							//�Cria e-mail de Transferencia			  �
							//�����������������������������������������
							IF nItem5 <> 3 .AND. nItem5 <> 4
								QAX10Email(QDG->QDG_DOCTO,QDG->QDG_RV,cCcFilAtu,cCcMatAtu)
							Endif
					
							RecLock("QDG",.F.)
							QDG->QDG_RECEB  :="N"
							QDG->QDG_SIT    := "I"
							MsUnLock()
							FKCOMMIT()
					
							IF DBSEEK(aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]+cCcFilAtu+cCcAtu+cCcMatAtu)
								RecLock("QDG",.F.)
								QDG->QDG_RECEB  :="S"
								QDG->QDG_SIT    := "T"
								MsUnLock()
								FKCOMMIT()
							Else
								dbGoTo(aPenDoc[nU,7])
								RecLock("QDG",.F.)
								QDG->QDG_FILMAT := cCcFilAtu
								QDG->QDG_MAT    := cCcMatAtu
								QDG->QDG_DEPTO  := cCcAtu
								QDG->QDG_RECEB  :="S"
								QDG->QDG_SIT    := "T"
								MsUnLock()
								FKCOMMIT()
							Endif
					
							If !QDJ->(dbSeek(QDG->QDG_FILIAL+QDG->QDG_DOCTO+QDG->QDG_RV+QDG->QDG_TIPO+cCcFilAtu+cCcAtu))
								RecLock("QDJ",.T.)
								QDJ->QDJ_FILIAL	:= QDG->QDG_FILIAL
								QDJ->QDJ_DOCTO 	:= QDG->QDG_DOCTO
								QDJ->QDJ_RV    	:= QDG->QDG_RV
								QDJ->QDJ_FILMAT	:= cCcFilAtu
								QDJ->QDJ_DEPTO	:= cCcAtu
								QDJ->QDJ_TIPO	:= QDG->QDG_TIPO
								MsUnlock()
								FKCOMMIT()
								//���������������������������������������Ŀ
								//�Grava Log de Transferencia			  �
								//�����������������������������������������
								FQAXA010Log(QDJ->QDJ_FILIAL,QDJ->QDJ_DOCTO,QDJ->QDJ_RV,"QDJ",QDG->QDG_FILMAT,QDG->QDG_MAT,QDG->QDG_DEPTO,cCcFilAtu,cCcMatAtu,cCcAtu)
							Endif
						Endif
				
						//�����������������������������������������������������Ŀ
						//�Loop para realizar apenas o tipo "G" - Destinatarios �
						//�������������������������������������������������������
						Loop
				
					Endif
			
					//Transf de Avisos     
					IF aTpPen[nA,4] == "S"
						IF nItem5 <> 3 .AND. nItem5 <> 4
							aAvPos:=Ascan(aAvisos,{|x| x[1]+x[2]+x[3] == aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]})
							IF aAvPos > 0
								dbSelectArea("QDS")
								QDS->(DbSetOrder(1))
								IF nItem5 <> 2
									//��������������Ŀ
									//�Baixa o Aviso �
									//����������������
									dbGoTo(aPenDoc[nU,7])
									RecLock( "QDS",.F.)
									QDS->QDS_PENDEN 	:= "B"
									QDS->QDS_DTBAIX	:= dDataBase
									QDS->QDS_HRBAIX	:= SubStr(Time(),1,5)
									QDS->QDS_FMATBX 	:= cMatFil
									QDS->QDS_MATBX  	:= cMatCod
									QDS->QDS_DEPBX  	:= cMatDep
									MsUnlock()
									FKCOMMIT()
								Else
									//�������������������Ŀ
									//� se n�o � baixa � transf. (nItem5 = 2) ent�o  coloca origem como Inativo
									//���������������������
									dbGoTo(aPenDoc[nU,7])
									RecLock( "QDS",.F.)
									QDS->QDS_SIT		:= "I"
									MsUnlock()
									FKCOMMIT()
								Endif
								//�������������������Ŀ
								//�Grava o novo Aviso �
								//���������������������
								IF !QDS->(DBSeek(cCcFilAtu+cCcMatAtu+"P"+aAvisos[aAvPos,6]+aPenDoc[nU,2]+aPenDoc[nU,3]+aAvisos[aAvPos,7]))
									QDXGvAviso(aAvisos[aAvPos,6],cCcFilAtu,cCcMatAtu,cCcAtu,aPenDoc[nU,2],aPenDoc[nU,3],aAvisos[aAvPos,7],aPenDoc[nU,8],aAvisos[aAvPos,8],aAvisos[aAvPos,9])
								Endif

								//�����������������������������������������������������Ŀ
								//�Loop para realizar apenas o tipo "S" - Avisos 		�
								//�������������������������������������������������������
								Loop
						
							Endif
						Endif
					Endif
											
					// Criticas por Docto
					If aPenDoc[nU,9] == 1
						dbSelectArea("QD4")
						If dbSeek(aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3])
							While !Eof() .And. QD4->QD4_FILIAL+QD4->QD4_DOCTO+QD4->QD4_RV == aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]
								If aTpPen[nA,4] == Left(QD4->QD4_TPPEND,1) .And. ;
								   ( QD4->QD4_FILMAT+QD4->QD4_MAT == cFilAtu+cMatAtu .Or. ;
								   QD4->QD4_FMATBX+QD4->QD4_MATBX == cFilAtu+cMatAtu .Or. ;
							       (nPosM1 := aScan(aBuscaQD1,{|x| x[1]+x[2] == QD4->QD4_FILMAT+QD4->QD4_MAT } )) > 0 .Or. ;
							       (nPosM2 := aScan(aBuscaQD1,{|x| x[1]+x[2]+X[3] == QD4->QD4_FMATBX+QD4->QD4_MATBX+QD4->QD4_DEPBX } )) > 0 )
							
									If nItem4 == 1 .Or. ( nItem4 == 2 .And. QD4->QD4_PENDEN == "B" ) .Or. ;
									   ( nItem4 == 3 .And. QD4->QD4_PENDEN == "P" )
								    	Reclock("QD4",.F.)
										If nItem5 == 1 .Or. nItem5 == 2 .Or. nItem5 == 3	// Transf. e Ativar ou Transf. s/Baixar ou Transf. e Baixa
											If QD4->QD4_FILMAT+QD4->QD4_MAT == cFilAtu+cMatAtu .Or. ;
										       (nPosM1 > 0 .And. QD4->QD4_FILMAT+QD4->QD4_MAT == aBuscaQD1[nPosM1,1]+aBuscaQD1[nPosM1,2])
												QD4->QD4_FILMAT := cCcFilAtu
												QD4->QD4_MAT	:= cCcMatAtu
											Endif
											If QD4->QD4_FMATBX+QD4->QD4_MATBX+QD4->QD4_DEPBX == cFilAtu+cMatAtu+cDepAtu .Or. ;
											   (nPosM2 > 0 .And. QD4->QD4_FMATBX+QD4->QD4_MATBX+QD4->QD4_DEPBX == aBuscaQD1[nPosM2,1]+aBuscaQD1[nPosM2,2]+aBuscaQD1[nPosM2,3])
												QD4->QD4_FMATBX := cCcFilAtu
												QD4->QD4_MATBX	:= cCcMatAtu
												QD4->QD4_DEPBX	:= cCcAtu
											Endif
										Endif
										If nItem5 == 3 .Or. nItem5 == 4	// Transf. e Baixa ou Baixa s/Transf.
											QD4->QD4_PENDEN := "B"
											QD4->QD4_DTBAIX := dDataBase
											QD4->QD4_HRBAIX := SubStr(Time(),1,5)
											If nItem5 == 4
												QD4->QD4_FMATBX := cMatFil
												QD4->QD4_MATBX	:= cMatCod
												QD4->QD4_DEPBX	:= cMatDep
											Endif
										Endif
										MsUnlock()
										FKCOMMIT()
										//���������������������������������������Ŀ
										//�Grava Log de Transferencia					�
										//�����������������������������������������
										FQAXA010Log(QD4->QD4_FILIAL,QD4->QD4_DOCTO,QD4->QD4_RV,"QD4",cFilAtu,cMatAtu,cDepAtu,cCcFilAtu,cCcMatAtu,cCcAtu)
										//���������������������������������������Ŀ
										//�Cria e-mail de Transferencia			  �
										//�����������������������������������������
										IF nItem5 <> 3 .AND. nItem5 <> 4
											QAX10Email(QD4->QD4_DOCTO,QD4->QD4_RV,cCcFilAtu,cCcMatAtu)
										Endif
								
									Endif
								Endif
								QD4->(dbSkip())
							Enddo
						Endif
					EndIf
			
					// Solicitacoes de Alteracao
					If aPenDoc[nU,9] == 1
						dbSelectArea("QDP")
						dbSetOrder(1)  //QDP_FILIAL+QDP_DTOORI+QDP_RV+QDP_NUMSEQ
						If dbSeek(aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3])
							While !Eof() .And. QDP->QDP_FILIAL+QDP->QDP_DTOORI+QDP->QDP_RV == aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]
								If (aTpPen[nA,4] == "E" .OR. (aTpPen[nA,4] == "D" .And. lMvQdoRevd)) .And. ;
								   ( QDP->QDP_FILMAT+QDP->QDP_DEPTO+QDP->QDP_MAT == cFilAtu+cDepAtu+cMatAtu .Or. ;
								   QDP->QDP_FMATBX+QDP->QDP_DEPBX+QDP->QDP_MATBX == cFilAtu+cDepAtu+cMatAtu .Or. ;
								   (nPosM1 := aScan(aBuscaQD1, {|x| x[1]+x[2]+x[3] == QDP->QDP_FILMAT+QDP->QDP_MAT  +QDP->QDP_DEPTO } )) > 0 .Or. ;
								   (nPosM2 := aScan(aBuscaQD1, {|x| x[1]+x[2]+x[3] == QDP->QDP_FMATBX+QDP->QDP_MATBX+QDP->QDP_DEPBX } )) > 0 )
							
									If nItem4 == 1 .Or. ( nItem4 == 2 .And. QDP->QDP_PENDEN == "B" ) .Or. ;
								       ( nItem4 == 3 .And. QDP->QDP_PENDEN == "P" )
								
										Reclock("QDP",.F.)
										If nItem5 == 1 .Or. nItem5 == 2 .Or. nItem5 == 3	// Transf. s/Baixar ou Transf. e Baixa
											If QDP->QDP_FILMAT+QDP->QDP_DEPTO+QDP->QDP_MAT == cFilAtu+cDepAtu+cMatAtu .Or. ;
											   (nPosM1 > 0 .And. QDP->QDP_FILMAT+QDP->QDP_MAT+QDP->QDP_DEPTO == aBuscaQD1[nPosM1,1]+aBuscaQD1[nPosM1,2]+aBuscaQD1[nPosM1,3])
												QDP->QDP_FILMAT := cCcFilAtu
												QDP->QDP_DEPTO	 := cCcAtu
												QDP->QDP_MAT	 := cCcMatAtu
											Endif
											If QDP->QDP_FMATBX+QDP->QDP_DEPBX+QDP->QDP_MATBX == cFilAtu+cDepAtu+cMatAtu .Or. ;
											   (nPosM2 > 0 .And. QDP->QDP_FMATBX+QDP->QDP_MATBX+QDP->QDP_DEPBX == aBuscaQD1[nPosM2,1]+aBuscaQD1[nPosM2,2]+aBuscaQD1[nPosM2,3])
													QDP->QDP_FMATBX := cCcFilAtu
													QDP->QDP_DEPBX	 := cCcAtu
													QDP->QDP_MATBX	 := cCcMatAtu
												Endif
										Endif
										If nItem5 == 3 .Or. nItem5 == 4	// Transf. e Baixa ou Baixa s/Transf.
											QDP->QDP_PENDEN := "B"
											QDP->QDP_DTBAIX := dDataBase
											QDP->QDP_HRBAIX := SubStr(Time(),1,5)
											QDP->QDP_FMATBX := cMatFil
											QDP->QDP_MATBX	 := cMatCod
											QDP->QDP_DEPBX	 := cMatDep
										Endif
										MsUnLock()
										FKCOMMIT()
										//���������������������������������������Ŀ
										//�Grava Log de Transferencia					�
										//�����������������������������������������
										FQAXA010Log(QDP->QDP_FILIAL,QDP->QDP_DTOORI,QDP->QDP_RV,"QDP",cFilAtu,cMatAtu,cDepAtu,cCcFilAtu,cCcMatAtu,cCcAtu)
										//���������������������������������������Ŀ
										//�Cria e-mail de Transferencia			  �
										//�����������������������������������������
										IF nItem5 <> 3 .AND. nItem5 <> 4
											QAX10Email(QDP->QDP_DTOORI,QDP->QDP_RV,cCcFilAtu,cCcMatAtu)
										Endif
									Endif
								Endif
								QDP->(dbSkip())
							Enddo
						Endif
					EndIf
			
					If nItem4 == 1 .Or. ( nItem4 == 2 .And. aPenDoc[nU,5] == "B" ) .Or. ;
					   ( nItem4 == 3 .And. aPenDoc[nU,5] == "P" )
				
						//�������������������������������������������������������������������Ŀ
						//� Atualiza o status de pendencias D/E que tenham criticas pendentes �
						//���������������������������������������������������������������������
						If !Empty(aPenCri)
							aEval(aPenCri,{|x| aPenDoc[x,5] := "B" })
						EndIf
								
						If aTpPen[nA,4] == "D"
							If nItem5 == 1 .Or. nItem5 == 2 .Or. nItem5 == 3	// Transf. e Ativar ou Transf. s/Baixar ou Transf. e Baixa
								dbSelectArea("QDH")
								dbSetOrder(1)
								If dbSeek(aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3])
									RecLock("QDH",.F.)
									QDH->QDH_FILMAT	:= cCcFilAtu
									QDH->QDH_MAT	:= cCcMatAtu
									QDH->QDH_DEPTOE	:= cCcAtu
									MsUnlock()
									FKCOMMIT()
									//���������������������������������������Ŀ
									//�Grava Log de Transferencia			  �
									//�����������������������������������������
									FQAXA010Log(QDH->QDH_FILIAL,QDH->QDH_DOCTO,QDH->QDH_RV,"QDH",cFilAtu,cMatAtu,cDepAtu,cCcFilAtu,cCcMatAtu,cCcAtu)
									//���������������������������������������Ŀ
									//�Cria e-mail de Transferencia			  �
									//�����������������������������������������
									IF nItem5 <> 3 .AND. nItem5 <> 4
										QAX10Email(QDH->QDH_DOCTO,QDH->QDH_RV,cCcFilAtu,cCcMatAtu)
									Endif
							
								Endif
							Endif
						Endif
				
						If aTpPen[nA,4] $ "E,R,A,H"
							If nItem5 == 1 .Or. nItem5 == 2 .Or. nItem5 == 3	// Transf. e Ativar ou Transf. s/Baixar ou Transf. e Baixa
								dbSelectArea("QD0")
								For nCnt:= 1 To Len(aBuscaQD1)
									cFilBsc := aBuscaQD1[nCnt,1]
									cMatBsc := aBuscaQD1[nCnt,2]
									cDepBsc := aBuscaQD1[nCnt,3]   													                                                                 							
									IF (cFilBsc+cMatBsc+cDepBsc)==(cCcFilAtu+cCcMatAtu+cCcAtu)
										//�����������������������������������������Ŀ
										//�ignora a Transf de usuario para ele mesmo�
										//�������������������������������������������
										Loop
									Endif
							
									If QD0->(DbSeek(aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]+aTpPen[nA,4]+cFilBsc+cDepBsc+cMatBsc))
															
										aQD0Tran := {}
										While !Eof() .And. QD0->QD0_FILIAL+QD0->QD0_DOCTO+QD0->QD0_RV+QD0->QD0_AUT+QD0->QD0_FILMAT+QD0->QD0_DEPTO+QD0->QD0_MAT == aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]+aTpPen[nA,4]+cFilBsc+cDepBsc+cMatBsc
											aAdd(aQD0Tran,{ QD0->QD0_FILIAL+QD0->QD0_DOCTO+QD0->QD0_RV+QD0->QD0_AUT,QD0->QD0_FILMAT+QD0->QD0_DEPTO+QD0->QD0_MAT} )
											QD0->(dbSkip())
										Enddo
								
										For n0 :=1 to Len(aQD0Tran)
											If QD0->(dbSeek(aQD0Tran[n0,1]+aQD0Tran[n0,2]))
												nRegQD0 := QD0->(Recno())
												For n0_1 := 1 to FCount()
													cCampo  := "M->O_"+Upper( AllTrim( QD0->( FieldName( n0_1 ) ) ) )
													&cCampo := QD0->( FieldGet( n0_1 ) )
												Next
												RecLock("QD0",.F.)
													QD0->QD0_FLAG := "I"
												QD0->(MsUnlock())
												QD0->(FKCOMMIT())
												If !QD0->(dbSeek(aQD0Tran[n0,1]+cCcFilAtu+cCcAtu+cCcMatAtu))
													RecLock("QD0",.T.)
														For n0_1 := 1 to FCount()
															FieldPut( n0_1, &("M->O_"+Eval( bCampo, n0_1 ) ) )
														Next
														QD0->QD0_FILMAT := cCcFilAtu
														QD0->QD0_MAT    := cCcMatAtu
														QD0->QD0_DEPTO  := cCcAtu
														QD0->QD0_FLAG   := "T"
													QD0->(MsUnLock())
													QD0->(FKCOMMIT())
													//���������������������������������������Ŀ
													//�Grava Log de Transferencia			  �
													//�����������������������������������������
													If aPenDoc[nU,9] == 1
														FQAXA010Log(QD0->QD0_FILIAL,QD0->QD0_DOCTO,QD0->QD0_RV,QD0->QD0_AUT,cFilBsc,cMatBsc,cDepBsc,cCcFilAtu,cCcMatAtu,cCcAtu)
														//���������������������������������������Ŀ
														//�Cria e-mail de Transferencia			  �
														//�����������������������������������������
														IF nItem5 <> 3 .AND. nItem5 <> 4
															QAX10Email(QD0->QD0_DOCTO,QD0->QD0_RV,cCcFilAtu,cCcMatAtu)
														Endif
													EndIf
												Else
													RecLock("QD0",.F.)
														QD0->QD0_FLAG := "T"
													QD0->(MsUnLock())
													QD0->(FKCOMMIT())
												Endif
											Endif
										Next n0
									Endif
								Next nCnt
							Endif
						Endif
						//�������������������������������������������Ŀ
						//�Gravacao do QDZ para Transf de Distribuicao�
						//���������������������������������������������
						IF aTpPen[nA,4] == "I"
							If !QDZ->(DbSeek(aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]+cCcAtu+cCcMatAtu+cCcFilAtu))
								RecLock( "QDZ",.T.)
								QDZ->QDZ_FILIAL := aPenDoc[nU,8]
								QDZ->QDZ_DOCTO  := aPenDoc[nU,2]
								QDZ->QDZ_RV     := aPenDoc[nU,3]
								QDZ->QDZ_FILMAT := cCcFilAtu
								QDZ->QDZ_DEPTO  := cCcAtu
								QDZ->QDZ_MAT	:= cCcMatAtu
								QDZ->QDZ_DIGITA	:= "1"
								MsUnLock()
								FKCOMMIT()
								DbSelectArea("QD1")
							Endif
						Endif
						If aPenDoc[nU,9] == 1
							dbSelectArea("QD1")
							dbGoTo(aPenDoc[nU,7])
							IF QD1->QD1_PENDEN == "B" .And. nItem5 <> 4 .And. ;
							   cCcAtu+cCcFilAtu+cCcMatAtu <> QD1->QD1_DEPTO+QD1->QD1_FILMAT+QD1->QD1_MAT .And. ;
							   ( QD1->QD1_TPPEND == "L  " .Or. ( QD1->QD1_TPPEND <> "L  " .And. QDH->QDH_STATUS == "L  "))
								lQDGDup := .T.
								For n0_1 := 1 to FCount()
									cCampo := "M->O_"+Upper( AllTrim( QD1->( FieldName( n0_1 ) ) ) )
									&cCampo := QD1->( FieldGet( n0_1 ) )
								Next
								dbSetOrder(7)
								If !dbSeek(aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]+cCcAtu+cCcFilAtu+cCcMatAtu+M->O_QD1_TPPEND)
									RecLock("QD1",.T.)
									For n0_1 := 1 to FCount()
										FieldPut( n0_1, &("M->O_"+Eval( bCampo, n0_1 ) ) )
									Next
							
									QD1->QD1_FILMAT:= cCcFilAtu
									QD1->QD1_MAT   := cCcMatAtu
									QD1->QD1_DEPTO := cCcAtu
									QD1->QD1_CARGO := cCcCargo
									QD1->QD1_SIT   := "T"	// Lacto de Transferencia
							
									If QD1->QD1_TPPEND == "L  " .AND. QD1->QD1_TPDIST<>"2"
										If nItem5 == 1
											QD1->QD1_PENDEN := "P"
											QD1->QD1_DTBAIX := CTOD("  /  /  ")
											QD1->QD1_HRBAIX := Space(5)
											QD1->QD1_LEUDOC := "N"
											QD1->QD1_FMATBX := Space(FWSizeFilial()) //Space(2)
											QD1->QD1_MATBX  := Space(TAMSX3("QAA_MAT")[1])
											QD1->QD1_DEPBX  := Space(TAMSX3("QAA_CC")[1])
										Endif
									Endif
									MsUnLock()
									FKCOMMIT()
								Else
									RecLock("QD1",.F.)
									QD1->QD1_SIT := "T" // Lacto de Transferencia
							
									If QD1->QD1_TPPEND == "L  " .AND. QD1->QD1_TPDIST<>"2"
										If nItem5 == 1
											QD1->QD1_PENDEN := "P"
											QD1->QD1_DTBAIX := CTOD("  /  /  ")
											QD1->QD1_HRBAIX := Space(5)
											QD1->QD1_LEUDOC := "N"
											QD1->QD1_FMATBX := Space(FWSizeFilial())//Space(2)
											QD1->QD1_MATBX  := Space(TAMSX3("QAA_MAT")[1])
											QD1->QD1_DEPBX  := Space(TAMSX3("QAA_CC")[1])
										Endif
									Endif
									MsUnLock()
									FKCOMMIT()
								Endif
								//���������������������������������������Ŀ
								//�Grava Log de Transferencia					�
								//�����������������������������������������
								FQAXA010Log(QD1->QD1_FILIAL,QD1->QD1_DOCTO,QD1->QD1_RV,QD1->QD1_TPPEND,cFilAtu,cMatAtu,cDepAtu,cCcFilAtu,cCcMatAtu,cCcAtu)
								//���������������������������������������Ŀ
								//�Cria e-mail de Transferencia			  �
								//�����������������������������������������
								IF nItem5 <> 3 .AND. nItem5 <> 4
									QAX10Email(QD1->QD1_DOCTO,QD1->QD1_RV,cCcFilAtu,cCcMatAtu)
								Endif
						
								dbSelectArea("QD1")
								dbSetOrder(2)
								dbGoTo(aPenDoc[nU,7])
								RecLock("QD1",.F.)
								QD1->QD1_SIT := "I"	// Inativo
								MsUnlock()
								FKCOMMIT()
							Else
								lQDGDup := .F.
								dbGoTo(aPenDoc[nU,7])
								If aTpPen[nA,4] == "L" .AND. QD1->QD1_TPDIST<>"2"
									If nItem5 == 1 .And. !(nItem3 == 1 .And. cCcFilAtu+cCcMatAtu == cFilAtu+cMatAtu )
										RecLock("QD1",.F.)
										QD1->QD1_PENDEN := "P"
										QD1->QD1_DTBAIX := CTOD("  /  /  ","DDMMYY")
										QD1->QD1_HRBAIX := Space(5)
										QD1->QD1_LEUDOC := "N"
										QD1->QD1_FMATBX := Space(FWSizeFilial())//Space(2)
										QD1->QD1_MATBX  := Space(TAMSX3("QAA_MAT")[1])
										QD1->QD1_DEPBX  := Space(TAMSX3("QAA_CC")[1])
										MsUnlock()
										FKCOMMIT()         
									Endif
								Endif
								If (nItem5 <> 4) .And. ;  // Baixa s/Transf.
								   cCcAtu+cCcFilAtu+cCcMatAtu <> QD1->QD1_DEPTO+QD1->QD1_FILMAT+QD1->QD1_MAT
									dbSetOrder(7)
									If !dbSeek(aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]+cCcAtu+cCcFilAtu+cCcMatAtu+aPenDoc[nU,1])
										dbGoTo(aPenDoc[nU,7])
								
										cChkFil   := QD1->QD1_FILMAT
										cChkMat	  := QD1->QD1_MAT
										cChkTpPnd := AllTrim(QD1->QD1_TPPEND)
								
										RecLock("QD1",.F.)
										QD1->QD1_FILMAT	:= cCcFilAtu
										QD1->QD1_MAT	:= cCcMatAtu
										QD1->QD1_DEPTO	:= cCcAtu
										QD1->QD1_CARGO  := cCcCargo
										QD1->QD1_SIT	:= " "
										MsUnlock()
										FKCOMMIT()
										
										//��������������������������������������������Ŀ
										//�Transfere as pendencias com critica (EC/DC) �
										//����������������������������������������������
										QA010TCR(cChkFil,cChkMat,cChkTpPnd,cCcFilAtu,cCcMatAtu,cCcAtu,aPenDoc[nU])
									Else
										dbGoTo(aPenDoc[nU,7])
										IF aTpPen[nA,4] == "L" .AND. QD1->QD1_TPDIST<>"2"
											RecLock("QD1",.F.)
											QD1->QD1_SIT 	:= "I"
											QD1->QD1_PENDEN	:= "B"
											MsUnLock()
											FKCOMMIT()
										Else
											cChkFil   := QD1->QD1_FILMAT
											cChkMat	  := QD1->QD1_MAT
											cChkTpPnd := AllTrim(QD1->QD1_TPPEND)

											RecLock("QD1",.F.)
											QD1->QD1_FILMAT	:= cCcFilAtu
											QD1->QD1_MAT	:= cCcMatAtu
											QD1->QD1_DEPTO	:= cCcAtu
											QD1->QD1_CARGO  := cCcCargo
											QD1->QD1_SIT 	:= " "
											MsUnLock()
											FKCOMMIT()
											
											//��������������������������������������������Ŀ
											//�Transfere as pendencias com critica (EC/DC) �
											//����������������������������������������������
											QA010TCR(cChkFil,cChkMat,cChkTpPnd,cCcFilAtu,cCcMatAtu,cCcAtu,aPenDoc[nU])
										Endif
									Endif
									//���������������������������������������Ŀ
									//�Grava Log de Transferencia			  �
									//�����������������������������������������
									FQAXA010Log(QD1->QD1_FILIAL,QD1->QD1_DOCTO,QD1->QD1_RV,QD1->QD1_TPPEND,cFilAtu,cMatAtu,cDepAtu,cCcFilAtu,cCcMatAtu,cCcAtu)
									//���������������������������������������Ŀ
									//�Cria e-mail de Transferencia			  �
									//�����������������������������������������
									QAX10Email(QD1->QD1_DOCTO,QD1->QD1_RV,cCcFilAtu,cCcMatAtu)							
							
								Endif
								If nItem5 == 4 .Or. nItem5 == 3  	// Transf. e Baixa ou Baixa s/Transf.
									RecLock("QD1",.F.)
									QD1->QD1_PENDEN := "B"
									QD1->QD1_DTBAIX := dDataBase
									QD1->QD1_HRBAIX := Substr( Time(), 1, 5 )
									QD1->QD1_LEUDOC := "S"
									QD1->QD1_FMATBX := cMatFil
									QD1->QD1_MATBX  := cMatCod
									QD1->QD1_DEPBX  := cMatDep
									MsUnlock()
									FKCOMMIT()
									//���������������������������������������Ŀ
									//�Grava Log de Transferencia			  �
									//�����������������������������������������
									FQAXA010Log(QD1->QD1_FILIAL,QD1->QD1_DOCTO,QD1->QD1_RV,QD1->QD1_TPPEND,cFilAtu,cMatAtu,cDepAtu,cCcFilAtu,cCcMatAtu,cCcAtu)
									//���������������������������������������Ŀ
									//�Cria e-mail de Transferencia			  �
									//�����������������������������������������
									IF nItem5 <> 4
										QAX10Email(QD1->QD1_DOCTO,QD1->QD1_RV,cCcFilAtu,cCcMatAtu)
									Endif
								Endif
							Endif
						Endif

				
						//-- Atualiza os arquivos de Destinos e Destinatarios
						If aPenDoc[nU,9] == 1
							If aTpPen[nA,4] == "L" .And. (nItem5 == 1 .Or. nItem5 == 2 .Or. nItem5 == 3)	// Transf. s/Baixar ou Transf. e Baixa
						
								dbSelectArea("QDG")
								For nCnt:= 1 To Len(aBuscaQD1)
									cFilBsc := aBuscaQD1[nCnt,1]
									cMatBsc := aBuscaQD1[nCnt,2]
									cDepBsc := aBuscaQD1[nCnt,3]
							
									If dbSeek(aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]+cFilBsc+cDepBsc+cMatBsc)
										aQDGTran := {}
										While !Eof() .And. QDG->QDG_FILIAL+QDG->QDG_DOCTO+QDG->QDG_RV+QDG->QDG_FILMAT+QDG->QDG_DEPTO+QDG->QDG_MAT == aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]+cFilBsc+cDepBsc+cMatBsc
											aAdd(aQDGTran,{QDG->QDG_FILIAL+QDG->QDG_DOCTO+QDG->QDG_RV,QDG->QDG_FILMAT+QDG->QDG_DEPTO+QDG->QDG_MAT} )
											QDG->(dbSkip())
										Enddo
										If Len(aQDGTran) > 0
											cTpQDJ := "D"
									
											For n0:=1 to Len(aQDGTran)
												If QDG->(dbSeek(aQDGTran[n0,1]+aQDGTran[n0,2]))
													If QDG->QDG_SIT <> "I"
														nRegQDG := QDG->(Recno())
														If lQDGDup
															For n0_1 := 1 to FCount()
																cCampo := "M->O_"+Upper( AllTrim( QDG->( FieldName( n0_1 ) ) ) )
																&cCampo := QDG->( FieldGet( n0_1 ) )
															Next
													
															RecLock("QDG",.F.)
															QDG->QDG_SIT := "I"
															MsUnlock()
															FKCOMMIT()
													
															If !QDG->(dbSeek(aQDGTran[n0,1]+cCcFilAtu+cCcAtu+cCcMatAtu))
																RecLock("QDG",.T.)
																For n0_1 := 1 to FCount()
																	FieldPut( n0_1, &("M->O_"+Eval( bCampo, n0_1 ) ) )
																Next
																QDG->QDG_FILMAT	:= cCcFilAtu
																QDG->QDG_MAT		:= cCcMatAtu
																QDG->QDG_DEPTO		:= cCcAtu
																QDG->QDG_SIT      := " "
																MsUnLock()
																FKCOMMIT()
																//���������������������������������������Ŀ
																//�Grava Log de Transferencia			  �
																//�����������������������������������������
																FQAXA010Log(QDG->QDG_FILIAL,QDG->QDG_DOCTO,QDG->QDG_RV,"QDG",cFilBsc,cMatBsc,cDepBsc,cCcFilAtu,cCcMatAtu,cCcAtu)
																//���������������������������������������Ŀ
																//�Cria e-mail de Transferencia			  �
																//�����������������������������������������
																IF nItem5 <> 3 .AND. nItem5 <> 4
																	QAX10Email(QDG->QDG_DOCTO,QDG->QDG_RV,cCcFilAtu,cCcMatAtu)
																Endif
														
															Else
																RecLock("QDG",.F.)
																QDG->QDG_SIT := " "
																MsUnLock()
																FKCOMMIT()
															Endif
														Else
															If QDG->(dbSeek(aQDGTran[n0,1]+cCcFilAtu+cCcAtu+cCcMatAtu))
																RecLock("QDG",.F.)
																QDG->QDG_SIT := " "
																MsUnlock()
																FKCOMMIT()
																QDG->(dbGoTo(nRegQDG))
																If QDG->QDG_FILMAT+QDG->QDG_MAT+QDG->QDG_DEPTO <> cCcFilAtu+cCcMatAtu+cCcAtu
																	RecLock("QDG",.F.)
																	QDG->QDG_SIT := "I"
																	MsUnlock()
																	FKCOMMIT()
																EndIf
															Else
																QDG->(dbGoTo(nRegQDG))
																RecLock("QDG",.F.)
																QDG->QDG_FILMAT	:= cCcFilAtu
																QDG->QDG_MAT		:= cCcMatAtu
																QDG->QDG_DEPTO		:= cCcAtu
																MsUnlock()
																FKCOMMIT()
																//���������������������������������������Ŀ
																//�Grava Log de Transferencia			  �
																//�����������������������������������������
																FQAXA010Log(QDG->QDG_FILIAL,QDG->QDG_DOCTO,QDG->QDG_RV,"QDG",cFilBsc,cMatBsc,cDepBsc,cCcFilAtu,cCcMatAtu,cCcAtu)
																//���������������������������������������Ŀ
																//�Cria e-mail de Transferencia			  �
																//�����������������������������������������
																IF nItem5 <> 3 .AND. nItem5 <> 4
																	QAX10Email(QDG->QDG_DOCTO,QDG->QDG_RV,cCcFilAtu,cCcMatAtu)
																Endif
														
															Endif
														Endif
														cTpQDJ := QDG->QDG_TIPO
													Endif
												EndIf
											Next
											If !QDG->(dbSeek(aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]+cFilBsc+cDepBsc))
												If !QDJ->(dbSeek(aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]+cTpQDJ+cCcFilAtu+cCcAtu))
													If QDJ->(dbSeek(aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]+cTpQDJ+cFilBsc+cDepBsc))
														RecLock("QDJ",.F.)
														QDJ->QDJ_FILMAT	:= cCcFilAtu
														QDJ->QDJ_DEPTO	:= cCcAtu
														MsUnlock()
														FKCOMMIT()
														//���������������������������������������Ŀ
														//�Grava Log de Transferencia			  �
														//�����������������������������������������
														FQAXA010Log(QDJ->QDJ_FILIAL,QDJ->QDJ_DOCTO,QDJ->QDJ_RV,"QDJ",cFilBsc,cMatBsc,cDepBsc,cCcFilAtu,cCcMatAtu,cCcAtu)
														//���������������������������������������Ŀ
														//�Cria e-mail de Transferencia			  �
														//�����������������������������������������
														IF nItem5 <> 3 .AND. nItem5 <> 4
															QAX10Email(QDJ->QDJ_DOCTO,QDJ->QDJ_RV,cCcFilAtu,cCcMatAtu)
														Endif
												
													Endif
												Endif
											Endif
											If !QDJ->(dbSeek(aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]+cTpQDJ+cCcFilAtu+cCcAtu))
												RecLock("QDJ",.T.)
												QDJ->QDJ_FILIAL	:= aPenDoc[nU,8]
												QDJ->QDJ_DOCTO 	:= aPenDoc[nU,2]
												QDJ->QDJ_RV    	:= aPenDoc[nU,3]
												QDJ->QDJ_FILMAT	:= cCcFilAtu
												QDJ->QDJ_DEPTO		:= cCcAtu
												QDJ->QDJ_TIPO		:= cTpQDJ
												MsUnlock()
												FKCOMMIT()
												//���������������������������������������Ŀ
												//�Grava Log de Transferencia			  �
												//�����������������������������������������
												FQAXA010Log(QDJ->QDJ_FILIAL,QDJ->QDJ_DOCTO,QDJ->QDJ_RV,"QDJ",cFilBsc,cMatBsc,cDepBsc,cCcFilAtu,cCcMatAtu,cCcAtu)
												//���������������������������������������Ŀ
												//�Cria e-mail de Transferencia			  �
												//�����������������������������������������
												IF nItem5 <> 3 .AND. nItem5 <> 4
													QAX10Email(QDJ->QDJ_DOCTO,QDJ->QDJ_RV,cCcFilAtu,cCcMatAtu)
												Endif
										
											Endif
										Endif
									Endif
								Next nCnt
							Endif
						Endif
					EndIf
				Next
			Next
		Endif

	End Transaction

	IF Len(aUsrMail) > 0
		QaEnvMail(aUsrMail,,,,aUsrMat[5],"2")
	Endif

QD1->(dbSetOrder(3))

Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QAXA010CkPen� Autor � Aldo Marini Junior  � Data � 15.05.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Carrega os Lactos de Pendencias                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QAXA010CkPen(ExpA1,ExpA2,ExpA3,ExpN1,ExpO1)                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 - Array contendo os Tp.Pendencias selecionadas       ���
���          � ExpA2 - Array contendo os Lactos das Pendencias            ���
���          � ExpA3 - Array contendo os Doctos envolvidos com o usr      ���
���          � ExpN1 - Numerico Indicando Tp Pendencia Ambas/Baix/Pend    ���
���          � ExpO1 - Objeto do Listbox de Documentos                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function QAXA010CkPen(aTpPen,aPenDoc,aDoctos,nItem4,oDoctos,aAvisos,oAvisos,aAviAux)

Local nA		:= 1
Local cIndex2	:= CriaTrab(nil,.f.)
Local cFilBsc	:= Space(FWSizeFilial())//Space(2)
Local cMatBsc	:= Space(TamSx3("QAA_MAT")[1])
Local cDepBsc	:= Space(TamSx3("QAA_CC")[1])
Local cTrCancel := GetNewPar("MV_QTRCANC","1")
Local nTotPenDoc:= 0       
Local nPos 		:= 0
Local nI		:= 0
Local dDtIni	:= CtoD("")
Local dDtFim	:= CtoD("")
Local lPergPTr	:= SuperGetMv("MV_QDOFTRA",.F.,.T.)

Private aArryPg   := {}

Pergunte( 'QDOP20', lPergPTr )

dDtIni := mv_par01
dDtFim := mv_par02

aArryPg := fMontPerg()

QDH->(DbSetOrder(1))
QD1->(DbSetOrder(3)) 

	For nA:= 1 to Len(aBuscaQD1)
	cFilBsc := aBuscaQD1[nA,1]
	cMatBsc := aBuscaQD1[nA,2]
	cDepBsc := aBuscaQD1[nA,3]

	//����������������������������������������������������������������������Ŀ
	//�Carrega os destinatarios que ainda estao com Documentos em Elaboracao �
	//������������������������������������������������������������������������
	cQuery :=" SELECT QD1.QD1_FILIAL,QD1.QD1_DOCTO,QD1.QD1_RV,QD1.QD1_TPPEND,QD1.QD1_PENDEN,QD1.R_E_C_N_O_" 
	cQuery += " FROM " + RetSqlName("QD1")+" QD1 "
	cQuery += " WHERE QD1.QD1_FILMAT = '"+cFilBsc+"' AND QD1.QD1_MAT = '"+cMatBsc+"' AND QD1.QD1_DEPTO = '"+cDepBsc+"' AND QD1.QD1_SIT <> 'I'"
	cQuery += " AND QD1.QD1_TPPEND <> 'EC' AND QD1.QD1_TPPEND <> 'DC'"
	If lPergPTr
		cQuery += " AND (QD1.QD1_DTGERA >= '"+DtoS(dDtIni)+"' AND QD1.QD1_DTGERA <= '"+DtoS(dDtFim)+"') "
	Endif
	cQuery += " AND QD1.D_E_L_E_T_ <> '*' "
	
	cQuery += " AND NOT EXISTS(SELECT R_E_C_N_O_ FROM "+ RetSqlName("QDH")+" QDH WHERE QD1.QD1_FILIAL = QDH.QDH_FILIAL "
	cQuery += " AND QD1.QD1_DOCTO = QDH.QDH_DOCTO AND QD1.QD1_RV = QDH.QDH_RV"
	If cTrCancel =="2"
		cQuery += " AND QDH.QDH_OBSOL = 'S' AND QDH.QDH_STATUS = 'L'" 
	Else
		cQuery += " AND (QDH.QDH_OBSOL = 'S' Or (QDH.QDH_CANCEL = 'S' And QDH.QDH_STATUS = 'L'))"
	Endif
	cQuery += " AND QDH.D_E_L_E_T_ <> '*')"
	cQuery += " ORDER BY QD1.QD1_FILIAL,QD1.QD1_TPPEND,QD1.QD1_DOCTO,QD1.QD1_RV "			
	cQuery := ChangeQuery(cQuery) 
					
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QD1TRB",.T.,.T.)

	WHILE QD1TRB->(!EOF())
		If (nPos:= aScan(aTpPen,{|x| x[4] == ALLTRIM(QD1TRB->QD1_TPPEND)})) > 0
			aTpPen[nPos,2]:= .T.
			//��������������������������������������������������������Ŀ
			//� Atualiza o array com as pendencias de todas as etapas  �
			//����������������������������������������������������������
			If (nPos:= aScan(aPenDoc,{|x| x[1] == QD1TRB->QD1_TPPEND .And. x[8] == QD1TRB->QD1_FILIAL .And. x[2] == QD1TRB->QD1_DOCTO .And. x[3] == QD1TRB->QD1_RV })) == 0 .Or. ;
				(nPos > 0 .And. aPenDoc[nPos,7] <> QD1TRB->R_E_C_N_O_)
				aAdd(aPenDoc,{QD1TRB->QD1_TPPEND,QD1TRB->QD1_DOCTO,QD1TRB->QD1_RV,.T.,QD1TRB->QD1_PENDEN,Space(8),QD1TRB->R_E_C_N_O_,QD1TRB->QD1_FILIAL,1,QD1TRB->QD1_PENDEN})
			Endif
		EndIf
		QD1TRB->(DbSkip())				
	ENDDO
	DBCLOSEAREA()			
	DBSelectArea("QAD")

	//�����������������������������������������������������������������������������������Ŀ
	//� Atualiza o sinalizador no Tipo de Pendencias                                      �
	//�������������������������������������������������������������������������������������

	cQuery :="    SELECT QAD.QAD_FILIAL,QAD.QAD_CUSTO,QAD.R_E_C_N_O_" 
	cQuery += "     FROM " + RetSqlName("QAD")+" QAD "
	cQuery += "    WHERE QAD.QAD_FILMAT = '"+cFilBsc+"' AND QAD.QAD_MAT = '"+cMatBsc+"' "
	cQuery += "      AND QAD.D_E_L_E_T_ <> '*' "                                      
	cQuery += " ORDER BY QAD.QAD_FILIAL,QAD.QAD_CUSTO "
	cQuery := ChangeQuery(cQuery) 
								
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QADTRB",.T.,.T.)

	WHILE QADTRB->(!EOF())
		//�����������������������������������������������������������������������������������Ŀ
		//� Atualiza o sinalizador no Tipo de Pendencias                                      �
		//�������������������������������������������������������������������������������������
		If (nPos:= aScan(aTpPen,{|x| x[4] == "P"})) > 0
			aTpPen[nPos,2] := .T.
			//�����������������������������������������������������������������������������������Ŀ
			//� Atualiza o sinalizador no Tipo de Pendencias                                      �
			//�������������������������������������������������������������������������������������
			If (nPos:= aScan(aPenDoc,{|x| Left(x[1],1) == "P" .And. x[2] == QADTRB->QAD_FILIAL .And. x[3] == QADTRB->QAD_CUSTO})) == 0
				aAdd(aPenDoc,{"P  ",QADTRB->QAD_FILIAL,QADTRB->QAD_CUSTO,.T.,"X",Space(8),QADTRB->R_E_C_N_O_,QADTRB->QAD_FILIAL,1,'P'})
			Endif
		Endif
		QADTRB->(DbSkip())				
	ENDDO
	DBCLOSEAREA()			
	DBSelectArea("QD0")

	//����������������������������������������������Ŀ
	//� Carrega Responsaveis                         �
	//������������������������������������������������		
	IF Empty(aArryPg)
		fPenDoc(aPenDoc,aTpPen,cFilBsc,cMatBsc)
	Endif
		//����������������������������������������������������������������������Ŀ
		//�Carrega os destinatarios que ainda estao com Documentos em Elaboracao �
		//������������������������������������������������������������������������
		cQuery :=" SELECT QDG.QDG_FILIAL,QDG.QDG_DOCTO,QDG.QDG_RV,QDG.QDG_FILMAT,QDG.QDG_MAT,QDG.R_E_C_N_O_" 
		cQuery += " FROM " + RetSqlName("QDG")+" QDG ,"+ RetSqlName("QDH")+" QDH " 
		cQuery += " WHERE QDG.QDG_FILMAT = '"+cFilBsc+"' AND QDG.QDG_MAT = '"+cMatBsc+"' AND QDG.QDG_SIT <> 'I' AND"
		cQuery += " QDG.QDG_FILIAL = QDH.QDH_FILIAL AND QDG.QDG_DOCTO = QDH.QDH_DOCTO AND QDG.QDG_RV = QDH.QDH_RV AND"
		If cTrCancel =="2"
			cQuery += " QDH.QDH_OBSOL <> 'S' AND QDH.QDH_STATUS <> 'L  ' AND" 
		Else
			cQuery += " QDH.QDH_OBSOL <> 'S' AND QDH.QDH_CANCEL <> 'S' AND QDH.QDH_STATUS <> 'L  ' AND" 
		Endif
		cQuery += " QDG.D_E_L_E_T_ = ' ' AND QDH.D_E_L_E_T_ = ' '"
		cQuery += " ORDER BY QDG.QDG_FILMAT,QDG.QDG_MAT,QDG.QDG_FILIAL,QDG.QDG_DOCTO,QDG.QDG_RV"
		cQuery := ChangeQuery(cQuery) 
								
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QDGTRB",.T.,.T.)
		nTotPenDoc := Len(aPendoc)

		While QDGTRB->(!Eof())
			If Ascan( aPenDoc , {|X| X[8]+X[2]+X[3]+SubStr(X[1],1,1) == QDGTRB->QDG_FILIAL+QDGTRB->QDG_DOCTO+QDGTRB->QDG_RV+"G"}) == 0
				aAdd(aPenDoc , { "G  ", QDGTRB->QDG_DOCTO, QDGTRB->QDG_RV, .T. ,"B",Space(8), QDGTRB->R_E_C_N_O_, QDGTRB->QDG_FILIAL, 0,'G'})
			EndIf
			QDGTRB->(DbSkip())
		EndDo
		If Len(aPenDoc) > nTotPenDoc
			aTpPen[9,2] := .T.
		Endif
		
		DBCLOSEAREA()			
		DbSelectArea( "QDG" )			   	

		//���������������������������������������������������������������Ŀ
		//�Carrega os avisos que ainda estao pendentes com Documentos     �
		//�����������������������������������������������������������������
		cQuery := " SELECT QDS.QDS_FILIAL,QDS.QDS_DOCTO,QDS.QDS_RV,QDS.QDS_FILMAT,QDS.QDS_MAT,QDS_PENDEN,QDS_TPPEND,QDS_DTGERA,QDS_HRGERA,QDS_CHAVE,QDS.R_E_C_N_O_" 
		cQuery += ",QDS_DOCREF ,QDS_RVREF "
		cQuery += " FROM " + RetSqlName("QDS")+" QDS "
		cQuery += " WHERE "					
		cQuery += " QDS.QDS_FILMAT = '"+cFilBsc+"' AND QDS.QDS_MAT = '"+cMatBsc+"' AND QDS.QDS_DEPTO ='"+cDepBsc+"' AND "
		cQuery += " QDS.QDS_SIT <> 'I' AND QDS.QDS_PENDEN ='P' AND QDS.D_E_L_E_T_ <> '*' "
		If lPergPTr
				cQuery += " AND (QDS.QDS_DTGERA >= '"+DtoS(dDtIni)+"' AND QDS.QDS_DTGERA <= '"+DtoS(dDtFim)+"') "
		Endif
		cQuery += " ORDER BY "+SqlOrder("QDS_FILIAL+QDS_DOCTO+QDS_RV+QDS_PENDEN+QDS_TPPEND+QDS_CHAVE")

		cQuery := ChangeQuery(cQuery) 
					
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QDSTRB",.T.,.T.)

		TcSetField("QDSTRB","QDS_DTGERA","D")					
		nTotPenDoc := Len(aPendoc)

		While !Eof()
			If (nPos:= aScan(aPenDoc,{|x| x[1] == "S  " .And. x[8] == QDSTRB->QDS_FILIAL .And. x[2] == QDSTRB->QDS_DOCTO .And. x[3] == QDSTRB->QDS_RV })) == 0
					aAdd(aPenDoc , { "S  ",QDSTRB->QDS_DOCTO,QDSTRB->QDS_RV,.T.,QDSTRB->QDS_PENDEN,Space(8),QDSTRB->R_E_C_N_O_,QDSTRB->QDS_FILIAL,1,'S'})				
			EndIf
				
			aAdd( aAvisos, { QDSTRB->QDS_FILIAL, QDSTRB->QDS_DOCTO, QDSTRB->QDS_RV,QDSTRB->QDS_PENDEN,DTOS(QDSTRB->QDS_DTGERA)+" "+QDSTRB->QDS_HRGERA,QDSTRB->QDS_TPPEND , QDSTRB->QDS_CHAVE,QDSTRB->QDS_DOCREF,QDSTRB->QDS_RVREF })									

			QDSTRB->(DbSkip())
		EndDo
		If Len(aPenDoc) > nTotPenDoc
				aTpPen[10,2] := .T.
		Endif
		
		DBCLOSEAREA()			
		DbSelectArea( "QDS" )			   	

Next

QD1->(DbSetOrder(1))
QAD->(DbSetOrder(1))
		
If Len(aPenDoc) > 0
	aPenDoc := aSort(aPenDoc,,,{ |x,y| x[1] + x[8] + x[2] + x[3] < y[1] + y[8] + y[2] + y[3] } )
Endif

//�����������������������������������������������������������������������������������Ŀ
//� Atualiza o Array dos Documento relacionados por Tipo de Documento                 �
//�������������������������������������������������������������������������������������
FQAXA010Doc(@oDoctos,@aDoctos,@aPenDoc,aTpPen,1,nItem4,.T.,,aAvisos,@oAvisos,@aAviAux)

//�������������������������������������������������������������������Ŀ
//� Atualiza o status de pendencias D/E que tenham criticas pendentes �
//���������������������������������������������������������������������
If Len(aPenDoc) > 0
	aPenCri := {} // Reinicializa o vetor para apagar dados das transf. anteriores

	For nI := 1 To Len(aPenDoc)
		If QA010CRP(aPenDoc[nI,8],aPenDoc[nI,2],aPenDoc[nI,3],aPenDoc[nI,1],cFilBsc,cMatBsc,cDepBsc)
			aPenDoc[nI,5] := "P"	// Altera o status da pendencia para pendente
			aAdd(aPenCri,nI)		// Salva a posicao do item alterado
		EndIf
	Next
EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FQAXA010Doc� Autor � Aldo Marini Junior  � Data � 15.05.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Carrega os Lactos de Pendencias                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �FQAXA010Doc(ExpO1,ExpA1,ExpA2,ExpA3,ExpN1,ExpN2,ExpL1,ExpL2)���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 - Objeto do ListBox de Doctos                        ���
���          � ExpA1 - Array contendo os Lancamentos dos Documentos       ���
���          � ExpA2 - Array contendo os Lancamentos dos Tp de Pendenc    ���
���          � ExpA3 - Array contendo os Tipos de Pendencias              ���
���          � ExpN1 - Numerico contendo posicao atual do Tp Pendencia    ���
���          � ExpN2 - Numerico contendo o Tp Pendencia-Ambas/Baix/Pend   ���
���          � ExpL1 - Logico indicando se ira carregar no inicio prg     ���
���          � ExpL2 - Logico indicando Filtro por Status Pen/Baix/Amb    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function FQAXA010Doc(oDoctos,aDoctos,aPenDoc,aTpPen,nPosTp,nItem4,lCarrega,lTpPen,aAvisos,oAvisos,aAviAux)

Local nY		:= 1
Local nX        := 0
Local cTitulo	:= Space(50)
Local nPos 		:= 1
Local nPosA		:= 1
Local aArDoc    := {}
Local cChave	:= If(nItem4==1,"",If(nItem4==2,"B","P"))
Local aPendAx   := {}
Local aAvisAx   := {}

Default lCarrega:= .F.
Default lTpPen  := .F.

aDoctos := {}
aPendAx := {}
aAvisAx := {}

	If lVldPer

		// Filtrando os registros de Documentos escolhidos pelo usu�rio na tela de abertura De At�
		For nX := 1 To Len(aPenDoc)
			If !(AScan(aFltDoc, {|X| X[1]+X[2] == aPenDoc[nX][2]+aPenDoc[nX][3] }) == 0)
				Aadd(aPendAx,aPenDoc[nX])
			Endif
		Next

		// Filtrando os registros de Avisos com base nos Documentos escolhidos pelo usu�rio na tela de abertura De At�
		For nX := 1 To Len(aAvisos)
			If !(AScan(aFltDoc, {|X| X[1]+X[2] == aAvisos[nX][2]+aAvisos[nX][3] }) == 0)
				Aadd(aAvisAx,aAvisos[nX])
			Endif
		Next
	Else
		aPendAx := aClone(aPenDoc)
		aAvisAx := aClone(aAvisos)
	Endif

	If Len(aPendAx) > 0
		If lTpPen
			For nY := 1 to Len(aTpPen)
				aTpPen[nY,2] := .F.
			Next
		Else
			nPosA := aScan(aPendAx, { |x| Left(x[1],1) == aTpPen[nPosTp,4] } )
			nPosA := If(nPosA == 0,Len(aPendAx),nPosA)
		Endif
	
		For nY := nPosA to Len(aPendAx)
			If Left(aPendAx[nY,1],1) == "P"
				If Left(aPendAx[nY,1],1) == aTpPen[nPosTp,4]
					cTitulo := Space(50)
					QAD->(DbSetOrder(1))
					If QAD->(DbSeek(If(FWModeAccess("QAD")=="E",aPendAx[nY,2],Space(FWSizeFilial()))+aPendAx[nY,3]))
						cTitulo := QAD->QAD_DESC
					Endif
					aAdd(aDoctos,{ aPendAx[nY,4] ,!Empty(aPendAx[nY,6]),aPendAx[nY,3] , aPendAx[nY,2] , cTitulo , aPendAx[nY,6], aPendAx[nY,8], aPendAx[nY,1], aPendAx[nY,7],aPendAx[nY,10]})
					aTpPen[nPosTp,2] := .T.
				Endif
			Else
				//�����������������������������������������������������������������������������������Ŀ
				//� Verifica se ja esta fora do Tipo de Pendencia e finaliza para agilizar ListBox    �
				//�������������������������������������������������������������������������������������
				If !lTpPen .And. Left(aPendAx[nY,1],1) <> aTpPen[nPosTp,4]
					Exit
				Endif
				//�����������������������������������������������������������������������������������Ŀ
				//� Atualiza o sinalizador no Tipo de Pendencias                                      �
				//�������������������������������������������������������������������������������������
				If lTpPen
					If ( nPos := aScan(aTpPen,{|x| x[4] == Left(aPendAx[nY,1],1) } ) ) > 0 .And. ;
						( Empty(cChave) .Or. aPendAx[nY,5] == "X" .Or. (!Empty(cChave) .And. aPendAx[nY,5] == cChave ))
						aTpPen[nPos,2] := .T.
					Endif
					If Left(aPendAx[nY,1],1) <> aTpPen[nPosTp,4]
						Loop
					Endif
				Endif

				If !Empty(cChave) .And. aPendAx[nY,5] <> cChave .And. aPendAx[nY,5] <> "X"
					Loop
				Endif

				If !Empty(cChave) .And. aPendAx[nY,9] == 0
					Loop
				EndIf

				If aPendAx[nY,9] == 0
					Loop
				EndIf

				cTitulo := Space(50)
				If QDH->(dbSeek(aPendAx[nY,8]+aPendAx[nY,2]+aPendAx[nY,3]))
					cTitulo := QDH->QDH_TITULO
				Endif
				If aScan(aDoctos,{|x| X[3]+X[4]+X[5]+X[6]+X[7]+X[8]+X[10] == aPendAx[nY,2]+aPendAx[nY,3]+cTitulo+aPendAx[nY,6]+aPendAx[nY,8]+aPendAx[nY,1]+aPendAx[nY,10]}) == 0
					aAdd(aDoctos,{ aPendAx[nY,4], !Empty(aPendAx[nY,6]),aPendAx[nY,2] , aPendAx[nY,3] , cTitulo , aPendAx[nY,6], aPendAx[nY,8], aPendAx[nY,1], aPendAx[nY,7], aPendAx[nY,10]})
				EndIf
			Endif
		Next
	Endif

	If Len(aDoctos) == 0
		aAdd(aDoctos,{ .F.,.F., Space(16) , Space(3) , OemToAnsi(STR0089), Space(8), Space(2), Space(2), 0, "P" })	// "N�o ha Documentos"
		aTpPen[nPosTp,2] := .F.
	Endif

	aDoctos:= aSort(aDoctos,,,{ |x,y| x[3] + x[4] < y[3] + y[4] } )

	// Filtrando os documentos 
	For nX := 1 To Len(aDoctos)
		If nX == 1 
			Aadd(aArDoc,aDoctos[nX])
		Else
			If !(AScan(aFltDoc, {|X| X[1]+X[2] == aDoctos[nX][3]+aDoctos[nX][4] }) == 0)
				Aadd(aArDoc,aDoctos[nX])
			Endif
		Endif
	Next

	If !lCarrega
		oDoctos:aHeaders:=IF(nPosTp == 8,aHeadRes,aHeadDoc)
		oDoctos:nAt:= 1
		oDoctos:SetArray(aArDoc)
		oDoctos:bLine:= { || { If( aArDoc[oDoctos:nAt,1], hOk, hNo ),If( aArDoc[oDoctos:nAt,2], oOk, oNo ), aArDoc[oDoctos:nAt,3], aArDoc[oDoctos:nAt,4], aArDoc[oDoctos:nAt,5] } }
		oDoctos:Refresh()
		oSayT2:SetText(" "+OemToAnsi(STR0080)+"    "+"Qtd"+": ("+(Alltrim(Str(IF(aTpPen[nPosTp,2],Len(aArDoc),0))))+")") //"Documentos/Pastas"
		oSayT2:Refresh()
	Endif
           
FQAXA010Avs(aTpPen[nPosTp,4]=="S",oDoctos,aArDoc,@oAvisos,aAvisAx,@aAviAux,nItem4)

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FQAXA010Fun � Autor � Aldo Marini Junior  � Data � 15.05.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualiza ponteiro de usuarios                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �FQAXA010Fun(oUsuarios,cChave)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� oUsuarios= Objeto contendo os Usuarios                     ���
���          � cChave   = Caracter contendo a chave de pesquisa de usuario���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function FQAXA010Fun(oUsuarios,cChave)

Local nOrdem:= QAA->(Indexord())

QAA->(dbSetOrder(1))
	If !QAA->(dbSeek(cChave))
	oUsuarios:GoTop()
	Endif

oUsuarios:UpStable()
oUsuarios:Refresh()

QAA->(dbSetOrder(nOrdem))

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 �FQAXA010QAD� Autor �Aldo Marini Junior    � Data � 21/05/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Verifica se existe o Centro de Custo digitado/selecionado   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 �FQAXA010QAD(cFilCC,cCodCC,cNDepto)                          ���
�������������������������������������������������������������������������Ĵ��
���Parametro �cFilCC - Caracter indicando a Filial destino                ���
���          �cCodCC - Caracter indicando o Codigo do C.Custo destino     ���
���          �cNDepto- Caracter indicando a descricao do C.Custo destino  ���
���          �cCcMatr- Caracter indicando o Codigo do Usuario             ���
�������������������������������������������������������������������������Ĵ��
���Uso		 �QAXA010()                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/                      
Static Function FQAXA010QAD(cFilCC,cCodCC,cNDepto,cCcMatr)

Local lRet	  := .T.
Local cFilQAD := If(FWModeAccess("QAD")=="E",cFilCC,Space(FWSizeFilial()))   

	If cDepAtu == cCodCC .And. cFilAtu == cCcFilial .And. cMatAtu == cCcMatr
	lRet := .F.
	Else
	QAD->(dbSetOrder(1))
		If QAD->(DbSeek( cFilQAD + cCodCC ))
	   lRet := .T.
		cNDepto := Padr(QAD->QAD_DESC,30)
		Else
		QAD->(DbGoTop())
	   MsgStop( OemToAnsi( STR0029 ), OemToAnsi( STR0011 ) ) // "N�o foi encontrado um registro v�lido. Informe outro !" ### "Aten��o"
	   lRet := .F.
		Endif
	Endif


Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QAXA010Leg � Autor � Aldo Marini Junior   � Data � 30.03.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria uma janela contendo a legenda da mBrowse              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QAXA010Leg()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QAXA010 - Siga Quality (Generico)                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QAXA010Leg()

Local aLegenda := { {'ENABLE'    , OemtoAnsi(STR0095) },;	// "Usuario normal sem Lactos Pendentes"
                    {'DISABLE'   , OemtoAnsi(STR0096)},;	// "Usuario demitido sem Lactos Pendentes"
                    {'BR_AMARELO', OemtoAnsi(STR0097)},;  // "Usuario normal com Lactos Pendentes"
                    {'BR_AZUL'   , OemtoAnsi(STR0098)},;  // "Usuario Transferido com Lactos Pendentes"
                    {'BR_PRETO'  , OemtoAnsi(STR0099)} }  // "Usuario Demitido com Lactos Pendentes"

BrwLegenda(cCadastro,STR0100 ,aLegenda) 	// "Legenda"

Return .T.

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 �FQAXA010Ttf� Autor �Aldo Marini Junior    � Data � 11/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Valida a transferencia de lactos em fase de Elaboracao      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 �FQAXA010Ttf(nItem3,nItem5,aPenDoc,aTpPen)              	  ���
�������������������������������������������������������������������������Ĵ��
���Parametro �ExpN1 - Numero identificando a opcao 1-Demissao/2-Transfer. ���
���          �ExpN2 - Numero identificando a opcao 1-Fil.C.C./Pendencias  ���
���          �ExpN3 - Numero identificando a opcao de Transfer. Pendencias���
���          �ExpA1 - Array identificando os Doctos                       ���
���          �ExpA2 - Array identificando os Tipos de Doctos              ���
�������������������������������������������������������������������������Ĵ��
���Uso		 �QAXA010()                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function FQAXA010Ttf(nItem3,nItem5,aPenDoc,aTpPen,cCCFilial)

Local lRet    := .T.
Local nPosQAA := QAA->(RecNo())
Local cFiltro := QAA->(DbFilter())
Local nU
Local nA

	If nItem3 == 1

		If cCCFilial <> xFilial("QAA")

		DbSelectArea("QAA")
		DbClearFilter()
	
			If QAA->(DbSeek(cCcFilial+cMatAtu))
			Help("",1,"QX10FILDES") // "Usuario ja existe na Filial Destino."
			lRet:= .F.
			EndIf
	
		Set Filter To &(cFiltro)
		QAA->(DbGoto(nPosQAA))

		EndIf
                                  

	EndIf

	If lRet .And. Len(aPenDoc) > 0 .And. (nItem5 == 3 .Or. nItem5 == 4)
	//��������������������������������������������������������������Ŀ
	//� Buscar lactos Pendentes das etapas:                          �
	//� 1-Digitacao ; 2-Elaboracao; 3-Revisao ; 4-Aprovacao ;        �
	//� 5-Homologacao ; 6-Distribuicao                               �
	//����������������������������������������������������������������

		For nA := 1 to 6

			If !(aTpPen[nA,1] == .T. .And. aTpPen[nA,2] == .T.)
			Loop
			Endif

		nPosA := aScan(aPenDoc, { |x| Left(x[1],1) == aTpPen[nA,4] } )
		nPosA := If(nPosA == 0,Len(aPenDoc),nPosA)

			For nU := nPosA to Len(aPenDoc)
				If Left(aPenDoc[nU,1],1) <> aTpPen[nA,4]
				Exit
				Endif
			
				If (aPenDoc[nU,4])
				Help("",1,"HELP",,STR0160,1,0,,,,,,{STR0104, ' ', STR0105}) // Somente poder�o ser Baixados lan�amentos do tipo LEITURA 
				lRet := .F.
				Exit
				Endif
			Next

			If !lRet
			Exit
			Endif

		Next

    // Pendencias tipo aviso
		If aTpPen[10,1] == .T. .And. aTpPen[10,2] == .T. .And. lRet
	    Help(,,"HELP",,STR0160,1,0) // Selecione as Etapas e seus respectivos Documentos com um Usuario destino e tente novamente
		lRet := .F. 		
		Endif
	Endif

Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 �FQAXA010Log� Autor �Eduardo de Souza      � Data � 31/10/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Grava Log da Transferencia                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 �FQAXA010Log(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5,ExpC6,ExpC7,ExpC8,���
���          �            ExpC9,ExpC10)                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametro �ExpC1  - Filial do Documento                                ���
���          �ExpC2  - Codigo do Documento                                ���
���          �ExpC3  - Revisao do Documento                               ���
���          �ExpC4  - Tipo de Pendencia                                  ���
���          �ExpC5  - Filial do Usuario Transferido                      ���
���          �ExpC6  - Matricula do Usuario Transferido                   ���
���          �ExpC7  - Departamento do Usuario Transferido                ���
���          �ExpC8  - Filial Usuario Destino                             ���
���          �ExpC9  - Matricula Usuario Destino                          ���
���          �ExpC10 - Departamento Usuario Destino                       ���
�������������������������������������������������������������������������Ĵ��
���Uso		 �QAXA010()                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function FQAXA010Log(cFilDoc,cDocto,cRv,cTpPend,cFilDe,cMatDe,cDeptoDe,cFilPara,cMatPara,cDeptoPara)

Local cAlias    := Alias()
Local nOrd		 := IndexOrd()
Local lGrava	:=.T.

Default cFilial   := Space(FWSizeFilial())
Default cDocto    := ""
Default cRv       := ""
Default cTpPend   := ""
Default cFilDe    := Space(FWSizeFilial()) //""
Default cMatDe    := ""
Default cDeptoDe  := ""
Default cFilPara  := Space(FWSizeFilial()) //""
Default cMatPara  := ""
Default cDeptoPara:= ""

DbSelectArea("QDR")
DbSetOrder(1)

//����������������������������������������������������������������������������������������������������������������������Ŀ
//�Pesquisa Chave unica                                                                                                  �
//�QDR_FILIAL+QDR_DOCTO+QDR_RV+QDR_TPPEND+QDR_FILDE+QDR_MATDE+QDR_DEPDE+QDR_FILPAR+QDR_MATPAR+QDR_DEPPAR+DTOS(QDR_DTTRAN)�
//������������������������������������������������������������������������������������������������������������������������
	IF QDR->(DBSeek(cFilDoc+cDocto+cRv+DTOS(dDataBase))) //QDR_FILIAL+QDR_DOCTO+QDR_RV+DTOS(QDR_DTTRAN)
		While QDR->(!EOF()) .AND. QDR->QDR_FILIAL+QDR->QDR_DOCTO+QDR->QDR_RV+DTOS(QDR->QDR_DTTRAN)==cFilDoc+cDocto+cRv+DTOS(dDataBase)
			IF QDR->QDR_FILIAL+QDR->QDR_DOCTO+QDR->QDR_RV+Alltrim(QDR->QDR_TPPEND)+;
			QDR->QDR_FILDE+QDR->QDR_MATDE+QDR->QDR_DEPDE+QDR->QDR_FILPAR+QDR->QDR_MATPAR+QDR->QDR_DEPPAR+DTOS(QDR->QDR_DTTRAN)== ;
			cFilDoc+cDocto+cRv+cTpPend+cFilDe+cMatDe+cDeptoDe+cFilPara+cMatPara+cDeptoPara+DTOS(dDatabase)
			
			lGrava:=.F.
			Exit
				Endif
		QDR->(DbSkip())
		Enddo
	Endif

	IF lGrava
	RecLock("QDR",.T.)
	QDR->QDR_FILIAL:= cFilDoc
	QDR->QDR_DOCTO := cDocto
	QDR->QDR_RV    := cRv
	QDR->QDR_DTTRAN:= dDataBase
	QDR->QDR_TPPEND:= cTpPend
	QDR->QDR_MOTIVO:= cMotTransf
	QDR->QDR_FILRES:= cMatFil
	QDR->QDR_MATRES:= cMatCod
	QDR->QDR_DEPRES:= cMatDep
	QDR->QDR_FILDE := cFilDe
	QDR->QDR_MATDE := cMatDe
	QDR->QDR_DEPDE := cDeptoDe
	QDR->QDR_FILPAR:= cFilPara
	QDR->QDR_MATPAR:= cMatPara
	QDR->QDR_DEPPAR:= cDeptoPara
	MsUnlock()		
	FKCOMMIT()														
	Endif
	
DbSelectArea(cAlias)
DbSetOrder(nOrd)

Return 

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 �QA010DlgJus� Autor �Eduardo de Souza      � Data � 01/11/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Tela de Justificativa                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 �QA010DlgJus()   				                                ���
�������������������������������������������������������������������������Ĵ��
���Uso		 �QAXA010()                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QA010DlgJus(oDlg)

Local oMotTransf
Local lGrava:= .F.

DEFINE MSDIALOG oDlgTransf TITLE OemToAnsi(STR0106) FROM 150,000 TO 230,280 OF oDlg PIXEL

@ 005,005 MSGET oMotTransf VAR cMotTransf SIZE 130,010 OF oDlgTransf PIXEL

DEFINE SBUTTON FROM 021,075 TYPE 1 ENABLE OF oDlgTransf;
   ACTION  (If(NaoVazio(cMotTransf),(lGrava := .T.,oDlgTransf:End()),));

DEFINE SBUTTON FROM 021,105 TYPE 2 ENABLE OF oDlgTransf;
   ACTION  (lGrava := .F.,oDlgTransf:end());

ACTIVATE MSDIALOG oDlgTransf CENTERED 

Return lGrava

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 � QAX010VdEx � Autor � Eduardo de Souza    � Data � 25/03/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Valida Exclusao de Usuarios                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QAX010VdEx()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QAXA010 - Siga Quality (Generico)                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QAX010VdEx()

Local nOrd01  := 0
Local cIndex  := ""
Local cKey    := ""
Local cFiltro := ""
Local lApaga  := .T. 
Local QTD	  := 0

//�������������������������������������������������Ŀ
//� RESPONSAVEIS                                    �
//���������������������������������������������������
	If lApaga
	cQuery := "Select Count (*)  QTD" 
	cQuery += " From " + RetSqlName("QD0") + " QD0 "
	cQuery += " Where QD0.QD0_FILMAT = '" + QAA->QAA_FILIAL + "' and "
	cQuery += "       QD0.QD0_MAT = '" + QAA->QAA_MAT + "' and "
	cQuery += "       QD0.D_E_L_E_T_ = ' '"
	
	cQuery := ChangeQuery(cQuery)
	
		If Qtd > 0
		lApaga := .F.
		Endif
	EndIf

//�������������������������������������������������Ŀ
//� PENDENCIAS                                      �
//���������������������������������������������������
	If lApaga
		cQuery := "Select Count (*)  QTD" 
		cQuery += " From " + RetSqlName("QD1") + " QM6 "
		cQuery += " Where QD1.QD1_FILMAT = '" + QAA->QAA_FILIAL + "' and "
		cQuery += "       QD1.QD1_MAT = '" + QAA->QAA_MAT + "' and "
		cQuery += "       QD1.D_E_L_E_T_ = ' '"
		
		cQuery := ChangeQuery(cQuery)
		
		If Qtd > 0
			lApaga := .F.
		Endif
	EndIf

//�������������������������������������������������Ŀ
//� JUSTIFICATIVAS POR DOCUMENTO                    �
//���������������������������������������������������
	If lApaga
	nOrd01:= QD7->(IndexOrd())	
	DbSelectarea("QD7")
	cIndex  := CriaTrab(Nil,.F.)
	cKey    := "QD7_FILMAT+QD7_MAT"
	cFiltro := "QD7->QD7_FILMAT+QD7->QD7_MAT == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"'"
	IndRegua("QD7",cIndex,cKey,,cFiltro,OemToAnsi(STR0114)) //"Validando Exclusao..."
		If QD7->(!Eof())
		lApaga:= .F.
		EndIf
	RetIndex("QD7")
	DbClearFilter()
	cIndex += OrDbagExt()
	Delete File &(cIndex)
	QD7->(DbSetOrder(nOrd01))
	EndIf

//�������������������������������������������������Ŀ
//� TREINAMENTOS CARGOxDEPTOxUSUAR                  �
//���������������������������������������������������
	If lApaga
	nOrd01:= QD8->(IndexOrd())	
	DbSelectarea("QD8")
	cIndex  := CriaTrab(Nil,.F.)
	cKey    := "QD8_FILMAT+QD8_MAT"
	cFiltro := "QD8->QD8_FILMAT+QD8->QD8_MAT == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"'"
	IndRegua("QD8",cIndex,cKey,,cFiltro,OemToAnsi(STR0114)) //"Validando Exclusao..."
		If QD8->(!Eof())
		lApaga:= .F.
		EndIf
	RetIndex("QD8")
	DbClearFilter()
	cIndex += OrDbagExt()
	Delete File &(cIndex)
	QD8->(DbSetOrder(nOrd01))
	EndIf

//�������������������������������������������������Ŀ
//� SUGESTOES						                �
//���������������������������������������������������
	If lApaga
	nOrd01:= QD9->(IndexOrd())	
	DbSelectarea("QD9")
	cIndex  := CriaTrab(Nil,.F.)
	cKey    := "QD9_FILMAT+QD9_MAT"
	cFiltro := "QD9->QD9_FILMAT+QD9->QD9_MAT == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"'"
	IndRegua("QD9",cIndex,cKey,,cFiltro,OemToAnsi(STR0114)) //"Validando Exclusao..."
		If QD9->(!Eof())
		lApaga:= .F.
		EndIf
	RetIndex("QD9")
	DbClearFilter()
	cIndex += OrDbagExt()
	Delete File &(cIndex)
	QD9->(DbSetOrder(nOrd01))
	EndIf

//�������������������������������������������������Ŀ
//� TREINAMENTO      				                �
//���������������������������������������������������
	If lApaga
	nOrd01:= QDA->(IndexOrd())	
	DbSelectarea("QDA")
	cIndex  := CriaTrab(Nil,.F.)
	cKey    := "QDA_FILF1+QDA_MAT1"
	cFiltro := "(QDA->QDA_FILF1+QDA->QDA_MAT1 == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"' .Or. "
	cFiltro += "QDA->QDA_FILF2+QDA->QDA_MAT2 == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"' .Or. "
	cFiltro += "QDA->QDA_FILF3+QDA->QDA_MAT3 == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"')"
	IndRegua("QDA",cIndex,cKey,,cFiltro,OemToAnsi(STR0114)) //"Validando Exclusao..."
		If QDA->(!Eof())
		lApaga:= .F.
		EndIf
	RetIndex("QDA")
	DbClearFilter()
	cIndex += OrDbagExt()
	Delete File &(cIndex)
	QDA->(DbSetOrder(nOrd01))
	EndIf

//�������������������������������������������������Ŀ
//� DESTINATARIOS    				                �
//���������������������������������������������������
	If lApaga
	nOrd01:= QDG->(IndexOrd())	
	QDG->(DbSetOrder(8))
		If QDG->(DbSeek(QAA->QAA_FILIAL+QAA->QAA_MAT))
		lApaga:= .F.
		EndIf
	QDG->(DbSetOrder(nOrd01))
	EndIf

//�������������������������������������������������Ŀ
//� DOCUMENTOS       				                �
//���������������������������������������������������
	If lApaga
	cQuery := "Select Count (*)  QTD" 
	cQuery += " From " + RetSqlName("QDH") + " QM6 "
	cQuery += " Where QDH.QDH_FILMAT = '" + QAA->QAA_FILIAL + "' and "
	cQuery += "       QDH.QDH_MAT = '" + QAA->QAA_MAT + "' and "
	cQuery += "       QDH.D_E_L_E_T_ = ' '"
	
	cQuery := ChangeQuery(cQuery)
	
		If Qtd > 0
		lApaga := .F.
		Endif
	EndIf

//�������������������������������������������������Ŀ
//� REGISTRO ASSINATURA DE USRS.	                �
//���������������������������������������������������
	If lApaga
	nOrd01:= QDN->(IndexOrd())	
	DbSelectarea("QDN")
	cIndex  := CriaTrab(Nil,.F.)
	cKey    := "QDN_FILIAL+QDN_MAT"
	cFiltro := "QDN->QDN_FILIAL+QDN->QDN_MAT == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"'"
	IndRegua("QDN",cIndex,cKey,,cFiltro,OemToAnsi(STR0114)) //"Validando Exclusao..."
		If QDN->(!Eof())
		lApaga:= .F.
		EndIf
	RetIndex("QDN")
	DbClearFilter()
	cIndex += OrDbagExt()
	Delete File &(cIndex)
	QDN->(DbSetOrder(nOrd01))
	EndIf

//�������������������������������������������������Ŀ
//� SOLICITACOES                                    �
//���������������������������������������������������
	If lApaga
	nOrd01:= QDP->(IndexOrd())	
	DbSelectarea("QDP")
	cIndex  := CriaTrab(Nil,.F.)
	cKey    := "QDP_FILIAL+QDP_MAT"
	cFiltro := "(QDP->QDP_FILIAL+QDP->QDP_MAT == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"' .Or. "
	cFiltro += "QDP->QDP_FMATBX+QDP->QDP_MATBX == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"')"
	IndRegua("QDP",cIndex,cKey,,cFiltro,OemToAnsi(STR0114)) //"Validando Exclusao..."
		If QDP->(!Eof())
		lApaga:= .F.
		EndIf
	RetIndex("QDP")
	DbClearFilter()
	cIndex += OrDbagExt()
	Delete File &(cIndex)
	QDP->(DbSetOrder(nOrd01))
	EndIf

//�������������������������������������������������Ŀ
//� AVISOS          				                �
//���������������������������������������������������
	If lApaga
	nOrd01:= QDS->(IndexOrd())	
	QDS->(DbSetOrder(1))
		If QDS->(DbSeek(QAA->QAA_FILIAL+QAA->QAA_MAT))
		Return .F.
		EndIf
	QDS->(DbSetOrder(nOrd01))
	EndIf
     
//�������������������������������������������������Ŀ
//� DEPARTAMENTOS (Responsavel)                     �
//���������������������������������������������������
	If lApaga
	nOrd01:= QAD->(IndexOrd())	
	QAD->(DbSetOrder(2))
		If QAD->(DBSeek(QAA->QAA_FILIAL+QAA->QAA_MAT))
		Return .F.
		EndIf
	QAD->(DbSetOrder(nOrd01))
	EndIf

//�����������������������������������������������������Ŀ
//� VALIDA RELACIONAMENTOS DAS TABELAS DA NG INFORMATICA�
//�������������������������������������������������������
	If lApaga
		If !NGVALSX9("QAA")
		dbSelectArea("QAD")
		dbSetOrder(1)
		Return .F.
		Else
		dbSelectArea("QAD")
		dbSetOrder(1)
		Endif
	Endif
Return lApaga

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao	 �FQAXA010USU� Autor �Aldo Marini Junior      � Data � 21/05/00 ���
���������������������������������������������������������������������������Ĵ��
���Descri�ao �Verifica se existe o Centro de Custo digitado/selecionado     ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe	 �FQAXA010USU(CcFilial,cCcMatr)                                 ���
���������������������������������������������������������������������������Ĵ��
���Parametro �cCcFilial - Caracter indicando a Filial destino               ���
���          �cCcMatr   - Caracter indicando a Matricula usuario destino    ���
���������������������������������������������������������������������������Ĵ��
���Uso		 �QAXA010()                                                     ���
���������������������������������������������������������������������������Ĵ��
���Observacao�                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/                      
Static Function FQAXA010USU(cCcFilial,cCcMatr)
Local lRet    := .T.
Local nPosQAA := QAA->(RecNo())
Local cFiltro := QAA->(DbFilter())

	If (cFilAtu <> cCcFilial)

	DbSelectArea("QAA")
	DbClearFilter()
	
		If QAA->(DbSeek(cCcFilial+cCcMatr))
		Help("",1,"QX10FILDES") // "Usuario ja existe na Filial Destino."
		lRet:= .F.
		EndIf
	
	Set Filter To &(cFiltro)
	QAA->(DbGoto(nPosQAA))

	EndIf

Return( lRet )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QAX10MarU �Autor  �Telso Carneiro      � Data �  14/05/2004 ���
�������������������������������������������������������������������������͹��
���Desc.     �   MARCAR/DESMARCAR USUARIOS		                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � BUTTON  oMarcar                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function QAX10MarU(lChk03,aDoctos,oDoctos,aPenDoc,oTpPen,aTpPen,cFilAtu,cMatAtu,aAvisos)
	Local lRet 		:= .T.
	Local nI		:= 0
	Local nPosT 	:= 0

//�����������������������������������������������������������������Ŀ
//�Verifica a Existencia de Ausencia Temporia para o Usuario Destino�
//�������������������������������������������������������������������
	IF oTpPen:nAt <= 6 //Todos os Tipos de Pendencia ate Distribuicao
		//�����������������������������������������������������������������Ŀ
		//�Verifica a Existencia de Ausencia Temporia para o Usuario Destino�
		//�������������������������������������������������������������������
		IF QA_SitAuDP(QAA->QAA_FILIAL,QAA->QAA_MAT,aTpPen[oTpPen:nAt,4])
			Help(" ",1,"QX040JEAP",,aTpPen[oTpPen:nAt,3]+" (" + Alltrim(QAA->QAA_MAT) + "-" + AllTrim(QA_NUSR(QAA->QAA_FILIAL,QAA->QAA_MAT)) + ")",05,00) // "Ja existe Ausencia Temporaria cadastrada no Periodo para este Usuario."
			lRet  := .F.
		Endif
		IF lRet
			//�����������������������������������������������������������������Ŀ
			//�Verifica a Existencia de Ausencia Temporia para o Usuario Origem �
			//�������������������������������������������������������������������
			IF QA_SitAuDP(cFilAtu,cMatAtu,aTpPen[oTpPen:nAt,4])
				Help(" ",1,"QX040JEAP",,aTpPen[oTpPen:nAt,3]+" (" + Alltrim(cMatAtu) + "-" + AllTrim(QA_NUSR(cFilAtu,cMatAtu)) + ")",05,00) // "Ja existe Ausencia Temporaria cadastrada no Periodo para este Usuario."
				lRet  := .F.
			Endif
			IF lRet
				//�����������������������������������������������������������������������������Ŀ
				//�Verifica o Usurio que vai receber a pendencia de Distribuicao e DISTSN (SIM) �
				//�������������������������������������������������������������������������������
				IF aTpPen[oTpPen:nAt,4]=="I" .AND. QAA->QAA_DISTSN =="2"
					MsgAlert(OemToAnsi(STR0128),OemToAnsi(STR0127)) //"O usu�rio informado para pendencia de Distribui��o N�O est� indicado como um distribuidor no cadastro !"###"Atencao"
					lRet  := .F.
				Endif
				//��������������������������������������������������������������������Ŀ
				//�Verifica se a Distribui��o pode ser executada para o Usuario Destino�
				//����������������������������������������������������������������������
				If oTpPen:nAt == 6 .and. !lChk03 .And. lRet
					lRet := QAX10SDoc(QAA->QAA_FILIAL,QAA->QAA_MAT,QAA->QAA_CC,cFilAtu,cMatAtu,cDepAtu,aDoctos)
					If !lRet
						aTpPen[6,1] := .F.
					EndIf
				EndIf
			Endif
		Endif
	Endif

	IF lRet
		If lChk03
			IF QAA->QAA_FILIAL+QAA->QAA_MAT==cFilAtu+cMatAtu
				Help(" ",1,"QD_USRNTRF")
			Else
				If Empty(aDoctos[oDoctos:nAt,6])
					aDoctos[oDoctos:nAt,6] := (QAA->QAA_FILIAL+QAA->QAA_MAT)
					lRet := QAX10SDoc(QAA->QAA_FILIAL,QAA->QAA_MAT,QAA->QAA_CC,cFilAtu,cMatAtu,cDepAtu,aDoctos,oDoctos,lChk03)
					If !lRet
						aTpPen[6,1] := .F.
					EndIf
				Else
					aDoctos[oDoctos:nAt,6] := SPACE(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1])
				Endif

				aDoctos[oDoctos:nAt,2] := !Empty(aDoctos[oDoctos:nAt,6])
			Endif

			oDoctos:Refresh()
			nPosT := 0
			nPosT := aScan(aPenDoc,{|x| x[1] == aDoctos[oDoctos:nAt,8] .And. x[7] == aDoctos[oDoctos:nAt,9] }) // Verifica Tipo de Pend. e Recno devido a fonte diversificada do recno
			aPenDoc[nPosT,6] := If(nPosT > 0 .And. !Empty(aDoctos[oDoctos:nAt,6]) .And. QAA->QAA_FILIAL+QAA->QAA_MAT <> cFilAtu+cMatAtu , QAA->QAA_FILIAL+QAA->QAA_MAT ,Space(8))
		Else
			IF QAA->QAA_FILIAL+QAA->QAA_MAT==cFilAtu+cMatAtu
				Help(" ",1,"QD_USRNTRF")
			Else
				IF Empty(aTpPen[oTpPen:nAt,5])
					aTpPen[oTpPen:nAt,5] := (QAA->QAA_FILIAL+QAA->QAA_MAT)
				Else
					aTpPen[oTpPen:nAt,5] := SPACE(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1])
				Endif
			Endif

			oTpPen:SetArray(aTpPen)
			oTpPen:bLine:= { || { If( aTpPen[ oTpPen:nAt, 1], hOk, hNo ), If( aTpPen[ oTpPen:nAt, 2 ], oOk, oNo ), If(!Empty(aTpPen[ oTpPen:nAt, 5 ]),oOk ,oNo ), aTpPen[ oTpPen:nAt, 3 ] } }
			oTpPen:Refresh()
		Endif
	Endif

Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QAX10MarT �Autor  �Telso Carneiro      � Data �  14/05/2004 ���
�������������������������������������������������������������������������͹��
���Desc.     � MARCAR/DESMARCAR TODOS                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � oItem2:bChange                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function QAX10MarT(nItem2,oItem2,aTpPen,oTpPen,cFilAtu,cMatAtu,aDoctos,aAvisos)
	Local lRet  := .T.
	Local nI	:= 0
	Local SpaceQAA:=Space(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1])

	Default aDoctos := {}

	CursorWait()
	If nItem2 == 1
		oItem2:nOption := 1
		For nI:=1 To 6 //Todos os Tipos de Pendencia ate Distribuicao
			IF aTpPen[nI,2]
				//�����������������������������������������������������������������Ŀ
				//�Verifica a Existencia de Ausencia Temporia para o Usuario Destino�
				//�������������������������������������������������������������������
				IF QA_SitAuDP(QAA->QAA_FILIAL,QAA->QAA_MAT,aTpPen[nI,4])
					Help(" ",1,"QX040JEAP",,aTpPen[nI,3]+" (" + Alltrim(QAA->QAA_MAT) + "-" + AllTrim(QA_NUSR(QAA->QAA_FILIAL,QAA->QAA_MAT)) + ")",05,00) // "Ja existe Ausencia Temporaria cadastrada no Periodo para este Usuario."
					lRet  := .F.
				Endif
				//��������������������������������������������������������������������Ŀ
				//�Verifica se a Distribui��o pode ser executada para o Usuario Destino�
				//����������������������������������������������������������������������
				If lRet .And. nI == 6
					lRet := QAX10SDoc(QAA->QAA_FILIAL,QAA->QAA_MAT,QAA->QAA_CC,cFilAtu,cMatAtu,cDepAtu,aDoctos)
					If !lRet
						aTpPen[6,1] := .F.
						nItem2:= 2
						oItem2:nOption := 2
					EndIf
				EndIf
				IF lRet
					//�����������������������������������������������������������������Ŀ
					//�Verifica a Existencia de Ausencia Temporia para o Usuario Origem �
					//�������������������������������������������������������������������
					IF QA_SitAuDP(cFilAtu,cMatAtu,aTpPen[nI,4])
						Help(" ",1,"QX040JEAP",,aTpPen[nI,3]+" (" + Alltrim(cMatAtu) + "-" + AllTrim(QA_NUSR(cFilAtu,cMatAtu)) + ")",05,00) // "Ja existe Ausencia Temporaria cadastrada no Periodo para este Usuario."
						lRet  := .F.
					Endif
					//�����������������������������������������������������������������������������Ŀ
					//�Verifica o Usurio que vai receber a pendencia de Distribuicao e DISTSN (SIM) �
					//�������������������������������������������������������������������������������
					IF lRet .AND. aTpPen[nI,4]=="I" .AND. QAA->QAA_DISTSN =="2"
						MsgAlert(OemToAnsi(STR0128),OemToAnsi(STR0127)) //"O usu�rio informado para pendencia de Distribui��o N�O est� indicado como um distribuidor no cadastro !"###"Atencao"
						lRet  := .F.
					Endif
				Endif
				IF !lRet
					Exit
				Endif
			Endif
		Next
		IF lRet
			aTpPen[1,1] := .T.
			aTpPen[1,5] := If(aTpPen[1,2],QAA->QAA_FILIAL+QAA->QAA_MAT,SpaceQAA) // "Digita��o"
			aTpPen[2,1] := .T.
			aTpPen[2,5] := If(aTpPen[2,2],QAA->QAA_FILIAL+QAA->QAA_MAT,SpaceQAA) // "Elabora��o"
			aTpPen[3,1] := .T.
			aTpPen[3,5] := If(aTpPen[3,2],QAA->QAA_FILIAL+QAA->QAA_MAT,SpaceQAA) // "Revis�o"
			aTpPen[4,1] := .T.
			aTpPen[4,5] := If(aTpPen[4,2],QAA->QAA_FILIAL+QAA->QAA_MAT,SpaceQAA) // "Aprova��o"
			aTpPen[5,1] := .T.
			aTpPen[5,5] := If(aTpPen[5,2],QAA->QAA_FILIAL+QAA->QAA_MAT,SpaceQAA) // "Homologa��o"
			aTpPen[6,1] := .T.
			aTpPen[6,5] := If(aTpPen[6,2],QAA->QAA_FILIAL+QAA->QAA_MAT,SpaceQAA) // "Distribui��o"
			aTpPen[7,1] := .T.
			aTpPen[7,5] := If(aTpPen[7,2],QAA->QAA_FILIAL+QAA->QAA_MAT,SpaceQAA) // "Leitura"
			aTpPen[8,1] := .T.
			aTpPen[8,5] := If(aTpPen[8,2],QAA->QAA_FILIAL+QAA->QAA_MAT,SpaceQAA) // "Resp.Depto"
			aTpPen[9,1] := .T.
			aTpPen[9,5] := If(aTpPen[9,2],QAA->QAA_FILIAL+QAA->QAA_MAT,SpaceQAA) // "Destinatario"
			aTpPen[10,1]:= .T.
			aTpPen[10,5]:= If(aTpPen[10,2],QAA->QAA_FILIAL+QAA->QAA_MAT,SpaceQAA) // "Aviso"
		Else
			nItem2:= 2
			oItem2:nOption := 2
		Endif
	Else
		aTpPen[1,5] := SpaceQAA  //	"Digita��o"
		aTpPen[2,5] := SpaceQAA  // "Elabora��o"
		aTpPen[3,5] := SpaceQAA  // "Revis�o"
		aTpPen[4,5] := SpaceQAA	 // "Aprova��o"
		aTpPen[5,5] := SpaceQAA	 // "Homologa��o"
		aTpPen[6,5] := SpaceQAA	 // "Distribui��o"
		aTpPen[7,5] := SpaceQAA	 // "Leitura"
		aTpPen[8,5] := SpaceQAA	 // "Resp.Depto"
		aTpPen[9,5] := SpaceQAA	 // "Destinatario"
		aTpPen[10,5]:= SpaceQAA	 // "Aviso"
	Endif
	oTpPen:bLine:= { || { If(aTpPen[oTpPen:nAt,1], hOk, hNo ), If(aTpPen[oTpPen:nAt,2], oOk, oNo ), If(!Empty(aTpPen[oTpPen:nAt,5]),oOk ,oNo ), aTpPen[oTpPen:nAt,3] } }
	oTpPen:Refresh()
	CursorArrow()
Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QAX10VldAu�Autor  �Telso Carneiro      � Data �  14/05/2004 ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica a Existencia de Ausencia Temporia para o Usuario  ���
���			 �  Destino nos Tipos Pendencias ate a Distribuicao           ���
�������������������������������������������������������������������������͹��
���Uso       � oItem2:bChange  / Valid da Troca de Depto                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function QAX10VldAu(cFilUsu,cCodUsu,aTpPen)
	Local lRet :=.T.
	Local nI

	CursorWait()
	For nI:=1 To 6 //Todos os Tipos de Pendencia ate Distribuicao
		IF aTpPen[nI,2]
			IF QA_SitAuDP(cFilUsu,cCodUsu,aTpPen[nI,4])
				Help(" ",1,"QX040JEAP",,aTpPen[nI,3]+" (" + Alltrim(cCodUsu) + "-" + AllTrim(QA_NUSR(cFilUsu,cCodUsu)) + ")",05,00) // "Ja existe Ausencia Temporaria cadastrada no Periodo para este Usuario."
				lRet  := .F.
				Exit
			Endif
		Endif
	Next

	CursorArrow()

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QAX10Email�Autor  �Telso Carneiro      � Data � 03/06/2004  ���
�������������������������������������������������������������������������͹��
���Desc.     � Cria e-mail de Transferencia			                      ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function QAX10Email(cDocto,cRv,cFilPara,cMatPara)

	Local aDiv      := {}
	Local aAlQAA	:= QAA->(GETAREA())

	QAA->(DBSETORDER(1))
	IF QAA->(DBSEEK(cFilPara+cMatPara))
		If !Empty(QAA->QAA_EMAIL) .And. QAA->QAA_RECMAI == "1"
			IF ASCAN(aUsrMail,{|x| Alltrim(x[1])==Alltrim(QAA->QAA_APELID)}) == 0
				FQDOTPMAIL(@aUsrMail,cDocto,cRv,,QAA->QAA_EMAIL,"TRF",cMatFil,QAA->QAA_APELID,QAA->QAA_MAT,,,aDiv,,)
			Endif
		EndIf
	ENDIF

	RestArea(aAlQAA)

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QAX010Lib �Autor  �Telso Carneiro      � Data �  08/06/2004 ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica a Existencia da matriz de Responsabilidade em     ���
���          � Duplicidade para a Transferencia                           ���
�������������������������������������������������������������������������͹��
���Sintaxe	 �QAX010Lib(aTpPen,aPenDoc,cFilAtu,cMatAtu,cDepAtu,			  ���
���	    	 �			nItem3,nItem5)                                    ���
�������������������������������������������������������������������������͹��
���Parametro �aTpPen - Array com o Tipos de Pendencia e Usuario que Recebe���
���          �aPenDoc- Array com o Documentos sinconizadro com aTpPen     ���
���          �cFilAtu- Filial do Usuario Transferido                      ���
���          �cMatAtu- Matricula do Usuario Transferido      			  ��� 
���          �cDepAtu- Departamento do Usuario Transferido                ���
���          �nItem3 - Intem de Transferencia de Filial/Depto  			  ���
���          �nItem5 - Tipo de Transferencia                   			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function QAX010Lib(aTpPen,aPenDoc,cFilAtu,cMatAtu,cDepAtu,nItem3,nItem5,nItem2)
	Local aArea  := GetArea()
	Local aAreaQD0:= QD0->(GetArea())
	Local cQuery := ""
	Local nI	 := 0
	Local nA	 := 0
	Local nU	 := 0
	Local nPosA	 := 0
	Local cDepto := ""
	Local aDocDup:= {}
	Local lRet   := .T.
	Local cUsrFil:= ""
	Local cUsrMat:= ""

	For nA := 1 to 6 //Todos os Tipos de Pendencia ate Distribuicao aTpPen
		If  aTpPen[nA,1] == .F. .Or. aTpPen[nA,2] == .F.
			Loop
		Endif

		nPosA := aScan(aPenDoc, { |x| Left(x[1],1) == aTpPen[nA,4] } )
		nPosA := If(nPosA == 0,Len(aPenDoc),nPosA)

		For nU := nPosA to Len(aPenDoc)
			If Left(aPenDoc[nU,1],1) <> aTpPen[nA,4]
				Exit
			Endif

			If nItem3 == 2

				If (aPenDoc[nU,4]) == .F. .Or. ;
						( Empty(aTpPen[nA,5]) .And. Empty(aPenDoc[nU,6]) .And. nItem5 <> 4)
					Loop
				Endif

			Endif

			IF !Empty(aTpPen[nA,5]) // Pendencias
				cUsrFil:= SUBS(aTpPen[nA,5],1,FWSizeFilial())
				cUsrMat:= SUBS(aTpPen[nA,5],FWSizeFilial()+1)
			Endif

			IF !Empty(aPenDoc[nU,6]) // Por Documento
				cUsrFil:= SUBS(aPenDoc[nU,6],1,FWSizeFilial())
				cUsrMat:= SUBS(aPenDoc[nU,6],FWSizeFilial()+1)
			Endif

			IF nItem2 == 1 //"Todas Pendencias"
				//��������������������������������������������������������Ŀ
				//�Transferencias do Usuario para ele MESMO para atender a �
				//�	 Usuario transferido  pelo SIGAGPE - Legenda Azul -    �
				//����������������������������������������������������������
				IF cFilAtu==cUsrFil .And. cMatAtu==cUsrMat
					Loop
				Endif
			Endif

			cDepto:=Posicione("QAA",1,cUsrFil+cUsrMat,"QAA_CC")

			cQuery := " SELECT R_E_C_N_O_ FROM "+ RetSqlName("QD0")+" QD0 WHERE QD0.QD0_FILIAL = '"+aPenDoc[nU,8]+"'"
			cQuery += " AND QD0.QD0_DOCTO = '"+aPendoc[nU,2]+"' AND QD0.QD0_RV = '"+aPendoc[nU,3]+"' AND QD0.QD0_FLAG <> 'I'"
			cQuery += " AND QD0.QD0_AUT = '"+Left(aPenDoc[nU,1],1) +"'"
			cQuery += " AND QD0.QD0_FILMAT = '"+cFilAtu+"' AND QD0.QD0_MAT = '"+cMatAtu+"'"
			cQuery += " AND QD0.D_E_L_E_T_ <> '*'"

			cQuery += " AND EXISTS(SELECT R_E_C_N_O_ FROM "+ RetSqlName("QD0")+" QD0 WHERE QD0.QD0_FILIAL = '"+aPenDoc[nU,8]+"'"
			cQuery += " AND QD0.QD0_DOCTO = '"+aPendoc[nU,2]+"' AND QD0.QD0_RV = '"+aPendoc[nU,3]+"' AND QD0.QD0_FLAG <> 'I'"
			cQuery += " AND QD0.QD0_AUT = '"+Left(aPenDoc[nU,1],1) +"'"
			cQuery += " AND QD0.QD0_FILMAT = '"+cUsrFil+"' AND QD0.QD0_MAT = '"+cUsrMat+"'"
			cQuery += " AND QD0.D_E_L_E_T_ <> '*')"

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QD0TRB",.T.,.T.)

			QD0TRB->(DBGotop())
			WHILE QD0TRB->(!Eof())
				IF ASCAN(aDocDup,{|X| X[1]==aPendoc[nU,2] .AND. X[2]==aPendoc[nU,3] .AND. X[3]==aPendoc[nU,1] .AND. X[4]+X[5]==cUsrFil+cUsrMat })==0
					AADD(aDocDup,{aPendoc[nU,2],aPendoc[nU,3],aPendoc[nU,1],cUsrFil,cUsrMat,QA_NUSR(cUsrFil,cUsrMat)} )
				Endif
				QD0TRB->(DbSKIP())
			Enddo

			DBCLOSEAREA()
			DbSelectArea("QD0")
		Next
	Next

	QD0->(RestArea(aAreaQD0))
	ResTArea(aArea)

	IF Len(aDocDup) > 0
		lRet:=.F.
		QAX10AuDlg(aDocDup,cFilAtu,cMatAtu,"1")
	Endif

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QAX10AuDlg�Autor  �Telso Carneiro      � Data �  13/05/2004 ���
�������������������������������������������������������������������������͹��
���Desc.     � Tela de Apresentaca das Inconsistencias da Ausencia Temp.  ���
�������������������������������������������������������������������������͹��
���Sintaxe	 �QAX10AuDlg(aDocDup,cFilAtu,cMatAtu)						  ���
�������������������������������������������������������������������������͹��
���Parametro �aDocDup- Array com o Doctos Inconsistentes                  ���
���          �cFilAtu- Filial do Usuario Transferido                      ���
���          �cMatAtu- Matricula do Usuario Transferido      			  ��� 
�������������������������������������������������������������������������͹��
���Uso       � QAX010Lib (Validacao da Tela)                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function QAX10AuDlg(aDocDup,cFilAtu,cMatAtu,cTpMens)

	Local oDlg,oList3,oFilAtu,oMatAtu,oDesAtu
	Local cDesAtu	:=QA_NUSR(cFilAtu,cMatAtu)
	Default cTpMens := "1"

	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0117) FROM 000,000 TO 385,770 OF oMainWnd PIXEL //"Inconsistencia"

	@ 005,003 TO 028,165 LABEL OemToAnsi(STR0118) OF oDlg PIXEL  //"Filial/Usuario"
	@ 012,006 MSGET oFilAtu VAR cFilAtu SIZE 038,008 OF oDlg PIXEL WHEN .F.
	@ 012,050 MSGET oMatAtu VAR cMatAtu SIZE 044,008 OF oDlg PIXEL	WHEN .F.
	@ 012,120 MSGET oDesAtu VAR cDesAtu SIZE 85,008 OF oDlg PIXEL WHEN .f.

	@ 005,218 SAY OemToAnsi(STR0119) SIZE 200,007 OF oDlg COLOR CLR_HRED,CLR_WHITE PIXEL	 //"Documentos com Inconsistencia na Transferencia "
	IF cTpMens =="1"
		@ 015,218 SAY OemToAnsi(STR0120) SIZE 200,007 OF oDlg COLOR CLR_HRED,CLR_WHITE  PIXEL	  //"entre Usuarios de mesma Responsabilidade. "
	Else
		@ 015,218 SAY OemToAnsi(STR0142) SIZE 200,007 OF oDlg COLOR CLR_HRED,CLR_WHITE  PIXEL	   //"devido ao cadastro, Responsaveis no Tipo de Documento."
	Endif

	@ 030,003 LISTBOX oList3 FIELDS HEADER Alltrim(TitSx3("QD0_DOCTO")[1]),;
		Alltrim(TitSx3("QD0_RV")[1]),;
		Alltrim(TitSx3("QD1_TPPEND")[1]),;
		Alltrim(TitSx3("QD0_FILMAT")[1]),;
		Alltrim(TitSx3("QD0_MAT")[1]),;
		Alltrim(TitSx3("QD0_NOME")[1]) SIZE 308,140 PIXEL

	oList3:SetArray(aDocDup)
	oList3:bLine := { || { aDocDup[oList3:nAt,1],aDocDup[oList3:nAt,2],aDocDup[oList3:nAt,3],aDocDup[oList3:nAt,4],aDocDup[oList3:nAt,5],aDocDup[oList3:nAt,6]}}
	oList3:GoTop()
	oList3:Refresh()

	DEFINE SBUTTON FROM 175,280 TYPE 6 ACTION QAXR10(aDocDup,cFilAtu,cMatAtu,cDepAtu) ENABLE OF oDlg PIXEL
	DEFINE SBUTTON FROM 175,310 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QADR045  � Autor � Leandro S. Sabino     � Data � 17/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao de Emails Associados   			                  ���
�������������������������������������������������������������������������Ĵ��
���Obs:      � (Versao Relatorio Personalizavel) 		                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADR045	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Function QAXR10(aDocDup,cFilAtu,cMatAtu,cDepAtu)
Local oReport

	If TRepInUse()
    oReport := ReportDef(aDocDup,cFilAtu,cMatAtu,cDepAtu)
    oReport:PrintDialog()
	Else
	Return QAXR10R3(aDocDup,cFilAtu,cMatAtu,cDepAtu) //Executa vers�o anterior do fonte
	EndIf


Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ReportDef()   � Autor � Leandro Sabino   � Data � 17.05.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Montar a secao				                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()				                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADR045                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef(aDocDup,cFilAtu,cMatAtu,cDepAtu)
Local oReport 
Local oSection1 
Local oSection2 
Local oCell
Local oTotaliz

oReport   := TReport():New("QAXR080" ,OemToAnsi(STR0122),,{|oReport| RF010Imp(oReport,aDocDup,cFilAtu,cMatAtu,cDepAtu)},OemToAnsi(STR0119)+OemToAnsi(STR0120))
//"Docs.Inconsistencia Transferencia"##"Documentos com Inconsistencia na Transferencia "##"entre Usuarios de mesma Responsabilidade. "

oSection1 := TRSection():New(oReport,OemToAnsi(STR0146),{}) // "Usuario"
oSection1:SetTotalInLine(.F.)
TRCell():New(oSection1,OemToAnsi(STR0145),"   ","Filial" ,,20,/*lPixel*/,/*{||}*/)//"Filial"
TRCell():New(oSection1,OemToAnsi(STR0146),"   ","Usuario",,40,/*lPixel*/,/*{||}*/)//"Usuario"

oSection2 := TRSection():New(oSection1,OemToAnsi(STR0122),{}) //"Docs.Inconsistencia Transferencia"
TRCell():New(oSection2,OemToAnsi(STR0147)  ,"   ",OemToAnsi(STR0147)	,,16,/*lPixel*/,/*{||}*/)//"Doc."
TRCell():New(oSection2,OemToAnsi(STR0148)	,"   ",OemToAnsi(STR0148)	,,3 ,/*lPixel*/,/*{||}*/)//"Revisao"
TRCell():New(oSection2,	OemToAnsi(STR0149)	,"   ",OemToAnsi(STR0149)	,,20,/*lPixel*/,/*{||}*/)//"Tipo"
TRCell():New(oSection2,OemToAnsi(STR0150)	,"   ",OemToAnsi(STR0150)	,,3 ,/*lPixel*/,/*{||}*/)//"Pendencia"
TRCell():New(oSection2,OemToAnsi(STR0151)	,"   ",OemToAnsi(STR0151)	,,6 ,/*lPixel*/,/*{||}*/)//"Nome"
TRCell():New(oSection2,OemToAnsi(STR0152)	,"   ",OemToAnsi(STR0152)	,,40,/*lPixel*/,/*{||}*/)//"Usuario"

Return oReport


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � RF010Imp      � Autor � Leandro Sabino   � Data � 17.05.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Imprimir os campos do relatorio                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RF010Imp(ExpO1)   	     	                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� oReport- Objeto oPrint                                     ���
���          | aDocDup- Array com o Doctos Inconsistentes                 |��
���          � cFilAtu- Filial do Usuario Transferido                     |��
���          � cMatAtu- Matricula do Usuario Transferido      			  |��
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADR045                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function RF010Imp(oReport,aDocDup,cFilAtu,cMatAtu,cDepAtu)
Local oSection1   := oReport:Section(1)
Local oSection2   := oReport:Section(1):Section(1)
Local nI          := 0

oSection1:Init()

oSection1:Cell(OemToAnsi(STR0145)):SetValue(cFilAtu)//"Filial"
oSection1:Cell(OemToAnsi(STR0146)):SetValue(cMatAtu+" "+QA_NUSR(cFilAtu,cMatAtu))//"Usuario"
oSection1:PrintLine()

oSection2:Init()
         
	For nI:= 1 To Len(aDocDup)
	oSection2:Cell(OemToAnsi(STR0147)):SetValue(aDocDup[nI,1])//"Doc."
	oSection2:Cell(OemToAnsi(STR0148)):SetValue(aDocDup[nI,2])//"Revisao"
	oSection2:Cell(OemToAnsi(STR0149)):SetValue(aDocDup[nI,3])//"Tipo"
	oSection2:Cell(OemToAnsi(STR0150)):SetValue(aDocDup[nI,4])//"Pendencia"
	oSection2:Cell(OemToAnsi(STR0151)):SetValue(aDocDup[nI,5])//"Nome"
	oSection2:Cell(OemToAnsi(STR0152)):SetValue(aDocDup[nI,6])//"Usuario"
	oSection2:PrintLine()
	Next

oSection1:Finish()
oSection2:Finish()

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QAXR10R3 �Autor  �Telso Carneiro      � Data �  08/06/2004 ���
�������������������������������������������������������������������������͹��
���Desc.     �Relatorio de Doctos Inconsistencia na Transferencia         ���
�������������������������������������������������������������������������͹��
���Sintaxe	 �QAXR10R3(aDocDup,cFilAtu,cMatAtu,cDepAtu)				  ���
�������������������������������������������������������������������������͹��
���Parametro �aDocDup- Array com o Doctos Inconsistentes                  ���
���          �cFilAtu- Filial do Usuario Transferido                      ���
���          �cMatAtu- Matricula do Usuario Transferido      			  ��� 
�������������������������������������������������������������������������͹��
���Uso       � QAX10AuDlg (Tela de Apresentacao da Inconsistencia)        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function QAXR10R3(aDocDup,cFilAtu,cMatAtu,cDepAtu)

	Local cDesc1       := STR0121 //"Este programa tem como objetivo imprimir relatorio "
	Local cDesc2       := STR0119 //"Documentos com Inconsistencia na Transferencia "
	Local cDesc3       := STR0120 //"entre Usuarios de mesma Responsabilidade. "
	Local cPict        := ""
	Local titulo       := STR0122 //"Docs.Inconsistencia Transferencia"
	Local nLin         := 80

	Local Cabec1       := OemToAnsi(STR0118) //"Filial/Usuario"
	Local Cabec2       := cFilAtu +" "+cMatAtu+" "+QA_NUSR(cFilAtu,cMatAtu)
	Local imprime      := .T.
	Local aOrd 		   := {}

	Private limite     := 80
	Private tamanho    := "P"
	Private nomeprog   := "QAXR080"
	Private nTipo      := 18
	Private aReturn    := { STR0123, 1, STR0124, 2, 2, 1, "", 1}  //"Zebrado"###"Administracao"
	Private nLastKey   := 0
	Private m_pag      := 01
	Private wnrel      := "QAXR080"
	Private cString    := "QAA"

	wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

//���������������������������������������������������������������������Ŀ
//� Processamento. RPTSTATUS monta janela com a regua de processamento. �
//�����������������������������������������������������������������������

	RptStatus({|| QAX10AuRel(Cabec1,Cabec2,Titulo,nLin,aDocDup) },Titulo)
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �QAX10AuRel� Autor � Telso Carneiro     � Data �  13/05/04   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � QAXR010                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function QAX10AuRel(Cabec1,Cabec2,Titulo,nLin,aDocDup)

Local nI
Local cCabec3 := (TitSx3("QDH_DOCTO")[1])+" "+ALLTRIM(TitSx3("QDH_RV")[1])+" "+(TitSx3("QD1_TPPEND")[1])+" "+(TitSx3("QD0_NOME")[1])
Local cbtxt    := SPACE(10)
Local cbcont   := 0

SetRegua(len(aDocDup))

	For nI:=1 TO Len(aDocDup)
   //���������������������������������������������������������������������Ŀ
   //� Verifica o cancelamento pelo usuario...                             �
   //�����������������������������������������������������������������������
		If lAbortPrint
      @nLin,00 PSAY STR0125 //"*** CANCELADO PELO OPERADOR ***"
      Exit
		Endif
   IncRegua()
   //���������������������������������������������������������������������Ŀ
   //� Impressao do cabecalho do relatorio. . .                            �
   //�����������������������������������������������������������������������
		If nLin > 60
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)                   
      nLin := 9
      @nLin,00 PSAY cCabec3                  
      nLin++                                 
   	  @nLin,000 Psay __PrtThinLine() 
      nLin++                                 
		Endif
   @nLin,00 PSAY aDocDup[nI,1]+" "+aDocDup[nI,2]+" "+aDocDup[nI,3]+;
   					SPACE(6)+aDocDup[nI,4]+" "+aDocDup[nI,5]+"-"+aDocDup[nI,6]
   nLin++                                           

	Next

	If nLin != 80
	Roda(cbcont,cbtxt,tamanho)
	EndIf


SET DEVICE TO SCREEN

	If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
	Endif

MS_FLUSH()

Return

/*
���������������������������������������������������������������������������Ŀ
�Fun��o    �fAbrEmpresa	  � Autor �Wilson de Godoy        � Data �03/01/2001�
���������������������������������������������������������������������������Ĵ
�Descri��o �Abre o Arquivo da Outra Empresa                        			�
���������������������������������������������������������������������������Ĵ
�Parametros� cAlias - Alias do Arquivo a Ser Aberto							�
�          � nOrdem - Ordem do Indice              							�
�����������������������������������������������������������������������������*/
Static Function fAbrEmpresa(cAlias,nOrdem,cEmpAte,cFilAte,cModo)
Local lRet          

	IF ( lRet := MyEmpOpenFile("QUA"+cAlias,cAlias,nOrdem,.t.,cEmpAte,@cModo) )
	dbSelectArea( "QUA"+cAlias )
	Else
	MsgAlert( OemToAnsi( STR0126+" "+ cAlias )  ) //"Nao foi possivel encontrar o arquivo"
	EndIF
 
Return( lRet )

/*
���������������������������������������������������������������������������Ŀ
�Fun��o    �fFecEmpresa	  � Autor �Wilson de Godoy        � Data �03/01/2001�
���������������������������������������������������������������������������Ĵ
�Descri��o �Fecha o Arquivo da Outra Empresa                        		�
���������������������������������������������������������������������������Ĵ
�Parametros� cAlias - Alias do Arquivo a Ser Fechado						�
�����������������������������������������������������������������������������*/
Static Function fFecEmpresa( cAlias )

	IF Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
	EndIF

Return( .T. )

/*
���������������������������������������������������������������������������Ŀ
�Fun��o    �MyEmpOpenFile � Autor �Wilson de Godoy        � Data �03/01/2001�
���������������������������������������������������������������������������Ĵ
�Descri��o �Abre Arquivo de Outra Empresa                         			�
���������������������������������������������������������������������������Ĵ
�Parametros�x1 - Alias com o Qual o Arquivo Sera Aberto                  	�
�          �x2 - Alias do Arquivo Para Pesquisa e Comparacao                �
�          �x3 - Ordem do Arquivo a Ser Aberto                              �
�          �x4 - .T. Abre e .F. Fecha                                       �
�          �x5 - Empresa                                                    �
�          �x6 - Modo de Acesso (Passar por Referencia)                     �
�����������������������������������������������������������������������������*/
Static Function MyEmpOpenFile(x1,x2,x3,x4,x5,x6)
Local cSavE := cEmpAnt, cSavF := cFilAnt, xRet
cEmpAnt := __cEmpAnt
cFilAnt := __cFilAnt
xRet	:= EmpOpenFile(@x1,@x2,@x3,@x4,@x5,@x6)
cEmpAnt := cSavE
cFilAnt := cSavF

Return( xRet )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QAX010PUS �Autor  �Telso Carneiro      � Data � 22/09/2004  ���
�������������������������������������������������������������������������͹��
���Desc.     �Tela de Pesquisa do Usuario para definir a Filial/Codigo    ���
���          �												              ���
�������������������������������������������������������������������������͹��
���Uso       �QAX010Atu()                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function QAX010PUS()

	Local lRet:= .T.
	Local oDlgU
	Local oFilUsr
	Local cFilUsr := cCcFilial
	Local oCodUsr
	Local oDesUsr
	Local cCodUsr:= Space(TamSx3("QAA_MAT" )[1])
	Local cDesUsr:= Space(TamSx3("QAA_NOME")[1])


	DEFINE MSDIALOG oDlgU FROM 000,000 TO 160,490 TITLE OemToAnsi(STR0001) PIXEL //"Pesquisar"

	@ 020,003 TO 065,240 LABEL OemToAnsi(STR0021) OF oDlgU PIXEL  //"Usuario"

	@ 030,006 SAY OemToAnsi(STR0033) SIZE 010,008 OF oDlgU PIXEL  //"Fil"
	@ 040,006 MSGET oFilUsr VAR cCcFilial PICTURE PesqPict("QDE","QDE_FILIAL") F3 "SM0" SIZE 050,008 OF oDlgU PIXEL ;
		VALID QA_CHKFIL(cCcFilial,@cFilMat)

	@ 030,070 SAY OemToAnsi(STR0082) SIZE 044,008 OF oDlgU PIXEL  //"C�digo"
	@ 040,070 MSGET oCodUsr VAR cCodUsr PICTURE '@!' F3 "QDE" SIZE 044,008 OF oDlgU PIXEL ;
		VALID (cDesUsr:= QA_NUSR(cCcFilial,cCodUsr,.T.),	oDesUsr:Refresh(),QA_CHKMAT(cCcFilial,cCodUsr))

	@ 030,134 SAY OemToAnsi(STR0083) SIZE 85,008 OF oDlgU PIXEL  //"Nome"
	@ 040,134 MSGET oDesUsr VAR cDesUsr SIZE 85,008 OF oDlgU PIXEL WHEN .f.

	ACTIVATE MSDIALOG oDlgU CENTERED ON INIT EnchoiceBar(oDlgU,{|| lRet:=.T., oDlgU:End()},{|| lRet:=.F., oDlgU:End()} )

	cCcFilial := cFilUsr

Return(lRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QA_SitAuDP�Autor  �Telso Carneiro      � Data �  11/05/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica a Existencia de Ausencia Temporaria para o Usuario���
���          � DE e PARA                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function QA_SitAuDP(cMatFil,cMatCod,cTpend)

	Local lRet	 := .F.
	Local aArea	 := GetArea()
	Local cQuery := ""

//������������������������������������������������������Ŀ
//�Verifica se existe lancamento de Ausencia Temporaria  �
//��������������������������������������������������������
	cQuery := " SELECT QAF.QAF_TPPEND "
	cQuery += " FROM " + RetSqlName("QAE")+" QAE ,"+ RetSqlName("QAF")+" QAF "
	cQuery += " WHERE QAE.QAE_FILIAL = '"+xFilial("QAE")+"'
	cQuery += " AND QAE.QAE_STATUS = '1' AND QAE.QAE_MODULO = "+AllTrim(Str(nModulo))
	cQuery += " AND QAE.QAE_FILIAL = QAF.QAF_FILIAL AND QAF.QAF_FLAG <> 'I'"
	cQuery += " AND QAE.QAE_ANO = QAF.QAF_ANO AND QAE.QAE_NUMERO = QAF.QAF_NUMERO "
	cQuery += " AND (QAE.QAE_FILMAT = '" + cMatFil +"' AND QAE.QAE_MAT = '" + cMatCod +"')"
	cQuery += " AND QAE.D_E_L_E_T_ <> '*' AND QAF.D_E_L_E_T_ <> '*'"
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QAETRB",.T.,.T.)

	QAETRB->(DBGotop())
	WHILE QAETRB->(!Eof())
		IF SUBS(QAETRB->QAF_TPPEND,1,1)==cTpend
			lRet:= .T.
			Exit
		Endif
		QAETRB->(DbSkip())
	EndDO

	DBCLOSEAREA()

	RestARea(aArea)

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QAX010FIM �Autor  �Telso Carneiro      � Data �  14/12/2004 ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica e Libera a Transfer�ncia                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � QAXA010()                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function QAX010FIM(nItem2,nItem3,nItem4,nItem5,aPenDoc,aTpPen,cCcFilial,cCcPara,cNDepto,cCcMatr,cFilAtu,cMatAtu,cDepAtu,oDlgFolder,lChk03,aAvisos)
Local aCof     := {}
Local cCof     := ""
Local cFilPara := Space(FWSizeFilial())
Local cMatPara := ""
Local cTipo    := ""
Local lChk     := lChk03
Local lRet     := .F.
LocaL Na       := 1
Local nI       := 0
Local nPosA    := 0
Local Nu       := 1
Local oChk     := Nil
Local oCof     := Nil
Local oDlgC    := Nil
Local oFnt     := Nil
Local oItV     := Nil
Local oItVi    := Nil

	DEFINE FONT oFnt NAME "Courier New" BOLD SIZE 6,30

	CursorWait()
	//�������������������������������������������������������Ŀ
	//�Valida a transferencia de lactos em fase de Elaboracao �
	//���������������������������������������������������������
	lRet:= FQAXA010Ttf(nItem3,nItem5,aPenDoc,aTpPen,cCcFilial)

	IF !lRet
		CursorArrow()
		Return(IF(lRet,1,2))
	Endif

	//�������������������������������������������������Ŀ
	//�Valida a transferencia de usuario entre filiais  �
	//���������������������������������������������������
	lRet:= FQAXA010ICE(cCcFilial)

	IF !lRet
		CursorArrow()
		Return(IF(lRet,1,2))
	Endif

//���������������������������������������������������������Ŀ
//�Verifica se existe o Centro de Custo digitado/selecionado�
//�����������������������������������������������������������

	IF nItem3 == 1
		lRet:= FQAXA010QAD(cCcFilial,cCcPara,@cNDepto,cCcMatr)
		IF !lRet
			CursorArrow()
			Return(IF(lRet,1,2))
		Endif
		//�����������������������������������������������������������Ŀ
		//�Verifica a Existencia de Ausencia Temporia para o Usuario  �
		//�Destino nos Tipos Pendencias ate a Distribuicao            �
		//�������������������������������������������������������������
		lRet:= QAX10VldAu(cCcFilial,cCcMatr,aTpPen)
		IF !lRet
			CursorArrow()
			Return(IF(lRet,1,2))
		Endif
	Endif

	//������������������������������������������������������������Ŀ
	//� Verifica a Existencia da matriz de Responsabilidade em     �
	//� Duplicidade para a Transferencia                           �
	//��������������������������������������������������������������
	lRet:= QAX010Lib(aTpPen,aPenDoc,cFilAtu,cMatAtu,cDepAtu,nItem3,nItem5,nItem2)
	IF !lRet
		CursorArrow()
		Return(IF(lRet,1,2))
	Endif

	//������������������������������������������������������������Ŀ
	//� Verifica a Existencia da matriz de Responsabilidade em     �
	//� Discordancia entre depto e Cargo                           �
	//��������������������������������������������������������������
	lRet:= QAX010QDD(aTpPen,aPenDoc,cFilAtu,cMatAtu,cDepAtu,nItem3,nItem5,nItem2,cCcPara)
	IF !lRet
		CursorArrow()
		Return(IF(lRet,1,2))
	Endif

	//����������������������������������������������������������������Ŀ
	//� Verifica os Avisos para evitar inconsistencia na Transferencia �
	//������������������������������������������������������������������
	lRet:=QAX010Vav(aAvisos,nItem2,nItem3,nItem5,aPenDoc,aTpPen)
	IF !lRet
		CursorArrow()
		Return(IF(lRet,1,2))
	Endif

	For nA := 1 to LeN(aTpPen) //Todos os Tipos de Pendencias
		If  aTpPen[nA,1] == .F. .Or. aTpPen[nA,2] == .F.
			Loop
		Endif

		nPosA := aScan(aPenDoc, { |x| Left(x[1],1) == aTpPen[nA,4] } )
		nPosA := If(nPosA == 0,Len(aPenDoc),nPosA)

		For nU := nPosA to Len(aPenDoc)
			If Left(aPenDoc[nU,1],1) <> aTpPen[nA,4]
				Exit
			Endif

			If nItem3 == 2
				If (aPenDoc[nU,4]) == .F. .Or. ;
						( Empty(aTpPen[nA,5]) .And. Empty(aPenDoc[nU,6]) .And. nItem5 <> 4)
					Loop
				Endif
			Endif

			If (aPenDoc[nU,9]) == 0
				Loop
			EndiF

			cTipo		:= aTpPen[nA,3]
			cFilPara	:= Space(FWSizeFilial())
			cMatPara	:= ""
			cDepto		:= ""

			IF !Empty(aTpPen[nA,5]) // Pendencias
				cFilPara:= SUBS(aTpPen[nA,5],1,FWSizeFilial())
				cMatPara:= SUBS(aTpPen[nA,5],FWSizeFilial()+1)
				cDepto	:= Posicione("QAA",1,cFilPara+cMatPara,"QAA_CC")
			Endif

			IF !Empty(aPenDoc[nU,6]) // Por Documento
				cFilPara:= SUBS(aPenDoc[nU,6],1,FWSizeFilial())
				cMatPara:= SUBS(aPenDoc[nU,6],FWSizeFilial()+1)
				cDepto	:= Posicione("QAA",1,cFilPara+cMatPara,"QAA_CC")
			Endif

			If nItem3 == 1
				cFilPara:=cCcFilial
				cMatPara:=cCcMatr
				cDepto	:=cCcPara
			Endif

			If nItem4 == 1 .Or. ( nItem4 == 2 .And. aPenDoc[nU,5] == "B" ) .Or. ;          //"1=Ambas 2=Baixadas 3=Pendentes"
				( nItem4 == 3 .And. aPenDoc[nU,5] == "P" )
				If aScan(aCof,{|x| X[1]+X[2]+X[3]+X[4] == cTipo+aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]}) == 0
					AADD(aCof,{cTipo ,; //Tipo de Pendencia
					aPenDoc[nU,8],; //Filial
					aPenDoc[nU,2],; // Codigo Docto
					aPenDoc[nU,3],; // Revisao
					cFilPara +"-" +cMatPara+" "+QA_NUSR(cFilPara,cMatPara)+OemToAnsi(STR0085)+": "+cDepto}) //PARA Depto
				EndIf
			Endif

		Next
	Next

	If Len(aCof)  > 0
		DEFINE MSDIALOG oDlgC TITLE OemToAnsi(STR0132)+OemToAnsi(STR0020)+" - "+OemToAnsi(STR0021)+": "+AllTrim(cMatAtu)+" - "+AllTrim(cNomAtu)+" "+OemToAnsi(STR0085)+": "+cDepATu FROM 9,0 TO 40,100 //"Confirma��o da "###"Transferencia de Usuarios"###"Usuario"###"Depto"

		@ 040,334 TO 135,394 LABEL  OemToAnsi(STR0060) OF oDlgC PIXEL //Opcoes

		//������������������������������������Ŀ
		//�Pendencias						   �
		//��������������������������������������
		@ 048,336 SAY OemToAnsi(STR0066) SIZE 050,010 OF oDlgC PIXEL
		@ 057,338 RADIO oItV VAR nItem4  SIZE 050,010 OF oDlgC PIXEL WHEN .F. ;
			ITEMS OemToAnsi( STR0067 ),; //"Ambas"
		OemToAnsi( STR0068 ),; //"Baixadas"
		OemToAnsi( STR0069 )   //"Pendentes"

		//������������������������������������Ŀ
		//�Transferir						   |
		//��������������������������������������
		@ 087,336 SAY OemToAnsi(STR0046) SIZE 050,010 OF oDlgC PIXEL
		@ 096,338 RADIO oItVi VAR nItem5  SIZE 050,010 OF oDlgC PIXEL  WHEN .F. ;
			ITEMS OemToAnsi( STR0048 ),;  //"Transf. e Ativar"
		OemToAnsi( STR0043 ),;  //"Transf. s/Baixar"
		OemToAnsi( STR0044 ),;  //"Transf. e Baixar"
		OemToAnsi( STR0045 )    //"Baixar. s/Transf."

		@ 146,338 CHECKBOX oChk VAR lChk SIZE 053,008 FONT oFnt OF oDlgC PIXEL  ;
			PROMPT OemToAnsi(STR0041) WHEN .F. //"Por Documento"

		@015, 002 LISTBOX oCof VAR cCof FIELDS HEADER ;
			OemToAnsi(STR0078), ; //"Tipos de Pendencia"
		OemToAnsi(STR0033), ; //"Fil"
		OemToAnsi(STR0086), ; //"No.Docto"
		OemToAnsi(STR0087), ; //"Rv"
		OemToAnsi(STR0023) ;  //" Transferir para "
		SIZE 330,210 OF oDlgC PIXEL

		oCof:SetArray(aCof)
		oCof:bLine := {|| aCof[oCof:nAt] }

		CursorArrow()
		ACTIVATE MSDIALOG oDlgC CENTERED ON INIT EnchoiceBar(oDlgC,{|| lRet:=.T.,oDlgC:End()},{|| lRet:= .F.,oDlgC:End()} )

		IF lRet
			lRet:=QA010DlgJus(oDlgFolder)
		Endif
	Else
		If nItem3 == 1 // Caso a Transferencia seja  por Centro de Custo
			CursorArrow()
			MsgInfo(OemToAnsi(STR0143),OemToAnsi(STR0127))  //"Nao ha Lancamentos a transferir! Usuario sera transferido de Departamento, favor verificar as pendencias deste usuario nos outros ambientes da Qualidade (Ex: Metrologia, Inspecao de Processos, etc ...)"###"Atencao"
			lRet:=.T.
		Else
			CursorArrow()
			MsgAlert(OemToAnsi(STR0089),OemToAnsi(STR0127))  //"N�o ha Lan�amentos"###"Atencao"
			lRet:=.F.
		EndIf
	Endif

Return(IF(lRet,1,2))

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QAX10SDoc �Autor  �Cicero Cruz         � Data �  18/06/2005 ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica se a Distribui��o pode ser executada para o       ���
���          � Usuario Destino com Pendencias de Distribuicao             ���
�������������������������������������������������������������������������͹��
���Uso       � QAXA010()                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function QAX10SDoc(cFilDest,cMatDest,cDepDest,cFilDe,cMatDe,cDepde,aDoctos,oDoctos,lChk03)
	Local aArea		:= GetArea()
	Local lRet 		:= .T.
	Local nI 		:= 0
	Local MsgConsist:= ""
	Local aAreaQD1  := QD1->(GetArea())

	Default lChk03 	:= .F.
	Default oDoctos := nil

	QD1->(dbSetOrder(7))

	If !lChk03
		For nI:=1 to Len(aDoctos)
			If aDoctos[nI][1] == .T.
				If QD1->(DBSeek(aDoctos[nI][7]+aDoctos[nI][3]+aDoctos[nI][4]+cDepDest+cFilDest+cMatDest+"I  "+"P"))    //Filial+Documento+Revisao+Departamento+Filial+Matricula+Tipo Pendencia+pendente
					lRet := .F.
					MsgConsist := OemToAnsi(STR0129) + aDoctos[nI][3] +"/"+ aDoctos[nI][4] //"A pendencia de Distribuicao do Documento "
					MsgConsist += OemToAnsi(STR0131) //" nao pode ser transferida, pois o usuario destino ja possui em esta pendencia de distribuicao!"
					Exit
				EndIf
			EndIf
		Next
	Else
		If aDoctos[oDoctos:nAt][1] == .T.
			If QD1->(DBSeek(aDoctos[oDoctos:nAt][7]+aDoctos[oDoctos:nAt][3]+aDoctos[oDoctos:nAt][4]+cDepDest+cFilDest+cMatDest+"I  "+"P"))    //Filial+Documento+Revisao+Departamento+Filial+Matricula+Tipo Pendencia+pendente
				lRet := .F.
				MsgConsist := OemToAnsi(STR0129) + aDoctos[oDoctos:nAt][3] +"/"+ aDoctos[oDoctos:nAt][4]  //"A pendencia de Distribuicao do Documento " ###"/"
				MsgConsist += OemToAnsi(STR0131)    //" nao pode ser transferida, pois o usuario destino ja possui esta pendencia de distribuicao!"
			EndIf
		EndIf
	EndIf

	IF !lRet
		MsgAlert(MsgConsist)
	Endif

	QD1->(RestArea(aAreaQD1))
	RestArea(aArea)

Return lRet



/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FQAXA010Avs� Autor � Telso Carneiro      � Data �18/08/2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Carrega os Avisos                           				  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �FQAXA010Avs(ExpO1,ExpA1,ExpA2,ExpA3,ExpL2)				  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 - Objeto do ListBox de Doctos                        ���
���          � ExpA1 - Array contendo os Lancamentos dos Documentos       ���
���          � ExpA2 - Array contendo os Lancamentos Avisos    			  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function FQAXA010Avs(lPosAv,oDoctos,aDoctos,oAvisos,aAvisos,aAviAux,nItem4)
Local nY		:= 1
Local cChave	:= If(nItem4==1,"",If(nItem4==2,"B","P"))

aAviAux:={}

	IF lPosAv .AND. Len(aDoctos) > 0
		For nY:= 1 to Len(aAvisos)
			IF aAvisos[nY,1]==aDoctos[oDoctos:nAt,7] .and. aAvisos[nY,2]==aDoctos[oDoctos:nAt,3] .AND. aAvisos[nY,3]==aDoctos[oDoctos:nAt,4] .AND. IF(EMPTY(cChave),.T.,cChave == aAvisos[nY,4])
    	 	aAdd(aAviAux,aAvisos[nY])
			Endif
		Next
	Endif
	 
	IF Len(aAviAux) == 0
	aAviAux:={{ Space(TamSx3("QDS_FILIAL")[1]),Space(TamSx3("QDS_DOCTO")[1]),Space(TamSx3("QDS_RV")[1]),Space(TamSx3("QDS_PENDEN")[1]),Space(TamSx3("QDS_DTGERA")[1])+" "+Space(TamSx3("QDS_HRGERA")[1]), OemToAnsi(STR0089)}}	
	Else
	aAviAux := aSort(aAviAux,,,{ |x,y| x[5] + x[6] < y[5] + y[6] } )	
	Endif

   
	If oAvisos<>Nil
	oAvisos:nAt:=1
	oAvisos:SetArray(aAviAux)
	oAvisos:bLine:= bQDSLine
		IF !lPosAv
		oAvisos:Hide()		       
		Else
		oAvisos:Show()     
		Endif
	oAvisos:Refresh()    	
	Endif

Return


/*�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������Ŀ��
���Fun��o    � QAX010MsgA� Autor � Telso Carneiro               � Data � 19/08/05 ���
���������������������������������������������������������������������������������Ĵ��
���Descri��o � Carrega Mensagem do Aviso                                          ���
���������������������������������������������������������������������������������Ĵ��
���Sintaxe   � QAX010MsgA(ExpC1)                                                  ���
���������������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - Tipo de Aviso                                              ���
���������������������������������������������������������������������������������Ĵ��
��� Uso      � QAXA010                                                            ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/

Static Function QAX010MsgA(cTipoAviso)
Return QAXDescSX5("QH",cTipoAviso,cTipoAviso)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QAX010Vav �Autor  �Telso Carneiro      � Data �  29/08/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida a Transferencia dos Avisos   						  ���
���          �para evitar inconsistencia na Transferencia                 ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

STatic Function QAX010Vav(aAvisos,nItem2,nItem3,nItem5,aPenDoc,aTpPen)
	Local aTiAus     := {}
	Local cCodFun    := ""
	Local cCODTp     := ""
	Local cDepto     := ""
	Local cDist      := ""
	Local cMvQLIBLEI := GetMV( "MV_QLIBLEI" )
	Local cUsrFil    := ""
	Local cUsrMat    := ""
	Local lRet       := .T.
	Local nA         := 10 //Posicao dos Aviso no Array
	Local nOrdQD0    := QD0->(IndexOrd())
	Local nOrdQDA    := QDA->(IndexOrd())
	Local nOrdQDG    := QDG->(IndexOrd())
	Local nPosA      := 0
	Local nPosP      := 0
	Local nPosT      := 0
	Local nU         := 0
	Local nY         := 0

	If  aTpPen[nA,1] == .F. .Or. aTpPen[nA,2] == .F.
		Return(lRet)
	Endif

	nPosA := aScan(aPenDoc, { |x| Left(x[1],1) == aTpPen[nA,4] } )
	nPosA := If(nPosA == 0,Len(aPenDoc),nPosA)

	For nU := nPosA to Len(aPenDoc)
		If Left(aPenDoc[nU,1],1) <> aTpPen[nA,4]
			Exit
		Endif

		If nItem3 == 2

			If (aPenDoc[nU,4]) == .F. .Or. ;
					( Empty(aTpPen[nA,5]) .And. Empty(aPenDoc[nU,6]) .And. nItem5 <> 4)
				Loop
			Endif

		Endif

		IF !Empty(aTpPen[nA,5]) // Pendencias
			cUsrFil:= SUBS(aTpPen[nA,5],1,FWSizeFilial())
			cUsrMat:= SUBS(aTpPen[nA,5],FWSizeFilial()+1)
		Endif

		IF !Empty(aPenDoc[nU,6]) // Por Documento
			cUsrFil:= SUBS(aPenDoc[nU,6],1,FWSizeFilial())
			cUsrMat:= SUBS(aPenDoc[nU,6],FWSizeFilial()+1)
		Elseif Empty(cUsrFil) .and. Empty(cUsrMat)
			cUsrFil:=cFilMat
			cUsrMat:=cMatAtu
		Endif

		IF nItem2 == 1 //"Todas Pendencias"
			//��������������������������������������������������������Ŀ
			//�Transferencias do Usuario para ele MESMO para atender a �
			//�	 Usuario transferido  pelo SIGAGPE - Legenda Azul -    �
			//����������������������������������������������������������
			IF cFilAtu==cUsrFil .And. cMatAtu==cUsrMat
				Loop
			Endif
		Endif

		QAA->(DbSetOrder(1))
		QAA->(DBSeek(cUsrFil+cUsrMat))
		cDepto 	:= QAA->QAA_CC
		cCodFun	:= QAA->QAA_CODFUN
		cDist	:= QAA->QAA_DISTSN

		nI:=Ascan(aAvisos,{|x| x[1]+x[2]+x[3] == aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]})
		IF nI > 0
			IF aAvisos[nI,6] $ "QUE.REF.SAD.VEN"
				cCODTp:=POSICIONE("QDH",1,aAvisos[nI,1]+aAvisos[nI,2]+aAvisos[nI,3],"QDH_CODTP")
				QD5->(DbSetOrder(1))
				If QD5->(DBSeek(aAvisos[nI,1] + cCODTp ))
					While QD5->(!EOF()) .AND. QD5->QD5_FILIAL==aAvisos[nI,1] .AND. QD5->QD5_CODTP == cCODTp
						IF aAvisos[nI,6] $ "REF.SAD.VEN"
							IF QD5->QD5_GREV == "N"
								// STR0127 - Aten��o
								// STR0134 - O usu�rio informado para receber o aviso de 
								// STR0135 - no documento
								// STR0136 - N�O est� indicado como permiss�o um Gerar Revisao no cadastro !
								// STR0175 - Dever� ser concedida permiss�o no Cadastro de Tipo de Documento.
								Help(NIL, NIL, STR0127, NIL, OemToAnsi(STR0134)+" ("+Alltrim(QAX010MsgA(aAvisos[nI,6]))+") "+OemToAnsi(STR0135)+Alltrim(aAvisos[nI,2])+" "+aAvisos[nI,3]+","+OemToAnsi(STR0136) ,1, 0, NIL, NIL, NIL, NIL, NIL, {STR0175})
								lRet := .F.
								Exit
							Else
								//��������������������������������������������������������������������������������������������������Ŀ
								//�Verifica o Usurio que vai receber o Aviso de Referencia, Solicitacao de Alt, Vencido com GREV='S' �
								//����������������������������������������������������������������������������������������������������
								QD0->(DbSetOrder(2))
								IF QD0->(DBSeek(aAvisos[nI,1]+aAvisos[nI,2]+aAvisos[nI,3]+QD5->QD5_AUT+cUsrFil+cDepto+cUsrMat))
									AADD(aTiAus,QD0->QD0_AUT)
									Exit
								Else
									// STR0127 - Aten��o
									// STR0173 - Usu�rio n�o tem permiss�o para receber aviso.
									// STR0174 - Efetue a transferencia de alguma pend�ncia(Elabora��o, Revis�o, Aprova��o ou Homologa��o) do documento e repita a transferencia de aviso.
									Help(NIL, NIL, STR0127, NIL, STR0173,1, 0, NIL, NIL, NIL, NIL, NIL, {STR0174})
									lRet := .F.
									Exit
								EndiF
							EndiF
						ElseIF aAvisos[nI,6] == "QUE"
							IF QD5->QD5_ALT == "N"
								// STR0127 - Aten��o
								// STR0134 - O usu�rio informado para receber o aviso de 
								// STR0135 - no documento
								// STR0137 - N�O est� indicado com permiss�o de Alterar no cadastro !
								// STR0175 - Dever� ser concedida permiss�o no Cadastro de Tipo de Documento.
								Help(NIL, NIL, STR0127, NIL, OemToAnsi(STR0134)+" ("+Alltrim(QAX010MsgA(aAvisos[nI,6]))+") "+OemToAnsi(STR0135)+Alltrim(aAvisos[nI,2])+" "+aAvisos[nI,3]+","+OemToAnsi(STR0137) ,1, 0, NIL, NIL, NIL, NIL, NIL, {STR0175})
								lRet := .F.
								Exit
							Else
								//Verifica o Usurio que vai receber o Aviso de Questionario TEM e QD5_ALT =S
								QD0->(DbSetOrder(2))
								IF QD0->(DBSeek(aAvisos[nI,1]+aAvisos[nI,2]+aAvisos[nI,3]+QD5->QD5_AUT+cUsrFil+cDepto+cUsrMat))
									AADD(aTiAus,QD0->QD0_AUT)
									Exit
								Else
									// STR0127 - Aten��o
									// STR0173 - Usu�rio n�o tem permiss�o para receber aviso.
									// STR0174 - Efetue a transferencia de alguma pend�ncia(Elabora��o, Revis�o, Aprova��o ou Homologa��o) do documento e repita a transferencia de aviso.
									Help(NIL, NIL, STR0127, NIL, STR0173,;
										1, 0, NIL, NIL, NIL, NIL, NIL, {STR0174})
									lRet := .F.
									Exit
								EndiF
							EndiF
						Endif
						IF !lRet
							Exit
						Endif
						QD5->(DbSkip())
					Enddo
				Endif
			ElseIF aAvisos[nI,6]== "TRE"
				//�����������������������������������������������������������������������������Ŀ
				//�Verifica o Usurio que vai receber o Aviso de Treinamento TEM e DISTSN (SIM)  �
				//�������������������������������������������������������������������������������
				IF cDist =="2"
					MsgAlert(OemToAnsi(STR0134)+" ("+Alltrim(QAX010MsgA(aAvisos[nI,6]))+"), "+OemToAnsi(STR0138),OemToAnsi(STR0127)) //"O usu�rio informado para receber o aviso de"###" N�O est� indicado como um distribuidor no cadastro !"###"Atencao"
					lRet  := .F.
				Else
					IF QDZ->(DBSeek(aAvisos[nI,1]+aAvisos[nI,2]+aAvisos[nI,3]+cDepto+cUsrMat+cUsrFil))
						AADD(aTiAus,"I")
					Else
						nPosT := aScan(aPenDoc,{ |x| Alltrim(x[1])+x[8]+x[2]+x[3] == "I"+aAvisos[nI,1]+aAvisos[nI,2]+aAvisos[nI,3] }) //Por Documento
						nPosP := aScan(aTpPen ,{ |x| Alltrim(x[4]) == "I" })	 //Verifica a Transferencia"
						If (IIF(nPosT > 0, aPenDoc[nPosT,6] != (cUsrFil+cUsrMat),.T.))  .AND. ;
								(aTpPen[nPosP,1] .AND. aTpPen[nPosP,2] .AND. aTpPen[nPosP,5] != (cUsrFil+cUsrMat)) 	//Verifica a Transferencia de  "Distribuidor"
							lRet  := .F.
						Endif
					Endif
					IF !lRet
						MsgAlert(OemToAnsi(STR0134)+" ("+Alltrim(QAX010MsgA(aAvisos[nI,6]))+") "+OemToAnsi(STR0135)+Alltrim(aAvisos[nI,2])+" "+aAvisos[nI,3]+","+OemToAnsi(STR0139),OemToAnsi(STR0127)) //"O usu�rio informado para receber o aviso de"###"no documento ###"" N�O est� indicado como distribuidor!"###"Atencao"
					Endif
				Endif
			ElseIF aAvisos[nI,6]== "CAN" .AND. cMvQLIBLEI == "N"
				//����������������������������������������������������������������������������Ŀ
				//�Verifica o Usurio que vai receber o Aviso de Cancelado e um usuario leitor  �
				//������������������������������������������������������������������������������
				QDG->(DbSetOrder(3))
				IF !QDG->(DBSeek(aAvisos[nI,1]+aAvisos[nI,2]+aAvisos[nI,3]+cUsrFil+cDepto+cUsrMat))
					nPosT := aScan(aPenDoc,{ |x| Alltrim(x[1]) == "L" .AND. (x[8]+x[2]+x[3] +aAvisos[nI,1]+aAvisos[nI,2]+aAvisos[nI,3]) }) //Por Documento
					If (IIF(nPosT > 0, aPenDoc[nPosT,6] != (cUsrFil+cUsrMat),.F.))
						lRet  := .F.
					Endif
					IF !lRet
						MsgAlert(OemToAnsi(STR0134)+" ("+Alltrim(QAX010MsgA(aAvisos[nI,6]))+") "+OemToAnsi(STR0135)+Alltrim(aAvisos[nI,2])+" "+aAvisos[nI,3]+","+OemToAnsi(STR0140),OemToAnsi(STR0127)) //"O usu�rio informado para receber o aviso de"###"no documento "###" N�O est� indicado como um Leitor!"###"Atencao"
					Endif
				Endif
				QDG->(DbSetorder(nOrdQDG))
			ElseIF aAvisos[nI,6]== "TI "
				//��������������������������������������������������������������������������������������Ŀ
				//�Verifica o Usurio que vai receber o Aviso de Treinamento e um usuario a ser treinado  �
				//����������������������������������������������������������������������������������������
				QDA->(DbSetOrder(2))
				IF QDA->(DBSeek(aAvisos[nI,1]+aAvisos[nI,2]+aAvisos[nI,3]))
					While QDA->(!EOF()) .AND. (QDA->QDA_FILIAL+QDA->QDA_DOCTO+QDA->QDA_RV)==(aAvisos[nI,1]+aAvisos[nI,2]+aAvisos[nI,3])
						QD8->(DbSetOrder(1))
						IF !QD8->(DBSeek(QDA->QDA_FILIAL+QDA->QDA_ANO+QDA->QDA_NUMERO+cUsrFil+cDepto+cCodFun+cUsrMat)) .AND. QD8->QD8_BAIXA !="S"
							MsgAlert(OemToAnsi(STR0134)+" ("+Alltrim(QAX010MsgA(aAvisos[nI,6]))+") "+OemToAnsi(STR0135)+Alltrim(aAvisos[nI,2])+" "+aAvisos[nI,3]+","+OemToAnsi(STR0141),OemToAnsi(STR0127)) //"O usu�rio informado para receber o aviso de"###"no documento "###" N�O est� indicado como um treinando!""###"Atencao"
							lRet  := .F.
							Exit
						Endif
						QDA->(DbSkip())
					Enddo
				Endif
				QDA->(DbSetorder(nOrdQDA))
			Endif
		Endif
		IF lRet
			For nY:= 1 to Len(aTiAus)
				//�����������������������������������������������������������������Ŀ
				//�Verifica a Existencia de Ausencia Temporia para o Usuario Destino�
				//�������������������������������������������������������������������
				IF QA_SitAuDP(cUsrFil,cUsrMat,aTiAus[nY])
					Help(" ",1,"QX040JEAP",,aTpPen[Ascan(aTpPen,{|x| x[4]==aTiAus[nY]}),3]+" (" + Alltrim(cUsrMat) + "-" + AllTrim(QA_NUSR(cUsrFil,cUsrMat)) + ")",05,00) // "Ja existe Ausencia Temporaria cadastrada no Periodo para este Usuario."
					lRet  := .F.
				Endif
				IF lRet
					//�����������������������������������������������������������������Ŀ
					//�Verifica a Existencia de Ausencia Temporia para o Usuario Origem �
					//�������������������������������������������������������������������
					IF QA_SitAuDP(cFilAtu,cMatAtu,aTiAus[nY])
						Help(" ",1,"QX040JEAP",,aTpPen[Ascan(aTpPen,{|x| x[4]==aTiAus[nY]}),3]+" (" + Alltrim(cMatAtu) + "-" + AllTrim(QA_NUSR(cFilAtu,cMatAtu)) + ")",05,00) // "Ja existe Ausencia Temporaria cadastrada no Periodo para este Usuario."
						lRet  := .F.
					Endif
				Endif
				IF !lRet
					Exit
				Endif
			Next
		Endif
		IF !lRet
			Exit
		Endif
	Next

Return(lRet)



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QAX010QDD �Autor  �Telso Carneiro      � Data �  01/02/2006 ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica a Existencia da matriz de Responsabilidade na     ���
���          � para a Transferencia e valida o usuario transferido        ���
���          � pertence a matriz de Responsabilidade        			  ���
�������������������������������������������������������������������������͹��
���Sintaxe	 �QAX010Lib(aTpPen,aPenDoc,cFilAtu,cMatAtu,cDepAtu,			  ���
���	    	 �			nItem3,nItem5)                                    ���
�������������������������������������������������������������������������͹��
���Parametro �aTpPen - Array com o Tipos de Pendencia e Usuario que Recebe���
���          �aPenDoc- Array com o Documentos sinconizadro com aTpPen     ���
���          �cFilAtu- Filial do Usuario Transferido                      ���
���          �cMatAtu- Matricula do Usuario Transferido      			  ��� 
���          �cDepAtu- Departamento do Usuario Transferido                ���
���          �nItem3 - Intem de Transferencia de Filial/Depto  			  ���
���          �nItem5 - Tipo de Transferencia                   			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function QAX010QDD(aTpPen,aPenDoc,cFilAtu,cMatAtu,cDepAtu,nItem3,nItem5,nItem2,cCcPara)
	Local aArea  := GetArea()
	Local aAreaQDD:= QDD->(GetArea())
	Local cQuery := ""
	Local nI	 := 0
	Local nA	 := 0
	Local nU	 := 0
	Local nPosA	 := 0
	Local cDepto := ""
	Local aDocDup:= {}
	Local lRet   := .T.
	Local cUsrFil:= ""
	Local cUsrMat:= ""
	Local lResp	 := .T.

	For nA := 2 to 5 //Tipos de Pendencia da Matriz QDD
		If  aTpPen[nA,1] == .F. .Or. aTpPen[nA,2] == .F.
			Loop
		Endif

		nPosA := aScan(aPenDoc, { |x| Left(x[1],1) == aTpPen[nA,4] } )
		nPosA := If(nPosA == 0,Len(aPenDoc),nPosA)

		For nU := nPosA to Len(aPenDoc)
			If Left(aPenDoc[nU,1],1) <> aTpPen[nA,4]
				Exit
			Endif

			If nItem3 == 2

				If (aPenDoc[nU,4]) == .F. .Or. ;
						( Empty(aTpPen[nA,5]) .And. Empty(aPenDoc[nU,6]) .And. nItem5 <> 4)
					Loop
				Endif

			Endif

			IF !Empty(aTpPen[nA,5]) // Pendencias
				cUsrFil:= SUBS(aTpPen[nA,5],1,FWSizeFilial())
				cUsrMat:= SUBS(aTpPen[nA,5],FWSizeFilial()+1)
			Endif

			IF !Empty(aPenDoc[nU,6]) // Por Documento
				cUsrFil:= SUBS(aPenDoc[nU,6],1,FWSizeFilial())
				cUsrMat:= SUBS(aPenDoc[nU,6],FWSizeFilial()+1)
			Elseif Empty(cUsrFil).and. Empty(cUsrMat)
				cUsrFil:=cFilMat
				cUsrMat:=cMatAtu
			Endif

			QAA->(DBSeek(cUsrFil+cUsrMat))
			If !Empty(cCcPara) .and. nItem3 == 1
				cDepto:=cCcPara
			Else
				cDepto:=QAA->QAA_CC
			Endif
			cCargo:=QAA->QAA_CODFUN

			// Posiciona no Docto
			QDH->(dbSetOrder(1))
			QDH->(dbSeek(aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]))

			QDD->(DbSetOrder(1))
			If QDD->(DbSeek(aPenDoc[nU,8]+QDH->QDH_CODTP+aTpPen[nA,4]))
				lResp:=.F.
				While QDD->(!Eof()) .And. QDD->QDD_FILIAL+QDD->QDD_CODTP+QDD->QDD_AUT == QDH->QDH_FILIAL+QDH->QDH_CODTP+aTpPen[nA,4]
					IF QDD->QDD_FILA==cUsrFil .AND. QDD->QDD_DEPTOA==cDepto .And.  QDD->QDD_CARGOA==cCargo
						lResp:=.T.
					Endif
					QDD->(DbSkip())
				Enddo
				IF !lResp
					IF ASCAN(aDocDup,{|X| X[1]==aPendoc[nU,2] .AND. X[2]==aPendoc[nU,3] .AND. X[3]==aPendoc[nU,1] .AND. X[4]+X[5]==cUsrFil+cUsrMat })==0
						AADD(aDocDup,{aPendoc[nU,2],aPendoc[nU,3],aPendoc[nU,1],cUsrFil,cUsrMat,QA_NUSR(cUsrFil,cUsrMat)} )
					Endif
				Endif
			EndIf
		Next
	Next

	QDD->(RestArea(aAreaQDD))
	ResTArea(aArea)

	IF Len(aDocDup) > 0
		lRet:=.F.
		QAX10AuDlg(aDocDup,cFilAtu,cMatAtu,"2")
	Endif

Return(lRet)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 �FQAXA010ICE� Autor �Leandro S. Sabino     � Data � 22/08/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Valida a transferencia de usuario entre filiais 			  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 �FQAXA010ICE(cCCFilial)					              	  ���
�������������������������������������������������������������������������Ĵ��
���Parametro �ExpN1 - Numero identificando a filial 					  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 �QAXA010()                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function FQAXA010ICE(cCCFilial)
Local lRet    := .T.

	If cCCFilial <> xFilial("QAA")
	DbSelectArea("IC2")
	DbSetOrder(2)

		If IC2->(DbSeek(xFilial("IC2")+cMatAtu))
		MSGALERT(STR0154)//"Usuario n�o podera ser transferido de filial, pois  pertence a um comite Gestor de Risco."
		lRet:= .F.
		EndIf

	EndIf

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QAXA010   �Autor  �Renata Cavalcante   � Data �  05/23/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida��o na Confirma��o da tela                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Valida��o de Respons�vel, ou se � �nico Destinat�rio do Doc���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function QAX010VLTP(nOpc)

	Local aArea:= GetArea()
	Local lRet:= .T.
	Local cMat:= M->QAA_MAT
	Local cDoc:= ""
	Local nCont:=0
	Local cRecno

	If nOpc == 4 .and. M->QAA_TPRCBT == "4"     // verifica se � altera��o e se o tipo de recebimento foi alterado para N�o Recebe
		DbSelectArea("QAD")
		DbSetOrder(2)
		If DbSeek(XFilial("QAD")+cMat)
			messagedlg(STR0155)//"O usu�rio consta como respons�vel por departamento(s) n�o � permitido a altera��o do tipo de recebimento para n�o recebe"
			lRet:= .F.

		Endif

		DbSelectArea("QDG")
		DbSetorder(8)
		If DbSeek(cfilAnt+cMat)
			While !EOF() .And. QDG->QDG_MAT == cMat
				If QDG->QDG_DOCTO <> cDoc
					cDoc:= QDG->QDG_DOCTO
					cRev:= QDG->QDG_RV
				Else
					QDG->(DbSkip())
				Endif
				cRecno:= QDG->(Recno())
				DBSELECTAREA("QDG")
				DbSetorder(1)
				DBGOTOP()
				If DbSeek(XFilial("QDG")+cDoc+cRev) // Verifica se est� como o �nico destinat�rio do documento
					While !EOF() .And. QDG->QDG_DOCTO == cDoc .and. QDG->QDG_RV == cRev
						nCont++
						QDG->(DbSkip())
					enddo
					If nCont == 1
						DbSelectArea("QDH")
						DbSetOrder(1)
						If Dbseek(Xfilial("QDH")+cDoc+cRev)
							IF QDH_STATUS <> "L"
								lRet:= .F.
								messagedlg(STR0156)//"O usu�rio consta como �nico destinat�rio de documento(s) portanto o tipo de recebimento n�o poder� estar como n�o recebe"
								exit
							Endif
						Endif
					Endif
				Endif
				nCont:=0
				DbSelectarea("QDG")
				DbSetorder(8)
				dbgoto(cRecno)
				QDG->(DbSkip())

			Enddo
		Endif
	Endif
	RestArea(aArea)

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � QA010TCR � Autor �Paulo Fco. Cruz Nt. � Data �  29/12/2009 ���
�������������������������������������������������������������������������͹��
���Desc.     � Efetua a transfer�ncia de pend�ncias com cr�tica	(EC/DC)	  ���
�������������������������������������������������������������������������͹��
���Sintaxe	 � QA010TCR(cChkFil,cChkMat,cChkTpPnd,cCcFilAtu,cCcMatAtu,	  ���
���          � cCcAtu,aPenDoc)						  					  ���
�������������������������������������������������������������������������͹��
���Parametro � cChkFil	 - Filial do Usuario Origem						  ���
���          � cChkMat	 - Matricula do Usuario Origem					  ���
���          � cChkTpPnd - Tipo de pend�ncia na transfer�ncia			  ���
���          � cCcFilAtu - Filial do Usuario Destino					  ��� 
���          � cCcMatAtu - Matricula do Usuario Destino					  ���
���          � cCcAtu 	 - Departamento do Usuario Destino				  ���
���          � aPenDoc 	 - Vetor com a pendencia transferida			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function QA010TCR(cChkFil,cChkMat,cChkTpPnd,cCcFilAtu,cCcMatAtu,cCcAtu,aPenDoc)
	Local aArea		  := GetArea()
	Local nTamTpPnd	  := TamSx3("QD1_TPPEND")[1]
	Local aAreaQD1    := {}
	Local aRegAlt	  := {}
	Local nI		  := 0
	Local lGrava	  := .T.

	Default cChkFil	  := Space(FWSizeFilial())//Space(2)
	Default cChkMat	  := Space(TAMSX3("QAA_MAT")[1])
	Default cChkTpPnd := Space(3)
	Default cCcFilAtu := Space(FWSizeFilial())//Space(2)
	Default cCcMatAtu := Space(TAMSX3("QAA_MAT")[1])
	Default cCcAtu	  := Space(TAMSX3("QAA_CC")[1])
	Default aPenDoc	  := {}

	If cChkTpPnd $ "D|E"
		DBSelectArea("QD1")
		DbSetOrder(2)
		QD1->(DbSeek(aPenDoc[8]+aPenDoc[2]+aPenDoc[3]))
		While QD1->(!Eof()) .AND. (QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV==aPenDoc[8]+aPenDoc[2]+aPenDoc[3])
			aAreaQD1 := QD1->(GetArea())
			If QD1->QD1_TPPEND == PadR(cChkTpPnd+"C",nTamTpPnd) .And. cChkFil+cChkMat == QD1->QD1_FILMAT+QD1->QD1_MAT
				QD1->(dbSetOrder(8))
				QD1->(dbGoTop())
				If !QD1->(dbSeek(aPenDoc[8]+aPenDoc[2]+aPenDoc[3]+cCcAtu+cCcFilAtu+cCcMatAtu+PadR(cChkTpPnd+"C",nTamTpPnd)+" "))
					If Len(aRegAlt) > 0
						For nI:=1 To Len(aRegAlt)
							If aPenDoc[8]+aPenDoc[2]+aPenDoc[3]+cCcAtu+cCcFilAtu+cCcMatAtu+PadR(cChkTpPnd+"C",nTamTpPnd)+" "+cvaltochar(aPenDoc[7]) == aRegAlt[nI]
								lGrava := .F.
							Endif
						Next nI
					Endif
					If lGrava
						RestArea(aAreaQD1)
						Aadd(aRegAlt,aPenDoc[8]+aPenDoc[2]+aPenDoc[3]+cCcAtu+cCcFilAtu+cCcMatAtu+PadR(cChkTpPnd+"C",nTamTpPnd)+" "+cvaltochar(QD1->(RecNo())))
						RecLock("QD1",.F.)
						QD1->QD1_FILMAT	:= cCcFilAtu
						QD1->QD1_MAT	:= cCcMatAtu
						QD1->QD1_DEPTO	:= cCcAtu
						QD1->QD1_SIT	:= " "
						QD1->(MsUnlock())
						QD1->(FKCOMMIT())
					Else
						RestArea(aAreaQD1)
						RecLock("QD1",.F.)
						QD1->(DbDelete())
						QD1->(MsUnlock())
						QD1->(FKCOMMIT())
					Endif
				Else
					RestArea(aAreaQD1)
					RecLock("QD1",.F.)
					QD1->(DbDelete())
					QD1->(MsUnlock())
					QD1->(FKCOMMIT())
				Endif
			EndIf
			QD1->(DbSkip())
			lGrava := .T.
		EndDo
	EndIf

	RestArea(aArea)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � QA010CRP � Autor �Paulo Fco. Cruz Nt. � Data �  29/12/2009 ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica se existem pendencias com critica pendentes		  ���
�������������������������������������������������������������������������͹��
���Sintaxe	 � QA010CRP(cFil,cDoc,cRv,cTpPend,cFilMat,cMat,cCC)			  ���
�������������������������������������������������������������������������͹��
���Parametro � cFil 	- Filial do pendencia							  ���
���          � cDoc 	- Codigo do documento							  ���
���          � cRv		- Revisao do documento							  ���
���          � cTpPend	- Tipo da pendencia								  ��� 
���          � cFilMat	- Filial do usuario da pendencia				  ���
���          � cMat		- Matricula do usuario da pendencia				  ���
���          � cCC		- Departamento do usuario da pendencia			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function QA010CRP(cFil,cDoc,cRv,cTpPend,cFilMat,cMat,cCC)
	Local aArea		:= GetArea()
	Local aQD1		:= QD1->(GetArea())
	Local aQDH		:= QDH->(GetArea())
	Local nA		:= 1
	Local nTamTpPnd	:= TamSx3("QD1_TPPEND")[1]
	Local cQuery	:= ""
	Local cFilBsc	:= Space(FWSizeFilial())//Space(2)
	Local cMatBsc	:= Space(TamSx3("QAA_MAT")[1])
	Local cDepBsc	:= Space(TamSx3("QAA_CC")[1])
	Local cTrCancel := GetNewPar("MV_QTRCANC","1")
	Local lExiste	:= .F.

	Static aPenCrit
	Static cLastUsr

	Default cFil 	:= Space(FWSizeFilial())
	Default cDoc	:= ""
	Default cRv		:= ""
	Default cTpPend	:= ""
	Default cFilMat	:= ""
	Default cMat	:= ""
	Default cCC		:= ""

	If (ValType(aPenCrit) != "A" .Or. ValType(cLastUsr) != "C") .Or. cLastUsr != cFilMat+cMat

		aPenCrit := {}
		cLastUsr := cFilMat+cMat

		For nA := 1 to Len(aBuscaQD1)
			cFilBsc := aBuscaQD1[nA,1]
			cMatBsc := aBuscaQD1[nA,2]
			cDepBsc := aBuscaQD1[nA,3]

			//�������������������������������������������Ŀ
			//� Carrega as pendencias com critica (DC/EC) �
			//���������������������������������������������
			cQuery := " SELECT QD1.QD1_FILIAL,QD1.QD1_DOCTO,QD1.QD1_RV,QD1.QD1_TPPEND,QD1.QD1_PENDEN,QD1.QD1_FILMAT,QD1.QD1_MAT,QD1.QD1_DEPTO"//,QD1.R_E_C_N_O_"
			cQuery += " FROM " + RetSqlName("QD1")+" QD1 "
			cQuery += " WHERE QD1.QD1_FILMAT = '"+cFilBsc+"' AND QD1.QD1_MAT = '"+cMatBsc+"' AND QD1.QD1_SIT <> 'I'"
			cQuery += " AND QD1.QD1_TPPEND IN ('EC','DC')"
			cQuery += " AND QD1.QD1_PENDEN = 'P'"
			cQuery += " AND QD1.D_E_L_E_T_ <> '*' "

			cQuery += " AND NOT EXISTS(SELECT R_E_C_N_O_ FROM "+ RetSqlName("QDH")+" QDH WHERE QD1.QD1_FILIAL = QDH.QDH_FILIAL "
			cQuery += " AND QD1.QD1_DOCTO = QDH.QDH_DOCTO AND QD1.QD1_RV = QDH.QDH_RV"
			If cTrCancel =="2"
				cQuery += " AND QDH.QDH_OBSOL = 'S' AND QDH.QDH_STATUS = 'L'"
			Else
				cQuery += " AND (QDH.QDH_OBSOL = 'S' Or (QDH.QDH_CANCEL = 'S' And QDH.QDH_STATUS = 'L'))"
			EndIf
			cQuery += " AND QDH.D_E_L_E_T_ <> '*')"
			cQuery += " ORDER BY QD1.QD1_FILIAL,QD1.QD1_TPPEND,QD1.QD1_DOCTO,QD1.QD1_RV "
			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QD1TRB",.T.,.T.)

			While QD1TRB->(!Eof())
				//������������������������������������������Ŀ
				//� Atualiza o array com as pendencias DC/EC �
				//��������������������������������������������
				If aScan(aPenCrit,{|x| x[1] == QD1TRB->QD1_FILIAL .And. x[2] == QD1TRB->QD1_DOCTO .And. x[3] == QD1TRB->QD1_RV .And. x[4] == QD1TRB->QD1_TPPEND }) == 0
					aAdd(aPenCrit,{QD1TRB->QD1_FILIAL,QD1TRB->QD1_DOCTO,QD1TRB->QD1_RV,QD1TRB->QD1_TPPEND,QD1TRB->QD1_PENDEND,QD1TRB->QD1_FILMAT,QD1TRB->QD1_MAT,QD1TRB->QD1_DEPTO})
				EndIf

				QD1TRB->(DbSkip())
			EndDo

			QD1TRB->(DbCloseArea())
		Next
	EndIf

	cTpPend := PadR(AllTrim(cTpPend)+"C",nTamTpPnd)

	If !Empty(aPenCrit) .And. cTpPend $ "DC |EC " .And. ;
			aScan(aPenCrit,{|x| x[1]+x[2]+x[3]+x[4]+x[6]+x[7] == cFil+cDoc+cRv+cTpPend+cFilMat+cMat}) > 0

		lExiste := .T.
	EndIf

	RestArea(aArea)
	QD1->(RestArea(aQD1))
	QDH->(RestArea(aQDH))

Return lExiste

/*/{Protheus.doc} fPenDoc
Fun��o expecialista para gerar o c�digo do documento afim de diminui��o da performance.
@type  Function
@author thiago.rover
@since 15/06/2021
(examples)
@see (links_or_references)
/*/
Function fPenDoc(aPenDoc,aTpPen, cFilBsc,cMatBsc)

Local cTrCancel  := GetNewPar("MV_QTRCANC","1")
Local x          := 0
Local cTpPen     := ""
Local cQuery     := ""
Local lPerg      := .F.
Local cDocumento := ""

	If Len(aPenDoc) >= 500
		lPerg   := .T.
	Else
		For x := 1 To Len(aPenDoc)
			If x = Len(aPenDoc)
				cDocumento += "'"+ALLTRIM(aPenDoc[x,8]+aPenDoc[x,2]+aPenDoc[x,3]+SubStr(aPenDoc[x,1],1,1))+"'"
			Else
				cDocumento += "'"+ALLTRIM(aPenDoc[x,8]+aPenDoc[x,2]+aPenDoc[x,3]+SubStr(aPenDoc[x,1],1,1))+"', "
			Endif
		Next x
	Endif

	For x := 1 To Len(aTpPen)
		If aTpPen[x,2] == .F.
			cTpPen += "'"+aTpPen[x,4]+"', "
		Endif
	Next x

	If cValTOChar(ASC(Substr(cTpPen,Len(ALLTRIM(cTpPen)),1))) $ '44' // Validando o ultimo caracter caso seja uma virgula
		cTpPen := Left(cTpPen,Len(ALLTRIM(cTpPen))-1)
	Endif

	cQuery := " SELECT QD0.QD0_AUT FROM "+ RetSqlName("QD0")+" QD0"
	cQuery += " LEFT JOIN (SELECT QDH_FILIAL+QDH_DOCTO+QDH_RV RETORNO FROM "+ RetSqlName("QDH")+" QDH " 
	cQuery += " WHERE "
	If cTrCancel=="2"
		cQuery += " QDH.QDH_OBSOL = 'S' AND QDH.QDH_STATUS = 'L'"
	Else
		cQuery += " (QDH.QDH_OBSOL = 'S' OR (QDH.QDH_CANCEL = 'S' AND QDH.QDH_STATUS = 'L'))" 
	Endif
	cQuery += " AND QDH.D_E_L_E_T_ <> '*') QDH "
	cQuery += " ON  QD0.QD0_FILIAL+QD0.QD0_DOCTO+QD0.QD0_RV = QDH.RETORNO "
	cQuery += " WHERE QD0.QD0_FILMAT = '"+cFilBsc+"' AND QD0.QD0_MAT = '"+cMatBsc+"'"
	cQuery += " AND QD0.QD0_FLAG <> 'I' AND QD0.D_E_L_E_T_ <> '*'
	cQuery += " AND QD0.QD0_AUT NOT IN ("+cTpPen+ ") "
	cQuery += " GROUP BY QD0.QD0_AUT "
	cQuery := ChangeQuery(cQuery) 
								
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QD0TRB",.T.,.T.)

	WHILE QD0TRB->(!EOF())
		If ( nPos := aScan(aTpPen,{|x| x[4] == QD0TRB->QD0_AUT } ) ) > 0
			aTpPen[nPos,2] := .T.
		ENDIF
		QD0TRB->(DbSkip())
	ENDDO

	QD0TRB->(DBCLOSEAREA())

	//����������������������������������������������Ŀ
	//� Carrega Responsaveis                         �
	//������������������������������������������������	
	cQuery := " SELECT QD0.QD0_FILIAL,QD0.QD0_DOCTO,QD0.QD0_RV,QD0.QD0_AUT,QD0.R_E_C_N_O_ FROM "+ RetSqlName("QD0")+" QD0"
	cQuery += " LEFT JOIN (SELECT QDH_FILIAL+QDH_DOCTO+QDH_RV RETORNO FROM "+ RetSqlName("QDH")+" QDH" 
	cQuery += " WHERE "
	If cTrCancel=="2"
		cQuery += " QDH.QDH_OBSOL = 'S' AND QDH.QDH_STATUS = 'L'"
	Else
		cQuery += " (QDH.QDH_OBSOL = 'S' OR (QDH.QDH_CANCEL = 'S' AND QDH.QDH_STATUS = 'L'))" 
	Endif
	cQuery += " AND QDH.D_E_L_E_T_ <> '*') QDH "
	cQuery += " ON  QD0.QD0_FILIAL+QD0.QD0_DOCTO+QD0.QD0_RV = QDH.RETORNO "
	cQuery += " WHERE QD0.QD0_FILMAT = '"+cFilBsc+"' AND QD0.QD0_MAT = '"+cMatBsc+"'"
	cQuery += " AND QD0.QD0_FLAG <> 'I' AND QD0.D_E_L_E_T_ <> '*'
	If lPerg
		cQuery += " AND (QD0.QD0_DOCTO >= ('"+ALLTRIM(aArryPg[1])+"') "
		cQuery += " AND QD0.QD0_DOCTO <= ('"+ALLTRIM(aArryPg[3])+"'))"
		cQuery += " AND (QD0.QD0_RV >= ('"+ALLTRIM(aArryPg[2])+"') "
		cQuery += " AND QD0.QD0_RV <= ('"+ALLTRIM(aArryPg[4])+"') )"
	Else
		cQuery += " AND QD0.QD0_DOCTO+QD0.QD0_RV+QD0.QD0_AUT NOT IN ("+cDocumento+") "
	Endif
	cQuery += " ORDER BY QD0.QD0_FILIAL,QD0.QD0_AUT,QD0.QD0_DOCTO,QD0.QD0_RV "
	cQuery := ChangeQuery(cQuery) 
								
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QD0TRB",.T.,.T.)

	If lPerg
		WHILE QD0TRB->(!EOF())
			If Ascan( aPenDoc , {|X| X[8]+X[2]+X[3]+SubStr(X[1],1,1) == QD0TRB->QD0_FILIAL+QD0TRB->QD0_DOCTO+QD0TRB->QD0_RV+QD0TRB->QD0_AUT}) == 0
				aAdd(aPenDoc , { Left(QD0TRB->QD0_AUT+Space( 3 ),3), QD0TRB->QD0_DOCTO, QD0TRB->QD0_RV, .T. ,"B", Space(8), QD0TRB->R_E_C_N_O_, QD0TRB->QD0_FILIAL, 0,''})
			EndIf
			QD0TRB->(DbSkip())
		EndDo
	Else
		WHILE QD0TRB->(!EOF())
			aAdd(aPenDoc , { Left(QD0TRB->QD0_AUT+Space( 3 ),3), QD0TRB->QD0_DOCTO, QD0TRB->QD0_RV, .T. ,"B", Space(8), QD0TRB->R_E_C_N_O_, QD0TRB->QD0_FILIAL, 0,''})
			QD0TRB->(DbSkip())
		EndDo
	Endif
	DBCLOSEAREA()	

Return

/*/{Protheus.doc} fMontPerg
Fun��o que monta um pergunte manual
@type  Function
@author thiago.rover
@since 18/06/2021
@example
(examples)
@see (links_or_references)
/*/
Function fMontPerg()
Local oDlg
Local oGet1
Local oGet2
Local aArryPg := {} 
Local cPict   := ""
Local nOpcao  := 0 
Local cDoctoDe:= Space(TAMSX3("QDH_DOCTO")[1])
Local cDoctoAt:= Replicate("Z",TAMSX3("QDH_DOCTO")[1])
Local cRevDe  := Space(TAMSX3("QDH_RV")[1])
Local cRevAt  := Replicate("9",TAMSX3("QDH_RV")[1])

	DEFINE MSDIALOG oDlg FROM 000,000 TO 15,50 TITLE OemToAnsi(STR0161) // "Filtro por Documento"
	//Campo para informar o documento de
	@10, 03 Say STR0162 Size 53, 07 Of oDlg  Pixel // "Documento De: "
	@10, 50 MSGET cDoctoDe SIZE 60, 09 OF oGet1 PIXEL PICTURE cPict F3 "QDH" 

	@30, 03 Say STR0163 Size 53, 07 Of oDlg  Pixel  // "Revis�o: "
	@30, 50 MSGET cRevDe PICTURE cPict SIZE 40, 09 WHEN .T.  OF oDlg PIXEL

	//campo para informar o documento at�
	@50, 03 Say STR0164 Size 53, 07 Of oDlg  Pixel // "Documento At�: "
	@50, 50 MSGET cDoctoAt SIZE 60, 09 OF oGet2 PIXEL PICTURE cPict F3 "QDH"

	//campo para informar o documento at�
	@70, 03 Say STR0165 Size 53, 07 Of oDlg  Pixel // "Revis�o: "
	@70, 50 MSGET cRevAt PICTURE cPict SIZE 40, 09 WHEN .T. OF oDlg PIXEL
	
	//bot�es
	DEFINE SBUTTON FROM 100, 100 TYPE 1 ACTION (nOpcao:= 1,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 100, 130 TYPE 2 ACTION (nOpcao:= 2,oDlg:End()) ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpcao == 1 .And. (Empty(cDoctoAt) .Or. Empty(cRevAt))
		fMontPerg()
	EndIf

	cQuery := " SELECT DISTINCT QDH_DOCTO, QDH_RV From "+ RetSqlName("QDH")+" QDH"
	cQuery += " WHERE "
	If !Empty(cDoctoDe) .Or. !Empty(cRevDe)
		lVldPer := .T.
		cQuery += " QDH_DOCTO BETWEEN '"+cDoctoDe+"' AND '"+cDoctoAt+"'"
		cQuery += " AND QDH_RV BETWEEN '"+cRevDe+"' AND '"+cRevAt+"' AND "
	Endif
	cQuery += " D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery) 
								
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QDHTRB",.T.,.T.)

	// Inicializa��o da vari�vel
	aFltDoc := {} 

	WHILE QDHTRB->(!EOF())
		aAdd(aFltDoc , { QDHTRB->QDH_DOCTO, QDHTRB->QDH_RV,})
		QDHTRB->(DbSkip())
	EndDo

	Aadd(aArryPg,cDoctoDe)
	Aadd(aArryPg,cRevDe)
	Aadd(aArryPg,cDoctoAt)
	Aadd(aArryPg,cRevAt)

	QDHTRB->(DbCloseArea())

Return aArryPg

/*/{Protheus.doc} valAltFunc
	Fun��o que valida se o usu�rio est� alterando o cargo/fun��o - DMANQUALI-2724
	@type  Function
	@author cintia.paul	
	@since 07/07/2021
	@example
	(examples)
	@see (links_or_references)
/*/
Function valAltFunc()
Local cCodFun := QAA->QAA_CODFUN

If Altera .And. !(cCodFun == M->QAA_CODFUN) 
/*		MsgAlert(OemToAnsi(STR0168) + CHR(13)+CHR(10);
		+ OemToAnsi(STR0169) + CHR(13)+CHR(10); 
		+ OemToAnsi(STR0170), OemToAnsi(STR0127))*/
		Help("",1,"ALTFUNCAO",,STR0168,1,0,,,,,,{STR0169, ' ', STR0170}) 
		//Aviso
		//Ao alterar a fun��o do usu�rio, o mesmo pode ficar sem permiss�o para baixar pend�ncias. 
		//Revise se usu�rio possui pend�ncias e transfira as mesmas para um novo respons�vel ou realize a baixa das pend�ncias antes desta altera��o.
		//O Relat�rio de Pend�ncias - QDOR050 poder� ser utilizado realizar esta verifica��o.

Endif	
	
Return .T.

/*/{Protheus.doc} QAX010TOK
@type Static Function
@author rafael.hesse
@since 29/04/2022
@param nOpc, num�rico, indica a opera��o da rotina
@return lRet, L�gico, indica se o cadastro est� v�lido para inclus�o/altera��o
/*/
Static Function QAX010TOK(nOpc)
	Local lImplantado 	:= .F.
	Local lRet 			:= .F.
	Local oDocControl 	:= Nil

	If Obrigatorio(aGets,aTela) .And. QX10VldEmp(lIntGPE) .And. QA010VrCfg(.T.) .And. QAX010VLTP(nOpc) .and. Q070VUso()	
		lRet := .T.  
	EndIf

	If lRet .and. M->QAA_TPWORD == '4'
		If FindClass(Upper("QDODocumentControl"))
			oDocControl 	:= QDODocumentControl():New()
			lRet := !oDocControl:validaInconsistenciaImplantacao(@lImplantado, .T.) 
			If lRet .and. !lImplantado
				//STR0171 "Implanta��o n�o executada."
				//STR0172 "Op��o dispon�vel apenas ap�s a execu��o do implantador 'QDOPdfVWiz'  "
				Help( " ", 1, "QX10IMPDOC",,STR0171 ,1, 1,,,,,, {STR0172})
				lRet := .F.
			Endif
		Endif
	EndIf

	If lRet .And. Altera .And. M->QAA_STATUS == '2'
		lRet := QAAValIna()
	EndIf

Return lRet

/*/{Protheus.doc} QAAValExc
Fun��o que valida se o usu�rio est� apto a ser excluido
@type  Function
@author rafael.hesse
@since 13/07/2022
@return lRet, L�gico, indica se o cadastro est� v�lido para Exclus�o.
/*/
Function QAAValExc()
Local lRet    := .T.

	If !(QNC070VExc() .And. QEA050VdDel() .And. QAX010VdEx())
		// "Existe Lancamentos para este Usuario nao e permitido a exclusao"
		// "Consulte o Follow Up/Etapas e verifique as etapas pendentes para este Usuario."
		Help(" ",1,"QDFUNEXC") 
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} QAAValIna
Fun��o que valida se o usu�rio est� apto a ser inativado
@type  Function
@author rafael.hesse
@since 16/08/2022
@return lRet, L�gico, indica se o cadastro est� v�lido para Inativa��o.
/*/
Function QAAValIna()
Local cAliasQD1 := GetNextAlias()
Local cQuery    := ""
Local lRet      := .T.
Local oExec     := Nil

Default lFwExecSta := FindClass( Upper("FwExecStatement") ) //Default para facilitar na cobertura

	cQuery := " SELECT "
	cQuery += 		" QD1_PENDEN "
	cQuery += " FROM "
	cQuery += 		RetSqlName("QD1") + " QD1 "
	cQuery += " WHERE "
	cQuery += 		" QD1.D_E_L_E_T_ = '' "
	cQuery += 		" AND QD1.QD1_MAT = '" + M->QAA_MAT + "' "
	cQuery += 		" AND QD1.QD1_FILMAT = '" + M->QAA_FILIAL + "' "
	cQuery += 		" AND QD1.QD1_PENDEN = 'P' "

	If lFwExecSta
		oExec := FwExecStatement():New(cQuery)
		cAliasQD1 := oExec:OpenAlias()
		oExec:Destroy()
		oExec := nil 
	else
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQD1)
	EndIf
	
	If (cAliasQD1)->(!EOF())
		//STR0176 "N�o � poss�vel inativar o usu�rio ###-#####"
		//STR0177 "Existem Lancamentos para este Usu�rio que o impedem de ser inativado"
		Help( " ", 1, "QDFUNINA",,STR0176 + M->QAA_MAT + " - " + M->QAA_NOME,1, 1,,,,,, {STR0177})
		lRet := .F.
	EndIf

	(cAliasQD1)->(DbCloseArea())
	
Return lRet
