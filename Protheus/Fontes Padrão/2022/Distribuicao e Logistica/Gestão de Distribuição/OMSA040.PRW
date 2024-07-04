#Include "Protheus.ch"
#Include "OMSA040.CH"
#INCLUDE "FWMVCDEF.CH"

Static lRestRepom	:= SuperGetMV( 'MV_VSREPOM',, '1' ) == '2.2'
Static lPagBem		:= FindFunction("TMSIntgPB")

//===========================================================================================================
/* Cadastramento de Motorista
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 	30/10/2012
@return

14/12/13 -> MAURO PALADINI -> Ajuste para funcionamento do Mile */

//===========================================================================================================
Function OMSA040( aRotAuto, nOpcAuto, aRotItem )

Local oMBrowse		:= Nil
Local lTMSOPdg		:= SuperGetMV('MV_TMSOPDG',,'0') $ '1|2'
Local l040Auto		:= (ValType(aRotAuto) == "A")
Local aAutoCab		:= {}
Local aAutoItens	:= {}

Private aRotina	:= MenuDef()

Default nOpcAuto	:= 0
Default aRotItem	:= {}

If l040Auto
	aAutoCab   := Aclone( aRotAuto )
	aAutoItens := Aclone( aRotItem )
	if lTMSOPdg
		FwMvcRotAuto( ModelDef(), "DA4", nOpcAuto, { { "OMSA040_DA4", aAutoCab }, { "MdGridDEL", aAutoItens }  } )  //Chamada da rotina automatica através do MVC
    else
		FwMvcRotAuto( ModelDef(), "DA4", nOpcAuto, { { "OMSA040_DA4", aAutoCab } } )  //Chamada da rotina automatica através do MVC
	EndIF
Else
	//===========================================================================================================
	// Funcao de BROWSE
	//===========================================================================================================

	oMBrowse:= FWMBrowse():New()
	oMBrowse:SetAlias("DA4")
	oMBrowse:SetDescription( OemToAnsi( STR0001 ) )

	//-- Ponto de entrada para incluir legenda no Browse
	If ExistBlock("OM040LEG")
		aRetPE := ExecBlock("OM040LEG",.F.,.F.)
		If ValType(aRetPE) == 'A'
			AEval(aRetPE,{|x| oMBrowse:AddLegend(x[1],x[2],x[3])})
		EndIf
	EndIf

	If lTMSOPdg 
		Pergunte('OMS040',.F.)
		oMBrowse:SetParam( { || Pergunte('OMS040',.T.) } )
	EndIf
	
	oMBrowse:Activate()

EndIf

Return

//===========================================================================================================
/* Retorna o modelo de Dados da rotina Cadastro de Motorista
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 	10/10/2012
@return 	oModel - Modelo de Dados */
//===========================================================================================================
Static Function ModelDef()

Local oModel		:= Nil
Local oStruDA4		:= Nil
Local oStruDEL		:= Nil
Local oStruDJ2		:= Nil
Local oStruDN7		:= Nil
Local lIntGFE		:= SuperGetMv('MV_INTGFE',,.F.) 
Local lTMSOPdg		:= SuperGetMV('MV_TMSOPDG',,'0') $ '1|2'
Local cTMSRre 		:= SuperGetMv("MV_TMSRRE" ,.F.,"") // 1=Calculo Frete, 2=Cotação, 3=Viagem, 4=Sol.Coleta, Em Branco= Nao Utiliza

oStruDA4	:= FwFormStruct( 1, "DA4" )
oStruDEL	:= FwFormStruct( 1, "DEL" )
oStruDJ2	:= FwFormStruct( 1, "DJ2" )

If lIntGFE
	oStruDA4:AddField( ;                      // Ord. Tipo Desc.
	"CGC Fornec."                    , ;      // [01]  C   Titulo do campo
	"CGC Fornec."                    , ;      // [02]  C   ToolTip do campo
	"DA4_CGCFOR"                     , ;      // [03]  C   Id do Field
	'C'                              , ;      // [04]  C   Tipo do campo
	14                               , ;      // [05]  N   Tamanho do campo
	0                                , ;      // [06]  N   Decimal do campo
	NIL                              , ;      // [07]  B   Code-block de validação do campo
	NIL                              , ;      // [08]  B   Code-block de validação When do campo
	NIL                              , ;      // [09]  A   Lista de valores permitido do campo
	NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD,'IIF(!Inclui,Posicione("SA2",1,xFilial("SA2")+DA4->DA4_FORNEC+DA4->DA4_LOJA,"A2_CGC"),"")' ), ;      // [11]  B   Code-block de inicializacao do campo
	NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
	NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.T.                              )        // [14]  L   Indica se o campo é virtual

	oStruDA4:AddTrigger( ;
	"DA4_LOJA", ;                                                      // [01] Id do campo de origem
	"DA4_CGCFOR" , ;                                                   // [02] Id do campo de destino
	{|| .T. }   , ;                                                    // [03] Bloco de codigo de validação da execução do gatilho
	&( ' { | oModel | Posicione("SA2",1,xFilial("SA2")+M->DA4_FORNEC+M->DA4_LOJA,"A2_CGC") } ' ) )   // [04] Bloco de codigo de execução do gatilho

EndIf

oModel:= MpFormModel():New( "OMSA040", /*bPre*/, { |oModel| PosVldMdl( oModel ) },  { |oModel| CommitMdl( oModel ) }, /*bCancel*/ )

oModel:SetDescription( OemToAnsi(STR0001) )

oModel:AddFields( "OMSA040_DA4", Nil, oStruDA4 )

oModel:SetPrimaryKey( { "DA4_FILIAL", "DA4_COD" } )

If lTMSOPdg

	oModel:AddGrid( "MdGridDEL", "OMSA040_DA4", oStruDEL )

	oModel:SetRelation( "MdGridDEL", { { "DEL_FILIAL", "xFilial( 'DEL' )" }, { "DEL_CODMOT", "DA4_COD" } }, DEL->( IndexKey( 1 ) ) )

	oModel:GetModel( "MdGridDEL" ):SetUniqueLine( { "DEL_CODOPE", "DEL_IDOPE" } )

	oModel:GetModel( "MdGridDEL" ):SetOptional( .T. )
	
	oModel:GetModel( "MdGridDEL" ):SetUseOldGrid( .T. )
	
Endif

If !Empty(cTMSRre) .And. cTMSRre <> "0" 
	
	oModel:AddGrid("MdGridDJ2","OMSA040_DA4", oStruDJ2)
	
	oModel:SetRelation( "MdGridDJ2", { {"DJ2_FILIAL", "xFilial( 'DJ2' )"}, {"DJ2_CODMOT", "DA4_COD"} }, DJ2->( IndexKey( 1 ) ) )
		
	oModel:GetModel( "MdGridDJ2" ):SetUniqueLine({"DJ2_CODCAR"})
	
	oModel:GetModel( "MdGridDJ2" ):SetOptional( .T. )
		
