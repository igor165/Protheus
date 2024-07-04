#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TECA870B.CH'

STATIC nDefPerc   := 0
STATIC nDefDias   := 0
STATIC cXml870b   := ""
STATIC oStrTV7Sta := Nil
STATIC aPrcOrc	  := {}
STATIC oFWSheet	  := Nil

#Define xmlCOLFIELD			01	//Coluna
#Define xmlCOLDATA			02	//Coluna
#Define xmlCOLTOTAL			02	//Coluna
#Define xmlLINNAME			01	//Linha
#Define xmlLINNICKNAME		02	//Linha
#Define xmlLINFORMULA		03	//Linha
#Define xmlLINVALUE			04	//Linha
#Define xmlLINPICTURE		05	//Linha
#Define xmlLINTOTAL			05	//Linha

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
	Definição do modelo de Dados

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel   := Nil
Local oStrTFJ  := FWFormStruct(1,'TFJ')
Local oStrTFL  := FWFormStruct(1,'TFL')
Local oStrTFF  := FWFormStruct(1,'TFF')
Local oStrTFH  := FWFormStruct(1,'TFH')
Local oStrTFG  := FWFormStruct(1,'TFG')
Local oStrTFI  := FWFormStruct(1,'TFI')
Local oStrTV7  := FWFormStruct(1,'TV7')
Local oStrTEV  := FWFormStruct(1,'TEV')
Local oStrTV7I := FWFormStruct(1,'TV7')
Local oStrZZP  := FWFormModelStruct():New()
Local nI	   := 1
Local oStru	   := Nil
Local cId 	   := ""
Local bVldPositivo := FwBuildFeature( STRUCT_FEATURE_VALID, 'Positivo()' )
Local bNoInit := FwBuildFeature( STRUCT_FEATURE_INIPAD, '' )
				  //{Titulo, Descri, Nome, Tipo, Tamanho, Decimal, Valid, When, aValues, lObrigat, bInit, lKey, lNoUpd }
Local aPerc    := {STR0001,STR0002 ,'_PERCEN','N', 11, 2, bVldPositivo, Nil, Nil, Nil, Nil, Nil, Nil, .F.}//'Percentual'##'Perc Reajus'
Local aVlr     := {STR0003, STR0004,'_VLRNEW','N', 14, 2, bVldPositivo, Nil, Nil, Nil, Nil, Nil, Nil, .F.}//'Valor novo'##'Valor Reajustado'
Local aPrazo   := {STR0005, STR0005,'_PRAZO','N', 11, 0, bVldPositivo, Nil, Nil, Nil, Nil, Nil, Nil, .F. }//'Prazo'##'Prazo'
Local xAux 		:= Nil


oStrTFJ:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)

oStrTFG:SetProperty("TFG_PRCVEN", MODEL_FIELD_OBRIGAT, .F.)
oStrTFG:SetProperty("TFG_TES",MODEL_FIELD_OBRIGAT, .F. )
oStrTFF:SetProperty("TFF_PRCVEN", MODEL_FIELD_OBRIGAT, .F.)
oStrTFH:SetProperty("TFH_PRCVEN", MODEL_FIELD_OBRIGAT, .F.)
oStrTFH:SetProperty("TFH_TES",MODEL_FIELD_OBRIGAT, .F. )

oStrTFH:RemoveField('TFH_LOCAL')
oStrTFH:RemoveField( "TFH_TES" )
oStrTFG:RemoveField('TFG_LOCAL')
oStrTFG:RemoveField( "TFG_TES" )

oStrTV7:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.) // remove a obrigatoriedade de todos os campos
oStrTV7:SetProperty("TV7_IDENT", MODEL_FIELD_OBRIGAT, .T.) // devolve a obrigatoriedade do campo de id do item da tabela de precificação
oStrTV7:SetProperty("*", MODEL_FIELD_INIT, bNoInit )  // remove todos os inicializadores padrão dos campos

oStrTV7I:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.) // remove a obrigatoriedade de todos os campos
oStrTV7I:SetProperty("TV7_IDENT", MODEL_FIELD_OBRIGAT, .T.) // devolve a obrigatoriedade do campo de id do item da tabela de precificação
oStrTV7I:SetProperty("*", MODEL_FIELD_INIT, bNoInit )  // remove todos os inicializadores padrão dos campos

oStrTV7:AddField(STR0006, STR0006, 'TV7_VLRCMB', 'C', 1,0, /*valid*/, /*when*/, /*combo*/, .F., /*inipad*/, .F., Nil, .T.)//"Vlr Combo"##"Vlr Combo"
oStrTV7:AddField(STR0007, STR0007, 'TV7_VLROLD', 'N', 14, 2, /*valid*/, /*when*/, /*combo*/, .F., /*inipad*/, .F., Nil, .T.)//"Vlr Antigo"##"Vlr Antigo"

oStrTV7I:AddField(STR0007, STR0007, 'TV7_VLROLD', 'N', 14, 2, /*valid*/, /*when*/, /*combo*/, .F., /*inipad*/, .F., Nil, .T.)//"Vlr Antigo"##"Vlr Antigo"
oStrTV7I:AddField(STR0006, STR0006, 'TV7_VLRCMB', 'C', 1,0, /*valid*/, /*when*/, /*combo*/, .F., /*inipad*/, .F., Nil, .T.)//"Vlr Combo"##"Vlr Combo"

oStrZZP:AddField(STR0008, STR0008, 'ZZP_SERVIC' , 'C', 28, ,, , , .F., , , .T., .T., )//'Serviço'##'Serviço'
oStrZZP:AddField(STR0009, STR0009, 'ZZP_VLROLD', 'N', 14,2 ,, , , .F., , , .T., .T., )//'Valor Antigo'##'Valor Antigo'
oStrZZP:AddField(STR0010, STR0010, 'ZZP_VLRNEW', 'N', 14,2 ,, , , .F., , , .T., .T., )//'Valor Revisado'##'Valor Revisado'

oStrTFF:AddField(" ","","BTNCALC","C",15,0,{||.T.},NIL,{},NIL,FwBuildFeature(STRUCT_FEATURE_INIPAD,"'RECALC_OCEAN'"),NIL,NIL,.F.)
oStrTFF:AddField(" ","","TFF_STATUS","C",15,0,{||.T.},NIL,{},NIL,FwBuildFeature(STRUCT_FEATURE_INIPAD,"'ENABLE'"),NIL,NIL,.F.)

oModel := MPFormModel():New('TECA870B', /*bPreValid*/,/*bPosValid*/,{|oModel|At870bCmt(oModel)}/*bCommit*/, {|oModel|At870bCcl(oModel)}/*bCancel*/)

oStrZZP:AddTable("   ",{}, "   ")

oModel:addFields('TFJMASTER',,oStrTFJ)
oModel:addGrid( 'TFLDETAIL', 'TFJMASTER', oStrTFL, {|oModelGrid, nLine,cAction,cField,xValue,xOldValue|A870bPreV(oModelGrid, 'TFL', cAction, cField,  'TFL_TOTAL','TFL_DTFIM', xValue, xOldValue)})
oModel:addGrid( 'TFFDETAIL', 'TFLDETAIL', oStrTFF, {|oModelGrid, nLine,cAction,cField,xValue,xOldValue|A870bPreV(oModelGrid, 'TFF', cAction, cField, 'TFF_PRCVEN','TFF_PERFIM', xValue, xOldValue)})
oModel:addGrid( 'TFGDETAIL', 'TFLDETAIL', oStrTFG, {|oModelGrid, nLine,cAction,cField,xValue,xOldValue|A870bPreV(oModelGrid, 'TFG', cAction, cField, 'TFG_PRCVEN', 'TFG_PERFIM',xValue, xOldValue)})
oModel:addGrid( 'TFHDETAIL', 'TFLDETAIL', oStrTFH, {|oModelGrid, nLine,cAction,cField,xValue,xOldValue|A870bPreV(oModelGrid, 'TFH', cAction, cField, 'TFH_PRCVEN', 'TFH_PERFIM',xValue, xOldValue)})
oModel:addGrid( 'TFIDETAIL', 'TFLDETAIL', oStrTFI, {|oModelGrid, nLine,cAction,cField,xValue,xOldValue|A870bPreV(oModelGrid, 'TFI', cAction, cField, ,'TFI_PERFIM',xValue, xOldValue)})
oModel:addGrid( 'TEVDETAIL', 'TFIDETAIL', oStrTEV, {|oModelGrid, nLine,cAction,cField,xValue,xOldValue|A870bPreV(oModelGrid, 'TEV', cAction, cField, 'TEV_VLRUNI','',xValue, xOldValue)})
oModel:addGrid( 'TV7DETAIL', 'TFFDETAIL', oStrTV7, {|oModelGrid, nLine,cAction,cField,xValue,xOldValue|A870bPreV(oModelGrid, 'TV7', cAction, cField, 'TV7_VLROLD','',xValue, xOldValue)},,,,{|oGrid|At820LFld(oGrid)})
oModel:addGrid( 'TV7IDETAIL','TFFDETAIL', oStrTV7I,,,,,{|oGrid| At870bFk()})
oModel:addGrid( 'ZZPDETAIL', 'TFLDETAIL', oStrZZP,,,,,{|oGrid| At870bFk()})

oModel:SetRelation('TFLDETAIL', { { 'TFL_FILIAL', 'xFilial("TFL")' }, { 'TFL_CODPAI', 'TFJ_CODIGO' } }, TFL->(IndexKey(1)) )
oModel:SetRelation('TFFDETAIL', { { 'TFF_FILIAL', 'xFilial("TFF")' }, { 'TFF_CODPAI', 'TFL_CODIGO' }, { 'TFF_LOCAL', 'TFL_LOCAL' }}, TFF->(IndexKey(1)) )

oModel:SetRelation('TFGDETAIL', { { 'TFG_FILIAL', 'xFilial("TFG")' }, { 'TFG_CODPAI', 'TFL_CODIGO' } }, TFG->(IndexKey(3)) )
oModel:SetRelation('TFHDETAIL', { { 'TFH_FILIAL', 'xFilial("TFH")' }, { 'TFH_CODPAI', 'TFL_CODIGO' } }, TFH->(IndexKey(3)) )
oModel:SetRelation('TFIDETAIL', { { 'TFI_FILIAL', 'xFilial("TFI")' }, { 'TFI_CODPAI', 'TFL_CODIGO' }}, TFI->(IndexKey(1)) )
oModel:SetRelation('TEVDETAIL', { { 'TEV_FILIAL', 'xFilial("TEV")' }, { 'TEV_CODLOC', 'TFI_COD' } }, TEV->(IndexKey(1)) )
oModel:SetRelation('TV7IDETAIL', { { 'TV7_FILIAL', 'xFilial("TV7")' }, }, TV7->(IndexKey(2)) )

