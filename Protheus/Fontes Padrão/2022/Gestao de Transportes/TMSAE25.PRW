#INCLUDE "TMSAE25.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSAE25  � Autor � Eduardo de Souza      � Data � 13/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cliente X Layout                                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE25()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATMS                                                    ���
�������������������������������������������������������������������������Ĵ��
���                  ATUALIZACOES - VIDE SOURCE SAFE                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSAE25()

Private cCadastro := STR0001 //'Cliente x Layout'
Private aRotina	:= MenuDef()

mBrowse( 6,1,22,75,'DEC')

RetIndex('DEC')

Return NIL

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSAE25Mnt� Autor � Eduardo de Souza      � Data � 13/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cliente x Layout                                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE25Mnt(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSAE25                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSAE25Mnt(cAlias,nReg,nOpcx)

Local oTmsEnch
Local oTmsDlgEsp
Local aTmsAltera  := {}
Local aTmsButtons := {}
Local nOpca		   := 0
Local aTmsVisual  := {}
Local aNoFields	:= {}
Local aYesFields  := {}
Local aObjects	   := {}
Local aInfo		   := {}
Local lTmAE25Cpo  := ExistBlock('TMAE25CPO') //-- Permite ao usuario, excluir campos na getdados
Local aCpos       := {}
Local nCntFor     := 0

Private oTmsGetD
Private aHeader	  := {}
Private aCols	     := {}
Private aTmsPosObj  := {}
Private aTela[0][0]
Private aGets[0]

RegToMemory(cAlias,nOpcx==3)

Aadd( aTmsVisual, 'DEC_CODCLI' )
Aadd( aTmsVisual, 'DEC_LOJCLI' )
Aadd( aTmsVisual, 'DEC_NOME'   )

Aadd( aNoFields, 'DEC_CODCLI' )
Aadd( aNoFields, 'DEC_LOJCLI' )
Aadd( aNoFields, 'DEC_NOME'   )

//-- Ponto de Entrada que permite a exclusao de campos na GetDados
If lTmAE25Cpo
	aCpos := ExecBlock("TMAE25CPO",.F.,.F. )
	If ValType(aCpos) == 'A'
		For nCntFor := 1 To Len( aCpos )
			Aadd( aTmsVisual, aCpos[nCntFor] )
			Aadd( aNoFields , aCpos[nCntFor] )
		Next nCntFor
	EndIf
EndIf

aTmsAltera := AClone( aTmsVisual )

//-- Configura variaveis da GetDados
TMSFillGetDados(nOpcx, cAlias, 1,xFilial('DEC')+M->DEC_CODCLI+M->DEC_LOJCLI, { || DEC->DEC_FILIAL + DEC->DEC_CODCLI + DEC->DEC_LOJCLI },{ || .T. }, aNoFields, aYesFields )

//-- Dimensoes padroes
aSize := MsAdvSize()
AAdd( aObjects, { 100, 20, .T., .T. } )
AAdd( aObjects, { 100, 80, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aTmsPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oTmsDlgEsp TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
	oTmsEnch := MsMGet():New( cAlias, nReg, nOpcx,,,, aTmsVisual, aTmsPosObj[1], aTmsAltera, 3,,,,,,.T. )
	//          MsGetDados(                      nT ,                  nL,                 nB,                  nR,    nOpc,     cLinhaOk,      cTudoOk,cIniCpos,lDeleta,aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)
	oTmsGetD := MSGetDados():New(aTmsPosObj[ 2, 1 ], aTmsPosObj[ 2, 2 ],aTmsPosObj[ 2, 3 ], aTmsPosObj[ 2, 4 ], nOpcx,'TMSAE25LOk','TMSAE25TOk',,nOpcx==3 .Or. nOpcx==4,       ,       ,      ,    ,       ,         ,       ,     ,    )
ACTIVATE MSDIALOG oTmsDlgEsp ON INIT EnchoiceBar(oTmsDlgEsp,{||Iif( oTmsGetD:TudoOk(), (nOpca := 1,oTmsDlgEsp:End()), (nOpca :=0, .F.))},{||nOpca:=0,oTmsDlgEsp:End()},, aTmsButtons )

If nOpcx != 2 .And. nOpcA == 1
	TMSAE25Grv( nOpcx, aTmsVisual )
EndIf

Return(nOpca)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSAE25LOk� Autor � Eduardo de Souza      � Data � 13/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacoes da linha da GetDados                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE25LOk()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSAE25                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSAE25LOk()

Local lRet := .T.

//-- Nao avalia linhas deletadas.
If !GDdeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
	//-- Analisa se ha itens duplicados na GetDados.
	lRet := GDCheckKey( { 'DEC_CODLAY' }, 4 )
EndIf

Return(lRet)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSAE25TOk� Autor � Eduardo de Souza      � Data � 13/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tudo Ok da GetDados                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE25TOk()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSAE25                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSAE25TOk()

Local lRet := .T.

//-- Analisa se os campos obrigatorios da Enchoice foram informados.
lRet := Obrigatorio( aGets, aTela )

//-- Analisa o linha ok.
If lRet
	lRet := TMSAE25LOk()
EndIf

Return( lRet )

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSAE25Grv� Autor � Eduardo de Souza     � Data � 13/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravar dados                                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE25(ExpN1)                                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 - Opcao Selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSAE25                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function TMSAE25Grv(nOpcx,aTmsVisual)

Local nCntFor	:= 0
Local nCntFo1	:= 0

If	nOpcx == 5				//-- Excluir
	Begin Transaction
		DEC->( DbSetOrder( 1 ) )
		While DEC->( MsSeek( xFilial('DEC') + M->DEC_CODCLI + M->DEC_LOJCLI, .F. ) )
			RecLock('DEC',.F.,.T.)
			DEC->(DbDelete())
			MsUnLock()
		EndDo
		EvalTrigger()
	End Transaction
EndIf

If	nOpcx == 3 .Or. nOpcx == 4			//-- Incluir ou Alterar
	Begin Transaction

		// Se ja existir o registro apaga pra incluir novamente
		DEC->( DbSetOrder( 2 ) )
		If	DEC->( MsSeek( xFilial('DEC') + M->DEC_CODCLI + M->DEC_LOJCLI, .F. ))
			While DEC->(!Eof()) .And. DEC->DEC_FILIAL + DEC->DEC_CODCLI + DEC->DEC_LOJCLI == xFilial('DEC') + M->DEC_CODCLI + M->DEC_LOJCLI
				RecLock('DEC',.F.,.T.)
				DEC->(DbDelete())
				MsUnLock()
				DEC->(DbSkip())
			EndDo
		EndIf        

		For nCntFor := 1 To Len( aCols )
			If	!GDDeleted( nCntFor )
				RecLock('DEC',.T.)
				DEC->DEC_FILIAL := xFilial('DEC')
				For nCntFo1 := 1 To Len(aTmsVisual)
					If DEC->(FieldPos(aTmsVisual[nCntFo1])) > 0
						&('DEC->'+aTmsVisual[nCntFo1]) := &('M->'+aTmsVisual[nCntFo1])
					EndIf
				Next nCntFo1
				For nCntFo1 := 1 To Len(aHeader)
					If	aHeader[nCntFo1,10] != 'V'
	         		FieldPut(FieldPos(aHeader[nCntFo1,2]), aCols[nCntFor,nCntFo1])
	    			EndIf
				Next
				MsUnLock()
			EndIf
		Next

		EvalTrigger()
	End Transaction
EndIf
	
Return NIL

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
								{ STR0003,'TMSAE25Mnt',0,2,0,NIL},; //'Visualizar'
								{ STR0004,'TMSAE25Mnt',0,3,0,NIL},; //'Incluir'
								{ STR0005,'TMSAE25Mnt',0,4,0,NIL},; //'Alterar'
								{ STR0006,'TMSAE25Mnt',0,5,0,NIL} } //'Excluir'


If ExistBlock("TME25MNU")
	ExecBlock("TME25MNU",.F.,.F.)
EndIf

Return(aRotina)

