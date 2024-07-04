#INCLUDE "TOTVS.CH"
#INCLUDE "Shopify.ch"
#INCLUDE "ShopifyExt.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWMVCDEF.CH'

#DEFINE POS_TITLE       1
#DEFINE POS_VAR_TITLE   2
#DEFINE POS_BARCODE     3
#DEFINE POS_WEIGHT      4
#DEFINE POS_WEIGHT_UNIT 5

#DEFINE ID_TITLE       "TITLE"
#DEFINE ID_VAR_TITLE   "VARTITLE"
#DEFINE ID_BARCODE     "BARCODE"
#DEFINE ID_WEIGHT      "WEIGHT"
#DEFINE ID_WEIGHT_UNIT "WEIGHT_UNIT"
#DEFINE ID_A1M         "A1M.RECNO"
#DEFINE ID_A1MCOD      "CODIGO"
#DEFINE ID_POSITION    "POSITION"
#DEFINE ID_VENDOR      "VENDOR"
#DEFINE ID_BODY_HTML   "BODY_HTML"
#DEFINE ID_TAXABLE     "TAXABLE"
#DEFINE ID_TYPE        "TYPE"
#DEFINE ID_TAG         "TAG"

#DEFINE POS_ID    1
#DEFINE POS_VALUE 2

/*/{Protheus.doc} SHP00001
 Function responsable for sending the products group to Shopify
@type  Function
@author Yves Oliveira
@since 12/02/2020
/*/
Function SHP00001(cId)
    Local oInt := ShpInteg():New()
    Do Case
        Case cId == ID_INT_CUSTOM_COLLECTION
            oInt:intPGroup()
        Case cId == ID_INT_PRODUCT
            oInt:intProduct()
        Case cId == ID_INT_CUSTOMER
            oInt:intCustomer()
        Case cId == ID_INT_INVENTORY
            oInt:intInventory()
        Case cId == ID_INT_ORDER
            oInt:intOrder()
        Otherwise
            Alert(STR0004 + " : " + cId)//Integration not mapped
    EndCase
    freeObj(oInt)
    
Return 

/*/{Protheus.doc} ShpInteg
    Class used to integrate with Shopify's 
    @author Yves Oliveira
    @since 25/02/2020
    /*/
Class ShpInteg FROM FWModelEvent
    Data oModel   As Object
    Data cModelId As String
    Data error    As String

    Method new() Constructor
    
    /*Custom Collection = Product group(SBM)*/
    Method intPGroup(nRecno, nOper)
    
    /*Product = Product(SB1)*/
    Method intProduct(nRecno, nOper)
    Method intProdByCod(cProduct, nOper)
    
    /*Customer = Customer(SA1)*/
    Method intCustomer(nRecno, nOper)

    /*Inventory = Inventory(SB2)*/
    Method intInventory(oModel, cModelId)

    Method intOrder(oModel, cModelId)
    Method AfterTTS(oModel, cModelId)

    Method GetProdDef(cProduct, lGrid)
    Method reqGroup(cGroup,cIdExtGroup,cRecnoColl)
    Method reqProduct(cIdExt, cRecno, cTitle, cVendor, cBodyHtml, cTag, cType)
    Method reqVariant(cIdVarExt, cTitle, cBarcode, nGrams, nPrice, cSku, lTaxable, nWeight, cWeightUnit, nPosition, cRecnoProd, cIdExtProd, cRecnoVar) 
    Method reqCollect(cIdExtGroup, cIdExtProd, cRecnoProd, cRecnoGrp)
    Method procImage(cCodA1M, cIdExtProd, cIdVarExt, cRecnoA1M)
    Method reqImage(cIdExt, cIdExtProd, cIdVar, cRecnoA1E, source, position, cRecnoA1M, lDelete)
EndClass


/*/{Protheus.doc} new
    Class constructor
    @author Yves Oliveira
    @since 26/02/2020
    /*/
Method new() Class ShpInteg
    ::error := ""
Return


Method AfterTTS(oModel, cModelId) Class ShpInteg
    Local oInt   := Nil
    Local nOper  := MODEL_OPERATION_INSERT
    Local nRecno := 0
    
    oInt  := ShpInteg():New()
    nOper := oModel:GetOperation()

    Do Case
        Case ::cIdEvent == "SHP_" + ID_INT_CUSTOM_COLLECTION
            nRecno := oModel:GetModel("MATA035_SBM"):NDATAID 
            Processa( {|| oInt:intPGroup(nRecno, nOper) }, STR0002, STR0001 ,.F.)//"Wait..."/"Integrating with Shopify..."            
            
        Case ::cIdEvent == "SHP_" + ID_INT_PRODUCT
            nRecno := oModel:GetModel("SB1MASTER"):NDATAID
            Processa( {|| oInt:intProduct(nRecno, nOper) }, STR0002, STR0001 ,.F.)//"Wait..."/"Integrating with Shopify..."

        Case ::cIdEvent == "SHP_" + ID_INT_CUSTOMER
            nRecno := oModel:GetModel("SA1MASTER"):NDATAID
            Processa( {|| oInt:intCustomer(nRecno, nOper) }, STR0002, STR0001 ,.F.)//"Wait..."/"Integrating with Shopify..."
        Otherwise
            Alert(STR0004 + " : " + ::cIdEvent)//Integration not mapped
    EndCase
    freeObj(oInt)
