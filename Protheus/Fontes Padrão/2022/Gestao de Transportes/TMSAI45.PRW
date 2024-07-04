#include "PROTHEUS.ch"
#include "TMSAI45.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa   º  TMSAI45   º Autor º Richard Anderson   º Data º 22/11/06 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍ¹±±
±±º             	Geracao MIC/DTA                             		         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe    º  TMSAI45()                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros º                                         			         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno    º NIL                                                       º±±
±±ºÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso        º SIGATMS - Gestao de Transportes                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Comentario º                                                           º±±
±±º            º                                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          Atualizacoes efetuadas desde a codificacao inicial            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador º  Data  º BOPS º             Motivo da Alteracao           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º            ºxx/xx/02ºxxxxxxº                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAI45()

Private cCadastro	:= STR0001 //-- MIC/DTA           
Private aImpRotina:= {{ STR0001  , "TMAI45Imp"   , 0, 6 },;  //"MIC/DTA"
 				          { STR0062  , "TMAI45I1"  , 0, 6 },;  //"Gráfico En Lastre - Formulario Pre-Impresso" 
  				          { STR0063  , "TMAI45I2"  , 0, 6 },;  //"Gráfico Normal - Formulario Pre-Impresso"
  				          { STR0064  , "TMAI45I3"  , 0, 6 }}   //"Gráfico Normal - Formulario Branco"

Private aRotina	:= {{ STR0002  , "AxPesqui"  , 0, 1 },; //"Pesquisar"
				          { STR0003  , "TMAI45Alt" , 0, 2 },; //"Visualizar"
 				          { STR0004  , "TMAI45Ger" , 0, 3 },; //"Gerar"  
 				          { STR0009  , "TMAI45Alt" , 0, 4 },; //"Alterar"
				          { STR0005  , "TMAI45Mnt" , 0, 5 },; //"Excluir"
        		          { STR0007  , aImpRotina  , 0, 6 },; //"Imprimir"
				          { STR0061  , "TMAI45Rge" , 0, 7 }}  //"Regerar"
 				          
If ExistBlock('TMI45ROT')
	ExecBlock('TMI45ROT',.F.,.F.)
EndIf	

dbSelectArea("DID")
dbSetOrder(1)
dbGoTop()

mBrowse(06,01,22,75,"DID")

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI45Mnt ³ Autor ³ Richard Anderson     ³ Data ³19.03.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Interface da Rotina de geracao de MIC/DTA                   ³±±
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
Function TMAI45Mnt(cAlias, nReg, nOpcx)

Local aAreaAtu := GetArea()
Local nTLinhas := 0
Local lChk		:= .T.

//-- EnchoiceBar
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

//-- Objeto LISTBOX
Private oLbx1
Private cLbx1

If !TMSChkViag( DID->DID_FILORI, DID->DID_VIAGEM, .F., .F., .F., , .F., .F., , , , , , .T. )
	lChk := .F.
EndIf

