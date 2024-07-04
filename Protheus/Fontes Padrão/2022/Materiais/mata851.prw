#include "MATA851.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH' 

Static aDados := {}

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA851()

Analise de rentabilidade por Produtos
  
@param [lPergunta], logico, Determina se exibe o pergunte "MATA851"
@param [dDtIni], data inicial do pedido 
@param [dDtFin], data final do pedido 
@param [cCodVend], caractere, codigo do vendedor
@param cCodVendFim  Codigo vendedor final
@param nOrdem       Ordem - crescente ou decrescente
@param nIndicador   - indicador- custo, margem, markup...
  
@author Vendas CRM
@since 20/10/2012
/*/
//-------------------------------------------------------------------- 
Function MATA851(lPergunta, dDtIni, dDtFin, cCodVend,;
			     cCodVendFim ,nOrdem,nIndicador) 
			     
Local lUpdLo118 := AIH->(FieldPos("AIH_MRGREG")) > 0 .AND. AII->(FieldPos("AII_MRGREG")) > 0 // Verifica se o update foi executado 

Default lPergunta := .T.
Default cCodVend := ""
Default nOrdem:=0
Default nIndicador:=0
Default cCodVendFim:=''  

INCLUI:= IF(Type("INCLUI") == "U", .F., INCLUI)
ALTERA:= IF(Type("ALTERA") == "U", .F., ALTERA)


If !lPergunta .OR. Pergunte("MATA851", lPergunta)
	//recebe codigo do orcamento/venda na chamada da funcao
	If !lPergunta
		mv_par01 := dDtIni
		mv_par02 := dDtFin
		mv_par03 := cCodVend
		If lUpdLo118
			mv_par04 := cCodVendFim				
			mv_par05 := 1 
			mv_par06 := nOrdem 
			mv_par07 := nIndicador 			
		EndIf	
	EndIf
		
		
	FWExecView(Iif(nModulo == 12,STR0011,STR0001),'mata851',  MODEL_OPERATION_VIEW,,  {|| .T. } , , )//"Orçamentos/Vendas"###"Pedido"
EndIf		


Return


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()

Menu - Analise de rentabilidade por Produtos
   
@author Vendas CRM
@since 20/10/2012
/*/
//--------------------------------------------------------------------  
Static Function MenuDef() 
Return FWLoadMenuDef( "mata850") 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()

Model - Analise de rentabilidade por Produtos
   
