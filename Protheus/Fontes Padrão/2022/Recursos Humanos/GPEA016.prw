#Include 'Protheus.ch'
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEA016.CH"


Function GPEA016()
Local oBrowse
Local xRetFilRh
Local cFiltraRh  := ""
Local cValidFil  := ""

	xRetFilRh := CHKRH("GPEA016","SRA","1")
	If ValType(xRetFilRh) == "L"
		cFiltraRh := if(xRetFilRh,".T.",".F.")
	Else
		cFiltraRh := xRetFilRh
	EndIf
	
	cValidFil := "(SRA->RA_SEXO == 'F')"

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('SRA')
	oBrowse:SetDescription(OemToAnsi(STR0001)) //"Cadastro de Período de Gestação"
	GpLegend(@oBrowse,.T.)
	oBrowse:SetmenuDef( 'GPEA016' )

	//Filtro padrao do Browse conforme tabela SRW (Controle de Restricoes de Usuarios)
	oBrowse:SetFilterDefault(cFiltraRh)
	oBrowse:AddFilter(OemToAnsi(OemToAnsi(STR0006)),cValidFil,.T.,.T.) //Funcionárias Mulheres
	
	oBrowse:Activate()

Return Nil


Static Function MenuDef()
Local aRotina :=  {}

	ADD OPTION aRotina TITLE OemToAnsi(STR0002)  ACTION 'PesqBrw'         	OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE OemToAnsi(STR0003)  ACTION 'VIEWDEF.GPEA016' 	OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE OemToAnsi(STR0004)  ACTION 'VIEWDEF.GPEA016' 	OPERATION 3 ACCESS 0 //"Atualizar"
	ADD OPTION aRotina TITLE OemToAnsi(STR0005)  ACTION 'VIEWDEF.GPEA016' 	OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina



Static Function ModelDef()
Local oStructSRA	
Local oStructSGZ
Local oModel

	oModel := MPFormModel():New("GPEA016",/*Pre-Validacao*/,/*Pos-Validacao*/,{ |oModel| GP016Grav( oModel) }/*Commit*/, /*Cancel*/)

	oStructSRA := FWFormStruct(1,"SRA",{|cCampo| AllTrim(cCampo)+"|" $ "RA_FILIAL|RA_MAT|RA_NOME|RA_ADMISSA|"})
	oModel:AddFields("GPEA016_SRA", /*cOwner*/, oStructSRA , /*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
	oModel:GetModel("GPEA016_SRA"):SetOnlyView( .T. )
	oModel:GetModel("GPEA016_SRA"):SetOnlyQuery( .T. )

	If !IsInCallStack("FWMILEIMPORT")
		oStructSRA:SetProperty( 'RA_MAT'    ,MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD, 'SRA->RA_MAT'     ) )
		oStructSRA:SetProperty( 'RA_NOME'   ,MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD, 'SRA->RA_NOME'    ) )
		oStructSRA:SetProperty( 'RA_ADMISSA',MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD, 'SRA->RA_ADMISSA' ) )
	EndIf

	oStructSGZ := FWFormStruct(1,"SGZ")
	oModel:AddGrid("GPEA016_SGZ", "GPEA016_SRA"/*cOwner*/, oStructSGZ , /*bLinePre*/,  { |oGrid| GP016LOk(oGrid) }/* bLinePost*/, /*bPre*/,  /*bPost*/,/*bLoad*/)
	oModel:GetModel('GPEA016_SGZ'):SetOptional(.T.)

	oModel:SetRelation("GPEA016_SGZ",{{"GZ_FILIAL",'xFilial("SGZ",SRA->RA_FILIAL)'},{"GZ_MAT","RA_MAT"}},SGZ->(IndexKey()))

	oModel:SetVldActivate( { |oModel| G015VldIni(oModel,oModel:GetOperation()) } )

Return(oModel)



Static Function ViewDef()
Local oModel
Local oStructSRA
Local oStructSGZ
Local oView

	oModel     := FwLoadModel("GPEA016")

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oStructSRA := FWFormStruct(2,"SRA",{|cCampo| AllTrim(cCampo)+"|" $ "RA_MAT|RA_NOME|RA_ADMISSA|"})
	oStructSRA:SetNoFolder()

	oView:AddField( "GPEA016_SRA" , oStructSRA )

	oStructSGZ := FWFormStruct(2,"SGZ")
	oView:AddGrid(  "GPEA016_SGZ" , oStructSGZ )

	oStructSGZ:RemoveField( "GZ_MAT" )

	oView:SetViewProperty("GPEA016_SRA","OnlyView") //Somente visualizacao. Nao permite edicao dos campos do cabecalho (SRA)

	oView:createHorizontalBox("FORMFIELD",15)
	oView:createHorizontalBox("GRID"     ,85)

	oView:SetOwnerView( "GPEA016_SRA","FORMFIELD")
	oView:SetOwnerView( "GPEA016_SGZ","GRID")

	oView:SetCloseOnOk( { |oView| GP016ClsOk( oView ) } )

Return(oView)


