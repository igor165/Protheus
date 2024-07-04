#INCLUDE 'TMSAE55.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWADAPTEREAI.CH'


//-----------------------------------------------------------------------------------------------------------
/* EDI - Notas Fiscais Importadas
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		7.00.111010P
@since 		17/08/2012
@return 	*/
//-----------------------------------------------------------------------------------------------------------
Function TMSAE55( xRotAuto, nOpcAuto, xItem1, xItem2 )

Local cCadastro		:= STR0001 // 'EDI - Notas Fiscais'
Local lTME55Auto	:= ( ValType( xRotAuto ) == "A" )
Local aAutoCab		:= {}
Local aItemDE5		:= {}
Local aItemDEU		:= {}
Local nOpcView		:= 0

If Type("aPanAgeTMS") == "U"
	aPanAgeTMS := Array(7)
EndIf

lPainel := IsInCallStack("TMSAF76") .And. !Empty(aPanAgeTMS)


Private aRotina		:= MenuDef()

Default xRotAuto 	:= Nil
Default nOpcAuto 	:= 3
Default xItem1 		:= Nil
Default xItem2 		:= Nil
	
If !lPainel
	If !lTME55Auto
		oMBrowse:= FWMBrowse():New()	
		oMBrowse:SetAlias( "DE5" )
		oMBrowse:SetDescription( cCadastro )
		oMBrowse:Activate()
	Else
		aAutoCab 	:= xRotAuto
		aItemDE5   	:= xItem1
		aItemDEU   	:= xItem2
		FwMvcRotAuto( ModelDef(), "DE5", nOpcAuto, { { "TMSE55CDE5", aAutoCab }, { "TMSE55IDE5", aItemDE5 }, { "TMSE55_DEU", aItemDEU } } )  //Chamada da rotina automatica através do MVC
	EndIf		
Else                                       
	If aPanAgeTMS[3] == 3
		FWExecView(, "TMSAE55" , MODEL_OPERATION_INSERT , ,{|| .T. })                               
	Else
		nOpcView:= IIf(aPanAgeTMS[3] == 5,MODEL_OPERATION_DELETE,IIf(aPanAgeTMS[3] == 4,MODEL_OPERATION_UPDATE, MODEL_OPERATION_VIEW))
		FWExecView(, "TMSAE55" , nOpcView , ,{|| .T. })	
	EndIf
EndIf    

Return

//-----------------------------------------------------------------------------------------------------------
/* Modelo de Dados 
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		7.00.111010P
@since 		17/08/2012
@return 	*/
//-----------------------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel 		:= Nil
Local lDE5PESLIQ 	:= DE5->(ColumnPos("DE5_PESLIQ")) > 0
Local oStruCDE5 	:= ''
Local oStruIDE5 	:= ''
Local oStruDEU 		:= FwFormStruct( 1, "DEU" )

If lDE5PESLIQ
	oStruCDE5 := FwFormStruct( 1, "DE5", { |cCampo| !AllTrim( cCampo ) + "|" $ "DE5_CODPRO|DE5_DESPRO|DE5_CODEMB|DE5_QTDVOL|DE5_VALOR|DE5_PESO|DE5_PESOM3|DE5_PESLIQ|DE5_VALSEG|DE5_METRO3|DE5_BASEIC|DE5_VALICM|DE5_BASIST|DE5_VALIST|DE5_FILIAL|DE5_TIPAGD|DE5_DATAGD|DE5_PRDAGD|DE5_INIAGD|DE5_FIMAGD|DE5_MOTAGD|" } )
	oStruIDE5 := FwFormStruct( 1, "DE5", { |cCampo|  AllTrim( cCampo ) + "|" $ "DE5_CODPRO|DE5_DESPRO|DE5_CODEMB|DE5_QTDVOL|DE5_VALOR|DE5_PESO|DE5_PESOM3|DE5_PESLIQ|DE5_VALSEG|DE5_METRO3|DE5_BASEIC|DE5_VALICM|DE5_BASIST|DE5_VALIST|DE5_TIPAGD|DE5_DATAGD|DE5_PRDAGD|DE5_INIAGD|DE5_FIMAGD|DE5_MOTAGD|" } )
