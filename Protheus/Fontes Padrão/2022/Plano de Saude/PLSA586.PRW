#include "PROTHEUS.CH"
#Include 'FWMVCDef.ch'
#include "PLSA586.CH"

Static lPLSUNI := GetNewPar("MV_PLSUNI", "0") == "1"
Static _oSelRDA		:= NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA586
Cadastro de Pacotes
@author Silvia Sant'Anna
@since 01/2021
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA586(lAutoma)
	Local oBrowse	:= nil
	Default lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )	

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('BLD')
	oBrowse:SetDescription("Cadastro de Pacotes")

	iif(!lAutoma, oBrowse:Activate(), '')

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Cadastro de Pacotes
@author Silvia Sant'Anna
@since 01/2021
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	Add Option aRotina Title 'Visualizar'				Action 'VIEWDEF.PLSA586'	Operation 2 Access 0
	Add Option aRotina Title 'Incluir'					Action 'VIEWDEF.PLSA586'	Operation 3 Access 0
	Add Option aRotina Title 'Alterar'					Action 'VIEWDEF.PLSA586'	Operation 4 Access 0
	Add Option aRotina Title 'Excluir'					Action 'VIEWDEF.PLSA586'	Operation 5 Access 0
	Add Option aRotina Title 'Vincular pacote com RDAs'	Action 'pl586Vinc()'		Operation 2 Access 0

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Cadastro de Pacotes
@author Silvia Sant'Anna
@since 01/2021
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel // Modelo de dados construído
	// Cria as estruturas a serem usadas no Modelo de Dados, ajustando os campos que irá considerar
	Local oStrBLD	:= FWFormStruct(1,'BLD',  )
	Local oStrBLE	:= FWFormStruct(1,'BLE',  ) 

	// Cria o objeto do Modelo de Dados e insere a funçao de pós-validação
	oModel := MPFormModel():New( 'PLSA586', , {|oModel| pl586VldOk(oModel)} , , )
	//MPFormModel():New( STR0038, /*bPreValidacao*/, /*bPosValidacao*/, {|oModel|PMGRVBOK(oModel)}/*bCommit*/, /*bCancel*/ ) //'Elegiveis/Inscritos' 

	// Adiciona ao modelo um componente de formulário
	oModel:addFields('MasterBLD',/*cOwner*/,oStrBLD)  

	// Adiciona ao modelo uma componente de grid
	oModel:AddGrid('BLEDetail', 'MasterBLD', oStrBLE)

	// Faz relacionamento entre os componentes do model
	oModel:SetRelation( 'BLEDetail', { { 'BLE_FILIAL', 'xFilial( "BLE" )' } ,{ 'BLE_CODINT', 'BLD->BLD_CODINT' } ,{ 'BLE_CODPAD', 'BLD->BLD_CODPAD' } ,{ 'BLE_CODPRO', 'BLD->BLD_CODPRO' }}, BLE->( IndexKey( 1 ) ) )  

	oModel:SetPrimaryKey( {"BLD_FILIAL", "BLD_CODINT", "BLD_CODPAD", "BLD_CODPRO"} )

	oStrBLE:SetProperty( "BLE_VIGDE"  , MODEL_FIELD_VALID, { || pls586VlDt(oModel:GetValue("BLEDetail","BLE_VIGDE"),oModel:GetValue("BLEDetail","BLE_VIGATE")) })
	oStrBLE:SetProperty( "BLE_VIGATE" , MODEL_FIELD_VALID, { || pls586VlDt(oModel:GetValue("BLEDetail","BLE_VIGDE"),oModel:GetValue("BLEDetail","BLE_VIGATE")) })

	oStrBLD:SetProperty( "BLD_CODPAD", MODEL_FIELD_WHEN , { || Iif(oModel:GetOperation()==3, .T., .F.) } )
	oStrBLD:SetProperty( "BLD_CODPRO", MODEL_FIELD_WHEN , { || Iif(oModel:GetOperation()==3, .T., .F.) } )
	oStrBLD:SetProperty( 'BLD_DESINT', MODEL_FIELD_TAMANHO, 100 )