oModel:GetModel('TV7DETAIL'):SetDescription(STR0011) //'Tabela de Precificação'
oModel:GetModel('TV7IDETAIL'):SetDescription(STR0012)//'Tabela de Impostos'
oModel:GetModel('TEVDETAIL'):SetDescription(STR0013) //'Cobrança da Locação'
oModel:GetModel('ZZPDETAIL'):SetDescription(STR0014)  //'Resumo da Revisão'

//oModel:SetPrimaryKey( {} )

oModel:GetModel('ZZPDETAIL'):SetOnlyQuery(.T.)
oModel:GetModel('ZZPDETAIL'):SetOptional(.T.)
oModel:GetModel('ZZPDETAIL'):SetNoDeleteLine(.T.)

For nI := 1 To Len(oModel:GetAllSubModels())
	cId := oModel:aAllSubModels[nI]:cId
	If !(cId $ 'TFJMASTER|ZZPDETAIL')
		oStru := oModel:GetModel(cId):GetStruct()
		AddFieldMD(oStru,aPerc)
		AddFieldMD(oStru,aVlr)

		If TFJ->TFJ_CNTREC <> '1'
			AddFieldMD(oStru,aPrazo)
		EndIf
		OnlyUpdMdl(oModel:GetModel(cId))
	EndIf
Next nI

oModel:AddCalc( 'CALCORC', 'TFJMASTER', 'TFLDETAIL', 'TFL_TOTAL', 'TFJ_VLROLD', 'FORMULA', ,,STR0009, {|oMdl| A870AtCalcL(oMdl, 1)}) //'Valor Antigo'
oModel:AddCalc( 'CALCORC', 'TFJMASTER', 'TFLDETAIL', 'TFL_VLRNEW', 'TFJ_VLRNEW', 'FORMULA', ,,STR0010, {|oMdl| A870AtCalcL(oMdl, 2)}) //'Valor revisado'
oModel:AddCalc( 'CALCORC', 'TFJMASTER', 'TFLDETAIL', 'TFL_PERCEN', 'TFJ_PERCEN', 'FORMULA', ,,STR0015, {|oMdl| A870AtCalcL(oMdl, 3)})//'Perc. Reaj'

oModel:GetModel('CALCORC'):SetDescription('Total Revisão')
oModel:SetActivate({|oModel| At870bInit( oModel ) })

TecDestroy(oFWSheet)

Return oModel

//--------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definicao da View
@author Matheus Lando Raimundo
@return oView
/*/
//---------------------	-----------------------------------------------
Static Function ViewDef()
Local oModel   := ModelDef()
Local oStrTFJ  := FWFormStruct(2,'TFJ' )
Local oStrTFL  := FWFormStruct(2,'TFL',{|cCampo| AllTrim(cCampo) $ "TFL_TOTAL|TFL_LOCAL|TFL_DESLOC|TFL_DTINI|TFL_DTFIM"})
Local oStrTFF  := FWFormStruct(2,'TFF',{|cCampo| AllTrim(cCampo) $ "TFF_COD|TFF_ITEM|TFF_PRODUT|TFF_QTDVEN|TFF_PRCVEN|TFF_PERINI|TFF_PERFIM|TFF_DESCRI"})
Local oStrTFH  := FWFormStruct(2,'TFH',{|cCampo| AllTrim(cCampo) $ "TFH_ITEM|TFH_PRODUT|TFH_QTDVEN|TFH_PRCVEN|TFH_PERINI|TFH_PERFIM|TFH_DESCRI"})
Local oStrTFG  := FWFormStruct(2,'TFG',{|cCampo| AllTrim(cCampo) $ "TFG_ITEM|TFG_PRODUT|TFG_QTDVEN|TFG_PRCVEN|TFG_PERINI|TFG_PERFIM|TFG_DESCRI"})
Local oStrTFI  := FWFormStruct(2,'TFI',{|cCampo| AllTrim(cCampo) $ "TFI_ITEM|TFI_PRODUT|TFI_QTDVEN|TFI_PERINI|TFI_PERFIM|TFI_DESCRI"})
Local oStrTV7  := FWFormStruct(2,'TV7',{|cCampo| AllTrim(cCampo) $ "TV7_ABA|TV7_IDENT|TV7_DESC|TV7_EDICAO|TV7_MODO"})
Local oStrTV7I  := FWFormStruct(2,'TV7',{|cCampo| AllTrim(cCampo) $ "TV7_ABA|TV7_IDENT|TV7_DESC|TV7_EDICAO"})
Local oStrTEV  := FWFormStruct(2,'TEV',{|cCampo| AllTrim(cCampo) $ "TEV_MODCOB|TEV_UM|TEV_QTDE|TEV_VLRUNI"})
Local oStrZZP  := FWFormViewStruct():New()
Local oStrCalc := FWCalcStruct( oModel:GetModel('CALCORC') )

Local oView    := FWFormView():New()
				 //{cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,nPictVar,F3,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar
Local aPerc    := {'_PERCEN', '00', STR0002, STR0001, Nil, 'N', '@E 99,999,999,999.99', Nil, '', .T., Nil, Nil, {}, Nil, Nil, .T.,Nil} //'Perc Reajus'##"Percentual"
Local aVlr    := {'_VLRNEW', '01', STR0004, STR0004, Nil, 'N', '@E 99,999,999,999.99', Nil, '', .T., Nil, Nil, {}, Nil, Nil, .T.,Nil} //'Valor Reajustado'##/'Valor Reajustado'
Local aPrazo   := {'_PRAZO', '02', STR0005, STR0005, Nil, 'N','@E 99,999,999,999' , Nil, '', .T., Nil, Nil, {}, Nil, Nil, .T.,Nil} //'Prazo'##'Prazo'
Local nI	   := 1
Local oStru	   := Nil
Local cTab		:= ""
Local cPosPerc	:= ""
Local cPosVlrNew := ""
Local cPosPrazo  := ""
Local lGSLE := GSGetIns('LE')
Local lGSRH := GSGetIns('RH')
Local lGSMI :=  GSGetIns('MI')
Local lGSMC := GSGetIns('MC')

oView:SetModel(oModel)  //-- Define qual o modelo de dados será utilizado

oStrTV7:AddField( "TV7_VLROLD", "99",  STR0007, STR0007,Nil,"N", "@E 99,999,999.99", NIL, "",.F.,NIL,NIL, {},Nil,NIL,.T.,NIL ) //"Vlr Antigo"##"Vlr Antigo"
oStrTV7I:AddField( "TV7_VLROLD", "99", STR0007, STR0007,Nil,"N", "@E 99,999,999.99", NIL, "",.F.,NIL,NIL, {},Nil,NIL,.T.,NIL )//"Vlr Antigo"##"Vlr Antigo"

oStrZZP:AddField( "ZZP_SERVIC", "00", STR0008, STR0008, Nil,"C",               "", NIL, "",.F.,NIL,NIL, {},Nil,NIL,.T.,NIL,NIL, NIL )//'Serviço'##'Serviço'
oStrZZP:AddField( "ZZP_VLROLD", "01", STR0009, STR0009,Nil,"N", "@E 99,999,999.99", NIL, "",.F.,NIL,NIL, {},Nil,NIL,.T.,NIL,NIL, NIL )//'Valor Antigo'##'Valor Antigo'
oStrZZP:AddField( "ZZP_VLRNEW", "02", STR0010, STR0010,Nil,"N", "@E 99,999,999.99", NIL, "",.F.,NIL,NIL, {},Nil,NIL,.T.,NIL,NIL, NIL )//'Valor Revisado'##'Valor Revisado'

oView:AddGrid('VIEW_TFL' ,oStrTFL, 'TFLDETAIL')
oView:AddGrid('VIEW_TFF' ,oStrTFF, 'TFFDETAIL')
oView:AddGrid('VIEW_TFH' ,oStrTFH, 'TFHDETAIL')
oView:AddGrid('VIEW_TFG' ,oStrTFG, 'TFGDETAIL')
oView:AddGrid('VIEW_TFI' ,oStrTFI, 'TFIDETAIL')
oView:AddGrid('VIEW_TV7' ,oStrTV7, 'TV7DETAIL')
oView:AddGrid('VIEW_TEV' ,oStrTEV, 'TEVDETAIL')
oView:AddGrid('VIEW_ZZP' ,oStrZZP, 'ZZPDETAIL')
oView:AddGrid('VIEW_TV7I' ,oStrTV7I, 'TV7IDETAIL')
oView:AddField('VIEW_CALC', oStrCalc,'CALCORC')

oView:CreateHorizontalBox('HIDE',0)
oView:CreateHorizontalBox('HIDE1',0)

oView:CreateHorizontalBox('CIMA',30)
oView:CreateHorizontalBox('MEIO',70)

oView:CreateFolder("FOLDER","MEIO")

oView:AddSheet("FOLDER","FLDRH", STR0016)//'Recursos Humanos'
oView:AddSheet("FOLDER","FLDMI", STR0017)//'Materiais de Implantação'
oView:AddSheet("FOLDER","FLDMC", STR0018) //'Materiais de Consumo'
oView:AddSheet("FOLDER","FLDLE", STR0019) //'Locação de Equipamentos'
oView:AddSheet("FOLDER","FLDRE", STR0020) //'Resumo Revisão'

oView:CreateHorizontalBox('RH',100,,,"FOLDER","FLDRH")
oView:CreateHorizontalBox('MI',100,,,"FOLDER","FLDMI")
oView:CreateHorizontalBox('MC',100,,,"FOLDER","FLDMC")
oView:CreateHorizontalBox('LE',50,,,"FOLDER","FLDLE")
oView:CreateHorizontalBox('TE',50,,,"FOLDER","FLDLE")
oView:CreateHorizontalBox('RE',50,,,"FOLDER","FLDRE")
oView:CreateHorizontalBox('CA',50,,,"FOLDER","FLDRE")

oView:SetOwnerView('VIEW_TFL','CIMA' )
oView:SetOwnerView('VIEW_TFF','RH')
oView:SetOwnerView('VIEW_TV7','HIDE')
oView:SetOwnerView('VIEW_TFG','MI')
oView:SetOwnerView('VIEW_TFH','MC')
oView:SetOwnerView('VIEW_TFI','LE')
oView:SetOwnerView('VIEW_TEV','TE')
oView:SetOwnerView('VIEW_ZZP','RE')
oView:SetOwnerView('VIEW_CALC','CA')
oView:SetOwnerView('VIEW_TV7I','HIDE1')

oView:EnableTitleView('VIEW_TEV')
oView:EnableTitleView('VIEW_CALC')

For nI := 1 To Len(oView:aViews)
	cTab := SubStr(oView:aViews[nI,6],1,3)

	oStru := oView:GetViewStruct(oView:aViews[nI,6])
	oStru:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)

	If !(cTab $ 'TFJ|ZZP|CALC')

		If cTab <> 'TFI'
			AddFieldVW(cTab,oStru,aPerc)
		EndIf

		If !(cTab $ 'TV7|TEV|') .And. TFJ->TFJ_CNTREC <> '1'
			AddFieldVW(cTab,oStru,aPrazo)
		EndIf

		If cTab <> 'TFI'
			AddFieldVW(cTab,oStru,aVlr)
		EndIf

		If cTab <> 'TFL'
			If oStru:HasField(cTab + '_PERCEN')
				If cTab $ 'TV7|TEV'
					If cTab == 'TEV'
						cPosPerc := Tira1(oStru:GetProperty(cTab + '_VLRUNI', MVC_VIEW_ORDEM))
						oStru:SetProperty('TEV_PERCEN', MVC_VIEW_ORDEM, cPosPerc)
					ElseIf cTab == 'TV7'
						oStru:SetProperty('TV7_PERCEN', MVC_VIEW_ORDEM, '15')
						oStru:SetProperty('TV7_VLROLD', MVC_VIEW_ORDEM, '16')
					EndIf
				Else
					cPosPerc := Tira1(oStru:GetProperty(cTab + '_PRCVEN', MVC_VIEW_ORDEM))
					oStru:SetProperty( cTab + '_PERCEN', MVC_VIEW_ORDEM, cPosPerc)
				EndIf
			EndIf

			If oStru:HasField(cTab + '_VLRNEW')
				cPosVlrNew := Soma1(oStru:GetProperty(cTab + '_PERCEN', MVC_VIEW_ORDEM))
				oStru:SetProperty( cTab + '_VLRNEW', MVC_VIEW_ORDEM, Soma1(cPosVlrNew))
			EndIf

			If oStru:HasField(cTab + '_PRAZO')
				cPosPrazo := Tira1(oStru:GetProperty(cTab + '_PERFIM', MVC_VIEW_ORDEM))
				oStru:SetProperty( cTab + '_PRAZO', MVC_VIEW_ORDEM, cPosPrazo)
			EndIf
		EndIf
	EndIf
Next nI

oStrTFL:SetProperty('TFL_LOCAL', MVC_VIEW_ORDEM, '00')
oStrTFL:SetProperty('TFL_DESLOC', MVC_VIEW_ORDEM, '01')
oStrTFL:SetProperty('TFL_PERCEN', MVC_VIEW_ORDEM, '02')
oStrTFL:SetProperty('TFL_TOTAL', MVC_VIEW_ORDEM, '03')
oStrTFL:SetProperty('TFL_VLRNEW', MVC_VIEW_ORDEM, '04')
If oStrTFL:HasField('TFL_PRAZO')
	oStrTFL:SetProperty('TFL_PRAZO', MVC_VIEW_ORDEM, '05')
EndIf
oStrTFL:SetProperty('TFL_DTINI', MVC_VIEW_ORDEM, '06')
oStrTFL:SetProperty('TFL_DTFIM', MVC_VIEW_ORDEM, '07')
oStrTV7:SetProperty('TV7_EDICAO', MVC_VIEW_TITULO, 'Editável')
oStrTFF:AddField('TFF_STATUS','00',""," ",{},'C','@BMP',NIL,'',.F.,NIL,NIL,{},NIL,Nil,.T.,NIL)
oStrTFF:AddField('BTNCALC','01',"Detalhes"," ",{},'C','@BMP',NIL,'',.F.,NIL,NIL,{},NIL,Nil,.T.,NIL)
oStrTV7Sta := oStrTV7
oView:SetViewProperty("VIEW_TFF", "ENABLENEWGRID")
oView:SetViewProperty("VIEW_TFF", "GRIDDOUBLECLICK", {{|oFormulario,cFieldName,nLineGrid,nLineModel| at870DClck(oFormulario,cFieldName)}})
oView:SetFieldAction( 'TFL_PERCEN', { |oView, cIDView, cField, xValue| At870Perc(oView) } )

If !lGSRH
	oView:HideFolder("FOLDER",STR0016, 2) //'Recursos Humanos'
EndIf

If !lGSMI
	oView:HideFolder("FOLDER",STR0017, 2) //'Materiais de Implantação'
EndIf

If !lGSMC
	oView:HideFolder("FOLDER",STR0018, 2) //'Materiais de Consumo'
EndIf

If !lGSLE
	oView:HideFolder("FOLDER",STR0019, 2) //'Locação de Equipamentos'
EndIf

Return oView

//--------------------------------------------------------------------
/*/{Protheus.doc} OnlyUpdMdl()

