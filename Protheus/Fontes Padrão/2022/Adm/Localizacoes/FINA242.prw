#include 'TOTVS.CH'
#include 'FINA242.CH'
#include 'FWMVCDEF.CH'

Static _oFINA242
Static _oFINA242A


// #########################################################################################
// Projeto: 11.7
// Modulo : Financeiro
// Fonte  : FINA242.prw
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 03/09/12 | Marcos Berto	    | Cadastros de Lotes Financeiros
// ---------+-------------------+-----------------------------------------------------------

Function FINA242()

Local oBrowse

PRIVATE cCadastro := STR0001 //"Lote Financeiro"

If cPaisLoc $ "ARG|RUS"
	dbSelectArea("FJB")
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("FJB")
	oBrowse:SetDescription(STR0001) //"Lote Financeiro"
	oBrowse:AddLegend("FJB_STATUS = '1'","GREEN"	,STR0002) //"Ativo"
	oBrowse:AddLegend("FJB_STATUS = '2'","RED"	,STR0003) //"Inativo"
	oBrowse:AddLegend("FJB_STATUS = '3'","BLUE"	,STR0004) //"Arquivo Gerado"
	oBrowse:AddLegend("FJB_STATUS = '4'","BLACK"	,STR0005) //"Retorno do Banco"
	oBrowse:AddLegend("FJB_STATUS = '5'","PINK"	,STR0006) //"Inativo por erro"
	oBrowse:AddLegend("FJB_STATUS = '6'","ORANGE"	,STR0007) //"Baixado"
	
	oBrowse:Activate()
Else
	Alert(STR0037) //"Tabelas inexistentes. Favor atualizar o dicionário de dados."
EndIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Menu Funcional

Parametros do array a Rotina:                       
	- Nome a aparecer no cabecalho                         
	- Nome da Rotina associada                            
	- Reservado                                          
	- Tipo de Transacaoo a ser efetuada:                  
		1 - Pesquisa e Posiciona em um Banco de Dados     
		2 - Simplesmente Mostra os Campos                   
		3 - Inclui registros no Bancos de Dados             
		4 - Altera o registro corrente                         
		5 - Remove o registro corrente do Banco de Dados       
	- Nivel de acesso                                       
	- Habilita Menu Funcional  

@author    Marcos Berto
@version   11.7
@since     3/09/2012
/*/
//------------------------------------------------------------------------------------------

Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title STR0008 /*Pesquisar*/ 		Action "VIEWDEF.FINA242" 	OPERATION 1 ACCESS 0 
ADD OPTION aRotina Title STR0009 /*Incluir*/ 			Action "F242Incl" 			OPERATION 3 ACCESS 0
ADD OPTION aRotina Title STR0010 /*Desativar*/ 		Action "F242DesLot" 			OPERATION 2 ACCESS 0
ADD OPTION aRotina Title STR0011 /*Visualizar*/ 		Action "VIEWDEF.FINA242" 	OPERATION 2 ACCESS 0
ADD OPTION aRotina Title STR0012 /*Editar Lote*/		Action "F242Edit" 			OPERATION 4 ACCESS 0

//Efetivação de Ordem de Pago - Pagamento Eletrônico			
If cPaisLoc $ "ARG|RUS" 
	ADD OPTION aRotina Title STR0013 /*Eft. Lote*/	Action "F242EftLot" 			OPERATION 2 ACCESS 0
EndIf

Return aRotina

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados do controle de lotes financeiros

@author    Marcos Berto
@version   11.7
@since     3/09/2012
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

Local aRelacFJC := {}
Local aRelacSEK1 := {}
Local aRelacSEK2 := {}
Local oModel

Local oStrutFJB 	:= FWFormStruct(1,"FJB")
Local oStrutFJC 	:= FWFormStruct(1,"FJC")
Local oStrutSEK1 	:= FWFormStruct(1,"SEK")
Local oStrutSEK2 	:= FWFormStruct(1,"SEK")

oStrutFJB:AddField(STR0014 	,STR0014 	,"FJB_DESC"	,"C",20,0,,,,,{|| F242SitCab(FJB->FJB_STATUS)},,,.T.) //Status
oStrutFJC:AddField(""		,""			,"FJC_LEGEND"	,"C",15,0,,,,,{|| F242SitDet(FJC->FJC_STATUS)},,,.T.)

//Cria objeto de Modelo de Dados
oModel := MPFormModel():New("FINA242")

//Modelo de estutura por campos
oModel:AddFields("FJBMASTER",,oStrutFJB) 

//Modelo de estrutura por grid
oModel:AddGrid("FJCDETAIL","FJBMASTER",oStrutFJC)

//Modelo de estrutura por grid
oModel:AddGrid("SEK1DETAIL","FJCDETAIL",oStrutSEK1) 

//Modelo de estrutura por grid
oModel:AddGrid("SEK2DETAIL","FJCDETAIL",oStrutSEK2) 

//Relacionamento das tabelas
aAdd(aRelacFJC,{'FJC_FILIAL'	,'xFilial("FJC")'})
aAdd(aRelacFJC,{'FJC_BANCO'		,'FJB_BANCO'})
aAdd(aRelacFJC,{'FJC_AGENCI'	,'FJB_AGENCI'})
aAdd(aRelacFJC,{'FJC_CONTA'		,'FJB_CONTA'})
aAdd(aRelacFJC,{'FJC_NUMLOT'	,'FJB_NUMLOT'})

aAdd(aRelacSEK1,{'EK_FILIAL'	,'xFilial("SEK")'})
aAdd(aRelacSEK1,{'EK_ORDPAGO'	,'FJC_NUMFIN'})
aAdd(aRelacSEK1,{'EK_TIPODOC'	,"'CP'"})

aAdd(aRelacSEK2,{'EK_FILIAL'	,'xFilial("SEK")'})
aAdd(aRelacSEK2,{'EK_ORDPAGO'	,'FJC_NUMFIN'})
aAdd(aRelacSEK2,{'EK_TIPODOC'	,"'TB'"})

//Relacionamento Cabeçalho X Detalhe
oModel:SetRelation("FJCDETAIL",aRelacFJC,FJC->(IndexKey(1)))

//Relacionamento Detalhe x OP
oModel:SetRelation("SEK1DETAIL",aRelacSEK1,SEK->(IndexKey(1)))

//Relacionamento OP x Titulo
oModel:SetRelation("SEK2DETAIL",aRelacSEK2,SEK->(IndexKey(1)))

oModel:SetPrimaryKey({"FJB_FILIAL","FJB_BANCO","FJB_AGENCI","FJB_CONTA","FJB_NUMLOT"})

oModel:SetDescription(STR0001) //Lote Financeiro

oModel:GetModel("FJBMASTER"):SetDescription(STR0015)  //Cabecalho de lote
oModel:GetModel("FJCDETAIL"):SetDescription(STR0016)  //Detalhe de Lote
oModel:GetModel("SEK1DETAIL"):SetDescription(STR0017) //Pagamentos - OP
oModel:GetModel("SEK2DETAIL"):SetDescription(STR0018) //Títulos - OP

Return oModel

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função que define a interface do cadastro de lotes

