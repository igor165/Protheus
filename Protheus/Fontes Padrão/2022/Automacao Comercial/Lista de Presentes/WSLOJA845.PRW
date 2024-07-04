#INCLUDE "Protheus.ch"
#INCLUDE "ApWebSrv.ch"
#INCLUDE "WSLOJA845.ch"

#DEFINE POS_MMODO		1		//Modo de abertura
#DEFINE POS_MRET		2       //Modo de retorno
#DEFINE POS_MTPL		3		//Tipo da lista
#DEFINE POS_MNL			4		//Numero da lista (Filtro ME1)
#DEFINE POS_MONL		5		//Online
#DEFINE POS_MLNOM		6		//Entrar com nomes dos presenteadores
#DEFINE POS_MLENVM		7		//Enviar mensagem
#DEFINE POS_MLITAB		8		//Listar itens em aberto
#DEFINE POS_MORI		9		//Origem da lista (filtro ME1)
#DEFINE POS_MFILT		10		//Filtro (ME2)
#DEFINE POS_MMULT		11		//Multi-selecao
#DEFINE POS_MMTOD		12		//Marcar todos
#DEFINE POS_MQTDU		13		//Quantidade utilizada
#DEFINE POS_MLAQTD		14		//Alterar quantidade
#DEFINE POS_MAME		15		//Alterar modo de entrega
#DEFINE POS_MTPEVE		16		//Tipo de evento (filtro ME1)
#DEFINE POS_MSTAT		17		//Status da lista (filtro ME1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบWebServiceณWSLOJA845  บAutor  ณVendas Clientes       บ Data ณ   11/03/11  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณWebservice para realizacao de pesquisa de lista de presentes,  บฑฑ
ฑฑบ          ณitens da lista, atores, entregas programadas e mensagens padraoบฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

//Estrutura de dados para retorno de dados
WSSTRUCT aRetMod
	WSDATA cRetorno 	AS String
ENDWSSTRUCT

WSSERVICE WSLOJA845
	
	//Array de retorno
	WSDATA aRetorno		AS Array OF aRetMod
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVariaveis para utilizacao da funcao Lj845PesqC  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	WSDATA cEmp01		AS String
	WSDATA cFil01		AS String
	WSDATA cLstCmp01	AS String
	WSDATA cFiltro		AS String
	WSDATA nOrdem01		AS Integer		OPTIONAL
	WSDATA lTCBox01		AS Boolean		OPTIONAL
	WSDATA cLCFG		AS String
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVariaveis para utilizacao da funcao Lj845RetD   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	WSDATA cEmp02		AS String
	WSDATA cFil02		AS String
	WSDATA cAlias01		AS String
	WSDATA cQryW		AS String
	WSDATA cLstCmp02	AS String
	WSDATA nOrdem02		AS Integer		OPTIONAL
	WSDATA lTCBox02		AS Boolean		OPTIONAL
	
	WSMETHOD Lj845PesqC	DESCRIPTION STR0001 //"Busca de lista de presentes mediante criterios de pesquisa"
	WSMETHOD Lj845RetD		DESCRIPTION	STR0002 //"Busca multi-tabela mediante criterios definidos"

ENDWSSERVICE

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบMetodo    ณLj845PesqCบAutor  ณVendas Cliente        บ Data ณ11/03/11         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo para consulta de listas de presentes.                      บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[C] : Filial de pesquisa                                     บฑฑ
ฑฑบ          ณExp02[C] : Numero da lista                                        บฑฑ
ฑฑบ          ณExp03[C] : Origem da lista                                        บฑฑ
ฑฑบ          ณExp04[C] : Status da lista                                        บฑฑ
ฑฑบ          ณExp05[C] : Lista de campos para pesquisa                          บฑฑ
ฑฑบ          ณExp06[C] : Array com os criterios de pesquisa                     บฑฑ
ฑฑบ          ณExp07[N] : Ordem de classificacao a ser utilizado                 บฑฑ
ฑฑบ          ณExp08[N] : Tratar valor de campos com combobox?                   บฑฑ
ฑฑบ          ณExp09[C] : Lista de configuracoes (apenas para webservice)        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณaRetorno[A] : Array com o resultado da busca, com os campos defin.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

