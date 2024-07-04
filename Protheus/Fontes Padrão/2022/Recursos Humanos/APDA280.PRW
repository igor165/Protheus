#Include "Protheus.ch"
#Include "FwMVCDef.ch"
#Include "TopConn.ch"
#Include "APDA280.ch"

#DEFINE OPER_FECHAR   10
#DEFINE OPER_CANCELAR 11
#DEFINE OPER_REATIVAR 12

Static lFechada := .F.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o      ³ APDA280³ Autor ³ Jorge Heitor                ³ Data ³ 31/03/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS       ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Oswaldo L   ³21/12/17³DRHPAG-9991 ³Tratar acessos diretos na SX2, pontuados  ³±±
±±³            ³        ³            ³pelo sonarqube                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 


/*/{Protheus.doc} APD003

@type function
@author Jorge Heitor
@since 31/03/2016
@version 1.0
@description Funcionalidade para Cadastro de Configurações de Política de Consolidações"

/*/
Function APDA280()

	Local oBrowse	:= FwMBrowse():New()
	Local lCompart	:= APD003VC()
	Private lTemRIZ	:= .F.
	
	If lCompart
	
		oBrowse:SetAlias("RIX")
		oBrowse:SetCacheView(.F.)
		oBrowse:DisableDetails()
		oBrowse:SetDescription(STR0001) //"Política de Consolidação"
		oBrowse:AddLegend("RIX->RIX_STATUS == '1'" , "GREEN",  STR0037 ) //"Política Ativa"
		oBrowse:AddLegend("RIX->RIX_STATUS == '2'" , "ORANGE", STR0038 ) //"Política Cancelada"
		oBrowse:AddLegend("RIX->RIX_STATUS == '3'" , "RED", 	  STR0039 ) //"Política Fechada"
		//oBrowse:SetFilterDefault()
		
		oBrowse:Activate()
		
	EndIf
	
Return

/*/{Protheus.doc} MenuDef

@type function
@author Jorge Heitor
@since 31/03/2016
@version 1.0
@description Função de Pré-carregamento dos itens de Menu

/*/
Static Function MenuDef()

	Local aRotina := {} //Array utilizado para controlar opcao selecionada
	
	ADD OPTION aRotina TITLE STR0002	ACTION "PesqBrw" 		OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003	ACTION "VIEWDEF.APDA280" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004	ACTION "VIEWDEF.APDA280" OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0005	ACTION "VIEWDEF.APDA280" OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0006	ACTION "VIEWDEF.APDA280" OPERATION 5 ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE STR0040	ACTION "APDA280Leg" OPERATION 5 ACCESS 0 //"Legenda"

Return aRotina

/*/{Protheus.doc} ModelDef

@type function
@author Jorge Heitor
@since 31/03/2016
@version 1.0
@description Função de carregamento dos Modelos de Dados da Funcionalidade

/*/
Static Function ModelDef()

	Local oModel	:= MPFormModel():New('APDA280', /*Pre-Validacao*/,/*Pos-Validacao*/ , /*Commit*/,/*Cancel*/) 
	Local oStruRIX	:= FWFormStruct(1,"RIX")
	Local oStruRIY	:= FWFormStruct(1,"RIY")
	Local nX		:= 0

	oModel:AddFields("RIXMASTER",,oStruRIX)
	oModel:AddGrid("RIYDETAIL","RIXMASTER",oStruRIY,{|oModel,nLine,cAcao|Apd003VldDel(oModel,nLine,cAcao)})
	
	oModel:SetRelation( "RIYDETAIL", { { "RIY_FILIAL", "FWxFILIAL('RIY')" }, { "RIY_CODIGO", "RIX_CODIGO" } }, RIY->( IndexKey( 1 ) ) )
	oModel:GetModel( "RIYDETAIL" ):SetUniqueLine( { "RIY_CODPER" } )

	oModel:SetPrimaryKey({'RIX_FILIAL','RIX_CODIGO'})
	oModel:SetVldActivate({|oY| APD003I(oY)})
	oModel:SetPost({|oModel| APD003V(oModel)},.T.)
	
