
#INCLUDE "SIGAWF.CH"

/*
	CADASTRO DE FLUXO DE PROCESSOS
*/
FUNCTION WFA015( cAlias, nReg, nOpcx )
	local lResult := .t.
	
	default nOpcx := WF_INICIO

	if nOpcx == WF_INICIO
		PRIVATE aRotina := MenuDef()
		PRIVATE cCadastro := OemToAnsi( "Cadastro de Fluxo de Processos" )
	
		ChkFile( "WF9" )	
		dbSelectArea( "WF9" )
		dbSetOrder( 1 ) 

		ChkFile( "WF8" )	
		dbSelectArea( "WF8" )
		dbSetOrder( 1 ) 

		mBrowse( 6, 1, 22, 75, "WF8" )
		
		dbSelectArea( "WF9" )
		dbCloseArea()

		dbSelectArea( "WF8" )
		dbCloseArea()
	else
		do case
			case nOpcx == WF_INCLUIR
				lResult := WFIncluir( cAlias, nReg, nOpcx )
			case nOpcx == WF_EXCLUIR
				lResult := WFExcluir( cAlias, nReg, nOpcx )
			case nOpcx == WF_OK
				lResult := WFValidate()
		endcase
	end
	
Return lResult

STATIC Function MenuDef()
	local aMenuDef := {}
	AAdd( aMenuDef,	{ OemToAnsi( "Pesquisar" ), "AxPesqui", 0, WF_PESQUISAR } )
	AAdd( aMenuDef, { OemToAnsi( "Visualizar" ), "AxVisual", 0, WF_VISUALIZAR } )
	AAdd( aMenuDef,	{ OemToAnsi( "Incluir" ), "WFA015", 0, WF_INCLUIR } )
	AAdd( aMenuDef, { OemToAnsi( "Alterar" ), "AxAltera", 0, WF_ALTERAR } )
	AAdd( aMenuDef, { OemToAnsi( "Excluir" ), "WFA015", 0, WF_EXCLUIR, 3 } )
	
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
		nOpcA := AxInclui( cAlias, nReg, nOpc,,,, "WFA015(,," + Str( WF_OK ) + ")" )
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
	Local aAC := { "Cancelar", "Ok" }
	Local bCampo := {|nCPO| Field(nCPO) }

	PRIVATE aTELA[0][0], aGETS[0]

   SetColor("n/bg,bg+/b,,,b/bg")
	SoftLock(cAlias)
	
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 28,80 OF oMainWnd
	nOpcA := EnChoice( cAlias, nReg, nOpc, aAC, "AC", OemToAnsi("Quant a Exclusao ?") )
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()}, {|| nOpcA := 1, oDlg:End() } )

   if nOpcA == 2
   	BEGIN TRANSACTION
			dbSelectArea("WF9")
			dbSelectArea( 2 )
			while dbSeek( xFilial("WF9") + WF8->WF8_CODIGO )
				if RecLock( "WF9",.F. )
					dbDelete()
				end
			end
			dbSelectArea( cAlias )
			RecLock( cAlias,.F.,.T. )
			dbDelete()
		END TRANSACTION
	else
		MsUnLock()
	end
	
Return lResult

STATIC FUNCTION WFValidate()
Return ExistChav( "WF8", M->WF8_CODIGO )

