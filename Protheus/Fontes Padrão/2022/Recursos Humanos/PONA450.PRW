#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PONA450.CH"

Static dIniFil := CtoD("")
Static dFimFil := CtoD("")
Static lIntTAE
Static lWenBtn := .F.
Static oSign   := NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    	³ PONA450    ³ Autor ³ Leandro Drumond       	      ³ Data ³ 30/03/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o 	³ Controle de Espelhos de Ponto			                      			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   	³ PONA450()                                                    			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      	³ Generico ( DOS e Windows )                                   			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data     ³ Chamado/Req.	³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Matheus M.   ³23/08/2016³ TVVOYV     	³  Ajuste no momento de limpar o GET para   ³±±
±±³			    ³          ³             	³  que o tamanho do campo continue o origi- ³±±
±±³			    ³          ³             	³  nal, permitindo uma nova digitação.	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function PONA450()

Local oMBrowse
Local cFiltraRh
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
Local aFldRel		:= {"RA_NOME", "RA_ADMISSA", "RS4_CODEBA"}
Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )

//Tratamento de acesso a Dados Sensíveis
If lBlqAcesso
	//"Dados Protegidos- Acesso Restrito: Este usuário não possui permissão de acesso aos dados dessa rotina. Saiba mais em {link documentação centralizadora}"
	Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)
	Return
EndIf

oMBrowse := FWMBrowse():New()

oMBrowse:SetAlias("SRA")
oMBrowse:SetDescription(OemToAnsi(STR0001)) //'Controle de Espelho de Ponto'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFiltraRh := CHKRH("PONA450","SRA","1")
oMBrowse:SetFilterDefault( cFiltraRh )

GpLegMVC(@oMBrowse)

// - Valida se o usuário tem acesso
If BloqPer()

	Return (Nil)

EndIf

oMBrowse:Activate()

Return

/*/{Protheus.doc} ModelDef
Regras de modelagemda gravação.

@author Leandro Drumond
@since 30/03/2015
@version 12.1.5

@return nulo
/*/
Static Function ModelDef()
	
	Local oModel
	Local oStructSRA
	Local oStruRS4CB
	Local oStruRS4TAE
	
	DEFAULT lIntTAE := ChkFile("RS4") .And. RS4->(ColumnPos("RS4_TPDOC")) > 0 .And. FindFunction("FwTotvsSign")
	
	// Criação do Objeto de Modelagem de dados da tabela RS4
	oModel := MPFormModel():New("PONA450", NIL, NIL)
	oModel:SetDescription( OemToAnsi(STR0001) ) //'Controle de Espelho de Ponto'
	
	// Estrutura de campos do Model //
	oStructSRA := FWFormStruct(1, "SRA", {|cCampo| AllTrim(cCampo) + "|" $ "RA_FILIAL|RA_MAT|RA_NOME|RA_ADMISSA|"})
	oStruRS4CB := FWFormStruct(1, "RS4")
	
	oStruRS4CB:AddField(' ', 'RS4_LEG', 'RS4_LEG', 'BT', 1, 0, /*bValid*/, /*bWhen*/,, .F., {||Pn450Leg(.F.)})
	
	oModel:AddFields("PONA450_SRA",, oStructSRA )
	oModel:GetModel("PONA450_SRA"):SetOnlyView( .T. )
	oModel:GetModel("PONA450_SRA"):SetOnlyQuery( .T. )
	oModel:AddGrid("PONA450_RS4", "PONA450_SRA", oStruRS4CB, { |oGrid, nLine, cAction, cField| Pn450DelOk(oGrid, nLine, cAction, cField) },,,, {|oGrid|CargaGrid(oGrid)})
	oModel:GetModel('PONA450_RS4'):SetOptional(.F.)
	
	// Não Permite Incluir linhas na formgrid
	oModel:GetModel( "PONA450_RS4" ):SetNoInsertLine()
	FWMemoVirtual( oStruRS4CB, {{ 'RS4_CODOBS', 'RS4_OBSERV' }})
	oModel:GetModel("PONA450_RS4"):SetUniqueLine( { "RS4_PER", "RS4_CODEBA" } )
	oModel:SetRelation("PONA450_RS4", {{"RS4_FILIAL", 'xFilial("RS4")'}, {"RS4_MAT", "RA_MAT"}}, RS4->(IndexKey()))
	
	If lIntTAE
		
		// Remove os campos referentes ao TAE da estrutura com os registros com o Código de barras
		oStruRS4CB:RemoveField("RS4_NDOC")
		oStruRS4CB:RemoveField("RS4_ID")
		oStruRS4CB:RemoveField("RS4_DTINTE")
		
		oModel:GetModel('PONA450_RS4'):SetOptional(.T.)
		
		// Cria uma nova estrutura da tabela RS4 para os registros integrados ao TAE 
		oStruRS4TAE := FWFormStruct(1, "RS4")	
		oStruRS4TAE:AddField(' ', 'RS4_LEG', 'RS4_LEG', 'BT', 1, 0, ,,, .F., {||Pn450Leg(.F.)})
		oStruRS4TAE:SetProperty("RS4_STATUS", MODEL_FIELD_WHEN, {|| .T.})
		
		// Remove os campos referentes ao código de barras da estrutura com os registros referentes ao TAE
		oStruRS4TAE:RemoveField("RS4_CODEBA")
		
		// Cria o segundo grid com os arquivos enviados para o TAE
		oModel:AddGrid( "PONA450_TAE", "PONA450_SRA", oStruRS4TAE, { |oGrid, nLine, cAction, cField| Pn450DelOk(oGrid, nLine, cAction, cField) },,,, {|oGrid|CargaGrid(oGrid)})
		oModel:GetModel( "PONA450_TAE"):SetOptional(.T.)
		oModel:GetModel( "PONA450_TAE" ):SetNoInsertLine()
		
		FWMemoVirtual( oStruRS4CB, {{'RS4_CODOBS', 'RS4_OBSERV' }})
		oModel:GetModel("PONA450_TAE"):SetUniqueLine( { "RS4_PER", "RS4_ID" } )
		oModel:SetRelation("PONA450_TAE", {{"RS4_FILIAL", "xFilial('RS4')"}, {"RS4_MAT", "RA_MAT"}}, RS4->(IndexKey()))	
		
		// Filtra as informações de cada grid
		oModel:GetModel( "PONA450_RS4" ):SetLoadFilter({{ "RS4_TPDOC", "'1'", MVC_LOADFILTER_NOT_EQUAL}})
		oModel:GetModel( "PONA450_TAE" ):SetLoadFilter({{ "RS4_TPDOC", "'1'" }})
		
	EndIf
	
