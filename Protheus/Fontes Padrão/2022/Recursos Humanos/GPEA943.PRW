#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GPEA943.CH'

Static lCpoCCT	:= NIL

/*/{Protheus.doc} GPEA943
Cadastro de de Convenção Coletiva de Trabalho
@author Leandro Drumond
@since 21/03/2022
@Type     Function
/*/
Function GPEA943()
Local aCoors  		:= FWGetDialogSize( oMainWnd )
Local cIdBrowse
Local cIdGrid
Local oDlgPrinc
Local oTela
Local oPanelUp
Local oPanelDown
Local oBrowseSWY
Local oBrowseRCE
Local oRelacRCE
Local cFiltraRh
Local lChkSWY		:= ChkFile("SWY")

If !lChkSWY
	MsgInfo(STR0034)//"Para utilizar essa rotina é necessário atualização do dicionário de dados com o pacote da 'Convenção Coletiva de Trabalho', consulte a documentação no TDN"
	Return Nil
EndIf

DEFINE MsDialog oDlgPrinc Title OemToAnsi(STR0001) From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] OF oMainWnd Pixel  //"Convenção Coletiva de Trabalho"

	// Cria o conteiner onde serão colocados os paineis
	oTela     := FWFormContainer():New( oDlgPrinc )
	cIdBrowse := oTela:CreateHorizontalBox( 50 )
	cIdGrid   := oTela:CreateHorizontalBox( 50 )

	oTela:Activate( oDlgPrinc, .F. )

	//Cria os paineis onde serao colocados os browses
	oPanelUp  	:= oTela:GeTPanel( cIdBrowse )
	oPanelDown  := oTela:GeTPanel( cIdGrid )

	oBrowseSWY 	:= FWMBrowse():New()
	oBrowseSWY:SetOwner( oPanelUp )

	oBrowseSWY:SetAlias("SWY")
	oBrowseSWY:SetDescription(OemToAnsi(STR0001)) //"Convenção Coletiva de Trabalho"
	oBrowseSWY:DisableDetails()
	oBrowseSWY:ForceQuitButton()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFiltraRh := CHKRH("GPEA943","SWY","1")
	oBrowseSWY:SetFilterDefault( cFiltraRh )

	oBrowseSWY:Activate()

	//FWmBrowse Inferior: Sindicatos associados
	oBrowseRCE	:= FWMBrowse():New()
	oBrowseRCE:SetOwner( oPanelDown )

	oBrowseRCE:SetDescription( OemToAnsi(STR0007) )	//"Sindicatos associados"
	oBrowseRCE:DisableDetails()
	oBrowseRCE:SetAlias( 'RCE' )
	oBrowseRCE:SetCacheView(.F.)
	oBrowseRCE:SetSeek(.F.)
	oBrowseRCE:ExecuteFilter(.F.)
	oBrowseRCE:SetUseFilter(.F.)
	oBrowseRCE:SetMenuDef('')

	// Relacionamento entre os Paineis
	oRelacRCE:= FWBrwRelation():New()
	oRelacRCE:AddRelation( oBrowseSWY  , oBrowseRCE , { { 'xFilial("SWY",RCE->RCE_FILIAL)', 'WY_FILIAL' },{ 'RCE->RCE_CCT', 'SWY->WY_CODIGO' } } )

	oRelacRCE:Activate()

	oBrowseRCE:Activate()

	oBrowseSWY:Refresh()
	oBrowseRCE:Refresh()

ACTIVATE MsDialog oDlgPrinc Center

Return

/*/{Protheus.doc} ModelDef
Definição e detalhamento do Model
@author Leandro Drumond
@since 21/03/2022
@Type     Function
/*/
Static Function ModelDef()

Local oModel
Local oStructSWY
Local oStructRCE
Local oStructSYY
Local oStructRI4
Local oStructREB
Local oStructSP4
Local oStructREI
Local bCommit		:= { |oMdl| Gpea943Grv( oMdl ) }
Local bValid		:= { |oMdl| Gpea943Vld( oMdl ) }
Local lTecXRH		:= SuperGetMV("MV_TECXRH",,.F.)

lCpoCCT := (lTecXRH .And. If(lCpoCCT == NIL, SP4->(ColumnPos("P4_CODCCT") > 0), lCpoCCT))

// Criacao do Objeto de Modelagem de dados da tabela RCE //
oModel	:= MPFormModel():New("GPEA943", NIL, bValid , bCommit )

oModel:SetDescription( OemToAnsi(STR0001) ) //"Convenção Coletiva de Trabalho"

// Estrutura de campos do Model //
oStructSWY := FWFormStruct(1, "SWY") // Convenção coletiva
oStructSYY := FWFormStruct(1 ,"SYY") // Histórico CCT 
oStructRCE := FWFormStruct(1, "RCE") // Sindicatos

oStructRCE:AddField( 	" "			       , ;              // [01] Titulo do campo "Periodo"
						""       		   , ;              // [02] ToolTip do campo
						"RCE_OK"	       , ;              // [03] Id do Field
						"L"           	   , ;              // [04] Tipo do campo
						1		           , ;              // [05] Tamanho do campo
						0         		   , ;              // [06] Decimal do campo
						{|oMdl| fVldMark_Ok(oMdl, 1) } , ;  // [07] Code-block de validação do campo
						{|oMdl| fWhenOK(oMdl, 1) } , ;   	// [08] Code-block de validação When do campo
										   , ;              // [09] Lista de valores permitido do campo
						.F.                , ;              // [10] Indica se o campo tem preenchimento obrigatório
						{|| .T.}		   , ;              // [11] Code-block de inicializacao do campo
						NIL                , ;              // [12] Indica se trata-se de um campo chave
						Nil                , ;              // [13] Indica se o campo não pode receber valor em uma operação de update.
						.T.)          		           		// [14] Indica se o campo é virtual	

oStructRI4 := FWFormStruct(1 ,"RI4")

oStructRI4:AddField( 	" "			       , ;              // [01] Titulo do campo "Periodo"
						""        		   , ;              // [02] ToolTip do campo
						"RI4_OK"	       , ;              // [03] Id do Field
						"L"           	   , ;              // [04] Tipo do campo
						1		           , ;              // [05] Tamanho do campo
						0         		   , ;              // [06] Decimal do campo
						{|oMdl| fVldMark_Ok(oMdl, 2) } , ;  // [07] Code-block de validação do campo
						{|oMdl| fWhenOK(oMdl, 2) } , ;      // [08] Code-block de validação When do campo
										   , ;              // [09] Lista de valores permitido do campo
						.F.                , ;              // [10] Indica se o campo tem preenchimento obrigatório
						{|| .T.}		   , ;              // [11] Code-block de inicializacao do campo
						NIL                , ;              // [12] Indica se trata-se de um campo chave
						Nil                , ;              // [13] Indica se o campo não pode receber valor em uma operação de update.
						.T.)          		           		// [14] Indica se o campo é virtual	

oStructRI4:AddField( 	STR0013			   , ;           	// [01] Titulo do campo "Descrição"
						STR0021			   , ;	            // [02] ToolTip do campo
						"RI4_DESC"	       , ;              // [03] Id do Field
						"C"           	   , ;              // [04] Tipo do campo
						20		           , ;              // [05] Tamanho do campo
						0         		   , ;              // [06] Decimal do campo
						 				   , ;  			// [07] Code-block de validação do campo
										   , ;      		// [08] Code-block de validação When do campo
										   , ;              // [09] Lista de valores permitido do campo
						.F.                , ;              // [10] Indica se o campo tem preenchimento obrigatório
						{|| FDesc("SRJ", RI4->RI4_CODSRJ, "RJ_DESC", NIL, RI4->RI4_FILSRJ)}		   , ;              // [11] Code-block de inicializacao do campo
						NIL                , ;              // [12] Indica se trata-se de um campo chave
						Nil                , ;              // [13] Indica se o campo não pode receber valor em uma operação de update.
						.T.)          		           		// [14] Indica se o campo é virtual	

oStructREB := FWFormStruct(1 ,"REB")

oStructREB:AddField( 	" "			       , ;              // [01] Titulo do campo "Periodo"
						""        		   , ;              // [02] ToolTip do campo
						"REB_OK"	       , ;              // [03] Id do Field
						"L"           	   , ;              // [04] Tipo do campo
						1		           , ;              // [05] Tamanho do campo
						0         		   , ;              // [06] Decimal do campo
						{|oMdl| fVldMark_Ok(oMdl, 3) } , ;  // [07] Code-block de validação do campo
						{|oMdl| fWhenOK(oMdl, 3) } , ;      // [08] Code-block de validação When do campo
										   , ;              // [09] Lista de valores permitido do campo
						.F.                , ;              // [10] Indica se o campo tem preenchimento obrigatório
						{|| .T.}		   , ;              // [11] Code-block de inicializacao do campo
						NIL                , ;              // [12] Indica se trata-se de um campo chave
						Nil                , ;              // [13] Indica se o campo não pode receber valor em uma operação de update.
						.T.)          		           		// [14] Indica se o campo é virtual	

If lCpoCCT
	oStructSP4 := FWFormStruct(1, "SP4") // Tipos de Hora extra
	oStructSP4:SetProperty( "P4_TIPO", 		MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID, "fTipoExtra(M->P4_TIPO)"))
	oStructSP4:SetProperty( "P4_DE", 		MODEL_FIELD_OBRIGAT, .T.)
	oStructSP4:SetProperty( "P4_ATE", 		MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID, ""))
	oStructSP4:SetProperty( "P4_ATE",		MODEL_FIELD_OBRIGAT, .T.)
	oStructSP4:SetProperty( "P4_PERCENT", 	MODEL_FIELD_OBRIGAT, .T.)
	oStructSP4:SetProperty( "P4_FILIAL", 	MODEL_FIELD_INIT, {|| xFilial("SP4", M->WY_FILIAL)})
	
	oStructSP4:AddField( 	" "			       , ;              // [01] Titulo do campo
							""        		   , ;              // [02] ToolTip do campo
							"P4_OK"	      	   , ;              // [03] Id do Field
							"L"           	   , ;              // [04] Tipo do campo
							1		           , ;              // [05] Tamanho do campo
							0         		   , ;              // [06] Decimal do campo
							NIL				   , ;  			// [07] Code-block de validação do campo
							NIL				   , ;		        // [08] Code-block de validação When do campo
							NIL				   , ;              // [09] Lista de valores permitido do campo
							.F.                , ;              // [10] Indica se o campo tem preenchimento obrigatório
							{|| .T.}		   , ;              // [11] Code-block de inicializacao do campo
							NIL                , ;              // [12] Indica se trata-se de um campo chave
							Nil                , ;              // [13] Indica se o campo não pode receber valor em uma operação de update.
							.T.)          		           		// [14] Indica se o campo é virtual	
EndIf