Static Function GP016ClsOk( oView )
Local aArea      := GetArea()
Local nOperation := oView:oModel:GetOperation()
Local oGrid      := oView:oModel:GetModel("GPEA016_SGZ")
Local nLinGrdPos := oGrid:GetLine() //Linha posicionada atualmente no Grid
Local lRet       :=  .F.
Local nX         := 0

	If nOperation == MODEL_OPERATION_UPDATE
		lRet := .T.
		For nX:=1 to oGrid:GetQtdLine()
			oGrid:GoLine( nX )
			if !oGrid:IsDeleted()	
				lRet := .F.
				Exit
			EndIf
		Next nX
		oGrid:GoLine( nLinGrdPos )
	EndIf

	RestArea( aArea )
	oGrid := Nil
Return lRet


Static Function GP016Grav(oModel)
Local lRet       := .T.
Local aArea      := GetArea()
Local aSaveLines := FWSaveRows( oModel )

	FWFormCommit(oModel)

	FWRestRows( aSaveLines, oModel )

	RestArea( aArea )

	aSize(aSaveLines,0)
	aSaveLines := Nil
	oGrid := Nil

Return lRet


Static Function GP016LOk(oGrid)
Local lRet 	  := .T.
Local oStruct   := oGrid:GetStruct()
Local aCampos	  := oStruct:GetFields()
Local aPerAtual := {}
Local dDatIni	  := CtoD("//")
Local dDtaAfas  := CtoD("//")
Local dDtaRet   := CtoD("//")
Local dDtAfMat  := CtoD("//")
Local nx		  := 0
Local nGrid	  := 0
Local nG		  := 0
Local cTipAfas  := ""

Private cProcesso := SRA->RA_PROCES

fPerAtual( @aPerAtual , fGetCalcRot('1') )
//como pegar a data do afastamento por licença maternidade?


If !oGrid:IsDeleted()
	For nx := 1 To Len(aCampos)
		If Empty(oGrid:GetValue(Trim(aCampos[nx][MODEL_FIELD_IDFIELD])))
			If !Empty(oGrid:GetValue("GZ_DATAINI"))
				If SRA->RA_ADMISSA > oGrid:GetValue("GZ_DATAINI")
					lRet := .F.
					Help(" ",1,"Help",,OemToAnsi(STR0013),1,0)//"Data Inicial deve ser igual ou maior à Data de Admissão da Funcionária."
				ElseIf oGrid:GetValue("GZ_DATAINI") < aPerAtual[1, 6]  
					lRet := .F.
					Help(" ",1,"Help",,OemToAnsi(STR0015),1,0)//"Data Inicial deve ser igual ou maior à Data Inicial do Período Atual."
				EndIf 
			EndIf
			If !Empty(oGrid:GetValue("GZ_DATAFIM")) 

				// -- Verifica se Afastamento refere-se a Licenca Maternidade
				If fAfLicMat(SRA->RA_FILIAL,SRA->RA_MAT,oGrid:GetValue("GZ_DATAFIM"),@dDtaAfas,@dDtaRet,@cTipAfas)
					If cTipAfas $ 'Q1*Q3' 
						dDtAfMat := dDtaAfas 
					EndIf 
				EndIf

				If Empty(oGrid:GetValue("GZ_DATAINI"))
					lRet := .F.
					Help(" ",1,"Help",,OemToAnsi(STR0007),1,0)//"Necessário preencher Data Inicial!"
				ElseIf oGrid:GetValue("GZ_DATAFIM") < oGrid:GetValue("GZ_DATAINI")
					lRet := .F.
					Help(" ",1,"Help",,OemToAnsi(STR0008),1,0)//"Data Final deve ser maior que Data Inicial!"
				ElseIf !Empty(SRA->RA_DEMISSA) .AND. oGrid:GetValue("GZ_DATAFIM") > SRA->RA_DEMISSA
					lRet := .F.
					Help(" ",1,"Help",,OemToAnsi(STR0014) + (cValToChar(Day(SRA->RA_DEMISSA)) + "/" + cValToChar(Month(SRA->RA_DEMISSA)) + "/" + cValToChar(Year(SRA->RA_DEMISSA))),1,0)
					//"Data Final não pode ser maior que Data de Demissão "#(//)
				ElseIf !Empty(dDtAfMat) .AND. oGrid:GetValue("GZ_DATAFIM") > dDtAfMat
					lRet := .F.
					Help(" ",1,"Help",,OemToAnsi(STR0016)+(cValToChar(Day(dDtAfMat)) + "/" + cValToChar(Month(dDtAfMat)) + "/" + cValToChar(Year(dDtAfMat))),1,0)//"A data Final deve ser de 1 dia anterior à data de início do afastamento por licença maternidade.
				EndIf 
			EndIf 
		EndIf
	Next nx
	
	nGrid:=oGrid:GetLine()
	If nGrid > 1
		dDatIni:= oGrid:GetValue("GZ_DATAINI")
		For nG := 1 To oGrid:Length()
			oGrid:GoLine( nG )
			If nGrid > nG 
				If !oGrid:IsDeleted() .AND. Empty(oGrid:GetValue("GZ_DATAFIM"))
					lRet := .F.
					Help(" ",1,"Help",,OemToAnsi(STR0009),1,0)//"Para incluir novo registro, Data Final anterior deve estar preenchida!"
					Exit
				ElseIf !oGrid:IsDeleted() .AND. dDatIni < oGrid:GetValue("GZ_DATAFIM")
					lRet := .F.
					Help(" ",1,"Help",,OemToAnsi(STR0010),1,0)//"A data inicial deve ser maior que a última data final!"
					Exit
				Endif
			Endif
			If nGrid < nG
				If !oGrid:IsDeleted() .AND. dDatIni > oGrid:GetValue("GZ_DATAFIM")
					lRet := .F.
					Help(" ",1,"Help",,OemToAnsi(STR0010),1,0)//"A data inicial deve ser maior que a última data final!"
					Exit
				Endif
			EndIf
		Next nG
		oGrid:GoLine( nGrid )
	EndIf
