#INCLUDE "TMKA061.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "TMKDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"  
#INCLUDE "TBICONN.CH"
#INCLUDE "CRMDEF.CH"

STATIC cEntAlias // Armazena alias para validacoes de campo.
STATIC cEntidade	:= "SA1"	// Alias da entidade selecionada para gerar a lista - o Default sera Cadastro de Clientes
STATIC cTempTab		:= ""

/*
	Array aAutoCab - Estrutura do SU4 para rotinas automaticas
	ÚÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³01³ U4_FILIAL    ³ Filial  							  									         ³
	³02³ U4_LISTA     ³ Codigo sequencial da lista                   									 ³
	³03³ U4_DESC      ³ Descricao da lista                           									 ³
	³04³ U4_DATA      ³ Data de vigencia   										                       	 ³
	³05³ U4_TIPO      ³ Tipo de lista(1-Marketing / 2-Cobranca / 3- Vendas)                              ³ 
	³06³ U4_FORMA     ³ Tipo de Contato (1-Voz/2-Fax/3-Cross Posting/4-Mala direta 5-Pendencia 6-WebSite)³
	³  ³              ³                                                                                  ³
	³07³ U4_TELE      ³ 1-Marketing/ 2-Vendas/ 3-Telecobranca/ 4-Ambos (Legado)- USO INTERNO-8.11³
	³  ³              ³                                                                                  ³
	³08³ U4_OPERAD    ³ Operador																		 ³
	³09³ U4_CONFIG    ³ Codigo da Configuracao Telemarketing											 ³
	³10³ U4_TIPOTEL	  ³ Tipo de telefone( 1-Residencial/ 2-Celular/ 3-Fax/ 4-Comercial 1/ 5- Comercial 2)³
	³11³ U4_MALADIR   ³ Arquivo de mala direta														   	 ³
	³12³ U4_TIPOEND   ³ Endereco para mala direta														 ³
	³13³ U4_LABEL     ³ Etiqueta (1-Sim / 2-Nao)  													   	 ³
	³14³ U4_ETIQUET   ³ Arquivo de Etiqueta															     ³
	³15³ U4_CODCAMP   ³ Codigo da campanha															     ³
	³16³ U4_SCRIPT    ³ Codigo do script 															     ³
	³17³ U4_EVENTO    ³ Codigo do evento 														     	 ³
	ÀÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	
	Array aAutoItens - Estrutura do SU6 para rotinas automaticas
	ÚÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³01³ U6_FILIAL    ³ Filial  							  	   ³
	³02³ U6_LISTA     ³ Codigo sequencial da lista                 ³
	³03³ U6_CODIGO    ³ Codigo da ligacao                          ³
	³04³ U6_FILENT    ³ Filial da entidade 					       ³
	³05³ U6_ENTIDA    ³ Entidade       						       ³
	³06³ U6_CODENT    ³ Codigo da entidade                         ³
	³07³ U6_ORIGEM    ³ Origem (1-Lista/ 2-Manual /3-Atendimento)  ³
	³08³ U6_CONTATO   ³ Contato								       ³
	³09³ U6_DATA      ³ Data                                       ³
	³10³ U6_HRINI     ³ Hora inicial                               ³
	³11³ U6_HRFIM     ³ Hora final                                 ³
	³12³ U6_STATUS    ³ Status(1-Nao enviado /2- Em uso/ 3-Enviado)³
	³13³ U6_CODLIG    ³ Codigo da ligacao efetuada                 ³
	ÀÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMKA061   ³ Autor ³ Vendas Clientes       ³ Data ³30.06.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³GERADOR DE LISTAS DE CONTATOS                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Campanhas, Agenda do Operador,Atendimento 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpX1: Array com as Informacoes do cabecalho da Lista.(     ³±±
±±³          ³		 Rotinas autimaticas) 								  								³±±
±±³          ³ExpX2: Array com as informacoes dos Itens da Lista.(        ³±±
±±³          ³		 Rotinas autimaticas) 								  								³±±
±±³          ³ExpN3: Opcao de menu enviada                 				  			³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tmka061(xAutoCab,xAutoItens,nOpcAuto, cFilDef, aAddFil, cVDefault)

Local aArea  	:= GetArea()				// Salva a area atual	
Local lRet   	:= .F. 						// Retorno da funcao
Local nX     	:= 0 						// Contador
Local nPos   	:= 0 
Local aPDFields	:= {} 
   						
// Variaveis de controle da rotina automatica
Private la061Auto  := (xAutoCab <> NIL  .AND. xAutoItens <> NIL)
Private aAutoCab   := {}
Private aAutoItens := {}
Private cCadastro  := ""
Private cMark      := GetMark()  

Default cFilDef    := ""
Default aAddFil    := {}
Default cVDefault  := ""

If nModulo <> 73 //SIGACRM
	cCadastro  := STR0013 //"Listas de Contato"
Else
	cCadastro  := STR0041 //"Listas de Marketing"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se e rotina automatica                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lA061Auto
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida array com os dados do cabecalho                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAutoCab := SU4->(MSArrayXDb(xAutoCab,,nOpcAuto))
	If ( Len(aAutoCab) == 0 )
		Return(lRet)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa a validacao dos itens.                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(xAutoItens)
		AAdd(aAutoItens,SU6->(MSArrayXDb(xAutoItens[nX],,nOpcAuto,.T.)))
		If Empty(aAutoItens[nX])
			Return(lRet)
		Endif
	Next nX
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa a opcao desejada do menu solicitada via rotina automatica      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SU4")
	nPos := Ascan(aRotina,{|x| x[4]== nOpcAuto})
	If ( nPos # 0 )
		bBlock := &( "{ |x,y,z,k| " + aRotina[ nPos,2 ] + "(x,y,z,k) }" )
		Eval( bBlock, Alias(), (Alias())->(Recno()),nPos)
	Endif

Else
	
	aPDFields := {"A1_NOME","U7_NOME"}
	FATPDLoad(Nil,Nil,aPDFields)  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa a MBrowse normal caso nao seja rotina automatica               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Protege rotina para que seja usada apenas no SIGATMK e SIGACRM
	If !AMIIn(13,73)			// 13 ‚ o SIGATMK // 73, SIGACRM
		Return(lRet)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectarea( "SU4" ) 
	
	//-------------------------------
	// Browse de Lista de Contatos
	//-------------------------------
	BrowseDef( /*oMBrowse*/, cFilDef, aAddFil, cVDefault ) 		  

	FATPDUnload()
	
Endif 

lRet := .T.


RestArea(aArea)   

Return (lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef

Browse de Lista de Contatos

@sample	BrowseDef( oMBrowse, cFilDef, aAddFil, cVDefault )

@param		oMBrowse	, Objeto	, Browse criado pelo Widget da Area de Trabalho.
			cFilDef	, Caracter	, Filtro padrao.
			aAddFil	, Array		, Filtros relacionados.
			cVDefault	, Caracter , Visao padrao.
			
@return	oMBrowse	, Objeto	, Retorna o objeto FWMBrowse.

@author	Anderson Silva
@since		05/12/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function BrowseDef( oMBrowse, cFilDef, aAddFil, cVDefault )
  						
Local oTableAtt	:= {}
Local lWidget 	:= .F.
Local nX		:= 0
Local aCores 	:= {} 
Local cCadastro := ""

Default oMBrowse	:= Nil
Default cFilDef		:= ""
Default aAddFil		:= {}
Default cVDefault	:= ""

If nModulo <> 73	
	aCores := {	{"SU4->U4_TIPO == '3'", "BR_VERDE"		, "Vendas"		},;		// Vendas     
   					{"SU4->U4_TIPO == '1'", "BR_AZUL" 		, "Marketing" 	},;		// Marketing   
   					{"SU4->U4_TIPO == '4'", "BR_BRANCO"   	, "Teleatendimento"},;	// Teleatendimento   						
   					{"SU4->U4_TIPO == '2'", "BR_VERMELHO"	, "Cobrança"}} 		// Cobranca 
	cCadastro  := STR0013 //"Listas de Contato"
	If Empty( cFilDef )
		cFilDef := " U4_ENTIDA = ' '"
	Else
		cFilDef += ".And.	U4_ENTIDA = ' '"
	EndIf
Else
	cCadastro  := STR0041 //"Listas de Marketing"	
EndIf

If Empty( oMBrowse )
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "SU4" )		
Else
	lWidget	:= .T.
EndIf	

oMBrowse:SetCanSaveArea(.T.) 

For nX := 1 To Len( aCores )
	oMBrowse:AddLegend( aCores[nX][1], aCores[nX][2], aCores[nX][3] )
Next nX 

If !Empty(cFilDef)
	oMBrowse:SetFilterDefault( cFilDef )
EndIf

For nX := 1 To Len(aAddFil)
	oMBrowse:DeleteFilter( aAddFil[nX][ADDFIL_ID] )
	oMBrowse:AddFilter( aAddFil[nX][ADDFIL_TITULO], ;
					      aAddFil[nX][ADDFIL_EXPR], ;
					      aAddFil[nX][ADDFIL_NOCHECK], ;
					      aAddFil[nX][ADDFIL_SELECTED], ; 
					      aAddFil[nX][ADDFIL_ALIAS], ;
					      aAddFil[nX][ADDFIL_FILASK], ;
					      aAddFil[nX][ADDFIL_FILPARSER], ;
					      aAddFil[nX][ADDFIL_ID] )		 
	oMBrowse:ExecuteFilter()	
Next nX		

oMBrowse:SetDescription( cCadastro )


If !lWidget
	oTableAtt 	:= TableAttDef()	
	oMBrowse:SetAttach( .T. )	
	oMBrowse:SetViewsDefault( oTableAtt:aViews )	
	// selecionando a visão inicial 
	If !Empty( cVDefault ) 
		nScan := aScan( oTableAtt:aViews, { |x| x:cID == cVDefault } )
		If nScan > 0 
			oMBrowse:SetIDViewDefault( oTableAtt:aViews[nScan]:cID )
		EndIf
	EndIf 
	// se for diferente do modulo CRM, então abre a tela com o grafico fechado
	If nModulo <> 73
		oMBrowse:SetOpenChart( .F. )
	EndIf
	oMBrowse:SetMainProc("TMKA061")
	oMBrowse:SetTotalDefault('U4_TIPO','COUNT',STR0055) //'Total de Registros'
	oMBrowse:Activate()
EndIf
		
Return Nil

//------------------------------------------------------------------------------
/*/	{Protheus.doc} TableAttDef

Cria as visões e gráficos padrões de Listas de Marketing.

@sample	TableAttDef()

@param		Nenhum

@return	ExpA - Array de Objetos com as Visoes.

@author	Cristiane Nishizaka
@since		02/06/2014
@version	12
/*/
//------------------------------------------------------------------------------
Static Function TableAttDef()

Local oTableAtt		:= FWTableAtt():New()
Local oDSMyLists		:= Nil // Minhas Listas de Marketing

// Tabela Listas de Marketing
oTableAtt:SetAlias("SU4")

If ( IsInCallStack("CRMA530") .Or. IsInCallStack("CRMA290") .Or. IsInCallStack("CRMA290A") .Or. IsInCallStack( "CRM290CWGT" ) )

	// Minhas Listas de Marketing
	oDSMyLists := FWDSView():New()
	oDSMyLists:SetName(STR0060) //"Minhas Listas de Marketing"
	oDSMyLists:SetID("DSMyLists") 
	oDSMyLists:SetOrder(1) // U4_FILIAL+U4_LISTA+DTOS(U4_DATA)
	oDSMyLists:SetCollumns({	"U4_FILIAL","U4_TIPO","U4_STATUS","U4_DESC",;
								"U4_DATA","U4_ORIGEM","U4_CUSTO","U4_DTUPD","U4_DTUTIL"})
	oDSMyLists:SetPublic(.T.)
	oDSMyLists:AddFilterRelation( "AO4", "AO4_CHVREG", "U4_FILIAL+U4_LISTA+U4_DATA" )
	oDSMyLists:AddFilter(STR0060, "AO4_ENTIDA='SU4' .AND. AO4_CODUSR == '"+RetCodUsr()+"' .AND. AO4_CTRLTT == .T.","AO4") //"Minhas Listas de Marketing"
	oTableAtt:AddView(oDSMyLists)

EndIf
	
Return(oTableAtt)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MenuDef	³ Autor ³ Fernando Amorim       ³ Data ³08/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de definição do aRotina                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRotina   retorna a array com lista de aRotina             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMK                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef() 

Local aRotina     :=	{}
Local aAtiv       := {}
Local aAnotac     := {}
Local aEntRelac   := {}
Local nPos        := 0

If nModulo <> 73 //SIGACRM
	aRotina :={	{ STR0002	,"AxPesqui"  	, 0 , 1 ,0 , .F.} ,;  	//"Pesquisar"
		   	 	{ STR0003	,"Tk061Tela" 	, 0 , 2 ,0 , .T.} ,;  	//"Visualizar"
		   	 	{ STR0004	,"Tk061Tela"	, 0 , 3 ,0 , .T.} ,;  	//"&Manual"
		   		{ STR0005	,"Tk061Tela"	, 0 , 3 ,0 , .T.} ,;  	//"Automatica"
		   		{ STR0006	,"Tk061Wizard"	, 0 , 3 ,0 , .T.} ,;  	//"Assiste&nte"
		   		{ STR0007	,"Tk061Altera"	, 0 , 4 ,0 , .T.} ,; 	//"A&lterar"
		   		{ STR0008	,"Tk061Exclui"  , 0 , 5 ,0 , .T.} ,; 	//"Excluir"
		   		{ STR0009	,"Tk061Imp"     , 0 , 4 ,0 , .T.} ,;	//"Imp&rimir"
			    { STR0010	,"Tk061Trans" 	, 0 , 4 ,0 , .T.} ,;	//"Transferencia"
		   		{ STR0011	,"Tk061Copy"  	, 0 , 3 ,0 , .T.} ,;	//"Copiar"
		   		{ STR0038	,"Tk061Legenda"	, 0 , 2 ,0 , .T.}  }	//"Legenda"

Else
	aRotina :={ { STR0002	,"AxPesqui"  	, 0 , 1 ,0 , .F.} ,;  	//"Pesquisar"
	 		    { STR0003	,"Tk061Tela" 	, 0 , 2 ,0 , .T.} ,;  	//"Visualizar"
				{ STR0047 	,"Tk061Tela"	, 0 , 3 , 0, .T.} ,;  	//"Incluir
				{ STR0007	,"Tk061Altera"	, 0 , 4 ,0 , .T.} ,; 	//"A&lterar"
				{ STR0008	,"Tk061Exclui"  , 0 , 5 ,0 , .T.} ,; 	//"Excluir"
				{ STR0009	,"Tk061Imp('SU4',SU4->(RecNo()),4)" 	, 0 , 4 ,0 , .T.} ,;		//"Imp&rimir"
				{ STR0011	,"Tk061Copy('SU4',SU4->(RecNo()),3)"  	, 0 , 3 ,0 , .T.}}		//"Copiar"
	
	Aadd(aEntRelac,{ STR0054	,"CRMA200('SU4')"		, 0 , 8 ,0 , .T.})//"Privilégios"
	Aadd(aEntRelac,{ STR0052	,"CRMA250()"		, 0 , 3 , 0, .T.})//Campanha Rápida
	
	aEntRelac := CRMXINCROT( "SU4", aEntRelac )	

	nPos := ASCAN(aEntRelac, { |x| IIF(ValType(x[2]) == "C", x[2] == "CRMA190Con()",Nil) })
	If nPos > 0 
		ADD OPTION aRotina TITLE aEntRelac[nPos][1] ACTION aEntRelac[nPos][2] OPERATION 8  ACCESS 0//"Conectar"
		Adel(aEntRelac,nPos)
		Asize(aEntRelac,Len(aEntRelac)-1)
	EndIf

	nPos := ASCAN(aEntRelac, { |x|  IIF(ValType(x[2]) == "C", x[2] == "CRMA180()", Nil) })
	If nPos > 0
		ADD OPTION aAtiv   TITLE STR0051  ACTION "CRMA180(,,,3,,)" OPERATION 3  ACCESS 0 //"Nova Atividade" 
		ADD OPTION aAtiv   TITLE STR0056 ACTION "CRMA180()" OPERATION 8  ACCESS 0 //"Todas as ATividades"
		aEntRelac[nPos][2] := aAtiv
	EndIf
	
	nPos := ASCAN(aEntRelac, { |x| IIF(ValType(x[2]) == "C", x[2] == "CRMA090()", Nil)})
	If nPos > 0
		ADD OPTION aAnotac   TITLE STR0057 ACTION "CRMA090(3)" OPERATION 3  ACCESS 0 //"Nova Anotação"
		ADD OPTION aAnotac   TITLE STR0058 ACTION "CRMA090()" OPERATION 8  ACCESS 0 //"Todas as Anotações" 
		aEntRelac[nPos][2] := aAnotac
		
	EndIf

	Asort(aEntRelac,,,{ | x,y | y[1] > x[1] } )
	ADD OPTION aRotina TITLE STR0059 ACTION aEntRelac OPERATION 8  ACCESS 0//"Relacionadas"
EndIf

Return( aRotina )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TK061Tela ³ Autor ³Rafael M. Quadrotti    ³ Data ³30.06.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Tela utilizada para inclusao Manual/Automatica, visualizacao³±±
±±³          ³alteracao e exclusao.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Campanhas, Lista de Contato, Agenda do Operador,Atendimento ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias                                                ³±±
±±³          ³ExpN2: Registro posicionado.                                ³±±
±±³          ³ExpN3: Opcao de menu enviada       			          	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk061Tela(cAlias,nReg,nOpc)

Local oSayEnt			                    // SAY "Entidade"
Local cNomEnt  	:= ""						// Nome da Entidade Selecionada
Local oDlg    								// Tela principal
Local cFiltro 	:= ""						// Descricao do filtro generico
Local nEntidade	:= 1					// Entidade selecionada para gerar a lista - o Default sera Cadastro de Clientes
Local cPergunte	:= ""						// Pergunte utilizada
Local cMensagem	:= Space(400) 				// Corpo do E-mail
Local cAssunto 	:= CriaVar("U4_ASSUNTO",.F.)// Assunto do E-mail
Local cAttach  	:= ""						// Nome do arquivo Anexo do E-Mail
Local aAttach  	:= {}						// Array de arquivo ANEXO do e-mail
Local aEntidade	:= {}						// Array com as entidades que POSSUEM CONTATOS
Local aPosObj   := {}						// Array para redimensionamento da tela
Local aObjects  := {}						// Array para redimensionamento da tela
Local aSize     := {}						// Array para redimensionamento da tela
Local aTable   	:= {{"T5",.T.}} 			// Contem as tabelas com ou sem contatos - Formato:[Nome da tabela, .T. (Com contato)]
Local aCampos 	:= Tk061RetU4Cmp(nOpc,cAlias,nReg)// Array com todos os campos do SU4 - menos U4_TIPO
Local lRet      := .F.  					// Valida retorno da funcao
Local nI 		:= 0 						// Contador para FOR
Local nT		:= 0                        // Contador
Local nSaveSX8	:= GetSx8Len()				// Controle de numeracao da 8.11
Local cTpLista	:= "1"						// Tipo da Lista  que sera gerada 1 = Telemarketing, 3 = Televendas - Default 1 - Telemarketing
Local cRotina	:= ""						// Nome da rotina que sera executada a lista de acordo com o tipo de Lista (TMK - Marketing ou TLV-Vendas)
Local aDados	:= {}
Local lIntegraPLS := SuperGetMV("MV_PLSXCRM",.T.,.F.)  // Habilita a integracao do Plano de Saude com o CRM
Local nPlus := 2 // Quantidade de registros a somar

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis privates do sistema                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nUsado       := 0					// Variaveis para a GETDADOS
Private oGet									// objeto da getdados
Private aCols        := {}
Private aHeader[0]
Private aValidGet    := {}
Private aTELA[0][0],aGETS[0]				// Variaveis privates para validacoes internas de campos.(Uso rotinas automaticas.)

Private oDlgMain
Private oEnchoice         					// ITENS DA LISTA - GETDADOS

//--------------------------------------------------------------------------------          
// Ajusta nOpc no CRM devido a alteração do MenuDef para ficar igual aos Defines
//--------------------------------------------------------------------------------
If nModulo == 73 //SIGACRM
    Iif( nOpc == 4, nOpc := 6, Iif( nOpc == 5, nOpc := 7, nOpc ) ) // 4= Alterar; 5= Excluir 
    If nOpc == 3
    	INCLUI := .T.
    Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seleciona as entidades para informação da tela de entidades.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nModulo <> 73 //SIGACRM
	DbSelectArea("SX5")
	DbSetOrder(1)
	For nI := 1 TO Len(aTable)
		If DbSeek(xFilial("SX5") + aTable[nI,1]) //"T5"
			While !Eof() .AND. (xFilial("SX5") == SX5->X5_FILIAL) .AND. (SX5->X5_TABELA == aTable[nI,1])  
				If SX5->X5_CHAVE <> "BA1"
					Aadd(aEntidade,{AllTrim(SX5->X5_CHAVE),;	// Alias
									AllTrim(X5DESCRI()),;		// Descricao
									aTable[nI,2]})				// TRUE = x Contato , FALSE x Sem contato
				EndIf
				SX5->(DbSkip())
			End
		Endif
	Next nI
Else
	If !lIntegraPLS
		aDados := { { "SA1", "SUS", "ACH", "SU5"}, { STR0042, STR0043, STR0044, STR0046 } } //"1 - Clientes"##"2 - Prospects"##"3 - Suspects"##4 - Contatos
	Else 
		aDados := { { "SA1", "SUS", "ACH", "SU5" , "BAU" }, { STR0042, STR0043, STR0044, STR0046, STR0061 } } //"1 - Clientes"##"2 - Prospects"##"3 - Suspects"##4 - Contatos## "5 - Prestadores"
		nPlus := 3
	Endif
	
	
	For nI := 1 To Len( aDados )+ nPlus    
		Aadd( aEntidade, { aDados[ 1, nI ],; // Alias
						   aDados[ 2, nI ],; // Descricao
						   .T. } )			 // Verdadeiro				   
	Next nI	
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa desta forma para criar uma nova instancia de variaveis private ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SU4")
DbSetOrder(1)    	//U4_FILIAL+U4_LISTA+DTOS(U4_DATA)
If (nOpc == INCLUIR .OR. nOpc == INCLUIAUTO)
	RegToMemory( "SU4", .T.)
Else
	RegToMemory( "SU4", .F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validacao da rotina automatica ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lA061Auto
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz o calculo automatico de dimensoes de objetos     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aObjects, { 100, 025, .T., .F. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	If (nOpc <> INCLUIAUTO)	
		AAdd( aObjects, { 100, 100, .T., .T. } )
	Endif
	
	aSize   := MsAdvSize()  		// Devolve o tamanho da tela atualmente no micro do usuario
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )
	
	cNomEnt := STR0014 				//"Nenhuma Entidade Selecionada"

	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] PIXEL

		// GroupBox
		@ aPosObj[1,1], aPosObj[1,2] TO aPosObj[1,3] ,aPosObj[1,4] LABEL "" OF oDlg  PIXEL

		// Botao da Entidade
		@ aPosObj[1,1]+8,aPosObj[1,2]+3 BUTTON STR0015 PIXEL OF oDlg SIZE 40,13 WHEN (  Tk61ButEnt() .And. ( nOpc == INCLUIR .OR. nOpc == INCLUIAUTO ) ); //"Entidade"
		ACTION (IIF(Tk061Entidade(	nOpc 		,@nEntidade		,aEntidade		,@cEntidade,;
									@cFiltro	,@cPergunte		,@cTpLista		,@cRotina),;
					cNomEnt := TRIM(aEntidade[nEntidade,2]) + cRotina,""),oSayEnt:SetText(cNomEnt))

		// Say da Entidade
		@ aPosObj[1,1]+10, aPosObj[1,2]+50 SAY oSayEnt PROMPT Alltrim(cNomEnt) OF oDlg PIXEL COLOR CLR_HRED SIZE 250,16
		
		// Enchoice com os dados
		oEnchoice := MSMGet():New( "SU4", nReg, nOpc,NIL,NIL,NIL,NIL,aPosObj[2],aCampos,3,NIL,NIL,oDlg)
				                                                                                          
       //---------------------------------------------------
       // Inicializacao de campos para o modulo de SIGACRM
       //---------------------------------------------------
		If nModulo == 73 .And. nOpc == 3  //SIGACRM Incluir 
			If U4_TIPO <> '1' 			  
				M->U4_TIPO := '1'	   	  //Marketing
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega informacoes para ToolBar Superior somente quando nao estiver em modo de inclusao.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   		If (nOpc <> INCLUIR) .AND. (nOpc <> INCLUIAUTO)
			cFiltro		:= SU4->U4_FILTRO
			cMensagem   := IIF(!Empty(SU4->U4_CODMENS),MSMM(SU4->U4_CODMENS,80),Space(400))
			cAssunto    := SU4->U4_ASSUNTO
			cAttach     := SU4->U4_ATTACH 
			Iif( nModulo == 73, cEntidade := SU4->U4_ENTIDA, cEntidade ) //SIGACRM
		Endif
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega o aCols com os itens do SU6³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nOpc <> INCLUIAUTO)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se a opcao for INCLUSAO nao serao selecionados itens e nao e necessaria a barra de progressao ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOpc <> INCLUIR //Inclusao
				Processa({|| Tk061Itens(nOpc,SU4->U4_LISTA,@cEntidade)},STR0016,,.T.) //"Selecionando itens..."
 				//-------------------------------------------------
 				// Carrega a descricao de campos virtuais no Grid
 				//-------------------------------------------------	
                If nModulo == 73 //SIGACRM
					TK61Dsc( @aCols, aHeader )
				EndIf
			Else
				Tk061Itens(nOpc,SU4->U4_LISTA,@cEntidade)
			Endif
			
			If (nOpc <> INCLUIAUTO .AND. nOpc <> INCLUIR)
				nEntidade	:= ASCAN(aEntidade, { |x| Upper(x[1]) == Upper(TRIM(cEntidade))} )
				cNomEnt		:= aEntidade[nEntidade,2]
			Endif	

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Os itens da lista serão sempre visualizados, a nao ser para³
			//³inclusao MANUAL (nOpc = 3) onde os itens serao digitados   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oGet:= MsGetDados():New(aPosObj[3,1],aPosObj[3,2],aPosObj[3,3],aPosObj[3,4],IIF(nOpc==7.OR. nOpc==6,2,nOpc),"TK061LINOK","AlwaysTrue","",.T.)
			oGet:oBrowse:bDelete:={ || aCols[n,Len(Acols[n])]:=!aCols[n,Len(Acols[n])],AlwaysTrue(),oGet:oBrowse:Refresh(.F.)}
		Endif

		Tk061Perg(cEntidade,@cPergunte,.F.,NIL)

		ACTIVATE MSDIALOG oDlg ON INIT ( Tk061Bar(	nOpc,		oDlg,		@cFiltro	,@cEntidade,; // Funcao 1
													@nEntidade,	aEntidade,	@cMensagem	,@cAssunto,;
													@aAttach,	@cAttach,	@cPergunte	,nSaveSX8),;    
													oDlgMain := oDlg,;
												IIF(nOpc == INCLUIR .OR. nOpc == INCLUIAUTO,;  				  // Funcao 2
											IIF(Tk061Entidade(	nOpc 		,@nEntidade		,aEntidade	,@cEntidade,;
																@cFiltro	,@cPergunte		,@cTpLista	,@cRotina),;
										    (cNomEnt := AllTrim(aEntidade[nEntidade,2])+cRotina,oSayEnt:SetText(cNomEnt));
										    ,"");
									    ,""))

