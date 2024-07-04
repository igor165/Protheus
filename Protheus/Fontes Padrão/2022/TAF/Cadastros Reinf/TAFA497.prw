#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA497.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA497
Cadastro MVC do R-5011 - Informações de bases e tributos consolidadas por período de apuração

@author Vitor Siqueira			
@since 10/03/2018
@version 1.0

/*/
//-------------------------------------------------------------------

Function TAFA497()

If TAFAlsInDic( "V0C" )	
	BrowseDef()
Else
	Aviso( STR0012, TafAmbInvMsg(), { STR0013 }, 3 ) //##"Dicionário Incompatível" ##"Encerrar"
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Vitor Siqueira			
@since 10/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aFuncao as array
Local aRotina as array

aFuncao := {}
aRotina := {}

aAdd( aFuncao, { "", "TAF497Xml", "1" } )
aAdd( aFuncao, { "", "xFunNewHis( 'V0C', 'TAFA497' )", "3" } )
aAdd( aFuncao, { "", "TAFXmlLote( 'V0C', 'R-5011', 'TotalContrib', 'TAF497Xml', 5, oBrw)", "5" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina Title "Visualizar"    ACTION 'VIEWDEF.TAFA497' OPERATION 2 ACCESS 0 //"Visualizar" STR0016
Else
	ADD OPTION aRotina Title "Visualizar"    ACTION 'VIEWDEF.TAFA497' OPERATION 2 ACCESS 0 //"Visualizar"
EndIf

Return (aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Vitor Siqueira			
@since 10/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruV0C  as object
Local oStruV0D  as object
Local oStruV0E  as object
Local oStruV0F  as object
Local oStruV0G  as object
Local oStruV0H  as object
Local oStruV0I  as object
Local oStruV0J  as object
Local oStruV6C  as object
Local oModel	as object
Local lCno 		As Logical
Local lLeiaute 	As Logical
Local lVSup132  As Logical
Local cVersao	As Character

cVersao	:=	StrTran(GetMV("MV_TAFVLRE", .F., " "),'_','')

lCno  		:= IIf( TafColumnPos( "V0F_CNO" ), .T., .F. )
lLeiaute	:= IIf( TafColumnPos( "V0C_LEIAUT" ), .T., .F. )
lVSup132	:= .F.

if lLeiaute .And. ( cVersao >= '10400' .OR. cVersao = " " ) 
	lVSup132 := .T. 
elseif lLeiaute .And. ( Empty( V0C->V0C_LEIAUT ) .Or. cVersao >= '10300')
	lVSup132 := .F.
elseif !lLeiaute
	lVSup132 := .F.
endif

oStruV0C  :=  FWFormStruct( 1, 'V0C' )
oStruV0D  :=  FWFormStruct( 1, 'V0D' )
oStruV0E  :=  FWFormStruct( 1, 'V0E' )
oStruV0F  :=  FWFormStruct( 1, 'V0F' )
oStruV0G  :=  FWFormStruct( 1, 'V0G' )
oStruV0H  :=  FWFormStruct( 1, 'V0H' )
oStruV0I  :=  FWFormStruct( 1, 'V0I' )
oStruV0J  :=  FWFormStruct( 1, 'V0J' )
oStruV6C  :=  FWFormStruct( 1, 'V6C' )

oModel    :=  MPFormModel():New( 'TAFA497' ,,,{|oModel| SaveModel(oModel)})

//V0C – Inf. Bases e Trib. consolidado
oModel:AddFields('MODEL_V0C', /*cOwner*/, oStruV0C)
oModel:GetModel( "MODEL_V0C" ):SetPrimaryKey( { "V0C_PERAPU" } )

//V0D – Ocorrências Registradas       
oModel:AddGrid('MODEL_V0D', 'MODEL_V0C', oStruV0D)
oModel:GetModel('MODEL_V0D'):SetUniqueLine({'V0D_SEQUEN'})
oModel:GetModel('MODEL_V0D'):SetOptional(.T.)

//V0E – Informações Consolidadas      
oModel:AddGrid('MODEL_V0E', 'MODEL_V0C', oStruV0E)
oModel:GetModel('MODEL_V0E'):SetUniqueLine({'V0E_NRREC'})
oModel:GetModel('MODEL_V0E'):SetOptional(.T.)

