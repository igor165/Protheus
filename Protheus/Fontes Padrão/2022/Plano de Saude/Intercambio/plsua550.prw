#INCLUDE "plsua550.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "PLSMCCR.CH"
#DEFINE VL_RECONHE 15 // Posicao no array aReg552 do campo "VL_RECONHE" (Valor Reconhecido)
STATIC bCodLayPLS := .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSUA550
Gera o arquivo PTU 550
@author Tulio Cesar
@since 05/05/2005
@version P12
/*/
//-------------------------------------------------------------------
Function PLSUA550
PRIVATE cCadastro := STR0001 //"Ajius Exportação"
PRIVATE aRotina   := {	{ STR0002, 'AxPesqui'		, 0, K_Pesquisar  },; //"Pesquisar"
						{ STR0003, 'PLSUA550VS'		, 0, K_Visualizar },; //"Visualizar"
						{ STR0004, 'PLSUA550GE(0)'	, 0, K_Incluir    },; //"Exportar"
						{ STR0028, 'PLSUA550GE(1)'	, 0, K_Incluir    } } //"Cancelar"
PRIVATE nRec553		:= 0
PRIVATE aBct553		:={}
PRIVATE lRet		:=.T.
PRIVATE cPerg       := "PLU550"
PRIVATE cGerPtu     := GetNewPar("MV_GERPTU","0") //Parametro = 0 - Criado para versao 4.1B, NAO GERA TITULO CONTESTACAO / 1 - GERA TITULO CONTESTACAO
PRIVATE lExp507     := .F.

PRIVATE oTempR51
PRIVATE oTempR52
PRIVATE oTempR53
PRIVATE oTempR57
PRIVATE oTempR58
PRIVATE oTempR59
PRIVATE oTempR5R

PRIVATE aMark	:= {}
Private l550L	:= .F.

lRet := Pergunte(cPerg,.T.)


// Exibe tela para selecionar arquivo para Exportacao A550 - Busca BRJ
If lRet
	TCSQLEXEC("UPDATE " + RetSqlName("BRJ") + " SET BRJ_OK = '  ' WHERE BRJ_OK <> '  ' ")
	PLS550BRW()
Endif
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS550BRW
Tela MVC com FWMarkBrowse
@author Lucas Nonato
@since 06/06/2018
@version P12
/*/
//-------------------------------------------------------------------
Function PLS550BRW()
private aRotina   := {	{ STR0004, 'PLSUA550GE(0)'	, 0, K_Visualizar },; //"Exportar"
						{ STR0002, 'AxPesqui'		, 0, K_Pesquisar  },; //"Pesquisar"
						{ STR0003, 'PLSUA550VS'		, 0, K_Visualizar },; //"Visualizar"						
						{ STR0028, 'PLSUA550GE(1)'	, 0, K_Visualizar } } //"Cancelar"
	
private cFilter	  := ""
private cCadastro := STR0001
private oMBrwBRJ

BRJ->(dbSetOrder(1))

// cGerPtu = "0" Titulo de Contestacao foi criado no Lote de Pagto(PLSA470)      
// cGerPtu = "1" Titulo de Contestacao sera criado no momento da geracao do A560 
if cGerPtu == "0"
	cPLSFiltro := "@BRJ_FILIAL = '"+xFilial("BRJ")+"' AND BRJ_REGPRI = '1' "
	cPLSFiltro += " AND ((BRJ_NUMSE2 <> ' ' AND BRJ_PRESE2 <> ' ' AND BRJ_TIPSE2 <> ' ') "
	if BRJ->(fieldpos("BRJ_GLOSA")) > 0
		cPLSFiltro += " OR (BRJ_GLOSA = '1' ) "
	endif
	cPLSFiltro += " OR (BRJ_TPCOB = '1' AND BRJ_PREE2N <> ' ' AND BRJ_NUME2N <> ' ')) "
	cPLSFiltro += " AND D_E_L_E_T_ = ' '"
elseif cGerPtu == "1"
	cPLSFiltro := "@BRJ_FILIAL = '"+xFilial("BRJ")+"' AND BRJ_REGPRI = '1' AND BRJ_PREFIX <> ' ' "
	cPLSFiltro += "OR BRJ_NUMFAT <> ' ' OR BRJ_NUMTIT <> ' ' OR BRJ_NUMNDC <> ' ' AND D_E_L_E_T_ = ' '"
endif

oMBrwBRJ:= FWMarkBrowse():New()
oMBrwBRJ:SetAlias("BRJ")
oMBrwBRJ:SetMenuDef("PLSUA550")
oMBrwBRJ:SetFieldMark( 'BRJ_OK' )
oMBrwBRJ:SetFilterDefault(cPLSFiltro)
oMBrwBRJ:SetDescription(cCadastro)
oMBrwBRJ:SetAllMark({ ||  A550Inverte(oMBrwBRJ) })
oMBrwBRJ:SetWalkThru(.F.)
oMBrwBRJ:SetAmbiente(.F.)
oMBrwBRJ:ForceQuitButton()
oMBrwBRJ:SetAfterMark({||PLMARKBRJ(oMBrwBRJ)}) 
oMBrwBRJ:Activate()

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSUA550GE ³ Autor ³ Alexander Santos    ³ Data ³ 02.01.07 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Gera os arquivos de exportacao/cancela do ajius 			  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSUA550GE(nTp)
LOCAL aRet
LOCAL nFor
LOCAL lSeg	:= .T.
LOCAL lCan 	:= .F.
LOCAL lRet 	:= .T.
LOCAL aOK   := {}

If lRet
	
	// BRJ	
	B2A->( DbSetOrder(1) ) //B2A_FILIAL + B2A_OPEDES + B2A_NUMTIT
	BRJ->( DbSetOrder(1) ) //BRJ_FILIAL + BRJ_CODIGO
	BRJ->( DbGoTop() )
	
	cSql := " SELECT R_E_C_N_O_ RECNO FROM " + RetSqlName("BRJ") + " BRJ "
	cSql += " WHERE BRJ_OK = '" + oMBrwBRJ:cMark + "'" 
	cSql += " AND BRJ.D_E_L_E_T_ = ' ' "
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),'BRJTMP',.F.,.T.)

	// While BRJ	
	Do While !BRJTMP->( Eof() )
		
		BRJ->(dbgoto(BRJTMP->RECNO))
		
			
			// Cancelamento				
			If nTp == 1
				If B2A->( MsSeek( xFilial("B2A")+alltrim(BRJ->(BRJ_OPEORI+BRJ_NUMFAT)) ) )
					If !B2A->B2A_TPARQ $ "2,3"
						While !B2A->( Eof() ) .And. B2A->(B2A_FILIAL+B2A_OPEDES+B2A_NUMTIT) == alltrim(xFilial("B2A")+BRJ->(BRJ_OPEORI+BRJ_NUMFAT))
							B2A->( RecLock("B2A", .F.) )
							B2A->( dbDelete() )
							B2A->( MsUnlock() )
							B2A->( DbSkip() )
							lCan := .T.
						EndDo
					Else
						MsgStop(STR0031+BRJ->BRJ_NUMFAT+STR0032)//"Existe importação para a fatura ( "+######+" ), primeiro cancele a importação!"
					EndIf
				Else
					MsgStop(STR0029+BRJ->BRJ_NUMFAT+STR0030)//"Fatura ( "+#######+" ), ainda nao foi exportada!"
				EndIf
			Else
				
				// Processamento				
				If lSeg
					If BRJ->BRJ_TIPLOT == "2"
						aRet := PLSUA550RA()
					Else
						aRet := PLSUA550PR(1)						
						If Len(aRet) > 0
							If aRet[1]
								AaDd(aOK,{BRJ->(BRJ_OPEORI+"-"+BRJ->BRJ_NOMORI),STR0006,aRet[2]}) //"Arquivo Gerado"
							Else
								If Len(aRet[2]) > 0
									AaDd(aOK,{BRJ->(BRJ_OPEORI+"-"+BRJ->BRJ_NOMORI),STR0007,""}) //"Nao foi possivel gerar. Motivo:"
									For nFor := 1 To Len(aRet[2])
										AaDd(aOK,{"",aRet[2,nFor,1]+"-"+aRet[2,nFor,2] ,""})
									Next
								EndIf
							Endif
						EndIf
					EndIf
				EndIf
			EndIf
		
		BRJTMP->( DbSkip() )
	Enddo
	BRJTMP->( dbclosearea() )
EndIf

If Len(aOK) > 0
	PLSCRIGEN(aOK,{ {STR0009,"@C",150},{STR0010,"@C",250},{STR0006,"@C",060} }, STR0011) //"Operadora Origem"###"Status"###"Arquivo Gerado"###"  Resumo "
Endif 
aOK   := {} 

// Cancelamento														

If lCan
	MsgAlert(STR0035)//"Concluido o processo de CANCELAMENTO!"
EndIf
	
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSUA550PR ³ Autor ³ Alexander Santos    ³ Data ³ 02.01.07 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Gera arquivo do 	Ajius									  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSUA550PR(nTipo)
LOCAL nFor
LOCAL nFor2
LOCAL nRegDE1551
LOCAL cChave551
LOCAL nRegDE1552
LOCAL cChave552
LOCAL nRegDE1553
LOCAL cChave553
LOCAL nRegDE1559
LOCAL cChave559
LOCAL nBottomArray
LOCAL cDado
LOCAL cFileGerado
LOCAL cDatGer
LOCAL cDatAtn
LOCAL cDtAcor
LOCAL nVlrTFa
LOCAL cNumFat := ""
LOCAL nIdOri
LOCAL cOpeOri
LOCAL cOpeDes := ""
LOCAL cTpArq
LOCAL cNumNota
LOCAL cNumLote
LOCAL cMatric
LOCAL cCodQue
LOCAL cDesQue
LOCAL cCodPad
LOCAL cCodPro
LOCAL cTpAcord
LOCAL cChaveBD6
LOCAL lContinua  := .T.
LOCAL nTotReg 	 := 0
LOCAL nVlrTotCob := 0
LOCAL nVlrTotRec := 0
LOCAL nVlrTotAco :=0
LOCAL nVlrTotAcoTx:=0
LOCAL nTotR507   := 0
LOCAL nTotR508   := 0
LOCAL nNumSeq    := 2
LOCAL nTamMaxLay := 0
LOCAL nTotRec    := 0
LOCAL nLayTam    := 0
LOCAL nVlrPag    := 0
LOCAL nID_ORI    := 0
LOCAL cDirFile   := "\PTU\"
LOCAL aRet       := {}
LOCAL aBusGui    := {}
LOCAL aDados     := {}
LOCAL aReg551    := {}
LOCAL aReg552    := {}
LOCAL aReg553    := {}
LOCAL aReg559    := {}
LOCAL aStru551   := {}
LOCAL aStru552   := {}
LOCAL aStru553   := {}
LOCAL aStru557   := {}
LOCAL aStru558   := {}
LOCAL aStruR5R   := {}
LOCAL aStru559   := {}
LOCAL aCriticas  := {}
LOCAL aRetBTU    := {}
Local cDate      := ""
Local cDt        := ""
Local cHr        := ""
Local cCodPacG   := getNewPar("MV_PLPACPT","99999998")
LOCAL cGNT       := "-03"
LOCAL cTipTab	 := ""
LOCAL nForx		 := 0
LOCAL nLin553	 := 0
LOCAL nTx		 := 0
LOCAL nFory		 := 0
LOCAL lNaoHaConte:= .F.
LOCAL cCodPsa	 := ""
LOCAL cCodTab	 := ""
LOCAL lFounDePar := .F.
LOCAL lExistB1M  := PlsAliasExi("B1M")
LOCAL lP550BENEF := ExistBlock("P550BENEF")
LOCAL nRecTot552 := 0

LOCAL nRec553	 := 0
LOCAL nVlrApr 	 := 0
LOCAL lGlosouTudo:= .T.
LOCAL nCalc		 := 0
LOCAL cCodImp	 := ""
LOCAL lDePara    := GetNewPar("MV_P500HDP","1") == "1"
LOCAL lDeParaBTU := GetNewPar("MV_PLAJBTU","0") == "1"
LOCAL lPL550PROC := ExistBlock("PL550PROC")
LOCAL lPL550DESC := ExistBlock("PL550DESC")

PRIVATE cCodQuest:="99"

// Verifica se layout existe... 
cDirFile := AllTrim(mv_par01)
cLayout  := PADR(AllTrim(mv_par02),6)

l550L := cLayout >= "A550L"
// Testa o diretorio													

If SubStr(cDirFile,Len(cDirFile),1) # "\"
	cDirFile+="\"
EndIf

// EDI																	

DE9->( DbSetOrder(1) )
If !DE9->( MsSeek( xFilial("DE9")+cLayout ) )
	AaDd( aCriticas,{"01",STR0013} ) //"Arquivo de layout EDI A550 nao LOCALizado nas parametrizacoes do sistema."
	lContinua := .F.
Else
	bCodLayPLS := val(AllTrim(DE9->DE9_VERLAY)) >= val("5.0a")
Endif
If nTipo == 1
	
	// Regra - Verifica se existe o titulo a receber contra a operadora...      ³
	
	SE1->( DbSetOrder(1) )
	If !Empty(BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT)) .And. !SE1->( MsSeek(xFilial("SE1")+Alltrim(BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT))))
		AaDd(aCriticas,{"02",STR0014+Alltrim(BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT))+STR0015}) //"Titulo a Receber ["###"] nao encontrado."
		lContinua := .F.
	Endif
	If !Empty(BRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+BRJ_TIPNDC)) .And. !SE1->( MsSeek(xFilial("SE1")+Alltrim(BRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+BRJ_TIPNDC))))
		AaDd(aCriticas,{"02",STR0014+Alltrim(BRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+BRJ_TIPNDC))+STR0015}) //"Titulo a Receber ["###"] nao encontrado."
		lContinua := .F.
	Endif
	
	// Regra - Verifica se existe o titulo a pagar   contra a operadora...      ³
	
	SE2->( DbSetOrder(1) )
	If !Empty(BRJ->(BRJ_PRESE2+BRJ_NUMSE2+BRJ_PARSE2+BRJ_TIPSE2)) .And. !SE2->( MsSeek(xFilial("SE2")+Alltrim(BRJ->(BRJ_PRESE2+BRJ_NUMSE2+BRJ_PARSE2+BRJ_TIPSE2)) ))
		AaDd(aCriticas,{"03",STR0016+Alltrim(BRJ->(BRJ_PRESE2+BRJ_NUMSE2+BRJ_PARSE2+BRJ_TIPSE2))+STR0015}) //"Titulo a Pagar ["###"] nao encontrado."
		lContinua := .F.
	Endif
	If !Empty(BRJ->(BRJ_PREE2N+BRJ_NUME2N+BRJ_PARNDC+BRJ_TIPE2N)) .And. !SE2->( MsSeek(xFilial("SE2")+Alltrim(BRJ->(BRJ_PREE2N+BRJ_NUME2N+BRJ_PARNDC+BRJ_TIPE2N)) ))
		AaDd(aCriticas,{"03",STR0016+Alltrim(BRJ->(BRJ_PREE2N+BRJ_NUME2N+BRJ_PARE2N+BRJ_TIPE2N))+STR0015}) //"Titulo a Pagar ["###"] nao encontrado."
		lContinua := .F.
	Endif
Else
	
	// Regra - Verifica se existe o titulo a receber contra a operadora...      ³
	
	SE1->( DbSetOrder(1) )
	If !SE1->( MsSeek(xFilial("SE1")+Alltrim(BTO->(BTO_PREFIX+BTO_NUMTIT+BTO_PARCEL+BTO_TIPTIT))))
		AaDd(aCriticas,{"02",STR0014+Alltrim(BTO->(BTO_PREFIX+BTO_NUMTIT+BTO_PARCEL+BTO_TIPTIT))+STR0015}) //"Titulo a Receber ["###"] nao encontrado."
		lContinua := .F.
	Endif
	
Endif

// checagem de regras... 												     ³

