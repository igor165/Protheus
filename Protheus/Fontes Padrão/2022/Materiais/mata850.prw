#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE "PRCONST.CH"
#include "MATA850.CH"

Static N_TAMPAER	:= 18
Static N_DESPER	:= 6 
Static lMosMsg 	:= .T. 
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()

Model - estrutura base da tela de consulta de rentabilidade
   
@author Vendas CRM
@since 20/10/2012
/*/
//--------------------------------------------------------------------  
Static Function ModelDef()

Local oModel 		:= MPFormModel():New( 'mata850' ) 
Local oStruMain	:= nil
Local oStruFake 	:= FWFormModelStruct():New() //estrutura fake - criada apenas porque eh obrigatorio a criacao de um componente de formulario ao modelo




//------------------------------------------------
//		Cria a estrutura basica manualmente
//------------------------------------------------
oStruMain := FWFormModelStruct():New()
oStruMain:AddTable( "ZAB" , { "ZAB_ID" } , STR0001 )//"Rentabilidade"
oStruMain:AddField("ID", "" , "ZAB_ID", "C", 20 )

oStruMain:AddField(STR0002, "" ,"ZAB_DESC"	, "C", 50 )//"Descrição"
oStruMain:AddField(STR0003, "" ,"ZAB_CUSTO"	, "N", 14, 2 )//"Custo"
oStruMain:AddField(STR0004, "" ,"ZAB_PRECO"	, "N", 14, 2 )//"Prc Tot Vnd"
oStruMain:AddField(STR0005, "" ,"ZAB_LUCRO"	, "N", 14, 2 )//"Lucro"
oStruMain:AddField(STR0006, "" ,"ZAB_MARGEM"	, "N", 14, 2 )//"Margem"
oStruMain:AddField(STR0007, "" ,"ZAB_MARKUP"	, "N", 14, 2 )//"Markup"


//------------------------------------------------------
//		Adiciona o componente de formulario no model 
//     Nao sera usado, mas eh obrigatorio ter
//------------------------------------------------------
oStruFake:AddField("FAKE", "" , "FAKE", "C", 1 ) //Obrigatorio ter um campo na estrutura só pra nao dar error log
oModel:AddFields( 'MODEL_FAKE',,oStruFake ,,, {|| } )
oModel:GetModel( 'MODEL_FAKE' ):SetDescription("Fake")

//------------------------------------------------------
//		Adiciona o Grid
//     Obs: Nao eh uma estrutura mestre detalhe.
//     O grid eh a estrutura principal
//------------------------------------------------------
oModel:AddGrid( 'MODEL_GRID', 'MODEL_FAKE', oStruMain,/*Pre-Validacao*/,/*Pos-Validacao*/,/*bPre*/,/*bPost*/, { || {}  }  /*bLoad*/) 
oModel:GetModel( 'MODEL_GRID' ):SetDescription("Grid")

//-----------------------------------------------------
//		Adiciona campos calculados baseado no grid
//-----------------------------------------------------
oModel:AddCalc(  'COMP_CALC1',  'MODEL_FAKE',  'MODEL_GRID',  'ZAB_CUSTO',  'TOTCUSTO',  'SUM'		, , , 	STR0017 )//'Custo Total'
oModel:AddCalc(  'COMP_CALC1',  'MODEL_FAKE',  'MODEL_GRID',  'ZAB_PRECO',  'TOTPRECO',  'SUM'		, , , 	STR0008 	  )//'Fat Total'
oModel:AddCalc(  'COMP_CALC1',  'MODEL_FAKE',  'MODEL_GRID',  'ZAB_LUCRO',  'TOTLUCRO',  'SUM'		, , ,	STR0009   )//'Lucro Total'
oModel:AddCalc(  'COMP_CALC1',  'MODEL_FAKE',  'MODEL_GRID',  'ZAB_MARGEM', 'TOTMARGEM', 'FORMULA'	, , ,	STR0010, { |oModel| M850CalcTot( oModel, "MARGEM" ) }  )//'Margem Geral (%)'
oModel:AddCalc(  'COMP_CALC1',  'MODEL_FAKE',  'MODEL_GRID',  'ZAB_MARKUP', 'TOTMARKUP', 'FORMULA'	, , , 	STR0011, { |oModel| M850CalcTot( oModel, "MARKUP" ) }  )//'Markup Geral (%)'