@author    Marcos Berto
@version   11.7
@since     3/09/2012
/*/
//------------------------------------------------------------------------------------------

Static Function ViewDef()

Local oView

Local oModel := FWLoadModel("FINA242")

Local oStrutFJB 	:= FWFormStruct(2,"FJB")
Local oStrutFJC 	:= FWFormStruct(2,"FJC")
Local oStrutSEK1 	:= FWFormStruct(2,"SEK")
Local oStrutSEK2 	:= FWFormStruct(2,"SEK")

Local aCposSEK1 	:= {}
Local aCposSEK2 	:= {}

Local nX			:= 0
Local nPosCpo		:= 0

//Remove campos da FJB que não devem aparecer na tela
oStrutFJB:RemoveField("FJB_FILIAL")
oStrutFJB:RemoveField("FJB_STATUS")
oStrutFJB:AddField( "FJB_DESC","ZZ",RetTitle("FJB_STATUS"),RetTitle("FJB_STATUS"),,"C",,,,.F.,,,,,,,,.F.)

//Remove campos da FJC que não devem aparecer na tela
oStrutFJC:RemoveField("FJC_FILIAL")
oStrutFJC:RemoveField("FJC_BANCO")
oStrutFJC:RemoveField("FJC_AGENCI")
oStrutFJC:RemoveField("FJC_CONTA")
oStrutFJC:RemoveField("FJC_NUMLOT")
oStrutFJC:RemoveField("FJC_STATUS")

oStrutFJC:AddField( "FJC_LEGEND","","","",,"C","@BMP",,,.F.,,,,,,,,.F.)

//Remove os campos que não são serão exibidos em cada estrutura
aCposSEK2 := {"EK_PREFIXO","EK_NUM","EK_PARCELA",,"EK_TIPO","EK_FORNECE","EK_LOJA","EK_VALOR","EK_MOEDA"}
aCposSEK1 := {"EK_TIPO","EK_VALOR","EK_NUM","EK_EMISSAO","EK_VENCTO"}

dbSelectArea("SX3")
SX3->(dbSetOrder(1))
SX3->(dbSeek("SEK"))
For nX := 1 to Len(aCposSEK1) 	
	While !SX3->(Eof()) .And. X3_ARQUIVO == "SEK"
		//Pagamentos da OP
		nPosCpo := aScan(aCposSEK1,{|x| AllTrim(x) == AllTrim(X3_CAMPO)})	
		If nPosCpo == 0
			oStrutSEK1:RemoveField(AllTrim(X3_CAMPO))	
		EndIf
		//Titulos da OP
		nPosCpo := aScan(aCposSEK2,{|x| AllTrim(x) == AllTrim(X3_CAMPO)})	
		If nPosCpo == 0
			oStrutSEK2:RemoveField(AllTrim(X3_CAMPO))	
		EndIf
		SX3->(dbSkip())
	EndDo
Next nX

//Cria o objeto da View
oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField("VIEW_FJB",oStrutFJB,"FJBMASTER")
oView:AddGrid("VIEW_FJC",oStrutFJC,"FJCDETAIL")
oView:AddGrid("VIEW_SEK1",oStrutSEK1,"SEK1DETAIL")
oView:AddGrid("VIEW_SEK2",oStrutSEK2,"SEK2DETAIL")

oView:CreateHorizontalBox('TOPO'		,20)
oView:CreateHorizontalBox('DETALHE'	,80)

oView:CreateVerticalBox('ESQUERDA'	, 20, 'DETALHE')
oView:CreateVerticalBox('DIREITA'	, 80, 'DETALHE')

oView:CreateHorizontalBox('DETALHE1'	,60	,'DIREITA')
oView:CreateHorizontalBox('DETALHE2'	,40	,'DIREITA')

oView:SetOwnerView("VIEW_FJB"	,"TOPO")
oView:SetOwnerView("VIEW_FJC"	,"ESQUERDA")
oView:SetOwnerView("VIEW_SEK2"	,"DETALHE1")
oView:SetOwnerView("VIEW_SEK1"	,"DETALHE2")

oView:EnableTitleView("VIEW_FJB")
oView:EnableTitleView("VIEW_FJC")
oView:EnableTitleView("VIEW_SEK1")
oView:EnableTitleView("VIEW_SEK2")

Return oView

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F242SitCab
Função que retorno a situação de um lote

@author    Marcos Berto
@version   11.7
@since     3/09/2012

@param cStatus	Cod. do Status
@return cDesc	 	Descrição do Status

/*/
//------------------------------------------------------------------------------------------
Function F242SitCab(cStatus)

Local cDesc := ""

DEFAULT cStatus := ""


Do Case
	Case cStatus == "1"
		cDesc := STR0002 //"ATIVO"	
	Case cStatus == "2"
		cDesc := STR0003 //"INATIVO"	
	Case cStatus == "3"
		cDesc := STR0004 //"ARQUIVO GERADO"	
	Case cStatus == "4"
		cDesc := STR0005 //"RETORNO DO BANCO"	
	Case cStatus == "5"
		cDesc := STR0006 //"INATIVO POR ERRO"
	Case cStatus == "6"
		cDesc := STR0007 //"BAIXADO"		
EndCase
	
Return cDesc

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F242SitDet
Função que retorno a situação de um detalhe de lote

@author    Marcos Berto
@version   11.7
@since     3/09/2012

@param cStatus	Cod. do Status
@return cDesc	 	Descrição do Status

/*/
//------------------------------------------------------------------------------------------
Function F242SitDet(cStatus)

Local cDesc := ""

DEFAULT cStatus := ""

Do Case
	Case cStatus == "1"
		cDesc := "BR_VERDE"	
	Case cStatus == "2"
		cDesc := "BR_VERMELHO"	
EndCase

Return cDesc

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F242Incl
Função que inclui um lote financeiro 

@author    Marcos Berto
@version   11.7
@since     3/09/2012
/*/
//------------------------------------------------------------------------------------------

Function F242Incl()

Local aAux 	:= {}
Local aLote 	:= Array(6)

Local cBanco
Local cAgencia
Local cConta
Local dDataDe
Local dDataAte
Local cFornDe	
Local cFornAte
Local cLojaDe
Local cLojaAte
Local cValorDe
Local cValorAte

PRIVATE cAliasTmp		:= GetNextAlias()
PRIVATE cMarcaSEK		:= GetMark()

If Pergunte("FIN242")

	/*
	MV_PAR01 - Banco
	MV_PAR02 - Agencia
	MV_PAR03 - Conta
	MV_PAR04 - Data OP de
	MV_PAR05 - Data OP ate
	MV_PAR06 - Fornecedor de
	MV_PAR07 - Fornecedor ate
	MV_PAR08 - Loja de
	MV_PAR09 - Loja ate
	MV_PAR010 - Valor de
	MV_PAR011 - Valor ate	
	*/
	
	cBanco		:= MV_PAR01
	cAgencia	:= MV_PAR02
	cConta		:= MV_PAR03
	dDataDe	:= MV_PAR04
	dDataAte	:= MV_PAR05
	cFornDe	:= MV_PAR06
	cFornAte	:= MV_PAR07
	cLojaDe	:= MV_PAR08
	cLojaAte	:= MV_PAR09
	cValorDe	:= MV_PAR10
	cValorAte	:= MV_PAR11
	
	lOP := F242SelOP(cBanco,cAgencia,cConta,dDataDe,dDataAte,cFornDe,cFornAte,cLojaDe,cLojaAte,cValorDe,cValorAte)
	
	dbSelectArea(cAliasTmp)
	(cAliasTmp)->(dbGoTop())
	
	If lOP
		
	/*Lote:
		[1] Num. Lote
		[2] Banco
		[3] Agência
		[4] Conta
		[5] Ret. Banco? (1)Sim/(2)Não
		[6] Detalhes do Lote
			[6][1]	Filial
			[6][2]	Ordem de Pago
			[6][3]	Valor
			[6][4]	Moeda
			[6][5]	Fornecedor
			[6][6]	Loja
			[6][7]	Emissão 
			[6][8] Status (1)Ativo/(2)Inativo*/
		
		If 	!(cAliasTmp)->(Eof())
		
			aLote[1] := GetSxeNum("FJB","FJB_NUMLOT")
			aLote[2] := cBanco
			aLote[3] := cAgencia
			aLote[4] := cConta
			aLote[5] := "2" //Ret. Banco? Inicia com a opção "2-Nao"
			aLote[6] := {}
				
			While !(cAliasTmp)->(Eof())
				If (cAliasTmp)->TMPOK == cMarcaSEK
					aAdd(aAux,(cAliasTmp)->EK_FILIAL)
					aAdd(aAux,(cAliasTmp)->EK_ORDPAGO) 
					aAdd(aAux,(cAliasTmp)->EK_VALOR)   
					aAdd(aAux,(cAliasTmp)->EK_MOEDA)  
					aAdd(aAux,(cAliasTmp)->EK_FORNECE) 
					aAdd(aAux,(cAliasTmp)->EK_LOJA)    
					aAdd(aAux,(cAliasTmp)->EK_DTDIGIT) 
					aAdd(aAux,"1") //Inicia com a OP ativa
					
					aAdd(aLote[6],aAux)
					aAux := {}		
				EndIf
				(cAliasTmp)->(dbSkip())
			EndDo
		EndIf
		
		//Exibe a tela do lote para confirmação
		F242Lote(aLote,1)
	EndIf
	
	If(_oFINA242 <> NIL)

		_oFINA242:Delete()
		_oFINA242 := NIL

	EndIf
	If(_oFINA242A <> NIL)

		_oFINA242A:Delete()
		_oFINA242A := NIL

	EndIf
EndIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F242SelOP
Função que inclui um lote financeiro 

@author    Marcos Berto
@version   11.7
@since     3/09/2012

@param cBanco 	Banco
@param cAgencia 	Agencia
@param cConta		Conta
@param dDataDe	Data inicial das OPs
@param dDataAte	Data final das OPs
@param cFornDe	Fornecedor de
@param cFornAte	Fornecedor até
@param cLojaDe	Loja de
@param cLojaAte	Loja até
@param cValorDe	Valor de 	
@param cValorAte	Valor até