Else
	oStruCDE5 := FwFormStruct( 1, "DE5", { |cCampo| !AllTrim( cCampo ) + "|" $ "DE5_CODPRO|DE5_DESPRO|DE5_CODEMB|DE5_QTDVOL|DE5_VALOR|DE5_PESO|DE5_PESOM3|DE5_VALSEG|DE5_METRO3|DE5_BASEIC|DE5_VALICM|DE5_BASIST|DE5_VALIST|DE5_FILIAL|DE5_TIPAGD|DE5_DATAGD|DE5_PRDAGD|DE5_INIAGD|DE5_FIMAGD|DE5_MOTAGD|" } )
	oStruIDE5 := FwFormStruct( 1, "DE5", { |cCampo|  AllTrim( cCampo ) + "|" $ "DE5_CODPRO|DE5_DESPRO|DE5_CODEMB|DE5_QTDVOL|DE5_VALOR|DE5_PESO|DE5_PESOM3|DE5_VALSEG|DE5_METRO3|DE5_BASEIC|DE5_VALICM|DE5_BASIST|DE5_VALIST|DE5_TIPAGD|DE5_DATAGD|DE5_PRDAGD|DE5_INIAGD|DE5_FIMAGD|DE5_MOTAGD|" } )
EndIf 

oModel := MpFormModel():New( "TMSAE55", /*bPre*/, /*bPost*/, { |oModel| CommitMdl( oModel ) }, /*bCancel*/ )

oModel:SetDescription( OemToAnsi( STR0001 ) ) // 'EDI - Notas Fiscais'

oModel:AddFields( "TMSE55CDE5", Nil, oStruCDE5, /*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/ )

oModel:SetPrimaryKey( { "DE5_FILIAL","DE5_CGCREM","DE5_DOC","DE5_SERIE" } )

oModel:AddGrid( "TMSE55IDE5", "TMSE55CDE5", oStruIDE5 )
oModel:AddGrid( "TMSE55_DEU", "TMSE55CDE5", oStruDEU, { |oModel| DEULinePre( oModel ) }, ,/*bPre*/,/*bPost*/,/*bLoad*/ )

oModel:SetRelation( "TMSE55IDE5", { { "DE5_FILIAL", "xFilial('DE5')" }, { "DE5_CGCREM", "DE5_CGCREM" }, { "DE5_DOC", "DE5_DOC" }, { "DE5_SERIE", "DE5_SERIE" } }, DE5->( IndexKey( 1 ) ) )
oModel:SetRelation( "TMSE55_DEU", { { "DEU_FILIAL", "xFilial('DEU')" }, { "DEU_CGCREM", "DE5_CGCREM" }, { "DEU_DOC", "DE5_DOC" }, { "DEU_SERIE", "DE5_SERIE" } }, DEU->( IndexKey( 1 ) ) )
  
oModel:GetModel( "TMSE55IDE5" ):SetUniqueLine( { "DE5_CODPRO" } )
oModel:GetModel( "TMSE55_DEU" ):SetUniqueLine( { "DEU_TIPVEI" } )									     

oModel:GetModel( "TMSE55IDE5" ):SetDelAllLine( .T. )
oModel:GetModel( "TMSE55_DEU" ):SetDelAllLine( .T. )

oModel:GetModel( "TMSE55_DEU" ):SetOptional( .T. )

oModel:AddCalc( "TMSE55TOT", "TMSE55CDE5", "TMSE55IDE5", "DE5_QTDVOL"   , "Volume" 			, "SUM" ) 
oModel:AddCalc( "TMSE55TOT", "TMSE55CDE5", "TMSE55IDE5", "DE5_VALOR"    , "Valor"  			, "SUM" ) 
oModel:AddCalc( "TMSE55TOT", "TMSE55CDE5", "TMSE55IDE5", "DE5_PESO"     , "Peso"				, "SUM" ) 
oModel:AddCalc( "TMSE55TOT", "TMSE55CDE5", "TMSE55IDE5", "DE5_PESOM3"   , "Peso Cubado"		, "SUM" ) 
If lDE5PESLIQ
	oModel:AddCalc( "TMSE55TOT", "TMSE55CDE5", "TMSE55IDE5", "DE5_PESLIQ"   , "Peso Líquido"	, "SUM" )
EndIf
oModel:AddCalc( "TMSE55TOT", "TMSE55CDE5", "TMSE55IDE5", "DE5_METRO3"   , "M3"				, "SUM" )
oModel:AddCalc( "TMSE55TOT", "TMSE55CDE5", "TMSE55IDE5", "DE5_VALSEG"   , "Valor Seguro"	, "SUM" )  

oModel:SetVldActivate( { |oModel| VldActdMdl( oModel ) } )

oModel:SetDeActivate( { |oModel| DeActMdl( oModel ) } )

Return( oModel )

//-----------------------------------------------------------------------------------------------------------
/* Retorna a View (tela) da rotina Cadastro de Endereço 
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		7.00.111010P
@since 		17/08/2012
@return 	*/
//-----------------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel		:= FwLoadModel( "TMSAE55" )
Local oView	  		:= Nil
Local lDE5PESLIQ 	:= DE5->(ColumnPos("DE5_PESLIQ")) > 0
Local oStruCDE5		:= ''
Local oStruIDE5		:= ''
Local oStruDEU		:= FwFormStruct( 2,"DEU" )
Local oCalc1		:= Nil

