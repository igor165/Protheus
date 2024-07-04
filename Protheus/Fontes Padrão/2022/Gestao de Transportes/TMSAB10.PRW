#INCLUDE "TMSAB10.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"


/*/-----------------------------------------------------------
{Protheus.doc} TMSAB10()
Cadastro de Diárias 

Uso: SIGATMS

@sample
//TMSAB10()

@author Paulo Henrique Corrêa Cardoso.
@since 09/01/2014
@version 1.0
-----------------------------------------------------------/*/
Function TMSAB10()
Local oBrowse   := Nil				// Recebe o  Browse          

Private  aRotina   := MenuDef()		// Recebe as rotinas do menu.

oBrowse:= FWMBrowse():New()   
oBrowse:SetAlias("DYS")			    // Alias da tabela utilizada
oBrowse:SetMenuDef("TMSAB10")		// Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription(STR0001)		//"Cadastro de Diarias"

oBrowse:Activate()

Return Nil

 /*/-----------------------------------------------------------
{Protheus.doc} MenuDef()
Utilizacao de menu Funcional  

Uso: TMSAB10

@sample
//MenuDef()

@author Paulo Henrique Corrêa Cardoso.
@since 09/01/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function MenuDef()

Local aRotina := {}

	ADD OPTION aRotina TITLE STR0003  ACTION "AxPesqui"        OPERATION 1 ACCESS 0 // "Pesquisar"
	ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.TMSAB10" OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.TMSAB10" OPERATION 3 ACCESS 0 // "Incluir"
	ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.TMSAB10" OPERATION 4 ACCESS 0 // "Alterar"
	ADD OPTION aRotina TITLE STR0007  ACTION "VIEWDEF.TMSAB10" OPERATION 5 ACCESS 0 // "Excluir"

Return(aRotina)  

/*/-----------------------------------------------------------
{Protheus.doc} ModelDef()
Definição do Modelo

Uso: TMSAB10

@sample
//ModelDef()

@author Paulo Henrique Corrêa Cardoso.
@since 09/01/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function ModelDef()

Local oModel	:= Nil		// Objeto do Model
Local oStruDYS	:= Nil		// Recebe a Estrutura da tabela DYS
Local oStruDYT	:= Nil 		// Recebe a Estrutura da tabela DYT

oStruDYS:= FWFormStruct( 1, "DYS" )
oStruDYT:= FWFormStruct( 1, "DYT" )

oModel := MPFormModel():New( "TMSAB10",,{|oModel|PosVldMdl(oModel)},/*bCommit*/, /*bCancel*/ ) 
oModel:AddFields( 'MdFieldDYS',, oStruDYS,,,/*Carga*/ ) 

oModel:AddGrid( 'MdGridDYT', 'MdFieldDYS', oStruDYT,/*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/,/*BLoad*/  )

oModel:SetRelation('MdGridDYT',{ {"DYT_FILIAL","FWxFilial('DYT')"},{"DYT_IDDIA","DYS_IDDIA"} }, DYT->(IndexKey(1)) )
oModel:GetModel('MdGridDYT'):SetUniqueLine( { "DYT_TIPVAL","DYT_TIPVEI","DYT_CONDUT"} )                  

oModel:GetModel('MdGridDYT'):SetDescription(STR0002) 		//Itens do Cadastro de Diárias 
oModel:SetDescription( STR0001 )							//"Cadastro de Diarias"
oModel:GetModel( 'MdFieldDYS' ):SetDescription( STR0001 ) 	//"Cadastro de Diarias" 

oModel:SetPrimaryKey({"DYS_FILIAL" , "DYS_IDDIA"})  
     
oModel:SetActivate( )
     
Return oModel 

