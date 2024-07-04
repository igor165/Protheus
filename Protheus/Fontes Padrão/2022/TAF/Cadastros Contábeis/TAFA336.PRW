#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA336.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA336
Cadastro MVC de Participações no Exterior

@author Roger Cangianeli
@since 10/06/2014
@version 1.0
  
/*/
//-------------------------------------------------------------------
Function TAFA336
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription(STR0001)//Participações no Exterior
oBrw:SetAlias( 'CFY')
oBrw:SetMenuDef( 'TAFA336' )
oBrw:Activate()  

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Fabio V Santana
@since 26/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf336Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA336" , , aFuncao)

Return( aRotina )      
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V Santana
@since 26/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCFY 	:= FWFormStruct( 1, 'CFY' )
Local oStruCFZ 	:= FWFormStruct( 1, 'CFZ' )
Local oStruCHL 	:= FWFormStruct( 1, 'CHL' )
Local oStruCHM 	:= FWFormStruct( 1, 'CHM' )
Local oStruCHN 	:= FWFormStruct( 1, 'CHN' )
Local oStruCHO 	:= FWFormStruct( 1, 'CHO' )
Local oStruCHP 	:= FWFormStruct( 1, 'CHP' )
Local oStruCHQ 	:= FWFormStruct( 1, 'CHQ' )
Local oStruV3M	:= Nil
Local oModel	:= Nil
Local lEcf50Bx  := Ecf50BlX()

if lEcf50Bx
	oStruV3M := FWFormStruct( 1, 'V3M' )
endif

oModel := MPFormModel():New( 'TAFA336',,{ |oModel| ValidModel( oModel ) } ,{|oModel| SaveModel(oModel)})

oModel:AddFields('MODEL_CFY', /*cOwner*/, oStruCFY)

//Participações no Exterior - Resultado do Período de Apuração
oModel:AddGrid('MODEL_CFZ', 'MODEL_CFY', oStruCFZ)
oModel:GetModel( 'MODEL_CFZ' ):SetUniqueLine( { 'CFZ_CODSEQ' } )
oModel:SetRelation( 'MODEL_CFZ' , { { 'CFZ_FILIAL' , 'xFilial( "CFZ" )' } , { 'CFZ_ID' , 'CFY_ID' } } , CFZ->( IndexKey( 1 ) ) ) 
oModel:GetModel( 'MODEL_CFZ' ):SetOptional( .T. )

//Demonstrativo de Resultados e de Imposto Pago no Exterior
oModel:AddGrid('MODEL_CHL', 'MODEL_CFY', oStruCHL)
oModel:GetModel( 'MODEL_CHL' ):SetUniqueLine( { 'CHL_CODSEQ' } )
oModel:SetRelation( 'MODEL_CHL' , { { 'CHL_FILIAL' , 'xFilial( "CHL" )' } , { 'CHL_ID' , 'CFY_ID' } } , CHL->( IndexKey( 1 ) ) ) 
oModel:GetModel( 'MODEL_CHL' ):SetOptional( .T. )
oModel:GetModel('MODEL_CHL'):SetNoInsertLine(.T.)

//Demonstrativo de Resultados no Exterior de Coligadas em Regime de Caixa
oModel:AddGrid('MODEL_CHM', 'MODEL_CFY', oStruCHM)
oModel:GetModel( 'MODEL_CHM' ):SetUniqueLine( { 'CHM_CODSEQ' } )
oModel:SetRelation( 'MODEL_CHM' , { { 'CHM_FILIAL' , 'xFilial( "CHM" )' } , { 'CHM_ID' , 'CFY_ID' } } , CHM->( IndexKey( 1 ) ) ) 
oModel:GetModel( 'MODEL_CHM' ):SetOptional( .T. )
oModel:GetModel('MODEL_CHM'):SetNoInsertLine(.T.)

