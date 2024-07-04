#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "TECA703.CH"

Static cItem := ""

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECA702

Planejamento de Execução - TX5, TX6
@author Mateus Boiani
@since 13/11/2018
@version 12.1.23

/*/
//----------------------------------------------------------------------------------------------------------------------

Function TECA703()
Local oBrw 		:= FwMBrowse():New() //Objeto Browse
Private aRotina	:= MenuDef() 		//Menu
oBrw:SetAlias( 'TX5' )
oBrw:SetDescription( OEmToAnsi( STR0001) )  //'Planejamento de Execução'
oBrw:Activate()

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Menudef

Menu do cadastro de Atividades
@author Mateus Boiani
@since 13/11/2018
@version 12.1.23
@param
@return aMenu  - Array de Menu
/*/
//----------------------------------------------------------------------------------------------------------------------
Static Function Menudef()

Local aMenu := {} //Menu

ADD OPTION aMenu Title STR0002 Action 'VIEWDEF.TECA703' OPERATION 2 ACCESS 0 	//'Visualizar'
ADD OPTION aMenu Title STR0003 Action 'VIEWDEF.TECA703' OPERATION 3 ACCESS 0 	//'Incluir'
ADD OPTION aMenu Title STR0004 Action 'VIEWDEF.TECA703' OPERATION 4 ACCESS 0 	//'Alterar'
ADD OPTION aMenu Title STR0005 Action 'VIEWDEF.TECA703' OPERATION 5 ACCESS 0 	//'Excluir'
ADD OPTION aMenu Title STR0006 Action 'VIEWDEF.TECA703' OPERATION 9 ACCESS 0    //'Copiar'

Return aMenu

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Modelo TECA702 - Cadastro de Atividades
@author Mateus Boiani
@since 13/11/2018
@version 12.1.23
@param
@return oModel  - Objeto Model
/*/
//----------------------------------------------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel		:= NIL //Modelo
Local oStrTX5 		:= FWFormStruct(1,'TX5') //Tabela TX5
Local oStrTX6 		:= FWFormStruct(1,'TX6') //Tabela TX6
Local bPosValidacao	:= { |oMdl| Tc703Pos( oMdl ) } //Bloco de PosValid do Modelo

oStrTX6:SetProperty( "TX6_CODPAI", MODEL_FIELD_OBRIGAT, .F. )

oModel := MPFormModel():New('TECA703',, bPosValidacao,/*Cancel*/)
oModel:SetDescription( STR0007 )  //'Roteiro de Tarefas'
oModel:addFields('TX5MASTER',,oStrTX5)
oModel:SetPrimaryKey({"TX5_FILIAL","TX5_CODIGO"})

oModel:addGrid('TX6DETAIL','TX5MASTER',oStrTX6, {|oModel, nLine,cAction| Tc703TX6Pre(cAction,nLine, oModel)}, { |oModel, nLine| Tc703TX6Pos(oModel, nLine)})
oModel:SetRelation('TX6DETAIL', { { 'TX6_FILIAL', 'xFilial("TX6")' }, { 'TX6_CODPAI', 'TX5_CODIGO' } }, TX6->(IndexKey(1)) )

oModel:getModel('TX5MASTER'):SetDescription(STR0008)	 //"Planejamento de Atividades"
oModel:getModel('TX6DETAIL'):SetDescription(STR0009)		 //"Lista de Atividades"

Return oModel

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

ViewDef TECA702 - Cadastro de Atividades
@author Mateus Boiani
@since 13/11/2018
@version 12.1.23
@param
@return oView  - Objeto View
/*/
//----------------------------------------------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= NIL	//Objeto View
Local oModel 	:= ModelDef() //Modelo Def
Local oStrTX5   := FWFormStruct( 2, "TX5" )  //Tabela TX5
Local oStrTX6   := FWFormStruct( 2, "TX6" ) //Tabela TX6


oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('VIEW_TX5', oStrTX5, 'TX5MASTER' )
oView:AddGrid('VIEW_TX6' , oStrTX6, 'TX6DETAIL')

oStrTX6:RemoveField('TX6_CODPAI')
oStrTX6:RemoveField('TX6_CODIGO')

oView:CreateHorizontalBox( 'TOP'   , 35 )
oView:CreateHorizontalBox( 'BOTTOM', 65 )

oView:SetOwnerView( "VIEW_TX5", "TOP" )
oView:SetOwnerView( "VIEW_TX6", "BOTTOM" )

Return oView

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tc703Pos

Validação do Modelo

@author Mateus Boiani
@since 13/11/2018
@version 12.1.23
@param 
@return lRet - Formulário válido

/*/
//------------------------------------------------------------------------------------------------------
Function Tc703Pos(oModel)
Local lRet 			:= .T. //Retorno


