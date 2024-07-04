#INCLUDE "PROTHEUS.CH"
#INCLUDE "FATA510.CH"  
#INCLUDE 'FWMVCDEF.CH'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA510   บAutor  ณVendas Clientes     บ Data ณ  19/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCadastro de Unidades de Negocio                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGACRM                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FATA510()

Local oTableAtt := TableAttDef()

Private cCadastro	:= STR0001 //"Cadastro de Unidades de Neg๓cio"
Private aRotina		:= MenuDef()

dbSelectArea("SX2")
dbSetOrder(1)
If !DbSeek("ADK")
	Aviso( STR0008, STR0007 , { STR0009 } ) //"Aten็ใo"###"Executar o Update TKUpdADK() para gerar os arquivos necessแrios para utilizar essa rotina"###"Ok"
	Return Nil
Endif

dbSelectArea("ADK")
dbSetOrder(1)

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('ADK')                                       
oBrowse:SetDescription(STR0001) //"Cadastro de Unidades de Neg๓cio"

oBrowse:SetAttach( .T. ) 		 //Habilita as vis๕es do Browse
//Se nใo for SIGACRM inibe a exibi็ใo do grแfico
If nModulo <> 73
	oBrowse:SetOpenChart( .F. )
EndIf
oBrowse:SetViewsDefault( oTableAtt:aViews ) 

oBrowse:SetTotalDefault('ADK_FILIAL','COUNT',STR0013) // 'Total de Registros'
oBrowse:Activate()

Return .T.


//------------------------------------------------------------------------------
/*/	{Protheus.doc} TableAttDef

Cria as vis๕es e grแficos.

@sample	TableAttDef()

@param		Nenhum

@return	ExpO - Objetos com as Visoes e Grแficos.

@author	Cristiane Nishizaka
@since		28/04/2014
@version	12
/*/
//------------------------------------------------------------------------------
Static Function TableAttDef()

Local oTableAtt 	:= FWTableAtt():New()
// Vis๕es  
Local oAtivos		:= Nil // Unidades de Neg๓cio Ativas 
Local oInativos	:= Nil // Unidades de Neg๓cio Inativas

oTableAtt:SetAlias("ADK")

//----------
// Vis๕es
//---------- 

// Unidades de Neg๓cio Ativas 
oAtivos := FWDSView():New()
oAtivos:SetName(STR0011) // "Unidades de Neg๓cio Ativas"
oAtivos:SetOrder(1) // ADK_FILIAL+ADK_COD
oAtivos:SetCollumns({"ADK_COD","ADK_NOME","ADK_RAZAO","ADK_TIPO","ADK_END",;
						"ADK_BAIRRO","ADK_MUN","ADK_EST","ADK_PAIS","ADK_DDD","ADK_TEL","ADK_EMAIL"})
oAtivos:SetPublic( .T. )
oAtivos:AddFilter(STR0011, "ADK_MSBLQL == '2'") // "Unidades de Neg๓cio Ativas"

oTableAtt:AddView(oAtivos)

// Unidades de Neg๓cio Inativas
oInativos := FWDSView():New()
oInativos:SetName(STR0012) // "Unidades de Neg๓cio Inativas"
oInativos:SetOrder(1) // ADK_FILIAL+ADK_COD
oInativos:SetCollumns({"ADK_COD","ADK_NOME","ADK_RAZAO","ADK_TIPO","ADK_END",;
						"ADK_BAIRRO","ADK_MUN","ADK_EST","ADK_PAIS","ADK_DDD","ADK_TEL","ADK_EMAIL"})
oInativos:SetPublic( .T. )
oInativos:AddFilter(STR0012, "ADK_MSBLQL == '1'") // "Unidades de Neg๓cio Inativas"

oTableAtt:AddView(oInativos)

Return (oTableAtt)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef   บAutor  ณVendas Clientes     บ Data ณ  22/11/2007 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina usada para realizar manueten็ใo na tabela ADK.      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA510                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
					  
Local aRotina   := {}
Local aRotAdic  := {}
Local lFt510Mnu	:= ExistBlock("FT510MNU")				//Valida a existencia do ponto de entrada
Local nX        := 0  

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw' 			OPERATION 1	ACCESS 0 //Pesquisar
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FATA510'	OPERATION 2	ACCESS 0 //Visualizar
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FATA510'	OPERATION 3	ACCESS 0 //Incluir
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FATA510'	OPERATION 4	ACCESS 0 //Alterar
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FATA510'	OPERATION 5	ACCESS 0 //Excluir 

aRotina:= CRMXINCROT("ADK",aRotina)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPonto de entrada para adicionar botoes |
//|no MenuDef                             |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If lFt510Mnu
	aRotAdic := ExecBlock("FT510MNU",.F.,.F.)
	If ValType(aRotAdic) == "A" 
		For nX := 1 to Len(aRotAdic)
			ADD OPTION aRotina TITLE aRotAdic [nX] [1] ACTION aRotAdic [nX] [2] OPERATION aRotAdic [nX] [4] ACCESS 0  
		Next nX
	EndIf
EndIf
					
Return(aRotina)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณModelDef  บAutor  ณVendas CRM          บ Data ณ  17/09/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefine o modelo de dados em MVC                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA510                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ModelDef()

Local oModel
Local oStruADK := FWFormStruct(1,'ADK', /*bAvalCampo*/,/*lViewUsado*/ )

Local bCommit		:= {|oMdl|FATA510Cmt(oMdl)}		//Gravacao dos dados

