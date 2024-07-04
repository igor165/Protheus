#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' //Necessita desse include quando usar MVC.
#include "dbtree.ch"
#include 'PLSA446.CH'

Static _B7BFilial 	:= xFilial("B7B")
Static _B7AFilial 	:= xFilial("B7A")
Static aTabDup 		:= {}
Static cProtNew		:= "BEA_TMREGA/BEA_SAUOCU/BEA_COBESP/BEA_NOMSOC/B4Q_NOMSOC" //campos da tiss 4.00.01
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ PLSA446  º Autor ³Everton M. Fernandesº Data ³  03/05/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Função De x Para das Terminologias TISS					    ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ PLSA446                                                    ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSA446()
Local oBrowse

Private cChv444 := ""

If !FWAliasInDic("B7A", .F.)
MsgAlert(STR0032) //"Para esta funcionalidade é necessário executar os procedimentos referente ao chamado: THQGIW"
Return()
EndIf

// Instanciamento da Classe de Browse
oBrowse := FWMBrowse():New()

// Definição da tabela do Browse
oBrowse:SetAlias('BCL')

// Titulo da Browse
oBrowse:SetDescription(STR0001)

// Ativação da Classe
oBrowse:Activate()

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ ModelDef º Autor ³Everton M. Fernandesº Data ³  03/05/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Define o modelo de dados da aplicação                      ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ PLSA446                                                    ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ModelDef()
// Cria as estruturas a serem usadas no Modelo de Dados
Local oStruBCL 		:= FWFormStruct( 1, 'BCL' )
Local oStruB7A 		:= FWFormStruct( 1, 'B7A' )
Local oStruB7B 		:= FWFormStruct( 1, 'B7B' )
Local oStruB7BPortal:= FWFormStruct( 1, 'B7B' )
Local oStruB7C 		:= FWFormStruct( 1, 'B7C' )
Local oModel // Modelo de dados construído

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'PLSA446' )

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'BCLMASTER', /*cOwner*/, oStruBCL )

// Adiciona ao modelo uma componente de grid
oModel:AddGrid( 'B7ADETAIL', 'BCLMASTER', oStruB7A )
oModel:AddGrid( 'B7CDETAIL', 'BCLMASTER', oStruB7C )
oModel:AddGrid( 'B7BDETAIL', 'BCLMASTER', oStruB7B )
oModel:AddGrid( 'B7BPORTAL', 'BCLMASTER', oStruB7BPortal )

// Faz relacionamento entre os componentes do model
oModel:SetRelation( 'B7ADETAIL', { { 'B7A_FILIAL', 'xFilial( "B7A" )'},;
       									{ 'B7A_TIPGUI', 'BCL_TIPGUI'},;
       									{ 'B7A_TISVER', 'BCL_TISVER' } }, B7A->( IndexKey( 1 ) ) )

oModel:SetRelation( 'B7CDETAIL', { { 'B7C_FILIAL', 'xFilial( "B7C" )'},;
       									{ 'B7C_TIPGUI', 'BCL_TIPGUI'},;
       									{ 'B7C_TISVER', 'BCL_TISVER' } }, B7C->( IndexKey( 1 ) ) )

oModel:SetRelation( 'B7BDETAIL', { { 'B7B_FILIAL', 'xFilial( "B7B" )'},;
       									{ 'B7B_TIPGUI', 'BCL_TIPGUI'},;
       									{ 'B7B_TISVER', 'BCL_TISVER' } }, B7B->( IndexKey( 2 ) ) )

oModel:SetRelation( 'B7BPORTAL', { { 'B7B_FILIAL', 'xFilial( "B7B" )'},;
       									{ 'B7B_TIPGUI', 'BCL_TIPGUI'},;
       									{ 'B7B_TISVER', 'BCL_TISVER' } }, B7B->( IndexKey( 2 ) ) )

// Adiciona a descrição do Modelo de Dados
oModel:SetDescription( 'Tipos de Guia' )

// Adiciona a descrição dos Componentes do Modelo de Dados
oModel:GetModel( 'BCLMASTER' ):SetDescription( STR0001 )
oModel:GetModel( 'B7ADETAIL' ):SetDescription( STR0002 )
oModel:GetModel( 'B7CDETAIL' ):SetDescription( "Grupo de Campos Portal" )
oModel:GetModel( 'B7BDETAIL' ):SetDescription( STR0003 )
oModel:GetModel( 'B7BPORTAL' ):SetDescription( "Campos Portal" )

//Seta Chaves primarias
oModel:SetPrimaryKey({})

//Permite gravar apenas a tabela BCL
oModel:GetModel('B7ADETAIL'):SetOptional(.T.)
oModel:GetModel('B7BDETAIL'):SetOptional(.T.)
oModel:GetModel('B7BPORTAL'):SetOptional(.T.)
oModel:GetModel('B7CDETAIL'):SetOptional(.T.)

//Não permite alterar a tabela BCL
oModel:GetModel('BCLMASTER'):SetOnlyView(.T.)

//Adiciona Dependencias entre os campos
oModel:AddRules( 'B7ADETAIL', 'B7A_INDICE' , 'B7ADETAIL', 'B7A_ALIAS'  , 3 )
oModel:AddRules( 'B7ADETAIL', 'B7A_DADPES' , 'B7ADETAIL', 'B7A_ALIAS'  , 3 )
oModel:AddRules( 'B7ADETAIL', 'B7A_DADPES' , 'B7ADETAIL', 'B7A_INDICE' , 3 )


// Retorna o Modelo de dados
Return oModel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ ViewDef  º Autor ³Everton M. Fernandesº Data ³  03/05/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Define o modelo de dados da aplicação                      ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ PLSA446                                                    ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ViewDef()
// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel( 'PLSA446' )

// Cria as estruturas a serem usadas na View
Local oStruBCL 			:= FWFormStruct( 2, 'BCL' )
Local oStruB7A 			:= FWFormStruct( 2, 'B7A' )
Local oStruB7B 			:= FWFormStruct( 2, 'B7B' )
Local oStruB7BPortal 	:= FWFormStruct( 2, 'B7B' )
Local oStruB7C 			:= FWFormStruct( 2, 'B7C' )

// Interface de visualização construída
Local oView

//Retira o campo código da tela
oStruB7A:RemoveField('B7A_TIPGUI')
oStruB7A:RemoveField('B7A_TISVER')

//REMOVE CAMPOS DO PORTAL NA ABA DE RELATÓRIOS
oStruB7B:RemoveField('B7B_TIPGUI')
oStruB7B:RemoveField('B7B_TISVER')
oStruB7B:RemoveField('B7B_NOMXMO')
oStruB7B:RemoveField('B7B_TAMANH')
oStruB7B:RemoveField('B7B_TIPO')
oStruB7B:RemoveField('B7B_KEYPRE')
oStruB7B:RemoveField('B7B_KEYDOW')
oStruB7B:RemoveField('B7B_VALID')
oStruB7B:RemoveField('B7B_INIPAD')
oStruB7B:RemoveField('B7B_GRUPO')
oStruB7B:RemoveField('B7B_GATILH')
oStruB7B:RemoveField('B7B_CHVGAT')
oStruB7B:RemoveField('B7B_F3')
oStruB7B:RemoveField('B7B_OBRIGA')
oStruB7B:RemoveField('B7B_CHANGE')
oStruB7B:RemoveField('B7B_CBOX')
oStruB7B:RemoveField('B7B_ACTION')
oStruB7B:RemoveField('B7B_EDITAR')
oStruB7B:RemoveField('B7B_CSS')
oStruB7B:RemoveField('B7B_EDIOFF')

//REMOVE CAMPOS DE RELATÓRIOS NA ABA DO PORTAL
oStruB7BPortal:RemoveField('B7B_TIPGUI')
oStruB7BPortal:RemoveField('B7B_TISVER')
oStruB7BPortal:RemoveField('B7B_CONDIC')
oStruB7BPortal:RemoveField('B7B_TOTALI')
oStruB7BPortal:RemoveField('B7B_DADPAD')
oStruB7BPortal:RemoveField('B7B_ALIAS')
oStruB7BPortal:RemoveField('B7B_ALIDES')
oStruB7BPortal:RemoveField('B7B_TABTIS')
oStruB7BPortal:RemoveField('B7B_DESTIS')
oStruB7BPortal:RemoveField('B7B_CAMPO')

oStruB7C:RemoveField('B7C_TIPGUI')
oStruB7C:RemoveField('B7C_TISVER')

// Cria o objeto de View
oView := FWFormView():New()