If oModel:GetOperation() != MODEL_OPERATION_DELETE .AND. oModel:GetValue( "TX5MASTER", "TX5_TEMPO"  ) <= 0
		
	Help( ,, STR0010,, STR0011, 1, 0 ) //STR0010##"Já existe a configuração de planilha" //"Atenção" //"Tempo Total do Planejamento deve ser informado"
	lRet := .F. 
			
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Tc703TX6Pre
Rotina para tratamento no pre valid do Modelo TX4

@param cAction - Acção
@param nLine - Linha
@param oMdlTX6 - Model Grid
@return .t.

@author Mateus Boiani
@since 13/11/2018
@version 12.1.23
/*/
//-------------------------------------------------------------------
Function Tc703TX6Pre(cAction,nLine, oMdlTX6)
Local lRet		:= .T. //Retorno
Local oModel 	:= oMdlTX6:GetModel() //Modelo
Local oMdlTX5	:= oModel:GetModel("TX5MASTER")//Modelo Cabeçalho

If cAction == 'UNDELETE' .Or. cAction == 'DELETE'
	Tc703Grd(oMdlTX6, oMdlTX5, cAction, nLine)
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Tc703TX6Pos
Rotina para tratamento no Pos valid do Modelo TX4

@param oMdlTX6 - Model Grid
@param nLine - Linha
@return lRet - Linha valida

@author Mateus Boiani
@since 13/11/2018
@version 12.1.23
/*/
//-------------------------------------------------------------------
Function Tc703TX6Pos(oMdlTX6, nLine)
Local lRet		:= .T. //Retorno
Local oModel  	:= oMdlTX6:GetModel() //Modelo
Local oMdlTX5	:= oModel:GetModel("TX5MASTER")//Modelo Cabeçalho

lRet := Tc703Grd(oMdlTX6, oMdlTX5, "", nLine)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Tc732Grd
Rotina para realizar a soma do tempo das tarefas e valida se não existe tarefa duplicada

@param oMdlTX6 - Itens da Atividade (lista de tarefas)
@param oMdlTX5 - Cabeçalho da Atividade (header)
@param cAction - Ação
@param nLinha - Linha a ser validade
@return lRet - Linha valida

@author Mateus Boiani
@since 13/11/2018
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function Tc703Grd(oMdlTX6, oMdlTX5, cAction, nLine)

Local nY 			:= 0 //Contador de Linhas do Model
Local aSaveRows 	:= {} //Linha corrente
Local nTotal 		:= 0 //Total de Atividades
Local lRet			:= .T. //Retorno

aSaveRows := FwSaveRows()

For nY := 1 To oMdlTX6:Length()
	
	oMdlTX6:GoLine(nY)
	
	If  cAction ==  'UNDELETE' .AND.  nY == nLine
		nTotal += oMdlTX6:GetValue('TX6_TEMPO')  
	ElseIf !(cAction ==  'DELETE' .AND.  nY == nLine)
			If !oMdlTX6:IsDeleted()
				nTotal += oMdlTX6:GetValue('TX6_TEMPO') 
			EndIf
	EndIf
Next nY

If lRet .AND.  nTotal > 0
	oMdlTX5:SetValue("TX5_TEMPO",nTotal)
EndIf

FwRestRows(aSaveRows)

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At703TFLLoc