//--------------------------------------
//		Configura o model
//--------------------------------------
oModel:SetDescription(STR0012) //obrigartorio ter alguma descricao//"Análise de Rentabilidade"
oModel:SetPrimaryKey( {} ) //obrigatorio setar a chave primaria (mesmo que vazia)
 
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()

View - estrutura base da tela de consulta de rentabilidade
   
@author Vendas CRM
@since 20/10/2012
/*/
//-------------------------------------------------------------------- 
Static Function ViewDef()

Local oModel 		:= FWLoadModel( 'mata850' ) 	//Utiliza o model do fonte mata850.prw
Local oView		:= FWFormView():New() 			//Cria o objeto da view
Local oStruFake  	:= FWFormViewStruct():New()		//estrutura fake - criada apenas porque eh obrigatorio a criacao de um componente de formulario ao modelo
Local oStruMain 	:= nil
Local oCalc		:= nil

//----------------------------------------------------------
//		Cria a estrutura baseada na estrutura do model
//----------------------------------------------------------
oStruMain :=FWFormViewStruct():New()  
M850ViewStr(oModel, @oStruMain)   

	
oStruFake:AddField('FAKE', '1', 'FAKE', "FAKE", , 'C' ) //Serve apenas para evitar erro: The FWFormViewStruct doesn't have fields associated.


//--------------------------------------
//		Associa o View ao Model
//--------------------------------------
oView:SetModel( oModel )	//define que a view vai usar o model mata850
oView:SetDescription(STR0013) //"Rentabilidade"

//--------------------------------------
//		Cria os Box's
//--------------------------------------
oView:CreateHorizontalBox( "SUPERIOR", 5 )  // Box dos botoes
oView:CreateHorizontalBox( "INFERIOR", 85 )  // Box do grid
oView:CreateHorizontalBox( "TOTAIS", 10 )  // Box do grid
oView:CreateHorizontalBox( "BOX_FAKE", 0 )  // criado apenas pq o componente de formulario eh vazio, mas precisa estar em algum box (nao pode ser em um box ja utilizado, senao a tela fica vazia)


//--------------------------------------
//		Insere os componentes na view
//--------------------------------------
oView:AddField( 'VIEW_FAKE', oStruFake, 'MODEL_FAKE' ) //cria componente associado ao componente de formulario (FAKE) do model 
oView:AddGrid( 'VIEW_GRID', oStruMain, 'MODEL_GRID' ) //grid - principal

oCalc := FWCalcStruct( oModel:GetModel( 'COMP_CALC1') ) 
oView:AddField( 'VIEW_CALC', oCalc, 'COMP_CALC1' )

//--------------------------------------
//		Associa os componentes ao Box
//--------------------------------------
//oView:SetOwnerView( 'VIEW_BOTOES', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_FAKE', 'BOX_FAKE' ) 
oView:SetOwnerView( 'VIEW_GRID', 'INFERIOR' ) // Relaciona o identificador (ID) da View com o "box" para exibição  
oView:SetOwnerView( 'VIEW_CALC', 'TOTAIS' ) // Relaciona o identificador (ID) da View com o "box" para exibição

oView:SetViewProperty("VIEW_GRID","ENABLENEWGRID") //utiliza o grid novo, com opcoes para ordenar as colunas


//oView:EnableTitleView('VIEW_GRID') //exibe uma descricao antes do box do grid 


Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()

Menu - estrutura base da tela de consulta de rentabilidade
   
@author Vendas CRM
@since 20/10/2012
/*/
//-------------------------------------------------------------------- 
Static Function MenuDef() 
Return FWMVCMenu( "mata850" ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} M850ViewStr()

