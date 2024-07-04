#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TECA450.CH"
#INCLUDE "Fileio.ch"

Static oTBitmap := Nil
Static lFile := .F.
 
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
Local oStrAB6 := FWFormStruct( 1,"AB6"  )
Local oStrTXM := FWFormStruct( 1,"TXM"  )

//Adiciona o campo para receber a imagem para o botão calcular
oStrTXM:AddField(" ", "", "BTNVIEW", "C", 10, 0, {||.T.}, NIL, {}, NIL, FwBuildFeature(STRUCT_FEATURE_PICTVAR, "'BMPVISUAL'"), NIL, NIL, .F.)

oModel := MPFormModel():New("TECA450A")
oModel:AddFields("AB6MASTER",/*cOwner*/,oStrAB6)
oModel:AddGrid("TXMDETAIL", "AB6MASTER", oStrTXM)

oModel:SetRelation("TXMDETAIL",{ { "TXM_FILIAL", "xFilial('TXM')" }, { "TXM_NUMOS", "AB6_NUMOS" } },TXM->(IndexKey( 1 ) ) )
oModel:SetDescription(STR0110) //"Detalhes Atendimento O.S"

oModel:GetModel('TXMDETAIL'):SetNoUpdateLine(.T.)
oModel:GetModel('TXMDETAIL'):SetNoInsertLine(.T.)
oModel:GetModel('TXMDETAIL'):SetNoDeleteLine(.T.)

oModel:GetModel('AB6MASTER'):SetDescription(STR0111)//"Ordem de Serviço"
oModel:GetModel('TXMDETAIL'):SetDescription(STR0112) //'Imagens'

oModel:SetVldActivate({|oModel| At450AVAct(oModel) })

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

Local oStrAB6 := FWFormStruct( 2,"AB6", {|cCampo| AllTrim(cCampo) $ "AB6_NUM0S|AB6_CODCLI|AB6_APPSTA|AB6_APPDTI|AB6_APPHRI|AB6_APPDCH|AB6_APPHCH"})
Local oStrTXM := FWFormStruct( 2,"TXM", TECA450ACPO() )


oView := FWFormView():New()

oStrAB6:SetProperty("*",MVC_VIEW_CANCHANGE,.F.)
oView:SetModel(oMdl)
oView:SetDescription( STR0110 ) // "Detalhes Atendimento O.S"

oView:AddField("VIEWAB6",oStrAB6,"AB6MASTER")
oView:AddGrid("VIEWTXM",oStrTXM,"TXMDETAIL")

//--------------------------------------
//        Cria os Box's
//--------------------------------------

oView:CreateVerticalBox( 'SUPESQ', 60)
oView:CreateVerticalBox( 'SUPDIR', 40)


oView:CreateHorizontalBox( "SUPERIOR", 50, 'SUPESQ' )  // Cabeçalho
oView:CreateHorizontalBox( "INFERIOR", 50,'SUPESQ'  )  // Grid


oView:AddOtherObject("VIEWIMG", {|oPanel|Tec450AImg(oPanel,oView) })

oView:SetViewProperty( 'VIEWTXM', "CHANGELINE", {{ |oView, cViewID| a450AChgLne() }} )

//--------------------------------------
//        Associa os componentes ao Box
//--------------------------------------
oView:SetOwnerView( 'VIEWAB6', 'SUPERIOR' ) 
oView:SetOwnerView( 'VIEWTXM' , 'INFERIOR' )
oView:SetOwnerView( 'VIEWIMG' , 'SUPDIR' )

//Botão na grid de atendentes
oStrTXM:AddField("BTNVIEW"/*<cIdField>*/,;
                  "ZZ"/*<cOrdem>*/,;
                  ""/*<cTitulo>*/,;	//"Visualizar"
                  " "/*<cDescric>*/,;
                  {}/*<aHelp>*/,;
                  "C"/*<cType>*/,;
                  "@BMP"/*<cPicture>*/,;
                  NIL/*<bPictVar>*/,;
                  ""/*<cLookUp>*/,;
                  .F./*<lCanChange>*/,;
                  NIL/*<cFolder>*/,;
                  NIL/*<cGroup>*/,;
                  {}/*[aComboValues]*/,;
                  NIL/*[nMaxLenCombo]*/,;
                  NIL/*<cIniBrow>*/,;
                  .T./*<lVirtual>*/,;
                  NIL/*<cPictVar>*/,;
                  /*[lInsertLine]*/,;
                  /*[nWidth]*/)

//Duplo-click da grid
oView:SetViewProperty("VIEWTXM", "GRIDDOUBLECLICK", {{|oFormulario, cFieldName, nLineGrid, nLineModel| At450ADClck(oFormulario, cFieldName)}})