oStruADK:SetProperty("ADK_COD"	,MODEL_FIELD_WHEN,FwBuildFeature( STRUCT_FEATURE_WHEN,"FT510CodWhen()"))
oStruADK:SetProperty("ADK_COD",MODEL_FIELD_VALID,FwBuildFeature( STRUCT_FEATURE_VALID,"ExistChav('ADK')"))

oModel := MPFormModel():New('FATA510',/*bPreValidacao*/, {|oMdl|PosValid(oModel)} ,bCommit,/*bCancel*/ )
oModel:AddFields('ADKMASTER',/*cOwner*/,oStruADK, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:SetPrimaryKey({'ADK_FILIAL'},{'ADK_COD'})
oModel:SetDescription(STR0001)

Return oModel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณViewDef   บAutor  ณVendas CRM          บ Data ณ  17/09/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefine a interface para Tela de cadastro no MVC             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA510                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ViewDef()   

Local oView  
Local oModel   := FWLoadModel('FATA510')
Local oStruADK := FWFormStruct( 2,'ADK')  
Local aButtons := {}
Local cName
Local cAction 
Local nX       := 0


oView := FWFormView():New()
oView:SetContinuousForm()
oView:SetModel(oModel)
oView:AddField('VIEW_ADK',oStruADK,'ADKMASTER')
If nModulo == 73 
	oView:AddUserButton( STR0015, "",{ |oView| CRMA090(3) },,,{ MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE } )//"Nova Anota็ใo"
	oView:AddUserButton( STR0016, "",{ |oView| CRMA090( , "ADK" ) },,,{ MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE } )//"Todas as Anota็๕es"
EndIf
oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW_ADK','TELA') 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPonto de entrada para adicionar Botoes ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

aButtons := FATA510Pre()

For nX = 1 to Len(aButtons)
   cName := aButtons[nX][4]
   cAction := aButtons[nX][2]
   oView:addUserButton(cName," ",cAction,"") 
Next nX
    
Return oView   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA510CmtบAutor  ณVendas CRM          บ Data ณ  21/09/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBloco executado na gravacao dos dados do formulario, substi-บฑฑ
ฑฑบ          ณtuindo a gravacao padrao do MVC.                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFATA510                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FATA510Cmt(oMdl)

Local aArea			:= GetArea()
Local nOperation	:= oMdl:GetOperation()
Local lFt510Cnf		:= ExistBlock("FT510CNF")		//Ponto de entrada na finalizacao da tela 
Local nReg

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPonto de entrada na finalizacao da telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DBGoBottom()
nReg := RecNo()

If ((nOperation== 3 .OR. nOperation== 4) .AND. lFt510Cnf)
   	ExecBlock("FT510CNF",.F.,.F.,{"ADK",nReg,nOperation})
EndIf
If nOperation == MODEL_OPERATION_DELETE
	//--------------------------
	// Exclusao de Anota็๕es   
	//--------------------------     
	If nModulo == 73
		CRMA090Del( "ADK", ADK->( Recno() ) )
	EndIf
EndIf

RestArea( aArea )
FWModelActive( oMdl )
FWFormCommit( oMdl )                

Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA510   บAutor  ณMicrosiga           บ Data ณ  11/09/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Executa o Ponto de entrada e retorna Array com as posicoes บฑฑ
ฑฑบ          ณ do aButtons                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFata510                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FATA510Pre()

Local lFt510But		:= ExistBlock("FT510BUT")		//Ponto de entrada para inclusao de novos botoes 
Local aButtons      :={}

If lFt510But
	aButtons := ExecBlock("FT510BUT",.F.,.F.)
EndIf  

Return(aButtons)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA510   บAutor  ณMicrosiga           บ Data ณ  25/03/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se existe pelo menos um segmento selecionado -      บฑฑ
ฑฑบ          ณ SIGATUR                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFata510                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PosValid(oModel)

Local nOperation	:= 0
Local lLazer		:= ""
Local lCorpor		:= ""
Local lEvento		:= ""
Local cValid 		:= ""
Local lRet 		:= .T.

// VERIFICAR QUAL O TIPO DE OPERAวรO ESTA SENDO REALIZADA
nOperation 	:= oModel:GetOperation()

lCorpor 	:= FwFldGet("ADK_CORP")
lEvento 	:= FwFldGet("ADK_EVENTO")
lLazer 	:= FwFldGet("ADK_LAZER")
IF nModulo == 89 
	// VERIFICA SE ษ INCLUSรO OU ALTERAวรO?
	IF nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE 
		// VALIDA SE NENHUM SEGMENTO FOI SELECIONADO PARA ESTA ENTIDADE
		IF lCorpor == .F. .AND. lEvento == .F. .AND. lLazer == .F.
			Help("FATA510", 1, STR0008, , STR0014, 1, 0) // "Aten็ใo" - "ษ necessแrio selecionar pelo menos um segmento para esta Entidade."	
			lRet:= .F.
		ENDIF
	ENDIF
ENDIF

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATA510   บAutor  ณMicrosiga Protheus  บ Data ณ  10/04/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retonar True para altera็ใo do campo ADK na opera็ใo de    บฑฑ
ฑฑบ          ณ inclusใo                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFata510                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FT510CodWhen()
Local lRet 		:= .F.
Local oModel	:= FwModelActive()

If oModel <> Nil .And. oModel:GetId() == "FATA510"
	lRet := oModel:GetOperation() == 3
EndIf

Return( lRet )
