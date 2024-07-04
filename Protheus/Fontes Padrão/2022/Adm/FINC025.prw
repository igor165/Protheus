#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FINC025.CH"

Static lComp     := .F. // Variavel para controle de comparação de fluxos
Static mv_par01  := ""
Static mv_par02  := .F. 
Static mv_par03  := ""
Static bLoadGrd3 := {}
Static _oFINC025a
Static __AuxLoad := {}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FINC025	³ Ronaldo Tapia                    ³ Data ³ 13/06/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Fluxo de Caixa - Consulta gravada 	  			           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FINC025()												  			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	 ³ Financeiro 												  	    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FINC025()

Private oBrowse

If GetRpoRelease() >= "12.1.033" .and. FindFunction("MsgExpRot")
	MsgExpRot("FINC025",;
				STR0036,; //"Novo gestor financeiro FINA710" 
				"https://tdn.totvs.com/pages/viewpage.action?pageId=611007335", "20220820" ) 
	if Date() >= CTOD("20/08/2022")
		MsgAlert(STR0037, STR0038) //"Rotina descontinuada" # "Alerta"
		Return
	Endif			
EndIf

If !ChkFile("FLZ")
	Return .F.
EndIf

//Iniciamos a construção básica de um Browse.
oBrowse := FWMBrowse():New()

//Definimos a tabela que será exibida na Browse utilizando o método SetAlias
oBrowse:SetAlias("FLZ")

//Definimos o título que será exibido como método SetDescription
oBrowse:SetDescription(STR0001) //"Histórico de Fluxo de Caixa"

//Ativamos a classe
oBrowse:Activate()

Return


//------------------------------------------------------------------------------------------
/* {Protheus.doc} MenuDef
Utilizacao de menu Funcional 

@author    Ronaldo Tapia
@version   11.80
@since     13/06/2016
@protected
*/
//------------------------------------------------------------------------------------------

Static Function MenuDef()

Local aRotina := {}
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.FINC025' OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FINC025' OPERATION 5 ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE STR0005 ACTION 'Fc025Comp' OPERATION 2 ACCESS 0 //"Comparar"

Return(aRotina)


//------------------------------------------------------------------------------------------
/* {Protheus.doc} ModelDef
Visualiza o fluxo de caixa 

@author    Ronaldo Tapia
@version   11.80
@since     14/06/2016
@protected
*/
//------------------------------------------------------------------------------------------

Static Function ModelDef()

// Cria as estruturas a serem usadas no Modelo de Dados
Local oStruFLZ  := FWFormStruct(1, 'FLZ')
Local oStruFLW1 := FWFormStruct(1, 'FLW')
Local oStruFLW2 := FWFormStruct(1, 'FLW')
Local oModel    := Nil
Local nQtdPer   := cValtoChar(FLZ->FLZ_QTDPER)
Local nPeriodo  := FLZ->FLZ_PERIOD // Periodicidade
Local cTipoPer  := "" // Tipo de periodicidade
// Carrega primeiro fluxo para comparacao
Local bLoad1    := {|oGridModel1, lCopy1| loadGrid1(oGridModel1, lCopy1, mv_par01)} // Fluxo 1
Local bLoad2    := {|oGridModel2, lCopy2| loadGrid2(oGridModel2, lCopy2, mv_par03)} // Fluxo 2 - A definir
Local bLoad3    := {|oGridModel3, lCopy3| bLoadGrd3} // Fluxo 2 - Realizado


// Verifica o tipo de periodicidade
Do Case
	Case nPeriodo == 1  
		cTipoPer := STR0006 //Diario
	Case nPeriodo == 7  
		cTipoPer := STR0007 //Semanal
	Case nPeriodo == 10 
		cTipoPer := STR0008 //Decendial
	Case nPeriodo == 15 
		cTipoPer := STR0009 //Quinzenal
	Case nPeriodo == 30 
		cTipoPer := STR0010 //Mensal
EndCase

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('FINC025')