@author Vendas CRM
@since 20/10/2012
/*/
//--------------------------------------------------------------------  
Static Function ModelDef() 

Local oModel := FWLoadModel( "mata850" )   			//herda o model padrao para a consulta
Local oModelGrid := oModel:GetModel("MODEL_GRID")		//pega o model do grid
Local oStructGrid	:= oModelGrid:GetStruct()			//pega a estrutura do grid (para add novos campos)
Local lUpdLo118 := AIH->(FieldPos("AIH_MRGREG")) > 0 .AND. AII->(FieldPos("AII_MRGREG")) > 0 // Verifica se o update foi executado

If lUpdLo118
	//monta array de dados para fazer a carga de dados e adiciona campos novos na estrutura do model do grid 
	MsgRun(STR0003, STR0002, { || aDados := M851Pedidos(mv_par01, mv_par02, mv_par03,mv_par04,;
														 mv_par05,mv_par06,mv_par07) } ) //"Aguarde"//"Carregando dados. Aguarde....."
Else
	//monta array de dados para fazer a carga de dados e adiciona campos novos na estrutura do model do grid 
	MsgRun(STR0003, STR0002, { || aDados := M851Pedidos(mv_par01, mv_par02, mv_par03) } ) //"Aguarde"//"Carregando dados. Aguarde....."
EndIf

oStructGrid:AddField(STR0004, "" , "ZAB_CLI", "C", 30 )//"Cliente"
oStructGrid:AddField(STR0005, "" , "ZAB_VEND", "C",30 )//"Vendedor"
oStructGrid:AddField(STR0006, "" , "ZAB_CONGPG", "C", 30 )//"CondPagto"

//-----------------------------------------------------------------------------------------------
// Altera a descricao de alguns campos do grid
// ATENCAO: DEVE-SE ALTERAR A DESCRICAO NO VIEW TAMBEM PARA FUNCIONAR OS FILTROS DO GRID 
//------------------------------------------------------------------------------------------------
If nModulo <> 12
	oStructGrid:SetProperty("ZAB_ID", MODEL_FIELD_TITULO , STR0007)//"Num Pedido"
Else	   
	oStructGrid:AddField("Nota" ,""  , "ZAB_NOTA", "C", TamSx3("L2_DOC")[1] ) 
	oStructGrid:AddField("Serie",""  , "ZAB_SERIE", "C",TamSx3("L2_SERIE")[1] )
	oStructGrid:SetProperty("ZAB_ID"   , MODEL_FIELD_TITULO , STR0011)//"Orçamento/Venda"
	oStructGrid:SetProperty("ZAB_ID"   , MODEL_FIELD_TAMANHO, 10)//Reduz o tamanho
	oStructGrid:SetProperty("ZAB_DESC" , MODEL_FIELD_TAMANHO, 10)//Reduz o tamanho	
EndIf
oStructGrid:SetProperty("ZAB_DESC", MODEL_FIELD_TITULO , STR0008)//"Emissão"


If lUpdLo118
	oModelGrid:SetLoad( {|| M850LoadGrid(aDados,MV_PAR06,MV_PAR07)} )
Else 
	oModelGrid:SetLoad( {|| M850LoadGrid(aDados)} )
EndIf

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()

View - Analise de rentabilidade por Produtos
   
@author Vendas CRM
@since 20/10/2012
/*/
//--------------------------------------------------------------------  
Static Function ViewDef() 
  
Local oModel 	:= FWLoadModel( 'mata851' ) 			//Utiliza o model deste fonte
Local oView := FWLoadView( "mata850" )				//herda a view padrao para a consulta
Local oStruGrid := oView:GetViewStruct("VIEW_GRID") 	//pega a estrutura do grid (view)
Local oModelGrid := oModel:GetModel("MODEL_GRID")	
Local lUpdLo118 := AIH->(FieldPos("AIH_MRGREG")) > 0 .AND. AII->(FieldPos("AII_MRGREG")) > 0 // Verifica se o update foi executado
Local lRet := .T.
 

//add os novos campos na estrutura da view do grid
M850ViewStr(oModel, @oStruGrid) 	

//-----------------------------------------------------------------------------------------------
// Altera a descricao de alguns campos do grid
// ATENCAO: DEVE-SE ALTERAR A DESCRICAO NO MODEL TAMBEM PARA FUNCIONAR OS FILTROS DO GRID 
//------------------------------------------------------------------------------------------------
If nModulo <> 12
	oStruGrid:SetProperty("ZAB_ID", MVC_VIEW_TITULO, STR0009)//"Num Pedido"
Else  
	oStruGrid:SetProperty("ZAB_ID"     , MVC_VIEW_TITULO, STR0011)//"Orçamento/Venda"
	oStruGrid:SetProperty("ZAB_ID" , MVC_VIEW_ORDEM, '01')
	oStruGrid:SetProperty("ZAB_NOTA" , MVC_VIEW_ORDEM, '02')
	oStruGrid:SetProperty("ZAB_SERIE" ,MVC_VIEW_ORDEM, '03')
EndIf
oStruGrid:SetProperty("ZAB_DESC", MVC_VIEW_TITULO, STR0010)//"Emissão"

