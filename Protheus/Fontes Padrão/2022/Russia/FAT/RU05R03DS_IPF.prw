#include "protheus.ch"
#Include 'birtdataset.ch'
#include "TOPCONN.CH"
#include "RU02R02.CH"
#INCLUDE 'FWMVCDEF.CH'

dataset RU05R03
Title ' '
Description " "
PERGUNTE "RU05R03" 
SX3->(DbSetorder(2)) 

Columns
//--------------------------------------------------------------------
//===================Items table of the document======================
//---------------------------------------------------------------------
define Column B1_PACCOU     TYPE CHARACTER SIZE 1000        DECIMALS 0          LABEL 'B1_PACCOU'           //B1 Product description F36_DESC
define Column B2_PDESC      TYPE CHARACTER SIZE 60          DECIMALS 0          LABEL 'B2_PDESC'            //B2 Product type code F36_CUSCOD
define Column B3_CODOKEY    TYPE CHARACTER SIZE 60          DECIMALS 0          LABEL 'B3_CODOKEY'          //B3 Unit of measure OKEI code AH_CODOKEI (F36_UM = AH_UMRES)
define Column B4_UM         TYPE CHARACTER SIZE 60          DECIMALS 0          LABEL 'B4_UM'               //B4 Unit of measure short name B1_UM
define Column B5_QUANT      TYPE CHARACTER  SIZE 11         DECIMALS 3          LABEL 'B5_QUANT'            //B5 Quantity F36_QUANT
//--------------------------------------------------------------------
define Column B6_VUNIT      TYPE CHARACTER  SIZE 60         DECIMALS 2          LABEL 'B6_VUNIT'            //B6 Price per base unit Price per base unit    F36_VUNIT
define Column B7_VATBS1     TYPE NUMERIC SIZE 20            DECIMALS 2          LABEL 'B7_VATBS1'           //B7 Total amount without VAT   F36_VATBS1
define Column B8_EXC_V1     TYPE NUMERIC SIZE 60            DECIMALS 2          LABEL 'B8_EXC_V1'           //B8 Excise value   F36_EXC_V1
define Column B9_RATE       TYPE CHARACTER SIZE 8           DECIMALS 0          LABEL 'B9_RATE'             //B9 Tax rate   F30_desc(F30_desc = F31_rate and F31_code = F36_vatcod)
define Column B10_VATVL1    TYPE NUMERIC SIZE 20            DECIMALS 2          LABEL 'B10_VATVL1'          //B10  VAT value    F36_VATVL1
//--------------------------------------------------------------------
define Column B11_VALGR     TYPE NUMERIC SIZE 60            DECIMALS 2          LABEL 'B11_VALGR'           //B11  Total gross value including VAT  F36_VALGR(F36_VATBS1 + F36_VATVL1)
define Column B12_ORIGIN    TYPE CHARACTER SIZE 3           DECIMALS 0          LABEL 'B12_ORIGIN'          //B12  Country of origin code   F36_ORIGIN
define Column B12_DESCR     TYPE CHARACTER SIZE 60          DECIMALS 0          LABEL 'B12_DESCR'           //B13  Country of origin short name YA_DESCR(F36_ORIGIN = YA_CODERP)
define Column B13_NUMDES    TYPE CHARACTER SIZE 30          DECIMALS 0          LABEL 'B13_NUMDES'          //B14  Number of tax declaration    F36_NUMDES
//--------------------------------------------------------------------
// ===============================HEADER 1============================ 
//--------------------------------------------------------------------
define Column A1_DOC        TYPE CHARACTER SIZE 20          DECIMALS 0          LABEL       'A1_DOC'                //A1 System document number         F35_DOC
define Column A2_PDATE      TYPE CHARACTER SIZE 10          DECIMALS 0          LABEL       'A2_PDATE'              //A2 Document date                  F35_PDATE
define Column A3_ADJNR      TYPE CHARACTER SIZE 3           DECIMALS 0          LABEL       'A3_ADJNR'              //A3 Adjustment number              F35_ADJNR
define Column A4_ADJDT      TYPE CHARACTER SIZE 10          DECIMALS 0          LABEL       'A4_ADJDT'              //A4 Adjustment date                F35_ADJDT
define Column A5_FULLNAM    TYPE CHARACTER SIZE 70          DECIMALS 0          LABEL       'A5_FULLNAM'            //A5 Seller's name                   CO_FULLNAM
//--------------------------------------------------------------------
define Column A6_FULL       TYPE CHARACTER SIZE 250         DECIMALS 0          LABEL       'A6_FULL '              //A6 Seller's address               AGA_FULL 
define Column A7_KPP_CO     TYPE CHARACTER SIZE 35          DECIMALS 0          LABEL       'A7_KPP_CO'             //A7 INN/KPP of the seller           F35_KPP_CO
define Column A8_PACCOU     TYPE CHARACTER SIZE 250         DECIMALS 0          LABEL       'A8_CNOR_C'             //A8 Consignor and its address F35_CNOR_C
define Column A9_CNEE_C     TYPE CHARACTER SIZE 250         DECIMALS 0          LABEL       'A9_CNEE_C'             //A9 Consignee and its address F35_CNEE_C
define Column A10_ADVDOC    TYPE CHARACTER SIZE 200         DECIMALS 0          LABEL       'A10_ADVDOC'            //A10 Payment document number  F5P_ADVDOC
//--------------------------------------------------------------------
define Column A11_ADVDT     TYPE CHARACTER SIZE 200         DECIMALS 0          LABEL       'A11_ADVDT'             //A11 Payment document date  F5P_ADVDT
define Column A12_NOME      TYPE CHARACTER SIZE 250         DECIMALS 0          LABEL       'A12_NOME'              //A12 Buyer A1_NOME
define Column A13_FULL      TYPE CHARACTER SIZE 250         DECIMALS 0          LABEL       'A13_FULL'              //A13 Buyer's address  AGA_FULL
define Column A14_KP_IN     TYPE CHARACTER SIZE 35          DECIMALS 0          LABEL       'A14_KPP_CL'            //A14 INN/KPP of the buyer F35_KPP_CL
define Column A15_CODISO    TYPE CHARACTER SIZE 53          DECIMALS 0          LABEL       'A15_CODISO'            //A15 Currency CTO_RDESC, CTO_CODISO  50 + 
//--------------------------------------------------------------------
define Column A16_GOVSTR    TYPE CHARACTER SIZE 50          DECIMALS 0          LABEL       'A16_GOVSTR'            //A16 Government contract number A16_GOVSTR
//--------------------------------------------------------------------
//=========================FOOTER===TOTAL=============================
//--------------------------------------------------------------------
define Column A17_VATBS1    TYPE NUMERIC SIZE 16            DECIMALS 2          LABEL       'A17_VATBS1'            //double pres           //A17 Total value without VAT F35_VATBS(1)
define Column A18_VATVL1    TYPE NUMERIC SIZE 16            DECIMALS 2          LABEL       'A18_VATVL1'            //double pres           //A18 Total VAT value F35_VATVL(1)
define Column A19_VALGR1    TYPE NUMERIC SIZE 16            DECIMALS 2          LABEL       'A19_VALGR1'            //double pres           //A19 Total gross value including VAT   (F35_VATBS1 + F35_VATVL1) //MOJET NE BIT POLYA
define Column A20_CHFDIR    TYPE CHARACTER SIZE 53          DECIMALS 0          LABEL       'A20_CHFDIR'            //A20
define Column A21_CHFACC    TYPE CHARACTER SIZE 50          DECIMALS 0          LABEL       'A21_CHFACC'            //A21
//--------------------------------------------------------------------
define query    "SELECT * FROM %WTable:1% "
process dataset



