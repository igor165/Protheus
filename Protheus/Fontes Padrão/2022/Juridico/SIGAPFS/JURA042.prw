#INCLUDE "JURA042.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/ { Protheus.doc } JURA042
Tabela de Honorarios

@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA042()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NRF" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NRF" )
JurSetBSize( oBrowse )
oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/ { Protheus.doc } MenuDef
Menu Funcional

@Return aRotina - Estrutura
[n, 1] Nome a aparecer no cabecalho
[[n, 2] Nome da Rotina associada
[n, 3] Reservado
[n, 4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n, 5] Nivel de acesso
[n, 6] Habilita Menu Funcional

@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA042", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA042", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA042", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA042", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA042", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/ { Protheus.doc } ViewDef
View de dados de Tabela de Honorarios

@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel      := FWLoadModel( "JURA042" )
Local oStructNRF
Local oStructNS9
Local oStructNSD

oStructNRF := FWFormStruct( 2, "NRF" )  //Tab. Honorários
oStructNS9 := FWFormStruct( 2, "NS9" )  //Honorários / Categoria
oStructNSD := FWFormStruct( 2, "NSD" )  //Honorários / Profissional
oStructNTV := FWFormStruct( 2, "NTV" )  //Hist. Tab. Honor
oStructNTU := FWFormStruct( 2, "NTU" )  //Hist. Honor / Categ
oStructNTT := FWFormStruct( 2, "NTT" )  //Hist. Honor / Prof

//Remove os campos do filho que já estão no pai
oStructNS9:RemoveField( "NS9_CTAB" )
oStructNSD:RemoveField( "NSD_CTAB" )
oStructNSD:RemoveField( "NSD_CPART" )
oStructNTV:RemoveField( "NTV_CTAB" )
oStructNTV:RemoveField( "NTV_COD" )
oStructNTU:RemoveField( "NTU_CTAB" )
oStructNTU:RemoveField( "NTU_COD" )
oStructNTU:RemoveField( "NTU_CHIST" )
oStructNTT:RemoveField( "NTT_CTAB" )
oStructNTT:RemoveField( "NTT_COD" )
oStructNTT:RemoveField( "NTT_CHIST" )
oStructNTT:RemoveField( "NTT_CPART" )

JurSetAgrp( 'NRF',, oStructNRF )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA042_TABHONOR"   , oStructNRF, "NRFMASTER"  )
oView:AddGrid(  "JURA042_HONORCAT"   , oStructNS9, "NS9DETAIL"  )
oView:AddGrid(  "JURA042_HONORPART"  , oStructNSD, "NSDDETAIL"  )
oView:AddGrid(  "JURA042_TABHONOR_H" , oStructNTV, "NTVDETAIL"  )
oView:AddGrid(  "JURA042_HONORCAT_H" , oStructNTU, "NTUDETAIL"  )
oView:AddGrid(  "JURA042_HONORPART_H", oStructNTT, "NTTDETAIL"  )

oView:CreateFolder("FOLDER_01")
oView:AddSheet("FOLDER_01", "ABA_01_01", STR0012 )
oView:AddSheet("FOLDER_01", "ABA_01_02", STR0013 )

oView:CreateHorizontalBox( "FORMTABH"    , 20,,,"FOLDER_01","ABA_01_01")
oView:CreateHorizontalBox( "FORM2NIVEL"  , 40,,,"FOLDER_01","ABA_01_01")
oView:CreateHorizontalBox( "FORM3NIVEL"  , 40,,,"FOLDER_01","ABA_01_01")
oView:CreateHorizontalBox( "FORMTABH_H"    , 20,,,"FOLDER_01","ABA_01_02")
oView:CreateHorizontalBox( "FORM2NIVEL_H"  , 40,,,"FOLDER_01","ABA_01_02")
oView:CreateHorizontalBox( "FORM3NIVEL_H"  , 40,,,"FOLDER_01","ABA_01_02")

oView:SetOwnerView( "JURA042_TABHONOR"  , "FORMTABH"    )
oView:SetOwnerView( "JURA042_HONORCAT"  , "FORM2NIVEL"  )
oView:SetOwnerView( "JURA042_HONORPART" , "FORM3NIVEL" )

oView:SetOwnerView( "JURA042_TABHONOR_H"  , "FORMTABH_H"    )
oView:SetOwnerView( "JURA042_HONORCAT_H"  , "FORM2NIVEL_H"  )
oView:SetOwnerView( "JURA042_HONORPART_H" , "FORM3NIVEL_H" )

oView:SetUseCursor( .T. )
oView:SetDescription( STR0007 ) // "Tabela de Honorarios"
oView:EnableControlBar( .T. )
oView:AddUserButton( STR0014, "VENDEDOR", { | oView | JURA042Bt1( oView ) } ) //Botão - Todas as Categorias

oView:EnableTitleView( "JURA042_HONORCAT" )
oView:EnableTitleView( "JURA042_HONORPART" )
oView:EnableTitleView( "JURA042_HONORCAT_H" )
oView:EnableTitleView( "JURA042_HONORPART_H" )

oView:SetViewProperty("NTVDETAIL", "GRIDFILTER", {.T.})

Return oView

//-------------------------------------------------------------------
/*/ { Protheus.doc } ModelDef
Modelo de dados de Tabela de Honorarios

@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0

@obs NRFMASTER - Dados do Tabela de Honorarios
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oStructNRF := NIL
Local oStructNS9 := NIL
Local oStructNSD := NIL
Local oModel     := NIL
Local oCommit    := JA042COMMIT():New()

oStructNRF := FWFormStruct( 1, "NRF" )  //Tab. Honorários
oStructNS9 := FWFormStruct( 1, "NS9" )  //Honorários / Categoria
oStructNSD := FWFormStruct( 1, "NSD" )  //Honorários / Profissional

oStructNTV := FWFormStruct( 1, "NTV" )  //Hist. Tab. Honor
oStructNTU := FWFormStruct( 1, "NTU" )  //Hist. Honor / Categ
oStructNTT := FWFormStruct( 1, "NTT" )  //Hist. Honor / Prof

oModel := MPFormModel():New( "JURA042", /*Pre-Validacao*/, { | oX | JA042TUDOK( oX ) }/*Pos-Validacao*/, /*Commit*/, /*Cancel*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Tabela de Honorarios"

oModel:AddFields( "NRFMASTER",             /*cOwner*/, oStructNRF, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:AddGrid( "NS9DETAIL", "NRFMASTER"   /*cOwner*/, oStructNS9, /*bLinePre*/, { | oX | JA042GRDOK( oX ) } /*bLinePost*/, /*bPre*/, /*bPost*/ )
oModel:AddGrid( "NSDDETAIL", "NRFMASTER"   /*cOwner*/, oStructNSD, /*bLinePre*/, { | oX | JA042GRDOK( oX ) } /*bLinePost*/, /*bPre*/, /*bPost*/ )
oModel:AddGrid(  "NTVDETAIL", "NRFMASTER"  /*cOwner*/, oStructNTV, /*bLinePre*/, { | oX | JA042GRDOK( oX ) } /*bLinePost*/, /*bPre*/, /*bPost*/, { |oGrid| LoadNTV( oGrid ) } )
oModel:AddGrid(  "NTUDETAIL", "NTVDETAIL"  /*cOwner*/, oStructNTU, /*bLinePre*/, { | oX | JA042GRDOK( oX ) } /*bLinePost*/, /*bPre*/, /*bPost*/ )
oModel:AddGrid(  "NTTDETAIL", "NTVDETAIL"  /*cOwner*/, oStructNTT, /*bLinePre*/, { | oX | JA042GRDOK( oX ) } /*bLinePost*/, /*bPre*/, /*bPost*/ )

oModel:GetModel( "NRFMASTER"  ):SetDescription( STR0009 ) //"Cabecalho da Tabela de Honorários"
oModel:GetModel( "NS9DETAIL"  ):SetDescription( STR0010 ) //"Valores por categoria"
oModel:GetModel( "NSDDETAIL"  ):SetDescription( STR0011 ) //"Excessão para os participantes"
oModel:GetModel( "NTVDETAIL"  ):SetDescription( STR0015 ) //"Hist. Tab. Honor"
oModel:GetModel( "NTUDETAIL"  ):SetDescription( STR0016 ) //"Hist. Honor / Categ"
oModel:GetModel( "NTTDETAIL"  ):SetDescription( STR0017 ) //"Hist. Honor / Prof"

oModel:GetModel( "NS9DETAIL" ):SetUniqueLine( { "NS9_CCAT"   } )
oModel:GetModel( "NSDDETAIL" ):SetUniqueLine( { "NSD_CPART"  } )
oModel:GetModel( "NTVDETAIL" ):SetUniqueLine( { "NTV_AMINI" } )
oModel:GetModel( "NTUDETAIL" ):SetUniqueLine( { "NTU_CCAT"   } )
oModel:GetModel( "NTTDETAIL" ):SetUniqueLine( { "NTT_CPART"  } )

oModel:SetRelation( "NS9DETAIL",   { { "NS9_FILIAL", "xFilial( 'NS9' ) " } , { "NS9_CTAB", "NRF_COD" } } , NS9->( IndexKey( 3 ) ) )
oModel:SetRelation( "NSDDETAIL",   { { "NSD_FILIAL", "xFilial( 'NSD' ) " } , { "NSD_CTAB", "NRF_COD" } } , NSD->( IndexKey( 1 ) ) )
oModel:SetRelation( "NTVDETAIL",   { { "NTV_FILIAL", "xFilial( 'NTV' ) " } , { "NTV_CTAB", "NRF_COD" } } , NTV->( IndexKey( 3 ) ) )
oModel:SetRelation( "NTUDETAIL",   { { "NTU_FILIAL", "xFilial( 'NTU' ) " } , { "NTU_CTAB", "NRF_COD" } ,{ "NTU_CHIST", "NTV_COD" } } , NTU->( IndexKey( 3 ) ) )
oModel:SetRelation( "NTTDETAIL",   { { "NTT_FILIAL", "xFilial( 'NTT' ) " } , { "NTT_CTAB", "NRF_COD" } ,{ "NTT_CHIST", "NTV_COD" } } , NTT->( IndexKey( 2 ) ) )

oModel:GetModel( "NTTDETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NTUDETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NTVDETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NSDDETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NS9DETAIL" ):SetDelAllLine( .F. )

oModel:SetOptional( "NTTDETAIL", .T. )
oModel:SetOptional( "NTUDETAIL", .T. )
oModel:SetOptional( "NTVDETAIL", .T. )
oModel:SetOptional( "NSDDETAIL", .T. )
oModel:SetOnDemand( .T. )

oModel:InstallEvent("JA042COMMIT", /*cOwner*/, oCommit)

JurSetRules( oModel, 'NRFMASTER',, 'NRF' )
JurSetRules( oModel, "NS9DETAIL",, 'NS9' )
JurSetRules( oModel, "NSDDETAIL",, 'NSD' )
JurSetRules( oModel, "NTVDETAIL",, 'NTV' )
JurSetRules( oModel, "NTUDETAIL",, 'NTU' )
JurSetRules( oModel, "NTTDETAIL",, 'NTT' )

Return oModel

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA042COMMIT
Classe interna implementando o FWModelEvent, para execução de função 
durante o commit.

@author Bruno Ritter
@since  23/08/2017
/*/
//-------------------------------------------------------------------
Class JA042COMMIT FROM FWModelEvent
	Data lUsaHist   // Habilitar a gravação dos históricos
	Data lHstMesAnt // Considerar a alteração dos cadatros ajustando o históricos no mês anterior
	Data cAnoMesAtu // Ano-mês atual que será considerado para as validações

	Method New()
	Method InTTS()
	Method GridLinePreVld()
End Class

Method New() Class JA042COMMIT
	Self:lUsaHist   := SuperGetMV( 'MV_JURHS1',, .T. ) // Habilita a gravação dos históricos
	Self:lHstMesAnt := SuperGetMV( 'MV_JURHS2',, .T. ) // Considera a alteração dos cadatros ajustando o históricos no mês anterior
	Self:cAnoMesAtu := ""
	If Self:lUsaHist
		Self:cAnoMesAtu := IIf(Self:lHstMesAnt, AnoMes(MsSomaMes(Date(), -1)), AnoMes(Date()))
	EndIf
Return

Method InTTS(oSubModel, cModelId) Class JA042COMMIT
	JFILASINC(oSubModel:GetModel(), "NRF", "NRFMASTER", "NRF_COD") //Fila de sincronização
Return

Method GridLinePreVld(oSubModel, cModelID, nLine, cAction) Class JA042COMMIT
Local lRet := JA042GdPre(oSubModel, cModelID, cAction, Self:cAnoMesAtu)

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JURA042Bt1
Executa a rotina ao clicar no botão 1 - "Todas Cat."

@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURA042Bt1( oView )
Local oModel     := FWModelActive()
Local nOperation := oModel:GetOperation()

	If nOperation == 3 .Or. nOperation == 4
		JURA042CAT( oView )
	EndIf

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA042TUDOK
Valida se as Regras das Structs estão OK
(campos obrigatórios)

@Return lRet	 	.T./.F. As informações são válidas ou não

@author David Gonçalves Fernandes
@since 29/08/09
/*/
//-------------------------------------------------------------------
Function JA042TUDOK(oModel)
Local lRet       := .T.
Local aArea      := GetArea()
Local aAreaNRF   := NRF->( GetArea() )
Local oStructNS9 := oModel:GetModel("NS9DETAIL")
Local oStructNTV := oModel:GetModel("NTVDETAIL")
Local nOperation := 0
Local nAnoMes    := 0
Local nQtdLinNTV := 0
Local nLinhaNTV  := 0

nOperation := oModel:GetOperation()

If nOperation == 3 .Or. nOperation == 4 //Inclusão (3) ou Alteração (4)
	
	lRet := JURPerHist( oStructNTV, .T.) //CH8119 Valida lacunas de período no histórico de honorários
	
	//Valida os campos obrigatórios do cadastro do serviços
	If lRet .AND. ( oStructNS9:GetQtdLine()  == 0 ) .OR. ;
		( oStructNS9:GetQtdLine()  == 1 .AND. Empty(oStructNS9:GetValue( "NS9_CCAT" )  )  )
		lRet := JurMsgErro( STR0021 )//"É necessário incluir o código da categoria (NS9_CCAT)"
	EndIf
	
	If lRet .AND. !JA042HST( oModel )  //Atualiza os históricos conforme as alterações nas tabelas de honorários
		lRet := .F.
	EndIf

	If lRet
		nQtdLinNTV := oStructNTV:GetQtdLine()
		
		For nLinhaNTV := 1 to nQtdLinNTV
			If !oStructNTV:IsDeleted(nLinhaNTV) .And. Empty(oStructNTV:GetValue("NTV_AMFIM", nLinhaNTV))
				nAnoMes++
				If nAnoMes > 1
					Exit
				EndIf
			EndIf
		Next nLinhaNTV
		
		If nAnoMes > 1
			lRet := JurMsgErro( STR0037 ) // "Não é possível ter  mais de um histórico com o campo ano-mês fim sem estar preenchido. Favor verifique." 	 		 	
		EndIf

	EndIf
EndIf

RestArea( aAreaNRF )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JURA042CAT
Obtém as categorias ativas para incluir na tabela de honorários selecionada

@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURA042CAT( oView )
	Local aArea      := GetArea()
	Local cQuery     := ""
	Local cTrb       := GetNextAlias()
	Local oModelGrid := NIL
	Local nPosCpo    := 1
	Local nPos       := 0
	Local nI         := 0
	Local nLines     := 0
	Local aSaveLines := FWSaveRows()
	Local aCols      := {}	
	
	//Local cFilSE2   := xFilial( cString )
	// + -----------------------
	// | Cria filtro temporario
	// + -----------------------
	cQuery := "SELECT "
	cQuery += "NRN_COD "
	cQuery += "FROM " + RetSqlName( "NRN" ) + " "
	cQuery += "WHERE NRN_FILIAL = '" + xFilial( "NRN" ) + "' "
	cQuery += "  AND NRN_ATIVO = '1' "
	cQuery += "  AND D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY NRN_FILIAL, NRN_COD"
		
	// + -----------------------
	// | Cria uma view no banco
	// + -----------------------
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTrb, .T., .F. )
	(cTrb)->( dbSelectArea( cTrb ) )
	(cTrb)->( dbGoTop() )
	
	oModelGrid := oView:GetModel( "NS9DETAIL" )
	nLines     := oModelGrid:GetQtdLine()
	
	For nI := 1 to nLines
		aAdd(aCols, {oModelGrid:GetValue("NS9_CCAT", nI)})
	Next

	While !(cTrb)->( EOF() )
		
		nPos := aScan( aCols, { | x | x[nPosCpo] == (cTrb)->NRN_COD } )

		If nPos > 0
			oModelGrid:GoLine( nPos )
			If oModelGrid:IsDeleted( nPos )
				oModelGrid:UnDeleteLine()
			EndIf
		Else
			If nLines == 1 .AND. Empty(oModelGrid:GetValue("NS9_CCAT"))
				oModelGrid:GoLine( 1 )
			ElseIf nPos == 0
				oModelGrid:AddLine( )
			EndIf
			oModelGrid:SetValue( "NS9_CCAT", (cTrb)->NRN_COD )
		EndIf

		(cTrb)->( dbSkip() )
	End
	oModelGrid:GoLine( 1 )
	(cTrb)->( dbCloseArea() )
	oView:Refresh()
	FWRestRows( aSaveLines )
	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA042HST
