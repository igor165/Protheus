#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'FWMVCDef.ch'
#Include 'GPEM040B.ch'

Static lIntTaf
Static lMiddleware
Static cVerEnv		:= ""
Static cVerGPE		:= ""

/*/{Protheus.doc} GPEM040B
Cria um browse que permite a seleção dos funcionários para o cálculo da rescisão coletiva 
@author cicero.pereira
@since 12/09/2017
@version 1.0
@see 
/*/
Function GPEM040B()
	
	Local aArea			:= GetArea()
	Local cValidFil		:= ""
	
	Static _Marcados	:= {}
	
	Private oBrowse
	Private _MarcReg	:= {}
	Private aMarcSRA	:= {}
	Private aGpm040Log	:= {}
	Private aLogErros	:= {} // Array com os logs de erros de processamento
	Private cResComp
	Private cModFol		:= SuperGetMv( "MV_MODFOL", .F., "1" )
	Private cAtualSit   := SuperGetMv( "MV_SITRES", .F., "2" )
	Private cArqDbf		:= ""
	Private cArqNtx		:= ""
	Private cFilOld		:= ""      
	Private dDataAvi	:= CtoD ("//")	
	Private lRescRRA	:= .F.
	Private lAtuSimul	:= .F.
	Private lSabDom		:= If(GetMv("MV_SABDOM")=="S", .T., .F.) //Se pagara o sab e domingo qdo demissao na sexta
	Private lModDataDem	:= .F.
	Private lProjav		:= .F. //Projeção do aviso prévio por tipo de rescisão
	Private lProj		:= .T. //Projeção do aviso prévio por sindicato 
	Private lColetiva	:= .F.
	Private lTCFA040	:= IsInCallStack("TCFA040")
	Private nRegSrg		:= 0
	Private nSalaMed 	:= 0
	Private nSMesMed  	:= 0
	Private nSDiaMed  	:= 0
	Private nSHorMed 	:= 0
	Private lIndAv		:= Iif(cPaisLoc == 'BRA' .And. SRG->(ColumnPos( "RG_INDAV")) > 0, .T., .F.) 
	Private lContrInt	:= If(SRC->(ColumnPos( 'RC_CONVOC' )) > 0,.T.,.F.)

	DEFAULT lIntTaf		:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 1 )
	DEFAULT lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )

	cEFDAviso  			:= If(cPaisLoc == 'BRA' .AND. Findfunction("fEFDAviso"), fEFDAviso(), "0")			//Se nao encontrar este parametro apenas emitira alertas
	lAvMsg				:= .F.

	//Verifica se os leiaute do eSocial GPE vs TAF estão divergentes.
	If lIntTaf .And. FindFunction("fVersEsoc") .And. FindFunction("ESocMsgVer")
		fVersEsoc( "S2299", .F.,,, @cVerEnv, @cVerGPE)
		If !lMiddleware .And. cVerGPE <> cVerEnv .And. (cVerGPE >= "9.0" .Or. cVerEnv >= "9.0")
			//"Atenção! A versão do leiaute GPE é xxx e a do TAF é xxx, sendo assim, estão divergentes. O Evento xxx não será integrado com o TAF, e consequentemente, não será enviado ao RET.
			//Caso prossiga a informação será atualizada somente na base do GPE. Deseja continuar?"				
			If ESocMsgVer(.F.,/*cEvento*/, cVerGPE, cVerEnv)
				lIntTAF		:= .F.
			Else
				Return
			EndIf
		EndIf
	EndIf

	SetMnemonicos(NIL,NIL,.T.)

	//Inicializa variaveis que no modelo 1 sao mnemonicos
	If cModFol == "2"
		aIncRes			:= {}
		lUltSemana 		:= .F.
		lRescDis		:= .F.
		lRescPLR		:= .F.
		lRecRes			:= .F.
		nPosSem			:= 0
		Salario			:= 0
		SalHora			:= 0
		SalDia			:= 0
		SalMes			:= 0
		NORMAL			:= 0
		DESCANSO		:= 0
		nDferven 		:= 0
		nFaltasv		:= 0
		nDferave		:= 0
		nFaltasp		:= 0
		nDferInd		:= 0
		cProcesso		:= ""
		cPeriodo		:= ""
		cNumPag			:= ""
		cRot			:= ""
		cCompl			:= ""
		dDataDem		:= CtoD("")
		dDataAvis		:= CtoD("")
	EndIf
	
	// Filtro das filiais que o usuário tem acesso
	If Len(fValidFil()) <= 2000
		cValidFil := "(AllTrim(SRA->RA_FILIAL) $ '" + fValidFil() + "')"
	Else
		cValidFil := "(! AllTrim(SRA->RA_FILIAL) $ '" + fValidFil(, .T.) + "')"
	EndIf

	DbSelectArea("SRA")
	DbSetOrder(1)

	oBrowse := FWMarkBrowse():New()
	oBrowse:SetAlias('SRA')
	oBrowse:SetFieldMark("RA_OKTRANS")
	GpLegend(@oBrowse,.T.)
	oBrowse:SetMenuDef('GPEM040B') 			
	oBrowse:SetDescription(OemToAnsi(STR0001)) //"Cálculo de múltiplas rescisões"
	oBrowse:SetFilterDefault(cValidFil)
	oBrowse:SetAfterMark({|| Marca() })
	oBrowse:SetAllMark({|| MarkAll() })
	
	oBrowse:Activate()
	
	RestArea(aArea)
	