Local cWTabAlias    as character
Local lRet          as logical
Local aSigners      as Array
Local cNotIni       as character 
Local cNotFil       as character    //branch of positioned record

cNotIni := F35->F35_KEY
cNotFil := F35->F35_FILIAL

lRet    := .F.
cWTabAlias := ::createWorkTable()

chkFile("SA2")
aSigners := {}
aadd (aSigners,self:execParamValue( "mv_par01" ))
aadd (aSigners,self:execParamValue( "mv_par02" ))

if !isblind() .and. (Empty(aSigners[1]) .or. Empty(aSigners[2])) 
     Help("",1,STR0017,,STR0018,1,0,,,,,,{""}) //Report signers not specified
endif

Processa({|_lEnd| lRet := X60NOT(cWTabAlias,cNotIni,cNotFil,aSigners)}, ::title())
Return .T.

//=================================================================================================
//-------------------------------------------------------------------------------------------------
static function X60NOT(cWTabAlias,cNotIni,cNotFil,aSigners)
//-------------------------------------------------------------------------------------------------
//=================================================================================================
    local oModel as object
    Local oModelF35 as object  
    Local oModelF36 as object 
    local cDirector,cCHIEFBUH as character
    local aArea as Array
    local nX as numeric 
    local cF5Pdocuments as character
    local cF35DocNumb as character
    local cPrintDate as character
    local cCnorCodent,cCneeCodent,cConsignee,cConsignor as character
    local cCnecod as character
    local cByer, cByerodent, cByerCod as character
    local cByername,cByerAdress, cByerINNKPP as character
    local cMoeda,cMoedaCode as character
    local cGosContract as character
    LOCAL cMyComName, cMyComAdrs, cMyINNKPP  as character
    local cQuery as character
    local cAliasTMP as character
    local lPrint as logical
    local cFdescr as character 
    local cB6Vunit as character
    local cComPar as character
    local  nVatBS,nVatVl,nValGr as numeric
    local aRet as Array 



    aRet := GetCoBrRUS(cNotFil,)
    cComPar := Alltrim(SuperGetMv("MV_CMPLVL",.F.,""))
    cByername := ""
    oModel:= FwLoadModel("RU09T02")
    oModel:Activate()

    oModelF35 := oModel:GetModel("F35MASTER")
    oModelF36 := oModel:GetModel("F36DETAIL")
    oModelF5P := oModel:GetModel("F5PDETAIL")

    // string for A10_ADVDOC - payment document: number, from.
    cF5Pdocuments := ""
    If !EMPTY(oModelF5P:GetValue("F5P_ADVDOC"))
        For nX := 1 to oModelF5P:Length()
                oModelF5P:GoLine(nX)
                    cF5Pdocuments += ", "+ STR0019 + " " + ALLTRIM(oModelF5P:GetValue("F5P_ADVDOC")) +  " " + STR0014 + " "+  FormatDate(oModelF5P:GetValue("F5P_ADVDT"))
        Next nX
        cF5Pdocuments := SUBSTR(cF5Pdocuments,2,LEN(cF5Pdocuments)-1)
    Else 
        cF5Pdocuments := "  --  "
    EndIf

    //main information about numbers and dates
    cF35DocNumb := oModelF35:GetValue("F35_DOC")
    cF35DocDate := FormatDate(oModelF35:GetValue("F35_PDATE"))
    cF35AdjNum  := oModelF35:GetValue("F35_ADJNR")
    cF35AdjDate := FormatDate(oModelF35:GetValue("F35_ADJDT"))
    cPrintDate  := IIF(!Empty(oModelF35:GetValue("F35_ADJDT")),DTOS(oModelF35:GetValue("F35_ADJDT")),DTOS(oModelF35:GetValue("F35_PDATE"))) //the date for check adresses and signers
    cF35AdjNum  := IIF(!Empty(cF35AdjNum),cF35AdjNum,"--")
    cF35AdjDate := IIF(!Empty(cF35AdjDate),cF35AdjDate,"--")
 

    cDirector := getSigner(aSigners[1],cPrintDate)
    cCHIEFBUH := getSigner(aSigners[2],cPrintDate)

    //Consignor: 1-seller, 2-another
    If oModelF35:GetValue("F35_CNRVEN") == "1"
        cConsignor     := alltrim(GetCoBrRUS()[2][6][2])  + ", " +GettFullAdress("SM0",getMyAgacodent(4),"2",cPrintDate)
    ElseIf oModelF35:GetValue("F35_CNRVEN") == "2"
        cCnorCodent := XFilial("SA2")+oModelF35:GetValue("F35_CNOR_C")+oModelF35:GetValue("F35_CNOR_B")
        cConsignor := alltrim(Posicione("SA2", 1, cCnorCodent, "A2_NOME")) + ", " + GettFullAdress("SA2",cCnorCodent,"2",cPrintDate)
    Endif

    //Consignee: 1-byer, 2-another
    If oModelF35:GetValue("F35_CNECLI") == "1"
        cCneeCodent := XFilial("SA1")+oModelF35:GetValue("F35_CLIENT")+oModelF35:GetValue("F35_BRANCH")
        cConsignee := alltrim(Posicione("SA1", 1, cCneeCodent, "A1_NOME")) + ", " + GettFullAdress("SA1",cCneeCodent,"2",cPrintDate)
    ElseIf oModelF35:GetValue("F35_CNECLI") == "2"
        cCneeCodent := XFilial("SA1")+oModelF35:GetValue("F35_CNEE_C")+oModelF35:GetValue("F35_CNEE_B")
        cConsignee := alltrim(Posicione("SA1", 1, cCneeCodent, "A1_NOME"))+ ", " + GettFullAdress("SA1",cCneeCodent,"2",cPrintDate)
    Endif

    //Byer may be headquater 
    cByername := " "
    cByerCod := findHeadQuoter(oModelF35:GetValue("F35_CLIENT"),oModelF35:GetValue("F35_BRANCH"))
    cByerodent := XFilial("SA1")+cByerCod+ oModelF35:GetValue("F35_BRANCH")
    DbSelectArea("SA1")
    dbSetOrder(1)
    If dbseek(XFilial("SA1")+cByerCod+oModelF35:GetValue("F35_BRANCH"))
        cByername := alltrim(SA1->A1_NOME)
    EndIf 
    dbclosearea()
    cByer    :=  cByername 
    cByerAdress :=  GettFullAdress("SA1",cByerodent,"0",cPrintDate)
    cByerINNKPP := alltrim(Posicione("SA1", 1, cByerodent, "A1_CODZON")) + IIF(!EMPTY(alltrim(oModelF35:GetValue("F35_KPP_CL"))),"/"+ alltrim(oModelF35:GetValue("F35_KPP_CL")),"") //should we take KPP of headquater?
    cGosContract := alltrim(oModelF35:GetValue("F35_GOVCTR"))

    //this part is information about seller, may be this is not the best way to get this information
    cMyINNKPP := aRet[1][13][2]  + "/"+  oModelF35:GetValue("F35_KPP_CO")
    cMyComName := ""
    cMyComAdrs := ""

    DO CASE 
        CASE cvaltochar(VAL(cComPar)-1) = '2'
            cMyComName  :=  alltrim(GetCoBrRUS()[2][6][2])
            cMyComAdrs     := GettFullAdress("SM0",getMyAgacodent(4),"0",cPrintDate)

            If aRet[2][7][2] = '1'
                cMyComAdrs     := GettFullAdress("SM0",getMyAgacodent(2)+aRet[2][7][2],"0",cPrintDate)
            EndIf 

        CASE cvaltochar(VAL(cComPar)-1) = '1'
                cMyComName  :=   alltrim(GetCoBrRUS()[1][5][2])
                cMyComAdrs     := GettFullAdress("SM0",getMyAgacodent(2)+aRet[2][7][2],"0",cPrintDate)

        CASE cvaltochar(VAL(cComPar)-1) = '0'
            cMyComName    := FWGrpName()  
            cMyComAdrs  := GettFullAdress("SM0",getMyAgacodent(2),"0",cPrintDate) 
    ENDCASE
     
    cMoedaCode := alltrim(Posicione("CTO",1,xFilial("CTO")+oModelF35:GetValue("F35_INVCUR"),"CTO_CODISO"))
    cMoeda :=  alltrim(Posicione("CTO",1,xFilial("CTO")+oModelF35:GetValue("F35_INVCUR"),"CTO_RDESC")) + ", " + cMoedaCode

