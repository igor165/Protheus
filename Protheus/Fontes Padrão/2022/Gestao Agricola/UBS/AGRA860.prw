#INCLUDE "AGRA860.CH"
#INCLUDE "PROTHEUS.CH"
#Include "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

Static oArqTemp   := Nil
Static __oOBrowse := Nil
/*/{Protheus.doc} AGRA860
Programação de Entrega
@author joaquim.burjack
@since 22/12/2016
@version undefined
 
@type function
/*/
Function AGRA860()
	Local oBrowse  	 := Nil
	Local bKeyF12    := {||AG860PERG()}
	Local aSeek      := {}
	Local aFieFilter := {}

	Local nX         := 0

	Private _cAliasTRB  := ""
	Private _aTPTB      := {}	
	Private _aCpsBrwPE  := {}

	If ExistBlock('AGRA860CPO')
		_aCpsBrwPE := ExecBlock('AGRA860CPO',.F.,.F.,_aCpsBrwPE)
	EndIf

	SetKey( VK_F12, bKeyF12)
	Pergunte('AGRA860', .T.)

	//Monta a estrutura da tabela temporária
	AGRA860STT()

	//Monta tabela temporaria
	AGRA860TRB()

	Aadd(aSeek,{"Filial+Pedido" ,{{"", TamSX3("C9_PEDIDO")[3] , TamSX3("C9_FILIAL")[1]+TamSX3("C9_PEDIDO")[1] , TamSX3("C9_PEDIDO")[2] , PesqPict("SC9","C9_PEDIDO") }}, 2, .T. } )

	//Campos que irão compor a tela de filtro
	Aadd(aFieFilter,{"FILIAL"   , "Filial"     , TamSX3("C9_FILIAL")[3]  , TamSX3("C9_FILIAL")[1]  , TamSX3("C9_FILIAL")[2]  ,PesqPict("SC9","C9_FILIAL") })
	Aadd(aFieFilter,{"PEDIDO"   , "Pedido"     , TamSX3("C9_PEDIDO")[3]  , TamSX3("C9_PEDIDO")[1]  , TamSX3("C9_PEDIDO")[2]  ,PesqPict("SC9","C9_PEDIDO") })
	Aadd(aFieFilter,{"ITEM"     , "Item"       , TamSX3("C9_ITEM")[3]    , TamSX3("C9_ITEM")[1]    , TamSX3("C9_ITEM")[2]    ,PesqPict("SC9","C9_ITEM")})
	Aadd(aFieFilter,{"SEQUENCIA", "Sequencia"  , TamSX3("C9_SEQUEN")[3]  , TamSX3("C9_SEQUEN")[1]  , TamSX3("C9_SEQUEN")[2]  ,PesqPict("SC9","C9_SEQUEN")})
	Aadd(aFieFilter,{"PRODUTO"  , "Produto"    , TamSX3("C9_PRODUTO")[3] , TamSX3("C9_PRODUTO")[1] , TamSX3("C9_PRODUTO")[2] ,PesqPict("SC9","C9_PRODUTO")})
	Aadd(aFieFilter,{"CLIENTE"  , "Cliente"    , TamSX3("C6_CLI")[3]     , TamSX3("C6_CLI")[1]     , TamSX3("C6_CLI")[2]     ,PesqPict("SC6","C6_CLI")})
	Aadd(aFieFilter,{"LOJA"     , "Loja"       , TamSX3("C6_LOJA")[3]    , TamSX3("C6_LOJA")[1]    , TamSX3("C6_LOJA")[2]    ,PesqPict("SC6","C6_LOJA")})
	Aadd(aFieFilter,{"NOME"     , "Nome"       , TamSX3("A1_NOME")[3]    , TamSX3("A1_NOME")[1]    , TamSX3("A1_NOME")[2]    ,PesqPict("SA1","A1_NOME")})
	Aadd(aFieFilter,{"MUNICIPIO", "Município"  , TamSX3("A1_MUN")[3]     , TamSX3("A1_MUN")[1]     , TamSX3("A1_MUN")[2]     ,PesqPict("SA1","A1_MUN")})
	Aadd(aFieFilter,{"VENDEDOR" , "Vendedor"   , TamSX3("C5_VEND1")[3]   , TamSX3("C5_VEND1")[1]   , TamSX3("A1_EST")[2]     ,PesqPict("SA1","A1_EST")})
	Aadd(aFieFilter,{"UF"       , "UF"         , TamSX3("A1_EST")[3]     , TamSX3("A1_EST")[1]     , TamSX3("C5_VEND1")[2]   ,PesqPict("SC5","C5_VEND1")})
	Aadd(aFieFilter,{"TPFRETE"  , "Tipo Frete" , TamSX3("C5_TPFRETE")[3] , TamSX3("C5_TPFRETE")[1] , TamSX3("C5_TPFRETE")[2] ,PesqPict("SC5","C5_TPFRETE")})
	Aadd(aFieFilter,{"CULTURA"  , "Cultura"    , TamSX3("C6_CULTRA")[3]  , TamSX3("C6_CULTRA")[1]  , TamSX3("C6_CULTRA")[2]  ,PesqPict("SC6","C6_CULTRA")})
	Aadd(aFieFilter,{"CULTIVAR" , "Cultivar"   , TamSX3("C6_CTVAR")[3]   , TamSX3("C6_CTVAR")[1]   , TamSX3("C6_CTVAR")[2]   ,PesqPict("SC6","C6_CTVAR")})
	Aadd(aFieFilter,{"CATEGORIA", "Categoria"  , TamSX3("C6_CATEG")[3]   , TamSX3("C6_CATEG")[1]   , TamSX3("C6_CATEG")[2]   ,PesqPict("SC6","C6_CATEG")})
	Aadd(aFieFilter,{"PENEIRA"  , "Peneira"    , TamSX3("C6_PENE")[3]    , TamSX3("C6_PENE")[1]    , TamSX3("C6_PENE")[2]    ,PesqPict("SC6","C6_PENE")})
	Aadd(aFieFilter,{"LOCAL"    , "Local"      , TamSX3("C6_LOCAL")[3]   , TamSX3("C6_LOCAL")[1]   , TamSX3("C6_LOCAL")[2]   ,PesqPict("SC6","C6_LOCAL")})
	Aadd(aFieFilter,{"SAFRA"    , "Safra"      , TamSX3("C5_CODSAF")[3]  , TamSX3("C5_CODSAF")[1]  , TamSX3("C5_CODSAF")[2]  ,PesqPict("SC5","C5_CODSAF")})
	Aadd(aFieFilter,{"QTDVEN"   , "Qtd Vendida", TamSX3("C6_QTDVEN")[3]  , TamSX3("C6_QTDVEN")[1]  , TamSX3("C6_QTDVEN")[2]  ,PesqPict("SC6","C6_QTDVEN")})
	Aadd(aFieFilter,{"QTDVEN2"  , "Qtd Vend2"  , TamSX3("C6_UNSVEN")[3]  , TamSX3("C6_UNSVEN")[1]  , TamSX3("C6_UNSVEN")[2]  ,PesqPict("SC6","C6_UNSVEN")})
	Aadd(aFieFilter,{"QTDLIB"   , "Qtd Lib"    , TamSX3("C9_QTDLIB")[3]  , TamSX3("C9_QTDLIB")[1]  , TamSX3("C9_QTDLIB")[2]  ,PesqPict("SC9","C9_QTDLIB")})
	Aadd(aFieFilter,{"QTDLIB2"  , "Qtd Lib2"   , TamSX3("C9_QTDLIB2")[3] , TamSX3("C9_QTDLIB2")[1] , TamSX3("C9_QTDLIB2")[2] ,PesqPict("SC9","C9_QTDLIB2")})
	Aadd(aFieFilter,{"UM"       , "Un. medida" , TamSX3("C6_UM")[3]      , TamSX3("C6_UM")[1]      , TamSX3("C6_UM")[2]      ,PesqPict("SC6","C6_UM")})
	Aadd(aFieFilter,{"UM2"      , "Un. med. 2" , TamSX3("C6_SEGUM")[3]   , TamSX3("C6_SEGUM")[1]   , TamSX3("C6_SEGUM")[2]   ,PesqPict("SC6","C6_SEGUM")})
	Aadd(aFieFilter,{"DTPROG"   , "Data Prog"  , TamSX3("NJ5_DTPROG")[3] , TamSX3("NJ5_DTPROG")[1] , TamSX3("NJ5_DTPROG")[2] ,PesqPict("NJ5","NJ5_DTPROG")})
	Aadd(aFieFilter,{"DTPREV"   , "Data Prev"  , TamSX3("C9_DATENT")[3]  , TamSX3("C9_DATENT")[1]  , TamSX3("C9_DATENT")[2]  ,PesqPict("SC9","C9_DATENT")})

	//tratamento campos adicionais
	for nX := 1 to len(_aCpsBrwPE)

		if !Empty( TamSx3( _aCpsBrwPE[nX] ) )
			Aadd(aFieFilter,{"Z"+STRTRAN(_aCpsBrwPE[nX], "_", "")   , RetTitle(_aCpsBrwPE[nX]) , TamSX3(_aCpsBrwPE[nX])[3]  , TamSX3(_aCpsBrwPE[nX])[1]  , TamSX3(_aCpsBrwPE[nX])[2]  ,X3PICTURE(_aCpsBrwPE[nX])})
		endif

	next nX

	(_cAliasTRB) -> (DbSetOrder(1))

	//Instancia o objeto Browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetTemporary(.T.)
	oBrowse:SetAlias(_cAliasTRB)
	oBrowse:SetProfileID(AllTrim("AGRA860"))
	oBrowse:SetDescription( STR0001 ) //Programação de entrega
	oBrowse:SetMenuDef("AGRA860")
	oBrowse:SetSeek(.T.,aSeek)
	oBrowse:DisableDetails()
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetUseCaseFilter(.T.)
	oBrowse:SetFieldFilter(aFieFilter)
	oBrowse:SetDBFFilter(.T.)

	oBrowse:AddMarkColumns( { ||Iif( !Empty( (_cAliasTRB)->MARK = "1" ),"LBOK","LBNO" ) },{ || AGRA860DCBW(), oBrowse:LineRefresh()  }, { ||  /*header click*/} )     

	oBrowse:AddLegend( "(_cAliasTRB)->status == '1'"	, "RED"			, STR0051) //"Agd. Aprovação"                   
	oBrowse:AddLegend( "(_cAliasTRB)->status == '2'"	, "YELLOW"		, STR0052) //"Aprovado"                         
	oBrowse:AddLegend( "(_cAliasTRB)->status == '3'"	, "GREEN"		, STR0053) //"Aprovado manualmente"             
	oBrowse:AddLegend( "(_cAliasTRB)->status == '4'"	, "WHITE"		, STR0054) //"Item sem liberação"               
	oBrowse:AddLegend( "(_cAliasTRB)->status == '5'"	, "BLUE"		, STR0055) //"Item liberado sem prog de entrega"
	oBrowse:AddLegend( "(_cAliasTRB)->status == '6'"	, "PINK"		, STR0056) //"Carga Montada"
	oBrowse:AddLegend( "(_cAliasTRB)->status == '7'"	, "BLACK"		, STR0057) //"Nota emitida" 	
	oBrowse:AddLegend( "(_cAliasTRB)->status == '8'"	, "BR_VIOLETA"	, STR0058) //"Com prog. e bloqueado Crédito" 
	oBrowse:AddLegend( "(_cAliasTRB)->status == '9'"	, "BR_CANCEL"	, STR0059) //"Programação Cancelada" 	

	ADD COLUMN oColumn DATA { || &(_aTPTB[1,1]) } TITLE STR0025        SIZE  _aTPTB[1,3]	PICTURE PesqPict("SC9","C9_FILIAL") 	TYPE TamSX3("C9_FILIAL")  [3]	OF oBrowse //"Filial"
	ADD COLUMN oColumn DATA { || &(_aTPTB[7,1]) } TITLE STR0026        SIZE  _aTPTB[7,3]	PICTURE PesqPict("SC9","C9_PEDIDO") 	TYPE TamSX3("C9_PEDIDO")  [3]	OF oBrowse //"Pedido"
	ADD COLUMN oColumn DATA { || &(_aTPTB[8,1]) } TITLE STR0027        SIZE  _aTPTB[8,3]	PICTURE PesqPict("SC9","C9_ITEM") 	    TYPE TamSX3("C9_ITEM")    [3]	OF oBrowse //"Item"
	ADD COLUMN oColumn DATA { || &(_aTPTB[3,1]) } TITLE STR0030        SIZE  _aTPTB[3,3]  	PICTURE PesqPict("SC6","C6_CLI") 		TYPE TamSX3("C6_CLI")     [3]	OF oBrowse //"Cliente"
	//ADD COLUMN oColumn DATA { || &(_aTPTB[25,1]) } TITLE STR0031       SIZE  _aTPTB[25,3] 	PICTURE PesqPict("SC6","C6_LOJA") 		TYPE TamSX3("C6_LOJA")    [3]	OF oBrowse //"Loja"
	ADD COLUMN oColumn DATA { || &(_aTPTB[4,1]) } TITLE STR0032        SIZE  _aTPTB[4,3]  	PICTURE PesqPict("SA1","A1_NOME") 		TYPE TamSX3("A1_NOME")    [3]	OF oBrowse //"Nome"	
	ADD COLUMN oColumn DATA { || &(_aTPTB[5,1]) } TITLE STR0033        SIZE  _aTPTB[5,3]  	PICTURE PesqPict("SA1","A1_MUN") 		TYPE TamSX3("A1_MUN")     [3]	OF oBrowse //"Município"
	ADD COLUMN oColumn DATA { || &(_aTPTB[6,1]) } TITLE STR0035        SIZE  _aTPTB[6,3]  	PICTURE PesqPict("SA1","A1_EST") 		TYPE TamSX3("A1_EST")     [3]	OF oBrowse //"UF"	
	ADD COLUMN oColumn DATA { || &(_aTPTB[12,1])} TITLE STR0060        SIZE _aTPTB[12,3]  	PICTURE PesqPict("SC6","C6_QTDVEN") 	TYPE TamSX3("C6_QTDVEN")  [3]	OF oBrowse //"Qtd Venda"
	ADD COLUMN oColumn DATA { || &(_aTPTB[13,1])} TITLE STR0061        SIZE _aTPTB[13,3]  	PICTURE PesqPict("SC6","C6_UM") 		TYPE TamSX3("C6_UM")      [3]	OF oBrowse //"Un. Med"
	ADD COLUMN oColumn DATA { || &(_aTPTB[14,1])} TITLE STR0062        SIZE  _aTPTB[14,3] 	PICTURE PesqPict("SC6","C6_UNSVEN") 	TYPE TamSX3("C6_UNSVEN")  [3]	OF oBrowse //"Qtd Venda 2"
	ADD COLUMN oColumn DATA { || &(_aTPTB[15,1])} TITLE STR0063        SIZE  _aTPTB[15,3] 	PICTURE PesqPict("SC6","C6_SEGUM") 		TYPE TamSX3("C6_SEGUM")   [3]	OF oBrowsE //"Un. Med 2"
	ADD COLUMN oColumn DATA { || &(_aTPTB[17,1])} TITLE STR0064        SIZE _aTPTB[17,3] 	PICTURE PesqPict("SC9","C9_QTDLIB") 	TYPE TamSX3("C9_QTDLIB")  [3]	OF oBrowse //"Qtd Liberada"
	ADD COLUMN oColumn DATA { || &(_aTPTB[18,1])} TITLE STR0065        SIZE _aTPTB[18,3] 	PICTURE PesqPict("SC9","C9_QTDLIB2")	TYPE TamSX3("C9_QTDLIB2") [3]	OF oBrowse //"Qtd Lib 2"
	ADD COLUMN oColumn DATA { || &(_aTPTB[19,1])} TITLE STR0066        SIZE _aTPTB[19,3] 	PICTURE PesqPict("SC9","C9_DATENT") 	TYPE TamSX3("C9_DATENT")  [3]	OF oBrowse //"Dt Prevista"
	ADD COLUMN oColumn DATA { || &(_aTPTB[30,1])} TITLE STR0067        SIZE _aTPTB[30,3] 	PICTURE PesqPict("NJ5","NJ5_DTPROG") 	TYPE TamSX3("NJ5_DTPROG") [3]	OF oBrowse //"Dt Programada"		 
	ADD COLUMN oColumn DATA { || &(_aTPTB[10,1])} TITLE STR0029        SIZE _aTPTB[10,3]  	PICTURE PesqPict("SC9","C9_PRODUTO") 	TYPE TamSX3("C9_PRODUTO") [3]	OF oBrowse //"Produto"
	ADD COLUMN oColumn DATA { || &(_aTPTB[11,1])} TITLE STR0029        SIZE _aTPTB[11,3]  	PICTURE PesqPict("SB1","B1_DESC") 		TYPE TamSX3("B1_DESC")	  [3]	OF oBrowse //"Desc. Produto"
	ADD COLUMN oColumn DATA { || &(_aTPTB[9,1]) } TITLE STR0068        SIZE  _aTPTB[9,3]  	PICTURE PesqPict("SC9","C9_SEQUEN") 	TYPE TamSX3("C9_SEQUEN")  [3]	OF oBrowse //"Sequen"	 	
	ADD COLUMN oColumn DATA { || &(_aTPTB[28,1])} TITLE STR0034        SIZE  _aTPTB[28,3] 	PICTURE PesqPict("SC5","C5_VEND1") 		TYPE TamSX3("C5_VEND1")	  [3]	OF oBrowse //"Vendedor"
	ADD COLUMN oColumn DATA { || &(_aTPTB[29,1])} TITLE STR0069        SIZE  _aTPTB[29,3]  	PICTURE PesqPict("SA3","A3_NOME") 		TYPE TamSX3("A3_NOME")	  [3]	OF oBrowse //"Nome Vendedor"
	ADD COLUMN oColumn DATA { || &(_aTPTB[16,1])} TITLE STR0070        SIZE  15 			PICTURE "@!" 							TYPE TamSX3("C5_TPFRETE") [3]	OF oBrowse //"Tp Frete"
	ADD COLUMN oColumn DATA { || &(_aTPTB[20,1])} TITLE STR0037        SIZE _aTPTB[20,3] 	PICTURE PesqPict("SC6","C6_CULTRA") 	TYPE TamSX3("C6_CULTRA")  [3]	OF oBrowse //"Cultura"
	ADD COLUMN oColumn DATA { || &(_aTPTB[21,1])} TITLE STR0038        SIZE _aTPTB[21,3] 	PICTURE PesqPict("SC6","C6_CTVAR") 	    TYPE TamSX3("C6_CTVAR")   [3]	OF oBrowse //"Cultivar"
	ADD COLUMN oColumn DATA { || &(_aTPTB[22,1])} TITLE STR0038        SIZE _aTPTB[22,3] 	PICTURE PesqPict("NP4","NP4_DESCRI") 	TYPE TamSX3("NP4_DESCRI") [3]	OF oBrowse //"Nome Cultivar"	
	ADD COLUMN oColumn DATA { || &(_aTPTB[23,1])} TITLE STR0039        SIZE _aTPTB[23,3] 	PICTURE PesqPict("SC6","C6_CATEG") 	    TYPE TamSX3("C6_CATEG")   [3]	OF oBrowse //"Categoria"
	ADD COLUMN oColumn DATA { || &(_aTPTB[24,1])} TITLE STR0040        SIZE _aTPTB[24,3] 	PICTURE PesqPict("SC6","C6_PENE") 	    TYPE TamSX3("C6_PENE")    [3]	OF oBrowse //"Peneira"
	ADD COLUMN oColumn DATA { || &(_aTPTB[25,1])} TITLE STR0041        SIZE _aTPTB[25,3] 	PICTURE PesqPict("SC9","C6_LOCAL") 	    TYPE TamSX3("C6_LOCAL")   [3]	OF oBrowse //"Local"
	ADD COLUMN oColumn DATA { || &(_aTPTB[26,1])} TITLE STR0045        SIZE _aTPTB[26,3] 	PICTURE PesqPict("SC5","C5_CODSAF") 	TYPE TamSX3("C5_CODSAF")  [3]	OF oBrowse //"Safra"
	ADD COLUMN oColumn DATA { || &(_aTPTB[33,1])} TITLE STR0071        SIZE  _aTPTB[33,3]  	PICTURE PesqPict("SC5","C5_EMISSAO") 	TYPE TamSX3("C5_EMISSAO") [3]	OF oBrowse //"Dt Emissao"

	//tratamento campos adicionais
	for nX := 1 to len(_aCpsBrwPE)		
		if !Empty( TamSX3(_aCpsBrwPE[nX]) )
			ADD COLUMN oColumn DATA &("{ || Z"+STRTRAN(_aCpsBrwPE[nX], "_", "")+"}") TITLE RetTitle(_aCpsBrwPE[nX]) SIZE  TamSX3(_aCpsBrwPE[nX])[1]  ;
			PICTURE X3PICTURE(_aCpsBrwPE[nX]) 	TYPE TamSX3(_aCpsBrwPE[nX])[3]	OF oBrowse
		endif
	next nX

	__oOBrowse := oBrowse

	//Ativa o Browse
	oBrowse:Activate()

	//Elimina a tabela temporária, se houver
	AGRDLTPTB(oArqTemp)

