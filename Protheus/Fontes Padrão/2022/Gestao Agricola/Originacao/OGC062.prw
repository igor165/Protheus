#INCLUDE "OGC062.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/** {Protheus.doc} OGC062
Consulta - Painel de Saldos de Notas de Remessa
@param:     Nil
@return:    nil
@author:    Vanilda.moggio
@since:     02/035/20198
@Uso:       SIGAAGR - Originação de Grãos
*/
Function OGC062( cFiltroDef, aQtNfPv )
	Local oBrowse
	
	Default cFiltroDef := ''
	Private cFiltro   := cFiltroDef
	Private aQtdsNfPv := aQtNfPv
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("N9A")							// Alias da tabela utilizada
	oBrowse:SetMenuDef("OGC062")				    // Nome do fonte onde esta a função MenuDef
	oBrowse:SetFilterDefault( cFiltroDef )
	oBrowse:SetDescription(STR0001)	// Descrição do browse 
	oBrowse:SetOnlyFields( {"N9A_FILORG","N9A_CODCTR","N9A_CTREXT","N9A_ITEM","N9A_SEQPRI","N9A_NOMENT","N9A_DATINI","N9A_DATFIM","N9A_QTDNF","N9A_CODPRO","N9A_DESPRO","N9A_VLUDPR","N9A_TIPMER","N9A_OPEFIS","N9A_VLUDES","N9A_VLT2MO","N9A_VLR2MO","N9A_UNIPRO","N9A_MOEDA","N9A_VLRTAX","N9A_TAKEUP", "N9A_VLTFPR","N9A_VLUFPR","N9A_VTOTNF", "N9A_QTNFPV"} )
	
	oBrowse:SetAttach( .T. ) //visualizações 
	oBrowse:Activate()                                       
Return(Nil)

/** {Protheus.doc} MenuDef
Funcao que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
*/
Static Function MenuDef()
	Local aRotina := {}
	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------
	ADD OPTION aRotina TITLE STR0002   ACTION "AxPesqui"       OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003   ACTION "OGC062VIS()"    OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004   ACTION "VIEWDEF.OGC062" OPERATION 8 ACCESS 0 //"Imprimir"
	
	Return aRotina
	
/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
*/
Static Function ModelDef()
	
	Local oStruN9A := FWFormStruct( 1, "N9A" )
	Local oModel
	
	oModel :=  MPFormModel():New( "OGC062", /*<bPre >*/ , /*bPost*/ , /*bCommit*/, /*bCancel*/ )
	
	oModel:AddFields("OGC062_N9A", Nil, oStruN9A ,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"N9A_FILIAL","N9A_CODCTR","N9A_ITEM","N9A_SEQPRI"})
Return oModel

/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
*/
Static Function ViewDef()
	Local oModel := FWLoadModel("OGC062")
	Local oView  := Nil
	Local oStructN9A := FWFormStruct(2,"N9A")

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "OGC062_N9A" , oStructN9A, /*cLinkID*/ )	//
	oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:SetOwnerView( "OGC062_N9A" , "MASTER" )
	       
Return oView

/*/{Protheus.doc} OGC062VIS
//TODO Descrição auto-gerada.
@author vanilda.moggio
@since 10/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OGC062VIS()
 	Local aAreaNJ0   := NJ0->(GetArea())
	Local aAreaNJR   := NJR->(GetArea())
	Local cCodClient := ""
	Local cCodLoja   := ""
	Local cCtrNeg    := ''
	Local cCtrVer    := ''
	Local cCtrUmp    := ''
	Local nCtrDia    := 0
	Local nCtrMor    := 0
	Local cCtrUnM    := ''
	
	//busca as informações de Cliente - verifciar se não vai ser da NNY ou N9A
	DbSelectArea("NJ0")
	DbSetOrder(1)
	If DbSeek(xFilial("NJ0")+N9A->(N9A_CODENT)+N9A->(N9A_LOJENT))
	   cCodClient     := NJ0->(NJ0_CODCLI)
	   cCodLoja       := NJ0->(NJ0_LOJCLI)		
	EndIf	
    
    //busca as informações de Cliente - verifciar se não vai ser da NNY ou N9A
	DbSelectArea("NJR")
	DbSetOrder(1)
	If DbSeek(xFilial("NJR")+N9A->(N9A_CODCTRC))
	   cCtrVer := NJR->(NJR_VERSAO)
	   cCtrMor := NJR->(NJR_MOEDAR)
	   cCtrDia := NJR->(NJR_DIASR)
	   cCtrUmp := NJR->(NJR_UMPRC)  	 
	   cCtrNeg := NJR->(NJR_CODNGC)  
	   cCtrUnM := NJR->(NJR_UM1PRO)
	EndIf	
    
    MsgRun("Processando...","Cálculo de Preços", {|| ;
    OGX055SIMU("R",  ;
           N9A->(N9A_FILIAL), ;
           N9A->(N9A_CODCTR), ;
           N9A->(N9A_ITEM), ;
           N9A->(N9A_SEQPRI), ;
           1, ;
           N9A->(N9A_TES) , ;
           N9A->(N9A_NATURE), ;
           N9A->(N9A_TIPCLI) , ;
           cCodClient, ;
           cCodLoja, ;
           N9A->(N9A_FILORG) , ;
           cCtrNeg, ;
           cCtrVer, ;
           N9A->(N9A_TIPMER), ;
           nCtrMor, ;
           nCtrDia,  ;
           cCtrUmp, ;
           cCtrUnM,  ;
           N9A->(N9A_CODPRO), ;
           N9A->(N9A_MOEDA),  ;
           N9A->(N9A_DATINI) ,;
           N9A->(N9A_DATFIM) );								
           })			

	RestArea(aAreaNJR)	
	RestArea(aAreaNJ0)	

Return  .T.

/*/{Protheus.doc} OGC062QNFP
Carga dinamica do campo N9A_QTNFPV
@type  Function
@author rafael.kleestadt / vanilda.moggio
@since 22/03/2019
@version 1.0
@param param, param_type, param_descr
@return nQtd, numeric, conteudo a ser carregado no campo
@example
(examples)
@see (links_or_references)
/*/
Function OGC062QNFP()
	Local nQtd := 0
	local nPos := 0

	If Empty(aQtdsNfPv)
		nQtd := N9A->N9A_SDONF
	Else
		//Buscar no array a regra fiscal posicionada e retornar a qtd no nQtd
		nPos := AScan(aQtdsNfPv, {|x| AllTrim(x[1]) == AllTrim(N9A->(N9A_FILIAL+N9A_CODCTR+N9A_ITEM+N9A_SEQPRI))})
		If nPos > 0
			If Month(aQtdsNfPv[nPos,3]) = Month(dDatabase)
				nQtd := N9A->N9A_SDONF + aQtdsNfPv[nPos,2]
			Else
				nQtd := aQtdsNfPv[nPos,2]
			EndIf
		Else
			nQtd := N9A->N9A_SDONF
		EndIf
	EndIf

Return nQtd