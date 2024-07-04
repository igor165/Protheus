#INCLUDE "protheus.ch"
#INCLUDE "AGRA610.CH"
#include "fwmvcdef.ch"
#INCLUDE "APWIZARD.CH"

Static cDXL_OP     := Space(TamSX3("D3_OP")[01])
Static cDXL_UNB    := Space(TamSX3("DX3_CODIGO")[01])
Static cDXL_PRDTOR := Space(TamSX3("NJ0_CODENT")[01])
Static cDXL_LJPRO  := Space(TamSX3("DXL_LJPRO")[01])
Static oAliasNF    := Nil
Static oAliasDoc   := Nil
Static oArqTemp    := Nil
Static oPnCompl    := Nil

Static __oMarkDXL 
Static __oMarkDXB
Static __oMarkDOC
Static __aStrutNF 
Static __aHeaderNF 
Static __cAliasNF
Static __aStrutDOC 
Static __aHeaderDOC 
Static __cAliasDOC
Static oTotFisico
Static oTotFiscal

//-----------------------------------------------------------
/*/{Protheus.doc} MenuDef
Retorna o Menu padrão da rotina

@param: Nil
@author: Aecio Ferreira Gomes
@since: 08/11/2012
@Uso: AGRA601
/*/
//-----------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title STR0052 /*"Compl.Físico"*/ Action 'StaticCall(AGRA610,ComplFisico)' OPERATION 1  ACCESS 0  DISABLE MENU
	ADD OPTION aRotina Title STR0053 /*"Compl.Fiscal"*/ Action 'StaticCall(AGRA610,ComplFiscal)' OPERATION 2  ACCESS 0  DISABLE MENU

Return aRotina

/*/{Protheus.doc} AGRA610
//Rotina de geração de complementos para os fardões
@author bruna.rocio
@since 05/07/2016
@version undefined

@type function
/*/
Function AGRA610()
	Local oSize     := Nil
	Local oSZ       := Nil
	Local oDlg		:= Nil
	Local oPnCabec  := Nil
	Local oPnResto  := Nil
	Local aCampos
	Local nX

	Local oTFolder
	Local oBtFilter

	Private _nTotFisico := 0	
	Private _nTotFiscal := 0


	__aHeaderNF := {{ STR0029 , "DXB_EMISSA", "D", TamSX3("DXB_EMISSA")[1], 0,     },; //"Emissão" 
	{ STR0030 , "DXB_DOCNF" , "C", TamSX3("DXB_DOCNF")[1] , 0, "@!"},; //"Nota Fiscal"
	{ STR0031 , "DXB_QUANT" , "N", TamSX3("DXL_PSLIQU")[1], TamSX3("DXL_PSLIQU")[2], PesqPict("DXL","DXL_PSLIQU") },; //"Quantidade"
	{ STR0032 , "DXB_SERIE" , "C", TamSX3("DXB_SERIE")[1],  0, "@!"},; //Série
	{ STR0033 , "DXB_CLIENT", "C", TamSX3("DXB_PRDTOR")[1], 0, "@!"},; //Cliente
	{ STR0034 , "DXB_NOMCLT", "C", TamSX3("A1_NOME")[1]   , 0, "@!"},; //Nome Cliente
	{ STR0035 , "DXB_LJCLI" , "C", TamSX3("DXB_LJPRO")[1] , 0, "@!"},; //Loja Cliente
	{ STR0036 , "DXB_SAFRA" , "C", TamSX3("DXB_SAFRA")[1],  0, "@!"},; //Safra
	{ STR0037 , "DXB_NUMPED", "C", TamSX3("DXB_NUMPED")[1], 0, "@!"}}  //Pedido

	__aHeaderDOC := {{ STR0029    , "DXB_EMISSA", "D", TamSX3("DXB_EMISSA")[1], 0, },; //Emissão
	{ STR0054 , "DXB_DOC"   , "C", TamSX3("DXB_DOC")[1]   , 0, "@!"},;    //"Documento"
	{ STR0031  , "DXB_QUANT" , "N", TamSX3("DXL_PSLIQU")[1], TamSX3("DXL_PSLIQU")[2], PesqPict("DXL","DXL_PSLIQU") },;
	{ STR0055  , "DXB_NUMSEQ", "C", TamSX3("DXB_NUMSEQ")[1], 0, "@!"},;     //"Num.Seq"
	{ STR0056  , "DXB_OP"    , "C", TamSX3("DXB_OP")[1]    , 0, "@!"},;     //"Ord.Prod"
	{ STR0074  , "DXB_FARDAO", "C", TamSX3("DXB_FARDAO")[1], 0, "@!"},;     //Fardão
	{ STR0057  , "DXB_PRDTOR", "C", TamSX3("DXB_PRDTOR")[1], 0, "@!"},;     //Produtor
	{ STR0058  , "DXB_NMPDTR", "C", TamSX3("A1_NOME")[1]   , 0, "@!"},; //"Nome"
	{ STR0059  , "DXB_LJPRO" , "C", TamSX3("DXB_LJPRO")[1] , 0, "@!"},; //"Loja"
	{ STR0036  , "DXB_SAFRA" , "C", TamSX3("DXB_SAFRA")[1] , 0, "@!"},;  //Safra
	{ STR0060  , "DXB_CODPRO", "C", TamSX3("DXB_CODPRO")[1], 0, "@!"},;    //"Produto"
	{ STR0061  , "DXB_DESPRO", "C", TamSX3("B1_DESC")[1]   , 0, "@!"}}	    //"Descrição"			


	__aStrutNF := {{"OK"        , "C", 1, 0  },;
	{"DXB_FILIAL", "C", TamSX3("DXB_FILIAL")[1], 0},;
	{"DXB_EMISSA", "D", TamSX3("DXB_EMISSA")[1], 0},;
	{"DXB_QUANT" , "N", TamSX3("DXL_PSLIQU")[1], TamSX3("DXL_PSLIQU")[2]},;
	{"DXB_DOCNF" , "C", TamSX3("DXB_DOCNF")[1],  0},; 
	{"DXB_SERIE" , "C", TamSX3("DXB_SERIE")[1],  0},;
	{"DXB_CLIENT", "C", TamSX3("DXB_PRDTOR")[1], 0},;
	{"DXB_NOMCLT", "C", TamSX3("A1_NOME")[1],    0},;
	{"DXB_LJCLI" , "C", TamSX3("DXB_LJPRO")[1],  0},;
	{"DXB_SAFRA" , "C", TamSX3("DXB_SAFRA")[1],  0},;
	{"DXB_NUMPED", "C", TamSX3("DXB_NUMPED")[1], 0},;
	{"RECNO"     , "N", 8, 0}}	

	__aStrutDOC := {{"OK"        , "C", 1, 0  },;
	{"DXB_FILIAL", "C", TamSX3("DXB_FILIAL")[1], 0},;
	{"DXB_EMISSA", "D", TamSX3("DXB_EMISSA")[1], 0},;
	{"DXB_QUANT" , "N", TamSX3("DXL_PSLIQU")[1], TamSX3("DXL_PSLIQU")[2]},;
	{"DXB_DOC"   , "C", TamSX3("DXB_DOC")[1]   , 0},; 
	{"DXB_NUMSEQ", "C", TamSX3("DXB_NUMSEQ")[1], 0},;
	{"DXB_OP"    , "C", TamSX3("DXB_OP")[1]    , 0},;
	{"DXB_FARDAO", "C", TamSX3("DXB_FARDAO")[1], 0},;
	{"DXB_PRDTOR", "C", TamSX3("DXB_PRDTOR")[1], 0},;
	{"DXB_NMPDTR", "C", TamSX3("A1_NOME")[1]   , 0},;
	{"DXB_LJPRO" , "C", TamSX3("DXB_LJPRO")[1] , 0},;
	{"DXB_SAFRA" , "C", TamSX3("DXB_SAFRA")[1] , 0},;
	{"DXB_CODPRO", "C", TamSX3("DXB_CODPRO")[1], 0},;
	{"DXB_DESPRO", "C", TamSX3("B1_DESC")[1], 0},;
	{"RECNO"     , "N", 8, 0}}				

	aCampos := {'DXL_CODIGO', 'DXL_SAFRA', 'DXL_CODPRO', 'DXL_PRDTOR', 'DXL_LJPRO', 'DXL_NMPDTR', 'DXL_FAZ',;
	'DXL_TALHAO', 'DXL_CODVAR', 'DXL_LOCAL', 'DXL_PSESTI', 'DXL_PSLIQU','DXL_DIFCOMP','DXL_DIFFIS', 'DXL_CODROM', 'DXL_STATUS', 'DXL_CODUNB'}			 

	//Cria tabela temporaria de notas fiscais de saída
	__cAliasNF := GetNextAlias() 
	oAliasNF   := AGRCRTPTB(__cAliasNF, {__aStrutNF, {{"", "DXB_FILIAL,DXB_DOCNF,DXB_SERIE" }} })

	//Cria tabela temporaria de movimentos internos
	__cAliasDOC := GetNextAlias() 
	oAliasDOC   := AGRCRTPTB(__cAliasDOC, {__aStrutDOC, {{"", "DXB_FILIAL,DXB_DOC,DXB_NUMSEQ" }} })

	//Função responsável pela busca das notas e docs a serem estornados
	AGRFilNota()	 

	//Cria objeto para buscar o tamanho da resolução do monitor
	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ALL", 100, 100, .T., .T. )    
	oSize:lLateral	:= .T.  // Calculo vertical	
	oSize:Process() //executa os calculos

	//Montagem da Tela
	oDlg := TDialog():New( oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3], oSize:aWindSize[4], STR0016, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) 

	//Divide tela em objetos distintos
	oSZ := FwDefSize():New()             
	oSZ:AddObject( "CABECALHO",  100, 10, .T., .T. ) // Totalmente dimensionavel
	oSZ:AddObject( "RODAPE"   ,  100, 80, .T., .T. ) // Totalmente dimensionavel
	oSZ:AddObject( "RESTO"    ,  100, 10, .T., .T. ) // Totalmente dimensionavel         

	oSZ:lProp 	 := .T. // Proporcional             
	oSZ:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

	oSZ:Process() // Dispara os calculos   

	//Cria os paneis que receberão as informações de cabeçalho, grids e totalizador de complemento
	oPnCabec := TPanel():New( oSZ:GetDimension("CABECALHO","LININI"), oSZ:GetDimension("CABECALHO","COLINI"), ,oDlg, , , , , ,oSZ:GetDimension("CABECALHO","COLEND"), oSZ:GetDimension("CABECALHO","LINEND"))			
	oPnCompl := TPanel():New( oSZ:GetDimension("RODAPE","LININI")   , oSZ:GetDimension("RODAPE","COLINI")   , ,oDlg, , , , , ,oSZ:GetDimension("RODAPE","COLEND")   , oSZ:GetDimension("RODAPE","LINEND")/1.3)	
	oPnResto := TPanel():New( oSZ:GetDimension("RESTO","LININI")    , oSZ:GetDimension("RESTO","COLINI")    , ,oDlg, , , , , ,oSZ:GetDimension("RESTO","COLEND")    , oSZ:GetDimension("RESTO","LINEND"))

	//Cria folder para receber as grids
	oTFolder := TFolder():New(0,0,{STR0017/*'Complemento'*/,STR0062/*'Estorno Fiscal'*/,STR0063/*'Estorno Físico'*/},,oPnCompl,,,,.T.,,(oPnCompl:nClientWidth/2),(oPnCompl:nClientHeight/2)) 

	/************************************************************************************/
	/*                            Criação dos dados de cabeçalho                        */
	/************************************************************************************/

	@ 007,005  Say STR0057/*'Entidade'*/ Of oPnCabec COLOR CLR_BLACK Pixel 
	@ 015,005 MSGET oDXL_PRDTOR Var cDXL_PRDTOR  Size 70,09  Picture X3Picture("NJ0_CODENT") F3 "NJ0"  Of oPnCabec  Pixel HasButton When .T.
	@ 007,075  Say STR0059/*'Loja'*/ Of oPnCabec COLOR CLR_BLACK Pixel
	@ 015,075 MSGET oDXL_LJPRO  Var cDXL_LJPRO   Size 20,09  Picture X3Picture("DXL_LJPRO") Valid ExistCpo('NJ0',cDXL_PRDTOR+cDXL_LJPRO)  Of oPnCabec  Pixel When .T.

	@ 007,100 Say STR0019 Of oPnCabec COLOR CLR_BLACK Pixel 
	@ 015,100 MSGET oDXL_UNB  Var cDXL_UNB  Size 30,09  Picture X3Picture("DX3_CODIGO") F3 "DX3"  Of oPnCabec  Pixel HasButton When .T.

	@ 015,130 Button oBtFilter Prompt STR0020/*"&Filtrar"*/  Size 32, 12 Pixel Action ( Filtra( oTFolder:nOption ) )  Of oPnCabec

	@ 007,180  Say STR0064  Of oPnCabec COLOR CLR_BLACK Pixel //"Ordem de produção: "
	@ 015,180 MSGET oDXL_OP  Var cDXL_OP     Size 100,09  Picture X3Picture("D3_OP") F3 "SC2"  Of oPnCabec  Pixel When !ExistBlock('AG610OPR') Pixel hasbutton

	@ 7,320  Say STR0065  Of oPnResto COLOR CLR_BLACK Pixel //"Tot.Compl.Fis"
	@ 5,355 MSGET oTotFisico  Var _nTotFisico  Size 100,09  Picture X3Picture("DXL_PSLIQU")  Of oPnResto  Pixel When .f. 

	@ 7,465  Say STR0066  Of oPnResto COLOR CLR_BLACK Pixel //"Tot.Compl.Fisc"
	@ 5,505 MSGET oTotFiscal  Var _nTotFiscal  Size 100,09  Picture X3Picture("DXL_PSFISC")  Of oPnResto  Pixel When .f.

	/************************************************************************************/
	/*     Criação de grid para apresentação dos fardões a serem complementados         */
	/************************************************************************************/ 

	__oMarkDXL:=FWMarkBrowse():NEW()   // Cria o objeto oMark - MarkBrowse
	__oMarkDXL:SetDescription(STR0016) // Define o titulo do MarkBrowse
	__oMarkDXL:SetFilterDefault("@"+FilterMark(Nil,Nil,Nil))
	__oMarkDXL:SetColumns(addCampoGrid())
	__oMarkDXL:SetOwner(oTFolder:aDialogs[1])
	__oMarkDXL:SetAlias("DXL") 	
	__oMarkDXL:SetFieldMark("DXL_OK")	// Define o campo utilizado para a marcacao
	__oMarkDXL:SetCustomMarkRec({ || A610CHK(oTotFisico, oTotFiscal) })	
	__oMarkDXL:SetOnlyFields(aCampos)	
	__oMarkDXL:SetSemaphore(.F.)	// Define se utiliza marcacao exclusiva
	__oMarkDXL:DisableDetails()	    // Desabilita a exibicao dos detalhes do MarkBrowse
	__oMarkDXL:Activate()	        // Ativa o MarkBrowse

	/************************************************************************************/
	/*     Criação de grid para apresentação das notas de saída a serem estornadas      */
	/************************************************************************************/

	__oMarkDXB:=FWMarkBrowse():NEW()   // Cria o objeto oMark - MarkBrowse
	__oMarkDXB:SetDescription(STR0038) // Define o titulo do MarkBrowse
	__oMarkDXB:SetTemporary(.t.)
	__oMarkDXB:SetAlias(__cAliasNF)
	__oMarkDXB:SetUseFilter(.T.)
	__oMarkDXB:SetdbFFilter(.T.)

	For nx := 1 to Len(__aHeaderNF)
		ADD COLUMN oColumn DATA &('{||'+__aHeaderNF[nX,2]+'}') Type __aHeaderNF[nX,3] Title __aHeaderNF[nX,1] SIZE __aHeaderNF[nX,4] DECIMAL  __aHeaderNF[nX,5] PICTURE __aHeaderNF[nX,6] Of __oMarkDXB		
	Next nX

	__oMarkDXB:SetFieldMark("OK")	// Define o campo utilizado para a marcacao	
	__oMarkDXB:SetOwner(oTFolder:aDialogs[2])
	__oMarkDXB:SetSemaphore(.F.)	// Define se utiliza marcacao exclusiva
	__oMarkDXB:DisableDetails()	// Desabilita a exibicao dos detalhes do MarkBrowse
	__oMarkDXB:AddButton(STR0068/*'&Estornar'*/,{|| NotaEstorno()})
	__oMarkDXB:SetMenuDef('')
	__oMarkDXB:Activate()	// Ativa o MarkBrowse

	/************************************************************************************/
	/*        Criação de grid para apresentação dos movimentos a serem estornados       */
	/************************************************************************************/

	__oMarkDoc:=FWMarkBrowse():NEW()   // Cria o objeto oMark - MarkBrowse
	__oMarkDoc:SetDescription(STR0067) // Define o titulo do MarkBrowse
	__oMarkDoc:SetTemporary(.t.)
	__oMarkDoc:SetAlias(__cAliasDOC)
	__oMarkDoc:SetUseFilter(.T.)
	__oMarkDoc:SetdbFFilter(.T.)

	For nx := 1 to Len(__aHeaderDOC)
		ADD COLUMN oColumn DATA &('{||'+__aHeaderDOC[nX,2]+'}') Type __aHeaderDOC[nX,3] Title __aHeaderDOC[nX,1] SIZE __aHeaderDOC[nX,4] DECIMAL  __aHeaderDOC[nX,5] PICTURE __aHeaderDOC[nX,6] Of __oMarkDoc		
	Next nX

	__oMarkDoc:SetFieldMark("OK")	// Define o campo utilizado para a marcacao	
	__oMarkDoc:SetOwner(oTFolder:aDialogs[3])
	__oMarkDoc:SetSemaphore(.F.)	// Define se utiliza marcacao exclusiva
	__oMarkDoc:DisableDetails()	// Desabilita a exibicao dos detalhes do MarkBrowse
	__oMarkDoc:AddButton(STR0068/*'&Estornar'*/,{|| DocEstorno()})
	__oMarkDoc:SetMenuDef('')
	__oMarkDoc:Activate()	// Ativa o MarkBrowse

	oDlg:Activate( , , , .t., { || .t. }, , { || EnchoiceBar(oDlg,{|| oDlg:End()},{||oDlg:End()},,) } )

	//Elimina a tabela temporária, se houver
	AGRDLTPTB(oArqTemp)
	AGRDLTPTB(oAliasNF)    