//Demonstrativo de Consolidação
oModel:AddGrid('MODEL_CHN', 'MODEL_CFY', oStruCHN)
oModel:GetModel( 'MODEL_CHN' ):SetUniqueLine( { 'CHN_CODSEQ' } )
oModel:SetRelation( 'MODEL_CHN' , { { 'CHN_FILIAL' , 'xFilial( "CHN" )' } , { 'CHN_ID' , 'CFY_ID' } } , CHN->( IndexKey( 1 ) ) ) 
oModel:GetModel( 'MODEL_CHN' ):SetOptional( .T. )
oModel:GetModel('MODEL_CHN'):SetNoInsertLine(.T.)

//Demonstrativo de Prejuízos Acumulados
oModel:AddGrid('MODEL_CHO', 'MODEL_CFY', oStruCHO)
oModel:GetModel( 'MODEL_CHO' ):SetUniqueLine( { 'CHO_CODSEQ' } )
oModel:SetRelation( 'MODEL_CHO' , { { 'CHO_FILIAL' , 'xFilial( "CHO" )' } , { 'CHO_ID' , 'CFY_ID' } } , CHO->( IndexKey( 1 ) ) ) 
oModel:GetModel( 'MODEL_CHO' ):SetOptional( .T. )
oModel:GetModel('MODEL_CHO'):SetNoInsertLine(.T.)

//Demonstrativo de Prejuízos Acumulados
oModel:AddGrid('MODEL_CHP', 'MODEL_CFY', oStruCHP)
oModel:GetModel( 'MODEL_CHP' ):SetUniqueLine( { 'CHP_CODSEQ' } )
oModel:SetRelation( 'MODEL_CHP' , { { 'CHP_FILIAL' , 'xFilial( "CHP" )' } , { 'CHP_ID' , 'CFY_ID' } } , CHP->( IndexKey( 1 ) ) ) 
oModel:GetModel( 'MODEL_CHP' ):SetOptional( .T. )
oModel:GetModel('MODEL_CHP'):SetNoInsertLine(.T.)

//Demonstrativo de Prejuízos Acumulados
oModel:AddGrid('MODEL_CHQ', 'MODEL_CFY', oStruCHQ)
oModel:GetModel( 'MODEL_CHQ' ):SetUniqueLine( { 'CHQ_CODSEQ' } )
oModel:SetRelation( 'MODEL_CHQ' , { { 'CHQ_FILIAL' , 'xFilial( "CHQ" )' } , { 'CHQ_ID' , 'CFY_ID' } } , CHQ->( IndexKey( 1 ) ) ) 
oModel:GetModel( 'MODEL_CHQ' ):SetOptional( .T. )
oModel:GetModel('MODEL_CHQ'):SetNoInsertLine(.T.)

if lEcf50Bx
	//Investidoras Diretas
	oModel:AddGrid('MODEL_V3M', 'MODEL_CFY', oStruV3M)
	oModel:GetModel( 'MODEL_V3M' ):SetUniqueLine( { 'V3M_SEQ' } )
	oModel:SetRelation( 'MODEL_V3M' , { { 'V3M_FILIAL' , 'xFilial( "V3M" )' } , { 'V3M_ID' , 'CFY_ID' } } , V3M->( IndexKey( 1 ) ) ) 
	oModel:GetModel( 'MODEL_V3M' ):SetOptional( .T. )
endif

