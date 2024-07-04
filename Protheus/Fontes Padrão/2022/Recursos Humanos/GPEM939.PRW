#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "GPEM939.CH"

Static aBkpDeptos		:= {}
Static __oStSM0
Static __oStSQ0
Static __oStSQ3
Static __oStSQB

//-------------------------------------------------------------------
/*/{Protheus.doc} GPEM939
Integração com o P&M (Performance & Metas)
@author  Allyson Luiz Mesashi
@since   14/04/2022
/*/
//-------------------------------------------------------------------
Function GPEM939()

Local aParams			:= {}
Local oNewPag   		:= Nil
Local oStepWiz  		:= Nil

Private aJsons      	:= {}
Private aJsonsLote  	:= {}
Private aLogErr       	:= {}
Private aLogFiltro     	:= {}
Private aLogIncon     	:= {}
Private aLogImp       	:= {}
Private aLogPeM       	:= {}
Private aLogProc       	:= {}
Private aPrcId       	:= {}
Private aTitle         	:= { OemToAnsi(STR0032), OemToAnsi(STR0187), OemToAnsi(STR0077), OemToAnsi(STR0033), OemToAnsi(STR0122), OemToAnsi(STR0085) }//"Processamento"##"Erro na integração com o P&M"##Registros Integrados"##"Registros inconsistentes"##"Status do processamento pelo P&M"
Private cAliasTmp		:= GetNextAlias()
Private cTabSQ0			:= RetSqlName("SQ0")
Private cTabSQ3			:= RetSqlName("SQ3")
Private cTabSQB			:= RetSqlName("SQB")
Private cTabSR7			:= RetSqlName("SR7")
Private cTabSR8			:= RetSqlName("SR8")
Private cTabSRA			:= RetSqlName("SRA")
Private cTabSRD			:= RetSqlName("SRD")
Private cTabSRE			:= RetSqlName("SRE")
Private cTabSX5			:= RetSqlName("SX5")
Private cTimeIni		:= ""
Private lInExec			:= .F.
Private lIntegrou		:= .F.
Private lSQ0Msbql		:= SQ0->( ColumnPos( "Q0_MSBLQL" ) ) > 0
Private lSQ3Msbql		:= SQ3->( ColumnPos( "Q3_MSBLQL" ) ) > 0
Private lSQBMsbql		:= SQB->( ColumnPos( "QB_MSBLQL" ) ) > 0
Private lTemREN			:= ChkFile("REN")
Private oProfile		:= FwProfile():New()
Private nContLote   	:= 0
Private nQtdSel 		:= 0
Private nRemoteType		:= GetRemoteType()
Private nTamLote      	:= 100
Private nTotInteg 		:= 0
Private nTotProc 		:= 0
Private oArqTmp			:= Nil

//Parametrização
Private aOpcAtiv		:= {STR0035, STR0036}//"Somente pelo campo MSBLQL (se houver)"##"Campo MSBLQL (se houver) + vínculo com registro ativo da SRA"
Private aOpcReto		:= {STR0086, STR0087}//"Aguardar o retorno do P&M"##"Não aguardar o retorno do P&M"
Private cPMToken		:= SuperGetMv( 'MV_APIPEM0', Nil, "" )
Private cPMURL			:= SuperGetMv( 'MV_APIPEM1', Nil, "" )
Private cOpcAtiv		:= ""
Private cOpcReto		:= ""
Private cOpcVis			:= Space(TamSX3("RDK_CODIGO")[1])
Private cOrgCfg			:= SuperGetMv( 'MV_ORGCFG', Nil, "0" )
Private cPMClient		:= SuperGetMv( 'MV_APIPEM2', Nil, "" )
Private cPMSecret		:= SuperGetMv( 'MV_APIPEM3', Nil, "" )
Private dDatCorte		:= cToD("//")
Private nOpcAtiv		:= 0
Private nOpcReto		:= 0
Private nPerSRD			:= 0
Private nTmpLimit		:= 0

//Tela Parametrização
Private oGetAtiv		:= Nil
Private oGetData		:= Nil
Private oGetTemp		:= Nil
Private oSayAtiv		:= Nil
Private oSayData		:= Nil
Private oSayExec		:= Nil
Private oSayReto		:= Nil
Private oSayTemp		:= Nil

//Tela Opções
Private lIntAfas 		:= .F.
Private lIntCarg 		:= .F.
Private lIntContr 		:= .F.
Private lIntDepto 		:= .F.
Private lIntFalta 		:= .F.
Private lIntFil 		:= .F.
Private lIntFunc 		:= .F.
Private lIntGrp 		:= .F.
Private lIntHCarg 		:= .F.
Private lIntHDep 		:= .F.
Private lIntHFil 		:= .F.
Private lIntHGrp 		:= .F.
Private lIntLider 		:= .F.
Private oChkAfas		:= Nil
Private oChkCarg		:= Nil
Private oChkContr		:= Nil
Private oChkDep			:= Nil
Private oChkFalta		:= Nil
Private oChkFil			:= Nil
Private oChkFunc		:= Nil
Private oChkGrp			:= Nil
Private oChkHCarg		:= Nil
Private oChkHDep		:= Nil
Private oChkHFil		:= Nil
Private oChkHGrp		:= Nil
Private oChkInv			:= Nil
Private oChkLider		:= Nil

//Tela Filtro
Private aArrayFil		:= {}
Private cFltAfas		:= ""
Private cFltCarg		:= ""
Private cFltDep			:= ""
Private cFltFalta		:= ""
Private cFltFunc		:= ""
Private cFltGrp			:= ""
Private cFltHCarg		:= ""
Private cFltHDep		:= ""
Private cFltHFil		:= ""
Private cFltHGrp		:= ""
Private cFltLider		:= ""
Private oButAfas		:= Nil
Private oButCarg		:= Nil
Private oButDep			:= Nil
Private oButFalta		:= Nil
Private oButFil			:= Nil
Private oButFunc		:= Nil
Private oButGrp			:= Nil
Private oButHCarg		:= Nil
Private oButHDep		:= Nil
Private oButHFil		:= Nil
Private oButHGrp		:= Nil
Private oButLider		:= Nil

//Tela Processamento
Private oButtonProc		:= Nil
Private oSayProc		:= Nil
Private oSaySep			:= Nil

If !ChkFile("REF")
	//"Atenção"###"A tabela REF não existe no dicionário. É necessário atualização do ambiente para acesso à rotina"###"Contate o administrador do sistema para efetuar a atualização do ambiente"
	Help( " ", 1, OemToAnsi(STR0001), Nil, OemToAnsi(STR0002), 1, 0, Nil, Nil, Nil, Nil, Nil, { OemToAnsi(STR0003) } )
	Return .F.
EndIf

If !Empty( xFilial("REF") )
	//"Atenção"###"A Tabela REF deve possuir modo de acesso compartilhado"###"Contate o administrador do sistema para efetuar a correção do ambiente"
	Help( " ", 1, OemToAnsi(STR0001), Nil, OemToAnsi(STR0070), 1, 0, Nil, Nil, Nil, Nil, Nil, { OemToAnsi(STR0071) } )
	Return .F.
EndIf

If SQ0->( EoF() )
	//"Atenção"###"O cadastro de grupos de cargo é obrigatório para a integração"###"Realize o cadastro de grupos de cargo e o vínculo dos grupos nos cargos"
	Help( " ", 1, OemToAnsi(STR0001), Nil, OemToAnsi(STR0081), 1, 0, Nil, Nil, Nil, Nil, Nil, { OemToAnsi(STR0082) } )
	Return .F.
EndIf

If Empty(cPMToken) .Or. Empty(cPMURL) .Or. Empty(cPMClient) .Or. Empty(cPMSecret)
	//"Atenção"###"Os parâmetros MV_APIPEM0, MV_APIPEM1, MV_APIPEM2 e/ou MV_APIPEM3 não estão preenchidos."###"Contate o administrador do sistema para revisar a configuração dos parâmetros MV_APIPEM0, MV_APIPEM1, MV_APIPEM2 e/ou MV_APIPEM3 no módulo Configurador"
	Help( " ", 1, OemToAnsi(STR0001), Nil, OemToAnsi(STR0013), 1, 0, Nil, Nil, Nil, Nil, Nil, { OemToAnsi(STR0072) } )
	Return .F.
EndIf

oProfile:SetUser( RetCodUsr() )
oProfile:SetProgram( "GPEM939" )
oProfile:SetTask( "GPEM939PARAM" )

aParams := oProfile:Load()
If !Empty(aParams)
	cOpcAtiv	:= Iif( aParams[1] == 0 .Or. aParams[1] == 1, STR0035, STR0036 )//"Somente pelo campo MSBLQL (se houver)"##"Campo MSBLQL (se houver) + vínculo com registro ativo da SRA"
	dDatCorte	:= aParams[2]
	cOpcReto	:= Iif( aParams[3] == 0 .Or. aParams[3] == 1, STR0086, STR0087 )//"Aguardar o retorno do P&M"##"Não aguardar o retorno do P&M"
	nTmpLimit	:= aParams[4]
	nPerSRD		:= aParams[5]
	If Len(aParams) >= 6
		cOpcVis	:= aParams[6]
	EndIf
EndIf

fCriaTmp()//Criação de tabela temporária para a MarkBrowse de seleção de filiais

oStepWiz := FWWizardControl():New()
oStepWiz:ActiveUISteps()

oNewPag := oStepWiz:AddStep( "1" )
oNewPag:SetStepDescription( STR0004 )//"Observações"
oNewPag:SetConstruction( { |Panel1| fPag1(Panel1) } )
oNewPag:SetNextAction( { || !PrcExec() } )
oNewPag:SetCancelAction( { || .T.} )

oNewPag := oStepWiz:AddStep( "2" )
oNewPag:SetStepDescription( STR0005 )//"Configuração"
oNewPag:SetConstruction( { |Panel2| fPag2(Panel2) } )
oNewPag:SetNextAction( { || fVldConf() .And. !PrcExec() } )
oNewPag:SetCancelAction( {|| .T. })

oNewPag := oStepWiz:AddStep( "3" )
oNewPag:SetStepDescription( STR0006 )//"Opções"
oNewPag:SetConstruction( { |Panel3| fPag3(Panel3) } )
oNewPag:SetNextAction( { || fVldOpc() .And. !PrcExec() } )
oNewPag:SetCancelAction( { || .T. })

oNewPag := oStepWiz:AddStep( "4" )
oNewPag:SetStepDescription( STR0057 )//"Filtro"
oNewPag:SetConstruction( { |Panel4| fPag4(Panel4) } )
oNewPag:SetNextAction( { || fVldOpc() .And. fVldFil() .And. !PrcExec() } )
oNewPag:SetCancelAction( { || .T. })

oNewPag := oStepWiz:AddStep( "5" )
oNewPag:SetStepDescription( STR0007 )//"Processamento"
oNewPag:SetConstruction( { |Panel5| fPag5(Panel5) } )
oNewPag:SetPrevAction( { || PrcConcl() } )
oNewPag:SetNextAction( { || !PrcInt() } )
oNewPag:SetCancelAction( { || .T. })

oNewPag:SetPrevWhen( { || !PrcExec() } )
oNewPag:SetCancelWhen( { || !PrcExec() } )

oStepWiz:Activate()

oProfile:DeActivate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fPag1
Painel com os descritivos do assistente
@author  Allyson Luiz Mesashi
@since   14/04/2022
/*/
//-------------------------------------------------------------------
Static Function fPag1(oPanel)

Local oButtonProc	:= Nil

TSay():New( 25, 20, { || fText("BEMVINDO") }, oPanel, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 300, 300, Nil, Nil, Nil, Nil, Nil, .T. )
TSay():New( 45, 20, { || fText("ASSIST") }, oPanel, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 300, 300, Nil, Nil, Nil, Nil, Nil, .T. )

oButtonProc  := TButton():New( 120, 25, OemToAnsi(STR0008), oPanel, { || ShellExecute( "open", "https://tdn.totvs.com/x/r8WWK", "", "", 1 ) }, 250, 15, Nil, Nil, .F., .T., .F., Nil, .F., Nil, Nil, .F. )//"Clique para abrir a documentação no TDN"

If nRemoteType <> 5
	oButtonProc:setCSS( fCSS("BTPROC") )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fPag2
Painel com a configuração da integração
@author  Allyson Luiz Mesashi
@since   14/04/2022
/*/
//-------------------------------------------------------------------
Static Function fPag2(oPanel)

oSayExec := TSay():New( 20, 10, { || STR0012 }, oPanel, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 200, 20 )//"Parâmetros"
oSayAtiv := TSay():New( 45, 10, { || STR0039 }, oPanel, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 100, 60 )//"Verificação registro ativo: "
oGetAtiv := TComboBox():New( 45, 95, { |u| Iif(PCount() > 0, cOpcAtiv := u, cOpcAtiv ) }, aOpcAtiv, 200, 10, oPanel, Nil, { || fChgAtiv() }, Nil, Nil, Nil, .T., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, 'cOpcAtiv' )
oGetAtiv:bHelp := { || ShowHelpCpo( STR0045, { STR0050, STR0051, STR0052 }, 2, {""}, 2 ) }//"Verificação"##"Define o tipo de verificação que será realizado para verificar se o registro está ativo:"##"Só MSBLQL - Se o campo MSBLQL estiver habilitado, somente será integrado se o registro está ativo."##"Vinc. SRA - Além da verificação do campo MSBLQL, também será verificado se existe funcionário ativo vinculado ao registro."
oSayData := TSay():New( 65, 10, { || STR0040 }, oPanel, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 100, 60 )//"Data de corte demissão: "
oGetData := TGet():New( 65, 95, { |u| Iif( PCount() == 0, dDatCorte, dDatCorte := u ) }, oPanel, 200, 10, "@D", Nil , 0, Nil, Nil, .F., Nil, .T., Nil, .F., { || cOpcAtiv != STR0035 }, .F., .F., Nil, .F., .F., Nil, 'dDatCorte' )//"Somente pelo campo MSBLQL (se houver)"
oGetData:bHelp := { || ShowHelpCpo( STR0046, { STR0053 }, 2, {""}, 2 ) }//"Data"##'Caso a pergunta "Verificação registro ativo?" esteja preenchida com "Vinc. SRA", também será considerado como ativo os funcionário demitidos a partir da data de corte informada'
oSayReto := TSay():New( 85, 10, { || STR0088 }, oPanel, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 100, 60 )//"Verificação retorno P&M: "
oGetReto := TComboBox():New( 85, 95, { |u| Iif(PCount() > 0, cOpcReto := u, cOpcReto ) }, aOpcReto, 200, 10, oPanel, Nil, { || fChgTmpL() }, Nil, Nil, Nil, .T., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, 'cOpcReto' )
oGetReto:bHelp := { || ShowHelpCpo( STR0089, { STR0090, STR0091, STR0092 }, 2, {""}, 2 ) }//"Retorno"##"Define o tipo de verificação do retorno do P&M que será realizado:"##"Aguardar o retorno do P&M - Espera até que haja retorno do processamento da integração pelo P&M"##"Não aguardar o retorno do P&M - Não espera o retorno do processamento da integração pelo P&M."
oSayTemp := TSay():New( 105, 10, { || STR0102 }, oPanel, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 100, 60 )//"Tempo limite (em minutos): "
oGetTemp := TGet():New( 105, 95, { |u| Iif( PCount() == 0, nTmpLimit, nTmpLimit := u ) }, oPanel, 200, 10, "@E 99", Nil , 0, Nil, Nil, .F., Nil, .T., Nil, .F., { || cOpcReto == STR0086 }, .F., .F., Nil, .F., .F., Nil, 'nTmpLimit' )//"Aguardar o retorno do P&M"
oGetTemp:bHelp := { || ShowHelpCpo( STR0103, { STR0104 }, 2, {""}, 2 ) }//"Tempo"##"Define o tempo limite em minutos que a rotina irá aguardar para o retorno do status de integração pelo P&M."
oSayPer := TSay():New( 125, 10, { || STR0243 }, oPanel, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 100, 60 )//"Período de faltas: "
oGetPer := TGet():New( 125, 95, { |u| Iif( PCount() == 0, nPerSRD, nPerSRD := u ) }, oPanel, 200, 10, "@E 9999", Nil , 0, Nil, Nil, .F., Nil, .T., Nil, .F., Nil, .F., .F., Nil, .F., .F., Nil, 'nPerSRD' )
oGetPer:bHelp := { || ShowHelpCpo( STR0244, { STR0245 }, 2, {""}, 2 ) }//"Período"##"Define o período de busca das faltas. Será considerado do mês 01 desse período até o mês 12."
If cOrgCfg $ "1/2"
	oSayLid := TSay():New( 145, 10, { || STR0247 }, oPanel, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 100, 60 )//"Código da visão: "
	oGetLid := TGet():New( 145, 95, { |u| Iif( PCount() == 0, cOpcVis, cOpcVis := u ) }, oPanel, 200, 10, "@!", { || Vazio() .OR. ExistCpo("RDK") } , 0, Nil, Nil, .F., Nil, .T., Nil, .F., Nil, .F., .F., Nil, .F., .F., Nil, 'cOpcVis' )
	oGetLid:bHelp 	:= { || ShowHelpCpo( STR0248, { STR0249 }, 2, {""}, 2 ) }//"Visão"##"Define o código da visão com a hierarquia organizacional."
	oGetLid:cF3		:= "RDK"
EndIf

If nRemoteType <> 5
	oSayExec:setCSS( fCSS("TEXTTITLE") )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fPag3
Painel com os descritivos do assistente
@author  Allyson L Mesashi
@since   14/04/2022
/*/
//-------------------------------------------------------------------
Static Function fPag3(oPanel)

Local lTabSel	    := .F.
Local nLin			:= 45
Local oSayExec		:= Nil

oScroll := TScrollArea():New(oPanel, 01, 01, 50, 50)
oScroll:Align := CONTROL_ALIGN_ALLCLIENT

@ 000,000 MSPANEL oPanel2 OF oScroll SIZE 50,220 COLOR CLR_HRED

oScroll:SetFrame( oPanel2 )

oSayExec := TSay():New( 20, 10, { || STR0006 }, oPanel2, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 200, 20 )//"Opções"

oChkGrp := TcheckBox():New( nLin, 10, STR0015, { || lIntFil }, oPanel2, 300, 10, Nil, { || lIntFil := !lIntFil }, Nil, Nil, Nil, Nil,.T., Nil, Nil, Nil, { || .T. } )//"Filiais"
nLin += 10
oChkFil := TcheckBox():New( nLin, 10, STR0014, { || lIntGrp }, oPanel2, 300, 10, Nil, { || lIntGrp := !lIntGrp }, Nil, Nil, Nil, Nil,.T., Nil, Nil, Nil, { || .T. } )//"Grupo de cargos"
nLin += 10
oChkDep := TcheckBox():New( nLin, 10, STR0017, { || lIntCarg }, oPanel2, 300, 10, Nil, { || lIntCarg := !lIntCarg }, Nil, Nil, Nil, Nil,.T., Nil, Nil, Nil, { || .T. } )//"Cargos"
nLin += 10
oChkCarg := TcheckBox():New( nLin, 10, STR0016, { || lIntDepto }, oPanel2, 300, 10, Nil, { || lIntDepto := !lIntDepto }, Nil, Nil, Nil, Nil,.T., Nil, Nil, Nil, { || .T. } )//"Departamentos"
nLin += 10
oChkContr := TcheckBox():New( nLin, 10, STR0192, { || lIntContr }, oPanel2, 300, 10, Nil, { || lIntContr := !lIntContr }, Nil, Nil, Nil, Nil,.T., Nil, Nil, Nil, { || .T. } )//"Grupos de contrato"
nLin += 10
oChkFunc := TcheckBox():New( nLin, 10, STR0018, { || lIntFunc }, oPanel2, 300, 10, Nil, { || lIntFunc := !lIntFunc }, Nil, Nil, Nil, Nil,.T., Nil, Nil, Nil, { || .T. } )//"Funcionários"
nLin += 10
oChkHFil := TcheckBox():New( nLin, 10, STR0214, { || lIntHFil }, oPanel2, 300, 10, Nil, { || lIntHFil := !lIntHFil }, Nil, Nil, Nil, Nil,.T., Nil, Nil, Nil, { || .T. } )//"Movimentação de filiais"
nLin += 10
oChkHGrp := TcheckBox():New( nLin, 10, STR0221, { || lIntHGrp }, oPanel2, 300, 10, Nil, { || lIntHGrp := !lIntHGrp }, Nil, Nil, Nil, Nil,.T., Nil, Nil, Nil, { || .T. } )//"Movimentação de grupos de cargo"
nLin += 10
oChkHCarg := TcheckBox():New( nLin, 10, STR0200, { || lIntHCarg }, oPanel2, 300, 10, Nil, { || lIntHCarg := !lIntHCarg }, Nil, Nil, Nil, Nil,.T., Nil, Nil, Nil, { || .T. } )//"Movimentação de cargos"
nLin += 10
oChkHDep := TcheckBox():New( nLin, 10, STR0207, { || lIntHDep }, oPanel2, 300, 10, Nil, { || lIntHDep := !lIntHDep }, Nil, Nil, Nil, Nil,.T., Nil, Nil, Nil, { || .T. } )//"Movimentação de departamentos"
nLin += 10
oChkAfas := TcheckBox():New( nLin, 10, STR0229, { || lIntAfas }, oPanel2, 300, 10, Nil, { || lIntAfas := !lIntAfas }, Nil, Nil, Nil, Nil,.T., Nil, Nil, Nil, { || .T. } )//"Afastamentos"
nLin += 10
oChkFalta := TcheckBox():New( nLin, 10, STR0236, { || lIntFalta }, oPanel2, 300, 10, Nil, { || lIntFalta := !lIntFalta }, Nil, Nil, Nil, Nil,.T., Nil, Nil, Nil, { || .T. } )//"Faltas"
nLin += 10
oChkLider := TcheckBox():New( nLin, 10, STR0250, { || lIntLider }, oPanel2, 300, 10, Nil, { || lIntLider := !lIntLider }, Nil, Nil, Nil, Nil,.T., Nil, Nil, Nil, { || .T. } )//"Líder dos funcionários"

nLin += 20
oChkInv := TcheckBox():New( nLin, 10, STR0019, { || lTabSel }, oPanel, 300, 10, Nil, { || fInverte(@lTabSel) }, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, Nil )//"Inverte seleção"

If nRemoteType <> 5
	oSayExec:setCSS( fCSS("TEXTTITLE") )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fPag4
Painel com os filtros
@author  Allyson Luiz Mesashi
@since   14/04/2022
/*/
//-------------------------------------------------------------------
Static Function fPag4(oPanel)

Local nLin			:= 45
Local oSayExec		:= Nil

oScroll := TScrollArea():New(oPanel, 01, 01, 50, 50)
oScroll:Align := CONTROL_ALIGN_ALLCLIENT

@ 000,000 MSPANEL oPanel2 OF oScroll SIZE 50,300 COLOR CLR_HRED

oScroll:SetFrame( oPanel2 )

oSayExec := TSay():New( 20, 10, { || STR0058 }, oPanel2, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 200, 20 )//"Filtros"

