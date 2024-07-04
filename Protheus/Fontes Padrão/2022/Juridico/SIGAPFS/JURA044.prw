#INCLUDE "JURA044.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA044
Tipo de despesas

@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA044()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NRH" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NRH" )
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
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA044", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA044", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA044", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA044", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA044", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Tipo de despesas

@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel     := FWLoadModel( "JURA044" )
Local oStructNRH := FWFormStruct( 2, "NRH" )
Local oStructNR4 := FWFormStruct( 2, "NR4" )
Local oStructNRM := FWFormStruct( 2, "NRM" )
Local oStructNYY := FWFormStruct( 2, "NYY" )
Local lUsaHist   := SuperGetMV( 'MV_JURHS1',, .F. )


oStructNR4:RemoveField( "NR4_CTDESP" )
oStructNR4:RemoveField( "NR4_DTDESP" )
oStructNRM:RemoveField( "NRM_CTIPO"  )
oStructNYY:RemoveField( "NYY_TIPO"  )

JurSetAgrp( 'NRH',, oStructNRH )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA044_VIEW", oStructNRH, "NRHMASTER"  )
oView:AddGrid(  "JURA044_NR4" , oStructNR4, "NR4IDIOMA"  )
oView:AddGrid(  "JURA044_NYY" , oStructNYY, "NYYTARIFA"  )
If lUsaHist
	oView:AddGrid(  "JURA044_NRM" , oStructNRM, "NRMDETAIL"  )
EndIf

oView:CreateFolder("FOLDER_01")

oView:AddSheet("FOLDER_01", "ABA_01_01", STR0007   ) //"Tipo de despesas"

oView:createHorizontalBox("BOX_01_F01_A01",40,,,"FOLDER_01","ABA_01_01")
oView:createHorizontalBox("BOX_02_F01_A01",30,,,"FOLDER_01","ABA_01_01")
oView:createHorizontalBox("BOX_03_F01_A01",30,,,"FOLDER_01","ABA_01_01")

oView:SetOwnerView( "JURA044_VIEW"  , "BOX_01_F01_A01" )
oView:SetOwnerView( "JURA044_NR4"  , "BOX_02_F01_A01" )
oView:SetOwnerView( "JURA044_NYY"  , "BOX_03_F01_A01" )

If lUsaHist
	oView:AddSheet("FOLDER_01", "ABA_01_02", STR0012   ) //"Histórico"
	oView:createHorizontalBox("BOX_01_F01_A02",100,,,"FOLDER_01","ABA_01_02")
	oView:SetOwnerView( "JURA044_NRM"  , "BOX_01_F01_A02" )
EndIf

oView:SetDescription( STR0007 ) // "Tipo de despesas"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Tipo de despesas

@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0

@obs NRHMASTER - Dados do Tipo de despesas
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel      := NIL
Local oStructNRH  := FWFormStruct( 1, "NRH" )
Local oStructNR4  := FWFormStruct( 1, "NR4" )
Local oStructNRM  := FWFormStruct( 1, "NRM" )
Local oStructNYY  := FWFormStruct( 1, "NYY" )
Local oCommit     := JA044Commit():New()

oStructNR4:RemoveField( "NR4_CTDESP" )
oStructNR4:RemoveField( "NR4_DTDESP" )
oStructNRM:RemoveField( "NRM_CTIPO"  )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA044",/*Pre-Validacao*/,{ |oX| JA044TUDOK( oX )} /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NRHMASTER", NIL, oStructNRH, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:AddGrid  ( "NR4IDIOMA", "NRHMASTER" /*cOwner*/, oStructNR4, /*bLinePre*/, /*bLinePost*/, /*bPre*/,  /*bPost*/ )
oModel:AddGrid  ( "NYYTARIFA", "NRHMASTER" /*cOwner*/, oStructNYY, /*bLinePre*/, /*bLinePost*/, /*bPre*/,  /*bPost*/ )

oModel:AddGrid( "NRMDETAIL", "NRHMASTER" /*cOwner*/, oStructNRM, /*bLinePre*/, { |oGrid| Jur044LOk(oGrid, "NRM" ) }  /*bLinePost*/, ;
							  /*bPre*/, /*bPost*/,  { |oGrid| LoadNRM(oGrid,"NRM_AMINI",oModel) } )

