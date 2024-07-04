#INCLUDE "JURA070.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"

#DEFINE ANOMES  1
#DEFINE PERC    3
#DEFINE OK      4

#DEFINE AMINI   1
#DEFINE AMFIM   2
#DEFINE PART    3
#DEFINE TIPO    4
#DEFINE PERCENT 5
#DEFINE DTIPO   6

Static aShow         := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,"Confirmar"},{.T.,"Fechar"},{.F.,Nil},{.F.,Nil}}
Static _J96GrpCli
Static _J96CodCli
Static _J96LojCli
Static _aCnt070      := {}

Static _cNumCaso     := SuperGetMV('MV_JCASO1',, '1') // 1 = Depende do Cliente; 2 = Independente de Cliente
Static _lPreservCaso := (_cNumCaso == "2") .And. SuperGetMV('MV_JCASO3',, .F.) // .T./.F. = Preserva ou não o número do Caso de Origem quando for Independente de Cliente.
Static __InMsgRun    := .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA070
Cadastro de Casos

@author David Gonçalves Fernandes
@since 07/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA070()
Local cLojaAuto := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

Private oBrowse := Nil

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NVE" )
oBrowse:SetLocate()
Iif(cLojaAuto == "1" .And. FindFunction("JurBrwRev"), JurBrwRev(oBrowse, "NVE", {"NVE_LCLIEN", "NVE_CLJNV"}), )
JurSetLeg(oBrowse, "NVE" )
JurSetBSize(oBrowse)
J070Filter(oBrowse, cLojaAuto) // Adiciona filtro padrões no browse

oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J070Filter
Adiciona filtros padrões no browse

@param  oBrowse, objeto, browse da rotina

@author Reginaldo Borges / Cristina Cintra
@since  08/08/2022
/*/
//-------------------------------------------------------------------
Static Function J070Filter(oBrowse, cLojaAuto)
Local aFilNVE1 := {}
Local aFilNVE2 := {}
Local aFilNVE3 := {}
Local aFilNVE4 := {}
Local aFilNVE5 := {}
Local aFilNVE6 := {}
Local aFilNVE7 := {}

	SAddFilPar("NVE_CPART5", "==", "%NVE_CPART50%", @aFilNVE1)
	oBrowse:AddFilter(STR0184, 'NVE_CPART5 == "%NVE_CPART50%"', .F., .F., , .T., aFilNVE1, STR0184) // "Código Sócio Responsável"

	SAddFilPar("NVE_SITUAC", "==", "%NVE_SITUAC0%", @aFilNVE2)
	oBrowse:AddFilter(STR0185, 'NVE_SITUAC == "%NVE_SITUAC0%"', .F., .F., , .T., aFilNVE2, STR0185) // "Situação"

	SAddFilPar("NVE_DTENTR", ">=", "%NVE_DTENTR0%", @aFilNVE3)
	oBrowse:AddFilter(STR0186, 'NVE_DTENTR >= "%NVE_DTENTR0%"', .F., .F., , .T., aFilNVE3, STR0186) // "Data Maior ou Igual a"

	SAddFilPar("NVE_DTENTR", "<=", "%NVE_DTENTR0%", @aFilNVE4)
	oBrowse:AddFilter(STR0187, 'NVE_DTENTR <= "%NVE_DTENTR0%"', .F., .F., , .T., aFilNVE4, STR0187) // "Data Menor ou Igual a"

	 If cLojaAuto == "2"
		SAddFilPar("NVE_CCLIEN", "==", "%NVE_CCLIEN0%", @aFilNVE5)
		SAddFilPar("NVE_LCLIEN", "==", "%NVE_LCLIEN0%", @aFilNVE5)
		oBrowse:AddFilter(STR0188, 'NVE_CCLIEN == "%NVE_CCLIEN0%" .AND. NVE_LCLIEN == "%NVE_LCLIEN0%"', .F., .F., , .T., aFilNVE5, STR0188) // "Cliente"
	Else 
	 	SAddFilPar("NVE_CCLIEN", "==", "%NVE_CCLIEN0%", @aFilNVE5)
	 	oBrowse:AddFilter(STR0188, 'NVE_CCLIEN == "%NVE_CCLIEN0%"', .F., .F., , .T., aFilNVE5, STR0188) // "Cliente"
	 EndIf

	SAddFilPar("NVE_NUMCAS", "$", "%NVE_NUMCAS0%", @aFilNVE6)
	oBrowse:AddFilter(STR0190, 'ALLTRIM(UPPER("%NVE_NUMCAS0%")) $ UPPER(NVE_NUMCAS)', .F., .F., , .T., aFilNVE6, STR0190) // "Caso"

	SAddFilPar("NVE_TITULO", "$", "%NVE_TITULO0%", @aFilNVE7)
	oBrowse:AddFilter(STR0191, 'ALLTRIM(UPPER("%NVE_TITULO0%")) $ UPPER(NVE_TITULO)', .F., .F., , .T., aFilNVE7, STR0191) // "Título do Caso"

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

@author Romeu Calmon Braga Mendonça
@since 07/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina   := {}
Local aUserButt := {}

aAdd( aRotina, { STR0001, "PesqBrw"              , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA070"      , 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA070"      , 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA070"      , 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA070"      , 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0168, "JA070REMAN()"         , 0, 4, 0, NIL } ) // "Remanejar"
aAdd( aRotina, { STR0065, "JA070REVAL()"         , 0, 4, 0, NIL } ) // "Revalorizar TSs"
aAdd( aRotina, { STR0090, "JA070DLG()"           , 0, 8, 0, NIL } ) // "Casos Sem Contrato"
If _lPreservCaso
	aAdd( aRotina, { STR0109, "JA070NoRev()"     , 0, 8, 0, NIL } ) // "Casos não revisados"
EndIf

// Ponto de entrada para acrescentar botões no menu
If ExistBlock('JURA070') // Mesmo ID do Modelo de Dados
	aUserButt := ExecBlock('JURA070', .F., .F., { Nil, "MENUDEF", 'JURA070'})
	If ValType( aUserButt ) == 'A'
		aEval( aUserButt, { |aX| aAdd( aRotina, aX ) } )
	EndIf
EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Casos

@author Romeu Calmon Braga Mendonça
@since 07/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView      := Nil
Local bNVECas    := {|xAux| !AllTrim(xAux) $ 'NVE_CCLINV|NVE_CLJNV|NVE_CCASNV|NVE_CCLIAN|NVE_CLOJAN|NVE_CCASAN|NVE_REVISA|NVE_DTREVI|NVE_SGLREV|NVE_CPARTR|NVE_DPARTR|NVE_OBSREV'}
Local bNVERem    := {|xAux|  AllTrim(xAux) $ 'NVE_CCLINV|NVE_CLJNV|NVE_CCASNV|NVE_CCLIAN|NVE_CLOJAN|NVE_CCASAN|NVE_REVISA|NVE_DTREVI|NVE_SGLREV|NVE_CPARTR|NVE_DPARTR|NVE_OBSREV'}
Local oModel     := FWLoadModel( "JURA070", )
Local oStruct    := FWFormStruct( 2, "NVE", bNVECas )    //Caso
Local oStructNUU := FWFormStruct( 2, "NUU" )             //Histórico do Caso
Local oStructREM := FWFormStruct( 2, "NVE", bNVERem )    //Remanejamento de Caso
Local oStructNUT := FWFormStruct( 2, "NUT" )             //Relac. Contrato X Casos
Local oStructNUW := FWFormStruct( 2, "NUW" )             //Hist. Exc da tab honor - cat
Local oStructNV0 := FWFormStruct( 2, "NV0" )             //Hist. Exc da tab honor - part
Local oStructNWL := FWFormStruct( 2, "NWL" )             //Condição de Êxito
Local oStructNUK := FWFormStruct( 2, "NUK" )             //Participação no Caso
Local oStructNVF := FWFormStruct( 2, "NVF" )             //Participação no Caso - Hist.
Local oStructNT7 := FWFormStruct( 2, "NT7" )             //Título do Caso por Idioma
Local oStructNY1 := FWFormStruct( 2, "NY1" )             //Histórico do remanejamento
Local oStructOHN := Nil                                  //Sócios/Revisores
Local oStructOHR := Nil                                  //Exceção de Valor por Tipo de Atividade
Local cLojaAuto  := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local lUsaHist   := SuperGetMV( 'MV_JURHS1',, .F. )       //Indica se é usa histórico
Local lMultRevis := ( SuperGetMV("MV_JMULTRV",, .F.) .And. (SuperGetMV("MV_JREVILD",, '2') == '1') ) // Indica se é utilizado o conceito de múltiplos revisores e a revisão de pré-fatura do LD.
Local lOHRInDic  := FWAliasInDic("OHR")
Local lIntegrPFS := SuperGetMV("MV_JFTJURI",, "2" ) == "1" //Se a integração SIGAJURI x SIGAPFS estiver Habilitada 
Local lJ070Sheet := ExistBlock("J070Sheet")
Local cParam     := AllTrim( SuperGetMv('MV_JDOCUME',, '1'))

JurSetAgrp( 'NVE',, oStruct ) //Define os agrupamentos dos campos

If (cLojaAuto == "1")
	oStruct:RemoveField( "NVE_LCLIEN" )
	oStructREM:RemoveField( "NVE_CLOJAN" )
	oStructREM:RemoveField( "NVE_CLJNV" )
	oStructNY1:RemoveField( "NY1_CLOJA" )
EndIf

oStruct:RemoveField( "NVE_CPART1" )
oStruct:RemoveField( "NVE_CPART2" )
oStruct:RemoveField( "NVE_CPART3" )
oStruct:RemoveField( "NVE_CPART4" )
oStruct:RemoveField( "NVE_CPART5" )
oStruct:RemoveField( "NVE_CPARTR" )

If NVE->(ColumnPos("NVE_CPTDBT")) > 0
	oStruct:RemoveField("NVE_CPTDBT")
EndIf

If NVE->(FieldPos("NVE_CODLD")) > 0
	oStruct:RemoveField('NVE_CODLD')
EndIf

//Campos de estão no Cadastro Principal
oStructNUU:RemoveField( "NUU_CCLIEN" ) //Caso
oStructNUU:RemoveField( "NUU_CLOJA"  )
oStructNUU:RemoveField( "NUU_CCASO"  )

oStructNUT:RemoveField( "NUT_CCLIEN" ) //Relac. Contrato X Casos
oStructNUT:RemoveField( "NUT_CLOJA"  )
oStructNUT:RemoveField( "NUT_DCLIEN" )
oStructNUT:RemoveField( "NUT_CCASO"  )
oStructNUT:RemoveField( "NUT_DCASO"  )
oStructNUT:RemoveField( "NUT_CPART1" )

oStructNUW:RemoveField( "NUW_COD"    ) //Hist. Exc da tab honor - cat
oStructNUW:RemoveField( "NUW_CCLIEN" )
oStructNUW:RemoveField( "NUW_CLOJA"  )
oStructNUW:RemoveField( "NUW_CCASO"  )

oStructNV0:RemoveField( "NV0_COD"    ) //Hist. Exc da tab honor - part
oStructNV0:RemoveField( "NV0_CCLIEN" )
oStructNV0:RemoveField( "NV0_CLOJA"  )
oStructNV0:RemoveField( "NV0_CCASO"  )
oStructNV0:RemoveField( "NV0_CPART"  )

oStructNUK:RemoveField( "NUK_COD"    ) //Particpação no Caso
oStructNUK:RemoveField( "NUK_CCLIEN" )
oStructNUK:RemoveField( "NUK_CLOJA"  )
oStructNUK:RemoveField( "NUK_NUMCAS" )
oStructNUK:RemoveField( "NUK_CPART"  )
oStructNUK:RemoveField( "NUK_MARCA"  )
If NUK->(ColumnPos("NUK_CODLD")) > 0 // @12.1.33
	oStructNUK:RemoveField("NUK_CODLD")
EndIf

oStructNVF:RemoveField( "NVF_COD"    ) //Particpação no Caso - Hist
oStructNVF:RemoveField( "NVF_CCLIEN" )
oStructNVF:RemoveField( "NVF_CLOJA"  )
oStructNVF:RemoveField( "NVF_NUMCAS" )
oStructNVF:RemoveField( "NVF_CPART"  )
oStructNVF:RemoveField( "NVF_MARCA"  )

oStructNWL:RemoveField( "NWL_COD"    ) //Condição de Êxito
oStructNWL:RemoveField( "NWL_CCLIEN" )
oStructNWL:RemoveField( "NWL_CLOJA"  )
oStructNWL:RemoveField( "NWL_DCLIEN" )
oStructNWL:RemoveField( "NWL_NUMCAS" )
oStructNWL:RemoveField( "NWL_DCASO"  )

oStructNT7:RemoveField( "NT7_COD"    )
oStructNT7:RemoveField( "NT7_CCLIEN" )
oStructNT7:RemoveField( "NT7_CLOJA"  )
oStructNT7:RemoveField( "NT7_CCASO"  )

If lMultRevis
	oStructOHN := FWFormStruct( 2, "OHN" )
	oStructOHN:RemoveField( "OHN_CCLIEN" )
	oStructOHN:RemoveField( "OHN_CLOJA"  )
	oStructOHN:RemoveField( "OHN_CCASO"  )
	oStructOHN:RemoveField( "OHN_CPREFT" )
	oStructOHN:RemoveField( "OHN_CPART" )
	If OHN->(ColumnPos("OHN_CCONTR")) > 0 // Proteção
		oStructOHN:RemoveField( "OHN_CCONTR" )
	EndIf
EndIf

If _lPreservCaso
	oStructNY1:RemoveField( "NY1_CPART" )
	oStructNY1:RemoveField( "NY1_CPARTR" )
EndIf

If lOHRInDic
	oStructOHR := FWFormStruct(2, "OHR") //Exceção de Valor por Tipo de Atividade
	oStructOHR:RemoveField("OHR_COD")
	oStructOHR:RemoveField("OHR_CCLIEN")
	oStructOHR:RemoveField("OHR_CLOJA")
	oStructOHR:RemoveField("OHR_CCASO")
EndIf

If FWIsInCallStack("JURA096")
	oStructNUT:SetProperty( 'NUT_CCONTR', MODEL_FIELD_NOUPD, .F. )
EndIf

oView := FWFormView():New()
oView:SetModel( oModel )

oView:AddField( "JURA070_CASO", oStruct, "NVEMASTER" )

If lUsaHist
	oView:AddGrid( "JURA070_HIST", oStructNUU, "NUUDETAIL" )
	oView:AddGrid( "JURA070_HPAR", oStructNVF, "NVFDETAIL" )
EndIf
If lMultRevis
	oView:AddGrid( "JURA070_SOCS", oStructOHN, "OHNDETAIL" )
EndIf
oView:AddGrid( "JURA070_RELA", oStructNUT, "NUTDETAIL" )
oView:AddGrid( "JURA070_HEXC", oStructNUW, "NUWDETAIL" )
oView:AddGrid( "JURA070_HEXP", oStructNV0, "NV0DETAIL" )
If lOHRInDic
	oView:AddGrid( "JURA070_HEXA", oStructOHR, "OHRDETAIL" ) // Exceção de Valor por Tipo de Atividade
EndIf
oView:AddGrid( "JURA070_PART", oStructNUK, "NUKDETAIL" )
oView:AddGrid( "JURA070_CEXI", oStructNWL, "NWLDETAIL" )
oView:AddGrid( "JURA070_TITU", oStructNT7, "NT7DETAIL" )

oView:AddField( "JURA070_REM", oStructREM, "NVEMASTER" )

If _lPreservCaso
	oView:AddGrid( "JURA070_HISREM", oStructNY1, "NY1DETAIL" ) // Histórico do remanejamento
EndIf

oView:CreateFolder("FOLDER_01")
oView:AddSheet("FOLDER_01", "ABA_01_01", STR0007 )  //Caso
If lUsaHist
	oView:AddSheet("FOLDER_01", "ABA_01_02", STR0010 )  //Histórico do caso
EndIf
oView:AddSheet("FOLDER_01", "ABA_01_03", STR0023 )  //Relac. Contrato X Casos
oView:AddSheet("FOLDER_01", "ABA_01_04", STR0015 )  //Exceção na Tab honorários
oView:AddSheet("FOLDER_01", "ABA_01_05", STR0016 )  //"Condição de Êxito"
oView:AddSheet("FOLDER_01", "ABA_01_06", STR0017 )  //Participação no Caso
oView:AddSheet("FOLDER_01", "ABA_01_07", STR0051 )  //Título do Caso por Idioma
oView:AddSheet("FOLDER_01", "ABA_01_08", STR0136 )  // Remanejamento
If lMultRevis
	oView:AddSheet( "FOLDER_01", "ABA_01_09", STR0164 ) // "Sócios/Revisores"
EndIf

oView:CreateHorizontalBox("BOX_01_F01_A01", 100,,, "FOLDER_01", "ABA_01_01") //Caso
If lUsaHist
	oView:CreateHorizontalBox("BOX_01_F01_A02", 100,,, "FOLDER_01", "ABA_01_02") //Histórico do caso
EndIf
oView:CreateHorizontalBox("BOX_01_F01_A03", 100,,, "FOLDER_01", "ABA_01_03") //Relac. Contrato X Casos
oView:CreateHorizontalBox("BOX_02_F01_A04", 100,,, "FOLDER_01", "ABA_01_04") //Exceção Tab H.

oView:CreateFolder("FOLDER_02", "BOX_02_F01_A04")
oView:AddSheet("FOLDER_02", "ABA_02_01", STR0013 )     //Exceção tab h - categ
oView:AddSheet("FOLDER_02", "ABA_02_02", STR0014 )     //Exceção tab h - paricip
If lOHRInDic
	oView:AddSheet("FOLDER_02", "ABA_02_03", STR0172 ) //Exceção tab h - Atividade
EndIf

oView:CreateHorizontalBox("BOX_02_F01_A05", 100,,, "FOLDER_01", "ABA_01_05") //Êxito
oView:CreateFolder("FOLDER_03", "BOX_02_F01_A05")
oView:AddSheet("FOLDER_03", "ABA_03_01", STR0072 ) //Êxito - Condição

oView:CreateHorizontalBox("BOX_01_F02_A01", 100,,, "FOLDER_02", "ABA_02_01")  // Exceção Tab H. categ - Hist
oView:CreateHorizontalBox("BOX_01_F02_A02", 100,,, "FOLDER_02", "ABA_02_02")  // Exceção Tab H. particip - Hist.
If lOHRInDic
	oView:CreateHorizontalBox("BOX_01_F02_A03", 100,,, "FOLDER_02", "ABA_02_03")// Exceção Tab H. Atividade
EndIf
If lUsaHist
	oView:CreateHorizontalBox("BOX_01_F01_A06", 50,,, "FOLDER_01", "ABA_01_06")  // Participação no Caso
	oView:CreateHorizontalBox("BOX_02_F01_A06", 50,,, "FOLDER_01", "ABA_01_06")  // Participação no Caso - Hist
Else
	oView:CreateHorizontalBox("BOX_01_F01_A06", 100,,, "FOLDER_01", "ABA_01_06")  // Participação no Caso
EndIf
oView:CreateHorizontalBox("BOX_01_F03_A05", 100,,, "FOLDER_03", "ABA_03_01") //Êxito - Condição
oView:CreateHorizontalBox("BOX_01_F01_A07", 100,,, "FOLDER_01", "ABA_01_07") // Título do Caso por Idioma

If _lPreservCaso
	oView:CreateHorizontalBox("BOX_01_F01_A08", 50,,, "FOLDER_01", "ABA_01_08") //Field de remanejamento
	oView:CreateHorizontalBox("BOX_02_F01_A08", 50,,, "FOLDER_01", "ABA_01_08") // Histórico do remanejamento
Else
	oView:CreateHorizontalBox("BOX_01_F01_A08", 100,,, "FOLDER_01", "ABA_01_08") //Field de remanejamento
EndIf
If lMultRevis
	oView:CreateHorizontalBox("BOX_01_F01_A09", 100,,, "FOLDER_01", "ABA_01_09") //Field de remanejamento
EndIf

oView:SetOwnerView( "JURA070_CASO", "BOX_01_F01_A01" )
oView:SetOwnerView( "JURA070_RELA", "BOX_01_F01_A03" )
oView:SetOwnerView( "JURA070_HEXC", "BOX_01_F02_A01" )
oView:SetOwnerView( "JURA070_HEXP", "BOX_01_F02_A02" )
If lOHRInDic
	oView:SetOwnerView( "JURA070_HEXA", "BOX_01_F02_A03" )
EndIf
oView:SetOwnerView( "JURA070_PART", "BOX_01_F01_A06" )
oView:SetOwnerView( "JURA070_CEXI", "BOX_01_F03_A05" )
oView:SetOwnerView( "JURA070_TITU", "BOX_01_F01_A07" )
oView:SetOwnerView( "JURA070_REM",  "BOX_01_F01_A08" )
If lUsaHist
	oView:SetOwnerView( "JURA070_HIST", "BOX_01_F01_A02" )
	oView:SetOwnerView( "JURA070_HPAR", "BOX_02_F01_A06" )
EndIf
If lMultRevis
	oView:SetOwnerView( "JURA070_SOCS", "BOX_01_F01_A09" )
EndIf

If _lPreservCaso
	oView:SetOwnerView( "JURA070_HISREM", "BOX_02_F01_A08" )

	oView:SetNoInsertLine( "JURA070_HISREM" )
	oView:SetNoUpdateLine( "JURA070_HISREM" )
	oView:SetNoDeleteLine( "JURA070_HISREM" )
	oView:EnableTitleView( "JURA070_HISREM" )
EndIf

If FWIsInCallStack("JURA096")
	oView:SetNoInsertLine( 'JURA070_RELA' )
	oView:SetNoUpdateLine( 'JURA070_RELA' )
	oView:SetNoDeleteLine( 'JURA070_RELA' )
EndIf

If !(cParam == '1' .And. IsPlugin())
	oView:AddUserButton( STR0179, "CLIPS", {| oView | JURANEXDOC("NVE", "NVEMASTER", , "NVE_CCLIEN", , , , , , "3", {"NVE_LCLIEN","NVE_NUMCAS"}, , , .T.)})
EndIf

oView:SetDescription( STR0007 ) // "Caso"
oView:EnableControlBar( .T. )

oView:EnableTitleView( "JURA070_HEXC" )
oView:EnableTitleView( "JURA070_HEXP" )
If lOHRInDic
	oView:EnableTitleView( "JURA070_HEXA" )
EndIf
If lUsaHist
	oView:EnableTitleView( "JURA070_HPAR" )
EndIf

If lIntegrPFS .Or. nModulo == 77 // SIGAPFS
	oView:SetCloseOnOk({|| .F.})
EndIf

// Ponto de entrada para criar uma nova aba no cadastro de casos
If lJ070Sheet
	J070Sheet(@oModel, @oView)
EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Casos

@author Romeu Calmon Braga Mendonça
@since 07/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local lShowVirt  := !JurIsRest() // Inclui os campos virtuais nos structs somente se não for REST (Necessário já que os inicializadores dos campos virtuais são executados sempre, mesmo sem o uso do header FIELDVIRTUAL = TRUE)
Local oStruct    := FWFormStruct( 1, "NVE",,, lShowVirt )   //Caso
Local oStructNUU := FWFormStruct( 1, "NUU",,, lShowVirt )   //Histórico do Caso
Local oStructNUT := FWFormStruct( 1, "NUT",,, lShowVirt )   //Relac. Contrato X Casos
Local oStructNUW := FWFormStruct( 1, "NUW",,, lShowVirt )   //Hist. Exc da tab honor - cat
Local oStructNV0 := FWFormStruct( 1, "NV0",,, lShowVirt )   //Hist. Exc da tab honor - part
Local oStructNWL := FWFormStruct( 1, "NWL",,, lShowVirt )   //Condição de Êxito
Local oStructNUK := FWFormStruct( 1, "NUK",,, lShowVirt )   //Participação no Caso
Local oStructNVF := FWFormStruct( 1, "NVF",,, lShowVirt )   //Participação no Caso - Hist.
Local oStructNT7 := FWFormStruct( 1, "NT7",,, lShowVirt )   //Título do Caso por Idioma
Local oStructNY1 := FWFormStruct( 1, "NY1",,, lShowVirt )   //Histórico do remanejamento
Local oStructOHN := Nil                        //Sócios/Revisores
Local oStructOHR := Nil                        //Exceção de Valor por Tipo de Atividade
Local bPosVldNUU := {|oX| JHistValid(oX) .And. Jur070LOk(oX, "NUUDETAIL")}
Local bPosVldNVF := {|oX| JHistValid(oX, {"NVF_CPART", "NVF_CTIPO"}) .And. Jur070LOk(oX, "NVFDETAIL")}
Local bPosVldNV0 := {|oX| JHistValid(oX, {"NV0_CPART"}) .And. Jur070LOk(oX, "NV0DETAIL")}
Local oCommit    := JA070COMMIT():New()
Local lMultRevis := ( SuperGetMV("MV_JMULTRV",, .F.) .And. (SuperGetMV("MV_JREVILD",, '2') == '1') ) // Indica se é utilizado o conceito de múltiplos revisores e a revisão de pré-fatura do LD.
Local lOHRInDic  := FWAliasInDic("OHR")

If lOHRInDic
	oStructOHR := FWFormStruct( 1, "OHR",,, lShowVirt ) //Exceção de Valor por Tipo de Atividade	
EndIf

If !lShowVirt
	// Adiciona os campos virtuais de "SIGLA" novamente nas estruturas, pois foram retirados via lShowVirt,
	// mas precisam existir para execução das operações nos lançamentos via REST
	AddCampo(1, "NVE_SIGLA1", @oStruct)
	AddCampo(1, "NVE_SIGLA2", @oStruct)
	AddCampo(1, "NVE_SIGLA3", @oStruct)
	AddCampo(1, "NVE_SIGLA4", @oStruct)
	AddCampo(1, "NVE_SIGLA5", @oStruct)
	AddCampo(1, "NVE_SGLREV", @oStruct)
	AddCampo(1, "NUT_SIGLA" , @oStructNUT)
	AddCampo(1, "NV0_SIGLA" , @oStructNV0)
	AddCampo(1, "NUK_SIGLA" , @oStructNUK)
	AddCampo(1, "NVF_SIGLA" , @oStructNVF)
	AddCampo(1, "NY1_SIGLA" , @oStructNY1)
	AddCampo(1, "NY1_SGLREV", @oStructNY1)
EndIf

If FWIsInCallStack("JURA096")
	oStructNUT:SetProperty( '*', MODEL_FIELD_NOUPD, .T. )
Else
	oStructNUT:SetProperty("NUT_CCONTR", MODEL_FIELD_WHEN, {|Model| Model:IsInserted() })
EndIf

oModel:= MPFormModel():New( "JURA070", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)

oModel:AddFields( "NVEMASTER", Nil, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/, /*Carga de Dados*/)
oModel:AddGrid( "NUUDETAIL", "NVEMASTER", oStructNUU, Nil /*bLinePre*/      , bPosVldNUU                         , Nil /*bPreVal*/ , Nil /*bPosVal*/      , {|oGrid| JLoadGrid(oGrid, "NUU_AMINI", oModel)} )
oModel:AddGrid( "NUTDETAIL", "NVEMASTER", oStructNUT, {|oX| J070NUTPre(oX)} , {|oX| J070NUTPos(oX)}              , Nil             , {|oX| J70NUTPosF(oX)}, Nil /*bLoad*/                                 )
oModel:AddGrid( "NUWDETAIL", "NVEMASTER", oStructNUW, Nil /*bLinePre*/      , {|oX| JHistValid(oX, {"NUW_CCAT"})}, Nil             , Nil /*bPosVal*/      , {|oGrid| JLoadGrid(oGrid, "NUW_AMINI", oModel)} )
oModel:AddGrid( "NV0DETAIL", "NVEMASTER", oStructNV0, Nil /*bLinePre*/      , bPosVldNV0                         , Nil             , Nil /*bPosVal*/      , {|oGrid| JLoadGrid(oGrid, "NV0_AMINI", oModel)} )
oModel:AddGrid( "NUKDETAIL", "NVEMASTER", oStructNUK, Nil /*bLinePre*/      , {|oX| Jur070LOk(oX, "NUKDETAIL" )} , Nil             , Nil /*bPosVal*/      , Nil /*bLoad*/                                 )
oModel:AddGrid( "NVFDETAIL", "NVEMASTER", oStructNVF, Nil /*bLinePre*/      , bPosVldNVF                         , Nil             , Nil /*bPosVal*/      , {|oGrid| JLoadGrid(oGrid, "NVF_AMINI", oModel)} )
oModel:AddGrid( "NT7DETAIL", "NVEMASTER", oStructNT7, Nil /*bLinePre*/      , Nil  /*bLinePost*/                 , Nil             , Nil /*bPosVal*/      , Nil /*bLoad*/                                 )
oModel:AddGrid( "NY1DETAIL", "NVEMASTER", oStructNY1, Nil /*bLinePre*/      , Nil  /*bLinePost*/                 , Nil             , Nil /*bPosVal*/      , Nil /*bLoad*/                                 )
oModel:AddGrid( "NWLDETAIL", "NVEMASTER", oStructNWL, Nil /*bLinePre*/      , {|oX| JA070VldExi()}               , Nil             , Nil /*bPosVal*/      , Nil /*bLoad*/                                 )

