#INCLUDE 'JURA096.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWMBROWSE.CH'

Static aCpoBotoes := NIL
Static aCpoInBot  := NIL
Static cUser      := ''
Static lCtrlMsg   := .T.
Static lCtlCndFat := .T.
Static aArmzNT0   := {}

Static _J70GrpCli
Static _J70CodCli
Static _J70LojCli
Static _aCnt096   := {}
Static _aPreFtVld := {}
Static _cNumClien := SuperGetMV("MV_JCASO1",, "1") // Seq¸Íncia da numeraÁ„o do caso (1 - Por cliente / 2 - Independente)
Static _aSitCasos := {}

// Vetor aCpoBotoes
Static CTPHON := 0
Static BOTAO  := 0
Static CONFIG := 0

// Posicao 3 tem os campos e atributos
Static CAMPO  := 0
Static INICIA := 0
Static VISIV  := 0
Static OBRIGA := 0

// Numero dos botoes da Tela
Static BOTAOCDF := 0
Static BOTAOFXA := 0

//-------------------------------------------------------------------
/*/{Protheus.doc} J096SetSta()
Set de valores iniciais das variavÈis Static
Essa funÁ„o foi desenvolvida para ser chamado na criaÁ„o do modelo,
assim os valores definidos aqui ficam no modelo quando È chamado por
um serviÁo (Rest, automaÁ„o e etc...).
@author bruno.ritter
@since 02/06/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096SetSta()
aCpoBotoes := NIL
aCpoInBot  := NIL
cUser      := '1' //1 = AlteraÁıes do usu·rio, 2 = AlteraÁıes so sistema (para permitir manipulaÁ„o de parcelas autom·ticas)
lCtrlMsg   := .T. //Controlar as mensagens STR0132 exibida na CondiÁ„o de Faturamento.
lCtlCndFat := .T. //Para controlar o bot„o de "Parcelar" e o "Confirmar"
aArmzNT0   := {}

_aCnt096   := {} //salva os valores especificados na funÁ„o J096CPYCnt()

// Vetor aCpoBotoes
CTPHON := 1
BOTAO  := 2
CONFIG := 3
// Posicao 3 tem os campo e atributos
CAMPO  := 1
INICIA := 2
VISIV  := 3
OBRIGA := 4
// Numero dos botoes da Tela
BOTAOCDF := 1
BOTAOFXA := 2

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA096
Contratos do Faturamento

@author David GonÁalves Fernandes
@since 26/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA096(cCliente, cLoja, cCaso)
Local cLojaAuto  := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-N„o)
Private oBrowse  := Nil

Default cCliente := ''
Default cLoja    := ''
Default cCaso    := ''

INCLUI := .F.
ALTERA := .F.

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NT0" )
Iif(cLojaAuto == "1", JurBrwRev(oBrowse, "NT0", {"NT0_CLOJA"}), )
oBrowse:SetLocate()

If !Empty( cCliente ) .And. !Empty( cLoja ) .And. !Empty( cCaso )
	oBrowse:SetFilterDefault( "NT0_CCLIEN == '" + cCliente + "' .AND. NT0_CLOJA == '" + cLoja + "'" )
	oBrowse:AddFilter("Contrato", "NUT_CCLIEN = '" + cCliente + "' AND NUT_CLOJA = '" + cLoja + "' AND NUT_CCASO = '" + cCaso + "' AND D_E_L_E_T_ = ' '", .T., .T., "NUT")
EndIf

oBrowse:SetMenuDef( 'JURA096' )
JurSetLeg( oBrowse, "NT0" )
JurSetBSize( oBrowse )
J096Filter(oBrowse, cLojaAuto) // Adiciona filtros padrıes no browse

oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} J096Filter
Adiciona filtros padrıes no browse

@param  oBrowse, objeto, browse da rotina

@author Reginaldo Borges / Cristina Cintra
@since  08/08/2022
/*/
//-------------------------------------------------------------------
Static Function J096Filter(oBrowse, cLojaAuto)
Local aFilNT01 := {}
Local aFilNT02 := {}
Local aFilNT03 := {}

	SAddFilPar("NT0_CTPHON", "==", "%NT0_CTPHON0%", @aFilNT01)
	oBrowse:AddFilter(STR0259, 'NT0_CTPHON == "%NT0_CTPHON0%"', .F., .F., , .T., aFilNT01, STR0259) // "Tipo de Honor·rios"

	SAddFilPar("NT0_CPART1", "==", "%NT0_CPART10%", @aFilNT02)
	oBrowse:AddFilter(STR0260, 'NT0_CPART1 == "%NT0_CPART10%"', .F., .F., , .T., aFilNT02, STR0260) // "SÛcio Respons·vel"

	If cLojaAuto == "2"
		SAddFilPar("NT0_CCLIEN", "==", "%NT0_CCLIEN0%", @aFilNT03)
		SAddFilPar("NT0_CLOJA", "==", "%NT0_CLOJA0%", @aFilNT03)
		oBrowse:AddFilter(STR0261, 'NT0_CCLIEN == "%NT0_CCLIEN0%" .AND. NT0_CLOJA == "%NT0_CLOJA0%"', .F., .F., , .T., aFilNT03, STR0261) // "Cliente"
	Else
		SAddFilPar("NT0_CCLIEN", "==", "%NT0_CCLIEN0%", @aFilNT03)
		oBrowse:AddFilter(STR0261, 'NT0_CCLIEN == "%NT0_CCLIEN0%"', .F., .F., , .T., aFilNT03, STR0261) // "Cliente"
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de TransaÁ„o a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - AlteraÁ„o sem inclus„o de registros
7 - CÛpia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author David GonÁalves Fernandes
@since 26/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
Local aPesq   := {}

