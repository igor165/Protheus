#include "LOJA7021.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH' 
//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA7021()

Analise de rentabilidade por vendedor
  
  
@author Vendas CRM
@since 20/10/2012
/*/
//--------------------------------------------------------------------       
Function LOJA7021()
 
If Pergunte("LOJA7021", .T.)
	
	FWExecView(STR0001,'LOJA7021',  MODEL_OPERATION_VIEW,,  {|| .T. } )//'Mês'
EndIf	

Return



//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()

Menu - Analise de rentabilidade por vendedor
   
@author Vendas CRM
@since 20/10/2012
/*/
//--------------------------------------------------------------------  
Static Function MenuDef() 
Return FWLoadMenuDef( "mata850") 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()

Model - Analise de rentabilidade por vendedor
   
@author Vendas CRM
@since 20/10/2012
/*/
//--------------------------------------------------------------------  
Static Function ModelDef() 
Local oModel := FWLoadModel( "mata850" )   			//herda o model padrao para a consulta
Local oModelGrid := oModel:GetModel("MODEL_GRID")		//pega o model do grid
Local oStructGrid	:= oModelGrid:GetStruct()			//pega a estrutura do grid (para add novos campos)
Local aDados := {}

//monta array de dados para fazer a carga de dados e adiciona campos novos na estrutura do model do grid 
MsgRun(STR0003, STR0004, { || aDados := M855Vendas() } ) //"Aguarde"//"Carregando dados. Aguarde....."


oModelGrid:SetLoad( {|| M850LoadGrid(aDados)} )

Return oModel 

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()

View - Analise de rentabilidade por vendedor
   
@author Vendas CRM
@since 20/10/2012
/*/
//--------------------------------------------------------------------  
Static Function ViewDef() 
  
Local oModel 	:= FWLoadModel( 'LOJA7021' ) 			//Utiliza o model deste fonte
Local oView := FWLoadView( "mata850" )				//herda a view padrao para a consulta
Local oStruGrid := oView:GetViewStruct("VIEW_GRID") 	//pega a estrutura do grid (view)
Local oModelGrid := oModel:GetModel("MODEL_GRID")	

//-----------------------------------------------------------------------------------------------
// Altera a descricao de alguns campos do grid
// ATENCAO: DEVE-SE ALTERAR A DESCRICAO NO MODEL TAMBEM PARA FUNCIONAR OS FILTROS DO GRID 
//------------------------------------------------------------------------------------------------
oStruGrid:SetProperty("ZAB_ID", MVC_VIEW_TITULO  , STR0005)//"Periodo"
oStruGrid:SetProperty("ZAB_DESC", MVC_VIEW_TITULO, STR0006)//"Mes"

//--------------------------------------------------------------------------
// add botoes com as acoes
// determina que a legenda do grafico sera baseada no campo ZAB_DESC
//--------------------------------------------------------------------------
oView:AddOtherObject('VIEW_BOTOES', {|oPanel| M850BtBar( oPanel , oModel , {|| M855Detalhe(oModelGrid) } ,  "ZAB_DESC" , /*cTitle*/,{|| M850ImpRel(oModel,oView:GetViewStruct("VIEW_GRID") , STR0007),STR0008},STR0008,2)} ) //"Analise de rentabilidade Vendas Mes"###"Vendas Mes"
oView:SetOwnerView( 'VIEW_BOTOES', 'SUPERIOR' )

oView:SetModel(oModel) //associa a view com o model



Return oView 

//-------------------------------------------------------------------
/*/{Protheus.doc} M855Detalhe()

Abre consulta de rentabilidade por Pedidos 

@param oModelGrid - model do grid de vendedores
   
@author Vendas CRM
@since 20/10/2012
/*/
//--------------------------------------------------------------------  
Function M855Detalhe(oModelGrid)
Local cData:= Right(oModelGrid:GetValue("ZAB_ID"),4)+Left(oModelGrid:GetValue("ZAB_ID"),2) +"01" // Monta a data
Local dDtIni:= FirstDay(STOD(cData)) // Data inicial
Local dDtFim:= LastDate(STOD(cData)) // Data final
//abre consulta de rentabilidade por Vendas (passa o vendedor selecionado)
MATA851(.F., dDtIni, dDtFim , Space(TamSx3("A3_COD")[1]) ,Replicate("Z", TamSX3("E2_NUM")[1]),1,1)

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} M855Vendas()