EndIf	

If AliasInDic("DN7")
	oStruDN7 := FwFormStruct(1,"DN7")
	oModel:AddGrid("MdGridDN7","OMSA040_DA4",oStruDN7)
	oModel:SetRelation("MdGridDN7",{{"DN7_FILIAL","xFilial('DN7')"},;
									{"DN7_CODMOT","DA4_COD"}},;
									DN7->(IndexKey(1)))
	oModel:GetModel("MdGridDN7"):SetUniqueLine({"DN7_CODFON"})
	oModel:GetModel("MdGridDN7"):SetOptional(.T.)
EndIf

Return( oModel )

//===========================================================================================================
/* Retorna a View (tela) da rotina Cadastro de Motorista
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 	10/10/2012
@return 	oView -  */
//===========================================================================================================
Static Function ViewDef()

Local oModel    := FwLoadModel( "OMSA040" )
Local oView     := Nil
Local oStruDA4  := FwFormStruct( 2, "DA4" )
Local oStruDEL  := FwFormStruct( 2, "DEL" )
Local oStruDJ2  := FwFormStruct( 2, "DJ2" )
Local oStruDN7  := Nil
Local lTMSOPdg  := SuperGetMV( "MV_TMSOPDG", , "0") $ '1|2'
Local lOM040BTN	:= ExistBlock("OM040BTN")
Local aBtnPE    := {}
Local nCont     := 0
Local cTMSRre   := SuperGetMv("MV_TMSRRE" ,.F.,"") // 1=Calculo Frete, 2=Cotação, 3=Viagem, 4=Sol.Coleta, Em Branco= Nao Utiliza

If AliasInDic("DN7")
	oStruDN7 := FwFormStruct(2,"DN7")
EndIf

oStruDEL:RemoveField( "DEL_CODMOT" )
oStruDEL:RemoveField( "DEL_NOMMOT" )

oStruDJ2:RemoveField( "DJ2_CODMOT" )
oStruDJ2:RemoveField( "DJ2_NOMMOT" )
oView := FwFormView():New()

oView:SetModel( oModel )

If !Empty(cTMSRre) .And. cTMSRre <> "0" .And. lTMSOPdg
		
	oView:AddGrid( "VwGridDJ2", oStruDJ2, "MdGridDJ2" )
	oView:AddGrid( "VwGridDEL", oStruDEL, "MdGridDEL" )
	
	If AliasInDic("DN7")
		oView:CreateHorizontalBox("Field"  ,040)
		oView:CreateHorizontalBox("FOLDER" ,030)
		oView:CreateHorizontalBox("INTEGRA",030)
	Else
		oView:CreateHorizontalBox( "Field" , 060 )
		oView:CreateHorizontalBox( "FOLDER", 040 )
	EndIf
	
	oView:CreateFolder( "PASTA", "FOLDER" )
	
	oView:AddSheet( "PASTA", "ABA01", STR0029 )   //Motoristas x Caracteristicas
	oView:AddSheet( "PASTA", "ABA02", STR0006 ) // Motorista X Operadora 
	
	oView:CreateHorizontalBox( "GridDJ2"  , 100,,,"PASTA","ABA01" )
	oView:CreateHorizontalBox( "GridDEL"  , 100,,,"PASTA","ABA02" )
	
	oView:SetOwnerView("VwGridDJ2", "GridDJ2" )
	oView:SetOwnerView("VwGridDEL", "GridDEL" )
	
	oView:AddIncrementView( "VwGridDJ2", "DJ2_ITEM" )
	oView:AddIncrementView( "VwGridDEL", "DEL_ITEM" )
		
ElseIf !Empty(cTMSRre) .And. cTMSRre <> "0" 
	
	If AliasInDic("DN7")
		oView:CreateHorizontalBox("Field"  ,040)
		oView:CreateHorizontalBox("Grid"   ,030)
		oView:CreateHorizontalBox("INTEGRA",030)
	Else
		oView:CreateHorizontalBox( "Field" , 070 )
		oView:CreateHorizontalBox( "Grid"  , 030 )
	EndIf
	
	oView:AddGrid( "VwGridDJ2", oStruDJ2, "MdGridDJ2" )
	
	oView:SetOwnerView("VwGridDJ2", "Grid" )
	
	oView:AddIncrementView( "VwGridDJ2", "DJ2_ITEM" )
	
	oView:EnableTitleView( "VwGridDJ2" )

ElseIf lTMSOPdg

	If AliasInDic("DN7")
		oView:CreateHorizontalBox("Field"  ,040)
		oView:CreateHorizontalBox("Grid"   ,030)
		oView:CreateHorizontalBox("INTEGRA",030)
	Else
		oView:CreateHorizontalBox( "Field"	, 070 )
		oView:CreateHorizontalBox( "Grid"	, 030 )
	EndIf

	oView:AddGrid( "VwGridDEL", oStruDEL, "MdGridDEL" )

	oView:SetOwnerView( "VwGridDEL"		, "Grid"	)

	oView:AddIncrementView( "VwGridDEL", "DEL_ITEM" )

	oView:EnableTitleView( "VwGridDEL" )

Else
	If AliasInDic("DN7")
		oView:CreateHorizontalBox("Field"  ,060)
		oView:CreateHorizontalBox("INTEGRA",040)
	Else
		oView:CreateHorizontalBox( "Field"	, 100 )
	EndIf
EndIf

oView:AddField( "VwFieldDA4", oStruDA4, "OMSA040_DA4"	)

oView:SetOwnerView( "VwFieldDA4"	, "Field"	)

If AliasInDic("DN7")
	oView:AddGrid("VwGridDN7",oStruDN7,"MdGridDN7")
	oView:SetOwnerView("VwGridDN7","INTEGRA")
	oView:EnableTitleView("VwGridDN7")
EndIf

If FindFunction("OMSGetFoto")
	oView:AddUserButton(STR0031,"MAGIC_BMP",{|| OMSGetFoto("DA4",/*Id Foto*/, oModel,"DA4_BITMAP","DA4_COD"),oView:LMODIFY :=.T.,oModel:LMODIFY := .T.}) //Foto
EndIf

//-- Ponto de entrada para incluir botoes
If lOM040BTN
	aBtnPE := ExecBlock( "OM040BTN", .F., .F. )
	If ValType( aBtnPE ) == 'A'
		For nCont := 1 To Len( aBtnPE )
			oView:AddUserButton( aBtnPE[nCont, 3], aBtnPE[nCont, 1], aBtnPE[nCont, 2] )
		Next nCont
	EndIf
EndIf

Return( oView )

//===========================================================================================================
/* PÓS validacao do Model
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 	10/10/2012
@return 	lRet */
//===========================================================================================================
Static Function PosVldMdl( oMdl )