Return

/*/{Protheus.doc} Marca
Realiza a marcação de um registro no browse
@author cicero.pereira
@since 12/09/2017
@version 1.0
/*/
Static Function Marca()

	Local cKey := SRA->( RA_FILIAL + RA_MAT )
	Local nPos := aScan( aMarcSRA, { |x| ( x[1] == cKey )})
	
	If oBrowse:IsMark()
		If cPaisLoc == "BRA"
			Aadd( aMarcSRA, { SRA->RA_FILIAL + SRA->RA_MAT , SRA->RA_PROCES} )
		Else
			Aadd( aMarcSRA, { SRA->RA_FILIAL + SRA->RA_MAT , SRA->RA_PROCES, SRA->RA_MAT} )
		EndIf
		Aadd(_Marcados, oBrowse:At())
	Else
		If ( nPos > 0 )
			nLastSize := Len( aMarcSRA )
			aDel( aMarcSRA, nPos )
			aDel(_Marcados, nPos)
			aSize( aMarcSRA, ( nLastSize - 1 ))
			aSize(_Marcados, ( nLastSize - 1 ))
		EndIF
	EndIf

Return

/*/{Protheus.doc} MarkAll
Faz a marcação de todos os registros do browse
@author cicero.pereira
@since 12/09/2017
@version 1.0
/*/
Static Function MarkAll()
	
	Local nUltimo
	
	oBrowse:GoBottom(.F.)
	nUltimo := oBrowse:At()
	oBrowse:GoTop()
	
	While .T.
		oBrowse:MarkRec()
		If nUltimo == oBrowse:At()
			oBrowse:GoTop()
			Exit
		EndIf
		oBrowse:GoDown()
	EndDo

Return

/*/{Protheus.doc} ]
Limpa as marcações do browse 
@author cicero.pereira
@since 12/09/2017
@version 1.0
/*/
Function Clear()

	While Len(_Marcados) >= 1
		oBrowse:GoTo(_Marcados[1])
		oBrowse:MarkRec()
	EndDo
	
	oBrowse:Refresh(.T.)
	
Return

Function Gp040BCalc()
Local aMarcAux	:= {}
Local aMarcAux2	:= {}
Local aMarcAux3	:= {}
Local aParAux	:= {}
Local aLogTitle	:= {}
Local aLogFile	:= {}
Local aLogAux	:= {{},{}}
Local cProcAux	:= ""
Local lTemErro	:= .F.
Local nQtdProc	:= 0
Local nPos		:= 0
Local nX		:= 0
Local nY		:= 0

Private aParam	:= {}

If Len(aMarcSRA) < 1
	Help(' ', 1, "NUMFUNC", , STR0002, 1, 0) //"Nenhum funcionário selecionado."
	Return
EndIf

aMarcAux := aClone(aMarcSRA)
_MarcReg := {}
cProcAux := aMarcAux[1,2]
aGpm040Log := {}

nQtdProc := aScan(aMarcAux, {|x| x[2] <> cProcAux } )

If nQtdProc > 0 //Existe mais de um processo selecionado
	If( MsgYesNo( OemToAnsi( STR0061 ), OemToAnsi( STR0051 ) ) ) //"Atencao"###"Foi selecionado mais de um processo para cálculo. Será aberta tela para preenchimento dos parâmetros para cada processo. Prosseguir?"
	
		aSort( aMarcAux,,,{ |x,y| x[2] < y[2] } )
		cProcAux := ""
	
		For nX := 1 to Len(aMarcAux)
			If cProcAux <> aMarcAux[nX,2]
				lInclui := .F.
				If fLoadParam(aMarcAux[nX,2],@aParAux,Len(aParam)) //Carrega os parametros de cálculo para cada período
					aAdd(aParam, aParAux)
					aAdd(aMarcAux3, {})
					lInclui := .T.
				EndIf
				aMarcAux2 := {}
				aParAux   := {}
				cProcAux  := aMarcAux[nX,2]
			EndIf
			
			If lInclui
				Aadd( aMarcAux3[Len(aMarcAux3)], {aMarcAux[nX,1],aMarcAux[nX,2]} )
			EndIf
		Next nX
		If Len(aParam) > 0
			//Chama a rotina de cálculo para cada processo
			For nX := 1 to Len(aParam)
				aParAux := aClone(aParam[nX])
				_MarcReg:= {}
				Aeval(aMarcAux3[nX],{ |x| aAdd(_MarcReg, x[1]) })
				GPEM630(aParAux)
				For nY := 1 to Len(aGpm040Log)
					If Len(aGpm040Log[nY]) > 0
						If nY == 1
							lTemErro := .T.
						EndIf
						For nPos := 1 to Len(aGpm040Log[nY])
							aAdd( aLogAux[nY], aGpm040Log[nY,nPos] )
						Next nPos
					EndIf
				Next nY
				aGpm040Log := {}
			Next nX
			
			If lTemErro
				aAdd( aLogTitle , STR0003 )	//"Foram Encontradas as Seguintes Inconsistencias no Calculo das Rescisoes:"
				aLogFile := {{},{}}
			Else
				aLogFile := {{}}
			EndIf
			aAdd( aLogTitle , STR0004 )	//"Funcionários Processados:"
			
			nPos := 1
			
			For nX := 1 to Len(aLogAux)
				If !lTemErro .and. nX == 1
					Loop
				EndIf
				For nY := 1 to Len(aLogAux[nX])
					aAdd(aLogFile[nPos],aLogAux[nX,nY])
				Next nY
				nPos++
			Next nX
		Else
			Help(' ', 1, "PARVAZIO", , STR0005, 1, 0) //"Os parâmetros para cálculo não foram preenchidos."
		EndIf
	EndIf