oView:EnableTitleView('VIEWAB6')
oView:EnableTitleView('VIEWTXM')
oView:SetAfterViewActivate({||a450AChgLne()})

Return oView 	


//-------------------------------------------------------------------
/*/{Protheus.doc} Tec450AImg
@since 17/08/2017
@version     P12
/*/
//-------------------------------------------------------------------

Function Tec450AImg(oPanel,oView	)
Local aTFolder := {"Fotos"}
Local oTFolder  := Nil 
lFile := .F.

oTFolder := TFolder():New( 0,0,aTFolder,,oPanel,,,,.T.,,500,500)
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
oTBitmap:lStretch := .T.

Return .T.     


//-------------------------------------------------------------------
/*/{Protheus.doc} a450AChgLne
@since 17/08/2017
@version     P12
/*/
//-------------------------------------------------------------------
Function a450AChgLne()
Local oModel    := FwModelActive()
Local cBase64   := oModel:GetValue('TXMDETAIL','TXM_FOTO')
Local cFoto		:=  StrTran( cBase64, "data:image/jpeg;base64,", "" )
Local cNome 	:= oModel:GetValue('TXMDETAIL','TXM_NUMOS') + oModel:GetValue('TXMDETAIL','TXM_ITEM') + oModel:GetValue('TXMDETAIL','TXM_ITFOTO')
Local nHandle 	:= 0
Local cFile     := GetTempPath() + "image" + Alltrim(cNome)  + ".jpeg"


If !File(cFile)
	nHandle := FCREATE(cFile, 0)
	FWrite(nHandle, decode64(cFoto))
	FClose(nHandle)
EndIf
		
If !IsBlind()
	oTBitmap:Load(,cFile)
EndIf	

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} At450AVAct

@since 21/10/2020
@version     P12
/*/
//-------------------------------------------------------------------
Function At450aVAct(oModel)
Local lRet  := .F.
Local cTemp := GetNextAlias()

BeginSQL Alias cTemp
		
	SELECT 
		TXM_NUMOS,
        TXM_ITEM,
        TXM_FOTO
	FROM 	
		%Table:TXM% TXM
	WHERE 
		TXM.TXM_FILIAL = %Exp:xFilial("TXM")% AND
		TXM.TXM_NUMOS = %Exp:AB6->AB6_NUMOS% AND
		TXM.%NotDel%
 EndSql

lRet := ( cTemp )->( !Eof() )

(cTemp)->(dbCloseArea())

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} At450ADClck()
@description	Função de duplo-click para chamar o cálculo da planilha
@sample	 	At450ADClck(oFormulario, cField)
@param			oFormulario
@param			cField
@since			15/03/2022
@author	 	Luiz Gabriel Gomes de Jesus (luiz.jesus)    
@version		P12.2210  
@return		lExp (.T.=Ação válida / .F.=Ação inválida)
/*/
//--------------------------------------------------------------------
Static Function At450ADClck(oFormulario, cField)
Local oModel	:= FwModelActive()
Local cBase64	:= oModel:GetValue('TXMDETAIL','TXM_FOTO')
Local cFoto		:= StrTran( cBase64, "data:image/jpeg;base64,", "" )
Local cNome 	:= oModel:GetValue('TXMDETAIL','TXM_NUMOS') + oModel:GetValue('TXMDETAIL','TXM_ITEM') + oModel:GetValue('TXMDETAIL','TXM_ITFOTO')
Local nHandle 	:= 0
Local cFile     := GetTempPath() + "image" + Alltrim(cNome)  + ".jpeg"

If cField == "BTNVIEW"
	If !File(cFile)
		nHandle := FCREATE(cFile, 0)
		FWrite(nHandle, decode64(cFoto))
		FClose(nHandle)
	EndIf

	ShellExecute( "open", cFile, "", "", 1 )
EndIf

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} TECA450ACPO()
@description	Retorno dos campos que serão exibidos no grid 
@sample	 	TECA450ACPO()
@since			15/03/2022
@author	 	Luiz Gabriel Gomes de Jesus (luiz.jesus)    
@version		P12.2210  
@return		bloco de codigo
/*/
//--------------------------------------------------------------------
Function TECA450ACPO()
Local bReturn  	:= Nil 
Local cFields		:= "TXM_ITFOTO|TXM_ITEM|TXM_NUMOS"

If TXM->( ColumnPos("TXM_DESCRI")) > 0
	cFields += "|TXM_DESCRI"
EndIf 

bReturn := {|cCampo| AllTrim(cCampo) $ cFields }

Return(bReturn)
