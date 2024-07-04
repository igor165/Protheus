#INCLUDE "JURA074.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWMBROWSE.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA074
Cadastro de Protocolos 

@author Andréia S. N. de Lima
@since 15/03/10                                   
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA074()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NXH" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NXH" )
JurSetBSize( oBrowse )
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Andréia S. N. de Lima
@since 15/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina   := {}
Local lPDUserAc := Iif(FindFunction("JPDUserAc"), JPDUserAc(), .T.) // Indica se o usuário possui acesso a dados sensíveis ou pessoais (LGPD)

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA074", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA074", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA074", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA074", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA074", 0, 6, 0, NIL } ) // "Imprimir"
aAdd( aRotina, { STR0025, 'JAGerAut()'     , 0, 3, 0, NIL } ) // "Geração Automática"
If lPDUserAc
	aAdd( aRotina, { STR0013, 'JA074AQry()'    , 0, 3, 0, NIL } ) // "Relat. Protocolo"
	aAdd( aRotina, { STR0014, 'JA074BQry()'    , 0, 3, 0, NIL } ) // "Listar Protocolos"
EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Protocolos

@author Andréia S. N. de Lima
@since 15/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel     := FWLoadModel( "JURA074" )
Local oStructNXH := FWFormStruct( 2, "NXH" )
Local oStructNXI := FWFormStruct( 2, "NXI" )
Local oStructNXJ := FWFormStruct( 2, "NXJ" )

oStructNXI:RemoveField( "NXI_CPROT" )
oStructNXJ:RemoveField( "NXJ_CPROT" )

JurSetAgrp( 'NXH',, oStructNXH )

oView := FWFormView():New()
oView:SetModel( oModel ) 
oView:AddField( "JURA074_VIEW", oStructNXH, "NXHMASTER"  )

oView:AddGrid(  "JURA074_NXI" , oStructNXI, "NXIDETAIL"  )
oView:AddGrid(  "JURA074_NXJ" , oStructNXJ, "NXJDETAIL"  )

oView:CreateFolder("FOLDER_01")

oView:AddSheet("FOLDER_01", "ABA_01_01", STR0007) //"Protocolo"
oView:AddSheet("FOLDER_01", "ABA_01_02", STR0010) //"Faturas"
oView:AddSheet("FOLDER_01", "ABA_01_03", STR0011) //"Vias do Protocolo"

oView:createHorizontalBox("BOX_01_F01_A01",100,,,"FOLDER_01","ABA_01_01")
oView:createHorizontalBox("BOX_02_F01_A01",100,,,"FOLDER_01","ABA_01_02")
oView:createHorizontalBox("BOX_03_F01_A01",100,,,"FOLDER_01","ABA_01_03")

oView:SetOwnerView( "JURA074_VIEW" , "BOX_01_F01_A01" )
oView:SetOwnerView( "JURA074_NXI"  , "BOX_02_F01_A01" )
oView:SetOwnerView( "JURA074_NXJ"  , "BOX_03_F01_A01" )

oView:AddIncrementField( "JURA074_NXJ", "NXJ_COD"  )  

oView:SetDescription( STR0007 ) // "Protocolos"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
"Protocolos"

@author Andréia S. N. de Lima
@since 15/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel      := NIL
Local oStructNXH  := FWFormStruct( 1, "NXH" )
Local oStructNXI  := FWFormStruct( 1, "NXI" )
Local oStructNXJ  := FWFormStruct( 1, "NXJ" )

oStructNXI:RemoveField( "NXI_CPROT" )
oStructNXJ:RemoveField( "NXJ_CPROT" )

oModel:= MPFormModel():New( "JURA074",   /*Pre-Validacao*/,/*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NXHMASTER", NIL, oStructNXH, /*Pre-Validacao*/, /*Pos-Validacao*/ )