WSMETHOD Lj845PesqC WSRECEIVE cEmp01,cFil01,cLstCmp01,cFiltro,nOrdem01,lTCBox01,cLCFG WSSEND aRetorno WSSERVICE WSLOJA845

Local cRotina	 		:= "[WSLOJA845:Lj845PesqC]" + Space(1)			// 
Local lOk				:= .T.
Local lRet				:= .T.
Local cDel				:= "|"											//Delimitador
Local aLstCmp			:= {}											//Lista de campos
Local aFiltro			:= {}											//Lista de filtros
Local aLCFG				:= {}											//Lista de filtros por configurador
Local aTMP				:= {}											//Array temporario
Local ni				:= 0											//Contador
Local nx				:= 0											//Contador 02
Local nPos				:= 0											//Posicionador

Default cLstCmp01		:= ""
Default cFiltro			:= ""
Default nOrdem01		:= 1
Default lTCBox01		:= .T.
Default cLCFG			:= ""

ConOut(cRotina + STR0003) //"Iniciando"
aLstCmp	:= IIf(!Empty(cLstCmp01),StrTokArr(cLstCmp01,cDel),Array(0))
aFiltro	:= IIf(!Empty(cFiltro),StrTokArr(cFiltro,cDel),Array(0))
aLCFG	:= IIf(!Empty(cLCFG),StrTokArr(cLCFG,cDel),Array(0))
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValidacoes e conexao  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty(::cEmp01) .OR. Empty(::cFil01) .OR. ValType(aLstCmp) # "A" .OR. Len(aLstCmp) == 0 .OR. ValType(aLCFG) # "A" .OR. ;
	Len(aLCFG) == 0 .OR. !FindFunction("EnvWSOk")
	
	lOk := !lOk              
Else
	//Prepara a configuracao de ambiente
	lOk := EnvWSOk(.T.,::cEmp01,::cFil01)
Endif
//Converter os arrays de filtro
For ni := 1 to Len(aFiltro)
	aFiltro[ni] := &(aFiltro[ni])
Next ni
//Acertar os tipos de dados do array de parametros de configuracao com tipos de dados diferentes de caracter
aLCFG[POS_MMODO]	:= GetDToVal(aLCFG[POS_MMODO])
aLCFG[POS_MRET]		:= GetDToVal(aLCFG[POS_MRET])
aLCFG[POS_MONL]		:= &(aLCFG[POS_MONL])
aLCFG[POS_MLNOM]	:= &(aLCFG[POS_MLNOM])
aLCFG[POS_MLENVM]	:= &(aLCFG[POS_MLENVM])
aLCFG[POS_MLITAB]	:= &(aLCFG[POS_MLITAB])
aLCFG[POS_MMULT]	:= &(aLCFG[POS_MMULT])
aLCFG[POS_MMTOD]	:= &(aLCFG[POS_MMTOD])
aLCFG[POS_MLAQTD]	:= &(aLCFG[POS_MLAQTD])
aLCFG[POS_MAME]		:= &(aLCFG[POS_MAME])
aLCFG[POS_MQTDU]	:= IIf(!Empty(aLCFG[POS_MQTDU]),&(aLCFG[POS_MQTDU]),{})
//Inicializando variavel de retorno
aAdd(::aRetorno,WSClassNew("aRetMod"))
If !lOk
	::aRetorno[1]:cRetorno := ""
	ConOut(cRotina + STR0004 + ::cEmp01 + STR0005 + ::cFil01 + STR0006) //"Nใo foi possํvel conectar o ambiente na empresa : "###" filial : "###". Execu็ใo do WS cancelada!"
	Return .T.
Endif
//Executar a busca
aTMP := Lj845PesqC("",aLstCmp,aFiltro,::nOrdem01,::lTCBox01,aLCFG)
If ValType(aTMP) # "A" .OR. Len(aTMP) == 0
	::aRetorno[1]:cRetorno := ""
	lRet := .F.
