#include "TECA201.CH"
#INCLUDE "PROTHEUS.CH"


//grids da tela principal
#DEFINE BRWCLIENTE 1
#DEFINE BRWCTRMANU 2
#DEFINE BRWCTRSERV 3
#DEFINE BRWBASEATD 4


//grids da tela de detalhe do contrato de manutencao
#DEFINE BRWORDEMSERV	1
#DEFINE BRWATENDOS  	2
#DEFINE BRWGRUPOCOB 	3
#DEFINE BRWALOCCTR 	4

#DEFINE	PERCLIENTE	1
#DEFINE PERCTRMANU	2
#DEFINE PERCTRSERV	4
#DEFINE PERBASEATD	3
Static lChkCli		:= .F.
//--------------------------------------------------------------------------------
/*/{Protheus.doc} TECA201()

Chamada de menu da Area de trabalho dos contratos

@return Nenhum

@author Vendas CRM
@since 24/01/13
/*/
//-------------------------------------------------------------------------------- 
Function TECA201()
//----------------------------------------------------------------------
// Privates obrigatorias para funcionar rotinas padroes dos browses
//----------------------------------------------------------------------
Private aRotina 					
Private aRotAuto 	
Private cCadastro := "TECA201"
Private L030AUTO
Private lRefresh
Private bFiltraBrw 	:= {|| Nil}                                
Private aAutoCab	:= {}			// Cabeçalho da rotina automático
Private aAutoItens	:= {}			// Itens da rotina automática
Private aAutoGrupo	:= {}			// Itens da rotina automática


MsgRun(STR0002, STR0001, {|| At201Show() } )  // "Procurar" "Procurando." "Aguarde..."//"Aguarde"//"Carregando Dados....."

Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} At201Show()

Exibe a tela principal da area de trabalho

@return Nenhum

@author Vendas CRM
@since 24/01/13
/*/
//-------------------------------------------------------------------------------- 
Function At201Show()
Local oPanel 			:= Nil	//tela principal
Local oFWLayer		:= Nil	//organizador de janelas
Local aCoors			:= MsAdvSize()	
Local oFontAlert 		:= TFont():New( ,,-12,, .T.)

//Controla as permissões na área de trabalho
Local lContrPerm		:= SuperGetMv("MV_TECPCON",,.F.)
Local lPermit        := .F.
Local aDadosP			:= {}

//objetos dos pedacos da tela
Local oClientes			:= Nil
Local oContrManutencao	:= Nil
Local oContrServico		:= Nil
Local oBaseAtendimento	:= Nil
Local oBotoes				:= Nil

//Controle tamanho resolução
Local nPanel1 := 0
Local nPanel2 := 0

//workaround para nao criar objetos privates e passar todos os browses para a funcao que executa os filtros 
Local aBrowses := Array(50)

//Botoes
Local oBtnLimpar		:= Nil
Local oBtnGrade		:= Nil
Local oBtnDetManu		:= Nil
Local oBtnSair		:= Nil
Local oCheck1		:= Nil

aDadosP := At201Perm()    

If Empty(aDadosP) .AND. lContrPerm == .T.
	Help("",1,"TECA201",,STR0019,2,0) 		//"Usuario sem permissão"
	lPermit := .F.
ElseIf Empty(aDadosP) .AND. lContrPerm == .F.
	lPermit := .T.
ElseIf  !Empty(aDadosP)
	lPermit := .T.
EndIf

If lPermit
	
	/*
	* Condição para verificar tamanho das linhas em relação a resolução
	* Pois sem a verificação em resolução menores, o conteudo do painel auxiliar pode sumir
	*/
	
	If aCoors[6] < 690
		nPanel1 := 40
		nPanel2 := 15
	Else 
		nPanel1 := 43
		nPanel2 := 12
	EndIf
	If !IsBlind()
		DEFINE MSDIALOG oPanel TITLE STR0003 FROM aCoors[7],0 TO aCoors[6],aCoors[5] of oMainWnd PIXEL STYLE WS_DLGFRAME //"Área de Trabalho - Contratos"
		
		//--------------------------------
		// Configura o FWLayer
		//--------------------------------
		oFWLayer := FWLayer():New()
		oFWLayer:Init( oPanel, .F.)
		
		//--------------------------------
		// Cria colunas
		//--------------------------------
		oFWLayer:AddLine( 'Linha 1', nPanel1, .F. ) 
		oFWLayer:AddCollumn("Coluna 1", 50, .F., 'Linha 1')
		oFWLayer:AddCollumn("Coluna 2", 50 , .F., 'Linha 1')
		
		oFWLayer:AddLine( 'Linha 2', nPanel1, .F. ) 
		oFWLayer:AddCollumn("Coluna 1", 50, .F., 'Linha 2')
		oFWLayer:AddCollumn("Coluna 2", 50, .F., 'Linha 2')
		
		oFWLayer:AddLine( 'Linha 3', nPanel2, .F. ) 
		oFWLayer:AddCollumn("Coluna 1", 100, .F., 'Linha 3')
		
		oFWLayer:AddWindow( "Coluna 1", "Window 2", STR0004, 100, .T., .T., , "Linha 3" , , CONTROL_ALIGN_CENTER )//"Auxiliares"
		
		//------------------------------------------
		// Associa objetos com os pedacos da tela
		//------------------------------------------
		oClientes 		:= oFWLayer:GetColPanel( "Coluna 1", 'Linha 1' )
		oBaseAtendimento 	:= oFWLayer:GetColPanel( "Coluna 2", 'Linha 1' )
		oContrManutencao	:= oFWLayer:GetColPanel( "Coluna 1", 'Linha 2' )		
		oContrServico 	:= oFWLayer:GetColPanel( "Coluna 2", 'Linha 2' )	
		oBotoes 			:= oFWLayer:GetWinPanel( "Coluna 1", "Window 2" , "Linha 3")		
		
		
		//oFWLayer:setColSplit ( "Coluna 2", , 'Linha 1' )
		
		
		//--------------------------------
		// Inclui os Browses e janelas
		//--------------------------------                                               
		At201Brw(aBrowses, BRWCLIENTE, oClientes, STR0005, "SA1", "MATA030",IIF(!Empty(aDadosP),aDadosP[1][PERCLIENTE],""))//"Clientes"
		At201Brw(aBrowses, BRWCTRMANU, oContrManutencao, STR0006, "AAH", "TECA200",IIF(!Empty(aDadosP),aDadosP[1][PERCTRMANU],""))//"Contrato de Manutenção"
		At201Brw(aBrowses, BRWCTRSERV, oContrServico, STR0007, "AAM", "TECA250",IIF(!Empty(aDadosP),aDadosP[1][PERCTRSERV],""))//"Contrato de Serviços"
		At201Brw(aBrowses, BRWBASEATD, oBaseAtendimento, STR0008, "AA3", "TECA040",IIF(!Empty(aDadosP),aDadosP[1][PERBASEATD],""))//"Base de Atendimento"
		
		
		//--------------------------------
		// Area dos botoes
		//--------------------------------
		@ 005, 005 Say STR0009 Size 300,015 COLOR CLR_BLUE FONT oFontAlert PIXEL OF oBotoes		//"Execute um duplo clique em um browse para filtrar os demais relacionados."
		@ 003, 260 Button oBtnLimpar Prompt STR0010 Size 040,012 Pixel Of oBotoes Action ( At201LimpFil(aBrowses,If( Empty(aDadosP) .Or. Len(aDadosP) == 0, Nil, aDadosP[1] ))	)
		@ 003, 310 Button oBtnGrade Prompt STR0020 Size 060,012 Pixel Of oBotoes Action At201Click(2) 		 //"Mesa de Operação"
		@ 005, 380 CHECKBOX oCheck1 VAR lChkCli PROMPT STR0022 Size 080,012 Pixel Of oBotoes	//"Pergunta Filtros?"
		@ 003, 460 Button oBtnDetManu Prompt STR0011 Size 060,012 Pixel Of oBotoes Action At201Click(3) 	//"Detalhe Contr. Manu."
		@ 003, 520 Button oBtnSair Prompt STR0021 Size 040,012 Pixel Of oBotoes Action At201Exit( oPanel ) 	//"Sair"

		ACTIVATE MSDIALOG oPanel CENTERED
	EndIf