@author Matheus Lando Raimundo
@return oView
/*/
//--------------------------------------------------------------------
Function OnlyUpdMdl(oModel)

oModel:SetOnlyQuery(.T.)
oModel:SetOptional(.T.)
oModel:SetNoDeleteLine(.T.)
oModel:SetNoInsertLine(.T.)

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} AddFieldMD()

@author Matheus Lando Raimundo
@return oView
/*/
//--------------------------------------------------------------------
Function AddFieldMD(oStru,aDados)

oStru:AddField(	aDados[1],;  // cTitle
				aDados[2],;  // cToolTip
				oStru:aTable[1] + aDados[3],; // cIdField
				aDados[4],;                                                              // cTipo
				aDados[5],;                                         					   // nTamanho
				aDados[6],;                                                           // nDecimal
				aDados[7],;											     	              										   // bValid
				aDados[8],;                                                                                              // bWhen
				aDados[9],;  //aOptions
				aDados[10],;                                                           								   // lObrigat
				aDados[11],;                                                                                              // bInit
				aDados[12],;                                                                                              // lKey
				aDados[13],;                                                                                              // lNoUpd
				aDados[14])                                                                                               // lVirtual
Return

//--------------------------------------------------------------------
/*/{Protheus.doc} AddFieldVW()

@author Matheus Lando Raimundo
@return oView
/*/
//--------------------------------------------------------------------
Function AddFieldVW(cId, oStru,aDados)

oStru:AddField( cId + aDados[1],; // cIdField
				aDados[2],;                   // cOrdem
                aDados[3],;      // cTitulo
                aDados[4],;      // cDescric
				aDados[5],;                    // aHelp
				aDados[6],;                    // cType
				aDados[7],;                   // cPicture
				aDados[8],;                    // nPictVar
				aDados[9],;                     // Consulta F3
				aDados[10],;                    // lCanChange
				aDados[11],;                    // cFolder
				aDados[12],;                    // cGroup
				aDados[13],;                     // aComboValues
				aDados[14],;                    // nMaxLenCombo
				aDados[15],;                    // cIniBrow
				aDados[16],;                    // lVirtual
				aDados[17])                    // cPictVar
Return

/*/{Protheus.doc} At870bInit
	Função após a ativação do modelo para carregar os dados dos campos no xml ativo
@since 		2016.12.19
@author 	josimar.assuncao
@param 		oModel, objeto FwFormModel/MPFormModel, modelo de dados principal da rotina
/*/
Static Function At870bInit( oModel )
Local cQryCampos := GetNextAlias()
Local oTemTabXML := FwUIWorkSheet():New(,.F.)
Local nLocal := 0
Local nItem := 0
Local nX:= 0
Local nTipoCob := 0
Local aCamposTab := {}
Local nTotCampos := 0
Local nPosCampos := 0
Local oMdlTFJ := oModel:GetModel("TFJMASTER")
Local oMdlTFL := oModel:GetModel("TFLDETAIL")
Local oMdlTFF := oModel:GetModel("TFFDETAIL")
Local oMdlTV7 := oModel:GetModel("TV7DETAIL")
Local oMdlTFI := oModel:GetModel("TFIDETAIL")
Local oMdlTEV := oModel:GetModel("TEVDETAIL")
Local cFullInfo := ''
Local nPosXml := 0
Local lRet := .T.
Local aSaveRows := FwSaveRows()
Local nPerc := At870bGet(1) // copia o conteúdo da static nDefPerc
Local nDias := At870bGet(2) // copia o conteúdo da static nDefDias
Local aXmlInfos	:= {}
Local lTFFXML	:= TFF->( ColumnPos('TFF_TABXML') ) > 0

//-- Função para setar os valores das descrições, não da pra usar o inicializador padrão =/
At870IniDs(oModel)

//-- Carrega a aba de resumo
At870LoadR(oModel)

If !lTFFXML
	cFullInfo := oMdlTFJ:GetValue("TFJ_TABXML")
EndIf

If !oMdlTFF:IsEmpty()
	// verifica quais são os campos editáveis dentro da tabela de precificação do orçamento de serviços
	BeginSQL Alias cQryCampos
		SELECT TV7.*
		FROM %Table:TFJ% TFJ
			INNER JOIN %Table:TV6% TV6 ON TV6_FILIAL = %xFilial:TV6%
												AND TV6_NUMERO = TFJ_CODTAB
												AND TV6_REVISA = TFJ_TABREV
												AND TV6.%NotDel%
			INNER JOIN %Table:TV7% TV7 ON TV7_FILIAL = %xFilial:TV7%
												AND TV7_CODTAB = TV6_CODIGO
												AND TV7.%NotDel%
												AND TV7_ABA <> ' '
												AND TV7_GRUPO = '1'
		WHERE TFJ_FILIAL = %xFilial:TFJ%
			AND TFJ_CODIGO = %Exp:TFJ->TFJ_CODIGO%
			AND TFJ_CODTAB <> ' '
			AND TFJ.%NotDel%
	EndSQL

	If (cQryCampos)->(!EOF())
		// copia para o array para ter performance depois e não precisar fazer dbGoTop no resultado da query
		While (cQryCampos)->(!EOF())
			aAdd( aCamposTab, { TV7_FILIAL, TV7_CODIGO, TV7_CODTAB, TV7_GRUPO, TV7_ABA, TV7_ORDEM, TV7_IDENT, TV7_TITULO, TV7_DESC, TV7_FORM, TV7_MODO, TV7_TAM, TV7_DEC, TV7_EDICAO} )

			(cQryCampos)->(DbSkip())
		End
		(cQryCampos)->(DbCloseArea())

		// calcula o total de campos para sofrer a atualização de conteúdo
		nTotCampos := Len(aCamposTab)
		// habilita a inserção de linhas no grid
		oMdlTV7:SetNoInsertLine(.F.)
	EndIf
EndIf