Atualiza os históricos conforme as alterações nas tabelas de honorários

@author David Gonçalves Fernandes
@since 17/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA042HST( oModel )
Local aArea      := GetArea()
Local lRet       := .T.
Local oModelNRF  //Tab. Honorários
Local oModelNS9  //Honorários / Categoria
Local oModelNSD  //Honorários / Profissional
Local oModelNTV  //Hist. Tab. Honor
Local oModelNTU  //Hist. Honor / Categ
Local oModelNTT  //Hist. Honor / Prof
Local lUsaHist   := SuperGetMV( 'MV_JURHS1',, .T. ) // Habilitar a gravação dos históricos
Local lHstMesAnt := SuperGetMV( 'MV_JURHS2',, .T. ) // Considerar a alteração dos cadatros ajustando o históricos no mês anterior
Local dData      := date()
Local nI         := 0
Local cAnoMes    := ""
Local cMaxAnoMes := ""
Local cAnoMesINI := ""
Local cAnoMesFim := ""
Local cNTVAMIni  := ""
Local cNTVAMFim  := ""
Local nPos       := 0
Local nLinha     := 0
Local nLinhaNS9  := 0
Local nLinhaNSD  := 0
Local nLinhaNTV  := 0
Local nLinhaNTU  := 0
Local nLinhaNTT  := 0
Local lMudou     := .F.
Local nQtdLinNTV := 0
Local nQdtLinNTU := 0
Local nQdtLinNTT := 0
Local nLinNS9Old := 0
Local nLinNSDOld := 0
Local nLinNTVOld := 0
Local nLinNTUOld := 0
Local nLinNTTOld := 0
Local aSaveLines := FWSaveRows( )