EndIf

Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} At201Brw()

Adiciona os browses na tela principal

@param aBrowses, array, Lista de Browses da tela (os objetos serao adicionados no array)
@param nID, numerico, ID para o Browse
@param oOwner, Objeto, Pai do Browse
@param cTitulo, caractere, Titulo do browse
@param cAlias, caractere, Tabela utilizada no browse
@param [cMenuDef], caractere, fonte em que sera buscado o menudef

@return Nenhum

@author Vendas CRM
@since 24/01/13
/*/
//-------------------------------------------------------------------------------- 
Function At201Brw(aBrowses, nID, oOwner, cTitulo, cAlias, cMenuDef,aDadosP )
Local oBrowse := nil
Local cStr	:= "/"
Local nX	:= 0
Local cContrAux := ''
Local nIndex := 0
Default cMenuDef := ""

//--------------------------------
// Inclui os Browses nas janelas
//--------------------------------
oBrowse:= FWmBrowse():New() 
oBrowse:SetOwner( oOwner )                           
oBrowse:SetDescription( cTitulo ) 
oBrowse:SetAlias( cAlias ) 
oBrowse:SetProfileID( Str(nID) ) 
oBrowse:DisableDetails() 
oBrowse:SetWalkThru(.F.)
oBrowse:SetAmbiente(.F.)

If !Empty(aDadosP)
	For nX := 1 To Len(aDadosP) 
		If nID == BRWBASEATD    
		    cStr += aDadosP[nX][1]+aDadosP[nX][2]+aDadosP[nX][4]+aDadosP[nX][5]+"/"		
		Else
	    	cStr += aDadosP[nX][1]+"/"
	    EndIf	
	Next
	If nID == BRWCLIENTE
		oBrowse:AddFilter("Default", "A1_COD $ '"+cStr+"'",,.T.,,,,'A1FILTER')
		oBrowse:ExecuteFilter()
		
	ElseIf nID == BRWCTRMANU
		oBrowse:AddFilter("Default", "AAH_CONTRT $ '"+cStr+"'",,.T.,,,,'AAHFILTER')
		oBrowse:ExecuteFilter()
		
	ElseIf nID == BRWCTRSERV
		oBrowse:AddFilter("Default", "AAM_CONTRT $ '"+cStr+"'",,.T.,,,,'AAMFILTER')
		oBrowse:ExecuteFilter()
		
	ElseIf nID == BRWBASEATD
		oBrowse:AddFilter("Default", "AA3_CODPRO+AA3_NUMSER+AA3_CODCLI+AA3_LOJA $ '"+cStr+"'",,.T.,,,,'AA3FILTER')
		oBrowse:ExecuteFilter()
		
	EndIf
EndIf

//add menu no contrato de manutencao para abrir tela de detalhes
If cMenuDef == "TECA200"
	oBrowse:AddButton(STR0012, {|| At201Click(3)})//"Ver Detalhes"
EndIf

If ExistBlock('AT201BTN')
	If nID == BRWCTRMANU	
		cContrAux := AAH->AAH_CONTRT
	ElseIf nID == BRWCTRSERV	
		cContrAux := AAM->AAM_CONTRT
	EndIf	

	aBtnBrw := ExecBlock("AT201BTN",.F.,.F.,{nID,cContrAux})
	If ValType( aBtnBrw ) == "A"
		For nIndex :=1 To Len(aBtnBrw) 
			oBrowse:AddButton(aBtnBrw[nIndex][1],aBtnBrw[nIndex][2])
		Next nIndex
	EndIf
EndIf


oBrowse:SetMenuDef(cMenuDef)
oBrowse:Activate() 

 //bloco de codigo para duplo click - ficar após o activate, senao o FWMBrowse ira sobreescrever com o bloco padrao
oBrowse:BlDblClick := {||At201FtBrw(aBrowses,nID) , At201FtBrw(aBrowses,nID)} //workaround (filtrar 2x para contornar bug que perde na primeira vez)

aBrowses[nID] := oBrowse 	//joga o browse criado para o Array (precisa criar primeiro o objeto para depois jogar a referencia no array)


Return

//--------------------------------------------------------------------------------
/*/{Protheus.doc} At201FtBrw()