For nLocal := 1 To oMdlTFL:Length()
	oMdlTFL:GoLine( nLocal )
	oMdlTFL:LoadValue('TFL_TOTAL', oMdlTFL:GetValue('TFL_TOTRH') + oMdlTFL:GetValue('TFL_TOTLE') + oMdlTFL:GetValue('TFL_TOTMI') + oMdlTFL:GetValue('TFL_TOTMC'))
	oMdlTFL:LoadValue('TFL_VLRNEW', oMdlTFL:GetValue('TFL_TOTAL'))


	If !oMdlTFI:IsEmpty()
		For nItem := 1 To oMdlTFI:Length()
			oMdlTFI:GoLine(nItem)

			For nX := 1 To oMdlTEV:Length()
				oMdlTEV:GoLine(nX)
				oMdlTEV:LoadValue('TEV_VLRNEW',oMdlTEV:GetValue('TEV_VLRUNI'))
			Next nX
		Next nItem
	EndIf

	If !Empty(cFullInfo) .AND. !lTFFXML
		// busca os dados do XML do local
		aXmlInfos := At740FXmlbyTfl( oMdlTFL:GetValue("TFL_CODIGO"), cFullInfo )
	EndIf

	If lRet .And. !oMdlTFF:IsEmpty()
		For nItem := 1 To oMdlTFF:Length()
			oMdlTFF:GoLine(nItem)
			If oMdlTFF:GetValue("TFF_COBCTR") <> "2"
				oMdlTFF:LoadValue("TFF_VLRNEW",oMdlTFF:GetValue("TFF_PRCVEN"))
				If lTFFXML
					oTemTabXML:LoadXmlModel( oMdlTFF:GetValue("TFF_TABXML") )
				Else
					nPosXml := aScan( aXmlInfos, {|x| x[1]==oMdlTFF:GetValue("TFF_COD") } )
					If nPosXml > 0
						oTemTabXML:LoadXmlModel( aXmlInfos[nPosXml,2] )
					EndIf
				EndIf


				For nPosCampos := 1 To nTotCampos

					If oMdlTV7:GetLine() > 1 .Or. !Empty( oMdlTV7:GetValue("TV7_IDENT") )
						oMdlTV7:AddLine()
					EndIf

					// ----------------------------------------------
					// insere o identificador do campo
					lRet := lRet .And. oMdlTV7:LoadValue("TV7_FILIAL" , aCamposTab[nPosCampos,1])
					lRet := lRet .And. oMdlTV7:LoadValue("TV7_IDENT" , aCamposTab[nPosCampos,7])
					lRet := lRet .And. oMdlTV7:LoadValue("TV7_TITULO" , aCamposTab[nPosCampos,8])
					lRet := lRet .And. oMdlTV7:LoadValue("TV7_DESC" , aCamposTab[nPosCampos,9])
					lRet := lRet .And. oMdlTV7:LoadValue("TV7_ABA" , aCamposTab[nPosCampos,5])
					lRet := lRet .And. oMdlTV7:LoadValue("TV7_FORM" , aCamposTab[nPosCampos,10])
					lRet := lRet .And. oMdlTV7:LoadValue("TV7_MODO" , aCamposTab[nPosCampos,11])
					lRet := lRet .And. oMdlTV7:LoadValue("TV7_TAM" , aCamposTab[nPosCampos,12])
					lRet := lRet .And. oMdlTV7:LoadValue("TV7_DEC" , aCamposTab[nPosCampos,13])

					If oMdlTFF:GetValue("TFF_ENCE") <> "1"
						If oMdlTV7:GetValue("TV7_MODO") == '2'
							lRet := lRet .And. oMdlTV7:LoadValue("TV7_EDICAO" , '2')
						Else
							lRet := lRet .And. oMdlTV7:LoadValue("TV7_EDICAO" , aCamposTab[nPosCampos,14])
						EndIf
					EndIf
						// insere o conteúdo anterior do campo da precificação
					If oMdlTV7:GetValue("TV7_MODO") == '1'
						If ValType(oTemTabXML:GetCellValue(aCamposTab[nPosCampos,7])) == 'C'
							lRet := lRet .And. oMdlTV7:LoadValue("TV7_VLROLD", Val(oTemTabXML:GetCellValue(aCamposTab[nPosCampos,7])))
							lRet := lRet .And. oMdlTV7:LoadValue("TV7_VLRNEW", oMdlTV7:GetValue("TV7_VLROLD"))
						Else
							lRet := lRet .And. oMdlTV7:LoadValue("TV7_VLROLD", oTemTabXML:GetCellValue(aCamposTab[nPosCampos,7]))
							lRet := lRet .And. oMdlTV7:LoadValue("TV7_VLRNEW", oMdlTV7:GetValue("TV7_VLROLD"))
						EndIf
					Else
						If ValType(oTemTabXML:GetCellValue(aCamposTab[nPosCampos,7])) == 'C'
							lRet := lRet .And. oMdlTV7:LoadValue("TV7_VLRCMB", oTemTabXML:GetCellValue(aCamposTab[nPosCampos,7]))
						Else
							lRet := lRet .And. oMdlTV7:LoadValue("TV7_VLRCMB", AllTrim(Str(oTemTabXML:GetCellValue(aCamposTab[nPosCampos,7]))))
						EndIf
					EndIf
				Next nPosCampos
			EndIf
		Next nItem

		// devolve para o primeiro item
		oMdlTFF:GoLine(1)
	EndIf
	If TFJ->TFJ_CNTREC <> '1'
		lRet := lRet .And. oMdlTFL:SetValue("TFL_PRAZO", nDias)
	EndIf
	lRet := lRet .And. oMdlTFL:SetValue("TFL_PERCEN", nPerc)
Next nLocal

At870LoadI(oModel)
oMdlTFL:GoLine(1)

// desabilita a inserção de linhas no grid
oMdlTV7:SetNoInsertLine(.T.)


FwRestRows( aSaveRows )

Return

/*/{Protheus.doc} At870bLdMt
	Atribui os valores de percentual e prazo aos itens de materiais do orçamento de serviços
@author 	josimar.assuncao
@since 		2016.12.20
@param 		oGrid, objeto FwFormGridModel, modelo de dados do grid da tabela TV7.
/*/
Static Function At870bLdMt( oModel, nDias, nPerc )
Local lRet := .T.
Local oMdlTFG := oModel:GetModel("TFGDETAIL")
Local oMdlTFH := oModel:GetModel("TFHDETAIL")
Local nK := 0
Local aSaveRows := FwSaveRows()
// atualiza as informações de materiais de implantação
If lRet .ANd. !oMdlTFG:IsEmpty()
	For nK := 1 To oMdlTFG:Length()
		oMdlTFG:GoLine(nK)
		If oMdlTFG:GetValue("TFG_COBCTR") <> "2"
			lRet := lRet .And. oMdlTFG:LoadValue("TFG_VLRNEW", oMdlTFG:GetValue("TFG_PRCVEN"))
			lRet := lRet .And. oMdlTFG:SetValue("TFG_PRAZO", nDias)
			lRet := lRet .And. oMdlTFG:SetValue("TFG_PERCEN", nPerc)
		EndIf
	Next nK
	// devolve para a primeira linha
	oMdlTFG:GoLine(1)
EndIf
// atualiza as informações de materiais de consumo
If lRet .ANd. !oMdlTFH:IsEmpty()
	For nK := 1 To oMdlTFH:Length()
		oMdlTFH:GoLine(nK)
		If oMdlTFH:GetValue("TFH_COBCTR") <> "2"
			lRet := lRet .And. oMdlTFH:LoadValue("TFH_VLRNEW", oMdlTFH:GetValue("TFH_PRCVEN"))
			lRet := lRet .And. oMdlTFH:SetValue("TFH_PRAZO", nDias)
			lRet := lRet .And. oMdlTFH:SetValue("TFH_PERCEN", nPerc)
		EndIf
	Next nK
	// devolve para a primeira linha
	oMdlTFH:GoLine(1)
EndIf
FwRestRows( aSaveRows )

Return lRet

/*/{Protheus.doc} At820LFld
	Carrega a estrutura dos campos da tabela TV7. Os dados só serão carregados mesmo durante o setAtivate do modelo.
@author 	josimar.assuncao
@since 		2016.12.20
@param 		oGrid, objeto FwFormGridModel, modelo de dados do grid da tabela TV7.
/*/
Static Function At820LFld(oGrid)
Local aRet := {}
Local cQryRet := GetNextAlias()

// executa uma query qualquer só para pegar a estrutura da tabela e os campos
// para não precisar ficar alterando esta função quando acontecer de criar novos campos na tabela
BeginSQL Alias cQryRet
	SELECT TV7.*
	FROM %Table:TV7% TV7
	WHERE TV7_FILIAL = %xFilial:TV7%
		AND 1 = 2
EndSQL

aRet := FwLoadByAlias( oGrid, cQryRet )

(cQryRet)->(DbCloseArea())

Return aRet

/*/{Protheus.doc} At870bSet / At870bGet
	Funções responsáveis por atribuir e retornar o conteúdos das variáveis static para identificação do valore default inserido pelo usuário
	na primeira interface para indicação do assistente de revisão por percentual
@author 	josimar.assuncao
@since 		2016.12.20
@param 		nTipo, numérico, default = 1, define em qual variável será a atribuição 1=Percentual/2=Prazo.
@param 		xValor, indefinido, valor a ser atribuído na variável
@return 	Indefinido, mesmo valor atribuído a variável
/*/
Function At870bSet( nTipo, xValor )

If nTipo <= 0 .Or. nTipo > 2
	nTipo := 1
EndIf

If nTipo == 1
	nDefPerc := xValor
ElseIf nTipo == 2
	nDefDias := xValor
EndIf
Return xValor

// At870bGet
Function At870bGet( nTipo )
Local xValor := Nil
If nTipo <= 0 .Or. nTipo > 3
	nTipo := 0
EndIf
If nTipo == 1
	xValor := nDefPerc
ElseIf nTipo == 2
	xValor := nDefDias
ElseIf nTipo == 3
	xValor := cXml870b
EndIf
Return xValor

/*/{Protheus.doc} At870bCmt
	Grava os dados da rotina no xml para capturar novamente no processo de revisão
@author 	josimar.assuncao
@since 		2016.12.20
@param 		oModel, objeto FwFormModel/MPFormModel, modelo principal do objeto mvc
@return 	Lógico, indica que o processo de gravação aconteceu com sucesso
/*/
Static Function At870bCmt(oModel)

cXml870b := ( oModel:GetXmlData(Nil, Nil, Nil, Nil, Nil, .T. ))

Return .T.

