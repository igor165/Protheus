#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TMKC040.CH"
#INCLUDE "CRMDEF.CH"


#DEFINE TABELA				 			1
#DEFINE ENTIDADE			 			2
#DEFINE TOTAL_CADASTRADO 				3
#DEFINE TOTAL_NAO_QUALIFICADO 			4
#DEFINE TOTAL_QUALIFICADO 				5
#DEFINE TAXA_QUALIFICACAO 				6
#DEFINE CTEMPO_MEDIO_QUALIFICACAO 		7 
#DEFINE NTEMPO_MEDIO_QUALIFICACAO 		8 
#DEFINE QUALIFICADO_X_NAO_QUALIFICADO	9 

#DEFINE ALIAS_ENTITY                    1
#DEFINE FIELD_NAME                      2

//------------------------------------------------------------------------------
/*/{Protheus.doc} TMKC040 


@sample		TMKC040(cCodVend)

@param			ExpC1 Codigo do Vendedor						

@return		Verdadeiro

@author		Aline Kokumai
@since			07/05/2013
@version		P12
/*/
//------------------------------------------------------------------------------
Function TMKC040(cCodVend)

Local oDlg 			:= Nil								// Janela principal
Local oPnlModal		:= Nil
Local oPnlIdConv		:= Nil								// Janela dos indicadores de conversao
Local oDlgGfConv  	:= Nil								// Janela do grafico dos indicadores de conversao
Local oDlgLtCont		:= Nil								// Janela da lista de Registros
Local oDlgTpPem		:= Nil								// Janela do tempo de permanencia
Local aCbxResA 		:= {STR0002,STR0003} 				// Combo do tipo de gráfico: "Pizza","Barras"
Local aCbxResB 		:= {STR0004,STR0005,STR0006,;		// Combo das opções do gráfico: "Total Cadastrado","Total Não Qualificado",
							STR0007,STR0008,STR0009}   		// "Total Qualificado","Taxa de Qualificação","Tempo Médio de Qualificação","Qualificado x Não Qualificado"
Local cCbxResA 	   	:= ""								//
Local cCbxResB 	   	:= ""								//
Local oFWLayer     	:= Nil								// Layer da tela
Local oFWCFactoc 		:= Nil 								// Instancia do grafico
Local oFWChart      	:= Nil								// Grafico
Local oFWLayerLt    	:= Nil								// Layer da lista de registros
Local aEntInfo		:= {}								// Array com o conteudo dos indicadores de conversao
Local aCampos			:= {}								// Array com os campos das entidades
Local oColIndCnv		:= Nil								// Colunas da janela indicadores de conversao
Local oBrwEntid		:= Nil								// Browse dos indicadores de conversao 
Local oBrowseRight	:= Nil								// Browse da lista de registros
Local oBrwCad			:= Nil								// Browse da lista de registros e treeview
Local oTree 			:= Nil								// TreeView tempo de permanencia
Local oPnlChrCbx		:= Nil								// Panel para disposição do combo box do gráfico
Local oPnlChart		:= Nil								// Panel para disposição do gráfico
Local oPnlCol 		:= Nil								// Panel da lista de registros
Local oPnlSup  		:= Nil 								// Panel superior da lista de registros
Local oPnlInf  		:= Nil								// Panel inferior da lista de registros
Local oPnlSair		:= Nil								// Panel do botão sair
Local oBtnSair		:= Nil								// Botão sair
Local lDatasInf		:= .F.

Default cCodVend	:= ""

Private aRotina := {}   

FATPDLoad(Nil,Nil,{"A1_NOME","US_NOME","ACH_RAZAO"}) 

If Pergunte("TMKC040",.T.)
    
    Processa({|| aEntInfo := TkC40PInd(cCodVend) },STR0047,STR0048) // "Aguarde"##"Gerando os indicadores de conversão..."
    	                                                              
	// Insere no array as colunas da lista de registros da conta
	AAdd(aCampos,{"ACH_FILIAL","ACH_CODIGO","ACH_LOJA","ACH_RAZAO","ACH_DTCAD","ACH_HRCAD"})
	AAdd(aCampos,{"US_FILIAL","US_COD","US_LOJA","US_NOME","US_DTCAD","US_HRCAD"})
	AAdd(aCampos,{"A1_FILIAL","A1_COD","A1_LOJA","A1_NOME","A1_DTCAD","A1_HRCAD"})
	
	
	oDlg := FWDialogModal():New()
	oDlg:SetBackground(.F.) // .T. -> escurece o fundo da janela 
	oDlg:SetTitle(STR0001)//titulo
	oDlg:SetEscClose(.T.)//permite fechar a tela com o ESC
	oDlg:EnableAllClient() //cria a tela maximizada (chamar sempre antes do CreateDialog)
	oDlg:EnableFormBar(.F.) 
	oDlg:CreateDialog() //cria a janela (cria os paineis)
	
	//-------------------------------------------------------------------------
	//Pega o painel principal da janela.
	//Esse painel é o painel onde devem ser colocados os componentes que
	//se deseja mostra na janela.
	//-------------------------------------------------------------------------
	oPnlModal := oDlg:GetPanelMain()
	
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oPnlModal,.F.)
	
	/*/
	/// Cria a tabela dos indicadores
	/*/
	oFWLayer:AddLine("LINETOP",25,.T.)
	oFWLayer:AddCollumn("INDICONV",100,.T.,"LINETOP")
	//oFWLayer:AddWindow("INDICONV","oPnlIdConv",STR0010,100,.F.,.T.,,"LINETOP")	// "Indicadores de Conversão"
	oPnlIdConv := oFWLayer:GetColPanel("INDICONV","LINETOP")
	
	
	DEFINE FWBROWSE oBrwEntid DATA ARRAY ARRAY aEntInfo LINE BEGIN 1 CHANGE {|| ;
	/*Atualiza os componentes da tela*/  ;
	Tk40AtInt(oBrwCad,oPnlSup,oBrwEntid,oTree,oFWCFactoc, oFwChart, oPnlChart,;
	cCbxResA, aCbxResA, cCbxResB, aCbxResB, aEntInfo, aCampos)};
	OF oPnlIdConv
		
	//Adiciona colunas da tabela dos indicadores de conversao
	ADD COLUMN oColIndCnv DATA &("{ || aEntInfo[oBrwEntid:At()][2] }") TITLE STR0011 SIZE 10 OF oBrwEntid //Entidade
	ADD COLUMN oColIndCnv DATA &("{ || aEntInfo[oBrwEntid:At()][3] }") TITLE STR0012 SIZE 10 OF oBrwEntid //Total Cadastrado
	ADD COLUMN oColIndCnv DATA &("{ || aEntInfo[oBrwEntid:At()][4] }") TITLE STR0013 SIZE 10 OF oBrwEntid //Total Não Qualificado
	ADD COLUMN oColIndCnv DATA &("{ || aEntInfo[oBrwEntid:At()][5] }") TITLE STR0014 SIZE 10 OF oBrwEntid //Total Qualificado
	ADD COLUMN oColIndCnv DATA &("{ || aEntInfo[oBrwEntid:At()][6]}")  TITLE STR0015 SIZE 10 OF oBrwEntid //Taxa de Qualificação
	ADD COLUMN oColIndCnv DATA &("{ || aEntInfo[oBrwEntid:At()][7]}")  TITLE STR0016 SIZE 10 OF oBrwEntid //Tempo Médio de Qualificação
	
	oBrwEntid:SetDescription(STR0010) //"Indicadores de Conversão"
	
	ACTIVATE FWBROWSE oBrwEntid
	
	/*/
	/// Cria o grafico referente aos indicadores
	/*/
	oFWLayer:AddLine("LINEBOTTOM",75,.T.)
	oFWLayer:AddCollumn("GRAFCONV",40,.T.,"LINEBOTTOM")
	oFWLayer:AddWindow("GRAFCONV","oDlgGfConv",STR0017,100,.F.,.T.,,"LINEBOTTOM")	// "Gráfico Indicadores de Conversão"
	oDlgGfConv := oFWLayer:getWinPanel( "GRAFCONV", "oDlgGfConv" ,"LINEBOTTOM" )
	
	oPnlChrCbx := TPanel():New(000,000,"",oDlgGfConv,,,,,,(oDlgGfConv:nWidth/2),(oDlgGfConv:nHeight/2)*0.10)
	oPnlChrCbx:Align := CONTROL_ALIGN_TOP
	
	//Criação do Combo Box do tipo de gráfico (pizza ou barras)
	@ 04, 05 Say STR0018 Size 050, 008 Pixel Of oPnlChrCbx //"Tipo de Gráfico:"
	@ 02, 50 ComboBox cCbxResA Items aCbxResA Size 055, 010 Pixel Of oPnlChrCbx ;
	On Change ( Tk040Graf(oFWCFactoc, oFwChart, oPnlChart, oBrwEntid, cCbxResA, aCbxResA, cCbxResB, aCbxResB, aEntInfo, aCampos, oPnlSup, oTree))
	
	//Criação do Combo Box
	//Tipo de valor
	@ 04, 115 Say STR0019 Size 060, 008 Pixel Of oPnlChrCbx //"Critério:"
	@ 02, 141 ComboBox cCbxResB Items aCbxResB Size 085, 010 Pixel Of oPnlChrCbx ;
	On Change ( Tk040Graf(oFWCFactoc, oFwChart, oPnlChart, oBrwEntid, cCbxResA, aCbxResA, cCbxResB, aCbxResB, aEntInfo, aCampos, oPnlSup, oTree))
	
	oPnlChart := TPanel():New(000,000,"",oDlgGfConv,,,,,,(oDlgGfConv:nWidth/2),(oDlgGfConv:nHeight/2)*0.90)
	oPnlChart:Align := CONTROL_ALIGN_BOTTOM
	
	// Cria instancia do FWChart
	oFWCFactoc := FWChartFactory():New()
	
		
	/*/
	/// Listagem dos registros (suspect ou prospect ou cliente)
	/*/
	oFWLayer:AddCollumn("LISTCONT",60,.T.,"LINEBOTTOM")
	
	oPnlCol := oFWLayer:GetColPanel( "LISTCONT","LINEBOTTOM" )
	
	oPnlSup := TPanel():New(000,000,"",oPnlCol,,,,,,(oPnlCol:nWidth/2),(oPnlCol:nHeight/2)*0.60)
	oPnlSup:Align := CONTROL_ALIGN_TOP
	
	oPnlInf := TPanel():New(000,000,"",oPnlCol,,,,,,(oPnlCol:nWidth/2),(oPnlCol:nHeight/2)*0.40)
	oPnlInf:Align := CONTROL_ALIGN_BOTTOM
	
	oFWLayerLt := FWLayer():New()
	oFWLayerLt:Init(oPnlInf,.F.)
	
	
	/*/
	/// TreeView tempo de permanencia
	/*/
	oFWLayerLt:AddLine("LINE",100,.T.)
	oFWLayerLt:AddCollumn("TREECTA",100,.T.,"LINE")
	oFWLayerLt:AddWindow("TREECTA","oDlgTpPem",STR0020,100,.F.,.T.,,"LINE")	// "Tempo de Permanência da Conta"
	oDlgTpPem := oFWLayerLt:GetWinPanel( "TREECTA", "oDlgTpPem" ,"LINE" )
	
	// Cria a Tree
	oTree := DBTree():New(001,001,160,260,oDlgTpPem,,,.T.)
	oTree:Align := CONTROL_ALIGN_ALLCLIENT
	
	// Gera gráfico
	Tk040Graf(oFWCFactoc, oFwChart, oPnlChart, oBrwEntid, cCbxResA, aCbxResA, cCbxResB, aCbxResB, aEntInfo, aCampos, oPnlSup, oTree)
	
	//Monta o grid de registros e informações do treeview 
	oBrwCad := Tk040Brw(oPnlSup,oBrwEntid,oTree,aEntInfo,aCampos)
		
	oDlg:Activate() //Ativa a Janela Modal
		