Return( oModel )

/*/{Protheus.doc} ViewDef
Regras de interface do usuário.
@author Leandro Drumond
@since 30/03/2015
@version 12.1.5
@return nulo
/*/
Static Function ViewDef()
	
	Local oView
	Local oModel
	Local oStructSRA
	Local oStruRS4CB
	Local oStruRS4TAE
	
	DEFAULT lIntTAE := ChkFile("RS4") .And. RS4->(ColumnPos("RS4_TPDOC")) > 0 .And. FindFunction("FwTotvsSign")
	
	// Criacao da Interface
	oView := FWFormView():New()
	
	// Vincular o View ao Model
	oModel := FWLoadModel("PONA450")
	oView:SetModel(oModel)
	
	oStructSRA := FWFormStruct(2, "SRA", {|cCampo| AllTrim(cCampo) + "|" $ "RA_MAT|RA_NOME|RA_ADMISSA|"})
	oStructSRA:SetNoFolder()
	
	oView:AddField( "PONA450_SRA", oStructSRA )
	
	oStruRS4CB := FWFormStruct(2, "RS4")
	
	// Adiciona campo legenda.
	oStruRS4CB:AddField( 'RS4_LEG', '01', '', '', , "BT")
	
	oStruRS4CB:RemoveField( "RS4_MAT" )
	
	oView:AddGrid( "PONA450_RS4", oStruRS4CB )
	
	oView:SetViewProperty("PONA450_SRA", "OnlyView") // Somente visualização. Não permite edição dos campos do cabeçalho (SRA)
	
	oView:createHorizontalBox("FORMFIELD", 15)
	oView:createHorizontalBox("GRID"     , 85)
	
	If lIntTAE
		
		// Remove os campos referentes ao TAE da estrutura com os registros com o Código de barras
		oStruRS4CB:RemoveField("RS4_NDOC")
		oStruRS4CB:RemoveField("RS4_ID")
		oStruRS4CB:RemoveField("RS4_DTINTE")
		oStruRS4CB:RemoveField("RS4_TPDOC")
		
		// Cria uma nova estrutura da tabela RS4 para os registros integrados ao TAE 
		oStruRS4TAE := FWFormStruct(2, "RS4")
		oStruRS4TAE:AddField( 'RS4_LEG', '01', '', '', , "BT")
		oStruRS4TAE:SetProperty("RS4_STATUS", MVC_VIEW_CANCHANGE, .F.)
		oStruRS4TAE:SetProperty("RS4_NDOC", MVC_VIEW_CANCHANGE, .F.)
		oStruRS4TAE:SetProperty("RS4_ID", MVC_VIEW_CANCHANGE, .F.)
		oStruRS4TAE:SetProperty("RS4_DTINTE", MVC_VIEW_CANCHANGE, .F.)
		
		oStruRS4TAE:RemoveField("RS4_MAT" )
		oStruRS4TAE:RemoveField("RS4_CODEBA")
		oStruRS4TAE:RemoveField("RS4_TPDOC")
		
		oView:AddGrid(  "PONA450_TAE", oStruRS4TAE )
		
		// Adiciona a barra com os botões
		oView:AddOtherObject("VIEW_BUTTONBAR", {|oPanel| ButtonBar(oPanel)})
		oView:SetViewProperty( 'PONA450_TAE', "CHANGELINE", {{ |oView| ButtonsWhen(oView) }})
		oView:SetAfterViewActivate({ |oView| ButtonsWhen(oView) })
		
		//Cria as abas 
		oView:CreateFolder("PASTAS", "GRID")
		oView:addSheet("PASTAS", "TAE", "Assinatura Eletrônica")
		oView:addSheet("PASTAS", "CodBar", "Código de barras")
		
		oView:CreateHorizontalBox( "BUTTONBAR", 5,,, "PASTAS", "TAE" )
		oView:CreateHorizontalBox( "GRIDTAE"  , 95,,, "PASTAS", "TAE" )
		
		oView:CreateHorizontalBox( "GRIDCD", 100,,, "PASTAS", "CodBar" )
		
		oView:SetOwnerView( "VIEW_BUTTONBAR", "BUTTONBAR")
		oView:SetOwnerView( "PONA450_TAE", "GRIDTAE")
		oView:SetOwnerView( "PONA450_RS4", "GRIDCD")
		
	Else
		oView:SetOwnerView( "PONA450_RS4", "GRID")
	EndIf
	
	oView:SetOwnerView( "PONA450_SRA", "FORMFIELD")
	
	oView:EnableControlBar(.T.)
	
	oView:AddUserButton(STR0002, '', {|oView|Pn450Leg(.T.)}) // Legenda
	
	oView:SetCloseOnOk({ || .T. })
	
Return oView

/*/{Protheus.doc} Pn450LinOk
Valida Possibilidade de deleção da linha.
@author Leandro Drumond.
@since 02/04/2015
@version 12.1.5
/*/
Static Function Pn450DelOk(oGrid, nLine, cAction, cField)
	
	Local lRet := .T.
	DEFAULT lIntTAE := ChkFile("RS4") .And. RS4->(ColumnPos("RS4_TPDOC")) > 0 .And. FindFunction("FwTotvsSign")
	
	If cAction == 'DELETE'
		If lIntTAE .And. oGrid:GetValue("RS4_TPDOC") == "1"
			lRet := fDelDocTAE(.T.)
		ElseIf oGrid:GetValue("RS4_STATUS") == "1"
	    	Help(,,STR0003,, STR0004,1,0 ) //"Registros de espelhos entregues não podem ser excluídos."
			lRet := .F.
		EndIf
	ElseIf cAction == 'UNDELETE' .And. lIntTAE .And. oGrid:GetValue("RS4_TPDOC") == "1"
		Help(,,STR0003,, STR0066, 1, 0 ) // "O documento foi excluído do Totvs Assinatura Eletrônica, Não é possível desfazer essa ação."
		lRet := .F.
	EndIf
	
