#INCLUDE "Mata900.ch"
#INCLUDE "FIVEWIN.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MATA900  � Autor � Juan Jose Pereira     � Data �13/02/93  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Acertos de Livros Fiscais                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
��� Marcos Simidu�03/09/98�17554A� Acertos no MV_DATAFIS.                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MATA900()
Local cFiltraSF3	:= " "
Local bFiltraBrw	:= " "
Local aIndexSF3		:= {}

PRIVATE aRotina := MenuDef()
//���������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes  �
//�����������������������������������������������
PRIVATE cCadastro := OemToAnsi(STR0006) //"Livros Fiscais"
PRIVATE nInclui   := 0


If cPaisLoc=="BOL"
	//������������������������������������������������������������������������Ŀ
	//�Verificacao de filtro na Mbrowse                                        �
	//��������������������������������������������������������������������������
	#IFDEF TOP
		cFiltraSF3 := 'F3_STATUS<>""'
	#ELSE
		cFiltraSF3 := '!Empty(F3_STATUS)'
	#ENDIF
	If Valtype(cFiltraSF3) == "C" .And. !Empty(cFiltraSF3)
		bFiltraBrw 	:= {|| FilBrowse("SF3",@aIndexSF3,@cFiltraSF3)}
		Eval(bFiltraBrw)
		If ( Eof() )
			HELP(" ",1,"RECNO")
		EndIf
	EndIf

	//������������������������������Ŀ
	//� Endereca a funcao de BROWSE  �
	//��������������������������������
	mBrowse( 6, 1,22,75,"SF3")
		
	//������������������������������������������������������������������������Ŀ
	//� Finaliza o uso da funcao FilBrowse e retorna os indices padroes.       �
	//��������������������������������������������������������������������������
	If !Empty(cFiltraSF3) .And. Len(aIndexSF3) > 0
		EndFilBrw("SF3",aIndexSF3)
	EndIf
Else

	//������������������������������Ŀ
	//� Endereca a funcao de BROWSE  �
	//��������������������������������
	mBrowse( 6, 1,22,75,"SF3")

EndIf
Return Nil

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A900Visual� Autor �   Henry Fila          � Data �03/09/02  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Inclusaoo dos Livros Fiscais                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A900Visual(cAlias,nReg,nOpc)

Local aButtonUsr:= {}

If ExistBlock("MA900BTN")
	aButtonUsr := ExecBlock("MA900BTN",.F.,.F.)
	If ValType(aButtonUsr) <> "A"
		aButtonUsr := Nil
	EndIf
EndIf

AxVisual(cAlias,nReg,nOpc, , , , ,aButtonUsr )

Return


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A900Inclui� Autor �   Henry Fila          � Data �03/09/02  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Inclusao dos Livros Fiscais                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function A900Inclui(cAlias,nReg,nOpc)

Local aButtonUsr 	:={}  
Local nOpcA			:=1
Local lAviso		:=.T.

If cPaisLoc<>"BOL"
	lAviso	:=If(nInclui==1,.F.,.T.)

	If !FisChkDt(dDataBase)
		Return
	Endif
			                 
	If lAviso
		nOpcA	:= Aviso("Atencao",STR0010,{"Sim","Nao"},3)
		lAviso	:= .F.
	Endif	
	
	If nOpcA == 1
		If ExistBlock("MA900BTN")
			aButtonUsr := ExecBlock("MA900BTN",.F.,.F.)
			If ValType(aButtonUsr) <> "A"
				aButtonUsr := Nil
			EndIf                                                  
		EndIf                                       
		nInclui	:=AxInclui(cAlias,nReg,nOpc, , , ,"A900TudOK()", , ,aButtonUsr)
		
		//-- Executa integra��o do Datasul
		If FindFunction("TMSAE76")
			TMSAE76()
		EndIf	
	Endif
Else
	AxInclui(cAlias,nReg,nOpc, , , ,"A900TudOK()", , ,aButtonUsr)
EndIf
Return


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A900Altera� Autor �   Marcos Simidu       � Data �05/06/97  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Alteracao dos Livros Fiscais                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A900Altera(cAlias,nReg,nOpc)
Local dData:=cTod(space(8))
Local aButtonUsr:= {}
Local cCfopAnt := Alltrim((cAlias)->F3_CFO)
Local cEntSai	:=	""
Local cCliefor	:=	""
Local cLoja		:=	""
Local cSerie	:=	""
Local cNota		:=	""

