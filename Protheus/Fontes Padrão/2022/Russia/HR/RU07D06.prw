#include 'parmtype.ch'
#INCLUDE "Protheus.ch"
#INCLUDE "RU07D06.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

Static 	cDocType	as	Character 	

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU07D06
Employee Documents Routine - Used to add and show documents 
@author natasha
@since 18/05/2018
@version P12.1.21
@type function
/*/
Function RU07D06()
Local oBrowse 		as Object

oBrowse := BrowseDef()
oBrowse:Activate()

	
Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse Definition
@author natasha
@since 18/05/2018
@version P12.1.21
@type function
/*/
Static Function BrowseDef()
Local oBrwTMP 	as Object

oBrowse	:= FWmBrowse():New()
oBrowse:SetAlias( "SRA" )
oBrowse:SetDescription( STR0001 ) // "Documents"  
oBrowse:DisableDetails() 
	
Return ( oBrowse ) 

//-----------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Definition.
@author natasha
@since 18/05/2018
@version P12.1.21
@type function
/*/
Static Function MenuDef()
Local aRotina as Array

aRotina := {}

ADD OPTION aRotina TITLE STR0004	ACTION 'RUD76Upd' 	OPERATION 4 ACCESS 0 //"Update"
ADD OPTION aRotina TITLE STR0025	ACTION 'RUD76VAll' 	OPERATION 2 ACCESS 0 //"View Doc. Included"

Return aRotina

//-----------------------------------------------------------------------
/*/{Protheus.doc} RUD76Upd
Update functio
@author natasha
@since 18/05/2018
@version P12.1.21
@type function
/*/
Function RUD76Upd()
Local aType 		as Array
Local lContinue 	as Logical

lContinue 	:= .T.
aType 		:= {}
cDocType	:= ""

While lContinue
	aType := RUD76TypD()
	lContinue := aType[2] 
	If lContinue
		cDocType := aType[1]
		If AllTrim(cDocType)!=''
			FWExecView(STR0001,"RU07D06",4,,{|| .T.})
		Endif
	Endif
EndDo

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} RUD76Upd
Update functio
@author natasha
@since 18/05/2018
@version P12.1.21
@type function
/*/
Function RUD76VAll()

cDocType	:= ""

FWExecView(STR0010,"RU07D06",4,,{|| .T.})

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} RUD76TypD
Selection of Type of Document
@author natasha
@since 18/05/2018
@version P12.1.21
@type function
/*/
Function RUD76TypD()
Local lClose	as Logical 

lClose := .F.

If !isBlind()
	lClose		:= Pergunte("RU07D06",.T.,STR0001)
	cDocType	:= MV_PAR01
EndIf                                                       


Return {cDocType,lClose}

//-----------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef Definition.
@author natasha
@since 18/05/2018
@version P12.1.21
@type function
/*/
Static Function ModelDef()
Local oStrEmpRD0 	as Object
Local oStrDocTMP 	as Object
Local oModel		as Object
Local oStructF4J 	as Object
Local oStructSRB 	as Object
Local oStructF4M 	as Object
Local oStructF4L 	as Object	 
Local oStructF4H 	as Object
Local oStructF4G	as Object
Local oStructDoc	as Object
Local oStrF4G as Object
Local oStrF4M as Object
Local oStrF4H as Object
Local oStrALL as Object
Local cRaCodunic 	As Char
Local cRd0Codigo 	As Char

cRaCodunic := SRA->RA_CODUNIC

cRd0Codigo := Posicione("RD0", 1, xFilial("RD0") + cRaCodunic, "RD0->RD0_CODIGO")

If cRd0Codigo != cRaCodunic
	Help(Nil, Nil, "ERROR", Nil, STR0010, 1, 0)
EndIf


oModel:= MPFormModel():New("RU07D06", /*bPreValid*/,/* bTudoOK*/, /* */, /*bCancel*/)
oModel:SetDescription( STR0001 ) //"Documents"  
    
