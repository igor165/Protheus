#Include "Plsmger.ch"
#Include "Plsa476.ch"
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "Colors.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSA476   �Autor  �Microsiga           � Data �  02/03/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro de grupos redutores de custos operacionais         ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAPLS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSA476(lAutoma)
Default lAutoma   := .F.

Private aRotina   := MenuDef()
Private cCadastro := Fundesc()
Private cCodPSA	  := ""

//���������������������������������������������������������������������������
//� Validacao
//���������������������������������������������������������������������������
If !PLSALIASEXI("B65")
	If !lAutoma
		MsgAlert( "N�o � poss�vel utilizar esta rotina! (Execute o compatibilizador da rotina)" )
	EndIf
	Return                                                  
EndIf

B65->(DbSetOrder(1))
B65->(DbGoTop())
If !lAutoma
	B65->(mBrowse(06,01,22,75,"B65",,,20))
EndIf

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor �Microsiga				� Data �03/02/2010���
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
���          �	  1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
Private aRotina := {{ STR0001 , 'AxPesqui' , 0 ,K_Pesquisar	  ,0 ,.F.},; //"Pesquisar"
{ STR0002 , 'PLS476Mov' , 0 ,K_Visualizar ,0 ,Nil},; //"Visualizar"
{ STR0003 , 'PLS476Mov' , 0 ,K_Incluir	  ,0 ,Nil},; //"Incluir"
{ STR0004 , 'PLS476Mov' , 0 ,K_Alterar	  ,0 ,Nil},; //"Alterar"
{ STR0005 , 'PLS476Mov' , 0 ,K_Excluir	  ,0 ,Nil} } //"Excluir"
Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PLS476MOV � Autor � Microsiga             � Data � 03/02/11 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Movimentacoes de grupos redutores                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �PLS476Mov(cAlias,nReg,nOpc)                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLS476Mov(cAlias,nReg,nOpc, lAutoma)
Local I__f 		:= 0
Local nOpca		:= 0
Local nBD6		:= 0
Local aPosObj	:= {}
Local aObjects	:= {}
Local aSize		:= {}
Local aInfo		:= {}
Local aCabB66	:= {}
Local aDadB66	:= {}
Local aTrbB66	:= {}
Local lLock 	:= .F.
Local nOpcx		:= nOpc
Local oDlgFolder
Local oEncB65
Local oFolder
Local oFont
Local oDlg
Local aDifSize:= {,,,,35,3,,}//array com dimen��es para corre��o de telas na vers�o 12

Default lAutoma := .F.

Private aCols	:= {}
Private aHeader	:= {}
Private oBrwB66

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

Store Header "B66" TO aCabB66 For .T.

If nOpcx == K_Incluir
	Store COLS Blank "B66" TO aDadB66 FROM aCabB66
Else
	B66->(DbSetOrder(1))
	If !B66->(DbSeek(xFilial("B66")+B65->B65_CODIGO))
		Store COLS Blank "B66" TO aDadB66 FROM aCabB66
	Else
		Store COLS "B66" TO aDadB66 FROM aCabB66 VETTRAB aTrbB66 While B66->(B66_FILIAL+B66_CODIGO) == xFilial("B65")+B65->B65_CODIGO
	EndIf
	If Len(aDadB66) == 0
		Store COLS Blank "B66" TO aDadB66 FROM aCabB66
	EndIf
EndIf

aSize	 := MsAdvSize()
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo	:= { aSize[1], aSize[2], aSize[3], aSize[4], 5, 5 }
aPosObj	:= MsObjSize( aInfo, aObjects, .T. )

If !lAutoma
	DEFINE MSDIALOG oDlgFolder TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL
EndIf

If nOpcx == K_Incluir
	Copy "B65" TO Memory Blank
Else
	Copy "B65" TO Memory
EndIf

cAlias:="B65"
nReg := B65->(RecNo())