Local lRet       := .T.
Local nOpcx      := oMdl:GetOperation()
Local aArea      := GetArea()
Local cAliasNew  := ''
Local cQuery     := ''
Local cMotorista := DA4->DA4_COD
Local lDA4X2MODO := FWModeAccess("DA4",3) == "E"
Local lIntGFE    := SuperGetMv("MV_INTGFE",.F.,.F.)
Local cIntGFE2   := SuperGetMv("MV_INTGFE2",.F.,"2")

If nOpcx == MODEL_OPERATION_INSERT .Or. nOpcx == MODEL_OPERATION_UPDATE

	If DA4->(FieldPos("DA4_TIPMOT") > 0)
		If (M->DA4_TIPMOT == "2" .Or. M->DA4_TIPMOT == "3") .And. !Empty(M->DA4_MAT)
			Help( " ", 1, "DL040NAO", ,RetTitle( "DA4_MAT" ), 3, 1 ) //"NÆo Informar o Campo :"
			lRet := .F.
		EndIf
	EndIf

	If lRet
		If ExistBlock("OM040TOK")
			lRet := ExecBlock("OM040TOK",.F.,.F.)
		EndIf
	EndIf

ElseIf nOpcx == MODEL_OPERATION_DELETE

	DbSelectArea("DA3")
	DbSetOrder(2)
	If dbSeek(xFilial("DA3")+cMotorista)
		lRet := .F.
		Help(" ",1,"DS0400711",,DA3->DA3_COD,05,22) //"Motorista já associado a um Caminhao, exclusão não permitida. Código do Caminhao:"
	EndIf

	//-- Ponto de entrada para validar exclusao do motorista
	If lRet
		If ExistBlock("OM040DEL")
			lRet := ExecBlock("OM040DEL",.F.,.F.)
		EndIf
	EndIf

	//-- Nao permite a exclusao do motorista quando o mesmo esta amarrado a uma montagem de cargas.
	If lRet
		#IFDEF TOP
			cAliasNew := GetNextAlias()
			cQuery := " SELECT 1 QTD "
			cQuery += " FROM " + RetSqlName("DAK") + " DAK "
			If lDA4X2MODO
				cQuery += "WHERE DAK_FILIAL  = '"+ xFilial('DA4') +"' AND "	
				cQuery += "      DAK_MOTORI = '" + DA4->DA4_COD + "'"
			Else
				cQuery += " WHERE DAK_MOTORI = '" + DA4->DA4_COD + "'"
			EndIf
			cQuery += " AND DAK.D_E_L_E_T_ = '' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasNew, .F., .T.)
			If (cAliasNew)->(!Eof()) .And. (cAliasNew)->QTD == 1
				lRet := .F.
			EndIf
			(cAliasNew)->(DbcloseArea())
		#ELSE
			DbSelectArea("DAK")
			DAK->(DbSetOrder(1))
			DAK->(DbGoTop())
			While !Eof()
				If lDA4X2MODO
					If xFilial('DA4') == DAK_FILIAL .And. DA4->DA4_COD == DAK->DAK_MOTORI
						lRet:= .F.
					EndIf
				Else
					If DA4->DA4_COD == DAK->DAK_MOTORI
						lRet:= .F.
					EndIf
				EndIf
				If !lRet
					Exit
				EndIf
				DAK->(Dbskip())
			EndDo
		#ENDIF

		If !lRet
			Help(" ",1,"OMSA04008") //--O Motorista esta em uso no Cadastro de Montagem de Carga, exclusao nao permitida.
		EndIf
	EndIf


	If lRet .And. IntTMS()
		#IFDEF TOP
			cAliasNew := GetNextAlias()
			cQuery := "SELECT DUP_FILORI, DUP_VIAGEM FROM "
			cQuery += RetSqlName("DUP")+ " DUP "
			cQuery += "WHERE "
			cQuery += "DUP_FILIAL = '"+xFilial("DUP")+"' AND "
			If lDA4X2MODO
				cQuery += "DUP_FILORI = '"+cFilAnt+"' AND "	
			EndIf
			cQuery += "DUP_CODMOT = '"+cMotorista+"' AND "
			cQuery += "DUP.D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasNew,.T.,.T.)
			If (cAliasNew)->(!Eof())
				lRet := .F.
				MsgAlert(STR0023+ " " +(cAliasNew)->DUP_FILORI+"-"+(cAliasNew)->DUP_VIAGEM)
			EndIf
			(cAliasNew)->(DbcloseArea())
		#EndIf
		If lRet
			//-- Validacao na tabela DD2 - Doc Exigidos x Motoristas
			DbSelectArea("DD2")
			DD2->(DbSetOrder(1))  //DD2_FILIAL+DD2_CODMOT
			If DD2->(dbSeek(xFilial("DD2")+cMotorista))
				lRet := .F.
				Help(" ",1,"OMSA04007")
			EndIf
		EndIf
	EndIf

EndIf

//Integração Protheus com SIGAGFE
If lRet .And. lIntGFE == .T. .And. cIntGFE2 $ "1S" .And. !IsInCallStack('TMSAO35')  //Controle Jornada Motorista
	If !InterGUU(nOpcx,.F.)
		lRet := .F.
	EndIf
EndIf

RestArea( aArea )

Return( lRet )

//===========================================================================================================
/* Gravação do Model
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 	10/10/2012
@return 	lRet */
//===========================================================================================================
Static Function CommitMdl( oMdl )

Local lRet		:= .T.
Local nOpcx		:= oMdl:GetOperation()
Local aArea		:= DA4->( GetArea() )
Local lIntGFE	:= SuperGetMv("MV_INTGFE",.F.,.F.)
Local cIntGFE2	:= SuperGetMv("MV_INTGFE2",.F.,"2")
Local lRepom	:= .F.
Local cCodMot	:= oMdl:GetValue("OMSA040_DA4", "DA4_COD")
Local cCGCMot	:= oMdl:GetValue("OMSA040_DA4", "DA4_CGC")
Local cCodOpe	:= "01"	// Repom
Local cOpePgBem	:= "03" // PAGBEM
Local lTMSOPdg	:= SuperGetMV('MV_TMSOPDG',,'0') $ '1|2'
Local oMdlDEL	:= Iif( lTMSOPdg, oMdl:GetModel("MdGridDEL") , Nil )
Local lMotXRep	:= Iif( lTMSOPdg , oMdlDEL:SeekLine( { {"DEL_CODOPE", cCodOpe } }, .F., .F. ) , Nil )
Local lPgBem	:= .F.

If lTMSOPdg .And. lMotXRep .AND. nOpcx == MODEL_OPERATION_DELETE .AND. lRestRepom
	lRepom := TMSDriLoc( cCodMot, .T., "Delete" )
EndIf

Begin Transaction

	lRet := FwFormCommit( oMdl )

	If ExistBlock("OS040GRV")
		ExecBlock("OS040GRV",.F.,.F.,{nOpcx})
	EndIf

	//Integração Protheus com SIGAGFE
	If lRet .And. lIntGFE == .T. .And. cIntGFE2 $ "1S" .And. !IsInCallStack('TMSAO35')  //Controle Jornada Motorista
		If !InterGUU( nOpcx, .T. )
			lRet := .F.
		EndIf
	EndIf

