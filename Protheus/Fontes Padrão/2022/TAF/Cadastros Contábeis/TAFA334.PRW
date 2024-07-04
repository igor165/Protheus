#INCLUDE "TOTVS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA334.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA334
Cadastro MVC de Operacoes com o Exterior - Exportações (Entradas de Divisas)

@author Roger Cangianeli
@since 10/06/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA334
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription(STR0001)//Operacoes com o Exterior - Exportações (Entradas de Divisas)
oBrw:SetAlias( 'CAY')
oBrw:SetMenuDef( 'TAFA334' )
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

Aadd( aFuncao, { "" , "Taf334Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA334" , , aFuncao)

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
Local oStruCAY 	:= 	FWFormStruct( 1, 'CAY' ) 
Local oStruCAZ 	:= 	FWFormStruct( 1, 'CAZ' )
Local oStruV6R 	:= 	FWFormStruct( 1, 'V6R' )
Local oModel	:= MPFormModel():New( 'TAFA334',,{ |oModel| ValidModel( oModel ) } ,{|oModel| SaveModel(oModel)})
Local bPost 	:= { || TafVldAj(@oModel)}

oModel:AddFields('MODEL_CAY', /*cOwner*/, oStruCAY)

//Contratantes das Exportações
oModel:AddGrid('MODEL_CAZ', 'MODEL_CAY', oStruCAZ)
oModel:GetModel( 'MODEL_CAZ' ):SetUniqueLine({'CAZ_NOME'})  
oModel:GetModel( 'MODEL_CAZ' ):SetOptional( .T. )

//Ajustes do preço da Exportação.
oModel:AddGrid('MODEL_V6R', 'MODEL_CAY', oStruV6R,,,, bPost )
oModel:GetModel( 'MODEL_V6R' ):SetOptional( .T. )

oModel:GetModel( "MODEL_CAY" ):SetPrimaryKey({ "CAY_PERIOD","CAY_NUMORD" })

oModel:SetRelation("MODEL_CAZ",{ {"CAZ_FILIAL","xFilial('CAZ')"}, {"CAZ_ID","CAY_ID"} },CAZ->( IndexKey(1)) )
oModel:SetRelation("MODEL_V6R",{ {"V6R_FILIAL","xFilial('V6R')"}, {"V6R_ID","CAY_ID"} },V6R->( IndexKey(1)) )                                                                               


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
Local oModel 	:= 	FWLoadModel( 'TAFA334' )
Local oStruCAY 	:= 	FWFormStruct( 2, 'CAY' )
Local oStruCAZ 	:= 	FWFormStruct( 2, 'CAZ' )
Local oStruV6R 	:= 	FWFormStruct( 2, 'V6R' )

Local oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_CAY', oStruCAY, 'MODEL_CAY' )
oView:EnableTitleView( 'VIEW_CAY', STR0001) //Operacoes da atividade imobiliaria - Unidade imobiliaria vendida

oView:AddGrid ( 'VIEW_CAZ', oStruCAZ, 'MODEL_CAZ' )
oView:AddGrid ( 'VIEW_V6R', oStruV6R, 'MODEL_V6R' )

oView:CreateHorizontalBox( 'FIELDSCAY', 60 )          
oView:CreateHorizontalBox( 'FOLDERGERAL', 40 )

oView:CreateFolder( 'FOLDER1', 'FOLDERGERAL' )

oView:AddSheet( 'FOLDER1', 'ABA01', STR0002) //Contratantes das Exportações
oView:CreateHorizontalBox( 'GRIDCAZ', 100,,, 'FOLDER1', 'ABA01' )

oView:AddSheet( 'FOLDER1', 'ABA02', STR0003) //Ajustes do Preço Parâmetro da Exportação
oView:CreateHorizontalBox( 'GRIDV6R', 100,,, 'FOLDER1', 'ABA02' )

oView:SetVldFolder({|cFldID, nOldSheet, nSelSheet| VldFldAju(cFldID, nOldSheet, nSelSheet)})

oView:AddIncrementField( 'VIEW_CAZ', 'CAZ_IDINC' )
oView:AddIncrementField( 'VIEW_V6R', 'V6R_NUMITE' )

oStruCAY:RemoveField('CAY_ID')
oStruCAY:RemoveField('CAY_IDFCOT')
oStruV6R:RemoveField('V6R_FILIAL')
oStruV6R:RemoveField('V6R_ID')
oStruV6R:RemoveField('V6R_IDTPAJ')


oView:SetOwnerView( 'VIEW_CAY', 'FIELDSCAY' )
oView:SetOwnerView( 'VIEW_CAZ', 'GRIDCAZ' )
oView:SetOwnerView( 'VIEW_V6R', 'GRIDV6R' )

oStruCAY:RemoveField( "CAY_IDCNC" )
oStruCAY:RemoveField( "CAY_IDMOED" )

oStruCAY:SetProperty( "CAY_PERIOD"	, MVC_VIEW_ORDEM, "03" )
oStruCAY:SetProperty( "CAY_NUMORD"	, MVC_VIEW_ORDEM, "04" )
oStruCAY:SetProperty( "CAY_TIPEXP"	, MVC_VIEW_ORDEM, "05" )
oStruCAY:SetProperty( "CAY_DESCRI"  , MVC_VIEW_ORDEM, "06" )
oStruCAY:SetProperty( "CAY_TOTOPE"  , MVC_VIEW_ORDEM, "07" )
oStruCAY:SetProperty( "CAY_CODCNC"  , MVC_VIEW_ORDEM, "08" )
oStruCAY:SetProperty( "CAY_DCODNC"	, MVC_VIEW_ORDEM, "09" )
oStruCAY:SetProperty( "CAY_QUANTI"	, MVC_VIEW_ORDEM, "10" )
oStruCAY:SetProperty( "CAY_UNIDAD"  , MVC_VIEW_ORDEM, "11" )
oStruCAY:SetProperty( "CAY_DUNIDA"  , MVC_VIEW_ORDEM, "12" )
oStruCAY:SetProperty( "CAY_INDOPE"	, MVC_VIEW_ORDEM, "13" )
oStruCAY:SetProperty( "CAY_TIPMET"	, MVC_VIEW_ORDEM, "14" )
oStruCAY:SetProperty( "CAY_VLPAR" 	, MVC_VIEW_ORDEM, "15" )
oStruCAY:SetProperty( "CAY_VLPRAT"  , MVC_VIEW_ORDEM, "16" )
oStruCAY:SetProperty( "CAY_VLAJ"	, MVC_VIEW_ORDEM, "17" )
oStruCAY:SetProperty( "CAY_TXJUR"	, MVC_VIEW_ORDEM, "18" )
oStruCAY:SetProperty( "CAY_TXJMIN"  , MVC_VIEW_ORDEM, "19" )
oStruCAY:SetProperty( "CAY_TXJMAX"  , MVC_VIEW_ORDEM, "20" )
oStruCAY:SetProperty( "CAY_CODCNC"	, MVC_VIEW_ORDEM, "21" )
oStruCAY:SetProperty( "CAY_DCCNC"	, MVC_VIEW_ORDEM, "22" )
oStruCAY:SetProperty( "CAY_MOEDA"	, MVC_VIEW_ORDEM, "23" )
oStruCAY:SetProperty( "CAY_DMOEDA"	, MVC_VIEW_ORDEM, "24" )
oStruCAY:SetProperty( "CAY_TPOPER"	, MVC_VIEW_ORDEM, "25" )
oStruCAY:SetProperty( "CAY_DESCPA"	, MVC_VIEW_ORDEM, "26" )
oStruCAY:SetProperty( "CAY_IDPAEN"	, MVC_VIEW_ORDEM, "27" )
oStruCAY:SetProperty( "CAY_TPBEM"	, MVC_VIEW_ORDEM, "28" )
oStruCAY:SetProperty( "CAY_DTUTIL"	, MVC_VIEW_ORDEM, "29" )
oStruCAY:SetProperty( "CAY_DESCME"	, MVC_VIEW_ORDEM, "30" )
oStruCAY:SetProperty( "CAY_DTNEGC"	, MVC_VIEW_ORDEM, "31" )
oStruCAY:SetProperty( "CAY_DTEMBQ"	, MVC_VIEW_ORDEM, "32" )
oStruCAY:SetProperty( "CAY_AJUPAR"	, MVC_VIEW_ORDEM, "33" )
oStruCAY:SetProperty( "CAY_QTDAJU"	, MVC_VIEW_ORDEM, "34" )
oStruCAY:SetProperty( "CAY_VLRCOT"	, MVC_VIEW_ORDEM, "35" )
oStruCAY:SetProperty( "CAY_NUMDEC"	, MVC_VIEW_ORDEM, "36" )
oStruCAY:SetProperty( "CAY_DTENPR"	, MVC_VIEW_ORDEM, "37" )
oStruCAY:SetProperty( "CAY_CODFCO"	, MVC_VIEW_ORDEM, "38" )
oStruCAY:SetProperty( "CAY_DESFCO"	, MVC_VIEW_ORDEM, "39" )

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

Local	cCNPJ 	:= 	oModel:GetValue( 'MODEL_CAY' , 'CAY_CNPJ' )
Local	cCPF 	:= 	oModel:GetValue( 'MODEL_CAY' , 'CAY_CPF' )
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
		TAFAltStat( "CAY", " " )
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} TAF334Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 19/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF334Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}
Local cChave		:= ""
Local cCAZKey		:= ""
Local nTotOper	:= 0
Local cUnidad		:= ''
Local cIdUnECF   := 0