Consulta padrão  Local TFLABS - Utilizada nas tabelas TX5 e TX7
@author Mateus Boiani
@since 13/11/2018
@version 12.1.23
@param 
@return lRet - Consulta realizada com sucesso
/*/
//----------------------------------------------------------------------------------------------------------------------
Function At703TFLLoc()
Local oModel        := FWModelActive() //Modelo Ativo
Local lRet          := .F. //Retorno da Consulta
Local oBrowse       := Nil //Objeto Browse
Local cAls          := GetNextAlias() //Alias da Consulta
Local nSuperior     := 0 //Coordenada da janela	
Local nEsquerda     := 0 //Coordenada da janela	
Local nInferior     := 0 //Coordenada da janela	
Local nDireita      := 0 //Coordenada da janela	
Local oDlgTela 		:= Nil //Objeto da janela
Local cQry  		:= "" //Query
Local aIndex 		:= {"TFL_LOCAL"}//Definição do índice da Consulta Padrão
Local aSeek 		:= {{ STR0012, {{STR0012,"C",TamSx3("TFL_LOCAL")[1],0,"",,}} }} //Definição da Descrição da Chave de Pesquisa da Consulta Padrão //STR0012 //"Local"
Local cCodCtt 		:= "" //Codigo do Contrato
Local cDesc 		:= "" //Descrição do Local
Local cCpoCtt 		:= 'TX5_CONTRT' //Campo do Contrato
Local cCpoLoc 		:= 'TX5_DESLOC' //Campo de Descrição do Local
Local cRet 			:= "" //Retorno da Consulta
Local cModel 		:= "" //Id do Modelo
Local cSubModel 	:= "TX5MASTER"

cItem := ""
cModel := oModel:GetId()

If cModel <> "TECA703"
	cSubModel <> "TX7MASTER"
	cCpoLoc := 'TX5_DESLOC'	
	cCpoCtt := 'TX7_CONTRT'
EndIf

cCodCtt := oModel:GetValue(cSubModel,cCpoCtt)

cQry := " SELECT " 
cQry += " TFL_FILIAL,"
cQry += " TFL_LOCAL, "
cQry += " ABS_DESCRI "
cQry += " FROM " + RetSqlName("TFL") + " TFL "
cQry += " INNER JOIN " + RetSqlName("ABS") + " ABS "
cQry += " ON ABS.ABS_FILIAL = '" +  xFilial('ABS') + "'"
cQry += " AND ABS.ABS_LOCAL = TFL.TFL_LOCAL"  
cQry += " AND ABS.D_E_L_E_T_ <> '*'"
cQry += " AND TFL.TFL_CONTRT = '"  + cCodCtt + "'"
 
cQry += " WHERE TFL_FILIAL = '" + xFilial('TFL') + "'"
cQry += " AND TFL.D_E_L_E_T_ <> '*'"
  
nSuperior := 0
nEsquerda := 0
nInferior := 460
nDireita  := 800

DEFINE MSDIALOG oDlgTela TITLE STR0013 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL  //"Locais"
 
oBrowse := FWFormBrowse():New()
oBrowse:SetDescription(STR0013)  //"Locais"
oBrowse:SetAlias(cAls)
oBrowse:SetDataQuery()
oBrowse:SetQuery(cQry)
oBrowse:SetOwner(oDlgTela)
oBrowse:SetDoubleClick({ || cRet := (oBrowse:Alias())->TFL_LOCAL, cDesc := (oBrowse:Alias())->ABS_DESCRI ,  lRet := .T., oDlgTela:End()})
oBrowse:AddButton( OemTOAnsi(STR0014), {|| cRet := (oBrowse:Alias())->TFL_LOCAL, lRet := .T.,  oDlgTela:End()},, 2 ) //"Confirmar"
oBrowse:AddButton( OemTOAnsi(STR0015),  {|| cRet := "", oDlgTela:End()} ,, 2 ) //STR0015  //"Cancelar"
oBrowse:DisableDetails()
oBrowse:SetQueryIndex(aIndex)
oBrowse:SetSeek(,aSeek)

ADD COLUMN oColumn DATA { ||  TFL_FILIAL } TITLE STR0016 SIZE TamSx3('TFL_FILIAL')[1] OF oBrowse //"Filial"
ADD COLUMN oColumn DATA { ||  TFL_LOCAL} TITLE STR0012 SIZE TamSx3('TFL_LOCAL')[1]  OF oBrowse //"Local"
ADD COLUMN oColumn DATA { ||  ABS_DESCRI } TITLE STR0017 SIZE TamSx3('ABS_DESCRI')[1] OF oBrowse //"Descrição"


If !IsBlind()             
	oBrowse:Activate()
	
	ACTIVATE MSDIALOG oDlgTela CENTERED
EndIf

If lRet
	cItem := cRet
	oModel:LoadValue(cSubModel,cCpoLoc,cDesc)
	
	 
EndIf
     
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At703TFFDt

Consulta padrão  Produto TFFDET - Utilizada nas tabelas TX5 e TX7
@author Mateus Boiani
@since 13/11/2018
@version 12.1.23
@param 
@return lRet - Consulta realizada com sucesso
/*/
//----------------------------------------------------------------------------------------------------------------------
Function At703TFFDt()

