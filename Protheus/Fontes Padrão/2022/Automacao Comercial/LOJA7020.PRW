#include "LOJA7020.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH' 

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA7020()

Analise de rentabilidade de Produtos
  
@author Varejo
@since 21/08/2013
/*/
//-------------------------------------------------------------------- 
Function LOJA7020() 

Local nReducao := 0
Local lPergunta:=.T.
If Pergunte("LOJA7020", lPergunta)
	FWExecView(STR0001,'LOJA7020',  MODEL_OPERATION_VIEW,,  {|| .T. } , , nReducao )//"Produto"
EndIf	

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()

Menu - Analise de rentabilidade por Produtos
   
@author Varejo 
@since 20/10/2012
/*/
//--------------------------------------------------------------------  
Static Function MenuDef() 
Return FWLoadMenuDef( "mata850") 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()

Model - Analise de rentabilidade por Produtos
   
@author Varejo
@since 20/10/2012
/*/
//--------------------------------------------------------------------  
Static Function ModelDef() 

Local oModel := FWLoadModel( "mata850" )   			//herda o model padrao para a consulta
Local oModelGrid := oModel:GetModel("MODEL_GRID")	//pega o model do grid
Local oStructGrid	:= oModelGrid:GetStruct()		//pega a estrutura do grid (para add novos campos)
Local aDados := {}                                  //array para exibicao na tela
                     
oStructGrid:AddField(STR0003, "" , "ZAB_QTDE", "N", 9, 2 )//"Quantidade"
oStructGrid:AddField(STR0004, "" , "ZAB_CTMED", "N", 9, 2 )//"Custo Médio Vendas"
oStructGrid:AddField(STR0005, "" , "ZAB_VLMED", "N", 9, 2 )//"Valor Médio Vendas"

//monta array de dados para fazer a carga de dados e adiciona campos novos na estrutura do model do grid 
MsgRun(STR0006, STR0007, { || aDados := M854Produto(MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06, MV_PAR07) } ) //"Aguarde"//"Carregando dados. Aguarde....."

//-----------------------------------------------------------------------------------------------
// Altera a descricao de alguns campos do grid
// ATENCAO: DEVE-SE ALTERAR A DESCRICAO NO MODEL TAMBEM PARA FUNCIONAR OS FILTROS DO GRID 
//------------------------------------------------------------------------------------------------
oStructGrid:SetProperty("ZAB_ID"  , MODEL_FIELD_TITULO, STR0008)//"Cód Produto"
oStructGrid:SetProperty("ZAB_DESC", MODEL_FIELD_TITULO, STR0001)

oModelGrid:SetLoad( {|| M850LoadGrid(aDados,MV_PAR05,MV_PAR06)} )

Return oModel 

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()

View - Analise de rentabilidade por Produtos
   
@author Varejo
@since 20/10/2012
/*/
//--------------------------------------------------------------------  
Static Function ViewDef() 
  
Local oModel 	:= FWLoadModel( 'LOJA7020' ) 		//Utiliza o model deste fonte
Local oView := FWLoadView( "mata850" )				//herda a view padrao para a consulta
Local oStruGrid := oView:GetViewStruct("VIEW_GRID") //pega a estrutura do grid (view)
Local oModelGrid := oModel:GetModel("MODEL_GRID")	

//add os novos campos na estrutura da view do grid
M850ViewStr(oModel, @oStruGrid) 	

//Altera a ordem dos campos para exibir na tela
oStruGrid:SetProperty("ZAB_ID"    , MVC_VIEW_ORDEM, '01')
oStruGrid:SetProperty("ZAB_DESC"  , MVC_VIEW_ORDEM, '02')
oStruGrid:SetProperty("ZAB_QTDE"  , MVC_VIEW_ORDEM, '03')
oStruGrid:SetProperty("ZAB_CTMED" , MVC_VIEW_ORDEM, '04')
oStruGrid:SetProperty("ZAB_CUSTO" , MVC_VIEW_ORDEM, '05')
oStruGrid:SetProperty("ZAB_VLMED" , MVC_VIEW_ORDEM, '06')