oModelNRF := oModel:GetModel( "NRFMASTER" )
oModelNS9 := oModel:GetModel( "NS9DETAIL" )
oModelNSD := oModel:GetModel( "NSDDETAIL" )

oModelNTV := oModel:GetModel( "NTVDETAIL" )
oModelNTU := oModel:GetModel( "NTUDETAIL" )
oModelNTT := oModel:GetModel( "NTTDETAIL" )

//Salva as linhas posicionadas para restaurá-las quando atualizar a tela
nLinNS9Old := oModelNS9:nLine
nLinNSDOld := oModelNSD:nLine
nLinNTVOld := oModelNTV:nLine
nLinNTUOld := oModelNTU:nLine
nLinNTTOld := oModelNTT:nLine

If !lUsaHist
	dData   := MsDate()	    // Ver qual data
	cAnoMesINI := AnoMes(dData)
	
	//Retorna o Menor Ano-Mês que estiver no Grid de histórico
	nQtdLinNTV := oModelNTV:GetQtdLine()
	For nLinhaNTV := 1 To nQtdLinNTV
		cNTVAMIni := oModelNTV:GetValue("NTV_AMINI", nLinhaNTV)

		If !oModelNTV:IsEmpty() .And. !oModelNTV:IsDeleted(nLinhaNTV) .And. !Empty(cNTVAMIni) .And. cNTVAMIni < cAnoMesIni
			cAnoMesIni := cNTVAMIni
			cAnoMesFim := cNTVAMIni
		EndIf
	Next
