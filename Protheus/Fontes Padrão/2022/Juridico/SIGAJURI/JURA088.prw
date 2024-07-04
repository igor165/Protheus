#INCLUDE "JURA088.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE 'FWBROWSE.CH'
#INCLUDE 'APWIZARD.CH'

Static __aCargo := {}

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA088
Filtra os contratos do assunto jurídico
Uso no cadastro de Contratos.

@param 	cProcesso  	Código do Assunto Jurídico
@param  lChgAll		Permissão para alterar registros de outras Filiais	
@author Clóvis Eduardo Teixeira
@since 23/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA088( cProcesso, cInstancia, cCorresp, clCorresp, ljura132, cTpCont, cReajustado, lChgAll, cFilFiltro)
Local oBrowse
Local aArea          := GetArea()
Local aAreaNSZ       := NSZ->( GetArea() )
Private c088cCorres  := cCorresp
Private c088lCorres  := clCorresp
Private nValContrato := 0
Private c088Processo := cProcesso
Private c088Instancia:= cInstancia

Default cProcesso    := ''
Default cInstancia   := ''
Default cReajustado  := '1'
Default lJura132     := .F.
Default cTpCont      := ''
Default cReajustado  := '2'
Default lChgAll		 := .T. 

Default cFilFiltro	 := xFilial("NSU")

Public cProcesso     := cProcesso
Public cInstancia    := cInstancia



oBrowse := FWMBrowse():New()
oBrowse:SetChgAll( lChgAll ) 
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NSU" )
oBrowse:SetLocate()

If !Empty(cProcesso) .And. !Empty(cInstancia) .And. !lJura132

	oBrowse:SetFilterDefault("NSU_FILIAL == '" + cFilFiltro + " '.AND. NSU_CAJURI == '" +cProcesso+ "' .And. NSU_INSTAN == '" +cInstancia+ "' .And. NSU_LFORNE == '" +clCorresp+ "'   .And.  NSU_CFORNE == '" +cCorresp+ "'  " )

elseIf !Empty(cCorresp) .And. !Empty(clCorresp) .And. !Empty(cTpCont) .And. lJura132

//oBrowse:SetFilterDefault(" ( dTos(NSU_FIMVGN) >= '" +dTOS(dDatabase)+ "' .OR. Empty(NSU_FIMVGN)  )   .And.  NSU_CTCONT == '" +cTpCont+ "'  .And. NSU_LFORNE == '" +clCorresp+ "'   .And.  NSU_CFORNE == '" +cCorresp+ "'   " )
	oBrowse:SetFilterDefault(" ( dTos(NSU_FIMVGN) >= '" +dTOS(dDatabase)+ "' .OR. Empty(NSU_FIMVGN) .OR. Dtos(NSU_DCAREN) >= '" + Dtos(dDataBase) + "') .And. NSU_LFORNE == '" +clCorresp+ "'   .And.  NSU_CFORNE == '" +cCorresp+ "'   " )

EndIf

oBrowse:SetMenuDef('JURA088')
JurSetBSize(oBrowse, '50,50,50')
JurSetLeg(oBrowse, "NSU" )
oBrowse:Activate()

RestArea(aAreaNSZ)
RestArea(aArea)
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

@author Clóvis Eduardo Teixeira
@since 27/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