/*/{Protheus.doc} At870bCcl
	Confirma se o usuário deseja abortar o processo de revisão por assistente
@author 	josimar.assuncao
@since 		2016.12.20
@param 		oModel, objeto FwFormModel/MPFormModel, modelo principal do objeto mvc
@return 	Lógico, indica que o processo de cancelamento pode acontecer ou não
/*/
Static Function At870bCcl(oModel)
Local lRet := .T.
Local lAutomato := IIF(FindFunction("_870BTestC"), _870BTestC() ,.F.)
lRet := IIF(lAutomato, .T. ,MsgNoYes(STR0021, STR0022)) //"Deseja realmente cancelar o processo de revisão?"##"Cancelamento"

cXml870b := ""

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} A870bPreV()

@author Matheus Lando Raimundo
@return oView
/*/
//--------------------------------------------------------------------
Function A870bPreV(oModel,cTab,cAction,cField,cFldVlr,cFildDtF,xValue,xOldValue)
Local nVlrOri	 := 0
Local nVlrNew    := 0
Local nPerc      := 0
Local nDif   	 := 0
Local lRet		 := .T.
Local aSaveLines := FWSaveRows()
Local lAtualLoc  := .F.
Local nVlrReaj	 := 0


If ( cTab $ 'TFF|TFL' .And. cAction == 'CANSETVALUE' .And. '_VLRNEW' $ cField );
    .Or. (!IsInCallStack('At870bInit') .And. cTab == 'TV7' .And. (oModel:GetValue('TV7_EDICAO') <> '1'));
    .Or.  (oModel:IsEmpty())
    lRet := .F.
EndIf


If lRet .And. cAction == 'SETVALUE'
 	If (cTab == 'TV7' .And.  oModel:GetValue('TV7_MODO') == '2' .And. (!IsInCallStack('At870bInit') ))
 		Help(" ",1,"A870BNEDIT",,STR0023,4,1) //'Os campos não númericos deverão ser alterados diretamente no orçamento de serviços'
 		lRet := .F.
 	EndIf

	If lRet
		If '_VLRNEW' $ cField
			nDif := xValue - oModel:GetValue(cFldVlr)
			nPerc := (nDif / oModel:GetValue(cFldVlr)) * 100
			oModel:LoadValue(cTab + '_PERCEN', nPerc)
			lAtualLoc := .T.
			nVlrReaj := xValue
		ElseIf '_PERC' $ cField
			If !(cTab $ 'TFL|TFF' )
				If !Empty(cFldVlr)
					If oModel:GetModel():GetValue("TFLDETAIL", "TFL_ENCE") <> "1"
						If cTab $ 'TV7'
							If oModel:GetModel():GetValue("TFFDETAIL", "TFF_ENCE") <> "1"
								nVlrOri 	:= oModel:GetValue(cFldVlr)
								nVlrNew := nVlrOri + ((nVlrOri / 100)  * xValue)
								oModel:LoadValue(cTab + '_VLRNEW', nVlrNew)
								nVlrReaj := nVlrNew
							Else
								nVlrNew	:= oModel:GetValue(cFldVlr)
								oModel:LoadValue(cTab + '_VLRNEW', nVlrNew)
								nVlrReaj := nVlrNew
								lAtualLoc	:= .F.
							EndIf
						ElseIf cTab $ 'TEV'
							If oModel:GetModel():GetValue("TFIDETAIL", "TFI_ENCE") <> "1"
								nVlrOri 	:= oModel:GetValue(cFldVlr)
								nVlrNew := nVlrOri + ((nVlrOri / 100)  * xValue)
								oModel:LoadValue(cTab + '_VLRNEW', nVlrNew)
								nVlrReaj := nVlrNew
							Else
								nVlrNew	:= oModel:GetValue(cFldVlr)
								oModel:LoadValue(cTab + '_VLRNEW', nVlrNew)
								nVlrReaj := nVlrNew
								lAtualLoc	:= .F.
							EndIf
						Else
							nVlrOri 	:= oModel:GetValue(cFldVlr)
							nVlrNew := nVlrOri + ((nVlrOri / 100)  * xValue)
							oModel:LoadValue(cTab + '_VLRNEW', nVlrNew)
							nVlrReaj := nVlrNew
						EndIf
					Else
						nVlrNew	:= oModel:GetValue(cFldVlr)
						oModel:LoadValue(cTab + '_VLRNEW', nVlrNew)
						nVlrReaj := nVlrNew
						lAtualLoc	:= .F.
					EndIf
				EndIf
			EndIf
			If cTab == 'TFF' .AND. xValue <> xOldValue
		   		If oModel:GetValue("TFF_ENCE") <> "1"
		   			A870AtTab(oModel,xValue)
		   			oModel:LoadValue('TFF_STATUS','BR_LARANJA')
		   		ElseIf oModel:GetValue("TFF_ENCE") == "1"
		   			oModel:LoadValue("TFF_STATUS", "ENABLE")
		   		EndIf

		   	EndIF
			If cTab == 'TFL'
				A870AtPerc(oModel,xValue)
			EndIf
			lAtualLoc := .T.

		ElseIf '_PRAZO' $ cField
			oModel:LoadValue(cFildDtF, DaySum(GetDbValue(cTab,cFildDtF,oModel:GetDataId()), xValue))

			If cTab == 'TFL'
				A870AtPrazo(oModel,xValue)
			EndIf
		EndIf
		//-- Atualiza o Total do local de atendimento
		If  lAtualLoc .And. !(cTab $ 'TFL|TV7') .And. !(cTab == 'TFF'  .And. '_PERC' $ cField)
			A870AtTotL(oModel,oModel:GetLine(), nVlrReaj, If(cTab == 'TEV', oModel:GetModel():GetModel('TFIDETAIL'):GetLine(),0))
		EndIf

	EndIf
EndIf

FWRestRows(aSaveLines)

Return lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} A870AtRH()

@author Matheus Lando Raimundo
@return oView
/*/
//--------------------------------------------------------------------

Function A870AtRH(oModel)
Local oMdlTFF := oModel:GetModel('TFFDETAIL')
Local oMdlTV7 := oModel:GetModel('TV7DETAIL')
Local nI 	  := 1
Local nVlr	  := 0
Local aSaveLines := FWSaveRows()

For nI := 1 To oMdlTV7:Length()
 	 oMdlTV7:GoLine(nI)
 	 nVlr += oMdlTV7:GetValue('TV7_VLRNEW')
Next nI

oMdlTFF:LoadValue('TFF_VLRNEW', nVlr)
FWRestRows(aSaveLines)

Return
//--------------------------------------------------------------------
/*/{Protheus.doc} A870AtTab()

@author Matheus Lando Raimundo
@return oView
/*/
//--------------------------------------------------------------------
Function A870AtTab(oMdlTFF,nPerc)
Local oModel 	 := oMdlTFF:GetModel()
Local oMdlTV7 	 := oModel:GetModel('TV7DETAIL')
Local nI 		 := 0
Local aSaveLines := FWSaveRows()

For nI := 1 To oMdlTV7:Length()
	oMdlTV7:GoLine(nI)

	If !Empty(oMdlTV7:GetValue('TV7_IDENT')) .And. oMdlTV7:GetValue('TV7_MODO') == '1' .And. oMdlTV7:GetValue('TV7_EDICAO') == '1'
		If  oMdlTV7:GetValue('TV7_VLROLD') > 0
			oMdlTV7:SetValue('TV7_PERCEN', nPerc)
		EndIf
	EndIf
Next nI


oMdlTV7:GoLine(1)
FWRestRows(aSaveLines)

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} A870AtPerc()

@author Matheus Lando Raimundo
@return oView
/*/
//--------------------------------------------------------------------
Function A870AtPerc(oMdlTFL,nPerc)
Local oModel 	:= oMdlTFL:GetModel()
Local oMdlTFF   := oModel:GetModel('TFFDETAIL')
Local oMdlTFH   := oModel:GetModel('TFHDETAIL')
Local oMdlTFG   := oModel:GetModel('TFGDETAIL')
Local oMdlTFI   := oModel:GetModel('TFIDETAIL')
Local oMdlTEV   := oModel:GetModel('TEVDETAIL')
Local oMdlTV7   := oModel:GetModel('TV7DETAIL')
Local nI  		:= 1
Local nX  		:= 1
Local oView := FwViewActive()
Local aSaveLines := FWSaveRows()

For nX := 1 to oMdlTFF:Length()
	oMdlTFF:GoLine(nX)

	If !Empty(oMdlTFF:GetValue('TFF_PRODUT'))
		If  oMdlTFF:GetValue('TFF_PRCVEN') > 0
			oMdlTFF:SetValue('TFF_PERCEN', nPerc)
		EndIf
	EndIf

	For nI := 1 to oMdlTV7:Length()
		oMdlTV7:GoLine(nI)

		If !Empty(oMdlTV7:GetValue('TV7_IDENT')) .And. oMdlTV7:GetValue('TV7_MODO') == '1' .And. oMdlTV7:GetValue('TV7_EDICAO') == '1'
			If  oMdlTV7:GetValue('TV7_VLROLD') > 0
				oMdlTV7:SetValue('TV7_PERCEN', nPerc)
			EndIf
	    EndIf
    Next nI
Next nX

For nX := 1 to oMdlTFH:Length()
	oMdlTFH:GoLine(nX)

	If !Empty(oMdlTFH:GetValue('TFH_PRODUT'))
		If oMdlTFH:GetValue('TFH_PRCVEN') > 0
			oMdlTFH:SetValue('TFH_PERCEN', nPerc)
		EndIf
	EndIf

Next nX

For nX := 1 to oMdlTFG:Length()
	oMdlTFG:GoLine(nX)

	If !Empty(oMdlTFG:GetValue('TFG_PRODUT'))
		If oMdlTFG:GetValue('TFG_PRCVEN') > 0
			oMdlTFG:SetValue('TFG_PERCEN', nPerc)
		EndIf
	EndIf
Next nX


For nI := 1 to oMdlTFI:Length()
	oMdlTFI:GoLine(nI)

	For nX := 1 to oMdlTEV:Length()
		oMdlTEV:GoLine(nX)

		If !Empty(oMdlTEV:GetValue("TEV_MODCOB")) .And. oMdlTEV:GetValue("TEV_MODCOB") <> "3"
			oMdlTEV:SetValue("TEV_PERCEN", nPerc)
		EndIf
	Next nX
Next nI

oMdlTFF:GoLine(1)
oMdlTFG:GoLine(1)
oMdlTFH:GoLine(1)
oMdlTFI:GoLine(1)

If !IsInCallStack('At870bInit') .And. ValType(oView)<>"U" .And. oView:GetModel():GetId()=="TECA870B"
	oView:Refresh()
EndIf

FWRestRows(aSaveLines)
Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} A870AtPrazo()

@author Matheus Lando Raimundo
@return oView
/*/
//--------------------------------------------------------------------
Function A870AtPrazo(oMdlTFL,nPrazo)
Local oModel 	:= oMdlTFL:GetModel()
Local oMdlTFF   := oModel:GetModel('TFFDETAIL')
Local oMdlTFH   := oModel:GetModel('TFHDETAIL')
Local oMdlTFG   := oModel:GetModel('TFGDETAIL')
Local oMdlTFI   := oModel:GetModel('TFIDETAIL')
Local nX  		:= 1
Local oView := FwViewActive()
Local aSaveLines := FWSaveRows()

