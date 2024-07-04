#INCLUDE "TMSA080.ch"
#INCLUDE "PROTHEUS.ch"

Static aFolder

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa   �  TMSA080   � Autor �        Nava        � Data � 18/10/01 ���
��������������������������������������������������������������������������͹��
���             Tabela de Tarifa                                           ���
��������������������������������������������������������������������������͹��
��� Sintaxe    � TMSA080()                                                 ���
��������������������������������������������������������������������������͹��
��� Parametros � Nenhum                                                    ���
��������������������������������������������������������������������������͹��
��� Retorno    � NIL                                                       ���
��������������������������������������������������������������������������͹��
��� Uso        � SigaTMS - Gestao de Transportes                           ���
��������������������������������������������������������������������������͹��
��� Comentario � Estrutura do Array de Folders                             ���
���            �                                                           ���
���            � [1] -> Tipo "N" , Numero do Folder                        ���
���            � [2] -> Tipo "C" , Titulo do Folder                        ���
���            � [3] -> Tipo "A" , aColsRecno ( Recno() de cada aCols )    ���
���            � [4] -> Tipo "A  , aHeader   da GetDados do Folder         ���
���            � [5] -> Tipo "A" , aCols     da GetDados do Folder         ���
���            � [6] -> Tipo "C" , cLinhaOk  da GetDados do Folder         ���
���            � [7] -> Tipo "C" , cTudoOk   da GetDados do Folder         ���
���            � [8] -> Tipo "O" , oGetDados deste Folder                  ���
���            �                                                           ���
���            � Possui 2 pontos de Entrada TMSA080A e TMSA080B            ���
��������������������������������������������������������������������������͹��
���          Atualizacoes efetuadas desde a codificacao inicial            ���
��������������������������������������������������������������������������͹��
���Programador �  Data  � BOPS �             Motivo da Alteracao           ���
��������������������������������������������������������������������������͹��
���            �xx/xx/02�xxxxxx�                                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
FUNCTION TMSA080(nRotina)

//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������

Local aSavARot := IF( Type("aRotina")  !="U",aRotina,	{}	)
Local cSavcCad := IF( Type("cCadastro")!="U",cCadastro,"" )
Local aArea	   := GetArea()

Private cCadastro := STR0001 //"Tabela de Tarifa"
Private aRotina   := MenuDef()
Private aLayOut   := {}

If	aFolder == Nil
	aFolder := {}
EndIf

// Carrega LayOut da Tabela
aLayOut := TMSLayOutTab( , .T.,,{"15"})
If Len(aLayOut)==0
   Return .F.
EndIf
RestArea(aArea)

If nRotina != Nil
	TMSA080Mnt("DTF",DTF->(RecNo()),nRotina)
Else
	Mbrowse( 6, 1, 22, 75, "DTF")
EndIf

//��������������������������������������������������������������Ŀ
//�Restaura os dados de entrada                                  �
//����������������������������������������������������������������
RestArea( aArea )
aRotina   := aSavARot
cCadastro := cSavcCad

RETURN NIL

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa   �  TMSA080   � Autor �        Nava        � Data � 18/10/01 ���
��������������������������������������������������������������������������͹��
���             Manutencao da Tabela de Tarifa                             ���
��������������������������������������������������������������������������͹��
��� Sintaxe    �  TMSA080Mnt( cAlias, nReg, nOpcx )                        ���
��������������������������������������������������������������������������͹��
��� Parametros �                                                           ���
���         01 � cAlias - Alias do arquivo                                 ���
���         02 � nReg   - Registro do Arquivo                              ���
���         03 � nOpcx  - Opcao da MBrowse                                 ���
��������������������������������������������������������������������������͹��
��� Retorno    � NIL                                                       ���
��������������������������������������������������������������������������͹��
��� Uso        � SigaTMS - Gestao de Transportes                           ���
��������������������������������������������������������������������������͹��
��� Comentario �                                                           ���
���            �                                                           ���
��������������������������������������������������������������������������͹��
���          Atualizacoes efetuadas desde a codificacao inicial            ���
��������������������������������������������������������������������������͹��
���Programador �  Data  � BOPS �             Motivo da Alteracao           ���
��������������������������������������������������������������������������͹��
���            �xx/xx/02�xxxxxx�                                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

Function TMSA080Mnt(cAlias,nReg,nOpcx)

Local aArea     := GetArea()
Local aInfo     := {}
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := MsAdvSize()
Local lDTLDESCRI:= DTL->(FieldPos("DTL_DESCRI"))>0

Local aTitles   := {}
Local aPages    := {}

Local nGd1      := 0 
Local nGd2      := 0 
Local nGd3      := 0 
Local nGd4      := 0 
Local nLoop     := 0 

Local oDlg
Local oFolder
Local oEnchoice
Local lTudoOk

Private nFolder  := 1
Private aHeader  := {}
Private aCols    := {}
Private aGets    := {}
Private aTela    := {}
Private aHeadDW0 := {}
Private aColsDW0 := {}
Private aSetKey  := {}

// Excedente por Subfaixa
Private aHeadDY0 := {}
Private aColsDY0 := {}

//������������������Ŀ
//� Verifica Folders �
//��������������������
DT3->( DbGoTop() )
If DT3->( Eof() )
	HELP(" ",1,"TMSA08002") //"Inclua ao menos 1 Registro na Configuracao de Folders"
	Return .F.
EndIf

//������������������������������������������������������Ŀ
//� Define as posicoes da Getdados a partir do folder    �
//��������������������������������������������������������

aObjects := {	{ 100, 045, .T., .T. },;
				{ 100, 100, .T., .T. } }
aInfo    := { aSize[1], aSize[2], aSize[3], aSize[4], 5, 5 } 
aPosObj  := MsObjSize( aInfo, aObjects, .T. ) 

nGd1 := 2
nGd2 := 2
nGd3 := aPosObj[2,3]-aPosObj[2,1]-15 
nGd4 := aPosObj[2,4]-aPosObj[2,2]-4 

//������������������Ŀ
//� Carrega Enchoice �
//��������������������
RegToMemory( "DTF", nOpcx == 3 )

//��������������������������������������������������Ŀ
//� Escolhe a Configuracao da Tabela se for Inclusao �
//����������������������������������������������������
If nOpcx == 3
	If !TMSABrowse( aLayOut, STR0024 ,,,,.T., { STR0025 , STR0026, STR0032 } ) //"Escolha a Configura��o desta Tabela de Tarifa" ### "Tabela de Frete" ### "Tipo"###"Descricao"
		Return .F.
	EndIf
	nLoop := Ascan( aLayOut, { |aItem| aItem[1] == .T. } )
	M->DTF_TABFRE := Left( aLayOut[ nLoop ][2], 4 )
	M->DTF_TIPTAB := Left( aLayOut[ nLoop ][3], 2 )
	M->DTF_DESTIP := Tabela("M5", M->DTF_TIPTAB,.F.)
	
	If lDTLDESCRI
		M->DTF_DESTAB := Posicione('DTL',1,xFilial('DTL')+M->DTF_TABFRE+M->DTF_TIPTAB,'DTL_DESCRI')
	EndIf	
		
	If DTL->(FieldPos('DTL_MOEDA')) > 0
		M->DTF_MOEDA := Posicione('DTL',1,xFilial('DTL')+M->DTF_TABFRE+M->DTF_TIPTAB,'DTL_MOEDA')
		If	M->DTF_MOEDA == 0
			M->DTF_MOEDA := 1
		EndIf
	EndIf
EndIf

//������������������Ŀ
//� Carrega Folder   �
//��������������������
TMSA080Fol( nOpcx )

//�������������������������Ŀ
//� Adiciona Titles e Pages �
//���������������������������
Aeval( aFolder, { | aFolderLine | 	Aadd( aTitles, aFolderLine[2] ), Aadd( aPages,  "AHEADER" ) } )

//������������������Ŀ
//�Montagem da Tela  �
//��������������������
DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],00 To aSize[6],aSize[5] OF oMainWnd PIXEL 

//������������������Ŀ
//� Desenha Enchoice �
//��������������������
oEnchoice := MsMGet():New( cAlias ,nReg, nOpcx, , , , , aPosObj[1], , 3,,,,,, .T. )

//������������������Ŀ
//� Desenha Folders  �
//��������������������
oFolder := TFolder():New(	aPosObj[2,1],aPosObj[2,2],aTitles,aPages, oDlg,,,,.T.,.F.,;
							aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])

//������������������������������������������������������Ŀ
//� Carrega as GetDados na Ordem INVERSA de Apresentacao �
//��������������������������������������������������������
For nLoop := Len( aFolder ) To 1 Step - 1 
	aHeader := aClone( aFolder[nLoop][4] )
	//���������������������������������������������������������������������������Ŀ
	//� Inicializa o campo "Item" da GetDados com "01"                            �
	//�����������������������������������������������������������������������������
	aEval(aFolder[nLoop][5], {|x| IIF( Empty(x[GdFieldPos('DTG_ITEM')]), x[GdFieldPos('DTG_ITEM')]:= StrZero(1, Len(DTG->DTG_ITEM)), .T.) })
	aCols   := aClone( aFolder[nLoop][5] )
			
	aFolder[nLoop][8] := MSGetDados():New(	nGd1,nGd2,nGd3,nGd4,nOpcx,;
															aFolder[nLoop][6],aFolder[nLoop][7],"+DTG_ITEM",nOpcx!=2, , , ,If(nOpcx==5,Len(aCols),999),,,,,;
															oFolder:aDialogs[nLoop]	)

	If nLoop == 1
		aFolder[nLoop][8]:oBrowse:lDisablePaint := .F.
	Else
		aFolder[nLoop][8]:oBrowse:lDisablePaint := .T.	
	EndIf

	//�����������������������������Ŀ
	//� Acerta OBRIGAT da MsGetDados�
	//�������������������������������
	TMSObgGetDados( aFolder[nLoop][8] )

NEXT nI	

//������������������������������Ŀ
//� Habilita o Trocador de Folder�
//��������������������������������
oFolder:bSetOption:={|nAtu| TMSA080Chg( nAtu, oFolder:nOption ) }

//�����������������������������������Ŀ
//� Chama Localizador de Folder Ativo �
//� Desenha a EnchoiceBar             �
//� Ativa Obrigat da Enchoice         �
//� Ativa Obrigat das GetDados        �
//� Ativa Dialog  Principal           �
//�������������������������������������
ACTIVATE MSDIALOG oDlg ON INIT ( TMSA080Loc( nOpcx, oFolder ),; 
											TMSA080Bar( oDlg, { ||	lTudoOk := ( 	nOpcx != 2 .And. ;
																								Obrigatorio(aGets,aTela) .And.;
																								TMSA080Ok(oFolder:nOption, nOpcx) ),;
																			IF( lTudoOk .Or. nOpcx == 2, oDlg:End(), NIL ) },;
															{|| oDlg:End() }, nOpcx ) )
If ( lTudoOk )
	Begin Transaction
		//-- Efetua a Gravacao
		TMSA080Grv( nOpcx )
		If ( __lSX8 )
			ConfirmSX8()
		EndIf
		EvalTrigger()
	End Transaction
Else
	If ( __lSX8 )
		RollBackSX8()
	EndIf
EndIf

//������������������������������������������������������Ŀ
//�Restaura a integridade dos dados                      �
//��������������������������������������������������������
MsUnLockAll()
RestArea(aArea)

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

Return NIL

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa   �  TMSA080   � Autor �        Nava        � Data � 18/10/01 ���
��������������������������������������������������������������������������͹��
���             Troca de Folder                                            ���
��������������������������������������������������������������������������͹��
��� Sintaxe    �  TMSA080Chg( nTargetFolder, nSourceFolder )               ���
��������������������������������������������������������������������������͹��
��� Parametros �                                                           ���
���         01 � nTargetFolder - Folder Destino                            ���
���         02 � nSourceFolder - Folder Atual                              ���
��������������������������������������������������������������������������͹��
��� Retorno    � .T. se a Troca de Folder foi permitida                    ���
��������������������������������������������������������������������������͹��
��� Uso        � SigaTMS - Gestao de Transportes                           ���
��������������������������������������������������������������������������͹��
��� Comentario � Checa a validacao da Getdados Atual e copia corretamente  ���
���            � aHeader e Acols dos Folders Atual e Destino               ���
��������������������������������������������������������������������������͹��
���          Atualizacoes efetuadas desde a codificacao inicial            ���
��������������������������������������������������������������������������͹��
���Programador �  Data  � BOPS �             Motivo da Alteracao           ���
��������������������������������������������������������������������������͹��
���            �xx/xx/02�xxxxxx�                                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function TMSA080Chg( nTargetFolder, nSourceFolder )

Local nI
Local lRetorno
Local lEmpty	:= .F.

//���������������������������������Ŀ
//� Se a GetDados nao esta deletada �
//�����������������������������������

If !Acols[1][Len(aHeader)+1]

	//������������������������������������������������Ŀ
	//� Verifica se os campos obrigatorios estao vazios�
	//��������������������������������������������������

	Aeval( aFolder[nSourceFolder][8]:aPosCol, { |aPosCol| 	IF ( !lEmpty .And. ;
															Empty( aCols[1][aPosCol[2]] ), ;
															lEmpty := .T.	, NIL ) } )
	//���������������������������������������������������Ŀ
	//� Se TODOS estiverem vazios e nao sofre modificacao �
	//� deleta para passar no 'OBRIGAT'                   �
	//�����������������������������������������������������

	If lEmpty .And. ! aFolder[nSourceFolder][8]:lChgField
		aCols[1][Len(aHeader)+1] := .T.
	EndIf
EndIf

//��������������������������������Ŀ
//� Efetua a Validacao da GetDados �
//����������������������������������

If ( lRetorno := aFolder[nSourceFolder][8]:TudoOk() )

	aFolder[nSourceFolder][8]:oBrowse:lDisablePaint := .T.

	//������������������������������������������������������Ŀ
	//� Grava aHeader e Acols do Afolder com as mudancas     �
	//��������������������������������������������������������
	aFolder[nSourceFolder][4] := aClone( aHeader )
	aFolder[nSourceFolder][5] := aClone( aCols )
	n := Max( aFolder[nTargetFolder][8]:oBrowse:nAt,1)

	//������������������������������������������������������Ŀ
	//� Grava aHeader e Acols a partir do aFolder            �
	//��������������������������������������������������������
	aHeader := aClone( aFolder[nTargetFolder][4] )
	aCols   := aClone( aFolder[nTargetFolder][5] )

	//������������������������������������������������Ŀ
	//� Verifica se os campos obrigatorios estao vazios�
	//��������������������������������������������������

   lEmpty := .F.
	Aeval( aFolder[nTargetFolder][8]:aPosCol, { |aPosCol| 	IF ( !lEmpty .And. ;
															Empty( aCols[1][aPosCol[2]] ), ;
															lEmpty := .T.	, NIL ) } )
	//���������������������������������������������������Ŀ
	//� Se TODOS estiverem vazios e nao sofre modificacao �
	//� dah RECALL porque esta funcao DELETOU !!          �
	//�����������������������������������������������������

	If	aCols[1][Len(aHeader)+1] .And. lEmpty .And. ;
		!aFolder[nTargetFolder][8]:lChgField
		aCols[1][Len(aHeader)+1] := .F.
	EndIf

	aFolder[nTargetFolder][8]:oBrowse:lDisablePaint := .F.
	aFolder[nTargetFolder][8]:oBrowse:Refresh(.T.)

	//����������������������������������������������������Ŀ
	//� Seta Variavel Private nFolder para o Folder Target �
	//������������������������������������������������������

	nFolder := nTargetFolder

EndIf

Return(lRetorno)

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa   �  TMSA080   � Autor �        Nava        � Data � 18/10/01 ���
��������������������������������������������������������������������������͹��
���             Gravacao da Enchoice e das GetDados dos Folders            ���
��������������������������������������������������������������������������͹��
��� Sintaxe    � TMSA080Grv( nOpcx )                                       ���
��������������������������������������������������������������������������͹��
��� Uso        � SigaTMS - Gestao de Transportes                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function TMSA080Grv(nOpcx)

Local nPosItDW0 := 0
Local nPosItem  := 0
Local nPos      := 0
Local nI        := 0
Local n1Cnt     := 0
Local n2Cnt     := 0
Local n3Cnt     := 0
Local aArea		 := GetArea()
Local bCampo    := { |nCpo| Field(nCpo) }
Local lSubFaixa := AliasInDic("DW0")
Local lSubExced := lSubFaixa .And. AliasInDic("DY0")

If nOpcx == 3 .Or. nOpcx == 4 //-- Inclusao ou Alteracao

	//-- Gravacao do cabecalho  
	RecLock('DTF',nOpcx==3)
	For nI := 1 TO FCount()
		If FieldName(nI) == 'DTF_FILIAL'
			FieldPut(nI,xFilial("DTF"))
		Else
			If Type('M->'+FieldName(nI)) <> 'U'
				FieldPut(nI,M->&(Eval(bCampo,nI)))
			EndIf
		EndIf
	Next nI
	MsUnLock()

	For n1Cnt := 1 To Len(aFolder)
		aHeader  := AClone(aFolder[n1Cnt,4])
		aCols    := AClone(aFolder[n1Cnt,5])
		nPosItem := GDFieldPos("DTG_ITEM")
		//-- Gravacao dos itens da tarifa
		For n2Cnt := 1 To Len(aCols)
			If !GdDeleted(n2Cnt)
				DTG->(DbSetOrder(1))
				If !DTG->(MsSeek(xFilial("DTG")+M->DTF_TABFRE+M->DTF_TIPTAB+M->DTF_TABTAR+aFolder[n1Cnt,1]+aCols[n2Cnt,nPosItem]))
					RecLock("DTG",.T.)
					DTG->DTG_FILIAL := xFilial("DTG")
					DTG->DTG_TABTAR := M->DTF_TABTAR
					DTG->DTG_TABFRE := M->DTF_TABFRE
					DTG->DTG_TIPTAB := M->DTF_TIPTAB
					DTG->DTG_CODPAS := aFolder[n1Cnt,1]
				Else
					RecLock("DTG",.F.)
				EndIf
				For nI := 1 To Len(aHeader)
					If aHeader[nI,10] != 'V'
						DTG->(FieldPut(FieldPos(aHeader[nI,2]),GDFieldGet(aHeader[nI,2],n2Cnt)))
					EndIf
				Next
				MsUnlock()
				//-- Gravacao das Sub-Faixas por item
				If lSubFaixa
					If (nPos:= Ascan( aColsDW0, { |x| x[1]+x[2] == aFolder[n1Cnt,1] + aCols[n2Cnt,nPosItem] } ) ) > 0
						nPosItDW0 := GDFieldPos("DW0_ITEM",aColsDW0[nPos,4])
						For n3Cnt := 1 To Len(aColsDW0[nPos,3])
							cItem := aColsDW0[nPos,3,n3Cnt,nPosItDW0]
							If !GdDeleted(n3Cnt,aColsDW0[nPos,4],aColsDW0[nPos,3])
								DW0->(DbSetOrder(1))
								If !DW0->(MsSeek(xFilial("DW0")+M->DTF_TABFRE+M->DTF_TIPTAB+M->DTF_TABTAR+aFolder[n1Cnt,1]+aCols[n2Cnt,nPosItem]+cItem))
									RecLock("DW0",.T.)
									DW0->DW0_FILIAL := xFilial("DW0")
									DW0->DW0_TABTAR := M->DTF_TABTAR
									DW0->DW0_TABFRE := M->DTF_TABFRE
									DW0->DW0_TIPTAB := M->DTF_TIPTAB
									DW0->DW0_CODPAS := aFolder[n1Cnt,1]
									DW0->DW0_ITEDTG := aCols[n2Cnt,nPosItem]
								Else
									RecLock("DW0",.F.)
								EndIf
								For nI := 1 To Len(aColsDW0[nPos,4])
									If aColsDW0[nPos,4,nI,10] != 'V'
										DW0->(FieldPut(FieldPos(aColsDW0[nPos,4,nI,2]),GDFieldGet(aColsDW0[nPos,4,nI,2],n3Cnt,,aColsDW0[nPos,4],aColsDW0[nPos,3])))
									EndIf
								Next
								MsUnlock()
							Else
								DW0->(DbSetOrder(1))
								If DW0->(MsSeek(xFilial("DW0")+M->DTF_TABFRE+M->DTF_TIPTAB+M->DTF_TABTAR+aFolder[n1Cnt,1]+aCols[n2Cnt,nPosItem]+cItem))
									RecLock("DW0",.F.)
									DW0->(DbDelete())
									MsUnlock()
								EndIf
							EndIf
						Next n3Cnt

						// Excedente por Subfaixa
						// Aqui deve ser gravado o Excedente para cada componente do DW0, na tabela DY0
						if lSubExced
							cChave := aFolder[n1Cnt,1] + aCols[n2Cnt,nPosItem]
							if (nPosDY0:= Ascan( aColsDY0, { |x| x[1]+x[2] == cChave })) > 0
								// Se nao esta deletado e os valores obrigatorios estao preenchidos
								// Efetiva a gravacao na tabela DY0, senao exclui o registro da tabela
								// Se existir senao ignora o item do vetor
								If !GdDeleted(1,aColsDY0[nPosDY0,4],aColsDY0[nPosDY0,3])
									DY0->(DbSetOrder(1))
									If !DY0->(MsSeek(xFilial("DY0")+M->DTF_TABFRE+M->DTF_TIPTAB+M->DTF_TABTAR+cChave))
										RecLock("DY0",.T.)
										DY0->DY0_FILIAL := xFilial("DY0")
										DY0->DY0_TABTAR := M->DTF_TABTAR
										DY0->DY0_TABFRE := M->DTF_TABFRE
										DY0->DY0_TIPTAB := M->DTF_TIPTAB
										DY0->DY0_CODPAS := aFolder[n1Cnt,1]
										DY0->DY0_ITEDTG := aCols[n2Cnt,nPosItem]
									Else
										RecLock("DY0",.F.)
									EndIf
									For nI := 1 To Len(aColsDY0[nPosDY0,4])
										If aColsDY0[nPosDY0,4,nI,10] != 'V'
											DY0->(FieldPut(FieldPos(aColsDY0[nPosDY0,4,nI,2]),aColsDY0[nPosDY0,3,1,nI]))
										EndIf
									Next
									MsUnlock()
								Else
									// Excedente por Subfaixa
									// Exclusao do item de Excedente se foi marcado para exclusao ou se o valor estiver zerado
									DY0->(DbSetOrder(1))
									If DY0->(MsSeek(xFilial("DY0")+M->DTF_TABFRE+M->DTF_TIPTAB+M->DTF_TABTAR+cChave))
										RecLock("DY0",.F.)
										DY0->(DbDelete())
										MsUnlock()
									EndIf
								EndIf
						   EndIf
						EndIf
					EndIf
				EndIf
			Else
				//-- Exclusao das sub-faixas
				If lSubFaixa
					DW0->(DbSetOrder(1))
					If DW0->(MsSeek(xFilial("DW0")+M->DTF_TABFRE+M->DTF_TIPTAB+M->DTF_TABTAR+aFolder[n1Cnt,1]+aCols[n2Cnt,nPosItem]))
						// Excedente por Subfaixa
						// Exclusao de todos os excedentes das subfaixas
						If lSubExced
							DY0->(MsSeek(cChaveDY0 := xFilial("DY0")+M->DTF_TABFRE+M->DTF_TIPTAB+M->DTF_TABTAR+aFolder[n1Cnt,1]+aCols[n2Cnt,nPosItem]))
							Do While DY0->( ! Eof()) .And. cChaveDY0 == DY0->(xFilial("DY0")+DY0_TABFRE+DY0_TIPTAB+DY0_TABTAR+DY0_CODPAS+DY0_ITEDTG)
								RecLock("DY0",.F.)
								DY0->(DbDelete())
								MsUnlock()
								DY0->( Dbskip())
							Enddo
						EndIf
						While DW0->(!Eof()) .And. DW0->DW0_FILIAL + DW0->DW0_TABFRE + DW0->DW0_TIPTAB + DW0->DW0_TABTAR + DW0->DW0_CODPAS + DW0->DW0_ITEDTG == ;
							xFilial("DW0") + M->DTF_TABFRE + M->DTF_TIPTAB + M->DTF_TABTAR + aFolder[n1Cnt,1] + aCols[n2Cnt,nPosItem]
							RecLock("DW0",.F.)
							DW0->(DbDelete())
							MsUnlock()
							DW0->(DbSkip())
						EndDo
					EndIf
				EndIf
				//-- Exclusao do item da tarifa.
				DTG->(DbSetOrder(1))
				If DTG->(MsSeek(xFilial("DTG")+M->DTF_TABFRE+M->DTF_TIPTAB+M->DTF_TABTAR+aFolder[n1Cnt,1]+aCols[n2Cnt,nPosItem]))
					RecLock("DTG",.F.)
					DTG->(DbDelete())
					MsUnlock()
				EndIf
			EndIf
		Next n2Cnt
	Next n1Cnt