Else                                            
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifico se as variaveis automaticas foram enviadas.         ³
	//³Estas variaveis irao simular os botoes padroes da ToolBar que³
	//³em alguns casos sao obrigatorios para execucao.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If (nT := ASCAN(aAutoCab,{|x| x[1]= "AUTENTIDADE"})) > 0
		cEntidade := aAutoCab[nT,2]
		Tk061Enti(cEntidade)
	Endif
	
	If (nT := ASCAN(aAutoCab,{|x| x[1]="AUTMENSAGEM"})) > 0
		cMensagem := aAutoCab[nT,2]
	Endif
	
	If (nT := ASCAN(aAutoCab,{|x| x[1]="AUTASSUNTO"})) > 0
		cAssunto := aAutoCab[nT,2]
	Endif
	
	If (nT := ASCAN(aAutoCab,{|x| x[1]="AUTATTACH"})) > 0
		cAttach := aAutoCab[nT,2]
	Endif
	
	If (nT := ASCAN(aAutoCab,{|x| x[1]="AUTFILTRO"})) > 0
		cFiltro := aAutoCab[nT,2]
	Endif
	
	If (nT := ASCAN(aAutoCab,{|x| x[1]="AUTPERG"})) > 0
		cPergunte := aAutoCab[nT,2]
	Endif
	
	If !SU4->(MsVldGAuto(aValidGet)) // Consiste os gets
		nOpc := 0
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se as variaveis para Cross Posting foram preenchidas e se for um³
	//³caso de alteracao preencho todas aquelas que nao vieram preenchidas.     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc > 0 .AND. nOpc <> INCLUIR
		If Empty(cFiltro)
			cFiltro := SU4->U4_FILTRO
        Endif
			
		If Empty(cMensagem)
			If !Empty(SU4->U4_CODMENS)
				cMensagem := MSMM(SU4->U4_CODMENS,80)
        	Endif
		Endif
                                                                                    
		If Empty(cAssunto)
			cAssunto := SU4->U4_ASSUNTO
		Endif	

		If Empty(cAttach)
			cAttach := SU4->U4_ATTACH
		Endif		
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega o aCols com os itens do SU6³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Processa({|| Tk061Itens(nOpc,M->U4_LISTA,@cEntidade)},STR0016,,.T.)	 //"Selecionando itens..."
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao da rotina automatica que carrega o acols criado anteriormente com os dados 	 ³
	//³informados pelos arrays da rotina automatica. Esta funcao simula a inclusao dos dados ³
	//³no acols como se fosse executada pelo usuario.                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsAuto2Acols()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa a validacao padrao para montagem do acols a partir do cabecalho.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nOpc == 0) .OR. ( !SU6->(MsVldAcAuto(aValidGet,NIL,NIL,NIL,nOpc,)) )   // consiste o campos do Acols
		nOpc := 0
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica o retorno da funcao e gera log se necessario.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet := Tk061Concluir(	nOpc		,cEntidade	,aEntidade	,@cMensagem	,;
							@cAssunto	,@aAttach	,@cAttach	,@cFiltro	,;
							@cPergunte	,nEntidade	,NIL		,NIL		,;
							NIL			,NIL		,NIL		,NIL		,;
							NIL			,NIL		,nSaveSX8	,NIL		,;
							NIL			,NIL		,NIL		,NIL		)  
							
	If !lRet
		AutoGRLog(	STR0017 +; 	//"Nao ha nenhum contato v lido para a regra informada. Verifique a sele‡„o do tipo "
					STR0018 +; 	//"de contato e a coerencia dos dados.Ex: Lista de Voz, contato:Fax, telefone de fax "
					STR0019) 	//"do contato informado n„o esta preenchido."

		DbSelectarea("SU4")
		While (GetSx8Len() > nSaveSx8)
			RollBackSX8()
		End	
	Endif
	
Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TK061Bar  ³ Autor ³ Vendas Clientes       ³ Data ³30.06.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Criacao da ToolBar principal.                               ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Campanhas, Lista de Contato, Agenda do Operador,Atendimento ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Exp1: Opcao de Menu.                                        ³±±
±±³          ³Exp2: Dialog para ToolBar.                                  ³±±
±±³          ³Exp3: Filtro para selecao.(NAO eh o filtro da MBrowse)      ³±±
±±³          ³Exp4: Entidade Trabalhada na Lista.          				  			³±±
±±³          ³Exp5: Entidade selecionada atraves do botao entidade  	  	³±±
±±³          ³Exp6: Array com as entidades que podem ser trabalhadas.	  	³±±
±±³          ³Exp7: Mensagem do email. (Listas de Cross Posting)          ³±±
±±³          ³Exp8: Assunto do e-mail. (Listas de Cross Posting)          ³±±
±±³          ³Exp9: Array com os arquivos anexos do e-mail.               ³±±
±±³          ³Exp10:String com os arquivos anexos do e-mail.              ³±±
±±³          ³Exp11:Codigo da Pergunte utilizada.                         ³±±
±±³          ³Exp12:Codigo da numeracao - GETSX8LEN                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk061Bar(nOpc		,oDlg		,cFiltro	,cEntidade	,;
						 nEntidade	,aEntidade	,cMensagem	,cAssunto	,;
						 aAttach	,cAttach	,cPergunte	,nSaveSX8)
						 
Local aArea	   		:= GetArea()	// Salva a area atual
Local aButtons		:= {}						// Botões exibidos na EnchoiceBar
Local cText    		:= CRLF 		// Variavel com os textos para help da Lista de Contatos
Local nAniver  		:= 0    		// Identifica se sera lista de Aniversario.
Local nPeriod  		:= 2    		// Identifica se sera lista de Periodicidade. 2= NAO 
Local lLstDiaria	:= .F.			// Identifica se a geracao de lista de aniversario sera diaria ou por periodo selecionado.
Local lTK061Bar		:= ExistBlock("TK061BAR")	// Controle de ponto de entrada
Local aTK061Bar		:= {}											// Array que ira receber o retorno do ponto de entrada
Local nX					:= 0											// Variavel de apoio para controle do ponto de entrada

If nModulo <> 73 //SIGACRM  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega a consulta de filtro para a rotina de Inclusao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc <> INCLUIR
		AAdd(aButtons,{ "FILTRO",	{|| Tk061Filtro(nOpc,@cFiltro,cEntidade,cPergunte)			}, STR0020,STR0020})  	//"Filtros","Filtros"
	Endif
	
	AAdd(aButtons,{ "NOTE"	,	{|| Tk061EMail(nOpc,@cMensagem,@cAssunto,@aAttach,@cAttach)	}, STR0021,STR0021}) 	//"E-Mail","E-Mail"
	AAdd(aButtons,{ "bmpvisual"	,	{|| Tk061Visual()                               			}, STR0022,STR0022})  	//"Visualizar","Visualizar"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega os botoes de lista de ANIVERSARIO/PERIODO para a rotina de Inclusao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc <> INCLUIR // Inclusao manual
		If TkPosto(TkOperador(),"U0_ANIVERS") == "1"  // SIM
			AAdd(aButtons, { "btcalend"		, {|| Tk061Niver(@nAniver,@nPeriod,nOpc,@lLstDiaria)  }, STR0023,STR0034 } )	 //"Lista de Aniversario","Aniver"
		Endif
		If TkPosto(TkOperador(),"U0_PERIODO") == "2" // Lista de ultimo contato.
			AAdd(aButtons, { "HISTORIC" 	, {|| Tk061Period(@nPeriod,@nAniver,nOpc) }, STR0024,STR0035 } )				 //"Lista de Periodicidade","Period"
		Endif	
	Endif
Else
	If  nOpc <> 2 //Visualizar	
		AAdd( aButtons,{ "bmpvisual", { || Tk061Members() }, STR0045, STR0045 } )//"Adicionar Membros à Lista"	
	EndIf
	If nOpc == 2 .OR. nOpc == 4 .OR. nOpc == 6
		aButtons := CRMXAddAct("SU4",aButtons) //Adcionar Rotinas no 'Ações relacionadas' do Formulário     
	EndIf
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para possibilitar inclusao de botoes na toolbar.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTK061Bar
	aTK061Bar := ExecBlock("TK061BAR",.F.,.F.,{} )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Protecao para retorno do ponto de entrada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Valtype(aTK061Bar) == "A"
		For nX := 1 to Len(aTK061Bar)
			AAdd( aButtons, aTK061Bar[nX] )
		Next nX
	Endif
		
Endif

EnchoiceBar(oDlg, {|| IIF(Tk061Concluir(nOpc		,cEntidade	,aEntidade	,@cMensagem	,;	// Botao de OK
										@cAssunto	,@aAttach	,@cAttach	,@cFiltro	,;
										@cPergunte	,nEntidade	,@cText		,nAniver 	,;
										nPeriod		,NIL		,NIL		,NIL		,;
										NIL			,NIL		,nSaveSX8	,lLstDiaria	,;
										NIL			,NIL		,NIL		,NIL		);
						,IIF(nOpc == INCLUIAUTO,(Tk061Help(@cText),oDlg:End());
						,oDlg:End()),; // Se o retorno da TkConcluir for true.
					 IIF(nOpc == INCLUIAUTO ,Tk061Help(@cText),""))},; // Se o retorno da TkConcluir for false.
				  {|| IIF(nOpc == INCLUIR .OR. nOpc == INCLUIAUTO .OR. nOpc == ASSISTENTE,Tk061Fim(nSaveSX8),""),oDlg:End()},,aButtons) // Botao de CANCELA

RestArea(aArea)
Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk061Entidade  ³ Autor ³ Vendas Clientes       ³ Data ³ 03/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Tela de selecao de entidade.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nExp1: Opcao de Menu.                                        	   ³±±
±±³          ³nExp2: Entidade selecionada atraves do botao entidade  	    	   ³±±
±±³          ³aExp3: Array com as entidades que podem ser trabalhadas.	  	   ³±±
±±³          ³cExp4: Entidade Trabalhada na Lista.          				   				 ³±±
±±³          ³cExp5: Filtro para selecao.(NAO eh o filtro da MBrowse)      	   ³±±
±±³          ³cExp6: Codigo da Pergunte utilizada.                         	   ³±±
±±³          ³cExp7: Tipo da Lista selecionada (1-Marketing,3-Vendas)      	   ³±±
±±³          ³cExp8: Nome da Rotina que sera utilizada (1-TMK,2-TLV)       	   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk061Entidade(nOpc		,nEntidade	,aEntidade	,cEntidade,;
							  cFiltro	,cPergunte	,cTpLista	,cRotina)

