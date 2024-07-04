#INCLUDE "fina472.ch"
#INCLUDE "protheus.ch"
#INCLUDE "FWMVCDEF.CH"

/* estado do movimento */
#DEFINE _CMOVCONC		"3"		//conciliado
#DEFINE _CMOVNCONC		"2"		//nao conciliado
#DEFINE _CMOVINCON		"1"		//inconsistente
/* estado do extrato */
#DEFINE _CEXTENCER		"4"		//encerrado
#DEFINE _CEXTCONC		"3"		//conciliado
#DEFINE _CEXTNCONC		"2"		//nao conciliado
#DEFINE _CEXTINCON		"1"		//inconsistente
/* forma de ingresso */
#DEFINE _CINGMANUAL		"1"		//inclusao manual
#DEFINE _CINGAUTOM		"2"		//inclusao automatica (importado)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFina472   บAutor  ณMicrosiga           บFecha ณ 06/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para tratamento de extratos bancarios.              บฑฑ
ฑฑบ          ณ Caracteristicas:                                           บฑฑ
ฑฑบ          ณ   Inclusao manual                                          บฑฑ
ฑฑบ          ณ   Importacao de arquivos .CSV                              บฑฑ
ฑฑบ          ณ   Conciliacao                                              บฑฑ
ฑฑบ          ณ   Manutencao dos extratos existentes                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑ Ivan Gomez  | DMICSN-53 |  30/08/2017 |Cuando se configura el Campo 	 ฑฑ
ฑฑ												EE_CONCON realice la b๚squeda 	 ฑฑ
ฑฑ												por concepto (EJ_OCORBCO)		 ฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fina472()
Local aArea		:= {}
Local oBrowse

aArea := GetArea()

If FinModProc()		/* Verifica se o ambiente esta configurada para as rotina de "modelo II" */
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SA6")
	oBrowse:SetDescription(STR0001) //"Extratos bancแrios"
	oBrowse:DisableDetails()
	oBrowse:Activate() 
Endif
RestArea(aArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFina472   บAutor  ณMicrosiga           บFecha ณ 12/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ModelDef()
Local oStruSA6
Local oStruFJE
Local oModel    

oStruSA6 := FWFormStruct(1,"SA6",{|cCampo| F472Estr("SA6",cCampo)})
oStruFJE := FWFormStruct(1,"FJE")
/* adiciona campos virtuais */
oStruFJE:AddField(AllTrim(SX3->(RetTitle("FJE_ESTEXT"))),"","FJEESTEXT","C",10,0,{|| .T.},NIL,{},NIL,FwBuildFeature(STRUCT_FEATURE_INIPAD,"F472EstExt(FJE->FJE_ESTEXT)"),NIL,NIL,.T.)
oStruFJE:AddField(AllTrim(SX3->(RetTitle("FJE_FORING"))),"","FJEFORING","C",10,0,{|| .T.},NIL,{},NIL,FwBuildFeature(STRUCT_FEATURE_INIPAD,"F472IngExt(FJE->FJE_FORING)"),NIL,NIL,.T.)
/*-*/
oModel := MPFormModel():New('EXTBANC')
	oModel:AddFields('SA6BANCO',/*cOwner*/,oStruSA6)
	oModel:AddGrid('FJEEXT','SA6BANCO',oStruFJE)
	oModel:SetRelation('FJEEXT',{{'FJE_FILIAL','xFilial( "FJE" )'},{'FJE_BCOCOD','A6_COD'},{'FJE_BCOAGE','A6_AGENCIA'},{'FJE_BCOCTA','A6_NUMCON'}},FJE->(IndexKey(2)))
	oModel:SetDescription('Extrato Bancarios')
	oModel:GetModel('SA6BANCO'):SetDescription('Bancos')
	oModel:GetModel('FJEEXT'):SetDescription('Extratos')
Return(oModel)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFina472   บAutor  ณMicrosiga           บFecha ณ 12/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ViewDef()
Local oModel
Local oStruSA6
Local oStruFJE
Local oView

oModel := FWLoadModel('Fina472')
oStruSA6 := FWFormStruct(2,"SA6",{|cCampo| F472Estr("SA6",cCampo)})
oStruFJE := FWFormStruct(2,'FJE')
oStruFJE:RemoveField('FJE_ESTEXT')
oStruFJE:RemoveField('FJE_FORING')
oStruFJE:RemoveField('FJE_BCOCOD')
oStruFJE:RemoveField('FJE_BCOAGE')
oStruFJE:RemoveField('FJE_BCOCTA')
/* adiciona campos virtuais */
oStruFJE:AddField('FJEESTEXT','01',AllTrim(SX3->(RetTitle("FJE_ESTEXT")))," ",{},'C','@BMP',NIL,'',.F.,NIL,NIL,{},NIL,'{|| F472EstExt(FJE->FJE_ESTEXT)}',.T.,NIL)
oStruFJE:AddField('FJEFORING','02',AllTrim(SX3->(RetTitle("FJE_FORING")))," ",{},'C','@BMP',NIL,'',.F.,NIL,NIL,{},NIL,'{|| F472IngExt(FJE->FJE_FORING)}',.T.,NIL)
/*-*/
oView := FWFormView():New()
	oView:SetModel(oModel)
	/*-*/
	oView:AddUserButton(STR0066,'',{|oView| F472ManExt(oView,MODEL_OPERATION_INSERT)})		//'Novo extrato'
	oView:AddUserButton(STR0067,'',{|oView| F472ManExt(oView,MODEL_OPERATION_VIEW)})		//'Visualiza็ใo'
	oView:AddUserButton(STR0068,'',{|oView| F472ManExt(oView,MODEL_OPERATION_UPDATE)})		//'Altera็ใo'
	oView:AddUserButton(STR0069,'',{|oView| F472ManExt(oView,MODEL_OPERATION_DELETE)})		//'Exclusใo'
	oView:AddUserButton(STR0003,'',{|oView| F472ConcAut(oView)})							//'Conciliacao automatica'
	oView:AddUserButton(STR0014,'',{|oView| F472DConcAut(oView)})							//'Desconcilia็ใo automatica'
	oView:AddUserButton(STR0070,'',{|oView| F472QuadConc(oView)})							//'Quadro de concilia็ใo'
    oView:AddUserButton(STR0078,'',{|oView| F472Legenda(oView)})                          	//"Legenda"
	/*-*/
	oView:AddField('VIEW_SA6',oStruSA6,'SA6BANCO')
	oView:CreateHorizontalBox('BANCO',10)
	oView:SetOwnerView('VIEW_SA6','BANCO')
	/*-*/
	oView:AddGrid('VIEW_FJE',oStruFJE,'FJEEXT')
	oView:CreateHorizontalBox('EXTRATOS',90)
	oView:SetOwnerView('VIEW_FJE','EXTRATOS')
Return(oView)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMENUDEF   บAutor  ณMicrosiga           บFecha ณ 10/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()     
Local aRotina

aRotina	:= {}
ADD OPTION aRotina TITLE STR0066 ACTION 'F472AIncExt()' OPERATION 4 ACCESS 0				//'Novo extrato'
ADD OPTION aRotina TITLE STR0071 ACTION 'F472Extr()' OPERATION 2 ACCESS 0					//'Extratos'
ADD OPTION aRotina TITLE STR0023 ACTION 'F472ConcMan()' OPERATION 2 ACCESS 0				//'Concilia็ใo manual'
ADD OPTION aRotina TITLE STR0028 ACTION 'F472DConcMan()' OPERATION 2 ACCESS 0				//'Desconcilia็ใo manual'
Return(Aclone(aRotina))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFina472   บAutor  ณMicrosiga           บFecha ณ 12/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472Estr(cTab,cCampo)
Local lRet	:= .T.

Do Case
	Case cTab == "SA6"
		lRet := AllTrim(cCampo) $ "A6_COD|A6_AGENCIA|A6_NUMCON|A6_NOME"
EndCase
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFina472   บAutor  ณMicrosiga           บFecha ณ 14/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472Extr()
FWExecView(STR0001,"Fina472",MODEL_OPERATION_VIEW,,{ || .T.},,10)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFina472   บAutor  ณMicrosiga           บFecha ณ 14/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472ManExt(oView,nAcao)
Local lRet		:= .F.
Local cExtrato	:= ""
Local nLin		:= 0
Local oModel
Local oFJE

Default nAcao	:= MODEL_OPERATION_INSERT

If nAcao == MODEL_OPERATION_INSERT
	If F472AIncExt()
		oModel := oView:GetModel()
		oFJE := oModel:GetModel("FJEEXT")
		nLin := oFJE:GetLine()
		oModel:DeActivate()
		oModel:Activate()
		oFJE := oModel:GetModel("FJEEXT")
		oFJE:GoLine(nLin)
	Endif
Else
	oModel := oView:GetModel()
	oFJE := oModel:GetModel("FJEEXT")
	nLin := oFJE:GetLine("FJEEXT")
	cExtrato := oModel:GetValue("FJEEXT","FJE_CODEXT")
	If FJE->(MsSeek(xFilial("FJE") + cExtrato))
		Do Case
			Case nAcao == MODEL_OPERATION_VIEW
				F472AVisExt()
				lRet := .F.
			Case nAcao == MODEL_OPERATION_UPDATE
				lRet := F472AAltExt()
			Case nAcao == MODEL_OPERATION_DELETE
				lRet := F472AExcExt()
			OtherWise
				Help(,,STR0029,,STR0030,1,0)		//'Op็ใo nใo implementada.',,'A op็ใo selecionada nใo estแ implementada.'
				lRet := .F.
		EndCase()
		If lRet
			oModel:DeActivate()
			oModel:Activate()
			oFJE:GoLine(nLin)
		Endif
	Endif
Endif
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFina472   บAutor  ณMicrosiga           บFecha ณ 13/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472EstExt(cEstExt,aEst)
Local cEstado		:= ""
Local cTitulo       := ""

Default cEstExt     := ""
Default aEst        := {}

Do Case 
	Case cEstExt == _CEXTINCON		//inconsistente
		cEstado := "DISABLE"
		cTitulo := STR0074			//"Inconsistente"
	Case cEstExt == _CEXTNCONC		//nao conciliado
		cEstado := "BR_AMARELO"
		cTitulo := STR0075			//"Nใo conciliado"
	Case cEstExt == _CEXTCONC		//conciliado
		cEstado := "BR_VERDE"
		cTitulo := STR0076			//"Conciliado"
	Case cEstExt == _CEXTENCER		//encerrado
		cEstado := "BR_AZUL"
		cTitulo := STR0077			//"Encerrado"
	OtherWise
		cEstado := "LBNO"
		cTitulo := " "
EndCase
aEst := {cEstado,cTitulo}
Return(cEstado)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFina472   บAutor  ณMicrosiga           บFecha ณ 13/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472IngExt(cIngExt)
Local cIngresso	:= ""

Default cIngExt	:= ""

Do Case 
	Case cIngExt == _CINGMANUAL		//manual
		cIngresso := "PARAMETROS"
	Case cIngExt == _CINGAUTOM		//automatico (importado)
		cIngresso := "AUTOM"
	OtherWise
		cIngresso := "LBNO"
EndCase
Return(cIngresso)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472   บAutor  ณMicrosiga           บFecha ณ  10/05/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472QuadConc(oView)
Local cQuery1	:= ""
Local cQuery2	:= ""
Local cAliasTmp	:= ""
Local dDtCorte	:= Ctod("//")
Local dDataMov	:= Ctod("//")
Local aQuadro	:= {}  
Local aArea		:= {}
Local aSize		:= {}
Local oDlgConc
Local oPnlSep1

aArea := GetArea()
/*-*/
Aadd(aQuadro,{STR0058,0}) //"(a) Saldo do banco"
Aadd(aQuadro,{STR0059,0}) //"(b) Valores nใo debitados pelo banco"
Aadd(aQuadro,{STR0060,0}) //"(c) Valores nใo creditados pelo banco"
Aadd(aQuadro,{STR0061,0}) //"(d) Valores nใo debitados pela empresa"
Aadd(aQuadro,{STR0062,0}) //"(e) Valores nใo creditados pela empresa"
Aadd(aQuadro,{STR0063,0}) //"(f) Saldo conciliado (a + b - c - d + e)"
Aadd(aQuadro,{STR0064,0}) //"(g) Saldo extrato bancแrio"
Aadd(aQuadro,{STR0065,0}) //"(h) Diferencia da concilia็ใo (f - g)"
/*-*/
dDtCorte := oView:GetValue("FJEEXT","FJE_DTEXT")
cTipoCH := IF(Type("MVCHEQUES")=="C",MVCHEQUES,MVCHEQUE)
/*
saldo do banco */
/* busca pelo saldo na data anterior ao primeiro movimento do extrato */
FJF->(MsSeek(xFilial("FJF") + oView:GetValue("FJEEXT","FJE_CODEXT")))
dDataMov := FJF->FJF_DATMOV - 1
If cPaisLoc == "ARG" 
	dDataMov:= STOD(SE8LastSeq(SA6->A6_COD,SA6->A6_AGENCIA,SA6->A6_NUMCON) )
EndIf		 
If SE8->(MsSeek(xFilial("SE8") + SA6->A6_COD + SA6->A6_AGENCIA + SA6->A6_NUMCON + DTOS(dDataMov)))
	aQuadro[1,2] :=  SE8->E8_SALATUA
Else
	SE8->(DbSkip(-1))
	If SE8->E8_BANCO == SA6->A6_COD .And. SE8->E8_AGENCIA == SA6->A6_AGENCIA .And. SE8->E8_CONTA == SA6->A6_NUMCON 
		aQuadro[1,2] :=  SE8->E8_SALATUA
	Else
		aQuadro[1,2] := 0
	Endif
Endif
/*
movimentos do financeiro */
cQuery2 := " and E5_FILIAL = '" + xFilial("SE5") + "'"
cQuery2 += " and E5_BANCO = '" + SA6->A6_COD + "'"
cQuery2 += " and E5_AGENCIA = '" + SA6->A6_AGENCIA + "'"
cQuery2 += " and E5_CONTA = '" + SA6->A6_NUMCON + "'"
cQuery2 += " and E5_DATA <= '" + Dtos(dDtCorte) + "'"
cQuery2 += " and E5_RECONC = ' '"
cQuery2 += " and E5_SITUACA not in ('C','X','E')"
cQuery2 += " and E5_TIPODOC not in " + FormatIn("BA/DC/JR/MT/CM/D2/J2/M2/C2/V2/CP/TL","/") 
cQuery2 += " and E5_VALOR > 0"
cQuery2 += " and (E5_MOEDA not in " + FormatIn("C1/C2/C3/C4/C5/CH","/") + " OR (E5_MOEDA in " + FormatIn("C1/C2/C3/C4/C5/CH","/") + " and E5_NUMCHEQ <> ' ')) and" 
cQuery2 += " (E5_NUMCHEQ <> '*' OR (E5_NUMCHEQ = '*' AND E5_RECPAG <> 'P')) AND "  
cQuery2 += " ((E5_TIPODOC  IN "+ FormatIn(cTipoCH,"|") + "AND  E5_DTDISPO <= '" + DTOS(dDtCorte)+ "' ) OR "  
cQuery2 += " (E5_TIPODOC   NOT IN "+ FormatIn(cTipoCH,"|") + "AND  E5_DTDISPO <= '" + DTOS(dDtCorte) + "' )) AND "  
cQuery2 += " (E5_NUMCHEQ <> '*' OR (E5_NUMCHEQ = '*' AND E5_RECPAG <> 'P')) "
cQuery2 += " and D_E_L_E_T_= ' '"
/*
movimentos a debito nao conciliados */
cQuery1 := "select sum(E5_VALOR) NVALOR from " + RetSQLName("SE5")
cQuery1 += "where E5_RECPAG = 'P'"
cQuery1 := ChangeQuery(cQuery1 + cQuery2)
cAliasTmp := GetNextAlias()
DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery1),cAliasTmp,.F.,.T.)
(cALiasTmp)->(DbGoTop())
aQuadro[2,2] := (cAliasTmp)->NVALOR
/*
movimentos a credito nao conciliados */
cQuery1 := "select sum(E5_VALOR) NVALOR from " + RetSQLName("SE5")
cQuery1 += "where E5_RECPAG = 'R'"
cQuery1 := ChangeQuery(cQuery1 + cQuery2)
cAliasTmp := GetNextAlias()
DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery1),cAliasTmp,.F.,.T.)
(cALiasTmp)->(DbGoTop())
aQuadro[3,2] := (cAliasTmp)->NVALOR
DbSelectArea(cAliasTmp)
DbCloseArea()
/*
valores do extrato bancario */
cQuery2 := " and FJF_FILIAL = '" + xFilial("FJF") + "'"
cQuery2 += " and FJF_CODEXT = '" + oView:GetValue("FJEEXT","FJE_CODEXT") + "'"
cQuery2 += " and FJF_ESTMOV <> '" + AllTrim(_CMOVCONC) + "'"
cQuery2 += " and D_E_L_E_T_= ' '"
/*
movimentos a debito nao conciliados no extrato*/
cQuery1 := "select sum(FJF_VALOR) NVALOR from " + RetSQLName("FJF")
cQuery1 += "where FJF_VALOR < 0"
cQuery1 := ChangeQuery(cQuery1 + cQuery2)
cAliasTmp := GetNextAlias()
DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery1),cAliasTmp,.F.,.T.)
(cALiasTmp)->(DbGoTop())
aQuadro[4,2] := Abs((cAliasTmp)->NVALOR)
DbSelectArea(cAliasTmp)
DbCloseArea()
/*
movimentos a debito nao conciliados no extrato*/
cQuery1 := "select sum(FJF_VALOR) NVALOR from " + RetSQLName("FJF")
cQuery1 += "where FJF_VALOR > 0"
cQuery1 := ChangeQuery(cQuery1 + cQuery2)
cAliasTmp := GetNextAlias()
DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery1),cAliasTmp,.F.,.T.)
(cALiasTmp)->(DbGoTop())
aQuadro[5,2] := (cAliasTmp)->NVALOR
DbSelectArea(cAliasTmp)
DbCloseArea()
/*
calculos */
aQuadro[6,2] := aQuadro[1,2] + aQuadro[2,2] - aQuadro[3,2] - aQuadro[4,2] +	aQuadro[5,2] //(a + b - c - d + e)
aQuadro[7,2] := oView:GetValue("FJEEXT","FJE_SLDEXT")
aQuadro[8,2] := aQuadro[6,2] - aQuadro[7,2]		//f -g
/*-*/
aSize := FwGetDialogSize(oMainWnd)
oDlgConc := TDialog():New(aSize[1],aSize[2],aSize[3]*.4,aSize[4]*.4,STR0070,,,,,,,,,.T.,,,,aSize[4]*.4,aSize[3]*.4)		//"Quadro de concilia็ใo"
	oPnlSep1 := TPanel():New(0,0,"",oDlgConc,,,,,,100,100,,)
		oPnlSep1:Align := CONTROL_ALIGN_TOP
		oPnlSep1:nHeight := 3
	oBrwMov := TCBrowse():New(0,0,10,10,,,,oDlgConc,,,,,,,,,,,,,,.T.,,,,.T.,)
		oBrwMov:AddColumn(TCColumn():New(" ",{|| aQuadro[oBrwMov:nAt,1]},,,,,150,.F.,.F.,,,,,))
		oBrwMov:AddColumn(TCColumn():New(" ",{|| aQuadro[oBrwMov:nAt,2]},PesqPict("FJF","FJF_VALOR"),,,,020,.F.,.F.,,,,,))
		oBrwMov:Align :=  CONTROL_ALIGN_ALLCLIENT
		oBrwMov:SetArray(aQuadro)
		oBrwMov:Refresh()     
	oDlgConc:bInit := {|| EnchoiceBar(oDlgConc,{|| oDlgConc:End()},{||oDlgConc:End()},.F.,)}