For nX := 1 to oMdlTFF:Length()
	oMdlTFF:GoLine(nX)

	If !Empty(oMdlTFF:GetValue('TFF_PRODUT'))
		oMdlTFF:SetValue('TFF_PRAZO', nPrazo)
	EndIf

Next nX

For nX := 1 to oMdlTFH:Length()
	oMdlTFH:GoLine(nX)

	If !Empty(oMdlTFH:GetValue('TFH_PRODUT'))
		oMdlTFH:SetValue('TFH_PRAZO', nPrazo)
	EndIf
Next nX

For nX := 1 to oMdlTFG:Length()
	oMdlTFG:GoLine(nX)

	If !Empty(oMdlTFG:GetValue('TFG_PRODUT'))
		oMdlTFG:SetValue('TFG_PRAZO', nPrazo)
	EndIf

Next nX

For nX := 1 to oMdlTFI:Length()
	oMdlTFI:GoLine(nX)
	If !Empty(oMdlTFI:GetValue('TFI_PRODUT'))
		oMdlTFI:SetValue('TFI_PRAZO', nPrazo)
	EndIf
Next nX

oMdlTFF:GoLine(1)
oMdlTFG:GoLine(1)
oMdlTFH:GoLine(1)
oMdlTFI:GoLine(1)
If !IsInCallStack('At870bInit') .And. ValType(oView)<>"U" .And. oView:GetModel():GetId()=="TECA870B"
	oView:Refresh()
EndIf

FWRestRows(aSaveLines)
Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} At870IniDs()

@author Matheus Lando Raimundo
@return oView
/*/
//--------------------------------------------------------------------

Function At870IniDs(oModel)
Local nI := 0
Local nX := 0
Local oMdlTFL   := oModel:GetModel('TFLDETAIL')
Local oMdlTFF   := oModel:GetModel('TFFDETAIL')
Local oMdlTFH   := oModel:GetModel('TFHDETAIL')
Local oMdlTFG   := oModel:GetModel('TFGDETAIL')
Local oMdlTFI   := oModel:GetModel('TFIDETAIL')
Local aSaveRows := FwSaveRows()

For nX := 1 to oMdlTFL:Length()
	oMdlTFL:GoLine(nX)

	If !Empty(oMdlTFL:GetValue('TFL_LOCAL'))
		oMdlTFL:LoadValue('TFL_DESLOC', Posicione("ABS", 1, xFilial("ABS")+oMdlTFL:GetValue('TFL_LOCAL'), "ABS_DESCRI"))
	EndIf


	For nI := 1 to oMdlTFF:Length()
		oMdlTFF:GoLine(nI)
		If !Empty(oMdlTFF:GetValue('TFF_PRODUT'))
			oMdlTFF:LoadValue('TFF_DESCRI', Posicione("SB1", 1, xFilial("SB1")+oMdlTFF:GetValue('TFF_PRODUT'), "B1_DESC"))
		EndIf
	next nI

	For nI := 1 to oMdlTFH:Length()
		oMdlTFH:GoLine(nI)
		If !Empty(oMdlTFH:GetValue('TFH_PRODUT'))
			oMdlTFH:LoadValue('TFH_DESCRI', Posicione("SB1", 1, xFilial("SB1")+oMdlTFH:GetValue('TFH_PRODUT'), "B1_DESC")                                        )
		EndIf
	next nI

	For nI := 1 to oMdlTFG:Length()
		oMdlTFG:GoLine(nI)
		If !Empty(oMdlTFG:GetValue('TFG_PRODUT'))
			oMdlTFG:LoadValue('TFG_DESCRI', Posicione("SB1", 1, xFilial("SB1")+oMdlTFG:GetValue('TFG_PRODUT'), "B1_DESC")                                        )
		EndIf
	next nI

	For nI := 1 to oMdlTFI:Length()
		oMdlTFI:GoLine(nI)
		If !Empty(oMdlTFI:GetValue('TFI_PRODUT'))
			oMdlTFI:LoadValue('TFI_DESCRI', Posicione("SB1", 1, xFilial("SB1")+oMdlTFI:GetValue('TFI_PRODUT'), "B1_DESC")                                        )
		EndIf
	next nI
Next nX

FwRestRows( aSaveRows )
Return


//--------------------------------------------------------------------
/*/{Protheus.doc} At870bFk()

@author Matheus Lando Raimundo
@return oView
/*/
//--------------------------------------------------------------------
Function At870bFk()

Return {}

Function At870LoadR(oModel)
Local oMdlTFL   := oModel:GetModel('TFLDETAIL')
Local oMdlZZP 	:= oModel:GetModel('ZZPDETAIL')
Local nI 		:= 0
Local aSaveRows := FwSaveRows()
Local lGSLE := GSGetIns('LE')
Local lGSRH := GSGetIns('RH')
Local lGSMI :=  GSGetIns('MI')
Local lGSMC := GSGetIns('MC')
Local lAddLine := .F.

For nI := 1 to oMdlTFL:Length()

	If lGSRH
		//-- RH
		oMdlTFL:GoLine(nI)
		lAddLine := .T.
		oMdlZZP:LoadValue('ZZP_SERVIC',STR0016) //'Recursos Humanos'
		oMdlZZP:LoadValue('ZZP_VLROLD',oMdlTFL:GetValue('TFL_TOTRH'))
		oMdlZZP:LoadValue('ZZP_VLRNEW',oMdlTFL:GetValue('TFL_TOTRH'))
	EndIf

	If lGSMI
	//-- MI
		If lAddLine
			oMdlZZP:AddLine()
		Else
			oMdlTFL:GoLine(nI)
		EndIf
		lAddLine := .T.
		oMdlZZP:LoadValue('ZZP_SERVIC',STR0017) //'Materias de Implantação'
		oMdlZZP:LoadValue('ZZP_VLROLD',oMdlTFL:GetValue('TFL_TOTMI'))
		oMdlZZP:LoadValue('ZZP_VLRNEW',oMdlTFL:GetValue('TFL_TOTMI'))
	EndIf

	If lGSMC
	//-- MC
		If lAddLine
			oMdlZZP:AddLine()
		Else
			oMdlTFL:GoLine(nI)
		EndIf
		lAddLine := .T.
		oMdlZZP:LoadValue('ZZP_SERVIC',STR0018) //'Materias de Consumo'
		oMdlZZP:LoadValue('ZZP_VLROLD',oMdlTFL:GetValue('TFL_TOTMC'))
		oMdlZZP:LoadValue('ZZP_VLRNEW',oMdlTFL:GetValue('TFL_TOTMC'))
	EndIf

	If lGSLE
		//-- LE
		If lAddLine
			oMdlZZP:AddLine()
		Else
			oMdlTFL:GoLine(nI)
		EndIf
		lAddLine := .T.
		oMdlZZP:LoadValue('ZZP_SERVIC',STR0019 ) //'Locação de equipamento'
		oMdlZZP:LoadValue('ZZP_VLROLD',oMdlTFL:GetValue('TFL_TOTLE'))
		oMdlZZP:LoadValue('ZZP_VLRNEW',oMdlTFL:GetValue('TFL_TOTLE'))
	EndIf
next nI

oMdlZZP:SetNoInsertLine(.T.)
oMdlZZP:SetNoUpdateLine(.T.)
FwRestRows( aSaveRows )

Return
//--------------------------------------------------------------------
/*/{Protheus.doc} A87OpenTab()

@author Matheus Lando Raimundo
@return oView
/*/
//--------------------------------------------------------------------
Function A87OpenTab(oModel, lAutomato)

Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oSubView		:= FwFormView():New(oModel)
Local lRet			:= .T.
Default lAutomato	:= FindFunction("_870BTestC") .AND. _870BTestC()
Default oModel		:= FwModelActive()

oSubView:SetModel(oModel)
oSubView:CreateHorizontalBox('POPBOX',100)
If !lAutomato
	oSubView:AddGrid('VIEWTV7',oStrTV7Sta,'TV7DETAIL')
	oSubView:SetOwnerView('VIEWTV7','POPBOX')
EndIf
oModel:GetModel('TV7DETAIL'):GoLine(1)
If lAutomato
	a87CalcTbP(.T., oModel)
Else
	If !oModel:GetModel('TV7DETAIL'):isEmpty()
		TECXFPOPUP(oModel,oSubView, '', MODEL_OPERATION_UPDATE, 55,,STR0024 + ' - ' +  AllTrim(oModel:GetValue('TFFDETAIL','TFF_PRODUT')) + ': ';//'Tabela de precificação'
							 + AllTrim(oModel:GetValue('TFFDETAIL','TFF_DESCRI')),{|| a87CalcTbP() })
	EndIf
EndIf
FWRestRows( aSaveLines )
RestArea(aArea)

Return lRet
//--------------------------------------------------------------------
/*/{Protheus.doc} At870LoadI()