Monta a estrutura da view baseada na estrutura do model
@param oModel, model 
@param oViewStruct,, estrutura do model
    
@author Vendas CRM
@since 20/10/2012
/*/
//-------------------------------------------------------------------- 
Function M850ViewStr(oModel,oViewStruct)

Local nI 			:= 0
Local oStructModel		:= oModel:GetModel("MODEL_GRID"):GetStruct()		//estrutura do model do grid
Local aCamposModel		:= oStructModel:GetFields()						//array de campos da estrutura do grid no model 
Local aViewFields		:= oViewStruct:GetFields() 						//array de campos da estrutura do grid na view
Local cPicture		:= ""

//-------------------------------------------------------------------------------------
//		Adiciona um campo na estrutura da view baseada na estrutura do model (grid)
//-------------------------------------------------------------------------------------
For nI := 1 to Len(aCamposModel)

	//procura o campo na estrutura (se o campo ja existir, nao adiciona) - busca pelo ID (indice 3 do model e 1 da view)
	If aScan(aViewFields, {|x|AllTrim(x[1]) == aCamposModel[nI][3] }   ) == 0 
		If (nI >= 3) .AND. (nI <= 5)  //mascara para custo, preco e lucro
			cPicture := "@E 999,999,999.99"
		ElseIf (nI == 6) .OR. (nI ==7)  //mascara para margem e markup
			cPicture := "@E 999,999,999.99%"
		Else
			If aCamposModel[nI][4] == "N"
				cPicture := "@E 999,999,999.99"
			Else
				cPicture := ""
			EndIf	
		EndIf		
		oViewStruct:AddField(aCamposModel[nI][3], cValToChar(nI), aCamposModel[nI][1], "", , aCamposModel[nI][4] , cPicture )
	EndIf
			
Next nI


Return


//-------------------------------------------------------------------
/*/{Protheus.doc} M850CalcTot()

funcao auxiliar para calculo dos totais de margem e markup
@param oModel, model 
@param cType, caractere, "MARGEM" ou "MARKUP" - determina qual sera o calculo realizado

@return nRet, numerico, valor calculado com base nos campos do model 
    
@author Vendas CRM
@since 20/10/2012
/*/
//-------------------------------------------------------------------- 
Function M850CalcTot( oModel, cType )
Local nRet 		:= 0
Local oModelCalc 	:= oModel:GetModel('COMP_CALC1')
Local nCusto 		:= oModelCalc:GetValue('TOTCUSTO') //busca o total do custo - calculado automaticamente
Local nPreco		:= oModelCalc:GetValue('TOTPRECO') //busca o total do faturamento - calculado automaticamente
Local nLucro		:= oModelCalc:GetValue('TOTLUCRO') //busca o total do lucro - calculado automaticamente

//calcula margem geral
If cType == "MARGEM"
	nRet := nLucro / nPreco * 100
EndIf
//calcula markup geral
If cType == "MARKUP"
	nRet := nLucro / nCusto * 100
	If nRet > 999999 .AND. lMosMsg
		//"MARKUP muito alto: (" +  "Pode existir inconsistencia de informações de Custo e Lucro." + Atenção
		MsgStop(STR0027+ Alltrim(Str(nRet)) + "%)" + Chr(13) + Chr(10) +STR0028, STR0029)
		lMosMsg := .F.
	EndIf

EndIf

Return nRet



//-------------------------------------------------------------------
/*/{Protheus.doc} M850BtBar()

Cria barra de botoes
@param oPanel, painel, objeto onde sera criado a barra de botoes 
@param oModel, model,
@param bDetail, bloco de codigo, bloco de codigo para exibicao do detalhe
@param cFieldDesc, caractere, campo utilizado para descricao (legenda) no grafico 
@param cTitle, caractere, titulo do grafico
@param bRelImp, bloco de codigo para imprimir o relatorio
@param cTitle2 titulo do grafico    
@param nTpGraf - tipo de grafico 1 - barra e pizza / 2 - linechart