oStructREB:AddField( 	STR0013			   , ;           	// [01] Titulo do campo "Descrição"
						STR0021			   , ;	            // [02] ToolTip do campo
						"REB_DESC"	       , ;              // [03] Id do Field
						"C"           	   , ;              // [04] Tipo do campo
						20		           , ;              // [05] Tamanho do campo
						0         		   , ;              // [06] Decimal do campo
						 				   , ;  			// [07] Code-block de validação do campo
										   , ;      		// [08] Code-block de validação When do campo
										   , ;              // [09] Lista de valores permitido do campo
						.F.                , ;              // [10] Indica se o campo tem preenchimento obrigatório
						{|| FDesc("SRV", REB->REB_CODSRV, "RV_DESC", NIL, REB->REB_FILSRV)}		   , ;              // [11] Code-block de inicializacao do campo
						NIL                , ;              // [12] Indica se trata-se de um campo chave
						Nil                , ;              // [13] Indica se o campo não pode receber valor em uma operação de update.
						.T.)          		           		// [14] Indica se o campo é virtual	

oStructREI := FWFormStruct(1 ,"REI")

oStructREI:AddField( 	" "			       , ;              // [01] Titulo do campo "Periodo"
						""        		   , ;              // [02] ToolTip do campo
						"REI_OK"	       , ;              // [03] Id do Field
						"L"           	   , ;              // [04] Tipo do campo
						1		           , ;              // [05] Tamanho do campo
						0         		   , ;              // [06] Decimal do campo
						{|oMdl| fVldMark_Ok(oMdl, 4) } , ;  // [07] Code-block de validação do campo
						{|oMdl| fWhenOK(oMdl, 4) } , ;      // [08] Code-block de validação When do campo
										   , ;              // [09] Lista de valores permitido do campo
						.F.                , ;              // [10] Indica se o campo tem preenchimento obrigatório
						{|| .T.}		   , ;              // [11] Code-block de inicializacao do campo
						NIL                , ;              // [12] Indica se trata-se de um campo chave
						Nil                , ;              // [13] Indica se o campo não pode receber valor em uma operação de update.
						.T.)          		           		// [14] Indica se o campo é virtual	

oStructREI:AddField( 	STR0013			   , ;           	// [01] Titulo do campo "Descrição"
						STR0021			   , ;	            // [02] ToolTip do campo
						"REI_DESC"	       , ;              // [03] Id do Field
						"C"           	   , ;              // [04] Tipo do campo
						20		           , ;              // [05] Tamanho do campo
						0         		   , ;              // [06] Decimal do campo
						 				   , ;  			// [07] Code-block de validação do campo
										   , ;      		// [08] Code-block de validação When do campo
										   , ;              // [09] Lista de valores permitido do campo
						.F.                , ;              // [10] Indica se o campo tem preenchimento obrigatório
						{|| FDesc("AA0", REI->REI_CODAA0, "AA0_DESCRI", NIL, REI->REI_FILAA0)}		   , ;              // [11] Code-block de inicializacao do campo
						NIL                , ;              // [12] Indica se trata-se de um campo chave
						Nil                , ;              // [13] Indica se o campo não pode receber valor em uma operação de update.
						.T.)          		           		// [14] Indica se o campo é virtual	

oStructRCE:SetProperty( 'RCE_DESCRI', MODEL_FIELD_WHEN, {|| .F. } )
oStructRCE:SetProperty( 'RCE_CODIGO', MODEL_FIELD_WHEN, {|| .F. } )

oModel:AddFields("GPEA943_SWY", NIL, oStructSWY)

oModel:SetPrimaryKey({"WY_CODIGO"})

oModel:GetModel( "GPEA943_SWY" ):SetDescription( OemToAnsi(STR0001) )  //"Convenção Coletiva de Trabalho"

oModel:AddGrid("GPEA943_RCE", "GPEA943_SWY"/*cOwner*/, oStructRCE , /*bLinePre*/, /* bLinePost*/, /*bPre*/,  /*bPost*/,/*bLoad*/)
oModel:GetModel( "GPEA943_RCE" ):SetOptional(.T.)
oModel:GetModel( "GPEA943_RCE" ):SetNoInsertLine(.T.)
oModel:GetModel( "GPEA943_RCE" ):SetNoDeleteLine(.T.)
oModel:GetModel( "GPEA943_RCE" ):SetOnlyQuery( .T. )

If xFilial("RCE") == xFilial("SWY")
	oModel:SetRelation("GPEA943_RCE",{{'RCE_FILIAL',"WY_FILIAL"},{"RCE_CCT","WY_CODIGO"}},RCE->(IndexKey()))
Else
	oModel:SetRelation("GPEA943_RCE",{{"RCE_CCT","WY_CODIGO"}},RCE->(IndexKey()))
EndIf

oModel:AddGrid("GPEA943_RI4", "GPEA943_SWY"/*cOwner*/, oStructRI4 , /*bLinePre*/, /* bLinePost*/, /*bPre*/,  /*bPost*/,/*bLoad*/)
oModel:GetModel( "GPEA943_RI4" ):SetOptional(.T.)
oModel:GetModel( "GPEA943_RI4" ):SetNoInsertLine(.T.)
oModel:GetModel( "GPEA943_RI4" ):SetNoDeleteLine(.T.)

oModel:SetRelation("GPEA943_RI4",{{"RI4_FILCCT","WY_FILIAL"},{"RI4_CODCCT","WY_CODIGO"}},RI4->(IndexKey()))

oModel:AddGrid("GPEA943_REB", "GPEA943_SWY"/*cOwner*/, oStructREB , /*bLinePre*/, /* bLinePost*/, /*bPre*/,  /*bPost*/,/*bLoad*/)
oModel:GetModel( "GPEA943_REB" ):SetOptional(.T.)
oModel:GetModel( "GPEA943_REB" ):SetMaxLine(500)
oModel:GetModel( "GPEA943_REB" ):SetNoInsertLine(.T.)
oModel:GetModel( "GPEA943_REB" ):SetNoDeleteLine(.T.)

oModel:SetRelation("GPEA943_REB",{{"REB_FILCCT","WY_FILIAL"},{"REB_CODCCT","WY_CODIGO"}},REB->(IndexKey()))

oModel:AddGrid("GPEA943_REI", "GPEA943_SWY"/*cOwner*/, oStructREI , /*bLinePre*/, /* bLinePost*/, /*bPre*/,  /*bPost*/,/*bLoad*/)
oModel:GetModel( "GPEA943_REI" ):SetOptional(.T.)
oModel:GetModel( "GPEA943_REI" ):SetMaxLine(500)
oModel:GetModel( "GPEA943_REI" ):SetNoInsertLine(.T.)
oModel:GetModel( "GPEA943_REI" ):SetNoDeleteLine(.T.)

oModel:SetRelation("GPEA943_REI",{{"REI_FILCCT","WY_FILIAL"},{"REI_CODCCT","WY_CODIGO"}},REI->(IndexKey()))

oModel:AddGrid("GPEA943_SYY", "GPEA943_SWY"/*cOwner*/, oStructSYY , /*bLinePre*/, /* bLinePost*/, /*bPre*/,  /*bPost*/,/*{|oGrid| CargaSR8(oGrid) }bLoad*/)
oModel:GetModel("GPEA943_SYY"):SetOptional(.T.)
oModel:SetRelation("GPEA943_SYY",{{"YY_FILIAL",'WY_FILIAL'},{"YY_CODIGO","WY_CODIGO"}},SYY->(IndexKey()))

// Tipos de HE 
If lCpoCCT
	oModel:AddGrid("GPEA943_SP4", "GPEA943_SWY", oStructSP4, {|oGrid, nLine, cAction| GPEDelOk(oGrid, nLine, cAction)}, {|oGrid, nLine| fSP4Ok(oGrid, nLine)}, /*bPre*/, /*bPost*/, /*bLoad*/)
	oModel:GetModel( "GPEA943_SP4" ):SetOptional(.T.)
	oModel:GetModel( "GPEA943_SP4" ):SetDescription( STR0041 ) // "Tipos de Horas Extras"
	oModel:GetModel( "GPEA943_SP4" ):SetUniqueLine({"P4_TIPO", "P4_DE"})
	oModel:SetRelation("GPEA943_SP4", { {"P4_FILCCT", "WY_FILIAL"}, {"P4_CODCCT", "WY_CODIGO"}}, SP4->(IndexKey()))
EndIf

Return( oModel )

/*/{Protheus.doc} ViewDef
Definição da viewdef
@author Leandro Drumond
@since 22/03/2022
@Type     Function
/*/
Static Function ViewDef()
Local oView
Local oModel
Local oStructSWY
Local oStructRCE
Local oStructRI4
Local oStructREB
Local oStructREI
Local oStructSP4
Local lTecXRH		:= SuperGetMV("MV_TECXRH",,.F.)

lCpoCCT := (lTecXRH .And. If(lCpoCCT == NIL, SP4->(ColumnPos("P4_CODCCT") > 0), lCpoCCT))

// Criacao da Interface //
oView := FWFormView():New()

// Vincular o View ao Model //
oModel := FWLoadModel("GPEA943")
oStructSWY := FWFormStruct(2, "SWY")
oStructRCE := FWFormStruct(2, "RCE")

RemoveFields(@oStructRCE)

oStructRCE:AddField( 	"RCE_OK"              	, ;              // [01] Campo
						"01"  					, ;              // [02] Ordem
						" "                		, ;              // [03] Titulo
						"Ok"                	, ;              // [04] Descricao
						NIL              		, ;              // [05] Help
						"L"                		, ;              // [06] Tipo do campo   COMBO, Get ou CHECK
								                , ;              // [07] Picture
												, ;              // [08] PictVar
												, ;              // [09] F3
						.T.  		            , ;              // [10] Editavel
												, ;              // [11] Folder
						""                		, ;              // [12] Group
												, ;              // [13] Lista Combo
												, ;              // [14] Tam Max Combo
												, ;              // [15] Inic. Browse
						.T.)                                     // [16] Virtual


oStructRI4 := FWFormStruct(2, "RI4")
oStructRI4:RemoveField("RI4_CODCCT")
oStructRI4:RemoveField("RI4_FILCCT")

oStructRI4:AddField( 	"RI4_OK"              	, ;              // [01] Campo
						"01"  					, ;              // [02] Ordem
						" "                		, ;              // [03] Titulo
						"Ok"                	, ;              // [04] Descricao
						NIL              		, ;              // [05] Help
						"L"                		, ;              // [06] Tipo do campo   COMBO, Get ou CHECK
								                , ;              // [07] Picture
												, ;              // [08] PictVar
												, ;              // [09] F3
						.T.  		            , ;              // [10] Editavel
												, ;              // [11] Folder
						""                		, ;              // [12] Group
												, ;              // [13] Lista Combo
												, ;              // [14] Tam Max Combo
												, ;              // [15] Inic. Browse
						.T.)                                     // [16] Virtual