oModel:AddGrid  ( "NXIDETAIL", "NXHMASTER" /*cOwner*/, oStructNXI, /*bLinePre*/, {|oModel| JA074VFAT(oModel)}/*bLinePost*/, /*bPre*/, /*bPost*/ )
oModel:AddGrid  ( "NXJDETAIL", "NXHMASTER" /*cOwner*/, oStructNXJ, /*bLinePre*/, /*bLinePost*/, /*bPre*/,  /*bPost*/ )

oModel:GetModel( "NXIDETAIL" ):SetUniqueLine( { "NXI_CFAT", "NXI_CESCR" } )

oModel:SetRelation( "NXIDETAIL", { { "NXI_FILIAL", "xFilial('NXI')" } , { "NXI_CPROT", "NXH_COD" } } , NXI->( IndexKey( 1 ) ) )
oModel:SetRelation( "NXJDETAIL", { { "NXJ_FILIAL", "xFilial('NXJ')" } , { "NXJ_CPROT", "NXH_COD" } } , NXJ->( IndexKey( 1 ) ) )

oModel:SetDescription( STR0008 ) // "Modelo de Dados de Tipo de Protocolos"
oModel:GetModel( "NXHMASTER" ):SetDescription( STR0009 ) // "Dados Protocolos"
oModel:GetModel( "NXIDETAIL" ):SetDescription( STR0010 ) // "Faturas"
oModel:GetModel( "NXJDETAIL" ):SetDescription( STR0011 ) // "Vias do Protocolo"

oModel:GetModel( "NXIDETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NXJDETAIL" ):SetDelAllLine( .T. )
oModel:SetOptional( "NXJDETAIL", .T. )

JurSetRules( oModel, 'NXHMASTER',, 'NXH' )
JurSetRules( oModel, 'NXIDETAIL',, 'NXI' )
JurSetRules( oModel, 'NXJDETAIL',, 'NXJ' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA074SUGES
Rotina para sugerir a Razão Social e o endereço conforme a fatura.

@author Andréia S. N. de Lima
@since 16/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA074SUGES()
Local cQuery  := ''
Local cResQRY := GetNextAlias()
Local aArea   := GetArea()
Local lRet    := .T.
Local oModel  := FWModelActive()
Local cFatura := (M->NXH_FAT)
Local cEsc    := (M->NXH_CESCR)

lRet := ExistCpo('NXA', FwFldGet('NXH_CESCR') + FwFldGet('NXH_FAT'), 1)

If lRet .And. (!Empty(M->NXH_FAT)) .And. (!Empty(M->NXH_CESCR))

	cQuery += " SELECT NXA.NXA_RAZSOC, NXA.NXA_LOGRAD, NXA.NXA_BAIRRO, NXA.NXA_CIDADE, "
	cQuery +=        " NXA.NXA_ESTADO, NXA.NXA_PAIS, NXA.NXA_CEP, NXA.NXA_CCONT "
	cQuery +=    " FROM "+ RetSqlName( "NXA" ) +" NXA "
	cQuery +=  " WHERE NXA.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND NXA.NXA_FILIAL = '" + xFilial( "NXH" ) +"' "
	cQuery +=    " AND NXA.NXA_COD = '" + cFatura +"' "
	cQuery +=    " AND NXA.NXA_CESCR = '" + cEsc +"' "
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cResQRY, .T., .T.)

	oModel:SetValue("NXHMASTER", "NXH_RZSOC",  (cResQRY)->NXA_RAZSOC)
	oModel:SetValue("NXHMASTER", "NXH_LOGRAD", (cResQRY)->NXA_LOGRAD)
	oModel:SetValue("NXHMASTER", "NXH_BAIRRO", (cResQRY)->NXA_BAIRRO)
	oModel:SetValue("NXHMASTER", "NXH_UF",     (cResQRY)->NXA_ESTADO)
	oModel:SetValue("NXHMASTER", "NXH_CID",    (cResQRY)->NXA_CIDADE)
	oModel:SetValue("NXHMASTER", "NXH_PAIS",   (cResQRY)->NXA_PAIS)
	oModel:SetValue("NXHMASTER", "NXH_CEP",    (cResQRY)->NXA_CEP)  
	oModel:SetValue("NXHMASTER", "NXH_CONTAT", Posicione("SU5", 1, xFilial("SU5") + (cResQRY)->NXA_CCONT, "U5_CONTAT"))

	dbSelectArea(cResQRY)
	(cResQRY)->(DbCloseArea())
	RestArea( aArea )

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA074VFAT
Rotina para validar o código da fatura por escritório.