@author Vendas CRM
@since 20/10/2012
/*/
//-------------------------------------------------------------------- 
Function M850BtBar(oPanel, oModel, bDetail, cFieldDesc,;
				   cTitle,bRelImp,cTitle2,nTpGraf)
Local lOk := .F. 
Local oBar := nil
Local cItemSelected			:= "" 	//controla o item selecionado no combo
Local oModelGrid := oModel:GetModel("MODEL_GRID")	
Local nI := 0
Local aItensCombo := {}

Default bRelImp:= {}   // bloco de codigo para impressao do realtorio
Default nTpGraf := 1   // define qual grafico sera exibido
Default cTitle2:=''    // Titulo
//--------------------------------
// Barra de botoes
//--------------------------------
oBar := FWButtonBar():new()
oBar:Init( oPanel, 018, 015, CONTROL_ALIGN_TOP )

//so mostra o botao de detalhe se recebeu o bloco de codigo para exibir os detalhes
If !Empty(bDetail) /*Self:bCodeDetail <> nil*/
	oBar:AddBtnImage( "PMSZOOMIN", STR0014, bDetail, , ,  )//"Ver detalhe"
EndIf
      
//so mostra o botao de detalhe se recebeu o bloco de codigo para exibir os detalhes
If !Empty(bRelImp) /*Self:bCodeDetail <> nil*/
	oBar:AddBtnImage( "RELATORIO", STR0026, bRelImp, , ,  )//"Relatório"
EndIf

//------------------------------------------------------------------
// Exibe o grafico.
// o Grafico sera baseado no campo selecionado no combo box
//-----------------------------------------------------------------
If nTpGraf == 1
	oBar:AddBtnImage( "GRAF2D", STR0015, {|| M850Grafico(oModelGrid, oModelGrid:aHeader[Val(cItemSelected)][2] ,;
											              cFieldDesc, cTitle,cTitle2,nTpGraf) }, , ,  )//"Ver gráfico"
Else
	oBar:AddBtnImage( "GRAF2D", STR0015, {|| M850Grafico(oModelGrid, oModelGrid:aHeader[Val(cItemSelected)][2] ,;
									                      cFieldDesc, cTitle,cTitle2,nTpGraf) }, , ,  )//"Ver gráfico"
EndIf
//-------------------------------------------------------------------
// Combobox para selecionar por qual campo sera exibido o relatorio
// Exibe no combo os campos padroes do model do grid
//------------------------------------------------------------------
aItensCombo := { }
For nI := 1 to Len(oModelGrid:aHeader)
	If oModelGrid:aHeader[nI][8] == 'N' //soh add no combo box os campos que forem numerico (no grafico precisa ser do tipo Numerico)
		Aadd(aItensCombo, cValToChar(nI) + "=" + oModelGrid:aHeader[nI][1] )
	EndIf
Next nI

oCombo := TComboBox():New(4,50,{|u|if(PCount()>0,cItemSelected:=u,cItemSelected)},aItensCombo,100,20,oPanel,,{|| /*ComboSelect(cItemSelected)*/ },,,,.T.,,,,,,,,,'cItemSelected')		
oCombo:Select(3) //seleciona por padrao o campo lucro, para exibir o relatorio
 

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} M850Grafico()

Cria grafico

@param oModelGrid, model, model do grid
@param cFieldValue, caractere, campo utilizado para considerar os valores no grafico
@param cFieldDesc, caractere, campo utilizado para descricao (legenda) no grafico 
@param cTitle, caractere, titulo do grafico
@param cTitle2 titulo do grafico
@param nTpGraf - tipo de grafico 1 - barra e pizza / 2 - linechart
    