Return()


/*/{Protheus.doc} AGRA860STT
Responsável pela criação da estrutura da tabela temporária
@author brunosilva
@since 31/01/2017
@version undefined

@type function
/*/
Static Function AGRA860STT()
	Local aIndice := {}
	Local nX      := 0

	aAdd(_aTPTB, {"Filial"    , TamSX3("C9_FILIAL")[3]  , TamSX3("C9_FILIAL")[1]  , TamSX3("C9_FILIAL")[2]})
	aAdd(_aTPTB, {"Status"    , "C", 1 , 0})	
	aAdd(_aTPTB, {"Cliente"   , TamSX3("C6_CLI")[3]     , TamSX3("C6_CLI")[1]     , TamSX3("C6_CLI")[2]})
	aAdd(_aTPTB, {"Nome"      , TamSX3("A1_NOME")[3]    , TamSX3("A1_NOME")[1]    , TamSX3("A1_NOME")[2]})
	aAdd(_aTPTB, {"Municipio" , TamSX3("A1_MUN")[3]     , TamSX3("A1_MUN")[1]     , TamSX3("A1_MUN")[2]})
	aAdd(_aTPTB, {"UF"        , TamSX3("A1_EST")[3]     , TamSX3("A1_EST")[1]     , TamSX3("A1_EST")[2]})
	aAdd(_aTPTB, {"Pedido"    , TamSX3("C9_PEDIDO")[3]  , TamSX3("C9_PEDIDO")[1]  , TamSX3("C9_PEDIDO")[2]})
	aAdd(_aTPTB, {"Item"      , TamSX3("C9_ITEM")[3]    , TamSX3("C9_ITEM")[1]    , TamSX3("C9_ITEM")[2]})
	aAdd(_aTPTB, {"Sequencia" , TamSX3("C9_SEQUEN")[3]  , TamSX3("C9_SEQUEN")[1]  , TamSX3("C9_SEQUEN")[2]})
	aAdd(_aTPTB, {"Produto"   , TamSX3("C9_PRODUTO")[3] , TamSX3("C9_PRODUTO")[1] , TamSX3("C9_PRODUTO")[2]})
	aAdd(_aTPTB, {"DescProd"  , TamSX3("B1_DESC")[3] 	, TamSX3("B1_DESC")[1] 	  , TamSX3("B1_DESC")[2]})	
	aAdd(_aTPTB, {"QtdVen"    , TamSX3("C6_QTDVEN")[3]  , TamSX3("C6_QTDVEN")[1]  , TamSX3("C6_QTDVEN")[2]})
	aAdd(_aTPTB, {"UM"        , TamSX3("C6_UM")[3]      , TamSX3("C6_UM")[1]      , TamSX3("C6_UM")[2]})
	aAdd(_aTPTB, {"QtdVen2"   , TamSX3("C6_UNSVEN")[3]  , TamSX3("C6_UNSVEN")[1]  , TamSX3("C6_UNSVEN")[2]})
	aAdd(_aTPTB, {"UM2"       , TamSX3("C6_SEGUM")[3]   , TamSX3("C6_SEGUM")[1]   , TamSX3("C6_SEGUM")[2]})
	aAdd(_aTPTB, {"TpFrete"   , TamSX3("C5_TPFRETE")[3] , 15                      , TamSX3("C5_TPFRETE")[2]})
	aAdd(_aTPTB, {"QtdLib"    , TamSX3("C9_QTDLIB")[3]  , TamSX3("C9_QTDLIB")[1]  , TamSX3("C9_QTDLIB")[2]})
	aAdd(_aTPTB, {"QtdLib2"   , TamSX3("C9_QTDLIB2")[3] , TamSX3("C9_QTDLIB2")[1] , TamSX3("C9_QTDLIB2")[2]})
	aAdd(_aTPTB, {"DtPrev"    , TamSX3("C9_DATENT")[3]  , TamSX3("C9_DATENT")[1]  , TamSX3("C9_DATENT")[2]})
	aAdd(_aTPTB, {"Cultura"   , TamSX3("C6_CULTRA")[3]  , TamSX3("C6_CULTRA")[1]  , TamSX3("C6_CULTRA")[2]})
	aAdd(_aTPTB, {"Cultivar"  , TamSX3("C6_CTVAR")[3]   , TamSX3("C6_CTVAR")[1]   , TamSX3("C6_CTVAR")[2]})
	aAdd(_aTPTB, {"NomeCtvar", TamSX3("NP4_DESCRI")[3] , TamSX3("NP4_DESCRI")[1] , TamSX3("NP4_DESCRI")[2]})
	aAdd(_aTPTB, {"Categoria" , TamSX3("C6_CATEG")[3]   , TamSX3("C6_CATEG")[1]   , TamSX3("C6_CATEG")[2]})
	aAdd(_aTPTB, {"Peneira"	  , TamSX3("C6_PENE")[3]    , TamSX3("C6_PENE")[1]    , TamSX3("C6_PENE")[2]})
	aAdd(_aTPTB, {"Locali"    , TamSX3("C6_LOCAL")[3]   , TamSX3("C6_LOCAL")[1]   , TamSX3("C6_LOCAL")[2]})
	aAdd(_aTPTB, {"Safra"     , TamSX3("C5_CODSAF")[3]  , TamSX3("C5_CODSAF")[1]  , TamSX3("C5_CODSAF")[2]})
	aAdd(_aTPTB, {"Loja"      , TamSX3("C6_LOJA")[3]    , TamSX3("C6_LOJA")[1]    , TamSX3("C6_LOJA")[2]})
	aAdd(_aTPTB, {"Vendedor"  , TamSX3("C5_VEND1")[3]   , TamSX3("C5_VEND1")[1]   , TamSX3("C5_VEND1")[2]})
	aAdd(_aTPTB, {"NomeVend"  , TamSX3("A3_NOME")[3]    , TamSX3("A3_NOME")[1]    , TamSX3("A3_NOME")[2]})
	aAdd(_aTPTB, {"DtProg"    , TamSX3("NJ5_DTPROG")[3] , TamSX3("NJ5_DTPROG")[1] , TamSX3("NJ5_DTPROG")[2]})
	aAdd(_aTPTB, {"d","C", 1 , 0})
	aAdd(_aTPTB, {"TpF"       , TamSX3("C5_TPFRETE")[3] , TamSX3("C5_TPFRETE")[1] , TamSX3("C5_TPFRETE")[2]})
	aAdd(_aTPTB, {"Emissao"   , TamSX3("C5_EMISSAO")[3] , TamSX3("C5_EMISSAO")[1] , TamSX3("C5_EMISSAO")[2]})	
	aAdd(_aTPTB, {"Mark"      , "C", 1 , 0})

	//tratamento campos adicionais
	for nX:=1 to len(_aCpsBrwPE)
		aAdd(_aTPTB, {"Z"+STRTRAN(_aCpsBrwPE[nX], "_", "") , TamSX3(_aCpsBrwPE[nX] )[3] , TamSX3(_aCpsBrwPE[nX] )[1] , TamSX3(_aCpsBrwPE[nX] )[2]})	
	next nX

	//-- Cria Indice de Trabalho	
	_cAliasTRB := GetNextAlias()
	aAdd (aIndice, {"", "FILIAL+PEDIDO+ITEM+SEQUENCIA+PRODUTO+STATUS"}) //mostrar os cancelados
	aAdd (aIndice, {"", "FILIAL+PEDIDO+STATUS"})
	aAdd (aIndice, {"", "FILIAL+CLIENTE+STATUS"})	

	oArqTemp := Nil
	oArqTemp := AGRCRTPTB(_cAliasTRB, {_aTPTB, aIndice },,,,.F. ) 

	(_cAliasTRB) -> (DbSetOrder(1))
