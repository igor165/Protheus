#INCLUDE "QNCA080.CH"
#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QNCA080  � Autor � Aldo Marini Junior    � Data � 28.11.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Modelos de Passos/Etapas                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QNCA080(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function MenuDef()

Local aRotina := {{ OemToAnsi( STR0001 ), "AxPesqui"    , 0, 1,,.F.},; //'Pesquisar'
                     { OemToAnsi( STR0002 ),"QNCA080Telas", 0, 2 },; //'Visualizar'
                     { OemToAnsi( STR0003 ),"QNCA080Telas", 0, 3 },; //'Incluir'
                     { OemToAnsi( STR0004 ),"QNCA080Telas", 0, 4 },; //'Alterar'
                     { OemToAnsi( STR0005 ),"QNCA080Ext"  , 0, 5 } } //'Excluir'

Return aRotina

Function QNCA080()


Private cCadastro	:= OemToAnsi( STR0006 )	// 'Cadastro Modelos de Passos/Etapas'

//��������������������������������������������������������������Ŀ
//� Define array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
//����������������������������������������������������������������
Private aRotina := MenuDef()

DbSelectArea( "QIB" )
DbSetOrder( 1 )
DbGoTop()

mBrowse(06, 01, 22, 75, "QIB" )

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QNCA080Telas� Autor � Aldo Marini Junior  � Data � 27/11/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa generico para alteracao                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QNCA080Telas(ExpC1,ExpN2,ExpN3)                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Opcao devolvida pela funcao                        ���
���          � ExpC1 = Alias do arquivo                                   ���
���          � ExpN2 = Numero do registro                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function QNCA080Telas( cAlias, nReg, nOpc )

Local nOpcA    := 0
Local nI       := 0
Local iT       := 0
Local lInit    := .F.
Local aButtons := {}

Private oDlg
Private aTELA[0][0]
Private aGETS[0]
Private bCampo := {|nCPO| Field( nCPO ) }
Private aHeader:= {}
Private aCols  := {}
Private nUsado := 0

//��������������������������������������������������������������Ŀ
//� Salva a integridade dos campos de Bancos de Dados            �
//����������������������������������������������������������������
If nOpc == 3 	//-- Inclusao

	For nI := 1 To FCount()
		M->&(Eval(bCampo,nI)) := FieldGet(nI)
		lInit := .F.

		If ( ExistIni(Eval(bCampo,nI)) )
			lInit := .T.
			M->&(Eval(bCampo,nI)) := InitPad(GetSx3Cache(Eval(bCampo,nI),"X3_RELACAO"))
			If ( ValType(M->&(Eval(bCampo,nI))) == "C" )
				M->&(Eval(bCampo,nI)) := Padr(M->&(Eval(bCampo,nI)),GetSx3Cache(Eval(bCampo,nI),"X3_TAMANHO"))
			Endif
			If ( M->&(Eval(bCampo,nI)) == NIL )
				lInit := .F.
			EndIf
		EndIf
		If ( ! lInit )
			If ( ValType(M->&(Eval(bCampo,nI))) == "C" )
				M->&(Eval(bCampo,nI)) := Space(Len(M->&(Eval(bCampo,nI))))
			ElseIf ( ValType(M->&(Eval(bCampo,nI))) == "N" )
				M->&(Eval(bCampo,nI)) := 0
			ElseIf ( ValType(M->&(Eval(bCampo,nI))) == "D" )
				M->&(Eval(bCampo,nI)) := Ctod("  /  /  ","DDMMYY")
			ElseIf ( ValType(M->&(Eval(bCampo,nI))) == "L" )
				M->&(Eval(bCampo,nI)) := .F.
			EndIf
		EndIf
	Next
	M->QIB_FILIAL:= xFilial("QIB")
Else
    
	For iT := 1 TO FCount()
	    M->&(EVAL(bCampo,iT)) := FieldGet(iT)
	Next
	
EndIf

//�����������������������������������������������Ŀ
//� Montagem da GetDados das Etapas em ARRAY      �
//�������������������������������������������������
QNC80FGet(nOpc)

