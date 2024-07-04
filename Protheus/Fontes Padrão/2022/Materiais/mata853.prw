#include "MATA853.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH' 

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA853()

Analise de rentabilidade por vendedor
  
@param lPergunta - Determina se exibe o pergunte MATA853
  
@author Vendas CRM
@since 20/10/2012
/*/
//--------------------------------------------------------------------       
Function MATA853(lPergunta)

Private d853DtIni  
Private d853DtFin 
 
Default lPergunta := .T.

INCLUI:= IF(Type("INCLUI") == "U", .F., INCLUI)
ALTERA:= IF(Type("ALTERA") == "U", .F., ALTERA)

If !lPergunta .OR. Pergunte("MATA853", lPergunta)
		
	d853DtIni := mv_par01
	d853DtFin := mv_par02 
	
	FWExecView(STR0001,'mata853',  MODEL_OPERATION_VIEW,,  {|| .T. } )//'Vendedores'
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
Local lUpdLo118 := AIH->(FieldPos("AIH_MRGREG")) > 0 .AND. AII->(FieldPos("AII_MRGREG")) > 0 // Verifica se o update foi executado

d853DtIni := IIF( Empty( d853DtIni ), Date(), d853DtIni )
d853DtFin := IIF( Empty( d853DtFin ), Date(), d853DtFin )

If lUpdLo118
	//monta array de dados para fazer a carga de dados e adiciona campos novos na estrutura do model do grid 
	MsgRun(STR0003, STR0002, { || aDados := M853Vendedor(d853DtIni, d853DtFin,MV_PAR03,MV_PAR04,,MV_PAR05,MV_PAR06) } ) //"Aguarde"//"Carregando dados. Aguarde....."
	oModelGrid:SetLoad( {|| M850LoadGrid(aDados,MV_PAR05,MV_PAR06)} )
Else
	//monta array de dados para fazer a carga de dados e adiciona campos novos na estrutura do model do grid 
	MsgRun(STR0003, STR0002, { || aDados := M853Vendedor(d853DtIni, d853DtFin) } ) //"Aguarde"//"Carregando dados. Aguarde....."
	oModelGrid:SetLoad( {|| M850LoadGrid(aDados)} ) 
EndIf      

Return oModel 

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()

View - Analise de rentabilidade por vendedor
   
@author Vendas CRM
@since 20/10/2012
/*/
//--------------------------------------------------------------------  
Static Function ViewDef() 
  
Local oModel 	:= FWLoadModel( 'mata853' ) 			//Utiliza o model deste fonte
Local oView := FWLoadView( "mata850" )				//herda a view padrao para a consulta
Local oStruGrid := oView:GetViewStruct("VIEW_GRID") 	//pega a estrutura do grid (view)
Local oModelGrid := oModel:GetModel("MODEL_GRID")	
Local lUpdLo118 := AIH->(FieldPos("AIH_MRGREG")) > 0 .AND. AII->(FieldPos("AII_MRGREG")) > 0 // Verifica se o update foi executado
 

//-----------------------------------------------------------------------------------------------
// Altera a descricao de alguns campos do grid
// ATENCAO: DEVE-SE ALTERAR A DESCRICAO NO MODEL TAMBEM PARA FUNCIONAR OS FILTROS DO GRID 
//------------------------------------------------------------------------------------------------
oStruGrid:SetProperty("ZAB_ID", MVC_VIEW_TITULO, STR0006)//"Codigo"
oStruGrid:SetProperty("ZAB_DESC", MVC_VIEW_TITULO, STR0007)//"Nome"

//--------------------------------------------------------------------------
// add botoes com as acoes
// determina que a legenda do grafico sera baseada no campo ZAB_DESC
//--------------------------------------------------------------------------

If lUpdLo118
	oView:AddOtherObject('VIEW_BOTOES', {|oPanel| M850BtBar( oPanel , oModel , {|| M853Detalhe(oModelGrid) } ,;
									  "ZAB_DESC" , /*cTitle*/,{|| M850ImpRel(oModel,oView:GetViewStruct("VIEW_GRID") ,;
									   STR0005),STR0001 })} )  //"Vendedores"  //"Analise de rentabilidade por Vendedores" 
Else
	oView:AddOtherObject('VIEW_BOTOES', {|oPanel| M850BtBar( oPanel , oModel , {|| M853Detalhe(oModelGrid) } ,;
									    "ZAB_DESC" , /*cTitle*/) })
EndIf
oView:SetOwnerView( 'VIEW_BOTOES', 'SUPERIOR' )

oView:SetModel(oModel) //associa a view com o model



Return oView 

//-------------------------------------------------------------------
/*/{Protheus.doc} M853Detalhe()

Abre consulta de rentabilidade por Pedidos 

@param oModelGrid - model do grid de vendedores
   
@author Vendas CRM
@since 20/10/2012
/*/
//--------------------------------------------------------------------  
Function M853Detalhe(oModelGrid)
Local lUpdLo118 := AIH->(FieldPos("AIH_MRGREG")) > 0 .AND. AII->(FieldPos("AII_MRGREG")) > 0 // Verifica se o update foi executado

d853DtIni := IIF( Empty( d853DtIni ), Date(), d853DtIni )
d853DtFin := IIF( Empty( d853DtFin ), Date(), d853DtFin )