Return 


/*/{Protheus.doc} ModelDef
Retorna o Modelo de dados da rotina de Programação de Entrega
@author joaquim.burjack
@since 22/12/2016
@version undefined

@type function
/*/
Static Function ModelDef()
	Local oModel   	:= Nil
	Local oStruSC9 	:= FwFormStruct(1,"SC9")//,{|cCampo| (Alltrim(cCampo) $ "C9_FILIAL","C9_PEDIDO","C9_ITEM","C9_SEQUEN","C9_CLIENTE","C6_LOJA","C9_PRODUTO","C9_QTDLIB","C9_QTDLIB2","C9_DATENT")} )//Liberação de pedidos
	Local oStruNJ5 	:= FWFormStruct(1,"NJ5")

	// Instancia o modelo de dados
	oModel := MpFormModel():New( 'AGRA860_SC9',/*bPre*/,/*{ |oModel| }*/,{ |oModel| AGRA860POS( oModel ) } , /*bCancel*/ )
	oModel:SetDescription( STR0001 ) //Programação de entrega

	// Adiciona estrutura de campos no modelo de dados
	oModel:AddFields( 'SC9MASTER', /*cOwner*/, oStruSC9 )
	oModel:AddFields( 'NJ5FIELD', 'SC9MASTER', oStruNJ5 )
	oModel:SetDescription( STR0008 ) // Liberações de Pedidos
	oModel:GetModel('NJ5FIELD'):SetDescription( STR0001 ) //Programação de entrega

	// Seta chave primaria
	oModel:SetPrimaryKey( {"C9_FILIAL","C9_PEDIDO","C9_ITEM","C9_SEQUEN","C9_PRODUTO"} )

	//Set the relationship between  to both
	oModel:SetRelation( 'NJ5FIELD', { { 'NJ5_FILIAL', 'FWxFilial( "NJ5" )' }, { 'NJ5_NUMPV', 'C9_PEDIDO' }, {'NJ5_ITEM', 'C9_ITEM'},;
	{'NJ5_SEQUEN', 'C9_SEQUEN'}, {'NJ5_PRODUT', 'C9_PRODUTO'} }, NJ5->( IndexKey( 1 ) ) )

	//Deixa todos os campos da SC9 travados para edição.
	oStruSC9:SetProperty('*',MODEL_FIELD_WHEN,{||.F.})

	//Seta função de execução na ativação do model
	oModel:SetActivate( { |oMdl| AGRA860ACT( oMdl ) } )

Return oModel

/*/{Protheus.doc} ViewDef
Retorna a View (tela) da rotina de Programação de entregas
@author joaquim.burjack
@since 22/12/2016
@version undefined

@type function
/*/
Static Function ViewDef()
	Local oView		:= Nil
	Local oModel	:= FwLoadModel( "AGRA860" )
	Local oStruSC9 	:= FwFormStruct( 2, "SC9",{|cCampo| (Alltrim(cCampo) $;
	"C9_FILIAL,C9_PEDIDO,C9_ITEM,C9_SEQUEN,C9_CLIENTE,C6_LOJA,C9_PRODUTO,C9_QTDLIB,C9_QTDLIB2,C9_DATENT")} )//Liberação de pedidos
	Local oStruNJ5  := FWFormStruct( 2, 'NJ5' )
	// Instancia modelo de visualização
	oView := FwFormView():New()

	// Seta o modelo de dados
	oView:SetModel( oModel )

	// Adciona os campos na estrutura do modelo de dados
	oView:AddField("VIEW_SC9",oStruSC9,"SC9MASTER")

	oView:AddField( "VIEW_NJ5", oStruNJ5, "NJ5FIELD" )

	oStruNJ5:RemoveField( "NJ5_CODCAR" )
	oStruNJ5:RemoveField( "NJ5_DTPREV" )

	oView:CreateHorizontalBox( "SUPERIOR" , 30)
	oView:CreateHorizontalBox( "INFERIOR" , 70)

	oView:SetOwnerView( "VIEW_SC9", "SUPERIOR" )
	oView:SetOwnerView( "VIEW_NJ5", "INFERIOR" )

	oView:EnableTitleView( "VIEW_SC9" )
	oView:EnableTitleView( "VIEW_NJ5" )

Return oView


