#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA404.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA404
Evento do e-Social S-2241 - Insalubridade, Periculosidade e Aposentadoria Especial

@author Paulo V.B. Santana
@since 11/11/2015
@version 1.0  

/*/ 
//-------------------------------------------------------------------
Function TAFA404()

Private oBrw :=  FWmBrowse():New()

If TafAtualizado()
	oBrw:SetDescription(STR0008)    //Insalubridade, Periculosidade e Aposentadoria Especial
	oBrw:SetAlias( 'T3B')
	oBrw:SetMenuDef( 'TAFA404' )
	oBrw:SetCacheView(.F.)
	oBrw:DisableDetails()
	
	If FindFunction('TAFSetFilter')
		oBrw:SetFilterDefault(TAFBrwSetFilter("T3B","TAFA404","S-2241"))
	Else
		oBrw:SetFilterDefault( "T3B_ATIVO == '1'" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )
	EndIf
	
	TafLegend(3,"T3B",@oBrw)
	
	oBrw:Activate()
EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Paulo V.B. Santana
@since 11/11/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}
If FindFunction('TafXmlRet')
	Aadd( aFuncao, { "" , "TafxmlRet('TAF404Xml','2241','T3B')" , "1" } )
Else 
	Aadd( aFuncao, { "" , "TAF404Xml" , "1" } )
EndIf 
	
//Chamo a Browse do Histórico
If FindFunction( "xNewHisAlt" ) 
	Aadd( aFuncao, { "" , "xNewHisAlt( 'T3B', 'TAFA404' ,,,,,,'2241','TAF404Xml' )" , "3" } )
Else
	Aadd( aFuncao, { "" , "xFunHisAlt( 'T3B', 'TAFA404' ,,,, 'TAF404XML','2241'  )" , "3" } )
EndIf

Aadd( aFuncao, { "" , "TAFXmlLote( 'T3B', 'S-2241' , 'evtInsApo' , 'TAF404Xml',, oBrw )" , "5" } )
Aadd( aFuncao, { "" , "xFunAltRec( 'T3B' )" , "10" } )
	
lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina Title "Visualizar"       Action 'VIEWDEF.TAFA404' OPERATION 2 ACCESS 0
	
	// Menu dos extemporâneos
	If FindFunction( "xNewHisAlt" ) .AND. FindFunction( "xTafExtmp" ) .And. xTafExtmp()
		aRotina	:= xMnuExtmp( "TAFA404", "T3B" )
	EndIf
		
Else
	aRotina	:=	xFunMnuTAF( "TAFA404" , , aFuncao, ,STR0009,STR0010,STR0011) //"Retificar Evento" "Alterar Evento" "Finalizar Evento"
EndIf

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Paulo V.B. Santana
@since 11/11/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruT3B	:= FWFormStruct( 1, 'T3B' )
Local oStruT3C  	:= FWFormStruct( 1, 'T3C' )
Local oStruT3D  	:= FWFormStruct( 1, 'T3D' )
Local oStruT3N  	:= FWFormStruct( 1, 'T3N' )
Local oStruT3O  	:= FWFormStruct( 1, 'T3O' )
Local oModel		:= MPFormModel():New( 'TAFA404' , , , {|oModel| SaveModel(oModel)})

lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

If lVldModel
	oStruT3B:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
EndIf

//Remoção do GetSX8Num quando se tratar da Exclusão de um Evento Transmitido.
//Necessário para não incrementar ID que não será utilizado.
If Upper( ProcName( 2 ) ) == Upper( "GerarExclusao" )
	oStruT3B:SetProperty( "T3B_ID", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "" ) )
EndIf

oModel:AddFields('MODEL_T3B', /*cOwner*/, oStruT3B)

//===================================
//Periculosidade e Insalubridade
//===================================
oModel:AddGrid("MODEL_T3C","MODEL_T3B",oStruT3C)
oModel:GetModel("MODEL_T3C"):SetUniqueLine({"T3C_IDAMB"})
oModel:GetModel('MODEL_T3C'):SetOptional( .T. )

oModel:AddGrid("MODEL_T3D","MODEL_T3C",oStruT3D)
oModel:GetModel("MODEL_T3D"):SetUniqueLine( {"T3D_IDFATR"} )
//oModel:GetModel('MODEL_T3D'):SetOptional( .T. )
//========================================================================

//===================================
//Aposentadoria Especial
//===================================
oModel:AddGrid("MODEL_T3N","MODEL_T3B",oStruT3N)
oModel:GetModel("MODEL_T3N"):SetUniqueLine({"T3N_IDAMB"})
oModel:GetModel('MODEL_T3N'):SetOptional( .T. )

oModel:AddGrid("MODEL_T3O","MODEL_T3N",oStruT3O)
oModel:GetModel("MODEL_T3O"):SetUniqueLine( {"T3O_IDFATR"} )
oModel:GetModel('MODEL_T3O'):SetOptional( .T. )
//========================================================================

//========================================================================
//Validação do Modelo de acordo com a opção selecionada no cadastro
//========================================================================

If Type( "cOperEvnt" ) <> "U"

	If cOperEvnt == '1' .AND. T3B->T3B_STATUS <> '4' .AND. T3B->T3B_EVENTO == 'I'
		oStruT3B:SetProperty( "T3B_DTFIN" ,MODEL_FIELD_WHEN,{|| .F. })
		oStruT3B:SetProperty( "T3B_DTFINA",MODEL_FIELD_WHEN,{|| .F. })
		oStruT3B:SetProperty( "T3B_DTALT" ,MODEL_FIELD_WHEN,{|| .F. })
		oStruT3B:SetProperty( "T3B_DTALTA",MODEL_FIELD_WHEN,{|| .F. })	
	
	ElseIf cOperEvnt == '2'
		oStruT3B:SetProperty( "T3B_DTFIN" ,MODEL_FIELD_WHEN,{|| .F. })
		oStruT3B:SetProperty( "T3B_DTFINA",MODEL_FIELD_WHEN,{|| .F. })
		oStruT3B:SetProperty( "T3B_DTINI" ,MODEL_FIELD_WHEN,{|| .F. })
		oStruT3B:SetProperty( "T3B_DTINIA",MODEL_FIELD_WHEN,{|| .F. })
		
	ElseIf cOperEvnt == '3'
		oStruT3B:SetProperty( "T3B_DTINI" ,MODEL_FIELD_WHEN,{|| .F. })
		oStruT3B:SetProperty( "T3B_DTINIA",MODEL_FIELD_WHEN,{|| .F. })
		oStruT3B:SetProperty( "T3B_DTALT" ,MODEL_FIELD_WHEN,{|| .F. })
		oStruT3B:SetProperty( "T3B_DTALTA",MODEL_FIELD_WHEN,{|| .F. })	
		oStruT3D:SetProperty( "T3D_IDFATR",MODEL_FIELD_WHEN,{|| .F. })		
		oStruT3O:SetProperty( "T3O_IDFATR",MODEL_FIELD_WHEN,{|| .F. })
	EndIf
	
	oStruT3B:SetProperty( "T3B_IDTRAB",MODEL_FIELD_WHEN,{|| .F. })	

Else
	oStruT3B:SetProperty( "T3B_DTFIN" ,MODEL_FIELD_WHEN,{|| .F. })
	oStruT3B:SetProperty( "T3B_DTFINA",MODEL_FIELD_WHEN,{|| .F. })
	oStruT3B:SetProperty( "T3B_DTALT" ,MODEL_FIELD_WHEN,{|| .F. })
	oStruT3B:SetProperty( "T3B_DTALTA",MODEL_FIELD_WHEN,{|| .F. })	
Endif

//=====================================================================

//Relacionamentos
oModel:SetRelation("MODEL_T3C",{ {"T3C_FILIAL","xFilial('T3C')"}, {"T3C_ID","T3B_ID"}, {"T3C_VERSAO","T3B_VERSAO"}},T3C->(IndexKey(1)) )
oModel:SetRelation("MODEL_T3D",{ {"T3D_FILIAL","xFilial('T3C')"}, {"T3D_ID","T3B_ID"}, {"T3D_VERSAO","T3B_VERSAO"}, {"T3D_IDAMB","T3C_IDAMB"}},T3D->(IndexKey(1)) )

oModel:SetRelation("MODEL_T3N",{ {"T3N_FILIAL","xFilial('T3N')"}, {"T3N_ID","T3B_ID"}, {"T3N_VERSAO","T3B_VERSAO"}},T3N->(IndexKey(1)))
oModel:SetRelation("MODEL_T3O",{ {"T3O_FILIAL","xFilial('T3O')"}, {"T3O_ID","T3B_ID"}, {"T3O_VERSAO","T3B_VERSAO"}, {"T3O_IDAMB","T3N_IDAMB"} },T3O->(IndexKey(1)))

oModel:GetModel("MODEL_T3B"):SetPrimaryKey({"T3B_IDTRAB"})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Paulo V.B. Santana
@since 11/11/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   	:= FWLoadModel( 'TAFA404' )
Local oStruT3B 	:= Nil
Local oStruT3Ba	:= Nil
Local oStruT3Bb	:= Nil
Local oStruT3C 	:= FWFormStruct( 2, 'T3C' )
Local oStruT3D 	:= FWFormStruct( 2, 'T3D' )
Local oStruT3N 	:= FWFormStruct( 2, 'T3N' )
Local oStruT3O 	:= FWFormStruct( 2, 'T3O' )
Local cCmpFil 	:= ""
Local oView   	:= FWFormView():New()