oStructRI4:AddField( 	"RI4_DESC"             	, ;              // [01] Campo
						"10"  					, ;              // [02] Ordem
						STR0013        			, ;              // [03] Titulo
						STR0013            		, ;              // [04] Descricao
						NIL              		, ;              // [05] Help
						"C"                		, ;              // [06] Tipo do campo   COMBO, Get ou CHECK
								                , ;              // [07] Picture
												, ;              // [08] PictVar
												, ;              // [09] F3
						.F.  		            , ;              // [10] Editavel
												, ;              // [11] Folder
						""                		, ;              // [12] Group
												, ;              // [13] Lista Combo
												, ;              // [14] Tam Max Combo
												, ;              // [15] Inic. Browse
						.T.)                                     // [16] Virtual 

oStructREB := FWFormStruct(2, "REB")
oStructREB:RemoveField("REB_CODCCT")
oStructREB:RemoveField("REB_FILCCT")

oStructREB:AddField( 	"REB_OK"              	, ;              // [01] Campo
						"01"  					, ;              // [02] Ordem
						" "                		, ;              // [03] Titulo
						"Ok"                	, ;              // [04] Descricao
						NIL              		, ;              // [05] Help
						"L"                		, ;              // [06] Tipo do campo   COMBO, Get ou CHECK
								                , ;              // [07] Picture
												, ;              // [08] PictVar
												, ;              // [09] F3
						.T.  		            , ;              // [10] Editavel
												, ;              // [11] Folder
						""                		, ;              // [12] Group
												, ;              // [13] Lista Combo
												, ;              // [14] Tam Max Combo
												, ;              // [15] Inic. Browse
						.T.)                                     // [16] Virtual

oStructREB:AddField( 	"REB_DESC"             	, ;              // [01] Campo
						"10"  					, ;              // [02] Ordem
						STR0013        			, ;              // [03] Titulo
						STR0013            		, ;              // [04] Descricao
						NIL              		, ;              // [05] Help
						"C"                		, ;              // [06] Tipo do campo   COMBO, Get ou CHECK
								                , ;              // [07] Picture
												, ;              // [08] PictVar
												, ;              // [09] F3
						.F.  		            , ;              // [10] Editavel
												, ;              // [11] Folder
						""                		, ;              // [12] Group
												, ;              // [13] Lista Combo
												, ;              // [14] Tam Max Combo
												, ;              // [15] Inic. Browse
						.T.)   

oStructREI := FWFormStruct(2, "REI")
oStructREI:RemoveField("REI_CODCCT")
oStructREI:RemoveField("REI_FILCCT")

oStructREI:AddField( 	"REI_OK"              	, ;              // [01] Campo
						"01"  					, ;              // [02] Ordem
						" "                		, ;              // [03] Titulo
						"Ok"                	, ;              // [04] Descricao
						NIL              		, ;              // [05] Help
						"L"                		, ;              // [06] Tipo do campo   COMBO, Get ou CHECK
								                , ;              // [07] Picture
												, ;              // [08] PictVar
												, ;              // [09] F3
						.T.  		            , ;              // [10] Editavel
												, ;              // [11] Folder
						""                		, ;              // [12] Group
												, ;              // [13] Lista Combo
												, ;              // [14] Tam Max Combo
												, ;              // [15] Inic. Browse
						.T.)                                     // [16] Virtual

oStructREI:AddField( 	"REI_DESC"             	, ;              // [01] Campo
						"10"  					, ;              // [02] Ordem
						STR0013        			, ;              // [03] Titulo
						STR0013            		, ;              // [04] Descricao
						NIL              		, ;              // [05] Help
						"C"                		, ;              // [06] Tipo do campo   COMBO, Get ou CHECK
								                , ;              // [07] Picture
												, ;              // [08] PictVar
												, ;              // [09] F3
						.F.  		            , ;              // [10] Editavel
												, ;              // [11] Folder
						""                		, ;              // [12] Group
												, ;              // [13] Lista Combo
												, ;              // [14] Tam Max Combo
												, ;              // [15] Inic. Browse
						.T.)   

// Tipos de Hora Extra
If lCpoCCT
	oStructSP4 := FWFormStruct(2, "SP4")
	oStructSP4:RemoveField("P4_CODCCT")
	oStructSP4:RemoveField("P4_FILCCT")
	oStructSP4:RemoveField("P4_TURNO")
	oStructSP4:SetProperty( 'P4_CODNAUT', MVC_VIEW_PICT, "@!" )
	oStructSP4:SetProperty( 'P4_CODAUT', MVC_VIEW_PICT, "@!" )
EndIf

oView:SetModel(oModel)
oView:AddField("GPEA943_SWY", oStructSWY)

oView:CreateHorizontalBox("FIELDS", 60)

oView:CreateHorizontalBox("BOTTOM", 40)

oView:CreateFolder('PASTAS','BOTTOM')

oView:AddSheet( 'PASTAS', 'ABA01', STR0022) // Sindicatos
oView:AddSheet( 'PASTAS', 'ABA02', STR0023) // Funções
oView:AddSheet( 'PASTAS', 'ABA03', STR0026) // Verbas

If lTecXRH
	oView:AddSheet( 'PASTAS', 'ABA04', STR0035) // Base Operacional
EndIf

If lCpoCCT
	oView:AddSheet( 'PASTAS', 'ABA05', STR0042 ) // Hora Extra
EndIf

// Cria um "box" horizontal para receber cada elemento da view			
oView:CreateHorizontalBox( 'ABAS1'  , 100,,, 'PASTAS', 'ABA01' )	//Sindicatos
oView:CreateHorizontalBox( 'ABAS2' ,  100,,, 'PASTAS', 'ABA02' )	//Funções
oView:CreateHorizontalBox( 'ABAS3' ,  100,,, 'PASTAS', 'ABA03' )	//Verbas

If lTecXRH
	oView:CreateHorizontalBox( 'ABAS4' ,  100,,, 'PASTAS', 'ABA04' )	//Base Operacional
EndIf

If lCpoCCT
	oView:CreateHorizontalBox( 'ABAS5' ,  100,,, 'PASTAS', 'ABA05' )	//Hora Extra
EndIf

oView:AddGrid('GPEA943_RCE' , oStructRCE)
oView:AddGrid('GPEA943_RI4' , oStructRI4)
oView:AddGrid('GPEA943_REB' , oStructREB)

If lTecXRH
	oView:AddGrid('GPEA943_REI' , oStructREI)
EndIf

If lCpoCCT
	oView:AddGrid('GPEA943_SP4' , oStructSP4)
EndIf

oView:addUserButton( STR0008 + " (F6)"	,"MAGIC_BMP", {|oModel| MsAguarde( { || LoadSindicato(oModel) } , OemtoAnsi(STR0030)) }	,STR0008,VK_F6	, {MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE} ) //"Associar sindicatos"
oView:addUserButton( STR0024 + " (F7)"	,"MAGIC_BMP", {|oModel| MsAguarde( { || LoadFuncoes(oModel) } , OemtoAnsi(STR0029)) }	,STR0024,VK_F7	, {MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE} ) //"Associar funções"
oView:addUserButton( STR0027 + " (F8)"	,"MAGIC_BMP", {|oModel| MsAguarde( { || LoadVerbas(oModel) } , OemtoAnsi(STR0028)) }	,STR0027,VK_F8	, {MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE} ) //"Associar verbas"
If lTecXRH
	oView:addUserButton( STR0036 + " (F9)"	,"MAGIC_BMP", {|oModel| MsAguarde( { || LoadBases(oModel) } , OemtoAnsi(STR0037)) }		,STR0036,VK_F9	, {MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE} ) //"Associar base operacional"
EndIf

If lCpoCCT
	//"Associar Tipos de Hora Extra" -- "Carregando Tipos de Hora Extra"
	oView:addUserButton( STR0043 + " (F10)", "MAGIC_BMP", {|oModel| MsAguarde( { || LoadHE(oModel) }, STR0044)}, STR0043, VK_F10, {MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE} )
EndIf

oView:addUserButton( STR0009			,"MAGIC_BMP", {|| ViewHistorico() }				,STR0009,		, {MODEL_OPERATION_UPDATE,MODEL_OPERATION_VIEW} )   //"Histórico"

oView:SetOwnerView("GPEA943_SWY", "FIELDS")
oView:SetOwnerView("GPEA943_RCE", "ABAS1")
oView:SetOwnerView("GPEA943_RI4", "ABAS2")
oView:SetOwnerView("GPEA943_REB", "ABAS3")
If lTecXRH
	oView:SetOwnerView("GPEA943_REI", "ABAS4")
EndIf

If lCpoCCT
	oView:SetOwnerView("GPEA943_SP4", "ABAS5")
EndIf

Return oView

/*/{Protheus.doc} ViewHistorico
Visualiza o histórico de alterações da CCT
@author Leandro Drumond
@since 29/03/2022
@Type     Function
/*/
Static Function ViewHistorico()

Local oView			:= Nil
Local oStructSYY 	:= Nil
Local oModel		:= FwLoadModel("GPEA943")

oView := FWFormView():New()

oStructSYY := FWFormStruct(2,"SYY")

oStructSYY:RemoveField("YY_FILIAL")
oStructSYY:RemoveField("YY_CODIGO")

oModel:SetRelation("GPEA943_SYY",{{"YY_FILIAL",'WY_FILIAL'},{"YY_CODIGO","WY_CODIGO"}},SYY->(IndexKey()))

oView:SetModel(oModel)

oView:AddGrid("GPEA943_SYY", oStructSYY)

oView:CreateHorizontalBox("SYY", 100)

oView:SetOwnerView("GPEA943_SYY", "SYY")

oFWMVCWindow := FWMVCWindow():New()
oFWMVCWindow:SetUseControlBar(.T.)
oFWMVCWindow:SetView(oView)
oFWMVCWindow:SetCentered(.T.)
oFWMVCWindow:SetPos(0,0)
oFWMVCWindow:SetSize(380,700)
oFWMVCWindow:SetTitle(STR0010)//'Histórico CCT'
oFWMVCWindow:Activate()

Return Nil

/*/{Protheus.doc} fWhenOK
Habilita o campo para seleção apenas se as colunas estiver preenchidas.
@author Leandro Drumond
@since 28/03/2022
@Type     Function
/*/
Static Function fWhenOK(oGrid, nTipo)
Local lRet 			:= .T.

If nTipo == 1
	If Empty(oGrid:GetValue("RCE_CODIGO"))
		lRet := .F.
	EndIf
ElseIf nTipo == 2
	If Empty(oGrid:GetValue("RI4_CODSRJ"))
		lRet := .F.
	EndIf
ElseIf nTipo == 3
	If Empty(oGrid:GetValue("REB_CODSRV"))
		lRet := .F.
	EndIf	
ElseIf nTipo == 4
	If Empty(oGrid:GetValue("REI_CODAA0"))
		lRet := .F.
	EndIf	
EndIf

Return lRet