Local oTemp
Local oDlg								// Janela
Local oEntidade							// Objeto que exibira as entidades para a escolha
Local oScroll							// Panel que contem o radio
Local oBtnPrf							// Botao de "Perfil do Contato"
Local oTpLista                          // Objeto do RADIO com selecao do tipo de Lista "Marketing,Vendas"
Local nTpLista			:= Val(cTpLista)// Tipo da Lista 1 = Telearketing 3 = Televendas 
Local aArea				:= GetArea()    // Salva a area atual
Local aOpcoes   		:= {}			// Array com as entidades que possuem contatos
Local lRet 				:= .F.			// Retorno da funcao 
Local cEntTmp  			:= cEntidade	// Variavel com a entidade selecionada
Local nEntTmp  			:= nEntidade	// Posicao da entidade no array de entidades
Local bBlock			:= {||}		 	// Bloco para setar a variavel para o radio	
Local lClickPerg		:= .F.			// Flag para avaliar se o usuario preencheu as perguntes de cada entidade para selecao de parametros	
Local nPosSA1			:= 1			// Posicao do ALIAS SA1 - Cadastro de Clientes nos radios de entidades
Local nPosSUS           := 1			// Posicao do ALIAS SUS - Cadastro de Prospect nos radios de entidades
Local nCount			:= 0			// Contador auxiliar
Local cTele				:= ""

DEFAULT cPergunte := "TMK061"			// A pergunte default sera do cadastro de clientes

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa o tipo de Lista - Marketing ou Vendas  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(nTpLista)
	nTpLista := 1   // Marketing  
ElseIf nTpLista == 3	
	nTpLista := 2   // Vendas  
ElseIf nTpLista == 5	
	nTpLista := 3   // Teleatendimento  
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Sorteia o array pela descricao dos arquivos.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*
  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Array aEntidade                                ³
  ³                                               ³
  ³1 - Alias da Tabela                            ³ 
  ³2 - Nome da Tabela                             ³
  ³3 - Campo logico = TRUE x SU5 - FALSE x sem SU5³
  ³                                               ³
  ³SA1      Clientes         .T.     	          ³
  ³SU2      Concorrentes     .T.                  ³
  ³SA2      Fornecedores     .T.                  ³
  ³AC4      Parceiros        .T.                  ³
  ³SUS      Suspects         .T.                  ³
  ³SA4      Transportadoras  .T.                  ³
  ³                                               ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ           
*/

aEntidade:= ASort(aEntidade,,,{|x,y| x[2] < y[2]})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Alimenta o array com as opcoes que serao exibidos para o usuario.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEval( aEntidade, { |x| nCount++,	IIF(Upper(TRIM(x[1])) == "SA1",nPosSA1 := nCount,""),;
									IIF(Upper(TRIM(x[1])) == "SUS",nPosSUS := nCount,""),;
									AAdd( aOpcoes, x[2] ) } )
nEntTmp := ASCAN(aEntidade,{|x| x[1] == cEntidade})

//If (INCLUI .OR. INCLUIAUTO)
//	nEntTmp := 1
//Endif

DEFINE MSDIALOG oDlg FROM  300,20 TO 660,330 TITLE STR0025  PIXEL OF oMainWnd   //"Selecione a Entidade"

	@ 03, 03 TO 43, 122 LABEL STR0026 OF oDlg PIXEL  //"Tipo de Lista"
	If nModulo <> 73 //SIGACRM
		If _ISTMKTS()
			@ 10, 08 RADIO 	oTpLista VAR nTpLista ITEMS STR0027,STR0028, STR0036 SIZE 108,10 PIXEL OF oDlg ;  //"Marketing","Vendas", "Teleatendimento"
							ON CHANGE TK061ChkRad(nTpLista, oEntidade, nPosSA1, Len(aOpcoes),nPosSUS ) 
		Else
			@ 10, 08 RADIO 	oTpLista VAR nTpLista ITEMS STR0027,STR0028 SIZE 108,10 PIXEL OF oDlg ;  //"Marketing","Vendas"
							ON CHANGE TK061ChkRad(nTpLista, oEntidade, nPosSA1, Len(aOpcoes),nPosSUS ) 		
		EndIf
	Else
		@ 10, 08 RADIO 	oTpLista VAR nTpLista ITEMS STR0027 SIZE 108,10 PIXEL OF oDlg ;  //"Marketing"
							ON CHANGE TK061ChkRad(nTpLista, oEntidade, nPosSA1, Len(aOpcoes),nPosSUS ) 	
	EndIf

	@ 45, 03 SCROLLBOX oScroll SIZE 120, 120

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exibe os botoes de selecao de parametros para ENTIDADE e CONTATO somente para inclusao AUTOMATICA / ASSISTENTE³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc <> INCLUIR
		DEFINE SBUTTON oBtnParam FROM 45,125 TYPE 5  ENABLE OF oDlg ACTION (Tk061Perg(cEntTmp,@cPergunte,.T.,nTpLista), lClickPerg:=.T.)	//PARAMETROS

		DEFINE SBUTTON oBtnPrf FROM 60,125 TYPE 11 ENABLE OF oDlg ACTION Pergunte("TMK060",.T.) //PERFIL DO CONTATO
		oBtnPrf:cToolTip := STR0029 //"Perfil do Contato..."
	Endif	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao for uma Inclusao habilita/desabilita as entidades de acordo com o tipo de lista: Marketing ou Vendas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If nOpc <> INCLUIR
		bBlock := &("{||nEntTmp:= oEntidade:nOption, cEntTmp := aEntidade[nEntTmp,1], IIF( aEntidade[nEntTmp,3],oBtnPrf:SetEnable(.T.),oBtnPrf:SetEnable(.F.) ), IIf( oEntidade:nOption == 2, oBtnParam:SetEnable(.F.), oBtnParam:SetEnable(.T.) ) }") 
	Else
		bBlock := &("{||nEntTmp:= oEntidade:nOption, cEntTmp := aEntidade[nEntTmp,1] }") 
	Endif
	
	/*

	   [ <oRadMenu> := ] TRadMenu():New( <nRow>, <nCol>, {<cItems>},;
									     [bSETGET(<nVar>)], <oWnd>, [{<nHelpId>}], <{uChange}>,;
									     <nClrFore>, <nClrBack>, <cMsg>, <.update.>, <{uWhen}>,;
									     <nWidth>, <nHeight>, <{uValid}>, <.lDesign.>, <.lLook3d.>,;
									     <.lPixel.> )
	*/
											
	oEntidade:= TRadMenu():New(	05, 05, aOpcoes,;
								bSETGET(nEntTmp), oScroll , NIL ,bBlock ,;
								NIL, NIL, NIL, .T., NIL,;
								100, 15, NIL, .T., .T., .T. )
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona na entidade selecionada anteriormente³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oEntidade:SetOption(nEntTmp)

	Eval(oTpLista:bChange)

	DEFINE SBUTTON FROM 05,125 TYPE 1  ENABLE OF oDlg; 	//OK
	ACTION (lRet	  :=.T.,;
			cFiltro	  :="",; 				
			nEntidade := nEntTmp ,;
			cEntidade := aEntidade[nEntidade,1],;  
		    cTpLista  := IIF(nTpLista == 1,Str(nTpLista,1),IIF(nTpLista == 2,"3","4")),; //Se for uma lista de TELEMARKETING = 1 , se for de TELEVENDAS = 3 - identico a versao 7.10
			cRotina   := IIF(nModulo <> 73,IIF(cTpLista == "1",STR0032,IIF(cTpLista == "3",STR0033,STR0037)),STR0040),; //" - Lista para a Rotina de:Telemarketing - Lista para a Rotina de: Televendas  - Lista para a Rotina de: Teleatendimento"##" - Lista para a Rotina de Marketing" 
			Tk061Enti(cEntidade),;
			M->U4_TELE := IIF(nModulo <> 73,IIF(nTpLista == 3,"5",ALLTRIM(STR(nTpLista))),"6"),;  //Se for uma lista de MARKETING = 1 , se for de VENDAS = 2, se TELEATENDIMENTO = 5					
			M->U4_TIPO := cTpLista,;
			Iif( nModulo == 73, M->U4_ENTIDA := cEntidade, M->U4_ENTIDA := "" ),;  
			oEnchoice:Refresh(),;
			oDlg:End())	  
																
	DEFINE SBUTTON FROM 20,125 TYPE 2  ENABLE OF oDlg ACTION (lRet := .F.,oDlg:End())     //CANCELA                                                             
        
ACTIVATE MSDIALOG oDlg CENTERED ON INIT Tk061Forma(nOpc,oEntidade)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o usuario nao atualizou os parametros de selecao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lClickPerg  
	Tk061Perg(cEntTmp,@cPergunte,.F.,nTpLista)
Endif
                     
RestArea(aArea)

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK061ChkRad ºAutor  ³ Vendas Clientes    º Data ³  07/07/03 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Habilita e desabilita as ENTIDADES de acordo com o tipo de  º±±
±±º          ³lista escolhida MARKETING/COBRANCA                          º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Exp1: Tipo da Lista.                                        ³±±
±±³          ³Exp2: Objeto com as entidades.                              ³±±
±±³          ³Exp3: Posicao do SA1 no objeto oEntidade.                   ³±±
±±³          ³Exp4: Total de Itens do objeto.         			     				  ³±±
±±³          ³Exp5: Posicao do SUS no objeto.               	        	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso 	 	 ³LISTA DE CONTATOS		                              		        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TK061ChkRad(	nTpLista, oEntidade, nPosSA1, nTotal,;
							 	nPosSUS )

Local nI := 0	// Contador

If (nTpLista == 1) //Marketing
	For nI := 1 To nTotal
		oEntidade:EnableItem( nI, .T. )
	Next nI

ElseIf (nTpLista == 2) //Vendas

	For nI := 1 To nTotal
		If (nI == nPosSA1) .OR. (nI == nPosSUS)
			oEntidade:EnableItem( nI, .T. )
		Else
			oEntidade:EnableItem( nI, .F. )
		Endif
		oEntidade:SetOption( nPosSA1 )
	Next nI

ElseIf (nTpLista == 3) //Teleatendimento
	For nI := 1 To nTotal
		oEntidade:EnableItem( nI, .T. )
	Next nI
	
