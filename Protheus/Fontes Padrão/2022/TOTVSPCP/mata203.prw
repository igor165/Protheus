#Include "PROTHEUS.CH"
#Include "MATA203.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � mata203  � Rev.  �GDP Materiais		    � Data �29/10/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Engenheiros.        							  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � mata203()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAEST                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MATA203()
Local aArea		:= GetArea()
Local aAreaSGK	:= SGK->(GetArea())

PRIVATE aRotina := MenuDef()
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := STR0001
DEFAULT lAutoMacao := .F.

IF !lAutoMacao
	mBrowse( 6, 1,22,75,"SGK")
ENDIF

RestArea(aAreaSGK)
RestArea(aArea)
Return .T.

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A203Inclui � Rev.  �GDP Materiais		� Data �29/10/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Programa de inclusao de aprovadores                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �A203Inclui(cAlias, nReg, nOpcx)                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � mata203                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A203Inclui(cAlias,nReg,nOpc)
	AxInclui(cAlias,nReg,nOpc,Nil,Nil,Nil,"A203TudOk(3)")
Return         

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A203AltExc � Rev.  �GDP Materiais		� Data �29/10/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Programa de alteracao e exclusao dos engenheiros            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �A203AltExc(cAlias, nReg, nOpcx)                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
���          � nOpcx  : 4 - Alterar                                       ���
���          �          5 - Excluir                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � mata203                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function a203AltExc(cAlias, nReg,nOpcx)
Local dDataAlt		:= dDataBase
Local aArea			:= GetArea()
Local aAreaSAL		:= SAL->(GetArea())
Local nRecSGK		:= SGK->(RecNo())
Local lGravaOk		:= .F.
Local l203Exclui	:= .F.
Local l203Altera	:= .F.
Local lContinua	:= .T.
Local lAltTipo		:= .F.
Local aCpos			:= {}
Local nSaveSX8    := GetSX8Len()
Local nCntFor     := 0   
Local bCampo		:= { |nCPO| Field(nCPO) }   

Local aObjects    := {}
Local aSize       := MsAdvSize()
Local aInfo       := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
Local aPosObj     := {}
Local cUsado
DEFAULT lAutoMacao := .F.

AAdd( aObjects, { 100, 100, .T., .T. } )
aPosObj := MsObjSize( aInfo, aObjects, .T.)

Do Case
	Case nOpcx == 4
		l203Altera := .T.
	Case nOpcx == 5   
		l203Exclui := .T.
EndCase
dbSelectArea("SGK")
If lContinua
	//������������������������������������������������������Ŀ
	//� Inicializa a Variaveis da Enchoice.                  �
	//��������������������������������������������������������
	dbSelectArea("SGK")
	TcSrvMap("SGK")
	dbGoto(nRecSGK)
	For nCntFor := 1 TO FCount()
		cUsado := Alltrim(GetSx3Cache(Field(nCntFor),'X3_USADO'))
		If X3USO(cUsado) .And. cNivel >= GetSx3Cache(Field(nCntFor),'X3_NIVEL')
			aAdd(aCpos,Alltrim(GetSx3Cache(Field(nCntFor),'X3_CAMPO')))
		EndIf
		
		dbSelectArea("SGK")
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next nCntFor

	IF !lAutoMacao
		DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL
			nOpcA:=EnChoice( "SGK", nRecSGK, nOpcx,,,,aCpos,aPosObj[1],)

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(A203TudOk(nOpcX)   ,(lGravaOk := .T.,oDlg:End()),)},{|| lGravaOk := .F.,oDlg:End()}) CENTERED
	ENDIF
EndIf

If l203Altera .And. lGravaOk
	dDataAlt	:= MaAlcDtRef(M->GK_COD,dDataBase,M->GK_GRAPROV)
	lAltTipo	:= M->GK_GRAPROV!=SGK->GK_GRAPROV
	lGravaOk	:= .T.
EndIf

If lGravaOk
	Begin Transaction
		A203Grava(nRecSGK,l203Exclui,l203Altera,dDataAlt,lAltTipo) 
		EvalTrigger()
        While ( GetSX8Len() > nSaveSX8 )
			ConfirmSX8()
		EndDo
	End Transaction
Else
    While ( GetSX8Len() > nSaveSX8 )
		RollBackSX8()
	EndDo
