#INCLUDE "FINA763.ch"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'FWBrowse.ch'

#DEFINE OPER_ENVIAR		10
#DEFINE OPER_APROVAR		11
#DEFINE OPER_LIBERAR		12
#DEFINE OPER_CONCLUIR		13
#DEFINE OPER_CANCELAR		14
#DEFINE OPER_ESTORNAR		15

Static __cProcPrinc  	:= "FINA763"
Static __cAliasTMP		:= ""
Static __cArqTrab		:= ""
Static __cArqTit		:= ""
Static __cIndTMP		:= ""
Static __cIndTMP2		:= ""
Static __cIndTit		:= ""
Static __nOper			:= 0
Static __lConfirmar		:= .F.
Static __lBTNConfirma	:= .F.
Static _oFINA7631		

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA763
Rotina respons�vel pela manutencao de registros de Programa��o Financeira

@author Mauricio Pequim Junior
@since 28/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Function FINA763()

Local oBrowse	:= Nil
Local oDlg		:= Nil

If cPaisLoc == "BRA"

	__nOper := 0
	
	oBrowse := FWMBrowse():New()
	oBrowse:setAlias("FX0") // Tabela do Cabe�alho do Documento H�bil
	oBrowse:SetDescription(STR0001) //"Cadastro de Programa��o Financeira"
	
	ADD LEGEND DATA {|| FX0_STATUS	== '1'} COLOR "WHITE"	TITLE	STR0002	Of oBrowse //"Aguardando Envio"
	ADD LEGEND DATA {|| FX0_STATUS  == '2'} COLOR "YELLOW"	TITLE	STR0003	Of oBrowse //"Aguardando Aprova��o"
	ADD LEGEND DATA {|| FX0_STATUS  == '3'} COLOR "ORANGE"	TITLE	STR0004	Of oBrowse //"Aguardando Libera��o"
	ADD LEGEND DATA {|| FX0_STATUS  == '4'} COLOR "GREEN"	TITLE	STR0005	Of oBrowse //"Aguardando Conclus�o"
	ADD LEGEND DATA {|| FX0_STATUS  == '5'} COLOR "RED"		TITLE	STR0006	Of oBrowse //"Conclu�do"
	ADD LEGEND DATA {|| FX0_STATUS  == '6'} COLOR "BLUE"	TITLE	STR0007	Of oBrowse //"Cancelado"
	ADD LEGEND DATA {|| FX0_STATUS  == '7'} COLOR "GRAY"	TITLE	STR0008	Of oBrowse //"Estornado"
	ADD LEGEND DATA {|| FX0_STATUS  == '8'} COLOR "PINK"	TITLE	STR0009	Of oBrowse //"Com Erros"
	ADD LEGEND DATA {|| FX0_STATUS  == '9'} COLOR "BLACK"	TITLE	STR0010	Of oBrowse //"Expirado"
	
	oBrowse:SetMenuDef("FINA763")
	oBrowse:Activate()
Else
	MsgStop(OemToAnsi(STR0116)) //"Fun��o dispon�vel apenas para o Brasil."
EndIf

If _oFINA7631 <> Nil
	_oFINA7631:Delete()
	_oFINA7631	:= Nil
Endif	

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao responsavel pelo modelo de dados do cadastro da Programa��o Financeira

@author Mauricio Pequim Jr
@since 14/11/2014
@version 1.0

@return Objeto Retorna o objeto do modelo de dados do cadastro de programa��o financeira

/*/
//-------------------------------------------------------------------

Static Function ModelDef()

Local oModel	:= MPFormModel():New('FINA763',/*bPre*/,{|oModel|F763ValDoc(oModel)}/*bPos*/,{|oModel|F763Grava(oModel)}/*bCommit*/,/*bCancel*/)
Local oStruCab	:= EstCabPF()
Local oStruItens:= EstItPF()
Local oStruDHs	:= EstItDH()
Local bFX2LinPre := { |oModel, nLine, cAction| FX2LinPre( oModel, nLine, cAction ) }

oStruCab:SetProperty( "FX0_UGEMIT", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "F763IniPad()" ) )
oStruCab:SetProperty( "FX0_UGDESC", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "POSICIONE('CPA', 1, xFilial('CPA') + F763IniPad(),'CPA_DESORG')" ) )
oStruItens:SetProperty( "FX1_SITUAC", MODEL_FIELD_VALID, {|oModelSit, cCampo, cSituac, nLinha| VldSitPF( oModelSit, cCampo, cSituac, nLinha ) } )

oModel:SetDescription(STR0011) //"Rotina de Manuten��o da Programa��o Financeira"
oModel:Addfields("CABPF",/*cOwner*/,oStruCab)
oModel:GetModel("CABPF"):SetDescription(STR0012) //"Cabe�alho da Programa��o Financeira"

oModel:AddGrid("ITENSPF","CABPF",oStruItens)
oModel:GetModel("ITENSPF"):SetDescription(STR0013) //"Itens da Programa��o Financeira"

oModel:AddGrid("ITENSDH","CABPF",oStruDHs,bFX2LinPre)
oModel:GetModel("ITENSDH"):SetDescription(STR0014) //"Itens de Documento H�bil vinculado a Programa��o Financeira"

oModel:SetRelation('ITENSPF',{ {'FX1_FILIAL','XFILIAL("FX1")'} ,{'FX1_CODIGO','FX0_CODIGO'} }, FX1->(IndexKey(1)) )
oModel:SetRelation('ITENSDH',{ {'FX2_FILIAL','XFILIAL("FX2")'} ,{'FX2_CODIGO','FX0_CODIGO'} }, FX2->(IndexKey(1)) )

oModel:GetModel( 'ITENSDH' ):SetUniqueLine( { 'FX2_CODDH' } )

oModel:AddCalc( 'CALC', 'CABPF', 'ITENSPF', 'FX1_VALOR', 'NTOTIPF', 'SUM',,,STR0015 ) //'Total Bruto' //"Total Itens Progr. Financeira"
oModel:AddCalc( 'CALC', 'CABPF', 'ITENSDH', 'FX2_VLRDH', 'NTOTIDH', 'SUM',,,STR0016 ) //'Total Presente' //"Total Docto. Habil"

oModel:SetPrimaryKey({})

oModel:SetVldActivate( {|oModel| F763VLMod(oModel) } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao reponsavel pela View  da interface do cadastro da Programa��o Financeira

@author Mauricio Pequim Jr
@since 14/11/2014
@version 1.0

@return Objeto Retorna o objeto da interface do cadastro de Programa��o Financeira

/*/
//-------------------------------------------------------------------

Static Function ViewDef()

Local oView		:= Nil
Local oModel		:= FWLoadModel('FINA763')
Local oStruCab	:= FWFormStruct(2,'FX0',{ |x| !ALLTRIM(x) $ 'FX0_CODIGO,FX0_CODSIA,FX0_STATUS,FX0_DTINCL'})
Local oStruItPF	:= FWFormStruct(2,'FX1',{ |x| !ALLTRIM(x) $ 'FX1_CODIGO'})
Local oStruItDH 	:= FWFormStruct(2,'FX2',{ |x| !ALLTRIM(x) $ 'FX2_CODIGO,FX2_STATUS'})
Local oCalc1 		:= FWCalcStruct( oModel:GetModel('CALC') )

oView := FWFormView():New()

oStruItDH:SetProperty("FX2_CODDH" ,MVC_VIEW_CANCHANGE, .F.)
oStruItDH:SetProperty("FX2_VLRDH" ,MVC_VIEW_CANCHANGE, .F.)

oView:SetModel(oModel)
oView:AddField("VCABPF"	,oStruCab	,"CABPF")
oView:AddGrid("VITENSPF",oStruItPF	,"ITENSPF")
oView:AddGrid("VITENSDH",oStruItDH	,"ITENSDH")
oView:AddField('TOTAL'  ,oCalc1     ,'CALC')

//Other objects (bot�es)	
oView:AddOtherObject('BTVARFX2',{|oPainel,oV|MontaBotao(oPainel,oV,"FX2")},{|oPainel|DesmontaBotao(oPainel)} )

//Other objects (Titulo dos Itens)	
oView:AddOtherObject('TITEM',{|| },{|| }) 

oView:CreateHorizontalBox( 'BOXFX0'   , 43)
oView:CreateHorizontalBox( 'BOXTIT'   , 03)
oView:CreateHorizontalBox( 'BOXDETAIL', 44)
oView:CreateHorizontalBox( 'BOXTOTAL' , 10)

oView:CreateFolder( 'DETAILFOL', 'BOXDETAIL')

oView:AddSheet('DETAILFOL','FX1SHEET',STR0013)	//'Itens da Programa��o Financeira'
oView:AddSheet('DETAILFOL','FX2SHEET',STR0103)	//'Documentos H�beis vinculados a Programa��o Financeira'	

oView:CreateHorizontalBox( 'BOXFX1DETAIL', 100, /*owner*/, /*lPixel*/, 'DETAILFOL', 'FX1SHEET')
oView:CreateHorizontalBox( 'BOXFX2'      , 100, /*owner*/, /*lPixel*/, 'DETAILFOL', 'FX2SHEET')