// Header structure - RD0 Persons
oStrEmpRD0 := FWFormStruct(1, "RD0", {|cCampo| "|"+ AllTrim(cCampo) + "|" $ "|RD0_FILIAL|RD0_CODIGO|RD0_NOME|RD0_DTADMI|RD0_CIC|RD0_DTNASC|"})
oModel:AddFields("RU07_MRD0", NIL, oStrEmpRD0 )
oModel:GetModel("RU07_MRD0"):SetDescription( STR0007 ) //"Personal Data" 
oModel:GetModel("RU07_MRD0"):SetOnlyQuery(.T.)
oModel:GetModel("RU07_MRD0"):SetOnlyView(.T.)

// Submodels for Update Documents -- START
// F4G Documents 
If !Empty(cDocType)
	oStrF4G := FWFormStruct(1, "F4G")
	oModel:AddGrid("RU07D06_MF4G", "RU07_MRD0", oStrF4G, /*bPreValidacao*/, /*bPosValidacao*/,,,  /* bLoad {|oModel| fLoadF4G(oModel)}*/  )
	oModel:GetModel("RU07D06_MF4G"):SetDescription( STR0001 ) //"Documents" 
	oModel:GetModel("RU07D06_MF4G"):SetOptional( .T. ) 
	oModel:GetModel("RU07D06_MF4G"):SetUniqueLine( {'F4G_DOCSEQ','F4G_NMR','F4G_DISSUE','F4G_DTEXY'} )
	oModel:SetPrimaryKey({'F4G_FILIAL','F4G_CODE ','F4G_DOCIDE', 'F4G_DOCSEQ'})
	oModel:SetRelation("RU07D06_MF4G", { { "F4G_FILIAL", 'RD0_FILIAL' }, { "F4G_CODE", 'RD0_CODIGO' } , {"F4G_DOCIDE" , "'"+cDocType+"'" } }, F4G->( IndexKey( 1 ) ) )
	// F4M SNILS
	oStrF4M := FWFormStruct(1, "F4M")
	oModel:AddGrid("RU07D06_MF4M", "RU07_MRD0", oStrF4M,, /*bLinOk*/  )	
	oModel:GetModel("RU07D06_MF4M"):SetDescription(STR0008) //"SNILS" 
	oModel:GetModel("RU07D06_MF4M"):SetOptional( .T. ) 
	oModel:GetModel("RU07D06_MF4M"):SetNoInsertLine( .T. ) 
	oModel:GetModel("RU07D06_MF4M"):SetUniqueLine( {'F4M_SEQ','F4M_SNILS','F4M_DTBSNL'} )
	oModel:SetPrimaryKey({'F4M_FILIAL','F4M_CODE ','F4M_SEQ'})
	oModel:SetRelation( "RU07D06_MF4M", { { "F4M_FILIAL", 'RD0_FILIAL' }, { "F4M_CODE", 'RD0_CODIGO' }, { "F4M_SNILS", 'RD0_CIC' } }, F4M->( IndexKey( 1 ) ) )
	// F4H Military Services
	oStrF4H := FWFormStruct(1, "F4H")
	oModel:AddGrid("RU07D06_MF4H", "RU07_MRD0", oStrF4H,, /*bLinOk*/  )
	oModel:GetModel("RU07D06_MF4H"):SetDescription( STR0009 ) //"Military Services" 
	oModel:GetModel("RU07D06_MF4H"):SetOptional( .T. ) 
	oModel:GetModel("RU07D06_MF4H"):SetUniqueLine( {'F4H_SEQ','F4H_MSSERS','F4H_MSNBR'} )
	oModel:SetPrimaryKey({'F4H_FILIAL','F4H_CODE', 'F4H_SEQ','F4H_MSNBR'})
	oModel:SetRelation( "RU07D06_MF4H", { { "F4H_FILIAL", 'RD0_FILIAL' }, { "F4H_CODE", 'RD0_CODIGO' } }, F4H->( IndexKey( 1 ) ) )
	//Submodels for Update Documents -- END
EndIf

