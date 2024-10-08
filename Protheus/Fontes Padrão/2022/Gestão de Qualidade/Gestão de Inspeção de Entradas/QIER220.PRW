#Include "QIER220.CH"
#Include "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIER220  � Autor � Vera Lucia S. Simoes  � Data �22/02/1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao das Fichas dos Produtos que foram importados     ���
���          � corretamente e que estao marcados para inspecao.           ���
���          � Imprime tambem as etiquetas de rastreabilidade e de laudo. ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � QIER220()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Chamado a partir do QIEA180.PRW                            ���
�������������������������������������������������������������������������Ĵ��
���			ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.			  ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data	� BOPS �  Motivo da Alteracao 					  ���
�������������������������������������������������������������������������Ĵ��
���Vera        �19/04/99�------� Inclusao da Loja do Fornecedor           ���
���Vera        �24/09/99�------� Opcao de impr. tambem as etiquetas rastr.���
���            �        �      � e de laudo se vier pelo menu Prod-Import.���
���Paulo Emidio�18/05/00�------�Retirada da Funcao de ajuste do SX1       ���
���Marcelo     �13/07/00�      � Inclusao da pergunta Imprime Entrada em  ���
���            �        �      � Skip-Lote (S/N).                         ���
���Paulo Emidio�29/09/00�----- � Alteracao na exibicao dos caracteres inva���
���            �        �      � lidos.                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QIER220(cProg,aGravDad)
// ��������������������������������������Ŀ
// � Par�metros para a fun��o SetPrint () �
// ����������������������������������������
LOCAL wnrel     := "QIER220"
LOCAL cString   := "QEK"
LOCAL cDesc1    := OemToAnsi(STR0001)	//"Neste relatorio ser�o relacionados os ensaios a serem realizados em ca-"
LOCAL cDesc2    := OemToAnsi(STR0002)	//"da laboratorio, para a validacao da Entrada."
LOCAL cDesc3    := ""
Local lEsc	    := .F.
Local lImpFic   := .F.
Local lEtiqRast	:= .F.
Local lEtiqLaudo:= .F.

Private lreport
// �����������������������������������Ŀ
// � Par�metros para a fun��o Cabec()  �
// �������������������������������������
PRIVATE cTitulo   :=	GetMv("MV_QEFICHP")+ STR0003	// - USO
PRIVATE cRelatorio:=	"QIER220"
PRIVATE cTamanho  := "G"
PRIVATE nPagina   := 1
Private LI        := 80

//������������������������������������������������Ŀ
//� Vari�veis utilizadas pela fun��o SetDefault () �
//��������������������������������������������������
Private	aReturn  := {STR0004, 1,STR0005,  1, 2, 1, "",1 }  //"Zebrado"###"Administracao"
Private	nLastKey := 0  
Private cPerg    := "QER220"
Private	cMV_PAR01 
Private	cMV_PAR02 
Private	cMV_PAR03 
Private	cMV_PAR04 
Private	cMV_PAR05 
Private	cMV_PAR06 
Private lExistBol := IIf(ExistBlock("QIER200R"),.T.,.F.)
Private lExistRas := IIf(ExistBlock("QIER240R"),.T.,.F.)
Private lExistLau := IIf(ExistBlock("QIER270R"),.T.,.F.)
Private cCabec1   := ""
Private cCabec2   := ""

If AllTrim(FunName()) == "QIER220" 

	If !Pergunte(cPerg,.T.)
  		lEsc := .T.
  	EndIf

  	cMV_PAR01 := mv_par01
  	cMV_PAR02 := mv_par02
  	cMV_PAR03 := mv_par03
  	cMV_PAR04 := mv_par04
  	cMV_PAR05 := mv_par05
  	cMV_PAR06 := mv_par06
Else

	cPerg := "QIE200"
	Pergunte(cPerg,.T.)

	//���������������������������������������Ŀ
	//� Verifica se existem Entradas corretas �
	//�����������������������������������������
	dbSelectArea("QEP")
	dbSetOrder(1)
	If !(dbSeek(xFilial("QEP")+"1"))
		lESC := .T.
	EndIf

  	cMV_PAR01 := mv_par01
  	cMV_PAR02 := mv_par02
  	cMV_PAR03 := mv_par03
  	cMV_PAR04 := mv_par04
  	cMV_PAR05 := mv_par05
  	cMV_PAR06 := mv_par06
  	
	If AllTrim(FunName())=="QIEA183"
	  	cPerg := ''
	EndIf  	

EndIf
	