//--------calculated values for footer 
    If cMoedaCode == "643"
        nVatBS := oModelF35:GetValue("F35_VATBS1")
        nVatVl := oModelF35:GetValue("F35_VATVL1")
        nValGr := nVatBS + nVatVl
    Else 
        nVatBS := oModelF35:GetValue("F35_VATBS")
        nVatVl := oModelF35:GetValue("F35_VATVL")
        nValGr := oModelF35:GetValue("F35_VALGR")
    Endif
    oModel:DeActivate()

    aArea := getArea()
    //details of print form, query used because because of sb1
	cQuery := " SELECT * FROM " + RetSqlName("F36") + " AS F36"
	
	cQuery += " INNER JOIN " + RetSqlName("F31") + " AS F31"
	cQuery += " ON F31.F31_CODE = F36.F36_VATCOD"
	cQuery += " AND F31.D_E_L_E_T_ = F36.D_E_L_E_T_"
    
	cQuery += " INNER JOIN " + RetSqlName("F30") + " AS F30"
	cQuery += " ON F30.F30_CODE = F31.F31_RATE"
	cQuery += " AND F30.D_E_L_E_T_  = F31.D_E_L_E_T_"

	cQuery += " LEFT JOIN " + RetSqlName("SYA") + " AS SYA"
	cQuery += " ON SYA.YA_CODGI = F36.F36_ORIGIN "
	cQuery += " AND SYA.D_E_L_E_T_  = F36.D_E_L_E_T_"
	
	cQuery += " LEFT JOIN " + RetSqlName("SB1") + " AS SB1" 
	cQuery += " ON SB1.B1_COD = F36.F36_ITMCOD " 
	cQuery += " AND SB1.D_E_L_E_T_= F36.D_E_L_E_T_"

	cQuery += " LEFT JOIN " + RetSqlName("SBM") + " AS SBM"
	cQuery += " ON SBM.BM_GRUPO = SB1.B1_GRUPO"
	cQuery += " AND SBM.D_E_L_E_T_ = SB1.D_E_L_E_T_"
	
	cQuery += " LEFT JOIN " + RetSqlName("SAH") + " AS SAH"
	cQuery += " ON SAH.AH_UNIMED = SB1.B1_UM"
    cQuery += " AND SAH.D_E_L_E_T_ = SB1.D_E_L_E_T_"

	cQuery += " WHERE F36.F36_FILIAL = '" + cNotFil + "' "    
	cQuery += " AND F36.F36_KEY = '" + cNotIni + "' "
    cQuery += " AND F36.D_E_L_E_T_ = ' '"
    cQuery += " AND F31.F31_FILIAL = '" + xFilial('F31') + "'"
    cQuery += " AND F30.F30_FILIAL = '" + xFilial('F30') + "'"
    
    cQuery += " AND COALESCE(SYA.YA_FILIAL,'" + xFilial('SYA') + "') = '"+ xFilial('SYA') + "' "
    cQuery += " AND COALESCE(SB1.B1_FILIAL,'" + xFilial('SB1') + "') = '"+ xFilial('SB1') + "' "
    cQuery += " AND COALESCE(SBM.BM_FILIAL,'" + xFilial('SBM') + "') = '"+ xFilial('SBM') + "' "
    cQuery += " AND COALESCE(SAH.AH_FILIAL,'" + xFilial('SAH') + "') = '"+ xFilial('SAH') + "' "
    
    cQuery += " ORDER BY F36.F36_ITEM"

    
	cQuery := ChangeQuery(cQuery)
	cAliasTMP   := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTMP,.T.,.T.)
	DbSelectArea(cAliasTMP)

    (cAliasTMP)->(dbGotop())
    While  (cAliasTMP)->(!EOF())

        If  !EMPTY((cAliasTMP)->BM_GDSSRV) //if at least one of the list is a commodity, not a service, the shipper / consignee will be printed
            lPrint := .T.
        endif
        //description of each product. If it is empty in invoice it would be taken from sb1 
        cFdescr := getDescr(cNotFil+cNotIni + (cAliasTMP)->F36_ITEM)
        If Empty(cFdescr) 
            cFdescr := (cAliasTMP)->B1_DESC
        EndIf  

        cB6Vunit :=  cvaltochar(NOROUND((cAliasTMP)->F36_VUNIT,2))  
        if AT('.',cB6Vunit)==(Len(cB6Vunit))-1
            cB6Vunit:=cB6Vunit + '0'
        endif
        if AT('.',cB6Vunit)== 0 
            cB6Vunit:=cB6Vunit + '.00'
        endif

        RecLock(cWTabAlias,.T.)

        If (cAliasTMP)->B1_PRINT = '2'  .or. EMPTY((cAliasTMP)->B1_PRINT) //temporary solution, because now user can enter services that are not in table SB1
            B2_PDESC    :=  ' -- '
            B3_CODOKEY  :=  ' -- '
            B4_UM       :=  ' -- '
            B5_QUANT    :=  ' -- '
            B6_VUNIT    :=  ' -- '
        Else 
            B2_PDESC    :=  alltrim((cAliasTMP)->F36_CUSCOD)   
            B3_CODOKEY  :=  alltrim((cAliasTMP)->AH_CODOKEI)   
            B4_UM       :=  alltrim((cAliasTMP)->AH_UMRES)  
            B5_QUANT    :=  cvaltochar((cAliasTMP)->F36_QUANT)
            B6_VUNIT    :=  cB6Vunit
        EndIf 

        If !EMPTY((cAliasTMP)->F36_CUSCOD)
            B2_PDESC  :=  alltrim((cAliasTMP)->F36_CUSCOD)
        ELSE
            B2_PDESC    :=  ' -- '
        ENDIF

        B1_PACCOU   :=  cFdescr  

        If cMoedaCode = '643' // rubles
            B7_VATBS1   :=  (cAliasTMP)->F36_VATBS1 
            B10_VATVL1  :=  (cAliasTMP)->F36_VATVL1     
            B11_VALGR   :=  ((cAliasTMP)->F36_VATBS1) + ((cAliasTMP)->F36_VATVL1) 
        else
            B7_VATBS1   :=  (cAliasTMP)->F36_VATBS  
            B10_VATVL1  :=  (cAliasTMP)->F36_VATVL      
            B11_VALGR   :=  (cAliasTMP)->F36_VALGR
        endif

        B9_RATE     :=  AllTrim((cAliasTMP)->F30_DESC)  

        If !EMPTY((cAliasTMP)->F36_ORIGIN)
            B12_ORIGIN  := alltrim((cAliasTMP)->F36_ORIGIN)  
            B12_DESCR   := alltrim((cAliasTMP)->YA_DESCR)
        Else
            B12_ORIGIN  := ' -- '
            B12_DESCR   := ' -- '
        Endif

        If !EMPTY((cAliasTMP)->F36_NUMDES) 
            B13_NUMDES  :=  (cAliasTMP)->F36_NUMDES
        Else
            B13_NUMDES   :=  "-"
        Endif

        //header of document
        A1_DOC      := cF35DocNumb    
        A2_PDATE    := cF35DocDate
        A3_ADJNR    := cF35AdjNum
        A4_ADJDT    := cF35AdjDate
        A5_FULLNAM  := cMyComName  
        A6_FULL     := cMyComAdrs 
        A7_KPP_CO   := cMyINNKPP
        A8_PACCOU   := cConsignor
        A9_CNEE_C   := cConsignee 
        A10_ADVDOC  := cF5Pdocuments
        A11_ADVDT   :=  ' '
        A12_NOME    := cByername
        A13_FULL    := cByerAdress
        A14_KP_IN   := cByerINNKPP
        A15_CODISO  := cMoeda
        A16_GOVSTR  := cGosContract
        A17_VATBS1  := nVatBS
        A18_VATVL1  := nVatVl
        A19_VALGR1  := nValGr

		A20_CHFDIR  := alltrim(cDirector)
		A21_CHFACC  := alltrim(cCHIEFBUH) 
		MsUnlock()
		(cAliasTMP)->(dbSkip())		
    Enddo

    (cAliasTMP)->(dbCloseArea())
    RestArea(aArea)