If lComp
	// Adiciona ao modelo um componente de formulário
	oModel:AddFields( 'FLZMASTER', /*cOwner*/, oStruFLZ )
	
	//Adiciona ao modelo um componente de grid
	oModel:AddGrid( 'FLWDETAIL1', 'FLZMASTER', oStruFLW1,,,,,bLoad1)
	If !mv_par02
		oModel:AddGrid( 'FLWDETAIL2', 'FLZMASTER', oStruFLW2,,,,,bLoad2) // Fluxo a definir
	Else
		oModel:AddGrid( 'FLWDETAIL2', 'FLZMASTER', oStruFLW2,,,,,bLoad3) // Fluxo realizado
	EndIf
	
	//Criação de relação entre as entidades do modelo (SetRelation)
	oModel:SetRelation( 'FLWDETAIL1', { { 'FLW_FILIAL', 'xFilial( "FLW" )' }, { 'FLW_CODIGO' , 'FLZ_CODIGO'  } } , FLW->( IndexKey( 1 ) )  )
	
	//Criação de relação entre as entidades do modelo (SetRelation)
	oModel:SetRelation( 'FLWDETAIL2', { { 'FLW_FILIAL', 'xFilial( "FLW" )' }, { 'FLW_CODIGO' , 'FLW_CODIGO'  } } , FLW->( IndexKey( 1 ) )  )
		
	// Adiciona a descrição do Modelo de Dados
	oModel:SetDescription( 'Histórico de Fluxo de Caixa' )

	// Adiciona a descrição dos Componentes do Modelo de Dados
	oModel:GetModel( 'FLZMASTER' ):SetDescription(STR0001) //"Histórico de Fluxo de Caixa"
	FLZ->(MsSeek(xFilial("FLZ")+mv_par01)) // Posiciona no registro correto
	oModel:GetModel( 'FLWDETAIL1' ):SetDescription( STR0011+DTOC(FLZ->FLZ_DATA)+' - '+FLZ->FLZ_HORA+' - '+cTipoPer+STR0012+nQtdPer+STR0013) //'Fluxo de Caixa: ' //' - Qtd. Per: ' //"dias"
	If !mv_par02
		FLZ->(MsSeek(xFilial("FLZ")+mv_par03)) // Posiciona no registro correto
		oModel:GetModel( 'FLWDETAIL2' ):SetDescription(STR0011+DTOC(FLZ->FLZ_DATA)+' - '+FLZ->FLZ_HORA) //"Fluxo de Caixa: "
	Else
		oModel:GetModel( 'FLWDETAIL2' ):SetDescription(STR0014) //"Fluxo de caixa realizado no período"
	EndIf
	
	//Define uma chave primaria (obrigatorio mesmo que vazia)	
	oModel:SetPrimaryKey( {} )
Else
	// Adiciona ao modelo um componente de formulário
	oModel:AddFields( 'FLZMASTER', /*cOwner*/, oStruFLZ )
	
	//Adiciona ao modelo um componente de grid
	oModel:AddGrid( 'FLWDETAIL', 'FLZMASTER', oStruFLW1 )
	
	//Criação de relação entre as entidades do modelo (SetRelation)
	oModel:SetRelation( 'FLWDETAIL', { { 'FLW_FILIAL', 'xFilial( "FLW" )' }, { 'FLW_CODIGO' , 'FLZ_CODIGO'  } } , FLW->( IndexKey( 1 ) )  )
	
	// Adiciona a descrição do Modelo de Dados
	oModel:SetDescription( STR0001 ) //"Histórico de Fluxo de Caixa"
	
	// Adiciona a descrição dos Componentes do Modelo de Dados
	oModel:GetModel( 'FLZMASTER' ):SetDescription( STR0015 ) //"Fluxo de Caixa"
	oModel:GetModel( 'FLWDETAIL' ):SetDescription( STR0001 ) //"Histórico de Fluxo de Caixa"
	
	//Define uma chave primaria (obrigatorio mesmo que vazia)	
	oModel:SetPrimaryKey( {} )

EndIf

Return oModel


//------------------------------------------------------------------------------------------
/* {Protheus.doc} ViewDef
Visualiza o fluxo de caixa 

@author    FLWaldo Tapia
@version   11.80
@since     14/06/2016
@protected
*/
//------------------------------------------------------------------------------------------

Static Function ViewDef()

// Cria as estruturas a serem usadas na View
Local oStruFLZ  := FWFormStruct(2, 'FLZ')
Local oStruFLW1 := FWFormStruct(2, 'FLW')
Local oStruFLW2 := FWFormStruct(2, 'FLW')
Local oModel    := FWLoadModel( 'FINC025' )

// Interface de visualização construída
Local oView  := Nil