Local oModel        := FWModelActive() //Modelo Corrente
Local lRet          := .F. //Retorno da rotina
Local oBrowse       := Nil //Objeto Browse
Local cAls          := GetNextAlias() //Alias da Janela
Local nSuperior     := 0	//Coordenada da Janela
Local nEsquerda     := 0 //Coordenada da Jan
Local nInferior     := 0 //Coordenada da Jan
Local nDireita      := 0 //Coordenada da Jan
Local oDlgTela 		:= Nil //Objeto Janela
Local cQry  		:= "" //Query Sql
Local aIndex 		:= {"TFF_PRODUT"} //Definição do índice da Consulta Padrão
Local aSeek 		:= {{ STR0019, {{STR0018,"C",TamSx3("TFF_PRODUT")[1],0,"",,}} }}//Definição da Descrição da Chave de Pesquisa da Consulta Padrão //"Produto" //"Produtos"
Local cCodCtt 		:= "" //Codigo do Contrato
Local cCodLocal 	:= "" //Codigo do local
Local cDesc 		:= "" //Descrição do Local
Local cFunc  		:= "" //Descrição da Função
Local cCpoFun 		:= 'TX5_DESFUN' //Campo de retorno da função	
Local cCpoDesPr 	:= 'TX5_DESPRD' //Campo de retorno do produto
Local cCpoCtt 		:= 'TX5_CONTRT' //Campo do contrato
Local cCpoLoc 		:= 'TX5_CODTFL' //Campo de Codigo do item de RH
Local cRet 			:= ""
Local cModel 		:= "" //Id do Model
Local cSubModel 	:= "TX5MASTER" //Id do Model Cabeçaho

cItem := ""

cModel := oModel:GetId()

If cModel <> "TECA703"
	cSubModel := "TX5MASTER"
	cCpoFun := 'TX7_DESFUN'	
	cCpoDesPr := 'TX7_DESPRD'
	cCpoCtt := 'TX7_CONTRT'
	cCpoLoc := 'TX7_CODTFL'
EndIf

cCodCtt := oModel:GetValue(cSubModel,cCpoCtt)
cCodLocal := oModel:GetValue(cSubModel,cCpoLoc)

cQry := " SELECT " 
cQry += " TFF_FILIAL,"
cQry += " TFF_COD, "
cQry += " TFF_PRODUT, "
cQry += " B1_DESC, "
cQry += " TFF_FUNCAO, "
cQry += " RJ_DESC, "
cQry += " TFF_QTDVEN, "
cQry += " TFF_PRCVEN, "
cQry += " TFF_PERINI, "
cQry += " TFF_PERFIM "  
cQry += " FROM " + RetSqlName("TFF") + " TFF "
cQry += " INNER JOIN " + RetSqlName("SB1") + " SB1 "
cQry += " ON SB1.B1_FILIAL = '" +  xFilial('SB1') + "'"
cQry += " AND SB1.B1_COD = TFF.TFF_PRODUT"  
cQry += " AND SB1.D_E_L_E_T_ <> '*'"
cQry += " INNER JOIN " + RetSqlName("SRJ") + " SRJ "
cQry += " ON SRJ.RJ_FILIAL = '" +  xFilial('SRJ') + "'"
cQry += " AND SRJ.RJ_FUNCAO = TFF.TFF_FUNCAO"  
cQry += " AND SRJ.D_E_L_E_T_ <> '*'"
cQry += " WHERE TFF_FILIAL = '" + xFilial('TFF') + "'"
cQry += " AND TFF.TFF_LOCAL = '"  + cCodLocal + "'"
cQry += " AND TFF.TFF_CONTRT = '"  + cCodCtt + "'"
cQry += " AND TFF.D_E_L_E_T_ <> '*'"
  
