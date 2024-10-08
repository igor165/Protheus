#Include 'TMSAE65.ch'
#Include 'Protheus.ch'

Static lRestRepom := SuperGetMV( 'MV_VSREPOM',, '1' ) == '2.2'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSAE65  � Autor � Vitor Raspa           � Data � 11.Jul.06���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Gerenciadores de Frota X Acoes                 ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function TMSAE65()
Private cCadastro := STR0001 //'Gerenciadores de Frota x Acoes'
Private aRotina	  := MenuDef()

mBrowse( ,,,,'DEM')

RetIndex('DEM')
Return NIL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSAE65Mnt� Autor � Vitor Raspa           � Data � 11.Jul.06���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Manutencao de Gerenciadores de Frota x Acoes               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE65Mnt(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function TMSAE65Mnt( cAlias, nReg, nOpc ) 

//-- EnchoiceBar
Local oEnchoice
Local lOk        := .F.
Local aCpoEnch   := {'DEM_CODOPE','DEM_NOMOPE'}
//-- Dialog
Local oDlg
Local aButtons   := {}

//-- GetDados
Local aNoFields  := {'DEM_CODOPE', 'DEM_NOMOPE'}
Local aYesFields := {}

//-- Controle de dimensoes de objetos
Local aObjects   := {}
Local aInfo      := {}

//-- EnchoiceBar
Private aTela[0][0]
Private aGets[0]

//-- GetDados
Private oGetDados
Private aHeader   := {}
Private aCols     := {}
Private aPosObj   := {}

//-- Variavel para controlar o resultado da consulta padrao no campo 'Cod. Movto.'
Private aMovOper  := {}

DEFAULT cAlias := 'DEM'
DEFAULT nReg   := 1
DEFAULT nOpc   := 2

//�������������������������������Ŀ
//�Configura variaveis da Enchoice�
//���������������������������������
RegToMemory( cAlias, nOpc==3 )

//�����������������������������������������Ŀ
//�Configura variaveis da GetDados Principal�
//�������������������������������������������
TMSFillGetDados( 	nOpc, 'DEM', 1, xFilial( 'DEM' ) + M->DEM_CODOPE ,; 
						{ ||  DEM->(DEM_FILIAL + DEM_CODOPE ) },;
					 	{ || .T. }, aNoFields,	aYesFields )

//�������������������������Ŀ
//�Preenche o Numero do Item�
//���������������������������
If Empty(GDFieldGet("DEM_ITEM",1))
	GDFieldPut("DEM_ITEM",StrZero(1,Len(DEM->DEM_ITEM)),1)
EndIf

//-- Dimensoes padroes
aSize := MsAdvSize()
AAdd( aObjects, { 65, 50, .T., .T. } )
AAdd( aObjects, { 235, 235, .T., .T. } )
aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj	:= MsObjSize( aInfo, aObjects,.T.)

//-- Ajuste do Ponteiro da tabela da GetDados para nao 
//-- Trazer sujeira na adicao de novas linhas, quando a operacao for
//-- de alteracao de registro.
DEM->(DbGoTo(0))

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL

//-- Enchoice
oEnchoice	:= MsMGet():New( cAlias, nReg, nOpc,,,, aCpoEnch, aPosObj[1],, 3,,,,,,.T. )

//--GetDados
oGetDados 	:= MSGetDados():New(	aPosObj[ 2, 1 ], aPosObj[ 2, 2 ],aPosObj[ 2, 3 ], aPosObj[ 2, 4 ],; 
											nOpc, 'TMSAE65LOk','TMSAE65TOk','+DEM_ITEM',;
											IIf(nOpc == 3 .Or. nOpc == 4,.T.,Nil),,,,99)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg,	{|| If(TMSAE65TOk(), ( lOk := .T.,oDlg:End()), lOk := .F. )} ,;
																	{|| lOk := .F., oDlg:End()},,aButtons ) 

