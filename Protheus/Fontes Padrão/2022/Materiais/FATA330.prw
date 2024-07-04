#include "FATA330.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TopConn.ch"
#INCLUDE "CRMDEF.CH"

#DEFINE LIST_CONTATOS 	1
#DEFINE LIST_CLIENTES 	2
#DEFINE LIST_PROSPECTS	3

//--------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FATA330()
Exibe tela para associacao de contatos importados e contas do representante ativo

@author Vendas CRM
@since 04/06/2013
/*/
//--------------------------------------------------------------------------------------------------------------

Function FATA330( lSigaCRM )

Local oDlg				:= Nil
Local oPanel			:= Nil
Local oFWLayer		:= Nil
Local oFWLayerSinc	:= Nil
Local aCoors        := FWGetDialogSize(oMainWnd)
Local nTimerSinc    := 15

Local oLContatos
Local oLbxContatos
Local cContatos
Local aContatos
	
Local oLClientes
Local oLbxClientes
Local cClientes
Local aClientes

Local oLProspects
Local oLbxProspects
Local cProspects
Local aProspects	

Local aGeral := {}

Local oSincroniz := Nil
Local oConfirmar := Nil
Local oCancelar  := Nil
Local oLOpcoes   := Nil

Local oCOLTWO    := Nil

Local oTimer := Nil
Local aInfo  := {} 
Local aObj   := {} 
Local aPObj  := {} 
Local aPGet  := {}

Local aAreaAO3 := {}
Local cCodUsr  := ""
Local cCodVend := ""
Local lTrhCRM  := .F. // se foi criada uma thread para o crm
Local aInfoUser := {}
Local aFieldsPD :={"A1_NOME", "US_NOME", "ADL_NOME", "U5_CONTAT","U5_EMAIL"}

Default lSigaCRM := .F.

Private lFiltroCRM := lSigaCRM

FATPDLoad(Nil, Nil, aFieldsPD)

If nModulo == 73
	cCodUsr :=  RetCodUsr() //codigo do usuario
	If Select("AO3") > 0
		aAreaAO3 := AO3->(GetArea())	
	Else
		DbSelectArea("AO3")// Usuario do CRM
	EndIf	
	AO3->(DbSetOrder(1))//AO3_FILIAL+AO3_CODUSR
Else
	cCodVend := Ft320RpSel()
EndIf

/*
aGeral -> { codContato | {aClientes} | {aProspects} }
aContatos -> { CodContato | Nome | Email }
aClientes -> { Selecionado | CodCli | Loja | Nome | Filial } 


Definição Conceitual:
O aGeral contem todos os contatos e para cada contato um array de clientes e um de prospects para montar os grids
No changeline da lista de contatos, o sistema ira carregar nos grids de clientes e prospects os arrays referentes aquele contato
Os Arrays utilizados nos grids serao temporarios contendo apenas a lista de clientes ou prospects do contato selecionado no momento
Em cada marcacao feita (selecao de cliente ou prospect) o sistema ira atualizar os respectivos arrays de clientes e prospects do contato no array aGeral

*/

If nModulo == 73
	If !Empty(cCodUsr) .AND. AO3->(DbSeek(xFilial("AO3")+cCodUsr))	// Verifica se é um usuario do CRM
		aInfoUser := CRM170GetS(.T.)
		If aInfoUser[_PREFIXO][_Habilita]
			CRM170AThr()
			CreateSyncSession(cValToChar(ThreadId()))
			lTrhCRM := .T. 
			CRMA170EXG(.T.,aInfoUser)// chama a sincronização automatica
			nTimerSinc := IIF(!Empty(aInfoUser[_PREFIXO][_TimeMin]),Val(aInfoUser[_PREFIXO][_TimeMin]),nTimerSinc)// valor padrao 10, caso o _TimeMin venha vazio
		EndIf 
	EndIf  
EndIf	

oDlg := FWDialogModal():New()
oDlg:SetBackground(.F.) 
oDlg:SetTitle(STR0001) //"Associacao Contatos x Contas"
oDlg:SetEscClose(.T.)
oDlg:EnableAllClient() 
oDlg:EnableFormBar(.F.) 
oDlg:CreateDialog() 