If lChk
	//-- Configura variaveis da Enchoice
	RegToMemory( cAlias, INCLUI )
	
	//-- Determina campos que não aparecem na GETDADOS
	Aadd(aNoFields,'DII_FILMIC')
	Aadd(aNoFields,'DII_NUMMIC')
	Aadd(aNoFields,'DII_CODVEI')
	
	//-- Configura variaveis da GetDados
	TMSFillGetDados( nOpcx, 'DII', 1, xFilial( 'DII' ) + M->DID_FILMIC+M->DID_NUMMIC+M->DID_CODVEI, { ||  DII->(DII_FILIAL+DII_FILMIC+DII_NUMMIC+DII_CODVEI) },;
	{ || .T. }, aNoFields,	aYesFields )
	nTLinhas := Len(aCols)
	
	//-- Dimensoes padroes
	aSize := MsAdvSize()
	AAdd( aObjects, { 100, 040, .T., .T. } )
	AAdd( aObjects, { 100, 060, .T., .T. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aTmsPosObj := MsObjSize( aInfo, aObjects,.T.)
	
	DEFINE MSDIALOG oTmsDlgEsp TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
	//-- Monta a enchoice.
	oTmsEnch	:= MsMGet():New( cAlias, nReg, nOpcx,,,,, aTmsPosObj[1],, 3,,,,,,.T. )
	//        MsGetDados(                      nT ,                  nL,                 nB,                  nR,    nOpc,     cLinhaOk,      cTudoOk,cIniCpos,lDeleta,aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)
	oTmsGetD := MSGetDados():New(aTmsPosObj[ 2, 1 ], aTmsPosObj[ 2, 2 ],aTmsPosObj[ 2, 3 ], aTmsPosObj[ 2, 4 ], nOpcx,,,,.T.,nil,nil,nil,nNumLinhas)
	ACTIVATE MSDIALOG oTmsDlgEsp ON INIT EnchoiceBar( oTmsDlgEsp,{|| nOpcA := 1, oTmsDlgEsp:End() },{|| nOpcA := 0, oTmsDlgEsp:End() })
	
	If nOpcB == 5 .And. nOpcA == 1
		TMAI45Exc()
	EndIf
EndIf

RestArea(aAreaATU)

Return nOpcA

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI45Ger³ Autor ³ Richard Anderson      ³ Data ³22/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Geracao do MIC/DTA                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMAI45Ger(cAlias, nReg, nOpcx)

Local cPerg := 'TMAI45'

If Pergunte(cPerg,.T.)
	If Empty(mv_par05) .OR. Empty(mv_par06)
		MsgAlert(STR0053	) //"Não existem aduanas de Origem ou Destino para efetuar a geração do MIC/DTA"
	Else
		Processa({|| TMAI45Prc(,,,nOpcx)},STR0010)  //'Gerando MIC/DTA...'
		//-- Nao chama novamente a tela, qd for inclusao
		MBRCHGLoop()
	EndIf
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI45Prc³ Autor ³ Richard Anderson      ³ Data ³22/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processamento da geracao do MIC/DTA                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMAI45Prc(cNumMic,lConfirma, aDocMIC, nOpcx)

Local   nI        := 0
Local   aAreaAtu  := GetArea()     
Local   aAreaDTQ  := DTQ->(GetArea())
Local   aAreaDTR  := DTR->(GetArea())
Local   cAliasQry := GetNextAlias()
Local   cQuery    := ''
Local	  nQtdDoc   := 0
Local	  nQtdVol   := 0
Local	  nPeso     := 0
Local	  nPesoM3   := 0
Local	  nValMer   := 0
Local 	 cCdrDes	 := ""
Local 	 cCdrCal	 := ""
Local   oDlgEsp   := {}
Local   cHDlgEsp  := cCadastro
Local   aHDocMIC  := {}
Local   aButtons  := {}
Local   nOpcA     := 0
Local   oNoMarked := LoadBitmap( GetResources(),'LBNO' )
Local   oMarked	:= LoadBitmap( GetResources(),'LBOK' )
Local   cFilOri   := mv_par01
Local   cViagem   := mv_par02
Local   cSeekDTR  := ''
//-- Controle de dimensoes de objetos
Local   aSize	   := {}
Local   aObjects  := {}
Local   aInfo	   := {}
Local   aPosObjH  := {}
//-- Checkbox
Local   oAllMark
Local   lAllMark
Local   oPanel
//-- Doctos do MIC
Local   aDocGrv   := {}         

Default cNumMic   := ''
Default lConfirma := .T. 
Default aDocMIC   := {}

If Len(aDocMIC) == 0
	DTQ->(dbSetOrder(2))
  	If DTQ->(dbSeek(xFilial('DTQ')+cFilOri+cViagem)) .And. DTQ->DTQ_TIPVIA $ '2;4' //-- Vazia ou Socorro
		//-- Gera MIC/DTA de viagens vazias para somente cruzar a fronteira
		DTR->(dbSetOrder(1))
		DTR->(dbSeek(cSeekDTR := xFilial('DTR')+cFilOri+cViagem))
		While DTR->(!Eof()) .And. DTR->(DTR_FILIAL+DTR_FILORI+DTR_VIAGEM) == cSeekDTR
			Aadd(aDocMIC,{ !lConfirma,;
			DTR->DTR_CODVEI,;
			Posicione('DA3',1,xFilial('DA3')+DTR->DTR_CODVEI,'DA3_DESC'),;
			Space(Len(DT6->DT6_FILDOC)),;
			Space(Len(DT6->DT6_DOC))   ,;
			Space(Len(DT6->DT6_SERIE)) ,;
			0,;
			0,;
			0,;
			0,;
			Space(Len(SA1->A1_NOME)),;
			0,;
			Space(Len(DT6->DT6_CDRDES)),;
			Space(Len(DT6->DT6_CDRCAL))})
			DTR->(dbSkip())
		EndDo
	Else
		cQuery := "SELECT DT6_FILDOC, DT6_DOC, DT6_SERIE, DT6_QTDVOL, DT6_PESO, DT6_PESOM3, DT6_VALMER, DTA_CODVEI, DT6_MOEDA, DT6_CLIREM, DT6_LOJREM, DT6_CDRDES,DT6_CDRCAL,DTA.R_E_C_N_O_ RECNODTA FROM "
		cQuery += RetSqlName("DTA")+" DTA, "
		cQuery += RetSqlName("DT6")+" DT6  "
		cQuery += " WHERE DTA.DTA_FILIAL = '"+xFilial("DTA",mv_par01)+"'"
		cQuery += "   AND DTA.DTA_FILORI = '"+cFilOri+"'"
		cQuery += "   AND DTA.DTA_VIAGEM = '"+cViagem+"'"
		cQuery += "   AND DTA.DTA_SERTMS IN ('2','3')" //-- Transporte, Entrega
		cQuery += "   AND DTA.DTA_TIPTRA = '4'" //-- Internacional
		cQuery += "   AND DTA.DTA_CODVEI BETWEEN '"+mv_par03+"' AND '"+mv_par04+"'"
		cQuery += "   AND DTA.D_E_L_E_T_ = ' '"
		cQuery += "   AND NOT EXISTS (SELECT 1 FROM "+RetSqlName("DII")+" DII "
		cQuery += "                    WHERE DII.DII_FILIAL = '"+xFilial("DII")+"'"
		cQuery += "                      AND DII.DII_FILDOC = DTA.DTA_FILDOC "
		cQuery += "                      AND DII.DII_DOC    = DTA.DTA_DOC    "
		cQuery += "                      AND DII.DII_SERIE  = DTA.DTA_SERIE  "
		cQuery += "                      AND DII.DII_RECDTA = DTA.R_E_C_N_O_ "
		cQuery += "                      AND DII.D_E_L_E_T_ = ' ' )"
		cQuery += "   AND DT6.DT6_FILIAL = '"+xFilial("DT6")+"'"
		cQuery += "   AND DT6.DT6_FILDOC = DTA_FILDOC"
		cQuery += "   AND DT6.DT6_DOC    = DTA_DOC"
		cQuery += "   AND DT6.DT6_SERIE  = DTA_SERIE"
		cQuery += "   AND DT6.DT6_TIPTRA = '4'" //-- Internacional
		cQuery += "   AND DT6.D_E_L_E_T_ = ' '"
		cQuery += " ORDER BY DTA_CODVEI,DT6_MOEDA,DTA_FILDOC,DTA_DOC,DTA_SERIE"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
		TcSetField(cAliasQry,"DT6_QTDVOL","N",TamSX3("DT6_QTDVOL")[1],TamSX3("DT6_QTDVOL")[2])
		TcSetField(cAliasQry,"DT6_PESO"  ,"N",TamSX3("DT6_PESO"  )[1],TamSX3("DT6_PESO"  )[2])
		TcSetField(cAliasQry,"DT6_PESOM3","N",TamSX3("DT6_PESOM3")[1],TamSX3("DT6_PESOM3")[2])
		TcSetField(cAliasQry,"DT6_VALMER","N",TamSX3("DT6_VALMER")[1],TamSX3("DT6_VALMER")[2])
		TcSetField(cAliasQry,"DT6_MOEDA" ,"N",TamSX3("DT6_MOEDA" )[1],TamSX3("DT6_MOEDA" )[2])
		If (cAliasQry)->(Eof())
			MsgAlert(STR0011) //"Não existem documentos da viagem para efetuar a geração do MIC/DTA"
		Else
			While (cAliasQry)->(!Eof())
				cCodVei := (cAliasQry)->DTA_CODVEI
				While (cAliasQry)->(!Eof()) .And. (cAliasQry)->DTA_CODVEI == cCodVei
					Aadd(aDocMIC,{ !lConfirma,;
					(cAliasQry)->DTA_CODVEI,;
					Posicione('DA3',1,xFilial('DA3')+(cAliasQry)->DTA_CODVEI,'DA3_DESC'),;
					(cAliasQry)->DT6_FILDOC,;
					(cAliasQry)->DT6_DOC   ,;
					(cAliasQry)->DT6_SERIE ,;
					(cAliasQry)->DT6_QTDVOL,;
					(cAliasQry)->DT6_PESO  ,;
					(cAliasQry)->DT6_PESOM3,;
					xMoeda((cAliasQry)->DT6_VALMER, (cAliasQry)->DT6_MOEDA, mv_par07),;
					Posicione('SA1',1,xFilial('SA1')+(cAliasQry)->(DT6_CLIREM+DT6_LOJREM),'A1_NOME'),;
					(cAliasQry)->RECNODTA ,;
					(cAliasQry)->DT6_CDRDES,;
					(cAliasQry)->DT6_CDRCAL})
					(cAliasQry)->(dbSkip())
				EndDo
			EndDo
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf	
EndIf

If Len(aDocMIC) > 0
	RestArea(aAreaAtu)
	//-- Dados do Cabecalho
	Aadd(aHDocMIC, RetTitle('DA3_COD')    )
	Aadd(aHDocMIC, RetTitle('DA3_DESC')   )
	Aadd(aHDocMIC, RetTitle('DT6_FILDOC') )
	Aadd(aHDocMIC, RetTitle('DT6_DOC')    )
	Aadd(aHDocMIC, RetTitle('DT6_SERIE')  )
	Aadd(aHDocMIC, RetTitle('DT6_QTDVOL') )
	Aadd(aHDocMIC, RetTitle('DT6_PESO')   )
	Aadd(aHDocMIC, RetTitle('DT6_PESOM3') )
	Aadd(aHDocMIC, RetTitle('DT6_VALMER') )
	Aadd(aHDocMIC, RetTitle('DT6_NOMREM') )
	//-- Calcula as dimensoes dos objetos
	
	aSize    := MsAdvSize(.T.)
	AAdd(aObjects,{100,090,.T.,.T.,.T.})
	AAdd(aObjects,{100,010,.T.,.T.,.T.})

	aInfo	   := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObjH	:= MsObjSize(aInfo,aObjects,.T.,.F.)
		
	If lConfirma
		DEFINE MSDIALOG oDlgEsp FROM aSize[7],00 TO aSize[6],aSize[5] TITLE cHDlgEsp	OF oMainWnd PIXEL
	
			//-- Apresenta os documentos
			@ aPosObjH[1,1], aPosObjH[1,2] LISTBOX oLbx1 VAR cLbx1 FIELDS HEADER '',aHDocMIC[1],aHDocMIC[2],aHDocMIC[3],aHDocMIC[4],aHDocMIC[5],;
			aHDocMIC[6],aHDocMIC[7],aHDocMIC[8],aHDocMIC[9],aHDocMIC[10]  SIZE aPosObjH[1,3], aPosObjH[1,4] OF oDlgEsp ON DBLCLICK TmAI45Mrk(aDocMIC) PIXEL
			
			oLbx1:SetArray( aDocMIC )
			
			//-- Monta o bLine do listbox
			oLbx1:bLine	:= { || { Iif(aDocMIC[oLbx1:nAT,1] , oMarked, oNoMarked ), ;
	         		             aDocMIC[oLbx1:nAT,2],;
									 	 aDocMIC[oLbx1:nAT,3],;
									 	 aDocMIC[oLbx1:nAT,4],;
									    aDocMIC[oLbx1:nAT,5],;
									    aDocMIC[oLbx1:nAT,6],;
									    Transform(aDocMIC[oLbx1:nAT,7] ,PesqPict('DT6','DT6_QTDVOL')),;
									    Transform(aDocMIC[oLbx1:nAT,8] ,PesqPict('DT6','DT6_PESO'  )),;
									    Transform(aDocMIC[oLbx1:nAT,9] ,PesqPict('DT6','DT6_PESOM3')),;
									    Transform(aDocMIC[oLbx1:nAT,10],PesqPict('DT6','DT6_VALMER')),;
									    aDocMIC[oLbx1:nAT,11] } }
									 
			oPanel := TPanel():New(aPosObjH[2,1],aPosObjH[2,2],"",oDlgEsp,,,,,CLR_WHITE,(aPosObjH[2,3]), (aPosObjH[2,4]), .T.)
	
			@ 005,005 CHECKBOX oAllMark VAR lAllMark PROMPT STR0008 SIZE 68, 08; //"Marca/Desmarca todos"
			ON CLICK(TmAI45All(lAllMark,aDocMIC)) OF oPanel PIXEL
		
		ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{||(nOpca := 1,oDlgEsp:End())},{||(nOpcA := 0,oDlgEsp:End())},, aButtons )
	Else
		nOpcA := 1
	EndIf
		
	If nOpcA == 1
		cCodVei := ''
		For nI := 1 To Len(aDocMIC)
			If !aDocMIC[nI,1]
				Loop
			EndIf					
			If aDocMIC[nI,2] != cCodVei   
				If !Empty(cCodVei)     
					If nOpcx <> 7 //Regerar, mantem a numeracao 
						cNumMIC := TMAI45Mic(cFilOri,cViagem,cCodVei,cCdrDes,cCdrCal)
					EndIf	
					TmAI45Grv(cNumMIC,cCodVei,nQtdDoc,nQtdVol,nPeso,nPesoM3,nValMer,aDocGrv,cFilOri,cViagem)
				EndIf
				cCodVei := aDocMIC[nI,2]
				nQtdDoc := 0
				nQtdVol := 0
				nPeso   := 0
				nPesoM3 := 0
				nValMer := 0
				aDocGrv := {}
			EndIf					
			nQtdDoc += 1
			nQtdVol += aDocMIC[nI,07]
			nPeso   += aDocMIC[nI,08]
			nPesoM3 += aDocMIC[nI,09]
			nValMer += aDocMIC[nI,10]
			cCdrDes := aDocMIC[nI,13]
			cCdrCal := aDocMIC[nI,14]
			
			Aadd(aDocGrv,{ aDocMIC[nI,4],aDocMIC[nI,5],aDocMIC[nI,6],aDocMIC[nI,7],aDocMIC[nI,12] })
		Next nI
		If nQtdDoc > 0
			If nOpcx <> 7 //Regerar, mantem a numeracao
				cNumMIC := TMAI45Mic(cFilOri,cViagem,cCodVei,cCdrDes,cCdrCal)
			EndIf	
			TmAI45Grv(cNumMIC,cCodVei,nQtdDoc,nQtdVol,nPeso,nPesoM3,nValMer,aDocGrv,cFilOri,cViagem)
		EndIf
	EndIf			
EndIf
RestArea(aAreaDTR)
RestArea(aAreaDTQ)
RestArea(aAreaAtu)
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI45Grv³ Autor ³ Richard Anderson      ³ Data ³18/08/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravacao do MIC/DTA                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMAI45Grv(cNumMIC,cCodVei,nQtdDoc,nQtdVol,nPeso,nPesoM3,nValMer,aDocGrv,cFilOri,cViagem)

Local   nCnt      := 0
Local   cItem     := ''
Local   cQuery    := ''
Local   cAliasQry := GetNextAlias()
Local   nFolha 	:= 0
Local   nVolta 	:= 0
Local   nVolOri	:= 0
Local   aDadMic	:= {}
Local   cSaldo    := ''
Local   nI        := 0 
Local   cSeekDT6  := ''
Local   aDoctosCar:= {}
Local   cFilDoc   := ''
Local   cDoc		:= ''
Local   cSerie    := ''
Local   cEmb		:= ''
Local   aAreaAtu  := GetArea()
Local   aDadCRT	:= {}
Local   cDados    := ''
Local   nX        := 0                                                             
Local   lCargPar  := .F.

Private aMicCamp 	:= {}
Default nQtdDoc   := 0
Default nQtdVol   := 0
Default nPeso     := 0
Default nPesoM3   := 0
Default nValMer   := 0
Default aDocGrv   := {}

//-- Obtem o último item gerado para o MIC do veículo
cQuery := "SELECT MAX(DII_ITEMIC) DII_ITEMIC FROM "
cQuery += RetSqlName('DII')
cQuery += " WHERE DII_FILIAL = '"+xFilial('DII')+"'"
cQuery += "   AND DII_FILMIC = '"+cFilAnt+"'"
cQuery += "   AND DII_NUMMIC = '"+cNumMIC+"'"
cQuery += "   AND DII_CODVEI = '"+cCodVei+"'"
cQuery += "   AND D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
If (cAliasQry)->(Eof())
	cItem := StrZero(1,Len(DII->DII_ITEMIC))
Else
	cItem := Soma1((cAliasQry)->DII_ITEMIC)
EndIf
(cAliasQry)->(dbCloseArea())
RestArea(aAreaAtu)
//-- Grava o MIC
Begin Transaction
	DID->(dbSetOrder(1))
	If DID->(!dbSeek(xFilial('DID')+cFilAnt+cNumMIC+cCodVei))
		RecLock("DID",.T.)
		DID->DID_FILIAL := xFilial("DID")
		DID->DID_FILMIC := cFilAnt
		DID->DID_NUMMIC := cNumMIC
		DID->DID_CODVEI := cCodVei
		DID->DID_FILORI := cFilOri
		DID->DID_VIAGEM := cViagem
		DID->DID_DATMIC := CriaVar("DID_DATMIC")
		DID->DID_HORMIC := CriaVar("DID_HORMIC")
		DID->DID_MOEDA  := mv_par07
		DID->DID_CODPCI := Alltrim(mv_par08)
		DID->DID_TRANAD := Str(mv_par09,Len(DID->DID_TRANAD))
	Else
		RecLock("DID",.F.)
	EndIf		
	DID->DID_QTDDOC += nQtdDoc
	DID->DID_QTDVOL += nQtdVol
	DID->DID_PESO   += nPeso
	DID->DID_PESOM3 += nPesoM3
	DID->DID_VALMER += nValMer      
	DID->DID_QTDFOL := StrZero(Int(DID->DID_QTDDOC / 2) + 1,Len(DID->DID_QTDFOL))
	MsUnLock()            
	nFolha := 0
	nVolta := 0
	For nCnt := 1 To Len(aDocGrv)
		//-- Atualiza DII (Itens MIC/DTA)
		RecLock("DII",.T.)
		DII->DII_FILIAL := xFilial('DII')
		DII->DII_FILMIC := cFilAnt
		DII->DII_NUMMIC := cNumMic
		DII->DII_CODVEI := cCodVei
		DII->DII_ITEMIC := cItem
		DII->DII_CDAORI := mv_par05
		DII->DII_CDADES := mv_par06
		DII->DII_FILDOC := aDocGrv[nCnt,1]
		DII->DII_DOC    := aDocGrv[nCnt,2]
		DII->DII_SERIE  := aDocGrv[nCnt,3]
		DII->DII_QTDVOL := aDocGrv[nCnt,4]
		DII->DII_RECDTA := aDocGrv[nCnt,5]        
		If Val(cItem) == 1
			nVolta := 1        			
			nFolha := 1
		ElseIf nVolta == 1
			nVolta++
			nFolha++
		ElseIf nVolta == 2
			nVolta := 1
		EndIf
		DII->DII_NUMFOL :=  StrZero(nFolha,Len(DII->DII_NUMFOL))
		MsUnLock()
		cItem := Soma1(cItem)                                         
		DII->(DbCommit())  //BIN Antigo da Expresso Aracatuba
	
		RegToMemory("DIJ",.T.)
		M->DIJ_FILMIC := DII->DII_FILMIC
		M->DIJ_NUMMIC := DII->DII_NUMMIC
		M->DIJ_CODVEI := DII->DII_CODVEI
		M->DIJ_ITEMIC := DII->DII_ITEMIC

		//--Dados do Remetente
		aDadCRT := TmsDadCRT('01',DII->DII_FILDOC,DII->DII_DOC,DII->DII_SERIE)
		aDadMIC := TmsDadMIC('33','',DII->DII_FILMIC,DII->DII_NUMMIC,DII->DII_CODVEI,DII->DII_ITEMIC)

		For nI := 1 To Len(aDadCRT)
			cDados  := ''
			For nX  := 1 To Len(aDadCRT)
				cDados += aDadCRT[nX]+Chr(13)+Chr(10)
			Next nX
			
			M->DIJ_DADREM := cDados
			Aadd(aMicCamp,{"DIJ_DADREM","33",.T.,M->DIJ_DADREM})
         Exit
		Next nI

		//--Dados do Destinatario
		aDadCRT := TmsDadCRT('04',DII->DII_FILDOC,DII->DII_DOC,DII->DII_SERIE)
		aDadMIC := TmsDadMIC('34','',DII->DII_FILMIC,DII->DII_NUMMIC,DII->DII_CODVEI,DII->DII_ITEMIC)

		For nI := 1 To Len(aDadCRT)
			cDados  := ''
			For nX  := 1 To Len(aDadCRT)
				cDados += aDadCRT[nX]+Chr(13)+Chr(10)
			Next nX

			M->DIJ_DADDES := cDados
			Aadd(aMicCamp,{"DIJ_DADDES","34",.T.,M->DIJ_DADDES})							
         Exit
		Next nI
      
		//--Cidade do Destinatario
		aDadCRT := TmsDadCRT('08',DII->DII_FILDOC,DII->DII_DOC,DII->DII_SERIE)
		aDadMIC := TmsDadMIC('08','',DII->DII_FILMIC,DII->DII_NUMMIC,DII->DII_CODVEI,DII->DII_ITEMIC)

		For nI := 1 To Len(aDadCRT)
			cDados  := ''
			For nX  := 1 To Len(aDadCRT)
				cDados += aDadCRT[nX]+Chr(13)+Chr(10)
			Next nX
			If Empty(aDadCRT[1]) .Or. AllTrim(aDadCRT[1]) = "-" // Incluido para os casos de viagem vazia internacional pega o destino da rota na região de fronteira
				aDadCRT := TMAI45Des(DTQ->DTQ_ROTA)
				cDados  := ''
				For nX  := 1 To Len(aDadCRT)
					cDados += aDadCRT[nX]+Chr(13)+Chr(10)
				Next nX
			EndIf
			M->DIJ_DADCDF := cDados
			Aadd(aMicCamp,{"DIJ_DADCDF","08",.T.,M->DIJ_DADCDF})							
         Exit
		Next nI

		//--Dados do Consignatario
		aDadCRT := TmsDadCRT('06',DII->DII_FILDOC,DII->DII_DOC,DII->DII_SERIE)
		aDadMIC := TmsDadMIC('35','',DII->DII_FILMIC,DII->DII_NUMMIC,DII->DII_CODVEI,DII->DII_ITEMIC)

		For nI := 1 To Len(aDadCRT)
			cDados  := ''
			For nX  := 1 To Len(aDadCRT)
				cDados += aDadCRT[nX]+Chr(13)+Chr(10)
			Next nX

			M->DIJ_DADCON := cDados
			Aadd(aMicCamp,{"DIJ_DADCON","35",.T.,M->DIJ_DADCON})
         Exit
		Next nI

		//--Documentos Anexos
		aDadCRT := TmsDadCRT('17',DII->DII_FILDOC,DII->DII_DOC,DII->DII_SERIE)
		aDadMIC := TmsDadMIC('36','',DII->DII_FILMIC,DII->DII_NUMMIC,DII->DII_CODVEI,DII->DII_ITEMIC)

		For nI := 1 To Len(aDadCRT)
			cDados  := ''
			For nX  := 1 To Len(aDadCRT)
				cDados += aDadCRT[nX]+Chr(13)+Chr(10)
			Next nX

			M->DIJ_DOCANE := cDados
			Aadd(aMicCamp,{"DIJ_DOCANE","36",.T.,M->DIJ_DOCANE})
         Exit
		Next nI
						
		//-- Pesquisa o Carregamento parcial para controlar o Saldo Embarcado		
		nVolOri := Posicione('DT6',1,xFilial('DT6')+DII->(DII_FILDOC+DII_DOC+DII_SERIE),'DT6_VOLORI')
		If (nVolOri == DII->DII_QTDVOL)
			//--Descricao das Mercadorias
			aDadCRT := TmsDadCRT('11',DII->DII_FILDOC,DII->DII_DOC,DII->DII_SERIE)
			aDadMIC := TmsDadMIC('38','',DII->DII_FILMIC,DII->DII_NUMMIC,DII->DII_CODVEI,DII->DII_ITEMIC)
	
			For nI := 1 To Len(aDadCRT)
				cDados  := ''
				For nX  := 1 To Len(aDadCRT)
					cDados += aDadCRT[nX]+Chr(13)+Chr(10)
				Next nX

				M->DIJ_DADMER := cDados
				Aadd(aMicCamp,{"DIJ_DADMER","38",.T.,M->DIJ_DADMER})						
	         Exit
			Next nI			
		Else
			//-- Carregamento parcial para controlar o Saldo Embarcado
			If DT6->DT6_DOCTMS == 'J' 
				Aadd(aDoctosCar,{ DII->DII_FILDOC, DII->DII_DOC, DII->DII_SERIE })
			   cFilDoc  := DII->DII_FILDOC
			   cDoc		:= DII->DII_DOC
			   cSerie   := DII->DII_SERIE

				DT6->(dbSetOrder(8))
				DT6->(dbSeek(cSeekDT6 := xFilial('DT6')+DII->(DII_FILDOC+DII_DOC+DII_SERIE)))
				While DT6->(!Eof()) .And. DT6->(DT6_FILIAL+DT6_FILDCO+DT6_DOCDCO+DT6_SERDCO) == cSeekDT6
					If DT6->DT6_DOCTMS == 'K' //-- Docto. de carregamento em partes
						Aadd(aDoctosCar,{ DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE })
						lCargPar := .T.						
					EndIf
					DT6->(dbSkip())
				EndDo
			ElseIf DT6->DT6_DOCTMS == 'K'
				DT6->(dbSetOrder(1))
				DT6->(dbSeek(cSeekDT6 := xFilial('DT6')+DT6->(DT6_FILDCO+DT6_DOCDCO+DT6_SERDCO)))
				Aadd(aDoctosCar,{ DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE })               
			   cFilDoc  := DT6->DT6_FILDOC
			   cDoc		:= DT6->DT6_DOC
			   cSerie   := DT6->DT6_SERIE

				DT6->(dbSetOrder(8))
				DT6->(dbSeek(cSeekDT6 := xFilial('DT6')+DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE)))
				While DT6->(!Eof()) .And. DT6->(DT6_FILIAL+DT6_FILDCO+DT6_DOCDCO+DT6_SERDCO) == cSeekDT6
					If DT6->DT6_DOCTMS == 'K' //-- Docto. de carregamento em partes
						Aadd(aDoctosCar,{ DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE })
						lCargPar := .T.
					EndIf
					DT6->(dbSkip())
				EndDo
			EndIf    
			If lCargPar
				cFilDCO := ''
				cDocDCO := ''
				cSerDCO := ''
				For nI := 1 To Len(aDoctosCar)
					cFilDCO += "'"+aDoctosCar[nI,1]+"'"+Iif(nI==Len(aDoctosCar),"",",")
					cDocDCO += "'"+aDoctosCar[nI,2]+"'"+Iif(nI==Len(aDoctosCar),"",",")
					cSerDCO += "'"+aDoctosCar[nI,3]+"'"+Iif(nI==Len(aDoctosCar),"",",")
				Next				

				cQuery := "SELECT SUM(DII_QTDVOL) SALDEMB FROM "
				cQuery += RetSqlName('DII')
				cQuery += " WHERE DII_FILIAL = '"+xFilial('DII')+"'"
				cQuery += "   AND DII_FILDOC In ("+cFilDCO+")"
				cQuery += "   AND DII_DOC    In ("+cDocDCO+")"
				cQuery += "   AND DII_SERIE  In ("+cSerDCO+")"
				cQuery += "   AND D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
				nSaldEmb  := 0
				If !(cAliasQry)->(EOF())
					nSaldEmb += (cAliasQry)->SALDEMB
				EndIf
				(cAliasQry)->(dbCloseArea())
				nSaldEmb :=  (nVolOri - nSaldEmb)
				
				//--Tipos de Volume
				aDadMIC := TmsDadMIC('30','',DII->DII_FILMIC,DII->DII_NUMMIC,DII->DII_CODVEI,DII->DII_ITEMIC)
				cEmb    := Alltrim(aDadMIC[1])
				
				//--Descricao das Mercadorias
				aDadMIC := TmsDadCRT('11',cFilDoc,cDoc,cSerie)      
				cSaldo  := ''
				If Len(aDadMic) > 0
					For nI  := 1 To Len(aDadMIC)
						If nI == 1
							cSaldo += RTrim(aDadMIC[nI])+' '+STR0058+Alltrim(Str(DII->DII_QTDVOL))+' '+cEmb+Chr(13)+Chr(10) //'SALDO EMBARCADO: '
						ElseIf nI == 2
							cSaldo += RTrim(aDadMIC[nI])+' '+STR0059+Alltrim(Str(nVolOri))+' '+cEmb+Chr(13)+Chr(10) //'SALDO TOTAL:     '
						ElseIf nI == 3
							cSaldo += Rtrim(aDadMIC[nI])+' '+STR0060+Alltrim(Str(nSaldEmb))+' '+cEmb+Chr(13)+Chr(10) //'SALDO A EMBARCAR:'
						Else
							cSaldo += aDadMIC[nI]+Chr(13)+Chr(10)
						EndIf
					Next nI
				Else						
					cSaldo += STR0058+Alltrim(Str(DII->DII_QTDVOL))+' '+cEmb+Chr(13)+Chr(10) //'SALDO EMBARCADO: '
					cSaldo += STR0059+Alltrim(Str(nVolOri))+Chr(13)+' '+cEmb+Chr(10) //'SALDO TOTAL:     '
					cSaldo += STR0060+Alltrim(Str(nSaldEmb))+Chr(13)+' '+cEmb+Chr(10) //'SALDO A EMBARCAR:'
				EndIf                                               
				//-- Gravar o Saldo Embarcado como Alteracao do MIC.
				M->DIJ_DADMER := cSaldo
				Aadd(aMicCamp,{"DIJ_DADMER","38",.T.,M->DIJ_DADMER})						
			EndIf
		EndIf                                                                   		

		TMAI45Gcp()
				
	Next nCnt						