oDlgConc:Activate(,,,.T.,,,)     
/*-*/
RestArea(aArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472   บAutor  ณMicrosiga           บFecha ณ 20/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472ConcAut(oView)
Local cArqTmp	:= ""
Local cAliasTmp	:= "TMPAUT"
Local nReg		:= 0
Local nTamChav	:= 0
Local lConc		:= .F.
Local aEstr		:= {}
Local aArea		:= {}
Local aSize		:= {}
Local aBotoes	:= {}
Local oModel
Local oDlgConc
Local oPnlTop
Local oPnlBco
Local oPnlExt
Local oPnlSep1
Local oPnlSep2
Local oFnt472
Local aTmpind := {}

Private oTmpTable

If oView:GetValue("FJEEXT","FJE_ESTEXT") == _CEXTINCON
	MsgAlert(STR0002 + ": " + AllTrim(oView:GetValue("FJEEXT","FJE_CODEXT")),STR0003) //"Este extrato nใo poderแ ser conciliado automaticamente, pois possui movimentos inconsistentes"###STR0003
ElseIf oView:GetValue("FJEEXT","FJE_ESTEXT") == _CEXTCONC
	MsgAlert(STR0004 + ": " + AllTrim(oView:GetValue("FJEEXT","FJE_CODEXT")),STR0003) //"Este jแ estแ totalmente conciliado"
Else
	aArea := GetArea()
	MsgRun(STR0005,STR0003,{|| nReg := F472ExtAnt(oView:GetValue("FJEEXT","FJE_CODEXT"))}) //"Verificando os movimentos em extratos anteriores"
	If nReg > 0
		lConc := MsgNoYes(STR0006 + CRLF + CRLF + STR0007,STR0003) //"Hแ extratos anteriores a este que ainda nใo estใo conciliados. Se este extrato for totalmente conciliado, os anteriores serใo encerrados."###"Deseja continuar com a concilia็ใo automแtica?"
	Else
		lConc := .T.
	Endif
	If lConc
		lConc := .F.
		Aadd(aBotoes,{"altera",{|| F472LegCon()},"",STR0078})		//"Legenda"
		nTamChav := TamSX3("FJF_VALOR")[1]
		nTamChav++		//para o tipo do movimento
		SEE->(MsSeek(xFilial("SEE") + SA6->A6_COD + SA6->A6_AGENCIA + SA6->A6_NUMCON))
		/*
		Conforme a configuracao para conciliacao os campos abaixo serao ou nao considerados para analisar os movimentos do extrato e do financeiro. A chave para busca
		no arquivo temporario devera ser montada com os campos na seguinte ordem, ou seja, no campo CPOCHV, os dados devem estar na seguinte ordem: data do movimento, 
		conceito, comprovante, valor, tipo (debito ou credito). O tamanho do campo CPOCHV deve, entao, ser suficiente para comportar esses dados. */	
		If SEE->EE_CONREF == "1"			//Considera o comprovante na conciliacao
			nTamChav += TamSX3("FJF_COMPRO")[1]
		Endif
		If SEE->EE_CONDATA == "1"			//Considera a data na conciliacao
			nTamChav += 8	//a data ira no formato AAAAMMDD
		Endif
		If SEE->EE_CONCONC == "1"			//Considera o conceito na conciliacao
			nTamChav += TamSX3("FJF_CODCON")[1]
		Endif
		AAdd(aEstr,{"CPOCHV"  ,"C",nTamChav,0})
		AAdd(aEstr,{"SEQMOV"  ,"C",TamSX3("FJF_SEQEXT")[1],TamSX3("FJF_SEQEXT")[2]})
		AAdd(aEstr,{"DATAMOV" ,"D",08,0})
		AAdd(aEstr,{"CONCEITO","C",TamSX3("FJF_CODCON")[1],TamSX3("FJF_CODCON")[2]})
		AAdd(aEstr,{"COMPROV" ,"C",TamSX3("FJF_COMPRO")[1],TamSX3("FJF_COMPRO")[2]})
		AAdd(aEstr,{"VALORMOV","N",TamSX3("FJF_VALOR")[1],TamSX3("FJF_VALOR")[2]})
		AAdd(aEstr,{"NREGEXT" ,"N",010,0})
		AAdd(aEstr,{"DADOSFIN","C",100,0})
		AAdd(aEstr,{"NREGFIN" ,"N",010,0})
		/*-*/	
		
		aTmpind:={"CPOCHV"}
		oTmpTable:= FWTemporaryTable():New(cAliasTmp) 
		oTmpTable:SetFields( aEstr ) 
		oTmpTable:AddIndex("1",aTmpind)
		//Creacion de la tabla
		oTmpTable:Create()  
		
		DbSelectArea(cAliasTmp)
		MsgRun(STR0031,STR0003,{|| (nReg := F472ConExt(oView,cAliasTmp))})		//"Verificando os movimentos do extrato."
		If nReg > 0
			MsgRun(STR0032,STR0003,{|| nReg := F472ConFin(oView,cAliasTmp)})		//"Verificando os movimentos financeiros."
			If nReg == 0
				lConc := .F.
				MsgAlert(STR0008,STR0003) //"Nใo foram encontrados movimentos financeiros que correspondam aos do extrato bancแrio."
			Else
				lConc := .T.
			Endif
			(cAliasTmp)->(DbGoTop())
			/*-*/
			oFnt472 := TFont():New(,10,16,,.T.,,,)
			cBanco := AllTrim(SA6->A6_COD) + "/" + AllTrim(SA6->A6_AGENCIA) + "/" + AllTrim(SA6->A6_NUMCON) + " - " + AllTrim(SA6->A6_NOME)
			cExtrato := AllTrim(oView:GetValue("FJEEXT","FJE_CODEXT")) + "/" + AllTrim(oView:GetValue("FJEEXT","FJE_NUMEXT"))
			aSize := FwGetDialogSize(oMainWnd)
			oDlgConc := TDialog():New(aSize[1],aSize[2],aSize[3]*.8,aSize[4]*.8,STR0003,,,,,,,,,.T.,,,,aSize[4]*.8,aSize[3]*.8)
				oPnlSep1 := TPanel():New(0,0,"",oDlgConc,,,,,,100,100,,)
					oPnlSep1:Align := CONTROL_ALIGN_TOP
					oPnlSep1:nHeight := 3
				oPnlTop := TPanel():New(0,0," " + cBanco,oDlgConc,,,,,,100,100,,)
					oPnlTop:Align := CONTROL_ALIGN_TOP
					oPnlTop:nHeight := oDlgConc:nHeight * .05
					/* dados do banco */
					oPnlBco := TPanel():New(0,0," " + cBanco,oPnlTop,oFnt472,,,,,100,100,,)
						oPnlBco:Align := CONTROL_ALIGN_LEFT
						oPnlBco:nWidth := oDlgConc:nWidth *.8
					/* dados do extrato em processo de conciliacao */
					oPnlExt := TPanel():New(0,0," " + STR0009 + ": " + cExtrato,oPnlTop,,,,,,100,100,,) //"Extrato"
						oPnlExt:Align := CONTROL_ALIGN_RIGHT
						oPnlExt:nWidth := oDlgConc:nWidth *.2
					/*-*/
				oPnlSep2 := TPanel():New(0,0,"",oDlgConc,,,,,RGB(0,0,0),100,100,,)
					oPnlSep2:Align := CONTROL_ALIGN_TOP
					oPnlSep2:nHeight := 1
				oBrwMov := TCBrowse():New(0,0,10,10,,,,oDlgConc,,,,,,,,,,,,,cAliasTmp,.T.,,,,.T.,)
					oBrwMov:AddColumn(TCColumn():New("  ",{|| If((cAliasTmp)->NREGFIN <> 0,F472AEstMov(_CMOVCONC),F472AEstMov(_CMOVNCONC))},,,,,010,.T.,.F.,,,,,))
					oBrwMov:AddColumn(TCColumn():New(FJF->(RetTitle("FJF_SEQEXT")),{|| (cAliasTmp)->SEQMOV},,,,,020,.F.,.F.,,,,,))
					oBrwMov:AddColumn(TCColumn():New(FJF->(RetTitle("FJF_DATMOV")),{|| (cAliasTmp)->DATAMOV},,,,,020,.F.,.F.,,,,,))
					oBrwMov:AddColumn(TCColumn():New(FJF->(RetTitle("FJF_CODCON")),{|| (cAliasTmp)->CONCEITO},,,,,020,.F.,.F.,,,,,))
					oBrwMov:AddColumn(TCColumn():New(FJF->(RetTitle("FJF_COMPRO")),{|| (cAliasTmp)->COMPROV},,,,,020,.F.,.F.,,,,,))
					oBrwMov:AddColumn(TCColumn():New(FJF->(RetTitle("FJF_VALOR")),{|| (cAliasTmp)->VALORMOV},PesqPict("FJF","FJF_VALOR"),,,,020,.F.,.F.,,,,,))
					oBrwMov:AddColumn(TCColumn():New(STR0010,{|| (cAliasTmp)->DADOSFIN},,,,,020,.F.,.F.,,,,,)) //"Movimento a conciliar"
					oBrwMov:Align :=  CONTROL_ALIGN_ALLCLIENT
					oBrwMov:Refresh()
				/*-*/ 
				If lConc
					oDlgConc:bInit := {|| EnchoiceBar(oDlgConc,{|| MsgRun(STR0011,STR0003,{|| F472RegConc(cAliasTmp,1)}),lConc := .T.,oDlgConc:End()},{|| lConc := .F.,oDlgConc:End()},.F.,aBotoes)} //"Efetuando a concilia็ใo."
				Else
					oDlgConc:bInit := {|| EnchoiceBar(oDlgConc,{|| lConc := .F.,oDlgConc:End()},{|| lConc := .F.,oDlgConc:End()},.F.,aBotoes)}
				Endif
			oDlgConc:Activate(,,,.T.,,,)
			If lConc
				oModel := oView:GetModel()
				oModel:DeActivate()
				oModel:Activate()
			Endif
		Else
			MsgAlert(STR0012 + ": " + AllTrim(oView:GetValue("FJEEXT","FJE_CODEXT")),STR0003) //"Este extrato nใo possui movimentos a serem conciliados"
		Endif
		DbSelectArea(cAliasTmp)
		DbCloseArea()
		//---------------------------------
		//Exclui a tabela 
		//---------------------------------
		oTmpTable:Delete()
	Endif
	RestArea(aArea)
Endif
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472   บAutor  ณMicrosiga           บFecha ณ 25/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472ExtAnt(cCodExt)
Local cQuery	:= ""
Local cAliasFJE	:= ""
Local nReg		:= 0
Local aArea		:= {}
Local aAreaFJE	:= {}

Default cCodExt	:= ""

If !Empty(cCodExt)
	aArea := GetArea()
	lTotConc := .F.
	DbSelectArea("FJE")
	aAreaFJE := GetArea()
	FJE->(DbSetOrder(1))
	If FJE->(MsSeek(xFilial("FJE") + cCodExt))
		cQuery := "select count(*) NEXTANT from " + RetSQLName("FJE")
		cQuery += " where FJE_FILIAL = '" + xFilial("FJE") + "'"
		cQuery += " and FJE_BCOCOD = '" + SA6->A6_COD + "'"
		cQuery += " and FJE_BCOAGE = '" + SA6->A6_AGENCIA + "'"
		cQuery += " and FJE_BCOCTA = '" + SA6->A6_NUMCON + "'"
		cQuery += " and FJE_CODEXT < '" + cCodExt + "'"
		cQuery += " and FJE_ESTEXT = '" + Alltrim(_CEXTNCONC) + "'"
		cQuery += " and D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasFJE := GetNextAlias()
		DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasFJE,.F.,.T.)
		(cAliasFJE)->(DbGoTop())
		nReg := (cAliasFJE)->NEXTANT
		DbSelectArea(cAliasFJE)
		DbCloseArea()
	Endif
	DbSelectArea("FJE")
	RestArea(aAreaFJE)
	RestArea(aArea)
Endif
Return(nReg)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472   บAutor  ณMicrosiga           บFecha ณ 35/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472VerEst(cCodExt,lAnteriores,nOper)
Local cQuery		:= ""
Local cAliasFJF		:= ""
Local lTotConc		:= .F.
Local aArea			:= {}
Local aAreaFJE		:= {}

Default cCodExt		:= ""
Default lAnteriores	:= .F.
Default nOper		:= 1

If !Empty(cCodExt)
	aArea := GetArea()
	lTotConc := .F.
	DbSelectArea("FJE")
	aAreaFJE := GetArea()
	FJE->(DbSetOrder(1))
	If FJE->(MsSeek(xFilial("FJE") + cCodExt))
		If nOper == 1				//Se conciliacao, verifica-se se todos os movimentos foram conciliados. Em caso afirmativo, altera o estado do extrato para conciliado.
			cQuery := "select count(*) REGNCONC from " + RetSQLName("FJF")
			cQuery += " where FJF_FILIAL = '" + xFilial("FJF") + "'"
			cQuery += " and FJF_CODEXT = '" + cCodExt + "'"
			cQuery += " and FJF_ESTMOV <> '" + Alltrim(_CMOVCONC) + "'"
			cQuery += " and D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasFJF := GetNextAlias()
			DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasFJF,.F.,.T.)
			(cAliasFJF)->(DbGoTop())
			If (cAliasFJF)->REGNCONC == 0
				If FJE->FJE_ESTEXT == _CEXTNCONC
					RecLock("FJE",.F.)
					Replace FJE->FJE_ESTEXT	With _CEXTCONC
					Replace FJE->FJE_DTCONC	With dDataBase
					lTotConc := .T.
					FJE->(MsUnLock())
					FJE->(DbCommit())
					DbSelectArea(cAliasFJF)
					DbCloseArea()
				Endif
			Endif
			/*
			Se o extrato esta totalmente conciliado, os anteriores que ainda nao o estao serao encerrados. */
			If lTotConc .And. lAnteriores
				cQuery := "select R_E_C_N_O_ from " + RetSQLName("FJE")
				cQuery += " where FJE_FILIAL = '" + xFilial("FJE") + "'"
				cQuery += " and FJE_BCOCOD = '" + SA6->A6_COD + "'"
				cQuery += " and FJE_BCOAGE = '" + SA6->A6_AGENCIA + "'"
				cQuery += " and FJE_BCOCTA = '" + SA6->A6_NUMCON + "'"
				cQuery += " and FJE_CODEXT < '" + cCodExt + "'"
				cQuery += " and FJE_ESTEXT = '" + Alltrim(_CEXTNCONC) + "'"
				cQuery += " and D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				cAliasFJF := GetNextAlias()
				DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasFJF,.F.,.T.)
				(cAliasFJF)->(DbGoTop())
				While !((cAliasFJF)->(Eof()))
					FJE->(DbGoTo((cAliasFJF)->R_E_C_N_O_))
					RecLock("FJE",.F.)
					Replace FJE->FJE_ESTEXT	With _CEXTENCER
					FJE->(MsUnLock())
					(cAliasFJF)->(DbSkip())
				Enddo
				DbSelectArea(cAliasFJF)
				DbCloseArea()
			Endif
		Else
			If FJE->FJE_ESTEXT == _CEXTCONC
				RecLock("FJE",.F.)
				Replace FJE->FJE_ESTEXT	With _CEXTNCONC
				Replace FJE->FJE_DTCONC	With Ctod("//")
				FJE->(MsUnLock())
				FJE->(DbCommit())
			Endif
		Endif
	Endif
	DbSelectArea("FJE")
	RestArea(aAreaFJE)
	RestArea(aArea)
Endif
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472   บAutor  ณMicrosiga           บFecha ณ 20/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472DConcAut(oView)
Local lRet		:= .F.
Local cQuery	:= ""
Local cAliasFJF	:= ""
Local aArea		:= {}