If lMultRevis
	oStructOHN := FWFormStruct( 1, "OHN",,, lShowVirt )
	If !lShowVirt
		// Adiciona os campos virtuais de "SIGLA" novamente nas estruturas, pois foram retirados via lShowVirt,
		// mas precisam existir para execução das operações nos lançamentos via REST
		AddCampo(1, "OHN_SIGLA", @oStructOHN)
	EndIf
	oModel:AddGrid( "OHNDETAIL", "NVEMASTER", oStructOHN, Nil /*bLinePre*/  , Nil  /*bLinePost*/                 , Nil             , Nil /*bPosVal*/      , Nil /*bLoad*/                                 )
EndIf

If lOHRInDic //Verifcar função de validação no "bLinePost"
	oModel:AddGrid( "OHRDETAIL" , "NVEMASTER" /*cOwner*/, oStructOHR, /*bLinePre*/, {|oGrid| JHistValid(oGrid, {"OHR_CATIVI"}) .And. J070ValNeg("OHR_VALOR", oGrid) } /*bLinePost*/, /*bPre*/, /*bPost*/ )
EndIf

oModel:SetDescription( STR0008 ) // "Modelo de Dados de Caso"

oModel:SetActivate( {|oModel| J070Active(oModel)} )

//Histórico do Caso
oModel:GetModel( "NUUDETAIL" ):SetDelAllLine(.T.)
oModel:GetModel( "NUUDETAIL" ):SetUniqueLine( { "NUU_AMINI", "NUU_AMFIM" } )
oModel:SetRelation( "NUUDETAIL", { { "NUU_FILIAL", "xFilial( 'NUU' )" }, ;
                                   { "NUU_CCLIEN", "NVE_CCLIEN" }, ;
                                   { "NUU_CLOJA" , "NVE_LCLIEN" }, ;
                                   { "NUU_CCASO" , "NVE_NUMCAS" } }, NUU->( IndexKey( 2 ) ) )

//Relac. Contrato X Casos
oModel:GetModel( 'NUTDETAIL' ):SetUniqueLine( { 'NUT_CCONTR' } )
oModel:SetRelation( "NUTDETAIL", { { "NUT_FILIAL", "xFilial( 'NUT' )" }, ;
                                   { "NUT_CCLIEN", "NVE_CCLIEN" }, ;
                                   { "NUT_CLOJA" , "NVE_LCLIEN" }, ;
                                   { "NUT_CCASO" , "NVE_NUMCAS" } }, NUT->( IndexKey( 2 ) ) )

//Hist. Exc da tab honor - cat
oModel:GetModel( "NUWDETAIL" ):SetDelAllLine(.T.)
oModel:GetModel( "NUWDETAIL" ):SetUniqueLine( { "NUW_CCAT", "NUW_AMINI" } )
oModel:SetRelation( "NUWDETAIL", { { "NUW_FILIAL", "xFilial( 'NUW' )" }, ;
                                   { "NUW_CCLIEN", "NVE_CCLIEN" }, ;
                                   { "NUW_CLOJA" , "NVE_LCLIEN" }, ;
                                   { "NUW_CCASO" , "NVE_NUMCAS" } }, NUW->( IndexKey( 1 ) ) )

//Hist. Exc da tab honor - part
oModel:GetModel( "NV0DETAIL" ):SetDelAllLine(.T.)
oModel:GetModel( "NV0DETAIL" ):SetUniqueLine( { "NV0_CPART", "NV0_AMINI" } )
oModel:SetRelation( "NV0DETAIL", { { "NV0_FILIAL", "xFilial( 'NV0' )" }, ;
                                   { "NV0_CCLIEN", "NVE_CCLIEN" }, ;
                                   { "NV0_CLOJA" , "NVE_LCLIEN" }, ;
                                   { "NV0_CCASO" , "NVE_NUMCAS" } }, NV0->( IndexKey( 1 ) ) )

//Participacao No caso
oModel:GetModel( "NUKDETAIL" ):SetDelAllLine(.T.)
oModel:GetModel( "NUKDETAIL" ):SetUniqueLine( { "NUK_CPART", "NUK_CTIPO" } )
oModel:SetRelation( "NUKDETAIL", { { "NUK_FILIAL", "xFilial( 'NUK' )" }, ;
                                   { "NUK_CCLIEN", "NVE_CCLIEN" }, ;
                                   { "NUK_CLOJA" , "NVE_LCLIEN" }, ;
                                   { "NUK_NUMCAS", "NVE_NUMCAS" } }, NUK->( IndexKey( 2 ) ) )

//Hist. Participação no caso
oModel:GetModel( "NVFDETAIL" ):SetDelAllLine(.T.)
oModel:GetModel( "NVFDETAIL" ):SetUniqueLine( { "NVF_CPART", "NVF_CTIPO", "NVF_AMINI" } )
oModel:SetRelation( "NVFDETAIL", { { "NVF_FILIAL", "xFilial( 'NVF' )" }, ;
                                   { "NVF_CCLIEN", "NVE_CCLIEN" }, ;
                                   { "NVF_CLOJA" , "NVE_LCLIEN" }, ;
                                   { "NVF_NUMCAS", "NVE_NUMCAS" }}, NVF->( IndexKey( 1 ) ) )

//Êxito - Condição
oModel:GetModel( "NWLDETAIL" ):SetUniqueLine( { "NWL_COD" } )
oModel:SetRelation( "NWLDETAIL", { { "NWL_FILIAL", "xFilial( 'NWL' )" }, ;
                                   { "NWL_CCLIEN", "NVE_CCLIEN" }, ;
                                   { "NWL_CLOJA" , "NVE_LCLIEN" }, ;
                                   { "NWL_NUMCAS", "NVE_NUMCAS" } }, NWL->( IndexKey( 1 ) ) )

//Título do Caso por Idioma
oModel:GetModel( "NT7DETAIL" ):SetDelAllLine(.T.)
oModel:GetModel( "NT7DETAIL" ):SetUniqueLine( { "NT7_CIDIOM"} )
oModel:SetRelation( "NT7DETAIL", { { "NT7_FILIAL", "xFilial( 'NT7' )" }, ;
                                   { "NT7_CCLIEN", "NVE_CCLIEN" }, ;
                                   { "NT7_CLOJA" , "NVE_LCLIEN" }, ;
                                   { "NT7_CCASO" , "NVE_NUMCAS" } }, NT7->( IndexKey( 2 ) ) )

//Histórico do remanejamento
oModel:GetModel( "NY1DETAIL" ):SetDelAllLine(.T.)
oModel:SetRelation( "NY1DETAIL", { { "NY1_FILIAL", "xFilial( 'NY1' )" }, ;
                                   { "NY1_CCASO", "NVE_NUMCAS" } }, NY1->( IndexKey( 2 ) ) )

If lMultRevis
	// Sócios/Revisores
	oModel:GetModel( "OHNDETAIL" ):SetDelAllLine(.T.)
	oModel:GetModel( "OHNDETAIL" ):SetUniqueLine( { "OHN_CPART", "OHN_REVISA" } )
	oModel:SetRelation( "OHNDETAIL",  { { "OHN_FILIAL", "xFilial( 'OHN' )" }, ;
	                                    { "OHN_CPREFT", "CriaVar('NX0_COD', .F.)" }, ;
	                                    { "OHN_CCLIEN", "NVE_CCLIEN" }, ;
	                                    { "OHN_CLOJA" , "NVE_LCLIEN" }, ;
	                                    { "OHN_CCASO" , "NVE_NUMCAS" } }, OHN->( IndexKey( 1 ) ) )
EndIf

If lOHRInDic
	oModel:GetModel( "OHRDETAIL" ):SetDelAllLine(.T.)
	oModel:GetModel( "OHRDETAIL" ):SetUniqueLine( { "OHR_AMINI", "OHR_CATIVI" } )
	oModel:SetRelation( "OHRDETAIL", { { "OHR_FILIAL", "xFilial( 'OHR' )" }, ;
	                                   { "OHR_CCLIEN", "NVE_CCLIEN" }, ;
	                                   { "OHR_CLOJA" , "NVE_LCLIEN" }, ;
	                                   { "OHR_CCASO" , "NVE_NUMCAS" } }, OHR->( IndexKey( 1 ) ) )
EndIf

oModel:GetModel( "NUUDETAIL" ):SetDescription( STR0052 ) // Histórico do Caso
oModel:GetModel( "NUTDETAIL" ):SetDescription( STR0053 ) // Relac. Contrato X Casos
oModel:GetModel( "NUWDETAIL" ):SetDescription( STR0055 ) // Hist. Exc da tab honor - cat
oModel:GetModel( "NV0DETAIL" ):SetDescription( STR0057 ) // Hist. Exc da tab honor - part
oModel:GetModel( "NUKDETAIL" ):SetDescription( STR0058 ) // Participacao No Caso
oModel:GetModel( "NVFDETAIL" ):SetDescription( STR0059 ) // Hist. Participação no caso
oModel:GetModel( "NWLDETAIL" ):SetDescription( STR0074 ) // Êxito - Condição
oModel:GetModel( "NT7DETAIL" ):SetDescription( STR0051 ) // Título do Caso por Idioma
oModel:GetModel( "NY1DETAIL" ):SetDescription( STR0108 ) // Histórico do remanejamento

If lMultRevis
	oModel:GetModel( "OHNDETAIL" ):SetDescription( STR0164 ) // Sócios/Revisores
EndIf

If lOHRInDic
	oModel:GetModel( "OHRDETAIL" ):SetDescription( STR0169 ) // Exceção de valor hora por Tipo de Atividade
EndIf

oModel:SetOptional( "NUUDETAIL", .T.)
oModel:SetOptional( "NUTDETAIL", .T.)
oModel:SetOptional( "NUWDETAIL", .T.)
oModel:SetOptional( "NV0DETAIL", .T.)
oModel:SetOptional( "NUKDETAIL", .T.)
oModel:SetOptional( "NVFDETAIL", .T.)
oModel:SetOptional( "NWLDETAIL", .T.)
oModel:SetOptional( "NT7DETAIL", .T.)
oModel:SetOptional( "NY1DETAIL", .T.)

oModel:SetOnDemand(.T.)

If lMultRevis
	oModel:SetOptional("OHNDETAIL", .T.)
EndIf

If lOHRInDic
	oModel:SetOptional("OHRDETAIL", .T.)
EndIf

oModel:InstallEvent("JA070COMMIT", /*cOwner*/, oCommit)

JFldNoUpd("*", oStructNUW, FwBuildFeature( STRUCT_FEATURE_WHEN, 'JA070WhExc()'), MODEL_FIELD_WHEN)
JFldNoUpd("*", oStructNV0, FwBuildFeature( STRUCT_FEATURE_WHEN, 'JA070WhExc()'), MODEL_FIELD_WHEN)

JurSetRules( oModel, "NVEMASTER",, "NVE" )
JurSetRules( oModel, "NUUDETAIL",, "NUU" )
JurSetRules( oModel, "NUTDETAIL",, "NUT" )
JurSetRules( oModel, "NWLDETAIL",, "NWL" )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA070VL1(oModel)
Valida se existe histórico para a tabela de honorários

@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA070VL1()
Local lRet      := .T.
Local cQuery    := ""
Local cResQRY   := GetNextAlias()
Local aArea     := GetArea()
Local oModel    := NIL
Local cIntegra  := SuperGetMV("MV_JFTJURI",, "2") //Indica se ha Integracao entre SIGAJURI e SIGAPFS (1=Sim;2=Nao)

oModel := FWModelActive()

If !Empty(oModel:GetValue("NUUDETAIL", "NUU_CTABH"))
	cQuery := " SELECT COUNT(NTV.NTV_AMINI) COUNT "
	cQuery +=   " FROM " + RetSqlName( "NTV" ) + " NTV "
	cQuery +=  " WHERE NTV.NTV_FILIAL  = '" + xFilial( "NUU" ) + "' "
	cQuery +=    " AND ((NTV.NTV_AMINI <= '" + FwFldGet("NUU_AMINI") + "' AND NTV.NTV_AMFIM = '') OR "
	cQuery +=    " (NTV.NTV_AMINI <= '" + FwFldGet("NUU_AMINI") + "' AND NTV.NTV_AMFIM >= '" + FwFldGet("NUU_AMINI") + "') ) "
	cQuery +=    " AND NTV.NTV_CTAB = '" + oModel:GetValue("NUUDETAIL", "NUU_CTABH") + "' "
	cQuery +=    " AND NTV.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cResQRY, .T., .T.)

	If ((cResQRY)->COUNT == 0)
		lRet := JurMsgErro(STR0018) // "Não existe histórico da tabela de honorários neste período"
	EndIf

	(cResQRY)->(dbCloseArea())

	RestArea( aArea )
ElseIf cIntegra == "1"
	lRet := JurMsgErro(STR0123) // "A tabela de honorários deve ser preenchida também no histórico do caso."
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J070POSVAL(oModel)
Rotinas executadas na pós-validação do modelo.

@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function J070POSVAL(oModel)
Local lOk        := .T.
Local aArea      := GetArea()
Local aAreaNVE   := NVE->(GetArea())
Local oModelNUK  := oModel:GetModel('NUKDETAIL')
Local oModelNUU  := oModel:GetModel('NUUDETAIL')
Local oModelNVF  := oModel:GetModel('NVFDETAIL')
Local nI         := 0
Local cMarca     := AllTrim(DtoS(Date()) + Substr(Time(), 1, 2) + Substr(Time(), 4, 2) + Substr(Time(), 7, 2))
Local nLinha     := 0
Local cIntegra   := SuperGetMV("MV_JFTJURI",, "2" ) //Indica se ha Integracao entre SIGAJURI e SIGAPFS (1=Sim;2=Nao)
Local lMultRevis := ( SuperGetMV("MV_JMULTRV",, .F.) .And. (SuperGetMV("MV_JREVILD",, '2') == '1') ) // Indica se é utilizado o conceito de múltiplos revisores e a revisão de pré-fatura do LD.
Local cTitMoeLim := ''
Local cTitValLim := ''
Local nOperation := oModel:GetOperation()
Local lIsRest    := (Iif(FindFunction("JurIsRest"), JurIsRest(), .F.))
Local lIntegraca := (SuperGetMV("MV_JFSINC", .F., '2') == '1')
Local lIntRevis  := lIntegraca .And. (SuperGetMV("MV_JREVILD", .F., '2') == '1' ) //Controla a integracao da revisão de pré-fatura com o Legal Desk
Local lJuMsgLd	 := lIsRest .And. FindFunction("JurMsgCdLD") // Verifica se a chamada foi via REST e se existe a função que valida o preenchimento do campo CODLD
Local lValCodLD  := lJuMsgLd .And. NUK->(ColumnPos("NUK_CODLD")) > 0 // @12.1.33

If nOperation ==  3 .Or. nOperation ==  4 // se for Inclusão ou Alteração

	If lIntRevis .And. Empty(oModel:GetValue("NVEMASTER","NVE_CPART5"))
		lOk := JurMsgErro( STR0150, , i18n(STR0171, {AllTrim(RetTitle("NVE_SIGLA5"))})) // "O campo Sócio deve ser preenchido." "Verifique o campo ('#1')."
	EndIf

	If lOk .And. Empty(oModel:GetValue("NVEMASTER", "NVE_CPART2"))
		lOk := JurMsgErro( STR0147, , i18n(STR0171, {AllTrim(RetTitle("NVE_SIGLA2"))}) ) // "O campo Solicitante deve ser preenchido." "Verifique o campo ('#1')."
	EndIf

	If lOk .And. cIntegra == "1" .And. Empty(oModel:GetValue("NVEMASTER", "NVE_CTABH"))
		lOk := JurMsgErro( STR0102, , i18n(STR0171, {AllTrim(RetTitle("NVE_CTABH"))}) ) // "É necessário preencher o campo código da tabela de honorários!" "Verifique o campo ('#1')."
	EndIf

	If lOk .And. cIntegra == "1" .And. Empty(oModel:GetValue("NVEMASTER", "NVE_CPART1"))
		lOk := JurMsgErro( STR0122, , i18n(STR0171, {AllTrim(RetTitle("NVE_SIGLA1"))}) ) // "O campo Revisor deve ser preenchido." "Verifique o campo ('#1')."
	EndIf

	If lOk .And. cIntegra == "1" .And. Empty(oModel:GetValue("NVEMASTER", "NVE_CIDIO"))
		lOk := JurMsgErro( STR0158, , i18n(STR0171, {AllTrim(RetTitle("NVE_CIDIO"))}) ) // "O campo Código Idioma Lançamentos deve ser preenchido." "Verifique o campo ('#1')."
	EndIf

	If lOk .And. cIntegra == "1" .And. !Empty(oModel:GetValue("NVEMASTER", "NVE_CMOELI")) .And. Empty(oModel:GetValue("NVEMASTER", "NVE_VLRLI"))
		cTitMoeLim := Alltrim(RetTitle("NVE_CMOELI"))
		cTitValLim := Alltrim(RetTitle("NVE_VLRLI"))
		lOk := JurMsgErro(I18N(STR0165, {cTitMoeLim, cTitValLim}), , I18N(STR0166, {cTitValLim, cTitMoeLim})) //#"Quando estiver preenchido o campo '#1' é necessário preencher também o valor no campo '#2'." ##" Informe um valor no campo '#1' remova a informação do campo '#2'."
	EndIf

	If lOk .And. nOperation ==  3 // se for Inclusão

		lOk := JA070CLIEN(oModel) //Valida se o cliente pode incluir casos

		If lOk
			lOk := JA070VNCAS(oModel)  //Valida a numeração
		EndIf

	EndIf

	If lOk .And. nOperation ==  4 // se for Alteração

		If lOk
			lOk := JA070ENCER(oModel) //Rotina para validar o encerramento do caso
		EndIf

		If lOk
			lOk := JA070REABR(oModel) //Rotina para validar a reabertura do caso
		EndIf

		If lOk
			lOk := JA070ENCOB(oModel) //Valida se há lançamentos pendentes quando encerrar
		EndIf

		If lOk
			lOk := J070VldAnd(oModel) //validar ao reabrir o caso se já existe outro caso em andamento
		EndIf

		If lOk
			J070PreFt(oModel) //Exbir as pré-fatura que estao associadas ao caso
		EndIf
	EndIf

	If lOk .And.; // Valida duplicidade de período e lacunas de período no Histórico do caso
		!JURPerHist(oModelNUU, .T.)
		lOk := .F.
	EndIf

	If lOk .And.; // Valida duplicidade e lacunas de período no Histórico part Caso
		!JURPerHist(oModelNVF, .T., {"NVF_CTIPO", "NVF_SIGLA"})
		lOk := .F.
	EndIf

	If lOk
		lOk := JA070CONTR() //Valida o relacionamento com contrato
	EndIf

	If lOk
		lOk := JA070VNV2(oModel, "NV0") //Valida a categoria da exceção de Exceção da Tabela de Honorários
	EndIf

	If lOk
		lOk := JA070VPART(oModel) //Valida se há participações obrigatórias e os percentuais não preenchidos
	EndIf

	If lOk
		lOk := JA070EXITC(oModel) //Valida se o Caso possui na Aba Êxito a Fatura ou Condição
	EndIf

	If lOk .And. NVE->(ColumnPos("NVE_SITCAD")) > 0 //Valida a situaçao do Caso
		lOk := JA070VlSit(oModel)
	EndIf 

	If lOk .And. oModel:IsFieldUpdated("NVEMASTER", "NVE_TITULO")
		J70ATUNT7(oModel:GetModel("NT7DETAIL")) //Atualiza o valor do campo revisado da tabela NT7
	EndIf

	If lOk .And. !FWIsInCallStack('JURA063') // não carrega se for remanejamento de caso
		J70AtuCateg( oModel, Nil ) //Rotina para atualizar os campos das categorias
	EndIf

	If lOk .And. lMultRevis
		lOk := JVdMultRev(oModel:GetModel("OHNDETAIL"))
	EndIf

	If lOk
		nLinha := oModelNUK:GetLine()
		If oModelNUK:IsUpdated()
			For nI := 1 To oModelNUK:GetQtdLine()
				oModelNUK:GoLine(nI)
				If !oModelNUK:IsDeleted()
					If lValCodLD .And. oModelNUK:IsInserted() .And. !JurMsgCdLD(oModelNUK:GetValue("NUK_CODLD"))
						lOk := .F.
						Exit
					EndIf
					oModelNUK:SetValue( "NUK_MARCA", cMarca )
				EndIf
			Next
		EndIf
		oModelNUK:GoLine(nLinha)
	EndIf

	If lOk .And. nOperation == 3 .And. lJuMsgLd .And. NVE->(FieldPos("NVE_CODLD")) > 0
		lOk := JurMsgCdLD(oModel:GetValue("NVEMASTER", "NVE_CODLD"))
	EndIf

	If oModel:GetValue("NVEMASTER", "NVE_REVISA") == "1"
		oModel:LoadValue("NVEMASTER", "NVE_CPARTR", JurUsuario(__CUSERID))
		oModel:LoadValue("NVEMASTER", "NVE_DTREVI", dDataBase)
	Else
		oModel:ClearField("NVEMASTER", "NVE_CPARTR")
		oModel:ClearField("NVEMASTER", "NVE_DTREVI")
	EndIf

EndIf

If lOk .And. nOperation ==  5 // se for Exclusão

	//--Valida se existe contrato para esse caso, pois as tabelas NVE e NUT estao no mesmo Model, o SX9 nao efetua a validacao.
	NUT->(dbsetorder(2)) //-- NUT_FILIAL+NUT_CCLIEN+NUT_CLOJA+NUT_CCASO
	If lOk .And. NUT->(DBSeek(xFilial("NUT") + oModel:GetValue("NVEMASTER", "NVE_CCLIEN") +;
													oModel:GetValue("NVEMASTER", "NVE_LCLIEN") +;
													oModel:GetValue("NVEMASTER", "NVE_NUMCAS")) )
		lOk := JurMsgErro(STR0064)
	EndIf

	If lOk .And. !J070VLTLot(oModel) //Valida vinculo com lançamento tabelado em lote
		lOk := JurMsgErro( STR0130 + Capital(AllTrim( INFOSX2( "NWM", 'X2_NOME' ))) + '.' ) //#"Violação de Integridade! Foi encontrada referência deste caso em "
	EndIf

EndIf

RestArea(aAreaNVE)
RestArea(aArea)

Return lOk

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA070COMMIT
Classe interna implementando o FWModelEvent, para execução de função
durante o commit.

@author Cristina Cintra Santos
@since 23/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA070COMMIT FROM FWModelEvent
	Method New()
	Method Before()
	Method After()
	Method InTTS()
	Method ModelPosVld()
End Class

Method New() Class JA070COMMIT
Return

Method Before(oSubModel, cModelId, cAlias, lNewRecord) Class JA070COMMIT

	If ExistBlock("JA070BEFO") //Ponto de entrada entre o Pós Valid e o Commit para ajustes de Histórico
		ExecBlock("JA070BEFO", .F., .F., {oSubModel:GetModel()})
	EndIf

Return

Method After(oSubModel, cModelId, cAlias, lNewRecord) Class JA070COMMIT
	J070AftCom(oSubModel:GetModel())
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} InTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit após 
as gravações porém antes do final da transação.

@param oModel   - Modelo de dados de Casos.
@param cModelId - Identificador do modelo.

@author  Abner Fogaça
@since   26/02/2021
/*/
//-------------------------------------------------------------------
Method InTTS(oModel, cModelId) Class JA070COMMIT
Local nOpc := oModel:GetOperation()
	
	J070FSinc(oModel:GetModel()) // Grava na fila de sincronização - Integração LegalDesk

	If nOpc == MODEL_OPERATION_DELETE .And. FindFunction("JExcAnxSinc")
		JExcAnxSinc("NVE", NVE->NVE_CCLIEN + NVE->NVE_LCLIEN + NVE->NVE_NUMCAS) // Exclui os anexos vinculados ao caso e registra na fila de sincronização
	EndIf

Return Nil

Method ModelPosVld(oSubModel, cModelID) Class JA070COMMIT
Local lRet := .T.
	
	lRet := J070POSVAL(oSubModel:GetModel())
	
	If lRet
		// Ajustes de Histórico do Caso e da Participação
		If !oSubModel:GetModel():GetOperation() == OP_EXCLUIR .And. !FWIsInCallStack('JURA063') // não carrega se for remanejamento de caso
			J70HISTNVE(oSubModel:GetModel())
			J70HSTNUK(oSubModel:GetModel())
		EndIf

		// Atualiza a variável static _aCnt070 para gravar na fila de sincronização os ajustes de vínculos com os contratos
		J070CPYCnt(oSubModel:GetModel(), .F.)
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J070FSinc
Faz a gravação do Caso na Fila de Sincronização (NYS).
Caso tenham sido incluídos ou retirados vínculos com Contratos, 
grava na fila também ajuste no Contrato.

@author Cristina Cintra
@since 23/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J070FSinc(oModel)
Local nQtdLn := Len(_aCnt070)
Local nNUT   := 0

	If SuperGetMV("MV_JFSINC", .F., '2') == '1'

		J170GRAVA(oModel, xFilial('NVE') + oModel:GetValue("NVEMASTER", "NVE_CCLIEN") + oModel:GetValue("NVEMASTER", "NVE_LCLIEN") + oModel:GetValue("NVEMASTER", "NVE_NUMCAS"))

		If nQtdLn > 0
			For nNUT := 1 To nQtdLn
				If (_aCnt070[nNUT][3] .Or. _aCnt070[nNUT][4]) .And. !(_aCnt070[nNUT][3] .And. _aCnt070[nNUT][4]) // Grava apenas se for um contrato novo ou excluído, desconsiderando os incluídos mas deletados
					J170GRAVA("NT0", xFilial("NT0") + _aCnt070[nNUT][2], "4")
				EndIf
			Next nNUT
		EndIf
	
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J070AftCom(oModel)
Executa ações após a efetivação do commit do modelo.

@author Felipe Bonvicini Conti
@since 07/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J070AftCom(oModel)
Local aArea   := GetArea()
Local cClient := oModel:GetValue("NVEMASTER", "NVE_CCLIEN")
Local cLoja   := oModel:GetValue("NVEMASTER", "NVE_LCLIEN")
Local cCaso   := oModel:GetValue("NVEMASTER", "NVE_NUMCAS")
Local cTitulo := oModel:GetValue("NVEMASTER", "NVE_TITULO")

//Verifica a Existencia das Pastas do GED
If ( oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4 )
	//FLUIG
	If SuperGetMV('MV_JDOCUME',, "2") == "3"
		J070PFluig(cClient + cLoja + cCaso, cTitulo)
	EndIf

	//WorkSite
	If SuperGetMV('MV_JDOCUME',, "2") == "1"
		J070PWork(cClient + cLoja + cCaso, cTitulo)
	EndIf
EndIf

If ExistBlock("JA070SOEX") //Ponto de entrada na Alteração do Sócio e Executor
	ExecBlock("JA070SOEX", .F., .F., {oModel})
EndIf

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J70HISTNVE(oModel)
Rotinas de histórico para o caso

@author Bruno Ritter
@since 16/08/2018
@version 2.0
/*/
//-------------------------------------------------------------------
Static Function J70HISTNVE(oModel)
	Local lRet      := .F.
	Local aCpoMdls  := {}
	Local aNVECpo   := {}

	aAdd(aNVECpo, {"NVE_CTABH" , "NUU_CTABH" })
	aAdd(aNVECpo, {"NVE_CTABS" , "NUU_CTABS" })
	aAdd(aNVECpo, {"NVE_TPHORA", "NUU_TPHORA"})
	aAdd(aNVECpo, {"NVE_VLHORA", "NUU_VLHORA"})
	aAdd(aNVECpo, {"NVE_CESCRI", "NUU_CESCR" })
	aAdd(aNVECpo, {"NVE_CAREAJ", "NUU_CAREAJ"})
	aAdd(aNVECpo, {"NVE_CSUBAR", "NUU_CSUBAR"})
	aAdd(aCpoMdls, {"NVEMASTER", aNVECpo})

	lRet := JURHIST(oModel, "NUUDETAIL", aCpoMdls, .F.)
	JurFreeArr(@aNVECpo)
	JurFreeArr(@aCpoMdls)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J70HSTNUK(oModel)
Rotinas de histórico para Participação no Caso

