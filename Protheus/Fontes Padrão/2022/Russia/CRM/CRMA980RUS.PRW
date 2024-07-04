#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMA980.CH" 

/*{Protheus.doc} BrowseDef
@author Alexander Salov
@since 20/12/2017
@version 1.0
@return oBrowse, return oBrowse
@type function
@description CRMA 980 BrowseDef locolized for RUS
*/
Function CRMA980RUS (aSA1Auto,nOpcAuto,aAI0Auto)
Local oMBrowse as OBJECT
Private aRotina as ARRAY

/*
//AS: settings not used in Russia
Private lCGCValido 	:= .F. // Variavel usada na validacao do CNPJ/CPF (utilizando o Mashup) 
Private l030Auto   	:= .F. // Variavel usada para saber se � rotina autom�tica
*/

Default aSA1Auto 	:= {} 
Default nOpcAuto	:= MODEL_OPERATION_INSERT
Default aAI0Auto	:= {}
	
oMBrowse	:= Nil
aRotina		:= MenuDef()

If (Len( aSA1Auto  ) == 0)
	oMBrowse := BrowseDef()
	oMBrowse:Activate()
Else
	If (oModel == Nil)
		oModel := FWLoadModel("CRMA980")
	EndIf
	
	l030Auto := .T.

	FwMvcRotAuto(oModel,"SA1",nOpcAuto,{{"SA1MASTER",aSA1Auto },{"AI0CHILD",aAI0Auto}},/*lSeek*/,.T.) 

	oModel:DeActivate() 
EndIf

Return


/*{Protheus.doc} BrowseDef
@author Alexander Salov
@since 20/12/2017
@version 1.0
@return oBrowse, return oBrowse
@type function
@description CRMA 980 BrowseDef locolized for RUS
*/
Static Function BrowseDef()

Local oBrowse as OBJECT

oBrowse := FwLoadBrw("CRMA980")



Return oBrowse


/*{Protheus.doc} MenuDef
@author Alexander Salov
@since 20/12/2017
@version 1.0
@return aRotina, return aRotina
@type function
@description CRMA 980 MenuDef locolized for RUS
*/
Static Function MenuDef()
Local aRotina as ARRAY

aRotina := FWLoadMenuDef("CRMA980")	

aAdd(aRotina,{STR0049, "CRMA680RUS('SA1',xFilial('SA1')+ SA1->A1_COD + SA1->A1_LOJA,.F.,"+"('"+STR0049 +"' + ' ' + SA1->A1_NREDUZ))", 0, 2})      //Address editing
aAdd(aRotina,{STR0050, "CALLR06D03()", 0, 7})																									//Client Bank accounts editing

Return aRotina


