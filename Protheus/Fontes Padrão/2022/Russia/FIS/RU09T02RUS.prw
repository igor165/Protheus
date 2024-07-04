#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fwmvcdef.ch'
#include 'topconn.ch'
#include 'ru09t02.ch'
#include 'ru09xxx.ch'


#define LAYOUT_LINEAR_L2R 0 // LEFT TO RIGHT
#define LAYOUT_LINEAR_R2L 1 // RIGHT TO LEFT
#define LAYOUT_LINEAR_T2B 2 // TOP TO BOTTOM
#define LAYOUT_LINEAR_B2T 3 // BOTTOM TO TOP
 
#define LAYOUT_ALIGN_LEFT     1
#define LAYOUT_ALIGN_RIGHT    2
#define LAYOUT_ALIGN_HCENTER  4
#define LAYOUT_ALIGN_TOP      32
#define LAYOUT_ALIGN_BOTTOM   64
#define LAYOUT_ALIGN_VCENTER  128

#define RU09T02_SF2_FIELDS_HISTORY	"F2_FILIAL |F2_SERIE  |F2_DOC    |F2_DTSAIDA|F2_EMISSAO|F2_VALBRUT|F2_BASIMP1|F2_VALIMP1|F2_STATUSR|F2_LOJA   |F2_CLIENTE|F2_CONUNI  |"

/*/{Protheus.doc} RU09T02
Creates the main screen of Sales VAT Invoice.
@author felipe.morais
@since 02/05/2017
@version P12.1.16
@type function
/*/

Function RU09T02RUS()
Local oBrowse as Object

// Initalization of tables, if they do not exist.
DBSelectArea("F35")
F35->(DbSetOrder(1))
DBSelectArea("F36")
F36->(DbSetOrder(1))
DbSelectArea("F54")
F54->(dbSetOrder(1))
DbSelectArea("F5P")
F5P->(dbSetOrder(1))

SetKey(VK_F12, {|a,b| AcessaPerg("RU09T02",.T.)})

oBrowse := FWLoadBrw("RU09T02")
oBrowse:Activate()
Return(.T.)



/*/{Protheus.doc} MenuDef
Defines the browser for the Sales VAT Invoice.
@author felipe.morais
@since 26/03/2018
@version P12.1.20
@type function
/*/
Static Function BrowseDef()
Local oBrowse as Object
Local oTableAtt as Object
Local aRotina as Array

oTableAtt:= TableAttDef()
aRotina := MenuDef()

oBrowse := FwMBrowse():New()

oBrowse:SetAlias("F35")
oBrowse:SetDescription(STR0001) //"Sales VAT Invoice"
oBrowse:DisableDetails()

// 'Select All' Button
oBrowse:SetAttach(.T.)
oBrowse:SetViewsDefault(oTableAtt:aViews)
oBrowse:SetChartsDefault(oTableAtt:aCharts)

Return(oBrowse)



/*/{Protheus.doc} MenuDef
Defines the menu to Sales VAT Invoice.
@author felipe.morais
@since 02/05/2017
@version P12.1.16
@type function
/*/
Static Function MenuDef()

Local aAddOpc as Array

local aRotina := {}

aAddOpc := {{STR0002, "RU09T02Add(.F.)", 0, 3, 0, Nil},; //"Commercial Invoice"
			{STR0054, "RU09T02Mnl()", 0, 3, 0, Nil}}

aRotina := {{STR0006, "VIEWDEF.RU09T02", 0, 2, 0, Nil},; //"View"
		{STR0007, aAddOpc, 0, 3, 0, Nil},; //"Add"
		{STR0008, "RU09T02act("+STR(MODEL_OPERATION_UPDATE)+", .T.)", 0, 4, 0, Nil},; //"Edit"
		{STR0009, "RU09T02act("+STR(MODEL_OPERATION_DELETE)+", .T.)", 0, 5, 0, Nil},; //"Delete"
		{STR0010, "CTBC662", 0, 2, 0, Nil},; //"Track Posting"
		{STR0060, "RU09T02Cp()", 0, 9, 0, Nil},; //"Track Posting"
		{STR0027, "RU09T02Chn()", 0, 4, 0, Nil},; //Edit VAT invoice number manually RU09T02Chn.RU09T02
		{STR0025, "RU09T02Bk(oModel)",0,2,0,Nil}}//"Sales Book" 
	aAdd(aRotina,{STR0063, "RU05R03()", 0, 6, 0, NIL})	


Return(aRotina)





/*/{Protheus.doc} ModelDef
Creates the model of Sales VAT Invoice.
@author felipe.morais
@since 02/05/2017
@version P12.1.16
@type function
/*/
Static Function ModelDef()
Local oStructF35 as Object
Local oStructF36 as Object
Local oStructSF2 as Object
Local oStructF5P as Object
Local oModelEvent as Object
Private oModel as Object

oStructF35 := FWFormStruct(1, "F35")
oStructF36 := FWFormStruct(1, "F36")
oStructSF2 := FWFormStruct(1, "SF2",{|x| (x $ RU09T02_SF2_FIELDS_HISTORY)})
oStructF5P := FWFormStruct(1, "F5P")

oModel := MPFormModel():New("RU09T02", , , {|oModel| ModelRec(oModel)},)

oModel:AddFields("F35MASTER", Nil, oStructF35)
oModel:AddGrid("F36DETAIL", "F35MASTER", oStructF36)

oModel:AddGrid("SF2DETAIL", "F35MASTER", oStructSF2,/* bLinePre */, /* bLinePost */, /* bPre */, /* bLinePost */, {|| LoadComInv(oStructSF2, F35->F35_FILIAL, F35->F35_CLIENT, F35->F35_BRANCH, F35->F35_KEY)} /* bLoadGrid */)
oModel:SetRelation("F36DETAIL", {{"F36_FILIAL", "xFilial('F36')"}, {"F36_KEY", "F35_KEY"}, {"F36_DOC", "F35_DOC"}}, F36->(IndexKey(1)))
oModel:SetPrimaryKey({"F35_FILIAL", "F35_KEY"/*, "F35_DOC",  "F35_TYPE" */})
oModel:SetRelation("SF2DETAIL", {{"F2_FILIAL", "F35_FILIAL"},{"F2_CLIENTE","F35_CLIENT"}, {"F2_LOJA","F35_BRANCH"} }, SF2->(IndexKey(4)))
oModel:SetRelation("SF2DETAIL", {{"F2_SERIE", "F36_INVSER"}, {"F2_DOC", "F36_INVDOC"}}, SF2->(IndexKey(4)))

oModel:GetModel("F36DETAIL"):SetUniqueLine({"F36_ITEM"})
oModel:GetModel("SF2DETAIL"):SetOptional(.T.)
oModel:GetModel("SF2DETAIL"):SetOnlyQuery(.T.)

oModel:AddGrid("F5PDETAIL", "F35MASTER", oStructF5P)
oModel:SetRelation("F5PDETAIL", {{"F5P_FILIAL", "xFilial('F5P')"}, {"F5P_KEY", "F35_KEY"}}, F5P->(IndexKey(1)))
oModel:GetModel("F5PDETAIL"):SetOptional(.T.)

oModelEvent 	:= RU09T02EventRUS():New()
oModel:InstallEvent("oModelEvent", /*cOwner*/, oModelEvent)
Return(oModel)



/*/{Protheus.doc} ViewDef
Creates the view of Sales VAT Invoice.
@author felipe.morais
@since 02/05/2017
@version P12.1.16
@type function
/*/
Static Function ViewDef()
Local oView as Object
Local oModel as Object
// Structures of used tables
Local oStructF35 as Object
Local oStructF36 as Object
Local oStruc_T as Object
Local oStructSF2 as Object
Local oStructF5P as Object
// Lists of fields to remove
Local cCmpF35 as Character
Local cCmpF36 as Character
Local cCmpF35_T as Character
Local cCmpSF2 as Character
Local cCmpF5P as Character

Local lHide := .F.

// Defines which fields we don't need to show on the screen.
cCmpF35 := "F35_IDATE;F35_CURR;F35_VATVL;F35_VALGR;F35_VATBS;F35_VATCOD;F35_VATVL1;F35_VATBS1"
cCmpF35_T := "F35_VATVL;F35_VALGR;F35_VATBS;F35_VATCOD;F35_VATVL1;F35_VATBS1"
cCmpF36 := "F36_FILIAL;F36_KEY;F36_DOCKEY;F36_TYPE;F36_DOC;F36_EXC_V1;F36_VATVS1;F36_EXC_V1;F36_DTLA;F36_INVCUR;"//F36_INVDOC;F36_INVSER;F36_DESC"
cCmpSF2 := "F2_SERIE  ;F2_DOC    ;F2_DTSAIDA;F2_EMISSAO;F2_VALBRUT;F2_BASIMP1;F2_VALIMP1"
cCmpF5P := "F5P_KEY   ;"

oModel := FwLoadModel("RU09T02")
oStructF35 := FWFormStruct(2, "F35", {|x| !(AllTrim(x) $ cCmpF35)})
oStructF36 := FWFormStruct(2, "F36", {|x| !(AllTrim(x) $ cCmpF36)})
oStructF5P := FWFormStruct(2, "F5P", {|x| !(AllTrim(x) $ cCmpF5P)})
oStruc_T := FWFormStruct(2, "F35", {|x| (AllTrim(x) $ cCmpF35_T) })
oStruc_T:SetNoFolder()

If (INCLUI)
	oStructF35:RemoveField("F35_DOC")
	oStructF35:RemoveField("F35_BOOK")
	oStructF36:RemoveField("F36_DOC")
EndIf

If SuperGetMV("MV_RASTRO") == "S"
	lHide := RU09T02LOC()
EndIf

If (lHide .AND. !INCLUI)
	oStructF36:RemoveField("F36_ORIGIN")
	oStructF36:RemoveField("F36_NUMDES")
EndIf

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField("F35_M", oStructF35, "F35MASTER")
oView:AddGrid("F36_D", oStructF36, "F36DETAIL")
oView:AddField("F35_T", oStruc_T, "F35MASTER")
oView:AddGrid("F5P_D", oStructF5P, "F5PDETAIL")

oView:CreateHorizontalBox("BOXFORMALL", 55)
oView:CreateFolder("FOLDER","BOXFORMALL")

oView:AddSheet("FOLDER", 'Sheet1', STR0032) // VAT Invoice Data
oView:AddSheet("FOLDER", 'Sheet5', STR0055) // Payment Documents

oView:CreateHorizontalBox("HEADER1", 100,,,"FOLDER",'Sheet1')
oView:CreateHorizontalBox("F5PHEADERBOX",100/*%*/,,,'FOLDER','Sheet5')

oView:SetOwnerView("F35_M", "HEADER1")
oView:SetOwnerView("F5P_D", "F5PHEADERBOX")

oView:CreateHorizontalBox("ITEMBOX", 35)
oView:CreateHorizontalBox("TOTALBOX",10)

oView:SetOwnerView("F36_D", "ITEMBOX")
oView:SetOwnerView("F35_T", "TOTALBOX")

oView:AddIncrementField('F36_D','F36_ITEM')
oView:AddIncrementField('F5P_D','F5P_ITEM')

oView:SetCloseOnOk({|| .T.})

If (FwIsInCallStack('RU09T02Mnl'));
	.or. (!INCLUI .and. (F35->F35_TYPE == "2"))
	oStructF35:RemoveField("F35_IDATE")
	oStructF35:RemoveField("F35_INVSER")
	oStructF35:RemoveField("F35_INVDOC")
	oStructF35:RemoveField("F35_CURR")
	oStructF35:RemoveField("F35_CONUNI")
	oStructF35:RemoveField("F35_MOEDA")
	oStructF35:RemoveField("F35_MOEDES")
	oStructF36:RemoveField("F36_INVSER")
	oStructF36:RemoveField("F36_INVDOC")
	oStructF36:RemoveField("F36_INVIT")
	oStructF36:RemoveField("F36_INVDT")
	oStructF36:RemoveField("F36_ITDATE")

Else
	oStructSF2 := FWFormStruct(2, "SF2", {|x| (x $ cCmpSF2)})
	oView:AddGrid("SF2_D", oStructSF2, "SF2DETAIL")
	oView:SetViewProperty("SF2_D", "GRIDDOUBLECLICK", {{|oModel,cField,nLineGrid| ComInvCl(oModel,nLineGrid)}})
	oView:AddSheet('FOLDER', 'Sheet4', STR0033)	// Comercial Invoice
	oView:CreateHorizontalBox("SF2HEADERBOX",100/*%*/,,,'FOLDER','Sheet4')
	oView:SetOwnerView("SF2_D", "SF2HEADERBOX")
	If (!INCLUI)
		oView:SetNoDeleteLine("SF2_D")
		oView:SetNoDeleteLine("F36_D")
	EndIf
EndIf

oStructF35:RemoveField("F35_F5QUID")

// Make some fields read-only if we are not in manual creation
If (!INCLUI)
	oView:AddUserButton(STR0025, '', {|| RU09T02Bk(oModel)})
EndIf

If (FwIsInCallStack("MATA467N")) .And. (FwIsInCallStack("RU09T02Add"))
	oView:AddUserButton(STR0036, '', {|| RU09T02CIB()})
EndIf

oView:SetViewCanActivate({|oView| RU09T02005_OpenFields(oView)})

Return(oView)



/*/{Protheus.doc} RU09T02Bk
@author felipe.morais
@since 22/11/2017
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Function RU09T02Bk(oModel)
Local aArea as Array
Local aAreaF39 as Array
Local oModelM as Object
Local cKey as Character
Local cBooKey as Character

If ValType(oModel) <> 'O'
      oModel     := FwLoadModel("RU09T02")
      oModel:SetOperation(6)
      oModel:Activate()
EndIf

aArea := GetArea()
aAreaF39 := F39->(GetArea())
oModelM := oModel:GetModel("F35MASTER")
cKey :=  AllTrim(oModelM:GetValue("F35_BOOK"))
cBooKey :=  AllTrim(oModelM:GetValue("F35_BOOKEY"))

If !(Empty(cBooKey))
	DbSelectArea("F39")
	F39->(DbSetOrder(1))
	If (F39->(DbSeek(xFilial("F39") + cBooKey)))
		FwExecView(STR0006,"RU09T04",MODEL_OPERATION_VIEW,,{|| .T.})
	Else 
		Help("",1,"NOBOOKEY",,STR0026,1,0) // "There is no Sales Book for this Sales VAT Invoice."
	EndIf
Else
	Help("",1,"NOBOOK",,STR0026,1,0) // "There is no Sales Book for this Sales VAT Invoice."
EndIf

RestArea(aAreaF39)
RestArea(aArea)
Return



/*/{Protheus.doc} RU09T02Mnl
This routine starts the procedure of creating Sales VAT Invoice manually.
@author artem.kostin
@since 11/08/2018
@version P12.1.22
@type function
/*/
Function RU09T02Mnl()
Local lRet := .T.
Local oModel:= FwLoadModel("RU09T02")

If (lRet)
	// If it is everything OK, must be show a window to the end user to continue to add a Sales VAT Invoice.
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
	RU09T02Mn1(oModel)
	FwExecView(STR0013, "RU09T02", MODEL_OPERATION_INSERT,/* oDlg */, {|| .T.},/* ok */,/*nPercReducation*/,/*aEnableButtons*/,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel) // "Sales Invoice"
EndIf

Return(lRet)



Function RU09T02Mn1(oModel)
Local lRet := .T.
Local oModelF35 := oModel:GetModel("F35MASTER")

If (lRet)
	lRet := lRet .and. oModelF35:LoadValue("F35_TYPE", "2")
	lRet := lRet .and. oModelF35:LoadValue("F35_PDATE", dDataBase)
EndIf

Return(lRet)



/*/{Protheus.doc} RU09T02Add (addComInv) - be carefull, this function is used also in other module. Look in locxnf.prw 
Function that adds a record in Sales VAT Invoice.
@author felipe.morais
@since 16/05/2017
@version P12.1.16
@param lExt, logical, Indicates if it is called from Sales VAT Invoice (.F.) or Outflow Document (.T.)
@type function
/*/
Function RU09T02Add(lExt)
Local lRet as Logical
Local aColumns as Array
Local aFieldsSF2 as Array
Local nI as Numeric
Local aArea as Array
Local aAreaSX3 as Array
Local oModel as Object
Local aSize as Array
Private aRotina as Array

Private oDlg	as Object
Private oBrwSel as Object
Private oTable	as Object
Private cTable	as Character
Private cMark	as Character

lRet := .T.
aArea := GetArea()
aAreaSX3 := SX3->(GetArea())

If !(lExt)
	aSize := MsAdvSize(.F.)
	
	cTable := CriaTrab(, .F.)
	
	lRet := genTable()
	
	If (lRet)
		aColumns := {}
		aFieldsSF2 := {}
		aAdd(aFieldsSF2, "F2_SERIE")
		aAdd(aFieldsSF2, "F2_DOC")
		aAdd(aFieldsSF2, "F2_CLIENTE")
		aAdd(aFieldsSF2, "F2_LOJA")
		aAdd(aFieldsSF2, "A1_NOME")
		aAdd(aFieldsSF2, "F2_EMISSAO")
		aAdd(aFieldsSF2, "F2_MOEDA")
		aAdd(aFieldsSF2, "F2_CONUNI")
		aAdd(aFieldsSF2, "F2_BASIMP1")
		aAdd(aFieldsSF2, "F2_VALIMP1")
		
			DbSelectArea("SX3")
			SX3->(DbSetOrder(2))
		For nI := 1 To Len(aFieldsSF2)
			If (SX3->(DbSeek(aFieldsSF2[nI])))
				aAdd(aColumns, FwBrwColumn():New())
				aColumns[Len(aColumns)]:SetData(&("{|| " + aFieldsSF2[nI] + "}"))
				aColumns[Len(aColumns)]:SetTitle(X3Titulo())
				aColumns[Len(aColumns)]:SetSize(TamSX3(aFieldsSF2[nI])[1])
				aColumns[Len(aColumns)]:SetDecimal(TamSX3(aFieldsSF2[nI])[2])
				aColumns[Len(aColumns)]:SetPicture(PesqPict("S" + SubStr(aFieldsSF2[nI], 1, 2), aFieldsSF2[nI]))
			EndIf
		Next nI
		
		oDlg := MsDialog():New(aSize[7], aSize[2], aSize[6], aSize[5], STR0019, , , , , CLR_BLACK, CLR_WHITE, , , .T., , , , .T.) // "Sales Invoices"
		
		oBrwSel := FwMarkBrowse():New()
		oBrwSel:SetFieldMark("F2_OK")
		oBrwSel:SetOwner(oDlg)
		oBrwSel:SetColumns(aColumns)
		oBrwSel:bAllMark := {||MarkAll(oBrwSel, cTable)}
		oBrwSel:SetAlias(cTable)
		aRotina := AddMenuDef()
		oBrwSel:SetMenuDef("AddMenuDef")
		oBrwSel:DisableReport()
		oBrwSel:Activate()

		cMark := oBrwSel:Mark()
		
		oDlg:Activate(, , , .T., {|| .T.}, , {|| .F.})
	EndIf
	
	(cTable)->(DbCloseArea())
	oTable:Delete()
	aRotina := MenuDef()
Else
	// If it is called from Outflow Document, must be checked if there is a Sales VAT Invoice for this Outflow Document.
	If (SF2->F2_STATUSR == "2")
		Help("",1,"RU09T02addComInv01",,STR0022,1,0)	// "VAT Sales Invoice was already created for this record."
		lRet := .F.
	EndIf
	
	If (lRet)
		// If it is everything OK, must be show a window to the end user to continue to add a Sales VAT Invoice.
		oModel := FwLoadModel("RU09T02")
		oModel:SetOperation(3)
		oModel:Activate()
		
		FwExecView(STR0013, "RU09T02", MODEL_OPERATION_INSERT, , {|| .T.},,,,,,, retInc(oModel, /*oDados*/, /*aHeader*/, lExt)) // "Sales Invoice"
	EndIf
EndIf

RestArea(aAreaSX3)
RestArea(aArea)
Return(lRet)



/*/{Protheus.doc} retInc
Function that fills automatically the fields at the moment of inclusion.
@author felipe.morais
@since 03/05/2017
@version P12.1.16
@type function
/*/
Static Function retInc(oModel as Object, oDados as Object, aHeader as Array, lExt as Logical)
Local lRet := .T.
Local aArea as Array
Local aAreaSF2 as Array
Local aAreaSD2 as Array
Local aAreaSA1 as Array
Local aAreaF31 as Array
Local nPosSer as Numeric
Local nPosEmi as Numeric
Local nPosDoc as Numeric
Local nPosCli as Numeric
Local nPosLoja as Numeric
Local nLinha as Numeric
Local oModelM as Object
Local oModelD as Object
Local oModelF as object
Local cPerg as Character
Local nItem as Numeric
Local cKeySF2 as Character
// Currency
Local cConuni := ""
Local nMoeda as Numeric
// SQL query
Local cTab := ""

aArea := GetArea()
aAreaSF2 := SF2->(GetArea())
aAreaSD2 := SD2->(GetArea())
aAreaSA1 := SA1->(GetArea())
aAreaF31 := F31->(GetArea())

If (lExt)
	// If it is called by Outflow Invoice, must be used the actual record.
	cKeySF2 := SF2->F2_FILIAL + SF2->F2_SERIE + DToS(SF2->F2_EMISSAO) + SF2->F2_DOC + SF2->F2_CLIENTE + SF2->F2_LOJA
Else
	// If it is called by Sales VAT Invoice, must be found the record in SF2.
	nPosSer := aScan(aHeader, {|x| AllTrim(x[2]) == "F2_SERIE"})
	nPosEmi := aScan(aHeader, {|x| AllTrim(x[2]) == "F2_EMISSAO"}) 
	nPosDoc := aScan(aHeader, {|x| AllTrim(x[2]) == "F2_DOC"}) 
	nPosCli := aScan(aHeader, {|x| AllTrim(x[2]) == "F2_CLIENTE"}) 
	nPosLoja := aScan(aHeader, {|x| AllTrim(x[2]) == "F2_LOJA"}) 
	nLinha := oDados:nAt
	
	cKeySF2 := xFilial("SF2") + oDados:aCols[nLinha][nPosSer] + DToS(CToD(oDados:aCols[nLinha][nPosEmi])) + ;
			oDados:aCols[nLinha][nPosDoc] + oDados:aCols[nLinha][nPosCli] + oDados:aCols[nLinha][nPosLoja]
EndIf

cPerg := "RU09T02"
nItem := 1

DbSelectArea("SF2")
SF2->(DbSetOrder(4)) //F2_FILIAL+F2_SERIE+DTOS(F2_EMISSAO)+F2_DOC+F2_CLIENTE+F2_LOJA
If (SF2->(DbSeek(cKeySF2)))
	DbSelectArea("SD2")
	SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	If (SD2->(DbSeek(SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA)))
		Pergunte(cPerg, .F.)
		
		oModelM := oModel:GetModel("F35MASTER")
		oModelD := oModel:GetModel("F36DETAIL")
		oModelF := oModel:GetModel("SF2DETAIL")
		
		oModelM:LoadValue("F35_FILIAL", xFilial("F35"))	// Purchases Commercial Invoice
		oModelM:LoadValue("F35_ORIGIN", "1")	// Purchases Commercial Invoice
		oModelM:LoadValue("F35_TYPE", "1")	// Purchases VAT Invoice
		oModelM:LoadValue("F35_IDATE", dDataBase)	// Issue date
		oModelM:LoadValue("F35_INVDT", SF2->F2_DTSAIDA)	// Commercial Invoice Issue Date
		oModelM:LoadValue("F35_INVDOC", SF2->F2_DOC)	// Commercial Invoice Number
		oModelM:LoadValue("F35_INVSER", SF2->F2_SERIE)	// Commercial Invoice Series
		oModelM:LoadValue("F35_CLIENT", SF2->F2_CLIENTE)	// Client
		oModelM:LoadValue("F35_BRANCH", SF2->F2_LOJA)	// Client Branch
		oModelM:LoadValue("F35_PDATE",;	// Print Date
			Iif(((dDataBase >= SF2->F2_DTSAIDA) .And. (dDataBase < SF2->F2_DTSAIDA + 5)), dDataBase, SF2->F2_DTSAIDA))
		oModelM:LoadValue("F35_ITDATE", SF2->F2_EMISSAO)	//Invoice Input Date
		oModelM:LoadValue("F35_TDATE", Date())	// Input Date
		oModelM:LoadValue("F35_INVCUR",Iif(SF2->F2_CONUNI == "1", "01", StrZero(SF2->F2_MOEDA,TamSX3("F35_INVCUR")[1])))
		oModelM:LoadValue("F35_C_RATE", SF2->F2_TXMOEDA)
		oModelM:LoadValue("F35_ICUDES", Posicione("CTO",1,xFilial("CTO")+PadL(FwFldGet("F35_INVCUR"),TamSX3("CTO_MOEDA")[1],'0'),"CTO_SIMB")) //Description
		oModelM:LoadValue("F35_CONUNI", SF2->F2_CONUNI)
		oModelM:LoadValue("F35_MOEDA", SF2->F2_MOEDA)
		oModelM:LoadValue("F35_MOEDES", Posicione("CTO",1,xFilial("CTO")+StrZero(FwFldGet("F35_MOEDA"),TamSX3("CTO_MOEDA")[1]),"CTO_SIMB"))
		oModelM:LoadValue("F35_VATVL", Iif(SF2->F2_CONUNI == "1", SF2->F2_VLIMP1M, SF2->F2_VALIMP1))	// VAT Value
		oModelM:LoadValue("F35_VALGR", Iif(SF2->F2_CONUNI == "1", SF2->F2_VLBRUTM, SF2->F2_VALBRUT))	// Gross Total
		oModelM:LoadValue("F35_VATBS", Iif(SF2->F2_CONUNI == "1", SF2->F2_BSIMP1M, SF2->F2_BASIMP1))	// VAT Base
		oModelM:LoadValue("F35_VATBS1", SF2->F2_BSIMP1M) // VAT Base Base
		oModelM:LoadValue("F35_VATVL1", SF2->F2_VLIMP1M)	// VAT Value Rubles
		oModelM:LoadValue("F35_CNEE_C", SF2->F2_CNEECOD)	// Consignee Code
		oModelM:LoadValue("F35_CNEE_B", SF2->F2_CNEEBR )	// Consignee Branch
		oModelM:LoadValue("F35_CNOR_C", SF2->F2_CNORCOD )	// Consignor Code
		oModelM:LoadValue("F35_CNOR_B", SF2->F2_CNORBR )	// Consignor Branch
		oModelM:LoadValue("F35_CNECLI", SF2->F2_CNEECLI )	// Consignee
		oModelM:LoadValue("F35_CNRVEN", SF2->F2_CNORVEN )	// Consignor
		oModelM:LoadValue("F35_CNRDES", Posicione('SA2',1,xFilial('SA2')+SF2->(F2_CNORCOD+F2_CNORBR),'A2_NREDUZ') )	// Consignor
		oModelM:LoadValue("F35_CNEDES", Posicione('SA1',1,xFilial('SA1')+SF2->(F2_CNEECOD+F2_CNEEBR),'A1_NREDUZ') )	// Consignee
		oModelM:LoadValue("F35_F5QUID", SF2->F2_F5QUID )
		oModelM:LoadValue("F35_CONTRA", SF2->F2_CNTID )
		oModelM:LoadValue("F35_F5QDES", Iif(!EMPTY(FwFldGet('F35_F5QUID')),Posicione('F5Q',1,XFILIAL('F5Q')+FwFldGet('F35_F5QUID'),'F5Q_DESCR'),'') )
		oModelM:LoadValue("F35_KPP_CL",;	// Client KPP
			Posicione("SA1", 1, xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA, "A1_INSCGAN"))
		oModelM:LoadValue("F35_KPP_CO", GetCoBrRUS()[2][5][2])	// Branch KPP!!!
		oModelM:LoadValue("F35_GOVCTR", Iif(!EMPTY(FwFldGet('F35_F5QUID')),Posicione('F5R',3,XFILIAL('F5R')+FwFldGet('F35_F5QUID'),'F5R_GOVID'),''))	// Identifier of government contract

		cTab := getTempTable(SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA, SF2->F2_EMISSAO)
		lRet := FillF36Table(oModelD, cTab)
		CloseTempTable(cTab)
		
		oModelF:LoadValue("F2_SERIE", SF2->F2_SERIE)
		oModelF:LoadValue("F2_DOC", SF2->F2_DOC)
		oModelF:LoadValue("F2_CLIENTE", SF2->F2_CLIENTE)
		oModelF:LoadValue("F2_LOJA", SF2->F2_LOJA)
		oModelF:LoadValue("F2_EMISSAO", SF2->F2_EMISSAO)
		oModelF:LoadValue("F2_VALBRUT", SF2->F2_VALBRUT)
		oModelF:LoadValue("F2_BASIMP1", SF2->F2_BASIMP1)
		oModelF:LoadValue("F2_VALIMP1", SF2->F2_VALIMP1)
	Else
		Help("",1,"RU09T02retInc01",,STR0015,1,0)	// "No Commercial Invoice's items found"
	EndIf
Else
	Help("",1,"RU09T02retInc02",,STR0016,1,0)	// "No Commercial Invoices found"
EndIf

RestArea(aAreaF31)
RestArea(aAreaSA1)
RestArea(aAreaSD2)
RestArea(aAreaSF2)
RestArea(aArea)
Return(oModel)

	
	
/*/{Protheus.doc} retKey
Function that returns the last value from the field F35_KEY.
@author felipe.morais
@since 10/05/2017
@version P12.1.16
@type function
/*/
Static Function retKey()
Local cQuery as Character
Local cTab as Character
Local cRet as Character
Local cProx as Character
Local aArea as Array

aArea := GetArea()

cQuery := " SELECT COALESCE(MAX(F35_KEY), '0') AS F35_KEY"
cQuery += " FROM " + RetSQLName("F35") + " T0"
cQuery += " WHERE T0.F35_FILIAL = '" + xFilial("F35") + "'"
cQuery += " AND T0.D_E_L_E_T_ = ' '"

cTab := MPSysOpenQuery(cQuery)

DbSelectArea((cTab))
(cTab)->(DbGoTop())

While ((cTab)->(!Eof()))
	cProx := Soma1(AllTrim((cTab)->F35_KEY))
	cRet := StrZero(Val(cProx), TamSX3("F36_KEY")[1])
	
	(cTab)->(DbSkip())
EndDo

(cTab)->(DbCloseArea())

RestArea(aArea) 
Return(cRet)