Return ()


/*/{Protheus.doc} A610CHK
//Função para marcação e desmarcação
@author bruna.rocio
@since 04/08/2016
@version undefined
@param oTotFisico, object, descricao
@type function
/*/
Static Function A610CHK(oTotFisico, oTotFiscal)
	Local lMark  := !__oMarkDXL:IsMark(__oMarkDXL:Mark())
	Local nRecno

	dbSelectArea('DXL')
	RecLock('DXL',.F.)
	DXL->DXL_OK := IIf(lMark, __oMarkDXL:Mark(), "  ")
	nRecno := DXL->(Recno())
	DXL->(MsUnLock())

	UpCount(oTotFisico, oTotFiscal)
	__oMarkDXL:Refresh()	
Return .T.

/*/{Protheus.doc} upCount
//Função para atualizar contador
@author bruna.rocio
@since 04/08/2016
@version undefined
@param oTotFisico, object, descricao
@type function
/*/
Static Function upCount(oTotFisico, oTotFiscal)
	Local aArea     := GetArea()
	Local nSoma     := 0
	Local nSomaFisc := 0

	DXL->(dbGoTop())
	While .Not. DXL->( Eof() )

		If __oMarkDXL:IsMark()
			nSoma     += Iif( DXL->DXL_PSLIQU > 0 .And. HasComplemento(DXL->DXL_SAFRA, DXL->DXL_CODIGO, 'COMPLFSC'), (DXL->DXL_PSLIQU - DXL->DXL_PSESTI), 0 )
			nSomaFisc += Iif( DXL->DXL_PSFISC > 0 .And. HasComplemento(DXL->DXL_SAFRA, DXL->DXL_CODIGO, 'COMPLFCL'), (DXL->DXL_PSFISC - DXL->DXL_PSESTI), 0 )

		EndIf
		DXL->(dbSkip())
	EndDo

	_nTotFisico := nSoma
	_nTotFiscal := nSomaFisc
	oTotFisico:Refresh()
	oTotFiscal:Refresh()
	RestArea(aArea)
Return .T.