/*/{Protheus.doc} LoadSindicato
Seleciona os sindicatos que serão associados a CCT
@author Leandro Drumond
@since 28/03/2022
@Type     Function
/*/
Static Function LoadSindicato(oModel)
Local aArea 		:= GetArea()
Local aStru  		:= {}
Local aLstIndices	:= {}
Local aColumns		:= {}
Local aPesq			:= {}
Local oGrid			:= oModel:GetModel("GPEA943_RCE")
Local cSindicatos   := ""
Local cIdGrid		:= ""
Local nTam          := oGrid:Length()
Local nX 			:= 0
Local nOpcX			:= 0
Local oSize
Local oTela
Local oDlgGrid
Local oPanel
Local oMark
Local oFont
Local oGroup
Local lInclui

Private cAliasTRB

For nX := 1 to nTam
	oGrid:GoLine(nX)
	If oGrid:GetValue("RCE_OK")
		cSindicatos += oGrid:GetValue("RCE_FILIAL") + oGrid:GetValue("RCE_CODIGO") + "#"
	EndIf
Next nX

Static cAliasTmp
Static oArqTmp

If oArqTmp == Nil //Monta temporária com filiais disponíveis
	Aadd(aStru, {"OK"		, "C", 2						, 0})
	Aadd(aStru, {"FILIAL"	, "C", FwGetTamFilial			, 0})
	Aadd(aStru, {"CODIGO"  	, "C", 2						, 0})
	Aadd(aStru, {"NOME"  	, "C", 40						, 0})
	AAdd(aLstIndices, {"FILIAL","CODIGO"})
	AAdd(aLstIndices, {"NOME"})

	cAliasTmp := cAliasTRB := GetNextAlias()

	oArqTmp := RhCriaTrab(cAliasTRB, aStru, aLstIndices)

	DbSelectArea("RCE")
	DbSetOrder(1)

	RCE->(DbGoTop())

	While RCE->(!Eof())
		RecLock(cAliasTRB, .T.)
		(cAliasTRB)->FILIAL	:= RCE->RCE_FILIAL
		(cAliasTRB)->CODIGO	:= RCE->RCE_CODIGO
		(cAliasTRB)->NOME	:= RCE->RCE_DESCRI
		(cAliasTRB)->(MsUnlock())
		RCE->(DbSkip())
	EndDo
Else 
	cAliasTRB := cAliasTmp
EndIf

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->FILIAL}") )
aColumns[Len(aColumns)]:SetTitle(STR0011) //"Filial"
aColumns[Len(aColumns)]:SetSize(FwGetTamFilial)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->CODIGO}") )
aColumns[Len(aColumns)]:SetTitle(STR0012) //"Código"
aColumns[Len(aColumns)]:SetSize(2)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->NOME}") )
aColumns[Len(aColumns)]:SetTitle(STR0013) //"Descrição"
aColumns[Len(aColumns)]:SetSize(40)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

Aadd( aPesq , {	STR0012, { { "CODIGO"   , "C", 02 , 0, "CODIGO", "@!"}}, 1})
Aadd( aPesq , {	STR0013, { { "NOME   "  , "C", 40 , 0, "NOME"  , "@!"}}, 1})

oSize := FwDefSize():New(.F.)

oSize:AddObject( "CABECALHO",(oSize:aWindSize[3]*1.1),(oSize:aWindSize[3]*0.4) , .F., .F. ) // Não dimensionavel
oSize:aMargins 	:= { 0, 0, 0, 0 } 		// Espaco ao lado dos objetos 0, entre eles 3
oSize:lProp 		:= .F. 				// Proporcional
oSize:Process() 	   					// Dispara os calculos

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

DEFINE MSDIALOG oDlgGrid TITLE OemToAnsi( STR0014 ) From 0,0 TO 600,1230 OF oMainWnd PIXEL //"Selecione os sindicatos que serão associados"

// Cria o conteiner onde serão colocados os paineis
oTela		:= FWFormContainer():New( oDlgGrid )
cIdGrid  	:= oTela:CreateHorizontalBox( 80 )

oTela:Activate( oDlgGrid, .F. )

//Cria os paineis onde serao colocados os browses
oPanel	:= oTela:GeTPanel( cIdGrid )

@ oSize:GetDimension("CABECALHO","LININI")+1 , oSize:GetDimension("CABECALHO","COLINI")+4	GROUP oGroup TO oSize:GetDimension("CABECALHO","LINEND") * 0.090 ,oSize:GetDimension("CABECALHO","COLEND") * 0.431  OF oDlgGrid PIXEL
oGroup:oFont:=oFont
@ oSize:GetDimension("CABECALHO","LININI")+9 , oSize:GetDimension("CABECALHO","COLINI")+6 SAY "" Of oDlgGrid Pixel

oMark := FWMarkBrowse():New()

oMark:SetOwner(oPanel)
oMark:SetAlias(cAliasTRB)
oMark:SetTemporary(.T.)
oMark:SetColumns(aColumns)
oMark:SetFieldMark('OK')
oMark:SetFilterDefault( "" )
oMark:SetIgnoreARotina(.T.)
oMark:SetMenuDef('')
oMark:SetSeek( .T., aPesq )

oMark:bAllMark := { || SetMarkAll(oMark:Mark(), lMarcar := !lMarcar, cAliasTRB ), oMark:Refresh(.T.)  }

oMark:Activate()

SetMarkAll(oMark:Mark(),.F.,cAliasTRB,cSindicatos) //Desmarca todos os registros

oMark:Refresh(.T.)

ACTIVATE MSDIALOG oDlgGrid CENTERED ON INIT EnchoiceBar(oDlgGrid, {||nOpcX := 1, oDlgGrid:End() } ,{|| oDlgGrid:End() }, NIL, {})

If nOpcX == 1

	//Adiciona filiais selecionadas
	(cAliasTRB)->(dbGoTop())

	lInclui := !Empty(cSindicatos)

	If lInclui
		For nX := 1 to nTam //Desmarca todos os sindicatos
			oGrid:GoLine(nX)
			oGrid:LoadValue("RCE_OK",.F.)
		Next nX
	Else 
		oGrid:GoLine(1)
	EndIf

	While (cAliasTRB)->(!EOF())
		If !Empty((cAliasTRB)->OK)
			
			If lInclui
				If !oGrid:SeekLine({{"RCE_FILIAL",(cAliasTRB)->FILIAL},{"RCE_CODIGO",(cAliasTRB)->CODIGO}})
					oGrid:AddLine(.T.) //Se não encontrar, adiciona uma linha
				EndIf
			EndIf

			oGrid:LoadValue("RCE_FILIAL"	,(cAliasTRB)->FILIAL)
			oGrid:LoadValue("RCE_CODIGO"	,(cAliasTRB)->CODIGO)
			oGrid:LoadValue("RCE_DESCRI"    ,(cAliasTRB)->NOME)
			oGrid:LoadValue("RCE_OK"		,.T.)

			lInclui := .T.
		EndIf
		(cAliasTRB)->(dbSkip())
	EndDo

	oGrid:GoLine(1)
EndIf

RestArea(aArea)

Return Nil

/*/{Protheus.doc} LoadFuncoes
Seleciona as funções que serão associadas a CCT
@author Leandro Drumond
@since 04/04/2022
@Type     Function
/*/
Static Function LoadFuncoes(oModel)
Local aArea 		:= GetArea()
Local aStru  		:= {}
Local aLstIndices	:= {}
Local aColumns		:= {}
Local aPesq			:= {}
Local oGrid			:= oModel:GetModel("GPEA943_RI4")
Local cFuncoes   	:= ""
Local cIdGrid		:= ""
Local cFilRI4		:= xFilial("RI4", SWY->WY_FILIAL)
Local nTam          := oGrid:Length()
Local nX 			:= 0
Local nOpcX			:= 0
Local oSize
Local oTela
Local oDlgGrid
Local oPanel
Local oMark
Local oFont
Local oGroup
Local lInclui

Private cAliasTRB

For nX := 1 to nTam
	oGrid:GoLine(nX)
	If oGrid:GetValue("RI4_OK")
		cFuncoes += oGrid:GetValue("RI4_FILSRJ") + oGrid:GetValue("RI4_CODSRJ") + "#"
	EndIf
Next nX

Static cAliasRI4
Static oArqRI4

If oArqRI4 == Nil //Monta temporária com filiais disponíveis
	Aadd(aStru, {"OK"		, "C", 2						, 0})
	Aadd(aStru, {"FILIAL"	, "C", FwGetTamFilial			, 0})
	Aadd(aStru, {"CODIGO"  	, "C", 5						, 0})
	Aadd(aStru, {"NOME"  	, "C", 20						, 0})
	AAdd(aLstIndices, {"FILIAL","CODIGO"})
	AAdd(aLstIndices, {"NOME"})

	cAliasRI4 := cAliasTRB := GetNextAlias()

	oArqRI4 := RhCriaTrab(cAliasTRB, aStru, aLstIndices)

	DbSelectArea("SRJ")
	DbSetOrder(1)

	SRJ->(DbGoTop())

	While SRJ->(!Eof())
		RecLock(cAliasTRB, .T.)
		(cAliasTRB)->FILIAL	:= SRJ->RJ_FILIAL
		(cAliasTRB)->CODIGO	:= SRJ->RJ_FUNCAO
		(cAliasTRB)->NOME	:= SRJ->RJ_DESC
		(cAliasTRB)->(MsUnlock())
		SRJ->(DbSkip())
	EndDo
Else 
	cAliasTRB := cAliasRI4
EndIf

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->FILIAL}") )
aColumns[Len(aColumns)]:SetTitle(STR0011) //"Filial"
aColumns[Len(aColumns)]:SetSize(FwGetTamFilial)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->CODIGO}") )
aColumns[Len(aColumns)]:SetTitle(STR0012) //"Código"
aColumns[Len(aColumns)]:SetSize(5)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->NOME}") )
aColumns[Len(aColumns)]:SetTitle(STR0013) //"Descrição"
aColumns[Len(aColumns)]:SetSize(20)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

Aadd( aPesq , {	STR0012, { { "CODIGO"   , "C", 05 , 0, "CODIGO", "@!"}}, 1})
Aadd( aPesq , {	STR0013, { { "NOME   "  , "C", 20 , 0, "NOME"  , "@!"}}, 1})

oSize := FwDefSize():New(.F.)

oSize:AddObject( "CABECALHO",(oSize:aWindSize[3]*1.1),(oSize:aWindSize[3]*0.4) , .F., .F. ) // Não dimensionavel
oSize:aMargins 	:= { 0, 0, 0, 0 } 		// Espaco ao lado dos objetos 0, entre eles 3
oSize:lProp 		:= .F. 				// Proporcional
oSize:Process() 	   					// Dispara os calculos

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

DEFINE MSDIALOG oDlgGrid TITLE OemToAnsi( STR0031 ) From 0,0 TO 600,1230 OF oMainWnd PIXEL //"Selecione as funções que serão associadas"

// Cria o conteiner onde serão colocados os paineis
oTela		:= FWFormContainer():New( oDlgGrid )
cIdGrid  	:= oTela:CreateHorizontalBox( 80 )

