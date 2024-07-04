#INCLUDE "TMSA147.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-----------------------------------------------------------------------------------------------------------
/* Browse da rotina de Cadastro de Romaneios
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		7.00.111010P
@since 	12/06/2012
@return 	*/
//-----------------------------------------------------------------------------------------------------------
Function TMSA147()

Local oMBrowse := Nil
Local lPercMDFe	  := AliasInDic("DJ1")

Private aRotina   := MenuDef()
Private cCadastro := STR0001

If !__lPyme
	Help( "", 1, "TMSA147001" ) // Esta funcionalidade esta disponivel somente para o Protheus Serie 3
	Return
EndIf

If !lPercMDFe
	Alert("Aplicar o Compatibilizador TMS11R159!!")
	Return
EndIf

AjustaHelp()

oMBrowse:= FWMBrowse():New()
oMBrowse:SetAlias("DYB")
oMBrowse:SetDescription( STR0001 ) // "Romaneio de Carga"

//-------------------------------------------------------------------
// Adiciona legendas no Browse
//-------------------------------------------------------------------
ADD LEGEND DATA 'DYB->DYB_STATUS=="1"' COLOR "GREEN"  TITLE STR0002 OF oMBrowse // "Romaneio em Aberto"
ADD LEGEND DATA 'DYB->DYB_STATUS=="2"' COLOR "YELLOW" TITLE STR0003 OF oMBrowse // "Romaneio em Transito"
ADD LEGEND DATA 'DYB->DYB_STATUS=="3"' COLOR "RED"    TITLE STR0004 OF oMBrowse // "Romaneio Encerrado"

oMBrowse:Activate()

Return

//===========================================================================================================
/* Retorna as operações disponiveis para o Cadastro de Romaneios.
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		7.00.111010P
@since 	12/06/2012
@return 	aRotina - Array com as opçoes de Menu */
//===========================================================================================================
Static Function MenuDef()

Local aRotina := {}

aAdd( aRotina, { STR0005, "PesqBrw"          , 0, 1, 0, .T. } ) // Pesquisar
aAdd( aRotina, { STR0006, "VIEWDEF.TMSA147"  , 0, 2, 0, NIL } ) // Visualizar
aAdd( aRotina, { STR0007, "VIEWDEF.TMSA147"  , 0, 3, 0, NIL } ) // Incluir
aAdd( aRotina, { STR0008, "VIEWDEF.TMSA147"  , 0, 4, 0, NIL } ) // Alterar
aAdd( aRotina, { STR0009, "VIEWDEF.TMSA147"  , 0, 5, 0, NIL } ) // Excluir
aAdd( aRotina, { STR0010, "TMSA147FEC(.T.)"  , 0, 6, 0, NIL } ) // Saida
aAdd( aRotina, { STR0011, "TMSA147FEC(.F.)"  , 0, 7, 0, NIL } ) // Chegada
aAdd( aRotina, { STR0012, "TMSA147OCO()"     , 0, 8, 0, NIL } ) // Apont.Ocor.

Return aRotina

//===========================================================================================================
/* Retorna o modelo de Dados da rotina Cadastro de Romaneios
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		7.00.111010P
@since 	12/06/2012
@return 	oModel - Modelo de Dados */
//===========================================================================================================
Static Function ModelDef()

Local oModel 	:= Nil
Local oStruDYB := FwFormStruct( 1, "DYB" )
Local oStruDYC := FwFormStruct( 1, "DYC" )
Local oStruDJ1 := FwFormStruct( 1, "DJ1" )

oStruDJ1:SetProperty("DJ1_NUMROM", MODEL_FIELD_INIT, {|| M->DYB_NUMROM })

oModel := MpFormModel():New( "TMSA147", /*bPre*/ , { |oMdl| TMSA147POS( oMdl ) } /*bPost*/, { |oMdl| TMSA147GRV( oMdl ) }/*bCommit*/, /*bCancel*/ )

oModel:SetVldActivate({ |oMdl| TMSA147PRE( oMdl ) })

oModel:SetDescription( STR0001 ) // "Romaneio de Carga"

oModel:AddFields( "TMSA147_DYB" , , oStruDYB )
oModel:SetPrimaryKey( { "DYB_FILIAL" ,  "DYB_NUMROM" } )