oButFil  := TButton():New( nLin, 25, OemToAnsi(STR0059), oPanel2, { || fSelFil() }, 250, 15, Nil, Nil, .F., .T., .F., Nil, .F., Nil, Nil, .F.)//"Filtro de Filiais"
nLin += 20
oButGrp  := TButton():New( nLin, 25, OemToAnsi(STR0060), oPanel2, { || GpFltBldExp( "SQ0" , NIL , @cFltGrp , NIL ) }, 250, 15, Nil, Nil, .F., .T., .F., Nil, .F., Nil, Nil, .F.)//"Filtro de Grupos de cargo"
nLin += 20
oButCarg := TButton():New( nLin, 25, OemToAnsi(STR0062), oPanel2, { || GpFltBldExp( "SQ3" , NIL , @cFltCarg , NIL ) }, 250, 15, Nil, Nil, .F., .T., .F., Nil, .F., Nil, Nil, .F.)//"Filtro de Cargos"
nLin += 20
oButDep  := TButton():New( nLin, 25, OemToAnsi(STR0061), oPanel2, { || GpFltBldExp( "SQB" , NIL , @cFltDep , NIL ) }, 250, 15, Nil, Nil, .F., .T., .F., Nil, .F., Nil, Nil, .F.)//"Filtro de Departamentos"
nLin += 20
oButFunc := TButton():New( nLin, 25, OemToAnsi(STR0063), oPanel2, { || GpFltBldExp( "SRA" , NIL , @cFltFunc , NIL ) }, 250, 15, Nil, Nil, .F., .T., .F., Nil, .F., Nil, Nil, .F.)//"Filtro de Funcionários"
nLin += 20
oButHFil := TButton():New( nLin, 25, OemToAnsi(STR0215), oPanel2, { || GpFltBldExp( "SRE" , NIL , @cFltHFil , NIL ) }, 250, 15, Nil, Nil, .F., .T., .F., Nil, .F., Nil, Nil, .F.)//"Filtro de Movimentação de filiais"
nLin += 20
oButHGrp  := TButton():New( nLin, 25, OemToAnsi(STR0222), oPanel2, { || GpFltBldExp( "SR7" , NIL , @cFltHGrp , NIL ) }, 250, 15, Nil, Nil, .F., .T., .F., Nil, .F., Nil, Nil, .F.)//"Filtro de Movimentação de grupos de cargo"
nLin += 20
oButHCarg := TButton():New( nLin, 25, OemToAnsi(STR0201), oPanel2, { || GpFltBldExp( "SR7" , NIL , @cFltHCarg , NIL ) }, 250, 15, Nil, Nil, .F., .T., .F., Nil, .F., Nil, Nil, .F.)//"Filtro de Movimentação de cargos"
nLin += 20
oButHDep := TButton():New( nLin, 25, OemToAnsi(STR0208), oPanel2, { || GpFltBldExp( "SRE" , NIL , @cFltHDep , NIL ) }, 250, 15, Nil, Nil, .F., .T., .F., Nil, .F., Nil, Nil, .F.)//"Filtro de Movimentação de departamentos"
nLin += 20
oButAfas := TButton():New( nLin, 25, OemToAnsi(STR0230), oPanel2, { || GpFltBldExp( "SR8" , NIL , @cFltAfas , NIL ) }, 250, 15, Nil, Nil, .F., .T., .F., Nil, .F., Nil, Nil, .F.)//"Filtro de Afastamentos"
nLin += 20
oButFalta := TButton():New( nLin, 25, OemToAnsi(STR0237), oPanel2, { || GpFltBldExp( "SRD" , NIL , @cFltFalta , NIL ) }, 250, 15, Nil, Nil, .F., .T., .F., Nil, .F., Nil, Nil, .F.)//"Filtro de Faltas"
nLin += 20
oButLider := TButton():New( nLin, 25, OemToAnsi(STR0251), oPanel2, { || GpFltBldExp( "SRA" , NIL , @cFltLider , NIL ) }, 250, 15, Nil, Nil, .F., .T., .F., Nil, .F., Nil, Nil, .F.)//"Filtro de Líder dos funcionários"

oButGrp:lActive 	:= lIntGrp
oButCarg:lActive 	:= lIntCarg
oButDep:lActive 	:= lIntDepto
oButFunc:lActive 	:= lIntFunc
oButHFil:lActive 	:= lIntHFil
oButHGrp:lActive 	:= lIntHGrp
oButHCarg:lActive 	:= lIntHCarg
oButHDep:lActive 	:= lIntHDep
oButAfas:lActive 	:= lIntAfas
oButFalta:lActive 	:= lIntFalta
oButLider:lActive 	:= lIntLider

If nRemoteType <> 5
	oSayExec:setCSS( fCSS("TEXTTITLE") )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fPag5
Painel com o processamento da integração
@author  Allyson Luiz Mesashi
@since   14/04/2022
/*/
//-------------------------------------------------------------------
Static Function fPag5(oPanel)

TSay():New( 45, 20, { || fText("PROC") }, oPanel, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 300, 300, Nil, Nil, Nil, Nil, Nil, .T. )

oButtonProc  := TButton():New( 100, 25, OemToAnsi(STR0020), oPanel, { || fBarra(oPanel, oButtonProc ) }, 250, 15, Nil, Nil, .F., .T., .F., Nil, .F., Nil, Nil, .F.)//"Clique para efetuar a integração"

If nRemoteType <> 5
	oButtonProc:setCSS( fCSS("BTPROC") )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fCriaTmp
Criação da tabela temporária da SM0
@author  Allyson Luiz Mesashi
@since   14/04/2022
/*/
//-------------------------------------------------------------------
Static Function fCriaTmp()

Local aLstIndices	:= {}
Local aSM0 			:= FWLoadSM0(.T.,,.T.)
Local aStru			:= {}
Local nCont			:= 0

aAdd( aStru, { "OK"		, "C", 2				, 0 } )
aAdd( aStru, { "FILIAL"	, "C", FwGetTamFilial	, 0 } )
aAdd( aStru, { "NOME"  	, "C", 100				, 0 } )
aAdd( aStru, { "CNPJ"  	, "C", 14 				, 0 } )
aAdd( aLstIndices, { "FILIAL" } )

oArqTmp := RhCriaTrab(cAliasTmp, aStru, aLstIndices)

For nCont := 1 To Len(aSM0)
	If aSM0[nCont, 1] == cEmpAnt
		If (cAliasTmp)->( RecLock(cAliasTmp, .T.) )
			(cAliasTmp)->FILIAL	:= aSM0[nCont, 2]
			(cAliasTmp)->NOME  	:= aSM0[nCont, 7]
			(cAliasTmp)->CNPJ 	:= aSM0[nCont, 18]
			(cAliasTmp)->(MsUnlock())
		EndIf
	EndIf
Next nCont

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fText
Formatação do textos dos descritivos do assistente
@author  Allyson Luiz Mesashi
@since   14/04/2022
/*/
//-------------------------------------------------------------------
Static Function fText(cInfo)

Local cRet 		:= ""

If cInfo == "BEMVINDO"
	cRet := '<font size="6" color="#0c9abe"><b>'+STR0009+'</b></font>'//"Bem-vindo..."
	cRet += '<br/>'
ElseIf cInfo == "ASSIST"
	cRet += '<font size="5" color="#888">'+STR0010//"Este é um processo para a integração de registros para o"
	cRet += '<br/>'
	cRet += STR0011//"P&M (Performance e Metas)."
ElseIf cInfo == "PROC"
	cRet += '<font size="5" color="#888">'+STR0037//"Ao clicar no botão abaixo, será iniciado o processo de"
	cRet += '<br/>'
	cRet += STR0038//"integração com o P&M (Performance e Metas)."
EndIf

Return(cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} fCSS
Fonte genérico contendo os Cascade Style (CSS) utilizados nas interfaces
@author  Allyson Luiz Mesashi
@since   14/04/2022
/*/
//-------------------------------------------------------------------
Static Function fCSS(cIDCSS)

Local cCSS := ""

Do Case
	Case cIDCSS == "TEXTTITLE"
		cCSS +=	"QLabel{"
		cCSS += "  font-size: 20;"
		cCSS += "  font-weight: bold;"
		cCSS += "  color: #000000;"
		cCSS += "}"
	Case cIDCSS == "BTPROC"
		cCSS += "QPushButton{ background-color: #3C7799; "
		cCSS += "border: none; "
		cCSS += "color: #FFFFFF;"
		cCSS += "padding: 2px 5px;"
		cCSS += "text-align: center; "
		cCSS += "text-decoration: none; "
		cCSS += "display: inline-block; "
		cCSS += "font-size: 16px; "
		cCSS += "border: 2px solid #3C7799; "
		cCSS += "border-radius: 2px "
		cCSS += "}"
		cCSS += "QPushButton:hover { "
		cCSS += "background-color: #FFFFFF;"
		cCSS += "color: #3C7799;"
		cCSS += "background-repeat: no-repeat;"
		cCSS += "border: 2px solid #3C7799; "
		cCSS += "border-radius: 2px "
		cCSS += "}"
		cCSS +=	"QPushButton:pressed {"
		cCSS +=	"  background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,"
		cCSS +=	"                                    stop: 0 #FFFFFF, stop: 1 #3C7799);"
		cCSS += "color: #000000;"
		cCSS +=	"}"
	Case cIDCSS == "LINESEPARADOR"
		cCSS +=	"QLabel{"
		cCSS += "  font-size: 20;"
		cCSS += "  font-weight: bold;"
		cCSS += "  color: #BBBBBB;"
		cCSS += "}"
EndCase

Return(cCSS)

//-------------------------------------------------------------------
/*/{Protheus.doc} fChgAtiv
Alteração do combobox "Verificação registro ativo: "
@author  Allyson L Mesashi
@since   14/04/2022
/*/
//-------------------------------------------------------------------
Static Function fChgAtiv()

If cOpcAtiv == STR0035//"Somente pelo campo MSBLQL (se houver)"
	dDatCorte := cToD("//")
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fChgAtiv
Alteração do combobox "Verificação registro ativo: "
@author  Allyson L Mesashi
@since   25/04/2022
/*/
//-------------------------------------------------------------------
Static Function fChgTmpL()

If cOpcReto == STR0087//"Não aguardar o retorno do P&M"
	nTmpLimit := 0
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldConf
Valida a configuração
@author  Allyson L Mesashi
@since   14/04/2022
/*/
//-------------------------------------------------------------------
Static Function fVldConf()

Local aParams	:= {}
Local lRet 		:= .T.

If cOpcAtiv == STR0036 .And. Empty(dDatCorte)//"Campo MSBLQL (se houver) + vínculo com registro ativo da SRA"
	lRet := .F.
	MsgInfo(STR0044, STR0001)//"Certifique-se de preencher a data de corte"##"Atenção"	
EndIf

If cOpcReto == STR0086 .And. Empty(nTmpLimit)//"Aguardar o retorno do P&M"
	lRet := .F.
	MsgInfo(STR0101, STR0001)//"Certifique-se de preencher o tempo limite"##"Atenção"	
EndIf

If lRet
	aParams := { Iif( cOpcAtiv == STR0035, 1, 2 ), dDatCorte, Iif( cOpcReto == STR0086, 1, 2 ), nTmpLimit, nPerSRD, cOpcVis }
	oProfile:SetProfile( aParams )
	oProfile:Save()
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fInverte
Função para inverter a seleção dos itens a serem integrados
@author  Allyson Luiz Mesashi
@since   14/04/2022
/*/
//-------------------------------------------------------------------
Static Function fInverte(lRet)

lIntFil := !lIntFil
lIntGrp := !lIntGrp
lIntCarg := !lIntCarg
lIntDepto := !lIntDepto
lIntContr := !lIntContr
lIntFunc := !lIntFunc
lIntHFil := !lIntHFil
lIntHGrp := !lIntHGrp
lIntHCarg := !lIntHCarg
lIntHDep := !lIntHDep
lIntAfas := !lIntAfas
lIntFalta := !lIntFalta
lIntLider := !lIntLider

oChkGrp:Refresh()
oChkFil:Refresh()
oChkDep:Refresh()
oChkCarg:Refresh()
oChkContr:Refresh()
oChkFunc:Refresh()
oChkHFil:Refresh()
oChkHGrp:Refresh()
oChkHCarg:Refresh()
oChkHDep:Refresh()
oChkAfas:Refresh()
oChkFalta:Refresh()
oChkLider:Refresh()

Return !lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldOpc
Valida a seleção de opções
@author  Allyson Luiz Mesashi
@since   14/04/2022
/*/
//-------------------------------------------------------------------
Static Function fVldOpc()

Local lRet := .T.

fContSel()

If Empty(nQtdSel)
	lRet := .F.
	MsgInfo(STR0021, STR0001)//"Certifique-se ao menos de selecionar uma opção para integração"##"Atenção"
EndIf

If lIntFalta .And. Empty(nPerSRD)
	lRet := .F.
	MsgInfo(STR0246, STR0001)//'Certifique-se de preencher a parametrizaçao de "Período de faltas"'
EndIf

If lIntLider .And. cOrgCfg $ "1/2" 
	If Empty(cOpcVis)
		lRet := .F.
		MsgInfo(STR0252, STR0001)//'Certifique-se de preencher a parametrização de "Código da visão"'
	ElseIf cOrgCfg == "1" .And. fDesc("RDK", cOpcVis, "RDK_HIERAR", NIL, cFilAnt, 1) == "1"
		lRet := MsgNoYes( STR0258 + CRLF + STR0259, STR0001)//"Parâmetro MV_ORGCFG está configurado com 1 e foi selecionado uma visão com hierarquia Organizacional."##"Deseja prosseguir com essa configuração?"
	ElseIf cOrgCfg == "2" .And. fDesc("RDK", cOpcVis, "RDK_HIERAR", NIL, cFilAnt, 1) == "2"
		lRet := MsgNoYes( STR0260 + CRLF + STR0259, STR0001)//"Parâmetro MV_ORGCFG está configurado com 2 e foi selecionado uma visão com hierarquia Comunicação."##"Deseja prosseguir com essa configuração?"
	EndIf
EndIf

If ValType(oButFil) != "U"
	oButFil:lActive 	:= .T.
	oButGrp:lActive 	:= lIntGrp
	oButCarg:lActive 	:= lIntCarg
	oButDep:lActive 	:= lIntDepto
	oButFunc:lActive 	:= lIntFunc
	oButHFil:lActive 	:= lIntHFil
	oButHGrp:lActive 	:= lIntHGrp
	oButHCarg:lActive 	:= lIntHCarg
	oButHDep:lActive 	:= lIntHDep
	oButAfas:lActive 	:= lIntAfas
	oButFalta:lActive 	:= lIntFalta
	oButLider:lActive 	:= lIntLider
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fContSel
Verifica quantas opções foram selecionadas
@author  Allyson Luiz Mesashi
@since   14/04/2022
/*/
//-------------------------------------------------------------------
Static Function fContSel()

nQtdSel := 0

If lIntFil
	nQtdSel++
EndIf
If lIntGrp
	nQtdSel++
EndIf
If lIntCarg
	nQtdSel++
EndIf
If lIntDepto
	nQtdSel++
EndIf
If lIntContr
	nQtdSel++
EndIf
If lIntFunc
	nQtdSel++
EndIf
If lIntHFil
	nQtdSel++
EndIf
If lIntHGrp
	nQtdSel++
EndIf
If lIntHCarg
	nQtdSel++
EndIf
If lIntHDep
	nQtdSel++
EndIf
If lIntAfas
	nQtdSel++
EndIf
If lIntFalta
	nQtdSel++
EndIf
If lIntLider
	nQtdSel++
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcConcl
Retorna se o processamento já foi concluído
@author  Allyson Luiz Mesashi
@since   14/04/2022
/*/
//-------------------------------------------------------------------
Static Function PrcConcl()

If oArqTmp == Nil
	fCriaTmp()//Criação de tabela temporária para a MarkBrowse de seleção de filiais
	oButtonProc:Enable()
	oSayProc:setText("")
	oSaySep:setText("")	
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcExec
Retorna se o processamento está em execução de acordo com o semáforo
@author  Allyson Luiz Mesashi
@since   14/04/2022
/*/
//-------------------------------------------------------------------
Static Function PrcExec()
Return( lInExec )

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcInt
Retorna se o processamento foi realizado
@author  Allyson Luiz Mesashi
@since   14/04/2022
/*/
//-------------------------------------------------------------------
Static Function PrcInt()

Local lRet	:= .F.

If !lIntegrou
	lRet := !MsgNoYes(STR0069, STR0001)//"Deseja fechar a rotina sem efetuar a importação?"##"Atenção"
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} fSelFil
Retorna as filiais que serão processadas
@author  Allyson Luiz Mesashi
@since   14/04/2022
/*/
//-------------------------------------------------------------------
Static Function fSelFil()

Local aButtons 		:= {}
Local aColumns 		:= {}
Local bOK2			:= { || ( oDlgGrid:End(), nOpcB := 1 ) }
Local bFecha 		:= { || oDlgGrid:End() }
Local lMArcar 		:= .F.
Local nOpcB 		:= 0
Local oFont 		:= Nil

aAdd( aColumns, FWBrwColumn():New() )
aColumns[Len(aColumns)]:SetData( &("{ || (cAliasTmp)->FILIAL }") )
aColumns[Len(aColumns)]:SetTitle( STR0064 )//"Filial"
aColumns[Len(aColumns)]:SetSize( FwGetTamFilial )
aColumns[Len(aColumns)]:SetDecimal( 0 )
aColumns[Len(aColumns)]:SetPicture( "@!" )

aAdd( aColumns, FWBrwColumn():New() )
aColumns[Len(aColumns)]:SetData( &("{ || (cAliasTmp)->NOME }" ) )
aColumns[Len(aColumns)]:SetTitle( STR0065 )//"Nome"
aColumns[Len(aColumns)]:SetSize( Len(SM0->M0_NOME) )
aColumns[Len(aColumns)]:SetDecimal( 0 )
aColumns[Len(aColumns)]:SetPicture( "@!" )

aAdd( aColumns, FWBrwColumn():New() )
aColumns[Len(aColumns)]:SetData( &("{ || (cAliasTmp)->CNPJ }" ) )
aColumns[Len(aColumns)]:SetTitle( STR0066 )//"CNPJ"
aColumns[Len(aColumns)]:SetSize( 14 )
aColumns[Len(aColumns)]:SetDecimal( 0 )
aColumns[Len(aColumns)]:SetPicture( "@R 99.999.999/9999-99" )

//Tela
oSize := FwDefSize():New(.F.)
oSize:AddObject( "CABECALHO", (oSize:aWindSize[3] * 1.1), (oSize:aWindSize[3] * 0.4) , .F., .F. )
oSize:aMargins 	:= { 0, 0, 0, 0 }
oSize:lProp 	:= .F. 
oSize:Process()

DEFINE MSDIALOG oDlgGrid TITLE OemToAnsi(STR0067) From 0, 0 TO 380, 930 OF oMainWnd PIXEL//"Filiais"

oTela2	:= FWFormContainer():New( oDlgGrid )
cIdGrid	:= oTela2:CreateHorizontalBox( 80 )

oTela2:Activate( oDlgGrid, .F. )

//Cria os paineis onde serao colocados os browses
oPanel4	:= oTela2:GeTPanel( cIdGrid )

@ oSize:GetDimension( "CABECALHO","LININI" )+1, oSize:GetDimension( "CABECALHO", "COLINI" )+4 GROUP oGroup TO oSize:GetDimension("CABECALHO","LINEND") * 0.090, oSize:GetDimension("CABECALHO","COLEND") * 0.431 OF oDlgGrid PIXEL
oGroup:oFont:=oFont
@ oSize:GetDimension( "CABECALHO","LININI" )+9, oSize:GetDimension( "CABECALHO", "COLINI" )+6 SAY "" Of oDlgGrid Pixel

oMark := FWMarkBrowse():New()
oMark:SetAlias( cAliasTmp )
oMark:SetTemporary( .T. )
oMark:SetColumns( aColumns )

//Indica o container onde sera criado o browse
oMark:SetOwner( oPanel4 )
oMark:bAllMark := { || SetMarkAll(oMark:Mark(), lMarcar := !lMarcar, cAliasTmp ), oMark:Refresh(.T.)  }

oMark:SetFieldMark('OK')

oMark:SetMenuDef("GPEM034")
oMark:Activate()

ACTIVATE MSDIALOG oDlgGrid CENTERED ON INIT EnchoiceBar(oDlgGrid, bOK2 ,bFecha, NIL, aButtons)

If nOpcB == 1
	aArrayFil		:= {}
	(cAliasTmp)->(dbGoTop())
	While (cAliasTmp)->( !EoF() )
		If !Empty( (cAliasTmp)->OK )
			aAdd(aArrayFil, { (cAliasTmp)->FILIAL, (cAliasTmp)->NOME })
		EndIf
		(cAliasTmp)->( dbSkip() )
	EndDo
EndIf

Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetMarkAll
Marca/desmarca todos os itens
@author  Allyson Luiz Mesashi
@since   14/04/2022
/*/
//-------------------------------------------------------------------
Static Function SetMarkAll(cMarca, lMarcar, cAliasTmp)

Local aAreaMark  := (cAliasTmp)->( GetArea() )

dbSelectArea(cAliasTmp)
(cAliasTmp)->( dbGoTop() )

While (cAliasTmp)->( !Eof() )
	If RecLock( (cAliasTmp), .F. )
		(cAliasTmp)->OK := Iif( lMarcar, cMarca, '  ' )
		MsUnLock()
	EndIf
	(cAliasTmp)->( dbSkip() )
EndDo

RestArea(aAreaMark)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldFil
Valida a seleção de filiais
@author  Allyson Luiz Mesashi
@since   14/04/2022
/*/
//-------------------------------------------------------------------
Static Function fVldFil()

Local lRet := .T.

If Empty(aArrayFil)
	lRet := .F.
	MsgInfo(STR0068, STR0001)//"Certifique-se de selecionar a(s) filial(is) para processamento no botão de Filtro de Filiais"##"Atenção"
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fBarra
Monta a barra de progresso na parte de baixo do painel 3 do wizard
@author  Allyson Luiz Mesashi
@since   14/04/2022
/*/
//-------------------------------------------------------------------
Static Function fBarra(oPanel, oButtonProc)

Local nMeter	:= 0
Local nMeter2	:= 0
Local oMeter	:= Nil
Local oMeter2	:= Nil
Local oSayProc2	:= Nil
Local oSayProc3	:= Nil

lInExec := .T.

aAdd( aLogProc, STR0025 + dToC( Date() ) )//"Data de início: "
aAdd( aLogProc, STR0026 + Time() )//"Hora de início: "

// Desabilita os botões
oButtonProc:Disable()

oSaySep := TSay():New( 115, 02, { || Replicate("_", 150) }, oPanel, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 300, 20 )
oSaySep:setCSS( fCSS("LINESEPARADOR") )

oSayProc := TSay():New( 130, 80, { || STR0022 }, oPanel, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 300, 20 )//"Efetuando Processamento -> "
oSayProc:setCSS( fCSS("TEXTTITLE") )

oSayProc2 := TSay():New( 145, 115, { || STR0023 }, oPanel, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 300, 20 )//"Opções importadas: "
oSayProc2:setCSS( fCSS("TEXTTITLE") )
oMeter2 := TMeter():New( 155, 25, { |u| Iif( Pcount() > 0, nMeter2 := u, nMeter2) }, 100, oPanel, 250, 16,, .T.)
oMeter2:setCSS("METER")
oMeter2:SetTotal(0)
oMeter2:Set(0)

oSayProc3 := TSay():New( 175, 115, { || STR0024 }, oPanel, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 300,20 )//"Registros importados: "
oSayProc3:setCSS( fCSS("TEXTTITLE") )
oMeter := TMeter():New( 185, 25, { |u| Iif( Pcount() > 0, nMeter := u, nMeter) }, 100, oPanel, 250, 16, Nil, .T. )
oMeter:setCSS("METER")
oMeter:SetTotal(0)
oMeter:Set(0)