Local cCodProF3 := Posicione('SX3', 2, 'DE5_CODPRO', 'X3_F3' )

If lDE5PESLIQ
	oStruCDE5	:= FwFormStruct( 2,"DE5", {|cCampo| !AllTrim( cCampo ) + "|" $ "DE5_CODPRO|DE5_DESPRO|DE5_CODEMB|DE5_QTDVOL|DE5_VALOR|DE5_PESO|DE5_PESOM3|DE5_PESLIQ|DE5_VALSEG|DE5_METRO3|DE5_BASEIC|DE5_VALICM|DE5_BASIST|DE5_VALIST|DE5_TIPAGD|DE5_DATAGD|DE5_PRDAGD|DE5_INIAGD|DE5_FIMAGD|DE5_MOTAGD|" } )
	oStruIDE5	:= FwFormStruct( 2,"DE5", {|cCampo|  AllTrim( cCampo ) + "|" $ "DE5_CODPRO|DE5_DESPRO|DE5_CODEMB|DE5_QTDVOL|DE5_VALOR|DE5_PESO|DE5_PESOM3|DE5_PESLIQ|DE5_VALSEG|DE5_METRO3|DE5_BASEIC|DE5_VALICM|DE5_BASIST|DE5_VALIST|DE5_TIPAGD|DE5_DATAGD|DE5_PRDAGD|DE5_INIAGD|DE5_FIMAGD|DE5_MOTAGD|" } )
Else
	oStruCDE5	:= FwFormStruct( 2,"DE5", {|cCampo| !AllTrim( cCampo ) + "|" $ "DE5_CODPRO|DE5_DESPRO|DE5_CODEMB|DE5_QTDVOL|DE5_VALOR|DE5_PESO|DE5_PESOM3|DE5_VALSEG|DE5_METRO3|DE5_BASEIC|DE5_VALICM|DE5_BASIST|DE5_VALIST|DE5_TIPAGD|DE5_DATAGD|DE5_PRDAGD|DE5_INIAGD|DE5_FIMAGD|DE5_MOTAGD|" } )
	oStruIDE5	:= FwFormStruct( 2,"DE5", {|cCampo|  AllTrim( cCampo ) + "|" $ "DE5_CODPRO|DE5_DESPRO|DE5_CODEMB|DE5_QTDVOL|DE5_VALOR|DE5_PESO|DE5_PESOM3|DE5_VALSEG|DE5_METRO3|DE5_BASEIC|DE5_VALICM|DE5_BASIST|DE5_VALIST|DE5_TIPAGD|DE5_DATAGD|DE5_PRDAGD|DE5_INIAGD|DE5_FIMAGD|DE5_MOTAGD|" } )
EndIf	

If !Empty(cCodProF3)
 oStruIDE5:SetProperty( 'DE5_CODPRO' , MVC_VIEW_LOOKUP    , cCodProF3 )
EndIf

oCalc1 := FWCalcStruct( oModel:GetModel( "TMSE55TOT" ) )

oStruDEU:RemoveField( "DEU_CGCREM"	)
oStruDEU:RemoveField( "DEU_DOC"		)
oStruDEU:RemoveField( "DEU_SERIE"	)

oView := FwFormView():New()
oView:SetModel( oModel )

oView:AddField( "VIEWCDE5", oStruCDE5, "TMSE55CDE5" )
oView:AddGrid(  "VIEWIDE5", oStruIDE5, "TMSE55IDE5" )
oView:AddGrid(  "VIEW_DEU", oStruDEU , "TMSE55_DEU" )
oView:AddField( "VIEWCALC", oCalc1   , "TMSE55TOT"  )

oView:AddIncrementField( 'VIEW_DEU', 'DEU_ITEM' )

oView:CreateHorizontalBox( 'TOPO'     , 40 )
oView:CreateHorizontalBox( 'FOLDER'   , 60 )

oView:CreateFolder( "PASTA", "FOLDER" )

oView:AddSheet( "PASTA", "ABA01", STR0001 ) //"Tipos de Veículo EDI"
oView:AddSheet( "PASTA", "ABA02", STR0013 ) //"Tipos de Veículo EDI"

oView:CreateHorizontalBox( "TAB_DE5"  , 070,,,"PASTA","ABA01" )
oView:CreateHorizontalBox( "TOTALDE5" , 030,,,"PASTA","ABA01" )
oView:CreateHorizontalBox( "TAB_DEU"  , 100,,,"PASTA","ABA02" )

