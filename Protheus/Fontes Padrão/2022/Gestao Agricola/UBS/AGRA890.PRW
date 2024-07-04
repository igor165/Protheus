#INCLUDE "AGRA890.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'TOTVS.CH'

Static lObgLocal := .F.
// -------------------------------------------------------------------------------------
Function AGRA890()
	Private vVetTRB := {},oView := Nil
	If !AGRIFDICIONA("SIX","NPM3",1,.f.)
		AGRINCOMDIC("U_AGRUPD .. UPDNPM")
		Return
	EndIf
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('NPG')
	oBrowse:SetDescription(STR0001)
	// Legendas
	AGRLEGEBROW(@oBrowse,{{"NPG_STATUS = '1'",AGRRETSX3BOX("NPG_STATUS",'1'),"BLUE"}		 ,{"NPG_STATUS = '2'",AGRRETSX3BOX("NPG_STATUS",'2'),"GREEN"},;
	{"NPG_STATUS = '3'",AGRRETSX3BOX("NPG_STATUS",'3'),"BR_CANCEL"},{"NPG_STATUS = '4'",AGRRETSX3BOX("NPG_STATUS",'4'),"YELLOW"},;
	{"NPG_STATUS = '5'",AGRRETSX3BOX("NPG_STATUS",'5'),"ORANGE"}	 ,{"NPG_STATUS = '6'",AGRRETSX3BOX("NPG_STATUS",'6'),"PINK"},;
	{"NPG_STATUS = '7'",AGRRETSX3BOX("NPG_STATUS",'7'),"RED"}		 ,{"NPG_STATUS = '8'",AGRRETSX3BOX("NPG_STATUS",'8'),"PMSEDT2"},;
	{"NPG_STATUS = '9'",AGRRETSX3BOX("NPG_STATUS",'9'),"BLACK"}})
	oBrowse:SetCacheView(.F.)
	oBrowse:Activate()
Return

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu padrão da rotina
@author: Aecio Ferreira Gomes
@since: 20/02/2013
@Uso: AGRA890
/*/
// -------------------------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.AGRA890'	OPERATION 2 	ACCESS 0	//Visualizar
	ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.AGRA890'	OPERATION 4 	ACCESS 0	//Alterar
	If EXISTBLOCK ("AGR890P2")
		ADD OPTION aRotina Title STR0008 Action 'U_AGR890P2'	OPERATION 8 	ACCESS 0 //Imprime
	Else
		//TODO Remover do fonte e criar fonte de impresso em separado
		ADD OPTION aRotina Title STR0008 Action 'AGRA890IM'		OPERATION 8 	ACCESS 0 //Imprime
	EndIf
	ADD OPTION aRotina Title STR0022 Action 'AGR890APR'			OPERATION 9 	ACCESS 0	//Aprovar
	ADD OPTION aRotina Title STR0023 Action 'AGR890CAN'			OPERATION 10 	ACCESS 0	//Cancelar
	ADD OPTION aRotina Title STR0032 Action 'AGR890HIS'			OPERATION 11 	ACCESS 0	//Historico

	If ExistBlock('AGR890MEN')
		aRet := ExecBlock('AGR890MEN',.F.,.F.,{aRotina})
		If ValType(aRet) == 'A'
			aRotina	:= aClone(aRet)
		EndIf
	EndIf

Return aRotina

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados da rotina
@author: Aecio Ferreira Gomes
@since: 20/02/2013
@Uso: AGRA890
/*/
// -------------------------------------------------------------------------------------
Static Function ModelDef()
	Private aColsOld,oView := Nil

	oModel   := Nil
	oStruNPG := FwFormStruct( 1, "NPG" ) // Autorização de Carregamento
	oStruNPH := FwFormStruct( 1, "NPH" ) // Itens da Autorização de Carregamento
	oStruADB := FwFormStruct( 1, "ADB" ) // Itens do Contrato de Parceria

	// Instancia o model
	oModel := MpFormModel():New( 'AGRA890', , , {|oMdl| AGRA890GRV(oMdl)},)
	oModel:SetDescription( STR0001 )

	// Adiciona estrutura do cabecallho no modelo de dados
	oModel:AddFields( 'NPGMASTER',,oStruNPG)
	oModel:GetModel( 'NPGMASTER' ):SetDescription( STR0009 )

	// Adiciona estrutura da Grid no modelo de dados
	oStruNPH:AddField(STR0033,STR0033,'NPH_QTDSLD','N',14,0,,,{},.F.,FWBuildFeature(STRUCT_FEATURE_INIPAD,""),.F.,.F.,.F.,,)
	oStruNPH:AddField(STR0067,STR0067,'NPH_QTDEND','N',14,0,,,{},.F.,FWBuildFeature(STRUCT_FEATURE_INIPAD,""),.F.,.F.,.F.,,)
	oStruNPH:AddField(STR0034,STR0034,'NPH_TOTAL','N',14,0,,,{},.F.,,.F.,.F.,.F.,,)

	oModel:AddGrid( 'NPHDETAIL', 'NPGMASTER', oStruNPH)

	oModel:GetModel( 'NPHDETAIL' ):SetDescription( STR0010 )

	// Não deixa incluir uma nova linha no grid
	oModel:GetModel( 'NPHDETAIL' ):SetNoInsertLine( .T. )

	// Seta Relacionamento
	oModel:SetRelation( 'NPHDETAIL', { { 'NPH_FILIAL', 'xFilial( "NPH" )' }, { 'NPH_CODAC','NPG_CODIGO' } }, NPH->(IndexKey()))

	// Seta Chave Primaria
	oModel:SetPrimaryKey( {"NPG_FILIAL","NPG_CODIGO"} )

	oStruNPH:SetProperty( 'NPH_CULTRA'	,MODEL_FIELD_WHEN,{||ValidCtro("ADB_CULTRA")})
	oStruNPH:SetProperty( 'NPH_CTVAR' 	,MODEL_FIELD_WHEN,{||ValidCtro("ADB_CTVAR")}	)
	oStruNPH:SetProperty( 'NPH_CATEG' 	,MODEL_FIELD_WHEN,{||ValidCtro("ADB_CATEG")}	)
	oStruNPH:SetProperty( 'NPH_PENE'  	,MODEL_FIELD_WHEN,{||ValidCtro("ADB_PENE") }	)
	///=== Define validações ===///
	oStruNPH:SetProperty( "NPH_LOCAL" 	, MODEL_FIELD_VALID , FwBuildFeature( STRUCT_FEATURE_VALID,"AGRA890VIT()") )

	//Ajusta Obrigatoriedade, mas armazena condição do dicionario
	lObgLocal := oStruNPH:GetProperty("NPH_LOCAL",MODEL_FIELD_OBRIGAT)
	if lObgLocal
		oStruNPH:SetProperty("NPH_LOCAL",MODEL_FIELD_OBRIGAT,.F.)
	endif
	// Valida antes da ativação do model
	oModel:SetVldActive( { |oMdl| A890VLDACT( oMdl ) } )

	// Valida a ativação do model
	oModel:SetActivate( { |oMdl| AGRA890ACT( oMdl ) } )

Return oModel


/*/{Protheus.doc} VldLine
// Função de Validação das linhas da grid
@author bruna.rocio
@since 21/10/2016
@version undefined
@param oModelGrid, object, descricao
@param cAction, characters, descricao
@type function
/*/
Static Function VldLine(oModelGrid, cAction, cCodPro)
	Local aArea      := GetArea()
	Local oModel 	 := oModelGrid:GetModel()
	Local nOperation := oModel:GetOperation()
	Local nQtdDisp   := 0
	Local nSaldoBF   := 0
	Local nX
	Local lRet       := .T.
		
	If nOperation==MODEL_OPERATION_UPDATE .Or. ;
	   nOperation==MODEL_OPERATION_INSERT	
		
		dbSelectArea('ADA')
		dbSetOrder(1)
		If dbSeek(FwXFilial('ADA')+FwFldGet("NPH_NUMCP"))
			For nX := 1 To oModelGrid:Length()
				If lRet
					oModelGrid:Goline(nX)
						
					If oModelGrid:IsUpdated(nX) .And. iif(!Empty(cCodPro), FwFldGet('NPH_CODPRO') = cCodPro, !Empty(FwFldGet('NPH_CODPRO')))						
						//Validação de Saldo do Lote
						validaSaldo( ADA->ADA_CODSAF, FwFldGet('NPH_CODPRO'), FwFldGet("NPH_LOCAL"), FwFldGet("NPH_CULTRA"), FwFldGet("NPH_CATEG"),; 
								     FwFldGet("NPH_PENE"), FwFldGet("NPH_CTVAR"), @nQtdDisp, @nSaldoBF )
														
						If FwFldGet('NPH_QUANT') > 	nQtdDisp			
										
							If APMSGYESNO( AllTrim(FwFldGet("NPH_CODPRO"))+" - "+ AllTrim(POSICIONE("SB1", 1, xFilial("SB1") + FwFldGet("NPH_CODPRO"), "B1_DESC"));
							+Chr(13)+STR0014 +Chr(13)+ STR0020+":"+CVALTOCHAR(nX)+ " "+STR0013 +Chr(13)+STR0035,STR0036,"YESNO" )
							Else
								lRet := .F.
							EndIf
						Endif
					Endif	
				Endif	
			Next nX
			oModelGrid:Goline(1)
		Endif
	Endif
	
	RestArea(aArea)