Filtra os browses da tela em relacao ao registro selecionado de um determinado browse

@param aBrowses, array, Lista de Browses da tela 
@param nID, numerico, ID do Browse que esta selecionando

@return Nenhum

@author Vendas CRM
@since 24/01/13
/*/
//--------------------------------------------------------------------------------
Function At201FtBrw(aBrowses, nID)
Local cFiltro 	:= "" 
Local nSA1_AAH		:= 0
Local nSA1_AAM		:= 0
Local nSA1_AA3		:= 0
Local nAAH_AAM		:= 0
Local nAAH_AA3		:= 0
Local nAAM_AA3		:= 0

//Verifica qual a filial entre as tabelas com a menor quantidade de caracteres (a mais compartilhada)
nSA1_AAH := At201FilMin("SA1", "AAH")
nSA1_AAM := At201FilMin("SA1", "AAM")
nSA1_AA3 := At201FilMin("SA1", "AA3")
nAAH_AAM := At201FilMin("AAH", "AAM")
nAAH_AA3 := At201FilMin("AAH", "AA3")
nAAM_AA3 := At201FilMin("AAM", "AA3")

//------------------------------------------------------------
//Filtro de filial: Pegar a menor qtde de caracteres entre
// as duas tabelas e filtrar a filial dando um substr com 
// essa qtde (a mais reduzida). Dessa forma sera filtrado
//------------------------------------------------------------

If nID == BRWCLIENTE //Quando selecionar um registro no browse de clientes, filtra os outros browses

	cFiltro := "AAH_CODCLI == '" + SA1->A1_COD + "' .AND. AAH_LOJA == '" + SA1->A1_LOJA + "'"
	If aBrowses[BRWCTRMANU]:oFwFilter:FILTEREXISTS('AAHFILTER')
		aBrowses[BRWCTRMANU]:oFwFilter:DELETEFILTER('AAHFILTER')
		aBrowses[BRWCTRMANU]:AddFilter( "Default", At201Filial(cFiltro, "AAH_FILIAL", SA1->A1_FILIAL, nSA1_AAH),,.T.,,,,'AAHFILTER' )
		aBrowses[BRWCTRMANU]:oFwFilter:ExecuteFilter()
	Else
		aBrowses[BRWCTRMANU]:AddFilter( "Default", At201Filial(cFiltro, "AAH_FILIAL", SA1->A1_FILIAL, nSA1_AAH),,.T.,,,,'AAHFILTER' )
		aBrowses[BRWCTRMANU]:oFwFilter:ExecuteFilter()
	EndIf
	
	cFiltro := "AAM_CODCLI == '" + SA1->A1_COD + "' .AND. AAM_LOJA == '" + SA1->A1_LOJA + "'"
	If aBrowses[BRWCTRSERV]:oFwFilter:FILTEREXISTS('AAMFILTER')
		aBrowses[BRWCTRSERV]:oFwFilter:DELETEFILTER('AAMFILTER')
		aBrowses[BRWCTRSERV]:AddFilter( "Default", At201Filial(cFiltro, "AAM_FILIAL", SA1->A1_FILIAL, nSA1_AAM),,.T.,,,,'AAMFILTER' )
		aBrowses[BRWCTRSERV]:oFwFilter:ExecuteFilter()
	Else
		aBrowses[BRWCTRSERV]:AddFilter( "Default", At201Filial(cFiltro, "AAM_FILIAL", SA1->A1_FILIAL, nSA1_AAM),,.T.,,,,'AAMFILTER' )
		aBrowses[BRWCTRSERV]:oFwFilter:ExecuteFilter()
	EndIf
	
	cFiltro := "AA3_CODCLI == '" + SA1->A1_COD + "' .AND. AA3_LOJA == '" + SA1->A1_LOJA + "'"
	If aBrowses[BRWBASEATD]:oFwFilter:FILTEREXISTS('AA3FILTER')
		aBrowses[BRWBASEATD]:oFwFilter:DELETEFILTER('AA3FILTER')
		aBrowses[BRWBASEATD]:AddFilter( "Default", At201Filial(cFiltro, "AA3_FILIAL", SA1->A1_FILIAL, nSA1_AA3),,.T.,,,,'AA3FILTER')
		aBrowses[BRWBASEATD]:oFwFilter:ExecuteFilter()
	Else
		aBrowses[BRWBASEATD]:AddFilter( "Default", At201Filial(cFiltro, "AA3_FILIAL", SA1->A1_FILIAL, nSA1_AA3),,.T.,,,,'AA3FILTER')
		aBrowses[BRWBASEATD]:oFwFilter:ExecuteFilter()
	EndIf
	
ElseIf nID == BRWCTRMANU //Quando selecionar um registro no browse de clientes, filtra os outros browses
	
	cFiltro := "A1_COD == '" + AAH->AAH_CODCLI + "' .AND. A1_LOJA == '" + AAH->AAH_LOJA + "'"
	If aBrowses[BRWCLIENTE]:oFwFilter:FILTEREXISTS('A1FILTER')
		aBrowses[BRWCLIENTE]:oFwFilter:DELETEFILTER('A1FILTER')
		aBrowses[BRWCLIENTE]:AddFilter( "Default", At201Filial(cFiltro, "A1_FILIAL", AAH->AAH_FILIAL, nSA1_AAH),,.T.,,,,'A1FILTER' )
		aBrowses[BRWCLIENTE]:oFwFilter:ExecuteFilter()
	Else
		aBrowses[BRWCLIENTE]:AddFilter( "Default", At201Filial(cFiltro, "A1_FILIAL", AAH->AAH_FILIAL, nSA1_AAH),,.T.,,,,'A1FILTER' )
		aBrowses[BRWCLIENTE]:oFwFilter:ExecuteFilter()
	EndIf
	
	cFiltro := "AAM_PROPOS == '" + AAH->AAH_PROPOS + "' .AND. AAM_REVPRO == '" + AAH->AAH_REVPRO + "'" + " .AND. !Empty(AAM_PROPOS) .AND.  !Empty(AAM_REVPRO)"
	If aBrowses[BRWCTRSERV]:oFwFilter:FILTEREXISTS('AAMFILTER')
		aBrowses[BRWCTRSERV]:oFwFilter:DELETEFILTER('AAMFILTER')
		aBrowses[BRWCTRSERV]:AddFilter( "Default", At201Filial(cFiltro, "AAM_FILIAL", AAH->AAH_FILIAL, nAAH_AAM),,.T.,,,,'AAMFILTER' )
		aBrowses[BRWCTRSERV]:oFwFilter:ExecuteFilter()
	Else
		aBrowses[BRWCTRSERV]:AddFilter( "Default", At201Filial(cFiltro, "AAM_FILIAL", AAH->AAH_FILIAL, nAAH_AAM),,.T.,,,,'AAMFILTER' )
		aBrowses[BRWCTRSERV]:oFwFilter:ExecuteFilter()
	EndIf
	
	cFiltro := "AA3_CONTRT == '" + AAH->AAH_CONTRT + "'"
	
	If aBrowses[BRWBASEATD]:oFwFilter:FILTEREXISTS('AA3FILTER')
		aBrowses[BRWBASEATD]:oFwFilter:DELETEFILTER('AA3FILTER')
		aBrowses[BRWBASEATD]:AddFilter( "Default", At201Filial(cFiltro, "AA3_FILIAL", AAH->AAH_FILIAL, nAAH_AA3),,.T.,,,,'AA3FILTER' )
		aBrowses[BRWBASEATD]:oFwFilter:ExecuteFilter()
	Else
		aBrowses[BRWBASEATD]:AddFilter( "Default", At201Filial(cFiltro, "AA3_FILIAL", AAH->AAH_FILIAL, nAAH_AA3),,.T.,,,,'AA3FILTER' )
		aBrowses[BRWBASEATD]:oFwFilter:ExecuteFilter()
	EndIf
	
ElseIf nID == BRWCTRSERV //Quando selecionar um registro no browse de clientes, filtra os outros browses
	
	cFiltro := "AAH_PROPOS == '" + AAM->AAM_PROPOS + "' .AND. AAH_REVPRO == '" + AAM->AAM_REVPRO + "'" + " .AND. !Empty(AAH_PROPOS) .AND.  !Empty(AAH_REVPRO)"
	If aBrowses[BRWCTRMANU]:oFwFilter:FILTEREXISTS('AAHFILTER')
		aBrowses[BRWCTRMANU]:oFwFilter:DELETEFILTER('AAHFILTER')
		aBrowses[BRWCTRMANU]:AddFilter( "Default", At201Filial(cFiltro, "AAH_FILIAL", AAM->AAM_FILIAL, nAAH_AAM),,.T.,,,,'AAHFILTER' )
		aBrowses[BRWCTRMANU]:oFwFilter:ExecuteFilter()
	Else
		aBrowses[BRWCTRMANU]:AddFilter( "Default", At201Filial(cFiltro, "AAH_FILIAL", AAM->AAM_FILIAL, nAAH_AAM),,.T.,,,,'AAHFILTER' )
		aBrowses[BRWCTRMANU]:oFwFilter:ExecuteFilter()
	EndIf
	
	cFiltro := "A1_COD == '" + AAM->AAM_CODCLI + "' .AND. A1_LOJA == '" + AAM->AAM_LOJA + "'"	
	If aBrowses[BRWCLIENTE]:oFwFilter:FILTEREXISTS('A1FILTER')
		aBrowses[BRWCLIENTE]:oFwFilter:DELETEFILTER('A1FILTER')
		aBrowses[BRWCLIENTE]:AddFilter( "Default", At201Filial(cFiltro, "A1_FILIAL", AAM->AAM_FILIAL, nSA1_AAM),,.T.,,,,'A1FILTER' )
		aBrowses[BRWCLIENTE]:oFwFilter:ExecuteFilter()
	Else
		aBrowses[BRWCLIENTE]:AddFilter( "Default", At201Filial(cFiltro, "A1_FILIAL", AAM->AAM_FILIAL, nSA1_AAM),,.T.,,,,'A1FILTER' )
		aBrowses[BRWCLIENTE]:oFwFilter:ExecuteFilter()
	EndIf
	
	cFiltro := "AA3_CONTRT == '" + AAM->AAM_CONTRT + "'"
	If aBrowses[BRWBASEATD]:oFwFilter:FILTEREXISTS('AA3FILTER')
		aBrowses[BRWBASEATD]:oFwFilter:DELETEFILTER('AA3FILTER')
		aBrowses[BRWBASEATD]:AddFilter( "Default", At201Filial(cFiltro, "AA3_FILIAL", AAM->AAM_FILIAL, nAAM_AA3),,.T.,,,,'AA3FILTER' )
		aBrowses[BRWBASEATD]:oFwFilter:ExecuteFilter()
	Else
		aBrowses[BRWBASEATD]:AddFilter( "Default", At201Filial(cFiltro, "AA3_FILIAL", AAM->AAM_FILIAL, nAAM_AA3),,.T.,,,,'AA3FILTER' )
		aBrowses[BRWBASEATD]:oFwFilter:ExecuteFilter()
	EndIf
ElseIf nID == BRWBASEATD //Quando selecionar um registro no browse de clientes, filtra os outros browses
	
	cFiltro := "AAH_CONTRT == '" + AA3->AA3_CONTRT + "'"
	If aBrowses[BRWCTRMANU]:oFwFilter:FILTEREXISTS('AAHFILTER')
		aBrowses[BRWCTRMANU]:oFwFilter:DELETEFILTER('AAHFILTER')
		aBrowses[BRWCTRMANU]:AddFilter( "Default", At201Filial(cFiltro, "AAH_FILIAL", AA3->AA3_FILIAL, nAAH_AA3),,.T.,,,,'AAHFILTER' )
		aBrowses[BRWCTRMANU]:oFwFilter:ExecuteFilter()
	Else
		aBrowses[BRWCTRMANU]:AddFilter( "Default", At201Filial(cFiltro, "AAH_FILIAL", AA3->AA3_FILIAL, nAAH_AA3),,.T.,,,,'AAHFILTER' )
		aBrowses[BRWCTRMANU]:oFwFilter:ExecuteFilter()
	EndIf
	
	cFiltro := "AAM_CONTRT == '" + AA3->AA3_CONTRT + "'"
	If aBrowses[BRWCTRSERV]:oFwFilter:FILTEREXISTS('AAMFILTER')
		aBrowses[BRWCTRSERV]:oFwFilter:DELETEFILTER('AAMFILTER')
		aBrowses[BRWCTRSERV]:AddFilter( "Default", At201Filial(cFiltro, "AAM_FILIAL", AA3->AA3_FILIAL, nAAM_AA3),,.T.,,,,'AAMFILTER' )
		aBrowses[BRWCTRSERV]:oFwFilter:ExecuteFilter()
	Else
		aBrowses[BRWCTRSERV]:AddFilter( "Default", At201Filial(cFiltro, "AAM_FILIAL", AA3->AA3_FILIAL, nAAM_AA3),,.T.,,,,'AAMFILTER' )
		aBrowses[BRWCTRSERV]:oFwFilter:ExecuteFilter()
	EndIf
	
	cFiltro := "A1_COD == '" + AA3->AA3_CODCLI + "' .AND. A1_LOJA == '" + AA3->AA3_LOJA + "'" 
	If aBrowses[BRWCLIENTE]:oFwFilter:FILTEREXISTS('A1FILTER')
		aBrowses[BRWCLIENTE]:oFwFilter:DELETEFILTER('A1FILTER')
		aBrowses[BRWCLIENTE]:AddFilter( "Default", At201Filial(cFiltro, "A1_FILIAL", AA3->AA3_FILIAL, nSA1_AA3),,.T.,,,,'A1FILTER' )
		aBrowses[BRWCLIENTE]:oFwFilter:ExecuteFilter()
	Else
		aBrowses[BRWCLIENTE]:AddFilter( "Default", At201Filial(cFiltro, "A1_FILIAL", AA3->AA3_FILIAL, nSA1_AA3),,.T.,,,,'A1FILTER' )
		aBrowses[BRWCLIENTE]:oFwFilter:ExecuteFilter()
	EndIf
	
EndIf

Return .T.


//--------------------------------------------------------------------------------
/*/{Protheus.doc} At201FilMin()