Return lRet

/*/{Protheus.doc} Pn450Leg
Monta a legenda dos registros apresentados no Grid.
@author Leandro Drumond.
@since 02/04/2015
@version 12.1.5
/*/
Function Pn450Leg(lTela)
Local oLegenda	:= Nil
Local xRet		:= Nil

If lTela
	oLegenda := FwLegend():New()
	oLegenda:add('RS4->RS4_STATUS==1','GREEN' ,STR0005)		//"Devolvido"
	oLegenda:add('RS4->RS4_STATUS==2','YELLOW',STR0006)		//"Pendente"
	oLegenda:add('RS4->RS4_STATUS==3','RED'   ,STR0007)		//"Cancelado"
	oLegenda:View()
	oLegenda:=nil
Else
	If RS4->RS4_STATUS == '1'	 //Devolvido
		xRet := 'br_verde'
	ElseIf RS4->RS4_STATUS ==  '3' //Cancelado
		xRet := 'br_vermelho'
	Else //Pendente
		xRet := 'br_amarelo'
	EndIf
EndIf

Return xRet

/*/{Protheus.doc} Pn450When
When do campo RS4_STATUS e RS4_OBSERV
@author Leandro Drumond
@since 02/04/2015
@version 12.1.5
@return lógico
/*/
Function Pn450When(nTipo)
Local lRet		:= .T.
Local oModel	:= FWModelActivate()
Local oGrid 	:= oModel:GetModel("PONA450_RS4")

If ( nTipo ==1 .and. oGrid:GetValue("RS4_STATUS") == '1' ) .or. Empty(oGrid:GetValue("RS4_CODEBA")) //Se o espelho já foi devolvido, ou não existe nenhum registro na grid (primeira linha vazia), não permite alteração.
	lRet := .F.
EndIf

Return lRet

/*/{Protheus.doc} Pn450Baixar
Abre o pop up para dar baixa nos espelhos de ponto entregues.
@author Leandro Drumond
@since 30/03/2015
@version 12.1.5
@return nulo
/*/
Function Pn450Baixa()
Local aButtons 		:= {}
Local aSvKeys		:= GetKeys()
Local cCodeBar		:= Space(60)
Local cObservacao	:= Space(80)
Local aDadosFunc	:= {Space(20),Space(100),Space(20),Space(30)}
Local lVldOk		:= .F.
Local oDlg
Local oGroup
Local oFont
Local oCodeBar
Local oObserva
Local oBtnGravar
Local oBtnOk
Local oDadosFunc
Local oSize			:= Nil

SetKey( VK_F5  , {|| iif(lVldOk .and. Pn440Grv(cObservacao),Pn450Clear(@cCodeBar,@cObservacao,@aDadosFunc),Nil) }  )
SetKey( VK_F6  , {|| iif(lVldOk .and. Pn440Grv(cObservacao),oDlg:End(),Nil) } )

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
oSize := FwDefSize():New(.F.)
oSize:AddObject( "CABECALHO",(oSize:aWindSize[3]*1.1),220 , .F., .F. ) // Não dimensionavel
oSize:aMargins 	:= { 0, 0, 0, 0 } // Espaco ao lado dos objetos 0, entre eles 3
oSize:lProp 	:= .F. // Proporcional
oSize:Process() 	   // Dispara os calculos

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
DEFINE MSDIALOG oDlg FROM  0,0 TO 220,(oSize:aWindSize[3]*1.1) TITLE OemToAnsi(STR0008) PIXEL //"Baixar Espelho de Ponto"

@ oSize:GetDimension("CABECALHO","LININI")+3,oSize:GetDimension("CABECALHO","COLINI")+3 GROUP oGroup TO oSize:GetDimension("CABECALHO","LINEND") * 0.39 ,( oSize:GetDimension("CABECALHO","COLEND") * 0.5 ) OF oDlg PIXEL

@ oSize:GetDimension("CABECALHO","LININI")+10,oSize:GetDimension("CABECALHO","COLINI")+15 SAY STR0009 Of oDlg Pixel FONT oFont //"Código de Barras"
@ oSize:GetDimension("CABECALHO","LININI")+18,oSize:GetDimension("CABECALHO","COLINI")+15 MSGET oCodeBar Var cCodeBar PICTURE "@!";
						VALID Pn450VldCode(cCodeBar,@aDadosFunc,@lVldOk) ;
						SIZE oSize:aWindSize[3]*0.52,10 OF oDlg PIXEL HASBUTTON
@ oSize:GetDimension("CABECALHO","LININI")+35,oSize:GetDimension("CABECALHO","COLINI")+15 SAY STR0010 Of oDlg Pixel FONT oFont //"Observação"
@ oSize:GetDimension("CABECALHO","LININI")+43,oSize:GetDimension("CABECALHO","COLINI")+15 MSGET oObservacao Var cObservacao PICTURE "@!";
						SIZE oSize:aWindSize[3]*0.52,10 OF oDlg PIXEL HASBUTTON

@ oSize:GetDimension("CABECALHO","LININI")+60,oSize:GetDimension("CABECALHO","COLINI")+15 SAY STR0011  Of oDlg Pixel FONT oFont //"Filial:"
@ oSize:GetDimension("CABECALHO","LININI")+60,oSize:GetDimension("CABECALHO","COLINI")+40 SAY aDadosFunc[1] Of oDlg Pixel