Else
	//-- Exclusao da tabela de tarifas
	DTG->(DbSetOrder(1))
	If DTG->(MsSeek(xFilial("DTG")+M->DTF_TABFRE+M->DTF_TIPTAB+M->DTF_TABTAR))
		While DTG->(!Eof()) .And. DTG->DTG_FILIAL + DTG->DTG_TABFRE + DTG->DTG_TIPTAB + DTG->DTG_TABTAR == xFilial("DTG") + M->DTF_TABFRE + M->DTF_TIPTAB + M->DTF_TABTAR

			//-- Exclusao das sub-faixas
			If lSubFaixa
				DW0->(DbSetOrder(1))
				If DW0->(MsSeek(xFilial("DW0")+M->DTF_TABFRE+M->DTF_TIPTAB+M->DTF_TABTAR))
	  				While DW0->(!Eof()) .And. DW0->DW0_FILIAL + DW0->DW0_TABFRE + DW0->DW0_TIPTAB + DW0->DW0_TABTAR == xFilial("DW0") + M->DTF_TABFRE + M->DTF_TIPTAB + M->DTF_TABTAR
						RecLock("DW0",.F.)
						DW0->(DbDelete())
						MsUnlock()
						DW0->(DbSkip())
					EndDo
				EndIf

				// Excedente por Subfaixa
				// Exclusao da Tabela - exclusao de todos os excedentes de todas as subfaixas
				If lSubExced
					DY0->(MsSeek(cChaveDY0 := xFilial("DY0")+M->DTF_TABFRE+M->DTF_TIPTAB+M->DTF_TABTAR))
					Do While DY0->( ! Eof()) .And. cChaveDY0 == DY0->(xFilial("DY0")+DY0_TABFRE+DY0_TIPTAB+DY0_TABTAR)
						RecLock("DY0",.F.)
						DY0->(DbDelete())
						MsUnlock()
						DY0->( Dbskip())
					Enddo
				EndIf
			EndIf

			RecLock("DTG",.F.)
			DTG->(DbDelete())
			MsUnlock()

			DTG->(DbSkip())
		EndDo
	EndIf
	//-- Exclusao do cabecalho
	RecLock('DTF',.F.)
	DTF->(DbDelete())
	MsUnLock()
EndIf

MsUnLockAll()
RestArea( aArea )

Return

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa   �  TMSA080   � Autor �        Nava        � Data � 18/10/01 ���
��������������������������������������������������������������������������͹��
���             Valida Linha da GetDados							   	   ���
��������������������������������������������������������������������������͹��
��� Sintaxe    �  TMSA080LinOk()                                           ���
��������������������������������������������������������������������������͹��
��� Parametros � Nenhum                                 			       ���
��������������������������������������������������������������������������͹��
��� Retorno    � .T. se a linha eh valida                                  ���
��������������������������������������������������������������������������͹��
��� Uso        � SigaTMS - Gestao de Transportes                           ���
��������������������������������������������������������������������������͹��
��� Comentario � Verifica se a Getdados possui INTERVALO de Tarifa jah     ���
���            � existente em outra linha, ou seja, se houve ENTRELACAMENTO���
��������������������������������������������������������������������������͹��
���          Atualizacoes efetuadas desde a codificacao inicial            ���
��������������������������������������������������������������������������͹��
���Programador �  Data  � BOPS �             Motivo da Alteracao           ���
��������������������������������������������������������������������������͹��
���            �xx/xx/02�xxxxxx�                                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

Function TMSA080LinOk()

Local lSeekUp		:= .F.
Local lSeekDown		:= .F.
Local lReturn		:= .F.
Local nPosValAte	:= Ascan( aHeader, { |aField| aField[2] = "DTG_VALATE" } )
Local nPosFatPes	:= Ascan( aHeader, { |aField| aField[2] = "DTG_FATPES" } )
Local nValAte		:= aCols[n][nPosValAte]
Local nValPes		:= If(nPosFatPes > 0, aCols[n][nPosFatPes], 0)

Do Case

	//������������������������������������������Ŀ
	//� Esta deletado                            �
	//��������������������������������������������

	Case 	aCols[n][Len( aHeader ) + 1]

			lReturn := .T.

	//������������������������������������Ŀ
	//� Na primeira linha Valida p/ baixo  �
	//��������������������������������������

	Case  n = 1
			lReturn := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ]	.And. ;
									(nValAte >= aLine[nPosValAte]	.Or.;
									 IIf(nPosFatPes >0, nValPes >= aLine[nPosFatPes],.F.) )}, 2 ) = 0
	//��������������������������������Ŀ
	//� Na ultima linha Valida p/ cima �
	//����������������������������������

	Case  n = Len( aCols )
			lReturn := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ]	.And. ;
										(nValAte <= aLine[nPosValAte]	.Or.;
										IIf(nPosFatPes >0, nValPes <= aLine[nPosFatPes],.F.) )}, 1, Len( Acols ) - 1 ) = 0

	Other

			//�����������������������Ŀ
			//� Valida Acima e Abaixo �
			//�������������������������

			lReturn := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ]	.And. ;
										(nValAte <= aLine[nPosValAte] .Or. ;
										IIf(nPosFatPes >0, nValPes <= aLine[nPosFatPes],.F.) ) } , 1, n - 1 ) = 0

			lReturn := lReturn .And. ;
						   Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ] .And. ;
										(nValAte >= aLine[nPosValAte] .Or.;
										IIf(nPosFatPes >0, nValPes >= aLine[nPosFatPes],.F.) )	}, n + 1 ) = 0
EndCase

If !lReturn
	HELP(" ",1,"TMSA08004") //"Campo Ate'/Fator Peso Invalido ou ja existente"
EndIf

If lReturn .And. !GdDeleted(n)
	If nPosFatPes >0 .And. GDFieldGet('DTG_FATPES',n) < GDFieldGet('DTG_VALATE',n)
		Help("", 1,"TMSA08005") //O campo "Fator Peso" esta menor do que o campo "Ate Peso"
		lReturn := .F.
	EndIf
	//-- Valida sub-faixa do componente.
	If lReturn
		If !GDDeleted(n) .And. !TMSA080Vd2(aFolder[nFolder,1],GDFieldGet('DTG_ITEM',n))
			Help("",1,"TMSA08009",,OemToAnsi(STR0020),1) //-- Nao foi informada a sub-faixa para o item.
			lReturn := .F.
		EndIf
	EndIf
EndIf

Return lReturn


/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa   �  TMSA080   � Autor �        Nava        � Data � 18/10/01 ���
��������������������������������������������������������������������������͹��
���             Valida Tudo antes da Gravacao                              ���
��������������������������������������������������������������������������͹��
��� Sintaxe    � TMSA080Ok( nSourceFolder )                                ���
��������������������������������������������������������������������������͹��
��� Parametros � nSourceFolder - Folder Atual                              ���
��������������������������������������������������������������������������͹��
��� Retorno    � .T. se a validacao foi aceita                             ���
��������������������������������������������������������������������������͹��
��� Uso        � SigaTMS - Gestao de Transportes                           ���
��������������������������������������������������������������������������͹��
��� Comentario � - Valida Folder a Folder comecando pelo atual             ���
���            � - Checa se existe PELO MENOS UM Folder preenchido         ���
��������������������������������������������������������������������������͹��
���          Atualizacoes efetuadas desde a codificacao inicial            ���
��������������������������������������������������������������������������͹��
���Programador �  Data  � BOPS �             Motivo da Alteracao           ���
��������������������������������������������������������������������������͹��
���            �xx/xx/02�xxxxxx�                                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function TMSA080Ok( nSourceFolder, nOpcx )