/*/{Protheus.doc} AGRFilNota
//Filtro para criação/atualização da tabela temporaria de notas
@author bruna.rocio
@since 01/08/2016
@version undefined
@type function
/*/
Static Function AGRFilNota() 
	Local aArea    := GetArea()
	Local cAliNota := GetNextAlias()
	Local cAliOP   := GetNextAlias()

	fZapTRB( __cAliasNF )
	fZapTRB( __cAliasDoc )

	/****************************************************************/
	/*      Busca informações das notas a serem estornadas          */
	/****************************************************************/

	BeginSql Alias cAliNota
		Select '' AS OK, DXB_FILIAL, DXB_EMISSA, DXB_DOCNF,
		DXB_SERIE, DXB_SAFRA, DXB_NUMPED,
		SUM(DXB_QUANT) AS DXB_QUANT FROM  %Table:DXB% DXB
		WHERE DXB.%notDel%
		AND  DXB.DXB_FILIAL = %xFilial:DXB%
		AND (DXB.DXB_ROTINA = 'AGRA610'
		OR DXB.DXB_ROTINA = 'COMPLFSC'
		OR DXB.DXB_ROTINA = 'COMPLFCL')
		AND DXB.DXB_DOCNF <> ''
		GROUP BY DXB_FILIAL, DXB_EMISSA, DXB.DXB_DOCNF, DXB.DXB_SERIE, DXB_SAFRA, DXB_NUMPED        
	EndSql

	DbselectArea( cAliNota )
	DbGoTop()
	While ( cAliNota )->( !Eof() )

		RecLock(__cAliasNF, .T.)
		(__cAliasNF)->DXB_FILIAL := (cAliNota)->DXB_FILIAL
		(__cAliasNF)->DXB_EMISSA := StoD((cAliNota)->DXB_EMISSA)
		(__cAliasNF)->DXB_DOCNF  := (cAliNota)->DXB_DOCNF
		(__cAliasNF)->DXB_SERIE  := (cAliNota)->DXB_SERIE
		(__cAliasNF)->DXB_CLIENT := Posicione("SC5", 1,fwxFilial('SC5')+(cAliNota)->DXB_NUMPED,"C5_CLIENTE")
		(__cAliasNF)->DXB_LJCLI  := Posicione("SC5", 1,fwxFilial('SC5')+(cAliNota)->DXB_NUMPED,"C5_LOJACLI")
		(__cAliasNF)->DXB_NOMCLT := Posicione("SA1", 1,fwxFilial('SA1')+(__cAliasNF)->DXB_CLIENT+(__cAliasNF)->DXB_LJCLI,"A1_NOME")
		(__cAliasNF)->DXB_SAFRA  := (cAliNota)->DXB_SAFRA
		(__cAliasNF)->DXB_NUMPED := (cAliNota)->DXB_NUMPED
		(__cAliasNF)->DXB_QUANT  := (cAliNota)->DXB_QUANT		
		(__cAliasNF)->(MsUnlock())

		(cAliNota)->(dbSkip())
	EndDo

	/****************************************************************/
	/*      Busca informações dos documentos a serem estornados     */
	/****************************************************************/

	BeginSql Alias cAliOP
		Select '' AS OK, DXB_FILIAL, DXB_EMISSA, DXB_OP, DXB_DOC, DXB_NUMSEQ,
		DXB_PRDTOR, DXB_LJPRO, DXB_SAFRA, DXB_FARDAO, DXB_CODPRO, SUM(DXB_QUANT) AS DXB_QUANT FROM  %Table:DXB% DXB
		WHERE DXB.%notDel%
		AND  DXB.DXB_FILIAL = %xFilial:DXB%
		AND (DXB.DXB_ROTINA = 'AGRA610'
		OR DXB.DXB_ROTINA = 'COMPLFSC'
		OR DXB.DXB_ROTINA = 'COMPLFCL')
		AND DXB.DXB_OP <> ''     
		GROUP BY DXB_FILIAL, DXB_EMISSA, DXB_OP, DXB_DOC, DXB_NUMSEQ, DXB_PRDTOR, DXB_LJPRO, DXB_SAFRA, DXB_FARDAO, DXB_CODPRO    	
	EndSql

	DbselectArea( cAliOP )
	DbGoTop()
	While ( cAliOP )->( !Eof() )
		RecLock(__cAliasDoc, .T.)
		(__cAliasDoc)->DXB_FILIAL := (cAliOP)->DXB_FILIAL
		(__cAliasDoc)->DXB_EMISSA := StoD((cAliOP)->DXB_EMISSA)
		(__cAliasDoc)->DXB_PRDTOR := (cAliOP)->DXB_PRDTOR
		(__cAliasDoc)->DXB_LJPRO  := (cAliOP)->DXB_LJPRO
		(__cAliasDoc)->DXB_NMPDTR := Posicione("SA1", 1,fwxFilial('SA1')+(cAliOP)->DXB_PRDTOR+(cAliOP)->DXB_LJPRO,"A1_NOME")
		(__cAliasDoc)->DXB_DOC    := (cAliOP)->DXB_DOC
		(__cAliasDoc)->DXB_OP     := (cAliOP)->DXB_OP
		(__cAliasDoc)->DXB_FARDAO := (cAliOP)->DXB_FARDAO
		(__cAliasDoc)->DXB_NUMSEQ := (cAliOP)->DXB_NUMSEQ
		(__cAliasDoc)->DXB_SAFRA  := (cAliOP)->DXB_SAFRA
		(__cAliasDoc)->DXB_CODPRO := (cAliOP)->DXB_CODPRO
		(__cAliasDoc)->DXB_DESPRO := Posicione("SB1", 1,fwxFilial('SB1')+(cAliOP)->DXB_CODPRO,"B1_DESC")
		(__cAliasDoc)->DXB_QUANT  := (cAliOP)->DXB_QUANT		
		(__cAliasDoc)->(MsUnlock())

		(cAliOP)->(dbSkip())
	EndDo

	RestArea(aArea)
Return 


/*/{Protheus.doc} fZapTRB
//Limpa tabela temporária
@author bruna.rocio
@since 01/08/2016
@version undefined
@param pcAliasTRB, , descricao
@type function
/*/
Static Function fZapTRB( pcAliasTRB )
	Local aAreaAtu	 	:= GetArea()

	If Select( pcAliasTRB ) > 0
		DbSelectArea( pcAliasTRB )
		Zap
	Endif

	RestArea( aAreaAtu )
Return( NIL )


/*/{Protheus.doc} FilterMark
//Monta filtro para o mark browse
@author bruna.rocio
@since 06/07/2016
@version undefined
@type function
/*/
Static Function FilterMark(cPrdtor, cLoja, cUNB)
	Local cQuery := ""

	If Empty(cPrdtor)
		If Empty(cUNB)
			cQuery := "( (DXL_PSLIQU > 0 AND DXL_PSLIQU <> DXL_PSESTI AND NOT EXISTS ( " +; 
			" Select DXB_FARDAO FROM " + RetSqlName('DXB') + " DXB1 WHERE DXB1.D_E_L_E_T_ = ' ' "+;  
			" AND DXB1.DXB_FILIAL = '" + fwxFilial('DXB') + "' AND DXB1.DXB_SAFRA = DXL_SAFRA "+;
			" AND DXB1.DXB_FARDAO = DXL_CODIGO "+; 
			" AND DXB1.DXB_ROTINA = 'COMPLFSC' )) " +;
			" OR (DXL_PSFISC > 0 AND DXL_PSFISC <> DXL_PSESTI AND NOT EXISTS ( "+;  
			" Select DXB_FARDAO FROM " + RetSqlName('DXB') + " DXB2 WHERE DXB2.D_E_L_E_T_ = ' ' "+;  
			" AND DXB2.DXB_FILIAL = '" + fwxFilial('DXB') + "' AND DXB2.DXB_SAFRA = DXL_SAFRA "+;
			" AND DXB2.DXB_FARDAO = DXL_CODIGO "+; 
			" AND DXB2.DXB_ROTINA = 'COMPLFCL' ))) AND "+;
			" DXL_FILIAL ='" + fwxFilial('DXL') + "' AND DXL_PSESTI > 0 "
		Else
			cQuery := "( (DXL_PSLIQU > 0 AND DXL_PSLIQU <> DXL_PSESTI AND NOT EXISTS ( " +; 
			" Select DXB_FARDAO FROM " + RetSqlName('DXB') + " DXB1 WHERE DXB1.D_E_L_E_T_ = ' ' "+;  
			" AND DXB1.DXB_FILIAL = '" + fwxFilial('DXB') + "' AND DXB1.DXB_SAFRA = DXL_SAFRA "+;
			" AND DXB1.DXB_FARDAO = DXL_CODIGO "+; 
			" AND DXB1.DXB_ROTINA = 'COMPLFSC' )) " +;
			" OR (DXL_PSFISC > 0 AND DXL_PSFISC <> DXL_PSESTI AND NOT EXISTS ( "+;  
			" Select DXB_FARDAO FROM " + RetSqlName('DXB') + " DXB2 WHERE DXB2.D_E_L_E_T_ = ' ' "+;  
			" AND DXB2.DXB_FILIAL = '" + fwxFilial('DXB') + "' AND DXB2.DXB_SAFRA = DXL_SAFRA "+;
			" AND DXB2.DXB_FARDAO = DXL_CODIGO "+; 
			" AND DXB2.DXB_ROTINA = 'COMPLFCL' ))) AND "+;
			" DXL_FILIAL ='" + fwxFilial('DXL') + "' AND DXL_PSESTI > 0 "+;
			" AND DXL_CODUNB = '" + cUNB + "'"
		Endif
	Else
		If Empty(cUNB)
			cQuery := "( (DXL_PSLIQU > 0 AND DXL_PSLIQU <> DXL_PSESTI AND NOT EXISTS ( " +; 
			" Select DXB_FARDAO FROM " + RetSqlName('DXB') + " DXB1 WHERE DXB1.D_E_L_E_T_ = ' ' "+;  
			" AND DXB1.DXB_FILIAL = '" + fwxFilial('DXB') + "' AND DXB1.DXB_SAFRA = DXL_SAFRA "+;
			" AND DXB1.DXB_FARDAO = DXL_CODIGO "+; 
			" AND DXB1.DXB_ROTINA = 'COMPLFSC' )) " +;
			" OR (DXL_PSFISC > 0 AND DXL_PSFISC <> DXL_PSESTI AND NOT EXISTS ( "+;  
			" Select DXB_FARDAO FROM " + RetSqlName('DXB') + " DXB2 WHERE DXB2.D_E_L_E_T_ = ' ' "+;  
			" AND DXB2.DXB_FILIAL = '" + fwxFilial('DXB') + "' AND DXB2.DXB_SAFRA = DXL_SAFRA "+;
			" AND DXB2.DXB_FARDAO = DXL_CODIGO "+; 
			" AND DXB2.DXB_ROTINA = 'COMPLFCL' ))) AND "+;
			" DXL_FILIAL ='" + fwxFilial('DXL') + "' AND DXL_PSESTI > 0 "+;
			" AND DXL_PRDTOR = '" + cPrdtor + "' AND DXL_LJPRO = '" + cLoja + "' "
		Else
			cQuery := "( (DXL_PSLIQU > 0 AND DXL_PSLIQU <> DXL_PSESTI AND NOT EXISTS ( " +; 
			" Select DXB_FARDAO FROM " + RetSqlName('DXB') + " DXB1 WHERE DXB1.D_E_L_E_T_ = ' ' "+;  
			" AND DXB1.DXB_FILIAL = '" + fwxFilial('DXB') + "' AND DXB1.DXB_SAFRA = DXL_SAFRA "+;
			" AND DXB1.DXB_FARDAO = DXL_CODIGO "+; 
			" AND DXB1.DXB_ROTINA = 'COMPLFSC' )) " +;
			" OR (DXL_PSFISC > 0 AND DXL_PSFISC <> DXL_PSESTI AND NOT EXISTS ( "+;  
			" Select DXB_FARDAO FROM " + RetSqlName('DXB') + " DXB2 WHERE DXB2.D_E_L_E_T_ = ' ' "+;  
			" AND DXB2.DXB_FILIAL = '" + fwxFilial('DXB') + "' AND DXB2.DXB_SAFRA = DXL_SAFRA "+;
			" AND DXB2.DXB_FARDAO = DXL_CODIGO "+; 
			" AND DXB2.DXB_ROTINA = 'COMPLFCL' ))) AND "+;
			" DXL_FILIAL ='" + fwxFilial('DXL') + "' AND DXL_PSESTI > 0 "+;
			" AND DXL_PRDTOR = '" + cPrdtor + "' AND DXL_LJPRO = '" + cLoja + "' "+;
			" AND DXL_CODUNB = '" + cUNB + "'"
		Endif
	Endif

