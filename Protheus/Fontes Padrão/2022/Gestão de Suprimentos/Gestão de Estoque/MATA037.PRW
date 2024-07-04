#INCLUDE "MATA037.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
 
//-------------------------------------------------------------------
/*{Protheus.doc} MATA037

*/
//-------------------------------------------------------------------
FUNCTION MATA037()

Local oBrowse	As Object

Private aRotina := MenuDef()

If AliasInDic("D3K")
	oBrowse:= BrowseDef()
	oBrowse:Activate()
Else
	MsgInfo('Necessário Pacote de Atualização BlocoK')
EndIf

Return

/*/{Protheus.doc} BrowseDef
Definição do browse principal do Complemento Fiscal dos produtos
@author Andre Maximo 
@since 11/10/2018
@version 1.0
@Return Object, FwMBrowse

@type function
/*/
STATIC FUNCTION BrowseDef() As Object
Local oBrowse	As Object

//Atualização do status da browser
A037AtuBrw('0')
A037AtuBrw('1')
A037AtuBrw('2')

oBrowse := FWMBrowse():New()
oBrowse:SetAlias( "SC2" )
oBrowse:SetFilterDefault( "C2_OPTERCE =='1'" )
oBrowse:SetDescription(STR0001)
oBrowse:AddLegend("( C2_STTERCE== '1'  )","GREEN",'Processado')
oBrowse:AddLegend("( C2_STTERCE== '2' )" ,"RED",'Com Itens para Processar')
oBrowse:AddLegend("( C2_STTERCE== '3' .OR. EMPTY(C2_STTERCE) .Or. C2_STTERCE== '0'  )", "WHITE",'Sem itens para processar')


Return oBrowse

//-------------------------------------------------------------------
/*{Protheus.doc} MenuDef

*/
//-------------------------------------------------------------------
Static Function MenuDef() 

aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.MATA037" OPERATION MODEL_OPERATION_VIEW	ACCESS 0 //"Visualizar"	
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.MATA037" OPERATION MODEL_OPERATION_UPDATE	ACCESS 0 //"Alterar"		
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.MATA037" OPERATION MODEL_OPERATION_DELETE	ACCESS 3 //"Excluir"	

Return aRotina


/*/{Protheus.doc} ModelDef
Definição da modelagem da tabela D3K
@author Andre Maximo
@since 11/10/2018
@version 1.0
@Return oModel, ${Return_description}

@type function
/*/
Static Function ModelDef() As Object
Local oStrD3K 	:= FWFormStruct(1 ,"D3K")
Local oStrSd3	:= FWFormStruct(1 ,"SD3",{|cCampo| AllTRim(cCampo) $ "D3_OP|D3_COD|D3_QUANT|D3_CF|D3_NUMSEQ|D3_LOTECTL"})
Local oStrD3KOP := FWFormStruct(1 ,"SC2",{|cCampo| AllTRim(cCampo) $ "C2_NUM|C2_ITEM|C2_SEQUEN"}) 
Local oModel:= MPFormModel():New( "MATA037" ,/* bPreValidacao */ ,/* bPosValidacao */  )// "MATA037"
Local lD3kLote
Local aGatilho	

// Verifica se o campo D3K_LOTE existe
lD3kLote := aScan(oStrD3K:GetFields(),{|x|AllTrim(x[3])=="D3K_LOTE"}) > 0