@ oSize:GetDimension("CABECALHO","LININI")+60,oSize:GetDimension("CABECALHO","COLINI")+75 SAY STR0012  Of oDlg Pixel FONT oFont //"Funcionário:"
@ oSize:GetDimension("CABECALHO","LININI")+60,oSize:GetDimension("CABECALHO","COLINI")+110 SAY aDadosFunc[2] Of oDlg Pixel

@ oSize:GetDimension("CABECALHO","LININI")+75,oSize:GetDimension("CABECALHO","COLINI")+15 SAY STR0013  Of oDlg Pixel FONT oFont //"Período:"
@ oSize:GetDimension("CABECALHO","LININI")+75,oSize:GetDimension("CABECALHO","COLINI")+40 SAY aDadosFunc[3] Of oDlg Pixel

@ oSize:GetDimension("CABECALHO","LININI")+75,oSize:GetDimension("CABECALHO","COLINI")+110 SAY aDadosFunc[4] Of oDlg Pixel FONT oFont COLOR CLR_RED

oBtnGravar	:= TButton():New( oSize:GetDimension("CABECALHO","LININI")+95,oSize:GetDimension("CABECALHO","COLEND")/2 - 140 , "&"+STR0014 ,NIL,{|| iif(Pn440Grv(cObservacao),Pn450Clear(@cCodeBar,@cObservacao,@aDadosFunc),Nil) }	, 040 , 012 , NIL , NIL , NIL , .T., , , , {||lVldOk} )	// "Gravar"
oBtnOk		:= TButton():New( oSize:GetDimension("CABECALHO","LININI")+95,oSize:GetDimension("CABECALHO","COLEND")/2 - 90, "&"+STR0015 ,NIL,{|| iif(Pn440Grv(cObservacao),oDlg:End(),Nil) }	, 040 , 012 , NIL , NIL , NIL , .T., , , , {||lVldOk} )	// "Gravar e Sair"
oBtnFechar	:= TButton():New( oSize:GetDimension("CABECALHO","LININI")+95,oSize:GetDimension("CABECALHO","COLEND")/2 - 40, "&"+STR0027 ,NIL,{|| oDlg:End() }	, 040 , 012 , NIL , NIL , NIL , .T. )	// "Fechar"

ACTIVATE MSDIALOG oDlg CENTERED

SetKey( VK_F5  , {||NIL}  )
SetKey( VK_F6  , {||NIL}  )

Return Nil

/*/{Protheus.doc} Pn450VldCode
Valida código de barras digitado.

@author Leandro Drumond
@since 30/03/2015
@version 12.1.5
@param cCodeBar - Código de barras do espelho de ponto
@param aDadosFunc - Array com filial, matricula + nome e período para exibição na tela

@return lógico
/*/
Static Function Pn450VldCode(cCodeBar,aDadosFunc,lVldOk)
Local lRet		:= .F.

DbSelectArea("SRA")
DbSetOrder(1)

DbSelectArea("RS4")
DbSetOrder(2) //RS4_CODEBA

aDadosFunc[4] := ""

If DbSeek(AllTrim(cCodeBar))
	If AllTrim(RS4->RS4_CODEBA) == AllTrim(cCodeBar) //Confirma que código de barras esta completo.
		lRet 	:= .T.
		lVldOk 	:= .T.
		If RS4->RS4_STATUS <> '2'
			lVldOk := .F.
			aDadosFunc[4] := STR0016//"Registro já processado."
		EndIf
	EndIf
EndIf

If lRet
	SRA->(DbSeek(RS4->RS4_FILIAL + RS4->RS4_MAT))
	aDadosFunc[1] := RS4->RS4_FILIAL
	aDadosFunc[2] := RS4->RS4_MAT + " - " + SRA->RA_NOME
	aDadosFunc[3] := DtoC(RS4->RS4_DATAI) + " - " + DtoC(RS4->RS4_DATAF)
Else
	aDadosFunc[1] := ""
	aDadosFunc[2] := ""
	aDadosFunc[3] := ""
	aDadosFunc[4] := STR0017 //"Nenhum registro encontrado"
	lVldOk := .F.
EndIf

Return .T. //Sempre retorna .T. para que valor label seja alterado.

/*/{Protheus.doc} Pn440Grv
Grava baixa de espelho de ponto.
@author Leandro Drumond
@since 30/03/2015
@version 12.1.5
@return lógico
/*/
Static Function Pn440Grv(cObservacao)
Local cMemoAux	:= ""

If !Empty(cObservacao)
	cMemoAux := MSMM(RS4->RS4_CODOBS,Nil,Nil,cObservacao,1,,,"RS4","RS4_CODOBS")
EndIf

RecLock("RS4",.F.)
RS4->RS4_STATUS := "1"
RS4->RS4_CODOBS := cMemoAux
MsUnLock()

Return .T.

/*/{Protheus.doc} Pn450Clear
Limpa dados da tela.

@author Leandro Drumond
@since 30/03/2015
@version 12.1.5

@return nulo
/*/
Static Function Pn450Clear(cCodeBar,cObservacao,aDadosFunc)

cCodeBar 	:= Space(60)
cObservacao := Space(80)
aDadosFunc[1] := ""
aDadosFunc[2] := ""
aDadosFunc[3] := ""
aDadosFunc[4] := ""

Return Nil