aArea := GetArea()
cQuery := "select R_E_C_N_O_ NREGEXT from " + RetSQLName("FJF")
cQuery += " where FJF_FILIAL = '" + xFilial("FJF") + "'"
cQuery += " and FJF_CODEXT = '" + oView:GetValue("FJEEXT","FJE_CODEXT") + "'"
cQuery += " and FJF_ESTMOV = '" + AllTrim(_CMOVCONC) + "'"
cQuery += " and D_E_L_E_T_=' '"
/*-*/
cQuery := ChangeQuery(cQuery)
cAliasFJF := GetNextAlias()
DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasFJF,.F.,.T.)
(cAliasFJF)->(DbGoTop())
If (cAliasFJF)->(Eof())
	MsgAlert(STR0013 + ": " + AllTrim(oView:GetValue("FJEEXT","FJE_CODEXT")),STR0014) //"Este extrato nใo possui movimentos conciliados"###STR0014
Else
	MsgAlert(STR0072 + CRLF + STR0073,STR0014)	//	"Os movimentos conciliados para os quais foram gerados documentos fiscais nใo serใo desconciliados automaticamente." "A desconcilia็ใo severแ ser feita manualmente." "Desconcilia็ใo automแtica"
	MsgRun(STR0033,STR0014,{|| lRet := F472RegCon(cAliasFJF,2)}) //"Efetuando a desconcilia็ใo dos movimentos."  "Desconcilia็ใo automแtica"
	If lRet
		oModel := oView:GetModel()
		oModel:DeActivate()
		oModel:Activate()
	Endif
Endif
DbSelectArea(cAliasFJF)
DbCloseArea()
RestArea(aArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472   บAutor  ณMicrosiga           บFecha ณ 24/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472ConExt(oView,cAliasTmp)
Local nReg		:= 0
Local nTamVlr	:= 0
Local nDecVlr	:= 0
Local cQuery	:= ""
Local cAliasFJF	:= ""
Local cChave	:= ""

SEE->(MsSeek(xFilial("SEE") + SA6->A6_COD + SA6->A6_AGENCIA + Sa6->A6_NUMCON))
/*-*/
cQuery := "select FJF_SEQEXT,FJF_CODCON,FJF_DESCON,FJF_DATMOV,FJF_COMPRO,FJF_VALOR, R_E_C_N_O_ from " + RetSQLName("FJF")
cQuery += " where FJF_FILIAL = '" + xFilial("FJF") + "'"
cQuery += " and FJF_CODEXT = '" + oView:GetValue("FJEEXT","FJE_CODEXT") + "'"
cQuery += " and FJF_ESTMOV = '" + AllTrim(_CMOVNCONC) + "'"
cQuery += " and D_E_L_E_T_=' '"
cQuery += " order by FJF_SEQEXT,FJF_DATMOV"
/*-*/
cQuery := ChangeQuery(cQuery)
cAliasFJF := GetNextAlias()
DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasFJF,.F.,.T.)
TcSetField(cAliasFJF,"FJF_DATMOV","D",8,0)
(cALiasFJF)->(DbGoTop())
nReg := 0
nTamVlr := TamSX3("FJF_VALOR")[1]
nDecVlr := TamSX3("FJF_VALOR")[2]
While !((cAliasFJF)->(Eof()))
	nReg++	/*
	Conforme a configuracao para conciliacao os campos abaixo serao ou nao considerados para analisar os movimentos do extrato e do financeiro. A chave para busca
	no arquivo temporario devera ser montada com os campos na seguinte ordem, ou seja, no campo CPOCHV, os dados devem estar na seguinte ordem: data do movimento, 
	conceito, comprovante, valor, tipo do movimento. */	
	cChave := ""
	If SEE->EE_CONDATA == "1"			//Considera a data na conciliacao
		cChave += Dtos((cAliasFJF)->FJF_DATMOV)
	Endif
	If SEE->EE_CONCONC == "1"			//Considera o conceito na conciliacao
		cChave += PadR((cAliasFJF)->FJF_CODCON,TamSX3("FJF_CODCON")[1])
	Endif
	If SEE->EE_CONREF == "1"			//Considera o comprovante na conciliacao
		cChave += Padr((cAliasFJF)->FJF_COMPRO,TamSX3("FJF_COMPROd")[1])
	Endif
	cChave += StrZero(Abs((cAliasFJF)->FJF_VALOR),nTamVlr,nDecVlr)
	cChave += If((cAliasFJF)->FJF_VALOR >= 0,"R","P")
	(cAliasTmp)->(DbAppend())
	Replace (cAliasTmp)->CPOCHV		With cChave
	Replace (cAliasTmp)->SEQMOV		With (cAliasFJF)->FJF_SEQEXT
	Replace (cAliasTmp)->DATAMOV	With (cAliasFJF)->FJF_DATMOV
	Replace (cAliasTmp)->CONCEITO	With (cAliasFJF)->FJF_CODCON
	Replace (cAliasTmp)->COMPROV	With (cAliasFJF)->FJF_COMPRO
	Replace (cAliasTmp)->VALORMOV	With (cAliasFJF)->FJF_VALOR
	Replace (cAliasTmp)->NREGEXT	With (cAliasFJF)->R_E_C_N_O_
	Replace (cAliasTmp)->DADOSFIN	With ""
	Replace (cAliasTmp)->NREGFIN	With 0
	(cAliasFJF)->(DbSkip())
Enddo
(cAliasTmp)->(DbCommit())
DbSelectArea(cAliasFJF)
DbCloseArea()
Return(nReg)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472   บAutor  ณMicrosiga           บFecha ณ 24/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472ConFin(oView,cAliasTmp)
Local cQuery		:= ""
Local cPic			:= ""
Local cAliasSE5	    := ""
Local cAliasSEJ	    := ""
Local cQuerySEJ	    := ""
Local cChave		:= ""
Local cTipoCh		:= ""
Local cDoc			:= ""
Local dDtCorte		:= Ctod("//")
Local nReg			:= 0
Local nDigitos		:= 0
Local lOk			:= .T.
Local lMovConc      := .F.
Local cNumDoc       := ""

Private aCposCab	:= {}
Private aCposMov	:= {}
Private aCposSep 	:= {}

cPic := PesqPict("SE5","E5_VALOR")
dDtCorte := oView:GetValue("FJEEXT","FJE_DTEXT")
/*-*/
aCposCab	:= {{.F.,'Data Inicial'  ,'D'	,"E5_DATA"		,0,0,nil},;
				{.F.,'Data Final'    ,'D'	,"E5_DATA"		,0,0,nil},;
				{.F.,'Cod. Banco'    ,'C'	,"E5_BANCO"		,0,0,nil},;
				{.F.,'Cod. Agencia'  ,'C'	,"E5_AGENCIA"	,0,0,nil},;
				{.F.,'Conta'         ,'C'	,"E5_CONTA"		,0,0,nil},;
				{.F.,'Saldo Anterior','N'	,"E5_VALOR"		,0,0,nil}}
	
aCposMov	:= {{.F.,'Data Movimento'  ,'D'	,"E5_DATA"		,0,0,nil},;
				{.F.,'Num. Movimento'  ,'C'	,"E5_NUMERO"	,0,0,nil},;
				{.F.,'Vlr Lan็amento'  ,'N'	,"E5_VALOR"		,0,0,nil},;
				{.F.,'Tipo Lan็amento' ,'C'	,"FJF_CODCON"	,0,0,nil},;
				{.F.,'Desc. Lan็amento','C'	,"FJF_DESCON"	,0,0,nil},;
				{.F.,'Saldo'           ,'N'	,"E5_VALOR"		,0,0,nil},;
				{.F.,'Moeda'           ,'C'	,"E5_MOEDA"		,0,0,nil}}//'Moeda'

//--- Para os Separadores
aCposSep	:= {{ .F. , nil	, SPACE(1) },;  // 'Separador Arquivo'
				{ .F. , nil	, SPACE(1) },;  // 'Separador Decimais'
				{ .F. , "N"	, 0 } }         // 'Digitos Menos Significativos'
/*
Seleciona os registros, nao conciliados, pertencentes ao banco seleciondo e com data
de movimentacao menor ou igual a data do extrato que se concilia. */
cTipoCH := IF(Type("MVCHEQUES")=="C",MVCHEQUES,MVCHEQUE)
cQuery := " select E5_DATA,E5_VALOR,E5_TIPO,E5_DOCUMEN,E5_RECPAG,E5_MOVFKS,E5_NUMERO,R_E_C_N_O_ from " + RetSQLName("SE5")
cQuery += " where E5_FILIAL = '" + xFilial("SE5") + "'"
cQuery += " and E5_BANCO = '" + SA6->A6_COD + "'"
cQuery += " and E5_AGENCIA = '" + SA6->A6_AGENCIA + "'"
cQuery += " and E5_CONTA = '" + SA6->A6_NUMCON + "'"
cQuery += " and E5_DATA <= '" + Dtos(dDtCorte) + "'"
cQuery += " and E5_RECONC = ' '"
cQuery += " and E5_SITUACA not in ('C','X','E')"
cQuery += " and E5_TIPODOC not in " + FormatIn("BA/DC/JR/MT/CM/D2/J2/M2/C2/V2/CP/TL","/") 
cQuery += " and E5_VALOR > 0"
cQuery += " and (E5_MOEDA not in " + FormatIn("C1/C2/C3/C4/C5/CH","/") + " OR (E5_MOEDA in " + FormatIn("C1/C2/C3/C4/C5/CH","/") + " and E5_NUMCHEQ <> ' ')) and" 
cQuery += " (E5_NUMCHEQ <> '*' OR (E5_NUMCHEQ = '*' AND E5_RECPAG <> 'P')) AND "  
cQuery += " ((E5_TIPODOC  IN "+ FormatIn(cTipoCH,"|") + "AND  E5_DTDISPO <= '" + DTOS(dDtCorte)+ "' ) OR "  
cQuery += " (E5_TIPODOC   NOT IN "+ FormatIn(cTipoCH,"|") + "AND  E5_DTDISPO <= '" + DTOS(dDtCorte) + "' )) AND "  
cQuery += " (E5_NUMCHEQ <> '*' OR (E5_NUMCHEQ = '*' AND E5_RECPAG <> 'P')) "  
cQuery += " and D_E_L_E_T_= ' '"
cQuery := ChangeQuery(cQuery)
cAliasSE5 := GetNextAlias()
DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSE5,.F.,.T.)
TcSetField(cAliasSE5,"E5_DATA","D",8,0)
(cALiasSE5)->(DbGoTop())
/*
Analisa os movimentos selecionados e procura pelos correspondentes no extrato bancario */
nReg := 0

SEE->(MsSeek(xFilial("SEE") + SA6->A6_COD + SA6->A6_AGENCIA + SA6->A6_NUMCON))
If !Empty(SEE->EE_ARQCFG)
	CFG57Load(SEE->EE_ARQCFG,@aCposCab,@aCposMov,@aCposSep)
	nDigitos := aCposSep[3,3]
Endif
While !((cAliasSE5)->(Eof()))
	/*
	Conforme a configuracao para conciliacao os campos abaixo serao ou nao considerados para analisar os movimentos do extrato e do financeiro. A chave para busca
	no arquivo temporario devera ser montada com os campos na seguinte ordem, ou seja, no campo CPOCHV, os dados devem estar na seguinte ordem: data do movimento, 
	conceito, comprovante, valor. */	
	If SEE->EE_CONCONC <> "1"		
		cChave := ""
		If SEE->EE_CONDATA == "1"			//Considera a data na conciliacao
			cChave += Dtos((cAliasSE5)->E5_DATA)
		Endif
		If SEE->EE_CONREF == "1"			//Considera o comprovante na conciliacao
			If cPaisLoc == "ARG"
				cDoc := IIf(!Empty((cAliasSE5)->E5_NUMERO), (cAliasSE5)->E5_NUMERO, (cAliasSE5)->E5_DOCUMEN)
			Else
				cDoc := (cAliasSE5)->E5_NUMERO
			EndIf
			If Existblock("FI472DOC")
				cDocNew := ExecBlock("FI472DOC",.F.,.F.,{cAliasSE5,(cAliasSE5)->R_E_C_N_O_})
				If ValType(cDocNew) == 'C' .AND. !Empty(cDocNew)
					cDoc := cDocNew
				Endif 
			Endif 
			If nDigitos > 0
				cDoc := Substr(cDoc,nDigitos + 1)
			Endif
			cChave += Padr(cDoc,TamSX3("FJF_COMPRO")[1])
		Endif
		cChave += StrZero((cAliasSE5)->E5_VALOR,TamSX3("FJF_VALOR")[1],TamSX3("FJF_VALOR")[2])
		cChave += (cAliasSE5)->E5_RECPAG
		If (cAliasTmp)->(MsSeek(cChave))
			lMovConc := .F.
			While !EOF() .And. (cAliasTmp)->CPOCHV == cChave .And. !lMovConc
				If Empty((cAliasTmp)->DADOSFIN) .And. (cAliasTmp)->NREGFIN == 0 
					lOk := .T.
					If SEJ->(MsSeek(xFilial("SEJ") + SA6->A6_COD + (cAliasTmp)->CONCEITO))
						lOk := SEJ->EJ_GERFIS <> "1"
					Endif
					nReg++
					If lOK
						If cPaisLoc == "ARG"
							cNumDoc := IIf(!Empty((cAliasSE5)->E5_NUMERO), (cAliasSE5)->E5_NUMERO, Padr((cAliasSE5)->E5_DOCUMEN,TamSX3("FJF_COMPRO")[1]))
							Replace (cAliasTmp)->DADOSFIN	With Dtoc((cAliasSE5)->E5_DATA) + " - " + Transform((cAliasSE5)->E5_VALOR,cPic) + "  " + Alltrim(cNumDoc)
						Else
							Replace (cAliasTmp)->DADOSFIN	With Dtoc((cAliasSE5)->E5_DATA) + " - " + Transform((cAliasSE5)->E5_VALOR,cPic) + "  " + Alltrim((cAliasSE5)->E5_NUMERO)
						EndIf
						Replace (cAliasTmp)->NREGFIN	With (cAliasSE5)->R_E_C_N_O_
						lMovConc := .T.
					Endif
				EndIf
				(cAliasTmp)->(dbSkip())
			EndDo
		Endif	
		(cAliasSE5)->(DbSkip())
	Else
		//Debe de realizar for para buscar en la Tabla SEJ el banco y extraer los conceptos para agregarlos a la llave
		cQuerySEJ := "SELECT EJ_FILIAL,EJ_BANCO,EJ_OCORBCO ,R_E_C_N_O_ from " + RetSQLName("SEJ")
		cQuerySEJ += " where EJ_FILIAL = '" + xFilial("SEJ") + "'"
		cQuerySEJ += " and EJ_BANCO = '" + SA6->A6_COD + "'"
		cQuerySEJ += " and D_E_L_E_T_= ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasSEJ := GetNextAlias()
		DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuerySEJ),cAliasSEJ,.F.,.T.)
		(cAliasSEJ)->(DbGoTop())		
		While !((cAliasSEJ)->(Eof()))
		
			cChave := ""
			If SEE->EE_CONDATA == "1"			//Considera a data na conciliacao
				cChave += Dtos((cAliasSE5)->E5_DATA)
			Endif
				cChave += (cAliasSEJ)->EJ_OCORBCO
			If SEE->EE_CONREF == "1"			//Considera o comprovante na conciliacao
				If cPaisLoc == "ARG"
					cDoc := IIf(!Empty((cAliasSE5)->E5_NUMERO), (cAliasSE5)->E5_NUMERO, (cAliasSE5)->E5_DOCUMEN)
				Else
					cDoc := (cAliasSE5)->E5_NUMERO
				EndIf
				If Existblock("FI472DOC")
					cDocNew := ExecBlock("FI472DOC",.F.,.F.,{cAliasSE5,(cAliasSE5)->R_E_C_N_O_})
					If ValType(cDocNew) == 'C' .AND. !Empty(cDocNew)
						cDoc := cDocNew
					Endif 
				Endif 
				If nDigitos > 0
					cDoc := Substr(cDoc,nDigitos + 1)
				Endif
				cChave += Padr(cDoc,TamSX3("FJF_COMPRO")[1])
			Endif
			cChave += StrZero((cAliasSE5)->E5_VALOR,TamSX3("FJF_VALOR")[1],TamSX3("FJF_VALOR")[2])
			cChave += (cAliasSE5)->E5_RECPAG
			If (cAliasTmp)->(MsSeek(cChave))
				lMovConc := .F.
				While !EOF() .And. (cAliasTmp)->CPOCHV == cChave .And. !lMovConc
					If Empty((cAliasTmp)->DADOSFIN) .And. (cAliasTmp)->NREGFIN == 0
						lOk := .T.		
						If SEJ->(MsSeek(xFilial("SEJ") + SA6->A6_COD + (cAliasTmp)->CONCEITO))
							lOk := SEJ->EJ_GERFIS <> "1"
						Endif
						nReg++
						If lOK
							If cPaisLoc == "ARG"
								cNumDoc := IIf(!Empty((cAliasSE5)->E5_NUMERO), (cAliasSE5)->E5_NUMERO, Padr((cAliasSE5)->E5_DOCUMEN,TamSX3("FJF_COMPRO")[1]))
								Replace (cAliasTmp)->DADOSFIN	With Dtoc((cAliasSE5)->E5_DATA) + " - " + Transform((cAliasSE5)->E5_VALOR,cPic) + "  " + Alltrim(cNumDoc)
							Else
								Replace (cAliasTmp)->DADOSFIN	With Dtoc((cAliasSE5)->E5_DATA) + " - " + Transform((cAliasSE5)->E5_VALOR,cPic) + "  " + Alltrim((cAliasSE5)->E5_NUMERO)
							EndIf
							Replace (cAliasTmp)->NREGFIN	With (cAliasSE5)->R_E_C_N_O_
							lMovConc := .T.
						Endif
					EndIf
					(cAliasTmp)->(dbSkip())
				EndDo
			Endif
			(cAliasSEJ)->(DbSkip())	
		EndDO	
		(cAliasSE5)->(DbSkip())	
	EndIF