//V0F – Totalizador Serviços Tomados  
oModel:AddGrid('MODEL_V0F', 'MODEL_V0E', oStruV0F)
oModel:GetModel('MODEL_V0F'):SetOptional(.T.)

if lVSup132 .And. lCno
	oModel:GetModel('MODEL_V0F'):SetUniqueLine({'V0F_CNPJPR','V0F_CRTOM','V0F_CNO'})
else
	oModel:GetModel('MODEL_V0F'):SetUniqueLine({'V0F_CNPJPR','V0F_CRTOM'})
endif

//V0G - Totalizador Serviços Prestados
oModel:AddGrid('MODEL_V0G', 'MODEL_V0E', oStruV0G)
oModel:GetModel('MODEL_V0G'):SetOptional(.T.)
oModel:GetModel('MODEL_V0G'):SetUniqueLine({'V0G_TPINST','V0G_NRINST'})

//V0H - Totalizador Detalhamento Rep  
oModel:AddGrid('MODEL_V0H', 'MODEL_V0E', oStruV0H)
oModel:GetModel('MODEL_V0H'):SetOptional(.T.)

If !lVSup132
	oModel:GetModel('MODEL_V0H'):SetUniqueLine({'V0H_CNPJAD'})
endif

//V0I - Totalizador Contrib. Sociais  
oModel:AddGrid('MODEL_V0I', 'MODEL_V0E', oStruV0I)
oModel:GetModel('MODEL_V0I'):SetOptional(.T.)
oModel:GetModel('MODEL_V0I'):SetUniqueLine({'V0I_SEQUEN'})
oModel:GetModel('MODEL_V0I'):SetMaxLine(3) 

//V0J - Totalizador CPRB              
oModel:AddGrid('MODEL_V0J', 'MODEL_V0E', oStruV0J)
oModel:GetModel('MODEL_V0J'):SetOptional(.T.)
oModel:GetModel('MODEL_V0J'):SetUniqueLine({'V0J_CODREC'})
oModel:GetModel('MODEL_V0J'):SetMaxLine(4) 

//V6C - Totalizador das contribuições sociais incidentes sobre aquisição de produção rural

oModel:AddGrid( "MODEL_V6C", "MODEL_V0E", oStruV6C )
oModel:GetModel( "MODEL_V6C" ):SetOptional( .T. )
oModel:GetModel( "MODEL_V6C" ):SetUniqueLine( { "V6C_CODREC" } )