Else
	If cPaisLoc == "BRA"
		Aeval(aMarcAux,{ |x| aAdd(_MarcReg, x[1]) })
	Else
		Aeval(aMarcAux,{ |x| aAdd(_MarcReg, x[3]) })
	EndIf
	GPEM630(,cProcAux)
	For nX := 1 to Len(aGpm040Log)
		If Len(aGpm040Log[nX]) > 0
			If nX == 1
				aAdd( aLogTitle , STR0003 )	//"Foram Encontradas as Seguintes Inconsistencias no Calculo das Rescisoes:"
			Else
				aAdd( aLogTitle , STR0004 )	//"Funcionários Processados:"
			EndIf
			aAdd( aLogFile, aGpm040Log[nX] )
		EndIf
	Next nX
EndIf

fMakeLog( aLogFile , aLogTitle , NIL , NIL , FunName() , STR0006 , , , , .f. ) //"Log de Ocorrências do Cálculo de Rescisão"

_MarcReg := aClone(aMarcAux)

Clear()

Return Nil

/*/{Protheus.doc} fLoadParam
Carrega os parâmetros de cada processo
@author Leandro Drumond
@since 01/04/2019
@version P12.1.17
@return aParam
/*/
Static Function fLoadParam(cProc,aParAux,nRot)

Local oDlg
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aRetcoords	:= {}

Local aArea			:= GetArea()
Local aPages		:= {}
Local aFolders		:= {}
Local aObjFolder	:= {}
Local bSet15
Local bSet24
Local bDialogInit
Local lRet			:= .F.

Local oIndAvsPrv
Local oProces
Local oFolders
Local oBtn
Local oChkHabGrab
Local oChkHabTrace
Local oSabDom
Local oMesAtu
Local oTipCalc

Local aIncRes	:= {}
Local aIndAvsPrv:= {}
Local dDataKey	:= CtoD("//") 
Local lHabGrab	:= .F.
Local lHabTrace	:= .F.
Local cModFol 	:= GetMvRH( "MV_MODFOL", .F., "1" )
Local cDiaInde  := Space(3)
Local cDiasCum	:= Space(3)

Private aTipCalc	:= {STR0007,STR0008,STR0009,STR0010} //"Calcular"#"Simular"#"Efetivar"#"Excluir"
Private aSimNao		:= {STR0011,STR0012} //"Sim"#"Não"
Private aNaoSim		:= {STR0012,STR0011} //"Não"#"Sim"
Private cIndAvPrv	:= ""
Private cTabRes		:= ""
Private cTipCalc	:= ""
Private cTpResDesc	:= Space( 50 )
Private cProcAux	:= cProc
Private cRotAux 	:= Space( TamSX3( "RY_CALCULO" )[1] )
Private cProcDesc	:= Space( TamSX3( "RCJ_DESCRI" )[1] )
Private cRotDesc 	:= Space( TamSX3( "RY_DESC" )[1] )
Private cPerAux		:= Space( TamSX3( "RCH_PER" )[1] )
Private cSemAux		:= Space( TamSX3( "RCH_NUMPAG" )[1] )
Private dDataIni	:= CtoD("//")
Private dDataFim	:= CtoD("//")
Private cSabDom		:= ""
Private cMesAtu		:= ""
Private cTipoRes	:= Space(2)
Private dDtAviso	:= CtoD("")
Private cDiasAviso	:= "   "
Private nDiascum	:= 0
Private nDiaInde	:= 0
Private dDataRes	:= CtoD("//")
Private dDataHom	:= CtoD("//")
Private dDataGer	:= CtoD("//")
Private nTamDesc	:= 25
Private nDiasAviso	:= 0