Return oModel // Retorna o Modelo de dados


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Cadastro de Pacotes
@author Silvia Sant'Anna
@since 01/2021
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	// Interface de visualização construída
	Local oView 

	// Carrega o model existente
	Local oModel := FWLoadModel( 'PLSA586' )

	// Cria as estruturas a serem usadas na View 
	Local oStrBLD:= FWFormStruct(2, 'BLD', { |cCampo| PlsBLDView(cCampo) })
	Local oStrBLE:= FWFormStruct(2, 'BLE', { |cCampo| PlsBLEView(cCampo) })

	oView := FWFormView():New() // Cria o objeto de View

	// Define qual Modelo de dados será utilizado
	oView:SetModel(oModel)

	// Adiciona nas views um controle do tipo formulário 
	oView:AddField('ViewBLD' , oStrBLD,'MasterBLD' ) 
	oView:AddGrid( 'ViewBLE' , oStrBLE,'BLEDetail' ) 

	// Cria um "box" horizontal para receber cada elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR' , 40 ) 
	oView:CreateHorizontalBox( 'INFERIOR1', 60 ) 

	//Atribui a cada view os respectivos "box" criados acima
	oView:SetOwnerView('ViewBLD','SUPERIOR') 
	oView:SetOwnerView('ViewBLE','INFERIOR1')

	//Filtro de pesquisa
	oView:SetViewProperty("BLEDetail", "GRIDFILTER", {.T.})
	oView:SetViewProperty("BLEDetail", "GRIDSEEK", {.T.})

	//Tornando campos editáveis apenas quando for inclusão
    oStrBLD:SetProperty( 'BLD_CODPAD'  , MVC_VIEW_CANCHANGE, .T. ) //não está funcionando MVC_VIEW_CANCHANGE com esta condição.
    oStrBLD:SetProperty( 'BLD_CODPRO'  , MVC_VIEW_CANCHANGE, .T. )

    //Ordem dos campos (BLD)
	oStrBLD:SetProperty( 'BLD_CODINT'  , MVC_VIEW_ORDEM, "00" )
	oStrBLD:SetProperty( 'BLD_DESINT'  , MVC_VIEW_ORDEM, "01" )
    oStrBLD:SetProperty( 'BLD_CODPAD'  , MVC_VIEW_ORDEM, "03" )
    oStrBLD:SetProperty( 'BLD_CODPRO'  , MVC_VIEW_ORDEM, "04" )
    oStrBLD:SetProperty( 'BLD_DESPRO'  , MVC_VIEW_ORDEM, "05" )

	//Ordem dos campos na grid (BLE)
	oStrBLE:SetProperty( 'BLE_CPADOC'  , MVC_VIEW_ORDEM, "00" )
	oStrBLE:SetProperty( 'BLE_CODOPC'  , MVC_VIEW_ORDEM, "01" ) 
	oStrBLE:SetProperty( 'BLE_DESOPC'  , MVC_VIEW_ORDEM, "02" ) 

    oStrBLE:SetProperty( 'BLE_TIPO'    , MVC_VIEW_CANCHANGE, .F. )
	
Return oView 