nUsado := Len(aHeader)

DEFINE MSDIALOG oDlg TITLE cCadastro FROM 09,00 TO 28,80 OF oMainWnd

EnChoice( cAlias, nReg, nOpc,,, OemToAnsi( STR0007 ) ) // "Quanto �s altera�oes?"

aButtons:= {{"AUTOM", {|| QNCA080Eta(nOpc) },OemToAnsi(STR0015),OemToAnsi(STR0026)}} // "Passos/Etapas"  //"Pas/ETa"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If( Obrigatorio( aGets, aTela ) .And. QNC80VLD(aCols),( nOpca := 1, oDlg:End() ), .f. )},;
				  {|| nOpca := 3,oDlg:End() },,aButtons)  CENTERED

If nOpc # 2
	If nOpcA == 1 .and. !Empty(M->QIB_CODIGO)
		DbSelectArea( "QIB" )
		Begin Transaction
			If nOpc == 3
				RecLock( "QIB", .T. )
			Else
				RecLock( "QIB", .F. )
			EndIf
			For ni := 1 To FCount()
				FieldPut( ni, M->&( Eval( bCampo, ni ) ) )
			Next ni
			QIB->QIB_FILIAL:= xFilial("QIB")
			MsUnlock()
			FKCOMMIT()
			QNC80GrNiv(aCols,aHeader)
		End Transaction
	EndIf
EndIf
lRefresh := .t.

Return nOpcA

/*/
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������Ŀ��
���Fun�ao	  � QNCA080EXT � Autor � Aldo Marini Junior         � Data � 28/11/00 ���
���������������������������������������������������������������������������������Ĵ��
���Descri�ao  � Exclusao de Modelos de Plano de Acao                              ���
���������������������������������������������������������������������������������Ĵ��
���Sintaxe	  � QNCA080EXT( cAlias, nReg, nOpc )                                  ���
���������������������������������������������������������������������������������Ĵ��
���Parametros � cAlias     � Alias do Arquivo                                     ���
���           � nReg       � Registro Atual ( Recno() )                           ���
���           � nOpc       � Opcao de selecao do aRotina                          ���
���������������������������������������������������������������������������������Ĵ��
���Uso		  � Generico                                                          ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
/*/
Function QNCA080EXT( cAlias, nReg, nOpc )

Local nOpcA
Local lAchou := .f.
Local aAC    := { OemToAnsi( STR0018 ), OemToAnsi( STR0019 ) } // 'Cancela' ### 'Confirma'
Local cQIB   := If( Inclui, "M", "QIB" )

If Inclui
   nOpcA := 2
Else
   Private oDlg
   Private aTELA[0][0]
   Private aGETS[0]
   nOpcA := 0

   dbSelectArea( cAlias )
   dbSetOrder( 1 )

   DEFINE MSDIALOG oDlg TITLE cCadastro  FROM 09,00 TO 28, 80 OF oMainWnd // 'Excluir'
          
   nOpcA := EnChoice( cAlias, nReg, nOpc, aAC, 'AC', OemToAnsi( STR0020 ) ) // 'Quanto � exclusao?'
   nOpcA := 1

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg, {|| nOpca := 2, oDlg:End() }, {|| nOpca := 1, oDlg:End() } )
EndIf

If nOpcA == 2
   DbSelectArea( "QI3" )
   DbGoTop()
   //���������������������������������������������������������������������Ŀ
   //� Verifica se existe cadastrado algum Plano de Acao com o modelo      �
   //�����������������������������������������������������������������������
   While !( QI3->( Eof() ) )
      If QI3->QI3_MODELO == &(cQIB+"->QIB_CODIGO")
         lAchou 	:= .t.
         Exit			
      EndIf
      QI3->(DbSkip())
   EndDo
EndIf
DbSelectArea( cAlias )
DbSetOrder( 1 )