oPanel := oDlg:GetPanelMain()
	
// Configura o FWLayer	
oFWLayer := FWLayer():New()
oFWLayer:Init( oPanel, .F. )

oFWLayer:AddCollumn("Coluna 1", 50,.T. )
oFWLayer:AddWindow( "Coluna 1", "Window 1", STR0002, 50, .T., .F.) //"Contatos"
oFWLayer:AddWindow( "Coluna 1", "Window 4", STR0003, 50, .T., .F.)//"Opções"
oFWLayer:AddCollumn("Coluna 2", 50,.T. )	
oFWLayer:AddWindow( "Coluna 2", "Window 2", STR0004, 50, .T., .F. )	//"Clientes"
oFWLayer:AddWindow( "Coluna 2", "Window 3", STR0005, 50, .T., .F. )//"Prospects"

oLContatos		:= oFWLayer:GetWinPanel( "Coluna 1", "Window 1" )	
oLClientes		:= oFWLayer:GetWinPanel( "Coluna 2", "Window 2" )		
oLProspects	:= oFWLayer:GetWinPanel( "Coluna 2", "Window 3" )
oLOpcoes		:= oFWLayer:GetWinPanel( "Coluna 1", "Window 4" )

oFWLayerSinc := FWLayer():New()
oFWLayerSinc:Init( oLOpcoes, .F. )

oFWLayerSinc:AddLine("LINEONE",30,.F.,Nil)
oFWLayerSinc:AddLine("LINETWO",70,.F.,Nil)

oLINEONE  := oFWLayerSinc:getLinePanel("LINEONE")
oLINETWO  := oFWLayerSinc:getLinePanel("LINETWO")

@ 01,01 LISTBOX oLbxContatos  VAR cContatos  FIELDS HEADER STR0006, STR0008, STR0007 SIZE 290,170 OF oLContatos PIXEL //"Codigo"//"Email"//"Nome"
oLbxContatos:Align := CONTROL_ALIGN_ALLCLIENT

@ 01,01 LISTBOX oLbxClientes  VAR cClientes  FIELDS HEADER " ",STR0009, STR0010, STR0011 SIZE 290,170 OF oLClientes PIXEL //"Codigo"//"Loja"//"Nome"
oLbxClientes:Align := CONTROL_ALIGN_ALLCLIENT

@ 01,01 LISTBOX oLbxProspects VAR cProspects FIELDS HEADER " ",STR0012, STR0013, STR0014 SIZE 290,170 OF oLProspects PIXEL //"Codigo"//"Loja"//"Nome"
oLbxProspects:Align := CONTROL_ALIGN_ALLCLIENT

@ 005, 045 BUTTON oConfirmar PROMPT STR0015 SIZE 036, 012 OF oLINEONE PIXEL ACTION (IF(FT330AssociaCont(aGeral), oDlg:Deactivate(), Nil))//"Confirmar"
@ 005, 085 BUTTON oCancelar  PROMPT STR0016 SIZE 036, 012 OF oLINEONE PIXEL ACTION ( oDlg:Deactivate() )//"Cancelar"
	
//configura lisbox
aContatos := FT330GetDados(LIST_CONTATOS)

