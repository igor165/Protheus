#Include "Protheus.ch"
#Include "rwmake.ch"
#Include "FINA820A.ch"

Static __cCodPes       As Character
Static __cFormApu      As Character
Static __cSitEsp       As Character
Static __dSitEsp       As Date
Static __cIniPer       As Character
Static __cTpDt         As Character
Static __cDevol        As Character
Static __dInicial      As Date
Static __dFinal        As Date

//------------------------------------------------------------------------------
/*/	{Protheus.doc} FINA820A

Interface do LCDPR

@sample     
@return		aRetTela		 Conforme FINA820 recebe
@author		rafael rondon
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Function FINA820A() As Array

Local oWizard       As Object
Local oStep1        As Object
Local oStep2        As Object
Local oStep3        As Object
Local oStep4        As Object
Local oStep5        As Object

Local aImoveis      As Array
Local cDirlocal     As Character
Local cContador     As Character
Local lProcessar    As Logical
Local lCancel		As Logical
Local lCSV          As Logical
Local aRetTela      As Array
Local aAux          As Array
Local aAuxBco       As Array
Local nI            As Numeric
Local aBancos       As Array
Local cVersao       As Character

Local cCodPes       As Character
Local cFormApu      As Character
Local cSitEsp       As Character
Local dSitEsp       As Date
Local cIniPer       As Character
Local cTpDt         As Character
Local cDevol        As Character
Local dInicial      As Date
Local dFinal        As Date

aImoveis    := {}
cContador   := Space(TamSX3('CVB_CODCTB')[1])
cDirlocal   := ""
lProcessar  := .F.
aRetTela    := {}
aAux        := {}
aAuxBco     := {}
aBancos     := {}
cVersao     := GetVerLCD()
lCancel		:= .F.
lCSV        := .F.

oWizard := FWWizardControl():New( /*oObjPai*/, { 600, 850 } )				// Instancia a classe FWWizardControl

oWizard:ActiveUISteps()

/*
    Apresentação
*/
oStep1 := oWizard:AddStep( 'Step1', { | oPanel | Step1( oPanel ) } )	    // Adiciona um "Passo"
oStep1:SetStepDescription( STR0001 )            							// Define o título do "Passo" | "Início"
oStep1:SetNextTitle( STR0002 )	    										// Define o título do botão de avanço | "Próximo"
oStep1:SetNextAction( { || .T. } )								            // Define o bloco ao clicar no botão Próximo
oStep1:SetCancelAction( { || lCancel := .T. } )										// Define o bloco ao clicar no botão Cancelar

/*
    "Abertura e Identificação"
*/
oStep2 := oWizard:AddStep( 'Step2', { | oPanel | Step2( oPanel      , @cCodPes      , @cFormApu     , @cSitEsp      , @dSitEsp  , ;
                                                        @cIniPer    , @cTpDt        , @dInicial     , @dFinal       , @cDevol          ) } )	    // Adiciona um "Passo"
oStep2:SetStepDescription( STR0003 )                 	// Define o título do "Passo" | "Abertura e Identificação"
oStep2:SetNextTitle( STR0002 )											// Define o título do botão de avanço | "Próximo"
oStep2:SetNextAction( { || ValStep2( cCodPes , cFormApu , cSitEsp, dSitEsp , cIniPer , cTpDt , dInicial , dFinal ) } )	    // Define o bloco ao clicar no botão Próximo
oStep2:SetCancelAction( { || lCancel := .T. } )										// Define o bloco ao clicar no botão Cancelar

/*
    "Seleção dos Imóveis"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
*/
oStep3 := oWizard:AddStep( 'Step3', { | oPanel | Step3( oPanel , cCodPes  , @aImoveis ) } )	    // Adiciona um "Passo"
oStep3:SetStepDescription( STR0004 )                         	// Define o título do "Passo" | "Seleção dos Imóveis"
oStep3:SetNextTitle( STR0002 )											// Define o título do botão de avanço | "Próximo"
oStep3:SetNextAction( { || ValStep3(aImoveis, cCodPes) } )	                // Define o bloco ao clicar no botão Próximo
oStep3:SetCancelAction( { || lCancel := .T. } )										// Define o bloco ao clicar no botão Cancelar

/*
    "Seleção dos Bancos"
*/
oStep4 := oWizard:AddStep( 'Step4', { | oPanel | Step4( oPanel , @aBancos ) } )	// Adiciona um "Passo"
oStep4:SetStepDescription( STR0050 )                                    	// Define o título do "Passo" | "Seleção dos Bancos"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
oStep4:SetNextTitle( STR0002 ) 									    		// Define o título do botão de avanço | "Próximo"
oStep4:SetNextAction( { || ValStep4(aBancos) } )  	        // Define o bloco ao clicar no botão Próximo
oStep4:SetCancelAction( { || lCancel := .T. } )										// Define o bloco ao clicar no botão Cancelar

