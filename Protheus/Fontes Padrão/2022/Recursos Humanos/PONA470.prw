#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PONA470.CH"

/*/{Protheus.doc} PONA470
Cadastro de bloqueio de períodos para o Ponto Eletrônico
@author Cícero Alves
@since 22/03/2022
@Type Function
/*/
Function PONA470()
	
	Local oMBrowse
	Local cFiltraRh := ""
	
	oMBrowse := FWMBrowse():New()
	
	oMBrowse:SetAlias("RG3")
	oMBrowse:SetDescription(STR0001) // "Bloqueio de Períodos Ponto Eletrônico"
	oMBrowse:SetmenuDef( "PONA470" )
	oMBrowse:SetChgAll(.F.)
	
	// Inicializa o filtro utilizando a funcao FilBrowse
	cFiltraRh := CHKRH("PONA470", "RG3", "1")
	cFiltraRh += If(!Empty(cFiltraRh), " .And. " , "")
	cFiltraRh += "RG3_ROTEIR == 'PON' .And. RG3_FIL == '" + cFilAnt + "'"
	
	oMBrowse:SetFilterDefault( cFiltraRh )
	
	oMBrowse:Activate()
	
Return

/*/{Protheus.doc} ModelDef
Cria modelo de dados com base na tabela RG3
@author Cícero Alves
@since 24/01/2021
@Type Static Function
/*/
Static Function ModelDef()
	
	Local oModel
	Local oStructF		// Estrutura apenas para permitir a criação do grid sem cabeçalho
	Local oStructRG3
	
	//Criacao do Objeto de Modelagem de dados 
	oModel := MPFormModel():New("PONA470")
	oModel:SetDescription(STR0001) // "Bloqueio de Períodos Ponto Eletrônico"
	
	//Cabecalho (fake)
	oStructF := FWFormModelStruct():New()
	oStructF:addTable("", {"CAMPO1"}, STR0001, {|| ""})
	oStructF:addField("String 01", "Campo de texto", "CAMPO1", "C", 2)
	oModel:AddFields("PONA470_F", , oStructF,,,{|| Space(2)})
	oModel:GetModel( "PONA470_F" ):SetDescription(STR0001) // "Bloqueio de Períodos Ponto Eletrônico"
	
	//Estrutura de campos do Model - RG3 - Bloqueio de períodos
	oStructRG3 := FWFormStruct(1, "RG3")
	
	oStructRG3:SetProperty( "RG3_USER1",  MODEL_FIELD_VALID, { |oModel| PON470VldUser(oModel, 1)})
	oStructRG3:SetProperty( "RG3_USER2",  MODEL_FIELD_VALID, { |oModel| PON470VldUser(oModel, 2)})
	oStructRG3:SetProperty( "RG3_DTINI",  MODEL_FIELD_VALID, { |oModel| PON470VldDat(oModel)})
	oStructRG3:SetProperty( "RG3_DTFIM",  MODEL_FIELD_VALID, { |oModel| PON470VldDat(oModel)})
	oStructRG3:SetProperty( "RG3_DFIL",   MODEL_FIELD_VALID, { || .T.})
	oStructRG3:SetProperty( "RG3_ROTEIR", MODEL_FIELD_VALID, { || .T.})
	oStructRG3:SetProperty( "RG3_DTINI",  MODEL_FIELD_OBRIGAT, .T.)
	oStructRG3:SetProperty( "RG3_DTFIM",  MODEL_FIELD_OBRIGAT, .T.)
	oStructRG3:SetProperty( "RG3_PERIOD", MODEL_FIELD_OBRIGAT, .T.)
	oStructRG3:SetProperty( "RG3_FIL", 	  MODEL_FIELD_WHEN, { || .T.})
	
	oStructRG3:SetProperty( "RG3_EMP",    MODEL_FIELD_INIT, {||cEmpAnt})
	oStructRG3:SetProperty( "RG3_FIL",    MODEL_FIELD_INIT, {||cFilAnt})
	oStructRG3:SetProperty( "RG3_PERIOD", MODEL_FIELD_INIT, {|| GetPerPon()} )
	oStructRG3:SetProperty( "RG3_ROTEIR", MODEL_FIELD_INIT, {||"PON"} )
	oStructRG3:SetProperty( "RG3_NUSER1", MODEL_FIELD_INIT, {|| UsrRetName(RG3->RG3_USER1)} )
	oStructRG3:SetProperty( "RG3_NUSER2", MODEL_FIELD_INIT, {|| UsrRetName(RG3->RG3_USER2)} )
	oStructRG3:SetProperty( "RG3_DFIL",   MODEL_FIELD_INIT, {|| FwFilialName(, RG3->RG3_FIL)} )
	
	oModel:AddGrid("PONA470_MRG3", "PONA470_F", oStructRG3,,{|oModelGrid| PON470VldDat(oModelGrid) })
	oModel:GetModel( "PONA470_MRG3" ):SetDescription(STR0001) // "Bloqueio de Períodos Ponto Eletrônico"
	oModel:GetModel( "PONA470_MRG3" ):SetOptional(.T.)
	oModel:GetModel( "PONA470_MRG3" ):SetUniqueLine({"RG3_FIL", "RG3_PERIOD", "RG3_ROTEIR"})
	
	oModel:SetRelation( "PONA470_MRG3", {{ "RG3_FILIAL", "xFilial('RG3')" }, { "RG3_FIL", "cFilAnt" }, {"RG3_ROTEIR", '"PON"'}}, RG3->( IndexKey()))
	
	// É necessário que haja alguma alteração na estrutura Field
	oModel:setActivate({ |oModel| onActivate(oModel)})
	
Return( oModel )

/*/{Protheus.doc} ViewDef
Regras de Interface com o Usuario
@author Cícero Alves
@since 22/03/2022
@Type StaticFunction
/*/
Static Function ViewDef()
	
	Local oView 
	Local oModel
	Local oStructRG3
	Local bLoadFil := {|oView| Pon470LoadPer(oView)}
	
	oModel := FWLoadModel("PONA470")
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	oStructRG3 := FWFormStruct(2, "RG3")
	oStructRG3:RemoveField( "RG3_EMP" )
	oStructRG3:RemoveField( "RG3_ROTEIR" )
	oStructRG3:SetProperty( "RG3_PERIOD", MVC_VIEW_PICT, "@R 9999/99" )
	oStructRG3:SetProperty( "RG3_PERIOD", MVC_VIEW_CANCHANGE, .T. )
	oStructRG3:SetProperty( "RG3_FIL", MVC_VIEW_CANCHANGE, .F. )
	oStructRG3:RemoveField( "RG3_SEMANA" )
	
	oView:AddGrid("PONA470_VRG3", oStructRG3, "PONA470_MRG3" )
	
	oView:CreateHorizontalBox("RG3_BODY", 100)
	
	oView:SetOwnerView( "PONA470_VRG3", "RG3_BODY" )
	
	oView:EnableTitleView("PONA470_VRG3")
	
	// "Replicar Períodos"
	oView:addUserButton(STR0002, "", bLoadFil, STR0002 + "...", , {MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE })
	
Return oView

/*/{Protheus.doc} PON470VldUser
Valida usuário liberado
@author Cícero Alves
@since 23/03/2022
/*/
Static Function PON470VldUser(oGrid, nUser)
	
	Local lRet  := .F.
	Local cUser := ""
	Local cDesc := ""
	
	If nUser == 1
		cUser := oGrid:GetValue("RG3_USER1")
	Else 
		cUser := oGrid:GetValue("RG3_USER2")
	EndIf
	
	If !Empty(cUser)
		If UsrExist(cUser)
			lRet := .T.
			cDesc := UsrRetName( cUser )
		EndIf
		
		If nUser == 1
			oGrid:LoadValue("RG3_NUSER1", cDesc)
		Else 
			oGrid:LoadValue("RG3_NUSER2", cDesc)
		EndIf
	Else
		lRet := .T.
	EndIf
	
Return lRet