//Remove os campos que não irão aparecer na grid
oStruFLW1:RemoveField( 'FLW_FILIAL' )
oStruFLW1:RemoveField( 'FLW_CODIGO' )
oStruFLW1:RemoveField( 'FLW_FOLDER' )
oStruFLW2:RemoveField( 'FLW_FILIAL' )
oStruFLW2:RemoveField( 'FLW_CODIGO' )
oStruFLZ:RemoveField( 'FLZ_FILIAL' )
oStruFLZ:RemoveField( 'FLZ_CODIGO' )
oStruFLZ:RemoveField( 'FLZ_CODUSR' )
oStruFLZ:RemoveField( 'FLZ_NOMUSR' )

// Cria o objeto de View
oView := FWFormView():New()

// Adiciona botões
oView:AddUserButton( "Imprimir Fluxos", 'IMPRIMIR', {|oView| FC25Imp(oView) } )	 // "Imprimir Fluxo"

// Define qual Modelo de dados será utilizado
oView:SetModel( oModel )
		
If lComp
	//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oView:AddGrid( 'VIEW_FLW1', oStruFLW1, 'FLWDETAIL1' )
	oView:AddGrid( 'VIEW_FLW2', oStruFLW2, 'FLWDETAIL2' )
	
	// Cria um "box" vertical para receber cada elemento da view
	oView:CreateHorizontalBox( 'INFERIOR', 100 )
	oView:CreateVerticalBox( 'LEFT', 50, 'INFERIOR' )
	oView:CreateVerticalBox( 'RIGHT', 50, 'INFERIOR' )
		
	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_FLW1', 'LEFT' )
	oView:SetOwnerView( 'VIEW_FLW2', 'RIGHT' )
	
	// Liga a identificacao do componente
	oView:EnableTitleView( 'VIEW_FLW1' )
	oView:EnableTitleView( 'VIEW_FLW2' )
Else
	// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
	oView:AddField( 'VIEW_FLZ', oStruFLZ, 'FLZMASTER' )
	
	//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oView:AddGrid( 'VIEW_FLW', oStruFLW1, 'FLWDETAIL' )
	
	// Cria um "box" horizontal para receber cada elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 15 )
	oView:CreateHorizontalBox( 'INFERIOR', 85 )
		
	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_FLZ', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_FLW', 'INFERIOR' )
	
	// Liga a identificacao do componente
	oView:EnableTitleView( 'VIEW_FLZ' )
	oView:EnableTitleView( 'VIEW_FLW' )
EndIf

// Volta variavel de controle de comparacao de fluxo
lComp     := .F.

Return oView

//------------------------------------------------------------------------------------------
/* {Protheus.doc} loadGrid1
Carrega o bloco de carga dos dados do submodelo 1

@author    Ronaldo Tapia
@version   11.80
@since     20/06/2016
@protected
*/
//------------------------------------------------------------------------------------------

Static Function loadGrid1(oGridModel1, lCopy1, mv_par01)
Local aLoad1 := {}

If !Empty(mv_par01) .And. !Empty(mv_par03)
	//Posiciona no registro correspondente do alias FLW
	FLW->(dbgotop())
	FLW->(MsSeek(xFilial("FLW")+mv_par01))
		
	While FLW->FLW_CODIGO == mv_par01
		aAdd(aLoad1,{0,{xFilial("FLW"), FLW->FLW_CODIGO, FLW->FLW_DATA, FLW->FLW_ENTRAD, FLW->FLW_SAIDA}})
		FLW->( dbSkip() )
	EndDo	
EndIf

Return aLoad1

//------------------------------------------------------------------------------------------
/* {Protheus.doc} loadGrid2
Carrega o bloco de carga dos dados do submodelo 2

@author    Ronaldo Tapia
@version   11.80
@since     20/06/2016
@protected
*/
//------------------------------------------------------------------------------------------

Static Function loadGrid2(oGridModel2, lCopy2, mv_par03)
Local aLoad2 := {}

If !Empty(mv_par01) .And. !Empty(mv_par03)
	//Posiciona no registro correspondente do alias FLW
	FLW->(dbgotop())
	FLW->(MsSeek(xFilial("FLW")+mv_par03))
	
	While FLW->FLW_CODIGO == mv_par03
		aAdd(aLoad2,{0,{xFilial("FLW"), FLW->FLW_CODIGO, FLW->FLW_DATA, FLW->FLW_ENTRAD, FLW->FLW_SAIDA}})
		FLW->( dbSkip() )
	EndDo
EndIf	

// Zera variaveis dos parametros
If Empty(mv_par01)
	mv_par01  := ""
	mv_par02  := .F.
	mv_par03  := ""
EndIf

Return aLoad2