aAdd( aRotina, { STR0001, aPesq                   , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aPesq,   { STR0001, 'PesqBrw'               , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aPesq,   { STR0160, 'JFiltraCaso( oBrowse )', 0, 3, 0, .T. } ) //"Filtro por Caso"
If JA162AcRst('10')
	aAdd( aRotina, { STR0002, 'VIEWDEF.JURA096', 0, 2, 0, NIL } ) //"Visualizar"
EndIf
If JA162AcRst('10', 3)
	aAdd( aRotina, { STR0003, 'VIEWDEF.JURA096', 0, 3, 0, NIL } ) //"Incluir"
EndIf
If JA162AcRst('10', 4)
	aAdd( aRotina, { STR0004, 'VIEWDEF.JURA096', 0, 4, 0, NIL } ) //"Alterar"
EndIf
If JA162AcRst('10', 5)
	aAdd( aRotina, { STR0005, 'VIEWDEF.JURA096', 0, 5, 0, NIL } ) //"Excluir"
EndIf
If !IsInCallStack( 'JURA162' )
	aAdd( aRotina, { STR0006, 'VIEWDEF.JURA096', 0, 8, 0, NIL } ) //"Imprimir"
	aAdd( aRotina, { STR0088, 'JA096REVAL(NT0->NT0_COD)', 0, 8, 0, NIL } ) //"Revalorizar TSs"
	aAdd( aRotina, { STR0077, 'JA096REPLI()', 0, 3, 0, NIL } ) //Replicar
EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
View de dados de Contratos do Faturamento

@author David GonÁalves Fernandes
@since 26/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView      := Nil
	Local oModel     := FWLoadModel( 'JURA096' )
	Local oStruct    := FWFormStruct( 2, 'NT0', { |cCampo| cAux := cCampo, aScan( aCpoInBot, { |x| Alltrim(cAux) == Alltrim(x[CAMPO]) } ) == 0 } )
	Local oStructNTK := FWFormStruct( 2, 'NTK' )
	Local oStructNTJ := FWFormStruct( 2, 'NTJ' )
	Local oStructNUT := FWFormStruct( 2, 'NUT' )
	Local oStructNVN := FWFormStruct( 2, 'NVN' )
	Local oStructNW3 := FWFormStruct( 2, 'NW3' )
	Local oStructNT5 := FWFormStruct( 2, 'NT5' )
	Local oStructNXP := FWFormStruct( 2, 'NXP' )
	Local cLojaAuto  := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-N„o)
	Local cParam     := AllTrim( SuperGetMv('MV_JDOCUME',, '1'))
	Local lIntegraLD := SuperGetMV("MV_JFSINC", .F., '2') == '1' // Indica se utiliza a integraÁ„o com o Legal Desk

oStruct:RemoveField( 'NT0_CPART1' )
oStruct:RemoveField( 'NT0_QTPARC' )
oStruct:RemoveField( 'NT0_DTENC' )
oStruct:RemoveField( 'NT0_TPCORR' )
oStruct:RemoveField( 'NT0_CINDIC' )
oStruct:RemoveField( 'NT0_DINDIC' )
oStruct:RemoveField( 'NT0_PARCE' )
oStruct:RemoveField( 'NT0_DISPON' )
oStruct:RemoveField( 'NT0_DESPAR' )
oStruct:RemoveField( 'NT0_DECPAR' )
oStruct:RemoveField( 'NT0_CFXCVL' )
oStruct:RemoveField( 'NT0_CTBCVL' )
oStruct:RemoveField( 'NT0_CFACVL' )
oStruct:RemoveField( 'NT0_CEXCVL' )
oStruct:RemoveField( 'NT0_CTIPOF' )
oStruct:RemoveField( 'NT0_DTIPOF' )

If !lIntegraLD .And. ( NT0->(ColumnPos( "NT0_CASMAE" )) > 0 .And. NT0->(ColumnPos( "NT0_CCLICM" )) > 0 )
	oStruct:RemoveField( 'NT0_CASMAE' )
	oStruct:RemoveField( 'NT0_CCLICM' )
	oStruct:RemoveField( 'NT0_CLOJCM' )
	oStruct:RemoveField( 'NT0_CCASCM' )
EndIf

If !lIntegraLD .And. NT0->(ColumnPos( "NT0_FIXREV" )) > 0
	oStruct:RemoveField( 'NT0_FIXREV' )
EndIf

If (cLojaAuto == "1")
	oStruct:RemoveField( "NT0_CLOJA" )
	oStructNUT:RemoveField( "NUT_CLOJA" )
	If NT0->(ColumnPos( "NT0_CLOJCM" )) > 0
		oStruct:RemoveField( 'NT0_CLOJCM' )
	EndIf
EndIf

oStructNUT:RemoveField( 'NUT_CCONTR' )
oStructNUT:RemoveField( 'NUT_DCONTR' )
oStructNUT:RemoveField( 'NUT_CPART1' )

oStructNTK:RemoveField( 'NTK_CCONTR' )
oStructNTK:RemoveField( 'NTK_DCONTR' )

oStructNTJ:RemoveField( 'NTJ_CCONTR' )
oStructNTJ:RemoveField( 'NTJ_DCONTR' )

oStructNVN:RemoveField( 'NVN_CCONTR' )
oStructNVN:RemoveField( 'NVN_CFATAD' )

oStructNT5:RemoveField( "NT5_COD"    )
oStructNT5:RemoveField( "NT5_CCONTR" )

oStructNXP:RemoveField( "NXP_COD"    )
oStructNXP:RemoveField( "NXP_CJCONT" )
oStructNXP:RemoveField( "NXP_CCONTR" )

oStructNVN:RemoveField( "NVN_CJCONT" )
oStructNVN:RemoveField( "NVN_CCONTR" )
oStructNVN:RemoveField( "NVN_CLIPG"  )
oStructNVN:RemoveField( "NVN_LOJPG"  )
oStructNVN:RemoveField( "NVN_CPREFT"  )
If NVN->(ColumnPos("NVN_CFIXO")) > 0 //ProteÁ„o
	oStructNVN:RemoveField( 'NVN_CFIXO' )
EndIf
If NVN->(ColumnPos("NVN_CFILA")) > 0 //ProteÁ„o
	oStructNVN:RemoveField( 'NVN_CFILA' )
	oStructNVN:RemoveField( 'NVN_CESCR' )
	oStructNVN:RemoveField( 'NVN_CFATUR' )
EndIf

oView := FWFormView():New()
oView:SetModel( oModel )

oView:AddField( 'JURA096_VIEW'   , oStruct   , 'NT0MASTER' )
oView:AddGrid(  'JURA096_GRIDNUT', oStructNUT, 'NUTDETAIL' )
oView:AddGrid(  'JURA096_GRIDNTK', oStructNTK, 'NTKDETAIL' )
oView:AddGrid(  'JURA096_GRIDNTJ', oStructNTJ, 'NTJDETAIL' )
oView:AddGrid(  'JURA096_GRIDNVN', oStructNVN, 'NVNDETAIL' )
oView:AddGrid(  'JURA096_GRIDNW3', oStructNW3, 'NW3DETAIL' )
oView:AddGrid(  'JURA096_GRIDNT5', oStructNT5, 'NT5DETAIL' )
oView:AddGrid(  'JURA096_GRIDNXP', oStructNXP, 'NXPDETAIL' )

oView:CreateFolder('FOLDER_01')
oView:AddSheet('FOLDER_01', 'ABA_01', STR0007 ) //"Contratos do Faturamento"
oView:AddSheet('FOLDER_01', 'ABA_02', STR0008 ) //"Despesas n„o cobr·veis"
oView:AddSheet('FOLDER_01', 'ABA_03', STR0009 ) //"Atividades n„o cobr·veis"
oView:AddSheet('FOLDER_01', 'ABA_05', STR0081 ) //"Contratos Vinculados"
oView:AddSheet('FOLDER_01', 'ABA_06', STR0087 ) //"TÌtulo do Contrato por Idioma"
oView:AddSheet('FOLDER_01', 'ABA_07', STR0118 ) //"Pagadores do Contrato"

oView:CreateHorizontalBox('BOX_A01_F01',  50,,, 'FOLDER_01', 'ABA_01')
oView:CreateHorizontalBox('BOX_A01_F02',  50,,, 'FOLDER_01', 'ABA_01')
oView:CreateHorizontalBox('BOX_A02_F01', 100,,, 'FOLDER_01', 'ABA_02')
oView:CreateHorizontalBox('BOX_A03_F01', 100,,, 'FOLDER_01', 'ABA_03')
oView:CreateHorizontalBox('BOX_A05_F01', 100,,, 'FOLDER_01', 'ABA_05')
oView:CreateHorizontalBox('BOX_A06_F01', 100,,, 'FOLDER_01', 'ABA_06')
oView:CreateHorizontalBox('BOX_A07_F01',  50,,, 'FOLDER_01', 'ABA_07')
oView:CreateHorizontalBox('BOX_A07_F02',  50,,, 'FOLDER_01', 'ABA_07')

oView:CreateFolder('FOLDER_02','BOX_A01_F02')
oView:AddSheet('FOLDER_02','ABA_01_01', STR0012 )  //Contrato X Casos
oView:CreateHorizontalBox('BOX_A01_F02_01',100,,,'FOLDER_02','ABA_01_01')
oView:CreateHorizontalBox('BOX_A01_F02_02',100,,,'FOLDER_02','ABA_01_02')

oView:CreateFolder('FOLDER_03','BOX_A07_F02')
oView:AddSheet('FOLDER_03','ABA_07_01', STR0080 )  //"Encaminhamento de fatura"
oView:CreateHorizontalBox('BOX_A07_F02_01',100,,,'FOLDER_03','ABA_07_01')
oView:CreateHorizontalBox('BOX_A07_F02_02',100,,,'FOLDER_03','ABA_07_02')

oView:SetOwnerView( 'JURA096_VIEW'   , 'BOX_A01_F01' )
oView:SetOwnerView( 'JURA096_GRIDNUT', 'BOX_A01_F02_01' )
oView:SetOwnerView( 'JURA096_GRIDNTK', 'BOX_A02_F01' )
oView:SetOwnerView( 'JURA096_GRIDNTJ', 'BOX_A03_F01' )
oView:SetOwnerView( 'JURA096_GRIDNW3', 'BOX_A05_F01' )
oView:SetOwnerView( 'JURA096_GRIDNT5', 'BOX_A06_F01' )
oView:SetOwnerView( 'JURA096_GRIDNXP', 'BOX_A07_F01' )
oView:SetOwnerView( 'JURA096_GRIDNVN', 'BOX_A07_F02_01' )

If IsInCallStack("JURA070")
	oView:SetNoInsertLine( 'JURA096_GRIDNUT' )
	oView:SetNoUpdateLine( 'JURA096_GRIDNUT' )
	oView:SetNoDeleteLine( 'JURA096_GRIDNUT' )
EndIf

oView:SetNoInsertLine( 'JURA096_GRIDNW3' )
oView:SetNoUpdateLine( 'JURA096_GRIDNW3' )
oView:SetNoDeleteLine( 'JURA096_GRIDNW3' )

oView:AddUserButton( STR0013, 'MENURUN', { | oView | JURA96CDF( oView ) } ) // "Cond.Fat.Fixo"
oView:AddUserButton( STR0014, 'LJPRECO', { | oView | JURA96FXA( oView ) } ) // "Fx.Val."

If !(cParam == '1' .AND. IsPlugin())
	oView:AddUserButton( STR0035, "CLIPS", { | oView | J096RetRecno("NT0_COD"), JURANEXDOC("NT0", "NT0MASTER", "", "NT0_COD", , , , , , , , , , .T.) } )
EndIf

If FwAliasInDic('OI4')
	oView:AddUserButton(STR0265, 'MENURUN', { | oV | JURA302( oV:GetModel('NT0MASTER'):GetValue('NT0_FILIAL'),oV:GetModel('NT0MASTER'):GetValue('NT0_COD') ) },,,{MODEL_OPERATION_UPDATE} ) // "Faixa Ocor."
Endif

oView:AddIncrementField( 'NVNDETAIL', 'NVN_COD' )

oView:SetDescription( STR0007 ) //"Contratos do Faturamento"
oView:EnableControlBar( .T. )

oView:SetProgressBar(.T.)

oView:SetCloseOnOk({||.F.})

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Contratos do Faturamento

@author David GonÁalves Fernandes
@since 26/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
	Local oModel     := NIL
	Local lShowVirt  := !JurIsRest() // Inclui os campos virtuais nos structs somente se n„o for REST (Necess·rio j· que os inicializadores dos campos virtuais s„o executados sempre, mesmo sem o uso do header FIELDVIRTUAL = TRUE)
	Local oStruct    := FWFormStruct( 1, 'NT0',,, lShowVirt )  //Contratos
	Local oStructNT1 := FWFormStruct( 1, 'NT1',,, lShowVirt )  //Vencimentos
	Local oStructNTR := FWFormStruct( 1, 'NTR',,, lShowVirt )  //Faixas
	Local oStructNUT := FWFormStruct( 1, 'NUT',,, lShowVirt )  //Casos do Contrato
	Local oStructNTK := FWFormStruct( 1, 'NTK',,, lShowVirt )  //Tipos de Despesas Nao Cobraveis
	Local oStructNTJ := FWFormStruct( 1, 'NTJ',,, lShowVirt )  //Tipos de Atividade Nao Cobravel
	Local oStructNVN := FWFormStruct( 1, 'NVN',,, lShowVirt )  //CÛpia da fatura
	Local oStructNW3 := FWFormStruct( 1, 'NW3',,, lShowVirt )  //Contratos Vinculados
	Local oStrcNW3_  := FWFormStruct( 1, 'NW3',,, lShowVirt )  //Contratos Vinculados (Auxiliar)
	Local oStructNT5 := FWFormStruct( 1, 'NT5',,, lShowVirt )  //TÌtulo do Contrato por Idioma
	Local oStructNXP := FWFormStruct( 1, 'NXP',,, lShowVirt )  //Pagadores do Contrato
	Local oStructNWE := FWFormStruct( 1, 'NWE',,, lShowVirt )  //Fixo Faturamento
	Local oCommit    := JA096COMMIT():New()	
	Local lIntegraLD := SuperGetMV( "MV_JFSINC", .F., '2') == '1' // Indica se utiliza a integraÁ„o com o Legal Desk
	Local lJURA162   := FWIsInCallStack("JURA162")

If !lShowVirt
	// Adiciona os campos virtuais "SIGLA" novamente nas estruturas, pois foi retirado via lShowVirt,
	// mas precisa existir para execuÁ„o das operaÁıes nos lanÁamentos via REST
	AddCampo(1, "NT0_SIGLA1", @oStruct)
	AddCampo(1, "NUT_SIGLA" , @oStructNUT)
EndIf

//Aplicar valores de default nas v·riaveis est·tica, de forma que quando for chamado o modelo, essas v·riaves existam com os valores iniciais.
J096SetSta()

If Empty(aCpoBotoes)
	aCpoBotoes := {}
	aCpoInBot  := {}
	JUR096CPO()
EndIf

oStructNT1:RemoveField( 'NT1_DCONTR' )    //campos virtuais utilizados na tela de emiss„o de fatura ( JURA203 )
oStructNT1:RemoveField( 'NT1_CCLIEN' )    //campos virtuais utilizados na tela de emiss„o de fatura ( JURA203 )
oStructNT1:RemoveField( 'NT1_CLOJA' )     //campos virtuais utilizados na tela de emiss„o de fatura ( JURA203 )
oStructNT1:RemoveField( 'NT1_DCLIEN' )    //campos virtuais utilizados na tela de emiss„o de fatura ( JURA203 )
oStructNT1:RemoveField( 'NT1_CTPHON' )    //campos virtuais utilizados na tela de emiss„o de fatura ( JURA203 )
oStructNT1:RemoveField( 'NT1_DTPHON' )    //campos virtuais utilizados na tela de emiss„o de fatura ( JURA203 )

//Libera ediÁ„o apenas de faturamentos pendentes e n„o deletados
oStructNT1:setProperty("*"         , MODEL_FIELD_WHEN, {|model| !model:isDeleted() .and. model:GetValue("NT1_SITUAC")=="1" } )
oStructNT1:setProperty("NT1_DESCRI", MODEL_FIELD_WHEN, {|model| !model:isDeleted() }) // Ser· possÌvel alterar somente a descriÁ„o

IIf(lShowVirt, oStructNUT:setProperty("NUT_DCONTR", MODEL_FIELD_INIT, Nil), Nil) // Campo removido do view n„o precisa executar o inicializador padr„o

oModel:= MPFormModel():New( 'JURA096', /*Pre-Validacao*/, {|oX| JUR96TUDOK(oX)}/*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( 'NT0MASTER', NIL, oStruct, /*Pre-Validacao*/,  /*Pos-Validacao*/ )

oModel:AddGrid( 'NT1DETAIL', 'NT0MASTER' /*cOwner*/, oStructNT1, { |oSubModel,nLinha,cAction,cCampo,xComp,xValue| JA096VE(oSubModel,nLinha,cAction,cCampo,xComp,xValue) }/*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, {|oGrid| JLoadGrid(oGrid,"NT1_SEQUEN",oModel)})
oModel:AddGrid( 'NTRDETAIL', 'NT0MASTER' /*cOwner*/, oStructNTR, /*bLinePre*/, { || JA125VLFX( oModel:GetModel('NTRDETAIL') , 'NTRDETAIL' ) } /*bLinePost*/,/*bPre*/, /*bPost*/ )

If lJURA162 // Rotina de Pesquisa de processo JURA162
	oModel:AddGrid('NUTDETAIL', 'NT0MASTER' /*cOwner*/, oStructNUT, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/, {|oModelGrid,lLoad| JA096NUT(oModelGrid,lLoad)})
Else
	oModel:AddGrid('NUTDETAIL', 'NT0MASTER' /*cOwner*/, oStructNUT, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/, {|oModelGrid, lLoad| JA96NUTLoad(oModelGrid, lLoad)})
EndIf

oModel:AddGrid( 'NTKDETAIL', 'NT0MASTER' /*cOwner*/, oStructNTK, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:AddGrid( 'NTJDETAIL', 'NT0MASTER' /*cOwner*/, oStructNTJ, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:AddGrid( 'NW3_DETAIL','NT0MASTER' /*cOwner*/, oStrcNW3_ , /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:AddGrid( 'NW3DETAIL', 'NW3_DETAIL'/*cOwner*/, oStructNW3, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:AddGrid( 'NT5DETAIL', 'NT0MASTER' /*cOwner*/, oStructNT5, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:AddGrid( 'NWEDETAIL', 'NT1DETAIL' /*cOwner*/, oStructNWE, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:AddGrid( 'NXPDETAIL', 'NT0MASTER' /*cOwner*/, oStructNXP, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:AddGrid( 'NVNDETAIL', 'NXPDETAIL' /*cOwner*/, oStructNVN, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )

oModel:SetDescription( STR0015 ) //"Modelo de Dados de Contratos do Faturamento"
oModel:GetModel( 'NT0MASTER' ):SetDescription( STR0016 ) //"Dados de Contratos do Faturamento"

oModel:GetModel( 'NT1DETAIL' ):SetUniqueLine( { 'NT1_PARC'   } )
oModel:GetModel( 'NTRDETAIL' ):SetUniqueLine( { 'NTR_COD'    } )
oModel:GetModel( 'NUTDETAIL' ):SetUniqueLine( { 'NUT_CCLIEN', 'NUT_CLOJA', 'NUT_CCASO'  } )
oModel:GetModel( 'NTKDETAIL' ):SetUniqueLine( { 'NTK_CTPDSP' } )
oModel:GetModel( 'NTJDETAIL' ):SetUniqueLine( { 'NTJ_CTPATV' } )
oModel:GetModel( 'NW3_DETAIL'):SetUniqueLine( { 'NW3_CJCONT','NW3_CCONTR' } )
oModel:GetModel( 'NW3DETAIL' ):SetUniqueLine( { 'NW3_CJCONT','NW3_CCONTR' } )
oModel:GetModel( 'NT5DETAIL' ):SetUniqueLine( { 'NT5_CIDIOM' } )
oModel:GetModel( 'NWEDETAIL' ):SetUniqueLine( { 'NWE_CFIXO','NWE_CWO','NWE_CFATUR','NWE_CESCR','NWE_PRECNF' } )
oModel:GetModel( 'NXPDETAIL' ):SetUniqueLine( { 'NXP_CLIPG', 'NXP_LOJAPG' } )
oModel:GetModel( 'NVNDETAIL' ):SetUniqueLine( { 'NVN_CCONT'} )

oModel:SetRelation( 'NT1DETAIL', { { 'NT1_FILIAL', "XFILIAL('NT1')" }, { 'NT1_CCONTR', 'NT0_COD'   }}, NT1->( IndexKey( 1 ) ) )
oModel:SetRelation( 'NTRDETAIL', { { 'NTR_FILIAL', "XFILIAL('NTR')" }, { 'NTR_CCONTR', 'NT0_COD'   }}, NTR->( IndexKey( 1 ) ) )
oModel:SetRelation( 'NUTDETAIL', { { 'NUT_FILIAL', "XFILIAL('NUT')" }, { 'NUT_CCONTR', 'NT0_COD'   }}, NUT->( IndexKey( 1 ) ) )
oModel:SetRelation( 'NTKDETAIL', { { 'NTK_FILIAL', "XFILIAL('NTK')" }, { 'NTK_CCONTR', 'NT0_COD'   }}, NTK->( IndexKey( 1 ) ) )
oModel:SetRelation( 'NTJDETAIL', { { 'NTJ_FILIAL', "XFILIAL('NTJ')" }, { 'NTJ_CCONTR', 'NT0_COD'   }}, NTJ->( IndexKey( 1 ) ) )
oModel:SetRelation( 'NW3_DETAIL',{ { 'NW3_FILIAL', "XFILIAL('NW3')" }, { 'NW3_CCONTR', 'NT0_COD'   }}, NW3->( IndexKey( 3 ) ) )
oModel:SetRelation( 'NW3DETAIL', { { 'NW3_FILIAL', "XFILIAL('NW3')" }, { 'NW3_CJCONT', 'NW3_CJCONT'}}, NW3->( IndexKey( 1 ) ) )
oModel:SetRelation( 'NT5DETAIL', { { 'NT5_FILIAL', "XFILIAL('NT5')" }, { 'NT5_CCONTR', 'NT0_COD'   }}, NT5->( IndexKey( 2 ) ) )
oModel:SetRelation( 'NWEDETAIL', { { 'NWE_FILIAL', "XFILIAL('NWE')" }, { 'NWE_CFIXO',  'NT1_SEQUEN' } }, "R_E_C_N_O_" )
oModel:SetRelation( 'NXPDETAIL', { { 'NXP_FILIAL', "XFILIAL('NXP')" }, { 'NXP_CCONTR', 'NT0_COD'   }}, NXP->( IndexKey( 2 ) ) )
oModel:SetRelation( 'NVNDETAIL', { { 'NVN_FILIAL', "XFILIAL('NVN')" }, { 'NVN_CCONTR', 'NT0_COD'   }, { 'NVN_CLIPG', 'NXP_CLIPG' }, { 'NVN_LOJPG', 'NXP_LOJAPG' } }, NVN->( IndexKey( 5 ) ) )

oModel:GetModel( 'NT1DETAIL' ):SetDelAllLine( .T. )
oModel:GetModel( "NUTDETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NTKDETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NTJDETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NTRDETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NT5DETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NWEDETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NXPDETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NVNDETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NW3DETAIL" ):SetOnlyView( .T. )

oModel:SetOptional("NT1DETAIL", .T. )
oModel:SetOptional("NUTDETAIL", .T. )
oModel:SetOptional("NTKDETAIL", .T. )
oModel:SetOptional("NTJDETAIL", .T. )
oModel:SetOptional("NTRDETAIL", .T. )
oModel:SetOptional("NW3DETAIL", .T. )
oModel:SetOptional("NT5DETAIL", .T. )
oModel:SetOptional("NTRDETAIL", .T. )
oModel:SetOptional("NW3_DETAIL",.T. )
oModel:SetOptional("NWEDETAIL", .T. )
oModel:SetOptional("NXPDETAIL", .T. )
oModel:SetOptional("NVNDETAIL", .T. )

// Retirar esta linha se houver algum erro de TOP relacionado a tabela NT1 ou NWE.
oModel:GetModel('NWEDETAIL'):SetOnlyView ( .T. )

oStructNT1:SetProperty( 'NT1_SEQUEN' , MODEL_FIELD_NOUPD, .T. )
oStructNT1:SetProperty( 'NT1_SITUAC' , MODEL_FIELD_NOUPD, .T. )
oStructNT1:SetProperty( 'NT1_CPREFT' , MODEL_FIELD_NOUPD, .T. )
oStructNT1:SetProperty( 'NT1_COTAC1' , MODEL_FIELD_NOUPD, .T. )
oStructNT1:SetProperty( 'NT1_COTAC2' , MODEL_FIELD_NOUPD, .T. )
If NT1->(ColumnPos("NT1_ACAOLD")) > 0
	oStructNT1:SetProperty( 'NT1_ACAOLD', MODEL_FIELD_NOUPD, .T. )
	oStructNT1:SetProperty( 'NT1_INSREV', MODEL_FIELD_NOUPD, .T. )
	oStructNT1:SetProperty( 'NT1_REVISA', MODEL_FIELD_NOUPD, .T. )		
EndIf
If !lIntegraLD .And. NT0->(ColumnPos("NT0_FIXREV")) > 0
	oStruct:SetProperty( 'NT0_FIXREV', MODEL_FIELD_NOUPD, .T. )
EndIf

//Aumenta a capacidade de linhas no grid
oModel:GetModel( "NUTDETAIL" ):SetMaxLine(999999)

oModel:InstallEvent("JA096COMMIT", /*cOwner*/, oCommit)

JurSetRules( oModel, 'NT0MASTER',, 'NT0' )
JurSetRules( oModel, 'NT1DETAIL',, 'NT1' )
JurSetRules( oModel, 'NTRDETAIL',, 'NTR' )
JurSetRules( oModel, 'NUTDETAIL',, 'NUT' )
JurSetRules( oModel, 'NTKDETAIL',, 'NTK' )
JurSetRules( oModel, 'NTJDETAIL',, 'NTJ' )
JurSetRules( oModel, 'NW3DETAIL',, 'NW3' )
JurSetRules( oModel, 'NT5DETAIL',, 'NT5' )
JurSetRules( oModel, 'NWEDETAIL',, 'NWE' )
JurSetRules( oModel, 'NXPDETAIL',, 'NXP' )
JurSetRules( oModel, 'NVNDETAIL',, 'NVN' )

oModel:SetVldActivate( {|oModel| J096VldTpH(oModel)} )

oModel:SetActivate( {|oModel| J096Active(oModel)} )

oModel:SetOnDemand()

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA96CDF
SubView de CondiÁıes de Faturamento de Fixo

@author David GonÁalves Fernandes
@since 26/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA96CDF( oViewPai )
Local oView        := Nil
Local oExecView    := Nil
Local oStruct      := Nil
Local oStructNT1   := Nil
Local nAt          := 0
Local nI           := 0
Local lSubView     := .T.
Local bOk          := { |oModel| JUR96BOK( oModel, lSubView, BOTAOCDF, 'NT1DETAIL' ) }
Local oModel       := oViewPai:GetModel()
Local oModelNT1    := oModel:GetModel('NT1DETAIL')
Local lParcPend    := .F.
Local cTpHon       := FwFldGet('NT0_CTPHON')
Local cTitulo      := FwFldGet('NT0_DTPHON')
Local lRet         := .T.
Local nBotaoAtv    := BOTAOCDF //1 = CondiÁıes de Faturamento de Fixo

If (nAt := J096TemCpo(BOTAOCDF)) == 0
	lRet := .F.
EndIf

If lRet .AND. J096ObrgOk(oModel, aCpoBotoes[nAt][CONFIG], STR0013) // "Cond.Fat.Fixo"

	oStruct    := FWFormStruct(2, 'NT0', { |cCampo| Jur96Exibe( cCampo, aCpoBotoes[nAt][CONFIG] ) })
	oStructNT1 := FWFormStruct(2, 'NT1')
	oStructNWE := FWFormStruct(2, 'NWE')

	oStructNT1:RemoveField('NT1_CCONTR')
	oStructNT1:RemoveField('NT1_SEQUEN')
	oStructNT1:RemoveField('NT1_TKRET' )
	oStructNT1:RemoveField('NT1_DCONTR')    //campos virtuais utilizados na tela de emiss„o de fatura ( JURA203 )
	oStructNT1:RemoveField('NT1_CCLIEN')    //campos virtuais utilizados na tela de emiss„o de fatura ( JURA203 )
	oStructNT1:RemoveField('NT1_CLOJA' )    //campos virtuais utilizados na tela de emiss„o de fatura ( JURA203 )
	oStructNT1:RemoveField('NT1_DCLIEN')    //campos virtuais utilizados na tela de emiss„o de fatura ( JURA203 )
	oStructNT1:RemoveField('NT1_CTPHON')    //campos virtuais utilizados na tela de emiss„o de fatura ( JURA203 )
	oStructNT1:RemoveField('NT1_DTPHON')    //campos virtuais utilizados na tela de emiss„o de fatura ( JURA203 )
	If NT1->(ColumnPos('NT1_COTAC')) > 0 //ProteÁ„o
		oStructNT1:RemoveField('NT1_COTAC')
		oStructNWE:RemoveField('NWE_COTAC')
	EndIf
	If NT1->(ColumnPos("NT1_ACAOLD")) > 0
		oStructNT1:RemoveField('NT1_ACAOLD')
		oStructNT1:RemoveField('NT1_INSREV')
		oStructNT1:RemoveField('NT1_REVISA')	
	EndIf
	oStructNT1:RemoveField('NT1_OK'    )
	oStructNWE:RemoveField('NWE_CFIXO' )
	oStructNT1:SetProperty('NT1_PARC'  , MVC_VIEW_CANCHANGE, .F. )
	oStructNT1:SetProperty('NT1_QTDADE', MVC_VIEW_CANCHANGE, .F. )

	oView := FWFormView():New(oViewPai)
	oView:SetModel(oModel)

	oView:AddField( 'JURA96CDF_VIEW', oStruct, 'NT0MASTER' )

	If JUR96TPFIX(cTpHon) .And. !(JUR96FAIXA(cTpHon))  //Verificar o Tipo de Honor·rios para exibir ou n„o o Grid NT1

		oView:AddGrid('JURA096_GRIDNT1', oStructNT1, 'NT1DETAIL')
		oView:AddGrid('JURA096_GRIDNWE', oStructNWE, 'NWEDETAIL')

		oView:CreateHorizontalBox('FORMFIELD', 50)
		oView:CreateHorizontalBox('FORMGRID', 50)

		oView:CreateFolder('FOLDER_01', 'FORMGRID')
		oView:AddSheet('FOLDER_01', 'ABA_01', STR0163) // "Parcelas"
		oView:AddSheet('FOLDER_01', 'ABA_02', STR0164) // "Faturamento"
		oView:CreateHorizontalBox('BOX_A01_F01',100,,,'FOLDER_01','ABA_01')
		oView:CreateHorizontalBox('BOX_A02_F01',100,,,'FOLDER_01','ABA_02')

		oView:SetOwnerView('JURA96CDF_VIEW' , 'FORMFIELD')
		oView:SetOwnerView('JURA096_GRIDNT1', 'BOX_A01_F01')
		oView:SetOwnerView('JURA096_GRIDNWE', 'BOX_A02_F01')
		oView:AddIncrementField('NT1DETAIL' , 'NT1_PARC')

		oView:SetNoDeleteLine('JURA096_GRIDNWE')
		oView:SetNoInsertLine('JURA096_GRIDNWE')
		oView:SetNoUpdateLine('JURA096_GRIDNWE')

		//Verifica se geraÁ„o de parcelas È autom·tica
		If J96TPHPAut(cTpHon)
			oView:SetNoDeleteLine('JURA096_GRIDNT1')
			oView:SetNoInsertLine('JURA096_GRIDNT1')

			//Verifica a existÍncia de parcelas pendentes
			lParcPend := .F.

			If !oModelNT1:IsEmpty()
				For nI := 1 To oModelNT1:GetQtdLine()
					If !oModelNT1:IsDeleted(nI) .And. oModelNT1:GetValue("NT1_SITUAC", nI) == "1"
						lParcPend := .T.
						Exit
					EndIf
				Next
			Else
				J096SetNo(oModelNT1, .T.)
			EndIf

			If lParcPend
				If JUR96TPFIX(oModel:GetValue('NT0MASTER','NT0_CTPHON'))
					oStruct:SetProperty("NT0_DTBASE",  MVC_VIEW_CANCHANGE, .T.)
					oStruct:SetProperty("NT0_CMOEF" ,  MVC_VIEW_CANCHANGE, .T.)
					oStruct:SetProperty("NT0_VLRBAS",  MVC_VIEW_CANCHANGE, .T.)
					oStruct:SetProperty("NT0_TPCORR",  MVC_VIEW_CANCHANGE, .T.)
					oStruct:SetProperty("NT0_CINDIC",  MVC_VIEW_CANCHANGE, .T.)
					oStruct:SetProperty("NT0_PERCOR",  MVC_VIEW_CANCHANGE, .T.)
					oStruct:SetProperty("NT0_DESPAR",  MVC_VIEW_CANCHANGE, .T.)
					If Val(JURGETDADOS('NTH', 1, xFilial('NTH') + cTpHon + "NT0_PERFIX", "NTH_VISIV")) == 1 //Verifica se o campo est· visÌvel
						oStruct:SetProperty("NT0_PERFIX", MVC_VIEW_CANCHANGE, .T.)
					EndIf
					If Val(JURGETDADOS('NTH', 1, xFilial('NTH') + cTpHon + "NT0_PEREX", "NTH_VISIV")) == 1 //Verifica se o campo est· visÌvel
						oStruct:SetProperty("NT0_PEREX", MVC_VIEW_CANCHANGE, .T.)
					EndIf
					If Val(JURGETDADOS('NTH', 1, xFilial('NTH') + cTpHon + "NT0_TPCEXC", "NTH_VISIV")) == 1
						oStruct:SetProperty("NT0_TPCEXC", MVC_VIEW_CANCHANGE, .T.)
					EndIf
					If Val(JURGETDADOS('NTH', 1, xFilial('NTH') + cTpHon + "NT0_LIMEXH", "NTH_VISIV")) == 1
						oStruct:SetProperty("NT0_LIMEXH", MVC_VIEW_CANCHANGE, .T.)
					EndIf
					If Val(JURGETDADOS('NTH', 1, xFilial('NTH') + cTpHon + "NT0_PERCD", "NTH_VISIV")) == 1
						oStruct:SetProperty("NT0_PERCD", MVC_VIEW_CANCHANGE, .T.)
					EndIf

				Else
					oStruct:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)
				EndIf

				J096EdtNT1(oModel) //Libera NT1 para ediÁ„o de acordo com Tipo de Hono

			EndIf
		Else
			J096EdtNT1(oModel) //Libera NT1 para ediÁ„o de acordo com Tipo de Hono
		EndIf

	Else
		oView:CreateHorizontalBox( 'FORMFIELD', 100 )
		oView:SetOwnerView( 'JURA96CDF_VIEW', 'FORMFIELD' )
	EndIf
	oView:SetDescription( STR0019 ) // "CondiÁıes de Faturamento"
	oView:SetOperation( oModel:GetOperation() )

	If (JUR96TPFIX(cTpHon)) .And. !(JUR96FAIXA(cTpHon))
		oView:AddUserButton( STR0112, 'MENURUN', { |oView| J96CorrCDF(oView:GetModel()) } ) //"Corrigir Valor"
		oView:AddUserButton( STR0114, 'NOCHECKED', { |oView| J96WOFixo(oView) } ) //"WO"
		If !(AllTrim(JURGETDADOS('NTH', 1, xFilial('NTH') + cTpHon + "NT0_PARCE", "NTH_VLPAD")) == "2" .And. ;
		     AllTrim(JURGETDADOS('NTH', 1, xFilial('NTH') + cTpHon + "NT0_PARFIX", "NTH_VLPAD")) == "2")
			oView:AddUserButton( STR0126, 'MENURUN', { |oModel| J096Parcela(oModel, nBotaoAtv) } )//"Parcelas"
		EndIf
	EndIf

	J96DtRef() // Sugere a data de referencia inicial da paracela de fixo com base no caso mais antigo

	aArmzNT0 := J096ArmzNT0(oModel, nBotaoAtv)//Armazena Valores do NT0

	oView:SetCloseOnOk({|| .T.})

	oExecView:= FwViewExec():New()
	oExecView:setView(oView)
	oExecView:setReduction(30)
	oExecView:setTitle(cTitulo)
	oExecView:setOk(bOK)
	oExecView:openView(.F.)
EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA96FXA
SubView de Faixa de Valores

@author David GonÁalves Fernandes
@since 26/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA96FXA( oViewPai )
Local oView      := Nil
Local oExecView  := Nil
Local oStruct    := Nil
Local oStructNTR := Nil
Local oStructNT1 := Nil
Local oStructNWE := Nil
Local lSubView   := .T.
Local nAt        := 0
Local lFixo      := .F.
Local oModel     := oViewPai:GetModel()
Local bOk        := { |oModel| J96BOKNTR( oModel, lSubView, BOTAOFXA, 'NTRDETAIL') }
Local oModelNT0  := oModel:GetModel('NT0MASTER')
Local cTitulo    := oModelNT0:GetValue('NT0_DTPHON')
Local cTpHon     := oModelNT0:GetValue('NT0_CTPHON')
Local nBotaoAtv  := BOTAOFXA // 2 = Faixa de Valores

If (nAt := J096TemCpo(BOTAOFXA)) == 0

	Return NIL

ElseIf J096ObrgOk(oModel, aCpoBotoes[nAt][CONFIG], STR0014) // "Fx.Val."

	oStruct    := FWFormStruct( 2, 'NT0', { |cCampo| Jur96Exibe( cCampo, aCpoBotoes[nAt][CONFIG] ) } )
	oStructNTR := FWFormStruct( 2, 'NTR' )
	If JUR96TPFIX(cTpHon) .And. JUR96FAIXA(cTpHon) //Verifica se o tipo de honor·rios cobra Fixo e se o campo ìNT0_FXABM" ou o ìNT0_FXENCMî est„o visÌveis (NTH_VISIV = ì1î) (Quantidade de Casos).
		oStructNT1 := FWFormStruct( 2, 'NT1' )
		oStructNWE := FWFormStruct( 2, 'NWE' )
		oStructNT1:SetProperty( 'NT1_PARC', MVC_VIEW_CANCHANGE, .F. )
		lFixo := .T.
	EndIf

	oStructNTR:RemoveField( 'NTR_CCONTR' )
	oStructNTR:RemoveField( 'NTR_COD' )

	If lFixo
		oStructNT1:RemoveField('NT1_CCONTR')
		oStructNT1:RemoveField('NT1_SEQUEN')
		oStructNT1:RemoveField('NT1_TKRET' )
		oStructNT1:RemoveField('NT1_DCONTR')    //campos virtuais utilizados na tela de emiss„o de fatura ( JURA203 )
		oStructNT1:RemoveField('NT1_CCLIEN')    //campos virtuais utilizados na tela de emiss„o de fatura ( JURA203 )
		oStructNT1:RemoveField('NT1_CLOJA' )    //campos virtuais utilizados na tela de emiss„o de fatura ( JURA203 )
		oStructNT1:RemoveField('NT1_DCLIEN')    //campos virtuais utilizados na tela de emiss„o de fatura ( JURA203 )
		oStructNT1:RemoveField('NT1_CTPHON')    //campos virtuais utilizados na tela de emiss„o de fatura ( JURA203 )
		oStructNT1:RemoveField('NT1_DTPHON')    //campos virtuais utilizados na tela de emiss„o de fatura ( JURA203 )
		oStructNT1:RemoveField('NT1_OK'    )
		oStructNWE:RemoveField('NWE_CFIXO' )
		If NT1->(ColumnPos("NT1_ACAOLD")) > 0
			oStructNT1:RemoveField('NT1_ACAOLD')
			oStructNT1:RemoveField('NT1_INSREV')
			oStructNT1:RemoveField('NT1_REVISA')	
		EndIf
		// Tratamento para permitir a digitaÁ„o da quantidade de casos manualmente
		oStructNT1:SetProperty('NT1_QTDADE', MVC_VIEW_CANCHANGE, SuperGetMV("MV_JQTDAUT", .F., "1") == "2")
	EndIf

	JurSetAgrp( 'NT0',, oStruct )
	JurSetAgrp( 'NT0',, oStruct )
	JurSetAgrp( 'NT0',, oStruct )

	oView := FWFormView():New( oViewPai )
	oView:SetModel( oModel )

	oView:AddField( 'JURA96FXA_VIEW' , oStruct   , 'NT0MASTER' )
	oView:AddGrid(  'JURA096_GRIDNTR', oStructNTR, 'NTRDETAIL' )
	If lFixo
		oView:AddGrid( 'JURA096_GRIDNT1', oStructNT1, 'NT1DETAIL' )
		oView:AddIncrementField('NT1DETAIL', 'NT1_PARC')

		oView:AddGrid( 'JURA096_GRIDNWE', oStructNWE, 'NWEDETAIL' )
		oView:SetNoDeleteLine('JURA096_GRIDNWE')
		oView:SetNoInsertLine('JURA096_GRIDNWE')
		oView:SetNoUpdateLine('JURA096_GRIDNWE')
	EndIf

	oView:CreateHorizontalBox( "BOX_A01_F01", 30 )
	oView:CreateHorizontalBox( "BOX_A01_F02", 70 )

	oView:CreateFolder('FOLDER_02','BOX_A01_F02')

	oView:AddSheet('FOLDER_02','ABA_01_01', STR0020 )  //"Faixa de Valores"
	If lFixo
		oView:AddSheet('FOLDER_02','ABA_01_02', STR0163 )  //"Parcelas"
		oView:AddSheet('FOLDER_02','ABA_01_03', STR0164 )  //"Faturamento"
	EndIf

	oView:CreateHorizontalBox('BOX_A01_F02_01',100,,,'FOLDER_02','ABA_01_01')
	oView:CreateHorizontalBox('BOX_A01_F02_02',100,,,'FOLDER_02','ABA_01_02')
	oView:CreateHorizontalBox('BOX_A01_F02_03',100,,,'FOLDER_02','ABA_01_03')

	oView:SetOwnerView( 'JURA96FXA_VIEW' , 'BOX_A01_F01' )
	oView:SetOwnerView( 'JURA096_GRIDNTR', 'BOX_A01_F02_01' )
	If lFixo
		oView:SetOwnerView( 'JURA096_GRIDNT1', 'BOX_A01_F02_02' )
		oView:SetOwnerView( 'JURA096_GRIDNWE', 'BOX_A01_F02_03' )
	EndIf

	oView:SetDescription( STR0020 ) // "Faixa de Valores"

	oView:SetOperation( oModel:GetOperation() )

	If lFixo
		oView:AddUserButton( STR0112, 'MENURUN',   { |oView| J96CorrCDF(oView:GetModel()) } ) //"Corrigir Valor"
		oView:AddUserButton( STR0113, 'MENURUN',   { |oView| J96CalcCDF(oView:GetModel()) } ) //"Calcular"
		oView:AddUserButton( STR0114, 'NOCHECKED', { |oView| J96WOFixo(oView) } ) //"WO"
		oView:AddUserButton( STR0126, 'MENURUN',   { |oModel| J096Parcela(oModel, nBotaoAtv) } )//"Parcelar"
		J096EdtNT1(oModel)
	EndIf

	oView:SetCloseOnOk({|| .T.})

	oExecView:= FwViewExec():New()
	oExecView:setView(oView)
	oExecView:setReduction(30)
	oExecView:setTitle(cTitulo)
	oExecView:setOk(bOK)
	oExecView:openView(.F.)

EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR96BOK
TudoOk dos botoes com SubView

@obs FunÁ„o chamada na AutomaÁ„o.

@author David GonÁalves Fernandes
@since 26/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR96BOK( oModel, lSubView, nBotao, cId )
Local aArea       := GetArea()
Local aAreaNTH    := NTH->( GetArea() )
Local aErro       := {}
Local lRet        := .T.
Local nI          := 0
Local oModelNT0   := oModel:GetModel('NT0MASTER')
Local cCTPHON     := oModelNT0:GetValue('NT0_CTPHON' )
Local cTpCalc     := oModelNT0:GetValue('NT0_CALFX' )
Local nAt         := aScan( aCpoBotoes, { |x| x[CTPHON] == cCTPHON .AND. X[BOTAO] == nBotao} )
Local cCampo      := ''
Local oModelNT1   := oModel:GetModel('NT1DETAIL')
Local nQtdLines   := oModelNT1:GetQtdLine()
Local oModelNTR   := Nil
Local lDt         := .T.
Local dDataNT0    := oModelNT0:GetValue('NT0_DTBASE')
Local cTpCorr     := oModelNT0:GetValue('NT0_TPCORR')
Local lQtdCas     := Iif(JUR96FAIXA(cCTPHON), .T., .F.)
Local nLinhaAtu   := 0
Local lParcAut    := J96TPHPAut(cCTPHON)
Local lParcDef    := !lParcAut .And. JurGetDados("NTH", 1, xFilial("NTH") + cCTPHON + "NT0_QTPARC", "NTH_VISIV") == "1"

cUser := '2'  // AlteraÁıes feitas pelo sistema, deve permitir a manipulaÁ„o autom·tica das parcelas

lRet := J096VlDtNT1(oModel) //Valida Datas do Grid NT1

If lRet  // Quando o campo 'NT0_DTBASE' n„o for obrigatÛrio, mas o campo NT0_TPCORR for diferente de '1', obrigar a digitaÁıa do campo: NT0_DTBASE.
	NTH->(DbSetOrder(1)) // NTH_FILIAL+NTH_CTPHON+NTH_CAMPO
	If NTH->(DbSeek(xFilial("NTH") + cCTPHON + "NT0_DTBASE")) .And. NTH->NTH_OBRIGA <> "1"
		If Empty(dDataNT0) .And. AllTrim(cTpCorr) <> "1"
			lRet := .F.
			ApMsgInfo(STR0185) // "O campo 'Data Base' deve ser preenchido."
		EndIf
	EndIf

EndIf

If lRet
	For nI := 1 To Len( aCpoBotoes[nAt][CONFIG] )
		cCampo := AllTrim( aCpoBotoes[nAt][CONFIG][nI][CAMPO] )
		If aCpoBotoes[nAt][CONFIG][nI][OBRIGA] .And. Empty( FwFldGet( cCampo ) )
			lRet := .F.
			Do Case
			Case nBotao == BOTAOCDF
				// #"Bot„o Cond. Fat.: " ##"O campo " ###") n„o foi preenchido"
				JurMsgErro( STR0214+CRLF+STR0098 + AllTrim( RetTitle( cCampo ) ) + " (" + cCampo + STR0022 )
			Case nBotao == BOTAOFXA
				JurMsgErro( STR0082 + AllTrim( RetTitle( cCampo ) ) + " (" + cCampo + STR0022 )
			End Case
			Exit
		EndIf
		If (cCampo == 'NT0_DTREFI' .Or. cCampo == 'NT0_DTVENC') .And. aCpoBotoes[nAt][CONFIG][nI][VISIV] == .F. //Analisa se os campos de Data est· visÌvel
			lDt := .F.
		EndIf
	Next
EndIf

// Valida a situaÁ„o do contrato, se o cliente for provisorio o contrato tambem deve ser
Iif(lRet, lRet := J096VldDef(), )

If lRet .And. cId = 'NT1DETAIL' .And. cTpCorr == "2" .And. Empty(oModelNT0:GetValue("NT0_CINDIC"))
	lRet := JurMsgErro( STR0097 )// "… preciso preencher o indice!"
EndIf

If lRet
	lRet := oModel:VldData( cId )
	If !lRet
		aErro := oModel:GetErrorMessage()
		JurMsgErro( aErro[6] )
	EndIf
EndIf

If lRet .And. cId = 'NTRDETAIL'

	oModelNTR := oModel:GetModel('NTRDETAIL')

	If J096TemCpo(BOTAOFXA, .F.) > 0

		If !oModelNTR:IsEmpty()
			If !JA125VLFX(oModelNTR, cId)
				lRet := .F.
			EndIf

			If lRet
				If !JA125VLTP( oModelNTR, cId, cTpCalc )
					lRet := .F.
				EndIf
			EndIf
		Else
			lRet := JurMsgErro( STR0083 ) // "A faixa de faturamento deve ser preenchida."
		EndIf

		// Valida se h· faixa iniciada em 0 e uma terminada em 99999.
		If lRet .And. !JVldPerFx(oModelNTR, "NTR_VLINI", "NTR_VLFIM", lQtdCas )
			lRet := .F.
		EndIf

		// Valida se h· lacunas entre as faixas
		If lRet .And. !JVldLacFx(oModelNTR, "NTR_VLINI", "NTR_VLFIM", lQtdCas )
			lRet := .F.
		EndIf

	EndIf

EndIf

If lRet .And. cId = 'NT1DETAIL'
	nLinhaAtu := oModelNT1:GetLine()
	For nI := 1 To nQtdLines

		If oModelNT1:IsDeleted(nI)
			Loop
		EndIf
		If !Empty(oModelNT1:GetValue("NT1_DATAIN", nI)) .Or. !Empty(oModelNT1:GetValue("NT1_DATAFI", nI)) .Or. !Empty(oModelNT1:GetValue("NT1_VALORB", nI)) .Or. ;
		   !Empty(oModelNT1:GetValue("NT1_DATAVE", nI)) .Or. !Empty(oModelNT1:GetValue("NT1_DESCRI", nI)) .Or. !Empty(oModelNT1:GetValue("NT1_CMOEDA", nI))
			Do Case
			Case (lParcAut .Or. lParcDef) .And. Empty(oModelNT1:GetValue("NT1_DATAIN", nI))
				lRet := JurMsgErro(STR0133 + oModelNT1:GetValue("NT1_PARC", nI) + ". " + STR0198 ) // Erro na Parcela ### "O campo 'Data Referencia Inicial' deve ser preenchido."
			Case (lParcAut .Or. lParcDef) .And. Empty(oModelNT1:GetValue("NT1_DATAFI", nI))
				lRet := JurMsgErro(STR0133 + oModelNT1:GetValue("NT1_PARC", nI) + ". " + STR0199) // Erro na Parcela ### "O campo 'Data Referencia Final' deve ser preenchido."
			Case (lParcAut .Or. lParcDef) .And. Empty(oModelNT1:GetValue("NT1_VALORB", nI))
				lRet := JurMsgErro(STR0133 + oModelNT1:GetValue("NT1_PARC", nI) + ". " + STR0200) // Erro na Parcela ### "O campo 'Valor Base' deve ser preenchido."
			Case (lParcAut .Or. lParcDef) .And. Empty(oModelNT1:GetValue("NT1_DATAVE", nI))
				lRet := JurMsgErro(STR0133 + oModelNT1:GetValue("NT1_PARC", nI) + ". " + STR0201) // Erro na Parcela ### "O campo 'Data de Vencimento' deve ser preenchido."
			Case Empty(oModelNT1:GetValue("NT1_DESCRI", nI))
				lRet := JurMsgErro(STR0133 + oModelNT1:GetValue("NT1_PARC", nI) + ". " + STR0202) // Erro na Parcela ### "O campo 'Descricao' deve ser preenchido."
			Case (lParcAut .Or. lParcDef) .And. Empty(oModelNT1:GetValue("NT1_CMOEDA", nI))
				lRet := JurMsgErro(STR0133 + oModelNT1:GetValue("NT1_PARC", nI) + ". " + STR0203) // Erro na Parcela ### "O campo 'Codigo Moeda Fatura' deve ser preenchido."
			EndCase
		EndIf

		If lRet
			lRet := J96VerPreFat(oModel, nI)
		EndIf

		If !lRet
			Exit
		EndIf
	Next nI
	oModelNT1:GoLine(nLinhaAtu)
EndIf

// lSubView: na Tela de Contrato n„o È informada, sÛ È informado no bot„o Confirmar da tela "Cond de Faturamente" e "Faixa Faturamento"
If lRet .And. lSubView .And. JUR96TPFIX(cCTPHON)
	J096ConfPa(oModel, nBotao)
EndIf

If lRet .And. lSubView
	lCtlCndFat:= .T.
EndIf

cUser := '1' // Retorna a alteraÁıes do usu·rio

RestArea( aAreaNTH )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR096CPO
Carga dos campos configuraveis

@author David GonÁalves Fernandes
@since 26/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JUR096CPO()
Local aArea     := GetArea()
Local aAreaNTH  := NTH->( GetArea() )
Local cFilNTH   := xFilial( 'NTH' )
Local nAt       := 0
Local cConcat   := ""

NTH->( dbSetOrder( 1 ) )
NTH->( DbSeek( cFilNTH ) )

While !NTH->( EOF() )

	If ( nAt := aScan( aCpoBotoes, { |x| x[CTPHON] == NTH->NTH_CTPHON .AND. X[BOTAO] == NTH->NTH_BOTAO } ) ) == 0
		aAdd( aCpoBotoes, { NTH->NTH_CTPHON, NTH->NTH_BOTAO, {} } )
		nAt := Len( aCpoBotoes )
	EndIf

	If GetSx3Cache(NTH->NTH_CAMPO, 'X3_TIPO') == 'C'
		cConcat := "'"
	Else
		cConcat := ""
	EndIf

	aAdd( aCpoBotoes[nAt][CONFIG], { NTH->NTH_CAMPO, &( '{|| ' +cConcat+ AllTrim( NTH->NTH_VLPAD ) +cConcat+ ' }' ), ( NTH->NTH_VISIV == '1' ), ( NTH->NTH_OBRIGA == '1' ) } )

	If aScan( aCpoInBot, { |x| x[1] == NTH->NTH_CAMPO } ) == 0
		aAdd( aCpoInBot, { NTH->NTH_CAMPO, } )
	EndIf

	NTH->( dbSkip() )
EndDo

NTH->(RestArea( aAreaNTH ))
RestArea( aArea )

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR96INI
Inicializacao dos campos configuraveis na troca do tipo

@author David GonÁalves Fernandes
@since 26/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR96INI()
Local cCTPHON := FwFldGet( 'NT0_CTPHON' )
Local lRet    := cCTPHON
Local nI      := 0
Local nJ      := 0
Local oModel  := FwModelActive()
Local aErro   := {}
Local cMsg    := ''
Local cCampo  := ''
Local lErro   := .F.

For nI := 1 To Len( aCpoBotoes )

	If aCpoBotoes[nI][CTPHON] == cCTPHON

		For nJ := 1 To Len( aCpoBotoes[nI][CONFIG] )
			cCampo := AllTrim( aCpoBotoes[nI][CONFIG][nJ][CAMPO]  )

			If !oModel:LoadValue( FwFindId( cCampo ), cCampo, Eval( aCpoBotoes[nI][CONFIG][nJ][INICIA] ) )

				aErro := oModel:GetErrorMessage()

				cMsg  := STR0024 + cCampo + ; // "N„o foi possÌvel inicializar o campo "
				STR0025  +  GetCbSource( aCpoBotoes[nI][CONFIG][nJ][INICIA] ) + CRLF + aErro[6] //" com o conte˙do "

				JurMsgErro( cMsg )

				Alert( cMsg )

				lErro := .T.

				Exit

			EndIf

			If lErro
				Exit
			EndIf

		Next

	EndIf

Next

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR96EXIBE
Verificacao dos campos a serem exibidos na SubView

@author David GonÁalves Fernandes
@since 26/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JUR96EXIBE( pCampo, paCampos )
Local lRet      := .F.
Local vPosicao  := 0

vPosicao := aScan( paCampos, { |x| PadR( x[CAMPO], 10 ) == PadR( pCampo, 10 ) } )

lRet := ( vPosicao > 0 .AND. paCampos[vPosicao][VISIV] )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR96TPFIX
Verifica se o Tipo de Honor·rios È Fixo

@author Fabio Crespo Arruda
@since 22/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JUR96TPFIX(cTpHon)
Local lCobraFix := .F.

lCobraFix := JurGetDados("NRA", 1, xFilial("NRA") + cTpHon, "NRA_COBRAF") == "1"

Return lCobraFix

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR96FAIXA
Verifica se o campo ìNT0_FXABM" ou o ìNT0_FXENCMî est„o visÌveis
(NTH_VISIV = ì1î) na configuraÁ„o de Tipo de Honor·rios, o que
caracteriza os tipos de honor·rios por Faixa - Quantidade de Casos.

@author Cristina Cintra
@since 10/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR96FAIXA( cTpHon )
Local lRet      := .F.
Local aArea     := GetArea()
Local aAreaNTH  := NTH->( GetArea() )

Default cTpHon  := FwFldGet('NT0_CTPHON')

If !Empty(cTpHon)
	NTH->( dbSetOrder( 1 ) ) //NTH_FILIAL+NTH_CTPHON+NTH_CAMPO
	If NTH->( dbSeek( xFilial('NTH') + cTpHon + 'NT0_FXABM' ) )
		lRet := NTH->NTH_VISIV == '1'
		If !lRet
			If NTH->( dbSeek( xFilial('NTH') + cTpHon + 'NT0_FXENCM' ) )
				lRet := NTH->NTH_VISIV == '1'
			EndIf
		EndIf
	EndIf
EndIf

NTH->(RestArea( aAreaNTH ))
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR96TUDOK
Valida os campos na hora de salvar

@author Fabio Crespo Arruda
@since 22/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JUR96TUDOK(oModel)
	Local lRet       := .T.
	Local lSubView   := .F.
	Local lCasMaeNUT := .F.
	Local aArea      := GetArea()
	Local aQtTD      := 0
	Local aTpAti     := {}
	Local aTpDsp     := {}
	Local aNTJAti    := {}
	Local aNTKDsp    := {}
	Local aCodPre    := {}
	Local oModelNT0  := oModel:GetModel('NT0MASTER')
	Local oModelNUT  := oModel:GetModel('NUTDETAIL')
	Local oModelNTK  := oModel:GetModel('NTKDETAIL')
	Local oModelNTJ  := oModel:GetModel('NTJDETAIL')
	Local nQtdNUT    := oModelNUT:GetQtdLine()
	Local nI         := 0
	Local nLinNTJ    := oModelNTJ:GetLine()
	Local nLinNTK    := oModelNTK:GetLine()
	Local nLinNUT    := oModelNUT:GetLine()
	Local nPosAti    := 0
	Local nPosDsp    := 0
	Local nQtdDel    := 0
	Local nFor       := 0
	Local nLenCod    := 0
	Local cQuery     := ""
	Local cMsgErr    := ""
	Local cCodCtr    := oModelNT0:GetValue("NT0_COD")
	Local cLojaAuto  := ""
	Local cTpHon     := ""
	Local lCobraH    := .T.

If oModel:GetOperation() == OP_INCLUIR .Or. oModel:GetOperation() == OP_ALTERAR

	If !JUR96TPHAT(oModel)
		lRet := JurMsgErro(STR0028) //"N„o È possÌvel utilizar este tipo de honor·rios, pois n„o est· ativo"
	EndIf

	If lRet .And. (oModel:GetOperation() == OP_INCLUIR .Or. oModel:IsFieldUpdated("NT0MASTER", "NT0_DTVIGI") .Or. oModel:IsFieldUpdated("NT0MASTER", "NT0_DTVIGF"))
		lRet := J096VigPar(oModel) // Valida as parcelas com a data de vigÍncia
	EndIf

	If lRet .And. (oModelNT0:GetValue("NT0_DISCAS") = "2" .And. Empty(oModelNT0:GetValue("NT0_TITFAT")) )
		lRet := JurMsgErro(STR0029) // "… necess·rio preencher o TÌtulo de Faturamento quando este n„o discriminado na fatura"
	EndIf

	If lRet .And. oModelNT0:GetValue("NT0_ATIVO") == '1' // Indica que o contrato est· ativo
		nQtdDel := 0
		For nI := 1 To nQtdNUT
			If oModelNUT:IsDeleted(nI)
				nQtdDel += 1
			EndIf

			If Empty(oModelNUT:GetValue('NUT_CCASO', nI)) .And. !oModelNUT:IsDeleted(nI) .And. !IsInCallStack("JURA070")
				lRet := JurMsgErro( STR0137 ) // "… obrigatÛrio informar o n˙mero do caso!"
				Exit
			EndIf
		Next nI
	EndIf

	If lRet .And. nQtdDel == nQtdNUT .And. !IsInCallStack("JURA070") .And. oModelNT0:GetValue("NT0_ATIVO") == '1' // Indica que o contrato est· ativo
		lRet := JurMsgErro( STR0108 ) // "… obrigatÛrio vincular pelo menos um caso "
	EndIf

	If lRet
		If !JUR96BOK( oModel, lSubView, BOTAOFXA, 'NTRDETAIL' ) .Or. ;
			!JUR96BOK( oModel, lSubView, BOTAOCDF, 'NT1DETAIL' )
			lRet := .F.
		Endif
	EndIf

	If lRet .AND. oModelNT0:GetValue("NT0_SIT") == '2'   //Obriga os preenchimeo para contr. definitivo
		If Empty(oModelNT0:GetValue("NT0_CPART1"))
			lRet := JurMsgErro(I18N(STR0208, {RetTitle("NT0_SIGLA1")} ) ) //"O campo '#1' deve ser preenchido quando o contrato for definitivo. Verifique!"
		EndIf
		If lRet .AND.  Empty(oModelNT0:GetValue("NT0_CESCR"))
			lRet := JurMsgErro(STR0098 + Alltrim(RetTitle('NT0_CESCR')) + " (NT0_CESCR)" +  STR0099) //O campo "" deve ser preenchido quando o contrato for definitivo
		EndIf
	EndIf

	If lRet
		lRet := JurVldPag(oModel) //ValidaÁ„o de pagadores
	EndIf

	//Verifica o preenchimento do Cliente/Loja/Caso m„e e se ele faz parte da NUT
	If lRet .And. NT0->(ColumnPos( "NT0_CASMAE" )) > 0 .And. oModelNT0:GetValue("NT0_CASMAE") == '1'
		If (Empty(oModelNT0:GetValue("NT0_CCLICM")) .Or. Empty(oModelNT0:GetValue("NT0_CLOJCM")) .Or. Empty(oModelNT0:GetValue("NT0_CCASCM")))
			lRet := .F.
			cLojaAuto := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-N„o)
			// STR0222="Para utilizar o conceito de AlocaÁ„o Unificada/Caso M„e È necess·rio o preenchimento das informaÁıes do Cliente/Caso no Contrato." STR0223="Verifique o preenchimento dos seguintes campos:"
			If cLojaAuto == "2"
				JurMsgErro( STR0222,, STR0223 + CRLF + Alltrim(RetTitle('NT0_CASMAE')) + CRLF + Alltrim(RetTitle('NT0_CCLICM')) + CRLF + Alltrim(RetTitle('NT0_CLOJCM')) + CRLF + Alltrim(RetTitle('NT0_CCASCM ')) )
			Else
				JurMsgErro( STR0222,, STR0223 + CRLF + Alltrim(RetTitle('NT0_CASMAE')) + CRLF + Alltrim(RetTitle('NT0_CCLICM')) + CRLF + Alltrim(RetTitle('NT0_CCASCM ')) )
			EndIf
		Else
			For nI := 1 To nQtdNUT
				oModelNUT:GoLine( nI )
				If !oModelNUT:IsDeleted(nI) .And. (oModelNT0:GetValue("NT0_CCLICM") == oModelNUT:GetValue("NUT_CCLIEN")) .And. (oModelNT0:GetValue("NT0_CLOJCM") == oModelNUT:GetValue("NUT_CLOJA")) ;
				   .And. (oModelNT0:GetValue("NT0_CCASCM") == oModelNUT:GetValue("NUT_CCASO"))
					lCasMaeNUT := .T.
					Exit
				EndIf
			Next nI
			oModelNUT:GoLine( nLinNUT )
			If !lCasMaeNUT
				lRet := JurMsgErro(STR0224,, STR0225) //"Necess·rio que o Caso M„e esteja relacionado a este Contrato!" "Verifique os casos vinculados a este contrato adicionando o caso m„e, ou troque o caso m„e para um vinculado a este contrato."
			EndIf
		EndIf
	EndIf

	If lRet .And. Empty(oModelNT0:GetValue("NT0_DTVIGI")) .And. !Empty(oModelNT0:GetValue("NT0_DTVIGF"))
		lRet := JurMsgErro(STR0228) //'Data inicial de vigÍncia n„o est· preenchida'
	ElseIf lRet .And. !Empty(oModelNT0:GetValue("NT0_DTVIGI")) .And. Empty(oModelNT0:GetValue("NT0_DTVIGF"))
		lRet := oModelNT0:SetValue("NT0_DTVIGF", CToD('31/12/9999'))
	EndIf

	If lRet // Valida SituaÁ„o do Contrato x SituaÁ„o do Cliente/Caso
		lRet := JA096VlSit(oModel)
	EndIf

EndIf

If lRet .And. (oModel:IsFieldUpdated("NT0MASTER", "NT0_TITFAT") .Or. oModel:IsFieldUpdated("NT0MASTER", "NT0_NOME"))
	J96ATUNT5(oModel:GetModel("NT5DETAIL"))
EndIf

If lRet .And. oModel:GetOperation() == OP_INCLUIR
	// Verifica se existe Tipo de Atividade n„o cobr·vel no contrato
	If oModelNTJ:IsEmpty()
		aTpAti := J096QTDE('NUB', '2', oModelNT0:GetValue("NT0_CCLIEN"), oModelNT0:GetValue("NT0_CLOJA"))
		For nI := 1 To Len(aTpAti)
			If oModelNTJ:GetQtdLine() == 1 .And. Empty(oModelNTJ:GetValue("NTJ_CTPATV"))
				oModelNTJ:GoLine( 1 )
			Else
				oModelNTJ:AddLine()
			EndIf
			oModel:SetValue("NTJDETAIL", "NTJ_CTPATV", aTpAti[nI])
		Next

	Else
		aTpAti := J096QTDE('NUB', '2', oModelNT0:GetValue("NT0_CCLIEN"), oModelNT0:GetValue("NT0_CLOJA"))
		For nI := 1 To oModelNTJ:GetQtdLine()
			oModelNTJ:GoLine( nI )
			If !oModelNTJ:IsDeleted( nI )
				aadd(aNTJAti, oModelNTJ:GetValue("NTJ_CTPATV") )
			EndIf
		Next
		aSort(aTpAti)
		aSort(aNTJAti)
		If Len(aTpAti) == Len(aNTJAti)
			For nI := 1 To Len(aTpAti)
				If aTpAti[nI] == aNTJAti[nI]
					nPosAti := 1
				Else
					nPosAti := 0
					Exit
				EndIf
			Next
		Else
			nPosAti := 0
		EndIf
		If nPosAti = 0
			If ApMsgYesNo( STR0104 )  //"O cadastro de tipo de atividade n„o cobr·vel do contrato est· diferente do cadastro de cliente. Deseja atualizar com o cadastro do cliente?"
				For nI := 1 To oModelNTJ:GetQtdLine()
					oModelNTJ:GoLine( nI )
					If !oModelNTJ:IsDeleted( nI )
						oModelNTJ:DeleteLine()
					EndIf
				Next

				For nI := 1 To Len(aTpAti)
					oModelNTJ:AddLine()
					oModel:SetValue("NTJDETAIL", "NTJ_CTPATV", aTpAti[nI])
				Next
			EndIf
		EndIf
		oModelNTJ:GoLine( nLinNTJ )
	EndIf

	// Verifica se existe Tipo de Despesa n„o cobr·vel no contrato
	If oModelNTK:IsEmpty()

		aTpDsp := J096QTDE('NUC', '2', oModelNT0:GetValue("NT0_CCLIEN"), oModelNT0:GetValue("NT0_CLOJA"))
		For nI := 1 To Len(aTpDsp)
			If oModelNTK:GetQtdLine() == 1 .And. Empty(oModelNTK:GetValue("NTK_CTPDSP"))
				oModelNTK:GoLine( 1 )
			Else
				oModelNTK:AddLine()
			EndIf
			oModel:SetValue("NTKDETAIL", "NTK_CTPDSP", aTpDsp[nI])
		Next

	Else
		aTpDsp := J096QTDE('NUC', '2', oModelNT0:GetValue("NT0_CCLIEN"), oModelNT0:GetValue("NT0_CLOJA"))
		For nI := 1 To oModelNTK:GetQtdLine()
			oModelNTK:GoLine( nI )
			If !oModelNTK:IsDeleted( nI )
				aAdd(aNTKDsp, oModelNTK:GetValue("NTK_CTPDSP") )
			EndIf
		Next
		aSort(aTpDsp)
		aSort(aNTKDsp)
		If Len(aTpDsp) == Len(aNTKDsp)
			For nI := 1 To Len(aTpDsp)
				If aTpDsp[nI] == aNTKDsp[nI]
					nPosDsp := 1
				Else
					nPosDsp := 0
					Exit
				EndIf
			Next
		Else
			nPosDsp := 0
		EndIf
		If nPosDsp = 0
			If ApMsgYesNo( STR0105 ) // "O cadastro de tipo de despesa n„o cobr·vel do contrato est· diferente do cadastro de cliente. Deseja atualizar com o cadastro do cliente?"
				For nI := 1 To oModelNTK:GetQtdLine()
					oModelNTK:GoLine( nI )
					If !oModelNTK:IsDeleted( nI )
						oModelNTK:DeleteLine()
					EndIf
				Next

				For nI := 1 To Len(aTpDsp)
					oModelNTK:AddLine()
					oModel:SetValue("NTKDETAIL", "NTK_CTPDSP", aTpDsp[nI])
				Next
			EndIf
		EndIf
		oModelNTK:GoLine( nLinNTK )
	EndIf
EndIf

If lRet .And. !IsInCallStack("JURA070") .And. oModelNT0:GetValue("NT0_ATIVO") == "1"
	cTpHon  := oModelNT0:GetValue("NT0_CTPHON")
	lCobraH := J096CHon(cTpHon) // Indica se o contrato cobra honor·rios
	For nI := 1 To nQtdNUT
		If !oModelNUT:IsDeleted(nI) .And. oModelNUT:IsUpdated(nI)
			oModelNUT:GoLine(nI)
			lRet := J96VldCaso(cTpHon, lCobraH)
			If !lRet
				Exit
			EndIf
		EndIf
	Next
	oModelNUT:GoLine(nLinNUT)
EndIf

If lRet .And. oModel:GetOperation() == OP_ALTERAR

	If J96AltCtr(oModel)

		cQuery := " select distinct NX0.NX0_COD "
		cQuery += " from " + RetSqlName("NX8") + " NX8 "
		cQuery += " Inner Join " + RetSqlName("NX0") + " NX0 "
		cQuery +=         " on( NX0.NX0_FILIAL = '" + xFilial("NX0") + "'"
		cQuery +=             " and NX0.NX0_COD = NX8.NX8_CPREFT "
		cQuery +=             " and NX0.NX0_SITUAC IN ('2','3','4','5','6','7','9','A','B') "
		cQuery +=             " and NX0.D_E_L_E_T_ = ' ') "
		cQuery += " where NX8.NX8_FILIAL = '" + xFilial("NX8") + "' "
		cQuery +=   " and NX8.NX8_CCONTR = '" + cCodCtr + "' "
		cQuery +=   " and NX8.D_E_L_E_T_ = ' ' "
		cQuery +=   " order by NX0.NX0_COD "

		aCodPre := JurSQL(cQuery, "*")
		nLenCod := Len(aCodPre)

		If nLenCod > 0 .And. Empty(_aPreFtVld) .And. !FwIsInCallStack("JA095NCaso") // Se n„o for inclus„o de caso no contrato atravÈs do SIGAJURI
			cMsgErr := STR0151 // "AtenÁ„o: as alteraÁıes feitas n„o refletir„o na(s) prÈ-fatura(s) em aberto: "
			For nFor := 1 To nLenCod
				cMsgErr += aCodPre[nFor][1] + IIf(nFor < nLenCod, ", ", ".")
			Next nFor
			MsgAlert(cMsgErr, STR0150) //"AtenÁ„o"
		EndIf

	EndIf
EndIf

If oModel:GetOperation() == OP_EXCLUIR

	cQuery := "SELECT NW3.NW3_CJCONT FROM " + RetSqlName("NW3") + " NW3 "
	cQuery += " Where NW3.NW3_FILIAL = '" + xFilial("NW3") + "' "
	cQuery += " AND EXISTS (SELECT NT0.R_E_C_N_O_ FROM " + RetSqlName("NT0") + " NT0 "
	cQuery += " WHERE NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "
	cQuery += " AND NT0.D_E_L_E_T_ = ' ' "
	cQuery += " AND NT0.NT0_COD = NW3.NW3_CCONTR "
	cQuery += " AND NW3.NW3_CCONTR = '" + cCodCtr +"') "
	cQuery += " AND NW3.D_E_L_E_T_ = ' ' "

	aQtTD := JurSQL(cQuery, "NW3_CJCONT")

	If Len(aQtTD) > 0
		lRet := JurMsgErro( STR0153 + aQtTD[1][1] + "." ) // "O contrato n„o pode ser excluido pois pertence a junÁ„o "
	EndIf

	If lRet .and. FwAliasInDic('OI4')
		J302Delete( xFilial('OI4'), cCodCtr )
	Endif

EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR96TPHAT
Verifica se o Tipo de honor·rios esta ativo

@author Fabio Crespo Arruda
@since 22/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JUR96TPHAT(oModel)
Local lRet   := .T.
Local aArea  := GetArea()
Local cAtivo := ''

If !Empty( oModel:GetValue('NT0MASTER', 'NT0_CTPHON') )
	cAtivo := JURGETDADOS('NRA', 1, xFilial('NRA') + oModel:GetValue('NT0MASTER', 'NT0_CTPHON'), 'NRA_ATIVO')
	lRet   := cAtivo == '1'
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA96TIT
Preenche o TÌtulo do Contrato do campo de descriÁ„o
Uso Geral.

@Return cRet Retorna o tÌtulo do caso

@author Fabio Crespo ARruda
@since 01/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA96TIT(cCliente, cLoja, cCaso)
Local cRet       := ""

Default cCliente := ""
Default cLoja    := ""
Default cCaso    := ""

If IsInCallStack('JURA096') .Or. IsInCallStack('JURA056') .Or. IsInCallStack('JURA109')
	If !IsInCallStack('JURA096') .Or. NT0->NT0_COD == NUT->NUT_CCONTR
		If _cNumClien == "1"
			IIF(NVE->(IndexOrd()) <> 1, NVE->(DbSetOrder(1)), Nil)
			NVE->(MsSeek(xFilial('NVE') + cCliente + cLoja + cCaso))
		Else
			IIF(NVE->(IndexOrd()) <> 3, NVE->(DbSetOrder(3)), Nil)
			NVE->(MsSeek(xFilial("NVE") + cCaso))
		EndIf
		cRet := NVE->NVE_TITULO
	EndIf
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J96SA1NT0()
CriaÁ„o da validaÁ„o na consulta padr„o de cliente para filtrar de acordo com o
grupo ou de acordo com o cliente do contrato

Uso Geral.
@Return nRet	         	Cliente e Loja
@sample
@author Fabio Crespo ARruda
@since 01/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function J96SA1NT0()
Local oModel := FwModelActive()
Local cRet   := "@#@#"
Local cCampo := AllTrim(ReadVar())

If IsInCallStack('J203FilUsr')
	If !Empty(oGrClien:GetValue())
		cRet := "@#SA1->A1_GRPVEN == '" + oGrClien:GetValue() + "'@#"
	EndIf
Else
	If oModel:GetId() == 'JURA096'
		If !Empty(FwFldGet("NT0_CGRPCL"))
			//cRet := "@#SA1->A1_GRPVEN == '"+oModel:GetValue('NT0MASTER','NT0_CGRPCL')+"'@#"
		Else
			Do Case
				Case "NT0_" $ cCampo
					cRet := "@#@#"
				Case "NUT_" $ cCampo
					cRet := "@#SA1->A1_COD == '" + FwFldGet("NT0_CCLIEN") + "' .And. SA1->A1_LOJA == '" + FwFldGet("NT0_CLOJA") + "'@#"
			End Case
		EndIf
	EndIf
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Jur096VFim
ValidaÁ„o do valor Final no cadastro de faixa de valors do contrato

@Return lRet	.T./.F. As informaÁıes s„o v·lidas ou n„o

@author Claudio Donizete de Souza
@since 01/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function Jur096VFim
Local lRet := M->&("NTR_VLFIM") >= FwFldGet("NTR_VLINI")

	If !lRet
		JurMsgErro(STR0115) //"Valor final deve ser maior ou igual ao valor inicial"
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Jur096VIni
ValidaÁ„o do valor inicial no cadastro de faixa de valors do contrato

@Return lRet  .T./.F. As informaÁıes s„o v·lidas ou n„o

@author Claudio Donizete de Souza
@since 01/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function Jur096VIni
Local lRet := M->&("NTR_VLINI") <= FwFldGet("NTR_VLFIM") .Or. FwFldGet("NTR_VLFIM") == 0

	If !lRet
		JurMsgErro(STR0116) //"Valor inicial deve ser menor ou igual ao valor final"
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA096CMBEF
FunÁıes prÈ-Commit

@Return lRet	.T./.F. As informaÁıes s„o v·lidas ou n„o

@author Evaldo V. Batista
@since 17/11/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA096CMBEF(oModel)
Local aArea      := GetArea()
Local oModelNVN  := oModel:GetModel("NVNDETAIL")
Local nQtdLines  := oModelNVN:GetQtdLine()
Local cContrato  := oModel:GetValue("NT0MASTER", "NT0_COD")
Local cFilAc8    := xFilial('AC8')
Local cFilEnt    := xFilial('NVN')
Local nX         := 0
Local cContato   := ""
Local cCodEnt    := ""
Local lRet       := .T.

If !oModelNVN:IsEmpty()

	For nX := 1 To nQtdLines
		cContato := oModelNVN:GetValue('NVN_CCONT', nX )
		cCodEnt  := oModelNVN:GetValue('NVN_COD'  , nX )
		
		// Relacao de Contatos x Entidade
		AC8->( dbSetOrder( 2 ) ) //AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT+AC8_CODCON
		If AC8->( dbSeek( cFilAc8 + 'NVN' + cFilEnt + PadR(cContrato + cCodEnt, TamSx3('AC8_CODENT')[1] ), .T.) )
			If oModelNVN:IsDeleted( nX )
				RecLock('AC8', .F.)
				AC8->( dbDelete() )
				AC8->( MsUnLock() )
			ElseIf oModelNVN:IsUpdated()
				RecLock('AC8',.F.)
				AC8->AC8_FILIAL := cFilAc8
				AC8->AC8_ENTIDA := 'NVN'
				AC8->AC8_FILENT := cFilEnt
				AC8->AC8_CODENT := PadR(cContrato + cCodEnt, TamSx3('AC8_CODENT')[1] )
				AC8->AC8_CODCON := cContato
				AC8->( MsUnLock() )
			EndIf
		ElseIf !oModelNVN:IsDeleted( nX ) //Gravar Novo
			RecLock('AC8',.T.)
			AC8->AC8_FILIAL := cFilAc8
			AC8->AC8_ENTIDA := 'NVN'
			AC8->AC8_FILENT := cFilEnt
			AC8->AC8_CODENT := PadR(cContrato + cCodEnt, TamSx3('AC8_CODENT')[1] )
			AC8->AC8_CODCON := cContato
			AC8->( MsUnLock() )
		EndIf

	Next nX

EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA096CMAFT
FunÁıes pÛs-Commit

@author Evaldo V. Batista
@since 17/11/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA096CMAFT( oModel )
Local cContrato  := oModel:GetValue("NT0MASTER", "NT0_COD")
Local oModelNUT  := oModel:GetModel("NUTDETAIL")
Local nNUT       := 1
Local aNUT       := {}
Local lRet       := .T.
Local cFilNVE    := xFilial("NVE")
Local nX         := 0
Local cMsgSitCas := ""
Local aCasosAlt  := {}

If Len(_aSitCasos) == 2

	cMsgSitCas := _aSitCasos[1] // Mensagem com os casos que ser„o e os que n„o ser„o alterados
	aCasosAlt  := _aSitCasos[2] // Vetor com dados dos casos que ter„o a situaÁ„o alterada

	If !Empty(cMsgSitCas)
		JurErrLog(cMsgSitCas, STR0150) // "AtenÁ„o"
	EndIf

	If !Empty(aCasosAlt)
		NVE->(DbSetOrder(1)) // NVE_FILIAL + NVE_CCLIEN + NVE_LCLIEN + NVE_NUMCAS + NVE_SITUAC
		
		For nX := 1 To Len(aCasosAlt)
			If NVE->(DbSeek(xFilial("NVE") + aCasosAlt[nX][1] + aCasosAlt[nX][2] + aCasosAlt[nX][3]))
				RecLock("NVE", .F.)
				NVE->NVE_SITCAD := "2"
				NVE->(MsUnLock())
				J170GRAVA("NVE", cFilNVE + NVE->NVE_CCLIEN + NVE->NVE_LCLIEN + NVE->NVE_NUMCAS, "4")
			EndIf
		Next nX
	EndIf

	JurFreeArr(@aCasosAlt)
	JurFreeArr(@_aSitCasos)

EndIf

If !oModel:GetOperation() == OP_INCLUIR

	NT0->( DbSetOrder(1) ) // recolocado pois estava desposicionando no commit da alteraÁ„o
	NT0->( DbSeek( xFilial('NT0') + cContrato ) )

	If oModel:GetOperation() == 4
		If oModel:IsFieldUpdated("NT0MASTER", "NT0_DESPAD") .Or. oModel:IsFieldUpdated("NT0MASTER", "NT0_TPERCD")
			lRet := J096DesCs(oModel)

		ElseIf !Empty(oModel:GetValue("NT0MASTER", "NT0_DESPAD"))
			For nNUT := 1 To oModelNUT:GetQtdLine()
				If !oModelNUT:IsDeleted(nNUT) .And. (oModelNUT:IsInserted(nNUT) .Or. oModelNUT:IsUpdated(nNUT))
					aAdd(aNUT, nNUT)
				EndIf
			Next nNUT

			If !Empty(aNUT)
				lRet := J096DesCs(oModel, aNUT)
			EndIf

		EndIf
	EndIf

	If !lRet
		JurMsgErro( STR0134 ) //"N„o foi possivel alterar o desconto em pelo menos um dos casos do contrato!"
	EndIf

Else

	NT0->( DbSetOrder(1) ) // recolocado pois estava deposicionando no commit da alteraÁ„o
	NT0->( DbSeek( xFilial('NT0') + cContrato ) )

	If lRet .And. oModel:GetOperation() != 5
		If !Empty(oModel:GetValue("NT0MASTER", "NT0_DESPAD"))
			lRet := J096DesCs(oModel)
		EndIf
	EndIf

	If !lRet
		JurMsgErro( STR0134 ) //"N„o foi possivel alterar o desconto em pelo menos um dos casos do contrato!"
	EndIf

EndIf

If lRet
	J096CPYCnt( oModel ) //atualiza o conteudo do array _aCnt096
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J96SA1NT0V
Validacao da amarraÁ„o de clientes e casos x contrato.

@author Evaldo V. Batista
@since 17/11/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Function J96SA1NT0V()
Local lRet    := .T.
Local oModel  := FwModelActive()
Local cGrupo  := ""
Local cClien  := ""
Local cLoja   := ""

If IsInCallStack( 'JURA096' )

	cGrupo := oModel:GetValue("NT0MASTER", "NT0_CGRPCL")
	cClien := oModel:GetValue("NT0MASTER", "NT0_CCLIEN")
	cLoja  := oModel:GetValue("NT0MASTER", "NT0_CLOJA")

	// Para o cÛdigo do cliente
	If __ReadVar $ "M->NT0_CCLIEN"
		lRet := JurVldCli(cGrupo, cClien, cLoja,,, "CLI")

	//<-Para validar se a sigla do revisor n„o esta bloqueada e se a mesma È v·lida ->
	//<- FindFunction("J33RgBloq") --> Verifica se a funÁ„o esta presente no RPO para evidar erroLog ->
	ElseIf __ReadVar $ "M->NT0_SIGLA1" .And. FindFunction("J33RgBloq")
		// Valida se o registro esta bloqueado atraves de ???_MSBLQL
		If !J33RgBloq('NT0_SIGLA1', 9)
			lRet := .F.
		EndIf

	// Para o cÛdigo do grupo do cliente
	ElseIf __ReadVar $ "M->NT0_CGRPCL"
		lRet := JurVldCli(cGrupo, cClien, cLoja,,, "GRP")

	ElseIf lRet .And. __ReadVar $ "M->NT0_CCLIEN|M->NT0_CLOJA"
		lRet := JurVldCli(cGrupo, cClien, cLoja,,, "LOJ")
		
		If lRet .And. !Empty(cClien) .And. !Empty(cLoja)
			J096SUGVIC()
		EndIf
	EndIf

EndIf

If __ReadVar $ "M->NXP_CLIPG"
	If !Empty(FwFldGet("NXP_CLIPG")) .And. Empty(FwFldGet("NXP_LOJAPG"))
		lRet := ExistCpo('SA1', FwFldGet("NXP_CLIPG"))
	EndIf

ElseIf __ReadVar $ "M->NXP_LOJAPG"
	If !Empty(FwFldGet("NXP_CLIPG")) .And. !Empty(FwFldGet("NXP_LOJAPG"))
		lRet := ExistCpo( "SA1", FwFldGet("NXP_CLIPG") + FwFldGet("NXP_LOJAPG"), 1 )
		If lRet
			If Empty(JurGetDados('NUH', 1, xFilial('NUH') + FwFldGet("NXP_CLIPG") + FwFldGet("NXP_LOJAPG"), 'NUH_COD'))
				lRet := JurMsgErro(STR0092) // "O Cliente/Loja inv·lido"
			EndIf
		EndIf
	EndIf

ElseIf __ReadVar $ "M->NXG_CLIPG"
	If !Empty(FwFldGet("NXG_CLIPG")) .And. Empty(FwFldGet("NXG_LOJAPG"))
		lRet := ExistCpo('SA1', FwFldGet("NXG_CLIPG"))
	EndIf

ElseIf __ReadVar $ "M->NXG_LOJAPG"
	If !Empty(FwFldGet("NXG_CLIPG")) .And. !Empty(FwFldGet("NXG_LOJAPG"))
		lRet := ExistCpo( "SA1", FwFldGet("NXG_CLIPG") + FwFldGet("NXG_LOJAPG"), 1 )
		If lRet
			If Empty(JurGetDados('NUH', 1, xFilial('NUH') + FwFldGet("NXG_CLIPG") + FwFldGet("NXG_LOJAPG"), 'NUH_COD'))
				lRet := JurMsgErro(STR0092) // "O Cliente/Loja inv·lido"
			EndIf
		EndIf
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J96VldCaso
FunÁ„o utilizada para validar o caso da tabela NUT

@param cTpHon , Tipo de honor·rio
@param lCobraH, Indica se o tipo de honor·rio cobra hora

@Return lRet   .T./.F. As informaÁıes s„o v·lidas ou n„o

@author Felipe Bonvicini Conti
@since  02/02/10
/*/
//-------------------------------------------------------------------
Function J96VldCaso(cTpHon, lCobraH)
Local lRet      := .T.
Local oModel    := FwModelActive()
Local oModelNUT := Nil
Local oModelNT0 := Nil
Local aArea     := GetArea()
Local aAreaNVE  := NVE->( GetArea() )
Local cCobravel := ""
Local cClient   := ""
Local cLoja     := ""
Local cContr    := ""
Local dDtVigI   := ""
Local dDtVigF   := ""
Local cAtivo    := ""
Local aCliLoj   := {}
Local cCaso     := ""

Default cTpHon  := ""
Default lCobraH := .F.

Chkfile('NVE')

If oModel:GetId() == 'JURA096'
	oModelNUT := oModel:GetModel('NUTDETAIL')

	If !Empty(oModelNUT:GetValue('NUT_CCASO'))

		If _cNumClien == "1"
			If Empty(oModelNUT:GetValue('NUT_CCLIEN')) .Or. Empty(oModelNUT:GetValue('NUT_CLOJA'))
				lRet := .F.
			Else
				cClient := oModelNUT:GetValue('NUT_CCLIEN')
				cLoja   := oModelNUT:GetValue('NUT_CLOJA')
				cCaso   := oModelNUT:GetValue('NUT_CCASO')

				NVE->(DbSetOrder(1)) // NVE_FILIAL+NVE_CCLIEN+NVE_LCLIEN+NVE_NUMCAS+NVE_SITUAC
				If NVE->(DbSeek(xFilial("NVE") + cClient + cLoja + cCaso))
					cCobravel := NVE->NVE_COBRAV
				Else
					lRet := JurMsgErro(STR0196) //"Cliente, loja e caso inv·lidos."
				EndIf
			EndIf

		ElseIf _cNumClien == "2"
			cCaso   := oModelNUT:GetValue('NUT_CCASO')

			NVE->(dbSetOrder(3)) //NVE_FILIAL+NVE_NUMCAS+NVE_SITUAC
			If NVE->(dbSeek(xFilial('NVE') + cCaso))
				cCobravel := NVE->NVE_COBRAV
				aCliLoj   := JCasoAtual(cCaso)
				If !Empty(aCliLoj)
					cClient := aCliLoj[1][1]
					cLoja   := aCliLoj[1][2]
				EndIf
			Else
				lRet := JurMsgErro(STR0197) //"Caso inv·lido."
			EndIf
		EndIf

		If lRet .And. cCobravel == "1"
			oModelNT0 := oModel:GetModel('NT0MASTER')
			cContr    := oModelNT0:GetValue("NT0_COD")
			cAtivo    := oModelNT0:GetValue("NT0_ATIVO")
			dDtVigI   := oModelNT0:GetValue("NT0_DTVIGI")
			dDtVigF   := oModelNT0:GetValue("NT0_DTVIGF")

			If oModel:GetOperation() <> OP_EXCLUIR
				If Empty(cTpHon) // cTpHon vem vazio quando a funÁ„o È chamada pelo Valid do campo NUT_CCASO
					cTpHon  := oModelNT0:GetValue("NT0_CTPHON")
					lCobraH := J096CHon(cTpHon) // Indica se o tipo de honor·rio cobra hora
				EndIf

				If lCobraH .And. cAtivo == "1"
					lRet := J096VlTpHo(oModel, cCaso, cContr, cClient, cLoja, cTpHon, dDtVigI, dDtVigF)
				EndIf

				If lRet
					lRet := J096VDespTab(cClient, cLoja, cCaso, cContr, cAtivo, dDtVigI, dDtVigF)
				EndIf
			EndIf

		EndIf

	EndIf

EndIf

RestArea(aAreaNVE)
RestArea(aArea)

Return lRet

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥J096VTpHon∫Autor  ≥Evaldo V. Batista   ∫ Data ≥  20/11/2009 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥-Funcao para validar os tipos de honorarios ja informados e ∫±±
±±∫          ≥apagar as informacoes geradas pelo usuario caso ele mude o  ∫±±
±±∫          ≥tipo de honorario                                           ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function J096VTpHon()
Local lRet        := .T.
Local nA          := 0
Local oModel      := FwModelActive()
Local oModelNT0   := oModel:GetModel('NT0MASTER')
Local oModelNT1   := oModel:GetModel('NT1DETAIL')
Local oModelNTR   := oModel:GetModel('NTRDETAIL')
Local cTipHon     := oModelNT0:GetValue('NT0_CTPHON')
Local cCodCtr     := oModelNT0:GetValue('NT0_COD') // Codigo do contrato
Local cOldTipHon  := JurGetDados('NT0', 1, xFilial('NT0') + cCodCtr, 'NT0_CTPHON')
Local nQtdLine    := oModelNT1:GetQtdLine()
Local nLineActive := 0
Local nSavNT1     := 0
Local nSavNTR     := 0
Local cParcela    := ""
Local cPreFat     := ""
Local cSituacao   := ""
Local cParcMsg    := ""
Local cParcBlq    := ""
Local cMsgErro    := ""

cUser := '2'

If !oModelNT1:IsEmpty()

	J096SetNo(oModelNT1, .F.)
	nSavNT1 := oModelNT1:GetLine()
	For nA := 1 To nQtdLine
		oModelNT1:GoLine(nA)
		If !oModelNT1:IsDeleted(nA)
			nLineActive++
			If Empty(oModelNT1:GetValue("NT1_SEQUEN"))
				oModelNT1:SetValue(JurGetNum("NT1", "NT1_SEQUEN"))
			EndIf

			cParcela := oModelNT1:GetValue("NT1_PARC")
			cPreFat  := oModelNT1:GetValue('NT1_CPREFT')
			If !Empty(cPreFat)
				cSituacao := JurGetDados("NX0", 1, xFilial("NX0") + cPreFat, "NX0_SITUAC")
				If cSituacao $ "2|3|D|E" // SituaÁıes que permitem cancelamento
					cParcMsg += IIf(Empty(cParcMsg), cParcela, ", " + cParcela)
					AAdd(_aPreFtVld, cPreFat)
				ElseIf cSituacao $ "4|5|6|7|9|A|B|C|F" // SituaÁıes que N√O permitem cancelamento
					cParcBlq += IIf(Empty(cParcBlq), cParcela, ", " + cParcela)
				EndIf
			EndIf
		EndIf
	Next nA

	If !Empty(cParcBlq)
		_aPreFtVld := {} // Limpa o array pois n„o permitir· a alteraÁ„o do tipo do honor·rio
		lRet := JurMsgErro(I18N(STR0248, {cParcBlq}),, STR0249) // "N„o È possÌvel alterar o tipo de honor·rio, pois a(s) parcela(s) '#1' est„o vinculadas a prÈ-fatura(s) que n„o permitem cancelamento e n„o ser„o alterada(s)!" - "Cancele a(s) prÈ-fatura(s) para realizar a alteraÁ„o do tipo de honor·rio."
	EndIf

	If lRet
		If JUR96TPFIX(cOldTipHon) .Or. JUR96TPFIX(cTipHon)
			If nLineActive > 0
				If Empty(cParcMsg)
					lRet := ApMsgYesNo( STR0036 + CRLF + STR0037, STR0038 ) // "Esta operaÁ„o ira excluir todas as parcelas pendentes do formul·rio de parcelas,"###" confirma a exclus„o das parcelas geradas e/ou digitadas?"###"Exclus„o Autom·tica"
					cMsgErro := STR0072 // "Para alterar o tipo de honor·rios as parcelas pendentes devem ser excluÌdas."
				Else
					lRet := ApMsgYesNo( I18N(STR0250, {cParcMsg}) + CRLF + STR0251 , STR0038) // "A(s) parcela(s) '#1' est„o vinculadas a prÈ-faturas. Esta operaÁ„o ir· excluir todas as parcelas pendentes e cancelar as prÈ-faturas." - "Confirma a exclus„o das parcelas geradas e/ou digitadas e o cancelamento das prÈ-faturas?" - "Exclus„o Autom·tica"
					cMsgErro := STR0252 // "Para alterar o tipo de honor·rios as parcelas devem ser excluÌdas e as prÈ-faturas canceladas."
				EndIf
			EndIf
			If lRet
				For nA := 1 To nQtdLine
					oModelNT1:GoLine( nA )
					If !oModelNT1:IsDeleted( nA ) .And. ((oModelNT1:GetValue("NT1_SITUAC") == '1') .Or. Empty(oModelNT1:GetValue("NT1_SITUAC")))
						If !oModelNT1:CanDeleteLine()
							oModelNT1:SetNoDeleteLine(.F.)
							oModelNT1:DeleteLine()
							oModelNT1:SetNoDeleteLine(.T.)
						Else
							oModelNT1:DeleteLine()
						EndIf
					EndIf
				Next nA
			Else
				JurMsgErro(STR0253,, cMsgErro) // "N„o È possÌvel alterar o tipo de honor·rios."
			EndIf
		EndIf

		If J96TPHPAut(cTipHon)
			J096SetNo(oModelNT1, .T.)
		EndIf
	EndIf
	oModelNT1:Goline(nSavNT1)
EndIf

If lRet

	nLineActive := 0
	nQtdLine    := oModelNTR:GetQtdLine()
	nSavNTR     := oModelNTR:GetLine()

	If !oModelNTR:IsEmpty()

		For nA := 1 To nQtdLine
			If !oModelNTR:IsDeleted( nA ) .And. !Empty( oModelNTR:GetValue("NTR_VLFIM") )
				nLineActive++
			EndIf
		Next nA

		If nLineActive > 0
			lRet := ApMsgYesNo( STR0070 + CRLF + STR0071, STR0038 )  //"Esta operaÁ„o ira excluir todas as Faixas de faturamento do formul·rio de faixas,"###" confirma a exclus„o das Faixas?"###"Exclus„o Autom·tica"
		EndIf
		If lRet
			For nA := 1 To nQtdLine
				oModelNTR:GoLine( nA )
				If !oModelNTR:IsDeleted( nA )
					If JUR96FAIXA(cTipHon )
						oModelNTR:SetValue( 'NTR_VLINI', Int( oModelNTR:GetValue( 'NTR_VLINI' ) ) )
						oModelNTR:SetValue( 'NTR_VLFIM', Int( oModelNTR:GetValue( 'NTR_VLFIM' ) ) )
					EndIf
					oModelNTR:DeleteLine()
				EndIf
			Next nA
		Else
			JurMsgErro(STR0073)
		EndIf

		oModelNTR:GoLine(nSavNTR)
	EndIf
EndIf

cUser := '1'

If lRet
	If JUR96TPHAT(oModel)
		JUR096CPO()
	Else
		lRet := .F.
	EndIf
EndIf

Return lRet

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥J096VldDef∫Autor  ≥Evaldo V. Batista   ∫ Data ≥  25/11/2009 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥-Funcao validar a situacao do contrato, se o tipo de        ∫±±
±±∫          ≥Contrato for definitivo o principal cliente do contrato     ∫±±
±±∫          ≥tambem deve ser definitivo                                  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function J096VldDef(cCodCli, cLojCli, cTipSit)
Local lRet      := .T.
Local aArea     := GetArea()
Local oModel    := FwModelActive()

Default cTipSit := FwFldGet('NT0_SIT')
Default cCodCli := FwFldGet('NT0_CCLIEN')
Default cLojCli := FwFldGet('NT0_CLOJA')

	If oModel:GetOperation() == OP_INCLUIR .Or. oModel:GetOperation() == OP_ALTERAR

		NUH->( dbSetOrder( 1 ) ) //NUH_FILIAL+NUH_COD+NUH_LOJA
		If NUH->( dbSeek( xFilial('NUH') + cCodCli + cLojCli, .F. ) )
			If NUH->NUH_SITCAD == '1' // ProvisÛrio
				If cTipSit == '2' // Definitivo
					lRet := JurMsgErro(STR0042,, STR0043) // "N„o È permitido alterar a situaÁ„o do contrato, pois o cliente È provisÛrio." # "Ajuste a situaÁ„o do cadastro no cliente para definitivo ou mantenha o contrato como provisÛrio."
				EndIf
			EndIf
		Else
			lRet := JurMsgErro(STR0044,, STR0045) // "Cadastro do cliente incompleto!" # "Preencha os dados complementares no cadastro do cliente."
		EndIf

	EndIf

RestArea(aArea)

Return( lRet )

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥J096VldDes∫Autor  ≥Evaldo V. Batista   ∫ Data ≥  26/11/2009 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥-Valida se o tipo de despesa nao cobravel esta ativa ou nao ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function J096VldDes(cCodDesp)
Local lRet       := .T.
Local aArea      := GetArea()

Default cCodDesp := FwFldGet('NTK_CTPDSP')

NRH->( dbSetOrder( 1 ) ) //NRH_FILIAL+NRH_COD
If NRH->( dbSeek( xFilial('NRH') + cCodDesp, .F. ) )
	If !NRH->NRH_ATIVO == '1'
		lRet := JurMsgErro( STR0046 ) //'Esta despesa n„o pode ser utilizada pois est· desabilitada'
	EndIf
Else
	lRet := JurMsgErro( STR0047 ) //'Despesa N„o Cadastrada...'
EndIf

RestArea(aArea)

Return( lRet )

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥J096VldAtv∫Autor  ≥Evaldo V. Batista   ∫ Data ≥  26/11/2009 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥-Valida se o tipo de atividade e cobravel                   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function J096VldAtv(cCodAtv)
Local lRet      := .T.
Local aArea     := GetArea()

Default cCodAtv := FwFldGet('NTJ_CTPATV')

NRC->( dbSetOrder( 1 ) )
If NRC->( dbSeek( xFilial('NRC') + cCodAtv, .F. ) )
	If NRC->NRC_ATIVO ==  "2"
		lRet := JurMsgErro( STR0124 ) // "Atividade inativa"
	EndIf
Else
	lRet := JurMsgErro( STR0049 ) // "Atividade N„o Cadastrada"
EndIf

RestArea(aArea)

Return( lRet )

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥J096VldRel∫Autor  ≥Evaldo V. Batista   ∫ Data ≥  26/11/2009 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥-Validacao para impedir que seja informado um relatorio     ∫±±
±±∫          ≥ desabilitado para este usuario                             ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function J096VldRel(cTabela)
Local lRet    := .T.
Local aArea   := GetArea()
Local cCodRel := ""
Local cCodCli := ""
Local cLojCli := ""

	Do Case
	Case cTabela == "NXA"
		cCodRel := FwFldGet('NXA_TPREL')
		cCodCli := FwFldGet('NXA_CCLIEN')
		cLojCli := FwFldGet('NXA_CLOJA')
	Case cTabela == "NXG"
		cCodRel := FwFldGet('NXG_CRELAT')
		cCodCli := FwFldGet('NXG_CLIPG')
		cLojCli := FwFldGet('NXG_LOJAPG')
	Case cTabela == "NXP"
		cCodRel := FwFldGet('NXP_CRELAT')
		cCodCli := FwFldGet('NXP_CLIPG')
		cLojCli := FwFldGet('NXP_LOJAPG')
	End Case

	NUA->( dbSetOrder( 1 ) ) //NUA_FILIAL+NUA_CCLIEN+NUA_CLOJA+NUA_CTPREL
	If NUA->( dbSeek( xFilial('NUA') + cCodCli + cLojCli + cCodRel ) )
		lRet := JurMsgErro( STR0050 ) //'Este RelatÛrio est· desabilitado para este cliente, informe um relatÛrio que n„o esteja desabilitado'
	EndIf

	NRJ->( dbSetOrder( 1 ) ) //NRJ_FILIAL+NRJ_COD
	If NRJ->( dbSeek( xFilial('NRJ') + cCodRel ) )
		If NRJ->NRJ_ATIVO == "2"
			lRet := JurMsgErro( STR0125 ) //"Este RelatÛrio est· inativo, informe um relatÛrio que esteja ativo!"
		EndIf
	EndIf

	RestArea(aArea)

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} J096FilRel
Filtro para n„o permitir exibir relatorios que estejam desabilitados 
para o cliente do contrato.

@param cCodRel, CÛdigo do Tipo de RelatÛrio
@param cCodRel, CÛdigo do Tipo de RelatÛrio
@param cCodRel, CÛdigo do Tipo de RelatÛrio

@obs   Utilizado na consulta padr„o NRJCTR

@author Evaldo V. Batista
@since  26/11/2009
/*/
//-------------------------------------------------------------------
Function J096FilRel(cCodRel, cCodCli, cLojCli)
Local lRet      := .T.
Local aArea     := GetArea()

Default cCodRel := NRJ->NRJ_COD

If IsInCallStack("JURA202") .Or. IsInCallStack("JURA033") .Or. IsInCallStack("JURA203")
	Default cCodCli := FwFldGet('NXG_CLIPG')
	Default cLojCli := FwFldGet('NXG_LOJAPG')
ElseIf IsInCallStack("JURA204")
	Default cCodCli := FwFldGet('NXA_CLIPG')
	Default cLojCli := FwFldGet('NXA_LOJPG')
Else
	Default cCodCli := FwFldGet('NXP_CLIPG')
	Default cLojCli := FwFldGet('NXP_LOJAPG')
EndIf

NUA->( dbSetOrder( 1 ) ) //NUA_FILIAL+NUA_CCLIEN+NUA_CLOJA+NUA_CTPREL
If NUA->( dbSeek( xFilial('NUA') + cCodCli + cLojCli + cCodRel ) )
	lRet := .F.
EndIf

RestArea(aArea)

Return ( lRet )

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥j096WhenCs∫Autor  ≥Evaldo V. Batista   ∫ Data ≥  26/11/2009 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥-Permite a digitacao ou nao do campo de caso de acordo com  ∫±±
±±∫          ≥o paramatro MV_JCASO1                                       ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function J096WhenCs(cCodCli, cLojCli, cCodCaso)
Local lRet     := .T.
Local cMvJCaso := GetMv('MV_JCASO1', .F., '1') //Determina se o caso È por cliente (1) ou independente de cliente (2)

If 'JURA096' $ Upper( FunName() )

	Default cCodCli  := FwFldGet('NUT_CCLIEN')
	Default cLojCli  := FwFldGet('NUT_CLOJA')
	Default cCodCaso := FwFldGet('NUT_CCASO')

	If cMvJCaso == '1' .And. ( Empty(cCodCli) .Or. Empty(cLojCli) )
		lRet := .F.
	EndIf

EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} J096VlTpHo()
ValidaÁ„o de Caso x Tipo de honor·rio

Impede que seja informado casos amarrados a contratos de cobranca por 
hora em outro contrato com cobranca por hora

@param oModel  , Modelo de dados de Contratos
@param cCodCaso, CÛdigo do Caso
@param cContr  , CÛdigo do Contrato
@param cCodCli , CÛdigo do Cliente
@param cLojCli , Loja do Cliente
@param cTipHon , CÛdigo do Tipo de honor·rio
@param dDtVigI , Data Inicial da vigÍncia
@param dDtVigF , Data Final da vigÍncia

@return lRet   , Indica se o caso pode ser adicionado ao contrato

@author Evaldo V. Batista
@since  30/11/2009
/*/
//-------------------------------------------------------------------
Static Function J096VlTpHo(oModel, cCodCaso, cContr, cCodCli, cLojCli, cTipHon, dDtVigI, dDtVigF)
Local aArea     := GetArea()
Local cAlias    := Nil
Local lRet      := .T.
Local cQuery    := ''
Local cMsgErr   := ''
Local cMsgSol   := ''
Local cErroVig  := ''

Default cTipHon := oModel:GetModel('NT0MASTER'):GetValue("NT0_CTPHON")
Default dDtVigI := CToD( '  /  /  ' )
Default dDtVigF := CToD( '  /  /  ' )

	cQuery := " SELECT NT0.NT0_COD, NUT.NUT_CCASO, NT0_DTVIGI, NT0_DTVIGF"
	cQuery +=   " FROM " + RetSqlName('NUT') + " NUT "
	cQuery +=  " INNER JOIN " + RetSqlName('NT0') + " NT0 "
	cQuery +=     " ON NT0.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND NT0.NT0_FILIAL = '" + xFilial('NT0') + "' "
	cQuery +=    " AND NT0.NT0_COD = NUT.NUT_CCONTR "
	cQuery +=    " AND NT0.NT0_COD <> '" + cContr + "' "
	cQuery +=    " AND NT0.NT0_ATIVO = '1' "
	cQuery +=  " INNER JOIN " + RetSqlName('NRA') + " NRA "
	cQuery +=     " ON NRA.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND NRA.NRA_FILIAL = '" + xFilial('NRA') + "' "
	cQuery +=    " AND NRA.NRA_COD    = NT0_CTPHON "
	cQuery +=    " AND NRA.NRA_COBRAH = '1' "
	cQuery +=  " WHERE NUT.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND NUT.NUT_FILIAL = '" + xFilial('NUT') + "' "
	cQuery +=    " AND NUT.NUT_CCLIEN = '" + cCodCli  + "' "
	cQuery +=    " AND NUT.NUT_CLOJA  = '" + cLojCli  + "' "
	cQuery +=    " AND NUT.NUT_CCASO  = '" + cCodCaso + "' "

	cAlias := GetNextAlias()
	dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQuery), cAlias, .T., .T. )

	While !(cAlias)->( Eof() )

		cErroVig := J096VldPer(cAlias, dDtVigI, dDtVigF)

		If !Empty(cErroVig)
			lRet    := .F.
			cMsgErr := cErroVig
			cMsgSol := (STR0230) //'Verifique o perÌodo de vigÍncia no contrato.'
		ElseIf Empty(dDtVigI) .And. Empty(dDtVigF)
			lRet    := .F.
			cMsgErr := STR0060 + AllTrim(cCodCaso) + STR0061 + AllTrim(cContr) + STR0062 + CRLF + STR0063 + cMsgErr  //'O caso '###' n„o pode ser vinculado ao contrato '###' porque j· faz parte de outros(s) contrato(s) com faturamento por Hora! '###'Contrato(s) Vinculado(s) ao caso: '
			cMsgSol := STR0231 // 'Verifique o perÌodo de vigÍncia no contrato.'
		EndIf

		If !lRet
			JurMsgErro( cMsgErr, 'J096VlTpHo', cMsgSol )
			Exit
		EndIf

		(cAlias)->( dbSkip() )
	EndDo
	(cAlias)->( dbCloseArea() )

	RestArea( aArea )

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} J096VDespTab
FunÁ„o utilizada para validar se o caso j· esta associado a algum
 outro contrato que cobre Despesa ou Tabelado

@Return lRet	 	.T./.F. As informaÁıes s„o v·lidas ou n„o

@author Felipe Bonvicini Conti
@since 01/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096VDespTab(cCliente, cLoja, cCaso, cContrato, cAtivo, dDtVigI, dDtVigF)
Local aArea     := GetArea()
Local cAlias    := ""
Local cQuery    := ""
Local cErroVig  := ""
Local oModel    := FwModelActive()
Local oModelNT0 := oModel:GetModel('NT0MASTER')
Local cCobTab   := oModelNT0:GetValue("NT0_SERTAB")
Local cCobDes   := oModelNT0:GetValue("NT0_DESPES")
Local lRet      := .T.

Default dDtVigI := CToD( '  /  /  ' )
Default dDtVigF := CToD( '  /  /  ' )

If cAtivo == '1' .And. (cCobTab == '1' .Or. cCobDes == '1')
	cQuery := "SELECT NT0.NT0_COD, NUT.NUT_CCASO, NT0.NT0_DESPES, NT0.NT0_SERTAB, NT0_DTVIGI, NT0_DTVIGF"
	cQuery += " FROM "+RetSqlName('NUT')+" NUT "
	cQuery += " INNER JOIN "+RetSqlName('NT0')+" NT0 "
	cQuery +=    " ON NT0.NT0_FILIAL = '"+xFilial('NT0')+"' "
	cQuery +=    " AND NT0.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND NT0.NT0_COD = NUT.NUT_CCONTR "
	cQuery +=    " AND NT0.NT0_COD <> '"+cContrato+"' "
	cQuery +=    " AND NT0.NT0_ATIVO = '1' "

	If cCobTab == '1' .And. cCobDes == '1'
		cQuery += " AND (NT0.NT0_SERTAB = '1' OR NT0.NT0_DESPES = '1') "
	ElseIf cCobTab == '1' .And. cCobDes == '2'
		cQuery += " AND NT0.NT0_SERTAB = '1' "
	ElseIf cCobTab == '2' .And. cCobDes == '1'
		cQuery += " AND NT0.NT0_DESPES = '1' "
	EndIf
	cQuery += " WHERE NUT.NUT_FILIAL = '"+xFilial('NUT')+"' "
	cQuery +=    " AND NUT.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND NUT.NUT_CCLIEN = '"+cCliente+"' "
	cQuery +=    " AND NUT.NUT_CLOJA = '"+cLoja+"' "
	cQuery +=    " AND NUT.NUT_CCASO = '"+cCaso+"' "

	cAlias := GetNextAlias()
	dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQuery), cAlias, .T., .T. )
	
	While !(cAlias)->( Eof() )

		cErroVig := J096VldPer(cAlias, dDtVigI, dDtVigF)

		If (cAlias)->NT0_SERTAB == "1" .And. cCobTab == "1"
			If !Empty(cErroVig)
				lRet := .F.
				cMsgSol := STR0230 //'Verifique o perÌodo de vigÍncia no contrato.'
			ElseIf Empty(dDtVigI) .And. Empty(dDtVigF)
				lRet := .F.
				cErroVig := STR0060+AllTrim(cCaso)+STR0061+AllTrim(cContrato)+STR0076+CRLF+STR0063+(cAlias)->NT0_COD //'O caso '###' n„o pode ser vinculado ao contrato '###' porque j· faz parte de outros(s) contrato(s) quem cobrem despesa! '###'Contrato(s) Vinculado(s) ao caso: '
				cMsgSol := STR0231 // "Verifique a forma de cobranÁa do contrato."
			EndIf
		EndIf

		If (cAlias)->NT0_DESPES == "1" .And. cCobDes == "1"
			If !Empty(cErroVig)
				lRet := .F.
				cMsgSol := STR0230 // 'Verifique o perÌodo de vigÍncia no contrato.'
			ElseIf Empty(dDtVigI) .And. Empty(dDtVigF)
				lRet := .F.
				cErroVig := STR0060+AllTrim(cCaso)+STR0061+AllTrim(cContrato)+STR0075+CRLF+STR0063+(cAlias)->NT0_COD //'O caso '###' n„o pode ser vinculado ao contrato 	'###' porque j· faz parte de outros(s) contrato(s) quem cobrem tabelado! '###'Contrato(s) Vinculado(s) ao caso: '
				cMsgSol  := STR0231 // "Verifique a forma de cobranÁa do contrato."
			EndIf
		EndIf

		If !lRet
			Exit
		EndIf

		(cAlias)->( dbSkip() )

	EndDo
	(cAlias)->( dbCloseArea() )

	If !lRet .And. !Empty(cErroVig) .And. !Empty(cMsgSol)
		JurMsgErro(cErroVig, 'J096VDespTab', cMsgSol)
	EndIf

EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J96TPHPAut
FunÁ„o utilizada para verificar se o tipo de honor·rios gera parcelas autom·ticas

@Return lRet	 	.T./.F. As informaÁıes s„o v·lidas ou n„o

@author Felipe Bonvicini Conti
@since 19/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function J96TPHPAut(cTpHonor)
Local lRet   := .F.
Local aArea  := GetArea()

Default cTpHonor := FwFldGet('NT0_CTPHON')

lRet := JurGetDados('NRA', 1, xFilial('NRA') + cTpHonor, 'NRA_PARCAT') == "1"

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J96CalcCDF
FunÁ„o utilizada para calcular o valor base da parcela fixa quando o
tipo de faixa de faturamento for Quantidade de Casos (Partido, OcorrÍncia e
PrÈ-definido).
Usada tambÈm na JURA203C para rec·lculo do valor base no momento da inserÁ„o
da parcela fixa na fila de emiss„o.

@Return nValor	 	Valor atualizado da parcela

@author Felipe Bonvicini Conti
@since  19/02/10
@obs    FunÁ„o tambÈm Chamada no Gatilho (SX7) do campo NT1_QTDADE
/*/
//-------------------------------------------------------------------
Function J96CalcCDF(oModel, cSequen)
Local oModelNT0   := Nil
Local oModelNUT   := Nil
Local oModelNT1   := Nil
Local oModelNTR   := Nil
Local nQtdNTR     := Nil
Local nQtdNUT     := Nil
Local nLnOldNT1   := Nil
Local nQtdLnNUT   := Nil
Local nLnOldNUT   := Nil
Local nLnOldNTR   := Nil
Local oStructNT1  := Nil
Local nValor      := 0
Local nDif        := 0
Local nI          := 0
Local nQtdCasPro  := 0
Local nQtdNT1     := 0
Local aValores    := {}
Local cNT1Descri  := ""
Local lCanDelNT1  := Nil
Local lCanUptNT1  := Nil
Local lCanInsNT1  := Nil
Local cQtdCsAut   := SuperGetMV("MV_JQTDAUT",, "1") // Indica se a quantidade de casos / processos ser· indicada na parcela de forma autom·tica (1) ou manual (2)

Default oModel    := FWModelActive()
Default cSequen   := ""

oModelNT0   := oModel:GetModel('NT0MASTER')
oModelNUT   := oModel:GetModel('NUTDETAIL') // Relacionamento Caso x Contrato
oModelNT1   := oModel:GetModel('NT1DETAIL') // Vencimentos
oModelNTR   := oModel:GetModel('NTRDETAIL') // Faixa de valores
nQtdNTR     := oModelNTR:GetQtdLine()
nQtdNUT     := oModelNUT:GetQtdLine()
nLnOldNT1   := oModelNT1:GetLine()
nQtdLnNUT   := nQtdNUT
nLnOldNUT   := oModelNUT:GetLine()
nLnOldNTR   := oModelNTR:GetLine()
oStructNT1  := oModelNT1:GetStruct()
lCanDelNT1  := oModelNT1:CanDeleteLine()
lCanUptNT1  := oModelNT1:CanUpdateLine()
lCanInsNT1  := oModelNT1:CanInsertLine()

If JUR96FAIXA(oModelNT0:GetValue('NT0_CTPHON')) .And. !oModelNUT:IsEmpty() .And. oModelNT1:Length(.T.) > 0 .And. oModelNT1:GetValue("NT1_SITUAC") == "1"

	If !Empty(cSequen)
		nQtdNT1   := oModelNT1:GetQtdLine()
		For nI := 1 To nQtdNT1
			If oModelNT1:IsDeleted(nI)
				Loop
			EndIf
			If oModelNT1:GetValue("NT1_SEQUEN", nI) == cSequen
				oModelNT1:GoLine(nI)
				Exit
			EndIf
		Next nI
	EndIf

	If cQtdCsAut == "2" // Quantidade de casos / processos ser· indicada manualmente
		nQtdCasPro := oModelNT1:GetValue('NT1_QTDADE')
	Else
		If NT0->(ColumnPos( "NT0_CASPRO" )) > 0 .And. oModelNT0:GetValue('NT0_CASPRO') == "2" // Processos - Utiliza funÁ„o do SIGAJURI que retorna o n˙mero de processos
			nQtdCasPro := JurQtdProc(oModelNT1:GetValue('NT1_DATAIN'), oModelNT1:GetValue('NT1_DATAFI'), .T. /*Em andamento*/, oModelNT0:GetValue('NT0_FXABM') == "1", oModelNT0:GetValue('NT0_FXENCM') == "1", oModelNT0:GetValue('NT0_COD'))
		Else // Casos
			For nI := 1 To nQtdLnNUT
				If oModelNUT:IsDeleted(nI) .Or. ;
					!J96ConsCaso(oModelNUT:GetValue("NUT_CCLIEN",nI),oModelNUT:GetValue("NUT_CLOJA",nI),oModelNUT:GetValue("NUT_CCASO",nI))
					nQtdNUT--
				EndIf
			Next nI
			nQtdCasPro := nQtdNUT
		EndIf
	EndIf

	If nQtdCasPro > 0
		Do Case
		Case oModelNT0:GetValue("NT0_TPFX") == "1" // Est·tica
			aValores := JFindMdlM(oModelNTR, ;
				"FwFldGet('NTR_VLINI') <= "+AllTrim(STR(nQtdCasPro))+" .And. FwFldGet('NTR_VLFIM') >= "+AllTrim(STR(nQtdCasPro)), ;
				{"NTR_VALOR","NTR_TPVL"})
			If !Empty(aValores)
				nValor := aValores[1]
				If aValores[2] == "2"
					nValor := nValor * nQtdCasPro
				EndIf
			EndIf

		Case oModelNT0:GetValue("NT0_TPFX") == "2" // Progressiva
			For nI := 1 To nQtdNTR
				Iif(nI > 1, nDif := 1, nDif := 0)
				If !oModelNTR:IsDeleted(nI)
					If oModelNTR:GetValue('NTR_VLINI',nI) <= oModelNTR:GetValue('NTR_VLFIM',nI) .And. oModelNTR:GetValue('NTR_VLINI',nI) <= nQtdCasPro
						If oModelNTR:GetValue("NTR_TPVL",nI) == "2" //Valor Unit·rio
							If nQtdCasPro <= oModelNTR:GetValue('NTR_VLFIM',nI)
								nValor += ((nQtdCasPro - (oModelNTR:GetValue('NTR_VLINI',nI) - nDif)) * oModelNTR:GetValue("NTR_VALOR",nI))
							Else
								nValor += ((oModelNTR:GetValue('NTR_VLFIM',nI) - (oModelNTR:GetValue('NTR_VLINI',nI) - nDif)) * oModelNTR:GetValue("NTR_VALOR",nI))
							EndIf
						Else
							nValor += oModelNTR:GetValue("NTR_VALOR",nI) //Valor Fixo
						EndIf
					EndIf
				EndIf
			Next
		End Case
	EndIf

	// GravaÁ„o dos valores
	J096SetNo(oModelNT1, .F.)
	oStructNT1:setProperty("NT1_VALORB", MODEL_FIELD_WHEN, {|model| !model:isDeleted() .and. model:GetValue("NT1_SITUAC")=="1" })
	oStructNT1:setProperty("NT1_VALORA", MODEL_FIELD_WHEN, {|model| !model:isDeleted() .and. model:GetValue("NT1_SITUAC")=="1" })
	oModelNT1:SetValue("NT1_VALORB", nValor)
	If NT1->(ColumnPos("NT1_QTDADE")) > 0
		oModelNT1:SetValue("NT1_QTDADE", nQtdCasPro)
	EndIf
	cNT1Descri := Iif(NT0->(ColumnPos("NT0_CASPRO")) > 0 .And. oModelNT0:GetValue('NT0_CASPRO') == "1", STR0220, STR0221) //"Quantidade de casos: ", "Quantidade de processos:"
	oModelNT1:SetValue("NT1_DESCRI", oModelNT1:GetValue("NT1_DESCRI") + CRLF + cNT1Descri + Alltrim(Str(nQtdCasPro)))

	If Empty(nValor)
		Alert(STR0170) // "N„o foi possÌvel calcular o valor da parcela. Verifique se h· faixas cadastradas e/ou casos/processos para o perÌodo da parcela."
	EndIf

Else
	Alert(STR0084) // "SÛ È possivel calcular parcelas pendentes!"
EndIf

oModelNT1:GoLine(nLnOldNT1)
oModelNUT:GoLine(nLnOldNUT)
oModelNTR:GoLine(nLnOldNTR)

// Retorna os valores padrıes
oModelNT1:SetNoDeleteLine(!lCanDelNT1)
oModelNT1:SetNoInsertLine(!lCanInsNT1)
oModelNT1:SetNoUpdateLine(!lCanUptNT1)

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} J96ConsCaso
FunÁ„o utilizada para verificar se o caso deve entrar ou n„o no c·lculo
de Quantidade de Casos, considerando sua data de entrada/encerramento.

@Param  cCliente  Cliente do Caso a ser consultado
@Param  cLoja     Loja do Caso a ser consultado
@Param  cCaso     Caso a ser consultado

@Return lRet      .T./.F. Considera ou n„o

@author Cristina Cintra
@since 13/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J96ConsCaso(cCliente, cLoja, cCaso)
Local lRet      := .T.
Local aArea     := GetArea()
Local aAreaNVE  := NVE->(GetArea())
Local lFxAber   := FwFldGet("NT0_FXABM")  == '1' //Considera casos abertos no mÍs de referÍncia
Local lFxEnce   := FwFldGet("NT0_FXENCM") == '1' //Considera casos encerrados no mÍs de referÍncia
Local dDTRefIni := FwFldGet("NT1_DATAIN")
Local dDTRefFim := FwFldGet("NT1_DATAFI")

If Empty(dDTRefIni) .Or. Empty(dDTRefFim)
	lRet := .F.
EndIf

If lRet
	NVE->(dbSetOrder(1))
	If NVE->(dbSeek(xFilial('NVE')+cCliente+cLoja+cCaso)) .And. (NVE->NVE_ENCHON = '2')
		If NVE->NVE_SITUAC == "1" // Andamento
			If lFxAber
				lRet := NVE->NVE_DTENTR < dDTRefFim+1
			Else
				lRet := NVE->NVE_DTENTR < dDTRefIni
			EndIf
		Else // Encerrado
			If lFxAber
				If lFxEnce
					lRet := NVE->NVE_DTENTR < dDTRefFim+1 .AND. NVE->NVE_DTENCE > dDTRefIni-1
				Else
					lRet := NVE->NVE_DTENTR < dDTRefFim+1 .AND. NVE->NVE_DTENCE > dDTRefFim
				EndIf
			Else
				If lFxEnce
					lRet := NVE->NVE_DTENTR < dDTRefIni .AND. NVE->NVE_DTENCE > dDTRefIni-1
				Else
					lRet := NVE->NVE_DTENTR < dDTRefIni .AND. NVE->NVE_DTENCE > dDTRefFim
				EndIf
			EndIf
		EndIf
	Else
		lRet := .F.
	EndIf
EndIf

NVE->(RestArea(aAreaNVE))
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096TemCpo
FunÁ„o utilizada para validar se o contrato ter· faixa de faturamento

@Param  nBotao Bot„o a ser validado como base para a validaÁ„o (Faixa de Valores ou CondiÁıes de Faturamento)
@Param  lShowMsg  Exibe ou n„o mensagem quanto ao tipo de honor·rio

@Return nAt	 	.T./.F. As informaÁıes s„o v·lidas ou n„o

@author Felipe Bonvicini Conti
@since 25/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096TemCpo(nBotao, lShowMsg)
Local lTemCpo := .F.
Local nAt     := 0
Local nI      := 0

Default lShowMsg := .T.

If ( nAt := aScan( aCpoBotoes, { |x| x[CTPHON] == FwFldGet('NT0_CTPHON') .AND. X[BOTAO] == nBotao } ) ) == 0
	ApMsgStop( STR0017 + FwFldGet('NT0_CTPHON') + STR0018 ) //### //"N„o existe configuraÁ„o de relacionamento de campos para o tipo de contrato "###" e este bot„o ou o tipo n„o foi informado."
	Return 0
EndIf

For nI := 1 To Len( aCpoBotoes[nAt][CONFIG] )
	If ( lTemCpo := Iif( aCpoBotoes[nAt][CONFIG][nI][VISIV], .T.,  lTemCpo ) )
		Exit
	EndIf
Next

If !lTemCpo
	Iif(lShowMsg, ApMsgStop( STR0027 ), ) //"N„o h· campos a serem utilizados para este tipo de honor·rios"
	Return 0
EndIf

Return nAt

//-------------------------------------------------------------------
/*/ { Protheus.doc } J70ATUNT5
Rotina para Atualizar o valor do campo revisado da tabela NT5

@author Felipe Bonvicini Conti
@since 02/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J96ATUNT5(oModelNT5)
Local nQtd     := oModelNT5:GetQtdLine()
Local nLineOld := oModelNT5:nLine
Local nI

For nI:=1 To nQtd
	oModelNT5:GoLine(nI)
	If !oModelNT5:IsDeleted()
		oModelNT5:SetValue("NT5_REV", "2")
	EndIf
Next

oModelNT5:GoLine(nLineOld)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144REVAL
Revaloriza os Time-Sheets dos casos do contrato

@Param cCodCont			CÛdigo do Contrato

@author Jacques Alves Xavier
@since 08/02/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA096REVAL(cCodCont)
Local lRet := .F.
	MsgRun(STR0209, , {|| lRet := JA096REVTS(cCodCont) } ) //"Revalorizando TS"
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA096REVTS
Revaloriza os Time-Sheets dos casos do contrato

@Param cCodCont  CÛdigo do Contrato
@param lAutomato ExecuÁ„o via automaÁ„o

@author Jacques Alves Xavier
@since 08/02/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA096REVTS(cCodCont, lAutomato)
Local aArea       := GetArea()
Local aAreaNUE    := NUE->(GetArea())
Local cQuery      := ""
Local cQueryRes   := ""
Local oModel      := FwModelActive(, .T.)
Local lOk         := .T.
Local lRet        := .T.
Local lLock       := .F.
Local cMsg        := ""
Local aResult     := {}
Local aTimeSheets := {}
Local aTsOk       := {}
Local lTodosTSBloq:= .T.
Local nI          := 0
Local cCodTS      := ""
Local cCodTSPre   := ""
Local lLiberaTudo := .F.
Local lLibAltera  := .F.
Local lLibParam   := .T.
Local aRetBlqTS   := {}
Local cUsuario    := JurUsuario(__CUSERID)
Local lLCPRE      := JurGetDados("NUR", 1, xFilial("NUR") + cUsuario, "NUR_LCPRE") == "1"
Local lAltHr      := NUE->(ColumnPos('NUE_ALTHR')) > 0

Default lAutomato := .F.

If lAutomato .Or. ApMsgYesNo(STR0089) //"Deseja revalorizar os Time-Sheets dos casos do contrato selecionado?"
	lLock := LockByName("SIGAPFS_CONTR_" + cCodCont + "_TIMESHEET", .T., .T., /*lMayIUseDisk*/)

	If lLock
		cQuery    := " SELECT NUE_CPREFT, NUE.R_E_C_N_O_  NUERECNO, NUE_DATATS, NUE_COD "
		cQuery    +=   " FROM " + RetSqlName("NUE") + " NUE "
		cQuery    +=  " WHERE NUE.D_E_L_E_T_ = ' ' "
		cQuery    +=    " AND NUE.NUE_FILIAL = '" + xFilial( "NT0" ) +"' "
		cQuery    +=    " AND NUE.NUE_SITUAC = '1' "
		cQuery    +=    " AND EXISTS ( SELECT NUT.R_E_C_N_O_ "
		cQuery    +=                   " FROM " + RetSqlName("NUT") + " NUT "
		cQuery    +=                  " WHERE NUT.D_E_L_E_T_ = ' ' "
		cQuery    +=                    " AND NUT.NUT_FILIAL = '" + xFilial( "NT0" ) +"' "
		cQuery    +=                    " AND NUT.NUT_CCONTR = '" + cCodCont + "' "
		cQuery    +=                    " AND NUT.NUT_CCLIEN = NUE.NUE_CCLIEN "
		cQuery    +=                    " AND NUT.NUT_CLOJA  = NUE.NUE_CLOJA "
		cQuery    +=                    " AND NUT.NUT_CCASO  = NUE.NUE_CCASO ) "

		cQueryRes := GetNextAlias()
		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cQueryRes, .T., .T.)

		TcSetField((cQueryRes), "NUE_DATATS", "D", 8, 0)

		While !(cQueryRes)->(EOF())
			Aadd(aTimeSheets, {(cQueryRes)->NUE_DATATS, (cQueryRes)->NUE_CPREFT, (cQueryRes)->NUE_COD, (cQueryRes)->NUERECNO})
             //                      1                              2                       3                4
			(cQueryRes)->( dbSkip() )
		EndDo

		(cQueryRes)->(dbCloseArea())

		For nI := 1 To Len(aTimeSheets)
			lOk := .F.

			If lLibParam
				aRetBlqTS := JBlqTSheet(aTimeSheets[nI, 1]) // Par‚metro da funÁ„o: Data do Timesheet
			EndIf
			lLiberaTudo   := aRetBlqTS[1]
			lLibAltera    := aRetBlqTS[3]
			lLibParam     := aRetBlqTS[5]
			If lLiberaTudo .And. lLibAltera .And. lLibParam
				lTodosTSBloq := .F.
				lOk          := .T.
			ElseIf !lLibParam
				lRet := .F.
				Exit
			EndIf

			If lOk .And. !Empty(Alltrim(aTimeSheets[nI, 2]))
				lOk := !(JurGetDados("NX0", 1, xFilial("NX0") + aTimeSheets[nI, 2], "NX0_SITUAC") $ "C|F")
				If !lOk
					cCodTSPre +=  aTimeSheets[nI, 3] + CRLF
				EndIf
			ElseIf !lOk
				cCodTS +=  aTimeSheets[nI, 3] + CRLF  // CÛdigo dos times sheets que n„o h· permiss„o para alterar.
			EndIf

			If lOk
				If !Empty(aTimeSheets[nI, 2]) // Numero de PrÈ-fatura preenchido?
					If lLCPRE
						If lAutomato .Or. ApMsgYesNo(STR0085) // "Existe prÈ-fatura para este Contrato. Deseja apagar a prÈ-fatura para efetuar a alteraÁ„o?."
							If ASCAN(aTsOk, aTimeSheets[nI, 2] ) == 0
								If JA202CANPF(aTimeSheets[nI, 2])
									J202HIST('5', aTimeSheets[nI, 2], cUsuario) //Insere o HistÛrico na prÈ-fatura // (cQueryRes)->NUE_CPREFT
									NUE->(DBGoTo(aTimeSheets[nI, 4]))
									RecLock( 'NUE', .F. )
									NUE->NUE_CPREFT := ''
									NUE->NUE_CUSERA := cUsuario
									NUE->NUE_ALTDT  := Date()
									If lAltHr
										NUE->NUE_ALTHR  := Time()
									EndIf
									NUE->(MsUnlock())
									//Grava na fila de sincronizaÁ„o a alteraÁ„o
									J170GRAVA("NUE", xFilial("NUE") + NUE->NUE_COD, "4")
									lOk := .T.
									Aadd(aTsOk, aTimeSheets[nI, 4])
								EndIf
							EndIf
						EndIf
					EndIf
				Else
					Aadd(aTsOk, aTimeSheets[nI, 4])
				EndIf
			EndIf
		Next

		If lTodosTSBloq .And. Len(aTimeSheets) > 0 .And. lLibParam
			cMsg := STR0206 + CRLF + cCodTS // "VocÍ n„o tem permiss„o para alterar os seguintes Time Sheets: "
		ElseIf lLibParam
			dbSelectarea('NUE')

			For nI := 1 To Len(aTsOk)
				NUE->(DbGoTo(aTsOk[nI]))
				If NUE->NUE_SITUAC == '1'
					PtInternal(1, "JA096REVTS: Reval TS - " + NUE->NUE_COD )
					// Revaloriza TS - n„o considera o par‚metro
					aResult := JURA200(NUE->NUE_COD, NUE->NUE_CPART2, NUE->NUE_CCLIEN, NUE->NUE_CLOJA, NUE->NUE_CCASO, NUE->NUE_ANOMES,, NUE->NUE_CATIVI)

					If Empty(aResult[1])
						lRet := .F.
						cCodTS += NUE->NUE_COD + CRLF //JurMsgErro( STR0025 ) // Erro na valorizaÁ„o do Time Sheet
					Else
						If (oModel == NIL) .OR. (oModel != NIL .AND. (oModel:GetOperation() == 3 .OR. oModel:GetOperation() == 4 ))
							RecLock("NUE", .F.)
							NUE->NUE_CMOEDA := aResult[1]
							NUE->NUE_VALORH := aResult[2]
							NUE->NUE_VALOR  := aResult[2] * NUE->NUE_TEMPOR
							NUE->NUE_CUSERA := JurUsuario(__CUSERID)
							NUE->NUE_ALTDT  := Date()
							If lAltHr
								NUE->NUE_ALTHR  := Time()
							EndIf
							NUE->(MsUnlock())
							//Grava na fila de sincronizaÁ„o a alteraÁ„o
							J170GRAVA("NUE", xFilial("NUE") + NUE->NUE_COD, "4")
						EndIf
					EndIf
				EndIf
			Next
		EndIf
		PtInternal(1, "JA096REVTS: Reval TS - OK" )
		lRet := UnLockByName("SIGAPFS_CONTR_" + cCodCont + "_TIMESHEET", .T., .T., /*lMayIUseDisk*/)
	EndIf

	If !Empty(cCodTSPre)
		MsgAlert(STR0226 + CRLF + cCodTSPre) // "Os seguintes Time Sheets n„o foram revalorizados pois est„o vinculados a prÈ-fatura em processo de revis„o: "
	EndIf

	If !lTodosTSBloq .And. lLibParam
		If !Empty(cCodTS)
			JurErrLog(STR0207 + CRLF + cCodTS) // "Alguns Time Sheets n„o foram revalorizados. VocÍ n„o tem permiss„o para alterar os seguintes Time Sheets: "
		EndIf
	ElseIf lLibParam
		JurErrLog(cMsg, STR0156) // "Os Time Sheets n„o foram revalorizados"
	EndIf

	If !lAutomato .And. lRet .And. !lTodosTSBloq .And. Empty(cCodTSPre)
		MsgInfo(STR0117) // "Time Sheet revalorizado"
	EndIf

EndIf

RestArea( aAreaNUE )
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J96CorrCDF
FunÁ„o utilizada para corrigir o valor.

@Param   oModel modelo de dados do cadastro de contratos

@Obs     Ao realizar manutenÁ„o da rotina, verificar a rotina original J201ECorrF

@author Felipe Bonvicini Conti
@since 09/04/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function J96CorrCDF(oModel)
Local oModelNT0  := oModel:GetModel('NT0MASTER')
Local oModelNT1  := oModel:GetModel('NT1DETAIL') // Parcelas fixas
Local cTpHon     := oModelNT0:GetValue('NT0_CTPHON')
Local cTabela    := ""
Local nValorBase := 0
Local nValorAtu  := 0
Local lAutomatic := J96TPHPAut(cTpHon) //Indica se a geraÁ„o das parcelas È autom·tica ou manual
Local nI         := 0
Local nQtdNT1    := 0
Local nLineNT1   := 0
Local aResult    := {}
Local lRet       := .T.
Local cMoedaNac  := SuperGetMv('MV_JMOENAC',, '01')

/* Quando o tipo for geraÁ„o autom·tica ser· atualizado o valor no contrato e em todas as parcelas pendentes considerando o seu perÌodo.
J· quando for manual, ser· atualizada apenas a parcela em que o usu·rio estiver posicionado e o valor atual no contrato.
*/

lRet := J96VerPreFat(oModel, oModelNT1:GetLine())

If lRet .And. !oModelNT1:IsEmpty() .And. !oModelNT0:GetValue("NT0_TPCORR") == "1"

	nLineNT1 := oModelNT1:GetLine()

	If lAutomatic
		cTabela := "NT0"
		nValorBase := oModelNT0:GetValue("NT0_VLRBAS")
	Else
		If !oModelNT1:IsDeleted() .And. oModelNT1:GetValue("NT1_SITUAC") == "1" //Parcela Pendente
			cTabela := "NT1"
			nValorBase := oModelNT1:GetValue("NT1_VALORB")
		Else
			ApMsgStop(STR0090) //"SÛ È possivel corrigir parcelas pendentes!"
		EndIf
	EndIf

	If !Empty(cTabela)

		If lAutomatic
			aResult := JFindMdl(oModelNT1, "NT1_SITUAC", "1", {"POSICAO"})
			If !Empty(aResult)
				oModelNT1:GoLine(aResult[1])
			Else
				ApMsgStop(STR0100) // "N„o foi possivel encontrar parcela pendente."
				Return Nil
			EndIf
			J096SetNo(oModelNT1, .F.)

			nQtdNT1 := oModelNT1:GetQtdLine()
			
			For nI := oModelNT1:GetLine() To nQtdNT1

				If !oModelNT1:IsDeleted(nI) .And. oModelNT1:GetValue("NT1_SITUAC", nI) == '1'

					nValorAtu := 0

					If Iif(Empty(oModelNT1:GetValue("NT1_CMOEDA", nI)), oModelNT0:GetValue("NT0_CMOEF"), oModelNT1:GetValue("NT1_CMOEDA", nI)) == cMoedaNac  //SÛ Faz a correÁ„o da parcela se o valor for em moeda nacional.

						nValorAtu := JCorrIndic(nValorBase, ;
												oModelNT0:GetValue("NT0_DTBASE"), ;
												oModelNT1:GetValue("NT1_DATAVE", nI), ;
												oModelNT0:GetValue("NT0_PERCOR"), ;
												oModelNT0:GetValue("NT0_CINDIC"), ;
												"V")
					Else
						nValorAtu := oModelNT1:GetValue("NT1_VALORB", nI)
					EndIf

				EndIf

				// Ajusta o valor da parcela quando se tratar de Misto
				If oModelNT0:GetValue('NT0_FIXEXC') == '2' .And. !Empty(oModelNT0:GetValue('NT0_PEREX')) .And. !Empty(oModelNT0:GetValue('NT0_PERFIX'))
					nValorAtu := nValorAtu / (oModelNT0:GetValue('NT0_PEREX') / oModelNT0:GetValue('NT0_PERFIX'))
				EndIf
				If !Empty(oModelNT0:GetValue('NT0_PERCD'))
					nValorAtu := nValorAtu - ( nValorAtu * ( oModelNT0:GetValue('NT0_PERCD') / 100 ) )
				EndIf

				If !Empty(nValorAtu)
					oModelNT1:GoLine(nI)
					oModelNT1:LoadValue( "NT1_VALORA", nValorAtu )
					oModelNT1:LoadValue( "NT1_DATAAT", Date() )
				EndIf

			Next nI

			// Preenche o valor base atualizado do contrato
			nValorAtu := JCorrIndic(nValorBase,   ;
									oModelNT0:GetValue("NT0_DTBASE"), ;
									Nil, ;
									oModelNT0:GetValue("NT0_PERCOR"), ;
									oModelNT0:GetValue("NT0_CINDIC"), ;
									"V")

			If !Empty(nValorAtu)
				oModelNT0:LoadValue( "NT0_VALORA", nValorAtu )
				oModelNT0:LoadValue( "NT0_DATAAT", Date() )
			EndIf

		Else // CorreÁ„o monetaria de uma unica parcela

			If !oModelNT1:IsDeleted() .And. oModelNT1:GetValue("NT1_SITUAC") == '1'

				If Iif(Empty(oModelNT1:GetValue("NT1_CMOEDA")), oModelNT0:GetValue("NT0_CMOEF"), oModelNT1:GetValue("NT1_CMOEDA")) == cMoedaNac  //SÛ Faz a correÁ„o da parcela se o valor for em moeda nacional.

					nValorAtu := JCorrIndic(nValorBase,   ;
											oModelNT0:GetValue("NT0_DTBASE"), ;
											oModelNT1:GetValue("NT1_DATAVE"), ;
											oModelNT0:GetValue("NT0_PERCOR"), ;
											oModelNT0:GetValue("NT0_CINDIC"), ;
											"V")

					If !Empty(nValorAtu)
						oModelNT1:LoadValue( "NT1_VALORA", nValorAtu )
						oModelNT1:LoadValue( "NT1_DATAAT", Date() )

						// Preenche o valor base atualizado do contrato
						nValorAtu := JCorrIndic(oModelNT0:GetValue("NT0_VLRBAS"),   ;
												oModelNT0:GetValue("NT0_DTBASE"), ;
												Nil, ;
												oModelNT0:GetValue("NT0_PERCOR"), ;
												oModelNT0:GetValue("NT0_CINDIC"), ;
												"V")
					Else
						nValorAtu := oModelNT1:GetValue("NT1_VALORB", nI)
					EndIf

					If !Empty(nValorAtu)
						oModelNT0:LoadValue( "NT0_VALORA", nValorAtu )
						oModelNT0:LoadValue( "NT0_DATAAT", Date() )
					EndIf

				EndIf

			EndIf

			oModelNT1:GoLine(nLineNT1)

			If lAutomatic
				J096SetNo(oModelNT1, .T.)
			EndIf

		EndIf

	EndIf

EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J096VLDCP
FunÁ„o para validar os campos do contrato pelo dicion·rio

@author David G. Fernandes
@since 05/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function J096VLDCP(cCampo)
Local lRet      := .T.
Local cCliente  := ""
Local cLoja     := ""
Local cSitContr := ""
Local cMsg      := ""
Local oModel    := Nil

Do Case
Case cCampo == "NT0_DIAEMI"
	lRet := FwFldGet("NT0_DIAEMI") >= 0 .And. FwFldGet("NT0_DIAEMI") <= 31
	cMsg := STR0091 //"O dia deve estar entre 0 e 31"

Case cCampo == "NUT_CLOJA"
	cCliente  := FwFldGet("NUT_CCLIEN")
	cLoja     := FwFldGet("NUT_CLOJA")
	cSitContr := FwFldGet("NT0_SIT")
	If !Empty(cCliente) .And. !Empty(cLoja)
		aDadosCli := JurGetDados('NUH', 1, xFilial('NUH') + cCliente + cLoja, {"NUH_COD", "NUH_SITCAD"})
		If Len(aDadosCli) == 2 .And. !Empty(aDadosCli[1]) // CÛdigo do cliente na NUH
			If Empty(cCliente) .Or. !JAEXECPLAN("NUTDETAIL", "", "NUT_CCLIEN", "NUT_CLOJA", "NUT_CCASO", "NUT_CLOJA")
				lRet := .F.
				cMsg := STR0092 // "O Cliente/Loja inv·lido"
			ElseIf cSitContr == "2" .And. aDadosCli[2] == "1" // Contrato Definitivo cliente provisÛrio
				lRet := .F.
				cMsg := STR0258 // "N„o È permitido o uso de cliente com situaÁ„o 'ProvisÛria' em contratos definitivos!"
			EndIf
		Else
			lRet := .F.
			cMsg := STR0092 // "O Cliente/Loja inv·lido"
		EndIf
	EndIf

Case cCampo == "NT0_TPCEXC"
	oModel := FwModelActive()

	If FwFldGet("NT0_TPCEXC") == "1"
		oModel:LoadValue("NT0MASTER", "NT0_PERCD", 0)
	Else
		oModel:LoadValue("NT0MASTER", "NT0_LIMEXH", 0)
	EndIf
End Case

If !lRet
	JurMsgErro(cMsg,, STR0255) // "Ajuste o cadastro."
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J96VldDTE
FunÁ„o utilizada para validar o intervalo de datas.

@author Felipe Bonvicini Conti
@since 13/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function J96VldDTE(dDataIni, dDataFim, cParcela)
Local lRet := .T.

If dDataIni >= dDataFim
	lRet := JurMsgErro(STR0095) //"A data final deve ser maior que a data inicial."
Else
	lRet := J096VldData(dDataIni, dDataFim, cParcela)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA096RELA
FunÁ„o para inicializador padr„o

@author Jacques Alves Xavier
@since 13/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA096RELA(cCampo)
Local cRet   := ""
Local oModel := FWModelActive()
Local aArea  := GetArea()

	If oModel:GetID() == 'JURA096'
		Do Case
			Case cCampo == "NUT_DCLIEN"
			cRet := JurGetDados("SA1", 1, xFilial("SA1") + NUT->NUT_CCLIEN + NUT->NUT_CLOJA, "A1_NOME")
		End Case
	EndIf

RestArea( aArea )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J96VldDTE
FunÁ„o para inicializador padr„o

@author Jacques Alves Xavier
@since 14/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA096VLENC()
Local lRet := .T.

If FwFldGet("NT0_DTENC") < FwFldGet("NT0_DTINC")
	lRet := JurMsgErro(STR0096) // "A data de encerramento deve ser maior ou igual a data de inclus„o."
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096SetNo
FunÁ„o utilizada para bloquar o grid.

@author Felipe Bonvicini Conti
@since 18/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096SetNo(oModel, lLiga)
	oModel:SetNoDeleteLine(lLiga)
	oModel:SetNoInsertLine(lLiga)
	oModel:SetNoUpdateLine(lLiga)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA096NUT
Verifica os casos vinculados a serem carregados na tela, a partir da
tela de processo

@param  	oModelGrid  	Model do Grid
@param 		lLoad           Indica se ir· carregar
@return 	aRet			Array de linhas do grid

@author Juliana Iwayama Velho
@since 26/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA096NUT(oModelGrid, lLoad)
Local aRet    := {}
Local aRet2   := {}
Local oStruct := Nil
Local aFields := {}
Local nPos    := 0
Local nI      := 0

	aRet  := FormLoadGrid(oModelGrid, lLoad)
	aRet2 := aClone( aRet )
	oStruct := oModelGrid:GetStruct()
	aFields := oStruct:GetFields()

	nPos := aScan(aFields, {|aX| aX[MODEL_FIELD_IDFIELD] == 'NUT_CCASO' } )

	If nPos > 0
		aRet2 := {}
		For nI := 1 To Len(aRet)
			If aRet[nI][2][nPos] == NSZ->NSZ_NUMCAS
				aAdd(aRet2, aClone(aRet[nI]))
			EndIf
		Next
	EndIf

Return aRet2

//-------------------------------------------------------------------
/*/{Protheus.doc} JA096VACY
Preenche o nome do grupo de clientes

@return 	cRet	Nome do grupo

@author Juliana Iwayama Velho
@since 26/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA096VACY()
Local aArea  := GetArea()
Local cRet   := ''

If IsInCallStack('JURA162') .Or. (!IsInCallStack('JURA162') .And. !INCLUI)
	cRet:= JurGetDados("ACY", 1, xFilial("ACY") + FwFldGet("NT0_CGRPCL"), "ACY_DESCRI")
EndIf

RestArea( aArea )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA096VSA1
Preenche o nome do cliente

@return 	cRet	Nome do cliente

@author Juliana Iwayama Velho
@since 26/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA096VSA1()
Local aArea := GetArea()
Local cRet  := ''

If IsInCallStack('JURA162') .Or. (!IsInCallStack('JURA162') .And. !INCLUI)
	cRet := JurGetDados("SA1", 1, xFilial("SA1") + FwFldGet("NT0_CCLIEN") + FwFldGet("NT0_CLOJA"), "A1_NOME")
EndIf

RestArea( aArea )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA096SGCAS
Verifica se os campos  de casos vinculados ao contrato devem ser
preenchidos ao entrar na tela. UtilizaÁ„o
desta rotina ao invÈs de inicializador padr„o em cada campo

@param 	oModel  	Model a ser verificado

@author Juliana Iwayama Velho
@since 23/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA096SGCAS(oModel)
Local aArea   := {}
Local nOpc    := oModel:GetOperation()

If nOpc == 3
	If IsInCallStack('JURA162')
		oModel:SetValue("NUTDETAIL", 'NUT_CCLIEN',NSZ->NSZ_CCLIEN)
		oModel:SetValue("NUTDETAIL", 'NUT_CLOJA' ,NSZ->NSZ_LCLIEN)
		oModel:SetValue("NUTDETAIL", 'NUT_CCASO' ,NSZ->NSZ_NUMCAS)
	ElseIf IsInCallStack('JA096REPLI')//Rotina de replicaÁ„o de contrato
		aArea := GetArea()
		JA096SGNT0(NT0->NT0_COD, oModel)
		RestArea(aArea)
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA096REPLI
Bot„o para replicar as informaÁıes do contrato

@author Juliana Iwayama Velho
@since 24/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA096REPLI()
Local aArea  := GetArea()

If ApMsgYesNo(STR0078)
	FWExecView(STR0003, 'JURA096', 3,, {||.T.})
EndIf

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA096SGNT0(cContr, oModel)
Rotina para sugerir as informaÁıes do contrato selecionado para a
replicaÁ„o

@param  oModel  Model a ser verificado
@param  cContr  CÛdigo do contrato

@author Luciano Pereira dos Santos
@since 24/05/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA096SGNT0(cContr, oModel)
Local aArea      := GetArea()
Local aAreaNT0   := NT0->(GetArea())
Local aAreaNXP   := NXP->(GetArea())
Local aAreaNVN   := NVN->(GetArea())
Local aAreaNT5   := NT5->(GetArea())
Local aAreaNTK   := NTK->(GetArea())
Local aAreaNTJ   := NTJ->(GetArea())
Local oModelNT0  := oModel:GetModel('NT0MASTER')
Local oModelNXP  := oModel:GetModel('NXPDETAIL')
Local oModelNVN  := oModel:GetModel('NVNDETAIL')
Local oModelNT5  := oModel:GetModel('NT5DETAIL')
Local oModelNTK  := oModel:GetModel('NTKDETAIL')
Local oModelNTJ  := oModel:GetModel('NTJDETAIL')
Local aNT0       := {}
Local aNXP       := {}
Local aNVN       := {}
Local aNT5       := {}
Local aNTK       := {}
Local aNTJ       := {}
Local nI         := 0
Local nY         := 0
Local aStruct    := {}
Local aStruct2   := {}
Local aLinha     := {}
Local nTamCOD    := TamSX3('NVN_COD')[1]

aStruct := J096RmvRelat('NT0', oModelNT0, {'NT0_FILIAL', 'NT0_COD'}) //Remove os campos do SetRelation e adicionais que n„o devem ser preenchidos
NT0->(DbSetOrder(1))
If NT0->( DbSeek( xFilial('NT0') + cContr ) )
	J096GetLin('NT0', aStruct, @aNT0, .F.)
EndIf

aStruct2 := J096RmvRelat('NXP', oModelNXP) //Remove os campos do SetRelation e adicionais que n„o devem ser preenchidos
aStruct  := J096RmvRelat('NVN', oModelNVN) //Remove os campos do SetRelation e adicionais que n„o devem ser preenchidos
NVN->(DbSetOrder(5)) //NVN_FILIAL+NVN_CCONTR+NVN_CLIPG+NVN_LOJPG
NXP->(DbSetOrder(2)) //NXP_FILIAL+NXP_CCONTR+NXP_CLIPG+NXP_LOJAPG
If NXP->(DbSeek( xFilial('NXP') + cContr))
	While !NXP->(Eof()) .And. (xFilial('NXP') + NXP->NXP_CCONTR == xFilial('NXP') + cContr)

		If NVN->(DbSeek( xFilial('NVN') + NXP->NXP_CCONTR + NXP->NXP_CLIPG + NXP->NXP_LOJAPG))
			nY := 1
			While !NVN->(Eof()) .And. (xFilial('NVN') + NVN->NVN_CCONTR + NVN->NVN_CLIPG + NVN->NVN_LOJPG == xFilial('NVN') + NXP->NXP_CCONTR + NXP->NXP_CLIPG + NXP->NXP_LOJAPG)
				J096GetLin('NVN', aStruct, @aNVN, .T., {{'NVN_COD', StrZero(nY, nTamCOD)}}) //O campo NVN_COD È incrementado via view
				nY++
				NVN->(DbSkip())
			EndDo
		EndIf

		J096GetLin('NXP', aStruct2, @aLinha, .F.)
		Aadd(aNXP, {aLinha, aNVN})
		aLinha := {}
		aNVN   := {}

		NXP->(DbSkip())
	EndDo
EndIf

aStruct := J096RmvRelat('NT5', oModelNT5, {'NT5_COD'}) //Remove os campos do SetRelation e adicionais que n„o devem ser preenchidos
NT5->(DbSetOrder(2)) //NT5_FILIAL + NT5_CCONTR
If NT5->(DbSeek(xFilial('NT5') + cContr))
	While !NT5->(Eof()) .And. (xFilial('NT5') + NT5->NT5_CCONTR == xFilial('NT5') + cContr)
		J096GetLin('NT5', aStruct, @aNT5)
		NT5->(DbSkip())
	EndDo
EndIf

aStruct := J096RmvRelat('NTK', oModelNTK) //Remove os campos do SetRelation e adicionais que n„o devem ser preenchidos
NTK->(DbSetOrder(1)) //NTK_FILIAL + NTK_CCONTR + NTK_CTPDSP
If NTK->(DbSeek( xFilial('NTK') + cContr))
	While !NTK->(Eof()) .And. xFilial('NTK') + NTK->NTK_CCONTR == xFilial('NTK') + cContr
		J096GetLin('NTK', aStruct, @aNTK)
		NTK->(DbSkip())
	EndDo
EndIf

aStruct := J096RmvRelat('NTJ', oModelNTJ) //Remove os campos do SetRelation e adicionais que n„o devem ser preenchidos
NTJ->(DbSetOrder(1)) //NTJ_FILIAL + NTJ_CCONTR + NTJ_CTPATV
If NTJ->( dbSeek( xFilial('NTJ') + cContr ) )
	While !NTJ->(Eof()) .And. xFilial('NTJ') + NTJ->NTJ_CCONTR == xFilial('NTJ') + cContr
		J096GetLin('NTJ', aStruct, @aNTJ)
		NTJ->(DbSkip())
	EndDo
EndIf

If lRet := J096GrvMdl(@oModelNT0, aNT0) //grava o cabeÁalho
	For nI := 1 To Len(aNXP)
		If lRet := J096GrvMdl(@oModelNXP, aNXP[nI][1]) //grava a linha do grid do pagador
			lRet := J096GrvGrid(@oModelNVN, aNXP[nI][2]) //grava as linhas do grid dos contatos de encaminhamento de fatura
		EndIf
		If lRet
			Iif(nI < Len(aNXP), oModelNXP:AddLine(), Nil)
		Else
			Exit
		EndIf
	Next nI
EndIf

lRet := lRet .And. J096GrvGrid(@oModelNT5, aNT5)
lRet := lRet .And. J096GrvGrid(@oModelNTK, aNTK)
lRet := lRet .And. J096GrvGrid(@oModelNTJ, aNTJ)

RestArea( aAreaNT0 )
RestArea( aAreaNXP )
RestArea( aAreaNVN )
RestArea( aAreaNT5 )
RestArea( aAreaNTK )
RestArea( aAreaNTJ )
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096RmvRelat(cTable, oModel)
Rotina para remover os campos de relacionamento de modelo da estrutura da tabela

@Param  cTable   Nome da Tabela Ex: NXP
@Param  oModel   Parte do modelo pertecente a tabela Ex: oModelNXP
@Param  aCampos  Array com campos adicionais para serem removidos Ex: ['NXP_CLIPG','NXP_LOJAPG']

@Return aRet     Array da estrutura da tabela com os campos removidos

@author Luciano Pereira dos Santos
@since 23/05/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096RmvRelat(cTable, oModel, aCampos)
Local aRet      := {}
Local aStruct   := (cTable)->(DbStruct())
Local aRelation := oModel:GetRelation()[1]
Local nI        := 0

Default aCampos := {}

For nI := 1 to Len(aStruct)
	If (Ascan(aRelation, {|aX| aX[1] == aStruct[nI][1]}) == 0) .And.;
		(Ascan(aCampos, {|aY| aY == aStruct[nI][1]}) == 0)
		aAdd(aRet, aStruct[nI])
	EndIf
Next nI

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096GrvGrid(oModel, aData, lShowErro)
Rotina para gravar um grid de dados

@Param  oModel           Objeto do Modelo
@Param  aData[n]         Linha do Array multidimencional contendo contentdo os dados a serem gravados
         aData[n][n][1]  Nome do campo da linha
         aData[n][n][2]  Inf a ser gravada no campo

@Return lRet

@author Luciano Pereira dos Santos
@since 23/05/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096GrvGrid(oModel, aData, lShowErro)
Local lRet   := .T.
Local nLinha := 0

Default lShowErro := .T.

For nLinha := 1 To Len(aData)
	aLinha := aData[nLinha]
	If !J096GrvMdl(oModel, aLinha, lShowErro)
		Exit
	Else
		IIf(nLinha < Len(aData), oModel:AddLine(), Nil)
	EndIf
Next nLinha

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096GrvMdl(oModel, aData, lShowErro)
Rotina para gravar um grid de dados

@Param  oModel        Objeto do Modelo
@Param  aData         Array multidimencional contendo contentdo os dados a serem gravados
         aData[n][1]  Nome do campo do modelo
         aData[n][2]  Inf a ser gravada no campo do modelo

@Return lRet

@author Luciano Pereira dos Santos
@since 23/05/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096GrvMdl(oModel, aData, lShowErro)
Local lRet    := .T.
Local nCampo  := 0

Default lShowErro := .T.

For nCampo := 1 To Len(aData)
	If oModel:CanSetValue(aData[nCampo][1])
		If !(lRet := oModel:SetValue(aData[nCampo][1], aData[nCampo][2])) .And. lShowErro
			JurMsgErro(STR0079 + aData[nCampo][1] + STR0101 + AllToChar(aData[nCampo][2]))
			Exit
		EndIf
	EndIf
Next nCampo

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096GetLin(cTable, aStruct, aData, lGrid, aCampos)
Recupera dos dados de um registro posisiconado conforme os campos da estrutura

@Param  cTable           Nome da Tabela posicionada Ex: 'NXP'
@Param  aStruct          Array com a estrutura dos campos da tabela
         aStruct[n][1]   Campo da estrutura (Obrigatorio)
@Param  aData[*]         Linha do Array multidimencional contendo contentdo os dados a serem gravados
         aData[*][n][1]  Nome do campo da linha
         aData[*][n][2]  InformaÁ„o a ser gravada no campo

@Param  lGrid            Se .T. altera da dimens„o do array para linhas, permitindo passar aData por referÍncia

@Param  aCampos[n]      Array de campos da estrutura para gravar com conteudo diferenciado do registro
         aCampos[n][1]  Nome do campo
         aCampos[n][2]  InformaÁ„o diferenciada

@Return aData

@Obs *Se lGrid for .T.  o array aData pode ser passado por referencia acumulando varias linhas de registros

@author Luciano Pereira dos Santos
@since 23/05/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096GetLin(cTable, aStruct, aData, lGrid, aCampos)
Local nCampo    := 0
Local aLinha    := {}
Local xValor    := Nil

Default aData   := {}
Default aCampos := {}
Default lGrid   := .T.

For nCampo := 1 to Len(aStruct)

	If (nPos := Ascan(aCampos, {|aY| aY[1] == aStruct[nCampo][1]})) == 0
		xValor := (cTable)->(FieldGet(FieldPos(aStruct[nCampo][1])))
	Else
		xValor := aCampos[nPos][2]
	EndIf

	aAdd(aLinha, {aStruct[nCampo][1], xValor})
Next nCampo

If lGrid
	Aadd(aData, aLinha)
Else
	aData := aLinha
EndIf

Return aData

//-------------------------------------------------------------------
/*/{Protheus.doc} J096QTDE
Rotina para retornar a qtde ou os registros de Tipo de Despesas ou
Tipo de Atividades n„o cobr·veis do cliente/loja do contrato

@Param 	cTabela  	Tabela que ser· feita a query (NUB / NUC)
@Param  cTipo     Tipo de Retorno (1 = Qtde / 2 = tipos n„o cobr·veis
                  cadastrados no cliente)
@Param  cCliente  Cliente do contrato
@Param  cLoja     Loja do contrato
@Return aRet      Retorna um Array com a qtde ou com os tipos
                  cadastrados no cliente (dependendo do parametro cTipo)

@author Jacques Alves Xavier
@since 13/08/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096QTDE(cTabela, cTipo, cCliente, cLoja)
Local aArea   := GetArea()
Local cAlias  := GetNextAlias()
Local cQuery  := ''
Local aRet    := {}

If cTabela = 'NUB'
	// Tipo de Atividade n„o cobravel no cliente
	If cTipo == '1'
		cQuery := "SELECT COUNT(NUB.R_E_C_N_O_) QTDE " + CRLF
	Else
		cQuery := "SELECT NUB.NUB_CTPATI CODIGO" + CRLF
	EndIf
	cQuery += "  FROM " + RetSqlName('NUB') + " NUB " + CRLF
	cQuery += " WHERE NUB.NUB_FILIAL = '" + xFilial('NUB') + "' " + CRLF
	cQuery += "   AND NUB.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "   AND NUB.NUB_CCLIEN = '" + cCliente + "' " + CRLF
	cQuery += "   AND NUB.NUB_CLOJA = '" + cLoja + "' "

Else
	// Tipo de despesa n„o cobravel no cliente
	If cTipo == '1'
		cQuery := "SELECT COUNT(NUC.R_E_C_N_O_) QTDE " + CRLF
	Else
		cQuery := "SELECT NUC.NUC_CTPDES CODIGO" + CRLF
	EndIf
	cQuery += "  FROM " + RetSqlName('NUC') + " NUC " + CRLF
	cQuery += " WHERE NUC.NUC_FILIAL = '" + xFilial('NUC') + "' " + CRLF
	cQuery += "   AND NUC.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "   AND NUC.NUC_CCLIEN = '" + cCliente + "' " + CRLF
	cQuery += "   AND NUC.NUC_CLOJA = '" + cLoja + "' "

EndIf

dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQuery), cAlias, .T., .T. )

