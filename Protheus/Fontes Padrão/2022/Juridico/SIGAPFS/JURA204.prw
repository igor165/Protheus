#INCLUDE "JURA204.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "FILEIO.CH"

// Campos dos models de lançamentos, carregados manualmente
#DEFINE CAMPOSNT1 'NT1_PARC|NT1_DATAIN|NT1_DATAFI|NT1_DESCRI|NT1_CMOEDA|NT1_DMOEDA|NT1_VALORB|NT1_VALORA|NT1_DATAAT|NT1_COTAC1|NT1_COTAC2|NT1_CCONTR|NT1_DCONTR|'
#DEFINE CAMPOSNUE 'NUE_COD|NUE_DATATS|NUE_SIGLA1|NUE_DPART1|NUE_SIGLA2|NUE_DPART2|NUE_CATIVI|NUE_DATIVI|NUE_COBRAR|NUE_UTL|NUE_UTR|NUE_HORAL|NUE_HORAR|NUE_TEMPOL|NUE_TEMPOR|NUE_DESC|NUE_CMOEDA|NUE_DMOEDA|NUE_VALORH|NUE_VALOR|NUE_VALOR1|NUE_COTAC1|NUE_COTAC2|NUE_CCASO|NUE_DCASO|NUE_CCLIEN|NUE_CLOJA|NUE_DCLIEN|NUE_CLTAB|NUE_DLTAB|'
#DEFINE CAMPOSNVY 'NVY_COD|NVY_DATA|NVY_CTPDSP|NVY_DTPDSP|NVY_DESCRI|NVY_COBRAR|NVY_CMOEDA|NVY_DMOEDA|NVY_VALOR|NVY_CCASO|NVZ_DCASO|NVY_CCLIEN|NVY_CLOJA|NVY_DCLIEN|NVY_COTAC1|NVY_COTAC2|'
#DEFINE CAMPOSNV4 'NV4_COD|NV4_DTLANC|NV4_CTPSRV|NV4_DTPSRV|NV4_DESCRI|NV4_COBRAR|NV4_CMOEH|NV4_DMOEH|NV4_VLHFAT|NV4_VLHTAB|NV4_CMOED|NV4_DMOED|NV4_VLDFAT|NV4_VLDTAB|NV4_COTAC1|NV4_COTAC2|NV4_CCASO|NV4_DCASO|'
#DEFINE CAMPOSNVV 'NVV_COD|NVV_DTINIH|NVV_DTFIMH|NVV_CMOE1|NVV_DMOE1|NVV_VALORH|NVV_DTINID|NVV_DTFIMD|NVV_CMOE2|NVV_DMOE2|NVV_VALORD|NVV_CCONTR|NVV_DCONTR|NVV_CCLIEN|NVV_CLOJA|NVV_DCLIEN|NVV_DTINIT|NVV_DTFIMT|NVV_CMOE4|NVV_DMOE4|NVV_VALORT|'
#DEFINE CAMPOSNVN 'NVN_CJCONT|NVN_CPREFT|NVN_CFATAD|NVN_CFIXO|NVN_CLIPG|NVN_LOJPG|NVN_LOJPG|NVN_CFILA|NVN_CFATUR|NVN_CESCR'

Static CPOUSRNT1    := J204CpoUsr("NT1")
Static CPOUSRNUE    := J204CpoUsr("NUE")
Static CPOUSRNVY    := J204CpoUsr("NVY")
Static CPOUSRNV4    := J204CpoUsr("NV4") 
Static CPOUSRNVV    := J204CpoUsr("NVV")
 
Static JA204CodMot  := ''
Static cLastFOpen   := 'C:\'
Static _cStatus     := ''
Static _dDtPagt     := ''
Static _nVlrPag     := 0
Static _lFwPDCanUse := FindFunction("FwPDCanUse")

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA204
Operações em Fatura

@author David Gonçalves Fernandes
@since 05/01/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA204()
Local oDlg204    := Nil
Local oFWLayer   := Nil
Local oPanelUp   := Nil
Local oPanelDown := Nil
Local oBrwCasos  := Nil
Local aCoors     := FwGetDialogSize( oMainWnd )
Local cLojaAuto  := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local oFilaExe   := JurFilaExe():New("JURA204")
Local lVldUser   := Iif(FindFunction("JurVldUxP"), JurVldUxP(), .T.) // Valida o participante relacionado ao usuário logado

Private oBrowse  := Nil

If lVldUser .And. oFilaExe:OpenWindow(.T.) //Indica que a tela está em execução para Thread de relatório
	
	SetCloseThread(.F.)

	oFilaExe:StartReport() //Inicia a thread emissão do relatório

	Define MsDialog oDlg204 Title STR0007 From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] STYLE nOR( WS_VISIBLE, WS_POPUP ) Pixel //"Operação de Faturas"

	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlg204, .F., .T. )

	// Painel Superior
	oFWLayer:AddLine( 'UP', 60, .F. )
	oFWLayer:AddCollumn( 'FATURAS', 100, .T., 'UP' )
	oPanelUp := oFWLayer:GetColPanel( 'FATURAS', 'UP' )

	// MarkBrowse Superior
	oBrowse := FWMBrowse():New()
	oBrowse:SetOwner( oPanelUp )
	oBrowse:SetDescription( STR0007 ) // "Operação em Fatura"
	oBrowse:SetAlias( "NXA" )
	Iif(cLojaAuto == "1", JurBrwRev(oBrowse, "NXA", {"NXA_CLOJA"}), )
	oBrowse:SetLocate()
	oBrowse:SetMenuDef('JURA204')
	oBrowse:DisableDetails()
	oBrowse:SetProfileID( '1' )
	oBrowse:SetCacheView( .F. )
	oBrowse:SetWalkThru(.F.)
	oBrowse:SetAmbiente(.F.)
	oBrowse:ForceQuitButton(.T.)
	oBrowse:SetBeforeClose({ || oBrowse:VerifyLayout(), oBrwCasos:VerifyLayout()})
	oBrowse:SetFilterDefault("NXA_TIPO != 'MF'")
	JurSetLeg( oBrowse, "NXA" )
	JurSetBSize( oBrowse )
	J204Filter(oBrowse, cLojaAuto) // Adiciona filtros padrãos no browse

	oBrowse:Activate()

	// Painel Inferior
	oFWLayer:addLine( 'DOWN', 40, .F. )
	oFWLayer:AddCollumn( 'CASOS',  100, .T., 'DOWN' )
	oPanelDown := oFWLayer:GetColPanel( 'CASOS', 'DOWN' )

	oBrwCasos := FWMBrowse():New()
	oBrwCasos:SetOwner( oPanelDown )
	oBrwCasos:SetDescription( STR0012 ) // "Casos da fatura"
	oBrwCasos:SetMenuDef( 'JURA201' )   // Referencia uma funcao que nao tem menu para que exiba nenhum
	oBrwCasos:DisableDetails()
	oBrwCasos:SetAlias( 'NXC' )
	Iif(cLojaAuto == "1", JurBrwRev(oBrwCasos, "NXC", {"NXC_CLOJA"}), )
	oBrwCasos:SetProfileID( '3' )
	oBrwCasos:SetCacheView( .F. )
	oBrwCasos:SetWalkThru(.F.)
	oBrwCasos:SetAmbiente(.F.)
	oBrwCasos:Activate()

	oRelation := FWBrwRelation():New()
	oRelation:AddRelation( oBrowse, oBrwCasos, { { 'NXC_FILIAL', "xFilial( 'NXC' )" }, { 'NXC_CESCR', 'NXA_CESCR' }, { 'NXC_CFATUR', 'NXA_COD' } } )
	oRelation:Activate()

	Activate MsDialog oDlg204 Centered

	oFilaExe:CloseWindow() // Indica que tela fechada para o client de impressão ser fechado também.

EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} J204Filter
Adiciona filtros padrões no browse

@param  oBrowse, objeto, browse da rotina

@author Reginaldo Borges
@since  08/08/2022
/*/
//-------------------------------------------------------------------
Static Function J204Filter(oBrowse, cLojaAuto)
Local cId      := "1"
Local aFilNXA1 := {}
Local aFilNXA2 := {}
Local aFilNXA3 := {}
Local aFilNXA4 := {}
Local aFilNXA5 := {}

	oBrowse:AddFilter(STR0247, 'NXA_SITUAC == "1"',,.F.,,,, cId)// "Somente válidas"

	SAddFilPar("NXA_DTEMI", ">=", "%NXA_DTEMI0%", @aFilNXA1)
	oBrowse:AddFilter(STR0248, 'NXA_DTEMI >= "%NXA_DTEMI0%"', .F., .F., , .T., aFilNXA1, STR0248) // "Emissao Maior ou Igual a"

	SAddFilPar("NXA_DTEMI", "<=", "%NXA_DTEMI0%", @aFilNXA2)
	oBrowse:AddFilter(STR0249, 'NXA_DTEMI <= "%NXA_DTEMI0%"', .F., .F., , .T., aFilNXA2, STR0249) // "Emissao Menor ou Igual a"

	SAddFilPar("NXA_CPART", "==", "%NXA_CPART0%", @aFilNXA3)
	oBrowse:AddFilter(STR0251, 'NXA_CPART == "%NXA_CPART0%"', .F., .F., , .T., aFilNXA3, STR0251) // "Sócio responsável"

	If cLojaAuto == "2"
		SAddFilPar("NXA_CLIPG", "==", "%NXA_CLIPG0%", @aFilNXA4)
		SAddFilPar("NXA_LOJPG", "==", "%NXA_LOJPG0%", @aFilNXA4)
		oBrowse:AddFilter(STR0250, 'NXA_CLIPG == "%NXA_CLIPG0%" .AND. NXA_LOJPG == "%NXA_LOJPG0%"', .F., .F., , .T., aFilNXA4, STR0250) // "Cliente pagador"

		SAddFilPar("NXA_CCLIEN", "==", "%NXA_CCLIEN0%", @aFilNXA5)
		SAddFilPar("NXA_CLOJA", "==", "%NXA_CLOJA0%", @aFilNXA5)
		oBrowse:AddFilter(STR0252, 'NXA_CCLIEN == "%NXA_CCLIEN0%" .AND. NXA_CLOJA == "%NXA_CLOJA0%"', .F., .F., , .T., aFilNXA5, STR0252) // "Cliente"
	Else
		SAddFilPar("NXA_CLIPG", "==", "%NXA_CLIPG0%", @aFilNXA4)
		oBrowse:AddFilter(STR0250, 'NXA_CLIPG == "%NXA_CLIPG0%"', .F., .F., , .T., aFilNXA4, STR0250) // "Cliente pagador"

		SAddFilPar("NXA_CCLIEN", "==", "%NXA_CCLIEN0%", @aFilNXA5)
		oBrowse:AddFilter(STR0252, 'NXA_CCLIEN == "%NXA_CCLIEN0%"', .F., .F., , .T., aFilNXA5, STR0252) // "Cliente"
	EndIf

Return Nil

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
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Felipe Bonvicini Conti
@since 05/01/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina    := {}
Local aPesq      := {}
Local aRotAux    := {}
Local nFor       := 0
Local lPDUserAc  := Iif(FindFunction("JPDUserAc"), JPDUserAc(), .T.) // Indica se o usuário possui acesso a dados sensíveis ou pessoais (LGPD)

aAdd( aRotina, { STR0001, aPesq                    , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aPesq,   { STR0001, 'PesqBrw'                , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aPesq,   { STR0170, 'JFiltraCaso( oBrowse )' , 0, 3, 0, .T. } ) // "Filtro por Caso"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA204"        , 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0004, "JA204Alter(4)"          , 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0018, "JA204CanFT()"           , 0, 6, 0, NIL } ) // "Cancelar"
If lPDUserAc
	aAdd( aRotina, { STR0019, "J204PDF()"              , 0, 6, 0, NIL } ) // "Docs Relacionados"
	aAdd( aRotina, { STR0021, "JA204Confe()"           , 0, 6, 0, NIL } ) // "Relatório Conf."
EndIf
aAdd( aRotina, { STR0020, "JA204Reimp()"           , 0, 6, 0, NIL } ) // "Refazer"
aAdd( aRotina, { STR0025, "J204EMail()"            , 0, 6, 0, NIL } ) // "Enviar por E-mail"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA204"        , 0, 8, 0, NIL } ) // "Imprimir"
aAdd( aRotina, { STR0087, "JA204PTIT()"            , 0, 2, 0, NIL } ) // "Titulos"
aAdd( aRotina, { STR0217, "JURA204B()"             , 0, 2, 0, NIL } ) // "Vínculo de Time Sheets"
aAdd( aRotina, { STR0242, "CTBC662"                , 0, 7, 0, NIL } ) // "Tracker Contábil"


If Existblock("J204ROT")
	aRotAux := Execblock("J204ROT", .F., .F.)
	If ValType(aRotAux) == "A" .And. Len(aRotAux) > 0
		For nFor := 1 To Len(aRotAux)
			aAdd(aRotina, aRotAux[nFor])
		Next nFor
	EndIf
EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Faturas

@author Felipe Bonvicini Conti
@since 05/01/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView      := Nil
Local oModel     := FWLoadModel( "JURA204" )
Local oStructNXA := FWFormStruct( 2, "NXA" )
Local oStructNXB := FWFormStruct( 2, "NXB" )
Local oStructNXC := FWFormStruct( 2, "NXC" )
Local oStructNXD := FWFormStruct( 2, "NXD" )
Local oStructNXE := FWFormStruct( 2, "NXE" )
Local oStructNXF := FWFormStruct( 2, "NXF" )
Local oStructNT1 := FWFormStruct( 2, "NT1", { | cCampo | AllTrim(cCampo) + '|' $ CAMPOSNT1 + CPOUSRNT1 } ) //Fixo
Local oStructNUE := FWFormStruct( 2, "NUE", { | cCampo | AllTrim(cCampo) + '|' $ CAMPOSNUE + CPOUSRNUE } ) //Time-Sheet
Local oStructNVY := FWFormStruct( 2, "NVY", { | cCampo | AllTrim(cCampo) + '|' $ CAMPOSNVY + CPOUSRNVY } ) //Despesas
Local oStructNV4 := FWFormStruct( 2, "NV4", { | cCampo | AllTrim(cCampo) + '|' $ CAMPOSNV4 + CPOUSRNV4 } ) //Lançamento Tabelado
Local oStructNVV := FWFormStruct( 2, "NVV", { | cCampo | AllTrim(cCampo) + '|' $ CAMPOSNVV + CPOUSRNVV } ) //Fatura Adicional
Local oStructNVN := FWFormStruct( 2, "NVN", { | cCampo | !AllTrim(cCampo) $ CAMPOSNVN .And. AllTrim(cCampo) != "NVN_CCONTR" } ) //Encaminhamento de fatura.
Local cLojaAuto  := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local lEncaminha := NVN->(ColumnPos("NVN_CFATUR")) > 0 .And. NVN->(ColumnPos("NVN_CESCR")) > 0 //Proteção
Local lCpoTSNCob := NX1->(ColumnPos("NX1_VTSNC")) > 0 // @12.1.2210

If SuperGetMV("MV_JFSINC", .F., '2') == '2'
	oStructNXB:RemoveField( 'NXB_CCLICM' )
	oStructNXB:RemoveField( 'NXB_CLOJCM' )
	oStructNXB:RemoveField( 'NXB_CCASCM' )
EndIf

If cLojaAuto == "1"
	oStructNXA:RemoveField("NXA_CLOJA")
	oStructNXB:RemoveField("NXB_CLOJA")
	oStructNXC:RemoveField("NXC_CLOJA")
	oStructNXD:RemoveField("NXD_CLOJA")
	oStructNXE:RemoveField("NXE_CLOJA")
	oStructNT1:RemoveField("NT1_CLOJA")
	oStructNUE:RemoveField("NUE_CLOJA")
	oStructNVY:RemoveField("NVY_CLOJA")
	oStructNV4:RemoveField("NV4_CLOJA")
	oStructNVV:RemoveField("NVV_CLOJA")
	oStructNXB:RemoveField("NXB_CLOJCM")
EndIf

oStructNXA:RemoveField("NXA_CPART")
oStructNXA:RemoveField("NXA_USUEMI")
oStructNXA:RemoveField("NXA_USRALT")
oStructNXA:RemoveField("NXA_USRCAN")
If NXA->(ColumnPos("NXA_DTCEMI")) > 0
	oStructNXA:RemoveField("NXA_DTCEMI")
	oStructNXA:RemoveField("NXA_DTCCAN")
EndIf

oStructNXB:RemoveField("NXB_CESCR")
oStructNXB:RemoveField("NXB_CFATUR")

oStructNXC:RemoveField("NXC_CESCR")
oStructNXC:RemoveField("NXC_CFATUR")

oStructNXD:RemoveField("NXD_CESCR")
oStructNXD:RemoveField("NXD_CFATUR")
oStructNXD:RemoveField("NXD_CPART")

oStructNXE:RemoveField("NXE_CESCR")
oStructNXE:RemoveField("NXE_CFATUR")
oStructNXE:RemoveField("NXE_FILIAD")

oStructNXF:RemoveField("NXF_CESCR")
oStructNXF:RemoveField("NXF_CFATUR")
oStructNXF:RemoveField("NXF_COD")

If lCpoTSNCob .And. !SuperGetMV("MV_JTSNCOB",, .F.) // Indica se vincula TimeSheet não cobrável na emissão
	oStructNXC:RemoveField("NXC_VTSNC")
	oStructNXB:RemoveField("NXB_VTSNC")
EndIf

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField("JURA204_VIEW", oStructNXA, "NXAMASTER")
oView:AddGrid("JURA204_NXB", oStructNXB, "NXBDETAIL")
oView:AddGrid("JURA204_NXE", oStructNXE, "NXEDETAIL")
oView:AddGrid("JURA204_NXF", oStructNXF, "NXFDETAIL")
If lEncaminha //Proteção
	oView:AddGrid("JURA204_NVN", oStructNVN, "NVNDETAIL")
EndIf
//Lançamentos
oView:AddGrid("JURA204_NT1", oStructNT1, "NT1DETAIL") // Fixo
oView:AddGrid("JURA204_NXC", oStructNXC, "NXCDETAIL") //"Casos da Fatura"
oView:AddGrid("JURA204_NXD", oStructNXD, "NXDDETAIL") //"Participantes da fatura"
oView:AddGrid("JURA204_NUE", oStructNUE, "NUEDETAIL") //"Time-Sheet"
oView:AddGrid("JURA204_NVY", oStructNVY, "NVYDETAIL") //"Despesas"
oView:AddGrid("JURA204_NV4", oStructNV4, "NV4DETAIL") //"Lanc. Tabelado"
oView:AddGrid("JURA204_NVV", oStructNVV, "NVVDETAIL") //"Fat. Adicional"

oView:CreateFolder("FOLDER_01")

oView:AddSheet("FOLDER_01", "ABA_01_01", STR0214 ) //"Detalhes da Fatura"
oView:AddSheet("FOLDER_01", "ABA_01_02", STR0010 ) //"Contratos da Fatura"
oView:AddSheet("FOLDER_01", "ABA_01_03", STR0116 ) //"Fat. Adicional"
oView:AddSheet("FOLDER_01", "ABA_01_04", STR0022 ) //"Resumo de Despesas da Fatura"
oView:AddSheet("FOLDER_01", "ABA_01_05", STR0023 ) //"Cambios Utilizados na Fatura"
If lEncaminha //Proteção
	oView:AddSheet("FOLDER_01", "ABA_01_06", STR0218 ) //"Encaminhamento de fatura"
EndIf
oView:createHorizontalBox("BOX_01_F01_A01",100,,,"FOLDER_01","ABA_01_01") //"Detalhes da Fatura"
oView:createHorizontalBox("BOX_01_F01_A02",040,,,"FOLDER_01","ABA_01_02") //"Contratos da Fatura"
oView:createHorizontalBox("BOX_01_F01_A03",060,,,"FOLDER_01","ABA_01_02") //"Contratos da Fatura (Detalhes)"
oView:createHorizontalBox("BOX_01_F01_A04",100,,,"FOLDER_01","ABA_01_03") //"Fat. Adicional"
oView:createHorizontalBox("BOX_01_F01_A05",100,,,"FOLDER_01","ABA_01_04") //"Resumo de Despesas da Fatura"
oView:createHorizontalBox("BOX_01_F01_A06",100,,,"FOLDER_01","ABA_01_05") //"Cambios Utilizados na Fatura"
If lEncaminha //Proteção
	oView:createHorizontalBox("BOX_01_F01_A07",100,,,"FOLDER_01","ABA_01_06") //"Encaminhamento de fatura"
EndIf
oView:CreateFolder("FOLDER_02","BOX_01_F01_A03") //"Contratos da Fatura (Detalhes)"

oView:AddSheet("FOLDER_02", "ABA_02_01", STR0112 ) //"Fixo"
oView:AddSheet("FOLDER_02", "ABA_02_02", STR0012 ) //"Casos da Fatura"
oView:AddSheet("FOLDER_02", "ABA_02_03", STR0014 ) //"Participantes da fatura"
oView:AddSheet("FOLDER_02", "ABA_02_04", STR0113 ) //"Time-Sheet"
oView:AddSheet("FOLDER_02", "ABA_02_05", STR0114 ) //"Despesas"
oView:AddSheet("FOLDER_02", "ABA_02_06", STR0115 ) //"Lanc. Tabelado"

oView:createHorizontalBox("BOX_01_F02_A01",100,,,"FOLDER_02","ABA_02_01") //"Fixo"
oView:createHorizontalBox("BOX_01_F02_A02",100,,,"FOLDER_02","ABA_02_02") //"Casos da Fatura"
oView:createHorizontalBox("BOX_01_F02_A03",100,,,"FOLDER_02","ABA_02_03") //"Participantes
oView:createHorizontalBox("BOX_01_F02_A04",100,,,"FOLDER_02","ABA_02_04") //"Time-Sheet"
oView:createHorizontalBox("BOX_01_F02_A05",100,,,"FOLDER_02","ABA_02_05") //"Despesas"
oView:createHorizontalBox("BOX_01_F02_A06",100,,,"FOLDER_02","ABA_02_06") //"Lanc. Tabelado"

oView:SetOwnerView("JURA204_VIEW", "BOX_01_F01_A01") //"Detalhes da Fatura"
oView:SetOwnerView("JURA204_NXB" , "BOX_01_F01_A02") //"Contratos da Fatura"
oView:SetOwnerView("JURA204_NVV" , "BOX_01_F01_A04") //"Fat. Adicional"
oView:SetOwnerView("JURA204_NXE" , "BOX_01_F01_A05") //"Resumo de Despesas da Fatura"
oView:SetOwnerView("JURA204_NXF" , "BOX_01_F01_A06") //"Cambios Utilizados na Fatura"
If lEncaminha //Proteção
	oView:SetOwnerView("JURA204_NVN" , "BOX_01_F01_A07") //"Encaminhamento de fatura"
EndIf
//Lancamentos
oView:SetOwnerView("JURA204_NT1" , "BOX_01_F02_A01") //"Fixo"
oView:SetOwnerView("JURA204_NXC" , "BOX_01_F02_A02") //Casos
oView:SetOwnerView("JURA204_NXD" , "BOX_01_F02_A03") //"Participantes
oView:SetOwnerView("JURA204_NUE" , "BOX_01_F02_A04") //"Time-Sheet"
oView:SetOwnerView("JURA204_NVY" , "BOX_01_F02_A05") //"Despesas"
oView:SetOwnerView("JURA204_NV4" , "BOX_01_F02_A06") //"Lanc. Tabelado"

oView:SetDescription( STR0007 ) // "Operação em Faturas"
oView:EnableControlBar( .T. )

// Desabilita as alterações no GRID NXB
oView:SetNoInsertLine("JURA204_NXB")
oView:SetNoDeleteLine("JURA204_NXB")
oView:SetNoUpdateLine("JURA204_NXB")

// Desabilita as alterações no GRID NXC
oView:SetNoInsertLine("JURA204_NXC")
oView:SetNoDeleteLine("JURA204_NXC")

// Desabilita as alterações no GRID NXD
oView:SetNoInsertLine("JURA204_NXD")
oView:SetNoDeleteLine("JURA204_NXD")
oView:SetNoUpdateLine("JURA204_NXD")

// Desabilita as alterações no GRID NXE
oView:SetNoInsertLine("JURA204_NXE")
oView:SetNoDeleteLine("JURA204_NXE")
oView:SetNoUpdateLine("JURA204_NXE")

// Desabilita as alterações no GRID NXF
oView:SetNoInsertLine("JURA204_NXF")
oView:SetNoDeleteLine("JURA204_NXF")
oView:SetNoUpdateLine("JURA204_NXF")

//Lançamentos
oView:SetNoInsertLine("JURA204_NT1")
oView:SetNoDeleteLine("JURA204_NT1")
oView:SetNoUpdateLine("JURA204_NT1")

oView:SetNoInsertLine("JURA204_NUE")
oView:SetNoDeleteLine("JURA204_NUE")
oView:SetNoUpdateLine("JURA204_NUE")

oView:SetNoInsertLine("JURA204_NVY")
oView:SetNoDeleteLine("JURA204_NVY")
oView:SetNoUpdateLine("JURA204_NVY")

oView:SetNoInsertLine("JURA204_NV4")
oView:SetNoDeleteLine("JURA204_NV4")
oView:SetNoUpdateLine("JURA204_NV4")

oView:SetNoInsertLine("JURA204_NVV")
oView:SetNoDeleteLine("JURA204_NVV")
oView:SetNoUpdateLine("JURA204_NVV")

If lEncaminha //Proteção
	oView:AddIncrementField("NVNDETAIL", "NVN_COD")
EndIf

oView:AddUserButton(STR0216, 'SDUAPPEND', {|oAux| JA204CpRed(oAux)})

oView:SetViewProperty( '*', "GRIDSEEK" ) // Habilita a pesquisa

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Faturas

@author Felipe Bonvicini Conti
@since 05/01/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local lShowVirt  := !JurIsRest() // Inclui os campos virtuais nos structs somente se não for REST (Necessário já que os inicializadores dos campos virtuais são executados sempre, mesmo sem o uso do header FIELDVIRTUAL = TRUE)
Local oStructNXA := FWFormStruct( 1, "NXA",,, lShowVirt )
Local oStructNXB := FWFormStruct( 1, "NXB",,, lShowVirt )
Local oStructNXC := FWFormStruct( 1, "NXC",,, lShowVirt )
Local oStructNXD := FWFormStruct( 1, "NXD",,, lShowVirt )
Local oStructNXE := FWFormStruct( 1, "NXE",,, lShowVirt )
Local oStructNXF := FWFormStruct( 1, "NXF",,, lShowVirt )
Local oStructNT1 := FWFormStruct( 1, "NT1", { | cCampo |  AllTrim( cCampo ) + '|' $ CAMPOSNT1 + CPOUSRNT1 },, lShowVirt ) // Fixo
Local oStructNUE := FWFormStruct( 1, "NUE", { | cCampo |  AllTrim( cCampo ) + '|' $ CAMPOSNUE + CPOUSRNUE },, lShowVirt ) // Time-Sheet
Local oStructNVY := FWFormStruct( 1, "NVY", { | cCampo |  AllTrim( cCampo ) + '|' $ CAMPOSNVY + CPOUSRNVY },, lShowVirt ) // Despesas
Local oStructNV4 := FWFormStruct( 1, "NV4", { | cCampo |  AllTrim( cCampo ) + '|' $ CAMPOSNV4 + CPOUSRNV4 },, lShowVirt ) // Lançamento Tabelado
Local oStructNVV := FWFormStruct( 1, "NVV", { | cCampo |  AllTrim( cCampo ) + '|' $ CAMPOSNVV + CPOUSRNVV },, lShowVirt ) // Fatura Adicional
Local oStructNXM := FWFormStruct( 1, "NXM",,, lShowVirt )
Local oStructNVN := FWFormStruct( 1, "NVN",,, lShowVirt )
Local cNumCaso   := SuperGetMV( 'MV_JCASO1',, 2 )
Local cIndexNXC  := ""
Local oCommit    := JA204COMMIT():New()
Local lEncaminha := NVN->(ColumnPos("NVN_CFATUR")) > 0 .And. NVN->(ColumnPos("NVN_CESCR")) > 0 //Proteção
Local lStatus    := .F.

If !lShowVirt
	// Adiciona os campos virtuais de "SIGLA" novamente nas estruturas, pois foram retirados via lShowVirt,
	// mas precisam existir para execução das operações nos lançamentos via REST
	AddCampo(1, "NUE_SIGLA1", @oStructNUE)
	AddCampo(1, "NUE_SIGLA2", @oStructNUE)
	AddCampo(1, "NXA_SIGLA" , @oStructNXA)
	AddCampo(1, "NXA_SIGLA2", @oStructNXA)
	AddCampo(1, "NXA_SIGLA3", @oStructNXA)
	AddCampo(1, "NXA_SIGLA4", @oStructNXA)
	AddCampo(1, "NXD_SIGLA" , @oStructNXD)
EndIf

If cNumCaso $ '1'
	cIndexNXC := "NXC_CCLIEN+NXC_CLOJA+NXC_CCASO"
Else
	cIndexNXC := "NXC_CCASO"
EndIf

oStructNXE:RemoveField("NXE_CESCR")
oStructNXE:RemoveField("NXE_CFATUR")
oStructNXE:RemoveField("NXE_FILIAD")

oStructNXF:RemoveField("NXF_CESCR")
oStructNXF:RemoveField("NXF_CFATUR")
oStructNXF:RemoveField("NXF_COD")

If !FWAliasInDic("OHT") .Or. !FwIsInCallStack("J243SE1Opt") // Cobrança
	oStructNXM:AddField(                                          ;
			"ORDEM"                                              ,; // [01]  C   Titulo do campo
			"ORDEM"                                              ,; // [02]  C   ToolTip do campo
			"__ORDEM"                                            ,; // [03]  C   Id do Field
			"N"                                                  ,; // [04]  C   Tipo do campo
			2                                                    ,; // [05]  N   Tamanho do campo
			0                                                    ,; // [06]  N   Decimal do campo
			NIL                                                  ,; // [07]  B   Code-block de validação do campo
			NIL                                                  ,; // [08]  B   Code-block de validação When do campo
			NIL                                                  ,; // [09]  A   Lista de valores permitido do campo
			NIL                                                  ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
			FwBuildFeature(STRUCT_FEATURE_INIPAD, "IIF(INCLUI, 0, NXM->NXM_ORDEM)"),; // [11]  B   Code-block de inicializacao do campo
			NIL                                                  ,; // [12]  L   Indica se trata-se de um campo chave
			NIL                                                  ,; // [13]  L   Indica se o campo pode receber valor em uma operação de update.
			.T.                                                   ) // [14]  L   Indica se o campo é virtual

	oStructNXM:RemoveField("NXM_CESCR")
	oStructNXM:RemoveField("NXM_CFATUR")
EndIf

oModel := MPFormModel():New( 'JURA204', /*Pre-Validacao*/, {|oM| IIF(IsInCallStack("J204PDF") .Or. FwIsInCallStack("J243SE1Opt"), .T., JA204TUDOK(oM))} /*Pos-Validacao*/, /*Commit*/, /*Cancel*/)
oModel:AddFields( "NXAMASTER", NIL, oStructNXA, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:AddGrid( "NXBDETAIL", "NXAMASTER" /*cOwner*/, oStructNXB, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )
oModel:AddGrid( "NXCDETAIL", "NXBDETAIL" /*cOwner*/, oStructNXC, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, )
oModel:AddGrid( "NT1DETAIL", "NXBDETAIL" /*cOwner*/, oStructNT1, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, {|oGrid| J204LdLanc("NT1", oGrid, CAMPOSNT1)} )
oModel:AddGrid( "NXDDETAIL", "NXCDETAIL" /*cOwner*/, oStructNXD, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, {|oGrid| LoadNXD(oGrid) } )
oModel:AddGrid( "NUEDETAIL", "NXCDETAIL" /*cOwner*/, oStructNUE, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, {|oGrid| J204LdLanc("NUE", oGrid, CAMPOSNUE)} )
oModel:AddGrid( "NVYDETAIL", "NXCDETAIL" /*cOwner*/, oStructNVY, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, {|oGrid| J204LdLanc("NVY", oGrid, CAMPOSNVY)} )
oModel:AddGrid( "NV4DETAIL", "NXCDETAIL" /*cOwner*/, oStructNV4, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, {|oGrid| J204LdLanc("NV4", oGrid, CAMPOSNV4)} )
oModel:AddGrid( "NXEDETAIL", "NXAMASTER" /*cOwner*/, oStructNXE, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )
oModel:AddGrid( "NXFDETAIL", "NXAMASTER" /*cOwner*/, oStructNXF, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )
If lEncaminha
	oModel:AddGrid( "NVNDETAIL", "NXAMASTER" /*cOwner*/, oStructNVN, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )
EndIf
oModel:AddGrid( "NXMDETAIL", "NXAMASTER" /*cOwner*/, oStructNXM, /*bLinePre*/, /*bLinePost*/, /*bPre*/, {|| J204PDFPos()} /*bPost*/, {|oGrid| J204LdLanc("NXM", oGrid, "")} )
oModel:AddGrid( "NVVDETAIL", "NXAMASTER" /*cOwner*/, oStructNVV, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, {|oGrid| J204LdLanc("NVV", oGrid, CAMPOSNVV)} )

oModel:GetModel("NXBDETAIL"):SetNoInsertLine()
oModel:GetModel("NXBDETAIL"):SetNoUpdateLine()
oModel:GetModel("NXBDETAIL"):SetNoDeleteLine()
oModel:GetModel("NXBDETAIL"):SetUniqueLine( {"NXB_CCONTR"} )
oModel:SetRelation("NXBDETAIL", { { "NXB_FILIAL", "xFilial('NXB')" }, { "NXB_CESCR", "NXA_CESCR" }, { "NXB_CFATUR", "NXA_COD" } }, NXB->( IndexKey( 1 ) ))  //CONTRATOS DA FATURA

oModel:GetModel("NXCDETAIL"):SetNoInsertLine()
oModel:GetModel("NXCDETAIL"):SetNoDeleteLine()
oModel:SetRelation("NXCDETAIL", { { "NXC_FILIAL", "xFilial( 'NXC' ) " }, { "NXC_CESCR", "NXB_CESCR" }, { "NXC_CFATUR", "NXB_CFATUR" }, {"NXC_CCONTR" ,"NXB_CCONTR"} } , cIndexNXC ) //CASOS DA FATURA

oModel:GetModel("NXDDETAIL"):SetNoInsertLine()
oModel:GetModel("NXDDETAIL"):SetNoUpdateLine()
oModel:GetModel("NXDDETAIL"):SetNoDeleteLine()
oModel:SetRelation("NXDDETAIL", { { "NXD_FILIAL", "xFilial('NXD')" }, { "NXD_CFATUR", "NXC_CFATUR" }, { "NXD_CESCR", "NXC_CESCR" }, {"NXD_CCONTR", "NXC_CCONTR"}, {"NXD_CCLIEN" ,"NXC_CCLIEN"}, {"NXD_CLOJA" ,"NXC_CLOJA"}, {"NXD_CCASO" ,"NXC_CCASO"} } , NXD->( IndexKey(1) )) //PARTICIPANTE DA FATURA

oModel:GetModel("NXEDETAIL"):SetNoInsertLine()
oModel:GetModel("NXEDETAIL"):SetNoUpdateLine()
oModel:GetModel("NXEDETAIL"):SetNoDeleteLine()
oModel:SetRelation("NXEDETAIL", { { "NXE_FILIAL", "xFilial('NXE')" }, { "NXE_CFATUR", "NXA_COD" }, { "NXE_CESCR", "NXA_CESCR" } }, NXE->( IndexKey( 1 ) ))   //RESUMO DAS DESPESAS

oModel:GetModel("NXFDETAIL"):SetNoInsertLine()
oModel:GetModel("NXFDETAIL"):SetNoUpdateLine()
oModel:GetModel("NXFDETAIL"):SetNoDeleteLine()
oModel:SetRelation("NXFDETAIL", { { "NXF_FILIAL", "xFilial('NXF')" }, { "NXF_CFATUR", "NXA_COD" }, { "NXF_CESCR", "NXA_CESCR" } }, NXF->( IndexKey( 2 ) )) //CAMBIOS DA FATURA

If lEncaminha
	oModel:SetRelation("NVNDETAIL", { { "NVN_FILIAL", "xFilial('NVN')" }, { "NVN_CESCR", "NXA_CESCR" }, { "NVN_CFATUR", "NXA_COD" } }, NVN->( IndexKey(3) )) //Encaminhamentos da Fatura
EndIf

oModel:GetModel("NXMDETAIL"):SetNoInsertLine(.T.)
oModel:SetRelation("NXMDETAIL", { { "NXM_FILIAL", "xFilial('NXM')" }, { "NXM_CESCR", "NXA_CESCR" }, { "NXM_CFATUR", "NXA_COD" } }, NXM->( IndexKey( 1 ) )) //DOCUMENTOS DA FATURA

//Vencimentos
oModel:GetModel("NT1DETAIL"):SetNoInsertLine()
oModel:GetModel("NT1DETAIL"):SetNoUpdateLine()
oModel:GetModel("NT1DETAIL"):SetNoDeleteLine()
oModel:GetModel("NT1DETAIL"):SetOnlyQuery ( .T. )
oModel:SetRelation("NT1DETAIL", { { "NT1_FILIAL", "xFilial( 'NT1' ) " }, {"NT1_CCONTR" ,"NXB_CCONTR"} }, cIndexNXC ) //CASOS DA FATURA

oModel:GetModel("NUEDETAIL"):SetNoInsertLine()
oModel:GetModel("NUEDETAIL"):SetNoUpdateLine()
oModel:GetModel("NUEDETAIL"):SetNoDeleteLine()
oModel:GetModel("NUEDETAIL"):SetOnlyQuery ( .T. )
oModel:SetRelation("NUEDETAIL", { { "NUE_FILIAL", "xFilial('NUE')"}, { "NUE_CCLIEN", "NXC_CCLIEN" }, { "NUE_CLOJA" , "NXC_CLOJA" }, { "NUE_CCASO" , "NXC_CCASO"  } }, NUE->( IndexKey( 1 ) ))

oModel:GetModel("NVYDETAIL"):SetNoInsertLine()
oModel:GetModel("NVYDETAIL"):SetNoUpdateLine()
oModel:GetModel("NVYDETAIL"):SetNoDeleteLine()
oModel:GetModel("NVYDETAIL"):SetOnlyQuery ( .T. )
oModel:SetRelation("NVYDETAIL", { { "NVY_FILIAL", "xFilial('NVY')"}, { "NVY_CCLIEN", "NXC_CCLIEN" }, { "NVY_CLOJA" , "NXC_CLOJA" }, { "NVY_CCASO" , "NXC_CCASO"  } }, NVY->( IndexKey( 1 ) ))

oModel:GetModel("NV4DETAIL"):SetNoInsertLine()
oModel:GetModel("NV4DETAIL"):SetNoUpdateLine()
oModel:GetModel("NV4DETAIL"):SetNoDeleteLine()
oModel:GetModel("NV4DETAIL"):SetOnlyQuery ( .T. )
oModel:SetRelation("NV4DETAIL", { { "NV4_FILIAL", "xFilial('NV4')"}, { "NV4_CCLIEN", "NXC_CCLIEN" }, { "NV4_CLOJA" , "NXC_CLOJA" }, { "NV4_CCASO" , "NXC_CCASO"  } }, NVY->( IndexKey( 1 ) ))

oModel:GetModel("NVVDETAIL"):SetNoInsertLine()
oModel:GetModel("NVVDETAIL"):SetNoUpdateLine()
oModel:GetModel("NVVDETAIL"):SetNoDeleteLine()
oModel:GetModel("NVVDETAIL"):SetOnlyQuery ( .T. )

oModel:SetDescription( STR0008 ) // "Modelo de Dados de Operação em Fatura"
oModel:GetModel( "NXAMASTER" ):SetDescription( STR0009 ) // "Dados de Operação em Fatura"
oModel:GetModel( "NXBDETAIL" ):SetDescription( STR0011 ) // "Descrição de Contratos da Fatura"
oModel:GetModel( "NXCDETAIL" ):SetDescription( STR0013 ) // "Descrição de Casos da Fatura"
oModel:GetModel( "NXDDETAIL" ):SetDescription( STR0015 ) // "Descrição de Participantes da fatura"
oModel:GetModel( "NXEDETAIL" ):SetDescription( STR0022 ) // "Resumo de Despesas da Fatura"
oModel:GetModel( "NXFDETAIL" ):SetDescription( STR0023 ) // "Cambios Utilizados na Fatura"
If lEncaminha
	oModel:GetModel( "NVNDETAIL" ):SetDescription( STR0218 ) // "Encaminhamento de fatura"
EndIf
oModel:GetModel( "NXMDETAIL" ):SetDescription( STR0019 ) // "Docs Relacionados"

JurSetRules( oModel, "NXAMASTER",, "NXA" )
JurSetRules( oModel, "NXBDETAIL",, "NXB" )
JurSetRules( oModel, "NXCDETAIL",, "NXC" )
JurSetRules( oModel, "NXDDETAIL",, "NXD" )
JurSetRules( oModel, "NXEDETAIL",, "NXE" )
JurSetRules( oModel, "NXFDETAIL",, "NXF" )
If lEncaminha
	JurSetRules( oModel, "NVNDETAIL",, "NVN" )
EndIf
JurSetRules( oModel, "NXMDETAIL",, "NXM" )

oModel:SetOptional("NXDDETAIL", .T. )
oModel:SetOptional("NXEDETAIL", .T. )
oModel:SetOptional("NXFDETAIL", .T. )
oModel:SetOptional("NXMDETAIL", .T. )
If lEncaminha
	oModel:SetOptional("NVNDETAIL", .T. )
EndIf

//Lançamentos
oModel:SetOptional("NT1DETAIL", .T. )
oModel:SetOptional("NUEDETAIL", .T. )
oModel:SetOptional("NVYDETAIL", .T. )
oModel:SetOptional("NV4DETAIL", .T. )
oModel:SetOptional("NVVDETAIL", .T. )

oModel:SetOnDemand()

oModel:InstallEvent("JA204COMMIT", /*cOwner*/, oCommit)

lStatus := oStructNXA:HasField( "NXA_STATUS" ) // Proteção
oModel:SetVldActivate( {|oModel| J204Activ(oModel, lStatus)} )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA204TUDOK
Tudo OK do Model

@author Cristina Cintra
@since 06/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA204TUDOK(oModel)
Local lRet       := .T.
Local cQuery     := ""
Local aArea      := GetArea()
Local aAreaSE1   := SE1->(GetArea())
Local aAreaNXA   := NXA->(GetArea())
Local cAliasSE1  := GetNextAlias()
Local cFil       := JurGetDados("NS7", 1, xFilial("NS7") + NXA->NXA_CESCR, "NS7_CFILIA")
Local nQtde      := 0
Local lParcUni   := SuperGetMv( "MV_JPACUNI", .F., .T. ) //Identif.se a o tit.unico tera o campo parcela preenchido
Local cMV_1DUP   := GetMv("MV_1DUP")
Local cParcela   := Space( TamSx3( "E1_PARCELA" )[ 1 ] )
Local lAberto    := .F.
Local aSE1RECNO  := {}
Local cAltRaz    := SuperGetMv( "MV_JALTRAZ", , '0' ) //Altera Razão Social da Fatura? 0 - Não altera; 1 - Altera se não foi emitida Nota Fiscal; 2 - Altera independente da emissão da Nota Fiscal.
Local cRazSocAnt := NXA->NXA_RAZSOC
Local cRazSocNov := oModel:GetValue('NXAMASTER', 'NXA_RAZSOC')
Local cMsgConf   := ""
Local cCliPg     := ""
Local cLojPg     := ""

// Retorna os titulos da fatura
cQuery := JA204Query( 'TI', xFilial( 'NXA' ), NXA->NXA_COD, NXA->NXA_CESCR, cFil )
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasSE1, .T., .T. )
SE1->( Dbsetorder( 1 ) )
(cAliasSE1)->( Dbgotop() )
Do While ! (cAliasSE1)->( Eof() )
	nQtde   := nQtde + 1
	lAberto := (cAliasSE1)->E1_VALOR == (cAliasSE1)->E1_SALDO
	Aadd(aSE1RECNO, (cAliasSE1)->SE1RECNO)

	(cAliasSE1)->( dbSkip() )
EndDo
(cAliasSE1)->( dbcloseArea() )

If nQtde == 1 .And. lAberto
	If lParcUni
		cParcela := cMV_1DUP
	EndIf
	SE1->(dbSetOrder(1))
	SE1->(DbGoto(aSE1RECNO[1]))
	J204AlVenc(aSE1RECNO[1], oModel:GetValue('NXAMASTER', 'NXA_DTVENC'), cFil)
EndIf

If oModel:GetValue('NXAMASTER', 'NXA_DTVENC') <> NXA->NXA_DTVENC
	oModel:SetValue('NXAMASTER', 'NXA_USRALT', JurUsuario(__CUSERID))
	oModel:SetValue('NXAMASTER', 'NXA_DTALVE', Date())
EndIf

If oModel:GetValue('NXAMASTER', 'NXA_FPAGTO') <> NXA->NXA_FPAGTO .Or. (oModel:GetValue('NXAMASTER', 'NXA_CBANCO') <> NXA->NXA_CBANCO);
	.Or. (oModel:GetValue('NXAMASTER', 'NXA_CAGENC') <> NXA->NXA_CAGENC) .Or. (oModel:GetValue('NXAMASTER', 'NXA_CCONTA') <> NXA->NXA_CCONTA)
	J204AlFPgt(aSE1RECNO, oModel:GetValue('NXAMASTER', 'NXA_FPAGTO'), cFil) //Função para ajuste da Forma de Pagamento nos títulos
	oModel:SetValue('NXAMASTER', 'NXA_USRALT', JurUsuario(__CUSERID))
	oModel:SetValue('NXAMASTER', 'NXA_DTALVE', Date())
EndIf

If J204ExistB(NXA->NXA_CESCR, NXA->NXA_COD) .And. ;
   ( oModel:GetValue('NXAMASTER', 'NXA_CBANCO') <> NXA->NXA_CBANCO .Or. ;
     oModel:GetValue('NXAMASTER', 'NXA_CAGENC') <> NXA->NXA_CAGENC .Or. ;
     oModel:GetValue('NXAMASTER', 'NXA_CCONTA') <> NXA->NXA_CCONTA )
	If !IsBlind()
		If !ApMsgYesNo(STR0227) // "Existe boleto para esta fatura! Deseja realmente alterar as informações bancárias?"
			oModel:LoadValue('NXAMASTER', 'NXA_CBANCO', NXA->NXA_CBANCO)
			oModel:LoadValue('NXAMASTER', 'NXA_CAGENC', NXA->NXA_CAGENC)
			oModel:LoadValue('NXAMASTER', 'NXA_CCONTA', NXA->NXA_CCONTA)
		EndIf
	Else
		lRet := .F.
	EndIf
EndIf

If lRet .And. cRazSocAnt != cRazSocNov

	If (cAltRaz == "1" .AND. oModel:GetValue('NXAMASTER','NXA_NFGER') != "1") .Or. cAltRaz == "2"
		cCliPg   := oModel:GetValue('NXAMASTER', 'NXA_CLIPG')
		cLojPg   := oModel:GetValue('NXAMASTER', 'NXA_LOJPG')

		cMsgConf := I18N(STR0200, {RetTitle("NXA_RAZSOC"), cRazSocAnt, cRazSocNov}) //"O campo '#1' foi alterado de '#2' para '#3'!"
		cMsgConf += CRLF+I18N(STR0201, {cRazSocNov, RetTitle("A1_NOME"), cCliPg, cLojPg}) //"Será inserido o valor '#1' no campo '#2', do cadastro do cliente '#3'/'#4'."
		cMsgConf += CRLF+STR0202 //"Deseja continuar?"

		// O IsBlind está sendo usado para tratar quando não houver interface com usuário, para que não exiba pergunta e considere que a resposta é SIM
		lRet := IsBlind() .Or. ApMsgYesNo(cMsgConf, STR0178) // "Atenção"

		If !lRet
			JurMsgErro(STR0203, 'JA204TUDOK',; //"Operação finalizada pelo usuário"
			I18N(STR0204, {RetTitle("NXA_RAZSOC")}); //"Para não ocorrer novamente essa pergunta, insira o valor original do campo '#1'."
			+ CRLF +I18N(STR0205, {cRazSocAnt})) //"Valor Original: '#1'"
		EndIf

	Else //Alteração de forma não prevista
		JurMsgErro(I18N(STR0206 + CRLF, {RetTitle("NXA_RAZSOC")}); //"O campo '#1' foi alterado de forma indevida!"
						+I18N(STR0207 + CRLF, {cRazSocAnt}); //"Valor Anterior: '#1'"
						+I18N(STR0208 + CRLF, {cRazSocNov}),; //"Valor Atual:    '#2'"
						"JA204TUDOK",;
						STR0209 + CRLF; //"Verifique:"
						+STR0210 + CRLF; //"1) O parâmetro 'MV_JALTRAZ'."
						+I18N(STR0211+ CRLF, {RetTitle("NXA_RAZSOC"), RetTitle("NXA_NFGER")}) ) //"2) Os campos: '#1' e '#2'"
		lRet := .F.
	EndIf

EndIf

RestArea(aAreaSE1)
RestArea(aAreaNXA)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA204DESCS
Retorna a descrição dos campos virtuais das tabelas relacionadas a fatura

@param 		cCampo		Campo virtual que ser exibido a descrição
@Return 	cRet	 		Descrição a ser exibida no campo
@Sample 	JA204DESCS("NXD_DCASO ")

@author Jacques Alves Xavier
@since 03/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA204DESCS(cCampo)
Local cRet    := ""
Local cIdioma := ""

Do Case
Case cCampo == 'NXB_DCLIEN'
	cRet := JurGetDados("SA1", 1, xFilial("SA1") + NXB->NXB_CCLIEN + NXB->NXB_CLOJA, "A1_NOME")
Case cCampo == 'NXC_DCLIEN'
	cRet := JurGetDados("SA1", 1, xFilial("SA1") + NXC->NXC_CCLIEN + NXC->NXC_CLOJA, "A1_NOME")
Case cCampo == 'NXD_DCLIEN'
	cRet := JurGetDados("SA1", 1, xFilial("SA1") + NXD->NXD_CCLIEN + NXD->NXD_CLOJA, "A1_NOME")
Case cCampo == 'NXE_DCLIEN'
	cRet := JurGetDados("SA1", 1, xFilial("SA1") + NXE->NXE_CCLIEN + NXE->NXE_CLOJA, "A1_NOME")
Case cCampo == 'NXC_DCASO'
	cRet := JurGetDados("NVE", 1, xFilial("NVE") + NXC->NXC_CCLIEN + NXC->NXC_CLOJA + NXC->NXC_CCASO, "NVE_TITULO")
Case cCampo == 'NXD_DCASO'
	cRet := JurGetDados("NVE", 1, xFilial("NVE") + NXD->NXD_CCLIEN + NXD->NXD_CLOJA + NXD->NXD_CCASO, "NVE_TITULO")
Case cCampo == 'NXE_DCASO'
	cRet := JurGetDados("NVE", 1, xFilial("NVE") + NXE->NXE_CCLIEN + NXE->NXE_CLOJA + NXE->NXE_CCASO, "NVE_TITULO")
Case cCampo == 'NXD_DCATEG'
	cIdioma := JurGetDados("NT0", 1, xFilial("NT0") + NXD->NXD_CCONTR, "NT0_CIDIO" )
	cRet    := JurGetDados("NR2", 3, xFilial("NR2") + NXD->NXD_CCATEG + cIdioma, "NR2_DESC" )
EndCase

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA204VLDCPO
Validação dos campos

@param 		cCampo		Campo virtual que ser exibido a descrição
@Return 	lRet	 		.T./.F. - true or false
@Sample 	JA204VLDCPO("NXA_CMOTCA")

@author Jacques Alves Xavier
@since 05/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA204VLDCPO(cCampo)
Local lRet   := .T.
Local oModel := FwModelActive()

If oModel:GetOperation() == 4

	Do Case
		Case cCampo == 'NXA_CMOTCA'
			lRet := ExistCpo('NSA',oModel:GetValue("NXAMASTER", 'NXA_CMOTCA'))
			If lRet
				oModel:LoadValue('NXAMASTER', 'NXA_DMOTCA', JurGetDados('NSA', 1, xFilial('NSA') + oModel:GetValue("NXAMASTER", 'NXA_CMOTCA'), "NSA_DESC")  )
			EndIf
		Case cCampo == 'NXA_CCONT'
			lRet := ExistCpo('SU5',oModel:GetValue("NXAMASTER", 'NXA_CCONT'))
			If lRet
				oModel:LoadValue('NXAMASTER', 'NXA_DCONT', JurGetDados('SU5', 1, xFilial('SU5') + oModel:GetValue("NXAMASTER", 'NXA_CCONT'), "U5_CONTAT")  )
			EndIf
	EndCase

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA204VLDCPO
Replica a redação para os casos da Fatura

@param 		oModel    Model ativo

@author Jacques Alves Xavier
@since 05/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA204CpRed(oModel)
Local cQuery   := ""
Local aArea    := GetArea()
Local aAreaNVE := NVE->(GetArea())
Local cResQry  := GetNextAlias()

If ApMsgYesNo(STR0024) // Deseja atualizar a redação nos casos?

	cQuery := "SELECT NXC.NXC_CCLIEN, NXC.NXC_CLOJA, NXC.NXC_CCASO, NXC.R_E_C_N_O_ NXCRECNO, NXC.NXC_CFATUR, NXC.NXC_CESCR "
	cQuery += " FROM " + RetSqlName("NXC") +" NXC "
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery +=   " AND NXC.NXC_FILIAL = '" + xFilial('NXC') + "' "
	cQuery +=   " AND NXC.NXC_CFATUR = '" + FWFldGet('NXA_COD') + "' "
	cQuery +=   " AND NXC.NXC_CESCR = '" + FWFldGet('NXA_CESCR') + "'"

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cResQry,.T.,.T.)

	While !(cResQry)->( EOF() )

		NXC->(dbGoTo((cResQry)->NXCRECNO))

		NVE->(dbSetOrder(1))
		If NVE->(dbSeek(xFilial('NVE') + (cResQry)->NXC_CCLIEN + (cResQry)->NXC_CLOJA + (cResQry)->NXC_CCASO))

			RecLock("NVE",.F.)
			NVE->NVE_REDFAT := NXC->NXC_REDAC
			NVE->(MsUnlock())

			//Grava na fila de sincronização a alteração
			J170GRAVA("NVE", xFilial("NVE") + NVE->NVE_CCLIEN + NVE->NVE_LCLIEN + NVE->NVE_NUMCAS, "4")

		EndIf

		(cResQry)->( dbSkip() )
	Enddo

	(cResQry)->( dbcloseArea() )
	RestArea(aAreaNVE)
	RestArea(aArea)

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JA204ValMN
Função para mostrar os valores da Fatura na moeda nacional (MV_JMOENAC)

@Param    cCampo     Campo a ser validado
@Param    nValor     Valor de origem para calcular o valor convertido

@author Jacques Alves Xavier
@since 08/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA204ValMN(cCampo, nValor)
Local nRet      := 0
Local nHon      := Round( NXA->NXA_VLFATH, TamSx3("E1_VALOR")[2])  //Chamado 6872 diferença de arredondamento do valor liquido
Local nDesp     := Round( NXA->NXA_VLFATD, TamSx3("E1_VALOR")[2])  //
Local nDesc     := Round( NXA->NXA_VLDESC, TamSx3("E1_VALOR")[2])  //
Local nAcre     := Round( NXA->NXA_VLACRE, TamSx3("E1_VALOR")[2])  //
Local nIRRF     := NXA->NXA_IRRF
Local nPIS      := NXA->NXA_PIS
Local nCOFINS   := NXA->NXA_COFINS
Local nCSLL     := NXA->NXA_CSLL
Local nINSS     := NXA->NXA_INSS
Local nISS      := IIF(JurGetDados("SA1", 1, xFilial("SA1") + NXA->NXA_CLIPG + NXA->NXA_LOJPG, "A1_RECISS") == "1" .And. GetNewPar("MV_DESCISS",.F.), NXA->NXA_ISS, 0) 
Local cMoedNac  := SuperGetMV( 'MV_JMOENAC',, '01' )
Local nValGrosH := IIF(NXA->(ColumnPos("NXA_VGROSH")) > 0, NXA->NXA_VGROSH, 0) // @12.1.2310
Local nValores  := nValGrosH - nDesc + nDesp + nAcre - nIRRF - nPIS - nCOFINS - nCSLL - nINSS - nISS
Local nLiq      := nHon + nValores

Do Case
	Case cCampo == 'NXA_VALLIQ'
		nRet := nLiq
	Case cCampo == 'NXA_VLIQMN'
		If cMoedNac != NXA->NXA_CMOEDA
			IIf (nValores == 0, nRet := NXA->NXA_FATHMN, nRet := NXA->NXA_FATHMN + Round(nValores * Round((NXA->NXA_FATHMN / NXA->NXA_VLFATH), TamSx3("NX6_COTAC1")[2]), TamSx3("E1_VALOR")[2]))
		Else
			nRet := nLiq
		EndIf
EndCase

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204EMail
Rotina utilizada para envio de e-mail

@author Felipe Bonvicini Conti
@since 05/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function J204EMail()
Local oDlg         := Nil
Local oLayer       := Nil
Local oMainColl    := Nil
Local oPnlT        := Nil
Local oPnlD        := Nil
Local bAtuConfig   := Nil
Local cServer      := ''
Local cUser        := ''
Local cPass        := ''
Local lAuth        := ''
Local aArea        := GetArea()
Local aAreaNXA     := NXA->(GetArea())
Local aRelats      := {.F., .F.}

Local aButtons     := {}
Local aSize        := {}
Local nTamDialog   := 0
Local nLargura     := 540
Local nAltura      := 350
Local nSizeTela    := 0

Local aMailEnv     := {STR0221, STR0222, STR0223} // "Não","Sim","Todos"
Local oCmbMailEnv  := Nil
Local cCmbMailEnv  := ""
Local aCposLGPD    := {}
Local aNoAccLGPD   := {}
Local aDisabLGPD   := {}
Local lCIdioma     := NXA->(ColumnPos("NXA_CIDIO")) > 0 .And. NRU->(ColumnPos("NRU_CIDIO")) > 0
Local cLojaAuto    := SuperGetMv( "MV_JLOJAUT", .F., "2", )
Local lCpoEmlAgr   := NXA->(ColumnPos("NXA_EMLAGR")) > 0 // @12.1.2310

Private cEmlFilter := ""
Private oTGetCodSe := Nil
Private oTGetDescS := Nil
Private oTGetCodUs := Nil
Private oTGetDesUs := Nil
Private oTGetConf  := Nil
Private oTGetConfD := Nil
Private oMarkMail  := Nil

If ApMsgYesNo(STR0133 + CRLF + CRLF + STR0134 ) // "Deseja verificar se existem faturas cujos documentos ainda não foram relacionados?" ### "Obs.: Esta verificação pode demorar alguns minutos dependendo do tamanho da base e de quantas faturas ainda não possuem esta associação."
	//Busca os documentos das faturas geradas
	Processa( { || J204AllDocs() }, STR0135, STR0136, .F. ) //"Buscando documentos"###"Processando..."
EndIf

// Retorna o tamanho da tela
aSize     := MsAdvSize(.F.)
nSizeTela := ((aSize[6]/2)*0.85) // Diminui 15% da altura.

If nAltura > 0 .And. nSizeTela < nAltura
	nTamDialog := nSizeTela
Else
	nTamDialog := nAltura
EndIf

If _lFwPDCanUse .And. FwPDCanUse(.T.)
	aCposLGPD := {"NR7_DESC", "NR8_DESC", "NRU_DESC"}

	aDisabLGPD := FwProtectedDataUtil():UsrNoAccessFieldsInList(aCposLGPD)
	AEval(aDisabLGPD, {|x| AAdd( aNoAccLGPD, x:CFIELD)})
EndIf
aAdd(aButtons, {, STR0128, {|| J204EmlFil() },,, .T., .T.} ) // "Filtrar"

oDlg := FWDialogModal():New()
oDlg:SetFreeArea(nLargura, nTamDialog)
oDlg:SetEscClose(.T.)    // Permite fechar a tela com o ESC
oDlg:SetCloseButton(.T.) // Permite fechar a tela com o "X"
oDlg:SetBackground(.T.)  // Escurece o fundo da janela
oDlg:SetTitle(STR0036)   // "Enviar por E-Mail"
oDlg:CreateDialog()
oDlg:addButtons(aButtons)
oDlg:addOkButton({|| Processa({|| If(J204VldSrv("BOTAO_ENVIAR", @cServer, @cUser, @cPass, @lAuth), J204Send(cServer, cUser, cPass, oTGetConf:Valor, aRelats, lAuth, cCmbMailEnv), ) }, STR0037, STR0038, .F.)})
oDlg:addCloseButton({|| oDlg:oOwner:End() }) //"Cancelar" // "O preenchimento dos detalhes do título é obrigatório. Por favor, verifique!"

@ 000,000 MSPANEL oPanel OF oDlg:GetPanelMain() SIZE nLargura, nTamDialog

oLayer := FwLayer():New()
oLayer:Init(oPanel, .F.)
oLayer:addCollumn("MainColl",100,.F.) //Cria as colunas do Layer
oMainColl := oLayer:GetColPanel( 'MainColl' )

oPnlT := tPanel():New(0,0,"",oMainColl,,,,,,0,0)
oPnlD := tPanel():New(0,0,"",oMainColl,,,,,,0,0)

oPnlT:nHeight  := 125
oPnlT:nWidth   := 300
oPnlT:Align    := CONTROL_ALIGN_TOP
oPnlD:Align    := CONTROL_ALIGN_ALLCLIENT

oPnlD:nCLRPANE := RGB(255,255,255)

oTGetCodSe := TJurPnlCampo():New(05, 05, 050, 22, oPnlT, STR0174, "NR7_COD" , {|| }, {|| },,,, "NR7") // "Config. Serv" ### "Codigo de Configuração do Servidor"
oTGetDescS := TJurPnlCampo():New(05, 70, 100, 22, oPnlT, STR0175, "NR7_DESC", {|| }, {|| },,,,,,,,, aScan(aNoAccLGPD, "NR7_DESC") > 0)       // "Desc. Serv"   ### "Descrição da Configuração do Servidor"

oTGetCodUs := TJurPnlCampo():New(05, 186, 050, 22, oPnlT, STR0176, "NR8_COD" , {|| }, {|| },,,, "NR8") // "Cód. Usuário" ### "Codigo do Usuário de Configuração do Servidor"
oTGetDesUs := TJurPnlCampo():New(05, 251, 100, 22, oPnlT, STR0177, "NR8_DESC", {|| }, {|| },,,,,,,,, aScan(aNoAccLGPD, "NR8_DESC") > 0)       // "Nome Usuário" ### "Nome do Usuário de Configuração do Servidor"

oTGetConf  := TJurPnlCampo():New(35, 05, 050, 22, oPnlT, STR0044, "NRU_COD" , {|| } ,{|| },,,, "NRU") // "Config. E-Mail"
oTGetConfD := TJurPnlCampo():New(35, 70, 100, 22, oPnlT, STR0045, "NRU_DESC",,,,,.T.,,,,,, aScan(aNoAccLGPD, "NRU_DESC") > 0)                // "Desc. Config. E-Mail"

oTGetDescS:SetWhen({|| .F.})
oTGetDesUs:SetWhen({|| .F.})
oTGetConfD:SetWhen({|| .F.})
oTGetCodUs:SetWhen({|| !Empty(oTGetCodSe:GetValue()) })

bAtuConfig := {|| oTGetConfD:Valor := J204NRUGET('NRU_DESC', oTGetConf:Valor), ;
					IIf(oTGetConf:IsModified(), J204NXAFilt( J204NXAAFl(oTGetConf:Valor, lCIdioma) , cCmbMailEnv),), .T. }

oTGetCodSe:oCampo:bValid := {|| J204VldSrv("NR7_COD")}
oTGetCodUs:oCampo:bValid := {|| J204VldSrv("NR8_COD")}
oTGetConf:oCampo:bValid  := {|| IIf(J204VldSrv("NRU_COD"), Eval(bAtuConfig), .F.)}

@ 35, 186 Say STR0224 Size 145, 243 Pixel Of oPnlT // "E-Mail enviado?"
oCmbMailEnv := TComboBox():New(44, 186, {|cValor| IIf(PCount() > 0, cCmbMailEnv := cValor, cCmbMailEnv)},;
                              aMailEnv, 060, 014, oPnlT,, {|| /*Ação*/},,,, .T.,,,,,,,,, 'cCmbMailEnv')

oCmbMailEnv:bChange := { || J204NXAFilt( J204NXAAFl(oTGetConf:Valor, lCIdioma) , cCmbMailEnv)}

oMarkMail := FWMarkBrowse():New()
oMarkMail:SetDescription(STR0243) // Faturas
oMarkMail:SetProfileID("MAIL")
oMarkMail:SetOwner(oPnlD)
oMarkMail:SetAlias("NXA")
IIF(cLojaAuto == "1" .And. FindFunction("JurBrwRev"), JurBrwRev(oMarkMail, "NXA", {"NXA_CLOJA "}),) //Proteção
oMarkMail:SetMenuDef("")
oMarkMail:SetFieldMark("NXA_OK")
oMarkMail:SetFilterDefault(J204NXAFilt(, cCmbMailEnv, .F.))
If lCpoEmlAgr .And. GetSx3Cache("NXA_EMLAGR", "X3_BROWSE") == "S"
	oMarkMail:SetFields(J204EmlAgr())
EndIf
oMarkMail:DisableDetails()
oMarkMail:DisableFilter()
oMarkMail:DisableSeek()
oMarkMail:DisableLocate()
oMarkMail:Activate()
oDlg:Activate()

RestArea(aAreaNXA)
RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J204NXAFilt
Define o filtro padrao da tela de envio de email

@param aCond      , Array com o campo usado na condição do Filtro e
                    respectivo valor para condição do Filtro
@param cCmbMailEnv, Valor do combo que filtra as faturas conforme o 
                    status de envio de e-mail

@param lRefresh   , Se verdadeiro executa a atualização do MarkBrowse

@author Felipe Bonvicini Conti
@since 05/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204NXAFilt(aCond, cCmbMailEnv, lRefresh)
	Local cFiltro       := ""
	Local cFilBase      := ""
	Local lEnc          := NVN->(ColumnPos("NVN_CESCR")) > 0 //Proteção
	Local nI            := 0
	Local cCond         := ""

	Default aCond       := {}
	Default cCmbMailEnv := STR0221 // "Não"
	Default	lRefresh    := .T.

	cFilBase := "( ( NXA_EMAIL > '"+ Space(TamSx3('NXA_EMAIL')[1]) + "' "
	cFilBase +=     " OR EXISTS ( SELECT NVN.NVN_FILIAL FROM " + RetSqlName("NVN") + " NVN, " + RetSqlName("SU5") + " SU5 "
	cFilBase +=                  " WHERE NVN.NVN_FILIAL = '" + xFilial("NVN") + "' "
	If lEnc // Utiliza o encaminhamento da fatura
		cFilBase +=                    " AND NVN.NVN_CESCR  = NXA_CESCR"
		cFilBase +=                    " AND NVN.NVN_CFATUR = NXA_COD"
	Else // Utiliza o encaminhamento do contrato
		cFilBase +=                    " AND ( ( NXA_CPREFT > '" + Space(TamSx3('NXA_CPREFT')[1]) + "' AND NVN.NVN_CPREFT = NXA_CPREFT ) "
		cFilBase +=                       " OR ( NVN.NVN_CJCONT = NXA_CJCONT AND NVN.NVN_CCONTR = NXA_CCONTR ) "
		cFilBase +=                       " OR ( NXA_CFTADC > '" + Space(TamSx3('NXA_CFTADC')[1]) + "' AND NVN.NVN_CFATAD = NXA_CFTADC ) "
		cFilBase +=                        " ) "
		cFilBase +=                  " AND NVN.NVN_CLIPG  = NXA_CLIPG "
		cFilBase +=                  " AND NVN.NVN_LOJPG  = NXA_LOJPG "
	EndIf
	cFilBase +=                    " AND SU5.U5_FILIAL = '" + xFilial("SU5") + "' "
	cFilBase +=                    " AND SU5.U5_CODCONT = NVN.NVN_CCONT"
	cFilBase +=                    " AND SU5.U5_EMAIL > '" + Space(TamSx3('U5_EMAIL')[1]) + "' "
	cFilBase +=                    " AND SU5.D_E_L_E_T_ = ' ' "
	cFilBase +=                    " AND NVN.D_E_L_E_T_ = ' ' ) ) "
	cFilBase +=   " AND EXISTS ( SELECT NXM_FILIAL FROM " + RetSqlName("NXM") + " NXM "
	cFilBase +=                 " WHERE NXM.NXM_FILIAL = '" + xFilial("NXM") + "' "
	cFilBase +=                   " AND NXM.NXM_CESCR  = NXA_CESCR "
	cFilBase +=                   " AND NXM.NXM_CFATUR = NXA_COD "
	cFilBase +=                   " AND NXM.NXM_EMAIL  = '1' "
	cFilBase +=                   " AND NXM.D_E_L_E_T_ = ' ' ) "

	cFilBase += " AND NXA_FILIAL = '" + xFilial("NXA") + "' "
	If cCmbMailEnv == STR0222 // "Sim"
		cFilBase += " AND NXA_MAILEN = '1' "
	ElseIf cCmbMailEnv == STR0221 // "Não"
		cFilBase += " AND NXA_MAILEN = '2' "
	EndIf
	cFilBase +=   " AND D_E_L_E_T_ = ' ' "
	cFilBase +=   " AND NXA_SITUAC = '1' AND NXA_MAILEN <> '3' ) " //Retira da fila a faturas que não podem ser enviadas, coforme configuração do cliente

	If Len(aCond) > 0
		For nI := 1 To Len(aCond)
			cCond += " AND " + aCond[nI][1] + "'" + aCond[nI][2] + "' "
		Next nI
	EndIf 

	cFiltro := "@" + cFilBase + cCond

	If lRefresh
		oMarkMail:SetFilterDefault(cFiltro)
		oMarkMail:Refresh()
	EndIf

	cEmlFilter := cFiltro
	
Return (cFiltro)

//-------------------------------------------------------------------
/*/{Protheus.doc} J204EmlFil
Altera o filtro padrao da tela de envio de email

@author Daniel Magalhaes
@since 08/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204EmlFil()
Local cFiltroRet := ""
Local cCondicao  := cEmlFilter

NXA->(DbClearFilter())

cFiltroRet := BuildExpr("NXA",, cFiltroRet, .T.)

If !Empty(cFiltroRet)
	cFiltroRet := IIf(!Empty(cCondicao), cCondicao + " and (" + cFiltroRet + ")", "@" + cFiltroRet)
Else
	cFiltroRet := cCondicao
EndIf

oMarkMail:SetFilterDefault(cFiltroRet)
oMarkMail:Refresh()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J204NRUGET
Rotina utilizada para buscar a descrição da configuração

@author Felipe Bonvicini Conti
@since 05/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204NRUGET(cCampo, cConfig)
Local cRet := JurGetDados("NRU", 1, xFilial("NRU") + cConfig, cCampo)
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204Send
Rotina utilizada para enviar e-mail

@author Felipe Bonvicini Conti
@since 08/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204Send(cServer, cUser, cPass, cConfig, aRelats, lAuth, cCmbMailEnv)
Local lOk        := .T.
Local nI         := 0
Local aConfig    := {}
Local aObjEmail  := {}
Local cEnviados  := ""
Local cPara      := ""
Local cAssunto   := ""
Local cEscri     := ""
Local cFatur     := ""
Local nEmail     := 0
Local cCliente   := ""
Local cLoja      := ""
Local lMailCC    := .F.
Local lMailCCO   := .F.
Local lCIdioma   := NXA->(ColumnPos("NXA_CIDIO")) > 0 .AND.  NRU->(ColumnPos("NRU_CIDIO")) > 0
Local cMailCC    := ""
Local cMailCCO   := ""
Local cMailCli   := ""
Local cMailCfgCC := ""
Local cCorpo     := ""
Local cAnexos    := ""
Local aLog       := {}

If !Empty(cServer) .And. !Empty(cUser) .And. !Empty(cConfig)

	aConfig   := J204GetConf(cConfig)
	aObjEmail := J204GetEmails(oMarkMail:Mark(), aConfig[4], aRelats, cConfig)
	nEmail    := Len(aObjEmail)
	lMailCC   := !Empty(Alltrim(aConfig[2]))
	lMailCCO  := !Empty(Alltrim(aConfig[3]))
	ProcRegua(nEmail)

	If nEmail > 0
		// Formata e-mail CC (NRU_CC)
		If lMailCC
			cMailCfgCC := J204FMail(aConfig[2])
		EndIf

		// Formata e-mail CCO (NRU_CCO)
		If lMailCCO
			cMailCCO := J204FMail(aConfig[3])
		EndIf

		For nI := 1 To nEmail
			IncProc(nI)
			cCliente := aObjEmail[nI][01]:cCliente
			cLoja    := aObjEmail[nI][01]:cLoja
			cPara    := aObjEmail[nI][01]:GetEMail()
			cAssunto := aConfig[1]
			cEscri   := aObjEmail[nI][01]:cCodEsc
			cFatur   := aObjEmail[nI][01]:cCodFat

			cMailCli := aObjEmail[nI][02]

			If !Empty(cMailCli)
				cMailCC  := J204FMail(cMailCli, cMailCfgCC) // Formata e-mail cliente (NUH_CMAIL)
			Else
				cMailCC  := cMailCfgCC
			EndIf

			If aObjEmail[nI][01]:lEnviar
				cCorpo  := aObjEmail[nI][01]:GetBody()
				cAnexos := J204EmlLDoc(aObjEmail[nI][01]:aCods)

				lOk := JurEnvMail(SubString(cUser, 1, At("@", cUser) - 1), ; // De
				cPara,                     ; // Para
				cMailCC,                   ; // CC
				cMailCCO,                  ; // CCO
				cAssunto,                  ; // Assunto
				cAnexos,                   ; // Anexo
				cCorpo,                    ; // Corpo
				Trim(cServer),             ; // Servior
				Trim(cUser),               ; // Usuário
				Trim(cPass),               ; // Senha
				lAuth,                     ; // Autenticação
				Trim(cUser),               ; // Usuário Auth
				Trim(cPass))                 // Senha Auth
			ElseIf !aObjEmail[nI][01]:lEnviar
				MsgStop(STR0109) //"O envio deste email foi cancelado."
			Else
				MsgStop(STR0030 + aObjEmail[nI][01]:GetEMail() + STR0031) //"O E-Mail ' ' não será enviado pois está incorreto!"
			EndIf

			If lOk
				cEnviados += aObjEmail[nI][01]:GetEMail() + IIF(Empty(cMailCC), "", ";" + cMailCC) + CRLF
				cEnviados += Trim(aObjEmail[nI][01]:GetCods("S")) + CRLF + Replicate("=", 20) + CRLF
				J204DelEml() //Exclui o arquivos anexos temporarios
				aLog      := J204GrvLog(cEscri, cFatur, cAssunto, cPara, cMailCC, cMailCCO, cCorpo, cAnexos)
				J204EmSent(aObjEmail[nI][01]:aCods, aLog) // Marca a fatura como e-mail enviado
			EndIf

		Next nI

		JurFreeArr(aLog)

		If !Empty(cEnviados)
			JurErrLog( STR0029 + CRLF + CRLF + cEnviados, STR0025) //"E-Mail enviado com sucesso para: " ### // "Enviar por E-mail"

			// Atualiza a tela conforme os filtros preenchidos
			J204NXAFilt( J204NXAAFl(cConfig, lCIdioma) , cCmbMailEnv)			
		EndIf

	Else
		ApMsgAlert(STR0196) //"Selecione pelo menos uma fatura para enviar."
	EndIf

Else
	MsgStop(STR0026) //"Favor preencher todos os campos!"
EndIf

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} J204FMail
Valida e Formata e-mail para envio

@param  cMails   , caractere, texto de e-mails a ser formatado separado por ";"
@param  cMailsAdd, caractere, texto de e-mails já formatados para adicionar
@param  lSort, boolean, ordena os e-mails adicionados

@author Jonatas Martins
@since  21/03/2019
/*/
//-------------------------------------------------------------------
Static Function J204FMail(cMails, cMailsAdd, lSort)
	Local aMails      := {}
	Local aMailsAdd   := {}
	Local aFormated   := {}
	Local cFormated   := ""

	Default cMails    := ""
	Default cMailsAdd := ""
	Default lSort     := .F.

	If ValType(cMails) == "C" .And. ValType(cMailsAdd) == "C" .And. ( !Empty(AllTrim(cMails)) .Or. !Empty(AllTrim(cMailsAdd)) )
		cMails    := StrTran(cMails, ",", ";")
		aMails    := StrTokArr(cMails, ";")

		If Len(aMails) > 0
			aEval(aMails, {|cValue| cFormated += IIF(JurIsEMail(AllTrim(cValue)), AllTrim(cValue) + ";", "")})
		EndIf

		If !Empty(cMailsAdd)
				aMailsAdd := StrTokArr(cMailsAdd, ";")
				aFormated := StrTokArr(cFormated, ";")
				aEval(aMailsAdd, {|cAdd| cFormated += IIF(aScan(aFormated, cAdd) == 0, AllTrim(cAdd) + ";", "")})		
				JurFreeArr(aMailsAdd)
				JurFreeArr(aFormated)
		EndIf

		If !Empty(cFormated)
			cFormated := SubStr(cFormated, 1, Len(cFormated) - 1)	
			If lSort
				aMailsAdd := StrTokArr(cFormated, ";")
				cFormated := ""
				aSort(aMailsAdd, , , {|x,y| x < y})
				aEval(aMailsAdd, {|cAdd| cFormated += IIF(aScan(aFormated, cAdd) == 0, AllTrim(cAdd) + ";", "")})		
				cFormated := SubStr(cFormated, 1, Len(cFormated) - 1)					
				JurFreeArr(aMailsAdd)
				JurFreeArr(aFormated)
			EndIf
		EndIf
	EndIf

	JurFreeArr(aMails)

Return (cFormated)

//-------------------------------------------------------------------
/*/{Protheus.doc} J204GetConf
Rotina utilizada para pegar as informações da config de E-mail

@author Felipe Bonvicini Conti
@since 08/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204GetConf(cConfig)
Local aRet     := {}
Local aArea    := GetArea()
Local aAreaNRU := NRU->(GetArea())

NRU->(DBSetOrder(1))
NRU->(dbGoTop())
If NRU->(DBSeek(xFilial('NRU') + cConfig))
	aAdd(aRet, IIf(NRU->(ColumnPos("NRU_ASSUNT")) > 0, NRU->NRU_ASSUNT, NRU->NRU_DESC))
	aAdd(aRet, NRU->NRU_CC)
	aAdd(aRet, NRU->NRU_CCO)
	aAdd(aRet, NRU->NRU_CORPO)
	If NRU->(ColumnPos("NRU_CIDIO")) > 0
		aAdd(aRet, NRU->NRU_CIDIO)
	EndIf
EndIf

RestArea(aAreaNRU)
RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204GetEmails
Rotina utilizada para montar os objetos de E-mail a serem enviados.

@author Felipe Bonvicini Conti
@since  09/03/10
/*/
//-------------------------------------------------------------------
Static Function J204GetEmails(cMarca, cBody, aRelats, cConfig)
Local aRet       := {}
Local aArea      := GetArea()
Local aAreaNXA   := NXA->(GetArea())
Local aEncMail   := {}
Local nI         := 0
Local cMailFor   := ""
Local lCpoAgrNUH := NUH->(ColumnPos("NUH_AGRUPA")) > 0
Local cQbr       := ""
Local aFaturas   := {} // 01 - Quebra
                       // 02 - aFatura
                       //    02.01 - Código do Escritório
                       //    02.02 - fatura
                       //    02.03 - encaminhamentos
                       // 03 - Cliente fatura
                       // 04 - Loja  do cliente da Fatura 
                       // 05 - Destinatários
                       // 06 - Código do Escritório
                       // 07 - Código da Fatura 
                       // 08 - E-mails em cópia (NUH_CEMAIL ou NXA_CEMAIL)
Local lEnvEnc    := .T. // Envia encaminhamentos?
Local cEmailEnc  := ""
Local aFatura    := {}
Local nC         := 0
Local lAgrupFat  := .F.
Local lMailCC    := NXA->(ColumnPos("NXA_CEMAIL")) > 0
Local cMailCC    := ""
Local lMailCli   := NUH->(ColumnPos('NUH_CEMAIL')) > 0 //Proteção
Local lCpoEmlAgr := NXA->(ColumnPos("NXA_EMLAGR")) > 0 // @12.1.2310

NXA->(DBSetOrder(1))
NXA->(dbGoTop())
While !NXA->(EOF())

	If NXA->NXA_OK == cMarca
		If lCpoAgrNUH // NUH_AGRUPA
			lAgrupFat := JurGetDados("NUH", 1, xFilial("NUH") +  NXA->NXA_CLIPG + NXA->NXA_LOJPG, "NUH_AGRUPA") == "1"
		EndIf
		
		If lCpoEmlAgr .And. FindFunction("J203HAgrEm")
			// Novo comportamento - quando agrupa também considera encaminhamentos
			If Empty(NXA->NXA_EMLAGR)
				aEncMail := J204GetEnc(NXA->NXA_CJCONT, NXA->NXA_CCONTR, NXA->NXA_CLIPG, NXA->NXA_LOJPG, NXA->NXA_CFTADC, NXA->NXA_CPREFT, NXA->NXA_CESCR, NXA->NXA_COD)
				J203HAgrEm(NXA->NXA_CESCR, NXA->NXA_COD, aEncMail, .F.)
			EndIf

			cMailFor := NXA->NXA_EMLAGR
		Else
			// Mantido o comportamento atual - quando agrupa não considera encaminhamentos
			cMailFor  := ""
			cEmailEnc := ""
			aFatura   := {}
			aEncMail  := {}

			lEnvEnc := !lAgrupFat

			//Envia encaminhamentos
			If lEnvEnc
				aEncMail := J204GetEnc(NXA->NXA_CJCONT, NXA->NXA_CCONTR, NXA->NXA_CLIPG, NXA->NXA_LOJPG, NXA->NXA_CFTADC, NXA->NXA_CPREFT, NXA->NXA_CESCR, NXA->NXA_COD)
			EndIf

			If !Empty(NXA->NXA_EMAIL)
				cMailFor := J204FMail(NXA->NXA_EMAIL)
			EndIf

			For nI := 1 To Len(aEncMail)
				If lAgrupFat
					cEmailEnc := J204FMail(aEncMail[nI], cEmailEnc)
				Else
					cMailFor := J204FMail(aEncMail[nI], cMailFor)
				EndIf
			Next nI

			//Formata o e-mail cópia
			If lMailCC
				cMailCC := AllTrim(NXA->NXA_CEMAIL)
			Else
				If lMailCli // Formata e-mail CCO (NUH_CEMAIL)
					cMailCC := JurGetDados("NUH", 1, xFilial("NUH") + NXA->NXA_CLIPG + NXA->NXA_LOJPG, "NUH_CEMAIL")
				EndIf
			EndIf

			If !Empty(cMailCC)
				cMailCC :=  J204FMail(cMailCC,,.T.)
			EndIf
		EndIf

		If lAgrupFat
			cQbr := NXA->(cMailFor +"|"+ NXA_CLIPG + "|"+ NXA_LOJPG + "|" + NXA_TIPO + "|" + NXA_CIDIO2)
		Else
			cQbr := NXA->(cMailFor +"|"+  NXA_TIPO + "|"+ NXA_CESCR + "|"+ NXA_COD)
		EndIf

		aFatura :=  { NXA->NXA_CESCR, NXA->NXA_COD, cEmailEnc} 
		If (nI := aScan(aFaturas, {|cQ| cQ[01] == cQbr .And. (lCpoEmlAgr .Or. cQ[08] == cMailCC)})) == 0
			aAdd(aFaturas, {cQbr, {aClone(aFatura)}, NXA->NXA_CLIPG, NXA->NXA_LOJPG, cMailFor, NXA->NXA_CESCR, NXA->NXA_COD, cMailCC})
		Else
			aAdd(aFaturas[nI, 02], aClone(aFatura))
		EndIf
	EndIf
	JurFreeArr(aEncMail)
	
	NXA->(DbSkip())
Enddo

For nI := 1 to Len(aFaturas)
	aAdd(aRet, {JurEMail():New(aFaturas[nI, 03],;  //NXA->NXA_CLIPG
				aFaturas[nI, 04],;  //NXA->NXA_LOJPG
				aFaturas[nI, 05],;  //cMailFor
				aFaturas[nI, 06],; //NXA->NXA_CESCR
				aFaturas[nI, 07],; //NXA->NXA_COD
				cBody, ;
				aRelats, ;
				cConfig,;
				aFaturas[nI, 02]), aFaturas[nI, 08]} )
	For nC := 1 to Len(aFaturas[nI, 02])
		If !Empty(aFaturas[nI, 02][nC, 03]) //TO DO: Enviar os encaminhados agrupados
			aAdd(aRet, {JurEMail():New(aFaturas[nI, 03],;  //NXA->NXA_CLIPG
				aFaturas[nI, 04],;  //NXA->NXA_LOJPG
				aFaturas[nI, 02, nI, 03],;  //cMailFor
				aFaturas[nI, 02, nI, 01],; //NXA->NXA_CESCR
				aFaturas[nI, 02, nI, 02],; //NXA->NXA_COD
				cBody, ;
				aRelats, ;
				cConfig), cMailCC} )
		EndIf
	Next nC
Next nI

For nI := 1 To Len(aRet)
	aRet[nI, 01]:Substituir()
Next

JurFreeArr(aFatura)	
JurFreeArr(aFaturas)
RestArea(aAreaNXA)
RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204EmSent()
Função para marcar a fatura como e-mail enviado

@author Daniel Magalhaes
@since 19/12/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204EmSent(aFatur, aLog)
Local aArea     := GetArea()
Local aAreaNXA  := NXA->(GetArea())
Local aAreaNXM  := NXM->(GetArea())
Local cChave    := ""
Local lCarta    := .F.
Local lRelat    := .F.
Local lRecib    := .F.
Local lRet      := .F.
Local cEscri    := ""
Local cFatur    := ""
Local nC        := 0

Default aLog    := {}

NXM->( DbSetOrder(1) ) // NXM_FILIAL+NXM_CESCR+NXM_CFATUR+NXM_ORDEM

For nC := 1 to Len(aFatur)
	cEscri := aFatur[nC, 01]
	cFatur := aFatur[nC, 02]

	cChave := xFilial("NXM") + AVKEY(cEscri, "NXM_CESCR") + AVKEY(cFatur, "NXM_CFATUR")

	If NXM->(DbSeek(cChave))

		While !NXM->(Eof()) .And. (NXM->NXM_FILIAL + NXM->NXM_CESCR + NXM->NXM_CFATUR == CCHAVE)

			If NXM->NXM_EMAIL == "1" //SIM
				If J204NomCmp( J204STRFile("C", "2", cEscri, cFatur), NXM->NXM_NOMORI)
					lCarta := .T.
				EndIf
				If J204NomCmp( J204STRFile("F", "2", cEscri, cFatur),  NXM->NXM_NOMORI)
					lRelat := .T.
				EndIf
				If J204NomCmp( J204STRFile("R", "2", cEscri, cFatur), NXM->NXM_NOMORI)
					lRecib := .T.
				EndIf
			EndIf

			NXM->( DbSkip() )
		EndDo

		NXA->(DbSetOrder(1))

		If lRet := NXA->( DbSeek(xFilial("NXA") + cEscri + cFatur ) )
			NXA->( Reclock("NXA", .F.) )
			NXA->NXA_MAILEN := "1" //"Sim"
			NXA->NXA_OK     := ""  // Limpa a marca da fatura enviada
			If lCarta
				NXA->NXA_CRTENV := "1" //"Sim"
			EndIf
			If lRelat
				NXA->NXA_RELENV := "1" //"Sim"
			EndIf
			If lRecib
				NXA->NXA_RECENV := "1" //"Sim"
			EndIf
			If Len(aLog) == 3
				NXA->NXA_PARTEN := aLog[1] // Participante de Envio (Formato: CODIGO - SIGLA - NOME)
				NXA->NXA_DTHREN := aLog[2] // Data/Hora do Envio
				NXA->NXA_LOGENV := aLog[3] // Log
			EndIf
			NXA->( MsUnlock() )
			//Grava na fila de sincronização a alteração
			J170GRAVA("NXA", xFilial("NXA") + NXA->NXA_CESCR + NXA->NXA_COD, "4")
		EndIf
	EndIf
Next nC
NXM->( RestArea(aAreaNXM) )
NXA->( RestArea(aAreaNXA) )

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204GetEnc
Função para retornar os encaminhamentos de fatura

@author Daniel Magalhaes
@since 20/12/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204GetEnc(cCjCont, cCContr, cCliPg, cLojPg, cCFatAd, cPreFat, cEscr, cFatura)
Local aRet    := {}
Local aArea   := GetArea()
Local cChave  := ""
Local lEnc    := NVN->(ColumnPos("NVN_CESCR")) > 0 //Proteção
Local lCpoEnv := NVN->(ColumnPos("NVN_ENVENC")) > 0 // @12.1.2210

SU5->( DbSetOrder(1) )

If lEnc //Proteção
	NVN->( DbSetOrder(3) ) //NVN_FILIAL+NVN_CESCR+NVN_CFATUR+NVN_CCONT
	cChave := xFilial("NVN") + cEscr + cFatura
	If NVN->(DbSeek(cChave))
		While !NVN->(EOF()) .And. (NVN->NVN_FILIAL + NVN->NVN_CESCR + NVN->NVN_CFATUR == cChave)
				If lCpoEnv .And. NVN->NVN_ENVENC == "2" // Não considera pra envio de e-mail
					NVN->(DbSkip())
					Loop
				ElseIf SU5->(DbSeek(xFilial("SU5") + NVN->NVN_CCONT))
				If !Empty(SU5->U5_EMAIL)
					AAdd(aRet, AllTrim(SU5->U5_EMAIL))
				EndIf
			EndIf
			NVN->(DbSkip())
		EndDo
	EndIf
Else
	//Verifica o encaminhamento pelo Cod da Pré-fatura
	If !Empty(cPreFat)
		NVN->( DbSetOrder(7) ) //NVN_FILIAL+NVN_CPREFT+NVN_CLIPG+NVN_LOJPG
		cChave := xFilial("NVN") + cPreFat + cCliPg + cLojPg
		If NVN->( DbSeek(cChave) )
			While !NVN->( Eof() ) .And. NVN->( NVN_FILIAL+NVN_CPREFT+NVN_CLIPG+NVN_LOJPG ) == cChave
					If lCpoEnv .And. NVN->NVN_ENVENC == "2" // Não considera pra envio de e-mail
						NVN->(DbSkip())
						Loop
					ElseIf SU5->(DbSeek(xFilial("SU5") + NVN->NVN_CCONT))
					If !Empty(SU5->U5_EMAIL)
						AAdd(aRet, AllTrim(SU5->U5_EMAIL))
					EndIf
				EndIf
				NVN->( DbSkip() )
			EndDo
		EndIf

	//Verifica o encaminhamento pelo Cod da Fatura Adicional
	ElseIf !Empty(cCFatAd)
		NVN->( DbSetOrder(6) ) //NVN_FILIAL+NVN_CCONTR+NVN_CLIPG+NVN_LOJPG
		cChave := xFilial("NVN") + cCFatAd + cCliPg + cLojPg
		If NVN->( DbSeek(cChave) )
			While !NVN->( Eof() ) .And. NVN->( NVN_FILIAL+NVN_CFATAD+NVN_CLIPG+NVN_LOJPG ) == cChave
					If lCpoEnv .And. NVN->NVN_ENVENC == "2" // Não considera pra envio de e-mail
						NVN->(DbSkip())
						Loop
					ElseIf SU5->(DbSeek(xFilial("SU5") + NVN->NVN_CCONT))
					If !Empty(SU5->U5_EMAIL)
						AAdd(aRet, AllTrim(SU5->U5_EMAIL))
					EndIf
				EndIf
				NVN->( DbSkip() )
			EndDo
		EndIf

	//Verifica o encaminhamento pelo Cod da Junção
	ElseIf !Empty(cCjCont)
		NVN->( DbSetOrder(4) ) //NVN_FILIAL+NVN_CJCONT+NVN_CLIPG+NVN_LOJPG
		cChave := xFilial("NVN") + cCjCont + cCliPg + cLojPg
		If NVN->( DbSeek(cChave) )
			While !NVN->( Eof() ) .And. NVN->( NVN_FILIAL+NVN_CJCONT+NVN_CLIPG+NVN_LOJPG ) == cChave
					If lCpoEnv .And. NVN->NVN_ENVENC == "2" // Não considera pra envio de e-mail
						NVN->(DbSkip())
						Loop
					ElseIf SU5->(DbSeek(xFilial("SU5") + NVN->NVN_CCONT))
					If !Empty(SU5->U5_EMAIL)
						AAdd(aRet, AllTrim(SU5->U5_EMAIL))
					EndIf
				EndIf
				NVN->( DbSkip() )
			EndDo
		EndIf

	//Verifica o encaminhamento pelo Cod do Contrato
	ElseIf !Empty(cCContr)
		NVN->( DbSetOrder(5) ) //NVN_FILIAL+NVN_CCONTR+NVN_CLIPG+NVN_LOJPG
		cChave := xFilial("NVN") + cCContr + cCliPg + cLojPg
		If NVN->( DbSeek(cChave) )
			While !NVN->( Eof() ) .And. NVN->( NVN_FILIAL+NVN_CCONTR+NVN_CLIPG+NVN_LOJPG ) == cChave
					If lCpoEnv .And. NVN->NVN_ENVENC == "2" // Não considera pra envio de e-mail
						NVN->(DbSkip())
						Loop
					ElseIf SU5->(DbSeek(xFilial("SU5") + NVN->NVN_CCONT))
					If !Empty(SU5->U5_EMAIL)
						AAdd(aRet, AllTrim(SU5->U5_EMAIL))
					EndIf
				EndIf
				NVN->( DbSkip() )
			EndDo
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA204CanFT()
Função para validar se a fatura é multipayer

@author Jacques Alves Xavier
@since 26/10/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA204CanFT(lCustom)
Local lRet      := .T.
Local lBaixas   := .F.
Local aResult   := {.T.,""}
Local aArea     := GetArea()
Local aAreaNXA  := NXA->(GetArea())
Local cFilSav   := cFilAnt
Local cAliasSE1 := GetNextAlias()
Local cTipo     := ""
Local cMsgLog   := ""
Local cMsgErr   := ""
Local cErroMsg  := ""
Local cFil      := ""
Local cQuery    := ""

Default lCustom := .F.

If PreValCFat(NXA->NXA_TIPO, lCustom)

	If NXA->NXA_SITUAC == '1'

		cFil := JurGetDados( "NS7", 1, xFilial("NS7") + NXA->NXA_CESCR, "NS7_CFILIA" )

		cQuery   := JA204Query( 'TI', xFilial( 'NXA' ),  NXA->NXA_COD, NXA->NXA_CESCR, cFil )

		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasSE1, .T., .T. )

		SE1->( DbsetOrder( 1 ) )

		(cAliasSE1)->( Dbgotop() )

		//Verifica se algum titulo foi identificado com baixas fora do SIGAPFS  - que não seja adiantamento
		Do while !(cAliasSE1)->( eof()) .And. !lBaixas

			lBaixas := J204BxSE1( (cAliasSE1)->SE1RECNO )
			// lBaixas == .T. - há alguma baixas que não são adiantamento
			// lBaixas == .F. - Não há baixas ou as baixas são adiantamento
			(cAliasSE1)->( dbSkip() )

		EndDo

		(cAliasSE1)->( dbcloseArea() )

		If lBaixas // há baixas que não são adiantamneto
			ApMsgInfo(STR0106) // "Não é possível cancelar uma fatura com baixas efetuadas."
			lRet := .F.
		Else
			lRet := JURA203G( 'FT', Date(), 'FATCAN' )[2] // Cria/valida o fechamento de periodo
		EndIf

		//Ponto de entrada para outras verificações do financeiro.
		If lRet .And. Existblock("J204FCAN")
			cErroMsg := ExecBlock( "J204FCAN", .F., .F. )
			If !Empty(cErroMsg)
				ApMsgInfo(cErroMsg)
				lRet := .F.
			EndIf
		EndIf

	Else
		lRet := .F.
		ApMsgInfo(STR0104) // "A fatura selecionada já foi cancelada."
	EndIf

	If lRet

		Begin Transaction

			Do Case
			Case NXA->NXA_TIPO $ "MF|MP|MS"
				If MsgYesNo( STR0148 + NXA->NXA_CPREFT + STR0149 ) //###"Todas as minutas da pré-fatura " ### " serão canceladas! Deseja continuar?"
					lRet := J204CANPG(NXA->NXA_CPREFT, NXA->NXA_TIPO, JA204CodMot)
				Else
					lRet := .F.
				EndIf

			OtherWise
				cTipo := (STR0129 + NXA->NXA_COD) // "Cancelando a Fatura " + NXA->NXA_COD
				Processa( {|| lRet := JA204CanFa(JA204CODMOT) }, STR0037, cTipo, .F. )  //'Aguarde'###
			EndCase

			If lRet

				cMsgLog := I18N(STR0028, {NXA->NXA_COD}) //"A fatura '#1' foi cancelada com sucesso!"

				If NXA->NXA_TIPO $ "MF|MP|MS"

					lRet := J204CanMin(NXA->NXA_CPREFT, NXA->NXA_CESCR, NXA->NXA_COD, NXA->NXA_TIPO )
					If !lRet
						cMsgErr += CRLF + I18N(STR0150, {NXA->NXA_CPREFT}) // "Erro ao cancelar a Pré-Fatura de minuta #1."
					EndIf

				Else  // Cancelamento de fatura

					If !Empty(NXA->NXA_CPREFT)
						aResult := JA204RPre(NXA->NXA_CESCR, NXA->NXA_COD)
						If aResult[1]
							cMsgLog += CRLF + I18N(STR0171, {NXA->NXA_CPREFT}) //"A pré-fatura '#1' está disponível em 'Operações Pré-fatura'."
						Else
							cMsgErr += CRLF + STR0084 + NXA->NXA_CPREFT + " - " + aResult[2] //"Erro ao refazer a Pré-Fatura "
							lRet := .F.
						EndIf

					ElseIf !Empty(NXA->NXA_CFIXO)

						cMsgLog += CRLF + I18N(STR0172, {JurGetDados("NT1", 1, xFilial("NT1") + NXA->NXA_CFIXO, "NT1_PARC" ), NXA->NXA_CCONTR}) //"A parcela de fixo '#1' do contrato '#2' está disponível para faturamento."

					ElseIf !Empty(NXA->NXA_CFTADC)

						cMsgLog += CRLF + I18N(STR0173, {NXA->NXA_CFTADC}) //"A fatura adicional '#1' está disponível para faturamento."

					EndIf

				EndIf
			Else
				Disarmtransaction()
				lRet := .F.
			EndIf

		End Transaction

		If !Empty(cMsgLog)
			ApMsgInfo(cMsgLog)
			If !Empty(cMsgErr)
				ApMsgAlert(cMsgErr)
			EndIf
		EndIf

		If lRet .And. !lCustom .And. !FwIsInCallStack("JA206PROC") .And. JA201TemFt(NXA->NXA_CPREFT,, .F., NXA->NXA_CFIXO, NXA->NXA_CFTADC)
			If ApMsgYesNo(I18N(STR0142, {NXA->NXA_COD}) + CRLF + I18N(STR0146, {NXA->NXA_COD}) + CRLF) //"Ainda existem faturas ativas relacionadas a fatura '#1' de outros pagadores." ## "Deseja também cancelar as faturas relacionadas a fatura '#1' ?"
				lRet := J204CANPG(NXA->NXA_CPREFT,, JA204CodMot, NXA->NXA_CFIXO, NXA->NXA_CFTADC)
			EndIf

		EndIf

	EndIf

EndIf

cFilAnt := cFilSav

RestArea(aArea)
RestArea(aAreaNXA)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA204CanFa()
Função para cancelar a fatura

@Param  cMotivo    Motivo de cancelamento
@Param  lShowMsg   Se .T. exibe a mensagem de erro quando ocorrer
@Param  cMsgErro   Retorno da mesagem de erro (parametro passado por referencia)
@Param  cSolucao   Retorno da mesagem de solução (parametro passado por referencia)
@Param  lMinutaPre Indica se é cancelamento de minuta da Pré-Fatura

@Return  lRet      .T. Se efetuou o cancelamento da fatura

@author Ricardo Camargo de Mattos
@since 05/01/11
@version 2.0
/*/
//-------------------------------------------------------------------
Function JA204CanFa(cMotivo, lShowMsg, cMsgErro, cSolucao, lMinutaPre)
Local lRet          := .T.
Local lUltima       := .T.
Local lEmissao      := FwIsInCallStack("J203FCaMin") // Não deleta os pagadores durante o processo de emissão
Local aArea         := GetArea()
Local aAreaNXA      := NXA->(GetArea())
Local dResult       := SToD("  /  /    ")
Local aSE1          := {}
Local dDtBsOld      := SToD("  /  /    ")
Local lBaixas       := .F.
Local aRet          := {}
Local lFluxoNFAut   := SuperGetMV("MV_JFATXNF", .F., .F.) // Parâmetro habilita o fluxo de emissão e cancelamento de NF a partir da fatura

Private lMsErroAuto := .F.

Default lShowMsg    := .T.
Default cMsgErro    := ""
Default cSolucao    := ""
Default lMinutaPre  := .F.

//Verifica se a fatura já foi cancelada
If NXA->NXA_SITUAC == "2"
	cMsgErro := STR0104 //"A fatura selecionada já foi cancelada."
	cSolucao := STR0197 //"Somente faturas ativas podem ser canceladas."
	lRet     := .F.
EndIf

//Verifica se a fatura ja foi gerada
If lRet .And. NXA->NXA_NFGER == "1" .And. !lFluxoNFAut
	cMsgErro := STR0105  //"Não foi possível cancelar a Fatura pois já existe um Documento Fiscal vinculado."
	cSolucao := STR0198  //"Verifique o documento fiscal da fatura antes de efetuar o cancelamento."
	lRet := .F.
EndIf

If lRet
	aSE1 := J204Baixas()
	//Verifica se algum titulo do loop anterior foi identificado com baixas fora do SIGAPFS
	lBaixas := aScan( aSE1, { | _x | _x[ 2 ] == 'S' } ) > 0

	//Existem baixas efetuadas. Nao pode cancelar a fatura
	If lBaixas
		cMsgErro := STR0106 //"Não é possível cancelar uma fatura com baixas efetuadas."
		cSolucao := STR0199 //"Verifique os títulos da fatura antes de efetuar o cancelamento."
		lRet     := .F.
	EndIf
EndIf

If lRet
	aRet := JURA203G( 'FT', Date(), 'FATCAN' )

	If aRet[2]
		dResult := aRet[1]
	Else
		lRet := aRet[2]
		If Len(aRet) == 4
			cMsgErro := aRet[3]
			cSolucao := aRet[4]
		EndIf
	EndIf

	If lRet .And. (Empty(dResult) .Or. (dResult < NXA->NXA_DTEMI))
		dResult := Date()
	EndIf
EndIf

If lRet
	Begin Transaction

		If NXA->NXA_TITGER == '1' .And. NXA->NXA_TIPO == 'FT'
			lRet := J204CanBxCP(aSE1, NXA->NXA_CESCR) // Cancelamento de baixas por compensação

			If lRet .And. NXA->NXA_NFGER == "1" .And. lFluxoNFAut
				//Marcar Pré-fatura
				If Empty(NXA->NXA_OK)
					RecLock("NXA", .F.)
					NXA->NXA_OK := GetMark(,"NXA","NXA_OK")
					NXA->(MsUnlock())
				EndIf

				Processa({|| lRet := JA206CANC(NXA->NXA_OK, "2", 1, .F., .F., .F., .F.)}, STR0037, "Cancelando o Documento Fiscal...", .F. )  //'Aguarde...'###'Cancelando o Documento Fiscal...'
			EndIf

			//Modifica a data base para tratar cancelamentos em periodos ainda não fechados.
			If lRet
				dDtBsOld   := dDatabase
				dDatabase  := dResult

				Processa( { || lRet := JA204CanTit(dResult) }, STR0037, STR0090, .F. )  //'Aguarde...'###'Cancelando Financeiro...'

				//Retorna a database a siatuacao anterior
				dDatabase   := dDtBsOld
			Else
				Disarmtransaction()
				Break
			EndIf

		EndIf

		If lRet
		
			RecLock( 'NXA', .F. )
			NXA->NXA_TITGER  := ' '
			NXA->NXA_SITUAC  := '2'
			NXA->NXA_CMOTCA  := cMotivo
			NXA->NXA_DTCANC  := dResult
			NXA->NXA_USRCAN  := JurUsuario(__CUSERID)
			NXA->(MsUnLock())
			NXA->(DBcommit())
			//Grava na fila de sincronização a alteração
			J170GRAVA("NXA", xFilial("NXA") + NXA->NXA_CESCR + NXA->NXA_COD, "4")

			//Efetua as gravacoes na fatura para efetivar o cancelamento
			lUltima := J204ULTIFA(NXA->NXA_COD, NXA->NXA_CPREFT, NXA->NXA_CFTADC, NXA->NXA_CFIXO)

			lRet := lRet .And. JA204Cance(NXA->NXA_COD, NXA->NXA_CESCR, 'TS', lUltima, cMsgErro, cSolucao, lMinutaPre)
			lRet := lRet .And. JA204Cance(NXA->NXA_COD, NXA->NXA_CESCR, 'DP', lUltima, cMsgErro, cSolucao, lMinutaPre)
			lRet := lRet .And. JA204Cance(NXA->NXA_COD, NXA->NXA_CESCR, 'LT', lUltima, cMsgErro, cSolucao, lMinutaPre)
			lRet := lRet .And. JA204Cance(NXA->NXA_COD, NXA->NXA_CESCR, 'FX', lUltima, cMsgErro, cSolucao, lMinutaPre)
			lRet := lRet .And. JA204Cance(NXA->NXA_COD, NXA->NXA_CESCR, 'FA', lUltima, cMsgErro, cSolucao, lMinutaPre)
			lRet := lRet .And. JA204CanPg(NXA->NXA_TIPO, NXA->NXA_CPREFT, NXA->NXA_CFTADC, NXA->NXA_CLIPG, NXA->NXA_LOJPG) //Ajusta o registro de pagador para pré-fatura e fatura adicional

			If lRet .And. lUltima .And. !Empty(NXA->NXA_CFIXO) //Se a ultima fatura da parcela de fixo for cancelada, exclui os pagadores e encaminhamento de fatura gerados pela fila.
				J203DelPag(NXA->NXA_CFILA, lEmissao)  // Volta a valer os pagadores do contrato ou da junção
			EndIf

			If lRet
				J204CanOHT(NXA->NXA_FILIAL, NXA->NXA_CESCR, NXA->NXA_COD) // Exclui registros na OHT após cancelamento da Fatura
			EndIf

			If lRet
				//Ponto de Entrada para complementar cancelamento
				If ExistBlock('JA204CFA')
					ExecBlock('JA204CFA', .F., .F.)
				EndIf

				While __lSX8
					ConfirmSX8()
				EndDo

			Else
				If lShowMsg .And. (!Empty(cMsgErro) .Or. !Empty(cSolucao))
					JurMsgErro(cMsgErro, , cSolucao)
				EndIf

				Disarmtransaction()
				Break
			EndIf

		EndIf

	End Transaction

Else

	If lShowMsg
		JurMsgErro(cMsgErro, , cSolucao)
	EndIf

EndIf

JurFreeArr(aSE1)
RestArea(aAreaNXA)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204CanBxCP
Função para cancelar baixa por compensação

@param  aSE1    , [n][1]Recno do título a receber
@param  cEscr   , Escritório da Fatura
@param  lAuto   , Indica se é uma execução automática (Migrador)
@param  cLogErro, Log para controle dos erros

@return lCanBxCP, Retorna .T. se o cancelamento da baixa
                  por compensação  foi efetuado com sucesso

@author Jonatas Martins
@since  27/11/2019
/*/
//-------------------------------------------------------------------
Function J204CanBxCP(aSE1, cEscr, lAuto, cLogErro)
Local aArea      := GetArea()
Local lCanBxCP   := .T.
Local nQtSE1     := 0
Local cFilSav    := cFilAnt
Local cFilTit    := cFilAnt

Default aSE1     := {}
Default cEscr    := ""
Default lAuto    := .F.
Default cLogErro := ""

	If !Empty(cEscr)
		cFilTit := JurGetDados("NS7", 1, xFilial("NS7") + cEscr, "NS7_CFILIA")
	EndIf

	cFilAnt := cFilTit
	DbselectArea("SE1")
	For nQtSE1 := 1 To Len( aSE1 )
		//Posiciona no título principal
		SE1->( DbGoto( aSE1[ nQtSE1 ][ 1 ] ) )

		//Efetua o estorno da baixa por compensação por rotina automática
		lMsErroAuto := .F.
		MsExecAuto( { |_x, _y| FINA330( _x, _y )}, 5, .T. )

		If lMSErroAuto
			lCanBxCP := .F.
			IIf(lAuto, aEval(GetAutoGRLog(), {|l| cLogErro += l + CRLF}), Mostraerro())
			Exit
		EndIf
	Next nQtSE1

	cFilAnt := cFilSav
	RestArea(aArea)

Return (lCanBxCP)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA204Cance()
Função para cancelar os registros vinculados a fatura

@Param  cFilialFat Filal da fatura
@Param  cFatura    Codigo da fatura
@Param  cEscrit    Codigo do escritorio
@Param  cTipo      Tipo do Lançamento a ser desvinculado (TS - Time Sheet, DP - Despesa, LT - Lançamento Tabelado, FA - Fatura Adicional,  FX - Parcela Fixa)
@Param  lAltera    .T. Altera a situação do lançamento 1 - Pendente de faturamento.
@Param  cMsgErro   Retorno da mesagem de erro (parametro passado por referencia)
@Param  cSolucao   Retorno da mesagem de solução (parametro passado por referencia)
@Param  lMinutaPre Indica se é cancelamento de minuta da Pré-Fatura

@author Jacques Alves Xavier
@since 10/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA204Cance(cFatura, cEscrit, cTipo, lAltera, cMsgErro, cSolucao, lMinutaPre)
Local lRet         := .T.
Local aArea        := GetArea()
Local aAreaRef     := {}
Local aAreaLan     := {}
Local cAliasTB     := GetNextAlias()
Local cQuery       := JA204Query(cTipo, , cFatura, cEscrit)
Local cTabRef      := ""
Local cTipolanc    := ""
Local cTabLan      := ""
Local cCampoRef    := ""
Local cCodLanc     := ""
Local lLockNT0     := .F.
Local cFiltro      := ""
Local cAux         := ""

Default cMsgErro   := ""
Default cSolucao   := ""
Default lMinutaPre := .F.

Do Case
	Case cTipo == 'TS'
		cTipolanc := STR0113 //'Time-Sheet'
		cTabLan   := 'NUE'
		cCampoRef := 'NW0_CTS'
	Case cTipo == 'DP'
		cTipolanc := STR0114 //'Despesas'
		cTabLan   := 'NVY'
		cCampoRef := 'NVZ_CDESP'
	Case cTipo == 'LT'
		cTipolanc := STR0115 //'Lanc. Tabelado'
		cTabLan   := 'NV4'
		cCampoRef := 'NW4_CLTAB'
	Case cTipo == 'FX'
		cTipolanc := STR0112 //'Fixo'
		cTabLan   := 'NT1'
		cCampoRef := 'NWE_CFIXO'
	Case cTipo == 'FA'
		cTipolanc := STR0116 //'Fat. Adicional'
		cTabLan   := 'NVV'
		cCampoRef := 'NWD_CFTADC'
EndCase

cTabRef  := Substr(cCampoRef, 1, 3)
aAreaRef := (cTabRef)->(GetArea())
aAreaLan := (cTabLan)->(GetArea())
cFiltro  := (cTabLan)->(DbFilter())
If !Empty(cFiltro) // Limpa o filtro na tabela principal de lançamentos, para que não haja problemas no DbSeek
	cAux := cTabLan + "_SITUAC == '1'"
	(cTabLan)->( dbSetFilter( &( '{|| ' + cAux + ' }'), cAux ) )
	(cTabLan)->(DbGoTop())
EndIf

DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasTB, .T., .T.)

While !(cAliasTB)->( EOF() )

	(cTabRef)->(DbGoTo((cAliasTB)->RECNO))
	cCodLanc := (cTabRef)->(FieldGet(FieldPos(cCampoRef)))

	If RecLock(cTabRef, .F.)
		(cTabRef)->(FieldPut(FieldPos(cTabRef + '_CANC'), '1') ) //Cancela o histórico de faturamento
		(cTabRef)->(MsUnlock())
		(cTabRef)->(dbCommit())
	Else
		lRet := .F.
		Exit
	EndIf

	If lAltera
		(cTabLan)->(DbSetOrder(1))
		If (cTabLan)->(DbSeek(xFilial(cTabLan) + cCodLanc))

			If cTabLan == "NT1" //Tratamemto para não permitir o cancelamento de contrato aberto em modo de alteração
				If NT0->( DbSeek( xFilial("NT0") + (cTabLan)->NT1_CCONTR )) .And. !SoftLock("NT0")
					lRet := .F.
					Exit
				Else
					lLockNT0 := .T.
				EndIf
			EndIf

			If !lMinutaPre
				If RecLock(cTabLan, .F.)
					(cTabLan)->(FieldPut(FieldPos(cTabLan + '_SITUAC'), '1') ) //Altera a situação do lançamento 1 - Pendente de faturamento
					(cTabLan)->(MsUnlock())
					(cTabLan)->(dbcommit())
				Else
					lRet := .F.
					Exit
				EndIf
			EndIf
		Else
			lRet     := .F.
			cMsgErro := STR0110 //A fatura selecionada não foi cancelada.
			cSolucao := I18n(STR0215, {cTipolanc, cCodLanc}) //"Verifique o lançamento de '#1', com código #2, para cancelar a fatura."
			Exit
		EndIf
	EndIf

	If lLockNT0
		NT0->(MsUnLock())
	EndIf

	(cAliasTB)->(DbSkip())
EndDo

(cAliasTB)->(DbCloseArea())

RestArea(aAreaLan)
RestArea(aAreaRef)
RestArea(aArea)

If !Empty(cFiltro)
	(cTabLan)->( dbSetFilter( &( '{|| ' + cFiltro + ' }'), cFiltro ) )
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA204Query()
Função para filtrar os lançamentos e títulos vinculados a fatura.

@Param    cTipo      BX - Baixa dos Titulos / TI - Titulos /  TS - Time Sheets / DP - Despesas
                     LT - Lançamento Tabelado / FA - Fatura Adicional / FX - Fixo
@Param    cFatura    Codigo da fatura
@Param    cEscrit    Codigo do escritorio
@Param    cFilia     Filial do Titulo

@Return   cQuery     Retorna a query montada

@author Jacques Alves Xavier
@since 09/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA204Query(cTipo, cFilialFat, cFatura, cEscrit, cFil)
Local cQuery := ""

Do Case
	Case cTipo == 'BX' // Baixas do Titulos
		cQuery := "SELECT E5_TIPO, E5_SEQ, E5_TIPODOC, E5_DOCUMEN, E5_VALOR "
		cQuery +=  " FROM " + RetSqlName("SE5") + " SE5 "
		cQuery += " WHERE SE5.E5_FILIAL = '" + FWxFilial("SE5", cFil) + "' "
		cQuery +=   " AND E5_PREFIXO||E5_NUMERO||E5_PARCELA||E5_TIPO||E5_FILIAL = '" + cFatura + "'"
		cQuery +=   " AND SE5.D_E_L_E_T_ = ' ' "

	Case cTipo == 'TI' // Contas a Receber (Titulos)
		cQuery := "SELECT E1_VALOR, E1_SALDO, R_E_C_N_O_ SE1RECNO "
		cQuery +=  " FROM " + RetSqlName("SE1") + " SE1 "
		cQuery += " WHERE SE1.E1_FILIAL = '" + FWxFilial("SE1", cFil) + "' "
		cQuery +=   " AND SE1.E1_JURFAT = '" + cFilialFat + AllTrim( + '-' + cEscrit + '-' + cFatura + '-' + cFil) + "'"
		cQuery +=   " AND SE1.D_E_L_E_T_ = ' ' "

	Case cTipo == 'TS' // Time Sheet
		cQuery := "SELECT NW0.R_E_C_N_O_ RECNO "
		cQuery +=  " FROM " + RetSqlName("NW0") + " NW0 "
		cQuery += " WHERE NW0.NW0_FILIAL = '" + xFilial('NW0') + "' "
		cQuery +=   " AND NW0.NW0_CFATUR = '" + cFatura + "' "
		cQuery +=   " AND NW0.NW0_CESCR = '" + cEscrit + "' "
		cQuery +=   " AND NW0.NW0_SITUAC = '2' "
		cQuery +=   " AND NW0.NW0_CANC = '2' "
		cQuery +=   " AND NW0.D_E_L_E_T_ = ' ' "

	Case cTipo == 'DP' // Despesa
		cQuery := "SELECT NVZ.R_E_C_N_O_ RECNO "
		cQuery +=  " FROM " + RetSqlName("NVZ") +" NVZ "
		cQuery += " WHERE NVZ.NVZ_FILIAL = '" + xFilial('NVZ') + "'"
		cQuery +=   " AND NVZ.NVZ_CFATUR = '" + cFatura + "'"
		cQuery +=   " AND NVZ.NVZ_CESCR = '" + cEscrit + "'"
		cQuery +=   " AND NVZ.NVZ_SITUAC = '2'"
		cQuery +=   " AND NVZ.NVZ_CANC = '2'"
		cQuery +=   " AND NVZ.D_E_L_E_T_ = ' ' "

	Case cTipo == 'LT' // Lançamento Tabelado
		cQuery := "SELECT NW4.R_E_C_N_O_ RECNO "
		cQuery +=  " FROM " + RetSqlName("NW4") + " NW4 "
		cQuery += " WHERE NW4.NW4_FILIAL = '" + xFilial('NW4') + "'"
		cQuery +=   " AND NW4.NW4_CFATUR = '" + cFatura + "'"
		cQuery +=   " AND NW4.NW4_CESCR = '" + cEscrit + "'"
		cQuery +=   " AND NW4.NW4_SITUAC = '2'"
		cQuery +=   " AND NW4.NW4_CANC = '2'"
		cQuery +=   " AND NW4.D_E_L_E_T_ = ' ' "

	Case cTipo == 'FX' // Fixo
		cQuery := "SELECT NWE.R_E_C_N_O_ RECNO "
		cQuery +=  " FROM " + RetSqlName("NWE") + " NWE "
		cQuery += " WHERE NWE.NWE_FILIAL = '" + xFilial('NWE') + "'"
		cQuery +=   " AND NWE.NWE_CFATUR = '" + cFatura + "'"
		cQuery +=   " AND NWE.NWE_CESCR = '" + cEscrit + "'"
		cQuery +=   " AND NWE.NWE_SITUAC = '2'"
		cQuery +=   " AND NWE.NWE_CANC = '2'"
		cQuery +=   " AND NWE.D_E_L_E_T_ = ' ' "

	Case cTipo == 'FA' // Fatura Adicional
		cQuery := "SELECT NWD.R_E_C_N_O_ RECNO "
		cQuery +=  " FROM " + RetSqlName("NWD") + " NWD "
		cQuery += " WHERE NWD.NWD_FILIAL = '" + xFilial('NWD') + "'"
		cQuery +=   " AND NWD.NWD_CFATUR = '" + cFatura + "'"
		cQuery +=   " AND NWD.NWD_CESCR = '" + cEscrit + "'"
		cQuery +=   " AND NWD.NWD_SITUAC = '2'"
		cQuery +=   " AND NWD.NWD_CANC = '2'"
		cQuery +=   " AND NWD.D_E_L_E_T_ = ' ' "
EndCase

cQuery := ChangeQuery(cQuery)

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JA204CanPg
Função para ajustar o registro do pagador no cancelamento de faturas de
pré-fatura e fatura Adicional

@Param  cTipo     Código do tipo de Fatura.
@Param  cPrefat   Código da pré-fatura.
@Param  cFatAdic  Código da fatura adicional.

@Param  cCliPag   Cliente pagador da fatura.
@Param  cLojaPag  Loja do cliente pagador da fatura.

@Obs  O registro de pagador referente a fatura de fixo é deletado quando não houver mais faturas

@Return  lRet      .T. Se ajustou a tabela da pagador da pré-fatura/ fatura adicional

@author Luciano Pereira dos Santos
@since 07/05/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA204CanPg(cTipo, cPrefat, cFatAdic, cCliPag, cLojaPag)
Local lRet       := .T.
Local aArea      := GetArea()
Local aAreaNXG   := NXG->(GetArea())

Default cPrefat  := Criavar('NXG_CPREFT', .F.)
Default cFatAdic := Criavar('NXG_CFATAD', .F.)
Default cCliPag  := Criavar('NXG_CLIPG',  .F.)
Default cLojaPag := Criavar('NXG_LOJAPG', .F.)

If cTipo == 'FT' .And. (!Empty(cPrefat) .Or. !Empty(cFatAdic))
	NXG->(dbSetOrder(2)) //NXG_FILIAL + NXG_CPREFT + NXG_CLIPG + NXG_LOJAPG + NXG_CFATAD + NXG_CFIXO
	If (lRet := NXG->(DbSeek(xFilial("NXG") + cPrefat + cCliPag + cLojaPag + cFatAdic)))
		RecLock("NXG", .F.)
		NXG->NXG_CESCR  := " "
		NXG->NXG_CFATUR := " "
		NXG->NXG_DTVENC := CToD('  /  /  ')
		NXG->(MsUnLock())
		NXG->(DbCommit())
	EndIf
EndIf

RestArea(aAreaNXG)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA204CanTit
Baixa por cancelamento dos titulos de fatura no financeiro

@param dDataCanc, Data de cancelamento
@param cLogErro , Log para controle dos erros

@author Ricardo Camargo de Mattos
@since  28/12/10
/*/
//-------------------------------------------------------------------
Function JA204CanTit(dDataCanc, cLogErro)
Local lRet          := .T.
Local aArea         := GetArea()
Local aAreaNS7      := NS7->( GetArea() )
Local aAreaSA1      := SA1->( GetArea() )
Local aAreaSE1      := SE1->( GetArea() )
Local cFilAtu       := cFilAnt
Local cQuery        := ""
Local cQryRes       := GetNextAlias()
Local aTitulos      := {}
Local cFatJur       := ""

Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.
Private lc050Auto   := .T. // Indica ser uma rotina automatica.

Default dDataCanc   := Date()
Default cLogErro    := ""

If !IsBlind()
	ProcRegua( 0 )
	IncProc()
	IncProc()
	IncProc()
	IncProc()
	IncProc()
EndIf

//Posiciona no escritório da fatura para se identificar a filial de geracao correta
NS7->( dbSetOrder( 1 ) )
NS7->( dbSeek( xFilial( 'NS7' ) + NXA->NXA_CESCR ) )

//Posiciona no cliente correto
SA1->( dbSetOrder( 1 ) )
SA1->( dbSeek( xFilial( 'SA1' ) + NXA->NXA_CLIPG + NXA->NXA_LOJPG ) )

cFilAnt     := NS7->NS7_CFILIA
cFatJur     := xFilial( 'NXA' ) + AllTrim( + '-' + NXA->NXA_CESCR + '-' + NXA->NXA_COD + '-' + cFilAnt)

//Seleciona os dados do título principal
cQuery := "Select R_E_C_N_O_ SE1RECNO "
cQuery +=  " From " + RetSqlName("SE1") + " SE1 "
cQuery +=  " Where SE1.E1_JURFAT = '" + cFatJur + "' "
cQuery +=  " And SE1.D_E_L_E_T_ = ' ' "
cQuery +=  " Order By " + SQLOrder( SE1->( IndexKey( 1 ) ) )

DbUseArea( .T., "TopConn", TCGenQry( ,, cQuery ), cQryRes, .F., .F. )

Do While !(cQryRes)->( Eof() ) .And. lRet

	SE1->(DbGoto((cQryRes)->SE1RECNO))
	aTitulos := {}

	//Cria o array para baixar o título a receber quando houver o cancelamento de fatura no PFS
	AADD( aTitulos, {"E1_FILIAL"      , SE1->E1_FILIAL    , NIL})
	AADD( aTitulos, {"E1_NUM"         , SE1->E1_NUM       , NIL})
	AADD( aTitulos, {"E1_PREFIXO"     , SE1->E1_PREFIXO   , NIL})
	AADD( aTitulos, {"E1_SERIE"       , SE1->E1_SERIE     , NIL})
	AADD( aTitulos, {"E1_PARCELA"     , SE1->E1_PARCELA   , NIL})
	AADD( aTitulos, {"E1_TIPO"        , SE1->E1_TIPO      , NIL})
	AADD( aTitulos, {"E1_CLIENTE"     , SE1->E1_CLIENTE   , NIL})
	AADD( aTitulos, {"E1_LOJA"        , SE1->E1_LOJA      , NIL})
	AADD( aTitulos, {"AUTMOTBX"       , 'CNF'             , NIL})
	AADD( aTitulos, {"AUTDTBAIXA"     , dDataCanc         , NIL})
	AADD( aTitulos, {"AUTHIST"        , STR0103           , NIL}) // 'Baixa por Cancelamento de Fatura'

	If SE1->E1_MOEDA != 1 //Quando o titulo não for em moeda nacional envia a taxa para fazer a conversão
		AADD( aTitulos, {"AUTTXMOEDA", SE1->E1_TXMOEDA, NIL})
	EndIf

	//Executa a Baixa do Titulo
	lMsErroAuto := .F.
	MSExecAuto( {|x, y, z| lRet := FINA070(x, y, , , , ,z)}, aTitulos, 3, .T.)

	If lMsErroAuto
		IIF(!IsBlind(), MostraErro(), aEval(GetAutoGRLog(), {|l| cLogErro += l + CRLF}))
		lRet := .F.
	Else
		J204AjImp((cQryRes)->SE1RECNO) // Trata a lei 10925 (Rotina adaptada FINA040)
	EndIf

	(cQryRes)->(DbSkip())

EndDo

(cQryRes)->(DbCloseArea())

cFilAnt := cFilAtu //Retorna a variavel de filial ao estado anterior

RestArea( aAreaSA1 )
RestArea( aAreaNS7 )
RestArea( aAreaSE1 )
RestArea( aArea    )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204JOIN
Função utilizada para juntar os relatórios

@author Felipe Bonvicini Conti
@since 10/11/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function J204JOIN(cEscri, cCodFat, aRelats, cNewFile, lOpenFile, cPastaDest, lAutomato)
Local cPastaPdfTk := JurFixPath(GetSrvProfString("StartPath", "\system\"), 0, 1)
Local cUsrPath    := JurFixPath(GetTempPathAdmin(.T.), 0, 1) //Extrai o diretorio temp do usuário, retirado do crytal.prw
Local nVezes      := 0
Local cCaminhoPDF := ""
Local cMsgErro    := ""
Local lRet        := .T.
Local lUni        := .F.
Local nRetExec    := 0
Local nI          := 0
Local cArquivos   := ""
Local cCNewFile   := ""
Local cRelats     := ""
Local aRetorno    := {}
Local lPadrao     := .T.

Default cEscri     := ""
Default cCodFat    := ""
Default aRelats    := {}
Default cNewFile   := ""
Default lOpenFile  := .T.
Default cPastaDest := JurImgFat(cEscri, cCodFat, .T.)
Default lAutomato  := .F.

If ExistBlock('J204JOIN')
	aRetorno      := ExecBlock('J204JOIN', .F., .F., { cEscri, cCodFat, aClone(aRelats), cNewFile, lOpenFile })
	lPadrao       := aRetorno[1]
	lRet          := aRetorno[2]
	cNewFile      := aRetorno[3]
EndIf

If !lPadrao
	Return lRet
EndIf

If Empty(cNewFile)
	cNewFile := Upper(STR0153 + "_(" + AllTrim(cEscri) + "-" + AllTrim(cCodFat) + ").PDF") // Unificado_
EndIf

cCNewFile := 'Copy_' + cNewFile

If !Empty(aRelats)

	If File(cPastaDest + cNewFile)
		__CopyFile(cPastaDest + cNewFile, cPastaDest + cCNewFile) // Cria uma copia do arquivo unificado.
		FErase(cPastaDest + cNewFile)
	EndIf

	If GetRemoteType() == 1 //Windows
		If File("c:\windows\system32\pdftk.exe")
			cCaminhoPDF := "c:\windows\system32\pdftk.exe"

		ElseIf File(cPastaPdfTk + "pdftk.exe") .And. File(cPastaPdfTk + "libiconv2.dll") //Verifica se os binarios estao no server

			//Copia os binarios para a estacao
			If !File(cUsrPath + "pdftk.exe")
				__CopyFile(cPastaPdfTk + "pdftk.exe", cUsrPath + "pdftk.exe")
			EndIf

			If !File(cUsrPath+"libiconv2.dll")
				__CopyFile(cPastaPdfTk + "libiconv2.dll", cUsrPath + "libiconv2.dll")
			EndIf

			//Se a copia foi bem sucedida, configura o caminho local para os binarios do utilitario PDFTK.exe
			If File(cUsrPath + "pdftk.exe") .And. File(cUsrPath + "libiconv2.dll")
				cCaminhoPDF := cUsrPath + "pdftk.exe"
			Else
				lRet := .F.
			EndIf
		Else
			cMsgErro := STR0158 + CRLF + CRLF //"O programa PDFTK não foi encontrado."
			cMsgErro += STR0159 + cPastaPdfTk //"Copie os arquivos 'pdftk.exe' e 'libiconv2.dll' para a pasta c:\windows\system32\ da estação ou para a pasta "
			cMsgErro += STR0160 //" no servidor. (Parâmetro MV_JFPDFTK)."

			IIF(lAutomato, JurLogMsg(cMsgErro), Alert(cMsgErro))
			lRet := .F.
		EndIf

	Else

		IIF(lAutomato, JurLogMsg(cMsgErro), Alert(cMsgErro)) //"O programa PDFTK só pode ser utilizado em estações Windows."
		lRet := .F.

	EndIf

	If lRet

		//Verifica e elimina versões antigas dos arquivos temporarios na pasta temp do usuario
		For nI := 1 To Len(aRelats) //Exclui os aquivos que serão unificados antigos
			If File(cUsrPath + aRelats[nI])
				FErase(cUsrPath + aRelats[nI])
			EndIf
		Next

		FErase(cUsrPath + cNewFile) //Exclui o arquvo unificado antigo

		// Ordenação para que ao unificar outro documento vinculado por upload ao arquivo unificado, o conteudo do arquivo unificado fique sempre
		// antes do conteudo do novo documento, caso exista algum documento unificado na lista de docs relacionados
		While !( Substr(aRelats[1], 1, 9) == 'UNIFICADO' .OR. Lower(aRelats[1]) == Lower(cNewFile))
			For nI := 1 To Len(aRelats)
				If Substr(aRelats[nI], 1, 9) == 'UNIFICADO' .OR. (Lower(aRelats[nI]) ==  Lower(cNewFile))
					cRelats := aRelats[nI - 1]
					aRelats[nI - 1] := aRelats[nI]
					aRelats[nI]     := cRelats
					lUni := .T.
				EndIf
			Next

			If !lUni
				Exit
			EndIf
		End

		For nI := 1 To Len(aRelats)

			If Lower(cNewFile) == Lower(aRelats[nI])
				aRelats[nI] := cCNewFile // Caso exista um arquivo unificado na lista, e este esteja sendo unificado com um novo arquivo vinculado
			EndIf                        // por upload é criado uma cópia do arquivo para servir de referencia no momento da criação do novo arquivo unificado.

			If File(cPastaDest + aRelats[nI])
				__CopyFile(cPastaDest + aRelats[nI], cUsrPath + FwNoAccent(aRelats[nI]))

				If File(cUsrPath + FwNoAccent(aRelats[nI]))
					cArquivos += " " + CHR(34) + cUsrPath + FwNoAccent(aRelats[nI]) + CHR(34)
				EndIf
			Else
				IIF(lAutomato, JurLogMsg(STR0074 + "(" + aRelats[nI] + ")"), Alert(STR0074 + "(" + aRelats[nI] + ")")) //"Imagem não existe!"
			EndIf
		Next

		If lRet
			nRetExec := ShellExecute("open", cCaminhoPDF, cArquivos + " cat output " + CHR(34) + cUsrPath + cNewFile + CHR(34), cUsrPath, 2)
			lRet     := J204ShowEr(nRetExec)
		EndIf

		If lRet
			While !File(cUsrPath+cNewFile) .And. nVezes <= 5
				Sleep(5000)
				nVezes += 1
			EndDo

			__CopyFile(cUsrPath + cNewFile, cPastaDest + cNewFile)

			If lOpenFile
				lRet := JurOpenFile(cNewFile, cPastaDest, '2', .T.)
			EndIf

			If File(cPastaDest + cCNewFile)
				FErase(cPastaDest + cCNewFile) //Exclui o arquivo de cópia antiga
			EndIf

		EndIf

	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204ShowEr
Função utilizada para verificar se o ShellExecute retornou erro.

@Param   nErro     Código do erro ShellExecute
@Param   lShow    .T. exibe a menssagem de erro em tela
@Param   cMsgLog   Menssagem da rotina, passada por referência

@Return  lRet

@author Luciano Pereira dos Santos
@since 11/11/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function J204ShowEr(nErro, lShow, cMsg)
Local lRet    := .T.

Default cMsg  := ''
Default lShow := .T.

Do Case
Case nErro == 2
	cMsg := STR0095 // "Não foi possível abrir o arquivo. Arquivo ou diretório não existe."
Case nErro == 3
	cMsg := STR0187 // "Caminho do arquivo não encontrado."
Case nErro == 5 .Or. nErro == 55
	cMsg := STR0096 //
Case nErro == 8
	cMsg := STR0188 // "Memória insuficiente."
Case nErro == 15
	cMsg := STR0097 //"Não foi possível abrir o arquivo. O dispositivo não esta pronto."
Case nErro == 26
	cMsg := STR0189 // "Violação de compartilhamento"
Case nErro == 27 .Or. nErro == 31
	cMsg := STR0098 // "Não existe programa associado para abrir o arquivo"
Case nErro == 28
	cMsg := STR0190 // "Tempo de requisição esgotado."
Case nErro == 29
	cMsg := STR0191 // "Falha de transação."
Case nErro == 30
	cMsg := STR0192 // "Dispositivo ocupado"
Case nErro == 32
	cMsg := STR0099 // "Não foi possível abrir o arquivo. Violação de compartilhamento."
Case nErro == 72
	cMsg := STR0100 // "Não foi possível abrir o arquivo. Falha de rede."
EndCase

If !Empty(cMsg)
	If lShow
		ApMsgStop(cMsg)
	EndIf
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA204Confe(cTipo, cFatura, cEscrit)
Função para gerar o relatório de conferência

@author Jacques Alves Xavier
@since 15/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA204Confe()
Local lRet       := .F.
Local oDlg       := Nil
Local aCbResult  := { STR0049, STR0050, STR0147 } //Impressora, Tela, Word
Local cCbResult  := Space( 25 )

If NXA->NXA_SITUAC == '1'

	DEFINE MSDIALOG oDlg TITLE STR0047 FROM 0,0 TO 150,220  PIXEL // Emissão de Conferência

	@ 010, 010 Say STR0048 Size 030,008 PIXEL OF oDlg // Resultado:
	@ 020, 010 ComboBox cCbResult Items aCbResult Size 090, 019 Pixel Of oDlg

	@ 040,010 Button STR0055 Size 037,012 PIXEL OF oDlg Action (lRet := .T., oDlg:End() )  //"Emitir"
	@ 040,062 Button STR0018 Size 037,012 PIXEL OF oDlg Action (lRet := .F., oDlg:End() )  //"Cancelar"

	ACTIVATE MSDIALOG oDlg CENTERED

	cCbResult := AllTrim( Str( aScan( aCbResult, cCbResult ) ) )

	If lRet
		Processa( {|| lRet := J204GerRel(cCbResult) }, STR0037, I18N(STR0246 , {NXA->NXA_CESCR, NXA->NXA_COD}) , .F. ) //"Gerando relatório de conferência da Fatura #1/#2" //'Aguarde'###
	EndIf
Else
	JurMsgErro(STR0057) // Não é possível emitir relatório de Conferência de Fatura Cancelada ou em WO!
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J204GerRel(cCbResult)
Rotina de geração do Relatório de Conferencia da Fatura

@param  cCbResult - Indica o tipo de impressão (Impressora, Tela, Word)
@return lRet      - Indica se o relatório foi gerado com sucesso

@author Willian Yoshiaki Kazahaya | Rebeca Facchinato Asuncao
@since 04/08/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204GerRel(cCbResult)
Local lRet       := .T.
Local cNomeArq   := STR0245 + "_(" + NXA->NXA_CESCR + "-" + NXA->NXA_COD + ")" // conferencia
Local cCrysPath  := JurCrysPath() // obtem o caminho dos arquivos exportados pelo Crystal (MV_JCRYPAS ou chave EXPORT do crysini.ini)
Local cImgFat    := ''
Local cParams    := ""
Local cOptions   := ""

	Do Case
		Case cCbResult = '1'  //Impressora
			cOptions := '2'
		Case cCbResult = '3'  //Word
			cOptions := '8'
		Otherwise //Tela
			cOptions := '1'
	EndCase
	cOptions := cOptions + ';0;1;'  //"Relatorio de Faturamento"
	cOptions := cOptions + cNomeArq // Indica o nome do arquivo sem extensão

	cParams += NXA->NXA_COD + ';'	  							   //Numero Fatura
	cParams += NXA->NXA_CESCR + ';'									 //Escritorio
	cParams += 'S' + ';'            								 //Conferencia
	cParams += 'N' + ';'            								 //Não mostrar despesas
	cParams += 'N' + ';'														 //Utiliza Redação?
	cParams += SuperGetMv('MV_JMOENAC',,'01' ) + ';' //Moeda Nacional
	cParams += JurGetDados("RD0", 1, xFilial("RD0") + JurUsuario(__CUSERID), "RD0_NOME") + ';' //vpcRedator
	cParams += IF(SuperGetMv('MV_JVINCTS ',, .T.), '1', '2') +';' //Vincula Ts ao Fixo

	If lRet
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
		ProcRegua( 0 )
		IncProc()
		JCallCrys( 'JU204', cParams, cOptions, .T., .T., .T. ) // Relatório de Conferência

		// Copia o relatório para a pasta \relatorios_faturamento\ (Pasta de docs relacionados) e em seguida para a pasta temporária do usuário
		JurMvRelat( cNomeArq + '.pdf', cCrysPath, "\relatorios_faturamento\" )

		cImgFat := JurImgFat(NXA->NXA_CESCR, NXA->NXA_COD, .T., .F.)
		J204GetDocs(NXA->NXA_CESCR, NXA->NXA_COD, , , cImgFat, .T.)
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA204Reimp()
Rotina para reimpressão da fatura

@author Jacques Alves Xavier
@since 17/03/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA204Reimp()
Local lRet        := .T.
Local cArquivo    := ''
Local aRetorno    := {}
Local cParams     := ''
Local aParams     := Array(21)
Local aRecsE1     := {}
Local cChavE1     := ""
Local cTpRel      := ""
Local cCarta      := ""
Local aArea       := GetArea()
Local aAreaNXA    := NXA->(GetArea())
Local lRetorno    := .T.
Local aRelat      := {}
Local cRelats     := '000'
Local cMessage    := ""
Local cDirCrystal := GetMV('MV_CRYSTAL')
Local cArqRel     := ''
Local cTipFat     := GetMV( 'MV_JTIPFAT',, 'FT ' )
Local cPrefat     := GetMV( 'MV_JPREFAT',, 'PFS' )
Local lPortador   := SuperGetMV( 'MV_JUSAPOR', .F., .T. ) //Utiliza dados do portador da fatura/contrato
Local lJA203BOL   := ExistBlock("JA203BOL")

If NXA->NXA_SITUAC == "2"
	If NXA->NXA_TIPO $ "MF|MP|MS"
		ApMsgStop(STR0156)  //"A minuta selecionada já foi cancelada."
	Else
		ApMsgStop(STR0104)  //"A fatura selecionada já foi cancelada."
	EndIf

	Return .F.
EndIf

// Verifica / Atualiza os impostos
If NXA->NXA_TIPO $ "FT"
	If !J204AtuImp(NXA->NXA_COD, NXA->NXA_CESCR, "1")[1]
		Return .F.
	EndIf
EndIf

//Utilizar o array aParams com as 20 posições descritas na rotina JA203PARAM()
If ExistBlock('J204REFAZ')
	aRetorno  := ExecBlock('J204REFAZ', .F., .F.)
	lRet      := aRetorno[1]
	aRelat    := aRetorno[2]
	aParams   := aRetorno[3]
Else
	aRetorno  := JA204Param()
	lRet      := aRetorno[1]
	aRelat    := aRetorno[2]
	aParams   := aRetorno[3]
EndIf

If lRet
	cMessage := STR0164 + " - " + STR0166 +": "+ NXA->NXA_CESCR +"-" + NXA->NXA_COD //"Início - Reimprimir Fatura"
	EventInsert( FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, "055", FW_EV_LEVEL_INFO, ""/*cCargo*/, STR0082, cMessage, .F. ) // " Reimprimir Fatura"

	If FindFunction("JPDLogUser")
		JPDLogUser("JA204Reimp") // Log LGPD Refazer fatura
	EndIf

	If aRelat[1] //Relatório de Faturamento
		cParams := aParams[ 3] + ';'	//vpiNumFatura
		cParams += aParams[ 4] + ';'	//vpiOrganizacao
		cParams += 'N' + ';'	//vpcConferencia
		cParams += aParams[16] + ';'
		cParams += aParams[15] + ';' // Utiliza Redação?
		cParams += SuperGetMv('MV_JMOENAC',,'01' ) + ';' // Moeda Nacional
		cParams += aParams[18] + ';'	//vpcRedator
		cParams += If(SuperGetMv('MV_JVINCTS ',,.T.), '1', '2') +';' //Vincula Ts ao Fixo
		//Adiciona o comando para parâmetros adicionais (customizados no relatório)
		If !Empty(aParams[21]) .AND. (Substr(aParams[21], Len(aParams[21]), Len(aParams[21])-1 ) == ';')
			cParams += aParams[21]
		EndIf

		cArquivo := STR0059 + "_(" + Trim(aParams[4]) + "-" + Trim(aParams[3]) + ")" // Relatorio_

		cTpRel := Alltrim(JurGetDados("NRJ", 1, xFilial("NRJ") + NXA->NXA_TPREL, "NRJ_ARQ"))

		If Empty(cTpRel)
			cTpRel := 'JU203'
		Else
			// Valida se o arquivo RPT existe na pasta de relatorios Crystal
			cArqRel := Upper(alltrim(cTpRel))
			cArqRel := StrTran(cArqRel, '.RPT', '')  // tira o .rpt do nome caso tenha sido cadastrado

			If File(cDirCrystal+cArqRel+'.RPT')  // verifica se encontra o arquivo especifico na pasta dos relatorios
				cTpRel := IIF(At( '.', cTpRel ) > 0, Substr(cTpRel, 1, At( '.', cTpRel ) - 1), cTpRel)
			Else
				cTpRel := 'JU203'
			EndIf
		EndIf

		aParams[12] := cTpRel

		// Gera o relatório de Faturamento - adiciona no na fila da Thread de emissão de relatórios
		J203ADDREL("F", aParams, , "JURA204")

	EndIf

	If aRelat[2] //Carta de Cobrança
		cParams := aParams[ 2] 	+ ';'	//vpiCodUser
		cParams += aParams[ 3] 	+ ';'	//vpiNumFatura
		cParams += aParams[ 4] 	+ ';'	//vpiOrganizacao
		cParams += aParams[ 5] 	+ ';'	//vpcNoSocioFatura
		cParams += aParams[ 6] 	+ ';'	//vpiCliente
		cParams += aParams[ 7] 	+ ';'	//vpcPreFaturaMinuta
		cParams += aParams[ 8] 	+ ';'	//vpcExibirLogo
		cParams += aParams[ 9] 	+ ';'	//vpcDadosDeposito
		cParams += aParams[10] 	+ ';'	//vpcContraApresentacao
		cParams += 'N' 			+ ';'	//vpcFaturaRateada
		cParams += aParams[17] 	+ ';'	//vpcAssinaturaEletron
		cParams += aParams[18] 	+ ';'	//vpcRedator
		//Adiciona o comando para parâmetros adicionais (customizados no relatório)
		If  !Empty(aParams[20]) .AND. (substr(aParams[20], len(aParams[20]), len(aParams[20])-1 ) == ';')
			cParams += aParams[20]
		EndIf

		cArquivo := STR0073+"_("+Trim(aParams[4]) +"-"+Trim(aParams[3])+")" //"carta"

		cCarta := Alltrim(JurGetDados("NRG", 1, xFilial("NRG") + NXA->NXA_CCARTA, "NRG_ARQ"))

		If Empty(cCarta)
			cCarta := 'JU203A'
		Else
			cCarta := IIF(At( '.', cCarta ) > 0,  substr(cCarta, 1, At( '.', cCarta )-1 ), cCarta)
		EndIf
		aParams[12] := cCarta

		//cliente: PNA - sobreescreve os PFs (S/N)
		If ExistBlock('J203SUB')
			lRetorno := ExecBlock('J203SUB', .F., .F., {cCarta, cParams, aParams[1]+cArquivo, aParams})
			If ValType(lRetorno) <> "L"
				lRetorno := .T.
			EndIf
		EndIf

		If lRetorno

			//Gera a Carta de Cobrança - adiciona no na fila da Thread de emissão de relatórios
			J203ADDREL("C", aParams, ,"JURA204")
			//O ponto de entrada "J203CRT" já é chamado na rotina JA203CARTA()
			//se não sobreescrever os docs, deve executar assim mesmo.

		Else
			//cliente: PNA -
			If ExistBlock('J203CRT')
				ExecBlock('J203CRT', .F., .F., { aParams, cParams, aParams[19], lRetorno })
			EndIf

		EndIf

	EndIf

	If aRelat[3] //Recibo
		If NXA->NXA_SITUAC == '1' .And. NXA->NXA_TIPO = 'FT'
			cParams := aParams[ 3] + ';'	//vpiNumFatura
			cParams += aParams[ 4] + ';'	//vpiOrganizacao
			cParams += aParams[ 5] + ';'	//vpcNoSocioFatura

			cArquivo := STR0062+"_("+Trim(aParams[4])+"-"+Trim(aParams[3])+")" // "Recibo"
			aParams[12] := 'JU203b'
			//Gera o Recibo - adiciona no na fila da Thread de emissão de relatórios
			J203ADDREL("R", aParams, , "JURA204")

		Else
			ApMSgInfo(STR0089) // "Não é possível emitir recibo de minuta, fatura cancelada ou em WO!"
		EndIf
	EndIf

	If aRelat[4] //Boleto
		NS7->( DbSetOrder(1) )
		If NS7->( dbSeek( xFilial('NS7') + NXA->NXA_CESCR ) )

			aRecsE1 := {}
			cChavE1 := AvKey(NS7->NS7_CFILIA, "E1_FILIAL") + AvKey(cPreFat, "E1_PREFIXO") + AvKey(NXA->NXA_COD, "E1_NUM")

			SE1->( DbSetOrder(1) )
			SE1->( DbSeek( cChavE1 ) )

			While !SE1->(Eof()) .And. cChavE1 == SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM)
				//Somente titulos de fatura
				If SE1->E1_TIPO == AvKey(cTipFat,"E1_TIPO")
					AAdd( aRecsE1, SE1->(Recno()) )

					// Caso o usuário cancele o borderô, essa informações são apagadas
					If Empty(SE1->E1_PORTADO) .Or. Empty(SE1->E1_AGEDEP) .Or. Empty(SE1->E1_CONTA)
						RecLock("SE1", .F.)
						SE1->E1_PORTADO := NXA->NXA_CBANCO
						SE1->E1_AGEDEP  := NXA->NXA_CAGENC
						SE1->E1_CONTA   := NXA->NXA_CCONTA
						SE1->(MsUnLock())
					EndIf
				EndIf
				SE1->( DbSkip() )
			EndDo
		EndIf

		If lJA203BOL
			ExecBlock("JA203BOL", .F., .F., { aRecsE1, aParams } )

		Else
			If FindFunction("U_FINX999") .And. aParams[14] == 'S' .And. NXA->NXA_FPAGTO == "2" .And. lPortador // Emite boleto
				J203ADDREL("B", aParams, , "JURA204")
			EndIf
		EndIf
	EndIf

	cRelats := If(aRelat[1], "1", "0") + If(aRelat[2], "1", "0") + If(aRelat[3], "1", "0")
	// Gera o relatório de Faturamento - adiciona no na fila da Thread de emissão de relatórios
	J203ADDREL("D", aParams, cRelats, "JURA204")

	cMessage := STR0165 + " - " + STR0166 +": "+ NXA->NXA_CESCR +"-" + NXA->NXA_COD //"Final - Reimprimir Fatura"
	EventInsert( FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, "055", FW_EV_LEVEL_INFO, ""/*cCargo*/, STR0082, cMessage, .F. ) // " Reimprimir Fatura"

EndIf

RestArea(aAreaNXA)
RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA204Param()
Rotina para reimpressão da fatura

Estrutura do array aParams:
	aParams[ 1] -	caractere	-	Opções de emissão(Crystal): cOptions + ';0;1;'
										cOption - '2' = Impressora
										cOption - '8' = Word
										cOption - '1' = Tela
	aParams[ 2] -	caractere	-	código do usuário do protheus (__CUSERID)
	aParams[ 3] -	caractere	-	Número da fatura
	aParams[ 4] -	caractere	-	Escritório
	aParams[ 5] -	caractere	-	Nome do Sócio da Fatura
	aParams[ 6] -	caractere	-	Código do Cliente
	aParams[ 7] -	caractere	-	Minuta de pré? ('S' / 'N')
	aParams[ 8] -	caractere	-	Exibe logotipo? ('S' / N)
	aParams[ 9] -	caractere	-	Utiliza dados de depósito? 	 ('S' / 'N')
	aParams[10] -	caractere	-	Utiliza contra apresentação (substitui o vencimento por 'contra-apresentação')  ('S' / 'N')
	aParams[11] -	caractere	-	Fatura Rateada? ('S' / 'N')
	aParams[12] -	caractere	-	Nome do relatório a ser emitido (sem extensão .RPT)
	aParams[13] -	caractere	-	Recibo
	aParams[14] -	caractere	-	Boleto
	aParams[15] -	caractere	-	Utilizar Redação ('S' / 'N')
	aParams[16] -	caractere	-	Ocultar despesas no Relatório ('S' / 'N')
	aParams[17] -	caractere	-	Exibir Assinatura Eletronica ('S' / 'N')
	aParams[18] -	caractere	-	Redator - Nome do participante de emissão
	aParams[19] -	caractere	-	Resultado do relatório - char: '1' - Impressora / '3' - Word / outros - Tela
	aParams[20]	-	caractere	-	Command - Para adição de parâmetros customizados na carta - separados com ';' e terminado com ';'
	aParams[21]	-	caractere	-	Command - Para adição de parâmetros customizados no relatório - separados com ';' e terminado com ';'
	aParams[22]	-	caractere	-	Command - Para customização de parâmetros para tela - separados com ';' e terminado com ';'

@author David Fernandes
@since 06/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA204Param()
Local lRet     := .F.
Local oDlg

Local cSocio   := Criavar( 'RD0_SIGLA', .F. )
Local cNome    := Criavar( 'RD0_NOME' , .F. )

Local oCkCarta
Local oCkRelat
Local oCkRecibo
Local oCkContApr
Local oCkRedacao
Local oCkLogo
Local oCkNoDesps
Local oCkAdicDep
Local oCkNomeRes
Local oCkAssin

Local lCkCarta
Local lCkRelat
Local lCkRecibo
Local lCkContApr
Local lCkRedacao
Local lCkLogo
Local lCkNoDesps
Local lCkAdicDep
Local lCkNomeRes
Local oCkGeraBol

Local lCkGeraBol := .F.
Local lCkAssin   := .T. //Assinatura Eletronica

Local oGetNome

Local oGetResp
Local aCbResult := { STR0049, STR0050, STR0147, STR0163} //"Impressora"###"Tela", Word / Nenhm
Local cCbResult := Space( 25 )
Local cOptions  := ''

Local aParams   := Array(22)
Local aRelat    := Array(4)

Local lPDUserAc := Iif(FindFunction("JPDUserAc"), JPDUserAc(), .T.) // Indica se o usuário possui acesso a dados sensíveis ou pessoais (LGPD)

	If !lPDUserAc
		cCbResult := aCbResult[4] // Nenhum
	EndIf

	DEFINE MSDIALOG oDlg TITLE STR0070 FROM 0,0 TO 250,423  PIXEL //"Relatórios de Faturamento"

	@ 005, 005 CheckBox oCkCarta   Var lCkCarta                                                    Prompt STR0060 Size 100, 008 Pixel Of oDlg // "Carta de Cobrança"
	@ 015, 005 CheckBox oCkRelat   Var lCkRelat                                                    Prompt STR0061 Size 100, 008 Pixel Of oDlg // "Relatório"
	@ 025, 005 CheckBox oCkRecibo  Var lCkRecibo                                                   Prompt STR0062 Size 100, 008 Pixel Of oDlg // "Recibo"
	@ 035, 005 CheckBox oCkNoDesps Var lCkNoDesps                                                  Prompt STR0067 Size 100, 008 Pixel Of oDlg // "Não mostrar despesas no Relatório"
	@ 045, 005 CheckBox oCkNomeRes Var lCkNomeRes                                                  Prompt STR0068 Size 100, 008 Pixel Of oDlg // "Incluir nome do Sócio"
	@ 055, 005 CheckBox oCkGeraBol Var lCkGeraBol on Change (J204VldBol(@lCkGeraBol, @oCkGeraBol)) Prompt STR0063 Size 100, 008 Pixel Of oDlg // "Boleto"

	@ 070, 005 Say STR0071 Size 035,008  PIXEL OF oDlg //"Responsável"
	@ 080, 005 MsGet oGetResp Var cSocio Valid ;
	IIf(!Empty(cSocio), ;
	IIf( ExistCPO( 'RD0', cSocio, 9), cNome := JurGetDados('RD0', 9, xFilial('RD0') + cSocio, 'RD0_NOME' ), cNome := '') ;
	, .T.) F3 'RD0REV' HasButton Size 100,009 PIXEL OF oDlg
	@ 095, 005 MsGet oGetNome Var cNome  Size 205,009 PIXEL OF oDlg

	@ 005, 110 CheckBox oCkContApr Var lCkContApr Prompt STR0064 Size 100, 008 Pixel Of oDlg // "Contra Apresentação"
	@ 015, 110 CheckBox oCkRedacao Var lCkRedacao Prompt STR0065 Size 100, 008 Pixel Of oDlg // "Utilizar Redação"
	@ 025, 110 CheckBox oCkLogo    Var lCkLogo    Prompt STR0066 Size 100, 008 Pixel Of oDlg // "Exibir Logotipo"
	lCkLogo := .T.
	@ 035, 110 CheckBox oCkAdicDep Var lCkAdicDep Prompt STR0069 Size 100, 008 Pixel Of oDlg // "Adicionar Depósito"
	@ 045, 110 CheckBox oCkAssin   Var lCkAssin   Prompt STR0093 Size 100, 008 Pixel Of oDlg // "Suprime Assinatura"

	@ 070, 110 Say STR0048 Size 030,008 PIXEL OF oDlg //"Resultado:"
	@ 080, 110 ComboBox cCbResult Items aCbResult When lPDUserAc Size 100, 012 Pixel Of oDlg

	@ 110, 129 Button STR0055 Size 037,012 PIXEL OF oDlg  Action  (lRet := .T. , oDlg:End() )  //"Emitir"
	@ 110, 172 Button STR0018 Size 037,012 PIXEL OF oDlg  Action  (lRet := .F. , oDlg:End() )  //"Cancelar"

	ACTIVATE MSDIALOG oDlg CENTERED

	cCbResult := AllTrim( Str( aScan( aCbResult, cCbResult ) ) )

	If lRet

		If lCkRelat .OR. lCkCarta .OR. lCkRecibo .Or. lCkGeraBol

			aRelat[1] := lCkRelat
			aRelat[2] := lCkCarta
			aRelat[3] := lCkRecibo
			aRelat[4] := lCkGeraBol

			Do Case
				Case cCbResult = '1'  //Impressora
					cOptions := '2'
				Case cCbResult = '3'  //Word
					cOptions := '8'
				Otherwise //Tela
					cOptions := '1'
			EndCase
			cOptions := cOptions + ';0;1;'  // "Relatorio de Faturamento"

			aParams[ 1] :=	cOptions

			aParams[ 2] :=	__CUSERID//vpiCodUser
			aParams[ 3] :=	NXA->NXA_COD//vpiNumFatura
			aParams[ 4] :=	NXA->NXA_CESCR//vpiOrganizacao
			aParams[ 5] :=	IIf( lCkNomeRes , cNome, " " )//vpcNoSocioFatura
			aParams[ 6] :=	NXA->NXA_CCLIEN//vpiCliente
			aParams[ 7] :=	'N' //vpcPreFaturaMinuta
			aParams[ 8] :=	IIf( lCkLogo    , 'S', 'N' )//vpcExibirLogo
			aParams[ 9] :=	IIf( lCkAdicDep , 'S', 'N' )//vpcDadosDeposito
			aParams[10] :=	IIf( lCkContApr , 'S', 'N' )//vpcContraApresentacao
			aParams[11] :=	IIf( lCkCarta , 'S', 'N' )//cCarta
			aParams[12] :=	IIf( lCkRelat , 'S', 'N' )//cRelatorio
			aParams[13] :=  'N' // Recibo
			aParams[14] :=	IIf( lCkGeraBol	, 'S', 'N' )
			aParams[15] :=	IIf( lCkRedacao	, 'S', 'N' )
			aParams[16] :=	IIf( lCkNoDesps	, 'S', 'N' )
			aParams[17] :=	IIf( lCkAssin	, 'S', 'N' )
			aParams[18] :=	JurGetDados("RD0", 1, xFilial("RD0") + JurUsuario(__CUSERID), "RD0_NOME")
			aParams[19] :=	cCbResult //Resultado do relatório: '1' - Impressora / '2' - Tela / '3' - Word / '4' - Nenhum
			aParams[20] :=	" "
			aParams[21] :=	" "
			aParams[22] :=	" "

		Else
			ApMSgInfo( STR0107 ) // "Selecione pelo menos uma das opções: Carta de Cobrança, Relatório, Recibo ou Boleto."
			lRet := .F.
		EndIf
	EndIf

Return {lRet, aRelat, aParams}

//-------------------------------------------------------------------
/*/{Protheus.doc} J204VldBol()
Valida se é possível emitir boleto no Refazer

@param lCkGeraBol, Indica se o boleto será emitido na opção Refazer
@param oCkGeraBol, Objeto CheckBox que indica se o boleto será 
                   emitido na opção Refazer

@author Jorge Martins
@since  08/07/2021
/*/
//-------------------------------------------------------------------
Static Function J204VldBol(lCkGeraBol, oCkGeraBol)

	If lCkGeraBol .And. FindFunction("JFatLiq") .And. JFatLiq(NXA->NXA_FILIAL, NXA->NXA_CESCR, NXA->NXA_COD)
		lCkGeraBol := JurMsgErro(STR0240,, STR0241) // "Não é possível marcar a opção de gerar o boleto." - "Essa fatura foi renegociada. Por esse motivo será possível gerar o boleto somente pelo título no módulo financeiro."
		oCkGeraBol:Refresh()
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JA204PTIT()
Posicao dos titulos financeiros da fatura

@author Ernani Forastieri
@since 17/03/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA204PTIT()
	Processa( { || JA204PTGER() }, STR0037, STR0108, .F. ) //"Aguarde..."###"Efetuando rastreamento ..."
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JA204PTGER()
Geracao da Posicao dos titulos financeiros da fatura

@author Ernani Forastieri
@since 17/03/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA204PTGER()
Local aArea      := GetArea()
Local aAreaFI7   := FI7->( GetArea() )
Local aAreaSE1   := SE1->( GetArea() )
Local aCoors     := {}
Local aStruSE1   := {}
Local aStruTit   := SE1->( dbStruct() )
Local cFatJur    := ''
Local cFilAtu    := cFilAnt
Local cFilSE1    := ''
Local cQuery     := ''
Local cTmp       := ''
Local cWhere     := ''
Local nI         := 0
Local TSE1       := GetNextAlias()
Local oDlg       := Nil
Local oBrowse    := Nil
Local oMainWnd   := Nil
Local cIndExpr   := ''
Local oTmpTable  := Nil
Local cCampo     := ''
Local cNivelCpo  := ''
Local cBrowse    := ''
Local nZ         := 0
Local nTamanho   := 1
Local cOpcoes    := ""
Local aOpcoes    := {}
Local lObfuscate := FindFunction("FwPDCanUse") .And. FwPDCanUse(.T.) // Indica se trabalha com Dados Protegidos e possui a melhoria de ofuscação de dados habilitada
Local aColumns   := {}
Local aLegTit    := {}

SE1->( dbSetOrder( 1 ) )
NS7->( dbSetOrder( 1 ) )
FI7->( dbSetOrder( 1 ) )

For nI := 1 To Len( aStruTit )
	cCampo    := aStruTit[nI][1]
	cNivelCpo := GetSx3Cache(cCampo, "X3_NIVEL")
	cBrowse   := GetSx3Cache(cCampo, "X3_BROWSE")
	cUsado    := GetSx3Cache(cCampo, "X3_USADO")
	cOpcoes   := GetSx3Cache(cCampo, "X3_CBOX")

	If ((cCampo $ 'E1_IRRF|E1_ISS|E1_INSS|E1_CSLL|E1_COFINS|E1_PIS' .Or. cBrowse == 'S') .And.;
		X3USO(cUsado) .And. cNivel >= cNivelCpo) .Or. (cCampo $ 'E1_FILIAL|E1_SALDO|E1_TIPOLIQ')

		aAdd( aStruTit[nI], cOpcoes )

		If !Empty(cOpcoes) // Trata o tamanho dos campos X3_CBOX
			nTamanho := 1
			aOpcoes  := {}
			aOpcoes := StrTokArr(cOpcoes, ";")
			For nZ := 1 To Len(aOpcoes)
				If Len(aOpcoes[nZ] ) > nTamanho
					nTamanho := Len(aOpcoes[nZ])
				EndIf
			Next nZ

			aStruTit[nI][3] := nTamanho

		EndIf

		aAdd( aStruSE1, aStruTit[nI] )
	EndIf

Next nI

// Cria no banco uma tabela temporária
oTmpTable := FWTemporaryTable():New( TSE1, aStruSE1 )
cIndExpr := SE1->( IndexKey( 1 ) )
oTmpTable:AddIndex("Ind1", JurIndTraA(cIndExpr))
oTmpTable:Create()

// Posiciona no escritorio da fatura para se identificar a filial de geracao correta
NS7->( dbSeek( xFilial( 'NS7' ) + NXA->NXA_CESCR ) )
cFilAnt     := NS7->NS7_CFILIA
cFilSE1     := xFilial( 'SE1' )
cFatJur     := xFilial( 'NXA' ) + '-' + NXA->NXA_CESCR+ '-' + NXA->NXA_COD + '-' + cFilAnt

// Obtem os titulos originais da Fatura
cQuery := "SELECT COUNT(R_E_C_N_O_) QUANT "
cWhere := "  FROM " + RetSqlName( "SE1" ) + " SE1 "
cWhere += " WHERE E1_FILIAL = '" + xFilial( 'SE1' ) + "' "
cWhere += "   AND E1_JURFAT = '" + cFatJur + "' "
cWhere += "   AND SE1.D_E_L_E_T_ = ' ' "

cQuery += cWhere

cTmp   := GetNextAlias()

dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cTmp, .T., .F. )

ProcRegua( ( cTmp )->QUANT )

( cTmp )->( dbCloseArea() )

cQuery := "SELECT R_E_C_N_O_ SE1RECNO "
cWhere += " ORDER BY " +  SQLOrder( SE1->( IndexKey( 1 ) ) )
cQuery += cWhere

cTmp := GetNextAlias()

dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cTmp, .T., .F. )

While !( cTmp )->( EOF() )

	IncProc()
	
	SE1->( dbGoTo( ( cTmp )->SE1RECNO ) )
	RecLock( TSE1, .T. )

	For nI := 1 To Len(aStruSE1)
		If Empty(aStruSE1[nI][5])
			( TSE1 )->( FieldPut( FieldPos( aStruSE1[nI][1] ), SE1->(FieldGet(FieldPos(aStruSE1[nI][1]))) ) )
		Else
			cRet := JurInfBox(aStruSE1[nI][1], SE1->(FieldGet(FieldPos(aStruSE1[nI][1]))) )
			( TSE1 )->( FieldPut( FieldPos( aStruSE1[nI][1] ), cRet ) )
		EndIf
	Next

	(TSE1)->(MsUnLock())

	( cTmp )->( dbSkip() )

EndDo

(cTmp)->(DbCloseArea())

// Montagem da tela de exibição
aCoors := FWGetDialogSize( oMainWnd )

Define MsDialog oDlg Title STR0075 FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] STYLE nOR( WS_VISIBLE, WS_POPUP ) Pixel //"Titulos Financeiro Referentes a Fatura "
aSeek := getSeek()
Define FWFormBrowse oBrowse DATA TABLE ALIAS TSE1 DESCRIPTION STR0075 + ' - ' + NXA->NXA_COD SEEK ORDER aSeek  Of oDlg //"Titulos Financeiro Referentes a Fatura "

aLegTit := J204LegTit(.F.) // Monta array com a estrutura da legenda

AEval(aLegTit, {|aLeg| oBrowse:AddLegend(aLeg[1], aLeg[2], aLeg[3])})

// Adiciona colunas
For nI := 1 To Len( aStruSE1 )
	AAdd( aColumns, FWBrwColumn():New() )
	aColumns[nI]:SetData(&( '{ || ' + aStruSE1[nI][1] + ' }' ))
	aColumns[nI]:SetTitle( Rettitle(aStruSE1[nI][1]) )
	aColumns[nI]:SetPicture( IIf(Empty(aStruSE1[nI][5]), X3Picture(aStruSE1[nI][1]), "") )
	If lObfuscate
		aColumns[nI]:SetObfuscateCol( Empty(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, {aStruSE1[nI][1]})) )
	EndIf
Next

oBrowse:SetColumns(aColumns)
oBrowse:DisableDetails()

// Adiciona os botoes do Browse
ADD Button oBtVisual Title STR0079 Action "JA204VSE1( '" + TSE1 + "' ) " OPERATION MODEL_OPERATION_VIEW   Of oBrowse //"Visualizar"
ADD Button oBtLegend Title STR0072 Action "J204LegTit(.T.)" OPERATION MODEL_OPERATION_VIEW   Of oBrowse //"Legenda"

Activate FWFormBrowse oBrowse // Ativação do Browse
Activate MsDialog oDlg Centered // Ativação do janela

oTmpTable:Delete()

cFilAnt := cFilAtu

RestArea( aAreaSE1 )
RestArea( aAreaFI7 )
RestArea( aArea    )

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JA204VSE1()
Visualizacao dos titulos

@author Ernani Forastieri
@since 17/03/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA204VSE1( TSE1 )
Local aArea       := GetArea()
Local aAreaSE1    := SE1->( GetArea() )

Private cCadastro := STR0080  //"Contas a Receber"

SE1->( dbSetOrder( 1 ) )
If SE1->( dbSeek( ( TSE1 )->( E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO ) ) )
	If FindFunction("JFatLiq") .And. JFatLiq(NXA->NXA_FILIAL, NXA->NXA_CESCR, NXA->NXA_COD) // Indica se a fatura foi liquidada
		F250Cons("SE1", SE1->(Recno()), 2) // Abre a tela de Rastreamento de contas a receber
	Else
		SE1->( AxVisual( "SE1", Recno(), 2 ) ) // Abre a visualização comum do título
	EndIf
Else
	JurMsgErro( STR0081 ) //"Titulo não encontrado para visualização."
EndIf

RestArea( aAreaSE1 )
RestArea( aArea )

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} J204ULTIFA
Função utilizada para verificar se existem mais de uma fatura para mesma 
pré com situação diferente de '2'

@author Felipe Bonvicini Conti
@since 01/04/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204ULTIFA(cFatura, cPrefat, cFatAdic, cFatFixo)
Local lRet := .F.
Local cSQL := ""

cSQL := " SELECT COUNT(NXA.R_E_C_N_O_) QTD "
cSQL += " FROM " + RetSqlname('NXA') + " NXA "
cSQL += " LEFT OUTER JOIN " + RetSqlname('NUF') + " NUF "
cSQL += " ON ( NUF.NUF_FILIAL = '" + xFilial("NUF") + "' "
cSQL +=       " AND NXA.NXA_COD = NUF.NUF_CFATU "
cSQL +=       " AND NXA.NXA_CESCR = NUF.NUF_CESCR "
cSQL +=       " AND NUF.D_E_L_E_T_ = ' ' ) "
cSQL +=   " WHERE NXA.NXA_FILIAL = '" + xFilial("NXA") + "' "
If !Empty( cPrefat )
	cSQL += " AND NXA.NXA_CPREFT = '" + cPrefat + "' "
ElseIf !Empty(cFatAdic)
	cSQL += " AND NXA.NXA_CFTADC = '" + cFatAdic + "' "
ElseIf !Empty( cFatFixo )
	cSQL += " AND NXA.NXA_CFIXO = '" + cFatFixo + "' "
EndIf
cSQL +=     " AND NXA.NXA_COD <> '" + cFatura + "' "
cSQL +=     " AND (NXA.NXA_SITUAC = '1' "
cSQL +=          " OR (NXA_SITUAC = '2' AND NUF.NUF_SITUAC = '1' )) "
cSQL +=     " AND NXA.NXA_TIPO = 'FT' "
cSQL +=     " AND NXA.D_E_L_E_T_ = ' ' "

If JurSQL(cSQL, {"QTD"})[1][1] == 0
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getSeek
Função para trazer a descrição dos campos de pesquisa
@author Clóvis Eduardo Teixeira
@since 11/06/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function getSeek()
Local aSeek    := {}
Local aPesqIdx := {}
Local aPesqOrd := {}
Local nI

AxPesqOrd ("SE1", @aPesqIdx,, .T., @aPesqOrd)
For nI := 1 To 1
	If aPesqIdx[nI][2]
		aAdd( aSeek, { aPesqOrd[nI], {}, aPesqIdx[nI][1], .T.})
	EndIf
Next

Return aSeek

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BxSE1
Verifica e retorna se ocorreram baixas do contas a receber que não foram efetuadas pelo SIGAPFS

@param 	nRecSE1  	Recno do titulo a receber

@Return lRet		.T. Se Achou Baixas fora do SIGAPFS / .F. Caso contrario

@sample lRetorno := J204BxSE1( nRecSE1 )

@author Ricardo Camargo de Mattos
@since 06/01/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function J204BxSE1( nRecSE1 )
Local lRet        := .T.
Local aBaixas     := {}
Local aArea       := GetArea()
Local aAreaSE1    := SE1->( GetArea() )
Local aAreaSE5    := SE5->( GetArea() )
Local cTipBaix    := "VL /V2 /BA /RA /CP /LJ /" + MV_CRNEG

Private aBaixaSE5 := {} //Variavel utilizar pela função SEL070BAIXA

SE1->( Dbsetorder( 1 ) )

SE1->( Dbgoto( nRecSE1 ) )

//-Recupera todas as baixas efetuadas no titulo posicionado
//-Esta função tambem alimenta o array PRIVATE aBaixaSE5
aBaixas := Sel070Baixa( cTipBaix, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, ;
						NIL, NIL, SE1->E1_CLIENTE, SE1->E1_LOJA, NIL, NIL, NIL, NIL, NIL, .T. )

//Verifica se ocorreram baixas nos titulos da fatura DIFERENTES de compensação utilizadas pelo SIGAPFS
If Len( aBaixaSE5 ) > 0
	If ( aScan( aBaixaSE5, { | _x |  _x[ 25 ] <> "CP" } ) > 0 )
		lRet := .T.
	Else
		lRet := .F.
	EndIf

Else

	lRet := .F.

EndIf

RestArea( aArea )
RestArea( aAreaSE1 )
RestArea( aAreaSE5 )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204LegTit
Monta e exibe a legenda da tela de Titulos da Fatura

@param  lBtnLeg, Indica se a legenda está sendo chamada via Botão (.T.),
                 ou via duplo clique na legenda (.F.)

@return aLegTit, Array com a estrutura da legenda

@author Daniel Magalhaes
@since  15/07/2011
/*/
//-------------------------------------------------------------------
Function J204LegTit(lBtnLeg)
Local aCores    := {}
Local aLegTit   := {}
Local aLegPE    := {}
Local cCadastro := STR0075 // "Titulos Financeiro Referentes a Fatura "

AAdd(aLegTit, {'NXA->NXA_SITUAC == "2"'                 , 'BR_AZUL_CLARO', STR0226}) // "Fatura Cancelada"
AAdd(aLegTit, {'E1_SALDO == 0 .AND. E1_TIPOLIQ <> "LIQ"', 'BR_VERMELHO'  , STR0076}) // "Baixado Total"
AAdd(aLegTit, {'E1_SALDO > 0 .AND. E1_SALDO <> E1_VALOR', 'BR_AZUL'      , STR0077}) // "Baixado Parcial"
AAdd(aLegTit, {'E1_SALDO == E1_VALOR'                   , 'BR_VERDE'     , STR0078}) // "Aberto"
AAdd(aLegTit, {'E1_SALDO == 0 .AND. E1_TIPOLIQ == "LIQ"', 'BR_PRETO'     , STR0239}) // "Renegociado"

If Existblock("J204SetLeg") // Ponto de entrada para customização das legendas
	aLegPE := Execblock("J204SetLeg", .F., .F., {aClone(aLegTit)})
	If ValType(aLegPE) == "A" .And. !Empty(aLegPE)
		aLegTit := aClone(aLegPE)
		JurFreeArr(@aLegPE)
	EndIf
EndIf

If lBtnLeg
	AEval(aLegTit, {|aLeg| aAdd( aCores, {aLeg[2], aLeg[3]})})
	BrwLegenda(cCadastro, OemToAnsi(STR0072), aCores) // "Status"
EndIf

Return aLegTit

//-------------------------------------------------------------------
/*/{Protheus.doc} PreValCFat
Pré-Validação para o cancelamento da fatura.

@param  cTipo - Tipo do registro (FT-Fatura/MP-Minuta de Pre/MF-Minuta de Fatura)
@Return lRet

@author Clóvis Eduardo Teixeira
@since 15/07/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PreValCFat(cTipo, lCustom)
Local lRet      := .T.
Default lCustom := .F.

If !lCustom
	JA204CodMot := ""
EndIf

If lCustom .Or. ApMsgYesNo(STR0027) // Deseja cancelar a Fatura selecionada?

	If cTipo == 'FT' .And. SuperGetMV('MV_JMOTCAN',, '2' ) == '1' .AND. Empty(JA204CodMot) // Obrigatoriedade de preenchimento do motivo de encerramento
		If NXA->NXA_NFGER $ '2|3' // 2-Não / 3-Não gerar
			If Existblock("J204MCAN")
				JA204CodMot := ExecBlock( "J204MCAN", .F., .F. )
			Else
				JA204CodMot := JA204MotCan()
			EndIf
		
			If Empty(JA204CodMot)
				lRet := JurMsgErro(STR0110) // A fatura selecionada não foi cancelada.
			EndIf
		EndIf
	EndIf
Else
	lRet := JurMsgErro(STR0110) // A fatura selecionada não foi cancelada.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA204MotCan
Função utilizada para o usuário selecionar o motivo de cancelamento

@author Clóvis Teixeira
@since 02/10/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA204MotCan()
Local cQuery     := ''
Local cCodMot    := ''
Local nI         := 0
Local nAt        := 0
Local cTrab      := GetNextAlias()
Local aCampos    := {}
Local aStru      := {}
Local aAux       := {}
Local aCodMot    := {}
Local cRotina    := 'MotEnc'
Local oBrowse    := Nil
Local oDlg       := Nil
Local oTela      := Nil
Local oPnlBrw    := Nil
Local oPnlRoda   := Nil
Local oBtnOk     := Nil
Local oBtnCancel := Nil
Local cIdBrowse  := ''
Local cIdRodape  := ''
Local lObfuscate := FindFunction("FwPDCanUse") .And. FwPDCanUse(.T.) // Indica se trabalha com Dados Protegidos e possui a melhoria de ofuscação de dados habilitada
Local aColumns   := {}

cQuery += " SELECT NSA_COD, NSA_DESC "
cQuery += " FROM " + RetSqlName("NSA")
cQuery += " WHERE NSA_FILIAL  = '" + xFilial("NSA") + "'"
cQuery += " AND D_E_L_E_T_  = ' '"

Define MsDialog oDlg FROM 0, 0 To 400, 600 Title STR0117 Pixel style  nOR( WS_VISIBLE, DS_MODALFRAME)

	nAt := aScan(aCodMot, {|aX| aX[1] == PadR( cRotina, 10 ) } )

	oTela     := FWFormContainer():New( oDlg )
	cIdBrowse := oTela:CreateHorizontalBox( 84 )
	cIdRodape := oTela:CreateHorizontalBox( 16 )
	oTela:Activate( oDlg, .F. )
	oPnlBrw   := oTela:GeTPanel( cIdBrowse )
	oPnlRoda  := oTela:GeTPanel( cIdRodape )

	If !Empty( cRotina )
		If nAt == 0
			aAdd( aCodMot, { PadR( cRotina, 10 ), cQuery, {} } )
		Else
			cQuery := aCodMot[nAt][2]
		EndIf
	EndIf

	Define FWBrowse oBrowse DATA QUERY ALIAS cTrab QUERY cQuery DOUBLECLICK {|| cCodMot := AllTrim((cTrab)->(FieldGet(1))), oDlg:End()} NO LOCATE Of oPnlBrw

	If !Empty( cRotina )
		If nAt == 0
			aStru := ( cTrab )->( dbStruct())
			For nI := 1 To Len( aStru )
				aAux    := {}
				aAdd( aAux, aStru[nI][1] )
				If AvSX3( aStru[nI][1],, cTrab, .T. )
					aAdd( aAux, RetTitle( aStru[nI][1] ) )
					aAdd( aAux, AvSX3( aStru[nI][1], 6, cTrab ) )
				Else
					aAdd( aAux, aStru[nI][1] )
					aAdd( aAux, '' )
				EndIf
				aAdd( aCampos, aAux )
			Next
			If !Empty( cRotina )
				aCodMot[Len( aCodMot ) ][3] := aCampos
			EndIf
		Else
			aCampos := aClone( aCodMot[nAt][3] )
		EndIf
	EndIf

	// Adiciona as colunas do Browse
	For nI := 1 To Len( aCampos )
		AAdd( aColumns, FWBrwColumn():New() )
		aColumns[nI]:SetData(&( '{ || ' + aCampos[nI][1] + ' }' ))
		aColumns[nI]:SetTitle( aCampos[nI][2] )
		aColumns[nI]:SetPicture( aCampos[nI][3] )
		If lObfuscate
			aColumns[nI]:SetObfuscateCol( Empty(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, {aCampos[nI][1]})) )
		EndIf
	Next

	oBrowse:SetColumns(aColumns)
	Activate FWBrowse oBrowse

	//Botão Ok
	@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + 221 Button oBtnOk  Prompt STR0169;   //# 'Ok'
	  Size 30 , 12 Of oPnlRoda Pixel Action ( cCodMot := AllTrim((cTrab)->(FieldGet(1))), oDlg:End())

	//Botão Cancelar
	@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + 263 Button oBtnCancel Prompt STR0018;  //# 'Cancelar'
	  Size 30 , 12 Of oPnlRoda Pixel Action ( oDlg:End() )

Activate MsDialog oDlg Centered

Return cCodMot

//-------------------------------------------------------------------
/*/{Protheus.doc} JA204BxSe1()
monta o array dos títulos para fazer os extornos, das baixas feitas pelo SIGAPFS

@Return lRet
@author Tiago Martins
@since 20/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA204BxSe1()
Local lRet := .T.
Local aSE1 := {}

aSE1 := J204Baixas()

If Empty (aSE1)
	lRet := .T.
Else
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204Baixas()
Monta o array dos títulos para fazer os estornos das baixas feitas pelo SIGAPFS

@Return lRet
@author Tiago Martins
@since 20/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function J204Baixas()
Local cFil       := ""
Local cQuery     := ""
Local cStaBx     := "N"
Local cAliasSE1  := GetNextAlias()
Local aSE1       := {}
Local aArea      := GetArea()
Local aAreaSE1   := SE1->( GetArea() )
Local cFilAtu    := cFilAnt

//Recupera a filial de acordo com o escritorio da fatura
cFil := JurGetDados("NS7", 1, xFilial("NS7") + NXA->NXA_CESCR, "NS7_CFILIA")

cFilAnt := cFil

// Retorna os titulos da fatura
cQuery := JA204Query( 'TI', xFilial( 'NXA' ), NXA->NXA_COD, NXA->NXA_CESCR, cFil )
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasSE1, .T., .T. )
SE1->( DbSetOrder( 1 ) )

(cAliasSE1)->( DbGoTop() )

Do While ! (cAliasSE1)->( Eof() )
	If J204BxSE1( (cAliasSE1)->SE1RECNO )
		cStaBx := "S"
	Else
		cStaBx := "N"
	EndIf
	Aadd( aSE1, { (cAliasSE1)->SE1RECNO, cStaBx } ) // Armazena o RECNO do titulo e o STATUS de encontro de baixas que ocorreram
	(cAliasSE1)->( dbSkip() )
EndDo
(cAliasSE1)->( dbcloseArea() )

cFilAnt := cFilAtu

RestArea( aArea )
RestArea( aAreaSE1 )

Return aSE1

//-------------------------------------------------------------------
/*/ {Protheus.doc} J204LdLanc()
Faz a carga manual dos dados nos grids dos lançamentos

@Param cAliasTb   Alias da tabela do lançamento. Ex: "NUE"
@Param oGrid      Objeto do grid da tabela do lançamento.
@Param DefCampos  String de Campos da tabela do lançamento.

@author Luciano Pereira dos Santos
@since 24/07/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204LdLanc(cAliasTb ,oGrid, DefCampos)
Local aStrucXXX := oGrid:oFormModelStruct:GetFields()
Local aArea     := GetArea()
Local aAreaNT1  := NT1->( GetArea() )
Local aAreaNUE  := NUE->( GetArea() )
Local aAreaNVY  := NVY->( GetArea() )
Local aAreaNV4  := NV4->( GetArea() )
Local aAreaNVV  := NVV->( GetArea() )
Local nX        := 0
Local nY        := 0
Local aCampos   := StrTokArr(DefCampos, "|")
Local cQuery    := ""
Local cQryNXX   := GetNextAlias()
Local aAux      := {}
Local aGrid     := {}
Local aLinha    := {}
Local cFatura   := FwFldGet('NXA_COD')
Local cEstcrit  := FwFldGet('NXA_CESCR')
Local cSituac   := FwFldGet('NXA_SITUAC')
Local cContrat  := FwFldGet('NXB_CCONTR')
Local cCaso     := FwFldGet('NXC_CCASO')
Local cCliente  := FwFldGet('NXC_CCLIEN')
Local cLoja     := FwFldGet('NXC_CLOJA')
Local cPreFat   := FwFldGet('NXA_CPREFT')
Local nFor      := 0
Local nRecno    := 0
Local cDescri   := ""
Local cJcaso    := SuperGetMV("MV_JCASO1",, '1')  //1 – Por Cliente; 2 – Independente de cliente
Local lVigencia := JA204Vig(cPreFat, cContrat)
Local lCpoTit   := NXM->(ColumnPos("NXM_TITNUM")) > 0 //@12.1.33
Local cSqlTit   := IIF(lCpoTit, ", NXM.NXM_FILTIT, NXM.NXM_PREFIX, NXM.NXM_TITNUM, NXM.NXM_TITPAR, NXM.NXM_TITTPO", "")

Do Case
Case cAliasTb == "NT1" // fixo

	If !Empty(CPOUSRNT1)
		aAux := J204ValCpUsr(StrTokArr(CPOUSRNT1, "|"), aCampos)
	EndIf

	cQuery := "SELECT NT1.NT1_PARC,"
	cQuery += " NT1.NT1_DATAIN,"
	cQuery += " NT1.NT1_DATAFI,"
	cQuery += " '' NT1_DESCRI," //campo memo
	cQuery += " NT1.NT1_CMOEDA,"
	cQuery += " CTO.CTO_SIMB NT1_DMOEDA,"
	cQuery += " NT1.NT1_VALORB,"
	cQuery += " NT1.NT1_VALORA,"
	cQuery += " NT1.NT1_DATAAT,"
	cQuery += " NWE.NWE_COTAC1 NT1_COTAC1,"
	cQuery += " NWE.NWE_COTAC2 NT1_COTAC2,"
	cQuery += " NT1.NT1_CCONTR,"
	cQuery += " NT0.NT0_NOME NT1_DCONTR,"
	For nFor := 1 To Len(aAux)
		cQuery += " " + aAux[nFor] + ","
	Next nFor
	cQuery += " NT1.R_E_C_N_O_ RECNO "
	cQuery += " FROM "+ RetSqlName("NXA") +" NXA,"
	cQuery +=       " "+ RetSqlName("NXB") +" NXB,"
	cQuery +=       " "+ RetSqlName("NT1") +" NT1,"
	cQuery +=       " "+ RetSqlName("NWE") +" NWE,"
	cQuery +=       " "+ RetSqlName("NT0") +" NT0,"
	cQuery +=       " "+ RetSqlName("CTO") +" CTO "
	cQuery += " WHERE NXA.NXA_FILIAL = '" + xFilial("NXA") +"'"
	cQuery += " AND NXB.NXB_FILIAL = '" + xFilial("NXB") +"'"
	cQuery += " AND NT1.NT1_FILIAL = '" + xFilial("NT1") +"'"
	cQuery += " AND NWE.NWE_FILIAL = '" + xFilial("NWE") +"'"
	cQuery += " AND NT0.NT0_FILIAL = '" + xFilial("NT0") +"'"
	cQuery += " AND CTO.CTO_FILIAL = '" + xFilial("CTO") +"'"
	cQuery += " AND NXA.NXA_COD = '"+ cFatura +"'"
	cQuery += " AND NXA.NXA_CESCR = '"+ cEstcrit +"'"
	cQuery += " AND NXB.NXB_CESCR = NXA.NXA_CESCR"
	cQuery += " AND NXB.NXB_CFATUR = NXA.NXA_COD"
	cQuery += " AND NXB.NXB_CCONTR = '"+ cContrat +"'"
	cQuery += " AND NWE.NWE_CFATUR = NXB.NXB_CFATUR"
	cQuery += " AND NWE.NWE_CESCR = NXB.NXB_CESCR"
	cQuery += " AND NWE.NWE_CFATUR = NXB.NXB_CFATUR"
	cQuery += " AND NWE.NWE_SITUAC = '2'"
	cQuery += " AND NWE.NWE_CFIXO = NT1.NT1_SEQUEN"
	cQuery += " AND NT1.NT1_CCONTR = NXB.NXB_CCONTR"
	cQuery += " AND NT0.NT0_COD = NT1.NT1_CCONTR"
	cQuery += " AND CTO.CTO_MOEDA = NT1.NT1_CMOEDA"
	cQuery += " AND NXA.D_E_L_E_T_ = ' '"
	cQuery += " AND NXB.D_E_L_E_T_ = ' '"
	cQuery += " AND NWE.D_E_L_E_T_ = ' '"
	cQuery += " AND NT1.D_E_L_E_T_ = ' '"
	cQuery += " AND NT0.D_E_L_E_T_ = ' '"
	cQuery += " AND CTO.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY NT1.NT1_DATAVE,"
	cQuery += " NT1.NT1_SEQUEN"

Case cAliasTb == "NUE" // time-sheet
	If !Empty(CPOUSRNUE)
		aAux := J204ValCpUsr(StrTokArr(CPOUSRNUE, "|"), aCampos)
	EndIf

	cQuery := " select"
	cQuery += " NUE.NUE_COD,"
	cQuery += " NUE.NUE_DATATS,"
	cQuery += " RD01.RD0_SIGLA as NUE_SIGLA1,"
	cQuery += " RD01.RD0_NOME as NUE_DPART1,"
	cQuery += " RD02.RD0_SIGLA as NUE_SIGLA2,"
	cQuery += " RD02.RD0_NOME as NUE_DPART2,"
	cQuery += " NUE.NUE_CATIVI,"
	cQuery += " NRC.NRC_DESC as NUE_DATIVI,"
	cQuery += " NUE.NUE_COBRAR,"
	cQuery += " NUE.NUE_UTL,"
	cQuery += " NUE.NUE_UTR,"
	cQuery += " NUE.NUE_HORAL,"
	cQuery += " NUE.NUE_HORAR,"
	cQuery += " NUE.NUE_TEMPOL,"
	cQuery += " NUE.NUE_TEMPOR,"
	cQuery += " '' NUE_DESC,"   //campo memo
	cQuery += " NUE.NUE_CMOEDA,"
	cQuery += " CTO.CTO_SIMB as NUE_DMOEDA,"
	cQuery += " NUE.NUE_VALORH,"
	cQuery += " NUE.NUE_VALOR,"
	cQuery += " NUE.NUE_VALOR1,"
	cQuery += " NW0.NW0_COTAC1 NUE_COTAC1,"
	cQuery += " NW0.NW0_COTAC2 NUE_COTAC2,"
	cQuery += " NUE.NUE_CCASO,"
	cQuery += " NVE.NVE_TITULO as NUE_DCASO,"
	cQuery += " NUE.NUE_CCLIEN,"
	cQuery += " NUE.NUE_CLOJA,"
	cQuery += " NUE_CLTAB,"
	cQuery += " '' NUE_DLTAB,"
	cQuery += " SA1.A1_NOME as NUE_DCLIEN,"
	For nFor := 1 To Len(aAux)
		cQuery += " " + aAux[nFor] + ","
	Next nFor
	cQuery += " NUE.R_E_C_N_O_ as RECNO, coalesce(NV4.R_E_C_N_O_, 0) RECNONV4"
	cQuery += " from "+ RetSqlName("NXC") +" NXC"
	cQuery += " inner join "+ RetSqlName("NW0") +" NW0"
	cQuery += " on(NW0.NW0_FILIAL = '" + xFilial("NW0") +"'"
	cQuery +=     " and NW0.NW0_CFATUR = NXC.NXC_CFATUR"
	cQuery +=     " and NW0.NW0_CESCR = NXC.NXC_CESCR"
	If cSituac == "1" // Somente para pendentes - Isso é necesário para exibir os registros em faturas canceladas
		cQuery +=     " and NW0.NW0_CANC = '2'"
	EndIf
	cQuery +=     " and NW0.NW0_SITUAC = '2'"
	cQuery +=     " and NW0.D_E_L_E_T_ = ' ')"
	cQuery += " inner join " + RetSqlName("NT0") + " NT0"
	cQuery += " on (NT0.NT0_FILIAL = '" + xFilial("NT0") + "'"
	cQuery += "     and NT0.NT0_COD = '" + cContrat + "'"
	cQuery += "     and NT0.D_E_L_E_T_ = ' ')"
	cQuery += " inner join "+ RetSqlName("NUE") +" NUE"
	cQuery += " on(NUE.NUE_FILIAL = '" + xFilial("NUE") +"'"
	cQuery +=     " and NUE.NUE_COD = NW0.NW0_CTS"
	cQuery +=     " and NUE.NUE_CCASO = NXC.NXC_CCASO"
	cQuery +=     " and NUE.NUE_CCLIEN = NXC.NXC_CCLIEN"
	cQuery +=     " and NUE.NUE_CLOJA = NXC.NXC_CLOJA"
	If lVigencia
		cQuery += " and NUE.NUE_DATATS between NT0.NT0_DTVIGI and NT0.NT0_DTVIGF"
	EndIf
	cQuery +=     " and NUE.D_E_L_E_T_ = ' ')"
	cQuery += " left outer join " + RetSqlName("NV4") + " NV4"
	cQuery += " on(NV4.NV4_FILIAL  = '" + xFilial("NV4") + "'"
	cQuery +=     " and NV4.NV4_COD = NUE.NUE_CLTAB"
	cQuery +=     " and NV4.D_E_L_E_T_ = ' ')"
	cQuery += " left outer join "+ RetSqlName("CTO") +" CTO"
	cQuery += " on(CTO.CTO_FILIAL = '" + xFilial("CTO") +"'"
	cQuery +=     " and CTO.CTO_MOEDA = NUE.NUE_CMOEDA"
	cQuery +=     " and CTO.D_E_L_E_T_ = ' ')"
	cQuery += " inner join "+ RetSqlName("RD0") +" RD01"
	cQuery += " on(RD01.RD0_FILIAL = '" + xFilial("RD0") +"'"
	cQuery +=      " and RD01.RD0_CODIGO = NUE.NUE_CPART1"
	cQuery +=      " and RD01.D_E_L_E_T_ = ' ')"
	cQuery += " inner join "+ RetSqlName("RD0") +" RD02"
	cQuery += " on(RD02.RD0_FILIAL = '" + xFilial("RD0") +"'"
	cQuery +=      " and RD02.RD0_CODIGO = NUE.NUE_CPART2"
	cQuery +=      " and RD02.D_E_L_E_T_ = ' ')"
	cQuery += " inner join "+ RetSqlName("NVE") +" NVE"
	cQuery += " on(NVE.NVE_FILIAL = '" + xFilial("NVE") +"'"
	cQuery +=      " and NVE.NVE_NUMCAS = NUE.NUE_CCASO"
	cQuery +=      " and NVE.NVE_CCLIEN = NUE.NUE_CCLIEN"
	cQuery +=      " and NVE.NVE_LCLIEN = NUE.NUE_CLOJA"
	cQuery +=      " and NVE.D_E_L_E_T_ = ' ')"
	cQuery += " inner join "+ RetSqlName("SA1") +" SA1"
	cQuery += " on(SA1.A1_FILIAL = '" + xFilial("SA1") +"'"
	cQuery +=     " and SA1.A1_COD = NUE.NUE_CCLIEN"
	cQuery +=     " and SA1.A1_LOJA = NUE.NUE_CLOJA"
	cQuery +=     " and SA1.D_E_L_E_T_ = ' ')"
	cQuery += " inner join "+ RetSqlName("NRC") +" NRC"
	cQuery += " on(NRC.NRC_FILIAL = '" + xFilial("NRC") +"'"
	cQuery +=     " and NRC.NRC_COD = NUE.NUE_CATIVI"
	cQuery +=     " and NRC.D_E_L_E_T_ = ' ')"
	cQuery += " where NXC.NXC_FILIAL = '" + xFilial("NXC") +"'"
	cQuery +=   " and NXC.NXC_CFATUR = '"+ cFatura +"'"
	cQuery +=   " and NXC.NXC_CESCR = '"+ cEstcrit +"'"
	cQuery +=   " and NXC.NXC_CCONTR = '"+ cContrat +"'"
	cQuery +=   " and NXC.NXC_CCASO = '"+ cCaso +"'"
	cQuery +=   " and NXC.NXC_CCLIEN = '"+ cCliente +"'"
	cQuery +=   " and NXC.NXC_CLOJA = '"+ cLoja +"'"
	cQuery +=   " and NXC.D_E_L_E_T_ = ' '"
	cQuery += " order by"
	If cJcaso == '1'
		cQuery += " NUE.NUE_CCLIEN,"
		cQuery += " NUE.NUE_CLOJA,"
	EndIf
	cQuery += " NUE.NUE_CCASO,"
	cQuery += " NUE.NUE_DATATS,"
	cQuery += " NUE.NUE_COD"

Case cAliasTb == "NVY" //Despesa
	If !Empty(CPOUSRNVY)
		aAux := J204ValCpUsr(StrTokArr(CPOUSRNVY, "|"), aCampos)
	EndIf

	cQuery := " select"
	cQuery += " NVY.NVY_COD,"
	cQuery += " NVY.NVY_DATA,"
	cQuery += " NVY.NVY_CTPDSP,"
	cQuery += " NRH.NRH_DESC NVY_DTPDSP,"
	cQuery += " '' NVY_DESCRI,"  //campo memo
	cQuery += " NVY.NVY_COBRAR,"
	cQuery += " NVY.NVY_CMOEDA,"
	cQuery += " NVZ.NVZ_COTAC1 NVY_COTAC1,"
	cQuery += " NVZ.NVZ_COTAC2 NVY_COTAC2,"
	cQuery += " CTO.CTO_SIMB NVY_DMOEDA,"
	cQuery += " NVY.NVY_VALOR,"
	cQuery += " NVY.NVY_CCASO,"
	cQuery += " NVE.NVE_TITULO NVZ_DCASO,"
	cQuery += " NVY.NVY_CLOJA,"
	cQuery += " SA1.A1_NOME NVY_DCLIEN,"
	cQuery += " NVY.NVY_CCLIEN,"
	For nFor := 1 To Len(aAux)
		cQuery += " " + aAux[nFor] + ","
	Next nFor
	cQuery += " NVY.R_E_C_N_O_ as RECNO"
	cQuery += " from " + RetSqlName("NXC") + " NXC"
	cQuery += " inner join " + RetSqlName("NT0") + " NT0"
    cQuery += " on (NT0.NT0_FILIAL = '" + xFilial("NT0") + "'"
	cQuery += "     and NT0.NT0_COD = '" + cContrat + "'"
	cQuery += "     and NT0.D_E_L_E_T_ = ' ')"
	cQuery += " inner join " + RetSqlName("NVY") + " NVY"
	cQuery += " on(NVY.NVY_FILIAL = '" + xFilial("NVY") + "'"
	cQuery +=     " and NVY.NVY_CCASO = NXC.NXC_CCASO"
	cQuery +=     " and NVY.NVY_CCLIEN = NXC.NXC_CCLIEN"
	cQuery +=     " and NVY.NVY_CLOJA = NXC.NXC_CLOJA"
	If lVigencia
		cQuery += " and NVY.NVY_DATA between NT0.NT0_DTVIGI and NT0.NT0_DTVIGF"
	EndIf
	cQuery +=     " and NVY.D_E_L_E_T_ = ' ')"
	cQuery += " inner join " + RetSqlName("NVZ") + " NVZ"
	cQuery += " on(NVZ.NVZ_FILIAL = '" + xFilial("NVZ") + "'"
	cQuery +=     " and NVZ.NVZ_CDESP = NVY.NVY_COD"
	cQuery +=     " and NVZ.NVZ_CFATUR = NXC.NXC_CFATUR"
	cQuery +=     " and NVZ.NVZ_CESCR = NXC.NXC_CESCR"
	cQuery +=     " and NVZ.NVZ_SITUAC = '2'"
	cQuery +=     " and NVZ.D_E_L_E_T_ = ' ')"
	cQuery += " inner join " + RetSqlName("CTO") + " CTO"
	cQuery += " on(CTO.CTO_FILIAL = '" + xFilial("CTO") + "'"
	cQuery +=     " and CTO.CTO_MOEDA = NVY.NVY_CMOEDA"
	cQuery +=     " and CTO.D_E_L_E_T_ = ' ')"
	cQuery += " inner join " + RetSqlName("NRH") + " NRH"
	cQuery += " on(NRH.NRH_FILIAL = '" + xFilial("NRH") + "'"
	cQuery +=     " and NRH.NRH_COD = NVY.NVY_CTPDSP"
	cQuery +=     " and NRH.D_E_L_E_T_ = ' ')"
	cQuery += " inner join " + RetSqlName("NVE") + " NVE"
	cQuery += " on(NVE.NVE_FILIAL = '" + xFilial("NVE") + "'"
	cQuery +=     " and NVE.NVE_NUMCAS = NVY.NVY_CCASO"
	cQuery +=     " and NVE.NVE_CCLIEN = NVY.NVY_CCLIEN"
	cQuery +=     " and NVE.NVE_LCLIEN = NVY.NVY_CLOJA"
	cQuery +=     " and NVE.D_E_L_E_T_ = ' ')"
	cQuery += " inner join " + RetSqlName("SA1") + " SA1"
	cQuery += " on(SA1.A1_FILIAL = '" + xFilial("SA1") + "'"
	cQuery +=     " and SA1.A1_COD = NVY.NVY_CCLIEN"
	cQuery +=     " and SA1.A1_LOJA = NVY.NVY_CLOJA"
	cQuery +=     " and SA1.D_E_L_E_T_ = ' ')"
	cQuery += " where NXC.NXC_FILIAL = '" + xFilial("NXC") +"'"
	cQuery +=   " and NXC.NXC_CFATUR = '"+ cFatura +"'"
	cQuery +=   " and NXC.NXC_CESCR = '"+ cEstcrit +"'"
	cQuery +=   " and NXC.NXC_CCONTR = '"+ cContrat +"'"
	cQuery +=   " and NXC.NXC_CCASO = '"+ cCaso +"'"
	cQuery +=   " and NXC.NXC_CCLIEN = '"+ cCliente +"'"
	cQuery +=   " and NXC.NXC_CLOJA = '"+ cLoja +"'"
	cQuery +=   " and NXC.D_E_L_E_T_ = ' '"
	cQuery += " order  by"
	If cJcaso == '1'
		cQuery += " NVY.NVY_CCLIEN,"
		cQuery += " NVY.NVY_CLOJA,"
	EndIf
	cQuery += " NVY.NVY_CCASO,"
	cQuery += " NVY.NVY_DATA,"
	cQuery += " NVY.NVY_COD"

Case cAliasTb == "NV4" //Lançamento tabelado
	If !Empty(CPOUSRNV4)
		aAux := J204ValCpUsr(StrTokArr(CPOUSRNV4, "|"), aCampos)
	EndIf

	cQuery := " select"
	cQuery += " NV4.NV4_COD,"
	cQuery += " NV4.NV4_DTLANC,"
	cQuery += " NV4.NV4_CTPSRV,"
	cQuery += " NR3.NR3_DESCHO as NV4_DTPSRV,"
	cQuery += " '' NV4_DESCRI,"   //campo memo
	cQuery += " NV4.NV4_COBRAR,"
	cQuery += " NV4.NV4_CMOEH,"
	cQuery += " CTOH.CTO_SIMB as NV4_DMOEH,"
	cQuery += " NV4.NV4_VLHFAT,"
	cQuery += " NV4.NV4_VLHTAB,"
	cQuery += " NV4.NV4_CMOED,"
	cQuery += " coalesce(CTOD.CTO_SIMB, '') as NV4_DMOED,"
	cQuery += " NV4.NV4_VLDFAT,"
	cQuery += " NV4.NV4_VLDTAB,"
	cQuery += " NW4.NW4_COTAC1 NV4_COTAC1,"
	cQuery += " NW4.NW4_COTAC2 NV4_COTAC2,"
	cQuery += " NV4.NV4_CCASO,"
	cQuery += " NVE.NVE_TITULO as NV4_DCASO,"
	For nFor := 1 To Len(aAux)
		cQuery += " " + aAux[nFor] + ","
	Next nFor
	cQuery += " NV4.R_E_C_N_O_ as RECNO"
	cQuery += " from " + RetSqlName("NXC") + " NXC"
	cQuery += " inner join " + RetSqlName("NT0") + " NT0"
    cQuery += " on (NT0.NT0_FILIAL = '" + xFilial("NT0") + "'"
	cQuery += "     and NT0.NT0_COD = '" + cContrat + "'"
	cQuery += "     and NT0.D_E_L_E_T_ = ' ')"
	cQuery += " inner join " + RetSqlName("NV4") + " NV4"	
	cQuery += " on(NV4.NV4_FILIAL = '" + xFilial("NV4") + "'"
	cQuery +=     " and NXC.NXC_CCASO = NV4.NV4_CCASO"
	cQuery +=     " and NXC.NXC_CCLIEN = NV4.NV4_CCLIEN"
	cQuery +=     " and NXC.NXC_CLOJA = NV4.NV4_CLOJA"
	If lVigencia
		cQuery += " and NV4.NV4_DTCONC between NT0.NT0_DTVIGI and NT0.NT0_DTVIGF"
	EndIf
	cQuery +=     " and NV4.D_E_L_E_T_ = ' ')"
	cQuery += " inner join " + RetSqlName("NW4") + " NW4"
	cQuery += " on(NW4.NW4_FILIAL = '" + xFilial("NW4") + "'"
	cQuery +=     " and NW4.NW4_CFATUR = NXC.NXC_CFATUR"
	cQuery +=     " and NW4.NW4_CESCR = NXC.NXC_CESCR"
	cQuery +=     " and NW4.NW4_SITUAC = '2'"
	cQuery +=     " and NW4.NW4_CLTAB = NV4.NV4_COD"
	cQuery +=     " and NW4.D_E_L_E_T_ = ' ')"
	cQuery += " inner join " + RetSqlName("CTO") + " CTOH"
	cQuery += " on(CTOH.CTO_FILIAL = '" + xFilial("CTO") + "'"
	cQuery +=     " and CTOH.CTO_MOEDA = NV4.NV4_CMOEH"
	cQuery +=     " and CTOH.D_E_L_E_T_ = ' ')"
	cQuery += " left outer join " + RetSqlName("CTO") + " CTOD"
	cQuery += " on(CTOD.CTO_FILIAL = '" + xFilial("CTO") + "'"
	cQuery +=     " and CTOD.CTO_MOEDA = NV4.NV4_CMOED"
	cQuery +=     " and CTOD.D_E_L_E_T_ = ' ')"
	cQuery += " inner join " + RetSqlName("NVE") + " NVE"
	cQuery += " on(NVE.NVE_FILIAL = '" + xFilial("NVE") + "'"
	cQuery +=     " and NVE.NVE_CCLIEN = NV4.NV4_CCLIEN"
	cQuery +=     " and NVE.NVE_LCLIEN = NV4.NV4_CLOJA"
	cQuery +=     " and NVE.NVE_NUMCAS = NV4.NV4_CCASO"
	cQuery +=     " and NVE.D_E_L_E_T_ = ' ')"
	cQuery += " inner join " + RetSqlName("NR3") + " NR3"
	cQuery += " on(NR3.NR3_FILIAL = '" + xFilial("NR3") + "'"
	cQuery +=     " and NR3.NR3_CIDIOM = NVE.NVE_CIDIO"
	cQuery +=     " and NR3.NR3_CITABE = NV4.NV4_CTPSRV"
	cQuery +=     " and NR3.D_E_L_E_T_ = ' ')"
	cQuery += " inner join " + RetSqlName("SA1") + " SA1"
	cQuery += " on(SA1.A1_FILIAL = '" + xFilial("SA1") + "'"
	cQuery +=     " and SA1.A1_COD = NV4.NV4_CCLIEN"
	cQuery +=     " and SA1.A1_LOJA = NV4.NV4_CLOJA"
	cQuery +=     " and SA1.D_E_L_E_T_ = ' ')"
	cQuery += " where NXC.NXC_FILIAL = '" + xFilial("NXC") +"'"
	cQuery +=   " and NXC.NXC_CFATUR = '"+ cFatura +"'"
	cQuery +=   " and NXC.NXC_CESCR = '"+ cEstcrit +"'"
	cQuery +=   " and NXC.NXC_CCONTR = '"+ cContrat +"'"
	cQuery +=   " and NXC.NXC_CCASO = '"+ cCaso +"'"
	cQuery +=   " and NXC.NXC_CCLIEN = '"+ cCliente +"'"
	cQuery +=   " and NXC.NXC_CLOJA = '"+ cLoja +"'"
	cQuery +=   " and NXC.D_E_L_E_T_ = ' '"
	cQuery += " order by"
	If cJcaso == '1'
		cQuery += " NV4.NV4_CCLIEN,"
		cQuery += " NV4.NV4_CLOJA,"
	EndIf
	cQuery += " NV4.NV4_CCASO,"
	cQuery += " NV4.NV4_DTLANC,"
	cQuery += " NV4.NV4_COD"

Case cAliasTb == "NVV" // Fatura Adicional
	If !Empty(CPOUSRNVV)
		aAux := J204ValCpUsr(StrTokArr(CPOUSRNVV, "|"), aCampos)
	EndIf

	cQuery := " SELECT NVV_COD, "
	//Time-Sheet
	cQuery += " NVV_DTINIH, NVV_DTFIMH, NVV_CMOE1,"
	cQuery += " COALESCE((SELECT CTO_SIMB FROM "+ RetSqlName("CTO") +" WHERE CTO_MOEDA = NVV.NVV_CMOE1 AND D_E_L_E_T_ = ' ' AND CTO_FILIAL = '" + xFilial("CTO") +"'),'') NVV_DMOE1,"
	cQuery += " NVV_VALORH,"
	//Tabelado
	cQuery += " NVV_DTINIT,NVV_DTFIMT,NVV_CMOE4,"
	cQuery += " COALESCE((SELECT CTO_SIMB FROM "+ RetSqlName("CTO") +" WHERE CTO_MOEDA = NVV.NVV_CMOE4 AND D_E_L_E_T_ = ' ' AND CTO_FILIAL = '" + xFilial("CTO") +"'),'') NVV_DMOE4,"
	cQuery += " NVV_VALORT,"
	//Despesa
	cQuery += " NVV_DTINID, NVV_DTFIMD, NVV_CMOE2,"
	cQuery += " COALESCE((SELECT CTO_SIMB FROM "+ RetSqlName("CTO") +" WHERE CTO_MOEDA = NVV.NVV_CMOE2 AND D_E_L_E_T_ = ' ' AND CTO_FILIAL = '" + xFilial("CTO") +"'),'') NVV_DMOE2,"
	cQuery += " NVV_VALORD,"

	cQuery += " NVV_CCONTR,NT0.NT0_NOME NVV_DCONTR,"
	cQuery += " NVV_CCLIEN, NVV_CLOJA, SA1.A1_NOME NVV_DCLIEN,"
	For nFor := 1 To Len(aAux)
		cQuery += " " + aAux[nFor] + ","
	Next nFor
	cQuery += " NVV.R_E_C_N_O_ RECNO"

	cQuery += " FROM "+ RetSqlName("NXA") +" NXA,"
	cQuery += " "+ RetSqlName("NVV") +" NVV,"
	cQuery += " "+ RetSqlName("NWD") +" NWD,"
	cQuery += " "+ RetSqlName("NT0") +" NT0,"
	cQuery += " "+ RetSqlName("SA1") +" SA1"
	cQuery += " WHERE NXA.NXA_FILIAL = '" + xFilial("NXA") +"'"
	cQuery += " AND NWD.NWD_FILIAL = '" + xFilial("NWD") +"'"
	cQuery += " AND NVV.NVV_FILIAL = '" + xFilial("NVV") +"'"
	cQuery += " AND NT0.NT0_FILIAL = '" + xFilial("NT0") +"'"
	cQuery += " AND SA1.A1_FILIAL = '" + xFilial("SA1") +"'"
	cQuery += " AND NWD.NWD_CFTADC = NVV.NVV_COD"
	cQuery += " AND NWD.NWD_SITUAC = '2'"
	cQuery += " AND NXA.NXA_COD = NWD.NWD_CFATUR"
	cQuery += " AND NXA.NXA_CESCR = NWD.NWD_CESCR"
	cQuery += " AND NXA.NXA_COD = '"+cFatura+"'"
	cQuery += " AND NXA.NXA_CESCR = '"+cEstcrit+"'"
	cQuery += " AND NT0.NT0_COD = NVV.NVV_CCONTR"
	cQuery += " AND SA1.A1_COD = NVV.NVV_CCLIEN"
	cQuery += " AND SA1.A1_LOJA = NVV.NVV_CLOJA"
	cQuery += " AND NVV.D_E_L_E_T_ = ' '"
	cQuery += " AND NWD.D_E_L_E_T_ = ' '"
	cQuery += " AND NXA.D_E_L_E_T_ = ' '"
	cQuery += " AND NVV.D_E_L_E_T_ = ' '"
	cQuery += " AND SA1.D_E_L_E_T_ = ' '"
	cQuery += " AND NT0.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY NVV.NVV_PARC"

Case cAliasTb == "NXM" // Docs Relacionados

	If !FWAliasInDic("OHT") .Or. !FwIsInCallStack("J243SE1Opt") // Cobrança
		aGrid := FormLoadGrid(oGrid)
	Else

		cQuery :=    "SELECT NXM.NXM_NOMARQ, NXM.NXM_EMAIL, NXM.NXM_ORDEM, NXM.NXM_CESCR, NXM.NXM_CFATUR, NXM.NXM_CTIPO, NXM.NXM_NOMORI, NXM.NXM_CPATH, NXM.NXM_CTPARQ, NXM.R_E_C_N_O_ RECNO "
		cQuery +=            cSqlTit
		cQuery +=     " FROM " + RetSqlName("NXM") + " NXM "
		cQuery +=    " INNER JOIN " + RetSqlName("OHT") + " OHT "
		cQuery +=       " ON OHT.OHT_FILTIT = '" + SE1->E1_FILIAL  + "' "
		cQuery +=      " AND OHT.OHT_PREFIX = '" + SE1->E1_PREFIXO + "' "
		cQuery +=      " AND OHT.OHT_TITNUM = '" + SE1->E1_NUM     + "' "
		cQuery +=      " AND OHT.OHT_TITPAR = '" + SE1->E1_PARCELA + "' "
		cQuery +=      " AND OHT.OHT_TITTPO = '" + SE1->E1_TIPO    + "' "
		cQuery +=      " AND OHT.OHT_FILFAT = NXM.NXM_FILIAL "
		cQuery +=      " AND OHT.OHT_FTESCR = NXM.NXM_CESCR "
		cQuery +=      " AND OHT.OHT_CFATUR = NXM.NXM_CFATUR "
		cQuery +=      " AND OHT.OHT_FILIAL = '" + xFilial("OHT") + "' "
		cQuery +=      " AND OHT.D_E_L_E_T_ = ' ' "
		cQuery +=    " WHERE NXM.NXM_FILIAL = '" + xFilial("NXM") + "' "
		cQuery +=      " AND NXM.D_E_L_E_T_ = ' ' "
		If lCpoTit
			cQuery += "UNION " 
			cQuery += "SELECT NXM.NXM_NOMARQ, NXM.NXM_EMAIL, NXM.NXM_ORDEM, NXM.NXM_CESCR, NXM.NXM_CFATUR, NXM.NXM_CTIPO, NXM.NXM_NOMORI, NXM.NXM_CPATH, NXM.NXM_CTPARQ, NXM.R_E_C_N_O_ RECNO "
			cQuery +=  cSqlTit
			cQuery +=  " FROM " + RetSqlName("NXM") + " NXM "
			cQuery += " WHERE NXM.NXM_FILIAL  = '" + xFilial("NXM")  + "' "
			cQuery +=   " AND NXM.NXM_FILTIT  = '" + SE1->E1_FILIAL  + "' "
			cQuery +=   " AND NXM.NXM_PREFIX  = '" + SE1->E1_PREFIXO + "' "
			cQuery +=   " AND NXM.NXM_TITNUM  = '" + SE1->E1_NUM     + "' "
			cQuery +=   " AND NXM.NXM_TITTPO  = '" + SE1->E1_TIPO + "' "
			cQuery +=   " AND (NXM.NXM_TITPAR = '" + SE1->E1_PARCELA + "' OR "
			cQuery +=   "      NXM.NXM_TITPAR = '" + SPACE(TAMSX3("E1_PARCELA")[1]) + "')"
			cQuery +=   " AND NXM.D_E_L_E_T_  = ' ' "
		EndIf

        cQuery += "ORDER BY NXM.NXM_CESCR, NXM.NXM_CFATUR "+ cSqlTit
		DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cQryNXX, .T., .T.)
		aGrid := FwLoadByAlias(oGrid, cQryNXX, "NXM")
		
		cQuery := "" // Limpa a Query para não entrar nos tratamentos abaixo

		(cQryNXX)->( DbCloseArea() )
	EndIf

EndCase

If !Empty(cQuery)
	cQuery := ChangeQuery(cQuery, .F.)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryNXX, .T., .F. )
	// preenche o array obdecendo a ordem dos campos da estrutura
	While !(cQryNXX)->(EOF())
		For nY := 1 To Len(aStrucXXX)
			For nX:= 1 To Len(aCampos)
				If aStrucXXX[nY][MODEL_FIELD_IDFIELD] == aCampos[nX]
					If aStrucXXX[nY][MODEL_FIELD_TIPO] == "D"
						aAdd(aLinha, StoD((cQryNXX)->(FieldGet(FieldPos(aCampos[nX])))) )

					ElseIf aStrucXXX[nY][MODEL_FIELD_TIPO] == "M"
						nRecno := (cQryNXX)->(FieldGet(FieldPos("RECNO")))
						(cAliasTb)->(DbGoto(nRecno))
						cDescri := (cAliasTb)->(FieldGet(FieldPos(aCampos[nX])))
						aAdd(aLinha, cDescri )

					ElseIf aCampos[nX] == "NUE_DLTAB" //campo memo da NV4
						nRecno := (cQryNXX)->(FieldGet(FieldPos("RECNONV4")))
						NV4->(DbGoto(nRecno))
						aAdd(aLinha, NV4->NV4_DESCRI )

					Else
						aAdd(aLinha, (cQryNXX)->(FieldGet(FieldPos(aCampos[nX]))) )

					EndIf
				EndIf
			Next nX
		Next nY
		nRecno := (cQryNXX)->(FieldGet(FieldPos("RECNO")))
		aAdd(aGrid, {nRecno, aLinha})
		aLinha := {}
		(cQryNXX)->( dbSkip() )
	EndDo
	(cQryNXX)->( dbcloseArea() )
EndIf

RestArea( aArea )
RestArea( aAreaNT1 )
RestArea( aAreaNUE )
RestArea( aAreaNVY )
RestArea( aAreaNV4 )
RestArea( aAreaNVV )

Return aGrid

//-------------------------------------------------------------------
/*/{Protheus.doc} J204STRFile()
Rotina para tratar o nome dos arquivos de relatorio,
carta, recibo e boleto.

@param cTipo    Controla o retorno do nome do arquivo
                'F'- Fatura (Relatório), 'C'-Carta, 'R'- Recibo, 'B' - Boleto, 'U' - Unificado
@param cFormato Controla o formato do retorno do nome do arquivo
                '1'- Sem alteração, '2'-Upper, '3'-Lower Case
@param cEscri   Escritório da Fatura
@param cCodFat  Código da Fatura
@param aFiles   Arquivos retornados
@param cFilTit  Filial do Título da Liquidação
@param cPrefTit Prefixo do Título da Liquidação
@param cNumTit  Numero do Título da Liquidação
@param cParcTit Parcela do Título da Liquidação
@param cTipoTit Tipo do Título da Liquidação

@author Queizy Nascimento
@since 23/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J204STRFile(cTipo, cFormato, cEscri, cCodFat, aFiles, cFilTit, cPrefTit, cNumTit, cParcTit, cTipoTit)
Local aArea      := GetArea()
Local aAreaNXM   := NXM->( GetArea() )
Local cStr       := ""
Local aTipos := {{"C", "1", STR0073}, ;     // "Carta"
					{"F", "2", STR0059}, ;  // "Relatório"
					{"R", "3", STR0062}, ;  // "Recibo"
					{"B", "4", STR0063}, ;  // "Boleto"
					{"U", "5", STR0153}, ;  // "Unificado"
					{"A", "6", STR0225}, ;  // "Adicional"
					{"N", "7", STR0245}}    // "conferencia"
Local nPos      := 0
Local cTmpFile  := ""
Local cChave    := ""
Local lCpoTit   := NXM->(ColumnPos("NXM_TITNUM")) > 0 //@12.1.33
Local bCond	    := {|| }

Default cFormato := "1"
Default cEscri := ""
Default cCodFat := ""
Default aFiles := {}

	
	nPos := aScan(aTipos, {|t| t[1] == cTipo } )

	If nPos > 0

		If NXM->(ColumnPos("NXM_CTPARQ")) > 0

			If !Empty(cEscri) .And. !Empty(cCodFat)
				NXM->(DbSetOrder(4)) //NXM_FILIAL+NXM_CESCR+NXM_CFATUR+NXM_CTPARQ
				cChave := xFilial("NXM") + cEscri + cCodFat + aTipos[nPos, 02]
				bCond := { || NXM->(NXM_FILIAL + NXM_CESCR + NXM_CFATUR + NXM_CTPARQ == cChave)}
			ElseIf lCpoTit .And. !Empty(cPrefTit) .And. !Empty(cNumTit)
				NXM->(DbSetOrder(5)) // NXM_FILIAL + NXM_FILTIT + NXM_PREFIX + NXM_TITNUM + NXM_TITPAR + NXM_TITTPO + NXM_CTPARQ
				cChave := xFilial("NXM")+cFilTit+cPrefTit+cNumTit
				bCond := {|| NXM->(NXM_FILIAL + NXM_FILTIT + NXM_PREFIX + NXM_TITNUM) == cChave;
									.And. (Empty(NXM->NXM_TITPAR) .Or. NXM->NXM_TITPAR == cParcTit);
									.And. NXM->NXM_TITTPO == cTipoTit .And.;
										NXM->NXM_CTPARQ == aTipos[nPos, 02] }
			EndIf
			If !Empty(cChave) .And.	NXM->(DbSeek(cChave))
				Do While NXM->(!Eof() .And. Eval(bCond))
					cTmpFile := NoAcento(AllTrim(NXM->NXM_NOMORI))
					cTmpFile := IIf(cFormato == "2", Upper(cTmpFile), IIf(cFormato == "3", Lower(cTmpFile), cTmpFile))
					aAdd(aFiles, cTmpFile )
					cStr += cTmpFile+";"
					NXM->(DbSkip(1))
				EndDo

			EndIf
		EndIf

		If Empty(cStr)
			cTmpFile :=  NoAcento(AllTrim(aTipos[nPos, 03]))
			cTmpFile := IIF(cFormato == "2", Upper(cTmpFile), Iif(cFormato == "3", Lower(cTmpFile), cTmpFile))
			aAdd(aFiles, cTmpFile )
			cStr := cTmpFile
		EndIf
	EndIf

	RestArea( aAreaNXM )
	RestArea( aArea )

Return cStr

//-------------------------------------------------------------------
/*/ {Protheus.doc} J204GetDocs()
Faz a carga da tabela NXM

@param cEscri     , Escritório da Fatura
@param cCodFat    , Código da Fatura
@param aParJ203   , Parâmetros de emissão do relatório
@param cCodOpr    , Operadores (Indicam quais arquivos serão emitidos)
@param cPastaDest , Pasta onde os arquivos estão localizados
@param lEmissao   , Indica se a chamada foi feita via Emissão/Refazer da Fatura (JURA203)
@param cFilTit    , Filial do Título da Liquidação
@param cPrefTit   , Prefixo do Título da Liquidação
@param cNumTit    , Numero do Título da Liquidação
@param cParcTit   , Parcela do Título da Liquidação
@param cTipoTit   , Tipo do Título da Liquidação

@return lRet      , Indica se foram encontrados arquivos anexados a fatura

@author Daniel Magalhaes
@since 02/08/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function J204GetDocs(cEscri, cCodFat, aParJ203, cCodOpr, cPastaDest, lEmissao, cNewDoc, lAjuOrd, cFilTit, cPrefTit, cNumTit, cParcTit, cTipoTit)
Local aAux         := {}
Local aDirPdf      := {}
Local aPutNXM      := {}
Local cChave       := ""
Local nFor         := 0
Local nOrdAnt      := 0
Local lRet         := .F.
Local lJA204GDOC   := Existblock("JA204GDOC")
Local lArqBolet    := .F.
Local lArqUnifi    := .F.
Local lArqAdici    := .F.
Local lNoTpUnif    := .F.
Local lArqBolLiq   := .F.
Local aCarta       := {}
Local aRelat       := {}
Local aRecibo      := {}
Local aBoleto      := {}
Local aConfFat     := {}
Local aUnif        := {}
Local aAdic        := {}
Local aBoletoLiq   := {}
Local cNomCarta    := ""
Local cNomRelat    := "" 
Local cNomRecib    := ""
Local cNomBolet    := ""
Local cNomBoLiq    := ""
Local cNomConfe    := ""
Local cNomUnifi    := ""
Local aRelJ203     := {}
Local cMessage     := ""
Local cTipo        := ""
Local cFatId       := ""
Local aCliPag      := {}
Local cTpUnif      := ""
Local cEmail       := ""
Local lcTpArq      := NXM->(ColumnPos("NXM_CTPARQ")) > 0
Local cFileName    := ""
Local lCpoTit      := NXM->(ColumnPos("NXM_TITNUM")) > 0 //@12.1.33
Local cTitId	   := ""
Local cParcBol     := ""
Local lFatura	   := .T.
Local lBolLiq      := .F.
Local lSeqNxm      := FindFunction("JurSeqNXM")
Local aDirTmp      := {}
Local lConferFat   := .F.


Default cEscri     := ""
Default cCodFat    := ""
Default aParJ203   := {}
Default cCodOpr    := ""
Default cPastaDest := JurImgFat(cEscri, cCodFat, .T.)
Default cNewDoc    := ""
Default lEmissao   := .T. // Indica se é Emissão/Refazer da Fatura
Default lAjuOrd    := .F. // Indica se deve executar o ajuste de ordem
Default cFilTit    := ""
Default cPrefTit   := ""
Default cNumTit    := ""
Default cParcTit   := ""
Default cTipoTit   := ""

If (lFatura := !Empty(cEscri) .And. !Empty(cCodFat))
	cNomCarta   := J204STRFile("C", "2" ,cEscri, cCodFat, @aCarta) //"Carta"
	cNomRelat   := J204STRFile("F", "2" ,cEscri, cCodFat, @aRelat ) //"Relatorio"
	cNomRecib   := J204STRFile("R", "2" ,cEscri, cCodFat, @aRecibo) //"Recibo"
	cNomBolet   := J204STRFile("B", "2" ,cEscri, cCodFat, @aBoleto) //"Boleto"
	cNomConfe   := J204STRFile("N", "2" ,cEscri, cCodFat, @aConfFat) //"Conferencia fatura"	
ElseIf (lBolLiq := lCpoTit .And. !Empty(cPrefTit) .And. !Empty(cNumTit))
	lAjuOrd     := .F. //Não ajusta a ordem da nxm
	cNomBoLiq   := J204STRFile("B", "2" ,, , @aBoletoLiq, cFilTit, cPrefTit, cNumTit, cParcTit, cTipoTit) //Boleto de Liquidação
EndIf

If !Empty(cNewDoc)
	cNomUnifi := cNewDoc
	aAdd(aUnif, cNomUnifi)
ElseIf lFatura
	cNomUnifi := J204STRFile("U", "2", cEscri, cCodFat, @aUnif) //"Unificado"
EndIf

If Empty(cCodOpr)
	aRelJ203 := {}
Else
	aAdd(aRelJ203, Substr(cCodOpr, 1, 1) == "1") // Relatório
	aAdd(aRelJ203, Substr(cCodOpr, 2, 1) == "1") // Carta
	aAdd(aRelJ203, Substr(cCodOpr, 3, 1) == "1") // Recibo
	aAdd(aRelJ203, Substr(cCodOpr, 4, 1) == "1") // Boleto
	aAdd(aRelJ203, Substr(cCodOpr, 5, 1) == "1") // Unificado
EndIf

If ExistDir(cPastaDest)
	If lFatura
		cFatId  := Alltrim(cEscri) + '-' + Alltrim(cCodFat)
		aDirPdf := Directory( cPastaDest + "*" + cFatId + "*", Nil, Nil, .T. )
		//Verifica os arquivos de nomes alterados
		J204FlExDi(cPastaDest, aCarta, aDirPdf )
		J204FlExDi(cPastaDest, aRelat, aDirPdf )
		J204FlExDi(cPastaDest, aRecibo, aDirPdf )
		J204FlExDi(cPastaDest, aBoleto, aDirPdf )
		J204FlExDi(cPastaDest, aUnif, aDirPdf )
		J204FlExDi(cPastaDest, aAdic, aDirPdf )
	ElseIf lBolLiq
		//Boleto gerado com parcelas em aberto
		cTitId := Trim(cFilTit) + "-" + Trim(cPrefTit) + "-" + Trim(cNumTit) +  "-" + /*Trim(cParcTit) */ "-"+ Trim(cTipoTit)
		cTitId := StrTran(cTitId, " ", "_")
		aDirTmp := Directory( cPastaDest + "*" + cTitId + "*", Nil, Nil, .T. )
		aEval(aDirTmp, { |t| aAdd(aDirPdf, aClone(t))})

		//Titulo da Parcela
		cTitId := Trim(cFilTit) + "-" + Trim(cPrefTit) + "-" + Trim(cNumTit) + "-" + Trim(cParcTit) + "-"+Trim(cTipoTit)
		cTitId := StrTran(cTitId, " ", "_")
		aDirTmp :=  Directory( cPastaDest + "*" + cTitId + "*", Nil, Nil, .T. )
		aEval(aDirTmp, { |t| aAdd(aDirPdf, aClone(t))})

		J204FlExDi(cPastaDest, aBoletoLiq, aDirPdf )
	EndIf

	JurFreeArr(aCarta)
	JurFreeArr(aRelat)
	JurFreeArr(aRecibo)
	JurFreeArr(aBoleto)
	JurFreeArr(aUnif)
	JurFreeArr(aAdic)
	JurFreeArr(aBoletoLiq)
EndIf

If Len(aDirPdf) > 0
	If lFatura .And. NUH->(ColumnPos("NUH_UNIREL")) > 0 // Proteção
		aCliPag   := JurGetDados("NXA", 1, xFilial("NXA") + cEscri + cCodFat, {"NXA_CLIPG", "NXA_LOJPG"}) 
		cTpUnif   := JurGetDados("NUH", 1, xFilial("NUH") + aCliPag[1] + aCliPag[2], "NUH_UNIREL")
		lNoTpUnif := Empty(cTpUnif) .Or. cTpUnif == "1" .Or. aScan(aDirPdf, {|x| J204NomCmp( cNomUnifi, AllTrim(x[1]))}) == 0 // Não unifica
	EndIf

	For nFor := 1 To Len(aDirPdf)
		cFileName := AllTrim(aDirPdf[nFor][1])
		lArqUnifi := J204NomCmp( cNomUnifi , cFileName)
		lArqBolet := J204NomCmp( cNomBolet , cFileName)
		lConferFat := J204NomCmp( cNomConfe , cFileName)
		lArqBolLiq := lBolLiq .And. J204NomCmp( cNomBoLiq , cFileName)

		// Deve preencher a flag automaticamente somente na emissão/refazer da fatura para os arquivos de "SISTEMA"
		If lEmissao .And. !lArqAdici
			If (lNoTpUnif .Or. lArqUnifi .Or. (lArqBolet .And. cTpUnif == "2") ) .and. !lConferFat
				cEmail := "1"
			Else
				cEmail := "2"
			EndIf
		ElseIf lArqBolLiq
			//cEmail := "2"
			cParcBol := cParcTit
			//Compara para ver se arquivo da parcela ou agrupador
			If !J204NomCmp( cTitId , cFileName)
				cParcBol := ""
			EndIf
		EndIf

		aAux := {aDirPdf[nFor][1], cEscri, cCodFat, cEmail, "",cFilTit, cPrefTit, cNumTit, cParcBol, cTipoTit}

		If J204NomCmp( cNomCarta , cFileName)
			aAux[05] := "1"
		ElseIf J204NomCmp( cNomRelat , cFileName)
			aAux[05] := "2"
		ElseIf J204NomCmp( cNomRecib , cFileName)
			aAux[05] := "3"
		ElseIf  lArqBolet .Or. lArqBolLiq
			aAux[05] := "4"
		ElseIf lArqUnifi
			aAux[05] := "5"
		ElseIf lConferFat
			aAux[05] := "7"
		Else
			aAux[05] := "6"
		EndIf
		aAdd(aPutNXM, aClone(aAux))
		lRet := .T.
	Next nFor

	JurFreeArr(aDirPdf)
	nOrdAnt := 0
	If lFatura
		//Define a ordenacao inicial
		cChave := xFilial("NXM") + AvKey(cEscri, "NXM_CESCR") + AvKey(cCodFat, "NXM_CFATUR")

		NXM->(DbSetOrder(1)) // NXM_FILIAL+NXM_CESCR+NXM_CFATUR+NXM_ORDEM
		If NXM->(DbSeek(cChave))

			nOrdAnt := 0

			While !NXM->(Eof()) .And. NXM->(NXM_FILIAL + NXM_CESCR + NXM_CFATUR) == cChave
				nOrdAnt := NXM->NXM_ORDEM
				lRet := .T.
				NXM->(DbSkip())
			EndDo

		EndIf
	EndIf
	cChave := xFilial("NXM")
	For nFor := 1 To Len(aPutNXM)
		NXM->(DbSetOrder(2)) // NXM_FILIAL+NXM_NOMARQ

		If NXM->( DbSeek(cChave + AvKey(aPutNXM[nFor][1], "NXM_NOMARQ") ) )
			Reclock("NXM", .F.)
			If NXM->NXM_TKRET
				NXM->NXM_TKRET := .F.
			EndIf
			If !Empty(aPutNXM[nFor][4])
				NXM->NXM_EMAIL := aPutNXM[nFor][4]
			EndIf
			NXM->( MsUnlock() )
		Else
			nOrdAnt := nOrdAnt + 1
			If lBolLiq .And. lSeqNxm

				nOrdAnt := JurSeqNXM("", "", aPutNXM[nFor][6], aPutNXM[nFor][7], aPutNXM[nFor][8], aPutNXM[nFor][9], aPutNXM[nFor][10])
			EndIf

			cTipo   := IIF(aPutNXM[nFor][5] <> "6", "1", "2")
		
			Reclock("NXM", .T.)
			NXM->NXM_FILIAL := cChave
			NXM->NXM_TKRET  := .F.
			NXM->NXM_NOMARQ := AvKey(aPutNXM[nFor][1], "NXM_NOMARQ")
			NXM->NXM_EMAIL  := IIF(Empty(aPutNXM[nFor][4]) .And. !Empty(aPutNXM[nFor][7]), "2", aPutNXM[nFor][4])
			NXM->NXM_ORDEM  := nOrdAnt
			NXM->NXM_CESCR  := AvKey(aPutNXM[nFor][2], "NXM_CESCR" )
			NXM->NXM_CFATUR := AvKey(aPutNXM[nFor][3], "NXM_CFATUR")
			NXM->NXM_CTIPO  := cTipo
			NXM->NXM_NOMORI := AvKey(aPutNXM[nFor][1], "NXM_NOMORI")
			NXM->NXM_CPATH  := ""
			If lcTpArq
				NXM->NXM_CTPARQ := aPutNXM[nFor][5]
			EndIf
			If lCpoTit
				NXM->NXM_FILTIT := aPutNXM[nFor][6]
				NXM->NXM_PREFIX := aPutNXM[nFor][7]
				NXM->NXM_TITNUM := aPutNXM[nFor][8]
				NXM->NXM_TITPAR := aPutNXM[nFor][9]
				NXM->NXM_TITTPO	:= aPutNXM[nFor][10]
			End
			NXM->(MsUnlock())
		EndIf

	Next nFor

	J204FixDocs(aPutNXM, cEscri, cCodFat, .T., cFilTit, cPrefTit, cNumTit, cParcTit, cTipoTit)

	If lAjuOrd .And. !IsInCallStack("J204GERARPT") // Não refaz a ordem dos documentos relacionados no refazer da Fatura
		J203AjuOrd(cEscri, cCodFat) // Ajusta ordem dos documentos se necessário
	EndIf

	//Ponto de entrada apos a geracao da NXM
	If lJA204GDOC .And. lFatura
		Execblock( "JA204GDOC", .F., .F., { AvKey(cEscri, "NXM_CESCR" ), AvKey(cCodFat, "NXM_CFATUR"), aParJ203, aRelJ203 } )
	EndIf

Else  //Não achou nenhum arquivo no diretório

	J204FixDocs(aPutNXM, cEscri, cCodFat, .F., cFilTit, cPrefTit, cNumTit, cParcTit, cTipoTit)

	If lAjuOrd .And. !IsInCallStack("J204GERARPT") // Não refaz a ordem dos documentos relacionados no refazer da Fatura
		J203AjuOrd(cEscri, cCodFat) // Ajusta ordem dos documentos se necessário
	EndIf

	lRet := .F.
	If !IsInCallStack("JURA203") .And. lFatura
		cMessage := STR0166 +" - "+ STR0167 +": "+ cEscri +"-" + cCodFat //"Final - Reimprimir Fatura"
		EventInsert( FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, "055", FW_EV_LEVEL_INFO, ""/*cCargo*/, STR0168 + "-"+STR0167, cMessage, .F. ) // " Reimprimir Fatura"
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204FixDocs()
Função para corrigir os registros dos arquivos relacionados à fatura.

@param aPutNXM , Array com arquivos que estão anexados à fatura
@param cEscri  , Escritório da Fatura
@param cCodFat , Código da Fatura
@param lInclui , Indica se a cópia deve ser criada logo após a exclusão 
                 dos registros originais
@param cFilTit , Filial do Título de Liquidação
@param cPrefTit, Prefixo do Título de Liquidação
@param cNumTit , Numero do Título de Liquidação
@param cParcTit, Parcela do Título de Liquidação
@param cTipoTit, Tipo do Título de Liquidação

@author Luciano Pereira dos Santos
@since 16/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204FixDocs(aPutNXM, cEscri, cCodFat, lInclui, cFilTit, cPrefTit, cNumTit, cParcTit, cTipoTit)
Local aArea   := GetArea()
Local aInclui := {}
Local nArqs   := 0
Local lcTpArq := NXM->(ColumnPos("NXM_CTPARQ")) > 0
Local lCpoTit := NXM->(ColumnPos("NXM_TITNUM")) > 0 //@12.1.33
Local cChave  := ""

DbselectArea("NXM")
If !Empty(cEscri) .And. !Empty(cCodFat)
	NXM->( DbSetOrder(1) ) // NXM_FILIAL+NXM_CESCR+NXM_CFATUR+NXM_ORDEM
	cChave := xFilial("NXM") + cEscri + cCodFat
	bCond := {|| NXM->(NXM_FILIAL+NXM_CESCR+NXM_CFATUR) == xFilial("NXM") + cEscri + cCodFat}
Else
	NXM->( DbSetOrder(5) ) // NXM_FILIAL + NXM_FILTIT + NXM_PREFIX + NXM_TITNUM + NXM_TITPAR +  NXM_TITTPO +  NXM_CTPARQ
	cChave := xFilial("NXM") + cFilTit + cPrefTit + cNumTit
	bCond := {|| NXM->(NXM_FILIAL + NXM_FILTIT + NXM_PREFIX + NXM_TITNUM) == cChave;
									.And. (Empty(NXM->NXM_TITPAR) .Or. NXM->NXM_TITPAR == cParcTit);
									.And. NXM->NXM_TITTPO == cTipoTit}
EndIf

If NXM->( DbSeek(cChave) )
	While !NXM->(Eof()) .And. Eval(bCond)
		If aScan(aPutNXM, {|ax| Upper(Alltrim(ax[1])) == Upper(Alltrim(NXM->NXM_NOMORI))}) == 0

			// É necessário realizar a inclusão somente quando for o relacionamento do arquivo original
			// Somente quando for o arquivo original, os nomes serão diferentes.
			If lInclui .And. Upper(Alltrim(NXM->NXM_NOMARQ)) <> Upper(Alltrim(NXM->NXM_NOMORI))
				aAdd(aInclui, { NXM->NXM_FILIAL, NXM->NXM_TKRET, NXM->NXM_NOMARQ, NXM->NXM_EMAIL, ;
				                NXM->NXM_ORDEM , NXM->NXM_CESCR, NXM->NXM_CFATUR, NXM->NXM_CTIPO, ;
								NXM->NXM_NOMARQ, IIF(lcTpArq,NXM->NXM_CTPARQ,NIL ) , NIL, NIL,;
								NIL , NIL , NIL } )
				If lCpoTit
					aTail(aInclui)[11] := NXM->NXM_FILTIT
					aTail(aInclui)[12] := NXM->NXM_PREFIX
					aTail(aInclui)[13] := NXM->NXM_TITNUM
					aTail(aInclui)[14] := NXM->NXM_TITPAR
					aTail(aInclui)[15] := NXM->NXM_TITTPO
				EndIf
			EndIf
			
			Reclock("NXM", .F.)
			NXM->(DbDelete())
			NXM->(MsUnlock())

		EndIf
		NXM->(DbSkip())
	EndDo

	// Necessário para que logo após a exclusão, sejam criados os arquivos novamente.
	// Quando o usuário incluia um novo anexo, o mesmo era excluído nessa rotina, 
	// e ao acessar novamente a tela de anexos o arquivo não aparecia. 
	// Era necessário fechar e abrir a tela novamente para o arquivo aparecer.
	For nArqs := 1 To Len(aInclui)
		Reclock("NXM", .T.)
		NXM->NXM_FILIAL := aInclui[nArqs][1]
		NXM->NXM_TKRET  := aInclui[nArqs][2]
		NXM->NXM_NOMARQ := aInclui[nArqs][3]
		NXM->NXM_EMAIL  := aInclui[nArqs][4]
		NXM->NXM_ORDEM  := aInclui[nArqs][5]
		NXM->NXM_CESCR  := aInclui[nArqs][6]
		NXM->NXM_CFATUR := aInclui[nArqs][7]
		NXM->NXM_CTIPO  := aInclui[nArqs][8]
		NXM->NXM_NOMORI := aInclui[nArqs][9]
		If lcTpArq
			NXM->NXM_CTPARQ := aInclui[nArqs][10]
		EndIf
		If lCpoTit
			NXM->NXM_FILTIT := aInclui[nArqs][11]
			NXM->NXM_PREFIX := aInclui[nArqs][12]
			NXM->NXM_TITNUM := aInclui[nArqs][13]
			NXM->NXM_TITPAR := aInclui[nArqs][14]
			NXM->NXM_TITTPO := aInclui[nArqs][15]
		EndIf
		NXM->NXM_CPATH  := ""
		NXM->( MsUnlock() )
	Next

	JurFreeArr(@aInclui)

EndIf

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J204PDF
SubView para os Documentos Relacionados a Fatura

@param lFinanc    Indica que a chamada é de rotina do Financeiro
@param cEscr      Escritório da Fatura
@param cCodFat    Código da Fatura

@author Daniel Magalhaes
@since 03/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J204PDF(lFinanc, cEscr, cCodFat)
Local aAreaNXA   := NXA->(GetArea())
Local aAreaSE1   := SE1->(GetArea())
Local aArea      := GetArea()
Local oView      := Nil
Local oExecView  := Nil
Local oStructNXM := Nil
Local oStructNXA := Nil
Local oModel     := Nil
Local cMsgRet    := ''
Local cImgFat    := ''
Local cMsgLog    := ''
Local lCpoTit    := NXM->(ColumnPos("NXM_TITNUM")) > 0 //@12.1.33

Default cEscr    := NXA->NXA_CESCR
Default cCodFat  := NXA->NXA_COD
Default lFinanc  := .F.

If FindFunction("JPDLogUser")
	JPDLogUser("J204PDF") // Log LGPD Relatório de Recibo do Adiantamento
EndIf

cImgFat := JurImgFat(cEscr, cCodFat, .T., .F., @cMsgRet)

If !Empty(cMsgRet)
	cMsgLog := "Ja202Refaz -> " + cMsgRet
EndIf

JurCrLog(cMsgLog)

J204GetDocs(cEscr, cCodFat, , , cImgFat, .F.)

If lFinanc
	NXA->( DbSetOrder(1) ) // NXA_FILIAL + NXA_CESCR + NXA_COD
	NXA->( DbSeek( xFilial("NXA") + cEscr + cCodFat ) )
EndIf

oModel := FWLoadModel( "JURA204" )

oStructNXA := FWFormStruct(2, 'NXA')
oStructNXM := FWFormStruct(2, 'NXM')

oStructNXM:RemoveField('NXM_CESCR')
oStructNXM:RemoveField('NXM_CFATUR')
oStructNXM:RemoveField('NXM_NOMORI')
oStructNXM:RemoveField('NXM_CPATH')

If lCpoTit
	oStructNXM:RemoveField('NXM_FILTIT')
	oStructNXM:RemoveField('NXM_PREFIX')
	oStructNXM:RemoveField('NXM_TITNUM')
	oStructNXM:RemoveField('NXM_TITPAR')
	oStructNXM:RemoveField('NXM_TITTPO')
EndIf

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddGrid("JURA204_NXM", oStructNXM, "NXMDETAIL" )
oView:CreateHorizontalBox('FORMGRID', 100)
oView:SetOwnerView("JURA204_NXM", "FORMGRID")
oView:SetCloseOnOk({|| .T.})

oView:AddUserButton(STR0119, 'SDUSEEK', {|oAux| J204PDFViz(oAux, cImgFat)}) //"Visualizar"

If !lFinanc
	oView:AddUserButton(STR0118, 'SDUADDTBL',   {|oAux| J204PDFUpl(oAux)})          // "Relacionar"
	oView:AddUserButton(STR0120, 'SDUCOPYTO',   {|oAux| J204PDFJoi(oAux, cImgFat)}) // "Unificar"
	oView:AddUserButton(STR0005, 'EXCLUIR.PNG', {|oAux| J204PDFDel(oAux, cImgFat)}) // "Excluir"
EndIf

oView:SetDescription( STR0019 ) // "Docs Relacionados"

If lFinanc
	oView:SetOperation( 1 )
Else
	oView:SetOperation( 4 )
EndIf

oExecView:= FwViewExec():New()
oExecView:SetView(oView)
oExecView:SetSize(200, 515)
If lFinanc
	oExecView:SetTitle(STR0019) // "Docs Relacionados"
Else
	oExecView:SetTitle(STR0121) // "Manutenção de Documentos"
EndIf
oExecView:OpenView(.F.)

RestArea(aAreaNXA)
RestArea(aAreaSE1)
RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J204PDFPos
Pos Validacao da View J204PDF

@author Daniel Magalhaes
@since 03/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J204PDFPos()
Local lRet       := .T.
Local oModel     := FwModelActive()
Local oModelNXM  := oModel:GetModel("NXMDETAIL")
Local nI         := 0
Local cTipo      := ""

For nI := 1 To oModelNXM:GetQtdLine()

	cTipo := oModelNXM:GetValue("NXM_CTIPO", nI)

	If oModelNXM:IsDeleted(nI) .And. cTipo == "1"
		lRet := JurMsgErro(STR0122) //"Não é possível excluir documentos gerados pelo sistema"
		Exit
	EndIf

Next nI

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204PDFVal
Refaz a ordenação do grid de documentos relacionados

@author Jonatas Martins / Jorge Martins
@since  24/05/2021
@Obs    Função chamada no X3_VALID do campo NXM_ORDEM
/*/
//-------------------------------------------------------------------
Function J204PDFVal(cCampo)
Local oView        := FwViewActive()
Local oModel       := FwModelActive()
Local oModelNXM    := oModel:GetModel("NXMDETAIL")
Local nLineUpd     := oModelNXM:GetLine()
Local nNewOrderUpd := 0
Local nOldOrderUpd := 0
Local nOrder       := 0
Local nLineNXM     := 0

	If cCampo == "NXM_ORDEM"
		If Empty(oModelNXM:GetValue("__ORDEM"))
			oModelNXM:LoadValue("__ORDEM", oModelNXM:GetValue("NXM_ORDEM"))
		Else
			nNewOrderUpd := oModelNXM:GetValue("NXM_ORDEM") // Valor novo da linha modificada (Alterado pelo usuário)
			nOldOrderUpd := oModelNXM:GetValue("__ORDEM")   // Valor antigo da linha modificada

			For nLineNXM := 1 To oModelNXM:GetQtdLine()
				oModelNXM:GoLine(nLineNXM)
				nOrder := oModelNXM:GetValue("NXM_ORDEM")

				If nLineNXM <> nLineUpd
					If nNewOrderUpd < nOldOrderUpd
						If nOrder >= nNewOrderUpd .And. nOrder <= nOldOrderUpd
							nOrder += 1
						EndIf
					Else
						If nOrder >= nOldOrderUpd .And. nOrder <= nNewOrderUpd
							nOrder -= 1
						EndIf
					EndIf

					oModelNXM:LoadValue("NXM_ORDEM", nOrder)
				EndIf

				oModelNXM:LoadValue("__ORDEM", nOrder)
			Next nLineNXM
		EndIf

		oModelNXM:GoLine(nLineUpd)
	EndIf

	oView:Refresh()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J204PDFWhen
Modo de Edicao dos campos da View J204PDF

@author Daniel Magalhaes
@since 04/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J204PDFWhen( cCampo )
Local lRet := .T.

If AllTrim(cCampo) == "NXM_NOMARQ"
	lRet := IsInCallStack("J204PDFUPL") .Or. IsInCallStack("J204PDFJOI")
ElseIf AllTrim(cCampo) == "NXM_CESCR"
	lRet := .F.
ElseIf AllTrim(cCampo) == "NXM_CFATUR"
	lRet := .F.
ElseIf AllTrim(cCampo) == "NXM_CTIPO"
	lRet := IsInCallStack("J204PDFUPL") .Or. IsInCallStack("J204PDFJOI")
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204PDFUpl
Upload de documentos da View J204PDF

@author Daniel Magalhaes
@since 04/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204PDFUpl( oView )
Local oModel    := FwModelActive()
Local oModelNXA := oModel:GetModel("NXAMASTER")
Local oModelNXM := oModel:GetModel("NXMDETAIL")
Local cEscrit   := oModelNXA:GetValue("NXA_CESCR")
Local cCodFat   := oModelNXA:GetValue("NXA_COD")
Local cDArquivo := ""
Local cNomeGrav := ""
Local cNomeView := ""
Local nPos      := 0
Local nLen      := 0
Local nMaxOrder := 0
Local nNXMOrder := 0
Local nI        := 0
Local lRet      := .T.
Local nSaveLine := 0
Local cMask     := ''
Local lcTpArq := NXM->(ColumnPos("NXM_CTPARQ")) > 0

cMask := I18N(STR0123, {'(*.pdf)|*.PDF|','(*.docx)|*.DOCX|','(*.doc)|*.DOC|','(*.xlsx)|*.XLSX|','(*.xls)|*.XLS|','(*.pptx)|*.PPTX|','(*.ppt)|*.PPT|','(*.*)|*.*|'}) //"Documento Acrobat® #1 Documento Word® #2 Documento Word® 97-2003 #3 Planilha Excel® #4 Planilha Excel® 97-2003 #5 Apresentação Power Point® #6 Apresentação Power Point® 97-2003 #7 Todos Arquivos #8"

cDArquivo := cGetFile(cMask, STR0124, 0, cLastFOpen, .T., GETF_LOCALHARD + GETF_NETWORKDRIVE, .T., .T.) //"Relacionar documento"

lRet := !Empty(cDArquivo)

If lRet
	cLastFOpen := Alltrim(Substr(cDArquivo, 1, RAt("\", cDArquivo) ) ) //Memoriza o ultimo diretório usado no Upload
	cDArquivo  := Upper(cDArquivo)

	nPos := RAt("\", cDArquivo)
	nLen := Len(cDArquivo) - nPos

	cNomeView := Right(cDArquivo,nLen)
	cNomeView := FwNoAccent(cNomeView)
	cNomeGrav := Upper(STR0225 + "_(" + AllTrim(cEscrit) + "-" + AllTrim(cCodFat) + ")_" + StrTran(cNomeView, " ", "_") ) // Adicional
	cNomeGrav := AvKey(FwNoAccent(cNomeGrav), "NXM_NOMARQ")

	nSaveLine := oModelNXM:GetLine()

	For nI := 1 To oModelNXM:GetQtdLine()
		If oModelNXM:GetValue("NXM_NOMARQ", nI) == cNomeGrav
			lRet := .F.
			Exit
		Else
			nNXMOrder := oModelNXM:GetValue("NXM_ORDEM", nI)
			nMaxOrder := IIf( nNXMOrder > nMaxOrder, nNXMOrder, nMaxOrder )
		EndIf
	Next nI

	If lRet
		nMaxOrder := nMaxOrder + 1

		If !oModelNXM:CanInsertLine()
			oModelNXM:SetNoInsertLine(.F.)
		EndIf

		oModelNXM:AddLine()
		oModelNXM:SetValue("NXM_FILIAL", xFilial("NXM"))
		oModelNXM:SetValue("NXM_TKRET" , .F.)
		oModelNXM:SetValue("NXM_NOMARQ", AvKey(cNomeGrav, "NXM_NOMARQ"))
		oModelNXM:SetValue("NXM_EMAIL" , "2")
		oModelNXM:SetValue("NXM_ORDEM" , nMaxOrder)
		oModelNXM:SetValue("NXM_CTIPO" , "2")//"U"
		oModelNXM:SetValue("NXM_NOMORI", AvKey(cNomeView, "NXM_NOMORI"))
		oModelNXM:SetValue("NXM_CPATH" , AvKey(cDArquivo, "NXM_CPATH"))
		If lcTpArq
			oModelNXM:SetValue("NXM_CTPARQ" , "6")
		EndIf

		oModelNXM:SetNoInsertLine(.T.)

	Else
		ApMsgAlert( I18N(STR0193, {cNomeView}) ) //"O documento '#1' já foi relacionado à fatura."
	EndIf

	oModelNXM:GoLine(nSaveLine)
EndIf

oView:Refresh()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204PDFViz
Visualiza o documento seleciona na View J204PDF

@author Daniel Magalhaes
@since 05/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J204PDFViz( oView, cPathImg )
Local oModel    := FwModelActive()
Local oModelNXM := oModel:GetModel("NXMDETAIL")
Local lRet      := .T.
Local cArquivo  := oModelNXM:GetValue("NXM_NOMARQ")
Local cEscr     := ""
Local cFatur    := ""

	Default cPathImg := ""
	
	If Empty(cPathImg)
		cEscr    := oModelNXM:GetValue("NXM_CESCR")
		cFatur   := oModelNXM:GetValue("NXM_CFATUR")
		cPathImg := JurImgFat(cEscr, cFatur, .T., .F.)
	EndIf
	
	If !oModelNXM:IsFieldUpdated("NXM_NOMARQ") //Indica que a subview ainda não foi comitada
		lRet := JurOpenFile(cArquivo, cPathImg, '2', .T.)
	Else
		ApMsgAlert(STR0194) //"É necessário salvar as alterações antes de visualizar o documento."
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204PDFJoi
Cria a juncao dos documentos selecionados na View J204PDF

@author Daniel Magalhaes
@since 05/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204PDFJoi( oView, cImgFat )
Local aMarks    := {}
Local aDoctos   := {}
Local aDoctos1  := {}
Local oModel    := FwModelActive()
Local oModelNXA := oModel:GetModel("NXAMASTER")
Local oModelNXM := oModel:GetModel("NXMDETAIL")
Local lRet      := .T.
Local lAddLine  := .T.
Local cEscrit   := oModelNXA:GetValue("NXA_CESCR")
Local cCodFat   := oModelNXA:GetValue("NXA_COD")
Local cJoinFile := ""
Local nNXMOrder := 0
Local nMaxOrder := 0
Local nI        := 0
Local cfile     := ""
Local IsPdf     := .F.
Local lcTpArq := NXM->(ColumnPos("NXM_CTPARQ")) > 0

For nI := 1 To oModelNXM:GetQtdLine()
	If oModelNXM:GetValue("NXM_TKRET", nI)
		cfile := Alltrim(oModelNXM:GetValue("NXM_NOMARQ", nI))
		IsPdf := Upper(Substr(cFile, At(".", cfile))) == ".PDF"

		If IsPdf
			aAdd( aMarks, nI )
			aAdd( aDoctos1, {cfile, oModelNXM:GetValue("NXM_ORDEM", nI)} )
		Else
			Exit
		EndIf
	EndIf
Next nI

If IsPdf
	aSort( aDoctos1,,, { |X,Y| X[2] < Y[2] } )

	For nI := 1 To Len(aDoctos1)
		aAdd( aDoctos, AllTrim(aDoctos1[nI][1]) )
	Next nI

	If Len(aMarks) > 1
		If ApMsgYesNo(STR0125, STR0126) //#"Para unificar os documentos, o sistema salvará todas as alterações feitas na tela, deseja continuar?" ##"ATENÇÃO"

			For nI := 1 To Len(aMarks)
				oModelNXM:GoLine(aMarks[nI])
				oModelNXM:SetValue("NXM_TKRET", .F.)
			Next nI

			J204PDFCpy(oModel, cImgFat)
			lRet  := J204JOIN(cEscrit, cCodFat, aDoctos, @cJoinFile, .T., cImgFat)

			If lRet
				For nI := 1 To oModelNXM:GetQtdLine()

					If AllTrim(Upper(oModelNXM:GetValue("NXM_NOMARQ", nI))) == AllTrim(Upper(cJoinFile))
						lAddLine := .F.
						Exit
					EndIf

					If !oModelNXM:IsDeleted(nI)
						nNXMOrder := oModelNXM:GetValue("NXM_ORDEM", nI)
						nMaxOrder := IIf( nNXMOrder > nMaxOrder, nNXMOrder, nMaxOrder )
					EndIf

				Next nI

				If lAddLine
					nMaxOrder := nMaxOrder + 1

					If !oModelNXM:CanInsertLine()
						oModelNXM:SetNoInsertLine(.F.)
					EndIf

					oModelNXM:AddLine()
					oModelNXM:SetValue("NXM_FILIAL", xFilial("NXM"))
					oModelNXM:SetValue("NXM_TKRET" , .F.)
					oModelNXM:SetValue("NXM_NOMARQ", AvKey(cJoinFile, "NXM_NOMARQ"))
					oModelNXM:SetValue("NXM_EMAIL" , "2")
					oModelNXM:SetValue("NXM_ORDEM" , nMaxOrder)
					oModelNXM:SetValue("NXM_CTIPO" , "2")
					oModelNXM:SetValue("NXM_NOMORI", AvKey(cJoinFile, "NXM_NOMORI"))
					oModelNXM:SetValue("NXM_CPATH" , "")
					If lcTpArq
						oModelNXM:SetValue("NXM_CTPARQ", "5")
					EndIf

					oModelNXM:SetNoInsertLine(.T.)
				EndIf
			EndIf

			If oModel:VldData()
				oModel:CommitData()
				oModel:Deactivate()
				oModel:Activate()
			EndIf

			oView:Refresh()

		EndIf
	Else
		ApMsgAlert(STR0127) //"Selecione pelos menos dois documentos para unificar."
	EndIf

Else
	ApMsgAlert(STR0195) //"Selecione apenas aquivos do tipo Acrobat® para unificar."
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204PDFDel
Exclusão de documentos da View J204PDF

@author Jorge Martins
@since 04/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204PDFDel( oView, cImgFat )
Local oModel     := FwModelActive()
Local oModelNXM  := oModel:GetModel("NXMDETAIL")
Local aMarks     := {}
Local aDoctos    := {}
Local nNXM       := 0
Local lRet       := .T.
Local aExc       := {}

For nNXM := 1 To oModelNXM:GetQtdLine()
	oModelNXM:GoLine(nNXM)
	If oModelNXM:GetValue("NXM_TKRET")
		aAdd( aMarks, nNXM )
		aAdd( aDoctos, AllTrim(oModelNXM:GetValue("NXM_NOMARQ")) )
	EndIf
Next nNXM

If Len(aMarks) >= 1
	If ApMsgYesNo(STR0161, STR0126) //"Deseja realmente excluir os documentos selecionados?"###"ATENÇÃO"

		For nNXM := 1 To Len(aMarks)
			oModelNXM:GoLine(aMarks[nNXM])
			oModelNXM:DeleteLine()

			If File(cImgFat + AllTrim(oModelNXM:GetValue("NXM_NOMARQ")))
				aAdd(aExc, (cImgFat + AllTrim(oModelNXM:GetValue("NXM_NOMARQ"))))
			EndIf

		Next nNXM

	EndIf
Else
	MsgAlert(STR0162)//"Selecione algum documento para realizar a exclusão"
EndIf

If lRet := oModel:VldData()

	oModel:CommitData()

	For nNXM := 1 To Len(aExc)
		FErase(aExc[nNXM])
	Next nNXM

	oModel:Deactivate()
	oModel:Activate()
Else
	For nNXM := 1 To Len(aMarks)
		oModelNXM:GoLine(aMarks[nNXM])
		oModelNXM:UnDeleteLine()
	Next
EndIf

oView:Refresh()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204CpyFat
Faz a cópia dos arquivos físicos da fatura.

@author Daniel Magalhaes
@since 05/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204CpyFat(oModel)
Local oModelNXM  := oModel:GetModel("NXMDETAIL")
Local cFileOri   := ""
Local nNXM       := 0
Local cImgFat    := JurImgFat(oModel:GetValue("NXAMASTER", "NXA_CESCR"), oModel:GetValue("NXAMASTER", "NXA_COD"), .T.)
Local cRazSocAnt := NXA->NXA_RAZSOC
Local cRazSocNov := oModel:GetValue('NXAMASTER', 'NXA_RAZSOC')
Local lAltRazSoc := SuperGetMv( "MV_JALTRAZ", , '0' ) != '0' // Altera Razão Social da Fatura? 0 - Não altera; 1 - Altera se não foi emitida Nota Fiscal; 2 - Altera independente da emissão da Nota Fiscal. 

	If IsInCallStack("J204PDF")

		J204PDFCpy(oModel, cImgFat)

		For nNXM := 1 To oModelNXM:GetQtdLine()
			oModelNXM:GoLine(nNXM)

			If oModelNXM:IsDeleted()
				cFileOri := Alltrim(oModelNXM:GetValue("NXM_NOMARQ"))

				If File(cImgFat + cFileOri)
					FErase(cImgFat + cFileOri)
				EndIf
			EndIf
		Next nNXM

	EndIf

	If lAltRazSoc .And. cRazSocAnt != cRazSocNov
		JA204CoRaz(oModel)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J204FSinc
Faz a gravação da fatura na Fila de Sincronização (NYS).

@author Cristina Cintra
@since 22/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204FSinc(oModel)
Local oModelNXA  := oModel:GetModel("NXAMASTER")
Local cEscrit    := oModelNXA:GetValue("NXA_CESCR")
Local cFatura    := oModelNXA:GetValue("NXA_COD")

	J170GRAVA(oModel, xFilial('NXA') + cEscrit + cFatura)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J204PDFCpy
Copia os documentos PDF para a pasta de destino

@author Daniel Magalhaes
@since 05/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J204PDFCpy(oModel, cImgFat)
Local oModelNXM  := oModel:GetModel("NXMDETAIL")
Local oModelNXA  := oModel:GetModel("NXAMASTER")
Local cEscrit    := oModelNXA:GetValue("NXA_CESCR")
Local cFatura    := oModelNXA:GetValue("NXA_COD")
Local cFileOri   := ""
Local cFileGrv   := ""
Local nNXM       := 0
Local cMsgRet    := ""
Local cMsgLog    := ""

Default cImgFat  := JurImgFat(cEscrit, cFatura , .T., .F., @cMsgRet)

If !Empty(cMsgRet)
	cMsgLog := "J204PDFCpy -> " + cMsgRet
EndIf

For nNXM := 1 To oModelNXM:GetQtdLine()
	oModelNXM:GoLine(nNXM)

	If !oModelNXM:IsDeleted() .And. !Empty(oModelNXM:GetValue("NXM_CPATH"))
		cFileOri := oModelNXM:GetValue("NXM_NOMARQ")
		cFileGrv := oModelNXM:GetValue("NXM_CPATH")

		If File(cImgFat + cFileOri)
			FErase(cImgFat + cFileOri)
		EndIf

		__CopyFile(cFileGrv, cImgFat + cFileOri)

		oModelNXM:SetValue("NXM_CPATH", "")
	EndIf
Next nNXM

JurCrLog(cMsgLog)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J204EmlDoc
Faz o tratamento do anexo do email

@author Daniel Magalhaes
@since 05/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J204EmlDoc(cEscri, cFatur, lDelAnt )
Local aAreaNXM    := NXM->(GetArea())
Local aArea       := GetArea()
Local cPDFDocs    := ""
Local aEmlDocs    := {}
Local cChave      := ""
Local cRet        := ""
Local cPastaDocs  := JurImgFat(cEscri, cFatur, .T.)
Local cFile       := ""

Default cEscri    := ""
Default cFatur    := ""
Default lDelAnt   := .T.

If !Empty(cEscri) .And. !Empty(cFatur)

	cPDFDocs := "Email_Fatura-" + AllTrim(cEscri) + "-" + AllTrim(cFatur) + ".pdf"

	//Deleta anexo anexo unificado antigo
	If lDelAnt .AND.  File(cPastaDocs + cPDFDocs)
		FErase(cPastaDocs + cPDFDocs)
	EndIf

	NXM->( DbSetOrder(1) ) // NXM_FILIAL+NXM_CESCR+NXM_CFATUR+NXM_ORDEM

	cChave := xFilial("NXM") + cEscri + cFatur

	If NXM->( DbSeek( cChave ) )

		While !NXM->(Eof()) .And. NXM->( NXM_FILIAL + NXM_CESCR + NXM_CFATUR ) == cChave

			cFile := Alltrim(NXM->NXM_NOMARQ)

			If NXM->NXM_EMAIL == "1" //Envia
				AAdd(aEmlDocs, cFile)
			EndIf

			NXM->( DbSkip() )
		EndDo
	EndIf
	cRet := J204PathEml(cPastaDocs, aEmlDocs, cPDFDocs, ,lDelAnt)

EndIf

NXM->( RestArea(aAreaNXM) )
RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204PathEml()
Rotina para copiar os arquivos anexos para a pasta
temporaria 'MailDocs_'+__cUserID no Rootpath do servidor

@author Luciano Pereira dos Santos
@since 03/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function J204PathEml(cPastaDocs, aEmlDocs, cPDFDocs, llog, lDelAnt)
Local lRet      := .T.
Local cMailDir  := JurFixPath('tmp_'+__cUserID, 1, 1)
Local nI        := 0
Local aDocsOld  := {}
Local cMailDocs := ""

Default lLog := .F.
Default lDelAnt := .T.

If !ExistDir(cMailDir)
	If (MakeDir(cMailDir) != 0)
		lRet := .F.
		Iif(lLog, JurLogMsg( "J204PathEml: Could not create directory '" + cPastaDocs + "'"), Nil)
	EndIf
EndIf

If lRet
	aDocsOld := Directory(cMailDir + '*.*')
	If lDelAnt
		For nI := 1 To Len(aDocsOld) //Limpa a pasta garantindo que não será enviado nenhum arquivo equivicado
			FErase(cMailDir + aDocsOld[nI][1])
		Next nI
	EndIf

	For nI := 1 To Len(aEmlDocs) //Copy os arquivos para a pasta apartir do RootPath
		If __COPYFILE(cPastaDocs + aEmlDocs[nI], cMailDir + aEmlDocs[nI])
			cMailDocs += cMailDir + aEmlDocs[nI] + ';'

			If aEmlDocs[nI] == cPDFDocs //Remove o arquivo unificado de email temporário
				FErase(cPastaDocs + aEmlDocs[nI])
			EndIf
		EndIf
	Next nI
EndIf

Return cMailDocs

//-------------------------------------------------------------------
/*/{Protheus.doc} J204DelEml()
Rotina para remover a pasta temporaria 'MailDocs_'+__cUserID dos
arquivos email anexos.

@author Luciano Pereira dos Santos
@since 03/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function J204DelEml(llog)
Local lRet      := .T.
Local cMailDir  := JurFixPath('tmp_'+__cUserID, 1, 1)
Local nI        := 0
Local aDocsOld  := {}

Default lLog := .F.

aDocsOld := Directory(cMailDir + '*.*')
For nI := 1 To Len(aDocsOld) //Limpa a pasta temporaria antes de remover
	If FErase(cMailDir + aDocsOld[nI][1]) == -1
		lRet := .F.
		Exit
	EndIf
Next nI

lRet := lRet .And. DirRemove(cMailDir)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA204RPre()
Reemite a pré ao cancelar a Fatura

@author Luciano Pereira dos Santos
@since 23/09/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA204RPre(cEscrit, cFatura)
Local aRet      := {.T., ""}
Local aArea     := GetArea()
Local cNVVCOD   := ""
Local cNW2COD   := ""
Local cNT0COD   := ""
Local cCLIPAG   := ""
Local cLOJAPG   := ""
Local cTEMTS    := ""
Local cTEMLT    := ""
Local cTEMDP    := ""
Local cTEMFX    := ""
Local cTEMFA    := ""
Local oParams   := Nil
Local cQuery    := ""
Local aFaturas  := {}
Local cCodPre   := ''
Local cCodFixo  := ''
Local cCASO     := ''
Local cPONumber := ''

cQuery := " SELECT NXA.NXA_COD, NXA.NXA_CESCR, NXA.NXA_SITUAC, NXA.NXA_CPREFT, NXA.NXA_CLIPG,"  //[5]
cQuery +=        " NXA.NXA_LOJPG, NXA.NXA_TIPO, NXA.NXA_DREFIH, NXA.NXA_DREFIT, NXA.NXA_DREFID, NXA.NXA_CFTADC," // [11]
cQuery +=        " NXA.NXA_CJCONT, NXA.NXA_CCONTR, NXA.NXA_TS, NXA.NXA_TAB, NXA.NXA_DES,"  // [16]
cQuery +=        " NXA.NXA_FIXO, NXA.NXA_FATADC, NXC_CCONTR, NXC_CCASO," // [20]
cQuery +=        " NXA.NXA_DREFFH, NXA.NXA_DREFFT, NXA.NXA_DREFFD, " // [23]
cQuery +=        " NXA.NXA_PONUMB " // [24]
cQuery += " FROM " + RetSqlName("NXA") + " NXA,"
cQuery +=      " " + RetSqlName("NXC") + " NXC"
cQuery += " WHERE NXA.NXA_FILIAL = '" + xFilial('NXA') + "'"
cQuery += " AND NXC.NXC_FILIAL = '" + xFilial('NXC') + "'"
cQuery += " AND NXA.NXA_CESCR = '" + cEscrit + "'"
cQuery += " AND NXA.NXA_COD = '" + cFatura + "'"
cQuery += " AND NXC.NXC_CESCR = NXA.NXA_CESCR"
cQuery += " AND NXC.NXC_CFATUR = NXA.NXA_COD"
cQuery += " AND NXA.D_E_L_E_T_ = ' '"
cQuery += " AND NXC.D_E_L_E_T_ = ' '"

aFaturas := JurSQL(cQuery, {'NXA_COD', 'NXA_CESCR', 'NXA_SITUAC', 'NXA_CPREFT', 'NXA_CLIPG',;
								'NXA_LOJPG', 'NXA_TIPO', 'NXA_DREFIH', 'NXA_DREFID', 'NXA_CFTADC',;
								'NXA_CJCONT', 'NXA_CCONTR', 'NXA_TS', 'NXA_TAB', 'NXA_DES',;
								'NXA_FIXO', 'NXA_FATADC', 'NXA_DREFIT', 'NXC_CCONTR', 'NXC_CCASO',;
								'NXA_DREFFH', 'NXA_DREFFT', 'NXA_DREFFD', 'NXA_PONUMB'})

If !Empty(aFaturas)

	If aFaturas[1][7] == "FT" .And. !Empty(aFaturas[1][4]) // se é fatura gerada a partir de uma pré-fatura

		oParams := TJPREFATPARAM():New()
		oParams:SetCodUser(__CUSERID)
		oParams:SetTpExec		( "6"		   		) // Reemitir a pré da Fatura Cancelada
		oParams:SetSituac		( "2"		   		) // Emissão
		oParams:SetDEmi			( dDatabase	   		)
		oParams:SetCFilaImpr	( ""		   		)
		oParams:SetDIniH		( StoD(aFaturas[1][8] ) )
		oParams:SetDFinH		( StoD(aFaturas[1][21]) )
		oParams:SetDIniT		( StoD(aFaturas[1][18]) )
		oParams:SetDFinT		( StoD(aFaturas[1][22]) )
		oParams:SetDIniD		( StoD(aFaturas[1][9] ) )
		oParams:SetDFinD		( StoD(aFaturas[1][23]) )
		oParams:SetDIniFA		( StoD(aFaturas[1][8] ) )
		oParams:SetDFinFA		( StoD(aFaturas[1][8] ) )
		oParams:SetCodFatur		( aFaturas[1][1]	)
		oParams:SetCodEscr		( aFaturas[1][2]	)

		cCodPre     := aFaturas[1][4]
		cNVVCOD     := aFaturas[1][10]
		cNW2COD     := aFaturas[1][11]
		cNT0COD     := aFaturas[1][19]
		cCodFixo    := ""
		cTEMTS      := aFaturas[1][13]
		cTEMLT      := aFaturas[1][14]
		cTEMDP      := aFaturas[1][15]
		cTEMFX      := aFaturas[1][16]
		cTEMFA      := aFaturas[1][17]
		cCLIPAG     := aFaturas[1][5]
		cLOJAPG     := aFaturas[1][6]
		cCASO       := aFaturas[1][20]
		cPONumber   := aFaturas[1][24]

		oParams:SetPreFat(cCodPre)
		oParams:SetContrato(cNT0COD)

		Processa({|| aRet := JA204RefPF(oParams, cCodFixo, cNVVCOD, cNW2COD,;
										cNT0COD, cCLIPAG, cLOJAPG, cCASO, cTEMTS, cTEMLT,;
										cTEMDP, cTEMFX, cTEMFA, cCodPre, cPONumber ) }, STR0037, STR0088, .F.) // "Aguarde..." "Refazendo a Prè-Fatura..."
	EndIf

EndIf

RestArea( aArea )

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA204RefPF
Reemite a pré ao cancelar a Fatura

@author David Gonçalves Fernandes
@since 24/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA204RefPF( oParams, cCodFixo, cNVVCOD, cNW2COD, cNT0COD, cCLIPAG, cLOJAPG, cCASO, cTEMTS, cTEMLT, cTEMDP, cTEMFX, cTEMFA, cCodPre, cPONumber )
Local aRet     := {.T., "JA204RefPF"}
Local cCPART   := ''
Local cCMOEDFT := ''
Local cCRELAT  := ''

Default cPONumber := ""

ProcRegua( 0 )
IncProc()
IncProc()
IncProc()
IncProc()
IncProc()

aRet := JA201BVinc(oParams, cCodFixo, cCodPre, cNVVCOD, cNW2COD, cNT0COD, "", "", "", cTEMTS, cTEMLT, cTEMDP, cTEMFX, cTEMFA )

If aRet[1]
	cCPART := JurGetDados('NX0', 1, xFilial('NX0') + cCodPre, 'NX0_CPART')
	// Verifica se existe mais uma fatura válida, casso contrario tenta reemitir

	NX0->( DbSetOrder(1) ) //NX0_FILIAL+NX0_COD
	If !(NX0->( DbSeek(xFilial("NX0") + cCodPre)))
		aRet := JA201CEmi(oParams, cCodPre, cNVVCOD, cNW2COD, cNT0COD )
		If !aRet[1]
			J202HIST("99", cCodPre, cCPART, STR0084 + " JURA204-JA204RefPF | " + aRet[2])// Erro ao refazer a pré-fatura
		EndIf
	Else

		//Verificar EscritÃ³rio e Filial de emissÃ£o (se houver junÃ§Ã£o Ã© da junÃ§Ã£o)
		cCMOEDFT    := JurGetDados("NX0", 1, xFilial("NX0") + cCodPre, "NX0_CMOEDA")

		//nÃ£o precisa - pega dos pagadores
		If !Empty(cNW2COD)
			cCRELAT := JurGetDados("NW2", 1, xFilial("NW2") + cNW2COD, "NW2_CRELAT")
		Else
			cCRELAT := JurGetDados("NT0", 1, xFilial("NT0") + cNT0COD, "NT0_CRELAT")
		EndIf

		//Totaliza Caso
		If aRet[1]
			aRet := JA201DCaso(oParams, cCodPre, cCMOEDFT, cNVVCOD, cNW2COD, cNT0COD)
		EndIf

		//Totaliza Contrato
		If aRet[1]
			aRet := JA201ECont(oParams, cCodPre, cCMOEDFT, cNVVCOD, cNW2COD, cNT0COD)
		EndIf

		//Totaliza Pré
		If aRet[1]
			aRet := JA201HPreF(oParams, cCodPre, cCMOEDFT, cNVVCOD, cNW2COD, cNT0COD, cCRELAT)
		EndIf

		//Ajusta o status da pré-fatura para definitiva, caso já tenha faturamento de algum pagador da pré;
		NX0->( DbSetOrder(1) ) //NX0_FILIAL+NX0_COD
		If (NX0->( DbSeek(xFilial("NX0") + cCodPre)))
			RecLock("NX0", .F.)
			NX0->NX0_SITUAC := Iif(JA201TemFt(cCodPre), "4", "2")
			NX0->NX0_USRALT := JurUsuario(__CUSERID)
			NX0->NX0_DTALT  := Date()
			NX0->NX0_FATOLD := oParams:GetCodFatur()
			NX0->NX0_ESCOLD := oParams:GetCodEscr()
			NX0->NX0_PONUMB := cPONumber
			If NX0->(FieldPos('NX0_FATURA')) > 0
				NX0->NX0_FATURA := Iif(J203IsFat(cCodPre), "1", "2")
			EndIf
			NX0->(MsUnlock())
			NX0->(DbCommit())

			//Insere o Histórico na pré-fatura
			J202HIST('6', cCodPre, cCPART)

			//Marca as cotações da Pré de Faturas canceladas com alteradas para não serem atualizadas pelo sistema.
			J204CotFTCan(cCodPre)

		Else
			J202HIST("99", cCodPre, cCPART, STR0084 + " JURA204-JA204RefPF | " + aRet[2])// Erro ao refazer a pré-fatura
		EndIf

	EndIf

Else
	J202HIST("99", cCodPre, cCPART, STR0084 + " JURA204-JA204RefPF | " + aRet[2])  // Erro ao refazer a pré-fatura
EndIf

Return ( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} J204AllDocs
Busca os documentos das faturas geradas

@author Daniel Magalhaes
@since 09/01/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function J204AllDocs()
Local aErros    := {}
Local cQuery    := ""
Local cAliasQry := GetNextAlias()
Local cQtdErros := ""
Local cRelErros := ""
Local nIdx      := 0
Local cImgFat   := ''

cQuery := " SELECT NXA.NXA_CESCR, NXA.NXA_COD"
cQuery +=   " FROM " + RetSqlName("NXA") + " NXA"
cQuery +=  " WHERE NXA.NXA_FILIAL = '" + xFilial("NXA") + "'"
cQuery +=    " AND NXA.NXA_SITUAC = '1'"
cQuery +=    " AND NXA.NXA_MAILEN = '2'"
cQuery +=    " AND NOT EXISTS (SELECT NXM.NXM_CFATUR"
cQuery +=                      " FROM " + RetSqlName("NXM") + " NXM"
cQuery +=                     " WHERE NXM.NXM_FILIAL = '" + xFilial("NXM") + "'"
cQuery +=                       " AND NXM.NXM_CESCR = NXA.NXA_CESCR"
cQuery +=                       " AND NXM.NXM_CFATUR = NXA.NXA_COD"
cQuery +=                       " AND NXM.D_E_L_E_T_ = ' ')"
cQuery +=    " AND NXA.D_E_L_E_T_ = ' '"
cQuery +=  " ORDER BY NXA.NXA_CESCR, NXA.NXA_COD"

cQuery := ChangeQuery(cQuery)

dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cAliasQry, .T., .F. )

ProcRegua(0)

While !(cAliasQry)->(Eof())

	IncProc(STR0137 + (cAliasQry)->NXA_CESCR + "/" + (cAliasQry)->NXA_COD ) //"Fatura: "
	cImgFat := JurImgFat((cAliasQry)->NXA_CESCR, (cAliasQry)->NXA_COD, .T.)

	If !J204GetDocs( (cAliasQry)->NXA_CESCR, (cAliasQry)->NXA_COD, , , cImgFat, .F.)
		aAdd( aErros, {(cAliasQry)->NXA_CESCR, (cAliasQry)->NXA_COD, cImgFat} )
	EndIf

	(cAliasQry)->( DbSkip() )
EndDo

(cAliasQry)->( DbCloseArea() )

If Len(aErros) > 0

	cQtdErros := AllTrim(Str( Len(aErros) ))

	If ApMsgYesNo(STR0138 + cQtdErros + STR0139 + CRLF + CRLF + STR0140 ) //"Existem "###" faturas que não possuem os documentos relacionados gravados na pasta do servidor: "###"Deseja exibir a relação completa?"
		cRelErros := "Escr. | Cód. Fatura | Pasta"
		cRelErros += CRLF + Replicate("-",Len(cRelErros))

		For nIdx := 1 To Len(aErros)
			cRelErros += CRLF + aErros[nIdx][1] + " | " + aErros[nIdx][2] + " | " + aErros[nIdx][3]
		Next nIdx

		cRelErros += CRLF + CRLF + "Total: " + cQtdErros

		J206MsgDlg(STR0141, {cRelErros}) //"Faturas sem Docs. Relacionados"

	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J204CanPG()
Rotina para cancelar as faturas dos demais pagadores

@Param	cCodPre	pré-fatura a ser analisada
@Param	cTipo		FT - Fatura , MF - Minuta de fatura, MP - Minuta de Pré-fatura
@Param	cMotivo	Motivo de cancelamento
@Param	cFixo		Fatura de Fixo à ser analisada
@Param	cFatAd		Fatura de fatura adicional à ser analisada

@return  lRet   - .T. se existir faturas; .F. se não existir faturas

@author Luciano Pereira dos Santos
@since 26/09/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J204CanPG(cCodPre, cTipo, cMotivo, cFixo, cFatAd)
Local lRet      := .T.
Local aResult   := {.T., ""}
Local aArea     := GetArea()
Local aAreaNXA  := NXA->(GetArea())
Local aAreaSE1  := SE1->(GetArea())
Local cAliasSE1 := GetNextAlias()
Local cFilSav   := cFilAnt
Local aCancFat  := {}
Local cFil      := ""
Local cQuery    := ""
Local cMemoFat  := ""
Local cMemoPre  := ""
Local nI        := 0

Default cTipo   := 'FT'
Default cFixo   := ''
Default cFatAd  := ''

If !Empty(cCodPre) .Or. !Empty(cFixo) .Or. !Empty(cFatAd)

	cQuery := " SELECT NXA.R_E_C_N_O_ NXA_RECNO"
	cQuery +=    " FROM " + RetSqlname('NXA') + " NXA"
	cQuery +=    " WHERE  NXA.NXA_FILIAL = '" + xFilial("NXA") + "'"
	Do Case
	Case !Empty(cCodPre)
		cQuery +=  " AND NXA.NXA_CPREFT = '" + cCodPre + "'"
	Case !Empty(cFixo)
		cQuery +=  " AND NXA.NXA_CFIXO = '" + cFixo + "'"
	Case !Empty(cFatAd)
		cQuery +=  " AND NXA.NXA_CFTADC = '" + cFatAd + "'"
	EndCase
	cQuery +=      " AND NXA.NXA_SITUAC = '1'"
	cQuery +=      " AND NXA.NXA_TIPO   = '" + cTipo + "'"
	If !SuperGetMV("MV_JFATXNF", .F., .F.) // Filtra somente se o fluxo de emissão e cancelamento de Nota Fiscal a partir da fatura estiver desativado
		cQuery +=  " AND (NXA.NXA_NFGER = '2' OR NXA.NXA_NFGER = '3')"
	EndIf
	cQuery +=      " AND NXA.D_E_L_E_T_ = ' '"

	aCancFat := JurSQL(cQuery, {'NXA_RECNO'})

	For nI := 1 To Len(aCancFat)

		NXA->(DbGoto(aCancFat[nI][1]))

		cFil := JurGetDados( "NS7", 1, xFilial("NS7") + NXA->NXA_CESCR, "NS7_CFILIA" )

		cQuery := JA204Query( 'TI', xFilial( 'NXA' ), NXA->NXA_COD, NXA->NXA_CESCR, cFil )

		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasSE1, .T., .T. )

		SE1->( DbsetOrder( 1 ) )

		(cAliasSE1)->( Dbgotop() )

		//Verifica se algum titulo foi identificado com baixas fora do SIGAPFS
		Do While !(cAliasSE1)->( Eof()) .And. lRet
			lRet := !J204BxSE1( (cAliasSE1)->SE1RECNO )
			(cAliasSE1)->( dbSkip() )
		EndDo

		(cAliasSE1)->( dbcloseArea() )

		If !lRet
			cMemoFat +=( STR0144 + NXA->NXA_COD   ) + CRLF //"FATURA .....: "
			cMemoFat +=( STR0145 + NXA->NXA_CESCR ) + CRLF //"ESCRITÓRIO .: "
			cMemoFat +=( Replicate('-', 80)       ) + CRLF+CRLF

		Else
			Do Case
			Case NXA->NXA_TIPO $ "MF|MP|MS"
				cTipo := (STR0130 + NXA->NXA_COD) // "Cancelando a Minuta " + NXA->NXA_COD
			OtherWise
				cTipo := (STR0129 + NXA->NXA_COD) // "Cancelando a Fatura " + NXA->NXA_COD
			EndCase

			Processa( { || lRet := JA204CanFa(cMotivo) }, STR0037, cTipo, .F. )  //'Aguarde'###

			If lRet .And. NXA->NXA_TIPO == 'FT'

				If !Empty(NXA->NXA_CPREFT)
					aResult := JA204RPre(NXA->NXA_CESCR, NXA->NXA_COD)

					If !aResult[1]
						cMemoPre := STR0084 + NXA->NXA_CPREFT + CRLF + aResult[2] //"Erro ao refazer a Pré-Fatura "
					EndIf
				EndIf

			EndIf

		EndIf

	Next nI

	cFilAnt := cFilSav

	cMemoFat := cMemoFat + cMemoPre

	If !Empty(cMemoFat)
		JurErrLog(STR0142 + CRLF + CRLF + cMemoFat, STR0083) //"A(s) seguente(s) fatura(s) não foram cancelada(s) por estar(em) com baixa fora do SIGAPFS:"  ## "Cancelamento de Fatura"
		lRet := .F.
	Else
		If Len(aCancFat) > 0 .And. lRet .And. !FwIsInCallStack("JA206PROC")
			ApMsgInfo(STR0085) //"Operação realizada com sucesso!"
		EndIf
	EndIf

EndIf

RestArea( aArea )
RestArea( aAreaNXA )
RestArea( aAreaSE1 )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204CanMin()
Rotina de alterar situação da pre-fatura de minuta cancelada

@Param	cPreFat - Codigo da pré-fatura
@Param	cEscrit - Escritório da Minuta de fatura cancelada
@Param	cFatur  - Código da Minuta de fatura cancelada

@return lRet	- .T. Exito na alteração

@author Luciano Pereira dos Santos
@since 14/06/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204CanMin(cPreFat, cEscrit, cFatur, cTipo)
Local lRet      := .T.
Local aArea     := GetArea()
Local aAreaNX0  := NX0->(GetArea())

DbselectArea("NX0")
NX0->( dbSetOrder(1) ) //NX0_FILIAL+NX0_COD+NX0_SITUAC
If NX0->( dBSeek( xFilial("NX0") + cPreFat ) )
	RecLock("NX0", .F.)
	If cTipo == "MS"
		NX0->NX0_SITUAC := "B"
	Else
		NX0->NX0_SITUAC := "7"
	EndIf
	NX0->NX0_USRALT := JurUsuario(__CUSERID)
	NX0->NX0_DTALT  := Date()
	NX0->NX0_FATOLD := cFatur
	NX0->NX0_ESCOLD := cEscrit
	NX0->(MsUnLock())
	NX0->(dbCommit())
	If NX0->NX0_SITUAC == "7"
		J170GRAVA("JURA202E", xFilial("NX0") + cPreFat, "4")
	EndIf
Else
	lRet := .F.
EndIf

RestArea( aAreaNX0 )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204AjImp(nRecnoSE1)
Rotina de recalculo de retenção de impostos.
Trecho retirado do Fonte FINA040.PRX Rotina Fa040Delet Linha 1404-1497.
Em caso de manutenção verificar rotina original.
Obs: Bloco implementado para recalcular impostos com origem SFQ no Retentor
é exclusivo para o PFS e não consta na rotina original.

@param  nRecnoSE1 - Recno do titulo cancelado pelo PFS

@return Nil

@author Luciano Pereira dos Santos
@since 25/04/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204AjImp(nRecnoSE1)
Local aArea        := GetArea()
Local aAreaSA1     := SA1->(GetArea())
Local aAreaSE1     := SE1->(GetArea())
Local aAreaSFQ     := SFQ->(GetArea())
Local cRetCli      := "1"
Local cModRet      := GetNewPar( "MV_AB10925", "0" )
Local lTemSfq      := .F.
Local lExcRetentor := .F.
Local nTotGrupo    := 0
Local lBaseImp     := If(FindFunction('F040BSIMP'), F040BSIMP(2), .F.)
Local nValBase     := 0
Local nBaseAtual   := 0
Local nBaseAntiga  := 0
Local nProp        := 0
Local aDadRet      := {,,,,,,,.F.}
Local nValMinRet   := GetNewPar("MV_VL10925", 5000)
Local aVlrTotMes   := {}
Local dVencRea     := CToD( '  /  /  ' )
Local cCliente     := ""
Local cLoja        := ""
Local nValorDif    := 0
Local nValorDDI    := 0
Local lRecalcImp   := .F.
Local nX           := 0

Private nIndexSE1  := 0
Private cIndexSE1  := ""
Private lF040Auto  := .T.
Private lAltera    := .T.

SE1->( dbGoTo( nRecnoSE1 ) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza o saldo das duplicatas em clientes, valor acumulado e saldo bancario ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !IsBlind() // Retirar após a correção da função na FINXAPI
	FaAvalSE1( 2, "JURA204" )
EndIf

cCliente := SE1->E1_CLIENTE
cLoja    := SE1->E1_LOJA

SA1->( dbSetOrder( 1 ) )
If SA1->( dbSeek( xFilial( "SA1" ) + cCliente + cLoja ) )
	cRetCli := Iif(Empty(SA1->A1_ABATIMP), "1", SA1->A1_ABATIMP)
EndIf

If cRetCli == "1" .And. cModRet == "2"
	SE1->(dbGoto(nRecnoSE1))
	SFQ->(DbSetOrder(1))
	If SFQ->(MsSeek(xFilial("SFQ") + "SE1" + SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA)))
		lTemSfq := .T.
		lExcRetentor := .T.
	Else
		SFQ->(DbSetOrder(2))
		If SFQ->(MsSeek(xFilial("SFQ") + "SE1" + SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA)))
			lTemSfq := .T.
		EndIf
	EndIf
	If lTemSfq
		// Altera Valor dos abatimentos do titulo retentor e tambem dos titulos gerados por ele.
		nTotGrupo   := F040TotGrupo(xFilial("SFQ") + "SE1" + SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA), Left(Dtos(SE1->E1_VENCREA), 6))
		nValBase    := If (lBaseImp .And. SE1->E1_BASEIRF > 0, SE1->E1_BASEIRF, SE1->E1_VALOR)
		nTotGrupo   -= nValBase
		nBaseAtual  := nTotGrupo
		nBaseAntiga := nTotGrupo + nValBase
		nProp       := nBaseAtual / nBaseAntiga
		aDadRet     := F040AltRet(xFilial("SFQ") + "SE1" + SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA), nProp, 0, nTotGrupo <= nValMinRet) // Altera titulo retentor
	EndIf

	If !aDadRet[8] // Retentor estah em aberto
		SFQ->(DbSetOrder(2)) // FQ_FILIAL+FQ_ENTDES+FQ_PREFDES+FQ_NUMDES+FQ_PARCDES+FQ_TIPODES+FQ_CFDES+FQ_LOJADES
		If SFQ->(MsSeek(xFilial("SFQ") + "SE1" + SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA)))
			lTemSfq := .T.
			If nTotGrupo <= nValMinRet
				// Exclui o relacionamento SFQ
				SE1->(DbSetOrder(1))
				If SE1->(MsSeek(xFilial("SE1") + SFQ->(FQ_PREFORI + FQ_NUMORI + FQ_PARCORI + FQ_TIPOORI)))
					aRecSE1 := FImpExcTit("SE1", SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA)
					For nX := 1 To Len(aRecSE1)
						SE1->(MSGoto(aRecSE1[nX]))
						FaAvalSE1(4)
					Next
					// Recalculo os impostos quando a base ficou menor que o valor minimo //
					aVlrTotMes := F040TotMes(SE1->E1_VENCREA, @nIndexSE1, @cIndexSE1)
					If (aVlrTotMes[1] - (IIf(lBaseImp .And. SE1->E1_BASEIRF > 0, SE1->E1_BASEIRF, SE1->E1_VALOR))) <= 5000
						dVencRea := SE1->E1_VENCREA
						F040RecalcMes(dVencRea, nValMinRet, cCliente, cLoja, .T.)
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Exclui os registros de relacionamentos do SFQ                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FImpExcSFQ("SE1", SFQ->FQ_PREFORI, SFQ->FQ_NUMORI, SFQ->FQ_PARCORI, SFQ->FQ_TIPOORI, SFQ->FQ_CFORI, SFQ->FQ_LOJAORI)
				EndIf
			EndIf
			RecLock("SFQ", .F.)
			DbDelete()
			MsUnlock()
		EndIf
		SFQ->(DbSetOrder(1))
		SE1->(MsGoto(nRecnoSE1))
		// Caso o total do grupo for menor ou igual ao valor minimo de acumulacao,
		// e o retentor nao estava baixado. Recalcula os impostos dos titulos do mes
		// que possivelmente foram incluidos apos a base atingir o valor minimo
		If (nTotGrupo <= nValMinRet .And. lTemSfq) .Or.;
			(lTemSfq .And. lExcRetentor)
			lRecalcImp := .T.
			dVencRea   := SE1->E1_VENCREA
		EndIf
	ElseIf lTemSfq
		SFQ->(DbSetOrder(2))// FQ_FILIAL+FQ_ENTDES+FQ_PREFDES+FQ_NUMDES+FQ_PARCDES+FQ_TIPODES+FQ_CFDES+FQ_LOJADES
		If SFQ->(MsSeek(xFilial("SFQ") + "SE1" + SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA)))
			RecLock("SFQ", .F.)
			DbDelete()
			MsUnlock()
		EndIf

		// Gera DDI
		// Calcula valor do DDI
		nValorDif := nBaseAtual - nBaseAntiga

		//Caso a base atua seja menor que o valor minimo de retencao (MV_VL10925)
		//O DDI sera o valor total dos impostos retidos do grupo (retidos + retentor)
		//Nao retirar o -1 pois neste caso o valor da diferenca eh o valor da base antiga
		//ja que os impostos foram descontados indevidamente. (Pequim & Claudio)
		If nBaseAtual <= nValMinRet
			nValorDif := (nBaseAntiga * (-1))
		EndIf

		nValorDDI := Round(nValorDif * (SED->(ED_PERCPIS + ED_PERCCSL + ED_PERCCOF) / 100), TamSx3("E1_VALOR")[2])

		If nValorDDI < 0
			nValorDDI := Abs(nValorDDI)
			// Se ja existir um DDI gerado para o retentor, calcula a diferenca do novo DDI.
			SE1->(DbSetOrder(1))
			If SE1->(MsSeek(xFilial("SE1") + aDadRet[1] + aDadRet[2] + aDadRet[3] + "DDI"))
				If (SE1->E1_VALOR == SE1->E1_SALDO)
					nValorDDI := nValorDDI - SE1->E1_VALOR
					RecLock("SE1", .F.)
					SE1->E1_VALOR := nValorDDI
					SE1->E1_SALDO := nValorDDI
					MsUnlock()
				EndIf
			Else
				GeraDDINCC( aDadRet[1],;
				            aDadRet[2],;
				            aDadRet[3],;
				            "DDI",;
				            aDadRet[5],;
				            aDadRet[6],;
				            aDadRet[7],;
				            nValorDDI,;
				            dDataBase,;
				            dDataBase,;
				            "APDIFIMP",;
				            lF040Auto )
			EndIf
		EndIf
	EndIf
EndIf

RestArea( aArea )
RestArea( aAreaSA1 )
RestArea( aAreaSE1 )
RestArea( aAreaSFQ )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J204DtVenc()
Rotina de recalculo de impostos do titulo retentor de impostos quando
o mesmo for o único no mes para qual foi transferido
Em caso de manutenção verificar rotina original.

@param  nRecnoSE1 - Recno do titulo transferido pelo PFS
@param  dDtVenc   - Nova data de Vencimento
@param  cFil      - Filial da Fatura

@return lRet

@author Luciano Pereira dos Santos
@since 27/04/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204AlVenc(nRecnoSE1, dDtVenc, cFil)
Local lRet          := .F.
Local cMoedNac      := SuperGetMV( 'MV_JMOENAC',, '01' )
Local aArea         := GetArea()
Local aAreaSE1      := SE1->(GetArea())
Local aAreaSED      := SED->(GetArea())
Local aAreaNXA      := NXA->(GetArea())
Local aSE1          := {}
Local cSE1Key       := ""
Local dDtVencRe     := dDtVenc
Local cFilAtu       := cFilAnt

Private lMsErroAuto := .F.

SE1->( dbGoTo( nRecnoSE1 ) )

cFilAnt := cFil

While !JurIsDUtil( dDtVencRe )
	dDtVencRe += 1
End

Begin Transaction

	cSE1Key := SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA)
	
	If (lRet := J204AltOri(cSE1Key, "FINA040"))
		If !(dDtVenc == SE1->E1_VENCREA)
	
			aAdd( aSE1, { 'E1_FILIAL ', SE1->E1_FILIAL      , NIL } )
			aAdd( aSE1, { 'E1_PREFIXO', SE1->E1_PREFIXO     , NIL } )
			aAdd( aSE1, { 'E1_NUM    ', SE1->E1_NUM         , NIL } )
			aAdd( aSE1, { 'E1_PARCELA', SE1->E1_PARCELA     , NIL } )
			aAdd( aSE1, { 'E1_TIPO   ', SE1->E1_TIPO        , NIL } )
			aAdd( aSE1, { 'E1_EMISSAO', SE1->E1_EMISSAO     , NIL } )
			aAdd( aSE1, { 'E1_VENCTO ', dDtVenc             , NIL } )
			aAdd( aSE1, { 'E1_VENCREA', dDtVencRe           , NIL } )
			aAdd( aSE1, { 'E1_NATUREZ', SE1->E1_NATUREZ     , NIL } )
			aAdd( aSE1, { 'E1_CLIENTE', SE1->E1_CLIENTE     , NIL } )
			aAdd( aSE1, { 'E1_LOJA   ', SE1->E1_LOJA        , NIL } )
			aAdd( aSE1, { 'E1_HIST   ', SE1->E1_HIST        , NIL } )
			aAdd( aSE1, { 'E1_VEND1  ', SE1->E1_VEND1       , NIL } )
			aAdd( aSE1, { 'E1_ORIGEM ', SE1->E1_ORIGEM      , NIL } )
			aAdd( aSE1, { 'E1_JURFAT ', SE1->E1_JURFAT      , NIL } )
			aAdd( aSE1, { 'E1_PORTADO', SE1->E1_PORTADO     , NIL } )
			aAdd( aSE1, { 'E1_AGEDEP ', SE1->E1_AGEDEP      , NIL } )
			aAdd( aSE1, { 'E1_CONTA  ', SE1->E1_CONTA       , NIL } )
			aAdd( aSE1, { 'E1_VALOR  ', SE1->E1_VALOR       , NIL } )
	
			If NXA->NXA_CMOEDA <> cMoedNac
				aAdd( aSE1, { 'E1_MOEDA  ', SE1->E1_MOEDA   , NIL } )
				aAdd( aSE1, { 'E1_VLCRUZ ', SE1->E1_VLCRUZ  , NIL } )
				aAdd( aSE1, { 'E1_TXMOEDA', SE1->E1_TXMOEDA , NIL } )
			EndIf
		Else
			aAdd( aSE1, { 'E1_FILIAL ', SE1->E1_FILIAL      , NIL } )
			aAdd( aSE1, { 'E1_PREFIXO', SE1->E1_PREFIXO     , NIL } )
			aAdd( aSE1, { 'E1_NUM    ', SE1->E1_NUM         , NIL } )
			aAdd( aSE1, { 'E1_PARCELA', SE1->E1_PARCELA     , NIL } )
			aAdd( aSE1, { 'E1_TIPO   ', SE1->E1_TIPO        , NIL } )
			aAdd( aSE1, { 'E1_EMISSAO', SE1->E1_EMISSAO     , NIL } )
			aAdd( aSE1, { 'E1_VENCTO ', dDtVenc             , NIL } )
			aAdd( aSE1, { 'E1_VENCREA', dDtVencRe           , NIL } )
		EndIf
	
		aSE1 := JurVet2Aut( aSE1, 'SE1', .F. )
	
		DbSelectArea( 'SE1' )
		SE1->( dbSetOrder( 1 ) )
	
		DbSelectArea( 'SED' )
		SED->( DbSetOrder( 1 ) ) //ED_FILIAL+ED_CODIGO
		If SED->(DbSeek( xFilial("SED") + SE1->E1_NATUREZ)) //Ch7957 garantir o posicionamento da natureza de Operação
	
			lMsErroAuto := .F.
	
			MSExecAuto( { | _x, _y | SE1->( FINA040( _x, _y ) ) }, aSE1, 4 )
	
			If lMsErroAuto
				lRet := .F.
				DisarmTransaction()
			Else
	
				While __lSX8
					ConFirmSX8()
				EndDo
	
			EndIf
	
		Else
			ApMsgStop(STR0154 +"'"+ AllToChar(SE1->E1_NATUREZ) +"'"+ STR0155)  //###"O código de natureza de operação " ### " não é válido!"
		EndIf
	
	EndIf
	
	lRet := J204AltOri(cSE1Key, "JURA203")

End Transaction

cFilAnt := cFilAtu

RestArea( aAreaSE1 )
RestArea( aAreaSED )
RestArea( aAreaNXA )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204AltOri(cSE1Key,cOrigem)
Rotina para alterar o titulo para o ExecAuto recalcular os impostos

@Param	cSE1Key - Chave da tabela SE1.
@Param	cOrigem - Origem do titulo.

@return  lRet

@author Luciano Pereira dos Santos
@since 27/04/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204AltOri(cSE1Key,cOrigem)
Local lRet      := .F.
Local aAreaSE1  := SE1->(GetArea())
Local aArea     := GetArea()

SE1->(DBgotop())
SE1->(DbSetOrder(1))
If SE1->(dbSeek(cSE1Key))
	While SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA) == (cSE1Key)
		RecLock("SE1", .F.)
		SE1->E1_ORIGEM := cOrigem
		SE1->(MsUnlock())
		SE1->(DbCommit())
		SE1->( dbSkip() )
	EndDo
	lRet := .T.
Else
	lRet := .F.
EndIf

RestArea( aAreaSE1 )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204AtuImp(cfatura, cEscrit, cOper)
Rotina para atualizar os impostos na fatura.

@Param	cfatura	- Codigo da Fatura.
@Param	cOrigem	- Codigo do Escritório.
@Param	cOper	- "1" : Grava na moeda da fatura os valores dos impostos
				  "2" : Retorna um array com os valores na moeda nacional

@return  aRet	- [1][1] : Retorno lógico da rotina .T. ou .F.
				  [2][1] : Valor de IRRF;
				  [2][2] : Valor de ISS;
				  [2][3] : Valor de INSS;
				  [2][4] : Valor de PIS;
				  [2][5] : Valor de COFINS;
				  [2][6] : Valor de CSLL;

@author Luciano Pereira dos Santos
@since 27/04/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function J204AtuImp(cFatura, cEscrit, cOper )
Local aImpostos := { 0, 0, 0, 0, 0, 0 }
Local aRet      := {.F., aImpostos}
Local aImpOld   := { 0, 0, 0, 0, 0, 0 }
Local aPercent  := {}
Local aSE1      := {}
Local aArea     := GetArea()
Local aAreaSE1  := SE1->( GetArea() )
Local aAreaSED  := SED->( GetArea() )
Local aAreaNXA  := NXA->( GetArea() )
Local cFilNS7   := JurGetDados('NS7', 1, xFilial('NS7') + cEscrit, 'NS7_CFILIA')
Local cFatJur   := ""
Local cQuery    := ""
Local cAliasSE1 := GetNextAlias()
Local cNaturez  := ''
Local cOrigem	:= PadR("JURA203", TamSX3("E1_ORIGEM")[1])

Default cOper	:= "1"

//Chave de busca da tabela SE1, campo E1_JURFAT utilizada na query abaixo
cFatJur := xFilial( 'NXA' ) + '-' + cEscrit + '-' + cFatura + '-' + cFilNS7

//Seleciona os titulos da fatura ativa
cQuery := "SELECT SE1.E1_FILIAL, SE1.E1_CLIENTE, SE1.E1_LOJA,"
cQuery += " SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_NATUREZ, SE1.E1_MOEDA"
cQuery +=  " FROM " + RetSQLName("SE1") + " SE1"
cQuery += " WHERE SE1.D_E_L_E_T_ = ' '"
cQuery +=   " AND SE1.E1_FILIAL = '" + FWxFilial("SE1",cFilNS7) + "'"
cQuery +=   " AND SE1.E1_JURFAT = '" + cFatJur + "'"
cQuery +=   " AND SE1.E1_ORIGEM = '" + cOrigem + "'"

cQuery := ChangeQuery( cQuery, .F.)
dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cAliasSE1, .T., .F. )

cNaturez := (cAliasSE1)->E1_NATUREZ

Do while !(cAliasSE1)->( Eof() )

	aSE1 := {}
	aAdd( aSE1, { 'E1_CLIENTE', (cAliasSE1)->E1_CLIENTE  , NIL } )
	aAdd( aSE1, { 'E1_LOJA   ', (cAliasSE1)->E1_LOJA     , NIL } )
	aAdd( aSE1, { 'E1_PREFIXO', (cAliasSE1)->E1_PREFIXO  , NIL } )
	aAdd( aSE1, { 'E1_NUM    ', (cAliasSE1)->E1_NUM      , NIL } )
	aAdd( aSE1, { 'E1_PARCELA', (cAliasSE1)->E1_PARCELA  , NIL } )
	aAdd( aSE1, { 'E1_NATUREZ', (cAliasSE1)->E1_NATUREZ  , NIL } )

	J203VerImp(aSE1, "1", @aImpostos, (cAliasSE1)->E1_FILIAL, StrZero((cAliasSE1)->E1_MOEDA, 2))

	(cAliasSE1)->( DbSkip() )

EndDo

(cAliasSE1)->(DbCloseArea())

If cOper == "1"

	DbSelectArea('SED')
	SED->(dbSetOrder(1)) //ED_FILIAL+ED_CODIGO
	If SED->(dbSeek(xFilial("SED") + cNaturez))

		DbSelectArea('NXA')
		NXA->(dbSetOrder(1)) //NXA_FILIAL+NXA_CESCR+NXA_COD
		If NXA->(dbSeek(xFilial("NXA") + cEscrit + cfatura))
			aPercent := J203PerNat(cNaturez, NXA->NXA_CLIPG, NXA->NXA_LOJPG)

			aImpOld[1]   := NXA->NXA_IRRF
			aImpOld[2]   := NXA->NXA_ISS
			aImpOld[3]   := NXA->NXA_INSS
			aImpOld[4]   := NXA->NXA_PIS
			aImpOld[5]   := NXA->NXA_COFINS
			aImpOld[6]   := NXA->NXA_CSLL

			RecLock("NXA",.F.)
			NXA->NXA_IRRF   := aImpostos[1]
			NXA->NXA_ISS    := aImpostos[2]
			NXA->NXA_INSS   := aImpostos[3]
			NXA->NXA_PIS    := aImpostos[4]
			NXA->NXA_COFINS := aImpostos[5]
			NXA->NXA_CSLL   := aImpostos[6]
			NXA->(MsUnlock())
			NXA->(DbCommit())

			//Grava as Aliquotas dos Impostos
			RecLock("NXA",.F.)
			If NXA->NXA_IRRF != aImpOld[1]
				NXA->NXA_PIRRF  := Iif(aImpostos[1] > 0.00, aPercent[1], 0)
			EndIf
			If NXA->NXA_PIS != aImpOld[4]
				NXA->NXA_PPIS   := Iif(aImpostos[4] > 0.00, aPercent[2], 0)
			EndIf
			If NXA->NXA_COFINS != aImpOld[5]
				NXA->NXA_PCOFIN := Iif(aImpostos[5] > 0.00, aPercent[3], 0)
			EndIf
			If NXA->NXA_CSLL != aImpOld[6]
				NXA->NXA_PCSLL  := Iif(aImpostos[6] > 0.00, aPercent[4], 0)
			EndIf
			If NXA->NXA_INSS != aImpOld[3]
				NXA->NXA_PINSS  := Iif(aImpostos[3] > 0.00, aPercent[5], 0)
			EndIf
			NXA->(MsUnlock())
			NXA->(DbCommit())
			//Grava na fila de sincronização a alteração
			J170GRAVA("NXA", xFilial("NXA") + NXA->NXA_CESCR + NXA->NXA_COD, "4")

			aRet := {.T., aImpostos}

		EndIf

	Else
		ApMsgStop(STR0154 +"'"+ cNaturez +"'"+ STR0155)  //###"O código de natureza de operação " ### " não é válido!"
	EndIf

Else
	aRet := {.T., aImpostos}
EndIf

RestArea( aAreaSED )
RestArea( aAreaSE1 )
RestArea( aAreaNXA )
RestArea( aArea    )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204Venc()
Rotina para validar alteração de data de vencimento da fatura

@return lRet

@author Luciano Pereira dos Santos
@since 21/06/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function J204Venc()
Local lRet := .T.

If IsInCallStack("JURA204")
	lRet := M->NXA_DTVENC >= M->NXA_DTEMI
	If !lRet
		JurMsgErro(STR0151) //"Data de vencimento não pode ser menor que a data de emissão da fatura!"
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204CotFTCan(cCodPre)
Rotina para marcar as cotações como alteradas por cancelamento de fatura, provenientes de Reemissão
de Pré-fatura de fatura cancelada.

@param cCodPre - Codigo da pré-fatura

@author Luciano Pereira dos Santos
@since 26/11/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function J204CotFTCan(cCodPre)
Local lRet    := .T.
Local aArea   := GetArea()

NXR->(DbSetOrder(1))
NXR->(DbGoTop())
If NXR->(DbSeek( xFilial("NXR") + cCodPre))
	While !NXR->(Eof()) .And. NXR->(NXR_FILIAL + NXR_CPREFT) == xFilial('NXR') + cCodPre
		RecLock("NXR", .F.)
		NXR->NXR_ALTCOT := '3'
		NXR->(MsUnlock())
		NXR->(DbCommit())
		NXR->(DbSkip())
	EndDo
Else
	lRet := .F.
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204SetMot()
Configura a variavel estatica que controla o Codigo do Motivo de
Cancelamento da Fatura

@param cCodMot - Codigo do motivo de cancelamento

@author Daniel Magalhaes
@since 17/12/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function J204SetMot(cCodMot)
Local lRet      := .T.

Default cCodMot := ""

If lRet := (Valtype(cCodMot) == "C")
	JA204CodMot := cCodMot
Else
	JA204CodMot := ""
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204CpoUsr()
Funcao para chamar os pontos de entrada para preenchimento dos campos
de usuarios nas telas de movimentos na Operacao de Faturas

@param cAlias    Alias da tabela de movimentos
                 NT1: Parcelas de pagto Fixo
                 NUE: Time Sheets
                 NVY: Despesas
                 NV4: Servicos Tabelas
                 NVV: Fatura Adicional

@author Daniel Magalhaes
@since 31/01/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function J204CpoUsr(cAlias)
Local cRet     := ""

Default cAlias := ""

Do Case
	Case cAlias == "NT1"
		If Existblock("J204CNT1")
			cRet := ExecBlock( "J204CNT1", .F., .F. )
		EndIf

	Case cAlias == "NUE"
		If Existblock("J204CNUE")
			cRet := ExecBlock( "J204CNUE", .F., .F. )
		EndIf

	Case cAlias == "NVY"
		If Existblock("J204CNVY")
			cRet := ExecBlock( "J204CNVY", .F., .F. )
		EndIf

	Case cAlias == "NV4"
		If Existblock("J204CNV4")
			cRet := ExecBlock( "J204CNV4", .F., .F. )
		EndIf

	Case cAlias == "NVV"
		If Existblock("J204CNVV")
			cRet := ExecBlock( "J204CNVV", .F., .F. )
		EndIf

EndCase

cRet := AllTrim(cRet)

If Len(cRet) > 0 .And. Right(cRet, 1) <> "|"
	cRet := cRet + "|"
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204ValCpUsr()
Valida os campos para montagem da query dos lancamentos da fatura

@param aCpUser  - Array contendo os campos de usuario
@param aCampos - Campos já exibidos pela rotina padrao

@return aRet    - Array com os campos validados.

@author Luciano Pereira dos Santos
@since 31/01/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204ValCpUsr(aCpUser, aCampos)
Local aRet      := {}
Local aArea     := GetArea()
Local cCpUser   := ""
Local nI        := 0

Default aCpUser := {}

For nI := 1 To Len(aCpUser)
	cCpUser := AllTrim(aCpUser[nI])
	If aScan(aCampos, cCpUser) == 0 .And. GetSx3Cache(cCpUser, "X3_CONTEXT") != "V"
		AAdd(aRet, cCpUser )
	EndIf
Next nI

RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA204Alter()
Função de chamada da View de Dados, permitindo habilitar a inclusão, alteração, exclusão do modelo de dados.

@param nOpc numero da operação: 3=Inclusão, 4=Alteração, 5=Exclusão.
@author Julio de Paula Paz
@since 04/09/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA204Alter(nOpc)
Local lRet
Local lConfirmou := .F.
Local aButtons   := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,STR0219},{.T.,STR0220},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil}} //"Confirmar"#"Fechar"

Begin Sequence
	nOperacao := nOpc
	If nOperacao == 4 // Alteração
		FWExecView( STR0007, 'JURA204', 4,, { || lConfirmou := .F. }, , , aButtons ) // Operação em Fatura
	EndIf
	nOperacao := 0

End Sequence

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204VldSrv(cCampoVld)
Funcao para validação da digitação de campos da tela de envio de e-mails.

@param	cCampoVld Campo em foco que chamou a validação.
@return .T. / .F. verdadeiro ou falso.

@author Julio de Paula Paz
@since 30/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J204VldSrv(cCampoVld, cServer, cUser, cPass, lAuth)
Local lRet     := .T.
Local aArea    := GetArea()
Local aOrd     := SaveOrd({"NR7", "NR8"})
Local aDadosUs := {}

Begin Sequence
	Do Case
	Case cCampoVld == "NR7_COD" .And. oTGetCodSe:IsModified()
		If Empty(oTGetCodSe:Valor)
			oTGetDescS:Valor := ""
		Else
			lRet := J204ECpo("NR7", oTGetCodSe:Valor, 1)
			If lRet
				oTGetDescS:Valor := JurGetDados('NR7', 1, xFilial('NR7') + oTGetCodSe:Valor, 'NR7_DESC')
				oTGetCodUs:Setfocus()
			Else
				MsgStop(STR0179, STR0178)  // "Código de servidor de e-mails inválido." ### "Atenção"
			EndIf
		EndIf

		oTGetCodUs:Valor := AvKey('', "NR8_COD")
		oTGetDesUs:Valor := AvKey('', "NR8_DESC")
		oTGetCodUs:Refresh()

	Case cCampoVld == "NR8_COD" .And. oTGetCodUs:IsModified()
		If Empty(oTGetCodUs:Valor)
			oTGetDesUs:Valor := ""
		Else
			aDadosUs := JurGetDados('NR8', 1, xFilial('NR8') + oTGetCodUs:Valor, {'NR8_CSERVI', 'NR8_DESC'})

			If !Empty(aDadosUs) .And. Len(aDadosUs) >= 2 .And. aDadosUs[1] == oTGetCodSe:Valor
				oTGetDesUs:Valor := aDadosUs[2]
			Else
				lRet := .F.
				oTGetDesUs:Valor := AvKey('', "NR8_DESC")
				MsgStop(STR0180, STR0178) // "Código do usuário do servidor de e-mails inválido." ### "Atenção"
			EndIf
		EndIf

	Case cCampoVld == "NRU_COD" .And. oTGetConf:IsModified()
		If Empty(oTGetConf:Valor)
			oTGetConfD:Valor := ""
		Else
			lRet := J204ECpo("NRU", oTGetConf:Valor, 1)
			If ! lRet
				MsgStop(STR0185, STR0178) // "O código de configuração de envio de e-mail não existe." ### "Atenção"
			EndIf
		EndIf

	Case cCampoVld == "BOTAO_ENVIAR"
		lRet := J204VldSrv("NR7_COD")
		If lRet
			lRet := J204VldSrv("NR8_COD")
		Else
			cServer := AvKey('', "NR7_COD")
			MsgStop(STR0181, STR0178) // "Nome do servidor de e-mails não informado." ### "Atenção"
			Break
		EndIf

		If !lRet
			cUser := AvKey('', "NR8_COD")
			MsgStop(STR0183, STR0178) // "Usuário de envio de e-mail não informado" ### "Atenção"
			Break
		Else
			NR7->(DbSetOrder(1))  // NR7_FILIAL+NR7_COD
			NR8->(DbSetOrder(1))  // NR8_FILIAL+NR8_COD
			NR7->(DbSeek(xFilial("NR7") + oTGetCodSe:Valor))
			cServer  := NR7->NR7_ENDERE
			lAuth    := If(NR7->NR7_AUTENT == "1", .T., .F.)
			NR8->(DbSeek(xFilial("NR8") + oTGetCodUs:Valor))
			Do While ! NR8->(Eof()) .And. NR8->(NR8_FILIAL + NR8_COD) == xFilial("NR8") + oTGetCodUs:Valor
				If NR7->NR7_COD == NR8->NR8_CSERVI
					cUser := NR8->NR8_EMAIL
					cPass := Decode64( Embaralha( AllTrim( NR8->NR8_SENHA ), 1 ) )
					Exit
				EndIf
				NR8->(DbSkip())
			EndDo
			Restord(aOrd)
			If Empty(cServer)
				lRet := .F.
				MsgStop(STR0181, STR0178) // "Nome do servidor de e-mails não informado." ### "Atenção"
			EndIf
			If lRet .And. Empty(lAuth)
				lRet := .F.
				MsgStop(STR0182, STR0178) // "Campo que informa se há autenticação do servidor não informado." ### "Atenção"
			EndIf
			If lRet .And. Empty(cUser)
				lRet := .F.
				MsgStop(STR0183, STR0178) // "Usuário de envio de e-mail não informado" ### "Atenção"
			EndIf
			If lRet .And. Empty(cPass)
				lRet := .F.
				MsgStop(STR0184, STR0178) // "Senha do usuário de envio de e-mail não informado" ### "Atenção"
			EndIf
		EndIf
	EndCase

End Sequence

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204ECpo()
Funcao para validar a existencia de um código passado por parâmetro na base de dados,
sem a exibição de mensagem padrão da função ExistCpo().

@param  cAliasTab Alias da tabeça a ser pesquisada.
@param  cExpressao expressão de pesquisa na tabela de dados.
@param  nIndice refere-se a ordem de pesquisa no índice da tabela.

@return .T. / .F. verdadeiro ou falso.

@author Julio de Paula Paz
@since 19/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function J204ECpo(cAliasTab, cExpressao, nIndice)
Local lRet      := .T.
Local aOrd      := SaveOrd({cAliasTab})

Default nIndice := 1

Begin Sequence
	(cAliasTab)->(DbSetOrder(nIndice))
	lRet := (cAliasTab)->(DbSeek(xFilial(cAliasTab) + cExpressao))
End Sequence

RestOrd(aOrd, .T.)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA204CoRaz(oModel)
Funcao para replicar a razão social alterada na fatura para o cadastro do cliente.

@author Bruno Ritter
@since 09/03/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA204CoRaz(oModel)
Local lRet       := .T.
Local cRazSocNov := oModel:GetValue('NXAMASTER', 'NXA_RAZSOC')
Local cCliPg     := oModel:GetValue('NXAMASTER', 'NXA_CLIPG')
Local cLojPg     := oModel:GetValue('NXAMASTER', 'NXA_LOJPG')
Local oModelSA1  := NIL
Local aErro      := {}
Local cMsgErro   := ""
Local cFilEscr   := JurGetDados("NS7", 1, xFilial("NS7") + oModel:GetValue('NXAMASTER', 'NXA_CESCR'), "NS7_CFILIA")
Local cFilAtu    := cFilAnt

cFilAnt := cFilEscr

oModelSA1 := FwLoadModel("JURA148")

DbSelectArea("SA1")
SA1->( dbSetOrder( 1 ) )
If SA1->(DbSeek(xFilial('SA1') + cCliPg + cLojPg))
	oModelSA1:SetOperation(MODEL_OPERATION_UPDATE)
	oModelSA1:Activate()
	oModelSA1:SetValue("SA1MASTER", "A1_NOME", cRazSocNov)

	lRet := oModelSA1:VldData()
	If lRet
		lRet := oModelSA1:CommitData()
	EndIf

	If !lRet
		aErro    := oModelSA1:GetErrorMessage()
		cMsgErro := I18N(STR0212, {cCliPg, cLojPg}) //"Erro ao replicar a razão social para o cadastro do cliente '#1'/'#2'. Detalhes:"
		cMsgErro += Iif(Len(aErro) >= 6, + CRLF + aErro[6], "")//Mensagem de erro do model

		JurMsgErro(cMsgErro,;
				"JA204CoRaz",;
				STR0213;//"Verifique o cadastro do cliente:"
				+ CRLF+ RetTitle("A1_FILIAL") +" = "+ xFilial('SA1'); //Filial
				+ CRLF+ RetTitle("A1_COD")    +" = "+ cCliPg        ; //Código do cliente
				+ CRLF+ RetTitle("A1_LOJA")   +" = "+ cLojPg        ) // Loja
	EndIf
Else
	lRet := JurMsgErro(STR0206,; //"Não foi possível localizar o cliente para ser replicado a alteração da Razão Social."
				"JA204CoRaz",;
				STR0213;//"Verifique o cadastro do cliente:"
				+ CRLF+ RetTitle("A1_FILIAL") +" = "+ xFilial('SA1'); //Filial
				+ CRLF+ RetTitle("A1_COD")    +" = "+ cCliPg        ; //Código do cliente
				+ CRLF+ RetTitle("A1_LOJA")   +" = "+ cLojPg        ) // Loja
EndIf

cFilAnt := cFilAtu

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA204WRaSo()
Função para o When do campo NXA_RAZSOC

@author Bruno Ritter
@since 14/02/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA204WRaSo()
Local lRet    := .F.
Local cAltRaz := SuperGetMV('MV_JALTRAZ',, '0')
Local oModel  := FwModelActive()
Local cNfGer  := Iif(oModel:cId == 'JURA204', oModel:GetValue('NXAMASTER', 'NXA_NFGER'), FwFldGet("NXA_NFGER"))

	Do Case
	Case cAltRaz == "0"
		lRet := .F.

	Case cAltRaz == "1"
		lRet := cNfGer == "2" .Or. cNfGer == "3"

	Case cAltRaz == "2"
		lRet := .T.

	Otherwise
		lRet := .F.
	EndCase

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204FPagto()
Função para o When do campo NXA_FPAGTO

@author Jorge Martins
@since 10/03/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J204FPagto()
Local lRet    := .F.
Local cAltFPg := SuperGetMV('MV_JALTFPG',, '1')
Local oModel  := FwModelActive()
Local cSituac := ""

	If oModel != Nil .And. oModel:cId == 'JURA204'
		cSituac := oModel:GetValue('NXAMASTER', 'NXA_SITUAC')
	Else
		cSituac := FwFldGet('NXA_SITUAC')
	EndIf

	If cAltFPg == "1" .And. cSituac == "1"
		lRet := .T.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204AlFPgt()
Rotina para alterar o usuário e data de alteração da fatura, além
de alterar a informação sobre a forma de pagamento do título gerado
no financeiro

@param  aSE1RECNO - Array com Recnos dos titulos transferidos pelo PFS
@param  cFPagto   - Forma de pagamento
@param  cFil      - Filial do Escritório de Faturamento

@return Nil

@author Jorge Martins
@since 13/03/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204AlFPgt(aSE1RECNO, cFPagto, cFil)
Local lRet          := .F.
Local aAreaSE1      := SE1->(GetArea())
Local aAreaNXA      := NXA->(GetArea())
Local aSE1          := {}
Local cBoleto       := ""
Local cFilSav       := cFilAnt
Local nI            := 0
Local nY            := 0
Local nRecnoSE1     := 0

If cFPagto == "1" // Depósito
	cBoleto := "2"
ElseIf cFPagto == "2" // Boleto
	cBoleto := "1"
EndIf

For nI := 1 To Len(aSE1RECNO)

	nRecnoSE1 := aSE1RECNO[nI]

	SE1->(DbGoTo(nRecnoSE1))

	If SE1->E1_VALOR == SE1->E1_SALDO

		aSE1 := {}

		aAdd( aSE1, {'E1_BOLETO ' , cBoleto          , NIL})
		If cBoleto == "1"
			aAdd( aSE1, {'E1_PORTADO ', M->NXA_CBANCO, NIL})
			aAdd( aSE1, {'E1_AGEDEP ' , M->NXA_CAGENC, NIL})
			aAdd( aSE1, {'E1_CONTA '  , M->NXA_CCONTA, NIL})
		EndIf

		cFilAnt := cFil

		Begin Transaction
			For nY := 1 To Len(aSE1)
				RecLock("SE1", .F.)
				SE1->(FieldPut(FieldPos(aSE1[nY][1]), aSE1[nY][2]))
				SE1->(MsUnLock())
			Next nY
		End Transaction

		cFilAnt := cFilSav
	EndIf

Next nI

JurFreeArr(aSE1) //Limpa memória

RestArea( aAreaSE1 )
RestArea( aAreaNXA )

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA204COMMIT
Classe interna implementando o FWModelEvent, para execução de função
durante o commit.

@author Cristina Cintra Santos
@since 21/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA204COMMIT FROM FWModelEvent
    Method New()
    Method BeforeTTS()
    Method InTTS()
End Class

Method New() Class JA204COMMIT
Return

Method BeforeTTS(oSubModel, cModelId) Class JA204COMMIT
	J204CpyFat(oSubModel:GetModel())
Return

Method InTTS(oSubModel, cModelId) Class JA204COMMIT
	J204FSinc(oSubModel:GetModel())
	J204UpdEml(oSubModel:GetModel())
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J204PFinan
Verifica todos os títulos relacionados a fatura e retorna se está 
Pendente, Paga ou Parcialmente Paga. 
Usado no inicializador de browse do NXA_STATUS. 

@Param  lInicBrw   Se a função for chamada pelo inicializador do Browse
@Param  cCpoIniBrw Campo da função chamada pelo inicializador do Browse

@author Abner Fogaça de Oliveira

@since 22/03/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function J204PFinan(lInicBrw, cCpoIniBrw)
Local aArea     := GetArea()
Local cRet      := ""
Local cQryRes   := ""
Local cQuery    := ""
Local cJurFat   := ""
Local cFilEsc   := ""
Local nVlrPago  := 0
Local nValor    := 0
Local nSaldo    := 0
Local aDadosTit := {}
Local dDtPagto  := SToD("  /  /    ")
Local lSemSaldo := .F.
Local lPendente := .F.

Default lInicBrw   := .T.
Default cCpoIniBrw := ""

	If NXA->NXA_SITUAC == "1" .And. NXA->NXA_TIPO == "FT"
		If !lInicBrw
			cQuery  := J204QryFin() // Query com os dados dos títulos vínculados a fatura
			cQryRes := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cQryRes, .T., .T. )

			If !(cQryRes)->( Eof() )
				If ((cQryRes)->E1_SALDO == (cQryRes)->E1_VALOR)
					cRet := "1" // Pendente
				ElseIf ((cQryRes)->E1_SALDO == 0)
					cRet     := "2" // Pago
					dDtPagto := StoD((cQryRes)->DTULTBAIXA)
					nVlrPago := (cQryRes)->VALOR_PAGO
				ElseIf ((cQryRes)->E1_SALDO != (cQryRes)->E1_VALOR)
					cRet     := "3" // Parcialmente Pago
					dDtPagto := StoD((cQryRes)->DTULTBAIXA)
					nVlrPago := (cQryRes)->VALOR_PAGO
				EndIf
			EndIf
	
			(cQryRes)->( DbCloseArea() )
			
			_cStatus := cRet
			_dDtPagt := dDtPagto
			_nVlrPag := nVlrPago
		Else
			
			cFilEsc := JurGetDados("NS7", 1, xFilial("NS7") + NXA->NXA_CESCR, "NS7_CFILIA")
			cJurFat := NXA->NXA_FILIAL + "-" + NXA->NXA_CESCR + "-" + NXA->NXA_COD + "-" + cFilEsc

			SE1->(DbSetOrder(25)) // E1_FILIAL + E1_JURFAT
			If SE1->(DbSeek(cFilEsc + cJurFat))
				If SE1->E1_PARCELA == Space(TamSx3("E1_PARCELA")[1]) .And. SE1->E1_TIPOLIQ == Space(TamSx3("E1_TIPOLIQ")[1]) // Títulos que não possuem parcelamento/liquidação
					lSemSaldo := SE1->E1_SALDO == 0
					lPendente := SE1->E1_SALDO == SE1->E1_VALOR
					Do Case
						Case cCpoIniBrw == "NXA_DTPAGT"
							cRet := IIf(lPendente, CToD("  /  /    "), SE1->E1_BAIXA)
						Case cCpoIniBrw == "NXA_VLRPAG"
							If lPendente
								cRet := 0
							Else
								cRet := IIf(lSemSaldo, SE1->E1_VALOR, SE1->E1_VALOR - SE1->E1_SALDO)
							EndIf
						OtherWise // NXA_STATUS
							If lPendente
								cRet := X3COMBO("NXA_STATUS", "1") // Pendente
							Else
								cRet := IIf(lSemSaldo, X3COMBO("NXA_STATUS", "2"), X3COMBO("NXA_STATUS", "3")) // 2 - Totalmente Pago # 3 - Parcialmente Pago
							EndIf
					End Case
				Else
					aDadosTit := JurSql(J204QryFin(cFilEsc), "*")

					If !Empty(aDadosTit)
						dDtPagto := StoD(aDadosTit[1][1])
						nVlrPago := aDadosTit[1][2]
						nValor   := aDadosTit[1][3]
						nSaldo   := aDadosTit[1][4]

						lSemSaldo := nSaldo == 0
						lPendente := nValor == nSaldo

						Do Case
							Case cCpoIniBrw == "NXA_DTPAGT"
								cRet := IIf(lPendente, CToD("  /  /    "), dDtPagto)
							Case cCpoIniBrw == "NXA_VLRPAG"
								If lPendente
									cRet := 0
								Else
									cRet := IIf(lSemSaldo, nValor, nVlrPago)
								EndIf
							OtherWise // NXA_STATUS
								If lPendente
									cRet := X3COMBO("NXA_STATUS", "1") // Pendente
								Else
									cRet := IIf(lSemSaldo, X3COMBO("NXA_STATUS", "2"), X3COMBO("NXA_STATUS", "3")) // 2 - Totalmente Pago # 3 - Parcialmente Pago
								EndIf
						End Case
					Else // Ajuste devido ao problema no financeiro que não limpa o campo E1_TIPOLIQ no cancelamento da liquidação - DFINCOM-12461
						Do Case
							Case cCpoIniBrw == "NXA_DTPAGT"
								cRet := CToD("  /  /    ")
							Case cCpoIniBrw == "NXA_VLRPAG"
								cRet := 0
							OtherWise // NXA_STATUS
								cRet := X3COMBO("NXA_STATUS", "1")
						End Case
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		If lInicBrw
			Do Case
				Case cCpoIniBrw == "NXA_DTPAGT"
					cRet     := CToD("  /  /    ")
					_dDtPagt := cRet
				Case cCpoIniBrw == "NXA_VLRPAG"
					cRet     := 0
					_nVlrPag := 0
				OtherWise // NXA_STATUS
					cRet     := IIf(NXA->NXA_TIPO <> "FT", "", X3COMBO("NXA_STATUS", "4")) // Cancelada / WO
					_cStatus := cRet
			End Case
		Else
			_dDtPagt := CToD("  /  /    ")
			_nVlrPag := 0
			_cStatus := IIf(NXA->NXA_TIPO <> "FT", "", "4") // Cancelada / WO
		EndIf
	EndIf

RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204QryFin
Gera query com os dados de valor, valor pago e saldo dos títulos 
vínculados a fatura, sejam títulos originados pela emissão da fatura, 
ou títulos gerados pela liquidação.

@param cFilEsc, Filial do Escritório da Fatura

@return cQuery, Query com os dados de títulos vinculados a fatura

@author Jorge Martins
@since  07/07/2021
/*/
//-------------------------------------------------------------------
Static Function J204QryFin(cFilEsc)
Local cEscrit   := NXA->NXA_CESCR
Local cFatura   := NXA->NXA_COD
Local cFilFat   := xFilial("NXA")
Local cQuery    := ""
Local lOHTInDic := FWAliasInDic("OHT")

Default cFilEsc := JurGetDados("NS7", 1, xFilial("NS7") + cEscrit, "NS7_CFILIA")

	cQuery +=       " SELECT MAX(SE1.E1_BAIXA) DTULTBAIXA, "
	cQuery +=              " SUM(SE1.E1_VALOR) - SUM(SE1.E1_SALDO) VALOR_PAGO, "
	cQuery +=              " SUM(SE1.E1_VALOR) E1_VALOR, "
	cQuery +=              " SUM(SE1.E1_SALDO) E1_SALDO "
	cQuery +=         " FROM " + RetSqlName("SE1") + " SE1 "
	If lOHTInDic
		cQuery +=    " INNER JOIN " + RetSqlName("OHT") + " OHT "
		cQuery +=       " ON OHT.OHT_FILIAL = '" + xFilial("OHT") + "' "
		cQuery +=      " AND OHT.OHT_FILFAT = '" + cFilFat + "' "
		cQuery +=      " AND OHT.OHT_FTESCR = '" + cEscrit + "' "
		cQuery +=      " AND OHT.OHT_CFATUR = '" + cFatura + "' "
		cQuery +=      " AND OHT.D_E_L_E_T_ = ' '
		cQuery +=    " WHERE SE1.E1_FILIAL = OHT.OHT_FILTIT "
		cQuery +=      " AND SE1.E1_PREFIXO = OHT.OHT_PREFIX "
		cQuery +=      " AND SE1.E1_NUM = OHT.OHT_TITNUM "
		cQuery +=      " AND SE1.E1_PARCELA = OHT.OHT_TITPAR "
		cQuery +=      " AND SE1.E1_TIPO = OHT.OHT_TITTPO "
	Else
		cQuery +=    " WHERE SE1.E1_FILIAL = '" + cFilEsc + "'"
		cQuery +=      " AND SE1.E1_JURFAT = '" + cFilFat + "-" + cEscrit + "-" + cFatura + "-" + cFilEsc + "'"
	EndIf
	cQuery +=          " AND SE1.E1_ORIGEM IN ('JURA203', 'FINA460') "
	cQuery +=          " AND SE1.E1_TIPOLIQ = '" + Space(TamSx3('E1_TIPOLIQ')[1]) + "' "
	cQuery +=          " AND SE1.D_E_L_E_T_ = ' ' "
	If lOHTInDic
		cQuery +=    " GROUP BY SE1.E1_JURFAT "
	EndIf

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} J204Activ
Rotina para validar a ativação do modelo de fatura e chama a função 
para carregar as variaveis estaticas do status dos titulos da fatura 
(J204PFinan).

@param  oModel   Model ativo
@param  lStatus  Indica se existe o campo NXA_STATUS

@return lRet     Indica se o modelo pode ser ativado

@author Luciano Pereira dos Santos
@since 22/03/18
/*/
//-------------------------------------------------------------------
Static Function J204Activ(oModel, lStatus)
	Local lRet      := Iif(FindFunction("JurVldUxP"), JurVldUxP(oModel), .T.)
	
	Default lStatus := .F.
	
	If lRet .And. lStatus
		J204PFinan(.F.)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204GeraRpt
Emissão de relatórios por SmartClient secundário.

@author Luciano Pereira dos Santos
@since 04/04/18
@version 1.0
/*/
//-------------------------------------------------------------------
Main Function J204GeraRpt(cParams)

Return J203GeraRpt(cParams)

//-------------------------------------------------------------------
/*/{Protheus.doc} J204GetSta
Retorna os valores das variaveis estaticas preenchidas no VldActivate do Modelo.

@author Anderson Carvalho / Bruno Ritter
@since 31/08/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function J204GetSta()
	Local xRet    := Nil
	Local cCampo  := AllTrim(ReadVar())
	
	Do Case
		Case cCampo == 'M->NXA_STATUS'
			xRet := _cStatus
		Case cCampo == 'M->NXA_DTPAGT'
			xRet := _dDtPagt
		Case cCampo == 'M->NXA_VLRPAG'
			xRet := _nVlrPag
	EndCase

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadNXD
Load dos dados da NXD para possibilitar a ordenação também por sigla
na grid de Participantes

@param  oGrid  Grid da NXD

@author Luciano Pereira dos Santos
@since 09/11/2018
@version 2.0
/*/
//-------------------------------------------------------------------
Static Function LoadNXD(oGrid)
Local aRet     := FormLoadGrid(oGrid)
Local aStruct  := oGrid:oFormModelStruct:GetFields()
Local nAnomes  := 0 
Local lSigla   := SuperGetMV('MV_JORDPAR',, '1') == '2' //Define a ordenação dos lançamentos pelo Código do Participante (RD0_COD) - 1 ou pela Sigla (RD0_SIGLA) - 2.
Local nSigla   := 0 
Local nCateg   := 0

nAnomes  := aScan( aStruct, { |e| e[MODEL_FIELD_IDFIELD] == 'NXD_ANOMES' } ) 
nSigla   := aScan( aStruct, { |e| e[MODEL_FIELD_IDFIELD] == Iif(lSigla, 'NXD_SIGLA', 'NXD_CPART') } )
nCateg   := aScan( aStruct, { |e| e[MODEL_FIELD_IDFIELD] == 'NXD_CCATEG' } )

If nAnomes > 0 .And. nSigla > 0 .And. nCateg > 0  
	aSort( aRet,,, { |aX,aY| aX[2][nAnomes] + aX[2][nSigla] + aX[2][nCateg] < aY[2][nAnomes] + aY[2][nSigla] + aY[2][nCateg] } )
ElseIf nSigla > 0 .And. nCateg > 0 //Proteção para o campo
	aSort( aRet,,, { |aX,aY| aX[2][nSigla] + aX[2][nCateg] < aY[2][nSigla] + aY[2][nCateg] } )
EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204ClMark
Limpa a marca dos registros na tela de envio de e-mail

@param  cMarca, Marca atual para localização dos registros marcados

@author  Jorge Martins
@since   23/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204ClMark(cMarca)
	Local aArea    := GetArea()
	Local cQuery   := ""
	Local aRegMark := {}
	Local nI       := 0

	NXA->( dbClearFilter() )

	cQuery := " SELECT NXA.NXA_FILIAL, NXA.NXA_CESCR, NXA.NXA_COD "
	cQuery +=   " FROM " + RetSqlName( 'NXA' ) + " NXA "
	cQuery +=  " WHERE NXA.NXA_FILIAL = '" + xFilial("NXA") + "' "
	cQuery +=    " AND NXA.NXA_OK     = '" + cMarca + "' "
	cQuery +=    " AND NXA.D_E_L_E_T_ = ' '"

	aRegMark := JurSQL(cQuery, {"NXA_FILIAL", "NXA_CESCR", "NXA_COD"})

	NXA->(dbSetOrder(1)) // NXA_FILIAL + NXA_CESCR + NXA_COD

	For nI := 1 To Len(aRegMark)
		If NXA->(DbSeek(aRegMark[nI][1] + aRegMark[nI][2] + aRegMark[nI][3]))
			RecLock("NXA", .F.)
			NXA->NXA_OK := ""
			NXA->(MsUnlock())
			NXA->(DbCommit())
		EndIf
	Next

	JurFreeArr(@aRegMark)

	RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J204InfBco()
Função para o When das informações bancárias (Banco, Agência e Conta) 
na fatura.

@return lRet  Indica se o campo pode ser liberado para edição (.T.)

@author Cristina Cintra
@since 06/01/2020
/*/
//-------------------------------------------------------------------
Function J204InfBco()
Local lRet       := .T.
Local oModel     := FwModelActive()
Local cSituac    := ""

If oModel != Nil .And. oModel:cId == 'JURA204'
	cSituac := oModel:GetValue('NXAMASTER', 'NXA_SITUAC')
Else
	cSituac := FwFldGet('NXA_SITUAC')
EndIf

// Valida a situação da fatura - não pode estar cancelada ou em WO
If cSituac == "2"
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204VldBco()
Função para o Valid das informações bancárias (Banco, Agência e Conta) 
na fatura. Verifica se os títulos não estão em borderô e chama a JurVldSA6.

@param cTipo  "1" para validação do Banco, "2" para Agência e "3" Conta

@return lRet  Indica se a validação foi OK (.T.)

@author Cristina Cintra
@since 06/01/2020
/*/
//-------------------------------------------------------------------
Function J204VldBco(cTipo)
Local lRet       := .T.
Local aArea      := GetArea()
Local aAreaSE1   := SE1->(GetArea())
Local aAreaNXA   := NXA->(GetArea())
Local oModel     := FwModelActive()
Local cQuery     := ""
Local cEscrit    := ""
Local cFatura    := ""
Local cFil       := ""

If oModel != Nil .And. oModel:cId == 'JURA204'
	cEscrit  := oModel:GetValue('NXAMASTER', 'NXA_CESCR')
	cFatura  := oModel:GetValue('NXAMASTER', 'NXA_COD')
	cSituac  := oModel:GetValue('NXAMASTER', 'NXA_SITUAC')
Else
	cEscrit  := FwFldGet('NXA_CESCR')
	cFatura  := FwFldGet('NXA_COD')
	cSituac  := FwFldGet('NXA_SITUAC')
EndIf

lRet := JurVldSA6(cTipo)

// Retorna os títulos da fatura e verifica se algum está em borderô
If lRet
	cFil := JurGetDados("NS7", 1, xFilial("NS7") + cEscrit, "NS7_CFILIA")
	
	cQuery := "SELECT COUNT(SE1.R_E_C_N_O_) QTD "
	cQuery +=  " FROM " + RetSqlName("SE1") + " SE1 "
	cQuery += " WHERE SE1.E1_FILIAL = '" + FWxFilial("SE1", cFil) + "' "
	cQuery +=   " AND SE1.E1_JURFAT = '" + xFilial("NXA") + AllTrim( '-' + cEscrit + '-' + cFatura + '-' + cFil) + "' "
	cQuery +=   " AND SE1.E1_NUMBOR <> ' ' "
	cQuery +=   " AND SE1.D_E_L_E_T_ = ' ' "
	
	If JurSQL(cQuery, {"QTD"})[1][1] != 0
		lRet := JurMsgErro(STR0228,, STR0229) // "Um ou mais títulos desta fatura estão em borderô, desta forma, não é possível a alteração das informações bancárias." # "Verifique o(s) título(s) desta fatura."
	EndIf
	
EndIf

RestArea(aAreaSE1)
RestArea(aAreaNXA)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204ExistB
Indica se a fatura possui boleto(s) emitido(s).

@param cEscrit, Escritório da Fatura
@param cFatura, Código da Fatura

@return lBoleto, Indica se a fatura possui boleto

@author  Jorge Martins
@since   06/01/2020
/*/
//-------------------------------------------------------------------
Static Function J204ExistB(cEscrit, cFatura)
	Local aArea     := GetArea()
	Local aAreaNXM  := NXM->(GetArea())
	Local cChave    := ""
	Local lBoleto   := .F.

	NXM->( DbSetOrder(1) ) // NXM_FILIAL+NXM_CESCR+NXM_CFATUR+NXM_ORDEM

	cChave := xFilial("NXM") + AvKey(cEscrit, "NXM_CESCR") + AvKey(cFatura, "NXM_CFATUR")

	If NXM->(DbSeek(cChave))
		While !NXM->(Eof()) .And. (NXM->NXM_FILIAL + NXM->NXM_CESCR + NXM->NXM_CFATUR == cChave)
			If J204NomCmp( J204STRFile("B", "2",cEscrit, cFatura), Upper(NXM->NXM_NOMORI))
				lBoleto := .T.
			EndIf

			NXM->( DbSkip() )
		EndDo
	EndIf

	RestArea(aAreaNXM)
	RestArea(aArea)

Return lBoleto

//-------------------------------------------------------------------
/*/{Protheus.doc} JA204Vig
Avalia se o contrato utiliza vigência

@param cContrato, Código do Contrato
@param cPreFat  , Código da Pré-Fatura

@return lExistVig, Se verdadeiro existe vigência

@author Jonatas Martins
@since  05/03/2020
/*/
//-------------------------------------------------------------------
Static Function JA204Vig(cPreFat, cContrato)
	Local lExistVig := .F.

	If NT0->(ColumnPos("NT0_DTVIGI")) > 0
		If Empty(cPreFat) // Busca vigência no contrato quando não existe pré-fatura
			lExistVig := !Empty(JurGetDados("NT0", 1, xFilial("NT0") + cContrato, "NT0_DTVIGI"))
		Else
			lExistVig := !Empty(JurGetDados("NX8", 1, xFilial("NX8") + cPreFat + cContrato, "NX8_DTVIGI"))
		EndIf
	EndIf

Return (lExistVig)

//-------------------------------------------------------------------
/*/{Protheus.doc} J204EmlLDoc
Faz o tratamento do anexo do email para uma lista de Faturas

@param aFaturas,  Array de Faturas
@return cRet Lista de Anexos
@author fabiana.silva
@since 14/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204EmlLDoc(aFaturas)
Local nC := 0
Local cRet := ""

For nC := 1 to Len(aFaturas)
	 cRet += J204EmlDoc(aFaturas[nC, 01], aFaturas[nC, 02], nC == 1 )+";"
Next nC 

If (nC := Len(cRet)) > 0
	cRet := SubStr( cRet, 1, nC - 1 )
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204NXAAFl
Filtos das Faturas

@param cConfig , Configuração de e-mail
@param lCIdioma, Indica se existem os campos de idioma

@return aFiltros, Retorna os filtros

@author fabiana.silva
@since  13/04/2020
/*/
//-------------------------------------------------------------------
Static Function J204NXAAFl(cConfig, lCIdioma)
Local aFiltros := {}
Local cFilIdio := ""
Local cFPagto  := J204NRUGET('NRU_FRMPGO', cConfig)

Default lCIdioma := NXA->(ColumnPos("NXA_CIDIO2")) > 0 .AND. NRU->(ColumnPos("NRU_CIDIO")) > 0 

	If cFPagto $ "1|2"
		aAdd(aFiltros , {"NXA_FPAGTO = ", cFPagto})
	EndIf

	If lCIdioma
		cFilIdio := J204NRUGET('NRU_CIDIO', cConfig)
		If !Empty(cFilIdio)
			aAdd(aFiltros , {"NXA_CIDIO2 = ", cFilIdio})
		EndIf
	EndIf

Return aFiltros

//-------------------------------------------------------------------
/*/{Protheus.doc} J204CanOHT
Função chamada após o cancelamento de uma fatura para exclusão do 
vínculo entre título a receber e fatura (OHT)

@author Jorge Martins / Abner Oliveira / Jonatas Martins
@since  06/07/2020
/*/
//-------------------------------------------------------------------
Static Function J204CanOHT(cFilNXA, cEscrit, cFatura)
Local cChaveOHT := ""

If Chkfile("OHT")
	cChaveOHT := xFilial("OHT") + cFilNXA + cEscrit + cFatura

	OHT->(DbSetOrder(1)) // OHT_FILIAL + OHT_FILFAT + OHT_FTESCR + OHT_CFATUR
	If OHT->(DbSeek(cChaveOHT))
		While !OHT->(EOF()) .And. OHT->(OHT_FILIAL + OHT_FILFAT + OHT_FTESCR + OHT_CFATUR) == cChaveOHT
			RecLock("OHT", .F.)
			OHT->(DbDelete())
			OHT->(MsUnLock())
			OHT->(DbSkip())
		EndDo
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J204GrvLog
Gera o Log de envio de e-mail da fatura

@param cEscrit , Escritório da Fatura
@param cFatura , Código da Fatura
@param cAssunto, Assunto do e-mail
@param cPara   , Destinatário - Para - do e-mail
@param cMailCC , Destinatário - CC (Cópia) - do e-mail
@param cMailCCO, Destinatário - CCO (Cópia Oculta) - do e-mail
@param cCorpo  , Corpo do e-mail
@param cAnexos , Lista de Anexos do e-mail

@return aLog   , Array com dados para geração do Log
                 aLog[1] Participante de envio do e-mail
                 aLog[2] Data / Hora do envio do e-mail
                 aLog[3] Log do envio do e-mail

@author Jorge Martins
@since  13/10/2020
/*/
//-------------------------------------------------------------------
Function J204GrvLog(cEscrit, cFatura, cAssunto, cPara, cMailCC, cMailCCO, cCorpo, cAnexos)
	Local aLog      := {}
	Local aPart     := {}
	Local cLog      := ""
	Local cLogFat   := ""
	Local cPart     := ""
	Local cDataHora := ""
	Local lCposLog  := NXA->(ColumnPos("NXA_LOGENV")) > 0

	If lCposLog
		aPart     := JurGetDados("RD0", 1, xFilial("RD0") + JurUsuario(__cUserId), {"RD0_CODIGO", "RD0_SIGLA", "RD0_NOME"})
		If Len(aPart) == 3
			cPart := AllTrim(aPart[1]) + " - " + AllTrim(aPart[2]) + " - " + AllTrim(aPart[3])
		EndIf
		cDataHora := cValToChar(Date()) + " - " + Time()
		cAnexos   := StrTran(cAnexos, JurFixPath('tmp_' + __cUserID, 1, 1), "") // Retira o diretório do nome do(s) arquivo(s)

		cLogFat   := J204LogFat(cEscrit, cFatura) // Log Atual da Fatura

		// Geração do Log
		cLog := STR0230 + cPart + CRLF                                      // "Participante de envio: "
		cLog += STR0231 + cDataHora + CRLF                                  // "Data e hora de envio: "
		cLog += STR0232 + cAssunto + CRLF                                   // "Assunto: "
		cLog += STR0233 + CRLF                                              // "Destinatário(s): "
		cLog += IIf(Empty(cPara)   , "", " - " + STR0234 + cPara + CRLF)    //  - "Para: "
		cLog += IIf(Empty(cMailCC) , "", " - " + STR0235 + cMailCC + CRLF)  //  - "CC: "
		cLog += IIf(Empty(cMailCCO), "", " - " + STR0236 + cMailCCO + CRLF) //  - "CCO: "
		cLog += STR0238 + cAnexos + CRLF                                    // "Anexos: "
		cLog += STR0237 + CRLF + cCorpo + CRLF                              // "Corpo do e-mail: "
		
		cLog += IIf(Empty(cLogFat), "", Replicate( "-", 100 ) + CRLF + CRLF + cLogFat) // Inclui o Log atual da fatura

		aLog := {cPart, cDataHora, cLog}
	EndIf

Return aLog

//-------------------------------------------------------------------
/*/{Protheus.doc} J204LogFat
Retorna o Log de envio de e-mail gravado atualmente na Fatura (NXA_LOGENV)

@param cEscrit , Escritório da Fatura
@param cFatura , Código da Fatura

@return cLogFat, Log de envio de e-mail da Fatura

@author Jorge Martins
@since  13/10/2020
/*/
//-------------------------------------------------------------------
Static Function J204LogFat(cEscrit, cFatura)
	Local aArea     := GetArea()
	Local aAreaNXA  := NXA->(GetArea())
	Local cLogFat   := ""

	NXA->(DbSetOrder(1))
	If NXA->( DbSeek(xFilial("NXA") + cEscrit + cFatura ) )
		cLogFat := NXA->NXA_LOGENV
	EndIf

	RestArea(aAreaNXA)
	RestArea(aArea)

Return cLogFat

//-------------------------------------------------------------------
/*/{Protheus.doc} J204FlExDi
Função que verifica se o arquivo existe no diretório se não existir adiciona no diretório

@param cPastaDest , Escritório da Fatura
@param aDoc       , Lista de Documentos
@param aDirPDF    , Diretório dos Arquivos

@author fabiana.silva
@since  19/10/2020
/*/
//-------------------------------------------------------------------
Function J204FlExDi(cPastaDest, aDoc, aDirPDF)
Local nC       := 0
Local cNomFile := ""

	For nC := 1 to Len(aDoc)
		cNomFile := Upper(aDoc[nC])
		If At(".", cNomFile) > 0 // Arquivo contém extensão
			If aScan(aDirPDF, {|p| p[1] == cNomFile }) = 0 .And. File(cPastaDest + cNomFile)
				aAdd(aDirPdf, {cNomFile, ,,,"A"})
			EndIf
		EndIf
	Next nC

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J204NomCmp
Função que compara os textos

@param cFileDef , String contendo
@param cNomFile , String nome do arquivo
@return lRet , Comparação com sucessp
@author fabiana.silva
@since  19/10/2020
/*/
//-------------------------------------------------------------------
Function J204NomCmp(cFileDef, cNomFile)
Local lRet := .F.
Local cTmp := ""

If Len(cFileDef) > Len(cNomFile)
	cTmp := Upper(cFileDef)
	cFileDef := cNomFile
	cNomFile := cTmp
EndIf

lRet := cFileDef $ cNomFile

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204UpdEml
Função para atualizar o campo de agrupamento de e-mail (NXA_EMLAGR)
na alteração da fatura

@param oModel, Modelo de dados da Fatura

@author Jonatas Martins
@since  02/06/2022
/*/
//-------------------------------------------------------------------
Static Function J204UpdEml(oModel)
Local aEncMail := {}
Local lCpoAgr  := NXA->(ColumnPos("NXA_EMLAGR")) > 0 // @12.1.2310

	If lCpoAgr .And. oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. FindFunction("J203HAgrEm")
		// Se houve alteração nos encaminhamentos ou alteração do e-mail ou e-mail cópia da fatura
		// Atualiza o agrupamento dos e-mails no campo novo
		If !Empty(oModel:GetModel("NVNDETAIL"):GetLinesChanged()) .Or. oModel:GetModel("NXAMASTER"):IsFieldUpdated("NXA_EMAIL");
		   .Or. (oModel:GetModel("NXAMASTER"):HasField("NXA_CEMAIL") .And. oModel:GetModel("NXAMASTER"):IsFieldUpdated("NXA_CEMAIL"))
			aEncMail := J204GetEnc(NXA->NXA_CJCONT, NXA->NXA_CCONTR, NXA->NXA_CLIPG, NXA->NXA_LOJPG, NXA->NXA_CFTADC, NXA->NXA_CPREFT, NXA->NXA_CESCR, NXA->NXA_COD)
			J203HAgrEm(NXA->NXA_CESCR, NXA->NXA_COD, aEncMail, .F.)
			JurFreeArr(aEncMail)
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J204EmlAgr
Monta campo de e-mail agrupado para exibir no browse da tela de 
envio de e-mail da fatura

@return aColumns, Estrutura do campo de e-mail agrupado

@author Jonatas Martins
@since  02/06/2022
/*/
//-------------------------------------------------------------------
Static Function J204EmlAgr()
Local aColumns := {}

	aAdd(aColumns, {;
		STR0244,;                               // [n][01] Título da coluna - // "E-Mail Agrup"
		{|| SubStr(NXA->NXA_EMLAGR, 1, 250) },; // [n][02] Code-Block de carga dos dados
		"C",;                                   // [n][03] Tipo de dados
		"",;                                    // [n][04] Máscara
		1,;                                     // [n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
		10,;                                    // [n][06] Tamanho
		0,;                                     // [n][07] Decimal
		200,;                                   // [n][08] Parâmetro reservado
		Nil,;                                   // [n][09] Parâmetro reservado
		.F.,;                                   // [n][10] Indica se exibe imagem
		Nil,;                                   // [n][11] Code-Block de execução do duplo clique
		Nil,;                                   // [n][12] Parâmetro reservado
		{|| AlwaysTrue()},;                     // [n][13] Code-Block de execução do clique no header
		.F.,;                                   // [n][14] Indica se a coluna está deletada
		.T.,;                                   // [n][15] Indica se a coluna será exibida nos detalhes do Browse
		2})                                     // [n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)

Return (aColumns)

//-------------------------------------------------------------------
/*/{Protheus.doc} J204VlTpAq( cTipArq )
Responsável pela validação no preenchimento do campo NXM_CTPARQ

@param  cTipArq - Indica o tipo de arquivo
					1=Carta
					2=Relatorio
					3=Recibo
					4=Boleto
					5=Unificado
					6=Adicional
					7=Conferencia
@return lRet    - Indica se o valor é válido
/*/
//-------------------------------------------------------------------
Function J204VlTpAq( cTipArq )

Local lRet := .F.

	If Empty( cTipArq ) .AND. VALTYPE(M->NXM_CTPARQ) <> "U"
		cTipArq := M->NXM_CTPARQ
	EndIf

	lRet := cTipArq $ "1234567"

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204CBox()
Responsável pelas opções de combo box do campo NXM_CTPARQ

@return lRet    - Indica a lista de opções
/*/
//-------------------------------------------------------------------
Function J204CBox()

Local cOpcoes := ""

	cOpcoes += "1=" + STR0254 + ";"  // "Carta"
	cOpcoes += "2=" + STR0255 + ";"  // "Relatorio"
	cOpcoes += "3=" + STR0256 + ";"  // "Recibo"
	cOpcoes += "4=" + STR0257 + ";"  // "Boleto"
	cOpcoes += "5=" + STR0258 + ";"  // "Unificado"
	cOpcoes += "6=" + STR0259 + ";"  // "Adicional"
	cOpcoes += "7=" + STR0260        // "Conferencia"

Return cOpcoes