Endif

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk061Perg      ³ Autor ³ Vendas Clientes       ³ Data ³ 07/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Executa as perguntes para a selecao das entidades.		           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1: Alias da Entidade (SA1,SUS,SU2,SU4,AC4).              	   ³±±
±±³          ³cExp2: Pergunte utilizado definido no SX1.                   	   ³±±
±±³          ³lExp3: Controle de exibicao do pergunte (TRUE - exibe, FALSE-nao ³±±
±±³          ³nExp4: Tipo de Lista selecionada. (1-Marketing,2-Vendas)     	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso 	 	 	 ³LISTA DE CONTATOS	                                  		         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk061Perg(cEntidade,cPergunte,lShow,nTpLista)

Local lRet		:= .T.		// Retorno da funcao

DEFAULT lShow  	:= .T.  	// Exibe a Pergunte
DEFAULT nTpLista:= 1		// Lista de Marketing	

If Empty(cEntidade)
	Help(" ",1,"TK061NOSEL")//"Informe a selecao dos clientes ou prospects !"
	lRet := .F.
Endif

If lRet
	Do Case
		Case cEntidade == "SU2"  //Concorrentes
			cPergunte := "TMK066"
			Pergunte(cPergunte,lShow)
			
		Case cEntidade == "AC4"  //Parceiros
			cPergunte := "TMK064"
			Pergunte(cPergunte,lShow)
			
		Case cEntidade == "ACH"	//Suspects
			cPergunte := "TMK064"
			Pergunte(cPergunte,lShow)
			
		Case cEntidade == "SA1"  //Clientes
			cPergunte := "TMK061"
			Pergunte(cPergunte,lShow)
			
		Case cEntidade == "SA2"	//Fornecedores
			cPergunte := "TMK065"
			Pergunte(cPergunte,lShow)
			
		Case cEntidade == "SA4"	//Transportadoras
			cPergunte := "TMK067"
			Pergunte(cPergunte,lShow)
			
		Case cEntidade == "SUS"	//Prospects
			cPergunte := "TMK063"
			Pergunte(cPergunte,lShow)
			
		Case cEntidade == "BAU"	//Prestadores
			cPergunte := "TMK070"
			Pergunte(cPergunte,lShow)
	Endcase
Endif
	
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TK061Forma   ³ Autor ³ Vendas Clientes    ³ Data ³07/07/03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica qual a ROTINA foi escolhida para permitir          ³±±
±±³          ³a escolha da entidade                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Exp1: Opcao de Menu.                                        ³±±
±±³          ³Exp2: Objeto da entidade.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso	     ³CALL CENTER                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk061Forma(	nOpc,oEntidade)

If (nOpc <> ALTERAR) .AND. (nOpc <> INCLUIR) .AND. (nOpc <> INCLUIAUTO)
	oEntidade:Disable()
Endif

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK061ConcluirºAutor ³ Vendas Clientes     º Data ³ 07/07/03  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica qual rotina sera executada na confirmacao		   º±±
±±º          ³ para efetuar as acoes corretas.                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER                          	               	   º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºParametros³cExp1: Opcao de Menu.                                        º±±
±±º          ³cExp2: Alias da entidade.                                    º±±
±±º          ³aExp3: Array com as entidades para selecao.                  º±±
±±º          ³cExp4: Mensagem do e-mail.(Cross Posting).                   º±±
±±º          ³cExp5: Assunto do E-mail.                              	   º±±
±±º          ³aExp6: Array com as arquivos atachados para o e-mail.   	   º±±
±±º          ³cExp7: Arquivos do email. (Listas de Cross Posting)          º±±
±±º          ³cExp8: Filtro da selecao.                                    º±±
±±º          ³cExp9: Pergunte para selecao. Alias.                         º±±
±±º          ³nExp10:Numero da entidade selecionda no oEntidade            º±±
±±º          ³cExp11:Variavel com as informacoes do arquivo texto          º±±
±±º          ³nExp12:Controle da Lista de Aniversario.                     º±±
±±º          ³nExp13:Controle da Lista de Periodicidade.                   º±±
±±º          ³nExp14:Utilizado pelo wizard para controle do detalhamento doº±±
±±º          ³      do contato.                                            º±±
±±º          ³cExp15:Diretorio para arquivo de OutBound.                   º±±
±±º          ³cExp16:Arquivo que sera gerado para lista de OutBound.       º±±
±±º          ³lExp17:Flag Avalia se o agente de OutBound sera identificado º±±
±±º          ³lExp18:Identifica se a Lista de OutBound sera gerada.	       º±±
±±º          ³nExp19:Controle de numeracao - GETSX8LEN                     º±±
±±º          ³lExp20:Identifica se a geracao de lista de aniversario       º±±
±±º          ³        sera diaria ou por periodo selecionado               º±±
±±º          ³lExp21:Flag para identificacao se a lista sera por grupo     º±±
±±º          ³cExp22:Codigo do Grupo que vai assumir a lista               º±±
±±º          ³cExp23:Filtro dos contatos                                   º±±
±±º          ³cExp24:Filtro dos contatos em sintaxe SQL                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Lista de Contato                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk061Concluir(	nOpc		,cEntidade	,aEntidade	,cMensagem	,;
						cAssunto	,aAttach	,cAttach	,cFiltro	,;
						cPergunte	,nEntidade	,cText		,nAniver	,;
						nPeriod		,nDetCont	,cDir		,cFile		,;
						lAgente		,lOutBound	,nSaveSX8	,lLstDiaria	,;
						lGrupo		,cGrupo		,cFiltroU5	,cFiltU5SQL	,;
						lOS			,cOSIni		,cOSFim	,lEntMonOS)		

Local lRet		  := .F.
Local cChave    := ""
Local aAutoAO4  := {}

Default cFiltroU5	:= ""
Default cFiltU5SQL	:= ""
Default lOS			:= .F.
Default cOSIni		:= ""
Default cOSFim		:= ""
Default lEntMonOS		:= .F.      

Do Case
	Case (nOpc == VISUAL) //Visualizacao
		lRet:= .T.
		
	Case (nOpc == INCLUIAUTO)  
		lRet := Tk061Incluir(	nOpc		,cEntidade	,aEntidade	,@cMensagem	,;
								@cAssunto	,@aAttach	,@cAttach	,@cFiltro	,;
								@cPergunte	,@cText		,nAniver	,nPeriod	,;
								NIL			,NIL		,NIL		,NIL		,;
								NIL			,nSaveSX8	,lLstDiaria	,lGrupo		,;
								cGrupo		,cFiltroU5	,cFiltU5SQL	)

	Case (nOpc == INCLUIR)  
		
		If nModulo == 73 .And. Empty( M->U4_DESC )//SIGACRM
			lRet := .F.
			Help( " " , 1, "TK061LDSC" )//O nome da lista não foi preenchido. ## Para prosseguir, por favor, preencha o nome da Lista.
		ElseIf nModulo <> 73 .And. Empty( M->U4_FORMA )
			lRet := .F.
			Help( " " , 1, "TK061FORMA" )//O Tipo de Contato não foi preenchido. ## Para prosseguir, por favor, preencha o Tipo de Contato.	
		Else
			lRet := Tk061Incluir(	nOpc 	 	,cEntidade	,aEntidade	,@cMensagem	,;
								@cAssunto	,@aAttach	,@cAttach	,@cFiltro	,;
								@cPergunte	,@cText		,nAniver	,nPeriod	,;
								NIL			,NIL		,NIL		,NIL		,;
								NIL			,nSaveSX8	,lLstDiaria	,lGrupo		,;
								cGrupo		,cFiltroU5	,cFiltU5SQL )
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Adiciona ou Remove o privilegios deste registro.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .And. nModulo == 73 //SIGACRM
			cChave   := PadR(xFilial("SU4")+M->U4_LISTA+dTos(M->U4_DATA),TAMSX3("AO4_CHVREG")[1])		
			aAutoAO4 := CRMA200PAut(nOpc,"SU4",cChave,/*cCodUsr*/,/*aPermissoes*/,/*aNvlEstrut*/,/*cCodUsrCom*/,/*dDataVld*/)    
			lRet 	  := CRMA200Auto(aAutoAO4[1],aAutoAO4[2],3)
		EndIf 
		
	Case (nOpc == ALTERAR)	
		If nModulo == 73 .And. Empty( M->U4_DESC )//SIGACRM
			lRet := .F.
			Help( " ", 1 , "TK061LDSC" )//O nome da lista não foi preenchido. ## Para prosseguir, por favor, preencha o nome da Lista.
		ElseIf nModulo <> 73 .And. Empty( M->U4_FORMA )
			lRet := .F.
			Help( " " , 1, "TK061FORMA" )//O Tipo de Contato não foi preenchido. ## Para prosseguir, por favor, preencha o Tipo de Contato.
		Else
	    	lRet := TK061GrvAlt(	nOpc		,cEntidade	,aEntidade	,@cMensagem	,;
	    						@cAssunto	,@aAttach	,@cAttach	,@cFiltro	,;
	    						@cPergunte	,@cText)
	    Endif

	Case (nOpc == EXCLUIR)
		lRet:= Tk061Del() 
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Adiciona ou Remove o privilegios deste registro.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .And. nModulo == 73 //SIGACRM
			cChave   := PadR(xFilial("SU4")+M->U4_LISTA+dTos(M->U4_DATA),TAMSX3("AO4_CHVREG")[1])		
			aAutoAO4 := CRMA200PAut(nOpc,"SU4",cChave,/*cCodUsr*/,/*aPermissoes*/,/*aNvlEstrut*/,/*cCodUsrCom*/,/*dDataVld*/)    
			lRet 	  := CRMA200Auto(aAutoAO4[1],aAutoAO4[2],5)
		EndIf 
		
	Case (nOpc == ASSISTENTE)
		lRet := Tk061Incluir(	nOpc		,cEntidade	,aEntidade	,@cMensagem	,;
								@cAssunto	,@aAttach	,@cAttach	,@cFiltro	,;
								@cPergunte	,@cText		,nAniver	,nPeriod	,;
								nDetCont	,cDir		,cFile		,lAgente	,;
								lOutBound	,nSaveSX8	,lLstDiaria ,lGrupo		,;
								cGrupo		,cFiltroU5	,cFiltU5SQL	,lOS		,;
								cOSIni		,cOSFim	,lEntMonOS)

EndCase

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk061RetU4Cmp º Vendas Clientes            º Data ³ 07/07/03 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Carrega um array com os campos do SU4 que podem ser alteradosº±±
±±º          ³dependendo da rotina: Inclusao ou Alteracao                  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nExp1: Opcao de menu enviada                                 ³±±
±±³          ³cExp2: Alias                                                 ³±±
±±³          ³nExp3: Registro selecionado na base.         				   			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³Lista de Contato                  	        	               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Tk061RetU4Cmp(nOpc,cAlias,nReg)

Local aArea 	:= GetArea()					// Salva a area atual
Local aCampos 	:= {}							// Array com os campos do SU4
Local cCampos  	:= "U4_OPERAD;U4_MALADIR;U4_CONFIG;U4_ETIQUET,U4_CODCAMP;U4_DESCCAM;U4_SCRIPT;U4_EVENTO"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Em caso de ALTERACAO verifica se a lista ja foi EXECUTADA. Se o retorno for positivo alguns campos nao podem ser alterados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == ALTERAR
	If Tk061ValAlt(cAlias,nReg,nOpc)
		cCampos   := "U4_OPERAD;U4_MALADIR;U4_CONFIG;U4_ETIQUET,U4_CODCAMP;U4_DESCCAM;U4_SCRIPT;U4_EVENTO"
	Else
		cCampos   := "U4_OPERAD;U4_MALADIR;U4_CONFIG;U4_ETIQUET"
	Endif
Endif

DbSelectArea("SX3")
DbSetOrder(1)
If DbSeek("SU4")
	While !Eof() .AND. SX3->X3_ARQUIVO == "SU4"
		
		If X3USO(SX3->X3_USADO)
			
			// Se for INCLUSAO carrega os campos usados do SU4
			If ( (nOpc == INCLUIR) .OR. (nOpc == INCLUIAUTO) )
				Aadd( aCampos, SX3->X3_CAMPO )
			Else
				// Se for ALTERACAO carrega somente os campos que PODEM ser alterados - mesmo com Lista pre-executada
				If (Alltrim(Upper(SX3->X3_CAMPO)) $ cCampos)
					Aadd( aCampos, SX3->X3_CAMPO )
				Endif
			Endif
		Endif
		SX3->(DbSkip())
	End
Endif


RestArea(aArea)

Return(aCampos)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK061Itens  ºAutor ³ Vendas Clientes     º Data ³ 05/10/04  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Carrega os itens da lista de contatos     								  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³nExp1: Opcao de menu enviada                                ³±±
±±³          ³cExp2: Codigo da Lista.                                     ³±±
±±³          ³cExp3: Alias para selecao.                   							  ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lista de Contatos                                     		  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk061Itens(nOpc,cLista,cEntidade)

Local aArea		:= GetArea()	// Salva a area atual
Local nRecAtu   := 0			// Contador do registro atual
Local nRecTot   := 0			// Contador do total de registros do SU6
Local cSeek		:= ""			//Armazena a string de busca em Codebase
Local cWhile	:= ""			//Armazena a condicao de parada
Local cQuery    := ""			// Composicao do SELECT para a query
Local cQryTot   := ""			// Composicao final da query	
Local bCond		:= {||IIf(SU6->U6_FILIAL == xFilial('SU6') .AND. SU6->U6_LISTA = cLista,.T.,.F.)} //Condicao para o registro ser adicionado no Acols



cQuery 	:= "SELECT * "
cQuery 	+= "FROM "+RetSqlName("SU6")+" SU6  "
cQuery 	+= "WHERE SU6.U6_FILIAL='"+xFilial("SU6")+"' AND "
cQuery 	+= "	SU6.U6_LISTA='"+cLista+"' AND "
cQuery 	+= "	SU6.D_E_L_E_T_ = ' ' "	

cQryTot := "SELECT COUNT(*) U6TOTAL " + SubStr(cQuery,AT("FROM ",cQuery),Len(cQuery))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O filtro esta montado e o ORDER BY nao esta na query entao e hora de montar o contator da regua³
//³Monto o SELECT que conta e aproveito o filtro da outra query                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
cQuery += "ORDER BY U6_LISTA"  

cQryTot := ChangeQuery(cQryTot)
DbSelectArea("SU6")
DbCloseArea()
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQryTot), "SU6", .F., .T.)
nRecTot := SU6->U6TOTAL	
                                                                  
DbSelectArea("SU6")
DbCloseArea()

cSeek	:= xFilial("SU6") + cLista
//cWhile	:= "SU6->U6_FILIAL == xFilial('SU6') .AND. SU6->U6_LISTA = '" + cLista + "'"	
cWhile	:= "SU6->U6_FILIAL + SU6->U6_LISTA"	