/*/{Protheus.doc} Pn450Filtro
Filtra espelhos exibidos na getdados por data.
@author Leandro Drumond
@since 05/04/2015
@version 12.1.5
@return nulo
/*/
Function Pn450Filtro()
	
	Local dDataIni	:= dIniFil
	Local dDataFim	:= dFimFil
	Local oDataIni
	Local oDataFim
	Local oSize
	Local oDlg
	Local oFont
	Local nOpcA := 0
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes dos Objetos         					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	oSize := FwDefSize():New(.T.)
	oSize:AddObject( "CABECALHO",150,100 , .F., .F. ) // Não dimensionavel
	oSize:aMargins 	:= { 0, 0, 0, 0 } // Espaco ao lado dos objetos 0, entre eles 3
	oSize:lProp 	:= .F. // Proporcional
	oSize:Process() 	   // Dispara os calculos
	
	bSet15 := {|| If(Pn450FilData(dDataIni,dDataFim),(nOpcA:=1,oDlg:End()),Nil)}
	bSet24 := {|| nOpcA := 2, oDlg:End()}
	
	DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
	DEFINE MSDIALOG oDlg FROM  0,0 TO 200,400 TITLE OemToAnsi(STR0018) PIXEL //"Filtrar Espelhos de Ponto"
	
	@ oSize:GetDimension("CABECALHO","LININI")+10,oSize:GetDimension("CABECALHO","COLINI")+15 SAY STR0019 Of oDlg Pixel FONT oFont //"Data Inicio"
	@ oSize:GetDimension("CABECALHO","LININI")+18,oSize:GetDimension("CABECALHO","COLINI")+15 MSGET oDataIni Var dDataIni PICTURE "@!" SIZE 60,10 OF oDlg PIXEL HASBUTTON
	@ oSize:GetDimension("CABECALHO","LININI")+35,oSize:GetDimension("CABECALHO","COLINI")+15 SAY STR0020 Of oDlg Pixel FONT oFont //"Data Fim"
	@ oSize:GetDimension("CABECALHO","LININI")+43,oSize:GetDimension("CABECALHO","COLINI")+15 MSGET oDataFim Var dDataFim PICTURE "@!" SIZE 60,10 OF oDlg PIXEL HASBUTTON
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 )
	
	If nOpcA == 1
		dIniFil	:= dDataIni
		dFimFil	:= dDataFim
	EndIf
	
Return Nil

/*/{Protheus.doc} Pn450FilData(dDataIni,dDataFim)
Valida datas para filtro dos espelhos

@author Leandro Drumond
@since 05/04/2015
@version 12.1.5

@return lógico
/*/
Static Function Pn450FilData(dDataIni,dDataFim)
Local lRet	:= .T.

If dDataFim < dDataIni
	Help(,,STR0003,, STR0021,1,0 ) //"A data final deve ser maior que a data inicial."
	lRet := .F.
EndIf

Return lRet

/*/{Protheus.doc} CargaGrid
Carrega grid filtrado
@author Leandro Drumond
@since 06/04/2015
@version 12.1.5
@return array
/*/
Static Function CargaGrid(oGrid)
	
	Local aRet 			:= {}
	Local aRet2			:= {}
	Local nX			:= 0
	Local nPosAux		:= 0
	
	aRet2 := FormLoadGrid(oGrid)
	
	If Empty(dIniFil) .and. Empty(dFimFil)
		aRet := aClone(aRet2)
	Else
		nPosAux := oGrid:GetIdField("RS4_DATAI")
		
		For nX:= 1 to Len(aRet2)
			If aRet2[nX, 2, nPosAux] >= dIniFil .and. aRet2[nX,2,nPosAux] <= dFimFil
				aAdd(aRet, aClone(aRet2[nX]))
			EndIf
		Next
	EndIf
	
Return aRet

/*/{Protheus.doc} MenuDef
Criação do menudo browse.
@author Leandro Drumond
@since 30/03/2015
@version 12.1.5
@return Array
/*/
Static Function MenuDef()
	
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0022  ACTION "PESQBRW"         	OPERATION 1 ACCESS 0 DISABLE MENU 	//'Pesquisar'
	ADD OPTION aRotina TITLE STR0023  ACTION "VIEWDEF.PONA450" 	OPERATION 2 ACCESS 0 				//'Visualizar'
	ADD OPTION aRotina TITLE STR0024  ACTION "VIEWDEF.PONA450" 	OPERATION 4 ACCESS 0				//'Manutenção'
	ADD OPTION aRotina TITLE STR0025  ACTION "Pn450Baixa()" 	OPERATION 5 ACCESS 0				//'Baixar'
	ADD OPTION aRotina TITLE STR0026  ACTION "Pn450Filtro()"	OPERATION 5 ACCESS 0				//'Filtrar Espelhos'
	
	// Integração com o Totvs Assinatura eletrônica
	ADD OPTION aRotina TITLE STR0028 ACTION "ConfigTAE()" OPERATION 6 ACCESS 0 // "Config. Assina. Eletr."
	ADD OPTION aRotina TITLE STR0065 ACTION "fTAEStatus()" OPERATION 6 ACCESS 0 // "Verificar assinaturas"
	
Return aRotina

/*/{Protheus.doc}ConfigTAE
Cria tela para informar usuário e senha para acesso ao TAE
@author Cícero Alves
@since 23/02/2022
/*/
Function ConfigTAE()
	
	Local cMsg1			:= ""
	Local cSenha		:= Space(50)
	Local cUsuario		:= Space(50)
	Local nOpca			:= 0
	Local oDlg			:= Nil
	Local oSenha		:= Nil
	Local oUsr			:= Nil
	
	DEFAULT lIntTAE := ChkFile("RS4") .And. RS4->(ColumnPos("RS4_TPDOC")) > 0 .And. FindFunction("FwTotvsSign")
	
	If !lIntTAE
		//"Funcionalidade não disponível para esta versão do sistema."
		Help( ,, "HELP",, STR0067, 1,,,,,,, {STR0068}) // "Para utilizar a integração com o Totvs Assinatura Eletrônica é necessário atualizar o sistema."
		Return
	EndIf
	
	cMsg1 := STR0029 + CRLF // "Essa rotina permite configurar o usuário e senha "
	cMsg1 += STR0030 		// "para integração com oTotvs Assinatura Eletrônica."
	
	DEFINE MSDIALOG oDlg TITLE STR0031 FROM 10,30 TO 200,500 OF oMainWnd PIXEL // "Configuração Totvs Assinatura Eletrônica"
		
		@ 6,4  SAY cMsg1 OF oDlg  PIXEL
		
		@ 35,4  SAY STR0032 OF oDlg  PIXEL // "Usuário:"
		@ 34,30 MSGET oUsr VAR cUsuario SIZE 140,08 VALID .T. OF oDlg PIXEL 
		
		@ 49,4  SAY STR0033 OF oDlg PIXEL // "Senha:"
		@ 48,30 MSGET oSenha VAR cSenha SIZE 140,08 VALID .T. OF oDlg PIXEL PASSWORD 
		
		DEFINE SBUTTON FROM 75,10 TYPE 1 ACTION (nOpca := 1, Iif(AtuUserTAE(cUsuario, cSenha), oDlg:End(), .F.)) ENABLE OF oDlg
		DEFINE SBUTTON FROM 75,40 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
		
	ACTIVATE MSDIALOG oDlg CENTERED
	