@author Bruno Ritter
@since 16/08/2018
@version 2.0
/*/
//-------------------------------------------------------------------
Static Function J70HSTNUK(oModel)
	Local lRet      := .T.
	Local aCpoMdls  := {}
	Local aNUKCpo   := {}

	aAdd(aNUKCpo, {"NUK_CPART" , "NVF_CPART"})
	aAdd(aNUKCpo, {"NUK_CTIPO" , "NVF_CTIPO"})
	aAdd(aNUKCpo, {"NUK_PERC"  , "NVF_PERC"})
	aAdd(aNUKCpo, {"NUK_DTINI" , "NVF_DTINI"})
	aAdd(aNUKCpo, {"NUK_DTFIN" , "NVF_DTFIN"})
	aAdd(aNUKCpo, {"NUK_COD"   , "NVF_COD"})
	aAdd(aNUKCpo, {"NUK_SIGLA" , "NVF_SIGLA"})
	aAdd(aCpoMdls, {"NUKDETAIL", aNUKCpo})
	
	lRet := JURHIST(oModel, "NVFDETAIL", aCpoMdls, .T., {"NUK_SIGLA", "NVF_SIGLA", "NUK_CTIPO", "NVF_CTIPO"})
	JurFreeArr(@aNUKCpo)
	JurFreeArr(@aCpoMdls)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA070VL0
Rotina para obter o valor hora da categoria da tabh do caso

@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA070VL0(cAlias, oModel)
Local nValor   := 0
Local cCateg   := ''
Local cPart    := ''
Local cTabh    := ''
Local cTPHora  := ''
Local aValor   := {}
Local nLineOld := 0

Default oModel := FWModelActive()

nLineOld := oModel:GetModel(cAlias + "DETAIL"):nLine

cTPHora := oModel:GetValue("NVEMASTER", "NVE_TPHORA")

If cTPHora == "1" // "Fixo"
	nValor := oModel:GetValue("NVEMASTER", "NVE_VLHORA")
Else
	cTabh := oModel:GetValue("NVEMASTER", "NVE_CTABH")
	If !Empty(cTabh)
		Do Case
		Case cAlias == "NV1"
			cCateg := oModel:GetValue(cAlias + "DETAIL", cAlias + "_CCAT")
			If !Empty(cCateg)
				nValor := JurGetDados("NS9", 3, xFilial("NS9") + cTabh + cCateg, "NS9_VALORH") // Honorários - Categoria
			EndIf

		Case cAlias == "NUW"
			nValor := J70VlONUW(oModel)

		Case cAlias == "NV2"
			cPart  := oModel:GetValue(cAlias + "DETAIL", cAlias + "_CPART")
			cCateg := JurGetDados("NUR", 1, xFilial("NUR") + cPart, "NUR_CCAT")

			If oModel:GetValue(cAlias + "DETAIL", cAlias + "_EXCCAT") == '1' // Acumulativo
				aValor := JFindMdl(oModel:GetModel("NV1DETAIL"), "NV1_CCAT", cCateg, {"NV1_VALOR3"})
				If Len(aValor) > 0
					nValor := aValor[1]
				EndIf
			EndIf

			If Empty(nValor)
				nValor := JurGetDados("NSD", 1, xFilial("NSD") + cTabh + cPart, "NSD_VALORH") // Honorários - Profissional
				If Empty(nValor)
					If !Empty(cCateg)
						nValor := JurGetDados("NS9", 3, xFilial("NS9") + cTabh + cCateg, "NS9_VALORH") // Honorários - Categoria
					EndIf
				EndIf

			EndIf

		Case cAlias == "NV0"
			nValor := J70VlONV0(oModel)

		EndCase

	EndIf

EndIf

If cTPHora == "2" .And. (cAlias == "NV1" .Or. cAlias == "NV2") .And. !Empty(nValor) .And. nValor > oModel:GetValue("NVEMASTER", "NVE_VLHORA")
	nValor := oModel:GetValue("NVEMASTER", "NVE_VLHORA")
EndIf

oModel:GetModel(cAlias + "DETAIL"):GoLine(nLineOld)

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} J70VlONUW
Rotina para obter o valor hora da categoria no histórico

@author Felipe Bonvicini Conti
@since 08/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J70VlONUW(oModel)
Local nValor     := 0
Local cTPHora    := ""
Local nValorFixo := 0
Local cTabh      := ""
Local cCateg     := ""
Local cSQL       := ""
Local aSqlRet    := {}

If !Empty(JFindMdlM(oModel:GetModel("NUUDETAIL"), ;
		"(FwFldGet('NUU_AMINI') <= '" + FwFldGet('NUW_AMINI') + "' .And. FwFldGet('NUU_AMFIM') >= '" + FwFldGet('NUW_AMINI') + "').Or."+;
		"(FwFldGet('NUU_AMINI') <= '" + FwFldGet('NUW_AMINI') + "' .And. (FwFldGet('NUU_AMFIM') = '" + FwFldGet('NUU_AMFIM') + "' .Or. FwFldGet('NUU_AMFIM') = '" + CriaVar("NUU_AMFIM", .F.) + "') )", ;
		{"NUU_AMINI"}))
	aValores := JFindMdlM(oModel:GetModel("NUUDETAIL"), ;
		"(FwFldGet('NUU_AMINI') <= '" + FwFldGet('NUW_AMINI') + "' .And. FwFldGet('NUU_AMFIM') >= '" + FwFldGet('NUW_AMINI') + "').Or."+;
		"(FwFldGet('NUU_AMINI') <= '" + FwFldGet('NUW_AMINI') + "' .And. (FwFldGet('NUU_AMFIM') = '" + FwFldGet('NUU_AMFIM') + "' .Or. FwFldGet('NUU_AMFIM') = '" + CriaVar("NUU_AMFIM", .F.) + "') )", ;
		{"NUU_TPHORA", "NUU_VLHORA", "NUU_CTABH"})
	If !Empty(aValores)
		cTPHora    := aValores[1]
		nValorFixo := aValores[2]
		cTabh      := aValores[3]
	EndIf

Else
	JurMsgErro(STR0030 + CRLF + STR0031 + FwFldGet('NUW_AMINI')) // "Hist. Exc da tab honor - cat:" # "Não existe histórico do caso para o período " 
	cTPHora    := "1"
	nValorFixo := 0
EndIf

If cTPHora == "1" // "Fixo"
	nValor := nValorFixo
Else

	cCateg := oModel:GetValue("NUWDETAIL", "NUW_CCAT")
	If !Empty(cCateg)

		cSQL := " SELECT NTU_VALORH "
		cSQL +=   " FROM " + RetSqlname('NTV') + " NTV, " + RetSqlname('NTU') + " NTU "
		cSQL +=  " WHERE NTV_FILIAL = '" + xFilial("NTV") + "' "
		cSQL +=    " AND NTU_FILIAL = '" + xFilial("NTU") + "' "
		cSQL +=    " AND NTV.D_E_L_E_T_ = ' ' "
		cSQL +=    " AND NTU.D_E_L_E_T_ = ' ' "
		cSQL +=    " AND ((NTV_AMINI <= '" + FwFldGet('NUW_AMINI') + "' AND NTV_AMFIM >= '" + FwFldGet('NUW_AMINI') + "' ) OR "
		cSQL +=         " (NTV_AMINI <= '" + FwFldGet('NUW_AMINI') + "' AND (NTV_AMFIM  = '" + FwFldGet('NUW_AMFIM') + "' OR NTV_AMFIM = '" + CriaVar("NTV_AMFIM", .F.) + "' ) ) ) "
		cSQL +=    " AND NTV_COD   = NTU_CHIST "
		cSQL +=    " AND NTV_CTAB  = '" + cTabh + "' "
		cSQL +=    " AND NTV_CTAB  = NTU_CTAB "
		cSQL +=    " AND NTU_CCAT  = '" + cCateg + "' "
		aSqlRet := JurSQL(cSQL, {"NTU_VALORH"})

		If !Empty(aSqlRet)
			nValor := aSqlRet[1][1]
		Else
			JurMsgErro(STR0030 + CRLF + STR0032 + FwFldGet('NUW_AMINI')) // "Hist. Exc da tab honor - cat:" # "Não existe histórico da categoria para o período " 
			nValor := 0
		EndIf

	EndIf

	If cTPHora == "2" .And. !Empty(nValor) .And. nValor > nValorFixo // "Limite"
		nValor := nValorFixo
	EndIf

EndIf

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} J70VlONV0
Rotina para obter o valor hora do participante no histórico

@author Felipe Bonvicini Conti
@since 08/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J70VlONV0(oModel)
Local nValor     := 0
Local cTPHora    := ""
Local nValorFixo := 0
Local cTabh      := ""
Local cPart      := ""
Local cCateg     := ""
Local cSQL       := ""
Local aSqlRet    := {}
Local aRet       := {}
Local cCategoria := ""
Local aValores   := {}

If !Empty(JFindMdlM(oModel:GetModel("NUUDETAIL"), ;
						"(FwFldGet('NUU_AMINI') <= '" + FwFldGet('NV0_AMINI') + "' .And. FwFldGet('NUU_AMFIM') >= '" + FwFldGet('NV0_AMINI') + "').Or."+;
						"(FwFldGet('NUU_AMINI') <= '" + FwFldGet('NV0_AMINI') + "' .And. (FwFldGet('NUU_AMFIM') = '" + FwFldGet('NV0_AMFIM') + "' .Or. FwFldGet('NUU_AMFIM') = '" + CriaVar("NUU_AMFIM", .F.) + "') )", ;
						{"NUU_AMINI"}))
	aValores := JFindMdlM(oModel:GetModel("NUUDETAIL"), ;
							"(FwFldGet('NUU_AMINI') <= '" + FwFldGet('NV0_AMINI') + "' .And. FwFldGet('NUU_AMFIM') >= '" + FwFldGet('NV0_AMINI') + "').Or."+;
							"(FwFldGet('NUU_AMINI') <= '" + FwFldGet('NV0_AMINI') + "' .And. (FwFldGet('NUU_AMFIM') = '" + FwFldGet('NV0_AMFIM') + "' .Or. FwFldGet('NUU_AMFIM') = '" + CriaVar("NUU_AMFIM", .F.) + "') )", ;
							{"NUU_TPHORA", "NUU_VLHORA", "NUU_CTABH"})
	If !Empty(aValores)
		cTPHora    := aValores[1]
		nValorFixo := aValores[2]
		cTabh      := aValores[3]
	EndIf

Else
	JurMsgErro(STR0033 + CRLF + STR0031 + FwFldGet('NV0_AMINI'))
	cTPHora    := "1"
	nValorFixo := 0
EndIf

If cTPHora == "1" // "Fixo"
	nValor := nValorFixo
Else

	cPart  := oModel:GetValue("NV0DETAIL", "NV0_CPART")

	cSQL := " SELECT NUS_CCAT "
	cSQL +=   " FROM " + RetSqlname('NUS') + " NUS "
	cSQL +=  " WHERE NUS_FILIAL = '" + xFilial("NUS") +"' "
	cSQL +=    " AND NUS.D_E_L_E_T_ = ' ' "
	cSQL +=    " AND ((NUS_AMINI <= '" + FwFldGet('NV0_AMINI') + "' And NUS_AMFIM >= '" + FwFldGet('NV0_AMINI') + "' ) Or "
	cSQL +=         " (NUS_AMINI <= '" + FwFldGet('NV0_AMINI') + "' And (NUS_AMFIM  = '" + FwFldGet('NV0_AMFIM') + "' OR NUS_AMFIM  = '" + CriaVar("NUS_AMFIM", .F.) + "' ) ) ) "
	cSQL +=    " AND NUS_CPART = '" + cPart + "' "
	aSqlRet := JurSQL(cSQL, {"NUS_CCAT"}) //Pegar a categoria pelo histórico do participante

	cCateg := IIf(!Empty(aSqlRet), aSqlRet[1][1], "")

	If oModel:GetValue("NV0DETAIL", "NV0_EXCCAT") == '1' //Acumulativo

		If FwFldGet('NV0_REGRA') == '4'
			cCategoria := FwFldGet('NV0_CCAT')
		Else
			cCategoria := JurGetDados("NUR", 1, xFilial("NUR") + FwFldGet("NV0_CPART"), "NUR_CCAT")
		EndIf

		aRet := JFindMdlM(oModel:GetModel("NUWDETAIL"),;
								"(FwFldGet('NUW_CCAT') == '" + cCategoria + "' ) .And. " +;
								"((FwFldGet('NUW_AMINI') <= '" + FwFldGet('NV0_AMINI') + "'.And.FwFldGet('NUW_AMFIM') >= '" + FwFldGet('NV0_AMINI') + "').Or."+;
								"(FwFldGet('NUW_AMINI') <= '" + FwFldGet('NV0_AMINI') + "'.And.(FwFldGet('NUW_AMFIM') = '" + FwFldGet('NV0_AMFIM') + "' .Or. FwFldGet('NUW_AMFIM') = '" + CriaVar("NUW_AMFIM", .F.) + "') ) )", ;
								{"NUW_VALOR3"})

		If !Empty(aRet)
			nValor := aRet[1]
		EndIf
	EndIf

	If Empty(nValor)

		cSQL := " SELECT NTT_VALORH VALOR "
		cSQL +=   " FROM " + RetSqlname('NTV') + " NTV, " + RetSqlname('NTT') + " NTT "
		cSQL +=  " WHERE NTV_FILIAL = '" + xFilial("NTV") + "' "
		cSQL +=    " AND NTT_FILIAL = '" + xFilial("NTT") + "' "
		cSQL +=    " AND NTV.D_E_L_E_T_ = ' ' "
		cSQL +=    " AND NTT.D_E_L_E_T_ = ' ' "
		cSQL +=    " AND ((NTV_AMINI <= '" + FwFldGet('NV0_AMINI') + "' AND NTV_AMFIM >= '" + FwFldGet('NV0_AMINI') + "' ) OR "
		cSQL +=         " (NTV_AMINI <= '" + FwFldGet('NV0_AMINI') + "' AND (NTV_AMFIM  = '" + FwFldGet('NV0_AMFIM') + "' OR NTV_AMFIM  = '" + CriaVar("NTV_AMFIM", .F.) + "' ) ) ) "
		cSQL +=    " AND NTV_COD   = NTT_CHIST "
		cSQL +=    " AND NTV_CTAB  = '" + cTabh + "' "
		cSQL +=    " AND NTT_CTAB  = '" + cTabh + "' "
		cSQL +=    " AND NTT_CPART = '" + cPart + "' "
		cSQL +=    " AND NTT_CCAT  = '" + cCateg + "' "
		cSQL +=  " UNION ALL "
		cSQL += " SELECT NTU_VALORH VALOR "
		cSQL +=   " FROM " + RetSqlname('NTV') + " NTV, " + RetSqlname('NTU') + " NTU "
		cSQL +=  " WHERE NTV_FILIAL = '" + xFilial("NTV") + "' "
		cSQL +=    " AND NTU_FILIAL = '" + xFilial("NTU") + "' "
		cSQL +=    " AND NTV.D_E_L_E_T_ = ' ' "
		cSQL +=    " AND NTU.D_E_L_E_T_ = ' ' "
		cSQL +=    " AND ((NTV_AMINI <= '" + FwFldGet('NV0_AMINI') + "' AND NTV_AMFIM >= '" + FwFldGet('NV0_AMINI') + "' ) OR "
		cSQL +=    " (NTV_AMINI <= '" + FwFldGet('NV0_AMINI') + "' AND (NTV_AMFIM  = '" + FwFldGet('NV0_AMFIM') + "' OR NTV_AMFIM = '" + CriaVar("NTV_AMFIM", .F.) + "' ) ) ) "
		cSQL +=    " AND NTV_COD   = NTU_CHIST "
		cSQL +=    " AND NTV_CTAB  = '" + cTabh + "' "
		cSQL +=    " AND NTU_CTAB  = '" + cTabh + "' "
		cSQL +=    " AND NTV_CTAB  = NTU_CTAB "
		cSQL +=    " AND NTU_CCAT  = '" + cCateg + "' "
		aSqlRet := JurSQL(cSQL, {"VALOR"}) //Pegar o valor Hora pelo histórico da tab honor do part. na categoria

		If !Empty(aSqlRet)
			nValor := aSqlRet[1][1]
		Else
			JurMsgErro(STR0033 + CRLF + STR0032 + FwFldGet('NV0_AMINI'))
			nValor := 0
		EndIf

	EndIf

	If cTPHora == "2" .And. !Empty(nValor) .And. nValor > nValorFixo // "Limite"
		nValor := nValorFixo
	EndIf

EndIf

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} JA070NUMER
Rotina para sugerir a próxima numeração no cadastro do caso

@author David Gonçalves Fernandes
@since 11/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA070NUMER(cCliente, cLoja)
Local cRet       := Criavar( 'NVE_NUMCAS', .F. )
Local nNumero    := 0
Local nMinNumero := 1
Local cQuery     := ''
Local oModel     := FWModelActive()
Local cResQRY    := GetNextAlias()
Local aArea      := GetArea()
Local cNumClien  := SuperGetMV( 'MV_JCASO1',, '1' ) // Seqüência da numeração do caso (1 - Por cliente / 2 - Independente)
Local lUsaLacuna := SuperGetMV( 'MV_JCASO2',, .F. )
Local lUsado     := .F.

Default cCliente := oModel:GetValue("NVEMASTER", "NVE_CCLIEN")
Default cLoja    := oModel:GetValue("NVEMASTER", "NVE_LCLIEN")

If !Empty( cCliente ) .And. !Empty( cLoja )

	If ExistBlock('J070NUM') // PE para customizar o controle de numeração do Caso
		cQuery := ExecBlock('J070NUM', .F., .F., { '1', cCliente, '', cNumClien, lUsaLacuna } )
	Else
		If (cNumClien == '1')
			If lUsaLacuna
				cQuery := " SELECT NVE_NUMCAS " //não foi adicionado o distinct aqui porque nunca o cliente terá dois registros com o mesmo número de caso.
			Else
				cQuery := " SELECT MAX(NVE_NUMCAS) NVE_NUMCAS "
			EndIf
			cQuery +=   " FROM " + RetSqlName( "NVE" ) + " NVE "
			cQuery +=  " WHERE NVE.D_E_L_E_T_ = ' ' "
			cQuery +=    " AND NVE.NVE_FILIAL = '" + xFilial("NVE") + "' "
			cQuery +=    " AND NVE_CCLIEN = '" + cCliente + "' "
			cQuery +=    " AND NVE_LCLIEN = '" + cLoja + "' "
			cQuery +=  " ORDER BY NVE_NUMCAS"
		Else
			If lUsaLacuna
				cQuery := " SELECT DISTINCT NVE_NUMCAS " //colocado o distinct para que a rotina consiga trazer casos com lacuna mesmo quando o número de caso já foi usado em outro cliente.
			Else
				cQuery := " SELECT MAX(NVE_NUMCAS) NVE_NUMCAS "
			EndIf
			cQuery +=   " FROM " + RetSqlName( "NVE" ) + " NVE "
			cQuery +=  " WHERE NVE.D_E_L_E_T_ = ' ' "
			cQuery +=    " AND NVE.NVE_FILIAL = '" + xFilial("NVE") + "' "
			cQuery +=  " ORDER BY NVE_NUMCAS "
		EndIf
	EndIf

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cResQRY, .T., .F.)

	If !Empty((cResQRY)->NVE_NUMCAS)
		If lUsaLacuna

			While !(cResQRY)->(EOF())
				If !nMinNumero == Val( (cResQRY)->NVE_NUMCAS )
					Exit
				EndIf
				nMinNumero ++
				(cResQRY)->( dbSkip() )
			EndDo
			nNumero := nMinNumero

		Else

			While !(cResQRY)->(EOF())
				nNumero := Val( (cResQRY)->NVE_NUMCAS ) + 1
				(cResQRY)->( dbSkip() )
			EndDo

		EndIf
	EndIf

	If Empty(nNumero)
		cRet := StrZero( 1, 6 )
	Else
		cRet := StrZero( nNumero, 6 )
	EndIf

	(cResQRY)->(dbCloseArea())

	If !Empty(cRet) .And. !Empty(nNumero)

		If cNumClien == '1'
			If !MayIUseCode( 'NVE' + xFilial( 'NVE' ) + cCliente +  cLoja + cRet )
				lUsado := .T.
			EndIf
		Else
			If !MayIUseCode( 'NVE' + xFilial( 'NVE' ) + cRet )
				lUsado := .T.
			EndIf
		EndIf

		If lUsado
			nNumero++
			cRet := StrZero( nNumero, 6 )
		EndIf

	EndIf

EndIf

RestArea( aArea )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA070VNCAS
Rotina para validar se a numeração do caso ja existe, quando salvar

@author David Gonçalves Fernandes
@since 12/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA070VNCAS(oModel)
Local lRet      := .T.
Local cQuery    := ''
Local cCliente  := ''
Local cLoja     := ''
Local cCaso     := ''
Local cNumCas   := ''
Local cResQRY   := GetNextAlias()
Local aArea     := GetArea()
Local cNumClien := SuperGetMV( 'MV_JCASO1',, '1' ) // Seqüência da numeração do caso (1 - Por cliente / 2 - Independente)

Default oModel  := FWModelActive()

cCliente := oModel:GetValue("NVEMASTER", "NVE_CCLIEN")
cLoja    := oModel:GetValue("NVEMASTER", "NVE_LCLIEN")
cCaso    := oModel:GetValue("NVEMASTER", "NVE_NUMCAS")

If ExistBlock('J070NUM')
	cQuery := ExecBlock('J070NUM', .F., .F., { '2', cCliente, cCaso, cNumClien, .F. } )
Else
	cQuery := " SELECT NVE.NVE_CCLIEN, NVE_LCLIEN, NVE_NUMCAS "
	cQuery +=   " FROM " + RetSqlName( "NVE" ) + " NVE "
	cQuery +=  " WHERE NVE.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND NVE.NVE_FILIAL = '" + xFilial( "NVE" ) + "' "
	cQuery +=    " AND NVE_SITUAC = '1' "
	cQuery +=    " AND NVE_NUMCAS = '" + cCaso + "' "

	If (cNumClien == '1')
		cQuery += " AND NVE_CCLIEN = '" + cCliente + "' "
		cQuery += " AND NVE_LCLIEN = '" + cLoja + "' "
	EndIf
EndIf

cQuery := ChangeQuery(cQuery)

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cResQRY, .T., .T.)

If !Empty((cResQRY)->NVE_NUMCAS)
	cNumCas := JA070NUMER()
	lRet := JurMsgErro(STR0038 + cCliente + "/" + cLoja + STR0039 + cNumCas)
EndIf

(cResQRY)->(dbCloseArea())

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}JA070ENCER
Rotina para validar o encerramento do caso

@author David Gonçalves Fernandes
@since 14/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA070ENCER(oModel)
Local lRet      := .T.
Local oModelNVE := oModel:GetModel("NVEMASTER")

If oModel:GetOperation() == OP_ALTERAR

	If ( oModelNVE:GetValue("NVE_SITUAC") == '2' ) .And. !Empty(NVE->NVE_SITUAC) .And.;
	   ( oModelNVE:GetValue("NVE_SITUAC") != NVE->NVE_SITUAC )

		If Empty( oModelNVE:GetValue("NVE_DETENC") )
			lRet := JurMsgErro(STR0043) // "O motivo de encerramento do caso deve ser preenchido" 
		EndIf

		If Empty( oModelNVE:GetValue("NVE_CPART3") )
			lRet := JurMsgErro(STR0044) // "O participante de encerramento do caso deve ser preenchido" 
		EndIf

		If lRet
			//Verifica se o conteudo do campo já está preenchido para não atualizar
			If Empty(oModelNVE:GetValue("NVE_DTENCE"))
				If !oModelNVE:SetValue( "NVE_DTENCE", Date() )
					lRet := JurMsgErro(STR0045) // "Não foi possível preencher a data de encerramento"
				EndIf
			EndIf
		EndIf

	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA070REABR
Rotina para validar a reabertura do caso

@author David Gonçalves Fernandes
@since 14/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA070REABR(oModel)
Local lRet      := .T.
Local oModelNVE := oModel:GetModel("NVEMASTER")

If oModel:GetOperation() == OP_ALTERAR

	If ( oModelNVE:GetValue("NVE_SITUAC") == '1' ) .And. !Empty(NVE->NVE_SITUAC) .And.;
	   ( oModelNVE:GetValue("NVE_SITUAC") != NVE->NVE_SITUAC )

		If Empty( oModelNVE:GetValue("NVE_DETREA") )
			lRet := JurMsgErro(STR0046) // "O motivo de reabertura do caso deve ser preenchido"
		EndIf

		If Empty( oModelNVE:GetValue("NVE_CPART4") )
			lRet := JurMsgErro(STR0047) // "O participante de reabertura do caso deve ser preenchido"
		EndIf

		// Verifica se o conteúdo do campo já está preenchido
		If lRet .And. Empty(oModelNVE:GetValue("NVE_DTREAB")) .And. !oModelNVE:SetValue( "NVE_DTREAB", Date() )
			lRet := JurMsgErro(STR0048) // "Não foi possível preencher a data de reabertura"
		EndIf

	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA070ENCOB
Rotina para validar se há lançamentos pendentes quando encerrar a
Cobrança do caso

@author David Gonçalves Fernandes
@since 14/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA070ENCOB(oModel)
Local lAviso    := .T.
Local cQuery    := ''
Local cResQRY   := ''
Local aArea     := GetArea()
Local oModelNVE := oModel:GetModel("NVEMASTER" )
Local cAviso    := ""

cCliente := oModel:GetValue("NVEMASTER", "NVE_CCLIEN")
cLoja    := oModel:GetValue("NVEMASTER", "NVE_LCLIEN")
cCaso    := oModel:GetValue("NVEMASTER", "NVE_NUMCAS")

// Honorário
If ( oModelNVE:GetValue("NVE_ENCHON") == '1' ) .And. ( NVE->NVE_ENCHON == '2' )
	cQuery := " SELECT COUNT(NUE.NUE_CCASO) COUNTTS "
	cQuery +=   " FROM " + RetSqlName( "NUE" ) + " NUE "
	cQuery +=  " WHERE NUE.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND NUE.NUE_FILIAL = '" + xFilial( "NVE" ) + "' "
	cQuery +=    " AND NUE.NUE_CCLIEN = '" + cCliente + "' "
	cQuery +=    " AND NUE.NUE_CLOJA  = '" + cLoja + "' "
	cQuery +=    " AND NUE.NUE_CCASO  = '" + cCaso + "' "
	cQuery +=    " AND NUE.NUE_SITUAC = '1' "

	cQuery := ChangeQuery(cQuery)

	cResQRY   := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cResQRY, .T., .T.)

	If (cResQRY)->COUNTTS > 0
		lAviso := .F.
		cAviso := STR0040 + CRLF // "Há time sheets pendentes para este caso."
	EndIf

	(cResQRY)->(dbCloseArea())

EndIf


// Serviços tabelados
If ( oModelNVE:GetValue("NVE_ENCTAB") == '1' ) .And. ( NVE->NVE_ENCTAB == '2' )
	cQuery := " SELECT COUNT(NV4.NV4_CCASO) COUNTLAN "
	cQuery +=   " FROM " + RetSqlName( "NV4" ) + " NV4 "
	cQuery +=  " WHERE NV4.D_E_L_E_T_ = ' '
	cQuery +=    " AND NV4.NV4_FILIAL = '" + xFilial( "NVE" ) + "' "
	cQuery +=    " AND NV4.NV4_CCLIEN = '" + cCliente + "' "
	cQuery +=    " AND NV4.NV4_CLOJA  = '" + cLoja + "' "
	cQuery +=    " AND NV4.NV4_CCASO  = '" + cCaso + "' "
	cQuery +=    " AND NV4.NV4_SITUAC = '1' "

	cQuery := ChangeQuery(cQuery)

	cResQRY := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cResQRY, .T., .T.)

	If (cResQRY)->COUNTLAN > 0
		lAviso := .F.
		cAviso += STR0042 // "Há lançamentos tabelados pendentes para este caso." 
	EndIf

	(cResQRY)->(dbCloseArea())

EndIf

RestArea( aArea )

If !lAviso
	Alert(cAviso)
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JA070DTENC
Rotina para limpar a data de Encerramento

@author Felipe Bonvicini Conti
@since 02/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA070DTENC()
Local dData

Do Case
	Case M->NVE_SITUAC == '1' // Em andamento
		dData := ''

	Case M->NVE_SITUAC == '2' // Encerrado
		dData := IIF(Empty(NVE->NVE_DTENCE), Date(), NVE->NVE_DTENCE)
EndCase

Return dData

//-------------------------------------------------------------------
/*/{Protheus.doc} JA070DTREAB
Rotina para limpar a data de Reabertura

@author Felipe Bonvicini Conti
@since 02/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA070DTREAB()
Local dData

Do Case
	Case M->NVE_SITUAC == '1' // Em andamento
		dData := IIF(Empty(NVE->NVE_DTREAB), Date(), NVE->NVE_DTREAB)

	Case M->NVE_SITUAC == '2' // Encerrado
		dData := ''
EndCase

Return dData