If Len(aContatos) > 0

	//----------------------------------------------------------------------------------------
	//Para a montagem dos grids de clientes e prospecs existem os pontos de entrada 
	//FT330CLI e FT330PRO que recebem como parametro o codigo do vendedor (representante)
	//e devem retornar um array com os clientes ou prospects na seguinte estrutura:
	// { .F. | Codigo da entidade | Loja | Nome | Filial } 
	// ----------------------------------------------------------------
	// .F. - Será usado para o usuário marcar a associacao com a entidade
	// Codigo da entidade = codigo do Cliente ou Prospect
	// Loja = Loja do Cliente ou Prospect
	// Filial = Filial do Cliente ou Prospect
	//----------------------------------------------------------------------------------------
	If ExistBlock("FT330CLI")
		aClientes := ExecBlock("FT330CLI",.F.,.F., {cCodVend})
	Else
		aClientes := FT330GetDados(LIST_CLIENTES)
	EndIf
	
	If ExistBlock("FT330PRO")
		aProspects := ExecBlock("FT330PRO",.F.,.F., {cCodVend})
	Else
		aProspects := FT330GetDados(LIST_PROSPECTS)
	EndIf
	
	aGeral := FT330AgrupaArrays(aContatos, aClientes, aProspects)
		
	Ft330CntList(oLbxContatos, aContatos, aGeral, oLbxClientes, oLbxProspects)
	Ft330ListCliPros(oLbxClientes, aClientes, aGeral, aContatos[oLbxContatos:nAt][1], LIST_CLIENTES)
	Ft330ListCliPros(oLbxProspects, aProspects, aGeral, aContatos[oLbxContatos:nAt][1], LIST_PROSPECTS)
EndIf	

If nModulo == 73
	CRMA180MTS(oLINETWO)// monta tela Status da sincronização
	@ 005, 005 BUTTON oSincroniz PROMPT STR0018 SIZE 036, 012 OF oLINEONE PIXEL ACTION (CRM170GetS(.F.) )//"Sincronizar"
	
	If Len(aInfoUser) > 0 .AND. aInfoUser[_PREFIXO][_Habilita]
		oDlg:SetTimer(nTimerSinc *60000,{|| IIF(aInfoUser[_PREFIXO][_Habilita],CRMA170EXG(.T.,aInfoUser),Nil) })
	EndIf
	
EndIf

FATPDLogUser('FATA330')	// Log de Acesso LGPD
oDlg:Activate() //ativa a janela 

If lTrhCRM
	(EndSyncSession(cValToChar(ThreadId())))
EndIf

FATPDUnload()

Return 


//--------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Ft330CntList()
Configura listbox de contatos

@param oListBox listbox de contatos
@param aContatos array com lista de contatos 
@param aGeral array com lista de contatos e listas de clientes e prospects de cada contato 
@param oLbxClientes listbox de clientes 
@param oLbxProspects listbox de prospects

@author Vendas CRM
@since 04/06/2013
/*/
//--------------------------------------------------------------------------------------------------------------
Function Ft330CntList(oListBox, aContatos, aGeral, oLbxClientes, oLbxProspects) 

Local aPDCols := {}

If 	Len(aContatos) > 0
	
	oListBox:SetArray( aContatos  )
	oListBox:bLine := 	{||	{	;
										aContatos[oListBox:nAt,1]	,;
										aContatos[oListBox:nAt,2]	,;
										aContatos[oListBox:nAt,3]	,;								
										}	;
									}
									
	oListBox:Refresh()
									
	oListBox:bChange := {|| FT330ChangeLine(aGeral, aContatos[oListBox:nAt,1], oLbxClientes, oLbxProspects ) } //troca o aContas de cliente e prospect buscando os arrays do aGeral referente ao novo contato posicionado
	
	If FATPDActive() .And. FTPDUse(.T.)
		aPDCols := {"","U5_CONTAT","U5_EMAIL", ""}
		oListBox:aObfuscatedCols := FATPDColObfuscate(aPDCols) 
	Endif
EndIf
									
Return


//configura listbox de clientes ou prospects (o aContas deve ser ja o relativo ao contato selecionado)
Function Ft330ListCliPros(oListBox, aContas, aGeral, cCodContato, cTypeCliPros)

Local aPDCols := {}
 
If 	!Empty(cCodContato) .AND. Len(aContas) > 0
	oListBox:SetArray( aContas )
	
	oListBox:bLine := 	{||	{	;
										IIF(aContas[oListBox:nAt,1], LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) ,;	 //verifica se o registro (cliente ou prospect esta selecionado para alterar o checkbox
										aContas[oListBox:nAt,2]	,;
										aContas[oListBox:nAt,3]	,;
										aContas[oListBox:nAt,4]	,;								
										}	;
									}
									
	oListBox:Refresh()
										
	
	oListBox:bLDblClick := {|| FT330SelItem(oListBox, aContas,oListBox:nAt, aGeral, cCodContato, cTypeCliPros) }
	
	If (nModulo == 73)
		Do Case
			Case cTypeCliPros == LIST_CLIENTES
				aPDCols := {"", "", "", "A1_NOME",""}
			
			Case cTypeCliPros == LIST_PROSPECTS
				aPDCols := {"", "", "", "US_NOME",""}
		End Case
	Else
		aPDCols := {"", "", "", "ADL_NOME",""}
	EndIf

	If FATPDActive() .And. FTPDUse(.T.)
		oListBox:aObfuscatedCols := FATPDColObfuscate(aPDCols) 
	Endif
EndIf
									
Return


//--------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FT330GetDados()
Busca dados da base para montar arrays de contatos, clientes ou prospect

@param nType 1 = Contatos / 2 = Clientes / 3 = Prospects

@return aContas array com dados da entidade
@author Vendas CRM
@since 04/06/2013
/*/
//--------------------------------------------------------------------------------------------------------------
Function FT330GetDados(nType)