// Define qual Modelo de dados será utilizado
oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:AddField( 'VIEW_BCL', oStruBCL, 'BCLMASTER' )

//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
oView:AddGrid( 'VIEW_B7A', oStruB7A, 'B7ADETAIL' )
oView:AddGrid( 'VIEW_B7C', oStruB7C, 'B7CDETAIL' )
oView:AddGrid( 'VIEW_B7B', oStruB7B, 'B7BDETAIL' )
oView:AddGrid( 'VIEW_B7BPOR', oStruB7BPortal, 'B7BPORTAL' )

//Nao deixa duplicar o campo B7A_CAMPO
//oModel:GetModel( 'B7ADETAIL' ):SetUniqueLine( { "B7A_FILIAL","B7A_TIPGUI","B7A_SEQUEN"} )
//oModel:GetModel( 'B7BDETAIL' ):SetUniqueLine( { "B7B_FILIAL","B7B_TIPGUI","B7B_ORDEM"} )

// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 40 )
oView:CreateHorizontalBox( 'INFERIOR', 60 )

//Cria as Folders
oView:CreateFolder( 'PASTA_INFERIOR' ,'INFERIOR' )

//Cria as pastas
oView:AddSheet( 'PASTA_INFERIOR'    , 'ABA_CONFIG'    , STR0002 ) //'Config. Impressão TISS'
oView:AddSheet( 'PASTA_INFERIOR'    , 'ABA_LAYOUT'    , STR0003 ) //'Etapa'
oView:AddSheet( 'PASTA_INFERIOR'    , 'ABA_GRUPOS'    , "Grupos de Campo Portal" ) //'Config. Impressão TISS'
oView:AddSheet( 'PASTA_INFERIOR'    , 'ABA_PORTAL'    , "Campos Portal" ) //'Etapa'

oView:CreateVerticalBox( 'BOX_CONFIG', 100,,, 'PASTA_INFERIOR', 'ABA_CONFIG' )
oView:CreateVerticalBox( 'BOX_LAYOUT', 100,,, 'PASTA_INFERIOR', 'ABA_LAYOUT' )
oView:CreateVerticalBox( 'BOX_GRUPOS', 100,,, 'PASTA_INFERIOR', 'ABA_GRUPOS' )
oView:CreateVerticalBox( 'BOX_PORTAL', 100,,, 'PASTA_INFERIOR', 'ABA_PORTAL' )

// Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView( 'VIEW_BCL', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_B7A', 'BOX_CONFIG' )
oView:SetOwnerView( 'VIEW_B7B', 'BOX_LAYOUT' )
oView:SetOwnerView( 'VIEW_B7C', 'BOX_GRUPOS' )
oView:SetOwnerView( 'VIEW_B7BPOR', 'BOX_PORTAL' )

//Adiciona campo incremental
oView:AddIncrementField( 'VIEW_B7B', 'B7B_ORDEM' )
oView:AddIncrementField( 'VIEW_B7BPOR', 'B7B_ORDEM' )
oView:AddIncrementField( 'VIEW_B7C', 'B7C_ORDEM' )

// Retorna o objeto de View criado
Return oView



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_DATAIND º Autor ³                    º Data ³  19/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Insere em Campo Memo campos pre-definidos para o Relatorio º±±
±±º          ³ de Informe de Rendimento PLSR997                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Function PL446CHV(cAlias, cPerg, cCodTab)

Local oModel   := FWModelActive()
Local oModelB7A   := oModel:GetModel( 'B7ADETAIL' )
Local oModelBCL   := oModel:GetModel( 'BCLMASTER' )

Local cIndice := oModelB7A:GetValue( 'B7A_INDICE')
Local cDadoInd := oModelB7A:GetValue( 'B7A_DADPES')
Local cDesAlias := oModelB7A:GetValue(  'B7A_DESCRI')
//Local nOrdExe := oModelB7A:GetValue( 'B7A_SEQUEN')

Local nPosSequen := GdFieldPos('B7A_SEQUEN')
Local nPosArquiv := GdFieldPos('B7A_ALIAS')
Local nPosDesArq := GdFieldPos('B7A_DESCRI')

Local aArea  := GetArea()
Local cIndRet := cDadoInd
Local cStrInd := ""
Local cCpoInd := ""
Local nPos := 0, nPosCtrl := 0, nI := 0
Local aCpsInd	:= {}
Local aHeadCpo 	:= {}
Local oTreeTab := Nil
Local nCps 		:= 0
Local aDadOri	:= {}
Local cDadOri	:= cDadoInd
Local nOpcI		:= 2

Default cCodTab := ""
DEFAULT cAlias := oModelB7A:GetValue( 'B7A_ALIAS')
DEFAULT cPerg := oModelBCL:GetValue( 'BCL_PERGUN')

If !FWAliasInDic("B7A", .F.)
MsgAlert(STR0032) //"Para esta funcionalidade é necessário executar os procedimentos referente ao chamado: THQGIW"
Return()
EndIf

//M->B7A_ALIAS, M->B7A_INDICE, M->B7A_DADPES,M->B7A_DESCRI, M->B7A_SEQUEN, ""
DbSelectArea("SX3")
DbSelectArea("SX2")

//Verifica se o indice existe
DbSelectArea("SIX")
DbSetOrder(1)
If DbSeek(cAlias+cIndice)
	cStrInd := Alltrim(SIX->CHAVE)
Else
	MsgStop(STR0004,STR0005)
	cCHV446 := cIndRet
	Return(.F.)
EndIf


//Desmmbra os dados existentes no campo e
//adiciona no aDadOri
If !Empty(cDadoInd)
	If At(")+",cDadoInd) > 0
		While !Empty(cDadoInd)
			If At(")+",cDadoInd) > 0
				AADD(aDadOri, Substr(cDadoInd, 1, At(")+",cDadoInd)) )
				cDadoInd := Substr(cDadoInd, At(")+",cDadoInd)+2,Len(cDadoInd) )
			Else
				AADD(aDadOri, cDadoInd)
				cDadoInd := ""
			EndIf
		EndDo
	ElseIf At("+",cDadoInd) > 0
		While !Empty(cDadoInd)
			If At("+",cDadoInd) > 0
				AADD(aDadOri, Substr(cDadoInd, 1, At("+",cDadoInd)-1))
				cDadoInd := Substr(cDadoInd, At("+",cDadoInd)+1,Len(cDadoInd) )
			Else
				AADD(aDadOri, cDadoInd)
				cDadoInd := ""
			EndIf
		EndDo
	EndIf
EndIf

//Desmmbra os dados existentes no campo e
//adiciona no aCpsInd
While !Empty(cStrInd)
	cDadAux := Space(100)
	If (nPos1 := At("+", cStrInd)) > 0
		cCpoInd := Substr(cStrInd, 1, nPos1 - 1)
		cStrInd :=  Substr(cStrInd, nPos1 + 1, Len(cStrInd))
	Else
		cCpoInd := cStrInd
		cStrInd := ""
	EndIf

	If !(cAlias $ Substr(cCpoInd,1,3)) .AND. (nPos1:= At("(", cCpoInd)) > 0
		cCpoInd := Alltrim(Substr(cCpoInd,nPos1+1, Len(cCpoInd)-1))
	EndIf
	DbSelectArea("SX3")
	DbSetOrder(2)
	DbSeek(cCpoInd)
	If "_FILIAL" $ 	cCpoInd
		nCps ++
		cDadAux := PADR("(xFilial('" + cAlias + "'))",100)
		AADD(aCpsInd, {cCpoInd,cDadAux, SX3->X3_TITULO, SX3->X3_DESCRIC, SX3->X3_TIPO, SX3->X3_TAMANHO,.F.})
	Else
		nCps ++
		If nCps <= Len(aDadOri)
	   		cDadAux := aDadOri[nCps]
	 	EndIf
		AADD(aCpsInd, {cCpoInd,cDadAux, SX3->X3_TITULO, SX3->X3_DESCRIC, SX3->X3_TIPO, SX3->X3_TAMANHO,.F.})
	EndIf
EndDo

//Header do GRID de Campos
aAdd(aHeadCpo,{STR0006,"HSPCAMPO","@!", Len(SX3->X3_CAMPO),0, ,,"C", ,"R",,,,"V",,,.T.})
aAdd(aHeadCpo,{STR0007,"HSPDADO","", 120,0,,,"C",         ,"R",,,,"A",,,.T.})
aAdd(aHeadCpo,{STR0008,"HSPTITULO","@!",  Len(SX3->X3_TITULO),0, ,,"C",         ,"R",,,,"V",,,.T.})
aAdd(aHeadCpo,{STR0009,"HSPDESCRIC","@!",  Len(SX3->X3_DESCRIC),0, ,,"C",         ,"R",,,,"V",,,.T.})
aAdd(aHeadCpo,{STR0010,"HSPTIPO","@!",  Len(SX3->X3_TIPO),0, ,,"C",         ,"R",,,,"V",,,.T.})
aAdd(aHeadCpo,{STR0011,"HSPTAMANHO","",  3,0, ,,"C",         ,"R",,,,"V",,,.T.})