EndIf

If l203Altera .Or. l203Exclui
 MsUnlockAll()
EndIf

RestArea(aAreaSAL)
RestArea(aArea)
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A203Grava� Autor �GDP Materiais           � Data �29/10/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Efetua a gravacao do Aprovador.                             ���
�������������������������������������������������������������������������Ĵ��
���Uso       �mata203                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A203Grava(nRecSGK,lExclui,lAltera,dDataAlt,lAltTipo)
Local bCampo    := { |nCPO| Field(nCPO) }
Local nCntFor   := 0
DEFAULT lExclui := .F.
DEFAULT lAltera := .F.

If !lExclui
	dbSelectArea("SGK")
	If lAltera 
		dbGoto(nRecSGK)
		RecLock("SGK",.F.)
		For nCntFor := 1 TO FCount()
			If "FILIAL"$Field(nCntFor)
				FieldPut(nCntFor,xFilial("SGK"))
			Else
				FieldPut(nCntFor,M->&(EVAL(bCampo,nCntFor)))
			EndIf
		Next nCntFor
	EndIf
Else
	dbSelectArea("SGK")
	dbSeek(xFilial())
	While !Eof() .And. xFilial() == SGK->GK_FILIAL
		If SGK->GK_COD == M->GK_COD 
			RecLock("SGK",.F.,.T.)
			dbDelete()
			MsUnlock()
		EndIf
		If M->GK_COD == SGK->GK_GRAPROV
			RecLock("SGK",.F.)
			SGK->GK_GRAPROV := ""        
			MsUnlock()
		EndIf
		dbSkip()
	End
EndIf
Return 

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � GDP Materiais         � Data �29/10/2010���
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
PRIVATE aRotina	:= { {STR0002,"AxPesqui", 0 , 1, 0, .F.},;	//"Pesquisar"    
						{ STR0003,"AxVisual", 0 , 2, 0, nil},;  	//"Visualizar" 
						{ STR0004,"A203Inclui", 0 , 3, 0, nil},;		//"Incluir"    
						{ STR0005,"A203AltExc", 0 , 4, 0, nil},;		//"Alterar"    
						{ STR0006,"A203AltExc", 0 , 5, 3, nil}}	   //"Excluir"

//������������������������������������������������������������������������Ŀ
//� Ponto de entrada utilizado para inserir novas opcoes no array aRotina  �
//��������������������������������������������������������������������������
If ExistBlock("MTA203MNU")
	ExecBlock("MTA203MNU",.F.,.F.)
EndIf
Return(aRotina)                 

/*/   
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A203TudOk  � Autor �GDP Materiais		     � Data �29/10/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �TudoOk Inclusao/Altera�ao/Exclusao do aprovador             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T. ou .F.                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A203TudOk(nOpcX)
Local aArea		:= GetArea()
Local lRet      := .T.
Local lMt203tok := .T.
Local aDados    := {}

aadd(aDados,{"GK_COD"		,M->GK_COD    })
aadd(aDados,{"GK_USER"   	,M->GK_USER   })
aadd(aDados,{"GK_GRAPROV"	,M->GK_GRAPROV   }) 
//����������������������������������������������������������������Ŀ
//� Ponto para validar se continua ou nao a Rotina.                �
//������������������������������������������������������������������
If ExistBlock("MT203TOK") .And. lRet
	lMt203TOK := Execblock("MT203TOK",.F.,.F.,{nOpcX,aDados})
	If ValType( lMt203TOK ) == "L" .And. !lMt203TOK
		lRet := .F.
	EndIf
EndIf
SGK->(dbSetOrder(2))
If (lRet .And. nOpcX == 3) .And. SGK->(MsSeek(xFilial("SGK")+M->GK_USER))
	Aviso(STR0007,STR0008,{STR0009})
	lRet := .F.				
Endif
If lRet .And. nOpcx == 5
	SGL->(dbSetOrder(2))
	If SGL->(dbSeek(xFilial("SGL")+M->GK_USER))
		Aviso(STR0007,STR0010,{STR0009}) //C�digo do Engenheiro cadastrado no Grupo de Engenharia.
		lRet := .F.					
	EndIf	
EndIf
RestArea(aArea)
Return(lRet)