Local aContas    := {}
Local cWhere     := ""
Local cQuery     := ""
Local cCodUsr    := ""
Local cCodVend   := ""
Local cOperador  := IIf(Trim(Upper(TcGetDb())) $ "ORACLE,POSTGRES,DB2,INFORMIX","||","+")

If nModulo == 73
	cCodUsr :=  RetCodUsr() //Usuario logado
Else
	cCodVend := Ft320RpSel()
EndIf

If Select("TMPCONT") > 0
	DBSelectArea("TMPCONT")   
	TMPCONT->(DBCloseArea())
EndIf

If nType == LIST_CONTATOS
	// Busca contatos relacionados com o representante que estao pendendes de associacao.
	//If nModulo == 73 // verificando o  modulo que está conectado
	If lFiltroCRM
		cQuery := " SELECT DISTINCT SU5.U5_CODCONT , SU5.U5_CONTAT, SU5.U5_EMAIL FROM " +RetSqlName("SU5")+ " SU5 "+CRLF
		cQuery += " INNER JOIN " + RetSqlName( "AO4" ) + " AO4 ON (SU5.U5_FILIAL " + cOperador + " SU5.U5_CODCONT) = AO4.AO4_CHVREG AND AO4.D_E_L_E_T_ = ''"  
		cQuery += " WHERE SU5.D_E_L_E_T_ = '' AND SU5.U5_FILIAL = '" + xFilial("SU5") + "' AND SU5.U5_CODUSR = '" +  cCodUsr + "'"
		cQuery += " AND SU5.U5_CODCONT NOT IN (SELECT DISTINCT AC8.AC8_CODCON FROM " +RetSqlName("AC8")+ " AC8 Where AC8.D_E_L_E_T_ = '' )"
	Else
		cQuery := " SELECT DISTINCT SU5.U5_CODCONT , SU5.U5_CONTAT, SU5.U5_EMAIL FROM " +RetSqlName("SU5")+ " SU5 "+CRLF
		cQuery += " WHERE SU5.D_E_L_E_T_ = '' AND SU5.U5_FILIAL = '" + xFilial("SU5") + "' AND SU5.U5_CODSA3 = '" +  cCodVend + "'"
		cQuery += " AND SU5.U5_CODCONT NOT IN (SELECT DISTINCT AC8.AC8_CODCON FROM " +RetSqlName("AC8")+ " AC8 Where AC8.D_E_L_E_T_ = '' )"
	EndIf	