//------------------------------------------------------------------------------------------
/* {Protheus.doc} Fc100Comp
Compara os fluxos de caixa

@author    Ronaldo Tapia
@version   11.80
@since     14/06/2016
@protected
*/
//------------------------------------------------------------------------------------------

Function Fc025Comp()

Local cCodFLZ		:= FLZ->FLZ_CODIGO
Local aParam	   := {}
Local cTitulo    := STR0016 //Comparar fluxos
Local cPrograma  := 'FINC025'
Local nOperation := MODEL_OPERATION_VIEW
Local lRet		   := .T.
Local nPeriod1   := 1
Local nPeriod2   := 1
Local dData1     := STOD("")
Local dData2	   := STOD("")
Local cQtdPer1   := 1
Local cQtdPer2   := 1
Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"

lOk :=  ParamBox( {	{ 1, STR0015		    , cCodFLZ ,"@!",'ExistCpo("FLZ",mv_par01)',"FLZ",".T.",60, .T.},; //"Fluxo de Caixa"
					{ 5, STR0017, .F., 160, ,.T.},; //"Comparar com o Realizado?"
				 	{ 1, STR0018    , cCodFLZ ,"@!",'ExistCpo("FLZ",mv_par03)',"FLZ","!mv_par02",60,.T.} },STR0019,aParam,,,,,,,FunName(),.F.,.T.) //"Comparar com o Fluxo"###"Fluxo de Caixa - Parâmetros de comparação"

If 	Len(aParam) > 0	
	mv_par01 := aParam[1]
	mv_par02 := aParam[2]
	mv_par03 := aParam[3]
Endif

If lOk	

	If !Empty(mv_par03)
		lComp := .T.
	EndIf
	
	// Posiciona no registro correspondente da FLZ (mv_par01)
	FLZ->(MsSeek(xFilial("FLZ")+mv_par01))
	nPeriod1 := FLZ->FLZ_PERIOD
	dData1	  := FLZ->FLZ_DATA
	cQtdPer1 := FLZ->FLZ_QTDPER
	
	// Posiciona no registro correspondente da FLZ (mv_par03)
	FLZ->(MsSeek(xFilial("FLZ")+mv_par03))
	nPeriod2 := FLZ->FLZ_PERIOD
	dData2	  := FLZ->FLZ_DATA
	cQtdPer2 := FLZ->FLZ_QTDPER
	
	// Validações
	If nPeriod1 <> nPeriod2 .And. !mv_par02
		IW_MsgBox(STR0021,STR0020, "STOP" )//"Periodicidades diferentes na comparação, verificar os parâmetros!" //"Atenção"
		lRet := .F.
	EndIf
	
	If dData1 <> dData2 .And. !mv_par02 .And. lRet
		IW_MsgBox(STR0022,STR0020, "STOP" )//"Períodos diferentes na comparação, verificar os parâmetros!" //"Atenção"
		lRet := .F.
	EndIf
	
	If dData1 == dData2 .And. cQtdPer1 <> cQtdPer2 .And. !mv_par02 .And. lRet
		IW_MsgBox(STR0023,STR0020, "STOP" ) //"Quantidade de períodos diferentes na comparação, verificar os parâmetros!" //"Atenção"
		lRet := .F.
	EndIf
	
	// Busca o fluxo de caixa realizado
	If mv_par02 // Comparar com o realizado
		MsgRun(STR0024,, { || lRet := Fc025Real() }  ) //"Aguarde, realizando a consulta do fluxo de caixa realizado"
	EndIf
	
	If lRet
		// Chama a view da tabela
		FWExecView(cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, aEnableButtons, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, /*oModel*/ )
	EndIf
EndIf

Return

//------------------------------------------------------------------------------------------
/* {Protheus.doc} Fc025Real
Busca o fluxo de caixa realizado

@author    Ronaldo Tapia
@version   11.80
@since     20/06/2016
@protected
*/
//------------------------------------------------------------------------------------------

Function Fc025Real()

Local dDataAnt
Local aCampos		:= { {"DATAX      ","D",8 ,0},{"RECEBIDOS ","N",17,2},{"PAGOS     ","N",17,2} }
Local nPagos		:= 0
Local nRecebidos	:= 0
Local nMoedaBco		:= 1
Local nMoeda		:= 1
Local nDecs			:= MsDecimais(nMoeda)	
Local aStru 		:= SE5->(dbStruct())
Local nI			:= 0	
Local cOrder
Local lRet		   	:= .T.
Local nDias	   		:= 0
Local nQtdPer    	:= 1
Local nPeriod    	:= 1		
Local cArqTmp    	:= ""