Consulta vendas para montar tela de rentabilidade

   
@author Vendas CRM
@since 20/10/2012
/*/
//--------------------------------------------------------------------  
Function M855Vendas()

Local aArea := GetArea()  // Salva area
Local nCustoAux := 0      // custo medio
Local nPrecoAux := 0      // preco de venda
Local cAuxCliente := ""   // nome cliente
Local cAuxVendedor := ""  // nome vendedor
Local cAuxCondPagto := "" // condiçao de pagamento
Local aVendas := {}      // array que apresenta na tela
Local nI := 0            // contador
Local cAliasTrb:= GetNextAlias()  // alias temporario
Local aMes:= {STR0012,STR0013,STR0014,STR0015,STR0016,STR0017,STR0018,STR0019,STR0020,STR0021,STR0022,STR0023}//"Janeiro"###"Fevereiro"###"Março"###"Abril"###"Maio"###"Junho"###"Julho"###"Agosto"###"Setembro"###"Outubro"###"Novembro"###"Dezembro"
Local cMes:= ""   // Armazena Mes
Local cAno:= ""   // Armazena Ano
Local cMoeda:= Alltrim(Str(SuperGetMV("MV_LJMDORC",,1))) // moeda do sistema
//Efetua a filtragem das vendas via SELECT 
M855FilVnd(@cAliasTrb)

While (cAliasTrb)->(!EOF()) 
	cNum      := (cAliasTrb)->F2_DOC+(cAliasTrb)->F2_SERIE
	cOrcam    := (cAliasTrb)->L1_NUM
	
   dDtEmis:= STOD((cAliasTrb)->F2_EMISSAO)
				
    While (cAliasTrb)->(!EOF()) .AND. (cAliasTrb)->D2_DOC+(cAliasTrb)->D2_SERIE == cNum
		  
        nCustoAux += (cAliasTrb)->&("D2_CUSTO"+cMoeda) 
        nPrecoAux += MaValPres((cAliasTrb)->D2_PRCVEN*(cAliasTrb)->D2_QUANT,dDtEmis,,,dDtEmis)
	
		cMes:= Alltrim(StrZero(MONTH(STOD( (cAliasTrb)->F2_EMISSAO) ) ,2) ) 
		cAno:= Alltrim(Str(YEAR (STOD( (cAliasTrb)->F2_EMISSAO) ) ) )
		nScan:= aScan(aVendas,{|x| x[1] ==  cMes+cAno })
		If nScan == 0   		                              
		//Monta o array com os dados que serao retornado		    
			AADD(aVendas, { cMes+cAno ,aMes[MONTH(STOD( (cAliasTrb)->F2_EMISSAO) )] , nCustoAux,nPrecoAux })  
		Else    
			aVendas[nScan][3] +=	 nCustoAux
			aVendas[nScan][4] +=	 nPrecoAux
		EndIf		
		nCustoAux := 0
		nPrecoAux := 0		
		(cAliasTrb)->(DbSkip())
	EndDo 
	Loop		
EndDo

RestArea(aArea)

Return aVendas

//-------------------------------------------------------------------
/*/{Protheus.doc} M855FilVnd()