oModel:AddGrid(  "TMSA147_DYC" , "TMSA147_DYB" , oStruDYC )
oModel:AddGrid(  "TMSA147_DJ1" , "TMSA147_DYB" , oStruDJ1 )
oModel:SetRelation( "TMSA147_DYC",{	 { "DYC_FILIAL" , "xFilial('DYC')" }   ,;
         	                             { "DYC_NUMROM" , "DYB_NUMROM"     } } ,;
                                     "DYC_FILIAL+DYC_NUMROM"   ;
			         )

oModel:SetRelation( "TMSA147_DJ1",{	 { "DJ1_FILIAL" , "xFilial('DJ1')" }   ,;
         	                             { "DJ1_NUMROM" , "DYB_NUMROM"     } } ,;
                                     "DJ1_FILIAL+DJ1_NUMROM"   ;
			         )

oModel:GetModel( "TMSA147_DYC" ):SetUniqueLine( { "DYC_FILDOC" , "DYC_DOC" , "DYC_SERIE" } )

oModel:AddCalc( "TMSA147TOT", "TMSA147_DYB", "TMSA147_DYC", "DYC_QTDVOL"   , STR0014, "SUM"   ) // "Volume"
oModel:AddCalc( "TMSA147TOT", "TMSA147_DYB", "TMSA147_DYC", "DYC_PESO"     , STR0013, "SUM"   ) // "Peso"
oModel:AddCalc( "TMSA147TOT", "TMSA147_DYB", "TMSA147_DYC", "DYC_PESOM3"   , STR0015, "SUM"   ) // "M3"
oModel:AddCalc( "TMSA147TOT", "TMSA147_DYB", "TMSA147_DYC", "DYC_VALMER"   , STR0016, "SUM"   ) // "Vl.Merc."
oModel:AddCalc( "TMSA147TOT", "TMSA147_DYB", "TMSA147_DYC", "DYC_DOC"      , STR0017, "COUNT" ) // "Qtd.Reg."

oModel:GetModel( 'TMSA147_DJ1' ):SetOptional( .T. )

Return oModel

//===========================================================================================================
/* Retorna a View (tela) da rotina Cadastro de Romaneios
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		7.00.111010P
@since 	12/06/2012
@return 	oView -  */
//===========================================================================================================
Static Function ViewDef()

Local oView	 := Nil
Local oModel   := FwLoadModel( "TMSA147" )
Local oStruDYB := FwFormStruct( 2, "DYB" )
Local oStruDYC := FwFormStruct( 2, "DYC" )
Local oStruDJ1 := FwFormStruct( 2, "DJ1" )
Local oCalc1   := Nil

oStruDYC:RemoveField( "DYC_NUMROM" )
oStruDYC:RemoveField( "DYC_OBS"    )
oStruDJ1:RemoveField( "DJ1_FILIAL" )

oStruDJ1:SetProperty("DJ1_NUMROM" , MVC_VIEW_CANCHANGE, .F.)
oStruDJ1:SetProperty("DJ1_SEQUEN" , MVC_VIEW_CANCHANGE, .F.)
oCalc1 := FWCalcStruct( oModel:GetModel( "TMSA147TOT" ) )

oView := FwFormView():New()

oView:SetModel( oModel )

oView:AddField( "VIEW_DYB" , oStruDYB, "TMSA147_DYB"   )
oView:AddGrid(  "VIEW_DYC" , oStruDYC, "TMSA147_DYC"   )
oView:AddGrid(  "VIEW_DJ1" , oStruDJ1, "TMSA147_DJ1"   )

oView:AddField( 'VIEW_CALC', oCalc1  , "TMSA147TOT" )