If cTipo == '1'
	aadd(aRet, (cAlias)->QTDE)
Else
	While !(cAlias)->( Eof() )
		aadd(aRet, (cAlias)->CODIGO )
		(cAlias)->( dbSkip() )
	EndDo
EndIf

(cAlias)->( dbCloseArea() )

RestArea( aArea )

Return( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} J096SUGVIC
Sugere as informaÁıes de cliente no casos vinculados

@author ClÛvis Eduardo Teixeira
@since 18/10/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function J096SUGVIC()
Local oModel     := FwModelActive()
Local oModelGrid := oModel:GetModel("NUTDETAIL" )
Local cClien     := oModel:GetValue("NT0MASTER", "NT0_CCLIEN")
Local cLoja      := oModel:GetValue("NT0MASTER", "NT0_CLOJA")
Local nOpc       := oModel:GetOperation()
Local lRet       := .T.

//Preenchimento dos campos cliente e loja da tabela NUT
If nOpc == 3 .And. !Empty(cClien) .And. !Empty(cLoja) .And. ( oModelGrid:IsEmpty() .Or. Empty(oModel:GetValue("NUTDETAIL", "NUT_CCASO")) ) ;
   .And. !IsInCallStack("JURA070")
	lRet := oModel:SetValue( "NUTDETAIL", "NUT_CCLIEN", cClien)
	lRet := oModel:SetValue( "NUTDETAIL", "NUT_CLOJA", cLoja)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA96DPART1