//-------------------------------------------------------------------
/*/{Protheus.doc} JA070CLIEN
Rotina para validar se o cliente pode incluir casos

@author Felipe Bonvicini Conti
@since 05/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA070CLIEN(oModel)
Local lRet := .T.

If oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4

	NUH->(DBSetOrder(1))
	NUH->(DBSeek(xFILIAL('NUH') + M->NVE_CCLIEN + M->NVE_LCLIEN))

	If NUH->NUH_AJNV == '2'
		lRet := JurMsgErro(STR0019) // "Este cliente não permite a inclusão de casos."
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J070F3GRUPO
Rotina específica para a consulta padrão do grupo.

@author Felipe Bonvicini Conti
@since 09/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function J070F3GRUPO()
Local lRet := .T.

If !Empty(M->NVE_CCLIEN)
	SA1->(DBSetOrder(1))
	SA1->(DBSeek(xFILIAL('SA1') + M->NVE_CCLIEN + M->NVE_LCLIEN))

	lRet := IIF(Empty(SA1->A1_GRPVEN), .T., ACY->ACY_GRPVEN == SA1->A1_GRPVEN)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J070GRUPO
Rotina utilizada para setar o grupo referente ao cliente.

@author Felipe Bonvicini Conti
@since 09/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function J070GRUPO()
Local cQuery   := ''
Local cResQRY  := GetNextAlias()
Local aArea    := GetArea()
Local oModel   := FWModelActive()
Local cCliente := ''
Local cLoja    := ''
Local cRet     := ''

cCliente := oModel:GetValue("NVEMASTER", "NVE_CCLIEN")
cLoja    := oModel:GetValue("NVEMASTER", "NVE_LCLIEN")

cQuery += " SELECT A1_GRPVEN "
cQuery +=   " FROM " + RetSqlName("SA1") + " SA1 "
cQuery +=  " WHERE SA1.D_E_L_E_T_ = ' ' "
cQuery +=    " AND SA1.A1_FILIAL = '" + xFilial( "SA1" ) + "' "
cQuery +=    " AND A1_COD  = '" + cCliente + "' "
cQuery +=    " AND A1_LOJA = '" + cLoja + "' "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cResQRY, .T., .T.)

cRet := (cResQRY)->A1_GRPVEN

(cResQRY)->(dbCloseArea())

RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J070VALNUM
Rotina utilizada para setar o grupo referente ao cliente.

@author Felipe Bonvicini Conti
@since 09/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function J070VALNUM()
Local lRet        := .T.
Local oModelSAVE  := Nil
Local oModelNow   := FWModelActive()
Local oModel      := Nil

If SuperGetMV( 'MV_JCASO1',, '1' ) == '1' // Seqüência da numeração do caso (1 - Por cliente / 2 - Independente)

	If (oModelNow:cId != 'JURA070')   // Se o Model que vier carregado for diferente do JURA070
		oModelSave := FWModelActive() // Salva o contexto do modelo

		oModel := FWLoadModel( 'JURA070' )
		oModel:Activate()

		lRet := !Empty(oModel:GetValue("NVEMASTER", "NVE_CCLIEN")) .And. !Empty(oModel:GetValue("NVEMASTER", "NVE_LCLIEN"))

		FWModelActive(oModelSAVE, .T.) // Restaura o contexto do modelo
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J070F3GRUPO
Rotina específica para a consulta padrão de Cliente/Loja

@author Felipe Bonvicini Conti
@since 09/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function J070F3CLI()
Local lRet := .T.

If !Empty(M->NVE_CGRPCL)
	lRet := SA1->A1_GRPVEN == M->NVE_CGRPCL
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J70GATICASO
Função utilizada para o gatilho do campo NUT_CCASO.

@author Felipe Bonvicini Conti
@since 17/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function J70GATICASO()
Local cTitulo   := ""
Local aArea     := GetArea()
Local aAreaNVE  := NVE->( GetArea() )
Local cNumClien := SuperGetMV( 'MV_JCASO1',, '1' ) // Seqüência da numeração do caso (1 - Por cliente / 2 - Independente)
Local oModel    := FWModelActive()
Local bFiltro
Local cFiltro   := ""

If FWIsInCallStack('JURA096') .Or. oModel:GetId() == "JURA096" .Or. FWIsInCallStack('JURA056')
	cFiltro := NVE->( dbFilter() )
	bFiltro := IIf(!Empty(cFiltro), &('{|| ' + AllTrim(cFiltro) + '}'), '')
	NVE->( dbClearFilter() )
	If cNumClien == "1" // 1 - Por cliente

		NVE->(dbsetorder(1))
		If NVE->(DBSeek(xFilial("NVE") + FwFldGet('NUT_CCLIEN') + FwFldGet('NUT_CLOJA') + FwFldGet('NUT_CCASO')))
			cTitulo := NVE->NVE_TITULO
		EndIf

	Else // 2 - Independente

		lRet := ExistCpo('NVE', FwFldGet('NUT_CCASO'), 3)
		lRet := lRet .And. JAEXECPLAN("NUTDETAIL", "", "NUT_CCLIEN", "NUT_CLOJA", "NUT_CCASO", "NUT_CCASO")
		If lRet
			oModel:LoadValue("NUTDETAIL", "NUT_DCLIEN", JurGetDados("SA1", 1, xFilial("SA1") + FwFldGet('NUT_CCLIEN') + FwFldGet('NUT_CLOJA'), "A1_NOME"))
			cTitulo := JurGetDados("NVE", 1, xFilial("NVE") + FwFldGet('NUT_CCLIEN') + FwFldGet('NUT_CLOJA') + FwFldGet('NUT_CCASO'), "NVE_TITULO")
		EndIf

	EndIf

ElseIf FWIsInCallStack('JURA070')
	cTitulo := FwFldGet('NVE_TITULO')
EndIf

If !Empty(cFiltro)
	NVE->(dbSetFilter(bFiltro, cFiltro))
EndIf

RestArea(aAreaNVE)
RestArea(aArea)

Return IIF(cTitulo == NIL, "", cTitulo)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA070CONTR
Rotina para validar o relacionamento com contrato

@author Felipe Bonvicini Conti
@since 05/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA070CONTR()
Local nI        := 0
Local lRet      := .T.
Local oModel    := FwModelActive()
Local oModelNUT := oModel:GetModel("NUTDETAIL")
Local aHora     := {}
Local aDesp     := {}
Local aTab      := {}
Local aArea     := GetArea()
Local cErro     := ""
Local cSolucao  := ""
Local cContr    := ""
Local lAddHora  := .F.
Local lAddDesp  := .F.
Local lAddTab   := .F.

If oModel:GetOperation() == OP_INCLUIR .Or. oModel:GetOperation() == OP_ALTERAR

	NT0->(DBSetOrder(1))
	For nI := 1 To oModelNUT:GetQtdLine()
		oModelNUT:GoLine(nI)

		lAddHora := .F. // Indica se foi adicionado um contrato no array aHora
		lAddDesp := .F. // Indica se foi adicionado um contrato no array aDesp
		lAddTab  := .F. // Indica se foi adicionado um contrato no array aTab

		If !oModelNUT:IsDeleted()

			If NT0->(DBSeek(xFilial("NT0") + oModelNUT:GetValue("NUT_CCONTR")))

				If !Empty(NT0->NT0_CTPHON) .And. NT0->NT0_ATIVO == "1"
					NRA->(DBSetOrder(1))
					If NRA->(DBSeek(xFilial("NRA") + NT0->NT0_CTPHON)) .And. NRA->NRA_COBRAH == '1'
						aAdd(aHora, oModelNUT:GetValue("NUT_CCONTR"))
						lAddHora := .T.
					EndIf
				EndIf

				If NT0->NT0_DESPES == "1" .And. NT0->NT0_ATIVO == "1"
					aAdd(aDesp, oModelNUT:GetValue("NUT_CCONTR"))
					lAddDesp := .T.
				EndIf

				If NT0->NT0_SERTAB == "1" .And. NT0->NT0_ATIVO == "1"
					aAdd(aTab, oModelNUT:GetValue("NUT_CCONTR"))
					lAddTab := .T.
				EndIf

			EndIf

			J070CPYCnt(oModel)

		Else
			cContr := _aCnt070[nI][2]

			If !_aCnt070[nI][3] .And. J070UltCs(oModelNUT:GetValue("NUT_CCLIEN", nI), oModelNUT:GetValue("NUT_CLOJA", nI),;
			   oModelNUT:GetValue("NUT_CCASO", nI), cContr, .T.)
				lRet  := .F.
				cErro := (STR0098 + cContr + STR0099) //"O contrato "+cContr+ ##" " não pode ser removido pois estará sem nenhum vínculo com os casos! ""
			Else
				J070CPYCnt(oModel)
			EndIf

 		EndIf

		If lRet
			If (Len(aHora) > 1 .Or. Len(aDesp) > 1 .Or. Len(aTab) > 1)
				cErro := J070VldVig(oModelNUT, aHora, aDesp, aTab, lAddHora, lAddDesp, lAddTab)
				If !Empty(cErro)
					lRet     := .F.
					cSolucao := STR0174 // "Verifique a forma de cobrança do contrato ou ajuste o período de vigência."
				EndIf
			EndIf
		Else
			Exit
		EndIf

	Next nI
	
EndIf

If !lRet
	JurMsgErro(cErro,, cSolucao)
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J70VLRAJUST
Rotina para ajuste de valor de categoria e participante

@author Felipe Bonvicini Conti
@since 23/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function J70VLRAJUST(cAliasTab, oModel)
Local nValor       := 0
Local cCateg       := ""
Local cTabela      := ""
Local lAcumulativo := .F.
Local nValor1      := ""
Local nValor2      := ""
Local cRegra       := ""

Default oModel     := FWModelActive()

nValor1 := oModel:GetValue(cAliasTab + "DETAIL", cAliasTab + "_VALOR1")
nValor2 := oModel:GetValue(cAliasTab + "DETAIL", cAliasTab + "_VALOR2")
cRegra  := oModel:GetValue(cAliasTab + "DETAIL", cAliasTab + "_REGRA")
cCateg  := oModel:GetValue(cAliasTab + "DETAIL", cAliasTab + "_CCAT")
cTabela := oModel:GetValue("NVEMASTER", "NVE_CTABH")

If cAliasTab == "NV2" .Or. cAliasTab == "NV0"
	lAcumulativo := FwFldGet(cAliasTab + "_EXCCAT") == "1"
EndIf

Do Case
Case cRegra == "1" // Percentual
	nValor := nValor1 + (nValor1 * (nValor2/100))
Case cRegra == "2" // Soma
	nValor := nValor1 + nValor2
Case cRegra == "3" // Fixo
	nValor := nValor2
Case cRegra == "4" // Categoria
	nValor := J70TABVAL(cTabela, cCateg, lAcumulativo, oModel)
EndCase

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} JA070VNV2
Rotina para validar a categoria da exceção de Exceção da Tabela de Honorários

@author Felipe Bonvicini Conti
@since 23/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA070VNV2(oModel, cAliasTab)
Local lRet  := .T.
Local nI    := 0
Local oGrid := Nil

If oModel:GetOperation() == OP_INCLUIR .Or. oModel:GetOperation() == OP_ALTERAR

	oGrid := oModel:GetModel(cAliasTab + "DETAIL")
	For nI := 1 To oGrid:Length()
		If !oGrid:IsDeleted(nI) .And. oGrid:GetValue(cAliasTab + "_REGRA", nI) == '4'
			If !Empty(oGrid:GetValue(cAliasTab + "_CPART", nI)) .And. Empty(oGrid:GetValue(cAliasTab + "_CCAT", nI))
				lRet := JurMsgErro(STR0029) // " Exceção na Tab honorários(Participante): O valor da categoria deve estar preenchido
			EndIf                           //   quando a regra estiver definida como 'Categoria' "
		EndIf
	Next
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J70ATUCATEG
Rotina para atualizar os campos das categorias.

@author Felipe Bonvicini Conti
@since 26/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function J70AtuCateg(oModel, cAliasTab)
Local oModelNUW   := Nil
Local oModelNV0   := Nil
Local nI          := 0
Local nLinNUWOld  := 0
Local nLinNV0Old  := 0

Default oModel    := FWModelActive()
Default cAliasTab := ""

oModelNUW := oModel:GetModel("NUWDETAIL")
oModelNV0 := oModel:GetModel("NV0DETAIL")

If oModel:GetOperation() == OP_INCLUIR .Or. oModel:GetOperation() == OP_ALTERAR .Or. oModel:GetOperation() == MODEL_OPERATION_VIEW // Inclusão / Alteração / Visualização

	If Empty(cAliasTab) .Or. cAliasTab == "NUW"
		nLinNUWOld := oModelNUW:nLine
		For nI := 1 To oModelNUW:GetQtdLine()
			oModelNUW:GoLine(nI)
			If !oModelNUW:IsDeleted()
				J70SetCateg("NUW", oModel)
			EndIf
		Next
		oModelNUW:GoLine(nLinNUWOld)
	EndIf

	If Empty(cAliasTab) .Or. cAliasTab == "NV0"
		nLinNV0Old := oModelNV0:nLine
		For nI := 1 To oModelNV0:GetQtdLine()
			oModelNV0:GoLine(nI)
			If !oModelNV0:IsDeleted() .And. !Empty(oModel:GetValue("NV0DETAIL", "NV0_CPART"))
				J70SetCateg("NV0", oModel)
			EndIf
		Next
		oModelNV0:GoLine(nLinNV0Old)
	EndIf

EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J70SetCateg
Rotina para setar os campos de categoria.

@author Felipe Bonvicini Conti
@since 26/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J70SetCateg(cAliasTab, oModel)
Local nOpc := oModel:GetOperation()

If !Empty(oModel:GetValue(cAliasTab + "DETAIL", cAliasTab + "_CCAT"))
	If nOpc == 1
		oModel:LoadValue(cAliasTab + "DETAIL", cAliasTab + "_VALOR1", JURA070VL0(cAliasTab, oModel))
		oModel:LoadValue(cAliasTab + "DETAIL", cAliasTab + "_VALOR3", J70VLRAJUST(cAliasTab, oModel))
	Else
		oModel:SetValue(cAliasTab + "DETAIL", cAliasTab + "_VALOR1", JURA070VL0(cAliasTab, oModel))
		oModel:SetValue(cAliasTab + "DETAIL", cAliasTab + "_VALOR3", J70VLRAJUST(cAliasTab, oModel))
	EndIf
EndIf

If cAliasTab == "NV2" .Or. cAliasTab == "NV0"
	If nOpc == 1
		oModel:LoadValue(cAliasTab + "DETAIL", cAliasTab + "_DCAT1", J70GATDCAT(cAliasTab))
		oModel:LoadValue(cAliasTab + "DETAIL", cAliasTab + "_VALOR1", JURA070VL0(cAliasTab))
		oModel:LoadValue(cAliasTab + "DETAIL", cAliasTab + "_VALOR3", J70VLRAJUST(cAliasTab))
	Else
		oModel:SetValue(cAliasTab + "DETAIL", cAliasTab + "_DCAT1", J70GATDCAT(cAliasTab))
		oModel:SetValue(cAliasTab + "DETAIL", cAliasTab + "_VALOR1", JURA070VL0(cAliasTab))
		oModel:SetValue(cAliasTab + "DETAIL", cAliasTab + "_VALOR3", J70VLRAJUST(cAliasTab))
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J70GATDCAT
Rotina para o gatilho do campo de categoria

@author Felipe Bonvicini Conti
@since 26/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function J70GATDCAT(cTab)
Local oModel
Local cCateg
Local cSQL
Local aSQL

If cTab = "NV0"
	oModel := FWModelActive()

	cSQL := " SELECT NUS_CCAT "
	cSQL += " FROM " + RetSqlname('NUS') + " NUS "
	cSQL += " WHERE NUS_FILIAL = '" + xFilial("NUS") + "' "
	cSQL +=   " AND NUS.D_E_L_E_T_ = ' ' "
	cSQL +=   " AND ((NUS_AMINI <= '" + FwFldGet('NV0_AMINI') + "' And NUS_AMFIM >= '" + FwFldGet('NV0_AMINI') + "' ) Or "
	cSQL +=        " (NUS_AMINI <= '" + FwFldGet('NV0_AMINI') + "' And (NUS_AMFIM  = '" + FwFldGet('NV0_AMFIM') + "' OR NUS_AMFIM  = '" + CriaVar("NUS_AMFIM", .F.) + "' ) ) ) "
	cSQL +=   " AND NUS_CPART = '" + FwFldGet(cTab + "_CPART") + "' "
	aSql := JurSQL(cSQL, {"NUS_CCAT"}) //Pegar a categoria pelo histórico do participante

	cCateg := IIf(!Empty(aSql), aSql[1][1], "")
EndIf

If Empty(cCateg)
	cCateg := JurGetDados("NUR", 1, xFilial("NUR") + FwFldGet(cTab + "_CPART"), "NUR_CCAT")
EndIf

Return JurGetDados("NRN", 1, xFilial("NRN") + cCateg, "NRN_DESC")

//-------------------------------------------------------------------
/*/{Protheus.doc} JA070VLDCP
Rotina para validar o campo de tipo de originação

@author Felipe Bonvicini Conti
@since 14/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA070VLDCP(cStrunt, cCampo)
Local lRet := .T.

lRet := JAVLDCAMPO(cStrunt, cCampo, 'NRI', 'NRI_ATIVO', '1') .And. ( JAVLDCAMPO(cStrunt, cCampo, 'NRI', 'NRI_TIPO', '2') .Or. ;
        JAVLDCAMPO(cStrunt, cCampo, 'NRI', 'NRI_TIPO', '3') )

If !lRet
	JurMsgErro( STR0034 ) // "Código inválido"
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA070VPART
Valida se há participações obrigatórias não preenchidas
Valida se os percentuais de participação e os participantes
correspondem aos parâmestros do tipo de originação

@return lRet A validação está ok

@author Felipe Bonvicini Conti
@since 14/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA070VPART(oModel)
Local lRet      := .T.
Local oModelNUK := oModel:GetModel("NUKDETAIL")
Local oModelNVF := oModel:GetModel("NVFDETAIL")
Local nPos      := 0
Local nI        := 0
Local cResQRY   := GetNextAlias()
Local aAreaSA1  := SA1->( GetArea() )
Local aAreaNUH  := NUH->( GetArea() )
Local aArea     := GetArea()
Local cQuery    := ''

If !(oModel:GetOperation() == 5)

	cQuery := " SELECT NRI.NRI_COD, NRI.NRI_DESC "
	cQuery +=   " FROM " + RetSqlName("NRI") + " NRI "
	cQuery +=  " WHERE NRI.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND NRI.NRI_FILIAL = '" + xFilial("NRI") + "' "
	cQuery +=    " AND ( NRI.NRI_TIPO = '2' OR NRI.NRI_TIPO = '3' )"
	cQuery +=    " AND NRI.NRI_ATIVO  = '1' "
	cQuery +=    " AND NRI.NRI_OBRIGA = '1' "

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cResQRY, .T., .T.)

	cMsg := STR0035 + CRLF

	While !(cResQRY)->(EOF())

		nPos := 0
		For nI := 1 To oModelNUK:GetQtdLine()
			If oModelNUK:GetValue("NUK_CTIPO", nI) == (cResQRY)->NRI_COD
				nPos := nI
			EndIf
		Next

		If nPos == 0 .Or. ( nPos > 0 .And. JModelGoLn(oModelNUK, nPos) .And. oModelNUK:IsDeleted() )
			cMsg += (cResQRY)->NRI_COD + " - " + AllTrim( (cResQRY)->NRI_DESC) + ". " + CRLF
			lRet := .F.
		EndIf
		(cResQRY)->( dbSkip() )
	End

	If lRet
		cMsg := J070VldPerc(oModelNUK, "NUK_MARCA", "NUK_CTIPO", "NUK_DTIPO", "NUK_PERC", "NUK_CPART")
		lRet := Empty(cMsg)
	EndIf

	If lRet
		If !(__InMsgRun)
			FWMsgRun( , {|| cMsg := J070VldMarc(oModelNVF)}, STR0101, STR0173) // "Aguarde..." ### "Validando percentuais."
		Else
			cMsg := J070VldMarc(oModelNVF)
		EndIf
		lRet := Empty(cMsg)
	EndIf

	If !lRet
		JurMsgErro( cMsg )
	EndIf

	(cResQRY)->( dbCloseArea() )

	RestArea(aAreaNUH)
	RestArea(aAreaSA1)
	RestArea(aArea)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA070VERPRE
Rotina para validar se existe pré-fatura para o Caso

@author Jacques Alves Xavier
@since 25/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA070VERPRE(oModel)
Local lRet     := .T.
Local cQuery   := ''
Local aArea    := GetArea()
Local cResQRY  := GetNextAlias()

cQuery := "SELECT DISTINCT NX0.NX0_COD, NX0.NX0_SITUAC "
cQuery +=  " FROM " + RetSqlName("NX0") + " NX0 "
cQuery += " INNER JOIN " + RetSqlName("NX1") + " NX1 "
cQuery +=    " ON NX0.NX0_FILIAL = NX1.NX1_FILIAL "
cQuery +=   " AND NX0.NX0_COD = NX1.NX1_CPREFT "
cQuery += " WHERE NX0.D_E_L_E_T_ = ' ' "
cQuery +=   " AND NX1.D_E_L_E_T_ = ' ' "
cQuery +=   " AND NX0.NX0_FILIAL = '" + xFilial( "NVE" ) + "' "
cQuery +=   " AND NX0.NX0_SITUAC IN ('2','4','5','6') "
cQuery +=   " AND NX1.NX1_CCLIEN = '" + M->NVE_CCLIEN + "'"
cQuery +=   " AND NX1.NX1_CLOJA = '" + M->NVE_LCLIEN + "'"
cQuery +=   " AND NX1.NX1_CCASO = '" + M->NVE_NUMCAS + "'"

cQuery := ChangeQuery(cQuery)

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cResQRY, .T., .T.)

If !Empty((cResQRY)->NX0_COD)
	If ApMsgYesNo(STR0049) // Existe pré-fatura para este Caso. Deseja apagar a pré-fatura para efetuar a alteração?.
		JA202CANPF((cResQRY)->NX0_COD)
	Else
		lRet := JurMsgErro(STR0050) // Não foi possível realizar as alterações!
	EndIf
EndIf

(cResQRY)->( dbcloseArea() )

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J70ATUNT7
Rotina para Atualizar o valor do campo revisado da tabela NT7

@author Felipe Bonvicini Conti
@since 02/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J70ATUNT7(oModelNT7)
Local nQtd     := oModelNT7:GetQtdLine()
Local nLineOld := oModelNT7:GetLine()
Local nI       := 0

If !oModelNT7:IsEmpty()
	For nI:=1 To nQtd
		If !oModelNT7:IsDeleted(nI) .And. !oModelNT7:IsFieldUpdated("NT7_TITULO", nI)
			oModelNT7:GoLine(nI)
			oModelNT7:SetValue("NT7_REV", "2")
		EndIf
	Next
EndIf

oModelNT7:GoLine(nLineOld)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J070ValCpo
Validação dos campos: Grupo, Cliente e Loja

@return   lRet  .T. ou .F.

@author Jacques Alves Xavier
@since 11/05/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function J070ValCpo()
Local lRet := .T.
Local oModel  := FwModelActive()
Local cGrupo  := ''
Local cClien  := ''
Local cLoja   := ''

If (oModel:cId != 'JURA070') // Se o Model que vier carregado for diferente do JURA070, carrega o Modelo correspondente do JURA070
	oModel := FWLoadModel( 'JURA070' )
	oModel:Activate()
EndIf

cGrupo  := oModel:GetValue("NVEMASTER", "NVE_CGRPCL")
cClien  := oModel:GetValue("NVEMASTER", "NVE_CCLIEN")
cLoja   := oModel:GetValue("NVEMASTER", "NVE_LCLIEN")

If __ReadVar $ "M->NVE_CGRPCL"
	lRet := JurVldCli(cGrupo, cClien, cLoja,,, "GRP")

ElseIf __ReadVar $ "M->NVE_CCLIEN"
	lRet := JurVldCli(cGrupo, cClien, cLoja,,, "CLI")

ElseIf __ReadVar $ "M->NVE_LCLIEN"
	lRet := JurVldCli(cGrupo, cClien, cLoja,,, "LOJ")
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J70VACONTR
Função utilizada para validar o campo de contrato

@author Jacques Alves Xavier
@since 24/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function J70VACONTR(cTipo)
Local lRet      := .T.
Local aArea     := GetArea()
Local oModel    := Nil
Local oModelNUT := Nil
Local cCClien   := NVE->NVE_CCLIEN
Local cLClien   := NVE->NVE_LCLIEN
Local cNumCas   := NVE->NVE_NUMCAS
Local cContr    := ""
Local lUnico    := .F.
Local nPos      := 0

Do Case
Case cTipo == 'V'

	If lRet .And. FWIsInCallStack("JURA070") // validação para verificar se o contrato tem somente o caso em questão

		oModel    := FwModelActive()
		oModelNUT := oModel:GetModel('NUTDETAIL')
		nPos      := oModelNUT:GetLine()

		If !oModelNUT:IsInserted()

			cContr := _aCnt070[nPos][2]
			lUnico := J070UltCs(cCClien, cLClien, cNumCas, cContr, .T.)

			If lUnico
				lRet := JurMsgErro(STR0098 + cContr + STR0099 ) //"O contrato "+cContr+ ##" não pode ser removido pois estará sem nenhum vínculo com os casos! ""
			Else
				J070CPYCnt( oModel )
			EndIf

		Else
			J070CPYCnt( oModel )
		EndIf

	EndIf

EndCase

If !lUnico
	If lRet .And. FwFldGet("NVE_COBRAV") == "2"
		lRet := JurMsgErro(STR0089) //"Este caso não pode ser vinculado a nenhum contrato, pois é um caso não cobrável."
	EndIf
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J70TABVAL
Função utilizada para retornar o valor conforme tabela de honorários.

@author Roberto Vagner Gomes
@since 31/03/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J70TABVAL(cTabela, cCategoria, lAcumulativo, oModel)
Local nValor := JA070VLCAT(cTabela, cCategoria, FwFldGet('NV0_AMINI'), FwFldGet('NV0_AMFIM'))

If lAcumulativo

	If !Empty(JFindMdlM(oModel:GetModel("NUWDETAIL"), ;
			"(FwFldGet('NUW_CCAT') == '" + FwFldGet('NV0_CCAT') + "' ) .And. " +;
			"((FwFldGet('NUW_AMINI') <= '" + FwFldGet('NV0_AMINI') + "'.And.FwFldGet('NUW_AMFIM') >= '" + FwFldGet('NV0_AMINI') + "').Or." +;
			"(FwFldGet('NUW_AMINI') <= '" + FwFldGet('NV0_AMINI') + "'.And.FwFldGet('NUW_AMFIM')  = '" + FwFldGet('NV0_AMFIM') + "'))", ;
			{"NUW_AMINI"}))
		nValor := JFindMdlM(oModel:GetModel("NUWDETAIL"), ;
			"(FwFldGet('NUW_CCAT') == '" + FwFldGet('NV0_CCAT') + "' ) .And. "+;
			"((FwFldGet('NUW_AMINI') <= '" + FwFldGet('NV0_AMINI') + "'.And.FwFldGet('NUW_AMFIM') >= '" + FwFldGet('NV0_AMINI') + "').Or." +;
			"(FwFldGet('NUW_AMINI') <= '" + FwFldGet('NV0_AMINI') + "'.And.FwFldGet('NUW_AMFIM')  = '" + FwFldGet('NV0_AMFIM') + "'))", ;
			{"NUW_VALOR3"})[1]
	EndIf

EndIf

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} JA070REVAL()
Revaloriza os Time-Sheets dos casos