/*{Protheus.doc} ModelRecIns
@author Alexander Ivanov
@since 09/13/2019
@version P12.1.27
@type function
@description Save the model in case of "insert" operation 
*/
Static Function ModelRecIns(oModel as Object)
	
	// Submodels
	Local oModelM as Object
	Local oModelDet as Object
	Local oModelF as Object
	Local nOperation as Numeric

	Local lRet as Logical
	Local cNumber as Character
	Local cKey as Character
	Local aCompBranch as Array
	Local nI as Numeric
	Local nX as Numeric
	Local nItem as Numeric
	Local cInvDoc as Character
	Local dpdat as Date
	Local cNMBAlias as Character

	lRet := .T.
	oModelM := oModel:GetModel("F35MASTER")
	nOperation := oModel:GetOperation()
	cNumber := ""
	cKey := ""
	aCompBranch := GetCoBrRUS()
	cNMBAlias := "VATINV"

	cKey := retKey()
	While !(MayIUseCode("RU09T02"+cKey))
		cKey := Soma1(cKey)
	EndDo

	FreeUsedCode(.T.)
	oModelM:LoadValue("F35_KEY", cKey)

	cNumber := RU09D03NMB(cNMBAlias, Nil, xFilial("F35"))
	If Empty(cNumber)
		lRet := .F.
		Help("",1,"RU09T08EventRUS:ModelPosVld_01",,STR0951 + cNMBAlias,1,0)
	Else
		// Document Number
		oModelM:LoadValue("F35_DOC", cNumber + Iif(aCompBranch[2][7][2] == "1", "/"+AllTrim(aCompBranch[2][11][2]), ""))
		
		Begin Transaction
			If (FwIsInCallStack("MATA467N"))
				DbSelectArea("SF2")
				SF2->(DbSetOrder(1))
				oModelDet := oModel:GetModel("F36DETAIL")
				oModelF	:= oModel:GetModel("SF2DETAIL")
			
				dpdat := oModel:GetModel("F35MASTER"):GetValue("F35_PDATE")

				For nX := 1 to oModelF:Length()
					oModelF:GoLine(nX)
					If !(oModelF:Isdeleted())
						dpdat := max(dpdat, oModelF:GetValue("F2_DTSAIDA"))
					EndIf
				Next nX

				oModel:GetModel("F35MASTER"):LoadValue("F35_PDATE", dpdat)
			
				//(02/03/18): If user deletes the first (parrent) invoice we need to write number the next undeleted one		
				cInvDoc := alltrim(oModel:GetModel("F35MASTER"):GetValue("F35_INVDOC"))
				oModelF:GoLine(1)
				nX := 1
				If (oModelF:Isdeleted()) .AND. (cInvDoc == alltrim(oModelF:GetValue("F2_DOC")))
					While (oModelF:Isdeleted())
						nX++
						oModelF:GoLine(nX)	
					EndDo
					oModel:GetModel("F35MASTER"):LoadValue("F35_INVDOC", alltrim(oModelF:GetValue("F2_DOC")))
				EndIf

				nItem := 1
				For nI := 1 to oModelDet:Length()
					oModelDet:GoLine(nI)
					//If we have delete items we should move items
					If !(oModelDet:Isdeleted())
						oModelDet:LoadValue("F36_ITEM", StrZero(nItem, TamSX3("F36_ITEM")[1]))
						nItem++ 
					Else 

						For nX := 1 to oModelF:Length()
							oModelF:GoLine(nX)

							If (!(oModelF:Isdeleted()) .AND. (oModelF:GetValue("F2_DOC") == oModelDet:GetValue("F36_INVDOC"));
									.AND. (oModelF:GetValue("F2_SERIE") == oModelDet:GetValue("F36_INVSER")))

								oModelDet:LoadValue("F36_FLAG", " ")
								oModelDet:UnDeleteLine()
								oModelDet:LoadValue("F36_ITEM", StrZero(nItem, TamSX3("F36_ITEM")[1]))
								nItem++ 
							EndIf

						Next nX	

					EndIf

				Next nI

				RU09T02002_F2_STATUSR(oModel, "2",nOperation)
				FWFormCommit(oModel)
				If (oModelM:GetValue("F35_ATBOOK") == "1")
					gravaBook(oModel)
				EndIf

			Else
				RU09T02002_F2_STATUSR(oModel, "2", nOperation)
				FWFormCommit(oModel)
				
				ctbVAT(oModel, .T.)
				
				If (oModelM:GetValue("F35_ATBOOK") == "1")
					gravaBook(oModel)
				EndIf
			
			EndIf

			// Creating Outflow VAT Movements
			RU09D07Add(oModel)
		End Transaction
	EndIf
Return (lRet)


/*{Protheus.doc} ModelRecDel
@author Alexander Ivanov
@since 09/13/2019
@version P12.1.27
@type function
@description Save the model in case of "delete" operation 
*/
Static Function ModelRecDel(oModel as Object)
	Local lRet as Logical

	// Submodel
	Local oModelM as Object
	Local lContinuous as Logical

	lRet := .T.
	lContinuous := .T.
	oModelM := oModel:GetModel("F35MASTER")
	
	// Checks if it is filled the field F35_BOOK.
	If !(Empty(oModelM:GetValue("F35_BOOK")))
			lContinuous := .F.
			lRet := .F.
			// "Deletion is prohibited, because 'Book No.' field is not empty"
			Help("",1,"RU09T02ModelRec",,STR0017,1,0)
	EndIf
		
	Begin Transaction
		updSF2(oModelM:GetValue("F35_KEY"), .T.)
		
		If (lContinuous)
			// Posting accounting entries.
			ctbVAT(oModel, .F.)
			
			FWFormCommit(oModel)

			// Deleting Outflow VAT Movements
			RU09D07Del(oModel)
		EndIf
	End Transaction

Return (lRet)


/*{Protheus.doc} ModelRecOth
@author Alexander Ivanov
@since 09/13/2019
@version P12.1.27
@type function
@description Save the model in other cases - if neither insert nor delete operation is in progress  
*/
Static Function ModelRecOth(oModel as Object)
 	Local lRet as Logical
	Local nOperation as Numeric
	Local aArea as Array
	Local oModelM as Object

	lRet := .T.
	nOperation := oModel:GetOperation()
	oModelM := oModel:GetModel("F35MASTER")
	
	Begin Transaction
		aArea := GetArea()
		RU09T02002_F2_STATUSR(oModel, "", nOperation)
		RestArea(aArea)
		// Just commit.
		FWFormCommit(oModel)
		// Updating Outflow VAT Movements
		RU09D07Edt(oModel)

		updSF2(oModelM:GetValue("F35_KEY"), .F.)
	End Transaction

Return (lRet)


/*/{Protheus.doc} ModelRec
Function that saves the model.
@author felipe.morais
@since 10/05/2017
@version P12.1.16
@type function
/*/
Static Function ModelRec(oModel as Object)
	Local lRet := .T.
	Local nOperation := oModel:GetOperation()

	If (nOperation == MODEL_OPERATION_INSERT)
		lRet = ModelRecIns(oModel)
	ElseIf (nOperation == MODEL_OPERATION_DELETE)
		lRet = ModelRecDel(oModel)
	Else 
		lRet = ModelRecOth(oModel)
	EndIf

Return (lRet)


Static Function updSF2(cKeyF35 as Character, lDel as Logical)
Local lRet as Logical
Local cQuery as Character
Local cTab as Character
Local aArea as Array
Local aAreaSF2 as Array

lRet := .T.
aArea := GetArea()
aAreaSF2 := SF2->(GetArea())

cQuery := " SELECT DISTINCT T0.F36_FILIAL,"
cQuery += " T0.F36_INVDOC,"
cQuery += " T0.F36_INVSER,"
cQuery += " T1.F35_CLIENT,"
cQuery += " T1.F35_BRANCH"
cQuery += " FROM " + RetSQLName("F36") + " T0"
cQuery += " INNER JOIN " + RetSQLName("F35") + " T1"
cQuery += " ON ("
cQuery += " (T1.F35_FILIAL = T0.F36_FILIAL)"
cQuery += " AND (T1.F35_KEY = T0.F36_KEY)"
cQuery += " AND (T1.F35_DOC = T0.F36_DOC)"
cQuery += ")"
cQuery += " WHERE T0.F36_FILIAL = '" + xFilial("F36") + "'"
cQuery += " AND T0.F36_KEY = '" + cKeyF35 + "'"
cQuery += " AND T0.D_E_L_E_T_ = ''"

cTab := MPSysOpenQuery(cQuery)

DbSelectArea((cTab))
(cTab)->(DbGoTop())

	DbSelectArea("SF2")
	SF2->(DbSetOrder(1))
While ((cTab)->(!Eof()))
	If (SF2->(DbSeek(xFilial("SF2") + SubStr((cTab)->F36_INVDOC, 1, TamSX3("F2_DOC")[1]) + SubStr((cTab)->F36_INVSER, 1, TamSX3("F2_SERIE")[1]) + SubStr((cTab)->F35_CLIENT, 1, TamSX3("F2_CLIENTE")[1]) + SubStr((cTab)->F35_BRANCH, 1, TamSX3("F2_LOJA")[1]))))
		RecLock("SF2", .F.)
		SF2->F2_STATUSR := Iif(lDel, "", "2")
		SF2->(MsUnlock())
	EndIf

	(cTab)->(DbSkip())
EndDo

(cTab)->(DbCloseArea())

RestArea(aAreaSF2)
RestArea(aArea)
Return(lRet)

/*/{Protheus.doc} gravaBook

@author felipe.morais
@since 05/05/2017
@version P12.1.16
@param oModel, object, Needs to receive the actual model.
@type function
/*/

Static Function gravaBook(oModel as Object)
Local lRet := .T.
// Sales Book model and submodels
Local oBook as Object
Local oModelF39 as Object
Local oModelF3A as Object
// Sales Book model's properties
Local nOperation as Numeric
// Saved variables
Local cPrintDate := DToS(oModel:GetModel("F35MASTER"):GetValue("F35_PDATE"))
// Variables for SQL queries
Local cTab := ""
Local cQuery := ""
// Working areas (tables)
Local aArea := GetArea()
Local aAreaF39 := F39->(GetArea())
Local aAreaF3A := F3A->(GetArea())

DbSelectArea("F39")
F39->(DbSetOrder(1))

DbSelectArea("F3A")
F3A->(DbSetOrder(1))

cQuery := " SELECT T0.F39_BOOKEY"
cQuery += " FROM " + RetSQLName("F39") + " T0"
cQuery += " WHERE T0.F39_FILIAL = '" + xFilial("F39") + "'"
cQuery += " AND '" + cPrintDate + "' BETWEEN T0.F39_INIT AND T0.F39_FINAL"
cQuery += " AND T0.F39_STATUS = '1'"
cQuery += " AND T0.F39_AUTO = '1'"
cQuery += " AND T0.D_E_L_E_T_ = ' '"
cQuery += " ORDER BY T0.R_E_C_N_O_"
cTab := MPSysOpenQuery(cQuery)

If ((cTab)->(!Eof()))
	If (F39->(DbSeek(xFilial("F39") + (cTab)->F39_BOOKEY)))
		nOperation := MODEL_OPERATION_UPDATE
	Else
		lRet := .F.
		Help("",1,"gravaBook03",,STR0943,1,0)
	EndIf
Else
	nOperation := MODEL_OPERATION_INSERT
EndIf
(cTab)->(DbCloseArea())

// Loads Sales Book model.
oBook := FwLoadModel("RU09T04")
oBook:SetOperation(nOperation)
oBook:Activate()

oModelF39 := oBook:GetModel("F39MASTER")
oModelF3A := oBook:GetModel("F3ADETAIL")

cQuery := RU09T04_01getSQLquery(oModelF3A)
cQuery += " and T0.F35_KEY = '" + oModel:GetModel("F35MASTER"):GetValue("F35_KEY") + "'"
cQuery += RU09T04_02getSQLGroupOrder()
cTab := MPSysOpenQuery(cQuery)

If (nOperation == MODEL_OPERATION_INSERT)
	lRet := lRet .and. oModelF39:LoadValue("F39_FILIAL", xFilial("F39"))
	lRet := lRet .and. oModelF39:LoadValue("F39_INIT", SToD(SubStr(cPrintDate, 1, 6) + "01"))
	lRet := lRet .and. oModelF39:LoadValue("F39_FINAL", LastDay(SToD(cPrintDate)))
	lRet := lRet .and. oModelF39:LoadValue("F39_STATUS", "1")
	lRet := lRet .and. oModelF39:LoadValue("F39_AUTO", "1")
EndIf

oModelEvent 	:= RU09T04EventRUS():New()
lRet := lRet .and. oModelEvent:FillF3ATable(oModelF3A, cTab)
CloseTempTable(cTab)

// If the validation of the model is not successful.
If lRet .and. !oBook:VldData()
	lRet := .F.
	Help("",1,"gravaBook01",,STR0941,1,0)
// If commit not is successful.
ElseIf lRet .and. !oBook:CommitData()
	lRet := .F.
	Help("",1,"gravaBook02",,STR0942,1,0)
EndIf
oBook:DeActivate()

RestArea(aAreaF3A)
RestArea(aAreaF39)
RestArea(aArea)
Return(lRet)

/*/{Protheus.doc} ctbVAT
Function thats posts accounting entries.
@author felipe.morais
@since 05/05/2017
@version P12.1.16
@param oModel, object, Needs to receive the actual model.
@param lInc, logical, Needs to inform it is an inclusion or not.
@type function
/*/

Static Function ctbVAT(oModel as Object, lInc as Logical)
Local lRet := .T.
Local oModelF35 := oModel:GetModel("F35MASTER")
Local oModelF36 := oModel:GetModel("F36DETAIL")
Local nHdlPrv as Numeric
Local cLoteFis as Character
Local cOrigem as Character
Local cArquivo as Character
Local nTotal := 0
Local lCommit as Logical
Local cPadrao as Character
Local cKeyF35 := xFilial("F35") + oModelF35:GetValue("F35_CLIENT") + oModelF35:GetValue("F35_BRANCH") + DToS(oModelF35:GetValue("F35_PDATE")) + oModelF35:GetValue("F35_DOC") + oModelF35:GetValue("F35_TYPE")
Local cKeyF36 := xFilial("F36") + oModelF36:GetValue("F36_KEY")
Local cKeySD2 := ""
Local lMostra as Logical
Local lAglutina as Logical
Local cPerg as Character
Local nItem as Numeric
// Used areas
Local aArea := GetArea()
Local aAreaF35 := F35->(GetArea())
Local aAreaF36 := F36->(GetArea())
Local aAreaSF2 := SF2->(GetArea())
Local aAreaSA1 := SA1->(GetArea())
Local aAreaSD2 := SD2->(GetArea())
Local aAreaSB1 := SB1->(GetArea())
Local aAreaSC6 := SC6->(GetArea())
Local aAreaSB8 := SB8->(GetArea())
Local aAreaSF4 := SF4->(GetArea())
Local aAreaSFB := SFB->(GetArea())
Local aAreaF31 := F31->(GetArea())
Local aAreaF30 := F30->(GetArea())

cPerg := "RU09T02"

Pergunte(cPerg, .F.)
lMostra := (mv_par02 == 1)
lAglutina := (mv_par03 == 1)

nHdlPrv := 0
cLoteFis := LoteCont("FIS")
cOrigem := "RU09T02"
cArquivo := " "
lCommit := .F.
// If it is an inclusion, must be used the Standard Entry 6AA to the header.
// If it is a deletion, must be used the Standard Entry 6AC to the header.
cPadrao := Iif(lInc, "6AA", "6AC")
	
// Needs to set the records in tables F35, SF2 and SA1 to help the end user to work with Standard Entries 6AA and 6AC.
DbSelectArea("F35")
F35->(DbSetOrder(2))
If !(F35->(DbSeek(cKeyF35)))
	Help("",1,"RU09T02_ctbVAT_F35",,STR0023,1,0) // "VAT Sales Invoice Header of this record was not found. Cannot delete this record."
	Return .F.
EndIf