EndIf

FATPDUnload()

Return( .T. ) 

//------------------------------------------------------------------------------
/*/{Protheus.doc} TkC40PInd

Processa os indicadores de conversao para as entidades.

@sample	TkC40PInd(cCodVend)

@param		ExpC1 Codigo do Vendedor	

@return	Nenhum

@author	Anderson Silva
@since		31/01/2014
@version	P12                
/*/
//------------------------------------------------------------------------------
Static Function TkC40PInd(cCodVend)
Local aRet := {}

ProcRegua(0)
AAdd(aRet,TkC40AGACH(cCodVend))
AAdd(aRet,TkC40AGSUS(cCodVend))
AAdd(aRet,TkC40AGSA1(cCodVend))

Return(aRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk040Graf

Função que gera os componentes do gráfico.

@sample				Tk040Graf(oFWCFactoc, oFwChart, oPnlChart, oBrwEntid, cTpChart, aCbxResA,;
							 cCritSel, aCbxResB, aEntInfo, aCampos, oPnlSup, oTree)

@param				Exp         oFWCFactoc	- Instancia do grafico
								oFwChart	- Objeto grafico
								oPnlChart	- Panel para disposição do gráfico
								oBrwEntid	- Browse dos indicadores de conversao 
								cTpChart	- Tipo do gráfico selecionado
								aCbxResA	- Combo box tipo de gráfico
								cCritSel	- Opção do gráfico selecionado
								aCbxResB	- Combo box das opções de gráfico
								aEntInfo	- Array com o conteudo dos indicadores de conversao
								aCampos		- Array com os campos das entidades
								oPnlSup		- Panel superior da lista de registros
								oTree		- TreeView tempo de permanencia								

@return			Verdadeiro

@author			Aline Kokumai
@since				20/05/2013
@version			P12
/*/
//------------------------------------------------------------------------------
Static Function Tk040Graf(oFWCFactoc, oFwChart, oPnlChart, oBrwEntid, cTpChart, aCbxResA, cCritSel, aCbxResB, aEntInfo, aCampos, oPnlSup, oTree)

Local aArea		:= GetArea()
Local nX 			:= 0
Local cDescri		:= "" 
Local cNomEntid	:= ""
Local cAlias		:= ""
Local nTpChart  	:= AScan(aCbxResA,{|x| x == cTpChart }) //Recebe a posição do tipo de gráfico selecionado
Local nCritSel  	:= AScan(aCbxResB,{|x| x == cCritSel }) //Recebe a posição da opção do gráfico selecionado
Local nSerie		:= 0  
Local cEntidade	:= ""

	If oFwChart <> NIL
		FreeObj(oFwChart)
	Endif       

	If nTpChart == 1
		oFwChart := oFWCFactoc:getInstance( PIECHART )
	Else
		oFwChart := oFWCFactoc:getInstance( BARCHART )
	EndIf  

	If nCritSel == 1
		cDescri := STR0004 //"Total Cadastrado"
		nSerie := TOTAL_CADASTRADO 
	ElseIf nCritSel == 2      
		cDescri := STR0005 //"Total Não Qualificado"
		nSerie := TOTAL_NAO_QUALIFICADO
	ElseIf nCritSel == 3
		cDescri := STR0006 //"Total Qualificado"
		nSerie := TOTAL_QUALIFICADO 
	ElseIf nCritSel == 4             
		cDescri := STR0007 //"Taxa de Qualificação" 
		nSerie := TAXA_QUALIFICACAO  
	ElseIf nCritSel == 5             
		cDescri := STR0008 //"Tempo Médio de Qualificação"
		nSerie := NTEMPO_MEDIO_QUALIFICACAO
	Else
		cNomEntid := aEntInfo[oBrwEntid:At()][ENTIDADE]      
		cDescri := cNomEntid+" - " + STR0009 //"Qualificado x Não Qualificado" 
		nSerie := QUALIFICADO_X_NAO_QUALIFICADO 
	EndIf
	
	oFWChart:Init( oPnlChart )
	oFWChart:SetTitle(cDescri, CONTROL_ALIGN_CENTER )
	oFWChart:SetLegend( CONTROL_ALIGN_BOTTOM )
	oFWChart:SetMask( " *@* " )
	oFWChart:SetPicture( "" )
	
	If nCritSel <> 6
		For nX := 1 to Len(aEntInfo)
			cNomEntid := 	aEntInfo[nX][ENTIDADE]
			oFWChart:AddSerie(cNomEntid,aEntInfo[nX][nSerie] ) //Adiona as series do gráfico
		Next nX 
	Else
		oFWChart:AddSerie(STR0005,aEntInfo[oBrwEntid:At()][TOTAL_NAO_QUALIFICADO] ) //"Total Não Qualificado"
		oFWChart:AddSerie(STR0006,aEntInfo[oBrwEntid:At()][TOTAL_QUALIFICADO] )	 //"Total Qualificado"	
	EndIf	
	
	oFWChart:Build()	
	
	If nSerie  <> 9 // Qualificado X Não Qualificado	
		//Atualiza os componentes da tela de acordo com a serie do gráfico selecionado	
		oFWChart:SetSerieAction({|nSerie| Tk040Brw(oPnlSup,oBrwEntid,oTree,aEntInfo,aCampos,; 
											IIF(nSerie == 1,"ACH",IIF(nSerie == 2,"SUS","SA1")),;
											IIF(nSerie == 1,STR0022,IIF(nSerie == 2,STR0023,STR0024)))}) //suspects###prospects###clientes
	EndIf 		 
	RestArea(aArea)

Return( .T. )


//------------------------------------------------------------------------------
/*/{Protheus.doc} TkC40AGACH

Analise Gerencial da Conta: Retorna dados para popular a tabela de indicadores de
conversão dos Suspects.

@sample			TkC40AGACH(cCodVend)

@param			ExpC1   Codigo do Vendedor

@return			ExpA 	Array contendo as seguintes informacoes
							aAGACH[1] - Tabela
							aAGACH[2] - Entidade
							aAGACH[3] - Total de Suspects Cadastrados
							aAGACH[4] - Total de Suspects Nao Qualificados
							aAGACH[5] - Total de Suspects Qualificados
							aAGACH[6] - Taxa de Qualificacao
							aAGACH[7] - Tempo Medio de Qualificacao: em texto
							aAGACH[8] - Tempo Medio de Qualificacao: numérico em horas

@author			Aline Kokumai
@since				13/05/2013
@version			P12
/*/
//------------------------------------------------------------------------------
Static Function TkC40AGACH(cCodVend)

Local aAGACH			:= {}		//Array de retorno contendo os indicadores
Local nTotCadas		:= 0		//Total Suspect Cadastrado
Local nTotNQlf		:= 0		//Total Suspect Nao Qualificado
Local nTotQlf			:= 0		//Total Suspect Qualificado
Local nPorcQlf		:= 0		//Taxa de Qualificacao de Suspect
Local aColunas		:= {}		//Array auxiliar para guardar data e hora de cadastro e conversão
Local aDtCadConv		:= {}    	//Matriz auxiliar contendo data e hora de cadastro e conversão para calculo da média de qualificação
Local aMedia			:= {}		//Tempo Medio de Qualificacao
Local cAlias 			:= GetNextAlias() 
Local cFiltro			:= ""
Local cOperBco 		:= IIf(Trim(Upper(TcGetDb())) $ "ORACLE,POSTGRES,DB2,INFORMIX","||","+")

Default cCodVend 		:= ""

// Filtro do SIGACRM
cFiltro := CRMXFilEnt("ACH", .T.)	
	
//Total Suspect Cadastrado
cQuery := "SELECT COUNT(*) TOTAL_SUSPECT_CAD "
cQuery += "FROM "+RetSqlName("ACH")+" ACH "
If !Empty(cFiltro)
	cQuery += "INNER JOIN " + RetSqlName( "AO4" ) + " AO4 ON (ACH.ACH_FILIAL " + cOperBco + " ACH.ACH_CODIGO " + cOperBco + " ACH.ACH_LOJA) = AO4.AO4_CHVREG "	
EndIf
cQuery += "WHERE ACH.ACH_FILIAL = '"+xFilial("ACH")+"' AND "
cQuery += "ACH.ACH_DTCAD BETWEEN '"+Dtos(MV_PAR01)+"' AND "
cQuery += "'"+Dtos(MV_PAR02)+"' AND " 

If Empty(cCodVend)
	If !Empty(cFiltro)
		cQuery += cFiltro+" AND "
	EndIf
	If MV_PAR07 == 1
		cQuery += "ACH.ACH_VEND BETWEEN '"+MV_PAR08+"' AND "
		cQuery += "'"+MV_PAR09+"' AND "
	EndIf
Else 
	cQuery += "ACH.ACH_VEND = '"+cCodVend+"' AND "	
EndIf
	
cQuery += "ACH.D_E_L_E_T_ <> '*' "
	
TkC40ExQry(cQuery,@cAlias)
	
nTotCadas := (cAlias)->TOTAL_SUSPECT_CAD
	
//Total Suspect Nao Qualificado
cQuery := "SELECT COUNT(*) TOTAL_SUSPECT_NAO_QUALIF "
cQuery += "FROM "+RetSqlName("ACH")+" ACH "
If !Empty(cFiltro)
	cQuery += "INNER JOIN " + RetSqlName( "AO4" ) + " AO4 ON (ACH.ACH_FILIAL " + cOperBco + " ACH.ACH_CODIGO " + cOperBco + " ACH.ACH_LOJA) = AO4.AO4_CHVREG "	
EndIf
cQuery += "WHERE ACH.ACH_FILIAL = '"+xFilial("ACH")+"' AND "
cQuery += "ACH.ACH_STATUS <> '6' AND "      
cQuery += "ACH.ACH_DTCAD BETWEEN '"+Dtos(MV_PAR01)+"' AND "
cQuery += "'"+Dtos(MV_PAR02)+"' AND " 
	
If Empty(cCodVend)
	If !Empty(cFiltro)
		cQuery += cFiltro+" AND "
	EndIf
	If MV_PAR07 == 1
		cQuery += "ACH.ACH_VEND BETWEEN '"+MV_PAR08+"' AND "
		cQuery += "'"+MV_PAR09+"' AND "
	EndIf
Else 
	cQuery += "ACH.ACH_VEND = '"+cCodVend+"' AND "	
EndIf
	
cQuery += "ACH.D_E_L_E_T_ <> '*' "
	
TkC40ExQry(cQuery,@cAlias)
	
nTotNQlf := (cAlias)->TOTAL_SUSPECT_NAO_QUALIF
	
//Total Suspect Qualificado
cQuery := "SELECT COUNT(*) TOTAL_SUSPECT_QUALIF "
cQuery += "FROM "+RetSqlName("ACH")+" ACH "
If !Empty(cFiltro)
	cQuery += "INNER JOIN " + RetSqlName( "AO4" ) + " AO4 ON (ACH.ACH_FILIAL " + cOperBco + " ACH.ACH_CODIGO " + cOperBco + " ACH.ACH_LOJA) = AO4.AO4_CHVREG "	
EndIf
cQuery += "WHERE ACH.ACH_FILIAL = '"+xFilial("ACH")+"' AND "
cQuery += "ACH.ACH_STATUS = '6' AND "   
cQuery += "ACH.ACH_DTCAD BETWEEN '"+Dtos(MV_PAR01)+"' AND "
cQuery += "'"+Dtos(MV_PAR02)+"' AND " 
	
If Empty(cCodVend)  
	If !Empty(cFiltro)
		cQuery += cFiltro+" AND "
 	EndIf
	If MV_PAR07 == 1
		cQuery += "ACH.ACH_VEND BETWEEN '"+MV_PAR08+"' AND "
		cQuery += "'"+MV_PAR09+"' AND "
	EndIf
Else 
	cQuery += "ACH.ACH_VEND = '"+cCodVend+"' AND "	
EndIf
	
cQuery += "ACH.D_E_L_E_T_<> '*' "
	
TkC40ExQry(cQuery,@cAlias)
	
nTotQlf := (cAlias)->TOTAL_SUSPECT_QUALIF
	
//Taxa de Qualificacao
nPorcQlf = Round((nTotQlf/nTotCadas)*100,2)
	
//Tempo Médio de Qualificação
cQuery := "SELECT ACH.ACH_DTCAD, ACH.ACH_HRCAD, ACH.ACH_DTCONV, ACH.ACH_HRCONV "
cQuery += "FROM "+RetSqlName("ACH")+" ACH "
If !Empty(cFiltro)
	cQuery += "INNER JOIN " + RetSqlName( "AO4" ) + " AO4 ON (ACH.ACH_FILIAL " + cOperBco + " ACH.ACH_CODIGO " + cOperBco + " ACH.ACH_LOJA) = AO4.AO4_CHVREG "	
EndIf
cQuery += "WHERE ACH.ACH_FILIAL='"+xFilial("ACH")+"' AND "
cQuery += "ACH.ACH_STATUS = '6' AND " 
cQuery += "ACH.ACH_DTCAD <> ' ' AND "
cQuery += "ACH.ACH_DTCAD BETWEEN '"+Dtos(MV_PAR01)+"' AND "
cQuery += "'"+Dtos(MV_PAR02)+"' AND " 
cQuery += "ACH.ACH_DTCONV <> ' ' AND "

If Empty(cCodVend)
	If !Empty(cFiltro)
		cQuery += cFiltro+" AND "
	EndIf
	If MV_PAR07 == 1
		cQuery += "ACH.ACH_VEND BETWEEN '"+MV_PAR08+"' AND "
		cQuery += "'"+MV_PAR09+"' AND "
	EndIf
Else 
	cQuery += "ACH.ACH_VEND = '"+cCodVend+"' AND "	
EndIf

cQuery += "ACH.D_E_L_E_T_ <> '*' "
	
TkC40ExQry(cQuery,@cAlias,ACH->(DbStruct()))
	
While (cAlias)->(!Eof())
	AAdd(aColunas,(cAlias)->ACH_DTCAD)
	AAdd(aColunas,IIF(Empty((cAlias)->ACH_HRCAD) .OR. (cAlias)->ACH_HRCAD==Nil,"23:59",(cAlias)->ACH_HRCAD))
	AAdd(aColunas,(cAlias)->ACH_DTCONV)
	AAdd(aColunas,IIF(Empty((cAlias)->ACH_HRCONV) .OR. (cAlias)->ACH_HRCONV==Nil,"23:59",(cAlias)->ACH_HRCONV))
	AAdd(aDtCadConv,aColunas)
	aColunas := {}
	(cAlias)->(DbSkip())
EndDo
	
//Calcula Tempo Medio de Qualificacao
aMedia := TkC40Media(aDtCadConv)
	
aAGACH := { "ACH", STR0022, nTotCadas, nTotNQlf, nTotQlf, nPorcQlf, aMedia[1],aMedia[2]  } //"ACH - Suspects"
	
//Encerra area temporaria
IIF(Select(cAlias)>0,(cAlias)->(DbCloseArea()),Nil)

Return( aAGACH )

//------------------------------------------------------------------------------
/*/{Protheus.doc} TkC40AGSUS

Analise Gerencial da Conta: Retorna dados para popular a tabela de indicadores de
conversão dos Prospects.

@sample			TkC40AGSUS(cCodVend)

@param			ExpC1 Codigo do Vendedor

@return			ExpA Array contendo as seguintes informações
							aAGSUS[1] - Tabela
							aAGSUS[2] - Entidade
							aAGSUS[3] - Total de Prospects Cadastrados
							aAGSUS[4] - Total de Prospects Nao Qualificados
							aAGSUS[5] - Total de Prospects Qualificados
							aAGSUS[6] - Taxa de Qualificacao
							aAGACH[7] - Tempo Medio de Qualificacao: em texto
							aAGACH[8] - Tempo Medio de Qualificacao: numérico em horas

@author			Aline Kokumai
@since				13/05/2013
@version			P12
/*/
//------------------------------------------------------------------------------
Static Function TkC40AGSUS(cCodVend)
	
Local aAGSUS		:= {}		//Array de retorno contendo os indicadores
Local nTotCadas	:= 0		//Total Prospect Cadastrado
Local nTotNQlf	:= 0		//Total Prospect Nao Qualificado
Local nTotQlf		:= 0		//Total Prospect Qualificado
Local nPorcQlf	:= 0		//Taxa de Qualificacao de Prospect
Local aColunas	:= {}		//Array auxiliar para guardar data e hora de cadastro e conversão
Local aDtCadConv	:= {}		//Matriz auxiliar contendo data e hora de cadastro e conversão para calculo da média de qualificação
Local aMedia		:= {}		//Tempo Medio de Qualificacao
Local cAlias		:= GetNextAlias()
Local cFiltro    	:= ""  
Local cOperBco 	:= IIf(Trim(Upper(TcGetDb())) $ "ORACLE,POSTGRES,DB2,INFORMIX","||","+")

Default cCodVend 	:= "" 


// Filtro do SIGACRM
cFiltro := CRMXFilEnt("SUS",.T.)	
	
	//Total Prospect Cadastrado
cQuery := "SELECT COUNT(*) TOTAL_PROSPECT_CAD "
cQuery += "FROM "+RetSqlName("SUS")+" SUS "
If !Empty(cFiltro)
	cQuery += "INNER JOIN " + RetSqlName( "AO4" ) + " AO4 ON (SUS.US_FILIAL " + cOperBco + " SUS.US_COD " + cOperBco + " SUS.US_LOJA) = AO4.AO4_CHVREG "	
EndIf
cQuery += "WHERE SUS.US_FILIAL = '"+xFilial("SUS")+"' AND "
cQuery += "SUS.US_DTCAD BETWEEN '"+Dtos(MV_PAR03)+"' AND "
cQuery += "'"+Dtos(MV_PAR04)+"' AND " 
		
If Empty(cCodVend)
	If !Empty(cFiltro)
		cQuery += cFiltro+" AND "
	EndIf
	If MV_PAR07 == 1
		cQuery += "SUS.US_VEND BETWEEN '"+MV_PAR08+"' AND "
		cQuery += "'"+MV_PAR09+"' AND "
	EndIf
Else 
	cQuery += "SUS.US_VEND = '"+cCodVend+"' AND "	
EndIf

cQuery += "SUS.D_E_L_E_T_ <> '*' "
	
TkC40ExQry(cQuery,@cAlias)
	
nTotCadas := (cAlias)->TOTAL_PROSPECT_CAD
	
//Total Prospect Nao Qualificado
cQuery := "SELECT COUNT(*) TOTAL_PROSPECT_NAO_QUALIF "
cQuery += "FROM "+RetSqlName("SUS")+" SUS "
If !Empty(cFiltro)
	cQuery += "INNER JOIN " + RetSqlName( "AO4" ) + " AO4 ON (SUS.US_FILIAL " + cOperBco + " SUS.US_COD " + cOperBco + " SUS.US_LOJA) = AO4.AO4_CHVREG "	
EndIf
cQuery += "WHERE SUS.US_FILIAL = '"+xFilial("SUS")+"' AND "
cQuery += "SUS.US_STATUS <> '6' AND "
cQuery += "SUS.US_DTCAD BETWEEN '"+Dtos(MV_PAR03)+"' AND "
cQuery += "'"+Dtos(MV_PAR04)+"' AND " 
	
If Empty(cCodVend)
	If !Empty(cFiltro)
		cQuery += cFiltro+" AND "
	EndIf
	If MV_PAR07 == 1
		cQuery += "SUS.US_VEND BETWEEN '"+MV_PAR08+"' AND "
		cQuery += "'"+MV_PAR09+"' AND "
	EndIf
Else 
	cQuery += "SUS.US_VEND = '"+cCodVend+"' AND "	
EndIf

cQuery += "SUS.D_E_L_E_T_ <> '*' "                           
	
TkC40ExQry(cQuery,@cAlias)
	
nTotNQlf := (cAlias)->TOTAL_PROSPECT_NAO_QUALIF
	
//Total Prospect Qualificado
cQuery := "SELECT COUNT(*) TOTAL_PROSPECT_QUALIF "
cQuery += "FROM "+RetSqlName("SUS")+" SUS "
If !Empty(cFiltro)
	cQuery += "INNER JOIN " + RetSqlName( "AO4" ) + " AO4 ON (SUS.US_FILIAL " + cOperBco + " SUS.US_COD " + cOperBco + " SUS.US_LOJA) = AO4.AO4_CHVREG "	
EndIf
cQuery += "WHERE SUS.US_FILIAL='"+xFilial("SUS")+"' AND "
cQuery += "SUS.US_STATUS = '6' AND "  
cQuery += "SUS.US_DTCAD BETWEEN '"+Dtos(MV_PAR03)+"' AND "
cQuery += "'"+Dtos(MV_PAR04)+"' AND " 
	
If Empty(cCodVend)
	If !Empty(cFiltro)
		cQuery += cFiltro+" AND "
	EndIf
	If MV_PAR07 == 1
		cQuery += "SUS.US_VEND BETWEEN '"+MV_PAR08+"' AND "
		cQuery += "'"+MV_PAR09+"' AND "
	EndIf
Else 
	cQuery += "SUS.US_VEND = '"+cCodVend+"' AND "	
EndIf
		
cQuery += "SUS.D_E_L_E_T_ <> '*' "
	
TkC40ExQry(cQuery,@cAlias)
	
nTotQlf := (cAlias)->TOTAL_PROSPECT_QUALIF
	
	//Taxa de Qualificacao
nPorcQlf = Round((nTotQlf/nTotCadas)*100,2)
	
//Tempo Médio de Qualificação
cQuery := "SELECT SUS.US_DTCAD, SUS.US_HRCAD, SUS.US_DTCONV, SUS.US_HRCONV "
cQuery += "FROM "+RetSqlName("SUS")+" SUS "
If !Empty(cFiltro)
	cQuery += "INNER JOIN " + RetSqlName( "AO4" ) + " AO4 ON (SUS.US_FILIAL " + cOperBco + " SUS.US_COD " + cOperBco + " SUS.US_LOJA) = AO4.AO4_CHVREG "	
EndIf
cQuery += "WHERE SUS.US_FILIAL = '"+xFilial("SUS")+"' AND "
cQuery += "SUS.US_STATUS = '6' AND "   
cQuery += "SUS.US_DTCAD <> ' ' AND " 
cQuery += "SUS.US_DTCAD BETWEEN '"+Dtos(MV_PAR03)+"' AND "
cQuery += "'"+Dtos(MV_PAR04)+"' AND " 
cQuery += "SUS.US_DTCONV <> ' ' AND "
	
If Empty(cCodVend)
	If !Empty(cFiltro)
		cQuery += cFiltro+" AND "
	EndIf
	If MV_PAR07 == 1
		cQuery += "SUS.US_VEND BETWEEN '"+MV_PAR08+"' AND "
		cQuery += "'"+MV_PAR09+"' AND "
	EndIf
Else 
	cQuery += "SUS.US_VEND = '"+cCodVend+"' AND "	
EndIf
		
cQuery += "SUS.D_E_L_E_T_<> '*' "

TkC40ExQry(cQuery,@cAlias,SUS->(DbStruct()))
	
While (cAlias)->(!Eof())
	AAdd(aColunas,(cAlias)->US_DTCAD)
	AAdd(aColunas,IIF(Empty((cAlias)->US_HRCAD) .OR. (cAlias)->US_HRCAD==Nil,"23:59",(cAlias)->US_HRCAD))
	AAdd(aColunas,(cAlias)->US_DTCONV)
	AAdd(aColunas,IIF(Empty((cAlias)->US_HRCONV) .OR. (cAlias)->US_HRCONV==Nil,"23:59",(cAlias)->US_HRCONV))
	AAdd(aDtCadConv,aColunas)
	aColunas := {}
	DbSkip()
EndDo
	
//Calcula Tempo Medio de Qualificacao
aMedia := TkC40Media(aDtCadConv)
	
aAGSUS := { "SUS", STR0023, nTotCadas, nTotNQlf, nTotQlf, nPorcQlf, aMedia[1], aMedia[2]  } //"SUS - Prospects"
	
//Encerra area temporaria
IIF(Select(cAlias)>0,(cAlias)->(DbCloseArea()),Nil)

Return( aAGSUS )

//------------------------------------------------------------------------------
/*/{Protheus.doc} TkC40AGSA1

Analise Gerencial da Conta: Retorna dados para popular a tabela de indicadores de
conversão dos Clientes.

@sample			TkC40AGSA1(cCodVend)

@param			ExpC1 Codigo do Vendedor

@return			ExpA Array contendo as seguintes informacoes
							aAGSA1[1] - Tabela
							aAGSA1[2] - Entidade
							aAGSA1[3] - Total de Clientes Cadastrados
							aAGSA1[4] - Total de Clientes Nao Qualificados
							aAGSA1[5] - Total de Clientes Qualificados
							aAGSA1[6] - Taxa de Qualificacao
							aAGACH[7] - Tempo Medio de Qualificacao: em texto
							aAGACH[8] - Tempo Medio de Qualificacao: numérico em horas

@author			Aline Kokumai
@since				13/05/2013
@version			P12
/*/
//------------------------------------------------------------------------------
Static Function TkC40AGSA1(cCodVend)

Local aAGSA1		:= {}
Local nTotCadas	:= 0
Local nTotNQlf	:= 0
Local nTotQlf		:= 0
Local nPorcQlf	:= 0
Local cAlias		:= GetNextAlias()
Local cFiltro    	:= "" 
Local cOperBco 	:= IIf(Trim(Upper(TcGetDb())) $ "ORACLE,POSTGRES,DB2,INFORMIX","||","+")

Default cCodVend 	:= ""

    
// Filtro do SIGACRM
cFiltro := CRMXFilEnt("SA1",.T.)	
	
//Total Cliente Cadastrado
cQuery := "SELECT COUNT(*) TOTAL_CLIENTE_CAD "
cQuery += "FROM "+RetSqlName("SA1")+" SA1 "
If !Empty(cFiltro)
	cQuery += "INNER JOIN " + RetSqlName( "AO4" ) + " AO4 ON (SA1.A1_FILIAL " + cOperBco + " SA1.A1_COD " + cOperBco + " SA1.A1_LOJA) = AO4.AO4_CHVREG "	
EndIf
cQuery += "WHERE SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND "  
cQuery += "SA1.A1_DTCAD BETWEEN '"+Dtos(MV_PAR05)+"' AND "
cQuery += "'"+Dtos(MV_PAR06)+"' AND " 
		
If Empty(cCodVend) 
	If !Empty(cFiltro)
		cQuery += cFiltro+" AND "
	EndIf
	If MV_PAR07 == 1
		cQuery += "SA1.A1_VEND BETWEEN '"+MV_PAR08+"' AND "
		cQuery += "'"+MV_PAR09+"' AND "
	EndIf
Else 
	cQuery += "SA1.A1_VEND = '"+cCodVend+"' AND "	
EndIf
	
cQuery += "SA1.D_E_L_E_T_ <> '*' "

TkC40ExQry(cQuery,@cAlias)
	
nTotCadas := (cAlias)->TOTAL_CLIENTE_CAD
nTotQlf	  := nTotCadas
aAGSA1 := { "SA1", STR0024, nTotCadas, nTotNQlf, nTotQlf, nPorcQlf, "",0  } //"SA1 - Clientes"
	
//Encerra area temporaria
IIF(Select(cAlias)>0,(cAlias)->(DbCloseArea()),Nil)

Return( aAGSA1 )

//------------------------------------------------------------------------------
/*/{Protheus.doc} TkC40ExQry

Executa a query passada como parametro.

@sample			TkC40ExQry(cQuery,cAlias,aStruct)

@param			ExpC Query ANSI
ExpC Alias @Referencia

@return		ExpL Verdadeiro.

@author		Aline Kokumai
@since			13/05/2013
@version		P12
/*/                                                              
//------------------------------------------------------------------------------
Static Function TkC40ExQry(cQuery,cAlias,aStruct)

Local nX := 0

Default aStruct := {}

IIF(Select(cAlias)>0,(cAlias)->(DbCloseArea()),Nil)

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

For nX := 1 To Len(aStruct)
	If ( aStruct[nX][2]<>"C" ) //AStruct devolve as colunas do mesmo tipo que é no banco
		TcSetField(cAlias,aStruct[nX][1],aStruct[nX][2],aStruct[nX][3],aStruct[nX][4])
	EndIf
Next nX

Return( .T. )
                                                  

//------------------------------------------------------------------------------
/*/{Protheus.doc} TkC40Media

Calculo tempo médio de duração para qualificação da entidade

@sample		TkC40AGACH(aPeriodo)

@param		aPeriodo - Array com os dados da data e hora de cadastro e data e hora da conversão
						aPeriodo[1] - Data de Cadastro
						aPeriodo[2] - Hora de Cadastro
						aPeriodo[3] - Data da Conversão
						aPeriodo[4] - Hora da Conversão

@return	Array com o período de duração média
						aRetorno[1] - Texto da Duração Média
						aRetorno[2] - Duração Média em Horas (numérico)

@author             Aline Kokumai
@since              13/05/2013
@version            P12
/*/
//------------------------------------------------------------------------------
Function TkC40Media(aDtCadConv)

Local nTempo	 := 0		//duracao total em horas
Local nDias	 := 0		//duracao total em dias
Local nAnos	 := 0		//duracao total em anos
Local cHoras	 := ""		//duracao restante em horas
Local cDurMed	 := "" 		//media do período de duração
Local nCont	 := 0		//contador auxiliar
Local nMedia 	 := 0 		//Media de duracao numerica 
Local aRetorno := {} 		//Retorno da duracao 

For nCont := 1 to Len(aDtCadConv)
	nTempo += SubtHoras(aDtCadConv[nCont,1],aDtCadConv[nCont,2],aDtCadConv[nCont,3],aDtCadConv[nCont,4])
Next

nTempo := (Abs(nTempo))/Len(aDtCadConv) //Calcula a media em horas
nMedia := nTempo

While nTempo >= 24  //Tranforma horas em dias
	nTempo := nTempo - 24
	nDias += 1
EndDo

cHoras := IntToHora( Abs(nTempo) ) //Recebe as horas que sobraram da duracao

If nDias >= 365 //Verifica se o numero de dias é maior ou igual a 1 ano	
	While nDias >= 365 //Calcula o numero de anos
		nDias :=  nDias - 365
		nAnos += 1
	EndDo
EndIf
	
	// Monta o texto da duração com anos, dias, horas e minutos
If nAnos <> 0
	cDurMed := cValToChar(nAnos) + " " + STR0025 + " " //"Anos"
EndIf
If nDias <> 0
	cDurMed += cValToChar(nDias) + " " + STR0026 + " " //"Dias"
EndIf
If substr(cHoras,1,2) <> "00"
	cDurMed += substr(cHoras,1,2) + " " + STR0027 + " " // "Horas"
EndIf
If substr(cHoras,4,2) <> "00"
	cDurMed += substr(cHoras,4,2) + " " + STR0028 + " " // "Minutos"
EndIf
	
aRetorno := { cDurMed,nMedia }

Return (aRetorno)


//------------------------------------------------------------------------------
/*/{Protheus.doc} TkC40GetCt

Analise Gerencial da Conta: Retorna dados para popular o tree view da evolução da conta.

@sample			TkC40GetCt(cEntidade,cChave)

@param			cEntidade 	Nome da entidade/tabela (SA1, SUS, ACH)
				cChave		Chave do registro (Filial+Codigo+Loja)

@return    	Matriz com as seguintes informações:
				aRetorno[1][1]-> ACH (Suspect)
				aRetorno[2][1]-> SUS (Prospect)
				aRetorno[3][1]-> SA1 (Cliente)
				aRetorno[x][2]-> .T. se existir a entidade ou .F. se não existir a entidade
				aRetorno[x][3]-> DATA DE CADASTRO
				aRetorno[x][4]-> DATA DE CADASTRO
				aRetorno[x][5]-> HORA DE CADASTRO
				aRetorno[x][6]-> DATA DE CONVERSÃO
				aRetorno[x][7]-> HORA DE CONVERSÃO
				aRetorno[x][8]-> TEMPO DE PERMANENCIA
				
@author 			Aline Kokumai
@since				15/05/2013
@version			P12
/*/
//------------------------------------------------------------------------------
Function TkC40GetCt(cEntidade,cChave)
 
Local aArea		:= GetArea()
Local aAreaSA1	:= SA1->(GetArea())
Local aAreaSUS	:= SUS->(GetArea())
Local aAreaACH	:= ACH->(GetArea())
 
//Matriz de retorno
Local aRetorno   := { {STR0031,.T.," "," "," "," "," "," " },; //Suspect
						{STR0032,.T.," "," "," "," "," "," " },; //Prospect
						{STR0033,.T.," "," "," "," "," "," " } } //Cliente

Default cEntidade	:= ""
Default cChave  	:= ""

Do Case

	Case cEntidade == "ACH"
		DbSelectArea("ACH")
		DbSetOrder(1)
		If (DbSeek(cChave)) //Verifica se existe o suspect
			//Preenche arra de retorno com dados do Suspect
			aRetorno[1,3] := ACH->ACH_RAZAO
			aRetorno[1,4] := ACH->ACH_DTCAD
			aRetorno[1,5] := ACH->ACH_HRCAD
			aRetorno[1,6] := ACH->ACH_DTCONV
			aRetorno[1,7] := ACH->ACH_HRCONV
			aRetorno[1,8] := TKCalcPer(ACH->ACH_DTCAD,ACH->ACH_HRCAD,ACH->ACH_DTCONV,ACH->ACH_HRCONV)
				
			DbSelectArea("SUS")
			If	(DbSeek(xFilial("SUS")+ACH->ACH_CODPRO+ACH->ACH_LOJPRO)) //Verifica se existe o prospect
				//Preenche arra de retorno com dados do Prospec
				aRetorno[2,3] := SUS->US_NOME
				aRetorno[2,4] := SUS->US_DTCAD
				aRetorno[2,5] := SUS->US_HRCAD
				aRetorno[2,6] := SUS->US_DTCONV
				aRetorno[2,7] := SUS->US_HRCONV
				aRetorno[2,8] := TKCalcPer(SUS->US_DTCAD,SUS->US_HRCAD,SUS->US_DTCONV,SUS->US_HRCONV)
				
				DbSelectArea("SA1")
					
				If (DbSeek(xFilial("SA1")+SUS->US_CODCLI+SUS->US_LOJACLI)) //Verifica se existe o cliente
					//Preenche arra de retorno com dados do Cliente
					aRetorno[3,3] := SA1->A1_NOME
					aRetorno[3,4] := SA1->A1_DTCAD
					aRetorno[3,5] := SA1->A1_HRCAD
					aRetorno[3,6] := DDATABASE
					aRetorno[3,7] := Time()
					aRetorno[3,8] := TKCalcPer(SA1->A1_DTCAD,SA1->A1_HRCAD,DDATABASE,Time())
				Else
					aRetorno[3,2] := .F.
				EndIf
			Else
				aRetorno[2,2] := .F.
				aRetorno[3,2] := .F.
			EndIf
		Else
			aRetorno[1,2] := .F.
			aRetorno[2,2] := .F.
			aRetorno[3,2] := .F.
		EndIf
			
	Case cEntidade == "SUS"
			
		DbSelectArea("SUS")
		DbSetOrder(1)
		If (DbSeek(cChave)) //Verifica se existe o prospect
			//Preenche arra de retorno com dados do Prospect
			aRetorno[2,3] := SUS->US_NOME
			aRetorno[2,4] := SUS->US_DTCAD
			aRetorno[2,5] := SUS->US_HRCAD
			aRetorno[2,6] := SUS->US_DTCONV
			aRetorno[2,7] := SUS->US_HRCONV
			aRetorno[2,8] := TKCalcPer(SUS->US_DTCAD,SUS->US_HRCAD,SUS->US_DTCONV,SUS->US_HRCONV)
			
			DbSelectArea("ACH")
			DbSetOrder(4)
			If	(DbSeek(xFilial("ACH")+SUS->US_COD+SUS->US_LOJA)) //Verifica se existe o suspect
				//Preenche arra de retorno com dados do Suspect	
				aRetorno[1,3] := ACH->ACH_RAZAO
				aRetorno[1,4] := ACH->ACH_DTCAD
				aRetorno[1,5] := ACH->ACH_HRCAD
				aRetorno[1,6] := ACH->ACH_DTCONV
				aRetorno[1,7] := ACH->ACH_HRCONV
				aRetorno[1,8] := TKCalcPer(ACH->ACH_DTCAD,ACH->ACH_HRCAD,ACH->ACH_DTCONV,ACH->ACH_HRCONV)
			Else
				aRetorno[1,2] := .F.
			EndIf
				
			DbSelectArea("SA1")
			DbSetOrder(1)
			If (DbSeek(xFilial("SA1")+SUS->US_CODCLI+SUS->US_LOJACLI)) //Verifica se existe o cliente
				//Preenche arra de retorno com dados do Cliente
				aRetorno[3,3] := SA1->A1_NOME
				aRetorno[3,4] := SA1->A1_DTCAD
				aRetorno[3,5] := SA1->A1_HRCAD
				aRetorno[3,6] := DDATABASE
				aRetorno[3,7] := Time()
				aRetorno[3,8] := TKCalcPer(SA1->A1_DTCAD,SA1->A1_HRCAD,DDATABASE,Time())
			Else
				aRetorno[3,2] := .F.
			EndIf
		Else
			aRetorno[1,2] := .F.
			aRetorno[2,2] := .F.
			aRetorno[3,2] := .F.
		EndIf
			
	Case cEntidade == "SA1"
			
		DbSelectArea("SA1")
		DbSetOrder(1)
		If (DbSeek(cChave)) //Verifica se existe o cliente
			//Preenche arra de retorno com dados do Cliente
			aRetorno[3,3] := SA1->A1_NOME
			aRetorno[3,4] := SA1->A1_DTCAD
			aRetorno[3,5] := SA1->A1_HRCAD
			aRetorno[3,6] := DDATABASE
			aRetorno[3,7] := Time()
			aRetorno[3,8] := TKCalcPer(SA1->A1_DTCAD,SA1->A1_HRCAD,DDATABASE,Time())
				
			DbSelectArea("SUS")
			DbSetOrder(5)
			If	(DbSeek(xFilial("SUS")+SA1->A1_COD+SA1->A1_LOJA)) //Verifica se existe o prospect
				//Preenche arra de retorno com dados do Prospect
				aRetorno[2,3] := SUS->US_NOME
				aRetorno[2,4] := SUS->US_DTCAD
				aRetorno[2,5] := SUS->US_HRCAD
				aRetorno[2,6] := SUS->US_DTCONV
				aRetorno[2,7] := SUS->US_HRCONV
				aRetorno[2,8] := TKCalcPer(SUS->US_DTCAD,SUS->US_HRCAD,SUS->US_DTCONV,SUS->US_HRCONV)
					
				DbSelectArea("ACH")
				DbSetOrder(4)
				If (DbSeek(xFilial("ACH")+SUS->US_COD+SUS->US_LOJA)) //Verifica se existe o suspect
					//Preenche arra de retorno com dados do Suspect
					aRetorno[1,3] := ACH->ACH_RAZAO
					aRetorno[1,4] := ACH->ACH_DTCAD
					aRetorno[1,5] := ACH->ACH_HRCAD
					aRetorno[1,6] := ACH->ACH_DTCONV
					aRetorno[1,7] := ACH->ACH_HRCONV
					aRetorno[1,8] := TKCalcPer(ACH->ACH_DTCAD,ACH->ACH_HRCAD,ACH->ACH_DTCONV,ACH->ACH_HRCONV)
				Else
					aRetorno[1,2] := .F.
				EndIf
			Else
				aRetorno[2,2] := .F.
				aRetorno[1,2] := .F.
			EndIf
		Else
			aRetorno[3,2] := .F.
			aRetorno[2,2] := .F.
			aRetorno[1,2] := .F.
		EndIf
			
EndCase

RestArea(aAreaACH)
RestArea(aAreaSUS)
RestArea(aAreaSA1)
RestArea(aArea)

Return (aRetorno)


//------------------------------------------------------------------------------
/*/{Protheus.doc} TkC40PrcPm

Calcula o percentual de permanecia da conta em cada entidade.

@sample			TkC40PrcPm(dDtIniAch,cHrIniAch,dDtFimAch,cHrFimAch,dDtIniSus,cHrIniSus,dDtFimSus,cHrFimSus)

@param			dDtIniAch 	Data de Início do Suspect
							dDtIniAch   Data de Cadastro do Suspect
							cHrIniAch	Hora de Cadastro do Suspect
							dDtFimAch	Data de Conversão do Suspect
							cHrFimAch   Hora de Conversão do Suspect
							dDtIniSus 	Data de Cadastro do Prospect
							cHrIniSus	Hora de Cadastro do Prospect
							dDtFimSus	Data de Conversão do Prospect
							cHrFimSus   Hora de Conversão do Prospect

@return    	Tempo de permanencia da conta (em porcentagem) em cada entidade
							posicao[1]-> porcentagem da permanencia do suspect
							posicao[2]-> porcentagem da permanencia do prospect

@author 		Aline Kokumai
@since			15/05/2013
@version		P12
/*/
//------------------------------------------------------------------------------
Function TkC40PrcPm(dDtIniAch,cHrIniAch,dDtFimAch,cHrFimAch,dDtIniSus,cHrIniSus,dDtFimSus,cHrFimSus)

Local aRetorno		:= {0,0}	//array de retorno
Local nTempoAch		:= 0		//duracao total em horas do suspect
Local nTempoSus		:= 0		//duracao total em horas do prospect
Local nTempoTot		:= 0		//duracao total em horas da conta

/*/
/// Calcula tempo de permanencia apenas se o suspect foi convertido em prospect
/// O prospect poderá estar no status cliente (convertido) ou em andamento (não convertido)
/*/
If (!Empty(dDtIniAch) .AND. !Empty(dDtFimAch) .AND. !Empty(dDtIniSus))
	cHrFimAch := IIF((Empty(cHrFimAch) .OR. cHrFimAch==Nil),"23:59",cHrFimAch)
	nTempoAch := SubtHoras(dDtIniAch,cHrIniAch,dDtFimAch,cHrFimAch) //Tempo de permanecia do suspect
		
	If Empty(dDtFimSus)
		dDtFimSus := DDATABASE
		cHrFimSus := SubStr(Time(),1,5)
	ElseIf !Empty(dDtFimSus) .AND. Empty(cHrFimSus)
		cHrFim := "23:59"
	EndIf
		
	nTempoSus := SubtHoras(dDtIniSus,cHrIniSus,dDtFimSus,cHrFimSus)//Tempo de permanecia do prospect
		
	nTempoTot := nTempoAch + nTempoSus //Tempo de permanecia da conta
		
	aRetorno[1] := Round((nTempoAch * 100)/nTempoTot,2) //Porcentagem da permanencia do suspect
	aRetorno[2] := Round((nTempoSus * 100)/nTempoTot,2) //Porcentagem da permanencia do prospect
		
EndIf

Return	(aRetorno) 


//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk40AtInt

Função para atualizar os componentes da tela

@sample 			Tk40AtInt( 	oBrwCad, oPnlSup, oBrwEntid, oTree, oFWCFactoc, oFwChart, oPnlChart,;
		   						cCbxResA, aCbxResA, cCbxResB, aCbxResB, aEntInfo, aCampos)

@param				oBrwCad		- Browse da lista de registros e treeview
					oPnlSup		- Panel superior da lista de registros
					oBrwEntid	- Browse dos indicadores de conversao 
					oTree		- TreeView tempo de permanencia
					oFWCFactoc	- Instancia do grafico
					oFwChart	- Objeto grafico
					oPnlChart	- Panel para disposição do gráfico
					cCbxResA	- Tipo do gráfico selecionado	
					aCbxResA	- Combo box tipo de gráfico
					cCbxResB	- Opção do gráfico selecionado
					aCbxResB	- Combo box das opções de gráfico
					aEntInfo	- Array com o conteudo dos indicadores de conversao
					aCampos		- Array com os campos das entidades

@return			True

@author			Aline Kokumai
@since				16/05/2013
@version			P12
/*/
//------------------------------------------------------------------------------

Static Function Tk40AtInt( 	oBrwCad, oPnlSup, oBrwEntid, oTree, oFWCFactoc, oFwChart, oPnlChart,;
		   						cCbxResA, aCbxResA, cCbxResB, aCbxResB, aEntInfo, aCampos)
Local lRetorno := .T. 


If ValType(oTree) == "O" .AND. ValType(oBrwCad) == "O"
	oBrwCad:DeActivate()
	oBrwCad:Destroy()
	oPnlSup:FreeChildren()
	oBrwCad := Tk040Brw(oPnlSup,oBrwEntid,oTree,aEntInfo,aCampos)
	Tk040Graf(oFWCFactoc, oFwChart, oPnlChart, oBrwEntid, cCbxResA, aCbxResA, cCbxResB, aCbxResB, aEntInfo, aCampos, oPnlSup, oTree)	
EndIf

Return( lRetorno ) 


//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk040Brw

Gera browse para listagem dos registros selecionado na tabela dos indicadores ou na serie do gráfico.

@sample 			Tk040Brw(oPnlSup,oBrwEntid,oTree,aEntInfo,aCampos, cAlias, cNomEntid)

@param				oPnlSup		- Panel superior da lista de registros
					oBrwEntid 	- Browse dos indicadores de conversao 
					oTree		- TreeView tempo de permanencia
					aEntInfo	- Array com o conteudo dos indicadores de conversao
					aCampos		- Array com os campos das entidades
					cAlias		- Tabela selecionada (ACH,SUS,SA1)
					cNomEntid	- Nome da entidade (suspect, prospect ou cliente)

@return			True

@author			Aline Kokumai
@since				16/05/2013
@version			P12
/*/
//------------------------------------------------------------------------------

Static Function Tk040Brw(oPnlSup,oBrwEntid,oTree,aEntInfo,aCampos,cAlias,cNomEntid,cCodVend)

Local oMBrowse	:= Nil 
Local nPosEnt		:= 0
Local aCpoEnt		:= {} 
Local cFiltro		:= ""
Local cChave		:= ""
Local nX			:= 0
Local aAddFil  	:= {}
Local cFilPri   	:= ""
Local lNoCheck  	:= .T. 
Local lSelected 	:= .T.
Local cAliasFil 	:= "AO4"
Local cFilEnt   	:= ""


Default cAlias 	:= aEntInfo[oBrwEntid:At()][TABELA] //Recebe alias do browse caso não seja passado da serie do grafico
Default cNomEntid	:= aEntInfo[oBrwEntid:At()][ENTIDADE] //Recebe nome da entidade do browse caso não seja passado pelo grafico
Default cCodVend 	:= ""

nPosEnt := IIF(cAlias=="ACH",1,IIF(cAlias=="SUS",2,3)) //Recebe a posição do registro selecionado
aCpoEnt := aCampos[nPosEnt] //Recebe os campos de acordo com a posição o registro selecionado       

If oPnlSup<> Nil .And. ValType(oPnlSup)=='O'
	oPnlSup:FreeChildren()
EndIf

Do Case 

	Case cAlias == "ACH" 
		
		cFilPri := CRMXFilEnt("ACH",.T.)
		cFiltro :=  " ACH_FILIAL = '" + xFilial("ACH") + "' AND  ACH_DTCAD >= '" + Dtos(MV_PAR01) + "' AND ACH_DTCAD <= '" + Dtos(MV_PAR02) + "' "
		
		If Empty(cCodVend)
			If MV_PAR07 == 1 
				cFiltro += " AND ( ACH_VEND >= '"+MV_PAR08+"' AND ACH_VEND <= '"+MV_PAR09+"' )" 
			EndIf
		Else 
			cFiltro += " AND ACH_VEND == '"+cCodVend+"' "	
		EndIf
		
		cChave	:= "ACH->ACH_FILIAL+ACH->ACH_CODIGO+ACH->ACH_LOJA"
	
	Case cAlias == "SUS" 
		
		cFilPri := CRMXFilEnt("SUS",.T.)
		cFiltro := " US_FILIAL = '" + xFilial("SUS") + "' AND  US_DTCAD >= '" + Dtos(MV_PAR03) + "' AND US_DTCAD <= '" + Dtos(MV_PAR04) + "' "
		
		If Empty(cCodVend)
			If MV_PAR07 == 1 
				cFiltro += " AND ( US_VEND >= '"+MV_PAR08+"' AND US_VEND <= '"+MV_PAR09+"' )" 
			EndIf
		Else 
			cFiltro += " AND US_VEND == '"+cCodVend+"' "	
		EndIf		
		
		cChave	:= "SUS->US_FILIAL+SUS->US_COD+SUS->US_LOJA"
	
	Case cAlias == "SA1" 
		
		cFilPri := CRMXFilEnt("SA1",.T.)
		cFiltro := " A1_FILIAL = '" + xFilial("SA1") + "' AND  A1_DTCAD >= '" + Dtos(MV_PAR05) + "' AND A1_DTCAD <= '" + Dtos(MV_PAR06) + "' "
		
		If Empty(cCodVend)
			If MV_PAR07 == 1 
			 	cFiltro += " AND ( A1_VEND >= '"+MV_PAR08+"' AND A1_VEND <= '"+MV_PAR09+"' )" 
			EndIf
		Else 
			cFiltro += " AND A1_VEND == '"+cCodVend+"' "	
		EndIf		
		
		cChave	:= "SA1->A1_FILIAL+SA1->A1_COD+SA1->A1_LOJA"
EndCase
	
DbSelectArea(cAlias)
DbSetOrder(1)
	
oMBrowse := FWMBrowse():New()                
oMBrowse:SetOwner(oPnlSup)
oMBrowse:SetAlias(cAlias)
oMBrowse:SetOnlyFields(aCpoEnt)
oMBrowse:SetMenuDef("")
oMBrowse:SetChange({|| Tk040Tree(oTree,cAlias,&(cChave))})
oMBrowse:SetProfileID("2")
oMBrowse:DisableDetails()
oMBrowse:SetWalkThru(.F.)
oMBrowse:SetAmbiente(.F.)
oMBrowse:SetDescription(cNomEntid)
	
If(cAlias == "SA1")
	oMBrowse:AddButton(STR0034	,{||TkC40Visua("SA1")},,2,,.F.)	//"Visualizar"
ElseIf(cAlias == "SUS")
	oMBrowse:AddButton(STR0034	,{||TkC40Visua("SUS")},,2,,.F.)	//"Visualizar"
Else
	oMBrowse:AddButton(STR0034	,{||TkC40Visua("ACH")},,2,,.F.)	//"Visualizar"
EndIf		

oMBrowse:SetFilterDefault('@' + cFiltro)
 
If !Empty( cFilPri )
	aAdd( aAddFil, {STR0049, cFilPri, lNoCheck, lSelected, cAliasFil, /*lFilterAsk*/, /*aFilParser*/, "AO4_FILENT"} )		// "Filtro do CRM"
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtros adicionais do Controle de Acesso do CRM. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aAddFil)
	oMBrowse:DeleteFilter( aAddFil[nX][ADDFIL_ID] )
	oMBrowse:AddFilter( aAddFil[nX][ADDFIL_TITULO]	,;
					      aAddFil[nX][ADDFIL_EXPR]		,;
					      aAddFil[nX][ADDFIL_NOCHECK]	,;
					      aAddFil[nX][ADDFIL_SELECTED]	,; 
					      aAddFil[nX][ADDFIL_ALIAS]		,;
					      aAddFil[nX][ADDFIL_FILASK]	,;
					      aAddFil[nX][ADDFIL_FILPARSER],;
					      aAddFil[nX][ADDFIL_ID] )		 
	oMBrowse:ExecuteFilter()	 