Private cVersEnvio	:= ""
Private cVersGPE	:= ""
Private lIntegra 	:= Iif( FindFunction("fVersEsoc"), fVersEsoc("S2299", .F., /*@aRetGPE*/, /*@aRetTAF*/, @cVersEnvio, @cVersGPE), .F. )

aIndAvsPrv  := Iif( cVersGPE == "2.2", {STR0013, STR0014, STR0015} ,{STR0016, STR0013, STR0014, STR0015, STR0017, STR0018}) //"Não se aplica"#"Cumprimento Total"#"Cump. parcial em razão de obtenção de novo emprego pelo empregado"#"Cumprimento parcial por iniciativa do empregador"#"Outras hipóteses de cumprimento parcial do aviso prévio"#"Aviso prévio indenizado ou não exigível"
aPages		:= If(cModFol == "2", Array( 02 ), Array( 01 ) )
aFolders	:= If(cModFol == "2", Array( 02 ), Array( 01 ) )
aObjFolder	:= If(cModFol == "2", Array( 02 ), Array( 01 ) )

// Define o Conteudo do aPages
aPages[ 01 ] := STR0019	//"Gerais"

// Define o Conteudo do aFolders
aFolders[ 01 ] := STR0019	//"Gerais"

// Define os Elementos para o Array do Objeto Folder
aObjFolder[ 01 ]	:= Array( 01 , 04 )

If cModFol == "2"
	aPages[ 02 ] 	:= STR0020	//"Faixas"
	aFolders[ 02 ] 	:= STR0020	//"Faixas"
	aObjFolder[ 02 ]:= Array( 02 , 04 )
EndIf

bSet15	:= { || lRet := If( Gp040VldCalc(), oDlg:End(), .F. ) }
bSet24	:= { || lRet := .F., oDlg:End() }

If cPaisLoc == "ARG"
	cConsRes := "S12ARG" 
	cTabRes	 := "S012"
	nTamDesc := 25
ElseIf cPaisLoc == "DOM"
	cConsRes := "S10DOM"
	cTabRes	 := "S010"
	nTamDesc := 30
ElseIf cPaisLoc == "COS"
	cConsRes := "S22COS"
	cTabRes	 := "S022"
	nTamDesc := 40
ElseIf cPaisLoc == "BRA"
	cConsRes := "S43BRA"
	cTabRes	 := "S043"
	nTamDesc := 30
EndIf

SetMnemonicos(NIL,NIL,.T.)

Gpm630ProcVld() //Carrega dados do processo