If lUpdLo118 
	//abre consulta de rentabilidade por Vendas (passa o vendedor selecionado)
	MATA851(.F., d853DtIni, d853DtFin, oModelGrid:GetValue("ZAB_ID"),oModelGrid:GetValue("ZAB_ID"),MV_PAR05,MV_PAR06)
Else
	//abre consulta de rentabilidade por Vendas (passa o vendedor selecionado)
	MATA851(.F., d853DtIni, d853DtFin, oModelGrid:GetValue("ZAB_ID") )
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} M853Vendedor()

Consulta vendedores para montar tela de rentabilidade

@param dDtIni - data inicial (para pesquisar os pedidos)
@param dDtFin - data final (para pesquisar os pedidos)
@param nOrdem - ordena drescente ou decrescente
@param nIndicador - por qual campo deve ordenar

@return aVendedores - Lista de vendedores ( Cod Vendedor | Nome | Custo total dos pedidos | Fat Total  )    
   
@author Vendas CRM
@since 20/10/2012
/*/
//--------------------------------------------------------------------  
Function M853Vendedor(dDtIni, dDtFin,cVendIni,cVendFim,nOrdem,nIndicador)

Local aArea := GetArea()
Local aAreaSA3 := SA3->(GetArea())
Local aData := {}
/* aData
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
Local aRentab := {}
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

Local cAuxCliente := ""
Local cAuxVendedor := ""
Local cAuxCondPagto := ""
Local aDadosAux	:= {}
Local aVendedores := {}
Local nI := 0
Local lUpdLo118 := AIH->(FieldPos("AIH_MRGREG")) > 0 .AND. AII->(FieldPos("AII_MRGREG")) > 0 // Verifica se o update foi executado 
Local aFieldsPD := {"A3_NOME"} 
Local cVENDObfus :=""
Local lVENDObfus :=  .F.
 
Default cVendIni  := ''
Default cVendFim  := '' 
Default nOrdem    := 0
Default nIndicador:= 0

FATPDLoad(Nil, Nil, aFieldsPD)
lVENDObfus :=  FATPDIsObfuscate("A3_NOME")
//Procura vendedores
DbSelectArea("SA3")
DbSetOrder(1) 

If DbSeek(xFilial("SA3"))
	While SA3->(!EOF()) .AND. SA3->A3_FILIAL == xFilial("SA3") 	
		If lUpdLo118		
			If SA3->A3_COD >= cVendIni .AND. SA3->A3_COD <= cVendFim
				aDadosAux := M851Pedidos(dDtIni, dDtFin, SA3->A3_COD,SA3->A3_COD,1,nOrdem,nIndicador)						
				//Faz o Sum das vendas de cada vendedor
				nCustoAux := 0
				nPrecoAux := 0
				For nI := 1 to Len(aDadosAux)
					nCustoAux += aDadosAux[nI][3]
					nPrecoAux += aDadosAux[nI][4]
				Next nI
				If lVENDObfus .And. Empty(cVENDObfus)
					cVENDObfus:=FATPDObfuscate(SA3->A3_NOME)		
				EndIf
				AADD(aVendedores, {SA3->A3_COD,Iif(Empty(cVENDObfus), SA3->A3_NOME,cVENDObfus), nCustoAux, nPrecoAux})  
			EndIf	
		Else  
			aDadosAux := M851Pedidos(dDtIni, dDtFin, SA3->A3_COD)								
			//Faz o Sum das vendas de cada vendedor
			nCustoAux := 0
			nPrecoAux := 0
			For nI := 1 to Len(aDadosAux)
				nCustoAux += aDadosAux[nI][3]
				nPrecoAux += aDadosAux[nI][4]
			Next nI	
			If lVENDObfus .And. Empty(cVENDObfus)
				cVENDObfus:=FATPDObfuscate(SA3->A3_NOME)		
			EndIf		
			AADD(aVendedores, {SA3->A3_COD,Iif(Empty(cVENDObfus), SA3->A3_NOME,cVENDObfus), nCustoAux, nPrecoAux})  
		EndIf	
		SA3->(DbSkip())
	EndDo
EndIf
	          

If lUpdLo118 .AND.	Len(aVendedores)>0 
	If nOrdem == 1 //Crescente
		Do Case
			Case nIndicador == 1 //Nome Vendedor
				aVendedores := aSort( aVendedores,,, { |x,y| x[2] < y[2] } )
			Case nIndicador == 2 //Custo
				aVendedores := aSort( aVendedores,,, { |x,y| x[3] < y[3] } )	
		EndCase	
	Else//Decrescente
		Do Case
			Case nIndicador == 1 //Nome Vendedor
				aVendedores := aSort( aVendedores,,, { |x,y| x[2] > y[2] } )	
			Case nIndicador == 2 //Custo
				aVendedores := aSort( aVendedores,,, { |x,y| x[3] > y[3] } )	
		EndCase	
	EndIf
EndIf	

SA3->(RestArea(aAreaSA3))
RestArea(aArea)

FATPDUnload()
Return aVendedores




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
/*/{Protheus.doc} FATPDUnload
    @description
    Finaliza o gerenciamento dos campos com proteção de dados.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cSource, Caractere, Remove da pilha apenas o recurso que foi carregado.
    @return return, Nulo
    @example FATPDUnload("XXXA010") 
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDUnload(cSource)    

    If FATPDActive()
		FTPDUnload(cSource)    
    EndIf

Return Nil

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