/*/{Protheus.doc} MenuDef
Retorna o Menu da rotina de Programação de entrega
@author joaquim.burjack
@since 22/12/2016
@version undefined

@type function
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title OemToAnsi(STR0002)		Action 'AGRA860VIS' 		OPERATION 2  ACCESS 0 //Visualizar
	ADD OPTION aRotina Title OemToAnsi(STR0003)		Action 'AGRA860INC'			OPERATION 4  ACCESS 0 //Incluir	
	ADD OPTION aRotina Title OemToAnsi(STR0004)		Action 'AGRA860ALT' 		OPERATION 4  ACCESS 0 //Alterar
	ADD OPTION aRotina Title OemToAnsi(STR0005)		Action 'AGRA860EXC' 		OPERATION 5  ACCESS 0 //Excluir
	ADD OPTION aRotina Title OemToAnsi(STR0006)		Action 'VIEWDEF.AGRA860' 	OPERATION 6  ACCESS 0 //Imprimir
	ADD OPTION aRotina Title OemToAnsi(STR0007)		Action 'AGRA860APR' 	 	OPERATION 7  ACCESS 0 //Aprov. manual

	ADD OPTION aRotina Title OemToAnsi(STR0009)		Action "AGRA860EXE"  	    OPERATION 10 ACCESS 0 //Executar
	ADD OPTION aRotina Title OemToAnsi(STR0010)		Action "AGRA950VLG('NJ5')"  OPERATION 11 ACCESS 0 //Histórico
	ADD OPTION aRotina Title OemToAnsi(STR0019)		Action "AGRA860DES()"  		OPERATION 12 ACCESS 0 //Desmembrar
	ADD OPTION aRotina Title OemToAnsi(STR0086)		Action "AGRA860REG()"  		OPERATION 13 ACCESS 0 //Reagendamento
	ADD OPTION aRotina Title OemToAnsi("Atualizar")	Action "AG860PERG()"  	OPERATION 14 ACCESS 0 //Atualizar	

Return aRotina

/*/{Protheus.doc} AGRA860INC
Responsável por verificar se não existe programação para a liberação.
@author brunosilva
@since 11/01/2017
@version undefined

@type function
/*/
Function AGRA860INC()

	If (_cAliasTRB)->STATUS = '5' //Item liberado sem prog. de entrega
		dbSelectArea("SC9")
		dbSetOrder(1)
		DbSeek(FWxFILIAL("SC9")+(_cAliasTRB)->PEDIDO+(_cAliasTRB)->ITEM+(_cAliasTRB)->SEQUENCIA+(_cAliasTRB)->PRODUTO)
		FWExecView(STR0087,'AGRA860', MODEL_OPERATION_UPDATE,,{ || .T. }) //"Programação"
	ElseIf (_cAliasTRB)->STATUS $ '1|2|3'
		Help(,,STR0018,,STR0011,1,0) //Atenção//Programação de entrega já efetuada.
	ElseIf (_cAliasTRB)->STATUS $ '6'
		Help(,,STR0018,,STR0088,1,0) //Atenção ### "Carga já montada"
	ElseIf (_cAliasTRB)->STATUS $ '9'
		Help(,,STR0018,,STR0089,1,0) //Atenção ### "Programação selecionada está excluída."	
	Else
		Help(,,STR0018,,STR0090,1,0) //Atenção ### "Liberação de pedido ainda não foi efetuada"
	EndIf

Return

/*/{Protheus.doc} AGRA860ALT
Responsável por verificar se já existe programação para a liberação.
@author brunosilva
@since 11/01/2017
@version undefined

@type function
/*/
Function AGRA860ALT()

	If (_cAliasTRB)->STATUS $ '1|2|3|8' //Prog já efetuada.
		dbSelectArea("SC9")
		dbSetOrder(1)
		DbSeek(FWxFILIAL("SC9")+(_cAliasTRB)->PEDIDO+(_cAliasTRB)->ITEM+(_cAliasTRB)->SEQUENCIA+(_cAliasTRB)->PRODUTO)
		FWExecView(STR0087,'AGRA860', MODEL_OPERATION_UPDATE,,{ || .T. }) //"Programação"
	ElseIf (_cAliasTRB)->STATUS = '5' //Item liberado sem prog. de entrega
		Help(,,STR0018,,STR0012,1,0) //Atenção //Não existe programação de entrega para ser alterada.
	ElseIf (_cAliasTRB)->STATUS = '9' //Item liberado sem prog. de entrega
		Help(,,STR0018,,STR0091,1,0) //"Programação selecionada está excluída"
	Else
		Help(,,STR0018,,STR0090,1,0) //"Liberação de pedido ainda não foi efetuada"
	EndIf
Return

/*/{Protheus.doc} AGRA860VIS
Responsável por permitir que o usuário apenas visualize uam programação que já tenha sido anteriormente incluida.
@author brunosilva
@since 13/01/2017
@version undefined

@type function
/*/
Function AGRA860VIS()

	If (_cAliasTRB)->STATUS $ '1|2|3|6|7|8' //Prog já efetuada.
		dbSelectArea("SC9")
		dbSetOrder(1)
		DbSeek(FWxFILIAL("SC9")+(_cAliasTRB)->PEDIDO+(_cAliasTRB)->ITEM+(_cAliasTRB)->SEQUENCIA+(_cAliasTRB)->PRODUTO)
		FWExecView(STR0087,'AGRA860', MODEL_OPERATION_VIEW,,{ || .T. }) //"Programação"
	Else
		Help(,,STR0018,,STR0013,1,0) //Não existe programação de entrega para ser visualizada.
	EndIf
Return

/*/{Protheus.doc} AGRA860ACT
Rotina responsável trazer os valores da tabela NJ5 par alteração da data prevista de carregamento.
@author brunosilva
@since 28/12/2016
@version undefined
@param oModel, object, descricao
@type function
/*/
Function AGRA860ACT(oModel)
	Local oFieldNJ5 := oModel:GetModel("NJ5FIELD")

	If IsIncallStack("AGRA860INC")
		oFieldNJ5:LoadValue("NJ5_FILIAL", FWxfilial("NJ5"))
		oFieldNJ5:LoadValue("NJ5_NUMPV",  (_cAliasTRB)->Pedido)
		oFieldNJ5:LoadValue("NJ5_ITEM",   (_cAliasTRB)->Item)
		oFieldNJ5:LoadValue("NJ5_SEQUEN", (_cAliasTRB)->Sequencia)
		oFieldNJ5:LoadValue("NJ5_PRODUT", (_cAliasTRB)->Produto)
		oFieldNJ5:LoadValue("NJ5_QTDE",   (_cAliasTRB)->QtdLib)
		oFieldNJ5:LoadValue("NJ5_UM",     (_cAliasTRB)->UM)
		oFieldNJ5:LoadValue("NJ5_QTDUM2", (_cAliasTRB)->QtdLib2)
		oFieldNJ5:LoadValue("NJ5_UM2",    (_cAliasTRB)->UM2)
		oFieldNJ5:LoadValue("NJ5_LOCAL",  (_cAliasTRB)->Locali)
		oFieldNJ5:LoadValue("NJ5_CULTRA", (_cAliasTRB)->Cultura)
		oFieldNJ5:LoadValue("NJ5_CTVAR",  (_cAliasTRB)->Cultivar)
		oFieldNJ5:LoadValue("NJ5_CATEG",  (_cAliasTRB)->Categoria)
		oFieldNJ5:LoadValue("NJ5_PENE",   (_cAliasTRB)->Peneira)
		oFieldNJ5:LoadValue("NJ5_TPFRET", (_cAliasTRB)->TpF)
		oFieldNJ5:LoadValue("NJ5_CODSAF", (_cAliasTRB)->Safra)
		oFieldNJ5:LoadValue("NJ5_DTPREV", (_cAliasTRB)->DtPrev)
		//oFieldNJ5:LoadValue("NJ5_DTPROG", dDatabase)

	EndIf
Return

/*/{Protheus.doc} AGR860APR
Rotina responsável pela aprovação manual.
@author brunosilva
@since 03/01/2017
@version undefined

@type function
/*/
Function AGRA860APR()
	Local oModel := FwLoadModel( "AGRA860" )
	Local oView  := Nil

	if (_cAliasTRB)->STATUS <> "9" //cancelado
		//Instacia a View
		oView := FwFormView():New()
		//Seta a model na view
		oView:SetModel(oModel)
		//Caso a tela tenha sido alterada, ele verifica.
		oView:Refresh()

		dbSelectArea("NJ5")
		dbSetOrder(1)
		DbSeek(FWxFILIAL("NJ5") + (_cAliasTRB)->PEDIDO + (_cAliasTRB)->ITEM + (_cAliasTRB)->SEQUENCIA + (_cAliasTRB)->PRODUTO)

		If NJ5->NJ5_STATUS $ "1"
			If NJ5->( MsRLock() )
				If AGRGRAVAHIS(STR0007,"NJ5",FWxFilial("NJ5")+NJ5->NJ5_CODCAR+NJ5->NJ5_NUMPV+NJ5->NJ5_ITEM+NJ5->NJ5_SEQUEN+NJ5->NJ5_PRODUT+"VALIDACAO","A") = 1 //Aprov. manual
					If RecLock("NJ5", .F.)
						NJ5->NJ5_STATUS := "3" //Aprovado manualmente
						NJ5->(MsUnlock())
						DbSelectArea("SC9")
						DbSetOrder(1)
						DbSeek(FWxFILIAL("SC9") + NJ5->NJ5_NUMPV + NJ5->NJ5_ITEM + NJ5->NJ5_SEQUEN + NJ5->NJ5_PRODUT)
						If RecLock("SC9", .F.)
							SC9->C9_DATENT := NJ5->NJ5_DTPROG
							SC9->(MsUnlock())
						EndIf
					EndIf
				EndIf
				NJ5->(MsRUnlock())
			Else
				Help(,,STR0018,,STR0014,1,0) //Atenção //Registro em uso no momento, favor repetir ação em seguida.
				Return
			EndIf
		ElseIf NJ5->NJ5_STATUS $ "2|3"
			Help(,,STR0018,,STR0015,1,0) //Atenção //Pedido já aprovado.
		Else
			Help(,,STR0018,,STR0016,1,0) //Atenção //Não existe Programação de entrega para este registro.
		EndIf

		//Refaz a select e a tela
		AGRA860TRB()
	endif	
Return

/*/{Protheus.doc} AGRA860EXC
Função responsável pela exclusão da liberação apenas na NJ5.
@author brunosilva
@since 04/01/2017
@version undefined