nCampo := aScan(aHeadCpo, {| aVet | AllTrim(aVet[2]) == "HSPCAMPO"})
nDado := aScan(aHeadCpo, {| aVet | AllTrim(aVet[2]) == "HSPDADO"})
nTitulo := aScan(aHeadCpo, {| aVet | AllTrim(aVet[2]) == "HSPTITULO"})

DEFINE MSDIALOG oDlgIND FROM 62,100 TO 420,780 TITLE STR0012 PIXEL //"Complemeto de Informe de Rendimento" //"Complemento de Informe de Rendimento"

Define  FONT oFont NAME "Arial,12," BOLD
@ 006,010 SAY oSay PROMPT STR0013 + Iif(!Empty(cDesAlias), " tabela: " + cDesAlias,"")	SIZE 200,009 OF oDlgIND PIXEL COLOR CLR_HBLUE FONT oFont//"="

oCampos := MsNewGetDados():New(13, 10, 143, 155,GD_UPDATE,,,,,,,,,, oDlgIND , aHeadCpo, aCpsInd)
oCampos:oBrowse:bGotFocus := {|| oSayHlp:setText(STR0014 ) }
//oCampos:oBrowse:BLDblClick := {|| FS_DblCpo(oCampos, nDado, @cIndRet) }
//oCampos:bLinhaOk 	    := {|| FS_ATRBCPO("",@cIndRet)}

@ 165,030 SAY oSayHlp PROMPT STR0015 SIZE 500,009 OF oDlgIND PIXEL COLOR CLR_HRED //FONT oFont//"="
//================================================================¿
//³ Folder de vinculo do dado					                 ³
//================================================================Ù
@ 005, 168 FOLDER oFolVin SIZE 170, 158  OF oDlgIND PIXEL PROMPTS STR0016
//oFolVin:bSetOption := {|| oSayHlp:setText("* Dê duplo clique " + IIf(oFolVin:nOption <> 1, "no campo escolhido","na pergunta escolhida") + " para compor o indice no campo (" + Alltrim(oCampos:aCols[oCampos:nAt, nTitulo]) + ")") }
//oFolVin:Align := CONTROL_ALIGN_ALLCLIENT

DEFINE DBTREE oTreeTab FROM 05, 05 TO 100, 100 CARGO OF oFolVin:aDialogs[1] Pixel
//Adiciona a tree apenas as tabelas que estão "abaixo" na ordem
If nOrdExe > 1 .AND.  Len(oModelB7A:aCols) >= nOrdExe
	DBADDTREE oTreeTab PROMPT PADR(STR0017,50) RESOURCE "BMPGROUP" CARGO PADR(STR0017,100)
	For nI := 1 to Len(oModelB7A:aCols)
		If oModelB7A:aCols[nI,nPosSequen] < nOrdExe
			DBADDTREE oTreeTab PROMPT PADR(oModelB7A:aCols[nI,nPosArquiv] + " -> " + oModelB7A:aCols[nI,nPosDesArq],50) RESOURCE "PRODUTO" CARGO PADR("Cab|" + oModelB7A:aCols[nI,nPosArquiv],100)
			DbSelectArea("SX3")
			DbGoTop()
			DbSetOrder(1)
			If DbSeek(Alltrim(oModelB7A:aCols[nI,nPosArquiv]))
				While !Eof() .AND. SX3->X3_ARQUIVO == oModelB7A:aCols[nI,nPosArquiv]
					DBADDITEM oTreeTab PROMPT PADR(SX3->X3_CAMPO + " - " + Alltrim(SX3->X3_TITULO) + " (" + Alltrim(SX3->X3_TIPO) + "," + Alltrim(Str(SX3->X3_TAMANHO)) + ")",50)   RESOURCE "BR_WHITE" CARGO PADR(Alltrim(SX3->X3_CAMPO) + "|" + Alltrim(SX3->X3_TITULO) + "|*CPO*",100)
					DbSkip()
				EndDo
			EndIf
			DBENDTREE oTreeTab
		EndIf
	Next nI
	DBENDTREE oTreeTab
EndIf
If !Empty(cPerg)
	DbSelectArea("SX1")
	DbSetOrder(1)
	If DbSeek(cPerg)
		DBADDTREE oTreeTab PROMPT PADR(STR0018,50) RESOURCE "BMPGROUP" CARGO PADR(STR0018,100)
		While !Eof() .AND. Alltrim(SX1->X1_GRUPO) == Alltrim(cPerg)
			DBADDITEM oTreeTab PROMPT PADR(Alltrim(SX1->X1_VAR01) + " - " + Alltrim(SX1->X1_PERGUNT) + " (" + Alltrim(SX1->X1_TIPO) + "," + Alltrim(Str(SX1->X1_TAMANHO)) + ")",50)   RESOURCE "BR_WHITE" CARGO PADR(Alltrim(SX1->X1_VAR01) + "|" + Alltrim(SX1->X1_PERGUNT) + "|*PRG*",100)
			DbSkip()
		EndDo
		DBENDTREE oTreeTab
	Else
		HS_MSGINF(STR0019, STR0005, STR0020)
	EndIf
Endif


oTreeTab:bGotFocus := {|| oSayHlp:setText(STR0021 + Alltrim(oCampos:aCols[oCampos:nAt, nTitulo]) + ")") }
oTreeTab:BLDblClick := {|| FS_ATRBCPO(oTreeTab:GetCargo(),@cIndRet) }
oTreeTab:Align := CONTROL_ALIGN_ALLCLIENT

//DEFINE SBUTTON FROM 150,45 TYPE 1 ACTION ( { || .T.,oDlgIND:End() }) ENABLE OF oDlgIND
//DEFINE SBUTTON FROM 150,75 TYPE 2 ACTION ( { || cIndRet := cDadOri ,oDlgIND:End()}) ENABLE OF oDlgIND

DEFINE SBUTTON FROM 150,45 TYPE 1 ACTION {|| nOpcI := 1, FS_ATRBCPO("",@cIndRet), IIf(!Empty(cIndRet), oDlgIND:End(), nIL)} ENABLE OF oDlgIND//Ok
DEFINE SBUTTON FROM 150,75 TYPE 2 ACTION {|| nOpcI := 2, oDlgIND:End()} ENABLE OF oDlgIND	//Cancelar

ACTIVATE MSDIALOG oDlgIND CENTERED //VALID IIf(Empty(Alltrim(cTexto)).OR. !ValidText(cTexto),.F.,.T.)

If nOpcI == 2
	cIndRet := cDadOri
EndIf

RestArea(aArea)
cCHV446 := cIndRet
Return(.T.)
/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ@¿
//³Atribui dado do campo selecionado ao campo do indice³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ@Ù
*/
Static Function FS_ATRBCPO(cCargo, cStrFinal,lWiz)
Local cConcat 	:= ""
Local cAlCon	:= ""
Local cDado 	:= ""
Local cCampo 	:= ""
Local nI
Local nLenCpo	:= 0
Default lWiz := .F.
If "*PRG*" $ cCargo .OR. "*CPO*" $ cCargo
	cConcat := Substr(cCargo,1,At("|",cCargo)-1)
	If lWiz
		If "*CPO*" $ cCargo
			cAlCon := Substr(Alltrim(cConcat),1,At("_",cConcat) - 1)
			If Len(cAlCon) == 2
				cAlCon := "S" + cAlCon
			EndIf
			cConcat := cAlCon + "->" + cConcat
		EndIf
		oCampos:aCols[oCampos:nAt, nDado] := cConcat
		Return()
	Else
		cAlCon := Substr(Alltrim(cConcat),1,At("_",cConcat) - 1)
		If Len(cAlCon) == 2
			cAlCon := "S" + cAlCon
		EndIf
		cConcat := cAlCon + "->" + cConcat
	EndIf

	cDado := Alltrim(oCampos:aCols[oCampos:nAt, nDado])
	If Empty(cDado)
		oCampos:aCols[oCampos:nAt, nDado] := "(" + cConcat + ")"
	ElseIf At("(",cDado) > 0 .AND. At(")",cDado) > 0
		oCampos:aCols[oCampos:nAt, nDado] := SubStr(cDado,1, Len(cDado)-1) + "+" + cConcat + ")"
	Else
		oCampos:aCols[oCampos:nAt, nDado] := "(" + cDado + "+" + cConcat + ")"
	EndIf