If lUpdLo118 
	If Len( aDados ) > 0 
		oView:AddOtherObject('VIEW_BOTOES', {|oPanel| M850BtBar( oPanel , oModel, {|| M851Detalhe(oModelGrid) }, /*cFieldDesc*/, /*cTitle*/ ,;
									    {|| M850ImpRel(oModel,oView:GetViewStruct("VIEW_GRID") , STR0013)  ,;
									    Iif(nModulo==12,STR0011,STR0001) } )} ) // botoes com as acoes //"Analise de rentabilidade por Orçamentos/Vendas"  //"Orçamentos/Vendas"//##"Pedido"
	Else
		lRet := .F.									
	EndIf					
Else
	oView:AddOtherObject('VIEW_BOTOES', {|oPanel| M850BtBar( oPanel , oModel, {|| M851Detalhe(oModelGrid) }, /*cFieldDesc*/, /*cTitle*/ )})
EndIf	
If lRet 
	oView:SetOwnerView( 'VIEW_BOTOES', 'SUPERIOR' )
EndIf

oView:SetModel(oModel) //associa a view com o model

Return oView 

//-------------------------------------------------------------------
/*/{Protheus.doc} M851Detalhe()

Abre consulta de rentabilidade por Produto 

@param oModelGrid - model do grid de Pedidos
   
@author Vendas CRM
@since 20/10/2012
/*/
//--------------------------------------------------------------------  
Function M851Detalhe(oModelGrid)

//abre consulta de rentabilidade por produto (passa a venda selecionada)
MATA852(.F., oModelGrid:GetValue("ZAB_ID") )

Return



//-------------------------------------------------------------------
/*/{Protheus.doc} M851Pedidos()

Consulta pedidos para exibicao

@param dDtIni, data, data inicial (pedido)
@param dDtFin, data, data final (pedido)
@param [cCodVend], caractere, codigo do vendedor
@param cVendFim  Codigo vendedor final
@param nVendas  Vendas ou orçamentos
@param nOrdem       Ordem - crescente ou decrescente
@param nIndicador   - indicador- custo, margem, markup...   
 
@return aDados, array, ( ID, Descricao, Custo, Preco, .....<campos adicionais> )
   
@author Vendas CRM
@since 20/10/2012
/*/
//--------------------------------------------------------------------  
Function M851Pedidos(dDtIni, dDtFin, cCodVend,cVendFim,;
					 nVendas,nOrdem,nIndicador)

Local aArea := GetArea()
Local aAreaSC5 := SC5->(GetArea())
Local aAreaSC6 := SC6->(GetArea())
Local aAreaSL1 := SL1->(GetArea())
Local aAreaSL2 := SL2->(GetArea())
Local nItem    := 0
Local aDados := {}
/* aDados
[n] Array com os campos retornado
[n][01] ExpC:Id
[n][02] ExpC:Descricao
[n][03] ExpN:Custo
[n][04] ExpN:Preco
.....   campos adicionais (opicional)
*/	

Local aItens := {}
Local aVendas := {}
Local aHeaderDt := {}
Local nCustoAux := 0
Local nPrecoAux := 0
Local aRentab := {} // array de rentabilidade do produto
Local dDtEmis := CTOD("  /  /  ")// data de emissao 
/*
aRentab
[n]    Item do pedido
[n][1] codigo do produto
[n][2] Valor Total (unit * qtde)
[n][3] C.M.V. (custo)
[n][4] Valor Presente
[n][5] Lucro Bruto (Valor presente - CMV)
[n][6] Margem de Contribuicao (%)
*/
Local cAuxCliente 	:= ""
Local cAuxVendedor 	:= ""
Local cAuxCondPagto := ""
Local cAliasTrb     := '' // alias temporario
Local cNum          := ''// numero do orçamento SIGALOJA
Local cDocumento    := '' // Numero do documento
Local cSerie        := '' // Serie do documento
Local cMoeda		:= Alltrim(Str(SuperGetMV("MV_LJMDORC",,1)))//moeda do sistema
Local aRet  		:= {}// array de retorno da funcao PegaCMAtu
Local lUpdLo118 	:= AIH->(FieldPos("AIH_MRGREG")) > 0 .AND. AII->(FieldPos("AII_MRGREG")) > 0 // Verifica se o update foi executado 
Local aPDFields  	:= {"A3_NOME","A1_NOME"} 
Local cVENDObfus 	:= ""