DbSelectArea("SF2")
SF2->(DbSetOrder(1))
If (FwFldGet("F35_TYPE") == "2") .and. !(SF2->(DbSeek(xFilial("SF2") + SubStr(F35->F35_INVDOC, 1, TamSX3("F2_DOC")[1]) + SubStr(F35->F35_INVSER, 1, TamSX3("F2_SERIE")[1]) + F35->F35_CLIENT + F35->F35_BRANCH)))
	Return .F.
EndIf

DbSelectArea("SA1")
SA1->(DbSetOrder(1))
SA1->(DbSeek(xFilial("SA1") + F35->F35_CLIENT + F35->F35_BRANCH))

DbSelectArea("F35")

nHdlPrv := HeadProva(cLoteFis, cOrigem, SubStr(cUserName, 1, 6), @cArquivo)

If (nHdlPrv > 0)
	nTotal += DetProva(nHdlPrv, cPadrao, cOrigem, cLoteFis, /*nLinha*/, /*lExecuta*/,;
	                   /*cCriterio*/, /*lRateio*/, /*cChaveBusca*/, /*aCT5*/,;
	                   /*lPosiciona*/, /*@aFlagCTB*/, /*aTabRecOri*/, /*aDadosProva*/)
	If (nTotal > 0)
		cA100Incl(cArquivo, nHdlPrv, 3, cLoteFis, lMostra, lAglutina)
	EndIf
	RodaProva(nHdlPrv, nTotal)

	// Updates the posting date.
	RecLock("F35", .F.)
	F35->F35_DTLA := dDataBase
	F35->(MsUnlock())
	
	// Updates the Outflow Document Status for Russia. 
	//If it is an inclusion needs to set "2" and if it is a deletion needs to set "1".
	RecLock("SF2", .F.)
	SF2->F2_STATUSR := Iif(lInc, "2", "1")
	SF2->(MsUnlock())

EndIf

// If it is an inclusion, must be used the Standard Entry 6AB to the items.
// If it is a deletion, must be used the Standard Entry 6AD to the items.
cPadrao := Iif(lInc, "6AB", "6AD")
nItem := 1

cKeySD2 := xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA

DbSelectArea("SD2")
SD2->(DbSetOrder(3))
SD2->(DbSeek(cKeySD2))

nTotal := 0
nHdlPrv := HeadProva(cLoteFis, cOrigem, SubStr(cUserName, 1, 6), @cArquivo)

While ((SD2->(!Eof())) .And. (cKeySD2 == xFilial("SD2") + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA))
	// Needs to set the records in tables SD2, SB1, SC6, SB8, SF4, SFB, F31, F30 and F36 to help the end user to work with Standard Entries 6AB and 6AD.
	
	// If there are no items linked to header, unexisted rows will be skipped and header will be deleted.
	DbSelectArea("F36")
	F36->(DbSetOrder(1))
	If !(F36->(DbSeek(cKeyF36 + StrZero(nItem, TamSX3("F36_ITEM")[1]))))
		SD2->(DbSkip())
		Loop
	EndIf
	
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1") + SD2->D2_COD))
	
	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	SC6->(DbSeek(xFilial("SC6") + SD2->D2_PEDIDO + SD2->D2_ITEMPV + SD2->D2_COD))
	
	DbSelectArea("SB8")
	SB8->(DbSetOrder(2))
	SB8->(DbSeek(xFilial("SB8") + SD2->D2_NUMLOTE + SD2->D2_LOTECTL + SD2->D2_COD + SD2->D2_LOCAL))
	
	DbSelectArea("SF4")
	SF4->(DbSetOrder(1))
	SF4->(DbSeek(xFilial("SF4") + SD2->D2_TES))
	
	DbSelectArea("SFB")
	SFB->(DbSetOrder(1))
	SFB->(DbSeek(xFilial("SFB") + "VAT"))
	
	DbSelectArea("F31")
	F31->(DbSetOrder(1))
	F31->(DbSeek(xFilial("F31") + SD2->D2_CF))
		
	DbSelectArea("F30")
	F30->(DbSetOrder(1))
	F30->(DbSeek(xFilial("F30") + F31->F31_RATE))
	
	nItem++
	
	If (nHdlPrv > 0)
		nTotal += DetProva(nHdlPrv, cPadrao, cOrigem, cLoteFis, /*nLinha*/, /*lExecuta*/,;
		                   /*cCriterio*/, /*lRateio*/, /*cChaveBusca*/, /*aCT5*/,;
		                   /*lPosiciona*/, /*@aFlagCTB*/, /*aTabRecOri*/, /*aDadosProva*/)
		
		RecLock("F36", .F.)
		F36->F36_DTLA := dDataBase
		F36->(MsUnlock())
	EndIf

	SD2->(DbSkip())
EndDo

If (nTotal > 0)
	cA100Incl(cArquivo, nHdlPrv, 3, cLoteFis, lMostra, lAglutina)
EndIf
RodaProva(nHdlPrv, nTotal)

RestArea(aArea)
RestArea(aAreaF35)
RestArea(aAreaF36)
RestArea(aAreaSF2)
RestArea(aAreaSA1)
RestArea(aAreaSD2)
RestArea(aAreaSB1)
RestArea(aAreaSC6)
RestArea(aAreaSB8)
RestArea(aAreaSF4)
RestArea(aAreaSFB)
RestArea(aAreaF31)
RestArea(aAreaF30)
Return(lRet)



/*/{Protheus.doc} RU09T02N
Function that returns the customer's name (time dependency).
@author felipe.morais
@since 10/07/2017
@version P12.1.16
@type function
/*/
Function RU09T02N()
Local cRet := ""
Local cKey := ""
Local aArea := GetArea()
Local aAreaSA1 := SA1->(GetArea())

If (IsInCallStack("RU09T02RUS"))
	If (IsInCallStack("RU09T02Add"))
		cKey := cCliente + cLoja
	ElseIf (IsInCallStack("RU09T02Mnl"))
		cKey := ""
	Else
		cKey := F35->F35_CLIENT + F35->F35_BRANCH
	EndIf
Else
	cKey := SF2->F2_CLIENTE + SF2->F2_LOJA
EndIf

DbSelectArea("SA1")
SA1->(DbSetOrder(1))
If !Empty(AllTrim(cKey)) .and. (SA1->(DbSeek(xFilial("SA1") + cKey)))
	cRet := SA1->A1_NOME
EndIf

RestArea(aAreaSA1)
RestArea(aArea)
Return(cRet)

/*/{Protheus.doc} RU09T02VAL
Function that validates F35_PDATE field.
@author artem.kostin
@since 10/20/2017
@version P12.1.18
@type function
/*/

Function RU09T02VAL()
Local lRet as Logical
Local aArea as Array
Local aAreaSF2 as Array
Local cKeySF2 as Character

lRet = .T.

cKeySF2 := M->F35_INVSER + DToS(M->F35_INVDT) + M->F35_INVDOC + M->F35_CLIENT + M->F35_BRANCH

aArea := GetArea()
aAreaSF2 := SF2->(GetArea())

DbSelectArea("SF2")
SF2->(DbSetOrder(4))
If !Empty(cKeySF2) .and. (SF2->(DbSeek(xFilial("SF2") + cKeySF2)))
	If ((M->F35_PDATE < F2_DTSAIDA) .or. (M->F35_PDATE > (F2_DTSAIDA + 5)))
		lRet = .F.
		Help("",1,"RU09T02VAL01",,STR0020,1,0) // "Wrong Print Date"
	EndIf
EndIf

RestArea(aAreaSF2)
RestArea(aArea)
Return(lRet)

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09T02act
Function that provides actions from out Outflow Modules
@author artem.kostin
@since 10/07/2017
@version P12.1.17
@param		nOperation	Numeric		Number of operation
			lInSide			Logical		Flag if function is called outside (.F.) for identifying SF2 record
@type function
/*/
//-----------------------------------------------------------------------
Function RU09T02act(nOperation, lInSide)
Local cQuery := ""
Local cTab := ""
Local cTabBook := ""
Local lRet	:=	.T.
Local aArea := GetArea()
Local aSF2Area := SF2->(GetArea())

Default lInSide := .F.

If lInSide
	DBSelectArea("SF2")
	SF2->(DbSetOrder(1))
	SF2->(DbSeek( xFilial("SF2") + F35->( F35_INVDOC + F35_INVSER + F35_CLIENT + F35_BRANCH ) ))
EndIf

cQuery	:=	" SELECT COUNT(*) AS COUNT1, MAX(F35.R_E_C_N_O_) AS RECNR " 

cQuery	+=	" FROM " + RetSqlName('F36') + " F36, " + RetSqlName('F35')+' F35 '
cQuery	+=	" WHERE "
cQuery	+=	" F35_FILIAL = '" + xFilial('F35') + "' AND "
cQuery	+=	" F36_FILIAL = '" + xFilial('F36') + "' AND "
cQuery	+=	" F36_KEY = F35_KEY AND "
// (F35->(DbSeek(xFilial("F35") + SF2->F2_SERIE + SF2->F2_DOC + SF2->F2_CLIENTE + SF2->F2_LOJA)))
cQuery	+=	" F36_INVSER = '" + SF2->F2_SERIE + "' AND"
cQuery	+=	" F36_INVDOC = '" + SF2->F2_DOC + "' AND"
cQuery	+=	" F35_CLIENT = '" + SF2->F2_CLIENTE  + "' AND"
cQuery	+=	" F35_BRANCH = '" + SF2->F2_LOJA  + "' AND"

cQuery	+=	" F36.D_E_L_E_T_= ' ' AND "
cQuery	+=	" F35.D_E_L_E_T_= ' ' "

If !lInSide
	cTab := MPSysOpenQuery(cQuery)
	If (cTab)->COUNT1 == 0 
		Help("",1,"RU09T02act01",,STR0018,1,0)	// "There is no VAT Invoice for this record."
		lRet	:=	 .F.
	Else
		F35->(DbGoto((cTab)->RECNR))
	EndIf
	DbSelectArea(cTab)
	DbCloseArea()
EndIf

If (lRet .and. (nOperation == MODEL_OPERATION_DELETE .or. nOperation == MODEL_OPERATION_UPDATE))
	cQuery	+=	" AND F35_BOOK <> '' "
	cTabBook := MPSysOpenQuery(cQuery)

	If (cTabBook)->COUNT1 > 0
		Help("",1,"RU09T02Act02",,STR0017 + F35->F35_BOOK,1,0)	// Action is prohibited. This record is already in the Sales Book:
		lRet := .F.
	EndIf
	DbSelectArea(cTabBook)
	DbCloseArea()
EndIf

If lRet
	FWExecView(" ","RU09T02",nOperation,,{|| .T.})
EndIf

If lInSide
	SF2->(DbCloseArea())
EndIf

RestArea(aSF2Area)
RestArea(aArea)
Return lRet 
//merge branch 12.1.19

/*{Protheus.doc} RU09T02Chn
@author Alexandra Menyashina
@since 20/12/2017
@version 1.0
@return Nil, return nil
@type function
@description Changing number in Sales VAT Invoice and in Sales Book for Russia
*/

function RU09T02Chn()
Local oModel as Object
Local oModelM as Object
local cTitle as char
local cOldlab as char
local cOldVal as char
local cNewLab as char
local cNewVal as char
local cLine as char
local nWidth as numeric
local nHeight as numeric
local cQuery as char
local nStatus as numeric
private oDlg as object

oModel	:= FwLoadModel("RU09T02")
oModel:SetOperation(MODEL_OPERATION_UPDATE)
oModel:Activate()
oModelM := oModel:GetModel("F35MASTER")

cTitle := STR0027
cOldlab := STR0030
cOldVal := oModelM:GetValue("F35_DOC")
cNewlab := STR0031
cNewVal := oModelM:GetValue("F35_DOC")
cLine := "<hr>"
nWidth:=250
nHeight:=100

oDlg := TDialog():New(000,000,nHeight,nWidth,cTitle,,,,,,,,,.T.)
oGBC:= tGridLayout():New(oDlg,CONTROL_ALIGN_ALLCLIENT)

oOldlab:= TSay():New(,, {|| cOldlab}, oGBC,,,,,,.T.,,,,,,,,,,.T.)
oOldDoc := TGet():New(,, { | u | If(PCount() == 0, cOldVal, cOldVal := u) },oGBC, 60, 10,"!@",,;
	0, 16777215,,,,.T.,,,,,,,.T.,.F.,,"cOldVal",,,,.F.,,,,)
oNewlab:= TSay():New(,, {|| cNewlab}, oGBC,,,,,,.T.,,,,,,,,,,.T.)
oNewDoc := TGet():New(,, { | u | If(PCount() == 0, cNewVal, cNewVal := u) },oGBC, 60, 10,"!@",,;
	0, 16777215,,,,.T.,,,,,,,.F.,.F.,,"cNewVal",,,,.F.,,,,)
oLine:= TSay():New(,, {|| cLine}, oGBC,,,,,,.T.,,,,,,,,,,.T.)
oButton1 := TButton():New(,, STR0028, oGBC,{||{ButtonOk(oModel, cNewVal),oDlg:End()}},;
	40,10,,,.F.,.T.,.F.,,.F.,,,.F.)
oButton2 := TButton():New(,, STR0029, oGBC,{||oDlg:End()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F.)

oGBC:addInLayout(oOldlab,1,1,1,1,LAYOUT_ALIGN_HCENTER + LAYOUT_ALIGN_TOP)
oGBC:addInLayout(oOldDoc,2,1,1,1,LAYOUT_ALIGN_HCENTER + LAYOUT_ALIGN_TOP)
oGBC:addInLayout(oNewlab,1,2,1,1,LAYOUT_ALIGN_HCENTER + LAYOUT_ALIGN_TOP)
oGBC:addInLayout(oNewDoc,2,2,1,1,LAYOUT_ALIGN_HCENTER + LAYOUT_ALIGN_TOP)
oGBC:addInLayout(oLine,3,1,1,2)
oGBC:addInLayout(oButton1,4,1,1,1,LAYOUT_ALIGN_HCENTER + LAYOUT_ALIGN_TOP)
oGBC:addInLayout(oButton2,4,2,1,1,LAYOUT_ALIGN_HCENTER + LAYOUT_ALIGN_TOP)

oDlg:Activate(,,,.T.,,,)
oModel:DeActivate()
Return nil

static function ButtonOk(oModel as Object, cNewVal as Character)
Local lRet := .T.
Local aArea := GetArea()
Local oModelF35 := oModel:GetModel("F35MASTER")
Local lNoBook	as Logical
Local cVATKey	as Character
Local nLine		as Numeric
Local oBook		as Object
Local oModelF3A as Object

oModelF35:LoadValue("F35_DOC", AllTrim(cNewVal))
lNoBook := Empty(oModelF35:GetValue("F35_BOOK"))

If !lNoBook
	DbSelectArea("F39")
	F39->(DbSetOrder(1))
	If (F39->(DbSeek(xFilial("F39") + oModelF35:GetValue("F35_BOOK"))))
		oBook	:= FwLoadModel("RU09T04")
		oBook:SetOperation(MODEL_OPERATION_UPDATE)
		oBook:Activate()
	Else
		lRet := .F.
		Help("",1,"NOBOOK",,STR0026,1,0) // "There is no Sales Book for this Sales VAT Invoice."
	EndIf
EndIf

//Change doc number in sales book if it exist
If lRet .And. !lNoBook
	cVATKey := oModelF35:GetValue("F35_KEY")
	oModelF3A := oBook:GetModel("F3ADETAIL")
	For nLine := 1 to oModelF3A:Length(.F.)
		oModelF3A:GoLine(nLine)
		If (oModelF3A:GetValue("F3A_KEY") == cVATKey)
			oModelF3A:LoadValue("F3A_DOC", AllTrim(cNewVal))
		EndIf
	Next nLine
EndIf

If (lRet)
	Begin Transaction
		// If the validation of the model is not successful.
		If lRet .and. !oModel:VldData()
			lRet := .F.
			DisarmTransaction()
			Help("",1,"ButtonOk:01",,STR0941,1,0)
		// If commit not is successful.
		ElseIf lRet .and. !oModel:CommitData()
			lRet := .F.
			DisarmTransaction()
			Help("",1,"ButtonOk:02",,STR0942,1,0)
		EndIf

		// If the validation of the model is not successful.
		If lRet .And. !lNoBook
			If !oBook:VldData()
				lRet := .F.
				DisarmTransaction()
				Help("",1,"ButtonOk:03",,STR0941,1,0)
			// If commit not is successful.
			ElseIf !oBook:CommitData()
				lRet := .F.
				DisarmTransaction()
				Help("",1,"ButtonOk:04",,STR0942,1,0)
			EndIf
		EndIf
	End Transaction
EndIf

RestArea(aArea)
Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} TableAttDef