If cPaisLoc<>"BOL"

	If Val(substr(SF3->F3_CFO,1,1))>=5
		dData:=SF3->F3_EMISSAO
	Else
		dData:=SF3->F3_ENTRADA
	Endif
	
	If FisChkDt(dData)
		If Aviso("Atencao",STR0011,{"Sim","Nao"},3) ==1
			If ExistBlock("MA900BTN")
				aButtonUsr := ExecBlock("MA900BTN",.F.,.F.)
				If ValType(aButtonUsr) <> "A"
					aButtonUsr := Nil
				EndIf
			EndIf
		
			If AxAltera(cAlias,nReg,nOpc,,,,,"A900TudOK()",,,aButtonUsr) == 1
			                                                
							
				//�����������������������������������������������������������������������������������������Ŀ
				//�Rodrigo Aguilar - 28/05/2012                                                             �
				//�                                                                                         �
				//�Quando o cliente altera a chave da NFe a mesma se aplica a todos os itens, sendo         �
				//�assim deve-se atualizar a tabela SFT, campo FT_CHVNFE com o conte�do gravado             �
				//�na SF3, afinal, nao podem existir em um documento duas chaves diferentes.                �
				//�                                                                                         �
				//�O tratamento acima foi necessario para que astabelas SF3 e SFT fiquem igualmente gravadas�
				//�com a chave do documento fiscal                                                          �
				//�������������������������������������������������������������������������������������������
				cEntSai		:=	Iif (Left((cAlias)->F3_CFO, 1)>="5", "S", "E")    
				cCliefor	:=	(cAlias)->F3_CLIEFOR       
				cLoja		:=	(cAlias)->F3_LOJA  
				cSerie		:=	(cAlias)->F3_SERIE    
				cNota		:=	(cAlias)->F3_NFISCAL        
															
				DbSelectArea("SFT")
				SFT->(DbSetOrder(3))
				If SFT->(DbSeek(xFilial("SFT")+cEntSai+cCliefor+cLoja+cSerie+cNota))
					Do While SFT->(!Eof()) .And. SFT->(xFilial("SFT")+FT_TIPOMOV+FT_CLIEFOR+FT_LOJA+FT_SERIE+FT_NFISCAL) == ;
													( xFilial("SFT")+cEntSai+cCliefor+cLoja+cSerie+cNota )
													
						RecLock("SFT",.F.)   						
							SFT->FT_CHVNFE := (cAlias)->F3_CHVNFE							
						SFT->(MsUnLock ())
						SFT->(FkCommit ())
						
						SFT->(DbSkip())
					EndDo
				EndIf
				
			EndIf
			If Val(cCfopAnt) <> Val((cAlias)->F3_CFO)
				A900AtuBas(cCfopAnt)
			Endif
			//�������������������������������������������������������������������������������������������Ŀ
			//�Verifica se a data foi alterada para alterar os registros relacionados (SF1/SD1 ou SF2/SD2)�
			//���������������������������������������������������������������������������������������������
			If dData <> (cAlias)->F3_ENTRADA
				A900AtuBas("")
			Endif
		Endif
	Endif
Else
		AxAltera(cAlias,nReg,nOpc,,,,,"A900TudOK()",,,aButtonUsr)