Else
	If !lHstMesAnt
		cAnoMesINI := AnoMes(dData)
		cAnoMesFim := AnoMes(MsSomaMes(dData,-1))
	Else
		cAnoMesINI := AnoMes(MsSomaMes(dData,-1))
		cAnoMesFim := AnoMes(MsSomaMes(dData,-2))
	EndIf
EndIf

If lRet
	cMsg := ''
	//Verifica se a 1ª linha (padrão FW) está vazia
	nQtdLinNTV := oModelNTV:GetQtdLine()
	
	If nQtdLinNTV == 1 .AND. ;
		Empty(oModelNTV:GetValue( "NTV_AMINI" ) ) .AND. ;
		Empty(oModelNTV:GetValue( "NTV_AMFIM" ) ) .AND. ; 
		Empty(oModelNTV:GetValue( "NTV_DESC" ) ) .AND. ;
		Empty(oModelNTV:GetValue( "NTV_CMOEDA") )
		nLinha := 1
	Else
		// Busca o histórico mais recente no grid de histórico
		For nLinhaNTV := 1 To nQtdLinNTV

			cNTVAMIni := oModelNTV:GetValue("NTV_AMINI", nLinhaNTV)
			cNTVAMFim := oModelNTV:GetValue("NTV_AMFIM", nLinhaNTV)
			
			// Se o maior histórico já estiver encerrado antes do período, não poderá ajustar o ano-mês final
			If !oModelNTV:IsDeleted(nLinhaNTV) .And. (Empty(cNTVAMFim) .OR. (!Empty(cNTVAMFim) .AND. cNTVAMFim >= cAnoMesFim))
				
				// cNTVAMIni  -> Ano-mês inicial do histórico da linha que está sendo validada
				// cAnoMesIni -> Ano-mês atual (data atual)
				// cMaxAnoMes -> Ano-mês máximo permitido para o histórico
				
				If cMaxAnoMes == ""
					cMaxAnoMes := IIf(cNTVAMIni > cAnoMesIni, cAnoMesIni, cNTVAMIni)
					nLinha     := nLinhaNTV
				ElseIf !lUsaHist
					If cNTVAMIni <= cMaxAnoMes
						cMaxAnoMes := cAnoMesIni
						nLinha := nLinhaNTV
					EndIf
				EndIf
			EndIf
		Next
	EndIf
	
	//Se não encontrou histórico mais recente a alterar, cria a linha de histórico
	If nLinha == 0
		cAnoMes    := cAnoMesINI
		cMaxAnoMes := cAnoMesIni
		oModelNTV:AddLine()
	Else
		//Posiciona na linha do histórico que deve ser alterada
		oModelNTV:GoLine(nLinha)
		If cMaxAnoMes == ''
			cAnoMes    := cAnoMesINI
			cMaxAnoMes := cAnoMesINI
		Else
			cAnoMes := cMaxAnoMes
		EndIf
	
		If lUsaHist
			//Verifica o cadastro mudou em relação ao histórico (se o hist. não está vazio)
			If (!Empty(oModelNTV:GetValue( "NTV_AMINI")) .AND. !Empty(oModelNTV:GetValue( "NTV_DESC" )) .AND. !Empty(oModelNTV:GetValue( "NTV_CMOEDA" )))
				//Tabela
				If (oModelNTV:GetValue( "NTV_DESC"   ) <> oModelNRF:GetValue( "NRF_DESC"  ) .OR. ;
					oModelNTV:GetValue( "NTV_CMOEDA" )   <> oModelNRF:GetValue( "NRF_MOEDA" ) )
					lMudou := .T.
				EndIf
				
				//Valor por categoria
				If !lMudou .AND. !Empty(oModelNTU:GetValue('NTU_CCAT'))
	
					nQtdLinNS9 := oModelNS9:GetQtdLine()
					For nLinhaNS9 := 1 to nQtdLinNS9
						oModelNS9:GoLine(nLinhaNS9)
						If oModelNS9:IsDeleted()
							lMudou := .T.
							Exit
						EndIf
						
						nPos := 0
						For nI := 1 To oModelNTU:GetQtdLine()
							If !oModelNTU:IsDeleted() .And. ; 
								 oModelNTU:GetValue('NTU_CCAT', nI) == oModelNS9:GetValue('NS9_CCAT') .And. ;
								 oModelNTU:GetValue('NTU_VALORH', nI) == oModelNS9:GetValue('NS9_VALORH')
								nPos := nI 
								Exit
							EndIf
						Next
						
						If nPos == 0
							lMudou := .T.
							Exit
						EndIf
						
					Next
				EndIf
				
				//Exceção por participante
				If !lMudou
					nQtdLinNSD := oModelNSD:GetQtdLine()
		
					For nLinhaNSD := 1 to nQtdLinNSD
						oModelNSD:GoLine(nLinhaNSD)
						
						If oModelNSD:IsDeleted()
							lMudou := .T.
							Exit
						EndIf
						
						For nI := 1 To oModelNTT:GetQtdLine()
							nPos := 0
							If !oModelNTT:IsDeleted() .And. ;
								 oModelNTT:GetValue('NTT_SIGLA', nI) == oModelNSD:GetValue('NSD_SIGLA') .And. ;
								 oModelNTT:GetValue('NTT_CCAT', nI) == oModelNSD:GetValue('NSD_CCAT') .And. ;
								 oModelNTT:GetValue('NTT_VALORH', nI) == oModelNSD:GetValue('NSD_VALORH')
								nPos := nI 
								Exit
							EndIf
						Next
						
						If nPos == 0
							lMudou := .T.
							Exit
						EndIf
					Next
				EndIf
			EndIf
			
			//Caso haja diferença, encerra o periodo antigo para incluir o novo em aberto.
			If lMudou .AND. oModelNTV:GetValue( "NTV_AMINI") <> cAnoMesIni
				If !( oModelNTV:SetValue( "NTV_AMFIM" ,  If( oModelNTV:GetValue( "NTV_AMINI") > cAnoMesFim, oModelNTV:GetValue( "NTV_AMINI"), cAnoMesFim ) ) )
					lRet := .F.
					oModelNTV:DeleteLine()
					cMsg := STR0018 //"Erro ao Gravar o histórico da Tabela de Honorários"
				EndIf
				cAnoMes    := cAnoMesINI
				cMaxAnoMes := cAnoMesIni
				oModelNTV:AddLine()
			EndIf
		EndIf
	EndIf
	
	If oModelNTV:IsDeleted()
		oModelNTV:UnDeleteLine()
	EndIf
	
	If oModel:GetOperation() == OP_INCLUIR
		cAnoMes := '190001'
	EndIf
	
	//Copia os dados do cadastro para o histórico
	//Copia para histórico - Tabela de honorários
	If lRet .AND. ;
		!( oModelNTV:SetValue( "NTV_AMINI" , cAnoMes ) .AND. ;
		oModelNTV:SetValue( "NTV_AMFIM" , '' )         .AND. ;
		oModelNTV:SetValue( "NTV_DESC"  , oModelNRF:GetValue( "NRF_DESC"  ) ) .AND. ;
		oModelNTV:LoadValue( "NTV_CMOEDA", oModelNRF:GetValue( "NRF_MOEDA" ) ) )
		lRet := .F.
		oModelNTV:DeleteLine()
		cMsg := STR0018 //"Erro ao Gravar o histórico da tabela de honorários"
	EndIf
	
	//Copia para histórico - Valor por categoria
	If lRet
		nQtdLinNS9 := oModelNS9:GetQtdLine()

		For nLinhaNS9 := 1 to nQtdLinNS9
			oModelNS9:GoLine(nLinhaNS9)
			
			nQtdLinNTU := oModelNTU:GetQtdLine()
			nPos := 0
			For nI := 1 To nQtdLinNTU
				If oModelNTU:GetValue('NTU_CCAT', nI) == oModelNS9:GetValue('NS9_CCAT')
					nPos := nI
				EndIf
			Next

			If nPos > 0 .OR. ( nQtdLinNTU == 1 .AND. Empty(oModelNTU:GetValue( "NTU_CCAT")) .And. !oModelNTU:IsDeleted() )
				//Aproveita a 1ª linha do FW em branco
				oModelNTU:GoLine(nPos)
			Else
				oModelNTU:AddLine()
			EndIf
			
			//Se a linha for apagada do registro, exclui do histórico.
			If !oModelNS9:IsDeleted() .AND. !oModelNTU:isDeleted() .AND. ;
				!( oModelNTU:LoadValue( "NTU_CCAT"  , oModelNS9:GetValue('NS9_CCAT'  ) ) .AND. ;
				oModelNTU:SetValue( "NTU_VALORH", oModelNS9:GetValue('NS9_VALORH') ) )
				lRet := .F.
				oModelNTU:DeleteLine()
				cMsg := STR0019 //"Erro ao Gravar o histórico do valor por categoria"
			ElseIf oModelNS9:isDeleted()
				oModelNTU:DeleteLine()
			ElseIf oModelNTU:isDeleted()
				oModelNTU:UnDeleteLine()
			EndIf
		Next
		
	EndIf
	
	//Copia para histórico - Exceção por participante
	If lRet
		nQtdLinNSD := oModelNSD:GetQtdLine()
	
		For nLinhaNSD := 1 to nQtdLinNSD
			oModelNSD:GoLine(nLinhaNSD)
			
			nQtdLinNTT := oModelNTT:GetQtdLine()
			nPos := 0
			For nI := 1 To nQtdLinNTT
				If oModelNTT:GetValue('NTT_SIGLA', nI) == oModelNSD:GetValue('NSD_SIGLA') .And. ;
					 oModelNTT:GetValue('NTT_CCAT', nI) == oModelNSD:GetValue('NSD_CCAT')
						nPos := nI 
						Exit
				EndIf
			Next
			
			If nPos > 0 .OR. ( nQtdLinNTT == 1 .AND. Empty( oModelNTT:GetValue( "NTT_SIGLA") ) .AND. Empty( oModelNTT:GetValue( "NTT_CCAT")) .And. !oModelNTT:isDeleted() )
				oModelNTT:GoLine(nPos)
			Else
				oModelNTT:AddLine()
			EndIF
			
			//Se a linha for apagada do registro, exclui do histórico.
			If !oModelNSD:isDeleted() .AND. !oModelNTT:isDeleted() .AND. ;
				!( oModelNTT:SetValue( "NTT_SIGLA", oModelNSD:GetValue('NSD_SIGLA' ) ) .AND. ;
				oModelNTT:LoadValue( "NTT_CCAT" , oModelNSD:GetValue('NSD_CCAT'  ) ) .AND. ;
				oModelNTT:SetValue( "NTT_VALORH", oModelNSD:GetValue('NSD_VALORH') ) )
				lRet := .F.
				oModelNTT:DeleteLine()
				cMsg := STR0019 //"Erro ao Gravar o histórico do valor por categoria"
			Elseif oModelNSD:IsDeleted()
				oModelNTT:DeleteLine()
			Elseif oModelNTT:IsDeleted()
				oModelNTT:uNDeleteLine()
			EndIf
			
		Next
		
	EndIf
	
	//Remove inconsistências
	If lRet
		//Exclui do histórico atual o valor por categ que não está no cadastro
		nQdtLinNTU := oModelNTU:GetQtdLine()
		
		For nLinhaNTU := 1 to nQdtLinNTU
			oModelNTU:GoLine(nLinhaNTU)
			
			nPos := 0
			For nI := 1 To oModelNS9:GetQtdLine()
				If oModelNS9:GetValue('NS9_CCAT', nI) == oModelNTU:GetValue('NTU_CCAT') .And. ;
					 oModelNS9:GetValue('NS9_VALORH', nI) == oModelNTU:GetValue('NTU_VALORH')
						nPos := nI 
						Exit
				EndIf
			Next
			
			If nPos == 0
				oModelNTU:DeleteLine()
			EndIf
			
		Next
	EndIf
	
	//Exclui do histórico atual exceção por participante que não está no cadastro
	If lRet
		nQdtLinNTT := oModelNTT:GetQtdLine()
		
		For nLinhaNTT := 1 to nQdtLinNTT
			oModelNTT:GoLine(nLinhaNTT)
			
			nPos := 0
			For nI := 1 To oModelNSD:GetQtdLine()
				If oModelNTT:GetValue('NTT_SIGLA') == oModelNSD:GetValue('NSD_SIGLA', nI) .And. ;
					 oModelNTT:GetValue('NTT_CCAT') == oModelNSD:GetValue('NSD_CCAT', nI) .And. ;
					 oModelNTT:GetValue('NTT_VALORH') == oModelNSD:GetValue('NSD_VALORH', nI)
						nPos := nI 
						Exit
				EndIf
			Next
			
			If nPos == 0
				oModelNTT:DeleteLine()
			EndIF
			
		Next

	EndIf