If lContinua
	
	// Posiciona no tipo de registro R551 (Header)...                
	
	DE0->( DbSetOrder(1) )
	If !DE0->( MsSeek(xFilial("DE0")+cLayout+"R551  ") )
		AaDd(aCriticas,{"04",STR0017}) //"Arquivo de registro R551 nao LOCALizado."
		lContinua := .F.
	Else
		nTamMaxLay := Iif(DE0->DE0_TAMREG > nTamMaxLay, DE0->DE0_TAMREG, nTamMaxLay)
	EndIf
	
	// Posiciona no primeiro campo deste tipo de registro...         
	
	DE1->( DbSetOrder(2) ) //DE1_FILIAL+DE1_CODLAY+DE1_CODREG+DE1_SEQUEN
	If !DE1->( MsSeek( xFilial("DE1")+DE0->(DE0_CODLAY+DE0_CODREG) ) )
		AaDd(aCriticas,{"05",STR0018}) //"Nao encontrado campos para o tipo de registro R551."
		lContinua := .F.
	Else
		nRegDE1551 := DE1->( Recno() )
		cChave551  := DE0->( DE0_CODLAY+DE0_CODREG )
	Endif
	
	// Posiciona no tipo de registro R553 (Header)...                
	
	DE0->(DbSetOrder(1))
	If !DE0->(MsSeek(xFilial("DE0")+cLayout+"R553"))
		AaDd(aCriticas,{"06",STR0019}) //"Arquivo de registro R553 nao LOCALizado."
		lContinua := .F.
	Else
		nTamMaxLay := IIf(DE0->DE0_TAMREG > nTamMaxLay, DE0->DE0_TAMREG, nTamMaxLay)
	Endif
	
	// Posiciona no primeiro campo deste tipo de registro...         
	
	DE1->( DbSetOrder(2) )//DE1_FILIAL+DE1_CODLAY+DE1_CODREG+DE1_SEQUEN
	If !DE1->( MsSeek( xFilial("DE1")+DE0->(DE0_CODLAY+DE0_CODREG) ) )
		AaDd(aCriticas,{"07",STR0020})
		lContinua := .F.
	Else
		nRegDE1553 := DE1->( Recno() )
		cChave553  := DE0->( DE0_CODLAY+DE0_CODREG )
	Endif
	
	
	// Posiciona no tipo de registro R559 (Header)...                
	
	DE0->(DbSetOrder(1))
	If !DE0->(MsSeek(xFilial("DE0")+cLayout+"R559"))
		AaDd(aCriticas,{"06",STR0019}) //"Arquivo de registro R559 nao LOCALizado."
		lContinua := .F.
	Else
		nTamMaxLay := IIf(DE0->DE0_TAMREG > nTamMaxLay, DE0->DE0_TAMREG, nTamMaxLay)
	Endif
	
	// Posiciona no primeiro campo deste tipo de registro...         
	
	DE1->( DbSetOrder(2) )//DE1_FILIAL+DE1_CODLAY+DE1_CODREG+DE1_SEQUEN
	If !DE1->( MsSeek( xFilial("DE1")+DE0->(DE0_CODLAY+DE0_CODREG) ) )
		AaDd(aCriticas,{"07",STR0020}) //"Nao encontrado campos para o tipo de registro R559."
		lContinua := .F.
	Else
		nRegDE1559 := DE1->( Recno() )
		cChave559  := DE0->( DE0_CODLAY+DE0_CODREG )
	Endif
	
	// Posiciona no tipo de registro R552 (detalhe)...               
	
	DE0->( DbSetOrder(1) )
	If !DE0->( MsSeek( xFilial("DE0")+cLayout+"R552" ) )
		AaDd( aCriticas,{"08",STR0021} ) //"Arquivo de registro R552 nao LOCALizado."
		lContinua := .F.
	Else
		nTamMaxLay := Iif(DE0->DE0_TAMREG > nTamMaxLay, DE0->DE0_TAMREG, nTamMaxLay)
	Endif
	
	// Posiciona no primeiro campo deste tipo de registro...         
	
	DE1->( DbSetOrder(2) )//DE1_FILIAL+DE1_CODLAY+DE1_CODREG+DE1_SEQUEN
	If !DE1->( MsSeek(xFilial("DE1")+DE0->(DE0_CODLAY+DE0_CODREG) ) )
		AaDd( aCriticas,{"09",STR0022} ) //"Nao encontrado campos para o tipo de registro R552."
		lContinua := .F.
	Else
		nRegDE1552 := DE1->( Recno() )
		cChave552  := DE0->( DE0_CODLAY+DE0_CODREG )
	Endif
	
	// Inicio da montagem do detalhe...                              
	
	If lContinua
		
		If nTipo == 1 .And. Empty(BRJ->BRJ_NIV550)
			BRJ->( RecLock("BRJ", .F.) )
			BRJ->BRJ_NIV550 := '1'
			BRJ->( MsUnlock() )
		EndIf
		
		aBusGui := BuscaGuias(nTipo)
		
		// Retorno conteudo													
		
		aDados  := aBusGui[1]
		nTotRec := aBusGui[2]
		If Len(aDados) > 0
			
			nID_ORI := 0
			For nFor := 1 To Len(aDados)
				If !aDados[nFor,24]
					lGlosouTudo:=.F.
					EXIT
				Endif
			Next 1
			
			// For																	
			
			For nFor := 1 To Len(aDados)
				BD6->( DbGoTo( aDados[nFor,1] ) )
				BD7->( DbGoTo( aDados[nFor,20] ) )				
				nVlrPag := BD7->BD7_VLRPAG				
				cCodQuest := "99"
				
				If nTipo = 1					
					BA0->(DbSetOrder(1))
					BA0->(MsSeek(xFilial("BA0")+BRJ->BRJ_OPEORI))					
					BA0->(DbSetOrder(1))
					If BA0->(MsSeek(xFilial("BA0")+BRJ->BRJ_OPEORI)) .And. ! Empty(BA0->BA0_GNT)
						cGNT := BA0->BA0_GNT
					Endif					
				Endif
				
				
				// Monta R553 (Header)...                                        
				
				lNaoHaConte:=.F.
				For nTx:=1 to Len(aBct553)
					If aBct553[nTx,1] == aDados[nFor,1]
						cCodQuest := aBct553[nTx,4]
						If cCodQuest="99"
							lNaoHaConte:=.T.
						Endif
					Endif
				Next nTx
				
				// 552															    	
				
				AaDd( aReg552,{ BD7->( Recno() ),{},BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO),BD7->BD7_SEQ500,lNaoHaConte } )
				nBottomArray := Len(aReg552)
				DE1->( DbGoTo(nRegDE1552) )
				nID_ORI++

				While ! DE1->( Eof() ) .And. DE1->(DE1_FILIAL+DE1_CODLAY+DE1_CODREG) == xFilial("DE9")+cChave552
					
					If     AllTrim(DE1->DE1_CAMPO) == "NR_SEQ" //001
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(nNumSeq++,DE1->DE1_LAYTAM) } )
						
					ElseIf AllTrim(DE1->DE1_CAMPO) == "TP_REG"  //002
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,"552" } )
						
					ElseIf AllTrim(DE1->DE1_CAMPO) == "NR_LOTE"  //003
						If !Empty(BD6->BD6_LOTEDI)
							AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(Val(SUBSTR(BD6->BD6_LOTEDI,1,8)) , DE1->DE1_LAYTAM)})
						Else
							AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(Val(SUBSTR(BD6->BD6_NUMIMP,1,8)) , DE1->DE1_LAYTAM)})
						EndIf
					ElseIf AllTrim(DE1->DE1_CAMPO) == "RESERVADO"    //004
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Space(DE1->DE1_LAYTAM) } )
					ElseIf AllTrim(DE1->DE1_CAMPO) == "RESERVADO"    //005
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Space(DE1->DE1_LAYTAM) } )
					ElseIf AllTrim(DE1->DE1_CAMPO) == "CD_UNI"    //006
						
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,BD6->BD6_OPEUSR } )
					ElseIf AllTrim(DE1->DE1_CAMPO) == "ID_BENEF" //007
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,BD6->(BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_DIGITO) } )
					ElseIf AllTrim(DE1->DE1_CAMPO) == "NM_BENEF" //008
						If lP550BENEF
							cNomeBenef := ExecBlock("P550BENEF",.F.,.F.,{BD6->BD6_NOMUSR})
							AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Subs(cNomeBenef,1,DE1->DE1_LAYTAM)})
						Else
							AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Subs(BD6->BD6_NOMUSR,1,DE1->DE1_LAYTAM)})
							
						Endif
					ElseIf AllTrim(DE1->DE1_CAMPO) == "DT_ATEND"  //009
						
						If BD6->BD6_TIPGUI $ "01,02,06"
							If !Empty(BD6->BD6_HORPRO)
								cHr := StrZero(Val(substr(BD6->BD6_HORPRO,1,2)), 2, 0) + ":" + StrZero(Val(substr(BD6->BD6_HORPRO,3,2)), 2, 0) +":"+ If(Len(BD6->BD6_HORPRO)> 4,StrZero(Val(substr(BD6->BD6_HORPRO,5,2)), 2, 0),"00")+cGNT
							Else
								cHr := "00:00:00"+cGNT
							Endif
							BD5->(DbSetOrder(1))
							If BD5->(DbSeek(xFilial("BD5")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)))
								
								If !Empty(BD5->BD5_DATPRO)
									cDt := substr(DtoS(BD5->BD5_DATPRO),1,4) + "/" + substr(DtoS(BD5->BD5_DATPRO),5,2) + "/" + substr(DtoS(BD5->BD5_DATPRO),7,2)
								Else
									cDt := "0000/00/00"
								Endif
								
								
								If !Empty(BD5->BD5_HORPRO)
									cHr := StrZero(Val(substr(BD5->BD5_HORPRO,1,2)), 2, 0) + ":" + StrZero(Val(substr(BD5->BD5_HORPRO,3,2)), 2, 0) + ":"+If(Len(BD5->BD5_HORPRO)> 4,StrZero(Val(substr(BD5->BD5_HORPRO,5,2)), 2, 0),"00")+cGNT
								Else
									cHr := "00:00:00"+cGNT
								Endif
							EndIf
						Else
							BE4->(DbSetOrder(1))
							If BE4->(DbSeek(xFilial("BE4")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO))) //.And. BE4->BE4_COMUNI == "1"
								
								If !Empty(BE4->BE4_DATPRO)
									cDt := substr(DtoS(BE4->BE4_DATPRO),1,4) + "/" + substr(DtoS(BE4->BE4_DATPRO),5,2) + "/" + substr(DtoS(BE4->BE4_DATPRO),7,2)
								Else
									cDt := "0000/00/00"
								Endif
								
								If !Empty(BE4->BE4_HORPRO)
									cHr := StrZero(Val(substr(BE4->BE4_HORPRO,1,2)), 2, 0) + ":" + StrZero(Val(substr(BE4->BE4_HORPRO,3,2)), 2, 0) + ":00"+cGNT
								Else
									cHr := "00:00:00"+cGNT
								Endif
							EndIf
						EndIf
						cDate :=  cDt + cHr
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,cDate} )
					ElseIf AllTrim(DE1->DE1_CAMPO) == "RESERVADO2" //010
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Space(DE1->DE1_LAYTAM)})
					ElseIf AllTrim(DE1->DE1_CAMPO) == "TP_TABELA"  //011
						
						cTipTab := "0"
						
						BR8->(dbSetOrder(1))
						If BR8->(dbSeek(xFilial("BR8")+BD6->(BD6_CODPAD+BD6_CODPRO))) .And. !Empty(BR8->BR8_TPPROC)
							cTipTab := BR8->BR8_TPPROC
							Do Case
							Case cTipTab $ "0"
								cTipTab := "0"
							Case cTipTab $ "3,4"
								cTipTab := "1"
							Case cTipTab $ "1,5"
								cTipTab := "2"
							Case cTipTab $ "2"
								cTipTab := "3"
							Case cTipTab $ "6"
								cTipTab := "4"
							EndCase
						EndIf
						
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,cTipTab})
						
					ElseIf AllTrim(DE1->DE1_CAMPO) == "CD_SERVICO"  //012
						
						If (empty(BD6->BD6_CD_PAC)) .OR. !l550L	
							BR8->(dbSetOrder(1))
							If BR8->(dbSeek(xFilial("BR8")+BD6->(BD6_CODPAD+BD6_CODPRO)))
								cCodTab := BR8->BR8_CODPAD
							Endif
							
							If lDeParaBTU
								aRetBTU := PTUDePaBTU(nil,BD6->BD6_CODPRO,BD6->BD6_CODPAD,.F.,.T.)
								If len(aRetBTU) > 0
									cCodPsa := Alltrim(aRetBTU[2])
									lFounDePar := .T.
								EndIf
							ElseIf lExistB1M .And. lDePara
								cCodPsa := PLDeParINT(BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_DATPRO,@lFounDePar,"E")
							EndIf
							If !lFounDePar
								If  ! empty(BR8->BR8_CODEDI) .And. lDePara
									cCodPsa := strzero(val(BR8->BR8_CODEDI),8)
								Else
									cCodPsa := strzero(val(BD6->BD6_CODPRO),8)
								Endif
							EndIf
						else
							cCodPsa := BD6->BD6_CD_PAC
						endIf

						If lPL550PROC
							cCodPsa := ExecBlock("PL550PROC",.F.,.F.,{cCodPsa,cCodTab})
						Endif
						
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Subs(cCodPsa,1,DE1->DE1_LAYTAM) } )

					ElseIf AllTrim(DE1->DE1_CAMPO) == "VL_COBRADO" //013
					
						nVlrTotCob += aDados[nFor,5]				
						
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero( aDados[nFor,22] * 100,DE1->(DE1_LAYTAM + DE1_LAYDEC) ) } )						
					ElseIf AllTrim(DE1->DE1_CAMPO) == "VL_RECONHE" //014
						If !(aDados[nFor,26])							
							If aDados[nFor,24] // SE FOR UMA GLOSA INTEGRAL
								AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(0,DE1->(DE1_LAYTAM+DE1_LAYDEC) ) } )
							Else
								If aDados[nFor,22]+aDados[nFor,23] == aDados[nFor,19] // Nao houve glosa parcial e nem total
									AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(aDados[nFor,22]*100,DE1->(DE1_LAYTAM+DE1_LAYDEC) ) } )
								Else// houve glosa parcial
									nVlrTotRec += aDados[nFor,25]
									AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(Round(aDados[nFor,25], 2)*100,DE1->(DE1_LAYTAM+DE1_LAYDEC) ) } )
								EndIf 
							EndIf							
						Else
							AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(Round(aDados[nFor,19], 2)*100,DE1->(DE1_LAYTAM+DE1_LAYDEC) ) } )
						Endif
						nLayTam := DE1->(DE1_LAYTAM+DE1_LAYDEC)
					ElseIf AllTrim(DE1->DE1_CAMPO) == "VL_ACORDO"   //015
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(Round(0,2)*100,DE1->(DE1_LAYTAM+DE1_LAYDEC) ) } )
					ElseIf AllTrim(DE1->DE1_CAMPO) == "DT_ACORDO"   //16
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Space(TamSX3("BRJ_DATA")[1]) } )
					ElseIf AllTrim(DE1->DE1_CAMPO) == "TP_ACORDO"   //17
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,IIf(lNaoHaConte,"11","00")})
					ElseIf AllTrim(DE1->DE1_CAMPO) == "QTD_COBRAD" //18
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,TotQtdRec(BD6->BD6_QTDPRO)})
						
					ElseIf AllTrim(DE1->DE1_CAMPO) == "DS_SERVICO"//19
						If !(empty(BD6->BD6_CD_PAC))
							cDescBr8 := BD6->BD6_DES500
						else
							cDescBr8 := BD6->BD6_DESPRO
						endIf
						If lPL550DESC
							cDescBr8 := ExecBlock("PL550DESC",.F.,.F.,{cDescBr8})
							AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,cDescBr8+Space(30)} )
						Else
							AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,IIf(BR8->BR8_GENER=="1",Padr(BD6->BD6_DES500,DE1->(DE1_LAYTAM+DE1_LAYDEC)),Padr(cDescBr8,DE1->(DE1_LAYTAM+DE1_LAYDEC)))} )
						EndIf
					ElseIf AllTrim(DE1->DE1_CAMPO) == "NR_SEQ_500"//20
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO, BD7->BD7_SEQ500} )
					ElseIf AllTrim(DE1->DE1_CAMPO) == "VL_COBR_CO" 	//21
						nVlrTotCob += aDados[nFor,6]
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(Round(aDados[nFor,6],2 )*100,DE1->(DE1_LAYTAM+DE1_LAYDEC))})
					ElseIf AllTrim(DE1->DE1_CAMPO) == "VL_RECO_CO" //22
						nVlrTotRec += aDados[nFor,7]
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(Round(aDados[nFor,7],2 )*100,DE1->(DE1_LAYTAM+DE1_LAYDEC))})
					ElseIf AllTrim(DE1->DE1_CAMPO) == "VL_ACOR_CO"  //23
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(Round(0,2 )*100,DE1->(DE1_LAYTAM+DE1_LAYDEC))})
					ElseIf AllTrim(DE1->DE1_CAMPO) == "VL_COB_FI"  //24
						nVlrTotCob += aDados[nFor,10]
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(Round(aDados[nFor,10],2 )*100,DE1->(DE1_LAYTAM+DE1_LAYDEC))})
					ElseIf AllTrim(DE1->DE1_CAMPO) == "VL_RECO_FI" //25
						nVlrTotRec += aDados[nFor,11]
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(Round(aDados[nFor,11],2 )*100,DE1->(DE1_LAYTAM+DE1_LAYDEC))})
					ElseIf AllTrim(DE1->DE1_CAMPO) == "VL_ACOR_FI" //26
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(0,DE1->(DE1_LAYTAM+DE1_LAYDEC))})
					ElseIf AllTrim(DE1->DE1_CAMPO) == "VL_CB_AD_S" //27
						nVlrTotCob += aDados[nFor,16]
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(Round(aDados[nFor,16],2 )*100,DE1->(DE1_LAYTAM+DE1_LAYDEC))})
						
					ElseIf AllTrim(DE1->DE1_CAMPO) == "VL_RE_AD_S" //28
						
						If aDados[nFor,24]  // SE FOR GLOSA INTEGRAL
							AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(0,DE1->(DE1_LAYTAM+DE1_LAYDEC))})
						Else
							AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(Round(aDados[nFor,17],2 )*100,DE1->(DE1_LAYTAM+DE1_LAYDEC))})
						Endif
						
					ElseIf AllTrim(DE1->DE1_CAMPO) == "V_ACO_AD_S"//29
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(Round(0,2 )*100,DE1->(DE1_LAYTAM+DE1_LAYDEC))})
					ElseIf AllTrim(DE1->DE1_CAMPO) == "V_CB_AD_CO" //30
						nVlrTotCob += aDados[nFor,8]
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(Round(aDados[nFor,8],2 )*100,DE1->(DE1_LAYTAM+DE1_LAYDEC))})
					ElseIf AllTrim(DE1->DE1_CAMPO) == "V_RE_AD_CO" //31
						nVlrTotRec += aDados[nFor,9]
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(Round(aDados[nFor,9],2 )*100,DE1->(DE1_LAYTAM+DE1_LAYDEC))})
					ElseIf AllTrim(DE1->DE1_CAMPO) == "V_ACD_A_CO" //32
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(Round(0,2 )*100,DE1->(DE1_LAYTAM+DE1_LAYDEC))})
					ElseIf AllTrim(DE1->DE1_CAMPO) == "V_CB_AD_FI" //33
						nVlrTotCob += aDados[nFor,12]
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(Round(aDados[nFor,12],2 )*100,DE1->(DE1_LAYTAM+DE1_LAYDEC))})
					ElseIf AllTrim(DE1->DE1_CAMPO) == "V_RC_AD_FI" //34
						nVlrTotRec += aDados[nFor,13]
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(Round(aDados[nFor,13],2 )*100,DE1->(DE1_LAYTAM+DE1_LAYDEC))})
					ElseIf AllTrim(DE1->DE1_CAMPO) == "V_ACD_A_FI" //35
						//						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(Round(aDados[nFor,13],2 )*100,DE1->(DE1_LAYTAM+DE1_LAYDEC))})
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(Round(0,2 )*100,DE1->(DE1_LAYTAM+DE1_LAYDEC))})
					ElseIf AllTrim(DE1->DE1_CAMPO) == "QT_RECONH"  //36
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,TotQtdRec(BD6->BD6_QTDPRO)})
					ElseIf AllTrim(DE1->DE1_CAMPO) == "ID_PACOTE"  //37		
						If l550L	
							if alltrim(BD6->BD6_CODPRO) == cCodPacG
								cCmp := " "
							elseif empty(BD6->BD6_CD_PAC)
								cCmp := "N"	
							else
								cCmp := "S"
							endif
							AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,cCmp})						
						else
							AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,IIF(Empty(BD6->BD6_CD_PAC),'N','S')})
						endIf
					ElseIf AllTrim(DE1->DE1_CAMPO) == "CD_PACOTE"  //38						
						If l550L .and. empty(BD6->BD6_CD_PAC)
							AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,STRZERO(0,DE1->(DE1_LAYTAM+DE1_LAYDEC))})
						else
							AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,STRZERO(VAL(BD6->BD6_CD_PAC),DE1->(DE1_LAYTAM+DE1_LAYDEC))})
						endIf
					ElseIf AllTrim(DE1->DE1_CAMPO) == "DT_SERVICO"  //39
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,dtos(BD6->BD6_DATPRO)})
					ElseIf AllTrim(DE1->DE1_CAMPO) == "HR_REALIZ"  //40
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Substr(BD6->BD6_HORPRO,1,2) + ":" + substr(BD6->BD6_HORPRO,3,2) + ":" + If(Len(BD6->BD6_HORPRO)> 4,StrZero(Val(substr(BD6->BD6_HORPRO,5,2)), 2, 0),"00")})
					ElseIf AllTrim(DE1->DE1_CAMPO) == "QT_ACORDAD"  //41
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,"00000000"})
					ElseIf AllTrim(DE1->DE1_CAMPO) == "FT_MULT_SV"  //42
						AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(BD6->BD6_FATMUL*100,DE1->(DE1_LAYTAM+DE1_LAYDEC))})
					ElseIf AllTrim(DE1->DE1_CAMPO) == "NR_NOTA"    //43
						If !Empty(BD6->BD6_LOTEDI)
							AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Padr(BD6->BD6_NUMIMP,DE1->DE1_LAYTAM) } )
						Else
							AaDd(aReg552[nBottomArray,2],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(Val(SUBSTR(BD6->BD6_NUMIMP,9,11)),DE1->DE1_LAYTAM) } )
						EndIf
					Endif
					
					// Proximo																
					
					DE1->( DbSkip() )
				Enddo

			Next
			
			// Monta R553 (Header)...                                        
			
			lNaoHaConte := .F.
			
			aSort(aBct553,,, { |x,y| y[7] > x[7]} )
			
			For nFor := 1 To Len(aDados)
			
				For nTx := 1 to Len(aBct553)
				
					If alltrim(aBct553[nTx,8]) == alltrim(aDados[nFor,21])  .or. nTipo = 2   //nTipo = 2 para a geraçõa do a550 tipo 5
						
						DE1->( DbGoTo(nRegDE1553) )
						AaDd( aReg553,{} )
						nLin553 := Len(aReg553)
						
						cCodQuest := aBct553[nTx,4]
						
						If nTipo = 2   //nTipo = 2 para a geraçõa do a550 tipo 5
							cCodQuest := "98"
						Endif
						
						// While																
						
						While ! DE1->( Eof() ) .And. DE1->(DE1_FILIAL+DE1_CODLAY+DE1_CODREG) == xFilial("DE9")+cChave553
							If AllTrim(DE1->DE1_CAMPO) == "NR_SEQ"
								AaDd(aReg553[nLin553],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(nNumSeq++,DE1->DE1_LAYTAM)})
							ElseIf AllTrim(DE1->DE1_CAMPO) == "TP_REG"
								AaDd(aReg553[nLin553],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,"553"})
							ElseIf AllTrim(DE1->DE1_CAMPO) == "CD_MOT_QUE"
								AaDd(aReg553[nLin553],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,If(cCodQuest="XX",cCodQuest,Strzero(Val(cCodQuest),4))})
							ElseIf AllTrim(DE1->DE1_CAMPO) == "DS_MOT_QUE"
								SX5->(DbSetOrder(1))
								if SX5->(DbSeek(xFilial("SX5")+"ZO"+cCodQuest))
									cDesMot	:= iif(cCodQuest<>"98",SX5->X5_DESCRI,aBct553[nTx,5]) 
									cDesMot	:= iif(!empty(aDados[nFor][3]),alltrim(aDados[nFor][3]),cDesMot) 
									aadd(aReg553[nLin553],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,cDesMot})
								else
									if (!empty(aDados[nFor][3]))
										cDesMot	:= alltrim(aDados[nFor][3])
									else
										cDesMot	:= "O Cod.Glosa "+aBct553[nTx,3]+"-"+Substr(aBct553[nTx,5],1,10)+" não cadastrado o CodEdi (BCT_EDI550) na tabela BCT" + " - " + aDados[nFor][3]
										aadd(aReg553[nLin553],{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,cDesMot})
									endif
								endif
							Endif
							
							// Proximo																
							
							DE1->( DbSkip() )
						Enddo
						AaDd(aReg553[nLin553],{aBct553[nTx,8]})
						
					Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ`¿
					//Gerando o Tipo 5 para os testes pos quem gera o tipo 5 é o WST como nao temos acesso³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ`Ù
					If nTipo = 2
						Exit
					Endif
					
				Next nTx
			Next nFor
			
			
			// Monta R551 (Header)...                                        
			
			DE1->( DbGoTo(nRegDE1551) )
			
			
			// While																
			
			While ! DE1->( Eof() ) .And. DE1->(DE1_FILIAL+DE1_CODLAY+DE1_CODREG) == xFilial("DE9")+cChave551
				
				If AllTrim(DE1->DE1_CAMPO) == "NR_SEQ"       //001
					AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(1,DE1->DE1_LAYTAM)})
					
				ElseIf AllTrim(DE1->DE1_CAMPO) == "TP_REG"   //002
					AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,"551"})
					
				ElseIf AllTrim(DE1->DE1_CAMPO) == "CD_UNI_DES" // 003
					AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,BRJ->BRJ_OPEORI})
					
				ElseIf AllTrim(DE1->DE1_CAMPO) == "CD_UNI_ORI"   //004
					AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,PLSINTPAD() } )
					
				ElseIf AllTrim(DE1->DE1_CAMPO) == "DT_GERACAO"   //005
					AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,DtoS(dDataBase) } )
					
				ElseIf AllTrim(DE1->DE1_CAMPO) == "CD_UNI_CRE"   //006
					AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,BRJ->BRJ_OPEORI } )
					
				ElseIf AllTrim(DE1->DE1_CAMPO) == "RESERVADO"    //007
					AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Space(DE1->(DE1_LAYTAM+DE1_LAYDEC))})
					
				ElseIf AllTrim(DE1->DE1_CAMPO) == "RESERVADO"    //008
					AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Space(DE1->(DE1_LAYTAM+DE1_LAYDEC))})
										
				ElseIf AllTrim(DE1->DE1_CAMPO) == Iif(!bCodLayPLS,"DT_VENC_FA","DT_VEN_DA1")//009
					If BRJ->BRJ_TPCOB == '2' .Or. BRJ->BRJ_TPCOB == '3' .Or. Empty(BRJ->BRJ_TPCOB)
						AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,dtos(BRJ->BRJ_DTVENC)})
					Else
						AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Space(8)})
					EndIf
					
				ElseIf AllTrim(DE1->DE1_CAMPO) == Iif(!bCodLayPLS,"VL_TOT_FAT","VL_TOT_DA1")  //010
					If (BRJ->BRJ_TPCOB == '2' .Or. BRJ->BRJ_TPCOB == '3' .Or. Empty(BRJ->BRJ_TPCOB))
						If !bCodLayPLS .And. SE2->( MsSeek(xFilial("SE2")+Alltrim(BRJ->(BRJ_PRESE2+BRJ_NUMSE2+BRJ_PARSE2+BRJ_TIPSE2)) ))
							AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(SE2->E2_VALOR*100,DE1->(DE1_LAYTAM+DE1_LAYDEC) ) } )
						Else
							AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(BRJ->BRJ_VLRFAT*100,DE1->(DE1_LAYTAM+DE1_LAYDEC) ) } )
						EndIf
					Else
						AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Replicate("0",DE1->(DE1_LAYTAM+DE1_LAYDEC) ) } )
					EndIf
					
				ElseIf AllTrim(DE1->DE1_CAMPO) == Iif(!bCodLayPLS,"VL_TOT_CON","VL_CON_DA1")//011
					cCodImp := BRJ->BRJ_CODIGO
					BAF->(DbSetOrder(2))
					BAF->(dbSeek(xFilial("BAF")+cCodImp))
					If (BRJ->BRJ_TPCOB == '3')
						AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(BAF->BAF_VLTXGL*100,DE1->(DE1_LAYTAM+DE1_LAYDEC))} )
					ElseIf (BRJ->BRJ_TPCOB == '2' .Or. Empty(BRJ->BRJ_TPCOB))
						AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(BAF->BAF_VLRGLO*100,DE1->(DE1_LAYTAM+DE1_LAYDEC))} )
					Else
						AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Replicate("0",DE1->(DE1_LAYTAM+DE1_LAYDEC))} )
					EndIf
				ElseIf AllTrim(DE1->DE1_CAMPO) == "VL_TOT_ACO" //012
					AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(0,DE1->(DE1_LAYTAM+DE1_LAYDEC) ) } )
				ElseIf AllTrim(DE1->DE1_CAMPO) == "TP_ARQUIVO" //013
					AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,"1"})
				ElseIf AllTrim(DE1->DE1_CAMPO) == "NR_VER_TRA" //014
					AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,"07"})
				ElseIf AllTrim(DE1->DE1_CAMPO) == Iif(!bCodLayPLS,"VL_TOT_PAG","VL_TOT_PA1")//015
					If (BRJ->BRJ_TPCOB == '2' .Or. BRJ->BRJ_TPCOB == '3' .Or. Empty(BRJ->BRJ_TPCOB)) .And. SE2->( MsSeek(xFilial("SE2")+Alltrim(BRJ->(BRJ_PRESE2+BRJ_NUMSE2+BRJ_PARSE2+BRJ_TIPSE2)) ));
						.and. !empty(Alltrim(BRJ->(BRJ_PRESE2+BRJ_NUMSE2+BRJ_PARSE2+BRJ_TIPSE2)))
						AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(SE2->E2_VALOR*100,DE1->(DE1_LAYTAM+DE1_LAYDEC))})
					Else
						AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Replicate("0",DE1->(DE1_LAYTAM+DE1_LAYDEC))})
					EndIf
				ElseIf AllTrim(DE1->DE1_CAMPO) == Iif(!bCodLayPLS,"NR_DOCUMEN","NR_NDC_1")//016
					If BRJ->BRJ_TPCOB == '2' .Or. BRJ->BRJ_TPCOB == '3' .Or. Empty(BRJ->BRJ_TPCOB)
						AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Strzero(0,(DE1->(DE1_LAYTAM+DE1_LAYDEC)))})
					Else
						AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Replicate("0",(DE1->(DE1_LAYTAM+DE1_LAYDEC)))})
					EndIf
				ElseIf AllTrim(DE1->DE1_CAMPO) == Iif(!bCodLayPLS,"DT_VENC_DO","DT_VEN_ND1")//017
					AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Space(DE1->(DE1_LAYTAM+DE1_LAYDEC))})
				ElseIf AllTrim(DE1->DE1_CAMPO) == "ST_CONCLUS"//018
					AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,"0"})
				ElseIf AllTrim(DE1->DE1_CAMPO) == "TP_COBA500"//019
					AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,IIf(Empty(BRJ->BRJ_TPCOB),"2",BRJ->BRJ_TPCOB)})
					
				ElseIf AllTrim(DE1->DE1_CAMPO) == "RESERVADO"//020
					AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Space(DE1->(DE1_LAYTAM+DE1_LAYDEC))})
					
				ElseIf AllTrim(DE1->DE1_CAMPO) == Iif(!bCodLayPLS,"DT_VEN_NDC","DT_VEN_DA2")//021
					If BRJ->BRJ_TPCOB == '1' .Or. BRJ->BRJ_TPCOB == '3'
						AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,dtos(BRJ->BRJ_DTVNDC)})
					Else
						AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Space(8)})
					EndIf
					
				ElseIf AllTrim(DE1->DE1_CAMPO) == Iif(!bCodLayPLS,"VL_TOT_NDC","VL_TOT_DA2")//022
					If BRJ->BRJ_TPCOB == '1' .Or. BRJ->BRJ_TPCOB == '3'
						AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(BRJ->BRJ_VLRNDC*100,DE1->(DE1_LAYTAM+DE1_LAYDEC))})
					Else
						AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Replicate("0",DE1->(DE1_LAYTAM+DE1_LAYDEC))})
					EndIf
					
				ElseIf AllTrim(DE1->DE1_CAMPO) == Iif(!bCodLayPLS,"VL_TOTCNDC","VL_CON_DA2")//023
					If BRJ->BRJ_TPCOB == '1' .Or. BRJ->BRJ_TPCOB == '3' .And. SE1->( MsSeek(xFilial("SE1")+Alltrim(BRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+BRJ_TIPNDC))))
						AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(BAF->BAF_VLRGLO*100,DE1->(DE1_LAYTAM+DE1_LAYDEC))} )
					Else
						AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Replicate("0",DE1->(DE1_LAYTAM+DE1_LAYDEC))} )
					EndIf
					
				ElseIf AllTrim(DE1->DE1_CAMPO) == Iif(!bCodLayPLS,"VL_TOTPNDC","VL_TOT_DA2")//024
					If BRJ->BRJ_TPCOB == '1' .Or. BRJ->BRJ_TPCOB == '3' .And. SE2->( MsSeek(xFilial("SE2")+Alltrim(BRJ->(BRJ_PREE2N+BRJ_NUME2N+BRJ_PARE2N+BRJ_TIPE2N)) ))
						AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(SE2->E2_VALOR*100,DE1->(DE1_LAYTAM+DE1_LAYDEC))})
					Else
						AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Replicate("0",DE1->(DE1_LAYTAM+DE1_LAYDEC))})
					EndIf
					
				ElseIf AllTrim(DE1->DE1_CAMPO) == Iif(!bCodLayPLS,"NR_DOC2","NR_NDC_2")//025
					//****************** TRATAR CAMPO *********************
					AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Iif(!Empty(BRJ->BRJ_NUMNDC),StrZero(Val(BRJ->BRJ_NUMNDC),DE1->(DE1_LAYTAM+DE1_LAYDEC)),Replicate("0",DE1->(DE1_LAYTAM+DE1_LAYDEC)))})
					
				ElseIf AllTrim(DE1->DE1_CAMPO) == "DT_VEN_ND2"//026
					//****************** TRATAR CAMPO *********************
					AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Space(8)})
					
				ElseIf AllTrim(DE1->DE1_CAMPO) == Iif(!bCodLayPLS,"NR_FATURA","NR_DOC_1_A")     //027
					If !Empty(BRJ->BRJ_NUMFAT)
						AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,BRJ->BRJ_NUMFAT})
					Else
						AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Space(20)})
					EndIf
					
				ElseIf AllTrim(DE1->DE1_CAMPO) == Iif(!bCodLayPLS,"NR_NDCA500","NR_DOC_2_A") //028
					If !Empty(BRJ->BRJ_NRNDC)
						AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,BRJ->BRJ_NRNDC})
					Else
						AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,Space(20)})
					EndIf
					
				ElseIf AllTrim(DE1->DE1_CAMPO) == "TP_ARQ_PAR"// 029
					AaDd(aReg551,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,"0"})
					
				Endif
				
				// Proximo																
				
				DE1->( DbSkip() )
			Enddo
		Else
			AaDd( aCriticas, {"11",STR0025} ) //"Valor de Glosa nao encontrado em BD6."
		Endif
	Endif