If nOpc != 2 .And. lOk
	TMSAE65Grv( M->DEM_CODOPE, nOpc )
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSAE65LOk� Autor � Vitor Raspa           � Data � 11.Jul.06���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacoes da linha da GetDados                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE65LOk()                                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function TMSAE65LOk()
Local lRet      := .T.
Local aCpoCheck := {'DEM_CODMOV', 'DEM_ACAO', 'DEM_TIPTRA', 'DEM_SERTMS', 'DEM_RECENV'}

If !GDDeleted( n ) 
	If (lRet:=MaCheckCols(aHeader,aCols,n))
		//-- Analisa se ha itens duplicados na GetDados.
		lRet := GDCheckKey(aCpoCheck,4)

		If lRet
			If GDFieldGet("DEM_ACAO", n) <> StrZero( 0, Len(DEM->DEM_ACAO) ) .And. GDFieldGet("DEM_ACAO", n) <> StrZero( 3, Len(DEM->DEM_ACAO) )
				If Empty( GDFieldGet("DEM_FORMUL", n) )
					lRet := .F.
					Help('',1,'OBRIGAT2',,RetTitle("DEM_FORMUL"), 04, 01)
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSAE65TOk� Autor � Vitor Raspa           � Data � 11.Jul.06���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tudo Ok da GetDados                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �TMSAE65TOk()                                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function TMSAE65TOk()
Local lRet	:= .T.
Local nAux
Local nDel	:= 0

//�������������������Ŀ
//�Verifica a Enchoice�
//���������������������
lRet := Obrigatorio( aGets, aTela )

//-- Analisa se os campos obrigatorios da GetDados foram preenchidos.
If lRet
	lRet := oGetDados:ChkObrigat(oGetDados:oBrowse:nAt) .And. TMSAE65LOk()
EndIf

//����������������������������������Ŀ
//�Verifica se as linhas estao Ativas�
//�GetDados Principal                �
//������������������������������������
If lRet
	nDel := 0	
	For nAux := 1 To Len(aCols)
		If aCols[nAux,Len(aHeader)+1]
			nDel++
		EndIf
	Next
	If Len(aCols) == nDel
		Help('',1,'TMSAE6501') //--'Produto nao Informado!'
		lRet := .F.
	EndIf
EndIf

Return( lRet )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSAE65Grv� Autor � Vitor Raspa          � Data � 11.Jul.06���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravar dados                                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE65Grv( ExpC1, ExpN1 )                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1: Codigo da Operadora                                 ���
���          � ExpN1: Opcao Selecionada                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TMSAE65Grv( cCodOpe, nOpc )
Local nAux  := 0
Local nAux2 := 0
Local aArea := GetArea()

If nOpc == 5                                           
	//����������Ŀ
	//� EXCLUSAO �
	//������������
	Begin Transaction
		DEM->(DbSetOrder(1))
		While DEM->( MsSeek( xFilial('DEM') + cCodOpe, .F. ) )
			RecLock('DEM', .F.)
			DbDelete()
			MsUnLock()
		EndDo
	End Transaction
Else
	//��������������������Ŀ
	//� INCLUSAO/ALTERACAO �
	//����������������������
	Begin Transaction	
		For nAux := 1 To Len( aCols )
			If	!GDDeleted( nAux ) 
				DEM->(dbSetOrder(1))			
				If	DEM->( MsSeek( xFilial('DEM') + cCodOpe + GDFieldGet( 'DEM_ITEM', nAux ), .F. ) )
					RecLock('DEM', .F.)
				Else
					RecLock('DEM', .T.)
					DEM->DEM_FILIAL := xFilial('DEM')
					DEM->DEM_CODOPE := cCodOpe
				EndIf
			
				For nAux2 := 1 To Len(aHeader)
					If	aHeader[nAux2,10] != 'V'
						FieldPut(FieldPos(aHeader[nAux2,2]), aCols[nAux,nAux2])
					EndIf
				Next
				MsUnLock()
			Else
				If	DEM->( MsSeek( xFilial('DEM') + cCodOpe + GDFieldGet( 'DEM_ITEM', nAux ), .F. ) )
					RecLock('DEM',.F.)
					DbDelete()
					MsUnLock()
				EndIf			
			EndIf
		Next
	End Transaction
EndIf