Return lRet

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface da rotina
@author: Aecio Ferreira Gomes
@since: 20/02/2013
@Uso: AGRA890
/*/
// -------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel	:= FwLoadModel( "AGRA890" )
	Local oStruNPG 	:= FwFormStruct( 2,"NPG",{|cCampo| !(Alltrim(cCampo) $ "NPG_STATUS")}) // Autorização de Carregamento
	Local oStruNPH 	:= FwFormStruct( 2,"NPH") // Itens da Autorização de Carregamento
	Public oView := Nil

	// Instancia a View
	oView := FwFormView():New()

	// Seta o model
	oView:SetModel( oModel )

	// Adiciona os campos na estrutura da View
	oView:AddField( 'VIEW_NPG', oStruNPG, 'NPGMASTER' )
	//Habilita o campo de valor de saldo, para que se possa usar a função F4
	oStruNPH:AddField( 'NPH_TOTAL','',STR0034,STR0034,, 'Get' ,'@E 99,999,999,999.99',,,.F.,,,,,,,, )
	oStruNPH:AddField( 'NPH_QTDSLD','',STR0033,STR0033,, 'Get' ,'@E 99,999,999,999.99',,,.T.,,,,,,.F.,, )
	oStruNPH:AddField( 'NPH_QTDEND','',STR0067,STR0067,, 'Get' ,'@E 99,999,999,999.99',,,.F.,,,,,,.F.,, )

	oView:AddGrid( 'VIEW_NPH' , oStruNPH, 'NPHDETAIL')

	// Cria o Box
	oView:CreateHorizontalBox( 'ENCHO', 70 )
	oView:CreateHorizontalBox( 'GRID', 30 )

	oStruNPH:SetProperty('NPH_TOTAL',MVC_VIEW_ORDEM,CVALTOCHAR(Len(oStruNPH:GetFields())+1))
	oStruNPH:SetProperty('NPH_QTDSLD',MVC_VIEW_ORDEM,CVALTOCHAR(Len(oStruNPH:GetFields())+1))
	oStruNPH:SetProperty('NPH_QTDEND',MVC_VIEW_ORDEM,CVALTOCHAR(Len(oStruNPH:GetFields())+1))


	// Seta Owner
	oView:SetOwnerView( 'VIEW_NPG', 'ENCHO' )
	oView:SetOwnerView( 'VIEW_NPH', 'GRID' )

	// Seta o campo incremental da Grid
	oView:AddIncrementField( 'VIEW_NPH', 'NPH_ITEM' )
		
	SetKey( VK_F4, { || AGR890F4() } )

Return oView



// -------------------------------------------------------------------------------------
/*/{Protheus.doc} A890VLDACT
Validação antes da ativação do model antes de apresentação da interface
@author: Aecio Ferreira Gomes
@since: 20/02/2013
@Uso: AGRA890
/*/
// -------------------------------------------------------------------------------------
Static Function A890VLDACT( oModel )
	Local nOperation := oModel:GetOperation(),lRet := .T.

	If nOperation == MODEL_OPERATION_UPDATE //Status permitido para Alteração e Exclusão somente Status igual a 1=Aguardando Aprovação ou 8=Parcialmente Atendido
		If !(NPG->NPG_STATUS $ "1|8")

			If NPG->NPG_STATUS == "2"
				If AGRIFDBSEEK("NPM",NPG->NPG_CODIGO,3,.F.)
					lRet := .F.
				EndIf
			Else
				lRet := .F.
			EndIf

		EndIf
	ElseIf nOperation == MODEL_OPERATION_DELETE
		If NPG->NPG_STATUS $ "2|4|5|6|7|8"
			lRet := .F.
		EndIf
	EndIf

	If !lRet
		Help("  ",1,"AGRA890AC")
	EndIf

	vVetTRB := AGRCOPIAREG("NPG")
Return(lRet)

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA890ACT
Validação após a ativação do model antes de apresentação da interface
@author: Aecio Ferreira Gomes
@since: 20/02/2013
@Uso: AGRA890
/*/
// -------------------------------------------------------------------------------------
Static Function AGRA890ACT( oModel )
	Local oAux			:= oModel:GetModel("NPHDETAIL")
	Local oGridNPG		:= oModel:GetModel("NPGMASTER")
	Local oGridNPH		:= oModel:GetModel("NPHDETAIL")
	Local nOperation	:= oModel:GetOperation()
	Local nLinha,nX,nQtdDisp,nSaldoBF,npgQtd,npgTot,lRet := .T.
	Local lAGR890P3 := EXISTBLOCK ("AGR890P3")
	Local oStruNPH 	:= FwFormStruct( 2,"NPH")
	Local nAltLocal := 0
	Local aCampos   := {}
	Local nY        := 0
	Store 0 To nLinha,nX,nQtdDisp,npgQtd,npgTot,nSaldoBF

	If IsIncallStack("FATA400") .or. IsIncallStack("AGRC010")
		//Carrega campos de tela

		//Atribui o valor dos campos CLIENTE como LoadValue para não "gatilhar" 
		//e nos campos LOJA como SetValue para buscar gatilhos
		oGridNPG:LoadValue("NPG_CLIORI", ADA->ADA_CODCLI)
		oGridNPG:LoadValue("NPG_CLIDES", ADA->ADA_CODCLI)
		oGridNPG:LoadValue( "NPG_LOJORI", ADA->ADA_LOJCLI )
		oGridNPG:LoadValue( "NPG_LOJDES", ADA->ADA_LOJCLI )
		oGridNPG:LoadValue( "NPG_CONDPG", ADA->ADA_CONDPG )
		oGridNPG:LoadValue( "NPG_DESCPG", Posicione( "SE4", 1, xFilial("SE4") + ADA->ADA_CONDPG, "E4_DESCRI" )  )
			
		//TVUSHU - Nome do cliente e nome fantasia
		AGRIFDBSEEK("SA1",ADA->ADA_CODCLI+ADA->ADA_LOJCLI,1,.f.)
		If SA1->(!Eof())
			oGridNPG:LoadValue( "NPG_NOMORI", SA1->A1_NOME )
			oGridNPG:LoadValue( "NPG_NOMDES", SA1->A1_NREDUZ )
		EndIf

		nAltLocal := AGRA890Local(oStruNPH, nAltLocal)

		AGRIFDBSEEK("ADB",ADA->ADA_NUMCTR,1,.F.)
		While ( !Eof() .And. xFilial("ADB") == ADB->ADB_FILIAL .And. ADA->ADA_NUMCTR == ADB->ADB_NUMCTR )
			If (ADB->(FieldGet(FieldPos("ADB_QUANT"))) - ADB->(FieldGet(FieldPos("ADB_QTDEMP"))) > 0)

				//Validação de Saldo do Lote
				validaSaldo( ADA->ADA_CODSAF, ADB->ADB_CODPRO, ADB->ADB_LOCAL, ADB->ADB_CULTRA, ADB->ADB_CATEG, ADB->ADB_PENE,; 
				             ADB->ADB_CTVAR, @nQtdDisp, @nSaldoBF )

				DbSelectArea("ADB")
				nLinha++
				oAux:SetNoInsertLine( .F. )
				If nLinha # 1
					oAux:AddLine()
				EndIf
				oAux:Goline(nLinha)

				If lAGR890P3 // Ponto de entrada para adicionar mais campos da tabela ADB na tab NPH
					aCampos := ExecBlock("AGR890P3",.F.,.F., aCampos)
					
					For nY := 1 To Len(aCampos) 
						FwFldPut(aCampos[nY][1][1],aCampos[nY][2][1])
					Next  
				Endif


				FwFldPut("NPH_CODPRO",ADB->ADB_CODPRO)
				FwFldPut("NPH_CODAC" ,FwFldGet("NPG_CODIGO"))
				FwFldPut("NPH_UM"	 ,ADB->ADB_UM)
				FwFldPut("NPH_PRCVEN",ADB->ADB_PRCVEN)
				FwFldPut("NPH_LOCAL" ,ADB->ADB_LOCAL,,,,.T.)
				FwFldPut("NPH_NUMCP" ,ADB->ADB_NUMCTR)
				FwFldPut("NPH_ITEMCP",ADB->ADB_ITEM)
				FwFldPut("NPH_ITEM",STRZERO(nLinha,3))
				oModel:SetValue( 'NPHDETAIL', 'NPH_QTDSLD', nQtdDisp )
				oModel:SetValue( 'NPHDETAIL', 'NPH_QTDEND', nSaldoBF )
				oModel:SetValue( 'NPHDETAIL', 'NPH_QUANT', ADB->ADB_QUANT-ADB->ADB_QTDEMP-ADB->ADB_QTDENT)
				oModel:SetValue( 'NPHDETAIL', 'NPH_TOTAL', (FwFldGet("NPH_QUANT")*(ADB->ADB_PRCVEN)))
				npgQtd += FwFldGet("NPH_QUANT")
				npgTot += (FwFldGet("NPH_QUANT")*(ADB->ADB_PRCVEN))
				AGRLOADVALUE(oGridNPH,{{'NPH_CULTRA',ADB->ADB_CULTRA},{'NPH_CTVAR',ADB->ADB_CTVAR},{'NPH_CATEG',ADB->ADB_CATEG},;
				{'NPH_PENE',ADB->ADB_PENE},{'NPH_SEGUM',ADB->ADB_SEGUM},;
				{'NPH_DESCPR',POSICIONE("SB1",1,xFilial("SB1")+ADB->ADB_CODPRO,"B1_DESC")},;
				{'NPH_QTD2UM',ConvUm(ADB->ADB_CODPRO,FwFldGet("NPH_QUANT"),FwFldGet("NPH_QTD2UM"),2)}})
				nQtdDisp := 0
			EndIf
			AGRDBSELSKIP("ADB")
		EndDo
		oAux:Goline(1)
		AGRSETVALUE(oGridNPG,{{'NPG_QTDTOT',npgQtd},{'NPG_VLRTOT',npgTot}})
		
		AGRA890Local(oStruNPH, nAltLocal)

	ElseIf nOperation == MODEL_OPERATION_UPDATE

		AGRIFDBSEEK("ADA",FwFldGet("NPH_NUMCP"),1,.F.)
		For nX := 1 To oAux:Length()
			oAux:Goline(nX)

			//Validação de Saldo do Lote
			validaSaldo( ADA->ADA_CODSAF, FwFldGet('NPH_CODPRO'), FwFldGet("NPH_LOCAL"), FwFldGet("NPH_CULTRA"), FwFldGet("NPH_CATEG"),; 
			             FwFldGet("NPH_PENE"), FwFldGet("NPH_CTVAR"), @nQtdDisp, @nSaldoBF )

			oModel:SetValue( 'NPHDETAIL', 'NPH_QTDSLD', nQtdDisp )
			oModel:SetValue( 'NPHDETAIL', 'NPH_QTDEND', nSaldoBF )
			oModel:SetValue( 'NPHDETAIL', 'NPH_TOTAL', (FwFldGet("NPH_QUANT") * FwFldGet("NPH_PRCVEN")))
		Next nX
		oAux:Goline(1)

	ElseIf nOperation == MODEL_OPERATION_DELETE
		If NPG->NPG_STATUS $ "2|4|5|6"
			lRet := .F.
			Help("  ",1,"AGRA890AC")
		EndIf

	ElseIf nOperation == MODEL_OPERATION_VIEW
		AGRIFDBSEEK("ADA",FwFldGet("NPH_NUMCP"),1,.F.)
		For nX := 1 To oAux:Length()
				oAux:Goline(nX)
				
				//Validação de Saldo do Lote
				validaSaldo( ADA->ADA_CODSAF, FwFldGet('NPH_CODPRO'), FwFldGet("NPH_LOCAL"), FwFldGet("NPH_CULTRA"), FwFldGet("NPH_CATEG"),; 
				             FwFldGet("NPH_PENE"), FwFldGet("NPH_CTVAR"), @nQtdDisp, @nSaldoBF )
				
				oModel:LoadValue( 'NPHDETAIL', 'NPH_QTDSLD', nQtdDisp )
				oModel:LoadValue( 'NPHDETAIL', 'NPH_QTDEND', nSaldoBF )
				oModel:LoadValue( 'NPHDETAIL', 'NPH_TOTAL', (FwFldGet("NPH_QUANT") * FwFldGet("NPH_PRCVEN")))
			Next nX
			oAux:Goline(1)
	EndIf
	oAux:SetNoInsertLine( .T. )