Endif

// Verifica se tem criticas											

If Len(aCriticas) > 0
	aRet := {.F.,aCriticas}
Else
	
	// Verifica se existe 	registro											
	
	If Len(aReg552) > 0
		
		// Area de trabalho													     ³
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		// TEMPORARIO 551     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aadd(aStru551,{"CHAVE","C",022,0})
		aadd(aStru551,{"CAMPO" ,"C",262,0})
	
		//--< Criação do objeto FWTemporaryTable >---
		oTempR51 := FWTemporaryTable():New( "R51" )
		oTempR51:SetFields( aStru551 )
		oTempR51:AddIndex( "INDR51",{ "CHAVE" } )
		
		if( select( "R51" ) > 0 )
			R51->( dbCloseArea() )
		endIf
		
		oTempR51:Create()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		// TEMPORARIO 552     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aadd(aStru552,{"CHAVE","N",10,0})
		aadd(aStru552,{"CAMPO" ,"C",652,0})
		
		//--< Criação do objeto FWTemporaryTable >---
		oTempR52 := FWTemporaryTable():New( "R52" )
		oTempR52:SetFields( aStru552 )
		oTempR52:AddIndex( "INDR52",{ "CHAVE" } )
		
		if( select( "R52" ) > 0 )
			R52->( dbCloseArea() )
		endIf
		
		oTempR52:Create()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		// TEMPORARIO 553     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aadd(aStru553,{"CHAVE","N",10,0})
		aadd(aStru553,{"CAMPO" ,"C",515,0})
		
		//--< Criação do objeto FWTemporaryTable >---
		oTempR53 := FWTemporaryTable():New( "R53" )
		oTempR53:SetFields( aStru553 )
		oTempR53:AddIndex( "INDR53",{ "CHAVE" } )
		
		if( select( "R53" ) > 0 )
			R53->( dbCloseArea() )
		endIf
		
		oTempR53:Create()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		// TEMPORARIO 557     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		aadd(aStru557,{"CHAVE","N",10,0})
		aadd(aStru557,{"CAMPO" ,"C",143,0})
		
		//--< Criação do objeto FWTemporaryTable >---
		oTempR57 := FWTemporaryTable():New( "R57" )
		oTempR57:SetFields( aStru557 )
		oTempR57:AddIndex( "INDR57",{ "CHAVE" } )
		
		if( select( "R57" ) > 0 )
			R57->( dbCloseArea() )
		endIf
		
		oTempR57:Create()
		
		// TEMPORARIO 558
		
		aadd(aStru558,{"CHAVE","N",10,0})
		aadd(aStru558,{"CAMPO" ,"C",304,0})
		
		//--< Criação do objeto FWTemporaryTable >---
		oTempR58 := FWTemporaryTable():New( "R58" )
		oTempR58:SetFields( aStru558 )
		oTempR58:AddIndex( "INDR58",{ "CHAVE" } )
		
		if( select( "R58" ) > 0 )
			R58->( dbCloseArea() )
		endIf
		
		oTempR58:Create()
		
		
		// TEMPORARIO R5R													         ³
		
		aadd(aStruR5R,{"CHAVE","C",8,0})
		aadd(aStruR5R,{"CAMPO","C",515,0})

		//--< Criação do objeto FWTemporaryTable >---
		oTempR5R := FWTemporaryTable():New( "R5R" )
		oTempR5R:SetFields( aStruR5R )
		oTempR5R:AddIndex( "INDR5R",{ "CHAVE" } )
		
		if( select( "R5R" ) > 0 )
			R5R->( dbCloseArea() )
		endIf
		
		oTempR5R:Create()
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		// TEMPORARIO 559     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aadd(aStru559,{"CHAVE","C",022,0})
		aadd(aStru559,{"CAMPO" ,"C",82,0})
		
		//--< Criação do objeto FWTemporaryTable >---
		oTempR59 := FWTemporaryTable():New( "R59" )
		oTempR59:SetFields( aStru559 )
		oTempR59:AddIndex( "INDR59",{ "CHAVE" } )
		
		if( select( "R59" ) > 0 )
			R59->( dbCloseArea() )
		endIf
		
		oTempR59:Create()
		
		
		// Header
		
		cDado := ""
		For nFor := 1 To Len(aReg551)
			cDado += aReg551[nFor,4]
			
			// Informacoes do cabecalho											
			
			Do Case
			Case AllTrim(aReg551[nFor,3]) == 'DT_GERACAO'	//B2A_DTGERA
				cDatGer := aReg551[nFor,4]
			Case AllTrim(aReg551[nFor,3]) == 'VL_TOT_FAT'	//B2A_VLTOTF
				nVlrTFa := Val(aReg551[nFor,4])/100
			Case AllTrim(aReg551[nFor,3]) == 'CD_UNI_ORI'	//B2A_CODOPE
				cOpeOri := aReg551[nFor,4]
			Case AllTrim(aReg551[nFor,3]) == 'CD_UNI_DES'	//B2A_OPEDES
				cOpeDes := aReg551[nFor,4]
			Case AllTrim(aReg551[nFor,3]) == Iif(!bCodLayPLS,"NR_FATURA","NR_DOC_1_A")	//B2A_NUMTIT
				cNumFat := aReg551[nFor,4]
			Case AllTrim(aReg551[nFor,3]) == 'TP_ARQUIVO'	//B2A_TPARQ
				cTpArq  := aReg551[nFor,4]
			EndCase
		Next
		
		// Questionamento	e preparação para o 559	        					     ³
		
		nVlrTotCob:=0
		nVlrTotRec:=0
		nVlrTotAco:=0
		nVlrTotAcoTx:=0
		nRecTot552:=0
		For nFor := 1 To Len(aReg552)
			cDado 	  := ""
			cChaveBD6 := aReg552[nFor,3]
			
			// For de registros													     ³
			
			For nFor2 := 1 To Len(aReg552[nFor,2])
				cDado += aReg552[nFor,2,nFor2,4]
				
				// Pega informacoes do Registro										     ³
				
				Do Case
				Case AllTrim(aReg552[nFor,2,nFor2,3]) == 'NR_NOTA' //B2A_NOTA
					cNumNota := aReg552[nFor,2,nFor2,4]
				Case AllTrim(aReg552[nFor,2,nFor2,3]) == 'NR_LOTE' //B2A_LOTE
					cNumLote := aReg552[nFor,2,nFor2,4]
				Case AllTrim(aReg552[nFor,2,nFor2,3]) == 'NR_ID_ORIG'//B2A_SEQUEN
					nIdOri := aReg552[nFor,2,nFor2,4]
				Case AllTrim(aReg552[nFor,2,nFor2,3]) == 'ID_BENEF' //B2A_MATRIC
					cMatric := aReg552[nFor,2,nFor2,4]
				Case AllTrim(aReg552[nFor,2,nFor2,3]) == 'DT_ATEND' //B2A_DATATE
					cDatAtn  := aReg552[nFor,2,nFor2,4]
				Case AllTrim(aReg552[nFor,2,nFor2,3]) == 'CD_MOT_QUE' //B2A_CODQUE
					cCodQue  := aReg552[nFor,2,nFor2,4]
				Case AllTrim(aReg552[nFor,2,nFor2,3]) == 'DS_MOT_QUE' //B2A_COMQUE
					cDesQue  := aReg552[nFor,2,nFor2,4]
				Case AllTrim(aReg552[nFor,2,nFor2,3]) == 'TP_TABELA' //B2A_CODPAD
					cCodPad  := aReg552[nFor,2,nFor2,4]
				Case AllTrim(aReg552[nFor,2,nFor2,3]) == 'CD_SERVICO' //B2A_CODPRO
					cCodPro  := aReg552[nFor,2,nFor2,4]
				Case AllTrim(aReg552[nFor,2,nFor2,3]) == 'DT_ACORDO' //B2A_DATACO
					cDtAcor  := aReg552[nFor,2,nFor2,4]
				Case AllTrim(aReg552[nFor,2,nFor2,3]) == 'TP_ACORDO' //B2A_STAACO
					cTpAcord  := AllTrim( Str( Val( aReg552[nFor,2,nFor2,4] ) ) )
					// somando o 559 VL_TOT_COB
				Case AllTrim(aReg552[nFor,2,nFor2,3]) == "VL_COBRADO" //013
					If !aReg552[nFor][5] // caso for .f. Ha glosa a ser contestada
						nVlrTotCob += Val(aReg552[nFor,2,nFor2,4])
						nRecTot552++
					Endif
				Case AllTrim(aReg552[nFor,2,nFor2,3]) == "VL_COBR_CO" 	//21
					If !aReg552[nFor][5]   // caso for .f. Ha glosa a ser contestada
						nVlrTotCob += Val(aReg552[nFor,2,nFor2,4])
					Endif
				Case AllTrim(aReg552[nFor,2,nFor2,3]) == "VL_COB_FI"  //24
					If !aReg552[nFor][5]	 // caso for .f. Ha glosa a ser contestada
						nVlrTotCob += Val(aReg552[nFor,2,nFor2,4])
					Endif
				Case AllTrim(aReg552[nFor,2,nFor2,3]) == "VL_CB_AD_S" //27
					If !aReg552[nFor][5]	 // caso for .f. Ha glosa a ser contestada
						nVlrTotCob += Val(aReg552[nFor,2,nFor2,4])
					Endif
				Case AllTrim(aReg552[nFor,2,nFor2,3]) == "V_CB_AD_CO" //30
					If !aReg552[nFor][5]	 // caso for .f. Ha glosa a ser contestada
						nVlrTotCob += Val(aReg552[nFor,2,nFor2,4])
					Endif
				Case AllTrim(aReg552[nFor,2,nFor2,3]) == "V_CB_AD_FI" //33
					If !aReg552[nFor][5]	 // caso for .f. Ha glosa a ser contestada
						nVlrTotCob += Val(aReg552[nFor,2,nFor2,4])
					Endif
					
					// somando o 559 VL_TOT_RECONH
				Case AllTrim(aReg552[nFor,2,nFor2,3]) == "VL_RECONHE" //014
					If !aReg552[nFor][5]	 // caso for .f. Ha glosa a ser contestada
						nVlrTotRec+= Val(aReg552[nFor,2,nFor2,4])
					Endif
				Case AllTrim(aReg552[nFor,2,nFor2,3]) == "VL_RECO_CO" //22
					If !aReg552[nFor][5]	 // caso for .f. Ha glosa a ser contestada
						nVlrTotRec+= Val(aReg552[nFor,2,nFor2,4])
					Endif
				Case AllTrim(aReg552[nFor,2,nFor2,3]) == "VL_RECO_FI" //25
					If !aReg552[nFor][5]	 // caso for .f. Ha glosa a ser contestada
						nVlrTotRec+= Val(aReg552[nFor,2,nFor2,4])
					Endif
				Case AllTrim(aReg552[nFor,2,nFor2,3]) == "VL_RE_AD_S" //28
					If !aReg552[nFor][5]	 // caso for .f. Ha glosa a ser contestada
						nVlrTotRec+= Val(aReg552[nFor,2,nFor2,4]) 
					Endif
				Case AllTrim(aReg552[nFor,2,nFor2,3]) == "V_RE_AD_CO" //31
					If !aReg552[nFor][5]	 // caso for .f. Ha glosa a ser contestada
						nVlrTotRec+= Val(aReg552[nFor,2,nFor2,4])
					Endif
				Case AllTrim(aReg552[nFor,2,nFor2,3]) == "V_RC_AD_FI" //34
					If !aReg552[nFor][5]	 // caso for .f. Ha glosa a ser contestada
						nVlrTotRec+= Val(aReg552[nFor,2,nFor2,4])
					Endif
					
					
					// somando o 559 VL_TOT_ACO alteracao
				Case AllTrim(aReg552[nFor,2,nFor2,3]) == "VL_ACORDO"   //15
					If !aReg552[nFor][5]	 // caso for .f. Ha glosa a ser contestada
						nVlrTotAco+= Val(aReg552[nFor,2,nFor2,4])
					Endif
				Case AllTrim(aReg552[nFor,2,nFor2,3]) == "VL_ACOR_CO"  //23
					If !aReg552[nFor][5]	 // caso for .f. Ha glosa a ser contestada
						nVlrTotAco+= Val(aReg552[nFor,2,nFor2,4])
					Endif
				Case AllTrim(aReg552[nFor,2,nFor2,3]) == "VL_ACOR_FI"  //26
					If !aReg552[nFor][5]
						nVlrTotAco+= Val(aReg552[nFor,2,nFor2,4])
					Endif
					
					// somando o 559 VL_TOT_ACO_TAXA
				Case AllTrim(aReg552[nFor,2,nFor2,3]) == "V_ACO_AD_S" //29
					If !aReg552[nFor][5]
						nVlrTotAcoTx+= Val(aReg552[nFor,2,nFor2,4])
					Endif
				Case AllTrim(aReg552[nFor,2,nFor2,3]) == "V_ACD_A_CO" //32
					If !aReg552[nFor][5]
						nVlrTotAcoTx+= Val(aReg552[nFor,2,nFor2,4])
					Endif
				Case AllTrim(aReg552[nFor,2,nFor2,3]) == "V_ACD_A_FI" //35
					If !aReg552[nFor][5]
						nVlrTotAcoTx+= Val(aReg552[nFor,2,nFor2,4])
					EndiF
				EndCase
			Next nFor2
			
			// Grava																
			
			R52->( RecLock("R52",.T.) )
			R52->CHAVE := aReg552[nFor,1]
			R52->CAMPO := cDado
			R52->( MsUnLock() )
			
			
			// R553																     ³
			
			For nForx:=1 to Len(aReg553)
				cDado := ""
				If aReg552[nFor,4]=aReg553[nForx,Len(aReg553[nForx]),1] .or. nTipo = 2
					For nFory := 1 To (Len(aReg553[nForx])-1)
						cDado += aReg553[nForx,nFory,4]
					Next nFory
					
					// Grava																
					
					R53->( RecLock("R53",.T.) )
					R53->CHAVE := aReg552[nFor,1]
					R53->CAMPO := cDado
					R53->( MsUnLock() )
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ`¿
				//Gerando o Tipo 5 para os testes pos quem gera o tipo 5 é o WST como nao temos acesso³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ`Ù
				If nTipo = 2
					Exit
				Endif
			Next nForx
			
			// Gravacao dos registro na tabela										     ³
			
			B2A->( DbSetOrder(1) ) //B2A_FILIAL + B2A_OPEDES + B2A_NUMTIT + B2A_SEQUEN
			If !B2A->( MsSeek( xFilial("B2A")+cOpeDes+cNumFat ) )
				B2A->( RecLock("B2A",.T.) )
				B2A->B2A_FILIAL := xFilial("B2A")
				B2A->B2A_CODOPE := cOpeOri
				B2A->B2A_OPEDES := cOpeDes
				B2A->B2A_NUMTIT := cNumFat
				B2A->B2A_NOTA   := cNumNota
				B2A->B2A_MATRIC := cMatric
				B2A->B2A_DATATE := StoD(cDatAtn)
				B2A->B2A_CODPAD := cCodPad
				B2A->B2A_CODPRO := cCodPro
				B2A->B2A_VALCOB := nVlrTotCob/100
				B2A->B2A_VALREC := nVlrTotRec/100
				B2A->B2A_DATACO := StoD(cDtAcor)
				B2A->B2A_STAACO := AllTrim(Str(Val(Iif(ValType(cTpAcord)=='U','0', cTpAcord ) )) )
				B2A->B2A_DTGERA := StoD(cDatGer)
				B2A->B2A_DTEMFA := StoD(cDatGer)
				B2A->B2A_VLTOTF := nVlrTFa
				B2A->B2A_NTOTRE := nTotReg
				B2A->B2A_VLTCOB := nVlrTotCob/100
				B2A->B2A_VLTREQ := nVlrTotRec/100
				B2A->B2A_TPARQ  := cTpArq
				B2A->B2A_DTEXIP := dDataBase
				B2A->B2A_CHKBD6 := cChaveBD6 //BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN + BD6_CODPAD + BD6_CODPRO
				B2A->( MsUnLock() )
			EndIf
		Next
		
		// Header																     ³
		
		cDado := ""
		For nFor := 1 To Len(aReg551)
			
			// Informacoes do cabecalho											
			
			Do Case
			Case AllTrim(aReg551[nFor,3]) == 'DT_GERACAO'	//B2A_DTGERA
				cDatGer := aReg551[nFor,4]
			Case AllTrim(aReg551[nFor,3]) == 'VL_TOT_FAT'	//B2A_VLTOTF
				nVlrTFa := Val(aReg551[nFor,4])/100
			Case AllTrim(aReg551[nFor,3]) == 'CD_UNI_ORI'	//B2A_CODOPE
				cOpeOri := aReg551[nFor,4]
			Case AllTrim(aReg551[nFor,3]) == 'CD_UNI_DES'	//B2A_OPEDES
				cOpeDes := aReg551[nFor,4]
			Case AllTrim(aReg551[nFor,3]) == Iif(!bCodLayPLS,"NR_FATURA","NR_DOC_1_A")	//B2A_NUMTIT
				cNumFat := aReg551[nFor,4]
			Case AllTrim(aReg551[nFor,3]) == 'TP_ARQUIVO'	//B2A_TPARQ
				cTpArq  := aReg551[nFor,4]
			EndCase
			cDado += aReg551[nFor,4]
		Next
		
		
		// Grava																
		
		R51->( RecLock("R51",.T.) )
		R51->CAMPO := cDado
		R51->( MsUnLock() )

		
		// Monta R559 (Trailer)...                                       
		
		DE1->( DbGoTo(nRegDE1559) )
		
		// While																
		
		aReg559:={}
		While ! DE1->( Eof() ) .And. DE1->(DE1_FILIAL+DE1_CODLAY+DE1_CODREG) == xFilial("DE9")+cChave559
			
			If  AllTrim(DE1->DE1_CAMPO) == "NR_SEQ"
				AaDd(aReg559,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(nNumSeq++,DE1->DE1_LAYTAM)})
			ElseIf AllTrim(DE1->DE1_CAMPO) == "TP_REG"
				AaDd(aReg559,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,"559"})
			ElseIf AllTrim(DE1->DE1_CAMPO) == "QT_TOTR552" //003
				AaDd(aReg559,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero( Len(aReg552),DE1->DE1_LAYTAM)})
			ElseIf AllTrim(DE1->DE1_CAMPO) == "VL_TOT_COB" //004
				AaDd(aReg559,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero( nVlrTotCob,DE1->(DE1_LAYTAM+DE1_LAYDEC) ) } )
			ElseIf AllTrim(DE1->DE1_CAMPO) == "VL_TOT_REQ" //005
				AaDd(aReg559,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero( nVlrTotRec,DE1->(DE1_LAYTAM+DE1_LAYDEC) ) } )
			ElseIf AllTrim(DE1->DE1_CAMPO) == "VL_TOT_ACO"  //006
				AaDd(aReg559,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(nVlrTotAco,DE1->(DE1_LAYTAM+DE1_LAYDEC) ) } )
			ElseIf AllTrim(DE1->DE1_CAMPO) == "VL_T_ACOTX"	 //007
				AaDd(aReg559,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(nVlrTotAcoTx,DE1->(DE1_LAYTAM+DE1_LAYDEC)) } )
			ElseIf AllTrim(DE1->DE1_CAMPO) == "QT_TOTR557"	 //008
				AaDd(aReg559,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(nTotR507,DE1->(DE1_LAYTAM+DE1_LAYDEC)) } )
		   	ElseIf AllTrim(DE1->DE1_CAMPO) == "QT_TOTR558"	 //009
		   		AaDd(aReg559,{DE1->DE1_CODLAY,DE1->DE1_CODREG,DE1->DE1_CAMPO,StrZero(nTotR508,DE1->(DE1_LAYTAM+DE1_LAYDEC)) } )
			Endif
			
			// Proximo																     ³
			
			DE1->( DbSkip() )
		Enddo
		
		// Trailer																     ³
		
		cDado := ""
		For nFor := 1 To Len(aReg559)
			cDado += aReg559[nFor,4]
		Next
		
		// Grava																
		
		R59->( RecLock("R59",.T.) )
		R59->CAMPO := cDado
		R59->( MsUnLock() )
		
		If nTipo == 1
			R59->( DbGoTop() )
			
			// Tratamento para docs com tamanho inferior a 7 caracteres			
			
			If BRJ->BRJ_TPCOB <> "1"
				If len(Alltrim(BRJ->BRJ_NUMFAT)) < 7 
					cFileGerado := cDirFile+"NC1_"+ Replicate("_",7-len(Alltrim(BRJ->BRJ_NUMFAT)))+Alltrim(BRJ->BRJ_NUMFAT)+"."+SubStr(BRJ->BRJ_CODOPE, 2, 3)
					cArqNom		:= "NC1_"+ Replicate("_",7-len(Alltrim(BRJ->BRJ_NUMFAT)))+Alltrim(BRJ->BRJ_NUMFAT)+"."+Strzero(Val(PLSINTPAD()),3)
				Else
					cFileGerado := cDirFile+"NC1_"+IIf(BRJ->BRJ_TPCOB <> "1",SubStr(Alltrim(BRJ->BRJ_NUMFAT), Len(Alltrim(BRJ->BRJ_NUMFAT)) - 6, 7),SubStr(Alltrim(BRJ->BRJ_NRNDC), Len(Alltrim(BRJ->BRJ_NRNDC)) - 6, 7))+"."+SubStr(BRJ->BRJ_CODOPE, 2, 3)
					cArqNom		:= "NC1_"+IIf(BRJ->BRJ_TPCOB <> "1",SubStr(Alltrim(BRJ->BRJ_NUMFAT), Len(Alltrim(BRJ->BRJ_NUMFAT)) - 6, 7),SubStr(Alltrim(BRJ->BRJ_NRNDC), Len(Alltrim(BRJ->BRJ_NRNDC)) - 6, 7))+"."+Strzero(Val(PLSINTPAD()),3)
				EndIf
			Else  
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				// Para a versao 7.0 nao e permitido o envio do Tipo 1 mas foi mantida a condicao ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If len(Alltrim(BRJ->BRJ_NRNDC)) < 7 
					cFileGerado := cDirFile+"NC1_"+ Replicate("_",7-len(Alltrim(BRJ->BRJ_NRNDC)))+Alltrim(BRJ->BRJ_NRNDC)+"."+SubStr(BRJ->BRJ_CODOPE, 2, 3)
					cArqNom		:= "NC1_"+ Replicate("_",7-len(Alltrim(BRJ->BRJ_NRNDC)))+Alltrim(BRJ->BRJ_NRNDC)+"."+Strzero(Val(PLSINTPAD()),3)
				Else
					cFileGerado := cDirFile+"NC1_"+IIf(BRJ->BRJ_TPCOB <> "1",SubStr(Alltrim(BRJ->BRJ_NRNDC), Len(Alltrim(BRJ->BRJ_NRNDC)) - 6, 7),SubStr(Alltrim(BRJ->BRJ_NRNDC), Len(Alltrim(BRJ->BRJ_NRNDC)) - 6, 7))+"."+SubStr(BRJ->BRJ_CODOPE, 2, 3)
					cArqNom		:= "NC1_"+IIf(BRJ->BRJ_TPCOB <> "1",SubStr(Alltrim(BRJ->BRJ_NRNDC), Len(Alltrim(BRJ->BRJ_NRNDC)) - 6, 7),SubStr(Alltrim(BRJ->BRJ_NRNDC), Len(Alltrim(BRJ->BRJ_NRNDC)) - 6, 7))+"."+Strzero(Val(PLSINTPAD()),3)
				EndIf
			EndIf
		Else    
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			// Tratativa para BTO                                                  
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			R59->( DbGoTop() ) 
			If len(Alltrim(BTO->BTO_NUMTIT)) < 7
				cFileGerado := cDirFile+"NC1_"+Replicate("_",7-len(Alltrim(BTO->BTO_NUMTIT)))+Alltrim(BTO->BTO_NUMTIT)+"."+SubStr(BTO->BTO_CODOPE, 2, 3)
				cArqNom		:= "NC1_"+Replicate("_",7-len(Alltrim(BTO->BTO_NUMTIT)))+Alltrim(BTO->BTO_NUMTIT)+"."+Strzero(Val(PLSINTPAD()),3)	
			Else
				cFileGerado := cDirFile+"NC1_"+SubStr(Alltrim(BTO->BTO_NUMTIT), Len(Alltrim(BTO->BTO_NUMTIT)) - 6, 7)+"."+SubStr(BTO->BTO_CODOPE, 2, 3)
				cArqNom		:= "NC1_"+SubStr(Alltrim(BTO->BTO_NUMTIT), Len(Alltrim(BTO->BTO_NUMTIT)) - 6, 7)+"."+Strzero(Val(PLSINTPAD()),3)	
			EndIf
		Endif  
		
		// Grava																
		
		//		Copy To &cFileGerado SDF
		R52->(DbGoTop())
		If  ! R52->(EOF())
			PTULn("551",.T.)
			PlsPTU(padr(mv_par02,6),cArqNom,cDirFile)
		Endif
		
		if( select( "R51" ) > 0 )
			oTempR51:delete()
		endIf
		
		if( select( "R52" ) > 0 )
			oTempR52:delete()
		endIf
		
		if( select( "R53" ) > 0 )
			oTempR53:delete()
		endIf
		
		if( select( "R59" ) > 0 )
			oTempR59:delete()
		endIf

		if( select( "R57" ) > 0 )
			oTempR57:delete()
		endIf

		if( select( "R58" ) > 0 )
			oTempR58:delete()
		endIf
		
		if( select( "R5R" ) > 0 )
			oTempR5R:delete()
		endIf
		
		// Retorno																     ³
		
		aRet := { .T.,cFileGerado }
	Endif