Local aAreaDT0	 := DT0->( GetArea() )
Local lReturn    := .F.
Local aSavHead   := aClone(aHeader)
Local aSavCols   := aClone(aCols)
Local nSavN      := N
Local nLoop      := 0
Local lEmpty     := .F.
Local nSavFolder := nFolder
Local cAliasNew  := ""
Local cQuery     := ""
Local cTabFre    := DTF->DTF_TABFRE
Local cTipTab    := DTF->DTF_TIPTAB
Local cTabTar    := DTF->DTF_TABTAR

If nOpcx == 5
	//-- Verifica se existe Tabela de Frete utilizando a Tabela de Tarifa a ser excluida
	cAliasNew := GetNextAlias()
	cQuery := " SELECT COUNT(*) DT0_COUNT"
	cQuery += " FROM "+RetSqlName("DT0")
	cQuery += " WHERE DT0_FILIAL = '"+xFilial("DT0")+"'"
	cQuery += "   AND DT0_TABFRE = '"+cTabFre+"'"
	cQuery += "   AND DT0_TIPTAB = '"+cTipTab+"'"
	cQuery += "   AND DT0_TABTAR = '"+cTabTar+"'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
	If	(cAliasNew)->DT0_COUNT > 0
		Help( ' ', 1, 'TMSA08001',,STR0016 + DTF->DTF_TABFRE +'/'+ DTF->DTF_TIPTAB,5,1)	//-- Tabela de tarifa em uso pela tabela de frete.	//'Tab.Frete : '
		DbCloseArea()
		RestArea( aAreaDT0 )
		Return( .F. )
	EndIf
	DbCloseArea()
	RestArea( aAreaDT0 )
EndIf

//������������������������������������������������������Ŀ
//� Verifica se existe algum campo obrigatorio em Branco �
//��������������������������������������������������������
Aeval( aFolder[nSourceFolder][8]:aPosCol, { |aPosCol| 	If ( !lEmpty .And. ;
														Empty( aCols[1][aPosCol[2]] ), ;
														lEmpty := .T.	, NIL ) } )
//�����������������������������������������������Ŀ
//� Se estah vazio e nao sofreu modificacao deleta�
//�������������������������������������������������
If lEmpty .And. ! aFolder[nSourceFolder][8]:lChgField
	aCols[1][Len(aHeader)+1] := .T.
EndIf

lEmpty := .T.

If (aFolder[nSourceFolder][8]:TudoOk() ) 

	aFolder[nSourceFolder][4] := aClone( aHeader )
	aFolder[nSourceFolder][5] := aClone( aCols )
	n := Max(aFolder[nSourceFolder][8]:oBrowse:nAt,1)

	lEmpty  := IF( lEmpty, Ascan( aCols, { |e| e[Len(e)] == .F. } ) = 0, lEmpty )

	lReturn := .T.

	For nLoop := 1 To Len( aFolder )

		If nLoop == nSourceFolder
			LOOP
		EndIf
		
		aHeader := aClone( aFolder[nLoop][4] )
		aCols   := aClone( aFolder[nLoop][5] )
		n       := Max(aFolder[nLoop][8]:oBrowse:nAt,1)
		nFolder := nLoop

		If !( aFolder[nLoop][8]:TudoOk() ) 
			lReturn := .F.
			Exit
		Else
			lEmpty  := IF( lEmpty, Ascan( aCols, { |e| e[Len(e)] == .F. }  ) = 0, lEmpty )
		EndIf

	Next nLoop

EndIf

If lReturn .And. lEmpty
	HELP(" ",1,"TMSA08003") //"Todos os Folder estao vazios !!"
	lReturn := .F.
EndIf

aHeader := aClone(aSavHead)
aCols   := aClone(aSavCols)
N       := nSavN
nFolder := nSavFolder

Return( lReturn )

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa   �  TMSA080   � Autor �        Nava        � Data � 18/10/01 ���
��������������������������������������������������������������������������͹��
���             Enchoice bar especifica                                    ���
��������������������������������������������������������������������������͹��
��� Sintaxe    � TMSA080Bar( oDlg, bOk, bCancel, nOpc )                    ���
��������������������������������������������������������������������������͹��
��� Parametros �                                                           ���
���         01 � oDlg    - Dialog da Window                                ���
���         02 � bOk     - Evento Ok                                       ���
���         03 � bCancel - Evento Cancel                                   ���
���         04 � nOpc    - Opcao da Mbrowse                                ���
��������������������������������������������������������������������������͹��
��� Retorno    � Objeto EnchoiceBar                                        ���
��������������������������������������������������������������������������͹��
��� Uso        � SigaTMS - Gestao de Transportes                           ���
��������������������������������������������������������������������������͹��
��� Comentario � - Possui Ponto de Entrada para Botoes do Usuario          ���
��������������������������������������������������������������������������͹��
���          Atualizacoes efetuadas desde a codificacao inicial            ���
��������������������������������������������������������������������������͹��
���Programador �  Data  � BOPS �             Motivo da Alteracao           ���
��������������������������������������������������������������������������͹��
���            �xx/xx/02�xxxxxx�                                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function TMSA080Bar( oDlg, bOk, bCancel, nOpc )

Local aButtons     := {}
Local aSomaButtons := {}
Local nCntFor      := 0

Aadd(aSetKey, { VK_F4 , { || TMSA080SFx(nOpc) } } )
Aadd( aButtons, { "RELATORIO", {|| TMSA080SFx(nOpc) }, STR0022 , STR0023 } ) //"SubFaixa - <F4>"

//-- Ponto de entrada para incluir botoes na enchoicebar
If	ExistBlock('TM080BUT')
	aSomaButtons:=ExecBlock('TM080BUT',.F.,.F.,{nOpc})
	If	ValType(aSomaButtons) == 'A'
		For nCntFor:=1 To Len(aSomaButtons)
			AAdd(aButtons,aSomaButtons[nCntFor])
		Next
	EndIf
EndIf

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

Return ( EnchoiceBar( oDlg, bOK, bCancel,, aButtons ) )

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa   �  TMSA080   � Autor �        Nava        � Data � 18/10/01 ���
��������������������������������������������������������������������������͹��
���             Localizador de Folder Preenchido                           ���
��������������������������������������������������������������������������͹��
��� Sintaxe    � TMSA080Loc( nOpcx, oFolder )                              ���
��������������������������������������������������������������������������͹��
��� Parametros �                                                           ���
���         01 � nOpcx   - Opcao da Mbrowse                                ���
���         02 � oFolder - Objeto Folder                                   ���
��������������������������������������������������������������������������͹��
��� Retorno    � NIL                                                       ���
��������������������������������������������������������������������������͹��
��� Uso        � SigaTMS - Gestao de Transportes                           ���
��������������������������������������������������������������������������͹��
��� Comentario � - Na Inclusao deleta TODOS os folders menos o 1           ���
���            � - Caso contrario localiza o primeiro folder preenchido    ���
���            � - Se o Folder 1 nao estiver preenchido :                  ���
���            �   - Deleta o Folder 1                                     ���
���            �   - Forca Troca do Folder para o Primeiro Preenchido      ���
���            �   - Troca Folder dentro do objeto Folder                  ���
���            �   - Refresh para refletir a mudanca no Objeto Folder      ���
��������������������������������������������������������������������������͹��
���          Atualizacoes efetuadas desde a codificacao inicial            ���
��������������������������������������������������������������������������͹��
���Programador �  Data  � BOPS �             Motivo da Alteracao           ���
��������������������������������������������������������������������������͹��
���            �xx/xx/02�xxxxxx�                                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

Static Function TMSA080Loc( nOpcx, oFolder )

Local nI
Local nJ
Local nFirstFolderOk := 0

If nOpcx == 3

	//�������������������������������Ŀ
	//� Deleta todos menos o Folder 1 �
	//���������������������������������

	Aeval( aFolder, { | aFold | 	aFold[5][1][Len( aFold[4] ) + 1] := .T. }, 2 ) 
	nFirstFolderOk := 1
Else
	For nI := 1 To Len( aFolder )
		
		//���������������������Ŀ
		//� Candidato a delecao �
		//�����������������������

		If Len( aFolder[nI][5] ) == 1
			lEmpty := .F.

			For nJ := 1 TO Len( aFolder[nI][8]:aPosCol ) // Valida Obrigat
				If !lEmpty .And. Empty( aFolder[nI][5][1][aFolder[nI][8]:aPosCol[nJ, 2]] )
					lEmpty := .T.
					Exit
				EndIf
			Next nJ

			IF lEmpty
				//����������������������������������������������������Ŀ
				//� Deleta porque a FillGetDados colocou para Inclusao �
				//������������������������������������������������������

				aFolder[nI][5][1][Len( aFolder[nI][4] ) + 1] := .T.

				//���������������������������������������������������Ŀ
				//� Se nao eh o Folder 1 e ainda nao localizou nenhum �
				//�����������������������������������������������������

         ElseIf nFirstFolderOk == 0
				nFirstFolderOk := nI
		EndIf

		//����������������������������������������������Ŀ
		//� Se tem mais de uma linha e nao eh o Folder 1 �
		//������������������������������������������������

		ElseIf nFirstFolderOk == 0
			nFirstFolderOk := nI
		EndIf

	Next nI

Endif

//����������������������������������Ŀ
//� Habilita apenas o 1o.  Folder    �
//������������������������������������

//Aeval( aFolder, { |aFold| 	aFold[8]:oBrowse:lDisablePaint := .F. } ) 
        
aFolder[1][8]:oBrowse:lDisablePaint := .F.
//���������������������������������������Ŀ
//� Primeiro Folder Preenchido nao eh o 1 �
//�����������������������������������������
If nFirstFolderOk > 1

	//�������������������Ŀ
	//� Deleta o Folder 1 �
	//���������������������

	aCols[1][Len(aHeader)+ 1] := .T.

	//��������������������������������������������������Ŀ
	//� Forca Troca do Folder para o primeiro preenchido �
	//����������������������������������������������������

	TMSA080Chg( nFirstFolderOk, 1 )

	//���������������������������������Ŀ
	//� Troca o Folder no Objeto Folder �
	//�����������������������������������

	oFolder:nOption := nFirstFolderOk

	//����������������������������������������Ŀ
	//� Dah um Refresh para efetivar a mudanca �
	//������������������������������������������

	oFolder:Refresh()

Else

	//������������������������������������Ŀ
	//� Padrao - Folder 1 estah preenchido �
	//��������������������������������������

	aFolder[1][8]:oBrowse:Refresh(.T.)

EndIf