@author Andréia S. N. de Lima
@since 19/03/10
@version 1.0
/*/
//-------------------------------------------------------------------                 	
Function JA074VFAT(oModel)
Local lRet := .T.

	If JurGetDados("NXA", 1, xFilial("NXA") + FwFldGet('NXI_CESCR') + FwFldGet('NXI_CFAT'), "NXA_SITUAC") <> '1'
		lRet := .F.
		JurMsgErro(STR0035) //("Fatura cancelada") 
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA074AQry()
Função para gerar o relatório de protocolos

@param lAutomato, Indica se a chamada foi feita via automação
@param cNameAuto, Nome do arquivo de relatório usado na automação

@author Andréia S. N. de Lima
@since 25/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA074AQry(lAutomato, cNameAuto)
Local lRet        := .F.
Local cParams     := ''
Local cCbResult   := Space( 25 )
Local cProtIni    := CriaVar('NXH_COD', .F. )
Local cProtFim    := CriaVar('NXH_COD', .F. )
Local aRangeRel   := {}
Local aVetPrinc   := {}
Local nI          := 0
Local cTipoRel    := ''
Local cRangeIni   := ''
Local cRangeFim   := ''
Local cModRel     := SuperGetMV('MV_JMODREL',, '1')  // TIPO DE RELATORIO 1 CRYSTAL, 2 FWMSPRINT
Local cArqRel     := ''
Local lJURR074A   := ExistBlock('JURR074A')

Default lAutomato := .F.
Default cNameAuto := ""

	lRet := IIf(lAutomato, .T., Pergunte('JURA074A'))

	cProtIni  := MV_PAR01
	cProtFim  := MV_PAR02
	cCbResult := str(MV_PAR03, 1)

	If lRet
		If FindFunction("JPDLogUser")
			JPDLogUser("JURR074A") // Log LGPD Relatório de Aviso de Cobrança
		EndIf
		
		If cModRel == '1'  // Crystal
			Do Case
				Case cCbResult = '1'  //Impressora
					cOptions := '2'
				Case cCbResult = '3'  //PDF
					cOptions := '6'
				Otherwise //Tela
					cOptions := '1'
			EndCase
			cOptions := cOptions + ';0;1;'  
			
			cParams := cProtIni + ';' //Protocolo Inicial
			cParams += cProtFim + ';'	//Protocolo Final
		
			/*
			CALLCRYS (rpt , params, options), onde:
			rpt = Nome do relatório, sem o caminho.
			params = Parâmetros do relatório, separados por vírgula ou ponto e vírgula. Caso seja marcado este parâmetro, serão desconsiderados os parâmetros marcados no SX1.
			options = Opções para não se mostrar a tela de configuração de impressão , no formato x;y;z;w ,onde:
			x = Impressão em Vídeo(1), Impressora(2), Impressora(3), Excel (4), Excel Tabular(5), PDF(6) e Texto (7) .
			y = Atualiza Dados  ou não(1)
			z = Número de Cópias, para exportação este valor sempre será 1.
			w =Título do Report, para exportação este será o nome do arquivo sem extensão.
			*/
			
			//ER_PCREQ-9651 - tratar se existe RPT especifico cadastrado no tipo de protocolo
			NXH->(DbSetOrder(1))
			NSO->(DbSetOrder(1))
			
			// montar a matriz com todos os protocolos do range informado e o tipo de relatorio associado. 
			// aRangeRel[n][1] - Protocolo
			// aRangeRel[n][2] - RPT  
			If NXH->(DbSeek(xFilial('NXH') + cProtIni))
				While !NXH->(Eof()) .And. xFilial('NXH') == NXH->NXH_FILIAL .And. NXH->NXH_COD >= cProtIni .And. NXH->NXH_COD <= cProtFim
					If NSO->(DbSeek(xFilial('NSO') + NXH->NXH_CTIPO))  // posiciona tipo de protocolo
						If J074RetRel(@cArqRel)  // valida arquivo RPT especifico para o protocolo
							Aadd(aRangeRel, {NXH->NXH_COD, cArqRel})      // relatorio especifico
						Else
							Aadd(aRangeRel, {NXH->NXH_COD, 'JU074A'})      // relatorio padrao
						EndIf
					EndIf
					NXH->(DbSkip())
				EndDo
			EndIf

			// processa agrupando por tipo de relatorio o range de/ate que deve ser impresso
			For nI := 1 to Len(aRangeRel)
				If Empty(cTipoRel) // primeiro acesso
					cTipoRel  := aRangeRel[nI][2]
					cRangeIni := aRangeRel[nI][1]
					cRangeFim := aRangeRel[nI][1]
				Else
					If cTipoRel == aRangeRel[nI][2]  // se o tipo de relatorio eh o mesmo soh muda o range fim
						cRangeFim :=  aRangeRel[nI][1]
					Else  // caso o tipo de relatorio mude carrega a matriz principal
						Aadd(aVetPrinc, {cTipoRel, cRangeIni, cRangeFim})

						cTipoRel  := aRangeRel[nI][2]  // seta o novo tipo de relatorio e range
						cRangeIni := aRangeRel[nI][1]
						cRangeFim := aRangeRel[nI][1]  
					EndIf
				EndIf

				If nI == Len(aRangeRel)  // caso seja o ultimo elemento carrega na matriz principal
					Aadd(aVetPrinc, {cTipoRel, cRangeIni, cRangeFim})
				EndIf
			Next nI
		
			// chamao RPT passando o range de protocolo por tipo de RPT
			For nI := 1 To Len(aVetPrinc)
				cParams := aVetPrinc[nI][2] + ';' //Protocolo Inicial
				cParams += aVetPrinc[nI][3] + ';' //Protocolo Final

				JCallCrys( aVetPrinc[nI][1], cParams, cOptions + STR0007, .T., .F., .F.) // Protocolos  
			Next
		Else // FWMSPRINT
			If lJURR074A
				ExecBlock('JURR074A', .F., .F.)
			Else
				JURR074A(lAutomato, cNameAuto)
			EndIf
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA074BQry()
Função para gerar o relatório de listagem de protocolos