RestArea(aArea)
Return NIL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSAE65Vld� Autor � Vitor Raspa           � Data � 11.Jul.06���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacoes                                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE65Vld()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSAE65                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function TMSAE65Vld()
Local lRet	 := .T.
Local cCampo := ReadVar()

If cCampo $ 'M->DEM_ACAO'
	If GDFieldPos('DEM_DACAO') > 0
		GDFieldPut('DEM_DACAO', TMSValField("M->DEM_ACAO",.F.,"DEJ_DACAO"),n)
	EndIf

ElseIf cCampo $ 'M->DEM_TIPTRA'
	If GDFieldPos('DEM_DESTPT') > 0
		GDFieldPut( 'DEM_DESTPT', TMSValField("M->DEM_TIPTRA",.F.),n)
	EndIf

ElseIf cCampo $ 'M->DEM_SERTMS'
	If GDFieldPos('DEM_DESSVT') > 0
		GDFieldPut( 'DEM_DESSVT', TMSValField("M->DEM_SERTMS",.F.),n)
	EndIf

ElseIf cCampo $ 'M->DEM_CODMOV'
	MsgRun( STR0007 , STR0008 , {|| CursorWait(), lRet := TMSE65Movtos(.T., M->DEM_CODMOV), CursorArrow()}) //"Obtendo a lista de Movimentos X Operadora de Frotas" ### "Aguarde..."

EndIf

Return( lRet )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TME65Acoes� Autor � Vitor Raspa           � Data � 11.Jul.06���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consulta F3( DEM ) para obter os Acoes Disponiveis         ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Logico                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function TME65Acoes(cCampo)
Local lRet:= .T.
DEFAULT cCampo := ReadVar()


If cCampo == 'M->DTY_CODMOV'
	lRet:= TMSE65MvCTC( M->DTY_CODOPE, M->DTY_FILORI, M->DTY_VIAGEM )
ElseIf cCampo == 'M->DEM_CODMOV'
	MsgRun( STR0007, STR0008 , {|| CursorWait(), TMSE65Movtos(), CursorArrow()}) //"Obtendo a lista de Movimentos X Operadora de Frotas" ### "Aguarde..."
Else
	TMSValField(cCampo,,,.T.) 
EndIf

Return lRet 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSE65MvCTC� Autor � Vitor Raspa          � Data � 02.Ago.06���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consulta F3( DEM ) para obter os Movimentos Relacionados   ���
���          � a Geracao de Contrato de Carreteiro Complementar           ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Logico                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSA250 - TMSA250COM()                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TMSE65MvCTC( cCodOpe, cFilOri, cViagem )

Local aArea     := GetArea()
Local aAreaDTQ  := DTQ->(GetArea())
Local cAliasQry := ''
Local cQuery    := ''
Local aMovtos   := {}
Local nItem     := 0
Local lRet      := .T.

	DTQ->(DbSetOrder(2)) //-- DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM+DTQ_ROTA
	DTQ->(MsSeek(xFilial('DTQ') + cFilOri + cViagem))

	cAliasQry := GetNextAlias()
	cQuery += "SELECT DEM.DEM_CODMOV, DEM.DEM_DESMOV"
	cQuery += "FROM " + RetSqlName("DEM") + " DEM "
	cQuery += "WHERE "	
	cQuery += "DEM.DEM_FILIAL = '" + xFilial("DEM") + "' AND "
	cQuery += "DEM.DEM_ACAO = '03' AND DEM.DEM_TIPMOV = 'E' AND "
	cQuery += "DEM.DEM_SERTMS = '" + DTQ->DTQ_SERTMS + "' AND "
	cQuery += "DEM.DEM_TIPTRA = '" + DTQ->DTQ_TIPTRA + "' AND "
	cQuery += "DEM.D_E_L_E_T_ = ''"

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	While !(cAliasQry)->(EoF())	
		AAdd(aMovtos, {(cAliasQry)->DEM_CODMOV, (cAliasQry)->DEM_DESMOV })
		(cAliasQry)->(DbSkip())
	EndDo

	If !Empty(aMovtos)
		nItem := TmsF3Array( {	Posicione('SX3', 2, 'DEM_CODMOV', 'X3Titulo()'),;
								Posicione('SX3', 2, 'DEM_DESMOV', 'X3Titulo()')},;
								aMovtos, STR0001 ) //-- Operadoras de Frota X Acoes
		If	nItem > 0
			//-- VAR_IXB eh utilizada como retorno da consulta F3
			VAR_IXB := aMovtos[ nItem, 1 ]
		Else
			lRet := .F.
		EndIF
	Else
		Help('',1,'TMSAE6508') //-- 'Nao existem Movimentos de Envio relacionados a Contrato de Carreteiro Complementar
		lRet := .F.
	EndIf

	(cAliasQry)->(DbCloseArea())