ElseIf nType == LIST_CLIENTES
	// Busca clientes relacionados com o representante
	//If nModulo == 73 // verificando o  modulo que está conectado
	If lFiltroCRM
	   cWhere := CRMXFilEnt("SA1",.T.)
	   If !Empty( cWhere )
			cWhere += " AND " 
			cQuery := " SELECT DISTINCT SA1.A1_COD , SA1.A1_FILIAL , SA1.A1_LOJA, SA1.A1_NOME  FROM " +RetSqlName("SA1")+ " SA1 "+CRLF
			cQuery += "INNER JOIN " + RetSqlName( "AO4" ) + " AO4 ON (SA1.A1_FILIAL " + cOperador + "SA1.A1_COD " + cOperador + " SA1.A1_LOJA) = AO4.AO4_CHVREG "
			cQuery += "WHERE " + cWhere + " SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = '" + xFilial("SA1") + "'"
		EndIf
	Else 
		cQuery := " SELECT DISTINCT ADL.ADL_CODENT , ADL.ADL_FILENT , ADL.ADL_LOJENT, ADL.ADL_NOME FROM " +RetSqlName("ADL")+ " ADL "+CRLF
		cQuery += " WHERE ADL.D_E_L_E_T_ = '' AND ADL.ADL_FILIAL = '" + xFilial("ADL") + "' AND ADL.ADL_VEND = '" +  cCodVend + "'"
		cQuery += " AND ADL_ENTIDA = 'SA1' "
   EndIf
ElseIf nType == LIST_PROSPECTS
	// Busca prospects relacionados com o representante
	//If nModulo == 73 // verificando o  modulo que está conectado
	If lFiltroCRM
   		cWhere := CRMXFilEnt("SUS",.T.)
   		If !Empty(cWhere)
			cWhere += " AND " 
			cQuery := " SELECT DISTINCT SUS.US_COD , SUS.US_FILIAL , SUS.US_LOJA, SUS.US_NOME  FROM " +RetSqlName("SUS")+ " SUS "+CRLF
			cQuery += "INNER JOIN " + RetSqlName( "AO4" ) + " AO4 ON (SUS.US_FILIAL " + cOperador + " SUS.US_COD " + cOperador + " SUS.US_LOJA) = AO4.AO4_CHVREG "
			cQuery += "WHERE "+cWhere+" SUS.D_E_L_E_T_ = '' AND SUS.US_FILIAL = '"+xFilial("SUS")+"'"
		EndIf 
	Else
		cQuery := " SELECT DISTINCT ADL.ADL_CODENT , ADL.ADL_FILENT , ADL.ADL_LOJENT, ADL.ADL_NOME FROM " +RetSqlName("ADL")+ " ADL "+CRLF
		cQuery += " WHERE ADL.D_E_L_E_T_ = '' AND ADL.ADL_FILIAL = '" + xFilial("ADL") + "' AND ADL.ADL_VEND = '" +  cCodVend + "'"
		cQuery += " AND ADL_ENTIDA = 'SUS' "
   EndIf
EndIf

If !Empty(cQuery)
	cQuery := ChangeQuery(cQuery)
	TcQuery cQuery NEW ALIAS "TMPCONT" 
	While TMPCONT->(!Eof())
		If nType == LIST_CONTATOS	
			Aadd(aContas,{TMPCONT->U5_CODCONT, TMPCONT->U5_CONTAT, TMPCONT->U5_EMAIL})
		Else
		   If nModulo == 73 
		      IF nType == LIST_CLIENTES
		      		 Aadd(aContas,{.F., TMPCONT->A1_COD, TMPCONT->A1_LOJA, TMPCONT->A1_NOME, TMPCONT->A1_FILIAL})
		      ElseIf nType == LIST_PROSPECTS
		      		 Aadd(aContas,{.F., TMPCONT->US_COD, TMPCONT->US_LOJA, TMPCONT->US_NOME, TMPCONT->US_FILIAL})	     
		      EndIf 
		   Else
				Aadd(aContas,{.F., TMPCONT->ADL_CODENT, TMPCONT->ADL_LOJENT, TMPCONT->ADL_NOME, TMPCONT->ADL_FILENT})
		   EndIf	
		EndIf
		TMPCONT->(dbSkip())
	EndDo
	TMPCONT->(DBCloseArea())
EndIf

Return aContas

//--------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FT330AgrupaArrays()
Junta listas de contatos, prospect e clientes em um array só