EndIf
/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta String Final de retorno da função³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
cStrFinal := ""
nLenCpo := Len(oCampos:aCols)
For nI := 1 To nLenCpo
	cCampo := Alltrim(oCampos:aCols[nI, nDado])
	If !Empty(cCampo)
		If nI == nLenCpo
			cStrFinal += cCampo
		Else
			cStrFinal += cCampo + "+"
		EndIf
	EndIf
Next nI
If Substr(cStrFinal,Len(cStrFinal),1) == "+"
	cStrFinal := Substr(cStrFinal,1,Len(cStrFinal)-1)
EndIf
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_DATAIND º Autor ³                    º Data ³  19/01/12 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna o Alias cadastrado na tabela						    º±±
±±º          ³ de Informe de Rendimento PLSR997                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Function PL446ALI(cAlias)
Local cRet := ""
Local oModel := Nil
Local oModelAux := Nil

Default cAlias := "B7A"

oModel   := FWModelActive()
oModelAux   := oModel:GetModel( cAlias + 'DETAIL' )

cRet := oModelAux:GetValue( cAlias +'_ALIAS')

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_DATAIND º Autor ³                    º Data ³  19/01/12 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Insere em Campo Memo campos pre-definidos para o Relatorio º±±
±±º          ³ de Informe de Rendimento PLSR997                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Function PL446WHN(cAlias)
Local cRet := ""
Local oModel := Nil
Local oModelAux := Nil
Local lRet := .T.
Default cAlias := "B7B"

oModel   := FWModelActive()
oModelAux   := oModel:GetModel( cAlias + 'DETAIL' )

cRet := oModelAux:GetValue( cAlias +'_DADPAD')
lRet := Empty(cRet)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_M63RCPOºAutor  ³Saude           º Data ³  04/18/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna campo selecionado da lista disponivel              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PL446CPO(lTag)

Local oModel   := FWModelActive()
Local oModelB7A   := oModel:GetModel( 'B7ADETAIL' )
Local oModelB7B   := oModel:GetModel( 'B7BDETAIL' )

Local aArea 	:= getArea()
Local cDado	:= oModelB7B:GetValue( 'B7B_CAMPO')
Local cCargo	:= ""
Local cPerg 	:= ""//M->GTQ_CODPER
Local nI		:= 0
Local cTamCpo	:= SPACE(3)
Local nOpcI	:= 0
Local nAliasPos	:= B7A->(GdFieldPos("B7A_ALIAS", oModelB7A:aHeader))
Local nDescPos		:= B7A->(GdFieldPos("B7A_DESCRI", oModelB7A:aHeader))

DEFAULT lTag 	:= .T.

If !FWAliasInDic("B7A", .F.)
MsgAlert(STR0032) //"Para esta funcionalidade é necessário executar os procedimentos referente ao chamado: THQGIW"
Return()
EndIf


If Empty(cPerg) .AND. Len(oModelB7A:aCols) == 1
	If Empty(oModelB7A:aCols[1,nAliasPos])
		HS_MSGINF(STR0022,STR0005,STR0020)
		Return(.T.)
	EndIf
EndIf

DEFINE MSDIALOG oDlgCpo FROM 62,100 TO 380,450 TITLE STR0023 PIXEL

Define  FONT oFont NAME "Arial,12," BOLD
//@ 006,010 TO PROMPT "Selecione o dado:" SIZE 200,009 OF oDlgCpo PIXEL COLOR CLR_HBLUE FONT oFont//"="
@ 006, 006 TO 142, 170 Label STR0024 OF oDlgCpo PIXEL //COLOR CLR_HBLUE FONT oFont
//================================================================¿
//³ Folder de vinculo do dado					                 ³
//================================================================Ù
//@ 005, 168 FOLDER oFolVin SIZE 170, 158  OF oDlgCpo PIXEL PROMPTS "Campos / Perguntas" //@ 165,030 SAY oSayHlp PROMPT "* Posicione no campo para atribuir o dado do indice (os dois primeiros campos são de preenchimento obrigatório)"	SIZE 500,009 OF oDlgCpo PIXEL COLOR CLR_HRED //FONT oFont//"="

DEFINE DBTREE oTreeTab FROM 015, 011 TO 137, 167 CARGO OF oDlgCpo Pixel

If Len(oModelB7A:aCols) > 0 .AND. !Empty(cAlias)
	DBADDTREE oTreeTab PROMPT PADR(STR0017,50) RESOURCE "BMPGROUP" CARGO PADR(STR0017,100)
	For nI := 1 to Len(oModelB7A:aCols)

		DBADDTREE oTreeTab PROMPT PADR(oModelB7A:aCols[nI,nAliasPos] + " -> " + oModelB7A:aCols[nI,nDescPos],70) RESOURCE "PRODUTO" CARGO PADR("Cab|" + oModelB7A:aCols[nI,nAliasPos],100)
		DbSelectArea("SX3")
		DbGoTop()
		DbSetOrder(1)
		If DbSeek(Alltrim(oModelB7A:aCols[nI,nAliasPos]))
			While !Eof() .AND. SX3->X3_ARQUIVO == oModelB7A:aCols[nI,nAliasPos]
				DBADDITEM oTreeTab PROMPT PADR(SX3->X3_CAMPO + " - " + Alltrim(SX3->X3_TITULO) + " (" + Alltrim(SX3->X3_TIPO) + "," + Alltrim(Str(SX3->X3_TAMANHO)) + ")",70)   RESOURCE "BR_WHITE" CARGO PADR(Alltrim(SX3->X3_CAMPO) + "|" + Alltrim(SX3->X3_TITULO) + "(" + Alltrim(SX3->X3_TIPO) + "," + Alltrim(Str(SX3->X3_TAMANHO)) + ")*CPO*",100)
				DbSkip()
			EndDo
		EndIf
		DBENDTREE oTreeTab

	Next nI
	DBENDTREE oTreeTab
EndIf

If !Empty(cPerg)
	DbSelectArea("SX1")
	DbSetOrder(1)
	If DbSeek(cPerg)
		DBADDTREE oTreeTab PROMPT PADR(STR0018,70) RESOURCE "BMPGROUP" CARGO PADR(STR0018,100)
		While !Eof() .AND. Alltrim(SX1->X1_GRUPO) == Alltrim(cPerg)
			DBADDITEM oTreeTab PROMPT PADR(Alltrim(SX1->X1_VAR01) + " - " + Alltrim(SX1->X1_PERGUNT) + " (" + Alltrim(SX1->X1_TIPO) + "," + Alltrim(Str(SX1->X1_TAMANHO)) + ")",70)   RESOURCE "BR_WHITE" CARGO PADR(Alltrim(SX1->X1_VAR01) + "|" + Alltrim(SX1->X1_PERGUNT) + "(" + Alltrim(SX1->X1_TIPO) + "," + Alltrim(Str(SX1->X1_TAMANHO)) + ")*PRG*",100)
			DbSkip()
		EndDo
		DBENDTREE oTreeTab
	Else
		HS_MSGINF(STR0019, STR0005, STR0020)
	EndIf
Endif
//oTreeTab:bGotFocus := {|| cCargo := oTreeTab:GetCargo(),IIf("*PRG*" $ oTreeTab:GetCargo() .OR. "*CPO*" $ oTreeTab:GetCargo(), cTamCpo := StrZero(Substr(oTreeTab:GetCargo(),At(",",oTreeTab:GetCargo())+1,  At(")",oTreeTab:GetCargo())-1),3),Nil)   }
oTreeTab:bChange   := {|| cCargo := oTreeTab:GetCargo(),IIf("*PRG*" $ oTreeTab:GetCargo() .OR. "*CPO*" $ oTreeTab:GetCargo(), cTamCpo := StrZero(Val(Substr(oTreeTab:GetCargo(),At(",",oTreeTab:GetCargo())+1,  At(")",oTreeTab:GetCargo())-1)),3),Nil), oTam:Refresh()   }
oTreeTab:BLDblClick := {|| IIf("*PRG*" $ oTreeTab:GetCargo() .OR. "*CPO*" $ oTreeTab:GetCargo(), cDado := FS_RETDADO(oTreeTab:GetCargo(), cTamCpo, lTag), Nil), IIf("*PRG*" $ oTreeTab:GetCargo() .OR. "*CPO*" $ oTreeTab:GetCargo(), oDlgCpo:End(), Nil)  }