oStrD3KOP:AddField( ; // Ord. Tipo Desc.
					STR0006 	 												, ;// [01] C Titulo do campo //'Ordem de Produção'
					STR0006														, ; // [02] C ToolTip do campo //'Ordem de Produção'
					'C2_NUMFULL' 												, ; // [03] C identificador (ID) do Field
					'C' 													, ; // [04] C Tipo do campo
					TamSX3("D3_OP" )[1] 									, ; // [05] N Tamanho do campo
					0 														, ; // [06] N Decimal do campo
					NIL														, ; // [07] B Code-block de validação do campo
					{||.F.}													, ; // [08] B Code-block de validação When do campo
					NIL				 										, ; // [09] A Lista de valores permitido do campo
					NIL 													, ; // [10] L Indica se o campo tem preenchimento obrigatório
					FwBuildFeature( STRUCT_FEATURE_INIPAD, "SC2->(C2_NUM+C2_ITEM+C2_SEQUEN )"), ; // [11] B Code-block de inicializacao do campo
					NIL 													, ; // [12] L Indica se trata de um campo chave
					NIL 													, ; // [13] L Indica se o campo pode receber valor em uma operação de update.
					.T. )														 // [14] L Indica se o campo é virtual


oStrSd3:AddField( ; // Ord. Tipo Desc.
					STR0007			 	 									, ;// [01] C Titulo do campo //Tp. RE/DE/PR
					STR0007													, ; // [02] C ToolTip do campo // Tp. RE/DE/PR
					'D3_RDP' 												, ; // [03] C identificador (ID) do Field
					'C' 													, ; // [04] C Tipo do campo
					TamSX3("D3_CF" )[1] 									, ; // [05] N Tamanho do campo
					0 														, ; // [06] N Decimal do campo
					NIL														, ; // [07] B Code-block de validação do campo
					NIL 													, ; // [08] B Code-block de validação When do campo
					NIL				 										, ; // [09] A Lista de valores permitido do campo
					NIL 													, ; // [10] L Indica se o campo tem preenchimento obrigatório
					FwBuildFeature( STRUCT_FEATURE_INIPAD, "SD3->D3_CF")											 			, ; // [11] B Code-block de inicializacao do campo
					NIL 													, ; // [12] L Indica se trata de um campo chave
					NIL 													, ; // [13] L Indica se o campo pode receber valor em uma operação de update.
					.T. )														 // [14] L Indica se o campo é virtual


oStrSd3:SetProperty("D3_OP",MODEL_FIELD_VALID,{||.T.})
oStrSd3:SetProperty("D3_COD",MODEL_FIELD_VALID,{||.T.})
oStrSd3:SetProperty("D3_QUANT",MODEL_FIELD_VALID,{||.T.})
oStrD3K:SetProperty('D3K_PERBLK',MODEL_FIELD_INIT,{||Substr(dTOS(dDatabase),1,6)})


oStrD3K:SetProperty("D3K_CLIENT" , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "ExistCpo('SA1', FwFldGet('D3K_CLIENT'), 1)") )
oStrD3K:SetProperty("D3K_LOJA"   , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "ExistCpo('SA1',FwFldGet('D3K_CLIENT')+FwFldGet('D3K_LOJA'), 1)"))


oModel:AddFields('D3KMASTER', NIL ,oStrD3KOP)
oModel:AddGrid('SD3DETAIL','D3KMASTER',oStrSd3)
oModel:AddGrid('D3KDETAIL','SD3DETAIL',oStrD3K)

oModel:SetRelation('SD3DETAIL',{{'D3_FILIAL', 'Xfilial("SD3")' },{'D3_OP','C2_NUM+C2_ITEM+C2_SEQUEN'}} ) 
If lD3kLote
	oModel:SetRelation('D3KDETAIL',{{'D3K_FILIAL', 'Xfilial("D3K") '},{'D3K_NUMSEQ','D3_NUMSEQ'},{'D3K_COD','D3_COD'},{'D3K_OP','D3_OP'},{'D3K_LOTE','D3_LOTECTL'}}, D3K->(IndexKey(1))) 
Else
	oModel:SetRelation('D3KDETAIL',{{'D3K_FILIAL', 'Xfilial("D3K") '},{'D3K_NUMSEQ','D3_NUMSEQ'},{'D3K_COD','D3_COD'},{'D3K_OP','D3_OP'}}, D3K->(IndexKey(1)))
