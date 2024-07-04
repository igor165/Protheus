#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA335.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA335
Cadastro MVC de Operacoes com o Exterior - Importações (Entradas de Divisas)

@author Roger Cangianeli
@since 10/06/2014
@version 1.0

/*/   
//-------------------------------------------------------------------
Function TAFA335
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription(STR0001)//Operacoes com o Exterior - Importações (Entradas de Divisas)
oBrw:SetAlias( 'CFV')
oBrw:SetMenuDef( 'TAFA335' )
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

Aadd( aFuncao, { "" , "Taf335Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA335" , , aFuncao)

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
Local oStruCFV 	:= 	FWFormStruct( 1, 'CFV' ) 
Local oStruCFX 	:= 	FWFormStruct( 1, 'CFX' )
Local oStruV6S 	:= 	FWFormStruct( 1, 'V6S' )
Local oModel	:= MPFormModel():New( 'TAFA335',,{ |oModel| ValidModel( oModel ) } ,{|oModel| SaveModel(oModel)})
Local bPost 	:= { || TafVldAj(@oModel)}

oModel:AddFields('MODEL_CFV', /*cOwner*/, oStruCFV)

oModel:AddGrid( 'MODEL_CFX', 'MODEL_CFV', oStruCFX)
oModel:GetModel( 'MODEL_CFX' ):SetUniqueLine({'CFX_NOME'})
oModel:GetModel( 'MODEL_CFX' ):SetOptional( .T. ) 

oModel:AddGrid( 'MODEL_V6S', 'MODEL_CFV', oStruV6S,,,,bPost)
oModel:GetModel( 'MODEL_V6S' ):SetOptional( .T. ) 

oModel:GetModel( 'MODEL_CFV' ):SetPrimaryKey({ 'CFV_PERIOD','CFV_NUMORD' })    

oModel:SetRelation("MODEL_CFX",{ {"CFX_FILIAL","xFilial('CFX')"}, {"CFX_ID","CFV_ID"} },CFX->( IndexKey(1)) )
oModel:SetRelation("MODEL_V6S",{ {"V6S_FILIAL","xFilial('V6S')"}, {"V6S_ID","CFV_ID"} },V6S->( IndexKey(1)) )

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
Local oModel 	:= 	FWLoadModel( 'TAFA335' )
Local oStruCFV 	:= 	FWFormStruct( 2, 'CFV' )
Local oStruCFX 	:= 	FWFormStruct( 2, 'CFX' )
Local oStruV6S 	:= 	FWFormStruct( 2, 'V6S' )

Local oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_CFV', oStruCFV, 'MODEL_CFV' )
oView:EnableTitleView( 'VIEW_CFV', STR0001) //Operacoes da atividade imobiliaria - Unidade imobiliaria vendida

oView:AddGrid ( 'VIEW_CFX', oStruCFX, 'MODEL_CFX' )
oView:AddGrid ( 'VIEW_V6S', oStruV6S, 'MODEL_V6S' )

oView:CreateHorizontalBox( 'FIELDSCFV', 60 )          
oView:CreateHorizontalBox( 'FOLDERGERAL', 40 )

oView:CreateFolder( 'FOLDER1', 'FOLDERGERAL' )

oView:AddSheet( 'FOLDER1', 'ABA01', STR0002) //Contratantes das Importações
oView:CreateHorizontalBox( 'GRIDCFX', 100,,, 'FOLDER1', 'ABA01' )

oView:AddSheet( 'FOLDER1', 'ABA02', STR0003) //Ajustes do Preço Parâmetro da Importação
oView:CreateHorizontalBox( 'GRIDV6S', 100,,, 'FOLDER1', 'ABA02' )

oView:AddIncrementField( 'VIEW_CFX', 'CFX_IDINC' )
oView:AddIncrementField( 'VIEW_V6S', 'V6S_NUMITE' )

oView:SetVldFolder({|cFldID, nOldSheet, nSelSheet| VldFldAju(cFldID, nOldSheet, nSelSheet)})