EndIf	
Return
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A900Deleta� Autor � Gilson do Nascimento  � Data �16/02/93  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de exclusao dos   Livros Fiscais                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A900Deleta(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A900Deleta(cAlias,nReg,nOpc)
//�����������������������Ŀ
//� Define Variaveis      �
//�������������������������
LOCAL nOpcA:=0, oDlg, cCod, aAC:= {STR0007,STR0008} //"Abandona"###"Confirma"
Local dData:=cTod(space(8))
Local aButtonUsr:= {}
Local cTipMov   := Iif (Left (SF3->F3_CFO, 1)>="5", "S", "E")
Local aInfo     := {}
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := MsAdvSize() 
Local nGd1      := 2
Local nGd2 		:= 2
Local nGd3 		:= 0
Local nGd4 		:= 0
//���������������������������������������Ŀ
//� Monta a entrada de dados do arquivo   �
//�����������������������������������������
Private aTELA[0][0],aGETS[0]

aObjects := {} 
AAdd( aObjects, {100, 100, .t., .t. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
aPosObj := MsObjSize( aInfo, aObjects )

nGd1 := 2
nGd2 := 2
nGd3 := aPosObj[1,3]-aPosObj[1,1]
nGd4 := aPosObj[1,4]-aPosObj[1,2]

If cPaisLoc<>"BOL"

	//��������������������������������������������������������������Ŀ
	//� Verifica ultima data para operacoes fiscais                  �
	//����������������������������������������������������������������
	If Val(substr(SF3->F3_CFO,1,1))>=5
		dData:=SF3->F3_EMISSAO
	Else
		dData:=SF3->F3_ENTRADA
	Endif
	
	If !FisChkDt(dData)
		Return
	Endif
	
	If Aviso("Atencao",STR0012,{"Sim","Nao"},3) ==1
		If ExistBlock("MA900BTN")
			aButtonUsr := ExecBlock("MA900BTN",.F.,.F.)
			If ValType(aButtonUsr) <> "A"
				aButtonUsr := Nil
			EndIf
		EndIf
		
		dbSelectArea(cAlias)
		
		DEFINE MSDIALOG oDlg TITLE cCadastro FROM nGd1,nGd2 TO nGd3,nGd4 OF oMainWnd PIXEL
		nOpcA:=EnChoice( cAlias, nReg, nOpc, ,"AC",STR0009, , aPosObj[1], , 3) //"Quanto � exclus�o?"
		nOpca:=1
		oDlg:lMaximized := .T.
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()},,aButtonUsr)
		
		dbSelectArea(cAlias)
		
		IF nOpcA == 2
			//���������������������������������������������������������������Ŀ
			//� Verifica se ainda existe NF no SF1 ou SF2, devera' ser APAGADA�
			//�����������������������������������������������������������������
			cAliasArq := iif(val(substr(SF3->F3_CFO,1,1))>=5,"SD2","SD1")
			cBusca    := SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA
			dbSelectArea(cAliasArq)
			dbSetOrder(1)
			dbSeek(F3Filial(cAliasArq)+cBusca) //cFilial
			
			Begin Transaction
				//����������������������Ŀ
				//� Deleta o registro SF3�
				//������������������������
				dbSelectArea(cAlias)
				If ExistBlock("MA900DEL")
					ExecBlock("MA900DEL",.F.,.F.)
				Else
					//��������������������������������������������������������������������Ŀ
					//�Tratamento de exclusao do SFT quando esta tabela estiver habilitada.�
					//����������������������������������������������������������������������
					
						DbSelectArea ("SFT")
						SFT->(DbSetOrder(3))
						If (SFT->(DbSeek (xFilial ("SFT")+cTipMov+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_SERIE+SF3->F3_NFISCAL+SF3->F3_IDENTFT)))
							Do While !SFT->(Eof ()) .And.;
								xFilial ("SFT")+cTipMov+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_SERIE+SF3->F3_NFISCAL+SF3->F3_IDENTFT==;
								xFilial ("SFT")+SFT->FT_TIPOMOV+SFT->FT_CLIEFOR+SFT->FT_LOJA+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_IDENTF3
								M926DlSped(2,SFT->FT_NFISCAL,SFT->FT_SERIE,SFT->FT_CLIEFOR,SFT->FT_LOJA,SFT->FT_TIPOMOV,SFT->FT_ITEM,SFT->FT_PRODUTO)
								RecLock ("SFT", .F., .T.)
								SFT->(DbDelete ())
								MsUnlock ()
							
								SFT->(DbSkip ())
							EndDo
						EndIf
							
					dbSelectArea(cAlias)
					If cAlias == "SF3"
						M926DlSped(1,SF3->F3_NFISCAL,SF3->F3_SERIE,SF3->F3_CLIEFOR,SF3->F3_LOJA,SF3->F3_CFO)
					Endif
					RecLock(cAlias,.F.,.T.)
					dbDelete()
					MsUnlock()
				EndIf
				
			End Transaction
		Else
			MsUnLock()
		Endif	
		
		dbSelectArea(cAlias)
	Endif
Else
   
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM nGd1,nGd2 TO nGd3,nGd4 OF oMainWnd PIXEL
	nOpcA:=EnChoice( cAlias, nReg, nOpc, ,"AC",STR0009, , aPosObj[1], , 3 ) //"Quanto � exclus�o?"
	nOpca:=1
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()},,aButtonUsr)
	
	dbSelectArea(cAlias)
	
	IF nOpcA == 2
		Begin Transaction
		//����������������������Ŀ
		//� Deleta o registro SF3�
		//������������������������
		RecLock(cAlias,.F.,.T.)
		dbDelete()
		MsUnlock()
		End Transaction
	Else
		MsUnLock()
	Endif	
	
	dbSelectArea(cAlias)

EndIf	
Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A900AtuBas� Autor � Sergio S. Fuzinaka    � Data � 09/08/05 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Atualiza as Tabelas SD1 ou SD2, quando o Cfop for alterado  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function A900AtuBas(cCfop)