//Limpa o codeblock bLoadGrd3 
If Len(bLoadGrd3) > 0
	aSize(bLoadGrd3,0)
EndIf

//----------------------------
//Criação da tabela temporaria
//----------------------------
If _oFINC025a <> Nil
	_oFINC025a:Delete()
	_oFINC025a := Nil
Endif

_oFINC025a := FWTemporaryTable():New( "cArqTmp" )  
_oFINC025a:SetFields(aCampos) 	

//Adiciono o índice da tabela temporária
_oFINC025a:AddIndex("1",{"DATAX"})				

_oFINC025a:Create()	
	
If !Empty(mv_par01)
	//Posiciona no registro correspondente do alias FLZ e FLW
	FLZ->(dbgotop())
	FLZ->(MsSeek(xFilial("FLZ")+mv_par01))
	FLW->(dbgotop())
	FLW->(MsSeek(xFilial("FLW")+mv_par01))
EndIf

nQtdPer := FLZ->FLZ_QTDPER
nPeriod := FLZ->FLZ_PERIOD

// Preenche o temporario com todas as datas gravadas no fluxo referente ao mv_par01
While FLW->FLW_CODIGO == mv_par01
	RecLock( "cArqTmp", .T. )
	REPLACE DATAX		WITH	FLW->FLW_DATA
	REPLACE RECEBIDOS 	WITH	0
	REPLACE PAGOS		WITH	0
	msUnlock()
	FLW->( dbSkip() )
Enddo

// Busca a menor e maior data na FLW
cQuery2 := "SELECT MIN(FLW_DATA) datamenor, MAX(FLW_DATA) datamaior"
cQuery2 += " FROM " + RetSqlName("FLW")
cQuery2 += " WHERE FLW_FILIAL = '" + xFilial("FLW") + "' "
cQuery2 += " AND FLW_CODIGO = '" + mv_par01 + "' "

cQuery2 := ChangeQuery(cQuery2)

// Verifica area aberta
If Select("FLW2") <> 0
	FLW2->(dbCloseArea())
EndIf
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery2), 'FLW2', .T., .T.)

// Data menor e maior do fluxo salvo
dDataMin := datamenor
dDataMax := datamaior

// Seleciona os movimentos do periodo na SE5
cOrder := "E5_FILIAL,E5_DTDISPO,E5_BANCO,E5_AGENCIA,E5_CONTA,E5_NUMCHEQ"

cQuery := "SELECT * "
cQuery += " FROM " + RetSqlName("SE5")
cQuery += " WHERE E5_FILIAL = '" + xFilial("SE5") + "' "
cQuery += " AND E5_DTDISPO BETWEEN '" + dDataMin  + "' AND '" + dDataMax  + "'
cQuery += " AND E5_MOTBX <> 'FAT' "		
cQuery += " AND D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY " + cOrder
cQuery := ChangeQuery(cQuery)

dbSelectArea("SE5")
dbCloseArea()

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE5', .T., .T.)

//Altera o tratamento para um campo/coluna retornada através da query
For nI := 1 to Len(aStru)
	If aStru[nI,2] != 'C'
		TCSetField('SE5', aStru[nI,1], aStru[nI,2],aStru[nI,3],aStru[nI,4])
	Endif
Next