aAdd( aRotina, { STR0001,  "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"

If JA162AcRst('09')
	aAdd( aRotina, { STR0002,  "VIEWDEF.JURA088", 0, 2, 0, NIL } ) // "Visualizar"
EndIf

If !IsInCallStack( 'JURA132' )
	If JA162AcRst('09',3)
		aAdd( aRotina, { STR0003,  "VIEWDEF.JURA088", 0, 3, 0, NIL } ) // "Incluir"
	EndIf
	If JA162AcRst('09',4)
		aAdd( aRotina, { STR0004,  "VIEWDEF.JURA088", 0, 4, 0, NIL } ) // "Alterar"
	EndIf
EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Contratos do Processo

@author Clóvis Eduardo Teixeira
@since 27/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel   := FWLoadModel( "JURA088" )
Local oStruct  := FWFormStruct( 2, "NSU" )
Local cGrpRest := JurGrpRest()

JurSetAgrp( 'NSU',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )

oView:AddField("JURA088_VIEW" , oStruct , "NSUMASTER" )
oView:CreateHorizontalBox("FORMFIELD", 100)
oView:SetOwnerView( "JURA088_VIEW","FORMFIELD" )

oView:SetDescription( STR0007 ) //"Andamentos"
oView:EnableControlBar( .T. )

oView:SetViewCanActivate({|oView|JA088Msg(oView)})

oView:setUseCursor(.F.)

oView:SetCloseOnOk({||.T.})

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Andamentos

@author Clóvis Eduardo Teixeira
@since 27/05/09
@version 1.0

@obs NSUMASTER - Dados do Andamentos

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel   := NIL
Local oStruct  := FWFormStruct( 1, "NSU" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA088", /*Pre-Validacao*/, {|oX| JA088TOk(oX)} /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NSUMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )

oModel:SetDescription( STR0008 ) // "Modelo de Dados de Andamentos"
oModel:GetModel( "NSUMASTER" ):SetDescription( STR0009 ) // "Dados de Andamentos"

JurSetRules( oModel, "NSUMASTER",, "NSU" )

oModel:SetActivate ( { |oX| SetCont( oX ) } )

Return oModel

/*/
//-------------------------------------------------------------------
{Protheus.doc} JA088Msg
Valida informações ao salvar

@param 	oView  		View a ser verificado
@Return lRet	 	.T./.F. As informações são válidas ou não
@author Clóvis Eduardo Teixeira
@since 20/01/10
@version 1.0
//-------------------------------------------------------------------
/*/
Function JA088Msg(oView)
Local oModel   	:= oView:Getmodel()
Local nOpc      := oModel:GetOperation()
Local cCodForne := c088cCorres
Local cLojForne := c088lCorres
Local cAliasQry := GetNextAlias()


if IsInCallStack( 'JURA132' )
   Return(.t.)
endif

If nOpc == 3

	BeginSql Alias cAliasQry

		SELECT NU5_CTCONT
		FROM %table:NU5% NU5
		WHERE NU5.NU5_CFORNE = %Exp:cCodForne%
	  	AND NU5.NU5_LFORNE = %Exp:cLojForne%
	  	AND NU5.NU5_FILIAL = %xFilial:NU5%
		  AND NU5.%notDEL%
	EndSql
	dbSelectArea(cAliasQry)

	if !(cAliasQry)->(EOF())

	  if  ApMsgYesNo(STR0012)

			SelTipoCont(oModel,cCodForne, cLojForne)
			NSU->(dbClearFilter())


		else

		oModel:Activate()
		oModel:LoadValue("NSUMASTER","NSU_CTCONT",CriaVar("NSU_CTCONT"))
	  	oModel:LoadValue("NSUMASTER","NSU_DETALH",CriaVar("NSU_DETALH"))
		oModel:LoadValue("NSUMASTER","NSU_CMOEDA",CriaVar("NSU_CMOEDA"))
		oModel:LoadValue("NSUMASTER","NSU_VALOR" ,CriaVar("NSU_VALOR"))

		endif

	Endif

	(cAliasQry)->( dbCloseArea() )
	cAliasQry := GetNextAlias()

Endif

Return .T.

/*/
//-------------------------------------------------------------------
{Protheus.doc} JA088TOk(oModel)
Valida informações ao salvar

@param 	oModel  	Model a ser verificado
@Return lRet	 	.T./.F. As informações são válidas ou não
@author Clóvis Eduardo Teixeira
@since 20/01/10
@version 1.0
//-------------------------------------------------------------------
/*/
Function JA088TOk(oModel)
Local cCajuri   := oModel:GetValue("NSUMASTER","NSU_CAJURI")
Local cCcorresp := oModel:GetValue("NSUMASTER","NSU_CFORNE")
Local cLcorresp := oModel:GetValue("NSUMASTER","NSU_LFORNE")
Local cCodCont  := oModel:GetValue("NSUMASTER","NSU_CTCONT")
Local cInstan   := oModel:GetValue("NSUMASTER","NSU_INSTAN")
Local cSequen   := oModel:GetValue("NSUMASTER","NSU_SEQUEN")
Local cSeqori   := oModel:GetValue("NSUMASTER","NSU_SEQORI")
Local cCod      := oModel:GetValue("NSUMASTER","NSU_COD")
Local lExiste   := .F.
Local nOpc      := oModel:GetOperation()
Local lRet      := .T.

	if IsInCallStack( 'JURA132' )
  	Return(lRet)
	endif

  if (nOpc == 3 .or. nOpc == 4)

 		if (nOpc == 4)
			if lRet
				If ( FwFldGet('NSU_FLGREJ') == '1' )
					JurMsgErro(STR0015) //"Contrato Reajustado Nao Pode Ser Alterado"
					lRet := .F.
				Endif
			Endif
  	endif

		if lRet
		  If (!Empty(FwFldGet('NSU_CMOEDA')) .Or. !Empty(FwFldGet('NSU_VALOR'))) .And.;
	  		!(!Empty(FwFldGet('NSU_CMOEDA')) .And. !Empty(FwFldGet('NSU_VALOR')))
			  JurMsgErro(STR0014) //"Preencher os campos obrigatórios, Código da Moeda e Valor."
			  lRet := .F.
			Endif
		Endif
/*  TRAVA NO CONTRATO DE CORRESPONDENTES
		if lRet .And. nOpc == 3
  		NSU->(dbSetOrder( 2 ))

	    	While !NSU->(EOF()) .AND. xFilial('NQE')+cCodCont + cCajuri + cCcorresp + cLcorresp + cInstan == ;
	    		NSU->NSU_FILIAL +NSU->NSU_CTCONT +NSU->NSU_CAJURI +NSU->NSU_CFORNE +NSU->NSU_LFORNE +NSU->NSU_INSTAN
						If ((NSU->NSU_FIMVGN > DATE()) .Or. Empty(NSU->NSU_FIMVGN))
							JurMsgErro(STR0011)
							lRet := .F.
							Exit
						Endif
					NSU->(dbSkip())
				End
		Endif*/
  Endif

  if lRet .And. nOpc == 3
	  lExiste := ExistCpo('NSU',cCajuri + cCcorresp + cLcorresp + cInstan+ cCodCont + cSEQUEN + cSEQORI +cCod)
	  if lExiste
	    lRet := .F.
	    JurMsgErro(STR0016)
	  Endif
  Endif

if lRet .And. SuperGetMV('MV_JINTJUR',, '2') == '1'
	JurIntJuri(oModel:GetValue("NSUMASTER","NSU_COD"), oModel:GetValue("NSUMASTER","NSU_CAJURI"), "7", Str(nOpc))
Endif

	If lRet
		If nOpc == 3 .Or. nOpc == 4
			lRet := JA088DtVg(FwFldGet("NSU_INIVGN"),FwFldGet("NSU_FIMVGN"))
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA088DtVg()
Rotina de validação para a data de vigência
@Return lRet
@author Clóvis Eduardo Teixeira
@since 26/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA088DtVg(cDtIni,cDtFim)
Local aArea  := GetArea()
Local lRet   := .T.

if cDtIni > cDtFim .And. !Empty(cDtFim)
  lRet := .F.
  JurMsgErro(STR0013)
Endif

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SelTipoCont
Função utilizada para o usuário selecionar o tipo contrato padrão
Uso Geral.
@param  cUser Código do Usuário
@author Clóvis Teixeira
@since 02/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SelTipoCont(oModel, cCForne, cLForne)
Local cTrab     := GetNextAlias()
Local cIdBrowse  := ''
Local cIdRodape  := ''
Local cQuery     := ''
Local cTipoCont  := ''
Local nI         := 0
Local nAt        := 0
Local aCampos    := {}
Local aStru      := {}
Local aAux       := {}
Local aTipoCont  := {}
Local cRotina    := 'JURA088'
Local oBrowse, oColumn, oDlg, oTela, oPnlBrw, oPnlRoda
Local oBtnOk, oBtnCancel
Local TNSU  := GetNextAlias()
Local lvNSU := J088VNSU(cCForne,cLForne)


IF lvNSU

	cQuery += " SELECT NU5_CTCONT, NSQ_DESC, CTO_SIMB, (CASE WHEN NU5_VALANT = 0 THEN NU5_VALOR ELSE NU5_VALANT END) VALOR,"
	cQuery += " NU5_CMOEDA, NU5.R_E_C_N_O_ RECNO1"
ELSE

	cQuery += " SELECT NU5_CTCONT, NSQ_DESC, CTO_SIMB, NU5_VALOR  VALOR,"
	cQuery += " NU5_CMOEDA, NU5.R_E_C_N_O_ RECNO1"
eNDIF

	cQuery += "   FROM "+RetSqlName("NU5")+" NU5,"+RetSqlName("CTO")+" CTO,"+RetSqlName("NSQ")+" NSQ"
	cQuery += "  WHERE NU5_CMOEDA = CTO_MOEDA "
	cQuery += "    AND NU5_CTCONT = NSQ_COD "
	cQuery += "    AND NU5_FILIAL = '"+xFilial("NU5")+"'"
	cQuery += "    AND CTO_FILIAL = '"+xFilial("CTO")+"'"
	cQuery += "    AND NSQ_FILIAL = '"+xFilial("NSQ")+"'"
	cQuery += "    AND NU5.D_E_L_E_T_ = ' '  "
	cQuery += "    AND CTO.D_E_L_E_T_ = ' '  "
	cQuery += "    AND NSQ.D_E_L_E_T_ = ' '  "
	cQuery += "    AND NU5_CFORNE = '"+cCForne+"'"
	cQuery += "    AND NU5_LFORNE = '"+cLForne+"'"

Define MsDialog oDlg FROM 0, 0 To 400, 600 Title '..: ' + STR0020 + ' :..' Pixel style DS_MODALFRAME

nAt       := 0
oTela     := FWFormContainer():New( oDlg )
cIdBrowse := oTela:CreateHorizontalBox( 84 )
cIdRodape := oTela:CreateHorizontalBox( 16 )
oTela:Activate( oDlg, .F. )
oPnlBrw   := oTela:GeTPanel( cIdBrowse )
oPnlRoda  := oTela:GeTPanel( cIdRodape )

If !Empty( cRotina )
	If nAt == 0
		aAdd( aTipoCont, { PadR( cRotina, 10 ) , cQuery, {} } )
	Else
		cQuery := aTipoCont[nAt][2]
	EndIf
EndIf

	//-------------------------------------------------------------------
	// Define o Browse
	//-------------------------------------------------------------------
	Define FWBrowse oBrowse DATA QUERY ALIAS cTrab QUERY cQuery DOUBLECLICK {||__aCargo :={ AllTrim(FieldGet(1)) , AllTrim(FieldGet(5)),FieldGet(4), FieldGet(6) },oDlg:End()} NO LOCATE Of oPnlBrw

	If !Empty( cRotina )

		If nAt == 0

			aStru := ( cTrab )->( dbStruct() )

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
				aTipoCont[Len( aTipoCont ) ][3] := aCampos
			EndIf
		Else
			aCampos := aClone( aTipoCont[nAt][3] )
		EndIf

	EndIf

	//-------------------------------------------------------------------
	// Adiciona as colunas do Browse
	//-------------------------------------------------------------------
	For nI := 1 To Len( aCampos )
		ADD COLUMN oColumn DATA &( ' { || ' + aCampos[nI][1] + ' } ' ) Title aCampos[nI][2]  PICTURE aCampos[nI][3] Of oBrowse
	Next

	//-------------------------------------------------------------------
	// Ativação do Browse
	//-------------------------------------------------------------------
	Activate FWBrowse oBrowse

	//Botão Ok
	@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + 221 Button oBtnOk  Prompt 'Ok' ;
	Size 25 , 12 Of oPnlRoda Pixel Action ( __aCargo := { AllTrim(FieldGet(1)), AllTrim(FieldGet(5)), FieldGet(4), FieldGet(6) } , oDlg:End())

	//Botão Cancelar
	@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + 273 Button oBtnCancel Prompt 'Cancelar';
	  Size 25 , 12 Of oPnlRoda Pixel Action ( oDlg:End() )

	//-------------------------------------------------------------------
	// Ativação do janela
	//-------------------------------------------------------------------
	Activate MsDialog oDlg Centered


Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetCont
Função utilizada para o usuário selecionar o tipo contrato padrão
Uso Geral.
@param  oModel   - Modelo de Dados
@param  cUser    - Código do Usuário
@param  cTipCont - Código Tipo de Contrato
@param  cMoeda   - Código da Moeda
@param  cValor   - Valor do contrato padrão
@param  cRecno   - Posição do REgistro
@author Clóvis Teixeira
@since 02/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SetCont(oModel)
Local lRet     := .T.
Local cDetalh  := ''
Local cTipCont := ''
Local cMoeda   := ''
Local cValor   := ''
Local cRecno   := ''
Local cDescCon := ''
Local cSimbMoe

if IsInCallStack( 'JURA132' )
   Return(lRet)
endif

if Len(__aCargo) > 0 .And. oModel:GetOperation() == 3

	cTipCont:= __aCargo[1]
	cMoeda  := __aCargo[2]
	cValor  := __aCargo[3]
	cRecno  := __aCargo[4]

	if oModel:SetValue("NSUMASTER","NSU_CTCONT",cTipCont)
 	  cDescCon := JURGETDADOS('NSQ',1,XFILIAL('NSQ')+cTipCont,'NSQ_DESC')                                                                  
	  oModel:SetValue("NSUMASTER","NSU_DTCONT",cDescCon)
	Endif

	If cRecno > 0
		NU5->( dbGoTo( cRecno ) )
		cDetalh := NU5->NU5_DETALH
		lRet := oModel:SetValue("NSUMASTER","NSU_DETALH",cDetalh)
	EndIf

	If lRet
		lRet := oModel:SetValue("NSUMASTER","NSU_CMOEDA",cMoeda)
	EndIf

	if lRet
	  cSimbMoe := rTrim(Posicione('CTO',1, xFilial('CTO')+ oModel:GetValue("NSUMASTER","NSU_CMOEDA"),'CTO_SIMB'))
	  lRet := oModel:SetValue("NSUMASTER","NSU_DMOEDA",cSimbMoe)
	Endif

	If lRet
		lRet := oModel:LoadValue("NSUMASTER","NSU_VALOR" ,cValor)
	EndIf

   oModel:SetValue("NSUMASTER","NSU_CPADRA","1")


elseif Len(__aCargo) == 0 .And. oModel:GetOperation() == 3

	oModel:LoadValue("NSUMASTER","NSU_CTCONT",CriaVar("NSU_CTCONT"))
   oModel:LoadValue("NSUMASTER","NSU_DETALH",CriaVar("NSU_DETALH"))
	oModel:LoadValue("NSUMASTER","NSU_CMOEDA",CriaVar("NSU_CMOEDA"))
	oModel:LoadValue("NSUMASTER","NSU_VALOR" ,CriaVar("NSU_VALOR"))

Endif

	 __aCargo := {}

Return lRet


/*{Protheus.doc} J088VNSU
Função utilizada para verifica contratos em vigor
*/

Function J088VNSU(rForne,rLForne)
Local dDataf     := CTOD("  /  /  ")
Local 	cRet := .F.

DbSelectArea("NSU")
//NSU->(DbSetFilter({|| NSU->(NSU_FILIAL+NSU_CFORNE+NSU_LFORNE+NSU_CAJURI+NSU_INSTAN ) == xFilial('NSU')+rForne+rlforne+c088Processo+ c088Instancia  .AND. ( DTOS(NSU_FIMVGN) >= DTOS(dDatabase) .OR. Empty(NSU_FIMVGN)) .AND.  dtos(dDataf) <> DTOS(NSU_DTREAJ)  },;
//"NSU->(NSU_FILIAL+NSU_CFORNE+NSU_LFORNE+NSU_CAJURI+NSU_INSTAN) == xFilial('NSU')+rForne+rlforne+c088Processo+ c088Instancia )  .AND. ( dTos(NSU_FIMVGN) >= '" +dTOS(dDatabase)+ "' .OR. Empty(NSU_FIMVGN)) .AND.  dtos(dDataf) <> DTOS(NSU_DTREAJ) " ))
NSU->(DbSetFilter({|| NSU->(NSU_FILIAL+NSU_CFORNE+NSU_LFORNE+NSU_CAJURI+NSU_INSTAN ) == xFilial('NSU')+rForne+rlforne+c088Processo+ c088Instancia  .AND. ( DTOS(NSU_FIMVGN) >= DTOS(dDatabase) .OR. Empty(NSU_FIMVGN) .OR. DTOS(NSU_DCAREN) >= DTOS(dDatabase))  },;
"NSU->(NSU_FILIAL+NSU_CFORNE+NSU_LFORNE+NSU_CAJURI+NSU_INSTAN) == xFilial('NSU')+rForne+rlforne+c088Processo+ c088Instancia )  .AND. ( dTos(NSU_FIMVGN) >= '" +dTOS(dDatabase)+ "' .OR. Empty(NSU_FIMVGN) .OR. Dtos(NSU_DCAREN) >= '" + Dtos(dDataBase) + "')  " ))
NSU->(DbGoTop())


If !EOF()
	cRet := .T.
endif

Return(cRet)

//----------------------------------------------------------------------------
/*/{Protheus.doc} J88ValMoed()
Escritorio Correspondente
@author Clovis E. Teixeira dos Santos
@since 11/06/09
@version 1.0
/*/
//----------------------------------------------------------------------------
Function J88ValMoed(cMoed)
Local lRet    := .T.
Local aArea   := GetArea()

Default cMoed = ''

	If cMoed <> ''
		dbSelectArea("CTO")
		dbSetOrder(1)

		If DbSeek(xFilial("CTO")+cMoed)
			If CTO->CTO_BLOQ == '2'
				lRet := .T.
			Else
				lRet := .F.
				JurMsgErro(STR0017+STR(Alltrim(cMoed))+STR0018)   // "Atenção a moeda "+STR(Alltrim(cMoed)) +" esta bloquada !"
			EndIF
		Else
			lRet := .F.
			JurMsgErro(STR0017+ STR0019)  // "Atenção a moeda " + " digitada é invalida. Favor conferir o cadastro de moedas !")
		EndIf
	EndIf

RestArea(aArea)
Return lRet