If CAY->CAY_STATUS $ ( " 1" )

	//Valida o Periodo informado
	If Empty(CAY->CAY_PERIOD)
		Aadd( aLogErro, { "CAY_PERIOD", "000003", "CAY", nRecno } ) //STR0003 - "Data inconsistente ou vazia."
	EndIf

	//Valida o Numero de Ordem das Operações
	If Empty(CAY->CAY_NUMORD)
		Aadd( aLogErro, { "CAY_NUMORD", "000001", "CAY", nRecno } ) //STR0001 - "Campo Inconsistente ou Vazio."
	EndIf

	//Valida o Tipo de Exportação
	If Empty(CAY->CAY_TIPEXP)
		Aadd( aLogErro, { "CAY_TIPEXP", "000001", "CAY", nRecno } ) //STR0001 - "Campo Inconsistente ou Vazio."
	Else
		If !CAY->CAY_TIPEXP $ '01|02|03|04|05'
			Aadd( aLogErro, { "CAY_TIPEXP", "000002", "CAY", nRecno } ) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
		EndIf
	EndIf	
	
	//Valida o Código NCM
	If ! Empty(CAY->CAY_CODNCM)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := CAY->CAY_CODNCM
		xVldECFTab("C0A",cChave,3,,@aLogErro,{ "CAY","CAY_CODNCM", nRecno })
	EndIf
	
	//Valida A Unidade de Medida 
	If ! Empty(CAY->CAY_UNIDAD)
		cIdUnECF := Posicione("C1J",3,xFilial("C1J")+CAY->CAY_UNIDAD,"C1J_IDUMEC")   
		cUnidad  := Posicione("CHJ",1,xFilial("CHJ")+cIdUnECF ,"CHJ_CODIGO")   
			
		If !AllTrim(cUnidad) $ '01|02|03|04|05|06|07|08|09|10|11|12|13|14|15'
			Aadd( aLogErro, { "CAY_UNIDAD", "000002", "CAY", nRecno } ) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
		Else	
			//Chave de busca na tabela FILHO ou Consulta padrao
			cChave := CAY->CAY_UNIDAD
			xVldECFTab("C1J",cChave,3,,@aLogErro,{ "CAY","CAY_UNIDAD", nRecno })
		EndIf
	
	EndIf
	
	//Valida a Operação Sujeita a Arbitramento
	If ! Empty(CAY->CAY_INDOPE)
		If !CAY->CAY_INDOPE $ '1|2'
			Aadd( aLogErro, { "CAY_INDOPE", "000002", "CAY", nRecno } ) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
		EndIf
	EndIf

	
	//Valida o Método
	If ! Empty(CAY->CAY_TIPMET)
		If !CAY->CAY_TIPMET $ '1|2|3|4|5'
			Aadd( aLogErro, { "CAY_TIPMET", "000002", "CAY", nRecno } ) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
		EndIf
	EndIf	

	/*/
	"REGRA_TIP_EXP_123_OBRIGATORIO: Verifica se DESC_EXP (Campo 04) está preenchido quando
	TIP_EXP (Campo 03) igual a “1” (bens) ou “2” (serviços) ou “3” (direitos)."
	/*/
	If CAY->CAY_TIPEXP $ '01|02|03' .and. Empty(CAY->CAY_DESCRI)
		Aadd( aLogErro, { "CAY_DESCRI", "000001", "CAY", nRecno } ) //STR0001 - Campo Inconsistente ou Vazio
	EndIf
	
	/*/
	"REGRA_TOT_OPER_OBRIGATORIO_X300: Verifica se TOT_OPER (Campo 05) está preenchido quando
	TIP_EXP (Campo 03) igual a “1” (bens) ou “2” (serviços) ou “3” (direitos) ou “5” (não especificadas)."
	/*/
	If CAY->CAY_TIPEXP $ '01|02|03|05' .and. CAY->CAY_TOTOPE == 0
		Aadd( aLogErro, { "CAY_TOTOPE", "000001", "CAY", nRecno } ) //STR0001 - Campo Inconsistente ou Vazio
	EndIf


	If CAY->CAY_TIPEXP == '01' 
		/*/
		"REGRA_OBRIGATORIO_BENS: Verifica se COD_NCM (Campo 06) está preenchido quando TIP_EXP
		(Campo 03) igual a “1” (bens)."
		/*/
		If Empty(CAY->CAY_CODNCM)
			Aadd( aLogErro, { "CAY_CODNCM", "000001", "CAY", nRecno } ) //STR0001 - Campo Inconsistente ou Vazio
		EndIf
		
		/*/
		"REGRA_OBRIGATORIO_BENS: Verifica se QTDE (Campo 07) está preenchido quando TIP_EXP
		(Campo 03) igual a “1” (bens)."
		/*/
		If CAY->CAY_QUANTI <= 0
			Aadd( aLogErro, { "CAY_QUANTI", "000001", "CAY", nRecno } ) //STR0001 - Campo Inconsistente ou Vazio
		EndIf
		
		/*/
		"REGRA_OBRIGATORIO_BENS: Verifica se UNI_MED (Campo 08) está preenchido quando TIP_EXP
		(Campo 03) igual a “1” (bens)."
		/*/
		If Empty(CAY->CAY_UNIDAD)
			Aadd( aLogErro, { "CAY_UNIDAD", "000001", "CAY", nRecno } ) //STR0001 - "Campo Inconsistente ou Vazio."
		EndIf

	EndIf

	If CAY->CAY_TIPEXP $ '01|02|03'
		/*/
		"REGRA_TIP_EXP_123_OBRIGATORIO: Verifica se IND_OPER (Campo 09) está preenchido quando
		TIP_EXP (Campo 03) igual a “1” (bens) ou “2” (serviços) ou “3” (direitos)."
		/*/
		If Empty(CAY->CAY_INDOPE)
			Aadd( aLogErro, { "CAY_INDOPE", "000001", "CAY", nRecno } ) //STR0001 - Campo Inconsistente ou Vazio
		EndIf
	
		/*/
		"REGRA_IND_OPER_OBRIGATORIO: Verifica se TIP_MET (Campo 10) está preenchido quando
		TIP_EXP (Campo 03) igual a “1” (bens) ou “2” (serviços) ou “3” (direitos) e IND_OPER (Campo 09) igual
		a “S” (operação suJeita a arbitramento)."
		/*/	
		If CAY->CAY_INDOPE $ '1' .And. Empty(CAY->CAY_TIPMET)
			Aadd( aLogErro, { "CAY_TIPMET", "000001", "CAY", nRecno } ) //STR0001 - Campo Inconsistente ou Vazio
		EndIf
	
		/*/
		"REGRA_IND_OPER_OBRIGATORIO: Verifica se VL_PAR (Campo 11) está preenchido quando 
		TIP_EXP (Campo 03) igual a “1” (bens) ou “2” (serviços) ou “3” (direitos) e IND_OPER (Campo 09) igual 
		a “S” (operação sujeita a arbitramento).
		/*/
		If CAY->CAY_INDOPE $ '1' .AND. CAY->CAY_VLPAR <= 0
			Aadd( aLogErro, { "CAY_VLPAR", "000001", "CAY", nRecno } ) //STR0001 - Campo Inconsistente ou Vazio
		EndIf
		
		/*/
		"REGRA_IND_OPER_OBRIGATORIO: Verifica se VL_PRAT (Campo 12) está preenchido quando
		TIP_EXP (Campo 03) igual a “1” (bens) ou “2” (serviços) ou “3” (direitos) e IND_OPER (Campo 09) igual
		a “S” (operação suJeita a arbitramento)."
		/*/
		If CAY->CAY_INDOPE $ '1' .AND. CAY->CAY_VLPRAT <= 0
			Aadd( aLogErro, { "CAY_VLPRAT", "000001", "CAY", nRecno } ) //STR0001 - Campo Inconsistente ou Vazio
		EndIf
	EndIf
		
	If CAY->CAY_VLAJ <= 0	
		/*/
		"REGRA_IND_OPER_OBRIGATORIO: Verifica se VL_AJ (Campo 13) está preenchido quando
		TIP_EXP (Campo 03) igual a “1” (bens) ou “2” (serviços) ou “3” (direitos) e IND_OPER (Campo 09) igual
		a “S” (operação suJeita a arbitramento).
	
		REGRA_TIP_EXP_45_OBRIGATORIO: Verifica se VL_AJ (Campo 13) está preenchido quando
		TIP_EXP (Campo 03) igual a “4” (operações financeiras) ou “5” (não especificadas)."
		/*/
		If (CAY->CAY_TIPEXP $ '01|02|03' .and. CAY->CAY_INDOPE $ '1') .OR. CAY->CAY_TIPEXP $ '04|05' 
			Aadd( aLogErro, { "CAY_VLAJ", "000001", "CAY", nRecno } ) //STR0001 - Campo Inconsistente ou Vazio
		EndIf
	EndIf
		

	If CAY->CAY_TIPEXP $ '04'
		/*/
		"REGRA_TIP_EXP_4_OBRIGATORIO: Verifica se VL_JUR (Campo 14) está preenchido quando
		TIP_EXP (Campo 03) igual a “4” (operações financeiras)."
		/*/
		If CAY->CAY_TXJUR <= 0
			Aadd( aLogErro, { "CAY_TXJUR", "000001", "CAY", nRecno } ) //STR0001 - Campo Inconsistente ou Vazio
		EndIf
		
		/*/
		"REGRA_VL_JUR_MIN_OBRIGATORIO_X300: Verifica se VL_JUR_MIN (Campo 15) está preenchido quando
		TIP_EXP (Campo 03) igual a “4” (operações financeiras)."
		/*/
		If CAY->CAY_TXJMIN <= 0
			Aadd( aLogErro, { "CAY_TXJMIN", "000001", "CAY", nRecno } ) //STR0001 - Campo Inconsistente ou Vazio
		EndIf
		
		/*/
		"REGRA_ VL_JUR_MAX _OBRIGATORIO_X300: Verifica se VL_JUR_MAX (Campo 16) está preenchido
		quando TIP_EXP (Campo 03) igual a “4” (operações financeiras)."
		/*/
		If CAY->CAY_TXJMAX <= 0
			Aadd( aLogErro, { "CAY_TXJMAX", "000001", "CAY", nRecno } ) //STR0001 - Campo Inconsistente ou Vazio
		EndIf
		
		/*/
		"REGRA_TIP_EXP_4_OBRIGATORIO: Verifica se COD_CNC (Campo 17) está preenchido quando
		TIP_EXP (Campo 03) igual a “4” (operações financeiras)."
		/*/

		If Empty(CAY->CAY_IDCNC)
			Aadd( aLogErro, { "CAY_CODCNC", "000001", "CAY", nRecno } ) //STR0001 - Campo Inconsistente ou Vazio
	    Else
			xVldECFTab("CZT",CAY->CAY_IDCNC,1,,@aLogErro,{"CAY","CAY_CODCNC",nRecno })
	    EndIf	
			
		/*/
		"REGRA_TIP_EXP_4_OBRIGATORIO: Verifica se TIP_MOEDA (Campo 18) está preenchido quando
		TIP_EXP (Campo 03) igual a “4” (operações financeiras)."
		/*/
		
		If Empty(CAY->CAY_IDMOED)
			Aadd( aLogErro, {"CAY_MOEDA", "000001", "CAY", nRecno }) //STR0001 - Campo Inconsistente ou Vazio
	    Else
			xVldECFTab("CZU",CAY->CAY_IDMOED,1,,@aLogErro,{"CAY","CAY_MOEDA",nRecno })
	    EndIf	
		
	EndIf	

	//ÚÄÄÄÄÄÄÄÄÄÄ¿
	//³INICIO CAZ³
	//ÀÄÄÄÄÄÄÄÄÄÄÙ
	CAZ->( DBSetOrder(1) )
	cCAZKey := CAY->CAY_ID
	If CAZ->( MsSeek( xFilial("CAZ") + cCAZKey ) )

		Do While !CAZ->( Eof() ) .And. cCAZKey == CAZ->CAZ_ID

			//---------------------
			// Campos obrigatórios
			//---------------------
			If Empty(CAZ->CAZ_NOME)
				AADD(aLogErro,{"CAZ_NOME","000001", "CAZ",nRecno }) //STR0001 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If CAZ->CAZ_VLOPER <= 0
				AADD(aLogErro,{"CAZ_VLOPER","000001", "CAZ",nRecno }) //STR0001 - "Campo Inconsistente ou Vazio"
			Else
				nTotOper += CAZ->CAZ_VLOPER
			EndIf
			
			If Empty(CAZ->CAZ_CONDPE)
				AADD(aLogErro,{"CAZ_CONDPE","000001", "CAZ",nRecno }) //STR0001 - "Campo Inconsistente ou Vazio"
			Else	
				If !CAZ->CAZ_CONDPE $ '01|02|03'
					AADD(aLogErro,{"CAZ_CONDPE","000002", "CAZ",nRecno }) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
				EndIf
			EndIf
			
			//------------------
			// Consultas padrão
			//------------------
			If Empty(CAZ->CAZ_PAIS)
				AADD(aLogErro,{"CAZ_PAIS","000001", "CAZ",nRecno }) //STR0001 - "Campo Inconsistente ou Vazio"
			Else		
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := CAZ->CAZ_PAIS
				xValRegTab("C08",cChave,3,,@aLogErro,)
			EndIf	
		

			CAZ->( DbSkip() )
		EndDo
		/*/			
		REGRA_SOMATORIA_VALOR_OPERACAO: Verifica se o somatório dos registros filhos X310.VL_OPER  é igual a TOT_OPER (Campo 04). 
		Se a regra não for cumprida, o sistema gera um aviso.  
		If CAY->CAY_TOTOPE # nTotOper
			AADD(aLogErro,{"CAY_TOTOPE","000011", "CAZ",nRecno }) //STR0011 - "A totalização do campo nos Registros Filhos não confere com o total no Registro Pai."		
		EndIf
		/*/

		/*/
		REGRA_X310_NAO_PREENCHIDO: Verifica se, para cada registro X300 preenchido, existe pelo menos um registro X310 preenchido. 
		Se a regra não for cumprida, o sistema gera um aviso. 
			AADD(aLogErro,{"CAZ_NOME","000001", "CAZ",nRecno }) //STR0001 - "Campo Inconsistente ou Vazio"
		/*/
		
	EndIf
	//ÚÄÄÄÄÄÄÄ¿
	//³FIM CAZ³
	//ÀÄÄÄÄÄÄÄÙ
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ATUALIZO O STATUS DO REGISTRO³
	//³1 = Registro Invalido        ³
	//³0 = Registro Valido          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TAFAltStat("CAY", IIf( Len(aLogErro)>0, '1', '0' ) )
	