EndIf

RestArea( aArea )

//Restaura as linhas posicionadas para não perder as referências em tela
oModelNS9:GoLine(nLinNS9Old)
oModelNSD:GoLine(nLinNSDOld)
oModelNTV:GoLine(nLinNTVOld)
oModelNTU:GoLine(nLinNTUOld)
oModelNTT:GoLine(nLinNTTOld)

If !lRet
	JurMsgErro(cMsg)
EndIf
FWRestRows(aSaveLines)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadNTV
Faz a carga dos dados da grid do NTV e ordena o ano-mes decrescente

@author Ernani Forastieri
@since 29/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LoadNTV( oGrid )
Local nOperacao := oGrid:GetModel():GetOperation()
Local aStruct   := oGrid:oFormModelStruct:GetFields()
Local nAt       := 0
Local aRet      := {}

If nOperacao <> OP_INCLUIR
	
	aRet := FormLoadGrid( oGrid )
	
	// Ordena decrescente pelo Ano/Mes
	If ( nAt := aScan( aStruct, { |aX| aX[MODEL_FIELD_IDFIELD] == 'NTV_AMINI' } ) ) > 0
		aSort( aRet,,, { |aX,aY| aX[2][nAt] > aY[2][nAt] } )
	EndIf
	
EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA042GRDOK
Valida se as Regras das Structs estão OK
(campos obrigatórios)
Regras de histórico:
	Não permitir históricos Futuros
	Não permitir inclusão de mais de 1 hist com ano-mês final em branco para o mesmo participante e mesma originação
	Não permitir períodos sobrepostos		
	