EndIf

Return lRet


Static Function G015VldIni(oModel,nOperacao)
Local aArea     := GetArea()
Local lRet 	  := .T.
Local lRefTrab  := FindFunction("fRefTrab") .And. fRefTrab("I")

	If !lRefTrab
		lRet := .F.
		Help(,,'HELP',, OemToAnsi(STR0018),1,0 ) //"Necessário habilitar funcionalidade através do parâmetro MV_REFTRAB, incluindo a opção 'I'"
	EndIf
	
	If  lRet .AND. nOperacao == 3
		oModel:SetOperation( 4 )
	EndIf
	//--------------------------------------------------------------
	//Verifica se o Arquivo Esta Vazio
	//--------------------------------------------------------------
	If !ChkVazio("SRA")
		Return .F.
	EndIf

	If lRet .AND. nOperacao == MODEL_OPERATION_DELETE .and. GP016SGZNull()
		Help(,,'HELP',, OemToAnsi(STR0011),1,0 ) //"Não existe nenhum período de gestação cadastrado para esta funcionária."
		lRet := .F.
	EndIf

	If  lRet .AND. !(SRA->RA_SEXO == 'F')
		Help(,,'HELP',, OemToAnsi(STR0012),1,0 ) //"Funcionalidade disponível apenas para Mulheres"
		lRet := .F.
	EndIf
	RestArea( aArea )

Return lRet


Static Function GP016SGZNull()
Local aArea := GetArea()
Local lRet	:= .T.
	DbSelectArea("SGZ")
	If DbSeek(xFilial("SRA")+SRA->RA_MAT)
		lRet := .F.
	EndIf
	RestArea(aArea)
Return lRet


Function fAfLicMat(cFilFun,cMatFun,dDtPesq,dDtafas,dDtRet,cTipAfas,dDtPqIni,dDtPqFim,cVrbExcep,lDSindAf)
Local lRet		 	:= .F.
Local aAfast	    := {}
Local aPerOrd		:= {}
Local nElemAf		:= 0

DEFAULT cVrbExcep	:= ""

//--Verifica se foram passados os parametros se nao cria vazio
cFilFun	:= If(cFilFun = Nil , SRA->RA_FILIAL , cFilfun)
cMatFun	:= If(cMatFun = Nil , SRA->RA_MAT , cMatFun)

If dDtPesq == Nil .or. Empty(dDtPesq)
	aPerOrd := GpGetPerOrd()
	If Empty(aPerOrd)
		Return( .F. )
	EndIf
	dDtPesq := aPerOrd[1,7]
EndIf

If dDtPqIni == Nil .And. dDtPqFim == Nil
	dDtPqIni := Ctod("01/"+StrZero(Month(dDtPesq),2)+"/"+StrZero(Year(dDtPesq),4),"DDMMYY")
	dDtPqFim := Ctod(StrZero(f_UltDia(dDtPesq),2)+"/"+StrZero(Month(dDtPesq),2)+"/"+StrZero(Year(dDtPesq),4),"DDMMYY")
EndIf	    

//--Tratamento nas variaveis de retorno
dDtAfas	:= If(dDtAfas = Nil , Ctod("  /  /  ") , dDtAfas)
dDtRet		:= If(dDtRet  = Nil , Ctod("  /  /  ") , dDtRet)
cTipAfas 	:= Space(1)
lDSindAf	:= .F.             
             
//--Funcao que retorna os afastamentos conforme a tabela RCM - Tipo de Afastamento

fBuscaAfast(dDtPqIni,dDtPqFim,@aAfast, , ,cVrbExcep)

//--Retorna o ultimo elemento sobre o periodo para as variaveis de retorno
nElemAf := Len(aAfast)
If nElemAf > 0
	dDtAfas  := aAfast[nElemAf,1]
	dDtRet	 := aAfast[nElemAf,2]
	cTipAfas := AAfast[nElemAf,19] //RCM_CODSEF	
	lDSindAf := If(cPaisLoc == "BRA" .And. aAfast[nElemAf,30] == "2",.T.,.F.)	   	
	lRet 	 := .T.
EndIf

Return lRet