Local oModelT3B 	:= oModel:GetModel( 'MODEL_T3B' ) 

cCmpFil	:= "T3B_ID|T3B_IDTRAB|T3B_NOMTRB|T3B_DTINI|T3B_DTALT|T3B_DTFIN|T3B_DTINIA|T3B_DTALTA|T3B_DTFINA|"
oStruT3B	:= FwFormStruct(2,"T3B",{|x| AllTrim(x) + "|" $ cCmpFil } ) //Campos do folder Protocolo de Transmissão

cCmpFil	:= "T3B_PROTUL|"
oStruT3Ba	:= FwFormStruct(2,"T3B",{|x| AllTrim(x) + "|" $ cCmpFil } ) //Campos do folder Protocolo de Transmissão

If TafColumnPos("T3B_DTRANS")
	cCmpFil := "T3B_DINSIS|T3B_DTRANS|T3B_HTRANS|T3B_DTRECP|T3B_HRRECP|"
	oStruT3Bb	:= FwFormStruct(2,"T3B",{|x| AllTrim(x) + "|" $ cCmpFil } )
EndIf

oView:SetModel( oModel )

If FindFunction("TafAjustRecibo")
	TafAjustRecibo(oStruT3Ba,"T3B")
EndIf

oView:AddField("VIEW_T3B",oStruT3B,"MODEL_T3B")
oView:AddField("VIEW_T3Ba",oStruT3Ba,"MODEL_T3B")

If TafColumnPos("T3B_PROTUL")
	oView:EnableTitleView( 'VIEW_T3Ba', TafNmFolder("recibo",1) ) // "Recibo da última Transmissão"  
EndIf 
If TafColumnPos("T3B_DTRANS")
	oView:AddField("VIEW_T3Bb",oStruT3Bb,"MODEL_T3B")
	oView:EnableTitleView( 'VIEW_T3Bb', TafNmFolder("recibo",2) )
EndIf

oView:AddGrid("VIEW_T3C",oStruT3C,"MODEL_T3C")
oView:EnableTitleView("VIEW_T3C","Ambientes de Insalubridade e Periculosidade") //"Fatores de Risco Ambiente Insalub. Pericul."

oView:AddGrid("VIEW_T3D",oStruT3D,"MODEL_T3D")
oView:EnableTitleView("VIEW_T3D","Fatores de Risco Ambiente Insalub. Pericul.") //"Fatores de Risco Ambiente Insalub. Pericul."

oView:AddGrid("VIEW_T3N",oStruT3N,"MODEL_T3N")
oView:EnableTitleView("VIEW_T3N","Ambientes de Aposentadoria Especial") //"Ambientes de Aposentadoria Especial"

oView:AddGrid("VIEW_T3O",oStruT3O,"MODEL_T3O")
oView:EnableTitleView("VIEW_T3O","Fatores de Risco Aposentadoria Especial") //Fatores de Risco Aposentadoria Especial

oStruT3B:AddGroup ( 'GRP_TRABALHADOR', "Informações do Trabalhador"     , '' , 1 )  //"Informações do Trabalhador"
oStruT3B:AddGroup ( 'GRP_INSAPERIC'  , "Insalubridade/Periculosidade"   , '' , 1 )	//Inicio Insalubridade/Periculosidade
oStruT3B:AddGroup ( 'GRP_APOSESPEC'  , "Aposentadoria Especial"         , '' , 1 )	//"Informações Bancarias"

oStruT3B:SetProperty( 'T3B_ID'     , MVC_VIEW_GROUP_NUMBER , 'GRP_TRABALHADOR' )
oStruT3B:SetProperty( 'T3B_IDTRAB' , MVC_VIEW_GROUP_NUMBER , 'GRP_TRABALHADOR' )
oStruT3B:SetProperty( 'T3B_NOMTRB' , MVC_VIEW_GROUP_NUMBER , 'GRP_TRABALHADOR' )

oStruT3B:SetProperty( 'T3B_DTINI'  , MVC_VIEW_GROUP_NUMBER , 'GRP_INSAPERIC' )
oStruT3B:SetProperty( 'T3B_DTFIN'  , MVC_VIEW_GROUP_NUMBER , 'GRP_INSAPERIC' )
oStruT3B:SetProperty( 'T3B_DTALT'  , MVC_VIEW_GROUP_NUMBER , 'GRP_INSAPERIC' )

oStruT3B:SetProperty( 'T3B_DTINIA'  , MVC_VIEW_GROUP_NUMBER , 'GRP_APOSESPEC' )
oStruT3B:SetProperty( 'T3B_DTFINA'  , MVC_VIEW_GROUP_NUMBER , 'GRP_APOSESPEC' )
oStruT3B:SetProperty( 'T3B_DTALTA'  , MVC_VIEW_GROUP_NUMBER , 'GRP_APOSESPEC' )

/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
// ----- PAINEL SUPERIOR -----
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL") 

oView:AddSheet("FOLDER_PRINCIPAL","ABA01","Insalubridade Periculosidade e Aposentadoria Especial") //"Insalubridade Periculosidade e Aposentadoria Especial"

If FindFunction("TafNmFolder")
	oView:AddSheet('FOLDER_PRINCIPAL', "ABA02", TafNmFolder("recibo") )   //"Numero do Recibo"
Else
	oView:AddSheet("FOLDER_PRINCIPAL","ABA02","Protocolo de Transmissão") //"Protocolo de Transmissão"
EndIf 

oView:CreateHorizontalBox("PAINEL_T3B",26,,,"FOLDER_PRINCIPAL","ABA01") //T3B

If TafColumnPos("T3B_DTRANS")
	oView:CreateHorizontalBox("PAINEL_T3Ba",20,,,"FOLDER_PRINCIPAL","ABA02")
	oView:CreateHorizontalBox("PAINEL_T3Bb",80,,,"FOLDER_PRINCIPAL","ABA02")
Else
	oView:CreateHorizontalBox("PAINEL_T3Ba",100,,,"FOLDER_PRINCIPAL","ABA02") //T3Ba
EndIf

// ----- PAINEL INFERIOR -----
oView:CreateHorizontalBox("PAINEL_INFERIOR",74,,,"FOLDER_PRINCIPAL","ABA01")
oView:CreateFolder("FOLDER_INFERIOR","PAINEL_INFERIOR") 

oView:AddSheet("FOLDER_INFERIOR","ABAT3C","Ambientes de Insalubridade e Periculosidade") //"Lançamentos da Parte A do e-Lalur"
oView:CreateHorizontalBox("PAINEL_T3C",45,,,"FOLDER_INFERIOR","ABAT3C") //T3C
oView:CreateHorizontalBox("PAINEL_INFERIOR_T3C",55,,,"FOLDER_INFERIOR","ABAT3C")

oView:CreateFolder("FOLDER_T3C","PAINEL_INFERIOR_T3C")

oView:AddSheet("FOLDER_T3C","ABA_T3D","Fatores de Risco Ambiente Insalub. Pericul.") //"Fatores de Risco Ambiente Insalub. Pericul."
oView:CreateHorizontalBox("PAINEL_T3D",100,,,"FOLDER_T3C","ABA_T3D") //T3D

//ABAT3N
oView:AddSheet("FOLDER_INFERIOR","ABAT3N","Ambientes de Aposentadoria Especial") //"Lançamentos da Parte A do E-Lacs"
oView:CreateHorizontalBox("PAINEL_T3N",45,,,"FOLDER_INFERIOR","ABAT3N") //T3N
oView:CreateHorizontalBox("PAINEL_INFERIOR_T3N",55,,,"FOLDER_INFERIOR","ABAT3N")

oView:CreateFolder("FOLDER_T3N","PAINEL_INFERIOR_T3N")

oView:AddSheet("FOLDER_T3N","ABA_T3O","Fatores de Risco Aposentadoria Especial") //"Conta da Parte B do e-Lalur"
oView:CreateHorizontalBox("PAINEL_T3O",100,,,"FOLDER_T3N","ABA_T3O") //T3O

oView:SetOwnerView( 'VIEW_T3B', 'PAINEL_T3B' )   
oView:SetOwnerView( 'VIEW_T3Ba','PAINEL_T3Ba' )
If TafColumnPos("T3B_DTRANS")
	oView:SetOwnerView( 'VIEW_T3Bb','PAINEL_T3Bb' )
EndIf
oView:SetOwnerView( 'VIEW_T3C', 'PAINEL_T3C' )
oView:SetOwnerView( 'VIEW_T3D', 'PAINEL_T3D' )   
oView:SetOwnerView( 'VIEW_T3N', 'PAINEL_T3N' )
oView:SetOwnerView( 'VIEW_T3O', 'PAINEL_T3O' ) 

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If !lMenuDif .OR. ( FindFunction( "xTafExtmp" ) .And. xTafExtmp() )
	xFunRmFStr(@oStruT3B, 'T3B')
	xFunRmFStr(@oStruT3C, 'T3C')
	xFunRmFStr(@oStruT3D, 'T3D')
	xFunRmFStr(@oStruT3N, 'T3N')
	xFunRmFStr(@oStruT3O, 'T3O')
EndIf

oStruT3C:RemoveField("T3C_ID")
oStruT3D:RemoveField("T3D_ID")
oStruT3N:RemoveField("T3N_ID")
oStruT3O:RemoveField("T3O_ID")

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param  oModel -> Modelo de dados

@Return .T.

@Author Paulo V.B. Santana
@Since 11/11/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )
                       
Local cVerAnt   	:= ""  
Local cProtocolo	:= ""
Local cVersao   	:= "" 
Local cChvRegAnt	:= ""
Local cEvento		:= ""
Local cLogOpe		:= ""
Local cLogOpeAnt	:= ""

