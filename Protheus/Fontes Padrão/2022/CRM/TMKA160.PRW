#INCLUDE 'TMKA160.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TMKDEF.CH'
#INCLUDE 'FWMVCDEF.CH'

Static lAutomacao := .F.   //Variavel utilizada para automa็ใo de teste

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTMKA160   บAutor  ณVendas e CRM        บ Data ณ  11/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCadastramento no modulo padrao da REGRA DE SELECAO          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTELECOBRANCA                                                บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณFernando  ณ12/12/06ณ9.12  ณBops 115400 Alterado a array aRotina        ณฑฑ
ฑฑณ          ณ        |      ณpara cria็ใo do menu funcional              ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TMKA160(xRotAuto,nOpc)

Local oBrowse
Private aRotina := MenuDef() 
Private cCadastro := STR0006 //"Atualizacao de Regra de Selecao"
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao de variaveis para rotina de inclusao automatica    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private lTk160Auto := ( xRotAuto <> NIL )

If xRotAuto == NIL
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('SK0')
	oBrowse:SetDescription(STR0006) // Atualizacao na regra de selecao
	oBrowse:Activate()
Else
	aRotina := MenuDef()
	FWMVCRotAuto(ModelDef(),"SK0",nOpc,{{"TMKA160_SK0",xRotAuto}})
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun็ใo    ณMenuDef   ณ Autor ณ Vendas CRM		      ณ Data ณ  12/01/12 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri็ใo ณFuncao de definicao do aRotina                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณaRotina   retorna a array com lista de aRotina               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณTmkA160                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function MenuDef()

Local aRotAdic	:= {}		// Retorno do P.E. TK160ROT
Local lTk160Rot := ExistBlock("TK160ROT") 
Local aRotina   := {}

