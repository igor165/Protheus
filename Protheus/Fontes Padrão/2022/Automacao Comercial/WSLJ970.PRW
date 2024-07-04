#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "TBICONN.CH"


Function WSLJ970()
Return Nil

/*
	Funcao criada com objetivo de controlar alguma alteracao realizada neste fonte que afeta outro fonte.                                        
	Retorna uma data de quando foi realizada a modificacao no fonte para poder verificar se o novo tratamento pode ser aplicado em outras funcoes
*/
Function WSLJ970Ver()
Return "20120710"

WSSERVICE LjGrvDados DESCRIPTION "Servico de Gravacao de dados (Automacao Comercial)" 
	
	//Dados para gravação da tabela SLX
	WsData SLXFilial	as String
	WsData SLXLocal	as String
	WsData SLXPdv		as String
	WsData SLXOperador as String
	WsData SLXDtMvto	as String
	WsData SLXHora	as String
	WsData SLXCupom	as String
	WsData SLXSerie	as String
	WsData SLXItem	as String
	WsData SLXValor	as Float
	WsData SLXProduto as String
	WsData SLXQtde	as Float
	WsData SLXSupervi as String
	WsData SLXSitua	as String
	WsData SLXTpCanc	as String
	WsData SLXDescont as Float
	WsData SLXAliqIcm as Float
	WsData SLXLegenda as String
	WsData SLXVlrUnt  as Float
	WsData SLXContDoc as String
	WsData SLXSitTrib as String

	WSDATA Estacao AS String
	WSDATA L1  	   AS String
	WSDATA L2      AS String
	WSDATA L4      AS String       
	
	WSDATA cRegistros As String
	WSDATA cAlias     As String
	WSDATA cConfirme  As String
	WSDATA lGravou    As Boolean	

	WSDATA Num	    AS String
	WSDATA Importou	AS String
	
	WSDATA StLink	AS String
	
	WSDATA cFil				As String					//Define se realiza a exportacao dos Dados de Saida
	WSDATA cEmp				As String					//Define se realiza a exportacao dos Dados de Saida
	WSDATA cFuncao			As String OPTIONAL			//Define a gravação da SLW Abertura ou Fechamento
	WSDATA aRetDados 		AS Array of String			//Retorna orcamentos cancelados(GrvCancel)
	WSDATA lCnv64To32 		As Boolean OPTIONAL			//Indica que deve converter uma string de 64 bytes para 32 (formato ASCII)
	
	
 	WSMETHOD Processar  DESCRIPTION "Processa"                  //Processa venda
	WSMETHOD GrvDadosX  DESCRIPTION "Grava SFI ou SE5"          //"Grava SFI ou SE5"
	WSMETHOD GrvCancel  DESCRIPTION "Grava Cancelamento"        //"Grava Cancelamento"
	WSMETHOD VldLink	DESCRIPTION "Valida Link"        		//"Valida Link" 
	WSMETHOD GrvEstorn  DESCRIPTION "Grava MBZ"                 //Grava MBZ
	WSMETHOD GrvLogCanc DESCRIPTION "Grava SLX"					//Grava Log de Cancelamentos
	WSMETHOD GrvCanTEF	DESCRIPTION "Grava Cancel TEF"			//"Grava Cancel TEF"

ENDWSSERVICE

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Metodo	 ³FRTBXCRD  ³ Autor ³ Venda Clientes        ³ Data ³22/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a baixa das CRDs selecionadas           			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - SL4       							  			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ .T.                   						              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD Processar WSRECEIVE Estacao, L1, L2, L4, cFil, cEmp   WSSEND Num WSSERVICE  LjGrvDados
Local aSl1
Local aSl2
Local aSl4
Local cNumOrc 	:= ""
Local lPrepEnv	:= LjPreparaWs(cEmp, cFil)	//faz prepare Environment 
Local nL2_VDOBS := 0
Local nCount := 0

aSl1 := &(L1)
aSl2 := &(L2)
aSl4 := &(L4)

If aSL1[AScan(aSL1,{|x|x[1]=="L1_NUMORIG"})][2] == ''
	aSL1[AScan(aSL1,{|x|x[1]=="L1_OPERACA"})][2] := ""
EndIf

//Tratameto para o campo tipo Memo Real
nL2_VDOBS := AScan(aSL2[1], "L2_VDOBS" )
If nL2_VDOBS > 0
	For nCount:=2 to Len(aSL2)
		If !Empty(aSL2[nCount][nL2_VDOBS])
			aSL2[nCount][nL2_VDOBS] := Decode64(aSL2[nCount][nL2_VDOBS])
		EndIf
	Next nCount