//-----------------------------------------------------------------------------------------------
// Altera a descricao de alguns campos do grid
// ATENCAO: DEVE-SE ALTERAR A DESCRICAO NO MODEL TAMBEM PARA FUNCIONAR OS FILTROS DO GRID 
//------------------------------------------------------------------------------------------------
oStruGrid:SetProperty("ZAB_ID"  , MVC_VIEW_TITULO, STR0008)//"Cód Produto"
oStruGrid:SetProperty("ZAB_DESC", MVC_VIEW_TITULO, STR0001)//"Produto"
//--------------------------------------------------------------------------
// add botoes com as acoes
// determina que a legenda do grafico sera baseada no campo ZAB_DESC
//--------------------------------------------------------------------------
oView:AddOtherObject('VIEW_BOTOES', {|oPanel| M850BtBar( oPanel , oModel , /*bDetail*/ , "ZAB_DESC", /*cTitle*/,{|| M850ImpRel(oModel,oView:GetViewStruct("VIEW_GRID") , STR0009),STR0001 } )} ) //"Analise de rentabilidade por Produtos"###"Produtos"
oView:SetOwnerView( 'VIEW_BOTOES', 'SUPERIOR' )

oView:SetModel(oModel) //associa a view com o model

Return oView 
//-------------------------------------------------------------------
/*/{Protheus.doc} M851Pedidos()

Consulta pedidos para exibicao

@param dDtIni, data, data inicial (pedido)
@param dDtFin, data, data final (pedido)
@param [cCodVend], caractere, codigo do vendedor
 
@return aDados, array, ( ID, Descricao, Custo, Preco, .....<campos adicionais> )
   
@author Varejo
@since 20/10/2012
/*/
//--------------------------------------------------------------------  
Function M854Produto(dDtIni,dDtFim, cProdIni, cProdFin,;
					 nOrdem,nIndicador,cCodTes)

Local aArea  := GetArea() //Salva area da tabela
Local aItens := {} //array de itens retornado

Local nCustoAux := 0 //Custo medio Unitario
Local nPrecoAux := 0 //Preco de venda
Local cAliasTrb := ''//Alias temporario
Local cNum      := ''//Num do documento
Local cOrcam    := ''//Num orcamento
Local nI:= 1        // contador
Local cMoeda:= Alltrim(Str(SuperGetMV("MV_LJMDORC",,1)))
//Procura orçamentos/vendas
If RAT(",",cCodTes) == Len(AllTrim(cCodTes))
	cCodTes := SubStr(cCodTes,1,(Len(AllTrim(cCodTes))-1))	
EndIf
cCodTes := "'" + StrTran(AllTrim(cCodTes), "," , "','") + "'"
cAliasTrb:= LjFildados(dDtIni,dDtFim,cProdIni, cProdFin,cCodTes)
While (cAliasTrb)->(!EOF()) 
		
	cNum      := (cAliasTrb)->F2_DOC+(cAliasTrb)->F2_SERIE
	cOrcam    := (cAliasTrb)->L1_NUM
	
   dDtEmis:= STOD((cAliasTrb)->F2_EMISSAO)
				
    While (cAliasTrb)->(!EOF()) .AND. (cAliasTrb)->D2_DOC+(cAliasTrb)->D2_SERIE == cNum
    
	  	nCustoAux += (cAliasTrb)->&("D2_CUSTO"+cMoeda) 
        nPrecoAux += MaValPres((cAliasTrb)->D2_PRCVEN*(cAliasTrb)->D2_QUANT,dDtEmis,,,dDtEmis)
		nScan:= aScan(aItens,{|x| x[1] ==  (cAliasTrb)->D2_COD })
		If nScan == 0   		                              
		//Monta o array com os dados que serao retornado		    
			AADD(aItens, {(cAliasTrb)->D2_COD, (cAliasTrb)->B1_DESC, nCustoAux,nPrecoAux,(cAliasTrb)->D2_QUANT,0,0 })  
		Else    
			aItens[nScan][3] +=	 nCustoAux
			aItens[nScan][4] +=	 nPrecoAux
			aItens[nScan][5] +=	 (cAliasTrb)->D2_QUANT
		EndIf		
		nCustoAux := 0
		nPrecoAux := 0		
		(cAliasTrb)->(DbSkip())
	EndDo 
		    
	Loop		