oModel:GetModel( "NR4IDIOMA" ):SetUniqueLine( { "NR4_CIDIOM" } )
oModel:SetRelation( "NR4IDIOMA", { { "NR4_FILIAL", "xFilial('NR4')" } , { "NR4_CTDESP", "NRH_COD" } } , NR4->( IndexKey( 1 ) ) )

oModel:GetModel( "NYYTARIFA" ):SetUniqueLine( { "NYY_CODCFG","NYY_CIDIOM" } )
oModel:SetRelation( "NYYTARIFA", { { "NYY_FILIAL", "xFilial('NYY')" } , { "NYY_TIPO", "NRH_COD" } } , NYY->( IndexKey( 1 ) ) )

oModel:SetDescription( STR0008 ) // "Modelo de Dados de Tipo de despesas"
oModel:GetModel( "NRHMASTER" ):SetDescription( STR0009 ) // "Dados de Tipo de despesas"
oModel:GetModel( "NR4IDIOMA" ):SetDescription( STR0010 ) // "Descrição do Tipo por Idioma"
oModel:GetModel( "NYYTARIFA" ):SetDescription( STR0023) // "Descrição do Tarifador"
oModel:GetModel( "NRMDETAIL" ):SetDescription( STR0013 ) // "Histórico do Tipo de despesas"


oModel:GetModel( "NYYTARIFA" ):SetDelAllLine( .F. )
oModel:GetModel( "NYYTARIFA" ):SetNoInsertLine( .T. )
oModel:GetModel( "NR4IDIOMA" ):SetDelAllLine( .F. )
oModel:GetModel( "NRMDETAIL" ):SetDelAllLine( .T. )


oModel:SetRelation( "NRMDETAIL", { { "NRM_FILIAL", "xFilial( 'NRM' ) " } , { "NRM_CTIPO", "NRH_COD" } } , NRM->( IndexKey( 1 ) ) )

oModel:SetOptional( "NYYTARIFA", .T.)
oModel:SetOptional( 'NR4IDIOMA', .T.)
oModel:SetOptional( "NRMDETAIL", .T.)

JurSetRules( oModel, 'NYYTARIFA',, 'NYY' )
JurSetRules( oModel, 'NRHMASTER',, 'NRH' )
JurSetRules( oModel, 'NR4IDIOMA',, 'NR4' )
JurSetRules( oModel, 'NRMDETAIL',, 'NRM' )

oModel:SetActivate( { |oModel| JURADDIDIO(oModel:GetModel("NR4IDIOMA"), "NR4") } )


oModel:InstallEvent("JA044Commit", /*cOwner*/, oCommit)

Return oModel

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA044TUDOK
Executa as rotinas ao confirmar as alteração no Model.

@author Felipe Bonvicini Conti
@since 23/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA044TUDOK ( oModel )
Local lRet 		:= .T.
Local nI    	:= 0
Local oModelNR4 := oModel:GetModel( "NR4IDIOMA" )
Local oModelNRM := oModel:GetModel( "NRMDETAIL" )
Local nQtdLnNR4 := oModelNR4:GetQtdLine()
Local nQtdLnNR1 := JurQtdReg('NR1')

If (oModel:GetOperation() == 3 .OR. oModel:GetOperation() == 4)
	
	lRet :=	JURPerHist(oModelNRM, .F.) 
		
	If lRet
		For nI := 1 to nQtdLnNR4
			oModelNR4:GoLine(nI)
			If oModelNR4:IsDeleted() .OR. Empty(oModelNR4:GetValue('NR4_CIDIOM') )
				nQtdLnNR4--
			EndIf
		Next nI
		
		If lRet .And. nQtdLnNR4 < nQtdLnNR1
			JurMsgErro( STR0011 )// É preciso incluir todos os idiomas
			lRet := .F.
		EndIf
		
	EndIf
	
	IIF(lRet, lRet := JurVldDesc(oModelNR4, { "NR4_DESC" } ), )
	
EndIf

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA044COMMIT
Classe interna implementando o FWModelEvent, para execução de função 
durante o commit.

@author Cristina Cintra Santos
@since 21/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA044COMMIT FROM FWModelEvent
    Method New()
    Method Before()
    Method InTTS()
End Class

Method New() Class JA044COMMIT
Return

Method Before(oSubModel, cModelId) Class JA044COMMIT
	JURA044HST(oSubModel:GetModel()) //Ajuste Histórico