Return(lRet)

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA890INC
Executa a operação de inclusão do model
@author: Aecio Ferreira Gomes
@since: 20/02/2013
@Uso: FATA400
/*/
// -------------------------------------------------------------------------------------
Function AGRA890INC(cContrato)
	AGRIFDBSEEK("ADA",cContrato,1,.F.)
	FWExecView(STR0005,'AGRA890', MODEL_OPERATION_INSERT,,{ || .T. })
Return

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA890GRV
Validação da linha da Grid
@author: Aecio Ferreira Gomes
@since: 20/02/2013
@Uso: AGRA890
/*/
// -------------------------------------------------------------------------------------
Static Function AGRA890GRV(oModel)
	Local nX,npgTot,npgQtd,lRet := .T.
	Local oAux		:= oModel:GetModel("NPHDETAIL")
	local aArea		:= GetArea()
	Local nOperac	:= oAux:GetOperation()
	Local cContrato	:= ""
	Local cMensagem  := ""
	Local nTipoMsg	:= 0 //0 - Nenhuma, 2 - ApMsgInfo, 1 - MSGYESNO 
		
	Store 0 To nX,npgTot,npgQtd

	//TODO ajuste de obrigatoriedade
	if lObgLocal
		oModel:GetModel("NPHDETAIL"):GetStruct():SetProperty('NPH_LOCAL', MODEL_FIELD_OBRIGAT,.T.)
		/* A alteração funciona, porém, nessa etapa, o model não identifica mais alteração, 
		 * então, vai passar. Fazer um teste, definir a função POSMODELO e alterar o obrigatório lá.
		 * Caso contrário, usar a variável lObgLocal pra definir se deve verificar se a informação de 
		 * local está preenchido ou não
		 */
	endif

	DbSelectArea("NPH")
	Begin Transaction
		For nX := 1 To oAux:Length()

			oAux:Goline(nX)
			npgQtd += FwFldGet("NPH_QUANT")
			npgTot += FwFldGet("NPH_QUANT")*FwFldGet("NPH_PRCVEN")

			// Validação de Todos os LOCAIS preenchidos 
			if !oAux:IsDeleted() .And. lObgLocal .And. Empty(FwFldGet("NPH_LOCAL"))
				//Campo locais preenchido Não
				//Verifique o preenchimento do campo local

				oModel:getModel():SetErrorMessage(oModel:GetId(),,oModel:GetId(),"","",STR0070,STR0071,"","") 

				DisarmTransaction()
				lRet := .F.
			EndIf

			AGRIFDBSEEK("NPH",FwFldGet("NPH_CODAC")+FwFldGet("NPH_ITEM"),1,.F.)

			If AGRIFDBSEEK("ADB",FwFldGet("NPH_NUMCP")+FwFldGet("NPH_ITEMCP"),1,.F.) // Valida os dados do contrato
				Do Case
					Case nOperac == MODEL_OPERATION_INSERT // Inclusão

					If !oAux:IsDeleted()
						IF  (FwFldGet("NPH_QUANT") > (ADB->ADB_QUANT-ADB->ADB_QTDEMP-ADB->ADB_QTDENT))
							cMensagem +=  AllTrim(FwFldGet("NPH_CODPRO"))+" - "+ AllTrim(POSICIONE("SB1", 1, xFilial("SB1") + FwFldGet("NPH_CODPRO"), "B1_DESC"));
										  +Chr(13)+STR0015+Chr(13)+ STR0020+":"+CVALTOCHAR(nX)+ " "+STR0013 + Chr(13)
										  
							IIf(nTipoMsg < 2, nTipoMsg := 2,)
										  
							lRet := .F.
						ElseIf	 (FwFldGet("NPH_QUANT")) > FwFldGet("NPH_QTDSLD")
							
							cMensagem += AllTrim(FwFldGet("NPH_CODPRO"))+" - "+ AllTrim(POSICIONE("SB1", 1, xFilial("SB1") + FwFldGet("NPH_CODPRO"), "B1_DESC"));
									     +Chr(13)+STR0014 +Chr(13)+ STR0020+":"+CVALTOCHAR(nX)+ " "+ STR0013 + Chr(13)
							
							IIf(nTipoMsg < 1, nTipoMsg := 1,)
							
						EndIf
						//cria saldo da autorização
						oModel:SetValue( 'NPHDETAIL', 'NPH_QTDDIS', FwFldGet("NPH_QUANT") )
						//Bloco Soma Empenho de Contrato
						//TODO Otimizar a rotina para se utilizar apenas de Model
						If RecLock('ADB',.f.) .and. lRet
							ADB->ADB_QTDEMP := ADB->ADB_QTDEMP + FwFldGet("NPH_QUANT")
							MsUnlock()
						Endif
					EndIf
					cContrato := ADB->ADB_NUMCTR

					Case nOperac == MODEL_OPERATION_UPDATE // Alteração
					If !oAux:IsDeleted()
						If FwFldGet("NPG_STATUS") = '8'		// CASO SEJA PARCIALMENTE ATENDIDA
							If (FwFldGet("NPH_QUANT") = NPH->NPH_QUANT - NPH->NPH_QTDDIS)
								//TODO Otimizar a rotina para se utilizar apenas de Model
								If RecLock('ADB',.f.)
									ADB->ADB_QTDEMP := ADB->ADB_QTDEMP - FwFldGet("NPH_QTDDIS")
									MsUnlock()
								Endif
								//Zerar Saldo Disponivel e finalizar Autorização de Carregamento
								oModel:SetValue( 'NPHDETAIL', 'NPH_QTDDIS',  0  )
								AGRIFDBSEEK("NPM",NPG->NPG_CODIGO,3,.F.)
								do case
									case NPM->NPM_STATUS = '2'
									oModel:SetValue( 'NPGMASTER', 'NPG_STATUS', '5' )
									case NPM->NPM_STATUS = '3'
									oModel:SetValue( 'NPGMASTER', 'NPG_STATUS', '6' )
									case NPM->NPM_STATUS = '4'
									oModel:SetValue( 'NPGMASTER', 'NPG_STATUS', '7' )
								end
							Else
								
								cMensagem += AllTrim(FwFldGet("NPH_CODPRO")) + " - " + AllTrim(POSICIONE("SB1", 1, xFilial("SB1") + FwFldGet("NPH_CODPRO"), "B1_DESC"));
								+ Chr(13)+STR0062 + Chr(13) + STR0020 + ":" + CVALTOCHAR(nX)+ " "+STR0013 + Chr(13)
								 
								IIf(nTipoMsg < 2, nTipoMsg := 2,)
								
								lRet := .F.
							EndIf
						Else
							If FwFldGet("NPH_QUANT") > ADB->ADB_QUANT .OR. (FwFldGet("NPH_QUANT") - NPH->NPH_QUANT) > (ADB->ADB_QUANT - ADB->ADB_QTDEMP )
								
								cMensagem +=   AllTrim(FwFldGet("NPH_CODPRO")) + " - " + AllTrim(POSICIONE("SB1", 1, xFilial("SB1") + FwFldGet("NPH_CODPRO"), "B1_DESC"));
								+ Chr(13)+STR0015 + Chr(13) + STR0020 + ":" + CVALTOCHAR(nX)+ " "+STR0013 + Chr(13)
								
								
								IIf(nTipoMsg < 2, nTipoMsg := 2,)
								
								
								lRet := .F.
							ElseIf	 (FwFldGet("NPH_QUANT") ) > FwFldGet("NPH_QTDSLD")
								
								cMensagem +=    AllTrim(FwFldGet("NPH_CODPRO")) + " - " + AllTrim(POSICIONE("SB1", 1, xFilial("SB1") + FwFldGet("NPH_CODPRO"), "B1_DESC"));
								+ Chr(13)+ STR0014 + Chr(13) + STR0020 + ":" + CVALTOCHAR(nX) + " " + STR0013 + Chr(13)
								
								IIf(nTipoMsg < 1, nTipoMsg := 1,)
							EndIf

							If RecLock('ADB',.f.) .and. lRet
								ADB->ADB_QTDEMP := (ADB->ADB_QTDEMP - NPH->NPH_QUANT) + FwFldGet("NPH_QUANT")
								oModel:SetValue( 'NPHDETAIL', 'NPH_QTDDIS',  FwFldGet("NPH_QUANT")  )
								MsUnlock()
							Endif
						EndIf
					Else
						If RecLock('ADB',.f.) .and. lRet
							ADB->ADB_QTDEMP := ADB->ADB_QTDEMP - FwFldGet("NPH_QUANT")
							MsUnlock()
						Endif
					Endif
					cContrato := ADB->ADB_NUMCTR

					Case nOperac == MODEL_OPERATION_DELETE // Exclusão

					AGRIFDBSEEK("ADA",ADB->ADB_NUMCTR,1,.F.) // Atualiza Status do Contrato de Parceria
					cContrato := ADB->ADB_NUMCTR
				EndCase
			EndIf
		Next nX
		
		If nTipoMsg = 2
			ApMsgInfo(cMensagem, STR0013 , STR0013)
		ElseIf nTipoMsg = 1
			If MSGYESNO( cMensagem + Chr(13) + STR0035,STR0036,"YESNO" )
			Else
				lRet := .F.
			EndIf
		EndIf
		
		If !lRet
			oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", STR0068, STR0072, ;
			STR0073, "", "")
			DisarmTransaction()
		EndIf
		
		If lRet
			If nOperac # MODEL_OPERATION_DELETE
				oModel:SetValue( 'NPGMASTER', 'NPG_QTDTOT', npgQtd )
				oModel:SetValue( 'NPGMASTER', 'NPG_VLRTOT', npgTot )
			EndIf
	
			AGRIFDBSEEK("ADA",cContrato,1,.F.) // Atualiza Status do Contrato de Parceria
			Ft400StatCt()
			
			If ValType("vVetTRB") = "A" .And. vVetTRB[1] <> Nil
				AGRCOMGHIST(vVetTRB,"NPG")
			EndIf
			FwFormCommit(oModel)
		Endif
	End Transaction
	RestArea(aArea)