aHeader := {}
aCols	:= {}
FillGetDados(	nOpc /*nOpcX*/, "SU6"/*cAlias*/, 1/*nIndex*/, cSeek/*cSeek*/,; 
				{||&(cWhile)}/*{||&cWhile}*/, bCond/*{|| bCond,bAct1,bAct2}*/, {"U6_STATUS"}/*aNoFields*/,; 
				/*aYesFields*/, /*lOnlyYes*/, cQuery/*cQuery*/, /*bMontAcols*/, IIf(nOpc<>INCLUIR,.F.,.T.)/*lEmpty*/,; 
				/*aHeaderAux*/, /*aColsAux*/, {||TK061SetProc(@nRecAtu, nRecTot)}/*bAfterCols*/, /*bBeforeCols*/,;
				/*bAfterHeader*/, "SU6"/*cAliasQry*/)
                                                                                                

DbSelectArea("SU6")
DbCloseArea()	

RestArea(aArea)

Return NIL 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    |TK061SetProcºAutor ³Vendas Cliente       º Data ³ 12/01/07  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Incrementa a contador de atividades 				   		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³nExp1: Numero do processo atual.                            ³±±
±±³          ³cExp2: Total de processos a serem executados                ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lista de Contatos                          	           	  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TK061SetProc(nRecAtu, nRecTot)  

nRecAtu++

IncProc( STR0030 + StrZero(nRecAtu,6) + STR0031 + StrZero(nRecTot,6) )/*// "Lendo reg. ", " ate " //"Lendo registro "###" ate "*/


Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk061Vld  ºAutor  ³ Vendas Clientes    º Data ³  30/07/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida o campo U4_MALA para quando a opcao for diferente de º±±
±±º          ³Mala-Direta                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Lista de Contato                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk061Vld() 
Local lRet := .F.	// Retorno dafuncao

If VAL(M->U4_FORMA) <> MALADIRETA .AND. !Empty(M->U4_MALADIR)	//Voz
	Help(" ",1,"TK061TPMAL")
Else
	lRet := .T.
Endif	

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TMKA061ENT ºAutor ³ Vendas Clientes    º Data ³  08/08/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza a variavel de controle do ALIAS e retorna valor    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lista de Contato                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk061Enti(cEntidade)

DEFAULT cEntidade := ""

If !Empty(cEntidade)
	cEntAlias := cEntidade
Endif

Return(cEntAlias)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK061Fim   ºAutor ³ Vendas Clientes    º Data ³  18/12/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza o semaforo quando o usuario cancelar a rotina      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lista de Contato                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk061Fim(nSaveSX8)

While (GetSx8Len() > nSaveSx8)
	RollBackSX8()
End

Return(.T.)       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk061PegEnt ºAutor  º Vendas Clientes    º Data º  16/01/06 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a entidade escolhida pelo usuario                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMKA061x                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk061PegEnt()
Return( cEntidade )            

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk061VldOp  ºAutor  º Vendas Clientes    º Data º  05/03/07 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida o operador selecionado para a lista de contatos      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMKA061x                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk061VldOp()

Local aArea		:= GetArea()
Local aAreaSU7	:= SU7->(GetArea())
Local lRet	:= .T.