Nome do Revisor na Aba de Caso

@param nTipo , Tipo de execuÁ„o (1=Inicializador Padr„o;2=Gatilho)
@param cCampo, Campo de origem da informaÁ„o

@return cRet , Valor que ser· preenchido no campo virtual

@author ClÛvis Eduardo Teixeira
@since 18/10/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA96DPART1(nTipo, cCampo)
Local cChave   := ""
Local cRet     := ""
Local cValor   := ""

Default nTipo  := 1
Default cCampo := "RD0_NOME"

	If nTipo == 1
		If Empty(M->NT0_COD) .Or. M->NT0_COD == NUT->NUT_CCONTR
			cChave := xFilial("NVE") + NUT->(NUT_CCLIEN + NUT_CLOJA + NUT_CCASO)

			If !Empty(cChave)
				If NVE->NVE_FILIAL + NVE->NVE_CCLIEN + NVE->NVE_LCLIEN + NVE->NVE_NUMCAS == cChave
					cValor := NVE->NVE_CPART1
				Else
					cValor := Posicione("NVE", 1, cChave, "NVE_CPART1")
				EndIf
			EndIf
		EndIf
	
	ElseIf nTipo == 2
		cChave := xFilial("NVE") + FwFldGet('NUT_CCLIEN') + FwFldGet('NUT_CLOJA') + FwFldGet('NUT_CCASO')
	
		If !Empty(cChave)
			If NVE->NVE_FILIAL + NVE->NVE_CCLIEN + NVE->NVE_LCLIEN + NVE->NVE_NUMCAS == cChave
				cValor := NVE->NVE_CPART1
			Else
				cValor := Posicione("NVE", 1, cChave, "NVE_CPART1")
			EndIf
		EndIf
	EndIf
	
	If !Empty(cValor)
		cRet := Posicione("RD0", 1, xFilial("RD0") + cValor, cCampo)
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA96VALCON
ValidaÁ„o do contato por cliente/loja pagador

