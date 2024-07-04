#Include "JURA033.Ch"
#Include "Protheus.Ch"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA033
Cadastro de Faturas Adicionais

@author TOTVS
@since --/--/--
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA033()
Local cLojaAuto := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local oBrowse   := Nil

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('NVV')
Iif(cLojaAuto == "1" .And. FindFunction("JurBrwRev"), JurBrwRev(oBrowse, "NVV", {"NVV_CLOJA"}), ) //Proteção
oBrowse:SetDescription(STR0001) //'Fatura Adicional'
oBrowse:DisableDetails()
oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@author TOTVS
@since --/--/--
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0 //'Pesquisar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.JURA033' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.JURA033' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.JURA033' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.JURA033' OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.JURA033' OPERATION 8 ACCESS 0 //'Imprimir'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do Modelo de Dados

@author TOTVS
@since --/--/--
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local bAvaNVVCab := {}
Local bAvaNVVRod := {}

Local oStrNVVCab := Nil
Local oStrNVVRod := Nil
Local oStrNVWDet := FWFormStruct(1, 'NVW')
Local oStrNWDFat := FWFormStruct(1, 'NWD')
Local oStrNXGDiv := FWFormStruct(1, 'NXG')
Local oStrNVNEnc := FWFormStruct(1, 'NVN')
Local cNumCaso   := SuperGetMV('MV_JCASO1',, '1') //Defina a sequência da numeração do Caso. (1- Por cliente;2- Independente do cliente.)
Local oModel     := Nil
Local oCommit    := JA033COMMIT():New()

If oStrNVWDet:HasField( "NVW_VALDTR" ) //Protecao
	bAvaNVVCab := {|xAux| !AllTrim(xAux) $ 'NVV_SALDOD\NVV_SALDOH\NVV_SALDOT\NVV_SALDTR'}
	bAvaNVVRod := {|xAux|  AllTrim(xAux) $ 'NVV_SALDOD\NVV_SALDOH\NVV_SALDOT\NVV_SALDTR'}
Else
	bAvaNVVCab := {|xAux| !AllTrim(xAux) $ 'NVV_SALDOD\NVV_SALDOH\NVV_SALDOT'}
	bAvaNVVRod := {|xAux|  AllTrim(xAux) $ 'NVV_SALDOD\NVV_SALDOH\NVV_SALDOT'}
EndIf
oStrNVVCab := FWFormStruct(1, 'NVV', bAvaNVVCab)
oStrNVVRod := FWFormStruct(1, 'NVV', bAvaNVVRod)

oStrNVVCab:RemoveField("NVV_TKRET")
oStrNVWDet:RemoveField("NVW_CODFAD")
oStrNVWDet:RemoveField("NVW_DTAEMI")
oStrNWDFat:RemoveField("NWD_CFTADC")
oStrNXGDiv:RemoveField("NXG_CFATAD")
oStrNVNEnc:RemoveField("NVN_CFATAD")
oStrNVNEnc:RemoveField("NVN_CCONTR")
oStrNVNEnc:RemoveField("NVN_CCONTR")
oStrNVNEnc:RemoveField("NVN_CLIPG")
oStrNVNEnc:RemoveField("NVN_LOJPG")