oView:CreateVerticalBox( 'BOXFX2DETAIL', 90, 'BOXFX2', /*lUsePixel*/, 'DETAILFOL', 'FX2SHEET')
oView:CreateVerticalBox( 'BOXBUTFX2'   , 10, 'BOXFX2', /*lUsePixel*/, 'DETAILFOL', 'FX2SHEET')
oView:CreateVerticalBox( 'BOXFORM15'   , 100, 'BOXTIT')

oView:SetOwnerView('VCABPF'	 ,'BOXFX0')
oView:SetOwnerView('TITEM'   ,'BOXFORM15')
oView:SetOwnerView('VITENSPF','BOXFX1DETAIL')
oView:SetOwnerView('VITENSDH','BOXFX2DETAIL')
oView:SetOwnerView('BTVARFX2','BOXBUTFX2')
oView:SetOwnerView('TOTAL'   ,'BOXTOTAL')

oView:EnableTitleView('VCABPF', STR0017 )	//'Programa��o Financeira'
oView:EnableTitleView('TOTAL' , STR0104 )	//'Totais'
oView:EnableTitleView('TITEM' , STR0018 )	//'Itens Programa��o Financeira'

//Define campos que terao Auto Incremento
oView:AddIncrementField( 'VITENSPF'   , 'FX1_ITEM')

//Inclus�o ou altera��o de Programa��o Financeira
If __nOper == 0 
	oStruCab:RemoveField( 'FX0_DTLIB' )
	oStruCab:RemoveField( 'FX0_DTAPRV' )
Endif

If __nOper > 0 
	//Aprova��o ou Libera��o da Programa��o Financeira
	If (__nOper == OPER_APROVAR .or. __nOper == OPER_LIBERAR)
		oStruCab:SetProperty( '*' , MVC_VIEW_CANCHANGE ,  .F. )
		oStruItPF:SetProperty('*' , MVC_VIEW_CANCHANGE ,  .F. )
		oStruItDH:SetProperty('*' , MVC_VIEW_CANCHANGE ,  .F. )	
	
		If __nOper == OPER_APROVAR
			oStruCab:SetProperty( 'FX0_DTAPRV' , MVC_VIEW_CANCHANGE ,  .T. )
			oStruCab:RemoveField( 'FX0_DTLIB' )
		Endif
	
		If __nOper == OPER_LIBERAR
			oStruCab:SetProperty( 'FX0_DTLIB' ,  MVC_VIEW_CANCHANGE ,  .T. )
			oStruCab:RemoveField( 'FX0_DTAPRV' )
		Endif
	Endif
Endif

If __lBTNConfirma 
	oView:AddUserButton( STR0019, 'OK', {|oView| F763CancVs(oView) } )	//"Cancelar"
EndIf

Return oView                                                                                                           

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Defini��o do menu da tela de cadastro do Documento H�bil

@author Pedro Alencar	
@since 08/01/2015	
@version 12.1.3
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

//Menu de Op��es da Browse da Programa��o Financeira
ADD OPTION aRotina TITLE STR0105	ACTION 'VIEWDEF.FINA763'	OPERATION MODEL_OPERATION_VIEW   ACCESS 0	//Visualizar 
ADD OPTION aRotina TITLE STR0106	ACTION 'VIEWDEF.FINA763'	OPERATION MODEL_OPERATION_INSERT ACCESS 0	//Incluir 
ADD OPTION aRotina TITLE STR0107	ACTION 'VIEWDEF.FINA763'	OPERATION MODEL_OPERATION_UPDATE ACCESS 0	//'Alterar' 
ADD OPTION aRotina TITLE STR0108	ACTION 'VIEWDEF.FINA763'	OPERATION MODEL_OPERATION_DELETE ACCESS 0	//'Excluir'
ADD OPTION aRotina TITLE STR0109	ACTION 'VIEWDEF.FINA763'	OPERATION 8 ACCESS 0						//'Imprimir'
ADD OPTION aRotina TITLE STR0020	ACTION 'SIAFCadPF()'		OPERATION MODEL_OPERATION_UPDATE ACCESS 0	//"Enviar"
ADD OPTION aRotina TITLE STR0021	ACTION 'F763Aprovar()'		OPERATION MODEL_OPERATION_UPDATE ACCESS 0	//"Aprovar"
ADD OPTION aRotina TITLE STR0022	ACTION 'F763Liberar()'		OPERATION MODEL_OPERATION_UPDATE ACCESS 0	//"Liberar"
ADD OPTION aRotina TITLE STR0023	ACTION 'F763Concluir()'		OPERATION MODEL_OPERATION_UPDATE ACCESS 0	//"Concluir"
ADD OPTION aRotina TITLE STR0019	ACTION 'F763Cancelar()'		OPERATION MODEL_OPERATION_UPDATE ACCESS 0	//"Cancelar"
ADD OPTION aRotina TITLE STR0024	ACTION 'F763Estornar()'		OPERATION MODEL_OPERATION_UPDATE ACCESS 0	//"Estornar"
ADD OPTION aRotina TITLE STR0025	ACTION 'F763EncExp()'		OPERATION 4 ACCESS 0 						//"Encerrar expiradas"
ADD OPTION aRotina TITLE STR0026	ACTION 'F763LOG()'			OPERATION MODEL_OPERATION_UPDATE ACCESS 0	//"Transa��es"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} EstCabPF

Estrutura de dados para armazenar no modelo dos campos do cabe�alho da
Programa��o Financeira

@author Mauricio Pequiim Jr
@since 14/11/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function EstCabPF()

Local oStrCabPF	:= Nil

oStrCabPF := FWFormStruct(1,'FX0')

oStrCabPF:AddTrigger('FX0_UGEMIT','FX0_UGDESC',{ || .T.}/*bPre*/,{ |oModel| Posicione('CPA',1,xFilial('CPA') + oModel:GetModel("CABPF"):GetValue("CABPF","FX0_UGEMIT"),'CPA_DESORG')})
oStrCabPF:AddTrigger('FX0_UGFAVO','FX0_UGDSFV',{ || .T.}/*bPre*/,{ |oModel| Posicione('CPA',1,xFilial('CPA') + oModel:GetModel("CABPF"):GetValue("CABPF","FX0_UGFAVO"),'CPA_DESORG')})

//Torna o campo Data de Aprova��o Obrigat�rio
If __nOper == OPER_APROVAR
	oStrCabPF:SetProperty( "FX0_DTAPRV", MODEL_FIELD_OBRIGAT, .T.)
	oStrCabPF:SetProperty( "FX0_DTAPRV", MODEL_FIELD_VALID, {|| F763VldDt("FX0_DTAPRV")})
Endif

//Torna o campo Data de Libera��o Obrigat�rio
If __nOper == OPER_LIBERAR
	oStrCabPF:SetProperty( "FX0_DTLIB", MODEL_FIELD_OBRIGAT, .T.)
	oStrCabPF:SetProperty( "FX0_DTLIB", MODEL_FIELD_VALID, {|| F763VldDt("FX0_DTLIB")})
Endif

Return oStrCabPF

//-------------------------------------------------------------------
/*/{Protheus.doc} EstItPF

Estrutura de dados para armazenar no modelo dos campos dos itens
do cadastro da Programa��o Financeira

@author Mauricio Pequiim Jr
@since 14/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function EstItPF()

Local oStrItPF	:= Nil

oStrItPF := FWFormStruct(1,'FX1')

oStrItPF:AddTrigger('FX1_SITUAC','FX1_NSITUA',{ || .T.}/*bPre*/,{ |oModel| POSICIONE('FVJ', 1, FWxFilial('FVJ') + oModel:GetModel("ITENSPF"):GetValue("ITENSPF","FX1_SITUAC"), 'FVJ_DESCRI')})
oStrItPF:AddTrigger('FX1_FONREC','FX1_NFONRE',{ || .T.}/*bPre*/,{ |oModel| F761GatFRec( oModel:GetValue('FX1_FONREC') ) })
oStrItPF:AddTrigger('FX1_CATGAS','FX1_NCATGA',{ || .T.}/*bPre*/,{ |oModel| POSICIONE('SX5', 1, FWxFilial('SX5') +'NX'+ oModel:GetValue('FX1_CATGAS') , 'X5_DESCRI')})

oStrItPF:SetProperty('FX1_NCATGA', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI,POSICIONE('SX5', 1, xFilial('SX5') + 'NX' + FX1->FX1_CATGAS, 'X5_DESCRI'),'')" ))
oStrItPF:SetProperty('FX1_NFONRE', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI,F761GatFRec( FX1->FX1_FONREC),'') " ))

