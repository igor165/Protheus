#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA311.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA311
Identificação dos Períodos e Formas de Apuração do IRPJ e da CSLL no 
  Ano-Calendário

@author Anderson Costa
@since 24/06/2014
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA311()

Local oBrw := FWmBrowse():New()

oBrw:SetDescription(STR0001) //"Identificação dos Períodos e Formas de Apuração do IRPJ e da CSLL no Ano-Calendário"
oBrw:SetAlias('CAC')
oBrw:SetMenuDef( 'TAFA311' )

// Define ordenação
CAC->(DbSetOrder(2))

oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Anderson Costa
@since 24/06/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf311Vld" , "2" } )
aRotina	:=	xFunMnuTAF( "TAFA311" , , aFuncao)

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Anderson Costa
@since 24/06/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCAC := FWFormStruct( 1, 'CAC' )
Local oStruCAD := FWFormStruct( 1, 'CAD' )
Local oStruCAE := FWFormStruct( 1, 'CAE' )
Local oStruCAF := FWFormStruct( 1, 'CAF' )
Local oStruCAG := FWFormStruct( 1, 'CAG' )
Local oModel := MPFormModel():New( 'TAFA311' , , , {|oModel| SaveModel(oModel)})

lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

If lVldModel
	oStruCAC:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
EndIf

oModel:AddFields('MODEL_CAC', /*cOwner*/, oStruCAC)

oModel:AddGrid("MODEL_CAD","MODEL_CAC",oStruCAD)
oModel:GetModel("MODEL_CAD"):SetOptional(.T.)
oModel:GetModel("MODEL_CAD"):SetUniqueLine({"CAD_CTA","CAD_CODCUS"})

oModel:AddGrid("MODEL_CAE","MODEL_CAD",oStruCAE)
oModel:GetModel("MODEL_CAE"):SetOptional(.T.)
oModel:GetModel("MODEL_CAE"):SetUniqueLine( {"CAE_CTAREF"} )

oModel:AddGrid("MODEL_CAF","MODEL_CAC",oStruCAF)
//oModel:GetModel("MODEL_CAF"):SetOptional(.T.)
oModel:GetModel("MODEL_CAF"):SetUniqueLine({"CAF_CTA","CAF_CODCUS"})

oModel:AddGrid("MODEL_CAG","MODEL_CAF",oStruCAG)
//oModel:GetModel("MODEL_CAG"):SetOptional(.T.)
oModel:GetModel("MODEL_CAG"):SetUniqueLine({"CAG_CTAREF"})

oModel:GetModel('MODEL_CAC'):SetPrimaryKey({"CAC_DTINI", "CAC_DTFIN", "CAC_IDPERA"})

oModel:SetRelation("MODEL_CAD",{ {"CAD_FILIAL","xFilial('CAD')"}, {"CAD_ID","CAC_ID"} },CAD->(IndexKey(1)) )
oModel:SetRelation("MODEL_CAE",{ {"CAE_FILIAL","xFilial('CAE')"}, {"CAE_ID","CAC_ID"}, {"CAE_CTA","CAD_CTA"},{"CAE_CODCUS","CAD_CODCUS"} },CAE->(IndexKey(1)) )
oModel:SetRelation("MODEL_CAF",{ {"CAF_FILIAL","xFilial('CAF')"}, {"CAF_ID","CAC_ID"} },CAF->(IndexKey(1)) )
oModel:SetRelation("MODEL_CAG",{ {"CAG_FILIAL","xFilial('CAG')"}, {"CAG_ID","CAC_ID"}, {"CAG_CTA","CAF_CTA"},{"CAG_CODCUS","CAF_CODCUS"} },CAG->(IndexKey(1)) )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Anderson Costa
@since 24/06/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FWLoadModel( 'TAFA311' )
Local oStruCAC := FWFormStruct( 2, 'CAC' )
Local oStruCAD := FWFormStruct( 2, 'CAD' )
Local oStruCAE := FWFormStruct( 2, 'CAE' )
Local oStruCAF := FWFormStruct( 2, 'CAF' )
Local oStruCAG := FWFormStruct( 2, 'CAG' )
Local oView    := FWFormView():New()
Local aCombo   := {}
Local nOrd     := 0
Local lCpEcf50 := VerEcf50()

/*----------------------------------------------------------------------------------
Esrutura da View
-------------------------------------------------------------------------------------*/
oView:SetModel( oModel )