oModel:SetRelation("MODEL_V0D",{ {"V0D_FILIAL","xFilial('V0D')"}, {"V0D_ID","V0C_ID"}, {"V0D_VERSAO","V0C_VERSAO"}} , V0D->(IndexKey(1)) )
oModel:SetRelation("MODEL_V0E",{ {"V0E_FILIAL","xFilial('V0E')"}, {"V0E_ID","V0C_ID"}, {"V0E_VERSAO","V0C_VERSAO"}} , V0E->(IndexKey(1)) )
oModel:SetRelation("MODEL_V0F",{ {"V0F_FILIAL","xFilial('V0F')"}, {"V0F_ID","V0C_ID"}, {"V0F_VERSAO","V0C_VERSAO"}  , {"V0F_NRREC" ,"V0E_NRREC"} }, V0F->(IndexKey(1)) )
oModel:SetRelation("MODEL_V0G",{ {"V0G_FILIAL","xFilial('V0G')"}, {"V0G_ID","V0C_ID"}, {"V0G_VERSAO","V0C_VERSAO"}  , {"V0G_NRREC" ,"V0E_NRREC"} }, V0G->(IndexKey(1)) )
oModel:SetRelation("MODEL_V0H",{ {"V0H_FILIAL","xFilial('V0H')"}, {"V0H_ID","V0C_ID"}, {"V0H_VERSAO","V0C_VERSAO"}  , {"V0H_NRREC" ,"V0E_NRREC"} }, V0H->(IndexKey(1)) )
oModel:SetRelation("MODEL_V0I",{ {"V0I_FILIAL","xFilial('V0I')"}, {"V0I_ID","V0C_ID"}, {"V0I_VERSAO","V0C_VERSAO"}  , {"V0I_NRREC" ,"V0E_NRREC"} }, V0I->(IndexKey(1)) )
oModel:SetRelation("MODEL_V0J",{ {"V0J_FILIAL","xFilial('V0J')"}, {"V0J_ID","V0C_ID"}, {"V0J_VERSAO","V0C_VERSAO"}  , {"V0J_NRREC" ,"V0E_NRREC"} }, V0J->(IndexKey(1)) )
oModel:SetRelation( "MODEL_V6C", { { "V6C_FILIAL", "xFilial('V6C')" }, { "V6C_ID", "V0C_ID" }, { "V6C_VERSAO", "V0C_VERSAO" }, { "V6C_NRREC", "V0E_NRREC" } }, V6C->( IndexKey( 1 ) ) )


Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Vitor Siqueira			
@since 10/03/2018
@version 1.0
/*/
//---------------------------------------------------------------------

Static Function ViewDef()

Local oModel   	as object
Local oStruV0Ca	as object
Local oStruV0Cb	as object
Local oStruV0D	as object
Local oStruV0E	as object
Local oStruV0F	as object
Local oStruV0G	as object
Local oStruV0H	as object
Local oStruV0I	as object
Local oStruV0J	as object
Local oStruV6C  as object
Local oView		as object
Local cCmpFil  	as char
Local nI        as numeric
Local nViewOrd 	as numeric
Local aCmpGrp   as array
Local cGrpCom1	as char
Local cGrpCom2	as char
Local cGrpCom3 	as char

Local lCno 		As Logical
Local lLeiaute 	As Logical
Local lVSup132 	As Logical

lCno  		:= IIf( TafColumnPos( "V0F_CNO" ), .T., .F. )
lLeiaute	:= IIf( TafColumnPos( "V0C_LEIAUT" ), .T., .F. )
lVSup132	:= .F.

if lLeiaute .And. "1_04" $ V0C->V0C_LEIAUT
	lVSup132 := .T.
elseif lLeiaute .And. ( Empty( V0C->V0C_LEIAUT ) .Or. "1_03" $ V0C->V0C_LEIAUT )
	lVSup132 := .F.
elseif !lLeiaute
	lVSup132 := .F.
endif

oModel   	:= FWLoadModel( 'TAFA497' )
oStruV0Ca	:= Nil
oStruV0Cb	:= Nil
oStruV0D	:= FWFormStruct( 2, 'V0D' )
oStruV0E	:= FWFormStruct( 2, 'V0E' )
oStruV0F	:= FWFormStruct( 2, 'V0F' )
oStruV0G  	:= FWFormStruct( 2, 'V0G' )
oStruV0H  	:= FWFormStruct( 2, 'V0H' )
oStruV0I  	:= FWFormStruct( 2, 'V0I' )
oStruV0J  	:= FWFormStruct( 2, 'V0J' )
oStruV6C := FWFormStruct( 2, "V6C" )

oView		:= FWFormView():New()
cCmpFil  	:= ''
nI        	:= 0
nViewOrd	:= 0
aCmpGrp   	:= {}
cGrpCom1  	:= ""
cGrpCom2  	:= ""
cGrpCom3	:= ""

oView:SetModel( oModel )
//oView:SetContinuousForm(.T.)

cCmpFil  := 'V0C_PERAPU|V0C_PROTUL|V0C_VERSAO|'
cCmpFil  += 'V0C_CODRET|V0C_DTPROC|V0C_HRPROC|V0C_IDEVT|V0C_HASH|'

oStruV0Ca := FwFormStruct( 2, 'V0C', {|x| AllTrim( x ) + "|" $ cCmpFil } )

oView:AddField( "VIEW_V0Ca", oStruV0Ca, "MODEL_V0C" )
oView:EnableTitleView( "VIEW_V0Ca", "Informações do Retorno" )

oStruV0Ca:SetProperty( "V0C_PERAPU"	, MVC_VIEW_ORDEM, "01" )
oStruV0Ca:SetProperty( "V0C_PROTUL"	, MVC_VIEW_ORDEM, "02" )
oStruV0Ca:SetProperty( "V0C_DTPROC"	, MVC_VIEW_ORDEM, "03" )
oStruV0Ca:SetProperty( "V0C_HRPROC"	, MVC_VIEW_ORDEM, "04" )
oStruV0Ca:SetProperty( "V0C_VERSAO"	, MVC_VIEW_ORDEM, "05" )
oStruV0Ca:SetProperty( "V0C_CODRET"	, MVC_VIEW_ORDEM, "06" )
oStruV0Ca:SetProperty( "V0C_IDEVT"	, MVC_VIEW_ORDEM, "07" )
oStruV0Ca:SetProperty( "V0C_HASH"	, MVC_VIEW_ORDEM, "08" )

/*-----------------------------------------------------------------------------------
			      Grupo de campos da Comercialização de Produção	
-------------------------------------------------------------------------------------*/