/*/{Protheus.doc} PON470VldDat
Valida data inicial e final
@author Cícero Alves
@since 24/03/2022
/*/
Static Function PON470VldDat(oGrid)
	
	Local dDtFim	:= Ctod("")
	Local dDtIni	:= Ctod("")
	Local dPerIni	:= cTod("//")
	Local dPerFim	:= cTod("//")
	Local lRet      := .T.
	Local cPerPon	:= ""
	
	dDtIni := oGrid:GetValue("RG3_DTINI")
	dDtFim := oGrid:GetValue("RG3_DTFIM")
	cPerPon := oGrid:GetValue("RG3_PERIOD")
	
	
	Begin Sequence
		
		If Empty(cPerPon) // "Período não informado"
			Help( ,, "HELP",, STR0016, 1, 0,,,,,, {STR0017}) // "Informe o período para o qual deseja cadastrar o bloqueio."
			lRet := .F.
			Break
		EndIf
		
		// Busca período do ponto
		PerAponta(@dPerIni, @dPerFim, LastDate(SToD(cPerPon + "01")))
		
		If !Empty(dDtFim) .And. ( dDtFim < dDtIni )
			Help(" ", 1, "DATA2INVAL") // "A Data de Fim nao pode ser menor do que a Data de Inicio."
			lRet := .F.
			Break
		EndIf
		
		If !Empty(dDtIni) .And. ( dDtIni < dPerIni ) // "A data inicial nao pode anteceder a data inicial do periodo selecionado"
			Help( ,, "HELP",, STR0003, 1, 0,,,,,, {STR0004 + DtoC(dPerIni) + " - " + DtoC(dPerFim) }) // "Período selecionado: "
			lRet := .F.
			Break
		EndIf
		
		If !Empty(dDtIni) .And. ( dDtIni > dPerFim ) // "A data inicial não pode ultrapassar a data final do período selecionado."
			Help( ,, "HELP",, STR0005, 1, 0,,,,,,{STR0004 + DtoC(dPerIni) + " - " + DtoC(dPerFim) }) // "Período selecionado: "
			lRet := .F.
			Break
		EndIf
		
		If !Empty(dDtFim) .And. dDtFim > dPerFim // "A data final não pode ultrapassar a data final do período selecionado."
			Help( ,, "HELP",, STR0006, 1, 0,,,,,,{STR0004 + DtoC(dPerIni) + " - " + DtoC(dPerFim) })  // "Período selecionado: "
			lRet := .F.
			Break
		EndIf
		
	End Sequence
	
Return( lRet )

