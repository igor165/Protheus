#INCLUDE "FISA107.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} FISA107
Cadastro de Rateios da Cat83

@author Graziele Mendonça Paro
@since 28/05/2015
@version P11

/*/
Function FISA107()

    Local oBrowse := Nil

    IF  AliasIndic("F01") 
        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias("F01")
        oBrowse:SetDescription(STR0001)     // "Rateios da Cat83"
        oBrowse:Activate()
    Else
        Help("",1,"Help","Help",STR0002,1,0) // Tabela F01 não cadastrada no sistema!
    EndIf
    
Return Nil     

/*/{Protheus.doc} ModelDef
Retorna o Modelo de dados da rotina de Cadastro Rateios da Cat83

@author Graziele Mendonça Paro
@since 28/05/2015
/*/
//--------------------------------------------------------------------------
Static Function ModelDef()

Local oModel   := Nil
Local oStruF01 := FwFormStruct(1,'F01')

// Instancia o modelo de dados
oModel := MpFormModel():New('FISA107',/*bPre*/,{|oMdl|A107TudOk(oModel)}/*bPos*/,/*bCommit*/, /*bCancel*/)

oModel:SetDescription(STR0001) //"Rateios da Cat83"

// Adiciona estrutura de campos no modelo de dados
oModel:AddFields('FORMF01',/*cOwner*/, oStruF01)
oModel:SetDescription(STR0001) // Rateios da Cat83

oModel:GetModel('FORMF01'):SetDescription(STR0001)

oModel:SetPrimaryKey({'F01_FILIAL','F01_PERIOD','F01_PRODUT','F01_FICHA'})

oStruF01:SetProperty('F01_PERIOD',MODEL_FIELD_WHEN, {||oModel:GetOperation()==3})
oStruF01:SetProperty('F01_PRODUT',MODEL_FIELD_WHEN, {||oModel:GetOperation()==3})
oStruF01:SetProperty('F01_FICHA' ,MODEL_FIELD_WHEN, {||oModel:GetOperation()==3})

Return oModel

//-----------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Retorna a View (tela) da rotina de Cadastro Rateios da Cat83

@author Graziele Mendonça Paro
@since 28/05/2015
/*/
//-----------------------------------------------------------------------
Static Function ViewDef()

Local oView    := Nil
Local oModel   := FwLoadModel('FISA107')
Local oStruF01 := FwFormStruct(2,'F01')//Cadastro Rateios da Cat83

// Instancia modelo de visualização
oView := FwFormView():New()

// Seta o modelo de dados
oView:SetModel(oModel)

// Adciona os campos na estrutura do modelo de dados
oView:AddField('VIEW_F01',oStruF01,'FORMF01')

//
oView:CreateHorizontalBox('TELA', 100)    //criou a tela e definiu que vai usar 100% do espaço

oView:SetOwnerView('VIEW_F01','TELA')


Return oView

//----------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Retorna o Menu da rotina de Cadastro Vigencia Classe de Selos

@author Graziele Mendonça Paro
@since 28/05/2015
/*/
//----------------------------------------------------------------

Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA107' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA107' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA107' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA107' OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina TITLE STR0008 ACTION 'Fi107Imp()'      OPERATION 3 ACCESS 0 //'Importar'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} A107TudOk
Função de validacao se ja existe o codigo informado.
                                   	
@author Flavio Luiz Vicco
@since 01/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A107TudOk(oModel)

Local lRet       := .T.
Local nOperation := oModel:GetOperation()
Local cPeriod    := oModel:GetValue('FORMF01','F01_PERIOD')
Local cProdut    := oModel:GetValue('FORMF01','F01_PRODUT')
Local cFicha     := oModel:GetValue('FORMF01','F01_FICHA' )

If nOperation == 3
	F01->(dbSetOrder(1)) //F01_FILIAL+F01_PERIOD+F01_PRODUT+F01_FICHA
	If F01->(dbSeek(xFilial('F01')+cPeriod+cProdut+cFicha))
		Help('',1,'JAGRAVADO')
		lRet := .F.
	EndIf
EndIf

/*IF lRet .And. cFicha == '2' .And. (nOperation == 3 .Or. nOperation == 4)
    Help("",1,"Help","Help",STR0007,1,0) //"Para a ficha 4B ainda não existe o tratamento no sistema!"
    lRet := .F.
EndIf*/

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Fi107Imp()

Funcao para importacao dos registros de rateios (F01)

@author Flavio Luiz Vicco
@since 17/06/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Function Fi107Imp()

Local cCaminho := Space(100)
Local aImport  := {}
Local lRet     := .F.
Local cPer     := Space(6)
Local nPosPrd  := 1
Local nPosFic  := 2
Local nPosPer  := 3
Local nPosPrc  := 4
Local nOpc     := 0

Private nTotReg := 0 //Total de registros lidos