Structs:
	"NRFMASTER" - "Cabecalho da Tabela de Honorários"
	"NS9DETAIL" - "Valores por categoria"
	"NSDDETAIL" - "Excessão para os participantes"
	"NTVDETAIL" - "Hist. Tab. Honor"
	"NTUDETAIL" - "Hist. Honor / Categ"
	"NTTDETAIL" - "Hist. Honor / Prof"

@Return lRet	 	.T./.F. As informações são válidas ou não
@sample

@author David Gonçalves Fernandes
@since 29/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA042GRDOK( oGrid )
	Local lRet       := .T.
	Local cStruct    := ""
	Local nOperation := oGrid:GetModel():GetOperation()
	Local oStructNTV := Nil
	Local oStructNTT := Nil
	Local nposBranco := 0
	Local nPosSobre  := 0
	Local nI         := 0
	Local cMsg       := ""
	Local aColsOrd   := {}
	Local nLinha     := 0
	Local nPosAMIni  := 1
	Local nPosAMFim  := 2
	Local nLines     := 0
	Local aSaveLines := FWSaveRows( )
	
	If nOperation == 3 .Or. nOperation == 4 //Inclusão (3) ou Alteração (4)

		cStruct := oGrid:GetID()
	
		//Histórico da Tab. de Honorários
		If cStruct == "NTVDETAIL"
			oStructNTV := oGrid:GetModel():GetModel( "NTVDETAIL" )
			nLinha := oStructNTV:nLine
			nLines := oStructNTV:GetQtdLine()

			For nI := 1 to nLines
				If !oStructNTV:IsDeleted(nI) .And. !oStructNTV:IsEmpty(nI)
					aAdd(aColsOrd, {oStructNTV:GetValue("NTV_AMINI",nI), oStructNTV:GetValue("NTV_AMFIM",nI)}) 	
				EndIf
			Next
		
			//Não permitir históricos Futuros
			If (oStructNTV:GetValue('NTV_AMINI') > AnoMes(MsDate())) .Or. (!Empty(oStructNTV:GetValue('NTV_AMFIM')) .AND. oStructNTV:GetValue('NTV_AMFIM') > AnoMes(MsDate()))
					cMsg := STR0031 // "Não é permitido gravar histórico futuros"
					lRet := .F.
			EndIf

			//Não permitir inclusão de mais de 1 hist com ano-mês final em branco
			If lRet
				If Empty(oStructNTV:GetValue("NTV_AMFIM"))
					
					nposBranco := ascan(aColsOrd, {|x| Empty( x[ nPosAMFim ]  )                           .AND. ;
															x[ nPosAMIni ] <> oStructNTV:GetValue("NTV_AMINI") } )
		
					If nposBranco > 0
						cMsg := STR0033 // "É preciso preencher o ano-nês final deste histórico"
						lRet := .F.
					EndIf
		
				EndIf
				
				If lRet
					//Não permitir períodos sobrepostos		
					// Ordena os dados em uma copia, para nao prejudicar a referencia do aCols
					aSort( aColsOrd,,, { |aX,aY| aX[nPosAmIni] > aY[nPosAmIni] } )
					
					//Verifica se o ano-mês inicial é menor ou igual a algum ano-mês final de período anterior
					If nPosSobre == 0 .AND. !Empty(oStructNTV:GetValue("NTV_AMFIM"))
						nposSobre :=		ascan(aColsOrd, {|x| x[ nPosAMIni ]   < oStructNTV:GetValue("NTV_AMINI") .AND. ; //períodos anteriores 
																								 x[ nPosAMFim ]  >= oStructNTV:GetValue("NTV_AMINI") .AND.  ;
																x[ nPosAMIni ] <> x[ nPosAMFim ] } )
					EndIf	
					//Verifica se o ano-mês final é maior ou igual a algum ano-mês inicial de período posterior 
					If nPosSobre == 0 .AND. !Empty(oStructNTV:GetValue("NTV_AMFIM"))
						nposSobre :=		ascan(aColsOrd, {|x| x[ nPosAMIni ]   > oStructNTV:GetValue("NTV_AMINI") .AND. ; //períodos posteriores
																								 x[ nPosAMIni ]  <= oStructNTV:GetValue("NTV_AMFIM") .AND.  ;
																x[ nPosAMIni ] <> x[ nPosAMFim ] } )
					EndIf	      
					//Verifica se o ano-mês inicial do período aberto é menor ou igual a algum ano-mês final
					If nPosSobre == 0 .AND. Empty(oStructNTV:GetValue("NTV_AMFIM"))
						nposSobre :=		ascan(aColsOrd, {|x| x[ nPosAMFim ] >= oStructNTV:GetValue("NTV_AMINI") .AND.   ;
																!Empty( x[ nPosAMFim ] ) } )                            //Períodos fechados
					EndIf
					//Verifica se o ano-mês inicial é maior que algum ano-mês inicial em aberto
					If nPosSobre == 0 .AND. !Empty(oStructNTV:GetValue("NTV_AMFIM"))
						nposSobre :=		ascan(aColsOrd, {|x| x[ nPosAMIni ] <= oStructNTV:GetValue("NTV_AMINI") .AND.   ;
																Empty( x[ nPosAMFim ] ) } )                          //Período aberto
					EndIf
		
					If nposSobre > 0
						lRet := .F.
						cMsg := STR0032 //"Períodos sobrepostos no histórico das participações"   
					EndIf
				EndIf
	
			EndIf
			
			oStructNTV:GoLine(nLinha)
		
		ElseIf cStruct == "NTTDETAIL"
			oStructNTT := oGrid:GetModel():GetModel( "NTTDETAIL" )
			nLinha := oStructNTT:nLine
			nLines := oStructNTT:GetQtdLine()

			For nI := 1 to nLines
				If !oStructNTT:IsDeleted(nI) .And. !oStructNTT:IsEmpty(nI) .And. Empty(FwFldget("NTT_CPART")) 
					lRet := .F.
					cMsg := STR0039 //"O participante não foi preenchido. Verifique!"	 	
					Exit
				EndIf
			Next
			
			oStructNTT:GoLine(nLinha)
			
		ElseIf cStruct == "NSDDETAIL"
			oStructNSD := oGrid:GetModel():GetModel( "NSDDETAIL" )
			nLinha := oStructNSD:nLine
			nLines := oStructNSD:GetQtdLine()

			For nI := 1 to nLines
				If !oStructNSD:IsDeleted(nI) .And. !oStructNSD:IsEmpty(nI) .And. Empty(FwFldget("NSD_CPART")) 
					lRet := .F.
					cMsg := STR0039 //"O participante não foi preenchido. Verifique!"	 	
					Exit
				EndIf
			Next
			
			oStructNSD:GoLine(nLinha)
			
		EndIf

		If !lRet
			JurMsgErro(cMsg)
		EndIf

	EndIf

	FWRestRows( aSaveLines )
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA042VLDCP
Função para validação dos campos o cadastro de cliente