Return lRet

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGR890STAT()
Retorna o Status da Autorização de Carregamento
@author: Aecio Ferreira Gomes
@since:  25/02/2013
@Uso: 	 AGRA890
/*/
// -------------------------------------------------------------------------------------
Function AGR890STAT(cAutoriza)
Return (Posicione("NPG",1,xFilial("NPG") + cAutoriza,"NPG_STATUS"))

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA890Tip()
Ajustes na mascara do campo NPG_CPF
@author: Tiago Filipe
@since:  30/05/2014
@Uso: 	 AGRA890
/*/
// -------------------------------------------------------------------------------------
Function AGRA890Tip()
Return If(!Empty(M->NPG_CPF) .And. Len(AllTrim(M->NPG_CPF)) < 14,"@R 999.999.999-99999%C","@R 99.999.999/9999-99%C")

//--------------------------------------------------------------------------------------------
/*/{Protheus.doc} Libera edição dos campos para autorização()
Verifica se os campos já estão preenchidos  ou não para liberar edição
@author: Maicol Lange
@since: 04/12/2014
@Uso: AGRA890
/*/
//--------------------------------------------------------------------------------------------
Static function ValidCtro(cCampo)
Return If(Empty(Alltrim(AGRSEEKDIC("ADB",xfilial("ADB")+FwFldGet("NPH_NUMCP")+FwFldGet("NPH_ITEMCP"),1,cCampo))),.t.,.f.)

//--------------------------------------------------------------------------------------------
/*/{Protheus.doc}  AGR890APR()
Libera a autorização para uso.
@author: Maicol Lange
@since.: 27/01/2015
@Uso...: AGRA890
/*/
//--------------------------------------------------------------------------------------------
Function AGR890APR()
	Local lRet := .t.
    Local oView := AGR890IMD()

	oView:Refresh()
	If NPG->NPG_STATUS $ "1"
		If NPG->( MsRLock() )
			If EXISTBLOCK ("AGR890P1")
				lRet := ExecBlock("AGR890P1",.F.,.F.)
			Endif
			If lRet
				If AGRGRAVAHIS(STR0022,"NPG",xFilial("NPG")+NPG->NPG_CODIGO,"A") = 1
					If RecLock("NPG",.F.)
						NPG->NPG_STATUS := "2"	// Aprovado
						NPG->(MsUnLock())
					Endif
				EndIf
			EndIf
			NPG->(MsRUnLock())
		Else
			MSGINFO(STR0022)//'Registro em uso no momento, favor repetir ação em seguida!'
			Return
		Endif
	Else
		If NPG->NPG_STATUS $ "2|3|4|5|6"
			MSGINFO(STR0028)	//"Status não permitido para aprovação."
			Return
		EndIf
	EndIf
Return