@type function
/*/
Function AGRA860EXC()
	Local dData
	if (_cAliasTRB)->STATUS <> "9"
		dbSelectArea("NJ5")
		dbSetOrder(1)
		If dbSeek(FWxFILIAL("NJ5")+(_cAliasTRB)->PEDIDO+(_cAliasTRB)->ITEM+(_cAliasTRB)->SEQUENCIA+(_cAliasTRB)->PRODUTO)
			/*NJ5_CODCAR pora que serve esse campo?*/
			//Verificar por que não está possicioando corretamente a sc9
			dbSelectArea("SC9")
			dbSetOrder(1)//C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
			DbSeek(FWxFILIAL("SC9")+(_cAliasTRB)->PEDIDO+(_cAliasTRB)->ITEM+(_cAliasTRB)->SEQUENCIA+(_cAliasTRB)->PRODUTO)
			If Empty(SC9->C9_CARGA)
				If RecLock("NJ5",.F.)
					dData := NJ5->NJ5_DTPROG
					dbDelete()
					NJ5->(MsUnlock())
					Help(,,"Atenção",,STR0017,1,0) //Programação de entrega excluída com sucesso.		
					If RecLock("SC9",.F.) 
						SC9->C9_DATENT := dData
						SC9 -> (MsUnlock())
					EndIf
				EndIf
			Else
				//TODO AJUSTAR HELP
				Help(,,STR0018,,STR0094,1,0) //"Carga já montada."
			EndIf	
		Else
			Help(,,STR0018,,STR0016,1,0) //Atenção //Programação de entrega não encontrada. 
		EndIf
	endif	
	//Refaz a select e a tela
	AGRA860TRB()
Return

/*/{Protheus.doc} AGRA860EXE
//Responsável por submeter os registros às funções de aprovação novamente.
@author brunosilva
@since 21/03/2017
@version undefined

@type function
/*/
Function AGRA860EXE()
	if (_cAliasTRB)->STATUS <> "9" //cancelado	
		dbSelectArea("NJ5")
		dbSetOrder(1)
		dbSeek(FWxFILIAL("NJ5")+(_cAliasTRB)->PEDIDO+(_cAliasTRB)->ITEM+(_cAliasTRB)->SEQUENCIA+(_cAliasTRB)->PRODUTO)
		If AGRA950VAL('NJ5')
			If RecLock("NJ5", .F.)
				NJ5->NJ5_STATUS := "2" //Aprovado
				NJ5->(MsUnlock())
				DbSelectArea("SC9")
				DbSetOrder(1)
				DbSeek(FWxFILIAL("SC9")+FwFldGet("NJ5_NUMPV")+FwFldGet("NJ5_ITEM")+FwFldGet("NJ5_SEQUEN")+FwFldGet("NJ5_PRODUT"))
				If RecLock("SC9", .F.)
					SC9->C9_DATENT := NJ5->NJ5_DTPROG
					SC9->(MsUnlock())
				EndIf
			EndIf
		Else
			If RecLock("NJ5", .F.)
				NJ5->NJ5_STATUS := "1" //Agd. Aprovação
				NJ5->(MsUnlock())
			Endif
		EndIf
		AGRA860TRB()
	endif	
Return

/*/{Protheus.doc} AGRA860POS
Função responsável pela gravação e validação das regras.
@author brunosilva
@since 04/01/2017
@version undefined
@param oMdl, object, descricao
@type function
/*/
Function AGRA860POS(oMdl)
	FwFormCommit(oMdl)
	DbSeek(FWxFILIAL("NJ5")+FwFldGet("NJ5_NUMPV")+FwFldGet("NJ5_ITEM")+FwFldGet("NJ5_SEQUEN")+FwFldGet("NJ5_PRODUT"))
	If AGRA950VAL('NJ5')
		If RecLock("NJ5", .F.)
			NJ5->NJ5_STATUS := "2" //Aprovado
			NJ5->(MsUnlock())
			DbSelectArea("SC9")
			DbSetOrder(1)
			DbSeek(FWxFILIAL("SC9")+FwFldGet("NJ5_NUMPV")+FwFldGet("NJ5_ITEM")+FwFldGet("NJ5_SEQUEN")+FwFldGet("NJ5_PRODUT"))
			If RecLock("SC9", .F.)
				SC9->C9_DATENT := NJ5->NJ5_DTPROG
				SC9->(MsUnlock())
			EndIf
		EndIf
	Else
		If RecLock("NJ5", .F.)
			NJ5->NJ5_STATUS := "1" //Agd. Aprovação
			NJ5->(MsUnlock())
		Endif
	EndIf

	AG860PERG()
Return .T.

/*-------------------------------------------------------------------
{Protheus.doc}AGRA860DES
Monta tela para informar desmembramento da liberação do pedido

@author Tamyris Ganzenmueller
@since 13/03/2017
@version 1.0
-------------------------------------------------------------------*/
Function AGRA860DES()
	Local nX       := 0
	Local nUsado   := 0
	Local cAliasGD := "SC9"

	// Cria Fonte para visualização
	Local oFont := TFont():New('Courier new',,-18,.T.)

	Local aButtons  := {}
	Local aCpoGDa   := {{},{},{},{},{}}
	Local aHeader   := {{},{},{},{},{}}
	Local aCols     := {}
	Local aColsBkp  := {}
	Local aAlterGDa := {}
	Local aFields   := {}

	Private oDlg
	Private oGetD
	Private oEnch

	//Valida se já foi realizada programação de entrega
	If ! ((_cAliasTRB)->STATUS $ "1|2|3|5|8|")
		If ((_cAliasTRB)->STATUS = "4")
			Help(,,STR0018,,STR0093,1,0) //"Item sem liberação de entrega."
		ElseIf ((_cAliasTRB)->STATUS = "6")
			Help(,,STR0018,,STR0094,1,0) //"Carga já montada."
		ElseIf ((_cAliasTRB)->STATUS = "9")
			Help(,,STR0018,,STR0089,1,0) //"Programação selecionada está excluída."
		EndIf
		Return .F. 
	Else

		aFields := FWSX3Util():GetAllFields( cAliasGD , .T. )

		For nX := 1 To Len(aFields)

			If (AllTrim(aFields[nX]) == "C9_QTDLIB" ) .And. cNivel >= AGRRETNIV(aFields[nX]) .And. X3USADO(aFields[nX])		
				aCpoGDa[1] := aFields[nX]
			ElseIf ( AllTrim(aFields[nX]) == "C9_QTDLIB2") .And. cNivel >= AGRRETNIV(aFields[nX]) .And. X3USADO(aFields[nX])	
				aCpoGDa[3] := aFields[nX]	
			ElseIf (AllTrim(aFields[nX]) == "C9_DATALIB") .And. cNivel >= AGRRETNIV(aFields[nX]) .And. X3USADO(aFields[nX])
				aCpoGDa[5] := aFields[nX]
			EndIf

		Next nX

		aFields := FWSX3Util():GetAllFields( "SC6" , .T. )

		For nX := 1 To Len(aFields)

			If (AllTrim(aFields[nX]) == "C6_UM" ) .And. cNivel >= AGRRETNIV(aFields[nX]) .And. X3USADO(aFields[nX])
				aCpoGDa[2] := aFields[nX]	
			ElseIf ( AllTrim(aFields[nX]) == "C6_SEGUM") .And. cNivel >= AGRRETNIV(aFields[nX]) .And. X3USADO(aFields[nX])		
				aCpoGDa[4] := aFields[nX]	
			EndIf

		Next nX

		aAlterGDa := aClone(aCpoGDa)
		nUsado:=0

		aFields := FWSX3Util():GetAllFields( "SC9" , .T. )

		For nX := 1 To Len(aFields)

			If (AllTrim(aFields[nX]) == "C9_QTDLIB" ) .And. cNivel >= AGRRETNIV(aFields[nX]) .And. X3USADO(aFields[nX])
				nUsado++	
				aHeader[1] := { TRIM(RetTitle(aFields[nX])), aFields[nX], X3PICTURE(aFields[nX]),TamSX3(aFields[nX])[1], TamSX3(aFields[nX])[2],"A860CONV()", X3USADO(aFields[nX]), TamSX3(aFields[nX])[3], X3F3(aFields[nX]), AGRRETCTXT("SC9", aFields[nX]) }
			ElseIf (AllTrim(aFields[nX]) == "C9_QTDLIB2" ) .And. cNivel >= AGRRETNIV(aFields[nX]) .And. X3USADO(aFields[nX])		
				nUsado++	
				aHeader[3] := { TRIM(RetTitle(aFields[nX])), aFields[nX], X3PICTURE(aFields[nX]),TamSX3(aFields[nX])[1], TamSX3(aFields[nX])[2],"A860CONV()", X3USADO(aFields[nX]), TamSX3(aFields[nX])[3], X3F3(aFields[nX]), AGRRETCTXT("SC9", aFields[nX]) }
			ElseIf (AllTrim(aFields[nX]) == "C9_DATALIB" ) .And. cNivel >= AGRRETNIV(aFields[nX]) .And. X3USADO(aFields[nX])
				nUsado++
				aHeader[5] := { TRIM(RetTitle(aFields[nX])), aFields[nX], X3PICTURE(aFields[nX]),TamSX3(aFields[nX])[1], TamSX3(aFields[nX])[2],"AllwaysTrue()", X3USADO(aFields[nX]), TamSX3(aFields[nX])[3], X3F3(aFields[nX]), AGRRETCTXT("SC9", aFields[nX]), , , , "A" }
			Endif

		Next nX

		aFields := FWSX3Util():GetAllFields( "SC6" , .T. )

		For nX := 1 To Len(aFields)

			If (AllTrim(aFields[nX]) == "C6_UM" ) .And. cNivel >= AGRRETNIV(aFields[nX]) .And. X3USADO(aFields[nX])		
				nUsado++	
				aHeader[2] := { TRIM(RetTitle(aFields[nX])), aFields[nX], X3PICTURE(aFields[nX]),TamSX3(aFields[nX])[1], TamSX3(aFields[nX])[2],"AllwaysTrue()", X3USADO(aFields[nX]), TamSX3(aFields[nX])[3], "SC6", AGRRETCTXT("SC6", aFields[nX]), , "(_cAliasTRB)->UM" }
			ElseIf(AllTrim(aFields[nX]) == "C6_SEGUM" ) .And. cNivel >= AGRRETNIV(aFields[nX]) .And. X3USADO(aFields[nX])	
				nUsado++	
				aHeader[4] := { TRIM(RetTitle(aFields[nX])), aFields[nX], X3PICTURE(aFields[nX]),TamSX3(aFields[nX])[1], TamSX3(aFields[nX])[2],"AllwaysTrue()", X3USADO(aFields[nX]), TamSX3(aFields[nX])[3], "SC6", AGRRETCTXT("SC6", aFields[nX]), , "(_cAliasTRB)->UM2 " }
			Endif

		Next nX

		aCols:={Array(nUsado+1)}	
		aCols[1,nUsado+1]:=.F.	

		For nX := 1 to nUsado		
			If (nX = 2) .or. (nX = 4)
				If nX = 2
					aCols[1,nX] := (_cAliasTRB)->UM
				ElseIf nX = 4
					aCols[1,nX] := (_cAliasTRB)->UM2
				EndIf
			Else
				aCols[1,nX]:=CriaVar(aHeader[nX,2])
			EndIf
		Next

		AColsBkp := aClone(aCols)

		oDlg := MSDIALOG():New(000,000,400,600, STR0019,,,,,,,,,.T.)

		// Monta o Texto no formato HTML
		cTextHtml := '<hr size="1">'+;
		'<table border="1" cellpadding="1" cellspacing="0">'+;
		'<tr>'+;
		'<td width="100" bgcolor="#f24848">Quantidade</td>'+;
		'<td width="50" bgcolor="#f24848">UM</td>'+;
		'<td width="100" bgcolor="#f24848">Quant. 2</td>'+;
		'<td width="50" bgcolor="#f24848">UM2</td>'+;
		'</tr>'+;
		'<tr>'+;
		'<td>' + cValToChar((_cAliasTRB)->QtdLib) + '</td>'+;
		'<td>' + (_cAliasTRB)->UM + '</td>'+;
		'<td>' + cValToChar((_cAliasTRB)->QtdLib2) + '</td>'+;
		'<td>' + (_cAliasTRB)->UM2 + '</td>'+;
		'</tr>'+;
		'</table>'+;
		'<hr size="1">'

		// Usan1do o método New
		oSay1:= TSay():New(31,20 ,{||STR0095},oDlg,,oFont,,,,.T.,CLR_BLUE,,200,20) //"Quantidades originais"

		oSay1:= TSay():New(40,10 ,{||cTextHtml},oDlg,,oFont,,,,.T.,CLR_BLUE,,300,100,,,,,,.T.)

		oGetD:= MsNewGetDados():New(100,000,300,300, 3, "AllwaysTrue", "AllwaysTrue","C9_DATALIB",;
		aAlterGDa,000,999, "AllwaysTrue","","AllwaysFalse", oDLG, aHeader, aCols)
		oGetD:oBrowse:lUseDefaultColors := .F.
		oDlg:bInit := {|| EnchoiceBar(oDlg, {||AGR860DEOK()}, {||oDlg:End()},,aButtons)}
		oDlg:lCentered := .T.
		oDlg:Activate()
	EndIF