//-------------------------------------------------------------------
/*/{Protheus.doc} pl586VldOk
Valida a inclusão do Registro.
Chamada pelo bPosValidacao do ModelDef.
@since 01/2021
@version P12
/*/
//-------------------------------------------------------------------
Static Function pl586VldOk(oModel)
	Local lRet		:= .T.
	Local oGridBLE	:= oModel:getModel("BLEDetail")
	Local nQtPrincip:= 0
	Local nI := 0

	for nI := 1 to oGridBLE:length()
		oGridBLE:goline(nI)
		if oGridBLE:getValue("BLE_PRINCI") == "1"
			nQtPrincip ++
		endIf
	next
	If nQtPrincip > 1
		MsgAlert(STR0002,STR0003) //"Existe mais de um procedimento Principal cadastrado neste pacote." ### "Atencao"
		lRet := .F.
	EndIf

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PlsBLDView
Tratamento para definir os campos da BLD que não serão usados na View
@author Silvia Sant'Anna
@since 01/2021
@version P12
/*/
//-------------------------------------------------------------------
Function PlsBLDView (cCampo)
	Local lRet	:= .T.
	cCampo := Alltrim(cCampo)

	If cCampo $ "BLD_CODPAC|BLD_DESCRI" 
		lRet := .F.
	EndIf
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PlsBLEView
Tratamento para definir os campos da BLE que não serão usados na View
@author Silvia Sant'Anna
@since 01/2021
@version P12
/*/
//-------------------------------------------------------------------
Function PlsBLEView (cCampo)
	Local lRet	:= .T.
	cCampo := Alltrim(cCampo)

	If cCampo $ "BLE_VALCH|BLE_COMPAR" 
		lRet := .F.
	EndIf
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} RetBLEProc
Retorna o código do procedimento para consulta padrão BM9PLS
Está no X3_VALID do campo BLE_CODOPC
@author Silvia Sant'Anna
@since 01/2021
@version P12
/*/
//-------------------------------------------------------------------
FUNCTION RetBLEProc()
	Local cRet	   := ""

	oModelRec := FwModelActive()
	cRet := oModelRec:GetValue( 'BLEDetail', 'BLE_CODOPC' )
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetBLECPad
Retorna o codPad
Está no X3_VALID do campo BLE_CODOPC.
@author Silvia Sant'Anna
@since 01/2021
@version P12
/*/
//-------------------------------------------------------------------
FUNCTION RetBLECPad()
	Local cRet	   := ""

	oModelRec := FwModelActive()
	cRet := oModelRec:GetValue( 'BLEDetail', 'BLE_CPADOC' )
Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} RetBLEDesc
Atualiza descrição do procedimento quando o código é digitado
Está no X3_VALID do campo BLE_CODOPC
@author Silvia Sant'Anna
@since 01/2021
@version P12
/*/
//-------------------------------------------------------------------
FUNCTION RetBLEDesc()
	Local cCodTbPrc := ""

	oModelRec := FwModelActive()
	cCodTbPrc := xFilial("BR8") + oModelRec:GetValue( 'BLEDetail', 'BLE_CPADOC' ) + oModelRec:GetValue( 'BLEDetail', 'BLE_CODOPC' )		
	oModelRec:LoadValue( 'BLEDetail', 'BLE_DESOPC', SubStr(ALLTRIM(Posicione("BR8",1,cCodTbPrc,"BR8_DESCRI")),1,30) )	
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} LoadBLETipo
Carrega o tipo do procedimento (BLE_TIPO) quando o código é digitado
Está no X3_VALID do campo BLE_CODOPC
@author Silvia Sant'Anna
@since 01/2021
@version P12
/*/
//-------------------------------------------------------------------
FUNCTION LoadBLETipo()
	Local lPacote := .F.
	Local cTipo	  := ""
	Local cCPADOC := ""
	Local cCODOPC := ""

	oModelRec := FwModelActive()
	cCPADOC := oModelRec:GetValue( 'BLEDetail', 'BLE_CPADOC' )
	cCODOPC := oModelRec:GetValue( 'BLEDetail', 'BLE_CODOPC' )

	BR8->(DbSetOrder(1))
	If BR8->(MsSeek(xFilial("BR8")+cCPADOC+cCODOPC))
		cTipo := BR8->BR8_TPPROC
	EndIf

	iF cTipo == "6"
		lPacote := .T.
	EndIf

	If !lPacote
		oModelRec:LoadValue( 'BLEDetail', 'BLE_TIPO', cTipo )	
	EndIf
	
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} pls586VlDt
Valida se a data de validade inicial não é maior do que a data final. 
@author Silvia Sant'Anna
@since 01/2021
@version P12
/*/
//-------------------------------------------------------------------
Function pls586VlDt (dDatIn,dDatFin)
	Local lRet		:= .T.
	Local dDataFin	:= ""

	dDataFin := ALLTRIM(DTOS(dDatFin))

	If !Empty(dDataFin) .And. dDatFin < dDatIn
		lRet := .F.
		MsgInfo(STR0004,STR0003) //"A data de validade inicial não pode ser maior do que a data final." ### "Atenção"
	Endif
 
Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} Pl586Valid
Função que faz a validação e carrega os dados do grid
Está no X3_VALID do campo BLD_CODPRO
@author Silvia Sant'Anna
@since 01/2021
@version P12
/*/
//-------------------------------------------------------------------
Function Pl586Valid()
	Local oModel		:= nil
    Local lRet      	:= .T.
    Local cCodint   	:= ""
    Local ccodpad   	:= ""
    Local ccodpro   	:= ""

	oModel := FwModelActive()

    cCodint := oModel:getModel("MasterBLD"):getValue("BLD_CODINT")
    ccodpad := oModel:getModel("MasterBLD"):getValue("BLD_CODPAD")
    ccodpro := oModel:getModel("MasterBLD"):getValue("BLD_CODPRO")

	BLD->(dbSetOrder(1))//BLD_FILIAL, BLD_CODINT, BLD_CODPAD, BLD_CODPRO
	If BLD->(dbSeek(xFilial("BLD")+cCodint+ccodpad+ccodpro))
		Aviso( OemtoAnsi(STR0005), OemtoAnsi(STR0006) , { STR0007 }, 2 )  //"Procedimento Invalido" ### "Procedimento principal ja existe em um pacote! ### "Ok"
		lRet:= .F. 
	Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} pl586Vinc