nSuperior := 0
nEsquerda := 0
nInferior := 460
nDireita  := 800

DEFINE MSDIALOG oDlgTela TITLE STR0018 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL  //"Produto"
 
oBrowse := FWFormBrowse():New()
oBrowse:SetDescription(STR0020)  //"Produtos RH"
oBrowse:SetAlias(cAls)
oBrowse:SetDataQuery()
oBrowse:SetQuery(cQry)
oBrowse:SetOwner(oDlgTela)
oBrowse:SetDoubleClick({ || cRet := (oBrowse:Alias())->TFF_COD, cDesc := (oBrowse:Alias())->B1_DESC,cFunc :=  (oBrowse:Alias())->RJ_DESC,  lRet := .T., oDlgTela:End()})
oBrowse:AddButton( OemTOAnsi(STR0014), {|| cRet := (oBrowse:Alias())->TFF_COD, lRet := .T.,  oDlgTela:End()},, 2 ) //"Confirmar"
oBrowse:AddButton( OemTOAnsi(STR0015),  {|| cRet := "", oDlgTela:End()} ,, 2 ) //STR0015  //"Cancelar"
oBrowse:DisableDetails()
oBrowse:SetQueryIndex(aIndex)
oBrowse:SetSeek(,aSeek)

ADD COLUMN oColumn DATA { ||  TFF_FILIAL } TITLE STR0016 SIZE TamSx3('TFF_FILIAL')[1] OF oBrowse //"Filial"
ADD COLUMN oColumn DATA { ||  TFF_COD} TITLE STR0021 SIZE TamSx3('TFF_COD')[1]  OF oBrowse //"Código"
ADD COLUMN oColumn DATA { ||  TFF_PRODUT } TITLE STR0018 SIZE TamSx3('TFF_PRODUT')[1] OF oBrowse //"Produto"
ADD COLUMN oColumn DATA { ||  B1_DESC } TITLE STR0017 SIZE TamSx3('B1_DESC')[1]  OF oBrowse //"Descrição"
ADD COLUMN oColumn DATA { ||  TFF_FUNCAO } TITLE STR0022 SIZE TamSx3('TFF_FUNCAO')[1] OF oBrowse //"Função"
ADD COLUMN oColumn DATA { ||  RJ_DESC } TITLE STR0017 SIZE TamSx3('RJ_DESC')[1]  OF oBrowse //"Descrição"
ADD COLUMN oColumn DATA { ||  TFF_QTDVEN } TITLE STR0023 SIZE TamSx3('TFF_QTDVEN')[1]  OF oBrowse //"Quantidade"
ADD COLUMN oColumn DATA { ||  TFF_PERINI } TITLE STR0024 SIZE TamSx3('TFF_PERINI')[1]  OF oBrowse //"Per ini"
ADD COLUMN oColumn DATA { ||  TFF_PERFIM } TITLE STR0025 SIZE TamSx3('TFF_PERFIM')[1]  OF oBrowse //"Per fim"

If !IsBlind()             
	oBrowse:Activate()
	
	ACTIVATE MSDIALOG oDlgTela CENTERED
EndIf

If lRet
	cItem := cRet

	oModel:LoadValue(cSubModel, cCpoFun,cFunc)
	oModel:LoadValue(cSubModel,cCpoDesPr,cDesc)
	 
EndIf
    
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At703RetIt

Retorno da Consulta padrão  Local/Produto
@author Mateus Boiani
@since 13/11/2018
@version 12.1.23
@param 
@return lRet - Consulta realizada com sucesso
/*/
//----------------------------------------------------------------------------------------------------------------------
Function At703RetIt()

Return cItem