Return

/*/{Protheus.doc}AtuUserTAE
Efetua gravação dos dados nos parâmetros
@author Cícero Alves
@since 23/02/2022
/*/
Static Function AtuUserTAE(cUsuario, cSenha)
	
	Local lRet := .T.
	
	If !Empty(cUsuario) .And. !Empty(cSenha) 
		If ValidLogin(cUsuario, cSenha)
			PutMv( "MV_RHTAEUS", rc4crypt( AllTrim(cUsuario), "123456789", .T.) )
			PutMv( "MV_RHTAEPW", rc4crypt( AllTrim(cSenha), "123456789", .T.) )
		EndIf
	Else
		// "Usuário ou senha não informado." - "Efetue o preenchimento do usuário e da senha"
		Help( ,, "HELP",, STR0034, 1,,,,,,, {STR0035})
		lRet := .F.
	EndIf
	
Return lRet

/*/{Protheus.doc} ValidLogin(cUsuario, cSenha)
Valida o usuário e senha informados
@type  Static Function
@author Cícero Alves
@since 23/02/2022
@param cUsuario, Caractere, Usuario para login no TAE
@param cSenha, Caractere, Senha para login no TAE
@return lRet, Lógico, Verdadeiro quando o login é realizado com sucesso
/*/
Static Function ValidLogin(cUsuario, cSenha)
	
	Local lRet	:= .T.
	Local oSign	:= Nil
	
	Default cusuario := ""
	Default cSenha := ""
	
	If !Empty(SuperGetMv('MV_SIGNURL',, ""))
		
		cUsuario := AllTrim(cUsuario)
		cSenha := AllTrim(cSenha)
		
		oSign := FwTotvsSign()
		oSign:authenticate( cUsuario, cSenha )
		
		If !oSign:isAuthenticated()
			//"Não foi possível efetuar a autenticação no Totvs Assinatura Eletrônica"
			Help( ,, "HELP",, STR0036, 1,,,,,,, {STR0037}) // "Verifique o usuário e senha informados"
			lRet := .F.
		EndIf
	Else
		//"Para configurar a integração com o Totvs Assinatura Eletrônica é necessário informar o parâmetro MV_SIGNURL no configurador"
		Help( ,, "HELP",, STR0036, 1,,,,,,, {STR0038} ) 
		lRet := .F.
	EndIf
	
Return lRet

/*/{Protheus.doc} ButtonBar
Adiciona botões com as opções para os documento integrados com o TAE
@type  Static Function
@author Cícero Alves
@since 28/02/2022
@param oPanel, Objeto, painel onde serão ancorados os botões
/*/
Static Function ButtonBar(oPanel)
	
	Local oBar
	
	DEFINE FONT oFont NAME "Arial" SIZE 0,-12 BOLD
	
	oBar := TBar():New( oPanel, oPanel:nHeight, oPanel:nHeight, .F.,,,, .T.)
	
	oPanel:lShowHint := .T.
	
	// Exclui o documento no TAE
	DEFINE BUTTON oBtApoDel RESOURCE "DELWEB.PNG" OF oBar WHEN lWenBtn ACTION MsAguarde( {|| fDelDocTAE()}, STR0048, STR0061, .F.) // "Excluindo arquivo"
	oBtApoDel:Align := CONTROL_ALIGN_LEFT
	oBtApoDel:cToolTip := OemToAnsi(STR0062) // "Excluir Documento"
	oBtApoDel:cTitle := ""
	
	// Download do documento
	DEFINE BUTTON oBtApoAb RESOURCE "TOTVSPRINTER_PDF.PNG" OF oBar ACTION MsAguarde( {|| fDownload()}, STR0048, STR0060, .F.) // "Salvando arquivo"
	oBtApoAb:Align := CONTROL_ALIGN_LEFT
	oBtApoAb:cToolTip := OeMToAnsi(STR0063)  // "Download"
	oBtApoAb:cTitle	:= ""
	
	// Verificar assinatura
	DEFINE BUTTON oBtApoAb RESOURCE "TK_VERTIT.PNG" OF oBar WHEN lWenBtn ACTION MsAguarde( {|| fAtuStatus()}, STR0048, STR0058, .F.) // "Atualizando status do documento"
	oBtApoAb:Align := CONTROL_ALIGN_LEFT
	oBtApoAb:cToolTip := OeMToAnsi(STR0064) // "Verificar assinatura" 
	oBtApoAb:cTitle	:= ""
	
	// Reenviar e-mail
	DEFINE BUTTON oBtApoAb RESOURCE "GEOEMAIL.PNG" OF oBar WHEN lWenBtn ACTION MsAguarde( {|| fSendMail()}, STR0048, STR0059, .F.) // "Aguarde" - "Enviando e-mail"
	oBtApoAb:Align := CONTROL_ALIGN_LEFT
	oBtApoAb:cToolTip := OeMToAnsi(STR0057) // "Solicitar Assinatura"
	oBtApoAb:cTitle	:= ""
	
Return

/*/{Protheus.doc} ButtonsWhen
Controla quando os botões estarão ativos na tela
@type  Static Function
@author Cícero Alves
@since 02/03/2022
@param oView, Objeto, Instância da classe FWFormView
/*/
Static Function ButtonsWhen(oView)
	
	Local oModel		:= oView:GetModel()
	Local oModelGrid 	:= oModel:GetModel("PONA450_TAE")
	
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		lWenBtn := If(oModelGrid:GetValue("RS4_STATUS") == "2", .T., .F.)
		oView:Refresh("VIEW_BUTTONBAR")
		oView:Refresh("PONA450_SRA")
	Else
		lWenBtn := .F.
	EndIf
	