/*
    "Finalização"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
*/
oStep5 := oWizard:AddStep( 'Step5', { | oPanel | Step5( oPanel , @cContador , @cDirlocal, @lCSV) } )	// Adiciona um "Passo"
oStep5:SetStepDescription( STR0005 )                               	// Define o título do "Passo" | "Finalização"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
oStep5:SetNextTitle( STR0006 ) 											// Define o título do botão de avanço | "Processar"
oStep5:SetNextAction( { || lProcessar := ValStep5(cDirlocal) } )	        // Define o bloco ao clicar no botão Próximo
oStep5:SetCancelAction( { || lCancel := .T. } )										// Define o bloco ao clicar no botão Cancelar

oWizard:Activate()

oWizard:Destroy()

If lProcessar

    AADD( aRetTela , {  cVersao                                                   	, ;
                        Posicione('FVU',1,xFilial('FVU') + __cCodPes , 'FVU_CNPJ' ) , ;
                        ''                                                          , ; 
                        __cIniPer                                                   , ; 
                        __cSitEsp                                                   , ;    // [5]
                        __dSitEsp                                                   , ; 
                        __dInicial                                                  , ; 
                        __dFinal                                                    , ; 
                        __cFormApu                                                  , ; 
                        cDirlocal                                                   , ;    // [10]
                        ''                                                          , ;    // Nome do arquivo (utilizado para automação de testes)
                        lCSV                                                        } )    // Gera .CSV 

    For nI := 1 To Len(aImoveis)    
        If aImoveis[nI][1]  // Marcado
            AADD( aAux , aImoveis[nI][2]  )
        EndIf
    Next nI
    AADD( aRetTela , aAux )
    
    For nI := 1 To Len(aBancos)    
        If aBancos[nI][1]  // Marcado
            AADD( aAuxBco , { aBancos[nI][2], aBancos[nI][4], aBancos[nI][5], aBancos[nI][6], aBancos[nI][7], aBancos[nI][8], aBancos[nI][9]}  )
        EndIf
    Next nI
    AADD( aRetTela , aAuxBco )

    AADD( aRetTela , {  xFilial('CVB') , cContador } )
    AADD( aRetTela , {  __cTpDt } )
    AADD( aRetTela , lCancel )
    AADD( aRetTela , cDevol == '1')

Else
	aRetTela := { {}, {}, {}, {}, {}, lCancel, cDevol == '1' }
EndIf

ZeraStatic()

Return aRetTela

//------------------------------------------------------------------------------
/*/	{Protheus.doc} Step1

Interface Step1 do LCDPR

@sample     
@return		
@author		rafael rondon
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function Step1( oPanel As Object )

Local oFont		As Object
Local oFontV	As Object
Local oSayTop	As Object
Local oSay2     As Object
Local oSay3     As Object
Local oSay4     As Object

oFont 	:= TFont():New( ,, -20, .T., .T.,,,,, )
oFontV 	:= TFont():New( ,, -12, .T., .T.,,,,, )

oSayTop	:= TSay():New( 10, 10, { || STR0007 }, oPanel,, oFont,,,, .T., CLR_BLUE, ) // "Geração do arquivo do LCDPR"
oSay2	:= TSay():New( 50, 10, { || STR0008 }, oPanel,,,,,, .T., CLR_BLUE, ) // "Este programa tem como base os cadastros de Pessoas (FINA031) e Imóveis (FINA029)"
oSay3	:= TSay():New( 70, 10, { || STR0051 }, oPanel,, oFontV,,,, .T., CLR_BLUE, ) // 'Importante: '
oSay3	:= TSay():New( 80, 10, { || STR0052 }, oPanel,,,,,, .T., CLR_BLUE, ) // 'Os bancos do declarante devem estar marcados como "Titularidade" Própria no cadastro de Bancos para poderem ser selecionados no Extrator.'
oSay4	:= TSay():New( 160, 140, { || STR0053 + GetVerLCD() }, oPanel,, oFontV,,,, .T., CLR_BLUE,,,,,,,,,, 1 ) // 'Versão do Leiaute: '

Return

//------------------------------------------------------------------------------
/*/	{Protheus.doc} Step2

Interface Step1 do LCDPR

@sample     
@return		
@author		rafael rondon
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function Step2(  oPanel As Object        , cCodPes As Character  , cFormApu  As Character    , cSitEsp As Character  , dSitEsp As Date , ;
                        cIniPer As Character    , cTpDt As Character, dInicial As Date      , dFinal As Date    , cDevol As Character)