If !lESC
	//����������������������������������������Ŀ
	//� Os valores de mv_par04 e mv_par05 sao  �
	//� perdidos depois de passar no execblock � 
	//������������������������������������������
	lImpFic		:= IF(cmv_par01 == 1,.T.,.F.)
	lEtiqRast   := IF(cmv_par02 == 1,.T.,.F.)
	lEtiqLaudo  := IF(cmv_par03 == 1,.T.,.F.)
	
	If lImpFic .Or. lEtiqRast .Or. lEtiqLaudo
		//��������������������������������������������������������������Ŀ
		//� Envia controle para a funcao SETPRINT                        �
		//����������������������������������������������������������������
	    If !lExistBol 
			wnrel := SetPrint(cString,wnrel,cPerg,@ctitulo,cDesc1,cDesc2,cDesc3,.F.,"",,cTamanho) 
		Endif			
		
		If nLastKey == 27
			Set Filter To
			Return
		Endif
		
	    If !lExistBol 
			SetDefault(aReturn,cString)
		Endif	
		
		If nLastKey == 27
			Set Filter To
			Return
		Endif
			
		RptStatus({|lEnd| A220Imp(@lEnd,wnRel,cString,lEsc,;
						lImpFic,lEtiqRast,lEtiqLaudo,aGravDad)},cTitulo)
	EndIf					
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A220Imp  � Autor � Vera Lucia S. Simoes  � Data �23/02/1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chama a impr. ficha p/ entr. marcadas p/ inspecao          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � A220Imp(lEnd,wnRel,cString)                       		  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd     -  A��o do CodeBlock                              ���
���          � wnRel    -  T�tulo do relat�rio                            ���
���          � cString  -  Mensagem                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A220Imp(lEnd,wnRel,cString,lEsc,lImpFic,lEtiqRast,lEtiqLaudo,aGravDad)
Local aVetQEK	:= {}
Local cChvQEK	:= ""
Local lImpres	:= .F.
Local nConta	:= 0
Local nCont		:= 0
Local nTipo 	:= 0
Local lFirst	:= .T.
Local cChvQEK1	:= ""
Local lQIER200R := ExistBlock("QIER200R")
Local lQER200RE := ExistBlock("QER200RE")