EndIf

::Num 	 := GeraL1L2L4(aSL1, aSL2, aSL4, Estacao)
cNumOrc := ::Num

//Somente transforma o orcamento em RX se ele foi gravado
If ValType(cNumOrc)=="C" .AND. Left(cNumOrc,2) == "OK"
	ConfL1L2L4(Substr(::Num, 4, 6 ), Estacao)
EndIf	

Return .T.


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Metodo	 ³FRTBXCRD  ³ Autor ³ Venda Clientes        ³ Data ³22/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a baixa das CRDs selecionadas           			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - SL4       							  			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ .T.                   						              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD VldLink WSRECEIVE Estacao, L1, L2, L4  WSSEND StLink WSSERVICE  LjGrvDados

::StLink := "OK"

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Metodo	 ³GrvDadosX ³ Autor ³ Venda Clientes        ³ Data ³18/11/2009  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a gravacao do SFI ou SE5             			    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cRegistros - String com os registros a serem gravados		³±±
±±³			 ³	   cAlias - Alias usado       								³±±
±±³          ³  cConfirme - Conteudo que ira atulizar o campo "XX_SITUA"    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ lGravou - Resultado do processamento			                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Sigaloja													    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD GrvDadosX WSRECEIVE cRegistros, cAlias, cConfirme, cEmp, cFil, cFuncao, lCnv64To32 WSSEND lGravou WSSERVICE LjGrvDados
Local aDados    := {}   
Local nCont     := 1
Local nQuant    := 0      
Local lPrepEnv	:= LjPreparaWs(cEmp, cFil)	//faz prepare Environment // diego
Local cNomeCamp := ""
Local aRet      := {"ER",0}
Local nPosLGI	:= 0
Local nPosLGA	:= 0
Local cCampoLGX := ""
Local cBackUsuar:= CUSUARIO

Default lCnv64To32 := .T. //Indica que deve converter uma string de 64 bytes para 32 (formato ASCII), somente se esta antes foi convertida de 32 para 64 bytes 
Default cFuncao	   := ""

Static cBkRegistros := ""	//Cria um bakup da variavel cRegistro

::lGravou := .T.

If !Empty(cFuncao) .AND. ExistFunc(cFuncao)
	cBkRegistros := cRegistros
	&(cFuncao + "(cBkRegistros)")	
Else
	aDados := &(cRegistros)
	nQuant := Len(aDados)
	
	//Formata campo NOMETABELA_SITUA, Exemplo: Iniciando com "S": SL1->L1_SITUA, caso contrário MDZ->MDZ_SITUA
	If Substr(Upper(cAlias), 1, 1) == "S"
		cNomeCamp := Substr(cAlias, 2, 2) + "_SITUA"        
	Else
		cNomeCamp := cAlias + "_SITUA"        
	EndIf

	//Formata campo NOMETABELA_USERLGX, Exemplo: Iniciando com "S": SE5->E5_USERLGI, caso contrário MDZ->MDZ_USERLGI
	If Substr(Upper(cAlias), 1, 1) == "S"
		cCampoLGX := Substr(cAlias, 2, 2)      
	Else
		cCampoLGX := cAlias      
	EndIf

	While nCont <= nQuant .AND. ::lGravou 
		//Converte uma string de 64 bytes para 32 (formato ASCII)
		//Este tratamento eh necessario, pois o campo pode conter 
		//caracteres que nao tem conversao para UTF-8, o que causaria erro no WS
		nPosLGI := aScan( aDados[nCont], {|x| Alltrim(Upper(x[1])) == cCampoLGX + "_USERLGI"}) 
		nPosLGA := aScan( aDados[nCont], {|x| Alltrim(Upper(x[1])) == cCampoLGX + "_USERLGA"}) 
		If nPosLGI <> 0
			aDados[nCont][nPosLGI][2] := Decode64(aDados[nCont][nPosLGI][2])
		EndIf
		
		If nPosLGA <> 0
			aDados[nCont][nPosLGA][2] := Decode64(aDados[nCont][nPosLGA][2])
		EndIf
		
		Do Case
			Case cAlias == "SFI"
				aRet := GeraSFI( aDados[nCont] )
			Case cAlias == "SE5"
				aRet := GeraE5( aDados[nCont] )
			Case cAlias == "LK9" .Or. cAlias == "LHG" .Or. cAlias == "SLW" .Or.;
				cAlias == "SLT" .Or. cAlias == "LEJ" .Or. cAlias == "MDZ"
				aRet := GeraSZ( cAlias, aDados[nCont] )
		EndCase

		If Len(aRet) > 0 .AND. aRet[1] == "OK"
			If cAlias == "MDZ" .And. aRet[2] == -1
				::lGravou := .T. //Confirma a gravação mas na verdade não pode gravar registro do tipo "RP" e outros, que não pode(m) ser duplicado(s)
			Else						
				&(cAlias)->(DbGoto(aRet[2]))
				::lGravou := FRTGeraSL(cAlias, {{cNomeCamp, cConfirme}})				// "RX" "OK" - Foi Recebido Pelo Server
			EndIf
			
		EndIf  
		If nPosLGI <> 0
			// Limpa a variável CUSUARIO do mesmo modo como entrou no método.
			CUSUARIO:= cBackUsuar
		EndIf  
		nCont++
	End
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Metodo	 ³GrvCancel ³ Autor ³ Venda Clientes        ³ Data ³18/11/2009  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a gravacao do Cancelamento.             			    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cRegistros - String com os registros a serem gravados		³±±
±±³			 ³	   cAlias - Alias usado       								³±±
±±³          ³  cConfirme - Conteudo que ira atulizar o campo "XX_SITUA"    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ aRetDados - Vendas Canceladas                				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Sigaloja													    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD GrvCancel WSRECEIVE cRegistros, cEmp, cFil WSSEND aRetDados WSSERVICE LjGrvDados