oStrItPF:SetProperty("FX1_DTPREV",MODEL_FIELD_VALID, {|oModel| F763ValCpo(oModel,"FX1_DTPREV",.T.,.T.)})

Return oStrItPF

//-------------------------------------------------------------------
/*/{Protheus.doc} EstItDH

Estrutura de dados para armazenar no modelo dos campos dos itens
dos documentos hab�is vinculados ao cadastro da Programa��o Financeira

@author Mauricio Pequiim Jr
@since 11/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function EstItDH()

Local oStrItDH	:= Nil

oStrItDH := FWFormStruct(1,'FX2')

oStrItDH:AddField( ;
"FX2_RECNO"					, ;	// [01] Titulo do campo
"FX2_RECNO"					, ;	// [02] ToolTip do campo
'FX2_RECNO'     			, ;	// [03] Id do Field
'N'             			, ;	// [04] Tipo do campo
10               			, ;	// [05] Tamanho do campo
0                			, ;	// [06] Decimal do campo
/**/						, ;
/*bWhen*/					, ;
/*aValues*/					, ;
.F.							, ;
/*bInit*/					, ;
.F.)

oStrItDH:AddTrigger('FX2_CODDH','FX2_VLRDH',{ || .T.}/*bPre*/,{ |oModel| Posicione('FV0',1,xFilial('FV0') + oModel:GetModel("ITENSDH"):GetValue("ITENSDH","FX2_CODDH"),'FV0_VLRDOC')})

oStrItDH:SetProperty("FX2_CODDH" , MODEL_FIELD_WHEN , {|| .F. } )

Return oStrItDH

//-------------------------------------------------------------------
/*/{Protheus.doc} F763VLMod

Valida��o para opera��es com o Model

@author Mauricio Pequiim Jr
@since 11/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function F763VLMod(oModel)

Local nOperation := oModel:GetOperation()
Local lRet := .T.

If lRet .And. (nOperation == MODEL_OPERATION_UPDATE ) .And. !(FX0->FX0_STATUS $ "1|8") .AND. __nOper == 0
	Help(" ",1,"F763ALT",,STR0027+CRLF+STR0028,1,0) //"N�o s�o permitidas altera��es nesta programa��o financeira."###"Apenas programa��es financeiras com status [Aguardando Envio] ou [Com Erros] podem ser alteradas."
	lRet := .F.
EndIf

If lRet .And. (nOperation == MODEL_OPERATION_DELETE ) .And. !(FX0->FX0_STATUS $ "1|8") .AND. __nOper == 0
	Help(" ",1,"F763DEL",,STR0029+CRLF+STR0030,1,0) //"N�o � permitida a exclus�o desta programa��o financeira."###"Apenas programa��es financeiras com status [Aguardando Envio] ou [Com Erros] podem ser excluidas."
	lRet := .F.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} F763LOG

Fun��o de consulta do log de processamento da programa��o financeira.

@author Mauricio Pequiim Jr
@since 11/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function F763LOG()

ProcLogView( cFilAnt, "PF" + FX0->FX0_CODIGO, "PF" + FX0->FX0_CODIGO )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FPFWMarkB
Tela de sele��o de documentos relacionado ao DH
@author Mauricio Pequim Jr
@since 29/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function FPFWMarkB()

Local oModel	:= FWModelActive()
Local oSubFX0	:= oModel:GetModel("CABPF")
Local oSubFX2	:= oModel:GetModel("ITENSDH")
Local oDlg 		:= Nil
Local cQuery	:= ""
Local nX		:= 0
Local nZ		:= 0
Local aColumns	:= {}
Local aSizeMrk	:= {}
Local aStruct	:= FV0->(dbStruct())
Local aStrMrk	:= {}
Local aCampos	:= {'FV0_CODIGO','FV0_UGEMIT','FV0_TIPODC','FV0_VLRDOC','FV0_FORNEC','FV0_LOJA','FV0_DTEMIS','FV0_DTVENC','FV0_STATUS'}
Local nRet 		:= 0
Local bOk 		:= {||((nRet := 1, oMrkBrowse:Deactivate(), oDlg:End()))}
Local aArea 	:= GetArea()
Local cCodigoDH := "" 
Local aReturn 	:= {}
Local nPos 		:= 0
Local cCampos := ""
Local cChave := ""
Local aMarkAnt := {} 
Local bAfterMark := {|| GuardaMark( @aMarkAnt ) }
Local aAreaTMP := {}
Local oMrkBrowse 
Local oView	:= FWViewActive()

Aadd(aStrMrk, {"RECNO","N",10,0})

For nX := 1 To Len(aCampos)
	cCampos += "," + aCampos[nX] + CRLF
	
	If ( nPos := aScan( aStruct, { |x| AllTrim( x[1] ) ==  AllTrim( aCampos[nX] ) } ) ) > 0
		Do Case
			Case aStruct[nPos][2] == "C"
				aAdd(aStrMrk, {aCampos[nX], "C", TamSx3(aCampos[nX])[1],0})				
			Case aStruct[nPos][2] == "D"
				aAdd(aStrMrk, {aCampos[nX], "D", TamSx3(aCampos[nX])[1],0})	
			Case aStruct[nPos][2] == "N"
				aAdd(aStrMrk, {aCampos[nX], "N", TamSx3(aCampos[nX])[1],TamSx3(aCampos[nX])[2]})
		EndCase
	EndIf
Next nX	

//Cria o arquivo tempor�rio, caso o mesmo j� n�o tenha sido criado // para carregar os documentos h�beis
If __cArqTrab == ""
	cQuery := "SELECT FV0.R_E_C_N_O_," + CRLF
	cQuery += SUBSTR(cCampos,2) + CRLF
	cQuery += " ,'  ' FV0_OK " + CRLF
	cQuery += "FROM " + RetSqlName('FV0') + " FV0 " + CRLF
	cQuery += " WHERE " + CRLF 
	cQuery += "FV0_FILIAL = " + "'" + FWxFilial("FV0") + "' AND " + CRLF
	cQuery += "FV0_STATUS = '2' AND " + CRLF
	cQuery += "D_E_L_E_T_ = ' ' AND NOT EXISTS ("
	cQuery += "SELECT FX2_CODDH "
	cQuery += "FROM "+RetSqlName("FX2")+" FX2 "
	cQuery += "WHERE "
	cQuery += "FX2_FILIAL = " + "'" + FWxFilial("FV0") + "' AND " + CRLF
	cQuery += "FX2_CODDH = FV0_CODIGO AND " 
	cQuery += "FX2_CODIGO <> '" + oSubFX0:GetValue("FX0_CODIGO") + "' AND "
	cQuery += "FX2.D_E_L_E_T_ = ' ' ) " + CRLF

	cQuery := ChangeQuery( cQuery )
	__cAliasTMP := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), __cAliasTMP, .T., .T. )	
	
	Aadd(aStrMrk, {"FV0_OK","C",1,0})
	
	__cArqTrab := GetNextAlias()
	
	//Cria o Objeto do FwTemporaryTable
	_oFINA7631 := FwTemporaryTable():New(__cArqTrab)
	
	//Cria a estrutura do alias temporario
	_oFINA7631:SetFields(aStrMrk)
	
	//Adiciona o indicie na tabela temporaria
	_oFINA7631:AddIndex("1",{"FV0_CODIGO"})
	_oFINA7631:AddIndex("2",{"RECNO"})
		
	//Criando a Tabela Temporaria
	_oFINA7631:Create()
	
	//Preenche Tabela TMP com as informa��es filtradas
	While !(__cAliasTMP)->(Eof())
		RecLock( __cArqTrab, .T. )
		
		For nX := 1 To Len(aStrMrk)
		
			If ( nPos := aScan( aStruct, { |x| AllTrim( x[1] ) ==  AllTrim( aStrMrk[nX][1] ) } ) ) > 0
				Do Case
					Case aStruct[nPos][2] == "C"
						(__cArqTrab)->&(aStrMrk[nX][1]) := (__cAliasTMP)->&(aStrMrk[nX][1])
					Case aStruct[nPos][2] == "D"
						(__cArqTrab)->&(aStrMrk[nX][1]) := STOD((__cAliasTMP)->&(aStrMrk[nX][1]))
					Case aStruct[nPos][2] == "N"
						(__cArqTrab)->&(aStrMrk[nX][1]) := (__cAliasTMP)->&(aStrMrk[nX][1])
				EndCase
			EndIf
		
		Next nX
		
		(__cArqTrab) ->RECNO := (__cAliasTMP)->R_E_C_N_O_
	
		//Caso j� tenha algum documento na grid, j� marca no arq temporario
		cCodigoDH := (__cArqTrab)->FV0_CODIGO
		If oSubFX2:SeekLine( { {"FX2_CODDH", cCodigoDH} } )
			(__cArqTrab)->FV0_OK := "X"
		Endif
		(__cArqTrab)->( MsUnlock() )

		(__cAliasTMP)->( dbSkip() )
	EndDo
	
Endif
	
//----------------MarkBrowse----------------------------------------------------
For nX := 1 To Len(aStrMrk)
	If !aStrMrk[nX][1] $ "FV0_OK|RECNO"//R_E_C_N_O_
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+aStrMrk[nX][1]+"}") )
		aColumns[Len(aColumns)]:SetTitle(RetTitle(aStrMrk[nX][1])) 
		aColumns[Len(aColumns)]:SetSize(aStrMrk[nX][3]) 
		aColumns[Len(aColumns)]:SetDecimal(aStrMrk[nX][4])
		aColumns[Len(aColumns)]:SetPicture(PesqPict("FV0",aStrMrk[nX][1])) 
	EndIf	
Next nX 

aSize( aMarkAnt, 0 ) 
aSizeMrk := MsAdvSize()

DEFINE MSDIALOG oDlg TITLE OemTOAnsi(STR0031) From aSizeMrk[7],0 to aSizeMrk[6],aSizeMrk[5] OF oMainWnd PIXEL //"Sele��o de Doctos Habeis"
	oDlg:lMaximized := .T.
	
	oMrkBrowse := FWMarkBrowse():New()
	oMrkBrowse:SetFieldMark( "FV0_OK" )
	oMrkBrowse:SetOwner( oDlg )
	oMrkBrowse:SetAlias( __cArqTrab )
	oMrkBrowse:AddButton( OemTOAnsi(STR0032), bOk,, 2 ) //"Confirmar"
	oMrkBrowse:bAllMark := {|| SIAFMark( oMrkBrowse, @aMarkAnt ) }
	oMrkBrowse:SetMark( 'X', __cArqTrab, "FV0_OK" )
	oMrkBrowse:SetAfterMark( bAfterMark ) 
	oMrkBrowse:SetDescription( OemTOAnsi(STR0031) ) //"Sele��o de Doctos Habeis"
	oMrkBrowse:SetColumns( aColumns )
	oMrkBrowse:SetMenuDef("")
	oMrkBrowse:Activate()
ACTIVATE MSDIALOg oDlg CENTERED

//Se a markbrowse for confirmada
If nRet == 1	//to do
	//Retorna os itens selecionados.
	(__cArqTrab)->(dbGoTop())
	While !(__cArqTrab)->(Eof())
	
		cCodigoDH := (__cArqTrab)->FV0_CODIGO
	
		If (__cArqTrab)->FV0_OK == oMrkBrowse:Mark()			
			//Verifica se o t�tulo j� est� na FV1 
			If !oSubFX2:SeekLine( { {"FX2_CODDH", cCodigoDH} } )
				//Adiciona documentos selecionados a FV1.
				If !oSubFX2:IsEmpty()
					oSubFX2:AddLine()
				Endif

				oSubFX2:LoadValue('FX2_RECNO' , (__cArqTrab)->RECNO)
				oSubFX2:LoadValue('FX2_CODDH' , (__cArqTrab)->FV0_CODIGO)
				oSubFX2:SetValue('FX2_VLRDH'  , (__cArqTrab)->FV0_VLRDOC)
				oSubFX2:LoadValue('FX2_STATUS', (__cArqTrab)->FV0_STATUS)
			Endif
		Else
			//Se o DH n�o estiver selecionado e estiver na FX2, deleta o mesmo da FX2
			If oSubFX2:SeekLine( { {"FX2_CODDH", cCodigoDH} } )
				If !oSubFX2:IsDeleted()
					oSubFX2:DeleteLine()
				Endif
			Endif	
		EndIf
		(__cArqTrab)->(DbSkip())
	EndDo
	
	oSubFX2:SetLine(1)
Else //Se a markbrowse for fechada ao inv�s de confirmada
	//Desfaz as altera��es de marca��es, pois a marca��o n�o foi confirmada
	aAreaTMP := ( __cArqTrab )->( GetArea() )
	For nX := 1 To Len( aMarkAnt )
		If __cArqTrab != ""												
			//Procura o t�tulo no arquivo tempor�rio				 
			( __cArqTrab )->( dbSetOrder( 2 ) ) //R_E_C_N_O_
			If ( __cArqTrab )->( msSeek( aMarkAnt[nX][1] ) )
				RecLock( __cArqTrab, .F. )			
				(__cArqTrab)->FV0_OK := aMarkAnt[nX][2]		
				( __cArqTrab )->(msUnlock() )
			Endif						
		Endif			
	Next nX
	
	( __cArqTrab )->( RestArea( aAreaTMP) )
	aSize( aMarkAnt, 0 ) 
	aMarkAnt := Nil
Endif

oView:Refresh()
RestArea(aArea)

Return aReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} SIAFMark
Fun��o para marcar todos os itens da markbrowse.

@author Mauricio Pequim Junior
@since 26/11/2014
@version 1.0

REAVALIAR

/*/
//-------------------------------------------------------------------
Static Function SIAFMark(oMrkBrowse,aMarkAnt)