/*/
//------------------------------------------------------------------------------------------
Function F242SelOP(cBanco,cAgencia,cConta,dDataDe,dDataAte,cFornDe,cFornAte,cLojaDe,cLojaAte,cValorDe,cValorAte)

Local aButtons 	:= {}

Local bInitBr

Local lOP			:= .T.

Local oBrwSelOP
Local oDlgOP

DEFAULT cBanco 	:= ""
DEFAULT cAgencia 	:= ""
DEFAULT cConta 	:= ""
DEFAULT dDataDe 	:= dDataBase
DEFAULT dDataAte 	:= dDataBase
DEFAULT cFornDe	:= ""
DEFAULT cFornAte	:= ""
DEFAULT cLojaDe	:= ""
DEFAULT cLojaAte	:= ""
DEFAULT cValorDe	:= 0	
DEFAULT cValorAte	:= 0

//Seleciona as Ordens de Pago de acordo com o filtro informado
F242FilOP(cBanco,cAgencia,cConta,dDataDe,dDataAte,cFornDe,cFornAte,cLojaDe,cLojaAte,cValorDe,cValorAte)

dbSelectArea(cAliasTmp)
(cAliasTmp)->(dbGoTop())

If !(cAliasTmp)->(Eof())
	
	//Define os objetos para montagem da seleção no browse
	oOk  := LoadBitmap(GetResources(),"wfchk")
	oNOk := LoadBitmap(GetResources(),"wfunchk")
	
	If Type("cMarcaSEK") <> "U"
		If Empty(cMarcaSEK)
			cMarcaSEK := ""	
		EndIf
	EndIf
	
	oDlgOP := MsDialog():New( 0,0,400,700,STR0019,,,,,,,,,.T.) //"Seleção de Ordem de Pago"
	
	oBrwSelOP := TCBrowse():New(0,0,400,400,,,,oDlgOP,,,,,{|| F242MrkOP() },,,,,,,,cAliasTmp,.T.,,,,.T.,)
	oBrwSelOP:AddColumn(TcColumn():New("",{|| Iif((cAliasTmp)->TMPOK == cMarcaSEK,oOK,oNOK)},,,,,010,.T.,.F.,,,,,))
	oBrwSelOP:AddColumn(TcColumn():New(RetTitle("EK_ORDPAGO")	,{|| (cAliasTmp)->EK_ORDPAGO }	,PesqPict("SEK","EK_ORDPAGO")	,,,,TamSX3("EK_ORDPAGO")[1]	,.F.,.F.,,,,,))
	oBrwSelOP:AddColumn(TcColumn():New(STR0020 /*Total OP*/		,{|| (cAliasTmp)->EK_VALOR   }	,PesqPict("SEK","EK_VALOR")		,,,,TamSX3("EK_VALOR")[1]	,.F.,.F.,,,,,))
	oBrwSelOP:AddColumn(TcColumn():New(RetTitle("EK_MOEDA")		,{|| (cAliasTmp)->EK_MOEDA   }	,PesqPict("SEK","EK_MOEDA")		,,,,TamSX3("EK_MOEDA")[1]	,.F.,.F.,,,,,))
	oBrwSelOP:AddColumn(TcColumn():New(RetTitle("EK_FORNECE")	,{|| (cAliasTmp)->EK_FORNECE }	,PesqPict("SEK","EK_FORNECE")	,,,,TamSX3("EK_FORNECE")[1]	,.F.,.F.,,,,,))
	oBrwSelOP:AddColumn(TcColumn():New(RetTitle("EK_LOJA")		,{|| (cAliasTmp)->EK_LOJA    }	,PesqPict("SEK","EK_LOJA")		,,,,TamSX3("EK_LOJA")[1]		,.F.,.F.,,,,,))
	oBrwSelOP:AddColumn(TcColumn():New(RetTitle("EK_EMISSAO")	,{|| (cAliasTmp)->EK_DTDIGIT }	,PesqPict("SEK","EK_EMISSAO")	,,,,TamSX3("EK_EMISSAO")[1]	,.F.,.F.,,,,,))
	oBrwSelOP:Align := CONTROL_ALIGN_ALLCLIENT

	//Bloco a ser executado na confirmação da seleção de Ordens de Pago
	bOk := {|| GetKeys() , SetKey( VK_F3 , Nil ), lOP := .T., oDlgOP:End()}
	
	//Bloco a ser executado ao cancelar a seleção de Ordens de Pago
	bCancel := {|| GetKeys() , SetKey( VK_F3 , Nil ), lOP := .F., oDlgOP:End()}
	
	//Inclui itens das Ações Relacionadas
	aAdd(aButtons,{"PENDENTE"	,{|| F242InMkOP(),oBrwSelOP:Refresh()},STR0021,STR0021}) //"Inverte Seleção"
	aAdd(aButtons,{"POSCLI"		,{|| F242DetOP((cAliasTmp)->EK_ORDPAGO)},STR0022,STR0022 }) //"Detalhe OP"
	
	//Bloco para montagem da Enchoice da tela de seleção de Ordens de Pago
	bInitBr := { || EnchoiceBar( oDlgOP , bOk , bCancel , Nil , aButtons )}
	oDlgOP:bInit := bInitBr
	
	oDlgOP:Activate(,,,.T.)
	
Else
	Alert(STR0028+" "+STR0029) //"Não existem dados para montagem de um lote. Verifique os parâmetros informados."
	lOP := .F.
EndIf

Return lOP

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F242FilOP
Função que filtra as Ordens de Pago conforme parametrizados 

@author    Marcos Berto
@version   11.7
@since     6/09/2012

@param cBanco 	Banco
@param cAgencia 	Agencia
@param cConta		Conta
@param dDataDe	Data inicial das OPs
@param dDataAte	Data final das OPs
@param cFornDe	Fornecedor de
@param cFornAte	Fornecedor até
@param cLojaDe	Loja de
@param cLojaAte	Loja até
@param cValorDe	Valor de 	
@param cValorAte	Valor até

/*/
//------------------------------------------------------------------------------------------
Function F242FilOP(cBanco,cAgencia,cConta,dDataDe,dDataAte,cFornDe,cFornAte,cLojaDe,cLojaAte,cValorDe,cValorAte)

Local aStruct 	:= {}

Local cFilSEK		:= ""
Local cOrdPago	:= ""
Local cFornece	:= ""
Local cLoja		:= ""
Local cMoedOP		:= ""	

Local cAliasSEK	:= GetNextAlias()
Local cArqTemp 	:= ""
Local cQuery 		:= ""

Local dDtEmis		:= dDataBase

Local nValOP		:= 0

DEFAULT cBanco 	:= ""
DEFAULT cAgencia 	:= ""
DEFAULT cConta 	:= ""
DEFAULT dDataDe 	:= dDataBase
DEFAULT dDataAte 	:= dDataBase
DEFAULT cFornDe	:= ""
DEFAULT cFornAte	:= ""
DEFAULT cLojaDe	:= ""
DEFAULT cLojaAte	:= ""
DEFAULT cValorDe	:= 0	
DEFAULT cValorAte	:= 0

cQuery := "SELECT EK_FILIAL,EK_ORDPAGO,EK_VALOR,EK_MOEDA,EK_FORNECE,EK_LOJA,EK_DTDIGIT "
cQuery += "	FROM "+RetSQLName("SEK")+" SEK "
cQuery += "	WHERE"
cQuery += "		SEK.EK_FILIAL = '"+xFilial("SEK")+"' AND "
cQuery += "		SEK.EK_DTDIGIT BETWEEN '"+Dtos(dDataDe)+"' AND '"+Dtos(dDataAte)+"' AND "
cQuery += "		SEK.EK_FORNECE BETWEEN '"+cFornDe+"' AND '"+cFornAte+"' AND "
cQuery += "		SEK.EK_LOJA BETWEEN '"+cLojaDe+"' AND '"+cLojaAte+"' AND "
cQuery += "		SEK.EK_TIPODOC = 'CP' AND "
cQuery += "		SEK.EK_PGTOELT = '1' AND "
cQuery += "		SEK.EK_NUMLOT = '' AND "
cQuery += "		SEK.EK_CANCEL = 'F' AND "
cQuery += "		EK_BANCO = '"+cBanco+"' AND"
cQuery += "		EK_AGENCIA = '"+cAgencia+"' AND"
cQuery += "		EK_CONTA = '"+cConta+"' AND"

/*	Valida se existe algum documento na Ordem de Pago que possui
	algum Modo de Pago que não seja eletrônico */

cQuery += "		SEK.EK_ORDPAGO NOT IN (" 
cQuery += "			SELECT EK_ORDPAGO FROM "+RetSQLName("SEK")+" SEK2 "
cQuery += "				WHERE "
cQuery += "					SEK2.EK_FILIAL = '"+xFilial("SEK")+"' AND "
cQuery += "					SEK2.EK_ORDPAGO = SEK.EK_ORDPAGO AND "
cQuery += "					SEK2.EK_TIPODOC = 'CP' AND "
cQuery += "					SEK2.EK_PGTOELT = '2' "
cQuery += "		) AND "

/*	Valida se existe algum documento na Ordem de Pago que possui
	algum Modo de Pago que não seja eletrônico */ 

cQuery += "		SEK.EK_ORDPAGO NOT IN ("
cQuery += "			SELECT EK_ORDPAGO FROM "+RetSQLName("SEK")+" SEK3 "
cQuery += "				WHERE "
cQuery += "					SEK3.EK_FILIAL = '"+xFilial("SEK")+"' AND "
cQuery += "					SEK3.EK_ORDPAGO = SEK.EK_ORDPAGO AND "
cQuery += "					SEK3.EK_TIPODOC = 'CT' "
cQuery += "		) AND "

cQuery += "SEK.D_E_L_E_T_ = '' "

cQuery += "ORDER BY EK_ORDPAGO "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSEK,.F.,.T.)