oModel := MPFormModel():New('JURA033', /*Prevalidacao*/, /*Pos-Validacao*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields('NVVMASTERCAB', /*cOwner*/, oStrNVVCab)
oModel:AddGrid('NVWDETAIL', 'NVVMASTERCAB', oStrNVWDet, {|oGrid,nLine, cAction | J033Atual(oGrid, nLine, cAction )} /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid('NWDDETAIL', 'NVVMASTERCAB', oStrNWDFat, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddFields('NVVMASTERROD', 'NVVMASTERCAB', oStrNVVRod)
oModel:AddGrid('NXGDETAIL', 'NVVMASTERCAB', oStrNXGDiv, /*bLinePre*/, {|oGrid,nLine, cAction | J033NXGPos(oGrid, nLine, cAction )}, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid('NVNDETAIL', 'NXGDETAIL', oStrNVNEnc, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

oModel:SetRelation('NVVMASTERROD', {{'NVV_FILIAL', 'xFilial("NVV")'}, {'NVV_COD'   , 'NVV_COD'} }, NVV->(IndexKey(1)))
oModel:SetRelation('NVWDETAIL'   , {{'NVW_FILIAL', 'xFilial("NVW")'}, {'NVW_CODFAD', 'NVV_COD'} }, NVW->(Indexkey(1)))
oModel:SetRelation('NWDDETAIL'   , {{'NWD_FILIAL', 'xFilial("NWD")'}, {'NWD_CFTADC', 'NVV_COD'} }, 'R_E_C_N_O_' )

oModel:SetRelation('NXGDETAIL'   , {{'NXG_FILIAL', 'xFilial("NXG")'}, {'NXG_CFATAD', 'NVV_COD'} }, NXG->(Indexkey(4)))
oModel:SetRelation('NVNDETAIL'   , {{'NVN_FILIAL', 'xFilial("NXG")'}, {'NVN_CFATAD', 'NVV_COD'}, {"NVN_CLIPG", 'NXG_CLIPG'}, {"NVN_LOJPG", 'NXG_LOJAPG'} }, NVN->(Indexkey(6)))

oModel:GetModel('NVWDETAIL'):SetUniqueLine( { "NVW_CCLIEN", "NVW_CLOJA", "NVW_CCASO" } )
oModel:GetModel('NVNDETAIL'):SetUniqueLine( { "NVN_CCONT" } )

oModel:SetDescription(STR0001) // 'Fatura Adicional'

oModel:GetModel('NVVMASTERCAB'):SetDescription(STR0009) //'Dados de Fatura Adicional (Cab)'
oModel:GetModel('NVVMASTERROD'):SetDescription(STR0010) //'Dados de Fatura Adicional (Rod)'
oModel:GetModel('NVWDETAIL'):SetDescription(STR0011) //'Casos x Fatura Adicional'
oModel:GetModel('NVWDETAIL'):SetDescription(STR0048) //'Encaminhamento de Faturas'

oModel:SetOnlyQuery('NVVMASTERROD', .T. )
oModel:GetModel('NWDDETAIL'):SetOnlyView ( .T. )

oStrNWDFat:SetProperty( '*', MODEL_FIELD_NOUPD, .T. ) 

oModel:SetOptional( "NWDDETAIL" , .T. )
oModel:SetOptional( "NVNDETAIL" , .T. )
oModel:SetOptional( "NVWDETAIL", .T. )
oModel:SetOptional( "NXGDETAIL", .T. )

oModel:InstallEvent("JA033COMMIT", /*cOwner*/, oCommit)

If(cNumCaso == "1")
	oModel:AddRules( 'NVWDETAIL', 'NVW_CCASO', 'NVWDETAIL', 'NVW_CLOJA', 3 )
EndIf

oModel:SetVldActivate( { |oModel| Iif(FindFunction("JurVldUxP"), JurVldUxP(oModel), .T.) } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA033COMMIT
Classe interna implementando o FWModelEvent, para execução de função
durante o commit.

@author Ricardo Neves
@since 25/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA033COMMIT FROM FWModelEvent
	Data lAlteraPre

	Method New()
	Method ModelPosVld()
	Method InTTS()
	Method Destroy()
End Class

Method New() Class JA033COMMIT
	Self:lAlteraPre := .F.
Return

Method ModelPosVld(oModel, cModelId) Class JA033COMMIT
Local lRet := .T.

	lRet := J033PosVal(oModel, @Self:lAlteraPre)

Return lRet

Method InTTS(oModel, cModelId) Class JA033COMMIT

	If Self:lAlteraPre
		J033UpdPre(oModel) //Atualiza a Pré-Fatura vinculada à fatura adicional
	EndIf

	JFILASINC(oModel:GetModel(), "NVV", "NVVMASTERCAB", "NVV_COD") // Fila de sincronização
Return

Method Destroy() Class JA033COMMIT
	Self:lAlteraPre := Nil
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao da Visualizacao de Dados (Formulario)

@author TOTVS
@since --/--/--
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local cLojaAuto  :=  SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local bAvaNVVCab := {}
Local bAvaNVVRod := {}

Local oStrNVVCab := Nil
Local oStrNVVRod := Nil
Local oStrNVWDet := FWFormStruct(2, 'NVW')
Local oStrNWDFat := FWFormStruct(2, 'NWD')
Local oStrNXGDiv := FWFormStruct(2, 'NXG')
Local oStrNVNEnc := FWFormStruct(2, 'NVN')

Local oModel     := FWLoadModel('JURA033')
Local oView      := Nil
Local cGroupCod  := ""

If oStrNVWDet:HasField( "NVW_VALDTR" ) //Protecao
	bAvaNVVCab := {|xAux| ! AllTrim(xAux) $ 'NVV_SALDOD\NVV_SALDOH\NVV_SALDOT\NVV_SALDTR'}
	bAvaNVVRod := {|xAux| AllTrim(xAux) $ 'NVV_SALDOD\NVV_SALDOH\NVV_SALDOT\NVV_SALDTR'}
Else
	bAvaNVVCab := {|xAux| ! AllTrim(xAux) $ 'NVV_SALDOD\NVV_SALDOH\NVV_SALDOT'}
	bAvaNVVRod := {|xAux| AllTrim(xAux) $ 'NVV_SALDOD\NVV_SALDOH\NVV_SALDOT'}
EndIf
oStrNVVCab := FWFormStruct(2, 'NVV', bAvaNVVCab)
oStrNVVRod := FWFormStruct(2, 'NVV', bAvaNVVRod)

If(cLojaAuto == "1")
	oStrNVVCab:RemoveField( "NVV_CLOJA" )
	oStrNVWDet:RemoveField( "NVW_CLOJA" )
EndIf
oStrNVVCab:RemoveField("NVV_TKRET")
oStrNVVCab:RemoveField("NVV_CPART1")
oStrNVWDet:RemoveField('NVW_CODFAD')
oStrNVWDet:RemoveField("NVW_DTAEMI")
oStrNWDFat:RemoveField("NWD_CFTADC")
oStrNXGDiv:RemoveField("NXG_COD")
oStrNXGDiv:RemoveField("NXG_CFATAD")
oStrNXGDiv:RemoveField("NXG_FILA")
oStrNXGDiv:RemoveField("NXG_CPREFT")
oStrNXGDiv:RemoveField("NXG_CCONTR")
oStrNXGDiv:RemoveField("NXG_CFIXO")
If NXG->(ColumnPos('NXG_PIRRF')) > 0 .AND. NXG->(ColumnPos('NXG_PPIS')) > 0 .AND. NXG->(ColumnPos('NXG_PCOFIN')) > 0 ;
	.And. NXG->(ColumnPos('NXG_PCSLL')) > 0 .AND. NXG->(ColumnPos('NXG_PINSS')) > 0 .AND. NXG->(ColumnPos('NXG_PISS')) > 0
	oStrNXGDiv:RemoveField("NXG_PIRRF")
	oStrNXGDiv:RemoveField("NXG_PPIS")
	oStrNXGDiv:RemoveField("NXG_PCOFIN")
	oStrNXGDiv:RemoveField("NXG_PCSLL")
	oStrNXGDiv:RemoveField("NXG_PINSS")
	oStrNXGDiv:RemoveField("NXG_PISS")
EndIf
oStrNVNEnc:RemoveField("NVN_CFATAD")
oStrNVNEnc:RemoveField("NVN_CCONTR")
oStrNVNEnc:RemoveField("NVN_CJCONT")
oStrNVNEnc:RemoveField("NVN_CLIPG")
oStrNVNEnc:RemoveField("NVN_LOJPG")
oStrNVNEnc:RemoveField("NVN_CPREFT")
If NVN->(ColumnPos("NVN_CFIXO")) > 0
	oStrNVNEnc:RemoveField( 'NVN_CFIXO' )
EndIf
If NVN->(ColumnPos("NVN_CFILA")) > 0 //Proteção
	oStrNVNEnc:RemoveField( "NVN_CFILA" )
	oStrNVNEnc:RemoveField( "NVN_CESCR" )
	oStrNVNEnc:RemoveField( "NVN_CFATUR" )
EndIf

If oStrNVVCab:HasField("NVV_MSBLQL") // Ajusta Agrupamento do campo de bloqueio
	cGroupCod := oStrNVVCab:GetProperty("NVV_COD", MVC_VIEW_GROUP_NUMBER)
	oStrNVVCab:SetProperty("NVV_MSBLQL", MVC_VIEW_GROUP_NUMBER, cGroupCod)
EndIf

oView := FWFormView():New()

oView:SetModel(oModel)
oView:AddField('VIEW_NVV_CAB', oStrNVVCab, 'NVVMASTERCAB')
oView:AddField('VIEW_NVV_ROD', oStrNVVRod, 'NVVMASTERROD')
oView:AddGrid('VIEW_NVW_DET', oStrNVWDet, 'NVWDETAIL')
oView:AddGrid('VIEW_NWD_DET', oStrNWDFat, 'NWDDETAIL')
oView:AddGrid('VIEW_NXG_DET', oStrNXGDiv, 'NXGDETAIL')
oView:AddGrid('VIEW_NVN_DET', oStrNVNEnc, 'NVNDETAIL')

oView:CreateFolder('FOLDER_01')
oView:AddSheet('FOLDER_01', 'ABA_01', STR0001 ) //"Fatura Adicional"
oView:AddSheet('FOLDER_01', 'ABA_02', STR0074 ) //"Pagadores"

oView:CreateHorizontalBox('B1_SUPERIOR',  55,,, 'FOLDER_01', 'ABA_01')
oView:CreateHorizontalBox('B1_MEIO',      35,,, 'FOLDER_01', 'ABA_01')
oView:CreateHorizontalBox('B1_INFERIOR',  10,,, 'FOLDER_01', 'ABA_01')

oView:CreateHorizontalBox('B1_PAGADORES',  50,,, 'FOLDER_01', 'ABA_02')
oView:CreateHorizontalBox('B1_ENCAMINHA',  50,,, 'FOLDER_01', 'ABA_02')

oView:CreateFolder('FOLDER_02','B1_MEIO')
oView:AddSheet('FOLDER_02','ABA_NVW', STR0035) // Casos vinculados
oView:AddSheet('FOLDER_02','ABA_NWD', STR0036) // Faturamento da parcela

oView:CreateHorizontalBox("FORMFOLDER_NVW",100,,,'FOLDER_02','ABA_NVW')
oView:CreateHorizontalBox("FORMFOLDER_NWD",100,,,'FOLDER_02','ABA_NWD')

oView:CreateFolder('FOLDER_03','B1_ENCAMINHA')
oView:AddSheet('FOLDER_03','ABA_NVN', STR0048) // "Encaminhamento de faturas"

oView:CreateHorizontalBox("FORMFOLDER_NVN",100,,,'FOLDER_03','ABA_NVN')

oView:SetOwnerView('VIEW_NVV_CAB', 'B1_SUPERIOR')
oView:SetOwnerView('VIEW_NVW_DET', 'FORMFOLDER_NVW')
oView:SetOwnerView('VIEW_NWD_DET', 'FORMFOLDER_NWD')
oView:SetOwnerView('VIEW_NVV_ROD', 'B1_INFERIOR')
oView:SetOwnerView('VIEW_NXG_DET', 'B1_PAGADORES')
oView:SetOwnerView('VIEW_NVN_DET', 'FORMFOLDER_NVN')

oView:AddUserButton(STR0025, 'RECALC', {|oAux| J033RatNVW(oAux)})  // Rateio
oView:AddUserButton(STR0034, 'SDUAPPEND', {|oAux| J033CASOS(oAux)}) // Casos        
oView:AddUserButton(STR0085, 'RECALC', {|oAux| JURA303()},,, {MODEL_OPERATION_UPDATE}) //"Hist. Fatu. Ocorr."

oView:AddIncrementField( 'NVNDETAIL', 'NVN_COD' )

oView:SetCloseOnOk({||.F.})

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} J033PrxPar
Calcula o proximo numero de parcela

@author TOTVS
@since --/--/--
@version 1.0
/*/
//-------------------------------------------------------------------
Function J033PrxPar(cCodCli, cLojCli)
Local cCodPar := ""
Local aArea   := GetArea()
Local aAreSav := NVV->(GetArea())
Local oModel  := FwModelActive()
Local cFatAdi := ""

If !Empty(cCodCli) .And. !Empty(cLojCli)

	If oModel:GetID() == 'JURA033' // Se o cliente foi igual retorna o numero da parcela
		cFatAdi := oModel:GetValue("NVVMASTERCAB", "NVV_COD")
		NVV->(dbSetOrder(1)) //NVV_FILIAL+NVV_COD+NVV_PARC
		If NVV->(dbSeek(xFilial('NVV') + cFatAdi))
			If NVV->(NVV_FILIAL + NVV_CCLIEN + NVV_CLOJA) == xFilial('NVV') + cCodCli + cLojCli
				cCodPar := NVV->NVV_PARC
			EndIf
		EndIf
	EndIf

	If Empty(cCodPar)
		cCodPar := StrZero(1, TamSX3('NVV_PARC')[1])
		NVV->(dbSetOrder(2)) //NVV_FILIAL+NVV_CCLIEN+NVV_CLOJA+NVV_PARC
		If NVV->(dbSeek(xFilial('NVV') + cCodCli + cLojCli))

			While ! NVV->(Eof()) .And. NVV->(NVV_FILIAL + NVV_CCLIEN + NVV_CLOJA) == xFilial('NVV') + cCodCli + cLojCli

				cCodPar := Soma1(NVV->NVV_PARC)

				NVV->(dbSkip())
			EndDo
		EndIf

	EndIf
EndIf

RestArea(aAreSav)
RestArea(aArea)

Return cCodPar

//-------------------------------------------------------------------
/*/{Protheus.doc} J033RecGrd
Recalcula Grid

@author TOTVS
@since --/--/--
@version 1.0
/*/
//-------------------------------------------------------------------
Function J033RecGrd(oModel, cAction, nLine)
Local lRet        := .T.
Local oModNVVCab  := oModel:GetModel('NVVMASTERCAB')
Local oModNVWDet  := oModel:GetModel('NVWDETAIL')

Local nRefDes     := IIf(oModNVVCab:GetValue('NVV_TPRAT') == '1', oModNVVCab:GetValue('NVV_VALORD'), IIf(oModNVVCab:GetValue('NVV_VALORD') > 0, 100, 0))
Local nRefHon     := IIf(oModNVVCab:GetValue('NVV_TPRAT') == '1', oModNVVCab:GetValue('NVV_VALORH'), IIf(oModNVVCab:GetValue('NVV_VALORH') > 0, 100, 0))
Local nRefTab     := IIf(oModNVVCab:GetValue('NVV_TPRAT') == '1', oModNVVCab:GetValue('NVV_VALORT'), IIf(oModNVVCab:GetValue('NVV_VALORT') > 0, 100, 0))
Local nRefTri     := 0

Local nConLin     := 0
Local nVlrDes     := 0
Local nVlrTri     := 0
Local nVlrHon     := 0
Local nVlrTab     := 0
Local lProtNvvVal := oModNVVCab:HasField( "NVV_VALDTR" ) //Protecao
Local lProtNvwVal := oModNVWDet:HasField( "NVW_VALDTR" ) //Protecao

Local nLinAnt     := oModNVWDet:GetLine()

Default cAction   := ''
Default nLine     := 0

If lProtNvvVal //proteção
	nRefTri := IIf(oModNVVCab:GetValue('NVV_TPRAT') == '1', oModNVVCab:GetValue('NVV_VALDTR'), IIf(oModNVVCab:GetValue('NVV_VALDTR') > 0, 100, 0))
EndIf

For nConLin := 1 To oModNVWDet:GetQtdLine()
	If !oModNVWDet:IsDeleted(nConLin) .And. !Empty(oModNVWDet:GetValue('NVW_CCASO',nConLin)) .And.;
		!(cAction == 'DELETE' .And. nConLin == nLine .And. !oModNVWDet:IsDeleted(nConLin))
		nVlrDes += oModNVWDet:GetValue('NVW_VALORD',nConLin)
		If lProtNvwVal //proteção
			nVlrTri += oModNVWDet:GetValue('NVW_VALDTR',nConLin)
		EndIf
		nVlrHon += oModNVWDet:GetValue('NVW_VALORH',nConLin)
		nVlrTab += oModNVWDet:GetValue('NVW_VALORT',nConLin)
	EndIf
Next nConLin

If oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4
	IIF(lRet, lRet := oModel:SetValue('NVVMASTERROD','NVV_SALDOD', Round(nRefDes - nVlrDes, TamSX3('NVV_SALDOD')[2] )), )
	If lProtNvvVal //proteção
		IIF(lRet, lRet := oModel:SetValue('NVVMASTERROD','NVV_SALDTR', Round(nRefTri - nVlrTri, TamSX3('NVV_SALDTR')[2] )), )
	EndIf
	IIF(lRet, lRet := oModel:SetValue('NVVMASTERROD','NVV_SALDOH', Round(nRefHon - nVlrHon, TamSX3('NVV_SALDOH')[2] )), )
	IIF(lRet, lRet := oModel:SetValue('NVVMASTERROD','NVV_SALDOT', Round(nRefTab - nVlrTab, TamSX3('NVV_SALDOT')[2] )), )
EndIf

oModNVWDet:GoLine(nLinAnt)

       //1        2        3        4        5                  6                 7        8        9                  10                   11
Return {nVlrDes, nVlrHon, nRefDes, nRefHon, nRefDes - nVlrDes, nRefHon - nVlrHon, nVlrTab, nRefTab, nRefTab - nVlrTab, lRet, nRefTri - nVlrTri }

//-------------------------------------------------------------------
/*/{Protheus.doc} J033RatNVW
Carrega Campos

@author TOTVS
@since --/--/--
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J033RatNVW(oView)
Local aArea       := GetArea()
Local aAreNUE     := NUE->(GetArea())
Local aAreNVE     := NVE->(GetArea())

Local oModNVVCab  := oView:GetModel():GetModel('NVVMASTERCAB')
Local oModNVWDet  := oView:GetModel():GetModel('NVWDETAIL')

Local nVlrDes     := IIf(oModNVVCab:GetValue('NVV_TPRAT') == '1', oModNVVCab:GetValue('NVV_VALORD'), IIf(oModNVVCab:GetValue('NVV_VALORD') > 0, 100, 0))
Local nVlrHon     := IIf(oModNVVCab:GetValue('NVV_TPRAT') == '1', oModNVVCab:GetValue('NVV_VALORH'), IIf(oModNVVCab:GetValue('NVV_VALORH') > 0, 100, 0))
Local nVlrTab     := IIf(oModNVVCab:GetValue('NVV_TPRAT') == '1', oModNVVCab:GetValue('NVV_VALORT'), IIf(oModNVVCab:GetValue('NVV_VALORT') > 0, 100, 0))

Local cTpDtTab    := SuperGetMv('MV_JCONVLT',, '3')  //Indica o Tipo de Conversao de Lanc. Tabelados (1 - Data de Emissao / 2 - Data de Inclusao / 3 - Data de Conclusao)

Local nVlrTri     := 0
Local nConLin     := 0
Local nTotLin     := 0
Local nLinAnt     := oModNVWDet:GetLine()

Local nPos        := 0
Local nRatDes     := 0
Local nRatHon     := 0
Local nRatTab     := 0
Local nRatTri     := 0
Local nTotDes     := 0
Local nTotTri     := 0
Local nTotHon     := 0
Local nTotTab     := 0
Local nSomaTS     := 0
Local nSomaTB     := 0
Local nSomaDS     := 0
Local nSomaDST    := 0
Local aParBox     := {}
Local aRetPar     := {}
Local nTipRat     := 1
Local nForRat     := 1
Local nValTSCaso  := 0
Local nValDsCaso  := 0
Local nValDsTCaso := 0
Local nValTbCaso  := 0
Local nTSFatAd    := 0
Local nDsFatAd    := 0
Local nDsFatAdT   := 0
Local nTbFatAd    := 0
Local nRatTSCaso  := 0
Local nRatDsCaso  := 0
Local nRatDsTCaso := 0
Local nRatTbCaso  := 0
Local nTotRatTS   := 0
Local nTotRatDs   := 0
Local nTotRatDsT  := 0
Local nTotRatTb   := 0
Local nMaxTS      := 0
Local nPosMaxTS   := 0
Local nMaxDs      := 0
Local nMaxDsT     := 0
Local nPosMaxDs   := 0
Local nPosMaxDsT  := 0
Local nMaxTb      := 0
Local nPosMaxTb   := 0
Local nUltCaso    := 0
Local aVlTSCaso   := {}
Local aVlDspCaso  := {}
Local aVlDspTCaso := {}
Local aVlTbCaso   := {}
Local lRet        := .T.
Local lDespTrib   := .T.
Local dLancTab
Local lProtNvvVal := oModNVVCab:HasField( "NVV_VALDTR" ) //Protecao
Local lProtNvwVal := oModNVWDet:HasField( "NVW_VALDTR" ) //Protecao

aAdd(aParBox,{3, STR0012, nTipRat, {STR0015, STR0014, STR0013, STR0051}, 50, "", .F.}) //"Tipo Rateio"###"Todos"(1)###"Time Sheet"(2)###"Despesa"(3)###"Tabelado"(4)###
aAdd(aParBox,{3, STR0052, nForRat, {STR0053, STR0054}, 100, "", .F.}) //"Forma de Rateio"###"Valor"(1)###"Quantidade"(2)

If lProtNvvVal //proteção
	nVlrTri := IIf(oModNVVCab:GetValue('NVV_TPRAT') == '1', oModNVVCab:GetValue('NVV_VALDTR'), IIf(oModNVVCab:GetValue('NVV_VALDTR') > 0, 100, 0))
EndIf

If ! ParamBox(aParBox, STR0016, @aRetPar,,,,,,,, .F., .F.) //"Pesquisa Direta"
	Return
EndIf

nTipRat := aRetPar[1]
nForRat := aRetPar[2]

If nForRat == 2 //Rateio pela quantidade de casos

	//Levantamento dos valores
	If ( (nTipRat == 1 .Or. nTipRat == 2) .And. (oModNVVCab:GetValue('NVV_VALORH') > 0) ) .Or.;
			( (nTipRat == 1 .Or. nTipRat == 3) .And. (oModNVVCab:GetValue('NVV_VALORD') > 0) )    .Or.;
			Iif(lProtNvvVal,( (nTipRat == 1 .Or. nTipRat == 3) .And. (oModNVVCab:GetValue('NVV_VALDTR') > 0) ), .F.) .Or.;
			( (nTipRat == 1 .Or. nTipRat == 4) .And. (oModNVVCab:GetValue('NVV_VALORT') > 0) )
		For nConLin := 1 To oModNVWDet:GetQtdLine()
			oModNVWDet:GoLine(nConLin)
			If !oModNVWDet:IsDeleted() .And. !Empty(oModNVWDet:GetValue('NVW_CCASO'))
				nTotLin ++
			EndIf
		Next

		If nTotLin == 0
			lRet := JurMsgErro(STR0056) //"Não há casos para rateio na aba Casos Vinculados."
		EndIf

		If lRet
			nRatDes := Round(IIf(nVlrDes == 0, 0, nVlrDes / nTotLin), 2)
			nRatTri := Round(IIf(nVlrTri == 0, 0, nVlrTri / nTotLin), 2)
			nRatHon := Round(IIf(nVlrHon == 0, 0, nVlrHon / nTotLin), 2)
			nRatTab := Round(IIf(nVlrTab == 0, 0, nVlrTab / nTotLin), 2)

			For nConLin := 1 To oModNVWDet:GetQtdLine()
				oModNVWDet:GoLine(nConLin)

				If Empty(oModNVWDet:GetValue('NVW_CCASO')) .Or. oModNVWDet:IsDeleted()
					Loop
				EndIf

				If nTipRat == 1 .Or. nTipRat == 2
					oModNVWDet:LoadValue('NVW_VALORH', nRatHon)
				EndIf

				If nTipRat == 1 .Or. nTipRat == 3
					oModNVWDet:LoadValue('NVW_VALORD', nRatDes)
					If lProtNvwVal
						oModNVWDet:LoadValue('NVW_VALDTR', nRatTri)
					EndIf
				EndIf

				If nTipRat == 1 .Or. nTipRat == 4
					oModNVWDet:LoadValue('NVW_VALORT', nRatTab)
				EndIf

				nTotDes += oModNVWDet:GetValue('NVW_VALORD')
				If lProtNvwVal  //proteção
					nTotTri += oModNVWDet:GetValue('NVW_VALDTR')
				EndIf
				nTotHon += oModNVWDet:GetValue('NVW_VALORH')
				nTotTab += oModNVWDet:GetValue('NVW_VALORT')

			Next

			For nConLin := 1 To oModNVWDet:GetQtdLine()
				oModNVWDet:GoLine(nConLin)
				If ( !Empty(oModNVWDet:GetValue('NVW_CCASO') ) .And. !(oModNVWDet:IsDeleted()) ) .And. ( nConLin > nUltCaso)
					nUltCaso := nConLin
				EndIf
			Next

			oModNVWDet:GoLine(nUltCaso)

			If (nVlrHon - nTotHon) <> 0 .and. (nTipRat == 1 .Or. nTipRat == 2)
				oModNVWDet:LoadValue('NVW_VALORH', nRatHon+(nVlrHon - nTotHon))
			EndIf

			If (nVlrDes - nTotDes) <> 0 .and. (nTipRat == 1 .Or. nTipRat == 3)
				oModNVWDet:LoadValue('NVW_VALORD', nRatDes+(nVlrDes - nTotDes))
			EndIf

			If lProtNvwVal  //proteção
				If (nVlrTri - nTotTri) <> 0 .and. (nTipRat == 1 .Or. nTipRat == 3)
					oModNVWDet:LoadValue('NVW_VALDTR', nRatTri+(nVlrTri - nTotTri))
				EndIf
			EndIf

			If (nVlrTab - nTotTab) <> 0 .and. (nTipRat == 1 .Or. nTipRat == 4)
				oModNVWDet:LoadValue('NVW_VALORT', nRatTab+(nVlrTab - nTotTab))
			EndIf

		EndIf
	Else
		lRet := JurMsgErro(STR0055) //"Não há valores a serem rateados."
	EndIf

Else //Rateio pelo valor pendente de cada caso

	//Levantamento dos valores
	If ( (nTipRat == 1 .Or. nTipRat == 2) .And. (oModNVVCab:GetValue('NVV_VALORH') > 0) ) .Or.;
			( (nTipRat == 1 .Or. nTipRat == 3) .And. (oModNVVCab:GetValue('NVV_VALORD') > 0) )    .Or.;
			( (nTipRat == 1 .Or. nTipRat == 4) .And. (oModNVVCab:GetValue('NVV_VALORT') > 0) )    .Or.;
			Iif(lProtNvvVal,((nTipRat == 1 .Or. nTipRat == 4) .And. (oModNVVCab:GetValue('NVV_VALDTR') > 0) ), .F.)

		For nConLin := 1 To oModNVWDet:GetQtdLine()
			oModNVWDet:GoLine(nConLin)
			If !oModNVWDet:IsDeleted() .And. !Empty(oModNVWDet:GetValue('NVW_CCASO'))
				nTotLin ++
			EndIf
		Next

		If nTotLin == 0
			lRet := JurMsgErro(STR0056) //"Não há casos para rateio na aba Casos Vinculados."
		EndIf

		If lRet
			For nConLin := 1 To oModNVWDet:GetQtdLine()
				oModNVWDet:GoLine(nConLin)

				If !oModNVWDet:IsDeleted() .And. !Empty(oModNVWDet:GetValue('NVW_CCASO'))

					NVE->(dbSetOrder(1)) //NVE_FILIAL+NVE_CCLIEN+NVE_LCLIEN+NVE_NUMCAS+NVE_SITUAC
					NVE->(dbSeek(xFilial("NVE") + oModNVWDet:GetValue('NVW_CCLIEN') + oModNVWDet:GetValue('NVW_CLOJA') + oModNVWDet:GetValue('NVW_CCASO')))

					While ! NVE->(Eof()) .And. NVE->(NVE_FILIAL+NVE_CCLIEN+NVE_LCLIEN+NVE_NUMCAS) == xFilial("NVE") + oModNVWDet:GetValue('NVW_CCLIEN');
							+ oModNVWDet:GetValue('NVW_CLOJA') + oModNVWDet:GetValue('NVW_CCASO')

						If NVE->NVE_COBRAV == "1" .And. NVE->NVE_ENCHON == "2"

							//Levanta os valores de TSs
							If ( (nTipRat == 1 .Or. nTipRat == 2) .And. (oModNVVCab:GetValue('NVV_VALORH') > 0) )

								NUE->(dbSetOrder(2)) //NUE_FILIAL+NUE_CCLIEN+NUE_CLOJA+NUE_CCASO+NUE_CPREFT
								NUE->(dbSeek(xFilial("NUE") + oModNVWDet:GetValue('NVW_CCLIEN') + oModNVWDet:GetValue('NVW_CLOJA') + oModNVWDet:GetValue('NVW_CCASO')))

								nValTSCaso := 0
								While ! NUE->(Eof()) .And. NUE->(NUE_FILIAL+NUE_CCLIEN+NUE_CLOJA+NUE_CCASO) == xFilial("NUE") + oModNVWDet:GetValue('NVW_CCLIEN');
										+ oModNVWDet:GetValue('NVW_CLOJA') + oModNVWDet:GetValue('NVW_CCASO')

									If NUE->NUE_SITUAC == '1' .And. (NUE->NUE_DATATS >= oModNVVCab:GetValue('NVV_DTINIH')) .And. (NUE->NUE_DATATS <= oModNVVCab:GetValue('NVV_DTFIMH'))

										lTSCob := JurTSCob(NUE->NUE_COD,NUE->NUE_CCLIEN,NUE->NUE_CLOJA,NUE->NUE_CCASO,NUE->NUE_CATIVI) //Indica se o TS é cobrável ou não

										If lTSCob
											If NUE->NUE_CMOEDA == oModNVVCab:GetValue('NVV_CMOE1')
												nValTSCaso += NUE->NUE_VALOR
											Else
												nValTSCaso += JA201FConv(oModNVVCab:GetValue('NVV_CMOE1'), NUE->NUE_CMOEDA, NUE->NUE_VALOR, "1", Date())[1]
											EndIf
										EndIf
									EndIf
									NUE->(dbSkip())
								EndDo
								Aadd(aVlTSCaso, {NVE->NVE_CCLIEN, NVE->NVE_LCLIEN, NVE->NVE_NUMCAS, nValTSCaso})
								nTSFatAd += nValTSCaso
							EndIf
						Else
							Aadd(aVlTSCaso, {NVE->NVE_CCLIEN, NVE->NVE_LCLIEN, NVE->NVE_NUMCAS, 0})
						EndIf

						If NVE->NVE_COBRAV == "1" .And. NVE->NVE_ENCDES == "2"

							//Levanta os valores de Despesa
							If ( (nTipRat == 1 .Or. nTipRat == 3) .And. (oModNVVCab:GetValue('NVV_VALORD') > 0) ) .Or.;
							   Iif(lProtNvvVal,( (nTipRat == 1 .Or. nTipRat == 3) .And. (oModNVVCab:GetValue('NVV_VALDTR') > 0) ), .F.)

								NVY->(dbSetOrder(2)) //NVY_FILIAL+NVY_CCLIEN+NVY_CLOJA+NVY_CCASO+NVY_CPREFT
								NVY->(dbSeek(xFilial("NVY") + oModNVWDet:GetValue('NVW_CCLIEN') + oModNVWDet:GetValue('NVW_CLOJA') + oModNVWDet:GetValue('NVW_CCASO')))

								nValDsCaso := 0
								nValDsTCaso:= 0
								While ! NVY->(Eof()) .And. NVY->(NVY_FILIAL+NVY_CCLIEN+NVY_CLOJA+NVY_CCASO) == xFilial("NVY") + oModNVWDet:GetValue('NVW_CCLIEN');
										+ oModNVWDet:GetValue('NVW_CLOJA') + oModNVWDet:GetValue('NVW_CCASO')

									If NVY->NVY_SITUAC == '1' .And. NVY->NVY_COBRAR == '1' .And. (NVY->NVY_DATA >= oModNVVCab:GetValue('NVV_DTINID')) .And. (NVY->NVY_DATA <= oModNVVCab:GetValue('NVV_DTFIMD'))

										lDSCob := JurDSCob(NVY->NVY_COD, NVY->NVY_CCLIEN, NVY->NVY_CLOJA, NVY->NVY_CCASO, NVY->NVY_CTPDSP) //Indica se o tipo de despesa é cobrável ou não

										If lDSCob
											lDespTrib := JurDspTrib(NVY->NVY_CTPDSP)
											If lDespTrib
												//Despesa Tributavel
												If lProtNvvVal
													If NVY->NVY_CMOEDA == oModNVVCab:GetValue('NVV_CMOE2')
														nValDsTCaso += NVY->NVY_VALOR
													Else
														nValDsTCaso += JA201FConv(oModNVVCab:GetValue('NVV_CMOE2'), NVY->NVY_CMOEDA, NVY->NVY_VALOR, "1", Date())[1]
													EndIf
												EndIf
											Else // Despesa reembolsável
												If NVY->NVY_CMOEDA == oModNVVCab:GetValue('NVV_CMOE2')
													nValDsCaso += NVY->NVY_VALOR
												Else
													nValDsCaso += JA201FConv(oModNVVCab:GetValue('NVV_CMOE2'), NVY->NVY_CMOEDA,NVY->NVY_VALOR, "1", Date())[1]
												EndIf
											EndIf
										EndIf
									EndIf
									NVY->(dbSkip())
								EndDo
								Aadd(aVlDspCaso, {NVE->NVE_CCLIEN, NVE->NVE_LCLIEN, NVE->NVE_NUMCAS, nValDsCaso})
								Aadd(aVlDspTCaso,{NVE->NVE_CCLIEN, NVE->NVE_LCLIEN, NVE->NVE_NUMCAS, nValDsTCaso})
								nDsFatAd  += nValDsCaso
								nDsFatAdT += nValDsTCaso
							EndIf
						Else
							Aadd(aVlDspCaso, {NVE->NVE_CCLIEN, NVE->NVE_LCLIEN, NVE->NVE_NUMCAS, 0})
							Aadd(aVlDspTCaso,{NVE->NVE_CCLIEN, NVE->NVE_LCLIEN, NVE->NVE_NUMCAS, 0})
						EndIf

						If NVE->NVE_COBRAV == "1" .And. NVE->NVE_ENCTAB == "2"

							//Levanta os valores de Tabelado
							If ( (nTipRat == 1 .Or. nTipRat == 4) .And. (oModNVVCab:GetValue('NVV_VALORT') > 0) )

								NV4->(dbSetOrder(2)) //NV4_FILIAL+NV4_CCLIEN+NV4_CLOJA+NV4_CCASO+NV4_CPREFT
								NV4->(dbSeek(xFilial("NV4") + oModNVWDet:GetValue('NVW_CCLIEN') + oModNVWDet:GetValue('NVW_CLOJA') + oModNVWDet:GetValue('NVW_CCASO')))

								nValTbCaso := 0
								While ! NV4->(Eof()) .And. NV4->(NV4_FILIAL+NV4_CCLIEN+NV4_CLOJA+NV4_CCASO) == xFilial("NV4") + oModNVWDet:GetValue('NVW_CCLIEN');
										+ oModNVWDet:GetValue('NVW_CLOJA') + oModNVWDet:GetValue('NVW_CCASO')

									If cTpDtTab == "1"     //Data de Emissao
										dLancTab := NV4->NV4_DTLANC
									ElseIf cTpDtTab == "2" //Data de Inclusao
										dLancTab := NV4->NV4_DTINC
									Else                  //Data de Conclusão
										dLancTab := NV4->NV4_DTCONC
									EndIf

									If NV4->NV4_SITUAC == '1' .And. NV4->NV4_COBRAR == '1' .And. NV4->NV4_CONC == '1' .And. (NV4->NV4_DTCONC >= oModNVVCab:GetValue('NVV_DTINIT')) .And. ;
											(NV4->NV4_DTCONC <= oModNVVCab:GetValue('NVV_DTFIMT'))
										If NV4->NV4_CMOEH == oModNVVCab:GetValue('NVV_CMOE4')
											nValTbCaso += NV4->NV4_VLHFAT
										Else
											nValTbCaso += JA201FConv(oModNVVCab:GetValue('NVV_CMOE4'), NV4->NV4_CMOEH, NV4->NV4_VLHFAT, "1", dLancTab)[1]
										EndIf
									EndIf
									NV4->(dbSkip())
								EndDo
								Aadd(aVlTbCaso, {NVE->NVE_CCLIEN, NVE->NVE_LCLIEN, NVE->NVE_NUMCAS, nValTbCaso})
								nTbFatAd += nValTbCaso
							EndIf
						Else
							Aadd(aVlTbCaso, {NVE->NVE_CCLIEN, NVE->NVE_LCLIEN, NVE->NVE_NUMCAS, 0})
						EndIf

						NVE->(dbSkip())
					EndDo

				EndIf
			Next
		EndIf
	Else
		lRet := JurMsgErro(STR0055) //"Não há valores a serem rateados."
	EndIf

	//Carrega os valores dos casos respeitando o "Rateio em:" - Valor (1) ou Percentual (2)
	If lRet
		For nConLin := 1 To oModNVWDet:GetQtdLine()
			oModNVWDet:GoLine(nConLin)

			If Empty(oModNVWDet:GetValue('NVW_CCASO')) .Or. oModNVWDet:IsDeleted()
				Loop
			EndIf

			If ( nTipRat == 1 .Or. nTipRat == 2 )
				If (oModNVVCab:GetValue('NVV_VALORH') > 0)
					nPos := aScan(aVlTSCaso, {|x| x[1] == (oModNVWDet:GetValue('NVW_CCLIEN')) .And. x[2] == (oModNVWDet:GetValue('NVW_CLOJA')) ;
						.And. x[3] == (oModNVWDet:GetValue('NVW_CCASO')) } )

					If oModNVVCab:GetValue('NVV_TPRAT') == "1"
						nRatTSCaso := (oModNVVCab:GetValue('NVV_VALORH') * (aVlTSCaso[nPos][4] / nTSFatAd * 100 / 100 ) )
					Else
						nRatTSCaso := (aVlTSCaso[nPos][4] / nTSFatAd * 100)
					EndIf
					oModNVWDet:LoadValue('NVW_VALORH', Round(nRatTSCaso, 2) )
					nTotRatTS := nTotRatTS + Round(nRatTSCaso, 2)
				Else
					oModNVWDet:LoadValue('NVW_VALORH', 0)
				EndIf
			EndIf

			If ( nTipRat == 1 .Or. nTipRat == 3 )
				If (oModNVVCab:GetValue('NVV_VALORD') > 0)
					nPos := aScan(aVlDspCaso, {|x| x[1] == (oModNVWDet:GetValue('NVW_CCLIEN')) .And. x[2] == (oModNVWDet:GetValue('NVW_CLOJA')) ;
						.And. x[3] == (oModNVWDet:GetValue('NVW_CCASO')) } )

					If oModNVVCab:GetValue('NVV_TPRAT') == "1"
						nRatDsCaso := (oModNVVCab:GetValue('NVV_VALORD') * (aVlDspCaso[nPos][4] / nDsFatAd * 100 / 100 ) )
					Else
						nRatDsCaso := (aVlDspCaso[nPos][4] / nDsFatAd * 100)
					EndIf
					oModNVWDet:LoadValue('NVW_VALORD', Round(nRatDsCaso, 2))
					nTotRatDs := nTotRatDs + Round(nRatDsCaso, 2)
				Else
					oModNVWDet:LoadValue('NVW_VALORD', 0)
				EndIf

				//Despesa Tributável
				If (oModNVVCab:GetValue('NVV_VALDTR') > 0)
					nPos := aScan(aVlDspTCaso, {|x| x[1] == (oModNVWDet:GetValue('NVW_CCLIEN')) .And. x[2] == (oModNVWDet:GetValue('NVW_CLOJA')) ;
						.And. x[3] == (oModNVWDet:GetValue('NVW_CCASO')) } )

					If oModNVVCab:GetValue('NVV_TPRAT') == "1"
						nRatDsTCaso := (oModNVVCab:GetValue('NVV_VALDTR') * (aVlDspTCaso[nPos][4] / nDsFatAdT * 100 / 100 ) )
					Else
						nRatDsTCaso := (aVlDspTCaso[nPos][4] / nDsFatAdT * 100)
					EndIf
					oModNVWDet:LoadValue('NVW_VALDTR', Round(nRatDsTCaso, 2))
					nTotRatDsT := nTotRatDsT + Round(nRatDsTCaso, 2)
				Else
					oModNVWDet:LoadValue('NVW_VALDTR', 0)
				EndIf
			EndIf


			If ( nTipRat == 1 .Or. nTipRat == 4 )
				If (oModNVVCab:GetValue('NVV_VALORT') > 0)
					nPos := aScan(aVlTbCaso, {|x| x[1] == (oModNVWDet:GetValue('NVW_CCLIEN')) .And. x[2] == (oModNVWDet:GetValue('NVW_CLOJA')) ;
						.And. x[3] == (oModNVWDet:GetValue('NVW_CCASO')) } )

					If oModNVVCab:GetValue('NVV_TPRAT') == "1"
						nRatTbCaso := (oModNVVCab:GetValue('NVV_VALORT') * (aVlTbCaso[nPos][4] / nTbFatAd * 100 / 100 ) )
					Else
						nRatTbCaso := (aVlTbCaso[nPos][4] / nTbFatAd * 100)
					EndIf
					oModNVWDet:LoadValue('NVW_VALORT', Round(nRatTbCaso,2))
					nTotRatTb := nTotRatTb + Round(nRatTbCaso, 2)
				Else
					oModNVWDet:LoadValue('NVW_VALORT', 0)
				EndIf
			EndIf

		Next

		//Ajusta a diferença do arredondamento
		If oModNVVCab:GetValue('NVV_TPRAT') == "1"
			If ( nTipRat == 1 .Or. nTipRat == 2 )
				If (oModNVVCab:GetValue('NVV_VALORH')) <> nTotRatTS

					For nConLin := 1 To oModNVWDet:GetQtdLine()
						oModNVWDet:GoLine(nConLin)
						If ( oModNVWDet:GetValue('NVW_VALORH') > 0 ) .And. ( oModNVWDet:GetValue('NVW_VALORH') > nMaxTS ) .And. !oModNVWDet:IsDeleted()
							nMaxTS    := oModNVWDet:GetValue('NVW_VALORH')
							nPosMaxTS := nConLin
						EndIf
					Next

					If nPosMaxTS > 0
						oModNVWDet:GoLine(nPosMaxTS)
						oModNVWDet:LoadValue('NVW_VALORH', Round(oModNVWDet:GetValue('NVW_VALORH') + ((oModNVVCab:GetValue('NVV_VALORH')) - nTotRatTS), 2))
					EndIf

				EndIf
			EndIf

			If ( nTipRat == 1 .Or. nTipRat == 3 )
				If (oModNVVCab:GetValue('NVV_VALORD')) <> nTotRatDs

					For nConLin := 1 To oModNVWDet:GetQtdLine()
						oModNVWDet:GoLine(nConLin)
						If ( oModNVWDet:GetValue('NVW_VALORD') > 0 ) .And. ( oModNVWDet:GetValue('NVW_VALORD') > nMaxDs ) .And. !oModNVWDet:IsDeleted()
							nMaxDs    := oModNVWDet:GetValue('NVW_VALORD')
							nPosMaxDs := nConLin
						EndIf
					Next

					If nPosMaxDs > 0
						oModNVWDet:GoLine(nPosMaxDs)
						oModNVWDet:LoadValue('NVW_VALORD', Round(oModNVWDet:GetValue('NVW_VALORD') + ((oModNVVCab:GetValue('NVV_VALORD')) - nTotRatDs), 2))
					EndIf
				EndIf

				//Despesa Tributável
				If lProtNvvVal //proteção
					If (oModNVVCab:GetValue('NVV_VALDTR')) <> nTotRatDsT

						For nConLin := 1 To oModNVWDet:GetQtdLine()
							oModNVWDet:GoLine(nConLin)
							If ( oModNVWDet:GetValue('NVW_VALDTR') > 0 ) .And. ( oModNVWDet:GetValue('NVW_VALDTR') > nMaxDsT ) .And. !oModNVWDet:IsDeleted()
								nMaxDsT    := oModNVWDet:GetValue('NVW_VALDTR')
								nPosMaxDsT := nConLin
							EndIf
						Next

						If nPosMaxDsT > 0
							oModNVWDet:GoLine(nPosMaxDsT)
							oModNVWDet:LoadValue('NVW_VALDTR', Round(oModNVWDet:GetValue('NVW_VALDTR') + ((oModNVVCab:GetValue('NVV_VALDTR')) - nTotRatDsT), 2))
						EndIf
					EndIf
				EndIf
			EndIf

			If ( nTipRat == 1 .Or. nTipRat == 4 )
				If (oModNVVCab:GetValue('NVV_VALORT')) <> nTotRatTb

					For nConLin := 1 To oModNVWDet:GetQtdLine()
						oModNVWDet:GoLine(nConLin)
						If ( oModNVWDet:GetValue('NVW_VALORT') > 0 ) .And. ( oModNVWDet:GetValue('NVW_VALORT') > nMaxTb ) .And. !oModNVWDet:IsDeleted()
							nMaxTb    := oModNVWDet:GetValue('NVW_VALORT')
							nPosMaxTb := nConLin
						EndIf
					Next

					If nPosMaxTb > 0
						oModNVWDet:GoLine(nPosMaxTb)
						oModNVWDet:LoadValue('NVW_VALORT', Round(oModNVWDet:GetValue('NVW_VALORT') + ((oModNVVCab:GetValue('NVV_VALORT')) - nTotRatTb), 2))
					EndIf
				EndIf

			EndIf
		Else  //Quando for Percentual
			If ( nTipRat == 1 .Or. nTipRat == 2 )
				If (oModNVVCab:GetValue('NVV_VALORH')) <> 0
					For nConLin := 1 To oModNVWDet:GetQtdLine()
						oModNVWDet:GoLine(nConLin)
						If ( oModNVWDet:GetValue('NVW_VALORH') > 0 ) .And. !oModNVWDet:IsDeleted()
							nSomaTS += oModNVWDet:GetValue('NVW_VALORH')
							If (oModNVWDet:GetValue('NVW_VALORH')) > nMaxTS
								nMaxTS  := oModNVWDet:GetValue('NVW_VALORH')
								nPosMaxTS := nConLin
							EndIf
						EndIf
					Next

					If nSomaTS <> 100 .And. nPosMaxTS <> 0
						oModNVWDet:GoLine(nPosMaxTS)
						oModNVWDet:LoadValue('NVW_VALORH', Round(oModNVWDet:GetValue('NVW_VALORH') + (100 - nSomaTS), 2))
					EndIf
				EndIf
			EndIf
			If ( nTipRat == 1 .Or. nTipRat == 3 )
				If (oModNVVCab:GetValue('NVV_VALORD')) <> 0
					For nConLin := 1 To oModNVWDet:GetQtdLine()
						oModNVWDet:GoLine(nConLin)
						If ( oModNVWDet:GetValue('NVW_VALORD') > 0 ) .And. !oModNVWDet:IsDeleted()
							nSomaDS += oModNVWDet:GetValue('NVW_VALORD')
							If (oModNVWDet:GetValue('NVW_VALORD')) > nMaxDS
								nMaxDS  := oModNVWDet:GetValue('NVW_VALORD')
								nPosMaxDS := nConLin
							EndIf
						EndIf
					Next

					If nSomaDS <> 100 .And. nPosMaxDS <> 0
						oModNVWDet:GoLine(nPosMaxDS)
						oModNVWDet:LoadValue('NVW_VALORD', Round(oModNVWDet:GetValue('NVW_VALORD') + (100 - nSomaDS), 2))
					EndIf
				EndIf

				//Despesa Tributável
				If lProtNvvVal //proteção
					If (oModNVVCab:GetValue('NVV_VALDTR')) <> 0
						For nConLin := 1 To oModNVWDet:GetQtdLine()
							oModNVWDet:GoLine(nConLin)
							If ( oModNVWDet:GetValue('NVW_VALDTR') > 0 ) .And. !oModNVWDet:IsDeleted()
								nSomaDST += oModNVWDet:GetValue('NVW_VALDTR')
								If (oModNVWDet:GetValue('NVW_VALDTR')) > nMaxDST
									nMaxDST := oModNVWDet:GetValue('NVW_VALDTR')
									nPosMaxDST := nConLin
								EndIf
							EndIf
						Next

						If nSomaDST <> 100 .And. nPosMaxDST <> 0
							oModNVWDet:GoLine(nPosMaxDS)
							oModNVWDet:LoadValue('NVW_VALDTR', Round(oModNVWDet:GetValue('NVW_VALDTR') + (100 - nSomaDST), 2))
						EndIf
					EndIf
				EndIf

			EndIf
			If ( nTipRat == 1 .Or. nTipRat == 4 )
				If (oModNVVCab:GetValue('NVV_VALORT')) <> 0
					For nConLin := 1 To oModNVWDet:GetQtdLine()
						oModNVWDet:GoLine(nConLin)
						If ( oModNVWDet:GetValue('NVW_VALORT') > 0 ) .And. !oModNVWDet:IsDeleted()
							nSomaTB += oModNVWDet:GetValue('NVW_VALORT')
							If (oModNVWDet:GetValue('NVW_VALORT')) > nMaxTB
								nMaxTB  := oModNVWDet:GetValue('NVW_VALORT')
								nPosMaxTB := nConLin
							EndIf
						EndIf
					Next

					If nSomaTB <> 100 .And. nPosMaxTB <> 0
						oModNVWDet:GoLine(nPosMaxTB)
						oModNVWDet:LoadValue('NVW_VALORT', Round(oModNVWDet:GetValue('NVW_VALORT') + (100 - nSomaTB), 2))
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

oModNVWDet:GoLine(nLinAnt)
J033RecGrd(oView:GetModel())

RestArea( aAreNVE)
RestArea( aAreNUE)
RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J033PosVal()
Pos Validacao do Modelo de dados da Fatura Adicional

@Param oModel     - Modelo de dados da Fatura Adicional
@Param lAlteraPre - Usar como refêrencia para verificar se a pré-fatura vinculada a fatura adicional deve ser alterada a situação ou cancelada.

@author Luciano Pereira dos Santos
@since  25/07/2018
@version 2.0
/*/
//-------------------------------------------------------------------
Static Function J033PosVal(oModel, lAlteraPre)
Local lRet       := .T.
Local aRet       := {}
Local oModNVVCab := oModel:GetModel('NVVMASTERCAB')
Local oGridNVW   := oModel:GetModel('NVWDETAIL')
Local nOperation := oModel:GetOperation()
Local nLinha     := 0
Local nLinAnt    := oGridNVW:GetLine()
Local aCpo       := {}

	If (nOperation == 4 .Or. nOperation == 5) // Alteração ou Exclusão
		
		If !Empty(oModNVVCab:GetValue('NVV_CPREFT'))
			aRet := JA033VERPRE(oModel, lAlteraPre)  //Valida se a fatura adicional possui pré-fatura e valida
			lRet := aRet[1]
			lAlteraPre := aRet[2]
		EndIf

		If lRet .And. nOperation == 5
			If !(JA033VE(oModel)) // Valida a existência de Fatura ou WO
				lRet := JurMsgErro(STR0078,, STR0026) // "A fatura adicional não pode ser excluída!" # "Existe faturamento/wo relacionados. Mesmo que o WO/Fatura estiverem cancelados, por questão de rastreabilidade o registro não pode ser excluido. Verifique a utilização do campo de bloqueio para invativar a Fatura Adicional."
			EndIf
		EndIf
	EndIf

	If lRet .And. nOperation != 5 //Inclusão e alteração

		If nOperation == 4 .And. oModNVVCab:GetValue("NVV_SITUAC") == '2'
			lRet := JurMsgErro(STR0037)  //"Não é permitido alterar uma fatura adicional que já foi faturada, operação cancelada!"
		EndIf
		
		If lRet
			If Empty(oModel:GetValue("NVVMASTERCAB", "NVV_CPART1"))
				lRet := JurMsgErro(I18N( STR0062, {RetTitle("NVV_SIGLA1")} ) ) // "O campo '#1' não foi preenchido. Verifique!"
			EndIf
		EndIf

		If lRet
			aCpo := {"NVV_DTINIH", "NVV_DTFIMH", "NVV_CMOE1", "NVV_VALORH"}
			lRet := J033VldLan(oModNVVCab, aCpo, "TS", STR0017) //#'Todos os campos relacionados a Honorarios devem ser preenchidos'
		EndIf

		If lRet
			aCpo := {"NVV_DTINIT", "NVV_DTFIMT", "NVV_CMOE4", "NVV_VALORT"}
			lRet := J033VldLan(oModNVVCab, aCpo, "LT", STR0050) //#'Todos os campos relacionados a Tabelados devem ser preenchidos'
		EndIf
		
		If lRet .And. oModNVVCab:GetValue("NVV_DSPCAS") == "1"
			aCpo := {"NVV_DTINID", "NVV_DTFIMD"}
			lRet := J033VldLan(oModNVVCab, aCpo, "DSP", STR0042) //#"É preciso preencher a data de referência de despesas para transferir as despesas ou cobrar as despesas do caso."
		ElseIf lRet
			aCpo := {"NVV_DTINID", "NVV_DTFIMD", "NVV_CMOE2", "NVV_VALORD"} //Se não existir valor de despesa, verifica se tem despesa tributável 
			If !(lRet := J033VldLan(oModNVVCab, aCpo, "DSP", STR0062)) //#'Todos os campos relacionados a Despesa devem ser preenchidos'
				aCpo := {"NVV_DTINID", "NVV_DTFIMD", "NVV_CMOE2", "NVV_VALDTR"}
				lRet := J033VldLan(oModNVVCab, aCpo, "DSP", STR0062) //#'Todos os campos relacionados a Despesa devem ser preenchidos'
			EndIf
		EndIf
		
		If lRet .And. !Empty(oModNVVCab:GetValue('NVV_CCONTR')) .And. !Empty(oModNVVCab:GetValue('NVV_CGRUPO')) .And. !Empty(oModNVVCab:GetValue('NVV_CCLIEN'))
			If !(JU033VG('NVVMASTERCAB', 'NVV_CCONTR'))
				lRet := JurMsgErro(STR0022) // Não é possível vincular este contrato para o Grupo ou Cliente/Loja preenchido. Verifique!
			EndIf
		EndIf
		
		If lRet //Somatoria do Grid x Valores digitados
			aRet := J033RecGrd(oModel)
			//   [1]     [2]       [3]     [4]      [5]                [6]                [7]      [8]      [9]                [10]  [11]
			// {nVlrDes, nVlrHon, nRefDes, nRefHon, nRefDes - nVlrDes, nRefHon - nVlrHon, nVlrTab, nRefTab, nRefTab - nVlrTab, lRet, nRefTri - nVlrTri } }
			
			lRet := (aRet[5] + aRet[6] + aRet[9] + aRet[11] == 0)
			
			If !lRet
				If oModNVVCab:GetValue('NVV_TPRAT') == '1'
					JurMsgErro(STR0019) //'Soma de Despesa/Honorarios deve ser igual ao Valor de Referencia'
				Else
					JurMsgErro(STR0020) //'Soma de Despesa/Honorarios deve ser igual 100%'
				EndIf
			EndIf
		EndIf

		If lRet
			For nLinha := 1 To oGridNVW:GetQtdLine()
				oGridNVW:GoLine(nLinha)
				If !oGridNVW:IsDeleted() .And. !Empty(oGridNVW:GetValue('NVW_CCASO'))
					If !(lRet := JU033VCS('NVWDETAIL', 'NVW_CCASO'))
						Exit
					EndIf
				EndIf
			Next
			oGridNVW:GoLine(nLinAnt)
		EndIf

		If lRet
			lRet := JurVldPag(oModel) //Validação de pagadores
		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J033VldLan(oModdelNVV, aCampos, cTipo, cSolucao)
Valida o preenchimento dos campos de lançamentos na Fatura Adicional.

@author Luciano Pereira dos Santos
@since 27/07/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J033VldLan(oModdelNVV, aCampos, cTipo, cSolucao)
Local cCampo := ""
Local nCampo := 0

aEval(aCampos, {|x| Iif(Empty(oModdelNVV:GetValue(x)), Iif(Empty(cCampo), cCampo := RetTitle(x), Nil), nCampo += 1) })

If oModdelNVV:GetValue("NVV_TRA" + cTipo) == "1"
	lRet := nCampo == Len(aCampos)
Else
	lRet := (nCampo == 0 .Or. nCampo == Len(aCampos))
EndIf

If !lRet
	JurMsgErro(I18N(STR0062, {AllTrim(cCampo)}), , cSolucao) //#"O campo '#1' não foi preenchido." ##'Todos os campos relacionados a Honorarios devem ser preenchidos'
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J033ValCpo()
Valida Campos

@author Luciano Pereira dos Santos
@since 12/11/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function J033ValCpo()
Local oModel    := FwModelActive()
Local lRetFun   := .T.
Local aArea     := GetArea()
Local aAreNUH   := NUH->(GetArea())
Local aAreNT0   := NT0->(GetArea())
Local cGrupoNVV := oModel:GetValue("NVVMASTERCAB", "NVV_CGRUPO")
Local cClienNVV := oModel:GetValue("NVVMASTERCAB", "NVV_CCLIEN")
Local cLojaNVV  := oModel:GetValue("NVVMASTERCAB", "NVV_CLOJA")
Local cClienNVW := oModel:GetValue("NVWDETAIL", "NVW_CCLIEN")
Local cLojaNVW  := oModel:GetValue("NVWDETAIL", "NVW_CLOJA")
Local cCasoNVW  := oModel:GetValue("NVWDETAIL", "NVW_CCASO")
Local cContrat  := ""
Local cCampo    := AllTrim(__ReadVar)

	//NVV
	If cCampo == 'M->NVV_CLOJA'
		lRetFun := JurVldCli(cGrupoNVV, cClienNVV, cLojaNVV,,, "LOJ")

	ElseIf cCampo == 'M->NVV_CCLIEN'
		lRetFun := JurVldCli(cGrupoNVV, cClienNVV, cLojaNVV,,, "CLI")

	ElseIf cCampo == 'M->NVV_CGRUPO'
		lRetFun := JurVldCli(cGrupoNVV, cClienNVV, cLojaNVV,,, "GRP")

	ElseIf cCampo == 'M->NVV_CCONTR'
		cContrat := oModel:GetValue('NVVMASTERCAB','NVV_CCONTR')

		NT0->(DbSetOrder(1))
		If NT0->(DbSeek(xFilial("NT0") + cContrat) )
			If !Empty(cClienNVV) .And. !Empty(cLojaNVV)
				If (NT0->(NT0_CCLIEN) != cClienNVV) .OR. (NT0->(NT0_CLOJA) != cLojaNVV)
					lRetFun := JurMsgErro(STR0038) //"O contrato informado possui cliente e loja diferente do informado na fatura adicional!"
				EndIf
			EndIf

			If lRetFun .And. NT0->NT0_ATIVO == '2'
				lRetFun := JurMsgErro(STR0075,,STR0076) // "Contrato informado está inativo." "Informe um contrato válido."
			EndIf

			If lRetFun .And. NT0->NT0_SIT == '1'
				lRetFun := JurMsgErro(STR0077,,STR0076) // "Contrato informado está como provisório." "Informe um contrato válido."
			EndIf
		Else
			lRetFun := JurMsgErro(I18N(STR0066, {cContrat}),; //"Não existe registro relacionado a este código de Contrato '#1'!"
			                      "J033ValCpo()",;
			                      STR0067)//"Informe um código de Contrato valido."
		EndIf

	ElseIf cCampo == 'M->NVV_CPART1'
		lRetFun := J33RgBloq('NVV_CPART1',1) // Valida se o registro esta bloqueado atraves de ???_MSBLQL

	ElseIf cCampo == 'M->NVV_SIGLA1'
		lRetFun := J33RgBloq('NVV_SIGLA1',9) // Valida se o registro esta bloqueado atraves de ???_MSBLQL

	ElseIf cCampo == 'M->NVV_TPRAT'
		lRetFun := J033RecGrd(oModel)[10]

	ElseIf cCampo == 'M->NVV_DSPCAS'
		If oModel:GetValue('NVVMASTERCAB', 'NVV_DSPCAS') == '1'
			lRetFun := oModel:LoadValue('NVVMASTERCAB','NVV_TRADSP','1')
		EndIf

	//NVW
	ElseIf cCampo == 'M->NVW_CCLIEN'
		lRetFun := JurVldCli( , cClienNVW, cLojaNVW, cCasoNVW,, "CLI")

	ElseIf cCampo == 'M->NVW_CLOJA'
		lRetFun := JurVldCli( , cClienNVW, cLojaNVW, cCasoNVW,,"LOJ")

	ElseIf cCampo == 'M->NVW_CCASO'
		lRetFun := JurVldCli( , cClienNVW, cLojaNVW, cCasoNVW,,"CAS")
	EndIf

	If cCampo $ 'M->NVV_VALORD|M->NVV_VALORH|M->NVV_VALORT|M->NVV_VALDTR'
		lRetFun := J033RecGrd(oModel)[10]
	EndIf

	If cCampo $ 'M->NVW_VALORD|M->NVW_VALORH|M->NVW_VALORT|M->NVW_VALDTR'
		lRetFun := J033RecGrd(oModel)[10]
	EndIf

RestArea( aAreNT0)
RestArea( aAreNUH)
RestArea( aArea )

Return lRetFun

//-------------------------------------------------------------------
/*/{Protheus.doc} J033IniCpo
Inicializacao dos Campos

@author TOTVS
@since --/--/--
@version 1.0
/*/
//-------------------------------------------------------------------
Function J033IniCpo(cCpoRef)
Local oModel    := FWModelActive()
Local cModelID  := oModel:GetID()
Local xVlrCpo   := ''

Default cCpoRef := ''

If cModelID ==  'JURA033' //Só validar na rotina de Fat. Adicional
	//NVW
	If cCpoRef == 'NVW_DCASO'
		xVlrCpo := JurGetDados('NVE', 1, xFilial('NVE') + NVW->(NVW_CCLIEN + NVW_CLOJA + NVW_CCASO), 'NVE_TITULO')
	EndIf
EndIf

Return xVlrCpo

//-------------------------------------------------------------------
/*/{Protheus.doc} J033FCliV
Filtro Cliente NVV

@author TOTVS
@since --/--/--
@version 1.0
/*/
//-------------------------------------------------------------------
Function J033FCliV()
Local cRet := "@#@#"

If !Empty(FWfldGet("NVV_CGRUPO"))
	cRet := "@#SA1->A1_GRPVEN == '" + FWfldGet("NVV_CGRUPO") + "'@#"
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J033FCliW
Filtro Cliente NVW

@author TOTVS
@since --/--/--
@version 1.0
/*/
//-------------------------------------------------------------------
Function J033FCliW()
Local cRet   := "@#@#"
Local oModel

oModel := FWModelActive()

If ! Empty(oModel:GetValue('NVVMASTERCAB', 'NVV_CGRUPO'))
	cRet := "@#SA1->A1_GRPVEN == '" + oModel:GetValue('NVVMASTERCAB', 'NVV_CGRUPO') + "'@#"
Else
	cRet := "@#SA1->A1_COD == '" + oModel:GetValue('NVVMASTERCAB', 'NVV_CCLIEN') + "' .AND. SA1->A1_LOJA == '" + oModel:GetValue('NVVMASTERCAB', 'NVV_CLOJA') + "'@#"
Endif

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J033FCasW
Filtro Caso NVW

@author TOTVS
@since --/--/--
@version 1.0
/*/
//-------------------------------------------------------------------
Function J033FCasW()
Local cRet := "@#@#"

If GetMV('MV_JCASO1') == '1' .And. Empty(FwFldGet('NVV_CCLIEN'))
	cRet := "@#'1'=='2'@#"
Else

	If !Empty(FwFldGet('NVW_CCLIEN')) .OR. !Empty(FwFldGet('NVW_CLOJA'))
		cRet := "@#NVE->NVE_CCLIEN == '" + FwFldGet('NVW_CCLIEN') + "' .AND. NVE->NVE_LCLIEN == '" + FwFldGet('NVW_CLOJA') + "'@#"

	ElseIf !Empty(FwFldGet('NVV_CCLIEN')) .OR. !Empty(FwFldGet('NVV_CLOJA'))
		cRet := "@#NVE->NVE_CCLIEN == '" + FwFldGet('NVV_CCLIEN') + "' .AND. NVE->NVE_LCLIEN == '" + FwFldGet('NVV_CLOJA') + "'@#"

	ElseIf !Empty(FwFldGet('NVV_CGRUPO'))
		cRet := "@#NVE->NVE_CGRPCL == '" + FwFldGet('NVV_CGRUPO') + "'@#"

	Else
		cRet := "@#@#"
	EndIf
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA033QRY
Monta a query de Contratos que podem ser exibidos pela consulta padrão ou
podem ser permitidos na digitação na Junção de Contratos

@Param cAliasF3   Tabela de pesquisa

@Return cQuery    Query montada

@author Jacques Alves Xavier
@since 22/01/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA033QRY(cAliasF3)
Local cQuery := ''
Local oModel := Nil

oModel := FWModelActive()

If cAliasF3 == 'NT0'
	cQuery := "SELECT NT0.NT0_COD, NT0.NT0_NOME, NT0.NT0_CGRPCL, NT0.NT0_CCLIEN, NT0.NT0_CLOJA, NT0.R_E_C_N_O_  NT0RECNO "
	cQuery +=       " FROM "+RetSqlName("NT0")+" NT0 "
	cQuery +=       " WHERE NT0.D_E_L_E_T_ = ' ' "
	cQuery +=         " AND NT0.NT0_FILIAL = '" + xFilial( "NT0" ) + "' "
	If !Empty(oModel:GetValue("NVVMASTERCAB","NVV_CGRUPO"))
		cQuery +=     " AND NT0.NT0_CGRPCL = '"  + M->NVV_CGRUPO + "' "
	ElseIf !Empty(oModel:GetValue("NVVMASTERCAB","NVV_CCLIEN"))
		cQuery +=     " AND NT0.NT0_CCLIEN = '"  + M->NVV_CCLIEN + "' "
		cQuery +=     " AND NT0.NT0_CLOJA = '"  + M->NVV_CLOJA + "' "
	EndIf
EndIf

If cAliasF3 == 'SA1'
	cQuery := "SELECT SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA1.A1_GRPVEN, SA1.R_E_C_N_O_  SA1RECNO "
	cQuery +=       " FROM "+RetSqlName("SA1")+" SA1 "
	cQuery +=       " WHERE SA1.D_E_L_E_T_ = ' ' "
	cQuery +=         " AND SA1.A1_FILIAL = '" + xFilial( "SA1" ) + "' "
	If !Empty(oModel:GetValue("NVVMASTERCAB","NVV_CGRUPO"))
		cQuery +=     " AND SA1.A1_GRPVEN = '"  + M->NVV_CGRUPO + "' "
	Else
		cQuery +=     " AND SA1.A1_COD = '"  + M->NVV_CCLIEN + "' "
	EndIf
EndIf

If cAliasF3 == 'NVE'
	cQuery := " SELECT NVE_CCLIEN, NVE_CCLIEN, NVE_NUMCAS, NVE.R_E_C_N_O_  NVERECNO "
	cQuery +=       " FROM "+RetSqlName("NVE")+" NVE "
	cQuery +=       " WHERE NVE.D_E_L_E_T_ = ' ' "
	cQuery +=         " AND NVE.NVE_FILIAL = '" + xFilial( "NVE" ) + "' "
	cQuery +=         " AND NVE.NVE_CCLIEN = '"  + FwFldGet('NVW_CCLIEN') + "' "
	cQuery +=         " AND NVE.NVE_LCLIEN = '"  + FwFldGet('NVW_CLOJA') + "' "
EndIf

If 'NUT' $ cAliasF3
	If cAliasF3 == 'NUT1'
		cQuery := "SELECT COUNT(*) QTDE "
	Else
		cQuery := "SELECT NUT_CCONTR, NUT_CCLIEN, NUT_CLOJA, NUT_CCASO "
	EndIf
	cQuery +=       " FROM "+RetSqlName("NUT")+" NUT "
	cQuery +=       " WHERE NUT.D_E_L_E_T_ = ' ' "
	cQuery +=         " AND NUT.NUT_FILIAL = '" + xFilial( "NUT" ) + "' "
	cQuery +=         " AND NUT.NUT_CCONTR = '" + FwFldGet('NVV_CCONTR') + "' "
EndIf

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JA033F3NT0
Monta a consulta padrão de Contratos com base no grupo de cliente ou cliente/loja
Uso Geral.

@Return lRet	 	.T./.F. As informações são válidas ou não
@sample
Consulta padrão específica RD0ATV

@author Jacques Alves Xavier
@since 19/01/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA033F3NT0()
Local cRet     := "@#@#"
Local aArea    := GetArea()
Local aAreaNT0 := NT0->( GetArea() )
Local oModel   := FWModelActive()

If !Empty(oModel:GetValue("NVVMASTERCAB","NVV_CGRUPO"))
	cRet := "@#NT0->NT0_CGRPCL == '"+M->NVV_CGRUPO+"'@#"
ElseIf !Empty(oModel:GetValue("NVVMASTERCAB","NVV_CCLIEN"))
	cRet := "@#NT0->NT0_CCLIEN == '" + M->NVV_CCLIEN + "' .AND. NT0->NT0_CLOJA == '" + M->NVV_CLOJA+ "'@#"
EndIf

RestArea(aAreaNT0)
RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JU033VG
Verifica se o valor do campo de contrato é válido quando o mesmo o digita no campo
Uso Geral.

@param 	cMaster  	Fields ou Grid a ser verificado
@Return cCampo	  Campo de contrato a ser verificado
@Return lRet	 	  .T./.F. As informações são válidas ou não

@sample
ExistChav("NVV",M->NVV_CCONTR,2).AND.ExistCpo('NT0',M->NVV_CCONTR,1).AND.JU033VG('NVVMASTERCAB','NVV_CCONTR')

@author Jacques Alves Xavier
@since 22/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JU033VG(cMaster, cCampo, cTipo)
Local lRet     := .F.
Local aArea    := GetArea()
Local cQuery   := JA033QRY('NT0')
Local cAlias   := GetNextAlias()
Local oModel   := FWModelActive()

cQuery := ChangeQuery(cQuery)

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAlias, .T., .T.)

(cAlias)->( dbSelectArea( cAlias ) )
(cAlias)->( dbGoTop() )

While !(cAlias)->( EOF() )
	If (cAlias)->NT0_COD == oModel:GetValue(cMaster, cCampo)
		lRet := .T.
		Exit
	EndIf
	(cAlias)->( dbSkip() )
EndDo

If !lRet .And. !Empty(oModel:GetValue('NVVMASTERCAB', 'NVV_CGRUPO')) .And. !Empty(oModel:GetValue('NVVMASTERCAB', 'NVV_CCLIEN'))
	JurMsgErro(STR0022) // Não é possível vincular este contrato para o Grupo ou Cliente/Loja preenchido. Verifique!
EndIf

(cAlias)->( dbcloseArea() )
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JU033VC
Verifica se o valor do campo de cliente é válido quando o mesmo o digita no campo
Uso Geral.

@param 	cMaster  	Fields ou Grid a ser verificado
@Return cCampo	  Cliente a ser verificado
@Return lRet	 	  .T./.F. As informações são válidas ou não

@sample
ExistChav("NVW",M->NVW_CCLIEN,2).AND.ExistCpo('SA1',M->NVW_CCLIEN,1).AND.JU033VC('NVWDETAIL','NVW_CCLIEN')

@author Jacques Alves Xavier
@since 22/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JU033VC(cMaster, cCampo, cTipo)
Local lRet     := .F.
Local aArea    := GetArea()
Local cQuery   := JA033QRY('SA1')
Local cAlias   := GetNextAlias()
Local oModel   := FWModelActive()

cQuery := ChangeQuery(cQuery)

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAlias, .T., .T.)

(cAlias)->( dbSelectArea( cAlias ) )
(cAlias)->( dbGoTop() )

While !(cAlias)->( EOF() )
	If (cAlias)->A1_COD == IIf(cTipo == '1', cCampo, oModel:GetValue(cMaster, cCampo))
		lRet := .T.
		Exit
	EndIf
	(cAlias)->( dbSkip() )
EndDo

If !lRet
	JurMsgErro(STR0023) // Grupo ou Cliente/Loja não confere com o digitado no cabeçalho. Verifique!
EndIf

(cAlias)->( dbcloseArea() )
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JU033VCS
Verifica se o valor do campo de caso é válido quando o mesmo o digita no campo
Uso Geral.

@param 	cMaster  	Fields ou Grid a ser verificado
@Return cCampo	  Campo de contrato a ser verificado
@Return lRet	 	  .T./.F. As informações são válidas ou não

@sample
(Vazio().Or.J033ValCpo()).And.ExistChav('NVW',M->NVV_COD+JurMVal({'NVW_CCLIEN','NVW_CLOJA','NVW_CCASO'})).AND.JU033VCS('NVWDETAIL','NVW_CCASO')

@author Jacques Alves Xavier
@since 22/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JU033VCS(cMaster, cCampo, cTipo)
Local lRet     := .F.
Local aArea    := GetArea()
Local cQuery   := JA033QRY('NVE')
Local cAlias   := GetNextAlias()
Local oModel   := FWModelActive()

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

(cAlias)->( dbSelectArea( cAlias ) )
(cAlias)->( dbGoTop() )

While !(cAlias)->( EOF() )
	If (cAlias)->NVE_NUMCAS == oModel:GetValue(cMaster,cCampo)
		lRet := .T.
		Exit
	EndIf
	(cAlias)->( dbSkip() )
EndDo

If !lRet
	JurMsgErro(STR0024) // "Caso não confere com o cliente digitado. Verifique!"
EndIf

(cAlias)->( dbcloseArea() )
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA033OK
Tudo OK do Model

@author Fabio Crespo Arruda
@since 29/05/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA033VE(oModel)
Local lRet     := .T.
Local aArea    := GetArea()
Local aAreaNWD := NWD->( GetArea() )

If oModel:GetOperation() == MODEL_OPERATION_DELETE

	NWD->( dbSetOrder(1) )
	NWD->( dbSeek(xFilial("NVW") + NVV->NVV_COD) )

	While !NWD->( EOF() ) .And. xFilial("NVW") + NWD->NWD_CFTADC == xFilial("NVV") + NVV->NVV_COD

		If NWD->NWD_SITUAC == "2" .Or. NWD->NWD_SITUAC == "3"
			lRet := .F.
			Exit
		EndIf

		NWD->( dbSkip() )

	EndDo

EndIf

RestArea(aAreaNWD)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA033VERPRE(oModel, lAlteraPre)
Rotina para validar se exite pré-fatura para a fatura adicional

@Param lAlteraPre - Verifica se a pré-fatura vinculada a fatura adicional deve ser alterada a situação ou cancelada no Commit.

@author Fabio Crespo Arruda
@since 07/06/10

@version 1.0
/*/
//-------------------------------------------------------------------
Function JA033VERPRE(oModel, lAlteraPre)
Local lRet       := .T.
Local cPreFat    := oModel:GetValue('NVVMASTERCAB', 'NVV_CPREFT')
Local cPartLog   := JurUsuario(__CUSERID)
Local cLCPRE     := Posicione("NUR", 1, xFilial("NUR") + cPartLog, "NUR_LCPRE")
Local aRet       := {}

If cLCPRE == '1'
	If NX0->(dbSeek(xFilial('NX0') + cPreFat))
		If NX0->NX0_SITUAC $ '2|3|D|E'
			lAlteraPre := .T.
		ElseIf NX0->NX0_SITUAC == '6'
			lRet := J33VerAltM(oModel:GetModel('NVVMASTERCAB'))
			If (!lRet)
				lRet := JurMsgErro(STR0064) // "Não foi possível realizar as alterações, o lançamento possui minuta!"
			EndIf
		ElseIf NX0->NX0_SITUAC $ '5|7|9|A|B' //Emitir Minuta | Minuta Emitida | Minuta Cancelada | Minuta Sócio | Minuta Sócio Emitida | Minuta Sócio Cancelada
			lRet := JurMsgErro(STR0064) // "Não foi possível realizar as alterações, o lançamento possui minuta!"

		ElseIf NX0->NX0_SITUAC == '4' //'Definitivo'
			lRet := JurMsgErro(STR0065) // "Não foi possível realizar as alterações, o lançamento possui pré-fatura em Definifivo!"

		ElseIf NX0->NX0_SITUAC $ 'C|F' // Em Revisão | Aguardando Sincronização
			lRet := JurMsgErro(STR0063) // "Não foi possível realizar as alterações, o lançamento possui pré-fatura em processo de Revisão!"
		EndIf
	EndIf
Else
	lRet := JurMsgErro(STR0027,, I18n(STR0071, cPartLog)) // "Não foi possível realizar as alterações, o lançamento possui pré-fatura!" , "Verifique as permissões de acesso no usuário '#1'."
EndIf

aRet := {lRet, lAlteraPre}

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} J33VerAltM(oModelNVV)
Verifica os campos que foram alterados

@param oModelNVV - Modelo da Fatura Adicional

@author Willian Kazahaya
@since 26/01/2022
/*/
//-------------------------------------------------------------------
Static Function J33VerAltM(oModelNVV)
Return JVldAltMdl(oModelNVV, 1, {"NVV_DESREL", "NVV_DESCRT"})

//-------------------------------------------------------------------
/*/{Protheus.doc} J033VLDCP
Rotina para validar se a conta corrente está ativa

@author David Fernandes
@since 29/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function J033VLDCP(cCampo)
Local lRet   := .T.

If cCampo == 'NVV_CCONTA'
	If !Empty(FwFldGet("NVV_CBANCO")) .AND. !Empty(FwFldGet("NVV_CAGENC")) .AND. !Empty(FwFldGet("NVV_CCONTA"))
		If !(Posicione("SA6", 1, xFilial("SA6") + FwFldGet("NVV_CBANCO") + FwFldGet("NVV_CAGENC") + FwFldGet("NVV_CCONTA"), "A6_BLOCKED") == "2")
			lRet := JurMsgErro(STR0028) // "Esta conta esta bloqueada!"
		EndIf
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J033CASOS
Rotina para sugerir os casos do contrato

@author Jacques Alves Xavier
@since 14/09/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J033CASOS(oView)
Local aArea      := GetArea()
Local nConLin    := 0
Local oModel     := oView:GetModel()
Local oModNVWDet := oModel:GetModel('NVWDETAIL')
Local nLinAnt    := oModNVWDet:GetLine()
Local cQuery     := ""
Local cQryRes    := GetNextAlias()
Local lRet       := .T.
Local lInclui    := .T.

If !Empty(FwFldGet("NVV_CCONTR"))

	If FwFldGet("NVV_SITUAC") == '1'

		cQuery := JA033QRY('NUT1')

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cQryRes, .T., .T.)

		(cQryRes)->( dbSelectArea( cQryRes ) )
		(cQryRes)->( dbGoTop() )

		If !(cQryRes)->QTDE > 0
			ApMsgInfo(STR0032 + FwFldGet("NVV_CCONTR")) //  "Não existem casos vinculados ao contrato: "
			lRet := .F.
		EndIf

		(cQryRes)->( dbcloseArea() )

		If lRet

			If ApMsgYesNo(I18N(STR0029, {FwFldGet("NVV_CCONTR")})) //"Deseja vincular os casos do contrato #1 na parcela de fatura adicional?"

				If !oModNVWDet:IsEmpty() .And. ApMsgYesNo(STR0030) //"Deseja apagar os caso(s) atualmente vinculado(s)?"
					For nConLin := 1 To oModNVWDet:GetQtdLine()
						oModNVWDet:GoLine(nConLin)
						If !oModNVWDet:IsDeleted()
							oModNVWDet:DeleteLine()
						EndIf
					Next
					oModNVWDet:GoLine(nLinAnt)
				EndIf

				oModNVWDet := oModel:GetModel('NVWDETAIL')

				cQuery := JA033QRY('NUT2')

				cQuery := ChangeQuery(cQuery)

				dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cQryRes, .T., .T.)

				(cQryRes)->( dbSelectArea( cQryRes ) )
				(cQryRes)->( dbGoTop() )

				While !(cQryRes)->( EOF() )

					If !oModNVWDet:IsEmpty()
						For nConLin := 1 To oModNVWDet:GetQtdLine()
							If !oModNVWDet:IsDeleted(nConLin) .And. ;
									oModNVWDet:GetValue("NVW_CCLIEN", nConLin)  == (cQryRes)->NUT_CCLIEN .And.;
									oModNVWDet:GetValue("NVW_CLOJA" , nConLin)  == (cQryRes)->NUT_CLOJA .And.;
									oModNVWDet:GetValue("NVW_CCASO" , nConLin)  == (cQryRes)->NUT_CCASO
								lInclui := .F.
								Exit
							EndIf
						Next
					Else
						lInclui := .T.
					EndIf

					If lInclui
						If !oModNVWDet:IsEmpty()
							oModNVWDet:AddLine()
						EndIf

						oModel:LoadValue("NVWDETAIL", "NVW_CCLIEN", (cQryRes)->NUT_CCLIEN)
						oModel:LoadValue("NVWDETAIL", "NVW_CLOJA", (cQryRes)->NUT_CLOJA)
						oModel:LoadValue("NVWDETAIL", "NVW_DCLIEN", Posicione('SA1', 1, xFilial('SA1') + (cQryRes)->NUT_CCLIEN + (cQryRes)->NUT_CLOJA, 'A1_NOME'))
						oModel:LoadValue("NVWDETAIL", "NVW_CCASO", (cQryRes)->NUT_CCASO)
						oModel:LoadValue("NVWDETAIL", "NVW_DCASO", Posicione('NVE', 1, xFilial('NVE') + (cQryRes)->NUT_CCLIEN + (cQryRes)->NUT_CLOJA + (cQryRes)->NUT_CCASO, 'NVE_TITULO'))
					EndIf

					lInclui := .T.
					(cQryRes)->( dbSkip() )
				EndDo

				oModNVWDet:GoLine(nLinAnt)
				(cQryRes)->( dbcloseArea() )
			EndIf
		EndIf
	Else
		ApMsgInfo(STR0033) // "Não é possível alterar parcela de fatura adicional faturada!"
	EndIf
Else
	ApMsgInfo(STR0031) // "Favor especificar um contrato para referência!"
EndIf

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JA33Sald
Preenche os saldos na inicialização padrão dos campos

@Return cCampo  Campo de saldo
@Return nValor  Valor do saldo

@author Juliana Iwayama Velho
@since 08/12/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA33Sald(cCampo)
Local oModel
Local oModNVVCab
Local oModNVWDet

Local nRefDes
Local nRefHon
Local nRefTab
Local nRefTri

Local nConLin := 0
Local nVlrDes := 0
Local nVlrTri := 0
Local nVlrHon := 0
Local nVlrTab := 0
Local nValor  := 0

Local nLinAnt
Local lProtNvvVal := .F. //Protecao
Local lProtNvwVal := .F. //Protecao


If IsInCallStack( 'JURA033' )

	oModel     := FwModelActive()
	oModNVVCab := oModel:GetModel('NVVMASTERCAB')
	oModNVWDet := oModel:GetModel('NVWDETAIL')

	lProtNvvVal := oModNVVCab:HasField( "NVV_VALDTR" ) //Protecao
	lProtNvwVal := oModNVWDet:HasField( "NVW_VALDTR" ) //Protecao

	nRefDes := IIf(oModNVVCab:GetValue('NVV_TPRAT') == '1', oModNVVCab:GetValue('NVV_VALORD'), IIf(oModNVVCab:GetValue('NVV_VALORD') > 0, 100, 0))
	If lProtNvvVal  //proteção
		nRefTri := IIf(oModNVVCab:GetValue('NVV_TPRAT') == '1', oModNVVCab:GetValue('NVV_VALDTR'), IIf(oModNVVCab:GetValue('NVV_VALDTR') > 0, 100, 0))
	EndIf
	nRefHon := IIf(oModNVVCab:GetValue('NVV_TPRAT') == '1', oModNVVCab:GetValue('NVV_VALORH'), IIf(oModNVVCab:GetValue('NVV_VALORH') > 0, 100, 0))
	nRefTab := IIf(oModNVVCab:GetValue('NVV_TPRAT') == '1', oModNVVCab:GetValue('NVV_VALORT'), IIf(oModNVVCab:GetValue('NVV_VALORT') > 0, 100, 0))

	nLinAnt := oModNVWDet:GetLine()
	For nConLin := 1 To oModNVWDet:GetQtdLine()
		If !oModNVWDet:IsDeleted(nConLin) .And. !Empty(oModNVWDet:GetValue('NVW_CCASO', nConLin))
			nVlrDes += oModNVWDet:GetValue('NVW_VALORD', nConLin)
			If lProtNvwVal  //proteção
				nVlrTri += oModNVWDet:GetValue('NVW_VALDTR', nConLin)
			EndIf
			nVlrHon += oModNVWDet:GetValue('NVW_VALORH', nConLin)
			nVlrTab += oModNVWDet:GetValue('NVW_VALORT', nConLin)
		EndIf

	Next

	If oModel:GetOperation() == 4
		If cCampo = 'NVV_SALDOD'
			nValor := Round(IIf(nRefDes - nVlrDes < 0, 0, nRefDes - nVlrDes), TamSX3("NVV_SALDOD")[2])
		ElseIf cCampo = 'NVV_SALDTR'
			If lProtNvvVal
				nValor := Round(IIf(nRefTri - nVlrTri < 0, 0, nRefTri - nVlrTri), TamSX3("NVV_SALDTR")[2])
			EndIf
		ElseIf cCampo = 'NVV_SALDOH'
			nValor := Round(IIf(nRefHon - nVlrHon < 0, 0, nRefHon - nVlrHon), TamSX3("NVV_SALDOH")[2])
		ElseIf cCampo = 'NVV_SALDOT'
			nValor := Round(IIf(nRefTab - nVlrTab < 0, 0, nRefTab - nVlrTab), TamSX3("NVV_SALDOT")[2])
		EndIf
	EndIf

	oModNVWDet:GoLine(nLinAnt)

EndIf

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} J033QRY
Cadastro de Faturas Adicionais