Funcao auxiliar para filtro entre browses - compara a qtde de caracteres do
campo filial de duas tabelas (determinando o nivel de compartilhamento) e retorna
o menor numero

@param cTab1, caractere, tabela 1
@param cTab2, caractere, tabela 2

@return numerico Qtde de caracteres da menor filial

@author Vendas CRM
@since 24/01/13
/*/
//--------------------------------------------------------------------------------
Function At201FilMin(cTab1, cTab2)

Local nQtdFil1 := Len(Trim(xFilial(cTab1)))
Local nQtdFil2 := Len(Trim(xFilial(cTab2)))

Return IIf( nQtdFil1 < nQtdFil2, nQtdFil1 , nQtdFil2 )


//--------------------------------------------------------------------------------
/*/{Protheus.doc} At201Filial()

Funcao auxiliar para filtro entre browses - Trata filtro para incluir a filial

@param cFiltro, caractere, filtro padrao (o filtro criado sera concatenado apos esse filtro padrao)
@param cCampoFil, caractere, campo de filial a ser filtrado (campo do browse a ser filtrado)
@param cValFil, caractere, valor da filial (valor do browse selecionado)
@param nQtdFil, caractere, Qtde de caracteres a considerar do campo de filial

@return nenhum

@author Vendas CRM
@since 24/01/13
/*/
//--------------------------------------------------------------------------------
Function At201Filial(cFiltro, cCampoFil, cValFil, nQtdFil)
Local cFiltroRet := ""
cFiltroRet := cFiltro + " .AND. (SUBSTR(" + cCampoFil + ",1," + cValToChar(nQtdFil) + " ) == '" + SUBSTR(cValFil,1,nQtdFil) + "')"  
Return cFiltroRet


//--------------------------------------------------------------------------------
/*/{Protheus.doc} At201FtDetBrw()

