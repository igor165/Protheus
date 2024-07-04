
#include "PROTHEUS.ch"
#include "TMSAF40.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa   º  TMSAF40   º Autor º Richard Anderson   º Data º 14/01/07 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Depreciação de Veículos                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe    º  TMSAF40()                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros º                                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno    º NIL                                                       º±±
±±ºÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso        º SIGATMS - Gestao de Transportes                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Comentario º                                                           º±±
±±º            º                                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          Atualizacoes efetuadas desde a coDFHicacao inicial            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador º  Data  º BOPS º             Motivo da Alteracao           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º            ºxx/xx/02ºxxxxxxº                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAF40()

Private cCadastro	:= STR0001 //-- Depreciação de Veículos
Private aRotina	:= {{ STR0002  , "AxPesqui"  , 0, 1 },; //"Pesquisar"
				          { STR0003  , "TMAF40Mnt" , 0, 2 },; //"Visualizar"
 				          { STR0004  , "TMAF40Mnt" , 0, 3 },; //"Incluir"
 				          { STR0005  , "TMAF40Mnt" , 0, 4 },; //"Alterar"
				          { STR0006  , "TMAF40Mnt" , 0, 5 },; //"Excluir"
				          { STR0007  , "TMAF40Imp" , 0, 3 } } //"Importar

dbSelectArea("DFG")
dbSetOrder(1)
dbGoTop()

mBrowse(06,01,22,75,"DFG")

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAF40Mnt ³ Autor ³ Richard Anderson     ³ Data ³14.01.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Interface da Rotina de Depreciação de Veículos              ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Alias da tabela                                      ³±±
±±³          ³ ExpN2: Numero do Registro                                   ³±±
±±³          ³ ExpN3: Opcao do aRotina                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMAF40Mnt(cAlias, nReg, nOpcx)

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
Local nPosSEq      

//-- EnchoiceBar
Private aTela[0][0]
Private aGets[0]

//-- GetDados
Private oTmsGetD
Private aHeader	 := {}
Private aCols	    := {}
Private aTmsPosObj := {}

Aadd(aNoFields,'DFH_CODVEI')

//-- Configura variaveis da Enchoice
RegToMemory( cAlias, INCLUI )

//-- Configura variaveis da GetDados
TMSFillGetDados( nOpcx, 'DFH', 1, xFilial( 'DFH' ) + M->DFG_CODVEI , { ||  DFH->(DFH_FILIAL + DFH_CODVEI ) },;
																		 { || .T. }, aNoFields,	aYesFields )
nTLinhas := Len(aCols)																			 
																			 
