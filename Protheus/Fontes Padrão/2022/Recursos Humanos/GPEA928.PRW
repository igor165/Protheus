#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEA928.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    	³ GPEA928    ³ Autor ³ Gustavo Silva Maranho	      	        ³ Data ³ 12/04/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao 	³ Informacoes eSocial				                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   	³ GPEA928()                                                    	  		            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL          			        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista     ³ Data     ³ FNC/Requisito  ³ Chamado ³  Motivo da Alteracao                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Raquel Hager ³11/08/2014³00000026544/2014³TQHIID   ³Inclusao de fonte na Versao 12.				³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPEA928()

Local oBrw := FwMBrowse():New()

oBrw:SetDescription( STR0001 ) //"Informacoes do e-social"
oBrw:SetAlias( "SRA" )
oBrw:SetMenuDef( 'GPEA928' ) 

oBrw:AddLegend( "RA_SITFOLH==' '"	, "GREEN"	, STR0002 ) //"Situação Normal"
oBrw:AddLegend( "RA_RESCRAI$'30/31'", "PINK"	, STR0003 ) //"Transferido"
oBrw:AddLegend( "RA_SITFOLH=='D'"	, "RED"		, STR0004 ) //"Demitido"
oBrw:AddLegend( "RA_SITFOLH=='A'"	, "YELLOW"	, STR0005 ) //"Afastado"
oBrw:AddLegend( "RA_SITFOLH=='F'"	, "BLUE"	, STR0006 ) //"Férias"

aColsAux:={}
//------------------------------------------
//Busca o filtro a ser utilizado no Browse
//------------------------------------------
xRetFilRh := CHKRH("GPEA010","SRA","1")
If ValType(xRetFilRh) == "L"
	cFiltraRh := if(xRetFilRh,".T.",".F.")
Else
	cFiltraRh := xRetFilRh
EndIf

oBrw:SetFilterDefault(cFiltraRh)

oBrw:Activate()

Return ( Nil )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MenuDef     ³ Autor ³ Gustavo M.		      ³ Data ³ 12/04/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Menu Funcional                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function MenuDef()
                                                                               	
Local aRotina := {}  

ADD OPTION aRotina Title OemToAnsi(STR0007)	Action 'VIEWDEF.GPEA928' OPERATION 4  ACCESS 0 DISABLE MENU //"Manutencao"	

Return aRotina

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ModelDef    ³ Autor ³ Gustavo M.		      ³ Data ³ 12/04/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³					                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ModelDef()                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function ModelDef()

Local oStruSRA := FWFormStruct( 1, 'SRA')
Local oStruRFS := NIL
Local oStruRBW := NIL
Local oStruRFX := FwFormStruct( 1, "RFX" )
Local oStruRFY := FwFormStruct( 1, "RFY" )
Local oStruRFZ := FwFormStruct( 1, "RFZ" )
Local oModel   := MpFormModel():New( "GPEA928",{|oModel|fGP928Ini(oModel)},{|oModel| ValidModel(oModel)},{ |oModel| SaveModel( oModel ) } )

Local lEstag	:= SRA->RA_CATEFD == '901'
Local lTempor   := SRA->RA_CATEFD == '106'

oModel:SetActivate( { |oModel| fGP928Ini( oModel ) } )

oStruSRA	:= FWFormStruct(1,"SRA",{|cCampo|  AllTrim(cCampo) $ "|RA_MAT|RA_NOME|RA_ADMISSA|"})

oModel:AddFields( 'MODEL_SRA',			  , oStruSRA )
If lEstag
	oStruRFS:= FwFormStruct( 1, "RFS" )
	oModel:AddFields( "MODEL_RFS", "MODEL_SRA", oStruRFS )
	oModel:SetRelation( "MODEL_RFS",{ { "RBW_FILIAL", "xFilial('RFS')" }, { "RFS_MAT", "RA_MAT" } },RFS->( IndexKey( 1 ) ) )
	oModel:GetModel( "MODEL_RFS" ):SetOptional( .T. ) 
Else
	If lTempor
		oStruRBW:=FwFormStruct( 1, "RBW" )
		oModel:AddFields( "RBWDETAIL", "MODEL_SRA", oStruRBW )
  		oModel:SetRelation( "RBWDETAIL",{ { "RBW_FILIAL", "xFilial('RBW')" }, { "RBW_MAT", "RA_MAT" } },RBW->( IndexKey( 1 ) ) )		
		oModel:GetModel( "RBWDETAIL" ):SetOptional( .T. )
	Endif