@param aContatos array de contatos
@param aClientes array de clientes
@param aProspects array de prospects
@return aRet array com todos os dados agrupados
@author Vendas CRM
@since 04/06/2013
/*/
//--------------------------------------------------------------------------------------------------------------
Function FT330AgrupaArrays(aContatos, aClientes, aProspects)
/*
aGeral -> { codContato | {aClientes} | {aProspects} }
aClientes -> { Selecionado | CodCli | Loja | Nome } 
*/

Local aRet := {}
Local nX := 0

For nX := 1 to Len(aContatos)
	Aadd(aRet,{aContatos[nX,1], AClone(aClientes), AClone(aProspects) } )
Next nX


Return aRet



//--------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FT330SelItem()
Realiza a selecao do registro (marca ou desmarca flags)

@author Vendas CRM
@since 04/06/2013
/*/
//--------------------------------------------------------------------------------------------------------------
Function FT330SelItem(oListBox, aContas, nPosItem, aGeral, cCodContato, cTypeCliPros)

//inverte selecao
aContas[nPosItem,1] := !aContas[nPosItem,1]
//atualiza listbox
Ft330ListCliPros(oListBox, aContas, aGeral, cCodContato, cTypeCliPros) 

//atualiza aGeral - array de todos os contatos
FT330AtuGeral(aContas, aGeral, cCodContato, cTypeCliPros)

Return


//--------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FT330AtuGeral()
Atualiza array geral com dados do array utilizado no momento nos listbox clientes ou prospects

@param aContas array de dados do listbox
@param aGeral array geral (junção dos contatos + clientes e prospects para cada contato)
@param cCodContato codigo do contato posicionado
@param cTypeCliPros define se o array aContas é referente a clientes ou prospects

@author Vendas CRM
@since 04/06/2013
/*/
//--------------------------------------------------------------------------------------------------------------

Function FT330AtuGeral(aContas, aGeral, cCodContato, cTypeCliPros)
Local nType := 0
Local nPosGeral := 0

If cTypeCliPros == LIST_CLIENTES
	nType := 2
ElseIF cTypeCliPros == LIST_PROSPECTS
	nType := 3
EndIf

//Atualiza o array de clientes ou prospects do contato no array geral
nPosGeral := aScan(aGeral, {|x| x[1] == cCodContato } )
If nType > 0 .AND. nPosGeral > 0
	aGeral[nPosGeral][nType] := AClone(aContas)
EndIf

Return



//--------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FT330ChangeLine()
Atualiza ListBox de clientes e prospects com dados do aGeral do respectivo contato

@return aRet array com todos os dados agrupados
@author Vendas CRM
@since 04/06/2013
/*/
//--------------------------------------------------------------------------------------------------------------
Function FT330ChangeLine(aGeral, cCodContato, oLbxClientes, oLbxProspects )

nPosGeral := aScan(aGeral, {|x| x[1] == cCodContato } )

Ft330ListCliPros(oLbxClientes, aGeral[nPosGeral][2], aGeral, cCodContato, LIST_CLIENTES)
Ft330ListCliPros(oLbxProspects, aGeral[nPosGeral][3], aGeral, cCodContato, LIST_PROSPECTS)

Return


//--------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FT330AssociaCont()
associa os contatos com as contas selecionadas

@param aGeral array geral (junção dos contatos + clientes e prospects para cada contato)

@return lRet .T. se o usuario confirmou a associacao
@author Vendas CRM
@since 04/06/2013
/*/
//--------------------------------------------------------------------------------------------------------------
Function FT330AssociaCont(aGeral)
/*
aGeral -> { codContato | {aClientes} | {aProspects} }
aContatos -> { CodContato | Nome | Email }
aClientes -> { Selecionado | CodCli | Loja | Nome | FilEnt }
*/
Local lRet := .F.
Local nCountGeral :=0 
Local nCountCli :=0
Local nCountPros := 0


//Exibe pergunta de confirmacao para o usuario
lRet := MsgNoYes(STR0017) //"Confirma a associação dos contatos com as entidades selecionadas?"