@author ClÛvis Eduardo Teixeira
@since 18/10/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA96VALCON()
Return JURCONTOK('SA1', FwFldGet("NXP_CCONT"), xFilial("SA1") + FwFldGet("NXP_CLIPG") + FwFldGet("NXP_LOJAPG"), "SU5->U5_ATIVO == '1'")

//-------------------------------------------------------------------
/*/{Protheus.doc} J96WOFixo
FunÁ„o para efetuar WO na parcela de Fixo

@author Jacques Alves Xavier
@since 16/11/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function J96WOFixo(oView, aObs)
Local ncountWO   := 0
Local aArea      := GetArea()
Local oModel     := oView:GetModel()
Local aAreaWO    := NT1->( GetArea() )
Local cContrato  := FwFldGet('NT1_CCONTR')
Local cParcela   := FwFldGet('NT1_SEQUEN')
Local cPrefat    := FwFldGet('NT1_CPREFT')
Local cSituac    := FwFldGet('NT1_SITUAC')
Local cWoCodig   := ''
Local nI         := 0
Local aParcela   := {}
Local aQtde      := {}
Local cSQL       := ''
Local nOpc       := oModel:GetOperation()
Local lTela      := .T.
Local lRet       := .T.
local lIsJ202    := IsJura202()
Local oModelNT1  := oModel:GetModel('NT1DETAIL')

Default aObs     := {}

If nOpc == 4

	If oModelNT1:IsEmpty()
		ApMsgStop(STR0194) // "N„o existem dados para realizaÁ„o do WO."
		lRet := .F.
	EndIf

	If lRet .And. oModel:lModify .And. !lIsJ202 .And. Empty(aObs)
		If ApMsgYesNo(STR0175, STR0150) //# "Ao realizar esta operaÁ„o o sistema salvar· todas as alteraÁıes feitas na tela!" ## "ATEN«√O"
			If lRet := oModel:VldData()
				lRet := FWFormCommit(oModel)
			Else
				JurShowErro( oModel:GetModel():GetErrormessage() )
			EndIf
		Else
			lRet := .F.
		EndIf
	EndIf

	If lRet

		If cSituac == '1'

			cSQL := "SELECT COUNT(NUT.R_E_C_N_O_) QTDE "
			cSQL +=  " FROM " + RetSqlName('NUT') + " NUT "
			cSQL +=  " WHERE NUT.NUT_FILIAL = '" + xFilial('NUT') + "' "
			cSQL +=   " AND NUT.D_E_L_E_T_ = ' ' "
			cSQL +=   " AND NUT.NUT_CCONTR = '" + cContrato + "' "

			aQtde := JurSQL(cSQL, "QTDE")

			If aQtde[1][1] > 0

				BEGIN TRANSACTION

					cSQL := "SELECT DISTINCT NUT.NUT_CCLIEN CLIENTE, NUT_CLOJA LOJA, NUT_CCASO CASO, NT0.NT0_CMOEF MOEDA, NT1.NT1_VALORA / " + alltrim(str(aQtde[1][1])) + " VAL_PARC "
					cSQL +=  " FROM " + RetSqlName('NT1') + " NT1 INNER JOIN " + RetSqlName('NUT') + " NUT "
					cSQL +=                                     " ON NT1.NT1_FILIAL = NUT.NUT_FILIAL AND NT1.NT1_CCONTR = NUT.NUT_CCONTR "
					cSQL +=                                     " INNER JOIN " + RetSqlName('NT0') + " NT0 "
					cSQL +=                                     " ON NT1.NT1_FILIAL = NT0.NT0_FILIAL AND NT1.NT1_CCONTR = NT0.NT0_COD "
					cSQL += " WHERE NT1.NT1_FILIAL = '" + xFilial('NT1') + "' "
					cSQL +=    " AND NT1.D_E_L_E_T_ = ' ' "
					cSQL +=    " AND NUT.D_E_L_E_T_ = ' ' "
					cSQL +=    " AND NT0.D_E_L_E_T_ = ' ' "
					cSQL +=    " AND NT1.NT1_CCONTR = '" + cContrato + "' "
					cSQL +=    " AND NT1.NT1_SEQUEN = '" + cParcela + "' "

					aParcela := JurSQL(cSQL, {"CLIENTE", "LOJA", "CASO", "MOEDA", "VAL_PARC"})

					If lTela := Empty(aObs)
						aObs := JurMotWO('NUF_OBSEMI', STR0135, STR0136, "5") // "WO - Parcela de Fixo" - "ObservaÁ„o - WO"
					EndIf

					If !Empty(aObs)

						cWoCodig := JAWOInclui(aObs)

						lRet := J96WOLanc(cPrefat, cParcela, cWoCodig, lTela, cContrato ) //Faz os ajustes de WO na parcela

						If lRet
							For nI := 1 To Len(aParcela)
								JAWOCasInc(cWoCodig, aParcela[nI][1], aParcela[nI][2], aParcela[nI][3], aParcela[nI][4], 0)  // N„o preencher o valor do campo valor (NUG_VALOR) na tabela NUG.
							Next
						EndIf

						J203NParc(cContrato) //Cria uma nova parcela conforme o tipo de honor·rio e condiÁıes do contrato.

						ncountWO := 1

						If lTela
							If lRet  // Esta mensagem sÛ pode ser exibida se o WO for efetivado.
								ApMsgInfo(STR0110) // "WO realizado com sucesso!"
							EndIf
						EndIf

					EndIf

					If lRet
						While GetSX8Len()>0
							ConfirmSX8()
						EndDo
					Else
						While GetSx8Len() > 0
							RollBackSX8()
						EndDo
						DisarmTransaction()
					EndIf

				END TRANSACTION

			Else
				If !IsInCallStack("JURA070")
					ApMsgStop(STR0108) // "… obrigatÛrio vincular pelo menos um caso "
				EndIf
			EndIf
		Else
			ApMsgStop(STR0109) // "SÛ ser· possÌvel efetuar WO em parcelas pendentes."
		EndIf

		If !lIsJ202
			oModel:Deactivate()
			NT0->( DbSetOrder(1) ) // recolocado pois estava deposicionando no commit da alteraÁ„o
			NT0->( DbSeek( xFilial('NT0') + cContrato ) )
			aArea := GetArea()
			oModel:Activate()
		EndIf

	EndIf

EndIf

RestArea( aAreaWO )
RestArea( aArea )

Return ncountWO

//-------------------------------------------------------------------
/*/{Protheus.doc} J96WOLanc
Efetua as alteraÁıes WO na parcela de Fixo