oView:CreateHorizontalBox( 'TOPO'		, 40 )
oView:CreateHorizontalBox( 'DETALHE'	, 30 )
oView:CreateHorizontalBox( 'DETAIL'	, 22,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
oView:CreateHorizontalBox( 'PERCURSO'	, 100 ,,,"IDFOLDER","IDSHEET01"  )
oView:CreateHorizontalBox( 'TOTAIS'   , 8 )

oView:CreateFolder("IDFOLDER","DETAIL")
oView:AddSheet("IDFOLDER","IDSHEET01","Percurso para MDF-e")

oView:SetOwnerView( "VIEW_DYB"  , "TOPO"     )
oView:SetOwnerView( "VIEW_DYC"  , "DETALHE"  )
oView:SetOwnerView( "VIEW_DJ1"  , "PERCURSO"  )
oView:SetOwnerView( "VIEW_CALC" , "TOTAIS"  )

oView:AddIncrementField( "TMSA147_DYC", "DYC_ITEM" )
oView:AddIncrementField( "TMSA147_DJ1", "DJ1_SEQUEN")

Return oView

//===========================================================================================================
/* Funcao responsavel por incilizar alguns campos da tabela DYC.
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		7.00.111010P
@since 	12/06/2012
@return 	cRet - */
//===========================================================================================================
Function TMSA147RCp(cCampo)

Local aGetArea	:= GetArea()
Local cRet := ""

Default cCampo := ""

If Alltrim(cCampo) == "DYC_NOMREM"
	DT6->(DbSetOrder(1))
	DT6->(DbSeek(xFilial("DT6")+DYC->(DYC_FILDOC + DYC_DOC + DYC_SERIE)))
	cRet := Posicione("SA1",1,xFilial("SA1")+DT6->DT6_CLIREM+DT6->DT6_LOJREM,"A1_NOME")
ElseIf  Alltrim(cCampo) == "DYC_NOMDES"
	DT6->(DbSetOrder(1))
	DT6->(DbSeek(xFilial("DT6")+DYC->(DYC_FILDOC + DYC_DOC + DYC_SERIE)))
	cRet := Posicione("SA1",1,xFilial("SA1")+DT6->DT6_CLIDES+DT6->DT6_LOJDES,"A1_NOME")
EndIf

RestArea( aGetArea )
Return(cRet)


//===========================================================================================================
/* Gravacao do Formulario
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		7.00.111010P
@since 	12/06/2012
@return 	lRet -  */
//===========================================================================================================
Static Function TMSA147GRV( oModel )

Local aGetArea	:= GetArea()
Local lRet			:= .T.
Local nCount 		:= 0
Local oMdlStru 	:= oModel:GetModel( "TMSA147_DYC" )
Local nOperation	:= oModel:GetOperation()

FwFormCommit( oModel )

For nCount := 1 To oMdlStru:Length()

	oMdlStru:GoLine( nCount )
	DUD->( DbSetOrder( 7 ) )

		If nOperation <> 5 .And. !oMdlStru:IsDeleted()
			If DUD->( DbSeek( xFilial( "DUD" ) +  oMdlStru:GetValue( "DYC_FILDOC" ) + oMdlStru:GetValue( "DYC_DOC" ) + oMdlStru:GetValue( "DYC_SERIE" ) + Space( TamSX3( "DUD_NUMROM" )[ 1 ] ) ) )
				RecLock( "DUD", .F. )
					DUD->DUD_NUMROM := M->DYB_NUMROM
					DUD->DUD_STATUS := StrZero( 3, Len( DUD->DUD_STATUS ) ) // Carregado
				MsUnLock()
			EndIf
		Else
				If DUD->( DbSeek( xFilial( "DUD" ) + oMdlStru:GetValue( "DYC_FILDOC" ) + oMdlStru:GetValue( "DYC_DOC" ) + oMdlStru:GetValue( "DYC_SERIE" )  + oMdlStru:GetValue( "DYC_NUMROM" ) ) )
					RecLock( "DUD", .F. )
						DUD->DUD_NUMROM := Space( TamSX3( "DUD_NUMROM" )[ 1 ] )
						DUD->DUD_STATUS := StrZero( 1, Len( DUD->DUD_STATUS ) ) // Em Aberto
					MsUnLock()
				EndIf
		EndIf

Next nCount

RestArea( aGetArea )
Return( lRet )

//===========================================================================================================
/* Pós Validação
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		7.00.111010P
@since 	12/06/2012
@return 	lRet */
//===========================================================================================================

Static Function TMSA147POS( oModel )

Local aGetArea	:= GetArea()
Local lRet 		:= .T.
Local nOperation 	:= oModel:GetOperation()

If nOperation == 5

	If M->DYB_STATUS <> "1"

		lRet := .F.
		Help( "", 1, "TMSA147002" )  // O registro nao pode ser deletado, pois o mesmo nao se encotra em aberto.

	EndiF

ElseIf nOperation == 4

	If M->DYB_STATUS <> "1"

		lRet := .F.
		Help( "", 1, "TMSA147002" ) // O registro nao pode ser alterado, pois o mesmo nao se encotra em aberto.

	EndiF

EndIf

RestArea( aGetArea )
Return( lRet )

//===========================================================================================================
/* Rotina é responsavel por apontar as operacao de SAIDA / CHEGADA do Cadastro de Romaneios.
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		7.00.111010P
@since 	12/06/2012
@return 	 */
//===========================================================================================================
Function TMSA147FEC(lSaida)

Local aGetArea	:= GetArea()
Local oDlg			:= Nil
Local oBtn1		:= Nil
Local oBtn2		:= Nil

Private dDataSai  := DYB->DYB_DATSAI
Private cHoraSai  := DYB->DYB_HORSAI
Private dDataEnt  := DYB->DYB_DATCHG
Private cHoraEnt  := DYB->DYB_HORCHG
Private lGrava	 := .F.

	DEFINE MSDIALOG oDlg FROM 000,000 TO 115,373 TITLE STR0018 STYLE DS_MODALFRAME PIXEL // "Operacao de Saida e Chega do Romaneio"
	oDlg:LEscClose := .F.

	@ 002,004 TO 040,185 OF oDlg PIXEL

	//----------------------------------------------------------------------------------------------------------------
	@ 010,010 SAY STR0019 SIZE 70,10 OF oDlg PIXEL // "Data Saida"
	@ 010,050 MSGET oDataSai Var dDataSai PICTURE "@D" When lSaida .And. Empty(dDataEnt) .And. Empty(cHoraEnt) SIZE 043,008 OF oDlg PIXEL

	@ 010,095 SAY STR0020 SIZE 70,10 OF oDlg PIXEL // "Hora Saida"
	@ 010,135 MSGET cHoraSai PICTURE	"@R 99:99" Valid TMSA147VLD( lSaida, "CHORASAI" ) When lSaida .And. Empty(dDataEnt) .And. Empty(cHoraEnt) SIZE 043,008 OF oDlg PIXEL
	//----------------------------------------------------------------------------------------------------------------
	@ 025,010 SAY STR0021 SIZE 70,10 OF oDlg PIXEL // "Data Entrada"
	@ 025,050 MSGET dDataEnt PICTURE "@D" When !lSaida .And. !Empty(dDataSai) .And. !Empty(cHoraSai) SIZE 043,008 OF oDlg PIXEL

	@ 025,095 SAY STR0022 SIZE 70,10 OF oDlg PIXEL // "Hora Entrada"
	@ 025,135 MSGET cHoraEnt PICTURE	"@R 99:99" Valid TMSA147VLD( lSaida, "CHORAENT" ) When !lSaida .And. !Empty(dDataSai) .And. !Empty(cHoraSai) SIZE 043,008 OF oDlg PIXEL

	oBtn1 := TBtnBmp2():New( 085,260,52,25,'OK'    ,,,,{|| Iif( TMSA147VLD( lSaida, "TUDOOK" ), lGrava := .T. , Nil ) ,  Iif( lGrava, oDlg:End(), Nil ) },oDlg,,,.T. )
	oBtn2 := TBtnBmp2():New( 085,320,52,25,'CANCEL',,,,{|| lGrava := .F.,  oDlg:End()},oDlg,,,.T. )

	ACTIVATE MSDIALOG oDlg CENTERED

	If lGrava
		RecLock( "DYB", .F. )

		If lSaida .And. DYB->DYB_STATUS <> "3" .And. dDataSai  <> DYB->DYB_DATSAI .And. cHoraSai  <> DYB->DYB_HORSAI
			DYB->DYB_DATSAI := dDataSai
			DYB->DYB_HORSAI := cHoraSai
			DYB->DYB_STATUS := Iif( Empty( dDataSai ) .And. Empty( cHoraSai ), "1", "2" )
		EndIf
		If !lSaida .And. dDataEnt  <> DYB->DYB_DATCHG .And. cHoraEnt  <> DYB->DYB_HORCHG
			DYB->DYB_DATCHG := dDataEnt
			DYB->DYB_HORCHG := cHoraEnt
			DYB->DYB_STATUS := Iif( Empty( dDataEnt ) .And. Empty( cHoraEnt ), "2", "3" )
		EndIf
		DYB->( MsUnLock() )
	EndIf

RestArea( aGetArea )
Return()

//===========================================================================================================
/* Rotina eh responsavel por validar a digitacao da tela de Apontamento de SAIDA / CHEGADA do Cadastro de
   Romaneios.
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		7.00.111010P
@since 	12/06/2012
@return 	lRet */
//===========================================================================================================
Static Function TMSA147VLD(lSaida, cCampo)

Local aGetArea	:= GetArea()
Local lRet 		:= .T.

If lSaida
	If cCampo == "DDATASAI" .Or. cCampo == "CHORASAI"

		If !Empty( dDataSai ) .And. !Empty( cHoraSai )
			lRet := AtVldHora( cHoraSAI ) .And. ValDatHor( dDataSai, cHoraSai, DYB->DYB_DATGER, DYB->DYB_HORGER )
		EndIf

	ElseIf cCampo == "TUDOOK"
		If ( Empty( dDataSai ) .And. !Empty( cHoraSai ) ) .Or. ( !Empty( dDataSai ) .And. Empty( cHoraSai ) )
			lRet := .F.
			NaoVazio()
		ElseIf  Empty( dDataSai ) .And. Empty( cHoraSai )
			DUA->( DbSetOrder( 11 ) )
			If DUA->( DbSeek( xFilial( "DUA" ) + DYB->DYB_NUMROM ) )
				lRet := .F.
				Help( "", 1, "TMSA147003" ) // Nao e possivel estornar o apontamento de saida do romaneio, pois existe ocorrencia lacanda para o mesmo.
			EndIf
		EndIf
	EndIf

Else

	If cCampo == "DDATAENT" .Or. cCampo == "CHORAENT"

		If !Empty( dDataEnt ) .And. !Empty( cHoraEnt )
			lRet := AtVldHora( cHoraEnt ) .And. ValDatHor( dDataEnt, cHoraEnt, DYB->DYB_DATSAI, DYB->DYB_HORSAI )
		EndIf

	ElseIf cCampo == "TUDOOK"
		If ( Empty( dDataEnt ) .And. !Empty( cHoraEnt ) ) .Or. ( !Empty( dDataEnt ) .And. Empty( cHoraEnt ) )
			lRet := .F.
			NaoVazio()
		EndIf
	EndIf

EndIf

RestArea( aGetArea )
Return( lRet )

//===========================================================================================================
/* Rotina eh responsavel por validar a digitacao da tela de Romaneio
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		7.00.111010P
@since 	12/06/2012
@return 	lRet */
//===========================================================================================================

Function TMSA147VCp( cCampo )

Local aGetArea	:= GetArea()
Local lRet 		:= .T.
Local cFildoc 	:= ""
Local cDoc    	:= ""
Local cSerie  	:= ""

Default cCampo := ReadVar()

If cCampo $ "DYC_FILDOC/DYC_DOC/DYC_SERIE"
	cFilDoc	:= FwFldGet( "DYC_FILDOC" )
	cDoc 		:= FwFldGet( "DYC_DOC"    )
	cSerie 	:= FwFldGet( "DYC_SERIE"  )

	If !Empty( cFilDoc ) .And. !Empty( cDoc ) .And. !Empty( cSerie )
		DT6->( DbSetOrder(1) )
		lRet := DT6->( DbSeek( xFilial( "DT6" ) + cFilDoc + cDoc + cSerie ) )

		If lRet
			DUD->( DbSetOrder( 7 ) ) // DUD_FILIAL+DUD_FILORI+DUD_STATUS+DUD_VIAGEM
			lRet := DUD->( DbSeek( xFilial( "DUD" )  + cFilDoc + cDoc + cSerie + Space( Len( DUD->DUD_NUMROM ) ) ) )
			If !lRet
				Help( " ", 1, "REGNOIS" )
			EndIf
		Else
			Help( " ", 1, "REGNOIS" )
		EndIf

	EndIf

EndIf

RestArea( aGetArea )
Return( lRet )

//===========================================================================================================
/* Funcao responsavel em listar os conhecimentos de frete do romaneio e gravar as ocorrencias de forma
	automatica (CTRC + Marcado = CTRC Nao Entregue - CTRC + Desnarcado = CTRC Entregue)
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		7.00.111010P
@since 	12/06/2012
@return 	lRet */
//===========================================================================================================
Function TMSA147OCO()

Local aArea         := GetArea()
Local lRet          := .T.
Local cOcorEnt      := SuperGetMv( "MV_OCORENT", .F., "" )
Local cOcorRee      := SuperGetMv( "MV_OCORREE", .F., "" )
Local nX            := 0
Local aCpoGDa       := { "DYC_FILDOC" , "DYC_DOC" , "DYC_SERIE", "DYC_NOMREM", "DYC_QTDVOL", "DYC_PESO", "DYC_PESOM3", "DYC_VALMER", "DYC_OBS" }
Local aAlter        := { "OK", "DYC_OBS" }
Local nSuperior     := C(040)
Local nEsquerda	    := C(001)
Local nInferior     := C(180)
Local nDireita      := C(302)
Local nOpc          := GD_UPDATE
Local cLinOk        := "AllwaysTrue"    // Funcao executada para validar o contexto da linha atual do aCols
Local cTudoOk       := "AllwaysTrue"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
Local nFreeze       := 000
Local nMax          := 999
Local cFieldOk      := "AllwaysTrue"
Local cSuperDel     := ""
Local cDelOk        := "AllwaysTrue"
Local cQry1         := ""
Local cAliasQry     := GetNextAlias()
Local oDlgNF        := Nil
Local OGETDNF       := Nil
Local nOpca         := 0
Local nMarcados     := 0
Local cNumOco       := ""
Local cFilOco       := ""
Local lMarcado 	    := .F.
Local aCab          := {}
Local aItens        := {}
Local lVazio        := .F.
Local oFont         := Nil
Local nPos          := 0
Local aDYCHeader    := {}

Private aHeader     := {}
Private aCols       := {}
Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.

If DYB->DYB_STATUS == "1"
	lRet := .F.
	Help( "", 1, "TMSA147004" ) // Nao e possivel registrar uma ocorrencia para o romaneio em aberto.

Else

	// Carrega aHead
	Aadd(aHeader,{"","OK","@BMP",1,0,"","","","","","",""})

    aDYCHeader := APBuildHeader("DYC")

	For nX := 1 to Len(aCpoGDa)
        nPos := AScan(aDYCHeader, { |coluna| AllTrim(coluna[2]) == aCpoGDa[nX]})
		If nPos > 0
            AAdd( aHeader, aDYCHeader[nPos])
		Endif
	Next nX

	cQry1 :=         " SELECT "
	cQry1 += CRLF +  "            DT6_FILDOC,DT6_DOC, DT6_SERIE, A1_NOME, DT6_QTDVOL, DT6_PESO, DT6_PESOM3, DT6_VALMER  "
	cQry1 += CRLF +  "      FROM " + RetSqlName("DYC") + " DYC "

	cQry1 += CRLF +  "           Inner Join " + RetSqlName( "DT6" ) + " DT6 ON "
	cQry1 += CRLF +  "               DT6_FILIAL      = '" +xFilial("DT6")+"' "
	cQry1 += CRLF +  "           AND DT6_FILDOC      = DYC_FILDOC "
	cQry1 += CRLF +  "           AND DT6_DOC         = DYC_DOC "
	cQry1 += CRLF +  "           AND DT6_SERIE       = DYC_SERIE "
	cQry1 += CRLF +  "           AND DT6_STATUS      <> '7' "
	cQry1 += CRLF +  "           AND DT6.D_E_L_E_T_  = '' "

	cQry1 += CRLF +  "           Inner Join " + RetSqlName( "SA1" ) + " SA1 ON "
	cQry1 += CRLF +  "               A1_FILIAL       = '" +xFilial("SA1")+"' "
	cQry1 += CRLF +  "           AND A1_COD          = DT6_CLIREM "
	cQry1 += CRLF +  "           AND A1_LOJA         = DT6_LOJREM "
	cQry1 += CRLF +  "           AND SA1.D_E_L_E_T_  = '' "

    	cQry1 += CRLF +  "      WHERE
	cQry1 += CRLF +  "          DYC_FILIAL = '" +xFilial("DYC")+"' "
	cQry1 += CRLF +  "      AND DYC_NUMROM =  '" +DYB->DYB_NUMROM+ "' "
	cQry1 += CRLF +  "      AND DYC.D_E_L_E_T_  = '' "


	cQry1 := ChangeQuery(cQry1)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry1),cAliasQry, .F., .T.)

	// Carregar aqui as Colunas da GetDados.
	If (cAliasQry)->( !Eof() )

		(cAliasQry)->( dbEval( { || ;
		(AAdd(aCols, { ;
		"LBOK",;
		(cAliasQry)->DT6_FILDOC       ,;
		(cAliasQry)->DT6_DOC          ,;
		(cAliasQry)->DT6_SERIE        ,;
		(cAliasQry)->A1_NOME          ,;
		(cAliasQry)->DT6_QTDVOL       ,;
		(cAliasQry)->DT6_PESO         ,;
		(cAliasQry)->DT6_PESOM3       ,;
		(cAliasQry)->DT6_VALMER       ,;
		""                            ,;
		.F. }), () ) },,;
		{ || !EOF() } ) )

	Else
		aAdd(aCols, { 	"LBOK", "", "", "", "", 0, 0, 0, 0, "", .F. } )
		lVazio := .T.
	EndIf

	(cAliasQry)->( DbCloseArea() )
	RestArea( aArea )

	Define MsDialog oDlgNF Title STR0023 From C(178),C(181) To C(560),C(783) Pixel // "Ocorrencias do Romaneio de Entrega"

	Define FONT oFont NAME "Mono As" SIZE 6,14

	@ 35 ,10   SAY STR0024 SIZE 170,10 Pixel Of oDlgNF FONT oFont  // "[X] - Documento marcado     = Documento entregue"
	@ 40 ,10   SAY STR0025 SIZE 170,10 Pixel Of oDlgNF FONT oFont  // "[ ] - Documento não marcado = Documento não entregue"

	oGetdnf := MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,{||.T. },,aAlter,nFreeze,nMax,cFieldOk,cSuperDel,;
	cDelOk,oDlgNF,aHeader,aCols)

	oGetdnf:oBrowse:blDblClick := { || TMSA147CLI(@OGETDNF) }

	Activate MsDialog oDlgNF Centered On Init EnchoiceBar(oDlgNF,{|| Iif(oGetdnf:TudoOk(),(nOpca:=1, oDlgNF:End()),nOpca:=0)},{|| nOpca:=0, oDlgNF:End() })

	If nOpca == 0
		lRet := .F.

	ElseIf nOpca == 1 .And. !lVazio

		//-- Cabecalho da Ocorrencia
		AAdd( aCab, { "DUA_FILORI", ""             , Nil } )
		AAdd( aCab, { "DUA_VIAGEM", ""             , Nil } )
		AAdd( aCab, { "DUA_NUMROM", DYB->DYB_NUMROM, Nil } )

		For nX:= 1 To Len(oGetdnf:aCols)
			lMarcado := oGetdnf:aCols[nX, GdFieldPos("OK")] == "LBOK"
			//-- Itens da Ocorrencia
			AAdd(aItens,{ ;
				{"DUA_SEQOCO", StrZero( nX, Len( DUA->DUA_SEQOCO ) )					,	Nil },;
				{ "DUA_DATOCO", dDataBase											 	,	Nil },;
				{ "DUA_HOROCO", SubStr( StrTran( Time( ), ":" ), 1,4 )				,	Nil },;
				{ "DUA_CODOCO", ( Iif( lMarcado, cOcorEnt, cOcorRee ) )				,	Nil },;
				{ "DUA_SERTMS", StrZero( 3, Len( DUA->DUA_SERTMS ) )					,	Nil },;
				{ "DUA_FILDOC", oGetdnf:aCols[ nX, GdFieldPos( "DYC_FILDOC" ) ]	,	Nil },;
				{ "DUA_DOC"   , oGetdnf:aCols[ nX, GdFieldPos( "DYC_DOC"    ) ]	,	Nil },;
				{ "DUA_SERIE" , oGetdnf:aCols[ nX, GdFieldPos( "DYC_SERIE"  ) ]	,	Nil },;
				{ "DUA_QTDOCO", oGetdnf:aCols[ nX, GdFieldPos( "DYC_QTDVOL" ) ]	,	Nil },;
				{ "DUA_PESOCO", oGetdnf:aCols[ nX, GdFieldPos( "DYC_PESO"   ) ]	,	Nil },;
				{ "DUA_MOTIVO", oGetdnf:aCols[ nX, GdFieldPos( "DYC_OBS"    ) ]	,	Nil }})
			Next nI

		//-- Inclusao da Ocorrencia
		MsExecAuto({|x,y,z|Tmsa360(x,y,z)},aCab,aItens,{},3)

		If lMsErroAuto
			MostraErro()
			lRet	:= .F.
		EndIf
	EndIf