Return


/*/{Protheus.doc} intPGroup
    Method to call custom collection integration
    @author Yves Oliveira
    @since 26/02/2020
    /*/
Method intPGroup(nRecno, nOper) Class ShpInteg
    Local aArea      := GetArea()
    Local aAreaSbm   := SBM->(GetArea())
    Local oInt       := Nil
    Local cIdExt     := ""
    Local cRet       := Nil
    Local cGrpFname  := ShpGetPar("GRPBFNAME")    

    Default nOper := MODEL_OPERATION_INSERT

    
    If nOper == MODEL_OPERATION_INSERT .Or. nOper == MODEL_OPERATION_UPDATE

        DbSelectArea("SBM")
        SBM->(DbGoTo(nRecno))

        //::crudPGroup(nRecno, AllTrim(SBM->BM_DESC))
        oInt := ShpPGroup():new()
        oInt:id := cValToChar(nRecno)

        cIdExt := ShpGetId(SHP_ALIAS_CUSTOM_COLLECTION, cValToChar(nRecno))

        If cIdExt <> Nil .And. Val(cIdExt) > 0
            oInt:idExt := cIdExt
        EndIf

        oInt:title 	  := AllTrim(SBM->BM_DESC)
        //oInt:bodyHtml := AllTrim(SBM->BM_XSHHTCL)
        oInt:bodyHtml := AllTrim(SBM->&(cGrpFname))
        oInt:requestToShopify()
        cRet    := oInt:idExt
        ::error := oInt:error
        FreeObj(oInt)
    EndIf

    RestArea(aArea)
    RestArea(aAreaSbm)
Return cRet

/*/{Protheus.doc} intProdByCod
    Method to call product integration by product code
    @author Yves Oliveira
    @since 15/04/2020
    /*/
Method intProdByCod(cProduct, nOper) Class ShpInteg
    Local lRet  := .T.
    Local aArea := SB1->(GetArea())

    Default nOper := MODEL_OPERATION_INSERT

    If nOper == MODEL_OPERATION_INSERT .Or. nOper == MODEL_OPERATION_UPDATE
        DbSelectArea("SB1")
        SB1->(DbSetOrder(1))//B1_FILIAL + B1_COD

        If SB1->(DbSeek(xFilial("SB1") + cProduct))
            lRet := ::intProduct(SB1->(Recno()))
        EndIf
    EndIf

    RestArea(aArea)
Return lRet

/*/{Protheus.doc} intProduct
    Method to call product integration
    @author Yves Oliveira
    @since 27/02/2020
    /*/