//Cria o arquivo temporário
aAdd(aStruct,{"EK_FILIAL"	,"C"	,TamSX3("EK_FILIAL")[1]		,TamSX3("EK_FILIAL")[2]}	)
aAdd(aStruct,{"EK_ORDPAGO"	,"C"	,TamSX3("EK_ORDPAGO")[1]		,TamSX3("EK_ORDPAGO")[2]}	)
aAdd(aStruct,{"EK_VALOR"		,"N"	,TamSX3("EK_VALOR")[1]		,TamSX3("EK_VALOR")[2]}		)
aAdd(aStruct,{"EK_MOEDA"		,"C"	,TamSX3("EK_MOEDA")[1]		,TamSX3("EK_MOEDA")[2]}		)
aAdd(aStruct,{"EK_FORNECE"	,"C"	,TamSX3("EK_FORNECE")[1]		,TamSX3("EK_FORNECE")[2]}	)
aAdd(aStruct,{"EK_LOJA"		,"C"	,TamSX3("EK_LOJA")[1]		,TamSX3("EK_LOJA")[2]}		)
aAdd(aStruct,{"EK_DTDIGIT"	,"D"	,TamSX3("EK_DTDIGITO")[1]	,TamSX3("EK_DTDIGIT")[2]}	)
aAdd(aStruct,{"TMPOK"		,"C"	,TamSX3("E2_OK")[1]			,TamSX3("E2_OK")[2]}			)

If(_oFINA242 <> NIL)

	_oFINA242:Delete()
	_oFINA242 := NIL

EndIf

//Criando o objeto FwTemporaryTable
_oFINA242 := FwTemporaryTable():New(cAliasTmp)

//Setando a estrutura da tabela temporaria
_oFINA242:SetFields(aStruct)

//Criando o indicie da tabela temporaria
_oFINA242:AddIndex("1",{"EK_FILIAL","EK_ORDPAGO"})

//Criando a tabela temporaria
_oFINA242:Create()

//Alimenta o alias temporário com os dados da Query
dbSelectArea(cAliasSEK)
While !(cAliasSEK)->(Eof())

	cFilSEK 	:= (cAliasSEK)->EK_FILIAL
	cOrdPago	:= (cAliasSEK)->EK_ORDPAGO
	cFornece	:= (cAliasSEK)->EK_FORNECE	
	cLoja		:= (cAliasSEK)->EK_LOJA
	cMoedOP	:= (cAliasSEK)->EK_MOEDA
	dDtEmis	:= Stod((cAliasSEK)->EK_DTDIGIT)

	While cOrdPago == (cAliasSEK)->EK_ORDPAGO .And. !(cAliasSEK)->(Eof()) 
		nValOP		+= 	(cAliasSEK)->EK_VALOR
		(cAliasSEK)->(dbSkip())
	EndDo

	If nValOP >= cValorDe .And. nValOP <= cValorAte	
		dbSelectArea(cAliasTmp)
		RecLock(cAliasTmp,.T.)
			(cAliasTmp)->EK_FILIAL	:= cFilSEK
			(cAliasTmp)->EK_ORDPAGO	:= cOrdPago
			(cAliasTmp)->EK_FORNECE	:= cFornece
			(cAliasTmp)->EK_LOJA		:= cLoja	
			(cAliasTmp)->EK_VALOR	:= nValOP
			(cAliasTmp)->EK_MOEDA	:= cMoedOP
			(cAliasTmp)->EK_DTDIGIT	:= dDtEmis
			(cAliasTmp)->TMPOK 		:= ""
		(cAliasTmp)->(MsUnlock())
	EndIf
	
	nValOP := 0
		
EndDo

(cAliasSEK)->(dbCloseArea())

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F242DetOP
Função para exibição dos detalhes de uma Ordem de Pago

@author    Marcos Berto
@version   11.7
@since     10/09/2012

/*/
//------------------------------------------------------------------------------------------
Function F242DetOP(cOrdPago)

Local aDadosOP	:= {}

Local bOk
Local bCancel
Local bInitBr

Local cAliasSEK	:= GetNextAlias()
Local cQuery		:= ""

Local oDlgDet
Local oBrwDet

DEFAULT cOrdPago := ""

cQuery := "SELECT EK_FILIAL,EK_ORDPAGO,EK_VALOR,EK_TIPO,EK_NUM,EK_VENCTO "
cQuery += "	FROM "+RetSQLName("SEK")+" SEK "
cQuery += "	WHERE"
cQuery += "		SEK.EK_FILIAL = '"+xFilial("SEK")+"' AND "
cQuery += "		SEK.EK_ORDPAGO = '"+cOrdPago+"' AND "
cQuery += "		SEK.EK_TIPODOC NOT IN ('TB','PA','RG') AND "
cQuery += "		SEK.D_E_L_E_T_ = '' "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSEK,.F.,.T.)

dbSelectArea(cAliasSEK)
(cAliasSEK)->(dbGoTop())
While !(cAliasSEK)->(Eof())
	aAdd(aDadosOP,{(cAliasSEK)->EK_TIPO,(cAliasSEK)->EK_VALOR ,(cAliasSEK)->EK_NUM,Stod((cAliasSEK)->EK_VENCTO) })
	(cAliasSEK)->(dbSkip())
EndDo
(cAliasSEK)->(dbCloseArea())

If Len(aDadosOP) > 0
	oDlgDet := MsDialog():New( 0,0,200,400,"Detalhe da Ordem de Pago",,,,,,,,,.T.)
	
	dbSelectArea("SEK")	
	oBrwDet := TCBrowse():New(0,0,400,400,,,,oDlgDet,,,,,,,,,,,,,"",.T.,,,,,)
	oBrwDet:AddColumn(TcColumn():New(RetTitle("EK_TIPO")		,{|| aDadosOP[oBrwDet:nAt][1] }	,PesqPict("SEK","EK_TIPO")		,,,,TamSX3("EK_TIPO")[1]		,.F.,.F.,,,,,))
	oBrwDet:AddColumn(TcColumn():New("Valor"					,{|| aDadosOP[oBrwDet:nAt][2] }	,PesqPict("SEK","EK_VALOR")		,,,,TamSX3("EK_VALOR")[1]	,.F.,.F.,,,,,))
	oBrwDet:AddColumn(TcColumn():New(RetTitle("EK_NUM")		,{|| aDadosOP[oBrwDet:nAt][3] }	,PesqPict("SEK","EK_NUM")		,,,,TamSX3("EK_NUM")[1]		,.F.,.F.,,,,,))
	oBrwDet:AddColumn(TcColumn():New(RetTitle("EK_VENCTO")	,{|| aDadosOP[oBrwDet:nAt][4] }	,PesqPict("SEK","EK_VENCTO")	,,,,TamSX3("EK_VENCTO")[1]	,.F.,.F.,,,,,))
	oBrwDet:Align := CONTROL_ALIGN_ALLCLIENT
	oBrwDet:SetArray(aDadosOP)
	
	//Bloco a ser executado na confirmação do detalhe de Ordem de Pago
	bOk := {|| GetKeys() , SetKey( VK_F3 , Nil ), oDlgDet:End()}
	
	//Bloco a ser executado ao cancelar o detalhe de Ordem de Pago
	bCancel := {|| GetKeys() , SetKey( VK_F3 , Nil ), oDlgDet:End()}
	
	//Bloco para montagem da Enchoice da tela de detalhes de Ordem de Pago
	bInitBr := { || EnchoiceBar( oDlgDet , bOk , bCancel , Nil )}
	oDlgDet:bInit := bInitBr
	
	oDlgDet:Activate(,,,.T.)
Else
	Alert(STR0030) //"Não foram localizados os dados da Ordem de Pago."
EndIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F242InMkOP
Função para inverter marcação das Ordens de Pago que irão compor um Lote Financeiro

@author    Marcos Berto
@version   11.7
@since     10/09/2012

/*/
//------------------------------------------------------------------------------------------

Function F242InMkOP()

Local aAreaTmp := GetArea()

dbSelectArea(cAliasTmp)
(cAliasTmp)->(dbGoTop())	
While !(cAliasTmp)->(Eof())
	F242MrkOP()
	(cAliasTmp)->(dbSkip())	
EndDo

RestArea(aAreaTmp)

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F242MrkOP
Função para marcação das Ordens de Pago que irão compor um Lote Financeiro

@author    Marcos Berto
@version   11.7
@since     10/09/2012

/*/
//------------------------------------------------------------------------------------------
Function F242MrkOP()

If Type("cMarcaSEK") <> "U"
	If Empty(cMarcaSEK)
		cMarcaSEK := ""	
	EndIf
EndIf

If !(cAliasTmp)->(Eof())
	RecLock(cAliasTmp,.F.)
	If (cAliasTmp)->TMPOK == cMarcaSEK
		(cAliasTmp)->TMPOK := ""
	Else
		(cAliasTmp)->TMPOK := cMarcaSEK
	EndIf
	(cAliasTmp)->(MsUnlock())
EndIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F242Edit
Função que edita um lote financeiro 

@author    Marcos Berto
@version   11.7
@since     3/09/2012
/*/
//------------------------------------------------------------------------------------------
Function F242Edit()

Local aAux 		:= {}
Local aLote 		:= Array(6)

Local cAlias		:= GetNextAlias()
Local cQuery 		:= ""

Local cBanco 		:= FJB->FJB_BANCO
Local cAgencia 	:= FJB->FJB_AGENCI
Local cConta		:= FJB->FJB_CONTA
Local cNumLot		:= FJB->FJB_NUMLOT
Local cRetBco		:= FJB->FJB_BCORET