Endif

Return(aRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³BuscaGuias³ Autor ³  Alexander Santos   ³ Data ³ 03.01.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cria matriz												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function BuscaGuias(nTipo)
local cCodGlo
local cDesGlo
local nGlosa		:= 0
local cSQL
local aRecnos 		:= {}
local nTotal    	:= 0
local nTotRec   	:= 0
local nVlrApr   	:= 0
local lGlosaTot		:= .F.
local lCopFil   	:= .F.
local nVlrCOPApr	:= 0 // valor apresentado Custo op
local nVlrFILApr	:= 0 // valor apresentado filme
local nVlrSRVApr	:= 0 // valor apresentado Serviço
local nVlrCOPCtr	:= 0 // valor contratado Custo OP
local nVlrFILCtr	:= 0 // valor contratado Filme
local nVlrSRVCtr	:= 0 // valor contratado serviço
local nVlrTxApSRV	:= 0 // valor Tx Adm Serviço apresentado
local nVlrTxApCOP	:= 0 // valor Tx Adm Custo	 apresentado
local nVlrTxApFIL	:= 0 // valor Tx Adm Filme	 apresentado
local nVlrTxCtSRV	:= 0 // valor Tx Adm Serviço contratado
local nVlrTxCtCOP	:= 0 // valor Tx Adm Custo	 contratado
local nVlrTxCtFIL	:= 0 // valor Tx Adm Filme	 contratado
local cCodSeqAnt	:= ""
local nRecBD7		:= 0
local nVlReconhece	:= 0
local nVlrApAjs		:= 0
local nVlrAdSeAj	:= 0
local nVlTotPagar	:= 0


aBct553    :={}

// Select																

If nTipo = 1
	
	cSQL := "SELECT BD6.R_E_C_N_O_ AS REG FROM " + RetSQLName("BD6") + " BD6 "
	cSQL += "WHERE BD6.BD6_FILIAL = '" + xFilial("BD6")  + "' AND "
	cSQL += "BD6.BD6_SEQIMP = '" + BRJ->BRJ_CODIGO + "' AND "
	cSQL += "BD6.D_E_L_E_T_ <> '*' AND "
	cSQL += "BD6.BD6_SITUAC <> '2' AND "
	cSQL += "BD6.BD6_NUMERO IN(SELECT BD6_NUMERO FROM "+RetSQLName("BD6")+" WHERE BD6_FILIAL = '"+xFilial("BD6")+"' AND BD6_SEQIMP = '" + BRJ->BRJ_CODIGO + "' AND D_E_L_E_T_ <> '*')  "
	cSQL += "ORDER BY BD6_FILIAL,BD6_CODOPE,BD6_CODLDP,BD6_CODPEG,BD6_NUMERO,BD6_SEQUEN,BD6_CODPAD,BD6_CODPRO"
	PLSQuery(cSQL,"Trb")
Else
	
	cSQL := "SELECT BD6.R_E_C_N_O_ AS REG FROM "+RetSQLName("BD6")+" BD6 "
	cSQL += "WHERE BD6.BD6_FILIAL = '" + xFilial("BD6")  + "' AND "
	If (BTO->BTO_TPMOV == '3' .And. BTO->BTO_TPCOB == '1') .Or. BTO->BTO_TPMOV == '1'
		cSQL += "BD6.BD6_PRENDC = '" + BTO->BTO_PREFIX + "' AND "
		cSQL += "BD6.BD6_NUMNDC = '" + BTO->BTO_NUMTIT + "' AND "
		cSQL += "BD6.BD6_PARNDC = '" + BTO->BTO_PARCEL + "' AND "
		cSQL += "BD6.BD6_TIPNDC = '" + BTO->BTO_TIPTIT + "' AND "
	Else
		cSQL += "BD6.BD6_PREFIX = '" + BTO->BTO_PREFIX + "' AND "
		cSQL += "BD6.BD6_NUMTIT = '" + BTO->BTO_NUMTIT + "' AND "
		cSQL += "BD6.BD6_PARCEL = '" + BTO->BTO_PARCEL + "' AND "
		cSQL += "BD6.BD6_TIPTIT = '" + BTO->BTO_TIPTIT + "' AND "
	EndIf
	cSQL += "BD6.BD6_FASE = '3'  AND "
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//somnte enviar o tipo 5 para os testes devido não termos acesso ao WST  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTipo = 2
		cSQL += "BD6.BD6_GUIORI <> ''  AND "
	Endif
	
	cSQL += "BD6.D_E_L_E_T_ <> '*' "
	
	
	cSQL += "ORDER BY BD6_FILIAL,BD6_CODOPE,BD6_CODLDP,BD6_CODPEG,BD6_NUMERO,BD6_SEQUEN,BD6_CODPAD,BD6_CODPRO"
	PLSQuery(cSQL,"Trb")
Endif

// Checa																

BD7->( DbSetOrder(1) )//BB7_FILIAL + BB7_CODIGO + BB7_DIA + BB7_HORENT
While !Trb->( Eof() )
	cCodGlo		:= ""
	cDesGlo		:= ""
	cCodQuest	:= "99"
	lGlosaTot 	:= .F.
	
	// Posiciona no bd6											   		
	
	BD6->( DbGoTo(Trb->REG) )
	
	// Verifica situacao													
	
	//If BD6->BD6_FASE == "4" .and. BD6->BD6_SITUAC == "1"
	lHaCritItens:=PlsVerCrtIt(nTipo)
	
	// Verifica critica	
	If lHaCritItens
		If BD6->BD6_FASE == "4" .and. BD6->BD6_SITUAC == "1"
			BDX->(DbSetOrder(1))//BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_CODPAD+BDX_CODPRO+BDX_SEQUEN+BDX_CODGLO
			If BDX->( MsSeek( xFilial("BDX")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CODPAD+BD6_CODPRO+BD6_SEQUEN) ) )
				While BDX->(!Eof()) .AND. BDX->BDX_FILIAL=xFilial("BDX") .AND. BDX->BDX_CODOPE=BD6->BD6_CODOPE .AND. BDX->BDX_CODLDP= BD6->BD6_CODLDP .AND. BDX->BDX_CODPEG=BD6->BD6_CODPEG .AND. BDX->BDX_NUMERO=BD6->BD6_NUMERO .AND. BDX->BDX_ORIMOV=BD6->BD6_ORIMOV .AND. BDX->BDX_CODPAD=BD6->BD6_CODPAD .AND. BDX->BDX_CODPRO=BD6->BD6_CODPRO .AND. BDX->BDX_SEQUEN=BD6->BD6_SEQUEN
					//BDX_ACAO = 1=Glosar;2=Reconsiderar
					If (BDX->BDX_ACAO == "1" .and. BDX->BDX_PERGLO == 100) .or. (BDX->BDX_ACAOTX == "1" .and. BDX->BDX_PERGTX == 100)
						cCodGlo 	:= BDX->BDX_CODGLO
						nGlosa  	:= BD6->BD6_VLRGLO
						cDesGlo		:= BDX->BDX_OBS
						lGlosaTot	:= .T.
						Exit
					ElseIf (BDX->BDX_ACAO == "1" .and. BDX->BDX_PERGLO < 100) .or. (BDX->BDX_ACAOTX == "1" .and. BDX->BDX_PERGTX < 100)
						cCodGlo 	:= BDX->BDX_CODGLO
						nGlosa  	:= BD6->BD6_VLRGLO
						cDesGlo		:= BDX->BDX_OBS
						lGlosaTot	:= .F.
						Exit
					ElseIf BDX->BDX_ACAO == "2"
						cCodGlo 	:= BDX->BDX_CODGLO
						nGlosa  	:= BD6->BD6_VLRGLO
						cDesGlo		:= BDX->BDX_OBS
						lGlosaTot	:= .F.
					Endif
					BDX->( DbSkip() )
				Enddo
			EndIf
		Endif
		
		// Pega o valor apresentado do bd7 									
		
		If BD7->( MsSeek( xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN) ) )
			While !BD7->( Eof() ) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
				
				cCodSeqAnt	:= Alltrim(BD7->BD7_SEQ500)
				nRecBD7		:= BD7->( Recno())
				
				If  BD7->BD7_VALORI > 0
					nVlrApr += BD7->BD7_VALORI
				Else
					nVlrApr += BD7->BD7_VLRBPR
				Endif
				
				nVlTotPagar += BD7->BD7_VLRPAG - BD7->BD7_VLTXPG
				nVlrApAjs := BD7->BD7_VLAPAJ
				nVlrAdSeAj := BD7->BD7_VLADSE
				If BD7->BD7_CODUNM $ "COP|COR"
					
					lCopFil		:= .T.
					nVlrAp500	:= BD7->BD7_VLAPAJ
					nVlrCOPApr	+= BD7->BD7_VALORI						// valor apresentado
					nVlrCOPCtr	+= BD7->BD7_VLRPAG - BD7->BD7_VLTXPG 	// valor Contratado
					nVlrTxApCOP	+= BD7->BD7_VLTXAP 						// valor Tx Adm Custo	 apresentado
					nVlrTxCtCOP	+= BD7->BD7_VLTXPG						// valor Tx Adm Serviço contratado
					
				ElseIf BD7->BD7_CODUNM ="FIL"
					
					lCopFil		:= .T.
					nVlrFILApr	+= BD7->BD7_VALORI						// valor apresentado
					nVlrFILCtr	+= BD7->BD7_VLRPAG - BD7->BD7_VLTXPG 	// valor Contratado
					nVlrTxApFIL	+= BD7->BD7_VLTXAP 						// valor Tx Adm Filme apresentado
					nVlrTxCtFil	+= BD7->BD7_VLTXPG				 		// valor Tx Adm Serviço contratado
					
				Else						
					nVlReconhece	+=	IIf(lGlosaTot,BD7->BD7_VLAPAJ,BD7->BD7_VLRPAG - BD7->BD7_VLTXPG)
					nVlrSRVApr	+= BD7->BD7_VALORI						// valor serviços
					nVlrSRVCtr	+= BD7->BD7_VLRPAG - BD7->BD7_VLTXPG 	// valor serviços
					nVlrTxApSRV	+= BD7->BD7_VLTXAP						// valor Tx Adm Serviço apresentado					
					nVlrTxCtSRV	+= IIf(lGlosaTot,BD7->BD7_VLADSE,BD7->BD7_VLTXPG) // valor Tx Adm Serviço contratado   se nao tiver glosa pega o mesmo valor
					
				Endif
				//Checa o valor da glosa
				nTotal += nGlosa

				BCT->( DbSetOrder(1) )
				BCT->( DBSeek(xFilial("BCT")+PLSINTPAD()+cCodGlo) )				
				
				cCodGlo 	:= BCT->BCT_CODEDI
				cCodQuest 	:= BCT->BCT_EDI550
				
				If Empty(cCodQuest)
					cCodQuest:="99"
				Endif
				
				BD7->( DbSkip() )
				
				If cCodSeqAnt <> BD7->BD7_SEQ500 .or. BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)<> BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
					
					AaDd(aRecnos,{ 	BD6->( Recno() ),; 				//01
									cCodGlo,;						//02
									cDesGlo,;						//03
									BD7->BD7_VLRGLO,;				//04
									nVlrSRVApr,;					//05	
									nVlrCOPApr,;					//06 BD7->BD7_VALORI // valor apresentado     				021
									IIf(lGlosaTot,0,nVlrCOPCtr),;	//07 BD7->BD7_VLRBPR // valor Contratado      				022
									nVlrTxApCOP,;					//08 BD7->BD7_VLTXAP // valor Tx Adm Custo	 apresentado	031
									IIf(lGlosaTot,0,nVlrTxCtCOP),;	//09 BD7->BD7_VLRTAD // valor Tx Adm Serviço contratado   	032
									nVlrFILApr,;					//10 BD7->BD7_VALORI // valor apresentado   				025
									IIf(lGlosaTot,0,nVlrFILCtr),;	//11 BD7->BD7_VLRBPR // valor Contratado					022
									nVlrTxApFIL,;					//12 BD7->BD7_VLTXAP // valor Tx Adm Filme apresentado		034
									IIf(lGlosaTot,0,nVlrTxCtFil),;	//13 BD7->BD7_VLRTAD // valor Tx Adm Serviço contratado		035
									nVlrSRVApr,;					//14 BD7->BD7_VALORI // valor serviços
									BD7->BD7_VLRBPR,;				//15 BD7->BD7_VLRBPR // valor Contratado
									nVlrTxApSRV,;					//16 BD7->BD7_VLTXAP // valor Tx Adm Serviço apresentado	028
									IIf(lGlosaTot,0,nVlrTxCtSRV),;	//17 BD7->BD7_VLRTAD // valor Tx Adm Serviço contratado  	029
									cCodQuest,;						//18
									IIf(lGlosaTot,0,nVlReconhece),;	//19 se foi glosado totalmente
									nRecBD7,;						//20 RECNO DO BD7
									cCodSeqAnt,;					//21 sequncia do bd7
									nVlrApAjs,;						//22 valor apresentado no a500 para tratamento ajius
									nVlrAdSeAj,;					//23 valor adicional de serviço para atratamento do ajius
									lGlosaTot,;						//24 se é uma glosa parcial ou total
									nVlTotPagar,;					//25 valor QUE IREI PAGAR DESCONTANDO AS GLOSA
									lCopFil} )						//26 Identificar se o Procedimento tem COP e FIL
					
					nVlrApr 	:= 0
					nVlReconhece:= 0
					nVlTotPagar := 0
					
					nVlrCOPApr	:= 0 // valor apresentado Custo op
					nVlrFILApr	:= 0 // valor apresentado filme
					nVlrSRVApr	:= 0 // valor apresentado Serviço
					
					nVlrCOPCtr	:= 0 // valor contratado Custo OP
					nVlrFILCtr	:= 0 // valor contratado Filme
					nVlrSRVCtr	:= 0 // valor contratado serviço
					
					nVlrTxApSRV	:= 0 // valor Tx Adm Serviço apresentado
					nVlrTxApCOP	:= 0 // valor Tx Adm Custo	 apresentado
					nVlrTxApFIL	:= 0 // valor Tx Adm Filme	 apresentado
					
					nVlrTxCtSRV	:= 0 // valor Tx Adm Serviço contratado
					nVlrTxCtCOP	:= 0 // valor Tx Adm Custo	 contratado
					nVlrTxCtFIL	:= 0 // valor Tx Adm Filme	 contratado

					lPartAntes	:= .F.
					lPartDespois:= .F.
				Endif
			Enddo
		Endif
		lGlosaTot	:= .F.
		lCopFil		:= .F.
		
		// Situac																
		
		If BD6->BD6_SITUAC == "1" .and. BD6->BD6_FASE == "4"
			nTotRec += BD6->BD6_VLRPAG
		Endif
	Endif
	
	// Proximo																
	
	Trb->( DbSkip() )
	nVlrApr 	:= 0
	nVlrCOPApr	:= 0 // valor apresentado Custo op
	nVlrFILApr	:= 0 // valor apresentado filme
	nVlrSRVApr	:= 0 // valor apresentado Serviço
	
	nVlrCOPCtr	:= 0 // valor contratado Custo OP
	nVlrFILCtr	:= 0 // valor contratado Filme
	nVlrSRVCtr	:= 0 // valor contratado serviço
	
	nVlrTxApSRV	:= 0 // valor Tx Adm Serviço apresentado
	nVlrTxApCOP	:= 0 // valor Tx Adm Custo	 apresentado
	nVlrTxApFIL	:= 0 // valor Tx Adm Filme	 apresentado
	
	nVlrTxCtSRV	:= 0 // valor Tx Adm Serviço contratado
	nVlrTxCtCOP	:= 0 // valor Tx Adm Custo	 contratado
	nVlrTxCtFIL	:= 0 // valor Tx Adm Filme	 contratado
	lGlosaTot	:= .F.
	lCopFil		:= .F.