Begin Transaction
   If nOpcA == 2
      If !lAchou
         dbSelectArea("QIC")
         dbSetOrder(1)
         //��������������������������������������������������������������������������������������������Ŀ
         //� Verifica se existe responsaveis cadastrados por tipo de documento, e se existir deleta-os. �
         //����������������������������������������������������������������������������������������������
         If DbSeek( &(cQIB+"->QIB_FILIAL+"+cQIB+"->QIB_CODIGO") )
            While !Eof() .And. &(cQIB+"->QIB_FILIAL+"+cQIB+"->QIB_CODIGO") == QIC->QIC_FILIAL + QIC->QIC_CODIGO
               RecLock( "QIC", .F.)
               dbDelete()
               MsUnlock()
               FKCOMMIT()
               DbSkip()
            Enddo
         EndIf
       
         DbSelectArea( cAlias )
         If !Inclui
            RecLock( cAlias, .F. )
            dbDelete()
            MsUnlock()
            FKCOMMIT()
         EndIf
         dbSkip()
      Else
         Help( ' ', 1, 'QNCEACAOMO' )	// Existe Plano de Acao cadastrado com este Modelo de Passos
      EndIf
   EndIf	
End Transaction

Return Nil

/*�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������Ŀ��
���Fun�ao	  � QNCA080Eta � Autor � Aldo Marini Junior         � Data � 29/11/00 ���
���������������������������������������������������������������������������������Ĵ��
���Descri�ao  � Cadastra as Etapas/Passos do Tipo de Modelo                       ���
���������������������������������������������������������������������������������Ĵ��
���Sintaxe	  � QNCA080Eta( nOpc )                                                ���
���������������������������������������������������������������������������������Ĵ��
���Parametros � nOpc       � Opcao de selecao do aRotina                          ���
���������������������������������������������������������������������������������Ĵ��
���Uso		  � Generico                                                          ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������*/

Function QNCA080Eta( nOpc )

Local oDlg1
Local nCnt
Local cCodigo   := M->QIB_CODIGO
Local cDescr    := Left( M->QIB_DESC, 50 )
Local oCodigo, oDescr

Private oGet1
Private aTELA[0][0]
Private aGETS[0]

//���������������������������������������������������������������������������������Ŀ
//� Verifica se foi digitado o codigo do Modelo de Passos/Etapas                    �
//�����������������������������������������������������������������������������������
If Empty(M->QIB_CODIGO)
	Return Nil
Endif

//���������������������������������������������������������������������������������Ŀ
//� Fim da montagem da GetDados do arquivo QIC                                      �
//�����������������������������������������������������������������������������������

DEFINE MSDIALOG oDlg1 TITLE cCadastro + " - " + OemToAnsi( STR0021 ) FROM 009,000 TO 028,080 OF oMainWnd // "Tipos de Modelos"
       	
@ 012,002 TO 043,314 OF oDlg1 PIXEL

@ 020,010 SAY OemToAnsi(STR0022) SIZE 30,07   OF oDlg1 PIXEL // "C�digo"	
@ 019,045 MSGET oCodigo VAR cCodigo          SIZE  24, 08 OF oDlg1 PIXEL

@ 032,010 SAY OemToAnsi(STR0023) SIZE 30,07   OF oDlg1 PIXEL // "Descri�ao"
@ 031,045 MSGET oDescr VAR cDescr            SIZE 170, 08 OF oDlg1 PIXEL 
oCodigo:lReadOnly:= .T.
oDescr:lReadOnly:= .T. 

oGet1 := MSGetDados():New( 046, 001, 136, 315, nOpc, "QN080LinOk","", "", If( nOpc==2, .f., .t. ), , )

ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar( oDlg1, {|| IF(QN080LinOk(),(oDlg1:End()),.F.) },{|| oDlg1:End() } )

Return Nil

/*�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������Ŀ��
���Fun�ao	  � QN080LinOk � Autor � Aldo Marini Junior         � Data � 01/12/00 ���
���������������������������������������������������������������������������������Ĵ��
���Descri�ao  � Critica Linha Digitada                                            ���
���������������������������������������������������������������������������������Ĵ��
���Sintaxe	  � QN080LinOk()                                                      ���
���������������������������������������������������������������������������������Ĵ��
���Parametros � Nao tem    �                                                      ���
���������������������������������������������������������������������������������Ĵ��
���Uso		  � Generico                                                          ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������*/