Return NIL

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa   �  TMSA080   � Autor �        Nava        � Data � 18/10/01 ���
��������������������������������������������������������������������������͹��
���             Carrega todos os Folder no aFolder                         ���
��������������������������������������������������������������������������͹��
��� Sintaxe    � TMSA080Fol( nOpcx )                                       ���
��������������������������������������������������������������������������͹��
��� Uso        � SigaTMS - Gestao de Transportes                           ���
��������������������������������������������������������������������������͹��
��� Comentario � Possui Ponto de Entrada p/ Mudanca de Folders pelo usuario���
���            �                                                           ���
���            � Estrutura do Array de Folders                             ���
���            �                                                           ���
���            � [1] -> Tipo "N" , Numero do Folder ( DT3_CODPAS )         ���
���            � [2] -> Tipo "C" , Titulo do Folder                        ���
���            � [3] -> Tipo "A" , aColsRecno ( Recno() de cada aCols )    ���
���            � [4] -> Tipo "A  , aHeader   da GetDados do Folder         ���
���            � [5] -> Tipo "A" , aCols     da GetDados do Folder         ���
���            � [6] -> Tipo "C" , cLinhaOk  da GetDados do Folder         ���
���            � [7] -> Tipo "C" , cTudoOk   da GetDados do Folder         ���
���            � [8] -> Tipo "O" , oGetDados deste Folder                  ���
���            �                                                           ���
���            � Estrutura do Array aFillGetDados                          ���
���            �                                                           ���
���            � [1] -> Tipo "C" , cAlias do Arquivo                       ���
���            � [2] -> Tipo "N" , nOrder	do Indice                      ���
���            � [3] -> Tipo "C" , cSeekKey, chave de Pesquisa             ���
���            � [4] -> Tipo "B" , bSeekWhile, Pesquisa  While             ���
���            � [5] -> Tipo "B" , bSeekFor, Pesquisa  For                 ���
���            � [6] -> Tipo "A" , aNoFields, NAO vao aparecer no aHeader  ���
���            � [7] -> Tipo "A" , aYesFields, VAO aparecer no aHeader     ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function TMSA080Fol( nOpcx )

Local nPosValAte   := 0	
Local cFolderName  := ''
Local aBacNoFields := {}
Local nAtalho      := 0
Local nPosItem     := 0
Local lSubFaixa    := AliasInDic("DW0")
Local lSubExced    := lSubFaixa .And. AliasInDic("DY0")
Local aNoFields    := { "DTG_TABTAR","DTG_TABFRE","DTG_TIPTAB" } 
Local aYesFields   := {}
Local aNoFieldsDW0 := {}
Local cLinhaOk     := "TMSA080LinOk"
Local cTudoOk      := NIL
Local aColsAux     := {}
Local nCnt         := 0
Local nCnt2        := 0
Local nCnt3        := 0
Local nPos         := 0

aFolder := {}

DVE->( DbSetOrder( 1 ) )
DVE->( MsSeek( xFilial("DVE") + M->DTF_TABFRE + M->DTF_TIPTAB ) )
While DVE->(!Eof()) .And. xFilial("DVE") + M->DTF_TABFRE + M->DTF_TIPTAB == DVE->DVE_FILIAL + DVE->DVE_TABFRE + DVE->DVE_TIPTAB

	aHeader := {}
	aCols   := {}
	nAtalho := 1
	aBacNoFields := Aclone(aNoFields)

	//����������������������������������������������������������������������������������Ŀ
	//�  Na Visualizacao / Exclusao da Tabela Mae, nao trazer na Tela Pastas Vazias      �
	//������������������������������������������������������������������������������������
	If (nOpcx == 2 .Or. nOpcx == 5) .And.	!DTG->(MsSeek(xFilial("DTG") + M->DTF_TABFRE + M->DTF_TIPTAB+ M->DTF_TABTAR+DVE->DVE_CODPAS))
		DVE->( DbSkip() )
		Loop
	EndIf

    DT3->(dbSetOrder(1))
	DT3->( MsSeek( xFilial( "DT3" ) +  DVE->DVE_CODPAS ) )

   //-- Se o componente for "Praca de Pedagio" ou calculado pelo "Cliente Destinat�rio" Ou "TDA x Regi�o", nao devera aparecer no folder
   If DT3->DT3_TIPFAI == StrZero(9, Len(DT3->DT3_TIPFAI))  .Or. DT3->DT3_TIPFAI == "15" .Or. DT3->DT3_TIPFAI == "18"
   	  DVE->( DbSkip() )
	  Loop
   EndIf
   If DT3->DT3_FAIXA  <> StrZero(1, Len(DT3->DT3_FAIXA))
      AAdd(aNoFields,'DTG_FATPES')
   EndIf

	//-- Qdo utilizar sub-faixa, nao sera apresentado 'Valor' e 'Fracao'.
	If !Empty(DT3->DT3_FAIXA2)
		AAdd(aNoFields,'DTG_VALOR' )
		AAdd(aNoFields,'DTG_INTERV')
	EndIf

	Aadd( aFolder, {	DT3->DT3_CODPAS, ;
						AllTrim( DT3->DT3_DESCRI ), 	;
						FillGetDados(	nOpcx, ;
						"DTG",	;
						1,	;
						xFilial( "DTF" ) + M->DTF_TABFRE + M->DTF_TIPTAB + M->DTF_TABTAR + DT3->DT3_CODPAS, ; 
						{ || DTG->DTG_FILIAL + DTG->DTG_TABFRE + DTG->DTG_TIPTAB + DTG->DTG_TABTAR + DTG->DTG_CODPAS } , ;
						{ || .T. } , ;
						aNoFields,;
						/*aYesFields*/,;
						/*lOnlyYes*/,;
						/*cQuery*/,;
						/*bMontCols*/),;
						aClone( aHeader ), ;
						aClone( aCols ), ;
						cLinhaOk, ;
						cTudoOk, ;
						NIL } )

	aColsAux  := AClone(aCols)
	aNoFields := AClone(aBacNoFields)

	//-- Define letra de atalho para acessar o folder
	If	!Empty( DT3->DT3_ATALHO )
		nAtalho := At( DT3->DT3_ATALHO, UPPER(aFolder[ Len(aFolder), 2 ]) )
		If Empty( nAtalho )
			nAtalho := 1
		EndIf
	EndIf

	aFolder[ Len(aFolder), 2 ] := Stuff( aFolder[ Len(aFolder), 2 ], nAtalho, 0, '&' )

	//-- Troca do aHeader refletindo o nome da Pasta do Folder
	nPosValAte	:= Ascan( aFolder[Len(aFolder)][4], { |aField| aField[2] = "DTG_VALATE" } )

   If Empty(DT3->DT3_FAIXA) .Or. DT3->DT3_FAIXA == StrZero(0, Len(DT3->DT3_FAIXA))
		cFolderName := TMSValField('DT3->DT3_TIPFAI',.F.)
   Else
		//-- Esse array contem as descricoes existentes no ComboBox do campo DT3_FAIXA
		aRetBox     := RetSx3Box( Posicione('SX3', 2, 'DT3_FAIXA', 'X3CBox()' ),,, Len(DT3->DT3_FAIXA) )
		cFolderName := AllTrim( aRetBox[ Ascan( aRetBox, { |x| x[ 2 ] == DT3->DT3_FAIXA} ), 3 ])
   EndIf

	SX3->( DbSetOrder( 2 ) )
	SX3->( MsSeek( "DTG_VALATE" ) )

	aFolder[Len(aFolder)][4][nPosValAte][1] := AllTrim( X3Titulo() ) + Space( 10 ) + "(" +  cFolderName + ")" 

	//-- Carrega Sub-Faixas
	If lSubFaixa .And. !Empty(DT3->DT3_FAIXA2)
		//-- Campos que nao deverao aparecer na getdados
		aNoFieldsDW0 := { "DW0_TABTAR", "DW0_ITEDTG" }
		If DT3->DT3_FAIXA2 <> StrZero(1, Len(DT3->DT3_FAIXA2))
			AAdd(aNoFieldsDW0,"DW0_FATPES")
		EndIf
		nPosItem := GDFieldPos("DTG_ITEM")
		For nCnt := 1 To Len(aColsAux)
			If (nPos:= Ascan( aColsDW0, { |x| x[1]+x[2] == DVE->DVE_CODPAS + aColsAux[nCnt,nPosItem] } ) ) == 0
				aCols   := {}
				aHeader := {}
					FillGetDados(	nOpcx, ;
									"DW0", ;
									1, 	 ;
									xFilial("DW0")+M->DTF_TABFRE+M->DTF_TIPTAB+M->DTF_TABTAR+DVE->DVE_CODPAS+aColsAux[nCnt,nPosItem] , ;
									Iif(nOpcx <> 3,{ || DW0->DW0_FILIAL+DW0->DW0_TABFRE+DW0->DW0_TIPTAB+DW0->DW0_TABTAR+DW0->DW0_CODPAS+DW0->DW0_ITEDTG },{|| ''   }), ;
									{|| .T.  },;
									aNoFieldsDW0,;
									/*aYesFields*/,;
									/*lOnlyYes*/,;
									/*cQuery*/,;
									/*bMontCols*/)
				//-- Inicializa o primeiro item da sub-faixa.
				aEval(aCols, {|x| Iif( Empty(x[GdFieldPos('DW0_ITEM')]), x[GdFieldPos('DW0_ITEM')]:= StrZero(1, Len(DW0->DW0_ITEM)), .T.) })
				Aadd(aColsDW0,{ DVE->DVE_CODPAS, aColsAux[nCnt,nPosItem], AClone(aCols), AClone(aHeader) } )

				// Excedente por Subfaixa
				// Carrega o vetor aColsDY0 com os dados da tabela
				if lSubExced
					nPosItemDW0  := GDFieldPos("DW0_ITEM")
					aNoFieldsDY0 := {"DY0_CODPAS"}

					aHeader := {}
					aCols   := {}

					If (nPos:= Ascan( aColsDY0, { |x| x[1]+x[2] == DVE->DVE_CODPAS + DW0->DW0_ITEDTG } ) ) == 0
						aCols   := {}
						aHeader := {}
						FillGetDados(	nOpcx, ;
										"DY0",;
										1, 	 ;
										xFilial("DY0")+M->DTF_TABFRE+M->DTF_TIPTAB+M->DTF_TABTAR+DVE->DVE_CODPAS+DW0->DW0_ITEDTG , ;
										Iif(nOpcx <> 3,{ || DY0->DY0_FILIAL+DY0->DY0_TABFRE+DY0->DY0_TIPTAB+DY0->DY0_TABTAR+DY0->DY0_CODPAS+DY0->DY0_ITEDTG },{|| ''   }), ;
										{|| .T.  },;
										aNoFieldsDY0,;
										/*aYesFields*/,;
										/*lOnlyYes*/,;
										/*cQuery*/,;
										/*bMontCols*/)
						//-- Inicializa o primeiro item da sub-faixa.
						aEval(aCols, {|x| Iif( Empty(x[GdFieldPos('DY0_ITEM')]), x[GdFieldPos('DY0_ITEM')]:= StrZero(1, Len(DY0->DY0_ITEM)), .T.) })
						Aadd(aColsDY0,{ DVE->DVE_CODPAS, DW0->DW0_ITEDTG, AClone(aCols), AClone(aHeader) } )
					Endif
		      Endif
			EndIf
		Next nCnt
	EndIf

	DVE->( DbSkip() )