Enddo
(cAliasTmp)->(DbCommit())
DbSelectArea(cAliasSE5)
DbCloseArea()
Return(nReg)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472   บAutor  ณMicrosiga           บFecha ณ 24/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472RegConc(cAliasTmp,nOper)
Local nRegProc	:= 0
Local nRegConc	:= 0
Local nPos		:= 0
Local cExtConc	:= ""
Local cTexto	:= ""
Local cLog		:= ""
Local lRet		:= .F.
Local aRegConc	:= {}
Local aRegs		:= {}
Local cCpoSE5	:= {}	

Default nOper	:= 0

If nOper == 1	//conciliacao
	nRegProc := (cAliasTmp)->(RecCount())
Endif
(cAliasTmp)->(DbGoTop())
Begin Transaction
	lRet := .T.
	While !((cAliasTmp)->(Eof())) .And. lRet
		If nOper == 1		//conciliacao
			/* Se ha correspondente no financeiro, efetua a conciliacao */
			If (cAliasTmp)->NREGFIN <> 0
				nRegConc++
				aRegs := {}
				Aadd(aRegs,{"FJF",(cAliasTmp)->NREGEXT})
				Aadd(aRegs,{"SE5",(cAliasTmp)->NREGFIN})
				If F472ARegConc(Aclone(aRegs))
					SE5->(DbGoto((cAliasTmp)->NREGFIN))
					/*-*/
					cCpoSE5 := "{" 
					cCpoSE5 += "{'E5_RECONC', 'x'}"
					cCpoSE5 += "}"
					lRet := F472ConFKS((cAliasTmp)->NREGFIN,cCpoSE5,nOper)
					If lRet
						/*
						Se o movimento for referente a cheque, atualiza o controle de cheques */
						If Alltrim(SE5->E5_TIPO) == "CH"
							F472CtrlCh(nOper)
						Endif
						/*-*/
						FJF->(DbGoto((cAliasTmp)->NREGEXT))
						RecLock("FJF",.F.)
						/* Guarda o extrato para verificar, ao final da conciliacao, se ele foi totalmente conciliado */
						cExtConc := FJF->FJF_CODEXT
						Replace FJF->FJF_ESTMOV	With _CMOVCONC
						FJF->(MsUnLock())
       				Endif
				Endif
			Endif
		Else
			If nOper == 2	//desconciliacao
				aRegs := {}
				/*
				Verifica se ha documentos fiscais. Se houver, a desconciliacao devera ser manual */
				aRegConc := F472ALote("FJF",(cAliasTmp)->NREGEXT)
				If Ascan(aRegConc,{|lotecon| lotecon[2] == "SF1" .Or. lotecon[2] == "SF2"}) == 0
					Aadd(aRegs,{"FJF",(cAliasTmp)->NREGEXT})
					aRegConc := F472ARegDConc(Aclone(aRegs))
				Else
					aRegConc := {}
				Endif
				/*
				executar a reversao correspondente */
				For nRegProc := 1 To Len(aRegConc)
					Do Case 
						Case aRegConc[nRegProc,1] == "SE5"		//movimento financeiro
							SE5->(DbGoto(aRegConc[nRegProc,2]))
							/*-*/
							cCpoSE5 := "{" 
							cCpoSE5 += "{'E5_RECONC', ' '}"
							cCpoSE5 += "}"
							lRet := F472ConFKS(aRegConc[nRegProc,2],cCpoSE5,nOper)
							If lRet
								If AllTrim(SE5->E5_ORIGEM) == "FINA472"	//Se o movimento foi gerado por esta rotina, ele sera excluido.
									aRegs := {}
									Aadd(aRegs,{"E5_BANCO"  ,SE5->E5_BANCO,Nil})
									Aadd(aRegs,{"E5_AGENCIA",SE5->E5_AGENCIA,Nil})
									Aadd(aRegs,{"E5_CONTA"  ,SE5->E5_CONTA,Nil})
									Aadd(aRegs,{"E5_PREFIXO",SE5->E5_PREFIXO,Nil})
									Aadd(aRegs,{"E5_NUMERO" ,SE5->E5_NUMERO,Nil})
									Aadd(aRegs,{"E5_PARCELA",SE5->E5_PARCELA,Nil})
									Aadd(aRegs,{"E5_TIPO"   ,SE5->E5_TIPO,Nil})
									Aadd(aRegs,{"E5_DOCUMEN",SE5->E5_DOCUMEN,Nil})
									Aadd(aRegs,{"E5_DATA"   ,SE5->E5_DATA,Nil})
									Aadd(aRegs,{"INDEX"     ,3,Nil})
									Fina100(0,aRegs,5)
								Else
									/*
									Se o movimento for referente a cheque, atualiza o controle de cheques */
									If Alltrim(SE5->E5_TIPO) == "CH"
										F472CtrlCh(nOper)
									Endif
								Endif
							Endif
						Case aRegConc[nRegProc,1] == "FJF"		//movimento no extrato bancario
							FJF->(DbGoto(aRegConc[nRegProc,2]))
							RecLock("FJF",.F.)
							/* Guarda o extrato para verificar, ao final da desconciliacao, atualizar o seu estado */
							cExtConc := FJF->FJF_CODEXT
							Replace FJF->FJF_ESTMOV	With _CMOVNCONC
						Case aRegConc[nRegProc,1] == "SF1"		//movimento fiscal
						Case aRegConc[nRegProc,1] == "SF2"		//movimento fiscal
					EndCase
				Next
			Endif
		Endif
		(cAliasTmp)->(DbSkip())
	Enddo
	If lRet
		/*
		Se houve a conciliacao, ou desconciliacao, verifica se o estado do extrato. */
		If nOper == 1
			MsgRun(STR0015,STR0003,{|| F472VerEst(cExtConc,.T.,1)}) //"Verificando o estado do extrato ap๓s a concilia็ใo."
		Else
			MsgRun(STR0016,STR0014,{|| F472VerEst(cExtConc,.F.,2)}) //"Verificando o estado do extrato ap๓s a desconcilia็ใo."
		Endif
		lRet := .T.
	Else
		DisarmTrans()
	Endif
End Transaction
/*
Apresenta o resultado da conciliacao */
If nOper == 1
	If lRet
		cTexto := Str(nRegProc,10) + " " + STR0017 + CRLF + CRLF //"Registro(s) processado(s)"
		cTexto += Str(nRegConc,10) + " " + STR0018 + CRLF + CRLF //"Registro(s) conciliado(s)"
		cTexto += Str(nRegProc - nRegConc,10) + " " + STR0019 + CRLF //"Registro(s) nใo conciliado(s)"
		MsgInfo(cTexto,STR0020) //"Resultado da concilia็ใo automแtica"
	Else
		MsgStop(STR0021,STR0014) //"Nใo foi possํvel efetuar a opera็ใo."
	Endif
Else
	If nOper == 2
		If lRet
			MsgInfo(STR0022,STR0014) 	//"Desconcilia็ใo efetuada"
		Else
			MsgStop(STR0021,STR0014)	//"Nใo foi possํvel efetuar a opera็ใo."
		Endif
	Endif
Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472   บAutor  ณMicrosiga           บFecha ณ 25/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472ConcMan()
Local cTmpFJF		:= "TMPFJF"
Local cTmpSE5		:= "TMPSE5"
Local aBotoes		:= {}
Local cArqFJF		:= ""
Local cArqSE5		:= ""
Local aArea			:= {}
Local aEstr			:= {}
Local aSize			:= {}
Local aRegExt		:= {}
Local aRegSE5		:= {}
Local oDlgConc
Local oBrwMov
Local oPnlTop
Local oPnlExt
Local oPnlBco
Local oPnlSep1
Local oPnlSep2
Local oFnt472
Local aTmpFJF := {}
Local aTmpSE5 := {}
Private oTmpTable1
Private oTmpTable2


If Pergunte("F472CON",.T.)
	aArea := GetArea()
	AAdd(aEstr,{"FJF_CODEXT","C",TamSX3("FJF_CODEXT")[1],TamSX3("FJF_CODEXT")[2]})
	AAdd(aEstr,{"FJF_SEQEXT","C",TamSX3("FJF_SEQEXT")[1],TamSX3("FJF_SEQEXT")[2]})
	AAdd(aEstr,{"FJF_DATMOV","D",TamSX3("FJF_SEQEXT")[1],TamSX3("FJF_SEQEXT")[2]})
	AAdd(aEstr,{"FJF_CODCON","C",TamSX3("FJF_CODCON")[1],TamSX3("FJF_CODCON")[2]})
	AAdd(aEstr,{"FJF_DESCON","C",TamSX3("FJF_DESCON")[1],TamSX3("FJF_DESCON")[2]})
	AAdd(aEstr,{"FJF_COMPRO","C",TamSX3("FJF_COMPRO")[1],TamSX3("FJF_DESCON")[2]})
	AAdd(aEstr,{"FJF_VALOR" ,"N",TamSX3("FJF_VALOR")[1] ,TamSX3("FJF_VALOR")[2]})
	AAdd(aEstr,{"FJF_MARCA" ,"N",2,0})
	AAdd(aEstr,{"NREGEXT" ,"N",010,0})
	AAdd(aEstr,{"NREGMOV" ,"N",010,0})
	/*-*/
	
	aTmpFJF:={"FJF_CODEXT", "FJF_SEQEXT"}
	oTmpTable1:= FWTemporaryTable():New(cTmpFJF) 
	oTmpTable1:SetFields( aEstr ) 
	oTmpTable1:AddIndex("1",aTmpFJF)
	//Creacion de la tabla
	oTmpTable1:Create()

	DbSelectArea(cTmpFJF)
	MsgRun(STR0034,STR0023,{|| F472ConMExt(cTmpFJF)}) // "Verificando os movimentos nos extratos."
	(cTmpFJF)->(DbGoTop())
	If ((cTmpFJF)->(Eof()))
		MsgAlert(STR0035,STR0023)		//"Nใo hแ movimentos para serem conciliados."
	Else
		Aadd(aBotoes,{"altera",{|| F472GerMov(cTmpFJF,@aRegExt),oBrwMov:Refresh(),If((cTmpFJF)->(eof()),(MsgAlert(STR0036,STR0023),oDlgConc:End()),)},STR0024,STR0025}) //"Gera็ใo de movimento bancแrio"###"Nใo hแ mais movimentos para conciliar."###"Movim. bancแrio"
		aEstr := {}
		AAdd(aEstr,{"E5CHAVE"   ,"C",TamSX3("E5_DATA")[1]+TamSX3("E5_VALOR")[1],0})
		AAdd(aEstr,{"E5_DATA"   ,"D",TamSX3("E5_DATA")[1],TamSX3("E5_DATA")[2]})
		AAdd(aEstr,{"E5_VALOR"  ,"N",TamSX3("E5_VALOR")[1],TamSX3("E5_VALOR")[2]})
		AAdd(aEstr,{"E5_RECPAG" ,"C",TamSX3("E5_RECPAG")[1],TamSX3("E5_RECPAG")[2]})
		AAdd(aEstr,{"E5_TIPO"   ,"C",TamSX3("E5_TIPO")[1],TamSX3("E5_TIPO")[2]})
		AAdd(aEstr,{"E5_PREFIXO","C",TamSX3("E5_PREFIXO")[1],TamSX3("E5_PREFIXO")[2]})
		AAdd(aEstr,{"E5_NUMERO" ,"C",TamSX3("E5_NUMERO")[1],TamSX3("E5_NUMERO")[2]})
		AAdd(aEstr,{"E5_DOCUMEN","C",TamSX3("E5_DOCUMEN")[1],TamSX3("E5_DOCUMEN")[2]})
		AAdd(aEstr,{"E5_MARCA"  ,"N",2,0})
		AAdd(aEstr,{"NREGMOV"   ,"N",010,0})
		/*-*/		
		
		aTmpSE5:={"E5CHAVE"}
		oTmpTable2:= FWTemporaryTable():New(cTmpSE5) 
		oTmpTable2:SetFields( aEstr ) 
		oTmpTable2:AddIndex("1",aTmpSE5)
		//Creacion de la tabla
		oTmpTable2:Create()

		DbSelectArea(cTmpSE5)
  		MsgRun(STR0026,STR0023,{|| F472ConMFin(cTmpSE5)}) //"Verificando os movimentos financeiros existentes no sistema."
		oFnt472 := TFont():New(,10,16,,.T.,,,)
		cBanco := AllTrim(SA6->A6_COD) + "/" + AllTrim(SA6->A6_AGENCIA) + "/" + AllTrim(SA6->A6_NUMCON) + " - " + AllTrim(SA6->A6_NOME)
		aRegExt := {}
		aSize := FwGetDialogSize(oMainWnd)
		oDlgConc := TDialog():New(aSize[1],aSize[2],aSize[3]*.8,aSize[4]*.8,STR0023,,,,,,,,,.T.,,,,aSize[4]*.8,aSize[3]*.8)
			oPnlSep1 := TPanel():New(0,0,"",oDlgConc,,,,,,100,100,,)
				oPnlSep1:Align := CONTROL_ALIGN_TOP
				oPnlSep1:nHeight := 3
			oPnlTop := TPanel():New(0,0," " + cBanco,oDlgConc,,,,,,100,100,,)
				oPnlTop:Align := CONTROL_ALIGN_TOP
				oPnlTop:nHeight := oDlgConc:nHeight * .05
				/* dados do banco */
				oPnlBco := TPanel():New(0,0," " + cBanco,oPnlTop,oFnt472,,,,,100,100,,)
					oPnlBco:Align := CONTROL_ALIGN_LEFT
					oPnlBco:nWidth := oDlgConc:nWidth * 0.8
				/*-*/
				oPnlExt := TPanel():New(0,0," " + STR0027,oPnlTop,,,,,,100,100,,) //"Movimentos de extratos bancแrios"
					oPnlExt:Align := CONTROL_ALIGN_RIGHT
					oPnlExt:nWidth := oDlgConc:nWidth * 0.2
			/*-*/
			oPnlSep2 := TPanel():New(0,0,"",oDlgConc,,,,,RGB(0,0,0),100,100,,)
				oPnlSep2:Align := CONTROL_ALIGN_TOP
				oPnlSep2:nHeight := 1
			oBrwMov := TCBrowse():New(0,0,10,10,,,,oDlgConc,,,,,,,,,,,,,cTmpFJF,.T.,,,,.T.,)
				oBrwMov:AddColumn(TCColumn():New(" ",{|| If((cTmpFJF)->FJF_MARCA == 1,"WFCHK","WFUNCHK")},,,,,010,.T.,.F.,,,,,))
				oBrwMov:AddColumn(TCColumn():New(FJF->(RetTitle("FJF_CODEXT")),{|| (cTmpFJF)->FJF_CODEXT},,,,,020,.F.,.F.,,,,,))
				oBrwMov:AddColumn(TCColumn():New(FJF->(RetTitle("FJF_SEQEXT")),{|| (cTmpFJF)->FJF_SEQEXT},,,,,020,.F.,.F.,,,,,))
				oBrwMov:AddColumn(TCColumn():New(FJF->(RetTitle("FJF_DATMOV")),{|| (cTmpFJF)->FJF_DATMOV},,,,,020,.F.,.F.,,,,,))
				oBrwMov:AddColumn(TCColumn():New(FJF->(RetTitle("FJF_CODCON")),{|| (cTmpFJF)->FJF_CODCON},,,,,020,.F.,.F.,,,,,))
				oBrwMov:AddColumn(TCColumn():New(FJF->(RetTitle("FJF_DESCON")),{|| (cTmpFJF)->FJF_DESCON},,,,,030,.F.,.F.,,,,,))
				oBrwMov:AddColumn(TCColumn():New(FJF->(RetTitle("FJF_VALOR")) ,{|| (cTmpFJF)->FJF_VALOR},PesqPict("FJF","FJF_VALOR"),,,,020,.F.,.F.,,,,,))
				oBrwMov:AddColumn(TCColumn():New(FJF->(RetTitle("FJF_COMPRO")),{|| (cTmpFJF)->FJF_COMPRO},,,,,040,.F.,.F.,,,,,))
				oBrwMov:Align :=  CONTROL_ALIGN_ALLCLIENT
				oBrwMov:blDblClick := {|| F472MarExt(cTmpFJF,@aRegExt)}
				oBrwMov:Refresh()
			/*-*/
			oDlgConc:bInit := {|| EnchoiceBar(oDlgConc,{|| F472SelFin(cTmpFJF,@aRegExt,cTmpSE5,@aRegSE5),oBrwMov:Refresh(),If((cTmpFJF)->(eof()),(MsgAlert(STR0036,STR0023),oDlgConc:End()),)},{|| oDlgConc:End()},.F.,aBotoes)}
		oDlgConc:Activate(,,,.T.,,,)
		DbSelectArea(cTmpSE5)
		DbCloseArea()
		//---------------------------------
		//Exclui a tabela 
		//---------------------------------
		oTmpTable2:Delete()
	Endif
	DbSelectArea(cTmpFJF)
	DbCloseArea()
	//---------------------------------
	//Exclui a tabela 
	//---------------------------------
	oTmpTable1:Delete()
	RestArea(aArea)
Endif
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472   บAutor  ณMicrosiga           บFecha ณ 26/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472MarExt(cTmpFJF,aRegExt)
Local nPos		:= 0

Default aRegExt	:= {}
Default cTmpFJF	:= ""

If !Empty(cTmpFJF)
	If Select(cTmpFJF) > 0
		(cTmpFJF)->FJF_MARCA *= -1
		If (cTmpFJF)->FJF_MARCA == 1	//adicionar o registro a array
			nPos := Ascan(aRegExt,{|registro| registro[2] == (cTmpFJF)->NREGMOV})
			If nPos == 0
				Aadd(aRegExt,{(cTmpFJF)->(Recno()),(cTmpFJF)->NREGMOV})
			Endif
		Else		//retirar o registro da array
			nPos := Ascan(aRegExt,{|registro| registro[2] == (cTmpFJF)->NREGMOV})
			If nPos <> 0
				aRegExt := Adel(aRegExt,nPos)
				aRegExt := Asize(aRegExt,Len(aRegExt) - 1)
			Endif
		Endif
	Endif