oTela:Activate( oDlgGrid, .F. )

//Cria os paineis onde serao colocados os browses
oPanel	:= oTela:GeTPanel( cIdGrid )

@ oSize:GetDimension("CABECALHO","LININI")+1 , oSize:GetDimension("CABECALHO","COLINI")+4	GROUP oGroup TO oSize:GetDimension("CABECALHO","LINEND") * 0.090 ,oSize:GetDimension("CABECALHO","COLEND") * 0.431  OF oDlgGrid PIXEL
oGroup:oFont:=oFont
@ oSize:GetDimension("CABECALHO","LININI")+9 , oSize:GetDimension("CABECALHO","COLINI")+6 SAY "" Of oDlgGrid Pixel

oMark := FWMarkBrowse():New()

oMark:SetOwner(oPanel)
oMark:SetAlias(cAliasTRB)
oMark:SetTemporary(.T.)
oMark:SetColumns(aColumns)
oMark:SetFieldMark('OK')
oMark:SetFilterDefault( "" )
oMark:SetIgnoreARotina(.T.)
oMark:SetMenuDef('')
oMark:SetSeek( .T., aPesq )

oMark:bAllMark := { || SetMarkAll(oMark:Mark(), lMarcar := !lMarcar, cAliasTRB ), oMark:Refresh(.T.)  }

oMark:Activate()

SetMarkAll(oMark:Mark(),.F.,cAliasTRB,cFuncoes) //Desmarca todos os registros

oMark:Refresh(.T.)

ACTIVATE MSDIALOG oDlgGrid CENTERED ON INIT EnchoiceBar(oDlgGrid, {||nOpcX := 1, oDlgGrid:End() } ,{|| oDlgGrid:End() }, NIL, {})

If nOpcX == 1

	//Adiciona filiais selecionadas
	(cAliasTRB)->(dbGoTop())

	lInclui := !Empty(cFuncoes)

	If lInclui
		For nX := 1 to nTam //Desmarca todas as funções
			oGrid:GoLine(nX)
			oGrid:LoadValue("RI4_OK",.F.)
		Next nX
	Else 
		oGrid:GoLine(1)
	EndIf

	While (cAliasTRB)->(!EOF())
		If !Empty((cAliasTRB)->OK)
			
			If lInclui
				If !oGrid:SeekLine({{"RI4_FILSRJ",(cAliasTRB)->FILIAL},{"RI4_CODSRJ",(cAliasTRB)->CODIGO}})
					oGrid:AddLine(.T.) //Se não encontrar, adiciona uma linha
				EndIf
			EndIf

			oGrid:LoadValue("RI4_FILIAL"	,cFilRI4)
			oGrid:LoadValue("RI4_FILCCT"	,SWY->WY_FILIAL)
			oGrid:LoadValue("RI4_CODCCT"	,SWY->WY_CODIGO)
			oGrid:LoadValue("RI4_FILSRJ"	,(cAliasTRB)->FILIAL)
			oGrid:LoadValue("RI4_CODSRJ"	,(cAliasTRB)->CODIGO)
			oGrid:LoadValue("RI4_DESC"    	,(cAliasTRB)->NOME)
			oGrid:LoadValue("RI4_OK"		,.T.)

			lInclui := .T.
		EndIf
		(cAliasTRB)->(dbSkip())
	EndDo

	oGrid:GoLine(1)
EndIf

RestArea(aArea)

Return Nil

/*/{Protheus.doc} LoadVerbas
Seleciona as verbas que serão associadas a CCT
@author Leandro Drumond
@since 06/04/2022
@Type     Function
/*/
Static Function LoadVerbas(oModel)
Local aArea 		:= GetArea()
Local aStru  		:= {}
Local aLstIndices	:= {}
Local aColumns		:= {}
Local aPesq			:= {}
Local oGrid			:= oModel:GetModel("GPEA943_REB")
Local cVerbas   	:= ""
Local cIdGrid		:= ""
Local cFilREB		:= xFilial("REB", SWY->WY_FILIAL)
Local nTam          := oGrid:Length()
Local nX 			:= 0
Local nOpcX			:= 0
Local nQtd			:= 0
Local oSize
Local oTela
Local oDlgGrid
Local oPanel
Local oMark
Local oFont
Local oGroup
Local lInclui

Private cAliasTRB

For nX := 1 to nTam
	oGrid:GoLine(nX)
	If oGrid:GetValue("REB_OK")
		cVerbas += oGrid:GetValue("REB_FILSRV") + oGrid:GetValue("REB_CODSRV") + "#"
	EndIf
Next nX

Static cAliasREB
Static oArqREB

If oArqREB == Nil //Monta temporária com filiais disponíveis
	Aadd(aStru, {"OK"		, "C", 2						, 0})
	Aadd(aStru, {"FILIAL"	, "C", FwGetTamFilial			, 0})
	Aadd(aStru, {"CODIGO"  	, "C", 3						, 0})
	Aadd(aStru, {"NOME"  	, "C", 20						, 0})
	AAdd(aLstIndices, {"FILIAL","CODIGO"})
	AAdd(aLstIndices, {"NOME"})

	cAliasREB := cAliasTRB := GetNextAlias()

	oArqREB := RhCriaTrab(cAliasTRB, aStru, aLstIndices)

	DbSelectArea("SRV")
	DbSetOrder(1)

	SRV->(DbGoTop())

	While SRV->(!Eof())
		RecLock(cAliasTRB, .T.)
		(cAliasTRB)->FILIAL	:= SRV->RV_FILIAL
		(cAliasTRB)->CODIGO	:= SRV->RV_COD
		(cAliasTRB)->NOME	:= SRV->RV_DESC
		(cAliasTRB)->(MsUnlock())
		SRV->(DbSkip())
	EndDo
Else 
	cAliasTRB := cAliasREB
EndIf

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->FILIAL}") )
aColumns[Len(aColumns)]:SetTitle(STR0011) //"Filial"
aColumns[Len(aColumns)]:SetSize(FwGetTamFilial)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->CODIGO}") )
aColumns[Len(aColumns)]:SetTitle(STR0012) //"Código"
aColumns[Len(aColumns)]:SetSize(3)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->NOME}") )
aColumns[Len(aColumns)]:SetTitle(STR0013) //"Descrição"
aColumns[Len(aColumns)]:SetSize(20)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

Aadd( aPesq , {	STR0012, { { "CODIGO"   , "C", 03 , 0, "CODIGO", "@!"}}, 1})
Aadd( aPesq , {	STR0013, { { "NOME   "  , "C", 20 , 0, "NOME"  , "@!"}}, 1})

oSize := FwDefSize():New(.F.)

oSize:AddObject( "CABECALHO",(oSize:aWindSize[3]*1.1),(oSize:aWindSize[3]*0.4) , .F., .F. ) // Não dimensionavel
oSize:aMargins 	:= { 0, 0, 0, 0 } 		// Espaco ao lado dos objetos 0, entre eles 3
oSize:lProp 		:= .F. 				// Proporcional
oSize:Process() 	   					// Dispara os calculos

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

DEFINE MSDIALOG oDlgGrid TITLE OemToAnsi( STR0032 ) From 0,0 TO 600,1230 OF oMainWnd PIXEL //"Selecione as funções que serão associadas"

// Cria o conteiner onde serão colocados os paineis
oTela		:= FWFormContainer():New( oDlgGrid )
cIdGrid  	:= oTela:CreateHorizontalBox( 80 )

oTela:Activate( oDlgGrid, .F. )

//Cria os paineis onde serao colocados os browses
oPanel	:= oTela:GeTPanel( cIdGrid )

@ oSize:GetDimension("CABECALHO","LININI")+1 , oSize:GetDimension("CABECALHO","COLINI")+4	GROUP oGroup TO oSize:GetDimension("CABECALHO","LINEND") * 0.090 ,oSize:GetDimension("CABECALHO","COLEND") * 0.431  OF oDlgGrid PIXEL
oGroup:oFont:=oFont
@ oSize:GetDimension("CABECALHO","LININI")+9 , oSize:GetDimension("CABECALHO","COLINI")+6 SAY "" Of oDlgGrid Pixel

oMark := FWMarkBrowse():New()

oMark:SetOwner(oPanel)
oMark:SetAlias(cAliasTRB)
oMark:SetTemporary(.T.)
oMark:SetColumns(aColumns)
oMark:SetFieldMark('OK')
oMark:SetFilterDefault( "" )
oMark:SetIgnoreARotina(.T.)
oMark:SetMenuDef('')
oMark:SetSeek( .T., aPesq )

oMark:bAllMark := { || SetMarkAll(oMark:Mark(), lMarcar := !lMarcar, cAliasTRB ), oMark:Refresh(.T.)  }

oMark:Activate()

SetMarkAll(oMark:Mark(),.F.,cAliasTRB,cVerbas) //Desmarca todos os registros

oMark:Refresh(.T.)

ACTIVATE MSDIALOG oDlgGrid CENTERED ON INIT EnchoiceBar(oDlgGrid, {||nOpcX := 1, oDlgGrid:End() } ,{|| oDlgGrid:End() }, NIL, {})

If nOpcX == 1

	//Adiciona filiais selecionadas
	(cAliasTRB)->(dbGoTop())

	lInclui := !Empty(cVerbas)

	If lInclui
		For nX := 1 to nTam //Desmarca todas as funções
			oGrid:GoLine(nX)
			oGrid:LoadValue("REB_OK",.F.)
			nQtd++
		Next nX
	Else 
		oGrid:GoLine(1)
		nQtd++
	EndIf

	While (cAliasTRB)->(!EOF())
		If !Empty((cAliasTRB)->OK)
						
			If lInclui
				If !oGrid:SeekLine({{"REB_FILSRV",(cAliasTRB)->FILIAL},{"REB_CODSRV",(cAliasTRB)->CODIGO}})
					If ++nQtd > 500
						MsgInfo(STR0038) //"Número máximo de linhas para inclusão no GRID é de 500"
						Exit
					EndIf
					oGrid:AddLine(.T.) //Se não encontrar, adiciona uma linha
				EndIf
			EndIf

			oGrid:LoadValue("REB_FILIAL"	,cFilREB)
			oGrid:LoadValue("REB_FILCCT"	,SWY->WY_FILIAL)
			oGrid:LoadValue("REB_CODCCT"	,SWY->WY_CODIGO)
			oGrid:LoadValue("REB_FILSRV"	,(cAliasTRB)->FILIAL)
			oGrid:LoadValue("REB_CODSRV"	,(cAliasTRB)->CODIGO)
			oGrid:LoadValue("REB_DESC"    	,(cAliasTRB)->NOME)
			oGrid:LoadValue("REB_OK"		,.T.)

			lInclui := .T.
		EndIf
		(cAliasTRB)->(dbSkip())
	EndDo

	oGrid:GoLine(1)
EndIf

RestArea(aArea)

Return Nil