Return// Função para tratamento das regras de cores para a grid da MsNewGetDadosStatic 

/*-------------------------------------------------------------------                                                                           
{Protheus.doc}AGR860DEOK
Efetua desmembramento da liberação do pedido

@author Tamyris Ganzenmueller
@since 13/03/2017
@version 1.0
-------------------------------------------------------------------*/ 
Static Function AGR860DEOK() 

	Local aCols   := oGetD:aCols
	Local nX        := 1
	Local nC        := 1
	Local nD        := 1
	Local nSumSdo := 0
	Local cTab      := "SC9"
	Local lAG860DES := ExistBlock("AG860DES")
	Local aCposCust := {}
	Local aNJ5Cust  := {}
	Local aFields   := {}
	Private aTab    := {}

	If Len(aCols) < 2

		Help(,,STR0018,, STR0020 ,1,0) 
		Return .F.
	EndIf

	nSumSdo := 0
	For nX := 1 to Len(aCols)
		nSumSdo += aCols[nX][1] 	

		If Empty(aCols[nX][5])
			Help(,,STR0018,, STR0021,1,0) 
			Return .F.
		EndIf

		If Empty(aCols[nX][1]) .OR. Empty(aCols[nX][3])
			Help(,,STR0018,, STR0022,1,0) 
			Return .F.
		EndIf
	Next nX

	//Verifica se a quantidade informada confere com o saldo
	//nSaldo := (_cAliasTRB)->QtdLib
	If nSumSdo <> (_cAliasTRB)->QtdLib
		Help(,,STR0018,, STR0023,1,0) 
		Return .F.
	EndIf


	//Sequencia
	cNameQry := "MAGRAVASC9"
	cQuery := "SELECT MAX(C9_SEQUEN) SEQUEN "
	cQuery +=   "FROM "+RetSqlName("SC9")+" SC9 "
	cQuery +=   "WHERE C9_FILIAL='"+xFilial("SC9")+"' AND "
	cQuery +=         "C9_PEDIDO='"+(_cAliasTRB)->PEDIDO+"' AND "
	cQuery +=         "C9_ITEM='"+(_cAliasTRB)->ITEM+"' AND "
	cQuery +=         "SC9.D_E_L_E_T_<>'*'"
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNameQry,.T.,.T.)
	If !Empty(SEQUEN)
		cSeqSC9 := AllTrim(SEQUEN)
	EndIf
	dbCloseArea()
	//Ponto de Entrada para atualizar campos customizados durante desmembramento de Programação de Entrega
	If lAG860DES
		aRetPe := ExecBlock("AG860DES",.F.,.F.)
		If Type("aRetPe") = "A" 
			aCposCust := aRetPe
		Endif
	Endif

	BEGIN TRANSACTION

		//já foi realizada programação de entrega
		dbSelectArea("NJ5")
		dbSetOrder(1)
		If dbSeek(FWxFILIAL("NJ5")+(_cAliasTRB)->PEDIDO+(_cAliasTRB)->ITEM+(_cAliasTRB)->SEQUENCIA+(_cAliasTRB)->PRODUTO)
			If NJ5->NJ5_STATUS $ "1|2|3|8"
				RecLock("NJ5", .F.)
				NJ5STATUS 	:= NJ5->NJ5_STATUS
				NJ5UM 		:= NJ5->NJ5_UM
				NJ5UM2 		:= NJ5->NJ5_UM2
				NJ5TPFRET 	:= NJ5->NJ5_TPFRET
				NJ5CODSAF 	:= NJ5->NJ5_CODSAF
				NJ5CULTRA 	:= NJ5->NJ5_CULTRA
				NJ5CTVAR 	:= NJ5->NJ5_CTVAR
				NJ5CATEG 	:= NJ5->NJ5_CATEG
				NJ5PENE 	:= NJ5->NJ5_PENE
				NJ5DTPREV 	:= NJ5->NJ5_DTPREV
				NJ5DTPROG 	:= NJ5->NJ5_DTPROG
				NJ5HRPROG 	:= NJ5->NJ5_HRPROG
				If lAG860DES .and. aCposCust <> Nil
					For nC := 1 to Len(aCposCust)
						AAdd(aNJ5Cust,{aCposCust[nC],&(aCposCust[nC])})
					Next nC
				Endif	
				NJ5->(dbDelete())   
				NJ5->(MsUnlock())
			EndIF
		EndIf

		aFields := FWSX3Util():GetAllFields( cTab, .F. )
		dbSelectArea("SC9")
		dbSetOrder(1)
		DbSeek(FWxFilial("SC9")+(_cAliasTRB)->PEDIDO+(_cAliasTRB)->ITEM+(_cAliasTRB)->SEQUENCIA+(_cAliasTRB)->PRODUTO)
		For nX := 1 To Len(aFields)
			AAdd(aTab,&(cTab + "->" + aFields[nX]))
		Next nX

		//Copia o registro atual
		IF RecLock("SC9", .F.)
			//Elimina o registro atual
			SC9->(dbDelete())   
			SC9->(MsUnlock())

			//Cria cópia da tabela 
			For nX:= 1 to Len(aCols)
				AGR860CPRG("SC9")
				cSeqSC9 := Soma1(cSeqSC9,Len(SC9->C9_SEQUEN))
				SC9->C9_SEQUEN   := cSeqSC9
				SC9->C9_QTDLIB   := aCols[nX][1] //Quantidade
				SC9->C9_QTDLIB2  := aCols[nX][3] //Quantidade
				SC9->C9_DATENT   := aCols[nX][5] //Data	
				MsUnlock("SC9")
				//Cria NJ5 se ja existir
				If NJ5->NJ5_STATUS $ "1|2|3|8"
					IF RecLock("NJ5", .T.)
						NJ5->NJ5_FILIAL := FWxFilial("NJ5")
						NJ5->NJ5_NUMPV 	:= SC9->C9_PEDIDO
						NJ5->NJ5_ITEM 	:= SC9->C9_ITEM
						NJ5->NJ5_SEQUEN := SC9->C9_SEQUEN
						NJ5->NJ5_PRODUT := SC9->C9_PRODUTO
						NJ5->NJ5_QTDE 	:= SC9->C9_QTDLIB
						NJ5->NJ5_UM 	:= NJ5UM
						NJ5->NJ5_QTDUM2 := SC9->C9_QTDLIB2
						NJ5->NJ5_UM2 	:= NJ5UM2
						NJ5->NJ5_LOCAL 	:= SC9->C9_LOCAL
						NJ5->NJ5_CULTRA := NJ5CULTRA
						NJ5->NJ5_CTVAR 	:= NJ5CTVAR
						NJ5->NJ5_CATEG 	:= NJ5CATEG
						NJ5->NJ5_PENE 	:= NJ5PENE
						NJ5->NJ5_TPFRET := NJ5TPFRET
						NJ5->NJ5_STATUS := NJ5STATUS
						NJ5->NJ5_CODSAF := NJ5CODSAF
						NJ5->NJ5_DTPREV := NJ5DTPREV
						NJ5->NJ5_DTPROG := aCols[nX][5]
						NJ5->NJ5_HRPROG := NJ5HRPROG
						If lAG860DES .and. aCposCust <> Nil
							For nD := 1 to Len(aNJ5Cust)
								&("NJ5->"+ALLTRIM(aNJ5Cust[nD][1])) := aNJ5Cust[nD][2]
							Next nD
						Endif	
						MsUnlock("NJ5")
					Else
						MsgInfo(STR0096 + " - NJ5") //"Não foi possivel dar reclock"
						DISARMTRANSACTION()				
					Endif
				Endif
			Next nX

		Else
			MsgInfo(STR0096 + " - SC9") //"Não foi possivel dar reclock"
			DISARMTRANSACTION()
		EndIf

	END TRANSACTION		

	oDlg:End()

	AGRA860TRB()

Return .T.

/*-------------------------------------------------------------------                                                                           
{Protheus.doc}AGR860CPRG
Copia todos os campos da tabela especificada do registro atual

@author Tamyris Ganzenmueller
@since 13/03/2017
@version 1.0
-------------------------------------------------------------------*/ 
Static Function AGR860CPRG(cTab)

	Local nX      := 0
	Local aFields := {}

	RecLock(cTab, .T.)
	aFields := FWSX3Util():GetAllFields( cTab, .F. )
	For nX := 1 To Len(aFields)
		&(cTab+"->"+ALLTRIM(aFields[nX]))  := aTab[nX]
	Next nX

	dbSelectArea(cTab)
Return aTab

