#INCLUDE 'TMSAE30.CH'
#INCLUDE 'PROTHEUS.CH'

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSAE30  � Autor � Eduardo de Souza      � Data � 13/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de  Agrupamento de CNPJ                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE30()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATMS                                                    ���
�������������������������������������������������������������������������Ĵ��
���                  ATUALIZACOES - VIDE SOURCE SAFE                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSAE30()

Private cCadastro := STR0001 //'Cadastro de Agrupamento de CNPJ'
Private aRotina	:= MenuDef()

DE4->( DbSetOrder( 1 ) )

mBrowse( 6,1,22,75,'DE4')

RetIndex('DE4')

Return( Nil)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSAE30Mnt� Autor � Jesus Pedro           � Data �29.08.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Agrupamento de CNPJ                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE30Mnt(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSEA30                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSAE30Mnt(cAlias, nReg, nOpcx)

Local oEnch
Local oDlgEsp
Local aAreaAnt	 := GetArea()
Local aAreaDE4	 := DE4->( GetArea() )
Local nCntFor	 := 0
Local aVisual	 := {}
Local aAltera	 := {}
Local aButtons	 := {}
Local nOpca		 := 0
Local aNoFields	 := {}
Local aYesFields := {}
Local aObjects	 := {}
Local aInfo		 := {}

Private oGetD
Private aHeader  := {}
Private aCols	 := {}
Private aPosObj  := {}
Private aTela[0][0]
Private aGets[0]
                
//-- Configura variaveis da Enchoice
RegToMemory( cAlias, nOpcx==3 )

Aadd( aNoFields, 'DE4_CNPJ')
Aadd( aNoFields, 'DE4_NREDUZ')

Aadd( aVisual, 'DE4_CNPJ')
Aadd( aVisual, 'DE4_NREDUZ')

//-- Configura variaveis da GetDados
TMSFillGetDados(nOpcx,'DE4',1,xFilial('DE4')+M->DE4_CNPJ, { ||	DE4->DE4_FILIAL + DE4->DE4_CNPJ},{ || .T. }, aNoFields,	aYesFields )

//-- Dimensoes padroes
aSize := MsAdvSize()
AAdd( aObjects, { 100, 20, .T., .T. } )
AAdd( aObjects, { 100, 80, .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlgEsp TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
	//-- Monta a enchoice.
	oEnch	:= MsMGet():New( cAlias, nReg, nOpcx,,,,aVisual,aPosObj[1],, 3,,,,,,.T. )
	//        MsGetDados(                      nT ,                  nL,                 nB,                  nR,    nOpc,     cLinhaOk,      cTudoOk,cIniCpos,lDeleta,aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)
	oGetD := MSGetDados():New(aPosObj[ 2, 1 ], aPosObj[ 2, 2 ],aPosObj[ 2, 3 ], aPosObj[ 2, 4 ], nOpcx,'TMSAE30LOk','TMSAE30TOk',,nOpcx==3 .Or. nOpcx==4,       ,       ,      ,9999,       ,         ,       ,     ,    )

ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{||nOpca:=1, If( oGetD:TudoOk(),oDlgEsp:End(),nOpca := 0)},{||oDlgEsp:End()},, aButtons ) 

If nOpcx != 2 .And. nOpcA == 1
	TMSAE30Grv( nOpcx )
EndIf

DeleteObject( oDlgEsp )
DeleteObject( oEnch )
DeleteObject( oGetD ) 

RestArea( aAreaDE4 )
RestArea( aAreaAnt )

Return(nOpca)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSAE30LOk� Autor � Eduardo de Souza      � Data � 13/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacoes da linha da GetDados                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE30LOk()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSEA30                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSAE30LOk()

Local lRet := .T.

//-- Nao avalia linhas deletadas.
If !GDdeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
	//-- Analisa se ha itens duplicados na GetDados.
	lRet := GDCheckKey( { 'DE4_CNPJ1' }, 4 )
EndIf

Return(lRet)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSAE30TOk � Autor � Eduardo de Souza     � Data � 13/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao Geral                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE30TOk()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSEA30                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSAE30TOk()

Local lRet     := .T. 
Local n        := 1
Local cAliasQry:= ""
Local aARea    := GetArea()

//-- Analisa se os campos obrigatorios da Enchoice foram informados.
lRet := Obrigatorio( aGets, aTela )

//-- Analisa o linha ok.
If lRet
	lRet := TMSAE30LOk()
EndIf
If lRet
	For n:=1 To Len(aCols)
		If	!GDdeleted(n)
			If GdFieldGet('DE4_CNPJ1',n) == M->DE4_CNPJ
				lRet := .F.
			EndIf
			If lRet
				cAliasQry := GetNextAlias()
				cQuery := " SELECT DE4.* "
				cQuery += "   FROM " + RetSqlName("DE4") + " DE4 "
				cQuery += "   WHERE DE4.DE4_FILIAL = '" + xFilial("DE4") + "' "
				cQuery += "     AND (DE4.DE4_CNPJ1 = '"+GdFieldGet('DE4_CNPJ1',n)+"'"
				cQuery += "     OR  DE4.DE4_CNPJ = '"+GdFieldGet('DE4_CNPJ1',n)+"'"
				cQuery += "     OR  DE4.DE4_CNPJ1 = '"+M->DE4_CNPJ+"'"
				If Inclui
					cQuery += "  OR  DE4.DE4_CNPJ = '"+M->DE4_CNPJ+"')"
				ElseIf Altera
					cQuery += "  ) AND DE4.DE4_CNPJ <> '"+M->DE4_CNPJ+"'"
				EndIf
				cQuery += "     AND DE4.D_E_L_E_T_ = ' ' "
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
				IF (cAliasQry)->(!Eof()) 
					lRet := .F.
				EndIf
				(cAliasQry)->(DbCloseArea())
			EndIf
			If !lRet
				Help("",1,"JAGRAVADO") //Ja existe registro com esta informacao.
				Exit
			EndIf
		EndIf
	Next
EndIf

RestArea(aArea)

Return( lRet )


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSAE30Grv � Autor � Eduardo de Souza     � Data � 13/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravar dados                                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE30Grv(ExpN1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 - Opcao Selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSEA30                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function TMSAE30Grv( nOpcx )

Local aAreaAnt	:= GetArea()
Local aAreaDE4	:= DE4->( GetArea() )
Local bCampo	:= { |nCpo| Field(nCpo) }
Local nCntFor	:= 0
Local nCntFo1	:= 0

If	nOpcx == 5				//-- Excluir
	Begin Transaction
    	// Exclui o item do DE4              
    	DE4->(dbSetOrder(1))
    	MsSeek(xFilial('DE4') + M->DE4_CNPJ)
    	While xFilial('DE4') + M->DE4_CNPJ == DE4->DE4_FILIAL+DE4->DE4_CNPJ
			RecLock('DE4',.F.,.T.)
				DE4->(DbDelete())
			MsUnLock()
			EvalTrigger()
			dbSkip()
		End	
	End Transaction
EndIf

If	nOpcx == 3 .Or. nOpcx == 4			//-- Incluir ou Alterar

	Begin Transaction
			
		// Se ja existir o registro apaga pra incluir novamente
		DE4->( DbSetOrder( 1 ))
		If	DE4->( MsSeek( xFilial('DE4') + M->DE4_CNPJ, .F. ))
		  	While !Eof() .And. (DE4->DE4_FILIAL + DE4->DE4_CNPJ == xFilial('DE4') + M->DE4_CNPJ)
				RecLock('DE4',.F.,.T.)
			 	DE4->(DbDelete())
			 	MsUnLock()
				dbSkip()
			EndDo
		EndIf
		
		//����������������Ŀ
		//� Grava GetDados �
		//������������������
		For nCntFor := 1 To Len( aCols )
			If	!GDDeleted( nCntFor ) .And. !Empty(M->DE4_CNPJ1)         
				RecLock('DE4',.T.)
				For nCntFo1 := 1 To Len(aHeader)
					If	aHeader[nCntFo1,10] != 'V'
	         		FieldPut(FieldPos(aHeader[nCntFo1,2]), aCols[nCntFor,nCntFo1])
	    			EndIf
				Next
				//����������������Ŀ
				//� Grava Enchoice �
				//������������������
				DE4->DE4_FILIAL := xFilial('DE4')
				DE4->DE4_CNPJ := M->DE4_CNPJ
				MsUnLock()
			EndIf
		Next

		EvalTrigger()

	End Transaction

EndIf

RestArea( aAreaDE4 )	
RestArea( aAreaAnt )	

Return( Nil) 

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
     
Private aRotina	:= {	{ STR0002,'AxPesqui'  ,0,1,0,.F.},; //'Pesquisar'
								{ STR0003,'TMSAE30Mnt',0,2,0,NIL},; //'Visualizar'
								{ STR0004,'TMSAE30Mnt',0,3,0,NIL},; //'Incluir'
								{ STR0005,'TMSAE30Mnt',0,4,0,NIL},; //'Alterar'
								{ STR0006,'TMSAE30Mnt',0,5,0,NIL} } //'Excluir'

If ExistBlock("TME30MNU")
	ExecBlock("TME30MNU",.F.,.F.)
EndIf
     

Return(aRotina)