End Transaction

If lTMSOPdg .And. lMotXRep .AND. lRet .AND. lRestRepom .AND. nOpcx <> MODEL_OPERATION_DELETE
	lRepom := TMSDriver( cCodMot )
EndIf

lPgBem	:= If( lTMSOPdg , oMdlDEL:SeekLine( { {"DEL_CODOPE", cOpePgBem } }, .F., .F. ) , Nil )

If lPagBem .AND. lPgBem .And. lTMSOPdg .AND. lRet .AND. nOpcx <> MODEL_OPERATION_DELETE
	TMSIntgPB( cCodMot, cCGCMot )
EndIf

RestArea( aArea )

Return( lRet )

//===========================================================================================================
/* Retorna as operações disponiveis para o Cadastramento de Motorista
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 	10/10/2012
@return 	aRotina - Array com as opçoes de Menu */
//===========================================================================================================
Static Function MenuDef()

Local lTMSOPdg	:= SuperGetMV('MV_TMSOPDG',,'0') $ '1|2'
Local lOM040BRW	:= ExistBlock("OM040BRW")

Local aRotina   := {	{ STR0026,	"AxPesqui"			,0 , 1,,.F. },;	//"Pesquisar"
						{ STR0027,	"VIEWDEF.OMSA040"	,0 , 2 },;			//"Visualizar"
						{ STR0019,	"VIEWDEF.OMSA040"	,0 , 3 },;			//"Incluir"
						{ STR0020,	"VIEWDEF.OMSA040"	,0 , 4 },;			//"Alterar"
						{ STR0021,	"VIEWDEF.OMSA040"	,0 , 5 } }			//"Excluir"
If	lTMSOPdg
	Aadd( aRotina, { STR0017, "OMS040AtOp()", 0 , 6 } ) //-- 'DadosXOperad.'
EndIf

