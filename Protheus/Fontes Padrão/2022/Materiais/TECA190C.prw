#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TECA190C.CH'

Static oTBitmap := Nil
Static cURLIn	:= ""
Static oTIBrwIn := Nil
Static lFile := .F.
Static cAppId := "AIzaSyCyWzVoFOzMgfDjfqPa5thMTG9wkasAPnI"
 
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
AD
@since 29/08/2013
@version 12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel := Nil
Local oStrABB := FWFormStruct( 1,"ABB"  )
Local oStrT48 := FWFormStruct( 1,"T48"  )

oModel := MPFormModel():New("TECA190C")
oModel:AddFields("ABBMASTER",/*cOwner*/,oStrABB)
oModel:AddGrid("T48DETAIL", "ABBMASTER", oStrT48)

oModel:SetRelation("T48DETAIL",{ { "T48_FILIAL", "xFilial('T48')" }, { "T48_CODABB", "ABB_CODIGO" } },T48->(IndexKey( 1 ) ) )
oModel:SetDescription( STR0001) //'Dados Check-in\out'

oModel:GetModel('T48DETAIL'):SetNoUpdateLine(.T.)
oModel:GetModel('T48DETAIL'):SetNoInsertLine(.T.)
oModel:GetModel('T48DETAIL'):SetNoDeleteLine(.T.)

oModel:GetModel('ABBMASTER'):SetDescription(STR0002) //'Agenda'
oModel:GetModel('T48DETAIL'):SetDescription(STR0003) //'Imagens'

oModel:SetVldActivate({|oModel| At190cVAct(oModel) })

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@since 29/08/2013
@version     P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView := Nil
Local oMdl := ModelDef()

Local oStrABB := FWFormStruct( 2,"ABB", {|cCampo| AllTrim(cCampo) $ "ABB_NOMTEC|ABB_DTINI|ABB_DTFIM|ABB_HRINI|ABB_HRFIM|ABB_DTFIM|ABB_OBSIN|ABB_OBSOUT|ABB_HRCHIN|ABB_HRCOUT"})
Local oStrT48 := FWFormStruct( 2,"T48", {|cCampo| AllTrim(cCampo) $ "T48_ITEM|T48_TIPO"})

oView := FWFormView():New()

oStrABB:SetProperty("*",MVC_VIEW_CANCHANGE,.F.)
oView:SetModel(oMdl)
oView:SetDescription( STR0004 ) // "Base x Ativo" //"Dados check-in\out"

oView:AddField("VIEWABB",oStrABB,"ABBMASTER")
oView:AddGrid("VIEWT48",oStrT48,"T48DETAIL")

//--------------------------------------
//        Cria os Box's
//--------------------------------------

oView:CreateVerticalBox( 'SUPESQ', 60)
oView:CreateVerticalBox( 'SUPDIR', 40)


oView:CreateHorizontalBox( "SUPERIOR", 50, 'SUPESQ' )  // Cabeçalho
oView:CreateHorizontalBox( "INFERIOR", 50,'SUPESQ'  )  // Grid


oView:AddOtherObject("VIEWIMG", {|oPanel|Tec190Img(oPanel,oView) })

oView:SetViewProperty( 'VIEWT48', "CHANGELINE", {{ |oView, cViewID| a190ChgLne(oView, cViewID) }} )

//--------------------------------------
//        Associa os componentes ao Box
//--------------------------------------
oView:SetOwnerView( 'VIEWABB', 'SUPERIOR' ) 
oView:SetOwnerView( 'VIEWT48' , 'INFERIOR' )
oView:SetOwnerView( 'VIEWIMG' , 'SUPDIR' )

oView:EnableTitleView('VIEWABB')
oView:EnableTitleView('VIEWT48')
oView:SetAfterViewActivate({||a190ChgLne()})

oView:AddUserButton(STR0005,"",{|oModel| a190cOpMap(Alltrim(ABB->ABB_LATIN),Alltrim(ABB->ABB_LONIN),Alltrim(ABB->ABB_LATOUT),Alltrim(ABB->ABB_LONOUT))})	//"Cons.Base Atend." 


Return oView 	


//-------------------------------------------------------------------
/*/{Protheus.doc} Tec190Img
@since 17/08/2017
@version     P12
/*/
//-------------------------------------------------------------------

Function Tec190Img(oPanel,oView	)
Local oGroupFoto := Nil
//Local aTFolder := { STR0003, STR0005} //'Localizacao check-in\out'
Local aTFolder := { STR0003} //'Localizacao check-in\out'
Local oTFolder  := Nil 
lFile := .F.

oTFolder := TFolder():New( 0,0,aTFolder,,oPanel,,,,.T.,,500,500)
//oTFolder:bSetOption:={|nFld| Tec190Map(nFld,Alltrim(ABB->ABB_LATIN),Alltrim(ABB->ABB_LONIN),Alltrim(ABB->ABB_LATOUT),Alltrim(ABB->ABB_LONOUT) )}
oTFolder:Align := 5
oTBitmap := TBitmap():New(10,; //1
							85,; //2
							200,;//3
							260,;//4
							,;//5
							,;//6
							.T.,;//7
							oTFolder:aDialogs[1] ,;//8
							,;//9
							,;//10
							.F.,;//11
							.F.,;//12
							,;//13
							,;//14
							.F.,;//15
							,;//16
							.T.,;//17
							,;//18
							.F.)//19