@author Tiago Martins
@since 06/07/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA070REVAL(lAutomato)
	Local aArea       := GetArea()
	Local cQuery      := ""
	Local cQueryRes   := Nil
	Local cCodPreTS   := ""
	Local oModel      := FwLoadModel("JURA070")
	Local lOk         := .T.
	Local cCClien     := NVE->NVE_CCLIEN
	Local cLClien     := NVE->NVE_LCLIEN
	Local cNumCas     := NVE->NVE_NUMCAS
	Local cLCPRE      := JurGetDados("NUR", 1, xFilial("NUR") + JurUsuario(__CUSERID), "NUR_LCPRE")
	Local cCodTS      := ''
	Local cCodTSReval := ''
	Local cCodTSPre   := ''
	Local cMsg        := ''
	Local cCodTSErro  := ''
	Local lLiberaTudo := .F.
	Local lLibAltera  := .F.
	Local lContinua   := .T.
	Local lLibParam   := .T. //Se MV_JCORTE preenchido corretamente
	Local aRetBlqTS   := {}
	Local aTimeSheets := {}
	Local lAltHr      := NUE->(ColumnPos('NUE_ALTHR')) > 0

	Default lAutomato := .F.

	oModel:SetOperation(4)

	If lAutomato .OR. ApMsgYesNo(STR0066) //"Deseja revalorizar os Time-Sheets dos casos do contrato selecionado?"

		cQuery    := " SELECT NUE.NUE_COD, NUE.NUE_CPREFT, NUE.NUE_DATATS, NUE.R_E_C_N_O_ NUERECNO "
		cQuery    +=   " FROM " + RetSqlName("NUE") + " NUE "
		cQuery    +=   " WHERE NUE.D_E_L_E_T_ = ' ' "
		cQuery    +=     " AND NUE.NUE_FILIAL = '" + xFilial( "NT0" ) + "' "
		cQuery    +=     " AND NUE.NUE_SITUAC = '1' "
		cQuery    +=     " AND NUE.NUE_CCLIEN = '" + cCClien + "' "
		cQuery    +=     " AND NUE.NUE_CLOJA = '" + cLClien + "' "
		cQuery    +=     " AND NUE.NUE_CCASO = '" + cNumCas + "' "
		cQuery    +=     " AND NUE.NUE_CPREFT > '" + Space(TamSx3('NUE_CPREFT')[1]) + "' "

		cQueryRes := GetNextAlias()
		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cQueryRes, .T., .T.)
		TcSetField((cQueryRes), "NUE_DATATS", "D", 8, 0)

		If !(cQueryRes)->(EOF())
			If cLCPRE == "1"
				If lAutomato .OR.  ApMsgYesNo(STR0067) // "Existe pré-fatura para este Caso. Deseja apagar a pré-fatura para efetuar a alteração?."
					While !(cQueryRes)->(EOF())
						If ASCAN(aTimeSheets, (cQueryRes)->NUE_CPREFT ) == 0
							If lLibParam
								aRetBlqTS := JBlqTSheet((cQueryRes)->NUE_DATATS)
							EndIf
							lLiberaTudo   := aRetBlqTS[1]
							lLibAltera    := aRetBlqTS[3]
							lLibParam     := aRetBlqTS[5]
							If lLiberaTudo .And. lLibAltera .And. lLibParam
								If JA202CANPF((cQueryRes)->NUE_CPREFT)
									J202HIST('5', (cQueryRes)->NUE_CPREFT, JurUsuario(__CUSERID)) //Insere o Histórico na pré-fatura // (cQueryRes)->NUE_CPREFT
									NUE->(DBGoTo((cQueryRes)->NUERECNO))
									RecLock( 'NUE', .F. )
									NUE->NUE_CPREFT := ''
									NUE->NUE_CUSERA := JurUsuario(__CUSERID)
									NUE->NUE_ALTDT  := Date()
									If lAltHr
										NUE->NUE_ALTHR  := Time()
									EndIf
									NUE->(MsUnlock())
									//Grava na fila de sincronização a alteração
									J170GRAVA("NUE", xFilial("NUE") + NUE->NUE_COD, "4")
									Aadd(aTimeSheets, (cQueryRes)->NUE_CPREFT)
								EndIf
							ElseIf !lLibParam
								Exit
							Else
								cCodPreTS := (cQueryRes)->NUE_CPREFT + CRLF
							EndIf
						EndIf
						(cQueryRes)->( dbSkip() )
					EndDo
					aTimeSheets := Nil
					lOk := .T.
				EndIf
			Else
				lOk := .F.
				Iif(!lAutomato, JurMsgErro(STR0148), Help( ,,, 'JA070REVAL', STR0148, 1, 0))  //"Não é possivel revalorizar o TSs pois há pré-fatura para o caso"\\Msg Confirmação da Valorização
			EndIf

		EndIf

		(cQueryRes)->(dbCloseArea())

		If lOk
			cQuery := " SELECT NUE_COD, NUE_CPART2, NUE_CCLIEN, NUE_CLOJA, NUE_CCASO, NUE_ANOMES, NUE_DATATS, NUE_CATIVI "
			cQuery +=   " FROM " + RetSqlName("NUE") + " NUE "
			cQuery +=  " WHERE NUE.D_E_L_E_T_ = ' ' "
			cQuery +=    " AND NUE.NUE_FILIAL = '" + xFilial( "NT0" ) + "' "
			cQuery +=    " AND NUE.NUE_SITUAC = '1' "
			cQuery +=    " AND NUE.NUE_CCLIEN = '" + cCClien + "' "
			cQuery +=    " AND NUE.NUE_CLOJA = '" + cLClien + "' "
			cQuery +=    " AND NUE.NUE_CCASO = '" + cNumCas + "' "
			cQuery +=    " AND NUE.NUE_CPREFT = '" + Space(TamSx3('NUE_CPREFT')[1]) + "' "

			cQueryRes := GetNextAlias()
			dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cQueryRes, .T., .T.)
			TcSetField((cQueryRes), "NUE_DATATS", "D", 8, 0)

			While !(cQueryRes)->(EOF())
				If lLibParam
					aRetBlqTS := JBlqTSheet((cQueryRes)->NUE_DATATS)
				EndIf
				lLiberaTudo   := aRetBlqTS[1]
				lLibAltera    := aRetBlqTS[3]
				lLibParam     := aRetBlqTS[5]
				lContinua     := .T.
				If !lLiberaTudo .And. !lLibAltera .And. lLibParam
					cCodTS += AllTrim((cQueryRes)->NUE_COD) + CRLF
					(cQueryRes)->( dbSkip() )
					Loop
				ElseIf !lLibParam
					Exit
				EndIf

				dbSelectArea('NUE')
				If NUE->(dbSeek(xFilial('NUE') + (cQueryRes)->NUE_COD) ) .And. NUE->NUE_SITUAC == '1'

					If !Empty(NUE->NUE_CPREFT)
						lContinua := !(JurGetDados("NX0", 1, xFilial("NX0") + aTimeSheets[nI, 2], "NX0_SITUAC") $ "C|F")
					EndIf

					If lContinua
						// Revaloriza TS - não considera o parâmetro
						aResult := JURA200((cQueryRes)->NUE_COD, (cQueryRes)->NUE_CPART2, (cQueryRes)->NUE_CCLIEN, (cQueryRes)->NUE_CLOJA, (cQueryRes)->NUE_CCASO, (cQueryRes)->NUE_ANOMES,, (cQueryRes)->NUE_CATIVI )

						If Len(aResult) == 3 .And. Empty(aResult[2]) .And. Empty(aResult[3])
							cCodTSErro += (cQueryRes)->NUE_COD + CRLF
						Else
							If (NUE->NUE_VALORH != aResult[2]) .Or. (NUE->NUE_CCATEG != aResult[3])
								cCodTSReval += (cQueryRes)->NUE_COD + CRLF

								RecLock("NUE", .F.)
								NUE->NUE_CMOEDA := aResult[1]
								NUE->NUE_VALORH := aResult[2]
								NUE->NUE_VALOR  := aResult[2] * NUE->NUE_TEMPOR
								NUE->NUE_CCATEG := aResult[3]
								NUE->NUE_CUSERA := JurUsuario(__CUSERID)
								NUE->NUE_ALTDT  := Date()
								If lAltHr
									NUE->NUE_ALTHR  := Time()
								EndIf
								NUE->(MsUnlock())

								// Grava na fila de sincronização
								J170GRAVA("NUE", xFilial("NUE") + NUE->NUE_COD, "4")
							EndIf
						EndIf
					Else
						cCodTSPre += AllTrim((cQueryRes)->NUE_COD) + CRLF
					EndIf
				EndIf

				(cQueryRes)->( dbSkip() )
			EndDo
			(cQueryRes)->(dbCloseArea())

			If ! Empty(cCodTSPre)
				cMsg := STR0159 + CRLF + AllTrim(cCodTSPre) + CRLF  // "Não foi possível a revalorização dos seguintes Time Sheets devido a vínculo com pré-fatura em revisão :"
			EndIf

			If ! Empty(cCodTSReval)
				cMsg := STR0085 + ": " + CRLF + AllTrim(cCodTSReval) + CRLF // "Time Sheet revalorizado"
			EndIf

			If ! Empty(cCodPreTS) .And. lLibParam
				cMsg += STR0149 + cCodPreTS + CRLF // "Por falta de permissão não será possível alterar e revalorizar os seguintes Time Sheets em Pré-Fatura: "
			EndIf

			If ! Empty(cCodTS) .And. lLibParam
				cMsg += STR0139 + cCodTS + CRLF // "Por falta de permissão não será possível alterar e revalorizar os seguintes Time Sheets: "
			EndIf

			If ! Empty(cCodTSErro)
				cMsg += STR0068 + CRLF + cCodTSErro // Erro na valorização do Time Sheet
			EndIf

			If ! Empty(cMsg)
				Iif(!lAutomato,JurErrLog(cMsg, STR0140), MsgInfo(cMsg,STR0140) ) // "Atenção"
			ElseIf lLibParam
				Iif(!lAutomato,MsgInfo(STR0141, STR0140),Help( ,,, STR0140, STR0141, 1, 0) ) // "Não há dados para revalorização de Time Sheets." ### "Atenção"
			EndIf

		EndIf
	EndIf

	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA070EXITC
Rotina para validar se o Caso possui na Aba Êxito a Fatura ou Condição

@author Tiago Martins
@since 12/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA070EXITC(oModel)
Local lRet      := .T.

If (oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4) .And. FwFldGet("NVE_EXITO") == "2" .And. JA070VlLinExi(oModel)
	lRet := JurMsgErro(STR0096) // "O campo Êxito está preenchido como Não. Apague os registros na aba de Êxito antes de confirmar ou ajuste o campo de Êxito para Sim."
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J070NUTPre
Pre Validacao da linha de Contratos x Casos

@param oView - View da rotina

@author Daniel Magalhaes
@since 13/07/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J070NUTPre(oView)
Local oModel    := FwModelActive()
Local oModelNUT := oModel:GetModel("NUTDETAIL")
Local lRet      := .T.

If oModel:GetOperation() == 3 .Or. oModelNUT:IsInserted() // Inclusão de caso ou inclusão de linha no grid de contrato x caso

	//Inicializa os campos de No. Caso, Cliente e Loja da tabela de Contratos x Casos (NUT)
	lRet := oModelNUT:LoadValue( "NUT_CCASO", FwFldGet("NVE_NUMCAS") )
	lRet := lRet .And. oModelNUT:LoadValue( "NUT_CCLIEN", FwFldGet("NVE_CCLIEN") )
	lRet := lRet .And. oModelNUT:LoadValue( "NUT_CLOJA" , FwFldGet("NVE_LCLIEN") )

	If !lRet
		JurMsgErro(STR0070) //"Erro ao incluir relacionamento entre contratos e casos. Preencha primeiramente os dados da pasta 'Caso'."
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J070NUTPos
Pos Validacao da linha de Contratos x Casos

@param oView - View da rotina

@author Daniel Magalhaes
@since 13/07/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J070NUTPos(oView)
Local lRet := .T.

lRet := JA070CONTR()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J70NUTPosF
Pos Validacao do formulario de Contratos x Casos

@param oView - View da rotina

@author Daniel Magalhaes
@since 13/07/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J70NUTPosF(oView)
Local aArea      := GetArea()
Local aAreaNT0   := NT0->( GetArea() )
Local lRet       := .T.
Local cQuery     := ""
Local cAliasQry  := GetNextAlias()
Local cCurrContr := ""
Local nNUT       := 0
Local cContrErr  := ""

// Caso seja exclusão da linha, verifica se o Contrato está ativo (NT0_ATIVO == "1")
// e verifica se a quantidade de Casos deste Contrato é menor ou igual a 1 (count NUT onde NUT_CCONTR == No. na View)
// lRet falso se afirmativo
For nNUT := 1 To oView:GetQtdLine()
	oView:GoLine(nNUT)

	If oView:IsDeleted() .And. !oView:IsInserted()

		cCurrContr := oView:GetValue("NUT_CCONTR")

		NT0->( DbSetOrder(1) )
		If NT0->( DbSeek( xFilial("NT0") + cCurrContr ) ) .And. NT0->NT0_ATIVO == "1"

			cQuery := " SELECT COUNT(NUT.R_E_C_N_O_) QTDE "
			cQuery += " from " + RetSqlName("NUT") + " NUT "
			cQuery += " where NUT.NUT_FILIAL = '" + xFilial("NUT") + "' "
			cQuery +=   " and NUT.NUT_CCONTR = '" + cCurrContr + "' "
			cQuery +=   " and not (NUT.NUT_CCLIEN = '" + oView:GetValue("NUT_CCLIEN") + "' "
			cQuery +=             " AND NUT.NUT_CLOJA = '" + oView:GetValue("NUT_CLOJA") + "' "
			cQuery +=             " AND NUT.NUT_CCASO = '" + oView:GetValue("NUT_CCASO") + "') "
			cQuery +=   " and NUT.D_E_L_E_T_ = ' '"

			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasQry, .T., .T.)

			//Verifica se este eh o ultimo caso do contrato ativo
			If ( (cAliasQry)->QTDE <= 0 )
				lRet := .F.
				cContrErr += IIf(Empty(cContrErr), "", ",") + cCurrContr
			EndIf

			(cAliasQry)->( DbCloseArea() )
		EndIf
	EndIf
Next nNUT

If !lRet
	JurMsgErro(STR0071 + cContrErr + STR0086 ) //"O(s) contrato(s): + cContrErr +  " não pode(m) ser removemovido(s) pois estará(ão) sem nenhum vínculo com o(s) caso(s)! "
EndIf

RestArea(aAreaNT0)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA070NoCont
Função utilizada para filtrar os casos que não possuem contrato vinculado.

@Param cGetGrup - Texto contendo o Grupo do cliente para o filtro
@Param cGetClie - Texto contendo o Código do cliente para o filtro
@Param cGetLoja - Texto contendo o Loja do cliente para o filtro
@Param lSemCon  - Filtro de casos sem contrato
@Param lCobHora - Filtro de casos por hora sem contrato
@Param lCobDesp - Filtro de casos com despesas sem contrato
@Param lCobTab  - Filtro de casos com tabelados sem contrato
@Param dDtIni -   Filtro de casos por data de entrada inicial
@Param dDtFim  -  Filtro de casos por data de entrada final

@author Clóvis Teixeira
@since 02/10/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA070NoCont(cGetGrup, cGetClie, cGetLoja, lSemCon, lCobHora, lCobDesp, lCobTab, dDtIni, dDtFim)
Local lRet       := .T.
Local nI         := 0
Local aFields    := {}
Local aOrder     := {}
Local aCoors     := {}
Local aTabTmp    := {}
Local oDlg       := Nil
Local cTabTmp    := ''
Local cQryNCnt   := ''
Local oTempTbCnt := Nil //Tabela temporária a ser criada
Local oBrwNCnt   := Nil
Local aStruAdic  := {}
Local aTmpFld    := {}
Local cLojaAuto  := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local lObfuscate := FindFunction("FwPDCanUse") .And. FwPDCanUse(.T.) // Indica se trabalha com Dados Protegidos e possui a melhoria de ofuscação de dados habilitada
Local aColumns   := {}

Begin Sequence
	If !lSemCon .And. !lCobHora .And. !lCobDesp .And. !lCobTab
		lRet := JurMsgErro(STR0153,, STR0133) //#"Nenhuma opção foi selecionada."  ##"Necessário marcar ao menos uma das situações."
		Break
	EndIf

	Aadd(aStruAdic, { STR0129, STR0129, "C", 100, 0, "@XS100"})

	cQryNCnt   := JA070QRY(lSemCon, lCobHora, lCobDesp, lCobTab, cGetGrup, cGetClie, cGetLoja, dDtIni, dDtFim)
	aTabTmp    := JurCriaTmp(GetNextAlias(), cQryNCnt, "NVE",, aStruAdic)

	oTempTbCnt := aTabTmp[1]
	aTmpFld    := aTabTmp[2]
	aOrder     := aTabTmp[3]
	cTabTmp    := oTempTbCnt:GetAlias()

	//Remover campos do browser
	Iif(cLojaAuto == "1", AEVAL(aTmpFld, {|aX| Iif(aX[1] $ "NVE_LCLIEN||NVE_CLJNV ",, Aadd(aFields, aX))}), aFields := aTmpFld)

	If !(cTabTmp)->(EOF())
		aCoors  := FWGetDialogSize( oMainWnd )
		Define MsDialog oDlg Title STR0124 FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] STYLE nOR(WS_VISIBLE, WS_POPUP) Pixel //"Casos sem vínculo com contrato"

		// Define o Browse
		Define FWFormBrowse oBrwNCnt DATA TABLE ALIAS (cTabTmp) DESCRIPTION STR0090 SEEK ACTION { |oSeek| MySeek(oSeek, oBrwNCnt) } SEEK ORDER aOrder NO LOCATE Of oDlg
		oBrwNCnt:SetAlias( cTabTmp )
		oBrwNCnt:SetTemporary(.T.)
		oBrwNCnt:SetDBFFilter(.T.)
		oBrwNCnt:SetUseFilter()
		oBrwNCnt:SetFieldFilter(aFields)
		oBrwNCnt:DisableDetails()

		// Adiciona as colunas do Browse
		oBrwNCnt:AddLegend( "" + STR0129 + " == PADR('" + STR0125 + "',100)", "RED"   , STR0125 )
		oBrwNCnt:AddLegend( "" + STR0129 + " == PADR('" + STR0126 + "',100)", "BLUE"  , STR0126 )
		oBrwNCnt:AddLegend( "" + STR0129 + " == PADR('" + STR0127 + "',100)", "HGREEN", STR0127 )
		oBrwNCnt:AddLegend( "" + STR0129 + " == PADR('" + STR0128 + "',100)", "ORANGE", STR0128 )

		For nI := 1 To Len( aFields )
			AAdd( aColumns, FWBrwColumn():New() )
			aColumns[nI]:SetData(&( '{ || ' + aFields[nI][1] + ' }' ))
			aColumns[nI]:SetTitle( aFields[nI][2] )
			aColumns[nI]:SetPicture( aFields[nI][6] )
			If lObfuscate
				aColumns[nI]:SetObfuscateCol( Empty(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, {aFields[nI][1]})) )
			EndIf
		Next

		oBrwNCnt:SetColumns(aColumns)

		// Adiciona os botoes do Browse
		ADD Button oBtVisual  Title STR0002 Action {|| JA070VNVE((cTabTmp)->(NVE_FILIAL + NVE_CCLIEN + NVE_LCLIEN + NVE_NUMCAS), 1)} OPERATION MODEL_OPERATION_VIEW Of oBrwNCnt //"Visualizar"
		ADD Button oBtAltera  Title STR0004 Action {|| JA070VNVE((cTabTmp)->(NVE_FILIAL + NVE_CCLIEN + NVE_LCLIEN + NVE_NUMCAS), 4)} OPERATION MODEL_OPERATION_UPDATE Of oBrwNCnt //"Alterar"
		ADD Button oBtRefresh Title STR0134 Action {|| JA070ATU(aStruAdic, cQryNCnt, @oBrwNCnt, @oTempTbCnt) } OPERATION MODEL_OPERATION_VIEW Of oBrwNCnt //"Atualizar"

		Activate FWFormBrowse oBrwNCnt // Ativação do Browse
		
		Activate MsDialog oDlg Centered // Ativação do janela
	Else
		lRet := JurMsgErro(STR0132,, STR0154) //# "Não há casos a serem exibidos." ## "Verifique os filtros selecionados."
	EndIf

	oTempTbCnt:Delete()

End Sequence

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA070ALT()
Função para visualização e alteração do Incidente

@return lRet .T./.F. As informações são válidas ou não

@author Clóvis Eduardo Teixeira
@since 20/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA070ALT(cClien, cLClien, cNumcas)
Local cRotina  := 'JURA070'
Local cMsg     := STR0007
Local cMsgErro := STR0071

If !Empty(cClien)
	NVE->(DBSetOrder(1))

	If NVE->(dbSeek(xFilial('NVE') + cClien + cLClien + cNumcas))
 		MsgRun(STR0088, cMsg, {|| FWExecView(STR0087, cRotina, 4,, { || lOk := .T., lOk },,, aShow) }) //Carregando...
	EndIf

Else
  JurMsgErro( cMsgErro )
EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} J070Active
Funcao executada na ativacao do modelo

@return Nil

@sample oModel:SetActivate( {|oModel| J070Active(oModel)} )

@author Daniel Magalhaes
@since 12/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J070Active( oModel )
Default oModel := FWModelActive()

J70GetCli( oModel )

If !FWIsInCallStack('JURA063') // não carrega se for remanejamento de caso
	J70AtuCateg( oModel, Nil )
EndIf

J070CPYCnt(oModel)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J70GetCli
Preenche os campos de Grupo de Clientes, Cod Cliente e Loja
quando chamado a partir da rotina JURA096 (Cad Contratos)

@return Nil

@author Daniel Magalhaes
@since 12/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J70GetCli( oModel )
Local oModelNVE

Default oModel   := FWModelActive()

oModelNVE := oModel:GetModel("NVEMASTER")

If oModel:GetOperation() == OP_INCLUIR .Or. oModel:GetOperation() == OP_ALTERAR
	If FWIsInCallStack("JURA096")
		If !Empty(_J96GrpCli)
			oModelNVE:SetValue("NVE_CGRPCL", _J96GrpCli)
		EndIf

		If !Empty(_J96CodCli) .And. !Empty(_J96LojCli)
			oModelNVE:SetValue("NVE_CCLIEN", _J96CodCli)
			oModelNVE:SetValue("NVE_LCLIEN", _J96LojCli)
		EndIf
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J70SetVar
Configura as variaveis estaticas passadas por parametro

@return Nil

@sample J70SetVar("_J96GrpCli","000011")

@author Daniel Magalhaes
@since 12/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J70SetVar(cNomVar, xValue)

&(cNomVar) := xValue

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J070When
Configura o modo de edicao dos campos (X3_WHEN)

@return Nil

@sample J070When("NVE_CGRPCL")

@author Daniel Magalhaes
@since 12/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J070When( cCampo )
Local lRet := .T.

cCampo := AllTrim(cCampo)

Do Case
	Case cCampo == "NVE_CGRPCL"
		lRet := !FWIsInCallStack("JURA096") .Or. FWIsInCallStack("J70GETCLI")
	Case cCampo == "NVE_CCLIEN"
		lRet := !FWIsInCallStack("JURA096") .Or. FWIsInCallStack("J70GETCLI")
	Case cCampo == "NVE_LCLIEN"
		lRet := !FWIsInCallStack("JURA096") .Or. FWIsInCallStack("J70GETCLI")
	Otherwise
		lRet := .T.
EndCase

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA070VldExi()
Validação do grid de Condição de Êxito.

@Return lRet
@author Tiago Martins
@since 16/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA070VldExi()
Local oModel    := FwModelActive()
Local oModelNWL := oModel:GetModel("NWLDETAIL")
Local nQtdNWL   := oModelNWL:getQtdLine()
Local nY        := 0
Local lRet      := .T.
Local cCondExi  := ""
Local cMsg      := ""

For nY := 1 To nQtdNWL
	If !oModelNWL:IsDeleted( nY )
		cCondExi := oModelNWL:GetValue('NWL_CONDEX', nY)
		Do Case
		Case cCondExi == '1' // Percentual
			If Empty(oModelNWL:GetValue('NWL_PERCEN', nY))
				cMsg := STR0080 //"Para esta condição de Êxito é necessário preencher o campo Percentual"
			ElseIf oModelNWL:GetValue('NWL_PERCEN', nY) == 0
				cMsg := STR0091 //"Para esta condição de Êxito o campo Percentual deve ser diferente de Zero"
			EndIf

		Case cCondExi == '2' // Faixa de valor
			If Empty(oModelNWL:GetValue('NWL_PERCEN', nY)) .Or. Empty(oModelNWL:GetValue('NWL_VALINI', nY)) .Or. Empty(oModelNWL:GetValue('NWL_VALFIN', nY))
				cMsg := STR0092 //"Para esta condição de Êxito é necessário preencher os campos de Valor Inicial, Final e Percentual"
			ElseIf oModelNWL:GetValue('NWL_VALINI', nY) > oModelNWL:GetValue('NWL_VALFIN', nY)
				cMsg := STR0083 //"Valor Inicial maior que valor Final"
			EndIf

		Case cCondExi == '3' // Faixa de Anos (Data de Distribuição)
			If Empty(oModelNWL:GetValue('NWL_PERCEN', nY)) .Or. Empty(oModelNWL:GetValue('NWL_ANOINI', nY)) .Or. Empty(oModelNWL:GetValue('NWL_ANOFIN', nY))
				cMsg := STR0093 //"Para esta condição de Êxito é necessário preencher os campos de Ano Inicial, Final e Percentual"
			ElseIf oModelNWL:GetValue('NWL_ANOINI', nY) > oModelNWL:GetValue('NWL_ANOFIN', nY)
				cMsg := STR0081 //"Ano Inicial maior que ano Final"
			EndIf

		Case cCondExi == '4' // Percentual (com Limite de Valor)
			If Empty(oModelNWL:GetValue('NWL_VALLIM', nY)) .Or. Empty(oModelNWL:GetValue('NWL_PERCEN', nY))
				cMsg := STR0094 //"Para esta condição de Êxito é necessário preencher os campos Percentual e Valor Limite"
			EndIf

		Case cCondExi == '5' // Valor Fechado
			If Empty(oModelNWL:GetValue('NWL_VALFEC', nY)) .Or. oModelNWL:GetValue('NWL_VALFEC', nY) == 0 ;
			   .Or. Empty(oModelNWL:GetValue('NWL_DTBASE', nY)) .Or. Empty(oModelNWL:GetValue('NWL_TPCORR', nY));
			   .Or. IIf(oModelNWL:GetValue('NWL_TPCORR', nY) == "2", Empty(oModelNWL:GetValue('NWL_VALCOR', nY)), )
				cMsg := STR0095 //"Para esta condição de Êxito é necessário preencher os campos Data Base,Valor Fechado,Cód Índice,Tipo Correção e Valor Correção"
			ElseIf oModelNWL:GetValue('NWL_TPCORR', nY) == '2' .And. Empty(oModelNWL:GetValue('NWL_CINDIC', nY))
				cMsg := STR0097 //"Para esta condição de Êxito com Correção do tipo Índice é necessário preencher o Código do Índice"
			EndIf
		EndCase
	EndIf
Next

If !Empty(cMsg)
	lRet := JurMsgErro(cMsg)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA070VlLinExi()
Verifica se há linha validas no êxito

@return lRet

@author Tiago Martins
@since 16/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA070VlLinExi(oModel)
Local oModelNWL := oModel:GetModel("NWLDETAIL")
Local nQtdNWL   := oModelNWL:GetQtdLine()
Local nQtdeGrid := 0
Local nI        := 0
Local lRet      := .F.

For nI := 1 To nQtdNWL
	If !oModelNWL:IsDeleted( nI ) .And. !Empty(oModelNWL:GetValue('NWL_CONDEX', nI))
		nQtdeGrid += 1
		Exit
	EndIf
Next

If nQtdeGrid > 0
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J070VCondEx()
Validação do campo para limpar os campos de valores no êxito

@return lRet

@author Tiago Martins
@since 16/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J070VCondEx()
Local cCond     := FwFldGet('NWL_CONDEX')
Local oModel    := FwModelActive()
Local oModelNWL := oModel:GetModel("NWLDETAIL")

Do Case
	Case cCond == '1'
		oModelNWL:LoadValue('NWL_VALINI',0		 )
		oModelNWL:LoadValue('NWL_VALFIN',0 		 )
		oModelNWL:LoadValue('NWL_ANOINI',''		 )
		oModelNWL:LoadValue('NWL_ANOFIN',''		 )
		oModelNWL:LoadValue('NWL_VALLIM',0		 )
		oModelNWL:LoadValue('NWL_DTBASE',cTod(''))
		oModelNWL:LoadValue('NWL_VALFEC',0		 )
		oModelNWL:LoadValue('NWL_TPCORR',''		 )
		oModelNWL:LoadValue('NWL_CINDIC',''		 )
		oModelNWL:LoadValue('NWL_VALCOR',0		 )
	Case cCond == '2'
		oModelNWL:LoadValue('NWL_ANOINI',''		 )
		oModelNWL:LoadValue('NWL_ANOFIN',''		 )
		oModelNWL:LoadValue('NWL_VALLIM',0		 )
		oModelNWL:LoadValue('NWL_DTBASE',cTod(''))
		oModelNWL:LoadValue('NWL_VALFEC',0		 )
		oModelNWL:LoadValue('NWL_TPCORR',''		 )
		oModelNWL:LoadValue('NWL_CINDIC',''		 )
		oModelNWL:LoadValue('NWL_VALCOR',0		 )
	Case cCond == '3'
		oModelNWL:LoadValue('NWL_VALINI',0		 )
		oModelNWL:LoadValue('NWL_VALFIN',0 		 )
		oModelNWL:LoadValue('NWL_VALLIM',0		 )
		oModelNWL:LoadValue('NWL_DTBASE',cTod(''))
		oModelNWL:LoadValue('NWL_VALFEC',0		 )
		oModelNWL:LoadValue('NWL_TPCORR',''		 )
		oModelNWL:LoadValue('NWL_CINDIC',''		 )
		oModelNWL:LoadValue('NWL_VALCOR',0		 )
	Case cCond == '4'
		oModelNWL:LoadValue('NWL_VALINI',0		 )
		oModelNWL:LoadValue('NWL_VALFIN',0 		 )
		oModelNWL:LoadValue('NWL_ANOINI',''		 )
		oModelNWL:LoadValue('NWL_ANOFIN',''		 )
		oModelNWL:LoadValue('NWL_DTBASE',cTod(''))
		oModelNWL:LoadValue('NWL_VALFEC',0		 )
		oModelNWL:LoadValue('NWL_TPCORR',''		 )
		oModelNWL:LoadValue('NWL_CINDIC',''		 )
		oModelNWL:LoadValue('NWL_VALCOR',0		 )
	Case cCond == '5'
		oModelNWL:LoadValue('NWL_DTBASE',cTod(''))
		oModelNWL:LoadValue('NWL_VALFEC',0		 )
		oModelNWL:LoadValue('NWL_TPCORR',''		 )
		oModelNWL:LoadValue('NWL_CINDIC',''		 )
		oModelNWL:LoadValue('NWL_VALCOR',0		 )