Return

Method InTTS(oSubModel, cModelId) Class JA044COMMIT
	JFILASINC(oSubModel:GetModel(), "NRD", "NRHMASTER", "NRH_COD")
Return
	
//-------------------------------------------------------------------
/*/ { Protheus.doc } JURA044HST
Rotina para atualizar o hitórico do Tipo de Despesas

@Return lRet, Se criou o histórico

@author Bruno Ritter
@since 16/08/2018
@version 2.0
/*/
//-------------------------------------------------------------------
Static Function JURA044HST(oModel)
	Local lRet      := .T.
	Local aCpoMdls  := {}
	Local aNRHCpo   := {}

	If !oModel:GetOperation() == OP_EXCLUIR
		aAdd(aNRHCpo, {"NRH_PCORRE", "NRM_PCORRE"} )
		aAdd(aNRHCpo, {"NRH_PCORRE", "NRM_PCORRE"} )
		aAdd(aNRHCpo, {"NRH_VALORU", "NRM_VALORU"} )
		aAdd(aCpoMdls, {"NRHMASTER", aNRHCpo})

		lRet := JurHist(oModel,"NRMDETAIL", aCpoMdls, .F.)

		JurFreeArr(@aNRHCpo)
		JurFreeArr(@aCpoMdls)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadNRM
Faz a carga dos dados da grid do NRM e ordena decrescente pelo ano-mês

@author Felipe Bonvicini Conti
@since 05/11/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LoadNRM( oGrid, cCampo, oModel)
Local nOperacao := oGrid:GetModel():GetOperation()
Local aStruct   := oGrid:oFormModelStruct:GetFields()
Local nAt       := 0
Local aRet      := {}

If nOperacao <> OP_INCLUIR // <- requer o INCLUDE do "FWMVCDEF.CH"
	
	aRet := FormLoadGrid( oGrid ) 
	
	// Ordena decrescente pelo Ano/Mes
	If ( nAt := aScan( aStruct, { |e| e[MODEL_FIELD_IDFIELD] == cCampo } ) ) > 0
		aSort( aRet,,, { |aX,aY| aX[2][nAt] > aY[2][nAt] } )
	EndIf

EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Jur044LOk
Validação da data final no cadastro de histórico do Tipo de Despesas

@Return lRet	 	.T./.F. As informações são válidas ou não       

@author Felipe Bonvicini Conti
@since 05/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Jur044LOk(oGrid, cAlias)
Local lRet       := .T.
Local nLines 	   := oGrid:GetQtdLine()
Local aColsOrd   := {}
Local nPosAmIni  := 1
Local nPosAmFim  := 2
Local nPosOrig   := 3
Local nAscan     := 0
Local nLinAtu 	 := oGrid:GetLine()
Local nX         := 0
Local nI         := 0

	// Ordena os dados em uma copia, para nao prejudicar a referencia do aCols
	For nI := 1 to nLines
		If !oGrid:IsDeleted(nI) .And. !oGrid:IsEmpty(nI)
			aAdd(aColsOrd, {oGrid:GetValue(cAlias+"_AMINI",nI), oGrid:GetValue(cAlias+"_AMFIM",nI), nI} ) 	
		EndIf
	Next

	aSort( aColsOrd,,, { |aX,aY| aX[nPosAmIni] > aY[nPosAmIni] } )
	
	If Empty(oGrid:GetValue(cAlias+"_AMFIM"))
		If (nAscan := Ascan(aColsOrd, { |e| Empty(e[nPosAmFim])  } )) > 0 .And. aColsOrd[nAscan][nPosOrig] <> nLinAtu
			JurMsgErro(STR0019) // "Não é possível existir duas linhas com Ano-mês final em branco"
			lRet := .F.
		Endif
	Endif	

	If lRet
		For nX := 1 To nLines
			If (nX + 1) <= nLines
				If aColsOrd[nX,nPosAmIni] <= aColsOrd[nX+1,nPosAmIni] .Or. aColsOrd[nX,nPosAmIni] <= aColsOrd[nX+1,nPosAmFim]
					lRet := .F.	
					JurMsgErro(STR0020) // "Não é possível ter históricos considerando o mesmo Ano-mês"
				Endif
			Endif
		Next
	Endif	

Return lRet