/*/-----------------------------------------------------------
{Protheus.doc} ViewDef()
Definição da View

Uso: TMSAB10

@sample
//ViewDef()

@author Paulo Henrique Corrêa Cardoso.
@since 09/01/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function ViewDef()     
Local oModel	:= Nil		// Objeto do Model 
Local oStruDYS	:= Nil		// Recebe a Estrutura da tabela DYS
Local oStruDYT	:= Nil 		// Recebe a Estrutura da tabela DYT  
Local oView					// Recebe o objeto da View

oModel   := FwLoadModel("TMSAB10")
oStruDYS := FWFormStruct( 2, "DYS" )
oStruDYT := FWFormStruct( 2, "DYT" )  

oStruDYT:RemoveField("DYT_IDDIA")  

oView := FwFormView():New()
oView:SetModel(oModel)     

oView:AddField('VwFieldDYS', oStruDYS , 'MdFieldDYS') 
oView:AddGrid( 'VwGridDYT', oStruDYT , 'MdGridDYT')   

oView:CreateHorizontalBox('CABECALHO', 30)
oView:CreateHorizontalBox('GRID'	 , 70)  
oView:SetOwnerView('VwFieldDYS','CABECALHO')
oView:SetOwnerView('VwGridDYT','GRID'     )     

oView:AddIncrementField('VwGridDYT','DYT_ITEM') 

Return oView


/*/-----------------------------------------------------------
{Protheus.doc} PosVldMdl()
Validação do Modelo

Uso: TMSAB10

@sample
//PosVldMdl(oModel)

@author Paulo Henrique Corrêa Cardoso.
@since 28/01/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function PosVldMdl(oModel)
Local lRet 		 := .T.    			// Recebe o Retorno
Local cRota		 := ""				// Recebe a Rota
Local cTipVia	 := ""				// Recebe o Tipo da Viagem
Local cQuery	 := ""				// Recebe a query da validação
Local cTab		 := GetNextAlias()	// Recebe o alias temporario para a query	
Local nOperation := 0				// Recebe a Operacao realizada
Local cIdDia	 := ""				// Recebe o Id da diaria corrente


cRota 	:=  FwFldGet("DYS_ROTA")
cTipVia :=  FwFldGet("DYS_TIPVIA")
cTipVia :=  FwFldGet("DYS_TIPVIA")
cIdDia  :=  FwFldGet("DYS_IDDIA")  

nOperation := oModel:GetOperation()

If  nOperation == MODEL_OPERATION_UPDATE .OR.  nOperation == MODEL_OPERATION_INSERT
	If !Empty(cRota) .OR. !Empty(cTipVia)
	
		// Verifica se já possui alguma vigencia com estas datas
		cQuery  += " SELECT COUNT(1) AS QTD
		cQuery  += " FROM " + RetSqlName( 'DYS' )
		cQuery  += " WHERE  D_E_L_E_T_ = ' ' 
		cQuery  += "     AND DYS_ROTA = '"+ cRota +"'
		cQuery  += "	 AND DYS_TIPVIA = '"+ cTipVia +"'
		cQuery  += "	 AND DYS_IDDIA <> '"+ cIdDia +"'
		
		
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTab, .F., .T. )
		
		If (cTab)->QTD > 0
			lRet := .F.
			
			Help('', 1,"HELP",, STR0008,1)// "Ja existe uma diaria cadastrada com essa configuracao: Rota + Tipo Viagem." 
		EndIf
		
		(cTab)->(dbCloseArea())
	Else
		lRet := .F.
		Help('', 1,"HELP",, STR0009 ,1)// "Necessario o Preenchimento de pelo menos um dos campos : Rota / Tipo Viagem" 
	EndIf
EndIf	

Return lRet
/*/-----------------------------------------------------------
{Protheus.doc} AB10CalTot()
Calcula o campo Total

Uso: TMSAB10

@sample
//AB10CalTot()

@author Paulo Henrique Corrêa Cardoso.
@since 28/01/2014
@version 1.0
-----------------------------------------------------------/*/
Function AB10CalTot()
Local lRet := .F.		// Recebe o Retorno
Local nVlrLiq := 0		// Recebe o Valor Liquido Calculado

nVlrLiq := (FwFldGet("DYT_QTDE") * FwFldGet("DYT_VLRUNI"))

If nVlrLiq >= 0
	FwFldPut("DYT_VLRTOT",nVlrLiq,,,,.T.)
	lRet := .T.
EndIf

Return lRet