Filtra os browses da tela de detalhe em relacao a um browse selecionado

@param aBrowsesDet, array, Lista de browses da tela de detalhe
@param nID, numerico, ID de identificação do browse que foi selecionado

@return nenhum

@author Vendas CRM
@since 24/01/13
/*/
//--------------------------------------------------------------------------------
Function At201FtDetBrw(aBrowsesDet, nID)

If nID == BRWORDEMSERV
	//Quando selecionar um registro no browse de clientes, filtra os outros browses
	aBrowsesDet[BRWATENDOS]:AddFilter( "Default", " '" + AB6->AB6_NUMOS +  "' $ AB9_NUMOS .AND. !Empty(AB9_CONTRT) ",,.T.)
	aBrowsesDet[BRWATENDOS]:oFwFilter:ExecuteFilter()
EndIf

Return .T.


//--------------------------------------------------------------------------------
/*/{Protheus.doc} At201LimpFil()

Limpa filtros da tela principal

@param aBrowses, array, Lista de browses da tela principal

@return nenhum

@author Vendas CRM
@since 24/01/13
/*/
//--------------------------------------------------------------------------------
Function At201LimpFil(aBrowses,aDadosP)

Local nI 	:= 0
Local cStr	:= ""

For nI := 1 to Len(aBrowses)
	If !Empty(aBrowses[nI])
		aBrowses[nI]:oFwFilter:CleanFilter()
		aBrowses[nI]:oFwFilter:ExecuteFilter()
		 If !Empty(aDadosP)
			If nI == BRWCLIENTE      
				 cStr := At201GetPerm(aDadosP[PERCLIENTE])
				 aBrowses[nI]:AddFilter("Default", "A1_COD $ '"+cStr+"'",,.T.,,,,'A1FILTER') 
				 aBrowses[nI]:oFwFilter:ExecuteFilter()
			ElseIf nI == BRWCTRMANU
				 cStr := At201GetPerm(aDadosP[PERCTRMANU])		
				 aBrowses[nI]:AddFilter("Default", "AAH_CONTRT $ '"+cStr+"'",,.T.,,,,'AAHFILTER')
			 	 aBrowses[nI]:oFwFilter:ExecuteFilter()
			ElseIf nI == BRWCTRSERV
				 cStr := At201GetPerm(aDadosP[PERCTRSERV])				
				 aBrowses[nI]:AddFilter("Default", "AAM_CONTRT $ '"+cStr+"'",,.T.,,,,'AAMFILTER')
				 aBrowses[nI]:oFwFilter:ExecuteFilter()
			ElseIf nI == BRWBASEATD                     
				 cStr := At201GetPerm(aDadosP[PERBASEATD],PERBASEATD)		
				 aBrowses[nI]:AddFilter("Default", "AA3_CODPRO+AA3_NUMSER+AA3_CODCLI+AA3_LOJA $ '"+cStr+"'",,.T.,,,,'AA3FILTER') 
				 aBrowses[nI]:oFwFilter:ExecuteFilter()
			EndIf	
		EndIf
	EndIf
Next nI

Return

//--------------------------------------------------------------------------------
/*/{Protheus.doc} At201GetPerm()