EndDo

Return

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa   �  TMSA080   � Autor �        Nava        � Data � 18/10/01 ���
��������������������������������������������������������������������������͹��
���             Copia Tabela de Tarifa                                     ���
��������������������������������������������������������������������������͹��
��� Sintaxe    �  TMSA080Cop()                                             ���
��������������������������������������������������������������������������͹��
��� Uso        � SigaTMS - Gestao de Transportes                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function TMSA080Cop()

Local oBold
Local oDlg
Local cTabFre   := DTF->DTF_TABFRE
Local cTipTab   := DTF->DTF_TIPTAB
Local cNewTab   := Space( Len( DTF->DTF_TABTAR ) )
Local nRecDTF   := DTF->( Recno() )
Local nOpc      := 2
Local cKeyDTF   := DTF->DTF_TABTAR
Local cKeyDTG   := ''
Local aCampos   := {}
Local aAreaDTG  := {}
Local aAreaDTF  := DTF->(GetArea())
Local lSubFaixa := AliasInDic("DW0")
Local lSubExced := lSubFaixa .And. AliasInDic("DY0")
Local cKeyDW0   := ''
Local aAreaDW0  := {}
Local nKmDe     := 0
Local nKmAte    := 0

Inclui := .T. 

DEFINE MSDIALOG oDlg TITLE STR0008 From 18,0 To 28,38 OF oMainWnd  //"Copia Tabela de Tarifas"

	@ 002,002 TO 075,148 LABEL "" OF oDlg PIXEL

	@ 010,010 SAY STR0009 SIZE 100,15 COLOR CLR_HBLUE PIXEL FONT oBold  //"Da Tabela "
	@ 025,010 SAY STR0010 SIZE 100,15 COLOR CLR_HBLUE PIXEL FONT oBold  //"Para Tabela"
	@ 040,010 SAY STR0017 SIZE 100,15 COLOR CLR_HBLUE PIXEL FONT oBold  //"Km De"
	@ 055,010 SAY STR0018 SIZE 100,15 COLOR CLR_HBLUE PIXEL FONT oBold  //"Km Ate"

   @ 010,050 MSGET cKeyDTF PICTURE "@!" SIZE 6,9 WHEN .F. PIXEL
   @ 025,050 MSGET cNewTab PICTURE "@!" SIZE 6,9 PIXEL
   @ 040,050 MSGET nKmDe   PICTURE "@E 99,999.9" SIZE 15,9 PIXEL
   @ 055,050 MSGET nKmAte  PICTURE "@E 99,999.9" SIZE 15,9 PIXEL

	DEFINE SBUTTON FROM 10,110	TYPE 1 ;
		ACTION If(TMSA080VCop(cNewTab,nKmDe,nKmAte),(nOpc := 1,oDlg:End()),.F.) ENABLE OF oDlg

	DEFINE SBUTTON FROM 25,110	TYPE 2 ;
		ACTION (nOpc := 2,oDlg:End()) ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

DTG->(DbSetOrder(1))
DTF->(DbSetOrder(1))
DTF->(DbGoto(nRecDTF))
cKeyDTF := xFilial("DTF") + DTF->DTF_TABTAR

If nOpc == 1 .And. ;
	Aviso( "AVISO",	STR0011 + DTF->DTF_TABTAR + CRLF + ;  //"Copiar da Tabela de Tarifa "
					STR0012 + " " + cNewTab, { STR0013, STR0014 },, STR0015 ) == 1  //"PARA a NOVA Tabela de Tarifa"###"Confirma"###"Cancela"###"Confirma��o"
	CursorWait()
	While DTF->(!Eof()) .And. DTF->DTF_FILIAL + DTF->DTF_TABTAR == cKeyDTF
		//-- Copia Cabecalho da Tabela de Tarifa
		aCampos := {}
		Aadd( aCampos, { "DTF_TABTAR", cNewTab } )
		Aadd( aCampos, { "DTF_KMDE"  , nKmDe   } )
		Aadd( aCampos, { "DTF_KMATE" , nKmAte  } )
		DTF->(TmsCopyReg(aCampos))
		DTF->(DbGoTo(nRecDTF))
		//-- Copia os Itens da Tabela de Tarifa
		If DTG->(MsSeek(cKeyDTG:= xFilial("DTG")+DTF->DTF_TABFRE+DTF->DTF_TIPTAB+DTF->DTF_TABTAR))
			aCampos := {}
			Aadd( aCampos, { "DTG_TABTAR", cNewTab } )
			While DTG->(!Eof()) .And. DTG->DTG_FILIAL + DTG->DTG_TABFRE + DTG->DTG_TIPTAB + DTG->DTG_TABTAR == cKeyDTG
				aAreaDTG := DTG->(GetArea())
				DTG->(TmsCopyReg(aCampos))
				RestArea( aAreaDTG )
				DTG->(DbSkip())
			EndDo
		EndIf
		//-- Copia as sub-faixas dos Itens da Tabela de Tarifa
		If lSubFaixa
			DW0->(DbSetOrder(1))
			If DW0->(MsSeek(cKeyDW0:= xFilial("DW0")+DTF->DTF_TABFRE+DTF->DTF_TIPTAB+DTF->DTF_TABTAR))
				aCampos := {}
				Aadd( aCampos, { "DW0_TABTAR", cNewTab } )
				While DW0->(!Eof()) .And. DW0->DW0_FILIAL + DW0->DW0_TABFRE + DW0->DW0_TIPTAB + DW0->DW0_TABTAR == cKeyDW0
					aAreaDW0 := DW0->(GetArea())
					DW0->(TmsCopyReg(aCampos))
					RestArea( aAreaDW0 )
					DW0->(DbSkip())
				EndDo
			EndIf

			// Excedente por Subfaixa
			// Copia dos valores excedentes das sub-faixas
			if lSubExced
				DY0->(DbSetOrder(1))
				If DY0->(MsSeek(cKeyDY0:= xFilial("DY0")+DTF->DTF_TABFRE+DTF->DTF_TIPTAB+DTF->DTF_TABTAR))
					aCampos := {}
					Aadd( aCampos, { "DY0_TABTAR", cNewTab } )
					While DY0->(!Eof()) .And. DY0->DY0_FILIAL + DY0->DY0_TABFRE + DY0->DY0_TIPTAB + DY0->DY0_TABTAR == cKeyDY0
						aAreaDY0 := DY0->(GetArea())
						DY0->(TmsCopyReg(aCampos))
						RestArea( aAreaDY0 )
						DY0->(DbSkip())
					EndDo
				EndIf
			EndIf

		EndIf
		DTF->(DbSkip())
	EndDo
	CursorArrow()
EndIf

RestArea(aAreaDTF)

Return

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA080XBI   � Autor �Patricia A. Salomao � Data � 11/04/2002 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Chama a rotina de Inclusao de Tabela de Frete                ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Consulta SXB - DTF                                           ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function TMSA080XBI()

TMSA080(3)

Return

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA080XBV   � Autor �Patricia A. Salomao � Data � 11/04/2002 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Chama a rotina de Visualizacao de Tabela de Frete            ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Consulta SXB - DTF                                           ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function TMSA080XBV()

TMSA080(2)

Return
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Tmsa080Vld   � Autor � Robson Alves       � Data � 08.08.2003 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao de campos.                                         ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Consulta SXB - DTF                                           ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function Tmsa080Vld()
Local cCampo   := ReadVar()
Local lRet     := .T.
Local aAreaDTF := DTF->( GetArea() )

If cCampo $ "M->DTF_KMDE;M->DTF_KMATE"

	If !Empty( M->DTF_KMATE ) .And. M->DTF_KMATE <= M->DTF_KMDE
		HELP(" ",1,"TMSA08007") // Quilometragem 'Ate' menor que a Qilometragem 'De'.
		lRet := .F.
	EndIf

	If lRet
		DTF->(dbSetOrder(1))
		DTF->(MsSeek(xFilial("DTF")+M->DTF_TABFRE+M->DTF_TIPTAB))
		While DTF->(!Eof()) .And. DTF->DTF_FILIAL + DTF->DTF_TABFRE + DTF->DTF_TIPTAB == xFilial("DTF") + M->DTF_TABFRE + M->DTF_TIPTAB
			/* Verifica se jah existe tarifa com a Quilometragem informada. */
			If M->DTF_TABTAR <> DTF->DTF_TABTAR
	         If !Empty( M->DTF_KMDE ) .And. M->DTF_KMDE >= DTF->DTF_KMDE .And. M->DTF_KMDE <= DTF->DTF_KMATE
	         	lRet := .F.
	         	Exit
				ElseIf !Empty( M->DTF_KMATE ) .And. M->DTF_KMATE >= DTF->DTF_KMDE .And. M->DTF_KMATE <= DTF->DTF_KMATE
	         	lRet := .F.
	         	Exit
				EndIf
			EndIf
			DTF->( dbSkip() )
		EndDo
		If !lRet
			Help(" ", 1, "TMSA08006",,STR0019 + DTF->DTF_TABTAR + " - " + STR0017 + " :" +;
			Str(DTF->DTF_KMDE, 7,1) + " / " + STR0018 + " :" + Str(DTF->DTF_KMATE, 7, 1),5,11) //"Ja existe uma tarifa cadastrada para essa Quilometragem" ### "Tarifa :" ### "Km De" ### "Km Ate"
		EndIf
	EndIf

EndIf
RestArea( aAreaDTF )

Return( lRet )

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSA080UPD  � Autor � Eduardo de Souza     � Data � 26/04/05 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizada para validar se o programa esta atualizado         ���
���          | na chamada da TmsCalFret().                                  ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA080UPD()                                                 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � TMSA080                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Function TMSA080UPD()

Return

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSA080SFx  � Autor � Eduardo de Souza     � Data � 26/04/05 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Apresenta Sub-Faixa                                          ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA080SFx()                                                 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � TMSA080                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function TMSA080SFx(nOpcx)

Local cTitTabFre := AllTrim(RetTitle("DW0_TABFRE"))
Local cTitTipTab := AllTrim(RetTitle("DW0_TIPTAB"))
Local cTitCodPas := AllTrim(RetTitle("DW0_CODPAS"))
Local cTitItem   := AllTrim(RetTitle("DW0_ITEM"  ))
Local oDlgEsp
Local oGetSub
Local aSize       := {}
Local aInfo       := {}
Local aObjects    := {}
Local aPosObj     := {}
Local nPos        := 0
Local nOpcao      := 0
Local lAchou      := .F.
Local nCnt        := 0
Local cCodPas     := aFolder[nFolder,1]
Local cItem       := GDFieldGet("DTG_ITEM",n)
Local aNoFields   := { "DW0_TABTAR", "DW0_ITEDTG" }
Local nPosValAte  := 0
Local aRetBox     := {}
Local cFolderName := ''

// Excedente por Subfaixa
Local aButtons    := {}