End Transaction 
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI45Vld³ Autor ³ Richard Anderson      ³ Data ³22/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida antes de editar o campo.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMAI45Vld(nCampo) 

Local lRet     := .T.
Local aAreaSM0 := SM0->(GetArea())
Local aAreaDTQ := DTQ->(GetArea())

//-- Filial de Origem e Viagem
If nCampo == 1 .Or. nCampo == 2
	If !Empty(mv_par01)
		//-- Filial de Origem da Viagem
		lRet := ExistCpo('SM0',cEmpAnt+mv_par01)
		If lRet .And. !Empty(mv_par02)
			DTQ->(dbSetOrder(2))
			If DTQ->(!dbSeek(xFilial('DTQ')+mv_par01+mv_par02))
				Help('',1,'REGNOIS')
				lRet := .F.
			ElseIf DTQ->DTQ_TIPTRA != StrZero(4,Len(DTQ->DTQ_TIPTRA))
				MsgAlert(STR0012) //'Tipo de transporte da viagem inválido'
				lRet := .F.
			EndIf
		EndIf
	EndIf
ElseIf nCampo == 5
	lRet := ExistCpo('DI1',mv_par05,1) 
ElseIf nCampo == 6 
	lRet := ExistCpo('DI1',mv_par06,1) 
EndIf

RestArea(aAreaSM0)
RestArea(aAreaDTQ)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI45Mic³ Autor ³ Richard Anderson      ³ Data ³22/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o numero do MIC/DTA                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial de Origem                                   ³±±
±±³          ³ ExpC2 - Viagem                                             ³±±
±±³          ³ ExpC3 - Código do Veiculo                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAI45                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMAI45Mic(cFilOri,cViagem,cCodVei,cCdrDes,cCdrCal) 
Local cRota    := Posicione('DTQ',2,xFilial('DTQ')+cFilOri+cViagem,'DTQ_ROTA')
Local cSerTms  := Posicione('DTQ',2,xFilial('DTQ')+cFilOri+cViagem,'DTQ_SERTMS')
Local aRegDCA  := TmsRegDCA(cRota)
Local cFilDes  := aRegDCA[Len(aRegDCA),3]
Local cPaisDes := aRegDCA[Len(aRegDCA),5]
Local cNumMIC  := ''
Local cSeqMIC  := ''
Local nTent    := 0
Local lSoma    := .T.
Local lRet    := .T.
Local aAreaDID := DID->(GetArea())
Local aAreaDI0 := DI0->(GetArea())
Local lDI0PAIS := DI0->(FieldPos("DI0_PAIS")) > 0 //TMS11R177 - Permisso

Default cCdrDes := ""
Default cCdrCal := ""

If cSerTms = StrZero(3,Len(DTQ->DTQ_SERTMS)) .And. !Empty(cCdrCal)
	cFilDes  := Posicione('DUY',1,xFilial('DUY')+cCdrCal,'DUY_FILDES')
	cPaisDes := Posicione('DUY',1,xFilial('DUY')+cCdrCal,'DUY_PAIS')
EndIf

//-- Tratamento para nao duplicar numero do MIC/DTA
While !LockByName("AI45NUMMIC",.T.,!Empty(xFilial("DI0"))) .And. nTent <= 50
	nTent++
	Sleep(5000)
EndDo
If nTent >= 50
	UserException(STR0006) //"NAO CONSEGUI LOCKBYNAME AI45NUMMIC"
EndIf 
DID->(dbSetOrder(2))
If DID->(dbSeek(xFilial('DID')+cFilOri+cViagem+cCodVei))
	cNumMIC := DID->DID_NUMMIC
Else	
	DI0->(dbSetOrder(1))
	DID->(dbSetOrder(1))
	If lDI0PAIS
		If DI0->(!MsSeek(xFilial("DI0")+cFilAnt+cFilDes+cPaisDes))
			cFilDes  := Posicione('DUY',1,xFilial('DUY')+cCdrDes,'DUY_FILDES')
			cPaisDes := Posicione('DUY',1,xFilial('DUY')+cCdrDes,'DUY_PAIS')
			If DI0->(!MsSeek(xFilial("DI0")+cFilOri+cFilDes+cPaisDes))
				If DI0->(!MsSeek(xFilial("DI0")+cFilOri+Space(Len(DI0->DI0_FILDES))+cPaisDes)) //Busca sem a Filial de Destino, pois existem permissos desta forma
					lRet := .F.
				EndIf
			EndIf
		EndIf
		If lRet
			cSeqMIC := Right(Alltrim(DI0->DI0_SEQMIC),6)
			cNumMIC := DI0->(DI0_SIGTRA+DI0_NUMPER+cSeqMIC)
			cMay    := AllTrim(xFilial('DID'))+cFilAnt+cNumMIC
			While DID->(dbSeek(xFilial('DID')+cFilAnt+cNumMIC)) .Or. !MayIUseCode(cMay)
				cSeqMIC := Soma1(cSeqMIC)
				cNumMIC := DI0->(DI0_SIGTRA+DI0_NUMPER+cSeqMIC)
				cMay    := AllTrim(xFilial('DID'))+cFilAnt+cNumMIC
				lSoma   := .F.
			EndDo		
			RecLock('DI0',.F.)
			DI0->DI0_SEQMIC := Iif(lSoma,Soma1(cSeqMIC),cSeqMIC)
			MsUnLock()
		EndIf	
	Else
		If DI0->(dbSeek(xFilial('DI0')+cFilAnt+cFilDes)) .Or. DI0->(dbSeek(xFilial('DI0')+cFilAnt+ Space(Len(DI0->DI0_FILDES)) ))
		   cSeqMIC := DI0->DI0_SEQMIC
			cNumMIC := DI0->(DI0_SIGTRA+DI0_NUMPER+cSeqMIC)
			cMay    := AllTrim(xFilial('DID'))+cFilAnt+cNumMIC
			While DID->(dbSeek(xFilial('DID')+cFilAnt+cNumMIC)) .Or. !MayIUseCode(cMay)
				cSeqMIC := Soma1(cSeqMIC)
				cNumMIC := DI0->(DI0_SIGTRA+DI0_NUMPER+cSeqMIC)
				cMay    := AllTrim(xFilial('DID'))+cFilAnt+cNumMIC
				lSoma   := .F.
			EndDo		
			RecLock('DI0',.F.)
			DI0->DI0_SEQMIC := Iif(lSoma,Soma1(cSeqMIC),cSeqMIC)
			MsUnLock()
		EndIf	
	EndIf
EndIf
RestArea(aAreaDID)
RestArea(aAreaDI0)
FreeUsedCode()
UnLockByName("AI45NUMMIC",.T.,!Empty(xFilial("DI0")))
//-- Fim do tratamento para nao duplicar MIC/DTA
If Empty(cNumMIC)
	MsgAlert(STR0013+cFilAnt+STR0014+cFilDes) //'Erro ao gerar número MIC/DTA para origem: '###' e destino: '
EndIf	
Return cNumMIC

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI45Exc³ Autor ³ Richard Anderson      ³ Data ³22/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processamento de Exclusao do MIC/DTA                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMAI45Exc()