Endif
oModel:GetModel( 'SD3DETAIL' ):SetnoInsertLine(.T.)
oModel:GetModel( 'SD3DETAIL' ):SetnoUpdateLine(.T.)
oModel:GetModel( 'SD3DETAIL' ):SetNoDeleteLine(.T.)
oModel:GetModel( 'SD3DETAIL' ):SetOnlyQuery(.T.)
oModel:GetModel( 'D3KMASTER' ):SetOnlyQuery(.T.)
oModel:GetModel('D3KDETAIL'  ):SetUniqueLine({"D3K_CLIENT","D3K_LOJA"})


oModel:SetDescription( STR0001 )// Producao de terceiros
oModel:GetModel( 'D3KMASTER' ):SetDescription( STR0001 ) // Producao de terceiros
oModel:GetModel( 'SD3DETAIL' ):SetDescription( STR0001 ) // Producao de terceiros
oModel:GetModel( 'D3KDETAIL' ):SetDescription( STR0001 ) // Producao de terceiros
oModel:GetModel( 'D3KDETAIL' ):SetOptional( .T. )


oModel:GetModel( 'SD3DETAIL' ):SetLoadFilter(,A037FILTER() ) 

If lD3kLote
	oModel:SetPrimaryKey({"D3K_FILIAL","D3K_NUMSEQ","D3K_CLIENT","D3K_LOJA","D3K_COD","D3K_OP","D3K_LOTE"})
Else
	oModel:SetPrimaryKey({"D3K_FILIAL","D3K_NUMSEQ","D3K_CLIENT","D3K_LOJA","D3K_COD","D3K_OP"})
Endif

Return oModel

/*/{Protheus.doc} ViewDef
@author Andre Maximo 
@since 11/10/2018
@version 1.0
@Return oView, ${Return_description}

@type function
/*/
Static Function ViewDef() As Object
Local oModel	:= FWLoadModel( "MATA037" )
Local oStrD3K	:= FWFormStruct(2 ,"D3K",{|cCampo| !AllTRim(cCampo) $ "D3K_OP|D3K_COD|D3K_PERBLK|D3K_NUMSEQ|D3K_LOTE"} )
Local oStrSd3	:= FWFormStruct(2 ,"SD3",{|cCampo| AllTRim(cCampo) $ "D3_OP|D3_COD|D3_QUANT|D3_CF|D3_LOTECTL"})
Local oStrD3KOP := FWFormViewStruct():New() 
Local oView		:= FWFormView():New()

oStrSd3:AddField( ; // Ord. Tipo Desc.
					'D3_RDP'													 , ; // [01] C Nome do Campo
					'04'														 , ; // [02] C Ordem
					STR0007 													 , ; // [03] C Titulo do campo // 'Tp. RE/DE/PR'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
					STR0007 											 		 , ; // [04] C Descrição do campo// 'Tp. RE/DE/PR'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
				    {STR0008}												 	 , ; // [05] A Array com Help // Tipo Movimento
					'C' 														 , ; // [06] C Tipo do campo
					'@!' 														 , ; // [07] C Picture
					NIL  														 , ; // [08] B Bloco de Picture Var
					'' 															 , ; // [09] C Consulta F3
					.T. 														 , ; // [10] L Indica se o campo é evitável
					NIL 														 , ; // [11] C Pasta do campo
					NIL 														 , ; // [12] C Agrupamento do campo
					NIL															 , ; // [13] A Lista de valores permitido do campo (Combo)
					NIL 														 , ; // [14] N Tamanho Maximo da maior opção do combo
					NIL 														 , ; // [15] C Inicializador de Browse
					.T. 														 , ; // [16] L Indica se o campo é virtual
					NIL ) 															 // [17] C Picture Variável

