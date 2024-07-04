#INCLUDE "TMSAC10.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/-----------------------------------------------------------
{Protheus.doc} TMSAC10()
"Controle Parâmetros do CheckList"
Uso: SIGATMS
@sample
//TMSAC10()
@author Felipe M. Barbiere
@since 07/04/2020
@version 1.0
-----------------------------------------------------------/*/
Function TMSAC10()
Local oBrowse   := Nil				// Recebe o  Browse               

Private  aRotina   := MenuDef()		// Recebe as rotinas do menu.

oBrowse:= FWMBrowse():New()   
oBrowse:SetAlias("DLZ")			    // Alias da tabela utilizada
oBrowse:SetMenuDef("TMSAC10")		// Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription(STR0001)		//"Controle Parâmetros do CheckList"
oBrowse:Activate()

Return Nil

 /*/-----------------------------------------------------------
{Protheus.doc} MenuDef()
Utilizacao de menu Funcional  
Uso: TMSAC10
@sample
//MenuDef()
@author Felipe M. Barbiere
@since 07/04/2020
@version 1.0
-----------------------------------------------------------/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002  ACTION "AxPesqui"        	OPERATION 1 ACCESS 0 // "Pesquisar"
ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.TMSAC10" 	OPERATION 2 ACCESS 0 // "Visualizar"
ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.TMSAC10"	OPERATION 3 ACCESS 0 // "Incluir"
ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.TMSAC10" 	OPERATION 4 ACCESS 0 // "Alterar"
ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.TMSAC10" 	OPERATION 5 ACCESS 0 // "Excluir"
ADD OPTION aRotina TITLE STR0007  ACTION "TMSC10Conn" 		OPERATION 5 ACCESS 0 // ""Testar conexão com Meu Check-list""

Return (aRotina)  

/*/-----------------------------------------------------------
{Protheus.doc} ModelDef()
Definição do Modelo
Uso: TMSAC10
@sample
//ModelDef()
@author Felipe M. Barbiere
@since 07/04/2020
@version 1.0
-----------------------------------------------------------/*/
Static Function ModelDef()

Local oModel	:= Nil		// Objeto do Model
Local oStruDLZ	:= Nil		// Recebe a Estrutura da tabela DLZ
Local bCommit	:= { |oMdl| CommitMdl(oMdl) }
Local bPosValid := { |oModel| PosVldMdl(oModel) }

oStruDLZ:= FWFormStruct( 1, "DLZ" )

oModel := MPFormModel():New( "TMSAC10",,bPosValid, bCommit /*bCommit*/, /*bCancel*/ ) 
oModel:AddFields( 'MdFieldDLZ',, oStruDLZ,,,/*Carga*/ ) 
oModel:GetModel( 'MdFieldDLZ' ):SetDescription( STR0001 ) 	//"Controle Parâmetros do CheckList"
oModel:SetPrimaryKey({"DLZ_FILIAL" , "DLZ_ID"})     
oModel:SetActivate()
     
Return oModel 

/*/-----------------------------------------------------------
{Protheus.doc} ViewDef()
Definição da View

Uso: TMSAC10

@sample
//ViewDef()

@author Felipe M. Barbiere
@since 07/04/2020
@version 1.0
-----------------------------------------------------------/*/
Static Function ViewDef()     
Local oModel	:= Nil		// Objeto do Model 
Local oStruDLZ	:= Nil		// Recebe a Estrutura da tabela DLZ
Local oView					// Recebe o objeto da View

oModel   := FwLoadModel("TMSAC10")
oStruDLZ := FWFormStruct( 2, "DLZ" )

oView := FwFormView():New()
oView:SetModel(oModel)     
oView:AddField('VwFieldDLZ', oStruDLZ , 'MdFieldDLZ')   
oView:CreateHorizontalBox('CABECALHO', 100)  
oView:SetOwnerView('VwFieldDLZ','CABECALHO')

Return oView

/*/-----------------------------------------------------------
{Protheus.doc} CommitMdl()
Definição da CommitMdl

Uso: TMSAC10

@sample
//CommitMdl()

@author Felipe M. Barbiere
@since 07/04/2020
@version 1.0
-----------------------------------------------------------/*/
Static Function CommitMdl(oModel)
Local nOperation := oModel:GetOperation()

	Begin Transaction	
		
		//-- Limpa informações Token
		If nOperation != MODEL_OPERATION_DELETE
			oModel:LoadValue("MdFieldDLZ","DLZ_TOKEN","")
			oModel:LoadValue("MdFieldDLZ","DLZ_DTTOKE",CTOD(""))
			oModel:LoadValue("MdFieldDLZ","DLZ_HRTOKE","")
			oModel:LoadValue("MdFieldDLZ","DLZ_EXPIRE",0)
		EndIf

		FwFormCommit(oModel ,/*bBefore*/,/*bAfter*/,/*bAfterSTTS*/)
	End Transaction

Return .T.


/*/-----------------------------------------------------------
{Protheus.doc} PosVldMdl()
pos validações

Uso: TMSAO52

@sample
//ViewDef()

@author Felipe M. Barbiere
@since 07/04/2020
@version 1.0
-----------------------------------------------------------/*/
Static Function PosVldMdl(oModel)
Local lRet			:= .T. 
Local aAreaDLZ		:= DLZ->(GetArea())
Local nOperation	:= oModel:GetOperation()
Local cAlias		:= ""
Local cAliasQry		:= ""

If ( nOperation == 3 .Or. nOperation == 4 ) .And. FwFldGet("DLZ_MSBLQL") == "2"

	cAliasQry	:= GetNextAlias()

	cQuery	:= " SELECT * "
	cQuery	+= " FROM " + RetSQLName("DLZ") + " DLZ "
	cQuery	+= " WHERE DLZ_FILIAL = '" + xFilial("DLZ") + "' "
	cQuery	+= " AND DLZ_SEQUEN <> '" + FwFldGet("DLZ_SEQUEN")  + "' "
	cQuery	+= " AND DLZ_MSBLQL = '2' " //-- Desbloqueado
	cQuery	+= " AND DLZ.D_E_L_E_T_ = '' "
							
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

	If (cAliasQry)->(!Eof())
		lRet	:= .F. 
	EndIf

	(cAliasQry)->( dbCloseArea() )
	
	If !lRet
		Help("",1,"TMSAC10001") //-- Não é permitido mais de um ID ativo.                        
	EndIf

EndIf

RestArea(aAreaDLZ)
Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} TMSC10Conn()
Testar Conexão

Uso: TMSAO52

@sample
//ViewDef()

@author Caio Murakami
@since 16/04/2020
@version 1.0
-----------------------------------------------------------/*/
Function TMSC10Conn()
Local aResult	:= {}
Local cResult	:= ""

Processa( { |lEnd| aResult := TMSChkTok( DLZ->DLZ_ID , DLZ->DLZ_SECRET , DLZ->DLZ_TENANT , DLZ->DLZ_URLTOK , DLZ->DLZ_USER , DLZ->DLZ_PASSW , DLZ->DLZ_SEQUEN ) }, , STR0008 , .T. )  //-- Processando...

If Len(aResult) > 0 
	cResult	:= aResult[2]
	If aResult[1]		
		MsgInfo( "Token: " + SubStr( cResult, 1, 50 ) , STR0009 ) //-- Resultado
	Else
		MsgStop( RTrim(cResult) , STR0009 )
	EndIf
Else
	MsgStop( RTrim(cResult) , STR0009 )
EndIf

Return