Local nRecno := 0
Local lRet	 := .T.

(__cArqTrab)->(dbGoTop())

While !(__cArqTrab)->(Eof())
	nRecno := (__cArqTrab)->RECNO	//R_E_C_N_O_
	FV0->(dbGoto(nRecno))
	If FV0->(MsRLock())
		RecLock(__cArqTrab, .F.)
		If (__cArqTrab)->FV0_OK == oMrkBrowse:Mark()		
			(__cArqTrab)->FV0_OK := ' '		
			//Guarda o estado da marca��o para desfazer caso a tela n�o seja confirmada		
			If aScan( aMarkAnt, { |aVet| aVet[1] == nRecno } ) <= 0			
				aAdd( aMarkAnt, { nRecno, "X" } )		
			Endif		
		Else
			(__cArqTrab)->FV0_OK := oMrkBrowse:Mark()
			//Guarda o estado da marca��o para desfazer caso a tela n�o seja confirmada		
			If aScan( aMarkAnt, { |aVet| aVet[1] == nRecno } ) <= 0			
				aAdd( aMarkAnt, { nRecno, " " } )		
			Endif
		EndIf
		(__cArqTrab)->(MsUnlock())
		(__cArqTrab)->(DbSkip())	
		lRet := .T.
	Else
		IW_MsgBox(STR0033,STR0034,"STOP")  //"Este titulo est� sendo utilizado em outro terminal, n�o pode ser utilizado na fatura"###"Aten��o" //"Este Documento H�bil est� sendo utilizado em outro terminal, n�o pode ser utilizado nesta Programa��o Financeira"###"Aten��o"
		lRet := .F.
	Endif	
EndDo

oMrkBrowse:oBrowse:Refresh(.T.)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GuardaMark()
Fun��o para guardar as marca��es, antes de serem alteradas,
com o proposito de recuper�-las caso a tela n�o seja confirmada
@param aMarkAnt, Vetor que guardar� o recno e a marca��o inicial

@author Mauricio Pequim Junior
@since  07/01/2015
@version 12.1.3
/*/
//-------------------------------------------------------------------
Static Function GuardaMark( aMarkAnt )

Local lRet := .T.
Local nRecno := 0
Local lMarcado := .F.  

If __cArqTrab != "" 

	nRecno := (__cArqTrab)->RECNO	//R_E_C_N_O_
	
	If aScan( aMarkAnt, { |aVet| aVet[1] == nRecno } ) <= 0
		//Se est� marcado, ent�o guarda o estado anterior que era desmarcado e vice-versa 
		lMarcado := Iif( (__cArqTrab)->FV0_OK == "X", .T., .F. )
		aAdd( aMarkAnt, { nRecno, Iif( lMarcado, " ", "X" ) } )		
	Endif
	
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FX2LinPre()
Pr� valida��o de linha da FX2 (grid de Documentos H�beis Relacionados)

@author Mauricio Pequim Junior
@since  06/01/2015
@version 12.1.3
/*/
//-------------------------------------------------------------------
Static Function FX2LinPre(oModel, nLinha, cAction)

Local lRet 		:= .T.
Local cCodigoDH := ""
Local cItem		:= ""	
Local aSaveLines := FWSaveRows()