Vincular o Pacote selecionado com as RDAs.
@author Silvia Sant'Anna
@since 01/2021
@version P12
/*/
//-------------------------------------------------------------------
Function pl586Vinc(lAutoma)
	Local lRet      	:= .T.
	Local lRetBLZ		:= .T.
	Local lPergVinc		:= .T.
	Local cCodInt   	:= BLD->BLD_CODINT
	Local cCodPad   	:= BLD->BLD_CODPAD
	Local cCodPro   	:= BLD->BLD_CODPRO
	Local cSQL 			:= ""
	Local cBLEDtVig		:= ""
	Local aStruBLE		:= BLE->(DbStruct())
	Local nI			:= 0
	Local cCampo		:= ""

	Local aDados		:= {}
	Local aRetMark		:= {}
	Local aPos			:= {}
	Local nVez			:= 0
	Local nPos			:= 0

	Default lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )	

	// Selecionando a data de início de vigência para o cabeçalho (BLZ). Deve ser a menor data de início de vigência de um item ativo (BLE)
	cSQL := "SELECT Min(BLE_VIGDE) VIG FROM " + RetSqlName('BLE')
	cSQL += " WHERE BLE_FILIAL = '" + xFilial('BLE') + "' "
	cSql += "   AND BLE_CODINT = '" + cCodInt + "' "  
	cSQL += "   AND BLE_CODPAD = '" + cCodPad + "' " 
	cSQL += "   AND BLE_CODPRO = '" + cCodPro + "' " 
	cSQL += "   AND BLE_ATIVO  = '1' " 
	cSQL += "   AND ( BLE_VIGATE = ' ' OR BLE_VIGATE >= '" + DtoS(dDataBase) + "' ) "
	cSQL += "   AND D_E_L_E_T_ = ' ' " 

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,changequery(cSql)),"TRBBLEVIG",.F.,.T.)
	cBLEDtVig := TRBBLEVIG->VIG
	TRBBLEVIG->(dbCloseArea())


	// Selecionando todas as RDAs não bloqueadas na data atual.
	cSQL := " SELECT BAU_FILIAL, BAU_CODIGO, BAU_NOME, BAU_TIPPE, BAU_CPFCGC, BAU_RECPRO, BAU_DTINCL, BAU_SIGLCR, BAU_ESTCR, BAU_CONREG, BAU_TIPPRE "  
	cSQL += "   FROM " + RetSQLName('BAU') + "  "
	cSQL += "  WHERE BAU_FILIAL = '" + xFilial('BAU') + "' "
	cSQL += "    AND ( BAU_CODBLO = ' ' OR BAU_DATBLO > '" + DtoS(dDataBase) + "' ) "
	cSQL += "    AND D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,changequery(cSql)),"QRYBAU",.F.,.T.)

	If !( QRYBAU->(EoF()) )
		While !( QRYBAU->(EoF()) )
			aadd(aDados,{	QRYBAU->BAU_FILIAL, ;
							QRYBAU->BAU_CODIGO, ;
							QRYBAU->BAU_NOME,   ;
							QRYBAU->BAU_TIPPE,  ;
							QRYBAU->BAU_CPFCGC, ;
							QRYBAU->BAU_RECPRO, ;
							QRYBAU->BAU_DTINCL, ;
							QRYBAU->BAU_SIGLCR, ;
							QRYBAU->BAU_ESTCR,  ;
							QRYBAU->BAU_CONREG, ;
							QRYBAU->BAU_TIPPRE})
			QRYBAU->( DbSkip() )
		EndDo
	EndIf
	QRYBAU->(dbCloseArea())

	//Cria o FWMarkBrowse usando uma FWTemporaryTable da BAU.
	aRetMark := pls586Mark(aDados,lAutoma)

	//Verifica se alguma RDA foi selecionada
	If LEN(aRetMark) > 0
		If !lAutoma
			lPergVinc := msgYesNo(STR0008 +cCodPad+"-"+AllTrim(cCodPro)+ STR0009) //"Deseja vincular o pacote " ### "com a(s) RDA(s) selecionada(s) ?"
		EndIf

		If lPergVinc .OR. lAutoma

			For nVez := 1 To Len(aRetMark)

				aPos := aRetMark[nVez] // {.F.,0}
				nPos := aPos[2]
				If aPos[1] .AND. nPos > 0
					cCodRda := aDados[nPos,2]

					// Caso uma RDA já tenha o pacote vinculado, não deve ser vinculado novamente.
					BLZ->(dbSetOrder(1))//BLZ_FILIAL+BLZ_CODINT+BLZ_CODRDA+BLZ_CODPAD+BLZ_CODPRO
					lRetBLZ := BLZ->(MsSeek (xFilial("BLZ")+cCodInt+cCodRda+cCodPad+cCodPro))

					If !lRetBLZ
						// Incluindo dados da BLD na BLZ
						BLZ->(RecLock("BLZ", .T.))
						BLZ->BLZ_FILIAL := xFilial("BLZ")
						BLZ->BLZ_CODINT := cCodInt
						BLZ->BLZ_CODRDA := cCodRda
						BLZ->BLZ_CODPAD := cCodPad
						BLZ->BLZ_CODPRO := cCodPro
						BLZ->BLZ_VIGINI := StoD(cBLEDtVig)
						BLZ->BLZ_VERSAO := '001'
						BLZ->(MsUnLock())
		
						// Incluindo dados da BLE na BLY
						BLE->(DbSetOrder(1)) //BLE_FILIAL+BLE_CODINT+BLE_CODPAD+BLE_CODPRO+BLE_TIPO+BLE_CPADOC+BLE_CODOPC 
						If BLE->(MsSeek(xFilial("BLE")+cCodInt+cCodPad+cCodPro))
							While !( BLE->(EoF()) )
								// Somente itens vigentes na data devem ser replicados.
								If BLE->BLE_CODPRO == cCodPro .AND. ( (dDataBase >= BLE->BLE_VIGDE) .AND. (dDataBase <= BLE->BLE_VIGATE)  .or.;
																	 (dDataBase >= BLE->BLE_VIGDE) .AND. (empty(BLE->BLE_VIGATE)) )		
									BLY->(RecLock("BLY", .T.))
									For nI:=1 to Len(aStruBLE)
										cCampo := aStruBLE[nI,1]
										&("BLY->BLY_"+Substr(cCampo,5,10)) := &("BLE->"+cCampo)
									Next
									BLY->BLY_CODRDA := cCodRda
									BLY->BLY_VERSAO := '001'
									BLY->(MsUnLock())
								EndIf
								BLE->( DbSkip() )
							EndDo
						EndIf
					EndIf //lRetBLZ
				Endif
			Next nVez
			If !lAutoma
				MsgInfo(STR0010 +cCodPad+"-"+AllTrim(cCodPro)+ STR0011) //"O vínculo do Pacote " ### " com a(s) RDA(s) selecionadas foi realizado com sucesso !"
			EndIf
		EndIf
	Else
		If !lAutoma
			MsgAlert(STR0012) //"Para realizar o vínculo, deve-se ter pelo menos uma RDA selecionada."
		EndIf
		lRet := .F.
	Endif 

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} pls586Mark
Selecionar as RDAs que ou titulos por vez, para excluir em um lote
@author Silvia Sant'Anna
@since 01/2021
@version P12
/*/
//-------------------------------------------------------------------
Function pls586Mark(aDados,lAutoma)
	Local aCpos		:= {}
	Local aCampos	:= {}
	Local aRet		:= {}
	Local aTam		:= {}
	Local cTitMBrow	:= OemToAnsi("Vincular pacote com RDAs")
	Local nFor 		:= 0

	Private cAliasTRB	:= ""
	Private cMarca 		:= ""

	Default lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )	

	aTam := TamSx3("BAU_FILIAL")
	aAdd(aCpos,   {"FILIAL"			,"C", aTam[1]	, aTam[2]})
	aAdd(aCampos, {"Filial"			,"FILIAL"		,"C","@!",1,aTam[1],aTam[2]})

	//aTam := {06,00}
	aTam := TamSx3("BAU_CODIGO")
	aAdd(aCpos,   {"COD_RDA"		,"C", aTam[1]	, aTam[2]})
	aAdd(aCampos, {"Cod. Rda"		,"COD_RDA"		,"C","@!",0,aTam[1],aTam[2]})

	aTam := TamSx3("BAU_NOME")
	aAdd(aCpos,   {"NOME_RDA"		,"C", aTam[1]	, aTam[2]})
	aAdd(aCampos, {"Nome da RDA"	,"NOME_RDA"		,"C","@!",1,aTam[1],aTam[2]})

	aTam := TamSx3("BAU_TIPPE")
	aAdd(aCpos,   {"TP_PESSOA"		,"C", aTam[1]	, aTam[2]})
	aAdd(aCampos, {"Tipo Pessoa "	,"TP_PESSOA"	,"C","@!",1,aTam[1],aTam[2]})

	aTam := TamSx3("BAU_CPFCGC")
	aAdd(aCpos,   {"CPF_CNPJ"		,"C", aTam[1]	, aTam[2]})
	aAdd(aCampos, {"CPF/CNPJ"		,"CPF_CNPJ"		,"C","@!",1,aTam[1],aTam[2]})

	aTam := TamSx3("BAU_RECPRO")
	aAdd(aCpos,   {"REC_PROPRI"		,"C", aTam[1]	, aTam[2]})
	aAdd(aCampos, {"Rec. Proprio"	,"REC_PROPRI"	,"C","@!",1,aTam[1],aTam[2]})

	aTam := TamSx3("BAU_DTINCL")
	aAdd(aCpos,   {"DT_INCL"		,"C", aTam[1]	, aTam[2]})
	aAdd(aCampos, {"Dt. Inclusao"	,"DT_INCL"		,"C","@!",1,aTam[1],aTam[2]})

	aTam := TamSx3("BAU_SIGLCR")
	aAdd(aCpos,   {"SIGLA_CR"		,"C", aTam[1]	, aTam[2]})
	aAdd(aCampos, {"Sigla CR"		,"SIGLA_CR"		,"C","@!",1,aTam[1],aTam[2]})

	aTam := TamSx3("BAU_ESTCR")
	aAdd(aCpos,   {"ESTADO_CR"		,"C", aTam[1]	, aTam[2]})
	aAdd(aCampos, {"Estado CR"		,"ESTADO_CR"	,"C","@!",1,aTam[1],aTam[2]})

	aTam := TamSx3("BAU_CONREG")
	aAdd(aCpos,   {"NUM_CR"			,"C", aTam[1]	, aTam[2]})
	aAdd(aCampos, {"Numero CR"		,"NUM_CR"		,"C","@!",1,aTam[1],aTam[2]})

	aTam := TamSx3("BAU_TIPPRE")
	aAdd(aCpos,   {"CLASS_REDE"		,"C", aTam[1]	, aTam[2]})
	aAdd(aCampos, {"Classe Rede "	,"CLASS_REDE"	,"C","@!",1,aTam[1],aTam[2]})

	aTam := {02,00}
	aAdd(aCpos,   {"IDMARK"			,"C", aTam[1], aTam[2]})

	//------------------
	//Criacao da tabela temporaria
	//------------------
	If _oSelRDA <> Nil
		_oSelRDA:Delete()
		_oSelRDA := Nil
	Endif
	cAliasTRB := GetNextAlias()
	_oSelRDA  := FWTemporaryTable():New( cAliasTRB )  
	_oSelRDA:SetFields(aCpos) 
	_oSelRDA:Create()
	//aStru
	For nFor := 1 to Len(aDados)
		(cAliasTRB)->(RecLock(cAliasTRB,.T.))
		(cAliasTRB)->FILIAL			:= aDados[nFor][01]
		(cAliasTRB)->COD_RDA		:= aDados[nFor][02]
		(cAliasTRB)->NOME_RDA		:= aDados[nFor][03]
		(cAliasTRB)->TP_PESSOA		:= aDados[nFor][04]
		(cAliasTRB)->CPF_CNPJ		:= aDados[nFor][05]
		(cAliasTRB)->REC_PROPRI		:= aDados[nFor][06]
		(cAliasTRB)->DT_INCL		:= aDados[nFor][07]
		(cAliasTRB)->SIGLA_CR		:= aDados[nFor][08]
		(cAliasTRB)->ESTADO_CR		:= aDados[nFor][09]
		(cAliasTRB)->NUM_CR			:= aDados[nFor][10]
		(cAliasTRB)->CLASS_REDE		:= aDados[nFor][11]
		(cAliasTRB)->(MsUnLock())
	Next nFor

	If Len(aDados) > 0
		_aMarks := {}
		Private aRotina		:= {}

		aAdd(aRotina,{"Vincular pacotes" 	,"pl586Ret()"	, 0,4})
		aAdd(aRotina,{"Marca/Desmarca todos","pl586Inver(oMark)"	, 0,4})
		
		dbSelectArea(cAliasTRB)
		dbGoTop()

		// Construcao do MarkBrowse
		oMark:=FWMarkBrowse():NEW()		// Cria o objeto oMark - MarkBrowse
		oMark:SetAlias(cAliasTRB)		// Define a tabela do MarkBrowse
		oMark:SetDescription(cTitMBrow)	// Define o titulo do MarkBrowse
		oMark:SetFieldMark("IDMARK")	// Define o campo utilizado para a marcacao
		oMark:SetFilterDefault("")		// Define o filtro a ser aplicado no MarkBrowse
		oMark:SetFields(aCampos)		// Define os campos a serem mostrados no MarkBrowse
		oMark:SetSemaphore(.F.)			// Define se utiliza marcacao exclusiva
		oMark:SetWalkThru(.F.)			// Desabilita a opcao de WalkThru
		oMark:DisableReport()			// Desabilita a opcao de imprimir
		oMark:SetAllMark({|| pl586Inver(oMark)})
		iif(!lAutoma, oMark:Activate(), '') // Ativa o MarkBrowse

		If lAutoma
			AaDd(_aMarks, {.T., aScan(aDados,{|x| x[2] == "000007"})})
		EndIf

		If !Empty(_aMarks)
			For nFor := 1 To Len(_aMarks)
				aAdd(aRet,{_aMarks[nFor][01],_aMarks[nFor][02]})
			Next nFor
		EndIf
	Else
		If !lAutoma
			Help( ,, 'HELP',,STR0013, 1, 0) //"Registros não encontrado !"
		EndIf
	EndIf

	If _oSelRDA <> Nil
		_oSelRDA:Delete()
		_oSelRDA := Nil
	Endif