Return(cQuery) 


/*/{Protheus.doc} NotaEstorno
//Função gerada para o estorno dos complementos fisico e fiscal
@author bruna.rocio
@since 03/07/2017
@version undefined

@type function
/*/
Static Function NotaEstorno()
	Local aArea := GetArea()
	Local lRet  := .T.
	Local nX    := 0
	Local aNotas

	If !ValidCheck(.T.) //Estorno
		MsgInfo(STR0027,STR0006)//"ATENCAO"###"Nenhum registro selecionado. Por favor, selecione ao menos um registro para dar continuidade ao processo."
		lRet := .F.
	Else	
		__oMarkDXL:SetFilterDefault(Nil)

		aNotas := GetNotas()

		If Len(aNotas) > 0
			For nX := 1 to Len(aNotas)
				Processa({||lRet := EstFiscal(aNotas[nX,1],aNotas[nX,2])},STR0028,STR0040) //"Estorno de Complemento Fiscal"##"Iniciando Estorno..."
			Next nX
		Endif

		__oMarkDXL:SetFilterDefault("@"+FilterMark(Nil))			
		If lRet			
			AGRFilNota()
			(__cAliasNF)->(dbGoTop())
			__oMarkDXB:SetAlias(__cAliasNF)
			__oMarkDXB:GoTop(.T.)
			__oMarkDXL:GoTop(.T.)
			__oMarkDXB:Refresh()
			__oMarkDXL:Refresh()		
		EndIf
	Endif

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} NotaEstorno
//Função gerada para o estorno dos complementos fisico e fiscal
@author bruna.rocio
@since 03/07/2017
@version undefined

@type function
/*/
Static Function DocEstorno()
	Local aArea := GetArea()
	Local lRet  := .T.
	Local nX    := 0
	Local aDocs

	If !ValidDocCheck() 
		MsgInfo(STR0027,STR0006)//"ATENCAO"###"Nenhum registro selecionado. Por favor, selecione ao menos um registro para dar continuidade ao processo."
		lRet := .F.
	Else	
		__oMarkDXL:SetFilterDefault(Nil)

		aDocs := GetDocs()

		If Len(aDocs) > 0
			For nX := 1 to Len(aDocs)
				Processa({||lRet := EstFisico(aDocs[nX,1],aDocs[nX,2])},STR0028,STR0040)
			Next nX
		Endif

		__oMarkDXL:SetFilterDefault("@"+FilterMark(Nil))			
		If lRet
			AGRFilNota()
			(__cAliasDoc)->(dbGoTop())
			__oMarkDoc:SetAlias(__cAliasDoc)
			__oMarkDoc:GoTop(.T.)
			__oMarkDXL:GoTop(.T.)
			__oMarkDoc:Refresh()
			__oMarkDXL:Refresh()
		EndIf
	Endif

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} ComplFisico
//Função para tratamento de complemento físico
@author bruna.rocio
@since 06/07/2016
@version undefined
@type function
/*/
Static Function ComplFisico()	
	Local aArea  := GetArea()
	Local lRet   := .T.

	//Valida se há registros selecionados
	If !ValidCheck(.F.)
		MsgInfo(STR0027,STR0006)//"ATENCAO"###"Nenhum registro selecionado. Por favor, selecione ao menos um registro para dar continuidade ao processo."
		lRet := .F.
	Else
		//Valida se tem saldo físico a ser complementado
		If VldFisico()
			Processa({|| lRet := AGR610FISICO() , STR0014/*"Aguarde..."*/, STR0069/*"Gerando complemento físico"*/ })
		Endif

		//Reabre query com as notas e docs de complemento
		AGRFilNota()

		//Atualiza grids de fardões a complementar e estorno físico
		(__cAliasDoc)->(dbGoTop())
		__oMarkDoc:SetAlias(__cAliasDoc)
		__oMarkDoc:Refresh()
		__oMarkDXL:Refresh()
	Endif	

	If Type("__oMarkDXL") <> "U"
		__oMarkDXL:Refresh()
	EndIf

	If Type("__oMarkDoc") <> "U"
		__oMarkDoc:Refresh()
	EndIf

	//Atualiza contador de registros selecionados
	UpCount(oTotFisico, oTotFiscal)

	RestArea(aArea)
Return lRet


/*/{Protheus.doc} ComplFiscal
//Função tratamento de complemento fiscal
@author bruna.rocio
@since 06/07/2016
@version undefined
@type function
/*/
Static Function ComplFiscal()	
	Local aArea   := GetArea()
	Local lRet    := .T.
	Local aInfo   

	//Valida se há registros selecionados
	If !ValidCheck(.F.)
		MsgInfo(STR0027,STR0006)//"ATENCAO"###"Nenhum registro selecionado. Por favor, selecione ao menos um registro para dar continuidade ao processo."
		lRet := .F.
	Else
		//Valida se há saldo fiscal a complementar
		If VldFiscal()
			//Busca informações para filtrar contratos
			aInfo := GetInfoCTR()

			Processa({|| lRet := AGR610FISCAL(aInfo) , STR0014 /*"Aguarde..."*/, STR0070/*"Gerando complemento fiscal"*/ })
		Endif

		//Reabre query com as notas e docs de complemento
		AGRFilNota()

		//Atualiza grids de fardões a complementar e estorno fiscal
		(__cAliasNF)->(dbGoTop())
		__oMarkDXB:SetAlias(__cAliasNF)
		__oMarkDXB:GoTop(.T.)
		__oMarkDXB:Refresh()
		__oMarkDXL:Refresh()			
	Endif	

	If Type("__oMarkDXL") <> "U"
		__oMarkDXL:Refresh()
	EndIf

	If Type("__oMarkDXB") <> "U"
		__oMarkDXB:Refresh()
	EndIf

	//Atualiza contador de registros selecionados
	UpCount(oTotFisico, oTotFiscal)

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} GetNotas
//Busca as notas que deverão ser estornadas
@author bruna.rocio
@since 28/07/2016
@version undefined
@type function
/*/
Static Function GetNotas()
	Local aNotas := {}

	(__cAliasNF)->(dbGoTop())
	While .Not. (__cAliasNF)->( Eof() )

		If __oMarkDXB:IsMark()
			aAdd(aNotas,{(__cAliasNF)->DXB_DOCNF,(__cAliasNF)->DXB_SERIE})
		Endif
		(__cAliasNF)->(dbSkip())
	EndDo	
Return aNotas

/*/{Protheus.doc} GetDocs
//Busca os documentos que deverão ser estornadas
@author bruna.rocio
@since 28/07/2016
@version undefined
@type function
/*/
Static Function GetDocs( )
	Local aDocs := {}

	(__cAliasDOC)->(dbGoTop())
	While .Not. (__cAliasDOC)->( Eof() )

		If __oMarkDoc:IsMark()
			aAdd(aDocs,{(__cAliasDOC)->DXB_DOC,(__cAliasDOC)->DXB_CODPRO})
		Endif
		(__cAliasDOC)->(dbSkip())
	EndDo	

Return aDocs

/*/{Protheus.doc} GetInfoCTR
//Retorna produto para filtrar os contratos
@author bruna.rocio
@since 27/07/2016
@version undefined
@type function
/*/
Static Function GetInfoCTR() 
	Local aArray := { /* Produto */, /* Produtor */ , /* Loja */ }

	DXL->(dbGoTop())
	While .Not. DXL->( Eof() )
		If __oMarkDXL:IsMark()
			aArray[1]  := DXL->DXL_CODPRO
			aArray[2]  := DXL->DXL_PRDTOR
			aArray[3]  := DXL->DXL_LJPRO
			Exit
		EndIf
		DXL->(dbSkip())
	EndDo
Return aArray

/*/{Protheus.doc} ValidCheck
//Verifica se há algum registro marcado
@author bruna.rocio
@since 25/07/2016
@version undefined
@type function
/*/
Static Function ValidDocCheck()
	Local aArea := GetArea()
	Local lRet  := .F.

	(__cAliasDoc)->(dbGoTop())
	While (__cAliasDoc)->(!Eof())
		If __oMarkDoc:IsMark()
			lRet := .T.
			Exit
		Endif
		(__cAliasDoc)->(dbSkip())
	EndDo

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} ValidCheck
//Verifica se há algum registro marcado
@author bruna.rocio
@since 25/07/2016
@version undefined
@type function
/*/
Static Function ValidCheck(lEstorno)
	Local aArea := GetArea()
	Local lRet  := .F.

	If lEstorno
		(__cAliasNF)->(dbGoTop())
		While (__cAliasNF)->(!Eof())
			If __oMarkDXB:IsMark()
				lRet := .T.
				Exit
			Endif
			(__cAliasNF)->(dbSkip())
		EndDo
	Else
		DXL->(dbGoTop())
		While DXL->(!Eof())
			If __oMarkDXL:IsMark()
				lRet := .T.
				Exit
			Endif
			DXL->(dbSkip())
		EndDo
	Endif	

	RestArea(aArea)
Return lRet


/*/{Protheus.doc} VldFiscal
@author bruna.rocio
@since 04/07/2017
@version undefined

@type function
/*/
Static Function VldFiscal()
	Local aArea := GetArea()
	Local lRet  := .T.
	Local cProdutor  := ""
	Local cLoja      := ""
	Local cSafra     := ""
	Local cProduto   := ""

	DXL->(dbGoTop())
	While DXL->(!Eof())
		If __oMarkDXL:IsMark()
			If (DXL->DXL_PSFISC - DXL->DXL_PSESTI) <= 0 .Or. DXL->DXL_COMPL = '3' //Complemento Fiscal
				MsgInfo(STR0071,STR0006) //"Há registros selecionados que não precisam ser complementados fiscalmente. Por favor, revise a seleção de fardões"##"Atenção"
				lRet := .F.
				Exit
			ElseIf !Empty(cProduto)
				If cProduto <> DXL->DXL_CODPRO
					MsgInfo(STR0075,STR0006) //"Há registros de diferentes produtos selecionados. Apenas fardões com o mesmo produto podem ser complementados juntos, favor verificar."##"Atenção"
					lRet := .F.
					Exit
				ElseIf cProdutor <> DXL->DXL_PRDTOR .Or. cLoja <> DXL->DXL_LJPRO
					MsgInfo(STR0076,STR0006) //"Há registros de diferentes produtor e/ou loja selecionados. Apenas fardões com o mesmo produtor e loja podem ser complementados juntos, favor verificar."##"Atenção"
					lRet := .F.
					Exit
				ElseIf cSafra <> DXL->DXL_SAFRA
					MsgInfo(STR0077,STR0006) //"Há registros de diferentes safras selecionados. Apenas fardões com a mesma safra podem ser complementados juntos, favor verificar."##"Atenção"
					lRet := .F.
					Exit
				Endif
			Else
				cProdutor := DXL->DXL_PRDTOR
				cLoja     := DXL->DXL_LJPRO
				cSafra    := DXL->DXL_SAFRA
				cProduto  := DXL->DXL_CODPRO	
			Endif			
		Endif
		DXL->(dbSkip())
	EndDo

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} VldFisico
@author bruna.rocio
@since 04/07/2017
@version undefined

@type function
/*/
Static Function VldFisico()
	Local aArea      := GetArea()
	Local lRet       := .T.
	Local cProdutor  := ""
	Local cLoja      := ""
	Local cSafra     := ""
	Local cProduto   := ""

	DXL->(dbGoTop())
	While DXL->(!Eof())
		If __oMarkDXL:IsMark()
			If (DXL->DXL_PSLIQU - DXL->DXL_PSESTI) = 0 .Or. DXL->DXL_COMPL = '1' //Complemento Fisico
				MsgInfo(STR0072,STR0006) //"Há registros selecionados que não precisam ser complementados fisicamente. Por favor, revise a seleção de fardões"##"Atenção"
				lRet := .F.
				Exit
			ElseIf !Empty(cProduto)
				If cProduto <> DXL->DXL_CODPRO
					MsgInfo(STR0075,STR0006) //"Há registros de diferentes produtos selecionados. Apenas fardões com o mesmo produto podem ser complementados juntos, favor verificar."##"Atenção"
					lRet := .F.
					Exit
				ElseIf cProdutor <> DXL->DXL_PRDTOR .Or. cLoja <> DXL->DXL_LJPRO
					MsgInfo(STR0076,STR0006) //"Há registros de diferentes produtor e/ou loja selecionados. Apenas fardões com o mesmo produtor e loja podem ser complementados juntos, favor verificar."##"Atenção"
					lRet := .F.
					Exit
				ElseIf cSafra <> DXL->DXL_SAFRA
					MsgInfo(STR0077,STR0006) //"Há registros de diferentes safras selecionados. Apenas fardões com a mesma safra podem ser complementados juntos, favor verificar."##"Atenção"
					lRet := .F.
					Exit
				Endif
			Else
				cProdutor := DXL->DXL_PRDTOR
				cLoja     := DXL->DXL_LJPRO
				cSafra    := DXL->DXL_SAFRA
				cProduto  := DXL->DXL_CODPRO
			Endif			
		Endif
		DXL->(dbSkip())
	EndDo

	RestArea(aArea)