Local oSay1     As Object
Local oSay2     As Object
Local oSay3     As Object
Local oSay4     As Object
Local oSay5     As Object
Local oSay6     As Object
Local oSay7     As Object
Local oSay8     As Object
Local oSay9     As Object
Local oSayA     As Object
Local oGet1     As Object
Local oGet2     As Object
Local oGet5     As Object
Local oGet7     As Object
Local oGet8     As Object
Local oIniPer   As Object
Local oSitEsp   As Object
Local oFormApu  As Object
Local oTpDt     As Object
Local oDevol    As Object
Local cNomPes   As Character
Local aIniPer   As Array            // Indicado do Inicio do Periodo       
Local aSitEsp   As Array            // Situação Especial
Local aTpDt     As Array
Local aDevol    As Array
Local nAltGet   As Numeric
Local nAltCombo As Numeric

Default cDevol  := '2'

cCodPes     := Space(TamSX3('FVU_CODIGO')[1])
cNomPes     := Space(TamSX3('FVU_NOME')[1])
aIniPer     := {}
aSitEsp     := {}
aTpDt       := {}
aDevol      := {}
dSitEsp     := CToD("")
aFormApu    := {}
dInicial    := CToD("")
dFinal      := CToD("")
nAltGet     := 13       // Altura dos Gets na tela
nAltCombo   := 16       // Altura dos Gets na tela

oSay1   := TSay():New( 10, 10, { || STR0009 }, oPanel,,,,,, .T. ) // "Cód. Declarante"
oGet1   := TGet():New( 18, 10, { |u| If( PCount() > 0, cCodPes := u, cCodPes ) }, oPanel, 060, nAltGet,,{|| ValCodPes(cCodPes , @cNomPes ) },,,,,,.T.,,,{|| .T.},,,,,,,"cCodPes" )
oGet1:cF3 := 'FVUFVV'

oSay2   := TSay():New( 10, 150, { || STR0010 }, oPanel,,,,,, .T. ) // "Nome Declarante"
oGet2   := TGet():New( 18, 150, { |u| If( PCount() > 0, cNomPes := u, cNomPes ) }, oPanel, 140, nAltGet,,,,,,,,.T.,,,{|| .F.},,,,,,,"cNomPes" )

/*
    Forma de Apuração
*/
oSay6   := TSay():New( 45, 10, { || STR0011 }, oPanel,,,,,, .T. ) // "Forma de Apuração"
AADD( aFormApu , STR0012 ) // '1= Livro Caixa'
AADD( aFormApu , STR0013 ) // '2= Apuração do lucro pelo disposto no art. 5º da Lei nº 8.023, de 1990'                                                                                                                                                                                                                                                                                                                                                                                                                                            
AADD( aFormApu , ' ' )
cFormApu := aFormApu[3]
oFormApu := TComboBox():New( 53, 10, { |u| If( PCount() > 0, cFormApu := u, cFormApu ) }, aFormApu, 200, nAltCombo, oPanel,,{|| __cFormApu	:= cFormApu },,,,.T.,,,,{|| .T.},,,,, "cFormApu" )

/*
    Situação Especial
*/
oSay4   := TSay():New( 80, 10, { || STR0014 }, oPanel,,,,,, .T. )  // "Situação Especial"
AADD( aSitEsp , STR0015 ) // '0= Normal'
AADD( aSitEsp , STR0016 ) // '1= Falecimento'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
AADD( aSitEsp , STR0017 ) // '2= Espólio'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
AADD( aSitEsp , STR0018 ) // '3= Saída definitiva do País'
AADD( aSitEsp , ' ' )
cSitEsp := aSitEsp[5]
oSitEsp := TComboBox():New( 88, 10, { |u| If( PCount() > 0, cSitEsp := u, cSitEsp ) }, aSitEsp, 100, nAltCombo, oPanel,,{|| __cSitEsp	:= cSitEsp },,,,.T.,,,,{|| .T.},,,,, "cSitEsp" )

oSay5   := TSay():New( 80, 150, { || STR0019 }, oPanel,,,,,, .T. )  // "Data Sit. Especial"
oGet5   := TGet():New( 88, 150, { |u| If( PCount() > 0, dSitEsp := u, dSitEsp ) }, oPanel, 060, nAltGet,,,,,,,,.T.,,,{|| bDtEsp(@dSitEsp, cSitEsp) },,, {|| __dSitEsp := dSitEsp},,,,"dSitEsp" )