If Empty(M->DTF_TABTAR)
	Help("",1,"TMSA08010") //-- Nao foi informada a tarifa para a tabela de frete.
	Return .F.
EndIf

SaveInter() //-- Salva Area

aCols   := {}
aHeader := {}

//-- Verifica se existe o componente de frete.
DT3->(dbSetOrder(1))
If !DT3->(MsSeek(xFilial("DT3")+cCodPas))
	Help("",1,"TMSA08011") //-- Componente de frete nao encontrado.
	RestInter() //-- Restaura Area
	Return .F.
EndIf

//-- Verifica se o componente utiliza sub-faixa.
If Empty(DT3->DT3_FAIXA2)
	Help("",1,"TMSA08012") //-- Componente de frete nao configurado para utilizar sub-faixa.
	RestInter() //-- Restaura Area
	Return .F.
EndIf

If DT3->DT3_FAIXA2 <> StrZero(1, Len(DT3->DT3_FAIXA2))
	AAdd(aNoFields,'DW0_FATPES')
EndIf

If (nPos:= Ascan( aColsDW0, { |x| x[1]+x[2] == cCodPas + cItem } ) ) == 0
		FillGetDados(	nOpcx, ;
						"DW0", ;
						1, 	 ;
						xFilial("DW0")+M->DTF_TABFRE+M->DTF_TIPTAB+M->DTF_TABTAR+cCodPas+cItem , ;
						Iif(nOpcx <> 3,{ || DW0->DW0_FILIAL+DW0->DW0_TABFRE+DW0->DW0_TIPTAB+DW0->DW0_TABTAR+DW0->DW0_CODPAS+DW0->DW0_ITEDTG },{|| ''   }), ;
						{|| .T.  },;
						aNoFields,;
						/*aYesFields*/,;
						/*lOnlyYes*/,;
						/*cQuery*/,;
						/*bMontCols*/)
	//-- Inicializa o primeiro item da sub-faixa.
	aEval(aCols, {|x| Iif( Empty(x[GdFieldPos('DW0_ITEM')]), x[GdFieldPos('DW0_ITEM')]:= StrZero(1, Len(DW0->DW0_ITEM)), .T.) })
Else
	lAchou   := .T.
	aCols    := AClone(aColsDW0[nPos,3]	)
	aHeader  := AClone(aColsDW0[nPos,4])
	//-- Inicializa todas as linhas do aCols como nao deletado, devido a falha na GetDados
	For nCnt := 1 To Len(aCols)
		aCols[nCnt,Len(aHeader)+1] := .F.
	Next nCnt
EndIf

//-- Inicio da troca do aHeader refletindo o nome da faixa.
nPosValAte	:= Ascan( aHeader, { |aField| aField[2] = "DW0_VALATE" } )

//-- Esse array contem as descricoes existentes no ComboBox do campo DT3_FAIXA2
aRetBox     := RetSx3Box( Posicione('SX3', 2, 'DT3_FAIXA2', 'X3CBox()' ),,, Len(DT3->DT3_FAIXA2) )
cFolderName := AllTrim( aRetBox[ Ascan( aRetBox, { |x| x[ 2 ] == DT3->DT3_FAIXA2} ), 3 ])

SX3->(DbSetOrder(2))
SX3->(MsSeek("DW0_VALATE"))

aHeader[nPosValAte,1] := AllTrim( X3Titulo() ) + Space( 10 ) + "(" +  cFolderName + ")" 
//-- Fim da troca do aHeader refletindo o nome da faixa.

//-- Dimensoes padroes
aSize   := MsAdvSize()
AAdd( aObjects, { 100, 015, .T., .T. } )
AAdd( aObjects, { 100, 085, .T., .T. } )

// Excedente por SubFaixa
// se o componente tiver valores de excedente deve incluir o botao
If AliasInDic("DY0") 
	Aadd(aButtons,	{'PRECO',{|| TMSA080Comp(nOpcx,cItem) }, STR0028, STR0027 }) //"Complemento de Sub-Faixa"###"Cmp.SbFx"
EndIf

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlgEsp TITLE STR0021 FROM aSize[7]/2,00 TO aSize[6]/2,aSize[5]/2+100 PIXEL //'Tabela de Tarifas - SubFaixa'

@ aPosObj[1,1],010 SAY cTitTabFre + ': ' COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 30 ,9
@ aPosObj[1,1],038 SAY M->DTF_TABFRE Of oDlgEsp PIXEL SIZE 29 ,9

@ aPosObj[1,1],055 SAY cTitTipTab + ': ' COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 30 ,9
@ aPosObj[1,1],070 SAY M->DTF_TIPTAB Of oDlgEsp PIXEL SIZE 10 ,9

@ aPosObj[1,1],080 SAY cTitCodPas + ': ' COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 35 ,9
@ aPosObj[1,1],115 SAY Posicione("DT3",1,xFilial("DT3")+cCodPas,"DT3_DESCRI") Of oDlgEsp PIXEL SIZE 40 ,9

@ aPosObj[1,1],185 SAY cTitItem + ': ' COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 30 ,9
@ aPosObj[1,1],200 SAY cItem Of oDlgEsp PIXEL SIZE 10 ,9

oGetSub:=MSGetDados():New(aPosObj[2,1]/2, aPosObj[2,2]/2, aPosObj[2,3]/2, aPosObj[2,4]/2+50, nOpcx, 'TMSA080SLOk()','AllWaysTrue',"+DW0_ITEM",nOpcx<>2)

//-- Atualiza aCols corrigindo a falha na GetDados
If(lAchou,aCols := AClone(aColsDW0[nPos,3]),.T.)
oGetSub:Refresh(.T.)

ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{|| If(oGetSub:TudoOk(),(nOpcao:= 1,oDlgEsp:End()),.F.) }, {|| oDlgEsp:End() },,aButtons ) CENTERED

//-- Atualiza array de aCols da sub-faixa
If nOpcao == 1
	If (nPos:= Ascan( aColsDW0, { |x| x[1]+x[2] == cCodPas+cItem } ) ) == 0
		Aadd(aColsDW0,{ cCodPas, cItem, AClone(aCols), AClone(aHeader) } )
	Else
		aColsDW0[nPos,3] := AClone(aCols)
	EndIf
EndIf

RestInter() //-- Restaura Area

Return


/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSA080SLOk � Autor � Eduardo de Souza     � Data � 27/04/05 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Valida linha da sub-faixa                                    ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA080SLOk()                                                ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � TMSA080                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Function TMSA080SLOk()

Local lRet			:= .F.
Local nPosValAte	:= GDFieldPos("DW0_VALATE")
Local nPosFatPes	:= GDFieldPos("DW0_FATPES")
Local nValAte		:= aCols[n][nPosValAte]
Local nValPes		:= If(nPosFatPes > 0, aCols[n][nPosFatPes], 0)

lRet := MaCheckCols(aHeader,aCols,n)

//-- Valida se esta deletado
If lRet
	If GDDeleted(n)
		lRet := .T.
	//-- Na primeira linha Valida p/ baixo
	ElseIf n == 1
		lRet := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ]	.And. ;
										(nValAte >= aLine[nPosValAte] .Or. ;
										IIf(nPosFatPes >0, nValPes >= aLine[nPosFatPes],.F.) )}, 2 ) == 0
	//-- Na ultima linha Valida p/ cima
	ElseIf n == Len( aCols )
		lRet := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ]	.And. ;
										(nValAte <= aLine[nPosValAte]	.Or.;
										IIf(nPosFatPes >0, nValPes <= aLine[nPosFatPes],.F.) )}, 1, Len( Acols ) - 1 ) == 0
	//-- Valida Acima e Abaixo
	Else			
		lRet := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ]	.And. ;
										(nValAte <= aLine[nPosValAte] .Or. ;
										IIf(nPosFatPes >0, nValPes <= aLine[nPosFatPes],.F.) ) } , 1, n - 1 ) == 0
		
		lRet := lRet .And. ;
				   Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ] .And. ;
										(nValAte >= aLine[nPosValAte] .Or.;
										IIf(nPosFatPes >0, nValPes >= aLine[nPosFatPes],.F.) )	}, n + 1 ) == 0
	EndIf

	If !lRet
		Help(" ",1,"TMSA08004") //"Campo Ate'/Fator Peso Invalido ou ja existente"
	EndIf

	If lRet .And. !GdDeleted(n)
		If nPosFatPes >0 .And. GDFieldGet('DW0_FATPES',n) < GDFieldGet('DW0_VALATE',n)
			Help("", 1,"TMSA08005") //O campo "Fator Peso" esta menor do que o campo "Ate Peso"
			lRet := .F.
		EndIf
	EndIf

EndIf

Return lRet

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSA080Vd2  � Autor � Eduardo de Souza     � Data � 27/04/05 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Valida sub-faixa para o componente principal.                ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA080Vd2()                                                 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � TMSA080                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function TMSA080Vd2(cCodPas,cItem)

Local lRet := .F.
Local nPos := 0

//-- Verifica se o componente de frete utiliza sub-faixa.
If Empty(Posicione("DT3",1,xFilial("DT3")+cCodPas,"DT3_FAIXA2"))
	lRet := .T.
Else
	//-- Verifica se foi informado alguma sub-faixa para o componente.
	If (nPos := Ascan( aColsDW0, { |x| x[1]+x[2] == cCodPas + cItem } )) > 0 .And. ;
			Ascan( aColsDW0[nPos,3], { |x| ! x[Len(x)] } ) > 0
		lRet := .T.
	EndIf
EndIf

Return lRet

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSA080VCop � Autor � Eduardo de Souza     � Data � 28/04/05 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Valida quilometragem na copia de tarifas.                    ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA080VCop()                                                ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � TMSA080                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function TMSA080VCop(cNewTab,nKmDe,nKmAte)

Local lRet     := .T.
Local aAreaDTF := DTF->( GetArea() )
Local cSeekDTF := ''

//-- Verifica se a tabela de tarifa foi preenchida
If Empty(cNewTab)
	Help(" ",1,"TMSA08013") //-- "Devera ser informada a nova tarifa."
	lRet := .F.
EndIf

If lRet .And. (nKmDe == 0 .Or. nKmAte == 0 )
	Help("",1,"OBRIGAT") //-- Campos Obrigatorios
	lRet := .F.
EndIf

//-- Verifica se a tarifa informada ja existe.
DTF->(DbSetOrder(1))
If lRet .And. DTF->(MsSeek(xFilial('DTF')+DTF->DTF_TABFRE+DTF->DTF_TIPTAB+cNewTab))
	Help('',1,'TMSA08008') //-- Tabela de tarifa ja cadastrada
	lRet := .F.
EndIf

