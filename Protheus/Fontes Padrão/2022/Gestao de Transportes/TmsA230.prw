#Include 'TmsA230.ch'
#Include 'Protheus.ch'
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSA230  � Autor � Alex Egydio           � Data �22.02.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Regioes por Motorista                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TMSA230()

Private cCadastro	:= STR0001 //'Regioes por Motorista'
Private aRotina	:= MenuDef()

mBrowse( 6,1,22,75,'DTB')

RetIndex('DTB')

Return NIL
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA230Mnt� Autor � Alex Egydio           � Data �22.02.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Regioes por Motorista                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA230Mnt(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function TMSA230Mnt( cTmsAlias, nTmsReg, nTmsOpcx, cMotorista )

//-- EnchoiceBar
Local aTmsVisual	:= {}
Local aTmsAltera	:= {}
Local aTmsButtons	:= {}
Local aTelOld		:= Iif( Type('aTela') == 'A', aClone( aTela ), {} )
Local aGetOld		:= Iif( Type('aGets') == 'A', aClone( aGets ), {} )
Local nOpca			:= 0
Local oTmsEnch
//-- Dialog
Local cCadOld		:= Iif( Type('cCadastro') == 'C', cCadastro, '' )
Local oTmsDlgEsp
//-- GetDados
Local aHeaOld		:= Iif( Type('aHeader') == 'A', aClone( aHeader ), {} )
Local aColOld		:= Iif( Type('aCols') == 'A', aClone( aCols ), {} )
Local aNoFields	:= {}
Local aYesFields	:= {}
//-- Controle de dimensoes de objetos
Local aObjects		:= {}
Local aInfo			:= {}

//-- EnchoiceBar
Private aTela[0][0]
Private aGets[0]
//-- GetDados
Private aHeader	:= {}
Private aCols		:= {}
Private oTmsGetD
Private aTmsPosObj:= {}

DEFAULT cTmsAlias := 'DTB'
DEFAULT nTmsReg	:= 1
DEFAULT nTmsOpcx	:= 2
DEFAULT cMotorista:= ''

cCadastro	:= STR0001 //'Regioes por Motorista'

//-- Configura variaveis da Enchoice
RegToMemory(cTmsAlias, nTmsOpcx == 3)
If	ValType( cMotorista ) == 'C'
	M->DTB_CODMOT := cMotorista
	M->DTB_NOMMOT := Posicione('DA4',1,xFilial('DA4') + M->DTB_CODMOT,'DA4_NOME')
EndIf

Aadd( aTmsVisual, 'DTB_CODMOT' )
Aadd( aTmsVisual, 'DTB_NOMMOT' )

Aadd( aTmsAltera, 'DTB_CODMOT' )

Aadd( aNoFields, 'DTB_CODMOT' )
Aadd( aNoFields, 'DTB_NOMMOT' )


//-- Configura variaveis da GetDados
TMSFillGetDados(	nTmsOpcx, 'DTB', 1,xFilial( 'DTB' ) + M->DTB_CODMOT, { || 	DTB->DTB_FILIAL + DTB->DTB_CODMOT }, ;
{ || .T. }, aNoFields,	aYesFields )

//-- Inicializa o item da getdados se a linha estiver em branco.
If Len( aCols ) == 1 .And. Empty( GDFieldGet( 'DTB_CDRDES', 1 ) )
	GDFieldPut( 'DTB_ITEM', StrZero(1,Len(DTB->DTB_ITEM)), 1 )
EndIf

//-- Dimensoes padroes
aSize := MsAdvSize()
AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 200, 200, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aTmsPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oTmsDlgEsp TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
	//-- Monta a enchoice.
	oTmsEnch		:= MsMGet():New( cTmsAlias, nTmsReg, nTmsOpcx,,,, aTmsVisual, aTmsPosObj[1], aTmsAltera, 3,,,,,,.T. )
	//          MsGetDados(                      nT ,                  nL,                 nB,                  nR,    nOpc,     cLinhaOk,      cTudoOk,cIniCpos,lDeleta,aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)

	oTmsGetD := MSGetDados():New(aTmsPosObj[ 2, 1 ], aTmsPosObj[ 2, 2 ],aTmsPosObj[ 2, 3 ], aTmsPosObj[ 2, 4 ], nTmsOpcx,'TMSA230LinOk','TmsA230TOk','+DTB_ITEM',.T.,       ,       ,      ,    ,       ,         ,       ,     ,    )

ACTIVATE MSDIALOG oTmsDlgEsp ON INIT EnchoiceBar(oTmsDlgEsp,{||Iif( oTmsGetD:TudoOk(), (nOpca := 1,oTmsDlgEsp:End()), (nOpca :=0, .F.))},{||nOpca:=0,oTmsDlgEsp:End()},, aTmsButtons )

If nTmsOpcx != 2 .And. nOpcA == 1

	TMSA230Grv( nTmsOpcx )
	
EndIf

DeleteObject( oTmsDlgEsp )
DeleteObject( oTmsEnch )
DeleteObject( oTmsGetD )

If !Empty( cCadOld )
	cCadastro := cCadOld
EndIf

If	!Empty( aTelOld )
	aTela		:= aClone( aTelOld )
	aGets		:= aClone( aGetOld )
EndIf

If	!Empty( aHeaOld )
	aHeader	:= aClone( aHeaOld )
	aCols		:= aClone( aColOld )
EndIf

Return(nOpca)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA230Vld� Autor � Alex Egydio           � Data �22.02.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacoes do sistema                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA230Vld()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function TMSA230Vld()

Local aAreaAnt	:= GetArea()
Local cCampo	:= ReadVar()
Local lRet		:= .T.

If	cCampo == 'M->DTB_CDRDES'

	lRet := TmsTipReg( M->DTB_CDRDES, StrZero( 2, Len( DTN->DTN_TIPREG ) ) )

ElseIf cCampo == 'M->DTB_REGDES'

	cCampo := 'DTB_CDRDES'
	M->&(cCampo) := CriaVar(cCampo)

	lRet := TmsPesqRegiao(cCampo,'DTB_REGDES')
	If	!Empty( M->DTB_CDRDES )
		GDFieldPut( 'DTB_CDRDES', M->DTB_CDRDES, n )
	EndIf
	GDFieldPut( 'DTB_REGDES', M->DTB_REGDES, n )

EndIf
RestArea( aAreaAnt )

Return( lRet )
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA230Lin� Autor � Alex Egydio           � Data �22.02.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacoes da linha da GetDados                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA230Lin()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function TMSA230LinOk()

Local lRet       := .T.
//-- Nao avalia linhas deletadas.
If !GDdeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
	//-- Analisa se ha itens duplicados na GetDados.
	lRet := GDCheckKey( { 'DTB_CDRDES' }, 4 )
EndIf

Return(lRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TmsA230TOk� Autor � Alex Egydio           � Data �25.02.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tudo Ok da GetDados                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function TmsA230TOk()

Local lRet		:= .T.

//-- Analisa se os campos obrigatorios da Enchoice foram informados.
lRet := Obrigatorio( aGets, aTela )
//-- Analisa se os campos obrigatorios da GetDados foram informados.
If	lRet
	lRet := oTmsGetD:ChkObrigat( n )
EndIf
//-- Analisa o linha ok.
If lRet
	lRet := TmsA230LinOk()
EndIf
//-- Analisa se todas os itens da GetDados estao deletados.
If lRet .And. Ascan( aCols, { |x| x[ Len( x ) ] == .F. } ) == 0
	Help( ' ', 1, 'OBRIGAT2') //Um ou alguns campos obrigatorios nao foram preenchidos no Browse.
	lRet := .F.
EndIf

Return( lRet )
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSA230Grv� Autor � Alex Egydio          � Data �22.02.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravar dados                                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Static Function TMSA230Grv( nTmsOpcx )

Local nCntFor	:= 0
Local nCntFo1	:= 0

If	nTmsOpcx == 5				//-- Excluir
	Begin Transaction

		DTB->( DbSetOrder( 1 ) )
		While DTB->( MsSeek( xFilial('DTB') + M->DTB_CODMOT, .F. ) )
			//-- Exclui Regioes por Motorista.
			RecLock('DTB',.F.,.T.)
			DTB->(DbDelete())
			MsUnLock()
		EndDo

		EvalTrigger()
	End Transaction
EndIf


If	nTmsOpcx == 3 .Or. nTmsOpcx == 4			//-- Incluir ou Alterar
	Begin Transaction

		For nCntFor := 1 To Len( aCols )
			If	!GDDeleted( nCntFor )

				If	DTB->( MsSeek( xFilial('DTB') + M->DTB_CODMOT + GDFieldGet( 'DTB_ITEM', nCntFor ), .F. ) )
					RecLock('DTB',.F.)
				Else
					RecLock('DTB',.T.)
					DTB->DTB_FILIAL	:= xFilial('DTB')
					DTB->DTB_CODMOT	:= M->DTB_CODMOT
				EndIf

				For nCntFo1 := 1 To Len(aHeader)
					If	aHeader[nCntFo1,10] != 'V'
	         		FieldPut(FieldPos(aHeader[nCntFo1,2]), aCols[nCntFor,nCntFo1])
	    			EndIf
				Next
				MsUnLock()

			Else
				If	DTB->( MsSeek( xFilial('DTB') + M->DTB_CODMOT + GDFieldGet( 'DTB_ITEM', nCntFor ), .F. ) )
					RecLock('DTB',.F.,.T.)
					DTB->(DbDelete())
					MsUnLock()
				EndIf
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
     
Private aRotina	:= {	{ STR0002 ,'AxPesqui'  ,0,1,0,.F.},; //'Pesquisar'
								{ STR0003 ,'TMSA230Mnt',0,2,0,NIL},; //'Visualizar'
								{ STR0004 ,'TMSA230Mnt',0,3,0,NIL},; //'Incluir'
								{ STR0005 ,'TMSA230Mnt',0,4,0,NIL},; //'Alterar'
								{ STR0006 ,'TMSA230Mnt',0,5,0,NIL} } //'Excluir'


If ExistBlock("TMA230MNU")
	ExecBlock("TMA230MNU",.F.,.F.)
EndIf

Return(aRotina)