Local aArea := GetArea()
Local cSeek := SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA
Local cChave := "E"+SF3->F3_SERIE+SF3->F3_NFISCAL+SF3->F3_CLIEFOR+SF3->F3_LOJA
If !Empty(cCfop)
	// Alteracao do CFOP nos itens
	If Left(cCfop,1) >= "5" .And. Left(Alltrim(SF3->F3_CFO),1) >= "5"		//Saida
		dbSelectArea("SD2")
		dbSetOrder(3)
		If dbSeek(xFilial("SD2")+cSeek)
			While !Eof() .And. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == xFilial("SD2")+cSeek
				If Val(SD2->D2_CF) == Val(cCfop)
					RecLock("SD2",.F.)
					SD2->D2_CF := SF3->F3_CFO
					MsUnlock()
				Endif
				dbSkip()
			Enddo
		Endif
		dbSelectArea("SFT")
		dbSetOrder(6)
		If dbSeek(xFilial("SFT")+"S"+cSeek)
			While !Eof() .And. SFT->FT_FILIAL+SFT->FT_TIPOMOV+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA == xFilial("SFT")+"S"+cSeek
				If Val(SFT->FT_CFOP) == Val(cCfop)
					RecLock("SFT",.F.)
					SFT->FT_CFOP := SF3->F3_CFO
					MsUnlock()
				Endif
				dbSkip()
			Enddo
		EndIf
	ElseIf Left(cCfop,1) < "5" .And. Left(Alltrim(SF3->F3_CFO),1) < "5"	//Entrada
		dbSelectArea("SD1")
		dbSetOrder(1)
		If dbSeek(xFilial("SD1")+cSeek)
			While !Eof() .And. SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == xFilial("SD1")+cSeek
				If Val(SD1->D1_CF) == Val(cCfop)
					RecLock("SD1",.F.)
					SD1->D1_CF := SF3->F3_CFO
					MsUnlock()
				Endif
				dbSkip()
			Enddo
		Endif
		dbSelectArea("SFT")
		dbSetOrder(6)
		If dbSeek(xFilial("SFT")+"E"+cSeek)
			While !Eof() .And. SFT->FT_FILIAL+SFT->FT_TIPOMOV+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA == xFilial("SFT")+"E"+cSeek
				If Val(SFT->FT_CFOP) == Val(cCfop)
					RecLock("SFT",.F.)
					SFT->FT_CFOP := SF3->F3_CFO
					MsUnlock()
				Endif
				dbSkip()
			Enddo
		EndIf
	Endif
Else                              
	// Alteracao da data de entrada nos itens e cabecalho
	If Left(SF3->F3_CFO,1) < "5"
		dbSelectArea("SF1")
		dbSetOrder(1)
		If dbSeek(xFilial("SF1")+cSeek)
			While !Eof() .And. SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == xFilial("SF1")+cSeek
				RecLock("SF1",.F.)
				SF1->F1_DTDIGIT := SF3->F3_ENTRADA
				MsUnlock()
				dbSkip()
			Enddo
		Endif     
						
	
		dbSelectArea("SD1")
		dbSetOrder(1)
		If dbSeek(xFilial("SD1")+cSeek)
			While !Eof() .And. SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == xFilial("SD1")+cSeek
				RecLock("SD1",.F.)
				SD1->D1_DTDIGIT := SF3->F3_ENTRADA
				MsUnlock()
				dbSkip()
			Enddo
		Endif
		
		dbSelectArea("SFT")
		dbSetOrder(1)
		If dbSeek(xFilial("SFT")+cChave)
			While !Eof() .And. SFT->FT_FILIAL+SFT->FT_TIPOMOV+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA == xFilial("SFT")+cChave
				RecLock("SFT",.F.)
		   		SFT->FT_ENTRADA := SF3->F3_ENTRADA
				MsUnlock()
				dbSkip()
			Enddo
		Endif     
	Endif
Endif

RestArea(aArea)

Return Nil


/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Marco Bianchi         � Data �01/09/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados           ���
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
Private	aRotina :={}
If cPaisLoc=="BOL"
	aRotina := {	{ STR0001,"AxPesqui"	, 0 , 1,0,.F.},; // "Pesquisar"
						{ STR0002,"A900Visual"	, 0 , 2,0,NIL},; // "Visualizar"
						{ STR0003,"A900Inclui"	, 0 , 3,0,NIL},; // "Incluir"
						{ STR0004,"A900Altera"	, 0 , 4,0,NIL},; // "Alterar"
						{ STR0005,"A900Deleta"	, 0 , 5,0,NIL} } // "Excluir"

Else

	aRotina := {	{ STR0001,"AxPesqui"	, 0 , 1,0,.F.},; // "Pesquisar"
						{ STR0002,"A900Visual"	, 0 , 2,0,NIL},; // "Visualizar"
						{ STR0003,"A900Inclui"	, 0 , 3,0,NIL},; // "Incluir"
						{ STR0004,"A900Altera"	, 0 , 4,0,NIL},; // "Alterar"
						{ STR0013,"MATA917"		, 0 , 6,0,NIL},;	// "Por Item"
						{ STR0014,"MATA968"		, 0 , 6,0,NIL},;	// "Ger. Lanc. Fiscais"
						{ STR0005,"A900Deleta"	, 0 , 5,0,NIL} } // "Excluir"
EndIf



If ExistBlock("MA900MNU")
	ExecBlock("MA900MNU",.F.,.F.)
EndIf

Return(aRotina)