@author David Gonçalves Fernandes
@since 15/10/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA042VLDCP(cCampo)
	Local lRet     := .F.
	Local cMsg     := ''
	Local cTabela  := SubStr( cCampo , 1, 3)
	Local aArea    := Nil
	Local cAlias   := ''
	Local cQuery   := ''
	Local cAmIni   := FWFldGet('NTV_AMINI')

	If cCampo == cTabela + '_AMFIM' .Or. cCampo == cTabela + '_AMINI'
		lRet      := .T.
		If !Empty(FWFLDGET(cTabela+'_AMFIM')) .AND. !Empty(FWFLDGET(cTabela+'_AMINI'))
			lRet := ( FWFLDGET(cTabela+'_AMINI')<=FWFLDGET(cTabela+'_AMFIM') )
			cMsg := STR0030//"O ano-mês final deve ser maior do que o final"
		EndIf
	ElseIf cCampo == 'NTT_CPART'
		cAmIni := FWFldGet('NTV_AMINI')
		
		If !Empty(cAmIni)

			aArea  := GetArea()
			cAlias := GetNextAlias()
			cQuery := JA042QRYF3()
			cQuery := ChangeQuery(cQuery, .F.)
			                                
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
			
			(cAlias)->( dbSelectArea( cAlias ) )
			(cAlias)->( dbGoTop() )
			
			While !(cAlias)->( EOF() )
				If (cAlias)->RD0_CODIGO == FWFLDGET('NTT_CPART')
					lRet := .T.
					Exit
				EndIf
				(cAlias)->( dbSkip() )
			End

			If !lRet
				cMsg := STR0036
			EndIf

			(cAlias)->( dbcloseArea() )
			RestArea(aArea)
		Else
			cMsg := STR0035
		EndIf
		
	EndIf

	If !lRet
		JurMsgErro( cMsg )
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA042CHAV
Função para validação das chaves dos registors

@author David Gonçalves Fernandes
@since 15/10/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA042CHAV(cAlias)
	Local lRet := .T.

	If cAlias == 'NRF' //Tab Honorários
		lRet := ExistChav('NRF', xFilial('NRF') + FWFldGet('NRF_COD'), 1 )
	ElseIf cAlias == 'NS9' //Valor por categoria
		lRet := ExistChav('NS9', xFilial('NS9') + FWFldGet('NRF_COD') + FWFldGet('NS9_CCAT'), 1 )	
	ElseIf cAlias == 'NSD' //Exceção por participante
		lRet := ExistChav('NSD', xFilial('NSD') + FWFldGet('NRF_COD') + FWFldGet('NSD_CPART'), 1 )	
	Elseif cAlias == 'NTV' //Hist. da Tab. honorários
		lRet := ExistChav('NTV', xFilial('NTV') + FWFldGet('NRF_COD') + FWFldGet('NTV_COD'), 1 )
	ElseIf cAlias == 'NTU' //Hist. do valor por categoria
		lRet := ExistChav('NTU', xFilial('NTU') + FWFldGet('NRF_COD') + FWFldGet('NTV_COD') + FWFldGet('NTU_COD'), 1 )
	ElseIf cAlias == 'NTT' //Hist. da exceção por participante
		lRet := ExistChav('NTT', xFilial('NTT') + FWFldGet('NRF_COD') + FWFldGet('NTV_COD') + FWFldGet('NTT_COD'), 1 )
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA042F3HST
Monta a consulta padrão para o histórico dos participantes corresondente ao hitórico da tabela