/*Recupera os detalhes do lote posicionado e monta a estrutura para exibição da tela
Lote:
	[1] Num. Lote
	[2] Banco
	[3] Agência
	[4] Conta
	[5] Ret. Banco? (1)Sim/(2)Não
	[6] Detalhes do Lote
		[6][1]	Filial
		[6][2]	Ordem de Pago
		[6][3]	Valor
		[6][4]	Moeda
		[6][5]	Fornecedor
		[6][6]	Loja
		[6][7]	Emissão
		[6][8] Status (1)Ativo/(2)Inativo */

If FJB->FJB_STATUS == "1"

	aLote[1] := cNumLot
	aLote[2] := cBanco
	aLote[3] := cAgencia
	aLote[4] := cConta
	aLote[5] := cRetBco
	aLote[6] := {} 
	
	cQuery := "SELECT FJC_STATUS,FJC_NUMFIN,EK_FILIAL,SUM(EK_VALOR) EK_VALOR,EK_MOEDA,EK_FORNECE,EK_LOJA,EK_DTDIGIT "
	cQuery += "	FROM "+RetSQLName("FJC")+" FJC, "+RetSQLName("SEK")+" SEK " 
	cQuery += "	WHERE "
	cQuery += "		FJC_FILIAL = '"+xFilial("FJC")+"' AND "
	cQuery += "		FJC_BANCO = '"+cBanco+"' AND "
	cQuery += "		FJC_AGENCI = '"+cAgencia+"' AND "
	cQuery += "		FJC_CONTA = '"+cConta+"' AND "
	cQuery += "		FJC_NUMLOT = '"+cNumLot+"' AND "
	cQuery += "		FJC_NUMFIN = EK_ORDPAGO AND "
	cQuery += "		EK_FILIAL = '"+xFilial("SEK")+"' AND "
	cQuery += "		EK_TIPODOC = 'CP' AND "
	cQuery += "		FJC.D_E_L_E_T_ = '' AND "
	cQuery += "		SEK.D_E_L_E_T_ = '' "
	cQuery += "	GROUP BY FJC_NUMFIN,FJC_STATUS,EK_FILIAL,EK_FORNECE,EK_LOJA,EK_MOEDA,EK_DTDIGIT "	

	If (cPaisLoc <> "RUS")
		cQuery := ChangeQuery(cQuery)
	Endif
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.F.,.T.)
	
	dbSelectArea(cAlias)
	
	While !(cAlias)->(Eof())	
		aAdd(aAux,(cAlias)->EK_FILIAL)
		aAdd(aAux,(cAlias)->FJC_NUMFIN)
		aAdd(aAux,(cAlias)->EK_VALOR)
		aAdd(aAux,(cAlias)->EK_MOEDA)
		aAdd(aAux,(cAlias)->EK_FORNECE)
		aAdd(aAux,(cAlias)->EK_LOJA)
		aAdd(aAux,(cAlias)->EK_DTDIGIT)
		aAdd(aAux,(cAlias)->FJC_STATUS)
		
		aAdd(aLote[6],aAux)
		aAux := {}
		(cAlias)->(dbSkip())			
	EndDo

	(cAlias)->(dbCloseArea())	

	//Exibe a tela do lote para edição
	F242Lote(aLote,2)

Else
	Alert(STR0031) //"Não é possível editar este lote."
EndIf

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F242Lote
Função para montagem da tela de lote

@author    Marcos Berto
@version   11.7
@since     10/09/2012

@param aLote 	Dados do lote
@param nOpc	Opção - (1)Inclusão/(2)Edição

/*/
//------------------------------------------------------------------------------------------
Function F242Lote(aLote,nOpc)

Local aButtons := {}
Local aField	 := {}

Local bOk
Local bCancel
Local bInitBr

Local lGrvOK := .T.

Local nX := 0

Local oDlgLot
Local oBrwLot

PRIVATE aDetail	:= {}
PRIVATE cBcoLot 	:= CriaVar("EK_BANCO")
PRIVATE cAgeLot 	:= CriaVar("EK_AGENCIA")
PRIVATE cCtaLot 	:= CriaVar("EK_CONTA")
PRIVATE cLote 	:= CriaVar("EK_NUMLOT")
PRIVATE cRetBco 	:= "2"

DEFAULT aLote := {}
DEFAULT nOpc	:= 0

/*Lote:
	[1] Num. Lote
	[2] Banco
	[3] Agência
	[4] Conta
	[5] Ret. Banco? (1)Sim/(2)Não
	[6] Detalhes do Lote
		[6][1]	Filial
		[6][2]	Ordem de Pago
		[6][3]	Valor
		[6][4]	Moeda
		[6][5]	Fornecedor
		[6][6]	Loja
		[6][7]	Emissão
		[6][8] Status (1)Ativo/(2)Inativo */

If Len(aLote) > 0

	cLote 		:= aLote[1]
	cBcoLot 	:= aLote[2]
	cAgeLot 	:= aLote[3]
	cCtaLot 	:= aLote[4]
	cRetBco 	:= aLote[5]
	aDetail 	:= aLote[6]

	If Len(aDetail) > 0
		oDlgLot := MsDialog():New( 0,0,550,900,STR0001,,,,,,,,,.T.) //"Lote Financeiro"
		
		//Painel do cabeçalho do lote
		oPnlCab := TPanel():New(01,01,,oDlgLot)
		oPnlCab:Align 	:= CONTROL_ALIGN_TOP		
		oPnlCab:nWidth	:= oDlgLot:nWidth	
		oPnlCab:nHeight	:= (oDlgLot:nHeight * 0.2)-30
		
		//Dados do Cabeçalho
		//Titulo ,Campo       ,Tipo,Tamanho                ,Decimal                ,Picture                     ,Valid                                                                                                ,Obrigat,Nivel,Inic Padrão,F3   ,When,Visual,Chave,Combo,Folder,Nao Alt,PictVar,Gatilho
		aAdd(aField,{RetTitle("EK_NUMLOT")	,"cLote"		,"C",TamSX3("EK_NUMLOT")[1],TamSX3("EK_NUMLOT")[2],PesqPict("SEK","EK_NUMLOT"),,.F.,1,,,,.T.,.F.,,,.F.,,})
		aAdd(aField,{RetTitle("EK_BANCO")	,"cBcoLot"		,"C",TamSX3("EK_BANCO")[1],TamSX3("EK_BANCO")[2],PesqPict("SEK","EK_BANCO"),,.F.,1,,,,.T.,.F.,,,.F.,,})
		aAdd(aField,{RetTitle("EK_AGENCI")	,"cAgeLot"		,"C",TamSX3("EK_AGENCIA")[1],TamSX3("EK_AGENCIA")[2],PesqPict("SEK","EK_AGENCIA"),,.F.,1,,,,.T.,.F.,,,.F.,,})
		aAdd(aField,{RetTitle("EK_CONTA")	,"cCtaLot"		,"C",TamSX3("EK_CONTA")[1],TamSX3("EK_CONTA")[2],PesqPict("SEK","EK_CONTA"),,.F.,1,,,,.T.,.F.,,,.F.,,})
		//Campo editável da tela - Mesmas propriedades conf. no SX3
		dbSelectArea("SX3")
		SX3->(dbSetOrder(2))
		If SX3->(dbSeek("FJB_BCORET"))
			aAdd(aField,{X3_TITULO,"cRetBco",X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_PICTURE,,.F.,1,,,,.F.,.F.,X3Cbox(),,.F.,,})
		EndIf
		
		oGetCab := MsMGet():New(,0,3,,,,,{000,000,oPnlCab:nHeight,oPnlCab:nWidth*0.05},,,,,,oPnlCab,,,,,,.T.,aField,,.T.)
		
		//Painel do detalhe do lote
		oPnlDet := TPanel():New(01,01,,oDlgLot)
		oPnlDet:Align := CONTROL_ALIGN_TOP		
		oPnlDet:nWidth	:= oDlgLot:nWidth	
		oPnlDet:nHeight	:= (oDlgLot:nHeight * 0.8) - 100
		
		//Browse com os detalhes do lote
		oBrwLot := TCBrowse():New(0,0,400,400,,,,oPnlDet,,,,,,,,,,,,,"",.T.,,,,.T.,)
		oBrwLot:AddColumn(TcColumn():New("",{|| LoadBitmap(GetResources(),F242LegOP(aDetail[oBrwLot:nAt][8])) },,,,,010,.T.,.F.,,,,,))
		oBrwLot:AddColumn(TcColumn():New(RetTitle("EK_ORDPAGO")	,{|| aDetail[oBrwLot:nAt][2] }	,PesqPict("SEK","EK_ORDPAGO")	,,,,TamSX3("EK_ORDPAGO")[1]+10	,.F.,.F.,,,,,))
		oBrwLot:AddColumn(TcColumn():New(STR0024 /*Valor*/		,{|| aDetail[oBrwLot:nAt][3] }	,PesqPict("SEK","EK_VALOR")		,,,,TamSX3("EK_VALOR")[1]+20	,.F.,.F.,,,,,))
		oBrwLot:AddColumn(TcColumn():New(RetTitle("EK_MOEDA")	,{|| aDetail[oBrwLot:nAt][4] }	,PesqPict("SEK","EK_MOEDA")		,,,,TamSX3("EK_MOEDA")[1]		,.F.,.F.,,,,,))
		oBrwLot:AddColumn(TcColumn():New(RetTitle("EK_FORNECE")	,{|| aDetail[oBrwLot:nAt][5] }	,PesqPict("SEK","EK_FORNECE")	,,,,TamSX3("EK_FORNECE")[1]		,.F.,.F.,,,,,))
		oBrwLot:AddColumn(TcColumn():New(RetTitle("EK_LOJA")		,{|| aDetail[oBrwLot:nAt][6] }	,PesqPict("SEK","EK_LOJA")		,,,,TamSX3("EK_LOJA")[1]			,.F.,.F.,,,,,))
		oBrwLot:AddColumn(TcColumn():New(RetTitle("EK_EMISSAO")	,{|| aDetail[oBrwLot:nAt][7] }	,PesqPict("SEK","EK_EMISSAO")	,,,,TamSX3("EK_EMISSAO")[1]		,.F.,.F.,,,,,))
		oBrwLot:Align := CONTROL_ALIGN_ALLCLIENT
		oBrwLot:SetArray(aDetail)
	
		//Bloco a ser executado na confirmação do Lote
		bOk := {|| GetKeys() , SetKey( VK_F3 , Nil ), lGrvOK := F242GrvLot(nOpc), Iif(lGrvOK,oDlgLot:End(),.F.)}
		
		//Bloco a ser executado ao cancelar a tela da montagem Lote
		bCancel := {|| GetKeys() , SetKey( VK_F3 , Nil ), oDlgLot:End()}
		
		//Inclui itens das Ações Relacionadas
		aAdd(aButtons,{"POSCLI",{|| F242DetOP(aLote[6][oBrwLot:nAt][2])},STR0022,STR0022}) //Detalhe OP
		aAdd(aButtons,{"SELECT",{|| F242AtvOP(aDetail[oBrwLot:nAt][2],nOpc,cLote),oBrwLot:Refresh()},STR0025,STR0025}) //Ativa/Inativa OP
		
		//Bloco para montagem da Enchoice da tela de seleção de Ordens de Pago
		bInitBr := { || EnchoiceBar( oDlgLot , bOk , bCancel , Nil , aButtons )}
		oDlgLot:bInit := bInitBr
		
		oDlgLot:Activate(,,,.T.)
	Else
		Alert(STR0032) //"Não há Ordens de Pago para compor um lote."	
	EndIf
Else
	Alert(STR0033) //"Não há dados para montagem do lote."
EndIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F242LegOP
Função para definição da legenda do detalhe do lote

@author    Marcos Berto
@version   11.7
@since     10/09/2012

@param cStatus 	Status do detalhe do Lote
@return cRet		String do bitmap da legenda

/*/
//------------------------------------------------------------------------------------------
Function F242LegOP(cStatus)

Local cRet := ""

DEFAULT cStatus := ""

If cStatus == "1" //Ativo
	cRet := "BR_VERDE"
ElseIf cStatus == "2" //Inativo
	cRet := "BR_VERMELHO"	
EndIf

Return cRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F242AtvOP
Função para ativar/inativar uma Ordem de Pago

@author    Marcos Berto
@version   11.7
@since     10/09/2012

@param COrdPago 	Cod. da Ordem de Pago
@param nOpcao 	Opção - (1)Inclusao/(2)Edição
@param cLote 		Número do Lote

/*/
//------------------------------------------------------------------------------------------
Function F242AtvOP(cOrdPago,nOpcao,cLote)

Local aAreaSEK := {}
Local nPosOP	 := 0

DEFAULT cOrdPago	:= ""
DEFAULT nOpcao	:= 0
DEFAULT cLote		:= ""

If Type("aDetail") == "A"
	
	nPosOP := Ascan(aDetail,{|x| AllTrim(x[2]) == AllTrim(cOrdPago)})
	
	If nPosOP > 0
		dbSelectArea("SEK")
		aAreaSEK := SEK->(GetArea())
		SEK->(dbGoTop())
		SEK->(dbSetOrder(1))
		If SEK->(dbSeek(aDetail[nPosOP][1]+aDetail[nPosOP][2]))
			If (nOpcao = 1 .And. Empty(SEK->EK_NUMLOT)) .Or.;
				(nOpcao = 2 .And. (SEK->EK_NUMLOT == cLote .Or. Empty(SEK->EK_NUMLOT)))
				If aDetail[nPosOP][8] == "1"
					aDetail[nPosOP][8] := "2" //Inativa
				ElseIf aDetail[nPosOP][8] == "2"
					aDetail[nPosOP][8] := "1" //Ativa	
				EndIf	
			Else
				Alert(STR0026+SEK->EK_NUMLOT) //Não é possivel manipular a OP, pois a mesma compoe o lote 
			EndIf	
		EndIf
		RestArea(aAreaSEK)
	EndIf
EndIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F242GrvLot
Função para gravação do lote

@author    Marcos Berto
@version   11.7
@since     11/09/2012

@param  nOpc	Opção - (1)Inclusão/(2)Edição
@return lRet	Status da Gravação

/*/
//------------------------------------------------------------------------------------------
Function F242GrvLot(nOpc)

Local aDados := {} 

Local lOK		:= .F.
Local lRet		:= .T.

Local nX		:= 0
Local nOPVld	:= 0
Local nPosOP	:= 0

DEFAULT nOpc 	:= 0

//Valida os dados do cabeçalho
cLote 		:= Iif(Type("cLote") <> "U",cLote,"") 
cBcoLot 	:= Iif(Type("cBcoLot") <> "U",cBcoLot,"")  
cAgeLot 	:= Iif(Type("cAgeLot") <> "U",cAgeLot,"") 
cCtaLot 	:= Iif(Type("cCtaLot") <> "U",cCtaLot,"") 
cRetBco 	:= Iif(Type("cRetBco") <> "U",cRetBco,"2") 

//Valida se existem dados para gravação
If Type("aDetail") == "A"
	For nX := 1 to Len(aDetail)
		If aDetail[nX][8] == "1"
			nOPVld++	
		EndIf
	Next nX
EndIf

If 	nOPVld > 0 .And. !Empty(cLote) .And. !Empty(cBcoLot) .And. !Empty(cAgeLot) .And. !Empty(cCtaLot)

	Begin Transaction 
		
		If nOpc  = 1 //inclusao
		
			//Grava o cabeçalho do lote
			dbSelectArea("FJB")
			RecLock("FJB",.T.)
			FJB->FJB_FILIAL 	:= xFilial("FJB")
			FJB->FJB_BANCO	:= cBcoLot
			FJB->FJB_AGENCI	:= cAgeLot
			FJB->FJB_CONTA	:= cCtaLot
			FJB->FJB_NUMLOT	:= cLote
			FJB->FJB_DATLOT	:= dDataBase
			FJB->FJB_ARQID	:= ""
			FJB->FJB_BCORET	:= cRetBco
			FJB->FJB_STATUS	:= "1" //Ativa
			FJB->(MsUnlock())
			
			dbSelectArea("FJC")
			For nX := 1 to Len(aDetail) 
				
				//Grava os detalhes do lote
				RecLock("FJC",.T.)
				FJC->FJC_FILIAL 	:= xFilial("FJC") 
				FJC->FJC_BANCO	:= cBcoLot
				FJC->FJC_AGENCI	:= cAgeLot
				FJC->FJC_CONTA	:= cCtaLot
				FJC->FJC_NUMLOT	:= cLote
				FJC->FJC_NUMFIN	:= aDetail[nX][2]
				FJC->FJC_STATUS	:= aDetail[nX][8]
				FJC->(MsUnlock())
			
				//Atualiza a Ordem de Pago com o numero do lote
				If aDetail[nX][8] == "1"
					dbSelectArea("SEK")
					SEK->(dbSetOrder(1))
					If SEK->(dbSeek(aDetail[nX][1]+aDetail[nX][2]))
						While !SEK->(Eof()) .And. SEK->EK_FILIAL == aDetail[nX][1] .And. SEK->EK_ORDPAGO == aDetail[nX][2]
							If SEK->EK_TIPODOC $  "CP|TB" //Atualiza os títulos baixados e os documentos próprios
								RecLock("SEK",.F.)
								SEK->EK_NUMLOT := cLote
								SEK->(MsUnlock())
								
								//Atualiza o título a pagar
								If SEK->EK_TIPODOC == "TB"
									dbSelectArea("SE2")
									SE2->(dbSetOrder(1))
									If SE2->(dbSeek(xFilial("SE2")+SEK->EK_PREFIXO+SEK->EK_NUM+SEK->EK_PARCELA+SEK->EK_TIPO+SEK->EK_FORNECE+SEK->EK_LOJA))	
										RecLock("SE2",.F.)
										SE2->E2_NUMBOR := cLote
										SE2->(MsUnlock())
									EndIf
								EndIf
								
								dbSelectArea("SEK")
								
							EndIf
							SEK->(dbSkip())
						EndDo			
					EndIf
				EndIf
				
			Next nX
			
			//Confirma a numeração do lote
			ConfirmSX8()
		
		ElseIf nOpc = 2 //Edição
			dbSelectArea("FJB")
			RecLock("FJB",.F.)
			FJB->FJB_BCORET	:= cRetBco
			FJB->(MsUnlock())	
			
			dbSelectArea("FJC")
			FJC->(dbSetOrder(1))
			If FJC->(dbSeek(xFilial("FJC")+cBcoLot+cAgeLot+cCtaLot+cLote))
				While !FJC->(Eof()) .And. FJC->FJC_FILIAL == xFilial("FJC") .And.; 
						FJC->FJC_BANCO == cBcoLot .And. FJC->FJC_AGENCI == cAgeLot .And.;
						FJC->FJC_CONTA == cCtaLot .And. FJC->FJC_NUMLOT == cLote
						
					nPosOP := aScan(aDetail,{|x| AllTrim(x[2]) == AllTrim(FJC->FJC_NUMFIN)})
					
					If nPosOP > 0
						RecLock("FJC",.F.)
						FJC->FJC_STATUS := aDetail[nPosOP][8]
						FJC->(MsUnlock())
						
						//Ajusta a amarração com a Ordem de Pago
						dbSelectArea("SEK")
						SEK->(dbSetOrder(1))
						If SEK->(dbSeek(xFilial("SEK")+FJC->FJC_NUMFIN))
							While !SEK->(Eof()) .And. SEK->EK_FILIAL == xFilial("SEK") .And.;
									SEK->EK_ORDPAGO == FJC->FJC_NUMFIN .And. SEK->EK_TIPODOC == "CP|TB|PA"
								
								RecLock("SEK",.F.)
								If FJC->FJC_STATUS == "1"
									SEK->EK_NUMLOT := FJC->FJC_NUMLOT
								ElseIf FJC->FJC_STATUS == "2"
									SEK->EK_NUMLOT := ""		
								EndIf
								SEK->(MsUnlock())
								SEK->(dbSkip())
								
							EndDo
						EndIf
					EndIf
					FJC->(dbSkip())	
				EndDo
			EndIf	
			
		EndIf
		
	End Transaction
Else
	Alert(STR0034+" "+STR0035)  //Não há dados para gravação deste lote. Verifique se existem Ordens de Pago ativas.
	lRet := .F.
EndIf

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F242DesLot
Função para ativar/inativar lotes financeiros

@author    Marcos Berto
@version   11.7
@since     11/09/2012

/*/
//------------------------------------------------------------------------------------------
Function F242DesLot()

Local cBanco 		:= FJB->FJB_BANCO
Local cAgencia 	:= FJB->FJB_AGENCI
Local cConta		:= FJB->FJB_CONTA
Local cNumLot		:= FJB->FJB_NUMLOT
Local cRecLot		:= ""

dbSelectArea("FJB")
FJB->(dbSetOrder(1))
If FJB->(dbSeek(xFilial("FJB")+cBanco+cAgencia+cConta+cNumLot))
	Begin Transaction 
		
		//Inativa o Lote
		RecLock("FJB",.F.)
		If FunName() == "FINA242"
			FJB->FJB_STATUS := "2" //Inativa
		Else
			//Inativa o lote por erro de processamento (banco ou sistemico)
			FJB->FJB_STATUS := "5" //Inativa por Erro	
		EndIf
		FJB->(MsUnlock())
		
		//Inativa os itens do lote
		dbSelectArea("FJC")
		FJC->(dbSetOrder(1))
		If FJC->(dbSeek(xFilial("FJC")+cBanco+cAgencia+cConta+cNumLot))
			While !FJC->(Eof()) .And. FJC->FJC_FILIAL == xFilial("FJC") .And.; 
					FJC->FJC_BANCO == cBanco .And. FJC->FJC_AGENCI == cAgencia .And.;
					FJC->FJC_CONTA == cConta .And. FJC->FJC_NUMLOT == cNumLot
					
				RecLock("FJC",.F.)
				FJC->FJC_STATUS := "2" //Inativa
				FJC->(MsUnlock())
				
				//Desfaz a amarração com a Ordem de Pago
				dbSelectArea("SEK")
				SEK->(dbSetOrder(1))
				If SEK->(dbSeek(xFilial("SEK")+FJC->FJC_NUMFIN))
					While !SEK->(Eof()) .And. SEK->EK_FILIAL == xFilial("SEK") .And.;
							SEK->EK_ORDPAGO == FJC->FJC_NUMFIN .And. SEK->EK_TIPODOC $ "CP|TB|PA"
						
						RecLock("SEK",.F.)
						SEK->EK_NUMLOT := ""
						SEK->(MsUnlock())
						
						//Atualiza o título a pagar
						If SEK->EK_TIPODOC == "TB"
							dbSelectArea("SE2")
							SE2->(dbSetOrder(1))
							If SE2->(dbSeek(xFilial("SE2")+SEK->EK_PREFIXO+SEK->EK_NUM+SEK->EK_PARCELA+SEK->EK_TIPO+SEK->EK_FORNECE+SEK->EK_LOJA))	
								
								//Recupera o número do último lote, caso o título esteja em mais de um lote
								cRecLot := F242RecLot(SEK->EK_PREFIXO,SEK->EK_NUM,SEK->EK_PARCELA,SEK->EK_TIPO,SEK->EK_FORNECE,SEK->EK_LOJA)
								
								RecLock("SE2",.F.)
								SE2->E2_NUMBOR := cRecLot
								SE2->(MsUnlock())
							EndIf
						EndIf
						
						dbSelectArea("SEK")
						SEK->(dbSkip())
						
					EndDo
				EndIf
				FJC->(dbSkip())	
			EndDo
		EndIf	
	End Transaction
EndIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F242RecLot
Verifica se um título pertence à mais de uma Ordem de Pago em Lote 

@author    Marcos Berto
@version   11.7
@since     24/09/2012

@param cPrefix	Prefixo do Título
@param cNum		Número do Título
@param cParcel	Parcela do Título
@param cTipo 		Tipo do Título
@param cFornece	Fornece do Título
@param cLoja		Loja do Título

@return cLote		Lote encontrado para o título


/*/
//------------------------------------------------------------------------------------------
Function F242RecLot(cPrefix,cNum,cParcel,cTipo,cFornece,cLoja)

Local aAreaSEK 	:= {}
Local cLote 		:= ""
Local nRecSEK 	:= 0

dbSelectArea("SEK")
aAreaSEK := SEK->(GetArea())
nRecSEK  := SEK->(Recno())
SEK->(dbSetOrder(6))
If SEK->(dbSeek(xFilial("SEK")+cPrefix+cNum+cParcel+cTipo+cFornece+cLoja))
	While !SEK->(Eof()) .And. SEK->EK_FILIAL = xFilial("SEK") .And.;
			SEK->EK_PREFIXO == cPrefix .And. SEK->EK_NUM == cNum .And.;
			SEK->EK_PARCELA == cParcel .And. SEK->EK_TIPO == cTipo .And.;
			SEK->EK_FORNECE == cFornece .And. SEK->EK_LOJA == cLoja
		
		If SEK->EK_TIPODOC == "TB" .And. !Empty(SEK->EK_NUMLOT)
			cLote := SEK->EK_NUMLOT
			Exit	
		EndIf
		
		SEK->(dbSkip())
			
	EndDo
EndIf

SEK->(RestArea(aAreaSEK))
SEK->(dbGoTo(nRecSEK))

Return cLote

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F242EftLot
Função responsavel por efetuar as movimentação pendentes de Ordens de Pago de forma manual,
quando não houver retorno do banco.  

@author    Marcos Berto
@version   11.7
@since     24/09/2012
/*/
//------------------------------------------------------------------------------------------
Function F242EftLot()

Local aButtons 		:= {}
Local aLotes			:= {}

Local bOk
Local bCancel
Local bInitBr

Local oOk
Local oNOk
Local oDlgLot
Local oBrwSelLot

Private cAliasTmp 	:= GetNextAlias()
Private cMarcaLot 	:= GetMark()

//Filtra os lotes pendentes de efetivação
F242FilLot()

dbSelectArea(cAliasTmp)
(cAliasTmp)->(dbGoTop())

If !(cAliasTmp)->(Eof())
	
	//Define os objetos para montagem da seleção no browse
	oOk  := LoadBitmap(GetResources(),"wfchk")
	oNOk := LoadBitmap(GetResources(),"wfunchk")

	oDlgLot := MsDialog():New( 0,0,400,700,STR0027,,,,,,,,,.T.) //Efetivação de Lotes
	
	oBrwSelLot := TCBrowse():New(0,0,400,400,,,,oDlgLot,,,,,{|| F242MrkLot() },,,,,,,,cAliasTmp,.T.,,,,.T.,)
	oBrwSelLot:AddColumn(TcColumn():New("",{|| Iif((cAliasTmp)->TMPOK == cMarcaLot,oOK,oNOK)},,,,,010,.T.,.F.,,,,,))
	oBrwSelLot:AddColumn(TcColumn():New(RetTitle("FJB_NUMLOT")	,{|| (cAliasTmp)->FJB_NUMLOT  }	,PesqPict("FJB","FJB_NUMLOT")	,,,,TamSX3("FJB_NUMLOT")[1]	,.F.,.F.,,,,,))
	oBrwSelLot:AddColumn(TcColumn():New(RetTitle("EK_VALOR")	,{|| (cAliasTmp)->FJB_VALOR   }	,PesqPict("SEK","EK_VALOR")		,,,,TamSX3("EK_VALOR")[1]	,.F.,.F.,,,,,))
	oBrwSelLot:AddColumn(TcColumn():New(RetTitle("FJB_BANCO")	,{|| (cAliasTmp)->FJB_BANCO   }	,PesqPict("FJB","FJB_BANCO")	,,,,TamSX3("FJB_BANCO")[1]	,.F.,.F.,,,,,))
	oBrwSelLot:AddColumn(TcColumn():New(RetTitle("FJB_AGENCI")	,{|| (cAliasTmp)->FJB_AGENCIA }	,PesqPict("FJB","FJB_AGENCI")	,,,,TamSX3("FJB_AGENCI")[1]	,.F.,.F.,,,,,))
	oBrwSelLot:AddColumn(TcColumn():New(RetTitle("FJB_CONTA")	,{|| (cAliasTmp)->FJB_CONTA   }	,PesqPict("FJB","FJB_CONTA")	,,,,TamSX3("FJB_CONTA")[1]	,.F.,.F.,,,,,))
	oBrwSelLot:Align := CONTROL_ALIGN_ALLCLIENT

	//Bloco a ser executado na confirmação da seleção de Lotes
	bOk := {|| GetKeys() , SetKey( VK_F3 , Nil ), MsgRun(STR0038,STR0001,{|| F242GrvEft()}), oDlgLot:End()}
	
	//Bloco a ser executado ao cancelar a seleção de Lotes
	bCancel := {|| GetKeys() , SetKey( VK_F3 , Nil ), oDlgLot:End()}
	
	//Inclui itens das Ações Relacionadas
	aAdd(aButtons,{"PENDENTE"	,{|| F242InMkLt()},STR0021,STR0021}) //Inverte Seleção
	
	//Bloco para montagem da Enchoice da tela de seleção de Lotes
	bInitBr := { || EnchoiceBar( oDlgLot , bOk , bCancel , Nil , aButtons )}
	oDlgLot:bInit := bInitBr
	
	oDlgLot:Activate(,,,.T.)
	
Else
	Alert(STR0036) //Não existem lotes pendentes de efetivação.
EndIf

If(_oFINA242 <> NIL)

	_oFINA242:Delete()
	_oFINA242 := NIL

EndIf
If(_oFINA242A <> NIL)

	_oFINA242A:Delete()
	_oFINA242A := NIL

EndIf
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F242FilLot
Função paa filtro dos lotes pendentes de efetivação

@author    Marcos Berto
@version   11.7
@since     24/09/2012
/*/
//------------------------------------------------------------------------------------------
Function F242FilLot()

Local aStruct 	:= {}

Local cAliasLot	:= GetNextAlias()
Local cQuery 		:= ""
Local cArqTemp	:= ""

cQuery := "SELECT FJB.FJB_FILIAL, FJB.FJB_NUMLOT, SUM(SEK.EK_VALOR) AS FJB_VALOR, FJB_BANCO, FJB.FJB_AGENCI, FJB.FJB_CONTA FROM " + RetSQLName("SEK") + " SEK, " + RetSQLName("FJB") + " FJB"
cQuery += " WHERE SEK.EK_FILIAL = '" + xFilial("SEK") + "'"
cQuery += " AND FJB.FJB_FILIAL = '" + xFilial("FJB") + "'"
cQuery += " AND SEK.EK_BANCO = FJB.FJB_BANCO"
cQuery += " AND SEK.EK_AGENCIA = FJB.FJB_AGENCI"
cQuery += " AND SEK.EK_CONTA = FJB.FJB_CONTA"
cQuery += " AND SEK.EK_NUMLOT = FJB.FJB_NUMLOT"
cQuery += " AND SEK.EK_NUMLOT <> ''"
cQuery += " AND FJB.FJB_BCORET = '2'"
cQuery += " AND FJB.FJB_STATUS = '1'"
cQuery += " AND SEK.D_E_L_E_T_ = ''"
cQuery += " AND FJB.D_E_L_E_T_ = ''"
cQuery += " GROUP BY FJB.FJB_FILIAL, FJB.FJB_NUMLOT, FJB_BANCO, FJB.FJB_AGENCI, FJB.FJB_CONTA"

If (cPaisLoc <> "RUS")
	cQuery := ChangeQuery(cQuery)
Endif
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasLot,.F.,.T.)

//Cria o arquivo temporário
aAdd(aStruct,{"FJB_FILIAL"	,"C"	,TamSX3("FJB_FILIAL")[1]	,TamSX3("FJB_FILIAL")[2]}	)
aAdd(aStruct,{"FJB_NUMLOT"	,"C"	,TamSX3("FJB_NUMLOT")[1]	,TamSX3("FJB_NUMLOT")[2]}	)
aAdd(aStruct,{"FJB_VALOR"	,"N"	,TamSX3("EK_VALOR")[1]		,TamSX3("EK_VALOR")[2]}		)
aAdd(aStruct,{"FJB_BANCO"	,"C"	,TamSX3("FJB_BANCO")[1]		,TamSX3("FJB_BANCO")[2]}	)
aAdd(aStruct,{"FJB_AGENCI"	,"C"	,TamSX3("FJB_AGENCI")[1]	,TamSX3("FJB_AGENCI")[2]}	)
aAdd(aStruct,{"FJB_CONTA"	,"C"	,TamSX3("FJB_CONTA")[1]		,TamSX3("FJB_CONTA")[2]}	)
aAdd(aStruct,{"TMPOK"		,"C"	,TamSX3("E2_OK")[1]			,TamSX3("E2_OK")[2]}		)

Begin Transaction
	
	//Criando o objeto FwTemporaryTable
	_oFINA242A := FwTemporaryTable():New(cAliastmp)

	//Setando a estrutura da tabela temporaria
	_oFINA242A:SetFields(aStruct)

	//criando o indicie da tabela temporaria
	_oFINA242A:AddIndex("1",{"FJB_FILIAL","FJB_BANCO","FJB_AGENCI","FJB_CONTA","FJB_NUMLOT"})

	//Criando a Tabela temporaria
	_oFINA242A:Create()

	dbSelectArea(cAliasLot)
	(cAliasLot)->(dbGoTop())
	While !(cAliasLot)->(Eof())
		Reclock(cAliasTmp,.T.)
		(cAliasTmp)->FJB_FILIAL 	:= (cAliasLot)->FJB_FILIAL 
		(cAliasTmp)->FJB_NUMLOT 	:= (cAliasLot)->FJB_NUMLOT
		(cAliasTmp)->FJB_VALOR 	:= (cAliasLot)->FJB_VALOR
		(cAliasTmp)->FJB_BANCO 	:= (cAliasLot)->FJB_BANCO
		(cAliasTmp)->FJB_AGENCI	:= (cAliasLot)->FJB_AGENCIA
		(cAliasTmp)->FJB_CONTA 	:= (cAliasLot)->FJB_CONTA
		(cAliasTmp)->TMPOK 		:= ""
		(cAliasTmp)->(MsUnlock())
		
		(cAliasLot)->(dbSkip())	
	EndDo
End Transaction

(cAliasLot)->(dbCloseArea())

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F250InMkLt
Função que inverte a seleção dos lotes

@author    Marcos Berto
@version   11.7
@since     24/09/2012
/*/
//------------------------------------------------------------------------------------------
Function F242InMkLt()

Local aAreaTmp := GetArea()

dbSelectArea(cAliasTmp)
(cAliasTmp)->(dbGoTop())	
While !(cAliasTmp)->(Eof())
	F242MrkLot()
	(cAliasTmp)->(dbSkip())	
EndDo

RestArea(aAreaTmp)

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F242MrkLot
Função que efetua marcação de um lote

@author    Marcos Berto
@version   11.7
@since     24/09/2012
/*/
//------------------------------------------------------------------------------------------
Function F242MrkLot()

If Type("cMarcaLot") <> "U"
	If Empty(cMarcaLot)
		cMarcaLot := ""	
	EndIf
EndIf

If !(cAliasTmp)->(Eof())
	RecLock(cAliasTmp,.F.)
	If (cAliasTmp)->TMPOK == cMarcaLot
		(cAliasTmp)->TMPOK := ""
	Else
		(cAliasTmp)->TMPOK := cMarcaLot
	EndIf
	(cAliasTmp)->(MsUnlock())
EndIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F242GrvEft
Função que efetua a gravação dos lotes selecionados

@author    Marcos Berto
@version   11.7
@since     24/09/2012
/*/
//------------------------------------------------------------------------------------------
Function F242GrvEft()

If Pergunte("FIN310C",.T.)
	(cAliasTmp)->(dbGoTop())
	While !(cAliasTmp)->(Eof())
		If (cAliasTmp)->TMPOK == cMarcaLot
			dbSelectArea("FJB")
			FJB->(dbSetOrder(1))
			FJB->(dbGoTop())
			If FJB->(dbSeek(xFilial("FJB")+(cAliasTmp)->FJB_BANCO+(cAliasTmp)->FJB_AGENCIA+(cAliasTmp)->FJB_CONTA+(cAliasTmp)->FJB_NUMLOT))
				F310EftLot((cAliasTmp)->FJB_BANCO,(cAliasTmp)->FJB_AGENCIA,(cAliasTmp)->FJB_CONTA,(cAliasTmp)->FJB_NUMLOT,.F.)
			EndIf
		EndIf
		(cAliasTmp)->(dbSkip())
	EndDo
EndIf

Return