oStrD3KOP:AddField( ; // Ord. Tipo Desc.
					'C2_NUMFULL'												 , ; // [01] C Nome do Campo
					'01'														 , ; // [02] C Ordem
					STR0006 													 , ; // [03] C Titulo do campo // Ordem de Produção
					STR0006 													 , ; // [04] C Descrição do campo
				   {STR0006}													 , ; // [05] A Array com Help  // Ordem de Produção
					'C' 														 , ; // [06] C Tipo do campo
					'@!' 														 , ; // [07] C Picture
					NIL  														 , ; // [08] B Bloco de Picture Var
					'' 															 , ; // [09] C Consulta F3
					.T. 														 , ; // [10] L Indica se o campo é evitável
					NIL 														 , ; // [11] C Pasta do campo
					NIL 														 , ; // [12] C Agrupamento do campo
					NIL															 , ; // [13] A Lista de valores permitido do campo (Combo)
					NIL 														 , ; // [14] N Tamanho Maximo da maior opção do combo
					NIL 														 , ; // [15] C Inicializador de Browse
					.T. 														 , ; // [16] L Indica se o campo é virtual
					NIL ) 															 // [17] C Picture Variável					


oView:SetModel(oModel)

oView:AddField( 'VIEW_D3K', oStrD3KOP,'D3KMASTER' )
oView:AddGrid( 'GRID_SD3',  oStrSD3,'SD3DETAIL'  )
oView:AddGrid( 'GRID_D3K',  oStrD3K,'D3KDETAIL'  )


oView:CreateHorizontalBox("MAIN",10)
oView:CreateHorizontalBox("GRIDSD3",45)
oView:CreateHorizontalBox("GRIDD3K",45)

oView:SetOwnerView('VIEW_D3K','MAIN')
oView:SetOwnerView('GRID_SD3','GRIDSD3')
oView:SetOwnerView('GRID_D3K','GRIDD3K')

oView:EnableControlBar(.T.)

Return oView


/*/{Protheus.doc} A037SALDO
Controle de saldo para distribuição para terceiros
@author Andre Maximo
@since 11/10/2018
@version 1.0
@Return oModel, ${Return_description}

@type function

/*/

Function A037SALDO()
Local oModel	:= FWModelActive()
Local oModelSD3	:= oModel:GetModel('SD3DETAIL')
Local oModelD3K	:= oModel:GetModel('D3KDETAIL')
Local nQuantSld := oModelSD3:GetValue('D3_QUANT')
Local nSldDist	:= 0 
Local nX		:= 0
Local lRet		:= .T.

For nX := 1 to  oModelD3K:Length()  
	oModelD3K:Goline(nX)
	If !oModelD3K:IsDeleted() 
		nSldDist+= oModelD3K:GetValue('D3K_QTDE')
	EndIf
Next nX
If nSldDist > nQuantSld
	lRet := .F.
	Help(" ",1,"NOSALDOTERC")
EndIf 

If lRet .And. nQuantSld == 0
	lRet := .F.
	Help(" ",1,"NOSALDOTERC")
EndIf
 
Return lRet

/*/{Protheus.doc} A037FILTER
@author Nilton MK
@since 24/07/2020
@version 1.0
/*/
Static Function A037FILTER()
Local cQry      := ""
Local lMVPROD   := ""

lMVPROD := SuperGetMV("MV_PRODMOD",.F.,.T.)

cQry := " D3_CF IN ( 'RE5','RE9','RE6','RE3','RE2','RE0','RE1','PR0','PR1') AND D3_ESTORNO = ' ' "
cQry += " AND " + If(AllTrim( Upper( TcGetDb() ) ) $ "ORACLE/POSTGRES","SUBSTR","SUBSTRING") + "(D3_COD,1,3) <> 'MOD' "
If lMVPROD
	cQry += " AND D3_COD in (select D3_COD  FROM "+ RetSqlName("SB1") + " WHERE B1_FILIAL = '"+FWxFilial('SB1')+"' AND B1_COD = D3_COD AND B1_CCCUSTO = ' ')"
EndIf 
  
Return cQry