Return .T.

/*/{Protheus.doc} fSendMail
Envia email para os assinates pendentes do documento posicionado no grid
@type  Static Function
@author Cícero Alves
@since 02/03/2022
/*/
Static Function fSendMail()
	
	Local oModel 	:= FWModelActivate()
	Local oGrid		:= oModel:GetModel("PONA450_TAE")
	Local oClient	:= Nil
	Local cPath 	:= "identityintegration/api/auth/login"
	Local cSignURL	:= SuperGetMV("MV_SIGNURL",, "")
	Local cUser     := AllTrim(GetMv('MV_RHTAEUS', , ""))
	Local cPassword := AllTrim(GetMv('MV_RHTAEPW', , ""))
	Local cBody		:= ""
	Local aHeader	:= {}
	Local oJson     := JsonObject():New()
	Local cToken	:= ""
	Local lOk		:= .T.
	
	If oSign == Nil
		SetUpSign(@oSign)
	EndIf
	
	lOk := oSign:documentStatus( oGrid:GetValue("RS4_ID"))
	jResponse := oSign:getResponse()
	
	If lOk .And. jResponse["data"]["status"] == 0
		
		// Faz a autenticação no TAE
		cUser := rc4crypt( cUser, "123456789", .F., .T.)
		cPassword := rc4crypt( cPassword, "123456789", .F., .T.)
		
		Aadd(aHeader, "Accept: application/json")
		Aadd(aHeader, "Content-Type: application/json")
		
		cBody := '{'
		cBody += '"userName":"' + cUser + '",'
		cBody += '"password":"' + cPassword + '"'
		cBody += '}'
		
		oClient := FwRest():New(cSignURL)
		oClient:SetPath(cPath)
		oClient:SetPostParams(cBody)
		
		If oClient:Post(aHeader)
		
			cRet := oClient:GetResult()
			oJson:fromJson(cRet)
			
			cToken := oJson["data"]["token"]
			
			// Reenvia o email
			cPath := "signintegration/v2/Publicacoes/reenvia-email-pendentes"
			cBody := '{"listaDocumentos": [' + cValToChar(oGrid:GetValue("RS4_ID")) + ']}'
			Aadd(aHeader, "Authorization: Bearer " + cToken)
			oClient:SetPath(cPath)
			oClient:SetPostParams(cBody)
			
			If oClient:Post(aHeader)
				MsgInfo(STR0056, "OK") // "e-mail enviado com sucesso"
			EndIf
			
		EndIf
	Else
		Help( ,, STR0003,, STR0054, 1,,,,,,, {STR0055} ) // "O e-mail não pode ser enviado" - "O e-mail é enviado apenas para documentos com o Status 'Pendente'"
		fAtuStatus(.F.)
	EndIf
	
Return

/*/{Protheus.doc} fDownload
Realiza o download do arquivo posicionado no grid
@type  Static Function
@author Cícero Alves
@since 03/03/2022
/*/
Static Function fDownload()
	
	Local oModel 	:= FWModelActivate()
	Local oGrid		:= oModel:GetModel("PONA450_TAE")
	Local cPath		:= ""
	
	If oSign == Nil
		SetUpSign(@oSign)
	EndIf
	
	cPath := cGetFile("PDF|*.pdf", STR0051, 0, , .F., GETF_LOCALHARD + GETF_RETDIRECTORY,,) //"Selecione o Diretorio"
	
	If !Empty(cPath) .And. oSign:downloadDocument(oGrid:GetValue("RS4_ID"), cPath, "1")
		MsgInfo(STR0053 + AllTrim(oGrid:GetValue("RS4_NDOC")) + " " + STR0052, "") //"Arquivo " - "salvo com sucesso"
	EndIf
	
Return

/*/{Protheus.doc} fAtuStatus
Verifica o status do documento posicionado no grid e atualiza a tabela RS4
@type  Static Function
@author Cícero Alves
@since 03/03/2022
@param lShowMsg, Lógico, define se irá apresentar a mensagem ao término do processamento
/*/
Static Function fAtuStatus(lShowMsg)
	
	Local oModel 	:= FWModelActivate()
	Local oGrid		:= oModel:GetModel("PONA450_TAE")
	Local oView		:= FWViewActive()
	Local cStatus	:= ""
	local lOk		
	
	Default lShowMsg := .T.
	
	If oSign == Nil
		SetUpSign(@oSign)
	EndIf
	
	lOk := oSign:documentStatus( oGrid:GetValue("RS4_ID"))
	jResponse := oSign:getResponse()
	
	If lOk .And. jResponse["data"]["status"] == 2 // Finalizado
		cStatus := "1"
	ElseIf lOk .And. jResponse["data"]["status"] == 4 // Rejeitado
		cStatus := "3"
	EndIf
	
	If !Empty(cStatus)
		oGrid:SetValue("RS4_STATUS", cStatus)
		
		dbSelectArea("RS4")
		RS4->(dbSetOrder(1))
		RS4->(dbSeek(xFilial("RS4", SRA->RA_FILIAL) + SRA->RA_MAT + dTos(oGrid:GetValue("RS4_DATAI")) + DToS(oGrid:GetValue("RS4_DATAF"))))
		
		RecLock("RS4", .F.)
		RS4->RS4_STATUS := cStatus
		MsUnLock()
		
		ButtonsWhen(oView)
		
		oView:Refresh("PONA450_TAE")
	EndIf
	
	If lShowMsg
		MsgInfo(STR0050, "OK") // Registro atualizado
	EndIf
	
Return