@author Vendas CRM
@since 20/10/2012
/*/
//-------------------------------------------------------------------- 
Function M850Grafico(oModelGrid, cFieldValue, cFieldDesc, cTitle,;
				     cTitle2,nTpGraf)
Local oGraphic	:= Nil	// Grafico dessa consulta
Local oDlgPrinc := Nil	// janela que mostrara o grafico
Local aSerie 	:= {}	// array de dados
Local nI 		:= 0	// contador para percorrer o grid do model
Local cOrdem    := ''   // Efetua validação conforme estabelecida no parametro; Crescente | Decrescente .
Local cMes      := ''   // Mes
Local lUpdLo118 := AIH->(FieldPos("AIH_MRGREG")) > 0 .AND. AII->(FieldPos("AII_MRGREG")) > 0 // Verifica se o update foi executado

Default cFieldValue	:= "ZAB_MARGEM"   //campo base para exibcao do grafico (esse campo pode ser selecionado pelo combobox da tela)
Default cFieldDesc		:= "ZAB_ID"		//campo de onde vira a descricao (legenda) do grafico
Default cTitle 		:= STR0016 + SubStr(cFieldValue, 5, Len(cFieldValue)) //titulo para o grafico//"Rentabilidade - "
Default cTitle2     := ""
Default nTpGraf:= 1 // tipo de grafico

If nModulo == 12
	Do Case
		Case FunName() == "MATA851"	
			cTitle2:= STR0018 //"Orçamento\Vendas"
		Case FunName() == "MATA852" .OR. FunName() == "MATA854"		
			cTitle2:= STR0019 //"Produtos"
		Case FunName() == "MATA853"	
			cTitle2:= STR0020 //"Vendedores"
	EndCase 
EndIf	

If nTpGraf == 1 

	If lUpdLo118 .AND. Pergunte("MATA850", .T.)
		//monta o array de dados do grafico
		For nI := 1 to oModelGrid:Length() 
			//Verifica a quantidade maxima de graficos na tela
			If nI <= MV_PAR02//nQuant
				Aadd(aSerie, {1, oModelGrid:GetValue(cFieldValue,nI), oModelGrid:GetValue(cFieldDesc,nI), 0} )	 
			EndIf	
		Next nI
	
		cOrdem:= Iif( MV_PAR01==1,STR0021,STR0022 )  // 'Crescente'###'Decrescente' 	
		//Efetua ordenação crescente ou decrescente.
		If Upper(cOrdem) == Upper(STR0021)  //'CRESCENTE'	
			aSerie := aSort( aSerie,,, { |x,y| x[2] < y[2] } )	
		Else
			aSerie := aSort( aSerie,,, { |x,y| x[2] > y[2]  } )		
		EndIf	
	Else	
		For nI := 1 to oModelGrid:Length() 
			Aadd(aSerie, {1, oModelGrid:GetValue(cFieldValue,nI), oModelGrid:GetValue(cFieldDesc,nI), 0} )	 
		Next nI
 	EndIf	
 	
	//exibe o grafico
	Define MsDialog oDlgPrinc Title cTitle+" "+cOrdem+" "+cTitle2 From 0,0 To 600,800 Pixel 
	TkC010Grap(@oGraphic,05,05,400,300, oDlgPrinc , aSerie, , , ,,.T.)
		
	Activate MsDialog oDlgPrinc Center 
		 	
ElseIf nTpGraf == 2
	//monta o array de dados do grafico
	For nI := 1 to oModelGrid:Length() 
		Aadd(aSerie, {oModelGrid:GetValue("ZAB_ID",nI), oModelGrid:GetValue(cFieldValue,nI)} )	 
		If nI == 1 
			cMes+=  SubStr(oModelGrid:GetValue("ZAB_DESC",nI),1,3) + "/"+ SubStr(oModelGrid:GetValue("ZAB_ID",nI),3,4)
		ElseIf nI == oModelGrid:Length() 
			cMes+=  " - " + SubStr(oModelGrid:GetValue("ZAB_DESC",nI),1,3) + "/"+SubStr(oModelGrid:GetValue("ZAB_ID",nI),3,4)
		EndIf
	Next nI

	Define MsDialog oDlgPrinc Title cTitle+" "+cTitle2 From 0,0 To 600,800 Pixel 
	oGraphic := FWChartLine():New()
	oGraphic:setTitle( SubStr(cFieldValue, 5, Len(cFieldValue)) +" - "+ cMes, CONTROL_ALIGN_CENTER )
	oGraphic:init( oDlgPrinc, .t. ) 
	oGraphic:setMask( "R$ *@* " )
	oGraphic:setPicture( PesqPict("SLR","LR_VLRITEM") )
	oGraphic:setColor("Random")
	oGraphic:addSerie( SubStr(cFieldValue, 5, Len(cFieldValue)),aSerie ) 	
	oGraphic:setLegend( CONTROL_ALIGN_LEFT ) 
	oGraphic:Build()
	ACTIVATE MSDIALOG oDlgPrinc CENTERED


EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} M850LoadGrid()

Faz o carregamento de dados no grid

@param aDados, array, dados do grid (cID | cDescricao | nCusto | nPreco | [campos adicionais] )
@return aRet, array, dados no formato para load do grid
    
@author Vendas CRM
@since 20/10/2012
/*/
//-------------------------------------------------------------------- 
Function M850LoadGrid(aDados,nOrdem,nIndicador)
Local aRet   		:= {} //array com os dados do grid
Local aLinhaAux 	:= {} //(Facilitador) array auxiliar onde sera montado o vetor que representa uma linha do grid que depois sera jogada no array final (aRet)