oView:SetOwnerView( "VIEWCDE5"  , "TOPO"     )
oView:SetOwnerView( "VIEWIDE5"  , "TAB_DE5"  )
oView:SetOwnerView( "VIEW_DEU"  , "TAB_DEU"  )
oView:SetOwnerView( "VIEW_DEU"  , "TAB_DEU"  )
oView:SetOwnerView( "VIEWCALC"  , "TOTALDE5" )

Return( oView )

//===========================================================================================================
/* Retorna as operações disponiveis para o Cadastro de Nota Fiscal EDI.
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		7.00.111010P
@since 		17/08/2012
@return 	aRotina - Array com as opçoes de Menu */                                                                                                         
//===========================================================================================================
Static Function MenuDef()

Local aArea		:= GetArea()
Local aRotina 	:= {}
Local aRet 		:= {}
Local nX		:= 0
aAdd( aRotina, { STR0002, "PesqBrw"          , 0, 1, 0, .T. } ) // Pesquisar
aAdd( aRotina, { STR0003, "VIEWDEF.TMSAE55"  , 0, 2, 0, .F. } ) // Visualizar
aAdd( aRotina, { STR0004, "VIEWDEF.TMSAE55"  , 0, 3, 0, Nil } ) // Incluir
aAdd( aRotina, { STR0005, "VIEWDEF.TMSAE55"  , 0, 4, 0, Nil } ) // Alterar
aAdd( aRotina, { STR0006, "VIEWDEF.TMSAE55"  , 0, 5, 3, Nil } ) // Excluir
If FindFunction('TMSAC17')
	aAdd( aRotina, { STR0024, "TMAE55CBar"  , 0, 3, 0, Nil } ) // Cod. Barras
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada utilizado para inserir novas opcoes no array aRotina  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("TME55MNU")
	aRet := ExecBlock("TME55MNU",.F.,.F.)
EndIf

If ValType(aRet) == "A" .And. Len(aRet) > 0
		For nX := 1 To Len( aRet )
			aAdd( aRotina, aRet[ nX ] )
		Next
EndIf

RestArea( aArea )

Return aRotina

//===========================================================================================================
/* Pré validacao do Model
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		7.00.111010P
@since 		17/08/2012
@return 	lRet */                                                                                                         
//===========================================================================================================

Static Function VldActdMdl( oMdl )

Local aArea		:= GetArea()
Local aAreaSA1  := SA1->(GetArea())
Local lRet		:= .T.
Local nOpcx		:= oMdl:GetOperation()

If nOpcx == MODEL_OPERATION_UPDATE .Or. nOpcx == MODEL_OPERATION_DELETE 
	If DE5->DE5_STATUS == "2" // Registro encerrado
		Help(" ",1,"TMSAE5504")
		lRet := .F.
	Else
		SA1->(DbSetOrder(3))
		If SA1->(DbSeek(xFilial("SA1") + DE5->DE5_CGCREM))
			If !TMSAVerAge("2",,,,SA1->A1_COD,SA1->A1_LOJA,DE5->DE5_DOC,DE5->DE5_SERIE,DE5->DE5_CODPRO,,,,"2",.T.,.T.)
				lRet := .F.
			EndIf
		Else
			MsgAlert("Cliente remetente não localizado.","Atenção")
			lRet := .F.
		EndIf
	EndIf
EndIf

RestArea( aAreaSA1 )
RestArea( aArea )

If !lRet
	//-- Limpa marcas dos agendamentos
	//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
	If !IsInCallStack("TMSAF76")
		TMSALimAge(StrZero(ThreadId(),20))
	EndIf
EndIf

Return( lRet )

//===========================================================================================================
/* Efetua a gravaçãodo do Model
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		7.00.111010P
@since 		17/08/2012
@return 	lRet */                                                                                                         
//===========================================================================================================

Static Function CommitMdl( oMdl )

Local aArea			:= GetArea()
Local lRet			:= .T.
Local lTME55GRV		:= ExistBlock("TME55GRV")
Local nOpcx	  		:= oMdl:GetOperation()

FWFormCommit( oMdl )

If nOpcx == MODEL_OPERATION_INSERT .Or. nOpcx == MODEL_OPERATION_UPDATE 
	If lTME55GRV
		ExecBlock("TME55GRV",.F.,.F.)
	EndIf
EndIf

RestArea( aArea )

Return( lRet )

//===========================================================================================================
/* Pre-Validação do Grid DET
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		7.00.111010P
@since 		17/08/2012
@return 	lRet */                                                                                                         
//===========================================================================================================

Static Function DETLinePre( oMdl )

Local aArea			:= GetArea()
Local lRet 			:= .T.
Local cHelpCamps	:= ""