@param cParcela   Parcela de fixo
@param cPrefat    N˙mero da PrÈ-fatura
@param cWoCodig   CÛdigo do WO
@param lTela      Exibir mensagens na tela (.T./.F.)
@param cContrato  CÛdigo do Contrato

@Return lRet

@author Luciano Pereira dos Santos
@since 14/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J96WOLanc(cPrefat, cParcela, cWoCodig, lTela, cContrato)
Local lRet        := .T.
Local aArea       := GetArea()
Local aAreaNT1    := NT1->(GetArea())
Local aAreaNX0    := NX0->(GetArea())
local lIsJ202     := IsJura202()
Local lHaMaisLanc := .F.
Local lJVINCTS    := GetMV("MV_JVINCTS",, .F.)
Local cClien      := ""
Local cLoja       := ""
Local dDataIni
Local dDataFim
Local aOrd        := SaveOrd({"NRA", "NX0", "NX1", "NT0", "NT1", "NUE"})
Local aIncLanc    := {}
Local cNx0SitAnt  := ''
Local cPartLog    := JurUsuario(__CUSERID)
Local lAltHr      := NUE->(ColumnPos('NUE_ALTHR')) > 0
Local cTpLanc     := STR0246 // "Parcela fixa"

If !Empty(cPrefat)
	If NX0->(dbSeek(xFilial('NX0') + cPreFat) )
		If NX0->NX0_SITUAC $ '2|3'  //PrÈ-Fatura alter·vel
			NT0->(DbSetOrder(1))
			NT0->(DbSeek(xFilial('NT0') + cContrato))
			cClien := NT0->NT0_CCLIEN
			cLoja  := NT0->NT0_CLOJA

			NRA->(DbSetOrder(1))
			NRA->(DbSeek(xFilial("NRA") + NT0->NT0_CTPHON))
			If NRA->NRA_COBRAF = "1" .And. NRA->NRA_COBRAH == "2"
				lHaMaisLanc := (JurLancPre(cPrefat, .F.) > 0)
			ElseIf NRA->NRA_COBRAF = "1" .And. NRA->NRA_COBRAH == "1"
				lHaMaisLanc := (JurLancPre(cPrefat, .T.) > 0)
			EndIf

			If lHaMaisLanc
				If ApMsgYesNo(STR0180 + AllTrim(cParcela) + STR0181 + AllTrim(cPrefat) + STR0182 + AllTrim(JurSitGet(NX0->NX0_SITUAC)) + STR0187) // "A parcela '" ### "' est· vinculada a prÈ-fatura '" ### "' com a situaÁ„o '" ### "', a situaÁ„o da prÈ-fatura ficar· como alterada! Deseja continuar?î
					cNx0SitAnt := NX0->NX0_SITUAC
					RecLock("NX0", .F.)
					NX0->NX0_SITUAC := '3'
					NX0->NX0_USRALT := JurUsuario(__CUSERID)
					NX0->NX0_DTALT  := date()
					NX0->(MsUnlock())
					NX0->(DbCommit())

					If cNx0SitAnt != '3'
						J202HIST('99', NX0->NX0_COD, cPartLog, I18N(STR0227, {cParcela, cContrato})) // "Efetuado WO da parcela '#1' no contrato '#2'."
					EndIf
					
					If lJVINCTS
						aIncLanc := {}
						NT1->( dbSetOrder( 1 ) ) //NT1_FILIAL+NT1_SEQUEN
						If NT1->( dbSeek( xFilial('NT1') + cParcela ) )
							dDataIni := NT1->NT1_DATAIN
							dDataFim := NT1->NT1_DATAFI
							Aadd(aIncLanc, NT1->NT1_CMOEDA)
							NT1->(RecLock('NT1', .F.))
							NT1->NT1_SITUAC := "2"
							NT1->NT1_CPREFT := ""
							NT1->(MsUnLock())
							NT1->(DbCommit())
							//Grava na fila de sincronizaÁ„o a alteraÁ„o
							J170GRAVA("NT0", xFilial("NT0") + NT1->NT1_CCONTR, "4")
						EndIf

						NX1->(DbSetOrder(3)) // NX1_FILIAL+NX1_CPREFT+NX1_CCONTR+NX1_CCLIEN+NX1_CLOJA+NX1_CCASO
						NX1->(DbSeek(xFilial("NX1") + cPrefat + cContrato + cClien + cLoja))

						NUE->(DbSetOrder(2)) // NUE_FILIAL+NUE_CCLIEN+NUE_CLOJA+NUE_CCASO+NUE_CPREFT
						NUE->(DbSeek(xFilial("NUE") + NX1->(NX1_CCLIEN + NX1_CLOJA + NX1_CCASO )))
						Do While ! NUE->(Eof()) .And. NUE->(NUE_FILIAL + NUE_CCLIEN + NUE_CLOJA + NUE_CCASO) == xFilial("NUE") + NX1->(NX1_CCLIEN + NX1_CLOJA + NX1_CCASO )
							If dDataIni >= NUE->NUE_DATATS .And. dDataFim >= NUE->NUE_DATATS
								NUE->(RecLock('NUE', .F.))
								NUE->NUE_CPREFT := ""
								NUE->NUE_CUSERA := JurUsuario(__CUSERID)
								NUE->NUE_ALTDT  := Date()
								If lAltHr
									NUE->NUE_ALTHR  := Time()
								EndIf
								NUE->(MsUnLock())
								NUE->(DbCommit())
								//Grava na fila de sincronizaÁ„o a alteraÁ„o
								J170GRAVA("NUE", xFilial("NUE") + NUE->NUE_COD, "4")
							EndIf

							NUE->(DbSkip())
						EndDo

						JACanVinc("FX", cPrefat, cParcela ) // Cancela o vÌnculo da parcela com a prÈ-fatura
						JACanVinc("TS", cPrefat, cParcela ) // Cancela o vÌnculo da parcela com TimeSheet

						JAUSALANC('NT1', cParcela, '3', cWoCodig, __CUSERID, aIncLanc) // Cria o histÛrico de WO de Fixo
					EndIf
					lRet := .T.
				Else
					lRet := .F.
				EndIf
			Else
				If ApMsgYesNo(STR0180 + AllTrim(cParcela) + STR0181 + AllTrim(cPrefat) + STR0182 + AllTrim(JurSitGet(NX0->NX0_SITUAC)) + STR0188) // "A parcela '" ### "' est· vinculada a prÈ-fatura '" ### "' com a situaÁ„o '" ### "', a situaÁ„o da prÈ-fatura ficar· como alterada! Deseja continuar?î
					aIncLanc := {}
					NT1->( dbSetOrder( 1 ) ) //NT1_FILIAL+NT1_SEQUEN
					If NT1->( dbseek( xFilial('NT1') + cParcela ) )
						Aadd(aIncLanc, NT1->NT1_CMOEDA)
						RecLock('NT1', .F.)
						NT1->NT1_SITUAC := "2"
						NT1->NT1_CPREFT := ""
						NT1->(MsUnLock())
						NT1->(DbCommit())
						// Grava na fila de sincronizaÁ„o a alteraÁ„o
						J170GRAVA("NT0", xFilial("NT0") + NT1->NT1_CCONTR, "4")
					EndIf

					If JA202CANPF(cPrefat)
						J202HIST('5', cPrefat, JurUsuario(__CUSERID)) // Insere o HistÛrico na prÈ-fatura
					EndIf

					If lTela
						ApMsgStop( I18N(STR0178, {cPrefat}) ) // # "A prÈ-fatura #1 foi cancelada por n„o conter mais lanÁamentos."
					EndIf

					JACanVinc("FX", cPrefat, cParcela ) // Cancela o vÌnculo da parcela com a prÈ-fatura

					JAUSALANC('NT1', cParcela, '3', cWoCodig, __CUSERID, aIncLanc) // Cria o histÛrico de WO de Fixo
					lRet := .T.
				Else
					lRet := .F.
				EndIf
			EndIf
			
			If lRet
				// Cancela as minutas da prÈ-fatura
				J202CanMin(cPrefat, I18N(STR0247, {cTpLanc} )) //#"Inclus„o de WO - #1. "
			EndIf

		ElseIf NX0->NX0_SITUAC $ '4|5|6|7|9|A|B' //Emitir Minuta | Minuta Emitida | Minuta Cancelada | Minuta SÛcio | Minuta SÛcio Emitida | Minuta SÛcio Cancelada
			If lTela
				ApMsgStop( I18N(STR0177 + CRLF, {cParcela, cPrefat, JurSitGet(NX0->NX0_SITUAC)}) ) //# "A parcela '#1' est· vinculada a prÈ-fatura '#2' com a situaÁ„o '#3' e n„o poder· realizar o WO!
			EndIf
			lRet := .F.

		EndIf
	EndIf
ElseIf !lIsJ202
	aIncLanc := {}
	NT1->( dbSetOrder( 1 ) ) //NT1_FILIAL+NT1_SEQUEN
	If NT1->( dbseek( xFilial('NT1') + cParcela ) )
		Aadd(aIncLanc, NT1->NT1_CMOEDA)
		RecLock('NT1', .F.)
		NT1->NT1_SITUAC := "2"
		NT1->NT1_CPREFT := ""
		NT1->(MsUnLock())
		NT1->(DbCommit())
		// Grava na fila de sincronizaÁ„o a alteraÁ„o
		J170GRAVA("NT0", xFilial("NT0") + NT1->NT1_CCONTR, "4")
	EndIf

	JAUSALANC('NT1', cParcela, '3', cWoCodig, __CUSERID, aIncLanc) //cria o histÛrico de WO de Fixo
	lRet := .T.

EndIf

RestArea(aAreaNT1)
RestArea(aAreaNX0)
RestArea(aArea)
RestOrd(aOrd)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA096SDLIM
Retorna o saldo disponivel do valor limite

@Return nSaldo

@author Jacques Alves Xavier
@since 03/03/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA096SDLIM()
Local aArea    := GetArea()
Local nSaldo   := 0

	If !Empty(FwFldGet('NT0_CMOELI')) .And. !Empty(FwFldGet('NT0_VLRLI'))
		nSaldo := J201GSldLm(FwFldGet('NT0_COD'), '2', , .T.)
	EndIf

RestArea(aArea)

Return nSaldo

//-------------------------------------------------------------------
/*/{Protheus.doc} J096ValDiv
FunÁ„o utilizada para validar o valor informado do campo NT0_VALDIV

@Return lRet	 	.T./.F. As informaÁıes s„o v·lidas ou n„o

@author Paulo Borges
@since 23-03-11
@version 1.0
/*/
//-------------------------------------------------------------------
Function J096ValDiv()
Local lRet  := .T.

If FwFldGet("NXP_PERCEN") > 100
	lRet := JurMsgErro(STR0111) // "O valor de percentual n„o pode ser maior que 100%"
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096GerNT1
Permite ou nao a inclusao de nova parcela na NT1 sob certas condicoes

@Return lRet	 	.T. -> Permite   -  .F. -> Nao permite

@author Ricardo Camargo
@since 25-04-11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096GerNT1( cCodHon, cNT0Parce, cEncCobH )
Local lRet  := .T.
Local aArea := GetArea()

// Verifica se foi encerrado a cobranca de honorarios no contrato
If cEncCobH == "1"

	// Verifica se tipo de honorarios e fixo
	If JUR96TPFIX( cCodHon )

		// Verifica se Gera parcela automatica
		NRA->( dbSetOrder( 1 ) )
		If NRA->(dbSeek(xFilial('NRA')+cCodHon)) .And. NRA->NRA_PARCAT == '1'
			// Verifica a config. PARCELAR
			If cNT0Parce == "2"
				lRet := .F.
			EndIf
		EndIf

	EndIf

EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA096DePar
Funcao utilizada para retornar a descricao da parcela conforme o
idioma informado

@Return cRet

@author Daniel Magalhaes
@since 26/04/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA096DePar(cCodNXK, cIdioma)
Local aArea := GetArea()
Local cRet  := ""

Default cCodNXK := ""
Default cIdioma := ""

cRet := Alltrim(JurGetDados("NXL", 3, xFilial("NXL") + cCodNXK + cIdioma, "NXL_DESC"))

RestArea( aArea )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096Active
Funcao executada na ativacao do modelo

@Return Nil

@sample oModel:SetActivate( {|oModel| J070Active(oModel)} )

@author Daniel Magalhaes
@since 12/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J096Active( oModel )
Local lRet := .T.

Default oModel := FWModelActive()

JA096SGCAS( oModel )

J96GetCli( oModel )

J096CPYCnt( oModel ) //atualiza o conteudo do array _aCnt096

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J96GetCli
Preenche os campos de Grupo de Clientes, Cod Cliente e Loja
quando chamado a partir da rotina JURA070 (Cad Contratos)

@Return Nil

@sample J96GetCli( oModel )

@author Daniel Magalhaes
@since 12/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J96GetCli( oModel )
Local oModelNT0  := Nil
Local nOperation := 0

Default oModel := FWModelActive()

nOperation := oModel:GetOperation()

If nOperation == OP_INCLUIR .Or. nOperation == OP_ALTERAR
	oModelNT0 := oModel:GetModel("NT0MASTER")
	
	If IsInCallStack("JURA070")
		If !Empty(_J70GrpCli)
			oModelNT0:SetValue("NT0_CGRPCL", _J70GrpCli)
		EndIf

		If !Empty(_J70CodCli) .And. !Empty(_J70LojCli)
			oModelNT0:SetValue("NT0_CCLIEN", _J70CodCli)
			oModelNT0:SetValue("NT0_CLOJA", _J70LojCli)
		EndIf
	EndIf

EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J96SetVar
Configura as variaveis estaticas passadas por parametro

@Return Nil

@sample J96SetVar("_J70GrpCli","000011")

@author Daniel Magalhaes
@since 12/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J96SetVar(cNomVar,xValue)

&(cNomVar) := xValue

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J096When
Configura o modo de edicao dos campos (X3_WHEN)

@Return Nil

@sample J096When("NT0_CGRPCL")

@author Daniel Magalhaes
@since 12/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J096When( cCampo )
Local lRet := .T.

cCampo := AllTrim(cCampo)

Do Case
Case cCampo == "NT0_CGRPCL"
	lRet := !IsInCallStack("JURA070") .Or. IsInCallStack("J96GETCLI")
Case cCampo == "NT0_CCLIEN"
	lRet := !IsInCallStack("JURA070") .Or. IsInCallStack("J96GETCLI")
Case cCampo == "NT0_CLOJA"
	lRet := !IsInCallStack("JURA070") .Or. IsInCallStack("J96GETCLI")
Case cCampo == "NT0_DESPAD"
	lRet := J096CHon()
Otherwise
	lRet := .T.
EndCase

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096Parcela(oModel, nBotaoAtv)
Rotina para gerar parcela na Cond. Faturamento

@param nBotaoAtv = Referente ao campo NTH_BOTAO
                     1 = CondiÁıes de Faturamento de Fixo
                     2 = Faixa de Valores

@Return lRet

@obs FunÁ„o chamada na AutomaÁ„o.

@author Tiago Martins
@since 22/09/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J096Parcela(oModel, nBotaoAtv)
Local lRet       := .T.
Local oModelNT1  := oModel:GetModel('NT1DETAIL')
Local oModelNT0  := oModel:GetModel('NT0MASTER')
Local aSaveLn    := FWSaveRows()
Local lGeraParc  := .F.
Local lNewLine   := .F.
Local nI         := 0
Local nA         := 0
Local cCTPHON    := oModelNT0:GetValue('NT0_CTPHON')
Local nAt        := aScan( aCpoBotoes, { |x| x[CTPHON] == cCTPHON .AND. X[BOTAO] == nBotaoAtv} )
Local cNT0Parce  := ''
Local cNT0Ench   := oModelNT0:GetValue('NT0_ENCH')
Local nQtdLine   := 0
Local aCpoGrd    := {}
Local nNumParc   := 0
Local nParcMax   := 0
Local nNT0QtPar  := oModelNT0:GetValue('NT0_QTPARC')
Local nPerFix    := oModelNT0:GetValue('NT0_PERFIX') 
Local cDescPar   := ""
Local lFimDtRef  := .T. //Controle do while na geraÁ„o de parcelas
Local dDataIni   := CToD(' / / ') //Data de referencia inicial para geraÁ„o de parcelas
Local dDataFim   := CToD(' / / ') //Data de referencia final para geraÁ„o de parcelas
Local dDataVenc  := CToD(' / / ') //Data de vencimento das parcelas
Local lDt        := .T.
Local lDesc      := .F. //Verifica se h· desconto para os tipos de excedente Valor dos tipos de honor·rios MÌnimo e Misto
Local cCodTpFat  := ""
Local cMoeFixo   := ""
Local lParNT1    := .F.
Local dNT1Data   := CToD(' / / ')
Local dDtVenc    := CToD(' / / ')
Local nVlrbase   := 0
Local cCampo     := ""
Local oView      := FwViewActive()
Local nTamParc   := TamSX3("NT1_PARC")[1]

Private CINSTANC := ""

If lRet
	For nI := 1 To Len( aCpoBotoes[nAt][CONFIG] )

		cCampo := AllTrim( aCpoBotoes[nAt][CONFIG][nI][CAMPO] )

		If cCampo == 'NT0_PERCD' .And. aCpoBotoes[nAt][CONFIG][nI][VISIV]
			Iif(oModelNT0:GetValue('NT0_PERCD') <> 0, lDesc := .T., lDesc := .F. )
		EndIf

		If (cCampo == 'NT0_DTREFI' .Or. cCampo == 'NT0_DTVENC') .And. !aCpoBotoes[nAt][CONFIG][nI][VISIV] //Analisa se os campos de Data est„o visÌveis
			lDt := .F.
		EndIf

		IIF(cCampo == 'NT0_PARCE', cNT0Parce := Eval(aCpoBotoes[nAt][CONFIG][nI][INICIA]), "")//Obtenho o "PARCELAR?" Sim ou N„o

		nPerFix := oModelNT0:GetValue( 'NT0_PERFIX' )
		If cCampo == 'NT0_PERFIX' .And. aCpoBotoes[nAt][CONFIG][nI][VISIV] //Se campo È Visivel entro com dados da tela (evitar erro com criaÁ„o de datas)
			If oModelNT0:GetValue(  'NT0_PERFIX' ) == 0
				MsgInfo(STR0171) //"Informe a periodicidade das parcelas."
				lRet:= .F.
				Exit
			EndIf
		EndIf 

		If cCampo == 'NT0_PEREX' .And. aCpoBotoes[nAt][CONFIG][nI][OBRIGA]
			If oModelNT0:GetValue(  'NT0_PEREX' ) == 0
				MsgInfo(STR0193) //"A periodicidade de excedente deve ser preenchida. Verifique!"
				lRet := .F.
				Exit
			ElseIf !Empty(oModelNT0:GetValue( 'NT0_PERFIX' )) .And. (oModelNT0:GetValue( 'NT0_PERFIX' ) > oModelNT0:GetValue( 'NT0_PEREX' ))
				MsgInfo(STR0192) //"A periodicidade de cobranÁa n„o pode ser maior do que a periodicidade de excedente. Verifique!"
				lRet := .F.
				Exit
			EndIf
		EndIf

		nNT0QtPar := oModelNT0:GetValue( 'NT0_QTPARC' )
		If cCampo == 'NT0_QTPARC' .And. aCpoBotoes[nAt][CONFIG][nI][OBRIGA] //Se campo È Visivel entro com dados da tela (evitar erro com criaÁ„o de datas)
			If nNT0QtPar == 0
				MsgInfo(STR0172) //"Informe a quantidade de parcelas."
				lRet := .F.
				Exit
			EndIf
		EndIf

		If cCampo == 'NT0_VLRBAS' .And. aCpoBotoes[nAt][CONFIG][nI][VISIV]
			nVlrbase := oModelNT0:GetValue('NT0_VLRBAS')
			If nVlrbase == 0
				MsgInfo(STR0173) //"Informe o valor base da parcela."
				lRet := .F.
				Exit
			ElseIf oModelNT0:GetValue('NT0_FIXEXC') == '2' .And. !Empty(oModelNT0:GetValue('NT0_PEREX')) .And. !Empty(oModelNT0:GetValue('NT0_PERFIX')) //Para c·lculo do valor da parcela de Misto
				nVlrbase := oModelNT0:GetValue('NT0_VLRBAS') / (oModelNT0:GetValue('NT0_PEREX') / oModelNT0:GetValue('NT0_PERFIX'))
			EndIf
			If lDesc
				nVlrbase := nVlrbase - ( nVlrbase * ( oModelNT0:GetValue('NT0_PERCD') / 100 ) )
			EndIf
		EndIf

		cMoeFixo := oModelNT0:GetValue('NT0_CMOEF')
		If cCampo == 'NT0_CMOEF' .And. aCpoBotoes[nAt][CONFIG][nI][OBRIGA]
			If Empty(cMoeFixo)
				MsgInfo(STR0174) //"Informe o valor base da parcela."
				lRet:=.F.
				Exit
			EndIf
		EndIf
	Next

EndIf

// Verifica se o tipo de honor·rios È fixo e autom·tico
If  lRet .And. JUR96TPFIX(cCTPHON)
	//Utilizado para criar o item de parcela automatica no formulario

	nQtdLine := oModelNT1:GetQtdLine()

	//Verifica a existÍncia de parcelas pendentes
	lGeraParc := .T.
	lNewLine  := .F.

	If !oModelNT1:IsEmpty()

		oModelNT1:GoLine(nQtdLine)

		cCodTpFat := oModelNT1:GetValue("NT1_CTPFTU")
		
		For nI := 1 To nQtdLine
			If !oModelNT1:IsDeleted(nI)

				If oModelNT1:GetValue("NT1_SITUAC", nI) == "1"
					lGeraParc := .F.
					Exit
				Else
					lParNT1  := .T.
				EndIf

				If cCodTpFat != oModelNT1:GetValue("NT1_CTPFTU", nI)
					cCodTpFat := ""
				EndIf

				nNumParc := Val(oModelNT1:GetValue("NT1_PARC", nI))
				If nParcMax < nNumParc
					nParcMax := nNumParc
					//Verifica a data da maior Parcela
					dNT1Data := oModelNT1:GetValue("NT1_DATAIN", nI)
					dDtVenc  := oModelNT1:GetValue( "NT1_DATAVE", nI )
				EndIf
			EndIf
		Next

	Else
		lNewLine := .T.
	EndIf

	If J96TPHPAut(cCTPHON) .And. cNT0Parce == '2'  //Se for parcelas Autom·tica e Tipo Hono for Parcelar?=2(N„o), considerar 1 parcela
		nNT0QtPar := 1
	EndIf

	//Se n„o existirem parcelas pendentes, gera parcela autom·tica
	If lGeraParc .and. J096GerNT1( cCTPHON, cNT0Parce, cNT0Ench )

		//CondiÁ„o para saida do loop abaixo
		lFimDtRef := .T.

		nNumParc := Strzero( nParcMax, nTamParc )

		//Start das datas de referencia e vencimento
		If lDt
			//Caso existam parcelas j· concluÌdas
			If lParNT1

				dDataIni  := STOD(JurDtAdd(DToS(dNT1Data), 'M', 1 ))
				dDataFim  := lastday(stod( JurDtAdd( DTOS(dDataIni) , "M", 0 ) ))
				dDataVenc := STOD(JurDtAdd(DToS(dDtVenc), 'M', 1 ))

			Else

				dDataIni := ctod( "01/" + strzero( month( oModelNT0:GetValue( "NT0_DTREFI" ) ), 2 ) + "/" +  ;
							substr( str( year( oModelNT0:GetValue( "NT0_DTREFI" ) ), 4 ), 3, 2 ) )
				
				If !Empty(dDataIni)
					dDataFim  := lastday(stod( JurDtAdd( dDataIni , "M", nPerFix-1 ) ))
				EndIf
				dDataVenc := oModelNT0:GetValue( "NT0_DTVENC" )

			Endif

			If oModelNT0:GetValue("NT0_DTVENC") < oModelNT0:GetValue("NT0_DTREFI")
				ApMsgInfo(STR0189) // " A primeira data de vencimento deve ser a partir da data de referÍncia inicial. "
				lRet:=.F.
			EndIf
		Else
			dDataIni := dDataFim := dDataVenc := CToD(' / / ')
		EndIf

		//GeraÁ„o das parcelas na tabela NT1
		If lRet
			For nA := 1 To nNT0QtPar
				
				lRet := J096VldData(dDataIni, dDataFim, Strzero( nA, nTamParc ))
				If !lRet
					oView:Refresh('NT1DETAIL')
					Exit
				EndIf

				//Verifica se a proxima data de referencia final ultrapassa a data de referencia digitada  OU  se deve gerar apenas uma parcela

				//ForÁa liberaÁ„o de ediÁ„o no modelo NT1
				J096SetNo( oModelNT1, .F. )

				//Controle de numercaÁ„o das parcelas
				nNumParc := Soma1(nNumParc)

				If !Empty(oModelNT0:GetValue( "NT0_DESPAR" )) .And. !Empty(oModelNT0:GetValue( "NT0_CIDIO" ))
					cDescPar := JA096DePar(oModelNT0:GetValue( "NT0_DESPAR" ), oModelNT0:GetValue( "NT0_CIDIO" ))
				Else
					cDescPar := STR0041 + nNumParc //Parcela XXXX
				EndIf

				aCpoGrd := {}

				aAdd( aCpoGrd, { 'NT1_PARC'  , nNumParc  } )
				aAdd( aCpoGrd, { 'NT1_CTPFTU', Space(TamSx3('NT1_CTPFTU')[1])})
				aAdd( aCpoGrd, { 'NT1_DATAIN', dDataIni  } )
				aAdd( aCpoGrd, { 'NT1_DATAFI', dDataFim  } )
				aAdd( aCpoGrd, { 'NT1_VALORB', nVlrbase  } )
				aAdd( aCpoGrd, { 'NT1_VALORA', nVlrbase  } )
				aAdd( aCpoGrd, { 'NT1_DATAAT', Date()    } )
				aAdd( aCpoGrd, { 'NT1_DATAVE', dDataVenc } )
				aAdd( aCpoGrd, { 'NT1_DESCRI', cDescPar  } )
				aAdd( aCpoGrd, { 'NT1_CMOEDA', cMoeFixo  } )
				aAdd( aCpoGrd, { 'NT1_DMOEDA', JurGetDados("CTO", 1, xFilial("CTO") + M->NT0_CMOEF, "CTO_SIMB" )  } )
				aAdd( aCpoGrd, { 'NT1_SITUAC', '1'  } )

				//Adiciona um novo registro
				If ! lNewLine
					oModelNT1:AddLine()
				EndIf

				//Grava conteudos nos campos
				For nI := 1 To Len( aCpoGrd )
					If !(lRet := JurLoadValue(oModelNT1, aCpoGrd[nI,1], , aCpoGrd[nI,2] ))
						Exit
					EndIf
				Next nI

				If lRet .And. Empty(oModelNT1:GetValue("NT1_SEQUEN"))
					lRet := JurLoadValue(oModelNT1, "NT1_SEQUEN", , JurGetNum("NT1","NT1_SEQUEN") )
				EndIf

				If !lRet .or. !oModelNT1:VldData()
					JurShowErro( oModel:GetModel():GetErrormessage() )
					Return lRet
				EndIf
				//Forca o bloqueio de edicao no modelo NT1
				oModelNT1:SetNoUpdateLine(.F.)

				//Acrescenta novos periodos as datas de referencia inicial e final
				If lDt

					dDataIni := ctod( "01/" + strzero( month( stod( JurDtAdd( oModelNT1:GetValue("NT1_DATAFI"), 'M', 1 ) ) ), 2 ) + "/" +  ;
								substr( str( year( stod( JurDtAdd( oModelNT1:GetValue("NT1_DATAFI"), 'M', 1 ) ) ), 4 ), 3, 2 ) )
					dDataVenc := stod( JurDtAdd( oModelNT1:GetValue("NT1_DATAVE"), 'M', nPerFix ) )

					dDataFim := lastday(stod( JurDtAdd( dDataIni , "M", nPerFix-1 ) ))

				Else
					dDataIni := dDataFim := dDataVenc := CToD(' / / ')
				EndIf

				//Permite a insercao de novas linhas na NT1
				lNewLine := .F.

			Next nA
		EndIf

	Else
		ApMsgInfo( I18N(STR0176, {STR0126}) ) //# "Existem parcelas pendentes cadastradas, a opÁ„o '#1' n„o pode mais ser usada."
	Endif

Endif

lCtlCndFat := .F.
FWRestRows( aSaveLn )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096ConfPa(oModel, nBotaoAtv)
Rotina para validar e chama rotina para gerar parcela na Cond. Faturamento atravÈs do bot„o de Confirmar

@param nBotaoAtv = Referente ao campo NTH_BOTAO
                     1 = CondiÁıes de Faturamento de Fixo
                     2 = Faixa de Valores

@Return Nil

@author Tiago Martins
@since 30/09/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096ConfPa(oModel, nBotaoAtv)
Local aSaveLn    := FWSaveRows()
Local oModelNT1  := oModel:GetModel('NT1DETAIL')
Local oModelNT0  := oModel:GetModel('NT0MASTER')
Local cCTPHON    := oModelNT0:GetValue('NT0_CTPHON')
Local nQtdLine   := oModelNT1:GetQtdLine()
Local nQtPendent := 0
Local nI         := 0
Local lAut       := .T. //gera autom·tico

If !oModelNT1:IsEmpty()
	For nI := 1 To nQtdLine
		If !oModelNT1:isDeleted(nI) .And. oModelNT1:GetValue("NT1_SITUAC", nI) == "1" //conta se h· algum pendente
			nQtPendent += 1
		EndIf
	Next
EndIf

If nQtPendent > 0 .And. lCtlCndFat .And. J096VldVlr(oModel, nBotaoAtv)
	If MsgYesNo(STR0129)   //"Houve alteraÁ„o na tela. Deseja salvar a alteraÁ„o?"
		J096Parcela(oModel, nBotaoAtv)
		lAut := .F.
	EndIf
EndIf

If lAut //Gera Autom·tico
	If oModelNT1:IsEmpty() .And. J96TPHPAut(cCTPHON)
		J096Parcela(oModel, nBotaoAtv)
	EndIf
EndIf

FWRestRows(aSaveLn)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J096VldNT1(oModel)
Verifica se os campos ObrigatÛrios na NT1 est„o preenchidos de 
acordo com Tipo Honor·rio

@param oModel, Modelo de dados de Contratos
@param nLine , Linha posicionada no grid de parcelas fixas (NT1)

@return lRet , Indica se os valores s„o v·lidos