Method intProduct(nRecno, nOper) Class ShpInteg
    Local aArea     := GetArea()
    Local aAreaSb1  := {}
    Local cIdVarExt := ""
    Local cIdExtGroup  := ""
    Local cIdExtProd:= ""
    Local cCodGroup := ""
    Local cRecnoColl:= ""
    
    Local cRecnoSb1   := ""
    Local cRecnoA1M   := ""
    Local cCodA1M     := ""
    Local cTitle      := ""
    Local cVendor     := ""
    Local cVarTitle   := ""
    Local cbarcode    := ""
    Local nGrams      := 0
    Local nPrice      := 0
    Local cSku        := ""
    Local lTaxable    := .T.
    Local nWeight     := 0
    Local cWeightUnit := ""
    Local nPosition   := 1
    Local cBodyHtml   := ""
    Local cIdExtCol   := ""
    Local cTag        := ""
    Local cType       := ""

    Local lGrid      := .F.
    Local aProdDef   := {}
    
    Local lOk        := .T.
    Local cIdDefVar  := ""
    Local lNew       := .F.
    Local cSearch    := ""
    
    Default nOper := MODEL_OPERATION_INSERT

    If nOper == MODEL_OPERATION_INSERT .Or. nOper == MODEL_OPERATION_UPDATE
        
        If nRecno <= 0 
            Return .F.
        EndIf

        //nRecno    := oModel:GetModel("SB1MASTER"):NDATAID 
        DbSelectArea("SB1")
        aAreaSb1 := SB1->(GetArea())
        SB1->(DbGoTo(nRecno))
        cRecnoSb1 := cValToChar(nRecno)

        cCodGroup := SB1->B1_GRUPO
        cSku      := SB1->B1_COD

        lGrid := ShpIsGrid(cSku)

        aProdDef := ::GetProdDef(cSku, lGrid)
        
        If Len(aProdDef) > 0
            cRecnoA1M   := cValToChar(GetGridValue(ID_A1M,aProdDef))
            cCodA1M     := GetGridValue(ID_A1MCOD,aProdDef)
            cIdExtProd  := ShpGetId(SHP_ALIAS_PRODUCT, cRecnoA1M)
            cIdVarExt   := ShpGetId(SHP_ALIAS_VARIANT, cRecnoSb1, SHP_ALIAS_PRODUCT, cRecnoA1M)
            cTitle      := AllTrim(GetGridValue(ID_TITLE,aProdDef))
            cVarTitle   := AllTrim(GetGridValue(ID_VAR_TITLE,aProdDef))
            cBarcode    := AllTrim(GetGridValue(ID_BARCODE,aProdDef))
            nWeight     := GetGridValue(ID_WEIGHT,aProdDef)
            cWeightUnit := GetGridValue(ID_WEIGHT_UNIT,aProdDef)
            nPosition   := GetGridValue(ID_POSITION,aProdDef)
            cVendor     := AllTrim(GetGridValue(ID_VENDOR,aProdDef))
            cBodyHtml   := AllTrim(GetGridValue(ID_BODY_HTML,aProdDef))
            lTaxable    := GetGridValue(ID_TAXABLE,aProdDef)
            cTag        := GetGridValue(ID_TAG,aProdDef)
            cType       := GetGridValue(ID_TYPE,aProdDef)
   
        EndIf
        If ValType(nWeight) == "C"
            nWeight := 0
        Endif

        lNew := Empty(cIdExtProd)

        nPrice      := ShpCurrPrice(AllTrim(cSku))

        //TODO - Verificar se o cWeightUnit ser�       
        cWeightUnit := "kg"
        
        If nWeight >= 1
            nGrams := Round(nWeight / 1000, 2)
        EndIf        
        
        lOk := .F.
        lOk := ::reqGroup(cCodGroup,@cIdExtGroup, @cRecnoColl)

        If !lOk
            Return lOk
        EndIf

        If !lNew
        	//Preciso esperar segundo para enviar um PUT
        	sleep(1000)
        EndIF
        
        lOk := ::reqProduct(@cIdExtProd, cRecnoA1M, cTitle, cVendor, cBodyHtml, cTag, cType)
        
        If !lOk
            Return lOk
        EndIf

        lOk := ::reqVariant(@cIdVarExt, cVarTitle, cBarcode, nGrams, nPrice, cSku, lTaxable, nWeight,;
                             cWeightUnit, nPosition, cRecnoA1M, cIdExtProd, cRecnoSb1)
            
        If !lOk
            Return lOk
        EndIf

        //Delete default variant
        cIdDefVar := ShpGetId(SHP_ALIAS_DEFAULT_VARIANT, cRecnoA1M, SHP_ALIAS_PRODUCT, cRecnoA1M)
        
        If !Empty(cIdDefVar)
            oInt := ShpVariant():New()
            oInt:idExt        := cIdDefVar
            oInt:idExtProduct := cIdExtProd
            oInt:delete       := .T.
            lOk := oInt:requestToShopify()

            If lOk
                DbSelectArea("A1D")
                A1D->(DbSetOrder(2))//A1D_FILIAL+A1D_ALIAS+A1D_ID+A1D_IDEXT+A1D_ALIASP+A1D_IDPAI
                cSearch := xFilial("A1D") + Pad(SHP_ALIAS_DEFAULT_VARIANT, TamSx3("A1D_ALIAS")[1]) + Pad(cRecnoA1M, TamSx3("A1D_ID")[1]) + Pad(cIdDefVar, TamSx3("A1D_IDEXT")[1]) +;
                            Pad(SHP_ALIAS_PRODUCT, TamSx3("A1D_ALIASP")[1]) + Pad(cRecnoA1M, TamSx3("A1D_IDPAI")[1])
                If A1D->(DbSeek(cSearch))
                    RecLock("A1D",.F.)
                    A1D->(DbDelete())
                    A1D->(MsUnlock())
                EndIf
            EndIf
        EndIf

        If !lOk
            Return lOk
        EndIf

        lOk := ::procImage(cCodA1M, cIdExtProd, cIdVarExt, cRecnoA1M)

        If !lOk
            Return lOk
        EndIf    

        cIdExtCol := ShpGetId(SHP_ALIAS_COLLECT, cRecnoColl, SHP_ALIAS_PRODUCT, cRecnoA1M) 

        If Empty(cIdExtCol)
            lOk := ::reqCollect(cIdExtGroup, cIdExtProd, cRecnoA1M, cRecnoColl)
        EndIf

        If !lOk
            Return lOk
        EndIf  

        //Update inventory
        ShpInt004({cEmpAnt, cFilAnt}, cSku)

    EndIf

    RestArea(aArea)