/*/{Protheus.doc} Pon470LoadPer
Carrega períodos futuros replicando as informações
@author Cícero Alves
@param oView, Objeto, View ativa
@since 24/03/2022
/*/
Static Function Pon470LoadPer(oView)
	
	Local aArea			:= GetArea()
	Local aColumns		:= {}
	Local aStru			:= {}
	Local aLstIndices	:= {}
	Local cUser1  		:= ""
	Local cUser2  		:= ""
	Local cNome1  		:= ""
	Local cNome2  		:= ""
	Local dDtIni  		:= ""
	Local dDtFim  		:= ""
	Local lMarcar 		:= .T.
	Local oModel      	:= oView:GetModel()
	Local oGrid			:= oModel:GetModel("PONA470_MRG3")
	Local nOpcX 		:= 0
	Local nCont
	Local oSize 
	Local oDlgGrid 
	Local oTela2
	Local oPanel4
	Local oMark
	Local oGroup
	Local oFont
	Local cPerPon		:= oGrid:GetValue("RG3_PERIOD")
	Local dPerIni		:= oGrid:GetValue("RG3_DTINI")
	Local dPerFim		:= oGrid:GetValue("RG3_DTFIM")
	Local cCodFil		:= ""
	Local cNFil			:= ""
	
	Private cFilAux 	:= oGrid:GetValue("RG3_FIL")
	Private cAliasTRB
	
	Static cAliasTmp
	Static oArqTmp
	
	If Empty(cPerPon) .Or. Empty(dPerIni) .Or. Empty(dPerFim) // "Período, data inicial ou data final do bloqueio não informados"
		Help( ,, "HELP",, STR0018, 1, 0,,,,,, {STR0019}) // "Informe o período, a data inicial e final do bloqueio para replicar as informações."
		Return
	EndIf
	
	If !(oArqTmp == Nil)
		oArqTmp:Delete()
	EndIf
	
	Aadd(aStru, {"OK"	  , "C", 2, 0})
	Aadd(aStru, {"PERIODO", "C", 6, 0})
	Aadd(aStru, {"DTINI"  , "D", 8, 0})
	Aadd(aStru, {"DTFIM"  , "D", 8, 0})
	AAdd(aLstIndices, {"PERIODO"})
	
	cAliasTmp := cAliasTRB := GetNextAlias()
	
	oArqTmp := RhCriaTrab(cAliasTRB, aStru, aLstIndices)
	
	For nCont := 1 To 12
		
		cPerPon := AnoMes(MonthSum(sToD(cPerPon + "01"), 1))
		
		RecLock(cAliasTRB, .T.)
			(cAliasTRB)->PERIODO := cPerPon
			(cAliasTRB)->DTINI   := MonthSum(dPerIni, nCont)
			(cAliasTRB)->DTFIM   := MonthSum(dPerFim, nCont)
		(cAliasTRB)->(MsUnlock())
	Next nCont
	
	cUser1  := oGrid:GetValue("RG3_USER1")
	cNome1  := oGrid:GetValue("RG3_NUSER1")
	cUser2 	:= oGrid:GetValue("RG3_USER2")
	cNome2  := oGrid:GetValue("RG3_NUSER2")
	dDtIni  := oGrid:GetValue("RG3_DTINI")
	dDtFim  := oGrid:GetValue("RG3_DTFIM")
	cCodFil := oGrid:GetValue("RG3_FIL")
	cNFil   := oGrid:GetValue("RG3_DFIL")
	
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->PERIODO}") )
	aColumns[Len(aColumns)]:SetTitle(STR0007) // "Período"
	aColumns[Len(aColumns)]:SetSize(6)
	aColumns[Len(aColumns)]:SetDecimal(0)
	aColumns[Len(aColumns)]:SetPicture("@R 9999/99")
	
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->DTINI}") )
	aColumns[Len(aColumns)]:SetTitle(STR0008) // "Data Inicial do bloqueio"
	aColumns[Len(aColumns)]:SetSize(8)
	aColumns[Len(aColumns)]:SetDecimal(0)
	aColumns[Len(aColumns)]:SetPicture("")
	
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->DTFIM}") )
	aColumns[Len(aColumns)]:SetTitle(STR0009) // "Data Final do bloqueio"
	aColumns[Len(aColumns)]:SetSize(8)
	aColumns[Len(aColumns)]:SetDecimal(0)
	aColumns[Len(aColumns)]:SetPicture("")
	
	oSize := FwDefSize():New(.F.)
	
	oSize:AddObject( "CABECALHO", (oSize:aWindSize[3]*1.1),(oSize:aWindSize[3]*0.4) , .F., .F. ) // Não dimensionavel
	oSize:aMargins := { 0, 0, 0, 0 } 		// Espaco ao lado dos objetos 0, entre eles 3
	oSize:lProp := .F.		 				// Proporcional
	oSize:Process() 	   					// Dispara os calculos
	
	DEFINE FONT oFont NAME "Arial" SIZE 0, -11 BOLD
	
	DEFINE MSDIALOG oDlgGrid TITLE STR0010 From 0,0 TO 380,930 OF oMainWnd PIXEL // "Selecione os períodos"
	
	// Cria o conteiner onde serão colocados os paineis
	oTela2		:= FWFormContainer():New( oDlgGrid )
	cIdGrid  	:= oTela2:CreateHorizontalBox( 80 )
	
	oTela2:Activate( oDlgGrid, .F. )
	
	//Cria os paineis onde serao colocados os browses
	oPanel4	:= oTela2:GeTPanel( cIdGrid )
	
	@ oSize:GetDimension("CABECALHO","LININI") + 1, oSize:GetDimension("CABECALHO", "COLINI") + 4 GROUP oGroup TO oSize:GetDimension("CABECALHO","LINEND") * 0.090 ,oSize:GetDimension("CABECALHO","COLEND") * 0.431 LABEL STR0010 OF oDlgGrid PIXEL // "Selecione os períodos"
	oGroup:oFont:=oFont
	@ oSize:GetDimension("CABECALHO","LININI")+9 , oSize:GetDimension("CABECALHO","COLINI")+6 SAY "" Of oDlgGrid Pixel
	
	oMark := FWMarkBrowse():New()
	
	oMark:SetOwner(oPanel4)
	oMark:SetAlias(cAliasTRB)
	oMark:SetTemporary(.T.)
	oMark:SetColumns(aColumns)
	oMark:SetFieldMark('OK')
	oMark:SetIgnoreARotina(.T.)
	oMark:SetMenuDef('')
	
	oMark:bAllMark := { || SetMarkAll(oMark:Mark(), lMarcar := !lMarcar, cAliasTRB ), oMark:Refresh(.T.)  }
	
	oMark:Activate()
	
	SetMarkAll(oMark:Mark(),.T.,cAliasTRB) //Marca todos os registros
	
	oMark:Refresh(.T.)
	
	ACTIVATE MSDIALOG oDlgGrid CENTERED ON INIT EnchoiceBar(oDlgGrid, {||nOPcX := 1, oDlgGrid:End() } ,{|| oDlgGrid:End() }, NIL, {})
	
	If nOpcX == 1
		
		//Adiciona filiais selecionadas
		(cAliasTRB)->(dbGoTop())
		
		While (cAliasTRB)->(!EOF())
			If !Empty((cAliasTRB)->OK)
				
				If !oGrid:SeekLine({{"RG3_PERIOD", (cAliasTRB)->PERIODO}}, .F., .T. )
					oGrid:AddLine(.T.)
				EndIf
				
				oGrid:LoadValue("RG3_FILIAL", xFilial("RG3", cCodFil))
				oGrid:LoadValue("RG3_FIL"	, cCodFil)
				oGrid:LoadValue("RG3_DFIL"	, cNFil)
				oGrid:LoadValue("RG3_USER1"	, cUser1)
				oGrid:LoadValue("RG3_NUSER1", cNome1)
				oGrid:LoadValue("RG3_USER2"	, cUser2)
				oGrid:LoadValue("RG3_NUSER2", cNome2)
				oGrid:LoadValue("RG3_DTINI"	, (cAliasTRB)->DTINI)
				oGrid:LoadValue("RG3_DTFIM"	, (cAliasTRB)->DTFIM)
				oGrid:LoadValue("RG3_PERIOD", (cAliasTRB)->PERIODO)
			EndIf
			
			(cAliasTRB)->(dbSkip())
		EndDo
		
		oGrid:GoLine(1)
	EndIf
	
	RestArea(aArea)
	