If cAction == "DELETE" .OR. cAction == "UNDELETE"
	cCodigoDH := PadR( oModel:GetValue('FX2_CODDH', nLinha), TamSX3('FX2_CODDH')[1] )

	//Se desfizer a dele��o do registro, verifica se a linha ficaria duplicada e, caso fique, n�o permite desfazer a dele��o (para n�o dar problema com a sele��o de registros na markbrowse)
	If cAction == "UNDELETE"
		If oModel:SeekLine( { {"FX2_CODDH", cCodigoDH} }, .F. )
			cItem := oModel:GetValue('FX2_ITEM')
			Help( "", 1, "FX2LinPre", , STR0035 + cItem, 3, 1 ) //"Documento j� selecionado na linha " //"Documento H�bil j� selecionado na linha "
			lRet := .F.
		Endif
	Endif

	If lRet 
		//Se o arquivo tempor�rio j� estiver criado, desmarca o t�tulo deletado manualmente atrav�s da grid e remarca ao desfazer a dele��o de linha  
		If __cArqTrab != ""												
			//Procura o t�tulo no arquivo tempor�rio	
			( __cArqTrab )->( dbSetOrder( 1 ) ) //FV0_CODIGO
			If ( __cArqTrab )->( msSeek( cCodigoDH ) )
				RecLock( __cArqTrab, .F. )			
				If cAction == "DELETE"
					//Se o registro foi apagado, remove a sele��o do campo no arquivo tempor�rio
					(__cArqTrab)->FV0_OK := " "
				Else
					//Se a dele��o da linha foi desfeita, adiciona novamente a sele��o do campo no arquivo tempor�rio
					(__cArqTrab)->FV0_OK := "X"
				Endif
				( __cArqTrab )->( msUnlock() )
			Endif			
		Endif			
	Endif
Endif

FWRestRows(aSaveLines)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} MontaBotao

Montagem do bot�o de campos vari�veis 

@author Mauricio Pequim Junior
@since 06/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static function MontaBotao(oPainel,oView,cTabModel)

Local nLin	:= 0 

nLin += 15
@  nLin, 4  BUTTON oButPrev PROMPT STR0036 SIZE 50,012 FONT oPainel:oFont ACTION FPFWMarkB(/*aCampos*/,'FV0') OF oPainel PIXEL WHEN (__nOper == 0)     // "Doctos Habeis" //"Doctos Habeis"

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DesmontaBotao

Desmontagem do bot�o de campos vari�veis

@author Pequim
@since 06/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DesmontaBotao(oPainel)

oPainel:FreeChildren()

Return

//-------------------------------------------------------------------
/*/
{Protheus.doc} FaFX0GETCOD
obt�m o c�digo para chave �nica da tabela Fv0 

@author Mauricio Pequim Jr.

@since 23/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function FaFX0GETCOD()

Local cCodFX0	:="" 
Local cQuery	:= ""	
Local aArea		:= GetArea()
Local cTab		:= ""
Local cTabela	:= RetSQLTab("FX0")
Local cFilTab	:= xFilial("FX0")

While .T.

	cTab	:= GetNextAlias()
	cCodFX0 := GetSx8Num("FX0","FX0_CODIGO","FX0_CODIGO"+cEmpAnt)
	ConfirmSx8()
	
	cQuery   := " SELECT "
	cQuery   += " FX0_CODIGO "
	cQuery   += " FROM " + cTabela 
	cQuery   += " WHERE "
	cQuery   += " FX0_FILIAL = '" + cFilTab + "' AND "
	cQuery   += " FX0_CODIGO = '" + cCodFX0 + "' AND "
	cQuery   += " D_E_L_E_T_ = ' ' "

	If Select(cTab) > 0
		(cTab)->(dbCloseArea())
	EndIf
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTab, .T., .T.)
	
	If (cTab)->(!EOF())
		(cTab)->(dbCloseArea())
		Loop
	Else
		Exit
	EndIf

EndDo

(cTab)->(dbCloseArea())

RestArea(aArea)

Return cCodFX0

//-----------------------------------------------------------------------
/*/{Protheus.doc} F763IniPad
Inicializador Padr�o do campo de Unidade Gestora Emitente da 
Programa��o Financeira

@author Mauricio Pequim Jr
@since 14/01/2015
@version 1.0
/*/
//-----------------------------------------------------------------------
Function F763IniPad()

Local cRet		:= ""
Local cCPAQry	:= ""
Local cCPAAls	:= GetNextAlias()

cCPAQry := "SELECT "
cCPAQry += " CPA.CPA_CODORG "
cCPAQry += " FROM " + RetSqlName("CPA") + " CPA "
cCPAQry += " WHERE " + RetSqlCond("CPA") + " "
cCPAQry += " AND CPA.CPA_SISFIL = '" + cFilAnt  + "' "
cCPAQry := ChangeQuery(cCPAQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cCPAQry),cCPAAls,.T.,.T.)

cRet := (cCPAAls)->CPA_CODORG

Return cRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} F763ValDoc
Valida��o TudoOk do Model de Programa��o Financeira

@author Mauricio Pequim Jr
@since 14/01/2015
@version 1.0
/*/
//-----------------------------------------------------------------------
Function F763ValDoc()

Local lRet		:= .T.
Local oModel	:= FWModelActive()
Local oAuxFX0	:= oModel:GetModel('CABPF')
Local oAuxFX1	:= oModel:GetModel('ITENSPF') 
Local oAuxFX2	:= oModel:GetModel('ITENSDH')
Local oAuxCalc	:= oModel:GetModel('CALC')
Local nX := 0
Local nOperation:= oModel:GetOperation()
Local cDescricao := ""

//Valida se todos os campos variaveis est�o preenchidos
If nOperation == MODEL_OPERATION_INSERT .or. nOperation == MODEL_OPERATION_UPDATE

	If oAuxCalc:GetValue("NTOTIPF") == 0
		Help( " ", 1, "VALPF01", , STR0037,1, 1 ) //"N�o foram informados valores na aba Itens da Programa��o Financeira."
		lRet := .F.
	Endif	

	If lRet .and. oAuxCalc:GetValue("NTOTIPF") == 0
		Help( " ", 1, "VALPF02", , STR0038+CRLF+; //"N�o foram relacionados documentos h�beis a esta programa��o financeira."
									STR0039,1, 1 ) //"Por favor, verifique o conte�do da aba <Documentos H�beis vinculados a Programa��o Financeira."
		lRet := .F.
	Endif	

	If lRet .and. oAuxCalc:GetValue("NTOTIPF") != oAuxCalc:GetValue("NTOTIDH")
		Help( " ", 1, "VALPF03", , STR0040,1, 1 ) //"Aba: Dados B�sicos"###"Item: Documentos de Origem" //"Os valores indicados na aba Itens da Programa��o Financeira n�o conferem com o total de Documentos H�beis relacionados a esta programa��o financeira."
		lRet := .F.
	Endif	

EndIf

If lRet .and. nOperation == MODEL_OPERATION_DELETE
	If oAuxFX0:GetValue("FX0_STATUS") != '1'
		Help( " ", 1, "NO_DEL_PF", ,STR0041 , 3, 1 ) //"N�o � possivel excluir esta programa��o financeira devido a seu status."
		lRet := .F.
	EndIf
EndIf

oModel	 := Nil

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F763Grava
Grava��o geral do Model

@author Mauricio Pequim Jr.
@since   03/02/2015