//-- Dimensoes padroes
aSize := MsAdvSize()
AAdd( aObjects, { 100, 040, .T., .T. } )
AAdd( aObjects, { 100, 060, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aTmsPosObj := MsObjSize( aInfo, aObjects,.T.)

nPosSEq := GdFieldPos('DFH_SEQUEN')
IF Empty(aCols[1,nPosSEq])
	aCols[1,nPosSEq]:= StrZero(1,Len(DFH->DFH_SEQUEN))
Endif

DFH->(dbGoto(0))

DEFINE MSDIALOG oTmsDlgEsp TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
	//-- Monta a enchoice.
	oTmsEnch	:= MsMGet():New( cAlias, nReg, nOpcx,,,,, aTmsPosObj[1],, 3,,,,,,.T. )
	
	//        MsGetDados(                      nT ,                  nL,                 nB,                  nR,    nOpc,     cLinhaOk,      cTudoOk,cIniCpos,lDeleta,aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)
	oTmsGetD := MSGetDados():New(aTmsPosObj[ 2, 1 ], aTmsPosObj[ 2, 2 ],aTmsPosObj[ 2, 3 ], aTmsPosObj[ 2, 4 ], nOpcx,"TMAF40LOk()","TMAF40TOk()","+DFH_SEQUEN",.T.,nil,nil,nil,nNumLinhas)
	
ACTIVATE MSDIALOG oTmsDlgEsp ON INIT EnchoiceBar( oTmsDlgEsp,{|| If(oTmsGetD:TudoOk(),(oTmsDlgEsp:End(),nOpcA := 1),nOpcA := 0)},{|| nOpcA := 0, oTmsDlgEsp:End() }) 

If nOpcx != 2 .And. nOpcA == 1
	TMAF40Grv(nOpcx)
EndIf

RestArea(aAreaAtu)

Return nOpcA

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAF40LOk ³ Autor ³ Richard Anderson     ³ Data ³14.01.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Validacao de digitacao de linha                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMAF40LOk()
Local lRet   := .T.
//-- Nao avalia linhas deletadas.
If	!GDDeleted( n )
   If lRet := MaCheckCols(aHeader,aCols,n)
	   //-- Analisa se ha itens duplicados na GetDados.
	   lRet := GDCheckKey( { 'DFH_TIPO' }, 4 )
	EndIf   
EndIf
Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAF40TOk ³ Autor ³ Richard Anderson     ³ Data ³22.11.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Validacao de confirmacao para gravacao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMAF40TOk()

Local lRet     := .T.
Local cSeekDFG := ''

//-- Analisa se os campos obrigatorios da GetDados foram informados.
If	lRet
	lRet := oTmsGetD:ChkObrigat( n )
EndIf
//-- Analisa o linha ok.
If lRet
	lRet := TMAF40LOk()
EndIf
    

//-- Analisa se todas os itens da GetDados estao deletados.
If lRet .And. Ascan( aCols, { |x| x[ Len( x ) ] == .F. } ) == 0
	Help('',1,'OBRIGAT2')
	lRet := .F.
EndIf

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ\ÜÜÜÜÜÜÜÜÜÜÜÜ\ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜœÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAF40Vld³ Autor ³ Richard Anderson      ³ Data ³22/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida antes de editar o campo.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMAF40Vld() 
Local lRet       := .T.
Local cCampo     := AllTrim(ReadVar())
Local nAux       := 0
Local lAAddACols := .F.
Local cSequen    := StrZero(1,Len(DFH->DFH_SEQUEN))

If cCampo == 'M->DFG_CODVEI'
	If !Empty(M->DFG_CODVEI)
		lRet := ExistCpo('DA3',M->DFG_CODVEI) .AND. ExistChav('DFG',M->DFG_CODVEI)
		If lRet
			M->DFG_MODVEI := Posicione('DA3',1,xFilial('DA3')+M->DFG_CODVEI,'DA3_DESC')
		EndIf
	EndIf
EndIf	

If lRet .And. cCampo == 'M->DFG_CBASE'
	If !Empty(M->DFG_ITEM)
		lRet := ExistCpo('SN1',M->DFG_CBASE+M->DFG_ITEM)
	EndIf
EndIf	

If lRet .And. cCampo == 'M->DFG_ITEM'
	If !Empty(M->DFG_CBASE)
		lRet := ExistCpo('SN1',M->DFG_CBASE+M->DFG_ITEM)
	EndIf
EndIf	

If lRet .And. (cCampo == 'M->DFG_CBASE' .Or. cCampo == 'M->DFG_ITEM') .And. (!Empty(M->DFG_CBASE) .And. !Empty(M->DFG_ITEM))

	lRet := ExistChav('DFG',M->(DFG_CBASE+DFG_ITEM),1)

	If lRet 
		M->DFG_DSCBEM := Posicione('SN1', 1, xFilial( 'SN1' ) +          M->( DFG_CBASE +             DFG_ITEM ), 'N1_DESCRIC' )
		M->DFG_AQUISI := Posicione('SN1', 1, xFilial( 'SN1' ) +          M->( DFG_CBASE +             DFG_ITEM ), 'N1_AQUISIC' )
		M->DFG_CODBEM := Posicione('ST9', 8, xFilial( 'ST9' ) + AllTrim( M->DFG_CBASE ) + AllTrim( M->DFG_ITEM ),'T9_CODBEM'   ) // By RoadMap
		M->DFG_CODVEI := Posicione('DA3', 5, xFilial( 'DA3' ) +          M->DFG_CODBEM                          ,'DA3_COD'     )
		M->DFG_MODVEI := Posicione('DA3', 1, xFilial( 'DA3' ) +          M->DFG_CODVEI                          ,'DA3_DESC'    )

//		M->DFG_CODBEM := Posicione('ST9',8,xFilial('ST9')+M->(DFG_CBASE+M->DFG_ITEM),'T9_CODBEM')
		
		SN3->(DbSetOrder(1)) //-- N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
		If SN3->(MsSeek(xFilial('SN3') + M->(DFG_CBASE+DFG_ITEM)))
			While !SN3->(Eof()) .And. SN3->(N3_FILIAL + N3_CBASE + N3_ITEM) == xFilial('SN3') + M->(DFG_CBASE+DFG_ITEM)

				If lAAddACols //-- Adiciona uma linha no aCols
					n++
					Aadd(aCols,Array(Len(aHeader)+1))
					For nAux := 1 To Len(aHeader)
						aCols[Len(aCols),nAux] := CriaVar(aHeader[nAux,2])
					Next
					aCols[Len(aCols),Len(aHeader)+1] := .F.
					cSequen    := Soma1(cSequen)
				Else
					lAAddACols := .T.
				EndIf

				GDFieldPut('DFH_SEQUEN'	, 	cSequen        , n)
				GDFieldPut('DFH_TIPO  '	, 	SN3->N3_TIPO	, n)
				GDFieldPut('DFH_VORIG1'	,	SN3->N3_VORIG1	, n)
				GDFieldPut('DFH_TXDEP1'	,	SN3->N3_TXDEPR1, n)
				GDFieldPut('DFH_VORIG2'	,	SN3->N3_VORIG2	, n)
				GDFieldPut('DFH_TXDEP2'	,	SN3->N3_TXDEPR2, n)
				GDFieldPut('DFH_VORIG3'	,	SN3->N3_VORIG3	, n)
				GDFieldPut('DFH_TXDEP3'	,	SN3->N3_TXDEPR3, n)
				GDFieldPut('DFH_VORIG4'	,	SN3->N3_VORIG4	, n)
				GDFieldPut('DFH_TXDEP4'	,	SN3->N3_TXDEPR4, n)
				GDFieldPut('DFH_VORIG5'	,	SN3->N3_VORIG5	, n)
				GDFieldPut('DFH_TXDEP5'	,	SN3->N3_TXDEPR5, n)
				GDFieldPut('DFH_VDMES1'	,	SN3->N3_VRDMES1, n)
				GDFieldPut('DFH_VDACU1'	,	SN3->N3_VRDACM1, n)
				GDFieldPut('DFH_VDMES2'	,	SN3->N3_VRDMES2, n)
				GDFieldPut('DFH_VDACU2'	,	SN3->N3_VRDACM2, n)
				GDFieldPut('DFH_VDMES3'	,	SN3->N3_VRDMES3, n)
				GDFieldPut('DFH_VDACU3'	,	SN3->N3_VRDACM3, n)
				GDFieldPut('DFH_VDMES4'	,	SN3->N3_VRDMES4, n)
				GDFieldPut('DFH_VDACU4'	,	SN3->N3_VRDACM4, n)
				GDFieldPut('DFH_VDMES5'	,	SN3->N3_VRDMES5, n)
				GDFieldPut('DFH_VDACU5'	,	SN3->N3_VRDACM5, n)
				GDFieldPut('DFH_FIMDRP'	,	SN3->N3_FIMDEPR, n)				

				SN3->(DbSkip())

			End			
			n := 1
			oTmsGetD:oBrowse:nAt := n
			oTmsGetD:Refresh(.T.)
		EndIf
	EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAF40Grv³ Autor ³ Richard Anderson      ³ Data ³22/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de Gravacao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMAF40Grv(nOpcx) 

Local nCntFor	:= 0
Local nCntFo1	:= 0 
Local cCodVei     

If	nOpcx == 5
	Begin Transaction
	cCodVei := M->DFG_CODVEI
	RecLock('DFG', .F.)   // Exclui o Cabecalho
	DbDelete()
	MsUnLock()
	
	DFH->( DbSetOrder( 1 ) )
	If DFH->( DbSeek( xFilial('DFH') + cCodVei ) )
		While DFH->(!Eof()) .And. DFH->DFH_FILIAL + DFH->DFH_CODVEI == xFilial('DFH') + cCodVei
			//-- Exclui Itens das Regras de Tributacao.
			RecLock('DFH', .F.)
			DbDelete()
			MsUnLock()
			DFH->(DbSkip())
		EndDo
	EndIf
		
	End Transaction
Else
	Begin Transaction
	
	RecLock( "DFG", nOpcx == 3 )
	
  	Aeval( dbStruct(), { |aFieldName, nI | FieldPut( nI, If('FILIAL' $ aFieldName[1],;
													   xFilial( "DFG" ), M->&(aFieldName[1]) ) ) } )
	
	DFH->(dbSetOrder(1))
	For nCntFor := 1 To Len( aCols )
		If	!GDDeleted( nCntFor ) 
			If	DFH->( DbSeek( xFilial('DFH') + M->DFG_CODVEI + GDFieldGet( 'DFH_SEQUEN', nCntFor ) ) )
				RecLock('DFH',.F.)
			Else
				RecLock('DFH',.T.)
				DFH->DFH_FILIAL := xFilial('DFH')
				DFH->DFH_CODVEI := M->DFG_CODVEI
			EndIf
			For nCntFo1 := 1 To Len(aHeader)
				If	aHeader[nCntFo1,10] != 'V'
					FieldPut(FieldPos(aHeader[nCntFo1,2]), aCols[nCntFor,nCntFo1])
				EndIf
			Next 
			MsUnLock()
		Else
			If	DFH->( DbSeek( xFilial('DFH') + M->DFG_CODVEI + GDFieldGet( 'DFH_SEQUEN', nCntFor ) ) )
				RecLock('DFH', .F.)
				DbDelete()
				MsUnLock()
			EndIf
		EndIf
	Next
	End Transaction
EndIf
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMAF40Imp ³ Autor ³ Vitor Raspa           ³ Data ³ 29.Jan.07³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina para importacao dos bens                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMAF40Imp()
Local aSays    := {}
Local aButtons := {}
Local nOpca    := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as perguntas selecionadas                            ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ MV_PAR01 - Do Bem                                            ³
//³ MV_PAR02 - Ate o Bem                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte('TMAF40',.F.) 

//-- FormBatch
Aadd( aSays, STR0008 )  //"Esta opção irá realizar a importacao dos bens (veiculos)"
Aadd( aSays, STR0009 )  //"cadastrados no módulo Ativo Fixo"

Aadd( aButtons, { 1, .T., {|o| nOpca := 1, o:oWnd:End() }})
Aadd( aButtons, { 2, .T., {|o| o:oWnd:End() }})
Aadd( aButtons, { 5, .T., {|| Pergunte('TMAF40',.T.) }})

FormBatch( STR0007, aSays, aButtons ) //-- "Importar"
	
If nOpca == 1
	Processa( { | lEnd | TMAF40PrcI( @lEnd ) }, cCadastro, STR0010, .T. ) //"Importando os Bens..."
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMAF40PrcI ³ Autor ³ Vitor Raspa          ³ Data ³ 29.Jan.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Proaessa a Importacao dos dados                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ¡±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±¡±±±±±±±±±±±±±±±±±±±±±±±±±±±
×ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßŸßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMAF40PrcI( lEnd )
Local aArea     := GetArea()
Local aAreaSN1  := SN1->(GetArea())
Local aAreaDFG  := DFG->(GetArea())
Local cQuery    := ''
Local cAliasQry := GetNextAlias()
Local cSequen   := ''     

cQuery := "SELECT DA3_COD, DA3_CODBEM "
cQuery += "FROM " + RetSQLName('DA3') + " DA3 "
cQuery += "WHERE DA3_FILIAL = '" + xFilial('DA3') + "' AND "
cQuery += "DA3_CODBEM <> ' ' AND "
cQuery += "DA3_CODBEM BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND "
cQuery += "D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

While !(cAliasQry)->(Eof()) .And. !lEnd
	ST9->(DbSetOrder(1))
	If ST9->(MsSeek(xFilial('ST9') + (cAliasQry)->(DA3_CODBEM))) .And. !Empty(ST9->T9_CODIMOB)
		SN1->(DbSetOrder(1)) //-- N1_FILIAL+N1_CBASE+N1_ITEM
		If SN1->(MsSeek(xFilial('SN1') + ST9->T9_CODIMOB)) .And. Empty(SN1->N1_BAIXA) 
			DFG->(DbSetOrder(1))
			If !DFG->(MsSeek(xFilial('DFG') + SN1->(N1_CBASE+N1_ITEM)))
				
				Begin Transaction
				
					RecLock('DFG',.T.)
					DFG->DFG_FILIAL := xFilial('DFG')
					DFG->DFG_CBASE  := SN1->N1_CBASE
					DFG->DFG_ITEM   := SN1->N1_ITEM
					DFG->DFG_CODBEM := M->DFG_CODBEM := Posicione('ST9',8,xFilial('ST9')+SN1->(N1_CBASE+N1_ITEM),'T9_CODBEM')
					DFG->DFG_CODVEI := (cAliasQry)->DA3_COD
					DFG->DFG_STATUS := StrZero(1,Len(DFG->DFG_STATUS)) 
					MsUnLock()
                     
					cSequen := StrZero(0,Len(DFH->DFH_SEQUEN))
					SN3->(DbSetOrder(1)) //-- N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
					If SN3->(MsSeek(xFilial('SN3') + SN1->(N1_CBASE+N1_ITEM)))
						While !SN3->(Eof()) .And. SN3->(N3_FILIAL + N3_CBASE + N3_ITEM) == xFilial('SN3') + SN1->(N1_CBASE+N1_ITEM)
						 
							cSequen := Soma1(cSequen)
							RecLock('DFH',.T.)                     
							DFH->DFH_FILIAL := xFilial('DFH')
							DFH->DFH_CODVEI := (cAliasQry)->DA3_COD
							DFH->DFH_SEQUEN := cSequen
							DFH->DFH_TIPO   := SN3->N3_TIPO
							DFH->DFH_VORIG1 := SN3->N3_VORIG1
							DFH->DFH_TXDEP1 := SN3->N3_TXDEPR1
							DFH->DFH_VORIG2 := SN3->N3_VORIG2
							DFH->DFH_TXDEP2 := SN3->N3_TXDEPR2
							DFH->DFH_VORIG3 := SN3->N3_VORIG3
							DFH->DFH_TXDEP3 := SN3->N3_TXDEPR3
							DFH->DFH_VORIG4 := SN3->N3_VORIG4
							DFH->DFH_TXDEP4 := SN3->N3_TXDEPR4
							DFH->DFH_VORIG5 := SN3->N3_VORIG5
							DFH->DFH_TXDEP5 := SN3->N3_TXDEPR5
							DFH->DFH_VDMES1 := SN3->N3_VRDMES1
							DFH->DFH_VDACU1 := SN3->N3_VRDACM1
							DFH->DFH_VDMES2 := SN3->N3_VRDMES2
							DFH->DFH_VDACU2 := SN3->N3_VRDACM2
							DFH->DFH_VDMES3 := SN3->N3_VRDMES3
							DFH->DFH_VDACU3 := SN3->N3_VRDACM3
							DFH->DFH_VDMES4 := SN3->N3_VRDMES4
							DFH->DFH_VDACU4 := SN3->N3_VRDACM4
							DFH->DFH_VDMES5 := SN3->N3_VRDMES5
							DFH->DFH_VDACU5 := SN3->N3_VRDACM5
							DFH->DFH_FIMDEP := SN3->N3_FIMDEPR
							DFH->DFH_STATUS := '1' //-- Em Aberto

							MsUnLock()
							SN3->(DbSkip())
						End
					EndIf
				End Transaction	
			EndIf
		EndIf
	EndIf
	(cAliasQry)->(DbSkip())	
End

If lEnd
	Aviso(	STR0011,;		//-- "Atencao"
			STR0012,;		//-- "Importacao cancelada pelo operador!"
			{STR0013},2 )	//-- "Ok"
EndIf

(cAliasQry)->(dbCloseArea())

RestArea(aArea)
RestArea(aAreaSN1)
RestArea(aAreaDFG)

Return