/*
    Indicador do Início do Período:
*/
oSay3   := TSay():New( 115, 10, { || STR0020 }, oPanel,,,,,, .T. )  // "Indicador do Início do Período"
AADD( aIniPer , STR0021 ) // '0= Regular (Início no primeiro dia do ano)'
AADD( aIniPer , STR0022 ) // '1= Abertura (Início de atividades no ano-calendário)'
AADD( aIniPer , STR0023 ) // '2= Início de obrigatoriedade da escrituração no curso do ano calendário'
AADD( aIniPer , ' ' )
cIniPer := aIniPer[4]
oIniPer := TComboBox():New( 123, 10, { |u| If( PCount() > 0, cIniPer := u, cIniPer ) }, aIniPer, 200, nAltCombo, oPanel,,{|| __cIniPer	:= cIniPer },,,,.T.,,,,{|| .T.},,,,, "cIniPer" )

/*
    Considera Devolução de Nota:
*/
oSayA   := TSay():New( 115, 230, { || STR0064}, oPanel,,,,,, .T. )  // 'Devolução de Nota'
AADD( aDevol , STR0065 ) // "1= Considera"
AADD( aDevol , STR0066 ) // "2= Não considera"
AADD( aDevol , ' ' )
oDevol := TComboBox():New( 123, 230, { |u| If( PCount() > 0, cDevol := u, cDevol ) }, aDevol, 070, nAltCombo, oPanel,,{|| __cDevol	:= cDevol },,,,.T.,,,,{|| .T.},,,,, "cDevol" )

/*
    Data utilizada no Período:
*/
oSay9   := TSay():New( 150, 10, { || STR0061}, oPanel,,,,,, .T. )  // "Por Data"
AADD( aTpDt , STR0062 ) // "1= Da Baixa"
AADD( aTpDt , STR0063 ) // "2= De Crédito"
AADD( aTpDt , ' ' )
cTpDt := aTpDt[3]
oTpDt := TComboBox():New( 158, 10, { |u| If( PCount() > 0, cTpDt := u, cTpDt ) }, aTpDt, 060, nAltCombo, oPanel,,{|| __cTpDt	:= cTpDt },,,,.T.,,,,{|| .T.},,,,, "cTpDt" )

/*
    Período
*/
oSay7   := TSay():New( 150, 100, { || STR0024 }, oPanel,,,,,, .T. )  // "Data Inicial"
oGet7   := TGet():New( 158, 100, { |u| If( PCount() > 0, dInicial := u, dInicial ) }, oPanel, 060, nAltGet,,{|| ValPeriodo(dInicial , @dFinal, Empty(dSitEsp)) },,,,,,.T.,,,{|| .T.},,, {|| __dInicial := dInicial},,,,"dInicial" )

oSay8   := TSay():New( 150, 190, { || STR0025 }, oPanel,,,,,, .T. )  // "Data Final"
oGet8   := TGet():New( 158, 190, { |u| If( PCount() > 0, dFinal := u, dFinal ) }, oPanel, 060, nAltGet,,{|| ValPeriodo(dInicial , @dFinal, Empty(dSitEsp)) },,,,,,.T.,,,{|| .T.},,, {|| __dFinal := dFinal},,,,"dFinal" )

Return