Else
	AADD(aLogErro,{"CAY_ID","000017", "CAY", nRecno })//STR0017 - "Registro já validado"
	
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
/*/{Protheus.doc} VldTpAj()
Função para validar os ajustes de preço informado.

@author Carlos Eduardo
@since 20/04/2021
@version 1.0

/*/
//-------------------------------------------------------------------
Function TafVldAj(oModel)
Local lRet := .t.
Local i := 0
Local j := 0
Local cTable := iif(IsInCallStack('TAFA334'),'V6R','V6S' )
Local oModelTpAj := oModel:GetModel('MODEL_'+cTable)
Local nLinhas := oModelTpAj:length()

if nLinhas > 1
	for i := 1 to nLinhas
		if !lRet; exit; endif
		oModelTpAj:GoLine(i)
		if oModelTpAj:GetValue(cTable+'_TPAJUS') != '99' 
			for j := i+1 to nLinhas
				if !oModelTpAj:IsDeleted(j) .and. oModelTpAj:GetValue(cTable+'_TPAJUS') == oModelTpAj:GetValue(cTable+'_TPAJUS',j) 
					lRet := .f.
					//alert('O unico tipo de ajuste que pode se repetir é o 99')
					oModel:SetErrorMessage(,,,,, STR0004 + CRLF + CRLF + STR0005) //Os tipos de ajuste de preço cadastrados não devem se repetir.# Por favor, verifique o cadastro e agrupe os valores manualmente se necessário.
					exit
				endif
			next
		endif	
	next
endif		

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} VldTpAj()
Função para validar se o ajustes de preço podem ser cadastrados

@author Carlos Eduardo
@since 26/04/2021
@version 1.0

/*/
//-------------------------------------------------------------------
Function VldFldAju(cFldID, nOldSheet, nSelSheet)
Local lRet 	  := .t.
Local cCmpVld := iif(IsInCallStack('TAFA334'),'CAY','CFV') + '_AJUPAR'
Local cTitCmp := iif(IsInCallStack('TAFA334'),'Ajust. Param','Aj. Preço Pa')

if nSelSheet = 2 .and. FwFldGet(cCmpVld) != 'S'
	Help( ,,STR0006,, STR0007 +' "'+cTitCmp+'" '+STR0008, 1, 0 ) //Ajuste de Preço # Para cadastrar os ajustes de preço, o campo # deve estar preenchido com "S-Sim"
	lRet := .F.
EndIf
   
Return lRet