dDataAnt := SE5->E5_DTDISPO
//Grava as movimentacoes do E5 no temporario
While ! SE5->( eof()) .And. SE5->E5_DTDISPO <= dDataBase .And. xFilial("SE5") == SE5->E5_FILIAL

	If xFilial("SE5") <> SE5->E5_FILIAL
		dbSkip()
		Loop
	Endif	
	dbSelectArea("SE5")

	//Grava as movimentacoes do E5 no temporario.   
	If SA6->(dbSeek(xFilial()+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA))
		If SA6->A6_FLUXCAI == "N"
			SE5->( dbSkip() )
			Loop
		Endif
	Endif

	If !Empty(SE5->E5_MOTBX) .And.  !(SE5->E5_TIPODOC$MVPAGANT+"|ES")
		If !MovBcoBx(SE5->E5_MOTBX)
			SE5->( dbSkip() )
			Loop
		EndIf
	Endif

	dbSelectArea("SE5")

	//Verifica se existe estorno para esta baixa                       
	If !Empty(SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO)) .or. SE5->E5_SITUACA =="C"
		If SE5->E5_SITUACA =="C" .Or. TemBxCanc(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ)
			SE5->(dbSkip())
			Loop
		EndIf
	EndIf

	//Verifica se é a titulo a receber ou a pagar e se não vai para o fluxo
	If !Empty(SE5->E5_NUMERO)
		If SE5->E5_RECPAG == "R"
			If SE1->( dbSeek(xFilial()+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO) )
				If SE1->E1_FLUXO == "N"
					SE5->( dbSkip() )
					Loop
				Endif
			Endif
		Else
			dbSelectArea("SE2")
			If SE2->( dbSeek(xFilial()+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIFOR) )
				If SE2->E2_FLUXO == "N"
					SE5->( dbSkip() )
					Loop
				Endif			
			Endif
		Endif
	Endif

	//Soma as movimentacoes diarias					  
	IF (!(SE5->E5_TIPODOC $ "CH/DC/JR/MT/CM/D2/J2/M2/C2/V2/CP/TL/BL/EC/ES"+Iif(cPaisLoc == "BOL","/BA","")) .Or. ;
		(SE5->E5_TIPODOC == "ES" .AND. !EMPTY(SE5->E5_KEY)) ) 	.and. ; //Estorno de PA/RA	OU titulos deletados	
		!(Empty(SE5->E5_TIPODOC) .AND. Empty(SE5->E5_MOEDA)).Or.; // Totalizador Bx Cnab
		(Empty(SE5->E5_TIPODOC) .AND. !Empty(SE5->E5_MOEDA))
		If SE5->E5_RECPAG == "R"
			nRecebidos  += xMoeda(SE5->E5_VALOR,nMoedaBco,nMoeda,SE5->E5_DATA,nDecs+1)
		Else
			nPagos      += xMoeda(SE5->E5_VALOR,nMoedaBco,nMoeda,SE5->E5_DATA,nDecs+1)
		EndIf
	EndIf
	

	dbSelectArea("SE5")
	SE5->( dbSkip() )
	//Grava os registros no temporario.				  
	If SE5->E5_DTDISPO != dDataAnt 
		If ( nRecebidos != 0 .Or. nPagos != 0 )
			// Posiciona no registro correto
			If nPeriod <> 1
				// Verifica se data esta entre o periodo selecionado
				dDataAnt := Fc025Perid(cArqTmp,nQtdPer,nPeriod,dDataAnt)
			EndIf
					
			cArqTmp->(dbGoTop())
			cArqTmp->(dbSetOrder(1)) 
			cArqTmp->(dbSeek(dDataAnt))	
			
			// Atualiza registro	
			RecLock( "cArqTmp", .F. )
			REPLACE DATAX		WITH	dDataAnt
			REPLACE RECEBIDOS	WITH	nRecebidos
			REPLACE PAGOS		WITH	nPagos
			msUnlock()
		Endif
		dDataAnt 	:= SE5->E5_DTDISPO
		nRecebidos	:= 0
		nPagos		:= 0
	EndIf
	dbSelectArea("SE5")

EndDo

// Verifica quantos dias estao sendo tratados pela peridiocidade e quantidade de periodos
nDias := nQtdPer*nPeriod

If SE5->E5_DTDISPO > dDataBase
	IW_MsgBox(STR0026, STR0020, "ALERT" )//"Data base é menor que o período selecionado para comparação!" //"Atenção"
	lRet := .F.
EndIf	

// Grava os valores do temporario no codeblock bLoadGrd3
cArqTmp->(dbGoTop())
While !cArqTmp->(eof())
	aAdd(bLoadGrd3,{0,{xFilial("SE5"), "9999999999", cArqTmp->DATAX, cArqTmp->RECEBIDOS, cArqTmp->PAGOS}})
	cArqTmp->(dbSkip())
Enddo

If Len(bLoadGrd3) > 0
	__AuxLoad := aClone(bLoadGrd3)
Else
	__AuxLoad := {}
EndIf

// Fecha e apaga o arquivo temporario
cArqTmp->(dbCloseArea()) 

//Deleta tabela temporária do banco de dados
If _oFINC025a <> Nil
	_oFINC025a:Delete()
	_oFINC025a := Nil
Endif

Return lRet

//------------------------------------------------------------------------------------------
/* {Protheus.doc} Fc025Perid
Verifica se a data do movimento esta dentro da periodicidade do fluxo de caixa

@author    Ronaldo Tapia
@version   11.80
@since     22/06/2016
@protected
*/
//------------------------------------------------------------------------------------------