// Items structure - Documents Included
oStrALL := DefStrMDoc()
oModel:AddGrid("RU07D06_MALL", "RU07_MRD0", oStrALL, /*bPreValidacao*/	, /*bPosValidacao*/	,,, {|oModel| fLoadALL(oModel)}/* bLoad*/   )
oModel:GetModel("RU07D06_MALL"):SetDescription( STR0010) // Documents Included
oModel:GetModel("RU07D06_MALL"):SetOnlyQuery(.T.)
oModel:GetModel("RU07D06_MALL"):SetOnlyView(.T.)
oModel:GetModel('RU07D06_MALL'):SetOptional(.T.)
oModel:SetRelation( "RU07D06_MALL", { { "DOCBRANCH", 'RD0_FILIAL' }, { "EMPLCODE", 'RD0_CODIGO' } }/*, ("EDCS")->( IndexKey( 1 ) )*/ )


oModel:SetVldActivate( { |oModel| .T. } )
oModel:SetActivate( { |oModel| fInitModel( oModel,oModel:GetOperation() ) } ) 


Return ( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Definition.
@author raquel.andrade
@since 19/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ViewDef()
Local oView 		as Object
Local oModel 		as Object
Local oStrEmpRD0 	as Object
Local oStrF4G 		as Object
Local oStrF4H 		as Object
Local oStrF4M 		as Object
Local oStrUpd 		as Object
Local oStrDocALL 	as Object
Local cModel 		as Character
Local cTitle		as Character
Local cShowFlds 	as Character

cModel:=''
cShowFlds:= ''
If !Empty(cDocType)
	If !(AllTrim(cDocType) == '16' .Or. AllTrim(cDocType)=='21'  .Or. AllTrim(cDocType) =='22')
		cShowFlds+="|F4G_SERIES"
	EndIf
	
	If !(AllTrim(cDocType) == '21')
		cShowFlds+="|F4G_SUBCD"
	EndIf
	
	If !(AllTrim(cDocType) == '28')
		cShowFlds+="|F4G_CATEG"
	EndIf
	
	If !(AllTrim(cDocType) == '16')
		cShowFlds+="|F4G_TPACT"
	EndIf
EndIf

oModel := FWLoadModel("RU07D06")

oView := FWFormView():New()
oView:SetModel(oModel)

// Header structure - RD0 Persons
oStrEmpRD0 := FWFormStruct(2, "RD0", {|cCampo| "|"+ AllTrim(cCampo) + "|" $ "|RD0_CODIGO|RD0_NOME|RD0_DTADMI|RD0_CIC|RD0_DTNASC|"})
oStrEmpRD0:SetNoFolder()
oView:AddField("RU07D06_VRD0", oStrEmpRD0, "RU07_MRD0" )
oView:SetViewProperty("RU07D06_VRD0","OnlyView")


// Views for Documents Update
If !Empty(cDocType)
	cTitle	:=	fDescRCC("S025", cDocType,1,3,4,50)  
	If AllTrim(cDocType) == "802" // Snils
		oStrUpd:= FWFormStruct(2, "F4M") // Snils
		oStrUpd:RemoveField( "F4M_CODE" )
		cModel:="RU07D06_MF4M"	
	ElseIf  AllTrim(cDocType) == "07"
		oStrUpd:= FWFormStruct(2, "F4H") //Military Card
		oStrUpd:RemoveField( "F4H_CODE" )
		cModel:="RU07D06_MF4H"
	Else
		oStrUpd:= FWFormStruct(2, "F4G", {|x| !(AllTrim(x) $ cShowFlds)}) //Documents
		oStrUpd:RemoveField( "F4G_CODE" )
		oStrUpd:RemoveField( "F4G_DOCIDE" )
		cModel:="RU07D06_MF4G"
	EndIf
	
	oView:AddGrid("RU07D06_VUPD", oStrUpd, cModel )
	
	If AllTrim(cDocType) == "802" // Snils
		oView:AddIncrementField( "RU07D06_VUPD", "F4M_SEQ" )
	ElseIf  alltrim(cDocType) == "07" // Military Card
		oView:AddIncrementField( "RU07D06_VUPD", "F4H_SEQ" )
	Else
		oView:AddIncrementField( "RU07D06_VUPD", "F4G_DOCSEQ" )
	EndIf
EndIf

// Temporary Structure for All Documents
If !Empty(cDocType)
	oStrDocALL := DefStrVALL()
	oView:AddGrid("RU07D06_VALL", oStrDocALL, "RU07D06_MALL" )
	oView:SetViewProperty("RU07D06_VALL","OnlyView")
	
	oView:CreateHorizontalBox( 'SUPERIOR'	, 15 )
	oView:CreateHorizontalBox( 'INFERIOR'  	, 85 )
	oView:CreateFolder( 'PASTAS' , 'INFERIOR' )
	
	oView:AddSheet( 'PASTAS', 'FLD01', cTitle ) 	// Document Selected
	oView:AddSheet( 'PASTAS', 'FLD02', STR0010 )	//"Documents Included" 
	
	oView:CreateHorizontalBox( 'ITEM1', 100,,,'PASTAS','FLD01' )
	oView:CreateHorizontalBox( 'ITEM2', 100,,,'PASTAS','FLD02' )
	
	oView:SetOwnerView( 'RU07D06_VRD0' , 'SUPERIOR'  )
	oView:SetOwnerView( 'RU07D06_VUPD' , 'ITEM1'  )
	oView:SetOwnerView( 'RU07D06_VALL' , 'ITEM2'  )
Else
	oStrDocALL := DefStrVALL()
	oView:AddGrid("RU07D06_VALL", oStrDocALL, "RU07D06_MALL" )
	oView:SetViewProperty("RU07D06_VALL","OnlyView")
	
	oView:CreateHorizontalBox( 'SUPERIOR'	, 15 )
	oView:CreateHorizontalBox( 'INFERIOR'  	, 85 )
	oView:CreateFolder( 'PASTAS' , 'INFERIOR' )
	
	oView:AddSheet( 'PASTAS', 'FLD01', STR0010 )	//"Documents Included" 
	
	oView:CreateHorizontalBox( 'ITEM1', 100,,,'PASTAS','FLD01' )
	
	oView:SetOwnerView( 'RU07D06_VRD0' , 'SUPERIOR'  )
	oView:SetOwnerView( 'RU07D06_VALL' , 'ITEM1'  )
EndIf

oView:SetCloseOnOk( { || .T. } )

Return ( oView )

//-----------------------------------------------------------------------
/*/{Protheus.doc} fInitModel
Initialization of Model.
@author raquel.andrade
@since 19/05/2018
@version P12.1.21
@type function
/*/
Static Function fInitModel( oModel,nOperation )
Local oGrid 	as Object

If !Empty(cDocType) .And. nOperation == MODEL_OPERATION_UPDATE
	If cDocType = '802'
		oGrid := oModel:GetModel('RU07D06_MF4M')
		oGrid:GoLine(1)
		oGrid:LoadValue( "F4M_SNILS", RD0->RD0_CIC)  
	EndIf
EndIf

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} DefStrMDoc
All Documents Temporary Table Structure Definition.
@author natasha
@since 18/05/2018
@version P12.1.21
@type function
/*/
Function DefStrMDoc()
Local aArea 		as Array
Local oStruct 		as Object

aArea		:= 	GetArea()
oStruct 	:= 	FWFormModelStruct():New()

// Table 
oStruct:AddTable(" EDCS", , STR0010) // Documents Included

// Indixes 
oStruct:AddIndex( 	1	      						, ;     // [01] Index Order
					"01"   							, ;     // [02] ID
					"DOCBRANCH+EMPLCODE+ID+SEQ"		, ; 	// [03] Key of Index
					"Doc_Tmp_Main"            	 	, ;     // [04] Description of Index
					""       						, ;    	// [05] Lookup Expression 
					"" 								, ;    	// [06] Index Nickname
					.T. )      								// [07] Index used on interface


// Fields
//				 Titulo 	,ToolTip		,Id do Field	,Tipo	,Tamanho					,Decimal,	Valid	,When	,Combo	,Obrigatorio,Init	,Chave	,Altera	,Virtual
oStruct:AddField(STR0011	, STR0011		,"DOCBRANCH" 	,"C"	,6	   							,0		,Nil	,Nil	,{}		,.F.		,Nil	,NIL	,NIL	,.F.)   // Branch - don't really use it
oStruct:AddField(STR0012	, STR0012		,"EMPLCODE" 	,"C"	,6								,0		,Nil	,Nil	,{}		,.F.		,Nil	,NIL	,NIL	,.F.)   // Standard ID of Document from S025
oStruct:AddField(STR0013	, STR0013		,"SEQ" 			,"C"	,3								,0		,Nil	,Nil	,{}		,.F.		,Nil	,NIL	,NIL	,.F.)   // Sequence
oStruct:AddField(STR0014	, STR0014		,"ID" 			,"C"	,3								,0		,Nil	,Nil	,{}		,.F.		,Nil	,NIL	,NIL	,.F.)   // Standard ID of Document from S025
oStruct:AddField(STR0015	, STR0015		,"DOCDESC" 		,"C"	,100							,0		,Nil	,Nil	,{}		,.F.		,Nil	,NIL	,NIL	,.F.)   // Description of Document from S025
oStruct:AddField(STR0016	, STR0016		,"SERIES" 		,"C"	,TamSX3("F4G_SERIES")[1]		,0		,Nil	,Nil	,{}		,.F.		,Nil	,NIL	,NIL	,.F.)   // Seris
oStruct:AddField(STR0017	, STR0017		,"NMR" 			,"C"	,TamSX3("F4M_SNILS")[1]			,0		,Nil	,Nil	,{}		,.F.		,Nil	,NIL	,NIL	,.F.)   // Number
oStruct:AddField(STR0018	, STR0018		,"DISSUE" 		,"D"	,TamSX3("F4G_DISSUE")[1]		,0		,Nil	,Nil	,{}		,.F.		,Nil	,NIL	,NIL	,.F.)   // Date Issue
oStruct:AddField(STR0019	, STR0019		,"DTEXY" 		,"C"	,TamSX3("F4G_DTEXY")[1]			,0		,Nil	,Nil	,{}		,.F.		,Nil	,NIL	,NIL	,.F.)   // Date Expiry

RestArea(aArea)
Return (oStruct)


//-----------------------------------------------------------------------
/*/{Protheus.doc} DefStrVALL
All Documents Temporary Table View Definition.
@author natasha
@since 18/05/2018
@version P12.1.21
@type function
/*/
Function DefStrVALL()
Local aArea 	as Array
Local oStruct 	as Object

aArea		:= 	GetArea()
oStruct 	:= 	FWFormViewStruct():New()

oStruct:AddField("ID"			,"04"	,STR0014	, STR0014		,NIL 	,"C"	,"@!"	,NIL	,''	,.F.	,''		,''		,{}		,0	,''		,.F.) 
oStruct:AddField("DOCDESC"		,"05"	,STR0015	, STR0015		,NIL 	,"C"	,"@!"	,NIL	,''	,.F.	,''		,''		,{}		,0	,''		,.F.)
oStruct:AddField("SERIES"		,"06"	,STR0016	, STR0016		,NIL 	,"C"	,"@!"	,NIL	,''	,.F.	,''		,''		,{}		,0	,''		,.F.) 
oStruct:AddField("NMR"			,"07"	,STR0017	, STR0017		,NIL 	,"C"	,"@!"	,NIL	,''	,.F.	,''		,''		,{}		,0	,''		,.F.) 
oStruct:AddField("DISSUE"		,"08"	,STR0018	, STR0018		,NIL 	,"C"	,"@!"	,NIL	,''	,.F.	,''		,''		,{}		,0	,''		,.F.) 
oStruct:AddField("DTEXY"		,"09"	,STR0019	, STR0019		,NIL 	,"C"	,"@!"	,NIL	,''	,.F.	,''		,''		,{}		,0	,''		,.F.) 


Return ( oStruct )

//-----------------------------------------------------------------------
/*/{Protheus.doc} fLoadALL
Load of All recorded Documents (last sequence)
@author natasha
@since 18/05/2018
@version P12.1.21
@type function
/*/
Function fLoadALL(oModelDoc as Object)
Local aLines		as Array
Local oModel 		as Object
Local cTab 			as Character
local cQuery    	as Character
Local aAreaTmp 		as Array
Local cEmpl 		as Character

aLines	:={}
oModel 	:= oModelDoc:GetModel()	
cEmpl	:= oModel:getModel("RU07_MRD0"):GetValue("RD0_CODIGO")

cQuery := " SELECT * FROM (( SELECT F4G_FILIAL AS FILIAL, F4G_CODE AS CODE, F4G_DOCSEQ AS SEQ, F4G_DOCIDE as DOCIDE , "
cQuery += " F4G_SERIES as SERIES, F4G_NMR as NUM, F4G_DISSUE as DISSUE, F4G_DTEXY as DEXY "
cQuery += " FROM " + RetSQLName("F4G") + " F4G "
cQuery += " INNER JOIN " + RetSQLName("RCC") + " RCC ON trim(F4G_DOCIDE)= trim(left(RCC_CONTEU,3)) AND RCC.RCC_CODIGO = 'S025'"
cQuery += " WHERE F4G_CODE='" + cEmpl + "' AND (cast(F4G_DTEXY as Date) >= cast('"+ DTOS(Date())+"' as Date) OR F4G_DTEXY = '') "
cQuery += " AND F4G.F4G_FILIAL = '" + xFilial("F4G") + "' AND F4G.D_E_L_E_T_= ' ' "
cQuery += " AND RCC.RCC_FILIAL = '" + xFilial("RCC") + "' AND RCC.D_E_L_E_T_= ' ' )"

cQuery += " UNION (SELECT F4M_FILIAL as FILIAL, F4M_CODE as CODE, F4M_SEQ as SEQ," + "'802'" + " as DOCIDE , " 
cQuery += " '' as SERIES, F4M_SNILS as NUM, '' as DISSUE, '' as DEXY " 
cQuery += " FROM " + RetSQLName("F4M") + " F4M  "
cQuery += " INNER JOIN " + RetSQLName("RCC") + " RCC on trim(left(RCC_CONTEU,3))='802' AND RCC.RCC_CODIGO = 'S025' "
cQuery += " WHERE F4M_CODE='" + cEmpl + "' AND F4M.F4M_FILIAL = '" + xFilial("F4M") + "' AND F4M.D_E_L_E_T_= ' ' "
cQuery += " AND RCC.RCC_FILIAL = '" + xFilial("RCC")+ "' AND RCC.D_E_L_E_T_= ' ' )"

cQuery += "  UNION (SELECT F4H_FILIAL as FILIAL, F4H_CODE as CODE, F4H_SEQ as SEQ," + "'07'" + " as DOCIDE, "
cQuery += " F4H_MSSERS as SERIES, F4H_MSNBR as NUM, F4H_DISSUE as DISSUE, F4H_DTEXY as DEXY FROM " +  RetSQLName("F4H") + " F4H "
cQuery += " INNER JOIN " + RetSQLName("RCC") + " RCC ON trim(left(RCC_CONTEU,3))='07' AND RCC.RCC_CODIGO = 'S025'"
cQuery += " WHERE F4H_CODE='" + cEmpl + "' AND F4H.D_E_L_E_T_= ' ' AND (cast(F4H_DTEXY as Date) >= cast ('"+ DTOS(Date())+"' as Date) OR F4H_DTEXY = ' ' ) " 
cQuery += " AND F4H.F4H_FILIAL = '" + xFilial("F4H") + "' AND F4H.D_E_L_E_T_= ' ' 
cQuery += " AND RCC.RCC_FILIAL = '" + xFilial("RCC") + "' AND RCC.D_E_L_E_T_= ' ' ) "

cQuery += " ) as T1  ORDER BY FILIAL , Code , SEQ  DESC "

cQuery := ChangeQuery(cQuery)

nStatus := TCSqlExec(cQuery)

cTab := CriaTrab( , .F.)
TcQuery cQuery New Alias ((cTab))

aAreaTmp:=(cTab)->(GetArea())

While (cTab)->(!EOF())  
	AADD(aLines,{0,{xFILIAL("RCC"),(cTab)->CODE , (cTab)->SEQ, (cTab)->DOCIDE, fDescRCC("S025",(cTab)->DOCIDE,1,3,4,50), (cTab)->SERIES, If((cTab)->DOCIDE = "802", Transform((cTab)->NUM,"@R 999-999-999 99"), (cTab)->NUM), STOD((cTab)->DISSUE), STOD((cTab)->DEXY) }})
	(cTab)->(DBSkip())
Enddo

// If array aLines is empty we need to fill it in with at least one empty string
If( Len( aLines ) = 0 )
    AADD( aLines, { 0, { xFILIAL( "RCC" ), "", "", "", "", "", "", "", CTod(" / / "), CTod(" / / ") } } )
EndIf

RestArea(aAreaTmp)

Return (aLines)


//-----------------------------------------------------------------------
/*/{Protheus.doc} RU07SRTALL
@author natasha
@since 18/05/2018
@version P12.1.21
@type function
/*/
Function RU07SRTALL(oModel,aLines,cModelALL)
Local oModelALL	:= oModel:GetModel("RU07D01_MALL")
Local aCpoALL	:= oModelALL:GetStruct():GetFields()
Local nCampo	:= 0
Local nPos as Numeric
Local aRetorno as Array

aRetorno := Array(Len(aCpoALL))
For nCampo := 1 To Len( aLines )
	If ( nPos := aScan( aCpoALL, { |x| AllTrim( x[3] ) ==  AllTrim( aLines[nCampo][1] ) } ) ) > 0
		If aLines[nCampo][2] <> Nil
			aRetorno[nPos]:= aLines[nCampo][2]
		EndIf
	EndIf
Next nCampo

aRetorno[Len(aRetorno)] := aLines[Len(aF4G)][2]

Return (aRetorno)

//-----------------------------------------------------------------------
/*/{Protheus.doc} fGetDocs
Return array with code and description of
all existent Type of Documents on table S025
@author raquel
@since 19/05/2018
@version P12.1.21
@type function
/*/
Function fGetDocs()
Local aAreaRCC	as Array
Local aTpDocs	as Array

aTpDocs	:= {}
aAreaRCC	:=RCC->(GetArea())

dbSelectArea("RCC")
RCC->(dbSetOrder(1))
RCC->(dbSeek(xFilial("RCC")+"S025")) 
While ("RCC")->(!EOF())  .and. (RCC->(RCC_FILIAL+RCC_CODIGO) == (xFilial("RCC")+"S025"))
	AADD(aTpDocs,{LEFT(RCC->RCC_CONTEU,3) /*code of document*/,SUBSTR(RCC->RCC_CONTEU,4,LEN(RCC->RCC_CONTEU)-3) /*description*/})	
	("RCC")->(DBSkip())