oModel:GetModel( 'MODEL_CFY' ):SetPrimaryKey( { 'CFY_PERIOD', 'CFY_NIF' } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V Santana
@since 26/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	:= 	FWLoadModel( 'TAFA336' )
Local oStruCFY 	:= 	FWFormStruct( 2, 'CFY' )
Local oStruCFZ 	:= 	FWFormStruct( 2, 'CFZ' )
Local oStruCHL 	:= 	FWFormStruct( 2, 'CHL' )
Local oStruCHM 	:= 	FWFormStruct( 2, 'CHM' )
Local oStruCHN 	:= 	FWFormStruct( 2, 'CHN' )
Local oStruCHO 	:= 	FWFormStruct( 2, 'CHO' )
Local oStruCHP 	:= 	FWFormStruct( 2, 'CHP' )
Local oStruCHQ 	:= 	FWFormStruct( 2, 'CHQ' )
Local oStruV3M 	:= 	Nil
Local oView		:=  Nil
Local lEcf50Bx  :=  Ecf50BlX()

if lEcf50Bx
	oStruV3M := FWFormStruct( 2, 'V3M' )
endif

oView := FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_CFY', oStruCFY, 'MODEL_CFY')
oView:EnableTitleView( 'VIEW_CFY', STR0001) //Participações no Exterior

oView:AddGrid ( 'VIEW_CFZ', oStruCFZ, 'MODEL_CFZ' )
oView:AddGrid ( 'VIEW_CHL', oStruCHL, 'MODEL_CHL' )
oView:AddGrid ( 'VIEW_CHM', oStruCHM, 'MODEL_CHM' )
oView:AddGrid ( 'VIEW_CHN', oStruCHN, 'MODEL_CHN' )
oView:AddGrid ( 'VIEW_CHO', oStruCHO, 'MODEL_CHO' )
oView:AddGrid ( 'VIEW_CHP', oStruCHP, 'MODEL_CHP' )
oView:AddGrid ( 'VIEW_CHQ', oStruCHQ, 'MODEL_CHQ' )
if lEcf50Bx
	oView:AddGrid ( 'VIEW_V3M', oStruV3M, 'MODEL_V3M' )
endif

oView:CreateHorizontalBox( 'FIELDSCFY', 60 )          
oView:CreateHorizontalBox( 'FOLDERGERAL', 40 )

oView:CreateFolder( 'FOLDER1', 'FOLDERGERAL' )

oView:AddSheet( 'FOLDER1', 'ABA01', STR0002) //Resultado do Período de Apuração
oView:CreateHorizontalBox( 'GRIDCFZ', 100,,, 'FOLDER1', 'ABA01' )
oView:AddIncrementField( 'VIEW_CFZ', 'CFZ_CODSEQ' )

oView:AddSheet( 'FOLDER1', 'ABA02', STR0003) //Demonstrativo de Resultados e de Imposto Pago no Exterior
oView:CreateHorizontalBox( 'GRIDCHL', 100,,, 'FOLDER1', 'ABA02' )
oView:AddIncrementField( 'VIEW_CHL', 'CHL_CODSEQ' )

oView:AddSheet( 'FOLDER1', 'ABA03', STR0004) //Demonstrativo de Resultados no Exterior de Coligadas em Regime de Caixa
oView:CreateHorizontalBox( 'GRIDCHM', 100,,, 'FOLDER1', 'ABA03' )
oView:AddIncrementField( 'VIEW_CHM', 'CHM_CODSEQ' )

oView:AddSheet( 'FOLDER1', 'ABA04', STR0005) //Demonstrativo de Consolidação
oView:CreateHorizontalBox( 'GRIDCHN', 100,,, 'FOLDER1', 'ABA04' )
oView:AddIncrementField( 'VIEW_CHN', 'CHN_CODSEQ' )

oView:AddSheet( 'FOLDER1', 'ABA05', STR0006) //Demonstrativo de Prejuízos Acumulados
oView:CreateHorizontalBox( 'GRIDCHO', 100,,, 'FOLDER1', 'ABA05' )
oView:AddIncrementField( 'VIEW_CHO', 'CHO_CODSEQ' )

oView:AddSheet( 'FOLDER1', 'ABA06', STR0007) //Demonstrativo de Rendas Ativas e Passivas
oView:CreateHorizontalBox( 'GRIDCHP', 100,,, 'FOLDER1', 'ABA06' )
oView:AddIncrementField( 'VIEW_CHP', 'CHP_CODSEQ' )

oView:AddSheet( 'FOLDER1', 'ABA07', STR0008) //Demonstrativo de Estrutura Societária
oView:CreateHorizontalBox( 'GRIDCHQ', 100,,, 'FOLDER1', 'ABA07' )
oView:AddIncrementField( 'VIEW_CHQ', 'CHQ_CODSEQ' )
if lEcf50Bx
	oView:AddSheet( 'FOLDER1', 'ABA08', STR0009 ) //#"Investidoras Diretas"
	oView:CreateHorizontalBox( 'GRIDV3M', 100,,, 'FOLDER1', 'ABA08' )
	oView:AddIncrementField( 'VIEW_V3M', 'V3M_SEQ' )
endif

oStruCFY:RemoveField('CFY_ID')
oStruCFY:RemoveField('CFY_IDMOED')
oStruCHL:RemoveField('CHL_ID')
oStruCHM:RemoveField('CHM_ID')
oStruCHN:RemoveField('CHN_ID')
oStruCHO:RemoveField('CHO_ID')
oStruCHP:RemoveField('CHP_ID')
oStruCHQ:RemoveField('CHQ_ID')
if lEcf50Bx
	oStruV3M:RemoveField('V3M_ID')
endif

oView:SetOwnerView( 'VIEW_CFY', 'FIELDSCFY' )
oView:SetOwnerView( 'VIEW_CFZ', 'GRIDCFZ' )
oView:SetOwnerView( 'VIEW_CHL', 'GRIDCHL' )
oView:SetOwnerView( 'VIEW_CHM', 'GRIDCHM' )
oView:SetOwnerView( 'VIEW_CHN', 'GRIDCHN' )
oView:SetOwnerView( 'VIEW_CHO', 'GRIDCHO' )
oView:SetOwnerView( 'VIEW_CHP', 'GRIDCHP' )
oView:SetOwnerView( 'VIEW_CHQ', 'GRIDCHQ' )
if lEcf50Bx
	oView:SetOwnerView( 'VIEW_V3M', 'GRIDV3M' )
endif

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidModel
Funcao de validacao de alguns campos do model.

@param  oModel - parametro com o Model MVC 

@return lRet - Flag de validacao, onde .T. eh valido e .F. NAO valido

@author Fabio V santana
@since 18/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidModel( oModel )
Local	lRet		:=	.T.

/*/
Se houver regra específica para este objeto.

Local	cCNPJ 	:= 	oModel:GetValue( 'MODEL_CFY' , 'CFY_CNPJ' )
Local	cCPF 	:= 	oModel:GetValue( 'MODEL_CFY' , 'CFY_CPF' )
//Validacao do campo CNPJ/CPF, dependendo do Tipo de Participante. PJ habilita o CNPJ, Fisica o CPF.
If (Empty(cCPF).And.Empty(cCNPJ)) .Or. (!Empty(cCPF).And.!Empty(cCNPJ))
	Help( ,,"CNPJOUCPF",,, 1, 0 ) 
	lRet	:=	.F.
EndIf
/*/

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Anderson Costa
@since 19/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

Local nOperation := oModel:GetOperation()

Begin Transaction 
	
	If nOperation == MODEL_OPERATION_UPDATE 
		TAFAltStat( "CFY", " " )
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} TAF336Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 19/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF336Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro  := {}
Local cChave    := ""
Local cKey		  := ""
Local cPais	  := ""
Local cIndCtl	  := ""
Local nAno		  := Year(CFY->CFY_PERIOD)
Local lEcf50Bx    := Ecf50BlX()

