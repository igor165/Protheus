#include "PROTHEUS.ch"
#include "TMSAI50.ch"

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa   �  TMSAI50   � Autor � Richard Anderson   � Data � 22/11/06 ���
��������������������������������������������������������������������������͹��
���             	Permisso por veiculo                        		         ���
��������������������������������������������������������������������������͹��
��� Sintaxe    �  TMSAI50()                                                ���
��������������������������������������������������������������������������͹��
��� Parametros �                                         			         ���
��������������������������������������������������������������������������͹��
��� Retorno    � NIL                                                       ���
��������������������������������������������������������������������������͹��
��� Uso        � SIGATMS - Gestao de Transportes                           ���
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
Function TMSAI50()

Private cCadastro	:= STR0001 //-- Permisso por Ve�culo
Private aRotina	:= {{ STR0002  , "AxPesqui"  , 0, 1 },; //"Pesquisar"
				          { STR0003  , "TMAI50Mnt" , 0, 2 },; //"Visualizar"
 				          { STR0004  , "TMAI50Mnt" , 0, 3 },; //"Incluir"
 				          { STR0005  , "TMAI50Mnt" , 0, 4 },; //"Alterar"
				          { STR0006  , "TMAI50Mnt" , 0, 5 } } //"Excluir"

dbSelectArea("DIE")
dbSetOrder(1)
dbGoTop()

mBrowse(06,01,22,75,"DIE")

Return Nil

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � TMAI50Mnt � Autor � Richard Anderson     � Data �19.03.2006 ���
��������������������������������������������������������������������������Ĵ��
���          � Interface da Rotina de Permisso por Veiculo                 ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1: Alias da tabela                                      ���
���          � ExpN2: Numero do Registro                                   ���
���          � ExpN3: Opcao do aRotina                                     ���
��������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function TMAI50Mnt(cAlias, nReg, nOpcx)

Local aAreaAtu := GetArea()
Local nTLinhas := 0

//-- EnchoiceBar
Local aTmsVisual	:= {}
Local aTmsAltera	:= {}
Local nOpcA			:= 0
Local nOpcB       := aRotina[nOpcx,4]
Local oTmsEnch

//-- Dialog
Local oTmsDlgEsp
Local aNoFields	:= {}
Local aYesFields	:= {}

//-- Controle de dimensoes de objetos
Local aObjects		:= {}
Local aInfo			:= {}

//-- GetDados
Local nNumLinhas  := 999

//-- EnchoiceBar
Private aTela[0][0]
Private aGets[0]

//-- GetDados
Private oTmsGetD
Private aHeader	 := {}
Private aCols	    := {}
Private aTmsPosObj := {}
                               
////-- Determina campos que n�o aparecem na GETDADOS
//Aadd(aNoFields,'DIF_FILIAL')
Aadd(aNoFields,'DIF_CODVEI')
Aadd(aNoFields,'DIF_NUMPER')

//-- Configura variaveis da Enchoice
RegToMemory( cAlias, INCLUI )

//-- Configura variaveis da GetDados
TMSFillGetDados( nOpcx, 'DIF', 1, xFilial( 'DIF' ) + M->DIE_CODVEI+M->DIE_NUMPER, { ||  DIF->(DIF_FILIAL + DIF_CODVEI + DIF_NUMPER) },;
																		 { || .T. }, aNoFields,	aYesFields )
If Inclui
	GdFieldPut("DIF_ITEM",StrZero(1,Len(DIF->DIF_ITEM)),1)
Endif		

nTLinhas := Len(aCols)																			 
																			 