@param		Nenhum
@return	Nenhum

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		16/01/2017
/*/
//-------------------------------------------------------------------

Static Function TableAttDef()
Local oTableAtt as Object
Local lCRMBrwView as Logical

oTableAtt 	:= Nil
lCRMBrwView	:= ExistBlock("CRMBRWVIEW")	// Entrance point for views
	

	If lCRMBrwView
		oTableAtt := ExecBlock("CRMBRWVIEW", .F.,.F.,{cRotina,cAliasView})
	EndIf 
	
	If Empty(oTableAtt)
	
		oTableAtt 	:= FWTableAtt():New()
		oTableAtt:SetAlias("F35")
EndIf

Return oTableAtt

/*{Protheus.doc} LoadComInv
@author Alexandra Menyashina
@since 08/02/2018
@version P12.1.20
@return nil
@type function
@description Function which added in Model structure more Invoice.
*/

static Function LoadComInv(oStructSF2 as object ,cFillial as Character, cClient as Character, cBranch as Character, cKey as Character)
Local nX as Numeric
Local cQuery as Character
Local cTab as Character
Local aRet as Array
Local aTmp as Array
Local aFields as Array
Local xValue

aRet := {}
cQuery := ""
cTab := ""
aFields	:= oStructSF2:GetFields()

cQuery := " SELECT DISTINCT "
For nX := 1 To Len(aFields)
	cQuery	+= aFields[nX, MODEL_FIELD_IDFIELD] + IIf(nX == Len(aFields), "", ",")
Next nX
cQuery += " FROM " + RetSQLName("SF2") + " T0"
cQuery += " INNER JOIN " + RetSQLName("F36") + " T1"
cQuery += " ON ("
cQuery += " T1.F36_FILIAL = T0.F2_FILIAL"
cQuery += " AND T1.F36_INVSER = T0.F2_SERIE"
cQuery += " AND T1.F36_INVDOC = T0.F2_DOC"
cQuery += " AND T1.F36_KEY = '" + cKey + "'"
cQuery += " AND T1.D_E_L_E_T_ = ' '"
cQuery += ")"
cQuery += " WHERE T0.F2_FILIAL = '" + cFillial + "'"
cQuery += " AND T0.F2_CLIENTE = '" + cClient + "'"
cQuery += " AND T0.F2_LOJA = '" + cBranch + "'"
cQuery += " AND T0.F2_STATUSR = '2'"
cQuery += " AND T0.D_E_L_E_T_ = ''"
cQuery += " ORDER BY F2_SERIE, F2_DOC"

cTab := MPSysOpenQuery(cQuery)

While (cTab)->(!EOF())
	aTmp	:= {}
	For nX := 1 To Len(aFields)
		xValue	:= &("('"+cTab+"')->" + aFields[nX, MODEL_FIELD_IDFIELD])
		If aFields[nX, MODEL_FIELD_TIPO] == "D"
			xValue	:= SToD(xValue)
		EndIf
		aAdd(aTmp, xValue)
	Next nX

	aAdd(aRet, {Len(aRet) + 1, aTmp})
	(cTab)->(dbSkip())
EndDo

(cTab)->(DbCloseArea())

Return aRet



/*{Protheus.doc} RU09T02CIB
@author Alexandra Menyashina
@since 15/01/2018
@version P12.1.20
@return nil
@type function
@description Function that add more Commertial Invoice with MarkBrowse().
*/
function RU09T02CIB()
local aAreaSF2 as Array
local nWidth as numeric
local nHeight as numeric
local cTitle as char
Local aStruSF2 as Array
local nX as numeric
local cSeria as character
local cInvdoc as character
local cClient as character
local cBranch as character
local dPdate as date
Local aSize as Array
Local lBook as Logical
Private aRotina as Character

private oMoreDlg as object
private oBrowsePut as object
Private oTempTable 	as Object
Private cTempTbl 	as Character
Private cMark		as Character

/*download current oModel*/
oModel  := FwModelActive()		
If ValType(oModel) <> 'O'
	oModel	:= FwLoadModel("RU09T02")
EndIf

oModel:Activate()
oModelM	:= oModel:GetModel("F35MASTER")
lBook := Empty(oModelM:GetValue("F35_BOOK"))

If (lBook)
	cSeria	:= oModelM:GetValue("F35_INVSER")
	cInvdoc	:= oModelM:GetValue("F35_INVDOC")
	cClient	:= oModelM:GetValue("F35_CLIENT")
	cBranch	:= oModelM:GetValue("F35_BRANCH")
	dPdate	:= oModelM:GetValue("F35_PDATE")
	
	aAdvSize	:= MsAdvSize()
	nHeight	:= 0.5*(aAdvSize[4] - aAdvSize[2])
	nWidth	:= (aAdvSize[3] - aAdvSize[1])
	nX:=0
	cTempTbl	:= CriaTrab(,.F.)
	aStruSF2	:= {}
	aColumns 	:= {}
	
	aSize := MsAdvSize(.F.)
	
	//-----------------------------------------------------------------------
	// Create temporary table
	//-----------------------------------------------------------------------
	MsgRun(STR0037,STR0038,{|| MyCreaTRB(cSeria, cInvdoc, cClient, cBranch, dPdate)})//"Please wait"//"Creating temporary table"
	
	aAdd(aStruSF2, {"F2_SERIE",STR0039, PesqPict("SF2","F2_SERIE")})//"Seria"
	aAdd(aStruSF2, {"F2_DOC",STR0040, PesqPict("SF2","F2_DOC")})//"Document"
	aAdd(aStruSF2, {"F2_DTSAIDA",STR0045	, PesqPict("SF2","F2_DTSAIDA")})//"Com Inv Issue Date"
	aAdd(aStruSF2, {"F2_EMISSAO",STR0041	, PesqPict("SF2","F2_EMISSAO")})//"Com Inv Issue Date"
	aAdd(aStruSF2, {"F2_CLIENTE",STR0042	, PesqPict("SF2","F2_CLIENTE")})//"Customer"
	aAdd(aStruSF2, {"F2_LOJA",STR0043, PesqPict("SF2","F2_LOJA")})//"Name"
	aAdd(aStruSF2, {"F2_VALBRUT",STR0044, PesqPict("SF2","F2_VALBRUT")})//"Invoice Gross Value"
	
	For nX := 1 TO Len(aStruSF2)
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData(&("{||"+aStruSF2[nX][1]+"}"))
		aColumns[Len(aColumns)]:SetTitle(aStruSF2[nX][2]) 
		aColumns[Len(aColumns)]:SetSize(TamSx3(aStruSF2[nX][1])[1]) 
		aColumns[Len(aColumns)]:SetDecimal(TamSx3(aStruSF2[nX][1])[2])
		aColumns[Len(aColumns)]:SetPicture(aStruSF2[nX][3]) 
	Next nX
	
	//oMoreDlg := TDialog():New(000,000,nHeight,nWidth,cTitle,,,,,,,,,.T.)
	oMoreDlg := MsDialog():New(aSize[7], aSize[2], aSize[6], aSize[5], STR0033, , , , , CLR_BLACK, CLR_WHITE, , , .T., , , , .T.) // "Sales Invoices"
	//-----------------------------------------------------------------------
	//define MarkBrowse
	//-----------------------------------------------------------------------
	oBrowsePut := FWMarkBrowse():New()
	//-----------------------------------------------------------------------
	//activate MarkBrowse
	//-----------------------------------------------------------------------
	oBrowsePut:SetFieldMark("F2_OK")
	oBrowsePut:SetOwner(oMoreDlg)
	oBrowsePut:SetAlias(cTempTbl)
	aRotina	 := RU09T02MCI() //Reset global aRotina
	oBrowsePut:SetMenuDef("RU09T02MCI")
	
	oBrowsePut:SetColumns(aColumns)
	oBrowsePut:bAllMark := {||MarkAll(oBrowsePut, cTempTbl)}
	
	//FWMarkBrowse (): SetDoubleClick (<bLDblClick>)
	oBrowsePut:DisableReport()
	oBrowsePut:Activate()
	
	cMark := oBrowsePut:Mark()
	
	oMoreDlg:Activate(, , , .T., {|| .T.}, , {|| .F.})
	//oMoreDlg:Activate(,,,.T.,,,)
	
	(cTempTbl)->(dbCloseArea())
	oTempTable:Delete()
	aRotina	 := MenuDef() //Nothing Changed :P
EndIf
Return nil

/*{Protheus.doc} RU06D10
@author Alexander Ivanov
@since 10/02/2019
@version P12.1.27
@return
@type function
@description Appends array with subarray of field name, type, width and precision of each column name
*/
Static Function RU09T02003_AppendFields(aList as Array, aFieldNames as Array)

	Local aField      as Array
	Local nWidth      as Numeric
	Local nDigits     as Numeric
	Local nI    	  as Numeric	
	Local cFieldName  as Character
	Local cType       as Character

	For nI := 1 To Len(aFieldNames)
		cFieldName := aFieldNames[nI]
		cType :=   GetSX3Cache(cFieldName, "X3_TIPO")
		nWidth :=  GetSX3Cache(cFieldName, "X3_TAMANHO")
		nDigits := GetSX3Cache(cFieldName, "X3_DECIMAL")
		aField := {cFieldName, cType, nWidth, nDigits}
		aAdd(aList, aField)
	Next
Return


/*{Protheus.doc} RU06D10
@author Alexander Ivanov
@since 10/02/2019
@version P12.1.27
@return
@type function
@description Makes cDelimiter-separated query from array of fiels
*/
Static Function RU09T02004_JoinFields(aFields as Array, cDelimiter as Character)

	Local cColumn as Character
	Local cQuery  as Character
	Local nI      as Numeric	
	Local nMax    as Numeric

	nMax := Len(aFields )
	cQuery := ""

	For nI := 1 To nMax-1
		cColumn := aFields[nI][1]
		cQuery += (cColumn + cDelimiter)
	Next

	If  Len(aFields)>0
		cColumn := aFields[nMax][1]
		cQuery += cColumn
	EndIf

Return cQuery

/*{Protheus.doc} MyCreaTRB
@author Alexandra Menyashina
@since 16/01/2018
@version P12.1.20
@return nil
@type function
@description Create temporary table and insert data into it.
*/
Static Function MyCreaTRB(cSeria, cInvdoc, cClient, cBranch, dPdate)

Local aFields     as Array
Local cColumnList as Character
Local cQuery      as Character
Local cQueryStart as Character
Local cListDoc    as Character
Local cConUni     as Character
Local cSeries     as Character
Local cDoc        as Character
Local cClient     as Character
Local cLoja       as Character
Local cSeek       as Character
Local dEmisao     as Date
Local nI          as Numeric
Local nMoeda      as Numeric
Local oModel      as Object
Local oModelF     as Object

cListDoc := ""

/* Object creation*/
oTempTable := FWTemporaryTable():New(cTempTbl)

oModel  := FwModelActive()		
If ValType(oModel) <> 'O'
	oModel	:= FwLoadModel("RU09T02")
EndIf

oModelF := oModel:GetModel("SF2DETAIL")
oModelF35 := oModel:GetModel("F35MASTER")
cSeries := oModelF35:GetValue("F35_INVSER")
dEmisao	:= oModelF35:GetValue("F35_INVDT")
cDoc    := oModelF35:GetValue("F35_INVDOC")	
cClient := oModelF35:GetValue("F35_CLIENT")
cLoja   := oModelF35:GetValue("F35_BRANCH")	

If  !((SF2->F2_FILIAL == xFILIAL("SF2"));
 	     .And. (SF2->F2_SERIE == cSeries);
         .And. (SF2->F2_EMISSAO == dEmisao);
         .And. (SF2->F2_DOC == cDoc);
         .And. (SF2->F2_CLIENTE == cClient);
         .And. (SF2->F2_LOJA == cLoja))
    
        cSeek := xFILIAL("SF2") + cSeries + DTOS(dEmisao) + cDoc + cClient + cLoja 
    
 		DbSelectArea("SF2")
		SF2->(DbSetOrder(4))
		SF2->(DbSeek(cSeek))
EndIf       
 
 cConUni := SF2->F2_CONUNI
 nMoeda := SF2->F2_MOEDA

// Table fields
aFields := {}
aAdd(aFields, {"F2_OK", "C", 1, 00})
RU09T02003_AppendFields(aFields, {"F2_FILIAL","F2_DOC","F2_DTSAIDA","F2_EMISSAO","F2_SERIE","F2_CLIENTE","F2_LOJA","F2_VALBRUT"})

oTemptable:SetFields(aFields)
oTempTable:AddIndex("indice1", {"F2_FILIAL", "F2_DOC", "F2_SERIE", "F2_CLIENTE", "F2_LOJA"})

// Table creation
oTempTable:Create()

cColumnList := RU09T02004_JoinFields(aFields, ", ")
cQueryStart := " INSERT INTO " + oTempTable:GetRealName()
cQueryStart += " (" +  cColumnList  + ") "

cQuery := " SELECT '0' " + cColumnList
cQuery += " FROM " + RetSQLName("SF2")
cQuery += " WHERE F2_FILIAL = '" +  xfilial("SF2")  + "'"
cQuery += " AND F2_SERIE = '" + cSeria + "'"
cQuery += " AND F2_EMISSAO <= '" + DTOS(dPdate+4)  + "'"
cQuery += " AND F2_EMISSAO >= '" + DTOS(dPdate-4)  + "'"
cQuery += " AND F2_CLIENTE = '" + cClient + "'"
cQuery += " AND F2_LOJA = '" + cBranch + "'"
cQuery += " AND F2_CONUNI = '" + cConUni + "'"
cQuery += " AND F2_MOEDA = '" + CValToChar(nMoeda) + "'"
cQuery += " AND F2_STATUSR != '2' AND NOT ("

Begin Transaction
	For nI := 1 To oModelF:Length()
		oModelF:GoLine(nI)
		cQuery += " (F2_DOC ='" + oModelF:GetValue("F2_DOC") + "'"
		cQuery += " AND F2_EMISSAO ='" + DTOS(oModelF:GetValue("F2_EMISSAO")) + "'"
		cQuery += " AND F2_SERIE ='" + oModelF:GetValue("F2_SERIE") + "') OR"
	Next nI
	
	cQuery := SubStr(cQuery, 1, Len(cQuery)-2)
	cQuery += ") AND D_E_L_E_T_ =' '"

	cQuery := cQueryStart + ChangeQuery(cQuery)
	nStatus := TCSqlExec(cQuery)

	DbSelectArea(cTempTbl) 
	DbGotop()
End Transaction

Return nil