oStruCFV:RemoveField('CFV_ID')
oStruCFV:RemoveField( "CFV_IDCNC" )
oStruCFV:RemoveField( "CFV_IDMOED" )
oStruCFV:RemoveField( "CFV_IDFOCO" )
oStruCFV:RemoveField( "CFV_IDITEM" )
oStruV6S:RemoveField('V6S_FILIAL')
oStruV6S:RemoveField('V6S_ID')
oStruV6S:RemoveField('V6S_IDTPAJ')

oView:SetOwnerView( 'VIEW_CFV', 'FIELDSCFV' )
oView:SetOwnerView( 'VIEW_CFX', 'GRIDCFX' )
oView:SetOwnerView( 'VIEW_V6S', 'GRIDV6S' )

oStruCFV:SetProperty( "CFV_PERIOD"	, MVC_VIEW_ORDEM, "03" )
oStruCFV:SetProperty( "CFV_NUMORD"	, MVC_VIEW_ORDEM, "04" )
oStruCFV:SetProperty( "CFV_TIPEXP"	, MVC_VIEW_ORDEM, "05" )
oStruCFV:SetProperty( "CFV_DESCRI"  , MVC_VIEW_ORDEM, "06" )
oStruCFV:SetProperty( "CFV_TOTOPE"  , MVC_VIEW_ORDEM, "07" )
oStruCFV:SetProperty( "CFV_CODCNC"  , MVC_VIEW_ORDEM, "08" )
oStruCFV:SetProperty( "CFV_DCODNC"	, MVC_VIEW_ORDEM, "09" )
oStruCFV:SetProperty( "CFV_QUANTI"	, MVC_VIEW_ORDEM, "10" )
oStruCFV:SetProperty( "CFV_UNIDAD"  , MVC_VIEW_ORDEM, "11" )
oStruCFV:SetProperty( "CFV_DUNIDA"  , MVC_VIEW_ORDEM, "12" )
oStruCFV:SetProperty( "CFV_TIPMET"	, MVC_VIEW_ORDEM, "13" )
oStruCFV:SetProperty( "CFV_VLPAR" 	, MVC_VIEW_ORDEM, "14" )
oStruCFV:SetProperty( "CFV_VLPRAT"  , MVC_VIEW_ORDEM, "15" )
oStruCFV:SetProperty( "CFV_VLAJ"	, MVC_VIEW_ORDEM, "16" )
oStruCFV:SetProperty( "CFV_TXJUR"	, MVC_VIEW_ORDEM, "17" )
oStruCFV:SetProperty( "CFV_TXJMIN"  , MVC_VIEW_ORDEM, "18" )
oStruCFV:SetProperty( "CFV_TXJMAX"  , MVC_VIEW_ORDEM, "19" )
oStruCFV:SetProperty( "CFV_CODCNC"	, MVC_VIEW_ORDEM, "20" )
oStruCFV:SetProperty( "CFV_DCCNC"	, MVC_VIEW_ORDEM, "21" )
oStruCFV:SetProperty( "CFV_MOEDA"	, MVC_VIEW_ORDEM, "22" )
oStruCFV:SetProperty( "CFV_DMOEDA"	, MVC_VIEW_ORDEM, "23" )
oStruCFV:SetProperty( "CFV_CODINV"	, MVC_VIEW_ORDEM, "24" )
oStruCFV:SetProperty( "CFV_DESINV"	, MVC_VIEW_ORDEM, "25" )
oStruCFV:SetProperty( "CFV_UTINPR"	, MVC_VIEW_ORDEM, "26" )
oStruCFV:SetProperty( "CFV_OPAPPA"	, MVC_VIEW_ORDEM, "27" )
oStruCFV:SetProperty( "CFV_DESPAR"	, MVC_VIEW_ORDEM, "28" )
oStruCFV:SetProperty( "CFV_IDPAEN"	, MVC_VIEW_ORDEM, "29" )
oStruCFV:SetProperty( "CFV_TPPAR"	, MVC_VIEW_ORDEM, "30" )
oStruCFV:SetProperty( "CFV_DTUTIL"	, MVC_VIEW_ORDEM, "31" )
oStruCFV:SetProperty( "CFV_CRIDET"	, MVC_VIEW_ORDEM, "32" )
oStruCFV:SetProperty( "CFV_DTTRAN"	, MVC_VIEW_ORDEM, "33" )
oStruCFV:SetProperty( "CFV_DTDUIM"	, MVC_VIEW_ORDEM, "34" )
oStruCFV:SetProperty( "CFV_AJUPAR"	, MVC_VIEW_ORDEM, "35" )
oStruCFV:SetProperty( "CFV_QTDAJU"	, MVC_VIEW_ORDEM, "36" )
oStruCFV:SetProperty( "CFV_VLRCOT"	, MVC_VIEW_ORDEM, "37" )
oStruCFV:SetProperty( "CFV_NUMDEC"	, MVC_VIEW_ORDEM, "38" )
oStruCFV:SetProperty( "CFV_DTENPR"	, MVC_VIEW_ORDEM, "39" )
oStruCFV:SetProperty( "CFV_CODCOT"	, MVC_VIEW_ORDEM, "40" )
oStruCFV:SetProperty( "CFV_DESCOT"	, MVC_VIEW_ORDEM, "41" )

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