@author Tiago Martins
@since  05/10/2011
/*/
//-------------------------------------------------------------------
Static Function J096VldNT1(oModel, nLine)
Local lRet      := .T.
Local cMsgErro  := ''
Local cMsg      := ''
Local oModelNT1 := oModel:GetModel('NT1DETAIL')
Local dDataIni  := oModelNT1:GetValue('NT1_DATAIN', nLine)
Local dDataFim  := oModelNT1:GetValue('NT1_DATAFI', nLine)
Local dDataVenc := oModelNT1:GetValue('NT1_DATAVE', nLine)

	If oModelNT1:GetValue("NT1_SITUAC", nLine) == "1"
		If lRet .And. !Empty(dDataIni) .And. (dDataFim < dDataIni)
			cMsgErro += "-" + STR0095 + CRLF // "A data final deve ser maior que a data inicial."
			lRet := .F.
		EndIf

		If lRet .And. !Empty(dDataIni) .And. !Empty(dDataVenc) .And. (dDataVenc < dDataIni)
			cMsgErro += "-" + STR0189 + CRLF // "A primeira data de vencimento deve ser a partir da data de referÍncia inicial. " // STR0130 + CRLF	 // "A primeira data de vencimento deve ser a partir do mÍs seguinte ao da Data de ReferÍncia Final"
			lRet := .F.
		EndIf
	EndIf

	If !Empty(cMsgErro)
		cMsg += STR0133 + oModelNT1:GetValue('NT1_PARC', nLine) + ":" + CRLF + cMsgErro // "Erro na parcela "
		JurMsgErro(cMsg)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096EdtNT1(oModel)
Verifica se Tipo Hono È Parcelas Autom·ticas, se Sim habilita EdiÁ„o do Grid NT1

@author Tiago Martins
@since 18/10/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096EdtNT1(oModel)
Local oModelNT1  := oModel:GetModel('NT1DETAIL')
Local oStructNT1 := oModelNT1:GetStruct()
Local cTpHon     := oModel:GetValue('NT0MASTER', 'NT0_CTPHON')

oStructNT1:setProperty("*", MODEL_FIELD_WHEN, {|| .F.}) //Bloqueia todas colunas

oStructNT1:setProperty("NT1_CCONTR", MODEL_FIELD_WHEN, {|model| !model:isDeleted() .and. model:GetValue("NT1_SITUAC")=="1" })
oStructNT1:setProperty("NT1_CTPFTU", MODEL_FIELD_WHEN, {|model| !model:isDeleted() .and. model:GetValue("NT1_SITUAC")=="1" })
oStructNT1:setProperty("NT1_DTPFTU", MODEL_FIELD_WHEN, {|model| !model:isDeleted() .and. model:GetValue("NT1_SITUAC")=="1" })
oStructNT1:setProperty("NT1_DATAIN", MODEL_FIELD_WHEN, {|model| !model:isDeleted() .and. model:GetValue("NT1_SITUAC")=="1" })
oStructNT1:setProperty("NT1_DATAFI", MODEL_FIELD_WHEN, {|model| !model:isDeleted() .and. model:GetValue("NT1_SITUAC")=="1" })
oStructNT1:setProperty("NT1_DATAVE", MODEL_FIELD_WHEN, {|model| !model:isDeleted() .and. model:GetValue("NT1_SITUAC")=="1" })
oStructNT1:setProperty("NT1_DESCRI", MODEL_FIELD_WHEN, {|model| !model:isDeleted() })

If !J96TPHPAut(cTpHon)//verifica se È Parc. Autom·tica
	oStructNT1:setProperty("NT1_VALORB", MODEL_FIELD_WHEN, {|model| !model:isDeleted() .and. model:GetValue("NT1_SITUAC")=="1" })
	oStructNT1:setProperty("NT1_VALORA", MODEL_FIELD_WHEN, {|model| !model:isDeleted() .and. model:GetValue("NT1_SITUAC")=="1" }) //Se desabilitar pelo When n„o poder· gatilhar.
	oModelNT1:SetNoUpdateLine(.F.)
Else
	oModelNT1:SetNoUpdateLine(.F.)
EndIF

J96AltParc(oModel) //Habilita alteraÁ„o manual da parcela de fixo.

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J096ArmzNT0(oModel)
Armazena dados da tela Cond Faturamento NT0 em Array

@param nBotaoAtv = Referente ao campo NTH_BOTAO
                     1 = CondiÁıes de Faturamento de Fixo
                     2 = Faixa de Valores

@author Tiago Martins
@since 04/11/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096ArmzNT0(oModel, nBotaoAtv)
Local oModelNT0 := oModel:GetModel("NT0MASTER")
Local cCTPHON   := oModelNT0:GetValue('NT0_CTPHON')
Local nAt       := aScan( aCpoBotoes, { |x| x[CTPHON] == cCTPHON .AND. X[BOTAO] == nBotaoAtv} )
Local aCpoGrd   := {}
Local nI        := 0

For nI := 1 to Len(aCpoBotoes[nAt][CONFIG])
	If aCpoBotoes[nAt][CONFIG][nI][VISIV]
		aAdd( aCpoGrd, {aCpoBotoes[nAt][CONFIG][nI][CAMPO], FwFldGet( aCpoBotoes[nAt][CONFIG][nI][CAMPO] ) } ) //[CampoNT0, Valor]
	EndIf
Next

Return aCpoGrd

//-------------------------------------------------------------------
/*/{Protheus.doc} J096VldVlr(oModel, nBotaoAtv)
Valida os Valores do NT1 para confirmar se houve alteraÁ„o do Grid NT1

@param nBotaoAtv = Referente ao campo NTH_BOTAO
                     1 = CondiÁıes de Faturamento de Fixo
                     2 = Faixa de Valores
@Return lRet		Se .T. È que houve alteraÁ„o no campo NT0 da Cond. Faturamento

@author Tiago Martins
@since 04/11/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096VldVlr(oModel, nBotaoAtv)
Local lRet      := .F.
Local oModelNT0 := oModel:GetModel("NT0MASTER")
Local cCTPHON   := oModelNT0:GetValue('NT0_CTPHON')
Local nAt       := aScan( aCpoBotoes, { |x| x[CTPHON] == cCTPHON .AND. X[BOTAO] == nBotaoAtv} )
Local nI        := 0
Local nA        := 0

For nI := 1 To Len(aCpoBotoes[nAt][CONFIG])
	If aCpoBotoes[nAt][CONFIG][nI][VISIV]
		For nA:=1 To Len(aArmzNT0)
			If aCpoBotoes[nAt][CONFIG][nI][CAMPO] ==  aArmzNT0[nA][1];
					.And. FwFldGet( aCpoBotoes[nAt][CONFIG][nI][CAMPO] ) != aArmzNT0[nA][2] //Campara os Campos & os Valores
				lRet = .T.
				Exit
			EndIf
		Next
		If lRet
			Exit
		EndIf
	EndIf
Next

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096VlDtNT1(oModel)
Valida as Datas do NT1 para confirmar se houve alteraÁ„o do Grid NT1

@Return lRet		Se .T. È que houve alteraÁ„o no campo NT0 da Cond. Faturamento

@author Tiago Martins
@since 04/11/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096VlDtNT1(oModel)
Local lRet      := .T.
Local nLine     := 0
Local oModelNT1 := oModel:GetModel('NT1DETAIL')
Local cTpHon    := oModel:GetModel('NT0MASTER'):GetValue('NT0_CTPHON')
Local nQtdLine  := oModelNT1:GetQtdLine()

If JUR96TPFIX(cTpHon) .And. !J96TPHPAut(cTpHon) // Se tiver fixo, valida se os campos est„o preenchidos
	For nLine := 1 To nQtdLine
		If !oModelNT1:IsDeleted(nLine)
			lRet := J096VldNT1(oModel, nLine) // Verifica se os campos ObrigatÛrios na NT1 est„o preenchidos de acordo com Tipo Honor·rio
			If !lRet
				Exit
			EndIf
		EndIf
	Next
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096DesCs()
Aplica o desconto nos casos do contrato

@Return lRet	.T. se  efetuado as alteraÁıes nos casos do contrato

@author Luciano Pereira dos Santos
@since 21/12/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096DesCs(oModel, aNUT)
Local lRet       := .T.
Local aArea      := GetArea()
Local oModelNT0  := oModel:GetModel('NT0MASTER')
Local nDesPad    := oModelNT0:GetValue("NT0_DESPAD")
Local oModelNUT  := oModel:GetModel('NUTDETAIL')
Local nLine      := oModelNUT:GetLine()
Local nQtdNUT    := oModelNUT:GetQtdLine()
Local cClient    := ""
Local cLoja      := ""
Local cCaso      := ""
Local nI         := 0
Local cMemoCab   := (STR0146 + CRLF + CRLF) //"O desconto n„o pode ser alterado no(s) caso(s): "
Local cMemoErr   := ""

Default aNUT     := {}

If Len(aNUT) == 0
	For nI := 1 To nQtdNUT
		If !oModelNUT:IsDeleted(nI) .And. !Empty(oModelNUT:GetValue("NUT_CCASO", nI ))
			cClient := oModelNUT:GetValue("NUT_CCLIEN", nI )
			cLoja   := oModelNUT:GetValue("NUT_CLOJA", nI )
			cCaso   := oModelNUT:GetValue("NUT_CCASO", nI )

			cMemoErr += J096GrDCas(cClient, cLoja, cCaso, nDesPad, .F.)
		EndIf
	Next nI

Else
	For nI := 1 To Len(aNUT)
		If !oModelNUT:IsDeleted(aNUT[nI])
			cClient := oModelNUT:GetValue("NUT_CCLIEN", aNUT[nI] )
			cLoja   := oModelNUT:GetValue("NUT_CLOJA", aNUT[nI] )
			cCaso   := oModelNUT:GetValue("NUT_CCASO", aNUT[nI] )

			cMemoErr += J096GrDCas(cClient, cLoja, cCaso, nDesPad, .F.)
		EndIf
	Next nI

EndIf

oModelNUT:GoLine(nLine)

RestArea( aArea )

If !Empty(cMemoErr)
	JurErrLog(cMemoCab + cMemoErr, STR0146) //"AlteraÁ„o de desconto"
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA096VLIM()
ValidaÁ„o do valor limite

@Return lRet	.T. se  o valor e maior ou igual ao valor faturado

@author Luciano Pereira dos Santos
@since 30/01/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA096VLIM()
Local lRet      := .T.
Local nValorLim := 0
Local nSaldoIni := 0

If IsInCallStack( 'JURA096' )
	nValorLim := FwFldGet('NT0_VLRLI')
	nSaldoIni := FwFldGet('NT0_SALDOI')
	If nValorLim < nSaldoIni
		lRet := JurMsgErro(STR0138) // "O Valor Limite do contrato n„o pode ser menor que o saldo inicial!"
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096NVENUT
Consulta padr„o de casos do contrato filtrando pelo cliente, loja ou
grupo do contrato

@Return lRet	 	.T./.F. As informaÁıes s„o v·lidas ou n„o

@author Juliana Iwayama Velho
@since 27/01/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function J096NVENUT()
Local xRet      := Nil
Local lOldSXB   := GetSx3Cache('NUT_CCASO', 'X3_F3') == 'NVENUT'
Local aArea     := GetArea()
Local aFiltro   := {}
Local aSearch   := {}
Local aCampos   := {}

J70SetVar( "_J96GrpCli", FwFldGet("NT0_CGRPCL") )
J70SetVar( "_J96CodCli", FwFldGet("NT0_CCLIEN") )
J70SetVar( "_J96LojCli", FwFldGet("NT0_CLOJA")  )

If lOldSXB //ProteÁ„o 12.1.14
	/* Filtro
	[1] CondiÁ„o para adicionar o filtro ou n„o
	[2] Tipo = A(Comando ADVPL) / S(Comando SQL)
	[3] Titulo do filtro
	[4] Comando
	[5] Tabela para filtro relacional (apenas para comando SQL)
	*/
	aSearch := {{'NVE_CCLIEN',1},{'NVE_NUMCAS',3},{'NVE_TITULO',4}} //Campos para pesquisa e indice
	aCampos := {'NVE_NUMCAS','NVE_TITULO'}  //Campos de colunas

	aAdd( aFiltro, {_cNumClien == "1" .And. !Empty(FwFldGet('NUT_CCLIEN')) .And. !Empty(FwFldGet('NUT_CLOJA')), 'A', STR0140,;
					"NVE_CCLIEN == '"+ FwFldGet('NUT_CCLIEN') +"' .AND. NVE_LCLIEN == '" + FwFldGet('NUT_CLOJA') + "' .AND. NVE_COBRAV == '1'"} )
	aAdd( aFiltro, {_cNumClien == "2" .And. !Empty(FwFldGet('NT0_CGRPCL')), 'A', STR0142, "NVE_COBRAV == '1'"} )

	xRet := .F.
	If JurF3Tab( aSearch, 'NVE', aFiltro, aCampos, 'JURA070' )
		xRet := .T.
	EndIf
Else
	 xRet  := ".T."
	If !Empty(FwFldGet('NUT_CCLIEN'))
		xRet  += " .AND. NVE_CCLIEN == '" + FwFldGet('NUT_CCLIEN') + "'"
	EndIf

	If !Empty(FwFldGet('NUT_CLOJA'))
		xRet  += " .AND. NVE_LCLIEN == '" + FwFldGet('NUT_CLOJA') + "'"
	EndIf
	RestArea( aArea )
EndIf

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096VerCli
Verifica se o campo de cliente do contrato est· preenchido para habilitar
campos de casos

@author Juliana Iwayama Vrlho
@since 01/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function J096VerCli()
Local lRet      := .T.
Local oModel    := FwModelActive()
Local oModelNT0 := oModel:GetModel("NT0MASTER")

	If IsInCallStack('JURA096')
		If lRet .And. (oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4)
			 If Empty(oModelNT0:GetValue("NT0_CCLIEN")) .Or. Empty(oModelNT0:GetValue("NT0_CLOJA"))
				lRet := .F.
			EndIf
		Endif
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096RetRecno
Retorna o Recno para que seja feita a rotina de anexos

@author Jorge Luis Branco Martins Junior
@since 22/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096RetRecno(cCod)

JURGETDADOS('NT0', 1, xFilial('NT0') + FwfldGet(cCod), 'NT0_COD')

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J096CHon()
Verifica se o contrato cobra honorarios

@Return lRet	.T. se o tipo de honorarios cobrar hora

@author Luciano Pereira dos Santos
@since 28/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function J096CHon(cTipHon)
Local lRet      := .T.
Local aArea     := GetArea()

Default cTipHon := M->NT0_CTPHON

If !Empty(cTipHon)
	NRA->(dbSetOrder(1))
	NRA->(dbSeek(xFilial('NRA') + cTipHon))
	lRet := NRA->NRA_COBRAH == '1'
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096CPYCnt(oModel)
Rotina para guardar as informaÁıes dos campos do contrato.

@param  oModel  Modelo de dados

@return Nil

@author Luciano Pereira dos Santos
@since 28/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096CPYCnt( oModel )
Local oModelNT0   := oModel:GetModel("NT0MASTER")
Local aStrucNT0   := oModelNT0:oFormModelStruct:GetFields()

_aCnt096 := {} //private da rotina JURA096

AEval(aStrucNT0, {|aCpo| Aadd(_aCnt096, {aCpo[MODEL_FIELD_IDFIELD], oModelNT0:GetValue(aCpo[MODEL_FIELD_IDFIELD])}) })

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J096CntVl()
Retorna o valor do campo guardado no array de _aCnt096

@author Luciano Pereira dos Santos
@since 29/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096CntVl(cCampo)
Local aSaveLines := FWSaveRows()
Local oModel     := FwModelActive()
Local oModelNT0  := oModel:GetModel("NT0MASTER")
Local nPos       := 0
Local uValor     := Nil

If oModel:GetOperation() != OP_INCLUIR
	nPos := aScan( _aCnt096, { |x| x[1] == cCampo} )
	uValor := _aCnt096[nPos][2]
Else
	uValor := oModelNT0:GetValue(cCampo)
EndIf

FWRestRows( aSaveLines )

Return uValor

//-------------------------------------------------------------------
/*/{Protheus.doc} J096GrDCas()
Grava o valor do desconto na tabela de casos

@author Luciano Pereira dos Santos
@since 29/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096GrDCas(cClient, cLoja, cCaso, nDesPad, lNewCaso)
Local cRet      := ""
Local lRet      := .T.
Local aArea     := GetArea()
Local lGravDif  := .T.
Local lGravIgl  := .T.

Default lNewCaso := .F.

NVE->( dbSetOrder( 1 ) ) //NVE_FILIAL+NVE_CCLIEN+NVE_LCLIEN+NVE_NUMCAS
If NVE->( dbSeek( xFilial('NVE') + cClient + cLoja + cCaso ) )

	lGravDif := (NVE->NVE_DESPAD != J096CntVl("NT0_DESPAD")) .And. (NVE->NVE_DESPAD != nDesPad)
	lGravIgl := (NVE->NVE_DESPAD == J096CntVl("NT0_DESPAD")) .And. (NVE->NVE_DESPAD != nDesPad) .Or. lNewCaso

	If lGravDif .And. lNewCaso // se o desconto for diferente e for um casso novo
		If MsgYesNo(STR0060 + (NVE->NVE_NUMCAS) + STR0143 + Transform(NVE->NVE_DESPAD, "@E 999.99999999") + STR0144) //'O caso ' ## " esta com o desconto de " ## ". Deseja substituir o desconto?"
			RecLock("NVE", .F.)
			NVE->NVE_DESPAD := nDesPad
			NVE->(MsUnlock())
			NVE->(DbCommit())
			//Grava na fila de sincronizaÁ„o a alteraÁ„o
			J170GRAVA("NVE", xFilial("NVE") + NVE->NVE_CCLIEN + NVE->NVE_LCLIEN + NVE->NVE_NUMCAS, "4")
		EndIf
	ElseIf lGravIgl  //se for um desconto igual ao do contrato replica a alteraÁ„o
		RecLock("NVE", .F.)
		NVE->NVE_DESPAD := nDesPad
		NVE->(MsUnlock())
		NVE->(DbCommit())
		//Grava na fila de sincronizaÁ„o a alteraÁ„o
		J170GRAVA("NVE", xFilial("NVE") + NVE->NVE_CCLIEN + NVE->NVE_LCLIEN + NVE->NVE_NUMCAS, "4")
	EndIf
Else
	lRet := .F.
EndIf

If !lRet
	cRet +=( STR0147 + cClient            )+ CRLF //"Cliente : "
	cRet +=( STR0148 + cLoja              )+ CRLF //"Loja ...: "
	cRet +=( STR0149 + cCaso              )+ CRLF //"Caso ...: "
	cRet +=( Replicate('-', LEN(STR0146)) )+ CRLF+CRLF  //"O desconto n„o pÙde ser alterado no(s) caso(s): "
EndIf

RestArea( aArea )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J96VldDsc()
Grava o valor do desconto no caso (validaÁ„o do campo NUT_CCASO)

@author Luciano Pereira dos Santos
@since 29/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function J96VldDsc()
Local lRet      := .T.
Local cClient   := ''
Local cLoja     := ''
Local cCaso     := ''
Local nDesPad   := 0
Local aCliLoj   := {}
Local cRet      := ''

If IsInCallStack("JURA096")

	cCaso := FwFldGet("NUT_CCASO")

	If _cNumClien == "1"
		cClient := FwFldGet("NUT_CCLIEN")
		cLoja   := FwFldGet("NUT_CLOJA")
	ElseIf _cNumClien == "2"
		aCliLoj := JCasoAtual(cCaso)
		If !Empty(aCliLoj)
			cClient := aCliLoj[1][1]
			cLoja   := aCliLoj[1][2]
		EndIf
	EndIf

	If !Empty(cClient) .And. !Empty(cLoja) .And. !Empty(cCaso)
		nDesPad := M->NT0_DESPAD
		cRet := J096GrDCas(cClient, cLoja, cCaso, nDesPad, .T.)
		J96DtRef()
		If !Empty(cRet)
			ApMsgInfo(cRet)
		EndIf
	Else
		cRet := RetTitle("NUT_CCLIEN") + ", " + RetTitle("NUT_CLOJA") + STR0191 + RetTitle("NUT_CCASO") //" e "

		lRet := JurMsgErro(I18N(STR0190, {Iif(_cNumClien == "1", cRet, RetTitle("NUT_CCASO"))})) //#Informe #1.
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J96DtRef(oModel)
Rotina para sugest„o de preenchimento do campo NT0_DTREFI
"Dt ReferÍncia inicial"

@author Luciano Pereira dos Santos
@since 20/04/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J96DtRef()
Local lRet       := .T.
Local oModel     := FwModelActive()
Local oModelNT0  := oModel:GetModel("NT0MASTER")
Local oModelNUT  := Nil
Local dDtRefIni  := CtoD("  /  /     ")
Local dDtCaso    := Date()
Local dDtTroca   := Date()
Local nPos       := 0
Local cClient    := ""
Local cLoja      := ""
Local cCaso      := ""
Local cQuery     := ""
Local aRetDate   := {}

	If JUR96TPFIX(oModelNT0:GetValue("NT0_CTPHON"))

		nPos := aScan(_aCnt096, {|x| x[1] == "NT0_DTREFI"})
		dDtRefIni := IIF(nPos > 0, _aCnt096[nPos][2], oModelNT0:GetValue("NT0_DTREFI"))

		If Empty(dDtRefIni) .And. !oModel:GetModel('NT1DETAIL'):IsEmpty()
			If oModel:GetOperation() == MODEL_OPERATION_UPDATE
				cQuery := "SELECT MIN(NVE_DTENTR) DTENTRCASO "
				cQuery +=   "FROM " + RetSQLName("NUT") + " NUT, " + RetSqlName("NVE") + " NVE "
				cQuery +=  "WHERE NUT_CCONTR = '" + oModelNT0:GetValue("NT0_COD") + "' "
				cQuery +=    "AND NUT.NUT_FILIAL = '" + xFilial("NUT") + "' "
				cQuery +=    "AND NUT.D_E_L_E_T_ = ' ' "
				cQuery +=    "AND NUT.NUT_FILIAL = NVE.NVE_FILIAL "
				cQuery +=    "AND NUT.NUT_CCLIEN = NVE.NVE_CCLIEN "
				cQuery +=    "AND NUT.NUT_CLOJA = NVE.NVE_LCLIEN "
				cQuery +=    "AND NUT.NUT_CCASO = NVE.NVE_NUMCAS "
				cQuery +=    "AND NVE.D_E_L_E_T_ = ' ' "

				aRetDate := JurSQL(cQuery, "*")
				dDtTroca := IIF(Len(aRetDate) > 0, StoD(aRetDate[1][1]), dDtTroca)
			EndIf

			oModelNUT := oModel:GetModel('NUTDETAIL')
			If !oModelNUT:IsDeleted() .And. oModelNUT:IsUpdated()
				cClient := oModelNUT:GetValue("NUT_CCLIEN")
				cLoja   := oModelNUT:GetValue("NUT_CLOJA")
				cCaso   := oModelNUT:GetValue("NUT_CCASO")

				dDtCaso := Posicione("NVE", 1, xFilial('NVE') + cClient + cLoja + cCaso, "NVE_DTENTR")
			EndIf

			If dDtCaso < dDtTroca
				dDtTroca := dDtCaso
			EndIf

			lRet := oModel:LoadValue("NT0MASTER", "NT0_DTREFI", dDtTroca)
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J96AltCtr
Verifica alteracao dos campos que afetam a geracao das pre-faturas

@author Daniel Magalhaes
@since 24/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J96AltCtr(oModel)
Local aArea   := GetArea()
Local aAux    := {}
Local cCpos   := "NT0_CMOE,NT0_CIDIO,NT0_CTPHON,NT0_DESPES,NT0_SERTAB,NT0_DESPAD,NT0_ENCH,NT0_ENCD,NT0_ENCT"
Local cGrids  := "NUTDETAIL,NTJDETAIL,NTKDETAIL,NXPDETAIL"
Local nFor    := 0
Local nQtdMdl := 0
Local lRet    := .F.
Local oMdlAux

aAux := StrTokArr(cCpos, ", ")

For nFor := 1 To Len(aAux)

	If lRet := oModel:IsFieldUpdated( "NT0MASTER", aAux[nFor] )
		Exit
	EndIf

Next nFor

If !lRet
	aAux := StrTokArr(cGrids,",")

	For nFor := 1 To Len(aAux)
		oMdlAux := oModel:GetModel(aAux[nFor])

		nQtdMdl := oMdlAux:GetQtdLine()

		If lRet := ( Len(oMdlAux:GetLinesChanged()) > 0 )
			Exit
		EndIf

	Next nFor

EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA096VE
Valida se na exclus„o de uma parcela de fixo n„o exista registro de faturamento vinculado

@author Jacques Alves Xavier
@since 24/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA096VE(oSubModel, nLinha, cAction, cCampo, xComp, xValue)
Local lRet      := .T.
Local aArea     := GetArea()
Local aAreaNWE  := NWE->( GetArea() )
Local oModel    := FwModelActive()
Local oModelNT0 := oModel:GetModel('NT0MASTER')
Local oModelNT1 := oModel:GetModel('NT1DETAIL')
Local cCTPHON   := oModelNT0:GetValue('NT0_CTPHON')
Local oStrucNT1 := oModelNT1:GetStruct()
Local cMoeda    := ""
Local nValBas   := 0
Local lShowMsg  := .T.

If cAction != "CANSETVALUE"
	If cAction == "SETVALUE" .And. cCampo == "NT1_DESCRI" // Sempre permitir alterar o campo de descriÁ„o da parcela
		lRet := .T.
	ElseIf !J96TPHPAut(cCTPHON)
		NWE->( dbSetOrder(1) )
		NWE->( dbSeek(xFilial("NWE") + oModelNT1:GetValue("NT1_SEQUEN")) )

		While !NWE->( EOF() ) .And. xFilial("NWE") + NWE->NWE_CFIXO == xFilial("NT1") + oModelNT1:GetValue("NT1_SEQUEN")
			If (NWE->NWE_SITUAC == "2" .Or. NWE->NWE_SITUAC == "3") .And. NWE->NWE_CANC == '2'
				lRet := .F.
				Exit
			EndIf

			NWE->( dbSkip() )
		EndDo

		RestArea(aAreaNWE)
	EndIf
ElseIf cAction == "CANSETVALUE" .And. cCampo == "NT1_VALORB" .And. oModelNT1:GetValue("NT1_QTDADE") > 0 .And. JUR96FAIXA(cCTPHON) .And. SuperGetMV("MV_JQTDAUT", .F., "1") == "2"
	lRet     := .F.
	lShowMsg := .F.
EndIf

If lRet
	// Validar e carregar automaticamente no grid a moeda e o simbolo.
	If oModelNT1:GetValue("NT1_SITUAC") == "1"
		If "CANSETVALUE" <> cAction .And. "SETVALUE" <> cAction
			cMoeda  := oModelNT0:GetValue("NT0_CMOEF")
			nValBas := oModelNT0:GetValue("NT0_VLRBAS")

			If !Empty(cMoeda)
				If Empty(oModelNT1:GetValue("NT1_CMOEDA"))  // Alterar a moeda apenas se estiver vazia.
						oModelNT1:SetValue("NT1_CMOEDA", cMoeda )
				EndIf
			EndIf

			If !Empty(nValBas) .And. Empty(oModelNT1:GetValue("NT1_VALORB"))
				oModelNT1:LoadValue("NT1_VALORB", nValBas )
			EndIf

		EndIf

		oStrucNT1:SetProperty( '*' , MODEL_FIELD_WHEN, {|| .T.} ) // Habilita a ediÁ„o dos campos, caso tenham sido bloqueados e a parcela n„o estiver concluida.
	Else
		oStrucNT1:SetProperty( '*'        , MODEL_FIELD_WHEN, {|| .F.} ) // N„o permitir a alteraÁ„o de campos quando uma parcela estiver liquidada.
		oStrucNT1:SetProperty("NT1_DESCRI", MODEL_FIELD_WHEN, {|| .T.} ) // Ser· possÌvel alterar somente a descriÁ„o
	EndIf
EndIf

If !lRet .And. lShowMsg
	JurMsgErro(STR0195) // "OperaÁ„o de AlteraÁ„o/Exclus„o cancelada!"
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA096DESC
Retorna as descriÁıes para os campos virtuais utilizados na rotina

@author Cristina Cintra Santos
@since 29/08/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA096DESC( cCampo )
Local oModel := FwModelActive()
Local cRet   := ""

	Do Case
		Case  "NTK_DTPDSP" $ cCampo
			cRet :=  JurGetDados("NRH", 1, xFilial("NRH") + oModel:GetValue("NTKDETAIL", "NTK_CTPDSP"), "NRH_DESC")

		Case "NXP_DIDIO2" $ cCampo
			cRet :=  JurGetDados("NR1", 1, xFilial("NR1") + oModel:GetValue("NXPDETAIL", "NXP_CIDIO2"), "NR1_DESC")

		Case "NXP_DCARTA" $ cCampo
			cRet :=  JurGetDados("NRG", 1, xFilial("NRG") + oModel:GetValue("NXPDETAIL", "NXP_CCARTA"), "NRG_DESC")

 		Case "NXP_DIDIO" $ cCampo
			cRet :=  JurGetDados("NR1", 1, xFilial("NR1") + oModel:GetValue("NXPDETAIL", "NXP_CIDIO"), "NR1_DESC")

 		Case "NXP_DRELAT" $ cCampo
			cRet :=  JurGetDados("NRJ", 1, xFilial("NRJ") + oModel:GetValue("NXPDETAIL", "NXP_CRELAT"), "NRJ_DESC")

 		Case "NXP_DMOE" $ cCampo
			cRet :=  JurGetDados("CTO", 1, xFilial("CTO") + oModel:GetValue("NXPDETAIL", "NXP_CMOE"), "CTO_SIMB")

 		Case "NXP_DAGENC" $ cCampo
			cRet :=  JurGetDados("SA6", 1, xFilial("SA6") + oModel:GetValue("NXPDETAIL", "NXP_CBANCO") + oModel:GetValue("NXPDETAIL", "NXP_CAGENC") + oModel:GetValue("NXPDETAIL", "NXP_CCONTA"), "A6_NOMEAGE")

 		Case "NXP_DBANCO" $ cCampo
			cRet :=  JurGetDados("SA6", 1, xFilial("SA6") + oModel:GetValue("NXPDETAIL", "NXP_CBANCO") + oModel:GetValue("NXPDETAIL", "NXP_CAGENC") + oModel:GetValue("NXPDETAIL", "NXP_CCONTA"), "A6_NOME")

 		Case "NXP_DCDPGT" $ cCampo
			cRet :=  JurGetDados("SE4", 1, xFilial("SE4") + oModel:GetValue("NXPDETAIL", "NXP_CCDPGT"), "E4_DESCRI")

 		Case "NXP_DCONT" $ cCampo
			cRet :=  JurGetDados("SU5", 1, xFilial("SU5") + oModel:GetValue("NXPDETAIL", "NXP_CCONT"), "U5_CONTAT")

 		Case "NXP_DCLIPG" $ cCampo
			cRet :=  JurGetDados("SA1", 1, xFilial("SA1") + oModel:GetValue("NXPDETAIL", "NXP_CLIPG") + oModel:GetValue("NXPDETAIL", "NXP_LOJAPG"), "A1_NOME")

		Case  "NVN_DCONT" $ cCampo
			cRet :=  JurGetDados("SU5", 1, xFilial("SU5") + oModel:GetValue("NVNDETAIL", "NVN_CCONT"), "U5_CONTAT")

		Case  "NT5_DIDIOM" $ cCampo
			cRet :=  JurGetDados("NR1", 1, xFilial("NR1") + oModel:GetValue("NT5DETAIL", "NT5_CIDIOM"), "NR1_DESC")

		Case  "NTJ_DTPATV" $ cCampo
			cRet :=  JurGetDados("NRC", 1, xFilial("NRC") + oModel:GetValue("NTJDETAIL", "NTJ_CTPATV"), "NRC_DESC")

		Otherwise
			cRet :=  ""
	EndCase

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J96VldTpVl
ValidaÁ„o do campo ìTipo Valorî (NTR_TPVL) do cadastro de Faixa de
Faturamento.

@author Cristina Cintra Santos
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J96VldTpVl()
Local lRet      := .T.
Local cTpHon    := FwFldGet('NT0_CTPHON')
Local oModel    := FWModelActive()
Local cCalFX    := FwFldGet('NT0_CALFX')
Local cTpVl     := FwFldGet('NTR_TPVL')

If !Empty(cCalFX) .Or. (JUR96TPFIX(cTpHon) .And. JUR96FAIXA(cTpHon))
	If cCalFX == '1' .And. ( cTpVl == '2' .Or. cTpVl == '4' )
		lRet := JurMsgErro(STR0165) //Quando utilizado o C·lculo de Faixa 'Valor' sÛ ser„o permitidos os Tipos 1=Valor Fixo e 3=% a Cobrar. Corrija o campo 'Calc Faixa' ou escolha outra opÁ„o no 'Tipo Valor'.
	ElseIf cCalFX == '2' .And. ( cTpVl == '2' )
		lRet := JurMsgErro(STR0166) //Quando utilizado o C·lculo de Faixa 'Hora' sÛ ser„o permitidos os Tipos 1=Valor Fixo, 3=% a Cobrar e 4=Tab Honor·rios. Corrija o campo 'Calc Faixa' ou escolha outra opÁ„o no 'Tipo Valor'.
	ElseIf (JUR96TPFIX(cTpHon) .And. JUR96FAIXA(cTpHon)) .And. ( cTpVl == '3' .Or. cTpVl == '4' )
		lRet := JurMsgErro(STR0167) //Quando utilizado o tipo de Faixa 'Quantidade de Casos' sÛ ser„o permitidos os Tipos 1=Valor Fixo e 2=Valor Unit·rio.
	EndIf
Else
	lRet := JurMsgErro(STR0168) //"Preencha o campo de C·lculo de Faixa antes de preencher o Tipo de Valor."
EndIf

//Efetua a limpeza dos campos de tabela de honor·rios / valor util de faixas, de acordo com o conte˙do do Tipo de Valor
If lRet .And. !Empty(cTpVl)
	If cTpVl <> '4' .And. !Empty(FwFldGet("NTR_CTABH"))
		oModel:ClearField("NTRDETAIL", "NTR_CTABH")
		oModel:ClearField("NTRDETAIL", "NTR_DTABH")
	EndIf

	If cTpVl == '4' .And. !Empty(FwFldGet("NTR_VALOR"))
		oModel:ClearField("NTRDETAIL", "NTR_VALOR")
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JVldCalFx
ValidaÁ„o do campo ìCalc Faixaî (NT0_CALFX) do cadastro de Faixa de
Faturamento.

@author Cristina Cintra Santos
@since 11/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JVldCalFx()
Local lRet        := .T.
Local oModel      := FWModelActive()
Local oModelNTR   := oModel:GetModel('NTRDETAIL')

	If ( oModelNTR:GetQtdLine() > 1 .And. !oModelNTR:IsDeleted() ) .Or. ( !oModelNTR:IsEmpty() .And. !Empty(oModelNTR:GetValue("NTR_TPVL")) .And. !oModelNTR:IsDeleted() )
		lRet := JurMsgErro(STR0169) //"SÛ È possÌvel alterar o C·lculo da Faixa quando n„o houverem registros na grid de Faixas de Valores."
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J96AltParc(oModel)
Rotina para permitir a alteraÁ„o do grid de parcelas de fixo de
forma manual quando no tipo de honor·rios, a parcela n„o for autom·tica
e a cobranÁa de honor·rios n„o estiver encerrada.

@Return	lRet	.T. quando permite inclus„o/alteraÁ„o manual est· permitida.

@author Luciano Pereira dos Santos
@since 21/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J96AltParc(oModel)
Local aArea     := GetArea()
Local lRet      := .T.
Local oModelNT0 := oModel:GetModel('NT0MASTER')
Local oModelNT1 := oModel:GetModel('NT1DETAIL')
Local lParcAut  := .F.
Local lEncHon   := .F.

//Verifica se a cobranca honorarios est· encerrada no contrato
lEncHon := oModelNT0:GetValue('NT0_ENCH') == '1'

//Verifica se o tipo de honorario È parcela automatica
lParcAut := JurGetDados("NRA", 1, xFilial("NRA") + oModelNT0:GetValue('NT0_CTPHON'), "NRA_PARCAT" ) == '1'

If lParcAut .Or. lEncHon
	oModelNT1:SetNoDeleteLine(.T.)
	oModelNT1:SetNoInsertLine(.T.)
	lRet := .F.
Else
	oModelNT1:SetNoDeleteLine(.F.)
	oModelNT1:SetNoInsertLine(.F.)
	lRet := .T.
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J96VerPreFat
Esta funÁ„o refere-se ao Requisito 003232 - Roadmap 2014  e tem por
objetivo validar e definir tratamentos para a alteraÁ„o das parcelas
das condiÁıes de faturamento, com base na situaÁ„o de uma prÈ-fatura,
caso exista.

@param oModel  , Modelo de Dados
@param nLineNT1, Linha corrente na NT1 (parcela fixa)

@return lRet   , Indica se o contrato foi ajustado e est· v·lido

@author Julio de Paula Paz
@since  26/03/2014
/*/
//-------------------------------------------------------------------
Static Function J96VerPreFat(oModel, nLineNT1)
Local lRet      := .T.
Local aArea     := GetArea()
Local aAreaNX0  := NX0->(GetArea())
Local oModelNT1 := oModel:Getmodel('NT1DETAIL')
Local cPreFat   := oModelNT1:GetValue('NT1_CPREFT', nLineNT1)
Local cParcela  := oModelNT1:GetValue('NT1_PARC'  , nLineNT1)
Local cParcSit  := oModelNT1:GetValue('NT1_SITUAC', nLineNT1)
Local cSituacao := ""

