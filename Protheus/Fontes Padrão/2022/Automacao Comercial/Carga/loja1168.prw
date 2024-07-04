#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA1168.CH"

// O protheus necessita ter ao menos uma função pública para que o fonte seja exibido na inspeção de fontes do RPO.
Function LOJA1168() ; Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º     Classe: ³ LJCInitialLoadSpecialTableSBIConfigurator ³ Autor: Vendas CRM ³ Data: 16/10/10 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º  Descrição: ³ Configurador da tabela especial SBI.                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Class LJCInitialLoadSpecialTableSBIConfigurator
	Method New()
	Method Configure()
EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º     Método: ³ New                               ³ Autor: Vendas CRM ³ Data: 16/10/10 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º  Descrição: ³ Construtor.                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros: ³ Nenhum.                                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º    Retorno: ³ Self                                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method New() Class LJCInitialLoadSpecialTableSBIConfigurator
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º     Método: ³ Configure                         ³ Autor: Vendas CRM ³ Data: 16/10/10 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º  Descrição: ³ Configura a tabela especial.                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros: ³ oSpecialTable: Objeto do tipo LJCInitialLoadSpecialTable.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º    Retorno: ³ lSave: Se houve alteração na configuração da tabela.                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method Configure( oSpecialTable ) Class LJCInitialLoadSpecialTableSBIConfigurator
	Local oDlgConfigure		:= Nil
	Local oLblTableName		:= Nil	
	Local oTableName		:= Nil	
	Local oLblFilter		:= Nil	
	Local oFilter			:= Nil
	Local cFilter			:= Space(200)
	Local oBtnWizard		:= Nil	
	Local oLbxBranches		:= Nil
	Local nLbxBranches		:= 0
	Local oLblBranches		:= Nil
	Local oLblObs			:= Nil
	Local oBtnSave			:= Nil
	Local oBtnCancel		:= Nil
	Local lSave				:= .F.
	Local aBranches			:= {}
	Local nCount			:= 0
	Local aNewBranches		:= {}
	Local lExclusiceTable	:= .F.
	
	// Configura inicialmente os parâmetros
	If Len(oSpecialTable:aParams) == 0
		oSpecialTable:aParams := { {}, }
	EndIf
	
	cFilter := PaDR(oSpecialTable:aParams[2],200)
	
	// Verifica se o tabela é exclusive
	// No caso do SBI o tabela que determina o modo de distribuição é o SB0
	lExclusiveTable := AllTrim(FWModeAccess("SB0",3)) == "E"			
	
	DEFINE MSDIALOG oDlgConfigure TITLE STR0001 FROM 000, 000  TO 330, 360 COLORS 0, 16777215 PIXEL // "Configurar transferência especial"

	@ 005, 005 SAY oLblTableName PROMPT STR0002 SIZE 020, 007 OF oDlgConfigure  PIXEL	 // "Tabela:"
	@ 005, 025 SAY oTableName PROMPT oSpecialTable:cTable SIZE 038, 007 OF oDlgConfigure PIXEL	
	@ 015, 005 SAY oLblFilter PROMPT STR0003 SIZE 015, 007 OF oDlgConfigure PIXEL // "Filtro:"
	@ 015, 020 GET oFilter VAR cFilter OF oDlgConfigure MULTILINE SIZE 092, 063 HSCROLL PIXEL
	@ 015, 120 BUTTON oBtnWizard PROMPT STR0004 SIZE 037, 012 OF oDlgConfigure PIXEL ACTION (cFilter := BuildExpr( "SB1",, @cFilter ))// "Assistente"
	@ 085, 005 SAY oLblObs PROMPT STR0011 SIZE 170, 007 OF oDlgConfigure PIXEL	 // "Para tabelas compartilhadas, não será possível selecionar a filial."
	@ 095, 005 SAY oLblBranches PROMPT STR0005 SIZE 015, 007 OF oDlgConfigure PIXEL	 // "Filiais:"
	@ 095, 020 LISTBOX oLbxBranches Fields Header "", STR0006, STR0007, STR0008 When lExclusiveTable Size 150, 048 Pixel Of oDlgConfigure ON DBLCLICK ( oLbxBranches:aArray[oLbxBranches:nAt][1] := !oLbxBranches:aArray[oLbxBranches:nAt][1], oLbxBranches:Refresh() ) // "Empresa" "Filial" "Descrição"
	@ 150, 070 BUTTON oBtnSave PROMPT STR0009 SIZE 037, 012 OF oDlgConfigure ACTION (If (Loj1149Vld(lExclusiveTable, oLbxBranches:aArray), (lSave := .T., aBranches := oLbxBranches:aArray, oDlgConfigure:End()), Nil)) PIXEL	 // "Salvar"
	@ 150, 130 BUTTON oBtnCancel PROMPT STR0010 SIZE 037, 012 OF oDlgConfigure ACTION oDlgConfigure:End() PIXEL	 // "Cancelar"
	
	DbSelectArea( "SM0" )
	DbSetOrder(1)
	DbGoTop()
	
	aBranches := {}
	While !SM0->(EOF()) 
		If cEmpAnt == SM0->M0_CODIGO
			aAdd( aBranches, { If(aScan( oSpecialTable:aParams[1], {|x| x == AllTrim(SM0->M0_CODFIL)}) > 0,.T.,.F.), AllTrim(SM0->M0_CODIGO), AllTrim(SM0->M0_CODFIL), AllTrim(SM0->M0_NOME) } )		
		EndIf
		SM0->(DbSkip())
	End
	
	oLbxBranches:SetArray( aBranches )
	oLbxBranches:bLine := {||	{	If( aBranches[oLbxBranches:nAt][1], LoadBitmap( GetResources(), "LBOK" ), LoadBitmap( GetResources(), "LBNO" ) ),;
									aBranches[oLbxBranches:nAt][2],;
									aBranches[oLbxBranches:nAt][3],;
									aBranches[oLbxBranches:nAt][4];
								} }								
	
	ACTIVATE MSDIALOG oDlgConfigure CENTERED
	
	If lSave
		oSpecialTable:aParams[2] := cFilter		
		
		If lExclusiveTable
			aNewBranches := {}
			For nCount := 1 To Len( aBranches )
				If aBranches[nCount][1]
					aAdd( aNewBranches, aBranches[nCount][3] )
				EndIf
			Next
			oSpecialTable:aParams[1] := aNewBranches
		Else
			oSpecialTable:aParams[1] := { xFilial(oSpecialTable:cTable) }
		EndIf
	EndIf
Return lSave