@author Andréia S. N. de Lima
@since 26/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA074BQry(lAutomato, cNameAuto)
Local lRet        := .F.
Local cParams     := ''
Local cCbResult   := Space( 25 )
Local cProtIni    := CriaVar('NXH_COD', .F. )
Local cProtFim    := CriaVar('NXH_COD', .F. )
Local cProtTip    := CriaVar('NXH_CTIPO', .F. )
Local cModRel     := SuperGetMV('MV_JMODREL',,'1')   // TIPO DE RELATORIO 1 CRYSTAL, 2 FWMSPRINT
Local lJURR074B   := ExistBlock('JURR074B')

Default lAutomato := .F.
Default cNameAuto := ""

	lRet := IIf(lAutomato, .T., Pergunte('JURA074B'))

	cProtIni  := MV_PAR01
	cProtFim  := MV_PAR02
	cProtTip  := MV_PAR03
	cCbResult := str(MV_PAR04, 1)

	If FindFunction("JPDLogUser")
		JPDLogUser("JURR074B") // Log LGPD Relatório de Recibo do Adiantamento
	EndIf

	If cModRel == '1' // Crystal
		If lRet
			Do Case
				Case cCbResult = '1' //Impressora
					cOptions := '2'
				Case cCbResult = '3' //PDF
					cOptions := '6'
				Otherwise //Tela
					cOptions := '1'
			EndCase
			cOptions := cOptions + ';0;1;'
		
			cParams := cProtIni + ';' //Protocolo Inicial
			cParams += cProtFim + ';'	//Protocolo Final
			cParams += cProtTip + ';'	//Tipo de Protocolo
			
			/*
			CALLCRYS (rpt , params, options), onde:
			rpt = Nome do relatório, sem o caminho.
			params = Parâmetros do relatório, separados por vírgula ou ponto e vírgula. Caso seja marcado este parâmetro, serão desconsiderados os parâmetros marcados no SX1.
			options = Opções para não se mostrar a tela de configuração de impressão , no formato x;y;z;w ,onde:
			x = Impressão em Vídeo(1), Impressora(2), Impressora(3), Excel (4), Excel Tabular(5), PDF(6) e Texto (7) .
			y = Atualiza Dados  ou não(1)
			z = Número de Cópias, para exportação este valor sempre será 1.
			w =Título do Report, para exportação este será o nome do arquivo sem extensão.
			*/
			
			JCallCrys( 'JU074B', cParams, cOptions + STR0007, .T., .F., .F.) // Protocolos				
		EndIf
	Else  // FWMSPRINTER
		If lRet
			If lJURR074B
				ExecBlock('JURR074B', .F., .F.)
			Else
				JURR074B(cProtIni, cProtFim, cProtTip, lAutomato, cNameAuto)
			EndIf
		EndIf
	EndIf
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JAGerAut()
Efetua a chamada da MarkBrowse de faturas (tela de WO de Faturas).