@ 145, 008 SAY oSay PROMPT STR0025 SIZE 50,009 OF oDlgCpo PIXEL COLOR CLR_HBLUE
@ 145, 024 MsGet oTam VAR cTamCpo Size 30, 009  PICTURE "999" WHEN lTag VALID !Empty(cTamCpo) OF oDlgCpo Pixel COLOR CLR_BLACK

DEFINE SBUTTON FROM 145,95 TYPE 1 ACTION {|| nOpcI := 1, IIf("*PRG*" $ oTreeTab:GetCargo() .OR. "*CPO*" $ oTreeTab:GetCargo(), oDlgCpo:End(), nIL)} ENABLE OF oDlgCpo//Ok

ACTIVATE MSDIALOG oDlgCpo CENTERED

If nOpcI == 1
	cDado := FS_RETDADO(cCargo, cTamCpo,.F.)
EndIf
RestArea(aArea)
cCHV446a += IIf(At("+",cDado) > 0,"+","") + cDado
Return(.T./*cDado*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna o dado do campo formatado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function FS_RETDADO(cCargo, cTam, lTag)
Local cData := ""
Local cType := ""
Local cAlias:= ""

If "*PRG*" $ cCargo .OR. "*CPO*" $ cCargo
	cData := Substr(cCargo,1,At("|",cCargo)-1)
	cType := Alltrim(Substr(cCargo  ,At("(",cCargo)+1,  At(",",cCargo)-1))
	If "*CPO*" $ cCargo
		cAlias := Substr(Alltrim(cData),1,At("_",cData) - 1)
		If Len(cAlias) == 2
			cAlias := "S" + cAlias
		EndIf
		cData := cAlias + "->(" + cData + ")"
	EndIf
	If !(cType $ "CM")
		If cType == "N"
			cData := "Alltrim(Str(" + cData + "))"
		ElseIf cType == "D"
			cData := "DtoS(" + cData + ")"
		ElseIf cType == "L"
			Hs_MsgInf(STR0026,STR0005,STR0020)
			Return("")
		EndIf
	EndIf
	//cData := IIf(lTag,"#A" + StrZero(Val(cTam),3),"") + "  " + cData + " "//+ " PADR(" + cData + "," + cTam + ")"
EndIf

//#A022  PADR(GCY->GCY_NOME,40)
Return(cData)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PL446DAD ºAutor  ³Saude                º Data ³  04/18/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta aDados										              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PL446DAD(cTipGui)
Local aDados 		:= {}
Local cAlias		:= ""
Local cChave		:= ""
Local cTisVer		:= ""
Local nPos			:= 0
Local cErro			:= ""

Default cTipGui 	:= ""

If Valtype(cTipGui)== "C"
	cTipGui := StrZero(Val(cTipGui),TamSX3("BCL_TIPGUI")[1])//"0" + cTipGui
Else
	cTipGui := "00"
EndIf

BCL->(DbSetOrder(1))
B7A->(DbSetOrder(1))
B7B->(DbSetOrder(1))

//Encontra o tipo da guia
If BCL->( MsSeek( xFilial("BCL") + PlsIntPad() + cTipGui))

	//Limpa e dimenciona o aDados
	aDados 	:= {}

	If BCL->BCL_QTDCMP > 0

		aSize(aDados,IIf(BCL->BCL_QTDCMP == 78, 79, BCL->BCL_QTDCMP))

		cTisVer := BCL->BCL_TISVER

		//Realiza o posicionamento configurado pelo usuário
		If B7A->(MsSeek(_B7AFilial+cTipGui+cTisVer))
		
			While !B7A->(Eof()) .AND. B7A->(B7A_FILIAL+B7A_TIPGUI+B7A_TISVER) == _B7AFilial+cTipGui+cTisVer .and. EMPTY(B7A->B7A_ALIPAI)

				cAlias 	:= B7A->B7A_ALIAS
				cIndice := B7A->B7A_INDICE
				cChave 	:= &(B7A->B7A_DADPES)
				
				//Preenche o aDados
				PLSTISPRE(cTipGui,cAlias,cIndice,cChave,@aDados, cTisVer)

			B7A->(DbSkip())
			EndDo
			
		Else
			MsgAlert(STR0027)
		EndIf
		
		// Por fim, preenche os campos que não usam tabelas
		//usando o o valor padrão configurado pelo usuario
		If B7B->(MsSeek(_B7BFilial+cTipGui+cTisVer))
		
			While !B7B->(Eof()) .and. B7B->(B7B_FILIAL+B7B_TIPGUI+B7B_TISVER) == _B7BFilial+cTipGui+cTisVer .and. Empty(B7B->B7B_ALIAS)

				nPos := B7B->B7B_ORDEM
				If Len(aDados) >= nPos .AND. B7B->B7B_IMPRIM == "S"
					aDados[nPos] := &(B7B->B7B_DADPAD)
				EndIf

			B7B->(DbSkip())
			EndDo

			//Grava log de erro
			If ! Empty(cErro)
				
				cArq := "erro_ger_relat_" + DtoS(Date()) + StrTran(Time(),":") + ".txt"
				
				FWLogMsg('ERROR',, 'SIGAPLS', funName(), '', '01',"Erro ao carregar dados do relatório." + CRLF + "Visualize o log em /LOGPLS/" + cArq  , 0, 0, {})
				
				cErro := 	"Erro ao carregar dados do relatório." + CRLF + ;
							"Verifique a cfg. de impressão da guia no cadastro de " + CRLF + ;
							"Tipos de Guias." + CRLF + CRLF + ;
							cErro
							
				PLSLogFil(cErro,cArq)
				
			EndIf

		EndIf
	Else
		MsgAlert(STR0028)
	EndIf
	
EndIf

Return(aDados)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSTISPOSºAutor  ³Saude                º Data ³  04/18/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o alias e Pai de outro alias 	              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSTISPOS(cTipGui, cPai, aDados, cTisVer)
Local aAreaB7A 	:= B7A->(GetArea())

B7A->(DbSetOrder(1))
If B7A->( MsSeek( _B7AFilial + cTipGui + cTisVer + cPai))
	
	While !B7A->(Eof()) .AND. B7A->(B7A_FILIAL+B7A_TIPGUI+B7A_TISVER+B7A_ALIPAI) == _B7AFilial+cTipGui+cTisVer+cPai

		//Verifica se a tabela deve ser posicionada
		lPos := IIF(Empty(B7A->B7A_CONDIC),.T.,&(B7A->B7A_CONDIC))
		
		If lPos

			cAlias 	:= B7A->B7A_ALIAS
			cIndice := B7A->B7A_INDICE
			cChave 	:= &(B7A->B7A_DADPES)
			
			//Preenche o aDados
			PLSTISPRE(cTipGui,cAlias,cIndice,cChave,@aDados, cTisVer)

		EndIf

	B7A->(DbSkip())
	EndDo
	
EndIf

RestArea(aAreaB7A)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSTISPREºAutor  ³Saude                º Data ³  04/18/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o alias e Pai de outro alias 	              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
function PLSTISPRE(cTipGui,cAlias,cIndice,cChave,aDados,cTisVer)
Local cChaveAux	:= ""
Local cChaveBus	:= ""
Local lPos		:= .T.
LOCAL lRetTiss 	:= .T.
LOCAL lImpriProc:= IIF(cTipGui == "05" .AND. cAlias == "BD6", .T., .F.)
Local cTabela 	:= ""
Local cPadBkp 	:= ""
Local nPosTabela:= 0
Local cCodPro  	:= ""

If empty(aTabDup)
	aTabDup 	:= PlsBusTerDup(SuperGetMv("MV_TISSCAB", .F. ,"87"))
endIf
//Verifica se o indice existe
If SIX->(MsSeek(cAlias + cIndice ) )
	
	&(cAlias)->(DbSetOrder( val(cIndice) ) )
	
	If &(cAlias)->(msSeek( iIf(lImpriProc, rTrim(cChave), cChave ) ) )
		
		//Posiciona a tabela de acordo com as chaves fornecidas
		//pelo usuario
		cChaveBus := SIX->CHAVE
		
		B7B->(DbSetOrder(1))
		
		while ! &(cAlias)->(eof()) .and. iIf(lImpriProc, BD6->BD6_CODPEG == BE4->BE4_CODPEG, rTrim(cChave) $ rTrim( &(cAlias + "->(" + cChaveBus + ")" ) ) )
			
			//Encontra os campos que serão impressos
			//Guarda a chave de busca //Necessário por causa da chamada recursiva
			cChaveAux := cChaveBus
			
			//Verifica se tem filho //Chamada recursiva//Relacionamento de chaves
			PLSTISPOS(cTipGui, B7A->B7A_ALIAS, @aDados, cTisVer)
			
			//Restaura a chave de busca //Necessário por causa da chamada recursiva
			cChaveBus := cChaveAux
			
			//Busca os campos configurados para a tabela
			If B7B->(MsSeek(_B7BFilial + cTipGui + cTisVer + B7A->B7A_ALIAS))
				
				While ! B7B->(eof()) .and. B7B->(B7B_FILIAL+B7B_TIPGUI+B7B_TISVER+B7B_ALIAS+B7B_IMPRIM) == _B7BFilial+cTipGui+cTisVer+B7A->B7A_ALIAS+"S"
					
					//Posição a preencher
					nPos := B7B->B7B_ORDEM
					
					// Posiciona na Terminologia TISS
					lRetTiss := .t.
					
					if ! empty(B7B->B7B_TABTIS)

						BTP->(DbSetOrder(1))
						BTP->( msSeek( xFilial('BTP') + B7B->B7B_TABTIS))
					
						lRetTiss := BTP->BTP_BUSDIR <> "1" //  Busca Direta TISS
						
					endIf	
					
					//Verifica se deve imprimir valor padrão
					If ! Empty(B7B->B7B_DADPAD)
						aDados[nPos] := &(B7B->B7B_DADPAD)
					Else
					
						//Verifica se o campo deve ser impresso
						lPos := IIF(Empty(B7B->B7B_CONDIC),.T.,&(B7B->B7B_CONDIC))
						
						If lPos
							
							//Verifica se preenche o campo com array (B7A->B7A_TIPO == '1')
							// ou campo simples (B7A->B7A_TIPO <> '1')
							If B7A->B7A_TIPO == "1" //1 == Tipo detalhe
								
								If B7B->B7B_TOTALI //Se for um totalizador
									
									//Protege para não realizar operação incorreta ('U' + 0 == erro!)
									If ValType(aDados[nPos]) == "U"
										aDados[nPos] := PLSRETTIS(B7B->B7B_TABTIS,cAlias,&(B7B->B7B_CAMPO), lRetTiss)
									Else
										
										If ValType(aDados[nPos]) =="A"
											
											If ValType(aDados[nPos,1]) == "N"
												
												aDados[nPos,1]:= aDados[nPos,1]
											Else
												
												aDados[nPos,1]:= val(aDados[nPos,1])
											EndIf
											
											aDados[nPos,1] 	+= PLSRETTIS(B7B->B7B_TABTIS,cAlias,&(B7B->B7B_CAMPO), lRetTiss)
										Else
											aDados[nPos] 	+= PLSRETTIS(B7B->B7B_TABTIS,cAlias,&(B7B->B7B_CAMPO), lRetTiss)
										EndIf
										
									EndIf
								
								//Campos normais
								Else
									
									//Preenche/Totaliza o campo
									If ValType(aDados[nPos]) == "U"
										aDados[nPos] := {}
									EndIf
									
									aAdd(aDados[nPos],PLSRETTIS(B7B->B7B_TABTIS,cAlias,&(B7B->B7B_CAMPO), lRetTiss))
								EndIf
								
							Else
								
								If B7B->B7B_TOTALI .and. ValType(aDados[nPos]) == "U" //Se for um totalizador
									
									aDados[nPos] += PLSRETTIS(B7B->B7B_TABTIS,cAlias,&(B7B->B7B_CAMPO), lRetTiss)
									
								Else
									
									
									If B7B->B7B_ORDEM == 20  .And. cTipGui == "01"
										
										cTabela 	:= &(B7B->B7B_CAMPO)
										cPadBkp		:= PLSGETVINC("BTU_CDTERM", "BR4", .F., "87",cTabela,.F.)
										aDados[nPos]:= cPadBkp
										nPosTabela 	:= nPos
										
									elseIf B7B->B7B_ORDEM == 21 .And. cTipGui == "01"
										
										If ! lRetTiss
											cCodPro	:= PLSGETVINC("BTU_CDTERM", "BR8", .F., cPadBkp, &(B7B->B7B_CAMPO), .F. ,aTabDup, @cPadBkp)
										else
											cCodPro	:= PLSGETVINC("BTU_CDTERM", "BR8", .F., cPadBkp , cTabela + &(B7B->B7B_CAMPO) , .F. ,aTabDup, @cPadBkp  /*,alltrim(cPadBkp)+BE2->BE2_CODPRO*/)
										endif
										
										aDados[nPos] 		:= cCodPro
										aDados[nPosTabela] 	:= cPadBkp
										
									elseIf ((B7B->B7B_ORDEM == 21 .And. cTipGui == "02") .or. (B7B->B7B_ORDEM == 22 .And. cTipGui == "03")) .And. !lRetTiss

										aDados[nPos] :=  IIF(BDR->BDR_CARINT =='E','1','2')
										
									else
										if PlVerExsCmp(alltrim(B7B->B7B_CAMPO), alltrim(B7B->B7B_ALIAS))
											aDados[nPos] := PLSRETTIS(B7B->B7B_TABTIS,cAlias,&(B7B->B7B_CAMPO), lRetTiss)
										endif	
									EndIf
									
								EndIf
								
							EndIf
							
						Else
							
							//Se não for para imprimir o campo apenas inicializa a posição
							If ValType(aDados[nPos]) == "U"
								
								//Trata os totalizadores
								If B7B->B7B_TOTALI
									
									aDados[nPos] := 0
									
									//Trata os demais campos
								Else
									
									If B7A->B7A_TIPO == "1" //1 == Tipo detalhe
										aDados[nPos] := {}
										aAdd(aDados[nPos],"")
									Else
										aDados[nPos] := ""
									EndIf
									
								EndIf
								
							EndIf
							
						EndIf
					EndIf
					
				B7B->(DbSkip())
				EndDo
				
			Else
				//Caso não encontre nenhum campo,
				// deixa a tabela posicionada, por que ela
				// provavelmente será utilizada como
				// parâmetro para outro posicionamento
				Exit
			EndIf
			
		&(cAlias)->(DbSkip())
		EndDo
		
		//Mantem posicionado no registro, caso seja necessário usar em alguma validação.
		&(cAlias)->(DbSkip(-1))
		
	//Se nao achar na tabela preenche com valores default (brancos ou arrays vazios)
	Else
		
		//Guarda a chave de busca //Necessário por causa da chamada recursiva
		cChaveAux := cChaveBus
		
		//Verifica se tem filho //Chamada recursiva
		PLSTISPOS(cTipGui, B7A->B7A_ALIAS, @aDados, cTisVer)
		
		//Restaura a chave de busca //Necessário por causa da chamada recursiva
		cChaveBus := cChaveAux
		
		If B7B->(MsSeek(_B7BFilial+cTipGui+cTisVer+B7A->B7A_ALIAS+"S"))
			
			While ! B7B->(eof()) .and. B7B->(B7B_FILIAL+B7B_TIPGUI+B7B_TISVER+B7B_ALIAS+B7B_IMPRIM) == _B7BFilial+cTipGui+cTisVer+B7A->B7A_ALIAS+"S"
				
				//Adiciona no aDados
				nPos := B7B->B7B_ORDEM
				
				//1 == Tipo detalhe
				If B7A->B7A_TIPO == "1"
					
					If ValType(aDados[nPos]) == "U"
						aDados[nPos] := {}
					EndIf
					
					If ValType(aDados[nPos]) == "A"
						aAdd(aDados[nPos],"")
					EndIf
					
					If cTipGui == "02" .and. nPos == 69 //Tratamento realizado para o campo 69 em específico porque o mesmo é tratado como campo virtual(hidden) na guia SADT.
						aDados[nPos] := ""
					EndIf
					
				Else
					aDados[nPos] := ""
				EndIf
				
			B7B->(DbSkip())
			EndDo
			
		EndIf
		
	EndIf
	