Local aOrcs     	:= {}   
Local nCont     	:= 1
Local nQuant    	:= 0      
Local nRet      	:= {} 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³A cada execucao, setamos a empresa e filial de acordo com a origem da requisicao,|
//| para que o Web Services execute o processamento no ambiente correto.			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LjPreparaWs(::cEmp, ::cFil)

Self:aRetDados := {}

aOrcs  := StrToKarr(cRegistros,"|")
nQuant := Len(aOrcs)

While nCont <= nQuant

	nRet := FRTExclusa( aOrcs[nCont] )
	
	// Se (0)Cancelou, (2)Nao Existe ou se (3)Venda não foi processada pelo GrvBatch (4)Venda foi devolvida/trocada
	If nRet == 0 .OR. nRet == 2 .OR. nRet == 3 .OR. nRet == 4 
		
		//Retorna Vendas Canceladas para atualizar SLI do PDV. Somente gera SLI quando envia a venda 
		//para a Retaguarda, quando não localiza a venda limpa SLI para evitar looping infinito
		If nRet <> 3
			AADD(Self:aRetDados,aOrcs[nCont])
		EndIf
	EndIf
    
	nCont++
End

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Metodo	 ³GrvEstorn ³ Autor ³ Venda Clientes    ³ Data ³30/12/2010  	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a gravacao do MBZ                     			    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cRegistros - String com os registros a serem gravados		³±±
±±³			 ³	   cAlias - Alias usado       							 	³±±
±±³          ³  cConfirme - Conteudo que ira atulizar o campo "XX_SITUA"    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ lGravou - Resultado do processamento			                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Sigaloja													    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD GrvEstorn WSRECEIVE cRegistros, cEmp, cFil WSSEND lGravou WSSERVICE LjGrvDados
Local aDados    := {}   
Local lPrepEnv	:= LjPreparaWs(cEmp, cFil) //faz prepare Environment
Local aRet      := {}

If AliasInDic("MBZ")	
	
	::lGravou := .T.
	
	aDados := &(cRegistros)  
	
	aRet := GeraMBZ( "MBZ", aDados )
	
	If aRet[1] == "OK"   
		ConfMBZ(aRet[2])
	Else
		::lGravou := .F.
	EndIf
	
Else 
	::lGravou := .F.
EndIf	

Return .T.

                 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa	 ³Lj970Slw  ³ Autor ³ Vendas CRM            ³ Data ³  30/01/2012  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chama a rotina para gravacao da SLW             			       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cBkRegistros - Recebe a string de registros para montar o array  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ .T.											                    			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Sigaloja Off-line     									        ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj970Slw(cBkRegistros) 
Local aBkDados	:= {}	//Cria um array com os registros da variavel cRegistros atraves de uma macro execucao

Default cBkRegistros := ""

If Empty(cBkRegistros)
	Return
EndIf

aBkDados := &(SubStr(cBkRegistros,2,Len(cBkRegistros) - 2)) 
           
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se executa a rotina de abertura ou fechamento da SLW ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(DtoS(aBkDados[aScan(aBkDados,{|x| AllTrim(x[1]) == "LW_DTFECHA"})][2]))  
	FRT020ABR(aBkDados,.T.)