oStruV0Ca:AddGroup( "GRP_01", STR0002, "", 1 ) //Período de apuração
//oStruV0Ca:AddGroup( "GRP_02", STR0003, "", 1 ) //Informações do Recibo de Retorno

aCmpGrp := StrToKArr(cGrpCom1,"|")
For nI := 1 to Len(aCmpGrp)
	oStruV0Ca:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_01")
Next nI
/*
aCmpGrp := StrToKArr(cGrpCom2,"|")
For nI := 1 to Len(aCmpGrp)
	oStruV0Ca:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_02")
Next nI
*/	
/*--------------------------------------------------------------------------------------------
									Estrutura da View
---------------------------------------------------------------------------------------------*/

//oView:AddGrid ( "VIEW_V0D", oStruV0D, "MODEL_V0D" )
//oView:AddIncrementField( 'VIEW_V0D', 'V0D_SEQUEN' ) 

oView:AddGrid ( "VIEW_V0E", oStruV0E, "MODEL_V0E" )
oView:AddGrid ( "VIEW_V0F", oStruV0F, "MODEL_V0F" )
oView:AddGrid ( "VIEW_V0G", oStruV0G, 'MODEL_V0G' )
oView:AddGrid ( "VIEW_V0H", oStruV0H, 'MODEL_V0H' )
oView:AddGrid ( "VIEW_V0I", oStruV0I, 'MODEL_V0I' )

oView:AddIncrementField( 'VIEW_V0I', 'V0I_SEQUEN' )

oView:AddGrid ( "VIEW_V0J", oStruV0J, 'MODEL_V0J' ) 
oView:AddGrid ( "VIEW_V6C", oStruV6C, 'MODEL_V6C' )



/*-----------------------------------------------------------------------------------
								Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL")

//////////////////////////////////////////////////////////////////////////////////

oView:AddSheet("FOLDER_PRINCIPAL","ABA01",STR0001) //"Informações de bases e tributos consolidadas por período de apuração"
oView:CreateHorizontalBox("V0Ca",030,,,"FOLDER_PRINCIPAL","ABA01") 

oView:CreateHorizontalBox("PAINEL_TPCOM",070,,,"FOLDER_PRINCIPAL","ABA01")
oView:CreateFolder( 'FOLDER_TPCOM', 'PAINEL_TPCOM' )

oView:AddSheet( 'FOLDER_TPCOM', 'ABA02', STR0004 ) //"Informações de ocorrências registradas"
oView:CreateHorizontalBox ( 'V0E', 050,,, 'FOLDER_TPCOM'  , 'ABA02' )

/*
oView:AddSheet( 'FOLDER_TPCOM', 'ABA01', STR0003 ) //"Informações Consolidadas"
oView:CreateHorizontalBox ( 'V0D', 100,,, 'FOLDER_TPCOM'  , 'ABA01' )
*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL2",50,,,"FOLDER_TPCOM","ABA02")
oView:CreateFolder("FOLDER_PRINCIPAL2","PAINEL_PRINCIPAL2")

// Abas - Eventos 
oView:AddSheet("FOLDER_PRINCIPAL2","ABA01",STR0005+" - R-2010") //"Serviços Tomados" 
oView:CreateHorizontalBox("V0F",100,,,"FOLDER_PRINCIPAL2","ABA01") 

oView:AddSheet( 'FOLDER_PRINCIPAL2', 'ABA02', STR0006+" - R-2020" ) //"Serviços Prestados" 
oView:CreateHorizontalBox ( 'V0G', 100,,, 'FOLDER_PRINCIPAL2'  , 'ABA02' )

oView:AddSheet( 'FOLDER_PRINCIPAL2', 'ABA03', STR0007+" - R-2040" ) //"Associações Desportivas"
oView:CreateHorizontalBox ( 'V0H', 100,,, 'FOLDER_PRINCIPAL2'  , 'ABA03' )

oView:AddSheet( 'FOLDER_PRINCIPAL2', 'ABA04', "Comercialização Prod. Rural"+" - R-2050" ) //"Contribuições Sociais"  
oView:CreateHorizontalBox ( 'V0I', 100,,, 'FOLDER_PRINCIPAL2'  , 'ABA04' )

oView:AddSheet( 'FOLDER_PRINCIPAL2', 'ABA05', STR0019 + " - R-2055" ) //"Aquisição Produção Rural" 
oView:CreateHorizontalBox ( "V6C", 100,,, 'FOLDER_PRINCIPAL2'  , 'ABA05' )


oView:AddSheet( 'FOLDER_PRINCIPAL2', 'ABA06', STR0009+" - R-2060" ) //"CPRB" 
oView:CreateHorizontalBox ( 'V0J', 100,,, 'FOLDER_PRINCIPAL2'  , 'ABA06' )


//oView:AddSheet("FOLDER_PRINCIPAL","ABA02",STR0010)//"Recibo de Transmissão" 
//oView:CreateHorizontalBox("V0Cb",100,,,'FOLDER_PRINCIPAL',"ABA02")

//////////////////////////////////////////////////////////////////////////////////

oStruV0F:SetProperty( "V0F_CNPJPR"	, MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )

If lVSup132 .And. lCno
oStruV0F:SetProperty( "V0F_CNO"		, MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
endif

oStruV0F:SetProperty( "V0F_VLRBRE"	, MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
oStruV0F:SetProperty( "V0F_CRTOM"	, MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
oStruV0F:SetProperty( "V0F_VLRTOM"	, MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
oStruV0F:SetProperty( "V0F_VLRSUS"	, MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )

/*-----------------------------------------------------------------------------------
							Amarração para exibição das informações
-------------------------------------------------------------------------------------*/

oView:SetOwnerView( "VIEW_V0Ca", "V0Ca")
//oView:SetOwnerView( "VIEW_V0Cb", "V0Cb")
//oView:SetOwnerView( "VIEW_V0D",  "V0D" )
oView:SetOwnerView( "VIEW_V0E",  "V0E" )
oView:SetOwnerView( "VIEW_V0F",  "V0F" )
oView:SetOwnerView( "VIEW_V0G",  "V0G" )
oView:SetOwnerView( "VIEW_V0H",  "V0H" )
oView:SetOwnerView( "VIEW_V0I",  "V0I" )
oView:SetOwnerView( "VIEW_V0J",  "V0J" )
oView:SetOwnerView( "VIEW_V6C",  "V6C" )

/*-----------------------------------------------------------------------------------
Remoção Campos
-------------------------------------------------------------------------------------*/
if lVSup132
	oStruV0H:RemoveField( "V0H_CNPJAD" )
	oStruV0H:RemoveField( "V0H_VLRREP" )
endif

if !lVSup132 .And. lCno
	oStruV0F:RemoveField( "V0F_CNO" )
endif

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If !lMenuDif
	xFunRmFStr(@oStruV0Ca,"V0C")
EndIf

Return (oView)

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Vitor Siqueira			
@since 10/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local nOperation	as numeric
	Local lRetorno		as logical

	nOperation	:= oModel:GetOperation()
	lRetorno	:= .T.

	FWFormCommit( oModel )   
     
Return (lRetorno)

//-------------------------------------------------------------------	
/*/{Protheus.doc} TAF497Xml
Retorna o Xml do Registro Posicionado 
	
@author Vitor Siqueira			
@since 10/03/2018
@version 1.0

@Param:
lJob - Informa se foi chamado por Job

@return
cXml - Estrutura do Xml do Layout S-5011
/*/
//-------------------------------------------------------------------
Function TAF497Xml(cAlias,nRecno,nOpc,lJob)
Local cXml    	as char
Local cLayout 	as char
Local cReg    	as char
Local cPeriodo	as char
Local cNumDoc	as char