Return lOk

/*/{Protheus.doc} reqGroup
    Execute the request to custom collection integration API
    @type  Static Function
    @author Yves Oliveira
    @since 08/04/2020
    /*/
Method reqGroup(cGroup,cIdExtGroup,cRecnoColl) Class ShpInteg
    Local lRet      := .F.
    Local nRecnoSbm := 0
    BEGIN SEQUENCE
        If !Empty(cGroup)
                
            //Check if the group already exists
            DbSelectArea("SBM")
            SBM->(DbSetOrder(1))//BM_FILIAL+BM_GRUPO
            cSearch := xFilial("SBM") + cGroup
            If SBM->(DbSeek(cSearch))
                nRecnoSbm   := SBM->(Recno())
                cIdExtGroup := ShpGetId(SHP_ALIAS_CUSTOM_COLLECTION, cValToChar(nRecnoSbm))
                If Empty(cIdExtGroup)
                    cIdExtGroup := ::intPGroup(nRecnoSbm)
                EndIf
            EndIf
        EndIf
        cIdExtGroup := AllTrim(cIdExtGroup)
        cRecnoColl  := cValToChar(nRecnoSbm)
        lRet := .T.
    RECOVER
        lRet := .F.
    END SEQUENCE
    
Return lRet

/*/{Protheus.doc} reqProduct
    Execute the request to product integration API
    @type  Static Function
    @author Yves Oliveira
    @since 08/04/2020
    /*/
Method reqProduct(cIdExt, cRecno, cTitle, cVendor, cBodyHtml, cTag, cType) Class ShpInteg
    Local lRet := .F.
    Local oInt := Nil
    
    BEGIN SEQUENCE
        oInt := ShpProduct():new()     
        If cIdExt <> Nil .And. Val(cIdExt) > 0
            oInt:idExt := cIdExt
        EndIf

        oInt:id       := cRecno
        //oInt:idGrid   := cIdGrid
        oInt:title    := cTitle
        oInt:vendor   := cVendor
        oInt:bodyHtml := cBodyHtml
        oInt:tags     := cTag
        oInt:type     := cType
        //oInt:aliasGrid:= cAliasGrid
        oInt:requestToShopify()
        cIdExt  := AllTrim(oInt:idExt)
        ::error := oInt:error //todo ajustar aqui para integrar novamente izo cristiano montebugnoli
        lRet := .T.
    END SEQUENCE

    If oInt <> Nil .And. !Empty(oInt:error)
        lRet := .F.
    EndIf

    FreeObj(oInt)

Return lRet

/*/{Protheus.doc} reqVariant
    Execute the request to variant integration API
    @type  Static Function
    @author Yves Oliveira
    @since 08/04/2020
    /*/
Method reqVariant(cIdVarExt, cTitle, cBarcode, nGrams, nPrice, cSku, lTaxable, nWeight, cWeightUnit, nPosition, cRecnoProd, cIdExtProd, cRecnoVar) Class ShpInteg
    Local lRet     := .F.
    Local oInt := Nil
    
    BEGIN SEQUENCE
        oInt := ShpVariant():New()
        If cIdVarExt <> Nil .And. Val(cIdVarExt) > 0
            oInt:idExt := cIdVarExt
        EndIf

        oInt:title        := cTitle
        oInt:barcode      := cBarcode
        oInt:grams        := nGrams
        oInt:price        := nPrice
        oInt:sku          := cSku
        oInt:taxable      := lTaxable
        oInt:weight       := nWeight
        oInt:weightUnit   := cWeightUnit
        oInt:position     := nPosition
        
        oInt:idProduct    := cRecnoProd
        oInt:idExtProduct := cIdExtProd
        oInt:id           := cRecnoVar
        oInt:requestToShopify()
        cIdVarExt := AllTrim(oInt:idExt)
        ::error   := oInt:error
        lRet := .T.
    END SEQUENCE

    If oInt <> Nil .And. !Empty(oInt:error)
        lRet := .F.
    EndIf

    FreeObj(oInt)
Return lRet

/*/{Protheus.doc} reqCollect
    Execute the request to collect integration API
    @type  Static Function
    @author Yves Oliveira
    @since 08/04/2020
    /*/