Return oModel

/*/{Protheus.doc} ViewDef

@type function
@author Jorge Heitor
@since 31/03/2016
@version 1.0
@description Função de carregamento da Interface de Manutenção dos Registros

/*/
Static Function ViewDef()

	Local oView		:= FWFormView():New()
	Local oModel	:= FwLoadModel("APDA280")
	Local oStruRIX1	:= FWFormStruct(2,"RIX")
	Local oStruRIX2	:= FWFormStruct(2,"RIX")
	Local oStruRIY	:= FWFormStruct(2,"RIY")

	//Remove campos para organização dos dados
	oStruRIX1:RemoveField("RIX_PERCOM")
	oStruRIX1:RemoveField("RIX_PERMET")
	oStruRIX1:RemoveField("RIX_PERFOR")
	
	//Remove campos já utilizados na estrutura superior
	oStruRIX2:RemoveField("RIX_FILIAL")
	oStruRIX2:RemoveField("RIX_CODIGO")
	oStruRIX2:RemoveField("RIX_DESC")
	oStruRIX2:RemoveField("RIX_STATUS")
	oStruRIX2:RemoveField("RIX_PORTAL")
	
	//Remove campo de relacionamento
	oStruRIY:RemoveField("RIY_CODIGO")
	
	oView:SetModel(oModel)

	oView:AddField("VIEWRIX1",oStruRIX1,"RIXMASTER")
	oView:AddField("VIEWRIX2",oStruRIX2,"RIXMASTER")
	oView:AddGrid("VIEWRIY",oStruRIY,"RIYDETAIL")	
	
	oView:CreateHorizontalBox('RIXFIELD',23)
	oView:CreateHorizontalBox('RIXPERC',22)
	oView:CreateHorizontalBox('RIYGRID',55)
	
	oView:SetOwnerView('VIEWRIX1','RIXFIELD')
	oView:SetOwnerView('VIEWRIX2','RIXPERC')
	oView:SetOwnerView('VIEWRIY','RIYGRID')
	
	oView:EnableControlBar(.T.)
	oView:EnableTitleView("VIEWRIX1", STR0007) //"Dados básicos:"
	oView:EnableTitleView("VIEWRIX2", STR0008) //"Percentuais de distribuição:"
	oView:EnableTitleView("VIEWRIY" , STR0009) //"Períodos envolvidos:"

Return oView

/*/{Protheus.doc} APD003V

@type function
@author Jorge Heitor
@since 31/03/2016
@version 1.0
@description Validações "TudoOK" para manutenção de uma Política de Consolidação 

/*/
Function APD003V(oModel)

	Local lRet     	:= .T.
	Local nOpc     	:= oModel:GetOperation()    
	Local oModelRIX	:= oModel:GetModel("RIXMASTER")
	Local oModelRIY := oModel:GetModel("RIYDETAIL")
 	Local nI 		:= 0
 	Local nItens	:= 0
 	Local nPercComp	:= 0
 	Local nPercMeta	:= 0
 	Local nPercForm	:= 0
 	Local cMsg		:= ""
 	Local aTipos	:= {}
 	Local lObrigaC	:= .F. //Valida preenchimento obrigatorio do percentual de Avaliação de Competências
 	Local lObrigaM	:= .F. //Valida preenchimento obritatorio do percentual de Metas
	
	If nOpc == 3 .Or. nOpc == 4 // 3 incluir 4 altera
		
		nPercComp := oModelRIX:GetValue("RIX_PERCOM")
		nPercMeta := oModelRIX:GetValue("RIX_PERMET")
		nPercForm := oModelRIX:GetValue("RIX_PERFOR")
		
		//Se não totalizar 100.00%, não permite prosseguir
		If nPercComp + nPercMeta + nPercForm <> 100.00 
	
			lRet := .F.
			cMsg := STR0010 //"A soma dos percentuais da distribuição obrigatoriamente deverá ser 100%"
			
		EndIf
		
		//Validação da Obrigatoriedade de se informar Percentual de Competencia
		If lRet
			
			//Efetua a leitura dos tipos distintos existentes 
			nItens := oModelRIY:Length(.F.)
			
			If nItens > 0
				For nI := 1 To nItens
					If !oModelRIY:IsDeleted(nI)
						If oModelRIY:GoLine(nI) == nI
							If aScan(aTipos,{|x| AllTrim(x) == oModelRIY:GetValue("RIY_TIPOPE")}) == 0
								aAdd(aTipos,oModelRIY:GetValue("RIY_TIPOPE"))
							EndIf
						EndIf
					EndIf						
				Next nI
				
				For nI := 1 To Len(aTipos)
					If aTipos[nI] == "4" .And. oModelRIX:GetValue("RIX_PERCOM") <= 0.00
						lRet := .F.
						cMsg := STR0011 //"É necessario informar o Percentual de Avaliações de Competência."
						Exit
					ElseIf aTipos[nI] == "3" .And. oModelRIX:GetValue("RIX_PERMET") <= 0.00
						lRet := .F.
						cMsg := STR0012 //"É necessario informar o Percentual de Avaliações de Metas."
						Exit
					EndIf
				Next nI
			Else
				lRet := .F.
				cMsg := STR0013 //"É necessário informar um ou mais períodos relacionados à Política de Consolidação."
			EndIf
		EndIf
	Endif
	
	If !lRet .And. !Empty(cMsg)
		oModel:SetErrorMessage("",,oModel:GetId(),"","APD003V",cMsg)
	EndIf