Else
	
	MsgAlert(STR0029 + cIndice + STR0030 + cAlias + STR0031)
	
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSRETTISºAutor  ³Everton M. Fernnades º Data ³  08/08/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ret. o valor da TISS correspondente ao passado pelo sistema ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSRETTIS(cCodTab,cAlias,cVlrSis, lRetTiss, cChave)
Local cRet			:= ""
Local cVlrSisSEEK	:= Iif(ValType(cVlrSis) == "U",NIL,IIf(ValType(cVlrSis) == "C", cVlrSis, IIf(ValType(cVlrSis) == "D",DTOC(cVlrSis),Alltrim(Str(cVlrSis)))))
Default cCodTab	:= ""
Default cAlias	:= ""
Default cChave	:= ""
Default cVlrSis	:= ""
Default lRetTiss:= .T.
Default cChave	:= ""

// A rotina serve tanto para retornar o valor da TISS a partir
//do Valor do protheus quanto o contrário. A variável lRetTiss
//controla isso: .T. -> Vlr. Protheus; .F. -> Vlr. Tiss
If lRetTiss .and. Empty(cCodTab) //Se não tem tabela de termo
	cRet := cVlrSis //Retorna o valor do protheus
Else

	//Caso especial que pede para retornar o codigo da tabela TISS
	If AllTrim(cVlrSis) == "B7B->B7B_TABTIS"
		cRet := B7B->B7B_TABTIS
	Else
	
		If lRetTiss //Indica se deve retornar o valor da TISS ou do Protheus

			BTU->(DbSetOrder(5))
			
			//Busca na tabela de De x Para pelo campo Valor Busca
			If BTU->(MsSeek(xFilial("BTU")+cCodTab+cAlias+cVlrSisSEEK))
				cRet := BTU->BTU_CDTERM
			Else
			
				BTU->(DbSetOrder(4))
				//Se não encontrar
				//Busca na tabela de De x Para pelo campo Valor Sistema
				If BTU->(MsSeek(xFilial("BTU")+cCodTab+cAlias+cVlrSisSEEK ))
					cRet := BTU->BTU_CDTERM
				Else
				
					If (!Empty(cCodTab) .And. cCodTab != "00") .And. !Empty(cVlrSis) .And. ValType(cVlrSis) == "C"
						cRet := PLSIMPVINC(cAlias,cCodTab,cVlrSis)
					Else
						cRet := cVlrSis 	//se mesmo assim não encontrar
					EndIf					//significa que não tem De x Para e
											//retorna o valor do protheus
				Endif
				
			EndIf
			
		Else
			
			//Retorna a Tabela Tiss
			BTP->(DbSetOrder(2)) //BTU_FILIAL+BTU_ALIAS+BTU_VLRSIS+BTU_CODTAB
			If BTP->(MsSeek(xFilial("BTP")+cAlias+cChave))
				
				cCodTab := BTP->BTP_CODTAB
				
			Else
			
				BVL->(DbSetOrder(2)) //BTU_FILIAL+BTU_ALIAS+BTU_VLRSIS+BTU_CODTAB
				If BVL->(MsSeek(xFilial("BVL")+cAlias+cChave))
					cCodTab := BVL->BVL_CODTAB
				Else
					cCodTab := ""
				EndIf
				
			EndIf
			
			//Busca na tabela de De x Para pelo valor passado.
			BTU->(DbSetOrder(2)) //BTU_FILIAL+BTU_ALIAS+BTU_VLRSIS+BTU_CODTAB

			If ! Empty(cCodTab) .AND. BTU->(MsSeek(xFilial("BTU")+cCodTab+PADR(xFilial(cAlias)+cVlrSisSEEK,TamSx3("BTU_VLRSIS")[1])+cAlias))
				cRet := BTU->BTU_CDTERM
			Else
				cRet := cVlrSis
			EndIf
			
		EndIf
		
	EndIf
	