RestArea(aArea)
RestArea(aAreaDTQ)
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSE65Movtos� Autor � Vitor Raspa         � Data � 16.Mar.07���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consulta F3( DEM ) para obter a lista de Movimentos atraves���
���          � do webservice                                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Logico                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSAE65                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TMSE65Movtos(lValida, cCodMov)
Local lRet       := .T.
Local oObj       := NIL
Local cError     := ''
Local cWarning   := ''
Local nAux       := 0
Local nPosCodMov := 0
Local aMsgErr    := {}
Local aVisErr    := {}
Local lTMSXML    := GetMV( 'MV_TMSXML',, .F. )

Default lValida  := .F.
Default cCodMov  := ''

If Empty( aMovOper )
	If Empty(M->DEM_CODOPE)
		Help('',1,'TMSAE6509') //--"E necessario informar o Codigo da Operadora de Frotas para verificar os Movimentos disponiveis"
		lRet := .F.
	Else
		DEG->(DbSetOrder(1))
		If DEG->(MsSeek(xFilial('DEG')+M->DEM_CODOPE))
			If M->DEM_CODOPE == '01' //-- REPOM Tecnologia
				If !lRestRepom
					//��������������������Ŀ
					//�ACIONA O WEBSERVICE �
					//����������������������
					oObj := WSIntegracao():New()
					oObj:cStrCliente           := AllTrim(DEG->DEG_IDOPE)
					oObj:cStrAssinaturaDigital := AllTrim(DEG->DEG_CODACE)			
					oObj:_URL                  := DEG->DEG_URLWS //-- Seta a URL conforme cadastro da Operadora

					If oObj:ConsultaMovimentos()
						If oObj:lConsultaMovimentosResult
							//-- Realiza tratamento no XML de retorno, removendo os acentos e caracteres incompativeis 					
							oObj:cStrXMLOut := TMSNoAcento( oObj:cStrXMLOut )
							
							//-- Gera XML em Disco
							If lTMSXML
								TMSLogXML( oObj:cStrXMLOut, 'ConsultaMovimentosResult.XML' )
							EndIf

							//-- Coverte em Objeto o XML de retorno enviado pela Operadora
							oXML := XMLParser( oObj:cStrXMLOut, '_', @cError, @cWarning )
				
							//-- Adiciona os Movimentos para montagem da Consulta Padrao
							If XMLChildCount(oXML:_Movimentos) > 0
								If ValType(oXML:_Movimentos:_Movimento) == 'A'
									For nAux := 1 To Len( oXML:_Movimentos:_Movimento )
										AAdd(aMovOper,{	oXML:_Movimentos:_Movimento[nAux]:_Movimento_Codigo:Text,;
														oXML:_Movimentos:_Movimento[nAux]:_Movimento_Descricao:Text} )
									Next
								Else
									AAdd( aMovOper, {	oXML:_Movimentos:_Movimento:_Movimento_Codigo:Text,;
														oXML:_Movimentos:_Movimento:_Movimento_Descricao:Text} )
								EndIf
							EndIf
						Else
							aMsgErr := TMSErrOper(M->DEM_CODOPE, oObj:cStrXMLErr, '1')
							lRet := .F.
						EndIf
					Else
						aMsgErr := TMSErrOper(M->DEM_CODOPE,, '2')
						lRet := .F.
					EndIf
				Else
					aMovOper:= TM65GetMov()
				EndIf

			EndIf
		Else
			Help('',1,'TMSAE6510') //-- "Cadastro da Operadora de Frotas nao realizado!"
			lRet := .F.
		EndIf
	EndIf