If !lAutoma
	if Val(GetVersao(.F.)) >= 12 //Valida vers�o 12
		oEncB65 := MSMGet():New(cAlias,nReg,nOpcx,,,,,aPosObj[1],,,,,,oDlgFolder,,,.F.)
		oBrwB66 := TPLSBrw():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,4],aPosObj[2,3],nil,oDlgFolder,nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabB66,aDadB66,.F.,"B66",nOpcx,STR0007,nil,nil,nil,aTrbB66,'PlsVldB66',,,,,,,,,,,,aDifSize)
		oBrwB66:bGotFocus := {||If(!Obrigatorio(oEncB65:aGets, oEncB65:aTela),oEncB65:SetFocus(),.T.)}
	Else
		oEncB65 := MSMGet():New(cAlias,nReg,nOpcx,,,,,aPosObj[1],,,,,,oDlgFolder,,,.F.)
		oBrwB66 := TPLSBrw():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,4],aPosObj[2,3],nil,oDlgFolder,nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabB66,aDadB66,.F.,"B66",nOpcx,STR0007,nil,nil,nil,aTrbB66,'PlsVldB66',,)
		oBrwB66:bGotFocus := {||If(!Obrigatorio(oEncB65:aGets, oEncB65:aTela),oEncB65:SetFocus(),.T.)}
	Endif

	ACTIVATE MSDIALOG oDlgFolder ON INIT EnchoiceBar(oDlgFolder,{|| If( P476TudoOk(nOpcx) ,(PlsEndBrw(),nOpca := 1,oDlgFolder:End()),.F.)},{|| PlsEndBrw(), nOpca :=2 , oDlgFolder:End() },K_MsgDel)
EndIf

If lAutoma .OR. nOpca == K_OK
	If nOpcx <> K_Visualizar
		B65->(DbGoTo(nReg))
		PLUPTENC("B65",nOpc)
		aChave := {}
		aAdd(aChave,{"B66_CODIGO",M->B65_CODIGO})
		If !lAutoma
			For nBD6 := 1 To Len(oBrwB66:aCols)
				oBrwB66:aCols[nBD6,1] := M->B65_CODIGO
			Next
			oBrwB66:Grava(aChave)
		EndIf
	EndIf
EndIf

Return

Static Function P476TudoOk(nOpc, lAutoma)
Local lRet := .T.
Default lAutoma := .F.

B65->(DbSetOrder(1))
B65->(DbSeek(xFilial("B65")+M->B65_CODINT+M->B65_CODIGO))
If nOpc == K_Incluir .And. !B65->(Eof())
	Help("",1,"JAGRAVADO")
	Return .F.
EndIf

If !lAutoma .AND. ! (oBrwB66:TudoOk())
	lRet := .F.
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PlsVldB66 �Autor  �Microsiga           � Data �  02/10/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Validacao das vigencias dos itens ( B66 )                   ���
�������������������������������������������������������������������������͹��
���Uso       �SIGAPLS                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PlsVldB66()
Local nContBrw := 0
Local nPosIni  := 0
Local nPosFin  := 0
Local nPosTab  := 0
Local nPosPro  := 0
Local lRet     := .T.
Local aArea	   := GetArea()
Local nUsado   := Len(oBrwb66:aHeader)

dbSelectArea("B66")
B66->(dbSetOrder(1))