/*/{Protheus.doc} SetMarkAll
Marca/Desmarca os registros
@author Leandro Drumond
@since 28/03/2022
@version P12.1.33
@Type     Function
/*/
Static Function SetMarkAll(cMarca,lMarcar,cAliasTRB,cMarcados)

Local cAliasMark := cAliasTRB
Local aAreaMark  := (cAliasMark)->( GetArea() )

DEFAULT cMarca := ""

dbSelectArea(cAliasMark)
(cAliasMark)->( dbGoTop() )

While !(cAliasMark)->( Eof() )
	RecLock( (cAliasMark), .F. )
	If !Empty(cMarcados)
		If (cAliasMark)->FILIAL + (cAliasMark)->CODIGO $ cMarcados 
			(cAliasMark)->OK := cMarca
		Else 
			(cAliasMark)->OK := '  '
		EndIf
	Else
		(cAliasMark)->OK := IIf( lMarcar , cMarca, '  ' )
	EndIf
	MsUnLock()
	(cAliasMark)->( dbSkip() )
EndDo

RestArea(aAreaMark)

Return .T.

/*/{Protheus.doc} RemoveFields
Deixa apenas o código do sindicato e descrição no grid
@author Leandro Drumond
@since 28/03/2022
@Type     Function
/*/
Static Function RemoveFields(oStruct)
Local aAux 		:= aClone(oStruct:GetFields())
Local nX 		:= 0

For nX := 1 to Len(aAux)
	If !(aAux[nX, MVC_VIEW_IDFIELD ] $ "RCE_FILIAL*RCE_CODIGO*RCE_DESCRI")
		oStruct:RemoveField(aAux[nX, MVC_VIEW_IDFIELD ])
	EndIf
Next nX

Return Nil

/*/{Protheus.doc} Gpea943When
When dos campos de ATS e PLR
@author Leandro Drumond
@since 22/03/2022
@Type     Function
/*/
Function Gpea943When()
Local cVar 		:= ReadVar()
Local oModel    := FWModelActive()
Local lRet 		:= .F.

oModel  := oModel:GetModel("GPEA943_SWY")

If "WY_VLR" $ cVar //When dos campos Valor ATS
	If oModel:GetValue("WY_TPCATS") $ "2*3"
		lRet := .T.
	EndIf
ElseIf "WY_PER" $ cVar //When dos campos Percentual ATS
	If oModel:GetValue("WY_TPCATS") $ "1*2"
		lRet := .T.
	EndIf
ElseIf "WY_PLRVLR" $ cVar
	If oModel:GetValue("WY_PLRTPC") == "2"
		lRet := .T.
	EndIf