/*{Protheus.doc} MarkAll
@author Alexandra Menyashina
@since 16/01/2018
@version P12.1.20
@param		oBrowsePut - Object
			cTempTbl - Alias markbrowse
@return .T.
@type function
@description Mark all records in MarkBrowse.
*/

static function MarkAll(oBrowsePut as Object, cTempTbl as Character)
Local nRecOri 	as Numeric

nRecOri	:= (cTempTbl)->(RecNo())

dbSelectArea(cTempTbl)
(cTempTbl)->(DbGoTop())
Do While !(cTempTbl)->(Eof())
	RecLock(cTempTbl, .F.)
	If !Empty((cTempTbl)->F2_OK)
		(cTempTbl)->F2_OK := ''
	Else
		(cTempTbl)->F2_OK := cMark
	EndIf
	MsUnlock()

	(cTempTbl)->(DbSkip())
EndDo

(cTempTbl)->(DbGoTo(nRecOri))

oBrowsePut:oBrowse:Refresh(.T.)

Return .T.

/*{Protheus.doc} RU09T02MCI
@author Alexandra Menyashina
@since 16/01/2018
@version P12.1.20
@param None
@return aRet - button array
@type function
@description Menu for MarkBrowse.
*/

static Function RU09T02MCI()
Local aRet as Array


aRet := {{STR0006, "RU09T02PIN()", 0, 2, 0, Nil},; //"View"
		{STR0035, "RU09T02Run()", 0, 10/*3*/, 0, Nil},; //"Run "
		{STR0052, "RU09T02Che()", 0, 10/*4*/, 0, Nil}} //"Check interval "
Return aRet

/*{Protheus.doc} RU09T02Run
@author Alexandra Menyashina
@since 16/01/2018
@version P12.1.20
@param None
@return nil
@type function
@description Creation new VAT Invoice with checked Commertial Invoice
*/
Function RU09T02Run()

Local lRet := .T.
local aAreaTMPTAB as array
Local aArea as Array
Local aAreaSF2 as Array
local oModel as object
local oModelM as object
local oModelD as object
local oModelF as object
local cKeySF2 as Character
local nItem as numeric
local nItemF as numeric
// SQL query
local cTab := ""
// Currency
Local cConuni := ""
Local nMoeda as Numeric

if (RU09T02Che())
aArea := GetArea()
aAreaSF2 := SF2->(GetArea())

/*download current oModel*/
oModel  := FwModelActive()		
If ValType(oModel) <> 'O'
	oModel	:= FwLoadModel("RU09T02")
EndIf
//oModel:Activate()
oModelM := oModel:GetModel("F35MASTER")
oModelD := oModel:GetModel("F36DETAIL")
oModelF := oModel:GetModel("SF2DETAIL")

aAreaTMPTAB := (cTempTbl)->(GetArea())
(cTempTbl)->(DbGotop())
nItem := 0
nItemF := 0

nMoeda := oModelM:GetValue("F35_MOEDA")
cConUni := oModelM:GetValue("F35_CONUNI")

DbSelectArea("SF2")
SF2->(DbSetOrder(4)) //F2_FILIAL+F2_SERIE+DTOS(F2_EMISSAO)+F2_DOC+F2_CLIENTE+F2_LOJA
While !((cTempTbl)->(Eof()))
	If ((cTempTbl)->F2_OK == cMark)
	
		cTab := getTempTable((cTempTbl)->F2_DOC, (cTempTbl)->F2_SERIE, (cTempTbl)->F2_CLIENTE, (cTempTbl)->F2_LOJA, (cTempTbl)->F2_EMISSAO)
		lRet := FillF36Table(oModelD, cTab)
		CloseTempTable(cTab)
		
		cKeySF2 := (cTempTbl)->F2_FILIAL + (cTempTbl)->F2_SERIE + DToS((cTempTbl)->F2_EMISSAO) + (cTempTbl)->F2_DOC +  (cTempTbl)->F2_CLIENTE + (cTempTbl)->F2_LOJA
		(SF2->(DbSeek(cKeySF2)))
		
		nItemF := oModelF:AddLine()
		oModelF:LoadValue("F2_SERIE", (cTempTbl)->F2_SERIE)
		oModelF:LoadValue("F2_DOC", (cTempTbl)->F2_DOC)
		oModelF:LoadValue("F2_CLIENTE", (cTempTbl)->F2_CLIENTE)
		oModelF:LoadValue("F2_LOJA", (cTempTbl)->F2_LOJA)
		oModelF:LoadValue("F2_EMISSAO", (cTempTbl)->F2_EMISSAO)
		oModelF:LoadValue("F2_VALBRUT", (cTempTbl)->F2_VALBRUT)
		oModelF:LoadValue("F2_BASIMP1", SF2->F2_BASIMP1)
		oModelF:LoadValue("F2_VALIMP1", SF2->F2_VALIMP1)
		
		oModelM:LoadValue("F35_VATVL", oModelM:GetValue("F35_VATVL") + Iif(SF2->F2_CONUNI == "1", SF2->F2_VLIMP1M, SF2->F2_VALIMP1))
		oModelM:LoadValue("F35_VALGR", oModelM:GetValue("F35_VALGR") + Iif(SF2->F2_CONUNI == "1", SF2->F2_VLBRUTM, SF2->F2_VALBRUT))
		oModelM:LoadValue("F35_VATBS", oModelM:GetValue("F35_VATBS") + Iif(SF2->F2_CONUNI == "1", SF2->F2_BSIMP1M, SF2->F2_BASIMP1))
		oModelM:LoadValue("F35_VATBS1", oModelM:GetValue("F35_VATBS1") + SF2->F2_BSIMP1M)
		oModelM:LoadValue("F35_VATVL1", oModelM:GetValue("F35_VATVL1") + SF2->F2_VLIMP1M)
	EndIf
	(cTempTbl)->(DbSkip())
EndDo

RfrshView()
oMoreDlg:End()

RestArea(aAreaSF2)
RestArea(aArea)
EndIf

Return nil



/*{Protheus.doc} RU09T02PIN
@author Alexandra Menyashina
@since 06/02/2018
@version P12.1.19
@param None
@return nil
@type function
@description View of checked Commertial Invoice
*/
Function RU09T02PIN()
Local aArea as Array
Local aAreaSF2 as Array
Local aAreaSD2 as Array
Local oModelM as Object
Local cKeySF2 as Character

aArea := GetArea()
aAreaSF2 := SF2->(GetArea())
aAreaSD2 := SD2->(GetArea())
oModelM := oModel:GetModel("F35MASTER")

		DbSelectArea("SF2")
		SF2->(DbSetOrder(4))
While !((cTempTbl)->(Eof()))
	If ((cTempTbl)->F2_OK == cMark)
		cKeySF2 := (cTempTbl)->F2_FILIAL + (cTempTbl)->F2_SERIE + DTOS((cTempTbl)->F2_EMISSAO) + (cTempTbl)->F2_DOC + (cTempTbl)->F2_CLIENTE + (cTempTbl)->F2_LOJA
		If (SF2->(DbSeek(cKeySF2)))
			CtbDocSaida()	// open View SF2/SD2
		EndIf
	EndIf
	(cTempTbl)->(DbSkip())
EndDo	
RestArea(aAreaSD2)
RestArea(aAreaSF2)
RestArea(aArea)
Return

/*{Protheus.doc} ComInvCl
@author Alexandra Menyashina
@since 10/02/2018
@version P12.1.19
@param 	oModel - current model
		nLine - current position in Grid
@return nil
@type function
@description double click in grid with SF2
*/
static Function ComInvCl(oModel as object, nLine as numeric)
Local aArea as Array
Local aAreaSF2 as Array
Local aAreaSD2 as Array
Local oModelF as Object
Local cKeySF2 as Character

Private aRotina as Array

aRotina	:=	{{"","",0,2,0,Nil},;
			{"","",0,2,0,Nil},;
			{"","",0,2,0,Nil},;
			{"","",0,2,0,Nil}}
aArea := GetArea()
aAreaSF2 := SF2->(GetArea())
aAreaSD2 := SD2->(GetArea())
oModelF := oModel:GetModel("SF2DETAIL")
DbSelectArea("SF2")
SF2->(DbSetOrder(1))
cKeySF2 := xFilial('SF2') + oModelF:GetValue("F2_DOC")+ oModelF:GetValue("F2_SERIE")+ oModelF:GetValue("F2_CLIENTE") + oModelF:GetValue("F2_LOJA")
If (SF2->(DbSeek(cKeySF2)))
	CtbDocSaida()	// open View SF2/SD2
EndIf
RestArea(aAreaSD2)
RestArea(aAreaSF2)
RestArea(aArea)
Return nil

/*{Protheus.doc} RU09T02Che
@author Alexandra Menyashina
@since 20/02/2018
@version P12.1.19
@param None
@return nil
@type function
@description Checking time interval 
*/
Function RU09T02Che(dFirst1 as Date, dLast1 as Date)
local aAreaTMPTAB as array
local oModelM as object
local oModelF as object
Local lRet as logical
local dPdate as date
Local dLast as date
Local dCurrent as date
Local nI as numeric

/*download current oModel*/
oModel  := FwModelActive()		
If ValType(oModel) <> 'O'
	oModel	:= FwLoadModel("RU09T02")
EndIf

oModelM := oModel:GetModel("F35MASTER")
oModelF := oModel:GetModel("SF2DETAIL")
dPdate	:= oModelM:GetValue("F35_PDATE")
dFirst	:= oModelM:GetValue("F35_PDATE")
dLast	:= oModelM:GetValue("F35_PDATE")
dCurrent	:= oModelM:GetValue("F35_PDATE")
lRet  := .F.

for nI := 1 to oModelF:Length()
	oModelF:GoLine(nI)
	if !(oModelF:IsDeleted())
		dFirst := min(dFirst, oModelF:GetValue("F2_EMISSAO"))
		dLast := max(dLast, oModelF:GetValue("F2_EMISSAO"))	
	EndIf
next nI

aAreaTMPTAB := (cTempTbl)->(GetArea())

(cTempTbl)->(DbGotop())
While !(cTempTbl)->(Eof())
	// if line is marked by user
	If ((cTempTbl)->F2_OK == cMark)
		dCurrent := (cTempTbl)->F2_EMISSAO
		dFirst := min(dFirst, dCurrent)
		dLast := max(dLast, dCurrent)	
	EndIf
	(cTempTbl)->(DbSkip())
EndDo

If (dLast - dFirst) > 4
	Help("",1,STR0051,,STR0048 + DTOC(dFirst) + " - "+ DTOC(dLast) + STR0049,1,0)
	lRet := .F.
ElseIf (FwIsInCallStack("RU09T02Run"))
	lRet := .T.
Else 
	Help("",1,STR0053,,STR0050,1,0)
	lRet := .T.
EndIf
Return lRet



/*/{Protheus.doc} genTable
@author felipe.morais
@since 10/02/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function genTable()

	Local aFieldsSF2  as Array
	Local aFields     as Array
	Local aArea       as Array
	Local aAreaSX3    as Array
	Local cColumnList as Character
	Local cQuery      as Character
	Local cQueryStart as Character
	Local cPerg       as Character
	Local cFromSer    as Character
	Local cToSer      as Character
	Local cFromDoc    as Character
	Local cToDoc      as Character
	Local cFromCus    as Character
	Local cFromBra    as Character
	Local cToCus      as Character
	Local cToBra      as Character
	Local dFromDt     as Date
	Local dToDt       as Date
	Local lRet        as Logical
	Local nStatus     as Numeric

	lRet := .T.
	aArea := GetArea()
	aAreaSX3 := SX3->(GetArea())
	cPerg := "RU09T0201"

	oTable := FwTemporaryTable():New(cTable) // cTable is private
	aFields := {}

	aFieldsSF2 := {"F2_FILIAL", "F2_SERIE", "F2_DOC", "F2_CLIENTE", "F2_LOJA", "A1_NOME",;
	"F2_EMISSAO", "F2_MOEDA", "F2_CONUNI", "F2_BASIMP1", "F2_VALIMP1"}
	
	aAdd(aFields, {"F2_OK", "C", 1, 00})
	RU09T02003_AppendFields(aFields, aFieldsSF2)

	oTable:SetFields(aFields)
	oTable:AddIndex("Indice1", {"F2_FILIAL", "F2_CLIENTE", "F2_LOJA", "F2_SERIE", "F2_DOC", "F2_EMISSAO"})
	oTable:AddIndex("Indice2", {"F2_FILIAL", "F2_EMISSAO", "F2_CLIENTE", "F2_LOJA", "F2_SERIE", "F2_DOC"})

	oTable:Create()

	If (Pergunte(cPerg, .T.))
		cFromSer := AllTrim(mv_par01)
		cToSer   := AllTrim(mv_par02)
		cFromDoc := AllTrim(mv_par03)
		cToDoc   := AllTrim(mv_par04)
		cFromCus := AllTrim(mv_par05)
		cFromBra := AllTrim(mv_par06)
		cToCus   := AllTrim(mv_par07)
		cToBra   := AllTrim(mv_par08)
		dFromDt  := mv_par09
		dToDt    := mv_par10
	
		cColumnList := RU09T02004_JoinFields(aFields, ", ")
		cQueryStart := " INSERT INTO " + oTable:GetRealName()
		cQueryStart += " ( " + cColumnList + " ) "	
		cQuery := " SELECT '0' F2_OK,"
		cQuery += " T0.F2_FILIAL,"
		cQuery += " T0.F2_SERIE,"
		cQuery += " T0.F2_DOC,"
		cQuery += " T0.F2_CLIENTE,"
		cQuery += " T0.F2_LOJA,"
		cQuery += " T1.A1_NOME,"
		cQuery += " T0.F2_EMISSAO,"
		cQuery += " T0.F2_MOEDA,"
		cQuery += " T0.F2_CONUNI,"
		cQuery += " T0.F2_BASIMP1,"
		cQuery += " T0.F2_VALIMP1"
		cQuery += " FROM " + RetSQLName("SF2") + " T0"
		cQuery += " INNER JOIN " + RetSQLName("SA1") + " T1"
		cQuery += " ON ("
		cQuery += " T1.A1_FILIAL = '" + xFilial("SA1") + "'"
		cQuery += " AND T1.A1_COD = T0.F2_CLIENTE"
		cQuery += " AND T1.A1_LOJA = T0.F2_LOJA"
		cQuery += " AND T1.D_E_L_E_T_ = ' '"
		cQuery += ")"
		cQuery += " WHERE T0.F2_FILIAL = '" + xFilial("SF2") + "'"
		cQuery += " AND T0.F2_SERIE BETWEEN '" + cFromSer + "'"
		cQuery += " AND '" + cToSer + "'"
		cQuery += " AND T0.F2_DOC BETWEEN '" + cFromDoc + "'"
		cQuery += " AND '" + cToDoc + "'"
		cQuery += " AND T0.F2_CLIENTE BETWEEN '" + cFromCus + "'"
		cQuery += " AND '" + cToCus + "'"
		cQuery += " AND T0.F2_LOJA BETWEEN '" + cFromBra + "'"
		cQuery += " AND '" + cToBra + "'"
		cQuery += " AND T0.F2_EMISSAO BETWEEN '" + DToS(dFromDt) + "'"
		cQuery += " AND '" + DToS(dToDt) + "'"
		cQuery += " AND T0.F2_TIPO = 'N'"
		cQuery += " AND T0.F2_TIPODOC = '01'"
		cQuery += " AND T0.F2_STATUSR <> '2'"
		cQuery += " AND T0.D_E_L_E_T_ = ' '"

		cQuery := cQueryStart + ChangeQuery(cQuery)
		nStatus := TcSQLExec(cQuery)
		
		DbSelectArea(cTable)
		(cTable)->(DbGoTop())
	Else
		// If user closes the questions window, nothing happens.
		lRet := .F.
	EndIf

	RestArea(aAreaSX3)
	RestArea(aArea)

Return(lRet)



/*/{Protheus.doc} AddMenuDef
@author felipe.morais
@since 10/02/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function AddMenuDef()
Local aRet as Array