Endif 

oModel:AddGrid  ( "RFXDETAIL", "MODEL_SRA", oStruRFX,{|oModel|Gp923PreLine(oModel)} )
oModel:AddGrid  ( "RFYDETAIL", "MODEL_SRA", oStruRFY,,{|oModel|fGp925LinOk(oModel)} )
oModel:AddGrid  ( "RFZDETAIL", "MODEL_SRA", oStruRFZ,,{|oModel|fGp926LinOk(oModel)} )

oModel:SetRelation( "RFXDETAIL",{ { "RFX_FILIAL", "xFilial('RFX')" }, { "RFX_MAT", "RA_MAT" } },RFX->( IndexKey( 1 ) ) )
oModel:SetRelation( "RFYDETAIL",{ { "RFY_FILIAL", "xFilial('RFY')" }, { "RFY_MAT", "RA_MAT" } },RFY->( IndexKey( 1 ) ) )
oModel:SetRelation( "RFZDETAIL",{ { "RFZ_FILIAL", "xFilial('RFZ')" }, { "RFZ_MAT", "RA_MAT" } },RFZ->( IndexKey( 1 ) ) )

oModel:GetModel( "RFXDETAIL" ):SetOptional( .T. )
oModel:GetModel( "RFYDETAIL" ):SetOptional( .T. )
oModel:GetModel( "RFZDETAIL" ):SetOptional( .T. )


oModel:SetVldActivate({|oModel| Gp925VldFun(oModel, aColsAux)})

Return( oModel ) 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ViewDef     ³ Autor ³ Gustavo M.		      ³ Data ³ 12/04/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ViewDef					                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ViewDef()                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function ViewDef()

Local oModel    := FWLoadModel( "GPEA928" )
Local oView     := FWFormView():New()

Local oStruSRA	:= FWFormStruct(2 , 'SRA' )
Local oStruRFS  := NIL
Local oStruRBW  := NIL
Local oStruRFX  := FWFormStruct( 2, "RFX" )
Local oStruRFY  := FWFormStruct( 2, "RFY" )
Local oStruRFZ  := FWFormStruct( 2, "RFZ" )
Local lEstag	:= SRA->RA_CATEFD == '901'
Local lTempor   := SRA->RA_CATEFD == '106'

oStruSRA	:= FWFormStruct(2,"SRA",{|cCampo|  AllTrim(cCampo) $ "|RA_MAT|RA_NOME|RA_ADMISSA|"})

oView:SetModel( oModel )   

If lEstag
	oStruRFS:=FWFormStruct( 2, "RFS" )
	oView:AddField( "VIEW_RFS", oStruRFS, "MODEL_RFS" )
	oStruRFS:RemoveField("RFS_MAT")
Else
	If lTempor
		oStruRBW:=FWFormStruct( 2, "RBW" )
		oView:AddField( "VIEW_RBW", oStruRBW, "RBWDETAIL" )
		oStruRBW:RemoveField("RBW_MAT")
	Endif
Endif


/*-----------------------------------------------------------------------------------
							Esrutura da View
-------------------------------------------------------------------------------------*/  
                                                                        
oView:AddField("VIEW_SRA" , oStruSRA, "MODEL_SRA" )
oView:AddGrid ( "VIEW_RFX", oStruRFX, "RFXDETAIL" )
oView:AddGrid ( "VIEW_RFY", oStruRFY, "RFYDETAIL" )
oView:AddGrid ( "VIEW_RFZ", oStruRFZ, "RFZDETAIL" )

oStruSRA:SetNoFolder() 
oStruRFX:RemoveField("RFX_MAT")
oStruRFY:RemoveField("RFY_MAT")
oStruRFZ:RemoveField("RFZ_MAT")

oView:SetOnlyView('VIEW_SRA')
oView:CreateHorizontalBox( 'SUPERIOR', 10 )
oView:SetOwnerView( 'VIEW_SRA', 'SUPERIOR' )