If	lOM040BRW
	aRotUser := ExecBlock("OM040BRW",.f.,.f.)
	If	ValType(aRotUser) == "A"
		aEval(aRotUser,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return( aRotina )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMS040Vld ³ Autor ³Henry Fila             ³ Data ³04.12.02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de validacao das datas de vencimento do motorista   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ OMS040Vld()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³OMSA040                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function OMS040Vld()
Static cFilBAnt := ""
Local aArea     := GetArea()
Local cCampo    := ReadVar()
Local lRet      := .T.

Do Case
	Case cCampo == "M->DA4_DATNAS"

		//-- Verifica se data de nascimento esta maior que a data base do sistema.
		If M->DA4_DATNAS > dDataBase
			lRet := .F.
			Help(" ",1,"DA4_DATNAS",,STR0024,2,1) //"Data de Nascimento deve ser menor que a data base do sistema."
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se  data de nascimento esta maior que a expedicao  da carteira³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(M->DA4_DTECNH)
			If M->DA4_DATNAS > M->DA4_DTECNH
				lRet := .F.
				Help(" ",1,"OMSA04001") //"Data de nascimento do motorista deve ser menor que a data de expedicao da CNH."
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se  data de nascimento esta maior que o vencimento da carteira³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .And. !Empty(M->DA4_DTVCNH)
			If M->DA4_DATNAS > M->DA4_DTVCNH
				lRet := .F.
				Help(" ",1,"OMSA04002") //"Data de nascimento do motorista deve ser menor que a data de vencimento da CNH."
			EndIf
		EndIf

	Case cCampo == "M->DA4_DTECNH"

		//-- Verifica se data de expedicao da carteira esta maior que a data base do sistema.
		If M->DA4_DTECNH > dDataBase
			lRet := .F.
			Help(" ",1,"DA4_DTECNH",,STR0025,2,1) //"Data de expedicao da CNH deve ser menor que a data base do sistema."
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se  data de nascimento esta maior que a expedicao  da carteira³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(M->DA4_DATNAS)
			If M->DA4_DATNAS > M->DA4_DTECNH
				lRet := .F.
				Help(" ",1,"OMSA04001") //"Data de nascimento do motorista deve ser menor que a data de expedicao da CNH."
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se a data de expedicao e maior que a data de vencimento       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .And. !Empty(M->DA4_DTVCNH)
			If M->DA4_DTECNH > M->DA4_DTVCNH
				lRet := .F.
				Help(" ",1,"OMSA04003") //"Data de expedicao da CNH deve ser menor que a data de vencimento."
			EndIf
		EndIf

	Case cCampo == "M->DA4_DTVCNH"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se  data de nascimento esta maior que o vencimento da carteira³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(M->DA4_DATNAS)
			If M->DA4_DATNAS > M->DA4_DTVCNH
				lRet := .F.
				Help(" ",1,"OMSA04002") //"Data de nascimento do motorista deve ser menor que a data de vencimento da CNH."
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se  data da expedicao e maior que a data do vencimento        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .And. !Empty(M->DA4_DTECNH)
			If M->DA4_DTECNH > M->DA4_DTVCNH
				lRet := .F.
				Help(" ",1,"OMSA04003") //"Data de expedicao da CNH deve ser menor que a data de vencimento."
			EndIf
		EndIf

	Case cCampo == "M->DA4_TIPMOT"

		// O Motorista so' podera' ser comissionado se for do tipo 'proprio'.
		If	M->DA4_TIPMOT <> StrZero(1, Len(DA4->DA4_TIPMOT)) .And. DA4->(FieldPos("DA4_COMISS") > 0)			
			M->DA4_COMISS := StrZero(2, Len(DA4->DA4_TIPMOT)) // Nao
		EndIf

	Case cCampo == 'M->DEL_CODOPE'
		lRet := TMSValField('M->DEL_CODOPE',.T.,'DEL_NOMOPE')
		If lRet
			DEG->(DbSetOrder(1))
			If DEG->(MsSeek(xFilial('DEG')+M->DEL_CODOPE))
				FwFldPut("DEL_NOMOPE", TMSValField('M->DEL_CODOPE',.F.,'DEL_NOMOPE'))
			Else
				Help(' ', 1, 'OMSA04004' ) //-- "O cadastro desta Operadora não foi realizado!"
				lRet := .F.
			EndIf
		EndIf

	Case cCampo == "M->DA4_FILBAS"
		If !Empty(M->DA4_FILBAS)
			lRet := TMSValidEmp(cEmpAnt+M->DA4_FILBAS)
		EndIf
		//-- Limpar campo quando trocar filial base.
		If	lRet .And. M->DA4_FILBAS <> cFilBAnt
			M->DA4_MAT := Space(TamSx3("DA4_MAT")[1])
			cFilBAnt   := M->DA4_FILBAS
		EndIf

	Case cCampo == "M->DA4_MAT"
		SRA->(DbSetOrder(1))
		If	!SRA->(MsSeek(OMS040Fil()+M->DA4_MAT))
			HELP(" ",1,"REGNOIS")
			lRet := .F.
		EndIf

	Case cCampo == "M->DEL_IDOPE"
		lRet := OS040VldId()

	Case cCampo == "M->DA4_FORNEC"
		If !Empty(M->DA4_FORNEC) .And. !Empty(M->DA4_LOJA)
			SA2->(DbSetOrder(1))
			If SA2->(MsSeek(xFilial("SA2")+M->DA4_FORNEC+M->DA4_LOJA))
				If SA2->A2_MSBLQL == "1"
					HELP(" ",1,"REGBLOQ")
					lRet := .F.
				EndIf
			Else
				HELP(" ",1,"REGNOIS")
				lRet := .F.
			EndIf
		EndIf
	Case cCampo == "M->DA4_DTIVSG"
		If !Empty(M->DA4_DTFVSG) .And. M->DA4_DTIVSG > M->DA4_DTFVSG
			M->DA4_DTFVSG:= CtoD("")
		EndIf 
		
	Case cCampo == "M->DA4_DTFVSG"
		If M->DA4_DTFVSG < M->DA4_DTIVSG
			HELP(" ",1,"OMSA04010")  //Data de Validade do Seguro Invalida!
			lRet := .F.
		EndIf
	Case cCampo == "M->DJ2_CODCAR"
		lRet:= ExistCpo("DJ0",M->DJ2_CODCAR,1)  
		If lRet
			If Posicione("DJ0",1,xFilial("DJ0")+M->DJ2_CODCAR,"DJ0_TIPO") <> StrZero(2,Len(DJ0->DJ0_TIPO))  //Motoristas
				Help(" ",1,"OMSA04011") //"Codigo de Caracteristica invalido para Motoristas.
				lRet:= .F.
			EndIf	
		EndIf		
EndCase
RestArea( aArea )

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Os040IncMo³ Autor ³ Robson Alves          ³ Data ³ 25.07.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inclusao do motorista atraves do botao do SXB.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OMS                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Os040IncMot()

Private aRotina := {{Nil,"", 0 , 3}}  
Private N       := 0 

FWExecView ("Inclusao", "OMSA040", MODEL_OPERATION_INSERT, , { || .T. } ) //, bCloseOnOk, bOk, nPercReducao, aEnableButtons, bCancel )

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMSA040Whe³ Autor ³Patricia A. Salomao    ³ Data ³29.10.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes para editar o campo DA4_COMISS                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ OMSA040Whe()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OMSA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function OMSA040Whe()
Local lRet   := .T.
Local cCampo := ReadVar()

//-- O Campo 'Comissionado' (DA4_COMISS) so' estara' habilitado se o Motorista for 'Proprio'.
If cCampo == 'M->DA4_COMISS' .And. DA4->(FieldPos("DA4_TIPMOT") > 0)
	If Empty(M->DA4_TIPMOT) .Or. M->DA4_TIPMOT <> StrZero(1, Len(DA4->DA4_TIPMOT))
		lRet := .F.
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMSA040CGC³ Autor ³Kleber Dias Gomes      ³ Data ³05.05.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes para editar o campo DA4_CGC                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ OMSA040CGC()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OMSA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function OMSA040CGC()
Local lRet   := .T.
Local aArea  := GetArea()
Local nRecno := DA4->(Recno())

If Cgc(M->DA4_CGC)
	DbSelectArea("DA4")
	DbSetOrder(3)
	If MsSeek(xFilial("DA4")+M->DA4_CGC)
		If INCLUI .Or. ( ALTERA .And. DA4->(Recno()) <> nRecno)
			If Aviso(STR0002,STR0003,{STR0004,STR0005},2)==2 //"Atencao"###"Este CNPJ/CPF está relacionado a outro motorista, deseja continuar?"###"Sim"###"Não"
				lRet := .F.
			EndIf
		EndIf
	EndIf
Else
	lRet := .F.
EndIf

RestArea( aArea )

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMSA040Tip ³ Autor ³ Allan Nogueira       ³ Data ³ 07.Dez.12³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ajustes na mascara do campo DA4_CGC.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ OMSA040Tip()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OMSA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function OMSA040Tip()
Local cMasc := ""
If !Empty(M->DA4_CGC) .And. Len(AllTrim(M->DA4_CGC))<14
	cMasc := "@R 999.999.999-99999%C" //Acrescentados 3 digitos p/ realizar a troca CPF/CNPJ 
Else
	cMasc := "@R 99.999.999/9999-99%C"
EndIf

Return cMasc

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OS040VldId ³ Autor ³ Vitor Raspa          ³ Data ³ 13.Jun.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o Cartao junto a Operadora                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ OS040VldId()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function OS040VldId( cCodOpe )
Local oObj
Local cTipMot
Local aMsgErr   := {}
Local aVisErr   := {}
Local aRetCNPJ  := {}
Local aConsCard := {}
Local lRet      := .T.
Local oView
Local oMdl017
Local oMdl		:= Nil
Local cStatus	:= ''
Local lRespCart := AliasIndic('DDQ') .And. FunName() == 'TMSA017' //Utilizar os dados do responsavel do cartão 
Local cCodFor   := If( lRespCart, M->DDQ_CODFOR, M->DA4_FORNEC	)
Local cLojFor   := If( lRespCart, M->DDQ_LOJFOR, M->DA4_LOJA	)
Local cIdOpe    := If( lRespCart, M->DDQ_IDCART, M->DEL_IDOPE	)
Local cCodMot	:= ""
Local cUrlToken	:= ""
Local cUser		:= ""
Local cPassword	:= ""

Default cCodOpe := FwFldGet( "DEL_CODOPE" )

DEG->( DbSetOrder(1) )
DEG->( MsSeek(xFilial('DEG') + cCodOpe) )
If cCodOpe == '01' //--REPOM
	If INCLUI .Or. ALTERA
		cTipMot := If(M->DA4_TIPMOT == '1', '1', '2')
		cCodMot := M->DA4_COD
	Else
		cTipMot := If(DA4->DA4_TIPMOT == '1', '1', '2')
		cCodMot := DA4->DA4_COD
	EndIf

	If !lRestRepom 
		oObj := WSIntegracao():New()

		oObj:cStrCliente           := AllTrim(DEG->DEG_IDOPE)
		oObj:cStrAssinaturaDigital := AllTrim(DEG->DEG_CODACE)
		oObj:cStrTipoEmissao       := cTipMot
		oObj:cStrCartao            := AllTrim(GDFieldGet( 'DEL_IDOPE',n ))
		oObj:_URL                  := DEG->DEG_URLWS //-- Seta a URL conforme cadastro da Operadora

		If oObj:ValidaCartaoExpress()
			If oObj:lValidaCartaoExpressResult
				Aviso(STR0012, STR0016, {STR0013}) // "AVISO"###"Id validado com sucesso!"###"OK"
			Else
				aMsgErr := TMSErrOper(cCodOpe, oObj:cStrXMLErr, '1')
				lRet    := .F.
			EndIf
		Else
			aMsgErr := TMSErrOper(cCodOpe,, '2')
			lRet    := .F.
		EndIf
	EndIf
ElseIf cCodOpe == '02' //--PamCard

	aRetCNPJ := PamCNPJEmp(cCodOpe, cFilAnt) //Função para obter CNPJ da contrante e filial de origem	

	//-- Montagem de Array com Dados para método FindCard - Pamcard
	AAdd (aConsCard,{'viagem.contratante.documento.numero',aRetCNPJ[1]} )
	AAdd (aConsCard,{'viagem.unidade.documento.tipo', aRetCNPJ[2] })
	AAdd (aConsCard,{'viagem.unidade.documento.numero', aRetCNPJ[3]} )
	AAdd (aConsCard,{'viagem.cartao.numero', AllTrim( cIdOpe ) } )

	lRet := PamFindCar(aConsCard,,lRespCart,@cStatus)	
	

	If !lRet
		lRet := PamVldFor(cCodFor, cLojFor,lRespCart)

		If !lRet
			Help('',1,'OMSA04009',,,6,0) //"Itens obrigatorios para inclusão não foram preenchidos na tabela de Fornecedores"
		Else
			//-- Montagem Array Pamcard - Inserir cartão Portador Frete - InsertCardFreight
			lRet := PamInsCtPF(aRetCNPJ, cCodFor, cLojFor, AllTrim( cIdOpe ), lRespCart )
			If lRet
				If PamFindCar(aConsCard,,lRespCart,@cStatus)
					oMdl017 := FwModelActive()
					If oMdl017<> Nil .And. oMdl017:CID = 'Tmsa017'
						oMdl017:SetValue("TMSA017_DDQ", "DDQ_STATUS", cStatus )						
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		oMdl := FwModelActive()
		If oMdl <> Nil .And. oMdl:CID = 'OMSA040'
			lRet	:= oMdl:GetModel( "MdGridDEL" ):SetValue( 'DEL_STATUS', cStatus )
		Endif
	EndIf

	//Refresh do campo DEL_STATUS durante a consulta do cartão do Motorista em tela após validações Pamcard
	oView 	:= FwViewActive()
	If ValType(oView) == "O"
		oView:Refresh()
	Endif

ElseIf cCodOpe == '03' .AND. lPagBem //-- PagBem
	
	cUrlToken	:= DEG->DEG_URLWS
	cUser		:= DEG->DEG_USER
	cPassword	:= DEG->DEG_SENHA

	// Verificar a situação do Cartão e atualiza os campos DDQ_STATUS ou DEL_STATUS
	oObj := TMSBCAPagBem():New()
	oObj:Auth()

	aStatus := oObj:GetCardSituation( cIdOpe ) // { lAtivo , cStatus, cMensagem }
	
	If Len( aStatus ) > 0
		oMdl := FwModelActive()
		
		If oMdl <> Nil .And. oMdl:CID = 'OMSA040'
			If Empty( aStatus[3] )
				lRet	:= oMdl:GetModel( "MdGridDEL" ):SetValue( 'DEL_STATUS', aStatus[2] )
			Else
				Aviso( STR0032, DecodeUTF8(aStatus[3]), {"Ok"} )// STR0032 "Atenção!"
			EndIf
		EndIf

	EndIf
EndIf

If !Empty(aMsgErr)
	AaddMsgErr( aMsgErr, aVisErr )
	TmsMsgErr( aVisErr )
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMS040AtOp ³ Autor ³ Vitor Raspa          ³ Data ³ 07.Jul.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza os dados do Motorista no cadastro da Operadora    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ OMS040AtOp()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function OMS040AtOp()
Local aCodigos   := {}
Local nOpcao     := 0
Local oDlg
Private cCodOpe  := CriaVar('DEG->DEG_CODOPE',.F.)
Private cNomOpe  := CriaVar('DEG->DEG_NOMOPE',.F.)

DEFINE MSDIALOG oDlg FROM 00,00 TO 090,350 PIXEL TITLE STR0018 //-- 'Atualiza Dados na Operadora'

	@ 011,005 SAY Posicione( 'SX3', 2, 'DEG_CODOPE', 'X3_TITULO' ) SIZE 100,15 COLOR CLR_HBLUE PIXEL

	@ 010,045 MSGET cCodOpe  F3 "DEG" PICTURE  PesqPict("DEG","DEG_CODOPE") SIZE 6,9  ;
				VALID TMSValField(,.T.,'DEG_NOMOPE') .And. TMSValField(,.F.,'cNomOpe') PIXEL
	@ 010,070 MSGET cNomOpe WHEN .F. SIZE 100,9 PIXEL

	DEFINE SBUTTON FROM 30,115 TYPE 1 OF oDlg ENABLE ACTION (nOpcao := 1,oDlg:End())
	DEFINE SBUTTON FROM 30,145 TYPE 2 OF oDlg ENABLE ACTION (nOpcao := 0,oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED

If nOpcao == 1
	If DA4->DA4_TIPMOT <> '1'
		AAdd( aCodigos, { DA4->( DA4_FORNEC + DA4_LOJA ), DA4->DA4_COD,'','','' } )
	Else
		AAdd( aCodigos, { 'SM0',DA4->DA4_COD,'','',''} )
	EndIf

	CursorWait()
	MsgRun( STR0015,; //-- "Atualizando dados junto a Operadora"
			STR0014,; //-- "Aguarde..."
			{ || TMSAtualOp( cCodOpe, Iif(lRestRepom,'2','5'), aCodigos, .T., DA4->DA4_CGC ) } )
			
	CursorArrow()
EndIf

Return 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OMS040Fil ºAutor  ³VICCO               º Data ³  28/04/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna Filial base para o cadastro de Funcionarios         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Omsa040 (SIGATMS)                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function OMS040Fil()
Local cFilBas := ""
If Empty(M->DA4_FILBAS)
	cFilBas := xFilial("SRA")
Else
	cFilBas := M->DA4_FILBAS
EndIf

Return( cFilBas )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OMS040MAT ºAutor  ³VICCO               º Data ³  28/04/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Consulta padrao para o cadastro de Motoristas               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Omsa040 (SIGATMS)                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function OMS040MAT()
Local cFiltro1  := '"'+OMS040Fil()+'"'
Local cFiltro2  := '"'+OMS040Fil()+'"'
Local cCadastro := "Funcionarios"
Local aRotOld   := aClone(aRotina)
Local aCampos   := {"RA_MAT","RA_NOME"}

Private nOpcSel := 0

aRotina := {}
AAdd( aRotina, { "&Confirmar","TMSConfSel",0,2,,,.T.} )
MaWndBrowse(0,0,300,600,cCadastro,"SRA",aCampos,aRotina,,cFiltro1,cFiltro2,.T.)

aRotina := aClone(aRotOld)

Return( nOpcSel == 1 )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OMS040HLOkºAutor  ³Andre Godoi         º Data ³  26/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tudo OK da Tela de Historico de transferencia              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function OMS040HLOk()
Local lRet      := .T.
Local aCpoCheck := {'DD9_DATATE'}
Local aCpoNoEmp := {'DD9_FILBASE','DD9_SRTMOT'}

//-- Analisa se ha itens duplicados na GetDados.
If !GDDeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
	lRet := GDCheckKey(aCpoCheck,4,aCpoNoEmp)
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OMS040HTOkºAutor  ³Andre Godoi         º Data ³  26/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tudo OK da Tela de Historico de transferencia              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function OMS040HTOk()

Local lRet := .T.

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OS040GrH     ³ Autor ³ Andre Godoi       ³ Data ³26.08.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravacao de historico do motorista, quando alterar a filial³±±
±±³          ³de rateio ou tipo de servico.                               ³±±
±±³ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ OS040GrH(ExpN1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1: Opcao selecionada                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function OS040GrH(nOpc)

Local aArea   := GetArea()
Local nAux    := 0
Local nAux2   := 0
Local lStrMot := DA4->(FieldPos("DA4_SRTMOT")) > 0 .AND. AliasInDic("DD9")

//-- Historico do Custos
If IntTms() .And. lStrMot .And. Len(aColsDD9) > 0
	If nOpc == 5
		DD9->(DbSetOrder(1))
		While DD9->(MsSeek(xFilial('DD9') + DA4->DA4_COD))
			RecLock('DD9', .F.)
			DbDelete()
			MsUnLock()
		EndDo
	Else
		For nAux := 1 To Len( aColsDD9 )
			If !Empty(aColsDD9[nAux, aScan(aHeaderDD9, {|x| AllTrim(x[2]) == 'DD9_ITEM'} )])
				DD9->(DbSetOrder(1))
				If	!aColsDD9[nAux,Len(aHeaderDD9)+1]
					If	DD9->( MsSeek( xFilial('DD9') + M->DA4_COD + aColsDD9[nAux, aScan(aHeaderDD9, {|x| AllTrim(x[2]) == 'DD9_ITEM'} )] ))
						RecLock('DD9', .F.)
					Else
						RecLock('DD9', .T.)
						DD9->DD9_FILIAL := xFilial('DD9')
						DD9->DD9_CODMOT := M->DA4_COD
					EndIf
					For nAux2 := 1 To Len(aHeaderDD9)
						If	aHeaderDD9[nAux2,10] != 'V'
							DD9->(FieldPut(FieldPos(aHeaderDD9[nAux2,2]), aColsDD9[nAux,nAux2]))
						EndIf
					Next
				Else
					If DD9->( MsSeek( xFilial('DD9') + M->DA4_COD + aColsDD9[nAux, aScan(aHeaderDD9, {|x| AllTrim(x[2]) == 'DD9_ITEM'} )]))
						RecLock('DD9',.F.)
						DbDelete()
					EndIf
				EndIf
				MsUnLock()
			EndIf
		Next
	EndIf
	aHeaderDD9 := {}
	aColsDD9   := {}
EndIf

RestArea( aArea )

Return( .T. )

//-----------------------------------------------------
/*/	Integra a tabela DA4(Protheus) com GUU(SIGAGFE) a cada registro novo
@author Felipe Machado de Oliveira
@version P11
@since 18/04/2013
/*/
//------------------------------------------------------
Static Function InterGUU(nOperation,lCommit)
Local aAreaGU3   := GU3->( GetArea() )
Local aAreaGUU   := GUU->( GetArea() )
Local lRet       :=  .T.
Local oModelGUU  := FWLoadModel("GFEA012")
Local nTpOpSetad := 0
Local cSit       := ""
Local cMsg       := ""
Local cPropri    := ""

	GUU->( dbSetOrder(1) )
	If GUU->( dbSeek( xFilial("GUU")+M->DA4_COD ) )
		oModelGUU:SetOperation( MODEL_OPERATION_UPDATE )
		nTpOpSetad := MODEL_OPERATION_UPDATE
	Else
		oModelGUU:SetOperation( MODEL_OPERATION_INSERT )
		nTpOpSetad := MODEL_OPERATION_INSERT
	EndIf

	oModelGUU:Activate()

	If nOperation <> MODEL_OPERATION_DELETE
		oModelGUU:SetValue( 'GFEA012_GUU', 'GUU_NMMTR' , M->DA4_NOME   )
		oModelGUU:SetValue( 'GFEA012_GUU', 'GUU_PSEUD' , M->DA4_NREDUZ )
		oModelGUU:SetValue( 'GFEA012_GUU', 'GUU_IDFED' , M->DA4_CGC    )
		oModelGUU:SetValue( 'GFEA012_GUU', 'GUU_RG'    , M->DA4_RG     )
		oModelGUU:SetValue( 'GFEA012_GUU', 'GUU_ORGEXP', M->DA4_RGORG  )
		oModelGUU:SetValue( 'GFEA012_GUU', 'GUU_NUMCNH', M->DA4_NUMCNH )
		oModelGUU:SetValue( 'GFEA012_GUU', 'GUU_REGCNH', M->DA4_REGCNH )
		oModelGUU:SetValue( 'GFEA012_GUU', 'GUU_DTECNH', M->DA4_DTECNH )
		oModelGUU:SetValue( 'GFEA012_GUU', 'GUU_DTVCNH', M->DA4_DTVCNH )
		oModelGUU:SetValue( 'GFEA012_GUU', 'GUU_MUNCNH', M->DA4_MUNCNH )
		oModelGUU:SetValue( 'GFEA012_GUU', 'GUU_ESTCNH', M->DA4_ESTCNH )
		oModelGUU:SetValue( 'GFEA012_GUU', 'GUU_CATCNH', M->DA4_CATCNH )
		oModelGUU:SetValue( 'GFEA012_GUU', 'GUU_MOPP'  , M->DA4_CARPER )
		oModelGUU:SetValue( 'GFEA012_GUU', 'GUU_BITMAP', M->DA4_BITMAP )

		GU3->( dbSetOrder(11) )
		If GU3->( dbSeek( xFilial("GU3")+M->DA4_CGCFOR  ) )
			cPropri :=	GU3->GU3_CDEMIT
		EndIf
		oModelGUU:LoadValue( 'GFEA012_GUU', 'GUU_CDTRP' , cPropri )

		If M->DA4_BLQMOT == "1"
			cSit := "3" //"3=Ent Proib"
		Else
			cSit := "1" //"1=Ativo"
		EndIf

		oModelGUU:LoadValue( 'GFEA012_GUU', 'GUU_SIT', cSit )

		If nTpOpSetad == MODEL_OPERATION_INSERT
			oModelGUU:SetValue( 'GFEA012_GUU', 'GUU_FILIAL', xFilial("DA4") )
			oModelGUU:SetValue( 'GFEA012_GUU', 'GUU_CDMTR' , M->DA4_COD )
		EndIf
	Else
		If nTpOpSetad <> MODEL_OPERATION_INSERT
			oModelGUU:LoadValue( 'GFEA012_GUU', 'GUU_SIT', "2" )
		EndIf
	EndIf

	If nOperation != MODEL_OPERATION_DELETE .Or. nTpOpSetad != MODEL_OPERATION_INSERT
		If oModelGUU:VldData()
			If lCommit
				oModelGUU:CommitData()
			EndIf
		Else
			lRet := .F.
			cMsg := STR0028+CRLF+CRLF+oModelGUU:GetErrorMessage()[6]//"Inconsistência com o Frete Embarcador (SIGAGFE)"##
		EndIf
	EndIf

	oModelGUU:Deactivate()

	If !lRet
		Help(,,STR0002,,cMsg,1,0) //"Atenção"
	EndIf

RestArea( aAreaGUU )
RestArea( aAreaGU3 )
Return lRet

/*/{Protheus.doc} A040AtuMat
Atualiza campo DA4_FILBASE

@author caio.y
@since 31/08/2018
@return return, Código único do funcionário
@param cFilDe, characters, Filial De
@param cMatDe, characters, Matricula De
@param cFilDe, characters, Filial Ate
@param cFilDe, characters, Matricula Ate

@example
/*/
Function A040AtuMat(cFilDe,cMatDe,cFilAte,cMatAte)
Local aArea			:= GetArea()
Local cQuery		:= ""
Local cAliasQry		:= GetNextAlias()

Default cFilDe		:= ""
Default cMatDe		:= ""
Default cFilAte		:= ""
Default cMatAte		:= ""

cQuery	:= " SELECT R_E_C_N_O_ DA4RECNO "
cQuery	+= " FROM " + RetSQLName("DA4") + " DA4 "
cQuery	+= " WHERE DA4_FILIAL 	= '" + xFilial("DA4") + "' "
cQuery	+= " AND DA4_FILBAS 	= '" + cFilDe + "' "
cQuery	+= " AND DA4_MAT		= '" + cMatDe + "' "
cQuery	+= " AND DA4.D_E_L_E_T_ =  ' ' "

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)

While (cAliasQry)->(!Eof())

	//-- Atualiza matricula do motorista
	DA4->( dbGoTo( (cAliasQry)->DA4RECNO ))
	RecLock("DA4",.F.)
	DA4->DA4_FILBAS		:= cFilAte
	DA4->DA4_MAT		:= cMatAte
	MsUnlock()

	(cAliasQry)->( dbSkip() )
EndDo

(cAliasQry)->(dbCloseArea())

RestArea(aArea)

Return

/*{Protheus.doc} OMSA040IDE
Exibe para escolha Motorista/Executores do Coleta/Entrega ou checklist
@author Carlos A. Gomes Jr.
@since 26/05/22
*/
Function OMSA040IDE()
Local lRet    := .F.
Local cCodFon := ""
Local aExec		As Array
Local oDlg		As Object
Local oListBox	As Object

If AliasInDic("DN7")
	cCodFon := FwFldGet("DN7_CODFON")
	If !Empty(cCodFon)
		aExec := OMSA040Ext(cCodFon)
		If Len(aExec) > 0
			DEFINE MSDIALOG oDlg TITLE STR0033 FROM 180, 180 TO 530, 910 PIXEL
				@ 005, 005 LISTBOX oListBox FIELDS HEADER STR0034, STR0035 SIZE 360, 150 OF oDlg PIXEL
				oListBox:SetArray( aExec )
				oListBox:bLine := { | | { 	aExec[oListBox:nAt][1], aExec[oListBox:nAt][2] } }
				DEFINE SButton FROM 160, 300 TYPE 1 ENABLE OF oDlg ACTION ( lRet := .T., Var_IXB := aExec[oListBox:nAt][2], oDlg:End() )
				DEFINE SButton FROM 160, 335 TYPE 2 ENABLE Of oDlg ACTION oDlg:End()
			ACTIVATE MSDIALOG oDlg CENTERED
		EndIf
	EndIf

	FwFreeObj(oListBox)
	FwFreeObj(oDlg)
	FwFreeArray(aExec)
EndIf

Return lRet

/*{Protheus.doc} OMSA040Ext
Busca Motorista/Executores no Coleta/Entrega ou checklist
@author Carlos A. Gomes Jr.
@since 26/05/22
*/
Static Function OMSA040Ext(cCodFon)

Local nCount    := 0
Local aRet      := {}
Local cAlias    := ""
Local aAlias    := {"DLZ","DN1"}
Local nN        := 0
Local lHasNext  := .T.
Local lOkColEnt := .F.
Local nPage     := 1
Local oColEnt As Object
Local oResult As Object
    
    For nN := 1 To Len(aAlias)
        If AliasInDic(aAlias[nN])
            oColEnt := TMSBCACOLENT():New(aAlias[nN])
            If oColEnt:DbGetToken() .And. !Empty(oColEnt:filext) .And. oColEnt:codfon == cCodFon
                cAlias := aAlias[nN]
                Exit
            EndIf
            FWFreeObj(oColEnt)
        EndIf
    Next

    If !Empty(cAlias)
        Do While lHasNext
			lHasNext  := .F.
			lOkColEnt := .F.
			Do Case
			Case cAlias == "DLZ"
				lOkColEnt := ( aResGet := oColEnt:Get( "checklist/query/api/v2/executors/", "?page=" + cValtoChar(nPage) + "&branchId=" + oColEnt:filext ) )[1]
			Case cAlias == "DN1"
				lOkColEnt := ( aResGet := oColEnt:Get( "coletaentrega/query/api/v1/motoristas/", "?page=" + cValtoChar(nPage) ) )[1]
			EndCase
			If lOkColEnt
                If FWJsonDeserialize( aResGet[2], @oResult )
                    If ( lHasNext := AttIsMemberOf( oResult, "hasNext" ) )
                        lHasNext := oResult:hasNext
                        nPage++
                    EndIf
                    If AttIsMemberOf( oResult, "items" )
                        For nCount := 1 To Len( oResult:items )
							Do Case
							Case cAlias == "DLZ"
								AAdd( aRet, { DeCodeUTF8( oResult:items[nCount]:fullName ), oResult:items[nCount]:id } )
							Case cAlias == "DN1"
								AAdd( aRet, { DeCodeUTF8( oResult:items[nCount]:nome ), oResult:items[nCount]:id } )
							EndCase
                        Next 
                    EndIf
                EndIf
            Else
                Help(" ", , "TMSAI8501-" + oColEnt:last_error, , oColEnt:desc_error, 2, 1)
                Exit
            EndIf
        EndDo

        If !Empty(aRet)
            ASort(aRet,,,{|x,y| x[1] < y[1]})
        EndIf

    EndIf

    FwFreeObj(oResult)
    FwFreeObj(oColEnt)

Return aRet