/*/
//-------------------------------------------------------------------
Function F763Grava(oModel)

Local nOperation := oModel:GetOperation() 
Local cStatus := "0"	
Local lRet := .T.
Local cLog := ""
Local cIdCV8 := ""
Local oAuxFX0 := oModel:GetModel("CABPF")
Local cStatAt := oAuxFX0:GetValue("FX0_STATUS")
		
BEGIN TRANSACTION

	//Grava��o dos Dados do Model de Programa��o Financeira
	lRet := FWFormCommit( oModel )

	If lRet 

		If nOperation == MODEL_OPERATION_INSERT .and. __nOper == 0
			//Registro no log a grava��o do registro do documento h�bil
			ProcLogIni( {}, "PF" + FX0->FX0_CODIGO, "PF" + FX0->FX0_CODIGO, @cIdCV8 )
			If __nOper == 0
				ProcLogAtu( "MENSAGEM", STR0042, STR0043, , .T. ) //"Inclus�o de Programa��o Finannceira"###"Inclus�o de Programa��o Finannceira com sucesso."
			Endif 
		Endif

		If nOperation == MODEL_OPERATION_UPDATE .and. __nOper == 0
			//Registro no log a grava��o do registro do documento h�bil
			ProcLogIni( {}, "PF" + FX0->FX0_CODIGO, "PF" + FX0->FX0_CODIGO, @cIdCV8 )
			If __nOper == 0
				ProcLogAtu( "MENSAGEM", STR0042, STR0043, , .T. ) //"Altera��o de Programa��o Finannceira"###"Altera��o de Programa��o Finannceira com sucesso."
			Endif 
			
			//Caso seja uma altera��o de uma PF com erros, volto o status para 1 (Aguardando Envio)
			If cStatAt == '8'
				RecLock("FX0")
				FX0->FX0_STATUS := '1'
				MsUnlock()
			Endif			
			
		Endif

		//Opera��o de Aprovar, Liberar ou Concluir
		If nOperation == MODEL_OPERATION_UPDATE .and. __nOper > 0 
			If __nOper == OPER_ENVIAR 
				cStatus := "2"
			ElseIf __nOper == OPER_APROVAR 
				cStatus := "3"
				ProcLogAtu( "MENSAGEM", STR0044, STR0045, , .T. ) //"Aprova��o de Programa��o Finannceira"###"Aprova��o de Programa��o Finannceira com sucesso."
			ElseIF __nOper == OPER_LIBERAR
				cStatus := "4"
				ProcLogAtu( "MENSAGEM", STR0046, STR0047, , .T. ) //"Libera��o de Programa��o Finannceira"###"Libera��o de Programa��o Finannceira com sucesso."
			ElseIF __nOper == OPER_CONCLUIR
				cStatus := "5"
				ProcLogAtu( "MENSAGEM", STR0048, STR0049, , .T. ) //"Conclus�o de Programa��o Finannceira"###"Conclus�o de Programa��o Finannceira com sucesso."
			ElseIF __nOper == OPER_CANCELAR
				cStatus := "6"
				ProcLogAtu( "MENSAGEM", STR0050, STR0051, , .T. ) //"Cancelamento de Programa��o Finannceira"###"Cancelamento de Programa��o Finannceira com sucesso."
			ElseIF __nOper == OPER_ESTORNAR
				cStatus := "7"
				ProcLogAtu( "MENSAGEM", STR0066, STR0067, , .T. ) //"Estorno de Programa��o Finannceira"###"Estorno de Programa��o Finannceira com sucesso."
			Endif
		
			If cStatus != '0'
				RecLock("FX0")
				FX0->FX0_STATUS := cStatus
				MsUnlock()
			Endif
		Endif
	Else
		lRet := .F.
		DisarmTransaction()

	    cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
	    cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
	    cLog += cValToChar(oModel:GetErrorMessage()[6])        	
	    
	    Help( ,,"M763VLD",,cLog, 1, 0 )	             

	Endif

END TRANSACTION

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} F763Aprovar
Informa��o de aprova��o da programa��o financeira 

@author Mauricio Pequim Jr
@since   03/02/2015

/*/
//-------------------------------------------------------------------
Function F763Aprovar(cAlias,nReg,nOpc)

Local aArea			:= GetArea()
Local cTitulo 		:= ""
Local cPrograma 	:= ""
Local nOperation 	:= MODEL_OPERATION_UPDATE
Local lRet			:= .T.
Local bOK			:= {|| F763ConfVs() }

If FX0->FX0_STATUS != '2'
	Help(" ",1,"F763APROV",,STR0052+CRLF+STR0053,1,0) //"N�o � poss�vel realizar a opera��o com esse status"###"Apenas programa��es financeiras com status [Aguardando Aprova��o] poder�o ser aprovadas."
	lRet := .F.
EndIf

If lRet
	cTitulo 			:= STR0054 //"Aprova��o"
	cPrograma 			:= 'FINA763'
	__nOper     		:= OPER_APROVAR
	
	FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. }/*bCloseOnOk*/,bOK/*bOk*/, /*nPercReducao*/, /*aButtons*/ , /*bCancel*/ )

EndIf

__nOper     := 0

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F763Liberar
Informa��o de libera��o da programa��o financeira 

@author Mauricio Pequim Jr
@since   03/02/2015

/*/
//-------------------------------------------------------------------
Function F763Liberar(cAlias,nReg,nOpc)

Local aArea			:= GetArea()
Local cTitulo		:= ""
Local cPrograma 	:= ""
Local nOperation 	:= MODEL_OPERATION_UPDATE
Local lRet			:= .T.
Local bOK			:= {|| F763ConfVs() }

If FX0->FX0_STATUS != '3'
	Help(" ",1,"F763LIBER",,STR0052+CRLF+STR0055,1,0) //"N�o � poss�vel realizar a opera��o com esse status"###"Apenas programa��es financeiras com status [Aguardando Libera��o] poder�o ser liberadas."
	lRet := .F.
EndIf

If lRet
	cTitulo 			:= STR0056 //"Libera��o"
	cPrograma 			:= 'FINA763'
	__nOper     		:= OPER_LIBERAR
	
	FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. }/*bCloseOnOk*/,bOK/*bOk*/, /*nPercReducao*/, /*aButtons*/ , /*bCancel*/ )

EndIf

__nOper     := 0

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F763Concluir
Informa��o de Conclus�o da programa��o financeira 

@author Mauricio Pequim Jr
@since   03/02/2015

/*/
//-------------------------------------------------------------------
Function F763Concluir(cAlias,nReg,nOpc)

Local aArea			:= GetArea()
Local lConfirma		:= .F.
Local lCancela		:= .F.
Local cTitulo 		:= ""
Local cPrograma 	:= ""
Local nOperation 	:= MODEL_OPERATION_VIEW
Local lRet			:= .T.
Local aButtons		:= {}
Local bCancel		:= {|| F763ConfVs() }
Local cIdCV8		:= ""

If FX0->FX0_STATUS != '4'
	Help(" ",1,"F763CONCLUIR",,STR0052+CRLF+STR0057,1,0) //"N�o � poss�vel realizar a opera��o com esse status"###"Apenas programa��es financeiras com status [Aguardando Conclus�o] poder�o ser concluidas."
	lRet := .F.
EndIf

If lRet
	cTitulo 			:= STR0058 //"Conclus�o"
	cPrograma 			:= 'FINA763'
	__nOper     		:= OPER_CONCLUIR
	__lConfirmar		:= .F.
	__lBTNConfirma	:= .T.

	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0032},{.T.,STR0059},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"//"Salvar"	 //"Confirmar"###"Salvar"
	
	FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. }/*bCloseOnOk*/,/*bOk*/, /*nPercReducao*/, aButtons , bCancel )
	
	If __lConfirmar

		//Registro no log a grava��o do registro do documento h�bil
		ProcLogIni( {}, "PF" + FX0->FX0_CODIGO, "PF" + FX0->FX0_CODIGO, @cIdCV8 )

		RecLock("FX0")
		FX0->FX0_STATUS := "5"	//Concluido
		MsUnlock()
		
		ProcLogAtu( "MENSAGEM", STR0048, STR0049, , .T. ) //"Conclus�o de Programa��o Finannceira"###"Conclus�o de Programa��o Finannceira com sucesso."
	EndIf

EndIf

__lConfirmar:= .F.
__lBTNConfirma  := .F.
__nOper     := 0

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F763Cancelar
Informa��o de cancelamento da programa��o financeira 

@author Mauricio Pequim Jr
@since   03/02/2015

/*/
//-------------------------------------------------------------------
Function F763Cancelar(cAlias,nReg,nOpc)

Local aArea			:= GetArea()
Local lConfirma		:= .F.
Local lCancela		:= .F.
Local cTitulo 		:= ""
Local cPrograma 	:= ""
Local nOperation 	:= MODEL_OPERATION_VIEW
Local lRet			:= .T.
Local aButtons		:= {}
Local bCancel		:= {|| F763ConfVs() }
Local cIdCV8		:= ""

If !(FX0->FX0_STATUS $'2|3')
	Help(" ",1,"F763CANCELAR",,STR0052+CRLF+STR0060 ,1,0) //"N�o � poss�vel realizar a opera��o com esse status"###"Apenas programa��es financeiras com status [Aguardando Aprova��o] ou [Aguardando Libera��o] poder�o ser canceladas."
	lRet := .F.
EndIf

If lRet
	cTitulo 			:= STR0061 //"Cancelamento"
	cPrograma 			:= 'FINA763'
	__nOper     		:= OPER_CANCELAR
	__lConfirmar		:= .F.
	__lBTNConfirma	:= .T.

	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0032},{.T.,STR0059},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"//"Salvar"	 //"Confirmar"###"Salvar"
	
	FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. }/*bCloseOnOk*/,/*bOk*/, /*nPercReducao*/, aButtons , bCancel )
	
	If __lConfirmar

		//Registro no log a grava��o do registro do documento h�bil
		ProcLogIni( {}, "PF" + FX0->FX0_CODIGO, "PF" + FX0->FX0_CODIGO, @cIdCV8 )

		RecLock("FX0")
		FX0->FX0_STATUS := "6"	//Cancelado
		MsUnlock()
		
		ProcLogAtu( "MENSAGEM", STR0050, STR0062, , .T. ) //"Cancelamento de Programa��o Finannceira"###"Cancelamento de Programa��o Finannceira efetuado com sucesso."
	EndIf

EndIf

__lConfirmar:= .F.
__lBTNConfirma  := .F.
__nOper     := 0

RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} F763Estornar
Informa��o de cancelamento da programa��o financeira 