/*/{Protheus.doc} A037PesqBrw
Controle de saldo para distribuição para terceiros
@author Andre Maximo
@since 19/10/2018
@version 1.0
@Return oModel, ${Return_description}

@type function

/*/
Function A037AtuBrw(cTipo)
Local oModel	:= FWLoadModel('MATA037')
Local oModelD3K	:= oModel:GetModel('D3KDETAIL')
Local cQuery := ""
Local lD3kLote
Default cTipo := "0"

// Verifica se o campo D3K_LOTE existe
lD3kLote := aScan(oModelD3K:GetStruct():GetFields(),{|x|AllTrim(x[3])=="D3K_LOTE"}) > 0

cQuery:="UPDATE "
cQuery+=""+RetSqlName("SC2")+" "
If cTipo == '0'
	cQuery+="SET C2_STTERCE ='0'
Elseif cTipo == '1'
	cQuery+="SET C2_STTERCE ='1'
Else
	cQuery+="SET C2_STTERCE ='2'
EndIf
cQuery+="where C2_NUM" + MatiConcat()+"C2_ITEM" + MatiConcat()+"C2_SEQUEN in (
cQuery+="SELECT "   
cQuery+=    "SD3.D3_OP "
cQuery+=	"FROM   "+RetSqlName("SD3")+" SD3 "
cQuery+=       "LEFT JOIN "+RetSqlName("SC2")+" SC2 " "
cQuery+=              "ON SD3.D3_OP = SC2.C2_NUM " + MatiConcat()+" SC2.C2_ITEM " + MatiConcat()+" SC2.C2_SEQUEN " + MatiConcat()+" SC2.C2_ITEMGRD "
cQuery+=                 "AND SC2.C2_FILIAL = '"+xFilial('SC2')+"' "
cQuery+=                 "AND SC2.D_E_L_E_T_ = ' ' "
cQuery+=       "LEFT JOIN "+RetSqlName("D3K")+" D3K " "
cQuery+=              "ON D3K_FILIAL = '"+xFilial('D3K')+"' "
cQuery+=                 "AND D3K.D3K_COD = SD3.D3_COD "
cQuery+=                 "AND D3K.D3K_NUMSEQ = SD3.D3_NUMSEQ "
cQuery+=                 "AND D3K.D3K_OP = SD3.D3_OP "
If lD3kLote
	cQuery+=             "AND D3K.D3K_LOTE = SD3.D3_LOTECTL "
Endif
cQuery+=				 "AND D3K.D_E_L_E_T_ = ' ' "
cQuery+="WHERE  SD3.D3_FILIAL = '"+xFilial('SD3')+"' "
cQuery+=       "AND SD3.D_E_L_E_T_ = ' ' "
cQuery+=       "AND SD3.D3_ESTORNO = ' ' "
cQuery+=       "AND SD3.D3_OP <> ' ' "
cQuery+=	   "AND SD3.D3_CF IN ( 'RE5','RE9','RE6','RE3','RE2','RE0','RE1','PR0','PR1') "
cQuery+=       "AND SD3.D_E_L_E_T_ = ' ' "
cQuery+=	   "AND SC2.C2_OPTERCE = '1' "
cQuery+="group by D3_COD, D3_OP,D3_NUMSEQ, D3_QUANT "
If cTipo == '0'
	cQuery+="having "+MatIsNull()+"(SD3.D3_QUANT,-1) - SUM("+MatIsNull()+"(D3K.D3K_QTDE,-1))  < 0 )
ElseIf cTipo == '1'
	cQuery+="having "+MatIsNull()+"(SD3.D3_QUANT,-1) - SUM("+MatIsNull()+"(D3K.D3K_QTDE,-1))  = 0 )
Else
	cQuery+="having "+MatIsNull()+"(SD3.D3_QUANT,-1) - SUM("+MatIsNull()+"(D3K.D3K_QTDE,-1))  > 0 )
EndIf

If (TcSqlExec(cQuery) < 0)
	ProcLogAtu("ERRO",TCSQLError())
EndIf


Return.T.