aAdd( aCombo, "01=L100A" )
aAdd( aCombo, "02=L100B" )
aAdd( aCombo, "03=L100C" )
aAdd( aCombo, "04=L300A" )
aAdd( aCombo, "05=L300B" )
aAdd( aCombo, "06=L300C" )
aAdd( aCombo, "07=P100" )
aAdd( aCombo, "08=P150" )
aAdd( aCombo, "09=U100A" )
aAdd( aCombo, "10=U100B" )
aAdd( aCombo, "11=U100C" )
aAdd( aCombo, "12=U100D" )
aAdd( aCombo, "13=U100E" )
aAdd( aCombo, "14=U150A" )
aAdd( aCombo, "15=U150B" )
aAdd( aCombo, "16=U150C" )
aAdd( aCombo, "17=U150D" )
aAdd( aCombo, "18=U150E" )

if lCpEcf50
	oStruCAE:SetProperty( 'CAE_TABECF'	, MVC_VIEW_ORDEM, cValToChar(++ nOrd) )
	oStruCAE:SetProperty( 'CAE_CTAREF'	, MVC_VIEW_ORDEM, cValToChar(++ nOrd) )
	oStruCAE:SetProperty( 'CAE_DCTARE'	, MVC_VIEW_ORDEM, cValToChar(++ nOrd) )
	oStruCAE:SetProperty( 'CAE_VLRSI'	, MVC_VIEW_ORDEM, cValToChar(++ nOrd) )
	oStruCAE:SetProperty( 'CAE_SITSI'	, MVC_VIEW_ORDEM, cValToChar(++ nOrd) )
	oStruCAE:SetProperty( 'CAE_VLRDB'	, MVC_VIEW_ORDEM, cValToChar(++ nOrd) )
	oStruCAE:SetProperty( 'CAE_VLRCR'	, MVC_VIEW_ORDEM, cValToChar(++ nOrd) )
	oStruCAE:SetProperty( 'CAE_VLRREF'	, MVC_VIEW_ORDEM, cValToChar(++ nOrd) )
	oStruCAE:SetProperty( 'CAE_SITVLR'	, MVC_VIEW_ORDEM, cValToChar(++ nOrd) )
endif

oStruCAE:SetProperty( "CAE_TABECF", MVC_VIEW_COMBOBOX, aCombo )
oStruCAG:SetProperty( "CAG_TABECF", MVC_VIEW_COMBOBOX, aCombo )

oView:AddField("VIEW_CAC",oStruCAC,"MODEL_CAC")
oView:EnableTitleView("VIEW_CAC",STR0002) //"Per. Formas Apur. do IRPJ e CSLL"

oView:AddGrid("VIEW_CAD",oStruCAD,"MODEL_CAD")
oView:EnableTitleView("VIEW_CAD",STR0003) //"Saldos Contábeis Encerramen. Período"

oView:AddGrid("VIEW_CAE",oStruCAE,"MODEL_CAE")
oView:EnableTitleView("VIEW_CAE",STR0004) //"Map. Referência do Saldo Final"

oView:AddGrid("VIEW_CAF",oStruCAF,"MODEL_CAF")
oView:EnableTitleView("VIEW_CAF",STR0005) //"Saldos Cont. Antes Encerram. Per."

oView:AddGrid("VIEW_CAG",oStruCAG,"MODEL_CAG")
oView:EnableTitleView("VIEW_CAG",STR0006) //"Map. Ref. Saldo Final Antes Enc."

/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",28)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL") //CAC 

oView:CreateHorizontalBox("PAINEL_INFERIOR",72)
oView:CreateFolder("FOLDER_INFERIOR","PAINEL_INFERIOR")  

oView:AddSheet("FOLDER_INFERIOR","ABA01",STR0003) //"Saldos Contábeis Encerramen. Período"
oView:CreateHorizontalBox("PAINEL_CAD",50,,,"FOLDER_INFERIOR","ABA01") //CAD
oView:CreateHorizontalBox("PAINEL_CAE",50,,,"FOLDER_INFERIOR","ABA01") //CAE

oView:AddSheet("FOLDER_INFERIOR","ABA02",STR0005) //"Saldos Cont. Antes Encerram. Per."
oView:CreateHorizontalBox("PAINEL_CAF",50,,,"FOLDER_INFERIOR","ABA02") //CAD
oView:CreateHorizontalBox("PAINEL_CAG",50,,,"FOLDER_INFERIOR","ABA02") //CAE