//-- Dimensoes padroes
aSize := MsAdvSize()
AAdd( aObjects, { 100, 040, .T., .T. } )
AAdd( aObjects, { 100, 060, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aTmsPosObj := MsObjSize( aInfo, aObjects,.T.)

DIF->(dbGoto(0))

DEFINE MSDIALOG oTmsDlgEsp TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
	//-- Monta a enchoice.
	oTmsEnch	:= MsMGet():New( cAlias, nReg, nOpcx,,,,, aTmsPosObj[1],, 3,,,,,,.T. )
	//        MsGetDados(                      nT ,                  nL,                 nB,                  nR,    nOpc,     cLinhaOk,      cTudoOk,cIniCpos,lDeleta,aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)
	oTmsGetD := MSGetDados():New(aTmsPosObj[ 2, 1 ], aTmsPosObj[ 2, 2 ],aTmsPosObj[ 2, 3 ], aTmsPosObj[ 2, 4 ], nOpcx,"TMAI50LOk()","TMAI50TOk()","+DIF_ITEM",.T.,nil,nil,nil,nNumLinhas)
ACTIVATE MSDIALOG oTmsDlgEsp ON INIT EnchoiceBar( oTmsDlgEsp,{|| If(oTmsGetD:TudoOk(),(oTmsDlgEsp:End(),nOpcA := 1),nOpcA := 0)},{|| nOpcA := 0, oTmsDlgEsp:End() }) 

If nOpcx != 2 .And. nOpcA == 1
	TMAI50Grv(nOpcx)
EndIf

RestArea(aAreaAtu)

Return nOpcA

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � TMAI50LOk � Autor � Richard Anderson     � Data �22.11.2006 ���
��������������������������������������������������������������������������Ĵ��
���          � Validacao de digitacao de linha                             ���
��������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function TMAI50LOk()
Local lRet    := .T.
Local nItem   := 0
Local cCdpOri := ''
Local cCdpDes := ''
Local nPosOri := GdFieldPos('DIF_CDPORI')
Local nPosDes := GdFieldPos('DIF_CDPDES')
//-- Nao avalia linhas deletadas.
If	!GDDeleted( n )
   If lRet := MaCheckCols(aHeader,aCols,n)
	   //-- Analisa se ha itens duplicados na GetDados.
	   lRet := GDCheckKey( { 'DIF_CDPORI', 'DIF_CDPDES' }, 4 )
	EndIf   
	cCdpOri := GdFieldGet('DIF_CDPDES')
	cCdpDes := GdFieldGet('DIF_CDPORI')
	If lRet .And. Len(aCols) == oTmsGetD:oBrowse:nAt .And. Ascan(aCols,{ | e | e[nPosOri]+e[nPosDes] == cCdpOri+cCdpDes }) == 0
		nItem := Len(aCols) + 1
		//-- Adiciona nova linha no aCols
		Eval(oTmsGetD:oBrowse:bAdd)
		GdFieldPut('DIF_CDPORI',cCdpOri,nItem)
		GdFieldPut('DIF_PAIORI',Posicione('SYA',1,xFilial('SYA')+cCdpOri,'YA_DESCR'),nItem)
		GdFieldPut('DIF_CDPDES',cCdpDes,nItem)
		GdFieldPut('DIF_PAIDES',Posicione('SYA',1,xFilial('SYA')+cCdpDes,'YA_DESCR'),nItem)
	EndIf		
EndIf
Return(lRet)

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � TMAI50TOk � Autor � Richard Anderson     � Data �22.11.2006 ���
��������������������������������������������������������������������������Ĵ��
���          � Validacao de confirmacao para gravacao                      ���
��������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function TMAI50TOk()

Local lRet     := .T.
Local cSeekDIE := ''

//-- Analisa se os campos obrigatorios da GetDados foram informados.
If	lRet
	lRet := oTmsGetD:ChkObrigat( n )
EndIf
//-- Analisa o linha ok.
If lRet
	lRet := TMAI50LOk()
EndIf

//-- Analisa se todas os itens da GetDados estao deletados.
If lRet .And. Ascan( aCols, { |x| x[ Len( x ) ] == .F. } ) == 0
	Help( ' ', 1, 'OBRIGAT2') //Um ou alguns campos obrigatorios nao foram preenchidos no Browse.
	lRet := .F.
EndIf

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMAI50Vld� Autor � Richard Anderson      � Data �22/11/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida antes de editar o campo.                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TMAI50Vld() 

Local lRet     := .T.
Local cCampo   := ReadVar()
Local aAreaDA3 := DA3->(GetArea())

If cCampo == 'M->DIE_CODVEI'
	DA3->(dbSetOrder(1))
	If DA3->(!dbSeek(xFilial('DA3')+M->DIE_CODVEI))
		Help('',1,'REGNOIS')
		lRet := .F.
	EndIf
	If lRet		
		M->DIE_MODVEI := DA3->DA3_DESC
		M->DIE_PLACA  := DA3->DA3_PLACA
		M->DIE_ANOMOD := DA3->DA3_ANOMOD
		M->DIE_ANOFAB := DA3->DA3_ANOFAB
		M->DIE_MARVEI := Tabela('M6',DA3->DA3_MARVEI,.F.)
		M->DIE_CHASSI := DA3->DA3_CHASSI
	EndIf
ElseIf cCampo == 'M->DIE_INIVIG' 
	If !Empty(M->DIE_FIMVIG) 
		lRet := M->DIE_INIVIG <= M->DIE_FIMVIG
	EndIf
ElseIf cCampo == 'M->DIE_FIMVIG' 
	If !Empty(M->DIE_INIVIG) 
		lRet := M->DIE_FIMVIG >= M->DIE_INIVIG
	EndIf
ElseIf cCampo == 'M->DIF_CDPORI'	
	lRet := ExistCpo('SYA',M->DIF_CDPORI,1)	
	If lRet
		GDFieldPut('DIF_PAIORI',Posicione('SYA',1,xFilial('SYA')+M->DIF_CDPORI,'YA_DESCR'))
	EndIf
ElseIf cCampo == 'M->DIF_CDPDES'	
	lRet := ExistCpo('SYA',M->DIF_CDPDES,1)	
	If lRet
		GDFieldPut('DIF_PAIDES',Posicione('SYA',1,xFilial('SYA')+M->DIF_CDPDES,'YA_DESCR'))
	EndIf
ElseIf cCampo == 'M->DIE_CODFOR' .Or. cCampo == 'M->DIE_LOJFOR'
	If cCampo == 'M->DIE_CODFOR' .And. Empty(M->DIE_CODFOR)
		M->DIE_LOJFOR := CriaVar('DIE_LOJFOR',.F.)
	ElseIf cCampo == 'M->DIE_LOJFOR' .And. Empty(M->DIE_LOJFOR)
		M->DIE_CODFOR := CriaVar('DIE_CODFOR',.F.)
	ElseIf !Empty(M->DIE_CODFOR)
		lRet := ExistCpo('SA2',M->DIE_CODFOR+AllTrim(M->DIE_LOJFOR))
	EndIf
	If lRet 
		M->DIE_NOMFOR := Posicione('SA2',1,xFilial('SA2')+M->DIE_CODFOR+M->DIE_LOJFOR,'A2_NOME')
	EndIf		
EndIf			
RestArea(aAreaDA3)
Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMAI50Grv� Autor � Richard Anderson      � Data �22/11/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de Gravacao                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TMAI50Grv(nOpcx) 

Local nCntFor	:= 0
Local nCntFo1	:= 0    
Local cCodVei	:= ""
Local cNumPer	:= ""

If	nOpcx == 5
	Begin Transaction
	RecLock('DIE', .F.)   // Exclui o Cabecalho
	DbDelete()
	MsUnLock()
	
	cCodVei := DIF->DIF_CODVEI
	cNumPer := DIF->DIF_NUMPER
	DIF->( DbSetOrder( 1 ) )
	While DIF->( DbSeek( xFilial('DIF') + cCodVei + cNumPer ) )
		//-- Exclui Itens das Regras de Tributacao.
		RecLock('DIF', .F.)
		DbDelete()
		MsUnLock()   
	EndDo
	End Transaction
Else
	Begin Transaction
	
	RecLock( "DIE", nOpcx == 3 )
	
	Aeval( dbStruct(), { |aFieldName, nI | FieldPut( nI, If('FILIAL' $ aFieldName[1],;
													   xFilial( "DIE" ), M->&(aFieldName[1]) ) ) } )
	
	DIF->(dbSetOrder(1))
	For nCntFor := 1 To Len( aCols )
		If	!GDDeleted( nCntFor ) 
			If	DIF->( MsSeek( xFilial('DIF') + M->DIE_CODVEI + M->DIE_NUMPER + GDFieldGet( 'DIF_ITEM', nCntFor ), .F. ) )
				RecLock('DIF',.F.)
			Else
				RecLock('DIF',.T.)
				DIF->DIF_FILIAL := xFilial('DIF')
				DIF->DIF_CODVEI := M->DIE_CODVEI
				DIF->DIF_NUMPER := M->DIE_NUMPER
			EndIf
			For nCntFo1 := 1 To Len(aHeader)
				If	aHeader[nCntFo1,10] != 'V'
					FieldPut(FieldPos(aHeader[nCntFo1,2]), aCols[nCntFor,nCntFo1])
				EndIf
			Next 
			MsUnLock()
		Else
			If	DIF->( MsSeek( xFilial('DIF') + M->DIE_CODVEI + M->DIE_NUMPER + GDFieldGet( 'DIF_ITEM', nCntFor ), .F. ) )
				RecLock('DIF', .F.)
				DbDelete()
				MsUnLock()
			EndIf
		EndIf
	Next
	End Transaction
EndIf
Return NIL