Default lJob 	:= .F.
Default cAlias 	:= "V0C"
Default nRecno	:= 1
Default nOpc	:= 1

cLayout 	:= "5011"
cXml    	:= ""
cReg    	:= "TotalContrib" 
cPeriodo	:= Substr(V0C->V0C_PERAPU,3) + "-" + Substr(V0C->V0C_PERAPU,1,2) 
cNumDoc		:= ""

DBSelectArea("V0D")  
V0D->(DBSetOrder(1))

DBSelectArea("V0E")  
V0E->(DBSetOrder(1))

DBSelectArea("V0F") 
V0F->(DBSetOrder(1))

DBSelectArea("V0G")  
V0G->(DBSetOrder(1))

DBSelectArea("V0H")  
V0H->(DBSetOrder(1))

DBSelectArea("V0I")  
V0I->(DBSetOrder(1))

DBSelectArea("V0J")  
V0J->(DBSetOrder(1))

cXml +=		"<ideRecRetorno>"	
cXml +=			"<ideStatus>"	
cXml +=				xTafTag("cdRetorno"  ,V0C->V0C_CODRET)
cXml +=				xTafTag("descRetorno",V0C->V0C_DESCRE)	
If V0D->( MsSeek( xFilial( "V0D" ) + V0C->( V0C_ID + V0C_VERSAO) ) )	
	While V0D->(!Eof()) .And. V0D->( V0D_FILIAL + V0D_ID + V0D_VERSAO) == V0C->( V0C_FILIAL + V0C_ID + V0C_VERSAO)
		
		xTafTagGroup("regOcorrs" 	 ,{ { "tpOcorr"		  ,V0D->V0D_TPOCOR			,,.F. }; 
						   	  		 ,  { "localErroAviso",V0D->V0D_LOCERR			,,.F. };
						   	  		 ,  { "codResp"		  ,V0D->V0D_CODRES          ,,.F. };
						  	 	 	 ,  { "dscResp"		  ,V0D->V0D_DRESP			,,.F. }};
						  	 	 	 ,  @cXml)	
		V0D->( DbSkip() )								
	EndDo
EndIf
cXml +=			"</ideStatus>"
cXml +=		"</ideRecRetorno>"

cXml +=		"<infoRecEv>"
cXml +=				xTafTag("nrProtEntr",V0C->V0C_PROTEN)	
cXml +=				xTafTag("dhProcess",DTOS(V0C->V0C_DTPROC) + V0C->V0C_HRPROC)
cXml +=				xTafTag("tpEv",V0C->V0C_TPEVT)
cXml +=				xTafTag("idEv",V0C->V0C_IDEVT)
cXml +=				xTafTag("hash",V0C->V0C_HASH)		
cXml +=		"</infoRecEv>"