Local nLinha		:= 0 //percorre cada registro do array aDados
Local nCampo		:= 0 //percorre cada campo do array aDados

Local nLucro		:= 0 //lucro = Preco - Custo
Local nMargem		:= 0 //Margem = Lucro / Preco
Local nMarkup		:= 0 //Markup = Lucro / Custo

Default nOrdem    :=0
Default nIndicador:=0
/*
[n] Estrutura do array aDados
[n][01] ExpC:Id
[n][02] ExpC:Descricao
[n][03] ExpN:Custo
[n][04] ExpN:Preco
[n][n] Expu: campos adicionais
......

*/	
//----------------------------------------------------------------------------------
// Monta o array para a carga de dados do grid baseado no array de dados recebido
// Calcula o lucro, margem e markup
//----------------------------------------------------------------------------------

For nLinha := 1 to Len(aDados)
	
	nLucro := aDados[nLinha][4] - aDados[nLinha][3]
	nMargem := IIF(aDados[nLinha][4] <> 0, ((nLucro / aDados[nLinha][4]) * 100), 0)
	nMarkup := IIF(aDados[nLinha][3] <> 0, ((nLucro / aDados[nLinha][3]) * 100), 0)	
	//-------------------------------------------------------------------
	// Monta a linha que vai para o array da carga. 
	// Adiciona os campos Lucro, margem e markup nas posicoes certas
	//-------------------------------------------------------------------
	aLinhaAux := {}
	For nCampo := 1 to Len(aDados[nLinha])
		//-----------------------------------------------------------------------
		//Depois de jogar o campo padrao, verifica se o indice eh um especifico
		//dos campos calculados e joga os campos calculados
		//-----------------------------------------------------------------------
				
		Aadd(aLinhaAux, aDados[nLinha][nCampo] )
		              
		If nCampo == 4
				Aadd(aLinhaAux, nLucro )
				Aadd(aLinhaAux, nMargem )
				Aadd(aLinhaAux, nMarkup )
		EndIf		
		
	Next nCampo
	
	Aadd(aRet, { nLinha,  aLinhaAux  })
	
Next nLinha