//------------------------------------------------------------------------------
/*/	{Protheus.doc} ValCodPes

Validar Codigo Pessoa Digitado na tela

@sample     
@return		
@author		rafael rondon
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function ValCodPes(cCodPes As Character, cNomPes As Character) As Logical

Local lRet      As Logical
Local aArea     As Array

__cCodPes := cCodPes

aArea := GetArea()
lRet := .F.

DbSelectArea('FVU')
FVU->(DbSetOrder(1))
If FVU->(DbSeek( xFilial('FVU') + cCodPes))
    If FVU->FVU_TIPCAD == '1'
        lRet := .T.
        cNomPes := FVU->FVU_NOME
    Else
        Help(' ',1,STR0026 ,,STR0027,2,0,) // 'Declarante' ## 'O Declarante deve estar marcado como Declarante no Cadastro de Pessoas'
    EndIf    
Else
    Help(' ',1,STR0028 ,,STR0029,2,0,) // 'Não Encontrado' ## 'Registro não encontrado o Cadastro de Pessoas'
EndIf

RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/	{Protheus.doc} ValPeriodo

Validar Período

@sample     
@return		
@author		rafael rondon
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function ValPeriodo( dInicial As Date, dFinal As Date, lSemdEsp As Logical ) As Logical

Local lRet      As Logical
Local cYear		As Character

Default lSemdEsp	:= .F.

lRet 		:= .T.
__dInicial	:= dInicial

If !Empty(dInicial)
	If !Empty(dFinal)
		If dInicial > dFinal
			lRet := .F.
			Help(' ',1,STR0030 ,,STR0031,2,0,) // 'Período' ## 'Data Inicial não pode ser maior que a data final!'
		EndIf
	ElseIf lSemdEsp
		cYear	:= AllTrim(Str(Year(dInicial)))
		__dFinal := dFinal 	:= CTOD('31/12/' + cYear)
	EndIf
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/	{Protheus.doc} ValStep2

Validar Step2

@sample     
@return		
@author		rafael rondon
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function ValStep2() As Logical

Local lRet      As Logical

lRet := .T.

If Empty(__cCodPes) .OR. Empty(__cFormApu) .OR. ( Empty(__cSitEsp) .OR. ( __cSitEsp <> "0" .AND. Empty(__dSitEsp)) ) .OR. Empty(__cIniPer) .OR. Empty(__cTpDt) .OR. Empty(__dInicial) .OR. Empty(__dFinal)
    lRet := .F.
    Help(' ',1,STR0032 ,,STR0033,2,0,) // 'Preenchimento' ## 'Existe campo na tela sem preenchimento!'
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/	{Protheus.doc} Step3

Interface Step3

@sample     
@return		
@author		rafael rondon
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function Step3( oPanel As Object , cCodPes As Character , aImoveis As Array )

Local oOk      		As Object
Local oNo      		As Object
Local oImoveis      As Object

Default cCodPes	:= __cCodPes

oOk      		:= LoadBitMap(GetResources(), "LBOK")
oNo      		:= LoadBitMap(GetResources(), "LBNO")
aImoveis        := GetImoveis(cCodPes)

oImoveis := TWBrowse():New( 010 , 010 , (oPanel:nClientWidth/2 - 020) , oPanel:nClientHeight/2 - 020  ,,,,oPanel,,,,,{|| IIF(!Empty(aImoveis[oImoveis:nAt][2]), aImoveis[oImoveis:nAt][1] := !aImoveis[oImoveis:nAt][1] , '') , oImoveis:Refresh() },,,,,,,.F.,,.T.,,.F.,,, )
oImoveis:SetArray(aImoveis)

oImoveis:AddColumn(TCColumn():New(""						, {|| Iif(aImoveis[oImoveis:nAt][1],oOK,oNO)}	,,,,'CENTER'	,20,.T.,.F.,,,,.F.,))
oImoveis:AddColumn(TCColumn():New(STR0034 /*"Filial"*/  	, {|| aImoveis[oImoveis:nAt][2] }	,,,,'LEFT'	    ,40,.F.,.F.,,,,.F.,))
oImoveis:AddColumn(TCColumn():New(STR0035 /*"Nome"*/	    , {|| aImoveis[oImoveis:nAt][4] }	,,,,'LEFT'	    ,70,.F.,.F.,,,,.F.,))
oImoveis:AddColumn(TCColumn():New(STR0036 /*"Endereço"*/    , {|| AllTrim(aImoveis[oImoveis:nAt][5]) + ', ' + cValToChar(aImoveis[oImoveis:nAt][6]) }	,,,,'LEFT'	    ,120,.F.,.F.,,,,.F.,))
oImoveis:AddColumn(TCColumn():New(STR0037 /*"Bairro"*/	    , {|| aImoveis[oImoveis:nAt][7] }	,,,,'LEFT'	    ,70,.F.,.F.,,,,.F.,))
oImoveis:AddColumn(TCColumn():New(STR0038 /*"Bloqueado?"*/  , {|| aImoveis[oImoveis:nAt][8] }	,,,,'LEFT'	    ,5,.F.,.F.,,,,.F.,))

Return

//------------------------------------------------------------------------------
/*/	{Protheus.doc} Step4

Interface Step4

@sample     
@return		
@author		rafael rondon
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function Step4( oPanel As Object , aBancos As Array )

Local oOk      		As Object
Local oNo      		As Object
Local oBancos       As Object

oOk      		:= LoadBitMap(GetResources(), "LBOK")
oNo      		:= LoadBitMap(GetResources(), "LBNO")
aBancos         := GetBancos()

oBancos := TWBrowse():New( 010 , 010 , (oPanel:nClientWidth/2 - 020) , oPanel:nClientHeight/2 - 020  ,,,,oPanel,,,,,{|| IIF(!Empty(aBancos[oBancos:nAt][2]), aBancos[oBancos:nAt][1] := !aBancos[oBancos:nAt][1] , '') , oBancos:Refresh() },,,,,,,.F.,,.T.,,.F.,,, )
oBancos:SetArray(aBancos)

oBancos:AddColumn(TCColumn():New(""						, {|| IIF(aBancos[oBancos:nAt][1],oOK,oNO)}	,,,,'CENTER'	,20,.T.,.F.,,,,.F.,))
oBancos:AddColumn(TCColumn():New(STR0054		       	, {|| aBancos[oBancos:nAt][2] }	,,,,'LEFT'	    ,40,.F.,.F.,,,,.F.,)) // 'Cód. Banco' 
oBancos:AddColumn(TCColumn():New(STR0055        	    , {|| aBancos[oBancos:nAt][3] }	,,,,'LEFT'	    ,70,.F.,.F.,,,,.F.,)) // 'Banco'
oBancos:AddColumn(TCColumn():New(STR0056	            , {|| aBancos[oBancos:nAt][4] },,,,'LEFT'	    ,40,.F.,.F.,,,,.F.,)) // 'Agência'
oBancos:AddColumn(TCColumn():New(STR0057        	    , {|| aBancos[oBancos:nAt][5] }	,,,,'LEFT'	    ,50,.F.,.F.,,,,.F.,)) // 'Conta'
oBancos:AddColumn(TCColumn():New(STR0034        	    , {|| aBancos[oBancos:nAt][7] }	,,,,'LEFT'		,50,.F.,.F.,,,,.F.,)) // 'Filial'

Return

//------------------------------------------------------------------------------
/*/	{Protheus.doc} Step5

