#INCLUDE "pmsa025.ch"
#INCLUDE "protheus.ch"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � PMSA025  � Autor � Totvs                 � Data � 11-06-2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Tipo de Tarefa                                               ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/                           
Function PMSA025( aRotAuto, nOpcAuto )

Local lIntegra		:= SuperGetMV( "MV_QTMKPMS", .F., 1 ) == 3 .OR. SuperGetMV( "MV_QTMKPMS", .F., 1 ) == 4

Private cCadastro	:= STR0001 	// "Tipo de Tarefa"
Private aAutoCab	:= aRotAuto
Private lExecAuto	:= ( aRotAuto <> NIL )
Private aRotina 	:= MenuDef()

DEFAULT nOpcAuto 	:= 3

If lExecAuto
	MBrowseAuto( nOpcAuto, aAutoCab, "AN4" )
Else	
	If lIntegra //Integracao entre PMS x TMK x QNC
		MsgAlert( "Apenas a pesquisa e visualiza��o poder� ser feita por essa rotina devido a integra��o com TMK/QNC. A edi��o s� pode ser feita pelo Cadastro de Etapas." ) //"Apenas a pesquisa e visualiza��o poder� ser feita por essa rotina devido a integra��o com TMK/QNC. A edi��o s� pode ser feita pelo Cadastro de Etapas."
	EndIf

	If AMIIn(44) .And. !PMSBLKINT()
		mBrowse( 6, 1, 22, 75, "AN4" )
	EndIf
EndIf

Return 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Totvs                 � Data � 11/06/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Utilizacao de menu Funcional                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina 	:= {}
Local lIntegra	:= SuperGetMV( "MV_QTMKPMS", .F., 1 ) == 3 .OR. SuperGetMV( "MV_QTMKPMS", .F., 1 ) == 4
Local lAuto

If Type("lExecAuto")=='L'
	lAuto := lExecAuto
Else
	lAuto := .F.
EndIf

If lIntegra
	If lAuto
		aRotina 	:= {	{ STR0002,	"AxPesqui"  , 0 , 1,,.F.},;	//"Pesquisar"
							{ STR0003,	"AxVisual", 0 , 2},;			//"Visualizar"
							{ STR0004,	"PA025Inclu", 0 , 3},;			//"Incluir"
							{ STR0005,	"PA025Alter", 0 , 4},;			//"Alterar"
							{ STR0006,	"PA025Delet()", 0 , 5} }		//"Excluir"
	Else
		aRotina 	:= {	{ STR0002,	"AxPesqui"  , 0 , 1,,.F.},;	//"Pesquisar"
							{ STR0003,	"AxVisual", 0 , 2} }			//"Visualizar"
	EndIf
Else
	aRotina 	:= {	{ STR0002,	"AxPesqui"  , 0 , 1,,.F.},;	//"Pesquisar"
						{ STR0003,	"AxVisual", 0 , 2},;			//"Visualizar"
						{ STR0004,	"AxInclui", 0 , 3},;			//"Incluir"
						{ STR0005,	"AxAltera", 0 , 4},;			//"Alterar"
						{ STR0006,	"PA025Delet()", 0 , 5} }		//"Excluir"
EndIf

Return( aRotina )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �PA025Delet� Autor � Totvs                 � Data � 11/06/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para validar exclusao do tipo de tarefa              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PA025Delet( lExecAuto )
Local lUsadoPrj	:= .T.

Default lExecAuto	:= .F.

DbSelectArea( "AF9" )
AF9->( DbSetOrder( 1 ) )
AF9->( DbGoTop() )
While AF9->( !Eof() ) .AND. AF9->AF9_FILIAL == xFilial( "AF9" )
	If AF9->AF9_TIPPAR == AN4->AN4_TIPO
		lUsadoPrj	:= .F.
		Help( " ", 1, "PA025DEL",, STR0007, 1, 0 ) //"Este tipo esta em uso e n�o pode ser excluido!"

		Exit
	EndIf

	AF9->( DbSkip() )
End

// Verifica se o tipo de tarefa esta sendo usado no checklist
If lUsadoPrj
	DbSelectArea( "AJQ" )
	AJQ->( DbSetOrder( 1 ) )
	AJQ->( DbSeek( xFilial( "AJQ" ) ) )
	While AJQ->( !Eof() ) .AND. AJQ->AJQ_FILIAL == xFilial( "AJQ" )
		If AllTrim( AJQ->AJQ_TIPTAR ) == AN4->AN4_TIPO
			lUsadoPrj	:= .F.
			Help( " ", 1, "PA025DEL",, STR0008, 3, 1 ) //"O tipo de tarefa esta vinculado � um checklist e n�o pode ser excluido!"

			Exit
		EndIf

		AJQ->( DbSkip() )
	End
EndIf

If lUsadoPrj
	AxDeleta( "AN4", AN4->( RecNo() ), 5 )
EndIf

Return lUsadoPrj

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �PA025Inclu� Autor � Totvs                 � Data � 28/07/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa para inclusao de naturezas                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PA025Inclu(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINA010                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PA025Inclu(cAlias,nReg,nOpc)

Local nOpca
Local cTudoOk	:= Nil
Local cTransact	:= Nil

If Type( "lExecAuto" ) != "L" .OR. lExecAuto
	RegToMemory( "AN4", .T., .F. )
	If EnchAuto( cAlias, aAutoCab, cTudoOk, nOpc )
		nOpca := AxIncluiAuto( cAlias, cTudoOk, cTransact )
	EndIf
Endif	

Return nOpca


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �PA025Alter� Autor � Totvs                 � Data � 28/07/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa para alteracao de naturezas                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � PA025Alter(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINA010                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PA025Alter(cAlias,nReg,nOpc)

Local nOpca		:= 0
Local cTudoOK 	:= Nil
Local cTransact := Nil

If Type( "lExecAuto" ) != "L" .OR. lExecAuto
	RegToMemory( "AN4", .F., .F. )
	If EnchAuto( cAlias, aAutoCab, cTudoOk, nOpc )
		nOpcA := AxIncluiAuto( cAlias,, cTransact, 4, RecNo() )
	EndIf
Endif

Return