If Empty(M->DE5_CGCREM) .Or. Empty(M->DE5_CGCDES) .Or. Empty(M->DE5_CGCDEV) .Or. Empty(M->DE5_TIPTRA) .Or. ;
		Empty(M->DE5_SERTMS) .Or. Empty(M->DE5_TIPFRE) .Or. Empty(M->DE5_SERVIC) .Or. Empty(M->DE5_CODPRO)

	cHelpCamps := RetTitle('DE5_CGCREM')+" / "+RetTitle('DE5_CGCDES')+" / "+RetTitle('DE5_CGCDEV')+Chr(13)+Chr(10)
	cHelpCamps += RetTitle('DE5_TIPTRA')+" / "+RetTitle('DE5_SERTMS')+" / "+RetTitle('DE5_TIPFRE')+" / "+RetTitle('DE5_SERVIC')+" / "+RetTitle('DE5_CODPRO')

	Help(" ",1,"TMSAE5503",,Chr(13)+Chr(10)+"- "+cHelpCamps,1,0) // "É obrigatório o preenchimento dos campos:"

	lRet := .F.

EndIf

RestArea( aArea )

Return( lRet )

//===========================================================================================================
/* Pre-Validação do Grid DEU
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		7.00.111010P
@since 		17/08/2012
@return 	lRet */                                                                                                         
//===========================================================================================================
Static Function DEULinePre( oMdl )

Local aArea	:= GetArea()
Local lRet 	:= .T.

Default oMdl := Nil

If Empty(M->DE5_CGCREM) .Or. Empty(M->DE5_DOC)

	Help(" ",1,"TMSAE5502") //"Infome o CNPJ do Cliente e Numero/Serie do Documento"
   
	lRet := .F.	
EndIf

RestArea( aArea )

Return( lRet )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAE55Vld³ Autor ³ Gilson da Silva       ³ Data ³ 25/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes do EDI                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAE55Vld()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAE55                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAE55Vld()
Local cCampo 	  := ReadVar()
Local lRet  	  := .T.
Local cTipo  	  := ""
Local cCgc   	  := ""  
Local cNumCot	  := ""        
Local lSixAtu	  := .T.
Local aAreaSIX 	  := GetArea() 
Local aAreaDT4    := {}
Local lDE5PESLIQ  := DE5->(ColumnPos("DE5_PESLIQ")) > 0
Local oStruIDE5   := ''
Local cCodProF3   := Posicione('SX3', 2, 'DE5_CODPRO', 'X3_F3' )
Local oModel	  := FwModelActive()	// Recebe o Model Ativo
Local oMdlGrid    := NIL				// Recebe o Modelo do Grid 
Local nLinha      := 0				// Recebe a Linha atual
Local cPlaca      := ""
Local aAreaDA3    := {}
Local lDE5_IDESTR := DE5->(ColumnPos('DE5_IDESTR')) > 0
Local cIDESTR     := ''

If lDE5PESLIQ
	oStruIDE5 := FwFormStruct( 2,"DE5", {|cCampo|  AllTrim( cCampo ) + "|" $ "DE5_CODPRO|DE5_DESPRO|DE5_CODEMB|DE5_QTDVOL|DE5_VALOR|DE5_PESO|DE5_PESOM3|DE5_PESLIQ|DE5_VALSEG|DE5_METRO3|DE5_BASEIC|DE5_VALICM|DE5_BASIST|DE5_VALIST|DE5_IDESTR|" } )
Else
	oStruIDE5 := FwFormStruct( 2,"DE5", {|cCampo|  AllTrim( cCampo ) + "|" $ "DE5_CODPRO|DE5_DESPRO|DE5_CODEMB|DE5_QTDVOL|DE5_VALOR|DE5_PESO|DE5_PESOM3|DE5_VALSEG|DE5_METRO3|DE5_BASEIC|DE5_VALICM|DE5_BASIST|DE5_VALIST|DE5_IDESTR|" } )
EndIf

If cCampo $ 'M->DE5_CGCREM;M->DE5_CGCDES;M->DE5_CGCCON;M->DE5_CGCDPC;M->DE5_CGCDEV;M->DE5_CGCEXP;M->DE5_CGCREC'
	cCgc := &(cCampo)
//-- Posiciona no cadastro de Clientes para verificar se o A1_TIPO == "X" (Exportacao)
	If !Empty(cCgc) .And. cCgc <> "00000000000000"
		cTipo := Posicione("SA1",3,xFilial("SA1")+cCgc,"A1_TIPO")		
	Else
		If cCgc = "00000000000000"
			cTipo := SA1->A1_TIPO
			If lDE5_IDESTR
				cIDESTR := SA1->A1_PFISICA
                FwFldPut("DE5_IDESTR",Substr(cIDESTR, 1, TamSX3('DE5_IDESTR')[1]),,,,.T.)
			EndIf
		EndIf
	EndIf

	If cPaisLoc == "BRA" .And. cTipo == "X"
		lRet := .T.
	Else
		lRet := CGC(cCgc)
	EndIf

	If lRet .And. cCampo == 'M->DE5_CGCDES'
		TMSA050InscCli(SA1->A1_COD, SA1->A1_LOJA, cCampo)
	EndIf
	
	If lRet .And. cCampo == 'M->DE5_CGCREM' .And. !Empty(M->DE5_DOC) .And. !Empty(M->DE5_SERIE) //.And. !Empty(M->DE5_EMINFC)
		lRet := ExistChav('DE5',M->DE5_CGCREM+M->DE5_DOC+M->DE5_SERIE,1)
	EndIf	