While !lRet
	nOpc := 0
	lRet := .F.
	DEFINE MSDIALOG oDlg TITLE "Importacao rateios" From 0,0 To 25,50
	//--Arquivo
	oSayArq := tSay():New(005,007,{| | "Informe o local onde se encontra o arquivo para importação:"},oDlg,,,,,,.T.,,,200,80)
	oGetArq := TGet():New(015,005,{|u| If(PCount()>0,cCaminho:=u,cCaminho)},oDlg,150,10,'@!',,,,,,,.T.,,,,,,,,,,'cCaminho') 
	oBtnArq := tButton():New(015,160,"&Abrir...",oDlg,{| | cCaminho := F01Sel(cCaminho)},30,12,,,,.T.)
	//--Layout
	oSayLay := tSay():New(037,007,{| | "Informe a posição das colunas no arquivo que será importado que correspondem aos campos abaixo:"},oDlg,,,,,,.T.,,,150,80)
	//-- Periodo
	oSayPrc := tSay():New(062,007,{| | "Periodo (MMAAAA)"},oDlg,,,,,,.T.,CLR_BLUE,,200,80)
	oGetPrc := TGet():New(060,065,{|u| If(PCount()>0,cPer:=u,cPer)},oDlg,50,10,'@!',,,,,,,.T.,,,,,,,,,,"cPer")
	//--Posicao campo Produto
	oSayPrd := tSay():New(077,007,{| | RetTitle("F01_PRODUT")},oDlg,,,,,,.T.,CLR_BLUE,,200,80)
	oGetPrd := TGet():New(074,065,{|u| If(PCount()>0,nPosPrd:=u,nPosPrd)},oDlg,10,10,'99',,,,,,,.T.,,,,,,,,,,"nPosPrd") 
	//--Posicao campo Ficha
	oSayPer := tSay():New(092,007,{| | RetTitle("F01_FICHA")},oDlg,,,,,,.T.,CLR_BLUE,,200,80)
	oGetPer := TGet():New(090,065,{|u| If(PCount()>0,nPosFic:=u,nPosFic)},oDlg,10,10,'99',,,,,,,.T.,,,,,,,,,,"nPosFic")
	//--Posicao campo Perc.Rateio
	oSayPer := tSay():New(107,007,{| | RetTitle("F01_PERRAT")},oDlg,,,,,,.T.,CLR_BLUE,,200,80)
	oGetPer := TGet():New(105,065,{|u| If(PCount()>0,nPosPer:=u,nPosPer)},oDlg,10,10,'99',,,,,,,.T.,,,,,,,,,,"nPosPer")
	//--Posicao campo Preco Medio
	oSayPrc := tSay():New(122,007,{| | RetTitle("F01_PRCM")},oDlg,,,,,,.T.,CLR_BLUE,,200,80)
	oGetPrc := TGet():New(120,065,{|u| If(PCount()>0,nPosPrc:=u,nPosPrc)},oDlg,10,10,'99',,,,,,,.T.,,,,,,,,,,"nPosPrc")
	//--Botoes
	oBtnImp := tButton():New(170,050,"Importar",oDlg,{| | nOpc:=1,oDlg:End()},40,12,,,,.T.)
	oBtnCan := tButton():New(170,110,"Cancelar",oDlg,{| | nOpc:=0,oDlg:End()},40,12,,,,.T.)
	ACTIVATE MSDIALOG oDlg CENTERED
	//-- Validacoes	
	If nOpc == 1
		If Empty(cCaminho)
			MsgInfo("Informe o arquivo a ser importado.","Atenção")
			lRet := .F.
		ElseIf !File(cCaminho)
			MsgInfo("O arquivo selecionado para importação não foi encontrado.","Atenção")
			lRet := .F.
		Else
			lRet := .T.
		EndIf
		If lRet .And. (Empty(cPer) .OR.  Empty(nPosPrd) .Or. Empty(nPosPer) .Or. Empty(nPosPrc))
			MsgInfo("Os campos destacados em azul são de preenchimento obrigatório.","Atenção")
			lRet := .F.
		EndIf
	Else
		lRet := .T.
	EndIf
	If lRet .And. nOpc == 1
		Processa({|| aImport := Fi107Ler(cCaminho,nPosPrd,nPosFic,nPosPer,nPosPrc)},"Aguarde","Processando a leitura do arquivo...")
		If Len(aImport) == 0
			MsgInfo("Não há registros para importação!","Finalizado")
		ElseIf MsgYesNo("Serão importados "+AllTrim(Str(Len(aImport)))+" registro(s) de "+AllTrim(Str(nTotReg))+" registro(s) lido(s). Confirma?")
			Processa({|| Fi107Grv(cPer,aImport)},"Aguarde","Processando gravação do(s) registro(s) lido(s)...")
		EndIf
	EndIf
EndDo

Return lRet