Return lRet


/*/{Protheus.doc} EstFiscal
//Função responsável pelo estorno de complemento fiscal
@author bruna.rocio
@since 14/07/2016
@version undefined
@type function
/*/
Static Function EstFiscal(cNF, cSerie)
	Local aArea   := GetArea()
	Local lRet    := .T.
	Local oMdDXL  := FwLoadModel('AGRA601')
	Local oMdDXB  := FwLoadModel('AGRA605')

	Begin Transaction
		dbSelectArea('DXB')
		dbSetOrder(3)
		If MsSeek(fwxFilial('DXB')+cNF+cSerie)
			While DXB->(!Eof())      .And. ;
			DXB->DXB_DOCNF = cNF    .And. ;
			DXB->DXB_SERIE = cSerie
				If !Empty(DXB->DXB_NUMPED)

					dbSelectArea('SF2')
					dbSetOrder(1)
					If MsSeek(fwxFilial('SF2')+DXB->DXB_DOCNF+DXB->DXB_SERIE)			
						//Deleta o documento fiscal do complemento 			
						Processa({||lRet := AGRDLDOCFIS(DXB->DXB_DOCNF,DXB->DXB_SERIE)},STR0028,STR0043) //"ATENCAO"###"Busca do Documento Fiscal"
					Endif	

					If lRet 
						dbSelectArea('SC5')
						dbSetOrder(1)
						If MsSeek(fwxFilial('SC5')+DXB->DXB_NUMPED)
							//Delete o pedido do complemento
							Processa({||lRet := AGRDLPDVEN(DXB->DXB_NUMPED)},STR0028,STR0044) //"ATENCAO"###"Busca do Pedido de Venda" 
						Endif	

						If lRet
							DXL->(dbSelectArea('DXL'))
							DXL->(dbSetOrder(1))
							If DXL->(MsSeek(fwxFilial('DXL')+;
							PADR(DXB->DXB_FARDAO,TamSX3('DXL_CODIGO')[1],' ')+;
							PADR(DXB->DXB_SAFRA, TamSX3('DXL_SAFRA')[1], ' ')+;
							PADR(DXB->DXB_PRDTOR,TamSX3('DXL_PRDTOR')[1],' ')+;
							PADR(DXB->DXB_LJPRO,TamSX3('DXL_LJPRO')[1], ' ')+;
							PADR(DXB->DXB_FAZ,TamSX3('DXL_FAZ')[1],' ')))
								SetFunName("AGRA610")
								//Atualiza o fardão
								lRet := UpdateDXL(oMdDXL, '2') // Complemento Estornado								
							Endif

							If lRet
								oMdDXB:SetOperation(5)	

								oMdDXB:Activate()
								If (lRet := oMdDXB:VldData())
									oMdDXB:CommitData()
								Else
									oMdDXB:SetErrorMessage( , , , , , oMdDXB:GetErrorMessage()[6]) 
								End
								oMdDXB:DeActivate()
							Else	
								DisarmTrans()
							Endif
						Else
							DisarmTrans()
						Endif
					Else
						DisarmTrans()
					Endif
				Else
					DisarmTrans()
				Endif
				DXB->(dbSkip())
			EndDo	
		Endif
	End Transaction

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} EstFisico
//Estorno de complemento físico
@author bruna.rocio
@since 05/07/2017
@version undefined

@type function
/*/
Static Function EstFisico(cDoc, cCodPro)
	Local aArea   := GetArea()
	Local lRet    := .T.
	Local oMdDXL  := FwLoadModel('AGRA601')
	Local oMdDXB  := FwLoadModel('AGRA605')

	dbSelectArea('DXB')
	dbSetOrder(4)
	If MsSeek(fwxFilial('DXB')+cDoc+cCodPro)

		SetFunName := "AGRA601"
		//Estorna o apontamento de produção
		Processa({||lRet := AGR601REOP( DXB->DXB_OP, DXB->DXB_CODPRO, DXB->DXB_DOC, .F. )},STR0028,STR0045)//"ATENCAO"###"Estorno do Apontamento de Produção"
		SetFunName := "AGRA610"
		If lRet
			DXL->(dbSelectArea('DXL'))
			DXL->(dbSetOrder(1))
			If DXL->(MsSeek(fwxFilial('DXL')+;
			PADR(DXB->DXB_FARDAO,TamSX3('DXL_CODIGO')[1],' ')+;
			PADR(DXB->DXB_SAFRA, TamSX3('DXL_SAFRA')[1], ' ')+;
			PADR(DXB->DXB_PRDTOR,TamSX3('DXL_PRDTOR')[1],' ')+;
			PADR(DXB->DXB_LJPRO,TamSX3('DXL_LJPRO')[1], ' ')+;
			PADR(DXB->DXB_FAZ,TamSX3('DXL_FAZ')[1],' ')))
				SetFunName("AGRA610")
				//Atualiza o fardão
				lRet := UpdateDXL(oMdDXL, '2') // Complemento Estornado								
			Endif

			If lRet
				oMdDXB:SetOperation(5)	

				oMdDXB:Activate()
				If (lRet := oMdDXB:VldData())
					oMdDXB:CommitData()
				Else
					oMdDXB:SetErrorMessage( , , , , , oMdDXB:GetErrorMessage()[6]) 
				End
				oMdDXB:DeActivate()
			Else	
				DisarmTrans()
			Endif
		Else
			DisarmTrans()
		Endif	
	Endif

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} GetACompl
//Busca os registros a serem complementados fiscalmente
@author bruna.rocio
@since 07/07/2016
@version undefined
@param aCompl, array, Array com os itens que precisam de complemento
@param cLocal, characters, local do produto do complemento
@param cProd, characters, produto do complemento
@type function
/*/
Static Function GetFiscCompl(aCompl, cLocal, cProd, aPedidos)
	Local nQtdDoc   := 0
	Local nX, nCont := 0
	Local nSoma     := 0

	DXL->(dbGoTop())
	While .Not. DXL->( Eof() )

		If __oMarkDXL:IsMark()

			DXB->(dbSelectArea('DXB'))
			DXB->(dbSetOrder(2))
			If DXB->(MsSeek(fwxFilial('DXB')+DXL->DXL_CODIGO+DXL->DXL_SAFRA+"COMPLFCL"))

				If Ascan(aPedidos,{ |x| x[1] == DXB->DXB_NUMPED}) == 0 
					aAdd(aPedidos,{DXB->DXB_NUMPED})
				Endif

				cLocal := DXL->DXL_LOCAL
				cProd  := DXL->DXL_CODPRO

				aAdd(aCompl, { DXL->DXL_CODPRO     ,;                                        //Produto 
				Posicione('SB1',1,fwxFilial('SB1')+DXL->DXL_CODPRO,"B1_DESC"),; //Descricao
				Posicione('SB1',1,fwxFilial('SB1')+DXL->DXL_CODPRO,"B1_UM"),;   //UM
				(DXL->DXL_PSFISC - DXL->DXL_PSESTI) ,; //Quantidade
				DXL->DXL_LOCAL ,; //Local
				DXL->DXL_SAFRA ,; //SAFRA
				DXL->DXL_CODIGO,; //FARDÃO  
				DXB->DXB_NUMPED,; //Pedido
				DXB->DXB_PRDTOR,;
				DXB->DXB_LJPRO ,;
				DXB->DXB_FAZ })
			Else
				cLocal  := DXL->DXL_LOCAL
				cProd   := DXL->DXL_CODPRO
				nQtdDoc += DXL->DXL_PSFISC - DXL->DXL_PSESTI
				nCont++

				aAdd(aCompl, { DXL->DXL_CODPRO     ,;                                     //Produto 
				Posicione('SB1',1,fwxFilial('SB1')+DXL->DXL_CODPRO,"B1_DESC"),; //Descricao
				Posicione('SB1',1,fwxFilial('SB1')+DXL->DXL_CODPRO,"B1_UM"),;   //UM
				(DXL->DXL_PSFISC - DXL->DXL_PSESTI) ,; //Quantidade
				DXL->DXL_LOCAL ,;   //Local
				DXL->DXL_SAFRA ,;   //SAFRA
				DXL->DXL_CODIGO,;   //FARDÃO  
				'',;
				DXL->DXL_PRDTOR,;
				DXL->DXL_LJPRO ,;
				DXL->DXL_FAZ})
			Endif	 	  	   

		EndIf
		DXL->(dbSkip())
	EndDo

	If Len(aCompl) > 0
		For nX := 1 to Len(aCompl)
			If Empty(aCompl[nX,8])
				aCompl[nX,4] := Round(nQtdDoc / nCont, 2)
				nSoma        += aCompl[nX,4]
			Endif 
		Next nX
	Endif

	nQtdDoc := nSoma	
Return nQtdDoc