Else
	For ni := 1 to Len(aTMP)
		cTMP := ""
		If ni == 1
			nPos := 1
		Else
			aAdd(::aRetorno,WSClassNew("aRetMod"))
			nPos := Len(::aRetorno)
		Endif
		For nx := 1 to Len(aTMP[ni])
			cTMP += AllToChar(aTMP[ni][nx]) + cDel
		Next nx
		::aRetorno[nPos]:cRetorno := cTMP
	Next ni
Endif
ConOut(cRotina + STR0007 + cValToChar(lRet) + " " + IIf(lRet,cValToChar(Len(::aRetorno)),"0")) //"Registros encontrados? "

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบMetodo    ณLj845RetD บAutor  ณVendas Cliente        บ Data ณ11/03/11         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo de retorno de dados de pesquisa, baseado em tabela e crite-บฑฑ
ฑฑบ          ณrio de pesquisa                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[C] : Filial de pesquisa                                     บฑฑ
ฑฑบ          ณExp02[C] : Tabela de pesquisa                                     บฑฑ
ฑฑบ          ณExp03[C] : Clausula de restricao para a query                     บฑฑ
ฑฑบ          ณExp04[C] : Lista de campos de retorno                             บฑฑ
ฑฑบ          ณExp05[L] : Auto-substituir valor de campos combo                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณaRetorno[A]  : Array com os dados encontrados                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

WSMETHOD Lj845RetD	WSRECEIVE cEmp02,cFil02,cAlias01,cQryW,cLstCmp02,nOrdem02,lTCBox02 WSSEND aRetorno WSSERVICE WSLOJA845

Local cRotina	 		:= "[WSLOJA845:Lj845RetD]" + Space(1)          //
Local lOk				:= .T.                                         //
Local lRet				:= .T.                                         //
Local cDel				:= "|"										    //Delimitador
Local aLstCmp			:= {}											//Lista de campos
Local aTMP				:= {}											//Array temporario
Local ni				:= 0											//Contador
Local nx				:= 0											//Contador 02
Local nPos				:= 0											//Posicionador

Default cAlias01		:= ""
Default cQryW			:= ""
Default cLstCmp02		:= ""
Default nOrdem02		:= 1
Default lTCBox02		:= .F.

ConOut(cRotina + STR0003) //"Iniciando"
aLstCmp	:= IIf(!Empty(::cLstCmp02),StrTokArr(::cLstCmp02,cDel),Array(0))
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValidacoes e conexao  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty(::cEmp02) .OR. Empty(::cFil02) .OR. ValType(aLstCmp) # "A" .OR. Len(aLstCmp) == 0 .OR. !FindFunction("EnvWSOk")
	lOk := !lOk
Else
	//Prepara a configuracao de ambiente
	lOk := EnvWSOk(.T.,::cEmp02,::cFil02)
Endif
//Inicializando variavel de retorno
aAdd(::aRetorno,WSClassNew("aRetMod"))
If !lOk
	::aRetorno[1]:cRetorno := ""
	ConOut(cRotina + STR0004 + ::cEmp02 + STR0005 + ::cFil02 + STR0006) //"Nใo foi possํvel conectar o ambiente na empresa : "###" filial : "###". Execu็ใo do WS cancelada!"
	Return .T.
Endif
//Executar a busca
aTMP := Lj845RetD("",::cAlias01,::cQryW,aLstCmp,::nOrdem02,::lTCBox02)
If ValType(aTMP) # "A" .OR. Len(aTMP) == 0
	::aRetorno[1]:cRetorno := ""
	lRet := .F.
Else
	For ni := 1 to Len(aTMP)
		cTMP := ""
		If ni == 1
			nPos := 1
		Else
			aAdd(::aRetorno,WSClassNew("aRetMod"))
			nPos := Len(::aRetorno)
		Endif
		For nx := 1 to Len(aTMP[ni])
			cTMP += AllToChar(aTMP[ni][nx]) + cDel
		Next nx
		::aRetorno[nPos]:cRetorno := cTMP
	Next ni
Endif
ConOut(cRotina + STR0007 + cValToChar(lRet) + " " + IIf(lRet,cValToChar(Len(::aRetorno)),"0")) //"Registros encontrados? "

Return .T.