EndDo

// Close area															

Trb->( DbCloseArea() )

Return( {aRecnos,nTotRec} )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSUA550MR³ Autor ³  Tulio Cesar        ³ Data ³ 13.12.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cria uma vida para os marcados...               ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSUA550MR
LOCAL lRet	:=	.F.
LOCAL nX	:=	0

// Executa tratamento para marcar...                             

DbSelectArea("BRJ")

// Checa se esta marcado												

If IsMark("BRJ_OK",oMBrwBRJ:cMark)
	BRJ->( RecLock("BRJ", .F.) )
	BRJ->BRJ_OK := "  "
	BRJ->( MsUnlock() )
	// Replace BRJ_OK With "  "
	//MsRUnLock( BRJ->( RECNO() ) )
Else
	For nX	:=	0	To 1 STEP 0.2
		If MsRLock()
			Replace BRJ_OK With oMBrwBRJ:cMark
			nX	:=	1
			lRet:=	.T.
		Else
			Inkey(0.2)
		Endif
	Next
	If !lRet
		MsgAlert(OemToAnsi(STR0026)) //"Este registro esta em uso"
	Endif
Endif

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA550VS ³ Autor ³ Alexander Santos      ³ Data ³ 03.01.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualiza registro exportados/importados					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA550VS(cAlias,nReg,nOpc)
LOCAL I__f := 0
LOCAL oDlg
LOCAL oFolder
LOCAL oBrwB2A
LOCAL aCabB2A := {}
LOCAL aVetB2A := {}
LOCAL aDadB2A := {}
LOCAL aCampos := {}