Busca das permissões para reorganizar filtro

@param aDadosP, array, dados da permissão

@return cStr, string com os dados referentes ao array

@author Vendas CRM
@since 24/01/13
/*/
//--------------------------------------------------------------------------------
Function At201GetPerm(aDadosP,nI)

Local cStr	:= ''
Local nX	:= 1                                                
Default nI	:=0

If !Empty(aDadosP)
	For nX := 1 To Len(aDadosP)
		If nI == PERBASEATD    
		    cStr += aDadosP[nX][1]+aDadosP[nX][2]+aDadosP[nX][4]+aDadosP[nX][5]+"/"		
		Else
		    cStr += aDadosP[nX][1]+"/"
		EndIf
	Next
EndIf             

Return cStr


//--------------------------------------------------------------------------------
/*/{Protheus.doc} At201Click()

Centralizador das chamadas dos cliques dos botoes da tela principal

@param aBrowses, array, Lista de browses da tela principal

@return nenhum

@author Vendas CRM
@since 24/01/13
/*/
//--------------------------------------------------------------------------------
Function At201Click(nBtn, xParam1 ,xParam2)

Local aArea := GetArea()
Local aAreaAAH := AAH->(GetArea())
Local lExecPerg := VALTYPE(lChkCli) == 'L' .AND. lChkCli

If nBtn == 1
	At201LimpFil(xParam1,xParam2) //xParam1 = aBrowses
ElseIf nBtn == 2
	cNumOs := ""
	If !Empty(AAH->AAH_CONTRT)
		TECA510(cNumOs,"",AAH->AAH_CONTRT,lExecPerg)
	Else
		MsgAlert(STR0013)//"Nenhum contrato de manutenção foi selecionado"
	EndIf
ElseIf nBtn == 3
	If !Empty(AAH->AAH_CONTRT)
		At201DetShow(AAH->AAH_CONTRT)
	Else
		MsgAlert(STR0013)//"Nenhum contrato de manutenção foi selecionado"
	EndIf
EndIf
                        
RestArea(aArea)
RestArea(aAreaAAH)

Return



//--------------------------------------------------------------------------------
/*/{Protheus.doc} At201DetShow()

Exibe tela de detalhe do contrato de manutenção selecionado