If lRet

	//----------------------------------------------------------------------------------------
	//Para a realizar a associacao dos contatos com as entidades (clientes ou prospects) 
	//existem o pontos de entrada FT330ASS que recebe um array contendo as associacoes definidas 
	//pelo usuario que devem ser processadas. 
	//O array contem a seguinte estrutura
	// { codContato | {aClientes} | {aProspects} }
	// Onde, aClientes e aProspects possuem a seguinte estrutura 
	// aClientes ou aProspects -> { Selecionado | Codigo da entidade | Loja | Nome | Filial } 
	// Selecionado = .T. ou .F. - define se o cliente/prospect foi selecionado para ser associado ao contato
	// Codigo da entidade = codigo do Cliente ou Prospect
	// Loja = Loja do Cliente ou Prospect
	// Filial = Filial do Cliente ou Prospect
	//----------------------------------------------------------------------------------------
	If ExistBlock("FT330ASS")
		 ExecBlock("FT330ASS",.F.,.F., {aGeral})
	Else	 
		For nCountGeral := 1 to Len(aGeral)
			FT330AuxAss(aGeral[nCountGeral], 'SA1')
			FT330AuxAss(aGeral[nCountGeral], 'SUS')
		Next nCountGeral
	EndIf
EndIf


Return lRet


//--------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FT330AuxAss()
funcao auxiliar para realizar o processamento da associacao independente da entidade (cliente/prospect)
@param aContas array de dados do listbox
@param cEntida entidade (clientes ou prospects)

@author Vendas CRM
@since 04/06/2013
/*/
//--------------------------------------------------------------------------------------------------------------
Function FT330AuxAss(aContas, cEntida)
Local nCountCli := 0
Local nIndiceConta := 0

If cEntida == 'SA1'
	nIndiceConta := 2
ElseIf cEntida == 'SUS'
	nIndiceConta := 3
EndIf


For nCountCli := 1 to Len(aContas[nIndiceConta])
	If aContas[nIndiceConta][nCountCli][1] //verifica se está selecionado o cliente para associar com o contato
		FT330InsAssociacao(cEntida,aContas[nIndiceConta][nCountCli][2],aContas[nIndiceConta][nCountCli][3], aContas[1], aContas[nIndiceConta][nCountCli][5])
	EndIf
Next nCountCli

Return

//--------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FT330InsAssociacao()
Insere o registro na AC8 pra gerar a associacao do contato com uma entidade (cliente/prospect)

@author Vendas CRM
@since 04/06/2013
/*/
//--------------------------------------------------------------------------------------------------------------
Function FT330InsAssociacao(cEntida,cCodEntidade,cLojaEnt, cCodContato, cFilEnt)

RecLock("AC8", .T.)
AC8->AC8_FILIAL 	:= xFilial("AC8")
AC8->AC8_FILENT 	:= cFilEnt
AC8->AC8_ENTIDA	:= cEntida
AC8->AC8_CODENT  	:= cCodEntidade + cLojaEnt 
AC8->AC8_CODCON	:= cCodContato
AC8->(MsUnlock())

Return

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
/*/{Protheus.doc} FATPDColObfuscate
    @description
    Verifica se a coluna de um grid deve ser ofuscado, tendo como base uma lista de
    campos, esta função deve utilizada somente após a inicialização das variaveis 
    atravez da função FATPDLoad.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.

    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FATPDIsObfuscate({"A1_COD","A1_NOME","A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDColObfuscate(aFields, cSource)  
    
	Local aPDColObf	:= {}

    If FATPDActive()
		aPDColObf := FTPDColObfuscate(aFields, cSource)  
    EndIf 

Return aPDColObf  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informações enviadas, 
    quando a regra de auditoria de rotinas com campos sensíveis ou pessoais estiver habilitada
	Remover essa função quando não houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que será utilizada no log das tabelas
    @param nOpc, Numerico, Opção atribuída a função em execução - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria não esteja aplicada, também retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

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