/*/{Protheus.doc} GetFisCompl
//Busca os registros a serem complementados fisicamente
@author bruna.rocio
@since 07/07/2016
@version undefined
@param aCompl, array, Array com os itens que precisam de complemento
@param cLocal, characters, local do produto do complemento
@param cProd, characters, produto do complemento
@type function
/*/
Static Function GetFisCompl(aCompl, cLocal, cProd)
	Local nQtdOP    := 0
	Local nX, nCont := 0
	Local cTM       := SuperGetMV('MV_AGRTMPR',.F.,'')
	Local nSoma     := 0

	DXL->(dbGoTop())
	While .Not. DXL->( Eof() )

		If __oMarkDXL:IsMark()

			DXB->(dbSelectArea('DXB'))
			DXB->(dbSetOrder(2))
			If !DXB->(MsSeek(fwxFilial('DXB')+DXL->DXL_CODIGO+DXL->DXL_SAFRA+"COMPLFSC"))

				cLocal := DXL->DXL_LOCAL
				cProd  := DXL->DXL_CODPRO
				nQtdOP += DXL->DXL_PSLIQU - DXL->DXL_PSESTI
				nCont++

				aAdd(aCompl, { DXL->DXL_CODPRO     ,;                                        //Produto 
				Posicione('SB1',1,fwxFilial('SB1')+DXL->DXL_CODPRO,"B1_DESC"),; //Descricao
				Posicione('SB1',1,fwxFilial('SB1')+DXL->DXL_CODPRO,"B1_UM"),;   //UM
				(DXL->DXL_PSLIQU - DXL->DXL_PSESTI) ,; //Quantidade
				DXL->DXL_LOCAL ,;   //Local
				cTM            ,;   //TM
				DXL->DXL_SAFRA ,;   //SAFRA
				DXL->DXL_CODIGO,;   //FARDÃO  
				DXL->DXL_PRDTOR,;
				DXL->DXL_LJPRO ,;
				DXL->DXL_FAZ})
			Endif	 	  	   
		EndIf
		DXL->(dbSkip())
	EndDo

	If Len(aCompl) > 0
		For nX := 1 to Len(aCompl)		
			aCompl[nX,4] := Round(nQtdOP / nCont, 2)
			nSoma        += aCompl[nX,4]			 
		Next nX
	Endif

	nQtdOP := nSoma	
Return nQtdOP

/*/{Protheus.doc} AGR610Fisico
//Função que efetua o complemento físico
@author bruna.rocio
@since 03/07/2017
@version undefined
@type function
/*/
Static Function AGR610Fisico()
	Local aArea := GetArea()
	Local lRet  := .T.
	Local cNumOP        := ""
	Local aCompl        := {}
	Local cNumDoc       := ""	
	Local nx            := 0
	Local cLocal, cProd := ""
	Local nQtdOP        := 0
	Local oMdDXL        := FwLoadModel('AGRA601')

	Private LMSERROAUTO := .F.

	nQtdOP := GetFisCompl(@aCompl, @cLocal, @cProd) //Busca os fardões a serem complementados fisicamente

	Begin Transaction
		If ExistBlock('AG610OPR')
			cNumOP := ExecBlock('AG610OPR',.F.,.F.,)
		elseif !Empty(cDXL_OP)
			cNumOP := cDXL_OP
		else
			cNumOP := A601GERAOP( cProd, cLocal, nQtdOP ) //Gera a ordem de produção para o complemento dos fardões
		EndIf		

		//****************************************************				 	  
		// IMPORTANTE: o valor complementado para cada fardão
		//             é uma média aritmética entre todos os
		//             fardões selecionados para serem 
		//             complementados na execução corrente
		//****************************************************	  
		For nx := 1 to Len(aCompl)		
			If lRet	 	  

				Processa({|| lRet := A620APROD(aCompl[nx], cNumOP, @cNumDoc)},STR0014,STR0046) //"Aguarde..."###"Efetuando apontamento de produção..."

				DXL->(dbSelectArea('DXL'))
				DXL->(dbSetOrder(1))

				If DXL->(MsSeek(fwxFilial('DXL')+PADR(aCompl[nX,8],TamSX3('DXL_CODIGO')[1],' ')+;
				PADR(aCompl[nX,7],TamSX3('DXL_SAFRA')[1],' ')+;
				PADR(aCompl[nX,9],TamSX3('DXL_PRDTOR')[1],' ')+;
				PADR(aCompl[nX,10],TamSX3('DXL_LJPRO')[1],' ')+;
				PADR(aCompl[nX,11],TamSX3('DXL_FAZ')[1],' ')))																						
					If lRet

						DbSelectArea('DXL')
						RegToMemory('DXL',.f.,.f.)

						//Cria o registro de rastreabilidade							
						lRet := RastroFisico(cNumDoc, aCompl[nX,4])		

						If lRet
							//Atualiza a DXL para marcar como complementado
							lRet := UpdateDXL(oMdDXL, '1') //Fardao complementado
							If !lRet
								DisarmTrans()
							Endif
						Else
							DisarmTrans()
						Endif			  											  
					Else
						DisarmTrans()
					Endif
				Endif					
				cNumDoc := ""  //Limpa o número do documento que será único para cada apontamento	
			Else
				DisarmTrans()
			Endif

		Next nX		 	  
	End Transaction	

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} AGR610Fiscal
// Geração de complemento de produto
@author bruna.rocio
@since 05/07/2016
@version undefined
@type function
/*/
Static Function AGR610Fiscal( aInfo )
	Local aArea         := GetArea()
	Local lRet          := .t.
	Local aCompl        := {}
	Local aPedidos      := {}
	Local cNumPed       := ""
	Local nx            := 0
	Local cLocal        := ""
	Local cProd         := aInfo[1]
	Local cCliente      := Posicione('NJ0',1,fwxFilial('NJ0')+aInfo[2]+aInfo[3],'NJ0_CODCLI')
	Local cLoja         := Posicione('NJ0',1,fwxFilial('NJ0')+aInfo[2]+aInfo[3],'NJ0_LOJCLI')
	Local nQtdDoc       := 0
	Local oMdDXL        := FwLoadModel('AGRA601')
	Local aFardoes      := {}      

	//Variaveis privadas utilizadas nas rotinas MATA	
	Private lTransf     := .f.
	Private lLiber      := .t.
	Private lSugere     := .f.
	Private bFiltraBrw  := {|| Nil}

	//Busca os fardões a serem complementados fiscalmente
	nQtdDoc := GetFiscCompl(@aCompl, @cLocal, @cProd, @aPedidos) 

	If nQtdDoc > 0
		//Busca contrato para complemento
		cCTR := A610BCtr(cProd,cCliente,cLoja)	
		If Empty(cCTR)
			Return .F.
		Endif	
	Endif

	Begin Transaction

		//Se a quantidade para a geração da nota for maior que zero
		If  nQtdDoc > 0 .And. !Empty(cCTR) 
			dbSelectArea('ADA')
			dbSetOrder(1)
			If MsSeek(fwxFilial('ADA')+cCTR)
				cNumPed := GetSXENum('SC5','C5_NUM')

				//Função para criação de pedido
				Processa({|| lRet := AGRCRTPED(cNumPed, cCTR, ADA->ADA_CODCLI, ADA->ADA_LOJCLI, nQtdDoc,;
				ADA->ADA_CONDPG, cProd, cLocal, /*cUM*/, /*cTES*/, /*nPVen*/), "AGRA610"},STR0014,STR0047) //"Aguarde..."###"Gerando pedido de venda..."

				If lRet
					aAdd(aPedidos,{cNumPed})

					//Atualiza contrato
					Ft400StatCt()

					If Len(aCompl) > 0
						For nx := 1 to Len(aCompl)				
							DXL->(dbSelectArea('DXL'))
							DXL->(dbSetOrder(1))

							If DXL->(MsSeek(fwxFilial('DXL')+PADR(aCompl[nX,7],TamSX3('DXL_CODIGO')[1],' ')+;
							PADR(aCompl[nX,6],TamSX3('DXL_SAFRA')[1],' ')+;
							PADR(aCompl[nX,9],TamSX3('DXL_PRDTOR')[1],' ')+;
							PADR(aCompl[nX,10],TamSX3('DXL_LJPRO')[1],' ')+;
							PADR(aCompl[nX,11],TamSX3('DXL_FAZ')[1],' ')))								

								If lRet
									DbSelectArea('DXL')
									RegToMemory('DXL',.f.,.f.)

									lRet := AGR605GRVPD( cProd, cLocal, cNumPed, aCompl[nX,4] )
								Else
									DisarmTrans()
								Endif
							Else
								DisarmTrans()
							Endif
						Next nX	
					Endif					

					//Verifica se gera o estoque bloqueado
					If lRet
						Pergunte("MTALIB",.F.)
						//³ mv_par01 Ordem Processmento ?  Ped.+Item /Dt.Entrega+Ped.+Item         ³
						//³ mv_par02 Pedido de          ?                                          ³
						//³ mv_par03 Pedido ate         ?                                          ³
						//³ mv_par04 Cliente de         ?                                          ³
						//³ mv_par05 Cliente ate        ?                                          ³
						//³ mv_par06 Dta Entrega de     ?                                          ³
						//³ mv_par07 Dta Entrega ate    ?                                          ³
						//³ mv_par08 Liberar            ? Credito/Estoque Credito                  ³
						MV_PAR01 := 1
						MV_PAR02 := cNumPed  
						MV_PAR03 := cNumPed
						MV_PAR04 := ADA->ADA_CODCLI
						MV_PAR05 := ADA->ADA_CODCLI
						MV_PAR06 := dDatabase
						MV_PAR07 := dDatabase
						MV_PAR08 := 1

						//Cria a SC9 e Libera Estoque															
						Processa({|| lRet := a440Proces(,,,@lRet)},STR0014,STR0048) //"Aguarde..."###"Liberando pedido de venda..."
					Endif

					If lRet
						//Verifica se gera o crédito bloqueado		
						If SuperGetMv("MV_BLOQUEI")
							//Avalia e Libera Crédito
							dbSelectArea("SC9")
							dbSetOrder(1)
							If MsSeek(fwxFilial("SC9")+cNumPed)
								If !(SC9->C9_BLCRED == "  " .And. SC9->C9_BLEST == "  ")
									//Função de Liberação de Crédito
									A450LibMan()
								Endif
							Endif	
						Endif					
					Else
						DisarmTrans()
					Endif					
				Else
					DisarmTrans()
				Endif
			Else
				DisarmTrans()		
			Endif									
		Endif	

	End Transaction	

	//Atualiza o numero do pedido no Array
	For nX := 1 to Len(aCompl)		
		If Empty(aCompl[nX,8])
			aCompl[nX,8] := cNumPed		 	
		Endif
		aAdd(aFardoes,{aCompl[nX,7]})
	Next nX	 	   

	If lRet
		//Gera as notas com base nos pedidos
		If Len(aPedidos) > 0 
			For nX := 1 to Len(aPedidos)
				If lRet
					//Posiciona no Pedido
					SC5->(dbSelectArea("SC5"))
					SC5->(dbSetOrder(1))
					SC5->(MsSeek(fwxFilial('SC5')+aPedidos[nX,1]))

					//Emite NF			
					lRet:= AGREMTNF(aPedidos[nX,1], "AGRA610")
				Endif
			Next nX
		Endif

		If lRet .And. ExistBlock('AG610PNF')
			lRet := ExecBlock('AG610PNF',.F.,.F.,{aFardoes,aPedidos})			
		EndIf

		//Atualização da DXL e DXB
		If lRet
			Begin Transaction
				If Len(aCompl) > 0
					For nx := 1 to Len(aCompl)				
						DXL->(dbSelectArea('DXL'))
						DXL->(dbSetOrder(1))

						If DXL->(MsSeek(fwxFilial('DXL')+PADR(aCompl[nX,7],TamSX3('DXL_CODIGO')[1],' ')+;
						PADR(aCompl[nX,6],TamSX3('DXL_SAFRA')[1],' ')+;
						PADR(aCompl[nX,9],TamSX3('DXL_PRDTOR')[1],' ')+;
						PADR(aCompl[nX,10],TamSX3('DXL_LJPRO')[1],' ')+;
						PADR(aCompl[nX,11],TamSX3('DXL_FAZ')[1],' ')))	

							//Atualiza a DXL para marcar como complementado
							lRet := UpdateDXL(oMdDXL, '3') //Fardao complementado fiscalmente

							If lRet
								//Atualiza a DXB com a Série e NF
								lRet := UpdateDXB(aCompl[nX,8]) //Numero do pedido de venda									
							Else
								DisarmTrans()
							Endif
						Else
							DisarmTrans()
						Endif
					Next nX	
				Endif
			End Transaction
		Endif
	Endif

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} UpdateDXB
//Função para inserção da NF na tabela de rastreabilidade DXB
@author bruna.rocio
@since 07/07/2016
@version undefined
@param cNumPed, characters, descricao
@type function
/*/
Static Function UpdateDXB(cNumPed)
	Local aArea  := GetArea()
	Local lRet   := .T.
	Local cNF, cSerie := ""

	DbSelectArea('SC5')
	DbSetOrder(1)
	If MsSeek(fwxFilial('SC5')+cNumPed)
		cNF    := SC5->C5_NOTA
		cSerie := SC5->C5_SERIE
	Endif

	//Grava a Nota Fiscal e Série
	lRet := AGR605GRVNF( DXL->DXL_CODIGO, DXL->DXL_SAFRA, cNF, cSerie, "COMPLFCL" )

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} RastroFisico
//Função para criação da tabela de rastreabilidade DXB para o complemento físico
@author bruna.rocio
@since 07/07/2016
@version undefined
@param cNumPed, characters, descricao
@param cNumDoc, characters, descricao
@param cTM, characters, descricao
@param cOP, characters, descricao
@type function
/*/
Static Function RastroFisico(cNumDoc, nQuant)
	Local aArea  := GetArea()
	Local lRet   := .T.
	Local oModel    := FwLoadModel('AGRA605')
	Local oGridDXB	:= oModel:GetModel('AGRA605_DXB')

	DbSelectArea('SD3')
	DbSetOrder(2)
	If MsSeek(fwxFilial('SD3')+cNumDoc)

		// Seta a operação do modelo como INCLUSÃO
		oModel:SetOperation(3)

		If oModel:Activate()

			//Grava tabela de relacionamentos - DXB
			oGridDXB:LoadValue("DXB_FILIAL",FwXFilial("DXB"))
			oGridDXB:LoadValue("DXB_EMISSA",dDataBase)
			oGridDXB:LoadValue("DXB_FARDAO",M->DXL_CODIGO)
			oGridDXB:LoadValue("DXB_SAFRA" ,M->DXL_SAFRA)
			oGridDXB:LoadValue("DXB_PRDTOR",M->DXL_PRDTOR)
			oGridDXB:LoadValue("DXB_LJPRO" ,M->DXL_LJPRO)
			oGridDXB:LoadValue("DXB_FAZ"   ,M->DXL_FAZ)
			oGridDXB:LoadValue("DXB_OP"    ,SD3->D3_OP)
			oGridDXB:LoadValue("DXB_CODPRO",SD3->D3_COD)
			oGridDXB:LoadValue("DXB_DOC"   ,SD3->D3_DOC)
			oGridDXB:LoadValue("DXB_LOCAL" ,SD3->D3_LOCAL)
			oGridDXB:LoadValue("DXB_NUMSEQ",SD3->D3_NUMSEQ)
			oGridDXB:LoadValue("DXB_CF"    ,SD3->D3_CF)
			oGridDXB:LoadValue("DXB_TM"    ,SD3->D3_TM)
			oGridDXB:LoadValue("DXB_QUANT" ,nQuant)
			oGridDXB:LoadValue("DXB_ROTINA","COMPLFSC")
			DbSelectArea('DXB')
			If DXB->(ColumnPos('DXB_CODUNI')) > 0
				oGridDXB:LoadValue("DXB_CODUNI",M->DXL_CODUNI)
			Endif
			DXB->(dbclosearea())
			If (lRet := oModel:VldData())
				//Efetiva gravacao dos dados na tabela
				lRet := oModel:CommitData()
			Else
				oModel:SetErrorMessage( , , , , , oModel:GetErrorMessage()[6])			
			EndIf
		Endif	
		oModel:DeActivate()
	Endif

	RestArea(aArea)