return .T. 




//function take information from memo field
static function getDescr(cIndex as character)

    local cFdescr as char 
    default cIndex := ""

    cFdescr = ' '
    dbSelectArea('F36')
    dbSetOrder(1)
    If (dbseek(cIndex))
        cFdescr := alltrim(F36->F36_DESC)
        F36->(dbSkip()) 
    endif
    F36->(dbCloseArea())
return cFdescr



//function return information about adress in field aga_full
static function GettFullAdress(cAliasP as character, cKeyP as character,cTipo as character,cDate as character)
Local cQuery 	as character
Local cAgaFull 	as character
Local cTab 		as character

cAgaFull 		:= ""
if (!empty(cAliasP) .and. !empty(cKeyP) .and. !empty(cTipo))
    cQuery := " SELECT AGA.R_E_C_N_O_ AS AGAREC FROM " + RetSqlName("AGA") + " AGA "
    cQuery += " WHERE AGA.AGA_FILIAL = '"+xFilial("AGA")+"'"
    cQuery += " AND AGA_ENTIDA = '" + cAliasP + "'"
    cQuery += " AND AGA_CODENT = '" + cKeyP + "'"
    cQuery += " AND AGA_TIPO = '" + cTipo + "'"
    If !empty(cDate)
        cQuery += " AND  '" + cDate +  "' BETWEEN '''AGA.AGA_FROM''' AND AGA.AGA_TO  "
    endif
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery := ChangeQuery(cQuery)
    cTab := MPSysOpenQuery(cQuery)

    If (cTab)->(!EOF())
        AGA->(dbGoTo((cTab)->AGAREC))
        cAgaFull    := ALLTRIM(AGA->AGA_FULL)
    Else
    cAgaFull        := " "
    EndIf
    (cTab)->( dbCloseArea() )