EndDo

RestArea(aAreaRCC)

Return (aTpDocs)

//-----------------------------------------------------------------------
/*/{Protheus.doc} fRUD06Vld
Validation for F4G_SERIES and F4G_NMR length
@author natasha
@since 04/04/2018
@version 1.0
@project MA3 - Russia
/*/
Function fRUD06Vld()   
Local lRet 		as Logical
Local cMem 		as Character
Local cFld 		as Character
Local nLen 		as Numeric

lRet	:=	.T.
cMem	:=	ReadVar() 
cFld	:=	Substr(cMem,4,Len(cMem)) 
nLen	:=	Len(AllTrim(FwFldGet(cFld))) 

// 16 - Labor Permit
If cFld == "F4G_SERIES" .And. AllTrim(cDocType) == '16' .and. nLen!=2 // Labour Permit
	lRet:=.F.
EndIf

// 21 - Passport of a citizen of the Russian Federation
If cFld == "F4G_SERIES" .And. AllTrim(cDocType) == '21' .and. nLen!=4  
	lRet:=.F.
EndIf

If cFld == "F4G_NMR" .And.  AllTrim(cDocType) == '21' .and. nLen!=6  
	lRet:=.F.
EndIf

// 22 - Foreign Passport of a citizen of the Russian Federation
If cFld == "F4G_SERIES" .And. AllTrim(cDocType) == '22' .and. nLen!=2 
	lRet:=.F.
EndIf

If cFld == "F4G_NMR" .And. AllTrim(cDocType) == '22' .and. nLen!=10  
	lRet:=.F.
EndIf

// INN
If cFld == "F4G_NMR" .And. AllTrim(cDocType) == '801' .and. nLen!=12 
	lRet:=.F.
EndIf


Return (lRet)
// Russia_R5
