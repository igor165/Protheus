#INCLUDE "TMSAB20.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"


/*/-----------------------------------------------------------
{Protheus.doc} TMSAB20()
Parametriza��o de Di�rias 

Uso: SIGATMS

@sample
//TMSAB20()

@author Paulo Henrique Corr�a Cardoso.
@since 13/01/2014
@version 1.0
-----------------------------------------------------------/*/
Function TMSAB20()
Local oBrowse   := Nil				// Recebe o  Browse          

Private  aRotina   := MenuDef()		// Recebe as rotinas do menu.


oBrowse:= FWMBrowse():New()   
oBrowse:SetAlias("DYU")			    // Alias da tabela utilizada
oBrowse:SetMenuDef("TMSAB20")		// Nome do fonte onde esta a fun��o MenuDef
oBrowse:SetDescription(STR0001)		//"Parametriza��o de Diarias"

oBrowse:Activate()

Return Nil

 /*/-----------------------------------------------------------
{Protheus.doc} MenuDef()
Utilizacao de menu Funcional  

Uso: TMSAB20

@sample
//MenuDef()

@author Paulo Henrique Corr�a Cardoso.
@since 13/01/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function MenuDef()

Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002  ACTION "AxPesqui"        OPERATION 1 ACCESS 0 // "Pesquisar"
	ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.TMSAB20" OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.TMSAB20" OPERATION 3 ACCESS 0 // "Incluir"
	ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.TMSAB20" OPERATION 4 ACCESS 0 // "Alterar"
	ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.TMSAB20" OPERATION 5 ACCESS 0 // "Excluir"

Return(aRotina)  

/*/-----------------------------------------------------------
{Protheus.doc} ModelDef()
Defini��o do Modelo

Uso: TMSAB20

@sample
//ModelDef()

@author Paulo Henrique Corr�a Cardoso.
@since 13/01/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function ModelDef()

Local oModel	:= Nil		// Objeto do Model
Local oStruDYU	:= Nil		// Recebe a Estrutura da tabela DYU

oStruDYU:= FWFormStruct( 1, "DYU" )

oModel := MPFormModel():New( "TMSAB20",,,/*bCommit*/, /*bCancel*/ ) 
oModel:AddFields( 'MdFieldDYU',, oStruDYU,,,/*Carga*/ ) 

oModel:GetModel( 'MdFieldDYU' ):SetDescription( STR0001 ) 	//"Parametriza��o de Diarias"

oModel:SetPrimaryKey({"DYU_FILIAL" , "DYU_IDPDIA"})  
     
oModel:SetActivate( )
     
Return oModel 

/*/-----------------------------------------------------------
{Protheus.doc} ViewDef()
Defini��o da View

Uso: TMSAB20

@sample
//ViewDef()

@author Paulo Henrique Corr�a Cardoso.
@since 13/01/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function ViewDef()     
Local oModel	:= Nil		// Objeto do Model 
Local oStruDYU	:= Nil		// Recebe a Estrutura da tabela DYU
Local oView					// Recebe o objeto da View

oModel   := FwLoadModel("TMSAB20")
oStruDYU := FWFormStruct( 2, "DYU" )


oView := FwFormView():New()
oView:SetModel(oModel)     

oView:AddField('VwFieldDYU', oStruDYU , 'MdFieldDYU')   

oView:CreateHorizontalBox('CABECALHO', 100)  
oView:SetOwnerView('VwFieldDYU','CABECALHO')

Return oView

/*/-----------------------------------------------------------
{Protheus.doc} TMSB20VLD()
Valida��o do Periodo de Vigencia

Uso: TMSAB20

@sample
//TMSB20VLD()

@author Paulo Henrique Corr�a Cardoso.
@since 13/01/2014
@version 1.0
-----------------------------------------------------------/*/
Function TMSB20VLD()
Local lRet 		:= .T.    			// Recebe o Retorno
Local dIni 		:= STOD("//")		// Recebe a Data de Vigencia Inicial
Local dFin 		:= STOD("//") 		// Recebe a Data de Vigencia Final
Local cQuery	:= ""				// Recebe a query da valida��o
Local cTab		:= GetNextAlias()	// Recebe o alias temporario para a query	

dIni :=  FwFldGet("DYU_INIVIG")
dFin :=  FwFldGet("DYU_FIMVIG")
 
If !Empty(dIni) .AND. !Empty(dFin)

	// Valida se a data inicial � menor que a data final
	If dIni > dFin
		lRet := .F.
		Help('', 1,"HELP",, STR0007,1) //"A data de Inicio da Vig�ncia n�o pode ser maior que a data de Fim da Vig�ncia."
	Else
		
		// Verifica se j� possui alguma vigencia com estas datas
		cQuery  += " SELECT DYU_IDPDIA "
		cQuery  += "	FROM " + RetSqlName( 'DYU' )
		cQuery  += "	WHERE D_E_L_E_T_ = ' ' AND DYU_FILIAL = '"+ FWxFilial("DYU") +"' AND "
		cQuery  += "	 	  ((DYU_INIVIG <= '"+ DTOS(dIni) +"' AND DYU_FIMVIG >= '"+ DTOS(dIni) +"') OR  "
		cQuery  += "	  	  (DYU_INIVIG <= '"+ DTOS(dFin) +"' AND DYU_FIMVIG >= '"+ DTOS(dFin) +"')) AND "
		cQuery  += "		  DYU_IDPDIA <> '" + FwFldGet("DYU_IDPDIA") + "'"
		
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTab, .F., .T. )
		
		If !(cTab)->(EOF())
			lRet := .F.
			Help('', 1,"HELP",, STR0008 + (cTab)->DYU_IDPDIA,1)// "A seguinte parametriza��o j� possui partes desta vig�ncia: " 
		EndIf
		(cTab)->(dbCloseArea())
	EndIf	
EndIf

Return lRet