Local cFilMIC  := DID->DID_FILMIC
Local cNumMIC  := DID->DID_NUMMIC
Local cCodVei  := DID->DID_CODVEI
Local cSeekDII := ''
Local cSeekDIJ := ''

Begin Transaction

DIJ->(dbSetOrder(1))
DIJ->(dbSeek(cSeekDIJ := xFilial('DIJ')+cFilMIC+cNumMIC+cCodVei))
While DIJ->(!Eof()) .And. DIJ->(DIJ_FILIAL+DIJ_FILMIC+DIJ_NUMMIC+DIJ_CODVEI) == cSeekDIJ
	MSMM(DIJ->DIJ_CODINF,,,,2)
	RecLock('DIJ',.F.)
	dbDelete()
	MsUnLock()
	DIJ->(dbSkip())
EndDo

DII->(dbSetOrder(1))
DII->(dbSeek(cSeekDII := xFilial('DII')+cFilMIC+cNumMIC+cCodVei))
While DII->(!Eof()) .And. DII->(DII_FILIAL+DII_FILMIC+DII_NUMMIC+DII_CODVEI) == cSeekDII
	RecLock('DII',.F.)
	dbDelete()
	MsUnLock()
	DII->(dbSkip())
EndDo

RecLock('DID',.F.)
dbDelete()
MsUnLock()

End Transaction

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI45Mrk³ Autor ³ Richard Anderson      ³ Data ³18.08.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca/Desmarca itens do listbox                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMAI45Mrk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAI45                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMAI45Mrk(aDocMIC)

aDocMIC[ oLbx1:nAT, 1 ] := !aDocMIC[ oLbx1:nAT, 1 ]
oLbx1:Refresh()

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI45All³ Autor ³ Richard Anderson      ³ Data ³18.08.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca/Desmarca todos os itens do LISTBOX                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMAI45All()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAI45                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMAI45All(lAllMark,aDocMIC)

Local nCntFor := 0

For nCntFor := 1 To Len( aDocMIC )
	aDocMIC[ nCntFor, 1 ] := lAllMark
Next
oLbx1:Refresh()

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI45Imp³ Autor ³ Richard Anderson      ³ Data ³22/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Preparacao para chamada da rotina de impressao do MIC/DTA  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAI45                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMAI45Imp() 

Local lExistIXB := ExistBlock("RTMSR18")
Local cPerg     := "RTMR18"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01            	// Fil.Origem De		                 ³
//³ mv_par02            	// Viagem De          	         	  ³
//³ mv_par03            	// Fil.Origem Ate  	      		     ³
//³ mv_par04            	// Viagem Ate         		           ³
//³ mv_par05            	// Veiculo De   	   		           ³
//³ mv_par06            	// Veiculo Ate          	           ³
//³ mv_par07            	// Item MIC/DTA De      	           ³
//³ mv_par08            	// Item MIC/DTA Ate     	           ³
//³ mv_par09            	// Impressao / Reimpressao            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lExistIXB
   	SetMVValue(cPerg,"MV_PAR01",DID->DID_FILORI)
   	SetMVValue(cPerg,"MV_PAR02",DID->DID_VIAGEM)
   	SetMVValue(cPerg,"MV_PAR03",DID->DID_FILORI)
   	SetMVValue(cPerg,"MV_PAR04",DID->DID_VIAGEM)
   	SetMVValue(cPerg,"MV_PAR05",DID->DID_CODVEI)
   	SetMVValue(cPerg,"MV_PAR06",DID->DID_CODVEI)
   	SetMVValue(cPerg,"MV_PAR07",StrZero(1,Len(DIJ->DIJ_ITEMIC)))
	SetMVValue(cPerg,"MV_PAR08",StrZero(DID->DID_QTDDOC,Len(DIJ->DIJ_ITEMIC)))
	SetMVValue(cPerg,"MV_PAR09",1)
	
	ExecBlock("RTMSR18",.F.,.F.)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI45I1 ³ Autor ³ Katia                 ³ Data ³01/03/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Preparacao para chamada da rotina de impressao do MIC/DTA  ³±±
±±³          ³ Grafico En Lastre - Formulario Pre-Impresso                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			 ³Somente imprime o numero do MIC/DTA (sem os dados de viagem ³±±
±±³          ³ e CRT)                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMAI45I1() 
                 
Local aArea  	  := GetArea()

If	ExistBlock("RTMSR18A")
	ExecBlock("RTMSR18A",.F.,.F.)
EndIf
     
RestArea( aArea )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI45I2 ³ Autor ³ Katia                 ³ Data ³01/03/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Preparacao para chamada da rotina de impressao do MIC/DTA  ³±±
±±³          ³ Gráfico Normal - Formulario Pre-Impresso                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Sem Bordas e BOX                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMAI45I2() 
                 
Local aArea  	  := GetArea()

If	ExistBlock("RTMSR18B")
	ExecBlock("RTMSR18B",.F.,.F.)
EndIf
     
RestArea( aArea )

Return                

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI45I3 ³ Autor ³ Katia                 ³ Data ³01/03/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Preparacao para chamada da rotina de impressao do MIC/DTA  ³±±
±±³          ³ Gráfico Normal - Formulario Branco                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Com Bordas e BOX                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMAI45I3() 
                 
Local aArea  	  := GetArea()

If	ExistBlock("RTMSR18G")
	ExecBlock("RTMSR18G",.F.,.F.)
EndIf
     
RestArea( aArea )

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSAI45   ºAutor  ³Telso Carneiro      º Data ³  13/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Alteracao do MIC/DTA                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMAI45Alt(cAlias, nReg, nOpcx)

Local aArea     := GetArea()
Local aCampos   := {}
Local lChk      := .T.
Local aFldDII	:= {}
Local nI		:= 0

Private lVisual := (nOpcx == 2)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva as variaveis utilizadas do MBrowse Anterior.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                               		
SaveInter() 

If !lVisual .And. !TMSChkViag( DID->DID_FILORI, DID->DID_VIAGEM, .F., .F., .F., , .F., .F., , , , , ,.T. )
	lChk := .F.
EndIf

If lChk
	aRotina := {}
	Aadd( aRotina, {STR0015,"TMAI45Cpo",0,2,,,.F.} )  //"His.Alterações"
	Aadd( aRotina, {STR0016,"TMAI45Cpo",0,4,,,.F.} )  //"Confirmar"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Variaveis de Memoria da Enchoice                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aFldDII := ApBuildHeader("DII")

	For nI := 1 To Len(aFldDII)
		If aFldDII[nI][2] $ "DII_ITEMIC,DII_FILDOC,DII_DOC,DII_SERIE,DII_QTDVOL"
			aAdd(aCampos, aFldDII[nI][2])
		EndIf
	Next

	aSize(aFldDII, 0)
	aFldDII := Nil

	DbSelectArea("DII")
	aIndexSub  := {}
	cFiltraSub := "DII_FILIAL=='"+xFilial("DII")+"'.And.DII_FILMIC=='"+DID->DID_FILMIC+"'.And.DII_NUMMIC=='"+DID->DID_NUMMIC+"'"
	bFiltraSub := {|| FilBrowse("DII",@aIndexSub,@cFiltraSub) }
	Eval(bFiltraSub)
	
	MaWndBrowse(0,0,300,600,cCadastro,"DII",aCampos,aRotina,,,,.T.,,,,,)
	
	EndFilBrw("DII",aIndexSub)
EndIf
	
RestInter()
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMAI45Cpo ºAutor  ³Telso Carneiro      º Data ³  13/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Alteracao dos Campos do MIC/DTA                             º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMAI45Cpo(cAlias,nReg, nOpcx)

Local aAreaAtu := GetArea()
Local nI			:= 0
Local cDados   := ''

//-- EnchoiceBar
Local oTmsEnch
Local nOpcB       := aRotina[nOpcx,4]

//-- Dialog
Local oTmsDlg
Local oFont       := TFont():New( "Courier New", 6, 15 )
Local nOpcA			:= 0

//-- Controle de dimensoes de objetos
Local aObjects		:= {}
Local aInfo			:= {}
Local aDadMIC 		:= {}

Local cFilMIC     	:= DII->DII_FILMIC
Local cNumMIC     	:= DII->DII_NUMMIC
Local cCodVei		:= DII->DII_CODVEI
Local cIteMIC		:= DII->DII_ITEMIC
Local cFilDoc  		:= DII->DII_FILDOC
Local cDoc			:= DII->DII_DOC
Local cSerie		:= DII->DII_SERIE
Local aVisual		:= {}
Local ic			:= 0
Local cCpoVis     	:= ''
Local aFldDIJ		:= {}

//-- EnchoiceBar
Private aTela[0][0]
Private aGets[0]     
Private aMicCamp := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva as variaveis utilizadas do MBrowse Anterior.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SaveInter()

If nOpcB == 2
	TmsCAltMIC()