/*/{Protheus.doc} AGRA860TRB
//Cria tabela temporaria
@author joaquim.burjack
@since 15/03/2017
@version undefined

@type function
/*/
Function AGRA860TRB()	
	Local cqry      := ''
	Local nX        := 0
	Local lRet		:= .T.
	Local aCamposQry := {"C6_FILIAL","C6_NUM","ISNULL(C9_QTDLIB,0) C9_QTDLIB","ISNULL(C9_QTDLIB2,0) C9_QTDLIB2",;
	"ISNULL(C9_SEQUEN,'') C9_SEQUEN","C6_CLI","C6_LOJA","A1_NOME","A1_MUN","A1_EST","C6_ITEM","C6_PRODUTO","B1_DESC","C6_QTDVEN","C6_UNSVEN","C6_UM","C6_SEGUM",;
	"C6_CULTRA","C6_CTVAR","ISNULL(NP4_DESCRI,'') NP4_DESCRI","C6_CATEG","C6_PENE","C6_LOCAL","C5_TPFRETE","C5_CODSAF","C5_VEND1","ISNULL(A3_NOME,'') A3_NOME","C5_EMISSAO"}

	//start query
	cqry := "SELECT "

	//input fields
	for nX:=1 to len(aCamposQry)
		cqry += aCamposQry[nX] + " , "  
	next nX

	//select
	cqry += " (CASE "	
	cqry += "	WHEN  COALESCE(PROGRAMACAO.NJ5_STATUS,'0') >=  2  THEN "  
	cqry += "		(CASE WHEN CAST(RTRIM(COALESCE(LIBERACAO_PEDIDO.C9_BLCRED,'0')) as INT) <  10 THEN '8' "
	cqry += 			" WHEN LIBERACAO_PEDIDO.C9_BLEST = '10'  THEN '7' " 	 
	cqry +=		        " WHEN LIBERACAO_PEDIDO.C9_CARGA <>  ' ' THEN '6' " 
	cqry +=		      	" ELSE PROGRAMACAO.NJ5_STATUS "
	cqry += 		" END) " 
	cqry += "   WHEN COALESCE(PROGRAMACAO.NJ5_STATUS,'0') = 0 THEN "  
	cqry += 		" (CASE WHEN COALESCE(LIBERACAO_PEDIDO.C9_QTDLIB,0)  = 0  THEN '4' "   
	cqry +=         " 		 WHEN LIBERACAO_PEDIDO.C9_QTDLIB  > 0 THEN '5' "
	cqry +=			"   END) " 
	cqry += "	ELSE PROGRAMACAO.NJ5_STATUS "	
	cqry += " END) SITUACAO, "
	//cqry += "	ISNULL(NJ5_DTPREV,) NJ5_DTPREV, "
	cqry += "	ISNULL(NJ5_DTPREV,C5_EMISSAO) NJ5_DTPREV, "
	cqry += "	ISNULL(NJ5_DTPROG,' ') NJ5_DTPROG, "
	cqry+=  "  (CASE "
	cqry += "	WHEN C5_TPFRETE = 'C' THEN 'CIF' "
	cqry += "   WHEN C5_TPFRETE = 'F' THEN 'FOB' "
	cqry += "   WHEN C5_TPFRETE = 'T' THEN 'TERCEIROS' "
	cqry += "   WHEN C5_TPFRETE = 'R' THEN 'REMETENTE' "
	cqry += "   WHEN C5_TPFRETE = 'D' THEN 'DESTINATARIO' "
	cqry += "   WHEN C5_TPFRETE = 'S' THEN 'SEM FRETE' "
	cqry += "   ELSE '-' "
	cqry += "   END) TPFRETE"

	//Adicionando os campos do cliente já com o ISNULL para que todo nulo seja preenchido com algum valor para não atrapalhar no INSERT
	for nX := 1 to len(_aCpsBrwPE)
		if TamSX3(_aCpsBrwPE[nX] )[3] = "N"
			cqry += ", "+ "ISNULL("+ _aCpsBrwPE[nX] +", 0 ) "+ _aCpsBrwPE[nX] +" "
		else
			cqry += ", "+ "ISNULL("+ _aCpsBrwPE[nX] +", ' ' ) "+ _aCpsBrwPE[nX] +" "
		endIf	
	next nX	

	cQry += " FROM " + RETSQLNAME('SC5') + ' PEDIDO '
	cQry += " INNER JOIN " + RETSQLNAME('SC6') + "  ITEM_PEDIDO ON ITEM_PEDIDO.D_E_L_E_T_ = ' ' AND ITEM_PEDIDO.C6_FILIAL = '"+xFilial("SC6")+"' AND  ITEM_PEDIDO.C6_NUM = PEDIDO.C5_NUM AND ITEM_PEDIDO.C6_BLQ <> 'R' "
	cQry += " INNER JOIN " + RETSQLNAME('SB1') + "  PRODUTO ON PRODUTO.D_E_L_E_T_ = ' ' AND PRODUTO.B1_FILIAL = '"+xFilial("SB1")+"'  AND PRODUTO.B1_COD = ITEM_PEDIDO.C6_PRODUTO "
	IF !Empty(MV_PAR08) .And. MV_PAR08 < 3
		cQry += " INNER JOIN " + RETSQLNAME('SB5') + "  COMPLEMENTO_PRODUTO ON  COMPLEMENTO_PRODUTO.D_E_L_E_T_ = ' ' AND COMPLEMENTO_PRODUTO.B5_FILIAL = '"+xFilial("SB5")+"' AND COMPLEMENTO_PRODUTO.B5_COD = PRODUTO.B1_COD "
		cQry += "AND  COMPLEMENTO_PRODUTO.B5_SEMENTE = '"+STR(MV_PAR08,1)+"' "
	End
	cQry += " LEFT JOIN  " + RETSQLNAME('SC9') + " LIBERACAO_PEDIDO  ON  LIBERACAO_PEDIDO.D_E_L_E_T_ = ' ' AND C9_FILIAL = '"+xFilial("SC9")+"' AND C9_PEDIDO = ITEM_PEDIDO.C6_NUM AND C9_ITEM = ITEM_PEDIDO.C6_ITEM AND C9_PRODUTO = ITEM_PEDIDO.C6_PRODUTO "
	cQry += " LEFT JOIN  " + RETSQLNAME('NJ5') + " PROGRAMACAO ON PROGRAMACAO.D_E_L_E_T_ = ' ' AND NJ5_FILIAL = '"+xFilial("NJ5")+"'   AND NJ5_NUMPV = LIBERACAO_PEDIDO.C9_PEDIDO  AND NJ5_ITEM = LIBERACAO_PEDIDO.C9_ITEM  AND NJ5_SEQUEN = LIBERACAO_PEDIDO.C9_SEQUEN   AND NJ5_PRODUT = LIBERACAO_PEDIDO.C9_PRODUTO" 
	cQry+= "  LEFT JOIN  " + RETSQLNAME('SA3') + " SA3 ON SA3.A3_FILIAL = '"+FWxFilial("SA3")+"' AND SA3.A3_COD = PEDIDO.C5_VEND1  AND SA3.D_E_L_E_T_ = ' ' "
	cQry+= "  LEFT JOIN  " + RETSQLNAME('NP4') + " NP4 ON NP4.NP4_FILIAL = '"+FWxFilial("NP4")+"' AND NP4.NP4_CODIGO = ITEM_PEDIDO.C6_CTVAR  AND NP4.D_E_L_E_T_ = ' ' "	
	cQry+= " INNER JOIN " + RETSQLNAME('SA1')  + " SA1 ON SA1.A1_COD = PEDIDO.C5_CLIENTE AND SA1.A1_LOJA = PEDIDO.C5_LOJACLI " 
	cQry+= "  AND SA1.D_E_L_E_T_ = ' ' "

	cQry += " WHERE PEDIDO.D_E_L_E_T_ = ' ' AND PEDIDO.C5_TPCARGA = '1' AND PEDIDO.C5_FILIAL = '"+xFilial("SC5")+"'" 

	If ! Empty(MV_PAR01)  	
		cQry += " AND C5_CODSAF = '" + MV_PAR01 + "' "
	EndIf	

	If ! Empty(MV_PAR02) .AND. ! Empty(MV_PAR03) 
		cQry += " AND ((NJ5_DTPROG IS NULL) "
		cQry += " OR (NJ5_DTPROG >= '" +  DTOS(MV_PAR02) + "' "
		cQry += " AND NJ5_DTPROG <= '" + DTOS(MV_PAR03) + "')) "
	EndIf

	If ! Empty(MV_PAR04)  	
		cQry += " AND C9_DATENT >= '" + DTOS(MV_PAR04) + "' "
	EndIf

	If ! Empty(MV_PAR05)  	
		cQry += " AND C9_DATENT <= '" + DTOS(MV_PAR05) + "' "
	EndIf

	If ! Empty(MV_PAR06)  	
		cQry += " AND C5_EMISSAO >= '" + DTOS(MV_PAR06) + "' "
	EndIf

	If ! Empty(MV_PAR07)  	
		cQry += " AND C5_EMISSAO <= '" + DTOS(MV_PAR07) + "' "
	EndIf	

	if MV_PAR09 == 2
		cQry += " UNION"
		cQry += " SELECT NJ5_FILIAL, NJ5_NUMPV, 0, 0, NJ5_SEQUEN,C5_CLIENTE,C5_LOJACLI,A1_NOME,A1_MUN,A1_EST,NJ5_ITEM,NJ5_PRODUT,"
		cQry += " B1_DESC,NJ5_QTDE, NJ5_QTDUM2, NJ5_UM, NJ5_UM2, NJ5_CULTRA, NJ5_CTVAR,ISNULL(NP4_DESCRI,'') NP4_DESCRI, NJ5_CATEG, NJ5_PENE, "
		cQry += " NJ5_LOCAL, NJ5_TPFRET, NJ5_CODSAF,C5_VEND1,ISNULL(A3_NOME,'') A3_NOME,C5_EMISSAO, NJ5_STATUS,NJ5_DTPREV, NJ5_DTPROG, NJ5_TPFRET "

		for nX := 1 to len(_aCpsBrwPE)
			if TamSX3(_aCpsBrwPE[nX] )[3] = "N"
				cQry += ", "+ "ISNULL("+ _aCpsBrwPE[nX] +", 0 ) "+ _aCpsBrwPE[nX] +" "
			else
				cQry += ", "+ "ISNULL("+ _aCpsBrwPE[nX] +", ' ' ) "+ _aCpsBrwPE[nX] +" "
			endIf	
		next nX	


		cQry+= " FROM " + RETSQLNAME('NJ5') + " NJ5 "
		cQry+= " INNER JOIN " + RETSQLNAME('SC5') + " SC5 ON NJ5.D_E_L_E_T_ = '*' "
		cQry+= "	AND NJ5.NJ5_NUMPV = SC5.C5_NUM "
		cQry+= "    AND NJ5.NJ5_CODSAF = SC5.C5_CODSAF"
		cQry+= "    AND SC5.D_E_L_E_T_ = ' ' "
		cQry+= "  LEFT JOIN  " + RETSQLNAME('SA3') + " SA3 ON SA3.A3_FILIAL = '"+FWxFilial("SA3")+"' AND SA3.A3_COD = SC5.C5_VEND1  AND SA3.D_E_L_E_T_ = ' ' "
		cQry+= "	INNER JOIN " + RETSQLNAME('SA1') + " SA1 ON SA1.A1_COD = SC5.C5_CLIENTE AND SA1.A1_LOJA = PEDIDO.C5_LOJACLI " 
		cQry+= "	   AND SA1.D_E_L_E_T_ = ' ' "
		cQry += " INNER JOIN " + RETSQLNAME('SB1') + "  PRODUTO ON PRODUTO.D_E_L_E_T_ = ' ' AND PRODUTO.B1_FILIAL = '"+FWxFilial("SB1")+"'  AND PRODUTO.B1_COD = NJ5.NJ5_PRODUT "
		cQry += " INNER JOIN " + RETSQLNAME('SC6') + "  ITEM_PEDIDO ON ITEM_PEDIDO.D_E_L_E_T_ = ' ' AND ITEM_PEDIDO.C6_FILIAL = '"+xFilial("SC6")+"' AND  ITEM_PEDIDO.C6_NUM = SC5.C5_NUM AND ITEM_PEDIDO.C6_BLQ <> 'R' "
		cQry += " LEFT JOIN  " + RETSQLNAME('SC9') + " LIBERACAO_PEDIDO  ON  LIBERACAO_PEDIDO.D_E_L_E_T_ = ' ' AND C9_FILIAL = '"+FWxFilial("SC9")+"' AND C9_PEDIDO = ITEM_PEDIDO.C6_NUM AND C9_ITEM = ITEM_PEDIDO.C6_ITEM AND C9_PRODUTO = ITEM_PEDIDO.C6_PRODUTO "
		cQry+= "  LEFT JOIN  " + RETSQLNAME('NP4') + " NP4 ON NP4.NP4_FILIAL = '"+FWxFilial("NP4")+"' AND NP4.NP4_CODIGO = NJ5.NJ5_CTVAR  AND NP4.D_E_L_E_T_ = ' ' "
	endIF

	cQry := ChangeQuery(cQry)	

	Processa({||AGRA860P(cQry)}, STR0097,STR0098,.F.)

	DbSelectArea(_cAliasTRB)
	(_cAliasTRB) -> (DBGoTop())