EndDo

For nI:= 1 To Len(aItens)
	aItens[nI][6]:= Round(aItens[nI][3] / aItens[nI][5],2)
	aItens[nI][7]:= Round(aItens[nI][4] / aItens[nI][5],2)
Next nI
       
(cAliasTrb)->(dbCloseArea())
	   

	
If Len(aItens)>0	
	If nOrdem == 1 //Crescente
		Do Case
			Case nIndicador == 1 //Descrição Produto
				aItens := aSort( aItens,,, { |x,y| x[2] < y[2] } )			
			Case nIndicador == 2 //Custo
				aItens := aSort( aItens,,, { |x,y| x[3] < y[3] } )	
		EndCase	
	Else//Decrescente
		Do Case
			Case nIndicador == 1 //Descrição Produto
				aItens := aSort( aItens,,, { |x,y| x[2] > y[2] } )			
			Case nIndicador == 2 //Custo
				aItens := aSort( aItens,,, { |x,y| x[3] > y[3] } )	
		EndCase	
	EndIf
EndIf		

RestArea(aArea)

Return aItens
//-------------------------------------------------------------------
/*/{Protheus.doc} LjFildados()

Consulta orcamentos/vendas para exibicao
  
@author Varejo 
@since 20/08/2013
/*/
//--------------------------------------------------------------------  
Static Function LjFildados(dDtIni, dDtFin,cProdIni, cProdFin,;
							cCodTes)

Local cQuery:= ''                // Query para consultar o banco
Local cAliasTrb:= GetNextAlias() // alias para tabela temporaria 
Local cMoeda:= Alltrim(Str(SuperGetMV("MV_LJMDORC",,1)))

cQuery+= " SELECT L1_NUM ,F2_EMISSAO,F2_VEND1,F2_CLIENTE,F2_LOJA,F2_TIPO,F2_TIPOCLI,D2_COD,D2_TES,"
cQuery+= " D2_PRCVEN,D2_LOCAL,D2_QUANT,D2_DESC,D2_TOTAL,F2_DOC,F2_SERIE,B1_DESC,D2_DOC,D2_SERIE,D2_CUSTO"+cMoeda+CRLF
cQuery+= "  FROM "+RetSqlName("SF2")+" SF2"+CRLF

cQuery+= "  INNER JOIN "+RetSqlName("SD2")+" SD2"+CRLF
cQuery+= "  ON F2_FILIAL = D2_FILIAL"+CRLF
cQuery+= "  AND F2_DOC  = D2_DOC"+CRLF
cQuery+= "  AND F2_SERIE= D2_SERIE"+CRLF
cQuery+= "  AND D2_COD BETWEEN '"+cProdIni+"' AND '"+cProdFin+"' "+CRLF
If cCodTes <> "''" //Se !Empty(), porém estamos recebendo com abre e fecha aspas.
	cQuery+= "  AND D2_TES IN (" + cCodTes + ")"+CRLF
Else	//Caso não for novo pergunte do item 7 (TES), manter o que era antes)
	cQuery+= "  AND D2_CF NOT IN ('5929','6929', '7929')"+CRLF // O CFOP 5929, 6929 e 7929 são  usados para " Lançamento efetuado em decorrência de emissão de documento fiscal relativo a operação ou prestação também registrada em equipamento Emissor de Cupom Fiscal - ECF ".
EndIf 
cQuery+= "  AND SD2.D_E_L_E_T_ <> '*' "+CRLF