ElseIf cCampo $ 'M->DE5_DOC' .And. lSixAtu
	If !Empty(M->DE5_CGCREM) .And. !Empty(M->DE5_SERIE) //.And. !Empty(M->DE5_EMINFC)
		lRet := ExistChav('DE5',M->DE5_CGCREM+M->DE5_DOC+M->DE5_SERIE,1)
	EndIf		
ElseIf cCampo $ 'M->DE5_SERIE' .And. lSixAtu
	If !Empty(M->DE5_CGCREM) .And. !Empty(M->DE5_DOC) //.And. !Empty(M->DE5_EMINFC)
		lRet := ExistChav('DE5',M->DE5_CGCREM+M->DE5_DOC+M->DE5_SERIE,1)  
	EndIf
ElseIf cCampo $ 'M->DE5_CODPRO'
	If !Empty(cCodProF3)
		oStruIDE5:SetProperty( 'DE5_CODPRO' , MVC_VIEW_LOOKUP    , cCodProF3 )
	Else
		lRet := ExistCpo("SB1",M->DE5_CODPRO)                                                                                              
	EndIf	                                                                                              
ElseIf cCampo $ 'M->DE5_LOTEDI'
	If !Vazio()
		lRet := ExistCpo("DET",M->DE5_LOTEDI,1)  
		If lRet 
			cNumCot := Posicione("DET",1,xFilial("DET")+M->DE5_LOTEDI,"DET_NUMCOT")	
			If !Empty(cNumCot)		
				aAreaDT4 := DT4->( GetArea() )
				//-- DT4_FILIAL+DT4_NUMCOT
				DT4->( dbSetOrder(4) ) 
				If DT4->( dbSeek( xFilial("DT4") + cNumCot ) )
					//-- 1=Pendente;2=Bloqueada;3=Aprovada;4=Encerrada;9=Cancelada 
					If DT4->DT4_STATUS == "4"
					   Help(" ",1 ,"TMSAE5505") //-- Já foi encontrada cotação parae ste lote, e a mesma encontra-se encerrada.
				  		lRet := .F.
					EndIf
				EndIf	
				RestArea(aAreaDT4)
			EndIf	 
		EndIf	  
	EndIf
ElseIf cCampo == "M->DE5_CODNEG"
	If Empty(M->DE5_CODNEG)
		Help(' ', 1, 'TMSAE5506') //-- Não é permitido que o código da negociação fique em branco.
		lRet := .F.
	EndIf
ElseIf cCampo $ 'M->DE5_DATAGD.M->DE5_INIAGD.M->DE5_FIMAGD.M->DE5_TIPAGD.M->DE5_PRDAGD.M->DE5_MOTAGD'
	//-- Agendamento de Entrega
	oMdlGrid := oModel:GetModel( "TMSE55IDE5" )
	nLinha   := oMdlGrid:GetLine() 
	If cCampo == "M->DE5_DATAGD" .And. &cCampo < dDataBase
		lRet := .F.
	ElseIf cCampo == "M->DE5_INIAGD"
		If oMdlGrid:GetValue("DE5_PRDAGD",nLinha) <> '2' .And. !AtVldHora(oMdlGrid:GetValue("DE5_INIAGD",nLinha))
			lRet := .F.
		EndIf
	ElseIf cCampo == "M->DE5_FIMAGD"
	   If !(oMdlGrid:GetValue("DE5_PRDAGD",nLinha) $ '1,4') .And. (!AtVldHora(oMdlGrid:GetValue("DE5_FIMAGD",nLinha)) .Or. &cCampo < oMdlGrid:GetValue("DE5_INIAGD",nLinha))
			lRet := .F.
		EndIf
	ElseIf cCampo == "M->DE5_FIMAGD" .And. Empty(&cCampo)
		lRet := .F.
	ElseIf cCampo == "M->DE5_PRDAGD" .And. !Pertence("1234")
		lRet := .F.
 	EndIf