If !EMPTY(M->U4_OPERAD) 

	DbSelectArea("SU7")
	DbSetOrder(1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida a existencia do operador e a sua validade³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (lRet := DbSeek(xFilial("SU7")+M->U4_OPERAD))
		lRet := Val(SU7->U7_VALIDO) == VALIDO
	EndIf

EndIf

RestArea(aAreaSU7)
RestArea(aArea)

Return (lRet)

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tk61ValCont()
Cria opções no menu

@return lRet - Retorno verdadeiro ou falso.
@author Vendas CRM
@since 15/07/2013
/*/
//------------------------------------------------------------------------------------------------

Function Tk61ValCont()

Local lRet

lRet := IIF(INCLUI,Tk061ValContM(M->U6_CONTATO),.T.) .AND. Tk061EntCont(M->U6_CONTATO);
    	.AND. TK700VldMan(M->U4_BLQCONT,M->U4_FORMA,M->U4_TIPOTEL,M->U4_TELE,M->U6_CONTATO)  

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK061Legenda ºAutor  ³ Vendas Clientes º Data ³  12/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Legendas do browse da Lista de Contatos.			       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk061Legenda()

Local aCores := {}

aCores := {	{"BR_VERDE"		,STR0028 },;	//"Vendas"
			{"BR_AZUL"		,STR0027 },;    //"Marketing"
			{"BR_BRANCO"	,STR0036 },;	//"Teleatendimento"
			{"BR_VERMELHO"	,STR0039 }}     //"Cobrança"

BrwLegenda(cCadastro,STR0026,aCores )	//"Tipo de Lista"
						
Return(.T.)   

//-------------------------------------------------------------------------
/*/{Protheus.doc} Tk061Members

Função que carrega os membros à lista de acordo com a entidade selecionada

@author Thamara Villa

@since 18/03/2014
@version 12.0
/*/
//-------------------------------------------------------------------------
Function Tk061Members() 

Local aArea				 := GetArea()
Local oDlg         		 := Nil
Local oMarkBrow   		 := Nil
Local bInitBr			 := Nil
Local bSetFech  		 := Nil
Local bSetConf  		 := Nil
Local cAliasQry   		 := ""
Local aCampos            := ""
Local cArqTmp            := ""  
Local cFiltro			 := ""
Local cEntidad    		 := M->U4_ENTIDA  
Local nI 				 := 0
Local aColumns 			 := {}      
Local aButtons 			 := {}   
Local aLista 			 := {} 
Local lConfirm  		 := .F.      
Local lRet				 := .T.
Local cTypeDB			 := Trim(Upper(TcGetDb()))
Local cConcat	  		 := IIF(cTypeDB $ "ORACLE,DB2,INFORMIX","||","+")
Local cQuery			 := ""
Local cNewTab 			 := ""
Local cInsert 			 := ""
Local nRetInsert		 := 0

Local cTempKey			 := ""
Local aKey				 := {}

Local nTam				 := 0
Local nX				 := 0	

If Empty( cEntidad ) 
	lRet := .F.     
	Help( " ", 1, "TK061CKENT" )//"Para adicionar membros à lista é necessário selecionar uma entidade." ## "Clique no botão "Entidade" para selecionar uma entidade."
EndIf

If lRet
	cAliasQry   		 := GetNextAlias() 
	aDados      		 := Tk61CpoBrw( cEntidad )
	aStruct     		 := aDados[1]       
	aCampos     		 := aDados[2]
	cCpoQry     		 := aDados[3]
	cTempTab    		 := GetNextAlias()  
	
	cFiltro := AllTrim( CRMXFilEnt( cEntidade, .T. ) )

	If !Empty( cFiltro )
		cFiltro := cFiltro + " AND "
	EndIf

	If cEntidad == "SA1" //Clientes  
		
		cQuery := " SELECT '  ' MARK, " + cCpoQry
		cQuery += " FROM " + RetSqlName("SA1") + " SA1 "
		 
		If !Empty( cFiltro )
			cQuery += "INNER JOIN " + RetSqlName( "AO4" ) + " AO4 "
			If cTypeDB $ "POSTGRES"
				cQuery += "ON AO4.AO4_CHVREG = CONCAT(SA1.A1_FILIAL,SA1.A1_COD,SA1.A1_LOJA) AND AO4.D_E_L_E_T_ = ' ' "
			Else
				cQuery += "ON AO4.AO4_CHVREG = SA1.A1_FILIAL " + cConcat + " SA1.A1_COD " + cConcat + " SA1.A1_LOJA AND AO4.D_E_L_E_T_ = ' ' "
			EndIf
		EndIf
		
		cQuery += " WHERE "
		
		If !Empty( cFiltro )
			cQuery += cFiltro
		EndIf
		
		cQuery += " SA1.D_E_L_E_T_ = ' ' "
	ElseIf cEntidad == "SUS" //Prospects
		
		cQuery := " SELECT '  ' MARK, " + cCpoQry
		cQuery += " FROM " + RetSqlName("SUS") + " SUS "
		
		If !Empty( cFiltro )
			cQuery += "INNER JOIN " + RetSqlName( "AO4" ) + " AO4 "
			If cTypeDB $ "POSTGRES"
				cQuery += "ON AO4.AO4_CHVREG = CONCAT(SUS.US_FILIAL,SUS.US_COD,SUS.US_LOJA) AND AO4.D_E_L_E_T_ = ' ' "
			Else
				cQuery += "ON AO4.AO4_CHVREG = SUS.US_FILIAL " + cConcat + " SUS.US_COD " + cConcat + " SUS.US_LOJA AND AO4.D_E_L_E_T_ = ' ' "
			EndIf
		EndIf
		
		cQuery += " WHERE "
		
		If !Empty( cFiltro )
			cQuery += cFiltro
		EndIf
		
		cQuery += " SUS.D_E_L_E_T_ = ' ' "
	ElseIf cEntidade == "ACH" //Suspects
		
		cQuery := " SELECT '  ' MARK, " + cCpoQry
		cQuery += " FROM " + RetSqlName("ACH") + " ACH "
		
		If !Empty( cFiltro )
			cQuery += "INNER JOIN " + RetSqlName( "AO4" ) + " AO4 "
			If cTypeDB $ "POSTGRES"
				cQuery += "ON AO4.AO4_CHVREG = CONCAT(ACH.ACH_FILIAL,ACH.ACH_CODIGO,ACH.ACH_LOJA) AND AO4.D_E_L_E_T_ = ' ' "
			Else
				cQuery += "ON AO4.AO4_CHVREG = ACH.ACH_FILIAL " + cConcat + " ACH.ACH_CODIGO " + cConcat + " ACH.ACH_LOJA AND AO4.D_E_L_E_T_ = ' ' "
			EndIf
		EndIf
		
		cQuery += " WHERE "
		
		If !Empty( cFiltro )
			cQuery += cFiltro
		EndIf
		
		cQuery += " ACH.D_E_L_E_T_ = ' ' "          
	ElseIf cEntidade == "SU5"//Contatos

		cQuery := " SELECT '  ' MARK, " + cCpoQry
		cQuery += " FROM " + RetSqlName("SU5") + " SU5 "

		If !Empty( cFiltro )
			cQuery += "INNER JOIN " + RetSqlName( "AO4" ) + " AO4 "
			If cTypeDB $ "POSTGRES"
				cQuery += "ON AO4.AO4_CHVREG = CONCAT(SU5.U5_FILIAL,SU5.U5_CODCONT) AND AO4.D_E_L_E_T_ = ' ' "
			Else
				cQuery += "ON AO4.AO4_CHVREG = SU5.U5_FILIAL " + cConcat + " SU5.U5_CODCONT AND AO4.D_E_L_E_T_ = ' ' "
			EndIf
		EndIf
		
		cQuery += " WHERE "
		
		If !Empty( cFiltro )
			cQuery += cFiltro
		EndIf
		
		cQuery += " SU5.D_E_L_E_T_ = ' ' "           
	 Else //Prestadores

		cQuery := " SELECT '  ' MARK, " + cCpoQry
		cQuery += " FROM " + RetSqlName("BAU") + " BAU "

		If !Empty( cFiltro )
			cQuery += "INNER JOIN " + RetSqlName( "AO4" ) + " AO4 "
			If cTypeDB $ "POSTGRES"
				cQuery += "ON AO4.AO4_CHVREG = CONCAT(BAU.BAU_FILIAL,BAU.AU_CODIGO) AND BAU.D_E_L_E_T_ = ' ' "
			Else
				cQuery += "ON AO4.AO4_CHVREG = BAU.BAU_FILIAL " + cConcat + " BAU.AU_CODIGO AND BAU.D_E_L_E_T_ = ' ' "
			EndIf
		EndIf
		
		cQuery += " WHERE "
		
		If !Empty( cFiltro )
			cQuery += cFiltro
		EndIf
		
		cQuery += " BAU.D_E_L_E_T_ = ' ' "         

	EndIf

	cQuery := ChangeQuery(cQuery)

	DBUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .T. ) 
	
	For nX := 1 To Len(aStruct)
		If ( aStruct[nX][2] <> "C" )
			TcSetField(cAliasQry,aStruct[nX][1],aStruct[nX][2],aStruct[nX][3],aStruct[nX][4])
		EndIf
	Next nX

	//-------------------------------------------------------------------
	// Instancia tabela temporária.  
	//-------------------------------------------------------------------

	oTempTable	:= FWTemporaryTable():New( cTempTab )

	aAdd( aStruct, {})
	aIns(aStruct,1)
	aStruct[1] := {"MARK","C",2,0}

	//-------------------------------------------------------------------
	// Atribui o  os índices.  
	//-------------------------------------------------------------------
	oTempTable:SetFields( aStruct )
	cTempKey    := ( cEntidad )->( IndexKey() )
	
	If	cEntidade <> "SU5"
		cTempKey	:= SubStr( cTempKey, At( "+", cTempKey ) + 1, Len( cTempKey ) )
		aKey 		:= StrTokArr( cTempKey, ",-+" )
	Else
		If	cEntidade == "SU5"
			aAdd(aKey,"U5_CODCONT")
		Else
			aAdd(aKey,"BAU_CODIGO")
		Endif
	Endif

	oTempTable:AddIndex("1",aKey)
	
	//------------------
	//Criação da tabela
	//------------------
	oTempTable:Create()  
	
	DbSelectArea(cAliasQry)
	
	nTam 		:= Len(aStruct)

	cNewTab := oTempTable:GetRealName()

	cInsert := " INSERT INTO " + cNewTab
	cInsert += " ( MARK, " + cCpoQry + " ) "
	cInsert += cQuery

	nRetInsert = TCSqlExec( cInsert )
	
	If nRetInsert < 0
		Conout( TCSQLError() )
	EndIf		

	If ( Select( cAliasQry ) > 0 )
	       DbSelectArea( cAliasQry )
	       DbCloseArea()
	EndIf

	DbSelectArea(cTempTab)                                                          
	cFiltro := CRMXFilEnt( cEntidad, .T. ) 
	
	For nI := 1 To Len( aCampos )
	       AAdd( aColumns, FWBrwColumn():New() )
	       aColumns[nI]:SetType(aCampos[nI][3] )
		  //----------------------------------
		  // Tratamento para ComboBox
	   	  //----------------------------------
	       If Empty( aCampos[nI][6] )  
	             aColumns[nI]:SetData( &( "{|| " + aCampos[nI][1] + " }" ) )
	       Else
	             aColumns[nI]:SetData( &( "{|| X3Combo( "+"'"+aCampos[nI][1]+"',"+aCampos[nI][1]+" ) }" ) )   
	       EndIf
	       aColumns[nI]:SetTitle( aCampos[nI][2] )
	       aColumns[nI]:SetSize( aCampos[nI][4] )
		   aColumns[nI]:SetDecimal( aCampos[nI][5] )
	Next nI
	              
	DEFINE DIALOG oDlg TITLE STR0045 FROM 0,0 TO 500,800 PIXEL //"Adicionar Membros à Lista"      
	
	       oMarkBrow:= FWBrowse():New()
	       oMarkBrow:SetDescription( STR0045 )//"Adicionar Membros à Lista"  
	       oMarkBrow:AddMarkColumns( { ||Iif( !Empty( MARK ),"LBOK","LBNO" ) },{ || Tk61MarkDM( oMarkBrow ) }, { || TK61MarlAll( oMarkBrow ), oMarkBrow:Refresh() } )            															             
	       oMarkBrow:SetDataQuery( .F. )
	       oMarkBrow:SetDataTable( .T. )                                            
	       oMarkBrow:SetAlias( cTempTab )
	       oMarkBrow:SetColumns( aColumns )  
	       oMarkBrow:SetDBFFilter()
	       oMarkBrow:SetUseFilter()
		   oMarkBrow:SetOwner( oDlg )  
	       oMarkBrow:Activate()                            
	             
			//Bloco a ser executado ao "Confirmar" a tela -> <CTRL+O>
			bSetConf := { || lConfirm := .T., GetKeys(), SetKey( VK_F3, Nil ), aLista := Tk61MarkOk( oMarkBrow, cEntidad ), Tk61EntGet( aLista ), oDlg:End() }
			
			//Bloco a ser executado ao "Finalizar" a tela -> <CTRL+X>
			bSetFech := { || lConfirm := .F. ,GetKeys(), SetKey( VK_F3, Nil ), oDlg:End() }  
			
		    //Habilitação da EnchoiceBar
			bInitBr  := { || EnchoiceBar( oDlg, bSetConf, bSetFech, Nil ) }
			oDlg:bInit := bInitBr
	          
	ACTIVATE DIALOG oDlg CENTERED     
	
	If( Valtype(oTempTable) == "O")
		oTempTable:Delete()
		FreeObj(oTempTable)
		oTempTable := nil
	EndIf
	
	RestArea( aArea )
EndIf
       
Return( Nil )    

//-------------------------------------------------------------------------
/*/{Protheus.doc} Tk61CpoBrw

Função que adiciona membros à lista de acordo com a entidade selecionada

@sample Tk61CpoBrw( cEntidad )

@param   cEntidad		->		Entidade selecionada     

@return	 aStruct	    -> 		Estrutura do campo (tipo, tamanho...)
		 aCampos	    ->		Campos utilizados
		 cCpoQry		->		Resultado da query

@author Thamara Villa

@since 20/03/2014
@version 12.0
/*/
//-------------------------------------------------------------------------
Static Function Tk61CpoBrw( cEntidad )

Local aArea       := GetArea()
Local aCampos     := {}
Local aStruct	  := {}
Local cCampo      := ""
Local cCpoQry 	  := ""

DbSelectArea( "SX3" )
DbSetOrder( 1 )

If Dbseek( cEntidad )

       While !SX3->( Eof() ) .AND. SX3->X3_ARQUIVO == cEntidad
             cCampo := AllTrim( SX3->X3_CAMPO )
             If ( X3USO( SX3->X3_USADO ) .AND. SX3->X3_CONTEXT <> "V" .AND. SX3->X3_TIPO <> "M") 
                    AAdd( aCampos,{ cCampo, X3Titulo(),SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL,X3CBox() } )
                    AAdd( aStruct,{ cCampo,SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
                    cCpoQry += cCampo+", "
             EndIf
             SX3->( DbSkip() )
       End
       cCpoQry := AllTrim( Padr( cCpoQry, Len( cCpoQry ) -2 ) )   
EndIf

RestArea( aArea )

Return( { aStruct, aCampos, cCpoQry } ) 

//-------------------------------------------------------------------------
/*/{Protheus.doc} Tk61MarkDM

Função de seleção de registros

@sample Tk61MarkDM( oMarkBrow )

@param   oMarkBrow		->		Objeto da do Browse

@author Thamara Villa

@since 20/03/2014
@version 12.0
/*/
//-------------------------------------------------------------------------
Static Function Tk61MarkDM( oMarkBrow )

Local cAliasTmp := (cTempTab)

RecLock( cAliasTmp,.F. )

If Empty( ( cAliasTmp )->MARK )
       ( cAliasTmp )->MARK := cMark
Else
       ( cAliasTmp )->MARK := "" 
EndIf 

MsUnLock()

Return( Nil )   

//-------------------------------------------------------------------------
/*/{Protheus.doc} TK61MarlAll

Marca/Desmarca Todos.

@sample TK61MarlAll( oMarkBrow )

@param   oMarkBrow		->		Objeto da do Browse

@author Thamara Villa

@since 20/03/2014
@version 12.0
/*/
//-------------------------------------------------------------------------
Static Function TK61MarlAll( oMarkBrow )

Local aArea 	 := GetArea()
Local cAlias 	 := (cTempTab) 
Local aAreaAlias := ( cAlias )->( GetArea() )     
Local lMarca	 := .F.
  
( cAlias )->( DbGoTop() )
 lMarca := ( cAlias )->MARK <> cMark
 
 While ( cAlias )->( !EOF() )

  RecLock( cAlias, .F. )   

  	( cAlias )->MARK := Iif( lMarca, cMark, "" )                      
 
  ( cAlias )->( MsUnlock() )
  ( cAlias )->( DbSkip() )                
  
EndDo

RestArea( aAreaAlias ) 
RestArea( aArea )

Return( Nil )

//-------------------------------------------------------------------------
/*/{Protheus.doc} Tk61MarkOk

Pega os registros selecionados para inserir na GetDados

@sample Tk61MarkOk( oMarkBrow )

@param   oMarkBrow		->		Objeto da do Browse
@param   cEntidad	   	->		Entidade Selecionada

@return	 aLista			-> 		Lista de Registros Marcados

@author Thamara Villa

@since 21/03/2014
@version 12.0
/*/
//-------------------------------------------------------------------------
Static Function Tk61MarkOk( oMarkBrow, cEntidad )

Local aArea 	 := GetArea()
Local cAlias 	 := (cTempTab) 
Local aAreaAlias := ( cAlias )->( GetArea() )  	
Local aLista	 := {}
Local cPrefix	 := "" 
Local cCpCod	 := "" 
Local cCpNome	 := ""
Local cCpLoj		:= ""

cPrefix := Iif( Subs( cEntidad, 1, 1 ) == "S", Subs( cEntidad, 2,3 ), cEntidad )

Do case
	Case cEntidade $ 'SA1/SUS'
		cCpCod  := "_COD"
		cCpLoj	 := "_LOJA"
		cCpNome := "_NOME" 
	Case cEntidade == 'ACH'
		cCpCod  := "_CODIGO" 
		cCpLoj	 := "_LOJA"
		cCpNome := "_RAZAO"  
	Case cEntidade == 'BAU'
		cCpCod  := "_CODIGO" 
		cCpLoj	 := "_LOJSA2"
		cCpNome := "_NOME"  
	OTHERWISE
		cCpCod := "_CODCONT"
		cCpLoj	 := "_LOJA" 
		cCpNome := "_CONTAT" 
Endcase

( cAlias )->( DbGoTop() )                                      

While ( cAlias )->( !EOF() ) 
	If AllTrim(( cAlias )->MARK) == AllTrim(cMark)
		If (cEntidade $ 'SA1/SUS/ACH' )
			aAdd( aLista, { ( cAlias )->&( cPrefix + cCpCod ), ( cAlias )->&( cPrefix + cCpLoj ), ( cAlias )->&( cPrefix + cCpNome ) } )
		ElseIf (cEntidade $ 'SU5/BAU' ) 
			aAdd( aLista, { ( cAlias )->&( cPrefix + cCpCod ), "", ( cAlias )->&( cPrefix + cCpNome ) } )
		EndIf 
    EndIf
	( cAlias )->( DbSkip() )                	
EndDo
      
RestArea( aAreaAlias ) 
RestArea( aArea )

Return( aLista )

//-------------------------------------------------------------------------
/*/{Protheus.doc} Tk61EntGet

Adiciona os registros selecionados na GetDados

@sample Tk61EntGet( aLista )
       
@param   aLista		->		Lista os registros selecionados

@return  aGrava		->		Array do aCols

@author Thamara Villa

@since 24/03/2014
@version 12.0
/*/
//-------------------------------------------------------------------------
Static Function Tk61EntGet( aLista )    

Local aArea 		:= GetArea()
Local nPosEnt   	:= aScan( aHeader, { |x|Alltrim( x[2] ) == "U6_CODENT"  } ) // Codigo Entidade
Local nPosEntDsc    := aScan( aHeader, { |x|Alltrim( x[2] ) == "U6_DESCENT" } ) // Nome Entidade
Local nPosCod		:= aScan( aHeader, { |x|Alltrim( x[2] ) == "U6_CODIGO"  } ) // Codigo do Item
Local nPosData  	:= aScan( aHeader, { |x|Alltrim( x[2] ) == "U6_DATA"  	} ) // Data
Local nPosTab		:= aScan( aHeader, { |x|Alltrim( x[2] ) == "U6_ENTIDA"  } ) // Entidade Selecionada
Local nPosHrFim     := aScan( aHeader, { |x|Alltrim( x[2] ) == "U6_HRFIM" 	} ) // Hora Final
Local nPosHrIni     := aScan( aHeader, { |x|Alltrim( x[2] ) == "U6_HRINI" 	} ) // Hora Inicio
Local nPosCont		:= aScan( aHeader, { |x|Alltrim( x[2] ) == "U6_CONTATO" } ) // Codigo Contato
Local nPosConDsc	:= aScan( aHeader, { |x|Alltrim( x[2] ) == "U6_NCONTAT" } ) // Nome Contato    
Local nPosDEnt		:= aScan( aHeader, { |x|Alltrim( x[2] ) == "U6_DENTIDA" } ) // Descrição da Entidade         
Local nDel 			:= Len( aHeader ) 
Local nLista		:= 0  
Local nScan			:= 0
Local nPosReg		:= 0  
Local nCols			:= 0  
Local cDescEnt		:= ""

Default aLista 		:= {}                                                    

Static aSelec		:= {}


If !Empty( cEntidade ) 
	cDescEnt := Posicione("SX2",1,cEntidade,"X2Nome()") 
EndIf

//----------------------------------------------------------------------------------------------------------
// Verifica se o(s) registro(s) selecionado(s) existe(m) no aCols, se existir(em), desconsidera a inclusão.
//----------------------------------------------------------------------------------------------------------
For nLista := 1 To Len( aLista )
	If cEntidade <> 'SU5'  .Or. cEntidade <> 'BAU'
		nScan := aScan( aCols, { |x| AllTrim( x[ nPosEnt ] ) == AllTrim( aLista[ nLista ][ 1 ] + aLista[ nLista ][ 2 ] ) } )
	Else
		nScan := aScan( aCols, { |x| AllTrim( x[ nPosCont ] ) == AllTrim( aLista[ nLista ][ 1 ] ) } )
	EndIf
	
	If nScan == 0	
		If nLista >= 2 .And. nLista <= Len( aLista ) .Or. nLista == 1 .And.;
			( !Empty( aCols[ 1 ][ nPosEnt ] ) .Or. !Empty( aCols[ 1 ][ nPosCont ] ) )
			aAdd( aCols, Array( nDel + 1 ) )
		EndIf	
		nCols := Len( aCols )
		If cEntidade <> 'SU5' .Or. cEntidade <> 'BAU'
			aCols[ nCols ][ nPosEnt  ]    := aLista[ nLista ][ 1 ] + aLista[ nLista ][ 2 ]
			aCols[ nCols ][ nPosEntDsc ]  := aLista[ nLista ][ 3 ]
		Else
			aCols[ nCols ][ nPosCont  ]   := aLista[ nLista ][ 1 ]
			If nPosConDsc > 0
				aCols[ nCols ][ nPosConDsc ]  := aLista[ nLista ][ 3 ] 
			EndIf
		EndIf
		
		aCols[ nCols ][ nPosCod ]     := IIF(Empty(aCols[ nCols ][ nPosCod ]),GetSx8Num( "SU6", "U6_CODIGO" ),aCols[ nCols ][ nPosCod ])
		aCols[ nCols ][ nPosData ]    := CriaVar( "U6_DATA"   , .T. )
		aCols[ nCols ][ nPosTab ]	  := cEntidade
		If nPosDEnt > 0
			aCols[ nCols ][ nPosDEnt ]    := cDescEnt
		EndIf
		aCols[ nCols ][ nPosHrFim ]   := CriaVar( "U6_HRFIM"  , .T. )
		aCols[ nCols ][ nPosHrIni ]   := CriaVar( "U6_HRINI"  , .T. )
		aCols[ nCols ][ nDel + 1 ]    := .F.
		
		If ALTERA
			aAdd( aSelec, aCols[ nCols ] )
		EndIf

	EndIf
Next( nLista ) 

RestArea( aArea ) 

Return( aCols )                 

//-------------------------------------------------------------------------
/*/{Protheus.doc} TK61ButEnt()                                                       

Verifica se existe registro na GetDados para Bloquear a alteracao de alias
através do botão de entidade.

@sample TK61ButEnt()

@author Thamara Villa

@since 25/03/2014
@version 12.0
/*/
//-------------------------------------------------------------------------
Static Function TK61ButEnt()

Local lRet 		:= .T.
Local nCols 	:= Len( aCols ) 
Local nPosCont	:= aScan( aHeader, { |x|Alltrim( x[2] ) == "U6_CONTATO" } ) // Codigo Contato
Local nPosEnt   := aScan( aHeader, { |x|Alltrim( x[2] ) == "U6_CODENT"  } ) // Codigo Entidade

If nModulo == 73 
	If nCols == 1 .And. ( !Empty( aCols[ 1 ][ nPosEnt ] ) .Or. !Empty( aCols[ 1 ][ nPosCont ] ) )  
		lRet := .F.
	Else 
		lRet := Len( aCols ) <= 1                                                             	
	EndIf	
EndIf       

Return( lRet )                           

//-------------------------------------------------------------------------
/*/{Protheus.doc} TK61DtList()

Grava a data da ultima utilizacao da lista.

@sample TK61DtList( cFilial, cCodigo )                                                       

@param   cFilial		->		Filial da Lista
@param   cCodigo		->		Codigo da Lista

@author Thamara Villa

@since 27/03/2014
@version 12.0
/*/
//-------------------------------------------------------------------------
Function TK61DtList( cCodigo )                                                       

Local aArea := GetArea()    
Local lRet	:= .T.       

Default cCodigo := ""

DbSelectArea( "SU4" )
DbSetOrder( 1 ) //U4_FILIAL+U4_LISTA+DTOS(U4_DATA)                                                                                                                                
If DbSeek( xFilial( "SU4" ) + cCodigo )
	RecLock( "SU4", .F. )
	Replace U4_DTUTIL With dDataBase
	MsUnLock()    
Else
	lRet := .F.
EndIf

RestArea( aArea )

Return( lRet )         
//-------------------------------------------------------------------------
/*/{Protheus.doc} TK61Change

Grava a grid quando for alteração

@sample TK61Change( )

@return lRet 	-> Verdadeiro ou Falso.                                                       

@author Thamara Villa

@since 27/03/2014
@version 12.0
/*/
//-------------------------------------------------------------------------
Function TK61Change()

Local aArea   		:= GetArea() 
Local nPosCod		:= aScan( aHeader, { |x|Alltrim( x[2] ) == "U6_CODIGO"  } ) // Codigo do Item
Local nPosCont		:= aScan( aHeader, { |x|Alltrim( x[2] ) == "U6_CONTATO" } ) // Codigo Contato
Local nPosEnt   	:= aScan( aHeader, { |x|Alltrim( x[2] ) == "U6_CODENT"  } ) // Codigo Entidade
Local nPosHrFim     := aScan( aHeader, { |x|Alltrim( x[2] ) == "U6_HRFIM" 	} ) // Hora Final
Local nPosHrIni     := aScan( aHeader, { |x|Alltrim( x[2] ) == "U6_HRINI" 	} ) // Hora Inicio
Local nLenSX8		:= GetSx8Len()
Local nX	  		:= 0   
Local cFieldName	:= ""
Local lRet 	  		:= .T.    
Local nTamSelec		:= Len( aSelec )
Local aDelete			:= {}

//----------------------------------------------------
// Grava campos do cabeçalho na Alteração no SIGACRM
//----------------------------------------------------                             
DbSelectArea( "SU4" )   // Lista de Contatos
DbSetOrder( 1 ) 		// U4_FILIAL+U4_LISTA+DTOS(U4_DATA)                                                                                                                                
RecLock( "SU4", .F. )
	For nX := 1 To FCount()
		cFieldName := FieldName( nX )
		Do Case
			Case AllTrim( cFieldName ) == "U4_DESC"
				SU4->U4_DESC := M->U4_DESC
			Case AllTrim( cFieldName ) == "U4_CUSTO"
				SU4->U4_CUSTO := M->U4_CUSTO 
			Case AllTrim( cFieldName ) == "U4_DATA"
				SU4->U4_DATA := M->U4_DATA
			Case AllTrim( cFieldName ) == "U4_ORIGEM"
				SU4->U4_ORIGEM := M->U4_ORIGEM
			OtherWise
				FieldPut( nX, M->&(cFieldName) )
		EndCase
	Next nX
MsUnLock()

//---------------------------------------------
// Grava Itens quando for Alteração no SIGACRM
//---------------------------------------------
If nTamSelec > 0
	For nX := 1 To nTamSelec
		If RecLock( "SU6", .T. )
			
			Replace U6_FILIAL  With xFilial( "SU6" )  			// Filial
			Replace U6_LISTA   With M->U4_LISTA  				// Codigo da Lista
			Replace U6_CODIGO  With aSelec[ nX ][ nPosCod ]  	// Codigo da interação
			If M->U4_ENTIDA == 'SU5'
				Replace U6_CONTATO With aSelec[ nX ][ nPosCont ]  	// Contato
			Else
				Replace U6_CONTATO With ""
			EndIf
			Replace U6_FILENT  With xFilial( M->U4_ENTIDA )  	// Filial da Entidade
			Replace U6_ENTIDA  With M->U4_ENTIDA                // Entidade
			Replace U6_CODENT  With aSelec[ nX ][ nPosEnt ]  	// Codigo da Entidade
			Replace U6_DATA    With M->U4_DATA	                // Data
			Replace U6_HRINI   With aSelec[ nX ][ nPosHrFim ] 	// Hora Inicio
			Replace U6_HRFIM   With aSelec[ nX ][ nPosHrIni ] 	// Hora Fim
			Replace U6_STATUS  With "1"      					// Status
			Replace U6_DTBASE  With dDataBase					// DataBase
			
			MsUnlock()
			ConfirmSX8()
			
		Else
			lRet := .F.
			While GetSx8Len() > nLenSX8
				RollBackSX8()
			EndDo
		EndIf
	Next( nX )
	If lRet
		// Atualiza os membros da lista na AOG (Membros da Campanha)
		Tk310AUpdAOG(aSelec, .T., M->U4_LISTA, M->U4_ENTIDA)
	EndIf	
EndIf
         
//--------------------------------------------------------------------------------
// Em caso de alteracao serao apagados os itens que estiverem deletados do aCols.
//--------------------------------------------------------------------------------
DbSelectArea( "SU6" )   // Itens da lista de Contatos
DbSetOrder( 1 ) 		// U6_FILIAL+U6_LISTA+U6_CODIGO
For nX:= 1 To Len( aCols )
	If aCols[ nX ][ Len( aHeader ) +1 ]
		If DbSeek( xFilial( "SU6" ) + M->U4_LISTA+ aCols[ nX ][ Ascan( aHeader, {|aVal| Alltrim( aVal[ 2 ] ) == "U6_CODIGO" } ) ] )
			Reclock( "SU6", .F., .T. )
			DbDelete()
			MsUnlock()
			aAdd(aDelete,aCols[ nX ])
		Endif
	Endif
Next( nX )

If Len(aDelete) > 0
	// Atualiza os membros da lista na AOG (Membros da Campanha)
	Tk310AUpdAOG(aDelete, .F., M->U4_LISTA, M->U4_ENTIDA)
EndIf

//Zera o Array
aSelec := {}

RestArea( aArea )

Return( lRet )
//-------------------------------------------------------------------------
/*/{Protheus.doc} TK61Dsc()

Traz a descrição dos campos virtuais no Grid.

@sample TK61Dsc( aCols, aHeader )

@param   aCols		->		aCols da GetDados
@param   aHeader	->		aHeader da GetDados 

@return	 Nulo

@author Thamara Villa

@since 30/03/2014

@version 12.0
/*/
//-------------------------------------------------------------------------
Function TK61Dsc( aCols, aHeader )
                                         
Local aArea 		:= GetArea()
Local nPosTab		:= aScan( aHeader, { |x|Alltrim( x[2] ) == "U6_ENTIDA"  } ) // Entidade Selecionada
Local nPosEnt   	:= aScan( aHeader, { |x|Alltrim( x[2] ) == "U6_CODENT"  } ) // Codigo Entidade
Local nPosEntDsc    := aScan( aHeader, { |x|Alltrim( x[2] ) == "U6_DESCENT" } ) // Nome Entidade
Local nPosCont		:= aScan( aHeader, { |x|Alltrim( x[2] ) == "U6_CONTATO" } ) // Codigo Contato
Local nPosConDsc	:= aScan( aHeader, { |x|Alltrim( x[2] ) == "U6_NCONTAT" } ) // Nome Contato                                                 
Local cTabela 		:= ""   
Local cCpoRet		:= ""
Local nAcols  		:= Len( aCols )
Local nX 			:= 0                                                                                                     

If nAcols > 0  
	cTabela := aCols[ 1 ][ nPosTab ]                     
EndIf

If !Empty( cTabela )
	If cTabela == "SUS"
		cCpoRet := "US_NOME"                     
		
	ElseIf cTabela == "SA1"
		cCpoRet := "A1_NOME"                     
		
	ElseIf cTabela == "ACH"
		cCpoRet := "ACH_RAZAO"                     
	
	ElseIf cTabela == "SU5"
		cCpoRet := "U5_CONTAT"                     		
	ElseIf cTabela == "BAU"
		cCpoRet := "BAU_NOME"                        		
	EndIf                  
	    
	If cTabela <> "SU5" .Or. cTabela <> "BAU"
		For nX := 1 To nAcols
			aCols[ nX ][ nPosEntDsc ] := Posicione( cTabela, 1, xFilial( cTabela ) + AllTrim( aCols[ nX ][ nPosEnt ] ), cCpoRet )
		Next( nX ) 
	Else
		For nX := 1 To nAcols
			aCols[ nX ][ nPosConDsc ] := Posicione( cTabela, 1, xFilial( cTabela ) + AllTrim( aCols[ nX ][ nPosCont ] ), cCpoRet )
		Next( nX ) 
	EndIf
EndIf

RestArea( aArea )

Return( Nil )

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