If !lEsc

	Li    := 80
	m_Pag := 1

	//����������������������������������������������������������Ŀ
	//� Imprime as Fichas dos Produtos para as Entradas corretas �
	//������������������������������������������������������������
	dbSelectArea("QEP")
	dbSetOrder(1)
	If dbSeek(xFilial("QEP")+"1")
		
		//������������������������������������������������������������Ŀ
		//� Impressao da Ficha do Produto - Uso, Etiquetas de Rastrea- �
		//� bilidade e de Laudo, independente de inspecionar ou certi- �
		//� ficar a Entrada.                                           �
		//��������������������������������������������������������������
		If LI > 58 .And. lImpFic .And. (!lQER200RE .AND. !lQIER200R)
			Cabec(cTitulo,cCabec1,cCabec2,wnrel,cTamanho,nTipo,,.F.)
		EndIf	
		
		While !Eof() .And. QEP_FILIAL == xFilial("QEP") .And. QEP_CODTAB == "1" 

			//�����������������������������������������Ŀ
			//� Verifica se a Entrada nao foi excluida  �
			//����������������`���������������������������
			If QEP->QEP_EXCLUI == "S"
				dbSkip()
				Loop
			EndIf

			//��������������������������������������������������������������Ŀ
			//� Se foi chamada pelo menu de Relatorios, verifica se j� foi   �
			//� impressa, se a opcao for a 2 - somente as nao impressas.     �
			//����������������������������������������������������������������
			If cMV_PAR06 == 2 //1=Todas 2=Atual
				If AllTrim(FunName()) == "QIER220"	.or. AllTrim(FunName()) == "QIEA183"
					If QEP->QEP_IMPFIC == "S"
						dbSkip()
						Loop
					EndIf
				EndIf
			EndIf         
			
			QEK->(dbSetOrder(14))
			cChvQEK := xFilial("QEK")+QEP->QEP_FORNEC+QEP->QEP_LOJFOR+;
					QEP->QEP_PRODUT+QEP->QEP_NTFISC+QEP->QEP_SERINF+DtoS(QEP->QEP_DTENTR)+QEP->QEP_LOTE

			
			// Localiza a Entrada
			If QEK->(dbSeek(cChvQEK))
			
				While !QEK->(Eof())
						IF Alltrim(QEK->QEK_ITEMNF+QEK->QEK_TIPONF) == Alltrim(QEP->QEP_ITEMNF+QEP->QEP_TIPONF) 		            
			    			If cMV_PAR06 == 2 //1=Todas 2=Atual
								If AllTrim(FunName()) == "QIEA200" 
									If QEP->QEP_INSPOB == "P" 
										QEP->(dbSkip())
										Loop
									EndIf
								EndIf
							EndIf	
																
							//��������������������������������Ŀ
							//� Imprime Ficha do Produto - Uso �
							//����������������������������������
							If lImpFic  // Imprime o Relat�rio
								If lQIER200R
									If lFirst 
										lFirst := .F.
										SetaPilha()	// precisa porque chama lprint mais de 1 vez
										cChvQEK1 := xFilial("QEK")+QEP->QEP_FORNEC+QEP->QEP_LOJFOR+QEP->QEP_PRODUT+QEP->QEP_NTFISC+QEP->QEP_SERINF+QEP->QEP_ITEMNF+QEP->QEP_TIPONF+DTOS(QEP->QEP_DTENTR)+QEP->QEP_LOTE								 
										ExecBlock("QIER200R",.f.,.f.,{"QIER220",aGravDad,{cChvQEK1}})
										SetaPilha()
									Endif
									If aGravDad <> NIL .and. !Alltrim(FunName()) $ "QIER220.QIEA200"
										nConta := Len(aGravDad)
									Endif	
									
								Else								
									lImpres := .T.
									SetWFirstPage(.F.)
									QIER200("QIER220",lImpres,@nConta,aGravDad,@lReport)
								EndIf
							Else
								If aGravDad <> NIL .and. !Alltrim(FunName()) $ "QIER220.QIEA200"
									nConta := Len(aGravDad)						
								Endif	
							EndIf
							Exit
						Endif
						QEK->(dbSetOrder(14))
						QEK->(dbSkip())
   					Enddo  
			
			EndIf		
		
			dbSelectArea("QEP")
			dbSkip()
		EndDo
	EndIf

	//������������������������������������������������Ŀ
	//� Imprime as Etiquetas para as Entradas corretas �
	//��������������������������������������������������
	dbSelectArea("QEP")
	dbSetOrder(1)
	If dbSeek(xFilial("QEP")+"1")
		
		//������������������������������������������������������������Ŀ
		//� Impressao da Ficha do Produto - Uso, Etiquetas de Rastrea- �
		//� bilidade e de Laudo, independente de inspecionar ou certi- �
		//� ficar a Entrada.                                           �
		//��������������������������������������������������������������
		While !Eof() .And. QEP_FILIAL == xFilial("QEP") .And. QEP_CODTAB == "1" 
			//�����������������������������������������Ŀ
			//� Verifica se a Entrada nao foi excluida  �
			//�������������������������������������������

			If QEP->QEP_EXCLUI == "S"
				dbSkip()
				Loop
			EndIf
		
			//��������������������������������������������������������������Ŀ
			//� Se foi chamada pelo menu de Relatorios, verifica se j� foi   �
			//� impressa, se a opcao for a 2 - somente as nao impressas.     �
			//����������������������������������������������������������������
	   		If cMV_PAR06 == 2 //1=Todas 2=Atual
				If AllTrim(FunName()) == "QIER220" .or. AllTrim(FunName()) == "QIEA183"
					If QEP->QEP_IMPFIC == "S"
						dbSkip()
						Loop
					EndIf
				EndIf
			EndIf			

			QEK->(dbSetOrder(14))
			cChvQEK := xFilial("QEK")+QEP->QEP_FORNEC+QEP->QEP_LOJFOR+;
					QEP->QEP_PRODUT+QEP->QEP_NTFISC+QEP->QEP_SERINF+DtoS(QEP->QEP_DTENTR)+QEP->QEP_LOTE

			If QEK->(dbSeek(cChvQEK))
				If Alltrim(FunName()) $ "QIER220.QIEA200"	 
					// Guarda o registro da entrega
					Aadd(aVetQEK,cChvQEK)
				Else  
					If nCont < nConta .and. lImpFic
						Aadd(aVetQEK,cChvQEK)					
		        	    nCont++
					Endif             
					If !lImpFic
					    If aGravDad <> NIL
						    aVetQEK := aClone(aGravDad)
						Endif    
					Endif
				Endif	
			EndIf		
			dbSelectArea("QEP")
			dbSkip()
		EndDo
		
		If Len(aVetQEK) > 0
			//�������������������������������������Ŀ
			//� Imprime Etiqueta de Rastreabilidade �
			//���������������������������������������
			If lEtiqRast   // Imprime a Etiqueta de Rastreabilidade
				If ExistBlock("QIER240R")
					SetaPilha()
					Execblock("QIER240R",.f.,.f.,{"QIER220",cMv_par04,cMv_par05,aVetQEK,aGravDad,lImpFic})
					SetaPilha()
				Else
					QIER240("QIER220",cMv_par04,cMv_par05,aVetQEK,aGravDad,lImpFic)
				Endif
			Endif
		Endif		
		//���������������������������Ŀ
		//� Imprime Etiqueta de Laudo �
		//�����������������������������
		If lEtiqLaudo
			If cmv_par03 == 1
				If ExistBlock("QIER270R")
					SetaPilha()
					ExecBlock("QIER270R",.F.,.F.,{"QIER220",cMv_par04,cMv_par05,aVetQEK,aGravDad,lImpFic,lEtiqRast})
					SetaPilha()
				Else       
					QIER270("QIER220",cMv_par04,cMv_par05,aVetQEK,lImpFic,lEtiqRast)
				EndIf
			Endif
		EndIf
	EndIf
EndIf

Return