EndCase

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J070CPYCnt()
Rotina para guardar as informações dos vinculos de contratos.

@param  oModel  Modelo de dados
@param  lVldUltCs  Indica se deve considerar o resultado da J070UltCs
                   no retorno da aCnt070[3]. Quando a chamada for pelo 
                   J070FSinc, isso não deve ser considerado para gravar 
                   na fila corretamente.

@sample _aCnt070[1] linha do grid NUT
		_aCnt070[2] numero do contrato
		_aCnt070[3] .T. se é novo contrato adicionado
		_aCnt070[4] .T. se é contrato excluído

@return Nil

@author Luciano Pereira dos Santos
@since 28/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J070CPYCnt( oModel, lVldUltCs )
Local aSaveLines  := FWSaveRows()
Local aArea       := GetArea()
Local oModelNUT   := oModel:GetModel("NUTDETAIL")
Local nQtdLn      := oModelNUT:GetQtdLine()
Local nNUT        := 0
Local cContr      := ""
Local cCClien     := ""
Local cLClien     := ""
Local cNumCas     := ""
Local lCntNovo    := .F.
Local lCntDel     := .F.

Default lVldUltCs := .T.

_aCnt070 := {}

For nNUT := 1 To nQtdLn

	If !oModelNUT:IsEmpty()
		cContr   := oModelNUT:GetValue("NUT_CCONTR", nNUT)
		cCClien  := oModelNUT:GetValue("NUT_CCLIEN", nNUT)
		cLClien  := oModelNUT:GetValue("NUT_CLOJA", nNUT)
		cNumCas  := oModelNUT:GetValue("NUT_CCASO", nNUT)
	
		lCntNovo := Empty(JurGetDados('NUT', 3, xFilial('NUT') + cContr + cCClien + cLClien + cNumCas, 'NUT_CCONTR')) .And.;
		            Iif(lVldUltCs, J070UltCs(cCClien, cLClien, cNumCas, cContr, .F.), .T.)

		lCntDel  := oModelNUT:IsDeleted(nNUT)

		aAdd(_aCnt070, { nNUT, cContr, lCntNovo, lCntDel } )
	EndIf

Next nNUT

FWRestRows( aSaveLines )
RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J070UltCs(oModel)
Rotina para verificar se o contrato tem somente o caso em questão

@param   cCClien	Cliente do caso
@param   cCLlien	loja do caso
@param   cNumCas	Numero do caso
@param   cContr		Contrato que sera verificado
@param   lnAtivos	Considera os contratos não ativos

@return  lRet		Se tiverem mais casos no contrato retorna .F.
					caso contrario retorna .T.

@author Luciano Pereira dos Santos
@since 28/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J070UltCs(cCClien, cLClien, cNumCas, cContr, lnAtivo)
Local lRet      := .F.
Local aArea     := GetArea()
Local cQuery    := ""
Local cQueryRes := GetNextAlias()

cQuery := " SELECT NUT.R_E_C_N_O_ "
cQuery +=   " FROM " + RetSqlName("NUT") + " NUT, "
cQuery +=        " " + RetSqlName("NT0") + " NT0 "
cQuery +=     " WHERE NUT.NUT_FILIAL = '" + xFilial( "NUT" ) + "' "
cQuery +=       " AND NT0.NT0_FILIAL = '" + xFilial( "NT0" ) + "' "
cQuery +=       " AND NUT.NUT_CCONTR = '" + cContr + "' "
cQuery +=       " AND NT0.NT0_COD = NUT.NUT_CCONTR "
cQuery +=       " AND (NOT (NUT.NUT_CCLIEN = '" + cCClien + "' "
cQuery +=                 " AND NUT.NUT_CLOJA = '" + cLClien + "' "
cQuery +=                 " AND NUT.NUT_CCASO = '" + cNumCas + "') "
If lnAtivo
	cQuery +=               " OR NT0.NT0_ATIVO = '2' "
EndIf
cQuery +=           " ) "
cQuery +=       " AND NUT.D_E_L_E_T_ = ' ' "
cQuery +=       " AND NT0.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cQueryRes, .T., .T.)

lRet := (cQueryRes)->(EOF())

(cQueryRes)->(dbCloseArea())

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J070VldPerc

@author Totvs
@since 25/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J070VldPerc(oModel, cCpoMarca, cCpoTipo, cCpoTipoD, cCpoPerc, cCpoPart)
Local cMsg        := ""
Local nQdtLinha   := 0
Local nLinha      := 0
Local aParticip   := {}
Local nPercent    := 0
Local nAtOld      := oModel:nLine
Local lRet        := .T.
Local cIncSocio   := ""
Local cSocio      := ""
Local nTamDec     := TamSX3("NRI_SOMAOR")[2]
Local lArredondar := SuperGetMV("MV_JARPART", .F., "2") == '1' //Arredondar participação? 1 - Sim; 2 - Não.
Local nTotPerc    := 0
Local nTotPartic  := 0

nQdtLinha := oModel:GetQtdLine()
If nQdtLinha > 0
	cMsg := STR0036 + CRLF
	For nLinha := 1 To nQdtLinha
		oModel:GoLine(nLinha)
		If !oModel:IsDeleted()
			cIncSocio := JurGetDados('NRI', 1, xFilial('NRI') + FwFldGet(cCpoTipo, nLinha), 'NRI_INCSOC')
			If cIncSocio == '1'
				cSocio := JurGetDados('NUR', 1, xFilial('NUR') + FwFldGet(cCpoPart, nLinha), 'NUR_SOCIO')
				If cSocio <> '1'
					lRet := .F.
					If At( AllTrim( FwFldGet(cCpoTipo, nLinha) ), cMsg ) == 0
						cMsg += AllTrim( FwFldGet(cCpoTipo, nLinha) + " - " + FwFldGet(cCpoTipoD, nLinha) ) + ". " + CRLF
					EndIf
				EndIf
			EndIf
		EndIf
	Next
EndIf

If nQdtLinha > 0 .And. lRet
	For nLinha := 1 To nQdtLinha
		oModel:GoLine( nLinha )
		If !Empty(FwFldGet(cCpoTipo, nLinha))
			nPos := aScan( aParticip, { |aX| aX[2] == FwFldGet(cCpoTipo, nLinha)} )

			If !oModel:IsDeleted()
				If nPos > 0
					aParticip[nPos][3] := aParticip[nPos][3] + FwFldGet(cCpoPerc, nLinha)
				Else
					aAdd( aParticip, { FwFldGet(cCpoMarca, nLinha), AllTrim( FwFldGet(cCpoTipo, nLinha) ), FwFldGet(cCpoPerc, nLinha), AllTrim( FwFldGet(cCpoTipoD, nLinha) ) } )
				EndIf
			EndIf
		EndIf
	Next
	cMsg := STR0037 + CRLF
	nQdtLinha := Len(aParticip)
	If nQdtLinha > 0
		For nLinha := 1 To nQdtLinha
			nPercent := JurGetDados('NRI', 1, xFilial('NRI') + aParticip[nLinha][2], 'NRI_SOMAOR')
			If nPercent > 0
				nTotPartic := aParticip[nLinha][3]
				nTotPerc   := Iif(lArredondar, Round(aParticip[nLinha][3], nTamDec), aParticip[nLinha][3])
				If nPercent <> nTotPerc
					lRet := .F.
					cMsg += aParticip[nLinha][2] + " - " + aParticip[nLinha][4] + " -> " + AllTrim(Str(nPercent)) + "%. "  + CRLF
				EndIf
			EndIf
		Next

		If lRet .And. nTotPartic > 100
			lRet := .F.
			cMsg :=  STR0100 + cValToChar(nTotPartic) //"A soma de participação deve ser menor ou igual a 100%. Valor atual: "
		EndIf
	EndIf
EndIf
oModel:GoLine( nAtOld )

cMsg := IIF(lRet, "", cMsg)

Return cMsg

//-------------------------------------------------------------------
/*/{Protheus.doc} J070VldMarc

@author Totvs
@since 25/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J070VldMarc(oModelNVF)
Local cRet      := ""
Local nI        := 0
Local nJ        := 0
Local nQtdNVF   := oModelNVF:GetQtdLine()
Local aPeriodo  := {}
Local aTipos    := {}
Local aAux      := {}
Local aRet      := {}
Local nAtual    := 0
Local nQtdPerio := 0
Local nQtdTipos := 0

nLinha := oModelNVF:nLine
If oModelNVF:IsUpdated()
  For nI := 1 To nQtdNVF
		oModelNVF:GoLine(nI)
		If !oModelNVF:IsDeleted()
			nAtual += 1
			aAdd(aPeriodo, { FwfldGet("NVF_AMINI"), FwfldGet("NVF_AMFIM"), FwFldGet("NVF_CPART"), FwFldGet("NVF_CTIPO"), FwFldGet("NVF_PERC"), FwFldGet("NVF_DTIPO") } )
			If aScan( aTipos, { |aX| aX[1] == aPeriodo[nAtual][TIPO]} ) == 0
				aAdd(aTipos, { aPeriodo[nAtual][TIPO], AllTrim(aPeriodo[nAtual][DTIPO]) })
			EndIf
		EndIf
	Next
EndIf
oModelNVF:GoLine(nLinha)

nQtdTipos := Len(aTipos)
nQtdPerio := Len(aPeriodo)

For nI := 1 To nQtdTipos
	aAux := {}
	For nJ := 1 To nQtdPerio
		If aPeriodo[nJ][4] == aTipos[nI][1]
			aAdd(aAux, aPeriodo[nJ])
		EndIf
	Next

	aRet := J070VldTp(aAux, aTipos[nI][1], aTipos[nI][2])
	If !aRet[1]
		cRet := aRet[2]
		Exit
	EndIf
Next

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J070VldTp
Rotina para validar o periodo

@author Totvs
@since 25/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J070VldTp(aPeriodo, cTipo, cDTipo)
Local lRet        := .T.
Local cRet        := ""
Local aAux        := {}
Local cAMMenor    := ""
Local cAMMaior    := ""
Local nI          := 0
Local nJ          := 0
Local nPercNRI    := 0
Local nTamDec     := TamSX3("NRI_SOMAOR")[2]
Local lArredondar := SuperGetMV("MV_JARPART", .F., "2") == '1' //Arredondar participação? 1 - Sim; 2 - Não.
Local nTotPartic  := 0
Local nTotPerc    := 0

Default aPeriodo  := {}
Default cTipo     := ""
Default cDTipo    := ""

aAux := aClone(aPeriodo)

aSort( aAux,,, { |aX,aY| aX[1] < aY[1] } )
cAMMenor := aAux[1][1]
aSort( aAux,,, { |aX,aY| aX[2] > aY[2] } )
cAMMaior := aAux[1][2]

aAux := J070GetDts(cAMMenor, cAMMaior, cTipo)

nPercNRI := JurGetDados('NRI', 1, xFilial('NRI') + cTipo, 'NRI_SOMAOR')
For nI := 1 To Len(aAux)

	For nJ := 1 To Len(aPeriodo)
		If  ( aPeriodo[nJ][TIPO] == aAux[nI][2] ) .And. ;
				( (aPeriodo[nJ][AMINI] <= aAux[nI][ANOMES] .And. aPeriodo[nJ][AMFIM] >= aAux[nI][ANOMES]) .Or. ;
				  (aPeriodo[nJ][AMINI] <= aAux[nI][ANOMES] .And. Empty(aPeriodo[nJ][AMFIM])) )
			aAux[nI][PERC] += aPeriodo[nJ][PERCENT]
			aAux[nI][OK] := .T.
		EndIf
	Next

	If aAux[nI][OK]
		nTotPartic := aAux[nI][PERC]
		nTotPerc   := Iif(lArredondar, Round(nTotPartic, nTamDec), nTotPartic)

		If (nPercNRI == 0 .And. nTotPartic > 100) .Or. (nPercNRI <> 0 .And. (nTotPerc <> nPercNRI .Or. nTotPartic > nPercNRI))
			lRet := .F.
			cRet := CRLF + STR0037 + CRLF + Transform(aAux[nI][ANOMES], "9999-99") + " | " + ;
			        cTipo + " - " + cDTipo + " -> " + AllTrim(Str(nTotPartic)) + "%. " + CRLF
			Exit
		EndIf
	EndIf

Next

Return {lRet, cRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} J070GetDts
Rotina para retornar a quantidade de mes entre datas

@author Totvs
@since 25/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J070GetDts(cAMMenor, cAMMaior, cTipo)
Local aRet     := {}
Local cAMAtual := cAMMenor
Local nMonth   := 0

Default cTipo  := ""

aAdd(aRet, {cAMAtual, cTipo, 0, .F.})
While SToD(cAMAtual + "01") < SToD(cAMMaior + "01")

	nMonth := Month(SToD(cAMAtual + "01"))
	nYear  := Year(SToD(cAMAtual + "01"))
	If nMonth == 12
		nMonth := 1
		nYear += 1
	Else
		nMonth += 1
	EndIf
	cAMAtual := StrZero(nYear, 4) + StrZero(nMonth, 2)

	aAdd(aRet, {cAMAtual, cTipo, 0, .F.})

EndDo

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J70AltCas
Verifica alteracao dos campos que afetam a geracao das pre-faturas

@author Daniel Magalhaes
@since 25/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J70AltCas(oModel)
Local lRet    := .F.
Local aAux    := {}
Local cCpos   := "NVE_PESO,NVE_TPHORA,NVE_VLHORA,NVE_CTABH,NVE_CTABS,NVE_CESCRI,NVE_DESPAD,NVE_CIDIO,NVE_ENCHON,NVE_ENCDES,NVE_ENCTAB,NVE_LANTS,NVE_LANDSP,NVE_LANTAB"
Local cGrids  := "NUTDETAIL,NUUDETAIL"
Local nI      := 0
Local nY      := 0
Local nQtdMdl := 0
Local oMdlAux := Nil

aAux := StrTokArr(cCpos, ",")

For nI := 1 To Len(aAux)
	If lRet := oModel:IsFieldUpdated( "NVEMASTER", aAux[nI] )
		Exit
	EndIf
Next nI

If !lRet
	aAux := StrTokArr(cGrids, ",")

	For nI := 1 To Len(aAux)
		oMdlAux := oModel:GetModel(aAux[nI])

		nQtdMdl := oMdlAux:GetQtdLine()

		For nY := 1 To nQtdMdl

			If oMdlAux:IsDeleted(nY) .Or. oMdlAux:IsUpdated(nY) .Or.;
			   (oMdlAux:IsInserted(nY) .And. !oMdlAux:IsEmpty(nY))
				lRet := .T.
				Exit
			EndIf

		Next nY

	Next nI

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J070PreFt(oModel)
Função para exbir as pré-fatura que estao associadas ao caso
e nao sofrerão alteração.

@author Luciano Pereira dos Santos
@since 23/09/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J070PreFt(oModel)
Local oMoldelNVE := oModel:GetModel("NVEMASTER")
Local cClient    := oMoldelNVE:GetValue("NVE_CCLIEN")
Local cLoja      := oMoldelNVE:GetValue("NVE_LCLIEN")
Local cCaso      := oMoldelNVE:GetValue("NVE_NUMCAS")
Local aCodPre    := {}
Local cQuery     := ""
Local cMsgErr    := ""
Local nFor       := 0
Local nLenCod    := 0
Local lRemanej   := FWIsInCallStack('JURA063')

If J70AltCas(oModel)

	cQuery := " Select NX0.NX0_COD "
	cQuery += " from " + RetSqlName("NX1") + " NX1 "
	cQuery +=    " inner join " + RetSqlName("NX0") + " NX0 "
	cQuery +=             " on( NX0.NX0_FILIAL = '" + xFilial("NX0") + "' "
	cQuery +=                 " and NX0.NX0_COD = NX1.NX1_CPREFT "
	cQuery +=                 " and NX0.NX0_SITUAC in ('1','2','3','4','5') "
	cQuery +=                 " and NX0.D_E_L_E_T_ = ' ') "
	cQuery += " where NX1.NX1_FILIAL = '" + xFilial("NX1") + "' "
	cQuery +=   " and NX1.NX1_CCLIEN = '" + cClient + "' "
	cQuery +=   " and NX1.NX1_CLOJA = '" + cLoja + "' "
	cQuery +=   " and NX1.NX1_CCASO = '" + cCaso + "' "
	cQuery +=   " and NX1.D_E_L_E_T_ = ' ' "
	cQuery += " group by NX0.NX0_COD "
	cQuery += " order by NX0.NX0_COD "

	aCodPre := JurSQL(cQuery, {"NX0_COD"})
	nLenCod := Len(aCodPre)

	If nLenCod > 0
		cMsgErr := STR0103 //"Atenção: as alterações feitas não refletirão na(s) pré-fatura(s) em aberto: "
		For nFor := 1 To nLenCod
			cMsgErr += aCodPre[nFor][1] + Iif(nFor < nLenCod, ", ", ".")
		Next nFor
		If !lRemanej .And. !(__InMsgRun)
			MsgAlert(cMsgErr)
		EndIf
	EndIf

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J070VldAnd
Função para quando os parametros MV_JCASO1 for 2 e o MV_JCASO3 for .T.,
validar ao reabrir o caso se ja existe outro caso em andamento, se sim,
então nao permitir reabrir.

@author Felipe Bonvicini Conti
@since 07/11/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J070VldAnd(oModel)
Local lRet         := .T.
Local cNumCaso     := SuperGetMV('MV_JCASO1',, '1') // 1 = Depende do Cliente; 2 = Independente de Cliente
Local lPreservCaso := (cNumCaso == "2") .And. SuperGetMV('MV_JCASO3',, .F.) // .T./.F. = Preserva ou não o número do Caso de Origem quando for Independente de Cliente.
Local cQuery       := ""
Local aSQL         := {}
Local nQtd         := 0
Local nI           := 0
Local cMsg         := ""

If lPreservCaso .And. oModel:GetOperation() == OP_ALTERAR
	cSituac := oModel:GetValue("NVEMASTER","NVE_SITUAC")
	If cSituac == "1" .And. NVE->NVE_SITUAC == "2" // Esta reabrindo o caso!

		cQuery := " SELECT NVE_CCLIEN, NVE_LCLIEN "
		cQuery +=   " FROM " + RetSqlName("NVE") + " NVE "
		cQuery +=  " WHERE NVE_FILIAL = '" + xFilial("NVE") +"' "
		cQuery +=    " AND NVE_SITUAC = '1' "
		cQuery +=    " AND NVE_NUMCAS = '" + oModel:GetValue("NVEMASTER", "NVE_NUMCAS") + "' "
		cQuery +=    " AND D_E_L_E_T_ = ' ' "

		aSQL := JurSQL(cQuery, {"NVE_CCLIEN", "NVE_LCLIEN"})

		If !Empty(aSQL) .And. (nQtd := Len(aSQL)) > 0
			cMsg := STR0105 + CRLF
			For nI := 1 To nQtd
				cMsg += STR0106 + aSQL[nI][1] + " / " + STR0107 + aSQL[nI][2] + CRLF // "Cliente: " e "Loja: "
			Next
			lRet := JurMsgErro(cMsg) // "Este caso não pode ser reaberto pois já existe outro caso com o mesma numeração em andamento. Verifique!"
		EndIf

	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA070NoRev
Exibe os casos que foram remanejados e nao estao revisados

@author Daniel Magalhaes
@since 09/11/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA070NoRev()
Local nI         := 0
Local cTrab      := "NVE"
Local aCampos    := {}
Local aTmpCps    := {}
Local aStru      := {}
Local aAux       := {}
Local aFields    := {}
Local aTmpFld    := {}
Local oBrw       := Nil
Local oDlg       := Nil
Local oTela      := Nil
Local oPnlBrw    := Nil
Local oPnlRoda   := Nil
Local bConfir    := {|| }
Local oLayer     := FWLayer():New()
Local oMainColl  := Nil
Local cLojaAuto  := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local lObfuscate := FindFunction("FwPDCanUse") .And. FwPDCanUse(.T.) // Indica se trabalha com Dados Protegidos e possui a melhoria de ofuscação de dados habilitada
Local aColumns   := {}

Define MsDialog oDlg FROM 0, 0 To 400, 600 Title STR0110 Pixel /*style DS_MODALFRAME*/ //"Casos remanejados e não revisados"

oLayer:init(oDlg, .F.) //Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
oLayer:addCollumn("MainColl", 100, .F.) //Cria as colunas do Layer
oMainColl := oLayer:GetColPanel( 'MainColl' )

oTela     := FWFormContainer():New(oDlg)
cIdBrowse := oTela:CreateHorizontalBox(84)
cIdRodape := oTela:CreateHorizontalBox(16)
oTela:Activate( oDlg, .F. )
oPnlBrw   := oTela:GeTPanel( cIdBrowse )
oPnlRoda  := oTela:GeTPanel( cIdRodape )

Define FWBrowse oBrw DATA TABLE ALIAS cTrab NO LOCATE Of oPnlBrw

oBrw:SetFilterDefault("NVE_REVISA == '2'")

aStru := ( cTrab )->( dbStruct())
For nI := 1 To Len(aStru)

	aAux    := {}
	aAdd( aAux, aStru[nI][1] )
	If AvSX3( aStru[nI][1],, cTrab, .T. )
		aAdd( aAux, RetTitle( aStru[nI][1] ) )
		aAdd( aAux, AvSX3( aStru[nI][1], 6, cTrab ) )
	Else
		aAdd( aAux, aStru[nI][1] )
		aAdd( aAux, '' )
	EndIf
	aAdd( aTmpCps, aAux )

	aAux := AvSX3( aStru[nI][1] )
	aAdd( aTmpFld, {aStru[nI][1], ; // X3_CAMPO
	                RetTitle(aStru[nI][1]), ; // X3_TITULO
	                aAux[2], ; // X3_TIPO
	                aAux[3], ; // X3_TAMANHO
	                aAux[4], ; // X3_DECIMAL
	                aAux[7]  ; // X3_PICTURE
	                } )
Next

If (cLojaAuto = "1")
	AEVAL(aTmpFld, {|aX| Iif("NVE_LCLIEN" != aX[1], Aadd(aFields, aX),)})
	AEVAL(aTmpCps, {|aX| Iif("NVE_LCLIEN" != aX[1], Aadd(aCampos, aX),)})
Else
	aFields := aTmpFld
	aCampos := aTmpCps
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

oBrw:SetFieldFilter(aFields)
oBrw:SetUseFilter(1)
oBrw:SetColumns(aColumns)

Activate FWBrowse oBrw

bConfir := {|| JA070ALT( (cTrab)->NVE_CCLIEN, (cTrab)->NVE_LCLIEN, (cTrab)->NVE_NUMCAS ), oBrw:Refresh(.T.)}

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar;
			(oDlg, bConfir,; //Confirma
			{|| oDlg:End() },; //Sair
			, /*aButtons*/, /*nRecno*/, /*cAlias*/, .F., .F., .F., .T., .F. )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J070PosRev
Função utilizada para buscar os valores de revisao do caso.

@author Felipe Bonvicini Conti
@since 11/11/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function J070PosRev(cCampo, cClien, cLoja, cCaso)
Local cRet := ""

	If !Empty(cCampo) .And. !Empty(cClien) .And. !Empty(cLoja) .And. !Empty(cCaso)
		cRet := JurGetDados('NVE', 1, xFilial('NVE') + cClien + cLoja + cCaso, cCampo)
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA070MsgRun
Função utilizada alterar a variavel __InMsgRun.

@author TOTVS
@since 11/11/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA070MsgRun(lMsRun)
	__InMsgRun := lMsRun
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J70ValNeg
Função utilizada para validação quando a regra for do tipo FIXO
e o valor ajustado (Vlr ajuste) for negativo

@author Rafael Rezende Costa
@since 25/05/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function J70ValNeg(cCampo)
Local lRet      := .T.
Local oModel    := Nil
Local oModelXXX := Nil
local cTab      := ''

oModel := FWModelActive()

If !Empty(cCampo)
	cCampo := Iif( ValType(cCampo) != 'C', Alltrim(Str(cCampo)), Alltrim(cCampo))
EndIf

If !Empty(cCampo) .And. Len(cCampo) > 3 .And. oModel != NIL

	cTab := Left(cCampo, 3)
	If !Empty(cTab)
		oModelXXX := oModel:GetModel(cTab + 'DETAIL') // GRID CORRESPONDENTE PARA VERICAÇÃO DE ACORDO COM O PARAMETRO

		Do Case
		Case (oModelXXX:GetValue(cTab + "_VALOR2") < 0) .And. (oModelXXX:GetValue(cTab + "_REGRA") == '3')
			lRet := JurMsgErro(i18N(STR0113 + '#1' + STR0114, {Alltrim(RetTitle(cCampo))} )) // "Para o tipo de Regra 'Fixo', o valor ajustado ("+ cCampo +") deverá ser positivo !"

		Case (oModelXXX:GetValue(cTab + "_VALOR2") < 0) .And. ( (oModelXXX:GetValue(cTab + "_REGRA") != '3') .Or. (oModelXXX:GetValue(cTab + "_REGRA") != '4'))

			If (J70VLRAJUST(cTab, oModel) < 0 )
				lRet := JurMsgErro(i18N(STR0115 + '#1' + STR0117 + '#3' + STR0118, {Alltrim(RetTitle(cCampo)), RetTitle(Left(cCampo, Len(cCampo) - 1) + '1'), RetTitle(Left(cCampo, Len(cCampo) - 1) + '3') } ))
				// STR0115 -> "Favor verificar o valor preenchido no campo "  STR0117 -> ", pois o valor do campo " STR0118 -> " será negativo !"
			EndIf

		Otherwise
			lRet := .T.
		EndCase
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J70CodCat
Função utilizada para validação do campo de codigo de categoria.

@author Rafael Rezende Costa
@since 12/06/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function J70CodCat(cTab)
Local lRet      := .T.
Local oModel    := FWModelActive()
Local cCampo    := ''
Local oModelXXX := Nil

Default cTab    := ""

cTab := Alltrim(cTab)

Do Case

	Case ( __READVAR $ 'M->NV2_REGRA')
		oModelXXX := oModel:GetModel("NV2DETAIL")

		If (oModelXXX:GetValue("NV2_REGRA") == '4')
			oModelXXX:Activate()

			If !(oModel:ClearField(oModelXXX:getId(), "NV2_VALOR2"))  // Limpa o conteudo do campo VlrAjuste NV2_Valor2
				lRet := JurMsgErro(STR0121 + Alltrim(RetTitle('NV2_VALOR2')))
			EndIf

			If Len(cTab) > 4 .And. Empty(oModelXXX:GetValue(cCampo))   // Se a quantidade de caracteres do parametro for maior que 4, significa que é o nome do campo para verificação
				lRet := JurMsgErro( i18N(STR0119 + '#1' + " !", {Alltrim(RetTitle(cCampo))})) //"Favor preencher o campo " + '#1' + " !",{Alltrim(RetTitle(cCampo))}
			EndIf

		Else
			If !(oModel:ClearField(oModelXXX:getId(), "NV2_CCAT" )) //Limpa o codigo de categoria
				lRet := JurMsgErro(STR0121 + Alltrim(RetTitle('NV2_CCAT')))
			EndIf

			If !(oModel:ClearField(oModelXXX:getId(), "NV2_DCAT" )) // Limpa a descrição de categoria
				lRet := JurMsgErro(STR0121 + Alltrim(RetTitle('NV2_DCAT')))
			EndIf
		EndIf

	Case ( __READVAR $ 'M->NV0_REGRA')
		oModelXXX := oModel:GetModel("NV0DETAIL")

		If (oModelXXX:GetValue("NV0_REGRA") == '4')
			oModelXXX:Activate()

			If !(oModel:ClearField(oModelXXX:getId(), "NV0_VALOR2")) // Limpa o conteundo do campo VlrAjuste NV0_Valor2
				lRet := JurMsgErro(STR0121 + Alltrim(RetTitle('NV0_VALOR2')))
			EndIf

			If !(oModel:ClearField(oModelXXX:getId(), "NV0_VALOR3")) // Limpa o conteundo do campo VlrAjustado NV0_Valor3
				lRet := JurMsgErro(STR0121 + Alltrim(RetTitle('NV0_VALOR3')))
			EndIf

			If Len(cTab) > 4 .And. Empty(oModelXXX:GetValue(cCampo)) // OBS: Se a quantidade de caracteres do parametro for maior que 4, significa que é o nome do camp para verificação
				lRet := JurMsgErro( i18N(STR0119 + '#1' + " !", {Alltrim(RetTitle(cCampo))}) )   //"Favor preencher o campo " + '#1' + " !",{Alltrim(RetTitle(cCampo))}
			EndIf

		Else
			If !(oModel:ClearField(oModelXXX:getId(), "NV0_CCAT"))
				lRet := JurMsgErro(STR0121 + Alltrim(RetTitle('NV0_CCAT')))
			EndIf

			If !(oModel:ClearField(oModelXXX:getId(), "NV0_DCAT"))
				lRet := JurMsgErro(STR0121 + Alltrim(RetTitle('NV0_DCAT')))
			EndIf

		EndIf

	Otherwise

		Iif(!Empty(cTab), cCampo := Alltrim(cTab), cCampo := '')
		Iif(!Empty(cCampo), cTab := Left(cCampo, 3), cTab := '')

		oModelXXX := oModel:GetModel(cTab + 'DETAIL')

		If (oModelXXX:GetValue(cTab + "_REGRA") == '4')

			If !(oModel:ClearField(oModelXXX:getId(), "NV0_VALOR2")) // Limpa o conteundo do campo VlrAjuste NV0_Valor2
				lRet := JurMsgErro(STR0121 + Iif(cTab == 'NV0', Alltrim(RetTitle('NV0_VALOR2')), Alltrim(RetTitle('NV2_VALOR2'))))
			EndIf

			If (Empty(oModelXXX:GetValue(cCampo)))
				lRet := JurMsgErro( i18N(STR0119 + '#1' + " !", {Alltrim(RetTitle(cCampo))}) ) //"Favor preencher o campo " + '#1' + " !",{Alltrim(RetTitle(cCampo))}
			EndIf

		Else
			If !(oModel:ClearField(oModelXXX:getId(), Iif(cTab == 'NV0', "NV0_CCAT", "NV2_CCAT")))
				lRet := JurMsgErro(STR0121 + Iif(cTab == 'NV0', Alltrim(RetTitle("NV0_CCAT")), Alltrim(RetTitle("NV2_CCAT"))))
			EndIf

			If !(oModel:ClearField(oModelXXX:getId(), Iif(cTab == 'NV0', "NV0_DCAT", "NV2_DCAT")))
				lRet := JurMsgErro(STR0121 + Iif(cTab == 'NV0', Alltrim(RetTitle("NV0_DCAT")), Alltrim(RetTitle("NV2_DCAT"))))
			EndIf
		EndIf