ElseIf cCampo $ 'M->DE5_PLACA.M->DE5_PLARB1.M->DE5_PLARB2.M->DE5_PLARB3'
	cPlaca:= &cCampo
	
	If !Empty(cPlaca)
		aAreaDA3 := DA3->( GetArea() )
		DA3->(dbSetOrder(3))
		If DA3->(DbSeek(xFilial('DA3') + cPlaca))  
			cCatVei:=  Posicione("DUT",1,xFilial("DUT")+DA3->DA3_TIPVEI,"DUT_CATVEI") 
			If cCampo == "M->DE5_PLACA"
				lRet:= cCatVei <> StrZero(3,Len(DUT->DUT_CATVEI)) 
			Else
				lRet:= cCatVei == StrZero(3,Len(DUT->DUT_CATVEI))    //Reboque				
			EndIf

			If !lRet
				Help(" ",1,"TMSAE5508")   //Categoria do veículo inválido.
			EndIf
		Else
			Help(" ",1,"TMSAE5507")  //Placa do Veículo não cadastrado.
			lRet:= .F.
		EndIf
		RestArea(aAreaDA3)
	EndIf
EndIf

RestArea(aAreaSIX)

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAE55Whe  ³ Autor ³ Gustavo Almeida     ³ Data ³04.07.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao de Campos (X3_WHEN)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAE55Whe()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function TMSAE55Whe(cCampo)
Local lRet     := .T.
Local lAgdEntr := Iif(FindFunction("TMSA018Agd"),TMSA018Agd(),.F.) .AND. DYD->(ColumnPos("DYD_DIAATR")) > 0   //-- Agendamento de Entrega.
Local oModel   := FwModelActive()	// Recebe o Model Ativo
Local oMdlGrid := NIL				// Recebe o Modelo do Grid 
Local nLinha   := 0					// Recebe a Linha atual

Default cCampo := AllTrim(ReadVar())

If cCampo $ 'M->DE5_SERTMS/M->DE5_SERVIC/'
	If Empty(M->DE5_CGCREM) .Or. Empty(M->DE5_CGCDES) .Or. Empty(M->DE5_CGCDEV) .Or. Empty(M->DE5_TIPTRA) .Or. ;
			Empty(M->DE5_TIPFRE)  
		lRet := .F.
	EndIf
ElseIf  cCampo $ 'M->DE5_CGCDEV/M->DE5_CGCREM/M->DE5_CGCDES/M->DE5_CGCEXP/M->DE5_CGCREC/' .And. !Empty(M->DE5_CGCDEV) 
	//--Validação do campo DE5_CGCDEV para quando informar o devedor, gatilhar o campo DE5_TIPFRE com CIF ou FOB.
	If M->DE5_CGCDEV == M->DE5_CGCREM .Or. M->DE5_CGCDEV == M->DE5_CGCEXP
		M->DE5_TIPFRE := "1" //-- CIF	
	ElseIf M->DE5_CGCDEV == M->DE5_CGCDES .Or. M->DE5_CGCDEV == M->DE5_CGCREC
		M->DE5_TIPFRE := "2" //-- FOB
	ElseIf (!Empty(M->DE5_CGCDPC) .And. M->DE5_CGCDEV == M->DE5_CGCDPC) .Or. (!Empty(M->DE5_CGCCON) .And. M->DE5_CGCDEV == M->DE5_CGCCON)
		M->DE5_TIPFRE := "2" //-- FOB
	Else
		M->DE5_TIPFRE := ""	
	EndIf
EndIf

//-- Agendamento de Entrega
If lAgdEntr
	If lRet
		oMdlGrid := oModel:GetModel( "TMSE55IDE5" )
		nLinha   := oMdlGrid:GetLine() 
		
		If cCampo == 'M->DE5_INIAGD'
			lRet := ( oMdlGrid:GetValue("DE5_PRDAGD",nLinha) <>'2')
		ElseIf cCampo == 'M->DE5_FIMAGD'
			lRet := (oMdlGrid:GetValue("DE5_PRDAGD",nLinha)$'2.3')
		ElseIf cCampo == 'M->DE5_PRDAGD'
			If oMdlGrid:GetValue("DE5_PRDAGD",nLinha) $ '1.4'
				oMdlGrid:LoadValue("DE5_FIMAGD",Space(TamSX3('DE5_FIMAGD')[1]),nLinha)
			ElseIf oMdlGrid:GetValue("DE5_PRDAGD",nLinha) == '2'
				oMdlGrid:LoadValue("DE5_INIAGD",Space(TamSX3('DE5_INIAGD')[1]),nLinha)
			EndIf
		EndIf
	EndIf
EndIf 
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IntegDef  ºAutor  ³ Leandro Paulino  º Data ³  09/12/11		º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Mensagem Única									           	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Mensagem Única                                            	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
Local aRet := {}                          

aRet := TMSIE55( cXML, nTypeTrans, cTypeMessage )

Return aRet