//--------------------------------------------------------------------------------------------
/*/{Protheus.doc}  AGR890CAN()
Cancela a autorização
@author: Ana Laura Olegini
@since.: 04/02/2015
@Uso...: AGRA890
/*/
//--------------------------------------------------------------------------------------------
Function AGR890CAN()
	Local cContrato := ""
	Local lrec 		:= .F.
	Local oView := AGR890IMD()

	oView:Refresh()
	If NPG->NPG_STATUS $ "1|2"
		//trava rotina para executar baixa segura de saldo do contrato, nesse momento nao pode haver outra interação no registro
		If NPG->( MsRLock() )
			If AGRGRAVAHIS(STR0023,"NPG",xFilial("NPG")+NPG->NPG_CODIGO,"C") = 1
				If RecLock("NPG",.F.)
					NPG->NPG_STATUS := "3"	// Cancelada
					NPG->(MsUnLock())
					lRec := .T.
				Endif
			EndIf
			/*	Quando houver cancelamento voltar o saldo
			Tabela de Itens de Autorização de Carregamento 		*/

			DBSelectArea("NPH")
			DBSetOrder(1)
			If DBSeek(xFilial("NPH")+NPG->NPG_CODIGO) .and. lRec
				WHILE NPH->(!Eof() .And. NPH_FILIAL + NPH_CODAC== xFilial( "NPG" ) + NPG->NPG_CODIGO)
					cContrato := NPH->NPH_NUMCP
					//Tabela de Contratos
					DBSelectArea("ADB")
					DBSetOrder(1)
					If DBSeek(xFilial("ADB") + NPH->NPH_NUMCP + NPH->NPH_ITEMCP)
						If RecLock("ADB",.F.)
							ADB->ADB_QTDEMP	:= ADB->ADB_QTDEMP-NPH->NPH_QUANT
							MsUnlock()
						Endif
					EndIf
					DBSelectArea("NPH")
					NPH->(dbSkip())
				ENDDO
			EndIf
			AGRIFDBSEEK("ADA",cContrato,1,.F.) // Atualiza Status do Contrato de Parceria
			Ft400StatCt()
			NPG->(MsRUnLock())
		Else
			MSGINFO(STR0022)//'Registro em uso no momento, favor repetir ação em seguida!'
			Return
		Endif
	Else
		If NPG->NPG_STATUS $ "3|4|5|6"
			MSGINFO(STR0031) //"Status não permitido para cancelamento."
		EndIf
	EndIf
	Return

//--------------------------------------------------------------------------------------------
/*/{Protheus.doc}  AGR890HIS()  -- OBS: DESABILITADO REVISAO DA TABELA NKU PARA A NK9
Mostra em tela o Historico de aprovações e rejeições
@author: Ana Laura Olegini
@since.: 04/02/2015
@Uso...: AGRA890
/*/
//--------------------------------------------------------------------------------------------
Function AGR890HIS()
	Local cChaveI := "NPG->("+Alltrim(AGRSEEKDIC("SIX","NPG1",1,"CHAVE"))+")"
	Local cChaveA := &(cChaveI)+Space(Len(NK9->NK9_CHAVE)-Len(&cChaveI))
	AGRHISTTABE("NPG",cChaveA)
Return

//--------------------------------------------------------------------------------------------
/*/{Protheus.doc}  AGR890F4
Consulta de saldo do produto F4
@param.: oModel
@author: Ana Laura Olegini
@since.: 16/02/2015
@Uso...: AGRA890
/*/
//--------------------------------------------------------------------------------------------
Static Function AGR890F4()
	Local oMdl		 := FwModelActive()
	Local oGrdNPH	 := oMdl:GetModel("NPHDETAIL")
	Local nLinNPH	 := oGrdNPH:GetLine()

	oGrdNPH:GoLine(nLinNPH)
	cLocal := oMdl:getModel("NPHDETAIL"):GetValue("NPH_LOCAL")
	cCultr := oMdl:getModel("NPHDETAIL"):GetValue("NPH_CULTRA")
	cCtvar := oMdl:getModel("NPHDETAIL"):GetValue("NPH_CTVAR")
	cCateg := oMdl:getModel("NPHDETAIL"):GetValue("NPH_CATEG")
	cPene  := oMdl:getModel("NPHDETAIL"):GetValue("NPH_PENE")
	cCodPr := oMdl:getModel("NPHDETAIL"):GetValue("NPH_CODPRO")

	If "M->NPH_" $ ReadVar()
		If ReadVar() = "M->NPH_QUANT"
			MaViewSB2(cCodPr)
		Else
			AGR890LF4(cCodPr,cLocal,cCultr,cCtvar,cCateg,cPene)
		EndIf
	EndIf
Return Nil