@author TOTVS
@since --/--/--
@version 1.0
/*/
//-------------------------------------------------------------------
Function J033QRY(cAliasF3)
Local cQuery := ''
Local oModel := Nil

oModel := FWModelActive()

If cAliasF3 == 'NT0'
	cQuery := "SELECT NT0.NT0_COD, NT0.NT0_NOME, NT0.NT0_CGRPCL, NT0.NT0_CCLIEN, NT0.NT0_CLOJA, NT0.R_E_C_N_O_ NT0RECNO "
	cQuery +=        " FROM " + RetSqlName("NT0") + " NT0 "
	cQuery +=        " WHERE NT0.D_E_L_E_T_ = ' ' "
	cQuery +=          " AND NT0.NT0_FILIAL = '" + xFilial( "NT0" ) + "' "
	If !Empty(oModel:GetValue("NVVMASTERCAB", "NVV_CGRUPO"))
		cQuery +=      " AND NT0.NT0_CGRPCL = '" + M->NVV_CGRUPO + "' "
	ElseIf !Empty(oModel:GetValue("NVVMASTERCAB", "NVV_CCLIEN"))
		cQuery +=      " AND NT0.NT0_CCLIEN = '" + M->NVV_CCLIENT + "' "
		cQuery +=      " AND NT0.NT0_CLOJA = '" + M->NVV_CLOJA + "' "
	EndIf
EndIf

If cAliasF3 == 'SA1'
	cQuery := "SELECT SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA1.A1_GRPVEN, SA1.R_E_C_N_O_ SA1RECNO "
	cQuery +=        " FROM " + RetSqlName("SA1") + " SA1 "
	cQuery +=        " WHERE SA1.D_E_L_E_T_ = ' ' "
	cQuery +=          " AND SA1.A1_FILIAL = '" + xFilial( "SA1" ) + "' "
	If !Empty(oModel:GetValue("NVVMASTERCAB", "NVV_CGRUPO"))
		cQuery +=      " AND SA1.A1_GRPVEN = '" + M->NVV_CGRUPO + "' "
	Else
		cQuery +=      " AND SA1.A1_COD = '" + M->NVV_CCLIEN + "' "
	EndIf
EndIf

If cAliasF3 == 'NVE'
	cQuery := "SELECT NVE_CCLIEN, NVE_CCLIEN, NVE_NUMCAS, NVE.R_E_C_N_O_ NVERECNO "
	cQuery +=        " FROM " + RetSqlName("NVE") + " NVE "
	cQuery +=        " WHERE NVE.D_E_L_E_T_ = ' ' "
	cQuery +=          " AND NVE.NVE_FILIAL = '" + xFilial( "NVE" ) + "' "
	cQuery +=          " AND NVE.NVE_CCLIEN = '" + FwFldGet('NVW_CCLIEN') + "' "
	cQuery +=          " AND NVE.NVE_LCLIEN = '" + FwFldGet('NVW_CLOJA') + "' "
EndIf

If 'NUT' $ cAliasF3
	If cAliasF3 == 'NUT1'
		cQuery := "SELECT COUNT(*) QTDE "
	Else
		cQuery := "SELECT NUT_CCONTR, NUT_CCLIEN, NUT_CLOJA, NUT_CCASO "
	EndIf
	cQuery +=        " FROM " + RetSqlName("NUT") + " NUT "
	cQuery +=        " WHERE NUT.D_E_L_E_T_ = ' ' "
	cQuery +=          " AND NUT.NUT_FILIAL = '" + xFilial( "NUT" ) + "' "
	cQuery +=          " AND NUT.NUT_CCONTR = '" + FwFldGet('NVV_CCONTR') + "' "
EndIf

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} J033When
Regra de Preenchimento de Campos.

@author Clóvis Eduardo Teixeira
@since 02/06/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J033When()
Local lRet   := .T.
Local oModel := FwModelActive()

	If lRet .And. (oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4)
		 If Empty(oModel:GetValue("NVVMASTERCAB", "NVV_CCLIEN")) .Or. Empty(oModel:GetValue("NVVMASTERCAB", "NVV_CLOJA"))
			lRet := .F.
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J33CliFil()
Valida se os campos de Cliente ou Loja estão em brancos

@author Rafael Rezende Costa
@since 14/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function J33CliFil()
Local lRet   := .T.
Local oModel := FwModelActive()

	If (oModel:cID == 'JURA033')
		If Empty(oModel:GetValue("NVVMASTERCAB", "NVV_CCLIEN")) .Or. Empty(oModel:GetValue("NVVMASTERCAB", "NVV_CLOJA"))
			lRet := .F.
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J33RgBloq()
Função para verificar se o registro esta bloqueado ou não atraves
do "???_MSBLQL"

Sample: RegistroOk(cAlias,lMostraHelp, nPblql, nPblqd)
nPblql Posicao do campo  ???_MSBLQL caso não seja o padrão
nPblqd Posicao do campo ???_MSBLQD caso não seja o padrão

@author Rafael Rezende Costa
@since 11/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function J33RgBloq(cCampo,nOrdem)
Local lRet     := .T.
Local aArea    := GetArea()

Default cCampo := ''
Default nOrdem := 1

	If cCampo <> ''
		RD0->( DBSetOrder(nOrdem) )
		IF RD0->( dbSeek( xFilial( 'RD0' ) + FwFldGet(cCampo) ) )
			If !(RegistroOk('RD0', .F.))
				lRet := JurMsgErro(I18N(STR0059, {RetTitle(cCampo)}), RetTitle(cCampo))//"O participante informado no campo '#1' esta inativo!"
			EndIf
		Else
			lRet := JurMsgErro(STR0060, RetTitle(cCampo)) //"Não existe registro relacionado a este código!"
		EndIf
	EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J033VldPar()
Função para verificar se o paricipante do contrato esta bloqueado no
gatilho do contrato "NVV_CCONTR"

@author Luciano Pereira dos Santos
@since 26/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function J033VldPar()
Local lRet   := .T.
Local aArea  := GetArea()
Local cPart  := JurGetDados("NT0", 1, xFilial("NT0") + M->NVV_CCONTR, "NT0_CPART1")

If !Empty(cPart)
	RD0->(DbSetOrder(1) )
	If RD0->(DbSeek( xFilial( 'RD0' ) + cPart ))
		lRet := RegistroOk('RD0', .F.)
	Else
		lRet := .F.
	EndIf

	If !lRet
		ApMsgAlert(STR0061, RetTitle("NVV_SIGLA1")) //"O participante do contrato informado é inválido ou esta inativo!"
	EndIf
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J033Atual()
Rotina para atualizar o saldo a partir da pré-validação da linha.

@author Luciano Pereira dos Santos
@since 28/08/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J033Atual(oModelGrid,nLine, cAction)
Local lRet        := .T.
Local oModel      := FWModelActive()
Local oModNVVCab  := oModel:GetModel('NVVMASTERCAB')
Local oModNVWDet  := oModelGrid

Local nRefDes     := IIf(oModNVVCab:GetValue('NVV_TPRAT') == '1', oModNVVCab:GetValue('NVV_VALORD'), IIf(oModNVVCab:GetValue('NVV_VALORD') > 0, 100, 0))
Local nRefHon     := IIf(oModNVVCab:GetValue('NVV_TPRAT') == '1', oModNVVCab:GetValue('NVV_VALORH'), IIf(oModNVVCab:GetValue('NVV_VALORH') > 0, 100, 0))
Local nRefTab     := IIf(oModNVVCab:GetValue('NVV_TPRAT') == '1', oModNVVCab:GetValue('NVV_VALORT'), IIf(oModNVVCab:GetValue('NVV_VALORT') > 0, 100, 0))

Local nRefTri     := 0
Local nConLin     := 0
Local nVlrDes     := 0
Local nVlrTri     := 0
Local nVlrHon     := 0
Local nVlrTab     := 0

Local nLinAnt     := oModNVWDet:GetLine()
Local lProtNvvVal := oModNVVCab:HasField( "NVV_VALDTR" ) //Protecao
Local lProtNvwVal := oModNVWDet:HasField( "NVW_VALDTR" ) //Protecao

Default cAction   := ''
Default nLine     := 0

If lProtNvvVal
	nRefTri := IIf(oModNVVCab:GetValue('NVV_TPRAT') == '1', oModNVVCab:GetValue('NVV_VALDTR'), IIf(oModNVVCab:GetValue('NVV_VALDTR') > 0, 100, 0))
EndIf

For nConLin := 1 To oModNVWDet:GetQtdLine()
	If !Empty(oModNVWDet:GetValue('NVW_CCASO', nConLin)) .And.;
		(!(cAction == 'DELETE' .And. nConLin == nLine .And. !oModNVWDet:IsDeleted(nConLin)) .And.;
		!(nConLin != nLine .And. oModNVWDet:IsDeleted(nConLin))) .Or. (cAction == 'SETVALUE' .And. !oModNVWDet:IsDeleted(nConLin))

		nVlrDes += oModNVWDet:GetValue('NVW_VALORD', nConLin)
		If lProtNvwVal
			nVlrTri += oModNVWDet:GetValue('NVW_VALDTR', nConLin)
		EndIf
		nVlrHon += oModNVWDet:GetValue('NVW_VALORH', nConLin)
		nVlrTab += oModNVWDet:GetValue('NVW_VALORT', nConLin)
	EndIf
Next nConLin

If oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4
	IIF(lRet, lRet := oModel:LoadValue('NVVMASTERROD', 'NVV_SALDOD', Round(nRefDes - nVlrDes, TamSX3('NVV_SALDOD')[2] )), )
	If lProtNvvVal
		IIF(lRet, lRet := oModel:LoadValue('NVVMASTERROD', 'NVV_SALDTR', Round(nRefTri - nVlrTri, TamSX3('NVV_SALDTR')[2] )), )
	EndIf
	IIF(lRet, lRet := oModel:LoadValue('NVVMASTERROD', 'NVV_SALDOH', Round(nRefHon - nVlrHon, TamSX3('NVV_SALDOH')[2] )), )
	IIF(lRet, lRet := oModel:LoadValue('NVVMASTERROD', 'NVV_SALDOT', Round(nRefTab - nVlrTab, TamSX3('NVV_SALDOT')[2] )), )
EndIf

oModNVWDet:GoLine(nLinAnt)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurDSCob
Função para verificar se a despesa é cobrável ou não, considerando o tipo de
despesa, o contrato e o cliente relacionados a ele.

@Param    cCod       Código da despesa a ser verificado se é cobrável ou não
@Param    cCliente   Cliente
@Param    cLoja      Loja do cliente
@Param    cCaso      Caso
@Param    cTpDesp    Código do Tipo de Despesa

@author Cristina Cintra
@since 14/10/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurDSCob(cCod, cCliente, cLoja, cCaso, cTpDesp)
Local lCob     := .T.
Local aArea    := GetArea()
Local cAtNCCli := ""
Local cCobra   := ""

cCobra   := JurGetDados("NRH", 1, xFilial("NRH") + cTpDesp, "NRH_COBRAR") //Verifica se o tipo de despesa é cobrável
cAtNCCli := JurTpDspNC(cCliente, cLoja, cCaso, cTpDesp)                  //Verifica se o tipo de despesa está como não cobrável no contrato

If cCobra == "2" .Or. cAtNCCli == "2"
	lCob := .F.
EndIf

RestArea( aArea )

Return lCob

//-------------------------------------------------------------------
/*/{Protheus.doc}  JurTpDspNC()
Função para retornar se o tipo de despesa é cobrável ou não no contrato
vinculado ao caso.