// Carrega tabela de exportacao										

Store Header "B2A" TO aCabB2A For .T.

// Cols																

If B2A->( dbSeek(xFilial("B2A")+BTO->BTO_CODOPE+BTO->BTO_NUMTIT) )
	Store COLS "B2A" TO aDadB2A FROM aCabB2A VETTRAB aVetB2A While B2A->(B2A_FILIAL+B2A_CODOPE+B2A_NUMTIT) == xFilial("B2A")+BTO->(BTO_CODOPE+BTO_NUMTIT)
Else
	Store COLS Blank "B2A" TO aDadB2A FROM aCabB2A
Endif

// Define Dialogo...                                             

DEFINE MSDIALOG oDlg TITLE cCadastro FROM ndLinIni,ndColIni TO ndLinFin,ndColFin OF GetWndDefault()

oEnchoice := MsMGet():New(cAlias,nReg,nOpc,,,,aCampos,{015,001,117,356},aCampos,,,,,oDlg,,,.F.)

@ 120,003 FOLDER oFolder SIZE 350,075 OF oDlg  PIXEL PROMPTS	"Questionamentos"
oBrwB2A:= TPLSBrw():New(001,001,347,055,nil,oFolder:aDialogs[1],nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabB2A,aDadB2A,.F.,"B2A",K_Visualizar,"Operadoras",nil,nil,nil,aVetB2A)

ACTIVATE MSDIALOG oDlg ON INIT (Eval({ || EnchoiceBar(oDlg,{|| nOpca := 1,oDlg:End() },{||oDlg:End()},.F.)  }))

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSLAR550
Mostra diretorios