Else
	FRT020FCH(aBkDados,,.T.)
EndIf	                             

Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} GrvDadosLX
Captura os dados da SLX do PDV e envia para gravação na retaguarda

aSLX : array com os dados da SLX
cEmp : Empresa 
cFil : Filial 

/*/
//--------------------------------------------------------------------
WSMETHOD GrvLogCanc WSRECEIVE cEmp,cFil, SLXFilial, SLXLocal, SLXPdv,;
	SLXOperador, SLXDtMvto, SLXHora, SLXCupom, SLXSerie, SLXItem, SLXValor,;
	SLXProduto, SLXQtde, SLXSupervi, SLXSitua, SLXTpCanc, SLXDescont,;
	SLXAliqIcm, SLXLegenda, SLXVlrUnt, SLXContDoc, SLXSitTrib WSSEND lGravou WSSERVICE LjGrvDados

::lGravou := .F.
LjPreparaWs(::cEmp,::cFil)	//faz prepare Environment

DbSelectArea('SLX')
SLX->(DbSetOrder(1))	//LX_FILIAL, LX_PDV, LX_CUPOM, LX_SERIE, LX_ITEM, LX_HORA
If !SLX->(DbSeek(::SLXFilial+::SLXPdv+::SLXCupom+::SLXSerie+::SLXItem+::SLXHora))
	RecLock('SLX',.T.)
	REPLACE LX_FILIAL	WITH ::SLXFilial
	REPLACE LX_LOCAL	WITH ::SLXLocal
	REPLACE LX_PDV	WITH ::SLXPdv
	REPLACE LX_OPERADO WITH ::SLXOperador
	REPLACE LX_DTMOVTO WITH StoD(::SLXDtMvto)
	REPLACE LX_HORA WITH ::SLXHora
	REPLACE LX_CUPOM WITH ::SLXCupom 
	SerieNfId("SLX",1,"LX_SERIE",dDataBase,LjEspecieNF(), ::SLXSerie )
	REPLACE LX_ITEM WITH ::SLXItem
	REPLACE LX_VALOR WITH ::SLXValor
	REPLACE LX_PRODUTO WITH ::SLXProduto
	REPLACE LX_QTDE WITH ::SLXQtde
	REPLACE LX_SUPERVI WITH ::SLXSupervi
	REPLACE LX_SITUACA WITH ::SLXSitua
	REPLACE LX_TPCANC WITH ::SLXTpCanc
	REPLACE LX_DESCON WITH ::SLXDescont
	REPLACE LX_ALIQICM WITH ::SLXAliqIcm
	REPLACE LX_LEGENDA WITH ::SLXLegenda
	REPLACE LX_VRUNIT WITH ::SLXVlrUnt
	   		
	If SLX->(ColumnPos("LX_CONTDOC")) > 0
		REPLACE LX_CONTDOC WITH ::SLXContDoc
	EndIf
	
	IF SLX->(ColumnPos("LX_SITTRIB")) > 0
		REPLACE LX_SITTRIB WITH ::SLXSitTrib
	EndIf
	
	SLX->(MsUnlock())
	::lGravou := .T.
Else
	::lGravou := .F.
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvCanTEF
Preenche os campos do cancelamento do 
TEF quando cancelo venda pelo PDV PAF

@type Function
@param cNumOrcamento , caracter , numero do orçamento
@author  Varejo
@version P11.8
@since   25/07/2015
@return  .T. , lógico , executado ?
/*/
//-------------------------------------------------------------------
WSMETHOD GrvCanTEF WSRECEIVE cRegistros, cEmp, cFil WSSEND aRetDados WSSERVICE LjGrvDados
Local aRegistros   	:= {}
Local aDados		:= {}
Local nCont     	:= 1
Local nQuant    	:= 0      
Local nRet      	:= {} 

LjPreparaWs(::cEmp, ::cFil)

Self:aRetDados := {}

aRegistros  := StrToKarr(cRegistros,";")
nQuant		:= Len(aRegistros)

For nCont:= 1 to nQuant
	aDados := StrToKarr(aRegistros[nQuant],"|")
	nRet := FrtTEFCanc( aDados )
		
	//Se (1) Gravou o cancelamento
	If nRet == 1
		//Retorna Vendas Canceladas para atualizar SLI do PDV. Somente gera SLI quando envia
		// a venda para a Retaguarda, quando não localiza a venda limpa SLI para evitar looping infinito
		If nRet <> 3
			AADD(Self:aRetDados,aDados[1])
		EndIf
	EndIf
    
Next nCont

Return .T.