@author Cristina Cintra Santos
@since 24/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JAGerAut()

	JURA141()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA074SET()
Verifica se há faturas marcadas para chamar a tela de opções de Geração
Automática.

@author Cristina Cintra Santos
@since 24/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA074SET(oBrowse)
Local aArea      := GetArea()
Local aAreaNXA   := NXA->(GetArea())
Local cMarca     := oBrowse:Mark()
Local cFiltro    := oBrowse:FWFilter():GetExprADVPL()
Local cDefFiltro := "NXA_TIPO = 'FT' .AND. NXA_SITUAC == '1'"
Local cAux       := ""
Local nCountNXA  := 0
Local lHabilita  := .T.

	If Empty(cFiltro)
		cFiltro += "(NXA_OK == '" + cMarca + "')"
	Else
		cFiltro += " .And. (NXA_OK == '" + cMarca + "')"
	EndIf

	cAux := &( '{|| ' + cFiltro + ' }')
	NXA->( dbSetFilter( cAux, cFiltro ) )
	NXA->( dbSetOrder(1) )
	
	NXA->(DbEval({||nCountNXA++}))
	
	If nCountNXA == 0
		JurMsgErro(STR0026)	 //"Necessário marcar ao menos uma fatura para geração do protocolo." 
	Else
		//Chama a tela para preenchimento do Tipo de Protocolo (obrigatório)
		//e da opção de geração (desabilitado caso tenha sido marcada apenas
		//uma fatura.
		If nCountNXA == 1
			lHabilita := .F.
		EndIf
		JA074OPC(lHabilita)
	EndIf

	RestArea( aAreaNXA )
	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA074OPC()
Tela para escolha do Tipo de Protocolo e do Tipo de Geração que será 
usado na Geração Automática de Protocolo.

@author Cristina Cintra Santos
@since 27/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA074OPC(lHabilita)
Local oGetTpProt  := Nil
Local oRadioTp    := Nil
Local cGetTpProt  := Criavar( 'NXH_CTIPO' )
Local nRadioTp    := 0
Local lRet        := .T.
Local nButtons    := 90