Local	cCNPJ 	:= 	oModel:GetValue( 'MODEL_CFV' , 'CFV_CNPJ' )
Local	cCPF 	:= 	oModel:GetValue( 'MODEL_CFV' , 'CFV_CPF' )
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
		TAFAltStat( "CFV", " " )
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} TAF335Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 19/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF335Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}
Local cChave		:= ""
Local cCFXKey		:= ""
Local nTotOper	:= 0
Local cUnidad		:= ""
Local cIdUnECF	:= ""
Local idPerido	:= ""
Local cPerini 	:= ""
Local cPerfim		:= ""
Local cAliasQry   := GetNextAlias()
Local cQuery		:= ""

If CFV->CFV_STATUS $ ( " 1" )
		
	// Valida o Periodo informado
	If Empty(CFV->CFV_PERIOD)
		Aadd( aLogErro, { "CFV_PERIOD", "000003", "CFV", nRecno } ) //STR0003 - "Data inconsistente ou vazia."
	EndIf

	// Valida o Numero de Ordem das Operações
	If Empty(CFV->CFV_NUMORD)
		Aadd( aLogErro, { "CFV_NUMORD", "000001", "CFV", nRecno } ) //STR0001 - Campo Inconsistente ou Vazio
	EndIf

	// Valida o Tipo de Exportação
	If Empty(CFV->CFV_TIPEXP)
		Aadd( aLogErro, { "CFV_TIPEXP", "000001", "CFV", nRecno } ) //STR0001 - "Campo Inconsistente ou Vazio."
	
	ElseIf !CFV->CFV_TIPEXP $ '01|02|03|04|05'
		Aadd( aLogErro, { "CFV_TIPEXP", "000002", "CFV", nRecno } ) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
	
	Elseif CFV->CFV_TIPEXP == '05' //REGRA_UM_REGISTRO_X320
		idPerido:= TAFEcfPer(CFV->CFV_PERIOD)	//encontra o ID do período de abertura ao qual se refere o período do registro	
		If !Empty(idPerido)
			dbSelectArea("CHD")
			CHD->(dbSetOrder(1))
			If MsSeek( xFilial("CHD") + idPerido )
				cPerini:= CHD->CHD_PERINI
				cPerfim:= CHD->CHD_PERFIN
				
				cQuery := "SELECT " 
				cQuery += "COUNT(CFV.CFV_ID) CONT" 
				cQuery += "FROM "
				cQuery += RetSqlName( 'CFV' ) + " CFV" 
				cQuery += "WHERE " 
				cQuery += "CFV.CFV_FILIAL='" + xFilial('CFV') + "' AND "
				cQuery += "CFV_PERIOD BETWEEN '" + Dtos(cPerini) + "' AND '" + Dtos(cPerfim) + "' AND "  
				cQuery += "CFV.D_E_L_E_T_=' ' "
				cQuery := ChangeQuery( cQuery )
	
				dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry ) 
				
				If (cAliasQry)->CONT > 1		
					Aadd( aLogErro, { "CFV_PERIOD", "000219", "CFV", nRecno } ) //000219 - "Deve existir apenas um registro X320 (Operações com o Exterior – Importações) dentro do mesmo período (em Parâmetros de Abertura)" 
				Endif				
				
			Endif
			
		Endif
	
	EndIf
	
	//Valida o Código NCM
	If ! Empty(CFV->CFV_CODNCM)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := CFV->CFV_CODNCM
		xVldECFTab("C0A",cChave,3,,@aLogErro,{ "CFV","CFV_CODNCM", nRecno })
	EndIf
	
	//Valida A Unidade de Medida 
	If ! Empty(CFV->CFV_UNIDAD)
		cIdUnECF := Posicione("C1J",3,xFilial("C1J")+CFV->CFV_UNIDAD,"C1J_IDUMEC")  
		cUnidad  := Posicione("CHJ",1,xFilial("CHJ")+cIdUnECF ,"CHJ_CODIGO")      
		
		If !AllTrim(cUnidad) $ '01|02|03|04|05|06|07|08|09|10|11|12|13|14|15'
			Aadd( aLogErro, { "CFV_UNIDAD", "000002", "CFV", nRecno } ) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
		Else
			//Chave de busca na tabela FILHO ou Consulta padrao
			cChave := CFV->CFV_UNIDAD
			xVldECFTab("C1J",cChave,3,,@aLogErro,{ "CFV","CFV_UNIDAD", nRecno })
		EndIf
		
	EndIf
		
	//Valida o Método
	If ! Empty(CFV->CFV_TIPMET)
		If !CFV->CFV_TIPMET $ '1|2|3|4|5|6|7'
			Aadd( aLogErro, { "CFV_TIPMET", "000002", "CFV", nRecno } ) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
		EndIf
	EndIf

	/*/
	"REGRA_DESC_IMP_OBRIGATORIO: Verifica se DESC_EXP (Campo 04) está preenchido quando
	TIP_IMP (Campo 03) igual a “1” (bens) ou “2” (serviços) ou “3” (direitos)."
	/*/
	If CFV->CFV_TIPEXP $ '01|02|03' .and. Empty(CFV->CFV_DESCRI)
		Aadd( aLogErro, { "CFV_DESCRI", "000001", "CFV", nRecno } ) //000001 - Campo Inconsistente ou Vazio
	EndIf
	
	/*/
	"REGRA_TOT_OPER_OBRIGATORIO_X320: Verifica se TOT_OPER (Campo 05) está preenchido quando
	TIP_IMP (Campo 03) igual a “1” (bens) ou “2” (serviços) ou “3” (direitos) ou “5” (não especificadas)."
	/*/
	If CFV->CFV_TIPEXP $ '01|02|03|05' .and. CFV->CFV_TOTOPE <= 0
		Aadd( aLogErro, { "CFV_TOTOPE", "000001", "CFV", nRecno } ) //000001 - Campo Inconsistente ou Vazio
	EndIf


	If CFV->CFV_TIPEXP == '01' 
		/*/
		"REGRA_COD_NCM_OBRIGATORIO: Verifica se COD_NCM (Campo 06) está preenchido quando TIP_IMP
		(Campo 03) igual a “1” (bens)."
		/*/
		If Empty(CFV->CFV_CODNCM)
			Aadd( aLogErro, { "CFV_CODNCM", "000001", "CFV", nRecno } ) //000001 - Campo Inconsistente ou Vazio
		EndIf
		
		/*/
		"REGRA_QTDE_OBRIGATORIO: Verifica se QTDE (Campo 07) está preenchido quando TIP_IMP
		(Campo 03) igual a “1” (bens)."
		/*/
		If CFV->CFV_QUANTI <= 0
			Aadd( aLogErro, { "CFV_QUANTI", "000001", "CFV", nRecno } ) //000001 - Campo Inconsistente ou Vazio
		EndIf
		
		/*/
		"REGRA_UNI_MED_OBRIGATORIO: Verifica se UNI_MED (Campo 08) está preenchido quando TIP_IMP
		(Campo 03) igual a “1” (bens)."
		/*/   
		If Empty(CFV->CFV_UNIDAD)
			Aadd( aLogErro, { "CFV_UNIDAD", "000001", "CFV", nRecno } ) //000001 - Campo Inconsistente ou Vazio
		EndIf

	EndIf

	If CFV->CFV_TIPEXP $ '01|02|03'
		/*/
		"REGRA_TIP_MET_OBRIGATORIO: Verifica se TIP_MET (Campo 9) está preenchido quando
		TIP_IMP (Campo 03) igual a “1” (bens) ou “2” (serviços) ou “3” (direitos)."
		/*/	
		If Empty(CFV->CFV_TIPMET)
			Aadd( aLogErro, { "CFV_TIPMET", "000001", "CFV", nRecno } ) //000001 - Campo Inconsistente ou Vazio
		EndIf
	
		/*/
		"REGRA_VL_PAR_OBRIGATORIO: Verifica se VL_PAR (Campo 10) está preenchido quando 
		TIP_IMP (Campo 03) igual a “1” (bens) ou “2”(serviços) ou “3” (direitos).
		/*/
		If CFV->CFV_VLPAR <= 0
			Aadd( aLogErro, { "CFV_VLPAR", "000001", "CFV", nRecno } ) //000001 - Campo Inconsistente ou Vazio
		EndIf
		
		/*/
		"REGRA_VL_PRAT_OBRIGATORIO: Verifica se VL_PRAT (Campo 11) está preenchido quando
		TIP_IMP (Campo 03) igual a “1” (bens) ou “2” (serviços) ou “3” (direitos)."
		/*/
		If CFV->CFV_VLPRAT <= 0
			Aadd( aLogErro, { "CFV_VLPRAT", "000001", "CFV", nRecno } ) //000001 - Campo Inconsistente ou Vazio
		EndIf
	EndIf
		
	If CFV->CFV_VLAJ <= 0	
		/*/
		"REGRA_VL_AJ_OBRIGATORIO: Verifica se VL_AJ (Campo 12) está preenchido quando TIP_IMP
		(Campo 03) igual a “1” (bens) ou “2” (serviços) ou “3” (direitos) ou “4” (operações financeiras) ou “5” (não
		especificadas)."
		/*/
		Aadd( aLogErro, { "CFV_VLAJ", "000001", "CFV", nRecno } ) //000001 - Campo Inconsistente ou Vazio
	EndIf
		

	If CFV->CFV_TIPEXP $ '04'
		/*/
		"REGRA_VL_JUR_OBRIGATORIO: Verifica se VL_JUR (Campo 13) está preenchido quando
		TIP_IMP (Campo 03) igual a “4” (operações financeiras)."
		/*/
		If CFV->CFV_TXJUR <= 0
			Aadd( aLogErro, { "CFV_TXJUR", "000001", "CFV", nRecno } ) //000001 - Campo Inconsistente ou Vazio
		EndIf
		
		/*/
		"REGRA_VL_JUR_MIN_OBRIGATORIO_X320: Verifica se VL_JUR_MIN (Campo 14) está preenchido quando
		TIP_IMP (Campo 03) igual a “4” (operações financeiras)."
		/*/
		If CFV->CFV_TXJMIN <= 0
			Aadd( aLogErro, { "CFV_TXJMIN", "000001", "CFV", nRecno } ) //000001 - Campo Inconsistente ou Vazio
		EndIf
		
		/*/
		"REGRA_VL_JUR_MAX_OBRIGATORIO_X320: Verifica se VL_JUR_MAX (Campo 15) está preenchido
		quando TIP_IMP (Campo 03) igual a “4” (operações financeiras)."
		/*/
		If CFV->CFV_TXJMAX <= 0
			Aadd( aLogErro, { "CFV_TXJMAX", "000001", "CFV", nRecno } ) //000001 - Campo Inconsistente ou Vazio
		EndIf
		
		/*/
		"REGRA_COD_CNC_OBRIGATORIO: Verifica se COD_CNC (Campo 16) está preenchido quando
		TIP_IMP (Campo 03) igual a “4” (operações financeiras)."
		/*/
		If Empty(CFV->CFV_IDCNC)
			Aadd( aLogErro, { "CFV_CODCNC", "000001", "CFV", nRecno } ) //STR0001 - Campo Inconsistente ou Vazio
	    Else
			xVldECFTab("CZT",CFV->CFV_IDCNC,1,,@aLogErro,{"CFV","CFV_CODCNC",nRecno })
	    EndIf	
				
		/*/
		"REGRA_TIP_MOEDA_OBRIGATORIO: Verifica se TIP_MOEDA (Campo 17) está preenchido quando
		TIP_IMP (Campo 03) igual a “4” (operações financeiras)."
		/*/
		If Empty(CFV->CFV_IDMOED)
			Aadd( aLogErro, {"CFV_MOEDA", "000001", "CFV", nRecno }) //STR0001 - Campo Inconsistente ou Vazio
	    Else
			xVldECFTab("CZU",CFV->CFV_IDMOED,1,,@aLogErro,{"CFV","CFV_MOEDA",nRecno })
	    EndIf	
		
		
	EndIf	

	//ÚÄÄÄÄÄÄÄÄÄÄ¿
	//³INICIO CFX³
	//ÀÄÄÄÄÄÄÄÄÄÄÙ
	CFX->( DBSetOrder(1) )
	cCFXKey := CFV->CFV_ID+DTOS(CFV->CFV_PERIOD)+CFV->CFV_NUMORD
	If CFX->( MsSeek( xFilial("CFX") + cCFXKey ) )

		Do While !CFX->( Eof() ) .And. cCFXKey == CFX->CFX_ID+DTOS(CFX->CFX_PERIOD)+CFX->CFX_NUMORD

			//---------------------
			// Campos obrigatórios
			//---------------------
			If Empty(CFX->CFX_NOME)
				AADD(aLogErro,{"CFX_NOME","000001", "CFX",nRecno }) //STR0001 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If CFX->CFX_VLOPER <= 0
				AADD(aLogErro,{"CFX_VLOPER","000001", "CFX",nRecno }) //STR0001 - "Campo Inconsistente ou Vazio"
			Else
				nTotOper += CFX->CFX_VLOPER
			EndIf
			
			If Empty(CFX->CFX_CONDPE)
				AADD(aLogErro,{"CFX_CONDPE","000001", "CFX",nRecno }) //STR0001 - "Campo Inconsistente ou Vazio"
			Else	
				If !CFX->CFX_CONDPE $ '01|02|03'
					AADD(aLogErro,{"CFX_CONDPE","000002", "CFX",nRecno }) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
				EndIf
			EndIf
			
			//------------------
			// Consultas padrão
			//------------------
			If Empty(CFX->CFX_PAIS)
				AADD(aLogErro,{"CFX_PAIS","000001", "CFX",nRecno }) //STR0001 - "Campo Inconsistente ou Vazio"
			Else
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := CFX->CFX_PAIS
				xValRegTab("C08",cChave,3,,@aLogErro,)
			EndIf	

			CFX->( DbSkip() )
		EndDo
		/*/		
		REGRA_SOMATORIA_VALOR_OPERACAO: Verifica se o somatório dos registros filhos X310.VL_OPER  é igual a TOT_OPER (Campo 04). 
		Se a regra não for cumprida, o sistema gera um aviso.  
		
		If CFV->CFV_TOTOPE # nTotOper
			AADD(aLogErro,{"CFV_TOTOPE","000011", "CFX",nRecno }) //STR0011 - "A totalização do campo nos Registros Filhos não confere com o total no Registro Pai."		
		EndIf
		/*/
		
		/*/
		REGRA_X330_NAO_PREENCHIDO: Verifica se, para cada registro X320 preenchido, existe pelo menos um registro X310 preenchido. 
		Se a regra não for cumprida, o sistema gera um aviso.
			AADD(aLogErro,{"CFX_NOME","000001", "CFX",nRecno }) //STR0001 - "Campo Inconsistente ou Vazio."
		/*/
		
	EndIf
	//ÚÄÄÄÄÄÄÄ¿
	//³FIM CFX³
	//ÀÄÄÄÄÄÄÄÙ
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ATUALIZO O STATUS DO REGISTRO³
	//³1 = Registro Invalido        ³
	//³0 = Registro Valido          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TAFAltStat("CFV", IIf( Len(aLogErro)>0, '1', '0' ) )
	
Else
	AADD(aLogErro,{"CFV_ID","000017", "CFV", nRecno }) //STR0017 - "Registro ja valido"
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro) 