Interface Step5

@sample     
@return		
@author		rafael rondon
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function Step5( oPanel As Object , cContador As Character , cDirlocal As Character, lCSV As Logical )

Local oSay1         As Object
Local oSay2         As Object
// Local oSay3         As Object
Local oGet1         As Object
Local oGet2         As Object
Local oGet3         As Object
Local oChk          As Object
Local oButton       As Object
Local cNomCont      As Character
Local nAltGet       As Numeric

cContador   := Space(TamSX3('CVB_CODCTB')[1])
cNomCont    := Space(TamSX3('CVB_NOME')[1])
nAltGet     := 13

oSay1   := TSay():New( 35, 10, { || STR0039 }, oPanel,,,,,, .T. )  // "Cód. Contador"
oGet1   := TGet():New( 43, 10, { |u| If( PCount() > 0, cContador := u, cContador ) }, oPanel, 060, nAltGet,,{|| ValContador(cContador,@cNomCont) },,,,,,.T.,,,{|| .T.},,,,,,,"cContador" )
oGet1:cF3 := 'CVB'

oSay2   := TSay():New( 35, 100, { || STR0040 }, oPanel,,,,,, .T. )  // "Nome Contador"
oGet2   := TGet():New( 43, 100, { |u| If( PCount() > 0, cNomCont := u, cNomCont ) }, oPanel, 100, nAltGet,,,,,,,,.T.,,,{|| .F.},,,,,,,"cNomCont" )

oChk   := TCheckBox():New( 150, 10, 'Gera .CSV',bSETGET(lCSV) /*{|u| If(PCount()>0,lCheck:=u,lCheck), GeraCSV(lCheck) }*/,oPanel,150,10,,,,,,,,.T.,,,)

oButton := TButton():New( 90, 10 , STR0041,oPanel,{ || cDirlocal := cGetFile('',STR0042,0,,.F.,GETF_LOCALHARD+ GETF_RETDIRECTORY+GETF_NETWORKDRIVE) }, 70, nAltGet + 2 ,,,.F.,.T.,.F.,,.F.,,,.F. )    // "Salvar arquivo em.." ## "Selecione onde Salvar os arquivos"
oGet3   := TGet():New( 90, 100, { |u| If( PCount() > 0, cDirlocal := u, cDirlocal ) }, oPanel, 150, nAltGet,,,,,,,,.T.,,,{|| .F.},,,,,,,"cDirlocal" )

Return