ElseIf nOpcB == 4 .And.  nReg >= 0
	If lVisual
		nOpcB := 2 
	EndIf
	
	aRotina	:= {{ STR0002  , "AxPesqui"  , 0, 1 },; //"Pesquisar"
	{ STR0003  , "AxVisual" , 0, 2 },; //"Visualizar"
	{ STR0004  , "AxInclui" , 0, 3 },; //"Incluir"
	{ STR0005  , "AxAltera" , 0, 4 },; //"Alterar"
	{ STR0006  , "AxDeleta" , 0, 5 }} //"Cancelar
	
	INCLUI := .T.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Variaveis de Memoria da Enchoice                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCpoVis := "DIJ_FILORI,DIJ_DATALT,DIJ_HORALT,DIJ_FILMIC,DIJ_CODVEI,DIJ_ITEMIC,DIJ_FILDOC,DIJ_DOC,DIJ_SERIE,DIJ_SEQUEN,DIJ_NOMUSR,DIJ_CPOMIC,"
	cCpoVis += "DIJ_CODINF,DIJ_INFORM,DIJ_MODVEI,DIJ_USER"
	
	If DII->DII_NUMFOL != StrZero(1,Len(DII->DII_NUMFOL))
	   cCpoVis += ","
		cCpoVis += "DIJ_CPO007,DIJ_DADAFP,"
		cCpoVis += "DIJ_CPO008,DIJ_DADCDF,"
		cCpoVis += "DIJ_CPO009,DIJ_DADPRC,"
		cCpoVis += "DIJ_CPO010,DIJ_DADCTB,"
		cCpoVis += "DIJ_CPO011,DIJ_PLAVEI,"
		cCpoVis += "DIJ_CPO012,DIJ_MARVEI,DIJ_CHASSI,"
		cCpoVis += "DIJ_CPO013,DIJ_CAPACM,"
		cCpoVis += "DIJ_CPO014,DIJ_ANOFAB,"
		cCpoVis += "DIJ_CPO015,DIJ_PLARB1,"
		cCpoVis += "DIJ_CPO016,DIJ_DADPR2,"
		cCpoVis += "DIJ_CPO017,DIJ_DADCT2,"
		cCpoVis += "DIJ_CPO018,DIJ_PLAVE2,"
		cCpoVis += "DIJ_CPO019,DIJ_MARVE2,DIJ_CHASS2,"
		cCpoVis += "DIJ_CPO020,DIJ_CAPAC2,"
		cCpoVis += "DIJ_CPO021,DIJ_ANOFA2,"
		cCpoVis += "DIJ_CPO022,DIJ_PLARB2"
	EndIf

	aFldDIJ := ApBuildHeader("DIJ", Strtokarr2( cCpoVis + "," + "DIJ_CPO041", ","))
	For nI := 1 To Len(aFldDIJ)
		aAdd(aVisual, aFldDIJ[nI][2])
	Next

	aSize(aFldDIJ, 0)
	aFldDIJ := Nil

	RegToMemory("DIJ", INCLUI)
	
	DbSelectArea("DIJ")
	
	//-- Configura variaveis da Enchoice
	M->DIJ_FILMIC := cFilMIC
	M->DIJ_NUMMIC := cNumMIC
	M->DIJ_CODVEI := cCodVei
	M->DIJ_ITEMIC := cIteMIC
	M->DIJ_FILDOC := cFilDoc
	M->DIJ_DOC    := cDoc
	M->DIJ_SERIE  := cSerie
		
	//-- Campo 03: Alfândega
	M->DIJ_TRANAD := DID->DID_TRANAD

	//-- Campo 04: Numero
	M->DIJ_NUMMIC := cNumMIC
	
	//-- Campo 05: Folha
	M->DIJ_FOLHA  := DII->DII_NUMFOL+'/'+DID->DID_QTDFOL

	//-- Campo 06: Data da emissao
	aDadMIC := TmsDadMIC('06','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	M->DIJ_DATMIC  := aDadMIC[1]
	Aadd(aMicCamp,{"DIJ_DATMIC","06",.F.,M->DIJ_DATMIC})
	
	//-- Campo 07: Alfândega
	aDadMIC := TmsDadMIC('07','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	M->DIJ_DADAFP := aDadMIC[1]+' '+aDadMIC[2]
	Aadd(aMicCamp,{"DIJ_DADAFP","07",.F.,M->DIJ_DADAFP})

	//-- Campo 08: Cidade e pais de destino final
	aDadMIC := TmsDadMIC('08','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	cDados  := ''
	For nI  := 1 To Len(aDadMIC)
		cDados += aDadMIC[nI]+Chr(13)+Chr(10)
	Next nI
	M->DIJ_DADCDF := cDados
	Aadd(aMicCamp,{"DIJ_DADCDF","08",.F.,M->DIJ_DADCDF})

	//-- Campo 09: Caminhão Original
	aDadMIC := TmsDadMIC('09','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	cDados  := ''
	For nI  := 1 To Len(aDadMIC)
		cDados += aDadMIC[nI]+Chr(13)+Chr(10)
	Next nI		
	M->DIJ_DADPRC := cDados
	Aadd(aMicCamp,{"DIJ_DADPRC","09",.F.,M->DIJ_DADPRC})		

	//-- Campo 10: Cadastro geral do contribuinte
	aDadMIC := TmsDadMIC('10','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	M->DIJ_DADCTB :=	AllTrim(aDadMIC[1])
	Aadd(aMicCamp,{"DIJ_DADCTB","10",.F.,M->DIJ_DADCTB})

	//-- Campo 11: Placa do caminhão
	aDadMIC := TmsDadMIC('11','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	M->DIJ_PLAVEI := Padr(aDadMIC[1],Len(M->DIJ_PLAVEI))
	Aadd(aMicCamp,{"DIJ_PLAVEI","11",.F.,M->DIJ_PLAVEI})

	//-- Campo 12: Marca e Numero
	aDadMIC := TmsDadMIC('12','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	M->DIJ_MARVEI :=	Padr(aDadMIC[1],Len(M->DIJ_MARVEI))
	M->DIJ_CHASSI :=	Padr(aDadMIC[2],Len(M->DIJ_CHASSI))
	Aadd(aMicCamp,{"DIJ_MARVEI","12",.F.,M->DIJ_MARVEI})
	Aadd(aMicCamp,{"DIJ_CHASSI","12",.F.,M->DIJ_CHASSI})

	//-- Campo 13: Capacidade de tração
	aDadMIC := TmsDadMIC('13','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	M->DIJ_CAPACM := aDadMIC[1]
	Aadd(aMicCamp,{"DIJ_CAPACM","13",.F.,M->DIJ_CAPACM,PesqPict('DA3','DA3_CAPACM')})

	//-- Campo 14: Ano
	aDadMIC := TmsDadMIC('14','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	M->DIJ_ANOFAB := Padr(aDadMIC[1],Len(M->DIJ_ANOFAB))
	Aadd(aMicCamp,{"DIJ_ANOFAB","14",.F.,M->DIJ_ANOFAB})	

	//-- Campo 15: Reboque
	aDadMIC := TmsDadMIC('15','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	M->DIJ_PLARB1 := Padr(aDadMIC[1],Len(M->DIJ_PLARB1))
	Aadd(aMicCamp,{"DIJ_PLARB1","15",.F.,M->DIJ_PLARB1})		

	//-- Campo 16: Caminhão Substituto
	aDadMIC := TmsDadMIC('16','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	cDados  := ''
	For nI  := 1 To Len(aDadMIC)
		cDados += aDadMIC[nI]+Chr(13)+Chr(10)
	Next nI		
	M->DIJ_DADPR2 := cDados
	Aadd(aMicCamp,{"DIJ_DADPR2","16",.F.,M->DIJ_DADPR2})		

	//-- Campo 17: Cadastro geral do contribuinte
	aDadMIC := TmsDadMIC('17','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	M->DIJ_DADCT2 := Padr(aDadMIC[1],Len(M->DIJ_DADCT2))
	Aadd(aMicCamp,{"DIJ_DADCT2","17",.F.,M->DIJ_DADCT2})

	//-- Campo 18: Placa do caminhão
	aDadMIC := TmsDadMIC('18','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	M->DIJ_PLAVE2 := Padr(aDadMIC[1],Len(M->DIJ_PLAVE2))
	Aadd(aMicCamp,{"DIJ_PLAVE2","18",.F.,M->DIJ_PLAVE2})

	//-- Campo 19: Marca e Numero
	aDadMIC := TmsDadMIC('19','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	M->DIJ_MARVE2 :=	Padr(aDadMIC[1],Len(M->DIJ_MARVE2))
	M->DIJ_CHASS2 :=	Padr(aDadMIC[2],Len(M->DIJ_CHASS2))
	Aadd(aMicCamp,{"DIJ_MARVE2","19",.F.,M->DIJ_MARVE2})
	Aadd(aMicCamp,{"DIJ_CHASS2","19",.F.,M->DIJ_CHASS2})

	//-- Campo 20: Capacidade de tração
	aDadMIC := TmsDadMIC('20','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	M->DIJ_CAPAC2 := aDadMIC[1]
	Aadd(aMicCamp,{"DIJ_CAPAC2","20",.F.,M->DIJ_CAPAC2,PesqPict('DA3','DA3_CAPACM')})

	//-- Campo 21: Ano
	aDadMIC := TmsDadMIC('21','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	M->DIJ_ANOFA2 := Padr(aDadMIC[1],Len(M->DIJ_ANOFA2))
	Aadd(aMicCamp,{"DIJ_ANOFAB","21",.F.,M->DIJ_ANOFA2})	

	//-- Campo 22: Reboque
	aDadMIC := TmsDadMIC('22','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	M->DIJ_PLARB2 := Padr(aDadMIC[1],Len(M->DIJ_PLARB2))
	Aadd(aMicCamp,{"DIJ_PLARB2","22",.F.,M->DIJ_PLARB2})		

	//-- Campo 23: Numero do Conhecimento
	DT6->(DbSeek(xFilial('DT6')+cFilDoc+cDoc+cSerie))
	M->DIJ_NUMCTR := DT6->DT6_SIGTRA+"."+Iif(!Empty(DT6->DT6_SERDCO),DT6->DT6_SERDCO,DT6->DT6_SERIE)+"."+cDoc

	//-- Campo 24: Alfandega de destino
	aDadMIC := TmsDadMIC('24','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	M->DIJ_DADAFD := aDadMIC[1]+' '+aDadMIC[2]           
	Aadd(aMicCamp,{"DIJ_DADAFD","24",.F.,M->DIJ_DADAFD})			

	//-- Campo 26: Origem das Mercadorias
	aDadMIC := TmsDadMIC('26','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	M->DIJ_DADORM := aDadMIC[1]             
	Aadd(aMicCamp,{"DIJ_DADORM","26",.F.,M->DIJ_DADORM})				

	//-- Campo 27: Valor FOT
	aDadMIC := TmsDadMIC('27','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	M->DIJ_VALOR := aDadMIC[1]
	Aadd(aMicCamp,{"DIJ_VALOR","27",.F.,M->DIJ_VALOR,PesqPict('DT6','DT6_VALTOT')})					

	//-- Campo 28: Valor Frete
	aDadMIC := TmsDadMIC('28','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	M->DIJ_VALTOT := aDadMIC[1]
	Aadd(aMicCamp,{"DIJ_VALTOT","28",.F.,M->DIJ_VALTOT,PesqPict('DT6','DT6_VALTOT')})

	//-- Campo 29: Seguro
	aDadMIC := TmsDadMIC('29','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	M->DIJ_VALSEG := aDadMIC[1]
	Aadd(aMicCamp,{"DIJ_VALSEG","29",.F.,M->DIJ_VALSEG,PesqPict('DTC','DTC_VALSEG')})						

	//-- Campo 30: Tipo de Volumes
	aDadMIC := TmsDadMIC('30','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	M->DIJ_DADEMB := aDadMIC[1]
	Aadd(aMicCamp,{"DIJ_DADEMB","30",.F.,M->DIJ_DADEMB})
	
	//-- Campo 31: Quantidade de Volumes
	aDadMIC := TmsDadMIC('31','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	M->DIJ_QTDVOL := aDadMIC[1]
	Aadd(aMicCamp,{"DIJ_QTDVOL","31",.F.,M->DIJ_QTDVOL,PesqPict('DT6','DT6_QTDVOL')})
	
	//-- Campo 32: Peso Bruto
	aDadMIC := TmsDadMIC('32','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	M->DIJ_PESO := aDadMIC[1]
	Aadd(aMicCamp,{"DIJ_PESO","32",.F.,M->DIJ_PESO,PesqPict('DT6','DT6_PESO')})
	
	//-- Campo 33: Remetente
	aDadMIC := TmsDadMIC('33','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	cDados  := ''
	For nI  := 1 To Len(aDadMIC)
		cDados += aDadMIC[nI]+Chr(13)+Chr(10)
	Next nI		
	M->DIJ_DADREM := cDados
	Aadd(aMicCamp,{"DIJ_DADREM","33",.F.,M->DIJ_DADREM})
	
	//-- Campo 34: Destinatario
	aDadMIC := TmsDadMIC('34','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	cDados  := ''
	For nI  := 1 To Len(aDadMIC)
		cDados += aDadMIC[nI]+Chr(13)+Chr(10)
	Next nI		
	M->DIJ_DADDES := cDados
	Aadd(aMicCamp,{"DIJ_DADDES","34",.F.,M->DIJ_DADDES})
	
	//-- Campo 35: Consignatario
	aDadMIC := TmsDadMIC('35','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	cDados  := ''
	For nI  := 1 To Len(aDadMIC)
		cDados += aDadMIC[nI]+Chr(13)+Chr(10)
	Next nI
	M->DIJ_DADCON := cDados
	Aadd(aMicCamp,{"DIJ_DADCON","35",.F.,M->DIJ_DADCON})
	
	//-- Campo 36: Documentos Anexos
	aDadMIC := TmsDadMIC('36','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	cDados  := ''
	For nI  := 1 To Len(aDadMIC)
		cDados += aDadMIC[nI]+Chr(13)+Chr(10)
	Next nI
	M->DIJ_DOCANE := cDados
	Aadd(aMicCamp,{"DIJ_DOCANE","36",.F.,M->DIJ_DOCANE})
	
	//-- Campo 37: Numero dos Lacres
	aDadMIC := TmsDadMIC('37','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	cDados  := ''
	For nI  := 1 To Len(aDadMIC)
		cDados += aDadMIC[nI]
	Next nI
	M->DIJ_DADLAC := cDados
	Aadd(aMicCamp,{"DIJ_DADLAC","37",.F.,M->DIJ_DADLAC})
	
	//-- Campo 38: Descricao das Mercadorias
	aDadMIC := TmsDadMIC('38','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	cDados  := ''
	For nI  := 1 To Len(aDadMIC)
		cDados += aDadMIC[nI]+Chr(13)+Chr(10)
	Next nI
	M->DIJ_DADMER := cDados
	Aadd(aMicCamp,{"DIJ_DADMER","38",.F.,M->DIJ_DADMER})
	
	//-- Campo 40: No.DTA,ROTA
	aDadMIC := TmsDadMIC('40','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	cDados  := ''
	For nI  := 1 To Len(aDadMIC)
		cDados += aDadMIC[nI]+Chr(13)+Chr(10)
	Next nI
	M->DIJ_PERCUR := cDados
	Aadd(aMicCamp,{"DIJ_PERCUR","40",.F.,M->DIJ_PERCUR})
	
	//-- Campo 41: Peso Liquido
	aDadMIC := TmsDadMIC('41','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
	M->DIJ_PESLIQ := aDadMIC[1]
	Aadd(aMicCamp,{"DIJ_PESLIQ","41",.F.,M->DIJ_PESLIQ,PesqPict('DT6','DT6_PESLIQ')})
	
	//-- Campo 42: 3° Reboque
	If DIJ->(ColumnPos('DIJ_PLARB3')) > 0
		aDadMIC := TmsDadMIC('42','',cFilMIC,cNumMIC,cCodVei,cIteMIC)
		M->DIJ_PLARB3 := Padr(aDadMIC[1],Len(M->DIJ_PLARB3))
		Aadd(aMicCamp,{"DIJ_PLARB3","42",.F.,M->DIJ_PLARB3})
	EndIf 
	//-- Dimensoes padroes
	aSize := MsAdvSize()
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aTmsPosObj := MsObjSize( aInfo, aObjects,.T.)
	
	DEFINE MSDIALOG oTmsDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
	
	//-- Monta a enchoice.
	oTmsEnch	:= MsMGet():New( "DIJ", nReg, nOpcB,,,,aVisual, aTmsPosObj[1],, 3,,,,,,.T. )
	oTmsEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	
	//-- Muda o fonte dos gets de campo Memo
	For nI := 1 To Len(oTmsEnch:aEntryCtrls)
		If oTmsEnch:aEntryCtrls[nI]:ClassName() == "TMULTIGET"
			oTmsEnch:aEntryCtrls[nI]:oFont := oFont
		EndIf
	Next nI
	
	ACTIVATE MSDIALOG oTmsDlg ON INIT EnchoiceBar( oTmsDlg,{|| Iif(Iif(!lVisual, Obrigatorio(aGets,aTela), .T.),(nOpcA := 1 , oTmsDlg:End()),'') },{|| nOpcA := 0, oTmsDlg:End() })
	             
	If nOpcB != 2
		If nOpcA == 1
			For ic := 1 To Len(aGets)
				TMAI45Mvl(Alltrim(aGets[ic]))
			Next
			TMAI45Gcp() //-- Gravacao da alteracao dos campos
		EndIf
	EndIf
EndIf

RestInter()
RestArea(aAreaATU)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMAI45Ini ºAutor  ³Telso Carneiro      º Data ³  14/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inicializador padrao dos campos virtuais para alteracao    º±±
±±º          ³ do MIC/DTA                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ X3_RELACAO                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMAI45Ini(cCpo)
Local cText

Do Case
	Case cCpo == "DIJ_CPO003"
		cText := STR0017 //"TRANSITO ADUANEIRO"
	Case cCpo == "DIJ_CPO004"                     ´
		cText := STR0018 //"NUM."
	Case cCpo == "DIJ_CPO005"
		cText := STR0019 //"FOLHA"
	Case cCpo == "DIJ_CPO006"
		cText := STR0020 //"DATA DA EMISSAO"
	Case cCpo == "DIJ_CPO007"
		cText := STR0021 //"ALFANDEGA CIDADE E PAIS DE PARTIDA"
	Case cCpo == "DIJ_CPO008"
		cText := STR0022 //"CIDADE DE PAIS DE DESTINO FINAL"
	Case cCpo == "DIJ_CPO009"
		cText := STR0023 //"CAMINHAO ORIGINAL: Nome e endereço do proprietário"
	Case cCpo == "DIJ_CPO010"
		cText := STR0024 //"CADASTRO GERAL DE CONTRIBUINTE"
	Case cCpo == "DIJ_CPO011"
		cText := STR0025 //"PLACA DO CAMINHÃO"
	Case cCpo == "DIJ_CPO012"
		cText := STR0026 //"MARCA E NUMERO"
	Case cCpo == "DIJ_CPO013"
		cText := STR0027 //"CAPACIDADE DE TRAÇÃO"
	Case cCpo == "DIJ_CPO014"
		cText := STR0028 //"ANO"
	Case cCpo == "DIJ_CPO015"
		cText := STR0029 //"Semi-Reboque/Reboque"
	Case cCpo == "DIJ_CPO016"
		cText := STR0030 //"CAMINHAO SUBSTITUTO: Nome e endereço do proprietário"
	Case cCpo == "DIJ_CPO017"
		cText := STR0031 //"CADASTRO GERAL DE CONTRIBUINTE"
	Case cCpo == "DIJ_CPO018"
		cText := STR0032 //"PLACA DO CAMINHÃO"
	Case cCpo == "DIJ_CPO019"
		cText := STR0033 //"MARCA E NUMERO"
	Case cCpo == "DIJ_CPO020"
		cText := STR0034 //"CAPACIDADE DE TRAÇÃO"
	Case cCpo == "DIJ_CPO021"
		cText := STR0035 //"ANO"
	Case cCpo == "DIJ_CPO022"
		cText := STR0036 //"Semi-Reboque/Reboque"
	Case cCpo == "DIJ_CPO023"
		cText := STR0037 //"NUM. DO CONHECIMENTO"
	Case cCpo == "DIJ_CPO024"
		cText := STR0038 //"ALFANDEGA DE DESTINO"
	Case cCpo == "DIJ_CPO026"
		cText := STR0039 //"ORIGEM DAS MERCADORIAS"
	Case cCpo == "DIJ_CPO027"
		cText := STR0040 //"VALOR FOT"
	Case cCpo == "DIJ_CPO028"
		cText := STR0041 //"FRETE EM US$"
	Case cCpo == "DIJ_CPO029"
		cText := STR0042 //"SEGURO EM US$"
	Case cCpo == "DIJ_CPO030"
		cText := STR0043 //"TIPO DOS VOLUMES"
	Case cCpo == "DIJ_CPO031"
		cText := STR0044 //"QUANTIDADE DE VOLUMES"
	Case cCpo == "DIJ_CPO032"
		cText := STR0045 //"PESO BRUTO"
	Case cCpo == "DIJ_CPO033"
		cText := STR0046 //"REMETENTE"
	Case cCpo == "DIJ_CPO034"
		cText := STR0047 //"DESTINATARIO"
	Case cCpo == "DIJ_CPO035"
		cText := STR0048 //"CONSIGNATARIO"
	Case cCpo == "DIJ_CPO036"
		cText := STR0049 //"DOCUMENTOS ANEXOS"
	Case cCpo == "DIJ_CPO037"
		cText := STR0050 //"NUMERO DOS LACRES"
	Case cCpo == "DIJ_CPO038"
		cText := STR0051 //"MARCAS E NUMEROS DOS VOLUMES, DESCRICAO DAS MERCADORIAS"
	Case cCpo == "DIJ_CPO040"
		cText := STR0052 //"No.DTA, ROTA E PRAZO DE TRANSPORTE"
EndCase

Return(cText)
                   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMAI45Gcp ºAutor  ³Telso Carneiro      º Data ³  23/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gravacao das Alteracoes no campos do MIC/DTA               º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function TMAI45Gcp()
Local aARea		 := GetArea()
Local cQuery    := ''
Local cAliasQry := GetNextAlias()
Local cSeq      := ''
Local ic			 := 0
Local cTexto    := ''
Local nCampo    := 0                   
Local ix        := 0
Local cCodUsr	:= RetCodUsr()

DbSelectArea("DIJ")

//-- Tratar o Campos Memos e Numericos
TMAI45Tmm(@aMicCamp)

Begin Transaction

For ic := 1 To Len(aMicCamp)
	If aMicCamp[ic,3]
		
		nCampo := aMicCamp[ic,2]
		cTexto := ''	
		//-- Pesquisa campos com dois ou mais valores
		For ix := 1 To Len(aMicCamp)
		 	If nCampo == aMicCamp[ix,2]
				cTexto += M->(&(aMicCamp[ix,1]))+Chr(13)+Chr(10)
			EndIf	
		Next
		
		cQuery := "SELECT MAX(DIJ_SEQUEN) SEQ FROM "
		cQuery += RetSqlName("DIJ")+" DIJ "
		cQuery += " WHERE DIJ.DIJ_FILIAL = '"+xFilial("DIJ")+"'"
		cQuery += "   AND DIJ.DIJ_FILMIC = '"+M->DIJ_FILMIC+"' "
		cQuery += "   AND DIJ.DIJ_NUMMIC = '"+M->DIJ_NUMMIC+"' "
		cQuery += "   AND DIJ.DIJ_CODVEI = '"+M->DIJ_CODVEI+"' "
		cQuery += "   AND DIJ.DIJ_ITEMIC = '"+M->DIJ_ITEMIC+"' "
		cQuery += "   AND DIJ.DIJ_CPOMIC = '"+aMicCamp[ic,2]+"' "
		cQuery += "   AND DIJ.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
		cSeq := StrZero(1,Len(DIJ->DIJ_SEQUEN))
		If !Empty((cAliasQry)->SEQ)
			cSeq := Soma1((cAliasQry)->SEQ)              
		EndIf
		(cAliasQry)->(dbCloseArea())
		                          		
		RecLock("DIJ",.T.)
		DIJ->DIJ_FILIAL := xFilial("DIJ")
		DIJ->DIJ_FILMIC := M->DIJ_FILMIC
		DIJ->DIJ_NUMMIC := M->DIJ_NUMMIC
		DIJ->DIJ_CODVEI := M->DIJ_CODVEI
		DIJ->DIJ_ITEMIC := M->DIJ_ITEMIC
		DIJ->DIJ_FILORI := M->DIJ_FILORI
		DIJ->DIJ_DATALT := M->DIJ_DATALT
		DIJ->DIJ_HORALT := M->DIJ_HORALT
		DIJ->DIJ_USER   := cCodUsr
		DIJ->DIJ_CPOMIC := aMicCamp[ic,2]
		DIJ->DIJ_SEQUEN := cSeq
		MSMM(DIJ->DIJ_CODINF,,,cTexto,1,,,"DIJ","DIJ_CODINF")
		MsUnlock()
	EndIf
Next

End Transaction
RestArea(aArea)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMAI45Mvl ºAutor  ³Telso Carneiro      º Data ³  23/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Marcar os Campos Alterados                                 º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function TMAI45Mvl(cCpo)
Local nPos 	  := 0 
Local nPos2	  := 0 

If (nPos := Ascan(aMicCamp,{|x| x[1] $ cCpo } )) <> 0
	If aMicCamp[nPos,4] <> M->(&(aMicCamp[nPos,1]))
      cCampo  := aMicCamp[nPos,2]      
		If (nPos2 := Ascan(aMicCamp,{|x| x[2] == cCampo .and. x[3] } )) == 0
			aMicCamp[nPos,3] := .T.
		EndIf			
	EndIf
EndIf

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMAI45Tmm ºAutor  ³Telso Carneiro      º Data ³  30/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Conversao de Dados para a gravacao do memo                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMAI45Tmm                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMAI45Tmm(aMicCamp)
Local ic      	:= 0
Local cTexto   := ''
Local cxPict   := '@!'

For ic := 1 To Len(aMicCamp)
	If ValType(M->(&(aMicCamp[ic,1]))) == 'N'
	   If Len(aMicCamp[ic]) == 5
			cxPict := aMicCamp[ic,5]
		Else
			cxPict := '@!'		
		EndIf
		cTexto := Transform(M->(&(aMicCamp[ic,1])),cxPict)
	ElseIf ValType(M->(&(aMicCamp[ic,1]))) == 'D'
		cTexto := DTOC(M->(&(aMicCamp[ic,1])))
	Else
		cTexto := M->(&(aMicCamp[ic,1]))
	EndIf
	
	M->(&(aMicCamp[ic,1])) := cTexto
Next

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMAI45Man ºAutor  ³Telso Carneiro      º Data ³  17/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exclusao e Regerando do Mic/Dta matendo o mesmo numero     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSAI45                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMAI45Rge(cAlias, nReg, nOpcx)                
   
Local cPerg   := 'TMAI45'
Local aDocMIC := {}
Local cSeekDII:= ''
Local cMicAtu := ''
Local nDTARec := 0
Local cSeekDTA:= ''
Local aArea   := GetArea()

Default nOpcx := 7   //Regerar

If MsgYesNo(STR0054+Chr(13)+Chr(10)+STR0055) //'Esta rotina regera o MIC/DTA com o dados atuais do CRT mantendo o numeracao.'###'Deseja Continuar ?'
	
	Pergunte(cPerg,.F.)
	// Variaveis utilizadas para parametros
	// 01      ¦Fil.Origem ?
	// 02      ¦Viagem ?
	// 03      ¦Veİculo De ?
	// 04      ¦Veİculo AtÚ ?
	// 05      ¦Aduana de Origem ?
	// 06      ¦Aduana de Destino ?
	// 07      ¦Moeda ?
	// 08      ¦Percurso ?
	// 09      ¦Transito aduaneiro ?	
	cMicAtu   := DID->DID_NUMMIC
	mv_par01  := DID->DID_FILORI
	mv_par02  := DID->DID_VIAGEM
	mv_par03  := Space(Len(DID->DID_CODVEI))
	mv_par04  := Repl('z',Len(DID->DID_CODVEI))
	
	DII->(dbSetOrder(1))
	DII->(dbSeek(cSeekDII := xFilial('DII')+DID->(DID_FILMIC+DID_NUMMIC+DID_CODVEI)))
	mv_par05 := DII->DII_CDAORI
	mv_par06 := DII->DII_CDADES
	mv_par07 := DID->DID_MOEDA
	mv_par08	:=	DID->DID_CODPCI
	mv_par09	:= Val(DID->DID_TRANAD)
	While DII->(!Eof()) .And. DII->(DII_FILIAL+DII_FILMIC+DII_NUMMIC+DII_CODVEI) == cSeekDII
		//Em caso de Estorno do Carregamento pesquisa o novo recno do DTA
		nDTARec := DII->DII_RECDTA
		DTA->(DbGOTO(nDTARec))
		If DTA->(Deleted())
			DTA->(DbSetOrder(1))
			nDTARec := 0
			If DTA->(dbSeek(cSeekDTA := xFilial('DTA')+DII->(DII_FILDOC+DII_DOC+DII_SERIE)+DID->DID_FILORI+DID->DID_VIAGEM))
				While DTA->(!Eof()) .And. DTA->(DTA_FILIAL+DTA_FILDOC+DTA_DOC+DTA_SERIE+DTA_FILORI+DTA_VIAGEM) == cSeekDTA
					nDTARec := DTA->(Recno())
					Exit
				EndDo
			EndIf
		EndIf
		If nDTARec <> 0 
			DT6->(dbSetOrder(1))
			If DT6->(dbSeek(xFilial('DT6')+ DII->(DII_FILDOC+DII_DOC+DII_SERIE) ))
				Aadd(aDocMIC,{ .T.,;
						DTA->DTA_CODVEI,;
						Posicione('DA3',1,xFilial('DA3')+DTA->DTA_CODVEI,'DA3_DESC'),;
						DII->DII_FILDOC,;
						DII->DII_DOC   ,;
						DII->DII_SERIE ,;
						DT6->DT6_QTDVOL,;
						0,;
						0,;
						DID->DID_MOEDA ,;
						Space(Len(SA1->A1_NOME)),;
						nDTARec,;
						DT6->DT6_CDRDES,;
				       DT6->DT6_CDRCAL })
			EndIf				       
		EndIf
		DII->(DbSkip())
	EndDo
	DTQ->(dbSetOrder(2))
	If Len(aDocMIC) == 0 .And. ;
	    DTQ->(dbSeek(xFilial('DTQ')+mv_par01+mv_par02)) .And. !(DTQ->DTQ_TIPVIA $ '2;4') //-- não serVazia ou Socorro
		MsgAlert(STR0056) //'Nao ha Documentos Carregados em Viagem para Regerar o MIC/DTA.'
	Else
		//Exclui o MIC/DTA atual
		//Regerando o MIC/DTA mantendo o numero atual
		Processa({|| TMAI45Exc(), TMAI45Prc(cMicAtu,.F.,aDocMIC,nOpcx)},STR0057) //'Regerando MIC/DTA...'
	EndIf
EndIf

RestArea(aArea)	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMAI45Man ºAutor  ³                    º Data ³ 23/08/21    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exclusao e Regerando do Mic/Dta matendo o mesmo numero     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSAI45                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function TMAI45Des(cRota)
	
Local cQuery    := ''
Local cAliasDI5 := GetNextAlias()
Local aRet      := Array(5)
Local nPosDes   := 1
Local aAreaDTY  := GetArea()  

Default cRota   := ''

Afill(aRet,'')

	cQuery := " SELECT DI5.DI5_CDRFRO FROM " + RetSqlName('DA8') + " DA8 " + CRLF
    cQuery += "   LEFT JOIN " + RetSqlName('DI5') + " DI5 " + CRLF
	cQuery += "   ON(DI5.DI5_FILIAL = '" + xFilial('DI5') + "' AND DI5.DI5_ROTA  ='" + cRota + "' AND DI5.D_E_L_E_T_ = ' ') " + CRLF
    cQuery += " 	WHERE DA8.DA8_FILIAL = '" + xFilial('DA8') + "' AND DA8.DA8_COD ='" + cRota + "' AND DA8.D_E_L_E_T_ = ' ' " + CRLF
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasDI5, .F., .T.)

	While !(cAliasDI5)->(Eof()) .And. Len(aRet)  <= 5
		DUY->(dbSetOrder(1))
		If DUY->(dbSeek(xFilial('DUY')+(cAliasDI5)->DI5_CDRFRO))
			aRet[nPosDes] := AllTrim(DUY->DUY_DESCRI) + ' - ' + Alltrim(DUY->DUY_EST)
			nPosDes ++
		EndIf
		(cAliasDI5)->(dbSkip())
	EndDo						
	(cAliasDI5)->(DbCloseArea())
	RestArea(aAreaDTY)

Return aRet