EndIf

Return (cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EXTTABTIS  ³Everton M. Fernnades º Data ³  08/08/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ret. o valor da TISS correspondente ao passado pelo sistema ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EXTTABTIS(cTabTiss)
Local aArea 	:= GetArea()
Local lRet		:= .F.

Default cTabTiss := ""

DbSelectArea("BTP")
BTP->(DbSetOrder(1))

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSRETTISºAutor  ³Everton M. Fernnades º Data ³  08/08/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ret. o valor da TISS correspondente ao passado pelo sistema ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TrataErro(e, cErro,nPos)
Local lRet	:= e:gencode > 0

If lRet
	cErro 	+= "Posição: " + STR(nPos,3) + "; Descrição: " + e:Description + CRLF
EndIf

Return lRet


Function PLSDARRAY()
Return {CtoD(""),CtoD(""),CtoD(""),CtoD(""),CtoD(""),CtoD(""),CtoD(""),CtoD(""),CtoD(""),CtoD("")}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSIMPVINCºAutor  ³Everton M. Fernnades º Data ³  08/08/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ret. o valor da TISS correspondente ao passado pelo sistema ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

FUNCTION PLSIMPVINC(cAlias,cCodTab,cVlrSis,lDetTerm)
LOCAL cBtuAlias := ""
LOCAL cRet		:= ""

DEFAULT cAlias  := ""
DEFAULT cCodTab := ""
DEFAULT cVlrSis := ""
DEFAULT lDetTerm:= .F.

If ! Empty(cCodTab) .and. ! Empty(cAlias)
	
	BTU->(DbSetOrder(1))//BTU_FILIAL+BTU_CODTAB+BTU_ALIAS
	If BTU->(MsSeek(xFilial("BTU")+cCodTab))
	
		cBtuAlias := BTU->BTU_ALIAS
	
		BTU->(DbSetOrder(4))//BTU_FILIAL+BTU_CODTAB+BTU_VLRSIS+BTU_ALIAS
		If BTU->(MsSeek(xFilial("BTU")+cCodTab+cVlrSis+Space(TamSX3("BTU_VLRSIS")[1]-Len(cVlrSis))+cBtuAlias))
			cRet := BTU->BTU_CDTERM
		Else
	
			If BTU->(MsSeek(xFilial("BTU")+cCodTab+(xFilial(cBtuAlias)+cVlrSis+Space(TamSX3("BTU_VLRSIS")[1]-Len(cVlrSis)-8))+cBtuAlias))
				cRet := BTU->BTU_CDTERM
			Else
				If BTU->(MsSeek(xFilial("BTU")+cCodtab+xFilial(cBtuAlias)+cVlrSis))
					cRet := BTU->BTU_CDTERM
				EndIf
			EndIf
			
		EndIf
		
	EndIf
	
	// Verifica se o vlrsis passado já não está com o de/para realizado
	If empty(cRet)
		
		BTU->(DbSetOrder(5)) // BTU_FILIAL+BTU_CODTAB+BTU_CDTERM+BTU_ALIAS
		If BTU->(MsSeek(xFilial("BTU")+cCodtab+cVlrSis+Space(TamSX3("BTU_CDTERM")[1]-Len(cVlrSis))+cBtuAlias))
			cRet := BTU->BTU_CDTERM
		EndIf
		
	EndIf

Else
	cRet := cVlrSis
EndIf

If lDetTerm .And. !Empty(cRet)

	BTQ->(DbSetOrder(1))// BTQ_FILIAL+BTQ_CODTAB+BTQ_CDTERM   
	If BTQ->(MsSeek(xFilial("BTQ")+cCodTab+cRet))
		cRet := BTQ->BTQ_DESTER
	Endif
	
Endif

Return Alltrim(cRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PL446OLDPR
Realiza a impressao de uma guia de prorrogacao lancada no modelo 
antigo (sem o Alias B4C)

@author  Renan Sakai 
@version P12
@since    26.11.2018
/*/
//-------------------------------------------------------------------
Function PL446OLDPR()
Local aDados := {}
Local aAux19 := {}
Local aAux20 := {}
Local aAux21 := {}
Local aAux22 := {}
Local aAux23 := {}

//Posiciona os Alias
BA0->(DbSetOrder(1)) //BA0_FILIAL+BA0_CODIDE+BA0_CODINT
BA0->(MsSeek(xFilial('BA0')+BE4->BE4_OPEUSR))

BA1->(DbSetOrder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
BA1->(MsSeek(xFilial('BA1')+BE4->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG)))

BAQ->(DbSetOrder(1))//BAQ_FILIAL+BAQ_CODINT+BAQ_CODESP
BAQ->(MsSeek(xFilial('BAQ')+BE4->(BE4_CODOPE+BE4_CODESP)))

BI4->(DbSetOrder(1))//BI4_FILIAL+BI4_CODACO
BI4->(MsSeek(xFilial('BI4')+BE4->BE4_PADINT))

BAH->(DbSetOrder(1))//BAH_FILIAL+BAH_CODIGO
BAH->(MsSeek(xFilial('BAH')+BE4->BE4_SIGLA))

BEA->(DbSetOrder(1))//BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+BEA_DATPRO+BEA_HORPRO
BEA->(MsSeek(xFilial("BEA")+BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)))

if Empty(MV_PAR01)
	BB0->(DbSetOrder(4)) //BB0_FILIAL+BB0_ESTADO+BB0_NUMCR+BB0_CODSIG+BB0_CODOPE
	BB0->(MsSeek(xFilial('BB0')+BE4->(BE4_ESTSOL+BE4_REGSOL+BE4_SIGLA)))
else	
	BB0->(DbSetOrder(1)) //BB0_FILIAL+BB0_CODIGO
	BB0->(MsSeek(xFilial('BB0')+MV_PAR01))	                                                                                                 
endIf                                                        

//Monta array com dados da Guia
Aadd(aDados,Alltrim(BA0->BA0_SUSEP)) //01-REG. ANS
Aadd(aDados,BE4->(BE4_CODOPE+'.'+BE4_ANOINT+'.'+BE4_MESINT+'-'+BE4_NUMINT)) //02-NRO. GUIA PRESTADOR 
Aadd(aDados,BE4->(BE4_CODOPE+'.'+BE4_ANOINT+'.'+BE4_MESINT+'-'+BE4_NUMINT)) //03-NUMERO DA GUIA DE SO
Aadd(aDados,BE4->BE4_DATPRO) //04-DATA DA AUTORIZAÇÃO
Aadd(aDados,IIf(GetNewPar('MV_PLSGRSN','0') == '1',BE4->BE4_SENHA,'')) //05-SENHA
Aadd(aDados,BE4->BE4_CODOPE+'.'+BE4->BE4_ANOINT+'.'+BE4->BE4_MESINT+'.'+BE4->BE4_NUMINT) //06-NUMERO DA GUIA ATRIB
Aadd(aDados,PSRETCART()) //07-NRO. CARTEIRINHA
Aadd(aDados,BA1->BA1_NOMUSR) //08-NOME BENEFICIARIO   
Aadd(aDados,BE4->BE4_CODRDA) //09-CODIGO NA OPERADORA
Aadd(aDados,BE4->BE4_NOMRDA) //10-NOME CONTRATADO
Aadd(aDados,BB0->BB0_NOME) //11-NOME PROFISSIONAL SO
Aadd(aDados,PLSGETVINC('BTU_CDTERM','BAH',.F.,'26',ALLTRIM(BB0->BB0_CODSIG))) //12-CONSELHO PROFISSIONA
Aadd(aDados,BB0->BB0_NUMCR) //13-NUMERO DO CONSELHO  
Aadd(aDados,PLSGETVINC('BTU_CDTERM',Space(3),.F.,'59',ALLTRIM(BB0->BB0_ESTADO))) //14-UF
Aadd(aDados,PLSGETVINC('BTU_CDTERM','BAQ',.F.,'24',ALLTRIM(BAQ->BAQ_CBOS))) //15-CODIGO DO CBOS      
Aadd(aDados,CalcDiriaEvo(2)) //16-QTD. DIARIAS SOL.   
Aadd(aDados,PLSGETVINC('BTU_CDTERM','BI4',.F.,'49',StrZero(Val(BE4->BE4_PADINT),2))) //17-TIPO DE ACOMODAÇÃO S

//Posiciona na BQV
BQV->(DbSetOrder(1))//BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT
if BQV->(MsSeek(BE4->(BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)))
	if Empty(MV_PAR01) .Or. BQV->BQV_REGSOL==MV_PAR01
		Aadd(aDados,If(BQV->(FieldPos('BQV_CODMEM'))>0,BQV->BQV_MEMO1,ALLTRIM(BE4->BE4_INDCLI)+' '+ALLTRIM(BE4->BE4_INDCL2))) //18-INDICACAO CLINICA   
	else
		Aadd(aDados,'') //18-INDICACAO CLINICA
	endIf

	BR8->(DbSetOrder(1))//BR8_FILIAL+BR8_CODPAD+BR8_CODPSA+BR8_ANASIN	
	BR4->(DbSetOrder(1))//BR4_FILIAL+BR4_CODPAD+BR4_SEGMEN
	                                                                                 
	while BE4->(BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) == BQV->(BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT) .and. !BQV->(Eof())
		
		if BR8->(MsSeek(xFilial("BR8")+BQV->(BQV_CODPAD+BQV_CODPRO)))

			BR4->(MsSeek(xFilial('BR4')+BR8->BR8_CODPAD))			                                                                                          

			Aadd(aAux19,PLSGETVINC('BTU_CDTERM','BR4',.F.,'87',ALLTRIM(BQV->BQV_CODPAD)) ) //19-TABELA
			Aadd(aAux20,PLSGETVINC('BTU_CDTERM','BR8',.F.,PLSGETVINC('BTU_CDTERM','BR4',.F.,'87',ALLTRIM(BQV->BQV_CODPAD)),ALLTRIM(BQV->BQV_CODPRO))) //20-CODIGO PROCEDIMENTO 
			Aadd(aAux21,BR8->BR8_DESCRI) //21-DESCRICAO
			Aadd(aAux22,BQV->BQV_QTDSOL) //22-QTD SOL.
			Aadd(aAux23,IIF(BE4->BE4_STATUS == '3' .OR. BQV->BQV_STATUS == '0',0,BQV->BQV_QTDPRO)) //23-QTD AUT.
		endIf

		BQV->(DbSkip())
	endDo
endIf
Aadd(aDados,aAux19) //19-TABELA
Aadd(aDados,aAux20) //20-TABELA
Aadd(aDados,aAux21) //21-CODIGO PROCEDIMENTO 
Aadd(aDados,aAux22) //22-DESCRICAO           
Aadd(aDados,aAux23) //23-QTD SOL.
Aadd(aDados,CalcDiriaEvo(1)) //24-QTD. DIARIAS ADICION
Aadd(aDados,PLSGETVINC('BTU_CDTERM','BI4',.F.,'49',StrZero(Val(BE4->BE4_PADINT),2))) //25-TIPO DE ACOMODAÇÃO A
Aadd(aDados,'') //26-JUSTIFICATIVA DA OPE
Aadd(aDados,'') //27-OBSERVAÇÃO DA JUSTIF
Aadd(aDados,BE4->BE4_DATPRO) //28-DATA DA SOLICITAÇÃO 

Return aDados


//-------------------------------------------------------------------
/*/{Protheus.doc} PlVerExsCmp
Função para verificar se existem os campos novos da Guia TISS 4, pois tem bases que possuem e outras não, gerando problemas na impressão
@version P12
@since 04/2022
/*/
//-------------------------------------------------------------------
static function PlVerExsCmp(cCampoTab, cAlias)
local lRet	:= .t.
local cNomCamp	:= substr(cCampoTab, rat(">", alltrim(cCampoTab))+1, len(cCampoTab))

if cNomCamp $ cProtNew
	lRet := iif( (cAlias)->(FieldPos(cNomCamp)) = 0, .f., lRet)
endif
return lRet

/*/{Protheus.doc} ChkTab446
	Retorna o código do vínculo utilizando o aTabDup(PlsBusTerDup)
	PlsBusTerDup - Busca tabelas com DE_PARA para a mesma terminologia
	@author Cesar Almeida
	@since 03/10/2022
	@version P12
/*/

Function GetTabVinc()

	Local cRet := ""
	Local nAscan := 0

	nAscan := aScan(aTabDup,{|x|Alltrim(x[2]) == ALLTRIM(BQV->BQV_CODPAD)})

	If Len(aTabDup) > 0 .AND. nAscan > 0
		PLSGETVINC("BTU_CDTERM", "BR8", .F. ,  , ALLTRIM(BQV->BQV_CODPAD)+ALLTRIM(BQV->BQV_CODPRO),.F.    ,  aTabDup, @cRet)                                                  
	Else
		cRet:= PLSGETVINC('BTU_CDTERM', 'BR4', .F., '87', ALLTRIM(BQV->BQV_CODPAD))                                                                                                                                    
	Endif

Return cRet


/*/{Protheus.doc} ChkProc446
	Retorna o código do vínculo utilizando o aTabDup(PlsBusTerDup)
	PlsBusTerDup - Busca tabelas com DE_PARA para a mesma terminologia
	@author Cesar Almeida
	@since 03/10/2022
	@version P12
/*/

Function GetProVinc()

	Local cRet := ""

	cRet:= PLSGETVINC("BTU_CDTERM", "BR8", .F. ,  , ALLTRIM(BQV->BQV_CODPAD)+ALLTRIM(BQV->BQV_CODPRO),.F.,  aTabDup)                                                                                                                                                                      

Return cRet