/*{Protheus.doc} ViewDef
@author Alexander Salov
@since 20/12/2017
@version 1.0
@return oView, return view
@type function
@description CRMA 980 ViewDef locolized for RUS
*/
Static Function ViewDef()
	Local oView		:= Nil
	Local oModel		:= FWLoadModel("CRMA980") 	 
	Local oStructSA1	:= FWFormStruct(2,"SA1",/*bAvalCampo*/,/*lViewUsado*/)
	Local oStructAI0	:= FWFormStruct(2,"AI0",/*bAvalCampo*/,/*lViewUsado*/)
	Local lCRMTerr 	:= SuperGetMV("MV_CRMTERR",.F.,.F.)
	

	// Remove duplicates from forign key fields of suplementary table
	oStructAI0:RemoveField("AI0_CODCLI")
	oStructAI0:RemoveField("AI0_LOJA")
	
	oView:= FWFormView():New()
	oView:SetContinuousForm()
	oView:SetModel(oModel)
	
	oView:CreateHorizontalBox("BOXFORMALL",100)
	oView:CreateFolder("FOLDER","BOXFORMALL")
	oView:AddSheet("FOLDER","SHEETSA1",STR0051)
	oView:AddSheet("FOLDER","SHEETAI0",STR0052)
	
	oView:CreateHorizontalBox("BOXFORMSA1",100,/*cIdOwner*/,/*lFixPixel*/,"FOLDER","SHEETSA1")
	oView:CreateHorizontalBox("BOXFORMAI0",100,/*cIdOwner*/,/*lFixPixel*/,"FOLDER","SHEETAI0")
	
	oView:AddField("VIEW_SA1",oStructSA1,"SA1MASTER")
	oView:SetOwnerView("VIEW_SA1","BOXFORMSA1")
	
	oView:AddField("VIEW_AI0",oStructAI0,"AI0CHILD")
	oView:SetOwnerView("VIEW_AI0","BOXFORMAI0")
	
	oView:AddUserButton(STR0003,"",{|| a450F4Con()},,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE} ) //"Posi��o do Cliente"
	oView:AddUserButton(STR0004,"",{|| FGeoWizard("SA1",FwFldGet("A1_COD")+FwFldGet("A1_LOJA"),{"M->A1_END","M->A1_MUN","M->A1_EST","M->A1_CEP","M->A1_BAIRRO"},{|lContinua| CodGeoRev({},NIL,@lContinua)[6] <> FwFldGet("A1_CEP") })},,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE} ) //"Geoprocessamento"
	oView:AddUserButton(STR0005,"",{|| FConsWizard({FwFldGet("A1_NOME"), FwFldGet("A1_PESSOA"), FwFldGet("A1_NREDUZ"), FwFldGet("A1_END"), FwFldGet("A1_CEP"), FwFldGet("A1_DDD"), FwFldGet("A1_TEL"), FwFldGet("A1_CGC"), FwFldGet("A1_RG"), FwFldGet("A1_DTNASC") })},,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE} ) //"Consulta Cr�dito - Ecossistema"
	oView:AddUserButton(STR0049,'AddrButton', {|| CRMA680RUS("SA1",xFilial("SA1")+ SA1->A1_COD + SA1->A1_LOJA,.F.,STR0049+ " " + SA1->A1_NREDUZ)}, /*[cToolTip]*/, K_CTRL_A) // Other Actions - address button in viewdef
	oView:AddUserButton(STR0053,'CAButton', {|| CALLR06D03()}, /*[cToolTip]*/) // Other Actions - address button in viewdef
	
	
	If ( nModulo == 13 .Or. nModulo == 73 )
		
		oView:AddUserButton(STR0006,"",{|| TkLstScr( oModel:GetOperation(),"SA1", FwFldGet("A1_COD"), FwFldGet("A1_LOJA") ) },,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE} ) //"Scripts de Campanha"
		
		If nModulo == 73	
			oView:AddUserButton(STR0007,"",{ |oView| SaveInter(), CRMA620(@aAOVMark,"SA1",FwFldGet("A1_COD"),FwFldGet("A1_LOJA"),FwFldGet("A1_CODSEG"),oModel:GetOperation()),RestInter() },,,{ MODEL_OPERATION_VIEW, MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE } ) //"Subsegmentos"
			If lCRMTerr
				oView:AddUserButton(STR0008,"",{|| CRMA690EvalTerritory("MATA030","SA1",.T.,.T.) },,,,{MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE} ) //"Simular Territ�rio"
			EndIf	
		EndIf
		
	EndIf
	
	oView := CRMXAddAct("SA1",oView) 


Return oView