@author Mauricio Pequim Jr
@since   03/02/2015

/*/
//-------------------------------------------------------------------
Function F763Estornar(cAlias,nReg,nOpc)

Local aArea			:= GetArea()
Local lConfirma		:= .F.
Local lCancela		:= .F.
Local cTitulo 		:= ""
Local cPrograma 	:= ""
Local nOperation 	:= MODEL_OPERATION_VIEW
Local lRet			:= .T.
Local aButtons		:= {}
Local bCancel		:= {|| F763ConfVs() }
Local cIdCV8		:= ""

If FX0->FX0_STATUS != '4'
	Help(" ",1,"F763CANCELAR",,STR0063+CRLF+STR0064 ,1,0) //"N�o � poss�vel realizar a opera��o com esse status."###"Apenas programa��es financeiras com status [Aguardando Conclus�o] poder�o ser estornadas."
	lRet := .F.
EndIf

If lRet
	cTitulo 			:= STR0065 //"Estorno"
	cPrograma 			:= 'FINA763'
	__nOper     		:= OPER_ESTORNAR
	__lConfirmar		:= .F.
	__lBTNConfirma	:= .T.

	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0032},{.T.,STR0059},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"//"Salvar"	 //"Confirmar"###"Salvar"
	
	FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. }/*bCloseOnOk*/,/*bOk*/, /*nPercReducao*/, aButtons , bCancel )
	
	If __lConfirmar

		//Registro no log a grava��o do registro do documento h�bil
		ProcLogIni( {}, "PF" + FX0->FX0_CODIGO, "PF" + FX0->FX0_CODIGO, @cIdCV8 )

		RecLock("FX0")
		FX0->FX0_STATUS := "7"	//Estornado
		MsUnlock()
		
		ProcLogAtu( "MENSAGEM", STR0066, STR0067, , .T. ) //"Estorno de Programa��o Finannceira"###"Estorno de Programa��o Finannceira efetuado com sucesso."
	EndIf

EndIf

__lConfirmar:= .F.
__lBTNConfirma  := .F.
__nOper     := 0

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F960ConfVs
Bot�o de confirmar para opera��es
VERIFICAR
@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------
Static Function F763ConfVs()

Local cMensagem := ""
Local lRet		:= .F.

If __nOper == OPER_APROVAR
	cMensagem := STR0068 //"Confirma a aprova��o desta programa��o financeira?"
ElseIf __nOper == OPER_LIBERAR
	cMensagem := STR0069 //"Confirma a libera��o desta programa��o financeira?"
ElseIf __nOper == OPER_CONCLUIR
	cMensagem := STR0070 //"Confirma a conclus�o desta programa��o financeira?"
ElseIf __nOper == OPER_CANCELAR
	cMensagem := STR0071 //"Confirma o cancelamento desta programa��o financeira?"
ElseIf __nOper == OPER_ESTORNAR
	cMensagem := STR0072 //"Confirma o estorno desta programa��o financeira?"
EndIf

If MsgYesNo(cMensagem)
	__lConfirmar := .T.
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F763CancVs
Bot�o de cancelar para opera��es Concluir e Cancelar

@author Mauricio Pequim Jr
@since   04/02/2015

/*/
//-------------------------------------------------------------------

Static Function F763CancVs(oView)

oView:ButtonCancelAction()

Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} F763VldDt()
Valida��o da data informada na tela para informa��o das datas de 
liberacao ou aprova��o da PF 

@author Mauricio Pequim Jr
@since�03/02/2015
@version P12.1.4
/*/
//-------------------------------------------------------------------
Static Function F763VldDt(cCampo)

Local cDesc		:= ""
Local dDataCria	:= FX0->FX0_DTINCL
Local dDataLast := LastDay(dDataCria)
Local lRet		:= .T.
Local oModel 	:= FwModelActive()
Local dData		:= oModel:GetModel("CABPF"):GetValue(cCampo)
Local cMessage	:= ""
Local cSolucao	:= ""
 
If __nOper == OPER_APROVAR
	cDesc := STR0073 //"Data de Aprova��o "
ElseIf __nOper == OPER_LIBERAR
	cDesc := STR0074 //"Data de Libera��o "
Endif

If Empty(dData)
	cMessage := cDesc + STR0075 //"n�o informada."
	lRet := .F.
Endif

If lRet .and. dData < dDataCria
	cMessage := cDesc + STR0076 //"da programa��o financeira � anterior a data de cria��o da mesma."
	cSolucao := STR0077+ cDesc + STR0078+ DTOC(dDataCria) + ")." //"Informe uma "###"posterior a data de cria��o da programa��o financeira ("
	lRet := .F.
Endif

If lRet .and. dData > dDataLast
	cMessage := cDesc + STR0079		 //"da programa��o financeira � posterior ao �ltimo dia do m�s de sua cria��o."
	cSolucao := STR0077+ cDesc + STR0080+ DTOC(dDataLast) + ")." //"Informe uma "###"anterior a data final do m�s de cria��o da programa��o financeira ("
	lRet := .F.
Endif

If !lRet
	oModel:SetErrorMessage("FINA763","FX0_DTINCL","DATA"  ,"FX0_DTINCL","VLDDATA",cMessage,cSolucao)
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F763Status()
X3Combo do campo FX0_STATUS

@author Mauricio Pequim Jr
@since�03/02/2015
@version P12.1.4
/*/
//-------------------------------------------------------------------
Function F763Status()

Local cOpcoes := ""

cOpcoes := "1="+STR0002+";" //"Aguardando Envio"
cOpcoes += "2="+STR0003+";" //"Aguardando Aprova��o"
cOpcoes += "3="+STR0004+";" //"Aguardando Libera��o"
cOpcoes += "4="+STR0005+";" //"Aguardando Conclus�o"
cOpcoes += "5="+STR0006+";" //"Conclu�do"
cOpcoes += "6="+STR0007+";" //"Cancelado"
cOpcoes += "7="+STR0008+";" //"Estornado"
cOpcoes += "8="+STR0009+";" //"Com Erros"
cOpcoes += "9="+STR0010 	//"Expirado"

Return cOpcoes

//----------------------------------------------------------------------
/*/{Protheus.doc} F763ValCpo()
Valida��o do campo FX1_DTPREV 
(Data de previs�o de utiliza��o dos recursos da programa��o financeira)

@author Mauricio Pequim Jr
@since�03/02/2015
@version P12.1.4
/*/
//----------------------------------------------------------------------
Function F763ValCpo(oModel,cCpo,lMsg)

Local lRet		:= .T.
Local cTexto	:= ""
Local cMsg		:= ""
Local xVal		:= NIL

Default cCpo	:= ""
Default lMsg	:= .F.

Do Case
	Case cCpo == "FX1_DTPREV"
		xVal := oModel:GetValue("FX1_DTPREV")
		If Empty(xVal) .or. xVal < dDataBase 
			lRet := .F.
		Endif
EndCase

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} F763VldVal()
Valida��o do campo FX1_VALOR

@author Mauricio Pequim Jr
@since�03/02/2015
@version P12.1.4
/*/
//-------------------------------------------------------------------
Function F763VldVal()                                                                                                                    

Local oModel	:= FWModelActive()
Local nValorFX1 := oModel:GetModel('ITENSPF'):GetValue("FX1_VALOR")
Local lRet 		:= .T.

If nValorFx1 <= 0
	lRet := .F.
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F763EncExp

Fun��o de Encerramento de Programa��es Financeiras expiradas

@author Mauricio Pequiim Jr
@since 11/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function F763EncExp()

Local nhdlLock 	:= 0
Local nOpca		:= 0
Local cCadastro := STR0085 //"Encerramento de Programa��es Financeiras expiradas"
Local aSays		:= {}
Local aButtons	:= {}
Local aArea		:= Getarea()

// Sem�foro para utiliza��o do encerramento de PFs expiradas
// N�o permite o acesso simult�neo � rotina por mais de 1 usuario.
IF ( nHdlLock := MSFCREATE("FINA973.W"+cEmpAnt)) < 0
	MsgAlert(STR0086+CRLF+;  //"O processo de encerramento de programa��es financeiras expiradas est� sendo utilizada por outro usuario."
			 STR0087+CRLF+;  //"Por questoes de integridade de dados, nao � permitida a utiliza��o desta rotina por mais de um usu�rio simultaneamente."
			 STR0088,cCadastro) //"Por favor, tente novamente mais tarde."
	Return .T.
Endif

// Grava no sem�foro informa��es sobre quem est� utilizando a rotina.
FWrite(nHdlLock,STR0089+cUserName+CRLF+; //"Operador: "
				STR0090+cEmpAnt+CRLF+; //"Empresa.: "
				STR0091+cFilAnt+CRLF) //"Filial..: "