@author Cristina Cintra
@since 14/10/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurTpDspNC(cCliente, cLoja, cCaso, cTpDesp)
Local cSQL      := ""
Local aTpAtv    := {}
Local cTpDspNC  := ""

	cSQL := " SELECT NTK.NTK_CTPDSP  NTK_CTPDSP "
	cSQL +=   " FROM " + RetSqlName("NUT") +" NUT, "
	cSQL +=        " " + RetSqlName("NT0") +" NT0, "
	cSQL +=        " " + RetSqlName("NTK") +" NTK "
	cSQL +=  " WHERE NUT.NUT_FILIAL = '" + xFilial("NUT") + "' "
	cSQL +=    " AND NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "
	cSQL +=    " AND NTK.NTK_FILIAL = '" + xFilial("NTK") + "' "
	cSQL +=    " AND NUT.NUT_CCONTR = NT0.NT0_COD "
	cSQL +=    " AND NUT.NUT_CCONTR = NTK.NTK_CCONTR "
	cSQL +=    " AND NUT.NUT_CCLIEN = '" + cCliente + "' "
	cSQL +=    " AND NUT.NUT_CLOJA = '" + cLoja + "' "
	cSQL +=    " AND NUT.NUT_CCASO = '" + cCaso + "' "
	cSQL +=    " AND NT0.NT0_DESPES = '1' "
	cSQL +=    " AND NTK.NTK_CTPDSP = '" + cTpDesp + "' "
	cSQL +=    " AND NUT.D_E_L_E_T_ = ' ' "
	cSQL +=    " AND NT0.D_E_L_E_T_ = ' ' "
	cSQL +=    " AND NTK.D_E_L_E_T_ = ' ' "

	aTpAtv := JurSQL(cSQL, {"NTK_CTPDSP"})

	If Empty(aTpAtv)
		cTpDspNC := "1"
	Else
		cTpDspNC := "2"
	EndIf