Static Function ModelDef()
	Local oModel    	:= Nil
	Local oStructSA1	:= FWFormStruct(1,"SA1",/*bAvalCampo*/,/*lViewUsado*/)
	Local oStructAI0	:= FWFormStruct(1,"AI0",/*bAvalCampo*/,/*lViewUsado*/)
	Local aMemoSA1	:= {}
	Local aMemoUser	:= {}
	Local oEvtDEF 		:= CRM980EventDEF():New()
	Local oEvtDEFCRM 	:= CRM980EventDEFCRM():New()
	Local oEvtDEFFAT 	:= CRM980EventDEFFAT():New()
	Local oEvtDEFFIN 	:= CRM980EventDEFFIN():New()
	Local oEvtDEFFIS 	:= CRM980EventDEFFIS():New()
	Local oEvtDEFJUR 	:= CRM980EventDEFJUR():New()
	Local oEvtDEFLOJ 	:= CRM980EventDEFLOJ():New()
	Local oEvtDEFGFE 	:= CRM980EventDEFGFE():New()
	Local oEvtDEFTMS 	:= CRM980EventDEFTMS():New()
	
	//-----------------------------------------------------------------------
	// Tratamento para campos do tipo Memo com o conteudo na SYP.
	// Obs: N�o adiciona campos Memos para o PDV pois o cadastro � reduzido. 
	//-----------------------------------------------------------------------
	If nModulo <> 23
		aAdd(aMemoSA1,{"A1_CODMARC","A1_VM_MARC"})
		aAdd(aMemoSA1,{"A1_OBS","A1_VM_OBS"})
	EndIf
	
	//--------------------------------------------------------------------
	// Ponto de entrada para adi��o de campos memos do usu�rio.
	//--------------------------------------------------------------------
	If ExistBlock("CRM980MMEM") 
		aMemoUser := ExecBlock( "CRM980MMEM", .F., .F. ) 
		If ValType( aMemoUser ) == "A"
			AEval( aMemoUser, { |x| aAdd( aMemoSA1, x ) } ) 	
		EndIf 	
	EndIf
	
	//-------------------------------------------
	// Considera os campos Memos SYP no MVC.
	//-------------------------------------------
	FWMemoVirtual(oStructSA1,aMemoSA1)
	
	oModel := MPFormModel():New("CRMA980",/*bPreValid*/,/*bPosValid*/,/*bCommit*/,/*bCancel*/)
	oModel:AddFields("SA1MASTER",/*cOwner*/,oStructSA1,/*bPreValid*/,/*bPosValid*/,/*bCarga*/)
	oModel:AddFields("AI0CHILD","SA1MASTER",oStructAI0,/*bPreValid*/,/*bPosValid*/,/*bCarga*/)
	oModel:SetRelation("AI0CHILD",{{"AI0_FILIAL", "xFilial('AI0')"},{"AI0_CODCLI","A1_COD"},{"AI0_LOJA","A1_LOJA"}},AI0->( IndexKey( 1 ) )) 
	
	oModel:SetDescription(STR0001)//"Clientes"
	
	//-------------------------------------------
	// Instala��o do evento padr�o por modulos.
	//-------------------------------------------
	oModel:InstallEvent("LOCDEF"	,/*cOwner*/,oEvtDEF)
	oModel:InstallEvent("LOCDEFCRM"	,/*cOwner*/,oEvtDEFCRM)
	oModel:InstallEvent("LOCDEFFAT"	,/*cOwner*/,oEvtDEFFAT)
	oModel:InstallEvent("LOCDEFFIN"	,/*cOwner*/,oEvtDEFFIN)
	oModel:InstallEvent("LOCDEFFIS"	,/*cOwner*/,oEvtDEFFIS)
	oModel:InstallEvent("LOCDEFLOJ"	,/*cOwner*/,oEvtDEFLOJ)
	oModel:InstallEvent("LOCDEFJUR"	,/*cOwner*/,oEvtDEFJUR)
	oModel:InstallEvent("LOCDEFRH"	,/*cOwner*/,oEvtDEFGFE)
	oModel:InstallEvent("LOCDEFTMS"	,/*cOwner*/,oEvtDEFTMS)

Return oModel

/*{Protheus.doc} MenuDef
@author Alexander Salov
@since 20/12/2017
@version 1.0
@return aRotina, return aRotina
@type function
@description CRMA 980 MenuDef locolized for RUS
*/
Function CALLR06D03()
Local oModelBank as object

aAreaF4N    := F4N->(GetArea())
F4N->(dbSetOrder(1)) 

FWExecView(STR0001, "RU06D03", MODEL_OPERATION_UPDATE, /* [ oDlg ] */, { || .T. } /* [ bCloseOnOK ] */, /* [ bOk ] */, /* [ nPercReducao ] */, /* [ aEnableButtons ] */, Nil, Nil, Nil/*oModelBank *//* [ oModel ] */)	//"Insert bank account"

Return nil


Function RusVldSA1()

If M->A1_TIPO <> "1"
	 M->AI0_PASSP := ""
Elseif M->A1_TIPO <> "2"
	 M->A1_INSCGAN := ""
EndIf

Return .T.


Function A010HeadQ()
Local aArea := SA1->(GetArea())
Local oModel as Object

oModel := FwModelActive()
oModel:GetModel("SA1MASTER"):GetStruct():SetProperty("A1_CODZON", MODEL_FIELD_WHEN, {|| .T.})

FwFldPut("A1_CODZON", Posicione("SA1", 1, xFilial("SA1")+M->AI0_HEAD + M->AI0_HEADUN, "A1_CODZON"))

oModel:GetModel("SA1MASTER"):GetStruct():SetProperty("A1_CODZON", MODEL_FIELD_WHEN, {|| AllTrim(FwFldGet("A1_TIPO")) != "3"})

RestArea(aArea)

Return .T.


// Russia_R5