//------------------------------------------------------------------------------
/*/	{Protheus.doc} GetImoveis

Retorna Imóveis da Pessoa Passada FVU

@sample     
@return		
@author		rafael rondon
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function GetImoveis( cCodPes As Character ) As Array

Local aImoveis  As Array
Local aArea     As Array
Local cQuery    As Character
Local cAliasQry As Character

aImoveis	:= {}
aArea		:= GetArea()
cQuery      := ""
cAliasQry   := GetNextAlias()

BeginSql Alias cAliasQry
    SELECT FVV_FILIAL , FVV_CODIGO , FVV_NOME , FVV_END , FVV_NUM , FVV_BAIRRO , FVV_MSBLQL , FVV_CODPES, '  ' FVGCODPES, FVV_VERSAO VER
    FROM %table:FVV% FVV
    WHERE FVV_CODPES = %exp:cCodPes%
    AND FVV.%notDel%
    UNION ALL
    SELECT FVV_FILIAL , FVV_CODIGO , FVV_NOME , FVV_END , FVV_NUM , FVV_BAIRRO , FVV_MSBLQL , FVV_CODPES, FVG_CODPES FVGCODPES, FVG_VERSAO VER
    FROM %table:FVV% FVV,
    	%table:FVG% FVG
    WHERE FVG_CODPES = %exp:cCodPes%
    AND FVG_VERSAO = FVV_VERSAO
    AND FVG_CODIMO = FVV_CODIGO
    AND FVG_TPPES = '1'
    AND FVV.%notDel%
    AND FVG.%notDel%
    ORDER BY FVV_FILIAL, VER DESC
EndSql

While (cAliasQry)->(!Eof())
    If ( aScan( aImoveis, { |x| X[2] == (cAliasQry)->FVV_FILIAL} ) ) == 0
        If ( (cAliasQry)->FVV_CODPES == cCodPes )
            AADD( aImoveis , {     Iif( (cAliasQry)->FVV_MSBLQL == '1' , .F. , .T.) , ;
                                (cAliasQry)->FVV_FILIAL                             , ;
                                (cAliasQry)->FVV_CODIGO                             , ;
                                (cAliasQry)->FVV_NOME                               , ;
                                (cAliasQry)->FVV_END                                , ;
                                (cAliasQry)->FVV_NUM                                , ;
                                (cAliasQry)->FVV_BAIRRO                             , ;
                                Iif( (cAliasQry)->FVV_MSBLQL == '1' , STR0058 , STR0059), ; // 'Sim' ## 'Não'
                                (cAliasQry)->FVV_CODPES 							} )
        ElseIf ( (cAliasQry)->FVGCODPES == cCodPes )
            AADD( aImoveis , {     Iif( (cAliasQry)->FVV_MSBLQL == '1' , .F. , .T.) , ;
                                (cAliasQry)->FVV_FILIAL                             , ;
                                (cAliasQry)->FVV_CODIGO                             , ;
                                (cAliasQry)->FVV_NOME                               , ;
                                (cAliasQry)->FVV_END                                , ;
                                (cAliasQry)->FVV_NUM                                , ;
                                (cAliasQry)->FVV_BAIRRO                             , ;
                                Iif( (cAliasQry)->FVV_MSBLQL == '1' , STR0058 , STR0059), ; // 'Sim' ## 'Não'
                                (cAliasQry)->FVGCODPES 								} )
        EndIf
            
        (cAliasQry)->(DbSkip())
    Else
        (cAliasQry)->(DbSkip())
    EndIf
EndDo

(cAliasQry)->(DbCloseArea())

If Len(aImoveis) == 0
    AADD( aImoveis , {  .F. , ;
                        ''  , ;
                        ''  , ;
                        ''  , ;
                        ''  , ;
                        0   , ;
                        ''  , ;
                        ''  , ;
                        ''  } )
EndIf

RestArea(aArea)

Return aImoveis

//------------------------------------------------------------------------------
/*/	{Protheus.doc} ValContador

Validar Contador

@sample     
@return		
@author		rafael rondon
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function ValContador( cContador As Character , cNomCont As Character ) As Logical

Local lRet      As Logical
Local aArea     As Array

aArea := GetArea()
lRet := .F.

If !Empty(cContador)
    DbSelectArea('CVB')
    CVB->(DbSetOrder(1))
    If CVB->(DbSeek( xFilial('CVB') + cContador ))
        lRet := .T.
        cNomCont := CVB->CVB_NOME
    Else
        lRet := .F.
        Help(' ',1,STR0043 ,,STR0029,2,0,)    // 'Não Encontrado' ## 'Registro não encontrado no Cadastro de Pessoas.'
    EndIf
Else
	cNomCont	:= ""
    lRet 		:= .T.
EndIf

RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/	{Protheus.doc} ValStep3

Validar Step3

@sample     
@return		
@author		rafael rondon
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function ValStep3( aImoveis As Array , cCodPes As Character ) As Logical

Local lRet      As Logical
Local nI        As Numeric

Default cCodPes	:= __cCodPes

lRet := .F.

If Len(aImoveis) > 0
    If aImoveis[1][9] == cCodPes    // Caso Retrocedeu a tela e alterou o Proprietário, os imóveis já foram carregados de outro proprietário
        For nI := 1 To Len(aImoveis)        
            If aImoveis[nI][1]     // Marcado
                lRet := .T.
                Exit
            EndIf
        Next nI
        If !lRet
            Help(' ',1,STR0045 ,,STR0046,2,0,)    // 'Imóveis' ## 'Selecionar pelo menos 1 imóvel para continuar!'
        EndIf
    Else
        Help(' ',1,STR0045 ,,STR0047,2,0,)     // 'Imóveis' ## 'Os imóveis selecionados não são do proprietário!'
    EndIf
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/	{Protheus.doc} ValStep4

Validar Step4

@sample     
@return		
@author		rafael rondon
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function ValStep4( aBancos As Array ) As Logical

Local lRet      As Logical
Local nI        As Numeric

lRet := .F.

For nI := 1 To Len(aBancos)        
    If aBancos[nI][1]     // Marcado
        lRet := .T.
        Exit
    EndIf