If TamSX3("CAD_CTA")[1] == 36
	oStruCAD:RemoveField( "CAD_CTA")
	oStruCAD:SetProperty( "CAD_CTACTB", MVC_VIEW_ORDEM, "03" )
EndIf


If TamSX3("CAF_CTA")[1] == 36
	oStruCAF:RemoveField( "CAF_CTA")
	oStruCAF:SetProperty( "CAF_CTACTB", MVC_VIEW_ORDEM, "03" )
EndIf
/*-----------------------------------------------------------------------------------
Amarração para exibição das informações
-------------------------------------------------------------------------------------*/
oView:SetOwnerView( 'VIEW_CAC', 'PAINEL_PRINCIPAL' )   
oView:SetOwnerView( 'VIEW_CAD', 'PAINEL_CAD' ) 
oView:SetOwnerView( 'VIEW_CAE', 'PAINEL_CAE' ) 
oView:SetOwnerView( 'VIEW_CAF', 'PAINEL_CAF' ) 
oView:SetOwnerView( 'VIEW_CAG', 'PAINEL_CAG' ) 

/*-----------------------------------------------------------------------------------
Esconde campos de controle interno
-------------------------------------------------------------------------------------*/
oStruCAC:RemoveField( "CAC_ID" )
oStruCAC:RemoveField( "CAC_IDPERA" )
oStruCAC:RemoveField( "CAC_STATUS" )
oStruCAE:RemoveField( "CAE_IDCTAR" )
oStruCAG:RemoveField( "CAG_IDCTAR" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param  oModel -> Modelo de dados

@Return .T.

@Author Anderson Costa
@Since 24/06/2014
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )                              

Local nOperation := oModel:GetOperation()

Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao responsavel por setar o Status do registro para Branco³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TAFAltStat( "CAC", " " )	
	
	EndIf

	FwFormCommit( oModel )

End Transaction

Return ( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf311Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacos 
caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 24/06/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function Taf311Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}
Local cStatus		:= ""
Local cChave		:= ""
Local lValida		:= .F.

Local cCADKey		:= ""
Local cCAEKey		:= ""
Local cCAFKey		:= ""
Local cCAGKey		:= ""

Local cIDCodNat	:= ""
Local cCodNat		:= ""
Local cIndCta		:= ""
Local nVLRSLI		:= 0
Local nVLRSLF		:= 0
Local nVLRDEB		:= 0
Local nVLRCRD		:= 0
Local nVLRREF		:= 0
Local nVLSLENC	:= 0
Local nVLSLANT	:= 0
Local lCpEcf50  := VerEcf50()

Default lJob := .F. 

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := CAC->( Recno() )

lValida := ( CAC->CAC_STATUS $ ( " |1" ) )