oTBitmap:Align := 5
							

//oTBitmap:lAutoSize := .T.
oTBitmap:lStretch := .T.


//oTIBrwIn := TIBrowser():New(0,0,365,283, '', oTFolder:aDialogs[2] )
Return .T.     


//-------------------------------------------------------------------
/*/{Protheus.doc} a190ChgLne
@since 17/08/2017
@version     P12
/*/
//-------------------------------------------------------------------
Function a190ChgLne()
Local oModel := FwModelActive()
Local cBase64	 := oModel:GetValue('T48DETAIL','T48_FOTO')
Local cteste	:= ""
Local nHandle 	:= 0
Local cFile :=   GetTempPath() + "image" + AllTrim(Str(oModel:GetModel('T48DETAIL'):GetDataId()))  + ".jpeg"


If !File(cFile)
	nHandle := FCREATE(cFile, 0)
	FWrite(nHandle, decode64(cBase64))
	FClose(nHandle)
EndIf	
		
If !IsBlind()
	oTBitmap:Load(,cFile)
EndIf	

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} a190FileMap
@since 17/08/2017
@version     P12
/*/
//-------------------------------------------------------------------
Function a190FileMap(cLatIn,cLongIn,cLatOut,cLongOut,cLatLoc,cLongLoc)

Local cHtml := ""
Local nHandle := 0
Local cFile := ""
Local nSleep := 1000
Local aCoords := {}

AADD(aCoords, {cLatIn, cLongIn, "Check-In", "red"})
AADD(aCoords, {cLatLoc, cLongLoc, "Local de atendimento", "green"})
If !Empty(cLatOut)
	AADD(aCoords, {cLatOut, cLongOut, "Check-out", "red"})
EndIf

cHtml := TECHTMLMap(STR0006,aCoords,"16",2)

cFile := GetTempPath() + "locationcheckin.html"

TECGenMap(cHtml, cFile, nSleep, .F.)

Return cFile

//-------------------------------------------------------------------
/*/{Protheus.doc} Tec190Map
@since 17/08/2017
@version     P12
/*/
//-------------------------------------------------------------------
Function Tec190Map(nFld,cLatIn,cLongIn,cTipo,cLatOut,cLongOut )
 

If nFld == 2 .And. !lFile 

	lFile := .T.
	MsgRun ( STR0012 , STR0013 , {|| A190LoadMap(cLatIn,cLongIn,cLatOut,cLongOut)}) 
		
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} A190LoadMap
@since 17/08/2017
@version     P12
/*/
//-------------------------------------------------------------------
Function A190LoadMap(cLatIn,cLongIn,cTipo,cLatOut,cLongOut)
Local cURLIn := ""


cURLIn := a190FileMap(cLatIn,cLongIn,cLatOut,cLongOut)
	
oTIBrwIn:Navigate(cURLIn)

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} At190cVAct
@since 30/08/2017
@version     P12
/*/
//-------------------------------------------------------------------
Function At190cVAct(oModel)
Local lRet  := .F.
Local cTemp := GetNextAlias()

BeginSQL Alias cTemp
		
	SELECT 
		1
	FROM 	
		%Table:T48% T48
	WHERE 
		T48.T48_FILIAL = %Exp:xFilial("T48")% AND
		T48.T48_CODABB = %Exp:ABB->ABB_CODIGO% AND
		T48.T48_TIPO IN ('1','3') AND
		T48.%NotDel%
 EndSql

lRet := ( cTemp )->( !Eof() )
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} a190cOpMap
@since 31/08/2017
@version     P12
/*/
//-------------------------------------------------------------------
Function a190cOpMap(cLatIn,cLonIn,cLatOut,cLonOut)
Local cFile := ""
Local aLocal := ""
Local cLatiLoc := ""
Local cLonLoc := ""

If !lFile
	lFile := .T.
	aLocal := a190llLoc(ABB->ABB_LOCAL)
	cLatiLoc := aLocal[1]
	cLonLoc := aLocal[2]
	cFile := a190FileMap(cLatIn,cLonIn,cLatOut,cLonOut,cLatiLoc,cLonLoc)
Else
	cFile := GetTempPath() + "locationcheckin.html" 	
EndIf	
ShellExecute("open",cFile ,"","",2) // 5=SW_SHOW

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} a190llLoc
@since 06/09/2017
@version     P12
/*/
//-------------------------------------------------------------------
Function a190llLoc(cCodLocal)
Local aRet := {}
Local aArea       := GetArea()

ABS->(DbSetOrder(1)) //ABS_LOCAL

If ABS->(DbSeek(xFilial("ABS")+cCodLocal))
	Aadd(aRet,ABS->ABS_LATITU)
	Aadd(aRet,ABS->ABS_LONGIT)
EndIf 	

RestArea(aArea)
Return aRet