Default lHabilita := .T.

	If lHabilita
	
		DEFINE MSDIALOG oDlg TITLE STR0025 FROM 0,0 TO 230,300 PIXEL // "Geração Automática"
	
		oGetTpProt := TJurPnlCampo():New(05,05,60,22,oDlg, , 'NXH_CTIPO',{|| },{|| cGetTpProt := oGetTpProt:Valor},,,,'NSO') //"Tipo de Protocolo"
		oGetTpProt:oCampo:bValid := {|| Empty(Alltrim(oGetTpProt:Valor)) .OR. ExistCpo('NSO',oGetTpProt:Valor,1) }
	
		@ 035,005 TO 080,150 LABEL STR0027 PIXEL OF oDlg //"Tipos de Geração Automática de Protocolo:"
		@ 045,010 Radio oRadioTp Var nRadioTp Items STR0028, STR0029, STR0030 3D Size 150,100 PIXEL OF oDlg //"Protocolo para cada fatura""Protocolo agrupando faturas de mesmo cliente" "Protocolo para todas as faturas marcadas"
	
	Else
		
		DEFINE MSDIALOG oDlg TITLE STR0025 FROM 0,0 TO 120,280 PIXEL // "Geração Automática"
		
		oGetTpProt := TJurPnlCampo():New(05,05,60,22,oDlg, , 'NXH_CTIPO',{|| },{|| cGetTpProt := oGetTpProt:Valor},,,,'NSO') //"Tipo de Protocolo"
	
		nButtons := 35 
		
	EndIf

	@ nButtons,020 Button STR0020 Size 050,012 PIXEL OF oDlg  Action (Iif(JA074VALID(lHabilita, nRadioTp, cGetTpProt) == .T., (	MsgRun(STR0034 , ,{|| lRet := JA074GERA(cGetTpProt,nRadioTp) })), lRet := .F.), IIf(lRet == .T.,oDlg:End(),.F.) ) //"Gerar"
	@ nButtons,080 Button STR0031 Size 050,012 PIXEL OF oDlg  Action (oDlg:End(),lRet == .T.) //"Sair"

	ACTIVATE MSDIALOG oDlg CENTERED 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA074GERA()
Função para geração automática de Protocolos de Fatura.

@Params    cTpProto      Tipo de Protocolo de Fatura
						nTpGerAut     Tipo de Geração Automática 

@author Cristina Cintra Santos
@since 27/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA074GERA(cTpProto, nTpGerAut)
Local aArea        := GetArea()
Local oModel       := FWLoadModel( "JURA074" )
Local cFiltro      := oBrowse:FWFilter():GetExprADVPL()
Local cMarca       := oBrowse:Mark()
Local cAux         := ""
Local cDefFiltro   := "NXA_TIPO = 'FT' .AND. NXA_SITUAC == '1'"
Local aFaturas     := {}
Local nI           := 0
Local nAux         := 0
Local lRet         := .T.
Local lNovoProt    := .T.