Aadd(aSays,STR0092) //"Este processo tem como objetivo o encerramento de progranma��es financeiras"
Aadd(aSays,STR0093) //"expiradas."
Aadd(aSays," ")
Aadd(aSays,STR0094) //"Programa��es Financeiras expiradas s�o aquelas que n�o foram concluidas at�"
Aadd(aSays,STR0095) //"o �ltimo dia do m�s de sua cria��o."

Aadd(aButtons, { 01,.T.,{|o| (o:oWnd:End(),nOpca := 1)}})
Aadd(aButtons, { 02,.T.,{|o| o:oWnd:End()}})

FormBatch(cCadastro,aSays,aButtons)
	
If nOpca == 1
	Processa({|lEnd| F763Expira()},cCadastro)
Endif	

FClose(nHdlLock)
Ferase("FINA973.W"+cEmpAnt)

RestArea(aArea)

Return(Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} F763Expira

Fun��o de Encerramento de Programa��es Financeiras expiradas (GRAVA��O)

@author Mauricio Pequiim Jr
@since 11/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function F763Expira()

Local oDlg 		:= Nil
Local oPanel	:= Nil
Local oTimer	:= Nil
Local oPFs		:= Nil
Local oSize		:= Nil
Local cQuery	:= ""
Local cCampos	:= ""
Local cChave	:= ""
Local cVarQ		:= "  "
Local cAliasQry	:= ""
Local cIdCV8	:= ""
Local cLastDay	:= DTOS(FirstDay(dDatabase))
Local nX		:= 0
Local nZ		:= 0
Local nOpca		:= 0
Local nPos 		:= 0
Local nTimeOut  := SuperGetMv("MV_FATOUT",,900)*1000 // Estabelece 15 minutos para que o usuarios selecione
Local aArea 	:= GetArea()
Local aPfs		:= {}
Local aSize		:= {}
Local a1stRow	:= {}

cQuery := "SELECT FX0_CODIGO,FX0_DTINCL,FX0_DTAPRV, FX0_DTLIB, FX0.R_E_C_N_O_ RECNO" + CRLF
cQuery += " FROM " + RetSqlName('FX0') + " FX0 " + CRLF
cQuery += " WHERE " + CRLF 
cQuery += "FX0_FILIAL = " + "'" + FWxFilial("FX0") + "' AND " + CRLF
cQuery += "FX0_STATUS IN ('1','2','3','8') AND " + CRLF
cQuery += "FX0_DTINCL < '" + cLastDay + "' AND " + CRLF
cQuery += "FX0_DTLIB  = ' ' AND " + CRLF	
cQuery += "D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery( cQuery )
cAliasQry := GetNextAlias()
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .T. )	

TcSetField(cAliasQry,"FX0_DTINCL","D",TamSX3("FX0_DTINCL")[1],TamSX3("FX0_DTINCL")[2])
TcSetField(cAliasQry,"FX0_DTAPRV","D",TamSX3("FX0_DTAPRV")[1],TamSX3("FX0_DTAPRV")[2])
TcSetField(cAliasQry,"FX0_DTLIB" ,"D",TamSX3("FX0_DTLIB")[1] ,TamSX3("FX0_DTLIB")[2] )

If !(cAliasQry)->(EOF())

	While !(cAliasQry)->(EOF())
		Aadd(aPfs,{ (cAliasQry)->FX0_CODIGO,(cAliasQry)->FX0_DTINCL,(cAliasQry)->FX0_DTAPRV,(cAliasQry)->FX0_DTAPRV } )
		(cAliasQry)->(DBSkip())
	EndDo			

	oSize := FWDefSize():New(.T.)

	oSize:AddObject("MASTER",100,100,.T.,.T.)
	oSize:lLateral := .F.				
	oSize:lProp := .T.
	
	oSize:Process()
	
	a1stRow := {oSize:GetDimension("MASTER","LININI"),;
				oSize:GetDimension("MASTER","COLINI"),;
				oSize:GetDimension("MASTER","XSIZE"),;
				oSize:GetDimension("MASTER","YSIZE")}
	

	DEFINE MSDIALOG oDlg TITLE STR0096 PIXEL FROM oSize:aWindSize[1],oSize:aWindSize[2] To oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd //"Programa��es Financeiras Expiradas"
	oTimer:= TTimer():New(nTimeOut,{|| oDlg:End() },oDlg) // Ativa timer
	oTimer:Activate()
	
	@ a1stRow[1], a1stRow[2] LISTBOX oPfs VAR cVarQ Fields;
		HEADER STR0097,STR0098,STR0099,STR0100 SIZE a1stRow[3],a1stRow[4] NOSCROLL OF oDlg PIXEL //"ID Programa��o Financeira"###"Dt. Inclus�o"###"Dt. Aprova��o"###"Dt.Libera��o"
		
	oPfs:SetArray(aPFs)
	oPfs:bLine := { || {aPFs[oPfs:nAt,1],aPFs[oPfs:nAt,2],aPFs[oPfs:nAt,3],aPFs[oPfs:nAt,4]}}  

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,oDlg:End()},{|| nOpca := 2,oDlg:End()})
Else
	Help(" ",1,"F763NOPFS",,STR0101,1,0) //"N�o foram encontradas programa��es financeiras passiveis de serem expiradas."
Endif

If nOpca == 1

	BEGIN TRANSACTION
		(cAliasQry)->(DBGoTop())
		While !(cAliasQry)->(EOF())
			
			//Atualiza o status da PF
			FX0->(DbGoto((cAliasQry)->RECNO))
			RecLock("FX0")
			FX0->FX0_STATUS := '9'	//Expirado
			MsUnlock()

			ProcLogIni( {}, "PF" + FX0->FX0_CODIGO, "PF" + FX0->FX0_CODIGO, @cIdCV8 )
			ProcLogAtu( "MENSAGEM" , STR0112 + FX0->FX0_CODIGO , STR0113,,.T. )	//'Programa��o Financeira: '###'Encerramento por expira��o de prazo.'

			//Atualiza o status das DHs amarradas a PF
			If FX2->(MsSeek(xFilial("FX2")+FX0->FX0_CODIGO))
				While !(FX2->(EOF())) .and. xFilial("FX2")+FX0->FX0_CODIGO == FX2->(FX2_FILIAL+FX2_CODIGO)
					RecLock("FX2")
					FX2->FX2_STATUS := '9'	//Expirado
					MsUnlock()
					FX2->(DBSkip())
				Enddo
			Endif
			
			(cAliasQry)->(dbSkip())
		Enddo
	END TRANSACTION

	MsgInfo(STR0102,STR0082) //"Processo realizado com sucesso."###"Informa��o"
			
Endif

Return .T.

//-------- FUN�OES PARA O ENVIO DA PROGRAMA��O FINANCEIRA VIA WEB SERVICE -----------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} SIAFCadPF()
Envio da Programa��o Financeira para o SIAFI

@author Mauricio Pequim Jr
@since�03/02/2015
@version P12.1.4
/*/
//-------------------------------------------------------------------
Function SIAFCadPF()

Local aArea			:= GetArea()
Local cTitulo 		:= ""
Local cPrograma 	:= ""
Local nOperation 	:= MODEL_OPERATION_UPDATE
Local lRet			:= .T.
Local bOK			:= {|| F763ConfVs() }
Local cIdCV8		:= ""

If FX0->FX0_STATUS != '1'
	Help(" ",1,"F763ENVIO",,STR0052,1,0) //"N�o � poss�vel realizar a opera��o com esse status"
	lRet := .F.
Else
	//Envia a programa��o financeira para o WebService do SIAFI
	WsSendPF()
EndIf

__nOper     := 0

RestArea(aArea)

Return lRet

/*/{Protheus.doc} VldSitPF
Fun��o para validar se a situa��o pode ser utilizada em Programa��o Financeira
 
@author Pedro Alencar	
@since 24/03/2015	
@version P12.1.5
/*/
Static Function VldSitPF( oModelSit, cCampo, cSituac, nLinha )

	Local lRet := .F.
	Local aAreaFVJ := FVJ->( GetArea() ) 			
	
	FVJ->( dbSetOrder( 1 ) ) //Filial + Situac. Doc.
	If FVJ->( msSeek( FWxFilial("FVJ") + cSituac ) )  
		//Se existir a situa��o, verifica se a mesma pode ser utilizada na Programa��o Financeira
		If FVJ->FVJ_TIPO == "2"		
			lRet := .T.
		Else
			lRet := .F.
			Help( "", 1, "VldSitPF1", , STR0114, 1, 0 ) //"Essa situa��o n�o pode ser utilizada em Programa��o Financeira."
		Endif
	Else
		lRet := .F.
		Help( "", 1, "VldSitPF2", , STR0115, 1, 0 ) //"Essa situa��o n�o est� cadastrada no Protheus."
	Endif
	
	FVJ->( RestArea( aAreaFVJ ) )	
	
Return lRet