If nIndicador > 0 .AND. nOrdem >0 
	If Len(aRet)>0	
		If nOrdem == 1 //Crescente
			Do Case
				Case nIndicador == 3 //Lucro
					aRet := aSort( aRet,,, { |x,y| x[2][5] < y[2][5] } )	
				Case nIndicador == 4//Margem
					aRet := aSort( aRet,,, { |x,y| x[2][6] < y[2][6] } )	
				Case nIndicador == 5 //Markup
					aRet := aSort( aRet,,, { |x,y| x[2][7] < y[2][7] } )	
			EndCase	                             
		Else//Decrescente                           
			Do Case
				Case nIndicador == 3 //Lucro
					aRet := aSort( aRet,,, { |x,y| x[2][5] > y[2][5] } )	
				Case nIndicador == 4//Margem
					aRet := aSort( aRet,,, { |x,y| x[2][6] > y[2][6] } )	
				Case nIndicador == 5 //Markup
					aRet := aSort( aRet,,, { |x,y| x[2][7] > y[2][7] } )	
			EndCase	
		EndIf
	EndIf	
EndIf


Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} M850VldQtd()

Valida a quantidade digitada nos parametros

@param nQuant - Quantidade digitada
@return lRet
    
@author Varejo 
@since 21/08/2013
/*/
//-------------------------------------------------------------------- 
Function M850VldQtd(nQuant)

Local lRet := .T.
Default nQuant:= 25

If nQuant > 25 
	MsgInfo(STR0023,STR0024)//"A quantidade informada é superior ao permitido.","Atenção"
	lRet:= .F.
EndIf

Return lRet
 

//-------------------------------------------------------------------
/*/{Protheus.doc} M850VldQtd()

Efetua a impressão dos dados apresentados na tela

@param oModel, oViewStruct 
@return lRet
    
@author Vendas 
@since 21/08/2013
/*/
//-------------------------------------------------------------------- 
Function M850ImpRel(oModel,oViewStruct,cTitulo)

Local oModelGrid  := oModel:GetModel("MODEL_GRID")
Local aViewFields := oViewStruct:GetFields() //array de campos da estrutura do grid na view
Local oStructModel:= oModelGrid:GetStruct()		//estrutura do model do grid
Local aCamposModel:= oStructModel:GetFields()						//array de campos da estrutura do grid no model 
  
Default cTitulo:= ''
oReport := Mt850Rel(oModelGrid,aViewFields,aCamposModel,cTitulo)
oReport:PrintDialog()	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Mt850Rel
Funcao que cria as celulas para impressao do relatorio.
@author Varejo
@since 28/05/2013
@version P11
/*/
//-------------------------------------------------------------------   
Static Function Mt850Rel(oModelGrid,aViewFields,aCamposModel,cTitulo)
	
Local cNomeRel	:= "Mt850Rel"           // Nome do relatorio
Local oReport	:= Nil                  // objeto treport
Local oSection0	:= Nil                  //Section0 0
Local oSection1 := Nil                  //Section0 1
Local aImp      := Array(Len(aViewFields))//array de impressao
Local aTotais   := Array(Len(aViewFields))      //Variavel para impressao
Local nI:=1                                      //contador
Local nImp := 1	                                 //controle de impressao
Local nScan:=1                                  // variavel de busca
//Cria objeto TReport	
oReport := TReport():New(cNomeRel,cTitulo,"",;
		  {|oReport| Mt850Imp(oReport,oModelGrid,aViewFields,aCamposModel,;
		                      @aImp,@aTotais,@nImp)},; // Efetua a extracao dos dados
		   				      cTitulo)

oReport:lParamReadOnly:= .F.
oReport:SetTotalInLine(.F.)
oReport:SetLandscape(.T.)

//Cria Secao 000
oSection0:= TRSection():New(oReport,FunName()+'-000',{},{})
oSection0:SetTotalInLine(.F.)                                                                                               