ElseIf "WY_PLRPER" $ cVar
	If oModel:GetValue("WY_PLRTPC") == "1"
		lRet := .T.
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} Gpea943Grv
Efetua gravação do modelo de dados
@author Leandro Drumond
@since 28/03/2022
@Type     Function
/*/
Static Function Gpea943Grv( oModel )
Local nOperation  := oModel:GetOperation()
Local oGrid
Local nTam
Local nX
Local lRet			:= .T.

Begin Transaction 

	If nOperation == 4 //--Alteracao - Grava historico dos campos alterados
		fGrvHist(oModel)
	EndIf
	If nOperation == 3 .or. nOperation == 4
		oGrid := oModel:GetModel("GPEA943_RI4")
		oModel:GetModel( "GPEA943_RI4" ):SetNoDeleteLine(.F.)
		nTam  := oGrid:Length()
		For nX := 1 to nTam
			oGrid:GoLine(nX)
			If !oGrid:GetValue("RI4_OK") .or. Empty(oGrid:GetValue("RI4_CODSRJ"))
				oGrid:DeleteLine() //Se a linha foi desmarcada, deixa
			EndIf
		Next nX
		oModel:GetModel( "GPEA943_RI4" ):SetNoDeleteLine(.T.)

		oGrid := oModel:GetModel("GPEA943_REB")
		oModel:GetModel( "GPEA943_REB" ):SetNoDeleteLine(.F.)
		nTam  := oGrid:Length()
		For nX := 1 to nTam
			oGrid:GoLine(nX)
			If !oGrid:GetValue("REB_OK") .or. Empty(oGrid:GetValue("REB_CODSRV"))
				oGrid:DeleteLine() //Se a linha foi desmarcada, deixa
			EndIf
		Next nX
		oModel:GetModel( "GPEA943_REB" ):SetNoDeleteLine(.T.)

		oGrid := oModel:GetModel("GPEA943_REI")
		oModel:GetModel( "GPEA943_REI" ):SetNoDeleteLine(.F.)
		nTam  := oGrid:Length()
		For nX := 1 to nTam
			oGrid:GoLine(nX)
			If !oGrid:GetValue("REI_OK") .or. Empty(oGrid:GetValue("REI_CODAA0"))
				oGrid:DeleteLine() //Se a linha foi desmarcada, deixa
			EndIf
		Next nX
		oModel:GetModel( "GPEA943_REI" ):SetNoDeleteLine(.T.)
	EndIf

	If FWFormCommit( oModel )

		If nOperation == 4 .or. nOperation == 3
			MsAguarde( { || lRet := fGrvSind(oModel) } , OemtoAnsi(STR0020)) //"Aguarde...associando sindicatos"
		EndIf

	EndIf

End Transaction

Return lRet

/*/{Protheus.doc} Gpea943Vld
Efetua validação do modelo de dados
@author Leandro Drumond
@since 29/03/2022
@Type     Function
/*/
Static Function Gpea943Vld( oModel )
Local nOperation  	:= oModel:GetOperation()
Local oGrid
Local lRet			:= .T.

If nOperation == 5 //--Exclusão
	oGrid := oModel:GetModel("GPEA943_RCE")
	If oGrid:Length() > 0
		oGrid:GoLine(1)
		If !Empty(oGrid:GetValue("RCE_CODIGO"))
			lRet := .F.
			Help(,, OemToAnsi(STR0015),, + CRLF + OemToAnsi(STR0016) , 1, 0,,,,,, { + CRLF + OemToAnsi(STR0017)})//"Atencao" ## "Esta CCT esta sendo utilizada nos sindicatos listados na grid." ### "Desassocie os sindicatos antes de excluir a CCT"
		EndIf 
	EndIf
EndIf

If nOperation == 4 .or. nOperation == 3
	lRet := fGrvSind( oModel, .F. )
EndIf

Return lRet

/*/{Protheus.doc} fGrvHist
Grava o histórico dos campos alterados
@author Leandro Drumond
@since 28/03/2022
@Type     Function
/*/
Static Function fGrvHist( oModel )
Local aArea		:= GetArea()
Local oMyMdl01	:= oModel:GetModel("GPEA943_SWY")
Local oStruct 	:= oMyMdl01:GetStruct()
Local aAux 		:= oStruct:GetFields()
Local cCCT		:= oMyMdl01:GetValue("WY_CODIGO")
Local cCampo	:= ""
Local cTipo		:= ""
Local cConteudo	:= ""
Local cFilSWY	:= xFilial("SWY")
Local nX		:= 0

DbSelectArea("SYY")
DbSetOrder(1)

For nX := 1 To Len(aAux)
	cCampo 		:= aAux[nX, MODEL_FIELD_IDFIELD ]
	cTipo  		:= aAux[nX, MODEL_FIELD_TIPO ]

	If cCampo <> "WY_FILIAL"
		If cTipo == "D"
			cConteudo  	:= DtoC(&("SWY->"+cCampo))
		Else
			cConteudo   := If(cTipo=="N",AllTrim(STR(&("SWY->"+cCampo))),&("SWY->"+cCampo))
		EndIf
		If cTipo $ "C*N*D" .and. oMyMdl01:GetValue(cCampo) <> &("SWY->"+cCampo)
			If SYY->(DbSeek(cFilSWY+cCCT+PadR(cCampo,10)+DtoS(dDataBase)))
				RecLock("SYY",.F.)
			Else
				RecLock("SYY",.T.)
			EndIf
			SYY->YY_FILIAL	:= cFilSWY
			SYY->YY_CODIGO	:= cCCT
			SYY->YY_CAMPO	:= cCampo
			SYY->YY_CONTEUD	:= cConteudo
			SYY->YY_DATA	:= dDataBase
			SYY->(MsUnLock())
		EndIf
	EndIf
Next nX

RestArea(aArea)

Return .T.

/*/{Protheus.doc} fGrvSind
Replica as informações para os sindicatos selecionados.
@author Leandro Drumond
@since 28/03/2022
@Type     Function
/*/
Static Function fGrvSind( oMdl, lGrava )
Local lRet 			:= .T.
Local cChave        := ""
Local cCampoSWY     := ""
Local cCampoRCE     := ""
Local nX 			:= 0
Local nY   			:= 0
Local oModel
Local oModelRCE
Local oGrid			:= oMdl:GetModel("GPEA943_RCE")
Local oModelSWY		:= oMdl:GetModel("GPEA943_SWY")
Local oStruct 		:= oModelSWY:GetStruct()
Local nTam          := oGrid:Length()
Local aAux 			:= oStruct:GetFields()
Local lExclui       := .F.

DEFAULT lGrava 		:= .T.

Begin Sequence
	For nX := 1 to nTam
		oGrid:GoLine(nX)

		If Empty(oGrid:GetValue("RCE_CODIGO"))
			Loop 
		EndIf

		lExclui := !oGrid:GetValue("RCE_OK")

		cChave := oGrid:GetValue("RCE_FILIAL") + oGrid:GetValue("RCE_CODIGO")
		RCE->(DbSeek(cChave))

		oModel		:= FWLoadModel( "GPEA340")
		oModelRCE	:= oModel:GetModel("GPEA340_RCE")
		oModel:SetOperation(4)

		If lGrava
			oModel:bPost := {|| .T.} //Não valida a gravação
		EndIf 

		oModel:Activate()

		If lExclui
			oModelRCE:LoadValue("RCE_CCT", "")
		Else 
			For nY := 1 to Len(aAux)
				cCampoSWY := aAux[nY, MODEL_FIELD_IDFIELD ]
				If cCampoSWY $ "WY_FILIAL*WY_CODIGO*WY_DESC"
					Loop 
				EndIf
				cCampoRCE := StrTran(cCampoSWY,"WY_","RCE_")
				oModelRCE:LoadValue(cCampoRCE, oModelSWY:GetValue(cCampoSWY))
			Next nY
			oModelRCE:LoadValue("RCE_CCT", oModelSWY:GetValue("WY_CODIGO"))
		EndIf 

		If ( lRet := oModel:VldData() )
			If !lGrava
				Break //Efetua apenas validação do modelo
			EndIf
			oModel:CommitData()
		Else
			Break
		EndIf

		oModel:DeActivate()

	Next nX

End Sequence

Return lRet

/*/{Protheus.doc} fVldMark_Ok
Confirma desassociação do sindicato da CCT
@author Leandro Drumond
@since 28/03/2022
@Type     Function
/*/
Static Function fVldMark_Ok(oModel, nTipo)
Local lGoto := If(nTipo == 1, M->RCE_OK, M->RI4_OK)

If !lGoTo 
	If nTipo == 1 .and. !MsgYesNo(STR0018 + CRLF + CRLF + STR0019) //"Desassociar sindicato desta CCT?" ### "Esta ação não replicará os demais campos alterados para o sindicato"
		oModel:LoadValue("RCE_OK", .T.) //Se não confirmar, volta valor para true
	EndIf
	If nTipo == 2 .and. !MsgYesNo(STR0025) //"Desassociar função desta CCT?"
		oModel:LoadValue("RI4_OK", .T.) //Se não confirmar, volta valor para true
	EndIf
	If nTipo == 3 .and. !MsgYesNo(STR0033) //"Desassociar verba desta CCT?"
		oModel:LoadValue("REB_OK", .T.) //Se não confirmar, volta valor para true
	EndIf
	If nTipo == 4 .and. !MsgYesNo(STR0039) //"Desassociar base desta CCT?"
		oModel:LoadValue("REI_OK", .T.) //Se não confirmar, volta valor para true
	EndIf
EndIf

Return .T.

/*/{Protheus.doc} LoadBases
Seleciona as bases operacionais que serão associadas a CCT
@author Leandro Drumond
@since 29/04/2022
@Type     Function
/*/
Static Function LoadBases(oModel)
Local aArea 		:= GetArea()
Local aStru  		:= {}
Local aLstIndices	:= {}
Local aColumns		:= {}
Local aPesq			:= {}
Local oGrid			:= oModel:GetModel("GPEA943_REI")
Local cBases	   	:= ""
Local cIdGrid		:= ""
Local cFilREI		:= xFilial("REI", SWY->WY_FILIAL)
Local nTam          := oGrid:Length()
Local nX 			:= 0
Local nOpcX			:= 0
Local nQtd			:= 0
Local oSize
Local oTela
Local oDlgGrid
Local oPanel
Local oMark
Local oFont
Local oGroup
Local lInclui

Private cAliasTRB

For nX := 1 to nTam
	oGrid:GoLine(nX)
	If oGrid:GetValue("REI_OK")
		cBases += oGrid:GetValue("REI_FILAA0") + oGrid:GetValue("REI_CODAA0") + "#"
	EndIf
Next nX

Static cAliasREI
Static oArqREI

If oArqREI == Nil //Monta temporária com filiais disponíveis
	Aadd(aStru, {"OK"		, "C", 2						, 0})
	Aadd(aStru, {"FILIAL"	, "C", FwGetTamFilial			, 0})
	Aadd(aStru, {"CODIGO"  	, "C", 6						, 0})
	Aadd(aStru, {"NOME"  	, "C", 20						, 0})
	AAdd(aLstIndices, {"FILIAL","CODIGO"})
	AAdd(aLstIndices, {"NOME"})

	cAliasREI := cAliasTRB := GetNextAlias()

	oArqREI := RhCriaTrab(cAliasTRB, aStru, aLstIndices)

	DbSelectArea("AA0")
	DbSetOrder(1)

	AA0->(DbGoTop())

	While AA0->(!Eof())
		RecLock(cAliasTRB, .T.)
		(cAliasTRB)->FILIAL	:= AA0->AA0_FILIAL
		(cAliasTRB)->CODIGO	:= AA0->AA0_CODIGO
		(cAliasTRB)->NOME	:= AA0->AA0_DESCRI
		(cAliasTRB)->(MsUnlock())
		AA0->(DbSkip())
	EndDo
Else 
	cAliasTRB := cAliasREI
EndIf

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->FILIAL}") )
aColumns[Len(aColumns)]:SetTitle(STR0011) //"Filial"
aColumns[Len(aColumns)]:SetSize(FwGetTamFilial)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->CODIGO}") )
aColumns[Len(aColumns)]:SetTitle(STR0012) //"Código"
aColumns[Len(aColumns)]:SetSize(6)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->NOME}") )
aColumns[Len(aColumns)]:SetTitle(STR0013) //"Descrição"
aColumns[Len(aColumns)]:SetSize(20)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

Aadd( aPesq , {	STR0012, { { "CODIGO"   , "C", 03 , 0, "CODIGO", "@!"}}, 1})
Aadd( aPesq , {	STR0013, { { "NOME   "  , "C", 20 , 0, "NOME"  , "@!"}}, 1})

oSize := FwDefSize():New(.F.)

oSize:AddObject( "CABECALHO",(oSize:aWindSize[3]*1.1),(oSize:aWindSize[3]*0.4) , .F., .F. ) // Não dimensionavel
oSize:aMargins 	:= { 0, 0, 0, 0 } 		// Espaco ao lado dos objetos 0, entre eles 3
oSize:lProp 		:= .F. 				// Proporcional
oSize:Process() 	   					// Dispara os calculos

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

DEFINE MSDIALOG oDlgGrid TITLE OemToAnsi( STR0040 ) From 0,0 TO 600,1230 OF oMainWnd PIXEL //"Selecione as bases operacionais que serão associadas"

// Cria o conteiner onde serão colocados os paineis
oTela		:= FWFormContainer():New( oDlgGrid )
cIdGrid  	:= oTela:CreateHorizontalBox( 80 )

oTela:Activate( oDlgGrid, .F. )

//Cria os paineis onde serao colocados os browses
oPanel	:= oTela:GeTPanel( cIdGrid )

@ oSize:GetDimension("CABECALHO","LININI")+1 , oSize:GetDimension("CABECALHO","COLINI")+4	GROUP oGroup TO oSize:GetDimension("CABECALHO","LINEND") * 0.090 ,oSize:GetDimension("CABECALHO","COLEND") * 0.431  OF oDlgGrid PIXEL
oGroup:oFont:=oFont
@ oSize:GetDimension("CABECALHO","LININI")+9 , oSize:GetDimension("CABECALHO","COLINI")+6 SAY "" Of oDlgGrid Pixel

oMark := FWMarkBrowse():New()

oMark:SetOwner(oPanel)
oMark:SetAlias(cAliasTRB)
oMark:SetTemporary(.T.)
oMark:SetColumns(aColumns)
oMark:SetFieldMark('OK')
oMark:SetFilterDefault( "" )
oMark:SetIgnoreARotina(.T.)
oMark:SetMenuDef('')
oMark:SetSeek( .T., aPesq )

oMark:bAllMark := { || SetMarkAll(oMark:Mark(), lMarcar := !lMarcar, cAliasTRB ), oMark:Refresh(.T.)  }

oMark:Activate()

SetMarkAll(oMark:Mark(),.F.,cAliasTRB,cBases) //Desmarca todos os registros

oMark:Refresh(.T.)

ACTIVATE MSDIALOG oDlgGrid CENTERED ON INIT EnchoiceBar(oDlgGrid, {||nOpcX := 1, oDlgGrid:End() } ,{|| oDlgGrid:End() }, NIL, {})

If nOpcX == 1

	//Adiciona filiais selecionadas
	(cAliasTRB)->(dbGoTop())

	lInclui := !Empty(cBases)

	If lInclui
		For nX := 1 to nTam //Desmarca todas as bases
			oGrid:GoLine(nX)
			oGrid:LoadValue("REI_OK",.F.)
			nQtd++
		Next nX
	Else 
		oGrid:GoLine(1)
		nQtd++
	EndIf

	While (cAliasTRB)->(!EOF())
		If !Empty((cAliasTRB)->OK)
						
			If lInclui
				If !oGrid:SeekLine({{"REI_FILAA0",(cAliasTRB)->FILIAL},{"REI_CODAA0",(cAliasTRB)->CODIGO}})
					If ++nQtd > 500
						MsgInfo(STR0038) //"Número máximo de linhas para inclusão no GRID é de 500"
						Exit
					EndIf
					oGrid:AddLine(.T.) //Se não encontrar, adiciona uma linha
				EndIf
			EndIf

			oGrid:LoadValue("REI_FILIAL"	,cFilREI)
			oGrid:LoadValue("REI_FILCCT"	,SWY->WY_FILIAL)
			oGrid:LoadValue("REI_CODCCT"	,SWY->WY_CODIGO)
			oGrid:LoadValue("REI_FILAA0"	,(cAliasTRB)->FILIAL)
			oGrid:LoadValue("REI_CODAA0"	,(cAliasTRB)->CODIGO)
			oGrid:LoadValue("REI_DESC"    	,(cAliasTRB)->NOME)
			oGrid:LoadValue("REI_OK"		,.T.)

			lInclui := .T.
		EndIf
		(cAliasTRB)->(dbSkip())
	EndDo

	oGrid:GoLine(1)
EndIf

RestArea(aArea)

Return Nil

/*/{Protheus.doc} MenuDef
Definição do MenuDef
@author Leandro Drumond
@since 21/03/2022
@Type     Function
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title OemToAnsi(STR0002)  Action 'PesqBrw'           OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title OemToAnsi(STR0003)  Action 'VIEWDEF.GPEA943'   OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title OemToAnsi(STR0004)  Action 'VIEWDEF.GPEA943'   OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina Title OemToAnsi(STR0005)  Action 'VIEWDEF.GPEA943'   OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title OemToAnsi(STR0006)  Action 'VIEWDEF.GPEA943'   OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