Method reqCollect(cIdExtGroup, cIdExtProd, cRecnoProd, cRecnoGrp) Class ShpInteg
    Local lRet := .F.
    Local oInt := Nil 
    BEGIN SEQUENCE
        If !Empty(cIdExtGroup) .And. !Empty(cIdExtProd)
            /*Integrating the link between product and group*/
            oInt := ShpCollect():new()        
            oInt:id         := cRecnoGrp
            oInt:recnoProd  := cRecnoProd
            oInt:collection := cIdExtGroup
            oInt:productId  := cIdExtProd
            oInt:requestToShopify()
            ::error := oInt:error
        EndIf
        lRet := .T.
    END SEQUENCE
    
    If oInt <> Nil .And. !Empty(oInt:error)
        lRet := .F.
    EndIf

    FreeObj(oInt)
Return lRet

/*/{Protheus.doc} procImage
    (long_description)
    @author Yves Oliveira
    @since 27/04/2020
    /*/
Method procImage(cCodA1M, cIdExtProd, cIdVarExt, cRecnoA1M) Class ShpInteg
    Local lRet := .T.
    
    Local cIdExtImg := ""
    Local cRecnoA1E := ""
    Local cSearch   := ""
    
    DbSelectArea("A1E")
    A1E->(DbSetOrder(1))//A1E_FILIAL+A1E_COD
    cSearch := xFilial("A1E") + cCodA1M
    A1E->(DbSeek(cSearch))
    
    While !A1E->(Eof()) .And. AllTrim(A1E->(A1E_FILIAL+A1E_COD)) ==  AllTrim(cSearch)
        cRecnoA1E := AllTrim(cValToChar(A1E->(Recno())))
        cIdExtImg := ShpGetId(SHP_ALIAS_IMAGE, cRecnoA1E, SHP_ALIAS_PRODUCT, cRecnoA1M)
        If A1E->A1E_INTEGR <> "2"
            
            //Do not send a photo update
            If Empty(cIdExtImg)
                lRet := ::reqImage(@cIdExtImg,cIdExtProd, cIdVarExt, cRecnoA1E,AllTrim(A1E->A1E_URL), Val(A1E->A1E_SEQUEN),cRecnoA1M)
            EndIf
        Else
            //Delete the photo if it exists on Shopify and is marked as not integrated into Protheus. Last parameter = delete 
            If !Empty(cIdExtImg)
                Begin Transaction
                    DbSelectArea("A1D")
                    A1D->(DbSetOrder(2))//A1D_FILIAL+A1D_ALIAS+A1D_ID+A1D_IDEXT+A1D_ALIASP+A1D_IDPAI
                    cSearch := xFilial("A1D") + Pad(SHP_ALIAS_IMAGE, TamSx3("A1D_ALIAS")[1]) + Pad(cRecnoA1E, TamSx3("A1D_ID")[1]) + Pad(cIdExtImg, TamSx3("A1D_IDEXT")[1]) +;
                                Pad(SHP_ALIAS_PRODUCT, TamSx3("A1D_ALIASP")[1]) + Pad(cRecnoA1M, TamSx3("A1D_IDPAI")[1])
                    If A1D->(DbSeek(cSearch))
                        RecLock("A1D",.F.)
                        A1D->(DbDelete())
                        A1D->(MsUnlock())
                    EndIf
                    
                    lRet := ::reqImage(@cIdExtImg,cIdExtProd, cIdVarExt, cRecnoA1E,AllTrim(A1E->A1E_URL), Val(A1E->A1E_SEQUEN),cRecnoA1M,.T.)

                    If !lRet
                        DisarmTransaction()
                        lRet := .F.
                    EndIf
                End Transaction
            EndIf
        EndIf

        If !lRet
            Exit
        EndIf

        A1E->(DbSkip())
    EndDo
    A1E->(DbCloseArea())
Return lRet

/*/{Protheus.doc} reqImage
    (long_description)
    @author Yves Oliveira
    @since 09/04/2020
    /*/
Method reqImage(cIdExt, cIdExtProd, cIdVar, cRecnoA1E, source, position, cRecnoA1M, lDelete) Class ShpInteg
       
    Local lRet := .F.
    Local oInt := Nil 

    Default lDelete := .F.

    BEGIN SEQUENCE        
        oInt := ShpProdImg():new()        
        If cIdExt <> Nil .And. Val(cIdExt) > 0
            oInt:idExt := cIdExt
        EndIf        
        oInt:id        := cRecnoA1E
        oInt:source    := source
        oInt:variantId := cIdVar
        oInt:productId := cIdExtProd
        oInt:position  := position
        oInt:productRec:= cRecnoA1M
        oInt:delete    := lDelete
        oInt:requestToShopify()
        ::error := oInt:error
        lRet := .T.
    END SEQUENCE

    If oInt <> Nil .And. !Empty(oInt:error)
        lRet := .F.
    EndIf

    FreeObj(oInt)
