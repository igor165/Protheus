#INCLUDE "WFA001.CH"
#INCLUDE "SIGAWF.CH"

/*
	CADASTRO DE STATUS DE PROCESSOS
*/
FUNCTION WFA002( cAlias, nReg, nOpcx )
	local lResult := .t.
	
	default nOpcx := WF_INICIO

	if nOpcx == WF_INICIO
		PRIVATE aRotina := MenuDef()
		PRIVATE cCadastro := OemToAnsi( STR0006 )
			
		ChkFile("WF3")
		DbSelectArea( "WF3" )
		DbSetOrder( 3 ) 

		ChkFile("WF2")
		DbSelectArea( "WF2" )
		DbSetOrder( 1 ) 

		mBrowse( 6, 1, 22, 75, "WF2" )
		WF2->( DbCloseArea() )
		WF3->( DbCloseArea() )
	else
		do case
			case nOpcx == WF_INCLUIR
				lResult := WFIncluir( cAlias, nReg, nOpcx )
			case nOpcx == WF_EXCLUIR
				lResult := WFExcluir( cAlias, nReg, nOpcx )
			case nOpcx == WF_OK
				lResult := WFTudoOk()
		endcase
	end
	
Return lResult

STATIC Function MenuDef()
	local aMenuDef := {}	
	AAdd( aMenuDef,	{ OemToAnsi( STR0001 ), "AxPesqui", 0, WF_PESQUISAR } )
	AAdd( aMenuDef, { OemToAnsi( STR0002 ), "AxVisual", 0, WF_VISUALIZAR } )
	AAdd( aMenuDef,	{ OemToAnsi( STR0003 ), "WFA002", 0, WF_INCLUIR } )
	AAdd( aMenuDef, { OemToAnsi( STR0004 ), "AxAltera", 0, WF_ALTERAR } )
	AAdd( aMenuDef, { OemToAnsi( STR0005 ), "WFA002", 0, WF_EXCLUIR, 3 } )
return aMenuDef

STATIC FUNCTION WFIncluir( cAlias, nReg, nOpc )
	Local nOpcA
	Local lResult := .t.
	Local bCampo := { |nCPO| Field(nCPO) }
	
	PRIVATE aTELA[0][0], aGETS[0]

	INCLUI := .T.
	ALTERA := .F.

	while .T.
		nOpcA:=0
		nOpcA := AxInclui( cAlias, nReg, nOpc,,,, "WFA002(,," + Str( WF_OK ) + ")" )
		dbSelectArea(cAlias)
		if nOpcA = 3
		  Exit
		end
	end
	
	dbSelectArea(cAlias)
Return lResult

STATIC FUNCTION WFExcluir( cAlias, nReg, nOpc )
	Local oDlg
	Local nOpcA := 0
	Local lResult := .t.
	Local aAC := { STR0008, STR0009 }
	Local bCampo := {|nCPO| Field(nCPO) }

	PRIVATE aTELA[0][0], aGETS[0]

   SetColor("n/bg,bg+/b,,,b/bg")
	SoftLock(cAlias)
	
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 28,80 OF oMainWnd
	nOpcA := EnChoice( cAlias, nReg, nOpc, aAC, "AC", OemToAnsi(STR0007) ) // Quant a Exclusao ?
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()}, {|| nOpcA := 1, oDlg:End() } )

   dbSelectArea(cAlias)

   if nOpcA == 2
   	BEGIN TRANSACTION
			dbSelectArea("WF3")
			dbSeek( xFilial("WF3") + WF2->WF2_PROC + WF2->WF2_STATUS )
			if ( WF3_FILIAL + WF3_PROC + WF3_STATUS ) == ( xFilial("WF3") + WF2->WF2_PROC + WF2->WF2_STATUS )
				HELP(" ",1,"W002NODEL")
				dbSelectArea(cAlias)
				MsUnLock()
				BREAK 
			end
			dbSelectArea( cAlias )
			RecLock( cAlias,.F.,.T. )
			dbDelete()
		END TRANSACTION
	else
		MsUnLock()
	end
	dbSelectArea(cAlias)
Return lResult

STATIC FUNCTION WFTudoOk()
	Local lResult
	if ( lResult := ExistChav( "WF2", M->WF2_PROC + M->WF2_STATUS ) )
		if Val( M->WF2_STATUS ) < 1000
			HELP(" ",1,"W002NOUSER")      
			lResult := .f.
		end
	end
return lResult