Local nY 		   	:= 0
Local nX		   	:= 0 
Local nOperation	:= oModel:GetOperation()
Local nT3B  	   	:= 0
Local nT3C  	   	:= 0
Local nT3D  	   	:= 0
Local nT3N  	   	:= 0
Local nT3O 	   	:= 0  
 
Local aGrava     := {}
Local aGravaT3C  := {}
Local aGravaT3D  := {}
Local aGravaT3N  := {}
Local aGravaT3O  := {}

Local oModelT3B  := Nil
Local oModelT3C  := Nil
Local oModelT3D  := Nil
Local oModelT3N  := Nil
Local oModelT3O  := Nil

Local lReturn    := .T.

//Controle se o evento é extemporâneo
lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )
                       
If Type("cOperEvnt") <> "U"
	If cOperEvnt == '1'
		cStatus := "R"
	ElseIf cOperEvnt == '2'
		cStatus := "A" 
	Else
		cStatus := "F" 
	Endif
Endif

Begin Transaction 
	
	If nOperation == MODEL_OPERATION_INSERT

	TafAjustID( "T3B", oModel)

		oModel:LoadValue( 'MODEL_T3B', 'T3B_VERSAO', xFunGetVer() ) 

		If Findfunction("TAFAltMan")
			TAFAltMan( 3 , 'Save' , oModel, 'MODEL_T3B', 'T3B_LOGOPE' , '2', '' )
		Endif

		FwFormCommit( oModel )  
		
	ElseIf nOperation == MODEL_OPERATION_UPDATE 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seek para posicionar no registro antes de realizar as validacoes,³
		//³visto que quando nao esta pocisionado nao eh possivel analisar   ³
		//³os campos nao usados como _STATUS                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    T3B->( DbSetOrder( 3 ) )
	    If lGoExtemp .OR. T3B->( MsSeek( xFilial( 'T3B' ) + FwFldGet('T3B_ID')+ '1' ) )
			    	    
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o registro ja foi transmitido³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    If T3B->T3B_STATUS == ( "4" ) 
				
				oModelT3B := oModel:GetModel( 'MODEL_T3B' ) 
				oModelT3C := oModel:GetModel( 'MODEL_T3C' ) 
				oModelT3D := oModel:GetModel( 'MODEL_T3D' )
				oModelT3N := oModel:GetModel( 'MODEL_T3N' ) 
				oModelT3O := oModel:GetModel( 'MODEL_T3O' )
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Busco a versao anterior do registro para gravacao do rastro³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cVerAnt    	:= oModelT3B:GetValue( "T3B_VERSAO" )				
				cProtocolo	:= oModelT3B:GetValue( "T3B_PROTUL" )				

				If TafColumnPos( "T3B_LOGOPE" )
					cLogOpeAnt := oModelT3B:GetValue( "T3B_LOGOPE" )
				endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Neste momento eu gravo as informacoes que foram carregadas na tela³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nT3B := 1 to Len( oModelT3B:aDataModel[ 1 ] )
					aAdd( aGrava, { oModelT3B:aDataModel[ 1, nT3B, 1 ], oModelT3B:aDataModel[ 1, nT3B, 2 ] } )
				Next
					       									
				// Model Tipo Amb. igual 1 - Referente Insalubridade e Periculosidade	
				For nT3C := 1 To oModel:GetModel( 'MODEL_T3C' ):Length()
					oModel:GetModel( 'MODEL_T3C' ):GoLine(nT3C)
					
					If !oModel:GetModel( 'MODEL_T3C' ):IsDeleted()
						aAdd (aGravaT3C,{oModelT3C:GetValue('T3C_IDAMB')} )						
					EndIf
					
					For nT3D := 1 To oModel:GetModel( 'MODEL_T3D' ):Length()
						oModel:GetModel( 'MODEL_T3D' ):GoLine(nT3D)
						
						If !oModel:GetModel( 'MODEL_T3D' ):IsDeleted() 
							aAdd (aGravaT3D, {oModelT3C:GetValue('T3C_IDAMB'),oModelT3D:GetValue('T3D_IDFATR')} )
						EndIf
					Next 
				Next 
				
				// Model Tipo Amb. igual 2 - Referente Aposentadoria Especial
				For nT3N := 1 To oModel:GetModel( 'MODEL_T3N' ):Length()
					oModel:GetModel( 'MODEL_T3N' ):GoLine(nT3N)
					
					If !oModel:GetModel( 'MODEL_T3N' ):IsDeleted()
						aAdd (aGravaT3N,{oModelT3N:GetValue('T3N_IDAMB')} )
					EndIf
					
					For nT3O := 1 To oModel:GetModel( 'MODEL_T3O' ):Length()
					oModel:GetModel( 'MODEL_T3O' ):GoLine(nT3O)
					
						If !oModel:GetModel( 'MODEL_T3O' ):IsDeleted()
							aAdd (aGravaT3O, {oModelT3N:GetValue('T3N_IDAMB'), oModelT3O:GetValue('T3O_IDFATR')} )
						EndIf
					Next 
				Next 
								
		      	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Seto o campo como Inativo e gravo a versao do novo registro³
				//³no registro anterior                                       ³
				//|                                                           |
				//|ATENCAO -> A alteracao destes campos deve sempre estar     |
				//|abaixo do Loop do For, pois devem substituir as informacoes|
				//|que foram armazenadas no Loop acima                        |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FAltRegAnt( 'T3B', '2' )	
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Neste momento eu preciso setar a operacao do model³
				//³como Inclusao                                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oModel:DeActivate()
				oModel:SetOperation( 3 ) 	
				oModel:Activate()		
														
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Neste momento eu realizo a inclusao do novo registro ja³
				//³contemplando as informacoes alteradas pelo usuario     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nT3B := 1 to Len( aGrava )
					oModel:LoadValue( "MODEL_T3B", aGrava[ nT3B, 1 ], aGrava[ nT3B, 2 ] )
				Next nT3B

				//Necessário Abaixo do For Nao Retirar
				If Findfunction("TAFAltMan")
					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T3B', 'T3B_LOGOPE' , '' , cLogOpeAnt )
				EndIf

				// Model Tipo Amb. igual 1 - Referente Insalubridade e Periculosidade	
				nT3C := 1	
				For nX := 1 To Len( aGravaT3C )
					oModel:GetModel( 'MODEL_T3C' ):LVALID	:= .T.
					
					If nT3C > 1
						oModel:GetModel( 'MODEL_T3C' ):AddLine()
					EndIf

					oModel:LoadValue( "MODEL_T3C", "T3C_IDAMB" ,aGravaT3C[nX][1])
					
					nT3D := 1	
		    		For nY := 1 To Len( aGravaT3D )
						
						If aGravaT3D[nY][1] == aGravaT3C[nX][1]
							oModel:GetModel( 'MODEL_T3D' ):LVALID	:= .T.
								
							If nT3D > 1
								oModel:GetModel( 'MODEL_T3D' ):AddLine()
							EndIf
					
							oModel:LoadValue( "MODEL_T3D", "T3D_IDFATR", aGravaT3D[nY][2])
							nT3D ++
						Endif
					Next 
		    	   nT3C ++
				Next	
				
				nT3N := 1
				// Model Tipo Amb. igual 2 - Referente Aposentadoria Especial
				For nX := 1 To Len( aGravaT3N )
					If nT3N > 1
						oModel:GetModel( 'MODEL_T3N' ):AddLine()
					EndIf
					oModel:GetModel( 'MODEL_T3N' ):LVALID	:= .T.
					
					oModel:LoadValue( "MODEL_T3N", "T3N_IDAMB", aGravaT3N[nX][1])
					
					nT3O := 1	
		    		For nY := 1 To Len( aGravaT3O )
						If aGravaT3N[nX][1] == aGravaT3O[nY][1]
							If nT3O > 1
								oModel:GetModel( 'MODEL_T3O' ):AddLine()
							EndIf
							oModel:GetModel( 'MODEL_T3O' ):LVALID	:= .T.
												
							oModel:LoadValue( "MODEL_T3O", "T3O_IDFATR",aGravaT3O[nY][2])
							nT3O++	
						Endif
							
		    	   Next 
		    	   nT3N ++
		    	   oModel:GetModel( 'MODEL_T3N' ):LVALID	:= .T.
				Next
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Busco a versao que sera gravada³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cVersao := xFunGetVer()		 
					                                   
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿		
				//|ATENCAO -> A alteracao destes campos deve sempre estar     |
				//|abaixo do Loop do For, pois devem substituir as informacoes|
				//|que foram armazenadas no Loop acima                        |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		                                                                      				         
				oModel:LoadValue( 'MODEL_T3B', 'T3B_VERSAO', cVersao )  
				oModel:LoadValue( 'MODEL_T3B', 'T3B_VERANT', cVerAnt )									          				    
				oModel:LoadValue( 'MODEL_T3B', 'T3B_PROTPN', cProtocolo )									          						
				oModel:LoadValue( 'MODEL_T3B', 'T3B_PROTUL', "" )									          				
				
				// Tratamento para limpar o ID unico do xml
				cAliasPai := "T3B"
				If TAFColumnPos( cAliasPai+"_XMLID" )
					oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
				EndIf
					
			Elseif	T3B->T3B_STATUS == ( "2" )
				TAFMsgVldOp( oModel, "2" )
				lReturn := .F.
			
			ElseIf T3B->T3B_STATUS == "6"
				TAFMsgVldOp( oModel, "6" )//"Registro não pode ser alterado. Aguardando processo de transmissão do evento de Exclusão S-3000"
				lReturn := .F.
								
			ElseIf T3B->T3B_STATUS == "7"
				lReturn := .F.
				TAFMsgVldOp( oModel, "7" )//"Registro não pode ser alterado, pois o evento de exclusão já se encontra na base do RET"
			
			Else
				If TafColumnPos( "T3B_LOGOPE" )
					cLogOpeAnt := T3B->T3B_LOGOPE
				endif
				TAFAltStat( 'T3B', " " )
			Endif
				
			If lReturn
				If T3B->T3B_STATUS ==  "4" .And. !lGoExtemp
					oModel:LoadValue( 'MODEL_T3B', 'T3B_EVENTO', cStatus )
				EndIf
				
				//Gravo alteração para o Extemporâneo
				If lGoExtemp
					TafGrvExt( oModel, 'MODEL_T3B', 'T3B' )							
				Endif

				If Findfunction("TAFAltMan")
					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T3B', 'T3B_LOGOPE' , '' , cLogOpeAnt )
				EndIf

				FwFormCommit( oModel )
			EndIf
			
		EndIf
	
	ElseIf nOperation == MODEL_OPERATION_DELETE 
	
		cChvRegAnt := T3B->(T3B_ID + T3B_VERANT)              
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³No caso de um evento de Exclusao de um registro com status 'Excluido' deve-se³
		//³perguntar ao usuario se ele realmente deseja realizar a inclusao.            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
													
		If !Empty( cChvRegAnt ) 
			TAFAltStat( 'T3B', " " )
			FwFormCommit( oModel )				
			If nOperation == MODEL_OPERATION_DELETE
				If T3B->T3B_EVENTO == "A" .Or. T3B->T3B_EVENTO == "E"
					TAFRastro( 'T3B', 1, cChvRegAnt, .T. , , IIF(Type("oBrw") == "U", Nil, oBrw) )
				EndIf
			EndIf
		Else
			oModel:DeActivate()
			oModel:SetOperation( 5 ) 	
			oModel:Activate()
			FwFormCommit( oModel )
		EndIf
		
	EndIf				
			