If !Empty(M->B66_VIGDE)
	nPosIni  := Ascan(oBrwB66:aHeader,{|x| Alltrim(x[2])=="B66_VIGDE"})
	nPosFin  := Ascan(oBrwB66:aHeader,{|x| Alltrim(x[2])=="B66_VIGATE"})
	nPosTab  := Ascan(oBrwB66:aHeader,{|x| Alltrim(x[2])=="B66_CODTAB"})
	nPosPsa  := Ascan(oBrwB66:aHeader,{|x| Alltrim(x[2])=="B66_CODPSA"})
	
	For nContBrw := 1 To Len(oBrwB66:aCols)
		If !oBrwB66:aCols[nContBrw][nUsado+1]
			If !nContBrw == n
				If !M->B66_VIGDE == Ctod(" / / ")
					If M->B66_VIGDE <= oBrwB66:aCols[nContBrw][nPosFin] .And. M->B66_CODTAB+M->B66_CODPSA == oBrwB66:aCols[nContBrw][nPosTab]+oBrwB66:aCols[nContBrw][nPosPsa]
						Aviso(STR0008,STR0009,{STR0010},2)//"Vig�ncia Inicial"###"A Data Incial da Nova Vig�ncia Precisa ser Maior que a Data Final da Ultima Vig�ncia!"###"Ok"
						lRet := .F.
						Return .F.
					EndIf
				EndIf
			EndIf
		EndIf
	Next nContBrw
	
	If !M->B66_VIGATE == Ctod(" / / ") .And. M->B66_VIGDE > M->B66_VIGATE
		Aviso(STR0008,STR0011,{STR0010},2)//"Vig�ncia Inicial"###"A vig�ncia inicial deve ser menor ou igual a vig�ncia final."###"Ok"
		lRet := .F.
		Return .F.
	EndIf
	
	For nContBrw := 1 To Len(oBrwB66:aCols)
		If !oBrwB66:aCols[nContBrw][nUsado+1]
			If !nContBrw == n
				If !M->B66_VIGDE == Ctod(" / / ")
					If M->B66_VIGDE >= oBrwB66:aCols[nContBrw][nPosIni] .And. M->B66_VIGDE <= oBrwB66:aCols[nContBrw][nPosFin].And. M->B66_CODTAB+M->B66_CODPSA == oBrwB66:aCols[nContBrw][nPosTab]+oBrwB66:aCols[nContBrw][nPosPsa]
						Aviso(STR0012,STR0013,{STR0010},2)	//"Vig�ncia Informada"###"J� existe um intervalo de data que compreende a data selecionada!"###"Ok"
						lRet := .F.
						Return .F.
					EndIf
				EndIf
			EndIf
		EndIf
	Next nContBrw
	
	For nContBrw := 1 To Len(oBrwB66:aCols)
		If !oBrwB66:aCols[nContBrw][nUsado+1]
			If !nContBrw == n
				If (oBrwB66:aCols[nContBrw][nPosFin] == Ctod(" / / ") .Or. oBrwB66:aCols[nContBrw][nPosFin] >= dDataBase) .And. M->B66_CODTAB+M->B66_CODPSA == oBrwB66:aCols[nContBrw][nPosTab]+oBrwB66:aCols[nContBrw][nPosPsa]
					Aviso(STR0014,STR0015,{STR0010},2) //"Vig�ncia em Aberto"###"J� existe uma Vig�ncia em Aberto!"###"Ok"
					lRet := .F.
					Return .F.
				EndIf
			EndIf
		EndIf
	Next nContBrw
EndIf

RestArea(aArea)

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � PLSUnsMed  � Autor �Microsiga          � Data � 10/02/2011 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � F3 da listagem das unidades de medidas                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAPLS                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Padrao do mBrowse                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PLSUnsMed(cDado,lTela,lAutoma)

	Static objCENFUNLGP := CENFUNLGP():New()

Local cSQL	  := ""
Local cStm	  := ""
Local nInd	  := 0
Local nPos	  := 0
Local nQtd	  := 0
Local bChk	  := {|| nQtd := PlsCntLst(aLista) }
Local aLista  := {}
Local aGrupos := {}
Local nOpca   := 0
Local bOK     := { || nOpca := K_OK, oDlg:End() }
Local bCancel := { || oDlg:End() }
Local oDlg
Local oGrupo
Local nTam	:=0
Default lTela 	:= .T.
Default lAutoma := .F.
//��������������������������������������������������������������������������Ŀ
//� coloca virgula no comeco (caso tenha inicializador padrao)               �
//����������������������������������������������������������������������������
cDado := AllTrim(cDado)
If Subs(cDado,Len(cDado),1) != "," .And. cDado != ""
	cDado += ","
EndIf

cSql := " SELECT BD3_CODIGO, BD3_DESCRI "
cSql += "   FROM "+ RetSQLName("BD3")
cSql += "  WHERE BD3_FILIAL = '" + xFilial("BD3") + "' "
cSql += "  	 AND D_E_L_E_T_ <> '*' "

cStm := ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cStm),"TRB",.F.,.T.)

While !TRB->( Eof() )
	aAdd( aGrupos , { TRB->BD3_CODIGO,TRB->BD3_DESCRI } )
	TRB->( DbSkip() )
EndDo
TRB->( DbCloseArea() )

For nInd := 1 To Len(aGrupos)
	aAdd( aLista , { aGrupos[nInd,1],aGrupos[nInd,2],If(aGrupos[nInd,1] $ cDado,.T.,.F.) } )
Next