Return lRet

/*/{Protheus.doc} GetProdDef
	Return array with product structure based on grid set-up
	@type  Static Function
	@author Yves Oliveira
	@since 06/04/2020
	/*/
Method GetProdDef(cProduct, lGrid) Class ShpInteg
	Local aRet      := {}
    Local aRetEmpty := {}
	Local cMask     := SuperGetMv("MV_MASCGRD")//06,01,04 -> Format sample
	Local nCodeSize := Val(Substr(cMask,1,2))
	Local nLinSize  := Val(Substr(cMask,4,2))
	Local nColSize  := Val(Substr(cMask,7,2))
    Local cAuxBrand := ""
	Local nStart    := 1
	Local cAlias    := GetNextAlias()
	Local cQuery    := ""
    Local cVarDesc  := ""
    Local nPosition := 1
    Local lTaxable  := .T.

    Local cFTitle    := ""
    Local cFVendor   := ""
    Local cFVarTitle := ""
    Local cFWeight   := ""
    Local cFBodyHtml := ""
    Local cFPosition := ""
    Local cFTag      := ""
    Local cFType     := ""

    Local cDefTitle    := "SB4.B4_DESC"
    Local cDefVendor   := "SBM.BM_CODMAR"
    Local cDefVarTitle := "SB1.B1_DESC"
    Local cDefWeight   := "SB1.B1_PESO"
    Local cDefBodyHtml := "SB4.B4_MATPROD"
    Local cDefPosition := "1"
    Local cDefTag      := "''"
    Local cDefType     := "''"
    
    Local cCodA1M      := ""
    
    Local nGridRecno := 0
    Local cGridType  := ShpGetPar("GRIDTYPE")

    If !lGrid
        cDefTitle    := "SBM.BM_DESC"
        cDefBodyHtml := "SB5.B5_CEME"
    EndIf

    //If cGridType == "CUSTOM"
        DbSelectArea("A1K")
        A1K->(DbSetOrder(1))//A1K_FILIAL + A1K_COD
        If A1K->(DbSeek(xFilial("A1K") + cProduct))
            DbSelectArea("A1M")
            A1M->(DbSetOrder(1))//A1M_FILIAL + A1M_COD
            If A1M->(DbSeek(xFilial("A1M") + A1K->A1K_CODPAI))
                cCodA1M    := A1M->A1M_COD
                cFTitle    := Iif(Empty(A1M->A1M_SQLTIT), "'" + AllTrim(A1M->A1M_DESC) + "'", A1M->A1M_SQLTIT)
                cFVendor   := A1M->A1M_SQLMAR
                cFBodyHtml := A1M->A1M_SQLHTM
                nGridRecno := A1M->(Recno())
                cFVarTitle := A1K->A1K_SQLTIT
                cFWeight   := A1K->A1K_SQLPES
                cFPosition := A1K->A1K_SEQUEN
                cFTag      := A1M->A1M_SQLTAG
                cFType     := A1M->A1M_SQLTP
                lTaxable   := Iif(A1K->A1K_TAX <> "2", .T., .F.)
            Else 
                Return aRetEmpty
            EndIf
        Else 
            Return aRetEmpty
        EndIf
    //EndIf

    If Empty(cFTitle)
        cFTitle := cDefTitle
    EndIf

    If Empty(cFVendor)
        cFVendor := cDefVendor
    EndIf
    
    If Empty(cFVarTitle)
        cFVarTitle := cDefVarTitle
    EndIf
    If Empty(cFWeight)
        cFWeight := cDefWeight
    EndIf

    If Empty(cFBodyHtml)
        cFBodyHtml := cDefBodyHtml
    EndIf

    If Empty(cFPosition)
        cFPosition := cDefPosition
    EndIf

    If Empty(cFTag)
        cFTag := cDefTag
    EndIf

    If Empty(cFType)
        cFType := cDefType
    EndIf

    cProduct := AllTrim(cProduct)
    cQuery += "SELECT" + CRLF
    cQuery += " " + cFPosition + " POSITION," + CRLF
    cQuery += "	" + AllTrim(cFTitle)    + " As TITLE ," + CRLF
    cQuery += "	" + AllTrim(cFVendor)   + " As VENDOR ," + CRLF
	cQuery += "	" + AllTrim(cFVarTitle) + " AS VARIANT_TITLE," + CRLF
	cQuery += "	" + AllTrim(cFWeight)   + " AS WEIGHT," + CRLF
	cQuery += "	" + AllTrim(cFBodyHtml) + " AS BODY_HTML," + CRLF
	cQuery += "	" + AllTrim(cFType)     + " AS TYPE," + CRLF
	cQuery += "	" + AllTrim(cFTag)      + " AS TAG," + CRLF
    cQuery += "	B1_CODBAR AS BARCODE," + CRLF
	cQuery += "	B1_COD AS SKU," + CRLF		
	cQuery += "	B1_UM AS WEIGHTUNIT " + CRLF
	cQuery += "FROM " + RetSqlName("SB1") + " SB1" + CRLF
	
	cQuery += "LEFT JOIN " + RetSqlName("SBM") + " SBM ON" + CRLF
	cQuery += "	SBM.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "	AND BM_FILIAL = '" + xFilial("SBM") + "'" + CRLF
	cQuery += "	AND SBM.BM_GRUPO = SB1.B1_GRUPO" + CRLF
	
	nStart := 1
	cQuery += "LEFT JOIN " + RetSqlName("SB4") + " SB4 ON" + CRLF
	cQuery += "	SB4.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "	AND B4_FILIAL = '" + xFilial("SB4") + "'" + CRLF
	cQuery += "	AND B4_COD = '" + Substr(cProduct, nStart, nCodeSize) + "'" + CRLF
	
	nStart += nCodeSize
	cQuery += "LEFT JOIN " + RetSqlName("SBV") + " LIN ON" + CRLF
	cQuery += "	LIN.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "	AND LIN.BV_FILIAL = '" + xFilial("SBV") + "'" + CRLF
	cQuery += "	AND LIN.BV_TABELA = B4_LINHA" + CRLF
	cQuery += "	AND LIN.BV_CHAVE = '" + Substr(cProduct, nStart, nLinSize) + "'" + CRLF
	
	nStart += nLinSize
	cQuery += "LEFT JOIN " + RetSqlName("SBV") + " COL ON" + CRLF
	cQuery += "	COL.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "	AND COL.BV_FILIAL = '" + xFilial("SBV") + "'" + CRLF
	cQuery += "	AND COL.BV_TABELA = B4_COLUNA" + CRLF
	cQuery += "	AND COL.BV_CHAVE = '" + Substr(cProduct, nStart, nColSize) + "'" + CRLF

    cQuery += "LEFT JOIN " + RetSqlName("SB5") + " SB5 ON" + CRLF
	cQuery += "	SB5.D_E_L_E_T_ = ' '" + CRLF
	cQuery += " AND SB5.B5_FILIAL = '" + xFilial("SB5") + "'" + CRLF
	cQuery += " AND SB5.B5_COD = SB1.B1_COD" + CRLF

	cQuery += "WHERE" + CRLF
	cQuery += "	SB1.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "	AND B1_FILIAL = '" + xFilial("SB1") + "'" + CRLF
	cQuery += "	AND B1_COD = '" + cProduct + "'" + CRLF

	cQuery := ChangeQuery(cQuery)

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
	
	TcQuery cQuery new Alias &cAlias
	
	DbSelectArea(cAlias)
	(cAlias)->(DbGoTop())
	
	If !(cAlias)->(Eof())
        Aadd(aRet,{ID_A1M   , cValToChar(nGridRecno)})
        Aadd(aRet,{ID_A1MCOD, cCodA1M})

		Aadd(aRet,{ID_TITLE    ,Capital((cAlias)->TITLE)})
        cVarDesc := (cAlias)->VARIANT_TITLE
        If Empty(cVarDesc)
            cVarDesc := (cAlias)->B4_DESC
        EndIf
        cVarDesc := Capital(cVarDesc)
		Aadd(aRet,{ID_VAR_TITLE, cVarDesc})
		Aadd(aRet,{ID_BARCODE  ,(cAlias)->BARCODE})
		Aadd(aRet,{ID_WEIGHT   ,(cAlias)->WEIGHT})
		Aadd(aRet,{ID_WEIGHT   ,(cAlias)->WEIGHTUNIT})
		
        nPosition := (cAlias)->POSITION
        If ValType(nPosition)  == "C"
            nPosition := Val(nPosition)
        EndIf
		Aadd(aRet,{ID_POSITION ,nPosition})
        cAuxBrand := GetAdvFVal("VE1","VE1_DESMAR", xFilial("VE1") + (cAlias)->VENDOR ,1)
		Aadd(aRet,{ID_VENDOR   , Capital(cAuxBrand)})
		Aadd(aRet,{ID_BODY_HTML, (cAlias)->BODY_HTML})
		Aadd(aRet,{ID_TAXABLE  , lTaxable})
		Aadd(aRet,{ID_TYPE     , (cAlias)->TYPE})
		Aadd(aRet,{ID_TAG      , (cAlias)->TAG})
        
	EndIf
	
	(cAlias)->(DbCloseArea())