NX0->(DbSetOrder(1)) // NX0_FILIAL+NX0_COD+NX0_SITUAC

If cParcSit == '1' .And. NX0->(DbSeek(xFilial("NX0") + cPreFat))
	cSituacao := tabela( 'JS', NX0->NX0_SITUAC, .F. )

	If AllTrim(NX0->NX0_SITUAC) $ "2|3|D|E"
		If ApMsgYesNo(STR0180 + AllTrim(cParcela) + STR0181 + cPreFat + STR0182 + AllTrim(cSituacao) + STR0183) // "A parcela '" ### "' est· vinculada a prÈ-fatura '" ### "' com a situaÁ„o '" ### "', ser· necess·rio cancelar para realizar a alteraÁ„o! Deseja continuar?"
			If JA202CANPF(cPreFat)
				J202HIST('5', cPreFat, JurUsuario(__CUSERID)) //Insere o HistÛrico na prÈ-fatura
			EndIf
		Else
			lRet := .F.
		EndIf
	ElseIf AllTrim(NX0->NX0_SITUAC) == '6'
		If FwIsInCallStack("JUR96BOK")
			// Quando a J96VerPreFat È chamada pela JUR96BOK, o grid n„o est· posicionado,
			// e È necess·rio posicionar para a execuÁ„o da funÁ„o abaixo (J96VerAltM)
			oModelNT1:GoLine(nLineNT1)
		EndIf
		lRet := J96VerAltM(oModelNT1)
		If (!lRet)
			ApMsgInfo(STR0180 + AllTrim(cParcela) + STR0181 + cPreFat + STR0182 + AllTrim(cSituacao) + STR0184) // "A parcela '" ### "' est· vinculada a prÈ-fatura '" ### "' com a situaÁ„o '" ### "' e n„o poder· ser alterada!"
		EndIf
	ElseIf AllTrim(NX0->NX0_SITUAC) $ "4|5|7|9|A|B|C|F"
		ApMsgInfo(STR0180 + AllTrim(cParcela) + STR0181 + cPreFat + STR0182 + AllTrim(cSituacao) + STR0184) // "A parcela '" ### "' est· vinculada a prÈ-fatura '" ### "' com a situaÁ„o '" ### "' e n„o poder· ser alterada!"
		lRet := .F.
	EndIf

	If lRet
		J096CanNWE(oModel, cPreFat) // Cancela linhas na NWE
	EndIf

EndIf

RestArea(aAreaNX0)
RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} J96VerAltM(oModelNT1)
Verifica os campos que foram alterados

@param oModelNT1 - Modelo do Contrato Fixo

@author Willian Kazahaya
@since 26/01/2022
/*/
//-------------------------------------------------------------------
Static Function J96VerAltM(oModelNT1)
Return JVldAltMdl(oModelNT1, 1, {"NT1_DESCRI"}, .T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} J096CanNWE()
Cancela linhas de faturamento das parcelas de fixo (NWE)

@param oModel,  Modelo de dados do Contrato
@param cPreFat, CÛdigo da PrÈ-Fatura

@author Abner Oliveira, Jorge Martins, Victor Hayashi
@since  06/10/2020
/*/
//-------------------------------------------------------------------
Static Function J096CanNWE(oModel, cPreFat)
	Local oModelNWE := oModel:GetModel("NWEDETAIL")
	Local nLine     := 0
	Local nI        := 0

	If !oModelNWE:IsEmpty()
		nLine := oModelNWE:GetLine()
		For nI := 1 To oModelNWE:Length()
			If oModelNWE:GetValue('NWE_PRECNF', nI) == cPreFat
				oModelNWE:GoLine(nI)
				J096SetNo(oModelNWE, .F.)
				oModelNWE:LoadValue("NWE_CANC", "1")
				J096SetNo(oModelNWE, .T.)
			EndIf
		Next nI
		oModelNWE:Goline(nLine)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J96PICTPFX()
Verifica se o tipo de honor·rios È por faixa de faturamento usando
Quantidade de Casos ou Hora/Valor. Quando se tratar de Quantidade de
Casos, a picture dever· ser alterada para formato sem decimais.
Usado no X3_PICTVAR dos campos NTR_VLINI e NTR_VLFIM.
Caso seja feita alteraÁ„o nas casas decimais, necess·rio ajustar a
funÁ„o JVldPerFx.

@Return cRet	M·scara para os campos NTR_VLINI e NTR_VLFIM

@author Cristina Cintra Santos
@since 26/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J96PICTPFX()
Local cRet := AllTrim(X3Picture('NTR_VLINI'))

If JUR96FAIXA() // Quantidade de Casos
	cRet := SubStr(cRet, 1, At(".", cRet) - 1)
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096VldTpH
Executa a inclus„o do cadastro de Contrato apenas se existir algum tipo
de honor·rio cadastrado, pois ele que determina quais campos ser„o
mostrados no bot„o. Caso n„o exista tipo de honor·rios, propıe a carga
inicial.
Sem esta verificaÁ„o, quando n„o h· tipo de honor·rios, os campos de Fixo,
Faixa e Limite s„o exibidos na tela principal.

@param oModel   Modelo de Dados de Contrato

@return lRet    Indica se o modelo pode ser aberto

@author Cristina Cintra santos
@since 06/08/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J096VldTpH(oModel)
Local aArea     := GetArea()
Local aAreaNTH  := NTH->( GetArea() )
Local lRet      := .T.
Local nOpc      := oModel:GetOperation()

If nOpc == 3
	NTH->(DbSetOrder(1)) // NTH_FILIAL+NTH_CTPHON+NTH_CAMPO
	If !(NTH->(DbSeek(xFilial("NTH"))))
		lRet := JurMsgErro(STR0204,,STR0245) //"N„o existem tipos de honor·rios cadastrados, desta forma, n„o È permitida a manipulaÁ„o de contratos." - "Efetue a carga inicial."
	EndIf
EndIf

RestArea( aAreaNTH )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J96BOKNTR
Chama a validaÁ„o para a tabela NTR e verificar se o tipo de honor·rio informado faz manutenÁ„o na tabela NT1.
Caso haja dados na tabela NT1, roda as validaÁıes da tabela NT1.

@param nBotao = Referente ao campo NTH_BOTAO
                  1 = CondiÁıes de Faturamento de Fixo
                  2 = Faixa de Valores

@author Julio de Paula Paz
@since 09/09/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J96BOKNTR( oModel, lSubView, nBotao, cId)
Local lRet      := .T.
Local oModelNT1 := oModel:GetModel('NT1DETAIL')

Begin Sequence
	lRet := JUR96BOK( oModel, lSubView, nBotao, cId)

	If !oModelNT1:IsEmpty()
		lRet := JUR96BOK( oModel, lSubView, nBotao, 'NT1DETAIL')
	EndIf

End Sequence

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096ObrgOk
Rotina para verificar se todos os campos obrigatorios do modelo MASTER foram
preenchidos antes de abrir a mini view do contrato.

@param oModel     Modelo da dados da tela de contrato
@param aCpoView   Array com os campos da miniViwe
@param cButon     DescriÁ„o do Bot„o da Mini View

@author Luciano Pereira dos Santos
@since 02/09/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096ObrgOk(oModel, aCpoView, cButon)
Local lRet      := .T.
Local aArea     := GetArea()
Local oModelNT0 := oModel:GetModel('NT0MASTER')
Local aCampos   := {}
Local nI        := 0
Local cCampo    := ''

aCampos  := JurCpoObrig("NT0")

For nI := 1 To Len(aCampos)

	cCampo := Alltrim(aCampos[nI])

	If !Jur96Exibe( cCampo, aCpoView ) //Se o campo for obrigatÛrio e n„o est· na MiniView

		If Empty( oModelNT0:GetValue(cCampo ) )
			lRet := .F.
			ApMsgStop(I18N(STR0205, {cButon, AVSX3(cCampo)[5] })) // "Antes de clicar em '#1', preencha a informaÁ„o do campo '#2'."
			Exit
		EndIf

	EndIf

Next nI

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096ClxGr()
Rotina para verificar se o cliente/loja pertence ao grupo.
Usado nos gatilhos de Grupo

@Return - lRet  .T. quando o cliente PERTENCE ao grupo informado OU
                .F. quando o cliente N√O pertence ao grupo informado

@author Bruno Ritter
@since 04/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J096ClxGr()
Local lRet    := .F.
Local oModel  := FwModelActive()
Local cGrupo  := ""
Local cClien  := ""
Local cLoja   := ""

If IsInCallStack( 'JURA096' )
	cGrupo  :=  oModel:GetValue("NT0MASTER", "NT0_CGRPCL")
	cClien  :=  oModel:GetValue("NT0MASTER", "NT0_CCLIEN")
	cLoja   :=  oModel:GetValue("NT0MASTER", "NT0_CLOJA")

	lRet := JurClxGr(cClien, cLoja, cGrupo)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096ClxCa()
Rotina para verificar se o cliente/loja pertece ao caso.
Utilizado para condiÁ„o de gatilho

@param lNT0     Indica se a chamada È de um campo da NT0. Usado para os
				gatilhos de Caso M„e

@Return - lRet  .T. quando o cliente PERTENCE ao caso informado OU
                .F. quando o cliente N√O pertence ao caso informado

@author Bruno Ritter
@since 30/12/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J096ClxCa(lNT0)
Local lRet    := .T.
Local oModel  := FwModelActive()
Local cCaso   := ""
Local cClien  := ""
Local cLoja   := ""

Default lNT0  := .F.

If lNT0
	cCaso   :=  oModel:GetValue("NT0MASTER", "NT0_CCLICM")
	cClien  :=  oModel:GetValue("NT0MASTER", "NT0_CLOJCM")
	cLoja   :=  oModel:GetValue("NT0MASTER", "NT0_CCASCM")
ElseIf IsInCallStack( 'JURA096' )
	cCaso   :=  oModel:GetValue("NUTDETAIL", "NUT_CCASO")
	cClien  :=  oModel:GetValue("NUTDETAIL", "NUT_CCLIEN")
	cLoja   :=  oModel:GetValue("NUTDETAIL", "NUT_CLOJA")
EndIf

If !Empty(cCaso) .Or. !Empty(cClien) .Or. !Empty(cLoja)
	lRet := JurClxCa(cClien, cLoja, cCaso)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA096COMMIT
Classe interna implementando o FWModelEvent, para execuÁ„o de funÁ„o
durante o commit.

@author Cristina Cintra Santos
@since 21/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA096COMMIT FROM FWModelEvent
    Method New()
    Method BeforeTTS()
    Method InTTS()
End Class

Method New() Class JA096COMMIT
Return

Method BeforeTTS(oSubModel, cModelId) Class JA096COMMIT
	JA096CMBEF(oSubModel:GetModel())
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} InTTS
MÈtodo que È chamado pelo MVC quando ocorrer as aÁıes do commit apÛs 
as gravaÁıes porÈm antes do final da transaÁ„o.

@param oModel   - Modelo de dados de Contrato.
@param cModelId - Identificador do modelo.

@author  Abner FogaÁa
@since   26/02/2021
/*/
//-------------------------------------------------------------------
Method InTTS(oModel, cModelId) Class JA096COMMIT
Local cPreFat   := ""
Local cCodContr := ""
Local nPreFat   := 0
Local nOpc      := oModel:GetOperation()

	JA096CMAFT(oModel)
	If !Empty(_aPreFtVld)
		For nPreFat := 1 To Len(_aPreFtVld)
			cPreFat := _aPreFtVld[nPreFat]
			If JA202CANPF(cPreFat) // Cancela PrÈ-Fatura
				J202HIST('5', cPreFat, JurUsuario(__CUSERID)) // Insere o HistÛrico na prÈ-fatura
				J096CanNWE(oModel, cPreFat) // Cancela linhas na NWE (Faturamento do Fixo)
			EndIf
		Next
	EndIf
	
	JFILASINC(oModel, "NT0", "NT0MASTER", "NT0_COD") // Grava na fila de sincronizaÁ„o - IntegraÁ„o LegalDesk

	If nOpc == MODEL_OPERATION_DELETE .And. FindFunction("JExcAnxSinc")
		cCodContr := oModel:GetValue("NT0MASTER", "NT0_COD")
		JExcAnxSinc("NT0", cCodContr) // Exclui os anexos vinculados ao contrato e registra na fila de sincronizaÁ„o
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J096VldData()
Valida o perÌodo de referÍncia da parcela de fixo em relaÁ„o ao perÌodo de vigÍncia do contrato

@param dDataIni Data de referÍncia inicial da parcela de fixo
@param dDataFim Data de referÍncia final da parcela de fixo

@Return lRet	.T./.F. As informaÁıes s„o v·lidas ou n„o

@author Abner FogaÁa de Oliveira / Queizy.nascimento
@since 31/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J096VldData(dDataIni, dDataFim, cParcela)
Local lRet       := .T.
Local oModel     := FWModelActive()
Local oModelNT0  := oModel:GetModel('NT0MASTER')
Local dDtVigI    := oModelNT0:GetValue("NT0_DTVIGI")
Local dDtVigF    := oModelNT0:GetValue("NT0_DTVIGF")

Default dDataIni := CToD( '  /  /  ' )
Default dDataFim := CToD( '  /  /  ' )

	If !Empty(dDtVigI) .And. !Empty(dDtVigF) .And. Empty(dDataIni) .And. Empty(dDataFim)
		If dDtVigI > dDtVigF
			lRet := JurMsgErro(STR0239,, STR0244) // "A data inicial da vigÍncia n„o pode ser superior que a data final." "Verifique a data de vigÍncia no contrato"
		EndIf
	ElseIf !Empty(dDataIni) .And. !Empty(dDataFim) .And. !Empty(dDtVigI) .And. !Empty(dDtVigF)
		If dDataIni < dDtVigI 
			lRet := JurMsgErro(I18N(STR0242, {cParcela, dDataIni}),, STR0244) // "A parcela '#1' esta com a data inicial '#2' fora do periodo de vigÍncia." "Verifique a data de vigÍncia no contrato"
		ElseIf dDataFim > dDtVigF
			lRet := JurMsgErro(I18N(STR0243, {cParcela, dDataFim}),, STR0244)// "A parcela '#1' esta com a data final '#2' fora do periodo de vigÍncia." "Verifique a data de vigÍncia no contrato"
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096VldPer(cAlias,dDtVigI, dDtVigF)
Valida sobreposiÁ„o do perÌodo de vigÍncia do contrato

@param cAlias   alias da tabela NT0 chamada das funÁıes J096VDespTab / J096VlTpHo
@param dDtVigI  Data da vigÍncia inicial
@param dDtVigF  Data da vigÍncia final

@Return aRet    aRet[1] lÛgico,    N„o h· perÌodo sobrepostos de vigÍncia
                aRet[2] caractere, Mensagem de erro quando houver perÌodo sobrepostos

@author Abner FogaÁa de Oliveira / Queizy.nascimento
@since 01/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J096VldPer(cAlias,dDtVigI, dDtVigF)
Local cMsgErro   := ""
Local dDtContIni := IIf(ValType((cAlias)->NT0_DTVIGI) == "C", SToD((cAlias)->NT0_DTVIGI), (cAlias)->NT0_DTVIGI) // VigÍncia inicial em outro contrato
Local dDtContFim := IIf(ValType((cAlias)->NT0_DTVIGF) == "C", SToD((cAlias)->NT0_DTVIGF), (cAlias)->NT0_DTVIGF) // VigÍncia final em outro contrato

	//Verifica se a vigÍncia inicial È maior ou igual a alguma vigÍncia final de perÌodo posterior
	If (dDtContIni <= dDtVigI) .And. (dDtContFim >= dDtVigI) .And. (dDtContIni != dDtContFim)
		cMsgErro := I18N(STR0234 + CRLF +; // "PerÌodos sobrepostos na vigÍncia."
						STR0235,; // "A vigÍncia inicial '#1' est· sobrepondo a vigÍncia do contrato '#2'."
						{dDtVigI, (cAlias)->NT0_COD}) // "Verifique o perÌodo de vigÍncia no contrato."
	EndIf

	//Verifica se a vigÍncia final È maior ou igual a alguma vigÍncia inicial de perÌodo posterior
	If (dDtContIni >= dDtVigI) .And. (dDtContIni <=  dDtVigF) .And. (dDtContIni != dDtContFim)
		cMsgErro := I18N(STR0234 + CRLF +; // "PerÌodos sobrepostos na vigÍncia."
						STR0236,; // "A vigÍncia final '#1' est· sobrepondo a vigÍncia do contrato '#2'."
						{dDtVigF,(cAlias)->NT0_COD}) // "Verifique o perÌodo de vigÍncia no contrato."
	EndIf

	If Empty(dDtContIni) .And.  Empty(dDtContFim) .And. !Empty(dDtVigI) .And. !Empty(dDtVigF)
		cMsgErro :=†I18N(STR0237,; // N„o È permitido vincular o caso '#1' a um contrato com vigÍncia, pois o mesmo est· vinculado ao contrato '#2' que n„o possui vigÍncia preenchida.
						{(cAlias)->NUT_CCASO,(cAlias)->NT0_COD}) 
	EndIf

	If Empty(dDtVigI) .And.  Empty(dDtVigF) .And. !Empty(dDtContIni) .And. !Empty(dDtContFim)
		cMsgErro := I18N(STR0238,; // N„o È permitido vincular o caso '#1' a um contrato sem vigÍncia, pois o mesmo est· vinculado ao contrato '#2' que possui vigÍncia preenchida.
						{(cAlias)->NUT_CCASO,(cAlias)->NT0_COD})
	EndIf

Return cMsgErro

//-------------------------------------------------------------------
/*/{Protheus.doc} J096VigPar
Percorre as parcelas para validar a data de vigÍncia do contrato

@param oModel, Modelo do contrato

@Return lRet,  Se est· tudo ok

@author Bruno Ritter
@since 09/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J096VigPar(oModel)
	Local lRet      := .T.
	Local lCobFixo  := JUR96TPFIX(oModel:GetValue('NT0MASTER','NT0_CTPHON'))
	Local oModelNT1 := oModel:GetModel('NT1DETAIL')
	Local nTotalLn  := oModelNT1:GetQTDLine()
	Local nLn       := 0

	If lCobFixo
		For nLn := 1 To nTotalLn
			If !J096VldData(oModelNT1:GetValue("NT1_DATAIN", nLn),;
			                oModelNT1:GetValue("NT1_DATAFI", nLn),;
			                oModelNT1:GetValue("NT1_PARC", nLn) )
				lRet := .F.
				Exit
			EndIf
		Next nLn
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J096NT1Whn()
Rotina de modo de ediÁ„o (When) da tabela de parcela de fixo.

@author Luciano Pereira dos Santos
@since 20/02/2019
/*/
//-------------------------------------------------------------------
Function J096NT1Whn()
Local lRet    := .F.
Local cCampo  := Alltrim(StrTran(ReadVar(), 'M->', ''))
Local oModel  := FwModelActive()

If oModel:GetID() == 'JURA096'
	If cCampo == "NT1_DESCRI"
		lRet := oModel:GetValue("NT1DETAIL", "NT1_SITUAC") == "1" 
	ElseIf cCampo == "NT1_TKRET"
		lRet := !Empty(oModel:GetValue("NT1DETAIL", "NT1_CPREFT")) 
	EndIf

ElseIf oModel:GetID() == 'JURA202'
	If cCampo $ "NT1_INSREV|NT1_REVISA|NT1_DESCRI|NT1_CTPFTU"
		lRet := Iif(FindFunction("JurIsRest"), JurIsRest(), .F.)
	EndIf
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} JA96NUTLoad
FunÁ„o para carregar o grid de casos atravÈs de query.

@param  oModelGrid, Objeto com a estrutura do modelo de dados
@param  lLoad     , Indica se ir· carregar

@author Jonatas Martins
@since  18/01/2021
/*/
//------------------------------------------------------------------------------
Static Function JA96NUTLoad(oModelGrid, lLoad)
Local aArea     := GetArea()
Local cQueryNUT := ""
Local aValues   := {}
Local aData     := {}
Local aStruTmp  := {}
Local aRelacao  := {}
Local cAlsTmp   := GetNextAlias()
Local cCampos   := J96GetCpo(oModelGrid, @aRelacao)
Local xValor    := Nil
Local nPosRel   := 0
Local nCpo      := 0
Local nOpc      := 0

	cQueryNUT := "SELECT " + cCampos + ", NUT.R_E_C_N_O_"
	cQueryNUT +=  " FROM " + RetSqlName("NUT") + " NUT"
	cQueryNUT += " INNER JOIN " + RetSqlName("SA1") + " SA1"
	cQueryNUT +=    " ON SA1.A1_FILIAL = '" + xFilial("SA1") + "'"
	cQueryNUT +=   " AND SA1.A1_COD = NUT.NUT_CCLIEN"
	cQueryNUT +=   " AND SA1.A1_LOJA = NUT.NUT_CLOJA"
	cQueryNUT +=   " AND SA1.D_E_L_E_T_ = ' ' "
	cQueryNUT += " INNER JOIN " + RetSqlName("NVE") + " NVE"
	cQueryNUT +=    " ON NVE.NVE_FILIAL = '" + xFilial("NVE") + "'"
	cQueryNUT +=   " AND NVE.NVE_CCLIEN = NUT.NUT_CCLIEN"
	cQueryNUT +=   " AND NVE.NVE_LCLIEN = NUT.NUT_CLOJA"
	cQueryNUT +=   " AND NVE.NVE_NUMCAS = NUT.NUT_CCASO"
	cQueryNUT +=   " AND NVE.D_E_L_E_T_ = ' '"
	cQueryNUT +=  " LEFT JOIN " + RetSqlName("RD0") + " RD0"
	cQueryNUT +=    " ON RD0.RD0_FILIAL = '" + xFilial("RD0") + "'"
	cQueryNUT +=   " AND RD0.RD0_CODIGO = NVE.NVE_CPART1 "
	cQueryNUT +=   " AND RD0.D_E_L_E_T_ = ' ' "
	cQueryNUT += " WHERE NUT_FILIAL = '" + xFilial("NUT") + "'"
	cQueryNUT +=   " AND NUT.NUT_CCONTR = '" + NT0->NT0_COD + "'"
	cQueryNUT +=   " AND NUT.D_E_L_E_T_ = ' '"

	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQueryNUT), cAlsTmp, .T., .T.)

	If Empty(aRelacao)
		aData := FwLoadByAlias(oModelGrid, cAlsTmp, "NUT")
	Else
		aStruTmp := (cAlsTmp)->(DbStruct())
		NUT->(DbSetOrder(1))

		// Necess·rio para situaÁıes onde existam campos customizados
		// e seja uma operaÁ„o via REST (LegalDesk)
		If Type("INCLUI") == "U" .Or. Type("ALTERA") == "U"
			nOpc   := oModelGrid:GetModel():GetOperation()
			INCLUI := nOpc == MODEL_OPERATION_INSERT
			ALTERA := nOpc == MODEL_OPERATION_UPDATE
		EndIf

		While (cAlsTmp)->(! EOF())

			For nCpo := 1 To Len(aStruTmp)
				cCampo  := aStruTmp[nCpo][1]
				
				If cCampo != "R_E_C_N_O_"
					nPosRel := aScan(aRelacao, {|x| x[1] == cCampo})
					
					If nPosRel
						NUT->(DbGoTo((cAlsTmp)->R_E_C_N_O_))
						xValor := &(aRelacao[nPosRel][2])
					Else
						xValor := (cAlsTmp)->(FieldGet(FieldPos(cCampo)))
					EndIf
				
					Aadd(aValues, xValor)
				EndIf
			Next nCpo

			Aadd(aData, {(cAlsTmp)->R_E_C_N_O_, aValues})
			aValues := {}

			(cAlsTmp)->(DbSkip())
		EndDo
	EndIf

	(cAlsTmp)->(DbCloseArea())

	JurFreeArr(@aRelacao)

	RestArea(aArea)

Return (aData)

//------------------------------------------------------------------------------
/*/{Protheus.doc} J96GetCpo
Monta string de campos para query de load do grid de casos NUT

@param      oModelGrid, Objeto com a estrutura do modelo de dados
@return     aRelacao  , Array com inicializador padr„o dos campos virtuais

@author     Jonatas Martins
@since      18/01/2021
@obs        Sempre que criar um novo campo virtual necess·rio atualizar o de para nessa funÁ„o
/*/
//------------------------------------------------------------------------------
Static Function J96GetCpo(oModelGrid, aRelacao)
	Local oStructGrid := oModelGrid:GetStruct()
	Local aFieldsGrid := oStructGrid:GetFields()
	Local cField      := ""
	Local cCampos     := ""
	Local nCpo        := 0

	For nCpo := 1 To Len(aFieldsGrid)
		cField := aFieldsGrid[nCpo][MODEL_FIELD_IDFIELD]
		
		Do Case
			Case cField == "NUT_DCLIEN"
				cCampos += "SA1.A1_NOME " + cField

			Case cField == "NUT_DCASO"
				cCampos += "NVE.NVE_TITULO " + cField

			Case cField == "NUT_SIGLA"
				cCampos += "RD0.RD0_SIGLA " + cField

			Case cField == "NUT_CPART1"
				cCampos += "RD0.RD0_CODIGO " + cField

			Case cField == "NUT_DPART1"
				cCampos += "RD0.RD0_NOME " + cField

			Case aFieldsGrid[nCpo][MODEL_FIELD_VIRTUAL]
				cCampos += "' ' " + cField

				If GetSx3Cache(cField, "X3_PROPRI") == "U" // Campo virtual de usu·rio
					Aadd(aRelacao, {cField, GetSx3Cache(cField, "X3_RELACAO")})
				EndIf

			OtherWise
				cCampos += cField
		End Case
		
		cCampos += ", "

	Next nCpo

	cCampos := SubStr(cCampos, 1, Len(cCampos) - 2)

Return (cCampos)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA096VlSit
Valida a situacao do Cliente/Caso x Situacao do contrato 

@param oModel, objeto, Estrutura do modelo de dados de contrato

@author Jonatas Martins / Jorge Martins
@since  26/01/2021
/*/
//-------------------------------------------------------------------
Static Function JA096VlSit(oModel)
Local aArea      := GetArea()
Local aAreaNVE   := NVE->( GetArea() )
Local oModelNUT  := Nil
Local lRet       := .T.
Local lLojaAuto  := .F.
Local aRet       := {}
Local cMsgSitCas := ""
Local cCliProv   := ""
Local cCasos     := ""
Local cTxt       := ""
Local cTitCpos   := ""
Local nLine      := 0
Local nQtdLines  := 0
Local lAltSit    := .T.
Local cSituac    := AllTrim(NT0->NT0_SIT)
Local cFilNUH    := ""

	If Empty(cSituac) .And. oModel:GetOperation() == 4
		NT0->(DbGoTo(oModel:GetModel("NT0MASTER"):GetDataId()))
		cSituac := NT0->NT0_SIT
	EndIf

	lAltSit := oModel:GetOperation() == 3 .Or. (oModel:GetOperation() == 4 .And. oModel:GetValue("NT0MASTER", "NT0_SIT") <> cSituac)

	If NVE->(ColumnPos("NVE_SITCAD")) > 0 .And. oModel:GetValue("NT0MASTER", "NT0_SIT") == "2"
		// Atualiza os casos provisÛrios para definitivo
		oModelNUT := oModel:GetModel("NUTDETAIL")
		nQtdLines := oModelNUT:GetQtdLine()
		lLojaAuto := SuperGetMv( "MV_JLOJAUT", .F., "2", ) == "1" // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-N„o)
		cFilNUH   := xFilial("NUH")

		For nLine := 1 To nQtdLines
			// Se a linha n„o estiver deletada E (houve alteraÁ„o da situaÁ„o do contrato OU inclus„o/alteraÁ„o da linha)
			If !oModelNUT:IsDeleted(nLine) .And. (lAltSit .Or. (oModelNUT:IsInserted(nLine) .Or. oModelNUT:IsUpdated(nLine)))
				cCliente := oModelNUT:GetValue("NUT_CCLIEN", nLine)
				cLoja    := oModelNUT:GetValue("NUT_CLOJA" , nLine)
				cCaso    := oModelNUT:GetValue("NUT_CCASO" , nLine)

				If NUH->NUH_COD == cCliente .And. NUH->NUH_LOJA == cLoja
					cSitCli := NUH->NUH_SITCAD
				Else
					cSitCli := Posicione("NUH", 1, cFilNUH + cCliente + cLoja, "NUH_SITCAD")
				EndIf

				If cSitCli == "1" // Cliente ProvisÛrio
					cTxt := cCliente + IIf(lLojaAuto, "", " - " + cLoja)
					If !(cTxt $ cCliProv)
						cCliProv += cTxt + CRLF
					EndIf
				ElseIf Empty(cCliProv) .And. Posicione("NVE", 1, cFilNUH + cCliente + cLoja + cCaso, "NVE_SITCAD") == "1" // Caso ProvisÛrio
					Aadd(aRet, {cCliente, cLoja, cCaso, cSitCli})
					cCasos  += cCliente + IIf(lLojaAuto, "", " - " + cLoja) + " - " + cCaso + CRLF
				EndIf
			EndIf
		Next nLine
		
		If !Empty(cCliProv) // Clientes provisÛrios que impedem a confirmaÁ„o do cadastro
			lRet := JurMsgErro(STR0256,, STR0257 + CRLF + cCliProv) // "N„o È permitido o uso de clientes com situaÁ„o provisÛria em contrato definitivo." # "Ajuste a situaÁ„o no cadastro do(s) cliente(s) abaixo: " 
		ElseIf !Empty(cCasos) // Casos que ser„o alterados
			cTitCpos   := RetTitle("NUT_CCLIEN") + " - " + RetTitle("NUT_CLOJA") + " - " + RetTitle("NUT_CCASO")
			cMsgSitCas := STR0254 + CRLF + CRLF + cTitCpos + CRLF + cCasos // "A situaÁ„o dos casos abaixo ser· alterada para definitiva."
			_aSitCasos := {cMsgSitCas, aRet}
		EndIf

	EndIf

	RestArea( aAreaNVE )
	RestArea( aArea )

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JF3NT0
Consulta padr„o de contratos

@param aFields   , array, Array de campos
@param lShow     , boolean, Indica se o formul·rio deve ser exibido
@param lInsert   , boolean, Indica se o usu·rio pode incluir novo registro
@param cFilter   , string, Filtro de pesquisa
@param lPreload  , boolean, Indica se o grid deve ser prÈ-carregado

@return lRet     , boolean, Indica se houve sucesso na consulta

@since  14/03/2022
/*/
//-------------------------------------------------------------------
Function JF3NT0(aFields, lShow, lInsert, cFilter, lPreload)
Local   lRet     := .F.
Default cFilter  := ""
Default lInsert  :=.F.
Default lShow    :=.T.
Default lPreload :=.T.
Default aFields  := {"NT0_COD", "NT0_NOME", "NT0_CGRPCL", "NT0_CCLIEN", "NT0_CLOJA"}

	If IsInCallStack('JURA033')
		cFilter  := "@#JA033F3NT0()"
	ElseIf ReadVar() == "M->NW2_CCONSU"
		If !Empty(FWFldGet("NW2_CGRUPO"))
			cFilter +=     " NT0.NT0_CGRPCL = '" + FWFldGet("NW2_CGRUPO") + "' "
		ElseIf !Empty(FWFldGet("NW2_CCLIEN")) .And. !Empty(FWFldGet("NW2_CLOJA"))
			cFilter +=     " NT0.NT0_CCLIEN = '" + FWFldGet("NW2_CCLIEN") + "' "
			cFilter += " AND NT0.NT0_CLOJA = '" + FWFldGet("NW2_CLOJA") + "' "
		EndIf
	ElseIf ReadVar() == "M->NW3_CCONTR"
		cFilter :=     " NOT EXISTS ( SELECT NW3a.R_E_C_N_O_ "
		cFilter +=                       " FROM " + RetSqlName("NW3") + " NW3a "
		cFilter +=                       " WHERE NW3a.D_E_L_E_T_ = ' ' "
		cFilter +=                         " AND NW3a.NW3_FILIAL = '" + xFilial( "NW3" ) + "' "
		cFilter +=                         " AND NW3a.NW3_CCONTR = NT0.NT0_COD )"
	Else
		cFilter  := "@#JURNT0()"
	EndIf
	lRet := JURSXB("NT0", "J96NT0", aFields, lShow, lInsert , cFilter, "JURA096", lPreload)

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} JA096VlCon
Busca despesas pendentes relacionadas a todos os casos relacionados ao contrato

@author Carolina Neiva
@since  25/08/2022
/*/
//-------------------------------------------------------------------
Function JA096VlCon()
Local lAviso    := .F.
Local cQuery    := ''
Local cResQRY   := ''
Local oModel    := FWModelActive()
Local oModelNT0 := oModel:GetModel("NT0MASTER" )
Local oModelNUT := oModel:GetModel("NUTDETAIL" )
Local nQtdLines := oModelNUT:GetQtdLine()
Local cAviso    := STR0263 // "Existem despesas pendentes relacionadas a casos deste contrato. Caso deseje cancelar o encerramento de despesas, retorne o campo para '2-N„o'."
Local nI        := 0
Local cTitle    := STR0264 // "Despesas Pendentes"

	If ( oModelNT0:GetValue("NT0_ENCD") == '1' ) 

		For nI := 1 To nQtdLines

			If !oModelNUT:IsDeleted(nI)

				cCliente := oModelNUT:GetValue("NUT_CCLIEN", nI)
				cLoja    := oModelNUT:GetValue("NUT_CLOJA", nI)
				cCaso    := oModelNUT:GetValue("NUT_CCASO", nI)

			
				cQuery := " SELECT COUNT(NVY.NVY_CCASO) COUNTDES "
				cQuery +=   " FROM " + RetSqlName( "NVY" ) + " NVY "
				cQuery +=  " WHERE NVY.D_E_L_E_T_ = ' '
				cQuery +=    " AND NVY.NVY_FILIAL = '" + xFilial( "NT0" ) + "' "
				cQuery +=    " AND NVY.NVY_CCLIEN = '" + cCliente + "' "
				cQuery +=    " AND NVY.NVY_CLOJA  = '" + cLoja + "' "
				cQuery +=    " AND NVY.NVY_CCASO  = '" + cCaso + "' "
				cQuery +=    " AND NVY.NVY_SITUAC = '1' "

				cQuery := ChangeQuery(cQuery)

				cResQRY := GetNextAlias()
				dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cResQRY, .T., .T.)

				lAviso := (cResQRY)->COUNTDES > 0
				(cResQRY)->(dbCloseArea())

				If lAviso
					Exit
				EndIf

			EndIf

		Next

		If lAviso 
			ApMsgAlert(cAviso,cTitle)
		EndIf

	EndIf

Return .T.