End Transaction 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF404Xml
Funcao de geracao do XML para atender o registro S-2241
Quando a rotina for chamada o registro deve estar posicionado

@Param:

@Return:
cXml - Estrutura do Xml do Layout S-2241
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composição da chave ID do XML

@author Paulo Sérgio V.B. Santana
@since 13/11/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF404Xml(cAlias,nRecno,nOpc,lJob,lRemEmp,cSeqXml)

Local cXmlFatRis	:= ""
Local cXml			:= ""
Local cLayout		:= "2241"
Local cReg			:= "InsApo"
Local cXmlVinc	:= ""
Local cFechaTag	:= ""
Local cSelect		:= ""
Local cTpEvtAnt	:= ""
Local cAlias		:= GetNextAlias()
Local lXmlVLd	:= IIF(FindFunction('TafXmlVLD'),TafXmlVLD('TAF404XML'),.T.)

Default cSeqXml := ""

If lXmlVLd
	If T3B->T3B_EVENTO == "R"
		cSelect =  "SELECT T3B_EVENTO FROM "  + RetSqlName("T3B") +" WHERE T3B_FILIAL = '" + xFilial("T3B")
		cSelect += "' AND T3B_ID = '" + T3B->T3B_ID + "' AND T3B_VERSAO = '"+ T3B->T3B_VERANT + "' AND D_E_L_E_T_ <> '*'"
		
		dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cSelect ) , cAlias)
		(cAlias)->(dbGoTop())

		cTpEvtAnt := (cAlias)->T3B_EVENTO
	EndIf

	T3D->( DbSetOrder( 1 ) ) 
	T3C->( DbSetOrder( 1 ) ) 
	T3N->( DbSetOrder( 1 ) ) 
	T3O->( DbSetOrder( 1 ) )

	C9V->( DbSetOrder( 2 ) )
	C9V->( MsSeek ( xFilial("C9V")+T3B->T3B_IDTRAB + "1") )   
		
	cXmlVinc +=		"<ideVinculo>"
	cXmlVinc += 			xTafTag("cpfTrab",C9V->C9V_CPF )
	cXmlVinc +=			xTafTag("nisTrab",C9V->C9V_NIS,, .T.)
	cXmlVinc +=			xTafTag("matricula",C9V->C9V_MATRIC,,.T.)		
	cXmlVinc +=		"</ideVinculo>"

	//===============================
	//Insalubridade e Perículosidade
	//===============================
	If  T3B->T3B_EVENTO == 'I' .OR. (T3B->T3B_EVENTO == 'R' .AND. cTpEvtAnt == 'I') 
		If !Empty(T3B->T3B_DTINI)
			cXml 		+=		"<insalPeric>"
			cXml 		+=			"<iniInsalPeric>"
			cXml 		+=				xTafTag("dtIniCondicao",T3B->T3B_DTINI)			
			cFechaTag	:=			"</iniInsalPeric>"
		EndIf
	Elseif T3B->T3B_EVENTO =='A' .OR. (T3B->T3B_EVENTO == 'R' .AND. cTpEvtAnt == 'A')
		If !Empty(T3B->T3B_DTALT)
			cXml 		+=		"<insalPeric>"
			cXml 		+=			"<altInsalPeric>"
			cXml 		+=				xTafTag("dtAltCondicao",T3B->T3B_DTALT)			
			cFechaTag	:=			"</altInsalPeric>"
		EndIf	
	ElseIf T3B->T3B_EVENTO =='F' .OR. (T3B->T3B_EVENTO == 'R' .AND. cTpEvtAnt == 'R')
		If !Empty(T3B->T3B_DTFIN)
			cXml 		+=		"<insalPeric>"
			cXml 		+=			"<fimInsalPeric>"
			cXml 		+=				xTafTag("dtFimCondicao",T3B->T3B_DTFIN)			
			cFechaTag	:=			"</fimInsalPeric>"
		EndIf
	Endif

	//Não permito a geração dos grupos de 'ambiente (T3C)' e 'fatores de risco(T3D)', caso a data respectiva ao evento não estiver preenchida 		
	If T3C->( MsSeek ( xFilial("T3C") + T3B->T3B_ID + T3B->T3B_VERSAO ) )
		While T3C->(!Eof()) .AND. T3C->( T3C_FILIAL + T3C_ID + T3C_VERSAO ) == T3B->( T3B_FILIAL + T3B_ID + T3B_VERSAO ) .And. !Empty(cFechaTag)
				If 	T3B->T3B_EVENTO <> "F"	.OR. (T3B->T3B_EVENTO == 'R' .AND. cTpEvtAnt $ 'I|A')
				
					If T3D->( MsSeek ( xFilial("T3D") + T3C->( T3C_ID + T3C_VERSAO + T3C_IDAMB )  ) )
				
						While 	T3D->(!Eof()) .AND. T3C->( T3C_ID + T3C_VERSAO + T3C_IDAMB ) == T3D->( T3D_ID + T3D_VERSAO + T3D_IDAMB )	 
							cXmlFatRis   +=		"<fatRisco>"
							cXmlFatRis   +=			xTafTag("codFatRis",Posicione("T3E",1,xFilial("T3E")+T3D->T3D_IDFATR,"T3E_CODIGO"))	
							cXmlFatRis   +=		"</fatRisco>"
							T3D->(dbSkip())
						Enddo
				
					Endif
				
					xTafTagGroup("infoAmb",{{"codAmb"	,Alltrim(Posicione("T04",3,xFilial("T04")+T3C->T3C_IDAMB+"1","T04_CODIGO")),,.F.}};
										, @cXml,{{"fatRisco",cXmlFatRis,1}})	
			
					cXmlFatRis := ""
			
				Else
				
					cXml   +=		"<infoAmb>"		
					cXml   +=			xTafTag("codAmb",Alltrim(Posicione("T04",3,xFilial("T04")+T3C->T3C_IDAMB+"1","T04_CODIGO")))
					cXml 	+=		"</infoAmb>"
					
				Endif
				
			T3C->(dbSkip())	
		Enddo
	EndIf

	If !Empty(cFechaTag)
		cXml   +=   		cFechaTag
		cXml 	+=		"</insalPeric>"	
	Endif

	//Limpo a variável para utilizar novamente na validação da geração de aposentadoria especial
	cFechaTag 	:= ""
	//===============================
	//Aposentadoria Especial
	//===============================

	If  T3B->T3B_EVENTO == 'I' .OR. (T3B->T3B_EVENTO == 'R' .AND. cTpEvtAnt == 'I')
		If !Empty(T3B->T3B_DTINIA)
			cXml 		+=		"<aposentEsp>"
			cXml 		+=			"<iniAposentEsp>"
			cXml		+=			xTafTag("dtIniCondicao",T3B->T3B_DTINIA)			
			cFechaTag	:=		"</iniAposentEsp>"
		EndIf		
	Elseif T3B->T3B_EVENTO =='A' .OR. (T3B->T3B_EVENTO == 'R' .AND. cTpEvtAnt == 'A')
		If !Empty(T3B->T3B_DTALTA)
			cXml 		+=		"<altAposentEsp>"
			cXml 		+=			xTafTag("dtAltCondicao",T3B->T3B_DTALTA)			
			cFechaTag	:=		"</altAposentEsp>"
		EndIf		
	ElseIf T3B->T3B_EVENTO =='F' .OR. (T3B->T3B_EVENTO == 'R' .AND. cTpEvtAnt == 'F')
		If !Empty(T3B->T3B_DTFINA)
			cXml 		+=		"<fimAposentEsp>" 
			cXml 		+=			xTafTag("dtFimCondicao",T3B->T3B_DTFINA)			
			cFechaTag	:=		"</fimAposentEsp>"
		EndIf
	Endif

	If T3N->( MsSeek ( xFilial("T3N") + T3B->T3B_ID + T3B->T3B_VERSAO ) )	
		//Não permito a geração dos grupos de 'ambiente (T3N)' e 'fatores de risco(T3O)', caso a data respectiva ao evento não estiver preenchida 	
		While T3N->(!Eof()) .AND. T3N->( T3N_FILIAL + T3N_ID + T3N_VERSAO ) == T3B->( T3B_FILIAL + T3B_ID + T3B_VERSAO ) .And. !Empty(cFechaTag)
			
			If 	T3B->T3B_EVENTO <> "F"	.OR. (T3B->T3B_EVENTO == 'R' .AND. cTpEvtAnt $ 'I|A')
				If T3O->( MsSeek ( xFilial("T3O") + T3N->( T3N_ID + T3N_VERSAO + T3N_IDAMB )  ) )
					While 	T3O->(!Eof()) .AND. T3O->( T3O_ID + T3O_VERSAO + T3O_IDAMB ) == T3N->( T3N_ID + T3N_VERSAO + T3N_IDAMB )	 
						cXmlFatRis   +=		"<fatRisco>"
						cXmlFatRis   +=			xTafTag("codFatRis",Posicione("T3E",1,xFilial("T3E")+T3O->T3O_IDFATR,"T3E_CODIGO"))	
						cXmlFatRis   +=		"</fatRisco>"
						T3O->(dbSkip())
					Enddo
				Endif
						
				xTafTagGroup("infoAmb",{{"codAmb"	,Alltrim(Posicione("T04",3,xFilial("T04")+T3N->T3N_IDAMB+"1","T04_CODIGO")),,.F.}};
										, @cXml,{{"fatRisco",cXmlFatRis,1}})			
						
				cXmlFatRis := ""
				
			Else
			
				cXml   +=		"<infoAmb>"		
				cXml   +=			xTafTag("codAmb",Alltrim(Posicione("T04",3,xFilial("T04")+T3N->T3N_IDAMB+"1","T04_CODIGO")))
				cXml   +=		"</infoAmb>"		
				
			Endif
						
			
			T3N->(dbSkip())		
		Enddo
	Endif

	If !Empty(cFechaTag)
		cXml   +=   		cFechaTag
		cXml   +=    "</aposentEsp>"
	Endif


	cXml := cXmlVinc + cXml
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Estrutura do cabecalho³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cXml := xTafCabXml(cXml,"T3B", cLayout,cReg,,cSeqXml)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa gravacao do registro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lJob
		xTafGerXml(cXml,cLayout)
	EndIf