If lValida
	
	//---------------------
	// Campos obrigatórios
	//---------------------
	If Empty(CAC->CAC_DTINI)                                           
		AADD(aLogErro,{"CAC_DTINI","000003","CAC",nRecno}) //STR0003 - "Data inconsistente ou vazia." 
	EndIf
	
	If Empty(CAC->CAC_DTFIN)                                            
		Aadd(aLogErro,{"CAC_DTFIN","000003","CAC",nRecno}) //STR0003 - "Data inconsistente ou vazia." 
	EndIf

	If Empty(CAC->CAC_IDPERA)                                            
		Aadd(aLogErro,{"CAC_IDPERA","000001","CAC",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 
	EndIf
	
	//------------------
	// Consultas padrão
	//------------------
	If !Empty(CAC->CAC_IDPERA)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := CAC->CAC_IDPERA
		xVldECFTab("CAH",cChave,1,,@aLogErro,{ "CAC", "CAC_PERAPU", nRecno })
	EndIf	

	//--------------------
	// Regras específicas
	//--------------------
	If (CAC->CAC_DTFIN) < (CAC->CAC_DTINI)
		AADD(aLogErro,{"CAC_DTFIN","000010","CAC", nRecno }) //STR0011 - A data de fim do período dever ser maior ou igual a data de início do período.
	EndIf
	
	//VALIDA_PERIODO
	xVldECFReg( cAlias,"VALIDA_PERIODO", @aLogErro,{CAC->CAC_DTINI,CAC->CAC_DTFIN,CAC->CAC_IDPERA})
	
	//ÚÄÄÄÄÄÄÄÄÄÄ¿
	//³INICIO CAD³
	//ÀÄÄÄÄÄÄÄÄÄÄÙ
	CAD->( DBSetOrder(1) )
	
	cCADKey := CAC->CAC_ID
	If CAD->( MsSeek( xFilial("CAD") + cCADKey ) )

		Do While !CAD->( Eof() ) .And. cCADKey == CAD->CAD_ID
		
			nVLRREF:= 0

			//---------------------
			// Campos obrigatórios
			//---------------------
			If Empty(CAD->CAD_CTA)                                           
				AADD(aLogErro,{"CAD_CTA","000001","CAC",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 
			EndIf

			If Empty(CAD->CAD_SITSLI)
				AADD(aLogErro,{"CAD_SITSLI","000001","CAC",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
			EndIf
			
			//------------------
			// Consultas padrão
			//------------------
			If !Empty(CAD->CAD_CTA)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := CAD->CAD_CTA
				xVldECFTab("C1O",cChave,3,,@aLogErro,{ "CAC", "CAD_CTA", nRecno })
			EndIf	

			If !Empty(CAD->CAD_CODCUS)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := CAD->CAD_CODCUS
				xVldECFTab("C1P",cChave,3,,@aLogErro,{ "CAC", "CAD_CTA", nRecno })
			EndIf	

			//--------
			// Combos
			//--------
			If !Empty(CAD->CAD_SITSLI) .And. !CAD->CAD_SITSLI $ (" |1|2")
				AADD(aLogErro,{"CAD_SITSLI","000002", "CAC",nRecno }) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."   
			EndIf	

			//--------------------
			// Regras específicas
			//--------------------
			
			// REGRA_NATUREZA_PERMITIDA_PATRIMONIAL
			cIDCodNat := Alltrim(Posicione("C1O",3,xFilial("C1O")+CAD->CAD_CTA,"C1O_CODNAT"))
			cCodNat := Alltrim(Posicione("C2R",3,xFilial("C2R")+cIDCodNat,"C2R_CODIGO"))
			
			If !cCodNat $ ("01|02|03")
				AADD(aLogErro,{"CAD_CTA","000018","CAC",nRecno}) //STR0018 - "O Código da Natureza referente ao campo 'Cta Contabil' deve ser igual a '01' (Contas do Ativo), '02' (Contas do Passivo) ou '03' (Contas do Patrimônio Líquido)."   
			EndIf
			
			// REGRA_CONTA_ANALITICA
			cIndCta := Alltrim(Posicione("C1O",3,xFilial("C1O")+CAD->CAD_CTA,"C1O_INDCTA"))
			
			If cIndCta <> '1'
				AADD(aLogErro,{"CAD_CTA","000124","CAC",nRecno}) //STR0124 - "O campo 'Cta Contabil' deve representar uma conta analítica."
			EndIf

			//REGRA_VALIDACAO_SALDO_FINAL - Campo IND_VL_SLD_FIN 
			If CAD->CAD_SITSLI == "1"
				If CAD->CAD_SITSLF == "1"
					If ( CAD->CAD_VLRSLF * ( - 1 ) ) <> ( CAD->CAD_VLRSLI * ( - 1 ) ) - CAD->CAD_VLRDEB + CAD->CAD_VLRCRD
						aAdd( aLogErro, { "CAD_VLRSLF", "000187", "CAC", nRecno } ) //STR0187 - "O valor de Vl.Saldo Fin deve ser igual ao valor de Vl.Saldo Ini somado aos valores dos campos Vl.Debito e Vl.Credito, considerando os indicadores de saldo devedor e credor do saldo inicial e do saldo final."
					EndIf
				Else
					If CAD->CAD_VLRSLF <> ( CAD->CAD_VLRSLI * ( - 1 ) ) - CAD->CAD_VLRDEB + CAD->CAD_VLRCRD
						aAdd( aLogErro, { "CAD_VLRSLF", "000187", "CAC", nRecno } ) //STR0187 - "O valor de Vl.Saldo Fin deve ser igual ao valor de Vl.Saldo Ini somado aos valores dos campos Vl.Debito e Vl.Credito, considerando os indicadores de saldo devedor e credor do saldo inicial e do saldo final."
					EndIf
				EndIf
			Else
				If CAD->CAD_SITSLF == "1"
					If ( CAD->CAD_VLRSLF * ( - 1 ) ) <> CAD->CAD_VLRSLI - CAD->CAD_VLRDEB + CAD->CAD_VLRCRD
						aAdd( aLogErro, { "CAD_VLRSLF", "000187", "CAC", nRecno } ) //STR0187 - "O valor de Vl.Saldo Fin deve ser igual ao valor de Vl.Saldo Ini somado aos valores dos campos Vl.Debito e Vl.Credito, considerando os indicadores de saldo devedor e credor do saldo inicial e do saldo final."
					EndIf
				Else
					If CAD->CAD_VLRSLF <> CAD->CAD_VLRSLI - CAD->CAD_VLRDEB + CAD->CAD_VLRCRD
						aAdd( aLogErro, { "CAD_VLRSLF", "000187", "CAC", nRecno } ) //STR0187 - "O valor de Vl.Saldo Fin deve ser igual ao valor de Vl.Saldo Ini somado aos valores dos campos Vl.Debito e Vl.Credito, considerando os indicadores de saldo devedor e credor do saldo inicial e do saldo final."
					EndIf
				EndIf
			EndIf
			
			// Se for devedor, subtrai. Senão, soma
			If CAD->CAD_SITSLI == '1'
				nVLRSLI := nVLRSLI - CAD->CAD_VLRSLI
			Else
				nVLRSLI := nVLRSLI + CAD->CAD_VLRSLI
			EndIf
			
			// Se for devedor, subtrai. Senão, soma
			If CAD->CAD_SITSLF == '1'
				nVLRSLF := nVLRSLF - CAD->CAD_VLRSLF
			Else
				nVLRSLF := nVLRSLF + CAD->CAD_VLRSLF
			EndIf
			
			nVLRDEB := nVLRDEB + CAD->CAD_VLRDEB
			nVLRCRD := nVLRCRD + CAD->CAD_VLRCRD
					

			//ÚÄÄÄÄÄÄÄÄÄÄ¿
			//³INICIO CAE³
			//ÀÄÄÄÄÄÄÄÄÄÄÙ
			CAE->( DBSetOrder(1) )
			
			cCAEKey := CAD->(CAD_ID + CAD_CTA + CAD_CODCUS)
			If CAE->( MsSeek( xFilial("CAE") + cCAEKey ) )
		
				Do While !CAE->( Eof() ) .And. cCAEKey == CAE->(CAE_ID + CAE_CTA + CAE_CODCUS)
		
					//---------------------
					// Campos obrigatórios
					//---------------------
					If Empty( CAE->CAE_IDCTAR )
						AADD(aLogErro,{"CAE_IDCTAR","000001","CAC",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 
					EndIf
		
					If Empty(CAE->CAE_SITVLR)
						AADD(aLogErro,{"CAE_SITVLR","000001","CAC",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
					EndIf

					if lCpEcf50
						If Empty(CAE->CAE_SITSI)
							AADD(aLogErro,{"CAE_SITSI","000001","CAC",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
						EndIf
					endif

					//------------------
					// Consultas padrão
					//------------------
					If !Empty( CAE->CAE_IDCTAR )
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := CAE->CAE_CTA + CAE->CAE_IDCTAR
						xVldECFTab( "CH5", cChave, 1,, @aLogErro, { "CAC", "CAE_CTAREF", nRecno } )
					EndIf	
		
					//--------
					// Combos
					//--------
					If !CAE->CAE_SITVLR $ (" |1|2")
						AADD(aLogErro,{"CAE_SITVLR","000002","CAC",nRecno }) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."   
					EndIf

					if lCpEcf50
						If !CAE->CAE_SITSI $ (" |1|2")
							AADD(aLogErro,{"CAE_SITSI","000002","CAC",nRecno }) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."   
						EndIf
					endif

					//Somatório do valor do saldo final	
					//Se situação do saldo final for devedor, subtrai. Senão, soma.
					If CAE->CAE_SITVLR == '1'
						nVLRREF:= nVLRREF - CAE->CAE_VLRREF
					Else
						nVLRREF:= nVLRREF + CAE->CAE_VLRREF
					EndIf
							
					CAE->( DbSkip() )
				EndDo
			Else
				//"Deve existir ao menos um Mapeamento Referencial do Saldo Final para o Saldo Contábil Depois do Encerramento do Período."
				aAdd( aLogErro , { "CAE_CTA" , "000126" , "CAC" , nRecno } )
			Endif
			
			//Valor do Saldo Final
			//Se for devedor, se torna negativo. Senão, mantém positivo.
			If CAD->CAD_SITSLF == '1'
				nVLSLENC:= CAD->CAD_VLRSLF * -1
			Else
				nVLSLENC:= CAD->CAD_VLRSLF
			EndIf

			//REGRA_MAPEAMENTO
			If nVLRREF <> nVLSLENC
				AADD(aLogErro,{"CAE_VLRREF","000022","CAC",nRecno}) //STR0022 - "A soma do campo 'Vl.Cta.Ref.' deve ser igual ao campo 'Vl.Saldo Fin'."
			EndIf

			//ÚÄÄÄÄÄÄÄ¿
			//³FIM CAE³
			//ÀÄÄÄÄÄÄÄÙ

			CAD->( DbSkip() )
		EndDo
	EndIf
	
	//** Regra retirada por que o validador do ECF Versão 1.0.6 não valida essas condições
	// REGRA_VALIDACAO_SOMA_SALDO_INICIAL
	//If nVLRSLI == 0
	//	AADD(aLogErro,{"CAD_VLRSLI","000019","CAC",nRecno}) //STR0019 - "A soma do campo 'Vl.Saldo Ini' deve ser igual a 0 (zero) para o período."
	//EndIf

	// REGRA_VALIDACAO_SOMA_SALDO_FINAL
	//If nVLRSLF == 0
	//	AADD(aLogErro,{"CAD_VLRSLF","000020","CAC",nRecno}) //STR0020 - "A soma do campo 'Vl.Saldo Fin' deve ser igual a 0 (zero) para o período."
	//EndIf
	
	// REGRA_VALIDACAO_DEB_DIF_CRED
	If nVLRDEB <> nVLRCRD 
		AADD(aLogErro,{"CAD_VLRDEB","000021","CAC",nRecno}) //STR0021 - "A soma do campo 'Vl.Debito' deve ser igual a soma do campo 'Vl.Credito' para o período."
	EndIf
	
	//ÚÄÄÄÄÄÄÄ¿
	//³FIM CAD³
	//ÀÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄ¿
	//³INICIO CAF³
	//ÀÄÄÄÄÄÄÄÄÄÄÙ
	CAF->( DBSetOrder(1) )
	
	cCAFKey := CAC->CAC_ID
	If CAF->( MsSeek( xFilial("CAF") + cCAFKey ) )
	
		Do While !CAF->( Eof() ) .And. cCAFKey == CAF->CAF_ID
		
			nVLRREF := 0

			//---------------------
			// Campos obrigatórios
			//---------------------
			If Empty(CAF->CAF_CTA)                                           
				AADD(aLogErro,{"CAF_CTA","000001","CAC",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 
			EndIf
			
			If Empty(CAF->CAF_SITSLF)
				AADD(aLogErro,{"CAF_SITSLF","000001","CAC",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
			EndIf
			
			//------------------
			// Consultas padrão
			//------------------
			If !Empty(CAF->CAF_CTA)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := CAF->CAF_CTA
				xVldECFTab("C1O",cChave,3,,@aLogErro,{ "CAC", "CAF_CTA", nRecno })
			EndIf	

			If !Empty(CAF->CAF_CODCUS)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := CAF->CAF_CODCUS
				xVldECFTab("C1P",cChave,3,,@aLogErro,{ "CAC", "CAF_CTA", nRecno })
			EndIf	

			//--------
			// Combos
			//--------
			If !CAF->CAF_SITSLF $ (" |1|2")
				AADD(aLogErro,{"CAF_SITSLF","000002", "CAC",nRecno }) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."   
			EndIf	

			//--------------------
			// Regras específicas
			//--------------------

			//REGRA_CONTA_ANALITICA
			cIndCta := AllTrim( Posicione( "C1O", 3, xFilial( "C1O" ) + CAF->CAF_CTA, "C1O_INDCTA" ) )

			If cIndCta <> "1"
				aAdd( aLogErro, { "CAF_CTA", "000124", "CAC", nRecno } ) //STR0124 - "O campo 'Cta Contabil' deve representar uma conta analítica."
			EndIf

			// REGRA_NATUREZA_PERMITIDA_4
			cIDCodNat := Alltrim(Posicione("C1O",3,xFilial("C1O")+CAF->CAF_CTA,"C1O_CODNAT"))
			cCodNat := Alltrim(Posicione("C2R",3,xFilial("C2R")+cIDCodNat,"C2R_CODIGO"))
			
			If cCodNat <> "04"
				AADD(aLogErro,{"CAF_CTA","000023","CAC",nRecno}) //STR0023 - "O valor do campo 'Cta Contabil' deve ser igual a '04' (Contas do Resultado)."   
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄ¿
			//³INICIO CAG³
			//ÀÄÄÄÄÄÄÄÄÄÄÙ
			CAG->( DBSetOrder(1) )
			
			cCAGKey := CAF->(CAF_ID + CAF_CTA + CAF_CODCUS)
			If CAG->( MsSeek( xFilial("CAG") + cCAGKey ) )
		
				Do While !CAG->( Eof() ) .And. cCAGKey == CAG->(CAG_ID + CAG_CTA + CAG_CODCUS)
		
					//---------------------
					// Campos obrigatórios
					//---------------------
					If Empty( CAG->CAG_IDCTAR )
						AADD(aLogErro,{"CAG_IDCTAR","000001","CAC",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 
					EndIf
		
					If Empty(CAG->CAG_SITVLR)
						AADD(aLogErro,{"CAG_SITVLR","000001","CAC",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
					EndIf
					
					//------------------
					// Consultas padrão
					//------------------
					If !Empty( CAG->CAG_IDCTAR )
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := CAG->CAG_CTA + CAG->CAG_IDCTAR
						xVldECFTab( "CH5", cChave, 1,, @aLogErro,{ "CAC", "CAG_IDCTAR", nRecno } )
					EndIf	
		
					//--------
					// Combos
					//--------
					If !CAG->CAG_SITVLR $ (" |1|2")
						AADD(aLogErro,{"CAG_SITVLR","000002", "CAC",nRecno }) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."   
					EndIf	
		
					//Somatório do valor do saldo final	
					//Se situação do saldo final for devedor, subtrai. Senão, soma.
					If CAG->CAG_SITVLR == '1'
						nVLRREF:= nVLRREF - CAG->CAG_VLRREF
					Else
						nVLRREF:= nVLRREF + CAG->CAG_VLRREF
					EndIf
							
					CAG->( DbSkip() )
				EndDo
			EndIf

			//Valor do Saldo Final
			//Se for devedor, se torna negativo. Senão, mantém positivo.
			If CAF->CAF_SITSLF == '1'
				nVLSLANT:= CAF->CAF_VLRSLF * -1
			Else
				nVLSLANT:= CAF->CAF_VLRSLF
			EndIf
						
			//REGRA_MAPEAMENTO
			If nVLRREF <> nVLSLANT
				AADD(aLogErro,{"CAG_VLRREF","000022","CAC",nRecno})  //STR0022 - "A soma do campo 'Vl.Cta.Ref.' deve ser igual ao campo 'Vl.Saldo Fin'."
			EndIf

			//ÚÄÄÄÄÄÄÄ¿
			//³FIM CAG³
			//ÀÄÄÄÄÄÄÄÙ

			CAF->( DbSkip() )
		EndDo
	EndIf

	//ÚÄÄÄÄÄÄÄ¿
	//³FIM CAF³
	//ÀÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ATUALIZO O STATUS DO REGISTRO³
	//³1 = Registro Invalido        ³
	//³0 = Registro Valido          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "CAC", cStatus )

Else
	AADD(aLogErro,{"CAC_ID","000017", "CAC", nRecno }) //STR0017 - "Registro já validado."
EndIf
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro)

//---------------------------------------------------------------------
/*/{Protheus.doc} VerEcf50

Rotina para verificar se existem os campos utilizados no ECF layout 5.0

@Param

@Author Denis Souza
@Since 23/04/2019
@Version 1.0
/*/
//---------------------------------------------------------------------
Function VerEcf50()

	Local aGetArea := GetArea()
	Local lEcf50  := .F.

	If AliasIndic("CAE") .And. Empty(Select("CAE"))
		DbSelectArea("CAE")
		CAE->(DbSetOrder(1))
	endif

	If TafColumnPos("CAE_VLRSI") .And. TafColumnPos( "CAE_SITSI" ) .And. TafColumnPos( "CAE_VLRDB" ) .And. TafColumnPos( "CAE_VLRCR" )
		lEcf50 := .T.
	endif

	RestArea(aGetArea)

Return lEcf50