Return cTpDspNC

//-------------------------------------------------------------------
/*/{Protheus.doc} J033ClxCa()
Rotina para verificar se o cliente/loja pertece ao caso.
Utilizado para condição de gatilho

@Return   lRet  .T. quando o cliente PERTENCE ao caso informado OU
                .F. quando o cliente NÃO pertence ao caso informado

@author Bruno Ritter
@since 30/12/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J033ClxCa()
Local lRet     := .F.
Local oModel   := FWModelActive()
Local cClien   := ""
Local cLoja    := ""
Local cCaso    := ""

cClien    := oModel:GetValue("NVWDETAIL", "NVW_CCLIEN")
cCaso     := oModel:GetValue("NVWDETAIL", "NVW_CCASO")
cLoja     := oModel:GetValue("NVWDETAIL", "NVW_CLOJA")

lRet := JurClxCa(cClien, cLoja, cCaso)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J033ClxGr()
Rotina para verificar se o cliente/loja pertence ao grupo.
Usado nos gatilhos de Grupo

@Return   lRet  .T. quando o cliente PERTENCE ao grupo informado OU
                .F. quando o cliente NÃO pertence ao grupo informado

@author Bruno Ritter
@since 04/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J033ClxGr()
Local lRet    := .T.
Local oModel  := FwModelActive()
Local cClien  := ""
Local cLoja   := ""
Local cGrupo  := ""

	cGrupo  :=  oModel:GetValue("NVVMASTERCAB", "NVV_CGRUPO")
	cClien  :=  oModel:GetValue("NVVMASTERCAB", "NVV_CCLIEN")
	cLoja   :=  oModel:GetValue("NVVMASTERCAB", "NVV_CLOJA")

	lRet := JurClxGr(cClien, cLoja, cGrupo)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J033UpdPre(oModel)
Rotina para atualizar a pré-fatura vinculada à fatura adicional.

@author Bruno Ritter
@since 16/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J033UpdPre(oModel)
Local aArea      := GetArea()
Local cPreFat    := oModel:GetValue('NVVMASTERCAB', 'NVV_CPREFT')
Local cPartLog   := JurUsuario(__CUSERID)
Local cNx0SitAnt := ""
Local nOpc       := oModel:GetOperation()
Local cMsg       := ""
Local cCodFatAdc := oModel:GetValue('NVVMASTERCAB', 'NVV_COD')

If NX0->(dbSeek(xFilial('NX0') + cPreFat))
cNx0SitAnt := NX0->NX0_SITUAC

	If nOpc == MODEL_OPERATION_UPDATE
		RecLock("NX0",.F.)
		NX0->NX0_SITUAC := '3'
		NX0->NX0_USRALT := cPartLog
		NX0->NX0_DTALT  := Date()
		NX0->(MsUnlock())

		If cNx0SitAnt != "3"
			cMsg := I18N(STR0069, {cCodFatAdc}) // "Alteração na fatura adicional '#1'."
			J202HIST('99', cPreFat, cPartLog, cMsg)

			// "A Fatura Adicional estava vinculado à pré-fatura '#1' com situação '#2', a pré-fatura terá o status atualizado para '#3'."
			ApMsgInfo(I18n(STR0073, {cPreFat, JurSitGet(cNx0SitAnt), JurSitGet('3')}))
		EndIf

	ElseIf nOpc == MODEL_OPERATION_DELETE
		//Verifica se há outros lançamentos na pré-fatura para cancelá-la se necessário
		If JurLancPre(cPrefat) <= 1
			If JA202CANPF(cPreFat)
				If oModel:GetId() != 'JURA202' .And. !IsInCallStack("JURA142")
					ApMsgInfo(I18N(STR0072, {cPreFat, JurSitGet(cNx0SitAnt)}))
				Else
					AutoGrLog(I18N(STR0072 + CRLF, {cPreFat, JurSitGet(cNx0SitAnt)}))  //# "O Fatura Adicional estava vinculado à pré-fatura '#1' com situação '#2', a pré-fatura foi cancelada por não conter mais lançamentos."
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J033RecTot()
Rotina para atualizar o saldo da despesa e despesa tributavel.

@author Nivia Ferreira
@since 11/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J033RecTot()
Local oModel := FwModelActive()

J033RecGrd(oModel)

Return(oModel:GetValue("NVVMASTERCAB", "NVV_DSPCAS") )

//-------------------------------------------------------------------
/*/{Protheus.doc} J033NXGPos
Rotina de Pós Validação na linha do pagador.