If lTela
	DEFINE MSDIALOG oDlg TITLE STR0016 FROM ndLinIni,ndColIni TO ndLinFin,ndColFin OF GetWndDefault()	//"Unidades de Medida de Sa�de"
	@ 020,012 SAY oSay PROMPT STR0017 SIZE 300,010 OF oDlg PIXEL COLOR CLR_HBLUE //"Selecione a(s) unidade(s) de medida que deseja informar"

	oGrupo := TcBrowse():New( 035, 012, 330, 150,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
	oGrupo:AddColumn(TcColumn():New(" "		,{ || IF(aLista[oGrupo:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) },"@c",nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))
	oGrupo:AddColumn(TcColumn():New(STR0018	,{ || OemToAnsi(aLista[oGrupo:nAt,1]) },"@!",nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil)) //"Codigo"
	oGrupo:AddColumn(TcColumn():New(STR0019	,{ || OemToAnsi(aLista[oGrupo:nAt,2]) },"@C",nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil))	//Descricao"
	
//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	if objCENFUNLGP:isLGPDAt()
		aCampos := {.F., "BD3_CODIGO", "BD3_DESCRI"}
		aBls := objCENFUNLGP:getTcBrw(aCampos)

		oGrupo:aObfuscatedCols := aBls
	endif
	
	oGrupo:SetArray(aLista)
	oGrupo:bLDblClick := { || Eval(bChk) , Iif( nQtd<=Len(aLista) .Or. aLista[oGrupo:nAt,3] , aLista[oGrupo:nAt,3] := IF(aLista[oGrupo:nAt,3],.F.,.T.) , .F. ) }

	ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar( oDlg,bOK,bCancel,.F.,{} )
Else
	nOpca := K_OK
EndIf

If lAutoma .OR. nOpca == K_OK
	cDado := ""
	For nInd := 1 To Len(aLista)
		If aLista[nInd,3]
			cDado += aLista[nInd,1]+","
		EndIf
	Next
EndIf

If Subs(cDado,Len(cDado),1) == ","
	cDado := Subs(cDado,1,Len(cDado)-1)
EndIf

nTam:=Len(cDado)
VAR_IXB := PadR(cDado,nTam)

Return(!Empty(cDado))

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PlsCntLst	     �Autor �Microsiga         � Data � 10/02/11  ���
�������������������������������������������������������������������������͹��
���Desc.     � Conta itens marcados da matriz							  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PlsCntLst(aLista)
LOCAL nI
LOCAL nQtd := 0

For nI := 1 To Len(aLista)
	If aLista[nI,3]
		nQtd++
	EndIf
Next

Return nQtd


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSA476   �Autor  �Microsiga           � Data �  02/10/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PL476PRO(lAutoma)
Local lRet := .T.
Default lAutoma := .F.

If !Empty(M->B66_CODTAB) .And. !Empty(M->B66_CODPSA)
	M->B66_DESPRO := Posicione("BR8",1,xFilial("BR8")+M->B66_CODTAB+M->B66_CODPSA,"BR8_DESCRI")
EndIf

If ReadVar() == "M->B66_CODPSA"

	If Empty(M->B66_CODTAB)
		If !lAutoma
			MsgInfo(STR0024)//"� necess�rio informar o campo 'Cod.Tab.Pad.'"
		EndIf
		lRet := .F.		
	ElseIf !ExistCPO("BR8",M->B66_CODTAB+M->B66_CODPSA,1)
		lRet := .F.
	Endif

ElseIf ReadVar() == "M->B66_CODTAB"

	If !ExistCPO("BR4",M->B66_CODTAB,1)
		lRet := .F.
	EndIf

Endif

Return lRet
                  
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSA476   �Autor  �Microsiga           � Data �  02/10/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Pesquisa tabela padrao                                      ���
�������������������������������������������������������������������������͹��
���Uso       �SIGAPLS                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PL476Pesq(lAutoma)
LOCAL lRet    := .F.
LOCAL cCodPad := ""
LOCAL cCodPSA := ""
Default lAutoma := .F.

If Type("M->B66_CODTAB") <> "U"
	cCodPad := M->B66_CODTAB
Endif

If !lAutoma
	lRet := PLSPESPROC(cCodPad,.F.)
	cCodPSA := BR8->BR8_CODPSA
EndIf
Return lRet