Return lRet

/*/{Protheus.doc} APD003I

@type function
@author Jorge Heitor
@since 04/04/2016
@version 1.0
@description Efetua validações iniciais para permitir ou não a alteração de uma Politica 

/*/
Function APD003I(oModel)

	Local lRet		:= .T.
	Local nOpc		:= oModel:GetOperation()
	Local cMsg		:= ""
	
	lFechada := .F.
	lTemRIZ	 := .F.
	
	//Tratamento para Alteração/Exclusão
	If (nOpc == 4 .Or. nOpc == 5) .And. RIX->RIX_STATUS == "3" //Fechada
		lFechada := .T.
	EndIf
	
	If lRet .and. ( nOpc == 4 .or. nOpc == 5 )
		//Verifica existencia de algum registro na tabela RIZ (resultados) para a política
		lTemRIZ := TemRIZ(RIX->RIX_CODIGO)
	EndIf

	If lRet .and. nOpc == 5 .and. lTemRIZ
		cMsg := STR0014 + STR0016 + STR0033 //"A Política selecionada não pode ser excluída, pois existe calculo efetuado."		
		lRet := .F.
	EndIf 
		
	If !Empty(cMsg)
		oModel:SetErrorMessage("",,oModel:GetId(),"","APD003I",cMsg)
	EndIf
		 	
Return lRet


/*/{Protheus.doc} TemRIZ

@type function
@author Jorge Heitor
@since 04/04/2016
@version 1.0
@description Verifica se determinado código de Politica de Consolidação já possui resultados gravados 

/*/
Static Function TemRIZ(cPolitica)

	Local lRet		:= .F.
	Local aArea		:= GetArea()
	Local cQuery	:= "SELECT COUNT(*) QTD FROM " + RetSqlName("RIZ") + " RIZ WHERE RIZ.D_E_L_E_T_ = '' AND RIZ_IDCONS = '" + cPolitica + "'"
	
	cQuery := ChangeQuery(cQuery)
	
	If Select("TRIZ") > 0 ; TRIZ->(dbCloseArea()) ; EndIf
	
	TcQuery cQuery ALIAS "TRIZ" NEW
	
	dbSelectArea("TRIZ")
	
	If !Eof() .And.TRIZ->QTD > 0
		lRet := .T.
	EndIf
	
	TRIZ->(dbCloseArea())
	
	RestArea(aArea)
	
Return lRet