Return lRet

/*/{Protheus.doc} AGRA860P
Responsável pelo processamento da temptable.
@author brunosilva
@since 17/01/2017
@version undefined

@type function
/*/
Static Function AGRA860P(cQry)
	Local cCamposIns 	:= ""
	Local cCmpCli 		:= ""
	Local cInst 		:= ""
	Local cDel			:= ""
	Local nX			

	//tratamento campos adicionais
	for nX:=1 to len(_aCpsBrwPE)
		cCmpCli += ","+"Z"+STRTRAN(_aCpsBrwPE[nX], "_", "")
	next nX

	cCamposIns := 'FILIAL,PEDIDO,QTDLIB,QTDLIB2,SEQUENCIA,CLIENTE,LOJA,NOME,MUNICIPIO,UF,ITEM,PRODUTO,DESCPROD,QTDVEN,QTDVEN2,UM,UM2,CULTURA,CULTIVAR,NOMECTVAR,CATEGORIA,PENEIRA,LOCALI,TPF,SAFRA,VENDEDOR,NOMEVEND,EMISSAO,STATUS,DTPREV,DTPROG,TPFRETE'

	if !EMPTY(cCmpCli) //Se houver, acrescenta os campos customizados
		cCamposIns +=  cCmpCli 
	endIF	

	If RECCOUNT(_cAliasTRB) > 0
		cDel := "DELETE "+ oArqTemp:GetRealName()
		TCSQLExec(cDel)
	EndIf

	cInst := "INSERT INTO " + oArqTemp:GetRealName() + " (" + cCamposIns + " ) " + cQry 
	TCSQLExec(cInst)

Return

/*/{Protheus.doc} AG860PERG
//Função responsável por armazenar as perguntas do programa
@author brunosilva
@since 22/03/2017
@version undefined
@type function
/*/
Function AG860PERG()

	If IsInCallStack('AGRA860INC') .OR. IsInCallStack('AGRA860ALT') .OR. IsInCallStack('AGRA860VIS')
		Pergunte('AGRA860', .F.)
	Else
		Pergunte('AGRA860', .T.)
	EndIf
	AGRA860TRB()

	//__oOBrowse:DeActivate()
	__oOBrowse:Refresh()

Return

/*/{Protheus.doc} A860CONV
//Função responsável pela conversãp na moeda do produto.
@author brunosilva
@since 22/03/2017
@version undefined
@type function
/*/
Function A860CONV()
	If oGetD:oBrowse:nColPos = 1
		aCols[oGetD:oBrowse:nRowPos][3] := ConvUm((_cAliasTRB)->PRODUTO , M->C9_QTDLIB, aCols[oGetD:oBrowse:nLinhas][3], 2)
	ElseIf oGetD:oBrowse:nColPos = 3
		aCols[oGetD:oBrowse:nRowPos][1] := ConvUm((_cAliasTRB)->PRODUTO ,aCols[oGetD:oBrowse:nLinhas][1], M->C9_QTDLIB2, 1)
	EndIf
	oGetD:ForceRefresh ()
Return .T.

/*{Protheus.doc} AGRA860DCBW
Função de Seleção de itens do browser 
@author jean.schulze
@since 28/09/2017
@version undefined

@type function
*/
Static Function AGRA860DCBW()
	if RecLock((_cAliasTRB),.F.)	.and. !empty((_cAliasTRB)->PEDIDO) //tratamento de excessao - sempre posicionado
		(_cAliasTRB)->MARK = IIF((_cAliasTRB)->MARK  == "1", "", "1")	
		MsUnlock()	
	endif
return .t.

/*/{Protheus.doc} AGRA860REG
//reagendamento de programação de entrega(Reprogramação)
@author joaquim.burjack
@since 09/07/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function AGRA860REG()
	Local aItensUpd := {}
	Local oDlg      := nil
	Local dDate	    := dDataBase
	Local dHour     := SUBSTR(TIME(), 1, 5)  
	Local cValida   := ""
	Local aOptionCB := {"Não","Sim"}
	Local lOpcao    := .f.
	Local nX        := 0
	Local lret      := .t.

	DbSelectArea((_cAliasTRB))
	DbGoTop()

	While !(_cAliasTRB)->(Eof()) 

		if (_cAliasTRB)->MARK == "1" //somente os selecionados Agd. Aprovação, Aprovado, Aprovado Manualmente ou Com prog. e bloqueado Crédito

			if (_cAliasTRB)->status $ "1|2|3|8" //somente com os status

				//procura o relacionamento com a tabela NJ5
				dbSelectArea("NJ5")
				dbSetOrder(1)//NJ5_FILIAL+NJ5_NUMPV+NJ5_ITEM+NJ5_SEQUEN+NJ5_PRODUT
				if DbSeek(FWxFILIAL("NJ5")+(_cAliasTRB)->PEDIDO+(_cAliasTRB)->ITEM+(_cAliasTRB)->SEQUENCIA+(_cAliasTRB)->PRODUTO)
					aAdd(aItensUpd, {(_cAliasTRB)->PEDIDO,(_cAliasTRB)->ITEM,(_cAliasTRB)->SEQUENCIA,(_cAliasTRB)->PRODUTO})		
				else
					Help(,,STR0018,,STR0099,1,0) //Atenção ### "Itens sem relacionamento com a programação de entrega."
					return .f. //devolve para o browse
				endif

			else
				//informa que somente com os status pode Reagenda
				Help(,,STR0018,,STR0100,1,0) //Atenção ### "Somente podem ser Reagendados itens com os Status: Agd. Aprovação, Aprovado, Aprovado Manualmente ou Com prog. e bloqueado Crédito."
				return .f. //devolve para o browse
			endif

		endif

		(_cAliasTRB)->( dbSkip() )	
	enddo

	//temos a relação de selecionados para reagendamento
	if len(aItensUpd) > 0
		//abre a tela para saber o dia e se será aplicado a reserva
		oDlg	:= TDialog():New(200,406,400,750,STR0101,,,,,CLR_BLACK,CLR_WHITE,,,.t.) //"Reagendamento" 
		oDlg:lEscClose := .f.

		@ 035,008 SAY STR0102 PIXEL //"Data"		
		@ 032,024 MSGET dDate OF oDlg PIXEL WHEN .t.

		@ 035,092 SAY STR0103 PIXEL //"Horário" 
		@ 032,130 MSGET dHour OF oDlg PIXEL WHEN .t. PICTURE "99:99"

		@ 056,008 SAY STR0104 PIXEL //"Revalidar Programações?"	
		@ 064,008 COMBOBOX cValida ITEMS aOptionCB OF oDlg PIXEL WHEN .t.

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| lOpcao := .T., oDlg:End()},{|| lOpcao := .F.,oDlg:End()}) CENTERED

		//pergunta se quer mostrar aplicar o reagendamento para o x itens
		if lOpcao .and. MsgYesNo(STR0105+alltrim(str(len(aItensUpd)))+STR0106) //"Deseja alterar a data das (" ### ") programações de entrega?"  

			BEGIN TRANSACTION 

				for nX:=1 to len(aItensUpd) 

					if lRet 
						DbSelectArea("NJ5")
						NJ5->(DbGoTop())
						lRet := NJ5->(DbSeek(FWxFILIAL("NJ5")+aItensUpd[nX][1]+aItensUpd[nX][2]+aItensUpd[nX][3]+aItensUpd[nX][4]))
					endif

					if lRet
						If cValida == "Não"
							If RecLock("NJ5", .F.)
								NJ5->NJ5_DTPROG := dDate
								NJ5->NJ5_HRPROG := dHour
								NJ5->(MsUnlock())

								DbSelectArea("SC9")
								SC9->(DbSetOrder(1))
								SC9->(DbGoTop())
								SC9->(DbSeek(FWxFILIAL("SC9")+aItensUpd[nX][1]+aItensUpd[nX][2]+aItensUpd[nX][3]+aItensUpd[nX][4]))
								If RecLock("SC9", .F.)
									SC9->C9_DATENT := NJ5->NJ5_DTPROG
									SC9->(MsUnlock())
								else 
									lRet := .f.
								EndIf
							else 
								lRet := .f.		
							Endif
						elseif AGRA950VAL('NJ5') //tem validacao
							If RecLock("NJ5", .F.)
								NJ5->NJ5_STATUS := "2" //Aprovado
								NJ5->NJ5_DTPROG := dDate
								NJ5->NJ5_HRPROG := dHour
								NJ5->(MsUnlock())

								DbSelectArea("SC9")
								SC9->(DbSetOrder(1))
								SC9->(DbGoTop())
								SC9->(DbSeek(FWxFILIAL("SC9")+aItensUpd[nX][1]+aItensUpd[nX][2]+aItensUpd[nX][3]+aItensUpd[nX][4]))
								If RecLock("SC9", .F.)
									SC9->C9_DATENT := NJ5->NJ5_DTPROG
									SC9->(MsUnlock())
								else 
									lRet := .f.								
								EndIf
							else 
								lRet := .f.		
							EndIf
						Else
							If RecLock("NJ5", .F.)
								NJ5->NJ5_STATUS := "1" //Agd. Aprovação
								NJ5->NJ5_DTPROG := dDate
								NJ5->NJ5_HRPROG := dHour
								NJ5->(MsUnlock())
							else 
								lRet := .f.	
							Endif
						EndIf
					else
						lRet := .f.	
					endif

					if !lRet
						DisarmTransaction() //rollback
					endif	
				next nX	

			END TRANSACTION  	

			if !lRet //fora da transação 
				Help(,,STR0018,,STR0107,1,0) //Atenção ### "Ocorreu um erro ao gravar o reagendamento."
				return .f. //devolve para o browse
			else
				Help(,,STR0018,,STR0108+alltrim(str(len(aItensUpd)))+STR0109,1,0) //Atenção ### "Data das (" ### ") programações de entrega alteradas!"
			endif
		endif

		//Refaz a select e a tela
		AGRA860TRB()
	else
		Help(,,STR0018,,STR0110,1,0) //Atenção ### "É necessário selecionar ao menos 1(um) item para reagendamento."
		return .f. //devolve para o browse
	endif	
return .t.