Default cTpProto   := ""
Default nTpGerAut  := 0

	If Empty(cFiltro)
		cFiltro += "(NXA_OK == '" + cMarca + "')"
	Else
		cFiltro += " .And. (NXA_OK == '" + cMarca + "')"
	EndIf

	cAux := &( '{|| ' + cFiltro + ' }')
	NXA->( dbSetFilter( cAux, cFiltro ) )
	
	NXA->( dbSetOrder(1) )
	NXA->(DbGoTop())
	While !NXA->(Eof())
		//Escritório, Número, Nome do Contato, Cliente e Loja Pagadores, todos da Fatura
		aAdd(aFaturas, {Alltrim(NXA->NXA_CESCR), NXA->NXA_COD, Alltrim(JurGetDados('SU5', 1, xFilial('SU5') + NXA->NXA_CCONT, "U5_CONTAT")), NXA->NXA_CLIPG, NXA->NXA_LOJPG })
		NXA->(dbSkip())
	EndDo

	If nTpGerAut == 1 .Or. nTpGerAut == 0  //"Protocolo para cada fatura"
		For nI := 1 To Len(aFaturas)
			
			oModel:SetOperation(MODEL_OPERATION_INSERT)
			oModel:Activate()

			oModel:SetValue('NXHMASTER', "NXH_CTIPO", cTpProto)
			oModel:SetValue('NXHMASTER', "NXH_CESCR", aFaturas[nI][1] ) 
			oModel:SetValue('NXHMASTER', "NXH_FAT", aFaturas[nI][2] ) 
			oModel:SetValue('NXHMASTER', "NXH_CONTAT", aFaturas[nI][3] )
		 
			oModel:SetValue('NXIDETAIL', "NXI_CESCR", aFaturas[nI][1]) 
			oModel:SetValue('NXIDETAIL', "NXI_CFAT", aFaturas[nI][2]) 

			If oModel:VldData()
				oModel:CommitData()
			Else
				JurMsgErro( , "JURA074" )
			EndIf

			oModel:Deactivate()

		Next
	
	ElseIf nTpGerAut == 2 //"Protocolo agrupando faturas de mesmo cliente" 
	
		aSort(aFaturas, , , {|X,Y| X[4] + X[5] + X[2] < Y[4] + Y[5] + Y[2]})	
		
		For nI := 1 To Len(aFaturas)
			
			If lNovoProt
				oModel:SetOperation(MODEL_OPERATION_INSERT)
				oModel:Activate()
	
				oModel:SetValue('NXHMASTER', "NXH_CTIPO", cTpProto)
				oModel:SetValue('NXHMASTER', "NXH_CESCR", aFaturas[nI][1] ) 
				oModel:SetValue('NXHMASTER', "NXH_FAT", aFaturas[nI][2] ) 
				oModel:SetValue('NXHMASTER', "NXH_CONTAT", aFaturas[nI][3] )
			EndIf
			
			If !JMdlNewLine(oModel:GetModel('NXIDETAIL'))
				oModel:GetModel('NXIDETAIL'):AddLine()
			EndIf
			oModel:SetValue('NXIDETAIL', "NXI_CESCR", aFaturas[nI][1]) 
			oModel:SetValue('NXIDETAIL', "NXI_CFAT", aFaturas[nI][2]) 
			
			nAux := nI+1
			If (nI == Len(aFaturas)) .Or. ( aFaturas[nAux][4] <> aFaturas[nI][4] .Or. aFaturas[nAux][5] <> aFaturas[nI][5] )
				lNovoProt := .T.
				If oModel:VldData()
					oModel:CommitData()
					oModel:Deactivate()
				Else
					JurMsgErro( , "JURA074" )
				EndIf
			Else
				lNovoProt := .F.
			EndIf
		
		Next
	
	ElseIf nTpGerAut == 3 //"Protocolo para todas as faturas marcadas"

		oModel:SetOperation(MODEL_OPERATION_INSERT)
		oModel:Activate()

		oModel:SetValue('NXHMASTER', "NXH_CTIPO", cTpProto)
		oModel:SetValue('NXHMASTER', "NXH_CESCR", aFaturas[1][1] ) 
		oModel:SetValue('NXHMASTER', "NXH_FAT", aFaturas[1][2] ) 
		oModel:SetValue('NXHMASTER', "NXH_CONTAT", aFaturas[1][3] )
		
		For nI := 1 To Len(aFaturas)
			
			If !JMdlNewLine(oModel:GetModel('NXIDETAIL'))
				oModel:GetModel('NXIDETAIL'):AddLine()
			EndIf

			oModel:SetValue('NXIDETAIL', "NXI_CESCR", aFaturas[nI][1]) 
			oModel:SetValue('NXIDETAIL', "NXI_CFAT", aFaturas[nI][2])

		Next
	
		If oModel:VldData()
			oModel:CommitData()
		Else
			JurMsgErro( , "JURA074" )
		EndIf

		oModel:Deactivate()

	EndIf

	NXA->(DbGoTop())
	While !NXA->(Eof())
		RecLock('NXA', .F.)
		NXA->NXA_OK := Space(TamSX3("NX0_OK")[1]) // Limpa a marca
		NXA->(MsUnlock())
		NXA->(DbCommit())
		NXA->(dbSkip())
	EndDo

	cAux := &( "{|| " + cDefFiltro + " }")  //Retorna o Filtro padrão 
	NXA->( dbSetFilter( cAux, cDefFiltro ) )
	
	oBrowse:Refresh()
	oBrowse:GoTop()
	
	oModel:Deactivate()

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA074VALID()
Valida o preenchimento do Tipo de Protocolo e da opção de geração 
automática.