//===========================================================================================================
/* Define se desativa a Model
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		7.00.111010P
@since 	18/03/2016
@return 	lRet */                                                                                                         
//===========================================================================================================

Static Function DeActMdl( oMdl )
Local lRet := .T.

//-- Limpa marcas dos agendamentos
If !IsInCallStack("TMSAF76")
	TMSALimAge(StrZero(ThreadId(),20))
EndIf

Return lRet

//-----------------------------------------------------------------------------------------------------------
/* EDI NF - TMAE55CBar - Código de Barra para inserção de DE5
@author  	Felipe Barbiere
@version 	1.0
@since 		21/05/2021
@return 	Nil */
//-----------------------------------------------------------------------------------------------------------
Function TMAE55CBar(oModel)
Local cCodBar := Space(TamSX3("DTC_NFEID")[1])
Local aNFs	  := {}
Local lIndices:= !Empty(DTC->(IndexKey(18))) //DTC_FILIAL+DTC_NFEID 
Local oGetBar 
Local oDlgBar

If RetRdTSS() .And. lIndices
	DEFINE DIALOG oDlgBar FROM 0,0 TO 120,400 TITLE STR0023 Of oMainWnd PIXEL       //Leitura do Codigo de Barras

	@ 16,10 SAY STR0022 Of oDlgBar PIXEL SIZE 100,10 //--"Informe o código de barras"
	@ 26,10 MSGET oGetBar VAR cCodBar SIZE 140,10 Picture '@!' VALID (oDlgBar:End()) PIXEL
	@ 25,11 MSGET oGetBar VAR cCodBar SIZE 1,1 //-- campo para mudança de foco e execução do valid

	ACTIVATE DIALOG oDlgBar CENTERED VALID(Iif(oDlgBar:WindowState() == 2,(cCodBar == '',.T.),.T.))
	
	If !Empty(cCodBar) .And. Len(AllTrim(cCodBar)) == 44 .And. Ascan(aNFs, {|x| x[1] == cCodBar}) == 0
		AAdd(aNFs, cCodbar)		
		TMAE55CBar(oModel)
	EndIf

	If !Empty(aNFs)
		TMAE55Proc(aNFs)
	EndIf
Else
	Aviso("SIGATMS", STR0030, {STR0031}, 3 ) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf

Return

//-----------------------------------------------------------------------------------------------------------
/* EDI de NFe - TMAE55Proc - Processamento da busca Notas Fiscais Eletrônicas na SEFAZ
@author  	Felipe Barbiere
@version 	1.0
@since 		21/05/2021
@return 	Nil */
//-----------------------------------------------------------------------------------------------------------
Function TMAE55Proc(aNFs)
    FwMsgRun( , {|oSay| TMAE55BNFe(oSay, aNFs) } , STR0025 , STR0026 ) //"Processando"  /  "Realizando comunicação com a SEFAZ"
Return

//-----------------------------------------------------------------------------------------------------------
/* Conferencia de Coletas - TMAE55BNFe - Busca Notas Fiscais Eletrônicas na SEFAZ
@author  	Felipe Barbiere
@version 	1.0
@since 		21/05/2021
@return 	Nil */
//-----------------------------------------------------------------------------------------------------------
Static Function  TMAE55BNFe(oSay, aNFs)
Local oNFSEFAZ
Local aResult     := {}		
Local aNFErros	  := {}
Local nCont		  := 0

Default aNFs      := {}

If !Empty(aNFs)
	DTC->(dbSetOrder(18)) //DTC_FILIAL+DTC_NFEID
	DE5->(dbSetOrder(5)) //DE5_FILIAL_DE5_NFEID

	oNFSEFAZ := TMSBCANFESEFAZ():New()
	For nCont := 1 to Len(aNFs)
		If !DTC->(MsSeek(xFilial("DTC")+aNFs[nCont])) .And. !DE5->(MsSeek(xFilial("DE5")+aNFs[nCont])) 
			oSay:SetText(STR0025 + STR0027 + aNFs[nCont] + "...") //Processando NFe XXXXXXX ....
			aResult := oNFSEFAZ:GetXMLNFe({aNFs[nCont]})
			If !Empty(aResult)
				TMSAE80A(aResult)	
			Else
				AAdd(aNFErros, { AllTrim(STR0027) + " " + aNFs[nCont] + STR0028, '04', ""})  //NF-e: XXXXX não encontrada 
			EndIf
		Else
			AAdd(aNFErros, { AllTrim(STR0027) + " " + aNFs[nCont] + STR0029, '04', ""})  //NF-e: XXXXX já existe na base de dados. Verifique as tabelas DE5 ou DTC. 
		EndIf
	Next nCont

	If !Empty( aNFErros )
		TmsMsgErr( aNFErros )
	EndIf
EndIf     

Return 