@Return lRet	 	.T./.F. As informações são válidas ou não       
@sample
Consulta padrão específica RD0HST

@author Juliana Iwayama Velho
@since 14/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA042F3HST()
Local lRet      := .F.
Local aArea     := Nil
Local cQuery    := ''
Local cAmIni    := FWFldGet('NTV_AMINI')
Local aPesq     := {"RD0_SIGLA", "RD0_CODIGO", "RD0_NOME"}
	
	If !Empty(cAmIni)
		aArea    := GetArea()
		cQuery   := JA042QRYF3()
		cQuery   := ChangeQuery(cQuery, .F.)
		uRetorno := ''
		
		If JurF3Qry( cQuery, 'JURRD0', 'RD0RECNO', @uRetorno,, aPesq )
			RD0->( dbGoto( uRetorno ) )
			lRet := .T.
		EndIf
		RestArea( aArea )  

	Else

		lRet := JurMsgErro( STR0035 )
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA042QRYF3()
Monta query para a consulta padrão e a validação do hist. dos participantes

@Return lRet	 	.T./.F. As informações são válidas ou não       
@sample
Consulta padrão específica RD0HST

@author Juliana Iwayama Velho
@since 14/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA042QRYF3()
	Local cQuery := ''
	Local cAmIni := FWFldGet('NTV_AMINI')
	Local cAmFim := FWFldGet('NTV_AMFIM')
	
	If Empty(cAmFim)
		cAmFim := AnoMes(MsDate())
	EndIf
	
	cQuery := " SELECT RD0.RD0_SIGLA, RD0.RD0_CODIGO, RD0.RD0_NOME, RD0.R_E_C_N_O_ RD0RECNO "
	cQuery += " FROM "+RetSqlName("RD0")+" RD0 "
	cQuery += " WHERE RD0.D_E_L_E_T_ = ' ' "
	cQuery +=   " AND RD0.RD0_FILIAL = '" + xFilial( "RD0" ) + "' "
	cQuery +=   " AND RD0.RD0_TPJUR  = '1'"
	cQuery +=   " AND RD0.RD0_MSBLQL = '2'"
	cQuery +=   " AND RD0.RD0_CODIGO IN  ( "
	cQuery +=      " SELECT NUS.NUS_CPART "
	cQuery +=      " FROM "+RetSqlName("NUS")+" NUS "
	cQuery +=      " WHERE NUS.D_E_L_E_T_ = ' ' "
	cQuery +=        " AND NUS.NUS_FILIAL = '" + xFilial( "NUS" ) + "' "
	cQuery +=        " AND '" + cAmIni + "' >= NUS.NUS_AMINI "
	cQuery +=        " AND ('" + cAmIni + "' <= NUS.NUS_AMFIM "
	cQuery +=              " OR NUS.NUS_AMFIM = '"+ Space(TamSx3('NUS_AMFIM')[1]) + "' )) "

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} J42ValNeg
Função utilizada para validação de valores negativos na tabela de honorários 

@author Rafael Rezende Costa
@since 03/06/2013
/*/
//-------------------------------------------------------------------
Function J42ValNeg(cCampo)
Local lRet       := .T.
Local oModel     := Nil
Local oModelXXX  := Nil
local cTab       := ''

Default cCampo   := ''
	
	If cCampo != ''
		oModel := FWModelActive()
		cTab   := LEFT(cCampo, 3)

		If !Empty(cTab)
				oModelXXX := oModel:GetModel(cTab + 'DETAIL') // GRID CORRESPONDENTE PARA VERICAÇÃO
				If (oModelXXX:GetValue(cCampo) < 0)
						lRet := JurMsgErro(i18N('#1' + STR0038, {Alltrim(RetTitle(cCampo))} )) // '#1'+" não pode ser negativo !"			
				EndIf
		EndIF
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA042GdPre
Faz a pré-validação das linhas dos grids

@param oGrid     , Grid que será pré-validado
@param cModelID  , Id do grid
@param cAction   , Ação que está sendo executada 
                   (Ex: ADDLINE, UNDELETE, DELETE, SETVALUE, CANSETVALUE, ISENABLE)
@param cAnoMesAtu, Ano-mês atual para validação dos históricos

@return lRet, .T./.F. As informações são válidas ou não

@author Jorge Martins
@since  28/03/2022
/*/
//-------------------------------------------------------------------
Function JA042GdPre(oGrid, cModelID, cAction, cAnoMesAtu)
Local lRet       := .T.
Local cProblema  := ""
Local cAnoMesIni := ""
Local oGridNTV   := Nil
Local nOperation := oGrid:GetModel():GetOperation()
	
	If cAction == "DELETE"

		nOperation := oGrid:GetModel():GetOperation()
	
		If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE // Inclusão (3) ou Alteração (4)
	
			// Histórico da Tab. de Honorários / Categorias
			If cModelID == "NTUDETAIL"
				// Se a Data inicial do período for MENOR que ano-mês atual         - NÃO PERMITE EXCLUIR TODAS AS LINHAS.
				// Se a Data inicial do período for MAIOR ou IGUAL ao ano-mês atual - PERMITE EXCLUIR TODAS AS LINHAS, 
				// pois a própria rotina criará novamente as categorias no histórico com base nas categorias e valores atuais da tabela de honorário (NS9)
				oGridNTV   := oGrid:GetModel():GetModel("NTVDETAIL")
				cAnoMesIni := oGridNTV:GetValue("NTV_AMINI")
				If !Empty(cAnoMesAtu) .And. !Empty(cAnoMesIni) .And. cAnoMesIni < cAnoMesAtu
					If oGrid:Length(.T.) == 1 // Indica que a última linha válida está sendo deletada
						cProblema := STR0034 + Transform(cAnoMesIni, '@R 9999-99') // "É preciso incluir Valor por categoria no histórico com ano-mês inicial: "
						lRet := JurMsgErro(cProblema,, STR0040) // "Mantenha ao menos uma linha válida."
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet