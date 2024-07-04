#Include "FISA300B.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA300B
Rotina que montará a tela de resumo da apuração de ISS do bloco B
da EFD ICMS/IPI

@author Erick G. Dias
@since 13/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Function FISA300B(cModo, cIdF1P, cIdF1N, cDescrMun, oApurISS, oApurIssMun, oServico, cCodMun, cStatus)			
Local nRet			:= 0
Private cIdApur		:= cIdF1P
Private cIdApurMun  := cIdF1N
Private cDescMun    := cDescrMun
Private oISS	    := oApurISS
Private oIssMunic	:= oApurIssMun
Private oTotServico	:= oServico
Private cCodMunic	:= cCodMun
Private cTpDeducao	:= ""
Private cModoDed	:= cModo

//Se o modo for edição porém o status é diferente de apurado, ou seja, gerou título e/ou contabilizou, não permitirá alteração.
If cModo == "EDT" .AND. cStatus <> "1"
	cModoDed	:= "VSL"
EndIF

If cModo == "EDT"
	
	//Somente abro transação se for modo de edição
	BEGIN TRANSACTION
	
	//Chama a View da rotina diretamente
	nRet	:= FWExecView(STR0001 ,'FISA300B', MODEL_OPERATION_UPDATE,,, { || OnClose() },,,{ || OnExit() })	 //"Apuração de ISS"
	
	If nRet == 1	
		//Usuário cancelou
		DisarmTransaction()	
	ElseIF nRet == 0
		//Usuário confirmou
		oISS:saveapur()
	EndIF
	
	END TRANSACTION
Else
	
	//Chama a View da rotina diretamente sem transação
	nRet	:= FWExecView(STR0001 ,'FISA300B', MODEL_OPERATION_UPDATE,, { || .T. } , { || OnClose() }) //"Apuração de ISS"

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

@author Erick G. Dias
@since 13/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function MenuDef() 
Return FWMVCMenu( 'FISA300B' )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

@author Erick G. Dias
@since 13/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel	
Local oStruABA		:= FWFormStruct( 1, 'F1P')
Local oStruABA1		:= TempStruct(1,'ABA1') //Aba de ISS Próprio
Local oStruABA2		:= TempStruct(1,'ABA2') //Aba de ISS Substituto
Local oStruABA3		:= TempStruct(1,'ABA3') //Aba de ISS Uniprofissional
Local bLoadABA1  	:= {||LoadGrid('ABA1') } //Popula ISS Próprio
Local bLoadABA2  	:= {||LoadGrid('ABA2') } //Popula Substituto
Local bLoadABA3  	:= {||LoadGrid('ABA3') } //Popula Uniprofissional
Local bPreValid  	:= { |oModelGrid, nLine, cAction, cField| FSA300BPRE(oModelGrid, nLine, cAction, cField) }	

Default cDescMun	:= ""

oModel	:=	MPFormModel():New('FISA300B',,{|oModel| .T. },{|oModel| .T. })

oModel:AddFields('MODEL_ABA',, oStruABA)

//Montagem do grid do ISS Próprio
oModel:AddGrid('MODEL_ABA1', 'MODEL_ABA', oStruABA1,bPreValid,,,, bLoadABA1)
oModel:GetModel('MODEL_ABA1'):SetNoInsertLine(.T.)
oModel:GetModel('MODEL_ABA1'):SetNoDeleteLine(.T.)	

//Montagem do grid do ISS Substituto
oModel:AddGrid('MODEL_ABA2', 'MODEL_ABA', oStruABA2,bPreValid,,,, bLoadABA2)
oModel:GetModel('MODEL_ABA2'):SetNoInsertLine(.T.)
oModel:GetModel('MODEL_ABA2'):SetNoDeleteLine(.T.)	

//Montagem do grid do ISS Uniprofissional    
oModel:AddGrid('MODEL_ABA3', 'MODEL_ABA', oStruABA3,bPreValid,,,, bLoadABA3)
oModel:GetModel('MODEL_ABA3'):SetNoInsertLine(.T.)
oModel:GetModel('MODEL_ABA3'):SetNoDeleteLine(.T.)	

oModel:GetModel( 'MODEL_ABA1' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_ABA2' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_ABA3' ):SetOptional( .T. )

oModel:SetPrimaryKey({'ABA1_CMP1'})
oModel:SetDescription(cDescMun + " - " + DescModo() )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

@author Erick G. Dias
@since 13/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel     	:= FWLoadModel('FISA300B')
Local oView        	:= FWFormView():New()
Local oStruABA1   	:= TempStruct(2,'ABA1')
Local oStruABA2   	:= TempStruct(2,'ABA2')
Local oStruABA3   	:= TempStruct(2,'ABA3')

oView:SetModel( oModel )

//Cria View do ISS Próprio
oView:AddGrid('VIEW_ABA1', oStruABA1 ,'MODEL_ABA1')
//Cria View do ISS Substituto
oView:AddGrid('VIEW_ABA2', oStruABA2 ,'MODEL_ABA2')
//Cria View do ISS Uniprofissional
oView:AddGrid('VIEW_ABA3', oStruABA3 ,'MODEL_ABA3')

//Desabilita a ordenação do grid
oView:SetViewProperty( "*", "GRIDNOORDER")

  //Título da tela
oView:EnableTitleView('VIEW_ABA1',STR0002) //"Apuração do ISS Próprio"
oView:EnableTitleView('VIEW_ABA2',STR0003) //"Apuração do ISS Substituto"
oView:EnableTitleView('VIEW_ABA3',STR0004) //"Apuração do ISS Uniprofissional"

//Cria a pasta
oView:CreateFolder('PASTAS')

oView:CreateHorizontalBox( 'TELA1', 100,,, 'PASTAS', 'ABA01' )
oView:CreateHorizontalBox( 'TELA2', 100,,, 'PASTAS', 'ABA02' )
oView:CreateHorizontalBox( 'TELA3', 100,,, 'PASTAS', 'ABA03' )

//Cria as abas
oView:AddSheet('PASTAS', 'ABA01', STR0005) //"ISS Próprio"
oView:AddSheet('PASTAS', 'ABA02', STR0006) //"ISS Substituto"
oView:AddSheet('PASTAS', 'ABA03', STR0007) //"ISS Uniprofissional"

//Relaciona cada grid com sua respectiva aba na tela
oView:SetOwnerView( 'VIEW_ABA1'  , 'TELA1')
oView:SetOwnerView( 'VIEW_ABA2'  , 'TELA2')
oView:SetOwnerView( 'VIEW_ABA3'  , 'TELA3')

//Adiciona ação de dulo clique para informar as deduções
oView:SetViewProperty("VIEW_ABA1", "GRIDDOUBLECLICK", {{|oFormulario,cFieldName,nLineGrid,nLineModel, cField| FSA300BGDC(oFormulario,cFieldName,nLineGrid,nLineModel,cField)}})
oView:SetViewProperty("VIEW_ABA2", "GRIDDOUBLECLICK", {{|oFormulario,cFieldName,nLineGrid,nLineModel, cField| FSA300BGDC(oFormulario,cFieldName,nLineGrid,nLineModel,cField)}})
oView:SetViewProperty("VIEW_ABA3", "GRIDDOUBLECLICK", {{|oFormulario,cFieldName,nLineGrid,nLineModel, cField| FSA300BGDC(oFormulario,cFieldName,nLineGrid,nLineModel,cField)}})

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} TempStruct

Função utilizada para criação das tabelas temporárias para as abas
da apuração, já que as tabelas não estão em dicionário, deverão ser
criadas manualmente.

@param  	nOpcao  - indica se foi chamada na criação do Model ou da View.
			cTabela - Indica o alias da tabela temporária
@return	oStru  - Estrutura criada com os campos da tabela temporária qe será exibida na tela.

@author Erick G. Dias
@since 13/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function TempStruct(nOpcao,cTabela)

Local aCampos	:= {}
Local nCont	:= 0
Local oStru

//Chama Função para criar os campos conforme tabela processada
aCampos:= CriaCampos(cTabela)

//Quando for chamada para criar Model
If nOpcao == 1

	oStru :=  FWFormModelStruct():New()//	FWFormStruct( 1 , '')//
	oStru:AddTable("TRB",{},"TOTVS")
	For nCont := 1 to len (aCampos)
		oStru:AddField( ; 					// Ord. Tipo Desc.
						aCampos[nCont][1] , ;// [01] C Titulo do campo
						aCampos[nCont][1] , ;// [02] C ToolTip do campo
						aCampos[nCont][2] , ;// [03] C identificador (ID) do Field
						aCampos[nCont][3] , ;// [04] C Tipo do campo
						aCampos[nCont][4] , ;// [05] N Tamanho do campo
						aCampos[nCont][5] , ;	// [06] N Decimal do campo
						NIL				,;	// [07] B Code-block de validação do campo
						NIL 				, ;	// [08] B Code-block de validação When do campo
						aCampos[nCont][10]  , ;	// [09] A Lista de valores permitido do campo
						NIL 				, ;	// [10] L Indica se o campo tem preenchimento obrigatório
						nil					, ;	// [11] B Code-block de inicializacao do campo
						NIL 				, ;	// [12] L Indica se trata de um campo chave
						.F. 				, ;	// [13] L Indica se o campo pode receber valor em uma operação de update.
						.F. ) 					// [14] L Indica se o campo é virtual
	Next nCont

//Quando for chamada para criar a View
ElseIF nOpcao == 2

	oStru := FWFormViewStruct():New()
	For nCont := 1 to len (aCampos)
		oStru:AddField( ;
		aCampos[nCont][2], ; // [01] C Nome do Campo
		aCampos[nCont][6], ;	// [02] C Ordem
		aCampos[nCont][1], ;	// [03] C Titulo do campo
		aCampos[nCont][1], ;	// [04] C Descrição do campo
	    aCampos[nCont][7], ; // [05] A Array com Help
		aCampos[nCont][3], ; 	// [06] C Tipo do campo
		aCampos[nCont][8], ; // [07] C Picture
		NIL 			   , ;	// [08] B Bloco de Picture Var
		''                 , ; 	// [09] C Consulta F3
		aCampos[nCont][9]	, ; 	// [10] L Indica se o campo é evitável
		nil				   , ; 	// [11] C Pasta do campo
		NIL                , ;	// [12] C Agrupamento do campo
		aCampos[nCont][10] , ; 	// [13] A Lista de valores permitido do campo
		NIL                , ;	// [14] N Tamanho Maximo da maior opção do combo
		NIL                , ; 	// [15] C Inicializador de Browse
		.F.                , ; 	// [16] L Indica se o campo é virtual
		NIL )
	Next nCont

EndIF

Return oStru

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadGrid

 Função que irá retornar as informações para pouplar as linhas
 das tabelas temporárias de cada aba da tela de apuração.

@param  	     cTabela  - Tabela a qual serão será populada
@return	aLoad   - Array com as informações e valores para popular as telas

@author Erick G. Dias
@since 13/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function LoadGrid(cTabela)

Local aLoad  		:= {}

IF cTabela == 'ABA1'
    //Função para carregar informações do ISS Profissional
    aLoad	:= LoadApur("PRO")
ElseIF cTabela == 'ABA2'
    //Função para carregar informações do ISS Substituto
    aLoad	:= LoadApur("SUB")
ElseIF cTabela == 'ABA3'
    //Função para carregar informações do ISS Uniprofissional
    aLoad	:= LoadApur("UNI")
EndIF

Return( aLoad )

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaCampos

 Função que monta as propriedades de cada campo da tabela temporária
 de cada aba das telas de apuração

@param  	cTabela  - Tabela a qual serão criados os campos
@return	aCampos  - Array com as propriedades dos campos que serão criados

@author Erick G. Dias
@since 13/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function CriaCampos(cTabela)

Local aCampos	:= {}

//aAdd(aCampos, {/*Título*/,/*Nome do campo*/,/*Tipo*/,/*Tamanho*/,/*Decimal*/,/*Ordem*/,/*Array com help*/,/*Picture*/,/*Campo editáveç*/})
  
//---------------------------------------------
// Cria as colunas das abas da apuração
// Todas as abas terão as mesmas colunas, então estou mantendo a mesma estrutura para todas
// Se necessário alterar precisa tratar através da variável cTabela
//---------------------------------------------		
aAdd(aCampos, {STR0008     , cTabela + '_CMP1','C',6,0, '01',{STR0008}    ,'@!'               ,.F.,{}}) //STR0008 //STR0008 //"Linha"
aAdd(aCampos, {STR0009 , cTabela + '_CMP2','C',70,0,'02',{STR0009},'@!'               ,.F.,{}}) //STR0009 //STR0009 //"Descrição"
aAdd(aCampos, {STR0010     , cTabela + '_CMP3','N',14,2,'03',{STR0010}    ,'@E 999,999,999.99',.T.,{}})  //STR0010	 //STR0010 //"Valor"

Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} OnClose

Função que fará o tratamento ao concluir tela de resumo da apuração.

@author Erick G. Dias
@since 13/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function OnClose()

Local lRet		:= .T.
Local oModel    :=	FWModelActive()
Local oABA1	    := oModel:GetModel('MODEL_ABA1')
Local oABA2	    := oModel:GetModel('MODEL_ABA2')
Local oABA3	    := oModel:GetModel('MODEL_ABA3')
Local oView 	:= 	FWViewActive()
Local nLinProp	:= 13
Local nLinSub	:= 4
Local nLinUni	:= 7
Local nLinRecUni	:= 2

//Este trecho é necessário, pois preciso alterar o modelo para o botão confirmar fechar a tela.
//Como o modelo possui tabela temporária, preciso alterar o modelo manualmente
cText	:= oABA3:GetValue("ABA3_CMP1",1)
oABA3:SetValue('ABA3_CMP1', "." )
oview:Refresh( 'VIEW_ABA3' )
oABA3:SetValue('ABA3_CMP1', cText )
oview:Refresh( 'VIEW_ABA3' )

//Verifica se existe algum valor negativo antes de salvar, que pode ter surgido por meio de uma dedução manual com valor maior que o saldo devedor
IF lRet .AND. oABA1:GetValue("ABA1_CMP3",nLinProp) < 0
	Help( ,, 'Help',, STR0011 , 1, 0 ) //"O Total Apurado a Recolher do ISS Próprio está com valor negativo, por favor verifique!"
	lRet	:= .F.
EndIf

IF lRet .AND. oABA2:GetValue("ABA2_CMP3",nLinSub) < 0
	Help( ,, 'Help',, STR0012 , 1, 0 ) //"O Total Apurado a Recolher do ISS Substituto está com valor negativo, por favor verifique!"
	lRet	:= .F.
EndIf

IF lRet .AND. oABA3:GetValue("ABA3_CMP3",nLinUni) < 0
	Help( ,, 'Help',, STR0013 , 1, 0 ) //"O Total Apurado a Recolher do ISS Uniprofissional está com valor negativo, por favor verifique!"
	lRet	:= .F.
EndIf

//Atualiza o valor da receita da Sociedade Uniprofissionais
IF lRet .AND. cModoDed == "EDT"
	oIssMunic:setRecUni( oABA3:GetValue("ABA3_CMP3",nLinRecUni) )
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} OnExit

Função que faz validação ao clicar no botão fechar.

@author Erick G. Dias
@since 16/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function OnExit()

Local lRet:= .F.

lRet := ApMsgYesNo(STR0014) //"Deseja realmente sair? Informações alteradas serão descartadas."

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadApur

Função responsável por popular as linhas do grid do resumo da apuração

@author Erick G. Dias
@since 13/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function LoadApur(cApur)

Local aRet			:= {}
Local nX			:= 0
Local nTotDedBase	:= 0

IF cApur == "PRO"
    
    //------------------------------
    //Seção de campos do ISS Próprio
    //------------------------------		
    nTotDedBase	:=  oTotServico:getMatTerc() + oTotServico:getMatProp() + oTotServico:getSubEmp() + oTotServico:getIsent()

	aAdd(aRet, {nX++, {"", "", }})
    aAdd(aRet, {nX++, {"001", STR0015, oTotServico:getVAlCont()}})     //"Total das prestações de serviço (A)"
	aAdd(aRet, {nX++, {"002", STR0016, oTotServico:getMatTerc()}}) //"Total do material fornecido por terceiros (B)"
    aAdd(aRet, {nX++, {"003", STR0017, oTotServico:getMatProp()}}) //"Total do material próprio utilizado (C)"
    aAdd(aRet, {nX++, {"004", STR0018, oTotServico:getSubEmp()}}) //"Valor total das subempreitadas (D)"
    aAdd(aRet, {nX++, {"005", STR0019, oTotServico:getIsent()}}) //"Total das operações isentas ou não-tributadas (E)"
    aAdd(aRet, {nX++, {"006", STR0020, nTotDedBase}})     //"Total das deduções da base de cálculo (F = B+C+D+E)"
	aAdd(aRet, {nX++, {"007", STR0021, oTotServico:getBsCalc()}})     //"Total da base de cálculo do ISS (G = A-F)"
	aAdd(aRet, {nX++, {"008", STR0022, oTotServico:getBsRetPr()}}) //"Total da base de cálculo de retido (H)"
    aAdd(aRet, {nX++, {"009", STR0023, oTotServico:getISSDest()}}) //"Total do ISS destacado (I)"
    aAdd(aRet, {nX++, {"010", STR0024,oTotServico:getISSRetP()}})     //"Total do ISS retido (J)"
	aAdd(aRet, {nX++, {"011", STR0025, oIssMunic:getDedProp()}})     //"Total das deduções (K)"
	aAdd(aRet, {nX++, {"012", STR0026, oIssMunic:getISSProp()}}) //"Total apurado a recolher (L = I-J-K)"
	aAdd(aRet, {nX++, {"", "", }})

ElseIF cApur == "SUB"

    //----------------------------------
    //Seção de campos do ISS Substituto
    //----------------------------------
    aAdd(aRet, {nX++, {"", "", }})
    aAdd(aRet, {nX++, {"101", STR0027, oTotServico:getISSRetA()}})	 //"Total do ISS retido nas aquisições do declarante (A)"
    aAdd(aRet, {nX++, {"102", STR0028, oIssMunic:getDedSub()}})	 //"Valor total das deduções (B)"
    aAdd(aRet, {nX++, {"103", STR0029, oIssMunic:getISSSub()}}) //"Valor total apurado a recolher (C = A-B)"
	aAdd(aRet, {nX++, {"", "", }})

ElseIF cApur == "UNI"

    //---------------------------------------
    //Seção de campos do ISS Uniprofissional
    //---------------------------------------
    aAdd(aRet, {nX++, {"", "", }})    
	aAdd(aRet, {nX++, {"201", STR0030, oIssMunic:getRecUni()}}) //"Receita Mensal"
	aAdd(aRet, {nX++, {"202", STR0031, oIssMunic:getProfHab()}})	 //"Quantidade de profissionais habilitados (A)"
	aAdd(aRet, {nX++, {"203", STR0032, oIssMunic:getVlMensal()}})	 //"Valor devido por profissional (B)"
	aAdd(aRet, {nX++, {"204", STR0033, oIssMunic:getISSUniDev()}})	 //"Valor do ISS devido (C = A*B)"
    aAdd(aRet, {nX++, {"205", STR0034, oIssMunic:getDedUni()}})	 //"Valor total das deduções (D)"
    aAdd(aRet, {nX++, {"206", STR0035, oIssMunic:getISSUni()}}) //"Valor total apurado a recolher (E = C-D)"
	aAdd(aRet, {nX++, {"", "", }})

EndIF

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA300BGDC

Função que fará tratamento do duplo clique nas telas das apuraçãoes.

@author Erick G. Dias
@since 13/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function FSA300BGDC(oFormulario,cFieldName,nLineGrid,nLineModel,cField)

Local cLinha	:= ""
Local cAba 		:= Substr(cFieldName, 1, 4)

//Obtem a linha da apuração em que efetuou o duplo clique
cLinha := oFormulario:GetModel("MODEL_" + cAba):GetVAlue( cAba +  "_CMP1")

// Valida se o duplo clique foi na linha de deduções (205)
If cLinha == "011" .OR. cLinha == "102" .OR. cLinha == "205"
	DeducaoIssMunic(SubStr(cLinha, 1, 1))
EndIF

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} DeducaoIssMunic

Função que fará controle de chamada das deduções das apurações

@author Erick G. Dias
@since 13/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function DeducaoIssMunic(cIndApur)

Local cDescr		:= STR0036 //"Deduções do ISS "
Local cAttIsMemberOf := "AttIsMemberOf"
Local cFiltroBrw	:= 'F1Q_FILIAL == "' + xFilial('F1Q') + '"'
Local oBrowseDed	:= nil
Local oModel		:= FWModelActive()
Local oView 		:= FWViewActive()
Local aApurMunic	:= {}

cTpDeducao	:= cIndApur

IF cIndApur == "0"
	cDescr 		+= STR0037				 //"Próprio"
	cFiltroBrw 	+=' .AND. F1Q_INDOBR == "0" '
ElseIF cIndApur == "1"
	cDescr 		+= STR0038			 //"Substituto"
	cFiltroBrw 	+=' .AND. F1Q_INDOBR == "1" '
ElseIF cIndApur == "2"
	cDescr 		+= STR0039			 //"Uniprofissional"
	cFiltroBrw 	+=' .AND. F1Q_INDOBR == "2" '
EndIF

cFiltroBrw +=' .AND. F1Q_IDAPUR == "' + cIdApurMun  + '" '

//Chamará a view
oBrowseDed := FWmBrowse():New()
oBrowseDed:SetDescription( cDescr)
oBrowseDed:SetAlias( 'F1Q' )
oBrowseDed:SetMenuDef( 'FISA300C' )
// Desabilita a seleção de filiais na hora de incluir um ajuste. O ajuste sempre será incluido
// na filial "logada" (cfilant) já que a apuração é feita por filial.
If &cAttIsMemberOf.(oBrowseDed,"lBrwFilOn",.T.)
	oBrowseDed:lBrwFilOn := .F.
EndIf
oBrowseDed:SetFilterDefault( cFiltroBrw )
oBrowseDed:Activate()

//Carrega as deduções da FQ
oIssMunic:loadDeducoes()

//Atualiza os valores da apuração com as deduções carregadas
oIssMunic:apurar()

oModel:DeActivate() 
oModel:Activate()   
oview:Refresh( 'VIEW_ABA1' )
oview:Refresh( 'VIEW_ABA2' )
oview:Refresh( 'VIEW_ABA3' )

cTpDeducao	:= ""

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x300BIDAPU
Função que retorna o ID da apuração selecionada
@author Erick G. Dias
@since 13/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Function x300BIDAPU()
Return cIdApurMun

//-------------------------------------------------------------------
/*/{Protheus.doc} x300BTPDED
Função que retorna o tipo de dedução que será realizada
@author Erick G. Dias
@since 13/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Function x300BTPDED()
Return cTpDeducao

//-------------------------------------------------------------------
/*/{Protheus.doc} x300BMODO
Função que retorna o modo do modelo, edição, visualização, exclusão
@author Erick G. Dias
@since 19/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Function x300BMODO()
Return cModoDed

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA300BPRE
Função de pre validação da edição
@author Erick G. Dias
@since 17/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------

Static Function FSA300BPRE(oModelGrid, nLine, cAction, cField)

Local lRet:= .F.

If (cModoDed == "EDT" .AND. nLine == 2 .AND. cField == "ABA3_CMP3") .OR. isincallstack('OnClose')
	//Somente permitirá alterar o valor da receita mensal da sociedade uniprofissional
	lRet	:= .T.
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DescModo
Função auxiliar que trata a descrição do modo da view
@author Erick G. Dias
@since 17/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function DescModo()
Local cRet	:= ""

Default cModoDed := ""

If cModoDed == "EDT"
	cRet := STR0040 //" Edição "
ElseIF cModoDed == "VSL"
	cRet := STR0041 //" Visualização "
ElseIF cModoDed == "EXL"
	cRet := STR0042	 //" Exclusão "
EndIF
Return cRet
 