aRet := {{STR0007, "RU09T02Ok()", 0, 3, 0, Nil},;
		{STR0006,"RU09t02Vi()",0,3,0,Nil}}
Return(aRet)



Function RU09T02Can()
Local lRet as Logical

lRet := .T.

oDlg:End()
Return(lRet)



/*/{Protheus.doc} RU09T02Ok
@author felipe.morais
@since 10/02/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function RU09T02Ok()
Local lRet as Logical
Local aArea as Array
Local aAreaSF2 as Array
Local aAreaSD2 as Array
Local aAreaF31 as Array
Local cPerg as Character
Local lMany as Logical
Local cCustomer as Character
Local cBranch as Character
Local dEmissao as Date
Local oModel as Object
Local oModelF35 as Object
Local oModelF36 as Object
Local lFirst as Logical
Local nItem as Numeric
Local nVatVl as Numeric
Local nValGr as Numeric
Local nVatBs as Numeric
Local nVatBs1 as Numeric
Local nVatVl1 as Numeric
Local cAutoSB	as Character
Local nMoeda as Numeric
Local cConUni as Character
Local cFunkName as Character
Private cCliente as Character
Private cLoja as Character

cFunkName := ProcName()
lRet := .T.
aArea := GetArea()
aAreaSF2 := SF2->(GetArea())
aAreaSD2 := SD2->(GetArea())
aAreaF31 := F31->(GetArea())
cPerg := "RU09T02"
Pergunte(cPerg, .F.)
lMany := Iif(mv_par05 == 1, .F., .T.)
cAutoSB := AllTrim(mv_par06)
cCustomer := ""
cBranch := ""

DbSelectArea((cTable))
(cTable)->(DbSetOrder(2))
(cTable)->(DbGoTop())

If((cTable)->(Eof()))
	lRet := .F.
	Help("",1,cFunkName+":05",,STR0065,1,0)		
Else

	While ((cTable)->(!Eof()))
		If ((cTable)->F2_OK == oBrwSel:Mark())
			If (((lMany) .And. ((cCustomer <> (cTable)->F2_CLIENTE) .Or. (cBranch <> (cTable)->F2_LOJA) .Or. (nMoeda <> (cTable)->F2_MOEDA) .Or. (cConUni <> (cTable)->F2_CONUNI) .Or. ((dEmissao < (cTable)	->F2_EMISSAO - 4) .Or. (dEmissao > (cTable)->F2_EMISSAO + 4)))) .Or. !(lMany))
				If (ValType(oModel) == "O")
					lRet := lRet .and. oModelF35:LoadValue("F35_VATVL", nVatVl)
					lRet := lRet .and. oModelF35:LoadValue("F35_VALGR", nValGr)
					lRet := lRet .and. oModelF35:LoadValue("F35_VATBS", nVatBs)
					lRet := lRet .and. oModelF35:LoadValue("F35_VATBS1", nVatBs1)
					lRet := lRet .and. oModelF35:LoadValue("F35_VATVL1", nVatVl1)
				
					// If the validation of the model is not successful.
					If lRet .and. !oModel:VldData()
						lRet := .F.
						Help("",1,"RU09T02Ok:01",,STR0941,1,0)
						// If commit not is successful.
					ElseIf lRet .and. !oModel:CommitData()
						lRet := .F.
						Help("",1,"RU09T02Ok:02",,STR0942,1,0)
					EndIf
					oModel:DeActivate()
				EndIf
			
				cCustomer := (cTable)->F2_CLIENTE
				cBranch := (cTable)->F2_LOJA
				cCliente := (cTable)->F2_CLIENTE
				cLoja := (cTable)->F2_LOJA
				dEmissao := (cTable)->F2_EMISSAO
				nMoeda := (cTable)->F2_MOEDA
				cConUni := (cTable)->F2_CONUNI
				lFirst := .T.
				nItem := 1
				nVatVl  := 0
				nValGr  := 0
				nVatBs  := 0
				nVatBs1 := 0
				nVatVl1 := 0
				oModel := FwLoadModel("RU09T02")
				oModel:SetOperation(MODEL_OPERATION_INSERT)
				oModel:Activate()
			
				oModelF35 := oModel:GetModel("F35MASTER")
				oModelF36 := oModel:GetModel("F36DETAIL")
			EndIf
		
			DbSelectArea("SF2")
			SF2->(DbSetOrder(1))
			If (SF2->(DbSeek(xFilial("SF2") + (cTable)->F2_DOC + (cTable)->F2_SERIE + (cTable)->F2_CLIENTE + (cTable)->F2_LOJA)))
				nVatVl  += Iif(AllTrim(SF2->F2_CONUNI) == "1", SF2->F2_VLIMP1M, SF2->F2_VALIMP1)
				nValGr  += Iif(AllTrim(SF2->F2_CONUNI) == "1", SF2->F2_VLBRUTM, SF2->F2_VALBRUT)
				nVatBs  += Iif(AllTrim(SF2->F2_CONUNI) == "1", SF2->F2_BSIMP1M, SF2->F2_BASIMP1)
				nVatBs1 += SF2->F2_BSIMP1M
				nVatVl1 += SF2->F2_VLIMP1M
	
				If (lFirst)
					lFirst := .F.
				
					lRet := lRet .and. oModelF35:LoadValue("F35_ORIGIN", "1")	// Purchases Commercial Invoice
					lRet := lRet .and. oModelF35:LoadValue("F35_TYPE", "1")	// Purchases VAT Invoice
					lRet := lRet .and. oModelF35:LoadValue("F35_IDATE", dDataBase)	// Issue date
					lRet := lRet .and. oModelF35:LoadValue("F35_INVDT", SF2->F2_DTSAIDA)	// Commercial Invoice Issue Date
					lRet := lRet .and. oModelF35:LoadValue("F35_INVDOC", SF2->F2_DOC)	// Commercial Invoice Number
					lRet := lRet .and. oModelF35:LoadValue("F35_INVSER", SF2->F2_SERIE)	// Commercial Invoice Series
					lRet := lRet .and. oModelF35:LoadValue("F35_CLIENT", SF2->F2_CLIENTE)	// Client
					lRet := lRet .and. oModelF35:LoadValue("F35_BRANCH", SF2->F2_LOJA)	// Client Branch
					lRet := lRet .and. oModelF35:LoadValue("F35_PDATE",;	// Print Date
						Iif(((dDataBase >= SF2->F2_DTSAIDA) .And. (dDataBase < SF2->F2_DTSAIDA + 5)), dDataBase, SF2->F2_DTSAIDA))
					lRet := lRet .and. oModelF35:LoadValue("F35_ITDATE", SF2->F2_EMISSAO)	// Invoice Typed Date
					lRet := lRet .and. oModelF35:LoadValue("F35_TDATE", Date())	// Input Date
					lRet := lRet .and. oModelF35:LoadValue("F35_INVCUR",Iif(SF2->F2_CONUNI == "1", "01", StrZero(SF2->F2_MOEDA,TamSX3("F35_INVCUR")[1])))
					lRet := lRet .and. oModelF35:LoadValue("F35_C_RATE", SF2->F2_TXMOEDA) // Currency Rate
					lRet := lRet .and. oModelF35:LoadValue("F35_ICUDES", Posicione("CTO",1,xFilial("CTO")+PadL(FwFldGet("F35_INVCUR"),TamSX3("CTO_MOEDA")[1],'0'),"CTO_SIMB")) //Description
					lRet := lRet .and. oModelF35:LoadValue("F35_CONUNI", SF2->F2_CONUNI)
					lRet := lRet .and. oModelF35:LoadValue("F35_MOEDA", SF2->F2_MOEDA)
					lRet := lRet .and. oModelF35:LoadValue("F35_MOEDES", Posicione("CTO",1,xFilial("CTO")+StrZero(FwFldGet("F35_MOEDA"),TamSX3("CTO_MOEDA")[1]),"CTO_SIMB"))
					lRet := lRet .and. oModelF35:LoadValue("F35_ATBOOK", cAutoSB)
					lRet := lRet .and. oModelF35:LoadValue("F35_CNEE_C", SF2->F2_CNEECOD)	// Consignee Code
					lRet := lRet .and. oModelF35:LoadValue("F35_CNEE_B", SF2->F2_CNEEBR )	// Consignee Branch
					lRet := lRet .and. oModelF35:LoadValue("F35_CNOR_C", SF2->F2_CNORCOD)	// Consignor Code
					lRet := lRet .and. oModelF35:LoadValue("F35_CNOR_B", SF2->F2_CNORBR )	// Consignor Branch
					lRet := lRet .and. oModelF35:LoadValue("F35_CNECLI", SF2->F2_CNEECLI )	// Consignee
					lRet := lRet .and. oModelF35:LoadValue("F35_CNRVEN", SF2->F2_CNORVEN )	// Consignor
					lRet := lRet .and. oModelF35:LoadValue("F35_CNRDES", Posicione('SA2',1,xFilial('SA2')+SF2->(F2_CNORCOD+F2_CNORBR),'A2_NREDUZ') )	// Consignor
					lRet := lRet .and. oModelF35:LoadValue("F35_CNEDES", Posicione('SA1',1,xFilial('SA1')+SF2->(F2_CNEECOD+F2_CNEEBR),'A1_NREDUZ') )	// Consignee
					lRet := lRet .and. oModelF35:LoadValue("F35_F5QUID", SF2->F2_F5QUID )
					lRet := lRet .and. oModelF35:LoadValue("F35_CONTRA", SF2->F2_CNTID )
					lRet := lRet .and. oModelF35:LoadValue("F35_F5QDES", Iif(!EMPTY(FwFldGet('F35_F5QUID')),Posicione('F5Q',1,XFILIAL('F5Q')+FwFldGet('F35_F5QUID'),'F5Q_DESCR'),'') )
					lRet := lRet .and. oModelF35:LoadValue("F35_KPP_CL",;	// Client KPP
						Posicione("SA1", 1, xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA, "A1_INSCGAN"))
					lRet := lRet .and. oModelF35:LoadValue("F35_KPP_CO", GetCoBrRUS()[2][5][2])	// Branch KPP!!!
					lRet := lRet .and. oModelF35:LoadValue("F35_GOVCTR", Iif(!EMPTY(FwFldGet('F35_F5QUID')),Posicione('F5R',3,XFILIAL('F5R')+FwFldGet('F35_F5QUID'),'F5R_GOVID'),''))	// Identifier of government contract
				EndIf
					
				cTab := getTempTable(SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA, SF2->F2_EMISSAO)
				lRet := lRet .and. FillF36Table(oModelF36, cTab)
				CloseTempTable(cTab)
			EndIf
		EndIf
	
		(cTable)->(DbSkip())
	EndDo

	If (ValType(oModel) == "O")
		lRet := lRet .and. oModelF35:LoadValue("F35_VATVL", nVatVl)
		lRet := lRet .and. oModelF35:LoadValue("F35_VALGR", nValGr)
		lRet := lRet .and. oModelF35:LoadValue("F35_VATBS", nVatBs)
		lRet := lRet .and. oModelF35:LoadValue("F35_VATBS1", nVatBs1)
		lRet := lRet .and. oModelF35:LoadValue("F35_VATVL1", nVatVl1)
				
		// If the validation of the model is not successful.
		If lRet .and. !oModel:VldData()
			lRet := .F.
			Help("",1,"RU09T02Ok:03",,STR0941,1,0)
		// If commit not is successful.
		ElseIf lRet .and. !oModel:CommitData()
			lRet := .F.
			Help("",1,"RU09T02Ok:04",,STR0942,1,0)
		EndIf
		oModel:DeActivate()
	
		oDlg:End()
		
	EndIf
	
EndIf
RestArea(aAreaF31)
RestArea(aAreaSD2)
RestArea(aAreaSF2)
RestArea(aArea)

Return(lRet)

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09T02LOC
check if there is at least one line in F36, that contains a product, having 'L' in b1_rastro
used for LOT control (see ViewDef)
@author natasha
@since 08/02/2018
@version P12.1.17
@type function
/*/
//-----------------------------------------------------------------------

Static Function RU09T02LOC()
Local cQuery as Character
Local cTab as Character

Local lHide as Logical

Local oModel as Object

Local cVATKey as Character
Local cICod as Character // string <'product1','product2',..,'productN> made from F36_ITMCOD field - when INSERT operation

Local nX as Numeric 

lHide := .F.
cQuery:= ''
cICod := ''

// When come to this function from INSERT operation - take data from Model
If (ValType(oModel) == "O") .and. (oModel:getId() == "RU09T02")
	oModelF36 := oModel:GetModel("F36DETAIL")
	For nX := 1 to oModelF36:Length()
			oModelF36:GoLine(nX)
			If !Empty(oModelF36:GetValue("F36_ITMCOD"))
				cICod += "'"+ oModelF36:GetValue("F36_ITMCOD") +"',"
			EndIf
	Next nX
	If !Empty(cICod)
		cICod := Left(cICod, Len(cICod)-1)
	EndIf

	cQuery := " SELECT COUNT(*) COUNT1 "
	cQuery += " FROM " + RetSQLName("SB1") + " SB1"
	cQuery += " WHERE SB1.B1_FILIAL = " +"'" + xFilial("SB1") +"' "
	If !Empty(cICod)
		cQuery += " AND SB1.B1_COD IN (" + cICod + ")"
	EndIf
	cQuery += " AND SB1.D_E_L_E_T_ =' ' "
	cQuery += " AND SB1.B1_RASTRO = 'L' " 

Else // When come to this function from EDIT/VIEW/DELETE operation - take data from table F36
	cVATKey := F35->F35_KEY
	cQuery := " SELECT COUNT(*) COUNT1 "
	cQuery += " FROM " + RetSQLName("F36") + " F36"
	cQuery += " INNER JOIN " + RetSQLName("SB1") + " SB1"
	cQuery += " ON ("
	cQuery += " SB1.B1_FILIAL = '" + xFilial("SB1")+"' "
	cQuery += " AND F36.F36_ITMCOD = SB1.B1_COD "
	cQuery += " AND SB1.D_E_L_E_T_ =' ' "
	cQuery += " AND SB1.B1_RASTRO = 'L')"
	cQuery += " WHERE F36.F36_FILIAL = " +"'" + xFilial("F36") +"' "
	If !Empty(cVATKey)
		cQuery += " AND F36.F36_KEY = " + "'" + cVATKey +"'"
	EndIf
	cQuery += " AND F36.D_E_L_E_T_ =' ' "
EndIf

cTab := MPSysOpenQuery(cQuery)

// If the quantity of lines having 'L' in b1_rastro equals zero.
If ((cTab)->COUNT1 == 0) 
	lHide := .T.
EndIf
CloseTempTable(cTab)
Return(lHide)



/*{Protheus.doc} FillF36Table()
@type       function
@author     Artem Kostin
@since      09/13/2018
@version    P12.1.21
@description    Function - fulfills the details table F36
*/
Function FillF36Table(oModelDetail as Object, cTab as Character)
Local lRet := .T.
// Variables to control lines
Local lAddLine := .T.
Local nLine := 1
// Concatenates Operational VAT Codes
Local cCFExt := AllTrim(FwFldGet("F35_VATCD2"))