@author Matheus Lando Raimundo
@return oView
/*/
//--------------------------------------------------------------------

Function At870LoadI(oModel)

Local cQryCampos := GetNextAlias()
Local oTemTabXML := FwUIWorkSheet():New(,.F.)
Local nLocal := 0
Local aCamposTab := {}
Local nTotCampos := 0
Local nPosCampos := 0
Local oMdlTFJ := oModel:GetModel("TFJMASTER")
Local oMdlTFL := oModel:GetModel("TFLDETAIL")
Local oMdlTFF := oModel:GetModel("TFFDETAIL")
Local oMdlTV7I := oModel:GetModel("TV7IDETAIL")
Local cFullInfo := ''
Local lRet := .T.
Local aSaveRows := FwSaveRows()
Local aXmlInfos	:= {}
Local lTFFXML	:= TFF->( ColumnPos('TFF_TABXML') ) > 0

If !lTFFXML
	cFullInfo := oMdlTFJ:GetValue("TFJ_TABXML")
EndIf

If !oMdlTFF:IsEmpty()
	// verifica quais são os campos editáveis dentro da tabela de precificação do orçamento de serviços
	BeginSQL Alias cQryCampos
		SELECT TV7.*
		FROM %Table:TFJ% TFJ
			INNER JOIN %Table:TV6% TV6 ON TV6_FILIAL = %xFilial:TV6%
												AND TV6_NUMERO = TFJ_CODTAB
												AND TV6_REVISA = TFJ_TABREV
												AND TV6.%NotDel%
			INNER JOIN %Table:TV7% TV7 ON TV7_FILIAL = %xFilial:TV7%
												AND TV7_CODTAB = TV6_CODIGO
												AND TV7.%NotDel%
												AND TV7_ABA = ' '
												AND TV7_GRUPO = '2'
		WHERE TFJ_FILIAL = %xFilial:TFJ%
			AND TFJ_CODIGO = %Exp:TFJ->TFJ_CODIGO%
			AND TFJ_CODTAB <> ' '
			AND TFJ.%NotDel%
	EndSQL

	If (cQryCampos)->(!EOF())
		// copia para o array para ter performance depois e não precisar fazer dbGoTop no resultado da query
		While (cQryCampos)->(!EOF())
			aAdd( aCamposTab, { TV7_FILIAL, TV7_CODIGO, TV7_CODTAB, TV7_GRUPO, TV7_ABA, TV7_ORDEM, TV7_IDENT, TV7_TITULO, TV7_DESC, TV7_FORM, TV7_MODO, TV7_TAM, TV7_DEC} )

			(cQryCampos)->(DbSkip())
		End
		(cQryCampos)->(DbCloseArea())

		// calcula o total de campos para sofrer a atualização de conteúdo
		nTotCampos := Len(aCamposTab)
		// habilita a inserção de linhas no grid
		oMdlTV7I:SetNoInsertLine(.F.)
	EndIf
EndIf

For nLocal := 1 To oMdlTFL:Length()
	oMdlTFL:GoLine( nLocal )

	If !Empty(cFullInfo) .AND. !lTFFXML
		// busca os dados do XML do local
		aXmlInfos := At740FXmlbyTfl( oMdlTFL:GetValue("TFL_CODIGO"), cFullInfo )
	EndIf

	If Len(aXmlInfos) > 0
		If lTFFXML
			oTemTabXML:LoadXmlModel( oMdlTFF:GetValue("TFF_TABXML") )
		Else
			oTemTabXML:LoadXmlModel( aXmlInfos[1][2] )
		EndIf

		For nPosCampos := 1 To nTotCampos

			If oMdlTV7I:GetLine() > 1 .Or. !Empty( oMdlTV7I:GetValue("TV7_IDENT") )
				oMdlTV7I:AddLine()
			EndIf

			// ----------------------------------------------
			// insere o identificador do campo
			lRet := lRet .And. oMdlTV7I:SetValue("TV7_FILIAL" , aCamposTab[nPosCampos,1])
			lRet := lRet .And. oMdlTV7I:SetValue("TV7_IDENT" , aCamposTab[nPosCampos,7])
			lRet := lRet .And. oMdlTV7I:SetValue("TV7_TITULO" , aCamposTab[nPosCampos,8])
			lRet := lRet .And. oMdlTV7I:SetValue("TV7_DESC" , aCamposTab[nPosCampos,9])
			lRet := lRet .And. oMdlTV7I:SetValue("TV7_ABA" , aCamposTab[nPosCampos,5])
			lRet := lRet .And. oMdlTV7I:SetValue("TV7_FORM" , aCamposTab[nPosCampos,10])
			lRet := lRet .And. oMdlTV7I:SetValue("TV7_MODO" , aCamposTab[nPosCampos,11])
			lRet := lRet .And. oMdlTV7I:SetValue("TV7_TAM" , aCamposTab[nPosCampos,12])
			lRet := lRet .And. oMdlTV7I:SetValue("TV7_DEC" , aCamposTab[nPosCampos,13])

			If oMdlTV7I:GetValue("TV7_MODO") == '1'
				If ValType(oTemTabXML:GetCellValue(aCamposTab[nPosCampos,7])) == 'C'
					lRet := lRet .And. oMdlTV7I:SetValue("TV7_VLROLD", Val(oTemTabXML:GetCellValue(aCamposTab[nPosCampos,7])))
					lRet := lRet .And. oMdlTV7I:LoadValue("TV7_VLRNEW", oMdlTV7I:GetValue("TV7_VLROLD"))
				Else
					lRet := lRet .And. oMdlTV7I:SetValue("TV7_VLROLD", oTemTabXML:GetCellValue(aCamposTab[nPosCampos,7]))
					lRet := lRet .And. oMdlTV7I:LoadValue("TV7_VLRNEW", oMdlTV7I:GetValue("TV7_VLROLD"))
				EndIf
			Else
				If ValType(oTemTabXML:GetCellValue(aCamposTab[nPosCampos,7])) == 'C'
					lRet := lRet .And. oMdlTV7I:LoadValue("TV7_VLRCMB", oTemTabXML:GetCellValue(aCamposTab[nPosCampos,7]))
				Else
					lRet := lRet .And. oMdlTV7I:LoadValue("TV7_VLRCMB", AllTrim(Str(oTemTabXML:GetCellValue(aCamposTab[nPosCampos,7]))))
				EndIf

			EndIf


		Next nPosCampos
		oMdlTFF:GoLine(1)
	EndIf

Next nLocal

FwRestRows( aSaveRows )

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} a87CalcTbP()

@author Matheus Lando Raimundo
@return oView
/*/
//--------------------------------------------------------------------
Function a87CalcTbP(lAutomato, oModel)
Default lAutomato := .F.

If lAutomato
	a870CalcRH(oModel)
Else
Processa( {|| (a870CalcRH()) }, STR0025, STR0026,.F.) //"Aguarde..."##"Executando cálculo"
EndIf

Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} a870CalcRH()

@author Matheus Lando Raimundo
@return oView
/*/
//--------------------------------------------------------------------
Function a870CalcRH(oModel)
Local nI := 0
Local nJ := 0
Local oMdlTV7 := Nil
Local aAux			:= {}
Local nId			:= 0// Numerador Único para os dois grupos: RH e Impostos
Local nId2			:= 0// Numerador Único para os dois grupos: RH e Impostos
Local nTam			:= 0
Local nDec			:= 0
Local uInit		:= ''
Local uValue		:= NIl
Local cPicture	:= ""
Local cXml			:= ""
Local aPrcOrc	:= {}
Local aSaveRows := FwSaveRows()
Default oModel := FwModelActive()

If Len(aPrcOrc) == 0
	aPrcOrc := At740FPrc( TFJ->TFJ_CODTAB, TFJ->TFJ_TABREV )
EndIf

At740FGTOT(oModel,'TFLDETAIL', 'TFFDETAIL','TFGDETAIL','TFHDETAIL','TFIDETAIL','TEVDETAIL',aPrcOrc,.T.)

For nJ := 1 To 2	// Duas interações: Grid	 Recursos Humanos e Grid Impostos
	If nJ == 1
		oMdlTV7	:= oModel:GetModel('TV7DETAIL')	// Recursos Humanos


		cXml += '<?xml version="1.0" encoding="UTF-8"?>'
		cXml += '<FWMODELSHEET Operation="4" version="1.01">'
		cXml += '<MODEL_SHEET modeltype="FIELDS" >'

		cXml += '<TOTLINES order="1">'
		cXml += '<value>' + AllTrim(Str(oMdlTV7:Length(.T.) + oModel:GetModel('TV7IDETAIL'):Length(.T.))) + '</value>'
		cXml += '</TOTLINES>'
		cXml += '<TOTCOLUMNS order="2">'
		cXml += '<value>' + AllTrim(Str(xmlCOLTOTAL)) + '</value>'
		cXml += '</TOTCOLUMNS>'

		cXml += '<MODEL_CELLS modeltype="GRID" optional="1">'

		// Seção Struct
		cXml += '<struct>'
		cXml += '<NAME order="1"/>'
		cXml += '<NICKNAME order="2"/>'
		cXml += '<FORMULA order="3"/>'
		cXml += '<VALUE order="4"/>'
		cXml += '<PICTURE order="5"/>'
		cXml += '<BLOCKCELL order="6"/>'
		cXml += '<BLOCKNAME order="7"/>'
		cXml += '</struct>'

		cXml += '<items>'
	Else
		oMdlTV7	:= oModel:GetModel('TV7IDETAIL')	// Impostos
	EndIf

	If !oMdlTV7:IsEmpty()
		For nI := 1 To oMdlTV7:Length(.T.)
			oMdlTV7:GoLine(nI)
			aAux := Array(xmlCOLTOTAL,xmlLINTOTAL)
			nId2 := nId2 + 1
			nId := nId + 1	// Numerador Único para os dois grupos: RH e Impostos


			cXml += '<item id="' + AllTrim(Str(nId2)) + '" deleted="0" >'
			cXml += '<NAME>' + 'A' + AllTrim(Str(nId)) + '</NAME>'
			cXml += '<VALUE>' + AllTrim(oMdlTV7:GetValue('TV7_DESC')) + '</VALUE>'
			cXml += '</item>'

			// Coluna Dados - Valores
			nId2 := nId2 + 1	// Numerador Único para os dois grupos: RH e Impostos
			cXml += '<item id="' + AllTrim(Str(nId2)) + '" deleted="0" >'
			cXml += '<NAME>' + 'B' + AllTrim(Str(nId)) + '</NAME>'

			If !Empty(AllTrim(oMdlTV7:GetValue('TV7_IDENT')))
				cXml += '<NICKNAME>' + AllTrim(oMdlTV7:GetValue('TV7_IDENT')) + '</NICKNAME>'
			EndIf

			If !Empty(AllTrim(oMdlTV7:GetValue('TV7_FORM')))
				cAux := AT740ENTAG(AllTrim(oMdlTV7:GetValue('TV7_FORM')))
				cXml += '<FORMULA>' + cAux + '</FORMULA>'
			EndIf

			//-- Caso não seja TOTAL_RH ou somente a única linha é TOTAL_RH
			If AllTrim(oMdlTV7:GetValue('TV7_IDENT')) <> 'TOTAL_RH' .OR.;
						( oMdlTV7:Length(.T.) == 1 .AND. AllTrim(oMdlTV7:GetValue('TV7_IDENT')) == 'TOTAL_RH')
				uInit := AllTrim(oMdlTV7:GetValue('TV7_INIT'))
				If !Empty(uInit)
					If At('=',uInit) > 1
						uValue	:= SubStr(uInit,1,At('=',uInit)-1)
					ElseIf At('=',uInit) == 1
						uValue	:= 1
					Else
						uValue	:= Val(StrTran(StrTran(uInit,'.',''),',','.'))
				 	EndIf
				Else
					If oMdlTV7:GetValue('TV7_MODO') == '1'
						uValue := oMdlTV7:GetValue('TV7_VLRNEW')
					Else
						uValue :=  oMdlTV7:GetValue('TV7_VLRCMB')
					EndIf
				EndIf

				uValue := If(ValType(uValue)=='N',cValToChar(uValue),uValue)

				cXml += '<VALUE>' + uValue + '</VALUE>'
			Else
				oMdlTV7:LoadValue('TV7_VLRNEW',0)
				oMdlTV7:LoadValue('TV7_PERCEN',0)
				cXml += '<VALUE>0</VALUE>'
			EndIf

			If (oMdlTV7:GetValue('TV7_MODO') == '1' )
				nTam := oMdlTV7:GetValue('TV7_TAM')
				nDec := oMdlTV7:GetValue('TV7_DEC')

				cPicture := TRANSFORM(Val(REPLICATE('9',nTam-(nDec+1)) + '.' + REPLICATE('9',nDec)),'999,999,999,999.'+REPLICATE('9',nDec))
				cPicture := '@E ' + ALLTRIM(cPicTure)

			Else
				cPicture		:= '@!'
			EndIf

			If !Empty(cPicture)
				cXml += '<PICTURE>' + cPicture + '</PICTURE>'
			EndIf

			cXml += '</item>'

		Next nI
	EndIf
Next nJ

cXml += '</items>'

cXml += '</MODEL_CELLS>'
cXml += '</MODEL_SHEET>'
cXml += '</FWMODELSHEET>'

oFWSheet := FWUIWorkSheet():New(,.F. ) //instancia a planilha sem exibição
oFWSheet:LoadXmlModel(cXml)

oModel:SetValue('TFFDETAIL','TFF_VLRNEW',oFWSheet:GetCellValue('TOTAL_RH'))
oModel:LoadValue('TFFDETAIL','TFF_STATUS','ENABLE')

TecDestroy(oFWSheet)

FwRestRows( aSaveRows )
Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} at870DClck()

@author Matheus Lando Raimundo
@return oView
/*/
//--------------------------------------------------------------------
Function at870DClck(oFormulario,cField, lAutomato, oModel)
Default oModel := FwModelActive()
Default lAutomato := .F.
If !oModel:GetModel('TFFDETAIL'):IsEmpty()
	If cField == 'BTNCALC' .AND. (oModel:GetValue("TFLDETAIL", "TFL_ENCE") <> "1" .AND. oModel:GetValue("TFFDETAIL", "TFF_ENCE") <> "1")
		A87OpenTab(oModel, lAutomato)
		IIF(VALTYPE(oFormulario) == 'O' , oFormulario:oControl:Refresh() , nil)
	ElseIf cField == 'BTNCALC'
		Help(" ",1,"A87OpenTab",,STR0031,1,0) //"O local ou item de RH esta encerrado."
	ElseIf  cField == 'TFF_STATUS'
		A87BLegend(lAutomato)
	EndIf