// Monta as Dimensoes dos Objetos
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
aAdd( aObjCoords, { 000, 000, .T., .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

If cModFol == "2"
	aAdd(aButtons, {STR0022, {|| TelaLog()}, OemToAnsi(STR0021), OemToAnsi(STR0023)}) // "Consulta Logs de Calculo"##"Logs"

	// Define o Bloco para a Inicializacao do Dialog
	bDialogInit		:= { ||;
								CursorWait()													,;
								oProces:SetFocus()												,;
								EnchoiceBar( oDlg , bSet15 , bSet24, NIL , aButtons )			,;
								CursorArrow()													 ;
						}
Else
	// Bloco de Inicialização da Janela
	bDialogInit 	:= { || CursorWait()													,;
							oProces:SetFocus()												,;
							EnchoiceBar( oDlg , bSet15 , bSet24, NIL ),;
							CursorArrow();
						}
EndIf

DEFINE MSDIALOG oDlg Title STR0024 + cProcAux From aAdvSize[7],000 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL
			
	oDlg:lEscClose := .F. // Nao permite sair ao se pressionar a tecla ESC.
	
	// Carrega o Objeto Folder
	oFolders := TFolder():New(	aObjSize[1,1]			,;
								aObjSize[1,2]			,;
								aFolders				,;
								aPages					,;
								oDlg					,;
								NIL						,;
								NIL						,;
								NIL						,;
								.T.						,;
								.F.						,;
								aObjSize[1,4]			,;
								aObjSize[1,3]			 ;
							 )
	
	// Dados do folder - Gerais
	aRetcoords := RetCoords(4,14,55,15,2,40,,oFolders:OWND:NTOP)
	
	@aRetcoords[1][1], aRetcoords[1][2] SAY STR0025 SIZE 040, 007 OF oFolders:aDialogs[01] PIXEL	//"Tipo de Calculo: "
	@aRetcoords[2][1], aRetcoords[2][2] COMBOBOX oTipCalc VAR cTipCalc ITEMS aTipCalc SIZE 050, 007 OF oFolders:aDialogs[01] PIXEL
	
	@aRetcoords[5][1], aRetcoords[5][2] SAY STR0026 SIZE 033, 007 OF oFolders:aDialogs[01] PIXEL	//"Processo: "
	@aRetcoords[6][1], aRetcoords[6][2] MSGET oProces VAR cProcAux SIZE 040, 007 OF oFolders:aDialogs[01] PIXEL PICTURE ;
																PesqPict("RCJ","RCJ_CODIGO") F3 "RCHCOL"
	
	@aRetcoords[7][1]	,aRetcoords[7][2] SAY   STR0027 SIZE 033,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Descricao: "
	@aRetcoords[8][1]	,aRetcoords[8][2] MSGET cProcDesc SIZE 140,007	OF oFolders:aDialogs[ 01 ] PIXEL WHEN .F.
	
	
	@aRetcoords[9][1]	,aRetcoords[9][2] SAY   STR0028 SIZE 033,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Roteiro: "
	@aRetcoords[10][1]	,aRetcoords[10][2] MSGET cRotAux  SIZE 040,007	OF oFolders:aDialogs[ 01 ] PIXEL WHEN .F. PICTURE ;
																PesqPict("SRY","RY_CALCULO") HASBUTTON  
															    
	@aRetcoords[11][1]  ,aRetcoords[11][2] SAY   STR0027 SIZE 033,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Descricao: "
	@aRetcoords[12][1]  ,aRetcoords[12][2] MSGET cRotDesc SIZE 140,007 OF oFolders:aDialogs[ 01 ] PIXEL WHEN .F.
	
	
	@aRetcoords[13][1]	,aRetcoords[13][2] SAY   STR0029 SIZE 033,007   OF oFolders:aDialogs[ 01 ] PIXEL	//"Periodo: "
	@aRetcoords[14][1]	,aRetcoords[14][2] MSGET cPerAux SIZE 040,007 OF oFolders:aDialogs[ 01 ] PIXEL WHEN .F.
	
	@aRetcoords[15][1]	,aRetcoords[15][2] SAY   STR0030 SIZE 038,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Nro Pagto: "
	@aRetcoords[16][1]	,aRetcoords[16][2] MSGET cSemAux SIZE 040,007 OF oFolders:aDialogs[ 01 ] PIXEL WHEN .F.
	
	@aRetcoords[17][1]	,aRetcoords[17][2] SAY   STR0031 SIZE 038,007  OF oFolders:aDialogs[ 01 ] PIXEL	//"Data Inicio: "
	@aRetcoords[18][1]	,aRetcoords[18][2] MSGET dDataIni SIZE 050,007 OF oFolders:aDialogs[ 01 ] PIXEL WHEN .F. HASBUTTON
	
	@aRetcoords[19][1]	,aRetcoords[19][2] SAY   STR0032 SIZE 033,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Data Fim: "
	@aRetcoords[20][1]	,aRetcoords[20][2] MSGET dDataFim SIZE 050,007	OF oFolders:aDialogs[ 01 ] PIXEL WHEN .F. HASBUTTON
	
	If cModFol == "1"
		@aRetcoords[21][1]	,aRetcoords[21][2] SAY   STR0033 SIZE 090,007  OF oFolders:aDialogs[ 01 ] PIXEL	//"Paga Sab. Dom.: "
		@aRetcoords[22][1]	,aRetcoords[22][2] COMBOBOX oSabDom VAR cSabDom ITEMS aSimNao SIZE 040,007 PIXEL OF oFolders:aDialogs[ 01 ]
		@aRetcoords[23][1]	,aRetcoords[23][2] SAY   STR0034 SIZE 083,007    OF oFolders:aDialogs[ 01 ] PIXEL //"Mês Atual para Média: "
		@aRetcoords[24][1]	,aRetcoords[24][2] COMBOBOX oMesAtu VAR cMesAtu ITEMS aNaoSim SIZE 140,007 PIXEL OF oFolders:aDialogs[ 01 ] WHEN !Empty(cSabDom)
		nPosTela := 25
	Else
		nPosTela := 21
	EndIf
	
	@aRetcoords[nPosTela][1]	,aRetcoords[nPosTela][2] SAY   STR0035 SIZE 040,007  OF oFolders:aDialogs[ 01 ] PIXEL //"Tipo Rescisao: "
	nPosTela++
	@aRetcoords[nPosTela][1]	,aRetcoords[nPosTela][2] MSGET cTipoRes SIZE 040,007 OF oFolders:aDialogs[ 01 ] PIXEL WHEN ( !Empty(cProcAux) ) F3 cConsRes VALID ;
																(Iif( Empty(cTipoRes),cTpResDesc := "", ( fIncRes(SRA->RA_FILIAL,cTipoRes,@aIncRes,@nPercFgts,@cRescrais,@cAfasfgts,@Cod_Am), ;
																cTpResDesc:= fDescRCC(cTabRes,cTipoRes,1,2,3,nTamDesc), lRet := .T.))) HASBUTTON
	nPosTela++
	@aRetcoords[nPosTela][1]	,aRetcoords[nPosTela][2] SAY   STR0027 SIZE 033,007    OF oFolders:aDialogs[ 01 ] PIXEL	//"Descrição: "
	nPosTela++
	@aRetcoords[nPosTela][1]	,aRetcoords[nPosTela][2] MSGET cTpResDesc SIZE 140,007 OF oFolders:aDialogs[ 01 ] PIXEL WHEN .F. //PICTURE 
	
	
	If cPaisLoc == "BRA"
		
		nPosTela++
		@aRetcoords[nPosTela][1]	,aRetcoords[nPosTela][2] SAY   STR0036 SIZE 040,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Data do Aviso: "
		nPosTela++
		@aRetcoords[nPosTela][1]	,aRetcoords[nPosTela][2] MSGET dDtAviso SIZE 050,007	OF oFolders:aDialogs[ 01 ] PIXEL WHEN .T. HASBUTTON	
		
		nPosTela++
		@aRetcoords[nPosTela][1]	,aRetcoords[nPosTela][2] SAY   STR0037 SIZE 040,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Dias Aviso: "
		nPosTela++
		@aRetcoords[nPosTela][1]	,aRetcoords[nPosTela][2] MSGET cDiasAviso SIZE 050,007	OF oFolders:aDialogs[ 01 ] PIXEL WHEN !Empty(cTipoRes) VALID (If(!Empty(cDiasAviso),(nDiasAviso := Val(cDiasAviso), GP40DiasAv(@dDtAviso,nDiasAviso,If(Len(aIncRes)>0,aIncRes[2],'')),.T.),.T.)) PICTURE "999" HASBUTTON
		
		nPosTela++
		@aRetcoords[nPosTela][1]	,aRetcoords[nPosTela][2] SAY   STR0038 SIZE 040,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Dias Av. Cump.: "
		nPosTela++
		@aRetcoords[nPosTela][1]	,aRetcoords[nPosTela][2] MSGET cDiascum SIZE 050,007	OF oFolders:aDialogs[ 01 ] PIXEL WHEN !Empty(cTipoRes) VALID (If(!Empty(cDiasAviso),(nDiasAviso := Val(cDiasAviso), nDiasCum := Val(cDiasCum), GP40DiasAv(@dDtAviso,nDiasAviso,If(Len(aIncRes)>0,aIncRes[2],''),@nDiasCum),.T.),.T.),nDiasCum := Val(cDiasCum),.T.) PICTURE "999" HASBUTTON
		
		nPosTela++
		@aRetcoords[nPosTela][1]	,aRetcoords[nPosTela][2] SAY   STR0039 SIZE 040,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Dias Av. Inde.: "
		nPosTela++
		@aRetcoords[nPosTela][1]	,aRetcoords[nPosTela][2] MSGET cDiaInde SIZE 050,007	OF oFolders:aDialogs[ 01 ] PIXEL WHEN !Empty(cTipoRes) VALID (If(!Empty(cDiasAviso),(nDiasAviso := Val(cDiasAviso), nDiaInde := Val(cDiaInde), GP40DiasAv(@dDtAviso,nDiasAviso,If(Len(aIncRes)>0,aIncRes[2],''),,@nDiaInde),.T.),.T.),nDiaInde := Val(cDiaInde),.T.) PICTURE "999" HASBUTTON
		
	Endif
		
	nPosTela++
	@aRetcoords[nPosTela][1]	,aRetcoords[nPosTela][2] SAY   STR0040 SIZE 040,007  OF oFolders:aDialogs[ 01 ] PIXEL	//"Data Rescisao: "
	nPosTela++
	@aRetcoords[nPosTela][1]	,aRetcoords[nPosTela][2] MSGET dDataRes SIZE 050,007 OF oFolders:aDialogs[ 01 ] PIXEL WHEN !Empty(cTipoRes) VALID Gp630VldDat(1) HASBUTTON
	
	nPosTela++
	@aRetcoords[nPosTela][1]	,aRetcoords[nPosTela][2] SAY   STR0041 SIZE 040,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Data Homolog: "
	nPosTela++
	@aRetcoords[nPosTela][1]	,aRetcoords[nPosTela][2] MSGET dDataHom SIZE 050,007	OF oFolders:aDialogs[ 01 ] PIXEL WHEN !Empty(dDataRes) HASBUTTON
	
	nPosTela++
	@aRetcoords[nPosTela][1]	,aRetcoords[nPosTela][2] SAY   STR0042 SIZE 040,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Data Geração: "
	nPosTela++
	@aRetcoords[nPosTela][1]	,aRetcoords[nPosTela][2] MSGET dDataGer SIZE 050,007	OF oFolders:aDialogs[ 01 ] PIXEL WHEN !Empty(dDataHom) VALID Gp630VldDat(2) HASBUTTON
	
	If ( cVersGPE >= "2.2" )
		nPosTela++
		@aRetcoords[nPosTela][1]	,aRetcoords[nPosTela][2] SAY   STR0043 SIZE 040,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Indic. de cumprimento de Aviso Prévio"
		nPosTela++
		@aRetcoords[nPosTela][1]	,aRetcoords[nPosTela][2] COMBOBOX oIndAvsPrv VAR cIndAvPrv ITEMS aIndAvsPrv SIZE 140,007	OF oFolders:aDialogs[ 01 ] PIXEL
	EndIf
	
	If cModFol == "2"
		nPosTela++
		@aRetcoords[nPosTela][1]	,aRetcoords[nPosTela][2] SAY   STR0044 SIZE 040,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Data Pgto: "
		nPosTela++
		@aRetcoords[nPosTela][1]	,aRetcoords[nPosTela][2] MSGET dDataKey SIZE 050,007	OF oFolders:aDialogs[ 01 ] PIXEL WHEN !Empty(dDataGer) HASBUTTON
		
		nPosTela++
		@aRetcoords[nPosTela][1]	,aRetcoords[nPosTela][2] CHECKBOX oChkHabGrab  VAR lHabGrab PROMPT OemToAnsi(STR0045) SIZE 100,08 OF oFolders:aDialogs[ 01 ] PIXEL //"Habilitar Gravacao"
		nPosTela++
		@aRetcoords[nPosTela][1]	,aRetcoords[nPosTela][2] CHECKBOX oChkHabTrace VAR lHabTrace PROMPT OemToAnsi( STR0046 ) SIZE 100,08 OF oFolders:aDialogs[ 01 ] PIXEL //"Habilitar TRACE"
	ElseIf cPaisLoc <> "BRA"
		nPosTela++
		@aRetcoords[nPosTela][1]	,aRetcoords[nPosTela][2] SAY   STR0047 SIZE 040,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Dias Aviso: "
		nPosTela++
		@aRetcoords[nPosTela][1]	,aRetcoords[nPosTela][2] MSGET cDiasAviso SIZE 050,007	OF oFolders:aDialogs[ 01 ] PIXEL WHEN !Empty(dDataGer) VALID (If(!Empty(cDiasAviso),(nDiasAviso := Val(cDiasAviso), GP40DiasAv(@dDtAviso,nDiasAviso),.T.),.T.)) HASBUTTON
		
		nPosTela++
		@aRetcoords[nPosTela][1]	,aRetcoords[nPosTela][2] SAY   STR0048 SIZE 040,007 OF oFolders:aDialogs[ 01 ] PIXEL	//"Data do Aviso: "
		nPosTela++
		@aRetcoords[nPosTela][1]	,aRetcoords[nPosTela][2] MSGET dDtAviso SIZE 050,007	OF oFolders:aDialogs[ 01 ] PIXEL WHEN !Empty(dDataGer) HASBUTTON	
	EndIf
	
	If nRot > 0 //Exibe botão para copiar informações do processo anterior
		nPosTela+=3
		@aRetcoords[nPosTela][1]	,aRetcoords[nPosTela][2] BUTTON oBtn PROMPT STR0049 SIZE 040,007 PIXEL OF oFolders:aDialogs[ 01 ] ACTION fLoadParAnt() //Copiar
		oBtn:cTOOLTIP := STR0050 //"Carrega as informações preenchidas no processo anterior"
	EndIf
	
ACTIVATE DIALOG oDlg ON INIT Eval( bDialogInit ) CENTERED

If lRet

	If ( cVersGPE >= "2.2" )
	 	aParAux := Array(18)
		aParAux[18] := cIndAvPrv
	Else
		aParAux := Array(17)
	EndIf
	aParAux[01] := cTipCalc	 
	aParAux[02] := cProcAux	 
	aParAux[03] := cRotAux	 
	aParAux[04] := cPerAux	 
	aParAux[05] := cSemAux	 
	aParAux[06] := dDataIni	 
	aParAux[07] := dDataFim	 
	aParAux[08] := cSabDom	 
	aParAux[09] := cMesAtu	 
	aParAux[10] := cTipoRes	 
	aParAux[11] := dDtAviso	 
	aParAux[12] := cDiasAviso 
	aParAux[13] := nDiascum	 
	aParAux[14] := nDiaInde	 
	aParAux[15] := dDataRes	 
	aParAux[16] := dDataHom	 
	aParAux[17] := dDataGer	 
	
EndIf

RestArea(aArea)

Return lRet

/*/{Protheus.doc} fLoadParAnt
Carrega os parâmetros incluídos no processo anterior
@author Leandro Drumond
@since 02/04/2019
@version P12.1.17
@return .T.
/*/
Static Function fLoadParAnt()
Local nTam 	:= Len(aParam)

If nTam > 0
	If ( cVersGPE >= "2.2" )
		cIndAvPrv := aParam[nTam,18] 
	EndIf
	cTipCalc	:= aParam[nTam,01]
	cSabDom	 	:= aParam[nTam,08]
	cMesAtu  	:= aParam[nTam,09]
	cTipoRes 	:= aParam[nTam,10]
	cTpResDesc  := fDescRCC(cTabRes,cTipoRes,1,2,3,nTamDesc)	 
	dDtAviso 	:= aParam[nTam,11]	 
	cDiasAviso 	:= aParam[nTam,12] 
	nDiascum 	:= aParam[nTam,13] 	 
	nDiaInde 	:= aParam[nTam,14]	 
	dDataRes 	:= aParam[nTam,15]	 
	dDataHom 	:= aParam[nTam,16]	 
	dDataGer 	:= aParam[nTam,17]	 
EndIf

Return .T.

/*/{Protheus.doc} Gp040VldCalc
Valida parametros da rescisao coletiva
@author Leandro Drumond
@since 02/04/2019
/*/
Function Gp040VldCalc()

Local lRet 		:= .T.
Local cMotESOC 	:= fGP40TPRES( cTipoRes)
Local lMotEsoc  := .F.
Local lNT15 	:= .F.
Local cVersESoc	:= "2.2"
Local cTipAux	:= ""

DEFAULT lIntTaf	:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 1 )

Begin Sequence

	cTipAux := AllTrim(STR(aScan( aTipCalc, {|x| x == cTipCalc} )))
	
	If nDiasAviso >0 .and. Empty(dDtAviso)
		Help( ,, OemToAnsi(STR0051),, STR0052 , 1, 0 )//"Atenção"##"Digite a Data de Aviso Prévio"
		lRet := .F.
		Break
	EndIf

	If Empty(dDataRes) .or. dDataRes < dDataIni .or. dDataRes > dDataFim
		Help( ,, OemToAnsi(STR0051),, OemToAnsi(STR0053) , 1, 0 )//"Atenção"##"Data de Demissão deve pertencer ao período informado"
		lRet := .F.
		Break
	EndIf
	
	If Empty(dDataHom)
		Help( ,, OemToAnsi(STR0051),, OemToAnsi(STR0054) , 1, 0 )//"Atenção"##"Preencha a data de Homologação"
		lRet := .F.
		Break
	EndIf
	
	If Empty(dDataGer) .or. dDataGer < dDataIni .or. dDataGer > dDataFim
		Help( ,, OemToAnsi(STR0051),, OemToAnsi(STR0055) , 1, 0 )//"Atenção"##"Data de Geração deve pertencer ao período informado"
		lRet := .F.
		Break
	EndIf

	//Verifica se versão do eSocial e o preenchimento do cumprimento do aviso prévio (mv_par38)      
	If cPaisLoc == "BRA" .And. !Empty(cTipoRes) .And. lIntTaf .And. cTipAux != "4"
		If cEFDAviso <> "2"
			lMotEsoc := cMotESOC $ ("02|03|04|07")

			If ExistFunc("fVersEsoc")
				fVersEsoc( "S2299", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersESoc, , , @lNT15)
			Endif 
			
			If !lNT15 .And. ( Empty(cIndAvPrv) .Or. cIndAvPrv == "9" ) .And. ( cVersESoc > '2.3' .OR. (lMotEsoc .And. cVersESoc == '2.3' ))
				//Atenção ### "Quando motivo de desligamento eSocial (ref. ao tipo de rescisão) for 02, 03, 04 ou 07, é obrigatório o preenchimento do campo 'Cump Aviso'." ### OK
				If cEfdAviso == "1"
					Help( ,, OemToAnsi(STR0051),, If(cVersESoc > '2.3', OemToAnsi(STR0056),OemToAnsi("OK")) , 1, 0 )
					lRet := .F.
					Break
				ElseIf !IsBlind()
					MsgAlert(If(cVersESoc > '2.3', OemToAnsi(STR0056),OemToAnsi("OK")), OemToAnsi(STR0051) )	// "Atenção ### "Quando motivo de desligamento eSocial (ref. ao tipo de rescisão) for 02, 03, 04 ou 07, é obrigatório o preenchimento do campo 'Cump Aviso'." ### OK "
				Endif
			EndIf
			
			If Empty(cMotEsoc)
				If cEfdAviso == "1"
					Help( ,, OemToAnsi(STR0051),, OemToAnsi(STR0057) + CRLF + CRLF + OemToAnsi(STR0058), 1, 0 ) // "Atenção ### "O motivo da rescisão não foi informado e é obrigatório para o eSocial.""Para informar o motivo, preencha o campo Mot. eSocial da tabela S043 - Tipos de Rescisão."
					lRet := .F.
					Break
				ElseIf !IsBlind()
					MsgAlert(OemToAnsi(STR0057) + CRLF + OemToAnsi(STR0058), OemToAnsi(STR0051) )	// "Atenção ### "O motivo da rescisão não foi informado e é obrigatório para o eSocial.""Para informar o motivo, preencha o campo Mot. eSocial da tabela S043 - Tipos de Rescisão." 
				Endif
			Endif
		Endif
	EndIf

End Sequence

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MenuDef   ºAutor  ³Leandro Drumond     º Data ³  04/04/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Menu Funcional                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAGPE                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()

Private aRotina :=  {}

ADD OPTION aRotina TITLE STR0059 ACTION 'Gp040BCalc()'			OPERATION 4 ACCESS 0 //"Calcular"
ADD OPTION aRotina Title OemToAnsi(STR0060) Action 'Clear()' OPERATION 7  ACCESS 0 // Limpar marcações

Return aRotina