Endif
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472   บAutor  ณMicrosiga           บFecha ณ  09/25/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472ConMExt(cTmpFJF,nOper)
Local cQuery	:= ""
Local cAliasFJF	:= ""

Default cTmpFJF	:= ""
Default nOper	:= 1		//conciliacao

If !Empty(cTmpFJF)
	If Select(cTmpFJF) > 0
		cQuery += "select FJE.FJE_CODEXT,FJE.R_E_C_N_O_ REGFJE,"
		cQuery += "FJF.FJF_CODEXT,FJF.FJF_SEQEXT,FJF.FJF_DATMOV,FJF.FJF_COMPRO,FJF.FJF_CODCON,FJF.FJF_DESCON,FJF.FJF_VALOR,FJF.R_E_C_N_O_ REGFJF"
		cQuery += " from " + RetSQLName("FJE") + " FJE, " + RetSQLName("FJF") + " FJF"
		cQuery += " where FJE.FJE_FILIAL = '" + xFilial("FJE") + "'"
		cQuery += " and FJE.FJE_BCOCOD = '" + SA6->A6_COD + "'"
		cQuery += " and FJE.FJE_BCOAGE = '" + SA6->A6_AGENCIA + "'"
		cQuery += " and FJE.FJE_BCOCTA = '" + SA6->A6_NUMCON + "'"
		If nOper == 1
			cQuery += " and FJE.FJE_ESTEXT not in ('" + AllTrim(_CEXTINCON) + "','" + AllTrim(_CEXTCONC) + "')"
		Else
			cQuery += " and FJE.FJE_ESTEXT <> '" + AllTrim(_CEXTINCON) + "'"
		Endif
		cQuery += " and FJE.D_E_L_E_T_ = ' '"
		cQuery += " and FJF.FJF_DATMOV >= '" + Dtos(MV_PAR01) + "'"
		If !Empty(MV_PAR02) .And. (MV_PAR02 >= MV_PAR01)
			cQuery += " and FJF.FJF_DATMOV <= '" + Dtos(MV_PAR02) + "'"
		Endif
		If nOper == 1		//para conciliacao seleciona movimentos nao conciliados
			cQuery += " and FJF.FJF_ESTMOV = '" + AllTrim(_CEXTNCONC) + "'"
		Else				//para desconciliacao seleciona movimentos conciliados
			cQuery += " and FJF.FJF_ESTMOV = '" + AllTrim(_CEXTCONC) + "'"
		Endif
		/* movimentos */
		cQuery += " and FJF.FJF_FILIAL = '" + xFilial("FJF") + "'"
		cQuery += " and FJF.FJF_CODEXT = FJE.FJE_CODEXT
		If !Empty(MV_PAR03)		//se informado o conceito
			cQuery += " and FJF.FJF_CODCON = '" + MV_PAR03 + "'"
		Endif
		If !Empty(MV_PAR04)		//se informado um comprovante
			cQuery += " and FJF.FJF_COMPRO = '" + MV_PAR04 + "'"
		Endif
		cQuery += " and Abs(FJF.FJF_VALOR) >= " + AllTrim(Str(MV_PAR05))
		If !Empty(MV_PAR06)		//se informado o valor final
			cQuery += " and Abs(FJF.FJF_VALOR) <= " + AllTrim(Str(MV_PAR06))
		Endif
		cQuery += " and FJF.D_E_L_E_T_= ' '"
		/*-*/
		cQuery := ChangeQuery(cQuery)
		cAliasFJF := GetNextAlias()
		DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasFJF,.F.,.T.)
		TcSetField(cAliasFJF,"FJF_DATMOV","D",8,0)
		(cALiasFJF)->(DbGoTop())
		While !((cAliasFJF)->(Eof()))
			(cTmpFJF)->(DbAppend())
			Replace (cTmpFJF)->FJF_CODEXT	With (cAliasFJF)->FJF_CODEXT
			Replace (cTmpFJF)->FJF_SEQEXT	With (cAliasFJF)->FJF_SEQEXT
			Replace (cTmpFJF)->FJF_DATMOV	With (cAliasFJF)->FJF_DATMOV
			Replace (cTmpFJF)->FJF_CODCON	With (cAliasFJF)->FJF_CODCON
			Replace (cTmpFJF)->FJF_DESCON	With (cAliasFJF)->FJF_DESCON
			Replace (cTmpFJF)->FJF_COMPRO	With (cAliasFJF)->FJF_COMPRO
			Replace (cTmpFJF)->FJF_VALOR	With (cAliasFJF)->FJF_VALOR
			Replace (cTmpFJF)->FJF_MARCA	With -1
			Replace (cTmpFJF)->NREGEXT	With (cAliasFJF)->REGFJE
			Replace (cTmpFJF)->NREGMOV	With (cAliasFJF)->REGFJF
			(cAliasFJF)->(DbSkip())
		Enddo
		(cTmpFJF)->(DbCommit())
		DbSelectArea(cAliasFJF)
		DbCloseArea()
	Endif
Endif
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472   บAutor  ณMicrosiga           บFecha ณ 25/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472ConMFin(cTmpSE5)
Local cQuery		:= ""
Local cAliasSE5		:= ""
Local cTipoCH		:= ""

Default cTmpSE5	:= ""

If !Empty(cTmpSE5)
	If Select(cTmpSE5) > 0
		cTipoCH := IF(Type("MVCHEQUES")=="C",MVCHEQUES,MVCHEQUE)
		/*-*/
		cQuery := "select E5_DATA,E5_VALOR,E5_DOCUMEN,E5_NUMERO,E5_TIPO,E5_PREFIXO,E5_RECPAG,E5_MOVFKS,R_E_C_N_O_ from " + RetSQLName("SE5")
		cQuery += " where E5_FILIAL = '" + xFilial("SE5") + "'"
		cQuery += " and E5_BANCO = '" + SA6->A6_COD + "'"
		cQuery += " and E5_AGENCIA = '" + SA6->A6_AGENCIA + "'"
		cQuery += " and E5_CONTA = '" + SA6->A6_NUMCON + "'"
		cQuery += " and E5_RECONC = ' '"
		cQuery += " and E5_DATA >= '" + Dtos(MV_PAR01) + "'"
		If !Empty(MV_PAR02) .And. (MV_PAR02 >= MV_PAR01)
			cQuery += " and E5_DATA <= '" + Dtos(MV_PAR02) + "'"
		Endif
		cQuery += " and E5_VALOR >= " + AllTrim(Str(MV_PAR05))
		If !Empty(MV_PAR06)		//se informado o valor final
			cQuery += " and E5_VALOR <= " + AllTrim(Str(MV_PAR06))
		Endif
		cQuery += " and E5_SITUACA not in ('C','X','E')"
		cQuery += " and E5_TIPODOC not in " + FormatIn("BA/DC/JR/MT/CM/D2/J2/M2/C2/V2/CP/TL","/") 
		cQuery += " and E5_VALOR > 0"
		cQuery += " and (E5_MOEDA not in " + FormatIn("C1/C2/C3/C4/C5/CH","/") + " OR (E5_MOEDA in " + FormatIn("C1/C2/C3/C4/C5/CH","/") + " and E5_NUMCHEQ <> ' ')) and"
		cQuery += " (E5_NUMCHEQ <> '*' OR (E5_NUMCHEQ = '*' AND E5_RECPAG <> 'P')) AND "  
		cQuery += " ((E5_TIPODOC  IN "+ FormatIn(cTipoCH,"|") + "AND  E5_DTDISPO BETWEEN  '" + DTOS(mv_par01)+ "' AND '"  + DTOS(mv_par02) +"' ) OR "  
		cQuery += " (E5_TIPODOC   NOT IN "+ FormatIn(cTipoCH,"|") + "AND  E5_DTDISPO BETWEEN  '" + DTOS(MV_PAR01)+ "' AND '"  + DTOS(MV_PAR02) +"' )) AND "  
		cQuery += " (E5_NUMCHEQ <> '*' OR (E5_NUMCHEQ = '*' AND E5_RECPAG <> 'P')) "  
		cQuery += " and D_E_L_E_T_= ' '"
		/*-*/
		cQuery := ChangeQuery(cQuery)
		cAliasSE5 := GetNextAlias()
		DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSE5,.F.,.T.)
		TcSetField(cAliasSE5,"E5_DATA","D",8,0)
		(cALiasSE5)->(DbGoTop())
		While !((cAliasSE5)->(Eof()))
			(cTmpSE5)->(DbAppend())
			Replace (cTmpSE5)->E5CHAVE		With Dtos((cAliasSE5)->E5_DATA) + StrZero((cAliasSE5)->E5_VALOR,TamSX3("E5_VALOR")[1],TamSX3("E5_VALOR")[1])
			Replace (cTmpSE5)->E5_DATA		With (cAliasSE5)->E5_DATA
			Replace (cTmpSE5)->E5_VALOR		With (cAliasSE5)->E5_VALOR
			Replace (cTmpSE5)->E5_TIPO		With (cAliasSE5)->E5_TIPO
			Replace (cTmpSE5)->E5_PREFIXO	With (cAliasSE5)->E5_PREFIXO
			Replace (cTmpSE5)->E5_NUMERO	With (cAliasSE5)->E5_NUMERO
			Replace (cTmpSE5)->E5_DOCUMEN	With (cAliasSE5)->E5_DOCUMEN
			Replace (cTmpSE5)->E5_RECPAG	With (cAliasSE5)->E5_RECPAG
			Replace (cTmpSE5)->E5_MARCA		With -1
			Replace (cTmpSE5)->NREGMOV		With (cAliasSE5)->R_E_C_N_O_
			(cAliasSE5)->(DbSkip())
		Enddo
		(cTmpSE5)->(DbCommit())
		DbSelectArea(cAliasSE5)
		DbCloseArea()
	Endif
Endif
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472   บAutor  ณMicrosiga           บFecha ณ 25/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472SelFin(cTmpFJF,aRegExt,cTmpSE5,aRegSE5)
Local lConc		:= .F.
Local aExtratos	:= {}
Local aSize		:= {}
Local aBotoes	:= {}
Local oDlgFin
Local oPnlTop
Local oPnlExt
Local oPnlBco
Local oPnlSep1
Local oBrwSE5
Local oFnt472

Default cTmpSE5	:= ""
Default cTmpFJF	:= ""
Default aRegSE5	:= {}
Default aRegExt	:= {}

If !Empty(cTmpSE5)
	If Select(cTmpSE5) > 0
		If Empty(aRegExt)
			MsgStop(STR0037,STR0023)	//"Primeiramente, selecione os movimentos para a concilia็ใo."
		Else
			lConc := .F.
			Aadd(aBotoes,{"altera",{|| If(F472GerMov(cTmpFJF,@aRegExt),oDlgFin:End(),NIL)},STR0038,STR0025})		//"Gera็ใo de movimento bancแrio"  "Movim. bancแrio"
			(cTmpSE5)->(DbGoTop())
			oFnt472 := TFont():New(,10,16,,.T.,,,)
			cBanco := AllTrim(SA6->A6_COD) + "/" + AllTrim(SA6->A6_AGENCIA) + "/" + AllTrim(SA6->A6_NUMCON) + " - " + AllTrim(SA6->A6_NOME)
			aSize  := FwGetDialogSize(oMainWnd)
			oDlgFin := TDialog():New(aSize[1],aSize[2],aSize[3]*.6,aSize[4]*.6,STR0023,,,,,,,,,.T.,,,,aSize[4]*.6,aSize[3]*.6)
				oPnlSep1 := TPanel():New(0,0,"",oDlgFin,,,,,,100,100,,)
					oPnlSep1:Align := CONTROL_ALIGN_TOP
					oPnlSep1:nHeight := 3
				oPnlTop := TPanel():New(0,0," " + cBanco,oDlgFin,,,,,,100,100,,)
					oPnlTop:Align := CONTROL_ALIGN_TOP
					oPnlTop:nHeight := oDlgFin:nHeight * .05
				/* dados do banco */
				oPnlBco := TPanel():New(0,0," " + cBanco,oPnlTop,oFnt472,,,,,100,100,,)
					oPnlBco:Align := CONTROL_ALIGN_LEFT
					oPnlBco:nWidth := oDlgFin:nWidth * 0.8
				/*-*/
				oPnlExt := TPanel():New(0,0," " + STR0039,oPnlTop,,,,,,100,100,,)		//"Movimentos financeiros"
					oPnlExt:Align := CONTROL_ALIGN_RIGHT
					oPnlExt:nWidth := oDlgFin:nWidth * 0.2
				/*-*/
				oPnlSep2 := TPanel():New(0,0,"",oDlgFin,,,,,RGB(0,0,0),100,100,,)
				oPnlSep2:Align := CONTROL_ALIGN_TOP
				oPnlSep2:nHeight := 1
				oBrwSE5 := TCBrowse():New(0,0,10,10,,,,oDlgFin,,,,,,,,,,,,,cTmpSE5,.T.,,,,.T.,)
				oBrwSE5:AddColumn(TCColumn():New(" ",{|| If((cTmpSE5)->E5_MARCA == 1,"WFCHK","WFUNCHK")},,,,,010,.T.,.F.,,,,,))
				oBrwSE5:AddColumn(TCColumn():New(SE5->(RetTitle("E5_DATA")),{|| (cTmpSE5)->E5_DATA},,,,,020,.F.,.F.,,,,,))
				oBrwSE5:AddColumn(TCColumn():New(SE5->(RetTitle("E5_VALOR")) ,{|| (cTmpSE5)->E5_VALOR},PesqPict("SE5","E5_VALOR"),,,,020,.F.,.F.,,,,,))
				oBrwSE5:AddColumn(TCColumn():New(SE5->(RetTitle("E5_RECPAG")) ,{|| (cTmpSE5)->E5_RECPAG},,,,,010,.F.,.F.,,,,,))
				oBrwSE5:AddColumn(TCColumn():New(SE5->(RetTitle("E5_TIPO")),{|| (cTmpSE5)->E5_TIPO},,,,,010,.F.,.F.,,,,,))
				oBrwSE5:AddColumn(TCColumn():New(SE5->(RetTitle("E5_PREFIXO")),{|| (cTmpSE5)->E5_PREFIXO},,,,,020,.F.,.F.,,,,,))
				oBrwSE5:AddColumn(TCColumn():New(SE5->(RetTitle("E5_NUMERO")),{|| (cTmpSE5)->E5_NUMERO},,,,,040,.F.,.F.,,,,,))
				oBrwSE5:AddColumn(TCColumn():New(SE5->(RetTitle("E5_DOCUMEN")),{|| (cTmpSE5)->E5_DOCUMEN},,,,,040,.F.,.F.,,,,,))
				oBrwSE5:Align :=  CONTROL_ALIGN_ALLCLIENT
				oBrwSE5:blDblClick := {|| F472MarFin(cTmpSE5,@aRegSE5)}
				oBrwSE5:Refresh()
				/*-*/
				oDlgFin:bInit := {|| EnchoiceBar(oDlgFin,{|| MsgRun(STR0040,STR0023,{|| lConc := F472VerSel(cTmpFJF,cTmpSE5,@aRegExt,@aRegSE5)}),If(lConc,oDlgFin:End(),.F.)},{|| lConc := .F.,oDlgFin:End()},.F.,aBotoes)}	//"Verificando os movimentos selecionados."
			oDlgFin:Activate(,,,.T.,,,)
			If lConc
				MsgRun(STR0011,STR0023,{|| lConc := F472RegMan(cTmpFJF,cTmpSE5,@aRegExt,@aRegSE5)})		//"Efetuando a concilia็ใo."
			Endif
		Endif
	Endif
Endif
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472   บAutor  ณMicrosiga           บFecha ณ 26/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472MarFin(cTmpSE5,aRegSE5)
Local nPos		:= 0

Default aRegSE5	:= {}
Default cTmpSE5	:= ""

If !Empty(cTmpSE5)
	If Select(cTmpSE5) > 0
		(cTmpSE5)->E5_MARCA *= -1
		If (cTmpSE5)->E5_MARCA == 1	//adicionar o registro a array
			nPos := Ascan(aRegSE5,{|registro| registro[2] == (cTmpSE5)->NREGMOV})
			If nPos == 0
				Aadd(aRegSE5,{(ctmpSE5)->(Recno()),(cTmpSE5)->NREGMOV})
			Endif
		Else		//retirar o registro da array
			nPos := Ascan(aRegSE5,{|registro| registro[2] == (cTmpSE5)->NREGMOV})
			If nPos <> 0
				aRegSE5 := Adel(aRegSE5,nPos)
				aRegSE5 := Asize(aRegSE5,Len(aRegSE5) - 1)
			Endif
		Endif
	Endif
Endif
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472   บAutor  ณMicrosiga           บFecha ณ  09/26/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472VerSel(cTmpFJF,cTmpSE5,aRegExt,aRegSE5)
Local lRet		:= .F.
Local nValFin	:= 0
Local nValExt	:= 0
Local nReg		:= 0

If Empty(aRegSE5) .Or. Empty(aRegExt)
	lRet := .F.
	MsgStop(STR0037,STR0023)		//"Primeiramente, selecione os movimentos para a concilia็ใo."
Else
	lRet := .T.
	nValFin := 0
	nValExt := 0
	ProcRegua((Len(aRegExt)) + (Len(aRegSE5)))
	For nReg := 1 To Len(aRegExt)
		(cTmpFJF)->(DbGoTo(aRegExt[nReg,1]))
		nValExt += (cTmpFJF)->FJF_VALOR
		IncProc()
	Next
	For nReg := 1 To Len(aRegSE5)
		(cTmpSE5)->(DbGoTo(aRegSE5[nReg,1]))
		nValFin += ((cTmpSE5)->E5_VALOR * If((cTmpSE5)->E5_RECPAG == "P",-1,1))
		IncProc()
	Next
	If nValFin <> nValExt
		MsgStop(STR0041,STR0023)	//"A soma dos valores dos movimentos do extrato nใo ้ a mesma da dos movimentos no financeiro. Verifique os movimentos selecionados."
		lRet := .F.
	Endif
Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472   บAutor  ณMicrosiga           บFecha ณ 26/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472RegMan(cTmpFJF,cTmpSE5,aRegExt,aRegSE5,aRegOut,nOper)
Local nReg		:= 0
Local nPos		:= 0
Local lRet		:= .F.
Local cCpoSE5	:= ""
Local aRegs		:= {}
Local aRegConc	:= {}
Local aExtConc	:= {}