/*
############################################################################
# Função   : AGR890LF                                                      #
# Descrição: Consulta saldo por lote                                       #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 09/09/2014                                                    #
############################################################################
*/
Function AGR890LF4(cCod,cLocal,cCultra,cCtvar,cCateg,cPene)
	Local nIndice,cChaveA,lRastroS := If(Rastro(cCod,"S"),.t.,.f.)
	Local cQuery ,cIndice := "",aIndex := {"NP9_LOTE"}
	local nx,ny,nSaldoL,nSaldoBF
	Local CodSaf		:= AGRSEEKDIC("ADA",xfilial("ADA")+FwFldGet("NPH_NUMCP"),1,"ADA_CODSAF")
	Local aSeek := {},aColumns	:= {}
	Local lEmpPrev	:= If(SuperGetMV("MV_QTDPREV") = "S",.T.,.F.)

	cQuery := " AND NP9_PROD ='"+cCod+"' AND NP9_CODSAF ='"+CodSaf+"' "
	cQuery += if(!empty(cCultra), "	AND NP9_CULTRA='"+cCultra+"' ","")
	cQuery += if(!empty(cCtvar), "	AND NP9_CTVAR='"+cCtvar+"' ","")
	cQuery += if(!empty(cPene), "	AND NP9_PENE 	='"+cPene+"' ","")
	cQuery += if(!empty(cCateg),"	AND NP9_CATEG='"+cCateg+"' ","")
	cQuery += if(!empty(cLocal),"	AND B8_LOCAL='"+cLocal+"' ","")
	cQuery += " AND NP9_STATUS  = '2'"
	cQuery := "% " + cQuery + " %"

	BeginSQL Alias "NP9TEMP"
	COLUMN B8_DTVALID AS DATE
	SELECT NP9.NP9_PROD,NP9.NP9_LOTE,NP9.NP9_TRATO,	NP9.NP9_TIPLOT,NP9.NP9_EMB,NP9.NP9_2UM,	NP9.NP9_CULTRA,
	NP9.NP9_CTVAR,NP9.NP9_CATEG,NP9.NP9_PENE,SB8.B8_DTVALID,SBF.BF_LOCALIZ,SB8.B8_LOCAL,SBF.BF_NUMLOTE
	FROM %Table:SB8% SB8
	INNER JOIN %table:NP9% NP9 ON NP9.%notDel%
	AND NP9.NP9_FILIAL = %xFilial:NP9%  AND  NP9.NP9_LOTE = SB8.B8_LOTECTL AND NP9.NP9_PROD = SB8.B8_PRODUTO
	LEFT JOIN %table:SBF% SBF ON
	SBF.%notDel%	AND
	SBF.BF_FILIAL = %xFilial:SBF%	AND SBF.BF_LOCAL = SB8.B8_LOCAL	AND SBF.BF_PRODUTO	= %exp:cCod%	AND
	SBF.BF_LOTECTL = NP9.NP9_LOTE
	WHERE
	SB8.B8_FILIAL=%xFilial:SB8% %exp:cQuery% AND SB8.%NotDel%
	EndSQL

	//Cria estrutura de arquivo temporario
	aCamTRB :=	{{"NP9_LOTE"},{"B8_LOCAL"},{"BF_LOCALIZ"},{"NP9_CULTRA"},{"NP9_CTVAR"},{"NP9_CATEG"},{"NP9_PENE"},{"NP9_2UM"},;
	{"B8_DTVALID"},{"B8_SALDO",TamSX3("B8_SALDO")[3],TamSX3("B8_SALDO")[1],TamSX3("B8_SALDO")[2],AGRTITULO("B8_SALDO"),PesqPict("SB8","B8_SALDO")},;
	{"BF_QUANT",TamSX3("BF_QUANT")[3],TamSX3("BF_QUANT")[1],TamSX3("BF_QUANT")[2],"Saldo Endereco",PesqPict("SBF","BF_QUANT")},;
	{"NP9_TIPLOT",TamSX3("NP9_TIPLOT")[3],TamSX3("NP9_TIPLOT")[1],TamSX3("NP9_TIPLOT")[2],AGRTITULO("NP9_TIPLOT"),PesqPict("NP9","NP9_TIPLOT")},;
	{"NP9_TRATO",TamSX3("NP9_TRATO")[3],TamSX3("NP9_TRATO")[1],TamSX3("NP9_TRATO")[2],AGRTITULO("NP9_TRATO"),PesqPict("NP9","NP9_TRATO")},;
	{"NP9_EMB",TamSX3("NP9_EMB")[3],TamSX3("NP9_EMB")[1],TamSX3("NP9_EMB")[2],AGRTITULO("NP9_EMB"),PesqPict("NP9","NP9_EMB")}}

	aRet := AGRCRIATRB(,aCamTRB,aIndex,FunName(),.t.)
	cNomeTRB := aRet[3] //Nome do arquivo temporário
	cAliTRBL := aRet[4] //Nome do alias do arquivo temporario
	aArqTemp := aRet[5] //Matriz com a estrutura do arquivo temporario + label e picutre

	ARGSETIFARQUI("NP9TEMP") //Carrega os dados para o arquivo temporario
	While !Eof()
		nIndice := If(lRastroS,2,3)
		cChaveA := If(lRastroS,("NP9TEMP")->BF_NUMLOTE+("NP9TEMP")->NP9_LOTE+cCod+("NP9TEMP")->B8_LOCAL,cCod+("NP9TEMP")->B8_LOCAL+("NP9TEMP")->NP9_LOTE)
		If AGRIFDBSEEK("SB8",cChaveA,nIndice,.f.)
			nSaldoL  := SB8Saldo(.F.,!Empty(("NP9TEMP")->NP9_LOTE),NIL,NIL,NIL,lEmpPrev,NIL,ddatabase,)
			nSaldoBF := SaldoSBF(("NP9TEMP")->B8_LOCAL,("NP9TEMP")->BF_LOCALIZ,("NP9TEMP")->NP9_PROD,NIL,("NP9TEMP")->NP9_LOTE,NIL,.F.,NIL,.T.)
			If !Empty(nSaldoL)
				AGRGRAVA2T(cAliTRBL,"NP9TEMP")
				(cAliTRBL)->NP9_TRATO 	:=	AGRRETSX3BOX("NP9_TRATO"	,("NP9TEMP")->NP9_TRATO)
				(cAliTRBL)->NP9_TIPLOT 	:=	AGRRETSX3BOX("NP9_TIPLOT"	,("NP9TEMP")->NP9_TIPLOT)
				(cAliTRBL)->NP9_EMB 	:=	AGRRETSX3BOX("NP9_EMB"		,("NP9TEMP")->NP9_EMB)
				(cAliTRBL)->B8_SALDO 	:=	nSaldoL
				(cAliTRBL)->BF_QUANT	:=	nSaldoBF
			EndIf
		EndIf
		AGRDBSELSKIP("NP9TEMP")
	End

	For nx := 1 To Len(aIndex) // monta a estruta para index
		cIndice := aIndex[nx]
		cIndice := StrTran(cIndice," ","")
		cIndice := StrTran(cIndice,"Dtos(","")
		cIndice := StrTran(cIndice,"Descend(","")
		cIndice := StrTran(cIndice,")","")
		cDescIn := Space(1)
		vVetInT := {}
		While !Empty(cIndice)
			nPos := At("+",cIndice)
			cCam := If(nPos > 0,Alltrim(SubStr(cIndice,1,nPos-1)),Alltrim(SubStr(cIndice,1,Len(cIndice))))
			Aadd(vVetInT,cCam)
			cIndice := StrTran(cIndice,If(nPos > 0,cCam+"+",cCam),"")
		End
		cTamInd := 0
		For ny := 1 To Len(vVetInT)
			nPos1 := Ascan(aArqTemp,{|x| Alltrim(x[1]) == Alltrim(vVetInT[ny])})
			If nPos1 > 0
				cDescIn += Alltrim(aArqTemp[nPos1,5])+If(ny < len(vVetInT)," + ","")
				cTamInd += aArqTemp[nPos1,3]
			EndIf
		Next ny
		Aadd(aSeek,{cDescIn,{{"","C",cTamInd,0,' ',,}}})
	Next nx

	DEFINE MSDIALOG oDlgX TITLE "Consulta de Lote de semente" FROM 00,00 TO 500,1000 PIXEL OF oMainWnd
	DEFINE FONT oBold NAME "Arial" SIZE 0,-12 BOLD
	// Instancia o layer
	oFWL1 := FWLayer():New()
	// Inicia o Layer
	oFWL1:init( oDlgX,.F.)
	// Cria uma linha unica para o Layer
	oFWL1:addLine( 'SUP', 10 , .F.)
	oFWL1:addLine( 'INF', 90 , .F.)
	// Cria colunas
	oFWL1:addCollumn('ESQ',100,.T.,'SUP' )
	oPnlLine1 := oFWL1:getLinePanel('INF')
	oPnDir    := oFWL1:getColPanel('ESQ','SUP')

	@ 004,010 SAY SM0->M0_CODIGO+"/"+Alltrim(FWCodFil())+" - "+Alltrim(SM0->M0_FILIAL)+"/"+SM0->M0_NOME Of oPnDir PIXEL SIZE 245,009
	@ 014,010 SAY Alltrim(cCod)+ " - "+POSICIONE("SB1",1,xFilial("SB1")+cCod,"B1_DESC")                 Of oPnDir PIXEL SIZE 245,009 FONT oBold

	For nx := 1 To Len(aArqTemp)
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[nx]:SetData(&("{||"+aArqTemp[nx,1]+"}"))
		aColumns[nx]:SetTitle(Alltrim(aArqTemp[nx,5]))
		aColumns[nx]:SetPicture(Alltrim(aArqTemp[nx,6]))
		aColumns[nx]:SetType(Alltrim(aArqTemp[nx,2]))
		aColumns[nx]:SetSize(aArqTemp[nx,3])
		aColumns[nx]:SetReadVar(aArqTemp[nx,1])
	Next nx

	DEFINE FWFORMBROWSE oBrowsX DATA TABLE ALIAS cAliTRBL OF oPnlLine1
	oBrowsX:SetTemporary(.T.)
	oBrowsX:SetFieldFilter(AGRITEMCBRW(aArqTemp))
	oBrowsX:SetColumns(aColumns)
	oBrowsX:SetDBFFilter(.T.)
	oBrowsX:SetUseFilter(.T.)
	oBrowsX:DisableDetails(.F.)
	oBrowsX:SetSeek(,aSeek)
	oBrowsX:AddButton("Sair",{|| oDlgX:end()},,9,0)
	ACTIVATE FWFORMBROWSE oBrowsX
	ACTIVATE MSDIALOG oDlgX CENTER
	AGRDELETRB(cAliTRBL,cNomeTRB)
	ARGCLOSEAREA("NP9TEMP")
	DbSelectArea("NPH")
Return .T.

/*
+=================================================================================================+
| Programa  : AGRA890IM                                                                           |
| Descrição : Impressão da autorização                                                            |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 29/06/2015                                                                          |
+=================================================================================================+
*/
Function AGRA890IM()
	Private wnrel,cDesc1,cDesc2,cDesc3,Cabec1,Cabec2,cRodaTxt,cPerg := ""
	Private titulo	 := Oemtoansi(STR0001)+"  -  "+AGRRETSX3BOX("NPG_STATUS",NPG->NPG_STATUS)
	Private nCntImpr := 0,nTipo	:= 15,li := 80,m_pag := 1,nSomQtd := 0
	Private aReturn  := {STR0037,1,STR0038,1,2,1,"",1}
	Private NomeProg := "AGRA890IM"
	Private cString  := "NPG"
	Private Tamanho  := "M"

	Store Space(1) To cDesc1,cDesc2,cDesc3,Cabec1,Cabec2,cRodaTxt

	If !NPG->NPG_STATUS $ "3"
		wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,.F.,.F.,Tamanho,,.T.)
		SetDefault(aReturn,cString)
		RptStatus({|lEnd|AGR890PRIM(@lEnd,wnRel,cString,Tamanho,NomeProg)},titulo)
	Else
		MsgInfo(STR0039)
		Return
	EndIf
Return