ADD OPTION aRotina TITLE STR0001 ACTION 'PesqBrw' 			OPERATION 1	ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.TMKA160'	OPERATION 2	ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0003 ACTION 'TK160IncMV()'	    OPERATION 3	ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.TMKA160'	OPERATION 4	ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.TMKA160'	OPERATION 5	ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.TMKA160'	OPERATION 4  	ACCESS 2 //"Reordenar"


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Ponto de entrada - Adiciona rotinas ao aRotina               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lTk160Rot
	aRotAdic := ExecBlock("TK160ROT" , .F. , .F.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	Endif
Endif

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณModelDef  บ Autor ณ Vendas CRM         บ Data ณ 12/01/12    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefine o modelo de dados (MVC)                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTmkA160                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ModelDef()
Local oModel
Local oStruSK0 		:= FWFormStruct(1,'SK0',/*bAvalCampo*/,/*lViewUsado*/)

If ( oStruSK0:HasField("K0_DSITCB") .And. !Empty( oStruSK0:GetProperty("K0_SITUACA" , MODEL_FIELD_VALUES ) ) ) 
	oStruSK0:SetProperty("K0_SITUACA" , MODEL_FIELD_VALUES, {} )
EndIf    

oModel := MPFormModel():New('TMKA160',/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)
oModel :AddFields('SK0MASTER',/*cOwner*/,oStruSK0,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
oModel :SetVldActivate( { |oMdl|TK160Pre(oMdl) } )
Return(oModel)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณViewDef   บ Autor ณ Vendas CRM         บ Data ณ  11/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefine a interface para cadastro em MVC.                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTmkA160                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ViewDef()

Local oView
Local oModel   	:= FWLoadModel('TMKA160')
Local oStruSK0	:= FWFormStruct(2,'SK0')

If ( oStruSK0:HasField("K0_DSITCB") .And. !Empty( oStruSK0:GetProperty("K0_SITUACA" , MVC_VIEW_COMBOBOX ) ) ) 
	oStruSK0:SetProperty("K0_SITUACA" , MVC_VIEW_COMBOBOX, {} )
EndIf    
 
oView := FWFormView():New()
oView :SetModel(oModel) 
oView :AddField('VIEW_SK0', oStruSK0,'SK0MASTER')
oView :CreateHorizontalBox('TELA',100)
oView :SetOwnerView('VIEW_SK0','TELA')
Return(oView)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK160Inc  บAutor  ณArmando M. Tessaroliบ Data ณ  17/09/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao especifica de Inclusao da regra de selecao SK0.      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTELECOBRANCA                                                บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณAndrea F. ณ29/03/04ณ811   ณ- Preenchimento do campo K0_SITUACA na incluณฑฑ
ฑฑณ          ณ        ณ      ณsao de uma regra para lista de cobranca.    ณฑฑ
ฑฑณ          ณ        ณ      ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TK160Inc(cAlias, nReg, nOpc)

Local nSaveSx8 	:= 0	// Funcao de numeracao
Local lTpCobra 	:= .F.	// Flag que define o tipo de cobranca: Cobranca x Grupo ou Lista de Cobranca

Default cAlias	:= "SK0"
Default nOpc	:= 3

If ( Type("lTk160Auto") == "U" )
	lTk160Auto := .F.
EndIf

If !lTk160Auto
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe a tabela ja estiver com a Regra de cobranca por Listas de Cobranca - NAO PERMITE NENHUMA INCLUSAO ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("SK0")
	DbSetOrder(1)
	If !MsSeek(xFilial("SK0"))
		If TmkOk(STR0011) //"Deseja implantar a Telecobran็a utilizando as Listas de Cobran็a ?"
			nSaveSx8 := GetSX8Len()  // Funcao de numeracao
			RecLock("SK0", .T.)
			SK0->K0_FILIAL	:= xFilial("SK0")
			SK0->K0_REGSEL	:= GetSxeNum("SK0","K0_REGSEL")
			SK0->K0_DESC	:= STR0012			//"REGRA PARA LISTAS DE COBRANวAS"
			SK0->K0_ORDEM	:= "000001"
			SK0->K0_PRAZO	:= "999999"
			SK0->K0_SITUACA := Padr("0",Len(SK0->K0_SITUACA)) //Carteira
			MsUnlock()
			While (GetSx8Len() > nSaveSx8)
				ConfirmSX8()
			End
			lTpCobra := .T.
		Endif
	Else
		If TK160List()
			Help("  ",1,"TK160LISTA")
			Return(.F.)
		Endif
	Endif
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe for entrada automatica e a tabela estiver vazia nao CADASTRA porque e necessario escolher o tipo de cobrancaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("SK0")
	DbSetOrder(1)
	If !MsSeek(xFilial("SK0"))
		Return(.F.)
	Endif	
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe nao for entrada automatica - exibe a tela de inclusaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !lTk160Auto
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe o usuario nao vai usar a telecobranca por Listas de Cobrancasณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !lTpCobra
		AxInclui(cAlias, nReg, nOpc)
	Endif	
Else    
	AxIncluiAuto(cAlias)
Endif

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK160Alt  บAutor  ณArmando M. Tessaroliบ Data ณ  17/09/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao especifica de alteracao da regra de selecao SK0.     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTELECOBRANCA                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TK160Alt(cAlias, nReg, nOpc)

Local aArea	:= GetArea()	// Salva a area atual
Local lRet	:= .T.			// Retorno da funcao
Local aParam	:= {}

Aadd(aParam, {|| .T. } )
Aadd(aParam, {|| Tk160VldAlt() } )		// Funcao para validar se a alteracao pode ser executada. 
Aadd(aParam, {|| .T. } )
Aadd(aParam, {|| .T. } )

If ( Type("lTk160Auto") == "U" )
	lTk160Auto := .F.
Endif

DbSelectArea("SK0")
DbSetOrder(1)
If MsSeek(xFilial("SK0"))
	While !Eof() .AND. xFilial("SK0") == SK0->K0_FILIAL
		If TK160List()
			Help("  ",1,"TK160LISTA")
			lRet := .F.
			Exit
		Endif
		SK0->(DbSkip())	
	End	
Endif

Restarea(aArea)

If lRet
	If !lTk160Auto
		AxAltera(cAlias, nReg, nOpc, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, aParam)
	Else
		If Tk160VldAlt()
			AxIncluiAuto(cAlias,NIL,NIL,nOpc,SK0->(RecNo()))
		Endif
	Endif
Endif	

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK160Del  บAutor  ณArmando M. Tessaroliบ Data ณ  17/09/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao especifica de exclusao da regra de selecao SK0       บฑฑ
ฑฑบ          ณValidacao independente da integridade referencial.          บฑฑ
ฑฑบ          ณ- Se a regra existe em algum Grupo de Atendimento           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTELECOBRANCA                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk160Del(cAlias, nReg, nOpc)

Local aArea	:= GetArea()
Local lRet	:= .T.

If ( Type("lTk160Auto") == "U" )
	lTk160Auto := .F.
EndIf

DbSelectArea("SU0")
DbSetOrder(1)
#IFDEF TOP
	cQuery	:=	" SELECT U0_FILIAL, U0_REGSEL " +;
				" FROM " +	RetSqlName("SU0") + " SU0 " +;
				" WHERE	SU0.U0_FILIAL = '" + xFilial("SU0") + "' AND" +;
				"		SU0.U0_REGSEL = '" + SK0->K0_REGSEL + "' AND" +;
				"		SU0.D_E_L_E_T_ = ''" +;
				" ORDER BY " + SqlOrder(IndexKey())
	
	cQuery	:= ChangeQuery(cQuery)
	// MemoWrite("TK190Del.SQL", cQuery)
	DbSelectArea("SU0")
	DbCloseArea()
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SU0', .F., .T.)
	
#ELSE
	MsSeek(xFilial("SU0"))
#ENDIF

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValida se existe algum Grupo de Atendimento com essa Regra em usoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
While !Eof() .AND. SU0->U0_FILIAL == xFilial("SU0")
	
	If SU0->U0_REGSEL == SK0->K0_REGSEL
		lRet := .F.
		Exit
	Endif
	
	DbSelectArea("SU0")
	DbSkip()
End

#IFDEF TOP
	DbSelectArea("SU0")
	DbCloseArea()
	ChkFile("SU0")
#ENDIF

RestArea(aArea)

If lRet
	If !lTk160Auto
		AxDeleta(cAlias, nReg, nOpc)
	Else
		DbSelectarea(cAlias)
		RecLock(cAlias,.F.,.T.)
		DbDelete()
		MsUnlock()
	Endif
Else
	If !lTk160Auto
		Help("  ",1,"TMKNDELREL")
		AxVisual(cAlias, nReg, nOpc)
	Endif
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK160Reo  บAutor  ณArmando M. Tessaroliบ Data ณ  13/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao especifica para reordenar com intervalo de 10 o campoบฑฑ
ฑฑบ          ณde ordem de selecao dos titulos.                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTELECOBRANCA                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TK160Reo()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Nใo reordena se a telecobranca for por Listas de Cobrancas     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If TK160List()
	Help("  ",1,"TK160LISTA")
	Return(.F.)
Endif

Processa( {|| TK160Reordena() }, STR0008)		// "Reordenando Regras de Selecao"

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณTK160ReordenaบAutorณArmando M. Tessaroliบ Data ณ  13/10/03  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao especifica para reordenar com intervalo de 10 o campoบฑฑ
ฑฑบ          ณde ordem de selecao dos titulos.                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTELECOBRANCA                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TK160Reordena()

Local aRegSel	:= {}	// Carrega as Regras de Selecao
Local nOrdem	:= 0
Local nI		:= 0

DbSelectarea("SK0")
DbSetOrder(2)		// K0_FILIAL+K0_ORDEM
ProcRegua(RecCount()*2)

If MsSeek(xFilial("SK0"))
	While !Eof() .AND. SK0->K0_FILIAL == xFilial("SK0")
		nOrdem+=10
		Aadd(aRegSel, {SK0->K0_REGSEL, StrZero(nOrdem,6)} )
		DbSkip()
		IncProc(STR0009)		// "Lendo Regras..."
	End
Endif

DbSelectarea("SK0")
DbSetOrder(1)		// K0_FILIAL+K0_REGSEL
For nI := 1 To Len(aRegSel)
	If MsSeek(xFilial("SK0") + aRegSel[nI][1])
		RecLock("SK0")
		SK0->K0_ORDEM := aRegSel[nI][2]
		MsUnlock()
	Endif
	IncProc(STR0010)		// "Gravando Regras..."
Next

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK160OrdemบAutor  ณArmando M. Tessaroliบ Data ณ  02/06/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณValidacao do conteudo do campo que define a ordem dos gruposบฑฑ
ฑฑบ          ณde atendimento para realizar as cobrancas.                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTELECOBRANCA                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk160Ordem()

Local aArea	:= GetArea()
Local lRet	:= .T.
Local nRec	:= Recno()

M->K0_ORDEM := StrZero(VaL(M->K0_ORDEM),6)

If VAL(M->K0_ORDEM) > 0
	DbSelectarea("SK0")
	DbSetOrder(2)
	If MsSeek(xFilial("SK0") + M->K0_ORDEM) .AND. nRec <> Recno()
		Help(" ",1,"TK160JATEM" )
		lRet := .F.
	EndIf
Else
	Help(" ",1,"TK160NZERO" )
	lRet := .F.
EndIf

RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK160PrazoบAutor  ณArmando M. Tessaroliบ Data ณ  02/06/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณValidacao do conteudo do campo que define o prazo dos gruposบฑฑ
ฑฑบ          ณde atendimento para realizar as cobrancas.                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTELECOBRANCA                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk160Prazo()

Local aArea		:= GetArea()
Local lRet		:= .T.
Local nTotPrazo	:= 0

M->K0_PRAZO := StrZero(VaL(M->K0_PRAZO),6)

If VAL(M->K0_PRAZO) <= 0
	Help(" ",1,"TK160NZERO" )
	lRet := .F.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณA somatoria de todos os prazos de cobranca nao podem ultrapassar 100000ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nTotPrazo := Val(M->K0_PRAZO)
DbSelectArea("SK0")
DbSetOrder(1)
MsSeek(xFilial("SK0"))
While !Eof() .AND. SK0->K0_FILIAL == xFilial("SK0")
	nTotPrazo := nTotPrazo + Val(SK0->K0_PRAZO)
	DbSkip()
End
If nTotPrazo > 100000
	Help(" ",1,"TK160PRAZO" )
	lRet := .F.
Endif

RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk160VldAltบAutor ณArmando M. Tessaroliบ Data ณ  28/01/04   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a alteracao da ordem e do prazo na regra de selecao  นฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk160VldAlt()

Local aArea := GetArea()
Local lRet  := .T.

If (!Empty(SK0->K0_ORDEM) .AND. M->K0_ORDEM <> SK0->K0_ORDEM) .OR.;
   (!Empty(SK0->K0_PRAZO) .AND. M->K0_PRAZO <> SK0->K0_PRAZO)
	
	// Valida se a Regra esta no Grupo de Atendimento 
	DbSelectArea("SU0")
	DbSetOrder(1)
	MsSeek(xFilial("SU0"))
	While !Eof() .AND. SU0->U0_FILIAL == xFilial("SU0")
		
		If SU0->U0_REGSEL <> SK0->K0_REGSEL
			DbSelectArea("SU0")
			DbSkip()
			Loop
		Endif
		
		// Se existe a Regra - Verifica quais os operadores desse Grupo de Atendimento
		DbSelectArea("SU7")
		DbSetOrder(1)
		MsSeek(xFilial("SU7"))
		While !Eof() .AND. SU7->U7_FILIAL == xFilial("SU7")
			
			If SU7->U7_POSTO <> SU0->U0_CODIGO
				DbSelectArea("SU7")
				DbSkip()
				Loop
			Endif
		    
			// Procura pelas "contas" no SK1 desse Operador - sobre os titulos vencidos 			
			DbSelectArea("SK1")
			DbSetOrder(3)		// K1_FILIAL+K1_OPERAD
			If MsSeek(xFilial("SK1") + SU7->U7_COD)
				lRet := .F.
			Endif
			
			// Se encontrou um titulo para o Operador verifica se existe lista de cobranca pendente
			If lRet
				DbSelectArea("SU4")
				DbSetOrder(5)		// U4_FILIAL+U4_OPERAD+U4_STATUS
				MsSeek(xFilial("SU4") + SU7->U7_COD)
				While	!Eof()								.AND.;
						SU4->U4_FILIAL == xFilial("SU4")	.AND.;
						SU4->U4_OPERAD == SU7->U7_COD
					
					If SU4->U4_STATUS <> "2" .AND. Val(SU4->U4_TIPO) == COBRANCA		// Nao encerrada e de Cobranca
						lRet := .F.
						Exit
					Endif
					
					DbSelectArea("SU4")
					DbSkip()
				End
			Endif
			
			If !lRet
				Exit
			Endif
			
			DbSelectArea("SU7")
			DbSkip()
		End
		
		If !lRet
			Exit
		Endif
		
		DbSelectArea("SU0")
		DbSkip()
	End
	
Endif

If !lRet
	Help( " ", 1, "TMKTLCRGA" )
Endif

RestArea(aArea)

Return(lRet)

// Inicio das verificacoes para o MVC

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK160Pre  บAutor  ณVendas e CRM        บ Data ณ  12/01/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao faz a pre validacao dos cadastros em MVC             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTELECOBRANCA                                                บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function TK160Pre (oMdl)
Local nOpc	:= oMdl:GetOperation()
Local lRet := .T.

If nOpc == 4
	lRet:= TK160AltMV()
Elseif nOpc == 5
	lRet:= Tk160DelMV()
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK160IncMVบAutor  ณArmando M. Tessaroliบ Data ณ  17/09/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao especifica de Inclusao da regra de selecao SK0.      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTELECOBRANCA                                                บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณAndrea F. ณ29/03/04ณ811   ณ- Preenchimento do campo K0_SITUACA na incluณฑฑ
ฑฑณ          ณ        ณ      ณsao de uma regra para lista de cobranca.    ณฑฑ
ฑฑณ          ณ        ณ      ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TK160IncMV(cAlias,nReg,nOpc)

Local nSaveSx8 	:= 0	// Funcao de numeracao
Local lRet		:= .T.
Local lRegraSel := .T. 
Local lSeekSK0  := .F.

Default cAlias	:= "SK0"
Default nOpc	:= 3

If ( Type("lTk160Auto") == "U" )
	lTk160Auto := .F.
EndIf

If !lTk160Auto
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe a tabela ja estiver com a Regra de cobranca por Listas de Cobranca - NAO PERMITE NENHUMA INCLUSAO ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("SK0")
	DbSetOrder(1)
		
	lSeekSK0 := MsSeek(xFilial("SK0"))
	
	If lSeekSK0 // Tem registro no cadastro de Regras de Selecao 
		If (TK160List()) // Telecobran็a por lista na filial
			Help("  ",1,"TK160LISTA")
			Return(.F.)
		EndIf
	Else
		If !IsBlind() 
			lRet := TmkOk(STR0011)
		Endif

		If lRet .Or. lAutomacao
			lRet := Tk160LstAut()
			lRegraSel := .F.
		Endif
	EndIf
	
	If lRegraSel
		FWExecView("",'TMKA160', MODEL_OPERATION_INSERT,, { || .T. } )
	Endif
	
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe for entrada automatica e a tabela estiver vazia nao CADASTRA porque e necessario escolher o tipo de cobrancaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("SK0")
	DbSetOrder(1)
	If !MsSeek(xFilial("SK0"))
		Return(.F.)
	Endif	
Endif
	 
Return lRet

//------------------------------------------------------------------------------
/*/	{Protheus.doc} Tk160LstAut()
Fun็ใo para incluir um Lista Automaticamente

@sample 	Tk160LstAut()
@return		lRet,	Logico, -  Retorna se o registro foi incluido.
@author		Squad CRM
@since		01/07/2019
@version	P12.1.25
/*/
//------------------------------------------------------------------------------
Function Tk160LstAut()

	Local aErro		:= {}
	Local cTitHelp	:= ""
	Local lRet		:= .T.
	Local oModel 	:= ModelDef()
	Local oMdlSK0	:= Nil

	oModel:SetOperation(MODEL_OPERATION_INSERT)	
	oModel:Activate()

	If oModel:IsActive()
		oMdlSK0	:= oModel:GetModel("SK0MASTER")

		oMdlSK0:SetValue( "K0_DESC"		, STR0012 )
		oMdlSK0:SetValue( "K0_ORDEM"	, "000001" )
		oMdlSK0:SetValue( "K0_PRAZO"	, "999999" )
		oMdlSK0:LoadValue( "K0_SITUACA"	, Padr( "0", Len( SK0->K0_SITUACA ) ) )

		If oModel:VldData()
			lRet := oModel:CommitData()
		Else
			lRet := .F.
		Endif
	Else
		lRet := .F.
	Endif

	If !lRet
		aError := oModel:GetErrorMessage()		
		cTitHelp := If( !Empty( aError[5] ), aError[5], "Tk160LstAut")
		Help("", 1, cTitHelp, , aError[6], 1, 0, , , , , , {aError[7] } )
	Endif
	
	aSize( aErro, 0 )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK160AltMVบAutor  ณVendas e CRM        บ Data ณ  12/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao especifica de alteracao da regra de selecao SK0.     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTELECOBRANCA                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TK160AltMV(cAlias, nReg, nOpc)

Local aArea		:= GetArea()	// Salva a area atual
Local lRet		:= .T.			// Retorno da funcao
Local aParam	:= {}

Aadd(aParam, {|| .T. } )
Aadd(aParam, {|| Tk160VldAlt() } )		// Funcao para validar se a alteracao pode ser executada. 
Aadd(aParam, {|| .T. } )
Aadd(aParam, {|| .T. } )

If ( Type("lTk160Auto") == "U" )
	lTk160Auto := .F.
Endif

DbSelectArea("SK0")
DbSetOrder(1)
If MsSeek(xFilial("SK0"))
	While !Eof() .AND. xFilial("SK0") == SK0->K0_FILIAL
		If TK160List()
			Help("  ",1,"TK160LISTA")
			lRet := .F.
			Exit
		Endif
		SK0->(DbSkip())	
	End	
Endif

Restarea(aArea)

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk160DelMVบAutor  ณArmando M. Tessaroliบ Data ณ  17/09/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao especifica de exclusao da regra de selecao SK0       บฑฑ
ฑฑบ          ณValidacao independente da integridade referencial.          บฑฑ
ฑฑบ          ณ- Se a regra existe em algum Grupo de Atendimento           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTELECOBRANCA                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk160DelMV(cAlias, nReg, nOpc)

Local aArea	:= GetArea()
Local lRet	:= .T.

If ( Type("lTk160Auto") == "U" )
	lTk160Auto := .F.
EndIf

DbSelectArea("SU0")
DbSetOrder(1)
#IFDEF TOP
	cQuery	:=	" SELECT U0_FILIAL, U0_REGSEL " +;
				" FROM " +	RetSqlName("SU0") + " SU0 " +;
				" WHERE	SU0.U0_FILIAL = '" + xFilial("SU0") + "' AND" +;
				"		SU0.U0_REGSEL = '" + SK0->K0_REGSEL + "' AND" +;
				"		SU0.D_E_L_E_T_ = ''" +;
				" ORDER BY " + SqlOrder(IndexKey())
	
	cQuery	:= ChangeQuery(cQuery)
	// MemoWrite("TK190Del.SQL", cQuery)
	DbSelectArea("SU0")
	DbCloseArea()
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SU0', .F., .T.)
	
#ELSE
	MsSeek(xFilial("SU0"))
#ENDIF

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValida se existe algum Grupo de Atendimento com essa Regra em usoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
While !Eof() .AND. SU0->U0_FILIAL == xFilial("SU0")
	
	If SU0->U0_REGSEL == SK0->K0_REGSEL
		lRet := .F.
		Exit
	Endif
	
	DbSelectArea("SU0")
	DbSkip()
End

#IFDEF TOP
	DbSelectArea("SU0")
	DbCloseArea()
	ChkFile("SU0")
#ENDIF

RestArea(aArea)

If lRet
	If lTk160Auto
		DbSelectarea(cAlias)
		RecLock(cAlias,.F.,.T.)
		DbDelete()
		MsUnlock()
	Endif
Else
	If !lTk160Auto
		Help("  ",1,"TMKNDELREL")
	Endif
Endif

Return(lRet)

//------------------------------------------------------------------------------
/*/	{Protheus.doc} Tk160GatOrd

Fun็ใo executada via gatilho do campo K0_ORDEM para preencher automaticamente
o campo Ordem com zeros. 
Atualzida em 27/03/2016 - Regra atualizada para contemplar valor de campo via MVC

A partir da versใo 12 do Protheus. 

@sample 	Tk160GatOrd() 
		
@return		Nil

@author		Squad CRM/Faturamento
@since		02/06/2003
/*/
//------------------------------------------------------------------------------
Function Tk160GatOrd() 

Local oModel 	:= FWModelActive()
Local oModelSK0	:= Nil 
Local cRet 		:= ""
Local nSize		:= 0

If !Empty( oModel )
	nSize		:= TamSx3("K0_ORDEM")[1]
 	oModelSK0 	:= oModel:getModel('SK0MASTER')
 	cRet 		:= oModelSK0:GetValue("K0_ORDEM")
 	
 	If Len( Alltrim(cRet) ) < nSize
 		cRet 	:= StrZero(VaL(cRet),nSize) 
 	EndIf
 	
 	oModelSK0:LoadValue ( 'K0_ORDEM', cRet )

	
	oView	:= FWViewActive()
		
	If Type( "oView" ) <> "U" .And. oView:IsActive()
		oView:Refresh('SK0MASTER')
	EndIf	

EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณTk160GatPr   บAutor  ณVendas e CRM        บ Data ณ02/06/03  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณGatilho do conteudo do campo que define o prazo dos grupos บฑฑ
ฑฑบ          ณde atendimento para realizar as cobrancas.                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTELECOBRANCA                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk160GatPr() 

Local oModel := FWModelActive()
Local oModelSK0
Local cRet := ""


oModelSK0 := oModel:getModel('SK0MASTER')
cRet := StrZero(VaL(oModelSK0:GetValue("K0_PRAZO")),6)

oModelSK0:LoadValue ( 'K0_PRAZO', cRet )


oView := FWViewActive()

If Type( "oView" ) <> "U" .And. oView:IsActive()
  oView:Refresh('SK0MASTER')
EndIf

Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณTk160ValPr   บAutor  ณVendas e CRM        บ Data ณ02/06/03  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณValidacao do conteudo do campo que define o prazo dos gruposบฑฑ
ฑฑบ          ณde atendimento para realizar as cobrancas.                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTELECOBRANCA                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk160ValPr()

Local nTotPrazo	:= 0
Local aArea		:= GetArea()
Local lRet		:= .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณA somatoria de todos os prazos de cobranca nao podem ultrapassar 100000ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nTotPrazo := Val(M->K0_PRAZO)
DbSelectArea("SK0")
DbSetOrder(1)
MsSeek(xFilial("SK0"))
While !Eof() .AND. SK0->K0_FILIAL == xFilial("SK0")
	nTotPrazo := nTotPrazo + Val(SK0->K0_PRAZO)
	DbSkip()
End
If nTotPrazo > 100000
	Help(" ",1,"TK160PRAZO" )
	lRet := .F.
Endif

RestArea(aArea)

Return (lRet)

//------------------------------------------------------------------------------
/*/	{Protheus.doc} Tk160Auto

Fun็ใo para definir se na automa็ใo de teste qual caminho ele irแ fazer 
Lista de Cobran็a := .T. e Lista de Sele็ใo := .F.

@sample 	Tk160Auto(lParam)

@param		Expl1 - Valor para definir a lista que serแ gerada
			
@return		ExpL - Verdadeiro / Falso

@author		Servi็os
@since		14/03/2014
@version	P118
/*/
//------------------------------------------------------------------------------
Function Tk160Auto(lParam)
lAutomacao := lParam
Return(lAutomacao)
//------------------------------------------------------------------------------
/*/	{Protheus.doc} TK160List()

Fun็ใo para definir se o registro ้ uma Lista ou uma Regra
.T. = Lista  | .F. = Regra

@sample 	TK160List()
@return		lRet,	Logico, -  Retorna se o registro ้ uma Lista.

@author		Squad CRM/Faturamento
@since		19/06/2019
@version	P1223
/*/
//------------------------------------------------------------------------------

Static Function TK160List()

	Local lRet := .F.

	If SK0->K0_ORDEM == "000001" .AND. SK0->K0_PRAZO == "999999"
		lRet := .T.
	EndIf
	
Return lRet