EndIf
Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} A870AtTotL()

@author Matheus Lando Raimundo
@return oView
/*/
//--------------------------------------------------------------------
Function A870AtTotL(oMdl,nLinExc,nVlr,nLinTFI)
Local oModel := oMdl:GetModel()
Local nI := 0
Local nTot := 0
Local nTotRH := 0
Local nTotMI := 0
Local nTotMC := 0
Local nTotLE := 0
Local aSaveRows := FwSaveRows()
Local cId := oMdl:GetId()
Local nQtd := 0
Local oZZPDetail := oModel:GetModel('ZZPDETAIL')
Local nLinRes	:= 0
Local oView	:= FwViewActive()
Local cServic := ""
Local lGSLE := GSGetIns('LE')
Local lGSRH := GSGetIns('RH')
Local lGSMI :=  GSGetIns('MI')
Local lGSMC := GSGetIns('MC')
Local nLinGrd := 0 //Linha do Grid

Default nLinExc := 0
Default nVlr := 0
Default nLinTFI := 0

nTotRH := At87MVCSUM(oModel:GetModel('TFFDETAIL'),'TFF_VLRNEW','TFF_QTDVEN',If(cId == 'TFFDETAIL',nLinExc,0),@nQtd,1,@nLinRes)
nTotMI += At87MVCSUM(oModel:GetModel('TFGDETAIL'),'TFG_VLRNEW','TFG_QTDVEN',If(cId == 'TFGDETAIL',nLinExc,0),@nQtd,2,@nLinRes)
nTotMC += At87MVCSUM(oModel:GetModel('TFHDETAIL'),'TFH_VLRNEW','TFH_QTDVEN',If(cId == 'TFHDETAIL',nLinExc,0),@nQtd,3,@nLinRes)

For nI := 1 To oModel:GetModel('TFIDETAIL'):Length()
	oModel:GetModel('TFIDETAIL'):GoLine(nI)
	nTotLE += At87MVCSUM(oModel:GetModel('TEVDETAIL'),'TEV_VLRNEW','TEV_QTDE', If(cId == 'TEVDETAIL',nLinExc,0),@nQtd,4,@nLinRes,nLinTFI)
Next nI


oZZPDetail:SetNoUpdateLine(.F.)
If lGSRH
	cServic := STR0016 //'Recursos Humanos'
	oZZPDetail:SeekLine({{"ZZP_SERVIC", cServic }})
	oZZPDetail:LoadValue('ZZP_VLRNEW',nTotRH)
	If nLinRes == 1
		nLinGrd := oZZPDetail:GetLine()
	EndIf
EndIf

If lGSMI
	cServic := STR0017 //'Materias de Implantação'
	oZZPDetail:SeekLine({{"ZZP_SERVIC", cServic }})
	oZZPDetail:LoadValue('ZZP_VLRNEW',nTotMI)
	If nLinRes == 2
		nLinGrd := oZZPDetail:GetLine()
	EndIf
EndIf

If lGSMC
	cServic := STR0018 //'Materias de Consumo'
	oZZPDetail:SeekLine({{"ZZP_SERVIC", cServic }})
	oZZPDetail:LoadValue('ZZP_VLRNEW',nTotMC)
	If nLinRes == 3
		nLinGrd := oZZPDetail:GetLine()
	EndIf
EndIf

If lGSLE
	cServic := STR0019 // 'Locação de equipamento'
	oZZPDetail:SeekLine({{"ZZP_SERVIC", cServic }})
	oZZPDetail:LoadValue('ZZP_VLRNEW',nTotLE)
	If nLinRes == 4
		nLinGrd := oZZPDetail:GetLine()
	EndIf
EndIf

oZZPDetail:GoLine(nLinGrd)
oZZPDetail:LoadValue('ZZP_VLRNEW',oZZPDetail:GetValue('ZZP_VLRNEW') + nVlr * nQtd)
oZZPDetail:SetNoUpdateLine(.T.)

//-- + (nVlr * nQtd) - Total esta recebendo o valor do campo corrente, pois o Pre valid ainda não esta atualizou o campo
nTot := nTotRH + nTotMI + nTotMC + nTotLE  + (nVlr * nQtd)

oModel:GetModel('TFLDETAIL'):SetValue('TFL_VLRNEW',nTot)

oZZPDetail:GoLine(1)
If !IsInCallStack('At870bInit') .And. ValType(oView)<>"U" .And. oView:GetModel():GetId()=="TECA870B"
	oView:Refresh()
EndIf

FwRestRows( aSaveRows )

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} At87MVCSUM()

@author Matheus Lando Raimundo
@return oView
/*/
//--------------------------------------------------------------------
Function At87MVCSUM(oModel,cCampo,cQtd,nLinExc,nQtdRet,nTipo,nLinRes,nLinTFI)
Local nI := 1
Local nRet := 0
Local aSaveRows := FwSaveRows()
Local lTEV := oModel:GetId() = 'TEVDETAIL'

Default nLinExc := 0
Default nQtdRet := 0


For nI := 1 to oModel:Length()
	oModel:GoLine(nI)

	If oModel:GetLine() == nLinExc .And. If(lTEV,nLinTFI == oModel:GetModel():GetModel('TFIDETAIL'):GetLine(),.T.)
		nQtdRet :=  oModel:GetValue(cQtd)
		nLinRes := nTipo
	Else
		If !oModel:IsDeleted()
			nRet += oModel:GetValue(cCampo)  * oModel:GetValue(cQtd)
		EndIF
	EndIf

next nI

FwRestRows( aSaveRows )
Return nRet

//--------------------------------------------------------------------
/*/{Protheus.doc} A87BLegend()

@author Retorna a Legenda
@return NIL
/*/
//--------------------------------------------------------------------
Function A87BLegend(lAutomato)
Local aLeg             := {}
Default lAutomato := .F.
aAdd(aLeg,{"ENABLE"    ,STR0027}) //'Sem pendência de cálculo'
aAdd(aLeg,{"BR_LARANJA",STR0028}) //"Com pendência de cálculo"

If !lAutomato
	BrwLegenda(STR0029,STR0030,aLeg) //"Legenda"##"Status"
EndIF

Return
//--------------------------------------------------------------------
/*/{Protheus.doc} At870Perc()
Refaz a conta do percentual aplicado

@author Matheus Lando Raimundo

/*/
//--------------------------------------------------------------------
Function At870Perc(oView)
Local oModel := FwModelActive()
Local oTFLDetail := oModel:GetModel('TFLDETAIL')
Local nRet := oTFLDetail:GetValue("TFL_PERCEN")
Local nDif := 0
Local nPerc := 0

nDif := oTFLDetail:GetValue("TFL_VLRNEW") - oTFLDetail:GetValue("TFL_TOTAL")
nPerc := (nDif / oTFLDetail:GetValue("TFL_TOTAL")) * 100
oTFLDetail:LoadValue('TFL_PERCEN', nPerc)

Return nRet

//--------------------------------------------------------------------
/*/{Protheus.doc} A870AtCalcL()
Função que calcula o valor dos totais

@author Matheus Lando Raimundo

/*/
//--------------------------------------------------------------------
Function A870AtCalcL(oModel,nOpc)
Local nI := 0
Local oMdlTFL := oModel:GetModel('TFLDETAIL')
Local nVlrOld := 0
Local nVlrNew  := 0
Local nRet := 0
Local nDif := 0

Default oModel := FwModelActive()

For nI := 1 To oMdlTFL:Length()
	nVlrOld += oMdlTFL:GetValue('TFL_TOTAL',nI)
	nVlrNew  += oMdlTFL:GetValue('TFL_VLRNEW',nI)
Next nI

If nOpc == 1
	nRet := nVlrOld
ElseIf nOpc == 2
	nRet :=  nVlrNew
ElseIf nOpc == 3
	nDif := nVlrNew - nVlrOld
	nRet := (nDif / nVlrOld) * 100
EndIf

Return nRet