Function QN080LinOk()

Local lRet  := .t.

If !GDDeleted( n )
	lRet := oGet1:ChkObrigat( n ) 
EndIf 

Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	  � QNC80GrNiv � Autor � Aldo Marini Junior � Data � 17/04/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao  � Grava array com os subcadastros                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	  � Qnc80GrNiv(ExpA1)                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros � ExpA1 - Array contendo as informacoes iniciais do Acols   ���
�������������������������������������������������������������������������Ĵ��
���Uso		  � QNCA080                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QNC80GrNiv(AcolsAux,aHeadNiv)

Local nCnt  := 0
Local nCpo

DbSelectArea("QIC")
DbSetOrder(1)
If DbSeek( M->QIB_FILIAL + M->QIB_CODIGO )
	While !Eof() .And. M->QIB_FILIAL + M->QIB_CODIGO == QIC->QIC_FILIAL + QIC->QIC_CODIGO
		RecLock("QIC",.F.)
		dbDelete()
		MsUnLock()
		FKCOMMIT()
		dbSkip()
	Enddo
Endif

For nCnt:= 1 To Len(AcolsAux)
	If !AcolsAux[nCnt,nUsado+1] // Verifica se o item foi deletado
		RecLock("QIC",.T.)
		For nCpo := 1 To Len(aHeadNiv)
			If aHeadNiv[nCpo, 10] <> "V"
				QIC->(FieldPut(FieldPos(Trim(aHeadNiv[nCpo,2])),AcolsAux[nCnt,nCpo]))
			EndIf
		Next nCpo
		QIC->QIC_FILIAL := xFilial("QIC")
		QIC->QIC_CODIGO := M->QIB_CODIGO
		QIC->QIC_SEQ    := StrZero(nCnt,Len(QIC->QIC_SEQ))
		MsUnlock()       
		FKCOMMIT()
	Endif
Next nCnt

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QNCA080   �Autor  �Telso Carneiro      � Data �  17/04/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Validacao da gravacao dos Passos/Etapas                    ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

STatic Function QNC80VLD(aColsAux)

Local lRet:=.F.
Local nCnt:= 0
Local nPosCod:= GdFieldPos("QIC_TPACAO",aHeader)

For nCnt:= 1 To Len(AcolsAux)
	If !AcolsAux[nCnt,Len(AcolsAux[1])] // Verifica se o item foi deletado
		lRet:= !EMPTY(AcolsAux[nCnt,nPosCod] )
		IF !lRet
			Exit          
		Endif	
	Endif
Next nCnt

IF !lRet
	Help( " " , 1, "QDA020BRA" )	// Existem campos obrigatorios em branco
Endif

Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	  � QNC80FGet  � Autor � Rafael S.Bernardi  � Data � 08/02/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao  � Monta aHeader e Acols do Cadastro de Etapas               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	  � QNC80FGet(ExpN1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros � ExpN1 - nOpc                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso		  � QNCA080                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QNC80FGet(nOpc)
Local cSeek
Local cWhile
Local lInclui := .F.

dbSelectArea("QIC")
dbSetOrder(1)

If !DbSeek(M->QIB_FILIAL + M->QIB_CODIGO)
	lInclui := .T.
EndIf

cSeek  := QIC->QIC_FILIAL+QIC->QIC_CODIGO
cWhile := "QIC->QIC_FILIAL+QIC->QIC_CODIGO"

If lInclui
	  FillGetDados(nOpc,"QIC" ,1     ,       ,           ,         ,         ,          ,        ,      ,        ,lInclui ,          ,        ,          ,           ,            ,)
	//FillGetDados(nOpc,Alias ,nOrdem,cSeek  ,bSeekWhile  ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
Else
	  FillGetDados(nOpc,"QIC" ,1     ,cSeek ,{|| &cWhile},         ,         ,          ,        ,      ,        ,       ,          ,        ,          ,           ,            ,)
	//FillGetDados(nOpc,Alias ,nOrdem,cSeek  ,bSeekWhile  ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
EndIf

Return