@param cCodContrt, caractere, codigo do contrato de manutencao

@return nenhum

@author Vendas CRM
@since 24/01/13
/*/
//--------------------------------------------------------------------------------
Function At201DetShow(cCodContrt)

Local oPanel 		:= Nil	//tela principal
Local oFWLayer	:= Nil	//organizador de janelas
Local aCoors		:= FWGetDialogSize(oMainWnd)	

//objetos dos pedacos da tela
Local oOrdemServ	:= Nil
Local oAtendOS	:= Nil
Local oGrupoCob	:= Nil
Local oAlocContr	:= Nil

Local oBtnsair	:= Nil
Local oButEnd		:= Nil

//workaround para nao criar objetos privates e passar todos os browses para a funcao que executa os filtros 
Local aBrowsesDet 	:= Array(50)
Local nValMaxApont	:= Posicione( "AAH", 1, xFilial("AAH") + cCodContrt, "AAH_VALMAX" )


//----------------------------------------------------------------------
// Privates obrigatorias para funcionar rotinas padroes dos browses
//----------------------------------------------------------------------
Private aRotina 					
Private aRotAuto 	
Private cCadastro
Private L460AUTO

Private bFiltraBrw 	:= {|| Nil}                                
Private aAutoCab		:= {}			// Cabeçalho da rotina automático
Private aAutoItens		:= {}			// Itens da rotina automática
Private aAutoGrupo		:= {}			// Itens da rotina automática


DEFINE MSDIALOG oPanel TITLE STR0014 + cCodContrt FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] PIXEL STYLE WS_DLGFRAME //"Detalhes - Contrato Manutenção "


//--------------------------------
// Configura o FWLayer
//--------------------------------
oFWLayer := FWLayer():New()
oFWLayer:Init( oPanel, .F.)

//--------------------------------
// Cria colunas
//--------------------------------
oFWLayer:AddLine( 'Linha 1', 50, .F. ) 
oFWLayer:AddCollumn("Coluna 1", 50, .F., 'Linha 1')
oFWLayer:AddCollumn("Coluna 2", 50, .F., 'Linha 1')

oFWLayer:AddLine( 'Linha 2', 46, .F. ) 
oFWLayer:AddCollumn("Coluna 1", 50, .F., 'Linha 2')
oFWLayer:AddCollumn("Coluna 2", 50, .F., 'Linha 2')

oFWLayer:AddLine( 'Linha 3', 4, .F. ) 
oFWLayer:AddCollumn("Coluna 1", 100, .F., 'Linha 3')

//------------------------------------------
// Associa objetos com os pedacos da tela
//------------------------------------------
oGrupoCob		:= oFWLayer:GetColPanel( "Coluna 1", 'Linha 1' )
oAlocContr 	:= oFWLayer:GetColPanel( "Coluna 2", 'Linha 1' )
oOrdemServ 	:= oFWLayer:GetColPanel( "Coluna 1", 'Linha 2' )
oAtendOS		:= oFWLayer:GetColPanel( "Coluna 2", 'Linha 2' )
	
oBtnsair := oFWLayer:GetColPanel( "Coluna 1", 'Linha 3' )

//--------------------------------
// Inclui os Browses e janelas
//--------------------------------
At201Brw(aBrowsesDet, BRWORDEMSERV, oOrdemServ, STR0015, "AB6", "TECA450")//"Ordem de Serviço"
At201Brw(aBrowsesDet, BRWGRUPOCOB, oGrupoCob, STR0016 + LTrim(STR(nValMaxApont,,2)), "AAR", "")//"Saldos do Grupo de Cobertura     |     Valor máximo para apontamento: R$"
At201Brw(aBrowsesDet, BRWATENDOS, oAtendOS, STR0017, "AB9", "TECA460")//"Atendimento da O.S."
At201Brw(aBrowsesDet, BRWALOCCTR, oAlocContr, STR0018, "ABQ", "")//"Configuração de Alocação"

//Cria o botão de Fechar
@ 003, 460 Button oButEnd Prompt STR0021 Size 060,012 Pixel Of oBtnsair Action oPanel:End()		//"Fechar"
oButEnd:Align    := CONTROL_ALIGN_RIGHT

//----------------------------------------------------------------------------
// Define filtros iniciais
// OBS: workaround (filtrar 2x para contornar bug que perde na primeira vez)
//----------------------------------------------------------------------------

aBrowsesDet[BRWORDEMSERV]:AddFilter("Default", "AB6_CONTRT == '" + cCodContrt + "'",,.T.)      //filtra grid de O.S.
aBrowsesDet[BRWORDEMSERV]:AddFilter("Default", "AB6_CONTRT == '" + cCodContrt + "'",,.T.) 		//filtra grid de O.S.

aBrowsesDet[BRWGRUPOCOB]:AddFilter("Default", "AAR_CONTRT == '" + cCodContrt + "'",,.T.) 		//filtra grid de Saldos do Grupo de Cobertura do Contrato
aBrowsesDet[BRWALOCCTR]:AddFilter("Default", "ABQ_CONTRT == '" + cCodContrt + "'",,.T.) 		//filtra grid de Alocacao do contrato

At201FtDetBrw(aBrowsesDet, BRWORDEMSERV) //Filtra grids relacionados às O.S.
At201FtDetBrw(aBrowsesDet, BRWORDEMSERV) //Filtra grids relacionados às O.S.

//---------------------------------------
// Altera o comportamento do click duplo
//---------------------------------------
At201AltBrwDet(aBrowsesDet, cCodContrt) //altera bloco para filtro nos grids

ACTIVATE MSDIALOG oPanel CENTERED


Return

//--------------------------------------------------------------------------------
/*/{Protheus.doc} At201AltBrwDet()