Filtra vendas 

   
@author Vendas CRM
@since 20/10/2012
/*/
//--------------------------------------------------------------------  
Static Function M855FilVnd(cAliasTrb)

Local dDtIni := MV_PAR01
Local dDtFim := LastDate(MonthSum(MV_PAR01,MV_PAR02))
Local cQuery:= ''           
Local cMoeda:= Alltrim(Str(SuperGetMV("MV_LJMDORC",,1)))
Local cCodTes	:= MV_PAR03

If !Empty(cCodTes) .AND. RAT(",",cCodTes) == Len(AllTrim(cCodTes))
	cCodTes := SubStr(cCodTes,1,(Len(AllTrim(cCodTes))-1))	
EndIf
cCodTes := "'" + StrTran(AllTrim(cCodTes), "," , "','") + "'"

cQuery+= " SELECT L1_NUM ,F2_EMISSAO,F2_VEND1,F2_CLIENTE,F2_LOJA,F2_TIPO,F2_TIPOCLI,D2_COD,D2_TES,"
cQuery+= " D2_PRCVEN,D2_LOCAL,D2_QUANT,D2_DESC,D2_TOTAL,F2_DOC,F2_SERIE,D2_DOC,D2_SERIE,D2_CUSTO"+cMoeda+CRLF
cQuery+= "  FROM "+RetSqlName("SF2")+" SF2"+CRLF
cQuery+= "  INNER JOIN "+RetSqlName("SD2")+" SD2"+CRLF
cQuery+= "  ON F2_FILIAL = D2_FILIAL"+CRLF
cQuery+= "  AND F2_DOC  = D2_DOC"+CRLF
cQuery+= "  AND F2_SERIE= D2_SERIE"+CRLF
If cCodTes <> "''" //Se !Empty(), porém estamos recebendo com abre e fecha aspas.
	cQuery+= "  AND D2_TES IN (" + cCodTes + ")"+CRLF
EndIf
cQuery+= "  AND SD2.D_E_L_E_T_ <> '*' "+CRLF

cQuery+= "   LEFT JOIN "+RetSqlName("SL1")+" SL1"+CRLF
cQuery+= "   ON L1_FILIAL = F2_FILIAL"+CRLF
cQuery+= "   AND L1_DOC = F2_DOC"+CRLF
cQuery+= "   AND L1_SERIE = F2_SERIE"+CRLF
cQuery+= "   AND SL1.D_E_L_E_T_ <> '*'  "+CRLF
     
cQuery+= "  WHERE F2_FILIAL = '"+xFilial("SF2")+"'"+CRLF
cQuery+= "  AND F2_EMISSAO BETWEEN '"+DTOS(dDtIni)+"' AND '"+DTOS(dDtFim)+"'" +CRLF
cQuery+= "  AND SF2.D_E_L_E_T_ <> '*'"+CRLF
cQuery+= "  ORDER BY D2_EMISSAO,D2_DOC,D2_SERIE,D2_ITEM"+CRLF

cQuery:= ChangeQuery(cQuery) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza a query³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select(cAliasTrb) > 0
	(cAliasTrb)->(dbCloseArea())
EndIf
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTrb, .F., .T.)
 

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} M855VldMes()

Valida o grupo de pergunta

@return lRet
    
@author Vendas 
@since 21/08/2013
/*/
//-------------------------------------------------------------------- 
Function M855VldMes(nTipo,xMvPar)

Local lRet:=.T.

Default nTipo := 0 
Default xMvPar:= 0
     
If nTIpo == 1
	If FirstDay(xMvPar) <> xMvPar
		MV_PAR01:= FirstDay(xMvPar)
		MsgInfo(STR0009,STR0010)//"O parametro foi modificado para o primeiro dia do mes informado."###"Atenção"
	EndIf
ElseIf nTipo == 2
	If xMvPar == 0 .OR. xMvPar > 12 	 
		MsgInfo(STR0011,STR0010)//"A quantidade informada é superior ao permitido ou igual a zero."###"Atenção"		
		lRet:=.F.
	EndIf
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Lj7021ValTes()

	Valida a Tes informada
	@type  Function
	@author Marisa Cruz
	@since 08/07/2019
	@version 12.1.23
	@param MV_PAR03
	@return lRet
/*/
//--------------------------------------------------------------------  
Function LJ7021ValTES(cTESValid)

Local lRet	:= .F.

If ExistFunc("LJ7020VALTES")		//O valid encontra-se em LOJA7020.PRW
	lRet := Lj7020ValTes(cTesValid)
EndIf

Return lRet