If V0E->( MsSeek( xFilial( "V0E" ) + V0C->( V0C_ID + V0C_VERSAO) ) )	
	While V0E->(!Eof()) .And. V0E->( V0E_FILIAL + V0E_ID + V0E_VERSAO) == V0C->( V0C_FILIAL + V0C_ID + V0C_VERSAO)
		cXml +=		"<infoTotalContrib>"
		cXml +=			xTafTag("nrRecArqBase"	,V0E->V0E_NRREC,,.T.)
		cXml +=			xTafTag("indExistInfo"	,V0E->V0E_INDEXI)
		
		if StrTran( Alltrim(V0C->V0C_LEIAUT),'_' ,'' ) >= "10501" .And. TafColumnPos( "V0E_IDDCTF" )
			cXml += xTafTag("identEscritDCTF", V0E->V0E_IDDCTF)
		endif

		If V0F->( MsSeek( xFilial( "V0F" ) + V0E->( V0E_ID + V0E_VERSAO + V0E_NRREC) ) )	
			While V0F->(!Eof()) .And. V0F->( V0F_FILIAL + V0F_ID + V0F_VERSAO + V0F_NRREC) == V0E->( V0E_FILIAL + V0E_ID + V0E_VERSAO + V0E_NRREC)
				xTafTagGroup("RTom" 	 ,{ { "cnpjPrestador"		, V0F->V0F_CNPJPR				    ,,.F. }; 
				   	  		 			 ,  { "vlrTotalBaseRet"		, TafFReinfNum(V0F->V0F_VLRBRE)		,,.F. };
				   	  		 			 ,  { "vlrTotalRetPrinc"	, TafFReinfNum(V0F->V0F_VLRPRI)     ,,.F. };
				   	  		 			 ,  { "vlrTotalRetAdic"		, TafFReinfNum(V0F->V0F_VLRADI)     ,,.T. };
				   	  		 			 ,  { "vlrTotalNRetPrinc"	, TafFReinfNum(V0F->V0F_VLRNPR)     ,,.T. };
				  	 	 	 			 ,  { "vlrTotalNRetAdic"	, TafFReinfNum(V0F->V0F_VLRNAD)		,,.T. }};
				  	 	 	 			 ,  @cXml)
				V0F->( DbSkip() )								
			EndDo
		EndIf
		
		If V0G->( MsSeek( xFilial( "V0G" ) + V0E->( V0E_ID + V0E_VERSAO + V0E_NRREC) ) )	
			While V0G->(!Eof()) .And. V0G->( V0G_FILIAL + V0G_ID + V0G_VERSAO + V0G_NRREC) == V0E->( V0E_FILIAL + V0E_ID + V0E_VERSAO + V0E_NRREC)
				
				xTafTagGroup("RPrest" 	 ,{ { "tpInscTomador"		, V0G->V0G_TPINST				    ,,.F. }; 
										 ,  { "nrInscTomador"		, V0G->V0G_NRINST			        ,,.F. };
				   	  		 			 ,  { "vlrTotalBaseRet"		, TafFReinfNum(V0G->V0G_VLRBRE)		,,.F. };
				   	  		 			 ,  { "vlrTotalRetPrinc"	, TafFReinfNum(V0G->V0G_VLRPRI)     ,,.F. };
				   	  		 			 ,  { "vlrTotalRetAdic"		, TafFReinfNum(V0G->V0G_VLRADI)     ,,.T. };
				   	  		 			 ,  { "vlrTotalNRetPrinc"	, TafFReinfNum(V0G->V0G_VLRNPR)     ,,.T. };
				  	 	 	 			 ,  { "vlrTotalNRetAdic"	, TafFReinfNum(V0G->V0G_VLRNAD)		,,.T. }};	
				  	 	 	 			 ,  @cXml)
				V0G->( DbSkip() )								
			EndDo
		EndIf
		
		If V0H->( MsSeek( xFilial( "V0H" ) + V0E->( V0E_ID + V0E_VERSAO + V0E_NRREC) ) )	
			While V0H->(!Eof()) .And. V0H->( V0H_FILIAL + V0H_ID + V0H_VERSAO + V0H_NRREC) == V0E->( V0E_FILIAL + V0E_ID + V0E_VERSAO + V0E_NRREC)
				
				xTafTagGroup("RRecRepAD" ,{ { "cnpjAssocDesp"	, V0H->V0H_CNPJAD					   ,,.F. }; 
										 ,  { "vlrTotalRep"		, TafFReinfNum(V0H->V0H_VLRREP)		   ,,.F. };
				   	  		 			 ,  { "vlrTotalRet"		, TafFReinfNum(V0H->V0H_VLRRET)		   ,,.F. };
				   	  		 			 ,  { "vlrTotalNRet"	, TafFReinfNum(V0H->V0H_VLRNRE)        ,,.T. }};	
				   	  		 			 ,  @cXml)
				V0H->( DbSkip() )								
			EndDo
		EndIf
		
		If V0I->( MsSeek( xFilial( "V0I" ) + V0E->( V0E_ID + V0E_VERSAO + V0E_NRREC) ) )	
			While V0I->(!Eof()) .And. V0I->( V0I_FILIAL + V0I_ID + V0I_VERSAO + V0I_NRREC) == V0E->( V0E_FILIAL + V0E_ID + V0E_VERSAO + V0E_NRREC)
				
				xTafTagGroup("RComl" 	 ,{ { "vlrCPApur"	, TafFReinfNum(V0I->V0I_VLRCPA)   ,,.F. };
										 ,  { "vlrRatApur"	, TafFReinfNum(V0I->V0I_VLRRAT)	  ,,.F. };
				   	  		 			 ,  { "vlrSenarApur", TafFReinfNum(V0I->V0I_VLRSEN)	  ,,.F. };
				   	  		 			 ,  { "vlrCPSusp"	, TafFReinfNum(V0I->V0I_VLRCPS)   ,,.T. };
				   	  		 			 ,  { "vlrRatSusp"	, TafFReinfNum(V0I->V0I_VLRRSU)   ,,.T. };
				   	  		 			 ,  { "vlrSenarSusp", TafFReinfNum(V0I->V0I_VLRSSU)   ,,.T. }};	
				   	  		 			 ,  @cXml)
				V0I->( DbSkip() )								
			EndDo
		EndIf
		
		If V0J->( MsSeek( xFilial( "V0J" ) + V0E->( V0E_ID + V0E_VERSAO + V0E_NRREC) ) )	
			While V0J->(!Eof()) .And. V0J->( V0J_FILIAL + V0J_ID + V0J_VERSAO + V0J_NRREC) == V0E->( V0E_FILIAL + V0E_ID + V0E_VERSAO + V0E_NRREC)
				
				xTafTagGroup("RCPRB" 	 ,{ { "codRec"			, V0J->V0J_CODREC				,,.F. }; 
										 ,  { "vlrCPApurTotal"	, TafFReinfNum(V0J->V0J_VLRCPT)	,,.F. };
				   	  		 			 ,  { "vlrCPRBSusp"		, TafFReinfNum(V0J->V0J_VLRCPS) ,,.T. }};	
				   	  		 			 ,  @cXml)
				V0J->( DbSkip() )								
			EndDo
		EndIf
		cXml +=		"</infoTotalContrib>"
		V0E->( DbSkip() )								
	EndDo