Funcao auxiliar para alterar a acao no duplo click dos browses da tela de detalhe

@param aBrowsesDet, array, lista de browses da tela de detalhe

@return nenhum

@author Vendas CRM
@since 24/01/13
/*/
//--------------------------------------------------------------------------------
Function At201AltBrwDet(aBrowsesDet)
Local nI := 0

//Altera o bloco de codigo do duplo click do browse 
For nI := 1 to Len(aBrowsesDet)
	If !Empty(aBrowsesDet[nI])
		If nI == BRWORDEMSERV
			aBrowsesDet[nI]:BlDblClick := {||At201FtDetBrw(aBrowsesDet,BRWORDEMSERV)} //filtra detalhe no browse de OS
		Else
			aBrowsesDet[nI]:BlDblClick := {||} //Nao faz nada no duplo click dos outros browses
		EndIf
	EndIf
Next nI

Return

//--------------------------------------------------------------------------------
/*/{Protheus.doc} At201Perm()

Funcao para retornar entidades de acesso

@return aPermissao

@author Totvs
@since 10/04/13
/*/
//--------------------------------------------------------------------------------
Function At201Perm()

Local aAreaAA1	:= AA1->(GetArea())
Local aContr	:= {}
Local aCli		:= {}
Local aBsAtend	:= {}
Local aContrSv	:= {}
Local aEquip	:= {}
Local aPermissao:= {}
Local cAteTec	:= ""
Local cAtend	:= "" 
Local nY
Local nZ
Local nPos	:=0

DbSelectArea("AA1")
AA1->(DbSetorder(4)) //AA1_FILIAL+AA1_CODUSR

If AA1->(DbSeek(xFilial("AA1")+__cUserId))
	
	cAtend := AA1->AA1_CODTEC
	
	DbSelectArea("AAZ")
	AAZ->(DbSetOrder(1)) //AAZ_FILIAL+AAZ_CODTEC
	If AAZ->(DbSeek(XFilial("AAZ")+cAtend))
		cAteTec := XFilial("AAZ")+cAtend
		While( AAZ->(!EOF()) .AND. cAteTec == AAZ->(AAZ_FILIAL+AAZ_CODTEC))
			AADD(aContr,{AAZ_CONTRT,AAZ_TPPERM,AAZ_TPCONT})
			AAZ->(DbSKip())
		End
	EndIf

	
	For nY := 1 To Len(aContr)
		
		If aContr[nY][3] == "1"
		
			DbSelectArea("AAH")
			AAH->(DbSetOrder(1)) //AAH_FILIAL+AAH_AAH_CONTRT
			If AAH->(DbSeek(xFilial("AAH")+aContr[nY][1]))
			    cCli := AAH->(AAH_CODCLI) 
			    nPos := aScan(aCli,{|aCli| aCli[1]==cCli})
			    If nPos == 0
					AADD(aCli,{AAH_CODCLI,AAH_LOJA,aContr[nY][1],aContr[nY][3]})
				EndIf
			EndIf
					
			DbSelectArea("AA3")
			AA3->(DbSetOrder(2)) //AA3_FILIAL+AA3_CONTRT
			If AA3->(DbSeek(xFilial("AA3")+aContr[nY][1]))
				AADD(aBsAtend,{AA3_CODPRO,AA3_NUMSER,aContr[nY][1],AA3_CODCLI,AA3_LOJA})
			EndIf
			
		ElseIf aContr[nY][3] == "2"
		
			DbSelectArea("CN9")
			CN9->(DbSetOrder(1))  //CN9_FILIAL+CN9_NUMERO
			If CN9->(DbSeek(xFilial("CN9")+aContr[nY][1]))
				DbSelectArea("CNC")
				CNC->(DbSetOrder(3)) //CNC_FILIAL+CNC_NUMERO+CNC_REVISA
				If CNC->(DbSeek(xFilial("CNC")+aContr[nY][1]+CN9->CN9_REVATU)) 
					cCli := CNC->(CNC_CLIENT)
					nPos := aScan(aCli,{|aCli| aCli[1]==cCli})
					If nPos == 0
						AADD(aCli,{CNC_CLIENT,CNC_LOJACL,aContr[nY][1],aContr[nY][3]})
					EndIf
				EndIf	
			Endif		
		
		EndIf	
		
	Next
	
	For nZ := 1 To Len(aCli) 
	
		If aCli[nZ][4] == "1"	
			DbSelectArea("AAM")
			AAM->(DbSetOrder(2)) //AAM_FILIAL+AAM_CODCLI+AAM_LOJA
			If AAM->(DbSeek(xFilial("AAM")+aCli[nZ][1]+aCli[nZ][2]))
				cContrS := xFilial("AAM")+aCli[nZ][1]+aCli[nZ][2]
				While AAM->(!EOF()) .AND. cContrS == AAM->(AAM_FILIAL+AAM_CODCLI+AAM_LOJA)
					AADD(aContrSv,{AAM_CONTRT})
				AAM->(DbSkip())
				End	
			EndIf
		EndIf
	
	Next
	
	If !Empty(aCli)	.OR. !Empty(aContr)	.OR. !Empty(aBsAtend) .OR. !Empty(aContrSv)
		AADD(aPermissao,{aCli,aContr,aBsAtend,aContrSv})
	EndIf
	
EndIf

RestArea(aAreaAA1)

Return aPermissao

/*/{Protheus.doc} At201Exit()
	Executa o fechamento da janela e elimina as variáveis de interface de memórias 

@param oDlg, Objeto, objeto da classe MSDIALOG para ser encerrado
@since 10/04/13
/*/
Function At201Exit( oDlg )

oDlg:End()
oDlg := Nil
DelClassIntF()

Return
