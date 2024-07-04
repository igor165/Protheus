#INCLUDE "Protheus.ch"
#INCLUDE "Loja843.ch"

#DEFINE PESQUISAR 		1
#DEFINE VISUALIZAR		2
#DEFINE INCLUIR	  		3
#DEFINE ALTERAR	  		4
#DEFINE EXCLUIR	  		5

#DEFINE POS_CMP	  		2
#DEFINE POS_TIPO  		8
#DEFINE POS_TAM	  		4
#DEFINE POS_DEC	  		5
#DEFINE POS_CNT	  		10
#DEFINE POS_COD	  		1												//Posicao do codigo do produto
#DEFINE POS_QTD	  		2												//Posicao da quantidade
#DEFINE POS_PRC	  		3												//Posicao do preco unitario
#DEFINE POS_ITEM 		4												//Posicao do item
#DEFINE POS_DESC 		5												//Posicao da decricao do produto
#DEFINE POS_UM	  		6												//Posicao de unidade de medida
#DEFINE POS_VEND 		7												//Posicao do vendedor
#DEFINE POS_SUG	  		8												//Posicao da sugestao
#DEFINE POS_FILO 		9												//Filial de origem
#DEFINE POS_NOVO 		10												//Posicao do indicador de item novo
#DEFINE POS_BLQ	 		11												//Posicao do indicador de item bloqueado
#DEFINE POS_CPO	   		12												//Campos obrigatorios ausentes
#DEFINE POS_PNE	   		13												//Produto nao existe

Static nPercUtO			:= 1										//Percentual de utilizacao da area dos objetos de janela da FWLayer
Static nOperacao		:= 0                                        //opcao de manutencao quando nao for autoexec
Static aLstCmpOb1		:= {}										//Lista de campos obrigatorios da enchoice
Static aLstCmpOb2		:= {}										//Lista de campos obrigatorios das getdados
Static lNovo			:= .F.										//Operacao de inclusao de registros?
Static lEdita			:= .F.										//Operacao eh de edicao?
Static cRotina			:= "LOJA843"								//Nome da rotina
Static nTotBot			:= 3										//Total de controles do tipo botao na tela

Static aCl3Ant			:= {}							            //checa campos da lista no SX3
Static oGD01_LST													//Grid de atores
Static aAutoCab			:= {}                                      //cabecalho via WebMail
Static aAutoItME2		:= {}                                      //Itens via WebMail
Static aAutoItMEE		:= {}                                      //Atores via WebMail
Static aAutoItMEH		:= {}                                      //Prazo de entrega via WebMail

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณLoja843   บAutor  ณVendas Cliente        บ Data ณ18/02/11         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para cadastro de lista de presentes.                       บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[N] : Opcao edicao automatica                                บฑฑ
ฑฑบ          ณExp02[A] : Matriz automatica ME1                                  บฑฑ
ฑฑบ          ณExp03[A] : Matriz automatica ME2                                  บฑฑ
ฑฑบ          ณExp04[A] : Matriz automatica MEE                                  บฑฑ
ฑฑบ          ณExp05[A] : Matriz automatica MEH                                  บฑฑ
ฑฑบ          ณExp06[N] : Opcao de abertura                                      บฑฑ
ฑฑบ          ณExp07[C] : Codigo da lista                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Loja843(	nOpcAuto	,xAutoCab	,xAutoItME2	,xAutoItMEE,;
					xAutoItMEH	,nOpc		,cNumLst)

Local lLstPre			:= SuperGetMV("MV_LJLSPRE",.T.,.F.) .AND. IIf(FindFunction("LjUpd78Ok"),LjUpd78Ok(),.F.)	//Lista de presente ativa?
Local cAlias01			:= "ME1"									/// area de trabalho
Local cAlias02			:= "MEE"									/// area de trabalho
Local cAlias03			:= "ME2"									/// area de trabalho
Local oArea				:= FWLayer():New()							/// objeto das areas de trabalho
Local aCoord			:= FWGetDialogSize(oMainWnd)				//Coordenadas da tela
Local lMDI				:= Iif(ExistFunc("LjIsMDI"),LjIsMDI(),oApp:lMDI) //Verifica se acessou via SIGAMDI
Local cTitulo			:= ""										//Titulo da rotina
Local aTamObj			:= Array(4)									//Dimensoes do objeto
Local aHeader02			:= {}										//Cabecalho da GD de atores
Local aHeader03   		:= {}										//Cabecalho da GD de produtos
Local aHeader04			:= {}										//Cabecalho da GD de entregas futuras
Local aCols02			:= {}										//Cabecalho da GD de atores
Local aCols03			:= {}										//Cabecalho da GD de produtos
Local aCols04			:= {}										//Cabecalho da GD de entregas futuras
Local cLinOk01			:= "Loja843LOK(,,1)"						//Validacao dos dados da linha da getdados de atores
Local cTudoOk01			:= "Loja843TOK(,1)"							//Validacao de todo o conteudo da getdadas de atores
Local cLinOk02			:= "Loja843LOK(,,2)"						//Validacao dos dados da linha da getdados de produtos
Local cTudoOk02			:= 'Loja843TOK(,2)'							//Validacao de todo o conteudo da getdadas de produtos
Local cLinDel02			:= "Loja843DOK()"							//Validacao de exclusao de linha
Local cDelTodos			:= "AllwaysFalse()"							//Validacao para CTRL+Delete
Local cCmpOk02			:= "Lj843COk02()"
Local aLstCmp01			:= {}										//Lista de campos da enchoice
Local aLstCmp02			:= {}										//Lista de campos da GD de atores
Local aLstCmp03 		:= {}										//Lista de campos da GD de produtos
Local aLstCmpA01		:= {}										//Lista de campos alteraveis da enchoice
Local aLstCmpA02		:= {}										//Lista de campos alteraveis da GD de atores
Local aLstCmpA03		:= {}										//Lista de campos alteraveis da GD de produtos
Local aLstCmpNL			:= {"ME2_CODIGO","MEE_CODLIS"}				//Lista de campos para nao listar
Local aLstCmpVis		:= {"ME2_ITEM"	,"ME2_FONTE" ,"ME2_QTDATE",;	//Lista de campos para visualizacao (nao definidos no SX3)
							"ME1_CODIGO","ME1_TPEVEN","ME1_CODCLI",;
							"ME1_LOJCLI","ME1_EXTRA" ,"ME1_VEND"}
Local lRet				:= .T.										//Variavel de retorno
Local aArea				:= {}
Local aTabs				:= {"ME1","ME2","ME3","MEE","MEF","MEH",; 	//Lista de tabelas para controle de area
							"SA1","SU5"}
Local cIniCpos02		:= "+ME2_ITEM"								//Inicializacao de campos
Local nLimLin01			:= 99										//Limite de linhas para a getdados de atores
Local nLimLin02			:= 9999										//Limite de linhas para a getdados de produtos
Local ni				:= 0										//Contador
Local cChave			:= ""										//Chave de pesquisa
Local nUsado			:= 0										//Total de campos utilizados
Local nPos				:= 0										//Controle de posicionamento
Local cLstCmpV			:= ""										//Lista de campos virtuais
Local cTMP				:= ""										//Variavel temporaria
Local cCond				:= ""										//Condicao
Local lOk				:= .T.										//Controle de fluxo
Local nSituaSX8  		:= GetSx8Len()								//Posicao atual de peticao para proximo registro
Local cChvRes			:= ""										//Reserva de palavra
Local lSalvaEd			:= .T.										//Determinar se pode-se alterar a enchoice e o grid de atores, pode ser alterado pelo PE Lj843HabSl

//Objetos graficos
Local oDlg
Local oPainel01											   			//Dados do evento
Local oPainel02											   			//Atores
Local oPainel03											   			//Lista de produtos
Local oPainel04											   			//Funcoes
Local oEnch															//Enchoice de dados da lista
Local oBot01														//Botao Fechar
Local oBot03														//Botao Coletar PDA
Local oBot04														//Botao Conta Corrente
Local oBot05														//Botao Encerrar lista
Local oBot06														//Botao Sugestao
Local oBot07														//Botao Entrega futura
Local oBot08														//Botao Imprimir
Local oBot09														//Botao Salvar
Local nPosME1Or                                                     //Posicao da coluna Origem
Local cErr1
Local lBtEncLst 		:= .T.												//Flag Habilita Botao Encerrar Lista
Local nx 				:= 1
Private aHeader			:= {}											// variaveis de sistema
Private aCols			:= {}											// variaveis de sistema
Private aRotina			:= MenuDef()									// variaveis de sistema
Private oGD02_LST													//Grid de produtos


Default nOpcAuto		:= 0
Default xAutoCab		:= {}
Default xAutoItME2		:= {}
Default xAutoItMEE		:= {}
Default xAutoItMEH		:= {}
Default nOpc			:= INCLUIR
Default cNumLst			:= ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerificar se o pacote de lista de presente esta devidamente aplicado e/ou configurado.  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !lLstPre  
    If ! SuperGetMV("MV_LJLSPRE",.T.,.F.)
       cErr1:= "1"
    Elseif ! FindFunction("LjUpd78Ok")
       cErr1:= "2"
    Elseif ! LjUpd78Ok()
       cErr1:= "3"
    Else
       cErr1:= "4"   
    Endif
	Help(" ",1,"LJLISPREA"+cErr1)	
	lRet := .F.
	Return lRet
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializacao de variaveis e ambiente  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

lLj843Auto := (!Empty(nOpcAuto) .AND. ;
				(ValType(xAutoCab) == "A") .AND. ;
				(ValType(xAutoItME2) == "A") .AND. ;
				(ValType(xAutoItMEE) == "A"))

If !lLj843Auto
	nOperacao := nOpc
Else
	aAutoCab 	:= xAutoCab      
	aAutoItME2	:= xAutoItME2
	aAutoItMEE	:= xAutoItMEE
	aAutoItMEH	:= xAutoItMEH
	nOperacao 	:= nOpcAuto
Endif
lNovo := (nOperacao == INCLUIR)
If !lNovo .AND. Empty(cNumLst)
	lRet := .F.
	Return lRet
Endif
If nOperacao == INCLUIR .OR. nOperacao == ALTERAR
	lEdita := .T.
Endif
//Armazenando dados da area de trabalho
For ni := 1 to Len(aTabs)
	aAdd(aArea,(aTabs[ni])->(GetArea()))
Next ni
//Definindo o titulo da rotina
If !lLj843Auto
	cTitulo := AllTrim(FWX2Nome(cAlias01))
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerificar em caso de edicao se a lista existe e se nao esta em uso  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea(cAlias01)
(cAlias01)->(DbSetOrder(2))	//ME1_FILIAL+ME1_CODIGO+ME1_TIPO+ME1_CODCLI+ME1_LOJCLI
If !lNovo
	//Buscar a lista
	If !(cAlias01)->(DbSeek(xFilial(cAlias01) + cNumLst))
		Help(" ",1,"LJ843NREC")
		aEval(aArea,{|x| RestArea(x)})
		Return !lRet
	Else
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCaso a lista tenha sido encontrada, verificar se a mesma nao   ณ
		//ณesta INATIVA, caso esteja passar a operacao para VISUALIZACAO  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If nOperacao == ALTERAR .AND. (cAlias01)->ME1_STATUS == "2"
			nOperacao := VISUALIZAR
			lEdita := .F.
		Endif
	Endif
	//Reserva do palavra da lista de presentes
	If nOperacao == ALTERAR .OR. nOperacao == EXCLUIR
		cChvRes := cRotina + xFilial("ME1") + (cAlias01)->ME1_CODIGO
		If !MayIUseCode(cChvRes)
			Help(" ",1,"LJ843BLQ")
			Return !lRet
		Endif
	Endif
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializacao de variaveis da Enchoice  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RegToMemory(cAlias01,lNovo)
If !lLj843Auto
	If nOperacao == INCLUIR 
		If Type("M->ME1_FILORI") # "U"
			M->ME1_FILORI := FWGETCODFILIAL
		Endif
	Else
		If Type("M->ME1_MENSAG") # "U"
			M->ME1_MENSAG := PadR(Lj843RtSYP(M->ME1_CODMEN,"ME1_CODMEN",GetSx3Cache("ME1_MENSAG","X3_TAMANHO")),TamSX3("ME1_MENSAG")[1])
		Endif
		//Carregar os dados de entregas futuras
		If AllTrim((cAlias01)->ME1_TIPO) == "3"
			Loja843PEP(@aCols04,@aHeader04,lMDI,.F.)		
		Endif		
	Endif
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLista de campos da Enchoice - ME1 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aCpos := FWSX3Util():GetAllFields(cAlias01)
For nx := 1 to len(aCpos)
	If X3Uso(GetSx3Cache(aCpos[nx],"X3_USADO")) .AND. cNivel >= GetSx3Cache(aCpos[nx],"X3_NIVEL")
		aAdd(aLstCmp01,aCpos[nx])
		//Caso seja obrigatorio, adicionar o item a lista de itens obrigatorios
		If X3Uso(GetSx3Cache(aCpos[nx],"X3_USADO")) .AND. (X3OBRIGAT(aCpos[nx]) .OR. VerByte(GetSx3Cache(aCpos[nx],"X3_RESERV"),7))
			aAdd(aLstCmpOb1,aCpos[nx])
		Endif
		//Verificar se o campo pode ser editado na operacao de alteracao do registro
		If nOperacao == ALTERAR .AND. GetSx3Cache(aCpos[nx],"X3_VISUAL") # "V"
			If aScan(aLstCmpVis,{|x| x == Upper(AllTrim(aCpos[nx]))}) == 0
				aAdd(aLstCmpA01,aCpos[nx])
			Endif
		Else
			aAdd(aLstCmpA01,aCpos[nx])
		Endif
	EndIf
Next nx
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLista de campos e dados da GD de Atores - MEE ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cLstCmpV := ""
aCpos := FWSX3Util():GetAllFields(cAlias02)
For nx := 1 to len(aCpos)
	If X3Uso(GetSx3Cache(aCpos[nx],"X3_USADO")) .AND. cNivel >= GetSx3Cache(aCpos[nx],"X3_NIVEL") .AND. aScan(aLstCmpNL,{|x| x == Upper(AllTrim(aCpos[nx]))}) == 0
		aAdd(aLstCmp02,aCpos[nx])
		//Caso seja obrigatorio, adicionar o item a lista de itens obrigatorios
		If X3Uso(GetSx3Cache(aCpos[nx],"X3_USADO")) .AND. (X3OBRIGAT(aCpos[nx]) .OR. VerByte(GetSx3Cache(aCpos[nx],"X3_RESERV"),7))
			aAdd(aLstCmpOb2,aCpos[nx])
		Endif
		//Campos virtuais
		If GetSx3Cache(aCpos[nx],"X3_CONTEXT") == "V"
			cLstCmpV += Upper(AllTrim(aCpos[nx])) + "|"
		Endif
		//Cabecalho - Estrutura MsNewGetDados
		aAdd(aHeader02,{RTrim(X3Titulo()),;
						aCpos[nx],;
						GetSx3Cache(aCpos[nx],"X3_PICTURE"),;
						GetSx3Cache(aCpos[nx],"X3_TAMANHO"),;
						GetSx3Cache(aCpos[nx],"X3_DECIMAL"),;
						GetSx3Cache(aCpos[nx],"X3_VALID"),;
						GetSx3Cache(aCpos[nx],"X3_USADO"),;
						GetSx3Cache(aCpos[nx],"X3_TIPO"),;
						GetSx3Cache(aCpos[nx],"X3_F3"),;
						GetSx3Cache(aCpos[nx],"X3_CONTEXT"),;
						GetSx3Cache(aCpos[nx],"X3_CBOX"),;						
						GetSx3Cache(aCpos[nx],"X3_RELACAO"),;
						GetSx3Cache(aCpos[nx],"X3_WHEN"),;
						IIf((nPos := aScan(aLstCmpVis,{|x| x == Upper(AllTrim(aCpos[nx]))})) == 0,GetSx3Cache(aCpos[nx],"X3_VISUAL"),"V"),;
						GetSx3Cache(aCpos[nx],"X3_VLDUSER"),;
						GetSx3Cache(aCpos[nx],"X3_PICTVAR"),;
						GetSx3Cache(aCpos[nx],"X3_OBRIGAT")})
	Endif
Next nx

aLstCmpA02 := aClone(aLstCmp02)
nUsado := Len(aHeader02)
If nOperacao == INCLUIR
	aCols02 := {Array(nUsado + 1)}
	//Inicializacao das variaveis
	aTail(aCols02[1]) := .F.
	For ni := 1 to nUsado
		aCols02[1][ni] := CriaVar(aHeader02[ni][POS_CMP])
	Next ni
Else
	aCols02 := Array(0)
	cChave := RTrim(xFilial(cAlias02) + ME1->ME1_CODIGO)
	//Pesquisar dados gravados da lista
	DbSelectArea(cAlias02)
	(cAlias02)->(DbSetOrder(1))
	(cAlias02)->(DbSeek(cChave))
	While !(cAlias02)->(Eof()) .AND. RTrim((cAlias02)->(MEE_FILIAL + MEE_CODLIS)) == cChave
		aAdd(aCols02,Array(nUsado + 1))
		nPos := Len(aCols02)
		If nPos > 0
			aTail(aCols02[nPos]) := .F.
			For ni := 1 to nUsado
				Do Case
					Case Upper(AllTrim(aHeader02[ni][POS_CMP])) $ cLstCmpV
						If Upper(AllTrim(aHeader02[ni][POS_CMP])) == "MEE_TPATOR"
							aCols02[nPos][ni] := GetAdvfVal("ME5","ME5_DESCRI",xFilial("ME5") + MEE->MEE_CODATO,1)
						Endif
					Otherwise
						aCols02[nPos][ni] := (cAlias02)->(FieldGet(FieldPos(aHeader02[ni][POS_CMP])))
				EndCase
			Next ni
		EndIf
		(cAlias02)->(DbSkip())
	End
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLista de campos e dados da GD de Produtos - ME2 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aCl3Ant	:= {}
cLstCmpV := ""
aCpos := FWSX3Util():GetAllFields(cAlias03)
For nx := 1 to len(aCpos)
	If X3Uso(GetSx3Cache(aCpos[nx],"X3_USADO")) .AND. cNivel >= GetSx3Cache(aCpos[nx],"X3_NIVEL") .AND. aScan(aLstCmpNL,{|x| x == Upper(AllTrim(aCpos[nx]))}) == 0
		aAdd(aLstCmp03,aCpos[nx])
		//Caso seja obrigatorio, adicionar o item a lista de itens obrigatorios
		If X3Uso(GetSx3Cache(aCpos[nx],"X3_USADO")) .AND. (X3OBRIGAT(aCpos[nx]) .OR. VerByte(GetSx3Cache(aCpos[nx],"X3_RESERV"),7))
			aAdd(aLstCmpOb2,aCpos[nx])
		Endif
		//Campos virtuais
		If GetSx3Cache(aCpos[nx],"X3_CONTEXT") == "V"
			cLstCmpV += Upper(AllTrim(aCpos[nx])) + "|"
		Endif
		//Definir condicao de utilizacao do campo, nao liberar campos que tenham sido parcialmente ou totalmente liberados
		cCond := ""
		If lEdita .AND. lNovo
			cCond := GetSx3Cache(aCpos[nx],"X3_WHEN")
		Endif
		//Cabecalho - Estrutura MsNewGetDados
		aAdd(aHeader03,{RTrim(X3Titulo()),;
						aCpos[nx],;
						GetSx3Cache(aCpos[nx],"X3_PICTURE"),;
						GetSx3Cache(aCpos[nx],"X3_TAMANHO"),;
						GetSx3Cache(aCpos[nx],"X3_DECIMAL"),;
						GetSx3Cache(aCpos[nx],"X3_VALID"),;
						GetSx3Cache(aCpos[nx],"X3_USADO"),;
						GetSx3Cache(aCpos[nx],"X3_TIPO"),;
						GetSx3Cache(aCpos[nx],"X3_F3"),;
						GetSx3Cache(aCpos[nx],"X3_CONTEXT"),;
						GetSx3Cache(aCpos[nx],"X3_CBOX"),;						
						GetSx3Cache(aCpos[nx],"X3_RELACAO"),;
						cCond,;
						IIf((nPos := aScan(aLstCmpVis,{|x| x == Upper(AllTrim(aCpos[nx]))})) == 0,GetSx3Cache(aCpos[nx],"X3_VISUAL"),"V"),;
						GetSx3Cache(aCpos[nx],"X3_VLDUSER"),;
						GetSx3Cache(aCpos[nx],"X3_PICTVAR"),;
						GetSx3Cache(aCpos[nx],"X3_OBRIGAT")})
		//Ajustes por campo
		Do Case
			Case Upper(AllTrim(aCpos[nx])) == "ME2_PRODUT"
				If !Empty(cTMP := aHeader03[Len(aHeader03)][6])
					aHeader03[Len(aHeader03)][6] := cTMP + " .AND. Lj843AtPrd()"
				Else
					aHeader03[Len(aHeader03)][6] := "Lj843AtPrd()"
				Endif
			Case Upper(AllTrim(aCpos[nx])) == "ME2_VEND"
				cTMP := ""
				If !Empty(cTMP := aHeader03[Len(aHeader03)][6])
					aHeader03[Len(aHeader03)][6] := cTMP + " .AND. Lj843AtVen()"
				Else
					aHeader03[Len(aHeader03)][6] := "Lj843AtVen()"
				EndIf
		EndCase
	Endif
Next nx

aLstCmpA03 := aClone(aLstCmp03)
nUsado := Len(aHeader03)
If nOperacao == INCLUIR
	aCols03 := {Array(nUsado + 1)}
	//Inicializacao das variaveis
	aTail(aCols03[1]) := .F.
	For ni := 1 to nUsado
		Do Case
			Case Upper(AllTrim(aHeader03[ni][POS_CMP])) == "ME2_ITEM"
				aCols03[1][ni] := StrZero(1,TamSX3("ME2_ITEM")[1])
			Case Upper(AllTrim(aHeader03[ni][POS_CMP])) == "ME2_QTDSOL"
				aCols03[1][ni] := 1
			Case Upper(AllTrim(aHeader03[ni][POS_CMP])) == "ME2_FILORI"
				aCols03[1][ni] := FWGETCODFILIAL
			Otherwise
				aCols03[1][ni] := CriaVar(aHeader03[ni][POS_CMP])
		EndCase
	Next ni
Else
	aCols03 := Array(0)
	cChave := RTrim(xFilial(cAlias03) + ME1->ME1_CODIGO)
	//Pesquisar dados gravados da lista
	DbSelectArea(cAlias03)
	(cAlias03)->(DbSetOrder(1))
	(cAlias03)->(DbSeek(cChave))
	Do While !(cAlias03)->(Eof()) .AND. RTrim((cAlias03)->(ME2_FILIAL + ME2_CODIGO)) == cChave
		aAdd(aCols03,Array(nUsado + 1))
		nPos := Len(aCols03)
		If nPos > 0
			aTail(aCols03[nPos]) := .F.
			For ni := 1 to nUsado
				aCols03[nPos][ni] := (cAlias03)->(FieldGet(FieldPos(aHeader03[ni][POS_CMP])))
			Next ni
		EndIf
		(cAlias03)->(DbSkip())
	EndDo
	//-- o vetor acl3ant eh utilizado pela funcao Lj843AtVen()
	aCl3Ant := AClone(aCols03)	
