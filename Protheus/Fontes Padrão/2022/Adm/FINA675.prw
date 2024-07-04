#INCLUDE "FINA675.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA675
Rotina para transferencia de filial de pessoas/participantes  
não relacionadas a tabela SRA/RDZ

@author Totvs
@since 19-09-2013
@version P11 R9
/*/
//--------------------------------------------------------------------
Function FINA675()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('RD0')
oBrowse:SetDescription( STR0009 ) //"Transferência de Pessoas/Participantes"  
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0010	ACTION 'VIEWDEF.FINA675' OPERATION 2 ACCESS 0	//Visualizar
ADD OPTION aRotina TITLE STR0011	ACTION 'If(Fina675VlR(),FINA675Tra(),Nil)'		OPERATION 20 ACCESS 0 //Transferir

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruRD0		:= FWFormStruct(1,'RD0')
Local oModel		:= MPFormModel():New('FINA675')

oModel:AddFields('RD0MASTER',,oStruRD0)
oModel:SetDescription(STR0012)	//'Modelo Cadastro de Pessoas/Participantes'
oModel:GetModel('RD0MASTER'):SetDescription(STR0013)	//Pessoas/Participantes

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel	:= FWLoadModel('FINA675')
Local oStruRD0	:= FWFormStruct(2,'RD0')
Local oView

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_RD0',oStruRD0,'RD0MASTER')
oView:CreateHorizontalBox( 'TELA' , 100 )
oView:SetOwnerView( 'VIEW_RD0', 'TELA' )

Return oView

//----------------------------------------------------------------------
// Valida se a pessoa/participante pode ser transferido por esta rotina
//----------------------------------------------------------------------
Function Fina675VlR()
Local lRet			:= .T.
Local aAreaRD0		:= RD0->(GetArea())
Local aAreaRDZ		:= RDZ->(GetArea())

DbSelectArea("RDZ")
DbSetOrder(2) //RDZ_FILIAL+RDZ_CODRD0+RDZ_EMPENT+RDZ_FILENT+RDZ_ENTIDA
If DbSeek(XFilial("RDZ")+RD0->RD0_CODIGO)
	If RDZ->RDZ_ENTIDA == "SRA" 
		lRet := .F.
		Help(" ",1,"Fina675VlR",,STR0001,1,0)		 //"Pessoa/Participante relacionado com a folha. Utilize a rotina de transferência do Ambiente Gestão de Pessoal."
	EndIf
EndIf

RestArea(aAreaRDZ)
RestArea(aAreaRD0)

Return lRet

//---------------------------------------
// Tela para o processo de transferencia
//---------------------------------------
Function FINA675Tra()
Local aCoors		:= FWGetDialogSize( oMainWnd )
Local oGet1		:= Nil
Local oGet2		:= Nil
Local oGet3		:= Nil
Local oGet4		:= Nil

Local cAntEmp		:= RD0->RD0_EMPATU
Local cAntFil		:= RD0->RD0_FILATU
Local cDscAntFil	:= If(Empty(cAntEmp) .Or. Empty(cAntFil),"",FWFilialName(cAntEmp,cAntFil,2))

Local cAtuEmp		:= If(Empty(cAntEmp),cEmpAnt,cAntEmp)
Local cAtuFil		:= CriaVar("RD0_FILATU",.F.)
Local cDscAtuFil	:= ""

Local lRet			:= .T.
Local nOpcA		:= 0

Private oDlg

Define MsDialog oDlg Title STR0014 From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel //Transferencia

	//---------------------------------
	// Transferencia - Dados de Origem
	//---------------------------------
	@5,5 TO 050,(aCoors[4]/2)-5 LABEL STR0002 OF oDlg PIXEL //"Origem"
	@020,015 SAY STR0003						SIZE 060,007 OF oDlg PIXEL //"Filial"
	@030,015 MSGET oGet1 VAR cAntFil		SIZE 035,007 OF oDlg PIXEL WHEN .F.
	@020,060 SAY STR0004					SIZE 060,007 OF oDlg PIXEL	 //"Descrição"
	@030,060 MSGET oGet2 VAR cDscAntFil		SIZE 140,007 OF oDlg PIXEL WHEN .F.

	//----------------------------------
	// Transferencia - Dados de Destino
	//----------------------------------
	@055,005 TO 100,(aCoors[4]/2)-5 LABEL STR0005 OF oDlg PIXEL //"Destino"
	@070,015 SAY "Filial"					SIZE 060,007 OF oDlg PIXEL
	@080,015 MSGET oGet3 VAR cAtuFil	SIZE 035,007 OF oDlg PIXEL F3 "XM0" VALID (lRet := FINA675Fil(cAtuEmp,cAtuFil),Fina675Dsc(lRet,cAtuEmp,cAtuFil,@cDscAtuFil),lRet) HASBUTTON 
	@070,060 SAY STR0004				SIZE 060,007 OF oDlg PIXEL	 //"Descrição"
	@080,060 MSGET oGet4 VAR cDscAtuFil	SIZE 140,007 OF oDlg PIXEL WHEN .F.

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg ,{|| nOpcA := 1,oDlg:End()},{|| nOpcA := 2,oDlg:End()},Nil,Nil) CENTERED VALID If(nOpcA==1,FINA675TOk(cAtuEmp,cAtuFil),.T.)

If nOpcA == 1
	Fina675Grv(cAntEmp,cAntFil,cAtuEmp,cAtuFil)

	If SuperGetMv("MV_RESEXP",.F.,"0") $ "1|3"
		Fina657Trn()
	EndIf

EndIf

Return

//---------------------------------------------
// Valida o preenchimento da filial de destino
//---------------------------------------------
Function FINA675Fil(cAtuEmp,cAtuFil)
Local lRet := .T.

If !Empty(cAtuFil)
	If RD0->RD0_FILATU == cAtuFil 
		Help(" ",1,"FINA675Fil",,STR0006,1,0) //"A filial de destino não pode ser igual a origem."
		lRet		:= .F.
	ElseIf !FWFilExist(cAtuEmp,cAtuFil)
		Help(" ",1,"FINA675Fil",,STR0007,1,0) //"Filial não existente."
		lRet		:= .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------
// Atualiza o campo de descricao da filial destino
//-------------------------------------------------
Function FINA675Dsc(lRet,cAtuEmp,cAtuFil,cDscAtuFil)

If !lRet .Or. Empty(cAtuFil)
	cDscAtuFil	:= ""
Else
	cDscAtuFil := FWFilialName(cAtuEmp,cAtuFil,2)
EndIf

Return

//----------------------------------------------
// Valida os dados ao acionar o botão Confirmar
//----------------------------------------------
Function FINA675TOk(cAtuEmp,cAtuFil)
Local lRet := .T.

If Empty(cAtuFil)
	lRet := .F.
	Help(" ",1,"FINA675TOk",,STR0008,1,0) //"Informe a filial de destino."
ElseIf !FINA675Fil(cAtuEmp,cAtuFil)
	lRet := .F.
EndIf

Return lRet

//------------------------------
// Realiza a gravacao dos dados
//------------------------------
Function Fina675Grv(cAntEmp,cAntFil,cAtuEmp,cAtuFil)

RecLock("RD0",.F.)
RD0->RD0_EMPANT	:= cAntEmp
RD0->RD0_FILANT	:= cAntFil
RD0->RD0_EMPATU	:= cAtuEmp
RD0->RD0_FILATU	:= cAtuFil
RD0->RD0_RESERV := "6"
RD0->(MsUnlock())

Return