// Chama as funções de processamento
fProc(oSayProc, oMeter, oMeter2, oSayProc2, oSayProc3)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fProc
Encapsula as funções de processamento
@author  Allyson Luiz Mesashi
@since   14/04/2022
/*/
//-------------------------------------------------------------------
Static Function fProc(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)

Local cErrToken	:= ""
Local cFilSelec	:= ""
Local cToken	:= ""
Local lErro		:= .F.
Local lTokOk	:= .F.
Local nContFil	:= 0

Private lVldSRA	:= (cOpcAtiv == STR0036)//"Campo MSBLQL (se houver) + vínculo com registro ativo da SRA"

cTimeIni := Time()
oMeter2:SetTotal( nQtdSel )

lTokOk := fTokenPM( @cToken, @cErrToken )

If !lTokOk
	aAdd(aLogErr, STR0078)//"Houve falha ao tentar obter o token de acesso. Solicite ao administrador uma revisão dos parâmetros MV_APIPEM0, MV_APIPEM2 e/ou MV_APIPEM3"
	aAdd(aLogErr, STR0080)//"Obs.: erro completo retornado:"
	FiltraLog( aLogErr, cErrToken)
EndIf

If lTokOk
	For nContFil := 1 To Len(aArrayFil)
		cFilSelec += aArrayFil[nContFil, 1] + "|"
	Next nContFil
	FiltraLog( aLogFiltro, STR0188 + cFilSelec)//"Filiais selecionadas: "

	If lIntFil//Filial
		fIntFil(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken)
	EndIf
	If lIntGrp//Grupo de cargos
		fIntGrp(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken)
		FiltraLog( aLogFiltro, STR0014 + ": " + cFltGrp)//"Grupo de cargos"
	EndIf
	If lIntCarg//Cargos
		fIntCarg(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken)
		FiltraLog( aLogFiltro, STR0017 + ": " + cFltCarg)//"Cargos"
	EndIf
	If lIntDepto//Departamentos
		fIntDepto(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken)
		FiltraLog( aLogFiltro, STR0016 + ": " + cFltDep)//"Departamentos"
	EndIf
	If lIntContr//Grupos de contrato
		fIntContr(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken)
	EndIf
	If lIntFunc//Funcionários
		fIntFunc(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken)
		FiltraLog( aLogFiltro, STR0018 + ": " + cFltFunc)//"Funcionários"
	EndIf
	If lIntHFil//Movimentação de filiais
		fIntHFil(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken)
		FiltraLog( aLogFiltro, STR0214 + ": " + cFltHFil)//"Movimentação de filiais"
	EndIf
	If lIntHGrp//Movimentação de grupos de cargo
		fIntHGrp(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken)
		FiltraLog( aLogFiltro, STR0221 + ": " + cFltHGrp)//"Movimentação de grupos de cargo"
	EndIf
	If lIntHCarg//Movimentação de cargos
		fIntHCarg(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken)
		FiltraLog( aLogFiltro, STR0200 + ": " + cFltHCarg)//"Movimentação de cargos"
	EndIf
	If lIntHDep//Movimentação de departamentos
		fIntHDep(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken)
		FiltraLog( aLogFiltro, STR0207 + ": " + cFltHDep)//"Movimentação de departamentos"
	EndIf
	If lIntAfas//Afastamentos
		fIntAfas(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken)
		FiltraLog( aLogFiltro, STR0229 + ": " + cFltAfas)//"Afastamentos"
	EndIf
	If lIntFalta//Afastamentos
		fIntFalta(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken)
		FiltraLog( aLogFiltro, STR0236 + ": " + cFltFalta)//"Faltas"
	EndIf
	If lIntLider//Líder dos funcionários
		fIntLider(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken)
		FiltraLog( aLogFiltro, STR0250 + ": " + cFltLider)//"Líder dos funcionários"
	EndIf

	If cOpcReto	== STR0086 .And. !Empty(aPrcId)//"Aguardar o retorno do P&M"
		fStatPeM(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken, @lErro)
		fStatREF()
	EndIf
EndIf

aAdd( aLogProc, STR0027 + dToC( Date() ) )//"Data de término: "
aAdd( aLogProc, STR0028 + Time() )//"Hora de término: "
aAdd( aLogProc, STR0029 + ElapTime( cTimeIni, Time() ) )//"Tempo de processamento: "
aAdd( aLogProc, "")
aAdd( aLogProc, STR0030 + cValToChar(nTotInteg) )//"Total de registros integrados: "
If lErro
	fMsgErr()
EndIf
fMakeLog( { aLogProc, aLogFiltro, aLogErr, aLogImp, aLogIncon, aLogPeM }, aTitle, Nil, Nil, Nil, OemToAnsi(STR0031), "G", "L", Nil, .F.) //"Log de Ocorrências"

MsgAlert(STR0034, STR0001)//"Processamento Finalizado"##"Atenção"
lInExec 	:= .F.
lIntegrou  	:= .T.

If ValType(oMeter2) <> "U"
	oSay:setText(Space(20)+STR0034)//"Processamento Finalizado."
	If cOpcReto	!= STR0086 .Or. ValType(oMeter) <> "U"//"Aguardar o retorno do P&M"
		oMeter:Free()
	EndIf
	oMeter2:Free()
	oSayProc2:setText("")
	oSayProc3:setText("")
EndIf

If Select(cAliasTmp) > 0
	(cAliasTmp)->( dbCloseArea() )
EndIf

If oArqTmp != Nil
	oArqTmp:Delete()
	Freeobj(oArqTmp)
EndIf

///Reinicialização das variáveis de integração
aArrayFil 	:= {}
aJsons 		:= {}
aJsonsLote 	:= {}
aLogErr 	:= {}
aLogFiltro	:= {}
aLogIncon 	:= {}
aLogImp 	:= {}
aLogPeM 	:= {}
aLogProc 	:= {}
aPrcId 		:= {}
aTitle    	:= { OemToAnsi(STR0032), OemToAnsi(STR0187), OemToAnsi(STR0077), OemToAnsi(STR0033), OemToAnsi(STR0122), OemToAnsi(STR0085) }//"Processamento"##"Erro na integração com o P&M"##Registros Integrados"##"Registros inconsistentes"##"Status do processamento pelo P&M"
cFltCarg 	:= cFltDep := cFltFunc := cFltGrp := cFltHCarg := cFltHDep := cFltHFil := cFltHGrp := cFltAfas := cFltFalta := cFltLider := ""
lIntFil 	:= lIntGrp := lIntCarg := lIntDepto := lIntFunc := lIntContr := lIntHCarg := lIntHDep := lIntHFil := lIntHGrp := lIntAfas := lIntFalta := lIntLider := .F.
nTotInteg	:= nTotProc	:= 0
oButFil:lActive 	:= .F.
oButGrp:lActive 	:= .F.
oButCarg:lActive 	:= .F.
oButDep:lActive 	:= .F.
oButFunc:lActive 	:= .F.
oButHFil:lActive 	:= .F.
oButHGrp:lActive 	:= .F.
oButHCarg:lActive 	:= .F.
oButHDep:lActive 	:= .F.
oButAfas:lActive 	:= .F.
oButFalta:lActive 	:= .F.
oButLider:lActive 	:= .F.

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fIntFil
Realiza a integração da tabela SM0 de filiais
@author  Allyson Luiz Mesashi
@since   27/04/2022
/*/
//-------------------------------------------------------------------
Static Function fIntFil(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken)

