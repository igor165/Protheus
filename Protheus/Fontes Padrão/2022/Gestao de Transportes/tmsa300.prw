#INCLUDE  "tmsa300.ch"
#include  "PROTHEUS.ch"

STATIC aFolder := {}  

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa   �  TMSA300   � Autor �Patricia A. Salomao � Data � 28/02/02 ���
��������������������������������������������������������������������������͹��
���             Tabela de Seguro                                           ���
��������������������������������������������������������������������������͹��
��� Sintaxe    � TMSA300()                                                 ���
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
���            � [9] -> Tipo "A" , Campos que podem ser alterados          ���
���            �                                                           ���
���            � Possui 2 pontos de Entrada TMSA300A e TMSA300B            ���
��������������������������������������������������������������������������͹��
���          Atualizacoes efetuadas desde a codIficacao inicial            ���
��������������������������������������������������������������������������͹��
���Programador �  Data  � BOPS �             Motivo da Alteracao           ���
��������������������������������������������������������������������������͹��
���            �xx/xx/02�xxxxxx�                                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
FUNCTION TMSA300(nRotina)

//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������

Local aSavARot := If( Type("aRotina")  !="U",aRotina,	{}	)
Local cSavcCad := If( Type("cCadastro")!="U",cCadastro,"" )
Local aArea		:= GetArea()

Private cCadastro := STR0001 //"Tabela de Seguro"
Private aRotina	:=	MenuDef()

Mbrowse( 6, 1, 22, 75, "DU4")

//��������������������������������������������������������������Ŀ
//�Restaura os dados de entrada                                  �
//����������������������������������������������������������������

RestArea( aArea )
aRotina   := aSavARot
cCadastro := cSavcCad

Return NIL

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa   �  TMSA300   � Autor �Patricia A. Salomao � Data � 28/02/02 ���
��������������������������������������������������������������������������͹��
���             Manutencao da Tabela de Seguro                             ���
��������������������������������������������������������������������������͹��
��� Sintaxe    �  TMSA300Mnt( cAlias, nReg, nOpcx )                        ���
��������������������������������������������������������������������������͹��
��� Parametros �                                         			       ���
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
���          Atualizacoes efetuadas desde a codIficacao inicial            ���
��������������������������������������������������������������������������͹��
���Programador �  Data  � BOPS �             Motivo da Alteracao           ���
��������������������������������������������������������������������������͹��
���            �xx/xx/02�xxxxxx�                                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

Function TMSA300Mnt(cAlias,nReg,nOpcx)
      
Local aArea     := GetArea()
Local aAreaDUX  := DUX->( GetArea() )

Local aInfo     := {}
Local aPosObj   := {} 
Local aObjects  := {}                        
Local aSize     := MsAdvSize() 

Local aTitles   := {}
Local aPages    := {}

Local cCadastro := STR0001 //"Tabela de Seguro"

Local nGd1      := 0 
Local nGd2      := 0 
Local nGd3      := 0 
Local nGd4      := 0 
Local nLoop     := 0 

Local oDlg
Local oFolder
Local oEnchoice
Local nOpca		 := 0
Local cSeekKey
Local nOpc
Local cContrato
Local cItem
Local aAlter

Private nFolder := 1
Private aHeader := {}
Private aCols   := {}
Private aGets   := {}
Private aTela   := {}

//������������������������������������������������������Ŀ
//� Define as posicoes da Getdados a partir do folder    �
//��������������������������������������������������������

aObjects := { { 100, 065, .T., .T. },;
					{ 100, 100, .T., .T. } }

aInfo		:= { aSize[1], aSize[2], aSize[3], aSize[4], 5, 5 } 

aPosObj	:= MsObjSize( aInfo, aObjects, .T. ) 

nGd1 := 2
nGd2 := 2
nGd3 := aPosObj[2,3]-aPosObj[2,1]-15 
nGd4 := aPosObj[2,4]-aPosObj[2,2]-4 

//������������������Ŀ
//� Carrega Enchoice �
//��������������������

RegToMemory( "DU4", nOpcx == 3 )

//������������������Ŀ
//� Carrega Folder   �
//��������������������

TMSA300Fol( nOpcx )

If Len(aFolder)==0
	Help("",1,"TMSA30002") //-- Nao Existem componentes cadastrados para a tabela de seguro ...
	Return Nil
EndIf
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

oEnchoice := MsMGet():New( cAlias ,nReg, nOpcx, , , , , aPosObj[1], aAlter, 3,,,,,, .T. )

//������������������Ŀ
//� Desenha Folders  �
//��������������������

oFolder := TFolder():New(	aPosObj[2,1],aPosObj[2,2],aTitles,aPages, oDlg,,,,.T.,.F.,;
									aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])

//������������������������������������������������������Ŀ
//� Carrega as GetDados na Ordem INVERSA de Apresentacao �
//��������������������������������������������������������

For nLoop := Len( aFolder ) TO 1 STEP - 1
	aHeader := aClone( aFolder[nLoop][4] )
	aCols   := aClone( aFolder[nLoop][5] )
	aFolder[nLoop][8] := MSGetDados():New(	nGd1,nGd2,nGd3,nGd4,nOpcx,;
															aFolder[nLoop][6],aFolder[nLoop][7],"",nOpcx!=2,aFolder[nLoop][9],,,,,,,,;
															oFolder:aDialogs[nLoop]	)

	aFolder[nLoop][8]:oBrowse:lDisablePaint := .T.
	aFolder[nLoop][8]:nMax := 99999 //-- Qtde. de linhas


	//�����������������������������Ŀ
	//� Acerta OBRIGAT da MsGetDados�
	//�������������������������������

	TMSObgGetDados( aFolder[nLoop][8] )