/*
+=================================================================================================+
| Programa  : AGRA890PRIM                                                                         |
| Descrição : Processa a impressão                                                                |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 29/06/2015                                                                          |
+=================================================================================================+
*/
Static Function AGR890PRIM(lEnd,WnRel,cString,Tamanho,NomeProg)
	Local nx

	AGRA890CAB()
	If AGRIFDBSEEK("NPH",NPG->NPG_CODIGO,1,.F.)
		While !Eof() .And. NPH->NPH_FILIAL = Xfilial("NPH") .And. NPH->NPH_CODAC = NPG->NPG_CODIGO
			If li > 60
				AGRA890CAB()
			EndIf
			@ li,001 PSay SubStr(Posicione("SB1",1,xFilial("SB1")+NPH->NPH_CODPRO,"B1_DESC"),1,30)
			@ li,034 PSay SubStr(Posicione("NP4",1,xFilial("NP4")+NPH->NPH_CTVAR,"NP4_DESCRI"),1,25)
			@ li,060 PSay NPH->NPH_UM    Picture "@!"
			@ li,066 PSay SubStr(IIF(Empty(NPH->NPH_CATEG),"",Posicione("SX5",1,xFilial("SX5")+"K1"+NPH->NPH_CATEG,"X5DESCRI()")),1,20)
			@ li,088 PSay NPH->NPH_PENE  Picture "@!"
			@ li,092 PSay Transform(NPH->NPH_QUANT ,"@E 9,999,999,999.99")
			@ li,108 PSay Transform(NPH->NPH_PRCVEN,"@E 999,999,999.9999")
			@ li,125 PSay NPH->NPH_NUMCP Picture "@!"
			li ++
			nSomQtd += NPH->NPH_QUANT
			AGRDBSELSKIP("NPH")
		End
	EndIf
	If !Empty(nSomQtd)
		@ Li,000 PSay __PrtThinLine()
	EndIf

	li ++
	@ li,003 PSay STR0040
	If !Empty(nSomQtd)
		@ li,073 PSay STR0041
		@ li,090 PSay Transform(nSomQtd,"@E 999,999,999,999.99")
	EndIf

	li ++
	For nx := 1 TO MLCount( NPG->NPG_OBS )
		@ li,003 PSay MemoLine( NPG->NPG_OBS,120,nx )
		li ++
	Next nx

	li += 7
	@ li,020 PSay Alltrim(SM0->M0_CIDCOB)+"("+SM0->M0_ESTCOB+"), "+Str(Day(Date()),2)+STR0042+AllTrim(MesExtenso(Date()))+STR0042+Str(Year(Date()),4)

	li += 2
	@ li,070 PSay Replicate("_",45)

	li ++
	cTABEL := "NPG->("+Alltrim(AGRSEEKDIC("SIX","NPG1",1,"CHAVE"))+")"
	cCHAVE := &(cTABEL)+Space(Len(NK9->NK9_CHAVE)-Len(&cTABEL))
	@ li,085 PSay Alltrim(Posicione("NK9",1,xFilial("NK9")+"NPG"+cCHAVE,"NK9_NOMUSU"))

	Set Device to Screen
	If aReturn[5] = 1
		Set Printer To
		dbCommitAll()
		OurSpool(wnrel)
	Endif
	MS_FLUSH()
Return

/*
+=================================================================================================+
| Programa  : AGRA890CAB                                                                          |
| Descrição : Cabeça~ho da impressão                                                              |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 29/06/2015                                                                          |
+=================================================================================================+
*/
Static Function AGRA890CAB()
	If Li > 60
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
		@ li,003 PSay STR0043
		@ li,012 PSay STR0044
		@ li,052 PSay STR0045
		@ li,092 PSay STR0046
		@ li,110 PSay STR0024
		li ++
		AGRIFDBSEEK("NPH",NPG->NPG_CODIGO,1,.F.)
		AGRIFDBSEEK("ADA",NPH->NPH_NUMCP,1,.F.)
		@ li,003 PSay Alltrim(ADA->ADA_CODSAF)						Picture "@!"
		@ li,012 PSay SubStr(Alltrim(SM0->M0_NOMECOM),1,40) 	Picture "@!"
		@ li,052 PSay SubStr(Alltrim(SM0->M0_FILIAL),1,40)  	Picture "@!"
		@ li,092 PSay Alltrim(NPG->NPG_CODIGO)			    		Picture "@!"
		@ li,110 PSay NPG->NPG_DTAUTO

		li ++
		@ Li,000 PSay __PrtThinLine()
		li ++

		AGRIFDBSEEK("SA1",NPG->NPG_CLIORI + NPG->NPG_lOJORI,1,.F.)
		AGRIFDBSEEK("SA4",NPG->NPG_TRANSP,1,.F.)
		@ li,003 PSay STR0047+SubStr(SA1->A1_NOME,1,48)
		@ li,070 PSay STR0048+SubStr(SA4->A4_NOME,1,48)

		li ++
		@ li,003 PSay STR0049+".........: "+SubStr(SA1->A1_NOME,1,48)
		@ li,070 PSay STR0050+"......: "+If(Len(Alltrim(SA1->A1_CGC)) < 14,SubSTr(SA1->A1_CGC,1,9)+"-"+SubSTr(SA1->A1_CGC,10,2),;
		SubSTr(SA1->A1_CGC,1,8)+"/"+SubSTr(SA1->A1_CGC,9,4)+"-"+SubSTr(SA1->A1_CGC,13,2))
		li ++
		@ li,003 PSay STR0050+".........: "+If(Len(Alltrim(SA1->A1_CGC)) < 14,SubSTr(SA4->A4_CGC,1,9)+"-"+SubSTr(SA4->A4_CGC,10,2),;
		SubSTr(SA4->A4_CGC,1,8)+"/"+SubSTr(SA4->A4_CGC,9,4)+"-"+SubSTr(SA4->A4_CGC,13,2))
		@ li,046 PSay "IE.: "+Alltrim(SA1->A1_INSCR)
		@ li,070 PSay STR0051+".....: "+Alltrim(SA4->A4_END)
		li ++

		@ li,003 PSay STR0051+"........: "+SA1->A1_END
		@ li,085 PSay Alltrim(SA4->A4_MUN)+" - "+SA4->A4_EST

		li ++
		@ li,021 PSay Alltrim(SA1->A1_MUN)+" - "+SA1->A1_EST
		@ li,046 PSay "B..: "+SA1->A1_BAIRRO

		li ++
		@ li,021 PSay "Tel.: "+ "(" + Alltrim(SA1->A1_DDD) + ") " + Alltrim(SA1->A1_TEL)
		@ li,046 PSay "CEP: "+SA1->A1_CEP
		AGRIFDBSEEK("DA3",NPG->NPG_PLACA,3,.F.)
		@ li,070 PSay STR0052+"........: "+If(!Empty(NPG->NPG_PLACA),NPG->NPG_PLACA+"  "+Alltrim(DA3->DA3_MUNPLA)+" - "+DA3->DA3_ESTPLA,"")
		li ++
		@ Li,000 PSay __PrtThinLine()

		li ++
		@ li,001 PSay STR0053
		@ li,034 PSay STR0054
		@ li,060 PSay STR0055
		@ li,066 PSay STR0056
		@ li,088 PSay STR0057
		@ li,098 PSay STR0058
		@ li,110 PSay STR0059
		@ li,125 PSay STR0060

		li ++
		@ Li,000 PSay __PrtThinLine()
		li ++
	EndIf
Return

/** {Protheus.doc} 7
Função que calcula o saldo do item do contrato
@param: 	cCtrPar  = Ctrato Parceria, cItemPar = Item do Ctrato de Parceria
@author: 	E Coelho  Refeito em 23/12/15 Inácio
@since: 	17/01/2015
@Uso: 		AgroIndustria
*/

Function Agr890QExp(cCtrPar,cItemPar)
	Local nSaldo := 0,ny
	If AGRIFDBSEEK("ADB",cCtrPar+cItemPar,1,.f.)
		aRetNPH := AGRBUSREGIS("NPH",xFilial("NPH")+ADB->ADB_NUMCTR+ADB->ADB_ITEM,2,.t.,.f.,;
		"NPH->NPH_FILIAL = XFILIAL('NPH') .And. NPH->NPH_NUMCP = '"+ADB->ADB_NUMCTR+"' .And. NPH->NPH_ITEMCP = '"+ADB->ADB_ITEM+"'",;
		{{"NPH_CODAC"},{"NPH_ITEM"}},,"M")
		For ny := 1 To Len(aRetNPH[2])
			vRetSoma := AGRSOMACAMP("NPN",aRetNPH[2,ny,1]+aRetNPH[2,ny,2],2,;
			"NPN->NPN_FILIAL = XFILIAL('NPN') .And. NPN->NPN_CODAC = '"+aRetNPH[2,ny,1]+"' .And. NPN->NPN_ITEMAC = '"+aRetNPH[2,ny,2]+"'",;
			{"NPN_QUANT"})
			nSaldo += vRetSoma[1]
		Next ny
		nSaldo := ADB->ADB_QUANT - nSaldo
	EndIf
Return nSaldo