Default cCodVend 	:= ""
Default cVendFim  	:= ""
Default nVendas   	:= 1
Default nOrdem    	:= 0
Default nIndicador	:= 0
FATPDLoad(/*cUser*/,/*aAlias*/, aPDFields, /*cSource*/)
lVENDObfus :=  FATPDIsObfuscate("A3_NOME")

dDtIni:= IIF( Empty( dDtIni ), Date(), dDtIni)
dDtFin:= IIF( Empty( dDtFin ), Date(), dDtFin)

If nModulo <> 12
	//Procura vendas
	DbSelectArea("SC5")
	DbSetOrder(2) //C5_FILIAL+DTOS(C5_EMISSAO)+C5_NUM		
	//Pesquisa pela data de emissao do pedido - pega todos os pedidos entre 2 datas - SoftSeek = .T.	 
	DbSeek(xFilial("SC5") + DtoS(dDtIni), .T.)
	While SC5->(!EOF()) .AND. SC5->C5_FILIAL == xFilial("SC5") .AND. (SC5->C5_EMISSAO >= dDtIni) .AND. (SC5->C5_EMISSAO <= dDtFin)		
		//filtra vendedor
		If !Empty(cCodVend) .AND. (cCodVend <> SC5->C5_VEND1)
			SC5->(DbSkip())
			Loop		
		EndIf		
		//busca custo medio e valor presente 
		aRentab := Mat410Rent(SC5->C5_NUM)
		nCustoAux := aRentab[Len(aRentab)][3]
		nPrecoAux := aRentab[Len(aRentab)][4]
		
		cAuxCliente := FATPDObfuscate(Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE,"A1_NOME"),"A1_NOME")
		cAuxVendedor := FATPDObfuscate(Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_NOME"),"A3_NOME")
		cAuxCondPagto := Posicione("SE4",1,xFilial("SE4")+SC5->C5_CONDPAG,"E4_DESCRI")
			
		//cria o item de rentabilidade que representa a analise de rentabilidade da venda - sera o registro da venda no grid
		//AADD(aVendas, ItemProfitability():New( SC5->C5_NUM  , SC5->C5_EMISSAO, nCustoAux, nPrecoAux, {cAuxCliente, cAuxVendedor, cAuxCondPagto } ))	
		
		//Monta o array com os dados que serao retornado
		AADD(aDados, {SC5->C5_NUM, SC5->C5_EMISSAO, nCustoAux, nPrecoAux, cAuxCliente, cAuxVendedor, cAuxCondPagto})
						
		SC5->(DbSkip())
	EndDo
ElseIf nModulo == 12 .AND. lUpdLo118 	
	//Procura orçamentos/vendas
	cAliasTrb:= LjFildados(dDtIni, dDtFin, cCodVend,cVendFim,;
							 nVendas)
	While (cAliasTrb)->(!EOF()) 
		
		nItem     :=0
		cNum      := (cAliasTrb)->L1_NUM
		cDocumento:= (cAliasTrb)->L1_DOC 
		cSerie    := (cAliasTrb)->L1_SERIE	   
	         
		cAuxCliente  := Posicione("SA1",1,xFilial("SA1")+(cAliasTrb)->L1_CLIENTE,"A1_NOME")
		cAuxVendedor := Posicione("SA3",1,xFilial("SA3")+(cAliasTrb)->L1_VEND,"A3_NOME")
		cAuxCondPagto:= Iif(Empty((cAliasTrb)->L1_CONDPG),'',Posicione("SE4",1,xFilial("SE4")+(cAliasTrb)->L1_CONDPG,"E4_DESCRI") )

		Do Case
			Case nVendas == 1
			    dDtEmis:= STOD((cAliasTrb)->L1_EMISNF)
			Case nVendas == 2
				dDtEmis:= STOD((cAliasTrb)->L1_EMISSAO)
			Case nVendas == 3
				dDtEmis:= STOD( Iif(Empty((cAliasTrb)->L1_EMISNF),(cAliasTrb)->L1_EMISSAO,(cAliasTrb)->L1_EMISNF) )			
		EndCase

        While (cAliasTrb)->(!EOF()) .AND. (cAliasTrb)->L2_NUM == cNum	         
	        If !EMPTY( (cAliasTrb)->L1_DOC )
	        	nCustoAux += (cAliasTrb)->&("D2_CUSTO"+cMoeda) 
	        Else
				aRet  := PegaCMAtu((cAliasTrb)->L2_PRODUTO,(cAliasTrb)->L2_LOCAL)
		        nCustoAux += (cAliasTrb)->L2_QUANT*aRet[Val(cMoeda)]
	        EndIf	
	        nPrecoAux += MaValPres((cAliasTrb)->L2_VLRITEM,dDtEmis,,,dDtEmis)
        	(cAliasTrb)->(DbSkip())
        EndDo 
		//Monta o array com os dados que serao retornado
		If lVENDObfus
			cVENDObfus:=FATPDObfuscate(SA3->A3_NOME)		
		EndIf
		AADD(aDados, {cNum,dDtEmis, nCustoAux, nPrecoAux,cAuxCliente, Iif(Empty(cVENDObfus), cAuxVendedor,cVENDObfus), cAuxCondPagto,cDocumento,cSerie})    		
		nCustoAux := 0
		nPrecoAux := 0
		Loop		
	EndDo
	(cAliasTrb)->(dbCloseArea())
	
EndIf

If lUpdLo118 .AND. Len(aDados)>0	
	If nOrdem == 1 //Crescente
		Do Case
			Case nIndicador == 1 // Dt Emissao
				aDados := aSort( aDados,,, { |x,y| x[2] < y[2] } )	
			Case nIndicador == 2 //Custo
				aDados := aSort( aDados,,, { |x,y| x[3] < y[3] } )	
		EndCase	
	Else//Decrescente
		Do Case
			Case nIndicador == 1 // Dt Emissao
				aDados := aSort( aDados,,, { |x,y| x[2] > y[2] } )	
			Case nIndicador == 2 //Custo
				aDados := aSort( aDados,,, { |x,y| x[3] > y[3] } )	
		EndCase	
	EndIf
EndIf	

SC6->(RestArea(aAreaSC6))
SC5->(RestArea(aAreaSC5))
SL1->(RestArea(aAreaSL1))
SL2->(RestArea(aAreaSL2))
RestArea(aArea)


Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} LjFildados()