endif
Return(cAgaFull)




//function formating date from date to russian print standart dd.mm.yyyy
static function FormatDate(dData as date)
    local cData as character
    cData := DTOS(dData)
    cData := Substr(alltrim(cData), 7, 2) + "." +  Substr(alltrim(cData), 5, 2) + "." + Substr(alltrim(cData), 1, 4)
Return cData




//function returns aga_codent of our company, depends on level
static function getMyAgacodent(nLevel as numeric)
    local cAGACodent as character
    local nFilLen, nBuOLen,nComLen,nGrpLen  as numeric
    Local aArea as Array
    default nLevel := 4

    aArea	:= GetArea()
    DbSelectArea("XX8")
    XX8->(dbSetOrder(1))
    XX8->(dbGoTop())

    cAGACodent := xFilial("AGA")+PADR(FWGrpCompany(),LEN(XX8->XX8_GRPEMP))
    If nLevel >= 2 
        cAGACodent += PADR(FWCompany(),LEN(XX8->XX8_EMPR) )
        If nLevel >= 3 
            cAGACodent += PADR(FWUnitBusiness(),LEN(XX8->XX8_UNID) )
            If nLevel == 4
                cAGACodent += PADR(FWFilial(),LEN(XX8->XX8_CODIGO) ) 
            EndIf
        Endif
    EndIf
    RestArea(aArea)