Endif
If !lLj843Auto
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPE Lj843HabSl - Tratamento para habilitar ou nao o botao de SALVAR  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ExistBlock("LJ843HABSL")
		If ValType(lSalvaEd := ExecBlock("LJ843HABSL",.F.,.F.,{})) # "L"
			lSalvaEd := .T.
		Endif
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInterface  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤู
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM aCoord[1],aCoord[2] TO aCoord[3],aCoord[4] OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE,WS_POPUP) PIXEL
	
	oDlg:lMaximized := .T.
	oDlg:lCentered := .F.
	//Inicializando FWLayer
	oArea:Init(oDlg,.F.)
	//ฺฤฤฤฤฤฤฤฤฤฤฟ
	//ณLinha 01  ณ
	//ภฤฤฤฤฤฤฤฤฤฤู
	oArea:AddLine("L01",30,.T.)
	oArea:AddCollumn("L01C01",100,.F.,"L01")
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPainel 01 - Dados do evento  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oArea:AddWindow("L01C01","L01C01P01",STR0001,100,.F.,.F.,,"L01") //"Dados do evento"
	oPainel01 := oArea:GetWinPanel("L01C01","L01C01P01","L01")
	//Dimensoes do objeto
	aTamObj[1] := 0
	aTamObj[2] := 0 
	aTamObj[3] := 0 
	aTamObj[4] := 0 
	oEnch := MsmGet():New(cAlias01,(cAlias01)->(Recno()),IIf(lEdita .AND. lSalvaEd,IIf(lNovo,3,4),2),/*aCRA*/,/*cLetras*/,/*cTexto*/,aLstCmp01,aTamObj,;
		aLstCmpA01,/*nModelo*/,/*nColMens*/,/*cMensagem*/,/*cTudoOk*/,oPainel01)
	oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	//ฺฤฤฤฤฤฤฤฤฤฤฟ
	//ณLinha 02  ณ
	//ภฤฤฤฤฤฤฤฤฤฤู
	oArea:AddLine("L02",70,.T.)
	oArea:AddCollumn("L02C01",88,.F.,"L02")
	oArea:AddCollumn("L02C02",12,.F.,"L02")
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPainel 02 - Atores           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oArea:AddWindow("L02C01","L02C01P01",STR0051,35,.F.,.F.,,"L02")            ///"Atores"
	oPainel02 := oArea:GetWinPanel("L02C01","L02C01P01","L02")
	//Dimensoes do objeto
	aTamObj[1] := 000
	aTamObj[2] := 000
	aTamObj[3] := (oPainel02:nClientHeight / 2) * nPercUtO
	aTamObj[4] := (oPainel02:nClientWidth / 2) * nPercUtO
	oGD01_LST := MsNewGetDados():New(aTamObj[1],aTamObj[2],aTamObj[3],aTamObj[4],IIf(lEdita .AND. lSalvaEd,GD_INSERT+GD_UPDATE+GD_DELETE,0),cLinOk01,cTudoOk01,;
		/*cIniPos*/,aLstCmpA02,0,nLimLin01,/*cFieldOk*/,cDelTodos,/*cDelOk*/,oPainel02,@aHeader02,@aCols02)
	oGD01_LST:lEditLine := .F.
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPainel 03 - Lista de produtosณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oArea:AddWindow("L02C01","L02C01P02",STR0002,65,.F.,.F.,,"L02") //"Lista de produtos"
	oPainel03 := oArea:GetWinPanel("L02C01","L02C01P02","L02")
	//Dimensoes do objeto
	aTamObj[1] := 000
	aTamObj[2] := 000
	aTamObj[3] := (oPainel03:nClientHeight / 2) * nPercUtO
	aTamObj[4] := (oPainel03:nClientWidth / 2) * nPercUtO
	oGD02_LST := MsNewGetDados():New(aTamObj[1],aTamObj[2],aTamObj[3],aTamObj[4],IIf(lEdita,GD_INSERT+GD_UPDATE+GD_DELETE,0),cLinOk02,cTudoOk02,cIniCpos02,aLstCmpA03,;
		0,nLimLin02,cCmpOk02,cDelTodos,cLinDel02,oPainel03,@aHeader03,@aCols03)
	oGD02_LST:lEditLine := .F.
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPainel 04 - Funcoes          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oArea:AddWindow("L02C02","L02C02P01",STR0052,100,.F.,.F.,,"L02")     ///"Fun็๕es"
	oPainel04 := oArea:GetWinPanel("L02C02","L02C02P01","L02")
	//Dimensoes do objeto
	aTamObj[1] := 000
	aTamObj[2] := 000
	aTamObj[3] := (oPainel04:nClientWidth / 2) * nPercUtO
	aTamObj[4] := 012

	//Botao  - Coletar PDA
	oBot03 := tButton():New(aTamObj[1],aTamObj[2],STR0003,oPainel04,{|| aTMP := IIF(FindFunction("Loja855"),Loja855(),{}),; //"Coletar PDA"
		IIf(ValType(aTMP) == "A" .AND. Len(aTMP) > 0,Lj843ImpPr(oGD02_LST,aTMP,1/*nPosCod*/,0/*nPosPrUn*/,;
																  3/*nPosVend*/,2/*nPosQtd*/,"3"/*Fonte*/),.T.)},;
		aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| IIF(FindFunction("Loja855"),(nOperacao == INCLUIR .OR. nOperacao == ALTERAR),nOperacao ==POS_CNT)}/*When*/)
	oBot03:Align := CONTROL_ALIGN_TOP
	
	//Botao - Conta corrente
	aTamObj[1] := (oBot03:nBottom / 2) + 2
	oBot04 := tButton():New(aTamObj[1],aTamObj[2],STR0004,oPainel04,{|| LOJA846(M->ME1_CODIGO)},aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,; //"Conta corrente"
		{|| nOperacao # INCLUIR}/*When*/)
	//Botao - Encerrar lista
	If ExistBlock("LJ843HBENC")
		If ValType(lBtEncLst := ExecBlock("LJ843HBENC",.F.,.F.,{})) # "L"
			lBtEncLst := .T.
		Endif
	Endif	
	aTamObj[1] := (oBot04:nBottom / 2) + 2
	oBot05 := tButton():New(aTamObj[1],aTamObj[2],STR0005,oPainel04,{|| lOk := LOJA846(M->ME1_CODIGO,Nil,.T.),IIf(ValType(lOk) == "L" .AND. lOk,IIf(Lj843EncLs(),oDlg:End(),.T.),.T.)},; //"Encerrar lista"
		aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| nOperacao == ALTERAR .And. lBtEncLst}/*When*/)

	//Botao - Sugestao
	aTamObj[1] := (oBot05:nBottom / 2) + 2
	oBot06 := tButton():New(aTamObj[1],aTamObj[2],STR0006,oPainel04,{|| nOpcP := Lj843DlSL(), IIf(nOpcP == 1 ,IIf(!Empty(M->ME1_TPEVEN),Eval({|| aTMP := IIF(FindFunction("Loja853"),Loja853(M->ME1_TPEVEN),{}),; //"Sugestใo"
		IIf(ValType(aTMP) == "A" .AND. Len(aTMP) > 0,Lj843ImpPr(oGD02_LST,aTMP,5/*nPosCod*/,0/*nPosPrUn*/,/*nPosVend*/,8/*nPosQtd*/),.T.)}),.T.),IIf(nOpcP ==2 .AND. !Empty(oGD02_LST:aCols) .AND. Lj843DME2(oGD02_LST:aCols, aHeader03), Lj843CriLs(Lj843Ar1SL("ME1"),Lj843Ar2SL(aHeader03, oGD02_LST:aCols/*aCols03*/)), .T.))},; 
		aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| IIF(FindFunction("Loja853"),(nOperacao == INCLUIR .OR. nOperacao == ALTERAR),nOperacao ==POS_CNT)}/*When*/)
	
	//Botao - Entrega futura
	aTamObj[1] := (oBot06:nBottom / 2) + 2
	oBot07 := tButton():New(aTamObj[1],aTamObj[2],STR0007,oPainel04,{|| Loja843PEP(@aCols04,@aHeader04,lMDI)},aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,/*When*/) //"Entrega futura"
	//Botao - Imprimir
	aTamObj[1] := (oBot07:nBottom / 2) + 2
	oBot08 := tButton():New(aTamObj[1],aTamObj[2],STR0008,oPainel04,{|| LOJR847(FWGETCODFILIAL,M->ME1_CODIGO)},aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,; //"Imprimir"
		{|| !lNovo .AND. nOperacao # EXCLUIR}/*When*/)
	//Botao - Salvar
	aTamObj[1] := (oBot08:nBottom / 2) + 2
	oBot09 := tButton():New(aTamObj[1],aTamObj[2],STR0009,oPainel04,{|| lOk := Loja843Grv(aLstCmp01,oGD01_LST:aHeader,oGD01_LST:aCols,oGD02_LST:aHeader,oGD02_LST:aCols,aHeader04,aCols04,@cChvRes),; //"Salvar"
		IIf(lOk,oDlg:End(),lOk := lOk)},aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| nOperacao # VISUALIZAR})
	//Botao - Fechar
	oBot01 := tButton():New(aTamObj[1],aTamObj[2],STR0010,oPainel04,{|| lOk := .F.,oDlg:End()},aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,/*When*/) //"Fechar"
	oBot01:Align := CONTROL_ALIGN_BOTTOM
	oDlg:Activate()
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณEnchoice automatica - ME1 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	lOk := EnchAuto(cAlias01,aAutoCab)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGetDados automatica - ME2 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	If lOk
		
		/*BEGINDOC
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica a origem da Lista de ้  1 Manual ou 2 Webณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		ENDDOC*/
		nPosME1Or := aScan( aAutoCab, {|cab| cab[1] == "ME1_ORIGEM"})
		aHeader	:= aClone(aHeader03)
		aCols	:= aClone(aCols03)
		lOk 	:= MsGetDAuto(aAutoItME2,"",{|| Loja843TOK(,2,IIF(nPosME1Or > 0,aAutoCab[nPosME1Or,2]=="2",.F.))},aAutoCab,nOperacao)
		aCols03	:= aClone(aCols)
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGetDados automatica - MEE ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	If lOk
		aHeader	:= aClone(aHeader02)
		aCols	:= aClone(aCols02)
		lOk 	:= MsGetDAuto(aAutoItMEE,"",{|| Loja843TOK(,1)},aAutoCab,nOperacao)
		aCols02	:= aClone(aCols)
	EndIf
	If lOK .AND. nOperacao == INCLUIR .AND. Len(aAutoItMEH) > 0
		//Montar cabecalho e getdados
		If !Loja843PEP(@aCols04,@aHeader04,lMDI)
			Return !lRet
		Endif
		aHeader	:= aClone(aHeader04)
		aCols	:= aClone(aCols04)
		lOk 	:= MsGetDAuto(aAutoItMEH,"",{|| },aAutoCab,nOperacao)
		aCols02	:= aClone(aCols)
	Endif	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGravacao dos dados  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lOk
		lOk := Loja843Grv(aLstCmp01,aHeader02,aCols02,aHeader03,aCols03,aHeader04,aCols04,cChvRes)
	Endif
Endif
//Recover
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLiberar codigo de lista nao utilizado  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !lOk
	If nOperacao == INCLUIR
		Do While GetSx8Len() > nSituaSX8
			RollBackSX8()
		EndDo
	Endif
Endif
MsUnlockAll()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLiberar nomes reservados  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(cChvRes)
	Leave1Code(cChvRes)
Endif
//Restaurando a area de trabalho
aEval(aArea,{|x| RestArea(x)})						

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณLj843AtPrdบAutor  ณVendas Cliente        บ Data ณ21/02/11         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para atualizar campos relacionados ao produto              บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ Nil                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ lRet                                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Lj843AtPrd()

Local lRet				:= .T.
Local ni				:= 0																			//Contador
Local aAreaSB1			:= SB1->(GetArea())
Local aCmpPos			:={	{"ME2_PRODUT",0},{"ME2_DESCRI",0},{"ME2_UM",0},{"ME2_VALUNI",0},;			//Produto //Descricao Item //Unidade de medida 01 //Valor unitario
							{"ME2_FILORI",0},{"ME2_VEND",0}}											//Filial de origem	//Codigo do vendedor
Local cCodCli			:= IIf(Type("M->ME1_CODCLI") # "U",M->ME1_CODCLI,"")							//Codigo do cliente
Local cLojCli			:= IIf(Type("M->ME1_LOJCLI") # "U",M->ME1_LOJCLI,"")							//Codigo da loja do cliente
Local cCodProd			:= ""																			//Codigo do produto
Local nPos				:= 0																			//Posicao do registro
Local aHead				:= {}																			//Cabecalho da lista
Local cCodVend			:= ""																			//Codigo do vendedor

If Type("oGD02_LST") # "O"
	lRet := .F.
	Return lRet
Endif
//Verificar se os campos podem ser atualizados
If !Lj843COk02() .AND. !lLj843Auto 
	Return !lRet
Endif
aHead	:= oGD02_LST:aHeader
nPos	:= oGD02_LST:nAt
//Definir as posicoes dos campos de destino
For ni := 1 to Len(aCmpPos)
	aTail(aCmpPos[ni]) := aScan(aHead,{|x| Upper(AllTrim(x[2])) == aCmpPos[ni][1]})
Next ni
//Se o campo de codigo de produto nao for encontrado no header ou o seu conteudo estiver vazio, sair
cCodProd := &("M->" + aCmpPos[1][1])
If (aCmpPos[1][2] == 0 .OR. Empty(cCodProd)) .and. !lLj843Auto
	lRet := .F.
	Return lRet
Endif
//Atualizar os campos relacionados a produtos
DbSelectArea("SB1")
SB1->(DbSetOrder(1))	//B1_FILIAL+B1_COD
If SB1->(DbSeek(xFilial("SB1") + cCodProd))
	//Verificar se o item estah bloqueado
	If SB1->(FieldPos("B1_MSBLQL")) > 0 .AND. SB1->B1_MSBLQL == "1" .and. !lLj843Auto
		Help(" ",1,"LJ843PBL")
		Return !lRet
	Endif
	//Atualizar o preco de venda
	If aCmpPos[4][2] > 0
		&("M->" + aCmpPos[4][1]) := Lj843PrcV(cCodProd,cCodCli,cLojCli,1)
		oGD02_LST:aCols[nPos][aCmpPos[4][2]] := &("M->" + aCmpPos[4][1])
	Endif
	//Atualizar descricao
	If aCmpPos[2][2] > 0
		&("M->" + aCmpPos[2][1]) := Substr(SB1->B1_DESC,1,TamSX3(aCmpPos[2][1])[1])
		oGD02_LST:aCols[nPos][aCmpPos[2][2]] := &("M->" + aCmpPos[2][1])
	Endif
	//Atualizar unidade de medida
	If aCmpPos[3][2] > 0
		&("M->" + aCmpPos[3][1]) := SB1->B1_UM
		oGD02_LST:aCols[nPos][aCmpPos[3][2]] := &("M->" + aCmpPos[3][1])
	Endif
	//Atualizar filial de origem
	If aCmpPos[5][2] > 0
		&("M->" + aCmpPos[5][1]) := FWGETCODFILIAL
		oGD02_LST:aCols[nPos][aCmpPos[5][2]] := &("M->" + aCmpPos[5][1])
	Endif
	//-- Ponto de Entrada LJ843VPR (Apos a digita็ใo do codigo do produto para validacoes gerais)
	//-- Parametros Passados:
	//-- PARAMIXB[1] = Codigo do produto
	//-- PARAMIXB[2] = .T. = Emite Help / .F. = Nao Emite Help
	//-- Retorno (Logico):
	//-- .T. - Produto validado
	//-- .F. - Produto nao validado
	If	ExistBlock('LJ843VPR')
		lRet := ExecBlock('LJ843VPR', .F., .F., {cCodProd,.T.})
		lRet := If(ValType(lRet)=='L',lRet,.T.)

		If	!lRet
			Return lRet
		EndIf
	EndIf

	//Atualizar codigo de vendedor
	If Empty(oGD02_LST:aCols[nPos][aCmpPos[6][2]]) 
		If nPos == 1
			If Len(oGD02_LST:aCols) > 1
				cCodVend := oGD02_LST:aCols[nPos + 1][aCmpPos[6][2]]
			Endif
		Else
			cCodVend := oGD02_LST:aCols[nPos - 1][aCmpPos[6][2]]
		Endif
		If !Empty(cCodVend)
			oGD02_LST:aCols[nPos][aCmpPos[6][2]] := cCodVend
		Endif	
	Endif
	oGD02_LST:Refresh()
Else
	RestArea(aAreaSB1)
	Return !lRet	
Endif
RestArea(aAreaSB1)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณLj843AtVenบAutor  ณVendas Cliente        บ Data ณ21/02/11         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para atualizar campos relacionados ao vendedor             บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Lj843AtVen()
Local lRet := .T.
Local cPrdAux := ""
Local nPosPrd := 0
If Type("oGD02_LST") # "O"
	Return lRet
Endif
nPosPrd := GDFieldPos("ME2_PRODUT")
cPrdAux := GdFieldGet("ME2_PRODUT",n)

If	ASCan(aCl3Ant,{|x|x[nPosPrd]==cPrdAux})>0
	//-- So permite alterar o codigo do vendedor ME2_VEND para novos itens incluidos na getdados
	Help(' ', 1, 'LJ843AtV', , STR0024 , 4, 1 )   ////'Altera็ใo do Vendedor permitido somente para novos itens!'
	lRet := .F.
EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณLj843PrcV บAutor  ณVendas Cliente        บ Data ณ21/02/11         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para retornar o preco unitario de um produto.              บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[C] : Codigo do produto                                      บฑฑ
ฑฑบ          ณExp02[C] : Codigo do cliente                                      บฑฑ
ฑฑบ          ณExp03[C] : Loja do cliente                                        บฑฑ
ฑฑบ          ณExp04[N] : Codigo da moeda                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Lj843PrcV(cProduto,cCliente,cLoja,nMoeda)

Local nRet			    := 0
Local lCenVend  		:= SuperGetMv("MV_LJCNVDA",,.F.)					//Parametro da tabela de preco padrao
Local cTabPrecos    	:= IIf(lCenVend,LjXETabPre(cCliente,cLoja),"")		//Retorna a tabela de precos utilizada para o cliente (LOJXFUNE)
Local cTabPad			:= RTrim(SuperGetMV("MV_TABPAD",.F.,"1"))

Default cProduto		:= ""
Default cCliente		:= ""
Default cLoja			:= ""
Default nMoeda			:= 1

If Empty(cProduto) .OR. !AliasInDic("SB0")
	Return nRet
Endif
cProduto := PadR(cProduto,TamSX3("B1_COD")[1])
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFuncao para trazer preco de venda de acordo com a qtde           ณ
//ณ a. Considera sempre quantidade 1                                ณ
//ณ b. Retorna o valor convertido pela moeda da tabela de preco DA1 ณ
//ณ c. Se nao encontrar tabela de preco, retorna valor do B0_PRV1   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lCenVend .AND. !Empty(cTabPrecos)
	nRet := MaTabPrVen(cTabPrecos,cProduto,1,cCliente,cLoja,1/*moeda*/,/*dDataVld*/,/*nTipo*/,/*lExec*/)
Else
	ChkFile("SB0",.F.)                                                      
	nRet := GetAdvfVal("SB0","B0_PRV" + cTabPad,xFilial("SB0") + cProduto,1)
Endif
If Empty(nRet) .OR. ValType(nRet) # "N"
	nRet := 0
Endif

Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณLoja843TOKบAutor  ณPablo Gollan Carreras บ Data ณ22/02/11         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para validacao da GetDados                                 บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[C] : Mensagem de alerta                                     บฑฑ
ฑฑบ          ณExp02[C] : Opcao de getdados a validar                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณlRet[L]  : Retorno da validacao                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Loja843TOK(lHelp,nOpcao,lOrigWeb)

Local lRet				:= .T.
Local ni               	:= 0
Local nLinhas			:= 0
Local aCol				:= {}
Local cErro				:= ""

Default lHelp			:= .T.
Default nOpcao			:= 1 
Default lOrigWeb        := .F. //Informa se a origem de lista e Web

If !lLj843Auto
	Do Case
		Case nOpcao == 1
			aCol := oGD01_LST:aCols
		Case nOpcao == 2
			aCol := oGD02_LST:aCols
	EndCase
Else
	aCol := aCols
Endif
nLinhas := 0
For ni := 1 to Len(aCol)
	If !aCol[ni,Len(aCol[ni])]
		If !Loja843LOK(ni,,nOpcao,@cErro)
			lRet := !lRet
			Exit
		Else
			nLinhas++
		Endif
	Endif
Next ni

If lRet
	If nLinhas == 0   
	 
/*BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFabiana/Veronica 24/03/2011                        ณ
//ณPermite a inclusao de itens caso seja uma execucao ณ
//ณautomแtica                                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ENDDOC*/
	    If  nOpcao == 1 .or. (!lLj843Auto .or. !lOrigWeb .or. Len(aCol) > 0 )
			If lHelp
				Help(" ",1,"NVAZIO",,IIf(nOpcao == 1,STR0011,STR0002) + IIf(Empty(cErro),CRLF + Upper(cErro),""),4,0) //"Lista de atores"###"Lista de produtos"
			Endif
			lRet := !lRet     
		EndIf
	Endif
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณLoja843LOKบAutor  ณPablo Gollan Carreras บ Data ณ22/02/11         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para validacao de linha da getdados                        บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[N] : Linha atual                                            บฑฑ
ฑฑบ          ณExp02[L] : Apresentar help                                        บฑฑ
ฑฑบ          ณExp03[N] : Opcao da getdados a validar                            บฑฑ
ฑฑบ          ณExp04[C] : Lista de campos com problemas                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Loja843LOK(nLinha,lHelp,nOpcao,cCmpProb)

Local lRet				:= .T.
Local ni               	:= 0
Local oObjGD			:= Nil
Local aHead				:= {}
Local aCol				:= {}
Local nPosCmpChv		:= 0
Local nPos				:= 0
Local lOk				:= 0

Default nLinha			:= n
Default lHelp			:= .T.
Default nOpcao			:= 1
Default cCmpProb		:= ""

If !lLj843Auto
	Do Case
		Case nOpcao == 1
			oObjGD := oGD01_LST
		Case nOpcao == 2
			oObjGD := oGD02_LST
		Otherwise
	EndCase
	aHead	:= aClone(oObjGD:aHeader)
	aCol	:= aClone(oObjGD:aCols)
Else
	aHead	:= aClone(aHeader)
	aCol 	:= aClone(aCols)
Endif
Do Case
	Case nOpcao == 1
		nPosCmpChv	:= aScan(aHead,{|x| AllTrim(Upper(x[2])) == "MEE_CODATO"})
	Case nOpcao == 2
		nPosCmpChv	:= aScan(aHead,{|x| AllTrim(Upper(x[2])) == "ME2_PRODUT"})
EndCase
If !aCol[nLinha][Len(aHead) + 1]
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณValidar campos obrigatorios  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For ni := 1 to Len(aCol[nLinha]) - 1
		If aScan(aLstCmpOb2,{|x| AllTrim(Upper(x)) == AllTrim(Upper(aHead[ni][2]))}) > 0 .AND. Empty(aCol[nLinha][ni]) .and. !lLj843Auto
			If lHelp
				cCmpProb := AllTrim(Upper(aHead[ni][2]))
				Help(" ",1,"OBRIGAT",,RetTitle(aHead[ni][2] + " " + cCmpProb))
				lRet := !lRet
				Exit
			Endif
		Else
		Endif
	Next ni
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณValidar registros duplicados ou codigo de supervisor igual ao usuario  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lRet .AND. nPosCmpChv # 0 .and. !lLj843Auto
		For ni := 1 to Len(aCol)
			If !aCol[ni][Len(aHead) + 1] .AND. ni # nLinha .AND. AllTrim(aCol[ni][nPosCmpChv]) == AllTrim(aCol[nLinha][nPosCmpChv])
				lOk := .F.
				If nOpcao == 2
					//Verificar se o item encontrado nao eh da mesma origem, que nao deve ser considerado na comparacao
					If (nPos := aScan(aHead,{|x| AllTrim(Upper(x[2])) == "ME2_ORIGEM"})) > 0 
						If AllTrim(aCol[ni][nPos]) == AllTrim(aCol[nLinha][nPos]) .AND. AllTrim(aCol[nLinha][nPos]) == "O"  .and. !lLj843Auto
							lOk := .T.
						Endif
					Endif
					//Verificar se o item encontrado nao foi atendido parcialmente e por isso nao pode ser editado, nao devendo ser considerado na comparacao
					If (nPos := aScan(aHead,{|x| AllTrim(Upper(x[2])) == "ME2_QTDATE"})) > 0 
						If aCol[ni][nPos] == 0 .AND. aCol[nLinha][nPos] == 0 .and. !lLj843Auto
							lOk := .T.
						Else
							lOk := .F.
						Endif
					Endif
				Else
					lOk := .T.
				Endif
				If lOk
					cCmpProb := STR0012 + cValToChar(ni) + STR0013 //"Linha "###" duplicada."
					If lHelp
						Help(" ",1,"JAGRAVADO",,cCmpProb)
					Endif
					lRet := !lRet
					Exit
				Endif
			Endif
		Next ni
	Endif	
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณLoja843ETOKบAutor  ณPablo Gollan Carreras บ Data ณ22/02/11        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para validacao total, da enchoice e da getdados            บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Loja843ETOK(lHelp,nCodGD,lOrigWeb)

Local lRet				:= .T.
Local ni				:= 0

Default lHelp			:= .T.
Default nCodGD			:= IIf(lLj843Auto,1,0)   
Default lOrigWeb		:= .F.   

//Validacao dos campos da enchoice
For ni := 1 to Len(aLstCmpOb1)
	If Empty(M->&(aLstCmpOb1[ni])) .and. !lLj843Auto
		If lHelp
			Help(" ",1,"OBRIGAT",,RetTitle(aLstCmpOb1[ni]) + " " + aLstCmpOb1[ni])
		Endif
		lRet := !lRet
		Exit
	Endif
Next ni
//Fazer validacao das linhas da getdados de atores
If lRet .AND. (nCodGD == 0 .OR. nCodGD == 1)
	lRet := Loja843TOK(,1)
Endif
//Fazer validacao das linhas da getdados de produtos
If lRet .AND. (nCodGD == 0 .OR. nCodGD == 2)
	lRet := Loja843TOK(,2, lOrigWeb) 
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณLoja843DOKบAutor  ณPablo Gollan Carreras บ Data ณ27/02/11         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para validacao de exclusao de linha da getdados            บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[N] : Linha atual                                            บฑฑ
ฑฑบ          ณExp02[L] : Apresentar help                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Loja843DOK(nLinha,lHelp)

Local lRet				:= .T.
Local oObjGD			:= Nil
Local aHead				:= {}
Local aCol				:= {}
Local nPos				:= 0

Default nLinha			:= n
Default lHelp			:= .T.

If lNovo
	Return lRet
Endif
If !lLj843Auto
	oObjGD := oGD02_LST
	aHead	:= aClone(oObjGD:aHeader)
	aCol	:= aClone(oObjGD:aCols)
Else
	aHead	:= aClone(aHeader)
	aCol 	:= aClone(aCols)
Endif
If !aCol[nLinha][Len(aHead) + 1]
	//Verificar se o item jah possui baixa parcial ou integral
	If (nPos := aScan(aHead,{|x| AllTrim(Upper(x[2])) == "ME2_STATUS"})) > 0
		If Upper(AllTrim(aCol[nLinha][nPos])) $ "P|E" .and. !lLj843Auto
			If lHelp
				Help(" ",1,"LJ843NA1")
			Endif
			Return !lRet
		Endif
	Endif
	//Verificar se o item jah possui baixa parcial ou integral atraves de sua quantidade atendida
	If (nPos := aScan(aHead,{|x| AllTrim(Upper(x[2])) == "ME2_QTDATE"})) > 0  .and. !lLj843Auto
		If aCol[nLinha][nPos] > 0
			If lHelp
				Help(" ",1,"LJ843NA1")
			Endif
			Return !lRet
		Endif
	Endif
	//Verificar se o item possui origem de comprador, que nao pode ser apagada		
	If (nPos := aScan(aHead,{|x| AllTrim(Upper(x[2])) == "ME2_ORIGEM"})) > 0  .and. !lLj843Auto
		If AllTrim(aCol[nLinha][nPos]) # "O"
			If lHelp
				Help(" ",1,"LJ843NA1")
			Endif
			Return !lRet
		Endif
	Endif			
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณLj843COk02บAutor  ณVendas Cliente        บ Data ณ27/02/11         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para validar a edicao de campos na GD de produtos          บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[N] : Linha atual                                            บฑฑ
ฑฑบ          ณExp02[L] : Apresentar help                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Lj843COk02(nLinha,lHelp)

Local lRet				:= .T.
Local oObjGD			:= Nil
Local aHead				:= {}
Local aCol				:= {}
Local nPos				:= 0

Default nLinha			:= n
Default lHelp			:= .T.

If nOperacao == INCLUIR
	Return lRet
Endif
If !lLj843Auto
	oObjGD := oGD02_LST
	aHead	:= aClone(oObjGD:aHeader)
	aCol	:= aClone(oObjGD:aCols)
Else
	aHead	:= aClone(aHeader)
	aCol 	:= aClone(aCols)
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEm caso de alteracao, verificar se o item pode ser modificado.  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOperacao # INCLUIR .AND. !lLj843Auto
	//Origem invalida para edicao do organizador
	If (nPos := aScan(aHead,{|x| AllTrim(Upper(x[2])) == "ME2_ORIGEM"})) > 0
		If AllTrim(aCol[nLinha][nPos]) # "O"
			lRet := !lRet
		Endif
	Endif
	//Validar quantidade
	If lRet .And. (nPos := aScan(aHead,{|x| AllTrim(Upper(x[2])) == "ME2_QTDATE"})) > 0
		If aCol[nLinha][nPos] > 0 
			If Type("M->ME2_QTDSOL") == "N"
				lRet := aCol[nLinha][nPos] <= M->ME2_QTDSOL //Verifica se a qtd atendida ้ maior que a solicitada.
			Else
				lRet := .F.
			EndIf
		EndIf
	Endif	
Endif
If !lRet .AND. lHelp
	Help(" ",1,"LJ843NA2")
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณLoja843GrvบAutor  ณVendas Cliente        บ Data ณ22/02/11         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para definicao das rotinas.                                บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Loja843Grv(aLstCmpE,aHeader02,aCols02,aHeader03,;
							aCols03,aHeader04,aCols04,cChvRes  ,;
							lHelp)

Local lRet             	:= .T.
Local aCmpCntOb			:= {"U5_CODCONT","U5_END","U5_MUN","U5_EST","U5_CEP"}			//Lista de campos obrigatorios no contato selecionado
Local aCmpEntrega		:= {{"U5_END"		,"A1_END"		,Nil,Nil},;				//Campos para entrega
							{"U5_BAIRRO"	,"A1_BAIRRO"	,Nil,Nil},;
							{"U5_MUN"		,"A1_MUN"		,Nil,Nil},;
							{"U5_EST"		,"A1_EST"		,Nil,Nil},;
							{"U5_CEP"		,"A1_CEP"		,Nil,Nil}}
Local ni				:= 0															//Contador
Local nx				:= 0															//Contador 02
Local lOk				:= .T.															//Controle de fluxo
Local lPELj843Grv		:= ExistBlock("LJ843GRV")
Local cTMP				:= ""															//Variavel temporaria
Local aTamCmp			:= {}															//Controle de tamanho de campo
Local aApaga			:= {}															//Array de controle de registros apagados
Local aCodCli			:= Array(2)													//Referencia do cliente
Local cNumLst			:= ""															//Numero da lista de presentes
Local lExPEP			:= (ValType(aHeader04)=="A" .AND. Len(aHeader04)>0) .AND. ;	//Existe prazo entrega programada?
							(ValType(aCols04)=="A" .AND. Len(aCols04)>0)
Local cChave			:= ""															//Chave de pesquisa
Local cAliasT			:= GetNextAlias()												//Alias temporario
Local aTMP				:= {}															//Array temporario
Local cCmpAt			:= ""															//Campo atual de processamento
Local aLinha			:= {}															//Linha corrente processada
Local aArea				:= {}															//Area de trabalho
Local aTabs				:= {"ME1","ME2","ME3","MEE","MEF","MEH","SA1","SU5"}			//Lista de tabelas para controle de area
Local nPos				:= 0															//Posicionador
Local nPos02			:= 0															//Posicionador 02
Local cQry				:= ""															//Query de pesquisa
Local aLstItBlq			:= {}															//Lista de itens bloqueados para edicao
Local lSalvINED			:= SuperGetMV("MV_ATLSNED",.F.,.T.)							//Parametro que permite desbilitar o salvamento de itens que nao foram editados
Local dDataIni			:= IIf(Type("M->ME1_EMISSA")=="U","",M->ME1_EMISSA)			//Data de emissao da lista
Local dDataRef			:= IIf(Type("M->ME1_DTEVEN")=="U","",M->ME1_DTEVEN)			//A data do evento eh a data de referencia dos calculos
Local dDataLim			:= IIf(Type("M->ME1_DTVAL")=="U","",M->ME1_DTVAL)	 			//A data de validade da lista define a data maxima para entrega																					   
						
Default aLstCmpE		:= {}
Default aHeader02		:= {}
Default aCols02			:= {}
Default aHeader03		:= {}
Default aCols03			:= {}
Default aHeader04		:= {}
Default aCols04	   		:= {}
Default cChvRes	   		:= ""
Default lHelp			:= .T.

If nOperacao == VISUALIZAR
	Return !lRet
Endif
//Armazenando dados da area de trabalho
For ni := 1 to Len(aTabs)
	aAdd(aArea,(aTabs[ni])->(GetArea()))
Next ni
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValidar codigo do cliente (organizador)  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SA1")
If Len(aCodCli := GetAdvfVal("SA1",{"A1_COD","A1_LOJA"},xFilial("SA1") + M->ME1_CODCLI + M->ME1_LOJCLI,1)) == 0
	Help(" ",1,"LJ843NCL")
	lRet := .F.
	Return lRet
Endif
DbSelectArea("ME1")
ME1->(DbSetOrder(2))	//ME1_FILIAL+ME1_CODIGO+ME1_TIPO+ME1_CODCLI+ME1_LOJCLI
cNumLst := M->ME1_CODIGO
Begin Transaction
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValidacoes :                   ณ
//ณBloco 01 - Inclusao e Alteracaoณ
//ณBloco 02 - Exclusao            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOperacao # EXCLUIR
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณValidar os campos obrigatorio da enchoice e listas de dados  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !lLj843Auto
		If !Loja843ETOK()
			If InTransaction()
				DisarmTransaction()
			Endif		
			Return !lRet
		Endif
	Else
		//MEE
		aHeader	:= aHeader02
		aCols 	:= aCols02
		If !Loja843ETOK(lHelp,1)
			If InTransaction()
				DisarmTransaction()
			Endif		
			Return !lRet
		Endif
		//ME2
		aHeader	:= aHeader03
		aCols 	:= aCols03   

		/*BEGINDOC
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณInserida a verifica็ใo da origem ser Web para ณ
		//ณpermitir a inclusใo de lista sem itens        ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		ENDDOC*/
		If !Loja843ETOK(lHelp,2,IIF(Valtype("M->ME1_ORIGEM")=="C",M->ME1_ORIGEM == "2" , .F.))
			If InTransaction()
				DisarmTransaction()
			Endif		
			Return !lRet
		Endif
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณValidar numero da lista de presentes  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If nOperacao == INCLUIR
		cChvRes := cRotina + xFilial("ME1")
		aTamCmp := {TamSX3("ME1_CODIGO")[1]}
		Do While ME1->(DbSeek(xFilial("ME1") + cNumLst)) .OR. !MayIUseCode(cChvRes + cNumLst)
			cNumLst := Soma1(cNumLst,aTamCmp[1])
		EndDo
		M->ME1_CODIGO := cNumLst
		cChvRes += cNumLst
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณValidar datas da lista de presentes.  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !Lj843VldDt(.T.,@cTMP) .AND. !lLj843Auto       
		Help(" ",1,"LJ843DTDP",,cTMP)
		If InTransaction()
			DisarmTransaction()
		Endif		
		Return !lRet
	Endif 
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณValidar dados do contato - Dados de entrega  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If M->ME1_TIPO $ "2|3" .AND. nOperacao == INCLUIR .AND. !lLj843Auto 
		If Empty(M->ME1_CONTAT)
			Help(" ",1,"LJ843NCNT")
			If InTransaction()
				DisarmTransaction()
			Endif			
			Return !lRet	
		Endif
		DbSelectArea("SU5")
		SU5->(DbSetOrder(1))	//U5_FILIAL+U5_CODCONT
		If SU5->(DbSeek(xFilial("SU5") + M->ME1_CONTAT))
			//Verificar se o contato esta ativo
			If SU5->U5_ATIVO == "2"
				Help(" ",1,"LJ843ICNT")
				//Restaurando a area de trabalho
				aEval(aArea,{|x| RestArea(x)})	
				If InTransaction()
					DisarmTransaction()
				Endif				
				Return !lRet
			Endif
			//Verificar campos obrigatorios que serao utilizados na entrega	
			Eval({|| lOk := .T.,aEval(aCmpCntOb,{|x| IIf(Empty(SU5->&(x)),lOk := .F.,lOk := lOk)})})
			If !lOk	
				Help(" ",1,"LJ843ECNT")
				//Restaurando a area de trabalho
				aEval(aArea,{|x| RestArea(x)})
				If InTransaction()
					DisarmTransaction()
				Endif				
				Return !lRet
			Endif
			//Carregar as informacoes de entrega do contato
			For ni := 1 to Len(aCmpEntrega)
				aCmpEntrega[ni][3] := Upper(NoAcento(AllTrim(SU5->&(aCmpEntrega[ni][1]))))
			Next ni
		Else
			Help(" ",1,"LJ843NCNT")
			//Restaurando a area de trabalho
			aEval(aArea,{|x| RestArea(x)})
			If InTransaction()
				DisarmTransaction()
			Endif			
			Return !lRet
		Endif
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCaso a lista seja de entrega programada, verificar  ณ
	//ณse os prazos foram definidos.                       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If M->ME1_TIPO == "3" .AND. !lExPEP .AND. !lLj843Auto 
		Help(" ",1,"LJ843PEP")
		//Restaurando a area de trabalho
		aEval(aArea,{|x| RestArea(x)})
		If InTransaction()
			DisarmTransaction()
		Endif
		Return !lRet
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe modo de EDICAO e se a lista for de ENTREGA PROGRAMADA ณ
	//ณvalidar se os prazos de entrega definidos estao corretos.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If nOperacao == ALTERAR .AND. AllTrim(M->ME1_TIPO) == "3" .AND. !lLj843Auto 
		lOk := .T.
		//Levantar as datas do registro consolidade
		aTMP := GetAdvfVal("ME1",{"ME1_EMISSA","ME1_DTEVEN","ME1_DTVAL"},xFilial("ME1") + cNumLst,2)
		//Caso existam diferencas nas datas, validar se os prazos de entrega programados respeitam os intervalos estabelecidos
		If dDataIni # aTMP[1] .OR. dDataRef # aTMP[2] .OR. dDataLim # aTMP[3]
			nPos := aScan(aHeader04,{|x| Upper(AllTrim(x[POS_CMP])) == "MEH_PRAZO"})
			//Buscar a lista de prazo de entrega programada
			If Len(aTMP := Lj843PEPCl(aHeader04,{},dDataIni,dDataRef,dDataLim,Nil,.T.,.T.,.T.)) > 0
				//Comparar a primeira data, a data estabelecida deve ser igual ou maior que a primeira data calculada
				If aCols04[1][nPos] < aTMP[1][nPos]
					lOk := .F.
				Endif
				//Comparar a ultima data, a data estabelecida deve ser igual ou menor que a ultima data calculada
				If aCols04[Len(aCols04)][nPos] > aTMP[Len(aTMP)][nPos]
					lOk := .F.
				Endif
				If !lOk
					Help(" ",1,"LJ843PEE")
					//Restaurando a area de trabalho
					aEval(aArea,{|x| RestArea(x)})
					If InTransaction()
						DisarmTransaction()
					Endif
					Return !lRet
				Endif
			Endif
		Endif	
	Endif		
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณReajustar o numero sequencial da lista na inclusao ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If nOperacao == INCLUIR
		nPos		:= aScan(aHeader03,{|x| Upper(AllTrim(x[POS_CMP])) == "ME2_ITEM"})
		nx			:= 0
		aTamCmp		:= {TamSX3("ME2_ITEM")[1]}
		aApaga		:= {}
		For ni := 1 to Len(aCols03)
			If !aTail(aCols03[ni])
				aCols03[ni][nPos] := StrZero(++nx,aTamCmp[1])
			Else
				aAdd(aApaga,ni)
			Endif
		Next ni
		If Len(aApaga) > 0
			aTMP := {}
			For ni := 1 to Len(aCols03)
				If aScan(aApaga,{|x| x == ni}) == 0
					aAdd(aTMP,aCols03[ni])
				Endif
			Next ni
			aCols03 := aClone(aTMP)
		Endif
	Endif
Else
	If Lj843ExItBlq(1,,cNumLst,aCodCli[1],aCodCli[2]) .and. !lLj843Auto
		Help(" ",1,"LJ843NEX")
		If InTransaction()
			DisarmTransaction()
		Endif		
		Return !lRet
	Endif
Endif
Do Case
	Case nOperacao == INCLUIR
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณGravacao - ME1  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Reclock("ME1",.T.)
		ME1->ME1_FILIAL	:= xFilial("ME1")
		ME1->ME1_CODIGO	:= cNumLst
		For ni := 1 to Len(aLstCmpE)
			cCmpAt 	:= RTrim(aLstCmpE[ni])
			nPos	:= ME1->(FieldPos(cCmpAt))
			If nPos > 0 .AND. Type("M->" + cCmpAt) # "U" .AND. !cCmpAt $ "ME1_FILIAL|ME1_CODMEN" .AND. GetSx3Cache(cCmpAt,"X3_CONTEXT") # "V" 
				If	Upper(AllTrim(cCmpAt))=="ME1_LOCAL"
					ME1->(FieldPut(nPos,Upper(M->&(cCmpAt))))
				Else
					ME1->(FieldPut(nPos,M->&(cCmpAt)))
				EndIf
			Endif
		Next ni
		ME1->(DbCommit())
		ME1->(MsUnlock())
		//Gravar campo memo
		If !Empty(M->ME1_MENSAG)
			MSMM(ME1->ME1_CODMEN,,,M->ME1_MENSAG,1,,,"ME1","ME1_CODMEN")
		Endif	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณGravacao - MEE  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		For ni := 1 to Len(aCols02)
			aLinha := aCols02[ni]
			If !aTail(aLinha)
				RecLock("MEE",.T.)
				MEE->MEE_FILIAL	:= xFilial("MEE")
				MEE->MEE_CODLIS	:= cNumLst
				For nx := 1 to Len(aLinha) - 1
					cCmpAt 	:= RTrim(aHeader02[nx][POS_CMP])
					nPos	:= MEE->(FieldPos(cCmpAt))
					If nPos > 0 .AND. !cCmpAt $ "MEE_FILIAL|MEE_CODLIS" .AND. aHeader02[nx][POS_CNT] # "V"
						If	Upper(AllTrim(cCmpAt))=="MEE_NOME"
							MEE->(FieldPut(nPos,Upper(aLinha[nx])))
  						Else
							MEE->(FieldPut(nPos,aLinha[nx]))
						EndIf
					Endif
				Next nx
				MsUnlock()
			Endif
		Next ni
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณGravacao - ME2  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		For ni := 1 to Len(aCols03)
			aLinha := aCols03[ni]
			If !aTail(aLinha)
				RecLock("ME2",.T.)
				ME2->ME2_FILIAL	:= xFilial("ME2")
				ME2->ME2_CODIGO	:= cNumLst
				For nx := 1 to Len(aLinha) - 1
					cCmpAt 	:= RTrim(aHeader03[nx][POS_CMP])
					nPos	:= ME2->(FieldPos(cCmpAt))
					If nPos > 0 .AND. !cCmpAt $ "ME2_FILIAL|ME2_CODIGO"
						ME2->(FieldPut(nPos,aLinha[nx]))
					Endif
				Next nx
				MsUnlock()
			Endif
		Next ni
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณGravacao - MEH  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If lExPEP
			For ni := 1 to Len(aCols04)
				aLinha := aCols04[ni]
				If !aTail(aLinha)
					RecLock("MEH",.T.)
					MEH->MEH_FILIAL	:= xFilial("MEH")
					MEH->MEH_CODLIS	:= cNumLst
					For nx := 1 to Len(aLinha) - 1
						cCmpAt 	:= RTrim(aHeader04[nx][POS_CMP])
						nPos	:= MEH->(FieldPos(cCmpAt))
						If nPos > 0 .AND. !cCmpAt $ "MEH_FILIAL|MEH_CODLIS"
							MEH->(FieldPut(nPos,aLinha[nx]))
						Endif
					Next nx
					MsUnlock()
				Endif
			Next ni		
		Endif
		//Confirmar sequencial
		ConfirmSX8()
	Case nOperacao == ALTERAR
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณGravacao - ME1  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
		If !ME1->(DbSeek(xFilial("ME1") + cNumLst))
			Help(" ",1,"LJ843LNE")
			If InTransaction()
				DisarmTransaction()
			Endif
			Return !lRet		
		Endif
		Reclock("ME1",lNovo)
		ME1->ME1_FILIAL	:= xFilial("ME1")
		ME1->ME1_CODIGO	:= cNumLst
		For ni := 1 to Len(aLstCmpE)
			cCmpAt 	:= RTrim(aLstCmpE[ni])
			nPos	:= ME1->(FieldPos(cCmpAt))
			If nPos > 0 .AND. Type("M->" + cCmpAt) # "U" .AND. !cCmpAt $ "ME1_FILIAL|ME1_CODMEN" .AND. GetSx3Cache(cCmpAt,"X3_CONTEXT") # "V" 
				If	Upper(AllTrim(cCmpAt))=="ME1_LOCAL"
					ME1->(FieldPut(nPos,Upper(M->&(cCmpAt))))
   			Else
					ME1->(FieldPut(nPos,M->&(cCmpAt)))
				EndIf
			Endif
		Next ni
		ME1->(DbCommit())
		ME1->(MsUnlock())
		//Gravar campo memo
		If !Empty(M->ME1_MENSAG)
			MSMM(ME1->ME1_CODMEN,,,M->ME1_MENSAG,1,,,"ME1","ME1_CODMEN")
		Else
			//Excluir campo memo caso o mesmo esteja vazio e havia uma referencia anterior
			If !Empty(ME1->ME1_CODMEN)
				MSMM(ME1->ME1_CODMEN,,,,2,,,"ME1","ME1_CODMEN")	
			Endif
		Endif	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณGravacao - MEE  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DbSelectArea("MEE")
		MEE->(DbSetOrder(1))	//MEE_FILIAL+MEE_CODLIS+MEE_CODATO		
		aTMP 	:= {}
		nPos	:= aScan(aHeader02,{|x| Upper(AllTrim(x[POS_CMP])) == "MEE_CODATO"})
		//Levantar todos os codigos de tipos de atores selecionados
		aEval(aCols02,{|x| aAdd(aTMP,x[nPos])})
		//Pesquisar se existe algum deles consolidado que nao consta no set atual de atores (aCols02), para exclusao
		If Len(aTMP) > 0
			lOk := .F.
			cQry := "SELECT DISTINCT MEE.MEE_CODATO "
			cQry += "FROM " + RetSQLName("MEE") + " MEE "
			cQry += "WHERE " + RetSQLDel("MEE") + " AND MEE.MEE_FILIAL = '" + xFilial("MEE") + "' AND MEE.MEE_CODLIS = '" + cNumLst + "' "
			cQry += "AND MEE.MEE_CODATO NOT IN ("
			aEval(aTMP,{|x| cQry += x + ","})
			cQry := Substr(cQry,1,Len(cQry) - 1)
			cQry += ") "
			cQry += "ORDER BY MEE.MEE_CODATO ASC"
			DbUseArea(.T.,__cRDD,TcGenQry(,,ChangeQuery(cQry)),cAliasT,.T.,.F.)
			(cAliasT)->(DbGoTop())
			If !(cAliasT)->(Eof())
				lOk 	:= .T.
				aTMP 	:= {}
				(cAliasT)->(DbEval({|x| aAdd(aTMP,FieldGet(FieldPos("MEE_CODATO")))}))
			Endif
			FechaArqT(cAliasT)
			If lOk
				//Apagar os atores consolidados que nao estao mais em uso
				For ni := 1 to Len(aTMP)
					If MEE->(DbSeek(xFilial("MEE") + cNumLst + aTMP[ni]))
						RecLock("MEE",.F.)
						MEE->(DbDelete())
						MEE->(DbCommit())
						MEE->(MsUnlock())
					Endif
				Next ni
			Endif
		Endif
		//Processar registros - gravar
		nPos02 := aScan(aHeader02,{|x| Upper(AllTrim(x[POS_CMP])) == "MEE_CODATO"})
		For ni := 1 to Len(aCols02)
			aLinha := aCols02[ni]
			If !aTail(aLinha)
				lOk := .T.
				If MEE->(DbSeek(xFilial("MEE") + cNumLst + aLinha[nPos02]))
					//Se o recurso de gravacao exclusiva de itens alterados estiver ativa, verificar se houve alteracoes para gravar
					If !lSalvINED
						If (lOk := Lj843ExDif("MEE",aLinha,aHeader02))
							RecLock("MEE",.F.)
						Endif
					Else
						RecLock("MEE",.F.)
					Endif
				Else
					RecLock("MEE",.T.)
				Endif
				If lOk
					MEE->MEE_FILIAL	:= xFilial("MEE")
					MEE->MEE_CODLIS	:= cNumLst
					For nx := 1 to Len(aLinha) - 1
						cCmpAt 	:= RTrim(aHeader02[nx][POS_CMP])
						nPos	:= MEE->(FieldPos(cCmpAt))
						If nPos > 0 .AND. !cCmpAt $ "MEE_FILIAL|MEE_CODLIS" .AND. aHeader02[nx][POS_CNT] # "V"
							If	Upper(AllTrim(cCmpAt))=="MEE_NOME"
								MEE->(FieldPut(nPos,Upper(aLinha[nx])))
    						Else
								MEE->(FieldPut(nPos,aLinha[nx]))
							EndIf
						Endif
					Next nx
					MEE->(MsUnlock())
				Endif
			Else
				If MEE->(DbSeek(xFilial("MEE") + cNumLst + aLinha[nPos02]))
					RecLock("MEE",.F.)
					MEE->(DbDelete())
					MEE->(DbCommit())
					MEE->(MsUnlock())					
				Endif			
			Endif
		Next ni	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณGravacao - ME2  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DbSelectArea("ME2")
		ME2->(DbSetOrder(1))	//ME2_FILIAL+ME2_CODIGO+ME2_ITEM
		aTMP 	:= {}
		nPos	:= aScan(aHeader03,{|x| Upper(AllTrim(x[POS_CMP])) == "ME2_ITEM"})
		//Levantar todos os itens consolidados
		aEval(aCols03,{|x| aAdd(aTMP,x[nPos])})
		If !lSalvINED
			//Levantar a lista de itens que nao pode ser editados
			aLstItBlq := Lj843ExItBlq(2,,cNumLst,aCodCli[1],aCodCli[2])
			If Len(aLstItBlq) > 0
				For ni := 1 to Len(aLstItBlq)
					If aScan(aTMP,{|x| AllTrim(x) == AllTrim(aLstItBlq[ni])}) == 0				    
						aAdd(aTMP,aLstItBlq[ni]) // 30/05/2011 - Rodrigo Fernandes - Colocou pois estava adicionando vetor ao inves do item
					Endif
				Next ni
			Endif
		Endif
		//Pesquisar se existe algum item consolidado que nao conste no set atual de produtos (aCols03), para exclusao
		If Len(aTMP) > 0 .or. (lLj843Auto .and. Len(aCols03) == 0) //Fabiana 30/05/11 - Se todos os itens da lista forem excluํdo pelo execauto 
			lOk := .F.
			cQry := "SELECT DISTINCT ME2.ME2_ITEM "
			cQry += "FROM " + RetSQLName("ME2") + " ME2 "
			cQry += "WHERE " + RetSQLDel("ME2") + " AND ME2.ME2_FILIAL = '" + xFilial("ME2") + "' AND ME2.ME2_CODIGO = '" + cNumLst + "' "
			cQry += "AND ME2.ME2_ITEM NOT IN ("			
			If Len(aTMP) > 0  //Se houver itens  monta a query 			
				aEval(aTMP,{|x| cQry += "'"+ x + "',"})
			
				cQry := Substr(cQry,1,Len(cQry)-1)
			Else
				//Se nใo, monta um in com string invalida
				cQry += "'" + Replicate("#", TamSX3("ME2_ITEM")[1]) + "'"
			Endif
			cQry += ") "
			cQry += "ORDER BY ME2.ME2_ITEM ASC"
			DbUseArea(.T.,__cRDD,TcGenQry(,,ChangeQuery(cQry)),cAliasT,.T.,.F.)
			(cAliasT)->(DbGoTop())
			If !(cAliasT)->(Eof())
				lOk 	:= .T.
				aTMP 	:= {}
				(cAliasT)->(DbEval({|x| aAdd(aTMP,FieldGet(FieldPos("ME2_ITEM")))}))
			Endif
			FechaArqT(cAliasT)
			If lOk
				//Apagar os atores consolidados que nao estao mais em uso
				For ni := 1 to Len(aTMP)
					If ME2->(DbSeek(xFilial("ME2") + cNumLst + aTMP[ni]))
						RecLock("ME2",.F.)
						ME2->(DbDelete())
						ME2->(DbCommit())
						ME2->(MsUnlock())
					Endif
				Next ni
			Endif
		Endif
		//Processar registros - gravar		
		nPos02 := aScan(aHeader03,{|x| Upper(AllTrim(x[POS_CMP])) == "ME2_ITEM"})
		For ni := 1 to Len(aCols03)
			aLinha := aCols03[ni]
			If !aTail(aLinha) .AND. aScan(aLstItBlq,{|x| AllTrim(x) == AllTrim(aLinha[nPos02])}) == 0
				lOk := .T.
				If ME2->(DbSeek(xFilial("ME2") + cNumLst + aLinha[nPos02]))
					//Se o recurso de gravacao exclusiva de itens alterados estiver ativa, verificar se houve alteracoes para gravar
					If !lSalvINED
						If (lOk := Lj843ExDif("ME2",aLinha,aHeader03))
							RecLock("ME2",.F.)
						Endif
					Else
						RecLock("ME2",.F.)
					Endif
				Else
					RecLock("ME2",.T.)
				Endif
				If lOk
					ME2->ME2_FILIAL	:= xFilial("ME2")
					ME2->ME2_CODIGO	:= cNumLst
					For nx := 1 to Len(aLinha) - 1
						cCmpAt 	:= RTrim(aHeader03[nx][POS_CMP])
						nPos	:= ME2->(FieldPos(cCmpAt))
						If nPos > 0 .AND. !cCmpAt $ "ME2_FILIAL|ME2_CODIGO" .AND. aHeader03[nx][POS_CNT] # "V"
							ME2->(FieldPut(nPos,aLinha[nx]))
						Endif
					Next nx
					ME2->(MsUnlock())
				Endif
			Else
				If aScan(aLstItBlq,{|x| AllTrim(x) == AllTrim(aLinha[nPos02])}) == 0
					If ME2->(DbSeek(xFilial("ME2") + cNumLst + aLinha[nPos02]))
						RecLock("ME2",.F.)
						ME2->(DbDelete())
						ME2->(DbCommit())
						ME2->(MsUnlock())					
					Endif
				Endif
			Endif
		Next ni		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณGravacao - MEH  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DbSelectArea("MEH")
		MEH->(DbSetOrder(1))	//MEH_FILIAL+MEH_CODLIS+MEH_SEQ+MEH_PRAZO		
		If !lExPEP
			//Caso nao exista prazo de entrega programada, verificar a existencia de PEP anterior
			cChave := xFilial("MEH") + cNumLst
			MEH->(DbSeek(cChave))
			Do While !MEH->(Eof()) .AND. MEH->(MEH_FILIAL + MEH_CODLIS) == xFilial("MEH") + cNumLst
				RecLock("MEH",.F.)
				MEH->(DbDelete())
				MEH->(DbCommit())
				MEH->(MsUnlock())
				MEH->(DbSkip())
			EndDo
		Else
			aTMP 	:= {}
			nPos	:= aScan(aHeader04,{|x| Upper(AllTrim(x[POS_CMP])) == "MEH_SEQ"})
			//Levantar todos as sequencias declaradas
			aEval(aCols04,{|x| aAdd(aTMP,x[nPos])})
			//Pesquisar se existe algum deles consolidado que nao consta no set atual de atores (aCols04), para exclusao
			If Len(aTMP) > 0
				lOk := .F.
				cQry := "SELECT DISTINCT MEH.MEH_SEQ "
				cQry += "FROM " + RetSQLName("MEH") + " MEH "
				cQry += "WHERE " + RetSQLDel("MEH") + " AND MEH.MEH_FILIAL = '" + xFilial("MEH") + "' AND MEH.MEH_CODLIS = '" + cNumLst + "' "
				cQry += "AND MEH.MEH_SEQ NOT IN ("
				aEval(aTMP,{|x| cQry += x + ","})
				cQry := Substr(cQry,1,Len(cQry) - 1)
				cQry += ") "
				cQry += "ORDER BY MEH.MEH_SEQ ASC"
				DbUseArea(.T.,__cRDD,TcGenQry(,,ChangeQuery(cQry)),cAliasT,.T.,.F.)
				(cAliasT)->(DbGoTop())
				If !(cAliasT)->(Eof())
					lOk 	:= .T.
					aTMP 	:= {}
					(cAliasT)->(DbEval({|x| aAdd(aTMP,FieldGet(FieldPos("MEH_SEQ")))}))
				Endif
				FechaArqT(cAliasT)
				If lOk
					//Apagar os atores consolidados que nao estao mais em uso
					For ni := 1 to Len(aTMP)
						If MEH->(DbSeek(xFilial("MEH") + cNumLst + aTMP[ni]))
							RecLock("MEH",.F.)
							MEH->(DbDelete())
							MEH->(DbCommit())
							MEH->(MsUnlock())
						Endif
					Next ni
				Endif
			Endif
			//Processar registros - gravar
			nPos02 := aScan(aHeader04,{|x| Upper(AllTrim(x[POS_CMP])) == "MEH_SEQ"})
			cChave := xFilial("MEH") + cNumLst
			For ni := 1 to Len(aCols04)
				aLinha := aCols04[ni]
				If !aTail(aLinha)
					lOk := .T.
					If MEH->(DbSeek(cChave + aLinha[nPos02]))
						//Se o recurso de gravacao exclusiva de itens alterados estiver ativa, verificar se houve alteracoes para gravar
						If !lSalvINED
							If (lOk := Lj843ExDif("MEH",aLinha,aHeader04))
								RecLock("MEH",.F.)
							Endif
						Else
							RecLock("MEH",.F.)
						Endif					
					Else
						RecLock("MEH",.T.)
					Endif
					If lOk
						MEH->MEH_FILIAL	:= xFilial("MEH")
						MEH->MEH_CODLIS	:= cNumLst
						For nx := 1 to Len(aLinha) - 1
							cCmpAt 	:= RTrim(aHeader04[nx][POS_CMP])
							nPos	:= MEH->(FieldPos(cCmpAt))
							If nPos > 0 .AND. !cCmpAt $ "MEH_FILIAL|MEH_CODLIS" .AND. aHeader04[nx][POS_CNT] # "V"
								MEH->(FieldPut(nPos,aLinha[nx]))
							Endif
						Next nx
						MEH->(MsUnlock())
					Endif
				Else
					If MEH->(DbSeek(cChave + aLinha[nPos02]))
						RecLock("MEH",.F.)
						MEH->(DbDelete())
						MEH->(DbCommit())
						MEH->(MsUnlock())					
					Endif
				Endif
			Next ni		
		Endif
	Case nOperacao == EXCLUIR
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณExclusao - ME1  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
		If !ME1->(DbSeek(xFilial("ME1") + cNumLst))
			Help(" ",1,"LJ843LNE")
			If InTransaction()
				DisarmTransaction()
			Endif
			Return !lRet		
		Endif
		//Excluir campo memo
		DbSelectArea("ME1")
		If !Empty(ME1->ME1_CODMEN)
			MSMM(ME1->ME1_CODMEN,,,,2,,,"ME1","ME1_CODMEN")	
		Endif
		//Excluir registro na ME1
		Reclock("ME1",lNovo)
		ME1->(DbDelete())
		ME1->(DbCommit())
		ME1->(MsUnlock())
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณExclusao - MEE  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DbSelectArea("MEE")
		MEE->(DbSetOrder(0))
		nPos := aScan(aHeader02,{|x| Upper(AllTrim(x[POS_CMP])) == "MEE_CODATO"})
		lOk := .F.
		cQry := "SELECT DISTINCT MEE.R_E_C_N_O_ "
		cQry += "FROM " + RetSQLName("MEE") + " MEE "
		cQry += "WHERE " + RetSQLDel("MEE") + " AND MEE.MEE_FILIAL = '" + xFilial("MEE") + "' AND MEE.MEE_CODLIS = '" + cNumLst + "' "
		cQry += "ORDER BY MEE.R_E_C_N_O_ ASC"
		DbUseArea(.T.,__cRDD,TcGenQry(,,ChangeQuery(cQry)),cAliasT,.T.,.F.)
		(cAliasT)->(DbGoTop())
		If !(cAliasT)->(Eof())
			lOk 	:= .T.
			aTMP 	:= {}
			(cAliasT)->(DbEval({|x| aAdd(aTMP,FieldGet(1))}))
		Endif
		FechaArqT(cAliasT)
		If lOk
			For ni := 1 to Len(aTMP)
				MEE->(DbGoTo(aTMP[ni]))
				If MEE->(Recno()) == aTMP[ni]
					RecLock("MEE",.F.)
					MEE->(DbDelete())
					MEE->(DbCommit())
					MEE->(MsUnlock())
				Endif
			Next ni
		Endif
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณExclusao - ME2  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DbSelectArea("ME2")
		ME2->(DbSetOrder(0))
		nPos := aScan(aHeader03,{|x| Upper(AllTrim(x[POS_CMP])) == "ME2_ITEM"})
		lOk := .F.
		cQry := "SELECT DISTINCT ME2.R_E_C_N_O_ "
		cQry += "FROM " + RetSQLName("ME2") + " ME2 "
		cQry += "WHERE " + RetSQLDel("ME2") + " AND ME2.ME2_FILIAL = '" + xFilial("ME2") + "' AND ME2.ME2_CODIGO = '" + cNumLst + "' "
		cQry += "ORDER BY ME2.R_E_C_N_O_ ASC"
		DbUseArea(.T.,__cRDD,TcGenQry(,,ChangeQuery(cQry)),cAliasT,.T.,.F.)
		(cAliasT)->(DbGoTop())
		If !(cAliasT)->(Eof())
			lOk 	:= .T.
			aTMP 	:= {}
			(cAliasT)->(DbEval({|x| aAdd(aTMP,FieldGet(1))}))
		Endif
		FechaArqT(cAliasT)
		If lOk
			For ni := 1 to Len(aTMP)
				ME2->(DbGoto(aTMP[ni]))
				If ME2->(Recno()) == aTMP[ni]
					RecLock("ME2",.F.)
					ME2->(DbDelete())
					ME2->(DbCommit())
					ME2->(MsUnlock())
				Endif
			Next ni
		Endif
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณExclusao - MEH  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DbSelectArea("MEH")
		MEH->(DbSetOrder(0))
		nPos := aScan(aHeader04,{|x| Upper(AllTrim(x[POS_CMP])) == "MEH_SEQ"})
		lOk := .F.
		cQry := "SELECT DISTINCT MEH.R_E_C_N_O_ "
		cQry += "FROM " + RetSQLName("MEH") + " MEH "
		cQry += "WHERE " + RetSQLDel("MEH") + " AND MEH.MEH_FILIAL = '" + xFilial("MEH") + "' AND MEH.MEH_CODLIS = '" + cNumLst + "' "
		cQry += "ORDER BY MEH.R_E_C_N_O_ ASC"
		DbUseArea(.T.,__cRDD,TcGenQry(,,ChangeQuery(cQry)),cAliasT,.T.,.F.)
		(cAliasT)->(DbGoTop())
		If !(cAliasT)->(Eof())
			lOk 	:= .T.
			aTMP 	:= {}
			(cAliasT)->(DbEval({|x| aAdd(aTMP,FieldGet(1))}))
		Endif
		FechaArqT(cAliasT)
		If lOk
			For ni := 1 to Len(aTMP)
				MEH->(DbGoto(aTMP[ni]))
				If MEH->(Recno()) == aTMP[ni]
					RecLock("MEH",.F.)
					MEH->(DbDelete())
					MEH->(DbCommit())
					MEH->(MsUnlock())
				Endif
			Next ni
		Endif
EndCase
End Transaction
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPonto de entrada pos-gravacao  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lPELj843Grv .And. ! lLj843Auto // Rodrigo Fernandes 31/05/2011 nใo executar se for pos alteracao do site
	ExecBlock("LJ843GRV",.F.,.F.,{FWGETCODFILIAL,M->ME1_CODIGO,nOperacao})
Endif 
//Restaurando a area de trabalho
aEval(aArea,{|x| RestArea(x)})	

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณLoja843PEPบAutor  ณVendas Cliente        บ Data ณ22/02/11         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para entrada dos prazos de entrega programado              บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Loja843PEP(aDadosEntP,aCabEntP,lMDI,lExInterf)

Local lRet				:= .T.
Local cAlias			:= "MEH"
Local aTabs				:= {"MEF","MEH","SX3"}
Local aArea				:= {}													//Variavel para armazenar as areas de trabalho
Local oArea				:= FWLayer():New()                                     //Area de trabalho
Local aLstCmp			:= {}													//Lista de campos
Local aLstCmpA			:= {}													//Lista de campos alteraveis
Local aLstCmpOb			:= {}													//Lista de campos obrigatorios
Local aLstCmpNL			:= {"MEH_CODLIS"}										//Lista de campos para nao listar
Local aLstCmpVis		:= {"MEH_SEQ"}											//Lista de campos para visualizacao (nao definidos no SX3)
Local cLinOk			:= "AllwaysTrue()"										//Validacao dos dados da linha da getdados de atores
Local cTudoOk			:= "AllwaysTrue()"										//Validacao de todo o conteudo da getdadas de atores
Local cDelOk			:= "AllwaysFalse()"										//Validacao para exclusao de registros
Local cDelTodos			:= "AllwaysFalse()"										//Validacao para CTRL+Delete
Local cIniCpos			:= "+MEH_SEQ"											//Auto sequencia de campos
Local nUsado			:= 0 													//Controle de campos utilizados
Local ni				:= 0													//Contador
Local nx				:= 0													//Cnotador 02
Local aHeader01			:= {}													//Cabecalho da GD de entregas
Local aCols01			:= {}													//Cabecalho da GD de entregas
Local nPos				:= 0				  									//Controle de posicionamento
Local dDataIni			:= IIf(Type("M->ME1_EMISSA")=="U","",M->ME1_EMISSA)	//Data de emissao da lista
Local dDataRef			:= IIf(Type("M->ME1_DTEVEN")=="U","",M->ME1_DTEVEN)	//A data do evento eh a data de referencia dos calculos
Local dDataLim			:= IIf(Type("M->ME1_DTVAL")=="U","",M->ME1_DTVAL)		//A data de validade da lista define a data maxima para entrega
Local cTipoLst			:= IIf(Type("M->ME1_TIPO")=="U","",M->ME1_TIPO)		//Tipo de lista
Local nTamIt			:= TamSX3("MEH_SEQ")[1]					   				//Tamanho do campo de item
Local lMonta			:= .T.													//Montar lista
Local nOpcA				:= 0													//Opcao de retorno
Local nLimLin			:= 0						   							//Limite de linhas da lista de entrega programada
Local aTamObj			:= Array(4)				 							//Dimensoes do objeto
Local cValid			:= ""													//Controle de validacao
Local lAjuste			:= .F.													//Ajustes de resultado
Local aApaga			:= {}													//Controle de registros apagados
Local cCoefDis			:= 0.003												//Coeficiente de reducao para distribuicao de objetos
Local aTMP				:= {}													//Array temporario
Local aCpos 			:= {}
//Variaveis de objeto de interface
Local oDlg02
Local oPainel
Local oGD03
Local oBot01
Local oBot02
Local oBot03

Default aDadosEntP		:= {}
Default aCabEntP		:= {}
Default lMDI			:= Iif(ExistFunc("LjIsMDI"),LjIsMDI(),oApp:lMDI) //Verifica se acessou via SIGAMDI
Default lExInterf		:= .T.													//Exibir interface?

//Validar as datas da lista de presentes
If !Lj843VldDt() .AND. !lLj843Auto 
	Return lRet	
Endif
//Validacao do tipo de lista
If  (Empty(cTipoLst) .OR. cTipoLst # "3") .AND. (!lLj843Auto)  
	Help(" ",1,"LJ843PE2")
	Return lRet
Endif
If ValType(aDadosEntP) == "A" .AND. Len(aDadosEntP) > 0
	lMonta := .F.
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณArmazenando dados da area de trabalho  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For ni := 1 to Len(aTabs)
	aAdd(aArea,(aTabs[ni])->(GetArea()))
Next ni
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPesquisar entregas programadas cadastradas   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("MEF")
MEF->(DbSetOrder(1))	//MEF_FILIAL+MEF_CODIGO
MEF->(DbGoTop())
If MEF->(Eof()) .AND. !lLj843Auto 
	Help(" ",1,"LJ843PE3")
	Return lRet
Else
	//Definir o limite da lista de acordo com o numero de possibilidades de prazos de entregas programados
	MEF->(DbEval({|| nLimLin++},,{|| MEF_FILIAL == xFilial("MEF")}))
	//Retornar ao primeiro registro
	MEF->(DbGoTop())
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLista de campos e dados da GD de entrega programada - MEH ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

aCpos := FWSX3Util():GetAllFields(cAlias)
For nx := 1 to len(aCpos)
	If X3Uso(GetSx3Cache(aCpos[nx],"X3_USADO")) .AND. cNivel >= GetSx3Cache(aCpos[nx],"X3_NIVEL") .AND. aScan(aLstCmpNL,{|x| x == Upper(AllTrim(aCpos[nx]))}) == 0
		aAdd(aLstCmp,aCpos[nx])
		//Caso seja obrigatorio, adicionar o item a lista de itens obrigatorios
		If X3Uso(GetSx3Cache(aCpos[nx],"X3_USADO")) .AND. (X3OBRIGAT(aCpos[nx]) .OR. VerByte(GetSx3Cache(aCpos[nx],"X3_RESERV"),7))
			aAdd(aLstCmpOb,aCpos[nx])
		Endif
		cValid := ""
		If Upper(AllTrim(aCpos[nx])) == "MEH_PRAZO"
			If !Empty(GetSx3Cache(aCpos[nx],"X3_VALID"))
				cValid := RTrim(GetSx3Cache(aCpos[nx],"X3_VALID")) + " .AND. "
			Endif
			cValid += "NaoVazio() .AND. (DtoS(M->MEH_PRAZO) >= '" + DtoS(dDataIni) + "' .AND. DtoS(M->MEH_PRAZO) <= '" + DtoS(dDataLim) + "')"
		Else
			cValid := GetSx3Cache(aCpos[nx],"X3_VALID")
		Endif
		//Cabecalho - Estrutura MsNewGetDados
		aAdd(aHeader01,{RTrim(X3Titulo()),;
						aCpos[nx],;
						GetSx3Cache(aCpos[nx],"X3_PICTURE"),;
						GetSx3Cache(aCpos[nx],"X3_TAMANHO"),;
						GetSx3Cache(aCpos[nx],"X3_DECIMAL"),;
						cValid,;
						GetSx3Cache(aCpos[nx],"X3_USADO"),;
						GetSx3Cache(aCpos[nx],"X3_TIPO"),;
						GetSx3Cache(aCpos[nx],"X3_F3"),;
						GetSx3Cache(aCpos[nx],"X3_CONTEXT"),;
						GetSx3Cache(aCpos[nx],"X3_CBOX"),;						
						GetSx3Cache(aCpos[nx],"X3_RELACAO"),;
						GetSx3Cache(aCpos[nx],"X3_WHEN"),;
						IIf((nPos := aScan(aLstCmpVis,{|x| x == Upper(AllTrim(aCpos[nx]))})) == 0,GetSx3Cache(aCpos[nx],"X3_VISUAL"),"V"),;
						GetSx3Cache(aCpos[nx],"X3_VLDUSER"),;
						GetSx3Cache(aCpos[nx],"X3_PICTVAR"),;
						GetSx3Cache(aCpos[nx],"X3_OBRIGAT")})
	Endif
Next nX

aLstCmpA 	:= aClone(aLstCmp)
nUsado		:= Len(aHeader01)
nPos		:= 0
aCabEntP	:= aClone(aHeader01)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMontar a lista de dados  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lMonta
	If !Lj843PEPCl(aHeader01,@aCols01,dDataIni,dDataRef,dDataLim)
		Help(" ",1,"LJ843PE1")
		Return lRet
	Endif
Else
	aCols01 := aClone(aDadosEntP)
Endif
If !lLj843Auto .AND. lExInterf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInterface lista de prazo de entrega progamado  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DEFINE MSDIALOG oDlg02 TITLE STR0014 FROM 000,000 TO 300,600 OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE,WS_POPUP) PIXEL //"Lista de entregas programadas"
	oArea:Init(oDlg02,!lMDI)
	oArea:AddLine("L01",100,.T.)
	oArea:AddCollumn("L01C01",100,.F.,"L01")
	oArea:AddWindow("L01C01","L01C01P01",STR0015,100,.F.,.F.,,"L01") //"Entregas programadas"
	oPainel := oArea:GetWinPanel("L01C01","L01C01P01","L01")
	//Dimensoes do objeto - MsNewGetDados
	aTamObj[1] := 000
	aTamObj[2] := 000
	aTamObj[3] := (oPainel:nClientHeight / 2) * 0.9
	aTamObj[4] := (oPainel:nClientWidth / 2) * nPercUtO
	oGD03 := MsNewGetDados():New(aTamObj[1],aTamObj[2],aTamObj[3],aTamObj[4],IIf(lEdita,GD_UPDATE+GD_INSERT,0),cLinOk,cTudoOk,cIniCpos,aLstCmpA,0,nLimLin,/*cFieldOk*/,cDelTodos,cDelOk,oPainel,@aHeader01,@aCols01)
	oGD03:lEditLine := .F.
	//Dimensoes do objeto - Botoes
	aTamObj[1] := (oGD03:oBrowse:nBottom / 2) + 2
	aTamObj[2] := 000
	aTamObj[3] := (oPainel:nClientWidth / 2) * ((nPercUtO - (cCoefDis * nTotBot)) / nTotBot)
	aTamObj[4] := 012
	//Botao - Confirmar
	oBot01 := tButton():New(aTamObj[1],aTamObj[2],STR0016,oPainel,{|| IIf(Lj843PEPCh(@nOpcA,oGD03),oDlg02:End(),.F.)},aTamObj[3],aTamObj[4],,; //"Confirmar"
		/*Font*/,,.T.,,,,{|| lEdita}/*When*/)
	//Botao - Recalcular
	aTamObj[2] := ((oBot01:nLeft + oBot01:nWidth) / 2) + 2
	oBot02 := tButton():New(aTamObj[1],aTamObj[2],STR0017,oPainel,{|| Lj843PEPCl(aHeader01,@aCols01,dDataIni,dDataRef,dDataLim,@oGD03,.T.)},aTamObj[3],aTamObj[4],,; //"Recalcular"
		/*Font*/,,.T.,,,,{|| lEdita}/*When*/)
	//Botao - Cancelar
	aTamObj[2] := ((oBot02:nLeft + oBot02:nWidth) / 2) + 2
	oBot03 := tButton():New(aTamObj[1],aTamObj[2],STR0010,oPainel,{|| oDlg02:End()},aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,/*When*/) //"Fechar"
	//Configuracoes e ativacao 
	oDlg02:lMaximized := .F.
	oDlg02:Activate(,,,.T.,/*valid*/,,{|| oGD03:oBrowse:SetFocus()})
Else
	nOpcA := 1
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณProcessamento  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOpcA == 1
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณIdentificar duplicidade de prazos de entrega.  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !lLj843Auto .AND. lExInterf
		aCols01 := oGD03:aCols
	Endif
	nPos := aScan(aHeader01,{|x| Upper(AllTrim(x[POS_CMP])) == "MEH_PRAZO"})
	For ni := 1 to Len(aCols01) - 1
		//Apagar os registros com data de entrega duplicados e mante o ultimo, por conta das condicoes de entrega
		If aCols01[ni + 1][nPos] == aCols01[ni][nPos]
			aTail(aCols01[ni]) := .T.
			lAjuste := .T.
		Endif
	Next ni
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCaso existam registros apagados, reorganizar e remover elemento.  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lAjuste
		nx 		:= 0
		nApaga 	:= 0
		nPos 	:= aScan(aHeader01,{|x| Upper(AllTrim(x[POS_CMP])) == "MEH_SEQ"})
		For ni := 1 to Len(aCols01)
			If !aTail(aCols01[ni])
				aCols01[ni][nPos] := StrZero(++nx,nTamIt)
			Else
				aAdd(aApaga,ni)
			Endif
		Next ni
		If Len(aApaga) > 0
			aTMP := {}
			For ni := 1 to Len(aCols01)
				If aScan(aApaga,{|x| x == ni}) == 0
					aAdd(aTMP,aCols01[ni])
				Endif
			Next ni	
			aCols01 := aClone(aTMP)
		Endif
	Endif
	aDadosEntP := aClone(aCols01)
	lRet := !lRet
Endif
//Restaurando a area de trabalho
aEval(aArea,{|x| RestArea(x)})	

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณLj843PEPChบAutor  ณVendas Cliente        บ Data ณ23/02/11         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para validacao da getdados de entregas programadas         บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[N] : Variavel de opcao de processamento Loja843PEP          บฑฑ
ฑฑบ          ณExp02[O] : Objeto de getdados da lista de entrega programada      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Lj843PEPCh(nOpcA,oGD03)

Local lRet             	:= .T.
Local ni				:= 0
Local nx				:= 0
Local aHead				:= {}
Local aCol				:= {}
Local nPos				:= 0

Default nOpcA 			:= 0
Default oGD03 			:= Nil

If nOpcA == Nil .OR. ValType(oGD03) # "O"
	Return !lRet
Endif
aHead	:= oGD03:aHeader
aCol 	:= oGD03:aCols
nPos	:= aScan(aHead,{|x| Upper(AllTrim(x[2])) == "MEH_PRAZO"})
If Len(aCol) == 0 .AND. !lLj843Auto 
	Return !lRet
Endif
For ni := 1 to Len(aCol)
	For nx := 1 to Len(aCol)
		If nx # ni
			If nx <= ni
				If aCol[ni][nPos] < aCol[nx][nPos]
					MsgAlert(STR0018 + aCol[ni][aScan(aHead,{|x| Upper(AllTrim(x[2])) == "MEH_SEQ"})] + STR0019) //"A data da sequ๊ncia "###" ้ invแlida!"
					lRet := !lRet
					Exit
				Endif			
			Else
				If aCol[ni][nPos] > aCol[nx][nPos]
					MsgAlert(STR0018 + aCol[ni][aScan(aHead,{|x| Upper(AllTrim(x[2])) == "MEH_SEQ"})] + STR0019) //"A data da sequ๊ncia "###" ้ invแlida!"
					lRet := !lRet
					Exit
				Endif
			Endif
		Endif
	Next nx	
	If !lRet
		Exit
	Endif
Next ni
If lRet
	nOpcA := 1
Else
	n := ni
	oGD03:nAt := ni
	oGD03:oBrowse:SetFocus()
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณLj843PEPClบAutor  ณVendas Cliente        บ Data ณ24/02/11         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de montagem da grid de dados da lista de prazos de entrega บฑฑ
ฑฑบ          ณprogramados.                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[A] : Cabecalho                                              บฑฑ
ฑฑบ          ณExp02[A] : Colunas de dados                                       บฑฑ
ฑฑบ          ณExp03[D] : Data abertura lista                                    บฑฑ
ฑฑบ          ณExp04[D] : Data evento                                            บฑฑ
ฑฑบ          ณExp05[D] : Data validade lista                                    บฑฑ
ฑฑบ          ณExp06[O] : Objeto da grid                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณlRet[L]  : Indicador de resultado                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Lj843PEPCl(	aHeader01,aCols01,dDataIni,dDataRef ,;
							dDataLim ,oGD    ,lRecalc ,lRetLstPE,;
							lRemPERep)

Local uRet				:= .T.													//Retorno
Local cAlias			:= "MEH"
Local ni				:= 0													//Contador
Local nx				:= 0													//Contador 02
Local nPos				:= 0				  									//Controle de posicionamento
Local cChave			:= ""													//Cahve de pesquisa
Local nUsado			:= 0 													//Controle de campos utilizados
Local lMonta			:= .F.
Local dDataTMP																	//Data temporaria para processamento
Local nTamIt			:= TamSX3("MEH_SEQ")[1]					   				//Tamanho do campo de item
Local aPEAnt			:= {}													//Lista de prazos anteriores
Local aPEPos			:= {}													//Lista de prazos posteriores
Local aResulta			:= {}													//Resultado ordenado da sequencia de prazos
Local lAjuste			:= .F.													//Ajustar sequencia
Local nApaga			:= 0													//Total dce itens a apagar
Local aApaga			:= {}													//Lista de itens a apagar
Local aTMP				:= {}													//Array temporario

Default aHeader01       := {}
Default aCols01         := {}
Default dDataIni        := cToD("  /  /  ")
Default dDataRef        := cToD("  /  /  ")
Default dDataLim        := cToD("  /  /  ")
Default oGD             := Nil
Default lRecalc		    := .F.													//Recalcular lista?
Default lRetLstPE		:= .F.													//Utilizar a funcao para retorno da lista de prazos de entrega calculado
Default lRemPERep		:= .F.													//Remover prazos de entrega calculados que sejam repetidos?

//Verificar minimo de parametros fornecidos
If PCount() < 5
	If !lRetLstPE
		Return !uRet
	Else
		Return Array(0)
	Endif
Endif
nUsado		:= Len(aHeader01)
nPos		:= 0
lMonta 		:= .F.
aCols01		:= {}
If nOperacao == INCLUIR .OR. lRecalc
	lMonta := .T.
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMontagem a partir da MEH  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aCols01 := Array(0)
	cChave := RTrim(xFilial(cAlias) + M->ME1_CODIGO)
	//Pesquisar dados gravados da lista
	DbSelectArea(cAlias)
	(cAlias)->(DbSetOrder(1))
	(cAlias)->(DbSeek(cChave))
	If (cAlias)->(Found())
		Do While !(cAlias)->(Eof()) .AND. RTrim((cAlias)->(MEH_FILIAL + MEH_CODLIS)) == cChave
			aAdd(aCols01,Array(nUsado + 1))
			nPos := Len(aCols01)
			aTail(aCols01[nPos]) := .F.
			For ni := 1 to nUsado
				aCols01[nPos][ni] := (cAlias)->(FieldGet(FieldPos(aHeader01[ni][POS_CMP])))
			Next ni
			(cAlias)->(DbSkip())
		EndDo
	Else
		//Caso nao exista dados na tabela, montar a lista de entrega programada
		lMonta := .T.
	Endif
Endif
If lMonta
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMontagem a partir da MEF  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("MEF")
	MEF->(DbSetOrder(1))
	MEF->(DbGoTop())
	Do While !MEF->(Eof())
		If MEF->MEF_PONTO == "1"
			aAdd(aPEAnt,{MEF->MEF_CODIGO,MEF->MEF_DIAS})
		Else
			aAdd(aPEPos,{MEF->MEF_CODIGO,MEF->MEF_DIAS})
		Endif
		MEF->(DbSkip())
	EndDo
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณClassificar as listas de entrega de data anterior e posterior a data de evento  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Len(aPEAnt)	> 0
		aSort(aPEAnt,,,{|x,y| x[2] > y[2]})
		aResulta := aClone(aPEAnt)
	Endif
	If Len(aPEPos)	> 0
		aSort(aPEPos,,,{|x,y| x[2] < y[2]})
		aEval(aPEPos,{|x| aAdd(aResulta,x)})
	Endif
	For nx := 1 to Len(aResulta)
		If MEF->(DbSeek(xFilial("MEF") + aResulta[nx][1]))
			aAdd(aCols01,Array(nUsado + 1))
			nPos++
			For ni := 1 to nUsado
				Do Case
					Case Upper(AllTrim(aHeader01[ni][POS_CMP])) == "MEH_SEQ"
						aCols01[nPos][ni] := StrZero(nPos,nTamIt)
					Otherwise
						aCols01[nPos][ni] := CriaVar(aHeader01[ni][POS_CMP])
				EndCase
			Next ni
			aTail(aCols01[nPos]) := .F.
			//Tratamento para a data de entrega
			dDataTMP := IIf(MEF->MEF_PONTO == "1",dDataRef - MEF->MEF_DIAS,dDataRef + MEF->MEF_DIAS)
			If dDataTMP > dDataLim
				dDataTMP := dDataLim
			ElseIf dDataTMP < dDataIni
				dDataTMP := dDataIni
			Endif			
			aCols01[nPos][aScan(aHeader01,{|x| Upper(AllTrim(x[POS_CMP])) == "MEH_PRAZO"})] 	:= dDataTMP
			aCols01[nPos][aScan(aHeader01,{|x| Upper(AllTrim(x[POS_CMP])) == "MEH_QTDMIN"})]	:= MEF->MEF_QTDMIN
			aCols01[nPos][aScan(aHeader01,{|x| Upper(AllTrim(x[POS_CMP])) == "MEH_VALMIN"})] 	:= MEF->MEF_VALMIN
			aCols01[nPos][aScan(aHeader01,{|x| Upper(AllTrim(x[POS_CMP])) == "MEH_ENTFDS"})] 	:= MEF->MEF_ENTFDS
		Endif
	Next nx
	MEF->(DbGoTop())
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณIdentificar e remover duplicidade de prazos de entrega  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRemPERep
	nPos := aScan(aHeader01,{|x| Upper(AllTrim(x[POS_CMP])) == "MEH_PRAZO"})
	aTMP := {}
	For ni := 1 to Len(aCols01) - 1
		//Apagar os registros com data de entrega duplicados e mante o ultimo, por conta das condicoes de entrega
		If aCols01[ni + 1][nPos] == aCols01[ni][nPos]
			aAdd(aTMP,ni)
			lAjuste := .T.
		Endif
	Next ni
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCaso existam registros apagados, reorganizar e remover elemento.  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lAjuste
		nx 		:= 0
		nApaga 	:= 0
		nPos 	:= aScan(aHeader01,{|x| Upper(AllTrim(x[POS_CMP])) == "MEH_SEQ"})
		For ni := 1 to Len(aCols01)
			If aScan(aTMP,{|x| x == ni}) == 0
				aCols01[ni][nPos] := StrZero(++nx,nTamIt)
			Else
				aAdd(aApaga,ni)
			Endif
		Next ni
		If Len(aApaga) > 0
			aTMP := {}
			For ni := 1 to Len(aCols01)
				If aScan(aApaga,{|x| x == ni}) == 0
					aAdd(aTMP,aCols01[ni])
				Endif
			Next ni
			aCols01 := aClone(aTMP)
		Endif
	Endif	
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtualizar objeto  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ValType(oGD) == "O"
	oGD:aCols := aCols01
	oGD:Refresh()
Endif
If !lRetLstPE
	uRet := .T.
Else
	uRet := aCols01
Endif

Return uRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณLj843VldDtบAutor  ณVendas Cliente        บ Data ณ23/02/11         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de validacao das datas da lista de presente.               บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[L] : Rotina automatica                                      บฑฑ
ฑฑบ          ณExp02[C] : Mensagem de retorno (caso passado por referencia)      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Lj843VldDt(lAuto,cMens)

Local lRet             := .T.
Local dDataIni			:= IIf(Type("M->ME1_EMISSA") == "U"	,"",M->ME1_EMISSA)	//Data de emissao da lista
Local dDataRef			:= IIf(Type("M->ME1_DTEVEN") == "U"	,"",M->ME1_DTEVEN)	//A data do evento eh a data de referencia dos calculos
Local dDataLim			:= IIf(Type("M->ME1_DTVAL") == "U"	,"",M->ME1_DTVAL)	//A data de validade da lista define a data maxima para entrega
Local dDataDisp			:= IIf(Type("M->ME1_DTDISP") == "U"	,"",M->ME1_DTDISP)	//Data de disponibilidade da lista

Default lAuto			:= .F.
Default cMens			:= ""

//Validacao das datas
If Empty(dDataRef) .OR. Empty(dDataIni) .OR. Empty(dDataLim) .OR. Empty(dDataDisp) .AND. !lLj843Auto 
	cMens := STR0020 + CRLF //"Para prosseguir, e necessario definir a data do evento, data inicial, data de disponibilidade e data de validade da lista."
	lRet := !lRet
Endif
If lRet .AND. dDataIni > dDataLim .AND. !lLj843Auto 
	cMens := STR0021 + CRLF //"A data de validade nao pode ser menor que a data inicial."
	lRet := !lRet
Endif
If lRet .AND. dDataIni > dDataRef .AND. !lLj843Auto 
	cMens := STR0022 + CRLF //"A data do evento nao pode ser menor que a data inicial."
	lRet := !lRet
Endif
If lRet .AND. dDataLim < dDataRef .AND. !lLj843Auto 
	cMens := STR0023 + CRLF //"A data de validade nใo pode ser menor que a data do evento."
	lRet := !lRet
Endif
If lRet .AND. dDataDisp < dDataIni .AND. !lLj843Auto 
	cMens := STR0024 + CRLF //"A data de disponibilidade da lista nใo pode ser menor que a data inicial da lista."
	lRet := !lRet
Endif
If lRet .AND. dDataDisp > dDataRef .AND. !lLj843Auto 
	cMens := STR0025 + CRLF //"A data de disponibilidade da lista nใo pode ser maior que a data do evento."
	lRet := !lRet
Endif
If !lRet .AND. !lAuto
	MsgAlert(cMens)	
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณLj843ExItBlqบAutor  ณVendas Cliente      บ Data ณ25/02/11         บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para retornar se existem itens bloqueados em uma dada listaบฑฑ
ฑฑบ          ณde presentes.                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[N] : 1 = Retorno logico  2 = Retorno com array dos itens    บฑฑ
ฑฑบ          ณExp02[C] : Filial de pesquisa (opcional)                          บฑฑ
ฑฑบ          ณExp03[C] : Codigo da lista                                        บฑฑ
ฑฑบ          ณExp04[C] : Codigo do cliente (opcional)                           บฑฑ
ฑฑบ          ณExp05[N] : Loja (opcional)                                        บฑฑ
ฑฑบ          ณExp06[N] : Origem do item, organizador / comprador (opcional)     บฑฑ
ฑฑบ          ณExp07[L] : Fazer com que a rotina retorne os itens validos        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณuRet[U]  : Retorno com o tipo atrelado ao 1o parametro            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Lj843ExItBlq(	nOpc	,cFil	,cNumLst	,cCodCli,;
						cCodLoja,cOrigem,lRetValido	)

Local uRet				:= .F.
Local lTOP				:= .T.
Local cQry				:= ""
Local cAlias01			:= "ME1"
Local cAlias02			:= "ME2"
Local cAliasT			:= GetNextAlias()
Local lOk				:= .T.
Local lExFEA			:= FindFunction("FechaArqT")

Default nOpc           	:= 1
Default cFil			:= ""
Default cNumLst		   	:= ""
Default cCodCli			:= ""
Default cCodLoja		:= ""
Default cOrigem			:= ""
Default lRetValido		:= .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValidacao de parametros e ambiente  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#IFNDEF TOP
	lTOP := !lTOP
#ELSE
	If Upper(AllTrim(TcSrvType())) == "AS/400"
		lTOP := !lTOP
	Endif
#ENDIF						
If Empty(cNumLst) .OR. PCount() > 6 .OR. !cValToChar(nOpc) $ "12" .OR. !lTOP .OR. !AliasInDic(cAlias01) .OR. !AliasInDic(cAlias02) .OR. !lExFEA
	If nOpc == 2 ; uRet := Array(0) ; Endif
	Return uRet	
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerificar a existencia fisica das tabelas no banco de dados  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !MsFile(RetSQLName(cAlias01),Nil,__cRDD)
	ChkFile(cAlias01)
Endif
If !MsFile(RetSQLName(cAlias02),Nil,__cRDD)
	ChkFile(cAlias02)
Endif
If nOpc == 2 ; uRet := Array(0) ; Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValidar lista de presente determinada  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cQry := "SELECT DISTINCT ME1.ME1_CODIGO "
cQry += "FROM " + RetSQLName(cAlias01) + " " + cAlias01 + " "
cQry += "WHERE " + RetSQLDel(cAlias01) + " AND ME1.ME1_FILIAL = '" + IIf(Empty(cFil),xFilial("ME1"),cFil) + "' AND ME1.ME1_CODIGO = '" + cNumLst + "' "
If !Empty(cCodCli)
	cQry += "AND ME1.ME1_CODCLI = '" + cCodCli + "' "
	If !Empty(cCodLoja)
		cQry += "AND ME1.ME1_LOJCLI = '" + cCodLoja + "' "
	Endif
Endif
DbUseArea(.T.,__cRDD,TcGenQry(,,ChangeQuery(cQry)),cAliasT,.T.,.F.)
(cAliasT)->(DbGoTop())
If (cAliasT)->(Eof())
	lOk := !lOk
Endif
FechaArqT(cAliasT)
If !lOk
	Return uRet
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPesquisar se existem itens bloqueados  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lOk := .T.
cQry := "SELECT DISTINCT ME2.ME2_ITEM "
cQry += "FROM " + RetSQLName(cAlias02) + " " + cAlias02 + " "
cQry += "WHERE " + RetSQLDel(cAlias02) + " AND ME2.ME2_FILIAL = '" + IIf(Empty(cFil),xFilial("ME2"),cFil) + "' AND ME2.ME2_CODIGO = '" + cNumLst + "' "
If !lRetValido
	cQry += "AND (ME2.ME2_STATUS <> 'A' OR ME2.ME2_QTDATE > 0) "
Else
	cQry += "AND (ME2.ME2_STATUS = 'A' OR ME2.ME2_QTDATE = 0) "
Endif
If !Empty(cOrigem)
	cQry += "AND (ME2.ME2_ORIGEM = '" + cOrigem + "' "
Endif
cQry += "ORDER BY ME2.ME2_ITEM ASC"
DbUseArea(.T.,__cRDD,TcGenQry(,,ChangeQuery(cQry)),cAliasT,.T.,.F.)
(cAliasT)->(DbGoTop())
If (cAliasT)->(Eof())
	lOk := !lOk
Else
	If nOpc == 2
		Do While !(cAliasT)->(Eof())
			aAdd(uRet,(cAliasT)->(FieldGet(1)))
			(cAliasT)->(DbSkip())
		EndDo
	Else
		uRet := .T.
	Endif
Endif
FechaArqT(cAliasT)
If !lOk
	Return uRet
Endif

Return uRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณLj843ImpPr  บAutor  ณVendas Cliente      บ Data ณ14/03/11         บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para importar produtos atraves de uma array, otimizando a  บฑฑ
ฑฑบ          ณutilizacao por produto, seguindo as regras de validacao de regis. บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[O] : Objeto do tipo grid utilizando a classe MsNewGetDados  บฑฑ
ฑฑบ          ณExp02[A] : Array de dados                                         บฑฑ
ฑฑบ          ณExp03[N] : Posicao do campo Codigo do Produto no array de dados   บฑฑ
ฑฑบ          ณExp04[N] : Posicao do campo Preco Unitario no array de dados      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณuRet[U]  : Retorno com o tipo atrelado ao 1o parametro            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Lj843ImpPr(	oGD		,aTMP	,nPosCod,nPosPrUn,;
							nPosVend,nPosQtd,cFonte)

Local lRet				:= .T.									//Variavel de retorno
Local ni				:= 0									//Contador
Local nx				:= 0									//Contador02
Local aInsere			:= {}									//Array de itens a inserir [1] Cod.Prod. [2] Qtde. [3] Preco [4] Item associado [5] Novo [6] Bloqueado						:
Local aHead				:= {}									//Cabecalho da grid de dados
Local aCol				:= {}									//Dados da grid de dados
Local aPos				:= {}									//Posicionador de campos da grid de dados
Local nPos				:= 0									//Posicionador 
Local nPosReg			:= 0									//Posicionador de registro
Local nValor			:= 0									//Variavel para valorizacao
Local lBloq				:= .T.									//Bloqueado SB1?
Local cCodProd			:= ""									//Codigo do produto
Local aLstItBlq			:= {}									//Lista de itens bloqueados para uso
Local cNumLst			:= ""									//Numero da lista
Local cProxIt			:= ""									//Codigo do proximo item
Local aSB1				:= {}									//Dados dos produtos
Local aCodVend			:= {}									//Codigo do vendedor
Local aREG				:= {}									//Registro atual
Local lOk				:= .T.									//Controle de fluxo
Local aCodCli			:= {}									//Referencia do cliente
Local cMens				:= ""									//Mensagem de resultado de processamento
Local aTotal			:= Array(7,2)							//Totalizadores
Local nEsp				:= 3									//Espacamento
Local cTMP				:= ""									//String temporario
Local lVendLst			:= .F.									//Vendedor recebido na lista de itens a importar?
Local nQtdeIt			:= 0									//Quantidade por item

Default oGD				:= Nil
Default aTMP			:= {}
Default nPosCod			:= 0
Default nPosPrUn		:= 0
Default nPosVend		:= 0
Default nPosQtd			:= 0
Default cFonte			:= "1"									//Fonte do item (1=Manual;2=Web;3=PDA)

If oGD == Nil .OR. ValType(oGD) # "O" .OR. ValType(aTMP) # "A" .OR. Len(aTMP) == 0 .OR. Empty(nPosCod)
	Return !lRet
Endif
If Empty(M->ME1_CODCLI) .OR. Empty(M->ME1_LOJCLI)
	MsgAlert(STR0026) //"Para importar itens, ้ necessแrio definir o organizador!"
	Return !lRet
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializar variaveis  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aHead	:= oGD:aHeader
aCol	:= oGD:aCols
cNumLst := M->ME1_CODIGO
cProxIt	:= StrZero(1,TamSX3("ME2_ITEM")[1])
//Caso a operacao seja de inclusao, a lista possua apenas um item e nao tenha sido editada, iniciar a lista novamente
If nOperacao == INCLUIR .AND. Len(oGD:aCols) == 1 .AND. !oGD:lModified
	nPosReg	:= 1
	aCol	:= Array(0)
Else
	nPosReg := Len(aCol) + 1 
Endif
DbSelectArea("SA1")
If Len(aCodCli := GetAdvfVal("SA1",{"A1_COD","A1_LOJA"},xFilial("SA1") + M->ME1_CODCLI + M->ME1_LOJCLI,1)) == 0
	Help(" ",1,"LJ843NCL")
	Return !lRet
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTratamento de vendedores  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(nPosVend)
	For ni := 1 to Len(aTMP)
		If !Empty(aTMP[ni][nPosVend])
			//Se o codigo do vendedor jah nao estiver na lista e o codigo sugerido for valido, adicionar
			If aScan(aCodVend,{|x| AllTrim(x) == AllTrim(aTMP[ni][nPosVend])}) == 0 .AND. ;
				!Empty(cTMP := GetAdvfVal("SA3","A3_COD",xFilial("SA3") + aTMP[ni][nPosVend],1))

				aAdd(aCodVend,cTMP)
				lVendLst := .T.
			Endif
		Endif
	Next ni
Endif
//Caso nenhum vendedor valido tenha sido definido, perguntar
If !lVendLst 
	//Validar se o campo de vendedor eh obrigatorio
	If aScan(aLstCmpOb2,{|x| Upper(AllTrim(x)) == Upper(AllTrim("ME2_VEND"))}) > 0
		If ConPad1(,,,"SA3",/*cRet*/,,.F./*lOnlyView*/,/*Campo chamada*/,,/*Cont.Campo Antes Chamada*/)
			aAdd(aCodVend,SA3->A3_COD)
		Else
			Help(" ",1,"LJ843VOB")
			Return !lRet
		Endif	
	Else
		If ApMsgYesNo(STR0027) //"Deseja selecionar um vendedor para vincular os itens เ inserir?"
			If ConPad1(,,,"SA3",/*cRet*/,,.F./*lOnlyView*/,/*Campo chamada*/,,/*Cont.Campo Antes Chamada*/)
				aAdd(aCodVend,SA3->A3_COD)
			Endif
		Endif
	Endif
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLista de campos utilizados    ณ
//ณ[1] Campo                     ณ
//ณ[2] Posicao aHeader           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd(aPos,{"ME2_ITEM"	,Lj843RetCol(1,"ME2_ITEM",2,1,aHead,aCol,.F.)		,POS_ITEM})
aAdd(aPos,{"ME2_PRODUT"	,Lj843RetCol(1,"ME2_PRODUT",2,1,aHead,aCol,.F.)	,POS_COD})
aAdd(aPos,{"ME2_DESCRI"	,Lj843RetCol(1,"ME2_DESCRI",2,1,aHead,aCol,.F.)	,POS_DESC})
aAdd(aPos,{"ME2_UM"		,Lj843RetCol(1,"ME2_UM",2,1,aHead,aCol,.F.)		,POS_UM})
aAdd(aPos,{"ME2_QTDSOL"	,Lj843RetCol(1,"ME2_QTDSOL",2,1,aHead,aCol,.F.)	,POS_QTD})
aAdd(aPos,{"ME2_SUGEST"	,Lj843RetCol(1,"ME2_SUGEST",2,1,aHead,aCol,.F.)	,POS_SUG})
aAdd(aPos,{"ME2_VEND"	,Lj843RetCol(1,"ME2_VEND",2,1,aHead,aCol,.F.)		,POS_VEND})
aAdd(aPos,{"ME2_FILORI"	,Lj843RetCol(1,"ME2_FILORI",2,1,aHead,aCol,.F.)	,POS_FILO})
aAdd(aPos,{"ME2_VALUNI"	,Lj843RetCol(1,"ME2_VALUNI",2,1,aHead,aCol,.F.)	,POS_PRC})
aAdd(aPos,{"ME2_FONTE"	,Lj843RetCol(1,"ME2_FONTE",2,1,aHead,aCol,.F.)		,0})
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAgrupar produtos recebidos em um array aglutinado por  ณ
//ณquantidade.                                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For ni := 1 to Len(aTMP)
	cCodProd	:= PadR(aTMP[ni][nPosCod],TamSX3("B1_COD")[1])
	If !Empty(nPosPrUn)
		nValor := GetDToVal(AllToChar(aTMP[ni][nPosPrUn]))
	Else
		nValor := 0
	Endif
	If !Empty(nPosQtd)
		nQtdeIt := GetDToVal(AllToChar(aTMP[ni][nPosQtd]))
	Else
		nQtdeIt := 1
	Endif
	DbSelectArea("SB1")
	lBloq := (aSB1 := GetAdvFVal("SB1",{"B1_MSBLQL","B1_DESC","B1_UM"},xFilial("SB1") + cCodProd,1))[1] == "1"
	If (nPos := aScan(aInsere,{|x| AllTrim(x[1]) == AllTrim(cCodProd)})) == 0
		aAdd(aInsere,Array(13))
		nPos := Len(aInsere)
		aInsere[nPos][POS_COD]		:= cCodProd
		aInsere[nPos][POS_QTD]		:= nQtdeIt
		aInsere[nPos][POS_PRC]		:= IIf(!Empty(nValor),nValor,Lj843PrcV(aInsere[nPos][POS_COD]))
		aInsere[nPos][POS_ITEM]		:= ""
		aInsere[nPos][POS_DESC]		:= aSB1[2]
		aInsere[nPos][POS_UM]		:= aSB1[3]
		If !lVendLst
			If Len(aCodVend) == 0
				aInsere[nPos][POS_VEND]	:= Space(TamSX3("A3_COD")[1])
			Else
				aInsere[nPos][POS_VEND]	:= PadR(aCodVend[1],TamSX3("A3_COD")[1])
			Endif
		Else
			//Verificar se o vendedor em questao eh valido
			If aScan(aCodVend,{|x| AllTrim(x) == AllTrim(aTMP[ni][nPosVend])}) > 0
				aInsere[nPos][POS_VEND]	:= PadR(aTMP[ni][nPosVend],TamSX3("A3_COD")[1])
			Else
				//Caso nao seja, utilizar o primeiro elemento
				aInsere[nPos][POS_VEND]	:= PadR(aCodVend[1],TamSX3("A3_COD")[1])
			Endif
		Endif
		aInsere[nPos][POS_SUG]		:= "1"
		aInsere[nPos][POS_FILO]		:= FWGETCODFILIAL
		aInsere[nPos][POS_NOVO]		:= .F.
		aInsere[nPos][POS_BLQ]		:= lBloq
		aInsere[nPos][POS_CPO]		:= .F.
		If Empty(aSB1[2]) .AND. Empty(aSB1[3])
			aInsere[nPos][POS_PNE]	:= .T.
		Else
			aInsere[nPos][POS_PNE]	:= .F.
		Endif
	Else
		aInsere[nPos][POS_QTD]++
	Endif
Next ni
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLevantar lista de itens bloqueados  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(aCol) > 0 .AND. !lNovo
	aLstItBlq := Lj843ExItBlq(2,,cNumLst,aCodCli[1],aCodCli[2])
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLevantar ultimo item  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(aCol) > 0
	cProxIt := Soma1(aCol[Len(aCol)][aScan(aPos,{|x| x[1] == "ME2_ITEM"})])
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLevantar itens com o mesmo codigo de produto e que podem  ณ
//ณser reaproveitados, agregando-se apenas a quantidade.     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For ni := 1 to Len(aInsere)
	//Se o item estiver bloqueado, saltar
	If aInsere[ni][POS_BLQ] .OR. aInsere[ni][POS_PNE]
		Loop
	Endif
	For nx := 1 to Len(aCol)
		If Upper(AllTrim(aInsere[ni][POS_COD])) == Upper(AllTrim(aCol[nx][aScan(aPos,{|x| x[1] == "ME2_PRODUT"})]))
			//Verificar a origem
			If aCol[nx][aScan(aHead,{|x| Upper(AllTrim(x[2])) == "ME2_ORIGEM"})] == "O"
				//Verificar se o item nao esta bloqueado para alteracao
				If aScan(aLstItBlq,{|x| x == aCol[nx][aScan(aPos,{|x| x[1] == "ME2_ITEM"})]}) == 0
					//Associar o item da lista de sugestao ao item existente
					aInsere[ni][POS_ITEM] := aCol[nx][aScan(aPos,{|x| x[1] == "ME2_ITEM"})]
					Exit
				Endif
			Endif
		Endif
	Next nx
Next ni
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInserir os novos itens  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For ni := 1 to Len(aInsere)
	//Se o item estiver bloqueado, saltar
	If aInsere[ni][POS_BLQ] .OR. aInsere[ni][POS_PNE]
		Loop
	Endif
	If !Empty(aInsere[ni][POS_ITEM])
		//ฺฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณALTERACAO  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤู	
		If (nPos := aScan(aCol,{|x| Upper(AllTrim(x[aScan(aPos,{|x| x[1] == "ME2_ITEM"})])) == Upper(AllTrim(aInsere[ni][POS_ITEM]))})) > 0
			aCol[nPos][aPos[aScan(aPos,{|x| x[1] == "ME2_QTDSOL"})][2]] += aInsere[ni][POS_QTD]
			aCol[nPos][aPos[aScan(aPos,{|x| x[1] == "ME2_SUGEST"})][2]] := "1"
			aCol[nPos][aPos[aScan(aPos,{|x| x[1] == "ME2_FONTE"})][2]] := cFonte
		Endif
	Else
		//ฺฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณINCLUSAO   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤู	
		aREG := Array(Len(aHead) + 1)
		aTail(aREG) := .F.
		lOk := .T.
		//Varrer campos
		For nx := 1 to Len(aHead)
			//Validar se o campo eh virtual
			If aHead[nx][10] # "V"
				//Verificar se o campo esta na lista de campos a inserir
				If (nPos := aScan(aPos,{|x| x[1] == Upper(AllTrim(aHead[nx][2]))})) > 0
					Do Case
						Case aPos[nPos][1] == "ME2_ITEM"
							aREG[nx] := cProxIt
						Case aPos[nPos][1] == "ME2_FONTE"
							aREG[nx] := cFonte
						Otherwise
							aREG[nx] := aInsere[ni][aTail(aPos[nPos])]
					EndCase
				Else
					aREG[nx] := CriaVar(aHead[nx][2],.T.)
				Endif
			Endif
		Next nx
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณValidar campos obrigatorios  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		For nx := 1 to Len(aREG) - 1
			If aScan(aLstCmpOb2,{|x| AllTrim(Upper(x)) == AllTrim(Upper(aHead[nx][2]))}) > 0 .AND. Empty(aREG[nx])
				lOk := .F.
				aInsere[nx][POS_CPO] := .T.	//Rejeitado por campo obrigatorio
				Exit
			Endif
		Next nx
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSe os dados estiverem consistentes, adicionar o registro e  ณ
		//ณatualizar variaveis de controle.                            ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If lOk
			aInsere[ni][POS_ITEM] := cProxIt
			aInsere[ni][POS_NOVO] := .T.
			aAdd(aCol,aREG)
			cProxIt := Soma1(cProxIt)			
		Endif
	Endif	
Next ni
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTotalizar resultados  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aTotal[1][1] := 0	//Total itens
aTotal[2][1] := 0	//Total itens importados
aTotal[3][1] := 0	//Total itens criados
aTotal[4][1] := 0	//Total itens incorporados
aTotal[5][1] := 0	//Total itens bloqueados
aTotal[6][1] := 0	//Total itens rejeitados por campo obrigatorio ausente
aTotal[7][1] := 0	//Total itens com produtos inexistentes
For ni := 1 to Len(aTotal)
	aTotal[ni][2] := Array(0)
Next ni
For ni := 1 to Len(aInsere)
	aTotal[1][1]++
	aAdd(aTotal[1][2],ni)
	If !Empty(aInsere[ni][POS_ITEM])
		aTotal[2][1]++
		aAdd(aTotal[2][2],ni)
		If aInsere[ni][POS_NOVO]
			aTotal[3][1]++
			aAdd(aTotal[3][2],ni)
		Else
			aTotal[4][1]++
			aAdd(aTotal[4][2],ni)
		Endif
	Else
		If aInsere[ni][POS_BLQ]
			aTotal[5][1]++
			aAdd(aTotal[5][2],ni)
		ElseIf aInsere[ni][POS_PNE]
			aTotal[7][1]++
			aAdd(aTotal[7][2],ni)
		Else
			aTotal[6][1]++
			aAdd(aTotal[6][2],ni)
		Endif
	Endif
Next ni
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMontar mensagem com resultados  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cMens := STR0028 + CRLF //"Resultado do processo de importa็ใo de itens"
cMens += Replicate("-",100) + CRLF
cMens += PadR("-" + Space(nEsp) + STR0029,070) + ":" + AllTrim(cValToChar(aTotal[1][1])) + CRLF //"Total itens"
cMens += PadR("-" + Space(nEsp) + STR0030,070) + ":" + AllTrim(cValToChar(aTotal[2][1])) + CRLF //"Total itens importados"
cMens += PadR("-" + Space(nEsp) + STR0031,070) + ":" + AllTrim(cValToChar(aTotal[3][1])) + CRLF //"Total itens criados"
cMens += PadR("-" + Space(nEsp) + STR0032,070) + ":" + AllTrim(cValToChar(aTotal[4][1])) + CRLF //"Total itens incorporados"
cMens += PadR("-" + Space(nEsp) + STR0033,070) + ":" + AllTrim(cValToChar(aTotal[5][1])) + CRLF //"Total itens bloqueados"
cMens += PadR("-" + Space(nEsp) + STR0034,070) + ":" + AllTrim(cValToChar(aTotal[7][1])) + CRLF //"Total itens com c๓digo de produto inexistente"
cMens += PadR("-" + Space(nEsp) + STR0035,070) + ":" + AllTrim(cValToChar(aTotal[6][1])) + CRLF //"Total itens rejeitados por campo obrigatorio ausente"
cMens += Replicate("-",100) + CRLF
cMens += STR0036 + CRLF //"Detalhamento"
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณItens criados  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cMens += "-" + Space(nEsp) + STR0037 + CRLF //"Itens criados"
If Len(aTotal[3][2]) > 0
	aEval(aTotal[3][2],{|x| cMens += "-" + Space(nEsp) + "[" + aInsere[x][POS_ITEM] + "] " + aInsere[x][POS_COD] + " " + aInsere[x][POS_DESC] + CRLF})
Else
	cMens += "-" + Space(nEsp) + STR0038 + CRLF //"Nenhum item"
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณItens incorporados  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cMens += CRLF
cMens += "-" + Space(nEsp) + STR0039 + CRLF //"Itens incorporados"
If Len(aTotal[4][2]) > 0
	aEval(aTotal[4][2],{|x| cMens += "-" + Space(nEsp) + "[" + aInsere[x][POS_ITEM] + "] " + aInsere[x][POS_COD] + " " + aInsere[x][POS_DESC] + CRLF})
Else
	cMens += "-" + Space(nEsp) + STR0038 + CRLF //"Nenhum item"
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณItens bloqueados  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cMens += CRLF
cMens += "-" + Space(nEsp) + STR0040 + CRLF //"Itens bloqueados"
If Len(aTotal[5][2]) > 0
	aEval(aTotal[5][2],{|x| cMens += "-" + Space(nEsp) + aInsere[x][POS_COD] + " " + aInsere[x][POS_DESC] + CRLF})
Else
	cMens += "-" + Space(nEsp) + STR0038 + CRLF //"Nenhum item"
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณItens com codigo de produto inexistente  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cMens += CRLF
cMens += "-" + Space(nEsp) + STR0041 + CRLF //"Itens com c๓digo de produto inexistente"
If Len(aTotal[7][2]) > 0
	aEval(aTotal[7][2],{|x| cMens += "-" + Space(nEsp) + aInsere[x][POS_COD] + " " + aInsere[x][POS_DESC] + CRLF})
Else
	cMens += "-" + Space(nEsp) + STR0038 + CRLF //"Nenhum item"
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณItens rejeitados por campo obrigat๓rio ausente  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cMens += CRLF
cMens += "-" + Space(nEsp) + STR0042 + CRLF //"Itens rejeitados por campo obrigat๓rio ausente"
If Len(aTotal[6][2]) > 0
	aEval(aTotal[6][2],{|x| cMens += "-" + Space(nEsp) + aInsere[x][POS_COD] + " " + aInsere[x][POS_DESC] + CRLF})
Else
	cMens += "-" + Space(nEsp) + STR0038 + CRLF //"Nenhum item"
Endif
cMens += CRLF
If !Empty(aTotal[2])
	oGD:aCols := aCol
	oGD:Refresh()
Endif
//Resultado do processamento
LjExibeTexto(STR0043,Upper(cMens),.T.,50,80) //"Processamento de importa็ใo"

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณLj843RetColบAutor  ณVendas Cliente       บ Data ณ12/03/11         บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para retornar posicao de campo ou o seu valor dentro do    บฑฑ
ฑฑบ          ณseu cabecalho ou lista de dados correspondente.                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[N] : Opcao 1. Posicao cabecalho 2. Dados                    บฑฑ
ฑฑบ          ณExp02[C] : Campo alvo                                             บฑฑ
ฑฑบ          ณExp03[N] : Posicao do X3_CAMPO no array de cabecalho              บฑฑ
ฑฑบ          ณExp04[N] : Posicao da linha na lista (GD)                         บฑฑ
ฑฑบ          ณExp05[A] : Array de cabecalho                                     บฑฑ
ฑฑบ          ณExp06[A] : Array de dados da lista (GD)                           บฑฑ
ฑฑบ          ณExp07[L] : Array de dados utiliza legenda na primeira coluna?     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA845                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Lj843RetCol(nOpc ,cTarget,nPosN,nPosL,;
							aHead,aDados ,lLegen)

Local uRet				:= ""
Local nPos				:= 0
Local nDesloca			:= 0

Default nOpc			:= 1
Default nPosN			:= 2
Default lLegen			:= .T.
Default cTarget			:= ""
Default nPosL           := 0
Default aHead           := {}
Default aDados          := {}

Do Case
	Case nOpc == 1
		uRet := 0
	Otherwise
		uRet := ""
EndCase
If ValType(aHead) # "A" .OR. Len(aHead) == 0 .OR. ValType(aDados) # "A" .OR. Empty(cTarget) .OR. Empty(nPosL)
	Return uRet
Else
	//Se a opcao for de retorno e os dados nao forem informados, sair
	If nOpc == 2 .AND. Len(aDados) == 0
		Return uRet
	Endif
Endif
If lLegen
	nDesloca := 1
Endif
Do Case
	Case nOpc == 1
		If nPosN == 0
			uRet := aScan(aHead,{|x| Upper(AllTrim(x)) == Upper(AllTrim(cTarget))})
		Else
			uRet := aScan(aHead,{|x| Upper(AllTrim(x[nPosN])) == Upper(AllTrim(cTarget))})
		Endif
	Case nOpc == 2
		If nPosN == 0
			nPos := aScan(aHead,{|x| Upper(AllTrim(x)) == Upper(AllTrim(cTarget))})
		Else
			nPos := aScan(aHead,{|x| Upper(AllTrim(x[nPosN])) == Upper(AllTrim(cTarget))})
		Endif
		If nPos > 0
			If (uRet := aDados[nPosL][nPos + nDesloca]) == Nil
				uRet := ""
			Endif
		Endif
EndCase

Return uRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณMyLoja843  บAutor  ณVendas Cliente       บ Data ณ14/03/11         บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para execucao de teste da rotina automatica do LOJA843     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA845                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function MyLoja843()

Local aDados01			:= {}
Local aDados02			:= {}
Local aDados03			:= {}
Local aDados04			:= {}
Local aCodCli			:= GetAdvfVal("SA1",{"A1_COD","A1_LOJA"},xFilial("SA1"),1)
Local cCodCont			:= GetAdvfVal("SU5","U5_CODCONT",xFilial("SU5"),1)
Local aCodEve			:= GetAdvfVal("ME3",{"ME3_CODIGO","ME3_PBONUS"},xFilial("ME3"),1)
Local cCodLst			:= GetSXENum("ME1","ME1_CODIGO",,1)
Local aCodProd			:= GetAdvfVal("SB1",{"B1_COD","B1_DESC","B1_UM"},xFilial("SB1"),1)
Local cCodAtor			:= GetAdvfVal("ME5","ME5_CODIGO",xFilial("ME5"),1)

Private lMsErroAuto := .F.

If Len(aCodCli) == 0 .OR. Empty(cCodCont) .OR. Len(aCodEve) == 0 .OR. Empty(cCodLst) .OR. Len(aCodProd) == 0 .OR. Empty(cCodAtor)
	Alert(STR0044) //"Ausencia de informa็๕es de cadastro impedem a execu็ใo do teste de rotina automatica!"
	Return Nil
Endif
aDados01 := {{"ME1_FILIAL","  ",Nil},;
				{"ME1_CODIGO",cCodLst,Nil},;
				{"ME1_NOME","TESTE",Nil},;
				{"ME1_CODCLI",aCodCli[1],Nil},;
				{"ME1_LOJCLI",aCodCli[2],Nil},;
				{"ME1_EMISSA",Date(),Nil},;
				{"ME1_TPEVEN",aCodEve[1],Nil},;
				{"ME1_DTEVEN",Date(),Nil},;
				{"ME1_DTDISP",Date(),Nil},;
				{"ME1_TIPO","1",Nil},;
				{"ME1_LOCAL","SALAO DE FESTAS",Nil},;
				{"ME1_CONTAT",cCodCont,Nil},;
				{"ME1_ORIGEM","1",Nil},;
				{"ME1_STATUS","1",Nil},;
				{"ME1_DTREV",Date(),Nil},;
				{"ME1_PBONUS",aCodEve[2],Nil},;
				{"ME1_ALERTA","1",Nil},;
				{"ME1_INSITE","2",Nil},;
				{"ME1_EXTRA","1",Nil},;
				{"ME1_DTVAL",Date() + 30,Nil},;
				{"ME1_FILORI",FWGETCODFILIAL,Nil},;
				{"ME1_MENSAG","TESTE DE MENSAGEM LOJA843",Nil}}

aDados02 := {{{"ME2_FILIAL","  ",Nil},;
				{"ME2_CODIGO",cCodLst,Nil},;
				{"ME2_ITEM","001",Nil},;
				{"ME2_PRODUT",aCodProd[1],Nil},;
				{"ME2_DESCRI",aCodProd[2],Nil},;
				{"ME2_UM",aCodProd[3],Nil},;
				{"ME2_QTDSOL",1,Nil},;
				{"ME2_STATUS","A",Nil},;
				{"ME2_QTDATE",0,Nil},;
				{"ME2_ORIGEM","O",Nil},;
				{"ME2_VALUNI",150,Nil},;
				{"ME2_SUGEST","2",Nil},;
				{"ME2_FONTE","1",Nil},;
				{"ME2_FILORI",FWGETCODFILIAL,Nil}}}

aDados03 := {{{"MEE_FILIAL","  ",Nil},;
				{"MEE_CODLIS",cCodLst,Nil},;
				{"MEE_CODATO","05",Nil},;
				{"MEE_NOME","JOHNNY TESTE",Nil},;
				{"MEE_EMAIL","teste@teste.com.br",Nil}}}

aDados04 := {}

MsExecAuto({|v,x,w,y,z| Loja843(v,x,w,y,z)},INCLUIR,aDados01,aDados02,aDados03,aDados04)
//Loja843(ALTERAR,aDados01,aDados02,aDados03,aDados04,,"000003")
If lMsErroAuto
	MostraErro()
Else
	Alert("OK")
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณLj843EncLsบAutor  ณVendas Cliente        บ Data ณ15/03/11         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para encerrar a lista de presentes                         บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA843                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Lj843EncLs()

Local lRet				:= .F.
Local cNumLst			:= M->ME1_CODIGO   
Local lPELj843Enc		:= ExistBlock("LJ843ENC")



If Empty(cNumLst)
	Return lRet
Endif
cNumLst := PadR(cNumLst,TamSX3("ME1_CODIGO")[1])  


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPonto de entrada pre-encerramentoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
  
If lPELj843Enc
   	lRet :=	ExecBlock("LJ843ENC",.F.,.F.,{FWGETCODFILIAL,cNumLst})
	lRet := ValType(lRet) == "L" .and. lRet	  
	If !lRet
		Return lRet
	EndIf
Endif

DbSelectArea("ME1")
If ME1->(DbSeek(xFilial("ME1") + cNumLst))
	RecLock("ME1",.F.)
	ME1->ME1_STATUS := "2"
	ME1->(MsUnlock())
	ME1->(DbCommit())
	lRet := !lRet
	MsgAlert(STR0050)    //// "A lista foi encerrrada com sucesso!"
Endif

 

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณLj843RtSYPบAutor  ณVendas Cliente        บ Data ณ15/02/11         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para pesquisar e retornar conteudos na SYP. Funcionalidade บฑฑ
ฑฑบ          ณcriada por conta de falhas de recuperacao de dados da MSMM.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[C] : Codigo da mensagem (YP_CHAVE)                          บฑฑ
ฑฑบ          ณExp02[C] : Nome do campo codigo da mensagem                       บฑฑ
ฑฑบ          ณExp03[C] : Tamanho maximo a ser retornado                         บฑฑ
ฑฑบ          ณExp04[L] : Retornar apenas se existe um determinado codigo        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA843                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Lj843RtSYP(cCodMens,cCampo,nTamMax,lExiste)

Local aArea				:= GetArea()
Local uRet				:= ""
Local cAlias			:= GetNextAlias()
Local cQry				:= ""
Local cAliasAt			:= Alias()

Default cCodMens		:= ""
Default cCampo			:= ""
Default nTamMax		:= 0 
Default lExiste		:= .F.

If !lExiste
	uRet := ""
Else
	uRet := .F.
Endif
If Empty(cCodMens)
	Return uRet
Endif
#IFNDEF TOP
	Return uRet
#ENDIF
cQry := "SELECT DISTINCT SYP.YP_SEQ, SYP.YP_TEXTO "
cQry += "FROM " + RetSQLName("SYP") + " SYP "
cQry += "WHERE " + RetSQLDel("SYP") + " AND SYP.YP_FILIAL = '" + xFilial("SYP") + "' "
cQry += "AND SYP.YP_CHAVE = '" + PadR(cCodMens,TamSX3("YP_CHAVE")[1]) + "' "
If !Empty(cCampo)
	cQry += "AND SYP.YP_CAMPO = '" + cCampo + "' "
Endif
cQry += "ORDER BY SYP.YP_SEQ ASC"
DbUseArea(.T.,__cRDD,TcGenQry(,,ChangeQuery(cQry)),cAlias,.T.,.F.)
(cAlias)->(DbGoTop())
If (cAlias)->(Eof())
	FechaArqT(cAlias)
	RestArea(aArea)
	If !Empty(cAliasAt)
		DbSelectArea(cAliasAt)
	Endif
	Return uRet
Endif
If !lExiste
	Do While !(cAlias)->(Eof())
		uRet += RTrim((cAlias)->(FieldGet(FieldPos("YP_TEXTO"))))
		(cAlias)->(DbSkip())
	EndDo
	If !Empty(nTamMax)
		uRet := Substr(uRet,1,nTamMax)
	Endif	
Else
	uRet := .T.
Endif
FechaArqT(cAlias)
RestArea(aArea)
If !Empty(cAliasAt)
	DbSelectArea(cAliasAt)
Endif

Return uRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณLj843GrvMvบAutor  ณVendas Cliente        บ Data ณ18/03/11         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para gravar movimento de credito a partir da LjGrvBatch    บฑฑ
ฑฑบ          ณe retorna qual o tipo de operacao deve ser executada pelo mesmo.  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[C] : Numero do orcamento                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณnRet[N]  : Opcao [0] Nenhum item de lista                         บฑฑ
ฑฑบ          ณ           Opcao [1] Processar Lj7Pedido                          บฑฑ
ฑฑบ          ณ           Opcao [2] Processar LjGvrTudo                          บฑฑ
ฑฑบ          ณ           Opcao [3] Processar LjGrvFin                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA843                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Lj843GrvMv(cNumOrc,cDocPed,cSeriePed)

Local nRet				:= 0												//Retorno
Local aArea				:= Lj7GetArea({"SL1","SL2","ME1","ME2","MED"})	//Area de trabalho
Local aLstPres 			:= {}												//Array de itens contidos na lista de presentes
Local aLstItLP 			:= {}												//Array de todos os itens do orcamento
Local ni				:= 0												//Contador
Local aTMP				:= {}												//Array temporario
Local nPos				:= 0												//Posicionador
Local nPos02			:= 0												//Posicionador 02
Local lGrvNovo			:= .F.												//Indicador de gravacao de novo registro na ME2
Local aSB1				:= {}												//Variavel para resultado de pesquisa na SB1
Local nOpc				:= 0												//Variavel de controle de fluxo
Local lLstPres			:= .F.												//Existe algum item associado a lista de presentes?
Local aLstMens			:= {}												//Lista de mensagens a gravar
Local aLstMProc			:= {}												//Lista de mensagens processadas
Local cAliasT			:= GetNextAlias()									//Alias para consulta
Local cQry				:= ""												//Query
Local lGrvMov			:= .T.												//Gravar movimento?
Local nTamDesc			:= TamSX3("B1_DESC")[1]
Local nTamUM			:= TamSX3("B1_UM")[1]
Local lFDtEnt			:= SL2->(FieldPos("L2_FDTENTR")) > 0 				//Data de Entrega
Local lFDtMont			:= SL2->(FieldPos("L2_FDTMONT")) > 0 				//Data de Montagem
Local lCodCont			:= SL2->(FieldPos("L2_CODCONT")) > 0 				//Contato da Entrega
Local aEntregas			:= {} 												//array de entregas programadas
Local cErro				:= "" 												//Erro na valida็ใo entrega/montagem
Local lL2PEDRES			:= SL2->(ColumnPos("L2_PEDRES")) > 0 				//Pedido de venda
Local lL2ITESC6			:= SL2->(ColumnPos("L2_ITESC6")) > 0 				//Numero do item no pedido de venda	
Local aDocSerie 		:= {}												//Array que recebe Documento e Serie para ser gravado na tabela ME4					   

Default cNumOrc 		:= ""                
Default cDocPed			:= ""
Default cSeriePed		:= ""

If Empty(cNumOrc) .OR. SL2->(FieldPos("L2_CODLPRE")) == 0 .OR. SL2->(FieldPos("L2_ITLPRE")) == 0 .AND. !AliasInDic("ME1")
	Return nRet
Endif
cNumOrc := PadR(cNumOrc,TamSX3("L1_NUM")[1])
//Se o registro nao estiver posicionado, realizar nova pesquisa
If Select("SL1") == 0 .OR. SL1->(L1_FILIAL + L1_NUM) # (xFilial("SL1") + cNumOrc)
	DbSelectArea("SL1")
	SL1->(DbSetOrder(1))
	If !SL1->(DbSeek(xFilial("SL2") + cNumOrc))
		Lj7RestArea(aArea)
		Return nRet
	Endif	
Endif

aDocSerie := Lj8AjuDoc()

If len(aDocSerie) == 2 
	cDocPed			:= aDocSerie[1]
	cSeriePed		:= aDocSerie[2]
EndIf 

//Pesquisar itens do orcamento
DbSelectArea("SL2")
SL2->(DbSetOrder(1))
SL2->(DbSeek(xFilial("SL2") + cNumOrc))
If !SL2->(Found())
	Lj7RestArea(aArea)
	Return nRet
Endif
nPos := 0
Do While !SL2->(Eof()) .AND. SL2->(L2_FILIAL + L2_NUM) == xFilial("SL2") + SL1->L1_NUM
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVarrer itens do orcamento para levantamento de itens de  ณ
	//ณlista de presentes e seus dados.                         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aAdd(aLstItLP,Array(7))	//[1] Item [2] Pedido [3] Fatura [4] Financeiro [5] Item lista presente? [6] Entrega Programada
	nPos := Len(aLstItLP)
	aLstItLP[nPos][1] := SL2->L2_ITEM
	aLstItLP[nPos][2] := .F.
	aLstItLP[nPos][3] := .F.
	aLstItLP[nPos][4] := .F.
	aLstItLP[nPos][5] := .F.
	aLstItLP[nPos][6] := .F. //Entrega programada
	//Verificar se existem listas de presentes associados
	If !Empty(SL2->L2_CODLPRE)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณModo de entrega por tipo de lista de presente            ณ
		//ณ=========================================================ณ
		//ณCREDITO                                                  ณ
		//ณ[2] Retira - Documento fiscal, processar LjGrvTudo       ณ
		//ณ[3] Credito - Documento nao fiscal, emitir apenas titulosณ
		//ณ                                                         ณ
		//ณENTREGA E ENTREGA PROGRAMADA                             ณ
		//ณ[2] Retira - Documento fiscal, processar LjGrvTudo       ณ
		//ณ[3] Entrega - Documento nao fiscal, processar Lj7Pedido  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aAdd(aLstPres,Array(18))
		nPos02 := Len(aLstPres)
		aLstPres[nPos02][1] 	:= SL2->L2_ITEM											//Item do orcamento
		aLstPres[nPos02][2] 	:= PadR(SL2->L2_CODLPRE,TamSX3("ME1_CODIGO")[1])		//Codigo da lista
		aLstPres[nPos02][3] 	:= PadR(SL2->L2_ITLPRE,TamSX3("ME2_ITEM")[1])	   		//Item da lista
		aLstPres[nPos02][4] 	:= SL2->L2_MSMLPRE										//Mensagem
		aLstPres[nPos02][5] 	:= SL2->L2_REMLPRE										//Remetentes (presenteadores)
		aLstPres[nPos02][6] 	:= SL2->L2_RESERVA										//Reserva
		aLstPres[nPos02][7] 	:= SL2->L2_ENTREGA										//Modo de entrega
		aLstPres[nPos02][8] 	:= Space(TamSX3("ME1_TIPO")[1])							//Tipo da lista
		aLstPres[nPos02][9] 	:= Space(TamSX3("ME1_EXTRA")[1])						//Aceitas quantidade e itens extras?
		aLstPres[nPos02][10]	:= SL2->L2_PRODUTO										//Codigo do produto
		aLstPres[nPos02][11]	:= SL2->L2_QUANT											//Quantidade
		aLstPres[nPos02][12]	:= SL2->L2_VEND											//Vendedor
		aLstPres[nPos02][13]	:= SL2->L2_VLRITEM										//Valor total do item
		aLstPres[nPos02][14]	:= Ctod("")												//Data da Entrega
		aLstPres[nPos02][15]	:= ""														//Contato
		aLstPres[nPos02][16]	:= Iif(!Empty(SL2->L2_DOC),"1","2")					//1=Cupom fiscal/2=Nao fiscal
		aLstPres[nPos02][17]	:= iIf(lL2PEDRES,SL2->L2_PEDRES,"")					//Numero do pedido de venda
		aLstPres[nPos02][18]	:= iIf(lL2ITESC6,SL2->L2_ITESC6,"")					//Numero do item no pedido de venda
	Endif
	SL2->(DbSkip())
EndDo
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe houverem itens, classificar acao posterior e gravar  ณ
//ณmovimentos.                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(aLstPres) > 0
	DbSelectArea("ME1")
	ME1->(DbSetOrder(2))	//ME1_FILIAL+ME1_CODIGO+ME1_TIPO+ME1_CODCLI+ME1_LOJCLI
	DbSelectArea("ME2")
	ME2->(DbSetOrder(1))	//ME2_FILIAL+ME2_CODIGO+ME2_ITEM
	
	MEH->(DbSetOrder(1)) //MEH_FILIAL+MEH_CODLIS+MEH_SEQ+DTOS(MEH_PRAZO)  
	
	                                                                                                                 
	Begin Transaction
	For ni := 1 to Len(aLstPres)
		//Determinar a posicao do item da lista de presente em relacao ao item do orcamento
		nPos := aScan(aLstItLP,{|x| AllTrim(x[1]) == AllTrim(aLstPres[ni][1])})
		//Pesquisar a existencia da lista de presentes
		If ME1->(DbSeek(xFilial("ME1") + aLstPres[ni][2]))
			//Atualizar item como integrante da lista de presente
			aLstItLP[nPos][5] := .T.
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAntes de gravar a transacao, validar se jah nao existe um ณ
			//ณmovimento de credito jah realizado com este orcamento     ณ
			//ณe/ou item, para evitar movimentos duplicados.             ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			cQry := "SELECT 1 "
			cQry += "FROM " + RetSQLName("ME4") + " ME4 "
			cQry += "WHERE " + RetSQLDel("ME4") + " AND ME4.ME4_FILIAL = '" + xFilial("ME4") + "' "
			cQry += "AND ME4.ME4_CODIGO = '" + aLstPres[ni][2] + "' " + IIF(!Empty(aLstPres[ni][3]), " AND ME4.ME4_ITLST = '" + aLstPres[ni][3] + "' ", "")
			cQry += "AND ME4.ME4_NUMORC = '" + cNumOrc + "' AND ME4.ME4_ITORC = '" + aLstPres[ni][1] + "' "
			cQry += "AND  ( ME4.ME4_TIPREG = '1' AND ME4.ME4_TIPO = '1' )  "//Cr้dito na venda

			DbUseArea(.T.,__cRDD,TcGenQry(,,ChangeQuery(cQry)),cAliasT,.T.,.F.)
			(cAliasT)->(DbGoTop())
			If !(cAliasT)->(Eof())
				lGrvMov := .F.
			Else
				lGrvMov := .T.
			Endif
			FechaArqT(cAliasT)
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณDefinir a tipo da lista e o status do item para acao posterior  ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			aLstPres[ni][8] := ME1->ME1_TIPO
			Do Case
				//CREDITO
				Case AllTrim(ME1->ME1_TIPO) == "1"	 //CREDITO	
					If aLstPres[ni][7] == "2" //1=Retira Posterior; 2= Retira; 3=Entrega
						//Colocar o item como fatura
						aLstItLP[nPos][3] := .T.
					Else
						//Colocar o item como financeiro
						aLstItLP[nPos][4] := .T.
					Endif
				//ENTREGA E ENTREGA PROGRAMADA
				Otherwise //2-ENTREGA / 3-ENTREGA PROGRAMADA / 4-CREDITO
					//1=Retira Posterior; 2= Retira; 3=Entrega
					If aLstPres[ni][7] == "2" .or. aLstPres[ni][7] == "" //Vazio ou "2"(Retira)
						//Colocar o item como fatura
						aLstItLP[nPos][3] := .T.
					Else
						//Colocar o item como pedido
						aLstItLP[nPos][2] := .T.
						aLstItLP[nPos][6] := ME1->ME1_TIPO == "3" .AND. lFDtEnt .AND. lGrvMov  //Entrega programada
						If lCodCont
							aLstPres[ni][15] := ME1->ME1_CONTAT
						EndIf
						If lFDtEnt
							aLstPres[ni][14] :=  Lj7PegaEntrega(aLstPres[ni][10])
						EndIf
					Endif
			EndCase
		
			//Lista com entrega
			If aLstItLP[nPos][6]
				If (nPos02 := aScan(aEntregas, { |l| l[1] == aLstPres[ni][2] })) = 0
					aAdd(aEntregas, Array(8))
					nPos02 := Len(aEntregas)
					aEntregas[nPos02, 01] := aLstPres[ni][2] //Codigo da Lista
					aEntregas[nPos02, 02] := Ctod("") //Data da Entrega
					aEntregas[nPos02, 03] := ME1->ME1_CONTAT //Contato
					aEntregas[nPos02, 04] := 0 //Valor Minimo do Item para entrega
					aEntregas[nPos02, 05] := 0 //Quantidade Mํnima de Entrega
					aEntregas[nPos02, 06] := 0 //Valor total dos Itens
					aEntregas[nPos02, 07] := 0 //Quantidade Total dos Itens
					aEntregas[nPos02, 08] := {} //Array dos Itens
					//Localiza o Prazo de entrega aproximado da Data Base
					
					MEH->(DbSeek(xFilial("ME1") + aLstPres[ni][2])) //MEH_FILIAL+MEH_CODLIS+MEH_SEQ+DTOS(MEH_PRAZO)
					Do While MEH->(!Eof() .AND. MEH_FILIAL+MEH_CODLIS == xFilial("ME1") + aLstPres[ni][2]) .AND. Empty(aEntregas[nPos02, 02])
						If MEH->MEH_PRAZO > dDataBase
							aEntregas[nPos02, 02] := MEH->MEH_PRAZO
							aEntregas[nPos02, 05] := MEH->MEH_QTDMIN //Valor Minimo do Item para entrega
							aEntregas[nPos02, 04] := MEH->MEH_VALMIN //Quantidade Mํnima de Entrega
						EndIf
						MEH->(DbSkip(1))
					EndDo	
					//Se nใo localizar a Data de Entrega da lista, retorna a padrใo
					If Empty(aEntregas[nPos02, 02])
						aEntregas[nPos02, 02] := aLstPres[ni][14]
					EndIf
				EndIf				
				aEntregas[nPos02, 06] +=  aLstPres[ni][13] //Valor total dos Itens
				aEntregas[nPos02, 07] +=  aLstPres[ni][11] //Quantidade Total dos Itens			
				aAdd(aEntregas[nPos02, 08], aLstPres[ni][01]) //Item de Or็amento					
			EndIf
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณCaso exista, remover o flag no campo L2_RESERVA, que           ณ
			//ณnao sera mais utilizado para validar a execucaco do Lj7Pedido  ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If SL2->(DbSeek(xFilial("SL2") + cNumOrc + aLstPres[ni][1])) .AND. lGrvMov
				RecLock("SL2",.F.)
				SL2->L2_RESERVA := Space(TamSX3("L2_RESERVA")[1])
				//Atualiza os Dados do Contato e Endere็o de Entrega
				If aLstItLP[nPos][2]  //Pedido (Entrega)
					If lCodCont
						SL2->L2_CODCONT := aLstPres[ni][15]
					EndIf
					If lFDtEnt .AND. Empty(SL2->L2_FDTENTR) .AND. ;
						( !lFDtMont .or. (Lj7ValEntMon( aLstPres[nI][14], SL2->L2_FDTMONT, @cErro )) )  //Data de Entrega padrใo
						SL2->L2_FDTENTR := aLstPres[nI][14]
					EndIf
				EndIf
				
				SL2->(MsUnlock())
			Endif
			If lGrvMov
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณDeterminar modo de gravacao  ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				lGrvNovo := .F.
				If Empty(aLstPres[ni][3])
					//Se o item estiver vazio caracteriza novo item
					lGrvNovo := .T.
				Else
					//Buscar item
					If ME2->(DbSeek(xFilial("ME2") + ME1->ME1_CODIGO + aLstPres[ni][3]))
						If AllTrim(ME2->ME2_STATUS) == "E" .OR. (ME2->ME2_QTDSOL - (ME2->ME2_QTDATE + aLstPres[ni][11])) < 0 .OR. ;
							ME2->ME2_ORIGEM == "C"
							
							//Item esgotado ou de origem de comprador, incluir novo item
							lGrvNovo := .T.
						Endif
					Else
						//Se o item nao foi encontrado
						lGrvNovo := .T.
					Endif
				Endif
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณGravacao do item  ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู								
				If lGrvNovo
					//Buscar dados do produto
					aSB1 := GetAdvfVal("SB1",{"B1_DESC","B1_UM"},xFilial("SB1") + aLstPres[ni][10],1)
					//Item de COMPRADOR
					RecLock("ME2",.T.)
					ME2->ME2_FILIAL		:= xFilial("ME2")
					ME2->ME2_CODIGO		:= aLstPres[ni][2]
					ME2->ME2_ITEM		:= Lj843PrIt(ME2->ME2_FILIAL,aLstPres[ni][2])
					ME2->ME2_PRODUT		:= aLstPres[ni][10]
					ME2->ME2_DESCRI		:= PadR(aSB1[1],nTamDesc)
					ME2->ME2_UM			:= PadR(aSB1[2],nTamUM)
					ME2->ME2_QTDSOL		:= aLstPres[ni][11]
					ME2->ME2_STATUS		:= "E"	//Esgotado
					ME2->ME2_QTDATE		:= aLstPres[ni][11]
					ME2->ME2_ORIGEM		:= "C"	//Comprador
					ME2->ME2_VALUNI		:= Lj843PrcV(aLstPres[ni][10])
					ME2->ME2_SUGEST		:= "2"
					ME2->ME2_FONTE		:= "1"
					ME2->ME2_VEND		:= aLstPres[ni][12]
					ME2->ME2_FILORI		:= FWGETCODFILIAL
					ME2->(MsUnlock())
					
					//Atualiza o SL2 - item de lista
					If SL2->(DbSeek(xFilial("SL2") + cNumOrc + aLstPres[ni][1]))
						RecLock("SL2",.F.)
						SL2->L2_ITLPRE := ME2->ME2_ITEM					
						SL2->(MsUnlock())
					Endif
				
				Else
					//Item ORIGINAL - Alteracao de saldo
					RecLock("ME2",.F.)
					ME2->ME2_QTDATE		+= aLstPres[ni][11]
					If ME2->ME2_QTDATE >= ME2->ME2_QTDSOL
						ME2->ME2_STATUS		:= "E"	//Esgotado
					Else
						ME2->ME2_STATUS		:= "P"	//Parcial
					Endif
					ME2->(MsUnlock())									
				Endif
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณGravacao de movimentacao de saldo - ME4  ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				aTMP := {ME2->ME2_CODIGO,;										//CODIGO DA LISTA
							ME2->ME2_ITEM,;										//ITEM DA LISTA
							aLstPres[ni][10],;									//CODIGO DO PRODUTO
							aLstPres[ni][11],;									//QUANTIDADE DO MOVIMENTO
							aLstPres[ni][13],;									//VALOR TOTAL DO ITEM
							cEmpAnt,;												//EMPRESA ORIGINAL
							cFilAnt,;												//FILIAL ORIGINAL
							SL1->L1_NUM,;											//ORCAMENTO
							aLstPres[ni][1],;										//ITEM DO ORCAMENTO
							aLstPres[ni][17],;									//PEDIDO
							aLstPres[ni][18],;									//ITEM DO PEDIDO
							cDocPed,;												//DOCUMENTO
							cSeriePed,;												//SERIE
							Date(),;												//EMISSAO
							,;														//PREFIXO
							,;														//NUM. TITULO
							,;														//PARCELA
							,;														//TIPO TITULO
							SL1->L1_CLIENTE,;										//CLIENTE
							SL1->L1_LOJA}											//LOJA
				//Determinar a OPCAO de operacao do componente de movimentacao de saldo
				If aLstItLP[nPos][2] //Se .T. o item na venda foi entrega (pedido)

					If aLstPres[nI][16] == "1" //1=Cupom fiscal (Retira)/2=Nao fiscal(Credito)
						//PEDIDO - Credito e Debito

						If SuperGetMv("MV_LJLPGBR",,.F.) //Considera a porcentagem do b๔nus mesmo o item sendo Retira
							nOpc := 8 //Credito(usado) - Debito - bonus
						Else
							nOpc := 7 //Credito Debito
						EndIf
					Else
						//PEDIDO - Credito, Debito e Bonus
						nOpc := 1

					EndIf

				ElseIf aLstItLP[nPos][3] //Tipo do item na venda: .T.=Retira / .F.=Entrega

					//FATURA - Credito, Debito
					If AllTrim(aLstPres[nI][8]) $ "1/2/4" //Tipo da lista: 1=Credito; 2=Entrega; 3=Entrega Programada;4=Retira

						If aLstPres[nI][16] == "1" //1=Cupom fiscal (Retira)/2=Nao fiscal(Credito)

							If SuperGetMv("MV_LJLPGBR",,.F.)
								nOpc := 8 //Credito(usado) - Debito - bonus
							Else
								nOpc := 7 //Credito Debito
							EndIf

						Else //Selecionado credito na lista de credito

							nOpc := 5 //Somente Credito
						EndIf

					Else

						//FATURA - Credito, Debito e Bonus
						nOpc := 1
					EndIf
				Else
					//FINANCEIRO - Credito e Bonus
					nOpc := 2
				Endif
				Lj8GeraCC(aTMP,nOpc,.F.,.F.,.F.)
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณGeracao da mensagem na SYP  ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If !Empty(aLstPres[ni][4])
					//Verificar se o codigo utilizado jah eh uma mensagem gravada na SYP
					If !Lj843RtSYP(aLstPres[ni][4],,,.T.)
						//Caso nao exista, pesquisar a lista de mensagens pre-definidas, gravar a mensagem no SYP e associar o codigo ao SL2
						DbSelectArea("MED")
						MED->(DbSetOrder(1))
						If MED->(DbSeek(xFilial("MED") + RTrim(aLstPres[ni][4])))
							If !Empty(MED->MED_DESCRI)
								//Posicionar no registro da SL2 que sera alterada
								If SL2->(DbSeek(xFilial("SL2") + cNumOrc + aLstPres[ni][1]))
									RecLock("SL2",.F.)
									SL2->L2_MSMLPRE := ""
									SL2->(MsUnlock())
									//Se o codigo utilizado ainda nao foi armazenado
									If aScan(aLstMProc,{|x| x == RTrim(aLstPres[ni][4])}) == 0
										//Alimentar a tabela de gravacao de mensagens
										aAdd(aLstMens,{"SL2","L2_MSMLPRE",MED->MED_DESCRI,SL2->(Recno())})
										//Alimentar o vetor de controle de mensagens jah processadas
										aAdd(aLstMProc,RTrim(aLstPres[ni][4]))
									Endif
								Endif
							Endif
						Else
							//Posicionar no registro da SL2 que sera alterada
							If SL2->(DbSeek(xFilial("SL2") + cNumOrc + aLstPres[ni][1]))
								RecLock("SL2",.F.)
								SL2->L2_MSMLPRE := ""
								SL2->(MsUnlock())
							Endif										
						Endif
					Endif
				Endif 
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณValidacao do remetente na SYP  ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If !Empty(aLstPres[ni][5])
					//Verificar se o codigo utilizado eh uma mensagem gravada na SYP, caso nao seja, limpar campo
					If !Lj843RtSYP(aLstPres[ni][5],,,.T.)
						//Posicionar no registro da SL2 que sera alterada
						If SL2->(DbSeek(xFilial("SL2") + cNumOrc + aLstPres[ni][1]))
							RecLock("SL2",.F.)
							SL2->L2_REMLPRE := Space(TamSX3("L2_REMLPRE")[1])
							SL2->(MsUnlock())
						Endif
					Endif
				Endif 
				//Envio de mensagens de compra e/ou agradecimento
				If nI == Len(aLstPres)
					LjEnvEmLP(ME1->ME1_CODIGO,SL1->L1_NUM)
				EndIf
			Endif
		Endif
	Next ni
	End Transaction
	//Verificar se existe itens associados a itens de lista de presentes
	aEval(aLstItLP,{|x| IIf(!lLstPres,IIf(x[5],lLstPres := .T.,.T.),.T.)})
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaso exista lista de presentes contida no orcamento definir  ณ
//ณa acao a ser executada.                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lLstPres

	//Atualizar Dados de Entrega Programada
	If lFDtEnt .AND. aScan(aLstItLP,{|x| x[6] == .T. }) > 0
		For nPos02 := 1 to Len(aEntregas)
			
			If (aEntregas[nPos02, 04] <= aEntregas[nPos02, 06])  .OR. ( aEntregas[nPos02, 05] <= aEntregas[nPos02, 07])
				//Localiza o array de Itens e confronta a data de entrega com o item Gravado na etapa acima
				For nI := 1 to Len(aEntregas[nPos02,08])
					nPos := aScan( aLstPres, { | It| It[1] == aEntregas[nPos02, 08][nI] })
					
					If nPos > 0 .AND. aLstPres[nPos, 14] <> aEntregas[nPos02, 02] //Entrega da Lista ้ Diferente da padrใo, entใo atualiza o Item
						If SL2->(DbSeek(xFilial("SL2") + cNumOrc + aEntregas[nPos02, 08][nI] )) 
							RecLock("SL2",.F.)
							SL2->L2_FDTENTR := aEntregas[nPos02, 02]
							If lFDtMont
								SL2->L2_FDTMONT := aEntregas[nPos02, 02]
							EndIf
							SL2->(MsUnlock())
						EndIf
					EndIf
				Next nI
			EndIf
		Next nPos02
	EndIf
	
	//Gravar lista de mensagens
	If Len(aLstMens) > 0
		For ni := 1 to Len(aLstMens)
			//Selecionar e posicionar tabela de destino
			DbSelectArea(aLstMens[ni][1])
			(aLstMens[ni][1])->(DbGoTo(aTail(aLstMens[ni])))
			MSMM((aLstMens[ni][1])->&(aLstMens[ni][2]),,,aLstMens[ni][3],1,,,aLstMens[ni][1],aLstMens[ni][2])
		Next ni
	Endif	
	//Todos os itens sao de lista?
	If aScan(aLstItLP,{|x| x[5] == .F.}) == 0
		//Todos os itens sao de credito?
		If aScan(aLstItLP,{|x| x[4] == .F.}) == 0
			//Todos itens de credito, gerar apenas financeiro
			nRet := 3
		Else
			//Existem itens de credito?
			If aScan(aLstItLP,{|x| x[4] == .T.}) > 0
				//Caso exista itens de credito com outros tipos de itens, processar o Lj7Pedido
				nRet := 1
			Else
				//Existem itens de pedido? (Entrega?)
				If aScan(aLstItLP,{|x| x[2] == .T.}) > 0
					nRet := 1
				Else
					nRet := 2
				Endif
			Endif
		Endif
	Else
		//Se nem todos os itens sao de lista, existe algum item de credito?
		If aScan(aLstItLP,{|x| x[4] == .T.}) == 0
			//Se nao existe nenhum item de credito, verificar se existe item de pedido
			If aScan(aLstItLP,{|x| x[2] == .T.}) == 0
				nRet := 2
			Else
				nRet := 1
			Endif
		Else
			nRet := 1
		Endif
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRespeitando regra estabelecida no LjGrvBatch, caso ณ
	//ณo template de OTICA esteja ativo, nao processar o  ณ
	//ณLj7Pedido.                                         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If nRet == 1 .AND. HasTemplate("OTC")
		//Processar LjGvrTudo
		nRet := 2
	Endif	
Endif
Lj7RestArea(aArea)

Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณLj843ExDifบAutor  ณVendas Cliente        บ Data ณ18/02/11         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para determinar se existe diferenca entre o conteudo de    บฑฑ
ฑฑบ          ณem registro do aCols e o seu par jah existente em uma tabela      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[C] : Nome do alias da tabela posicionada                    บฑฑ
ฑฑบ          ณExp02[A] : Conteudo de um dado registro da aCols                  บฑฑ
ฑฑบ          ณExp03[A] : Array com dados dos campos existentes                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA843                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Lj843ExDif(cAlias,aLinha,aHead)

Local lRet				:= .F.
Local nx				:= 0
Local uValCampo			:= ""

Default cAlias			:= ""
Default aLinha          := {}
Default aHead           := {}

If nOperacao # ALTERAR .OR. Empty(cAlias) .OR. Len(aLinha) == 0 .OR. Len(aHead) == 0
	Return lRet
Endif
DbSelectArea(cAlias)
For nx := 1 To Len(aHead)
	If (cAlias)->(FieldPos(aHead[nx][POS_CMP])) > 0 .AND. aHead[nx][POS_CNT] # "V"
		uValCampo := aLinha[nx]
		If PadR(StrTran(AllToChar(uValCampo)," ",""),250)	 # PadR(StrTran(AllToChar((cAlias)->(FieldGet(FieldPos(aHead[nx][POS_CMP]))))," ",""),250)
			lRet := .T.
			Exit
		Endif
	Endif
Next nx

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณLj843PrIt  บAutor ณVendas Cliente        บ Data ณ18/03/11         บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para retornar o proximo item de uma determinada lista      บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[C] : Filial                                                 บฑฑ
ฑฑบ          ณExp02[A] : Numero da lista                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณcRet[C]  : Proximo item da lista                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Lj843PrIt(cFil,cNumLst)

Local cRet				:= ""
Local aArea				:= GetArea()
Local cQry				:= ""
Local cAliasT			:= GetNextAlias()

Default cFil			:= ""
Default cNumLst		    := ""

cQry := "SELECT DISTINCT ME2.ME2_ITEM "
cQry += "FROM " + RetSQLName("ME2") + " ME2 "
cQry += "WHERE " + RetSQLDel("ME2") + " AND ME2.ME2_FILIAL = '" + cFil + "' AND ME2.ME2_CODIGO = '" + cNumLst + "' "
cQry += "ORDER BY ME2.ME2_ITEM DESC"
DbUseArea(.T.,__cRDD,TcGenQry(,,ChangeQuery(cQry)),cAliasT,.T.,.F.)
(cAliasT)->(DbGoTop())
If !(cAliasT)->(Eof())
	cRet := Soma1((cAliasT)->ME2_ITEM,TamSX3("ME2_ITEM")[1])
Else
	cRet := StrZero(1,TamSX3("ME2_ITEM")[1])
Endif
FechaArqT(cAliasT)
RestArea(aArea)

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef   บAutor  ณVendas Cliente        บ Data ณ18/02/11         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para definicao das rotinas.                                บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA843                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function MenuDef()

Local aRot				:= {}

aAdd(aRot,{STR0045	,"AxPesqui"	,0	,PESQUISAR	,0	,.F.}) //"Pesquisar"
aAdd(aRot,{STR0046	,"Loja843"	,0	,VISUALIZAR	,	,.T.}) //"Visualizar"
aAdd(aRot,{STR0047	,"Loja843"	,0	,INCLUIR	,	,.T.}) //"Incluir"
aAdd(aRot,{STR0048	,"Loja843"	,0	,ALTERAR	,	,.T.}) //"Alterar"
aAdd(aRot,{STR0049	,"Loja843"	,0	,EXCLUIR	,	,.T.}) //"Excluir"

Return aRot

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณLj843UsSL  บAutor ณVendas Cliente        บ Data ณ18/07/11         บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para retornar se o usuario pode criar ou alterar Sugestao  บฑฑ
ฑฑบ          ณde Lista                                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNao tem                                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณlRet[L]  : .T.=Pode manipular Sugestao de Lista                   บฑฑ
ฑฑบ          ณ           .F.=Nao pode manipular Sugestao de Lista               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                                              
Function Lj843UsSL ()

Local lRet       := .T.										 // Variavel utilizada para armazenar o retorno da funcao
Local cGruSugLst := SuperGetMV("MV_LJGRSLS", , "000000")	    // Guarda o grupo que tem permissao de para criacao de sug. de lista 
Local aArrGrp    := {}										   // Array para conter os grupos do usuario consultado

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณObter os grupos em que o usuario logado pertenceณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aArrGrp := FWSFUsrGrps(cGruSugLst)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerificar se o usuario pertence ao grupo cadastrado no grupo do parametro MV_LJUSSUGLณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If aScan(aArrGrp, {|x| x == cGruSugLst}) == 0
	lRet := .F.
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณLj843DlSL  บAutor ณVendas Cliente        บ Data ณ18/07/11         บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para retornar se o usuario pode criar ou alterar Sugestao  บฑฑ
ฑฑบ          ณde Lista                                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณnRet[N]  : 1 - Importar Sugestao                                  บฑฑ
ฑฑบ          ณ           2 - Criar Nova Sugestao                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                               
Static Function Lj843DlSL()

Local nRet		:= 0									// Variavel utilizada para armazenar o retorno da funcao
Local cTitulo	:= STR0079								// Titulo da caixa de dialogo  #Sugestใo de lista de presentes
Local cTexto	:= STR0079								// Texto da caixa de dialogo   #Sugestใo de lista de presentes
Local aBotoes	:= {STR0077, STR0078}				    // Array com os textos dos botoes da caixa de dialogo #Importar#Criar nova

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe o usuario tiver permissao para criar uma nova lista ้ chamada o dialogo para escolha.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Lj843UsSL()
	nRet := Aviso(cTitulo, cTexto, aBotoes, 2)
Else
	nRet := 1
Endif

Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณLj843CriLs บAutor ณVendas Cliente        บ Data ณ18/07/11         บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que cria uma Dialog Box para criar uma nova lista baseada  บฑฑ
ฑฑบ          ณnos itens da lista que esta sendo montada no momento.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[A] : Cabecalho da sugestao de lista - ME7:                  บฑฑ
ฑฑบ          ณ           Exp01[1]: ME7_DESCRI                                   บฑฑ
ฑฑบ          ณ           Exp01[2]: ME7_STATUS                                   บฑฑ
ฑฑบ          ณ           Exp01[3]: ME7_TIPLIS                                   บฑฑ
ฑฑบ          ณ           Exp01[4]: ME7_DESCTP                                   บฑฑ
ฑฑบ          ณExp02[A] : Itens da sugestao de lista - ME8                       บฑฑ
ฑฑบ          ณ           Exp02[1]: ME8_CODIGO                                   บฑฑ
ฑฑบ          ณ           Exp02[2]: ME8_CODPRO                                   บฑฑ
ฑฑบ          ณ           Exp02[3]: ME8_DESPRO                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณlRet[L]  : .T. - Lista criada com sucesso                         บฑฑ
ฑฑบ          ณ           .F. - Erro na criacao da lista                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/            
Static Function Lj843CriLs(aCabec, aItens)

Local lRet    := .T.								// Variavel utilizada para armazenar o retorno da funcao
Local nCont   := 0                       			// Contador utilizado no laco para preencher os campos da tela com os valores da lista original
Local nPosArr := 0									// Armazena a posicao no array aCabec de um determinado campo da enchoice

Local aLstCmpAlt := {"ME7_DESCRI", "ME7_DESCTP"}	// Array com os campos da enchoice que permitem edicao de dados para verificao no SX3
Local aCpoEnch   := {}								// Array com os campos da enchoice
Local cAliasE    := "ME7"							// Alias utilizado para a enchoice
Local aAlterEnch := {}								// Array para a enchoice com os campos que permitem a edicao
Local aPos := {000,000,180,300}						// Tamanho da tela
Local nModelo := 3									// Modelo 3 da tela para a Enchoice
Local lF3 := .F.									// Indica se a enchoice esta sendo criada em uma consulta F3 para utilizar variaveis de memoria.
Local lMemoria := .T.								// Indica se a enchoice utilizara variaveis de memoria ou os campos da tabela na edicao. 
Local lColumn := .F.								// Indica se a apresentacao dos campos sera em forma de coluna.
Local caTela := ""									// Nome da variavel tipo "private" que a enchoice utilizara no lugar da variavel aTela.
Local lNoFolder := .F.								// Indica se a enchoice nใo ira utilizar as Pastas de Cadastro (SXA).   
Local lProperty := .F.								// Indica se a enchoice nao utilizara as variaveis tipo "private" aTela e aGets, 
													// somente suas propriedades com seus respectivos nomes. 
Local cCadastro := STR0080							// Titulo da tela   #Cadatro de sugestao de lista
Local oBtnOK                    					// Botao OK da tela
Local oBtnCa                    					// Botao Cancelar da tela
Local aTELA[0][0]									// Variavel utilizada na funcao Obrigatorio
Local aGETS[0]										// Variavel utilizada na funcao Obrigatorio
Local oDlg03										// Objeto da caixa de dialogo (tela)
Local oEnch											// Objeto da enchoice da tela


DbSelectArea("SX3")
DbSetOrder(1)
DbSeek(cAliasE)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVarrer o SX3 para buscar os dados dos campos para alimentar a enchoiceณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
While !Eof() .AND. GetSx3Cache(aCpos[nx],"X3_ARQUIVO") == cAliasE    

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSelecionar campos para apresentar na enchoiceณ
    //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !(aCpos[nx] $ "A1_FILIAL") .AND. cNivel >= GetSx3Cache(aCpos[nx],"X3_NIVEL") .AND. X3Uso(GetSx3Cache(aCpos[nx],"X3_USADO"))
		AADD(aCpoEnch,aCpos[nx])
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSelecionar campos para alteracao na enchoiceณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If aScan(aLstCmpAlt,{|x| x == Upper(ALLTRIM(aCpos[nx]))}) > 0
		aAdd(aAlterEnch,aCpos[nx])
	Endif
	DbSkip()
End  

//ฺฤฤฤฤฤฤฤฤฤฟ
//ณInterfaceณ
//ภฤฤฤฤฤฤฤฤฤู
oDlg03 := MSDIALOG():New(000,000,210,600,cCadastro,,,,,,,,,.T.)

	RegToMemory(cAliasE, .T.)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCarregar os campo da tela em memoria com os dado vindos do array.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nCont:= 1 To LEN(aCpoEnch)
		
		nPosArr := aScan(aCabec, {|x| x[1] == aCpoEnch[nCont]})
	
		If nPosArr > 0 .AND. LEN(aCabec[nPosArr]) > 1
			M->&(aCpoEnch[nCont]) := aCabec[nPosArr][2]
		Endif	
	Next nCont
	
	//ฺฤฤฤฤฤฤฤฤฟ
	//ณEnchoiceณ
	//ภฤฤฤฤฤฤฤฤู
	oEnch := MsMGet():New(cAliasE,/*nReg*/, 3, /*aCRA*/, /*cLetra*/,;
						   /*cTexto*/, aCpoEnch, aPos, aAlterEnch, nModelo, /*nColMens*/,;
	                       /*cMensagem*/, /*cTudoOk*/,oDlg03,lF3,lMemoria,lColumn, caTela,;
					       lNoFolder, lProperty)
	//ฺฤฤฤฤฤฤฤฤฟ
	//ณBotao OKณ
	//ภฤฤฤฤฤฤฤฤู                                                           
	@oDlg03:nHeight/2-30, oDlg03:nClientWidth/2-190 Button oBtnOK Prompt STR0081 Size 30,15 Pixel ;  //#Ok
				Action {|| IIf(Lj843GrvLs(Lj843Ar1SL("ME7"), aItens, @aGets, @aTela), oDlg03:End(),.T.)} Of oDlg03
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณBotao Cancelarณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	@oDlg03:nHeight/2-30, oDlg03:nClientWidth/2-155 Button oBtnCa Prompt STR0082 Size 30,15 Pixel Action {|| oDlg03:End()} Of oDlg03  //#Cancelar
	
	oDlg03:lCentered := .T.
oDlg03:Activate()

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณLj843GrvLs บAutor ณVendas Cliente        บ Data ณ18/07/11         บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que grava ou atualiza a nova lista baseada nos itens da    บฑฑ
ฑฑบ          ณlista nos itens da lista que esta sendo montada no momento.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[A] : Cabecalho da sugestao de lista - ME7                   บฑฑ
ฑฑบ          ณExp02[A] : Itens da sugestao de lista - ME8                       บฑฑ
ฑฑบ          ณExp03[A] : aGets para utilizacao na funcao Obrigatorio            บฑฑ
ฑฑบ          ณExp03[A] : aTela para utilizacao na funcao Obrigatorio            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณlRet[L]  : .T. - Lista gravada com sucesso                        บฑฑ
ฑฑบ          ณ           .F. - Erro na gravacao da lista                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/            
Static Function Lj843GrvLs(aCabec, aItens, aGets, aTela)

Local lRet       := .T.						// Variavel utilizada para armazenar o retorno da funcao
Local aAreaME7   := ME7->(GetArea())		// Array para guardar o status da tabela ME7 para volta-la ao status original no final da funcao
Local aAreaME8   := ME8->(GetArea())    	// Array para guardar o status da tabela ME8 para volta-la ao status original no final da funcao
Local cIndiceME7   := "ME7_CODIGO"			// Utilizado p/ obter a posicao do campo ME7_CODIGO no array aCabec
Local cValInd    := ""						// Valor do campo ME7_CODIGO vindo no array aCabec
Local nI         := 0						// Contador para lacos na funcao
Local nJ	     := 0						// Contador para lacos na funcao
Local cCmpAt     := ""						// Armazena o nome do campo para se obter o seu FieldPos para insercao de dados
Local nPosDePara := 0						// Armazena a linha a ser lida no array aME2xME8 para realizar o de-para entre os campos da ME2 e ME8 
Local aME2xME8   := {{"ME2_PRODUT", "ME8_CODPRO"},;  // Matriz de-para entre ME2 e ME8
                     {"ME2_DESCRI", "ME8_DESPRO"},;
                     {"ME2_QTDSOL", "ME8_QTDADE"}}



//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerificar o preenchimento dos campo obrigatorios na enchoiceณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Obrigatorio(aGets,aTela, ,.F.)
	MsgAlert(STR0083)	// #E necessario informar o conteudo de todos os campos obrigatorios antes da gravacao
	lRet := .F.
Endif

If lRet == .T.
    
	

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGravacao dos dados na ME7 e ME8ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Begin Transaction

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerificar se a sugestao ja existe na tabela ME7 ณ
		//|Caso exista e realizada a inclusao dos dados    |
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DbSelectArea("ME7")
		DbSetOrder(1)		// ME7_FILIAL+ME7_CODIGO
		cValInd := aCabec[aScan(aCabec, {|x| x[1] == cIndiceME7 })][2]
		If !ME7->(DbSeek(xFilial("ME7")+cValInd))

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณInserir dados na ME7 - Cabecalho da sugestao de listaณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			RecLock("ME7", .T.)
			
			For nI:= 1 to LEN(aCabec)
				cCmpAt 	:= RTrim(aCabec[nI][1])
				nPos	:= ME7->(FieldPos(cCmpAt))

				If nPos > 0
					ME7->(FieldPut(nPos,aCabec[nI][2]))
				Endif
			Next nI
			
			MsUnlock()
        
   		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//|Caso contrario os dados na ME7 sao atualizados  |
		//|e os da ME8 sao deletados e novamente inseridos |
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Else

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualizar dados na ME7 - Cabecalho da sugestao de listaณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			RecLock("ME7", .F.)
			
			For nI:= 1 to LEN(aCabec)
				cCmpAt 	:= RTrim(aCabec[nI][1])
				nPos	:= ME7->(FieldPos(cCmpAt))

				If nPos > 0 .AND. !cCmpAt $ "ME7_FILIAL|ME7_CODIGO|ME7_STATUS" 
					ME7->(FieldPut(nPos,aCabec[nI][2]))
				Endif
			Next nI
			
			MsUnlock()
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณApagar dados da tabela ME8ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			DbSelectArea("ME8")
			DbSetOrder(1)		// ME8_FILIAL+ME8_CODIGO+ME8_FACIL+ME8_GRPLIS+ME8_CODPRO
			If ME8->(DbSeek(xFilial("ME8")+cValInd))
				While !ME8->(EOF()) .AND. ME8->ME8_FILIAL == xFilial("ME8") .AND. ME8->ME8_CODIGO == cValInd
					
					RecLock("ME8", .F.)
					ME8->(dbDelete())
					MsUnlock()
					
					ME8->(DbSkip())
				End
			Endif
			
		Endif

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณInserir dados na ME8 - Itens da sugestao de listaณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		For nI := 2 To LEN(aItens)
		
			RecLock("ME8", .T.)		    
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณGravacao do campo Codigoณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			cCmpAt 	:= "ME8_CODIGO"
			nPos	:= ME8->(FieldPos(cCmpAt))
			If nPos > 0
				ME8->(FieldPut(nPos,cValInd))
			Endif
            
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณGravacao da filial do item da Sugestao da Listaณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			cCmpAt 	:= "ME8_FILIAL"
			nPos	:= ME8->(FieldPos(cCmpAt))
			If nPos > 0
				ME8->(FieldPut(nPos,xFilial("ME8")))
			Endif			

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณGravacao dos demais campos do arrayณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			For nJ:= 1 to LEN(aItens[nI])

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณSe o campo estiver entre os do array do de-para ele e gravado na tabela ME8ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				nPosDePara := aScan(aME2xME8, {|x| x[1] == aItens[1][nJ]})
				If nPosDePara > 0
				
					cCmpAt 	:= RTrim(aME2xME8[nPosDePara][2])
					nPos	:= ME8->(FieldPos(cCmpAt))
		
					If nPos > 0
						If Type(cCmpAt) == "N"
							ME8->(FieldPut(nPos,Round(aItens[nI][nJ], TamSX3(cCmpAt)[2])))
						Else
							ME8->(FieldPut(nPos,aItens[nI][nJ]))				
						Endif
					Endif
				Endif				
				
			Next nJ
		
			MsUnlock()

 		Next nI
		
	End Transaction
	
Endif

RestArea(aAreaME7)
RestArea(aAreaME8)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณLj843Ar1SL บAutor ณVendas Cliente        บ Data ณ18/07/11         บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que monta o array do cabecalho da sugestao da lista -      บฑฑ
ฑฑบ          ณDados da tabela ME1                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[C] : Se for ME1, preenche com os dados de ME1, se for ME7   บฑฑ
ฑฑบ          ณ           preenche com os dados de ME7                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณaRet[A]  : Array do cabecalho da sugestao da lista de casamento   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA843                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                    
Static Function Lj843Ar1SL(cTab)

Local aRet := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณQuando o array para gravacao for preenchido com dados da ME1       ณ
//|o campo ME7_DESCTP e preenchido com o correspondente da tabela ME3 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

// [01] Filial
// [02] Codigo da lista
// [03] Descricao da lista
// [04] Status da lista (1 = Ativa, 2 = Inativa)
// [05] Tipo da lista (cadastro de tipos na tabela ME3)
// [06] Descricao do tipo da lista

If cTab == "ME1"
	aAdd(aRet, {"ME7_FILIAL", xFilial("ME7")})
	aAdd(aRet, {"ME7_CODIGO", M->ME1_CODIGO} )
	aAdd(aRet, {"ME7_DESCRI", M->ME1_NOME}   )
	aAdd(aRet, {"ME7_STATUS", "1"}           )
	aAdd(aRet, {"ME7_TIPLIS", M->ME1_TPEVEN} )
	aAdd(aRet, {"ME7_DESCTP", Posicione("ME3", 1, xFilial("ME3")+M->ME1_TPEVEN, "ME3_DESCRI")})
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณQuando o array para gravacao for preenchido com dados da ME7         ณ
//|o campo ME7_DESCTP e preenchido com o que foi preenchido na enchoice ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ElseIf cTab == "ME7"
	aAdd(aRet, {"ME7_FILIAL", xFilial("ME7")})
	aAdd(aRet, {"ME7_CODIGO", M->ME7_CODIGO} )
	aAdd(aRet, {"ME7_DESCRI", M->ME7_DESCRI} )
	aAdd(aRet, {"ME7_STATUS", "1"}           )
	aAdd(aRet, {"ME7_TIPLIS", M->ME7_TIPLIS} )
	aAdd(aRet, {"ME7_DESCTP", M->ME7_DESCTP} )
Endif

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณLj843Ar2SL บAutor ณVendas Cliente        บ Data ณ18/07/11         บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que monta o array dos itens da sugestao da lista - Dados   บฑฑ
ฑฑบ          ณda tabela ME2                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[A] : aHeader utilizado no grid para tabela ME2              บฑฑ
ฑฑบ          ณExp02[A] : aCols utilizado no grid para tabela ME2                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณaRet[A]  : Array dos itens da sugestao da lista de casamento      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA843                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                         
Static Function Lj843Ar2SL(aHeaderME2, aColsME2)

Local aRet       := {}
Local nCont1     := 0
Local nCont2     := 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMontar a primeira linha do aCols com os dados do aHeader ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd(aRet, {})
For nCont1 := 1 To LEN(aHeaderME2)
	aAdd(aRet[LEN(aRet)],aHeaderME2[nCont1][POS_CMP])
Next nCont1
                                      
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPreencher as demais linhas do aCols com os dados a serem gravado na tabela ME2ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nCont1 := 1 To LEN(aColsME2)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerificacao para nao permitir itens excluidosณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If aColsME2[nCont1][LEN(aColsME2[1])] == .F.
		aAdd(aRet, {})	
		For nCont2 := 1 To LEN(aColsME2[nCont1])-1
			aAdd(aRet[LEN(aRet)],aColsME2[nCont1][nCont2])	
		Next nCont2
	Endif
		
Next nCont1             

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณLj843DME2  บAutor ณVendas Cliente        บ Data ณ03/02/12         บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que valida se no array dos itens da sugestao da lista -    บฑฑ
ฑฑบ          ณDados da tabela ME2 - ha duplicidade de itens                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[A] : aCols utilizado no grid para tabela ME2                บฑฑ
ฑฑบ          ณExp02[A] : aHeader utilizado no grid para tabela ME2              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณlRet : .F. - Indica se ha duplicacao de itens                     บฑฑ
ฑฑบRetorno   ณ       .T. - Nao ha duplicacao de itens                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA843                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                     
Function Lj843DME2(aColsME2, aHeadME2)
           
Local lRet 	  := .T.		// Variavel de retorno da funcao
Local nCont   := 0			// Variavel para loops for
Local cCodProd := ""			// Codigo do produto a ser pesquisado no aCols	
Local nPos	  := 0			// Numero da posicao do registro encontrado no aCols
Local nPosCod := 0			// Posicao no aCols do codigo do produto
                                                                                                  
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณObter a posicao do campo ME2_CODIGOณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nCont := 1 To LEN(aHeadME2)
        
	If aHeadME2[nCont][POS_CMP] == "ME2_PRODUT"
		nPosCod := nCont
		Exit
	Endif

Next nCont
           

If nPosCod > 0
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณLoop em todas as linhas do aCols para verificar se ha duplicidade em cada uma das linhas      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nCont := 1 To Len(aColsME2)                    
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerificacao para nao permitir itens excluidosณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If aColsME2[nCont][LEN(aColsME2[1])] == .F.	
	
			cCodProd := aColsME2[nCont][nPosCod]
			
			nPos := aScan(aColsME2, {|x| x[nPosCod] == cCodProd})	
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณCaso a posicao encontrada no aScan seja diferente da que esta sendo buscada neste momento      ณ
			//ณse trata de uma duplicidade de produto. Tamb้m eh verificado se o registro nao estah deletado. ณ
			//ณLogo o retorno e true, ou seja ha duplicidade                                                  ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If nPos <> nCont .AND. aColsME2[nPos][LEN(aColsME2[1])] == .F.
				MsgAlert(STR0084 + CRLF + ;	//#"Hแ produtos informados duas vezes nos itens da lista de presente. "
						 STR0085)	   		//#"Por favor exclua um dos produtos duplicados."
				lRet := .F.
				Exit
			Endif
			
		Endif
	
	Next nCont
Endif

Return lRet


//-------------------------------------------------------------------
/*{Protheus.doc} Lj845VlTipo
Valida se serแ possivel alterar o tipo da lista

@param   
@author  Varejo
@version P11.8
@since   14/10/2015
@return  lRet - .T. -> permitido / .F. -> nใo permitido
@obs
@sample
/*/
//-------------------------------------------------------------------
Function Lj845VlTipo()
Local lRet		:= .T.
Local aOrdME4	:= {}

If nOperacao == ALTERAR .And. Type("M->ME1_TIPO") # "U" .And. Type("M->ME1_CODIGO") # "U"
	aOrdME4 := ME4->(GetArea())
	ME4->(DBSetOrder(1)) //ME4_FILIAL + ME4_CODIGO
	If ME4->(DBSeek( xFilial("ME4") + M->ME1_CODIGO ))
		MsgInfo(STR0092,STR0093) //"Nใo ้ possํvel alterar o seu tipo pois jแ existe(m) movimenta็ใo(๕es) para esta lista." //"Aten็ใo"
		lRet := .F.
	EndIf
	RestArea(aOrdME4)
EndIf

Return lRet    

//-------------------------------------------------------------------
/*{Protheus.doc} Lj843CodBar
Valida se o produto existe nas tabelas de codigo de barras.

@param   
@author  Varejo
@version P11.8
@since   14/10/2015
@return  lRet - .T. -> permitido / .F. -> nใo permitido
@obs
@sample
/*/
//-------------------------------------------------------------------
Function Lj843CodBar(cProduto)
Local lRet		:= .T.
Local nQtd		:= 1
Local cCodBar	:= ""

Default cProduto := ""

lRet := LjSB1SLK( @cProduto, nQtd, .F., @cCodBar )
If lRet
	M->ME2_PRODUT := cProduto
Else
	MsgInfo(STR0094,STR0093) //"Produto ou C๓digo de barras nใo encontrado." //"Aten็ใo"
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} Lj8AjuDoc
Retorna o numero do documento e serie para que seja gravado no campo ME4_DOC e ME4_SERIE

@param   
@author  Lucas Novais (lnovais)
@version P12.1.17
@since   14/10/2015
@return  Array - Retorna o numero do documento e serie para que seja gravado no campo ME4_DOC e ME4_SERIE
@obs
@sample
/*/
//-------------------------------------------------------------------

Static Function Lj8AjuDoc()

Local cDocPed 		:= ""	
Local cSeriePed		:= ""
Local aArea			:= GetArea()
Local aAreaSL1 		:= SL1->(GetArea())

//Se Doc e DocPed estiver vazio indica que esta posicionado no or็amento filho, por esse motivo precisamos pegar o Doc ou docped preenchido no or็amento Pai
If Empty(SL1->L1_DOC) .And. Empty(SL1->L1_DOCPED)
	DbSelectArea("SL1")
	SL1->(DbSetOrder(1))
	If SL1->(DbSeek(xFilial("SL1") + SL1->L1_ORCRES))
		Do Case 
			Case !Empty(SL1->L1_DOC)
				cDocPed		:= SL1->L1_DOC
				cSeriePed	:= SL1->L1_SERIE
			Case !Empty(SL1->L1_DOCPED)
				cDocPed		:= SL1->L1_DOCPED
				cSeriePed	:= SL1->L1_SERPED		
		EndCase
	EndIf
Else
	Do Case 
		Case !Empty(SL1->L1_DOC)
			cDocPed		:= SL1->L1_DOC
			cSeriePed	:= SL1->L1_SERIE
		Case !Empty(SL1->L1_DOCPED)
			cDocPed		:= SL1->L1_DOCPED
			cSeriePed	:= SL1->L1_SERPED
	EndCase	
EndIf 

RestArea(aAreaSL1)
RestArea(aArea)

Return {cDocPed,cSeriePed}