Consulta orcamentos/vendas para exibicao
                                        
@param dDtIni - Data inicial 
@param dDtFin - Data final
@param cCodVend - Vendedor inicial
@param cVendFim - Vendedor Final
@param nVendas  - Define se a consulta retorne apenas vendas, orcamentos ou Ambos

@author Vendas 
@since 20/08/2013
/*/
//--------------------------------------------------------------------  
Static Function LjFildados(dDtIni, dDtFin, cCodVend,cVendFim,;
					       nVendas)

Local cQuery:= ''  // varial para escrita da query
Local cAliasTrb:= GetNextAlias() // pga proxima alias disponivel
Local cMoeda:= Alltrim(Str(SuperGetMV("MV_LJMDORC",,1)))// moeda do sistema

cQuery+= " SELECT  L1_NUM,L2_NUM,L1_EMISSAO,L1_VEND,L1_DOC,L1_EMISNF,L1_FORMPG,L1_CLIENTE,L1_LOJA,L1_TIPO,L1_TIPOCLI,"+CRLF
cQuery+= " L1_CONDPG,L2_PRODUTO,L2_TES,L2_VRUNIT,L2_LOCAL,L2_QUANT,L2_VALDESC,L2_VLRITEM,L1_DOC,L1_SERIE,D2_CUSTO"+cMoeda+CRLF
cQuery+= "  FROM "+RetSqlName("SL1")+" SL1"
cQuery+= "  INNER JOIN "+RetSqlName("SL2")+" SL2"
cQuery+= "  ON L1_FILIAL = L2_FILIAL"
cQuery+= "  AND L1_NUM = L2_NUM"
cQuery+= "  AND SL2.D_E_L_E_T_ <> '*' "

cQuery+= "  LEFT JOIN "+RetSqlName("SD2")+" SD2"
cQuery+= "  ON L2_FILIAL = D2_FILIAL"
cQuery+= "  AND L1_DOC = D2_DOC"
cQuery+= "  AND L1_SERIE = D2_SERIE"
cQuery+= "  AND L2_ITEM = D2_ITEM"
cQuery+= "  AND SL2.D_E_L_E_T_ <> '*' "

cQuery+= "  WHERE L1_FILIAL = '"+xFilial("SL1")+"'"
cQuery+= "  AND L1_VEND BETWEEN '"+cCodVend+"' AND '"+cVendFim+"'"
If nVendas == 1
	cQuery+= "  AND L1_EMISNF BETWEEN '"+DTOS(dDtIni)+"' AND '"+DTOS(dDtFin)+"'" 
	cQuery+= "  AND L1_DOC <> '"+Space(TamSx3("L1_NUM")[1] )+"' "	
ElseIf nVendas == 2
	cQuery+= "  AND L1_EMISSAO BETWEEN '"+DTOS(dDtIni)+"' AND '"+DTOS(dDtFin)+"'" 
	cQuery+= "  AND L1_DOC = '"+Space(TamSx3("L1_NUM")[1] )+"' "	
ElseIf nVendas == 3	
	cQuery+= "  AND L1_EMISSAO BETWEEN '"+DTOS(dDtIni)+"' AND '"+DTOS(dDtFin)+"'" 
EndIf
cQuery+= "  AND SL1.D_E_L_E_T_ <> '*'"
cQuery+= "  ORDER BY L2_NUM,L2_ITEM,L1_EMISSAO"                
cQuery:= ChangeQuery(cQuery) 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza a query³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select(cAliasTrb) > 0
	(cAliasTrb)->(dbCloseArea())
EndIf
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTrb, .F., .T.)
 
 
Return cAliasTrb




//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLoad
    @description
    Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cUser, Caractere, Nome do usuário utilizado para validar se possui acesso ao 
        dados protegido.
    @param aAlias, Array, Array com todos os Alias que serão verificados.
    @param aFields, Array, Array com todos os Campos que serão verificados, utilizado 
        apenas se parametro aAlias estiver vazio.
    @param cSource, Caractere, Nome do recurso para gerenciar os dados protegidos.
    
    @return cSource, Caractere, Retorna nome do recurso que foi adicionado na pilha.
    @example FATPDLoad("ADMIN", {"SA1","SU5"}, {"A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDLoad(cUser, aAlias, aFields, cSource)
	Local cPDSource := ""

	If FATPDActive()
		cPDSource := FTPDLoad(cUser, aAlias, aFields, cSource)
	EndIf

Return cPDSource

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta função deve utilizada somente após 
    a inicialização das variaveis atravez da função FATPDLoad.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FATPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDIsObfuscate(cField, cSource, lLoad)
    
	Local lObfuscate := .F.

    If FATPDActive()
		lObfuscate := FTPDIsObfuscate(cField, cSource, lLoad)
    EndIf 

Return lObfuscate


//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue   



//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  
