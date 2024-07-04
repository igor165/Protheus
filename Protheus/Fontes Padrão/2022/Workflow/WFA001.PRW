#INCLUDE "WFA001.CH"
#INCLUDE "SIGAWF.CH"
#INCLUDE "APVISIO.CH"

#DEFINE FLD_COD			1
#DEFINE FLD_DESCR			2

#DEFINE WF_RASTREAB		6
#DEFINE WF_MSVISIO		7
#DEFINE WF_TEMPLVISIO	8
#DEFINE WF_FLUXOVISIO	9

STATIC cVSDFile


/******************************************************************************
 WFA001()
 Cadastro de Processos
******************************************************************************/
Function WFA001( cAlias, nReg, nOpcx )
	local lResult := .t.
	
	default nOpcx := WF_INICIO

	if nOpcx == WF_INICIO
		ChkFile("WF2")
		DbSelectArea( "WF2" )                                                                                                         	
		dbSetOrder( 1 )
		
		ChkFile("WF1")
		dbSelectArea( "WF1" )
		dbSetOrder( 1 ) 

		PRIVATE aRotina := MenuDef(.F.)
		PRIVATE lBrowser := .t.
	   	PRIVATE cCadastro := OemToAnsi( STR0006 )
   		PRIVATE oVisio
		
		mBrowse( 6, 1, 22, 75, "WF1" )

		if oVisio <> nil
			oVisio:Release()
		end

		WF1->( DbCloseArea() )
		WF2->( DbCloseArea() )
	else
		if oVisio <> nil
			oVisio:Release()
		end
		do case
			case nOpcx == WF_VISUALIZAR
				lResult := WFVisualizar( cAlias, nReg, nOpcx )
			case nOpcx == WF_INCLUIR
				lResult := WFIncluir( cAlias, nReg, nOpcx )
			case nOpcx == WF_ALTERAR
				lResult := WFAlterar( cAlias, nReg, nOpcx )
			case nOpcx == WF_EXCLUIR
				lResult := WFExcluir( cAlias, nReg, nOpcx )
			case nOpcx == WF_RASTREAB
				lResult := WFC001( 0, WF1_COD )
			case nOpcx == WF_MSVISIO
				lResult := WFVisio()
			case nOpcx == WF_TEMPLVISIO
				lResult := WFC004( 0, WF1_COD )
			case nOpcx == WF_OK
				lResult := WFTudoOk()
		endcase
	end                             
	
Return lResult

STATIC Function MenuDef(lisMenuDef)
	
	local aMenuDef := {}
	Default lisMenuDef  := .T.
	
	AAdd( aMenuDef,	{ OemToAnsi( STR0001 ), "AxPesqui", 0, WF_PESQUISAR } )
	AAdd( aMenuDef, { OemToAnsi( STR0002 ), "WFA001", 0, WF_VISUALIZAR } )
	AAdd( aMenuDef,	{ OemToAnsi( STR0003 ), "WFA001", 0, WF_INCLUIR } )
	AAdd( aMenuDef, { OemToAnsi( STR0004 ), "WFA001", 0, WF_ALTERAR } )
	AAdd( aMenuDef, { OemToAnsi( STR0005 ), "WFA001", 0, WF_EXCLUIR, 3 } )
	AAdd( aMenuDef, { OemToAnsi( STR0010 ), "WFA001", 0, WF_RASTREAB } ) //"Rastreabilidade"

	if  !lisMenuDef .and. ApOleClient("MSVISIO")
		AAdd( aMenuDef, { OemToAnsi( STR0011 ), "WFA001", 0, WF_MSVISIO } )
		AAdd( aMenuDef, { OemToAnsi( STR0012 ), "WFA001", 0, WF_TEMPLVISIO } )
	end

return aMenuDef

FUNCTION WF1GetFile()
	cVSDFile := cGetFile("Visio Documentos (*.vsd)| *.vsd", "Microsoft Visio")
	if empty( cVSDFile )
		cVSDFile := M->WF1_VISIO
	end
return !(empty(cVSDFile))