CFZ->( DBSetOrder(1) )
CHL->( DBSetOrder(1) )
CHM->( DBSetOrder(1) )
CHN->( DBSetOrder(1) )
CHO->( DBSetOrder(1) )
CHP->( DBSetOrder(1) )
CHQ->( DBSetOrder(1) )
if lEcf50Bx
	V3M->( DBSetOrder(1) )
endif

If CFY->CFY_STATUS $ ( " 1" )

	//Valida o Periodo informado
	If Empty( CFY->CFY_PERIOD )
		aAdd( aLogErro, { "CFY_PERIOD", "000003", "CFY", nRecno } ) //STR0003 - "Data inconsistente ou vazia."
	EndIf

	If Empty( CFY->CFY_RAZSOC )
		aAdd( aLogErro, { "CFY_RAZSOC", "000001", "CFY", nRecno } ) //STR0001 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty( CFY->CFY_NIF )
		aAdd( aLogErro, { "CFY_NIF", "000001", "CFY", nRecno } ) //STR0001 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty( CFY->CFY_INDCTL )
		aAdd( aLogErro, { "CFY_INDCTL", "000001", "CFY", nRecno } ) //STR0001 - "Campo Inconsistente ou Vazio"
	Else
		cIndCtl := Alltrim(CFY->CFY_INDCTL)
		If !( cIndCtl $ "1|2|3|4|5|6|7|8|9|10")
			aAdd( aLogErro, { "CFY_INDCTL", "000002", "CFY", nRecno } ) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
		EndIf
		If cIndCtl == '10' .And. VerifCFY(1)
			aAdd( aLogErro, { "CFY_INDCTL", "000321", "CFY", nRecno } ) // STR0321 "Se X340.IND_CONTROLE igual a '10', não deve existir outro registro X340 com X340.IND_CONTROLE igual a '4' ou '6'."                                                                                                                                                                                                                                                                                                                                                                                                 
		EndIf
		
		If cIndCtl $ '4|6' .And. VerifCFY(2)
			aAdd( aLogErro, { "CFY_INDCTL", "000322", "CFY", nRecno } ) // STR0321 "Se X340.IND_CONTROLE igual a '4' ou '6', não deve existir outro registro X340 com X340.IND_CONTROLE igual a '10'."                                                                                                                                                                                                                                                                                                                                                                                                 
		EndIf
		
	EndIf

	//Valida o conteúdo do País
	If !Empty( CFY->CFY_PAIS )
		//Chave de busca na tabela filho ou consulta padrão
		cChave := CFY->CFY_PAIS
		cPais := Posicione("C08",3,xFilial("C08")+cChave,"C08_PAISSX")
		xValRegTab( "C08", cChave, 3,, @aLogErro )
		If cPais == "105" .And. Empty(CFY->CFY_CNPJ)
			aAdd( aLogErro, { "CFY_PAIS", "000260", "CFY", nRecno } ) // Se país igual a “105” (Brasil), o campo X340.CNPJ deve estar preenchido.		
		EndIf
		If !Empty(CFY->CFY_CNPJ) .And. Empty(CFY->CFY_NIF)
		    aAdd( aLogErro, { "CFY_PAIS", "000261", "CFY", nRecno } ) // Se X340.CNPJ estiver preenchido, X340.NIF deve estar preenchido. 
		EndIf
		
	Else
		aAdd( aLogErro, { "CFY_PAIS", "000001", "CFY", nRecno } ) //STR0001 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty( CFY->CFY_INDREP )
		aAdd( aLogErro, { "CFY_INDREP", "000001", "CFY", nRecno } ) //STR0001 - "Campo Inconsistente ou Vazio"
	Else
		If !CFY->CFY_INDREP $ "1|2"
			aAdd( aLogErro, { "CFY_INDREP", "000002", "CFY", nRecno } ) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
		EndIf
	EndIf

	If Empty( CFY->CFY_INDCON )
		aAdd( aLogErro, { "CFY_INDCON", "000001", "CFY", nRecno } ) //STR0001 - "Campo Inconsistente ou Vazio"
	Else
		If !CFY->CFY_INDCON $ "1|2"
			aAdd( aLogErro, { "CFY_INDCON", "000002", "CFY", nRecno } ) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
		EndIf
	EndIf

	//Valida o Motivo da Não Consolidação
	If !Empty( CFY->CFY_MOTNCO )
		If !CFY->CFY_MOTNCO $ "1|2|3|4|5|6"
			aAdd( aLogErro, { "CFY_MOTNCO", "000002", "CAY", nRecno } ) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
		EndIf
	EndIf

	//REGRA_MOTIVO_NAO_CONSOL_PREENCHER
	If Empty( CFY->CFY_MOTNCO ) .and. CFY->CFY_INDCON == "2"
		aAdd( aLogErro, { "CFY_MOTNCO", "000225", "CFY", nRecno } ) //STR0225 - "Quando o campo Indicador de Consolidação for igual a '2 - Não', o campo Motivo da Não Consolidação deve ser preenchido obrigatoriamente."
	EndIf
	
	//REGRA_MOTIVO_NAO_CONSOL_NAO_PREENCHER
	If !Empty(CFY->CFY_MOTNCO) .And. CFY->CFY_INDCON =='1' 
		Aadd( aLogErro, { "CFY_MOTNCO", "000226", "CFY", nRecno } ) //STR0226 - "Quando o campo Indicador de Consolidação for igual a '1 - S=Sim', o campo Motivo da Não Consolidação não deve ser preenchido."
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄ¿
	//³INICIO CFZ³
	//ÀÄÄÄÄÄÄÄÄÄÄÙ
	cKey := CFY->CFY_ID
	If CFZ->( MsSeek( xFilial("CFZ") + cKey ) )

		Do While !CFZ->( Eof() ) .And. cKey == CFZ->CFZ_ID
			
			//REGRA_LUC_BRUTO_VALOR
			If CFZ->CFZ_LUCBRT <> CFZ->CFZ_RECLIQ - CFZ->CFZ_VLCUST
				AADD(aLogErro,{"CFZ_LUCBRT","000168", "CFZ",nRecno }) //STR0168 - "O 'Lucro Bruto' não corresponde ao resultado da substração 'Rec. Líquido' por 'Valor Custos' "    
			Endif
			//REGRA_LUC_OPER_VALOR
			If CFZ->CFZ_LUCOPE <> CFZ->CFZ_LUCBRT + CFZ->CFZ_RECAUF + CFZ->(CFZ_RECOPE - CFZ_DSPFIN - CFZ_DSPOPE)
				AADD(aLogErro,{"CFZ_LUCOPE","000169", "CFZ",nRecno }) //STR0169 - "Conteúdo do campo 'Lucro Oper' é diferente do resultado da operação 'Lucro Bruto' + 'Rec Auf + Rec Oper - Desp Fin - Desp Oper'"      
			Endif
			//REGRA_LUC_LIQ_ANT_IR_VALOR
			If CFZ->CFZ_LUCIR <> CFZ->CFZ_LUCOPE + CFZ->CFZ_RECPAR + CFZ->(CFZ_RECOUT - CFZ_DSPOUT)
				AADD(aLogErro,{"CFZ_LUCIR","000170", "CFZ",nRecno }) //STR0170 - "O 'Lucro Ant IR' é divergente ao resultado da operação 'Lucro Oper' + 'Rec Part' + 'Outras Rec' - 'Outras Desp'"       
			Endif
			//REGRA_LUC_LIQ_VALOR
			If CFZ->CFZ_LUCPA <> CFZ->(CFZ_LUCIR - CFZ_IMPDEV)
				AADD(aLogErro,{"CFZ_LUCPA","000171", "CFZ",nRecno }) //STR0171 - "O 'Lucro Per Ap' é divergente ao resultado da operação 'Lucro Ant IR' - 'Imp Devido'"       
			Endif
			//REGRA_LUC_LIQ_VALOR
			If nAno == 2014
				//Registro foi excluído do layout a partir de 2015.
				If CFZ->CFZ_LUCAPO <> CFZ->(CFZ_LUCANT - CFZ_IMPARB)
					AADD(aLogErro,{"CFZ_LUCAPO","000172", "CFZ",nRecno }) //STR0172 - "O 'Luc apos Imp' é divergente ao resultado da operação 'Luc ant Imp' - 'Imp Dev Arb'"       
				Endif
			EndIF
			
			CFZ->( DbSkip() )
		EndDo
	
	EndIf
	//ÚÄÄÄÄÄÄÄ¿
	//³FIM CFZ³
	//ÀÄÄÄÄÄÄÄÙ
	If lEcf50Bx .And. cIndCtl == '5' 
		//REGRA_X357_PREENCHER
		If V3M->( MsSeek( xFilial("V3M") + cKey ) )
			AADD(aLogErro,{"V3M_ID","000335", "V3M",nRecno }) //STR0335 - "Não deve existir registros de 'Investidoras Diretas', para 'Ind. Controle' igual a '5'"
		Endif
	
	ElseIf cIndCtl == '6' 
		//REGRA_X351_PREENCHER
		If CHL->( MsSeek( xFilial("CHL") + cKey ) )
			AADD(aLogErro,{"CHL_ID","000173", "CFY",nRecno }) //STR0173 - "Não deve existir registros de 'Demonstrativo de Resultados Imp. Pg.Exterior', para 'Ind. Controle' igual a '6'"       
		Endif
		//REGRA_X354_PREENCHE
		If CHO->( MsSeek( xFilial("CHO") + cKey ) )
			AADD(aLogErro,{"CHO_ID","000190", "CHO",nRecno }) //"STR0190 - "Não deve existir registros de 'Demonstrativo de Prejuízos Acumulados', para 'Ind. Controle' igual '6'" 
		Endif
		//REGRA_X355_PREENCHE
		If CHP->( MsSeek( xFilial("CHP") + cKey ) )
			AADD(aLogErro,{"CHP_ID","000178", "CHP",nRecno }) //STR0178 - "Não deve existir registros de 'Demonstrativo de Rendas Ativas e Passivas', para 'Ind. Controle' igual '6'"  
		Endif
		//REGRA_X353_PREENCHER
		If CHN->( MsSeek( xFilial("CHN") + cKey ) )	
			AADD(aLogErro,{"CHN_ID","000177", "CHN",nRecno }) //STR0177 - "Não deve existir registros de 'Demonstrativo de Consolidação', para 'Ind. Controle' igual a '6' ou 'Ind. Consolid.' igual a '2' "
		Endif
		
	ElseIf cIndCtl <> '6'
		//Valida campos CHL
		If CHL->( MsSeek( xFilial("CHL") + cKey ) )
			Do While !CHL->( Eof() ) .And. cKey == CHL->CHL_ID
				
				//REGRA_POS_TRIB_VALOR
				If CHL->CHL_RESINV > 0 .And. CHL->CHL_RESINV > CHL->CHL_RESNEG .And. CHL->CHL_RESPTB <> CHL->(CHL_RESINV - CHL_RESNEG)
					AADD(aLogErro,{"CHL_RESPTB","000174", "CHL",nRecno }) //STR0174 - "Quando o valor em 'Res Invest' for positivo e maior que o valor em 'Res Neg', o campo 'Res a Tribut' deve corresponder ao resultado da subtração 'Res Invest' por 'Res Neg'"  
				Endif
				//REGRA_POS_TRIB_NAO_PREENCHER
				If (CHL->CHL_RESINV < 0 .OR. CHL->CHL_RESINV <= CHL->CHL_RESNEG) .And. CHL->CHL_RESPTB <> 0  
					AADD(aLogErro,{"CHL_RESPTB","000175", "CHL",nRecno }) //STR0175 - "Quando o valor em 'Res Invest' for negativo ou possuir valor menor ou igual ao valor em 'Res Neg', o campo 'Res a Tribut' deve corresponder a zero" 
				Endif
				
				CHL->( DbSkip() )
				
			EndDo
		Endif
		
		If CHP->( MsSeek( xFilial("CHP") + cKey ) )
			Do While !CHP->( Eof() ) .And. cKey == CHP->CHP_ID
				
				//REGRA_ATIV_PROP_VALOR
				If CHP->CHP_RENATV <> CHP->CHP_RENTOT - CHP->CHP_RENPAS
					AADD(aLogErro,{"CHP_RENATV","000179", "CHP",nRecno }) //STR0179 - "O valor da 'Renda Ativa' não corresponde ao resultado da subtração 'Renda Total' por 'Rend Passiva' " 
				Endif
				//REGRA_ATIV_PROP_REAL_VALOR
				If CHP->CHP_RENARE <> CHP->CHP_RENTRE - CHP->CHP_RENPRE
					AADD(aLogErro,{"CHP_RENARE","000180", "CHP",nRecno }) //STR0180 - "O valor da 'Rend Ativa R' não corresponde ao resultado da subtração 'Renda Tot Re' por 'Rend P.Reais' " 
				Endif
				//REGRA_PERCENTUAL_VALOR
				If CHP->CHP_PERCEN <> Round(CHP->CHP_RENTOT / CHP->CHP_RENATV,2)
					AADD(aLogErro,{"CHP_PERCEN","000181", "CHP",nRecno }) //STR0181 - "O valor da 'Percentual' não corresponde ao resultado da divisão 'Renda Ativa' por 'Renda Total' " 
				Endif
				
				
				CHP->( DbSkip () )
			Enddo
		Endif 
		
		//REGRA_X352_PREENCHER
		If CHM->( MsSeek( xFilial("CHM") + cKey ) )
			AADD(aLogErro,{"CHM_ID","000176", "CFY",nRecno }) //STR0173 - "Não deve existir registros de 'Demonstrativo de Resultados Imp. Pg.Exterior', para 'Ind. Controle' igual a '6'"       
		Endif
	
	Elseif CFY->CFY_INDCON <> '1'
		//REGRA_X353_PREENCHER
		If CHN->( MsSeek( xFilial("CHN") + cKey ) )	
			AADD(aLogErro,{"CHN_ID","000177", "CHN",nRecno }) //STR0177 - "Não deve existir registros de 'Demonstrativo de Consolidação', para 'Ind. Controle' igual a '6' ou 'Ind. Consolid.' igual a '2' "       
		Endif
		
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ATUALIZO O STATUS DO REGISTRO³
	//³1 = Registro Invalido        ³
	//³0 = Registro Valido          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TAFAltStat("CFY", IIf( Len(aLogErro)>0, '1', '0' ) )
	