EndIf

RestArea( aArea )
Return(lRet)

//===========================================================================================================
/* Funcao responsavel pela marcacao no browse
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		7.00.111010P
@since 	12/06/2012
@return 	 */
//===========================================================================================================

Static Function TMSA147CLI( oGetdnf )

If oGetdnf:aCols[ oGetdnf:oBrowse:nAt, GdFieldPos( "OK" ) ] == "LBOK"
	oGetdnf:aCols[ oGetdnf:oBrowse:nAt, GdFieldPos( "OK" ) ] := "LBNO"
Else
	oGetdnf:ACOLS[ oGetdnf:oBrowse:nAt, GdFieldPos( "OK" ) ] := "LBOK"
ENDIF
oGetdnf:Refresh()
oGetdnf:oBrowse:Refresh()

Return( Nil )

//===========================================================================================================
/* PRE Validação
@author  	Fabio Marchiori Sampaio
@version 	P11 R11.8
@build
@since 	01/09/2014
@return 	lRet */
//===========================================================================================================

Static Function TMSA147PRE( oModel )

Local aGetArea	:= GetArea()
Local lRet 		:= .T.
Local nOperation 	:= oModel:GetOperation()
Local cAliasDYB

If nOperation == 5 .Or. nOperation == 4

	cAliasDYB	:= GetNextAlias()

	cQuery := " SELECT DTX.DTX_MANIFE, DYN.DYN_IDCMDF FROM " + RetSqlName("DYB") + " DYB "
	cQuery += "	JOIN " + RetSqlName("DTX") + " DTX "
	cQuery += " 		ON DTX.DTX_FILIAL = '"+xFilial("DTX")+"'"
	cQuery += "		AND DTX.DTX_NUMROM = DYB.DYB_NUMROM "
	cQuery += "		AND DTX.D_E_L_E_T_ <> '*' "
	cQuery += "	LEFT JOIN " + RetSqlName("DYN") + " DYN "
	cQuery += " 		ON DYN.DYN_FILIAL = '"+xFilial("DYN")+"'"
	cQuery += "		AND DYN.DYN_NUMROM = DYB.DYB_NUMROM "
	cQuery += "		AND DYN.D_E_L_E_T_ <> '*' "
	cQuery += "	WHERE  DYB.DYB_FILIAL = '"+xFilial("DYB")+"'"
	cQuery += "	AND DYB.DYB_NUMROM = '"+ DYB->DYB_NUMROM+"'"
	cQuery += "	AND DYB.D_E_L_E_T_ <> '*' "

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDYB, .T., .F.)

	If !(cAliasDYB)->( Eof() )
		If !Empty((cAliasDYB)->DTX_MANIFE)
			Help( "", 1, "TMSA147005" ,, (cAliasDYB)->DTX_MANIFE ,5,11)  // Romaneio não pode ser alterado ou excluído, o mesmo possui MDF-e número:
			lRet := .F.
		Else
			If Empty((cAliasDYB)->DYN_IDCMDF) .Or. (cAliasDYB)->DYN_IDCMDF <> '101'
		  		Help( "", 1, "TMSA147006" ,, (cAliasDYB)->DTX_MANIFE ,5,11)  // Romaneio não pode ser alterado ou excluído, o mesmo possui MDF-e ainda não autorizado o cancelamento pela SEFAZ:
		  		lRet := .F.
			EndIf
		EndIf
	EndIf

	(cAliasDYB)->(dbCloseArea())

EndIf

RestArea( aGetArea )
Return( lRet )


//-------------------------------------------------------------------
/*{Protheus.doc} AjustaHelp

Ajusta o Help

@author Fabio Marchiori Sampaio
@since 20/08/14
@version 1.0
*/
//-------------------------------------------------------------------

Static Function AjustaHelp()

Local aHlpPor1 := { "Romaneio não pode ser alterado ou excluído, ","o mesmo possui MDF-e número: "}
Local aHlpPor2 := { "Romaneio não pode ser alterado ou excluído, ","o mesmo possui MDF-e ainda não autorizado ", " o cancelamento pela SEFAZ: "}

PutHelp("PTMSA147005", aHlpPor1, , , .F.)
PutHelp("PTMSA147006", aHlpPor2, , , .F.)

Return