Return(aRet)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} pl586Ret
Prepara o array de retorno para vincular com o pacote.
@author Silvia Sant'Anna
@since 01/2021
@version P12
/*/
//------------------------------------------------------------------------------------------
Function pl586Ret()
	Local cMarca	:= oMark:Mark()
	Local nPos		:= 0

	_aMarks := {}

	dbSelectArea(cAliasTRB)
	(cAliasTRB)->(DbGoTop())

	While !(cAliasTRB)->(Eof())
		nPos++
		If oMark:IsMark(cMarca)
			aAdd(_aMarks,{.T.,nPos})
		EndIf
		(cAliasTRB)->(dbSkip())
	EndDo

	CloseBrowse()

Return()


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} pl586Inver
Função para marcar e desmarcar todos da MarkBrowse
@author Silvia Sant'Anna
@since 01/2021
@version P12
/*/
//------------------------------------------------------------------------------------------
function pl586Inver(oMark)
	Local lRet		:= .T.		  	 						// Retorno da rotina.                           
	Local aAreaTmp	:= (oMark:Alias())->(GetArea())	  		// Guarda a area do browse.
	Local lTop 		:= .T.	  								// Posiciona no primeiro registro.

		(oMark:Alias())->(DbGoTop())
		While (oMark:Alias())->(!Eof())
			// Marca ou desmarca. Este metodo respeita o controle de semaphoro. 
			oMark:MarkRec()
			(oMark:Alias())->(DbSkip())
		EndDo

	RestArea(aAreaTmp)  
	oMark:Refresh(lTop)

Return lRet



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PL586CarCr
Carrega as críticas.
@author Silvia Sant'Anna
@since 01/2021
@version P12
/*/
//------------------------------------------------------------------------------------------
Function PL586CarCr()

PutHelp("PPLSA586001",{"Não foi possível incluir o registro.","",""},{},{},.f.)
PutHelp("SPLSA586001",{"Já existe um procedimento","principal cadastrado neste pacote.",""},{},{},.f.)

PutHelp("PPLSA586002",{"Não foi possível alterar a vigência.","",""},{},{},.f.)
PutHelp("SPLSA586002",{"Periodos de vigências de/até","incompativeis.",""},{},{},.f.)

Return