FUNCTION WF1RetFile()
return cVSDFile

/******************************************************************************
 WFVisualizar()
 Inclusao de Processos
******************************************************************************/
STATIC FUNCTION WFVisualizar( cAlias, nReg, nOpc )
	local lResult := .t.
	lBrowser := .f.
	AxVisual( cAlias, nReg, nOpc )
	lBrowser := .t.
Return lResult

/******************************************************************************
 WFAlterar()
 Inclusao de Processos
******************************************************************************/
STATIC FUNCTION WFAlterar( cAlias, nReg, nOpc )
	local lResult := .t.
	lBrowser := .f.
	AxAltera( cAlias, nReg, nOpc )
	lBrowser := .t.
Return lResult

/******************************************************************************
 WFIncluir()
 Inclusao de Processos
******************************************************************************/
STATIC FUNCTION WFIncluir( cAlias, nReg, nOpc )
	Local nOpcA
	Local lResult := .t.
	Local bCampo := { |nCPO| Field(nCPO) }
	
	PRIVATE aTELA[0][0], aGETS[0]

	INCLUI := .T.
	ALTERA := .F.
	lBrowser := .f.

	while nOpcA <> 3
		nOpcA := 0
		nOpcA := AxInclui( cAlias, nReg, nOpc,,,, "WFA001(,," + str( WF_OK ) + ")" )
		dbSelectArea(cAlias)
	end
	
	dbSelectArea(cAlias)
	lBrowser := .t.
Return lResult

/******************************************************************************
 WFExcluir()
 Exclusao de Processos
******************************************************************************/
STATIC FUNCTION WFExcluir( cAlias, nReg, nOpc )
	Local oDlg
	Local nOpcA := 0
	Local lResult := .t.
	Local aAC := { STR0008, STR0009 }
	Local bCampo := {|nCPO| Field(nCPO) }

	PRIVATE aTELA[0][0], aGETS[0]

   SetColor("n/bg,bg+/b,,,b/bg")
	SoftLock(cAlias)
	lBrowser := .f.
	
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 28,80 OF oMainWnd
	nOpcA := EnChoice( cAlias, nReg, nOpc, aAC, "AC", OemToAnsi(STR0007) ) // Quant a Exclusao ?
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()}, {|| nOpcA := 1, oDlg:End() } )

   dbSelectArea(cAlias)

   if nOpcA == 2
   	BEGIN TRANSACTION
			dbSelectArea("WF2")
			dbSeek( xFilial( "WF2" ) + WF1->WF1_COD )
			if ( WF2_FILIAL + WF2_PROC ) == ( xFilial( "WF2" ) + WF1->WF1_COD )
  			   HELP(" ",1,"W001NODEL")
			   dbSelectArea(cAlias)
			   MsUnLock()
			   BREAK 
			End
			dbSelectArea( cAlias )
			RecLock( cAlias,.F.,.T. )
			dbDelete()
		END TRANSACTION
	else
		MsUnLock()
	end

	dbSelectArea(cAlias)
	lBrowser := .t.
Return lResult

STATIC FUNCTION WFTudoOk()
	local cMsg := STR0014 // "Deseja construir o visio template a partir do arquivo "
	local lResult := ExistChav( "WF1", M->WF1_COD )
	local cFileName
	
	if lResult .and. WF1->(FieldPos("WF1_VISIO") ) > 0 
		cFileName := AllTrim( M->WF1_VISIO )
		if !empty( cFileName ) .and. file( cFileName )
			cMsg += Alltrim( cFileName ) + space(1)
			cMsg += STR0015
			if MsgYesNo( cMsg, STR0016 )
				WFC004( 0, M->WF1_COD )
			end
		end
	end
	
Return lResult

STATIC FUNCTION WFVisio()    
	local cFileName := AllTrim( WF1->WF1_VISIO )
	
	if empty( cFileName ) .or. !file( cFileName )
		MsgAlert( STR0017 )
	else
		oVisio := VisioApp():New()
		oVisio:Documents:Open( cFileName )
	end

return .t.
                                    