return cAGACodent



//function check headquater for client coe and return code of hedquoter, If it is found
static function findHeadQuoter(cCod as character, cBranch as character)
local cHeadQuot as character 
    dbSelectArea('AI0')
    dbSetOrder(1)
    If (dbseek(xFilial("AI0") + cCod + cBranch))
        cHeadQuot := alltrim(AI0->AI0_HEAD)
        AI0->(dbSkip()) 
    Else 
        cHeadQuot  := cCod
    endif
    AI0->(dbCloseArea())
return cHeadQuot


//function later must be replased for standart one (ru99signers)
Static Function getSigner(cSomeOne,cDate)
Local cTab as CHAR
local cQuery as character
default cDate := DTOS(ddatabase)

    cQuery := " SELECT * FROM " + RetSqlName("F42") + " F42 " 
    cQuery += " WHERE " 
    cQuery += " F42.F42_EMPL = '" + cSomeOne 	+ "' AND F42.D_E_L_E_T_=' ' "
    cQuery += " AND F42.F42_FILIAL = '" + FWxFilial('F42')	+ "' "
    cQuery += " AND  '" + cDate +  "' BETWEEN '''F42.F42_DFROM''' AND F42.F42_DATETO  "

    cQuery := ChangeQuery(cQuery)
    cTab	:= GetNextAlias()
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTab,.T.,.T.)
    DbSelectArea(cTab)

    If (cTab)->(!EOF())
        cSomeOne := (cTab)->F42_NAME
    Else
        cSomeOne := " "
    EndIf
    (cTab)->(dbCloseArea())

Return alltrim(cSomeOne)