/*
+=================================================================================================+
| Programa  : AGRADBVALD                                                                          |
| Descrição : Validação do cadastro do contrato de parceria com os campos de integração do SIGAAGR|
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 29/07/2015                                                                          |
+=================================================================================================+
*/
Function AGRADBVALD()
	Local lRet	   := .T.,cValorAtu := "",cValorDB := ""
	Local nCodPro  := aScan(aHeader,{|x| AllTrim(x[2]) == "ADB_CODPRO" })
	Local cCampoL  := Alltrim(SubStr(ReadVar(),4,Len(ReadVar())))
	Local cCampo   := cCampoL


	If AGRIFDBSEEK("SB5",aCols[n,nCodPro],1,.F.) .And. SB5->B5_SEMENTE = '1' // Valida se o produto é semente
		If ReadVar() $ "M->ADB_CULTRA"
			If !Empty(M->ADB_CULTRA) .AND. !ExistCpo("NP3",M->ADB_CULTRA)
				Return .f.
			EndIf
			cValorAtu := M->ADB_CULTRA
			cValorDB  := SB5->B5_CULTRA
		ElseIf ReadVar() $ "M->ADB_CTVAR"
			If !Empty(M->ADB_CTVAR) .AND. !ExistCpo("NP4",M->ADB_CTVAR)
				Return .f.
			EndIf
			cValorAtu := M->ADB_CTVAR
			cValorDB  := SB5->B5_CTVAR
		ElseIf ReadVar() $ "M->ADB_CATEG"
			If !Empty(M->ADB_CATEG) .AND. !ExistCpo('SX5','K1'+M->ADB_CATEG)
				Return .f.
			EndIf
			cValorAtu := M->ADB_CATEG
			cValorDB  := SB5->B5_CATEG
		ElseIf ReadVar() $ "M->ADB_PENE"
			If !Empty(M->ADB_PENE) .AND. !ExistCpo("NP7",M->ADB_PENE)
				Return .f.
			EndIf
			cValorAtu := M->ADB_PENE
			cValorDB  := SB5->B5_PENE
		EndIf

		If Empty(cValorAtu)
			Help(,1,"HELP",,STR0063+" "+AGRTITULO(cCampo),1,0)
			lRet := .F.
		Else
			If !Empty(cValorAtu) .And. !Empty(cValorDB) .And. cValorAtu != cValorDB
				Help(,1,"HELP",,STR0064+" "+Alltrim(AGRSX2NOME("SB5"))+" -> "+AGRTITULO(cCampo),1,0)
				lRet := .F.
			EndIf
		EndIf
	EndIf
Return lRet

/*
+=================================================================================================+
| Programa  : AGRA890DTA                                                                          |
| Descrição : Validação da data da autorização                                                    |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 27/08/2015                                                                          |
+=================================================================================================+
*/
Function AGRA890DTA()
	Local oView := FWViewActive()
	If oView:GetOperation() = 4
		If AGRIFDBSEEK("NPM",FwFldGet("NPG_CODIGO"),3,.f.)
			Help(,1,"HELP",,STR0065+" "+Alltrim(AGRSX2NOME("NPM")),1,0)
			Return .F.
		EndIf
	EndIf
Return .t.


//--------------------------------------------------------------------------------------------
/*/{Protheus.doc}  AGR890IMD()
Instancia o Model que será usado na aprovação/Cancelamento.
@author: Marcelo R. Ferrari
@since.: 10/08/2016
@Uso...: AGRA890
/*/
//--------------------------------------------------------------------------------------------
Function AGR890IMD()
    Local oModel    := FwLoadModel( "AGRA890" )
    Public oView := Nil
    // Instancia a View
    oView := FwFormView():New()
    // Seta o model
    oView:SetModel( oModel )
Return oView


/*/{Protheus.doc} AGRA890Local
//TODO Descrição auto-gerada.
@author bruna.rocio
@since 18/10/2016
@version undefined
@param oStruNPH, object, descricao
@param nAltLocal, numeric, descricao
@type function
/*/
Function AGRA890Local(oStruNPH, nAltLocal)
   Local nI   := 0
   Local nRet := 0
   If nAltLocal = 0
	   For nI := 1  to Len(oStruNPH:AFIELDS)
	      If oStruNPH:AFIELDS[nI][1] = "NPH_LOCAL" .AND. (oStruNPH:AFIELDS[nI][10]) 
	         oStruNPH:AFIELDS[nI][10] := .NOT.(oStruNPH:AFIELDS[nI][10])
	         nRet := nI
	         exit 
	      EndIf
	   Next nI
   Else
       oStruNPH:AFIELDS[nAltLocal][10] := .NOT.(oStruNPH:AFIELDS[nAltLocal][10])
       nRet := 0
   EndIf
Return nRet


/*/{Protheus.doc} validaSaldo
//Validação de Saldo do Lote
@author bruna.rocio
@since 18/10/2016
@version undefined
@param cSafra, characters, descricao
@param cLocal, characters, descricao
@param cCultura, characters, descricao
@param cCateg, characters, descricao
@param cPeneira, characters, descricao
@param cCtvar, characters, descricao
@param nQtdDisp, numeric, descricao
@param nSaldoBF, numeric, descricao
@type function
/*/
Static Function validaSaldo( cSafra, cProduto, cLocal, cCultura, cCateg, cPeneira, cCtvar, nQtdDisp, nSaldoBF )
	Local aArea    := GetArea()
	Local lRetorno := .T.
	Local lEmpPrev := If(SuperGetMV("MV_QTDPREV") = "S",.T.,.F.)
	
	
	cAlias := GetNextAlias()
	cQry := " SELECT NP9.NP9_PROD,NP9.NP9_LOTE"
	cQry += " FROM " +RetSqlName("NP9")+" NP9 "
	cQry += " WHERE NP9_FILIAL = '"+xFilial("NP9")+"'"
	cQry += " AND NP9.NP9_PROD = '"+cProduto+"' AND NP9.NP9_CODSAF = '"+cSafra+"' "
	cQry +=   iif (!Empty(AllTrim(cLocal)),  " AND NP9.NP9_LOCAL   = '"+cLocal+"'","")
	cQry +=   iif (!Empty(AllTrim(cCultura)), " AND NP9.NP9_CULTRA = '"+cCultura+"'","")
	cQry +=   iif (!Empty(AllTrim(cCateg)), " AND NP9.NP9_CATEG    = '"+cCateg+"'","")
	cQry +=   iif (!Empty(AllTrim(cPeneira)), " AND NP9.NP9_PENE   = '"+cPeneira+"'","")
	cQry +=   iif (!Empty(AllTrim(cCtvar)), " AND NP9.NP9_CTVAR    = '"+cCtvar+"'","")
	cQry += " AND NP9.D_E_L_E_T_ = ' '  AND NP9_STATUS  ='2' "
	cQry += " Order by NP9.NP9_PROD"
	cQry := ChangeQuery(cQry)

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),cAlias,.F.,.T.)

	nQtdDisp := 0
	nSaldoBF := 0

	While (cAlias)->(!Eof())
		dbSelectArea('SB8')
		dbSetOrder(5)
		If dbSeek(FwXFilial('SB8')+(cAlias)->NP9_PROD+(cAlias)->NP9_LOTE)
			WHILE SB8->(!Eof()) .and. B8_FILIAL = xFilial("SB8") .and. B8_PRODUTO = (cAlias)->NP9_PROD .and. B8_LOTECTL = (cAlias)->NP9_LOTE
				nQtdDisp += SB8Saldo(.F.,!Empty((cAlias)->NP9_LOTE),NIL,NIL,NIL,NIL,lEmpPrev,ddatabase)
				
				dbSelectArea('SBF')
				dbSetOrder(2)
				If dbSeek(xFilial('SBF')+(cAlias)->NP9_PROD+SB8->B8_LOCAL+(cAlias)->NP9_LOTE)
					While !SBF->(Eof()) .And. SBF->BF_FILIAL  = xFilial('SBF')     ;
										.And. SBF->BF_PRODUTO = (cAlias)->NP9_PROD ;
										.And. SBF->BF_LOCAL   = SB8->B8_LOCAL      ;
										.And. SBF->BF_LOTECTL = (cAlias)->NP9_LOTE
						nSaldoBF += SaldoSBF(SB8->B8_LOCAL,SBF->BF_LOCALIZ,(cAlias)->NP9_PROD,NIL,(cAlias)->NP9_LOTE,NIL,.F.,NIL,.T.)
					SBF->(dbSkip())
					EndDo
					
				Endif
				DbSelectArea('SB8')
				DbSkip()
			END
		EndIf
		(cAlias)->(dbSkip())
	End
	
	(cAlias)->(dbCloseArea())
	
	RestArea(aArea)
Return lRetorno

/*/{Protheus.doc} AGRA890VIT
//Na alteração do campo local é necessario realizar a Validação do ITem
@author carlos.augusto
@since 12/12/2016
@version undefined
@type function
/*/
Function AGRA890VIT()
	Local oModel	 := FwModelActive()
	Local oModelGrid := oModel:GetModel("NPHDETAIL")
	Local lRetorno	 := .T.
	If !Empty(FwFldGet("NPH_NUMCP"))
		If !Empty(FwFldGet("NPH_LOCAL"))
			lRetorno := VldLine(oModelGrid,,FwFldGet('NPH_CODPRO'))
		EndIf
		If lRetorno
			lRetorno := NaoVazio() .And. ExistCPO("NNR")
		EndIf
	EndIf
	
Return lRetorno