Return aRet

/*/{Protheus.doc} GetGridValue
    Get grid array value by Id
    @type  Static Function
    @author Yves Oliveira
    @since 06/04/2020
    /*/
Static Function GetGridValue(cId, aValues)
    Local oRet := Nil
    Local nPos := 0
    Local aAux := aClone(aValues)

    nPos := aScan(aAux, {|x| AllTrim(x[POS_ID]) == AllTrim(cId) })
    If nPos > 0
        oRet := aAux[nPos][POS_VALUE] 
    EndIf

Return oRet

/*/{Protheus.doc} intCustomer
    Method to call customer integration
    @author Yves Oliveira
    @since 27/02/2020
    /*/
Method intCustomer(nRecno, nOper) Class ShpInteg
    Local oInt     := Nil
    Local aArea    := GetArea()
    Local aAreaSa1 := SA1->(GetArea())
    Local cIdExt := 0
    
    Default nOper := MODEL_OPERATION_INSERT

    
    //incluir isincallstack  ShpUpdCust para nao ser chamado aqui
    //If (!IsInCallStack("U_ShpInt002") .Or. !IsInCallStack("ShpInt002")) .And. (nOper == MODEL_OPERATION_INSERT .Or. nOper == MODEL_OPERATION_UPDATE)
    If nOper == MODEL_OPERATION_UPDATE

        DbSelectArea("SA1")
        aAreaSa1 := SA1->(GetArea())    
        SA1->(DbGoTo(nRecno))
        cIdExt := ShpGetId("SA1", cValToChar(nRecno))

        If  cIdExt <> Nil .And. Val(cIdExt) > 0
            oInt := ShpCustomer():new()
            
            oInt:id := cValToChar(nRecno)

            //cIdExt := ShpGetId("SA1", cValToChar(nRecno))

            If cIdExt <> Nil .And. Val(cIdExt) > 0
                oInt:idExt := cIdExt
            EndIf

            oInt:email     := AllTrim(SA1->A1_EMAIL)//AllTrim(oModel:GetValue("SA1MASTER", "A1_EMAIL"))
            oInt:firstName := AllTrim(SA1->A1_NOME)//AllTrim(oModel:GetValue("SA1MASTER", "A1_NOME"))
            oInt:lastName  := ""//AllTrim(oModel:GetValue("SA1MASTER", "A1_NREDUZ"))
            oInt:phone     := AllTrim(SA1->A1_TEL)//AllTrim(oModel:GetValue("SA1MASTER", "A1_TEL"))

            //Address
            oInt:addressId   := ShpGetId("SA1.ENDERECO", cValToChar(nRecno), "SA1", cValToChar(nRecno))
            oInt:address1    := AllTrim(SA1->A1_END)//AllTrim(oModel:GetValue("SA1MASTER", "A1_END"))
            oInt:address2    := AllTrim(SA1->A1_COMPLEM)//AllTrim(oModel:GetValue("SA1MASTER", "A1_COMPLEM"))
            oInt:city        := AllTrim(SA1->A1_MUN)//AllTrim(oModel:GetValue("SA1MASTER", "A1_MUN"))
            oInt:comapny     := AllTrim(SA1->A1_NREDUZ)//AllTrim(oModel:GetValue("SA1MASTER", "A1_NREDUZ"))
            oInt:country     := ""//AllTrim(oModel:GetValue("SA1MASTER", "A1_PAISDES"))
            oInt:addrFName   := AllTrim(SA1->A1_NOME)//AllTrim(oModel:GetValue("SA1MASTER", "A1_NOME"))
            oInt:addrLName   := ""//AllTrim(oModel:GetValue("SA1MASTER", "A1_NREDUZ"))
            oInt:addrPhone   := AllTrim(SA1->A1_TEL)//AllTrim(oModel:GetValue("SA1MASTER", "A1_TEL"))
            oInt:province    := ""//SA1->
            oInt:zip         := AllTrim(SA1->A1_CEP)//AllTrim(oModel:GetValue("SA1MASTER", "A1_CEP"))
            oInt:countryCode := ""//SA1->
            oInt:default     := .T.

            //adiciona se recolhe imposto sim ou nao
            If SA1->A1_RETIVA == "2"
                oInt:taxsetting     := "True" //nao recolhe taxa � uma excessao
            else
                oInt:taxsetting     := "False" //recolhe taxa
            endif

            oInt:requestToShopify()

            FreeObj(oInt)

        EndIf 

    EndIf

    RestArea(aArea)
    RestArea(aAreaSa1)
Return 