Next nI
If !lRet
    Help(' ',1, STR0055,, STR0060,2,0,)    // 'Banco' ## 'Selecionar pelo menos 1 banco para continuar.'
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/	{Protheus.doc} ValStep5

Validar Step5

@sample     
@return		
@author		rafael rondon
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function ValStep5(cDirlocal As Character) As Logical

Local lRet      As Logical

lRet := .T.

If Empty(cDirlocal)
    lRet := .F.    
    Help(' ',1,STR0048 ,,STR0049,2,0,)     // 'Diretório' ## 'Favor selecionar a pasta onde será salvo o arquivo.'
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/	{Protheus.doc} GetBancos

Retorna Bancos próprios

@sample     
@return		
@author		rafael rondon
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function GetBancos() As Array

Local aBancos       As Array
Local aArea         As Array
Local cQuery        As Character
Local cAliasQry     As Character
Local cExpPropri    As Character
Local cCpos         As Character
Local cGroup        As Character
Local lExstCpoA6    As Logical

aBancos 	:= {}
aArea		:= GetArea()
cQuery      := ""
cCpos       := ""
cGroup      := ""
cAliasQry   := GetNextAlias()
cExpPropri  := '1'
lExstCpoA6  := SA6->(ColumnPos("A6_BCOOFI")) > 0

If lExstCpoA6
    cCpos   := "%A6_PAISCTA, A6_COD, A6_NOME, A6_AGENCIA, A6_NUMCON, A6_DVCTA, A6_FILIAL, A6_BCOOFI%"
    cGroup  := "%A6_PAISCTA, A6_COD, A6_NOME, A6_AGENCIA, A6_NUMCON, A6_DVCTA, A6_FILIAL, A6_BCOOFI%"
Else
    cCpos   := "%A6_PAISCTA, A6_COD, A6_NOME, A6_AGENCIA, A6_NUMCON, A6_DVCTA, A6_FILIAL%"
    cGroup  := "%A6_PAISCTA, A6_COD, A6_NOME, A6_AGENCIA, A6_NUMCON, A6_DVCTA, A6_FILIAL%"
EndIf

BeginSql Alias cAliasQry

    SELECT %Exp:cCpos%
    FROM %table:SA6% SA6
    WHERE A6_PROPRIA = %exp:cExpPropri%
    AND SA6.%notDel%
    GROUP BY %Exp:cGroup%
    ORDER BY SA6.A6_COD , SA6.A6_AGENCIA , SA6.A6_NUMCON

EndSql

While (cAliasQry)->(!Eof())
	AADD( aBancos , {       .T.                                                 , ;
                            (cAliasQry)->A6_COD                                 , ;
                            (cAliasQry)->A6_NOME                                , ;
                            (cAliasQry)->A6_AGENCIA                             , ;
                            (cAliasQry)->A6_NUMCON                              , ;
                            (cAliasQry)->A6_DVCTA	                            , ;
                            (cAliasQry)->A6_FILIAL	                            , ;
                            (cAliasQry)->A6_PAISCTA	                            , ;
                            If(lExstCpoA6, (cAliasQry)->A6_BCOOFI,'')           } )

	(cAliasQry)->(DbSkip())
EndDo

(cAliasQry)->(DbCloseArea())

If Len(aBancos) == 0
    AADD( aBancos , {  .F. , ;
                        ''  , ;
                        ''  , ;
                        ''  , ;
                        ''  , ;
                        ''  , ;
                        ''  , ;
                        ''  , ;
                        ''  } )
EndIf

RestArea(aArea)

Return aBancos

//------------------------------------------------------------------------------
/*/	{Protheus.doc} bDtEsp

When da data de situação especial

@sample     
@return		
@author		Rodrigo Oliveira
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function bDtEsp(dSitEsp As Date, cSitEsp As Character) As Logical
	Local lRet  As Logical
	
	__cSitEsp	:= cSitEsp
	
	If (AllTrim(cSitEsp) == '0')
		__dSitEsp := dSitEsp := CTOD('  /  /  ')
	EndIf
	lRet := !(AllTrim(cSitEsp) == '0' )
Return lRet

//------------------------------------------------------------------------------
/*/	{Protheus.doc} ZeraStatic

Função para zerar variáveis Statics

@sample     
@return		
@author		Rodrigo Oliveira
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function ZeraStatic()

	__cCodPes	:= ""
	__cFormApu	:= ""
	__cSitEsp	:= ""
	__cIniPer	:= ""
    __cTpDt 	:= ""
    __cDevol    := ""
	__dInicial	:= CTOD('  /  /  ')
	__dFinal	:= CTOD('  /  /  ')
	__dSitEsp	:= CTOD('  /  /  ')
    
Return