Else
	AADD(aLogErro,{"CFY_ID","000017", "CFY", nRecno }) //STR0017 - "Registro ja valido"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	//xValLogEr(aLogErro)
	VldECFLog(aLogErro)
EndIf

Return(aLogErro) 

//-------------------------------------------------------------------
/*/{Protheus.doc} VerifCFY
Função statica para verificar na CFY a regra abaixo:
REGRA_OPCAO_REGIME: Verifica, quando X340.IND_CONTROLE igual a “10”, se não existe outro registro X340 com
X340.IND_CONTROLE igual a “4” ou “6”. Verifica, quando X340.IND_CONTROLE igual a “4” ou “6”, se não existe outro registro X340 com
X340.IND_CONTROLE igual a “10”.

@author Henrique Pereira
@since 05/04/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VerifCFY(nOpc)
Local lRet 	:= .F.
Local aGetCFY	:= CFY->(GetArea())

CFY->(DBSetOrder(3))// Indice novo, apartir do leiaute 3
If nOpc == 1 
	If CFY->(DbSeek(xFilial("CFY")+"4")) .Or. CFY->(DbSeek(xFilial("CFY")+"6"))
		lRet := .T.
	EndIf
EndIf

If nOpc == 2
 	If CFY->(DbSeek(xFilial("CFY")+"10"))
		lRet := .T.
	EndIf	
EndIf

CFY->(RestArea(aGetCFY))

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} Ecf50BlX

Rotina para verificar se existem os campos utilizados no ECF layout 5.0

@Param

@Author Denis Souza
@Since 26/04/2019
@Version 1.0
/*/
//---------------------------------------------------------------------
Function Ecf50BlX()

	Local aGetArea := GetArea()
	Local lEcf50  := .F.

	If AliasIndic("V3M") .And. Empty(Select("V3M"))
		DbSelectArea("V3M")
		V3M->(DbSetOrder(1))
	endif

	If AliasIndic("CHN") .And. Empty(Select("CHN"))
		DbSelectArea("CHN")
		CHN->(DbSetOrder(1))
	endif

	If TafColumnPos("V3M_SEQ") .And. TafColumnPos( "V3M_PAIS" ) .And. TafColumnPos( "V3M_NIF" ) .And. TafColumnPos( "V3M_RAZSOC" ) ;
	.And. TafColumnPos( "V3M_PERCPI" ) .And. TafColumnPos( "CHN_RPROP" ) .And. TafColumnPos( "CHN_RPREAL" )
		lEcf50 := .T.
	endif

	RestArea(aGetArea)

Return lEcf50