End Case

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J070VLTLot
Função utilizada para validar se o caso tem lançamento tabelado em lote.

@author Luciano Pereira dos Santos
@since 19/06/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J070VLTLot(oModel)
Local lRet    := .T.
Local cSQL    := ""
Local aArea   := GetArea()
Local cClient := oModel:GetValue("NVEMASTER", "NVE_CCLIEN")
Local cLoja   := oModel:GetValue("NVEMASTER", "NVE_LCLIEN")
Local cCaso   := oModel:GetValue("NVEMASTER", "NVE_NUMCAS")

cSQL := "SELECT NWM.R_E_C_N_O_ RECNO "
cSQL +=    " FROM " + RetSqlName("NWM") + " NWM "
cSQL +=    " INNER JOIN " + RetSqlName("NWN") + " NWN "
cSQL +=           " ON NWM.NWM_COD = NWN.NWN_CLOTE "
cSQL +=           " AND NWN.NWN_FILIAL = '" + xFilial("NWN") + "' "
cSQL +=           " AND NWN.NWN_CCASO  = '" + cCaso + "' "
cSQL +=           " AND NWN.D_E_L_E_T_ = ' ' "
cSQL +=    " WHERE NWM.NWM_FILIAL = '" + xFilial("NWM") + "' "
cSQL +=      " AND NWM.NWM_CCLIEN = '" + cClient + "' "
cSQL +=      " AND NWM.NWM_CLOJA  = '" + cLoja + "' "
cSQL +=      " AND NWM.D_E_L_E_T_ = ' ' "

lRet := Empty(JurSQL(cSQL, {"RECNO"}))

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA070VNVE()
Visualização ou Alteração do caso com base em tabela temporária.
Usado no botão Casos sem Contrato (JA070NOCONT).

@Params  cChave   Chave Tabela NVE Ordem 1
@Params  nModo    Alteração (4) ou Visualização (1)

@author Cristina Cintra
@since 09/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA070VNVE(cChave, nModo )
Local aArea    := GetArea()
Local aAreaNVE := NVE->(GetArea())
Local cMsg     := STR0007 //"Caso"

Default nModo  := 1 //Visualizar

oBrowse:CleanFilter() // Remover filtros do Browse principal.

NVE->(DbSetOrder(1)) // NVE_FILIAL+NVE_CCLIEN+NVE_LCLIEN+NVE_NUMCAS
If NVE->(dbSeek(cChave))
	If nModo == 1
		MsgRun(STR0088, cMsg, {|| FWExecView(STR0002, 'JURA070', 1,, { || lOk := .T., lOk }) }) //#Carregando... ##"Visualizar"
	ElseIf nModo == 4
		MsgRun(STR0088, cMsg, {|| FWExecView(STR0004, 'JURA070', 4,, { || lOk := .T., lOk }) }) //#Carregando... ##"Alterar"
	EndIf
Else
	JurMsgErro( STR0131 ) //"Caso não encontrado!"
EndIf

RestArea( aAreaNVE )
RestArea( aArea )
oBrowse:ExecuteFilter() //Retorna os filtros do Browse princípal

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA070QRY()
Função para retornar a query que será utilizada na montagem e validação
da tela Casos sem contratos

@Param  lSemCon     Casos cobráveis sem contrato vinculado
@Param  lCobHora    Caso que permite faturamento de TS, sem vínculo a contrato que cobre hora
@Param  lCobDesp    Caso que permite faturamento de Despesa, sem vínculo a contrato que cobre despesa
@Param  lCobTab     Caso que permite faturamento de Tabelado, sem vínculo a contrato que cobre tabelado
@Param  cGetGrup    Texto com Grupo (filtro da tela)
@Param  cGetClie    Texto com o Cliente (filtro da tela)
@Param  cGetLoja    Texto com a Loja (filtro da tela)
@Param  dDtIni      Data com data de entrada incial para o filtro
@Param  dDtFim      Data com data de entrada final para o filtro

@author Bruno Ritter
@since 21/09/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA070QRY( lSemCon, lCobHora, lCobDesp, lCobTab, cGetGrup, cGetClie, cGetLoja, dDtIni, dDtFim)
Local cQuery     := ""
Local cDtIni     := DToS(dDtIni)
Local cDtFim     := DToS(dDtFim)
Local cFilPrd    := ""
Local cRelQry    := ""
Local cSelcQry   := ""

//-------------------------------------------------------------------
//Campos select
//-------------------------------------------------------------------
cSelcQry := "SELECT "
cSelcQry += " NVE_FILIAL, NVE_CGRPCL, NVE_CCLIEN, NVE_LCLIEN, NVE_NUMCAS, "
cSelcQry += " NVE_TITULO, NVE_CCLINV, NVE_CLJNV, NVE_CCASNV, "
cSelcQry += JurCaseCB({'NVE_SITUAC'}) //Criar Case com campo cBox
cSelcQry += " A1_NOME NVE_DCLIEN, "
cSelcQry += " CASE " //Tratamento para caso a descrição do grupo for null
cSelcQry +=     " WHEN ACY_DESCRI IS NULL THEN ' ' "
cSelcQry +=     " ELSE ACY_DESCRI "
cSelcQry += " END NVE_DGRPCL "

//-------------------------------------------------------------------
//Relacionamento
//-------------------------------------------------------------------
cRelQry += " FROM " + RetSqlName("NVE") + " NVE "
cRelQry += " INNER JOIN " + RetSqlName("SA1") + " SA1 "
cRelQry +=       " ON NVE.NVE_CCLIEN = SA1.A1_COD "
cRelQry +=       " AND NVE.NVE_LCLIEN = SA1.A1_LOJA "
cRelQry +=       " AND SA1.D_E_L_E_T_ = ' ' "
cRelQry += " LEFT JOIN " + RetSqlName("ACY") + " ACY "
cRelQry +=       " ON NVE.NVE_CGRPCL = ACY.ACY_GRPVEN "
cRelQry +=       " AND ACY.D_E_L_E_T_ = ' ' "
cRelQry += " LEFT JOIN " + RetSqlName("NUT") + " NUT "
cRelQry +=       " ON NUT.NUT_CCLIEN = NVE.NVE_CCLIEN "
cRelQry +=       " AND NUT.NUT_CLOJA = NVE.NVE_LCLIEN "
cRelQry +=       " AND NUT.NUT_CCASO = NVE.NVE_NUMCAS "
cRelQry +=       " AND NUT.D_E_L_E_T_ = ' ' "
cRelQry +=       " AND NUT.NUT_FILIAL = '" + xFilial("NUT") + "' "
cRelQry += " LEFT JOIN " + RetSqlName("NT0") + " NT0"
cRelQry +=       " ON NT0.NT0_COD = NUT.NUT_CCONTR "
cRelQry +=       " AND NT0.D_E_L_E_T_ = ' ' "
cRelQry +=       " AND NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "

//-------------------------------------------------------------------
// Filtros Padrões da query
//-------------------------------------------------------------------
Iif(!Empty(cGetGrup), cFilPrd += " AND NVE.NVE_CGRPCL = '"  + cGetGrup + "' ", ) //Grupo
Iif(!Empty(cGetClie), cFilPrd += " AND NVE.NVE_CCLIEN = '"  + cGetClie + "' ", ) //Cliente
Iif(!Empty(cGetLoja), cFilPrd += " AND NVE.NVE_LCLIEN = '"  + cGetLoja + "' ", ) //Loja
Iif(!Empty(cDtIni)  , cFilPrd += " AND NVE.NVE_DTENTR >= '" + cDtIni +   "' ", ) //Data Inicio
Iif(!Empty(cDtFim)  , cFilPrd += " AND NVE.NVE_DTENTR <= '" + cDtFim +   "' ", ) //Data Fim
cFilPrd += " AND NVE.NVE_FILIAL = '" + xFilial("NVE") + "' " 
cFilPrd += " AND NVE.D_E_L_E_T_ = ' ' " 

//-------------------------------------------------------------------
// Criando a Query
//-------------------------------------------------------------------
If lSemCon
	//Casos cobravéis sem contrato vinculado
	cQuery := cSelcQry
	cQuery += ", '" + StrTran(STR0125, ",", "-") + "' " + STR0129 + " " //Status
	cQuery += cRelQry // From e Joins

	cQuery += " WHERE NVE.NVE_COBRAV = '1' " 
	cQuery += cFilPrd //Filtros Padrões
	cQuery += " AND ( " 
	cQuery +=           " NUT.R_E_C_N_O_ IS NULL "  //Sem contrato
	cQuery +=        " OR NT0.NT0_SIT = '1' "       //Provisório
	cQuery +=        " OR NT0.NT0_ATIVO = '2' "     //Inativo
	cQuery +=      " ) " 
EndIf

If lCobHora
	//Caso por hora, mas com o contrato com honorarios diferente de por hora
	Iif (!Empty(cQuery), cQuery += " UNION ", )

	cQuery += cSelcQry
	cQuery += ", '" + StrTran(STR0126, ",", " -") + "' " + STR0129 + " " //Status
	cQuery += cRelQry // From e Joins
	cQuery += " INNER JOIN " + RetSqlName("NRA") + " NRA" 
	cQuery +=       " ON NRA.NRA_COD = NT0.NT0_CTPHON" 
	cQuery +=       " AND NRA.D_E_L_E_T_ = ' ' " 
	cQuery +=       " AND NRA.NRA_FILIAL = '" + xFilial("NRA") + "' " 

	cQuery += " WHERE NVE_LANTS = '1' " 
	cQuery += " AND NVE_ENCHON = '2' " 
	cQuery += " AND NVE_COBRAV = '1' " 
	cQuery += " AND NT0.NT0_SIT = '2' "    //Definitivo
	cQuery += " AND NT0.NT0_ATIVO = '1' "  //Ativo
	cQuery += " AND (NRA.NRA_COBRAH = '2' OR NT0.NT0_ENCH = '1') " 
	cQuery += cFilPrd //Filtros Padrões

EndIf

If lCobDesp
	//Caso com Despesa, verifica se está vinculado a algum contrato que cobre Despesas
	Iif (!Empty(cQuery), cQuery += " UNION ", )

	cQuery += cSelcQry
	cQuery += ", '" + StrTran(STR0127, ",", " -") + "' " + STR0129 + " " //Status
	cQuery += cRelQry // From e Joins

	cQuery += " WHERE NVE_LANDSP = '1' "
	cQuery += " AND NVE_ENCDES = '2' "
	cQuery += " AND NVE_COBRAV = '1' "
	cQuery += " AND NT0.NT0_SIT = '2' "    //Definitivo
	cQuery += " AND NT0.NT0_ATIVO = '1' "  //Ativo
	cQuery += " AND (NT0.NT0_DESPES = '2' OR NT0.NT0_ENCD = '1') "
	cQuery += cFilPrd //Filtros Padrões

EndIf

If lCobTab
	//Caso Tabelados, verifica se está vinculado a algum contrato que cobre Tabelado.
	Iif (!Empty(cQuery), cQuery += " UNION ", )

	cQuery += cSelcQry
	cQuery += ", '" + StrTran(STR0128, ",", " -") + "' " + STR0129 + " " //Status
	cQuery += cRelQry // From e Joins

	cQuery += " WHERE NVE_LANTAB = '1' "
	cQuery += " AND NVE_ENCTAB = '2' "
	cQuery += " AND NVE_COBRAV = '1' "
	cQuery += " AND NT0.NT0_SIT = '2' "    //Definitivo
	cQuery += " AND NT0.NT0_ATIVO = '1' "  //Ativo
	cQuery += " AND (NT0.NT0_SERTAB = '2' OR NT0.NT0_ENCT = '1') "
	cQuery += cFilPrd //Filtros Padrões

EndIf

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JA070ATU()
Atualiza a tela de Casos sem Contratos ao acionar o botão Atualizar.

@param  aStruAdic     Estrutora adicional para a função oTempTbCnt
@param  cQryNCnt      Query para ser criado novamente a tabela temporária
@param  oBrwNCnt      Objeto do browse passado por referência, para ser executado o Refresh()
@param  oTempTbCnt    Objeto da tabela temporária passado por referência, para a tabela ser excluída e ser criada novamente

@author Cristina Cintra
@since 09/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA070ATU(aStruAdic, cQryNCnt, oBrwNCnt, oTempTbCnt)
Local aArea  := GetArea()
Local cAlias := oTempTbCnt:GetAlias()

oTempTbCnt:Delete()

MsgRun(STR0088, STR0088, {|| oTempTbCnt := (JurCriaTmp(cAlias, cQryNCnt, "NVE",, aStruAdic))[1]}) //# Carregando...

oBrwNCnt:Refresh()
oBrwNCnt:GoTop(.T.)

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA070VLCAT()
Retorna o valor hora da categoria na tabela de honorários e dentro do período
informado.

@author Cristina Cintra
@since 03/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA070VLCAT(cTabh, cCateg, cAmIni, cAmFim)
Local nValor    := 0
Local cSQL      := ""

Default cTabh   := ""
Default cCateg  := ""
Default cAmIni  := ""
Default cAmFim  := ""

If !Empty(cTabh) .And. !Empty(cCateg) .And. !Empty(cAmIni)

	cSQL := " SELECT NTU_VALORH "
	cSQL +=   " FROM " + RetSqlname('NTV') + " NTV, " + RetSqlname('NTU') + " NTU "
	cSQL +=  " WHERE NTV_FILIAL = '" + xFilial("NTV") + "' "
	cSQL +=    " AND NTU_FILIAL = '" + xFilial("NTU") + "' "
	cSQL +=    " AND NTV.D_E_L_E_T_ = ' ' "
	cSQL +=    " AND NTU.D_E_L_E_T_ = ' ' "
	cSQL +=    " AND ((NTV_AMINI <= '" + cAmIni + "' AND NTV_AMFIM >= '" + cAmIni + "' ) OR "
	cSQL +=        " (NTV_AMINI <= '" + cAmIni + "' AND (NTV_AMFIM  = '" + cAmFim + "' OR NTV_AMFIM = '" + CriaVar("NTV_AMFIM", .F.) + "' ) ) ) "
	cSQL +=    " AND NTV_COD  = NTU_CHIST "
	cSQL +=    " AND NTV_CTAB = '" + cTabh + "' "
	cSQL +=    " AND NTV_CTAB = NTU_CTAB "
	cSQL +=    " AND NTU_CCAT = '" + cCateg + "' "

	aSqlRet := JurSQL(cSQL, {"NTU_VALORH"})

	If !Empty(aSqlRet)
		nValor := aSqlRet[1][1]
	EndIf

EndIf

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} J070PFluig()
Cria ou altera as pastas relacionadas ao caso incluido ou alterado.

@param  cChave Chave da Tabela NZ7
		cTitulo Titulo do Caso

@author Andre Lago
@since 10/04/2015
@version 1.0

@Obs Não retirar o DbCommitAll() é preciso confirmar a inclusão do registro
dentro da transação do remanejamento de caso.
/*/
//-------------------------------------------------------------------
Function J070PFluig(cChave, cTitulo, cTipoAssJu)
Local aArea        := GetArea()
Local aAreaNVE     := NVE->( GetArea() )
Local aAreaNYB     := NYB->( GetArea() )
Local aAreaNZ7     := NZ7->( GetArea() )
Local nPstPai      := 0
Local xRet
Local cIdPst       := ""
Local cErro        := ""
Local cStatus      := ""
Local cUsuario     := AllTrim(SuperGetMV('MV_ECMUSER',, ""))
Local cSenha       := AllTrim(SuperGetMV('MV_ECMPSW',, ""))
Local nEmpresa     := AllTrim(SuperGetMV('MV_ECMEMP',, 0))
Local aPstFil      := StrtoKArr(AllTrim(SuperGetMV('MV_JFLSUBP',, "")), ";/\,")
Local cPstFil      := ""
Local cColId       := ""
Local ni           := 0
Local aDadosNYB    := {}

Default cTipoAssJu := ""

//Carrega tipo do assunto juridico
If Empty(cTipoAssJu) .And. Type("cTipoAsj") == "C" .And. !Empty(cTipoAsj)
	cTipoAssJu := cTipoAsj
EndIf

If Empty(cTipoAssJu)
	NSZ->( DbSetOrder(2) )	// NSZ_FILIAL+NSZ_CCLIEN+NSZ_LCLIEN+NSZ_NUMCAS
	If NSZ->( DbSeek(xFilial("NSZ") + cChave) )
		cTipoAssJu := NSZ->NSZ_TIPOAS
	EndIf
EndIf

//Carrega informações do tipo do assunto jurídico
aDadosNYB := JurGetDados("NYB", 1, xFilial("NYB") + cTipoAssJu, {"NYB_IDGED", "NYB_IDGRP"})

If Len(aDadosNYB) == 0
	cErro := STR0161 //"Não foi possível carrega informações do tipo de assunto jurídico."
Else
	If !Empty(aDadosNYB[1])//se o campo NYB_IDGED estiver vazio, não atualiza a pasta
		ProcRegua(0)
		IncProc()
		IncProc()

		NZ7->(dbSetOrder(1))
		If NZ7->(dbSeek(xFilial("NZ7") + cChave))

			//Codigo da pasta do caso no fluig
			nPstPai := Left(NZ7->NZ7_LINK, At(";", NZ7->NZ7_LINK) - 1)

			//Verifica se ja tem link entre o fluig x caso ou o titulo do caso foi alterado
			If Empty(nPstPai) .Or. ( !Empty(cTitulo) .And. AllTrim(cTitulo) <> AllTrim(NZ7->NZ7_TITULO) )

				If Empty(cTitulo)
					cTitulo := AllTrim(NZ7->NZ7_TITULO)
				EndIf

				If Empty(nPstPai)

					//Codigo da pasta do assunto jurídico no fluig
					nPstPai := Left(aDadosNYB[1], At(";", aDadosNYB[1]) - 1)

					//Criar um diretorio no Fluig (Pasta do caso)
					cErro := J070AtPstF("1", nPstPai, NZ7->NZ7_CCLIEN + "-" + NZ7->NZ7_LCLIEN + "-" + NZ7->NZ7_NUMCAS + "-" + AllTrim(cTitulo), cUsuario, cSenha, nEmpresa, @cIdPst)

					If !Empty(cErro)
						cIdPst  := ""
						cStatus := "1"
					Else
						cStatus := "2"
					EndIf

				Else

					//Atualiza um diretorio, no Fluig
					cErro := J070AtPstF("2", nPstPai, NZ7->NZ7_CCLIEN + "-" + NZ7->NZ7_LCLIEN + "-" + NZ7->NZ7_NUMCAS + "-" + AllTrim(FwNoAccent(cTitulo)), cUsuario, cSenha, nEmpresa, @cIdPst)

					If !Empty(cErro)
						cIdPst  := NZ7->NZ7_LINK
						cStatus := "1"
					Else
						cStatus := "2"
					EndIf
				EndIf

				If Empty(cErro)
					RecLock("NZ7", .F.)
					NZ7->NZ7_TITULO := cTitulo
					NZ7->NZ7_STATUS := cStatus
					NZ7->NZ7_LINK   := cIdPst
					NZ7->( MsUnLock() )

					//Retorna pastas do fluig que existem abaixo da pasta do caso
					cColId  := JColId(cUsuario, cSenha, nEmpresa, cUsuario)
					cPstFil := JGetSPst(nPstPai, cUsuario, cSenha, nEmpresa, cColid)
				EndIf
			EndIf

		Else

			NVE->( DbSetOrder(1) )
			If NVE->( DbSeek(xFilial("NVE") + cChave) )

				//Codigo da pasta do assunto jurídico no fluig
				nPstPai := Left(aDadosNYB[1], At(";", aDadosNYB[1]) - 1)

				//Criar um diretorio no Fluig (Pasta do caso)
				cErro := J070AtPstF("1", nPstPai, NVE->NVE_CCLIEN + "-" + NVE->NVE_LCLIEN + "-" + NVE->NVE_NUMCAS + "-" + AllTrim(NVE->NVE_TITULO), cUsuario, cSenha, nEmpresa, @cIdPst)

				If !Empty(cErro)
					cIdPst  := ""
					cStatus := "1"
				Else
					cStatus := "2"
				EndIf

				If Empty(cErro)
					RecLock("NZ7", .T.)
					NZ7->NZ7_FILIAL := xFilial("NZ7")
					NZ7->NZ7_CCLIEN := NVE->NVE_CCLIEN
					NZ7->NZ7_LCLIEN := NVE->NVE_LCLIEN
					NZ7->NZ7_NUMCAS := NVE->NVE_NUMCAS
					NZ7->NZ7_CAREAJ := NVE->NVE_CAREAJ
					NZ7->NZ7_CPART1 := NVE->NVE_CPART1
					NZ7->NZ7_TITULO := NVE->NVE_TITULO
					NZ7->NZ7_STATUS := cStatus
					NZ7->NZ7_LINK   := cIdPst
					NZ7->( MsUnLock() )
					DbCommitAll()
				EndIf
			EndIf

		EndIf

		If Empty(cErro)

			//Verifica se a pasta foi criada no fluig
			nPstPai := Left(cIdPst, At(";", cIdPst) - 1)
			If ( Empty(cStatus) .Or. cStatus == "2" ) .And. !Empty(nPstPai)
				//Inclui permissão a pasta do caso para o grupo do assunto juridico, no Fluig.
				cErro := J163SetPer(nPstPai, cUsuario, cSenha, nEmpresa, "2", AllTrim(aDadosNYB[2]), .T.)
			EndIf

			//Cria pastas abaixo do caso no fluig definidas pelo parâmetro MV_JFLSUBP quando não existirem
			For ni:=1 To Len(aPstfil)
				If !"<documentDescription>"+AllTrim(aPstFil[ni]) $ cPstFil
					xRet := JMkPst(nPstPai, AllTrim(aPstFil[ni]), cUsuario, cSenha, nEmpresa)
				EndIf
			Next
		EndIf
	EndIf
EndIf

If !Empty(cErro) //Grava erro
	JurConout(cErro)
EndIf

RestArea(aAreaNZ7)
RestArea(aAreaNYB)
RestArea(aAreaNVE)
RestArea(aArea)

Return cStatus

//-------------------------------------------------------------------
/*/{Protheus.doc} Jur070LOk
Validação de linha: Não permitir inclusão de linha sem participante 
preenchido. NUK, NVF e NV0.

@return lRet  .T./.F. As informações são válidas ou não

@author Cristina Cintra
@since 30/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Jur070LOk(oGrid, cModelId)
Local lRet       := .T.
Local nLinha     := 0
Local nOperation := oGrid:GetModel():GetOperation()
Local nI         := 0
Local nLines     := 0
Local oModelX    := Nil
Local cPart      := ""

If nOperation == 3 .Or. nOperation == 4

	oModelX := oGrid:GetModel():GetModel( cModelId )
	nLinha  := oModelX:Length()
	nLines  := oModelX:GetQtdLine()

	If cModelId == "NUUDETAIL"
		lRet := J170ValNUU(oModelX, nLinha)
	Else
		If !oModelX:IsEmpty()
			For nI := 1 To nLines
				cPart := oModelX:GetValue(Substr(cModelId, 1, 3) + "_CPART", nI)
				If !oModelX:IsDeleted(nI) .And. Empty(cPart)
					lRet := JurMsgErro(STR0145) // "O participante não foi preenchido. Verifique!"
					Exit
				EndIf
			Next nI
		EndIf
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J170ValNUU
Valida a obrigatoriedade de preenchimento do campo "NUU_CTABH" quando
a integração com SIGAJURI estiver habilitada.

@param   oGridNUU, objeto  , Grid do histórico do caso
@param   nLinha  , numerico, Linha atual do histórico do caso

@return  lLinNUU , logico, Verdadeiro/Falso

@author  Jonatas Martins
@since   21/08/2018
@obs     Função chamada na pós-validação de linha do Grid NUU
/*/
//-------------------------------------------------------------------
Static Function J170ValNUU(oGridNUU, nLinha)
Local cIntegra  := SuperGetMV("MV_JFTJURI",, "2") // Integração SIGAJURI
Local lLinNUU   := .T.
Local cTabHTit  := ""

If cIntegra == "1"
	If Empty(oGridNUU:GetValue("NUU_CTABH", nLinha))
		cTabHTit := Alltrim(RetTitle("NUU_CTABH"))
		lLinNUU  := JurMsgErro(STR0162, "J170ValNUU", I18N(STR0163, {'"' + cTabHTit + '"'})) // "Campo obrigatório não preenchido!" # "Preencha o campo #1."
	EndIf
EndIf

Return (lLinNUU)

//-------------------------------------------------------------------
/*/{Protheus.doc} J070PWork()
Cria ou altera as pastas relacionadas ao caso incluido ou alterado na
tabela NZ7 que é usada pelo WorkSite.

@param  cChave Chave da Tabela NZ7 cTitulo Titulo do Caso

@author André Spirigoni Pinto
@since 28/04/2016
@version 1.0