Default cTmpFJF	:= ""
Default cTmpSE5	:= ""
Default aRegSE5	:= {}
Default aRegExt	:= {}
Default aRegOut	:= {}
Default nOper	:= 1	//conciliacao

If nOper == 1
	lRet := !(Empty(aRegSE5) .And. Empty(aRegExt))
Else
	lRet := !Empty(aRegExt)
Endif
If lRet
	lRet := .F.
	ProcRegua((Len(aRegExt) * 2) + (Len(aRegSE5) * 2) + Len(aRegOut))
	Begin Transaction
		If nOper == 1		//concilia็ใo
			aRegConc := {}
			/* registros do extrato bancario */
			For nReg := 1 To Len(aRegExt)
				Aadd(aRegConc,{"FJF",aRegExt[nReg,2]})
				IncProc()
			Next
			/* registros do movimento no financeiro */
			For nReg := 1 To Len(aRegSE5)
				Aadd(aRegConc,{"SE5",aRegSE5[nReg,2]})
				IncProc()
			Next
			/* registros de outros documentos */
			For nReg := 1 To Len(aRegOut)
				Aadd(aRegConc,{aRegOut[nReg,1],aRegOut[nReg,2]})
				IncProc()
			Next
			If F472ARegConc(Aclone(aRegConc))
				/* atualiza os movimentos no extrato e no financeiro */
				For nReg := 1 To Len(aRegSE5)
					SE5->(DbGoto(aRegSE5[nReg,2]))
					cCpoSE5 := "{" 
					cCpoSE5 += "{'E5_RECONC', 'x'}""
					If aRegSE5[nReg,1] == 0 
						cCpoSE5 += ",{'E5_ORIGEM', 'FINA472'}"
						cCpoSE5 += ",{'E5_NUMERO','" + StrZero(SE5->(Recno()),TamSX3("E5_NUMERO")[1],0) + "'}"
						cCpoSE5 += ",{'E5_PREFIXO','F47'}"
					Endif
					cCpoSE5 += "}"
					lRet := F472ConFKS(aRegSE5[nReg,2],cCpoSE5,nOper)
					
					If lRet
						/* 
						eliminando o registro do arquivo temporario */
						If aRegSE5[nReg,1] <> 0		//Se 0, indica que o movimento bancario foi gerado por esta rotina.
							(cTmpSE5)->(DbGoTo(aRegSE5[nReg,1]))
							(cTmpSE5)->(DbDelete())

							If Alltrim(SE5->E5_TIPO) == "CH" .and.  cPaisLoc=="ARG" .and. FUNNAME()=="FINA472"
								F472CtrlCh(nOper)
							Endif
						Else
							/*
							Se o movimento for referente a cheque, atualiza o controle de cheques */
							If Alltrim(SE5->E5_TIPO) == "CH"
								F472CtrlCh(nOper)
							Endif
						Endif
					Endif
					IncProc()
				Next
				/*-*/
				For nReg := 1 To Len(aRegExt)
					FJF->(DbGoto(aRegExt[nReg,2]))
					RecLock("FJF",.F.)
					/* Inclui o extrato na lista de conciliados para verificar, ao final da conciliacao, se ele foi totalmente conciliado */
					nPos := Ascan(aExtConc,FJF->FJF_CODEXT)
					If nPos == 0
						Aadd(aExtConc,FJF->FJF_CODEXT)
					Endif
					/*-*/
					Replace FJF->FJF_ESTMOV	With _CMOVCONC
					FJF->(MsUnLock())
					/* eliminando o registro do arquivo temporario */
					(cTmpFJF)->(DbGoTo(aRegExt[nReg,1]))
					(cTmpFJF)->(DbDelete())
					IncProc()
				Next
				/*-*/
				lRet := .T.
				aRegExt := {}
				aRegSE5 := {}
				aRegOut	:= {}
			Endif
		Else		//desconciliacao
			aRegs := {}
			For nReg := 1 To Len(aRegExt)
				Aadd(aRegs,{"FJF",aRegExt[nReg,2]})
			Next
			aRegConc := F472ARegDConc(Aclone(aRegs))
			/*
			executar a reversao correspondente */
			lRet := .T.
			nReg := 0
			While lRet .And. (nReg < Len(aRegConc))
				nReg++
				Do Case 
					Case aRegConc[nReg,1] == "SE5"		//movimento financeiro
						SE5->(DbGoto(aRegConc[nReg,2]))
						If !Empty(SE5->E5_RECONC)
							cCpoSE5 := "{" 
							cCpoSE5 += "{'E5_RECONC', ' '}""
							cCpoSE5 += "}"
							lRet := F472ConFKS(aRegConc[nReg,2],cCpoSE5,nOper)
							If lRet
								If AllTrim(SE5->E5_ORIGEM) == "FINA472"	//Se o movimento foi gerado por esta rotina, ele sera excluido 
									aRegs := {}
									Aadd(aRegs,{"E5_BANCO"  ,SE5->E5_BANCO,Nil})
									Aadd(aRegs,{"E5_AGENCIA",SE5->E5_AGENCIA,Nil})
									Aadd(aRegs,{"E5_CONTA"  ,SE5->E5_CONTA,Nil})
									Aadd(aRegs,{"E5_PREFIXO",SE5->E5_PREFIXO,Nil})
									Aadd(aRegs,{"E5_NUMERO" ,SE5->E5_NUMERO,Nil})
									Aadd(aRegs,{"E5_PARCELA",SE5->E5_PARCELA,Nil})
									Aadd(aRegs,{"E5_TIPO"   ,SE5->E5_TIPO,Nil})
									Aadd(aRegs,{"E5_DOCUMEN",SE5->E5_DOCUMEN,Nil})
									Aadd(aRegs,{"E5_DATA"   ,SE5->E5_DATA,Nil})
									Aadd(aRegs,{"INDEX"	  	,3,Nil})
									Fina100(0,aRegs,5)
								Else
									/*
									Se o movimento for referente a cheque, atualiza o controle de cheques */
									If AllTrim(SE5->E5_TIPO) == "CH"
										F472CtrlCh(nOper)
									Endif
								Endif
							Endif
						Endif
					Case aRegConc[nReg,1] == "FJF"		//movimento no extrato bancario
						FJF->(DbGoto(aRegConc[nReg,2]))
						RecLock("FJF",.F.)
						/* Inclui o extrato na lista de desconciliados para atualizar o seu estado ao final da conciliacao */
						nPos := Ascan(aExtConc,FJF->FJF_CODEXT)
						If nPos == 0
							Aadd(aExtConc,FJF->FJF_CODEXT)
						Endif
						/*-*/
						Replace FJF->FJF_ESTMOV	With _CMOVNCONC
					Case aRegConc[nReg,1] == "SF1"		//movimento fiscal
						lRet := F472GerFis(aRegConc[nReg],2)
					Case aRegConc[nReg,1] == "SF2"		//movimento fiscal
						lRet := F472GerFis(aRegConc[nReg],2)
				EndCase
			Enddo
			aRegSE5 := {}
		Endif
		/*
		Atualiza o estado dos estratos apos o termino da operacao */
		If lRet
			If nOper == 1	//conciliacao
				Processa({|| F472VerExtMan(aExtConc,nOper)},STR0023,STR0042)		//"Verificando os extratos conciliados."
			Else
				Processa({|| F472VerExtMan(aExtConc,nOper)},STR0028,STR0043)		//"Verificando os extratos desconciliados."
			Endif
		Else
			DisarmTrans()
		Endif
	End Transaction
	If lRet
		If nOper == 1
			MsgInfo(STR0044,STR0023)		//"Concilia็ใo efetuada"
		Else
			MsgInfo(STR0045,STR0028)		//"Desconcilia็ใo efetuada"
		Endif
	Endif
Else
	MsgStop(STR0037,STR0023)		//"Primeiramente, selecione os movimentos para a concilia็ใo."
Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472   บAutor  ณMicrosiga           บFecha ณ  09/28/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472VerExtMan(aExtConc,nOper)
Local nExtr			:= 0

Default aExtConc	:= {}
Default nOper		:= 0
        
If !Empty(aExtConc)
	ProcRegua(Len(aExtConc))
	For nExtr := 1 To Len(aExtConc)
		F472VerEst(aExtConc[nExtr],.F.,nOper)
		IncProc()
	Next
Endif
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472   บAutor  ณMicrosiga           บFecha ณ 25/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472DConcMan()
Local cArqFJF	:= ""
Local cTmpFJF	:= "TMPFJF"
Local lConc		:= .F.
Local aArea		:= {}
Local aEstr		:= {}
Local aSize		:= {}
Local aRegExt	:= {}
Local oDlgConc
Local oBrwMov
Local oPnlTop
Local oPnlExt
Local oPnlBco
Local oPnlSep1
Local oPnlSep2
Local oFnt472
Local aTmpFJF		:= {}
Private oTmpTable3


If Pergunte("F472CON",.T.)
	aArea := GetArea()
	AAdd(aEstr,{"FJF_CODEXT","C",TamSX3("FJF_CODEXT")[1],TamSX3("FJF_CODEXT")[2]})
	AAdd(aEstr,{"FJF_SEQEXT","C",TamSX3("FJF_SEQEXT")[1],TamSX3("FJF_SEQEXT")[2]})
	AAdd(aEstr,{"FJF_DATMOV","D",TamSX3("FJF_SEQEXT")[1],TamSX3("FJF_SEQEXT")[2]})
	AAdd(aEstr,{"FJF_CODCON","C",TamSX3("FJF_CODCON")[1],TamSX3("FJF_CODCON")[2]})
	AAdd(aEstr,{"FJF_DESCON","C",TamSX3("FJF_DESCON")[1],TamSX3("FJF_DESCON")[2]})
	AAdd(aEstr,{"FJF_COMPRO","C",TamSX3("FJF_COMPRO")[1],TamSX3("FJF_DESCON")[2]})
	AAdd(aEstr,{"FJF_VALOR" ,"N",TamSX3("FJF_VALOR")[1] ,TamSX3("FJF_VALOR")[2]})
	AAdd(aEstr,{"FJF_MARCA" ,"N",2,0})
	AAdd(aEstr,{"NREGEXT" ,"N",010,0})
	AAdd(aEstr,{"NREGMOV" ,"N",010,0})
	/*-*/
	
	aTmpFJF:={"FJF_CODEXT"}
	oTmpTable3:= FWTemporaryTable():New(cTmpFJF) 
	oTmpTable3:SetFields( aEstr ) 
	oTmpTable3:AddIndex("1",aTmpFJF)
	//Creacion de la tabla
	oTmpTable3:Create()
	
	DbSelectArea(cTmpFJF)
	/*-*/
	MsgRun(STR0042,STR0028,{|| F472ConMExt(cTmpFJF,2)})//"Verificando os movimentos conciliados"
	(cTmpFJF)->(DbGoTop())
	If ((cTmpFJF)->(Eof()))
		MsgAlert(STR0046,STR0028)		//"Nใo hแ movimentos para serem desconciliados."
	Else 
		lConc := .F.
		oFnt472 := TFont():New(,10,16,,.T.,,,)
		cBanco := AllTrim(SA6->A6_COD) + "/" + AllTrim(SA6->A6_AGENCIA) + "/" + AllTrim(SA6->A6_NUMCON) + " - " + AllTrim(SA6->A6_NOME)
		aRegExt := {}
		aSize := FwGetDialogSize(oMainWnd)
		oDlgConc := TDialog():New(aSize[1],aSize[2],aSize[3]*.8,aSize[4]*.8,STR0028,,,,,,,,,.T.,,,,aSize[4]*.8,aSize[3]*.8)
			oPnlSep1 := TPanel():New(0,0,"",oDlgConc,,,,,,100,100,,)
				oPnlSep1:Align := CONTROL_ALIGN_TOP
				oPnlSep1:nHeight := 3
			oPnlTop := TPanel():New(0,0," " + cBanco,oDlgConc,,,,,,100,100,,)
				oPnlTop:Align := CONTROL_ALIGN_TOP
				oPnlTop:nHeight := oDlgConc:nHeight * .05
				/* dados do banco */
				oPnlBco := TPanel():New(0,0," " + cBanco,oPnlTop,oFnt472,,,,,100,100,,)
					oPnlBco:Align := CONTROL_ALIGN_LEFT
					oPnlBco:nWidth := oDlgConc:nWidth * 0.8
				/*-*/
				oPnlExt := TPanel():New(0,0," " + STR0047,oPnlTop,,,,,,100,100,,)		//"Movimentos conciliados"
					oPnlExt:Align := CONTROL_ALIGN_RIGHT
					oPnlExt:nWidth := oDlgConc:nWidth * 0.2
			/*-*/
			oPnlSep2 := TPanel():New(0,0,"",oDlgConc,,,,,RGB(0,0,0),100,100,,)
				oPnlSep2:Align := CONTROL_ALIGN_TOP
				oPnlSep2:nHeight := 1
			oBrwMov := TCBrowse():New(0,0,10,10,,,,oDlgConc,,,,,,,,,,,,,cTmpFJF,.T.,,,,.T.,)
				oBrwMov:AddColumn(TCColumn():New(" ",{|| If((cTmpFJF)->FJF_MARCA == 1,"WFCHK","WFUNCHK")},,,,,010,.T.,.F.,,,,,))
				oBrwMov:AddColumn(TCColumn():New(FJF->(RetTitle("FJF_CODEXT")),{|| (cTmpFJF)->FJF_CODEXT},,,,,020,.F.,.F.,,,,,))
				oBrwMov:AddColumn(TCColumn():New(FJF->(RetTitle("FJF_SEQEXT")),{|| (cTmpFJF)->FJF_SEQEXT},,,,,020,.F.,.F.,,,,,))
				oBrwMov:AddColumn(TCColumn():New(FJF->(RetTitle("FJF_DATMOV")),{|| (cTmpFJF)->FJF_DATMOV},,,,,020,.F.,.F.,,,,,))
				oBrwMov:AddColumn(TCColumn():New(FJF->(RetTitle("FJF_CODCON")),{|| (cTmpFJF)->FJF_CODCON},,,,,020,.F.,.F.,,,,,))
				oBrwMov:AddColumn(TCColumn():New(FJF->(RetTitle("FJF_DESCON")),{|| (cTmpFJF)->FJF_DESCON},,,,,030,.F.,.F.,,,,,))
				oBrwMov:AddColumn(TCColumn():New(FJF->(RetTitle("FJF_VALOR")) ,{|| (cTmpFJF)->FJF_VALOR},PesqPict("FJF","FJF_VALOR"),,,,020,.F.,.F.,,,,,))
				oBrwMov:AddColumn(TCColumn():New(FJF->(RetTitle("FJF_COMPRO")),{|| (cTmpFJF)->FJF_COMPRO},,,,,040,.F.,.F.,,,,,))
				oBrwMov:Align :=  CONTROL_ALIGN_ALLCLIENT
				oBrwMov:blDblClick := {|| F472MarExt(cTmpFJF,@aRegExt)}
				oBrwMov:Refresh()
			/*-*/
			oDlgConc:bInit := {|| EnchoiceBar(oDlgConc,{|| Processa({|| lConc := F472RegMan(cTmpFJF,,aRegExt,,,2)}),If(lConc,oDlgConc:End(),.F.)},{|| lConc := .F.,oDlgConc:End()},.F.,)}
		oDlgConc:Activate(,,,.T.,,,)
	Endif
	DbSelectArea(cTmpFJF)
	DbCloseArea()
	//---------------------------------
	//Exclui a tabela 
	//---------------------------------
	oTmpTable3:Delete()

	RestArea(aArea)
Endif
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472   บAutor  ณMicrosiga           บFecha ณ 27/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472GerMov(cTmpFJF,aRegExt)
Local cClieFor		:= ""
Local cLoja			:= ""
Local lRet			:= .T.
Local nReg			:= 0
Local nPos			:= 0
Local aDocFis		:= {}		//contem os conceitos para os quais se deve gerar documento fiscal
Local aFJE			:= {}
Local aFJF			:= {}
Local aFJG			:= {}
Local aSA6			:= {}
Local aArea			:= {}

/*
Variaveis de controle externo, atualizadas pela funcao F472DadosMov. Esta funcao deve ser executada pelo programa externo (fina100 por exemplo)
passando o valor e o item correspondente. Veja a funcao F472DadosMov. */
Private _nVal472_	:= 0		//valor da soma dos movimentos do extrato selecionados para conciliacao
Private _lIncMov_	:= .F.		//indica se o movimento ou documento foi incluido (.T.) ou nao (.F.)
Private _aSE5472_	:= {}		//contem os registros dos movimentos incluidos na SE5 para a conciliacao
Private _aReg472_	:= {}		//contem os registros de outros documentos, como notas de debito, no formato { {tabela,recno},{tabela,recno},...}
Private _lGerFis_	:= .F.		//indica que ha a geracao de documentos fiscais

Default cTmpFJF	:= ""
Default aRegExt	:= {}

If Empty(aRegExt)
	lRet := .F.
	MsgStop(STR0037,STR0023)		//"Primeiramente, selecione os movimentos para a concilia็ใo."