/*/{Protheus.doc} APD003C

@type function
@author Jorge Heitor
@since 04/04/2016
@version 1.0
@description Inicialização de Campos 

/*/
Function APD003C(cCampo)

	Local oModel	:= FwModelActive()
	Local xRet		
	Local nOpc		:= oModel:GetOperation()
	Local aArea		:= GetArea()
	
	If nOpc <> 3
		If cCampo == "RIY_INIPER"
			xRet := Posicione("RDU",1,FWxFilial("RDU") + RIY->RIY_CODPER,"RDU_DATINI") //oModel:GetModel("RIYDETAIL"):GetValue("RIY_CODPER"),"RDU_DATINI")
		ElseIf cCampo == "RIY_FIMPER"
			xRet := Posicione("RDU",1,FWxFilial("RDU") + RIY->RIY_CODPER,"RDU_DATFIM") //oModel:GetModel("RIYDETAIL"):GetValue("RIY_CODPER"),"RDU_DATFIM")
		ElseIf cCampo == "RIY_TIPOPE"
			xRet := Posicione("RDU",1,FWxFilial("RDU") + RIY->RIY_CODPER,"RDU_TIPO") //oModel:GetModel("RIYDETAIL"):GetValue("RIY_CODPER"),"RDU_TIPO")
		ElseIf cCampo == "RIY_DESCPE"
			xRet := Posicione("RDU",1,FWxFilial("RDU") + RIY->RIY_CODPER,"RDU_DESC") //oModel:GetModel("RIYDETAIL"):GetValue("RIY_CODPER"),"RDU_DESC")
		EndIf
	ElseIf nOpc == 3 //Para inclusão manda dados zerados
		If cCampo $ "RIY_INIPER/RIY_FIMPER"
			xRet := CtoD("  /  /  ")
		ElseIf cCampo == "RIY_TIPOPE"
			xRet := " "
		ElseIf cCampo == "RIY_DESCPE"
			xRet := Space(TamSX3("RIY_DESCPE")[1])
		EndIf
	EndIf
	
	RestArea(aArea)
	
Return xRet

/*/{Protheus.doc} APD003X

@type function
@author Jorge Heitor
@since 04/04/2016
@version 1.0
@description Validação de Campos da Rotina 

/*/
Function APD003X(cCampo)

	Local lRet		:= .T.
	Local oModel	:= FwModelActive()
	Local cMsg		:= ""
	
	If alltrim(cCampo) $ "RIX_PERCOM/RIX_PERMET/RIX_PERFOR"
		xConteudo := oModel:GetModel("RIXMASTER"):GetValue(cCampo)
		If xConteudo > 100.00
			lRet := .F.
			cMsg := STR0018 //"Não é possível inserir um valor maior que 100.00 para este campo."
		EndIf
	EndIf
	
	If alltrim(cCampo) == "RIY_CODPER"
		xConteudo := oModel:GetModel("RIYDETAIL"):GetValue(cCampo)
		If !(Posicione("RDU",1,xFilial("RDU")+xConteudo,"RDU_TIPO") $ '3/4')
			lRet := .F.
			cMsg := "Período inválido. Informe um período de tipo 3-Plano de Metas ou 4-Avaliação."
		EndIf
	EndIf
	
	If !lRet .And. !Empty(cMsg)
		oModel:SetErrorMessage("",,oModel:GetId(),"","APD003X",cMsg)
	EndIf

Return lRet