Next nX		

oMBrowse:Activate()
	
Return( oMBrowse )


//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk040Tree

Gera Tree View para exibir a evolução da conta.

@sample				Tk040Tree(oTree,cEntidade,cChave)

@param				oTree 		Objeto do TreeView
					cEntidade	Nome da Entidade
					cChave		Chave do registro (Filial+Codigo+Loja)

@return			True

@author			Aline Kokumai
@since				16/05/2013
@version			P12                
/*/
//------------------------------------------------------------------------------

Static Function Tk040Tree(oTree,cEntidade,cChave)

Local aConta     := TkC40GetCt(cEntidade,cChave) //Busca dados da conta
Local nAuxCont	 := 0
Local nAuxTree	 := 0
Local cAuxTree	 := ""
Local aEntFldNam :=	{; 
						{"ACH","ACH_RAZAO"},;	// 01 - ACH
						{"SUS","US_NOME"}  ,;   // 02 - SUS
						{"SA1","A1_NOME"}  ,;	// 03 - SA1
					}
Local nPosEntity := aScan(aEntFldNam, {|aEntity| aEntity[ALIAS_ENTITY] == cEntidade})





oTree:Reset()

	For nAuxCont:=1 to Len(aConta) //Adiciona opção no tree para cada entidade da conta
		
		If (aConta[nAuxCont,2] == .T.) //Valida se existe a entidade
			
			// Insere item no tree
			nAuxTree++
			cAuxTree := "00"+ cValToChar(nAuxTree)
			oTree:AddItem(aConta[nAuxCont,1] + ": " + FATPDObfuscate(aConta[nAuxCont,3],aEntFldNam[nPosEntity][FIELD_NAME]) + Space(35),cAuxTree, "CLIENTE" ,,,,1)
			
			If oTree:TreeSeek(cAuxTree) //Se encontrar item do tree
				
					nAuxTree++
					cAuxTree := "00"+ cValToChar(nAuxTree)	
				If(aConta[nAuxCont,8] <> "") //Adiciona o tempo de permanencia se não for vazio
					oTree:AddItem(STR0029 + " " + cValToChar(aConta[nAuxCont,8]),cAuxTree, "FWOCN_MNU_MRU",,,,2) // "Tempo de Permanência:"
				Else //Se for vazio adiciona como indefinido
					oTree:AddItem(STR0029 + " " + STR0030,cAuxTree, "FWOCN_MNU_MRU",,,,2) // "Tempo de Permanência:" "Indefinido"
				EndIf
				
			EndIf
			
			oTree:TreeSeek(cAuxTree) // Retorna ao primeiro nível
			
		EndIf
	Next

	If !oTree:IsEmpty()
		oTree:EndTree() // Indica o término da contrução da Tree  
	EndIf

Return( .T. )

//------------------------------------------------------------------------------
/*/{Protheus.doc} TkC40Visua

Função para visualizar o registro selecionado no grid

@sample			TkC40Visua(cAlias)

@param			cAlias - Alias da entidade

@return		True

@author		Aline Kokumai
@since			16/05/2013
@version		P12                
/*/
//------------------------------------------------------------------------------
Function TkC40Visua(cAlias)

Local lRetorno := .T.
Private cCadastro := ""

	FATPDLogUser("TKC40VISUA")
	
	If (cAlias)->(!Eof())
		If (cAlias == "SA1")
			aRotina	:= {{STR0034, "A030Visual" , 0 , 2,0   , NIL}} //"Visualizar" 
			cCadastro := STR0024 //"Clientes"
			A030Visual("SA1",SA1->(RecNo()),1)
			aRotina   := {}
			cCadastro := ""
		ElseIf(cAlias == "SUS")		
			FWExecView(STR0034,"VIEWDEF.TMKA260",1,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/) //"Visualizar"
		Else
			FWExecView(STR0034,"VIEWDEF.TMKA341",1,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/) //"Visualizar" 
		EndIf
	Else
		Help(" ",1,"SemDados")	
	EndIf
	
Return (lRetorno)
        
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