Else
	_nVal472_ := 0
	_lGerFis  := .F.
	For nReg := 1 To Len(aRegExt)
		(cTmpFJF)->(DbGoTo(aRegExt[nReg,1]))
		_nVal472_ += (cTmpFJF)->FJF_VALOR
		/*
		Verifica movimentos que pedem documento fiscal. */
		cConceito := (cTmpFJF)->FJF_CODCON
		If SEJ->(MsSeek(xFilial("SEJ") + SA6->A6_COD + (cTmpFJF)->FJF_CODCON))
			If SEJ->EJ_GERFIS == "1"	//gerar documento fiscal
				/* procura na lista pelo conceito e acumula o valor do movimento para o documento fiscal */
				_lGerFis_ := .T.
				nPos := Ascan(aDocFis,{|conceito| conceito[1] == (cTmpFJF)->FJF_CODCON})
				If nPos == 0
					Aadd(aDocFis,{(cTmpFJF)->FJF_CODCON,SEJ->EJ_ALQIMP,0})
					nPos := Len(aDocFis)
				Endif
				aDocFis[nPos,3] += (cTmpFJF)->FJF_VALOR
			Endif
		Endif
	Next
	If _nVal472_ == 0
		MsgStop(STR0048,STR0023)		//"A soma dos valores dos movimentos selecionados ้ igual a zero. Para gerar o movimento bancแrio, ela deve ser diferente de zero."
	Else
		lRet := .F.
		aArea := GetArea()
		aSA6 := SA6->(GetArea("SA6"))
		aFJE := FJE->(GetArea("FJE"))
		aFJF := SA6->(GetArea("FJF"))
		aFJG := SA6->(GetArea("FJG"))
		Begin Transaction
			If _nVal472_ < 0
				MsgRun(STR0049,STR0023,{|| Fina100(3)})		//"Inclusใo de movimento bancแrio."
			Else
				MsgRun(STR0049,STR0023,{|| Fina100(4)})		//"Inclusใo de movimento bancแrio."
			Endif
			/*
			Efetua a conciliacao, caso o movimento financeiro tenha sido incluido corretamente. */
			If _lIncMov_
				aRegSE5 := {}
				For nReg := 1 To Len(_aSE5472_)
					Aadd(aRegSE5,{0,_aSE5472_[nReg]})		//O primeira item do array sendo 0, indica que o registro foi incluido por esta rotina.
					SE5->(DbGoTo(_aSE5472_[nReg]))
					cClieFor := SE5->E5_CLIFOR
					cLoja := SE5->E5_LOJA
				Next
				/*
				gera os documentos fiscais para os conceitos que pedem isso */
				If Len(aDocFis) > 0
					MsgRun(STR0050,STR0023,{|| lRet := F472GerFis(@aDocFis,1,cClieFor,cLoja)})		//"Gerando documentos fiscais."
				Else
					lRet := .T.
				Endif
				If lRet
					lRet := F472RegMan(cTmpFJF,"",@aRegExt,@aRegSE5,@_aReg472_,1)
				Else
					lRet := .F.
				Endif				
			Endif
			If !lRet
				DisarmTrans()
			Endif
		End Transaction
		DbSelectArea("SA6")
		RestArea(aSA6)
		DbSelectArea("FJE")
		RestArea(aFJE)
		DbSelectArea("FJF")
		RestArea(aFJF)
		DbSelectArea("FJG")
		RestArea(aFJG)
		RestArea(aArea)
	Endif
Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472   บAutor  ณMicrosiga           บFecha ณ 27/09/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atribui os valores iniciais ao movimento a ser gerado      บฑฑ
ฑฑบ          ณ no financeiro. Esses valores nao devem ser alterados       บฑฑ
ฑฑบ          ณ pelo usuario pois sao orignais do extrato bancario.        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ A funcao F472CposMov determina os campos que nao podem     บฑฑ
ฑฑบ          ณ ser alterados.                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472MovFin()
M->E5_TIPOMOV	:= If(_lGerFis_,"01","02")
M->E5_VALOR		:= Abs(_nVal472_)
M->E5_BANCO		:= SA6->A6_COD
M->E5_AGENCIA	:= SA6->A6_AGENCIA
M->E5_CONTA		:= SA6->A6_NUMCON
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472   บAutor  ณMicrosiga           บFecha ณ  09/27/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472DadosMov(xVal,cTipo)
Default xVal	:= 0
Default cTipo	:= ""

If !Empty(cTipo)
	Do Case
		Case cTipo == "SE5"
			If Type("_aSE5472_") == "A"
				Aadd(_aSE5472_,xVal)
			Endif
		Case cTipo == "OUTROS"
			If Type("_aReg472_") == "A"
				Aadd(_aReg472_,Aclone(xVal))
			Endif
		Case cTipo == "INCMOV"
			If ValType(xVal) == "L"
				_lIncMov_ := xVal
			Else
				_lIncMov_ := .F.
			Endif
	EndCase
Endif
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472   บAutor  ณMicrosiga           บFecha ณ  09/28/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472CposMov(aCpos)
Local nCpo		:= 0
Local nDel		:= 0
Local nPos		:= 0
Local aCposBlq	:= {}

Default aCpos	:= {}
/* 
campos preenchidos pela conciliacao e que nao poderao ser alterados */
aCposBlq := {}
Aadd(aCposBlq,"E5_VALOR")
Aadd(aCposBlq,"E5_BANCO")
Aadd(aCposBlq,"E5_AGENCIA")
Aadd(aCposBlq,"E5_CONTA")
Aadd(aCposBlq,"E5_TIPOMOV")
/*-*/
nDel := 0
For nCpo := 1 To Len(aCposBlq)
	nPos := Ascan(aCpos,{|cpos| Alltrim(cpos) == AllTrim(aCposBlq[nCpo])})
	If nPos > 0
		Adel(aCpos,nPos)
		nDel++
	Endif
Next
If nDel > 0
	aCpos := Asize(aCpos,Len(aCpos)-nDel)
Endif
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472   บAutor  ณMicrosiga           บFecha ณ 01/10/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472GerFis(aDocFis,nOper,cClFo,cLj)
Local cTexto	:= ""
Local cTabDB	:= ""
Local cTabCR	:= ""
Local cTabDoc	:= ""
Local cClieFor	:= ""
Local cProd		:= ""
Local cLoja		:= ""
Local lGerCR	:= .F.
Local lGerDB	:= .F.
Local lRet		:= .T.
Local nDoc		:= 0
Local nConcs	:= 0
Local nValor	:= 0
Local nTipoDeb	:= 1
Local nTipoCre	:= 1
Local nTipoCR	:= 0
Local nTipoDB	:= 0
Local aSize		:= {}
				/* {especie de documento,descricao,tipo,tabela gravacao} */
Local aNDsC		:= {{"NCP","",7,"SF2"},{"NDI","",6,"SF2"}}		//tipos de notas para movimentos a receber (valor > 0)
Local aNDsD		:= {{"NDP","",9,"SF1"},{"NCI","",8,"SF1"}}		//tipos de notas para movimentos a pagar (valor < 0)
Local aEspecieC	:= {}
Local aEspecieD	:= {}
Local oDlgFis
Local oPnlDeb
Local oPnlCre
Local oPnlEsqD
Local oPnlEsqC
Local oPnlSep1
Local oPnlSep2
Local oPnlMsg
Local oRadBDeb
Local oRadBCre

Default aDocFis	:= {}
Default nOper	:= 0
Default cClFo	:= ""
Default cLj		:= ""

If !Empty(aDocFis)
	If nOper == 1	//conciliacao
		nConcs := Len(aDocFis)
		If nConcs > 1
			cTexto := STR0051 + CRLF + CRLF		//"Serแ gerado um documento fiscal para cada conceito abaixo:"
			For nDoc := 1 To nConcs
				cTexto += aDoscs[nDoc,1] + CRLF
			Next
			MsgAlert(cTexto,STR0023 + " - " + STR0052)		//"gera็ใo de documento fiscal"
		Endif
		lGerDB := (Ascan(aDocFis,{|docfis| docfis[3] < 0}) > 0)
		lGerCR := (Ascan(aDocFis,{|docfis| docfis[3] > 0}) > 0)
		cClieFor := cClFo
		cLoja := cLj
	ElseIf nOper == 2	//Desconciliacao
		nConcS := 1
		cTabDoc := aDocFis[1]
		(cTabDoc)->(DbGoto(aDocFis[2]))
		If cTabDoc == "SF1"
			cClieFor := SF1->F1_FORNECE
			cLoja := SF1->F1_LOJA
			SD1->(DbSetOrder(1))
			If SD1->(MsSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))
				cProd := SD1->D1_COD
				nValor := SD1->D1_VUNIT
			Endif
		Else
			cClieFor := SF2->F2_CLIENTE
			cLoja := SF2->F2_LOJA
			SD2->(DbSetOrder(3))
			If SD2->(MsSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA))
				cProd := SD2->D2_COD
				nValor := SD2->D2_PRCVEN
			Endif
		Endif
		lGerDB := (Ascan(aNDsC,{|tabela| tabela[4] == cTabDoc}) > 0)
		lGerCR := (Ascan(aNDsD,{|tabela| tabela[4] == cTabDoc}) > 0)
	Endif
Endif		
/*-*/
If lGerDB .Or. lGerCR
	/*
	selecao do tipo de documento a ser gerado */
	aEspecieC := {}
	For nDoc := 1 To Len(aNDsC)
		If SX5->(MsSeek(xFilial("SX5") + "42" + PadR(aNDsC[nDoc,1],Len(SX5->X5_CHAVE))))
			aNDsC[nDoc,2] := AllTrim(Lower(X5Descri()))
			Aadd(aEspecieC,AllTrim(aNDsC[nDoc,1]) + "=" + aNDsC[nDoc,2])
		Endif
	Next
	aEspecieD := {}
	For nDoc := 1 To Len(aNDsD)
		If SX5->(MsSeek(xFilial("SX5") + "42" + PadR(aNDsD[nDoc,1],Len(SX5->X5_CHAVE))))
			aNDsD[nDoc,2] := AllTrim(Lower(X5Descri()))
			Aadd(aEspecieD,AllTrim(aNDsD[nDoc,1]) + "=" + aNDsD[nDoc,2])
		Endif
	Next
	aSize := FwGetDialogSize(oMainWnd)
	oDlgFis := TDialog():New(aSize[1],aSize[2],aSize[3]*.4,aSize[4]*.4,If(nOper == 1,STR0023,STR0028) + " - " + STR0052,,,,,,,,,.T.,,,,aSize[4]*.4,aSize[3]*.4)
		oPnlSep1 := TPanel():New(0,0,"",oDlgFis,,,,,,100,100,,)
			oPnlSep1:Align := CONTROL_ALIGN_TOP
			oPnlSep1:nHeight := 10
		If lGerDB
			/* tipo para valores a debito */
			oPnlMsgD := TPanel():New(0,0," " + STR0053,oDlgFis,,,,,,100,100,,)		//"Selecione o tipo de documento para valores a d้bito"
				oPnlMsgD:Align := CONTROL_ALIGN_TOP
				oPnlMsgD:nHeight := oDlgFis:nHeight * .10
			oPnlDeb := TPanel():New(0,0," ",oDlgFis,,,,,,100,100,,)
				oPnlDeb:Align := CONTROL_ALIGN_TOP
				oPnlDeb:nHeight := oDlgFis:nHeight * .30
				oPnlEsqD := TPanel():New(0,0,"",oPnlDeb,,,,,,100,100,,)
					oPnlEsqD:Align := CONTROL_ALIGN_LEFT
					oPnlEsqD:nWidth := 10
				oRadBDeb := TRadMenu():New(0,0,aEspecieD,{|u| If (PCount()==0,ntipoDeb,nTipoDeb:=u)},oPnlDeb,,,,,,,,100,100,,,,.T.)
				oRadBDeb:Align := CONTROL_ALIGN_ALLCLIENT
			oPnlSep2 := TPanel():New(0,0,"",oDlgFis,,,,,,100,100,,)
				oPnlSep2:Align := CONTROL_ALIGN_TOP
				oPnlSep2:nHeight := 10
		Endif
		If lGerCR
			/* tipo para valores a credito */
			oPnlMsgC := TPanel():New(0,0," " + STR0054,oDlgFis,,,,,,100,100,,)		//"Selecione o tipo de documento para valores a cr้dito"
				oPnlMsgC:Align := CONTROL_ALIGN_TOP
				oPnlMsgC:nHeight := oDlgFis:nHeight * .10
			oPnlCre := TPanel():New(0,0," ",oDlgFis,,,,,,100,100,,)
				oPnlCre:Align := CONTROL_ALIGN_ALLCLIENT
			oPnlEsqC := TPanel():New(0,0,"",oPnlCre,,,,,,100,100,,)
				oPnlEsqC:Align := CONTROL_ALIGN_LEFT
				oPnlEsqC:nWidth := 10
			oRadBCre := TRadMenu():New(0,0,aEspecieC,{|u| If (PCount()==0,ntipoCre,nTipoCre:=u)},oPnlCre,,,,,,,,100,100,,,,.T.)
				oRadBCre:Align := CONTROL_ALIGN_ALLCLIENT
		Endif
	oDlgFis:bInit := {|| EnchoiceBar(oDlgFis,{|| lRet := .T.,oDlgFis:End()},{|| lRet := .F.,oDlgFis:End()},.F.,)}
	oDlgFis:Activate(,,,.T.,,,)
	/*-*/
	If lRet
		cTabDB := aNDsD[nTipoDeb,4]
		nTipoDeb := aNDsD[nTipoDeb,3]
		cTabCR := aNDsC[nTipoCre,4]
		nTipoCre := aNDsC[nTipoCre,3]
		nDoc := 0
		lRet := .T.
		While lRet .And. (nDoc < nConcs)
			nDoc++
			_lIncMov_ := .F.		//atualizada pela F472NDGer(), ao final da gravacao da nota
			If nOper == 1
				nValor := aDocFis[nDoc,3] / (1 + (aDocFis[nDoc,2] / 100))
				If aDocFis[nDoc,3] < 0
					NFxInclui(nTipoDeb,{|| A472DadosND(1,cTabDB,Abs(nValor),,cClieFor,cLoja)},.F.)
				Else
					NFxInclui(nTipoCre,{|| A472DadosND(1,cTabCR,nValor,,cClieFor,cLoja)},.F.)
				Endif
			Else
				If lGerDB
					NFxInclui(nTipoDeb,{|| A472DadosND(2,cTabDB,nValor,cProd,cClieFor,cLoja)},.F.)
				Else
					NFxInclui(nTipoCre,{|| A472DadosND(2,cTabCR,nValor,cProd,cClieFor,cLoja)},.F.)
				Endif
			Endif
			lRet := _lIncMov_
		Enddo
	Endif
Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472   บAutor  ณMicrosiga           บFecha ณ 01/10/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A472DadosND(nOper,cTab,nValND,cProd,cClieFor,cLoja)
Local nItem			:= 0
Local nPosQtd		:= 0
Local nPosVlrUn		:= 0
Local nPosTotal		:= 0
Local nPosTES		:= 0
Local nPosProd		:= 0
Local cValidacao	:= ""
Local cPrefCab		:= ""
Local cPrefItem		:= ""
Local bValid		:= {|| }

Default nOper		:= 1
Default nValND		:= 0
Default cClieFor	:= ""
Default cLoja		:= ""
Default cProd		:= ""
Default cTab		:= ""

If nValND > 0 .And. cTab $ "SF1|SF2"
	/* inicializa os dados do cebecalho da nota */
	If !Empty(cClieFor) .And. !Empty(cLoja)
		If cTab == "SF1"
			M->F1_FORNECE := cClieFor
			M->F1_LOJA := cLoja
		Else
			M->F2_CLIENTE := cClieFor
			M->F2_LOJA := cLoja
		Endif
		/* impede a edicao do fornecedor */
		If Type("__aoGets")!= "U" .And. ValType(__aoGets)=="A" 
			nItem := Ascan(__aoGets,{|aget| AllTrim(Upper(aget:cReadVar)) == If(cTab == "SF1","M->F1_FORNECE","M->F2_CLIENTE")})
			If nItem > 0
				__aoGets[nItem]:bWhen := {|| .F.}
			Endif
			nItem := Ascan(__aoGets,{|aget| AllTrim(Upper(aget:cReadVar)) == If(cTab == "SF1","M->F1_LOJA","M->F2_LOJA")})
			If nItem > 0
				__aoGets[nItem]:bWhen := {|| .F.}
			Endif
		Endif
	Endif
	/*
	inicializa os dados dos itens */
	nPosQtd   := Ascan(aHeader,{|cpo| AllTrim(cpo[2]) == If(cTab == "SF1","D1_QUANT","D2_QUANT")})
	nPosVlrUn := Ascan(aHeader,{|cpo| AllTrim(cpo[2]) == If(cTab == "SF1","D1_VUNIT","D2_PRCVEN")})
	nPosTotal := Ascan(aHeader,{|cpo| AllTrim(cpo[2]) == If(cTab == "SF1","D1_TOTAL","D2_TOTAL")})
	nPosTES   := Ascan(aHeader,{|cpo| AllTrim(cpo[2]) == If(cTab == "SF1","D1_TES","D2_TES")})
	nPosProd   := Ascan(aHeader,{|cpo| AllTrim(cpo[2]) == If(cTab == "SF1","D1_COD","D2_COD")})
	aCols := {}
	oGetDados:AddLine()
	aCols[1,nPosQtd] := 1
	aCols[1,nPosVlrUn] := nValND
	aCols[1,nPosTotal] := nValND
	If !Empty(cProd)
		aCols[1,nPosProd]  := cProd
	Endif
	/*-*/
	cValidacao := "(n >= 1)"
	/*
	altera a validacao da quantidade para nao permitir sua alteracao */
	If Empty(aHeader[nPosQtd,6])
		aHeader[nPosQtd,6] := cValidacao
	Else
		aHeader[nPosQtd,6] := cValidacao + " .And. " + aHeader[nPosQtd,6]
	Endif
	/*
	altera a validacao do valor para nao permitir sua alteracao */
	If Empty(aHeader[nPosVlrUn,6])
		aHeader[nPosVlrUn,6] := cValidacao
	Else
		aHeader[nPosVlrUn,6] := cValidacao + " .And. " + aHeader[nPosVlrUn,6]
	Endif
	/*
	altera a validacao do valor total para nao permitir sua alteracao */
	If Empty(aHeader[nPosTotal,6])
		aHeader[nPosTotal,6] := cValidacao
	Else
		aHeader[nPosTotal,6] := cValidacao + " .And. " + aHeader[nPosTotal,6]
	Endif
	/*
	nao permite TES que atualizem estoque e/ou que gerem titulos*/
	If Empty(aHeader[nPosTES,6])
		aHeader[nPosTES,6] := "F472NDTES(M->" + If(cTab == "SF1","D1_TES","D2_TES") + ")"
	Else
		aHeader[nPosTES,6] := "F472NDTES(M->" + If(cTab == "SF1","D1_TES","D2_TES") + ") .And. " + aHeader[nPosTES,6]
	Endif
	/*-*/
	If Empty(oGetDados:cLinhaOK)
		oGetDados:cLinhaOK := "F472NDTES() .And. " + cValidacao
	Else
		
		oGetDados:cLinhaOK := "(F472NDTES() .And. " + cValidacao + ") .And. " + oGetDados:cLinhaOK
	Endif
	If Empty(oGetDados:cTudoOK)
		oGetDados:cTudoOK := "F472NDTES()"
	Else
		oGetDados:cTudoOK := "F472NDTES() .And. " + oGetDados:cTudoOK
	Endif
	/*
	nao pemite a exclusao dos itens referentes aos documentos devolvidos */
	If Empty(oGetDados:cSuperDel)
		oGetDados:cSuperDel := cValidacao
	Else
		oGetDados:cSuperDel := cValidacao + ".And. " + oGetDados:cSuperDel
	Endif
	If Empty(oGetDados:cDelOk)
		oGetDados:cDelOk := cValidacao
	Else
		oGetDados:cDelOk := cValidacao + ".And. " + oGetDados:cDelOk
	Endif
	/*
	define uma funcao para ser executada ao final da edicao da nota de debito para capturar os dados na nd gerada */
	oGetDados:oWnd:bValid := {|| F472NDGer(cTab),.T.}
	oGetDados:oWnd:cCaption := If(nOper == 1,STR0055,STR0056) + " - " + STR0052		//"Concilia็ใo bancแria","Desconcilia็ใo bancแria","gera็ใo de documento fiscal"
	oGetDados:oWnd:cTitle := If(nOper == 1,STR0055,STR0056) + " - " + STR0052			//"Concilia็ใo bancแria","Desconcilia็ใo bancแria","gera็ใo de documento fiscal"
	/*-*/
	oGetDados:lNewLine := .F.
	/*-*/
	MaFisClear()
	MaColsToFis(aHeader,aCols,,"MT100",.T.)
	oGetDados:nMax := 1
	oGetDados:oBrowse:nAt := 1
	oGetDados:oBrowse:Refresh()