Local aArea 		:= GetArea()
Local aErrInt		:= {}
Local aRegInteg		:= {}
Local cAliasQRY 	:= "IMPSM0"
Local cFilQry		:= ""
Local cNomeTmp 		:= oArqTmp:GetRealName()
Local cQuery		:= ""
Local oJson			:= Nil
Local nCont			:= 0
Local nContFil		:= 0
Local nErrInt		:= 0
Local nInc			:= 0
Local nRegs			:= 0

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0073 + STR0110 )//"Iniciando Processamento..."##"Importação filiais"
oSayProc2:SetText( STR0075 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Opções integradas: "
fRstLote()

For nContFil := 1 To Len(aArrayFil)
	cFilQry += aArrayFil[nContFil, 1]
Next nContFil

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + cNomeTmp + " SM0 "
cQuery 	+= "WHERE SM0.FILIAL IN (" + fSqlIn(cFilQry, FwGetTamFilial) + ")"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

cQuery	:= "SELECT FILIAL, NOME "
cQuery 	+= "FROM " + cNomeTmp + " SM0 "
cQuery 	+= "WHERE SM0.FILIAL IN (" + fSqlIn(cFilQry, FwGetTamFilial) + ")"
cQuery 	+= "ORDER BY 1"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

While (cAliasQRY)->( !EoF() )
	nInc++
	oMeter:Set(nInc)
	oSayProc3:SetText( STR0076 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros processados: "

	If !lVldSRA .Or. fVldSM0( (cAliasQRY)->FILIAL )
		oJson := JsonObject():New()
		oJson['integrationId'] 	:= AllTrim( cEmpAnt+(cAliasQRY)->FILIAL )
		oJson['name'] 			:= AllTrim( (cAliasQRY)->NOME )
		fCriaLote( oJson )
	EndIf

	(cAliasQRY)->( dbSkip() )
EndDo

If !Empty(aJsons) .Or. !Empty(aJsonsLote)
	If fEnvGen(cToken, @aErrInt, @aRegInteg, "1")
		aAdd(aLogImp, STR0111)//"Registros integrados de filiais: "
		For nRegs := 1 To Len(aRegInteg)
			aAdd(aLogImp, aRegInteg[nRegs])
		Next nRegs
		nTotInteg += Len(aRegInteg)
	Else
		aAdd(aLogErr, STR0112)//"Erro na integração das filiais: "
		aAdd(aLogErr, STR0083)//"Houve falha ao tentar efetuar a integração. Solicite ao administrador uma revisão dos parâmetros MV_APIPEM1, MV_APIPEM2 e/ou MV_APIPEM3"
		aAdd(aLogErr, STR0080)//"Obs.: erro completo retornado:"
		For nErrInt := 1 To Len(aErrInt)
			FiltraLog( aLogErr, aErrInt[nErrInt])
		Next nErrInt	
	EndIf
EndIf

(cAliasQRY)->( dbCloseArea() )

RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fIntGrp
Realiza a integração da tabela SQ0 de grupos de cargo
@author  Allyson Luiz Mesashi
@since   18/04/2022
/*/
//-------------------------------------------------------------------
Static Function fIntGrp(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken)

Local aArea 		:= GetArea()
Local aAreaRET 		:= {}
Local aAreaSQ0 		:= SQ0->( GetArea() )
Local aAuxJson		:= {}
Local aErrInt		:= {}
Local aFilProc		:= {}
Local aRegInteg		:= {}
Local cAliasQRY 	:= "IMPSQ0"
Local cCodPeM		:= ""
Local cDescPeM		:= ""
Local cFilIn		:= ""
Local cFilQry		:= ""
Local cQuery		:= ""
Local lTudoComp		:= Empty( xFilial("SQ0") )
Local lTudoExc		:= FWModeAccess( "SQ0", 1 )+FWModeAccess( "SQ0", 2 )+FWModeAccess( "SQ0", 3 ) == "EEE"
Local oJson			:= Nil
Local nCont			:= 0
Local nContFil		:= 0
Local nErrInt		:= 0
Local nInc			:= 0
Local nRegs			:= 0
Local nTamFil		:= 0

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0073 + STR0074 )//"Iniciando Processamento..."##"Importação grupos de cargo"
oSayProc2:SetText( STR0075 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Opções integradas: "
fRstLote()

If !lTudoComp .And. lTemREN
	aAreaRET := RET->( GetArea() )
	RET->( dbSetOrder(2) )//RET_FILIAL+RET_TIPO+RET_FILCAD+RET_CODCAD
EndIf

If !lTudoComp .And. !lTudoExc
	nTamFil	:= Len(AllTrim(xFilial("SQ0")))
	For nContFil := 1 To Len(aArrayFil)
		If aScan(aFilProc, {|x| x == xFilial("SQ0", aArrayFil[nContFil, 1]) }) == 0
			aAdd(aFilProc, xFilial("SQ0", aArrayFil[nContFil, 1]) )
			cFilQry += AllTrim(xFilial("SQ0", aArrayFil[nContFil, 1]))
		EndIf
	Next nContFil
	cFilIn := fSqlIn(cFilQry, nTamFil)
ElseIf lTudoExc
	For nContFil := 1 To Len(aArrayFil)
		cFilQry += aArrayFil[nContFil, 1]
	Next nContFil
	cFilIn := fSqlIn(cFilQry, FwGetTamFilial)
EndIf

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + cTabSQ0 + " SQ0 "
cQuery 	+= "WHERE "
If !lTudoComp .And. !lTudoExc
	cQuery 	+= "SUBSTRING(SQ0.Q0_FILIAL, 1, " + cValToChar(nTamFil) + ") IN (" + cFilIn + ") AND "
ElseIf lTudoExc
	cQuery 	+= "SQ0.Q0_FILIAL IN (" + cFilIn + ") AND "
EndIf
If !Empty(cFltGrp)
	cQuery 	+= "( " + GPEParSQL(fPrepExpIn(cFltGrp)) + " ) AND "
EndIf
cQuery 	+= "SQ0.D_E_L_E_T_ = ' '"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

cQuery	:= "SELECT Q0_FILIAL, Q0_GRUPO, R_E_C_N_O_ AS RECNO "
cQuery 	+= "FROM " + cTabSQ0 + " SQ0 "
cQuery 	+= "WHERE "
If !lTudoComp .And. !lTudoExc
	cQuery 	+= "SUBSTRING(SQ0.Q0_FILIAL, 1, " + cValToChar(nTamFil) + ") IN (" + cFilIn + ") AND "
ElseIf lTudoExc
	cQuery 	+= "SQ0.Q0_FILIAL IN (" + cFilIn + ") AND "
EndIf
If !Empty(cFltGrp)
	cQuery 	+= "( " + GPEParSQL(fPrepExpIn(cFltGrp)) + " ) AND "
EndIf
cQuery 	+= "SQ0.D_E_L_E_T_ = ' ' "
cQuery 	+= "ORDER BY 1, 2"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

If nCont == 0
	aAdd(aLogErr, STR0079)//"Erro na integração dos grupos de cargo: "
	aAdd(aLogErr, STR0189)//"Nenhum registro encontrado de acordo com o filtro realizado."
Else
	While (cAliasQRY)->( !EoF() )
		nInc++
		oMeter:Set(nInc)
		oSayProc3:SetText( STR0076 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros processados: "

		SQ0->( dbGoTo( (cAliasQRY)->RECNO) )
		
		cCodPeM		:= cEmpAnt+SQ0->Q0_FILIAL+SQ0->Q0_GRUPO
		cDescPeM	:= SQ0->Q0_DESCRIC

		If fVldSQ0( !lTudoComp, @cCodPeM, @cDescPeM )
			oJson := JsonObject():New()
			oJson['integrationId'] 	:= AllTrim( cCodPeM )
			oJson['name'] 			:= AllTrim( cDescPeM )
			If aScan( aAuxJson, { |x| x['integrationId'] == oJson['integrationId'] } ) == 0
				aAdd( aAuxJson, oJson )
			EndIf
		EndIf

		(cAliasQRY)->( dbSkip() )
	EndDo

	For nCont := 1 To Len(aAuxJson)
		fCriaLote( aAuxJson[nCont] )
	Next nCont

	If !Empty(aJsons) .Or. !Empty(aJsonsLote)
		If fEnvGen(cToken, @aErrInt, @aRegInteg, "2")
			aAdd(aLogImp, STR0084)//"Registros integrados dos grupos de cargo: "
			For nRegs := 1 To Len(aRegInteg)
				aAdd(aLogImp, aRegInteg[nRegs])
			Next nRegs
			nTotInteg += Len(aRegInteg)
		Else
			aAdd(aLogErr, STR0079)//"Erro na integração dos grupos de cargo: "
			aAdd(aLogErr, STR0083)//"Houve falha ao tentar efetuar a integração. Solicite ao administrador uma revisão dos parâmetros MV_APIPEM1, MV_APIPEM2 e/ou MV_APIPEM3"
			aAdd(aLogErr, STR0080)//"Obs.: erro completo retornado:"
			For nErrInt := 1 To Len(aErrInt)
				FiltraLog( aLogErr, aErrInt[nErrInt])
			Next nErrInt	
		EndIf
	EndIf
EndIf

(cAliasQRY)->( dbCloseArea() )

If !lTudoComp .And. lTemREN
	RestArea( aAreaRET )
EndIf

RestArea( aAreaSQ0 )
RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fIntCarg
Realiza a integração da tabela SQ3 de cargos
@author  Allyson Luiz Mesashi
@since   02/05/2022
/*/
//-------------------------------------------------------------------
Static Function fIntCarg(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken)

Local aArea 		:= GetArea()
Local aAreaRET 		:= {}
Local aAreaSQ0 		:= SQ0->( GetArea() )
Local aAreaSQ3 		:= SQ3->( GetArea() )
Local aAuxJson		:= {}
Local aErrInt		:= {}
Local aFilProc		:= {}
Local aRegInteg		:= {}
Local cAliasQRY 	:= "IMPSQ3"
Local cCodPeM		:= ""
Local cCodPeMGrp	:= ""
Local cDescPeM		:= ""
Local cFilIn		:= ""
Local cFilQry		:= ""
Local cQuery		:= ""
Local lTudoComp		:= Empty( xFilial("SQ3") )
Local lTudoExc		:= FWModeAccess( "SQ3", 1 )+FWModeAccess( "SQ3", 2 )+FWModeAccess( "SQ3", 3 ) == "EEE"
Local oJson			:= Nil
Local nCont			:= 0
Local nContFil		:= 0
Local nErrInt		:= 0
Local nInc			:= 0
Local nRegs			:= 0
Local nTamFil		:= 0

SQ0->( dbSetOrder(1) )//Q0_FILIAL+Q0_GRUPO

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0073 + STR0113 )//"Iniciando Processamento..."##"Importação cargos"
oSayProc2:SetText( STR0075 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Opções integradas: "
fRstLote()

If !lTudoComp .And. lTemREN
	aAreaRET := RET->( GetArea() )
	RET->( dbSetOrder(2) )//RET_FILIAL+RET_TIPO+RET_FILCAD+RET_CODCAD
EndIf

If !lTudoComp .And. !lTudoExc
	nTamFil	:= Len(AllTrim(xFilial("SQ3")))
	For nContFil := 1 To Len(aArrayFil)
		If aScan(aFilProc, {|x| x == xFilial("SQ3", aArrayFil[nContFil, 1]) }) == 0
			aAdd(aFilProc, xFilial("SQ3", aArrayFil[nContFil, 1]) )
			cFilQry += AllTrim(xFilial("SQ3", aArrayFil[nContFil, 1]))
		EndIf
	Next nContFil
	cFilIn := fSqlIn(cFilQry, nTamFil)
ElseIf lTudoExc
	For nContFil := 1 To Len(aArrayFil)
		cFilQry += aArrayFil[nContFil, 1]
	Next nContFil
	cFilIn := fSqlIn(cFilQry, FwGetTamFilial)
EndIf

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + cTabSQ3 + " SQ3 "
cQuery 	+= "WHERE "
If !lTudoComp .And. !lTudoExc
	cQuery 	+= "SUBSTRING(SQ3.Q3_FILIAL, 1, " + cValToChar(nTamFil) + ") IN (" + cFilIn + ") AND "
ElseIf lTudoExc
	cQuery 	+= "SQ3.Q3_FILIAL IN (" + cFilIn + ") AND "
EndIf
If !Empty(cFltCarg)
	cQuery 	+= "( " + GPEParSQL(fPrepExpIn(cFltCarg)) + " ) AND "
EndIf
cQuery 	+= "SQ3.D_E_L_E_T_ = ' '"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

cQuery	:= "SELECT SQ3.Q3_FILIAL, SQ3.Q3_CARGO, R_E_C_N_O_ AS RECNO "
cQuery 	+= "FROM " + cTabSQ3 + " SQ3 "
cQuery 	+= "WHERE "
If !lTudoComp .And. !lTudoExc
	cQuery 	+= "SUBSTRING(SQ3.Q3_FILIAL, 1, " + cValToChar(nTamFil) + ") IN (" + cFilIn + ") AND "
ElseIf lTudoExc
	cQuery 	+= "SQ3.Q3_FILIAL IN (" + cFilIn + ") AND "
EndIf
If !Empty(cFltCarg)
	cQuery 	+= "( " + GPEParSQL(fPrepExpIn(cFltCarg)) + " ) AND "
EndIf
cQuery 	+= "SQ3.D_E_L_E_T_ = ' ' "
cQuery 	+= "ORDER BY 1, 2"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

If nCont == 0
	aAdd(aLogErr, STR0115)//"Erro na integração de cargos: "
	aAdd(aLogErr, STR0189)//"Nenhum registro encontrado de acordo com o filtro realizado."
Else
	While (cAliasQRY)->( !EoF() )
		nInc++
		oMeter:Set(nInc)
		oSayProc3:SetText( STR0076 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros processados: "

		SQ3->( dbGoTo( (cAliasQRY)->RECNO ) )

		cCodPeM		:= cEmpAnt+SQ3->Q3_FILIAL+SQ3->Q3_CARGO
		cDescPeM	:= SQ3->Q3_DESCSUM
		cCodPeMGrp	:= cEmpAnt+xFilial("SQ0", SQ3->Q3_FILIAL)+SQ3->Q3_GRUPO

		If fVldSQ3( !lTudoComp, @cCodPeM, @cDescPeM, @cCodPeMGrp )
			oJson := JsonObject():New()
			oJson['integrationId'] 					:= AllTrim( cCodPeM )
			oJson['name'] 							:= AllTrim( cDescPeM )
			oJson['positionGroupIntegrationId'] 	:= AllTrim( cCodPeMGrp )
			If aScan( aAuxJson, { |x| x['integrationId'] == oJson['integrationId'] } ) == 0
				aAdd( aAuxJson, oJson )
			EndIf
		EndIf

		(cAliasQRY)->( dbSkip() )
	EndDo

	For nCont := 1 To Len(aAuxJson)
		fCriaLote( aAuxJson[nCont] )
	Next nCont

	If !Empty(aJsons) .Or. !Empty(aJsonsLote)
		If fEnvGen(cToken, @aErrInt, @aRegInteg, "3")
			aAdd(aLogImp, STR0114)//"Registros integrados de cargos: "
			For nRegs := 1 To Len(aRegInteg)
				aAdd(aLogImp, aRegInteg[nRegs])
			Next nRegs
			nTotInteg += Len(aRegInteg)
		Else
			aAdd(aLogErr, STR0115)//"Erro na integração de cargos: "
			aAdd(aLogErr, STR0083)//"Houve falha ao tentar efetuar a integração. Solicite ao administrador uma revisão dos parâmetros MV_APIPEM1, MV_APIPEM2 e/ou MV_APIPEM3"
			aAdd(aLogErr, STR0080)//"Obs.: erro completo retornado:"
			For nErrInt := 1 To Len(aErrInt)
				FiltraLog( aLogErr, aErrInt[nErrInt])
			Next nErrInt	
		EndIf
	EndIf
EndIf

(cAliasQRY)->( dbCloseArea() )

If !lTudoComp .And. lTemREN
	RestArea( aAreaRET )
EndIf

RestArea( aAreaSQ0 )
RestArea( aAreaSQ3 )
RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fIntDepto
Realiza a integração da tabela SQB de departamentos
@author  Allyson Luiz Mesashi
@since   02/05/2022
/*/
//-------------------------------------------------------------------
Static Function fIntDepto(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken)

Local aArea 		:= GetArea()
Local aAreaRET 		:= {}
Local aAreaSQB 		:= SQB->( GetArea() )
Local aAuxJson		:= {}
Local aErrInt		:= {}
Local aFilProc		:= {}
Local aRegInteg		:= {}
Local cAliasQRY 	:= "IMPSQB"
Local cCodPeM		:= ""
Local cDescPeM		:= ""
Local cFilIn		:= ""
Local cFilQry		:= ""
Local cQuery		:= ""
Local lTudoComp		:= Empty( xFilial("SQB") )
Local lTudoExc		:= FWModeAccess( "SQB", 1 )+FWModeAccess( "SQB", 2 )+FWModeAccess( "SQB", 3 ) == "EEE"
Local oJson			:= Nil
Local nCont			:= 0
Local nContFil		:= 0
Local nErrInt		:= 0
Local nInc			:= 0
Local nRegs			:= 0
Local nTamFil		:= 0

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0073 + STR0116 )//"Iniciando Processamento..."##"Importação departamentos"
oSayProc2:SetText( STR0075 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Opções integradas: "
fRstLote()

If !lTudoComp .And. lTemREN
	aAreaRET := RET->( GetArea() )
	RET->( dbSetOrder(2) )//RET_FILIAL+RET_TIPO+RET_FILCAD+RET_CODCAD
EndIf

If !lTudoComp .And. !lTudoExc
	nTamFil	:= Len(AllTrim(xFilial("SQB")))
	For nContFil := 1 To Len(aArrayFil)
		If aScan(aFilProc, {|x| x == xFilial("SQB", aArrayFil[nContFil, 1]) }) == 0
			aAdd(aFilProc, xFilial("SQB", aArrayFil[nContFil, 1]) )
			cFilQry += AllTrim(xFilial("SQB", aArrayFil[nContFil, 1]))
		EndIf
	Next nContFil
	cFilIn := fSqlIn(cFilQry, nTamFil)
ElseIf lTudoExc
	For nContFil := 1 To Len(aArrayFil)
		cFilQry += aArrayFil[nContFil, 1]
	Next nContFil
	cFilIn := fSqlIn(cFilQry, FwGetTamFilial)
EndIf

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + cTabSQB + " SQB "
cQuery 	+= "WHERE "
If !lTudoComp .And. !lTudoExc
	cQuery 	+= "SUBSTRING(SQB.QB_FILIAL, 1, " + cValToChar(nTamFil) + ") IN (" + cFilIn + ") AND "
ElseIf lTudoExc
	cQuery 	+= "SQB.QB_FILIAL IN (" + cFilIn + ") AND "
EndIf
If !Empty(cFltDep)
	cQuery 	+= "( " + GPEParSQL(fPrepExpIn(cFltDep)) + " ) AND "
EndIf
cQuery 	+= "SQB.D_E_L_E_T_ = ' '"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

cQuery	:= "SELECT QB_FILIAL, QB_DEPTO, R_E_C_N_O_ AS RECNO "
cQuery 	+= "FROM " + cTabSQB + " SQB "
cQuery 	+= "WHERE "
If !lTudoComp .And. !lTudoExc
	cQuery 	+= "SUBSTRING(SQB.QB_FILIAL, 1, " + cValToChar(nTamFil) + ") IN (" + cFilIn + ") AND "
ElseIf lTudoExc
	cQuery 	+= "SQB.QB_FILIAL IN (" + cFilIn + ") AND "
EndIf
If !Empty(cFltDep)
	cQuery 	+= "( " + GPEParSQL(fPrepExpIn(cFltDep)) + " ) AND "
EndIf
cQuery 	+= "SQB.D_E_L_E_T_ = ' ' "
cQuery 	+= "ORDER BY 1, 2"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

If nCont == 0
	aAdd(aLogErr, STR0118)//"Erro na integração de departamentos: "
	aAdd(aLogErr, STR0189)//"Nenhum registro encontrado de acordo com o filtro realizado."
Else
	While (cAliasQRY)->( !EoF() )
		nInc++
		oMeter:Set(nInc)
		oSayProc3:SetText( STR0076 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros processados: "

		SQB->( dbGoTo( (cAliasQRY)->RECNO ) )
		
		cCodPeM		:= cEmpAnt+SQB->QB_FILIAL+SQB->QB_DEPTO
		cDescPeM	:= SQB->QB_DESCRIC

		If fVldSQB( !lTudoComp, @cCodPeM, @cDescPeM )
			oJson := JsonObject():New()
			oJson['integrationId']	:= AllTrim( cCodPeM )
			oJson['name'] 			:= AllTrim( cDescPeM )
			If aScan( aAuxJson, { |x| x['integrationId'] == oJson['integrationId'] } ) == 0
				aAdd( aAuxJson, oJson )
			EndIf
		EndIf

		(cAliasQRY)->( dbSkip() )
	EndDo

	For nCont := 1 To Len(aAuxJson)
		fCriaLote( aAuxJson[nCont] )
	Next nCont

	If !Empty(aJsons) .Or. !Empty(aJsonsLote)
		If fEnvGen(cToken, @aErrInt, @aRegInteg, "4")
			aAdd(aLogImp, STR0117)//"Registros integrados de departamentos: "
			For nRegs := 1 To Len(aRegInteg)
				aAdd(aLogImp, aRegInteg[nRegs])
			Next nRegs
			nTotInteg += Len(aRegInteg)
		Else
			aAdd(aLogErr, STR0118)//"Erro na integração de departamentos: "
			aAdd(aLogErr, STR0083)//"Houve falha ao tentar efetuar a integração. Solicite ao administrador uma revisão dos parâmetros MV_APIPEM1, MV_APIPEM2 e/ou MV_APIPEM3"
			aAdd(aLogErr, STR0080)//"Obs.: erro completo retornado:"
			For nErrInt := 1 To Len(aErrInt)
				FiltraLog( aLogErr, aErrInt[nErrInt])
			Next nErrInt	
		EndIf
	EndIf
EndIf

(cAliasQRY)->( dbCloseArea() )

If !lTudoComp .And. lTemREN
	RestArea( aAreaRET )
EndIf

RestArea( aAreaSQB )
RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fIntFunc
Realiza a integração da tabela SRA de funcionários
@author  Allyson Luiz Mesashi
@since   03/05/2022
/*/
//-------------------------------------------------------------------
Static Function fIntFunc(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken)

Local aArea 		:= GetArea()
Local aAreaRDZ 		:= RDZ->( GetArea() )
Local aAreaRET 		:= {}
Local aAreaSQ0 		:= SQ0->( GetArea() )
Local aAreaSQ3 		:= SQ3->( GetArea() )
Local aAreaSQB 		:= SQB->( GetArea() )
Local aAreaSRA 		:= SRA->( GetArea() )
Local aAreaSRG 		:= SRG->( GetArea() )
Local aCpfsProc		:= {}
Local aErrInt		:= {}
Local aRegInteg		:= {}
Local cAliasQRY 	:= "IMPSSRA"
Local cCodCargo		:= ""
Local cCodContr		:= ""
Local cCodDepto		:= ""
Local cCodDesl		:= ""
Local cCodRD0		:= ""
Local cFilIn		:= ""
Local cFilQry		:= ""
Local cQuery		:= ""
Local lVldDePara	:= !Empty( xFilial("SQ3") ) .Or. !Empty( xFilial("SQB") )
Local oJson			:= Nil
Local nCont			:= 0
Local nContFil		:= 0
Local nErrInt		:= 0
Local nInc			:= 0
Local nRegs			:= 0

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0073 + STR0119 )//"Iniciando Processamento..."##"Importação funcionários"
oSayProc2:SetText( STR0075 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Opções integradas: "
fRstLote()

If lVldDePara .And. lTemREN
	aAreaRET := RET->( GetArea() )
	RET->( dbSetOrder(2) )//RET_FILIAL+RET_TIPO+RET_FILCAD+RET_CODCAD
EndIf

RDZ->( dbSetOrder(1) )//RDZ_FILIAL+RDZ_EMPENT+RDZ_FILENT+RDZ_ENTIDA+RDZ_CODENT+RDZ_CODRD0
SQ0->( dbSetOrder(1) )//Q0_FILIAL+Q0_GRUPO
SQ3->( dbSetOrder(1) )//Q3_FILIAL+Q3_CARGO+Q3_CC
SQB->( dbSetOrder(1) )//QB_FILIAL+QB_DEPTO+QB_DESCRIC
SRG->( dbSetOrder(3) )//RG_FILIAL+RG_MAT+DTOS(RG_DATADEM)+DTOS(RG_DATAHOM)+RG_EFETIVA

For nContFil := 1 To Len(aArrayFil)
	cFilQry += aArrayFil[nContFil, 1]
Next nContFil
cFilIn := fSqlIn(cFilQry, FwGetTamFilial)

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + cTabSRA + " SRA "
cQuery 	+= "WHERE "
cQuery 	+= "SRA.RA_FILIAL IN (" + cFilIn + ") AND "
If !Empty(cFltFunc)
	cQuery 	+= "( " + GPEParSQL(fPrepExpIn(cFltFunc)) + " ) AND "
EndIf
cQuery 	+= "SRA.D_E_L_E_T_ = ' '"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

cQuery	:= "SELECT SRA.RA_CIC, SRA.RA_SITFOLH, SRA.RA_ADMISSA, SRA.R_E_C_N_O_ AS SRARECNO "
cQuery 	+= "FROM " + cTabSRA + " SRA "
cQuery 	+= "WHERE "
cQuery 	+= "SRA.RA_FILIAL IN (" + cFilIn + ") AND "
If !Empty(cFltFunc)
	cQuery 	+= "( " + GPEParSQL(fPrepExpIn(cFltFunc)) + " ) AND "
EndIf
cQuery 	+= "SRA.D_E_L_E_T_ = ' ' "
cQuery 	+= "ORDER BY 1,2 ASC, 3 DESC"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

If nCont == 0
	aAdd(aLogErr, STR0121)//"Erro na integração de funcionários: "
	aAdd(aLogErr, STR0189)//"Nenhum registro encontrado de acordo com o filtro realizado."
Else
	While (cAliasQRY)->( !EoF() )
		nInc++
		oMeter:Set(nInc)
		oSayProc3:SetText( STR0076 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros processados: "

		SRA->( dbGoTo( (cAliasQRY)->SRARECNO ) )

		If aScan( aCpfsProc, { |x| x == SRA->RA_CIC } ) > 0
			If aScan( aLogIncon, { |x| x == STR0167 } ) == 0//"Inconsistências na integração de funcionários:"
				aAdd(aLogIncon, STR0167)//"Inconsistências na integração de funcionários:"
			EndIf
			aAdd(aLogIncon, STR0123 + SRA->RA_FILIAL+SRA->RA_MAT + STR0166)//"Filial + Mat: "##" desprezado porque CPF já foi enviado anteriormente."
			(cAliasQRY)->( dbSkip() )
			Loop		
		EndIf

		cCodCargo	:= cEmpAnt+xFilial("SQ3", SRA->RA_FILIAL)+SRA->RA_CARGO
		cCodDepto	:= cEmpAnt+xFilial("SQB", SRA->RA_FILIAL)+SRA->RA_DEPTO

		If fVldSRA( @cCodCargo, @cCodDepto, @cCodRD0, @cCodContr, @cCodDesl )
			aAdd( aCpfsProc, SRA->RA_CIC )
			oJson := JsonObject():New()	
			oJson['integrationId'] 					:= cCodRD0
			oJson['name'] 							:= Iif( !Empty(SRA->RA_NOMECMP), AllTrim( SRA->RA_NOMECMP ), SRA->RA_NOME )
			oJson['socialName'] 					:= AllTrim( SRA->RA_NSOCIAL )
			oJson['email'] 							:= AllTrim( SRA->RA_EMAIL )
			oJson['admissionDate'] 					:= FWTimeStamp(6, SRA->RA_ADMISSA, "00:00:00")
			oJson['lastRaiseDate'] 					:= fUltSR3( SRA->RA_FILIAL+SRA->RA_MAT )
			oJson['birthDate'] 						:= FWTimeStamp(6, SRA->RA_NASC, "00:00:00")
			oJson['demissionDate'] 					:= IIf( !Empty(SRA->RA_DEMISSA), FWTimeStamp(6, SRA->RA_DEMISSA, "00:00:00"), "" )
			oJson['experienceEndDate'] 				:= IIf( !Empty(SRA->RA_VCTEXP2) .Or. !Empty(SRA->RA_VCTOEXP), FWTimeStamp(6, Iif( !Empty(SRA->RA_VCTEXP2), SRA->RA_VCTEXP2, SRA->RA_VCTOEXP ), "00:00:00"), "" )
			oJson['dismissalType'] 					:= cCodDesl
			oJson['hiringTypeIntegrationId'] 		:= cCodContr
			oJson['departmentIntegrationId'] 		:= AllTrim( cCodDepto )
			oJson['positionIntegrationId'] 			:= AllTrim( cCodCargo )
			oJson['facilityIntegrationId'] 			:= AllTrim( cEmpAnt+SRA->RA_FILIAL )
			fCriaLote( oJson )
		EndIf	

		(cAliasQRY)->( dbSkip() )
	EndDo

	If !Empty(aJsons) .Or. !Empty(aJsonsLote)
		If fEnvGen(cToken, @aErrInt, @aRegInteg, "5")
			aAdd(aLogImp, STR0120)//"Registros integrados de funcionários: "
			For nRegs := 1 To Len(aRegInteg)
				aAdd(aLogImp, aRegInteg[nRegs])
			Next nRegs
			nTotInteg += Len(aRegInteg)
		Else
			aAdd(aLogErr, STR0121)//"Erro na integração de funcionários: "
			aAdd(aLogErr, STR0083)//"Houve falha ao tentar efetuar a integração. Solicite ao administrador uma revisão dos parâmetros MV_APIPEM1, MV_APIPEM2 e/ou MV_APIPEM3"
			aAdd(aLogErr, STR0080)//"Obs.: erro completo retornado:"
			For nErrInt := 1 To Len(aErrInt)
				FiltraLog( aLogErr, aErrInt[nErrInt])
			Next nErrInt	
		EndIf
	EndIf
EndIf

(cAliasQRY)->( dbCloseArea() )

If lVldDePara .And. lTemREN
	RestArea( aAreaRET )
EndIf

RestArea( aAreaRDZ )
RestArea( aAreaSQ0 )
RestArea( aAreaSQ3 )
RestArea( aAreaSQB )
RestArea( aAreaSRA )
RestArea( aAreaSRG )
RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fIntContr
Realiza a integração da tabela S150 de grupos de contratos
@author  Allyson Luiz Mesashi
@since   16/05/2022
/*/
//-------------------------------------------------------------------
Static Function fIntContr(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken)

Local aArea 		:= GetArea()
Local aAreaSX5 		:= SX5->( GetArea() )
Local aErrInt		:= {}
Local aFilProc		:= {}
Local aRegInteg		:= {}
Local cAliasQRY 	:= "IMPSX5"
Local cFilIn		:= ""
Local cFilQry		:= ""
Local cQuery		:= ""
Local lTudoComp		:= Empty( xFilial("SX5") )
Local lTudoExc		:= FWModeAccess( "SX5", 1 )+FWModeAccess( "SX5", 2 )+FWModeAccess( "SX5", 3 ) == "EEE"
Local oJson			:= Nil
Local nCont			:= 0
Local nContFil		:= 0
Local nErrInt		:= 0
Local nInc			:= 0
Local nRegs			:= 0
Local nTamFil		:= 0

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0073 + STR0193 )//"Iniciando Processamento..."##"Importação grupos de cargo"
oSayProc2:SetText( STR0075 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Opções integradas: "
fRstLote()

If !lTudoComp .And. !lTudoExc
	nTamFil	:= Len(AllTrim(xFilial("SX5")))
	For nContFil := 1 To Len(aArrayFil)
		If aScan(aFilProc, {|x| x == xFilial("SX5", aArrayFil[nContFil, 1]) }) == 0
			aAdd(aFilProc, xFilial("SX5", aArrayFil[nContFil, 1]) )
			cFilQry += AllTrim(xFilial("SX5", aArrayFil[nContFil, 1]))
		EndIf
	Next nContFil
	cFilIn := fSqlIn(cFilQry, nTamFil)
ElseIf lTudoExc
	For nContFil := 1 To Len(aArrayFil)
		cFilQry += aArrayFil[nContFil, 1]
	Next nContFil
	cFilIn := fSqlIn(cFilQry, FwGetTamFilial)
EndIf

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + cTabSX5 + " SX5 "
cQuery 	+= "WHERE "
If !lTudoComp .And. !lTudoExc
	cQuery 	+= "SUBSTRING(SX5.X5_FILIAL, 1, " + cValToChar(nTamFil) + ") IN (" + cFilIn + ") AND "
ElseIf lTudoExc
	cQuery 	+= "SX5.X5_FILIAL IN (" + cFilIn + ") AND "
EndIf
cQuery 	+= "SX5.X5_TABELA = '1C' AND "
cQuery 	+= "SX5.D_E_L_E_T_ = ' '"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

cQuery	:= "SELECT R_E_C_N_O_ AS RECNO "
cQuery 	+= "FROM " + cTabSX5 + " SX5 "
cQuery 	+= "WHERE "
If !lTudoComp .And. !lTudoExc
	cQuery 	+= "SUBSTRING(SX5.X5_FILIAL, 1, " + cValToChar(nTamFil) + ") IN (" + cFilIn + ") AND "
ElseIf lTudoExc
	cQuery 	+= "SX5.X5_FILIAL IN (" + cFilIn + ") AND "
EndIf
cQuery 	+= "SX5.X5_TABELA = '1C' AND "
cQuery 	+= "SX5.D_E_L_E_T_ = ' ' "
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

If nCont == 0
	aAdd(aLogErr, STR0195)//"Erro na integração de grupos de contrato: "
	aAdd(aLogErr, STR0189)//"Nenhum registro encontrado de acordo com o filtro realizado."
Else
	While (cAliasQRY)->( !EoF() )
		nInc++
		oMeter:Set(nInc)
		oSayProc3:SetText( STR0076 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros processados: "

		SX5->( dbGoTo( (cAliasQRY)->RECNO) )		

		oJson := JsonObject():New()
		oJson['integrationId'] 	:= AllTrim( cEmpAnt+SX5->X5_FILIAL+SX5->X5_CHAVE )
		oJson['name'] 			:= AllTrim( X5Descri() )
		fCriaLote( oJson )

		(cAliasQRY)->( dbSkip() )
	EndDo

	If !Empty(aJsons) .Or. !Empty(aJsonsLote)
		If fEnvGen(cToken, @aErrInt, @aRegInteg, "6")
			aAdd(aLogImp, STR0194)//"Registros integrados dos grupos de contrato: "
			For nRegs := 1 To Len(aRegInteg)
				aAdd(aLogImp, aRegInteg[nRegs])
			Next nRegs
			nTotInteg += Len(aRegInteg)
		Else
			aAdd(aLogErr, STR0195)//"Erro na integração de grupos de contrato: "
			aAdd(aLogErr, STR0083)//"Houve falha ao tentar efetuar a integração. Solicite ao administrador uma revisão dos parâmetros MV_APIPEM1, MV_APIPEM2 e/ou MV_APIPEM3"
			aAdd(aLogErr, STR0080)//"Obs.: erro completo retornado:"
			For nErrInt := 1 To Len(aErrInt)
				FiltraLog( aLogErr, aErrInt[nErrInt])
			Next nErrInt	
		EndIf
	EndIf
EndIf

(cAliasQRY)->( dbCloseArea() )

RestArea( aAreaSX5 )
RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fIntHCarg
Realiza a integração da tabela SR7 de movimentaçãocargos
@author  Allyson Luiz Mesashi
@since   02/06/2022
/*/
//-------------------------------------------------------------------
Static Function fIntHCarg(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken)

Local aArea 		:= GetArea()
Local aAreaRET 		:= {}
Local aAreaSQ3 		:= SQ3->( GetArea() )
Local aAreaSR7 		:= SR7->( GetArea() )
Local aAreaSRA 		:= SRA->( GetArea() )
Local aErrInt		:= {}
Local aRegInteg		:= {}
Local aRegsSR7		:= {}
Local cAliasQRY 	:= "IMPSR7"
Local cCodCargo		:= ""
Local cCodRD0		:= ""
Local cFilIn		:= ""
Local cFilQry		:= ""
Local cFilMatAnt	:= ""
Local cQuery		:= ""
Local lTudoComp		:= Empty( xFilial("SQ3") )
Local oJson			:= Nil
Local nCont			:= 0
Local nContFil		:= 0
Local nErrInt		:= 0
Local nInc			:= 0
Local nRegs			:= 0

SQ3->( dbSetOrder(1) )//Q3_FILIAL+Q3_CARGO+Q3_CC
SRA->( dbSetOrder(1) )//RA_FILIAL+RA_MAT+RA_NOME

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0073 + STR0202 )//"Iniciando Processamento..."##"Importação movimentação de cargos"
oSayProc2:SetText( STR0075 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Opções integradas: "
fRstLote()

If !lTudoComp .And. lTemREN
	aAreaRET := RET->( GetArea() )
	RET->( dbSetOrder(2) )//RET_FILIAL+RET_TIPO+RET_FILCAD+RET_CODCAD
EndIf

For nContFil := 1 To Len(aArrayFil)
	cFilQry += aArrayFil[nContFil, 1]
Next nContFil
cFilIn := fSqlIn(cFilQry, FwGetTamFilial)

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + cTabSR7 + " SR7 "
cQuery 	+= "WHERE "
cQuery 	+= "SR7.R7_FILIAL IN (" + cFilIn + ") AND "
If !Empty(cFltHCarg)
	cQuery 	+= "( " + GPEParSQL(fPrepExpIn(cFltHCarg)) + " ) AND "
EndIf
cQuery 	+= "SR7.D_E_L_E_T_ = ' '"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

cQuery	:= "SELECT SR7.R7_FILIAL, SR7.R7_MAT, SR7.R7_DATA, SR7.R7_SEQ, R_E_C_N_O_ AS RECNO "
cQuery 	+= "FROM " + cTabSR7 + " SR7 "
cQuery 	+= "WHERE "
cQuery 	+= "SR7.R7_FILIAL IN (" + cFilIn + ") AND "
If !Empty(cFltHCarg)
	cQuery 	+= "( " + GPEParSQL(fPrepExpIn(cFltHCarg)) + " ) AND "
EndIf
cQuery 	+= "SR7.D_E_L_E_T_ = ' ' "
cQuery 	+= "ORDER BY 1, 2, 3, 4"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

If nCont == 0
	aAdd(aLogErr, STR0203)//"Erro na integração de movimentação de cargos: "
	aAdd(aLogErr, STR0189)//"Nenhum registro encontrado de acordo com o filtro realizado."
Else
	While (cAliasQRY)->( !EoF() )
		nInc++
		oMeter:Set(nInc)
		oSayProc3:SetText( STR0076 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros processados: "

		SR7->( dbGoTo( (cAliasQRY)->RECNO ) )
		SRA->( dbSeek( SR7->R7_FILIAL + SR7->R7_MAT ) )

		If cFilMatAnt != SR7->R7_FILIAL+SR7->R7_MAT
			aRegsSR7 	:= {}
			cFilMatAnt	:= SR7->R7_FILIAL+SR7->R7_MAT
			aAdd( aRegsSR7, { SR7->R7_FILIAL, SR7->R7_MAT, SR7->R7_DATA, SR7->R7_SEQ, SR7->R7_CARGO } )
		EndIf

		If SR7->R7_DATA != SRA->RA_ADMISSA .And. SR7->R7_CARGO != aRegsSR7[Len(aRegsSR7), 5]
			cCodCargo	:= cEmpAnt+xFilial("SQ3", SR7->R7_FILIAL)+SR7->R7_CARGO

			If fVldHCarg( !lTudoComp, @cCodRD0, @cCodCargo )
				oJson := JsonObject():New()
				oJson['integrationId'] 				:= AllTrim( cEmpAnt+SR7->R7_FILIAL+SR7->R7_MAT+dToS(SR7->R7_DATA)+SR7->R7_SEQ )
				oJson['personIntegrationId'] 		:= AllTrim( cCodRD0 )
				oJson['positionIntegrationId'] 		:= AllTrim( cCodCargo )
				oJson['changeDate'] 				:= FWTimeStamp(6, SR7->R7_DATA, "00:00:00")
				fCriaLote( oJson )
			EndIf
		EndIf

		(cAliasQRY)->( dbSkip() )
	EndDo

	If !Empty(aJsons) .Or. !Empty(aJsonsLote)
		If fEnvGen(cToken, @aErrInt, @aRegInteg, "7")
			aAdd(aLogImp, STR0204)//"Registros integrados de movimentação de cargos: "
			For nRegs := 1 To Len(aRegInteg)
				aAdd(aLogImp, aRegInteg[nRegs])
			Next nRegs
			nTotInteg += Len(aRegInteg)
		Else
			aAdd(aLogErr, STR0205)//"Erro na integração de movimentação de cargos: "
			aAdd(aLogErr, STR0083)//"Houve falha ao tentar efetuar a integração. Solicite ao administrador uma revisão dos parâmetros MV_APIPEM1, MV_APIPEM2 e/ou MV_APIPEM3"
			aAdd(aLogErr, STR0080)//"Obs.: erro completo retornado:"
			For nErrInt := 1 To Len(aErrInt)
				FiltraLog( aLogErr, aErrInt[nErrInt])
			Next nErrInt	
		EndIf
	EndIf
EndIf

(cAliasQRY)->( dbCloseArea() )

If !lTudoComp .And. lTemREN
	RestArea( aAreaRET )
EndIf

RestArea( aAreaSQ3 )
RestArea( aAreaSR7 )
RestArea( aAreaSRA )
RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fIntHDep
Realiza a integração da tabela SRE de movimentação de departamentos
@author  Allyson Luiz Mesashi
@since   06/06/2022
/*/
//-------------------------------------------------------------------
Static Function fIntHDep(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken)

Local aArea 		:= GetArea()
Local aAreaRET 		:= {}
Local aAreaSQB 		:= SQB->( GetArea() )
Local aAreaSRA 		:= SRA->( GetArea() )
Local aAreaSRE 		:= SRE->( GetArea() )
Local aErrInt		:= {}
Local aRegInteg		:= {}
Local cAliasQRY 	:= "IMPSRE"
Local cCodDepto		:= ""
Local cCodRD0		:= ""
Local cFilIn		:= ""
Local cFilQry		:= ""
Local cQuery		:= ""
Local lTudoComp		:= Empty( xFilial("SQB") )
Local oJson			:= Nil
Local nCont			:= 0
Local nContFil		:= 0
Local nErrInt		:= 0
Local nInc			:= 0
Local nRegs			:= 0

SQB->( dbSetOrder(1) )//QB_FILIAL+QB_DEPTO+QB_DESCRIC
SRA->( dbSetOrder(1) )//RA_FILIAL+RA_MAT+RA_NOME

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0073 + STR0209 )//"Iniciando Processamento..."##"Importação movimentação de departamentos"
oSayProc2:SetText( STR0075 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Opções integradas: "
fRstLote()

If !lTudoComp .And. lTemREN
	aAreaRET := RET->( GetArea() )
	RET->( dbSetOrder(2) )//RET_FILIAL+RET_TIPO+RET_FILCAD+RET_CODCAD
EndIf

For nContFil := 1 To Len(aArrayFil)
	cFilQry += aArrayFil[nContFil, 1]
Next nContFil
cFilIn := fSqlIn(cFilQry, FwGetTamFilial)

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + cTabSRE + " SRE "
cQuery 	+= "WHERE "
cQuery 	+= "SRE.RE_EMPP = '" + cEmpAnt + "' AND "
cQuery 	+= "( SRE.RE_FILIALD IN (" + cFilIn + ") OR "
cQuery 	+= "SRE.RE_FILIALP IN (" + cFilIn + ") ) AND "
cQuery 	+= "( SRE.RE_EMPD != SRE.RE_EMPP OR "
cQuery 	+= "SRE.RE_FILIALD != SRE.RE_FILIALP OR "
cQuery 	+= "SRE.RE_DEPTOD != SRE.RE_DEPTOP ) AND "
If !Empty(cFltHDep)
	cQuery 	+= "( " + GPEParSQL(fPrepExpIn(cFltHDep)) + " ) AND "
EndIf
cQuery 	+= "SRE.D_E_L_E_T_ = ' '"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

cQuery	:= "SELECT SRE.RE_FILIALP, SRE.RE_MATP, SRE.RE_DATA, R_E_C_N_O_ AS RECNO "
cQuery 	+= "FROM " + cTabSRE + " SRE "
cQuery 	+= "WHERE "
cQuery 	+= "SRE.RE_EMPP = '" + cEmpAnt + "' AND "
cQuery 	+= "( SRE.RE_FILIALD IN (" + cFilIn + ") OR "
cQuery 	+= "SRE.RE_FILIALP IN (" + cFilIn + ") ) AND "
cQuery 	+= "( SRE.RE_EMPD != SRE.RE_EMPP OR "
cQuery 	+= "SRE.RE_FILIALD != SRE.RE_FILIALP OR "
cQuery 	+= "SRE.RE_DEPTOD != SRE.RE_DEPTOP ) AND "
If !Empty(cFltHDep)
	cQuery 	+= "( " + GPEParSQL(fPrepExpIn(cFltHDep)) + " ) AND "
EndIf
cQuery 	+= "SRE.D_E_L_E_T_ = ' ' "
cQuery 	+= "ORDER BY 1, 2, 3"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

If nCont == 0
	aAdd(aLogErr, STR0210)//"Erro na integração de movimentação de departamentos: "
	aAdd(aLogErr, STR0189)//"Nenhum registro encontrado de acordo com o filtro realizado."
Else
	While (cAliasQRY)->( !EoF() )
		nInc++
		oMeter:Set(nInc)
		oSayProc3:SetText( STR0076 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros processados: "

		SRE->( dbGoTo( (cAliasQRY)->RECNO ) )
		SRA->( dbSeek( SubStr( SRE->RE_FILIALP, 1, FwGetTamFilial ) + SRE->RE_MATP ) )

		cCodDepto	:= cEmpAnt+xFilial("SQB", SRA->RA_FILIAL)+SRE->RE_DEPTOP

		If fVldHDep( !lTudoComp, @cCodRD0, @cCodDepto )
			oJson := JsonObject():New()
			oJson['integrationId'] 				:= AllTrim( cEmpAnt+SubStr( SRE->RE_FILIALP, 1, FwGetTamFilial )+SRE->RE_MATP+dToS(SRE->RE_DATA) )
			oJson['personIntegrationId'] 		:= AllTrim( cCodRD0 )
			oJson['departmentIntegrationId']	:= AllTrim( cCodDepto )
			oJson['changeDate'] 				:= FWTimeStamp(6, SRE->RE_DATA, "00:00:00")
			fCriaLote( oJson )
		EndIf

		(cAliasQRY)->( dbSkip() )
	EndDo

	If !Empty(aJsons) .Or. !Empty(aJsonsLote)
		If fEnvGen(cToken, @aErrInt, @aRegInteg, "8")
			aAdd(aLogImp, STR0211)//"Registros integrados de movimentação de departamentos: "
			For nRegs := 1 To Len(aRegInteg)
				aAdd(aLogImp, aRegInteg[nRegs])
			Next nRegs
			nTotInteg += Len(aRegInteg)
		Else
			aAdd(aLogErr, STR0212)//"Erro na integração de movimentação de departamentos: "
			aAdd(aLogErr, STR0083)//"Houve falha ao tentar efetuar a integração. Solicite ao administrador uma revisão dos parâmetros MV_APIPEM1, MV_APIPEM2 e/ou MV_APIPEM3"
			aAdd(aLogErr, STR0080)//"Obs.: erro completo retornado:"
			For nErrInt := 1 To Len(aErrInt)
				FiltraLog( aLogErr, aErrInt[nErrInt])
			Next nErrInt	
		EndIf
	EndIf
EndIf

(cAliasQRY)->( dbCloseArea() )

If !lTudoComp .And. lTemREN
	RestArea( aAreaRET )
EndIf

RestArea( aAreaSQB )
RestArea( aAreaSRE )
RestArea( aAreaSRA )
RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fIntHFil
Realiza a integração da tabela SRE de movimentação de filiais
@author  Allyson Luiz Mesashi
@since   07/06/2022
/*/
//-------------------------------------------------------------------
Static Function fIntHFil(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken)

Local aArea 		:= GetArea()
Local aAreaSRA 		:= SRA->( GetArea() )
Local aAreaSRE 		:= SRE->( GetArea() )
Local aErrInt		:= {}
Local aRegInteg		:= {}
Local cAliasQRY 	:= "IMPSRE"
Local cCodRD0		:= ""
Local cFilIn		:= ""
Local cFilQry		:= ""
Local cQuery		:= ""
Local oJson			:= Nil
Local nCont			:= 0
Local nContFil		:= 0
Local nErrInt		:= 0
Local nInc			:= 0
Local nRegs			:= 0

SRA->( dbSetOrder(1) )//RA_FILIAL+RA_MAT+RA_NOME

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0073 + STR0216 )//"Iniciando Processamento..."##"Importação movimentação de filiais"
oSayProc2:SetText( STR0075 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Opções integradas: "
fRstLote()

For nContFil := 1 To Len(aArrayFil)
	cFilQry += aArrayFil[nContFil, 1]
Next nContFil
cFilIn := fSqlIn(cFilQry, FwGetTamFilial)

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + cTabSRE + " SRE "
cQuery 	+= "WHERE "
cQuery 	+= "SRE.RE_EMPP = '" + cEmpAnt + "' AND "
cQuery 	+= "( SRE.RE_FILIALD IN (" + cFilIn + ") OR "
cQuery 	+= "SRE.RE_FILIALP IN (" + cFilIn + ") ) AND "
cQuery 	+= "( SRE.RE_EMPD != SRE.RE_EMPP OR "
cQuery 	+= "SRE.RE_FILIALD != SRE.RE_FILIALP ) AND "
If !Empty(cFltHFil)
	cQuery 	+= "( " + GPEParSQL(fPrepExpIn(cFltHFil)) + " ) AND "
EndIf
cQuery 	+= "SRE.D_E_L_E_T_ = ' '"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

cQuery	:= "SELECT SRE.RE_FILIALP, SRE.RE_MATP, SRE.RE_DATA, R_E_C_N_O_ AS RECNO "
cQuery 	+= "FROM " + cTabSRE + " SRE "
cQuery 	+= "WHERE "
cQuery 	+= "SRE.RE_EMPP = '" + cEmpAnt + "' AND "
cQuery 	+= "( SRE.RE_FILIALD IN (" + cFilIn + ") OR "
cQuery 	+= "SRE.RE_FILIALP IN (" + cFilIn + ") ) AND "
cQuery 	+= "( SRE.RE_EMPD != SRE.RE_EMPP OR "
cQuery 	+= "SRE.RE_FILIALD != SRE.RE_FILIALP ) AND "
If !Empty(cFltHFil)
	cQuery 	+= "( " + GPEParSQL(fPrepExpIn(cFltHFil)) + " ) AND "
EndIf
cQuery 	+= "SRE.D_E_L_E_T_ = ' '"
cQuery 	+= "ORDER BY 1, 2, 3"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

If nCont == 0
	aAdd(aLogErr, STR0217)//"Erro na integração de movimentação de filiais: "
	aAdd(aLogErr, STR0189)//"Nenhum registro encontrado de acordo com o filtro realizado."
Else
	While (cAliasQRY)->( !EoF() )
		nInc++
		oMeter:Set(nInc)
		oSayProc3:SetText( STR0076 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros processados: "

		SRE->( dbGoTo( (cAliasQRY)->RECNO ) )
		SRA->( dbSeek( SubStr( SRE->RE_FILIALP, 1, FwGetTamFilial ) + SRE->RE_MATP ) )

		If fVldHFil( @cCodRD0 )
			oJson := JsonObject():New()
			oJson['integrationId'] 				:= AllTrim( cEmpAnt+SubStr( SRE->RE_FILIALP, 1, FwGetTamFilial )+SRE->RE_MATP+dToS(SRE->RE_DATA) )
			oJson['personIntegrationId'] 		:= AllTrim( cCodRD0 )
			oJson['facilityIntegrationId']		:= AllTrim( cEmpAnt+SubStr( SRE->RE_FILIALP, 1, FwGetTamFilial ) )
			oJson['changeDate'] 				:= FWTimeStamp(6, SRE->RE_DATA, "00:00:00")
			fCriaLote( oJson )
		EndIf

		(cAliasQRY)->( dbSkip() )
	EndDo

	If !Empty(aJsons) .Or. !Empty(aJsonsLote)
		If fEnvGen(cToken, @aErrInt, @aRegInteg, "9")
			aAdd(aLogImp, STR0218)//"Registros integrados de movimentação de filiais: "
			For nRegs := 1 To Len(aRegInteg)
				aAdd(aLogImp, aRegInteg[nRegs])
			Next nRegs
			nTotInteg += Len(aRegInteg)
		Else
			aAdd(aLogErr, STR0219)//"Erro na integração de movimentação de filiais: "
			aAdd(aLogErr, STR0083)//"Houve falha ao tentar efetuar a integração. Solicite ao administrador uma revisão dos parâmetros MV_APIPEM1, MV_APIPEM2 e/ou MV_APIPEM3"
			aAdd(aLogErr, STR0080)//"Obs.: erro completo retornado:"
			For nErrInt := 1 To Len(aErrInt)
				FiltraLog( aLogErr, aErrInt[nErrInt])
			Next nErrInt	
		EndIf
	EndIf
EndIf

(cAliasQRY)->( dbCloseArea() )

RestArea( aAreaSRE )
RestArea( aAreaSRA )
RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fIntHGrp
Realiza a integração da tabela SR7 de movimentação de grupos de cargo
@author  Allyson Luiz Mesashi
@since   08/06/2022
/*/
//-------------------------------------------------------------------
Static Function fIntHGrp(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken)

Local aArea 		:= GetArea()
Local aAreaRET 		:= {}
Local aAreaSQ3 		:= SQ3->( GetArea() )
Local aAreaSR7 		:= SR7->( GetArea() )
Local aAreaSRA 		:= SRA->( GetArea() )
Local aErrInt		:= {}
Local aRegInteg		:= {}
Local aRegsSR7		:= {}
Local cAliasQRY 	:= "IMPSR7"
Local cCodGrpQ3		:= ""
Local cCodGrupo		:= ""
Local cCodRD0		:= ""
Local cFilIn		:= ""
Local cFilQry		:= ""
Local cFilMatAnt	:= ""
Local cQuery		:= ""
Local lTudoComp		:= Empty( xFilial("SQ3") )
Local oJson			:= Nil
Local nCont			:= 0
Local nContFil		:= 0
Local nErrInt		:= 0
Local nInc			:= 0
Local nRegs			:= 0

SQ3->( dbSetOrder(1) )//Q3_FILIAL+Q3_CARGO+Q3_CC
SRA->( dbSetOrder(1) )//RA_FILIAL+RA_MAT+RA_NOME

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0073 + STR0223 )//"Iniciando Processamento..."##"Importação movimentação de grupos de cargo"
oSayProc2:SetText( STR0075 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Opções integradas: "
fRstLote()

If !lTudoComp .And. lTemREN
	aAreaRET := RET->( GetArea() )
	RET->( dbSetOrder(2) )//RET_FILIAL+RET_TIPO+RET_FILCAD+RET_CODCAD
EndIf

For nContFil := 1 To Len(aArrayFil)
	cFilQry += aArrayFil[nContFil, 1]
Next nContFil
cFilIn := fSqlIn(cFilQry, FwGetTamFilial)

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + cTabSR7 + " SR7 "
cQuery 	+= "WHERE "
cQuery 	+= "SR7.R7_FILIAL IN (" + cFilIn + ") AND "
If !Empty(cFltHGrp)
	cQuery 	+= "( " + GPEParSQL(fPrepExpIn(cFltHGrp)) + " ) AND "
EndIf
cQuery 	+= "SR7.D_E_L_E_T_ = ' '"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

cQuery	:= "SELECT SR7.R7_FILIAL, SR7.R7_MAT, SR7.R7_DATA, SR7.R7_SEQ, SR7.R_E_C_N_O_ AS RECNO "
cQuery 	+= "FROM " + cTabSR7 + " SR7 "
cQuery 	+= "WHERE "
cQuery 	+= "SR7.R7_FILIAL IN (" + cFilIn + ") AND "
If !Empty(cFltHGrp)
	cQuery 	+= "( " + GPEParSQL(fPrepExpIn(cFltHGrp)) + " ) AND "
EndIf
cQuery 	+= "SR7.D_E_L_E_T_ = ' ' "
cQuery 	+= "ORDER BY 1, 2, 3, 4"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

If nCont == 0
	aAdd(aLogErr, STR0224)//"Erro na integração de movimentação de grupos de cargo: "
	aAdd(aLogErr, STR0189)//"Nenhum registro encontrado de acordo com o filtro realizado."
Else
	While (cAliasQRY)->( !EoF() )
		nInc++
		oMeter:Set(nInc)
		oSayProc3:SetText( STR0076 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros processados: "

		SR7->( dbGoTo( (cAliasQRY)->RECNO ) )
		SRA->( dbSeek( SR7->R7_FILIAL + SR7->R7_MAT ) )

		cCodGrpQ3 := FDesc("SQ3", SR7->R7_CARGO, "Q3_GRUPO", NIL, SR7->R7_FILIAL, 1)

		If cFilMatAnt != SR7->R7_FILIAL+SR7->R7_MAT
			aRegsSR7 	:= {}
			cFilMatAnt	:= SR7->R7_FILIAL+SR7->R7_MAT
			aAdd( aRegsSR7, { SR7->R7_FILIAL, SR7->R7_MAT, SR7->R7_DATA, SR7->R7_SEQ, SR7->R7_CARGO, cCodGrpQ3 } )
		EndIf

		If SR7->R7_DATA != SRA->RA_ADMISSA .And. cCodGrpQ3 != aRegsSR7[Len(aRegsSR7), 6]
			cCodGrupo	:= cEmpAnt+xFilial("SQ0", SR7->R7_FILIAL)+cCodGrpQ3

			If fVldHGrp( !lTudoComp, @cCodRD0, @cCodGrupo, cCodGrpQ3 )
				oJson := JsonObject():New()
				oJson['integrationId'] 				:= AllTrim( cEmpAnt+SR7->R7_FILIAL+SR7->R7_MAT+dToS(SR7->R7_DATA)+SR7->R7_SEQ )
				oJson['personIntegrationId'] 		:= AllTrim( cCodRD0 )
				oJson['positionGroupIntegrationId'] := AllTrim( cCodGrupo )
				oJson['changeDate'] 				:= FWTimeStamp(6, SR7->R7_DATA, "00:00:00")
				fCriaLote( oJson )
			EndIf
		EndIf

		(cAliasQRY)->( dbSkip() )
	EndDo

	If !Empty(aJsons) .Or. !Empty(aJsonsLote)
		If fEnvGen(cToken, @aErrInt, @aRegInteg, "A")
			aAdd(aLogImp, STR0225)//"Registros integrados de movimentação de grupos de cargo: "
			For nRegs := 1 To Len(aRegInteg)
				aAdd(aLogImp, aRegInteg[nRegs])
			Next nRegs
			nTotInteg += Len(aRegInteg)
		Else
			aAdd(aLogErr, STR0205)//"Erro na integração de movimentação de grupos de cargo: "
			aAdd(aLogErr, STR0083)//"Houve falha ao tentar efetuar a integração. Solicite ao administrador uma revisão dos parâmetros MV_APIPEM1, MV_APIPEM2 e/ou MV_APIPEM3"
			aAdd(aLogErr, STR0080)//"Obs.: erro completo retornado:"
			For nErrInt := 1 To Len(aErrInt)
				FiltraLog( aLogErr, aErrInt[nErrInt])
			Next nErrInt	
		EndIf
	EndIf
EndIf

(cAliasQRY)->( dbCloseArea() )

If !lTudoComp .And. lTemREN
	RestArea( aAreaRET )
EndIf

RestArea( aAreaSQ3 )
RestArea( aAreaSR7 )
RestArea( aAreaSRA )
RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fIntAfas
Realiza a integração da tabela SR8 de afastamentos
@author  Allyson Luiz Mesashi
@since   29/06/2022
/*/
//-------------------------------------------------------------------
Static Function fIntAfas(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken)

Local aArea 		:= GetArea()
Local aAreaRCM 		:= RCM->( GetArea() )
Local aAreaSR8 		:= SR8->( GetArea() )
Local aAreaSRA 		:= SRA->( GetArea() )
Local aErrInt		:= {}
Local aRegInteg		:= {}
Local cAliasQRY 	:= "IMPSR8"
Local cCodRD0		:= ""
Local cCodTipo		:= ""
Local cFilIn		:= ""
Local cFilQry		:= ""
Local cQuery		:= ""
Local oJson			:= Nil
Local nCont			:= 0
Local nContFil		:= 0
Local nErrInt		:= 0
Local nInc			:= 0
Local nRegs			:= 0

RCM->( dbSetOrder(1) )//RCM_FILIAL+RCM_TIPO
SRA->( dbSetOrder(1) )//RA_FILIAL+RA_MAT+RA_NOME

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0073 + STR0231 )//"Iniciando Processamento..."##"Importação afastamentos"
oSayProc2:SetText( STR0075 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Opções integradas: "
fRstLote()

For nContFil := 1 To Len(aArrayFil)
	cFilQry += aArrayFil[nContFil, 1]
Next nContFil
cFilIn := fSqlIn(cFilQry, FwGetTamFilial)

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + cTabSR8 + " SR8 "
cQuery 	+= "WHERE "
cQuery 	+= "SR8.R8_FILIAL IN (" + cFilIn + ") AND "
If !Empty(cFltAfas)
	cQuery 	+= "( " + GPEParSQL(fPrepExpIn(cFltAfas)) + " ) AND "
EndIf
cQuery 	+= "SR8.D_E_L_E_T_ = ' '"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

cQuery	:= "SELECT R8_FILIAL, R8_MAT, R8_DATAINI, R_E_C_N_O_ AS RECNO  "
cQuery 	+= "FROM " + cTabSR8 + " SR8 "
cQuery 	+= "WHERE "
cQuery 	+= "SR8.R8_FILIAL IN (" + cFilIn + ") AND "
If !Empty(cFltAfas)
	cQuery 	+= "( " + GPEParSQL(fPrepExpIn(cFltAfas)) + " ) AND "
EndIf
cQuery 	+= "SR8.D_E_L_E_T_ = ' '"
cQuery 	+= "ORDER BY 1, 2, 3"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

If nCont == 0
	aAdd(aLogErr, STR0232)//"Erro na integração de afastamentos: "
	aAdd(aLogErr, STR0189)//"Nenhum registro encontrado de acordo com o filtro realizado."
Else
	While (cAliasQRY)->( !EoF() )
		nInc++
		oMeter:Set(nInc)
		oSayProc3:SetText( STR0076 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros integrados: "

		SR8->( dbGoTo( (cAliasQRY)->RECNO ) )
		SRA->( dbSeek( SR8->R8_FILIAL + SR8->R8_MAT ) )

		If fVldAfas( @cCodRD0, @cCodTipo )
			oJson := JsonObject():New()
			oJson['integrationId'] 					:= AllTrim( cEmpAnt+SR8->R8_FILIAL+SR8->R8_MAT+dToS(SR8->R8_DATAINI) )
			oJson['personIntegrationId'] 			:= AllTrim( cCodRD0 )
			oJson['type'] 							:= AllTrim( cCodTipo )
			oJson['startDate'] 						:= FWTimeStamp(6, SR8->R8_DATAINI, "00:00:00")
			oJson['endDate'] 						:= FWTimeStamp(6, SR8->R8_DATAFIM, "00:00:00")
			fCriaLote( oJson )
		EndIf

		(cAliasQRY)->( dbSkip() )
	EndDo

	If !Empty(aJsons) .Or. !Empty(aJsonsLote)
		If fEnvGen(cToken, @aErrInt, @aRegInteg, "B")
			aAdd(aLogImp, STR0233)//"Registros integrados de afastamentos: "
			For nRegs := 1 To Len(aRegInteg)
				aAdd(aLogImp, aRegInteg[nRegs])
			Next nRegs
			nTotInteg += Len(aRegInteg)
		Else
			aAdd(aLogErr, STR0232)//"Erro na integração de afastamentos: "
			aAdd(aLogErr, STR0083)//"Houve falha ao tentar efetuar a integração. Solicite ao administrador uma revisão dos parâmetros MV_APIPEM1, MV_APIPEM2 e/ou MV_APIPEM3"
			aAdd(aLogErr, STR0080)//"Obs.: erro completo retornado:"
			For nErrInt := 1 To Len(aErrInt)
				FiltraLog( aLogErr, aErrInt[nErrInt])
			Next nErrInt	
		EndIf
	EndIf
EndIf

(cAliasQRY)->( dbCloseArea() )

RestArea( aAreaRCM )
RestArea( aAreaSR8 )
RestArea( aAreaSRA )
RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fIntFalta
Realiza a integração da tabela SRD de faltas
@author  Allyson Luiz Mesashi
@since   01/07/2022
/*/
//-------------------------------------------------------------------
Static Function fIntFalta(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken)

Local aArea 		:= GetArea()
Local aAreaSRA 		:= SRA->( GetArea() )
Local aAreaSRD 		:= SRD->( GetArea() )
Local aCodFol		:= {}
Local aErrInt		:= {}
Local aIdsErr		:= {}
Local aRegInteg		:= {}
Local aRegSRD		:= {}
Local cAliasQRY 	:= "IMPSRD"
Local cCodFaltas	:= ""
Local cCodRD0		:= ""
Local cFilIn		:= ""
Local cFilQry		:= ""
Local cPerFim		:= cValToChar(nPerSRD)+"12"
Local cPerIni		:= cValToChar(nPerSRD)+"01"
Local cQuery		:= ""
Local oJson			:= Nil
Local nCont			:= 0
Local nContFil		:= 0
Local nContSRD		:= 0
Local nDias			:= 0
Local nErrInt		:= 0
Local nHrsDia		:= 0
Local nIds			:= 0
Local nInc			:= 0
Local nPosSRD		:= 0
Local nRegs			:= 0

SRA->( dbSetOrder(1) )//RA_FILIAL+RA_MAT+RA_NOME

If Fp_CodFol(@aCodFol, cFilAnt, .F., Nil, @aIdsErr)
	cCodFaltas := fSqlIN( aCodFol[54, 1]+aCodFol[55, 1]+aCodFol[203, 1]+aCodFol[242, 1]+aCodFol[243, 1], 3 )
Else
	aAdd(aLogErr, STR0239)//"Erro na integração de faltas: "
	aAdd(aLogErr, STR0242)//"A integração não será realizada pois falta o cadastro de verbas para o(s) identificador(es) de cálculo abaixo:"
	For nIds := 1 To Len(aIdsErr)
		aAdd(aLogErr, aIdsErr[nIds])
	Next nIds
	Return
EndIf

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0073 + STR0238 )//"Iniciando Processamento..."##"Importação faltas"
oSayProc2:SetText( STR0075 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Opções integradas: "
fRstLote()

For nContFil := 1 To Len(aArrayFil)
	cFilQry += aArrayFil[nContFil, 1]
Next nContFil
cFilIn := fSqlIn(cFilQry, FwGetTamFilial)

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + cTabSRD + " SRD "
cQuery 	+= "WHERE "
cQuery 	+= "SRD.RD_FILIAL IN (" + cFilIn + ") AND "
cQuery 	+= "SRD.RD_DATARQ >= '" + cPerIni + "' AND SRD.RD_DATARQ <= '" + cPerFim + "' AND "
cQuery 	+= "SRD.RD_PD IN (" + cCodFaltas + ") AND "
If !Empty(cFltFalta)
	cQuery 	+= "( " + GPEParSQL(fPrepExpIn(cFltFalta)) + " ) AND "
EndIf
cQuery 	+= "SRD.D_E_L_E_T_ = ' '"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

cQuery	:= "SELECT R_E_C_N_O_ AS RECNO "
cQuery 	+= "FROM " + cTabSRD + " SRD "
cQuery 	+= "WHERE "
cQuery 	+= "SRD.RD_FILIAL IN (" + cFilIn + ") AND "
cQuery 	+= "SRD.RD_DATARQ >= '" + cPerIni + "' AND SRD.RD_DATARQ <= '" + cPerFim + "' AND "
cQuery 	+= "SRD.RD_PD IN (" + cCodFaltas + ") AND "
If !Empty(cFltFalta)
	cQuery 	+= "( " + GPEParSQL(fPrepExpIn(cFltFalta)) + " ) AND "
EndIf
cQuery 	+= "SRD.D_E_L_E_T_ = ' ' "
cQuery 	+= "ORDER BY RD_FILIAL, RD_MAT, RD_DATARQ"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

If nCont == 0
	aAdd(aLogErr, STR0239)//"Erro na integração de faltas: "
	aAdd(aLogErr, STR0189)//"Nenhum registro encontrado de acordo com o filtro realizado."
Else
	While (cAliasQRY)->( !EoF() )
		SRD->( dbGoTo( (cAliasQRY)->RECNO ) )
		If SRD->RD_TIPO1 == "D"
			nDias := SRD->RD_HORAS
		Else
			nHrsDia := gpRetSR9("SR9", SRD->RD_DATPGT, "RA_HRSDIA")
			nHrsDia := Iif( Empty(nHrsDia), fDesc("SRA", SRD->RD_MAT, "RA_HRSDIA", NIL, SRD->RD_FILIAL, 1), nHrs )	
			nDias	:= SRD->RD_HORAS/nHrsDia
		EndIf

		If ( nPosSRD := aScan( aRegSRD, { |x| x[1]+x[2]+x[3] == SRD->RD_FILIAL+SRD->RD_MAT+SRD->RD_DATARQ} ) ) == 0
			aAdd( aRegSRD, { SRD->RD_FILIAL, SRD->RD_MAT, SRD->RD_DATARQ, nDias } )
		Else
			aRegSRD[nPosSRD, 4] += nDias
		EndIf
		(cAliasQRY)->( dbSkip() )
	EndDo

	For nContSRD := 1 To Len(aRegSRD)
		nInc++
		oMeter:Set(nInc)
		oSayProc3:SetText( STR0076 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros integrados: "

		SRA->( dbSeek( aRegSRD[nContSRD, 1] + aRegSRD[nContSRD, 2] ) )

		If fVldFalta( @cCodRD0 )
			oJson := JsonObject():New()
			oJson['integrationId'] 					:= AllTrim( cEmpAnt+SRA->RA_FILIAL+SRA->RA_MAT+aRegSRD[nContSRD, 3] )
			oJson['personIntegrationId'] 			:= AllTrim( cCodRD0 )
			oJson['year'] 							:= Val( SubStr( aRegSRD[nContSRD, 3], 1, 4 ) )
			oJson['month'] 							:= Val( SubStr( aRegSRD[nContSRD, 3], 5, 2 ) )
			oJson['daysNotWorked'] 					:= Int( aRegSRD[nContSRD, 4] )
			fCriaLote( oJson )
		EndIf
	Next

	If !Empty(aJsons) .Or. !Empty(aJsonsLote)
		If fEnvGen(cToken, @aErrInt, @aRegInteg, "C")
			aAdd(aLogImp, STR0240)//"Registros integrados de faltas: "
			For nRegs := 1 To Len(aRegInteg)
				aAdd(aLogImp, aRegInteg[nRegs])
			Next nRegs
			nTotInteg += Len(aRegInteg)
		Else
			aAdd(aLogErr, STR0239)//"Erro na integração de faltas: "
			aAdd(aLogErr, STR0083)//"Houve falha ao tentar efetuar a integração. Solicite ao administrador uma revisão dos parâmetros MV_APIPEM1, MV_APIPEM2 e/ou MV_APIPEM3"
			aAdd(aLogErr, STR0080)//"Obs.: erro completo retornado:"
			For nErrInt := 1 To Len(aErrInt)
				FiltraLog( aLogErr, aErrInt[nErrInt])
			Next nErrInt	
		EndIf
	EndIf
EndIf

(cAliasQRY)->( dbCloseArea() )

RestArea( aAreaSRA )
RestArea( aAreaSRD )
RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fIntLider
Realiza a integração da tabela SRA de líder dos funcionários
@author  Allyson Luiz Mesashi
@since   04/07/2022
/*/
//-------------------------------------------------------------------
Static Function fIntLider(oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken)

Local aArea 		:= GetArea()
Local aAreaRDZ 		:= RDZ->( GetArea() )
Local aAreaSQB 		:= SQB->( GetArea() )
Local aAreaSRA 		:= SRA->( GetArea() )
Local aCpfsProc		:= {}
Local aErrInt		:= {}
Local aRegInteg		:= {}
Local cAliasQRY 	:= "IMPSRA"
Local cCodLider		:= ""
Local cCodRD0		:= ""
Local cFilIn		:= ""
Local cFilQry		:= ""
Local cQuery		:= ""
Local oJson			:= Nil
Local nCont			:= 0
Local nContFil		:= 0
Local nErrInt		:= 0
Local nInc			:= 0
Local nRegs			:= 0

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0073 + STR0119 )//"Iniciando Processamento..."##"Importação funcionários"
oSayProc2:SetText( STR0075 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Opções integradas: "
fRstLote()

RDZ->( dbSetOrder(1) )//RDZ_FILIAL+RDZ_EMPENT+RDZ_FILENT+RDZ_ENTIDA+RDZ_CODENT+RDZ_CODRD0
SQB->( dbSetOrder(1) )//QB_FILIAL+QB_DEPTO+QB_DESCRIC

For nContFil := 1 To Len(aArrayFil)
	cFilQry += aArrayFil[nContFil, 1]
Next nContFil
cFilIn := fSqlIn(cFilQry, FwGetTamFilial)

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + cTabSRA + " SRA "
cQuery 	+= "WHERE "
cQuery 	+= "SRA.RA_FILIAL IN (" + cFilIn + ") AND "
If !Empty(cFltLider)
	cQuery 	+= "( " + GPEParSQL(fPrepExpIn(cFltLider)) + " ) AND "
EndIf
cQuery 	+= "SRA.D_E_L_E_T_ = ' '"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

cQuery	:= "SELECT R_E_C_N_O_ AS SRARECNO "
cQuery 	+= "FROM " + cTabSRA + " SRA "
cQuery 	+= "WHERE "
cQuery 	+= "SRA.RA_FILIAL IN (" + cFilIn + ") AND "
If !Empty(cFltLider)
	cQuery 	+= "( " + GPEParSQL(fPrepExpIn(cFltLider)) + " ) AND "
EndIf
cQuery 	+= "SRA.D_E_L_E_T_ = ' ' "
cQuery 	+= "ORDER BY RA_CIC, RA_SITFOLH ASC, RA_ADMISSA DESC"
cQuery 	:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

If nCont == 0
	aAdd(aLogErr, STR0253)//"Erro na integração de líder dos funcionários: "
	aAdd(aLogErr, STR0189)//"Nenhum registro encontrado de acordo com o filtro realizado."
Else
	While (cAliasQRY)->( !EoF() )
		nInc++
		oMeter:Set(nInc)
		oSayProc3:SetText( STR0076 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros processados: "

		SRA->( dbGoTo( (cAliasQRY)->SRARECNO ) )
		SQB->( dbSeek( xFilial("SQB", SRA->RA_FILIAL)+ SRA->RA_DEPTO ) )

		If aScan( aCpfsProc, { |x| x == SRA->RA_CIC } ) > 0
			If aScan( aLogIncon, { |x| x == STR0254 } ) == 0//"Inconsistências na integração de líder dos funcionários:"
				aAdd(aLogIncon, STR0254)//"Inconsistências na integração de funcionários:"
			EndIf
			aAdd(aLogIncon, STR0123 + SRA->RA_FILIAL+SRA->RA_MAT + STR0166)//"Filial + Mat: "##" desprezado porque CPF já foi enviado anteriormente."
			(cAliasQRY)->( dbSkip() )
			Loop		
		EndIf

		If fVldLider( @cCodRD0, @cCodLider )
			aAdd( aCpfsProc, SRA->RA_CIC )
			If Empty(cCodLider)
				If aScan( aLogIncon, { |x| x == STR0254 } ) == 0//"Inconsistências na integração de líder dos funcionários:"
					aAdd(aLogIncon, STR0254)//"Inconsistências na integração de funcionários:"
				EndIf
				aAdd(aLogIncon, STR0123 + SRA->RA_FILIAL+SRA->RA_MAT + STR0257)//"Filial + Mat: "##" desprezado porque o funcionário não possui líder."
			Else
				oJson := JsonObject():New()	
				oJson['personIntegrationId'] 	:= cCodRD0
				oJson['managerIntegrationId'] 	:= cCodLider
				fCriaLote( oJson )
			EndIf
		EndIf	

		(cAliasQRY)->( dbSkip() )
	EndDo

	If !Empty(aJsons) .Or. !Empty(aJsonsLote)
		If fEnvGen(cToken, @aErrInt, @aRegInteg, "D")
			aAdd(aLogImp, STR0255)//"Registros integrados de líder dos funcionários: "
			For nRegs := 1 To Len(aRegInteg)
				aAdd(aLogImp, aRegInteg[nRegs])
			Next nRegs
			nTotInteg += Len(aRegInteg)
		Else
			aAdd(aLogErr, STR0253)//"Erro na integração de líder dos funcionários: "
			aAdd(aLogErr, STR0083)//"Houve falha ao tentar efetuar a integração. Solicite ao administrador uma revisão dos parâmetros MV_APIPEM1, MV_APIPEM2 e/ou MV_APIPEM3"
			aAdd(aLogErr, STR0080)//"Obs.: erro completo retornado:"
			For nErrInt := 1 To Len(aErrInt)
				FiltraLog( aLogErr, aErrInt[nErrInt])
			Next nErrInt	
		EndIf
	EndIf
EndIf

(cAliasQRY)->( dbCloseArea() )

RestArea( aAreaRDZ )
RestArea( aAreaSQB )
RestArea( aAreaSRA )
RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fRstLote
Reinicializa o controle do lote
@author  Allyson Luiz Mesashi
@since   18/04/2022
/*/
//-------------------------------------------------------------------
Static Function fRstLote()

aJsons       	:= {}
aJsonsLote     	:= {}

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fCriaLote()
Função que cria o lote para integração
@author  Allyson Luiz Mesashi
@since   18/04/2022
/*/
//-------------------------------------------------------------------
Static Function fCriaLote( oJson )

nContLote++
aAdd( aJsons, oJson )
If nContLote == nTamLote
	aAdd(aJsonsLote, aClone(aJsons))
	aSize(aJsons, 0)
	aJsons     	:= {}
	nContLote 	:= 0
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fEnvGen()
Função que efetua a integração genérica para o P&M
@author  Allyson Luiz Mesashi
@since   18/04/2022
/*/
//-------------------------------------------------------------------
Static Function fEnvGen( cToken, aErrInt, aRegInteg, cTipo )

Local aHeader	:= {}
Local cBody		:= ""
Local cPrcId	:= ""
Local cError 	:= ""
Local lRet 		:= .F.
Local nContJson	:= 0
Local nContLot	:= 0
Local oClient 	:= Nil

nContLote := 0

If Len(aJsons) > 0
	aAdd(aJsonsLote, aClone(aJsons))
	aSize(aJsons, 0)
	aJsons := {}
EndIf

oClient := FwRest():New(cPMURL)
If cTipo == "1"//"Filiais"
	oClient:SetPath("api/v1/auxiliary-records/facilities")
ElseIf cTipo == "2"//"Grupos de cargo"
	oClient:SetPath("api/v1/auxiliary-records/position-groups")
ElseIf cTipo == "3"//"Cargos"
	oClient:SetPath("api/v1/auxiliary-records/positions")
ElseIf cTipo == "4"//"Departamentos"
	oClient:SetPath("api/v1/auxiliary-records/departments")
ElseIf cTipo == "5"//"Funcionários"
	oClient:SetPath("api/v2/persons")
ElseIf cTipo == "6"//"Grupos de contrato"
	oClient:SetPath("api/v1/auxiliary-records/hiring-types")
ElseIf cTipo == "7"//"Movimentação de cargos"
	oClient:SetPath("api/v1/position-history")
ElseIf cTipo == "8"//"Movimentação de departamentos"
	oClient:SetPath("api/v1/department-history")
ElseIf cTipo == "9"//"Movimentação de filiais"
	oClient:SetPath("api/v1/facility-history")
ElseIf cTipo == "A"//"Movimentação de grupos de cargo"
	oClient:SetPath("api/v1/position-group-history")
ElseIf cTipo == "B"//"Afastamentos"
	oClient:SetPath("api/v1/absences")
ElseIf cTipo == "C"//"Faltas"
	oClient:SetPath("api/v1/days-not-worked")
ElseIf cTipo == "D"//"Líder dos funcionarios"
	oClient:SetPath("api/v1/persons/bind")
EndIf

aAdd( aHeader, "Authorization: Bearer " + cToken ) 
aAdd( aHeader, "content-type: application/json" ) 
aAdd( aHeader, "User-Agent: Protheus")

If !Empty(aJsonsLote)	
	For nContLot := 1 To Len(aJsonsLote)
		cBody	:= '['
		For nContJson := 1 To Len(aJsonsLote[nContLot])
			cBody	+= '{'
			If !(cTipo $ "D")//Líder dos funcionários
				cBody	+= 		'"integrationId": "' + aJsonsLote[nContLot, nContJson]['integrationId'] + '"'
			EndIf
			If !(cTipo $ "7/8/9/A/B/C/D")//Movimentação de cargos/Movimentação de departamentos/Movimentação de filiais/Movimentação de grupos de cargo/Afastamentos/Faltas/Líder dos funcionários
				cBody	+= 		',"name": "' + FwNoAccent( aJsonsLote[nContLot, nContJson]['name'] ) + '"'
			EndIf
			If cTipo == "3"//"Cargos"
				cBody += 	',"positionGroupIntegrationId": "' + aJsonsLote[nContLot, nContJson]['positionGroupIntegrationId'] + '"'
			EndIf
			If cTipo == "5"//"Funcionários"
				cBody += 	',"socialName": "' + aJsonsLote[nContLot, nContJson]['socialName'] + '"'
				cBody += 	',"email": "' + aJsonsLote[nContLot, nContJson]['email'] + '"'
				cBody += 	',"admissionDate": "' + aJsonsLote[nContLot, nContJson]['admissionDate'] + '"'
				cBody += 	',"lastRaiseDate": "' + aJsonsLote[nContLot, nContJson]['lastRaiseDate'] + '"'
				cBody += 	',"birthDate": "' + aJsonsLote[nContLot, nContJson]['birthDate'] + '"'
				cBody += 	',"demissionDate": "' + aJsonsLote[nContLot, nContJson]['demissionDate'] + '"'
				cBody += 	',"experienceEndDate": "' + aJsonsLote[nContLot, nContJson]['experienceEndDate'] + '"'
				cBody += 	',"dismissalType": "' + aJsonsLote[nContLot, nContJson]['dismissalType'] + '"'
				cBody += 	',"hiringTypeIntegrationId": "' + aJsonsLote[nContLot, nContJson]['hiringTypeIntegrationId'] + '"'
				cBody += 	',"departmentIntegrationId": "' + aJsonsLote[nContLot, nContJson]['departmentIntegrationId'] + '"'
				cBody += 	',"positionIntegrationId": "' + aJsonsLote[nContLot, nContJson]['positionIntegrationId'] + '"'
				cBody += 	',"facilityIntegrationId": "' + aJsonsLote[nContLot, nContJson]['facilityIntegrationId'] + '"'
			EndIf
			If cTipo $ "7/8/9/A/B/C"//"Movimentação de cargos"##"Movimentação de departamentos"##"Movimentação de filiais"##"Movimentação de grupos de cargo"##"Afastamentos
				cBody += 	',"personIntegrationId": "' + aJsonsLote[nContLot, nContJson]['personIntegrationId'] + '"'
				If !(cTipo $ "B/C")
					cBody += 	',"changeDate": "' + aJsonsLote[nContLot, nContJson]['changeDate'] + '"'
				EndIf
				If cTipo == "7"//"Movimentação de cargos"
					cBody += 	',"positionIntegrationId": "' + aJsonsLote[nContLot, nContJson]['positionIntegrationId'] + '"'
				EndIf
				If cTipo == "8"//"Movimentação de departamentos"
					cBody += 	',"departmentIntegrationId": "' + aJsonsLote[nContLot, nContJson]['departmentIntegrationId'] + '"'
				EndIf
				If cTipo == "9"//"Movimentação de filiais"
					cBody += 	',"facilityIntegrationId": "' + aJsonsLote[nContLot, nContJson]['facilityIntegrationId'] + '"'
				EndIf
				If cTipo == "A"//"Movimentação de grupos de cargo"
					cBody += 	',"positionGroupIntegrationId": "' + aJsonsLote[nContLot, nContJson]['positionGroupIntegrationId'] + '"'
				EndIf
				If cTipo == "B"//"Afastamentos"
					cBody += 	',"type": "' + aJsonsLote[nContLot, nContJson]['type'] + '"'
					cBody += 	',"startDate": "' + aJsonsLote[nContLot, nContJson]['startDate'] + '"'
					cBody += 	',"endDate": "' + aJsonsLote[nContLot, nContJson]['endDate'] + '"'
				EndIf
				If cTipo == "C"//"Faltas"
					cBody += 	',"year": ' + cValToChar( aJsonsLote[nContLot, nContJson]['year'] ) + ''
					cBody += 	',"month": ' + cValToChar( aJsonsLote[nContLot, nContJson]['month'] ) + ''
					cBody += 	',"daysNotWorked": ' + cValToChar( aJsonsLote[nContLot, nContJson]['daysNotWorked'] ) + ''
				EndIf
			EndIf
			If cTipo == "D"//Líder dos funcionários
				cBody += 	'"personIntegrationId": "' + aJsonsLote[nContLot, nContJson]['personIntegrationId'] + '"'
				cBody += 	',"managerIntegrationId": "' + aJsonsLote[nContLot, nContJson]['managerIntegrationId'] + '"'
			EndIf
			If nContJson < Len(aJsonsLote[nContLot])
				cBody += '},'
			Else
				cBody += '}'
			EndIf
			aAdd( aRegInteg, Iif( !(cTipo $ "D"), aJsonsLote[nContLot, nContJson]['integrationId'], aJsonsLote[nContLot, nContJson]['personIntegrationId']) + Iif( !(cTipo $ "7/8/9/A/B/C/D"), " - " + aJsonsLote[nContLot, nContJson]['name'], "" ) )
		Next nContJson
		cBody	+= ']'

		oClient:SetPostParams(cBody)	

		If oClient:Post(aHeader)
			lRet 	:= .T.
			cPrcId 	:= StrTran( oClient:GetResult(), '"' )
			fGravaREF( cPrcId, cTipo, cBody )
			If cOpcReto	== STR0086//"Aguardar o retorno do P&M"
				aAdd( aPrcId, { cPrcId, cTipo, "0", "", "" } )
			EndIf
		Else
			cError := oClient:GetResult() 
			If Empty(cError) 
				cError := oClient:getLastError()
			EndIf
			aAdd( aErrInt, cError )
		EndIf
	Next nContLot
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fGravaREF()
Função que efetua a gravação do lote na tabela REF
@author  Allyson Luiz Mesashi
@since   18/04/2022
/*/
//-------------------------------------------------------------------
Static Function fGravaREF( cPrcId, cTipo, cBody )

If REF->( RecLock("REF", .T.) )
	REF->REF_PRCID		:= cPrcId
	REF->REF_TIPO  		:= cTipo
	REF->REF_DATINT		:= Date()
	REF->REF_HORINT		:= Time()
	REF->REF_STATUS		:= "0"
	REF->REF_LOTE  		:= cBody
	REF->REF_USER  		:= RetCodUsr()
	REF->( MsUnLock() )
EndIf

Return

/*/{Protheus.doc} FiltraLog
//Função que quebra o texto para gravação no log
@author paulo.inzonha
@since 25/07/2019
@version 1.0
@return NIL
@param aLogCalc, array, Array que deve ser preenchido com a mensagem do log
@param cTexto, characters, Texto que deve ser apresentado no log
@type function
/*/
Static Function FiltraLog(aLogCalc, cTexto)
Local nPos := 0

If Len(Alltrim(cTexto)) >= 210
	nPos := At(" ",cTexto,200)
	If nPos > 0
		aAdd(aLogCalc, substr(cTexto,1,nPos))
		aAdd(aLogCalc, substr(cTexto,nPos))
	Else
		aAdd(aLogCalc, substr(cTexto,1,209))
		aAdd(aLogCalc, substr(cTexto,210))
	EndIf
Else
	aAdd(aLogCalc, cTexto)
EndIf

Return( NIL )

//-------------------------------------------------------------------
/*/{Protheus.doc} fStatPeM()
Função que efetua a consulta do status do processamento dos lotes no P&M
@author  Allyson Luiz Mesashi
@since   25/04/2022
/*/
//-------------------------------------------------------------------
Static Function fStatPeM( oSay, oMeter, oMeter2, oSayProc2, oSayProc3, cToken, lErro )

Local aHeader	:= {}
Local cPath		:= "api/v1/process/"
Local cStatJson	:= ""
Local cStatPrc	:= ""
Local cTimeIni	:= Time()
Local cTipoAPI	:= ""
Local lTenta	:= .T.
Local nMsgPeM	:= 0
Local nPrcId	:= 0
Local nTamLote	:= Len(aPrcId)
Local oClient 	:= FwRest():New(cPMUrl)
Local oJson		:= Nil

aAdd( aHeader, "Authorization: Bearer " + cToken )

oMeter:Free()
oSayProc3:setText("")
oSay:SetText( STR0108 )//"Iniciando consulta de status da integração"
oMeter2:SetTotal( nTamLote )

Begin Sequence

	For nPrcId := 1 To nTamLote
		If ( TimeToSecs( ElapTime( cTimeIni, Time() ) ) / 60 ) > nTmpLimit
			Break
		EndIf
		oSayProc2:SetText( STR0109 + cValToChar(nPrcId) + "/" + cValToChar(nTamLote) )//"Status retornados: "
		oMeter2:Set(nPrcId)

		lTenta := .T.
		oClient:SetPath( cPath+aPrcId[nPrcId, 1] )
		If oClient:Get(aHeader)
			oJson := JsonObject():New()
			oJson:fromJson( oClient:GetResult() )
			fJsPMSt( @oJson, @cStatJson )
			If cStatJson $ "2/3"
				aPrcId[nPrcId, 3] := cStatJson
				aPrcId[nPrcId, 4] := Iif( cStatJson == "3", oJson["errorMessages"], "" )
				aPrcId[nPrcId, 5] := oClient:GetResult()
			Else
				While lTenta .And. ( TimeToSecs( ElapTime( cTimeIni, Time() ) ) / 60 ) < nTmpLimit
					If oClient:Get(aHeader)
						oJson := JsonObject():New()
						oJson:fromJson( oClient:GetResult() )
						fJsPMSt( @oJson, @cStatJson )
						If cStatJson $ "2/3"
							aPrcId[nPrcId, 3] := cStatJson
							aPrcId[nPrcId, 4] := Iif( cStatJson == "3", oJson["errorMessages"], "" )
							aPrcId[nPrcId, 5] := oClient:GetResult()
							lTenta := .F.
						EndIf
					EndIf
				End
			EndIf
		EndIf
	Next nPrcId

End Sequence

For nPrcId := 1 To Len(aPrcId)
	If aPrcId[nPrcId, 2] == "1"
		cTipoAPI 	:= STR0015//"Filiais"
	ElseIf aPrcId[nPrcId, 2] == "2"
		cTipoAPI 	:= STR0014//"Grupo de cargos"
	ElseIf aPrcId[nPrcId, 2] == "3"
		cTipoAPI 	:= STR0017//"Cargos"
	ElseIf aPrcId[nPrcId, 2] == "4"
		cTipoAPI 	:= STR0016//"Departamentos"
	ElseIf aPrcId[nPrcId, 2] == "5"
		cTipoAPI 	:= STR0018//"Funcionários"
	ElseIf aPrcId[nPrcId, 2] == "6"
		cTipoAPI 	:= STR0192//"Grupos de contrato"
	ElseIf aPrcId[nPrcId, 2] == "7"
		cTipoAPI 	:= STR0200//"Movimentação de cargos"
	ElseIf aPrcId[nPrcId, 2] == "8"
		cTipoAPI 	:= STR0207//"Movimentação de departamentos"
	ElseIf aPrcId[nPrcId, 2] == "9"
		cTipoAPI 	:= STR0214//"Movimentação de filiais"
	ElseIf aPrcId[nPrcId, 2] == "A"
		cTipoAPI 	:= STR0221//"Movimentação de grupos de cargo"
	ElseIf aPrcId[nPrcId, 2] == "B"
		cTipoAPI 	:= STR0229//"Afastamentos"
	ElseIf aPrcId[nPrcId, 2] == "C"
		cTipoAPI 	:= STR0236//"Faltas"
	ElseIf aPrcId[nPrcId, 2] == "D"
		cTipoAPI 	:= STR0250//"Líder dos funcionários"
	EndIf
	cStatPrc	:= Iif( aPrcId[nPrcId, 3] == "0", STR0095, Iif( aPrcId[nPrcId, 3] == "1", STR0096, Iif( aPrcId[nPrcId, 3] == "2", STR0097, STR0098 ) ) )//"Status: "##" - "##"Não iniciado"##"Executando"##"Concluído"##"Houve erro de validação"
	aAdd(aLogPeM, STR0093 + aPrcId[nPrcId, 1] + " | " + STR0099 + aPrcId[nPrcId, 2] + " - " + cTipoAPI + " | " + STR0094 + aPrcId[nPrcId, 3] + " - " + cStatPrc)//"ID do Lote: "##"Tipo: "##"Status: "
	If aPrcId[nPrcId, 3] == "3"
		lErro := .T.
		aAdd(aLogPeM, STR0100)//"Obs.: mensagem de validação retornada pelo P&M:"
		For nMsgPeM := 1 To Len(aPrcId[nPrcId, 4])
			FiltraLog( aLogPeM, STR0105 + Iif(ValType(aPrcId[nPrcId, 4, nMsgPeM]["integrationId"]) != "U", aPrcId[nPrcId, 4, nMsgPeM]["integrationId"] , "null" ) + " | " + STR0106 + Iif( ValType(aPrcId[nPrcId, 4, nMsgPeM]["code"]) != "U", cValToChar( aPrcId[nPrcId, 4, nMsgPeM]["code"] ) , "null" ) + " | " + Iif( ValType(aPrcId[nPrcId, 4, nMsgPeM]["message"]) != "U", STR0107 + aPrcId[nPrcId, 4, nMsgPeM]["message"], "null" ) )//"ID de integração: "##"Código da validação: "##"Mensagem: "	
		Next nMsgPeM
	EndIf
Next nPrcId

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fStatREF()
Função que efetua a gravação do retorno do P&M no lote da tabela REF
@author  Allyson Luiz Mesashi
@since   26/04/2022
/*/
//-------------------------------------------------------------------
Static Function fStatREF()

Local aAreaREF	:= REF->( GetArea() )
Local nPrcId 	:= 0

REF->( dbSetOrder(2) )//REF_FILIAL+REF_PRCID

For nPrcId := 1 To Len(aPrcId)
	If aPrcId[nPrcId, 3] != "0" .And. REF->( dbSeek( xFilial("REF") + aPrcId[nPrcId, 1] ) ) .And. REF->( RecLock("REF", .F.) )
		REF->REF_STATUS 	:= aPrcId[nPrcId, 3]
		REF->REF_RETORN 	:= aPrcId[nPrcId, 5]
		REF->( MsUnlock() )
	EndIf
Next nPrcId

RestArea( aAreaREF )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fCodRD0()
Função que efetua a busca do código do participante a partir da SRA
@author  Allyson Luiz Mesashi
@since   03/05/2022
/*/
//-------------------------------------------------------------------
Static Function fCodRD0( cEmp, cFilMat )

Local cCodRD0 := ""

If RDZ->( dbSeek( xFilial("RDZ", SRA->RA_FILIAL)+cEmp+SRA->RA_FILIAL+"SRA"+cFilMat ) )
	cCodRD0 := cEmpAnt+RDZ->RDZ_CODRD0
EndIf

Return cCodRD0

//-------------------------------------------------------------------
/*/{Protheus.doc} fUltSR3()
Função que efetua a busca da data do último aumento
@author  Allyson Luiz Mesashi
@since   03/05/2022
/*/
//-------------------------------------------------------------------
Static Function fUltSR3( cFilMat )

Local cUltSR3 := ""

SR3->( dbSetOrder(2) )//R3_FILIAL+R3_MAT+DTOS(R3_DATA)+R3_SEQ+R3_TIPO+R3_PD
If SR3->( dbSeek( cFilMat ) )
	While SR3->( !EoF() ) .And. SR3->R3_FILIAL+SR3->R3_MAT == cFilMat
		cUltSR3 := FWTimeStamp(6, SR3->R3_DATA, "00:00:00")
		SR3->( dbSkip() )
	End
EndIf

Return cUltSR3

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldSM0()
Função que verifica se a filial é válida para integração
@author  Allyson Luiz Mesashi
@since   12/05/2022
/*/
//-------------------------------------------------------------------
Static Function fVldSM0( cCodFil )

Local cAliasQRY 	:= GetNextAlias()
Local cQuery		:= ""
Local lRet			:= .F.

If __oStSM0 == Nil
	__oStSM0 := FWPreparedStatement():New()
	cQuery 	+= "SELECT COUNT(*) AS CONT FROM " + cTabSRA + " SRA "
	cQuery 	+= "INNER JOIN " + cTabSQ3 + " SQ3 "
	cQuery 	+= "ON " + FWJoinFilial( "SQ3", "SRA" ) + " AND SQ3.Q3_CARGO = SRA.RA_CARGO AND SQ3.Q3_GRUPO != '  ' AND SQ3.D_E_L_E_T_ = ' ' "
	If lSQ3Msbql
		cQuery 	+= "AND SQ3.Q3_MSBLQL IN (' ', '2') "
	EndIf
	cQuery 	+= "WHERE SRA.RA_FILIAL = ? AND ( SRA.RA_SITFOLH <> 'D' OR (SRA.RA_SITFOLH = 'D' AND SRA.RA_DEMISSA >= '" + dToS(dDatCorte) + "' ) ) AND SRA.D_E_L_E_T_ = ' '"
	cQuery 	:= ChangeQuery(cQuery)
	__oStSM0:SetQuery(cQuery)
EndIf

__oStSM0:SetString(1, cCodFil)

cQuery := __oStSM0:getFixQuery()

dbUseArea(.T., "TOPCONN", TcGenQry( Nil, Nil, cQuery), cAliasQRY, .T., .T.)

lRet := (cAliasQRY)->CONT > 0

If !lRet
	If aScan( aLogIncon, { |x| x == STR0156 } ) == 0//"Inconsistências na integração de filiais:"
		aAdd(aLogIncon, STR0156)//"Inconsistências na integração de filiais:"
	EndIf
	aAdd(aLogIncon, STR0154 + cCodFil + STR0155)//"Filial: "##" sem funcionários ativos/válidos."
EndIf

(cAliasQRY)->( dbCloseArea() )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldSQ0()
Função que verifica se o grupo é válido para integração
@author  Allyson Luiz Mesashi
@since   12/05/2022
/*/
//-------------------------------------------------------------------
Static Function fVldSQ0( lVldDePara, cCodPeM, cDescPeM )

Local cAliasQRY 	:= GetNextAlias()
Local cQuery		:= ""
Local lOk			:= .T.
Local lRet			:= .F.

If lSQ0Msbql .And. SQ0->Q0_MSBLQL == "1"
	If aScan( aLogIncon, { |x| x == STR0157 } ) == 0//"Inconsistências na integração de grupos:"
		aAdd(aLogIncon, STR0157)//"Inconsistências na integração de grupos:"
	EndIf
	aAdd(aLogIncon, STR0158 + SQ0->Q0_FILIAL+SQ0->Q0_GRUPO + STR0159)//"Filial + grupo: "##" bloqueado para uso através do campo MSBLQL."
	lOk := .F.
EndIf

If lVldDePara .And. lTemREN
	If RET->( dbSeek( xFilial("RET")+"1"+SQ0->Q0_FILIAL+SQ0->Q0_GRUPO ) ) .And. REN->( dbSeek( xFilial("REN")+"1"+RET->RET_CODIGO ) )	
		cCodPeM		:= cEmpAnt+REN->REN_FILIAL+REN->REN_CODIGO
		cDescPeM	:= REN->REN_DESC
	Else
		If aScan( aLogIncon, { |x| x == STR0157 } ) == 0//"Inconsistências na integração de grupos:"
			aAdd(aLogIncon, STR0157)//"Inconsistências na integração de grupos:"
		EndIf
		aAdd(aLogIncon, STR0158 + SQ0->Q0_FILIAL+SQ0->Q0_GRUPO + STR0196)//"Filial + grupo: "##" não encontrado no cadastro de De x Para."
		lOk := .F.
	EndIf
EndIf

If lOk
	If !lVldSRA
		lRet := .T.
	Else
		If __oStSQ0 == Nil
			__oStSQ0 := FWPreparedStatement():New()
			cQuery 	+= "SELECT COUNT(*) AS CONT FROM " + cTabSRA + " SRA "
			cQuery 	+= "INNER JOIN " + cTabSQ3 + " SQ3 "
			cQuery 	+= "ON " + FWJoinFilial( "SQ3", "SRA" ) + " AND SQ3.Q3_CARGO = SRA.RA_CARGO AND SQ3.Q3_GRUPO = ? AND SQ3.D_E_L_E_T_ = ' ' "
			If lSQ3Msbql
				cQuery 	+= "AND SQ3.Q3_MSBLQL IN (' ', '2') "
			EndIf
			cQuery 	+= "INNER JOIN " + cTabSQ0 + " SQ0 ON " + FWJoinFilial( "SQ0", "SQ3" ) + " AND SQ0.Q0_GRUPO = SQ3.Q3_GRUPO AND SQ0.Q0_FILIAL = ? AND SQ0.D_E_L_E_T_ = ' ' "
			cQuery 	+= "WHERE SRA.RA_SITFOLH <> 'D' OR (SRA.RA_SITFOLH = 'D' AND SRA.RA_DEMISSA >= '" + dToS(dDatCorte) + "' ) AND SRA.D_E_L_E_T_ = ' '"
			cQuery 	:= ChangeQuery(cQuery)
			__oStSQ0:SetQuery(cQuery)
		EndIf

		__oStSQ0:SetString(1, SQ0->Q0_GRUPO)
		__oStSQ0:SetString(2, SQ0->Q0_FILIAL)
		
		cQuery := __oStSQ0:getFixQuery()

		dbUseArea(.T., "TOPCONN", TcGenQry( Nil, Nil, cQuery), cAliasQRY, .T., .T.)

		lRet := (cAliasQRY)->CONT > 0

		If !lRet
			If aScan( aLogIncon, { |x| x == STR0157 } ) == 0//"Inconsistências na integração de grupos:"
				aAdd(aLogIncon, STR0157)//"Inconsistências na integração de grupos:"
			EndIf
			aAdd(aLogIncon, STR0158 + SQ0->Q0_FILIAL+SQ0->Q0_GRUPO + STR0155)//"Filial + grupo: "##" sem funcionários ativos/válidos."
		EndIf

		(cAliasQRY)->( dbCloseArea() )
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldSQ3()
Função que verifica se o cargo é válido para integração
@author  Allyson Luiz Mesashi
@since   12/05/2022
/*/
//-------------------------------------------------------------------
Static Function fVldSQ3( lVldDePara, cCodPeM, cDescPeM, cCodPeMGrp )

Local cAliasQRY 	:= GetNextAlias()
Local cQuery		:= ""
Local lOk			:= .T.
Local lRet			:= .F.

If lSQ3Msbql .And. SQ3->Q3_MSBLQL == "1"
	If aScan( aLogIncon, { |x| x == STR0160 } ) == 0//"Inconsistências na integração de cargos:"
		aAdd(aLogIncon, STR0160)//"Inconsistências na integração de cargos:"
	EndIf
	aAdd(aLogIncon, STR0161 + SQ3->Q3_FILIAL+SQ3->Q3_CARGO + STR0159)//"Filial + cargo: "##" bloqueado para uso através do campo MSBLQL."
	lOk := .F.
EndIf

If lVldDePara .And. lTemREN
	If RET->( dbSeek( xFilial("RET")+"2"+SQ3->Q3_FILIAL+SQ3->Q3_CARGO ) ) .And. REN->( dbSeek( xFilial("REN")+"2"+RET->RET_CODIGO ) )	
		cCodPeM		:= cEmpAnt+REN->REN_FILIAL+REN->REN_CODIGO
		cDescPeM	:= REN->REN_DESC
	Else
		If aScan( aLogIncon, { |x| x == STR0160 } ) == 0//"Inconsistências na integração de cargos:"
			aAdd(aLogIncon, STR0160)//"Inconsistências na integração de cargos:"
		EndIf
		aAdd(aLogIncon, STR0161 + SQ3->Q3_FILIAL+SQ3->Q3_CARGO + STR0196)//"Filial + cargo: "##" não encontrado no cadastro de De x Para."
		lOk := .F.
	EndIf
EndIf

If Empty(SQ3->Q3_GRUPO)
	If aScan( aLogIncon, { |x| x == STR0160 } ) == 0//"Inconsistências na integração de cargos:"
		aAdd(aLogIncon, STR0160)//"Inconsistências na integração de cargos:"
	EndIf
	aAdd(aLogIncon, STR0161 + SQ3->Q3_FILIAL+SQ3->Q3_CARGO + STR0162)//"Filial + cargo: "##" sem grupo preenchido."
	lOk := .F.
Else
	If SQ0->( dbSeek( xFilial("SQ0")+SQ3->Q3_GRUPO ) )
		If lSQ0Msbql .And. SQ0->Q0_MSBLQL == "1"
			If aScan( aLogIncon, { |x| x == STR0160 } ) == 0//"Inconsistências na integração de cargos:"
				aAdd(aLogIncon, STR0160)//"Inconsistências na integração de cargos:"
			EndIf
			aAdd(aLogIncon, STR0161 + SQ3->Q3_FILIAL+SQ3->Q3_CARGO + STR0163)//"Filial + cargo: "##" vinculado a um grupo bloqueado para uso através do campo MSBLQL."
			lOk := .F.
		EndIf
		If !Empty( xFilial("SQ0") ) .And. lTemREN
			If RET->( dbSeek( xFilial("RET")+"1"+xFilial("SQ0", SQ3->Q3_FILIAL)+SQ3->Q3_GRUPO ) ) .And. REN->( dbSeek( xFilial("REN")+"1"+RET->RET_CODIGO ) )	
				cCodPeMGrp	:= cEmpAnt+REN->REN_FILIAL+REN->REN_CODIGO
			Else
				If aScan( aLogIncon, { |x| x == STR0160 } ) == 0//"Inconsistências na integração de cargos:"
					aAdd(aLogIncon, STR0160)//"Inconsistências na integração de cargos:"
				EndIf
				aAdd(aLogIncon, STR0161 + SQ3->Q3_FILIAL+SQ3->Q3_CARGO + STR0197)//"Filial + cargo: "##" vinculado a um grupo não encontrado no cadastro de De x Para."
				lOk := .F.
			EndIf
		EndIf
	Else
		If aScan( aLogIncon, { |x| x == STR0160 } ) == 0//"Inconsistências na integração de cargos:"
			aAdd(aLogIncon, STR0160)//"Inconsistências na integração de cargos:"
		EndIf
		aAdd(aLogIncon, STR0161 + SQ3->Q3_FILIAL+SQ3->Q3_CARGO + STR0171)//"Filial + cargo: "##" vinculado a um grupo não existente."
		lOk := .F.	
	EndIf
EndIf

If lOk
	If !lVldSRA
		lRet := .T.
	Else
		If __oStSQ3 == Nil
			__oStSQ3 := FWPreparedStatement():New()
			cQuery 	+= "SELECT COUNT(*) AS CONT FROM " + cTabSRA + " SRA "
			cQuery 	+= "INNER JOIN " + cTabSQ3 + " SQ3 "
			cQuery 	+= "ON " + FWJoinFilial( "SQ3", "SRA" ) + " AND SQ3.Q3_CARGO = SRA.RA_CARGO AND SQ3.Q3_FILIAL = ? AND SQ3.Q3_CARGO = ? AND SQ3.D_E_L_E_T_ = ' ' "
			cQuery 	+= "WHERE SRA.RA_SITFOLH <> 'D' OR (SRA.RA_SITFOLH = 'D' AND SRA.RA_DEMISSA >= '" + dToS(dDatCorte) + "' ) AND SRA.D_E_L_E_T_ = ' '"
			cQuery 	:= ChangeQuery(cQuery)
			__oStSQ3:SetQuery(cQuery)
		EndIf

		__oStSQ3:SetString(1, SQ3->Q3_FILIAL)
		__oStSQ3:SetString(2, SQ3->Q3_CARGO)
		
		cQuery := __oStSQ3:getFixQuery()

		dbUseArea(.T., "TOPCONN", TcGenQry( Nil, Nil, cQuery), cAliasQRY, .T., .T.)

		lRet := (cAliasQRY)->CONT > 0

		If !lRet
			If aScan( aLogIncon, { |x| x == STR0160 } ) == 0//"Inconsistências na integração de cargos:"
				aAdd(aLogIncon, STR0160)//"Inconsistências na integração de cargos:"
			EndIf
			aAdd(aLogIncon, STR0161 + SQ3->Q3_FILIAL+SQ3->Q3_CARGO + STR0155)//"Filial + cargo: "##" sem funcionários ativos/válidos."
		EndIf

		(cAliasQRY)->( dbCloseArea() )
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldSQB()
Função que verifica se o departamento é válido para integração
@author  Allyson Luiz Mesashi
@since   12/05/2022
/*/
//-------------------------------------------------------------------
Static Function fVldSQB( lVldDePara, cCodPeM, cDescPeM )

Local cAliasQRY 	:= GetNextAlias()
Local cQuery		:= ""
Local lOk			:= .T.
Local lRet			:= .F.

If lSQBMsbql .And. SQB->QB_MSBLQL == "1"
	If aScan( aLogIncon, { |x| x == STR0164 } ) == 0//"Inconsistências na integração de departamentos:"
		aAdd(aLogIncon, STR0164)//"Inconsistências na integração de departamentos:"
	EndIf
	aAdd(aLogIncon, STR0165 + SQB->QB_FILIAL+SQB->QB_DEPTO + STR0159)//"Filial + departamento: "##" bloqueado para uso através do campo MSBLQL."
	lOk := .F.
EndIf

If lVldDePara .And. lTemREN
	If RET->( dbSeek( xFilial("RET")+"3"+SQB->QB_FILIAL+SQB->QB_DEPTO ) ) .And. REN->( dbSeek( xFilial("REN")+"3"+RET->RET_CODIGO ) )	
		cCodPeM		:= cEmpAnt+REN->REN_FILIAL+REN->REN_CODIGO
		cDescPeM	:= REN->REN_DESC
	Else
		If aScan( aLogIncon, { |x| x == STR0164 } ) == 0//"Inconsistências na integração de departamentos:"
			aAdd(aLogIncon, STR0164)//"Inconsistências na integração de departamentos:"
		EndIf
		aAdd(aLogIncon, STR0165 + SQB->QB_FILIAL+SQB->QB_DEPTO + STR0196)//"Filial + departamento: "##" bloqueado para uso através do campo MSBLQL."
		lOk := .F.
	EndIf
EndIf

If lOk
	If !lVldSRA
		lRet := .T.
	Else
		If __oStSQB == Nil
			__oStSQB := FWPreparedStatement():New()
			cQuery 	+= "SELECT COUNT(*) AS CONT FROM " + cTabSRA + " SRA "
			cQuery 	+= "INNER JOIN " + cTabSQB + " SQB "
			cQuery 	+= "ON " + FWJoinFilial( "SQB", "SRA" ) + " AND SQB.QB_DEPTO = SRA.RA_DEPTO AND SQB.QB_FILIAL = ? AND SQB.QB_DEPTO = ? AND SQB.D_E_L_E_T_ = ' ' "
			cQuery 	+= "WHERE SRA.RA_SITFOLH <> 'D' OR (SRA.RA_SITFOLH = 'D' AND SRA.RA_DEMISSA >= '" + dToS(dDatCorte) + "' ) AND SRA.D_E_L_E_T_ = ' '"
			cQuery 	:= ChangeQuery(cQuery)
			__oStSQB:SetQuery(cQuery)
		EndIf

		__oStSQB:SetString(1, SQB->QB_FILIAL)
		__oStSQB:SetString(2, SQB->QB_DEPTO)
		
		cQuery := __oStSQB:getFixQuery()

		dbUseArea(.T., "TOPCONN", TcGenQry( Nil, Nil, cQuery), cAliasQRY, .T., .T.)

		lRet := (cAliasQRY)->CONT > 0

		If !lRet
			If aScan( aLogIncon, { |x| x == STR0164 } ) == 0//"Inconsistências na integração de departamentos:"
				aAdd(aLogIncon, STR0164)//"Inconsistências na integração de departamentos:"
			EndIf
			aAdd(aLogIncon, STR0165 + SQB->QB_FILIAL+SQB->QB_DEPTO + STR0155)//"Filial + departamento: "##" sem funcionários ativos/válidos."
		EndIf

		(cAliasQRY)->( dbCloseArea() )
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldSRA()
Função que verifica se o funcionário é válido para integração
@author  Allyson Luiz Mesashi
@since   12/05/2022
/*/
//-------------------------------------------------------------------
Static Function fVldSRA( cCodCargo, cCodDepto, cCodRD0, cTipContr, cTipDesl )

Local lRet		:= .T.
Local lVldSQ0	:= !Empty( xFilial("SQ0") )
Local lVldSQB	:= !Empty( xFilial("SQ0") )

If Empty(SRA->RA_CIC)
	If aScan( aLogIncon, { |x| x == STR0167 } ) == 0//"Inconsistências na integração de funcionários:"
		aAdd(aLogIncon, STR0167)//"Inconsistências na integração de funcionários:"
	EndIf
	aAdd(aLogIncon, STR0123 + SRA->RA_FILIAL+SRA->RA_MAT + STR0178)//"Filial + Mat: "##" sem CPF cadastrado."
	lRet := .F.
EndIf

If Empty(SRA->RA_EMAIL)
	If aScan( aLogIncon, { |x| x == STR0167 } ) == 0//"Inconsistências na integração de funcionários:"
		aAdd(aLogIncon, STR0167)//"Inconsistências na integração de funcionários:"
	EndIf
	aAdd(aLogIncon, STR0123 + SRA->RA_FILIAL+SRA->RA_MAT + STR0179)//"Filial + Mat: "##" sem e-mail cadastrado."
	lRet := .F.
EndIf

If Empty(SRA->RA_DEPTO)
	If aScan( aLogIncon, { |x| x == STR0167 } ) == 0//"Inconsistências na integração de funcionários:"
		aAdd(aLogIncon, STR0167)//"Inconsistências na integração de funcionários:"
	EndIf
	aAdd(aLogIncon, STR0123 + SRA->RA_FILIAL+SRA->RA_MAT + STR0168)//"Filial + Mat: "##" sem departamento cadastrado."
	lRet := .F.
Else
	If SQB->( dbSeek( xFilial("SQB")+SRA->RA_DEPTO ) )
		If lSQBMsbql .And. SQB->QB_MSBLQL == "1"
			If aScan( aLogIncon, { |x| x == STR0167 } ) == 0//"Inconsistências na integração de funcionários:"
				aAdd(aLogIncon, STR0167)//"Inconsistências na integração de funcionários:"
			EndIf
			aAdd(aLogIncon, STR0123 + SRA->RA_FILIAL+SRA->RA_MAT + STR0169)//"Filial + Mat: "##" vinculado a um departamento bloqueado para uso através do campo MSBLQL."
			lRet := .F.
		EndIf
		If lVldSQB .And. lTemREN
			If RET->( dbSeek( xFilial("RET")+"3"+xFilial("SQB", SRA->RA_FILIAL)+SQB->QB_DEPTO ) ) .And. REN->( dbSeek( xFilial("REN")+"3"+RET->RET_CODIGO ) )	
				cCodDepto	:= cEmpAnt+REN->REN_FILIAL+REN->REN_CODIGO
			Else
				If aScan( aLogIncon, { |x| x == STR0167 } ) == 0//"Inconsistências na integração de funcionários:"
					aAdd(aLogIncon, STR0167)//"Inconsistências na integração de funcionários:"
				EndIf
				aAdd(aLogIncon, STR0123 + SRA->RA_FILIAL+SRA->RA_MAT + STR0198)//"Filial + Mat: "##" vinculado a um departamento não encontrado no cadastro de De x Para."
				lRet := .F.
			EndIf
		EndIf
	Else
		If aScan( aLogIncon, { |x| x == STR0167 } ) == 0//"Inconsistências na integração de funcionários:"
			aAdd(aLogIncon, STR0167)//"Inconsistências na integração de funcionários:"
		EndIf
		aAdd(aLogIncon, STR0123 + SRA->RA_FILIAL+SRA->RA_MAT + STR0170)//"Filial + Mat: "##" vinculado a um departamento não existente."
		lRet := .F.
	EndIf
EndIf

If Empty(SRA->RA_CARGO)
	If aScan( aLogIncon, { |x| x == STR0167 } ) == 0//"Inconsistências na integração de funcionários:"
		aAdd(aLogIncon, STR0167)//"Inconsistências na integração de funcionários:"
	EndIf
	aAdd(aLogIncon, STR0123 + SRA->RA_FILIAL+SRA->RA_MAT + STR0172)//"Filial + Mat: "##" sem cargo cadastrado."
	lRet := .F.
Else
	If SQ3->( dbSeek( xFilial("SQ3")+SRA->RA_CARGO ) )
		If lSQ3Msbql .And. SQ3->Q3_MSBLQL == "1"
			If aScan( aLogIncon, { |x| x == STR0167 } ) == 0//"Inconsistências na integração de funcionários:"
				aAdd(aLogIncon, STR0167)//"Inconsistências na integração de funcionários:"
			EndIf
			aAdd(aLogIncon, STR0123 + SRA->RA_FILIAL+SRA->RA_MAT + STR0173)//"Filial + Mat: "##" vinculado a um cargo bloqueado para uso através do campo MSBLQL."
			lRet := .F.
		EndIf
		If Empty(SQ3->Q3_GRUPO)
			If aScan( aLogIncon, { |x| x == STR0167 } ) == 0//"Inconsistências na integração de funcionários:"
				aAdd(aLogIncon, STR0167)//"Inconsistências na integração de funcionários:"
			EndIf
			aAdd(aLogIncon, STR0123 + SRA->RA_FILIAL+SRA->RA_MAT + STR0175)//"Filial + Mat: "##" vinculado a um cargo sem grupo preenchido."
			lRet := .F.
		Else
			If SQ0->( dbSeek( xFilial("SQ0", SQ3->Q3_FILIAL)+SQ3->Q3_GRUPO ) )
				If lSQ0Msbql .And. SQ0->Q0_MSBLQL == "1"
					If aScan( aLogIncon, { |x| x == STR0167 } ) == 0//"Inconsistências na integração de funcionários:"
						aAdd(aLogIncon, STR0167)//"Inconsistências na integração de funcionários:"
					EndIf
					aAdd(aLogIncon, STR0123 + SRA->RA_FILIAL+SRA->RA_MAT + STR0176)//"Filial + Mat: "##" vinculado a um cargo vinculado ao um grupo bloqueado para uso através do campo MSBLQL."
					lRet := .F.
				EndIf
			Else
				If aScan( aLogIncon, { |x| x == STR0167 } ) == 0//"Inconsistências na integração de funcionários:"
					aAdd(aLogIncon, STR0167)//"Inconsistências na integração de funcionários:"
				EndIf
				aAdd(aLogIncon, STR0123 + SRA->RA_FILIAL+SRA->RA_MAT + STR0177)//"Filial + Mat: "##" vinculado a um cargo vinculado ao um grupo não existente."
				lRet := .F.
			EndIf
		EndIf
		If lVldSQ0 .And. lTemREN
			If RET->( dbSeek( xFilial("RET")+"2"+xFilial("SQ3", SRA->RA_FILIAL)+SQ3->Q3_CARGO ) ) .And. REN->( dbSeek( xFilial("REN")+"2"+RET->RET_CODIGO ) )	
				cCodCargo	:= cEmpAnt+REN->REN_FILIAL+REN->REN_CODIGO
			Else
				If aScan( aLogIncon, { |x| x == STR0167 } ) == 0//"Inconsistências na integração de funcionários:"
					aAdd(aLogIncon, STR0167)//"Inconsistências na integração de funcionários:"
				EndIf
				aAdd(aLogIncon, STR0123 + SRA->RA_FILIAL+SRA->RA_MAT + STR0199)//"Filial + Mat: "##" vinculado a um cargo não encontrado no cadastro de De x Para."
				lRet := .F.
			EndIf
		EndIf
	Else
		If aScan( aLogIncon, { |x| x == STR0167 } ) == 0//"Inconsistências na integração de funcionários:"
			aAdd(aLogIncon, STR0167)//"Inconsistências na integração de funcionários:"
		EndIf
		aAdd(aLogIncon, STR0123 + SRA->RA_FILIAL+SRA->RA_MAT + STR0174)//"Filial + Mat: "##" vinculado a um cargo não existente."
		lRet := .F.
	EndIf
EndIf

cCodRD0 := fCodRD0( cEmpAnt, SRA->RA_FILIAL+SRA->RA_MAT )
If Empty(cCodRD0)
	If aScan( aLogIncon, { |x| x == STR0167 } ) == 0//"Inconsistências na integração de funcionários:"
		aAdd(aLogIncon, STR0167)//"Inconsistências na integração de funcionários:"
	EndIf
	aAdd(aLogIncon, STR0123 + SRA->RA_FILIAL+SRA->RA_MAT + STR0180)//"Filial + Mat: "##" sem participante relacionado."
	lRet := .F.
EndIf

If !lVldSRA .And. SRA->RA_SITFOLH == "D"
	If aScan( aLogIncon, { |x| x == STR0167 } ) == 0//"Inconsistências na integração de funcionários:"
		aAdd(aLogIncon, STR0167)//"Inconsistências na integração de funcionários:"
	EndIf
	aAdd(aLogIncon, STR0123 + SRA->RA_FILIAL+SRA->RA_MAT + STR0181)//"Filial + Mat: "##" desprezado pois situação de folha está como Demitido."
	lRet := .F.
ElseIf lVldSRA .And. !(SRA->RA_SITFOLH != "D" .Or. (SRA->RA_SITFOLH == 'D' .And. dToS(SRA->RA_DEMISSA) >= dToS(dDatCorte) ) )
	If aScan( aLogIncon, { |x| x == STR0167 } ) == 0//"Inconsistências na integração de funcionários:"
		aAdd(aLogIncon, STR0167)//"Inconsistências na integração de funcionários:"
	EndIf
	aAdd(aLogIncon, STR0123 + SRA->RA_FILIAL+SRA->RA_MAT + STR0182)//"Filial + Mat: "##" desprezado pois situação de folha está como Demitido ou a data de demissão é menor que a data de corte."
	lRet := .F.
EndIf

cTipContr := fCodContr()
If Empty(cTipContr)
	If aScan( aLogIncon, { |x| x == STR0167 } ) == 0//"Inconsistências na integração de funcionários:"
		aAdd(aLogIncon, STR0167)//"Inconsistências na integração de funcionários:"
	EndIf
	aAdd(aLogIncon, STR0123 + SRA->RA_FILIAL+SRA->RA_MAT + STR0190)//"Filial + Mat: "##' desprezado pois não foi preenchido o agrupador de contrato no campo "Agrupador P&M" da tabela S049.'
	lRet := .F.
EndIf

If SRA->RA_SITFOLH == "D"
	cTipDesl := fCodDesl()
	If Empty(cTipDesl)
		If aScan( aLogIncon, { |x| x == STR0167 } ) == 0//"Inconsistências na integração de funcionários:"
			aAdd(aLogIncon, STR0167)//"Inconsistências na integração de funcionários:"
		EndIf
		aAdd(aLogIncon, STR0123 + SRA->RA_FILIAL+SRA->RA_MAT + STR0191)//"Filial + Mat: "##' desprezado pois não foi preenchido o tipo de desligamento no campo "Tipo P&M" de contrato na tabela S043.'
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fCodContr()
Função que efetua a busca do agrupador de contrato na tabela S049 a partir da SRA
@author  Allyson Luiz Mesashi
@since   01/06/2022
/*/
//-------------------------------------------------------------------
Static Function fCodContr()

Local cCodContr	:= ""
Local nPos		:= 0

If ( nPos := fPosTab("S049", SRA->RA_CATEFD, "==", 04, Nil, Nil, Nil, Nil, Nil, Nil, Nil, SRA->RA_FILIAL) ) > 0 .And. !Empty(fTabela("S049", nPos, 7))
	cCodContr := cEmpAnt+xFilial("SX5", SRA->RA_FILIAL)+fTabela("S049", nPos, 7)
EndIf

Return cCodContr

//-------------------------------------------------------------------
/*/{Protheus.doc} fCodDesl()
Função que efetua a busca do tipo de desligamento na tabela S043 a partir da SRG
@author  Allyson Luiz Mesashi
@since   01/06/2022
/*/
//-------------------------------------------------------------------
Static Function fCodDesl()

Local cCodDesl	:= ""
Local nPos		:= 0

If SRG->( dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + dToS(SRA->RA_DEMISSA) ) )
	While SRG->( !EoF() ) .And. SRG->RG_FILIAL+SRG->RG_MAT+dToS(SRG->RG_DATADEM) == SRA->RA_FILIAL + SRA->RA_MAT + dToS(SRA->RA_DEMISSA)
		If SRG->RG_EFETIVA == "S"
			If ( nPos := fPosTab("S043", SRG->RG_TIPORES, "==", 04, Nil, Nil, Nil, Nil, Nil, Nil, Nil, SRA->RA_FILIAL) ) > 0 .And. !Empty(fTabela("S043", nPos, 31))
				cCodDesl := fTabela("S043", nPos, 31)
			EndIf
			Exit
		EndIf
		SRG->( dbSkip() )
	EndDo
EndIf

Return cCodDesl

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldHCarg()
Função que verifica se a movimentação de cargos é válida para integração
@author  Allyson Luiz Mesashi
@since   02/06/2022
/*/
//-------------------------------------------------------------------
Static Function fVldHCarg( lVldDePara, cCodRD0, cCodCargo )

Local lRet	:= .T.

cCodRD0 := fCodRD0( cEmpAnt, SR7->R7_FILIAL+SR7->R7_MAT )
If Empty(cCodRD0)
	If aScan( aLogIncon, { |x| x == STR0206 } ) == 0//"Inconsistências na integração de movimentação de cargos:"
		aAdd(aLogIncon, STR0206)//"Inconsistências na integração de movimentação de cargos:"
	EndIf
	aAdd(aLogIncon, STR0123 + SR7->R7_FILIAL+SR7->R7_MAT + STR0180)//"Filial + Mat: "##" sem participante relacionado."
	lRet := .F.
EndIf

If lVldDePara .And. lTemREN
	If RET->( dbSeek( xFilial("RET")+"2"+xFilial("SQ3", SR7->R7_FILIAL)+SR7->R7_CARGO ) ) .And. REN->( dbSeek( xFilial("REN")+"2"+RET->RET_CODIGO ) )	
		cCodCargo	:= cEmpAnt+REN->REN_FILIAL+REN->REN_CODIGO
	Else
		If aScan( aLogIncon, { |x| x == STR0206 } ) == 0//"Inconsistências na integração de movimentação de cargos:"
			aAdd(aLogIncon, STR0206)//"Inconsistências na integração de movimentação de cargos:"
		EndIf
		aAdd(aLogIncon, STR0123 + SR7->R7_FILIAL+SR7->R7_MAT + STR0199)//"Filial + Mat: "##" vinculado a um cargo não encontrado no cadastro de De x Para."
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldHDep
Função que verifica se a movimentação de departamentos é válida para integração
@author  Allyson Luiz Mesashi
@since   06/06/2022
/*/
//-------------------------------------------------------------------
Static Function fVldHDep( lVldDePara, cCodRD0, cCodCDepto )

Local lRet	:= .T.

cCodRD0 := fCodRD0( cEmpAnt, SRA->RA_FILIAL+SRA->RA_MAT )
If Empty(cCodRD0)
	If aScan( aLogIncon, { |x| x == STR0213 } ) == 0//"Inconsistências na integração de movimentação de departamentos:"
		aAdd(aLogIncon, STR0213)//"Inconsistências na integração de movimentação de departamentos:"
	EndIf
	aAdd(aLogIncon, STR0123 + SRA->RA_FILIAL+SRA->RA_MAT + STR0180)//"Filial + Mat: "##" sem participante relacionado."
	lRet := .F.
EndIf

If lVldDePara .And. lTemREN
	If RET->( dbSeek( xFilial("RET")+"3"+xFilial("SQB", SRA->RA_FILIAL)+SRE->RE_DEPTOP ) ) .And. REN->( dbSeek( xFilial("REN")+"3"+RET->RET_CODIGO ) )	
		cCodCDepto	:= cEmpAnt+REN->REN_FILIAL+REN->REN_CODIGO
	Else
		If aScan( aLogIncon, { |x| x == STR0213 } ) == 0//"Inconsistências na integração de movimentação de departamentos:"
			aAdd(aLogIncon, STR0213)//"Inconsistências na integração de movimentação de departamentos:"
		EndIf
		aAdd(aLogIncon, STR0123 + SRA->RA_FILIAL+SRA->RA_MAT + STR0198)//"Filial + Mat: "##" vinculado a um departamento não encontrado no cadastro de De x Para."
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldHFil
Função que verifica se a movimentação de filiais é válida para integração
@author  Allyson Luiz Mesashi
@since   07/06/2022
/*/
//-------------------------------------------------------------------
Static Function fVldHFil( cCodRD0 )

Local lRet	:= .T.

cCodRD0 := fCodRD0( cEmpAnt, SRA->RA_FILIAL+SRA->RA_MAT )
If Empty(cCodRD0)
	If aScan( aLogIncon, { |x| x == STR0220 } ) == 0//"Inconsistências na integração de movimentação de filiais:"
		aAdd(aLogIncon, STR0220)//"Inconsistências na integração de movimentação de filiais:"
	EndIf
	aAdd(aLogIncon, STR0123 + SRA->RA_FILIAL+SRA->RA_MAT + STR0180)//"Filial + Mat: "##" sem participante relacionado."
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldHGrp()
Função que verifica se a movimentação de grupos de cargo é válida para integração
@author  Allyson Luiz Mesashi
@since   08/06/2022
/*/
//-------------------------------------------------------------------
Static Function fVldHGrp( lVldDePara, cCodRD0, cCodGrupo, cCodGrpQ3 )

Local lRet	:= .T.

cCodRD0 := fCodRD0( cEmpAnt, SR7->R7_FILIAL+SR7->R7_MAT )
If Empty(cCodRD0)
	If aScan( aLogIncon, { |x| x == STR0227 } ) == 0//"Inconsistências na integração de movimentação de grupos de cargo:"
		aAdd(aLogIncon, STR0227)//"Inconsistências na integração de movimentação de grupos de cargo:"
	EndIf
	aAdd(aLogIncon, STR0123 + SR7->R7_FILIAL+SR7->R7_MAT + STR0180)//"Filial + Mat: "##" sem participante relacionado."
	lRet := .F.
EndIf

If lVldDePara .And. lTemREN
	If RET->( dbSeek( xFilial("RET")+"1"+xFilial("SQ0", SR7->R7_FILIAL)+cCodGrpQ3 ) ) .And. REN->( dbSeek( xFilial("REN")+"1"+RET->RET_CODIGO ) )	
		cCodGrupo	:= cEmpAnt+REN->REN_FILIAL+REN->REN_CODIGO
	Else
		If aScan( aLogIncon, { |x| x == STR0227 } ) == 0//"Inconsistências na integração de movimentação de grupos de cargo:"
			aAdd(aLogIncon, STR0227)//"Inconsistências na integração de movimentação de grupos de cargo:"
		EndIf
		aAdd(aLogIncon, STR0123 + SR7->R7_FILIAL+SR7->R7_MAT + STR0228)//"Filial + Mat: "##" vinculado a um cargo vinculado a um grupo não encontrado no cadastro de De x Para."
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldAfas
Função que verifica se o afastamento é válido para integração
@author  Allyson Luiz Mesashi
@since   07/06/2022
/*/
//-------------------------------------------------------------------
Static Function fVldAfas( cCodRD0, cCodTipo )

Local lRet	:= .T.

cCodRD0 := fCodRD0( cEmpAnt, SRA->RA_FILIAL+SRA->RA_MAT )
If Empty(cCodRD0)
	If aScan( aLogIncon, { |x| x == STR0234 } ) == 0//"Inconsistências na integração de afastamentos:"
		aAdd(aLogIncon, STR0234)//"Inconsistências na integração de afastamentos:"
	EndIf
	aAdd(aLogIncon, STR0123 + SRA->RA_FILIAL+SRA->RA_MAT + STR0180)//"Filial + Mat: "##" sem participante relacionado."
	lRet := .F.
EndIf

cCodTipo := fCodRCM()
If Empty(cCodTipo)
	If aScan( aLogIncon, { |x| x == STR0234 } ) == 0//"Inconsistências na integração de afastamentos:"
		aAdd(aLogIncon, STR0234)//"Inconsistências na integração de afastamentos:"
	EndIf
	aAdd(aLogIncon, STR0123 + SRA->RA_FILIAL+SRA->RA_MAT + STR0235)//"Filial + Mat: "##' com tipo de ausência sem preenchimento do campo "Tipo P&M".'
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fCodRCM()
Função que efetua a busca do tipo de afastamento do P&M a partir da RCM
@author  Allyson Luiz Mesashi
@since   29/06/2022
/*/
//-------------------------------------------------------------------
Static Function fCodRCM()

Local cCodTipo	:= ""

If RCM->( dbSeek( xFilial("RCM", SR8->R8_FILIAL) + SR8->R8_TIPOAFA ) )
	cCodTipo := RCM->RCM_TIPOPM
EndIf

Return cCodTipo

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldFalta
Função que verifica se a falta é válida para integração
@author  Allyson Luiz Mesashi
@since   01/07/2022
/*/
//-------------------------------------------------------------------
Static Function fVldFalta( cCodRD0 )

Local lRet	:= .T.

cCodRD0 := fCodRD0( cEmpAnt, SRA->RA_FILIAL+SRA->RA_MAT )
If Empty(cCodRD0)
	If aScan( aLogIncon, { |x| x == STR0241 } ) == 0//"Inconsistências na integração de faltas:"
		aAdd(aLogIncon, STR0241)//"Inconsistências na integração de faltas:"
	EndIf
	aAdd(aLogIncon, STR0123 + SRA->RA_FILIAL+SRA->RA_MAT + STR0180)//"Filial + Mat: "##" sem participante relacionado."
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldFalta
Função que verifica se a falta é válida para integração
@author  Allyson Luiz Mesashi
@since   01/07/2022
/*/
//-------------------------------------------------------------------
Static Function fVldLider( cCodRD0, cCodLider )

Local aDeptos 		:= {}
Local aSuperior		:= {}
Local cTipoOrg		:= ""
Local lRet			:= .T.
Local nPosDepto		:= 0

cCodRD0 := fCodRD0( cEmpAnt, SRA->RA_FILIAL+SRA->RA_MAT )
If Empty(cCodRD0)
	If aScan( aLogIncon, { |x| x == STR0254 } ) == 0//"Inconsistências na integração de líder dos funcionários:"
		aAdd(aLogIncon, STR0254)//"Inconsistências na integração de líder dos funcionários:"
	EndIf
	aAdd(aLogIncon, STR0123 + SRA->RA_FILIAL+SRA->RA_MAT + STR0180)//"Filial + Mat: "##" sem participante relacionado."
	lRet := .F.
EndIf

If ( nPosDepto := aScan( aBkpDeptos, { |x| x[1] == SRA->RA_FILIAL } ) ) > 0
	aDeptos := aClone( aBkpDeptos[nPosDepto, 2] )
Else
	aDeptos := fEstrutDepto( SRA->RA_FILIAL )
	aAdd( aBkpDeptos, { SRA->RA_FILIAL, aClone(aDeptos) } )
EndIf

TipoOrg(@cTipoOrg, cOpcVis)
aSuperior 	:= fBuscaSuperior(SRA->RA_FILIAL, SRA->RA_MAT, SRA->RA_DEPTO, aDeptos, cTipoOrg, cOpcVis)
If !Empty(aSuperior) .And. !Empty(aSuperior[1, 1]+aSuperior[1, 2])
	cCodLider := fCodRD0( aSuperior[1, 7], aSuperior[1, 1]+aSuperior[1, 2] )
	If Empty(cCodLider)
		If aScan( aLogIncon, { |x| x == STR0254 } ) == 0//"Inconsistências na integração de líder dos funcionários:"
			aAdd(aLogIncon, STR0254)//"Inconsistências na integração de líder dos funcionários:"
		EndIf
		aAdd(aLogIncon, STR0123 + SRA->RA_FILIAL+SRA->RA_MAT + STR0256)//"Filial + Mat: "##" com líder sem participante relacionado."
		lRet := .F.
	EndIf
EndIf

Return lRet