Function Fc025Perid(cArqTmp,nQtdPer,nPeriod,dDataAnt)

Local lRet := .F.
Local dSemaAnt := STOD("")
Local dDataRet := STOD("")

Default dDataAnt := STOD("")

cArqTmp->(dbGoTop())

// Varre todo o temporario para analisar o periodo
While !cArqTmp->(eof()) .And. !lRet
	dSemaAnt := cArqTmp->DATAX
	// Se data da pesquisa for maior que data anterior e menor que data anterior mais a periodicidade, salva a data de retorno
	If dDataAnt >= dSemaAnt .And. dDataAnt <= DaySum(cArqTmp->DATAX,nPeriod)
		dDataRet := cArqTmp->DATAX
		lRet := .T.
	EndIf
	cArqTmp->(dbSkip())
Enddo

Return(dDataRet)

//------------------------------------------------------------------------------------------
/* {Protheus.doc} FC25Imp
Imprime os fluxos

@author    Ronaldo Tapia
@version   20/07/2016
@protected
*/
//------------------------------------------------------------------------------------------

Function FC25Imp()

Local oReport := Nil	
Local cPerg:= "FC25Imp"

oReport := RptDef(cPerg)
oReport:PrintDialog()

Return

// Monta a estrutura das seções do relatório
Static Function RptDef(cNome)

Local oReport  := Nil
Local oSection1:= Nil
Local oSection2:= Nil
Local oSection3:= Nil
Local oSection4:= Nil
Local oSection5:= Nil

/*Sintaxe: TReport():New(cNome,cTitulo,cPerguntas,bBlocoCodigo,cDescricao)*/
oReport := TReport():New(cNome,STR0027,cNome,{|oReport| ReportPrint(oReport)},STR0028)//"Comparação de Fluxos" //"Comparação de Fluxo de Caixa"
oReport:SetPortrait()    
oReport:lParamPage := .F.