EndIf
Return(cXml)
//-------------------------------------------------------------------
/*/{Protheus.doc} TAF404Grv    
Funcao de gravacao para atender o registro S-2241

@parametros
cLayout - Nome do Layout que esta sendo enviado, existem situacoes onde o mesmo fonte
          alimenta mais de um regsitro do E-Social, para estes casos serao necessarios
          tratamentos de acordo com o layout que esta sendo enviado.
nOpc   -  Opcao a ser realizada ( 3 = Inclusao, 4 = Alteracao, 5 = Exclusao )
cFilEv -  Filial do ERP para onde as informacoes deverao ser importadas
oXML   -  Objeto com as informacoes a serem manutenidas ( Outras Integracoes )  

@Return    
lRet    - Variavel que indica se a importacao foi realizada, ou seja, se as 
		  informacoes foram gravadas no banco de dados
aIncons - Array com as inconsistencias encontradas durante a importacao 

@author Fabio V. Santana
@since 07/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF404Grv( cLayout, nOpc, cFilEv, oXML, cOwner , cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID  )

Local cCmpsNoUpd		:= "|T3B_FILIAL|T3B_ID|T3B_VERSAO|T3B_VERANT|T3B_PROTPN|T3B_EVENTO|T3B_STATUS|T3B_ATIVO|"
Local cCabec   		:= "/eSocial/evtInsApo/ideVinculo"
Local cCabec02 		:= "/eSocial/evtInsApo/insalPeric"
Local cCabec03 		:= "/eSocial/evtInsApo/aposentEsp"
Local cT3CPath		:= ""
Local cT3DPath		:= ""
Local cT3NPath		:= ""
Local cT3OPath		:= ""
Local cEvenAtivo		:= ""
Local cIdverAnt		:= ""
Local cChaveT3D		:= ""
Local cChaveT3O		:= ""
Local cTagRecibo		:= "/eSocial/evtInsApo/ideEvento/nrRecibo"
Local cTagInicio		:= cCabec02 + "/iniInsalPeric/dtIniCondicao"
Local cTagAlt			:= cCabec02 + "/altInsalPeric/dtAltCondicao"
Local cTagFim			:= cCabec02 + "/fimInsalPeric/dtFimCondicao"
Local cTagInicioAp	:= cCabec03 + "/iniAposentEsp/dtIniCondicao"
Local cTagAltAp		:= cCabec03 + "/altAposentEsp/dtAltCondicao"
Local cTagFimAp		:= cCabec03 + "/fimAposentEsp/dtFimCondicao"
Local cMensagem		:= ""
Local cEnter			:= Chr(13) + Chr(10) 
Local cAmbTrab		:= ""
Local cIdFunc			:= ""
Local cDtIniPeric		:= ""
Local cInconMsg		:= ""
Local cEvento			:= ""
Local cIdVersao		:= ""
Local cErro 			:= "ERRO15"
Local cErro1 			:= "ERRO16"
Local cErro2			:= "ERRO17"
Local cCodEvent  		:= Posicione("C8E",2,xFilial("C8E")+"S-"+cLayout,"C8E->C8E_ID")

Local nlI			:= 0  
Local nT3C			:= 1
Local nT3D			:= 1
Local nT3N			:= 1
Local nT3O			:= 1
Local nJ			:= 0
Local nSeqErrGrv	:= 0

Local aIncons		:= {} 			
Local aRules		:= {} 
Local aChave  	:= {}
Local aGravaT3C	:= {}
Local aGravaT3D	:= {}
Local aGravaT3N	:= {}
Local aGravaT3O	:= {}

Local lTransmit	:= .F.
Local lRet			:= .F. 	

Local cLogOpeAnt 	:= ""

Local oModel		:= Nil 
Local oModelT3B 	:= Nil

Private lVldModel	:= .T. //Caso a chamada seja via integracao seto a variavel de controle de validacao como .T.
Private oDados   	:= oXML

Default cLayout 		:= ""
Default nOpc     		:= 1
Default cFilEv   		:= ""
Default oXML     		:= Nil
Default cOwner			:= ""
Default cFilTran		:=	""
Default cPredeces		:=	""
Default nTafRecno		:=	0
Default cComplem		:=	""
Default cGrpTran		:=	""
Default cEmpOriGrp		:=	""
Default cFilOriGrp		:=	""
Default cXmlID			:=	""


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chave do registro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
cIdFunc		:= FGetIdInt( "cpfTrab", "matricula", cCabec +"/cpfTrab", cCabec + "/matricula")
cDtIniPeric	:= Alltrim( FTafGetVal( cCabec02 + "/iniInsalPeric/dtIniCondicao", 'C', .F., @aIncons, .F., '', '' ) )
cDtIniPeric	:= Strtran(cDtIniPeric,"-","")
cDtIniApos 	:= Alltrim( FTafGetVal( cCabec03 + "/iniAposentEsp/dtIniCondicao", 'C', .F., @aIncons, .F., '', '' ) )
cDtIniApos 	:= Strtran(cDtIniApos,"-","")

Aadd( aChave, { "C", "T3B_IDTRAB"  ,cIdFunc	  	, .T.} )  	  
Aadd( aChave, { "C", "T3B_DTINI"   ,cDtIniPeric , .T.} )
Aadd( aChave, { "C", "T3B_DTINIA"  ,cDtIniApos	, .T.} )

cChave	:= Padr( cIdFunc, Tamsx3( aChave[ 1, 2 ])[1] ) + Padr( cDtIniPeric, Tamsx3( aChave[ 2, 2 ])[1]) + Padr( cDtIniApos, Tamsx3( aChave[ 3, 2 ])[1] )

//Verifica se o evento ja existe na base
("T3B")->( DbSetOrder( 2 ) )
If ("T3B")->( MsSeek( FTafGetFil( cFilEv , @aIncons , "T3B" ) + cChave + '1' ) )
	nOpc 		:= 4
	lTransmit 	:= IIF(T3B->T3B_STATUS == '4',.T.,.F.) 
	EvenAtivo	:= T3B->T3B_EVENTO
	cIdverAnt	:= T3B->( T3B_ID + T3B_VERSAO )
EndIf

//Validação do tipo de Evento
If lTransmit 
	If (oDados:XPathHasNode( cTagInicio ) .Or. oDados:XPathHasNode( cTagInicioAp ))  .AND. (!oDados:XPathHasNode( cTagAlt  ) .AND. !oDados:XPathHasNode( cTagFim  ))
		If EvenAtivo == "I" 
			cEvento := "R"		
		Else
			//Não é possível integrar um evento de retificação, referente ao Início do Afastamento, quando houver uma Alteração ou Finalização ativa. 
			Aadd( aIncons, cErro1 )
		Endif
	Endif
	
	If oDados:XPathHasNode( cTagAlt ) .Or. oDados:XPathHasNode( cTagAltAp ) 
		If EvenAtivo $ "I|A"
			cEvento := IIf(EvenAtivo == "A","R","A")
		Else
			Aadd( aIncons, cErro2 )//"Não é possível integrar um evento de Alteração quando houver uma Finalização ativa. 
		Endif
	Endif
	
	If oDados:XPathHasNode( cTagFim ) .Or. oDados:XPathHasNode( cTagFimAp ) 
		If EvenAtivo $ "I|F"
			cEvento := IIf(EvenAtivo == "F","R","F")
		Else
			Aadd( aIncons, cErro ) //"Não é permitido a integração deste evento, enquanto houver outra alteração pendente de transmissão."
		EndIf
	Endif	
	
Else
	If oDados:XPathHasNode( cTagInicio ) .Or. oDados:XPathHasNode( cTagInicioAp )
		cEvento := "I"
	ElseIf oDados:XPathHasNode( cTagAlt ) .Or. oDados:XPathHasNode( cTagAltAp )
		cEvento := "A"
	Elseif oDados:XPathHasNode( cTagFim ) .Or. oDados:XPathHasNode( cTagFimAp )
		cEvento := "F"
	Endif
Endif

If Empty(aIncons) 
	
	Begin Transaction	
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao para validar se a operacao desejada pode ser realizada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If FTafVldOpe( 'T3B', 2, @nOpc, cFilEv, @aIncons, aChave, @oModel, 'TAFA404', cCmpsNoUpd )		    	      				     		    	      	    		    		    		    		    																					

			If TafColumnPos( "T3B_LOGOPE" )
				cLogOpeAnt := T3B->T3B_LOGOPE
			endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando se tratar de uma Exclusao direta apenas preciso realizar ³
			//³o Commit(), nao eh necessaria nenhuma manutencao nas informacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOpc <> 5 
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Carrego array com os campos De/Para de gravacao das informacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aRules := TAF404Rul(@cInconMsg, @nSeqErrGrv, lTransmit, @oModel, cCabec, cCabec02, cCabec03, cCodEvent, cOwner )	
				
				oModel:LoadValue( "MODEL_T3B", "T3B_FILIAL", T3B->T3B_FILIAL )
				oModel:LoadValue( "MODEL_T3B", "T3B_EVENTO", cEvento)	

				If TAFColumnPos( "T3B_XMLID" )
					oModel:LoadValue( "MODEL_T3B", "T3B_XMLID", cXmlID )
				EndIf
		    		
				nT3N 		:= 1
				nT3C 		:= 1
					
				If cEvento $ ("R|I")
					cT3CPath	:= cCabec02 + "/iniInsalPeric/infoAmb[" + cValToChar(nT3C)+ "]"
					cT3NPath	:= cCabec03 + "/iniAposentEsp/infoAmb[" + cValToChar(nT3N)+ "]"
				Elseif cEvento == "A"
					cT3CPath	:= cCabec02 + "/altInsalPeric/infoAmb[" + cValToChar(nT3C)+ "]"
					cT3NPath	:= cCabec03 + "/altAposentEsp/infoAmb[" + cValToChar(nT3N)+ "]"
				Elseif cEvento == "F"
					cT3CPath	:= cCabec02 + "/fimInsalPeric/infoAmb[" + cValToChar(nT3C)+ "]"
					cT3NPath	:= cCabec03 + "/fimAposentEsp/infoAmb[" + cValToChar(nT3N)+ "]"	
				Endif	
				
				oModelT3B := oModel:GetModel( 'MODEL_T3B' )
				cIdVersao := oModelT3B:GetValue( "T3B_ID" ) + oModelT3B:GetValue( "T3B_VERSAO" )
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Rodo o aRules para gravar as informacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nlI := 1 To Len( aRules )                 					
				 	oModel:LoadValue( "MODEL_T3B", aRules[ nlI, 01 ], FTafGetVal( aRules[ nlI, 02 ], aRules[nlI, 03], aRules[nlI, 04], @aIncons, .F. ) )
				Next

				If Findfunction("TAFAltMan")
					if nOpc == 3
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T3B', 'T3B_LOGOPE' , '1', '' )
					elseif nOpc == 4
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T3B', 'T3B_LOGOPE' , '', cLogOpeAnt )
					EndIf
				EndIf
				
				//=========================================================================
				//Quando se tratar de uma retificação de Evento já transmitido, em que	    ||
				//o arquivo retificador possua apenas um dos grupos, o novo registro,deve	||
				//ser preenchido com as informações do registro anterior na posição do 	    ||
				//grupo não informado.														||  
				//=========================================================================
				If nOpc == 4 .And. lTransmit 
				
					//Grupo de Insalubridade e Periculosidade 
					IF !oDados:XPathHasNode( cT3CPath ) .OR. cEvento == "F"   
						dbSelectArea("T3C")
						T3C->( dbSetOrder( 1 ) )
						If T3C->( msSeek( FTafGetFil( cFilEv , @aIncons , "T3C" ) + cIdverAnt ) )
							While T3C->( !Eof() ) .And. cIdverAnt == T3C->( T3C_ID + T3C_VERSAO )
								aAdd (aGravaT3C,{T3C->T3C_IDAMB} )
							
								cChaveT3D := T3C->( T3C_ID + T3C_VERSAO + T3C_IDAMB )
								T3D->( dbSetorder( 1 ) )
								If T3D->( msSeek( FTafGetFil( cFilEv , @aIncons , "T3D" ) + cChaveT3D ) )
									While T3D->(!Eof()) .And. T3D->( T3D_ID + T3D_VERSAO + T3D_IDAMB ) == cChaveT3D
										aAdd (aGravaT3D,{T3C->T3C_IDAMB, T3D->T3D_IDFATR} )
										T3D->( dbSkip() )
									Enddo
								Endif
								T3C->( dbSkip() )
							Enddo
						Endif
					Endif
					
					//Grupo de Aposentadoria Especial
					IF !oDados:XPathHasNode( cT3NPath ) .OR. cEvento == "F" 
						dbSelectArea("T3N")
						T3N->( dbSetOrder( 1 ) )
						If T3N->( msSeek( FTafGetFil( cFilEv , @aIncons , "T3N" ) + cIdverAnt ) )
							While T3N->( !Eof() ) .And. cIdverAnt == T3N->( T3N_ID + T3N_VERSAO )
								aAdd (aGravaT3N,{T3N->T3N_IDAMB} )
								cChaveT3O := T3N->( T3N_ID + T3N_VERSAO + T3N_IDAMB )
								T3O->( dbSetorder( 1 ) )
								If T3O->( msSeek( FTafGetFil( cFilEv , @aIncons , "T3O" ) + cChaveT3O ) )
									While T3O->(!Eof()) .And. cChaveT3O == T3O->( T3O_ID + T3O_VERSAO + T3O_IDAMB )
										aAdd (aGravaT3O,{T3N->T3N_IDAMB, T3O->T3O_IDFATR} )
										T3O->( dbSkip() )
									Enddo
								Endif
								T3N->( dbSkip() )
							Enddo
						Endif
					Endif
				EndIF 

				//========================================================================================
				//Caso esteja integrando uma finalização para o evento que já existe na base o tratamento
				//será outro devido a possibilidade do usuário finalizar parcialmente os ambientes
				//relacionados ao trabalhador.
				//========================================================================================
				If !(cEvento == "F" .And. lTransmit)
					
					If !Empty(aGravaT3C) .or. !Empty(aGravaT3N)
						//Carrego as informações do registro anterior gravada nos arrays, para depois efetuar as alterações.
						Taf404Carr(aGravaT3C,aGravaT3D,aGravaT3N,aGravaT3O,@oModel)	
					Endif  
							
					/*======================================
					||Integração Insalub/Pericul. - INICIO||				
					||====================================*/
					If nOpc == 4 
						For NJ := 1 to oModel:GetModel( 'MODEL_T3C' ):Length()
							oModel:GetModel( 'MODEL_T3C' ):GoLine(NJ)
							oModel:GetModel( 'MODEL_T3C' ):DeleteLine()
						Next NJ
					EndIf
						
					nT3C := 1
					While oDados:XPathHasNode( cT3CPath )
							
						oModel:GetModel( "MODEL_T3C" ):lValid:= .T.
						If nOpc == 4 .or. nT3C > 1
							oModel:GetModel( "MODEL_T3C" ):AddLine()
						EndIf
						cAmbTrab := FGetIdInt( "codAmb",, cT3CPath + "/codAmb",,,,@cInconMsg, @nSeqErrGrv )	
						
			 			oModel:LoadValue( "MODEL_T3C", "T3C_IDAMB" , cAmbTrab )
			 				
			 			nT3D 		:= 1
						cT3DPath	:= cT3CPath + "/fatRisco[" + cValToChar(nT3D)+ "]"
							
						If nOpc == 4
							For NJ := 1 to oModel:GetModel( 'MODEL_T3D' ):Length()
								oModel:GetModel( 'MODEL_T3D' ):GoLine(NJ)
								oModel:GetModel( 'MODEL_T3D' ):DeleteLine()
							Next NJ
						EndIf
												
						nT3D := 1		
							
				 		While oDados:XPathHasNode( cT3DPath ) 
							If nOpc == 4 .or. nT3D > 1
								oModel:GetModel( "MODEL_T3D" ):lValid:= .T.
								oModel:GetModel( "MODEL_T3D" ):AddLine()
							EndIf
			 				oModel:LoadValue( "MODEL_T3D", "T3D_IDFATR", FGetIdInt( "codFatRis",, cT3DPath + "/codFatRis",,,,@cInconMsg, @nSeqErrGrv ) )
				 			nT3D ++
				 			cT3DPath	:= cT3CPath + "/fatRisco[" + cValToChar(nT3D)+ "]"
						EndDo
								
						nT3C ++
											
						If cEvento $ ("R|I")
							cT3CPath	:= cCabec02 + "/iniInsalPeric/infoAmb[" + cValToChar(nT3C)+ "]"
						Elseif cEvento == "A"
							cT3CPath	:= cCabec02 + "/altInsalPeric/infoAmb[" + cValToChar(nT3C)+ "]"
						Elseif cEvento == "F"
							cT3CPath	:= cCabec02 + "/fimInsalPeric/infoAmb[" + cValToChar(nT3C)+ "]"
						Endif	
							
					Enddo

					/*======================================
					||Integração Insalub/Pericul. - FIM	||				
					||====================================*/
					
					/*======================================
					||Integração Aposent.Especial - INICIO||				
					||====================================*/
					//Rodo o XML parseado para gravar as novas informacoes no GRID ( Cadastro de Info Ambiente Insal./Peric. )
					If nOpc == 4
						For NJ := 1 to oModel:GetModel( 'MODEL_T3N' ):Length()
							oModel:GetModel( 'MODEL_T3N' ):GoLine(nT3N)
							oModel:GetModel( 'MODEL_T3N' ):DeleteLine()
						Next NJ
					EndIf
					
					nT3N := 1
					While oDados:XPathHasNode( cT3NPath )
						
						oModel:GetModel( "MODEL_T3N" ):lValid:= .T.
						If nOpc == 4 .or. nT3N > 1
							oModel:GetModel( "MODEL_T3N" ):AddLine()
						EndIf
						
						cAmbTrab := FGetIdInt( "codAmb",, cT3NPath + "/codAmb",,,,@cInconMsg, @nSeqErrGrv )	
		 				oModel:LoadValue( "MODEL_T3N", "T3N_IDAMB" , cAmbTrab  )
			 			
						nT3O 		:= 1
						cT3OPath	:= cT3NPath + "/fatRisco[" + cValToChar(nT3O)+ "]"
						
						If nOpc == 4
							For NJ := 1 to oModel:GetModel( 'MODEL_T3O' ):Length()
								oModel:GetModel( 'MODEL_T3O' ):GoLine(nT3O)
								oModel:GetModel( 'MODEL_T3O' ):DeleteLine()
							Next NJ
						EndIf
															
		 				While oDados:XPathHasNode( cT3OPath )
							If nOpc == 4 .or. nT3O > 1
								oModel:GetModel( "MODEL_T3O" ):lValid:= .T.
								oModel:GetModel( "MODEL_T3O" ):AddLine()
							EndIf
							
		 					oModel:LoadValue( "MODEL_T3O", "T3O_IDFATR", FGetIdInt( "codFatRis",, cT3OPath + "/codFatRis",,,,@cInconMsg, @nSeqErrGrv ) )
		 					
		 					nT3O ++
		 					cT3OPath	:= cT3NPath + "/fatRisco[" + cValToChar(nT3O)+ "]"
							
						EndDo
						
						nT3N ++
						If cEvento $ ("R|I")
							cT3NPath	:= cCabec03 + "/iniAposentEsp/infoAmb[" + cValToChar(nT3N)+ "]"
						Elseif cEvento == "A"
							cT3NPath	:= cCabec03 + "/altAposentEsp/infoAmb[" + cValToChar(nT3N)+ "]"
						Elseif cEvento == "F"
							cT3NPath	:= cCabec03 + "/fimAposentEsp/infoAmb[" + cValToChar(nT3N)+ "]"	
						Endif
						
					Enddo
				
				Else
					If (!Empty(aGravaT3C) .or. !Empty(aGravaT3N))
						//Carrego as informações do registro anterior gravada nos arrays, para depois efetuar as alterações.
						Taf404Carr(aGravaT3C,aGravaT3D,aGravaT3N,aGravaT3O,oModel)	
					Endif  
				Endif			
			Endif
			/*======================================
			||Integração Aposent.Especial - FIM	||				
			||====================================*/
			
			//=============================
			//³Efetiva a operacao desejada³
			//=============================
			If Empty(cInconMsg) .And. Empty(aIncons)
				If TafFormCommit( oModel )
					Aadd(aIncons, "ERRO19")
				Else
					lRet := .T.
				EndIf	 
			Else			
				Aadd(aIncons, cInconMsg)
				DisarmTransaction()
			EndIf						 			   
			
			oModel:DeActivate()
		
		EndIf                                                                           	

	End Transaction

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Zerando os arrays e os Objetos utilizados no processamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize( aRules, 0 ) 
aRules     := Nil