@author Alexander Santos
@since 03.01.07
@version P12
/*/
//------------------------------------------------------------------------------------------
Function PLSLAR550(cDirAnt, cCampo)
local cDir := cDirAnt

default cCampo := "MV_PAR01"

//Diretorio																 
cDirAnt := cGetFile("*.*",STR0027,0,"SERVIDOR\",.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY)
														
if empty(cDirAnt)
	cDirAnt := cDir 
	&cCampo := cDirAnt + space(100)
else
	&cCampo := cDirAnt 
endif 

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSUA550VSºAutor  ³Microsiga           º Data ³  12/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Aplica Filtro na Rotina									  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSUA550VS
Local cPLSFiltro := ""

cPLSFiltro := "@BRJ_FILIAL = '"+xFilial("BRJ")+"' AND BRJ_REGPRI = '1' AND BRJ_PREFIX <> ' ' "
cPLSFiltro += "AND BRJ_NUMTIT <> ' ' AND D_E_L_E_T_ = ' '"

PLSED500VS()

DbSelectArea("BRJ")
SET FILTER TO &cPLSFiltro
	
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PL550PSRECºAutor  ³Microsiga           º Data ³  14/12/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pociona no 553 											  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PL550PSREC()
Local aArea := GetArea()
Local nRec:=R52->(CHAVE)

DbSelectArea("R53")
R53->(DbgoTop())

While R53->(!eof())
	If R53->(CHAVE) = nRec
		Exit
	Endif
	R53->(Dbskip())
Enddo

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsVerCrtItºAutor  ³Microsiga          º Data ³  14/12/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se há criticas   								  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PlsVerCrtIt(nTipo)
Local aArea 	:= GetArea()
Local lret		:=.F.
Local lHaGlosa	:=.F.
Local Nx		:=0

BCT->( DbSetOrder(1) )
BDX->(DbSetOrder(1))//BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_CODPAD+BDX_CODPRO+BDX_SEQUEN+BDX_CODGLO

If BDX->( MsSeek( xFilial("BDX")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) ) )
	While !Eof() .AND. BDX->BDX_FILIAL=xFilial("BDX") .AND. BDX->BDX_CODOPE=BD6->BD6_CODOPE .AND. BDX->BDX_CODLDP= BD6->BD6_CODLDP .AND. BDX->BDX_CODPEG=BD6->BD6_CODPEG .AND. BDX->BDX_NUMERO=BD6->BD6_NUMERO
		If (BDX->BDX_ACAO == "1" .and. BDX->BDX_PERGLO == 100) .or. (BDX->BDX_ACAOTX == "1" .and. BDX->BDX_PERGTX == 100)
			lHaGlosa:=.T.
			Exit
		ElseIf (BDX->BDX_ACAO == "1" .and. BDX->BDX_PERGLO < 100) .or. (BDX->BDX_ACAOTX == "1" .and. BDX->BDX_PERGTX < 100)
			lHaGlosa:=.T.
			Exit
		ElseIf BDX->BDX_ACAO == "2" // reconsidera total
			lHaGlosa:=.F.
		Endif
		
		If nTipo = 2 // se for tipo 5 envia o tipo 99= sem contestaçõa
			If BDX->BDX_ACAO == "2" .or. BDX->BDX_ACAOTX == "2"
				lHaGlosa:=.T.
				Exit
			Endif
		Endif
		BDX->( DbSkip() )
	Enddo
Endif


If nTipo = 2 // se for tipo 5 envia o tipo 99= sem contestaçõa
	lHaGlosa:=.T.
Endif



If lHaGlosa
	
	If BD7->(Dbseek(BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
		While !BD7->(Eof()) .AND. BD7->BD7_FILIAL=xFilial("BD7") .AND. BD7->BD7_CODOPE=BD6->BD6_CODOPE .AND. BD7->BD7_CODLDP= BD6->BD6_CODLDP .AND. BD7->BD7_CODPEG=BD6->BD6_CODPEG .AND. BD7->BD7_NUMERO=BD6->BD6_NUMERO .AND. BD7->BD7_ORIMOV=BD6->BD6_ORIMOV .AND. BD7->BD7_SEQUEN =BD6->BD6_SEQUEN
			If BDX->( DbSeek(BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_CODPAD+BD7_CODPRO+BD7_SEQUEN) ) )
				
				While !BDX->(Eof()) .AND. BDX->BDX_FILIAL == xFilial("BDX") .And. (BDX->(BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_CODPAD+BDX_CODPRO+BDX_SEQUEN) == BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_CODPAD+BD7_CODPRO+BD7_SEQUEN))
					
					
					If BDX->BDX_ACAO == "1" .or. BDX->BDX_ACAOTX == "1"
						
						lret:=.T.
						If Ascan(aBct553, {|x| x[1] = BD6->(RECNO()) .And. x[3] = BDX->BDX_CODGLO .And. x[8] = BD7->BD7_SEQ500 }) = 0
							If BCT->( DBSeek(xFilial("BCT")+PLSINTPAD()+BDX->BDX_CODGLO) )
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								// Forco novamente pois na Unimed Sul Cap nao posicionava corretamente no     ³
								// primeiro DbSeek. Isso so ocorria na primeira vez que fosse gerar o arquivo ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If BDX->BDX_CODGLO <> BCT->(BCT_PROPRI+BCT_CODGLO)
									BCT->( DBSeek(xFilial("BCT")+PLSINTPAD()+BDX->BDX_CODGLO) )//Forco novamente pois na Unimed Sul Cap nao posisionava corretamente na primeira vez
								EndIf
								//                    1               2               3                      4                                              5                6             7			8
								aadd(aBct553,{BD6->(RECNO()),BDX->(RECNO()),BDX->BDX_CODGLO,If(Empty(BCT->BCT_EDI550),"XX",BCT->BCT_EDI550),BCT->BCT_DESCRI,BDX->BDX_SEQUEN,BD7->(RECNO()),BD7->BD7_SEQ500})
							Endif
						Endif
					ElseIf BDX->BDX_ACAO == "2" .or. BDX->BDX_ACAOTX == "2"
						lret:=.T.
						If Ascan(aBct553, {|x| x[1] = BD6->(RECNO()) .And. x[4] = "99" .And. x[8] = BD7->BD7_SEQ500 }) = 0
							If BCT->( DBSeek(xFilial("BCT")+PLSINTPAD()+BDX->BDX_CODGLO) )
								aadd(aBct553,{BD6->(RECNO()),BDX->(RECNO()),BDX->BDX_CODGLO,"99",BCT->BCT_DESCRI,BDX->BDX_SEQUEN,BD7->(RECNO()),BD7->BD7_SEQ500})
							Endif
						Endif
					Endif
					
					
					If nTipo = 2 // se for tipo 5 envia o tipo 99= sem contestaçõa
						If BDX->BDX_ACAO == "2" .or. BDX->BDX_ACAOTX == "2"
							lret:=.T.
							If Ascan(aBct553, {|x| x[1] = BD6->(RECNO()) .And. x[4] = "99" .And. x[8] = BD7->BD7_SEQ500 }) = 0
								If BCT->( DBSeek(xFilial("BCT")+PLSINTPAD()+BDX->BDX_CODGLO) )
									aadd(aBct553,{BD6->(RECNO()),BDX->(RECNO()),BDX->BDX_CODGLO,"99",BCT->BCT_DESCRI,BDX->BDX_SEQUEN,BD7->(RECNO()),BD7->BD7_SEQ500})
								Endif
							Endif
						Endif
					Endif
					
					BDX->( DbSkip() )
				Enddo
			Endif
			
			iF Len(aBct553)=0 .and. nTipo == 2
				aadd(aBct553,{BD6->(RECNO()),BDX->(RECNO()),"","99","",BDX->BDX_SEQUEN,BD7->(RECNO()),BD7->BD7_SEQ500})
			Endif
			
			BD7->( DbSkip() )
		Enddo
	Endif
	If !lret
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//verificar se um outro item na guia com glosa												³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If BDX->( DbSeek( xFilial("BDX")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) ) )
			While !Eof() .AND. BDX->BDX_FILIAL=xFilial("BDX") .AND. BDX->BDX_CODOPE=BD6->BD6_CODOPE .AND. BDX->BDX_CODLDP= BD6->BD6_CODLDP .AND. BDX->BDX_CODPEG=BD6->BD6_CODPEG .AND. BDX->BDX_NUMERO=BD6->BD6_NUMERO
				If (BDX->BDX_ACAO == "1" .and. BDX->BDX_PERGLO == 100) .or. (BDX->BDX_ACAOTX == "1" .and. BDX->BDX_PERGTX == 100)
					lret:=.T.
					Exit
				ElseIf (BDX->BDX_ACAO == "1" .and. BDX->BDX_PERGLO < 100) .or. (BDX->BDX_ACAOTX == "1" .and. BDX->BDX_PERGTX < 100)
					lret:=.T.
					Exit
				ElseIf BDX->BDX_ACAO == "2"
					lret:=.T.
					Exit
				Endif
				BDX->( DbSkip() )
			Enddo
		Endif
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//Se existir alguma glosa em outros itens da guia esse item sera acrescentado o código "99".³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If lret
			If BCT->( DBSeek(xFilial("BCT")+PLSINTPAD()+BDX->BDX_CODGLO) )
				If BD7->(Dbseek(BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
					While !Eof() .AND. BD7->BD7_FILIAL=xFilial("BD7") .AND. BD7->BD7_CODOPE=BD6->BD6_CODOPE .AND. BD7->BD7_CODLDP= BD6->BD6_CODLDP .AND. BD7->BD7_CODPEG=BD6->BD6_CODPEG .AND. BD7->BD7_NUMERO=BD6->BD6_NUMERO .AND. BD7->BD7_ORIMOV=BD6->BD6_ORIMOV .AND. BD7->BD7_SEQUEN =BD6->BD6_SEQUEN
						If Ascan(aBct553, {|x| x[1] = BD6->(RECNO()) .And. x[4] = "99" .And. x[8] = BD7->BD7_SEQ500 }) = 0
							aadd(aBct553,{BD6->(RECNO()),BDX->(RECNO()),"","99","",BDX->BDX_SEQUEN,BD7->(RECNO()),BD7->BD7_SEQ500})
						Endif
						BD7->( DbSkip() )
					Enddo
				Endif
			Endif
		Endif
	Endif
Endif
RestArea(aArea)

IF nTipo == 2
	lRet := .T.
Endif
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLQTA500TO   ºAutor  ³Microsiga        º Data ³  16/11/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Trata o totalizador de eventos para gerar o R509           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TotQtdRec(nQtd)
Local cRet     := ''
Local cDecItem := ''

cDecItem := cValToChar(nQtd - Int(nQtd))
cDecItem := Padr(Substr(cDecItem,3,len(cDecItem)),4,"0")
cRet 	 := Strzero(int(nQtd),4)+cDecItem
	
Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PLSUA550RA  ºAutor  ³Microsiga        º Data ³  15/10/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exporta aquivo A550 de reembolso             			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSUA550RA
Local aR551      := {}
Local aR53R      := {}
Local aR559      := {}
Local aStru551   := {}
Local aStru552   := {}
Local aStru553   := {}
Local aStru557   := {}
Local aStru558   := {}
Local aStru559   := {}
Local aStruR5R   := {}
Local cNomArq    := ""
Local nVlrTotCob := 0
Local nVlrTotRec := 0
Local nVlrTotAco := 0
Local nVlrAcoTx  := 0
Local nVlrContes := 0
Local nTotR507   := 0
Local nTotR508   := 0   
Local nFor       := 0
Local cDirFile   := "\PTU\"
Local cLayout    := PADR(AllTrim(mv_par02),6)
Local cCodCri    := ""
Local cDesCri    := ""
Local cNotaAnt	 := ""

lExp507 := .T.

cDirFile := AllTrim(mv_par01)

// Testa o diretorio													

If SubStr(cDirFile,Len(cDirFile),1) # "\"
	cDirFile+="\"
EndIf

// TEMPORARIO 551													         ³

aadd(aStru551,{"CHAVE","C",022,0})
aadd(aStru551,{"CAMPO","C",262,0})

//--< Criação do objeto FWTemporaryTable >---
oTempR51 := FWTemporaryTable():New( "R51" )
oTempR51:SetFields( aStru551 )
oTempR51:AddIndex( "INDR51",{ "CHAVE" } )

if( select( "R51" ) > 0 )
	R51->( dbCloseArea() )
endIf

oTempR51:Create()


// TEMPORARIO 552													         ³

aadd(aStru552,{"CHAVE","N",10,0})
aadd(aStru552,{"CAMPO","C",652,0})

//--< Criação do objeto FWTemporaryTable >---
oTempR52 := FWTemporaryTable():New( "R52" )
oTempR52:SetFields( aStru552 )
oTempR52:AddIndex( "INDR52",{ "CHAVE" } )

if( select( "R52" ) > 0 )
	R52->( dbCloseArea() )
endIf

oTempR52:Create()


// TEMPORARIO 553													         ³

aadd(aStru553,{"CHAVE","C",8,0})
aadd(aStru553,{"CAMPO","C",515,0})

//--< Criação do objeto FWTemporaryTable >---
oTempR53 := FWTemporaryTable():New( "R53" )
oTempR53:SetFields( aStru553 )
oTempR53:AddIndex( "INDR53",{ "CHAVE" } )

if( select( "R53" ) > 0 )
	R53->( dbCloseArea() )
endIf

oTempR53:Create()


// TEMPORARIO R5R													         ³

aadd(aStruR5R,{"CHAVE","C",8,0})
aadd(aStruR5R,{"CAMPO","C",515,0})

//--< Criação do objeto FWTemporaryTable >---
oTempR5R := FWTemporaryTable():New( "R5R" )
oTempR5R:SetFields( aStruR5R )
oTempR5R:AddIndex( "INDR5R",{ "CHAVE" } )

if( select( "R5R" ) > 0 )
	R5R->( dbCloseArea() )
endIf

oTempR5R:Create()
    

// TEMPORARIO 557													         ³

aadd(aStru557,{"CHAVE","C",8,0})
aadd(aStru557,{"CAMPO","C",143,0})

//--< Criação do objeto FWTemporaryTable >---
oTempR57 := FWTemporaryTable():New( "R57" )
oTempR57:SetFields( aStru557 )
oTempR57:AddIndex( "INDR57",{ "CHAVE" } )

if( select( "R57" ) > 0 )
	R57->( dbCloseArea() )
endIf

oTempR57:Create()
   

// TEMPORARIO 558													         ³
  
aadd(aStru558,{"CHAVE","C",8,0})
aadd(aStru558,{"CAMPO","C",234,0})

//--< Criação do objeto FWTemporaryTable >---
oTempR58 := FWTemporaryTable():New( "R58" )
oTempR58:SetFields( aStru558 )
oTempR58:AddIndex( "INDR58",{ "CHAVE" } )

if( select( "R58" ) > 0 )
	R58->( dbCloseArea() )
endIf

oTempR58:Create()


// TEMPORARIO 559													         ³

aadd(aStru559,{"CHAVE","C",022,0})
aadd(aStru559,{"CAMPO","C",82,0})

//--< Criação do objeto FWTemporaryTable >---
oTempR59 := FWTemporaryTable():New( "R59" )
oTempR59:SetFields( aStru559 )
oTempR59:AddIndex( "INDR59",{ "CHAVE" } )

if( select( "R59" ) > 0 )
	R59->( dbCloseArea() )
endIf

oTempR59:Create()     

B7Q->(dbSetOrder(1))//B7Q_FILIAL+B7Q_CODBRJ+B7Q_SEQGUI
B7R->(dbSetOrder(1))//B7R_FILIAL+B7R_CODBRJ+B7R_SEQGUI
BCT->(dbSetOrder(1))//BCT_FILIAL+BCT_CODOPE+BCT_PROPRI
SE2->(dbSetOrder(1))
B2A->(dbSetOrder(1))//B2A_FILIAL + B2A_OPEDES + B2A_NUMTIT + B2A_SEQUEN
BRJ->(dbSetOrder(1))//BRJ_FILIAL + BRJ_CODIGO 

If BCT->(DbSeek(xFilial("BCT")+PlsIntPad()+GetNewPar("MV_PTCRIRE","999")))
	If(Empty(BCT->BCT_EDI550),cCodCri := "9999",cCodCri := Strzero(Val(BCT->BCT_EDI550),4))
		cDesCri := Padr(BCT->BCT_DESCRI,500)
	EndIf
	
	If !Empty(BRJ->(BRJ_PRESE2+BRJ_NUMSE2+BRJ_PARSE2+BRJ_TIPSE2)) .And. !SE2->( MsSeek(xFilial("SE2")+Alltrim(BRJ->(BRJ_PRESE2+BRJ_NUMSE2+BRJ_PARSE2+BRJ_TIPSE2)) ))
		MsgInfo("Título de pagamento não encontrado.")
		Return()
	EndIf
	
	If B7Q->(DbSeek(xFilial("B7Q")+BRJ->BRJ_CODIGO))
		While xFilial("B7Q")+B7Q->B7Q_CODBRJ == xFilial("B7Q")+BRJ->BRJ_CODIGO			
			If B7R->(DbSeek(xFilial("B7R")+BRJ->BRJ_CODIGO)) 
				While xFilial("B7R")+B7R->B7R_CODBRJ == xFilial("B7R")+BRJ->BRJ_CODIGO 
					If B7R->B7R_VLRGLO <= 0
						B7R->(dbSkip())
						Loop						
					EndIf
					
					// Informacoes registro R553 										         ³
					
					if B7Q->B7Q_NOTA <> cNotaAnt
						aR53R := {}
						aadd(aR53R,StrZero(1,8))	 								 // 01 Sequencial
						aadd(aR53R,"553")					   						 // 02 Tipo de Registro
						aadd(aR53R,cCodCri)									 		 // 03 Código do motivo do questionamento
						aadd(aR53R,cDesCri)                                         // 04 Complemento do motivo do questionamento
						
						cDado := ""
						For nFor := 1 To Len(aR53R)
							cDado += aR53R[nFor]
						Next
						
						R5R->( RecLock("R5R",.T.) )
						R5R->CHAVE := B7Q->B7Q_NRSEQ
						R5R->CAMPO := cDado
						R5R->( MsUnLock() )
						
						
						// Informacoes registro R557						
						aR557 := {}
						aadd(aR557,StrZero(1,8))	 						// 01 Sequencial
						aadd(aR557,"557")					   				// 02 Tipo de Registro
						aadd(aR557,B7Q->B7Q_LOTE)							// 03 Número do lote de notas.
						aadd(aR557,B7Q->B7Q_NOTA)                           // 04 Número da nota de controle da Unimed
			  			aadd(aR557,B7Q->B7Q_CODOPE)							// 05 Código da Unimed
			  			aadd(aR557,Substr(B7Q->B7Q_MATRIC,5,13))			// 06 Código de Identificação do Beneficiário  
			  			aadd(aR557,B7Q->B7Q_NOMUSR)							// 07 Nome do Beneficiário	  		
			  			aadd(aR557,Dtos(B7Q->B7Q_DATREE))					// 08 Data do reembolso
			  			aadd(aR557,B7Q->B7Q_CPFCGC)	 						// 09 Número do CNPJ ou do CPF do prestador
		  		  		aadd(aR557,B7Q->B7Q_NOMRDA)							// 10 Nome do prestador 
						
						nVlrTotCob += B7R->B7R_VLRDIF
						nVlrTotRec += B7R->B7R_VLRDIF - B7R->B7R_VLRGLO
						nVlrContes += B7R->B7R_VLRGLO
						nTotR507 ++
						
						cDado := ""
						For nFor := 1 To Len(aR557)
							cDado += aR557[nFor]
						Next
						
						R57->( RecLock("R57",.T.) )
						R57->CHAVE := B7Q->B7Q_NRSEQ
						R57->CAMPO := cDado
						R57->( MsUnLock() )			
					endif
		   			//Informacoes registro R558	   		
		   			aR558 := {}
		   			aadd(aR558,StrZero(1,8))	 						// 01 Sequencial
			  		aadd(aR558,"558")					   				// 02 Tipo de Registro
			  		aadd(aR558,B7Q->B7Q_LOTE)							// 03 Número do lote de notas.
			  		aadd(aR558,B7Q->B7Q_NOTA)                        	// 04 Número da nota de controle da Unimed	
		   			aadd(aR558,B7Q->B7Q_NRSEQ)                       	// 05 Número seqüencial do A500 (fatura)	
		   			aadd(aR558,Dtos(B7Q->B7Q_DATSER))					// 06 Data de execução do serviço		   			
					aadd(aR558,B7R->B7R_TPTAB)                      	// 07 Tipo de participação.	
		   			aadd(aR558,B7R->B7R_CODTPA)                     	// 08 Identifica o tipo de tabela utilizado no Serviço Médico		   			
		   			aadd(aR558,Substr(B7R->B7R_CODPRO,1,8))        		// 09 Código do Serviço
		   			aadd(aR558,Strzero((B7R->B7R_VLRSER)*100,14))    	// 10 Valor cobrado pelo serviço
		   			aadd(aR558,Strzero((B7R->B7R_VLRDIF)*100,14))   	// 11 Valor da diferença do serviço cobrado	
		   			aadd(aR558,Strzero((B7R->B7R_VLRDIF-B7R->B7R_VLRGLO)*100,14))     				// 12 Valor Reconhecido	
		   			aadd(aR558,Replicate("0",14))                    	// 13 Valor do acordo
		   			aadd(aR558,Space(8))                       			// 14 Data do acordo
		   			aadd(aR558,'00')                       				// 15 Tipo do Acordo
		   			aadd(aR558,Strzero(Int(Round(B7R->B7R_QTDAPR, 2)),4)+"0000")    				// 16 Quantidade de serviços
		   			aadd(aR558,Strzero(Int(Round(B7R->B7R_VLRDIF -B7R->B7R_VLRGLO , 2)),4)+"0000") 	// 17 Quantidade de um serviço reconhecido	
		   			aadd(aR558,Replicate("0",8))                    	// 18 Quantidade Acordada   			
		   			aadd(aR558,Space(40))                       		// 19 Reservado	
		   			aadd(aR558,Padr(B7R->B7R_SIGEXE,12))             	// 20 Sigla do Conselho Profissional
		   			aadd(aR558,Padr(B7R->B7R_REGEXE,15))             	// 21 Número do Conselho Profissional do prestador
		   			aadd(aR558,B7R->B7R_ESTEXE)                      	// 22 Sigla da Unidade Federativa do Conselho Profissional do prestador
		   			aadd(aR558,B7Q->B7Q_NUMAUT)                      	// 23 Número da Autorização
					aadd(aR558,B7R->B7R_NOMEXE)                      	// 24 Nome do profissional executante.	
					
					nTotR508 ++
					
					cDado := ""
					For nFor := 1 To Len(aR558)
						cDado += aR558[nFor]
					Next
					
					R58->( RecLock("R58",.T.) )  
					R58->CHAVE := B7Q->B7Q_NRSEQ
					R58->CAMPO := cDado
					R58->( MsUnLock() )
					
					cNotaAnt := B7Q->B7Q_NOTA
					
					If !B2A->( MsSeek( xFilial("B2A")+AllTrim(BRJ->(BRJ_OPEORI+BRJ_NUMFAT)) ) )
						B2A->( RecLock("B2A",.T.) )
						B2A->B2A_FILIAL := xFilial("B2A")
						B2A->B2A_CODOPE := PlsIntPad()
						B2A->B2A_OPEDES := BRJ->BRJ_OPEORI
						B2A->B2A_NUMTIT := AllTrim(BRJ->BRJ_NUMFAT)					
						B2A->B2A_MATRIC := B7Q->B7Q_MATRIC
						B2A->B2A_DATATE := B7Q->B7Q_DATSER
						B2A->B2A_CODPAD := '0'
						B2A->B2A_CODPRO := Substr(B7R->B7R_CODPRO,1,8)
				   		B2A->B2A_VALCOB := nVlrTotCob/100
				   		B2A->B2A_VALREC := nVlrTotRec/100
						B2A->B2A_DATACO := BRJ->BRJ_DATA
						B2A->B2A_TPARQ  := "1"				
						B2A->( MsUnLock() )
					EndIf
					B7R->(dbSkip())
				EndDo					    
			EndIf			
			B7Q->(DbSkip())
		EndDo
		
		// Informacoes registro R551 										         ³
		
		aadd(aR551,StrZero(1,8))	 								 // 01 Sequencial
		aadd(aR551,"551")					   						 // 02 Tipo de Registro
		aadd(aR551,BRJ->BRJ_OPEORI)									 // 03 Código da Unimed destino para envio de arquivo.
		aadd(aR551,PLSINTPAD())				   						 // 04 Código da Unimed origem do envio de arquivo.
		aadd(aR551,DtoS(dDataBase))            					     // 05 Data de geração do arquivo de envio.
		aadd(aR551,BRJ->BRJ_OPEORI)				 					 // 06 Código da Unimed Credora.
		aadd(aR551,Space(11))					 					 // 07 Reservado para o futuro.
		aadd(aR551,Space(11))					   					 // 08 Reservado para o futuro.
		aadd(aR551,dtos(BRJ->BRJ_DTVENC))         					 // 09 Data de vencimento do documento 1
		aadd(aR551,StrZero(BRJ->BRJ_VLRFAT*100,14))				 	 // 10 Valor total do documento 1
		aadd(aR551,StrZero(nVlrContes*100,14))			  			 // 11 Valor total da contestação do documento 1   - BAF->BAF_VLRGLO
		aadd(aR551,Space(14))                 					     // 12 Reservado
		aadd(aR551,"1") 						 					 // 13 Tipo de Arquivo.
		aadd(aR551,"12")						 					 // 14 Número da versão da transação
		aadd(aR551,StrZero(SE2->E2_VALOR*100,14)) 					 // 15 Valor total pago do documento 1
		aadd(aR551,Replicate("0",11))             					 // 16 Número da Nota de Débito de conclusão da contestação do documento 1
		aadd(aR551,Space(8))                      					 // 17 Data de vencimento da NDC 1
		aadd(aR551,"0")                          					 // 18 Status da Conclusão
		aadd(aR551,IIf(Empty(BRJ->BRJ_TPCOB),"2",BRJ->BRJ_TPCOB))  // 19 Classificação da Cobrança
		aadd(aR551,Space(11))										 // 20 Reservado
		aadd(aR551,Space(8))										 // 21 Data de vencimento do documento 2
		aadd(aR551,Replicate("0",14))								 // 22 Valor total do documento 2
		aadd(aR551,Replicate("0",14))								 // 23 Valor total da contestação do documento 2
		aadd(aR551,Replicate("0",14))								 // 24 Valor total pago do documento 2
		aadd(aR551,Replicate("0",11))								 // 25 Número da Nota de Débito de conclusão da contestação do documento 2
		aadd(aR551,Space(8))										 // 26 Data de vencimento da NDC 2
		aadd(aR551,BRJ->BRJ_NUMFAT)									 // 27 Número do documento 1
		aadd(aR551,Space(20)) 										 // 28 Número do documento 2		
		aadd(aR551,"0")                                              // 29 Tipo de Arquivo Parcial
		
		cDado := ""
		For nFor := 1 To Len(aR551)
			cDado += aR551[nFor]
		Next
		
		R51->( RecLock("R51",.T.) )
		R51->CAMPO := cDado
		R51->( MsUnLock() )
		
		// Informacoes registro R559 										         ³
		
		aadd(aR559,StrZero(1,8))	 								 // 01 Sequencial
		aadd(aR559,"559")					   						 // 02 Tipo de Registro
		aadd(aR559,Replicate("0",5))								 // 03 Quantidade total de registro tipo R552
		aadd(aR559,StrZero(nVlrTotCob*100,14))                      // 04 Valor total cobrado
		aadd(aR559,StrZero(nVlrTotRec*100,14))                      // 05 Valor total reconhecido
		aadd(aR559,StrZero(nVlrTotAco*100,14))                      // 06 Valor total acordo do serviço (somatório das sequencias 015, 023 e 026 do R552)
		aadd(aR559,StrZero(nVlrAcoTx*100,14))                       // 07 Valor total acordo da taxa (somatório das sequencias 029,032 e 035 do R552)- nVlrTotAcoTx
		aadd(aR559,StrZero(nTotR507,5))								 // 08 Quantidade total de registro tipo R557
		aadd(aR559,StrZero(nTotR508,5))								 // 09 Quantidade total de registro tipo R558								
		
		cDado := ""
		For nFor := 1 To Len(aR559)
			cDado += aR559[nFor]
		Next
		
		R59->( RecLock("R59",.T.) )
		R59->CAMPO := cDado
		R59->( MsUnLock() )
		
		// Define nome do arquivo   										         ³
		
		If len(Alltrim(BRJ->BRJ_NUMFAT)) < 6
			cFileGerado := cDirFile+"NC1_"+ Replicate("_",6-len(Alltrim(BRJ->BRJ_NUMFAT)))+Alltrim(BRJ->BRJ_NUMFAT)+"."+SubStr(BRJ->BRJ_CODOPE, 2, 3)
			cArqNom		:= "NC1_"+ Replicate("_",6-len(Alltrim(BRJ->BRJ_NUMFAT)))+Alltrim(BRJ->BRJ_NUMFAT)+"."+Strzero(Val(PLSINTPAD()),3)
		Else
			cFileGerado := cDirFile+"NC1_"+IIf(BRJ->BRJ_TPCOB <> "1",SubStr(Alltrim(BRJ->BRJ_NUMFAT), Len(Alltrim(BRJ->BRJ_NUMFAT)) - 5, 6),SubStr(Alltrim(BRJ->BRJ_NRNDC), Len(Alltrim(BRJ->BRJ_NRNDC)) - 5, 6))+"."+SubStr(BRJ->BRJ_CODOPE, 2, 3)
			cArqNom		:= "NC1_"+IIf(BRJ->BRJ_TPCOB <> "1",SubStr(Alltrim(BRJ->BRJ_NUMFAT), Len(Alltrim(BRJ->BRJ_NUMFAT)) - 5, 6),SubStr(Alltrim(BRJ->BRJ_NRNDC), Len(Alltrim(BRJ->BRJ_NRNDC)) - 5, 6))+"."+Strzero(Val(PLSINTPAD()),3)
		EndIf
		
		// Gera arquivo A550        										         ³
		
		R5R->(DbGoTop())
		R57->(DbGoTop())
		R58->(DbGoTop())
		If !R57->(EOF())
			PTULn("551",.T.)
			PlsPTU(padr(mv_par02,6),cArqNom,cDirFile)
		Endif
		
		If Empty(BRJ->BRJ_NIV550)
			BRJ->( RecLock("BRJ", .F.) )
			BRJ->BRJ_NIV550 := '1'
			BRJ->( MsUnlock() )
		EndIf			
EndIf

if( select( "R51" ) > 0 )
	oTempR51:delete()
endIf

if( select( "R52" ) > 0 )
	oTempR52:delete()
endIf

if( select( "R53" ) > 0 )
	oTempR53:delete()
endIf

if( select( "R5R" ) > 0 )
	oTempR5R:delete()
endIf

if( select( "R57" ) > 0 )
	oTempR57:delete()
endIf

if( select( "R58" ) > 0 )
	oTempR58:delete()
endIf

if( select( "R59" ) > 0 )
	oTempR59:delete()
endIf
		
Return { .T., ""}

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} A550Inverte
Função para marcar e desmarcar todos da MarkBrowse

@author Lucas Nonato
@since 06/06/2018
@version P12
/*/
//------------------------------------------------------------------------------------------
function A550Inverte(oMBrwBRJ)
local nReg 	 := BRJ->(Recno())
BRJ->( dbgotop() )

while !BRJ->(Eof())
	// Marca ou desmarca. Este metodo respeita o controle de semaphoro.
	oMBrwBRJ:MarkRec()
	BRJ->(dbSkip())
enddo

BRJ->(dbGoto(nReg))
oMBrwBRJ:oBrowse:Refresh(.t.)

return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} PLMARKBRJ
Armazena o recno de todas as guias selecionadas
@author Lucas Nonato
@since 06/06/2018
@version P12
/*/
//-------------------------------------------------------------------
function PLMARKBRJ(obj)
local nScan := 0

if obj:IsMark(obj:Mark()) 	
	aadd(aMark,{BRJ->(RECNO())}) 	
else 
	nScan := ascan(aMark,{ |x| x[1] == BRJ->(RECNO())})	
	//deleta o registro desmarcado
	if nScan > 0
		//Deleta os dados da posição
		adel(aMark, nScan)		
		//Deleta a posição do array que ficou vazio após o ADEL
		asize(aMark, LEN(aMark) - 1)	
	endif
endIf

return