oSection1:= TRSection():New(oReport, "FLUXO1Cab", {"FLZ"}, , .F., .T.)
TRCell():New(oSection1,"DATA"			,"FLZ",STR0029,"@!",10,/*lPixel*/,/*{|| code-block de impressao }*/) //"Data"
TRCell():New(oSection1,"PERIODO"		,"FLZ",STR0030,PesqPict("FLZ","FLZ_PERIOD" ),TamSX3("FLZ_PERIOD" )[1],/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Periodicidade"
TRCell():New(oSection1,"QUANT"			,"FLZ",STR0031,PesqPict("FLZ","FLZ_QTDPER" ),TamSX3("FLZ_QTDPER" )[1],/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Quant. Períodos"

oSection2:= TRSection():New(oReport, "FLUXO1", {"TRB1"}, , .F., .T.)
TRCell():New(oSection2,"DATA"			,"TRB1",STR0029,"@!",10,/*lPixel*/,/*{|| code-block de impressao }*/) //"Data"
TRCell():New(oSection2,"ENTRADA"		,"TRB1",STR0032,PesqPict("FLW","FLW_ENTRAD" ),TamSX3("FLW_ENTRAD" )[1],/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor Entrada"
TRCell():New(oSection2,"SAIDA"			,"TRB1",STR0033,PesqPict("FLW","FLW_SAIDA" ),TamSX3("FLW_SAIDA" )[1],/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor Saída"

oSection3:= TRSection():New(oReport, "FLUXO2", {"TRB2"}, NIL, .F., .T.)
TRCell():New(oSection3,"DATA"			,"TRB2",STR0029,"@!",10,/*lPixel*/,/*{|| code-block de impressao }*/) //"Data"
TRCell():New(oSection3,"ENTRADA"		,"TRB2",STR0032,PesqPict("FLW","FLW_ENTRAD" ),TamSX3("FLW_ENTRAD" )[1],/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor Entrada"
TRCell():New(oSection3,"SAIDA"			,"TRB2",STR0033,PesqPict("FLW","FLW_SAIDA" ),TamSX3("FLW_SAIDA" )[1],/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor Saída"

oSection4:= TRSection():New(oReport, "FLUXO3Cab", {"TRB2"}, NIL, .F., .T.)
TRCell():New(oSection4,"FLUXO"			,"TRB4",STR0034,,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Fluxo Realizado"

oSection5:= TRSection():New(oReport, "FLUXO3", {"TRB3"}, NIL, .F., .T.)
TRCell():New(oSection5,"DATA"			,"TRB3",STR0029,"@!",10,/*lPixel*/,/*{|| code-block de impressao }*/) //"Data"
TRCell():New(oSection5,"ENTRADA"		,"TRB3",STR0032,PesqPict("FLW","FLW_ENTRAD" ),TamSX3("FLW_ENTRAD" )[1],/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor Entrada"
TRCell():New(oSection5,"SAIDA"			,"TRB3",STR0033,PesqPict("FLW","FLW_SAIDA" ),TamSX3("FLW_SAIDA" )[1],/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor Saída"

Return(oReport)

// Imprime os dados do contrato e o demonstrativo das parcelas provisórias
// geradas no contas a pagar (SE2)
Static Function ReportPrint(oReport)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2)
Local oSection3 := oReport:Section(3)
Local oSection4 := oReport:Section(4)
Local oSection5 := oReport:Section(5)
Local nY := 0

If oReport:Cancel()
	Return .T.
EndIf

// Inicializo todas as seçoes
oSection1:Init()
oSection2:Init()
oSection3:Init()
oSection4:Init()
oSection5:Init()
oReport:IncMeter()

Dbselectarea("FLZ")
FLZ->(dbgotop())
FLZ->(MsSeek(xFilial("FLZ")+mv_par01))

// Imprime a primeira seção
oSection1:Cell("DATA"):SetValue(FLZ->FLZ_DATA)
oSection1:Cell("PERIODO"):SetValue(FLZ->FLZ_PERIOD)	
oSection1:Cell("QUANT"):SetValue(FLZ->FLZ_QTDPER)					
oSection1:Printline()

Dbselectarea("FLW")
FLW->(dbgotop())
FLW->(MsSeek(xFilial("FLW")+mv_par01))

cNumFluxo := mv_par01

// Imprime a segunda seção
While FLW->(!EOF()) .And. FLW_CODIGO == mv_par01

	IncProc(STR0035) //"Imprimindo Fluxo de Caixa..."
	oSection2:Cell("DATA"):SetValue(FLW->FLW_DATA)
	oSection2:Cell("ENTRADA"):SetValue(FLW->FLW_ENTRAD)	
	oSection2:Cell("SAIDA"):SetValue(FLW->FLW_SAIDA)					
	oSection2:Printline()

	FLW->( dbSkip() )
	
EndDo

// Fluxo de caixa a ser comparado
If !MV_PAR02 

	Dbselectarea("FLW")
	FLW->(dbgotop())
	FLW->(MsSeek(xFilial("FLW")+mv_par03))

	Dbselectarea("FLW")
	FLW->(dbgotop())
	FLW->(MsSeek(xFilial("FLW")+mv_par03))

	cNumFluxo := mv_par03

	// Imprime a quarta seção
	While FLW->(!EOF()) .And. FLW_CODIGO == mv_par03

		IncProc(STR0035) //"Imprimindo Fluxo de Caixa..."
		oSection3:Cell("DATA"):SetValue(DTOC(FLW->FLW_DATA))
		oSection3:Cell("ENTRADA"):SetValue(FLW->FLW_ENTRAD)	
		oSection3:Cell("SAIDA"):SetValue(FLW->FLW_SAIDA)					
		oSection3:Printline()

		FLW->( dbSkip() )

	EndDo
// Fluxo de Caixa Realizado
Else
	// Imprime a primeira seção
	oSection4:Cell("FLUXO"):SetValue("")		
	oSection4:Printline()

	// Imprime a Sexta seção
	For nY := 1 to Len(__AuxLoad)
		IncProc(STR0035) //"Imprimindo Fluxo de Caixa..."
		oSection5:Cell("DATA"):SetValue(DTOC(__AuxLoad[nY][2][3]))
		oSection5:Cell("ENTRADA"):SetValue(__AuxLoad[nY][2][4])	
		oSection5:Cell("SAIDA"):SetValue(__AuxLoad[nY][2][5])	
		oSection5:Printline()
	Next nY
EndIf

// Finalizo a primeira seção para que seja reiniciada para o proximo registro
oSection1:Finish()

// Imprimo uma linha para separar as informações
oReport:ThinLine()

// Finalizo a segunda e terceira seção para que seja reiniciada para o proximo registro
oSection2:Finish()

//Finalizo a terceira seção para que seja reiniciada para o proximo registro
oSection3:Finish()

//Finalizo a quarta e quinta seção para que seja reiniciada para o proximo registro
oSection4:Finish()
oSection5:Finish()

Return