/*/{Protheus.doc} fTAEStatus
Verifica o status dos documentos no TAE, atualiza a tabela RS4 e apresenta um log
@type  Function
@author Cícero Alves
@since 03/03/2022
/*/
Function fTAEStatus()
	
	DEFAULT lIntTAE := ChkFile("RS4") .And. RS4->(ColumnPos("RS4_TPDOC")) > 0 .And. FindFunction("FwTotvsSign")
	
	If !lIntTAE
		//"Funcionalidade não disponível para esta versão do sistema."
		Help( ,, "HELP",, STR0067, 1,,,,,,, {STR0068}) // "Para utilizar a integração com o Totvs Assinatura Eletrônica é necessário atualizar o sistema."
		Return
	EndIf
	
	If oSign == Nil
		SetUpSign(@oSign)
	EndIf
	
	MsAguarde( {|| fStatusTAE()}, STR0048, STR0049, .F.) // "Aguarde" - "Atualizando status dos documentos"
	
Return

/*/{Protheus.doc} fStatusTAE
Verifica o status dos documentos no TAE, atualiza a tabela RS4 e apresenta um log
@type Static Function
@author Cícero Alves
@since 03/03/2022
/*/
Static Function fStatusTAE()
	
	Local cAliasRS4	:= GetNextAlias()
	Local cWhere	:= "%%"
	Local nStatus	:= 0
	Local aLogTAE	:= {{},{},{}}
	Local aLogTitle := {"", "", ""}
	
	If !Empty(dFimFil)
		cWhere := "% AND RS4.RS4_DATAI BETWEEN '" + dTos(dIniFil) +"' AND '" + dToS(dFimFil) + "'%"
	EndIf
	
	BeginSQL Alias cAliasRS4
		SELECT RS4.RS4_FILIAL, RS4.RS4_MAT, RS4.RS4_NDOC, RS4.RS4_ID, RS4.R_E_C_N_O_ AS RECNO 
		FROM %Table:RS4% RS4
		WHERE RS4.RS4_TPDOC = '1'
		AND RS4.RS4_STATUS = '2'
		AND RS4.%NotDel%
		%Exp:cWhere%
	EndSQL
	
	dbSelectArea("RS4")
	
	While (cAliasRS4)->(!Eof())
		If !Empty((cAliasRS4)->RS4_ID)
			If oSign:documentStatus((cAliasRS4)->RS4_ID)
				jResponse := oSign:getResponse()
				nStatus := jResponse["data"]["status"]
				
				Do Case
					Case nStatus == 0
						aAdd(aLogTAE[1], (cAliasRS4)->RS4_FILIAL + " - " + (cAliasRS4)->RS4_MAT + ": " + (cAliasRS4)->RS4_NDOC)
						If Empty(aLogTitle[1])
							aLogTitle[1] := STR0047 // "Documentos pendentes de assinatura"
						EndIf
					Case nStatus == 2
						RS4->(dbGoTo((cAliasRS4)->RECNO))
						RecLock("RS4", .F.)
						RS4->RS4_STATUS := "1"
						MsUnLock()
						
						aAdd(aLogTAE[2], (cAliasRS4)->RS4_FILIAL + " - " + (cAliasRS4)->RS4_MAT + ": " + (cAliasRS4)->RS4_NDOC)
						If Empty(aLogTitle[2])
							aLogTitle[2] := STR0046 // "Documentos assinados"
						EndIf
						
					Case nStatus == 4
						RS4->(dbGoTo((cAliasRS4)->RECNO))
						RecLock("RS4", .F.)
						RS4->RS4_STATUS := "3"
						MsUnLock()
						
						aAdd(aLogTAE[3], (cAliasRS4)->RS4_FILIAL + " - " + (cAliasRS4)->RS4_MAT + ": " + (cAliasRS4)->RS4_NDOC)
						If Empty(aLogTitle[3])
							aLogTitle[3] := STR0045 // "Documentos rejeitados"
						EndIf
				EndCase
			EndIf
		EndIf
		
		(cAliasRS4)->(dbSkip())
	EndDo
	
	(cAliasRS4)->(DbCloseArea())
	
	fMakeLog( aLogTAE, aLogTitle,,, "PONA450", STR0044) // "Log de ocorrências na integração com TAE"
	
Return

/*/{Protheus.doc} fDelDocTAE
Valida se é possível e realiza a exclusão do documento no TAE 
@type  Static Function
@author Cícero Alves
@since 03/03/2022
@return lRet, Lógico, Indica se foi feita a exclusão do registro
/*/
Static Function fDelDocTAE(lModelCall)
	
	Local oModel 	:= FWModelActivate()
	Local oGrid		:= oModel:GetModel("PONA450_TAE")
	Local oView		:= FWViewActive()
	Local lRet		:= .T.
	Local lOk
	
	Default lModelCall := .F.
	
	If oSign == Nil
		SetUpSign(@oSign)
	EndIf
	
	lOk := oSign:documentStatus( oGrid:GetValue("RS4_ID"))
	jResponse := oSign:getResponse()
	
	If lOk .And. jResponse["data"]["status"] == 0 // Documento pendente de assinatura
		
		// "O documento também será excluído do Totvs assinatura eletrônica."
		// "Essa ação não poderá ser desfeita."
		// "Deseja continuar?"
		If lRet := MsgYesNo(STR0041 + CRLF + STR0042 + CRLF + STR0043, STR0003)
			
			If oSign:deleteDocument(oGrid:GetValue("RS4_ID"))
				
				//oGrid:DeleteLine()
				dbSelectArea("RS4")
				RS4->(dbSetOrder(1))
				RS4->(dbSeek(xFilial("RS4", SRA->RA_FILIAL) + SRA->RA_MAT + dTos(oGrid:GetValue("RS4_DATAI")) + DToS(oGrid:GetValue("RS4_DATAF"))))
				
				RecLock("RS4",.F.)
				dbDelete()
				MsUnLock()
				
				ButtonsWhen(oView)
				
				oView:Refresh("PONA450_TAE")
				
			EndIf
		ElseIf lModelCall
			Help( ,, STR0003,, STR0039, 1,,,,,,, {} ) // "O documento não foi excluído"
		EndIf
	Else
		//"O documento não foi excluído" - "Apenas documentos com o Status 'Pendente' podem ser excluídos"
		Help( ,, STR0003,, STR0039, 1,,,,,,, {STR0040} )
		fAtuStatus(.F.)
		lRet := .F.
	EndIf
	
Return lRet