/*/{Protheus.doc} LoadHE
Seleciona Os tipos de Hora Extra para facilitar o cadastro na CCT
@author Cícero Alves
@since 22/07/2022
@Type Static Function
/*/
Static Function LoadHE(oModel)
	
	Local aArea 		:= GetArea()
	Local aStru  		:= {}
	Local aLstIndices	:= {}
	Local aColumns		:= {}
	Local aPesq			:= {}
	Local oGrid			:= oModel:GetModel("GPEA943_SP4")
	Local cTiposHE   	:= ""
	Local cIdGrid		:= ""
	Local cFilSP4		:= xFilial("SP4", SWY->WY_FILIAL)
	Local nTam          := oGrid:Length()
	Local nX 			:= 0
	Local nOpcX			:= 0
	Local nQtd			:= 0
	Local oSize
	Local oTela
	Local oDlgGrid
	Local oPanel
	Local oMark
	Local oFont
	Local oGroup
	Local lInclui
	
	Private cAliasTRB
	
	For nX := 1 to nTam
		oGrid:GoLine(nX)
		If oGrid:GetValue("P4_OK")
			cTiposHE += oGrid:GetValue("P4_FILIAL") + oGrid:GetValue("P4_TURNO") + oGrid:GetValue("P4_TIPO") + StrZero(oGrid:GetValue("P4_DE") * 100, 5) + "#"
		EndIf
	Next nX
	
	Static cAliasSP4
	Static oArqSP4
	
	If oArqSP4 == Nil // Monta tabela temporária
		
		Aadd(aStru, {"OK"		, "C", 2				, 0})
		Aadd(aStru, {"FILIAL"	, "C", FwGetTamFilial	, 0})
		Aadd(aStru, {"TURNO"  	, "C", 3				, 0})
		Aadd(aStru, {"TIPO"  	, "C", 1				, 0})
		Aadd(aStru, {"CODIGO"  	, "C", 9				, 0})
		Aadd(aStru, {"DE"  		, "N", 6				, 2})
		Aadd(aStru, {"ATE"  	, "N", 6				, 2})
		Aadd(aStru, {"PERC"  	, "N", 6				, 2})
		Aadd(aStru, {"CODNAUT"  , "C", 3				, 0})
		Aadd(aStru, {"CODAUT"  	, "C", 3				, 0})
		AAdd(aLstIndices, {"FILIAL", "TURNO", "TIPO"})
		AAdd(aLstIndices, {"FILIAL", "TIPO"})
		AAdd(aLstIndices, {"TIPO"})
		
		cAliasSP4 := cAliasTRB := GetNextAlias()
		
		oArqSP4 := RhCriaTrab(cAliasTRB, aStru, aLstIndices)
		
		DbSelectArea("SP4")
		DbSetOrder(1)
		SP4->(dbGoTop())
		
		While SP4->(!Eof())
			If Empty(SP4->P4_CODCCT)
				RecLock(cAliasTRB, .T.)
				(cAliasTRB)->FILIAL	:= SP4->P4_FILIAL
				(cAliasTRB)->TURNO	:= SP4->P4_TURNO
				(cAliasTRB)->TIPO	:= SP4->P4_TIPO
				(cAliasTRB)->CODIGO	:= SP4->(P4_TURNO + P4_TIPO + StrZero( P4_DE * 100, 5))
				(cAliasTRB)->DE		:= SP4->P4_DE
				(cAliasTRB)->ATE	:= SP4->P4_ATE
				(cAliasTRB)->PERC	:= SP4->P4_PERCENT
				(cAliasTRB)->CODNAUT:= SP4->P4_CODNAUT
				(cAliasTRB)->CODAUT	:= SP4->P4_CODAUT
				(cAliasTRB)->(MsUnlock())
			EndIf
			SP4->(DbSkip())
		EndDo
	Else 
		cAliasTRB := cAliasSP4
	EndIf
	
	AAdd(aColumns, FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetTitle(STR0011) //"Filial"
	aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->FILIAL}") )
	aColumns[Len(aColumns)]:SetSize(FwGetTamFilial)
	aColumns[Len(aColumns)]:SetDecimal(0)
	aColumns[Len(aColumns)]:SetPicture("@!")
	
	AAdd(aColumns, FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetTitle(STR0045) // "Tipo"
	aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->TIPO}") )
	aColumns[Len(aColumns)]:SetSize(1)
	aColumns[Len(aColumns)]:SetDecimal(0)
	aColumns[Len(aColumns)]:SetPicture("@!")
	aColumns[Len(aColumns)]:SetOptions(StrToKArr(PonRetOpcBox(4), ";"))
	
	AAdd(aColumns, FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetTitle(STR0046) // "Horas De"
	aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->DE}") )
	aColumns[Len(aColumns)]:SetSize(1)
	aColumns[Len(aColumns)]:SetDecimal(0)
	aColumns[Len(aColumns)]:SetPicture("@E 999.99")
	
	AAdd(aColumns, FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetTitle(STR0047) // "Horas Até"
	aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->ATE}") )
	aColumns[Len(aColumns)]:SetSize(1)
	aColumns[Len(aColumns)]:SetDecimal(0)
	aColumns[Len(aColumns)]:SetPicture("@E 999.99")
	
	AAdd(aColumns, FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetTitle(STR0048) // "% Adicional"
	aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->PERC}") )
	aColumns[Len(aColumns)]:SetSize(1)
	aColumns[Len(aColumns)]:SetDecimal(0)
	aColumns[Len(aColumns)]:SetPicture("@E 999.99")
	
	AAdd(aColumns, FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetTitle(STR0049) // "Evento não atorizado"
	aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->CODNAUT}") )
	aColumns[Len(aColumns)]:SetSize(1)
	aColumns[Len(aColumns)]:SetDecimal(0)
	aColumns[Len(aColumns)]:SetPicture("")
	
	AAdd(aColumns, FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetTitle(STR0050) // "Evento atorizado"
	aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->CODAUT}") )
	aColumns[Len(aColumns)]:SetSize(1)
	aColumns[Len(aColumns)]:SetDecimal(0)
	aColumns[Len(aColumns)]:SetPicture("")
	
	Aadd( aPesq , {	STR0045, { { "TIPO", "C", 1, 0, "TIPO", "@!"}}, 1})
	
	oSize := FwDefSize():New(.F.)
	
	oSize:AddObject( "CABECALHO", (oSize:aWindSize[3]*1.1), (oSize:aWindSize[3]*0.4) , .F., .F. ) // Não dimensionavel
	oSize:aMargins 	:= { 0, 0, 0, 0 } 		// Espaco ao lado dos objetos 0, entre eles 3
	oSize:lProp 		:= .F. 				// Proporcional
	oSize:Process() 	   					// Dispara os calculos
	
	DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
	
	DEFINE MSDIALOG oDlgGrid TITLE OemToAnsi( STR0051 ) From 0,0 TO 600,1230 OF oMainWnd PIXEL // "Selecione os tipos de Hora Extra"
	
	// Cria o conteiner onde serão colocados os paineis
	oTela		:= FWFormContainer():New( oDlgGrid )
	cIdGrid  	:= oTela:CreateHorizontalBox( 80 )
	
	oTela:Activate( oDlgGrid, .F. )
	
	//Cria os paineis onde serao colocados os browses
	oPanel	:= oTela:GeTPanel( cIdGrid )
	
	@ oSize:GetDimension("CABECALHO","LININI")+1 , oSize:GetDimension("CABECALHO","COLINI")+4	GROUP oGroup TO oSize:GetDimension("CABECALHO","LINEND") * 0.090 ,oSize:GetDimension("CABECALHO","COLEND") * 0.431  OF oDlgGrid PIXEL
	oGroup:oFont:=oFont
	@ oSize:GetDimension("CABECALHO","LININI")+9 , oSize:GetDimension("CABECALHO","COLINI")+6 SAY "" Of oDlgGrid Pixel
	
	oMark := FWMarkBrowse():New()
	
	oMark:SetOwner(oPanel)
	oMark:SetAlias(cAliasTRB)
	oMark:SetTemporary(.T.)
	oMark:SetColumns(aColumns)
	oMark:SetFieldMark('OK')
	oMark:SetFilterDefault( "" )
	oMark:SetIgnoreARotina(.T.)
	oMark:SetMenuDef('')
	oMark:SetSeek( .T., aPesq )
	
	oMark:bAllMark := { || SetMarkAll(oMark:Mark(), lMarcar := !lMarcar, cAliasTRB ), oMark:Refresh(.T.)}
	
	oMark:Activate()
	
	SetMarkAll(oMark:Mark(), .F., cAliasTRB, cTiposHE) // Desmarca todos os registros
	
	oMark:Refresh(.T.)
	
	ACTIVATE MSDIALOG oDlgGrid CENTERED ON INIT EnchoiceBar(oDlgGrid, {||nOpcX := 1, oDlgGrid:End() } ,{|| oDlgGrid:End() }, NIL, {})
	
	If nOpcX == 1
		
		//Adiciona os tipos de HE selecionadas
		(cAliasTRB)->(dbGoTop())
		
		lInclui := !Empty(cTiposHE)
		
		If lInclui
			For nX := 1 to nTam //Desmarca todos
				oGrid:GoLine(nX)
				oGrid:LoadValue("P4_OK", .F.)
				nQtd++
			Next nX
		Else 
			oGrid:GoLine(1)
			nQtd++
		EndIf
		
		While (cAliasTRB)->(!EOF())
			
			If !Empty((cAliasTRB)->OK)
				
				oGrid:GoLine(1)
				
				If lInclui
					If !oGrid:SeekLine({{"P4_TIPO", (cAliasTRB)->TIPO}, {"P4_TURNO", (cAliasTRB)->TURNO}, {"P4_DE", (cAliasTRB)->DE}})
						oGrid:AddLine(.T.) //Se não encontrar, adiciona uma linha
					EndIf
					
					oGrid:LoadValue("P4_FILIAL", 	cFilSP4)
					oGrid:LoadValue("P4_TURNO",		(cAliasTRB)->TURNO)
					oGrid:LoadValue("P4_TIPO", 		(cAliasTRB)->TIPO)
					oGrid:LoadValue("P4_DE", 		(cAliasTRB)->DE)
					oGrid:LoadValue("P4_ATE", 		(cAliasTRB)->ATE)
					oGrid:LoadValue("P4_PERCENT",	(cAliasTRB)->PERC)
					oGrid:LoadValue("P4_CODNAUT", 	(cAliasTRB)->CODNAUT)
					oGrid:LoadValue("P4_CODAUT", 	(cAliasTRB)->CODAUT)
					oGrid:LoadValue("P4_FILCCT", 	SWY->WY_FILIAL)
					oGrid:LoadValue("P4_CODCCT", 	SWY->WY_CODIGO)
					
				EndIf
				
				oGrid:LoadValue("P4_OK", 		.T.)
				
				lInclui := .T.
			EndIf
			(cAliasTRB)->(dbSkip())
		EndDo
	EndIf
	
	oGrid:GoLine(1)
	
	RestArea(aArea)
	
Return Nil

/*/{Protheus.doc} GPEDelOk
Altera o campo P4_OK quando a linha é deletada
@type  Static Function
@author Cícero Alves 
@since 26/07/2022
@param oGrid, Objeto, Submodelo da rotina, instância da classe FWFormGridModel
@param nLine, Numérico, Número da linha posicionada
@param cAction, Caractere, Ação que foi executada
@return lRet, Lógico, Indica se a ação é válida
/*/
Static Function GPEDelOk(oGrid, nLine, cAction)
	
	Local lRet := .T.
	
	If cAction == 'DELETE'
		oGrid:LoadValue("P4_OK", .F.)
	ElseIf cAction == 'UNDELETE'
		oGrid:LoadValue("P4_OK", .F.)
	EndIf
	
Return lRet

/*/{Protheus.doc} fSP4Ok
Validações do cadastro dos tipos de hora extra
@type  Static Function
@author Cícero Alves 
@since 26/07/2022
@param oGrid, Objeto, Submodelo da rotina, instância da classe FWFormGridModel 
@param nLine, Numérico, Número da linha posicionada
@return lRet, Lógico, Indica se as informações da linha são válidas
/*/
Static Function fSP4Ok(oGrid, nLine)
	
	Local lRet	:= .T.
	
	oGrid:GoLine(nLine)
	
	// Valida as horas de/até
	If oGrid:GetValue("P4_ATE") <= oGrid:GetValue("P4_DE")
		lRet := .F.
		// "O campo Horas Até não pode ser menor que o campo Horas De" -- "Informe um valor válido para o campo horas até."
		Help(NIL, NIL, "Help", NIL, STR0052, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0053})
	EndIf
	
Return lRet