EndIf

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Estrutura do cabecalho³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cXml := TAFXmlReinf( cXml, "V0C", cLayout, cReg, cPeriodo,,"TotalContrib")

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Executa gravacao do registro³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If !lJob
	xTafGerXml(cXml,cLayout,,,,,,"R-" )
EndIf

Return(cXml)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF497Vld

@author Vitor Siqueira			
@since 10/03/2018
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF497Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro   as array
Local aDadosUtil as array
Local lValida    as logical   

Default lJob := .F.

aLogErro   := {}
aDadosUtil := {}
lValida    := V0C->V0C_STATUS $ ( " |1" )

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := V0C->( Recno() )

If !lValida
	aAdd( aLogErro, { "V0C_ID", "000305", "V0C", nRecno } ) //Registros que já foram transmitidos ao Fisco, não podem ser validados
Else
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ATUALIZO O STATUS DO REGISTRO³
	//³1 = Registro Invalido        ³
	//³0 = Registro Valido          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cStatus := Iif( Len( aLogErro ) > 0, "1", "0" )
	Begin Transaction 
		If RecLock( "V0C", .F. )
			V0C->V0C_STATUS := cStatus
			V0C->( MsUnlock() )
		EndIf
	End Transaction 
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nao apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	xValLogEr( aLogErro )
EndIf

Return(aLogErro)



//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition

@author Roberto Souza
@since 23/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()
	Private	oBrw 	as object

	If FunName() == "TAFXREINF"
		lMenuDif 	:= Iif( Type( "lMenuDif" ) == "U", .T., lMenuDif ) 
		cPerAReinf	:= Iif( Type( "cPerAReinf" ) == "U", "", cPerAReinf )

		cFiltro := "V0C_ATIVO == '1'" + IIf( !Empty(cPerAReinf) ," .AND. AllTrim(V0C_PERAPU) =='"+cPerAReinf+"'","" )
	Else
		cFiltro := "V0C_ATIVO == '1'"
	EndIf

	oBrw	:= FWmBrowse():New()

	oBrw:SetDescription( "R-5011 - "+STR0014 )	//"Informações de bases e tributos consolidadas por período de apuração"
	oBrw:SetAlias( 'V0C')
	oBrw:SetMenuDef( 'TAFA497' )	
	oBrw:SetFilterDefault( "V0C_ATIVO == '1'" )

	//DbSelectArea("V0C")
	//Set Filter TO &("V0C_ATIVO == '1'")

	TafLegend(2,"V0C",@oBrw)

	oBrw:Activate()

Return( oBrw )