If lRet
	If !Empty( nKmAte ) .And. nKmAte <= nKmDe
		Help(" ",1,"TMSA08007") // Quilometragem Ate menor que a Quilometragem De.
		lRet := .F.
	EndIf
	If lRet
		RestArea( aAreaDTF )
		DTF->(dbSetOrder(1))
		DTF->(MsSeek(cSeekDTF := xFilial("DTF")+DTF->DTF_TABFRE+DTF->DTF_TIPTAB))
		While DTF->(!Eof()) .And. DTF->DTF_FILIAL + DTF->DTF_TABFRE + DTF->DTF_TIPTAB == cSeekDTF
			//-- Verifica se jah existe tarifa com a Quilometragem informada.
			If !Empty( nKmDe ) .And. nKmDe >= DTF->DTF_KMDE .And. nKmDe <= DTF->DTF_KMATE
				lRet := .F.
				Exit
			ElseIf !Empty( nKmAte ) .And. nKmAte >= DTF->DTF_KMDE .And. nKmAte <= DTF->DTF_KMATE
				lRet := .F.
				Exit
			EndIf
			DTF->( dbSkip() )
		EndDo
		If !lRet
			Help(" ", 1, "TMSA08006",,STR0019 + DTF->DTF_TABTAR + " - " + STR0017 + " :" +;
				Str(DTF->DTF_KMDE, 7,1) + " / " + STR0018 + " :" + Str(DTF->DTF_KMATE, 7, 1),5,11) //"Ja existe uma tarifa cadastrada para essa Quilometragem" ### "Tarifa :" ### "Km De" ### "Km Ate"
		EndIf
	EndIf
EndIf
RestArea( aAreaDTF )

Return lRet

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

Private aRotina	:=	{	{ STR0002 ,"AxPesqui"  , 0, 1 ,0,.F.},;  //"Pesquisar"
						{ STR0003 ,"TMSA080Mnt", 0, 2 ,0,NIL},;  //"Visualizar"
						{ STR0004 ,"TMSA080Mnt", 0, 3 ,0,NIL},;  //"Incluir"
						{ STR0005 ,"TMSA080Mnt", 0, 4 ,0,NIL},;  //"Alterar"
						{ STR0006 ,"TMSA080Mnt", 0, 5 ,0,NIL},;  //"Excluir"
						{ STR0007 ,"TMSA080Cop", 0, 6 ,0,NIL} }  //"Copiar"

If ExistBlock("TM080MNU")
	ExecBlock("TM080MNU",.F.,.F.)
EndIf

Return(aRotina)

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSA080Comp � Autor �Aldo Barbosa dos Santos� Data� 15/05/09 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Apresenta Sub-Faixa                                          ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA080Comp()                                                ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � TMSA080                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function TMSA080Comp(nOpcx,cItemDTG)

Local cTitTabFre := AllTrim(RetTitle("DW0_TABFRE"))
Local cTitTipTab := AllTrim(RetTitle("DW0_TIPTAB"))
Local cTitCodPas := AllTrim(RetTitle("DW0_CODPAS"))
Local cTitItem   := AllTrim(RetTitle("DW0_ITEM"  ))
Local oDlgEsp
Local oGetSub
Local aSize       := {}
Local aInfo       := {}
Local aObjects    := {}
Local aPosObj     := {}
Local nPos        := 0
Local nOpcao      := 0
Local lAchou      := .F.
Local nCnt        := 0
Local cCodPas     := aFolder[nFolder,1]

// Excedente por Subfaixa
Local nPosItem    := Ascan( aHeader, { |aField| aField[2] = "DW0_ITEM" } )
Local cItem       := aCols[n,nPosItem]

Local aNoFields   := { "DY0_CODPAS", "DY0_TABTAR", "DY0_ITEDTG" }
Local nPosValAte  := 0
Local aRetBox     := {}
Local cFolderName := ''

If Empty(M->DTF_TABTAR)
	Help("",1,"TMSA08010") //-- Nao foi informada a tarifa para a tabela de frete.
	Return .F.
EndIf

SaveInter() //-- Salva Area

aCols   := {}
aHeader := {}

//-- Verifica se existe o componente de frete.
DT3->(dbSetOrder(1))
If !DT3->(MsSeek(xFilial("DT3")+cCodPas))
	Help("",1,"TMSA08011") //-- Componente de frete nao encontrado.
	RestInter() //-- Restaura Area
	Return .F.
EndIf

//-- Verifica se o componente utiliza sub-faixa.
If Empty(DT3->DT3_FAIXA2)
	Help("",1,"TMSA08012") //-- Componente de frete nao configurado para utilizar sub-faixa.
	RestInter() //-- Restaura Area
	Return .F.
EndIf

If (nPos:= Ascan( aColsDY0, { |x| x[1]+x[2] == cCodPas + cItemDTG } ) ) == 0
		FillGetDados(	nOpcx, ;
							"DY0", ;
							1, 	 ;
							xFilial("DY0")+M->DTF_TABFRE+M->DTF_TIPTAB+M->DTF_TABTAR+cCodPas+cItemDTG , ;
							Iif(nOpcx <> 3,{ || DY0->DY0_FILIAL+DY0->DY0_TABFRE+DY0->DY0_TIPTAB+DY0->DY0_TABTAR+DY0->DY0_CODPAS+DY0->DY0_ITEDTG },{|| ''   }), ;
							{|| .T.  },;
							aNoFields,;
							/*aYesFields*/,;
							/*lOnlyYes*/,;
							/*cQuery*/,;
							/*bMontCols*/)
	//-- Inicializa o primeiro item da sub-faixa.
	aEval(aCols, {|x| Iif( Empty(x[GdFieldPos('DY0_ITEM')]), x[GdFieldPos('DY0_ITEM')]:= StrZero(1, Len(DY0->DY0_ITEM)), .T.) })

Else
	lAchou   := .T.
	aCols    := AClone(aColsDY0[nPos,3]	)
	aHeader  := AClone(aColsDY0[nPos,4])
	//-- Inicializa todas as linhas do aCols como nao deletado, devido a falha na GetDados
	For nCnt := 1 To Len(aCols)
		aCols[nCnt,Len(aHeader)+1] := .F.
	Next nCnt
EndIf


//-- Dimensoes padroes
aSize   := MsAdvSize()
AAdd( aObjects, { 100, 015, .T., .T. } )
AAdd( aObjects, { 100, 085, .T., .T. } )

// Excedente por Subfaixa
// Se o componente tiver valores de excedente deve incluir o botao
aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlgEsp TITLE STR0028 FROM aSize[7]/2,00 TO aSize[6]/2,aSize[5]/2+100 PIXEL //"Complemento de Sub-Faixa"

@ aPosObj[1,1],010 SAY cTitTabFre + ': ' COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 30 ,9
@ aPosObj[1,1],038 SAY M->DTF_TABFRE Of oDlgEsp PIXEL SIZE 29 ,9

@ aPosObj[1,1],055 SAY cTitTipTab + ': ' COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 30 ,9
@ aPosObj[1,1],070 SAY M->DTF_TIPTAB Of oDlgEsp PIXEL SIZE 10 ,9

@ aPosObj[1,1],080 SAY cTitCodPas + ': ' COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 35 ,9
@ aPosObj[1,1],115 SAY Posicione("DT3",1,xFilial("DT3")+cCodPas,"DT3_DESCRI") Of oDlgEsp PIXEL SIZE 40 ,9

@ aPosObj[1,1],2000 SAY STR0029 COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 30 ,9 //"Faixa : "
@ aPosObj[1,1],0220 SAY cItemDTG Of oDlgEsp PIXEL SIZE 10 ,9

//       MsGetDados(nT , nL,  nB,  nR,                                                          nOpc,   cLinhaOk,    cTudoOk,          cIniCpos,  lDeleta,    aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)
aAltera := {"DY0_EXCMIN", "DY0_VALMIN", "DY0_VALMAX", "DY0_VALOR","DY0_INTERV"}

//       MsGetDados(                  nT ,              nL,              nB,                nR,  nOpc,        cLinhaOk,      cTudoOk,   cIniCpos,  lDeleta,  aAlter,nFreeze,lEmpty, nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)
oGetSub:=MSGetDados():New(aPosObj[2,1]/2, aPosObj[2,2]/2, aPosObj[2,3]/2, aPosObj[2,4]/2+50, nOpcx, 'TMSA080CLOk()','AllWaysTrue',"+DY0_ITEM",nOpcx<>2, aAltera, 3,           , 1 )

//-- Atualiza aCols corrigindo a falha na GetDados
If(lAchou,aCols := AClone(aColsDY0[nPos,3]),.T.)
oGetSub:Refresh(.T.)

ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{|| If(oGetSub:TudoOk(),(nOpcao:= 1,oDlgEsp:End()),.F.) }, {|| oDlgEsp:End() },, ) // CENTERED

//-- Atualiza array de aCols da sub-faixa
If nOpcao == 1
	If (nPos:= Ascan( aColsDY0, { |x| x[1]+x[2] == cCodPas+cItemDTG } ) ) == 0
		Aadd(aColsDY0,{ cCodPas, cItemDTG, AClone(aCols), AClone(aHeader) } )
	Else
		aColsDY0[nPos,3] := AClone(aCols)
	EndIf
EndIf

RestInter() //-- Restaura Area

Return


/*�������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSA080CLOk � Autor � Aldo Barbosa dos Santos� Data � 15/05/09 ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Valida linha do complemento da sub-faixa                       ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA080CLOk()                                                  ���
�����������������������������������������������������������������������������Ĵ��
��� Uso      � TMSA080                                                        ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
��������������������������������������������������������������������������������*/
Function TMSA080CLOk()

Local lRet			:= .F.
Local nPosExcMin	:= GDFieldPos("DY0_EXCMIN")
Local nPosValMin	:= GDFieldPos("DY0_VALMIN")
Local nPosValMax	:= GDFieldPos("DY0_VALMAX")
Local nPosValor		:= GDFieldPos("DY0_VALOR")
Local nExcMin		:= aCols[n][nPosExcMin]
Local nValMin		:= aCols[n][nPosValMin]
Local nValMax		:= aCols[n][nPosValMax]
Local nValor		:= aCols[n][nPosValor]

lRet := MaCheckCols(aHeader,aCols,n)

//-- Valida se esta deletado
If lRet
	If GDDeleted(n)
		lRet := .T.
	//-- Na primeira linha Valida p/ baixo
	ElseIf n == 1
		lRet := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ] .And. nExcMin >= aLine[nPosExcMin] }, 2 ) == 0
	//-- Na ultima linha Valida p/ cima
	ElseIf n == Len( aCols )
		lRet := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ] .And. nExcMin <= aLine[nPosExcMin] }, 1, Len( Acols ) - 1 ) == 0
	//-- Valida Acima e Abaixo
	Else	
		lRet := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ] .And. nExcMin <= aLine[nPosExcMin] }, 1, n - 1 ) == 0
		lRet := lRet .And. ;
				Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ] .And. nExcMin >= aLine[nPosExcMin] }, n + 1 ) == 0
	EndIf
	If ! GDDeleted(n) .And. nValMax > 0 .And. nValMin > nValMax
		lRet := .F.
	EndIf
	If !lRet
		Alert(STR0030) //"Valores informados Invalidos"
	EndIf
EndIf

Return lRet