/*-----------------------------------------------------------------------------------
							Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",90)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL")
oView:AddSheet("FOLDER_PRINCIPAL","ABA01",STR0001) 

oView:CreateHorizontalBox("AUXILIAR",33,,,"FOLDER_PRINCIPAL","ABA01")	
oView:CreateFolder("FOLDER_PRINCIPAL_AUXILIAR","AUXILIAR" )
oView:AddSheet("FOLDER_PRINCIPAL_AUXILIAR","ABA01",STR0008) //Estabilidade
oView:CreateHorizontalBox( 'RFX', 100,,, "FOLDER_PRINCIPAL_AUXILIAR", 'ABA01' )

oView:CreateHorizontalBox("AUX1",33,,,"FOLDER_PRINCIPAL","ABA01")	
oView:CreateFolder("FOLDER_PRINCIPAL_AUX1","AUX1" ) 
oView:AddSheet("FOLDER_PRINCIPAL_AUX1","ABA01",STR0009) //Aviso Previo
oView:CreateHorizontalBox( 'RFY', 100,,, "FOLDER_PRINCIPAL_AUX1", 'ABA01' )

oView:CreateHorizontalBox("AUX2",33,,,"FOLDER_PRINCIPAL","ABA01")	
oView:CreateFolder("FOLDER_PRINCIPAL_AUX2","AUX2" ) 		 
oView:AddSheet("FOLDER_PRINCIPAL_AUX2","ABA01",STR0010) //Sucessao de vinculos
oView:CreateHorizontalBox( 'RFZ', 100,,, "FOLDER_PRINCIPAL_AUX2", 'ABA01' )


If lEstag
	oView:AddSheet("FOLDER_PRINCIPAL","ABA02",STR0012) 
	oView:CreateHorizontalBox("RFS",100,,,"FOLDER_PRINCIPAL","ABA02")
	oView:SetOwnerView( "VIEW_RFS", "RFS" )
Else 
	If lTempor
		oView:AddSheet("FOLDER_PRINCIPAL","ABA03",STR0013)  
		oView:CreateHorizontalBox("RBW",100,,,"FOLDER_PRINCIPAL","ABA03")
		oView:SetOwnerView( "VIEW_RBW", "RBW" ) 
	Endif
Endif	

/*-----------------------------------------------------------------------------------
							Amarração para exibição das informações
-------------------------------------------------------------------------------------*/

oView:SetOwnerView( "VIEW_RFX", "RFX" )
oView:SetOwnerView( "VIEW_RFY", "RFY" )
oView:SetOwnerView( "VIEW_RFZ", "RFZ" )

Return( oView )       
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SaveModel   ³ Autor ³ Gustavo M.		      ³ Data ³ 19/04/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³					                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³SaveModel()                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
                       
Static Function SaveModel( oModel )

Begin Transaction
	FwFormCommit( oModel )
End Transaction

Return ( .T. )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ValidModel  ³ Autor ³ Gustavo M.		      ³ Data ³ 19/04/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³					                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ValidModel()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function ValidModel( oModel )

Local nI := 0
Local lEstag	:= SRA->RA_CATEFD == '901'
Local lTempor   := SRA->RA_CATEFD == '106'

	oModelRFX := oModel:GetModel( 'RFXDETAIL')
	If oModelRFX:IsUpdated()
		RFX->(dbSetOrder(1))
		If !RFX->( dbSeek( xFilial( 'RFX' ) + oModel:GetValue( 'MODEL_SRA', 'RA_MAT' )  ) )
			aCampos := oModelRFX:GetStruct():GetFields()
			For nI :=  1 to Len( aCampos )
				If aCampos[nI][MODEL_FIELD_INIT] <> NIL
					xInit := oModelRFX:InitValue( aCampos[nI][MODEL_FIELD_IDFIELD] )
					If !Empty( xInit )
						oModelRFX:LoadValue( aCampos[nI][MODEL_FIELD_IDFIELD], xInit )
					EndIf
				EndIf
			Next
		EndIf         
	Endif
	
	oModelRFY := oModel:GetModel( 'RFYDETAIL')
	If oModelRFY:IsUpdated()
	   	RFY->(dbSetOrder(1))
		If !RFY->( dbSeek( xFilial( 'RFY' ) + oModel:GetValue( 'MODEL_SRA', 'RA_MAT' )  ) )
			aCampos := oModelRFY:GetStruct():GetFields()
			For nI :=  1 to Len( aCampos )
				If aCampos[nI][MODEL_FIELD_INIT] <> NIL           	
					xInit := oModelRFY:InitValue( aCampos[nI][MODEL_FIELD_IDFIELD] )
					If !Empty( xInit )
						oModelRFY:LoadValue( aCampos[nI][MODEL_FIELD_IDFIELD], xInit )
					EndIf
				EndIf
			Next
		EndIf      
	Endif
	
	oModelRFZ := oModel:GetModel( 'RFZDETAIL')
	If oModelRFZ:IsUpdated()
		RFZ->(dbSetOrder(1))
		If !RFZ->( dbSeek( xFilial( 'RFZ' ) + oModel:GetValue( 'MODEL_SRA', 'RA_MAT' )  ) )
			aCampos := oModelRFZ:GetStruct():GetFields()
			For nI :=  1 to Len( aCampos )
				If aCampos[nI][MODEL_FIELD_INIT] <> NIL
					xInit := oModelRFZ:InitValue( aCampos[nI][MODEL_FIELD_IDFIELD] )
					If !Empty( xInit )
						oModelRFZ:LoadValue( aCampos[nI][MODEL_FIELD_IDFIELD], xInit )
					EndIf
				EndIf
			Next
		EndIf
	Endif
	