Next nI	

//������������������������������Ŀ
//� Habilita o Trocador de Folder�
//��������������������������������

oFolder:bSetOption:={|nAtu| TMSA300Chg( nAtu, oFolder:nOption ) }

//�����������������������������������Ŀ
//� Chama Localizador de Folder Ativo �
//� Desenha a EnchoiceBar             �
//� Ativa Obrigat da Enchoice         �
//� Ativa Obrigat das GetDados        �
//� Ativa Dialog  Principal           �
//�������������������������������������

ACTIVATE MSDIALOG oDlg ON INIT ( TMSA300Loc( nOpcx, oFolder, aFolder),;                                                                                                                
									TMSA300Bar(oDlg, {||nOpca:=1,If(TMSA300Ok(oFolder:nOption, nOpcx) ,;
											If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},;
												{||oDlg:End()}, nOpcx) )

If nOpcx!= 2 .And. nOpca==1

	Begin Transaction      
		                           	
		//������������������������������Ŀ
		//� Efetua a Gravacao de Tudo    �
		//��������������������������������
		TMSA300Grv( nOpcx )
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

Return NIL

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa   �  TMSA300   � Autor �Patricia A. Salomao � Data � 28/02/02 ���
��������������������������������������������������������������������������͹��
���             Troca de Folder							 				   ���
��������������������������������������������������������������������������͹��
��� Sintaxe    �  TMSA300Chg( nTargetFolder, nSourceFolder )               ���
��������������������������������������������������������������������������͹��
��� Parametros �                                         			       ���
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
���          Atualizacoes efetuadas desde a codIficacao inicial            ���
��������������������������������������������������������������������������͹��
���Programador �  Data  � BOPS �             Motivo da Alteracao           ���
��������������������������������������������������������������������������͹��
���            �xx/xx/02�xxxxxx�                                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
STATIC FUNCTION TMSA300Chg( nTargetFolder, nSourceFolder )

Local nI
Local lRetorno
Local lEmpty 	:= .F.

//���������������������������������Ŀ
//� Se a GetDados nao esta deletada �
//�����������������������������������

If !Acols[1][Len(aHeader)+1]

	//������������������������������������������������Ŀ
	//� VerIfica se os campos obrigatorios estao vazios�
	//��������������������������������������������������

	Aeval( aFolder[nSourceFolder][8]:aPosCol, { |aPosCol| 	If ( !lEmpty .AND. ;
																						Empty( aCols[1][aPosCol[2]] ), ;
																						lEmpty := .T.	, NIL ) } )
	//���������������������������������������������������Ŀ
	//� Se TODOS estiverem vazios e nao sofre modIficacao �
	//� deleta para passar no 'OBRIGAT' 						�
	//�����������������������������������������������������

	If lEmpty .AND. ! aFolder[nSourceFolder][8]:lChgField
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
	aFolder[	nSourceFolder][5] := aClone( aCols )
	n := Max( aFolder[nTargetFolder][8]:oBrowse:nAt,1)

	//������������������������������������������������������Ŀ
	//� Grava aHeader e Acols a partir do aFolder            �
	//��������������������������������������������������������
	aHeader := aClone( aFolder[nTargetFolder][4] )
	aCols   := aClone( aFolder[nTargetFolder][5] )

	//������������������������������������������������Ŀ
	//� VerIfica se os campos obrigatorios estao vazios�
	//��������������������������������������������������

   lEmpty := .F.
	Aeval( aFolder[nTargetFolder][8]:aPosCol, { |aPosCol| 	If ( !lEmpty .AND. ;
																						Empty( aCols[1][aPosCol[2]] ), ;
																						lEmpty := .T.	, NIL ) } )
	//���������������������������������������������������Ŀ
	//� Se TODOS estiverem vazios e nao sofre modIficacao �
	//� dah RECALL porque esta funcao DELETOU !!          �
	//�����������������������������������������������������

	If aCols[1][Len(aHeader)+1] .AND. lEmpty .AND. ;
      ! aFolder[nTargetFolder][8]:lChgField
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

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa   �  TMSA300   � Autor �Patricia A. Salomao � Data � 28/02/02 ���
��������������������������������������������������������������������������͹��
���             Gravacao da Enchoice e das GetDados dos Folders            ���
��������������������������������������������������������������������������͹��
��� Sintaxe    � TMSA300Grv( nOpcx, cMasterAlias, cSlaveAlias,  ;          ���
���            �             nSlaveOrder, cSlaveSeek, bSlaveFor,;          ���
���            �             bSlaveWhile, bMasterRec, bSlaveRec  )         ���
��������������������������������������������������������������������������͹��
��� Parametros �                                         			       ���
���         01 � nOpcx        - Opcao do aRotina                           ���
���         02 � cMasterAlias - Alias da Enchoice ( Pai )                  ���
���         03 � cSlaveAlias  - Alias da GetDados ( Filhos )               ���
���         04 � nSlaveOrder  - Ordem para Pesquisa dos Filhos             ���
���         05 � cSlaveSeek   - Chave para Pesquisa dos Filhos             ���
���         06 � cSlaveFor    - 'For' para Pesquisa dos Filhos             ���
���         07 � bSlaveWhile  - 'While' para Pesquisa dos Filhos           ���
���         08 � bMasterRec   - Gravacao de campos adicionais no Master    ���
���         09 � cbSlaveRec   - Gravacao de campos adicionais no Slave     ���
��������������������������������������������������������������������������͹��
��� Retorno    � .T. se a Troca de Folder foi permitida                    ���
��������������������������������������������������������������������������͹��
��� Uso        � SigaTMS - Gestao de Transportes                           ���
��������������������������������������������������������������������������͹��
��� Comentario � - Efetua a gravacao de TUDO, Enchoice e Todas as GetDados ���
���            � - O campo cbSlaveRec eh uma String porem em ForMATO de    ���
���            � codeblock, porque o ultimo parametro eh o nome do campo   ���
���            � que vai armazenar o Numero do Folder.                     ���
��������������������������������������������������������������������������͹��
���          Atualizacoes efetuadas desde a codIficacao inicial            ���
��������������������������������������������������������������������������͹��
���Programador �  Data  � BOPS �             Motivo da Alteracao           ���
��������������������������������������������������������������������������͹��
���            �xx/xx/02�xxxxxx�                                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
STATIC FUNCTION TMSA300Grv(nOpcx, cMasterAlias, cSlaveAlias, nSlaveOrder, ;
									cSlaveSeek, bSlaveFor, bSlaveWhile, bMasterRec, cbSlaveRec  )

Local aArea      		:=	GetArea()
Local lRetorno   		:=	.T. 
Local aNoEmptyField	

Default cMasterAlias :=	"DU4"
Default cSlaveAlias	:=	"DU5"
Default nSlaveOrder	:=	1
Default cSlaveSeek	:=	M->DU4_FILIAL + M->DU4_TABSEG + M->DU4_TPTSEG

Default bSlaveFor    := { || .T. } 
Default bSlaveWhile	:= { || 	DU5->DU5_FILIAL + DU5->DU5_TABSEG + DU5->DU5_TPTSEG + DU5->DU5_COMSEG}
Default bMasterRec   := { || NIL } 

//��������������������������������������������������Ŀ
//� Campos a serem gravados alem do ACOLS ( Slave )  �
//����������������������������������������������������

Default cbSlaveRec   := "{ || " + ; 
								"DU5->DU5_TABSEG := M->DU4_TABSEG , DU5->DU5_TPTSEG := M->DU4_TPTSEG, " +;
								"DU5->DU5_COMSEG := '"

//�������������������������������Ŀ
//�Gravacao das Getdados ( Slave )�
//���������������������������������

If nOpcx <> 5 // Deleta
	Aeval( aFolder, { |aFolderGetDados, nI, cFolder | cFolder := aFolderGetDados[1], bRecFields := &(cbSlaveRec + cFolder + "' }"), ;
																		TMSRecGetDados( 	cSlaveAlias, aFolderGetDados[3], aFolderGetDados[4], ;
																		aFolderGetDados[5], bRecFields, aNoEmptyFields ) } )
Else
	( cSlaveAlias )->( dbSetOrder( nSlaveOrder ) )
	( cSlaveAlias )->( MsSeek( cSlaveSeek	) )
	( cSlaveAlias )->( dbEval( { ||	RecLock( cSlaveAlias, .F. ), dbDelete(), MsUnlock() },bSlaveFor, ;
												{ || 	!Eof() .AND. Eval( bSlaveWhile ) = cSlaveSeeK } ) )												
EndIf

//�������������������������������Ŀ
//�Gravacao da Enchoice ( Master )�
//���������������������������������

RecLock( cMasterAlias, nOpcx== 3 )

If nOpcx <> 5
	Aeval( dbStruct(), { |	aFieldName, nI | 	FieldPut( nI, ;
															If( 	'FILIAL' $ aFieldName[1],;
																	xFilial( cMasterAlias ), ;
																	M->&( aFieldName[1] ) ) ) } ) 
	//���������������������������������������������������Ŀ
	//�Gravacao Adicional da Enchoice se houver ( Master )�
	//�����������������������������������������������������
	Eval( bMasterRec )
Else
	dbDelete()   
	
EndIf

MsUnLockAll()
RestArea( aArea )

Return NIL

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa   �  TMSA300   � Autor �Patricia A. Salomao � Data � 28/02/02 ���
��������������������������������������������������������������������������͹��
���             Valida Tudo antes da Gravacao                              ���
��������������������������������������������������������������������������͹��
��� Sintaxe    � TMSA300Ok( nSourceFolder, nOpcx )                         ���
��������������������������������������������������������������������������͹��
��� Parametros � nSourceFolder - Folder Atual              			       ���
��������������������������������������������������������������������������͹��
��� Retorno    � .T. se a validacao foi aceita                             ���
��������������������������������������������������������������������������͹��
��� Uso        � SigaTMS - Gestao de Transportes                           ���
��������������������������������������������������������������������������͹��
��� Comentario � - Valida Folder a Folder comecando pelo atual             ���
���            � - Checa se existe PELO MENOS UM Folder preenchido         ���
��������������������������������������������������������������������������͹��
���          Atualizacoes efetuadas desde a codIficacao inicial            ���
��������������������������������������������������������������������������͹��
���Programador �  Data  � BOPS �             Motivo da Alteracao           ���
��������������������������������������������������������������������������͹��
���            �xx/xx/02�xxxxxx�                                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function TMSA300Ok( nSourceFolder, nOpcx )

Local lReturn := .F.
Local aSavHead := aClone(aHeader)
Local aSavCols := aClone(aCols)
Local nSavN    := N
Local nLoop    := 0 
Local lEmpty   := .F.     
Local nPosValCob,nPosValPag,nPosCod

//������������������������������������������������������Ŀ
//� Testa a Inclusao de chave Duplicada  	       	     � 
//��������������������������������������������������������    
If nOpcx == 3 .And. !TMSA300Inc()
	Return .F.
EndIf

//������������������������������������������������������Ŀ
//� VerIfica se existe algum campo obrigatorio em Branco �
//��������������������������������������������������������
Aeval( aFolder[nSourceFolder][8]:aPosCol, { |aPosCol| 	If ( !lEmpty .AND. ;
																					Empty( aCols[1][aPosCol[2]] ), ;
																					lEmpty := .T.	, NIL ) } )
//�����������������������������������������������Ŀ
//� Se estah vazio e nao sofreu modIficacao deleta�
//�������������������������������������������������
If lEmpty .AND. ! aFolder[nSourceFolder][8]:lChgField
	aCols[1][Len(aHeader)+1] := .T.
EndIf

lEmpty := .T.

If ( aFolder[nSourceFolder][8]:TudoOk() ) 

	aFolder[nSourceFolder][4] 	:= aClone( aHeader )
	aFolder[	nSourceFolder][5] 	:= aClone( aCols )
	n := Max(aFolder[nSourceFolder][8]:oBrowse:nAt,1)
	nPosValCob:=Ascan(aHeader, {|x| AllTrim(x[2]) == "DU5_VALCOB"} )
	nPosValPag:=Ascan(aHeader, {|x| AllTrim(x[2]) == "DU5_VALPAG"} )		
	nPosCod   :=Ascan(aHeader, {|x| AllTrim(x[2]) == "DU5_CODPRO"} )				

	lEmpty  := If( lEmpty, Ascan( aFolder[nSourceFolder][5], { |e| e[Len(e)] == .F. } ) = 0, lEmpty )

	lReturn := .T.

	For nLoop := 1 TO Len( aFolder )

		If nLoop == nSourceFolder
			Loop
		EndIf
		
		aHeader := aClone( aFolder[nLoop][4] )
		aCols   := aClone( aFolder[nLoop][5] )
		n := Max(aFolder[nLoop][8]:oBrowse:nAt,1)
		If !( aFolder[nLoop][8]:TudoOk() ) 
			lReturn := .F.
			Exit
        Else
			lEmpty  := If( lEmpty, Ascan( aCols, { |e| e[Len(e)] == .F. }  ) = 0, lEmpty )
		EndIf			

	Next nLoop
	
EndIf

If lReturn .And. lEmpty
	Help(" ",1,"TMSA01006") //"Todas as 'Pastas' estao vazias !!"
	lReturn := .F.
EndIf
           
aHeader := aClone(aSavHead)
aCols   := aClone(aSavCols)
N       := nSavN      

Return( lReturn )
	
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa   �  TMSA300   � Autor �Patricia A. Salomao � Data � 28/02/02 ���
��������������������������������������������������������������������������͹��
���             Enchoice bar especIfica                                    ���
��������������������������������������������������������������������������͹��
��� Sintaxe    � TMSA300Bar( oDlg, bOk, bCancel, nOpcx )                   ���
��������������������������������������������������������������������������͹��
��� Parametros �                                         			       ���
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
���          Atualizacoes efetuadas desde a codIficacao inicial            ���
��������������������������������������������������������������������������͹��
���Programador �  Data  � BOPS �             Motivo da Alteracao           ���
��������������������������������������������������������������������������͹��
���            �xx/xx/02�xxxxxx�                                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

STATIC FUNCTION TMSA300Bar( oDlg, bOk, bCancel, nOpcx )

Local aButtons 	 := {}
Local nCntFor      := 0
Local aSomaButtons  := {}

//-- Ponto de entrada para incluir botoes na enchoicebar
If	ExistBlock('TM300BUT')
	aSomaButtons:=ExecBlock('TM300BUT',.F.,.F.,{nOpcx})
	If	ValType(aSomaButtons) == 'A'
		For nCntFor:=1 To Len(aSomaButtons)
			AAdd(aButtons,aSomaButtons[nCntFor])
		Next
	EndIf
EndIf

Return ( EnchoiceBar( oDlg, bOK, bCancel,, aButtons ) )

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa   �  TMSA300   � Autor �Patricia A. Salomao � Data � 28/02/02 ���
��������������������������������������������������������������������������͹��
���             Localizador de Folder Preenchido                           ���
��������������������������������������������������������������������������͹��
��� Sintaxe    � TMSA300Loc( nOpcx, oFolder)                               ���
��������������������������������������������������������������������������͹��
��� Parametros �                                         			       ���
���         01 � nOpcx   - Opcao da Mbrowse                                ���
���         02 � oFolder - Objeto Folder                                   ���
��������������������������������������������������������������������������͹��
��� Retorno    � NIL                                                       ���
��������������������������������������������������������������������������͹��
��� Uso        � SigaTMS - Gestao de Transportes                           ���
��������������������������������������������������������������������������͹��
��� Comentario � - Na Inclusao deleta TODOS os folders menos o 1           ���
���            � - Caso contrario Localiza o primeiro folder preenchido    ���
���            � - Se o Folder 1 nao estiver preenchido :                  ���
���            �   - Deleta o Folder 1      					       	   ���
���            �   - Forca Troca do Folder para o Primeiro Preenchido      ���
���            �   - Troca Folder dentro do objeto Folder      			   ���
���            �   - Refresh para refletir a mudanca no Objeto Folder      ���
��������������������������������������������������������������������������͹��
���          Atualizacoes efetuadas desde a codIficacao inicial            ���
��������������������������������������������������������������������������͹��
���Programador �  Data  � BOPS �             Motivo da Alteracao           ���
��������������������������������������������������������������������������͹��
���            �xx/xx/02�xxxxxx�                                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

FUNCTION TMSA300Loc( nOpcx, oFolder, aFolder)

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
	For nI := 1 TO Len( aFolder )
		
		//���������������������Ŀ
		//� Candidato a delecao �
		//�����������������������
		If Len( aFolder[nI][5] ) == 1
			lEmpty := .F.

			For nJ := 1 TO Len( aFolder[nI][8]:aPosCol ) // Valida Obrigat
				If !lEmpty .AND. Empty( aFolder[nI][5][1][aFolder[nI][8]:aPosCol[nJ, 2]] )
					lEmpty := .T.
					EXIT
				EndIf	
			Next nJ

			If lEmpty
				//����������������������������������������������������Ŀ
				//� Deleta porque a FillGetDados colocou para Inclusao �
				//������������������������������������������������������

				aFolder[nI][5][1][Len( aFolder[nI][4] ) + 1] := .T.

				//���������������������������������������������������Ŀ
				//� Se nao eh o Folder 1 e ainda nao Localizou nenhum �
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

EndIf

//���������������������������Ŀ
//� Habilita Todos os Folders �
//�����������������������������

Aeval( aFolder, { |aFold| 	aFold[8]:oBrowse:lDisablePaint := .F. } ) 

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

	TMSA300Chg( nFirstFolderOk, 1 )

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
��� Programa   �  TMSA300   � Autor �Patricia A. Salomao � Data � 28/02/02 ���
��������������������������������������������������������������������������͹��
���             Carrega todos os Folder no aFolder				           ���
��������������������������������������������������������������������������͹��
��� Sintaxe    � TMSA300Fol(nOpcx, cAlias, nOrder, cSeekKey, bSeekWhile,;  ���
���            �			bSeekFor, aNoFields, aYesFields, cLinhaOk, ;   ���
���            �			cTudoOk )                                      ���
��������������������������������������������������������������������������͹��
��� Parametros �                                         			       ���
���         01 � nOpcx      - Opcao do Mbrowse                             ���
���         02 � cAlias     - Alias                                        ���
���         03 � nOrder     - Ordem                                        ���
���         04 � cSeekKey   - Chave de Seek para montar aCols              ���
���         05 � bSeekWhile - Condicao While                               ���
���         06 � bSeekFor   - Condicao For                                 ���
���         07 � aNoFields  - Campos a serem excluidos                     ���
���         08 � aYesFields - Campos a serem incluidos                     ���
���         09 � cLinhaOk   - Valida Linha                                 ���
���         10 � cTudoOk    - Valida Tudo                                  ���
��������������������������������������������������������������������������͹��
��� Retorno    � NIL                                                       ���
��������������������������������������������������������������������������͹��
��� Uso        � SigaTMS - Gestao de Transportes                           ���
��������������������������������������������������������������������������͹��
��� Comentario � Possui Ponto de Entrada p/ Mudanca de Folders pelo usuario���
���            �                                                           ���
���            � Estrutura do Array de Folders                             ���
���            �                                                           ���
���            � [1] -> Tipo "N" , Numero do Folder ( DU3_COMSEG )         ���
���            � [2] -> Tipo "C" , Titulo do Folder                        ���
���            � [3] -> Tipo "A" , aColsRecno ( Recno() de cada aCols )    ���
���            � [4] -> Tipo "A  , aHeader   da GetDados do Folder         ���
���            � [5] -> Tipo "A" , aCols     da GetDados do Folder         ���
���            � [6] -> Tipo "C" , cLinhaOk  da GetDados do Folder         ���
���            � [7] -> Tipo "C" , cTudoOk   da GetDados do Folder         ���
���            � [8] -> Tipo "O" , oGetDados deste Folder                  ���
���            � [9] -> Tipo "A" , Campos que podem ser alterados          ���
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
���            �                                                           ���
��������������������������������������������������������������������������͹��
���          Atualizacoes efetuadas desde a codIficacao inicial            ���
��������������������������������������������������������������������������͹��
���Programador �  Data  � BOPS �             Motivo da Alteracao           ���
��������������������������������������������������������������������������͹��
���            �xx/xx/02�xxxxxx�                                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

FUNCTION TMSA300Fol( 	nOpcx, cAlias, nOrder, cSeekKey, bSeekWhile, bSeekFor, ;
										aNoFields, aYesFields, cLinhaOk, cTudoOk, aAlter )

Local nPosValAte	
Local nPosValor	
Local nPosValAju	
Local nPosPerAju	

Local aSX3Box
Local cFolderName
Local nAtalho			:= 0

Default cAlias 		:= "DU5"
Default nOrder       := 1
Default cSeekKey     :=	xFilial( "DU4" ) + M->DU4_TABSEG + DU4->DU4_TPTSEG

Default bSeekWhile	:= { || 	DU5->DU5_FILIAL + DU5->DU5_TABSEG + DU5->DU5_TPTSEG + DU5->DU5_COMSEG }

Default bSeekFor     := { || .T. } 

Default aNoFields		:= { 	"DU5_TABSEG", "DU5_TPTSEG", "DU5_COMSEG" }

Default cLinhaOk		:= "TMSA300LinOk"

aFolder := {}

DU5->( dbSetOrder( 1 ) )
DU3->( dbSetOrder( 1 ) )
DU3->( dbGoTop() )

Do While ! DU3->( Eof() )

	//-- Somente exibe todos componentes na inclusao ou alteracao
	If nOpcx <> 3 .And. nOpcx <> 4
		//-- Verifica se existe tabela para o componente
		If DU5->( !MsSeek( xFilial( 'DU5' ) + M->DU4_TABSEG + M->DU4_TPTSEG + DU3->DU3_COMSEG ) )
			DU3->( DbSkip() )
			Loop
		EndIf
	EndIf					

	aHeader := {}
	aCols   := {}
	nAtalho := 1

	Aadd( aFolder, {	DU3->DU3_COMSEG, ;
							AllTrim( DU3->DU3_DESCRI ), 	;
							TMSFillGetDados(	nOpcx, ;
													cAlias,	;
													nOrder,	;
													cSeekKey + DU3->DU3_COMSEG, ; 
													bSeekWhile, ;
													bSeekFor  , ;
													aNoFields ,	;
													aYesFields  ;
												 ), ;
							aClone( aHeader ), ;
							aClone( aCols ), ;
							cLinhaOk, ;
							cTudoOk, ;
							NIL, ;
							aAlter } )

	//-- Define letra de atalho para acessar o folder
	If	!Empty( DU3->DU3_ATALHO )
		nAtalho := At( DU3->DU3_ATALHO, UPPER(aFolder[ Len(aFolder), 2 ]) )
		If Empty( nAtalho )
			nAtalho := 1
		EndIf
	EndIf

	aFolder[ Len(aFolder), 2 ] := Stuff( aFolder[ Len(aFolder), 2 ], nAtalho, 0, '&' )

	DU3->( dbSkip() )

EndDo	

Return NIL		 	

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa   �  TMSA300   � Autor �Patricia A. Salomao � Data � 28/02/02 ���
��������������������������������������������������������������������������͹��
���             Valida Linha da GetDados								   ���
��������������������������������������������������������������������������͹��
��� Sintaxe    �  TMSA300LinOk()                                           ���
��������������������������������������������������������������������������͹��
��� Parametros � Nenhum                                   			       ���
��������������������������������������������������������������������������͹��
��� Retorno    � .T. se a linha e'  valida                                 ���
��������������������������������������������������������������������������͹��
��� Uso        � SigaTMS - Gestao de Transportes                           ���
��������������������������������������������������������������������������͹��
���          Atualizacoes efetuadas desde a codIficacao inicial            ���
��������������������������������������������������������������������������͹��
���Programador �  Data  � BOPS �             Motivo da Alteracao           ���
��������������������������������������������������������������������������͹��
���            �xx/xx/02�xxxxxx�                                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

FUNCTION TMSA300LinOk()

Local lRet       := .T.

If !GDdeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
	//-- Analisa se ha itens duplicados na GetDados.
	lRet := GDCheckKey( { 'DU5_CODPRO','DU5_CDRORI','DU5_CDRDES' }, 4 )

	If lRet .And. ! Empty(GDFieldGet( 'DU5_CDRORI', n )) .And. Empty(GDFieldGet( 'DU5_CDRDES', n ))
		Help('',1,'OBRIGAT2',,RetTitle('DU5_CDRDES'),4,1) //Um ou alguns campos obrigatorios nao foram preenchidos no Browse"
		lRet := .F.
	EndIf
	
	If lRet .And. ! Empty(GDFieldGet( 'DU5_CDRDES', n )) .And. Empty(GDFieldGet( 'DU5_CDRORI', n ))
		Help('',1,'OBRIGAT2',,RetTitle('DU5_CDRORI'),4,1) //Um ou alguns campos obrigatorios nao foram preenchidos no Browse"
		lRet := .F.
	EndIf

EndIf

Return lRet
	
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa   �  TMSA300   � Autor �Patricia A. Salomao � Data � 28/02/02 ���
��������������������������������������������������������������������������͹��
���             Valida Coluna da GetDados								   ���
��������������������������������������������������������������������������͹��
��� Sintaxe    �  TMSA300Valid()                                           ���
��������������������������������������������������������������������������͹��
��� Parametros � Nenhum                                   			       ���
��������������������������������������������������������������������������͹��
��� Retorno    � .T. se a coluna eh valida                                 ���
��������������������������������������������������������������������������͹��
��� Uso        � SigaTMS - Gestao de Transportes                           ���
��������������������������������������������������������������������������͹��
���          Atualizacoes efetuadas desde a codIficacao inicial            ���
��������������������������������������������������������������������������͹��
���Programador �  Data  � BOPS �             Motivo da Alteracao           ���
��������������������������������������������������������������������������͹��
���            �xx/xx/02�xxxxxx�                                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

FUNCTION TMSA300Valid()

Local lReturn 		:= .T.

DO CASE

	//������������������������������������������Ŀ
	//� Esta deletado                            �
	//��������������������������������������������

	CASE 	aCols[n][Len( aHeader ) + 1]
			lReturn := .T.

			
ENDCASE

Return lReturn

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa   �  TMSA300   � Autor �Patricia A. Salomao � Data � 28/02/02 ���
��������������������������������������������������������������������������͹��
���             Testa Inclusao Duplicada								   ���
��������������������������������������������������������������������������͹��
��� Sintaxe    �  TMSA300Inc()                                             ���
��������������������������������������������������������������������������͹��
��� Parametros � Nenhum                                   			       ���
��������������������������������������������������������������������������͹��
��� Retorno    � .T. se a chave eh valida                                  ���
��������������������������������������������������������������������������͹��
��� Uso        � SigaTMS - Gestao de Transportes                           ���
��������������������������������������������������������������������������͹��
��� Comentario �                                                           ���
���            �                                                           ���
��������������������������������������������������������������������������͹��
���          Atualizacoes efetuadas desde a codIficacao inicial            ���
��������������������������������������������������������������������������͹��
���Programador �  Data  � BOPS �             Motivo da Alteracao           ���
��������������������������������������������������������������������������͹��
���            �xx/xx/02�xxxxxx�                                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
FUNCTION TMSA300Inc()

Local lRet := .T.
Local aArea:= DU4->(GetArea())
DU4->(dbSetOrder(1))		 

If DU4->(MsSeek(xFilial("DU4")+M->DU4_TABSEG + M->DU4_TPTSEG))			
    Help("",1,"JAGRAVADO") //Ja existe registro com esta informacao. 
    lRet := .F.
EndIf      

RestArea(aArea)

Return lRet
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa   �  TMSA300   � Autor �Patricia A. Salomao � Data � 28/02/02 ���
��������������������������������������������������������������������������͹��
���             Copia Tabela de Seguro 									   ���
��������������������������������������������������������������������������͹��
��� Sintaxe    �  TMSA300Cop()                                             ���
��������������������������������������������������������������������������͹��
��� Parametros � Nenhum                                   			       ���
��������������������������������������������������������������������������͹��
��� Retorno    � NIL                                                       ���
��������������������������������������������������������������������������͹��
��� Uso        � SigaTMS - Gestao de Transportes                           ���
��������������������������������������������������������������������������͹��
��� Comentario �                                                           ���
���            �                                                           ���
��������������������������������������������������������������������������͹��
���          Atualizacoes efetuadas desde a codIficacao inicial            ���
��������������������������������������������������������������������������͹��
���Programador �  Data  � BOPS �             Motivo da Alteracao           ���
��������������������������������������������������������������������������͹��
���            �xx/xx/02�xxxxxx�                                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
FUNCTION TMSA300Cop()
/*

LOCAL oDlg
LOCAL cNewOrig  := Space(Len(DU5->DU5_CDRORI))
LOCAL aAreaDU4  := DU4->(GetArea())
LOCAL nRecDU4   := DU4->( Recno() )
LOCAL nRecDU5   := DU5->( Recno() )
LOCAL nOpc      := 2
LOCAL cCodPas, cDesc, aArea
LOCAL cKeyDU4   := DU4->DU4_CDRORI
LOCAL cDescRegOri 
LOCAL cKeyDU5
LOCAL cFileName := CriaTrab( NIL, .F. )

//�������������������������������������������������������������������Ŀ
//�	Tabelas fora da vigencia e inativas nao poderao ser copiadas      �
//���������������������������������������������������������������������	
DUR->(dbSetOrder(1))
If DUR->(MsSeek(xFilial('DUR')+DU4->DU4_TABSEG+DU4->DU4_TPTSEG))
	If DUR->DUR_ATIVO == '2' .Or. (dDataBase < DUR->DUR_DATDE .Or. ;
	     IIF(!Empty(DUR->DUR_DATATE),dDataBase > DUR->DUR_DATATE,.F.))
	   Help("",1,"TMSA010O" ) 
	   Return .F.
	EndIf               
EndIf	

DUY->(dbSetOrder(1))
DUY->( MsSeek( xFilial('DUY') + cKeyDU4, .F.) )

cDescRegOri := DUY->DUY_DESCRI
cDescNewOri := ""
//��������������������������Ŀ
//�Para Funcionar ExistChav !�
//����������������������������

Inclui := .T. 

DEFINE MSDIALOG oDlg TITLE OemToAnsi( STR0008 ) + " : " +  DU4->DU4_TABSEG + "/" +DU4->DU4_TPTSEG From 9,0 To 18,50 OF oMainWnd 

	@ 010,010 SAY 	 OemToAnsi( STR0008 ) SIZE 100,15 COLOR CLR_HBLUE PIXEL  //"Copia Tabelas de Seguro"
	@ 030,010 SAY 	 OemToAnsi( STR0009 ) SIZE 100,15 COLOR CLR_HBLUE PIXEL //Da Origem
	@ 030,053 SAY 	 cKeyDU4+ " - " + cDescRegOri  SIZE 200,15 PIXEL 
	@ 046,010 SAY 	 OemToAnsi( STR0010 ) SIZE 100,15 COLOR CLR_HBLUE PIXEL //Para a Origem
                                                                 										
	@ 046,050 MSGET cNewOrig  F3 "DUY"  PICTURE  PesqPict("DU4","DU4_CDRORI") SIZE 6,9 WHEN ( DbGoTo( nRecDU4 ), .T. ) ;
									VALID (cNewOrig<>DU4_CDRORI) .And. TMSA300Cpo(cNewOrig) PIXEL

	@ 046,080 MSGET  cDescNewOri  When .F.  SIZE 70,9  OF oDlg PIXEL 

	DEFINE SBUTTON FROM 12	,166	TYPE 1 ACTION (nOpc := 1,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 26.5,166	TYPE 2 ACTION (nOpc := 2,oDlg:End()) ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

IF nOpc == 1 .AND. Aviso( "AVISO", STR0017	 + " " + DU4->DU4_CDRORI + " " + ;  //"Copiar todas as Tabela de Seguro de Origem"
									STR0010 + " " + cNewOrig, { STR0014, STR0015},,STR0016) == 1  //"Para a Origem"###"Confirma"###"Cancela"###"Confirmacao"

	cKeyDU4 := xFilial("DU4") + DU4->DU4_CDRORI                  

	CursorWait()

	dbSelectArea( "DU4" )
    dbSetOrder(2)
	MsSeek(xFilial()+ DU4->DU4_CDRORI)
    
	DO WHILE ckeyDU4 == DU4_FILIAL+ DU4_CDRORI                     
	
	    aArea :=DU4->(GetArea())
	    
	    If  DU4->(MsSeek(xFilial()+cNewOrig+DU4_CDRDES+DU4_TABSEG+DU4_TPTSEG))
		    RestArea(aArea)		                                                   	    
 			DU4->(dbSkip())
 			Loop	    
	    EndIf	        
	    
	    RestArea(aArea)		                                                   

		//�������������������������������������������������������������������Ŀ 		
		//� Verifica se a Nova Regiao Origem e' igual a Regiao Destino        �
		//���������������������������������������������������������������������		    
	    If (cNewOrig == DU4_CDRDES)
 			 DU4->(dbSkip())
 			 Loop	    	    
	    EndIf
	    	    
		//�������������������������������������������������������������������Ŀ
		//�	Tabelas fora da vigencia e inativas nao poderao ser ajustadas     �
		//���������������������������������������������������������������������	
		If DUR->(MsSeek(xFilial('DUR')+DU4->DU4_TABSEG+DU4->DU4_TPTSEG))
			If DUR->DUR_ATIVO == '2' .Or. (dDataBase < DUR->DUR_DATDE .Or. ;
			     IIF(!Empty(DUR->DUR_DATATE),dDataBase > DUR->DUR_DATATE,.F.))
			   Help("",1,"TMSA010O" ) 
			   Return .F.
			EndIf               
		EndIf	
			    
		cKeyDU5 := xFilial("DU5") + DU4->DU4_TABSEG + DU4->DU4_TPTSEG + DU4->DU4_CDRORI + DU4->DU4_CDRDES 
		nRecDU4 := Recno()
		COPY TO &cFileName. NEXT 1	
		APPE FROM &cFileName.
		RecLock( "DU4", .F. )
		DU4->DU4_CDRORI := cNewOrig
		MsUnLock()
	
		DbSelectArea( "DU5" )
	
		MsSeek( cKeyDU5 )
		DO WHILE cKeyDU5 == xFilial("DU5") + DU5_TABSEG + DU5_TPTSEG + DU5_CDRORI + DU5_CDRDES
	
			nRecDU5 := Recno()
			COPY TO &cFileName. NEXT 1	
			APPE FROM &cFileName.
			RecLock( "DU5", .F. )
			DU5->DU5_CDRORI := cNewOrig
			MsUnLock()
	
			DU5->( DbGoTo( nRecDU5 ) )
	
			DU5->( DbSkip() )
	
		ENDDO			
        
		DbSelectArea( "DU4" )
		DU4->( DbGoTo( nRecDU4 ) )	
		DU4->( DbSkip() )

	ENDDO	

ENDIF	

DbSelectArea( "DU4" )
DU4->( DbGoto( nRecDU4 ) )
RestArea( aAreaDU4 )
CursorArrow()

*/
RETURN NIL

                       
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA300Cpo() � Autor �Patricia A. Salomao � Data � 27/05/2002 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Inicializa alguns campos a partir da Regiao Origem informada ���
���          � na Copia da Tabela de Seguro                                 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/  
Function TMSA300Cpo(cNewOrig)
Local lRet := .T.

/*
Local aAreaDU4 := DU4->(GetArea())
DU4->(dbSetOrder(2))
If DU4->(MsSeek(xFilial()+cNewOrig+DU4->DU4_CDRDES+DU4->DU4_TABSEG+DU4->DU4_TPTSEG ))
    Help("",1,"TMSA010Q")
    lRet := .F.
EndIf           

If lRet 
	If DUY->(MsSeek(xFilial()+cNewOrig))
		cDescNewOri := DUY->DUY_DESCRI
	    lRet := .T.		
	Else
	    Help("",1,"NORECNO")
	    lRet := .F.	
	EndIf    
EndIf
RestArea(aAreaDU4)

*/
	
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA300Whe� Autor �Patricia A. Salomao    � Data �28.02.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacoes antes de editar o campo                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA300Whe()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Logico                                                     ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function TMSA300Whe()

Local cCampo	:= ReadVar()  
Local nPosValCob := Ascan(aHeader, { |x| AllTrim(x[2]) == "DU5_VALCOB" } )
Local nPosValPag := Ascan(aHeader, { |x| AllTrim(x[2]) == "DU5_VALPAG" } )
Local lRet		:= .T.

If	cCampo == 'M->DU5_INTCOB'
	lRet := !Empty(aCols[n][nPosValCob] )
ElseIf	cCampo == 'M->DU5_INTPAG'
	lRet := !Empty(aCols[n][nPosValPag] )
EndIf

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
     
Private aRotina	:=	{	{ STR0002 ,"AxPesqui"  , 0, 1,0,.F. },;	//"Pesquisar"
								{ STR0003 ,"TMSA300Mnt", 0, 2,0,NIL },;	//"Visualizar"
								{ STR0004 ,"TMSA300Mnt", 0, 3,0,NIL },;	//"Incluir"
								{ STR0005 ,"TMSA300Mnt", 0, 4,0,NIL },;	//"Alterar"
								{ STR0006 ,"TMSA300Mnt", 0, 5,0,NIL } }	//"Excluir"


If ExistBlock("TM300MNU")
	ExecBlock("TM300MNU",.F.,.F.)
EndIf

Return(aRotina)