lAddLine := !Empty(AllTrim(oModelDetail:GetValue("F36_INVDOC")+oModelDetail:GetValue("F36_INVSER")))
// Loading new data selected by query at the end of the grid.
DbSelectArea((cTab))
(cTab)->(DbGoTop())
While ((cTab)->(!Eof()))
	If lAddLine
        nLine := oModelDetail:AddLine()
    Else
        nLine := oModelDetail:Length()
        lAddLine := .T.
    EndIf
	
	// F36_FILIAL is used relation with F35
	// F36_KEY is used relation with F35
	lRet := lRet .and. oModelDetail:LoadValue("F36_DOCKEY", xFilial("SD2") + (cTab)->(D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_COD + D2_ITEM + D2_TIPO))
	// F36_DOC is used in relation with F35
	lRet := lRet .and. oModelDetail:LoadValue("F36_ITEM", StrZero(nLine, GetSX3Cache("F36_ITEM", "X3_TAMANHO")))
	lRet := lRet .and. oModelDetail:LoadValue("F36_ITMCOD", (cTab)->B1_COD) // Prod./Service Description
	lRet := lRet .and. oModelDetail:LoadValue("F36_ITMDES", SubStr((cTab)->B1_DESC, 1, GetSX3Cache("F36_ITMDES", "X3_TAMANHO")))
	// F36_CUSCOD is empty yet
	lRet := lRet .and. oModelDetail:LoadValue("F36_UM", (cTab)->D2_UM)
	lRet := lRet .and. oModelDetail:LoadValue("F36_QUANT", (cTab)->D2_QUANT)

	lRet := lRet .and. oModelDetail:LoadValue("F36_VUNIT", Round( Iif((cTab)->F2_CONUNI == "1", (cTab)->D2_BSIMP1M, (cTab)->D2_BASIMP1) / (cTab)->D2_QUANT, 2 )) // Unit Value
	lRet := lRet .and. oModelDetail:LoadValue("F36_VALUE", Iif((cTab)->F2_CONUNI == "1", (cTab)->D2_BSIMP1M, (cTab)->D2_BASIMP1))	// VAT Value
	lRet := lRet .and. oModelDetail:LoadValue("F36_VATBS", Iif((cTab)->F2_CONUNI == "1", (cTab)->D2_BSIMP1M, (cTab)->D2_BASIMP1))	// VAT Base
	lRet := lRet .and. oModelDetail:LoadValue("F36_VATVL", Iif((cTab)->F2_CONUNI == "1", (cTab)->D2_VLIMP1M, (cTab)->D2_VALIMP1))	// VAT Value
	lRet := lRet .and. oModelDetail:LoadValue("F36_VALGR", Iif((cTab)->F2_CONUNI == "1", (cTab)->D2_VLBRUTM, (cTab)->D2_VALBRUT))	// Gross Total

	lRet := lRet .and. oModelDetail:LoadValue("F36_VATCOD", (cTab)->D2_CF)
	lRet := lRet .and. oModelDetail:LoadValue("F36_VATCD2", (cTab)->F31_OPCODE)
	lRet := lRet .and. oModelDetail:LoadValue("F36_VATRT", (cTab)->D2_ALQIMP1)	// VAT Rate
	lRet := lRet .and. oModelDetail:LoadValue("F36_VATBS1", (cTab)->D2_BSIMP1M)
	lRet := lRet .and. oModelDetail:LoadValue("F36_VATVL1", (cTab)->D2_VLIMP1M)
	
	lRet := lRet .and. oModelDetail:LoadValue("F36_INVSER", (cTab)->F2_SERIE)
	lRet := lRet .and. oModelDetail:LoadValue("F36_INVDOC", (cTab)->F2_DOC)
	lRet := lRet .and. oModelDetail:LoadValue("F36_INVIT", (cTab)->D2_ITEM)
	lRet := lRet .and. oModelDetail:LoadValue("F36_INVDT", StoD((cTab)->F2_DTSAIDA))	// Commercial Invoice Series
	lRet := lRet .and. oModelDetail:LoadValue("F36_ITDATE", StoD((cTab)->F2_EMISSAO)) // Commercial Invoice Date
	lRet := lRet .and. oModelDetail:LoadValue("F36_ORIGIN", (cTab)->B8_ORIGEM)
	lRet := lRet .and. oModelDetail:LoadValue("F36_NUMDES", SubStr((cTab)->B8_NUMDESP, 1, GetSX3Cache("F36_NUMDES", "X3_TAMANHO")))
	// F36_DTLA should be fulfulled in Accounting Postings procedure
	SD2->(dbGoTo((cTab)->R_E_C_N_O_))
	lRet := lRet .and. oModelDetail:LoadValue("F36_DESC", Iif(!Empty(SD2->D2_FDESC), MSMM(SD2->D2_FDESC,TamSX3("F36_DESC")[1],1,SD2->D2_FDESC,3), oModelDetail:GetValue("F36_ITMDES")))

	If !Empty((cTab)->F31_OPCODE) .and. !((cTab)->F31_OPCODE $ cCFExt)
		If !Empty(cCFExt)
			cCFExt += ";"
		EndIf
		cCFExt += AllTrim((cTab)->F31_OPCODE)
	EndIf

	(cTab)->(DbSkip())
EndDo

lRet := lRet .and. FWFldPut("F35_VATCD2", cCFExt)
Return(lRet)


/*{Protheus.doc} getTempTable
@type       function
@author     Artem Kostin
@since      09/17/2018
@version    P12.1.21
@description    Function returns the alias of temporary table with all the data from selected invoices
*/
Static Function getTempTable(cDoc, cSeries, cClient, cBranch, dEmission)
Local cQuery := ""
Local cTab := ""

cQuery := " SELECT"
cQuery += " F2_SERIE, F2_DOC, F2_CLIENTE, F2_LOJA, F2_EMISSAO, F2_DTSAIDA,"
cQuery += " F2_MOEDA, F2_CONUNI,"
cQuery += " F2_VLIMP1M, F2_VALIMP1, F2_VLBRUTM, F2_VALBRUT, "
cQuery += " D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM, D2_TIPO,"
cQuery += " B1_COD, B1_DESC,"
cQuery += " B8_ORIGEM, B8_NUMDESP,"
cQuery += " D2_UM, D2_QUANT,"
cQuery += " D2_BSIMP1M, D2_BASIMP1, D2_BSIMP1M, D2_BASIMP1, D2_VLIMP1M, D2_VALIMP1, D2_VLBRUTM, D2_VALBRUT,"
cQuery += " D2_CF, D2_ALQIMP1,"
cQuery += " SD2.R_E_C_N_O_,"
cQuery += " F31_OPCODE"
cQuery += " FROM " + RetSQLName("SF2") + " AS SF2"
cQuery += " LEFT JOIN " + RetSQLName("SD2") + " AS SD2 ON ("
cQuery += " D2_FILIAL = '" + xFilial('SD2') + "'"
cQuery += " AND D2_EMISSAO = F2_EMISSAO"
CQUERY += " AND D2_DOC = F2_DOC"
CQUERY += " AND D2_SERIE = F2_SERIE"
CQUERY += " AND D2_CLIENTE = F2_CLIENTE"
CQUERY += " AND D2_LOJA = F2_LOJA"
CQUERY += " AND SD2.D_E_L_E_T_ = ' '"
cQuery += " )"
cQuery += " LEFT JOIN " + RetSQLName("SB1") + " AS SB1 ON ("
cQuery += " B1_FILIAL = '" + xFilial('SB1') + "'"
cQuery += " AND B1_COD = D2_COD"
CQUERY += " AND SB1.D_E_L_E_T_ = ' '"
cQuery += " )"
cQuery += " LEFT JOIN " + RetSQLName("SB8") + " AS SB8 ON ("
cQuery += " B8_FILIAL = '" + xFilial('SB8') + "'"
cQuery += " AND B8_NUMLOTE = D2_NUMLOTE"
CQUERY += " AND B8_LOTECTL = D2_LOTECTL"
CQUERY += " AND B8_PRODUTO = D2_COD"
CQUERY += " AND B8_LOCAL = D2_LOCAL"
CQUERY += " AND SB8.D_E_L_E_T_ = ' '"
cQuery += " )"
cQuery += " LEFT JOIN " + RetSQLName("F31") + " AS F31 ON ("
cQuery += " F31_FILIAL = '" + xFilial('F31') + "'"
cQuery += " AND F31_CODE = D2_CF"
cQuery += " AND F31.D_E_L_E_T_ = ' '"
cQuery += " )"
cQuery += " WHERE F2_FILIAL = '" + xFilial('SF2') + "'"
cQuery += " AND F2_EMISSAO = '" + DToS(dEmission) + "'"
cQuery += " AND F2_DOC = '" + cDoc + "'"
cQuery += " AND F2_SERIE = '" + cSeries + "'"
cQuery += " AND F2_CLIENTE = '" + cClient + "'"
cQuery += " AND F2_LOJA = '" + cBranch + "'"
cQuery += " AND SF2.D_E_L_E_T_ = ' '"
cQuery += " ORDER BY D2_ITEM"
cTab := MPSysOpenQuery(ChangeQuery(cQuery))

Return(cTab)


/*/{Protheus.doc} RU09T02Cp
@author artem.kostin
@since 12/19/2018
@version P12.1.21
@type function
/*/
Function RU09T02Cp()
Local lRet := .T.
Local oModel 	as Object
Local aAreaF35  as Array

aAreaF35	:= F35->(GetArea())
If (F35->F35_TYPE == "2")
	oModel := FWLoadModel("RU09T02")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate(.T.)

	oModel:GetModel("F35MASTER"):LoadValue("F35_TYPE", "2")
	oModel:GetModel("F35MASTER"):LoadValue("F35_CLIENT", F35->F35_CLIENT)
	oModel:GetModel("F35MASTER"):LoadValue("F35_BRANCH", F35->F35_BRANCH)
	oModel:GetModel("F35MASTER"):LoadValue("F35_DOC", "")
	oModel:GetModel("F35MASTER"):LoadValue("F35_TDATE ", dDataBase)
	oModel:GetModel("F35MASTER"):LoadValue("F35_DTLA", StoD(""))
	oModel:GetModel("F35MASTER"):LoadValue("F35_BOOK", "")

	FWExecView( STR0060, "RU09T02", MODEL_OPERATION_INSERT, /*oDlg*/, {|| .T. },  , /*nPercReducao*/, , /*bCancel*/ , /*cOperatId*/, /*cToolBar*/,oModel)
	oModel:DeActivate()
Else
	HELP(' ',1,"RU09T02Cp:01" ,,STR0062,2,0,,,,,,/* solution */)
EndIf

RestArea(aAreaF35)
Return(lRet)

/*/{Protheus.doc} RU09T02T01_F36_VALUE_F36_VATBS
@author artem.kostin
@since 01/30/2019
@version P12.1.23
@type function recalculates VAT Base after the value was changed
/*/
Function RU09T02T01_F36_VATBS()
Local aVATRate := RU09GetRate(FWFldGet("F36_VATCOD"))
Local nVATBase := Round(FWFldGet("F36_VALUE"), 2)
If (aVATRate[2] != 100)
	nVATBase = Round(FWFldGet("F36_VALUE") * 100 / aVATRate[2], 2)
EndIf
Return(nVATBase)

/*/{Protheus.doc} RU09T02002_F2_STATUSR
@author alexandra.velmozhnay
@since 17/05/2019
@version P12.1.25
@type function change status of invoice
/*/
Function RU09T02002_F2_STATUSR(oModel as Object, cStatus as Character, nOperation as Numeric)
Local oModelDet	as Object
Local oModelM	as Object
Local nI		as Numeric
Local cInvDoc	as Character
Local cInvSer	as Character
Local cCliente	as Character
Local cLoja		as Character

Default cStatus := ""

If ValType(oModel) <> "O"
	oModel := FwLoadModel("RU09T02")
    oModel:SetOperation(nOperation)
	lRet := .T.
EndIf

If !oModel:isActive()
    oModel:Activate()
EndIf
oModelM		:= oModel:GetModel("F35MASTER")
oModelDet	:= oModel:GetModel("F36DETAIL")
DbSelectArea("SF2")
SF2->(DbSetOrder(1))
For nI := 1 to oModelDet:Length()
	oModelDet:GoLine(nI)
	If !oModelDet:Isdeleted()
		cInvDoc := SubStr(oModelDet:GetValue("F36_INVDOC"), 1, TamSX3("F2_DOC")[1])
		cInvSer := SubStr(oModelDet:GetValue("F36_INVSER"), 1, TamSX3("F2_SERIE")[1])
		cCliente := SubStr(oModelM:GetValue("F35_CLIENT"), 1, TamSX3("F2_CLIENTE")[1])
		cLoja := SubStr(oModelM:GetValue("F35_BRANCH"), 1, TamSX3("F2_LOJA")[1])
		If (SF2->(DbSeek(xFilial("SF2") + cInvDoc + cInvSer + cCliente + cLoja)))
		// if we update this status previos item it is bypassing
			If(SF2->F2_STATUSR != "2")
				RecLock("SF2", .F.)
				SF2->F2_STATUSR := cStatus
				SF2->(MsUnlock())
			EndIf
		EndIf
	EndIf
Next nI
oModel:GetModel("SF2DETAIL"):Deactivate()

Return

Function RU09t02Vi()
Local lRet as Logical
Local aArea as Array
Local aAreaSF2 as Array
Local aAreaSD2 as Array
Local cKeySF2 as Character	
Local cFunkName as Character

	cFunkName := ProcName()
	lRet := .T.
	aArea := GetArea()
	aAreaSF2 := SF2->(GetArea())
	aAreaSD2 := SD2->(GetArea())	
	DbSelectArea("SF2")
	SF2->(DbSetOrder(1))
	cKeySF2 := xFilial('SF2') + (cTable)->F2_DOC+ (cTable)->F2_SERIE+ (cTable)->F2_CLIENTE + (cTable)->F2_LOJA
	If (SF2->(DbSeek(cKeySF2)))
		CtbDocSaida()	// open View SF2/SD2
	Else
		Help("",1,cFunkName+":01",,STR0015,1,0)	
		lRet := .F.
	EndIf
	RestArea(aAreaSD2)
	RestArea(aAreaSF2)
	RestArea(aArea)
Return lRet

/*{Protheus.doc} RU09T02005_OpenFields
@description Opens fields for manual editing
@author alexander.ivanov
@since 03/03/2020
@version 1.0
@project MA3 - Russia
*/
Function RU09T02005_OpenFields(oView)
	Local aFieldsF35 as Array
	Local aFieldsF36 as Array
	Local oStrF35    as Object
	Local oStrF36    as Object
	
	oStrF35 := oView:GetViewStruct("F35_M")
	aFieldsF35 := {"F35_CLIENT", "F35_BRANCH", "F35_ITDATE", "F35_CNRVEN",;
	"F35_CNECLI", "F35_CNEE_C", "F35_CNEE_B", "F35_CNOR_C", "F35_CNOR_B", "F35_INVDT"}
	AllowEdit(oStrF35, aFieldsF35)
	
	oStrF36 := oView:GetViewStruct("F36_D")
	aFieldsF36 := {"F36_ITMCOD", "F36_QUANT", "F36_VUNIT", "F36_VALUE", "F36_VATVL",;
	"F36_VATBS1", "F36_VATVL1"}
	AllowEdit(oStrF36, aFieldsF36)
Return .T.

/*{Protheus.doc} AllowEdit
@description Allows or disallows to edit array of fields
@author alexander.ivanov
@since 05/03/2020
@version 1.0
@project MA3 - Russia
*/
Static Function AllowEdit(oStruct as Object, aFields as Array, lAllow as Logical)
	Local nI as Numeric
	Default lAllow := .T.
	For nI:=1 To Len(aFields) 
		oStruct:SetProperty(aFields[nI], MVC_VIEW_CANCHANGE, lAllow)
	Next nI
Return