//-- dialog para selecao de arquivo CSV
Static Function F01Sel(cArquivo)

Local cType := "Arquivo CSV (*.csv) |*.csv|"

cArquivo := cGetFile(cType, "Selecione o arquivo para importação",,,.T.)
If !Empty(cArquivo)
	cArquivo += Space(100-Len(cArquivo))
Else
	cArquivo := Space(100)
EndIf

Return cArquivo

//-------------------------------------------------------------------
/*/{Protheus.doc} Fi107Ler

Funcao para leitura do arquivo CSV e gravacao da tabela F01 - Rateios

@param dDtIn    inicial do Processamento
@param cArquivo Arquivo CSV para importacao 
@return lRet - Process. com sucesso

@author Flavio Luiz Vicco
@since 17/06/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function Fi107Ler(cArquivo,nPosPrd,nPosFic,nPosPer,nPosPrc)

Local aImport := {} //Array conteudo a ser gravado da tabela F01
Local lRet    := .T.
Local cLinha  := ""
Local cTrecho := ""
Local cProdut := ""
Local nPerRat := 0
Local nPrcM   := 0
Local nHdl    := 0
Local nX      := 0

Default nPosPrd := 1 //Nro Coluna do campo F01_PRODUT
Default nPosFic := 2 //Nro Coluna do campo F01_FICHA
Default nPosPer := 3 //Nro Coluna do campo F01_PERRAT
Default nPosPrc := 4 //Nro Coluna do campo F01_PRCM

Default cArquivo:= ""

If Empty(cArquivo)
	//-- Informe path+arquivo a ser importado.
	lRet := .F.
ElseIf !File(cArquivo)
	//-- Arquivo selecionado para importacao nao foi encontrado.
	lRet := .F.
ElseIf Empty(nPosPrd) .Or. Empty(nPosFic) .Or. Empty(nPosPer) .Or. Empty(nPosPrc)
	//-- As colunas dos campos nao foram informados.
	lRet := .F.
EndIf

SB1->(dbSetOrder(1)) //B1_FILIAL+B1_COD
F01->(dbSetOrder(1)) //F01_FILIAL+F01_PERIOD+F01_PRODUT+F01_FICHA

If lRet
	nHdl    := FT_FUSE(cArquivo)
	nTotReg := FT_FLASTREC()
	FT_FGOTOP()
	While !FT_FEOF()
		//-- Reinicia variaveis
		cProdut := CriaVar("F01_PRODUT",.F.)
		cFicha  := CriaVar("F01_FICHA" ,.F.)
		nPerRat := 0
		nPrcM   := 0
		nX      := 0
		cLinha  := FT_FREADLN()
		While !Empty(cLinha)
			nX++
			cTrecho := If(At(";",cLinha)>0,Substr(cLinha,1,At(";",cLinha)-1),cLinha)
			cLinha  := If(At(";",cLinha)>0,Substr(cLinha,  At(";",cLinha)+1),"")
			Do Case
				Case nPosPrd == nX
					cProdut := Padr(cTrecho,TamSX3("F01_PRODUT")[1])
				Case nPosFic == nX
					cFicha := Padr(cTrecho,TamSX3("F01_FICHA")[1])
				Case nPosPer == nX
					nPerRat := Val(StrTran(cTrecho,',','.'))
				Case nPosPrc == nX
					nPrcM := Val(StrTran(cTrecho,',','.'))
			EndCase
		EndDo
		aAdd(aImport,{cProdut,cFicha,nPerRat,nPrcM})
		//-- Proxima linha.
		FT_FSKIP()
	EndDo
	FT_FUSE()
EndIf

Return aImport

//-------------------------------------------------------------------
/*/{Protheus.doc} Fi107Grv
 
 Funcao para gravacao do F01 a partir do arquivo CSV
  
@param cPeriod - Periodo processamento
@param aCampos - Array conteudo a ser gravado da tabela F01
@return Nenhum
			
@author Flavio Luiz Vicco
@since 17/06/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function Fi107Grv(cPeriod,aImport)

Local nX := 0

Default cPeriod := "MMAAAA"

//-- Gravacao do F01 a partir do arquivo CSV
For nX := 1 To Len(aImport)
	If	SB1->(dbSeek(xFilial("SB1")+aImport[nX,1]))
		If	F01->(dbSeek(xFilial("F01")+cPeriod+aImport[nX,1]+aImport[nX,2]))
			RecLock("F01",.F.)
		Else
			RecLock("F01",.T.)
			F01_FILIAL := xFilial("F01")
			F01_PERIOD := cPeriod
			F01_PRODUT := aImport[nX,1]
			F01_FICHA  := aImport[nX,2]
		EndIf
		F01_PERRAT := aImport[nX,3]
		F01_PRCM   := aImport[nX,4]
		MsUnLock()
	EndIf
Next nX

Return Nil