Return Nil

/*/{Protheus.doc} SetMarkAll
Marca/Desmarca todos os períodos
@author Cícero Alves
@since 24/03/2022
/*/
Static Function SetMarkAll(cMarca, lMarcar, cAliasTRB)
	
	Local cAliasMark := cAliasTRB
	Local aAreaMark  := (cAliasMark)->( GetArea() )
	
	dbSelectArea(cAliasMark)
	(cAliasMark)->( dbGoTop() )
	
	While !(cAliasMark)->( Eof() )
		RecLock( (cAliasMark), .F. )
		(cAliasMark)->OK := IIf( lMarcar, cMarca, '  ' )
		MsUnLock()
		(cAliasMark)->( dbSkip() )
	EndDo
	
	RestArea(aAreaMark)
	
Return .T.

/*/{Protheus.doc} MenuDef
Define opções do menu da rotina
@author Leandro Drumond
@since 24/01/2021
@version P12.1.33
/*/
Static Function MenuDef()
	
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0011 ACTION "PESQBRW"         OPERATION 1 ACCESS 0 DISABLE MENU 	//"Pesquisar"
	ADD OPTION aRotina TITLE STR0012 ACTION "VIEWDEF.PONA470" OPERATION 2 ACCESS 0 					//"Visualizar"
	ADD OPTION aRotina TITLE STR0020 ACTION "CallPON470" 	  OPERATION 3 ACCESS 0					//"Bloqueio de Períodos"  
	ADD OPTION aRotina TITLE STR0015 ACTION "VIEWDEF.PONA470" OPERATION 5 ACCESS 0					//"Excluir"
	
Return aRotina

/*/{Protheus.doc} getPerPon
Retorna o período de apontamento atual
@type  Static Function
@author Cícero Alves
@since 24/03/2022
@return cPerPon, Caractere, Período do ponto no formato AAAAMM
/*/
Static Function getPerPon()
	
	Local cPerPon	:= ""
	Local dPerIni	:= cTod("//")
	Local dPerFim	:= cTod("//")
	
	If PerAponta(@dPerIni, @dPerFim)
		cPerPon := AnoMes(dPerIni)
	EndIf
	
Return cPerPon

/*/{Protheus.doc} onActivate
Altera o campo no cabeçalho "fake" para permitir a inclusão
@type  Static Function
@author Cícero Alves
@since 25/03/2022
@see https://tdn.totvs.com/x/PpNvI (Criando uma tela MVC só com GRID)
/*/
Static Function onActivate(oModel)
	// Só efetua a alteração do campo para inserção
	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		FwFldPut("CAMPO1", "FK", , oModel)
	EndIf
Return