EndIf

If !lValida
	If !Empty(aMovOper)
		nItem := TmsF3Array( {	Posicione('SX3', 2, 'DEM_CODMOV', 'X3Titulo()'),;
								Posicione('SX3', 2, 'DEM_DESMOV', 'X3Titulo()')},;
								aMovOper, STR0001 ) //-- Operadoras de Frota X Acoes
		If nItem > 0
			//-- VAR_IXB eh utilizada como retorno da consulta F3
			VAR_IXB := aMovOper[ nItem, 1 ]
			If GDFieldPos('DEM_DESMOV') > 0
				GDFieldPut('DEM_DESMOV', PadR(aMovOper[nItem, 2 ], TamSX3("DEM_DESMOV")[1]))
			EndIf
		EndIF
	Else
		If lRet
			Help('',1,'TMSAE6511') //-- "Nao foram encontrados movimentos para esta Operadora"
			lRet := .F.
		EndIf
	EndIf
Else
	If !Empty(aMovOper)
		nPosCodMov := AScan(aMovOper, {|x| AllTrim(x[1]) == AllTrim(cCodMov)})
		If nPosCodMov > 0
			If GDFieldPos('DEM_DESMOV') > 0
				GDFieldPut('DEM_DESMOV', PadR(aMovOper[nPosCodMov, 2 ], TamSX3("DEM_DESMOV")[1]))
			EndIf
		Else
			Help('',1,'TMSAE6512') //-- "O codigo do Movimento informado nao e valido!"
			lRet := .F.
		EndIf
	Else
		lRet := .F.
	EndIf
EndIf

If !lRet .And. !Empty(aMsgErr)
	//-- Carrega o Array com as mensagens de Erro  		
	AaddMsgErr( aMsgErr, aVisErr )	
	If !Empty( aVisErr )
		TmsMsgErr( aVisErr )
	EndIf
EndIf

Return(lRet)

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
     
Private aRotina	:= {	{ STR0002,'AxPesqui'  ,0,1,0,.F.},; //'Pesquisar'
								{ STR0003,'TMSAE65Mnt',0,2,0,NIL},; //'Visualizar'
								{ STR0004,'TMSAE65Mnt',0,3,0,NIL},; //'Incluir' 
								{ STR0005,'TMSAE65Mnt',0,4,0,NIL},; //'Alterar'
								{ STR0006,'TMSAE65Mnt',0,5,0,NIL} } //'Excluir'


If ExistBlock("TME65MNU")
	ExecBlock("TME65MNU",.F.,.F.)
EndIf

Return(aRotina)

//-----------------------------------------------------------------
/*/{Protheus.doc} Retorna os Codigos Movimentos da Repom
Consulta o M�todo GET /Movement/GetMovement

@author Katia
@since 07/01/2021
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function TM65GetMov()
Local aRet    := {}
Local aRetOper:= {}
Local oRepom  := Nil
Local nI      := 0
Local nPos    := 0
Local cIdent  := ""
Local cDesc   := ""

oRepom := TMSBCARepomFrete():New()
If oRepom:Auth()
    aRet:= oRepom:GetMovement() 
    For nI := 1 To Len(aRet)
		If nPos:= aScan(aRet[nI], {|x| x[1] $ "IDENTIFIER" } )
			cIdent := aRet[nI][nPos][2]
			cDesc  := ""

			If nPos:= aScan(aRet[nI], {|x| x[1] $ "DESCRIPTION" } )
			   cDesc:= aRet[nI][nPos][2]
			EndIf
							
			If !Empty(cIdent)
				AAdd(aRetOper,{cIdent,AllTrim( Decodeutf8( cDesc ) )})
			EndIf	
		EndIf							
    Next nI

EndIf
oRepom:Destroy()
FwFreeObj(oRepom)
FwFreeArray(aRet )
Return aRetOper