//Cria Secao 001
oSection1:= TRSection():New(oReport,FunName()+'-001',{},{})
oSection1:SetTotalInLine(.F.)
For nI:=1 To Len(aViewFields)  

	If aViewFields[nI][6] == "N"
		aImp[nI]:= 0
		aTotais[nI]:=0
	Else
		aImp[nI]:= ""
		aTotais[nI]:=""			
	EndIf
	nImp:=nI
	nScan:=aScan(aCamposModel,{|x| x[3] == aViewFields[nI][1]})
	TRCell():New(oSection0,aViewFields[nI][1]+"A","", aViewFields[nI][3],StrTran(aViewFields[nI][7],"%",""),aCamposModel[nScan][5]+15 )
	If nI > 1	
		TRCell():New(oSection1,aViewFields[nI][1]+"B","",Space(aCamposModel[nScan][5]) ,StrTran(aViewFields[nI][7],"%",""),aCamposModel[nScan][5]+15 )
	Else
		TRCell():New(oSection1,aViewFields[nI][1]+"B","",STR0025,StrTran(aViewFields[nI][7],"%",""),aCamposModel[nScan][5]+15)//"Total"	
	EndIf	
	If aViewFields[nI][6] == "N"
		oSection0:Cell(aViewFields[nI][1]+"A"):SetAlign("CENTER")	
		oSection1:Cell(aViewFields[nI][1]+"B"):SetAlign("CENTER")			
	EndIf
Next nI


Return(oReport)


//-------------------------------------------------------------------
/*/{Protheus.doc} Mt850Imp
Efetua a impressão do relatório

@author Varejo
@since 28/05/2013
@version P11
/*/
//-------------------------------------------------------------------   
Static Function Mt850Imp(oReport,oModelGrid,aViewFields,aCamposModel,aImp,aTotais,nImp)

Local nI       := 1                       //contador
Local nY      := 1                        //contador
Local oSection0		:= oReport:Section(1)// Section
Local oSection1		:= oReport:Section(2)// Section

Local nPosLucro:= aScan(aViewFields,{|x| x[1] == "ZAB_LUCRO"})   // Posicao do lucro
Local nPosPreco:= aScan(aViewFields,{|x| x[1] == "ZAB_PRECO"})	  // Posicao do preco
Local nPosCusto:= aScan(aViewFields,{|x| x[1] == "ZAB_CUSTO"})   // Posicao do custo
Local nScan:=1  // variavel de busca


oSection0:Init()      
For nI := 1 To oModelGrid:Length()      
	oModelGrid:GoLine(nI)
	For nY:= 1 To Len(aViewFields)
		oSection0:Cell(aViewFields[nY][1]+"A"):SetValue(oModelGrid:GetValue(aViewFields[nY][1]))
		If aViewFields[nY][6] == "N"
			aTotais[nY]+= oModelGrid:GetValue(aViewFields[nY][1])
		EndIf		
	Next nY
	oSection0:PrintLine()		
Next nI
  

oReport:SkipLine()
oSection1:Init()
                                                        
For nY:= 1 To Len(aViewFields)
	nScan:=aScan(aCamposModel,{|x| x[3] == aViewFields[nY][1]})
	If aViewFields[nY][6] == "N"
		If aViewFields[nY][1] == "ZAB_MARGEM"
			oSection1:Cell(aViewFields[nY][1]+"B"):SetValue( (aTotais[nPosLucro]/aTotais[nPosPreco])*100 )	
		ElseIf aViewFields[nY][1] == "ZAB_MARKUP" 	
			oSection1:Cell(aViewFields[nY][1]+"B"):SetValue( (aTotais[nPosLucro]/aTotais[nPosCusto])*100)	
		Else 
			oSection1:Cell(aViewFields[nY][1]+"B"):SetValue(aTotais[nY])			
		EndIf	
	Else
		oSection1:Cell(aViewFields[nY][1]+"B"):SetValue(Space( aCamposModel[nScan][5] ))
	EndIf	
Next nY
oSection1:PrintLine()
oSection0:Finish()	
oSection1:Finish()	

Return