@Obs Não retirar o DbCommitAll() é preciso confirmar a inclusão do registro
dentro da transação do remanejamento de caso.
/*/
//-------------------------------------------------------------------
Function J070PWork(cChave, cTitulo)
Local aArea    := GetArea()
Local aAreaNVE := NVE->( GetArea() )

NZ7->(dbSetOrder(1))
If NZ7->(dbSeek(xFilial("NZ7")+cChave))
	//Atualiza o título do caso e muda para pendente
	If (!(AllTrim(cTitulo) == AllTrim(NZ7->NZ7_TITULO)))

		If Empty(cTitulo)
			cTitulo := AllTrim(NZ7->NZ7_TITULO)
		EndIf

		RecLock("NZ7", .F.)
		NZ7->NZ7_TITULO := cTitulo
		NZ7->NZ7_STATUS := "1" //pendente
		NZ7->(MsUnLock())

	EndIf
Else
	NVE->(dbSetOrder(1))
	If NVE->(dbSeek(xFilial("NVE") + cChave))
		RecLock("NZ7", .T.)
		NZ7->NZ7_FILIAL := xFilial("NZ7")
		NZ7->NZ7_CCLIEN := NVE->NVE_CCLIEN
		NZ7->NZ7_LCLIEN := NVE->NVE_LCLIEN
		NZ7->NZ7_NUMCAS := NVE->NVE_NUMCAS
		NZ7->NZ7_CAREAJ := NVE->NVE_CAREAJ
		NZ7->NZ7_CPART1 := NVE->NVE_CPART1
		NZ7->NZ7_TITULO := NVE->NVE_TITULO
		NZ7->NZ7_STATUS := "1" //pendente
		NZ7->(MsUnLock())
		DbCommitAll()
	EndIf

EndIf

RestArea(aAreaNVE)
RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JA070DLG()
Tela de parâmetros para fazer filtro dos casos sem contrato.

@obs Campos cGetGrup, cGetClie, cGetLoja devem ser privados devido a 
função JA202VLTRA, que válida os campos

@author Bruno Ritter
@since 16/09/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA070DLG()
Local aArea      := GetArea()
Local oGetGrup   := Nil
Local oGetClie   := Nil
Local oGetLoja   := Nil
Local oDlg       := Nil
Local lSemCon    := .T.
Local oSemCon    := Nil
Local lCobHora   := .T.
Local oCobHora   := Nil
Local lCobDesp   := .T.
Local oCobDesp   := Nil
Local lCobTab    := .T.
Local oCobTab    := Nil
Local lRet       := .T.
Local dDtIni     := CToD( '01/01/1900' )
Local dDtFim     := Date()
Local oDtIni     := Nil
Local oDtFim     := Nil
Local bBtOk      := {|| }
Local oLayer     := FWLayer():New()
Local oMainColl  := Nil
Local bTitulo    := { |cCampo| SX3->(DbSetOrder(2)), SX3->(DbSeek(cCampo)), AllTrim(X3Titulo()) }
Local cTitDtIni  := Eval(bTitulo, 'NVE_DTENTR') + " " + STR0151 // "início"
Local cTitDtFim  := Eval(bTitulo, 'NVE_DTENTR') + " " + STR0152 // "fim"
Local cTitGruCl  := Eval(bTitulo, 'NVE_CGRPCL')
Local cTitCodCl  := Eval(bTitulo, 'NVE_CCLIEN')
Local cTitLojCl  := Eval(bTitulo, 'NVE_LCLIEN')
Local cLojaAuto  := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

Private cGetGrup := Criavar("NVE_CGRPCL", .F.)
Private cGetClie := Criavar("NVE_CCLIEN", .F.)
Private cGetLoja := Criavar("NVE_LCLIEN", .F.)

DEFINE MSDIALOG oDlg TITLE STR0090 FROM 0, 0 TO 280, 480 PIXEL // "# Casos sem contrato"

oLayer:init(oDlg, .F.) //Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
oLayer:addCollumn("MainColl", 100, .F.) //Cria as colunas do Layer
oMainColl := oLayer:GetColPanel( 'MainColl' )

oGetGrup := TJurPnlCampo():New(05, 05, 50, 22, oMainColl, cTitGruCl, ("A1_GRPVEN"), {|| }, {|| },,,, 'ACY') // "Grupo"
oGetGrup:SetValid({||  JurTrgGCLC( @oGetGrup, @cGetGrup, @oGetClie, @cGetClie, @oGetLoja, @cGetLoja, , , "GRP") })

oGetClie := TJurPnlCampo():New(05, 70, 50, 22, oMainColl, cTitCodCl, ("A1_COD"), {|| }, {|| },,,, 'SA1NVE') // "Cliente"
oGetClie:SetValid({|| JurTrgGCLC( @oGetGrup, @cGetGrup, @oGetClie, @cGetClie, @oGetLoja, @cGetLoja, , , "CLI") })

oGetLoja := TJurPnlCampo():New(05, 130, 40, 22, oMainColl, cTitLojCl, ("A1_LOJA"), {|| }, {|| },,,,) // "Loja"
oGetLoja:SetValid({|| JurTrgGCLC( @oGetGrup, @cGetGrup, @oGetClie, @cGetClie, @oGetLoja, @cGetLoja, , , "LOJ")})
oGetLoja:Visible(cLojaAuto == "2")

oSemCon := TJurCheckBox():New(35, 05, STR0125, {|| }, oMainColl, 220, 008, , {|| }, , , , , , .T., , , ) //"Apresenta minutas?"
oSemCon:SetCheck(lSemCon)
oSemCon:bChange := {|| lSemCon := oSemCon:Checked() }

oCobHora := TJurCheckBox():New(45, 05, STR0126, {|| }, oMainColl, 220, 008, , {|| }, , , , , , .T., , , ) //"Apresenta minutas?"
oCobHora:SetCheck(lCobHora)
oCobHora:bChange := {|| lCobHora := oCobHora:Checked() }

oCobDesp := TJurCheckBox():New(55, 05, STR0127, {|| }, oMainColl, 220, 008, , {|| }, , , , , , .T., , , ) //"Apresenta minutas?"
oCobDesp:SetCheck(lCobDesp)
oCobDesp:bChange := {|| lCobDesp := oCobDesp:Checked() }

oCobTab := TJurCheckBox():New(65, 05, STR0128, {|| }, oMainColl, 220, 008, , {|| }, , , , , , .T., , , ) //"Apresenta minutas?"
oCobTab:SetCheck(lCobTab)
oCobTab:bChange := {|| lCobTab := oCobTab:Checked() }

oDtIni := TJurPnlCampo():New(80, 05, 60, 22, oMainColl, cTitDtIni, 'NVE_DTENTR', {|| }, {|| }, DtoC(dDtIni),,,) // "Data Entrada início: "
oDtIni:SetChange({|| (dDtIni := oDtIni:Valor)})

oDtFim := TJurPnlCampo():New(80, 70, 60, 22, oMainColl, cTitDtFim, 'NVE_DTENTR', {|| }, {|| }, DtoC(dDtFim),,,) // "Data Entrada fim: "
oDtFim:SetChange({|| (dDtFim := oDtFim:Valor)})

bBtOk := {|| (lRet := (JA070NoCont(cGetGrup, cGetClie, cGetLoja, lSemCon, lCobHora, lCobDesp, lCobTab, dDtIni, dDtFim)), IIf(lRet == .T., oDlg:End(), .F.)) }

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,;
															{|| MsgRun(STR0088, STR0088, bBtOk)},; //# "Carregando..."
															{|| (oDlg:End())},;
															, /*aButtons*/, /*nRecno*/, /*cAlias*/, .F., .F., .F., .T., .F.)

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J070AtPstF()
Efetua alteração em uma pasta no Fluig.

@param   cTipo - 1=Inclui 2=Altera

@author  Rafael Tenorio da Costa
@since   08/07/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J070AtPstF(cTipo, cPasta, cDescPasta, cUsuario, cSenha, cEmpresa, cIdPst)
	Local cErro    := ""
	Local cAviso   := ""
	Local xRet     := ""
	Local cJMkPst  := "oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_CREATESIMPLEFOLDERRESPONSE:_RESULT:_ITEM" //Informa o caminho para acessar o cabecalho da msg XML de criação
	Local cJUpSPst := "oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_UPDATESIMPLEFOLDERRESPONSE:_RESULT:_ITEM" //Informa o caminho para acessar o cabecalho da msg XML de atualização
	Local cXml     := ""

	Private oXml   := Nil //Necessario por causa da macro execução

	//Criar um diretorio no Fluig (Pasta do caso)
	If cTipo == "1"
		cXml := cJMkPst
		xRet := JMkPst(cPasta, cDescPasta, cUsuario, cSenha, cEmpresa)

	//Atualiza um diretorio, no Fluig
	Else
		cXml := cJUpSPst
		xRet := JUpSPst(cPasta, cDescPasta, cUsuario, cSenha, cEmpresa)
	EndIf

	If "WEBSERVICEMESSAGE" $ Upper(xRet)

		oXml := XmlParser(xRet, "_", @cErro, @cAviso)

		If oXml <> Nil

			If XmlChildEx( &(cXml), "_WEBSERVICEMESSAGE") <> Nil

				If &(cXml + ":_WEBSERVICEMESSAGE:TEXT") <> "ok"
					cIdPst := ""
					cErro  := &(cXml + ":_WEBSERVICEMESSAGE:TEXT")
				Else
					cIdPst := AllTrim( &(cXml + ":_DOCUMENTID:TEXT") ) + ";"
					cIdPst += AllTrim( &(cXml + ":_VERSION:TEXT") )
				EndIf
			EndIf

		Else
			//³Retorna falha no parser do XML³
			cErro := I18n(STR0142 + " #1 - #2", {cPasta, cDescPasta}) //"Objeto XML nao criado, verificar a estrutura do XML"
		EndIf

		FwFreeObj(oXml)
	Else

		cErro := I18n(STR0160, {"(J070AtPstF)", xRet}) //"Retorno desconhecido: #1 #2"
	EndIf

Return cErro

//-------------------------------------------------------------------
/*/{Protheus.doc} J70CasoEnc()
Verifica se o caso esta encerrado a partir do link com o fluig.

@author  Rafael Tenorio da Costa
@since   21/08/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J70CasoEnc(cLink)
	Local aArea    := GetArea()
	Local lRetorno := .F.
	Local cSql     := ""
	Local aSqlRet  := {}

	cSql := " SELECT NSZ_FILIAL, NSZ_COD"
	cSql += " FROM " + RetSqlname("NSZ") + " NSZ INNER JOIN " + RetSqlname("NZ7") + " NZ7"
	cSql +=   " ON NZ7_FILIAL = '" + xFilial("NZ7") + "' AND NSZ_CCLIEN = NZ7_CCLIEN AND NSZ_LCLIEN = NZ7_LCLIEN AND NSZ_NUMCAS = NZ7_NUMCAS AND NSZ.D_E_L_E_T_ = NZ7.D_E_L_E_T_"
	cSql += " WHERE NSZ_FILIAL = '" + xFilial("NSZ") + "'"
	cSql +=   " AND NSZ_SITUAC = '2'" // 2=Encerrado
	cSql +=   " AND NZ7_LINK LIKE '" + cLink + ";" + "%'"
	cSql +=   " AND NSZ.D_E_L_E_T_ = ' '"

	aSqlRet := JurSQL(cSql, {"NSZ_FILIAL", "NSZ_COD"})

	If Len(aSqlRet) > 0
		lRetorno := .T.
	EndIf

	RestArea(aArea)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} J070ClxGr()
Rotina para verificar se o cliente/loja pertence ao grupo.
Usado nos gatilhos de Grupo

@Return - lRet  .T. quando o cliente PERTENCE ao grupo informado OU
                .F. quando o cliente NÃO pertence ao grupo informado

@author Bruno Ritter
@since 04/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J070ClxGr()
Local lRet    := .F.
Local oModel  := FwModelActive()
Local cGrupo  := ''
Local cClien  := ''
Local cLoja   := ''

If (oModel:cId != 'JURA070') // Se o Model que vier carregado for diferente do JURA070, carrega o Modelo correspondente do JURA070
	oModel := FWLoadModel( 'JURA070' )
	oModel:Activate()
EndIf

cGrupo  := oModel:GetValue("NVEMASTER", "NVE_CGRPCL")
cClien  := oModel:GetValue("NVEMASTER", "NVE_CCLIEN")
cLoja   := oModel:GetValue("NVEMASTER", "NVE_LCLIEN")

If FindFunction("JurClxGr") //PROTEÇÃO
	lRet := JurClxGr(cClien, cLoja, cGrupo)
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J070ArPart()
Função para pré arredondar um percentual de participação e no histórico.

@return nRet Valor Arredondado ou o próprio valor.

@author Bruno Ritter
@since 14/02/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J070ArPart()
Local oModel     := FWModelActive()
Local cAlias     := SubStr(ReadVar(), 4, 3)
Local cTipoOrig  := oModel:GetValue(cAlias + "DETAIL", cAlias + "_CTIPO")
Local nPerc      := oModel:GetValue(cAlias + "DETAIL", cAlias + "_PERC")
Local nRet       := JurArrPart(cAlias + "_PERC", nPerc, cTipoOrig)

	If (nRet != nPerc)
		oModel:LoadValue(cAlias + "DETAIL", cAlias + "_PERC", nRet)
	EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA070WhExc
Verifica a operação do modelo e retorna se é inclusão ou não.
Usado para bloquear as abas de Exceção na Tab Honorários, pois suas info
não deverão ficar disponíveis na inclusão.

@Return   lRet  .T. quando a operação do modelo for diferente de Inclusão
                .F. quando a operação do modelo for Inclusão

@author Cristina Cintra
@since 23/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA070WhExc()
Local oModel   := FWModelActive()
Local lRet     := .T.

If !FWIsInCallStack('JURA063')
	lRet := oModel:GetOperation() != 3
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA070VLIM()
Validação do valor limite

@return lRet .T. se  o valor e maior ou igual ao valor faturado

@author Queizy Nascimento/Anderson Carvalho
@since 11/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA070VLIM()
Local lRet := .T.

	If FWIsInCallStack("JURA070") .And. JA070SDLIM() < 0
		lRet := JurMsgErro(STR0167) // "O Valor Limite do caso não pode ser menor que a soma do saldo inicial mais os valores já faturados!"
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA070SDLIM
Retorna o saldo disponivel do valor limite

@return nSaldo

@author Queizy Nascimento/Anderson Carvalho
@since 11/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA070SDLIM()
Local aArea    := GetArea()
Local nSaldo   := 0
Local cClient  := M->NVE_CCLIEN
Local cLoja    := M->NVE_LCLIEN
Local cCaso    := M->NVE_NUMCAS
Local cMoeLim  := M->NVE_CMOELI
Local nValLim  := M->NVE_VLRLI

	If FindFunction('J201GSldCs') .And. !Empty(cMoeLim) .And. !Empty(nValLim)
		nSaldo := J201GSldCs(cClient, cLoja, cCaso, '2', .T.)
	EndIf

	RestArea(aArea)

Return nSaldo

//-------------------------------------------------------------------
/*/{Protheus.doc} JA070REMAN()
Rotina para adicionar ao menu o remanejamento de casos.

@return Nil

@author Luciano Pereira dos Santos
@since 06/02/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA070REMAN()

	JURA063(NVE->NVE_CCLIEN, NVE->NVE_LCLIEN, NVE->NVE_NUMCAS)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J070ValNeg
Valida valor negativo quando a regra for do tipo Fixo.
Chamada no dicionário e na pós validação da linha.

@author  Jonatas Martins
@since   06/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J070ValNeg(cCampo, oModelOHR)
	Local oModel      := Nil
	Local cRegra      := ""
	Local nValor      := 0
	Local lRet        := .T.

	Default oModelOHR := Nil

	If oModelOHR == Nil
		oModel    := FWModelActive()
		oModelOHR := oModel:GetModel('OHRDETAIL')
	EndIf

	cRegra := oModelOHR:GetValue("OHR_REGRA")
	nValor := oModelOHR:GetValue("OHR_VALOR")

	If !Empty(cRegra) .And. (cRegra == '3') .And. nValor < 0  // Fixo
		lRet := JurMsgErro(STR0170, , i18N(STR0171, {Alltrim(RetTitle(cCampo))} )) // "Para o tipo de Regra 'Fixo' não é permitido valor negativo." / "Verifique o campo ('#1')."
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J070Sheet
Função para criar aba na tela de casos através do ponto de entrada

@param oModel, objeto, Estrutura do modelo de dados de casos
@param oView , objeto, Estrutura da tela de casos

@author Jonatas Martins
@since  04/05/2019
/*/
//-------------------------------------------------------------------
Static Function J070Sheet(oModel, oView)
	Local cSheetName := "DEFAULT"
	Local cTablePE   := ""
	Local cModelID   := ""
	Local cViewID    := ""
	Local cOrder     := ""
	Local aSheet     := {}
	Local aRelation  := {}
	Local aRemovePE  := {}
	Local aUniqueLin := {}
	Local nIndexPE   := 1
	Local nField     := 0
	Local lGrid      := .F.
	Local oMStructPE := Nil
	Local oVStructPE := Nil

	aSheet := ExecBlock("J070Sheet", .F., .F.)

	If ValType(aSheet) == "A" .And. Len(aSheet) >= 5 .And. !Empty(aSheet[2])
		aRelation := aSheet[4]

		If ValType(aRelation) == "A" .And. Len(aRelation) == 3
			cSheetName := IIF(ValType(aSheet[1]) <> "C" .Or. Empty(aSheet[1]), cSheetName, AllTrim(aSheet[1]))
			cTablePE   := AllTrim(SubStr(aSheet[2], 1, 3))
			lGrid      := IIF(ValType(aSheet[3]) <> "L", .F., aSheet[3])
			cModelID   := cTablePE + IIF(lGrid, "DETAIL", "MASTER")
			cViewID    := cTablePE + "_VIEW"
			nIndexPE   := IIF(ValType(aSheet[5]) <> "N", nIndexPE, aSheet[5])
			aRelation  := {{cTablePE + "_FILIAL", "xFilial('" + cTablePE + "')"},;
							{aRelation[1], "NVE_CCLIEN"},;
							{aRelation[2], "NVE_LCLIEN"},;
							{aRelation[3], "NVE_NUMCAS"}}
			
			// Monta esturura do Model
			oMStructPE := FWFormStruct(1, cTablePE)
			If lGrid
				oModel:AddGrid(cModelID, "NVEMASTER", oMStructPE)
				oModel:SetOptional(cModelID, .T.)
				aUniqueLin := IIF(Len(aSheet) >= 7, aSheet[7], Nil)
				If ValType(aUniqueLin) == "A"
					oModel:GetModel(cModelID):SetUniqueLine(aUniqueLin)
				EndIf
			Else
				oModel:AddFields(cModelID, "NVEMASTER", oMStructPE)
			EndIf
			cOrder := &(cTablePE)->(IndexKey(nIndexPE))
			oModel:SetRelation(cModelID, aRelation, cOrder)
			oModel:GetModel(cModelID):SetDescription(cSheetName + "Ponto de Entrada")

			// Monta estutura do View
			oVStructPE := FWFormStruct(2, cTablePE)
			oVStructPE:RemoveField(aRelation[2][1])
			oVStructPE:RemoveField(aRelation[3][1])
			oVStructPE:RemoveField(aRelation[4][1])
			If lGrid
				oView:AddGrid(cViewID, oVStructPE, cModelID)
				// Campo de incremento
				If Len(aSheet) == 8 .And. !Empty(aSheet[8])
					oView:AddIncrementField(cModelID, aSheet[8])
				EndIf
			Else
				oView:AddField(cViewID, oVStructPE, cModelID)
			EndIf
			//Remove campos da View
			aRemovePE := IIF(Len(aSheet) >= 6 .And. ValType(aSheet[6]) == "A", aSheet[6], Nil)
			For nField := 1 To Len(aRemovePE)
				If !Empty(aRemovePE[nField])
					oVStructPE:RemoveField(aRemovePE[nField])
				EndIf
			Next nField
			oView:AddSheet("FOLDER_01", "SHEET_PE", cSheetName)
			oView:createHorizontalBox("BOXPE", 100,,, "FOLDER_01", "SHEET_PE")
			oView:SetOwnerView(cViewID, "BOXPE")
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA070VlSit
Valida a situacao do cliente x Situacao do Caso

@param oModel, objeto, Estrutura do modelo de dados de casos

@author fabiana.silva
@since  19/01/2021
/*/
//-------------------------------------------------------------------
Static Function JA070VlSit(oModel)
Local lOk       := .T.
Local aContrato := {}
Local oModelNVE := oModel:GetModel("NVEMASTER")

	If oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4

		If oModelNVE:GetValue("NVE_SITCAD") == "2"
			If JurGetDados("NUH", 1, xFilial('NUH') + oModelNVE:GetValue("NVE_CCLIEN") + oModelNVE:GetValue("NVE_LCLIEN"), "NUH_SITCAD") <> "2"
				lOk := JurMsgErro(STR0180, , STR0177) // "Situação do caso inválida." # "Somente casos provisórios podem ser vinculados a clientes provisórios."
			EndIf
		Else
			// Valida se existem contratos ativos e definitivos
			cQuery := "SELECT NT0.NT0_COD "
			cQuery +=  " FROM " + RetSqlName("NT0") + " NT0 "
			cQuery += " INNER JOIN " + 	RetSqlName("NUT") + " NUT "
			cQuery +=    " ON NUT.NUT_FILIAL = '" + xFilial("NUT") + "' "
			cQuery +=   " AND NUT.NUT_CCLIEN = '" + oModelNVE:GetValue("NVE_CCLIEN") + "' "
			cQuery +=   " AND NUT.NUT_CLOJA  = '" + oModelNVE:GetValue("NVE_LCLIEN") + "' "
			cQuery +=   " AND NUT.NUT_CCASO  = '" + oModelNVE:GetValue("NVE_NUMCAS") + "' "
			cQuery +=   " AND NUT.NUT_CCONTR =  NT0.NT0_COD "
			cQuery +=   " AND NUT.D_E_L_E_T_ = ' ' "
			cQuery += " WHERE NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "
			cQuery +=   " AND NT0.NT0_SIT    = '2' "
			cQuery +=   " AND NT0.NT0_ATIVO  = '1' "
			cQuery +=   " AND NT0.D_E_L_E_T_ = ' ' "

			aContrato := JurSql(cQuery, {"NT0_COD"})
			If Len(aContrato) > 0 .And. !Empty(aContrato[01, 01])
				lOk := JurMsgErro(STR0180, , STR0178) // "Situação do caso inválida." # "Este caso está vinculado a um contrato definitivo. Para alterar a situação do caso para provisório é necessário desvincular o caso do contrato."
			EndIf
		EndIf
	EndIf

Return lOK

//-------------------------------------------------------------------
/*/{Protheus.doc} J070VldVig
Valida sobreposição do período de vigência dos contratos vinculados 
ao caso.

Esta função é executada na validação de cada linha da NUT e analisa 
a vigência comparando todos os contratos vinculados com a mesma 
forma de cobrança do contrato atual (hora, despesa, tabelado)

@param  oModelNUT, Modelo de dados de Contratos x Casos
@param  aHora    , Array com códigos dos contratos que cobram hora
@param  aDesp    , Array com códigos dos contratos que cobram despesa
@param  aTab     , Array com códigos dos contratos que cobram tabelado
@param  lVldHora , Indica se devem ser validados os contratos que cobram hora
@param  lVldDesp , Indica se devem ser validados os contratos que cobram despesa
@param  lVldTab  , Indica se devem ser validados os contratos que cobram tabelado

@return cErro    , Mensagem de erro quando houver períodos sobrepostos
                   Retorna em branco caso não tenha erros

@author Jorge Martins
@since  03/03/2021
/*/
//-------------------------------------------------------------------
Static Function J070VldVig(oModelNUT, aHora, aDesp, aTab, lVldHora, lVldDesp, lVldTab)
Local cErro := ""

	If oModelNUT:IsUpdated() // Valida somente as linhas que foram alteradas
		cErro := IIf(lVldHora .And. Len(aHora) > 1                   , J070VldTpV(oModelNUT, aHora, STR0024), cErro) // Valida vigência dos contratos que cobram hora     - "É possível relacionar apenas um contrato que cobre por hora. ("###")"
		cErro := IIf(lVldDesp .And. Len(aDesp) > 1 .And. Empty(cErro), J070VldTpV(oModelNUT, aDesp, STR0025), cErro) // Valida vigência dos contratos que cobram despesa  - "É possível relacionar apenas um contrato que cobre despesa. ("###")"
		cErro := IIf(lVldTab  .And. Len(aTab)  > 1 .And. Empty(cErro), J070VldTpV(oModelNUT, aTab , STR0026), cErro) // Valida vigência dos contratos que cobram tabelado - "É possível relacionar apenas um contrato que cobre tabelado. ("###")"
	EndIf

Return cErro

//-------------------------------------------------------------------
/*/{Protheus.doc} J070VldTpV
Faz a validação de sobreposição do período de vigência dos contratos 
conforme o tipo de cobrança (valida separadamente os contratos que 
cobram hora, despesa e tabelado).

@param  oModelNUT , Modelo de dados de Contratos x Casos
@param  aContratos, Contratos que serão validados
@param  cMsgVld   , Mensagem de validação caso as datas estejam vazias
                    e exista mais de um contrato cobrando hora/despesa/tabelado

@return cErro     , Mensagem de erro quando houver períodos sobrepostos
                    Retorna em branco caso não tenha erros

@author Jorge Martins
@since  03/03/2021
/*/
//-------------------------------------------------------------------
Static Function J070VldTpV(oModelNUT, aContratos, cMsgVld)
Local nContr    := 0
Local cContrato := ""
Local cErro     := ""
Local aDadosVig := {}
Local dDtVigIni := Nil
Local dDtVigFim := Nil
Local cCaso     := oModelNUT:GetValue("NUT_CCASO")

	For nContr := 1 To Len(aContratos)
		cContrato := aContratos[nContr]
		If cContrato <> NT0->NT0_COD // Faz a validação comparando o registro atual com os outros que estiverem no array. Somente não compara o registro com ele mesmo.
			aDadosVig := JurGetDados("NT0", 1, xFilial("NT0") + cContrato, {"NT0_DTVIGI", "NT0_DTVIGF"})
			If !Empty(aDadosVig)
				dDtVigIni := aDadosVig[1] // Data Inicial da Vigência
				dDtVigFim := aDadosVig[2] // Data Final da Vigência
				
				// Valida se os 2 contratos estão com data de vigência em branco
				If Empty(dDtVigIni) .And. Empty(dDtVigFim) .And. Empty(NT0->NT0_DTVIGI) .And. Empty(NT0->NT0_DTVIGF)
					cErro := cMsgVld + AToC(aContratos) + STR0027
					Exit
				EndIf

				// Valida se um dos contratos tem vigência e o outro não
				If Empty(dDtVigIni) .And. Empty(dDtVigFim) .And. !Empty(NT0->NT0_DTVIGI) .And. !Empty(NT0->NT0_DTVIGF)
					cErro := I18N(STR0181, {cCaso, NT0->NT0_COD, cContrato}) // "Não é permitido vincular o caso '#1' a um contrato com vigência ('#2') e outro que não possui vigência preenchida ('#3') ao mesmo tempo."
					Exit
				EndIf
				
				// Valida se um dos contratos tem vigência e o outro não
				If !Empty(dDtVigIni) .And. !Empty(dDtVigFim) .And. Empty(NT0->NT0_DTVIGI) .And. Empty(NT0->NT0_DTVIGF)
					cErro := I18N(STR0181, {cCaso, cContrato, NT0->NT0_COD}) // "Não é permitido vincular o caso '#1' a um contrato com vigência ('#2') e outro que não possui vigência preenchida ('#3') ao mesmo tempo."
					Exit
				EndIf

				// Valida se existem vigências sobrepostas entre os dois contratos
				If (NT0->NT0_DTVIGI <= dDtVigIni) .And. (NT0->NT0_DTVIGF >= dDtVigIni) .And. (NT0->NT0_DTVIGI != NT0->NT0_DTVIGF)
					cErro := I18N(STR0182, {dDtVigIni, cContrato, NT0->NT0_COD}) // "A vigência inicial '#1' do contrato '#2' está sobrepondo a vigência do contrato '#3'."
					Exit
				EndIf

				// Valida se existem vigências sobrepostas entre os dois contratos
				If (NT0->NT0_DTVIGI >= dDtVigIni) .And. (NT0->NT0_DTVIGI <=  dDtVigFim) .And. (NT0->NT0_DTVIGI != NT0->NT0_DTVIGF)
					cErro := I18N(STR0183, {dDtVigFim, cContrato, NT0->NT0_COD}) // "A vigência final '#1' do contrato '#2' está sobrepondo a vigência do contrato '#3'."
					Exit
				EndIf

			EndIf
		EndIf
	Next

Return cErro

//-------------------------------------------------------------------
/*/{Protheus.doc} J070VlDesp
Busca lançamentos pendentes no caso no momento de encerrar a despesas

@param cEncDes, Despesa encerrada SIM x NÃO

@author Glória Maria
@since  25/08/2022
/*/
//-------------------------------------------------------------------
Function J070VlDesp(cEncDes)
Local lAviso    := .F.
Local cQuery    := ''
Local cResQRY   := ''
Local aArea     := NVE->(GetArea())
Local oModel    := FWModelActive()
Local cAviso    := ""
Local lRet      := .T.
Local cTitle    := STR0193 // "Despesas Pendentes"

	cCliente := oModel:GetValue("NVEMASTER", "NVE_CCLIEN")
	cLoja    := oModel:GetValue("NVEMASTER", "NVE_LCLIEN")
	cCaso    := oModel:GetValue("NVEMASTER", "NVE_NUMCAS")

	If ( cEncDes == '1' )
		cQuery := " SELECT COUNT(NVY.NVY_CCASO) COUNTDES "
		cQuery +=   " FROM " + RetSqlName( "NVY" ) + " NVY "
		cQuery +=  " WHERE NVY.D_E_L_E_T_ = ' '
		cQuery +=    " AND NVY.NVY_FILIAL = '" + xFilial( "NVE" ) + "' "
		cQuery +=    " AND NVY.NVY_CCLIEN = '" + cCliente + "' "
		cQuery +=    " AND NVY.NVY_CLOJA  = '" + cLoja + "' "
		cQuery +=    " AND NVY.NVY_CCASO  = '" + cCaso + "' "
		cQuery +=    " AND NVY.NVY_SITUAC = '1' "

		cQuery := ChangeQuery(cQuery)

		cResQRY := GetNextAlias()
		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cResQRY, .T., .T.)

		If (cResQRY)->COUNTDES > 0
			lAviso := .T.
			cAviso += STR0192 // "Existem despesas pendentes relacionadas a este caso. Caso deseje cancelar o encerramento de despesas, retorne o campo para '2-Não'"
		EndIf

		(cResQRY)->(dbCloseArea())
		
		If lAviso 
			ApMsgAlert(cAviso,cTitle)
		EndIf

	EndIf

	RestArea(aArea)

Return lRet