/*/{Protheus.doc} APD003VC

@author Jorge Heitor
@since 19/04/2016
@version P12.1.6
@description Validação de Compartilhamento entre tabelas

/*/
Function APD003VC()

	Local lRet		:= .T.
	Local cEnt		:= chr(13) + chr(10)
	Local i			:= 0
	Local aTabs		:= {'RIX','RIY','RIZ','RDU','RD6','RD7','RD9','RDA','RDB','RDC','RDD','RDP'}
	Local cTabs		:= ''
	Local lDiverg	:= .F.
	Local aArea		:= GetArea()
	
	For i := 1 to Len(aTabs)
		cTabs += aTabs[i] + ": " + FWModeAccess( aTabs[i], 3) + '-' + FWModeAccess( aTabs[i], 2) + '-' + FWModeAccess( aTabs[i], 1) + cEnt
		If  FWModeAccess( aTabs[i], 3) <> "C" .Or. FWModeAccess( aTabs[i], 2) <> "C" .Or. FWModeAccess( aTabs[i], 1) <> "C"
			lDiverg := .T.
		EndIf
	Next i
	
	If lDiverg
		MsgAlert( STR0025 + cEnt + cEnt;    //"As tabelas abaixo devem estar todas configuradas como 'Compartilhadas':"
		+ cTabs + cEnt + STR0026, STR0027 ) //'Avise o Administrador do sistema'###'Compartilhamentos'
		lRet := .F.
	EndIf

	RestArea(aArea)
	
	If !lRet
		Final()
	EndIf

Return(lRet)

/*/{Protheus.doc} Apd003VldDel

@author Leandro Drumond
@since 28/04/2016
@version P12.1.6
@description Validação da grid RIY

/*/
Static Function Apd003VldDel(oModel,nLine,cAcao)
Local lRet	:= .T.

If cAcao == "DELETE" 
	If lFechada
		Help( ,, STR0031,, STR0035, 1, 0 ) //Atenção ## Política fechada não pode ter os períodos excluídos 
		lRet := .F.
	EndIf
	If lRet .and. lTemRIZ
		Help( ,, STR0031,, STR0036, 1, 0 ) //Atenção ## Política possui cálculo e não pode ter os períodos excluídos 
		lRet := .F.
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} RIXWhen

@author Leandro Drumond
@since 28/04/2016
@version P12.1.6
@description When dos campos RIX

/*/
Function RIXWhen()
Local lRet := !lTemRIZ .and. !lFechada

If ( ReadVar() == "M->RIX_DESC" .or. ReadVar() == "M->RIX_STATUS" ).and. !lFechada
	lRet := .T.
EndIf

Return lRet

/*/{Protheus.doc} RIXStatusVld

@author Leandro Drumond
@since 28/04/2016
@version P12.1.6
@description Valid do campo RIX_STATUS

/*/
Function RIXStatusVld()
Local lRet		:= .T.
Local cVar		:= &(ReadVar())
Local oModel	:= FwModelActive()

If !lTemRIZ .and. cVar == "3"
	Help( ,, STR0031,, STR0032, 1, 0 ) //Atenção ## Não existe cálculo efetuado. Utilize a opção de exclusão
	lRet := .F.
ElseIf RIX->RIX_STATUS =="2" .and. cVar == "3"
	Help( ,, STR0031,, STR0034, 1, 0 ) //Atenção ## A politica deve ser reativada antes de efetuar o fechamento.
	lRet := .F.
EndIf

If lRet .and. cVar == "3"
	lRet := .F.
	IF MsgNoYes(STR0028) //"Atenção: você optou por realizar o fechamento da Política. Tem certeza que deseja fechá-la ?"	
		If MsgNoYes(STR0020) //"Confirma o fechamento da Política de Cálculo Consolidado? (Esta operação é irreversível)"
			lRet:= .T.
		EndIf
	EndIf
	If !lRet
		oModel:LoadValue("RIXMASTER","RIX_STATUS",RIX->RIX_STATUS) //Retorna o valor anterior
		M->RIX_STATUS := RIX->RIX_STATUS
	EndIf
EndIf 

Return lRet	


/*/{Protheus.doc} RIXStatusVld

@author Marcos Pereira
@since 20/07/2016
@version P12.1.7
@description Legenda

/*/
Function APDA280Leg()

Local aCores := {	{"BR_VERDE"	  ,STR0037},; // 'Política Ativa'
					{"BR_LARANJA" ,STR0038},; // 'Política Cancelada'
					{"BR_VERMELHO",STR0039} } // 'Política Fechada'
					
BrwLegenda(STR0040,STR0041,aCores) //'Legenda' # "Situação da Política"

Return