@author Cristina Cintra Santos
@since 27/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA074VALID(lHabilita, nRadioTp, cGetTpProt)
Local lRet         := .T.

Default nRadioTp   := 0
Default cGetTpProt := ""

	If lHabilita .And. (Empty(nRadioTp) .Or. Empty(cGetTpProt))
		lRet := .F.
		JurMsgErro(STR0032) //"Necessário preencher o tipo de protocolo e o tipo de Geração Automática!"
	ElseIf !lHabilita .And. Empty(cGetTpProt)
		lRet := .F.
		JurMsgErro(STR0033) //"Necessário preencher o tipo de Geração Automática!"
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J074RetRel(cArqRel)
Função para retornar o tipo de relatorio de protocolo
Busca na NSO pelo tipo de relatorio e valida o RPT especifico

@param 	cArqRel	==> recebe variavel por referencia para devolver o nome do RPT especifico

@return lRet ==> RPT especifico valido ou não

@author Mauricio Canalle
@since 28/03/16
@version 1.0	
/*/
//-------------------------------------------------------------------
Static Function J074RetRel(cArqRel)
Local aArea       := GetArea()
Local lRet        := .T.
Local cDirCrystal := GetMV('MV_CRYSTAL')

	If empty(NSO->NSO_ARQ)   // nao tem relatorio especifico cadastrado
		lRet := .F.
	Else
		cArqRel := Upper(alltrim(NSO->NSO_ARQ))
		cArqRel := StrTran(cArqRel, '.RPT', '')  // tira o .rpt do nome caso tenha sido cadastrado
		If !File(cDirCrystal + cArqRel + '.RPT')  // verifica se encontra o arquivo especifico na pasta dos relatorios
			lRet := .F.  // se nao encontra imprime o padrao
		EndIf
	EndIf
	
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J074VldTrp(cTipoRp)
Valida se o tipo de relatorio de protocolo (NSO) esta ativo

@param	cTipoRF		Tipo de Relatorio de Protocolo

@return lRet   .T. - validacao OK, libera o campo
               .F. - validacao falhou, nao libera o campo

@author Mauricio Canalle
@since 30/03/2016

@version 1.0
/*/
//-------------------------------------------------------------------
Function J074VldTrp(cTipoRp)
Local lRet   := .T.
Local aArea  := GetArea()

	NSO->( dbSetOrder( 1 ) ) //NSO_FILIAL+NSO_COD
	If NSO->( dbSeek( xFilial('NSO') + cTipoRp, .F. ) )
		If !NSO->NSO_ATIVO == '1'
			JurMsgErro( STR0036 ) //'Este tipo de relatório não pode ser utilizado pois está inativo'
			lRet := .F.
		EndIf
	Else
		JurMsgErro( STR0037 ) //'Tipo de Relatório Não Cadastrado...'
		lRet := .F.
	EndIf

	RestArea(aArea)

Return( lRet )