aSize( aChave, 0 ) 
aChave     := Nil    

oModel     := Nil
      
Return { lRet, aIncons } 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF404Rul           

Regras para gravacao das informacoes do registro S-2241 do E-Social

@Param
nOper      - Operacao a ser realizada ( 3 = Inclusao / 4 = Alteracao / 5 = Exclusao )

@Return	
aRull  - Regras para a gravacao das informacoes


@author Paulo V.B. Santana
@since 20/11/2015
@version 1.0

/*/                        	
//-------------------------------------------------------------------
Static Function TAF404Rul( cInconMsg, nSeqErrGrv, lTransmit, oModel, cCabec, cCabec02, cCabec03, cCodEvent, cOwner )

Local aRull := {}

Default cInconMsg		:= ""
Default nSeqErrGrv	:= 0
Default lTransmit		:= .F.
Default oModel		:= 	Nil	
Default cCabec		:= ""
Default cCabec02		:= ""
Default cCabec03		:= ""
Default cCodEvent		:= ""
Default cOwner		:= ""

Aadd( aRull,{"T3B_IDTRAB" ,FGetIdInt( "cpfTrab", "matricula", cCabec +"/cpfTrab", cCabec + "/matricula",,,@cInconMsg, @nSeqErrGrv),"C", .T.} ) 

If TafXNode( oDados , cCodEvent, cOwner, ( cCabec02 + "/iniInsalPeric/dtIniCondicao" ))
	Aadd( aRull,{"T3B_DTINI", cCabec02 + "/iniInsalPeric/dtIniCondicao" , "D", .F.})
Endif

If TafXNode( oDados , cCodEvent, cOwner, ( cCabec03 + "/iniAposentEsp/dtIniCondicao"  ))
	Aadd( aRull,{"T3B_DTINIA" , cCabec03 + "/iniAposentEsp/dtIniCondicao" , "D", .F.})
ElseIf lTransmit
	oModel:LoadValue( "MODEL_T3B", "T3B_DTINIA", T3B->T3B_DTINIA )
Endif 

If TafXNode( oDados , cCodEvent, cOwner, ( cCabec03 + "/altAposentEsp/dtAltCondicao"  ))
	Aadd( aRull, {"T3B_DTALTA", cCabec03 + "/altAposentEsp/dtAltCondicao" , "D", .F.}) 
Endif

If TafXNode( oDados , cCodEvent, cOwner, ( cCabec02 + "/altInsalPeric/dtAltCondicao"  ))
	Aadd( aRull, {"T3B_DTALT" , cCabec02 + "/altInsalPeric/dtAltCondicao" , "D", .F.}) 
Endif

If TafXNode( oDados , cCodEvent, cOwner, ( cCabec02 + "/fimInsalPeric/dtFimCondicao"  ))
	Aadd( aRull, {"T3B_DTFIN" , cCabec02 + "/fimInsalPeric/dtFimCondicao" , "D", .F.}) 
Endif

If TafXNode( oDados , cCodEvent, cOwner, ( cCabec03 + "/fimAposentEsp/dtFimCondicao"  ))
	Aadd( aRull, {"T3B_DTFINA", cCabec03 + "/fimAposentEsp/dtFimCondicao" , "D", .F.}) 
Endif

Return ( aRull )

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf404Carr

Carrega o modelo com as informações do registro anterior.

@return .T.

@author Paulo Santana
@since 05/09/2013
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Static Function Taf404Carr(aGravaT3C,aGravaT3D,aGravaT3N,aGravaT3O,oModel)	

Local nT3C := 0
Local nT3D := 0
Local nT3N := 0
Local nT3O := 0   
Local nX   := 0
Local nY   := 0

// Model Tipo Amb. igual 1 - Referente Insalubridade e Periculosidade	
nT3C := 1	
For nX := 1 To Len( aGravaT3C )
	oModel:GetModel( 'MODEL_T3C' ):LVALID	:= .T.
	If nT3C > 1
		oModel:GetModel( 'MODEL_T3C' ):AddLine()
	EndIf

	oModel:LoadValue( "MODEL_T3C", "T3C_IDAMB" ,aGravaT3C[nX][1])
	
	nT3D := 1	
	For nY := 1 To Len( aGravaT3D )
		
		If aGravaT3D[nY][1] == aGravaT3C[nX][1]
			oModel:GetModel( 'MODEL_T3D' ):LVALID	:= .T.
				
			If nT3D > 1
				oModel:GetModel( 'MODEL_T3D' ):AddLine()
			EndIf
	
			oModel:LoadValue( "MODEL_T3D", "T3D_IDFATR", aGravaT3D[nY][2])
			nT3D ++
		Endif
	Next 
   nT3C ++
Next

// Model Tipo Amb. igual 2 - Referente Aposentadoria Especial
nT3N := 1
For nX := 1 To Len( aGravaT3N )
	If nT3N > 1
		oModel:GetModel( 'MODEL_T3N' ):AddLine()
	EndIf
	oModel:GetModel( 'MODEL_T3N' ):LVALID	:= .T.
	
	oModel:LoadValue( "MODEL_T3N", "T3N_IDAMB", aGravaT3N[nX][1])
	
	nT3O := 1	
	For nY := 1 To Len( aGravaT3O )
		
		If aGravaT3N[nX][1] == aGravaT3O[nY][1]
			If nT3O > 1
				oModel:GetModel( 'MODEL_T3O' ):AddLine()
			EndIf
			oModel:GetModel( 'MODEL_T3O' ):LVALID	:= .T.
								
			oModel:LoadValue( "MODEL_T3O", "T3O_IDFATR",aGravaT3O[nY][2])
			nT3O++	
		Endif
			
   Next 
   nT3N ++
Next

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
Funcao que gera a exclusão do evento (S-3000)

@Param  oModel  -> Modelo de dados
@Param  nRecno  -> Numero do recno
@Param  lRotExc -> Variavel que controla se a function é chamada pelo TafIntegraESocial

@Return .T.

@Author Vitor Henrique Ferreira
@Since 30/06/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarEvtExc( oModel, nRecno )

Local cVerAnt   	:= ""  
Local cProtocolo	:= ""
Local cVersao   	:= ""

Local nT3B 	   	:= 0
Local nT3C 	   	:= 0
Local nT3D 	   	:= 0
Local nT3N 	   	:= 0
Local nT3O 	   	:= 0  
Local nY 		   	:= 0
Local nX		   	:= 0 
 
Local aGrava   	:= {}
Local aGravaT3C	:= {}
Local aGravaT3D	:= {}
Local aGravaT3N	:= {}
Local aGravaT3O	:= {}

Local oModelT3B	:= Nil
Local oModelT3C	:= Nil
Local oModelT3D	:= Nil
Local oModelT3N	:= Nil
Local oModelT3O 	:= Nil

//Controle se o evento é extemporâneo
Local lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

Begin Transaction 

	dbSelectArea("T3B")
	("T3B")->( DBGoTo( nRecno ) )
	
	oModelT3B := oModel:GetModel( 'MODEL_T3B' ) 
	oModelT3C := oModel:GetModel( 'MODEL_T3C' ) 
	oModelT3D := oModel:GetModel( 'MODEL_T3D' )
	oModelT3N := oModel:GetModel( 'MODEL_T3N' ) 
	oModelT3O := oModel:GetModel( 'MODEL_T3O' )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busco a versao anterior do registro para gravacao do rastro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cVerAnt    	:= oModelT3B:GetValue( "T3B_VERSAO" )				
	cProtocolo	:= oModelT3B:GetValue( "T3B_PROTUL" )				
	cEvento		:= oModelT3B:GetValue( "T3B_EVENTO" )
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Neste momento eu gravo as informacoes que foram carregadas na tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nT3B := 1 to Len( oModelT3B:aDataModel[ 1 ] )
		aAdd( aGrava, { oModelT3B:aDataModel[ 1, nT3B, 1 ], oModelT3B:aDataModel[ 1, nT3B, 2 ] } )
	Next	       	
						
	// Model Tipo Amb. igual 1 - Referente Insalubridade e Periculosidade	
	For nT3C := 1 To oModel:GetModel( 'MODEL_T3C' ):Length()
		oModel:GetModel( 'MODEL_T3C' ):GoLine(nT3C)
		If !oModel:GetModel( 'MODEL_T3C' ):IsDeleted()
			aAdd (aGravaT3C,{oModelT3C:GetValue('T3C_IDAMB')} )						
		EndIf
		
		For nT3D := 1 To oModel:GetModel( 'MODEL_T3D' ):Length()
			oModel:GetModel( 'MODEL_T3D' ):GoLine(nT3D)
			If !oModel:GetModel( 'MODEL_T3D' ):IsDeleted() 
				aAdd (aGravaT3D, {oModelT3C:GetValue('T3C_IDAMB'), oModelT3D:GetValue('T3D_IDFATR')} )
			EndIf
		Next 
	Next 
	
	// Model Tipo Amb. igual 2 - Referente Aposentadoria Especial
	For nT3N := 1 To oModel:GetModel( 'MODEL_T3N' ):Length()
		oModel:GetModel( 'MODEL_T3N' ):GoLine(nT3N)
		If !oModel:GetModel( 'MODEL_T3N' ):IsDeleted()
			aAdd (aGravaT3N, {oModelT3N:GetValue('T3N_IDAMB')} )
		EndIf
		
		For nT3O := 1 To oModel:GetModel( 'MODEL_T3O' ):Length()
		oModel:GetModel( 'MODEL_T3O' ):GoLine(nT3O)
			If !oModel:GetModel( 'MODEL_T3O' ):IsDeleted()
				aAdd (aGravaT3O, {oModelT3N:GetValue('T3N_IDAMB'), oModelT3O:GetValue('T3O_IDFATR')} )
			EndIf
		Next 
	Next 
				
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seto o campo como Inativo e gravo a versao do novo registro³
	//³no registro anterior                                       ³
	//|                                                           |
	//|ATENCAO -> A alteracao destes campos deve sempre estar     |
	//|abaixo do Loop do For, pois devem substituir as informacoes|
	//|que foram armazenadas no Loop acima                        |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FAltRegAnt( 'T3B', '2' )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Neste momento eu preciso setar a operacao do model³
	//³como Inclusao                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oModel:DeActivate()
	oModel:SetOperation( 3 ) 	
	oModel:Activate()		
											
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Neste momento eu realizo a inclusao do novo registro ja³
	//³contemplando as informacoes alteradas pelo usuario     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nT3B := 1 to Len( aGrava )
		oModel:LoadValue( "MODEL_T3B", aGrava[ nT3B, 1 ], aGrava[ nT3B, 2 ] )
	Next nT3B
	
	// Model Tipo Amb. igual 1 - Referente Insalubridade e Periculosidade	
	nT3C := 1	
	For nX := 1 To Len( aGravaT3C )
		oModel:GetModel( 'MODEL_T3C' ):LVALID	:= .T.
		If nT3C > 1
			oModel:GetModel( 'MODEL_T3C' ):AddLine()
		EndIf

		oModel:LoadValue( "MODEL_T3C", "T3C_IDAMB" ,aGravaT3C[nX][1])
		
		nT3D := 1	
		For nY := 1 To Len( aGravaT3D )
			
			If aGravaT3D[nY][1] == aGravaT3C[nX][1]
				oModel:GetModel( 'MODEL_T3D' ):LVALID	:= .T.
					
				If nT3D > 1
					oModel:GetModel( 'MODEL_T3D' ):AddLine()
				EndIf
		
				oModel:LoadValue( "MODEL_T3D", "T3D_IDFATR", aGravaT3D[nY][2])
				nT3D ++
			Endif
		Next 
	   nT3C ++
	Next	
	
	nT3N := 1
	// Model Tipo Amb. igual 2 - Referente Aposentadoria Especial
	For nX := 1 To Len( aGravaT3N )
		If nT3N > 1
			oModel:GetModel( 'MODEL_T3N' ):AddLine()
		EndIf
		oModel:GetModel( 'MODEL_T3N' ):LVALID	:= .T.
		
		oModel:LoadValue( "MODEL_T3N", "T3N_IDAMB", aGravaT3N[nX][1])
		
		nT3O := 1	
		For nY := 1 To Len( aGravaT3O )
			If aGravaT3N[nX][1] == aGravaT3O[nY][1]
				If nT3O > 1
					oModel:GetModel( 'MODEL_T3O' ):AddLine()
				EndIf
				oModel:GetModel( 'MODEL_T3O' ):LVALID	:= .T.
									
				oModel:LoadValue( "MODEL_T3O", "T3O_IDFATR",aGravaT3O[nY][2])
				nT3O++	
			Endif
				
	   Next 
	   nT3N ++
	   oModel:GetModel( 'MODEL_T3N' ):LVALID	:= .T.
	Next
	
	//Busco a nova versao do registro
	cVersao := xFunGetVer()
	
	/*---------------------------------------------------------
	ATENCAO -> A alteracao destes campos deve sempre estar     
	abaixo do Loop do For, pois devem substituir as informacoes
	que foram armazenadas no Loop acima                        
	-----------------------------------------------------------*/
	oModel:LoadValue( "MODEL_T3B", "T3B_VERSAO", cVersao )
	oModel:LoadValue( "MODEL_T3B", "T3B_VERANT", cVerAnt )
	oModel:LoadValue( "MODEL_T3B", "T3B_PROTPN", cProtocolo )
	oModel:LoadValue( "MODEL_T3B", "T3B_PROTUL", "" )
	
	/*---------------------------------------------------------
	Tratamento para que caso o Evento Anterior fosse de exclusão
	seta-se o novo evento como uma "nova inclusão", caso contrário o
	evento passar a ser uma alteração
	-----------------------------------------------------------*/
	oModel:LoadValue( "MODEL_T3B", "T3B_EVENTO", "E" )
	oModel:LoadValue( "MODEL_T3B", "T3B_ATIVO", "1" )

	//Gravo alteração para o Extemporâneo
	If lGoExtemp
		TafGrvExt( oModel, 'MODEL_T3B', 'T3B' )	
	EndIf
		
	FwFormCommit( oModel )
	TAFAltStat( 'T3B',"6" )
			
End Transaction 

Return .T.