@param oModelGrid, Grid que está sendo usada
@param nLine     , Linha que está posicionado o grid
@param cAction   , Ação que foi executada

@return lRet     , Indica se o banco pode ser utilizado.

@author Reginaldo Borges
@since  27/07/2021
/*/
//-------------------------------------------------------------------
Function J033NXGPos(oModelGrid, nLine, cAction)
Local lRet       := .T.
Local oModNXGDet := oModelGrid
Local oModel     := FWModelActive()
Local oModNVVCab := oModel:GetModel('NVVMASTERCAB')
Local cEscrit    := oModNVVCab:GetValue("NVV_CESCR ")
Local cBanco     := oModNXGDet:GetValue("NXG_CBANCO")
Local cAgencia   := oModNXGDet:GetValue("NXG_CAGENC")
Local cConta     := oModNXGDet:GetValue("NXG_CCONTA")
Local lJurxFin   := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN

Default cAction  := ''
Default nLine    := 0

	If JurGetDados('SA6', 1, xFilial('SA6') + cBanco + cAgencia + cConta, "A6_BLOCKED") == "1" //Validação de bloqueio de banco
		lRet := JurMsgErro(I18n(STR0079, {cBanco, cAgencia, cConta}), , STR0080) //#"O banco #1, agência #2 e conta #3 está bloqueado." ## "Verifique o cadastro de banco ou selecione outro banco."
	EndIf

	If lRet
		If lJurxFin .And. FWAliasInDic("OHK") // Proteção OHK
			If Empty(JurGetDados("OHK", 1, xFilial("OHK") + cEscrit + cBanco + cAgencia + cConta, "OHK_CESCRI")) //Validação de conta associada ao banco
				lRet := JurMsgErro(I18n(STR0081, {cBanco, cAgencia, cConta, cEscrit}), , STR0082) //# "O banco #1, agência #2 e conta #3 não está associado ao escritório #4." ##"Verifique se o banco está vinculado ao escritório ou selecione um com vinculo."
			EndIf
		Else
			If Empty(JurGetDados("SA6", 1, xFilial("SA6") + cBanco + cAgencia + cConta, "A6_COD"))
				lRet := JurMsgErro(I18n(STR0083, {cBanco,cAgencia,cConta}), , STR0084) //# "O banco #1, agência #2 e conta #3 não foi encontrado." ##"Verifique o cadastro do banco ou selecione outro banco."
			EndIf
		EndIf
	EndIf

	If lRet .And. lJurxFin .And. FindFunction("JurBnkNat")
		lRet := JurBnkNat(cBanco, cAgencia, cConta) // Valida natureza do banco
	EndIf

Return lRet