Return lRet


/*/{Protheus.doc} UpdateDXL
//Atualização da tabela DXL - Fardão
@author bruna.rocio
@since 07/07/2016
@version undefined
@param oMdDXL, object, model da tabela DXL
@param cVlCompl, character, valor a ser atribuido ao campo DXL_COMPL (1 - Complementado, 2 - Estornado)
@type function
/*/
Static Function UpdateDXL(oMdDXL, cVlCompl)
	Local aArea := GetArea()
	Local lRet  := .T.

	oMdDXL:GetModel("DXLMASTER"):GetStruct():DeActivate()			
	If !(oMdDXL:GetModel("DXLMASTER"):HasField("DXL_OK"))
		oMdDXL:GetModel("DXLMASTER"):GetStruct():AddField(/*cTitulo*/'',;
		/*cTooltip*/'' ,;
		/*cIdField*/'DXL_OK',;
		/*cTipo*/'C',;
		/*nTamanho*/2,;
		/*nDecimal*/0,;
		/*bValid*/ ,;
		/*bWhen*/,;
		/*aValues*/,;
		/*lObrigat*/ .F.,;
		/*bInit*/ ,;
		/*lKey*/,;
		/*lNoUpd */,;
		/*lVirtual */ .F.)						
	endif
	If !(oMdDXL:GetModel("DXLMASTER"):HasField("DXL_COMPL"))
		oMdDXL:GetModel("DXLMASTER"):GetStruct():AddField(/*cTitulo*/'',;
		/*cTooltip*/'' ,;
		/*cIdField*/'DXL_COMPL',;
		/*cTipo*/TamSX3('DXL_COMPL')[3],;
		/*nTamanho*/TamSX3('DXL_COMPL')[1],;
		/*nDecimal*/TamSX3('DXL_COMPL')[2],;
		/*bValid*/ ,;
		/*bWhen*/,;
		/*aValues*/,;
		/*lObrigat*/ .F.,;
		/*bInit*/ ,;
		/*lKey*/,;
		/*lNoUpd */,;
		/*lVirtual */ .F.)						
	Endif

	//Seta operação do Fardão como alteração para encerrar o processo
	oMdDXL:SetOperation(MODEL_OPERATION_UPDATE) //Alteração
	//Se for possível ativar o modelo, continua
	If oMdDXL:Activate()
		oMdDXL:GetModel("DXLMASTER"):LoadValue('DXL_OK','')	
		oMdDXL:GetModel("DXLMASTER"):LoadValue('DXL_COMPL',cVlCompl)

		If (lRet := oMdDXL:VldData())
			oMdDXL:CommitData()								
		Else
			// Se foi retornado erro da validação do modelo
			// seta o retorno como false, mostra mensagem de erro
			// e interrompe o looping
			lRet := .F.
			oMdDXL:SetErrorMessage( , , , , , oMdDXL:GetErrorMessage()[6])							
		Endif
	Endif	

	//Desativa o modelo
	oMdDXL:DeActivate()	

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} A610BCtr
//Tela para a seleção de contratos
@author bruna.rocio
@since 27/07/2016
@version undefined
@param cProduto, characters, descricao
@type function
/*/
Static Function A610BCtr(cProduto,cCliente,cLoja)
	Local aArea     := GetArea()
	Local aOrdem    := {AllTrim(RetTitle("ADA_NUMCTR")),AllTrim(RetTitle("ADA_EMISSA"))}
	Local aChave    := {"ADA_NUMCTR","ADA_EMISSA"}
	Local aPesq     := {{Space(Len(ADA->ADA_NUMCTR)),"@!"},{Ctod(""),"@!"}}
	Local aHeadTrb  := {}
	Local aStruTrb  := {}
	Local aSize     := MsAdvSize( .F. )
	Local aObjects  := {}
	Local aInfo     := {}
	Local aPosObj   := {}
	Local aIndex    := {}
	Local cContrato := ""
	Local cAliasADA := "ADA"
	Local cAliasADB := "ADB"
	Local cAliasTrb := "FT400PV"
	Local cQuery    := ""
	Local cCombo    := ""
	Local nHandle   := GetFocus()
	Local nX        := 0
	Local nOpcA     := 0
	Local lQuery    := .F.
	Local lValido   := .T.
	Local xPesq     := ""
	Local bWhile1   := {|| .T.}
	Local bWhile2   := {|| .T.}
	Local oDlg
	Local oPanel
	Local oCombo
	Local oGet
	Local oGetDB
	Local aStruct  := {}

	// Obs: este array aRotina foi inserido apenas para permitir o
	// funcionamento das rotinas internas da MSGETDB
	If Type("aRotina") != "A"
		Private aRotina := { { "aRotina Falso", "AxInclui", 0 , 1} }
	Endif

	//***************************************************
	// Montagem do arquivo temporario dos itens do SD1  
	//***************************************************
	aStruct := ADA->(DbStruct())

	For nX := 1 To Len(aStruct)
		If X3USADO(aStruct[nX,1]) .And. cNivel >= AGRRETNIV(aStruct[nX,1]) .And. AGRRETCTXT("ADA", aStruct[nX,1]) <> "V" .And. aStruct[nX,2] <> "M"
			Aadd(aHeadTrb,{ TRIM(RetTitle(aStruct[nX,1])),;
			aStruct[nX,1],;
			X3PICTURE(aStruct[nX,1]),;
			aStruct[nX,3],;
			aStruct[nX,4],;
			X3VALID(aStruct[nX,1]),;
			X3USADO(aStruct[nX,1]),;
			aStruct[nX,2],;
			"ADA",;
			AGRRETCTXT("ADA", aStruct[nX,1]),;
			X3ORDEM(aStruct[nX,1]) })
			aadd(aStruTRB,{aStruct[nX,1],aStruct[nX,2],aStruct[nX,3],aStruct[nX,4]})
		EndIf
	Next nX

	//*****************************
	// Cria o arquivo temporario 
	//*****************************

	For nx := 1 To Len(aChave)
		//A funcao u adiciona o nome do indice
		AADD(aIndex,{"", aChave[nx]  } )
	Next nX 	
	cAliasTrb := GetNextAlias()
	oArqTemp  := AGRCRTPTB(cAliasTrb, {aStruTRB, aIndex } )

	//**********************************************************************
	// Verificacao do aHeader atual  
	//**********************************************************************
	//**********************************************************************
	// Atualizacao do arquivo temporario com base nos itens do SD1         
	//**********************************************************************
	dbSelectArea("ADA")
	dbSetOrder(2)
	dbSelectArea("ADB")
	dbSetOrder(1)

	lQuery    := .T.
	cAliasADA := "F4PODER3_SQL"
	cAliasADB := "F4PODER3_SQL"

	cQuery := "SELECT ADA.R_E_C_N_O_ ADARECNO,ADA_FILIAL,ADB_FILIAL,ADB_NUMCTR,ADB_CODPRO,ADB_QUANT,ADB_QTDEMP "
	For nX := 1 To Len(aHeadTRB)
		cQuery += ","+aHeadTRB[nX][2]+" "
	Next nX
	cQuery += "FROM "+RetSqlName("ADA")+" ADA ,"
	cQuery += RetSqlName("ADB")+" ADB "
	cQuery += "WHERE ADA.ADA_FILIAL='"+fwxFilial("ADA")+"' AND "
	cQuery += "ADA.ADA_CODCLI = '" + cCliente + "' AND "
	cQuery += "ADA.ADA_LOJCLI = '" + cLoja + "' AND " 
	cQuery += "ADA.ADA_STATUS IN('B','C') AND "
	cQuery += "ADA.D_E_L_E_T_=' ' AND "
	cQuery += "ADB.ADB_FILIAL='"+fwxFilial("ADB")+"' AND "
	cQuery += "ADB.ADB_NUMCTR=ADA.ADA_NUMCTR AND "
	cQuery += "ADB.ADB_CODPRO='" + cProduto + "' AND "
	cQuery += "ADB.ADB_QUANT>ADB.ADB_QTDEMP AND "
	cQuery += "ADB.D_E_L_E_T_=' ' "

	cQuery += "ORDER BY "+SqlOrder(ADB->(IndexKey()))

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasADA,.T.,.T.)

	For nX := 1 To Len(aStruTRB)
		If aStruTRB[nX][2] <> "C" .And. FieldPos(aStruTRB[nX][1])<>0
			TcSetField(cAliasADA,aStruTRB[nX][1],aStruTRB[nX][2],aStruTRB[nX][3],aStruTRB[nX][4])
		EndIf
	Next nX
	bWhile1 := {|| !Eof() .And. (cAliasADA)->ADA_FILIAL==fwxFilial("ADA") }
	bWhile2 := {|| !Eof() .And. (cAliasADB)->ADB_FILIAL==fwxFilial("ADB") .And. (cAliasADB)->ADB_NUMCTR==(cAliasADA)->ADA_NUMCTR .And. (cAliasADB)->ADB_CODPRO==cProduto }

	While Eval(bWhile1)
		If !lQuery
			If ADA->ADA_STATUS $ "B,C"
				lValido := .T.
				dbSelectArea("ADB")
				dbSetOrder(1)
				MsSeek(fwxFilial("ADB")+ADA->ADA_NUMCTR)
			Else
				lValido := .F.
			EndIf
		Else
			lValido := .T.
		EndIf
		While lValido .And. Eval(bWhile2)
			//*********************************************************
			// Atualiza o arquivo temporario com os dados do contrato 
			//*********************************************************
			dbSelectArea(cAliasTRB)
			dbSetOrder(1)
			If !MsSeek((cAliasADA)->ADA_NUMCTR)
				If (cAliasADB)->ADB_QUANT > (cAliasADB)->ADB_QTDEMP
					RecLock(cAliasTRB,.T.)
					For nX := 1 To Len(aStruTRB)
						If (cAliasADA)->(FieldPos(aStruTRB[nX][1]))<>0
							(cAliasTRB)->(FieldPut(nX,(cAliasADA)->(FieldGet(FieldPos(aStruTRB[nX][1])))))
						EndIf
					Next nX
					MsUnLock()
				EndIf
			EndIf
			dbSelectArea(cAliasADB)
			dbSkip()
		EndDo
		dbSelectArea(cAliasADA)
		dbSkip()
	EndDo
	If lQuery
		dbSelectArea(cAliasADA)
		dbCloseArea()
		dbSelectArea("ADA")
	EndIf
	dbSelectArea(cAliasTRB)
	dbSetOrder(1)
	dbGotop()	

	PRIVATE aHeader := aHeadTRB
	xPesq := aPesq[(cAliasTRB)->(IndexOrd())][1]

	//**************************************
	// Calcula as coordenadas da interface  
	//**************************************
	aSize[1] /= 1.5
	aSize[2] /= 1.5
	aSize[3] /= 1.5
	aSize[4] /= 1.3
	aSize[5] /= 1.5
	aSize[6] /= 1.3
	aSize[7] /= 1.5

	AAdd( aObjects, { 100, 020,.T.,.F.,.T.} )
	AAdd( aObjects, { 100, 060,.T.,.T.} )
	AAdd( aObjects, { 100, 020,.T.,.F.} )
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects,.T.)

	//***************************
	// Interface com o usuario   
	//***************************
	If !(cAliasTRB)->(Eof())
		DEFINE MSDIALOG oDlg TITLE STR0049 FROM aSize[7],000 TO aSize[6],aSize[5] OF oMainWnd PIXEL //"Contrato"
		@ aPosObj[1,1],aPosObj[1,2] MSPANEL oPanel PROMPT "" SIZE aPosObj[1,3],aPosObj[1,4] OF oDlg CENTERED LOWERED
		@ aPosObj[3,1]+3,aPosObj[3,2]+00 SAY STR0050 PIXEL //"Pesquisar por:"
		@ aPosObj[3,1]+3,aPosObj[3,2]+140 SAY STR0051 PIXEL //"Localizar"
		@ aPosObj[3,1]+00,aPosObj[3,2]+40 MSCOMBOBOX oCombo VAR cCombo ITEMS aOrdem SIZE 100,044 OF oDlg PIXEL ;
		VALID ((cAliasTRB)->(dbSetOrder(oCombo:nAt)),(cAliasTRB)->(dbGotop()),xPesq := aPesq[(cAliasTRB)->(IndexOrd())][1],.T.)
		@ aPosObj[3,1],aPosObj[3,2]+170 MSGET oGet VAR xPesq Of oDlg PICTURE aPesq[(cAliasTRB)->(IndexOrd())][2] PIXEL ;
		VALID ((cAliasTRB)->(MsSeek(Iif(ValType(xPesq)=="C",AllTrim(xPesq),xPesq),.T.)),.T.).And.IIf(oGetDb:obrowse:refresh()==NIL,.T.,.T.)
		oGetDb := MsGetDB():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],1,"Allwaystrue","allwaystrue","",.F., , ,.F., ,cAliasTRB)
		DEFINE SBUTTON FROM aPosObj[3,1],aPosObj[3,4]-060 TYPE 1 ACTION (nOpcA := 1,oDlg:End()) ENABLE OF oDlg
		DEFINE SBUTTON FROM aPosObj[3,1],aPosObj[3,4]-030 TYPE 2 ACTION (nOpcA := 0,oDlg:End()) ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg CENTERED
	Else
		MsgInfo(STR0073,STR0006) //"Não encontrado contrato de venda para produtor e produto do fardão"##"Atenção"
	EndIf
	If nOpcA == 1
		cContrato := (cAliasTRB)->ADA_NUMCTR
	EndIf

	//***********************************
	// Restaura a integridade da rotina
	//***********************************
	dbSelectArea(cAliasTRB)
	dbCloseArea()
	RestArea(aArea)
	SetFocus(nHandle)
Return(cContrato)

/*/{Protheus.doc} addCampoGrid
//Adiciona campos com o valor a complementar
@author bruna.rocio
@since 04/07/2017
@version undefined
@type function
/*/
Static function addCampoGrid()
	Local aColumns := {}

	Aadd( aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData(&("{||IIF(DXL_PSFISC > 0 .And. HasComplemento(DXL_SAFRA, DXL_CODIGO, 'COMPLFCL'),(DXL_PSFISC - DXL_PSESTI),0)}"))
	aColumns[Len(aColumns)]:SetType(TAMSX3("DXL_PSFISC")[3])
	aColumns[Len(aColumns)]:SetID("DXL_DIFFIS")
	aColumns[Len(aColumns)]:SetTitle(STR0053/*"Compl.Fiscal"*/)
	aColumns[Len(aColumns)]:SetSize(TAMSX3("DXL_PSFISC")[1])
	aColumns[Len(aColumns)]:SetDecimal(TAMSX3("DXL_PSFISC")[2])
	aColumns[Len(aColumns)]:SetPicture(X3Picture("DXL_PSFISC"))
	aColumns[Len(aColumns)]:SetAlign(CONTROL_ALIGN_RIGHT)
	aColumns[Len(aColumns)]:SetReadVar("(DXL->DXL_PSFISC - DXL->DXL_PSESTI)")

	Aadd( aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData(&("{||IIF(DXL_PSLIQU > 0 .And. HasComplemento(DXL_SAFRA, DXL_CODIGO, 'COMPLFSC'), (DXL_PSLIQU - DXL_PSESTI),0)}"))
	aColumns[Len(aColumns)]:SetType(TAMSX3("DXL_PSLIQU")[3])
	aColumns[Len(aColumns)]:SetID("DXL_DIFCOMP")
	aColumns[Len(aColumns)]:SetTitle(STR0052/*"Compl.Fisico"*/)
	aColumns[Len(aColumns)]:SetSize(TAMSX3("DXL_PSLIQU")[1])
	aColumns[Len(aColumns)]:SetDecimal(TAMSX3("DXL_PSLIQU")[2])
	aColumns[Len(aColumns)]:SetPicture(X3Picture("DXL_PSLIQU"))
	aColumns[Len(aColumns)]:SetAlign(CONTROL_ALIGN_RIGHT)
	aColumns[Len(aColumns)]:SetReadVar("(DXL->DXL_PSLIQU - DXL->DXL_PSESTI)")

Return(aColumns)


/*/{Protheus.doc} HasComplemento
//Verifica se tem complemento
@author bruna.rocio
@since 07/07/2017
@version undefined
@param cSafra, characters, descricao
@param cFardao, characters, descricao
@param cRotina, characters, descricao
@type function
/*/
Static Function HasComplemento(cSafra, cFardao, cRotina)
	Local aArea := GetArea()
	Local lRet  := .T.

	dbSelectArea('DXB')
	dbSetOrder(2)
	If MSSeek(fwxFilial('DXB')+cFardao+cSafra+cRotina)
		If cRotina = 'COMPLFCL' .And. !Empty(DXB->DXB_DOCNF)
			lRet := .F.
		ElseIf cRotina = "COMPLFSC"
			lRet := .F.
		Endif	
	Endif

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} Filtra
//Filtra a informação das grid com base no produtor e unidade de beneficiamento informados no cabeçalho
@author bruna.rocio
@since 04/07/2017
@version undefined
@param nOptFolder, numeric, número da pasta selecionada no folder
@type function
/*/
Static Function Filtra( nOptFolder)
	If nOptFolder = 1 //Complemento
		__oMarkDXL:SetFilterDefault("@"+FilterMark(cDXL_PRDTOR, cDXL_LJPRO, cDXL_UNB))
		__oMarkDXL:Refresh()
	Endif
Return .t.