IF lEstag
	fG920RFSpo()
Else
	If lTempor
		Gp927PosVal(oModel)
	Endif 
Endif 

Gp923PosVal(oModel)
fGp925TdOk(aColsAux)
fGp926TdOk()

Return .T.    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fGP928Ini   ³ Autor ³ Gustavo M.		      ³ Data ³ 19/04/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³					                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fGP928Ini(oModel)                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/

Static Function fGP928Ini( oModel )

Local aArea      := GetArea()
Local aCampos    := {}
Local nI         := 0
Local nOperation := oModel:GetOperation()
Local xInit      := ""
Local lEstag	:= SRA->RA_CATEFD == '901'
Local lTempor   := SRA->RA_CATEFD == '106'

If nOperation == MODEL_OPERATION_UPDATE
        
	If lEstag
		oModelRFS := oModel:GetModel( 'MODEL_RFS') 
		
		RFS->( dbSetOrder( 1 ) )
		If !RFS->( dbSeek( xFilial( 'RFS' ) + oModel:GetValue( 'MODEL_SRA', 'RA_MAT' )  ) )
			aCampos := oModelRFS:GetStruct():GetFields()
			For nI :=  1 to Len( aCampos )
				If aCampos[nI][MODEL_FIELD_INIT] <> NIL
					xInit := oModelRFS:InitValue( aCampos[nI][MODEL_FIELD_IDFIELD] )
					If !Empty( xInit )
						oModelRFS:LoadValue( aCampos[nI][MODEL_FIELD_IDFIELD], xInit )
					EndIf
				EndIf
			Next
		EndIf 
	Endif
	
	IF lTempor	
		oModelRBW := oModel:GetModel( 'RBWDETAIL')
		oStruRBW  := oModelRBW:GetStruct()
		oStruRBW:SetProperty('RBW_MOTIVO',	MODEL_FIELD_OBRIGAT, .F. )
		RBW->(dbSetOrder(1))
		If !RBW->( dbSeek( xFilial( 'RBW' ) + oModel:GetValue( 'MODEL_SRA', 'RA_MAT' )  ) )
			aCampos := oModelRBW:GetStruct():GetFields()
			For nI :=  1 to Len( aCampos )
				If aCampos[nI][MODEL_FIELD_INIT] <> NIL
					xInit := oModelRBW:InitValue( aCampos[nI][MODEL_FIELD_IDFIELD] )
					If !Empty( xInit )
						oModelRBW:LoadValue( aCampos[nI][MODEL_FIELD_IDFIELD], xInit )
					EndIf
				EndIf
			Next
		EndIf
	Endif
		
	oModelRFX := oModel:GetModel( 'RFXDETAIL')
	oStruRFX  := oModelRFX:GetStruct()
 	oStruRFX:SetProperty('RFX_DATAI',	MODEL_FIELD_OBRIGAT, .F. )
	oStruRFX:SetProperty('RFX_TPESTB',	MODEL_FIELD_OBRIGAT, .F. )
		
	oModelRFY := oModel:GetModel( 'RFYDETAIL')
	oStruRFY  := oModelRFY:GetStruct()
	oStruRFY:SetProperty('RFY_TPAVIS',	MODEL_FIELD_OBRIGAT, .F. )
	oStruRFY:SetProperty('RFY_DTASVP',	MODEL_FIELD_OBRIGAT, .F. )
	oStruRFY:SetProperty('RFY_DIASAV',	MODEL_FIELD_OBRIGAT, .F. )
	oStruRFY:SetProperty('RFY_DTPJAV',	MODEL_FIELD_OBRIGAT, .F. )		   
EndIf
             
RestArea( aArea )

Return .T.