cQuery+= "   LEFT JOIN "+RetSqlName("SL1")+" SL1"+CRLF
cQuery+= "   ON L1_FILIAL = F2_FILIAL"+CRLF
cQuery+= "   AND L1_DOC = F2_DOC"+CRLF
cQuery+= "   AND L1_SERIE = F2_SERIE"+CRLF
cQuery+= "   AND SL1.D_E_L_E_T_ <> '*'  "+CRLF
     
cQuery+= "  INNER JOIN "+RetSqlName("SB1")+" SB1"+CRLF
cQuery+= "  ON B1_FILIAL = '"+xFilial("SB1")+"' "+CRLF     
cQuery+= "  AND B1_COD = D2_COD"+CRLF
cQuery+= "  AND SB1.D_E_L_E_T_ <> '*' "+CRLF

cQuery+= "  WHERE F2_FILIAL = '"+xFilial("SF2")+"'"+CRLF
cQuery+= "  AND F2_EMISSAO BETWEEN '"+DTOS(dDtIni)+"' AND '"+DTOS(dDtFin)+"'" +CRLF
cQuery+= "  AND SF2.D_E_L_E_T_ <> '*'"+CRLF
cQuery+= "  AND F2_VALMERC > 0 " +CRLF
cQuery+= "  ORDER BY D2_DOC,D2_SERIE,D2_ITEM,D2_EMISSAO"+CRLF

cQuery:= ChangeQuery(cQuery) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza a query³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select(cAliasTrb) > 0
	(cAliasTrb)->(dbCloseArea())
EndIf
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTrb, .F., .T.)
 
Return cAliasTrb

/*/{Protheus.doc} LJ7020ValTES
	Valida a Tes informada
	@type  Function
	@author Fábio S. dos Santos
	@since 28/05/2019
	@version 12.1.23
	@param MV_PAR07
	@return lRet
	/*/
Function LJ7020ValTES(cTESValid)
Local lRet		:= .T.
Local cStrValid := "0123456789,"
Local cSubStr	:= ""
Local cTesNoFound:= ""
Local nX		:= 0
Local nY		:= 0
Local aAux		:= {}
lOCAL aCodTes	:= {}

Default cTESValid := ""

For nX := 1 To Len(AllTrim(cTESValid))
	cSubStr := SubStr(cTESValid,nX,1)
	nY := At(cSubStr,cStrValid)
	If nY = 0 
		lRet := .F.
	EndIf
Next nX

If !lRet
	FWAlertInfo(STR0011)//"Campo obrigatório não informado ou não válido, Verifique!"
Else
	//Validar os códigos digitados se existem
	aAux := Separa(cTESValid,',',.F.)
	
	For nX := 1 To Len(aAux)
		aAdd(aCodTes,{aAux[nX],"N"})
	Next nX
	
	SF4->(DbSetOrder(1))
	For nX := 1 To Len(aCodTes)
		
		If (SF4->(DbSeek(xFilial("SF4")+aCodTes[nX,1]))) 
			aCodTes[nX,2] := "S"	
		EndIf
				
	Next nX
	
	For nX := 1 To Len(aCodTes) 
		If !Empty(aCodTes[nX,1]) .And. aCodTes[nX,2] == "N"
			cTesNoFound +=  ", " + aCodTes[nX,1]
		EndIf
	Next nX
	
	If !Empty(cTesNoFound)
		//retiro "," da primeira posição
		If AT(",",cTesNoFound) == 1
			cTesNoFound := SubStr(cTesNoFound,2,Len(cTesNoFound))	
		EndIf
		lRet := .F.
		FWAlertInfo(STR0012 + Chr(13)+Chr(10) + Chr(13)+Chr(10) + cTesNoFound + Chr(13)+Chr(10) + Chr(13)+Chr(10) + STR0013) //"TES não encontrada! "#"Favor verificar no cadastro de TES - Tipo de Entrada/Saída."
	EndIf
	
EndIf

Return lRet