Endif
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472   บAutor  ณMicrosiga           บFecha ณ 01/10/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472NDTes(cTes)
Local aAreaSFC	:= SFC->(GetArea())
Local lRet		:= .T.
Local nPosTES	:= 0

Default cTes		:= ""

If Empty(cTes)
	nPosTES := Ascan(aHeader,{|cpo| AllTrim(cpo[2]) == "D1_TES"})
	If nPosTES <> 0
		cTes := aCols[n,nPosTES]
	Endif
Endif

If !Empty(cTes)
	If SF4->(MsSeek(xFilial("SF4") + cTes))
		/* o TES nao deve atualizar estoque ou gerar titulos no financeiro */
		If SF4->F4_ESTOQUE == "S" .Or. SF4->F4_DUPLIC == "S"
			MsgAlert(STR0057)		//"Utilize somente TES que nใo atualizem estoque e nใo gerem tํtulos financeiros."
			lRet := .F.
		Endif
	Endif
Endif
RestArea(aAreaSFC)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472   บAutor  ณMicrosiga           บFecha ณ 01/10/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472NDGer(cTab)
Local aRet	:= {}

If oGetDados:oWnd:nResult == 0
	aRet := {cTab,(cTab)->(Recno())}
	F472DadosMov(Aclone(aRet),"OUTROS")
	F472DadosMov(.T.,"INCMOV")
Else
	F472DadosMov(.F.,"INCMOV")
Endif
Return(.T.)
   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472   บAutor  ณMicrosiga           บFecha ณ 03/10/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472CtrlCh(nOper)
Local cSeqFRF	:= ""
Local cQuery	:= ""
Local cAliasTmp	:= ""
Local cCpoSE5	:= ""
Local lRet		:= .T.
Local aAreaSEF	:= {}
Local aAreaSE5	:= {}
Local aArea		:= {}

Default nOper	:= 1

aArea := GetArea()
/*
Atualiza o controle de cheques */
DbSelectArea("SEF")
aAreaSEF := GetArea()
SEF->(DbSetOrder(6))
If SEF->(MsSeek( xFilial("SEF") + SE5->E5_RECPAG + If(SE5->E5_RECPAG == "R",(SE5->E5_BCOCHQ+SE5->E5_AGECHQ+SE5->E5_CTACHQ+PadR(SE5->E5_NUMERO,TAMSX3("EF_NUM")[1])),(SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA+PadR(IIf(cPaisLoc == "ARG",SE5->E5_NUMERO,SE5->E5_NUMCHEQ),TAMSX3("EF_NUM")[1])))+SE5->E5_PREFIXO ))
	RecLock("SEF",.F.)
	Replace SEF->EF_RECONC	With Iif(nOper == 1,"x"," ")
	SEF->(MSUnlock())
	/*
	atualiza o historico de movimentacoes */
	cSeqFRF := GetSXENum("FRF","FRF_SEQ")
	RecLock("FRF",.T.)
	Replace FRF->FRF_FILIAL		With xFilial("FRF")
	Replace FRF->FRF_BANCO		With SEF->EF_BANCO
	Replace FRF->FRF_AGENCIA	With SEF->EF_AGENCIA
	Replace FRF->FRF_CONTA		With SEF->EF_CONTA
	Replace FRF->FRF_NUM		With SEF->EF_NUM
	Replace FRF->FRF_PREFIX		With SEF->EF_PREFIXO
	Replace FRF->FRF_CART		With SE5->E5_RECPAG
	Replace FRF->FRF_DATPAG		With SEF->EF_DATAPAG
	Replace FRF->FRF_MOTIVO		With If(nOper == 1,"70","71")
	Replace FRF->FRF_DESCRI		With If(nOper == 1,STR0055,STR0056)	//"Concilia็ใo bancแria","Desconcilia็ใo bancแria"
	Replace FRF->FRF_SEQ		With cSeqFRF
	FRF->(MsUnLock())
	ConfirmSX8()
Endif
/*
Atualiza os registros do movimento bancario: para cheques gerados manualmente (FINA100), havera dois registros: um gerado no momento da inclusao do cheque; 
outro pela liquidacao no controle de cheques emitidos.*/
DbSelectArea("SE5")
aAreaSE5 := GetArea()
cQuery := "select R_E_C_N_O_ REGSE5 from " + RetSQLName("SE5")
cQuery += "where E5_FILIAL = '" + xFilial("SE5") + "'"
cQuery += " and R_E_C_N_O_ <> " + AllTrim(Str(SE5->(Recno())))
cQuery += " and E5_BANCO = '" + SE5->E5_BANCO + "'"
cQuery += " and E5_AGENCIA = '" + SE5->E5_AGENCIA + "'"
cQuery += " and E5_CONTA = '" + SE5->E5_CONTA + "'"
cQuery += " and E5_RECPAG = '" + SE5->E5_RECPAG + "'"
If SE5->E5_RECPAG == "R"
	cQuery += " and E5_PREFIXO = '" + SE5->E5_PREFIXO + "'"
Endif
cQuery += " and E5_SITUACA not in ('C','X','E')"
cQuery += " and E5_NUMCHEQ = '" + SE5->E5_NUMERO + "'"
cQuery += " and E5_PARCELA = '" + SE5->E5_PARCELA + "'" 
cQuery += " and E5_TIPO = '" + SE5->E5_TIPO + "'"
cQuery += " and E5_CLIFOR = '" + SE5->E5_CLIFOR + "'"
cQuery += " and E5_LOJA = '" + SE5->E5_LOJA + "'"
cQuery += " and D_E_L_E_T_= ' '"
cQuery := ChangeQuery(cQuery)
cAliasTmp := GetNextAlias()
/*-*/
cCpoSE5 := "{" 
cCpoSE5 += "{'E5_RECONC', '" + If(nOper == 1,"x"," ") + "'}"
cCpoSE5 += "}"
DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasTmp,.F.,.T.)
(cALiasTmp)->(DbGoTop())
While !((cAliasTmp)->(Eof())) .And. lRet
	SE5->(DbGoto((cAliasTmp)->REGSE5))
	/*-*/
	lRet := F472ConFKS((cAliasTmp)->REGSE5,cCpoSE5,nOper)
	(cAliasTmp)->(DbSkip())
Enddo
DbSelectArea(cAliasTmp)
DbCloseArea()
/*-*/
RestArea(aAreaSEF)
RestArea(aAreaSE5)
RestArea(aArea)
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472   บAutor  ณMicrosiga           บFecha ณ 11/10/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472Legenda(oView)
Local aLeg  := {}
Local aRet  := {}

Aadd(aLeg,{F472EstExt(_CEXTINCON,@aRet),aRet[2]})
Aadd(aLeg,{F472EstExt(_CEXTNCONC,@aRet),aRet[2]})
Aadd(aLeg,{F472EstExt(_CEXTCONC,@aRet),aRet[2]})
Aadd(aLeg,{F472EstExt(_CEXTENCER,@aRet),aRet[2]})
/*_*/
BrwLegenda(STR0001,AllTrim(SX3->(RetTitle("FJE_ESTEXT"))),aLeg)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472   บAutor  ณMicrosiga           บFecha ณ 25/10/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472LegCon()
Local aLeg  := {}
Local aEst  := {}

Aadd(aLeg,{ F472AEstMov(_CMOVCONC,@aEst),aEst[2]})
Aadd(aLeg,{ F472AEstMov(_CMOVNCONC,@aEst),aEst[2]})
/*_*/
BrwLegenda(STR0001,AllTrim(SX3->(RetTitle("FJF_ESTMOV"))),aLeg)
Return()




//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F472VldConc
Valida็ใo da existencia de registros para bloqueios de opera็๕es nas rotinas:
- Cancelamento de Ordem de Pago
- Cancelamento de Recibo
- Cancelamento, substitui็ใo e devolu็ใo de Cheques Recebidos/Cheques Emitidos

@author    Marcos Berto
@version   11.7
@since     26/09/2012

@param aSE5		Dados do registro de mov. bancแria que deve ser validada
					[x][1]  = Prefixo
					[x][2]  = Numero
					[x][3]  = Parcela
					[x][4]  = Tipo
					[x][5]  = Cli/For
					[x][6]  = Loja
					[x][7]  = Banco
					[x][8]  = Agencia
					[x][9]  = Conta

@return lConc		Valida se existe uma concilia็ใo bancแria efetuada

/*/
//------------------------------------------------------------------------------------------
Function F472VldConc(aSE5)

Local aAreaSE5	:= {}

Local lConc		:= .F.

Local nX		:= 1

Local aArea		:= {}

DEFAULT aSE5	:= {}

aArea := GetArea()
dbSelectArea("SE5")
aAreaSE5 := SE5->(GetArea())

If cPaisLoc != "CHI"
	SE5->(dbSetOrder(7))

	For nX := 1 to Len(aSE5)
		//FILIAL+PREFIXO+NUMERO+PARCELA+TIPO+CLIFOR+LOJA
		If SE5->(MsSeek(xFilial("SE5") + aSE5[nX][1]+aSE5[nX][2]+aSE5[nX][3]+aSE5[nX][4]+aSE5[nX][5]+aSE5[nX][6]))
			While !SE5->(Eof()) .And. SE5->E5_FILIAL == xFilial("SE5") .And.;
					SE5->E5_PREFIXO == aSE5[nX][1] .And. SE5->E5_NUMERO == aSE5[nX][2] .And.;
					SE5->E5_PARCELA == aSE5[nX][3] .And. SE5->E5_TIPO   == aSE5[nX][4] .And.;
					SE5->E5_CLIFOR  == aSE5[nX][5] .And. SE5->E5_LOJA   == aSE5[nX][6]
		
				//Movimentos do mesmo tํtulo/cheque/documento de outros bancos nใo serใo considerados
				If SE5->E5_RECPAG == "P" .Or. (SE5->E5_RECPAG == "R" .And. !(SE5->E5_TIPO $ MVCHEQUE))
					If SE5->E5_BANCO <> aSE5[nX][7] .And. SE5->E5_AGENCIA <> aSE5[nX][8] .And. SE5->E5_CONTA <> aSE5[nX][9]  
						SE5->(dbSkip())
						Loop
					EndIf
				Else
					If SE5->E5_BCOCHQ <> aSE5[nX][7] .And. SE5->E5_AGECHQ <> aSE5[nX][8] .And. SE5->E5_CTACHQ <> aSE5[nX][9]  
						SE5->(dbSkip())
						Loop
					EndIf	
				EndIf
			
				//Valida se o movimento foi conciliado
				If !Empty(SE5->E5_RECONC) 
					If cPaisLoc=="ARG"
						lConc := .T.	
						Exit
					ELSE
					
						dbSelectArea("FJG") // extractos bancarios FINA472
						FJG->(dbSetOrder(2))
						If FJG->(MsSeek(xFilial("FJG")+"SE5"+StrZero(SE5->(Recno()),TamSx3("FJG_REGCON")[1],0))) 
							lConc := .T.
							Exit
						EndIf

					EndIf

				EndIf
				SE5->(dbSkip())
			EndDo
		EndIf
	Next nX
Else
	SE5->(dbSetOrder(1)) //E5_FILIAL+DTOS(E5_DATA)+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ
	For nX := 1 to Len(aSE5)
		If SE5->(MsSeek(xFilial('SE5')+ DtoS(SEK->EK_EMISSAO)))
			while !SE5->(Eof()) 
				If AllTrim(SE5->E5_NUMERO) == aSE5[nX][2] .and. SE5->E5_CLIFOR  == aSE5[nX][5]
					If !Empty(SE5->E5_RECONC)
						lConc := .T.	
					EndIf
				Endif
				SE5->(dbskip())


			EndDo
		EndIf

	Next
EndIf

RestArea(aAreaSE5)
RestArea(aArea)
Return(lConc)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472   บAutor  ณMicrosiga           บFecha ณ 25/10/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F472ConFKS(nRecnoSE5,cCpoSE5,nOper)
Local oModelFK5	:= Nil
Local oSubFK5			:= Nil
Local oSubFKA			:= Nil
Local lRet					:= .F.
Local aArea				:= {}
Local cLog 				:= ""
Local lVldFK			:= .F.

FK5->(DbSetOrder(1))
//
aArea := GetArea()
SE5->(DbGoto(nRecnoSE5))
lVldFK := IIF(Empty(SE5->E5_IDORIG),.T.,.F.)
oModelFK5	:= FWLoadModel("FINM030")
oSubFK5 		:= oModelFK5:GetModel("FK5DETAIL")
oSubFKA 		:= oModelFK5:GetModel("FKADETAIL")	
//
oModelFK5:SetOperation(MODEL_OPERATION_UPDATE)
oModelFK5:Activate()	
oSubFKA:Seekline({{'FKA_IDORIG', SE5->E5_IDORIG}})
oModelFK5:SetValue(	"MASTER",	"E5_GRV"			, .T. )
oModelFK5:SetValue(	"MASTER",	"E5_CAMPOS"	,cCpoSE5 ) //Informa os campos da SE5 que serkใo gravados independentes de FK5
oSubFK5:SetValue("FK5_DTCONC",If(nOper == 1,dDataBase,Ctod("//")))   	
If oModelFK5:VldData()
	oModelFK5:CommitData()
	lRet := .T.
Else
	lRet := .F.
	If lVldFK
		Help( ,,"FIN472001",,STR0079, 1, 0 ) // "Verifique o vํnculo da tabela SE5 com as tabelas FKs" 
	Else
		cLog := cValToChar(oModelFK5:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
		cLog += cValToChar(oModelFK5:GetErrorMessage()[MODEL_MSGERR_ID ]) 				 + ' - '
		cLog += cValToChar(oModelFK5:GetErrorMessage()[MODEL_MSGERR_MESSAGE])   
	Help( ,,"M030VALID",,cLog, 1, 0 )
	EndIF
EndIf
//
oModelFK5:DeActivate()

RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA472   บAutor  ณMarivaldo           บFecha ณ 12/01/2021  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o ultimo registro da tabela de saldo bancario      บฑฑ
ฑฑบ          ณ SE8                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SE8LastSeq(cBanco,cAgencia,cConta)
local cQuery as char
local cSeq as char
local cAlias as char
local cDataSal := Dtos(dDataBase) 
Default cBanco := ""
Default cAgencia := ""
Default cConta := ""

//Guarda a workarea corrente
cAlias := Alias()

//Gera um alias aleat๓rio somente para abrir a query
cQuery := GetNextAlias()

//Cria a query
BeginSQL alias cQuery
    SELECT MAX(E8_DTSALAT) SEQ_MAX
      FROM %table:SE8%
     WHERE E8_FILIAL = %xfilial:SE8%
       AND E8_BANCO = %exp:cBanco%
	   AND E8_AGENCIA = %exp:cAgencia%
	   AND E8_CONTA = %exp:cConta%
	   AND E8_DTSALAT<= %exp:cDataSal%
       AND %notDel%
EndSQL

//Se existir registro, retorna o mesmo
If !(cQuery)->(Eof())
    cSeq := (cQuery)->SEQ_MAX
Else
    cSeq := ""
Endif

//Fecha a query
(cQuery)->(DBCloseArea())

//Retorna a workarea corrente
If !Empty(cAlias)
    DBSelectArea(cAlias)
Endif

Return cSeq
