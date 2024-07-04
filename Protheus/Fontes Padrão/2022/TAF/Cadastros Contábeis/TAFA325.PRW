#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA325.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA325
ATIVIDADES INCENTIVADAS - PJ EM GERAL

@author Roger Cangianeli
@since 20/05/2014
@version 1.0
 
/*/
//-------------------------------------------------------------------
Function TAFA325()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 )
oBrw:SetAlias('CFK')
oBrw:SetMenuDef( 'TAFA325' )
oBrw:SetCacheView(.F.)
oBrw:Activate()  


Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Denis R. de Oliveira
@since 17/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf325Vld" , "2" } )
aRotina	:=	xFunMnuTAF( "TAFA325" , , aFuncao )

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Marcio Nunes
@since 10/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCFK 	:= 	FWFormStruct( 1, 'CFK' )
Local 	oModel 	:= MPFormModel():New( 'TAFA325' , , , {|oModel| SaveModel( oModel ) } )

oModel:AddFields('MODEL_CFK', /*cOwner*/, oStruCFK)
oModel:GetModel( 'MODEL_CFK' ):SetPrimaryKey( { "CFK_VIGINI", "CFK_VIGFIM", "CFK_IDBENF", "CFK_IDINDP", "CFK_ATOCON" } )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View
@return oView - Objeto da View MVC
@author Denis R de Oliveira
@since 17/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA325' )
Local 	oStruCFK 	:= 	FWFormStruct( 2, 'CFK' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_CFK', oStruCFK, 'MODEL_CFK' )

oView:EnableTitleView( 'VIEW_CFK', STR0001 ) //ATIVIDADES INCENTIVADAS - PJ EM GERAL
oView:CreateHorizontalBox( 'FIELDSCFK', 100 )
oView:SetOwnerView( 'VIEW_CFK', 'FIELDSCFK' )

oStruCFK:RemoveField('CFK_ID')
oStruCFK:RemoveField('CFK_IDBENF')
oStruCFK:RemoveField('CFK_IDINDP')

oStruCFK:SetProperty("CFK_PERIOD", MVC_VIEW_ORDEM, "03" )
oStruCFK:SetProperty("CFK_BENFIS", MVC_VIEW_ORDEM, "04" )
oStruCFK:SetProperty("CFK_DBENFI", MVC_VIEW_ORDEM, "05" )
oStruCFK:SetProperty("CFK_INDPRO", MVC_VIEW_ORDEM, "06" )
oStruCFK:SetProperty("CFK_DINDPR", MVC_VIEW_ORDEM, "08" )
oStruCFK:SetProperty("CFK_ATOCON", MVC_VIEW_ORDEM, "09" )
oStruCFK:SetProperty("CFK_VIGINI", MVC_VIEW_ORDEM, "10" )
oStruCFK:SetProperty("CFK_VIGFIM", MVC_VIEW_ORDEM, "12" )


Return oView   

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Denis R. de Oliveira
@since 17/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation := oModel:GetOperation()

Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao responsavel por setar o Status do registro para Branco³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TAFAltStat( "CFK", " " )	
	
	EndIf

	FwFormCommit( oModel )
        

End Transaction
       

Return .T.

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf325Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return .T.

@author Denis R. de Oliveira
@since 17/02/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function Taf325Vld(cAlias,nRecno,nOpc,lJob) 

Local aLogErro	:= {}
Local cBenFis	:= ''
Local cIndPro	:= ''

If (CFK->CFK_STATUS $ (' 1'))
	
	//Valida o Benefício Fiscal
	If Empty(CFK->CFK_IDBENF)
		Aadd( aLogErro, { "CFK_BENFIS", "000001", "CFK", nRecno } ) //STR0001 - "Campo Inconsistente ou Vazio."		
	Else
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := CFK->CFK_IDBENF
		xVldECFTab("CFL",cChave,1,,@aLogErro,{ "CFK","CFK_BENFIS", nRecno })
	EndIf
	
	//Valida o Indicador de Projeto
	If Empty(CFK->CFK_IDINDP)
		Aadd( aLogErro, { "CFK_INDPRO", "000001", "CFK", nRecno } ) //STR0001 - "Campo Inconsistente ou Vazio."	
	Else
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := CFK->CFK_IDINDP
		xVldECFTab("CFM",cChave,1,,@aLogErro,{ "CFK","CFK_INDPRO", nRecno })
	EndIf
	
	//Valida o Ato Concessório
	If Empty(CFK->CFK_ATOCON)
		Aadd( aLogErro, { "CFK_ATOCON", "000001", "CFK", nRecno } ) //STR0001 - "Campo Inconsistente ou Vazio."	
	EndIf
	
	//Valida o Início da Vigência
	If Empty(CFK->CFK_VIGINI)
		Aadd( aLogErro, { "CFK_VIGINI", "000001", "CFK", nRecno } ) //STR0001 - "Campo Inconsistente ou Vazio."	
	EndIf
	
	//Valida o Fim da Vigência
	If Empty(CFK->CFK_VIGFIM)
		Aadd( aLogErro, { "CFK_VIGFIM", "000001", "CFK", nRecno } ) //STR0001	- "Campo Inconsistente ou Vazio."	
	EndIf

	/*/	
	"REGRA_IND_PROJ_ACEITO: Verifica se IND_PROJ (Campo CFK_INDPRO) é compatível com a atividade (CFK_BENFIS).
	O erro ocorre:
	1) Se X280.IND_ATIV = “1” e X280.IND_PROJ é diferente de “1” ou “2” ou “3” ou “4” ou “6” ou “8” ou “9” ou “10” ou “11” ou “99”)
	2) Se X280.IND_ATIV = “2” e X280.IND_PROJ é diferente de “7” ou “99”
	3) Se X280.IND_ATIV = “3” e X280.IND_PROJ é diferente de “1” ou “2” ou “3” ou “4” ou “99”
	4) Se X280.IND_ATIV = “4” e X280.IND_PROJ é diferente de “1” ou “99”
	5) Se X280.IND_ATIV = “5” e X280.IND_PROJ é diferente de “3” ou “5” ou “99”
	6) Se X280.IND_ATIV = “6” e X280.IND_PROJ é diferente de “3” ou “99”
	7) Se X280.IND_ATIV = “7” e X280.IND_PROJ é diferente de “1” ou “2” ou “3” ou “4” ou “99”
	8) Se X280.IND_ATIV = “8” e X280.IND_PROJ é diferente de “5” ou “99”
	9) Se X280.IND_ATIV = “9” e X280.IND_PROJ é diferente de “99”
	/*/

	// BenFis
	cBenFis := Posicione("CFL",1,xFilial("CFL")+CFK->CFK_IDBENF,"CFL_CODIGO")
	
	// IndPro
	cIndPro := Posicione("CFM",1,xFilial("CFL")+CFK->CFK_IDINDP,"CFM_CODIGO")

	// Regra 1	
	If cBenFis == '01' .and. !cIndPro $ '01|02|03|04|06|08|09|10|11|99'
		Aadd( aLogErro, { "CFK_INDPRO", "000153", "CFK", nRecno } ) //STR0153 - "Conteúdo do campo não condiz com as opções possíveis."	
	// Regra 2
	ElseIf cBenFis == '02' .and. !cIndPro $ '07|99'
		Aadd( aLogErro, { "CFK_INDPRO", "000154", "CFK", nRecno } ) //STR0154 - "Conteúdo do campo não condiz com as opções possíveis."		
	// Regra 3 e Regra 7
	ElseIf cBenFis $ '03/07' .and. !cIndPro $ '01|02|03|04|99'
		Aadd( aLogErro, { "CFK_INDPRO", "000155", "CFK", nRecno } ) //STR0155 - "Conteúdo do campo não condiz com as opções possíveis."		
	// Regra 4	
	ElseIf cBenFis == '04' .and. !cIndPro $ '01|99'
		Aadd( aLogErro, { "CFK_INDPRO", "000156", "CFK", nRecno } ) //STR0156 - "Conteúdo do campo não condiz com as opções possíveis."		
	// Regra 5	
	ElseIf cBenFis == '05' .and. !cIndPro $ '03|05|99'
		Aadd( aLogErro, { "CFK_INDPRO", "000157", "CFK", nRecno } ) //STR0157 - "Conteúdo do campo não condiz com as opções possíveis."	
	// Regra 6
	ElseIf cBenFis == '06' .and. !cIndPro $ '03|99'
		Aadd( aLogErro, { "CFK_INDPRO", "000158", "CFK", nRecno } ) //STR0158 - "Conteúdo do campo não condiz com as opções possíveis."	
	// Regra 8
	ElseIf cBenFis == '08' .and. !cIndPro $ '05|99'
		Aadd( aLogErro, { "CFK_INDPRO", "000159", "CFK", nRecno } ) //STR0159 - "Conteúdo do campo não condiz com as opções possíveis."	
	// Regra 9
	ElseIf cBenFis == '09' .and. cIndPro <> '99'
		Aadd( aLogErro, { "CFK_INDPRO", "000160", "CFK", nRecno } ) //STR0160 - "Conteúdo do campo não condiz com as opções possíveis."		
	EndIf	
	
	//REGRA_MAIOR_IGUAL_VIG_INI
	If CFK->CFK_VIGFIM < CFK->CFK_VIGINI
		Aadd( aLogErro, { "CFK_VIGFIM", "000224", "CFK", nRecno } ) //STR0224 - "O campo 'Fim da Vigência' deve ser maior ou igual ao campo 'Início da Vigência'."
	EndIf
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ATUALIZO O STATUS DO REGISTRO³
	//³1 = Registro Invalido        ³
	//³0 = Registro Valido          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aLogErro)>0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TAFAltStat("CFK", '1')
	Else
		TAFAltStat("CFK", '0')
	EndIf
	
Else
	AADD(aLogErro,{"CFK_ID","000017", "CFK", nRecno }) //STR0017 - "Registro já validado"
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro)