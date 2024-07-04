#INCLUDE "FWMBROWSE.CH"
#INCLUDE "PROTHEUS.CH" 

/*
  Esta funcao foi criada para que seja possivel visualizar a data deste
  fonte no inspetor de objetos, pois nao eh possivel fazer isso se nao
  houver nenhuma FUNCTION no fonte.
*/
FUNCTION FISX001();RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} EFDGEN()
Classe genérica para processamento da EFD Contribuições. Aqui serão 
criados metódos, informações e processamentos em comum para apuração
que estarão disponíveis para as demais classes que herdarem esta classe. 

@author Erick G. Dias
@since 28/07/2014
@version 11.80

@history Vogas Júnior, 05/06/2018, (DSERFIS1-4280)  imprimir relartório conforme período apurado.
/*/
//-------------------------------------------------------------------
CLASS EFDGEN

	Data aFilial 	As Array	HIDDEN 	
	Data cConsl 	As String  HIDDEN
	Data dDtIni 	As Date 	HIDDEN		
	Data dDtFim		As Date		HIDDEN
	Data cFilApu 	As String		
	Data lBuild     As Boolean
	Data lVer12		As Boolean
	Data oHashSM0
	Method SetDtIni(value)
	Method SetDtFim(value)
	Method SetFilial(Value)
	Method New(Value)
	Method BuscaxFil(Value)
	Method SetFilApu(Value)
	Method SetConsol(Value)
	Method FechaAlias(Value)		
	Method IniHash()
	Method AddHash()
	Method FindHash()		
	
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método construtor da classe 

@author Erick G. Dias
@since 28/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD New() Class EFDGEN
	Self:cConsl := '2' //Como Default irá iniciar com 2, apuração não consolidada na visão da Matriz.
Self:IniHash()
Return

Method SetFilApu(Value) Class EFDGEN
	Self:cFilApu := Value
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} SetConsol()
Método que indica se o processamento será realizado de forma consolidada
na visão da matriz ou se será efetuado na forma individualizada na filial. 

@author Erick G. Dias
@since 28/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method SetConsol(Value) Class EFDGEN
	Self:cConsl := Value
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFilial()
Método que passa um array com o conteúdo do xFilial das tabelas. Será
utilizado para processo de consolidaçãoe gravação das informações neste modo. 

@author Erick G. Dias
@since 28/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method SetFilial(Value) Class EFDGEN
	
	/*o trecho abaixo com código de bloco é devido ao motivo do robô de compilação ter o binário antigo
	e não conteplar a funcionalidade do HashMap, e nestes casos é necessário macro executar estas funcionalidades.
	Porém para o método AtoHM ocorre erro na versão 11, e com uma alterantiva criei o bloco de código como string
	macro executo o bloco e depois realizo eval para processar o AtoHM, foi a única forma que encontrei para
	macro executar o AtoHM na versão 11.
	*/
	Local cBloco	  :=  ''
	Local bBloco	  := nil		
	
	Self:aFilial := Value	

	// Converte o array aFilial em hashmap.
	// Testo se o valor passado é um Array pois há chamadas da "SetFilial"
	// em que o valor passado nao eh um array.
	IF Self:lBuild .And. ValType(Value) == "A"	
			
		IF Self:lVer12
			Self:oHashSM0 := AtoHM(Self:aFilial)
		Else
			cBloco	:= '{ || AtoHM( Value ) }'
			bBloco	:= nil
			
			bBloco	:= &cBloco		
			Self:oHashSM0 := Eval(bBloco)				
		Endif

	Endif
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FechaAlias()
Método que fecha area do alias pasasdo. 

@author Erick G. Dias
@since 28/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method FechaAlias(cAliasProc) Class EFDGEN
	DbSelectArea (cAliasProc)
	(cAliasProc)->(DbCloseArea ())
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuscaxFil()
Método que realiza busca do conteúdo do xFilial para que seja realizado
o processamento de consolidação na visão da empresa. 

@author Erick G. Dias
@since 28/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method BuscaxFil(cxFilial) Class EFDGEN

Local cFil	:= ''
Local nPos	:= 0
Local aFilHash := {}
Local cHmGet	:= 'HMGet'

// Se a build for compativel faco a busca direto no hashmap com HMGET.
// Caso contrario mantenho a busca com aScan no array Self:aFilial.
// Nao utilizei o "FindHash" pois aqui quero retornar um array (aFilHash)
// e nao uma posicao (nPos) como eh feito nos registros aglutinados. 
// Para nao ter que tratar o tipo do retorno da FindHash utilizei direto
// a HMGet.
If Self:lBuild
	If &cHmGet.( Self:oHashSM0 , cxFilial  , @aFilHash )
		cFil := aFilHash[1][2]
	Else
		cFil := xFilial (cxFilial)
	EndIf
Else
	nPos :=	aScan(Self:aFilial,{|aX| aX[1]==cxFilial})
	If nPos > 0	
		cFil := Self:aFilial[nPos][2]
	Else
		cFil := xFilial (cxFilial)
	EndIF 
EndIf
 
Return cFil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetDtIni()
Método que irá passar a data inicial de processamento. 

@author Erick G. Dias
@since 28/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method SetDtIni(Value) Class EFDGEN
	Self:dDtIni := Value
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} SetDtFim()
Método que irá passar a data final de processamento. 

@author Vogas Júnior
@since 05/06/2018
@version Única
/*/
//-------------------------------------------------------------------
Method SetDtFim(Value) Class EFDGEN
	Self:dDtFim := Value
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} AddHash()
Adiciona Elemento no HashMap.

@author Erick G. Dias
@since 28/07/2014
/*/
//-------------------------------------------------------------------
Method AddHash(oHash,cChave,nPos) Class EFDGEN

Local cHmSet	:= 'HMSet'

&cHmSet.(oHash, cChave, nPos)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FindHash()
Procura Elemento no HashMap.

@author Erick G. Dias
@since 28/07/2014
/*/
//-------------------------------------------------------------------
Method FindHash(oHash,cChave) Class EFDGEN
	
Local nPosRet	:= 0	
Local cHmGet	:= 'HMGet'

&cHmGet.( oHash , cChave  , @nPosRet )
	
Return nPosRet

//-------------------------------------------------------------------
/*/{Protheus.doc} IniHash()
Inicializa o HashMap das Filiais

@author joao.pellegrini
@since 12/01/2018
/*/
//-------------------------------------------------------------------
Method IniHash() Class EFDGEN

Local cNew := "HMNew()"

Self:lBuild := GetBuild() >= "7.00.131227A"
Self:lVer12 := GetVersao(.F.) == "12"

If Self:lBuild
	Self:oHashSM0 := &cNew
EndIf

Return
/*
Classe de apuração da EFD Contribuições, contendo todas as regras e cálculos
para os tributos de PIS, COFINS e CPRB para apuração e geração da obrigação
acessória da EFD Contribuições.
*/

CLASS FISX001 FROM EFDGEN

//----------------------------------------------------
//DECLARAÇÃO DAS VARIÁVEIS UTILIZADAS NAS PROPRIEDADES 
//----------------------------------------------------

	Data nBase 	  		As integer HIDDEN //Base de Cálculo
	Data nVal  	  		As integer HIDDEN //Valor do Tributo
	Data nAlq  	  		As integer HIDDEN //Alíquota do tributo
	Data nBaseST 		As integer HIDDEN //Base de Cálculo Substituição Tributária
	Data nValST  		As integer HIDDEN //Valor do Tributo Substituição Tributária
	Data nValipi  		As integer HIDDEN //Valor do IPI para exclusão da Receita Bruta 																				 
	Data nAlqST  		As integer HIDDEN //Alíquota do tributo Substituição Tributária
	Data nReceita 		As integer HIDDEN //Valor da Receita
	Data nRecBruta 		As integer HIDDEN //Valor da Receita Bruta
	Data nTotBase		As integer HIDDEN //Valot total da base
	Data nBaseCum		As integer HIDDEN //Valor total da base de cálculo cumulativa
	Data nBaseNCum		As integer HIDDEN //Valor total da base de cálculo não cumulativa
	Data nVlPauta		As integer HIDDEN	//valor da pauta utilizada no documento fiscal
	Data nQtde			As integer HIDDEN//quantidade do item 
	Data nValMajora		As integer HIDDEN//Valor do tributo majorado
	Data nAlqMajora		As integer HIDDEN//valor da alíquota majorada
	Data nVlExclFol		As integer HIDDEN//valor da alíquota majorada	
	Data cPauta	  		As String  HIDDEN//Indica se operação é com pauta de PIS e COFINS
	Data cTpReg			As String  HIDDEN//tipo do regime
	Data cConta			As string  HIDDEN//conta contábil
	Data cTrib  		As string  HIDDEN//Tributo processado
	Data cRegime  		As string  HIDDEN//Regime do tributo
	Data cRegimeApu 	As string  HIDDEN//Regime da apuração
	Data cRegimeOpe 	As string  HIDDEN//Regime da operação
	Data cCst  	  		As string  HIDDEN//CST de PIS e COFINS
	Data cLivro	  		As string  HIDDEN//Livro Processado
	Data cCodConCrd 	As string  HIDDEN//Código da Contribuição
	Data cOrigem		As string  HIDDEN//Origem do Processamento
	Data cIdEFD	  		As String  HIDDEN//Id da EFD
	Data cCodBcc		As String  HIDDEN//Código do Crédito de PIS e COFINS
	Data cAlqBas		As String  HIDDEN//Indica se é alíquota básica
	Data cIndCre		As String  HIDDEN//indicador da origem do crédito de PIS e COFINS
	Data cDescri		As String  HIDDEN//Descrição 
	Data cCfop			As String  HIDDEN//CFOP do item da nota fiscal
	Data cEspecie		As String  HIDDEN//Espécie da nota fiscal
	Data cTNatRec		As String  HIDDEN//Tabela da Natureza da Receita
	Data cCNatRec		As String  HIDDEN//Código da Ntureza da Receita
	Data cGNatRec		As String  HIDDEN//Grupo da Receita da Natureza	
	Data cBlocoI		As String  HIDDEN//Grupo da Receita da Natureza	
	Data lSCP			As Boolean HIDDEN//Indica se é operação com SCP
	Data lAtvImob		As Boolean HIDDEN//Indica se é operação com ativodade Imobiliaria
	Data lVendMan		As Boolean HIDDEN//Indica se é venda para Zona Franca de Manaus	
	Data lImport		As Boolean HIDDEN//Indica se operação é referente a importação
	Data lExport		As Boolean HIDDEN//Indica se operação é referente a exportação
	Data lCupom	  		As Boolean HIDDEN//Indica se operação é referente a cupom fiscal	
	Data dDNatRec		As Date	   HIDDEN//Data da Natureza da Receita
	DAta dDtFin	  		As Date    HIDDEN//Data Final
	Data aChave	 		As Array   HIDDEN//Array com as filiais selecionadas pelo usuário
	Data aCFOPs	 		As Array   HIDDEN//Array com CFOPS para considerar como receita
	Data aTotCST		As Array   HIDDEN//Array espelho com informações dos totais por CST
	Data aRecBruta		As Array   HIDDEN //Array espelho com informações da receita bruta
	Data aTotCL8		As Array   HIDDEN//Array espelho da tabela CL8 - Débitos Consolidados
	Data aCKS			As Array   HIDDEN //Array espelho da tabela CKS - Relação EFD
	Data aCL0			As Array   HIDDEN//Array espelho da tabela CL0 - Receita Bruta
	Data aCKT			As Array   HIDDEN////Array espelho da tabela CKT		
	Data aCL8			As Array   HIDDEN////Array espelho da tabela CL8
	Data aCL9			As Array   HIDDEN////Array espelho da tabela CL9
	Data aF3J	 		As Array   HIDDEN////Array espelho da tabela CL9
	Data cPisFolha		As string  HIDDEN////Array espelho da tabela CL9
	Data lProcCprb		As string  HIDDEN////Array espelho da tabela CL9	
	Data lImob			As Boolean HIDDEN
	Data lAgrIndust		As Boolean HIDDEN
	Data aNcmInsumPres  As Array   HIDDEN
	Data lDeprAtv		As Boolean HIDDEN
	Data cSlctF0X  		AS String  HIDDEN
	Data cFromF0X	  	As String  HIDDEN
	Data cWhereF0X  	AS String  HIDDEN
	Data lCredSBse 		As Boolean HIDDEN
	Data aPERCAPD  		As Array   HIDDEN	
	Data lECF  			As Boolean HIDDEN	
	Data oHashCL8
	Data oHashCL9	
	Data nValIcmsST	  	As integer HIDDEN //Valor do ICMS ST	
	Data lCmpAjuBas	  	As Boolean
	Data aRecBloco	  	
	Data aTotRecNB //Array com os totais das receitas e receitas não bruta
	Data cBloco //Bloco da receita que está sendo processada
	Data nTamCtaCKT 	As Integer	

/*----------------------------------------------------
DECLARAÇÃO DOS MÉTODOS DE GET E SET 
Sempre que necessário passar os obter informações da classe
deverá ser realizado pelas propriedades get e set.
----------------------------------------------------*/
 	
	Method SetBcTrib(Value)
	Method GetBcTrib(Value)		
	Method SetValTrib(Value)	
	Method SetAlqTrib(Value)	
	Method GetAlqTrib(Value)	
	Method SetBaseST(Value)	
	Method SetValST(Value)	
	Method SetAlqSt(Value)	
	Method SetTributo(Value)	
	Method SetRegime(Value)	
	Method SetCST(Value)	
	Method SetDtFin(Value)	
	Method SetLivro(Value)
	Method SetSCP(Value)
	Method SetAtvImob(Value)
	Method SetVendMan(Value)
	Method SetReceita(Value)
	Method SetRecBrut(Value)
	Method SetCodBcc(Value)
	Method SetCFOP(Value)
	Method SetEspecie(Value)
	Method SetTNatRec(Value)
	Method SetCNatRec(Value)
	Method SetCupom(Value)
	Method SetGNatRec(Value)
	Method SetBlocoI(Value)	
	Method SetDNatRec(Value)
	Method SetVlPauta(Value)
	Method SetQtde(Value)
	Method SetConta(Value)
	Method SetAlqMaj(Value)
	Method SetValMaj(Value)
	Method SetRegApur(Value)
	Method SetTpReg(Value)	
	Method SetOrigem(Value)
	METHOD SetPisFolh(cValue) 
	METHOD SetExclPis(cValue) 	
	Method SetPauta(Value)
	Method SetAlqBas(Value)	
	Method SetImport(Value)
	Method SetExport(Value)
	Method SetCodDC(Value)
	Method SetPrcCPRB(Value)	
	Method setImob(Value)
	Method setAgrIndust(Value)
	Method setlDeprAtv(Value)
	Method setCredSBse(Value)
	Method setlECF(Value)
	Method setIcmsSt(Value)		
	Method setValIpi(Value)							 
	
	//Metodos is - retornam uma condicao
	Method isAgrIndust()

// Declaração dos Métodos que a classe terá
	Method New()
	Method AgrContr()
	Method GetWhrSFT(Value)
	Method GetCmpSFT()
	Method GetJoinFrm()
	Method GetGrpSFT()
	Method ChkRegraNf(cEspecie,cCfop,cEntSai)
	Method ChkEspecie(Value)
	Method ChkCFOP(Value)
	Method AgrpContr()
	Method CodCon ()
	Method ChvEFD ()
	Method GrvDebPC()
	Method GrvResCST()
	Method ProcRecNB()
	Method Clear()
	METHOD ClearTab()
	METHOD AgrpCred ()
	METHOD GrvCred ()
	Method CodCred()
	METHOD GrvCredPC ()
	METHOD CalcBAseRC()
	METHOD GrvRecBru()
	METHOD GrvRecNB()
	METHOD AcumRecBru ()
	METHOD LoadRecBru()
	METHOD OperPauta()
	METHOD GrvRecNT()
	METHOD DefRegime()
	METHOD GrvCKZ()	
	METHOD GrvCKS()
	METHOD GrvCL0()
	METHOD GrvCKT()
	METHOD Finaliza(cValor)
	METHOD GrvCL8()
	METHOD GrvCL9()			
	METHOD EstornCanc()	
	METHOD BuscaChave()	
	METHOD ReduzBase()	
	METHOD ReduzCL0()	//Método que irá reduzir valores de receita e base de cálculo do resumo de enradas e saídas por CST
	Method ClsItem()
	Method cfgParamPres( Value1 )
	Method GetF0X( cPeriodo )
	Method GetcSlctF0X()
	Method GetcFromF0X()
	Method GetcWhereF0X()	
	Method setIndCre(Value)
	Method SetRegOpe(Value)
	Method GetRegOpe()
	Method AgrCL9CL8()
	Method GetReceita()
	Method GetRecBrut()
	Method GetCST()	
	Method GetCodCon()		
	Method RecBlocos(cBLoco)
	Method GetRecBlc()
	Method SetRecBlc()
		
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método Construtor da Classe 

@author Erick G. Dias
@since 14/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD New() Class FISX001
	Local cPERCAPD	:= GetNewPar("MV_PERCAPD","{0,0,0}")
	Local cNew := "HMNew()"
	
	Self:nReceita	:=0
	Self:nRecBruta	:=0
	Self:nTotBase	:=0
	Self:nBaseCum	:=0
	Self:nBaseNCum	:=0
	Self:nVlPauta	:=0
	Self:nQtde		:=0 
	Self:nValMajora	:=0
	Self:nAlqMajora	:=0
	Self:nVlExclFol	:=0	
	Self:cPauta	  	:='2'
	Self:cTpReg		:=''
	Self:cConta		:=''
	Self:cTrib  	:=''
	Self:cRegime  	:=''
	Self:cRegimeApu :=''
	Self:cRegimeOpe :=''
	Self:cCst  	  	:=''
	Self:cLivro	  	:=''
	Self:cCodConCrd :=''
	Self:cOrigem	:=''
	Self:cIdEFD	  	:=''
	Self:cCodBcc	:=''
	Self:cAlqBas	:=''
	Self:cIndCre	:='0'
	Self:cDescri	:='' 
	Self:cCfop		:=''
	Self:cEspecie	:=''
	Self:cTNatRec	:=''
	Self:cCNatRec	:=''
	Self:cGNatRec	:=''
	Self:cBlocoI	:=''
	Self:cPisFolha	:=''		
	Self:lSCP		:= .F.
	Self:lAtvImob	:= .F.
	Self:lVendMan	:= .F.	
	Self:lImport	:= .F.
	Self:lExport	:= .F.
	Self:lCupom	  	:= .F.
	Self:dDNatRec	:=CTod("  /  /    ")
	Self:dDtIni	  	:=CTod("  /  /    ")
	Self:dDtFin	  	:=CTod("  /  /    ")
	Self:aChave	 	:={}
	Self:aCFOPs		:= XFUNCFRec() // Funcao que retorna array com CFOPS / [1]-Considera Receita / [2]-NAO considera como Receita
	Self:aTotCST	:={}
	Self:aRecBruta	:={}
	AADD(Self:aRecBruta,{0,0,0,0,0})	
	Self:aTotCL8	:={}
	Self:aCKS		:={}
	Self:aCL0		:={}
	Self:aCKT		:={}		
	Self:aCL8		:={}
	Self:aCL9		:={}
	Self:aF3J	 	:={}
	Self:cConsl		:= '2'
	Self:lProcCprb	:= .F.
	Self:lImob		:= .F.	
	Self:nAlqST		:= 0
	Self:lDeprAtv	:= .F.
	Self:lCredSBse	:= .F.	 	 
	Self:aPERCAPD   := Iif (Len(cPERCAPD) > 1,&(cPERCAPD),{0,0,0})
	Self:lECF		:= .F.
	Self:IniHash()
	Self:nValIcmsST	:= 0	
	Self:nValIpi	:= 0 					  
	Self:lCmpAjuBas	:= CKS->(FieldPos("CKS_BCAJUS"))>0 
	Self:aRecBloco	:= {}
	Self:aTotRecNB	:= {}
	Self:cBloco:= ""
	Self:nTamCtaCKT := TamSx3("CKT_CONTA")[1] 	

	If Self:lBuild	
		Self:oHashCL8 := &cNew
		Self:oHashCL9 := &cNew
	EndIf

Return  Self

/*--------------------------------------------------------------
SEÇÃO DOS MÉTODOS GET E SET DA CLASSE, COM TODAS AS PROPRIEDADES
SE NECESSÁRIO CRIAR GET E SET, SEGUIR ESTA LISTA ABAIXO
--------------------------------------------------------------*/
//--------------------------
//BASE DE CALCULO DO TRIBUTO
//--------------------------
Method SetBcTrib(Value) Class FISX001
	Self:nBase := Value
Return .T.

Method GetBcTrib(Value) Class FISX001
Return Self:nBase

//----------------
//VALOR DO TRIBUTO
//----------------
Method SetValTrib(Value) Class FISX001
	Self:nVal := Value
Return .T.


//-------------------
//ALÍQUOTA DO TRIBUTO
//-------------------
Method SetAlqTrib(Value) Class FISX001
	Self:nAlq := Value
Return .T.

Method GetAlqTrib() Class FISX001	
Return Self:nAlq

//--------------------------------------------------
//BASE DE CALCULO DO TRIBUTO SUBSTITUIÇÃO TRIBUTÁRIA
//--------------------------------------------------
Method SetBaseST(Value) Class FISX001
	Self:nBaseST := Value
Return .T.

//--------------------------------------------------
//VALOR DO TRIBUTO SUBSTITUIÇÃO TRIBUTÁRIA
//--------------------------------------------------
Method SetValST(Value) Class FISX001
	Self:nValST := Value
Return .T.

//--------------------------------------------------
//ALÍQUOTA DO TRIBUTO SUBSTITUIÇÃO TRIBUTÁRIA
//--------------------------------------------------
Method SetAlqSt(Value) Class FISX001
	Self:nAlqST := Value
Return .T.

//-------
//TRIBUTO
//-------
Method SetTributo(Value) Class FISX001
	Self:cTrib := Value
Return .T.

//---------------------------------------
//REGIME DE TRIBUTAÇÃO DO PIS E DA COFINS
//---------------------------------------
Method SetRegime(Value) Class FISX001
	Self:cRegime := Value
Return .T.

//-------------------
//CST DE PIS E COFINS
//-------------------
Method SetCST(Value) Class FISX001
	Self:cCst := Value
Return .T.

Method GetCST() Class FISX001	
Return Self:cCst

Method SetPauta(Value) Class FISX001
	Self:cPauta := Value
Return

Method SetAlqBas(Value)	 Class FISX001
	Self:cAlqBas := Value
Return

Method SetImport(Value) Class FISX001
	Self:lImport := Value
Return 

Method SetExport(Value) Class FISX001
	Self:lExport := Value
Return 

//---------------------------------------
//DATA FINAL DE PROCESSAMENTO DA APURAÇÃO
//---------------------------------------
Method SetDtFin(Value) Class FISX001
	Self:dDtFin := Value
Return .T.

//----------------
//LIVRO PROCESSADO
//----------------
Method SetLivro(Value) Class FISX001
	Self:cLivro := Value
Return .T.

//----------------
//OPERAÇÂO COM SCP
//----------------
Method SetSCP(Value) Class FISX001
	Self:lSCP := Value
Return .T.

//-----------------------------------
//OPERAÇÂO COM ATIVIDADE IMOBILIÁRIA
//-----------------------------------
Method SetAtvImob(Value) Class FISX001
	Self:lAtvImob := Value
Return .T.

//--------------------------------------------------------
//OPERAÇÃO DE SUBSTITUIÇÃO TRIBUTÁRIA DE VENDA PARA MANAUS
//--------------------------------------------------------
Method SetVendMan(Value) Class FISX001
	Self:lVendMan	:= Value
Return .T.

//--------------------------------------------------------
//VALOR DE RECEITA DA OPERAÇÃO
//--------------------------------------------------------
Method SetReceita(Value) Class FISX001
	Self:nReceita	:= Value
Return .T.

Method GetReceita(Value) Class FISX001	
Return Self:nReceita

//--------------------------------------------------------
//VALOR DE RECEITA DA OPERAÇÃO
//--------------------------------------------------------
Method SetRecBrut(Value) Class FISX001
	Self:nRecBruta	:= Value
Return .T.

Method GetRecBrut(Value) Class FISX001	
Return Self:nRecBruta


//--------------------------------------------------------
//CÓDIGO DA BASE DE CÁLCULO DO CRÉDITO
//--------------------------------------------------------
Method SetCodBcc(Value) Class FISX001
	Self:cCodBcc	:= Value
Return .T.

//--------------------------------------------------------
//CÓDIGO DA BASE DE CÁLCULO DO CRÉDITO
//--------------------------------------------------------
Method SetCFOP(Value) Class FISX001
	Self:cCfop	:= Value
Return .T.


//--------------------------------------------------------
//CÓDIGO DA BASE DE CÁLCULO DO CRÉDITO
//--------------------------------------------------------
Method SetEspecie(Value) Class FISX001
	Self:cEspecie	:= Value
Return .T.

//--------------------------------------------------------
//CÓDIGO DA BASE DE CÁLCULO DO CRÉDITO
//--------------------------------------------------------
Method SetTNatRec(Value) Class FISX001
	Self:cTNatRec	:= Value
Return .T.


//--------------------------------------------------------
//CÓDIGO DA BASE DE CÁLCULO DO CRÉDITO
//--------------------------------------------------------
Method SetCNatRec(Value) Class FISX001
	Self:cCNatRec	:= Value
Return .T.


//--------------------------------------------------------
//CÓDIGO DA BASE DE CÁLCULO DO CRÉDITO
//--------------------------------------------------------
Method SetGNatRec(Value) Class FISX001
	Self:cGNatRec	:= Value
Return .T.


//--------------------------------------------------------
//CÓDIGO DA BASE DE CÁLCULO DO CRÉDITO
//--------------------------------------------------------
Method SetCupom(Value) Class FISX001
	Self:lCupom	:= Value
Return .T.

//--------------------------------------------------------
//CÓDIGO DA BASE DE CÁLCULO DO CRÉDITO
//--------------------------------------------------------
Method SetBlocoI(Value) Class FISX001
	Self:cBlocoI	:= Value
Return .T.

//--------------------------------------------------------
//CÓDIGO DA BASE DE CÁLCULO DO CRÉDITO
//--------------------------------------------------------
Method SetDNatRec(Value) Class FISX001
	Self:dDNatRec	:= Value
Return .T.

//--------------------------------------------------------
//CÓDIGO DA BASE DE CÁLCULO DO CRÉDITO
//--------------------------------------------------------
Method SetVlPauta(Value) Class FISX001
	Self:nVlPauta	:= Value
Return .T.


//--------------------------------------------------------
//CÓDIGO DA BASE DE CÁLCULO DO CRÉDITO
//--------------------------------------------------------
Method SetQtde(Value) Class FISX001
	Self:nQtde	:= Value
Return .T.

//--------------------------------------------------------
//CÓDIGO DA BASE DE CÁLCULO DO CRÉDITO
//--------------------------------------------------------
Method SetConta(Value) Class FISX001
	Self:cConta := Value
Return

//--------------------------------------------------------
//CÓDIGO DA BASE DE CÁLCULO DO CRÉDITO
//--------------------------------------------------------
Method SetAlqMaj(Value) Class FISX001
	Self:nAlqMajora := Value
Return

//--------------------------------------------------------
//CÓDIGO DA BASE DE CÁLCULO DO CRÉDITO
//--------------------------------------------------------
Method SetValMaj(Value) Class FISX001
	Self:nValMajora := Value
Return

//--------------------------------------------------------
//CÓDIGO DA BASE DE CÁLCULO DO CRÉDITO
//--------------------------------------------------------
Method SetRegApur(Value) Class FISX001
	Self:cRegimeApu := Value
Return

//--------------------------------------------------------
//CÓDIGO DA BASE DE CÁLCULO DO CRÉDITO
//--------------------------------------------------------
Method SetTpReg(Value) Class FISX001
	Self:cTpReg := Value
Return

METHOD SetOrigem(cValor) Class FISX001
	Self:cOrigem	:=	cValor
Return

METHOD SetPisFolh(cValue) Class FISX001
	Self:cPisFolha := cValue	
Return

METHOD SetExclPis(cValue) Class FISX001
	Self:nVlExclFol := cValue	
Return

METHOD SetCodDC(cCod) Class FISX001
	Self:cCodConCrd	:= PADR(cCod,3) 
Return

METHOD GetCodCon() Class FISX001
Return PADR(Self:cCodConCrd,2)

Method SetPrcCPRB(Value) Class FISX001
	Self:lProcCprb := Value
Return

Method setImob(Value) Class FISX001
	Self:lImob := Value
Return

Method setAgrIndust(Value) Class FISX001
	Self:lAgrIndust := Value
Return
Method setlDeprAtv(Value) Class FISX001
	Self:lDeprAtv := Value
Return
Method setCredSBse(Value) Class FISX001
	Self:lCredSBse := Value
Return

Method setIndCre(Value)	 Class FISX001
	Self:cIndCre := Value
Return

Method GetcSlctF0X() Class FISX001
Return Self:cSlctF0X

Method GetcFromF0X() Class FISX001
Return Self:cFromF0X

Method GetcWhereF0X() Class FISX001
Return Self:cWhereF0X

Method SetRegOpe(Value) Class FISX001
	Self:cRegimeOpe := Value
Return

Method setlECF(Value) Class FISX001
	Self:lECF := Value
Return

Method setIcmsSt(Value) Class FISX001
	Self:nValIcmsST := Value
Return
Method setValIpi(Value) Class FISX001 
	Self:nValipi := Value
Return
Method GetRegOpe() Class FISX001
Return Self:cRegimeOpe

Method GetRecBlc() Class FISX001
Return Self:aRecBloco

Method SetRecBlc(aRecBloco) Class FISX001
Self:aRecBloco	:= aRecBloco
Return 

Method RecBlocos(cBLoco) Class FISX001

Local nPos	:= 0
Local cCstNTrib	:= '04#06#07#08#09#49#99'
Local lRecNTrib	:= Self:cCst $ cCstNTrib .OR. (Self:cCst == '05' .AND. Self:nAlq == 0)
Local cCodCon	:= Iif(lRecNTrib, "" , Self:GetCodCon())  //Receita não tributada não possui código da contribuição

Self:cBloco	:= cBLoco

//Acumula valores no array agrupados por CST, Regime e Bloco. 
nPos := aScan(Self:aRecBloco,{|x| x[1] == Self:cCst .AND. x[2] == cCodCon .AND. x[3] == Self:GetRegOpe()})

IF nPos == 0
	//Adicionar informações no array	
	aAdd(Self:aRecBloco, {})
	nPos := Len(Self:aRecBloco)
	aAdd (Self:aRecBloco[npos],Self:getCST()) 
	aAdd (Self:aRecBloco[npos],cCodCon)
	aAdd (Self:aRecBloco[npos],Self:GetRegOpe())
	aAdd (Self:aRecBloco[npos],0) //Receitas bloco A
	aAdd (Self:aRecBloco[npos],0) //Receitas bloco C
	aAdd (Self:aRecBloco[npos],0) //Receitas bloco D
	aAdd (Self:aRecBloco[npos],0) //Receitas bloco F
	aAdd (Self:aRecBloco[npos],0) //Percentual de Receita

EndIF

IF nPos > 0 .AND. !Empty(cBloco)
	If cBloco == "A"
		Self:aRecBloco[nPos][4] += Self:getReceita()
	ElseIF cBloco == "C"
		Self:aRecBloco[nPos][5] += Self:getReceita()
	ElseIF cBloco == "D"
		Self:aRecBloco[nPos][6] += Self:getReceita()
	ElseIF cBloco == "F"
		Self:aRecBloco[nPos][7] += Self:getReceita()		
	EndIF
EndIF

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AgrCL9CL8()
Metodo responsavel por agrupar os dados do array aCL9 no array aCL8
para que nao ocorram divergencias entre os registros M100 e M105. 

@author joao.pellegrini
@since 05/12/2016
@version 11.80
/*/
//-------------------------------------------------------------------
Method AgrCL9CL8() Class FISX001

Local nX := 0
Local nPosCL8 := 0
	
// Zerando a base previamente calculada.

For nX := 1 to Len(Self:aCL8)

	Self:aCL8[nX, 8] := 0 		

Next nX

// Atualizando base de calculo com base na CL9
// Estrutura aCL9:
// 02 - Data
// 03 - ID EFD
// 04 - CodBCC
// 05 - CST
// 10 - Base de Calculo
For nX := 1 to Len(Self:aCL9)

	nPosCL8 := aScan(Self:aCL8,{|aX| aX[1] == Self:BuscaxFil('CL8') .AND. aX[2] == Self:aCL9[nX,2] .AND. aX[3] == Self:aCL9[nX,3] .AND. aX[5] == Self:aCL9[nX,4] .AND. aX[6] == Self:aCL9[nX,5]})
	
	If nPosCL8 > 0
	
		Self:aCL8[nPosCL8, 8] += Self:aCL9[nX, 10] 				
	
	EndIf
 
Next nX

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} GetWhrSFT()
Método que retorna filtro para Where da Query para as operações de 
Saída no Livro Fiscal

@author Erick G. Dias
@return	cFiltro - Filtro para query de saída 
@since 22/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method GetWhrSFT(cEntSai,lCompl,lProcCanc,lDevCuml,lFullAtf,lLastDay,lJoinView) Class FISX001

Local cFiltro		:= ""
Local cCstDev		:= ""
Local cEmptyPDV		:= Space(TamSX3("FT_PDV")[1])

Default lCompl		:= .T.
Default lProcCanc	:= .F. //Indica se deverá ou não considera documento cancelado na apuração
Default lDevCuml	:= .F.
Default lFullAtf	:= .F.
Default lLastDay	:= .F.
Default lJoinView	:= .F.

cCstDev := Iif(lDevCuml,",'98'","")

cFiltro += " SFT.FT_FILIAL= '"+ xFilial("SFT")+ "' AND "

If lDevCuml
	cFiltro += "(SFT.FT_TIPOMOV = 'S' OR SFT.FT_TIPO = 'D') AND "
Else
	cFiltro += "SFT.FT_TIPOMOV = '" + %Exp:Iif(cEntSai=='2','S','E')% + "' AND "
EndIf

If lJoinView
	cFiltro += "SFT.FT_CLIEFOR=SF3.F3_CLIEFOR AND SFT.FT_LOJA=SF3.F3_LOJA AND "
	cFiltro += "SFT.FT_SERIE=SF3.F3_SERIE AND SFT.FT_NFISCAL=SF3.F3_NFISCAL AND "
	cFiltro += "SFT.FT_IDENTF3=SF3.F3_IDENTFT AND SFT.FT_ENTRADA=SF3.F3_ENTRADA AND "
Else

	cFiltro += "SFT.FT_ENTRADA>= '" + %Exp:DToS (Self:dDtIni)% + "' AND "
	If lLastDay
		cFiltro += "SFT.FT_ENTRADA<= '" + %Exp:DToS (lastday(Self:dDtFin))% + "' AND "
	Else
		cFiltro += "SFT.FT_ENTRADA<= '" + %Exp:DToS (Self:dDtFin)% + "' AND "
	EndIf

Endif

If !lProcCanc
	cFiltro += "(SFT.FT_DTCANC = ' ' OR SFT.FT_DTCANC > '" + %Exp:DToS (lastday(Self:dDtFin))% + "' )AND "	
EndIF

If Self:cLivro <> "*"
	cFiltro += " SFT.FT_NRLIVRO = '" +%Exp:(Self:cLivro)% +"' AND "
EndIf

IF !lCompl
	cFiltro += " SFT.FT_TIPO NOT IN ('I','P')  AND "
EndIF

If cEntSai =='2'
	cFiltro	+= "(( (SFT.FT_BASEPIS > 0  OR  SFT.FT_BASEPS3 > 0 ) OR SFT.FT_CSTPIS IN ('01','05','07','08','09','49'"+ cCstDev +"))  OR "
	cFiltro	+= " ( (SFT.FT_BASECOF > 0  OR  SFT.FT_BASECF3 > 0 ) OR SFT.FT_CSTCOF IN ('01','05','07','08','09','49'"+ cCstDev +")))  AND "
	
	//Cupom fiscal Regime de Competencia consolidado - Considera cupom fiscal na Query para F550
	If !Self:lECF
		cFiltro	+= "SFT.FT_ESPECIE <> 'CF' AND "
	Endif

	// Somente bilhetes de passagem que não tenham sido emitidos por ECF.
	cFiltro += "((SFT.FT_ESPECIE <> 'BPR') OR (SFT.FT_ESPECIE = 'BPR' AND SFT.FT_PDV = " + ValToSql(cEmptyPDV) + ")) AND "	
ElseIf cEntSai =='1' .and. !lJoinView
	
	cFiltro	+= "("
		cFiltro	+= " (SF4.F4_ATUATF <> 'S' AND (((SFT.FT_BASEPIS > 0  OR  SFT.FT_BASEPS3 > 0) OR SFT.FT_CSTPIS IN ('70','71','72','73','74','98','99'))  OR "
		cFiltro	+= " 						    ((SFT.FT_BASECOF > 0  OR  SFT.FT_BASECF3 > 0) OR SFT.FT_CSTCOF IN ('70','71','72','73','74','98','99')))) OR "
		If !lFullAtf
			cFiltro	+= " (SF4.F4_ATUATF   = 'S' AND ((SFT.FT_CSTCOF IN ('70','71','72','73','74','98','99')) OR "			
			cFiltro	+= " 						    (SFT.FT_CSTPIS IN ('70','71','72','73','74','98','99')))) "
		Else
			cFiltro	+= " (SF4.F4_ATUATF   = 'S') "		
		EndIf	
	cFiltro	+= ") "
	cFiltro	+= " AND "
EndIF

If ExistBlock("EFDCON01")
	cFiltro	:= ExecBlock("EFDCON01",.F.,.F.,{cFiltro})
EndIF

Return cFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCmpSFT()
Método que retorna campos para query de forma agrupada com SUM.

@author Erick G. Dias
@param nM996Tpr, Numérico, Indica conteúdo do parâmetro MV_M996TPR
@param lGroup, Lógico, Indica se a query deverá ser feita com agrupamento ou não
@param lJoinSC5, Lógico, indica se deverá realizar Left Join com tabela SC5
@return	cFiltro - Filtro para query de saída 
@since 22/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method GetCmpSFT(nM996Tpr, lGroup,lJoinSC5, lCNO, lExigSusp) Class FISX001

	Local cSlctSFT	:= ""
	Local cDbType  	:= ""
	Local cFuncNull	:= ""

	DEFAULT nM996Tpr	:= 0
	DEFAULT lGroup	:= .T.
	DEFAULT lJoinSC5	:= .T.
	DEFAULT lCNO		:= .F.
	Default lExigSusp	:= .F.

	cSlctSFT := "%SFT.FT_CFOP,	SFT.FT_ESPECIE,	SFT.FT_ALIQPIS,	SFT.FT_ALIQCOF,	SFT.FT_ALIQCF3,	SFT.FT_ALIQPS3,"
	cSlctSFT += "SFT.FT_CSTPIS,	SFT.FT_CSTCOF,	SFT.FT_PAUTPIS,	SFT.FT_PAUTCOF,	SFT.FT_TNATREC,	SFT.FT_CNATREC,"
	cSlctSFT +=	"SFT.FT_GRUPONC,SFT.FT_DTFIMNT,	SFT.FT_CODBCC, SFT.FT_CONTA, SFT.FT_MALQCOF, SFT.FT_MALQPIS, SFT.FT_TIPO ,"
	cSlctSFT += "SFT.FT_CREDST, SFT.FT_ESTADO,"
	If SFT->(FieldPos("FT_SERSAT"))>0 
		cSlctSFT += "SFT.FT_SERSAT,"
	EndIF
	
	If nM996Tpr == 1
		If	SFT->(FieldPos("FT_TES"))>0
			cSlctSFT += "SFT.FT_TES,"
		Endif
		cSlctSFT +=	"SF4.F4_TPREG,	SB1.B1_TPREG,"
	ElseIF nM996Tpr == 2
		cSlctSFT +=	"SB1.B1_TPREG,"
	Elseif nM996Tpr == 3
		cSlctSFT +=	"SA1.A1_TPREG,"	
	EndIF

	If	SFT->(FieldPos("FT_ALIQCPB"))>0
		cSlctSFT += "SFT.FT_ALIQCPB,"	
	Endif	
	If	SFT->(FieldPos("FT_ATIVCPB"))>0
		cSlctSFT += "SFT.FT_ATIVCPB,"	
	Endif	
	
	If lGroup	
		cSlctSFT +=	"SUM(SFT.FT_VALPIS) AS FT_VALPIS,	SUM(SFT.FT_VALCOF)  AS FT_VALCOF,  SUM(SFT.FT_VALCONT) AS FT_VALCONT,"
		cSlctSFT +=	"SUM(SFT.FT_TOTAL)  AS FT_TOTAL,	SUM(SFT.FT_BASEPIS) AS FT_BASEPIS, SUM(SFT.FT_BASECOF) AS FT_BASECOF,"
		cSlctSFT += "SUM(SFT.FT_BASECF3) AS FT_BASECF3, SUM(SFT.FT_BASEPS3) AS FT_BASEPS3, SUM(SFT.FT_VALPS3) AS FT_VALPS3,"
		cSlctSFT += "SUM(SFT.FT_VALCF3) AS FT_VALCF3,	SUM(SFT.FT_MVALCOF) AS FT_MVALCOF, SUM(SFT.FT_MVALPIS) AS FT_MVALPIS,"		
		cSlctSFT += "SUM(SFT.FT_ICMSRET)  AS FT_ICMSRET,	SUM(SFT.FT_SOLTRIB) AS FT_SOLTRIB, SUM(SFT.FT_ISENRET) AS FT_ISENRET, "		
		cSlctSFT += "SUM(SFT.FT_OBSSOL)  AS FT_OBSSOL,	SUM(SFT.FT_OUTRRET) AS FT_OUTRRET, "
		cSlctSFT += "SUM(SFT.FT_QUANT)  AS FT_QUANT,	SUM(SFT.FT_DESCONT) AS FT_DESCONT, SUM(SFT.FT_DESCZFR) AS FT_DESCZFR "
		
		If SFT->(FieldPos("FT_BASECPB"))>0 .And. SFT->(FieldPos("FT_VALCPB"))>0
			cSlctSFT += ", SUM(SFT.FT_BASECPB) AS FT_BASECPB,SUM(SFT.FT_VALCPB) AS FT_VALCPB, SUM(SFT.FT_VALIPI) AS FT_VALIPI, SUM(SFT.FT_ICMSRET) AS FT_ICMSRET
		Endif		
	Else		
		cSlctSFT +=	"SFT.FT_FILIAL	, 	SFT.FT_NFELETR , 	SFT.FT_NFISCAL ,	SFT.FT_SERIE   ,	SFT.FT_LOJA     ,"
		cSlctSFT +=	"SFT.FT_CLIEFOR	,	SFT.FT_EMISSAO ,	SFT.FT_ENTRADA ,	SFT.FT_PRODUTO ,	SFT.FT_ITEM     ,"
		cSlctSFT +=	"SFT.FT_VALPIS	,	SFT.FT_VALCOF  ,	SFT.FT_VALCONT ,    SFT.FT_TOTAL   ,	SFT.FT_BASEPIS  ,"
		cSlctSFT += "SFT.FT_BASECOF ,	SFT.FT_BASECF3 , 	SFT.FT_BASEPS3 ,	SFT.FT_VALPS3  ,	SFT.FT_VALCF3 	,"
		cSlctSFT += "SFT.FT_MVALCOF ,	SFT.FT_MVALPIS ,	SFT.FT_DTCANC  ,  	SFT.FT_VALIPI  ,	SFT.FT_ICMSRET	,"
		cSlctSFT += "SFT.FT_OBSERV	,   SFT.FT_TIPOMOV ,	SFT.FT_ISENRET ,	SFT.FT_OBSSOL  ,	SFT.FT_OUTRRET  ,"
		cSlctSFT += "SFT.FT_QUANT	,	SFT.FT_DESCZFR ,    SFT.FT_DESCONT ,	SFT.FT_SOLTRIB "
		If SFT->(FieldPos("FT_BASECPB"))>0 .And. SFT->(FieldPos("FT_VALCPB"))>0
			cSlctSFT +=", SFT.FT_BASECPB, SFT.FT_VALCPB"
		EndIF
		If lJoinSC5
			cSlctSFT += ", SC5.* "
		EndIF

		If lExigSusp

			cDbType  	:= TCGetDB()
			Do Case // Nome da funcao do banco de dados que substitui NULL
				Case cDbType $ "DB2/POSTGRES"
					cFuncNull	:= "COALESCE"
				Case "ORACLE" $ cDbType
					cFuncNull	:= "NVL"
				Otherwise
					cFuncNull	:= "ISNULL"
			EndCase
			//Adiciona campos da tabela CID
			cSlctSFT += ", SFT.FT_VALICM, SFT.FT_CHVNFE, CCF.CCF_NUMERO, CCF.CCF_IDITEM, CCF.CCF_INDAUT, CCF.CCF_NATJU, CCF.CCF_TIPO, CCF.CCF_TRIB, CID.CID_CST, CID.CID_REDUC, CID.CID_ICMS, CID.CID_ISS, CID.CID_ALIQ, CID.CID_CODREC"
			cSlctSFT += ", "+cFuncNull+"(SFTDEV.FT_TIPO,' ') FTTEMDEV"
		EndIF
	EndIF

	If lCNO
		cSlctSFT += ", SON.ON_CNO "
	EndIf

	cSlctSFT += "%"
	
Return cSlctSFT

//-------------------------------------------------------------------
/*/{Protheus.doc} GetJoinFrm()
@description Método que faz join na query principal dos documentos fiscais.

@author Erick G. Dias
@param nM996Tpr, Numérico, Indica conteúdo do parâmetro MV_M996TPR
@param lJoinSC5, Lógico, indica se deverá realizar Left Join com tabela SC5
@return cFiltro, String, Retorna as instruções de Left Join  
@since 22/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method GetJoinFrm(nM996Tpr,lJoinSC5, cEntSai, lCNO, lExigSusp) Class FISX001

Local cFrom			:= ''
Local cCodIndDeng	:= ""

DEFAULT nM996Tpr	:= 0 
DEFAULT lJoinSC5	:= .F.
DEFAULT lCNO		:= .F.
Default lExigSusp	:= .F.
 
cFrom	   :=  RetSqlName('SFT')+' SFT '

IF cEntSai == '1' //Entradas
	cFrom	   +="LEFT JOIN "+RetSqlName("SD1")+" SD1 ON(SD1.D1_FILIAL='"+xFilial("SD1")+"'  AND SD1.D1_DOC=SFT.FT_NFISCAL AND SD1.D1_SERIE=SFT.FT_SERIE AND SD1.D1_FORNECE=SFT.FT_CLIEFOR AND SD1.D1_LOJA=SFT.FT_LOJA AND SD1.D1_COD=SFT.FT_PRODUTO AND SD1.D1_ITEM=SFT.FT_ITEM AND SD1.D_E_L_E_T_=' ') "
	cFrom	   +="LEFT JOIN "+RetSqlName("SF4")+" SF4 ON(SF4.F4_FILIAL='"+xFilial("SF4")+"'  AND SF4.F4_CODIGO=SD1.D1_TES AND SF4.D_E_L_E_T_=' ') "
	
Else // saida	
	cCodIndDeng		:= XFUNCodSef({"D","I"},.t.)

	If lJoinSC5
		cFrom	   += "LEFT JOIN "+RetSqlName("SD2")+" SD2 ON(SD2.D2_FILIAL='"+xFilial("SD2")+"'  AND SD2.D2_DOC=SFT.FT_NFISCAL AND SD2.D2_SERIE=SFT.FT_SERIE AND SD2.D2_CLIENTE=SFT.FT_CLIEFOR "
		cFrom	   += "  AND SD2.D2_LOJA=SFT.FT_LOJA AND SD2.D2_COD=SFT.FT_PRODUTO AND SD2.D2_ITEM=SFT.FT_ITEM AND SD2.D_E_L_E_T_=' ') "
	EndIf
	
	cFrom	   += "INNER JOIN "+RetSqlName("SF3")+" SF3DIS ON "
	cFrom	   += "(SF3DIS.F3_FILIAL='"+xFilial("SF3")+"' AND SF3DIS.F3_SERIE = SFT.FT_SERIE AND SF3DIS.F3_NFISCAL = SFT.FT_NFISCAL AND SF3DIS.F3_CLIEFOR = SFT.FT_CLIEFOR AND SF3DIS.F3_LOJA = SFT.FT_LOJA AND SF3DIS.F3_IDENTFT = SFT.FT_IDENTF3  "
	cFrom	   += " AND SF3DIS.D_E_L_E_T_= ' ' AND SF3DIS.F3_CODRSEF NOT IN "+ cCodIndDeng +" AND SF3DIS.F3_CFO = SFT.FT_CFOP) "
	
	If nM996Tpr == 1
		//O CADASTRO DE TES E/OU PRODUTO IRÁ DEFINIR O REGIME		
		cFrom	   +="LEFT JOIN "+RetSqlName("SF4")+" SF4 ON(SF4.F4_FILIAL='"+xFilial("SF4")+"'  AND SF4.F4_CODIGO=SFT.FT_TES AND SF4.D_E_L_E_T_=' ') "
		cFrom	   +="LEFT JOIN "+RetSqlName("SB1")+" SB1 ON(SB1.B1_FILIAL='"+xFilial("SB1")+"'  AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.D_E_L_E_T_=' ') "	
	ElseIF nM996Tpr == 2
		//O CADASTRO DE PRODUTO IRÁ DEFINIR O REGIME
		cFrom	   +="LEFT JOIN "+RetSqlName("SB1")+" SB1 ON(SB1.B1_FILIAL='"+xFilial("SB1")+"'  AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.D_E_L_E_T_=' ') "
	ElseIF nM996Tpr == 3
		//O CADASTRO DO CLIENTE IRÁ DEFINIR O REGIME 
		cFrom	   +="LEFT JOIN "+RetSqlName("SA1")+" SA1 ON(SA1.A1_FILIAL='"+xFilial("SA1")+"'  AND SA1.A1_COD=SFT.FT_CLIEFOR  AND SA1.A1_LOJA=SFT.FT_LOJA AND SA1.D_E_L_E_T_=' ') "
	EndIF

	IF lExigSusp
		//Aqui faço join com as tabelas CDG e CCF
		cFrom	   +="INNER JOIN "+RetSqlName("CDG")+" CDG ON(CDG.CDG_FILIAL='"+xFilial("CDG")+"'  AND CDG.CDG_TPMOV=SFT.FT_TIPOMOV  AND CDG.CDG_DOC=SFT.FT_NFISCAL AND CDG.CDG_SERIE=SFT.FT_SERIE AND CDG.CDG_CLIFOR=SFT.FT_CLIEFOR AND CDG.CDG_LOJA=SFT.FT_LOJA AND CDG.CDG_ITEM=SFT.FT_ITEM AND CDG.D_E_L_E_T_=' ') "		
		cFrom	   +="INNER JOIN "+RetSqlName("CCF")+" CCF ON(CCF.CCF_FILIAL='"+xFilial("CCF")+"'  AND CCF.CCF_NUMERO=CDG.CDG_PROCES  AND CCF.CCF_TIPO=CDG.CDG_TPPROC AND CCF.CCF_IDITEM=CDG.CDG_ITPROC AND CCF.CCF_TRIB IN('7','8') AND CCF.CCF_NATJU IN('12','13','14','15','16','17','19') AND CCF.CCF_TPCOMP IN ('1','2') AND CCF.D_E_L_E_T_=' ') "
		cFrom	   +="INNER JOIN "+RetSqlName("CID")+" CID ON(CID.CID_FILIAL='"+xFilial("CID")+"'  AND CID.CID_NUMERO=CCF.CCF_NUMERO  AND CID.CID_TIPO=CCF.CCF_TIPO AND CID.CID_INDAUT=CCF.CCF_INDAUT AND CID.CID_IDITEM = CCF.CCF_IDITEM AND CID.D_E_L_E_T_=' ') "
		cFrom 	   +="LEFT JOIN "+RetSqlName("SFT")+" SFTDEV ON (SFTDEV.FT_FILIAL=SFT.FT_FILIAL AND SFTDEV.FT_TIPOMOV=(CASE WHEN SFT.FT_TIPOMOV='E' THEN 'S' ELSE 'E' END) AND SFTDEV.FT_SERORI = SFT.FT_SERIE AND SFTDEV.FT_NFORI = SFT.FT_NFISCAL AND SFTDEV.FT_CLIEFOR=SFT.FT_CLIEFOR AND SFTDEV.FT_LOJA=SFT.FT_LOJA AND SFTDEV.FT_ITEMORI=SFT.FT_ITEM AND SFTDEV.FT_PRODUTO=SFT.FT_PRODUTO AND SFTDEV.FT_DTCANC=' ' AND SFTDEV.FT_TIPO='D' AND  SFTDEV.D_E_L_E_T_=' '  )"
	EndIF
	
	If lJoinSC5				
		cFrom	   +="LEFT JOIN "+RetSqlName("SC5")+" SC5 ON(SC5.C5_FILIAL='"+xFilial("SC5")+"'  AND SC5.C5_NUM= SD2.D2_PEDIDO AND SC5.D_E_L_E_T_=' ') "
	EndIF
EndIF

If lCNO
	cFrom	+="INNER JOIN "+RetSqlName("SF2")+" SF2 ON( SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND SF2.F2_EMISSAO = SFT.FT_EMISSAO AND SF2.F2_DOC = SFT.FT_NFISCAL "
	cFrom	+="AND SF2.F2_SERIE = SFT.FT_SERIE AND SF2.F2_CLIENTE = SFT.FT_CLIEFOR AND SF2.F2_LOJA = SFT.FT_LOJA AND SF2.F2_EST = SFT.FT_ESTADO AND SF2.D_E_L_E_T_=' ') "
	cFrom	+="INNER JOIN "+RetSqlName("SON")+" SON ON( SON.ON_FILIAL = '"+xFilial("SON")+"' AND SF2.F2_CNO = SON.ON_CODIGO AND SON.D_E_L_E_T_=' ') "
EndIf

cFrom	:=	'%'+cFrom+'%'
	
Return cFrom


//-------------------------------------------------------------------
/*/{Protheus.doc} GetGrpSFT()
Método que retorna group by dos campos para query de saída agrupada

@author Erick G. Dias
@return	cFiltro - Filtro para query de saída 
@since 22/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method GetGrpSFT(nM996Tpr, lCNO) Class FISX001

	Local cGroupBy	:= ""
	DEFAULT nM996Tpr	:= 0
	DEFAULT lCNO		:= .F.

	cGroupBy	:=	"GROUP BY "
	cGroupBy	+=  "SFT.FT_CFOP,		SFT.FT_ESPECIE,	SFT.FT_ALIQPIS,	SFT.FT_ALIQCOF,	SFT.FT_ALIQCF3,"
	cGroupBy	+=  "SFT.FT_ALIQPS3,	SFT.FT_CSTPIS,	SFT.FT_CSTCOF,	SFT.FT_PAUTPIS,	SFT.FT_PAUTCOF,"
	cGroupBy	+=	"SFT.FT_TNATREC,	SFT.FT_CNATREC,	SFT.FT_GRUPONC,	SFT.FT_DTFIMNT,	SFT.FT_CODBCC, SFT.FT_CONTA,"
	cGroupBy  	+= 	"SFT.FT_MALQCOF, 	SFT.FT_MALQPIS,	SFT.FT_TIPO,    SFT.FT_CREDST, SFT.FT_ESTADO"
	

	If nM996Tpr == 1
		If	SFT->(FieldPos("FT_TES"))>0
			cGroupBy += ",SFT.FT_TES"
		Endif
		cGroupBy +=	",SF4.F4_TPREG,	SB1.B1_TPREG"
	ElseIF nM996Tpr == 2
		cGroupBy +=	",SB1.B1_TPREG"
	Elseif nM996Tpr == 3
		cGroupBy +=	",SA1.A1_TPREG"	
	EndIF
	
	If SFT->(FieldPos("FT_SERSAT"))>0 
		cGroupBy += ",SFT.FT_SERSAT"
	EndIF
	
	If	SFT->(FieldPos("FT_ALIQCPB"))>0
		cGroupBy += ",SFT.FT_ALIQCPB"	
	Endif	
	If	SFT->(FieldPos("FT_ATIVCPB"))>0
		cGroupBy += ",SFT.FT_ATIVCPB"	
	Endif	

	If lCNO
		cGroupBy +=	", SON.ON_CNO"
	EndIf

Return cGroupBy

Method ChkRegraNf(cEspecie,cCfop,cEntSai,cCodModNf,cModNF,cCst) Class FISX001

Local lRet			:= .F.
Local cModelo		:= ''
Default cCodModNf	:= ''
Default cModNF 		:= ''
Default cCst		:= ''

cModelo	:= IIF(Empty(cCodModNf), aMODNOT(cEspecie), cCodModNf)

cModNF := cModelo 
cCSTRec := '01/02/03/04/05/06/07/08/09'

If Self:ChkEspecie(cModelo) .And. ;
	( (cEntSai =='1') 		.Or.  ; //Entrada	  
	  (cModelo $ '01/55' 	.And. SubStr(cCfop,2,3) == '933') .Or.;
	  ((Empty(cModelo) 		.And. Len(AllTrim(cCfop))<>4) .Or. Self:ChkCFOP(AllTrim(cCfop)));
	   .Or. ((cModelo $ '01/55/65/59' .Or. Alltrim(cEspecie) $ 'NFS|NFPS|RPS') .And. SubStr(cCfop,2,3) == '949' .And. cCst$cCSTRec) )  //Saída //Adicionado 65 - NFCE / 59 - SATCE - ISSUE https://jiraproducao.totvs.com.br/browse/DSERFIS1-23197
	
	lRet := .T.	
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkEspecie()
Método que verifica se a espécie processada está prevista na geração
da EFD Contribuições

@author Erick G. Dias
@param 		Value - Espécie
@return	lRet - Retorna se espécie está dentro das previstas para processar EFD 
@since 23/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method ChkEspecie(cModelo) Class FISX001

	Local lRet	:= .F.	 
	If cModelo $ "01#02#04#06#07#08#09#10#11#13#18#21#26#28#29#22#2D#55#65#57#59#63"+Iif(Year(Self:dDtIni)>=2020,"#66","")+"#67#1B#8B#  "
		lRet := .T.
	EndIF	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkCFOP()
Método que verifica se o CFOP está previsto na geração
da EFD Contribuições

@author Erick G. Dias
@param 		Value - CFOP
@return	lRet - Retorna se CFOP está dentro dos previstos para processar EFD 
@since 23/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method ChkCFOP(Value) Class FISX001

	Local lRet	:= .F.

	If (Value$Self:aCFOPs[01] .Or. Value$Self:aCFOPs[03]) .AND. !(Value$Self:aCFOPs[02])
		lRet	:= .T.
	EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DefRegime()
Função que define o regime da operação

@author Erick G. Dias
@since 29/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method DefRegime() Class FISX001

	If Self:cRegimeApu == '1'
		//Regime da operação é Não Cumulativo
		Self:cRegimeOpe := '1'
	ElseIF Self:cRegimeApu $ '2/3/'
		//Regime da operação é cumulativo
		Self:cRegimeOpe := '2'
	ElseIF Self:cRegimeApu == '4'
		//Regime da operação será definido através do parâmetro MV_M996TPR
		Self:cRegimeOpe := Self:cTpReg
	EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CodCon()
Função que irá gerar o código da Contribuição, para ser processado na
apuração.

@author Erick G. Dias
@return	lRet - Retorna o Código da Contribuição já processado. 
@since 23/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method CodCon () Class FISX001
Self:cCodConCrd	:= ''
Do Case

	//-------------------------------------------------------------------
	//OPERAÇÃO REFERENTE AO PROCESSAMENTO DE PIS SOBRE FOLHA DE SALAÁRIO.
	//-------------------------------------------------------------------
	Case Self:cPisFolha == '1'
			Self:cCodConCrd	:=	'99'
			Self:cPisFolha	:= ''
	//----------------------------------------------------------------------------
	//Operação com operações de Atividade Imobiliária
	//----------------------------------------------------------------------------
	Case Self:lAtvImob
		IF Self:cRegimeOpe == '1'//Não Cumulativo terá código 04
			Self:cCodConCrd	:=	'04'
		ElseIF Self:cRegimeOpe == '2'//Cumulativo terá c[odigo 74
			Self:cCodConCrd	:=	'54'
		EndIf
	//----------------------------------------------------------------------------
	//Operação com Sociedade em Conta Participação
	//----------------------------------------------------------------------------
	Case Self:lSCP
		IF Self:cRegimeOpe == '1'//Não Cumulativo terá código 71
			Self:cCodConCrd	:=	'71'
		ElseIF Self:cRegimeOpe == '2'//Cumulativo terá c[odigo 72
			Self:cCodConCrd	:=	'72'
		EndIf
	//----------------------------------------------------------------------------		
	//Tributável alíquota básica
	//----------------------------------------------------------------------------
	Case Self:cCst == '01'
		IF Self:cRegimeOpe == '1'//Não Cumulativo terá código 01
			Self:cCodConCrd	:=	'01'
		ElseIF Self:cRegimeOpe == '2'//Cumulativo terá código 51
			Self:cCodConCrd	:=	'51'
		EndIf
	//----------------------------------------------------------------------------
	//Tributável alíquota diferenciada
	//----------------------------------------------------------------------------
	Case Self:cCst == '02'
		IF Self:cRegimeOpe == '1'//Não Cumulativo terá código 02
			Self:cCodConCrd	:=	'02'
		ElseIF Self:cRegimeOpe == '2'//Cumulativo terá código 52
			Self:cCodConCrd	:=	'52'
		EndIf
	
	//----------------------------------------------------------------------------
	//Tributável alíquota em reais
	//----------------------------------------------------------------------------	
	Case Self:cCst == '03'
		IF Self:cRegimeOpe == '1'//Não Cumulativo terá código 03
			Self:cCodConCrd	:=	'03'
		ElseIF Self:cRegimeOpe == '2'//Cumulativo terá código 53
			Self:cCodConCrd	:=	'53'
		EndIf
	
	//----------------------------------------------------------------------------
	//Tributável por Substituição Tributária com alíquota maior que zero
	//----------------------------------------------------------------------------	
	Case Self:cCst == '05' .AND. Self:nAlqST >0
		If Self:lVendMan //Substituição Tributária com Venda para Manaus terá CST 32
			Self:cCodConCrd	:= '32'
		Else
			Self:cCodConCrd	:= '31'	 //Se não for venda para Manaus então terá código 31
		EndIF
		
EndCase

Return Self:cCodConCrd

//-------------------------------------------------------------------
/*/{Protheus.doc} AgrpContr()

@author Erick G. Dias
@return	lRet - Retorna o Código da Contribuição já processado. 
@since 23/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method AgrpContr(Value) Class FISX001
	Local lSTMoto	:= .F.
	Local nRecMoto	:= Self:nReceita
	Local cRegime	:= ""
	
	Self:DefRegime()
	cRegime	:= Self:cRegimeOpe

	IF (Self:cRegimeOpe == '2' .Or. (Self:cCSt == '05' .And. Self:nAlqST > 0 )) .AND. Self:cTNatRec  == '4312' .AND. SubStr(Self:cCNatRec,1,2) $ '20/30' .AND. aModNot(Self:cEspecie) $'01/55'
		lSTMoto	:= .T.
		nRecMoto	:= Self:nReceita
		Self:nReceita	:= 0
		Self:cRegimeOpe := '2' //Muda regime para processar ST no regime cumulativo 
	EndIF
			
	IF Self:cCSt == '03'
		Self:OperPauta()		
	EndIF
	
	If Self:cCst $ '01/02/03'  .OR. (Self:cCSt == '05' .And. Self:nAlqST > 0 ) .OR. Self:cPisFolha == '1'
	//Operações tributadas
		Self:CodCon ()//Gera código da Contribuição
		Self:ChvEFD()	//Grava relacionamento da EFD
		Self:GrvDebPC() //Grava na tabela de débito de PIS e COFINS
	ElseIF Self:cBlocoI <> '1'
		Self:GrvRecNT()
	EndIF	
	
	Self:cpauta := '2' 
	
	//Verificar aqui se deverá processar substituição tributária de motocicleta adicionando cst 01
	IF lSTMoto
		Self:cRegimeOpe := cRegime //retorna regime de processamento
		Self:cCSt		:= '01'
		Self:nReceita	:= nRecMoto
		Self:CodCon ()//Gera código da Contribuição
		Self:ChvEFD()	//Grava relacionamento da EFD
		Self:GrvDebPC() //Grava na tabela de débito de PIS e COFINS		
	EndIF
	
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ChvEFD()
Método responsável pela gravação do relacionamento das informações
da EFD.

@author Erick G. Dias 
@since 23/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method ChvEFD() Class FISX001

	Local nAliquota:= 0
	Local nPos	  := 0
	Local cChave	  := ''
	local cDebCred	:= Iif(Len(Alltrim(Self:cCodConCrd))==2 ,'1' ,'2' ) //se len igual a 2, débito, se não crédito

	nAliquota:= Iif(Self:cCst == '05',Self:nAlqST,Self:nAlq)
	Self:cCodConCrd	:= PadR(Self:cCodConCrd,3,"")
	Self:cOrigem    := PadR(Self:cOrigem,1)
	
	cChave	:= dTos(Self:dDtIni)+Self:cTrib+Self:cRegimeOpe+Self:cCodConCrd+cDebCred+Self:cOrigem+str(nAliquota,8,4)	
	nPos:=aScan(Self:aChave,{|aX| aX[1]==Self:BuscaxFil('CKZ') .AND. aX[8] ==cChave .AND. aX[10] == Self:cConsl})

	IF nPos == 0
		aAdd(Self:aChave, {})
		nPos := Len(Self:aChave)
		aAdd (Self:aChave[nPos], Self:BuscaxFil('CKZ'))
		aAdd (Self:aChave[nPos], Self:dDtIni)
		aAdd (Self:aChave[nPos], Self:cTrib)
		aAdd (Self:aChave[nPos], nAliquota)
		aAdd (Self:aChave[nPos], Self:cCodConCrd)		
		aAdd (Self:aChave[nPos], Self:cOrigem)
		aAdd (Self:aChave[nPos], Self:cRegimeOpe)
		aAdd (Self:aChave[nPos], cChave)
		aAdd (Self:aChave[nPos], cDebCred)		
		aAdd (Self:aChave[nPos], Self:cConsl)		
	EndIF

	Self:cIdEFD:= cChave

Return


Method ClsItem() Class FISX001
	
	Self:nVlPauta   := 0
	Self:nQtde      := 0
	Self:nValMajora := 0
	Self:nAlqMajora := 0
	Self:cPauta     := '2'
	Self:cTpReg     := ''
	Self:cConta     := ''
	Self:cRegime    := ''
	Self:cOrigem    := ''
	Self:cCodBcc    := ''
	Self:cAlqBas    := ''
	Self:cCfop      := ''
	Self:cEspecie   := ''
	Self:cTNatRec   := ''
	Self:cCNatRec   := ''
	Self:cGNatRec   := ''
	Self:cPisFolha  := ''
	Self:lSCP       := .F.
	Self:lAtvImob   := .F.
	Self:lVendMan   := .F.
	Self:lImport    := .F.
	Self:lExport    := .F.
	Self:dDNatRec   := CTod(" / / ")
	Self:lImob      := .F.
	Self:nAlqST     := 0	

Return




//-------------------------------------------------------------------
/*/{Protheus.doc} GrvDebPC()
Método responsável pela gravação da tabela de débito de PIS e COFINS.

@author Erick G. Dias 
@since 23/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method GrvDebPC() Class FISX001

	Local nBase	:= Iif(Self:cCSt=='05',Self:nBaseST,Self:nBase)
	Local nValor  := Iif(Self:cCSt=='05',Self:nValST,Self:nVal)
	Local nPos	:= 0	
	Local nPosF3J	:= 0	
	local cChvF3J	:= ''
	
	nPos:=aScan(Self:aCKS,{|aX| aX[1]==Self:BuscaxFil('CKS').AND. aX[3]==Self:cIdEFD .AND. aX[11] == Self:cConsl})

	IF nPos == 0
		aAdd(Self:aCKS, {})
		nPos := Len(Self:aCKS)
		aAdd (Self:aCKS[nPos], Self:BuscaxFil('CKS'))
		aAdd (Self:aCKS[nPos], Self:dDtIni)
		aAdd (Self:aCKS[nPos], Self:cIdEFD)
		aAdd (Self:aCKS[nPos], Self:cTrib)
		aAdd (Self:aCKS[nPos], Self:cPauta)		
		aAdd (Self:aCKS[nPos], Self:nReceita)
		aAdd (Self:aCKS[nPos], nBase)
		aAdd (Self:aCKS[nPos], nValor)
		aAdd (Self:aCKS[nPos], nValor) 
		aAdd (Self:aCKS[nPos], Self:nVlExclFol)
		aAdd (Self:aCKS[nPos], Self:cConsl)		
		
	Else
		Self:aCKS[nPos][6]	+= Self:nReceita
		Self:aCKS[nPos][7]	+= nBase
		Self:aCKS[nPos][8]	+= nValor
		Self:aCKS[nPos][9]	+= nValor
		Self:aCKS[nPos][10]	+= Self:nVlExclFol
		
	EndIF

	nPosF3J:=aScan(Self:aF3J,{|aX| aX[1]==Self:cTrib 					.AND.;
									   aX[2]==Self:cRegimeOpe 			.AND.;
									   aX[3]==Self:cCst 				.AND.;
									   aX[4]==Alltrim(Self:cCodConCrd) 	.AND.;
									   aX[5]==Self:cTNatRec 			.AND.;
									   aX[6]==Self:cCNatRec   })	
	IF nPosF3J == 0
		aAdd(Self:aF3J, {})
		nPosF3J := Len(Self:aF3J)		
		aAdd (Self:aF3J[nPosF3J], Self:cTrib)
		aAdd (Self:aF3J[nPosF3J], Self:cRegimeOpe)		
		aAdd (Self:aF3J[nPosF3J], Self:cCst)		
		aAdd (Self:aF3J[nPosF3J], Alltrim(Self:cCodConCrd))
		aAdd (Self:aF3J[nPosF3J], Self:cTNatRec)
		aAdd (Self:aF3J[nPosF3J], Self:cCNatRec)
		aAdd (Self:aF3J[nPosF3J], nValor) 
		aAdd (Self:aF3J[nPosF3J], '')
	Else
		Self:aF3J[nPosF3J][7] += nValor
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcRecNB()
Método que fará o processamento dos totais das receitas e dos totais das
receitas não tributadas, agrupando por bloco e período.

@author Erick G. Dias 
@since 09/10/2019
@version 12.1.25

/*/
//-------------------------------------------------------------------
Method ProcRecNB(nTotal, nRecNBruta) Class FISX001

Local nPos 			:= 0
Default nTotal		:= 0
Default nRecNBruta	:= 0

//Somente processará se o bloco estiver preenchido
IF !Empty(Self:cBloco) .AND. Self:cCst $ "01/02/03/04/05/06/07/08/09" .AND. Self:cBloco <> "P" //As receitas do bloco P não serão consideradas aqui, o registro 0900 não tem receita do bloco P
	
	//Acumula valores por bloco
	nPos := aScan(Self:aTotRecNB,{|x| x[1] == Self:cBloco})

	IF nPos == 0
		//Adicionar informações no array	
		aAdd(Self:aTotRecNB, {})
		nPos := Len(Self:aTotRecNB)
		aAdd (Self:aTotRecNB[nPos], Self:cBloco )//Bloco
		aAdd (Self:aTotRecNB[nPos], nTotal )//Receita
		aAdd (Self:aTotRecNB[nPos], nRecNBruta )//Receita Não Bruta
	Else
		Self:aTotRecNB[npos][2] += nTotal //Receita
		Self:aTotRecNB[npos][3] += nRecNBruta //Receita Não Bruta
	EndIF

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvResCST()
Método responsável pela gravação das operações por CST,
para termos o resumo de todas operações por cada código de CST

@author Erick G. Dias 
@since 24/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method GrvResCST(lRecBrut, cBloco) Class FISX001
Local nPos	:= 0
Default lRecBrut	:= .T.
Default cBloco	:= ""

//Atribuo aqui o bloco para a propriedade da classe
Self:cBloco := cBloco

nPos:=aScan(Self:aCL0,{|aX| aX[1]==Self:BuscaxFil('CL0').AND. aX[3]==Self:cCst .AND. aX[8] == Self:cConsl .AND. aX[9] == Self:cOrigem  })

IF nPos == 0
	aAdd(Self:aCL0, {})
	nPos := Len(Self:aCL0)
	aAdd (Self:aCL0[nPos], Self:BuscaxFil('CL0'))
	aAdd (Self:aCL0[nPos], Self:dDtIni)
	aAdd (Self:aCL0[nPos], Self:cCst)		
	If Self:cRegimeOpe == '1'
		aAdd (Self:aCL0[nPos], Iif(Self:cPauta =='1',0, Self:nBase))
		aAdd (Self:aCL0[nPos], Self:nReceita)
		aAdd (Self:aCL0[nPos], 0)
		aAdd (Self:aCL0[nPos], 0)			
	Else
		aAdd (Self:aCL0[nPos], 0)
		aAdd (Self:aCL0[nPos], 0)
		aAdd (Self:aCL0[nPos], Iif(Self:cPauta =='1',0,Self:nBase))
		aAdd (Self:aCL0[nPos], Self:nReceita)
	EndIF
	aAdd (Self:aCL0[nPos], Self:cConsl)					
	aAdd (Self:aCL0[nPos], Self:cOrigem)	
Else
	If Self:cRegimeOpe == '1'
		Self:aCL0[nPos][4]	+= Iif(Self:cPauta =='1',0,Self:nBase)
		Self:aCL0[nPos][5]	+= Self:nReceita			
	Else
		Self:aCL0[nPos][6]	+= Iif(Self:cPauta =='1',0,Self:nBase)
		Self:aCL0[nPos][7]	+= Self:nReceita
	EndIF
EndIF

//Existem Situações onde algumas receitas não deverão ser totalizadas nas receitas brutas.
IF lRecBrut
	Self:AcumRecBru()
Else
	//Aqui é uma receita, porém não foi considerada como receita bruta.
	Self:ProcRecNB(Self:nReceita, Self:nReceita)
EndIF

 // Quando for Item de CST PIS COF = 05 ST não limpa objeto para processamento posterior do item com CST 01
If !(Self:cRegimeOpe == '2' .AND. Self:cCSt == '05' .AND. Self:cTNatRec  == '4312' .AND. SubStr(Self:cCNatRec,1,2) $ '20/30')
	Self:ClsItem()
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Clear()
Método que limpa variáveis

@author Erick G. Dias 
@since 24/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method Clear() Class FISX001

	Self:nBase      := 0
	Self:nVal       := 0
	Self:nAlq       := 0
	Self:nBaseST    := 0
	Self:nValST     := 0
	Self:nValipi    := 0
	Self:nAlqST     := 0
	Self:cCst       := ''
	Self:cCodConCrd := ''
	Self:cOrigem    := ' '
	Self:cIdEFD     := ''
	Self:lSCP       := .F.
	Self:lAtvImob   := .F.
	Self:lVendMan   := .F.
	Self:nTotBase   := 0
	Self:nBaseCum   := 0
	Self:nBaseNCum  := 0
	Self:nVlPauta   := 0
	Self:nValMajora := 0
	Self:nAlqMajora := 0
	Self:cCodBcc    := ''
	Self:cAlqBas    := ''
	Self:cIndCre    := '0'
	Self:cDescri    := ''
	Self:cTpReg     := ''	
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Clear()
Método que limpa variáveis

@author Erick G. Dias 
@since 24/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method ClearTab(aAlias, lExcluCon) Class FISX001

	Local cAliasDel	:= ""
	Local nPos	:= 0
	Local lDel := .T.
	Local lCpoOk
	Local cTabfilApu := "CKY|CKV|CL2|CKX|CL1|CL5|CL6|CL7|F0T"
	Local lDifer		:= .F. //indica o processamento das tabelas CFA e/ou CFB
	Local cPerApu		:= Substr(DTOS(Self:dDtIni ),5,2)+Substr(DTOS(Self:dDtIni ),1,4)
	Local cChave		:= ''
	Local lNewDIf		:= FindFunction("ISA001NDIF") .AND. ISA001NDIF()
	Local cCmpPer		:= ""
	Local lConsol		:= .F.
	Default lExcluCon 	:= .F.
	

	For nPos	:= 1 To Len(aAlias)
		If aAlias[nPos][2]
			cAliasDel :=aAlias[nPos][1]
			dbSelectArea(cAliasDel)
			lDifer	:= cAliasDel$"CFA|CFB"
			cCampo := cAliasDel+Iif(cAliasDel$cTabFilApu,"_FILAPU","_FILIAL")
			lCpoOk := cAliasDel $ cTabFilApu .And. ((cAliasDel)->(FieldPos(cCampo)) > 0) 
			lConsol := ((cAliasDel)->(FieldPos(cAliasDel+"_CONSOL"))) > 0 
			
			// Tratamento p/ exclusao dos registros anteriores à criacao do campo _FILAPU.
			// Caso este campo esteja em branco os dados nao serao excluidos corretamente,
			// ocasionando duplicidade de valores no arquivo. Futuramente esta chamada
			// poderá ser retirada pois nao haverao mais registros com este campo em branco. 
			If lCpoOk				
				DelFilApu(cAliasDel, dTos(Self:dDtIni),lConsol)				
			EndIf
			 
			If cAliasDel$cTabFilApu .And. lCpoOk		
				If cAliasDel $ "CL1" 
					If SIX->(dbSeek("CL13"))
						(cAliasDel)->(dbSetOrder(3))
					Else
						(cAliasDel)->(dbSetOrder(1))
					EndIf
				ElseIf cAliasDel == "F0T"
					(cAliasDel)->(dbSetOrder(3))
				Else
					If SIX->(dbSeek(cAliasDel+"2"))
						(cAliasDel)->(dbSetOrder(2))
					Else
						(cAliasDel)->(dbSetOrder(1))
					EndIf
				EndIf	
			Else
				If cAliasDel$"CL4"
					If SIX->(dbSeek("CL43"))
						(cAliasDel)->(dbSetOrder(3))
					Else
						(cAliasDel)->(dbSetOrder(2)) // Utiliza indice 2 =(CL4_FILIAL+CL4_CHV) campo chave que é composto pelo periodo conforme chave 3 = (CL4_FILIAL+DTOS(CL4_PER))
					EndIf						
				Else
					(cAliasDel)->(dbSetOrder(1))
				EndIf
			Endif	

			If lDifer
				cChave	:= Self:BuscaxFil(aAlias[nPos][1])+cPerApu
			Else
				cChave	:= Self:BuscaxFil(aAlias[nPos][1])+dTos(Self:dDtIni)			
			EndIf
			
			If (aAlias[nPos][1])->(MsSeek( cChave  ))
				
				cCampo := IIf(lCpoOk, cCampo, cAliasDel+"_FILIAL")
				
				cCmpPer	:= ""
				If lDifer
					cCmpPer	:= cAliasDel+'_PERAPU'
				ElseIF cAliasDel == "F2Z"
					cCmpPer	:= cAliasDel+'_PERAPU'				
				Else
					cCmpPer	:= cAliasDel+'_PER'
				EndIF

				While (cAliasDel)->(!Eof()) .And. ;
						(cAliasDel)->(&(cCampo)==xFilial(cAliasDel).And. ;
						  Iif(lDifer, &(cCmpPer)== cPerApu , (&(cCmpPer)>=Self:dDtIni .And. &(cCmpPer)<=Self:dDtfIN)) ) //Data Final

						  
					lDel := .T.
					If lConsol .and. lExcluCon .AND. (cAliasDel)->&(cAliasDel+'_CONSOL') == '2' // &(cAliasDel+'_CONSOL') == '2' //Operação não agru-pada
						//Se entrou aqui é porq usuário está realizando exclusão da apuração agrupada gerada pelo 
						 //sistema. Somente irá delettar se o campo _CONSOL for igua a 1. Se for igual a 2 não deverá exclur.
						lDel := .F.
					EndIF	

					If cAliasDel == "F3P" .And. F3P->(FieldPos("F3P_AJMANU")) > 0 .And. F3P->F3P_AJMANU == "1"			
						lDel := .F.
					EndIf

					If lDel 
					
						IF aAlias[nPos][1] == 'CKZ'
							DelInfTab('CLA',CKZ->CKZ_ID,lExcluCon)
						ENdIF
						
						IF cAliasDel == 'F0T' .AND. !lNewDIf
							lDel 	:= !F0T->F0T_TIPO $ '4/5' 
						EndIF

						If cAliasDel == "F2Z" .AND. F2Z->F2Z_ORIG == '1'
							//Não deletará as linhas inseridas manualmente pelo usuário.
							lDel	:= .F.
						EndIF

						IF lDel
							RecLock(cAliasDel,.F.)
							(cAliasDel)->(dbDelete())
							MsUnLock()
							(cAliasDel)->(FKCommit())
						Endif
					EndIF
	
					(cAliasDel)->(DbSkip ())
				EndDo
		
			EndIF
		EndIf
	Next nPos

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AgrpCred()
Método que agrupa os valores das operações de entradas, operações com direito
ou sem direito ao crédito

@author Erick G. Dias 
@since 25/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method AgrpCred() Class FISX001

	Self:cRegimeOpe := '1'	
	
	//Faz a diferença se houver valor de crédito majorado
	IF Self:nValMajora > 0
		Self:nVal -= Self:nValMajora
	EndIF	
	
	//Faz a diferença se houver alíquota majorada
	If Self:nAlqMajora > 0
		Self:nAlq -= Self:nAlqMajora
	EndIF

//Verifica se é alíquota básica
	If Self:nAlq == 0.65 .OR. Self:nAlq == 1.65 .OR. Self:nAlq == 3 .OR. Self:nAlq == 7.60
	//Alíquota básica
		Self:cAlqBas := '1'
	Else
   	//Alíquota diferenciada
		Self:cAlqBas := '2'
	EndIf

//Busca descrição do código da base de cálculo do crédito na consulta padrão.
	If (SX5->(MsSeek (xFilial ("SX5")+"MZ"+Self:cCodBcc)))
		Self:cDescri	:=	SX5->X5_DESCRI
	Endif

//--------------------------------------------------------
//CRÉDITO VINCULADO A RECEITA TRIBUTADA NO MERCADO INTERNO
//--------------------------------------------------------
	If Self:cCst $ '50|60|53|63|54|64|56|66'
		Self:cCodConCrd:= '1'
		Self:GrvCred()
	EndIF

//------------------------------------------------------------
//CRÉDITO VINCULADO A RECEITA NÃO TRIBUTADA NO MERCADO INTERNO
//------------------------------------------------------------
	If Self:cCst $ '51|61|53|63|55|65|56|66'
		Self:cCodConCrd:= '2'
		Self:GrvCred()
	EndIF

//-----------------------------------------
//CRÉDITO VINCULADO A RECEITA DE EXPORTAÇÃO
//-----------------------------------------
	If Self:cCst $ '52|62|54|64|55|65|56|66'
		Self:cCodConCrd:= '3'
		Self:GrvCred()
	EndIF
		
//-----------------------------------------
//CRÉDITO REGISTRO F800
//-----------------------------------------
	If Self:lCredSBse		
		Self:GrvCred()
	EndIF
	Self:nValMajora 	:= 0
	Self:nAlqMajora	:= 0

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CodCred()
Método que irá definir os dois últimos dígitos para poder compor o código do crédito

@author Erick G. Dias 
@since 11/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method CodCred() Class FISX001

Local cCod	:= ''
/*
IF Self:cCodBcc	== '18'
//-----------------------------------------------------------
//Código da base de cálculo 18, que trata estoque de abertura
//-----------------------------------------------------------
	cCod	+=	'04'
	
ElseIf Self:cCst $ '60|61|62|63|64|65|66'
	//-------------------------
	//CST de Credito Presumido
	//-------------------------
	
	IF Substr(Self:cTNatRec,1,1) $ "439" .AND. Self:cCst  <> '67'		
		cCod	+=	'07' //Presumido da Agroindustria
	Else
		cCod	+=	'06' //Outros Créditos Presumidos
	EndIF

Elseif Self:cPauta =='1'
//-----------------------------
//Valor por unidade de produto
//-----------------------------
	cCod	+=	'03'

ElseIf Self:cAlqBas == '1'
//-----------------------------
//Aliquota basica
//-----------------------------
	cCod 	+=	Iif(Self:lImport,'08','01')

Else
//-----------------------------
//Aliquota diferenciada
//-----------------------------
	cCod	+=	Iif(Self:lImport,'08','02')
	
EndIf
*/
//Codigo de Base de Calculo do Credito 15 - Atividade Imobiliaria - Custo Incorrido de Unidade Imobiliaria
//Codigo de Base de Calculo do Credito 16 - Atividade Imobiliaria - Custo Orcado de unidade nao concluida
If Self:cCodBcc $ "15/16"
	
	//Atividade Imobiliaria
	cCod	+=	"09"
				
//Codigo de Base de Calculo do Credito 18 - Estoque de abertura de bens
Elseif Self:cCodBcc == "18"
	
	//Estoque de Abertura
	cCod	+=	"04"
		
//Codigo da Situacao Tributaria 6x (exceto 67) - Credito Presumido - Operacao de Aquisicao Vinculada Exclusivamente a Receita Tributada no Mercado Interno		
Elseif Substr(Self:cCst ,1,1) $ "6" .And. Self:cCst  <> "67"
    
	If Substr(Self:cTNatRec,1,1) $ "439" .or. Self:lAgrIndust
		cCod	+=	"06" 		//Presumido da Agroindustria
	Else
		cCod	+=	"07" 		//Outros Créditos Presumidos
	EndIf

//Importacao	
Elseif Self:lImport

	//Importacao
		cCod	+=	"08" 
		
//Operacoes com Unidade de Produto
Elseif  Self:cPauta =='1'
	
	//Codigo da Natureza da Receita iniciado por 7		
	If Substr(Self:cTNatRec,1,1) == "7"
	
	    //Aquisicao Embalagens para revenda
		cCod	+=	"05"
			
	Else
	    //Aliquota por Unidade de Produto
		cCod	+=	"03"
	Endif

//Aliquota basica
ElseIf Self:cAlqBas == '1'

    //Aliquota Basica
	cCod	+=	"01"
	
Else

    //Aliquota Diferenciada
	cCod	+=	"02"
EndIf

Return cCod
//-------------------------------------------------------------------
/*/{Protheus.doc} GrvCred()
Método que irá calcular valores para poder gravar os créditos nas tabelas 
da apuração da EFD.

@author Erick G. Dias 
@since 25/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method GrvCred() Class FISX001

local cGrupo   := ''
Local nBaseOri := Self:nBase
Local nValCred := 0
Local lValori  := .F.
Local lIndAprop := GetNewPar("MV_RATPROP",.F.)

If !Self:lCredSBse // F800 Pega codigo digitado pelo usuário
	cGrupo	:= Self:cCodConCrd
	Self:cCodConCrd += Self:COdCred()	
Endif

//Cálculo para obter total da base bruta, base Não cumulativa, base cumulativa e base para apuração.
Self:nTotBase	:= Self:nBase
IF Self:cRegimeApu == '4' .and. SELF:CPAUTA == '2' .And. !lIndAprop //Cumulativo e Não Cumulativo
	Self:nBaseCum		:= Round(Self:nTotBase *  Self:aRecBruta[1][4]  / Self:aRecBruta[1][5],2)
	Self:nBaseNCum	:= Self:nTotBase - Self:nBaseCum
	Self:nBase		:= Self:nBaseNCum
Else
//Regime exclusivamente Não Cumulkativo, neste caso a base integral será Não Cumulativa.
	Self:nBaseNCum	:= Self:nTotBase
	Self:nBase		:= Self:nTotBase
EndIF



//-----------------------------------------------------------
//IRÁ FAZER CLASSIFICAÇÃO PARA CST COM RECEITA EM COMUM
//CONSIDERANDO OS TOTAIS DE RECEITAS DAS OPERAÇÕES DE SAÍDAS
//-----------------------------------------------------------

Self:nBase := Self:nBase * Self:CalcBAseRC(cGrupo,lIndAprop)
	
IF self:nVlPauta == 0	//Se não for paura realiza conta com percentual
	
	nValCred := (Self:nBase * Self:nAlq)/100 
	
	If (nValCred == 0 .And. Self:lCredSBse) .Or. Self:lAtvImob // F800 // PE - SPDPCIMOB - F200 F205 F210
		nValCred := Self:nval
	Elseif nValCred > 0 .and. Self:nBase == nBaseOri
		//Se não Houve alteração da base, segue com valor original. / evita problemas de arredondamento.
		nValCred := Self:nVal
		lValori := .T.
	EndIf

	If Self:lDeprAtv .or. lValori
		Self:nVal	:= nValCred
	Else
		Self:nVal	:= Round(nValCred,2)
	EndIf
	
Else
	//Caso seja pauta então não utiliza percentual, somente quantidade  multiplicado pela pauta
	Self:nVal	:= Round((Self:nBase * Self:nAlq),2)
EndIF

//Grava relacionamento da EFD
Self:ChvEFD()	

//GRAVA VALORES DE CRÉDITOS
Self:GrvCredPC()

//Retorna valor da base de cálculo original para caso houver mais código de crédito para serem classificados
Self:nBase	:= nBaseOri 

Return


Method CalcBAseRC(cGrupo,lIndAprop) Class FISX001
Local nValor	:= 1
Default lIndAprop	:= .F.

//Se for apropriação direta, irá verificar se existe informações preenchidas pelo usuário no parâmetro MV_PERCAPD, 
//se não houver irá utilizar percentuais do registo 0111, igual faz para rateio proporcional.
IF lIndAprop .AND. Self:aPERCAPD[1] + Self:aPERCAPD[2]+ Self:aPERCAPD[3] == 100 
	lIndAprop	:= .T.
Else
	lIndAprop	:= .F.
EndIF

If Self:cCst $ "53/63"
	If cGrupo == '1'
		IF !lIndAprop
			nValor := Self:aRecBruta[1][1] /(Self:aRecBruta[1][1] + Self:aRecBruta[1][2])
		Else
			nValor := (Self:aPERCAPD[1] * 100 / (Self:aPERCAPD[1] + Self:aPERCAPD[2] ) )/100
		EndIF
	Else					
		IF !lIndAprop		
			nValor :=  Self:aRecBruta[1][2] / (Self:aRecBruta[1][1] + Self:aRecBruta[1][2])
		Else
			
			nValor := (Self:aPERCAPD[2] * 100 / (Self:aPERCAPD[1] + Self:aPERCAPD[2] ) ) / 100		
		EndIF
	EndIf 

ElseIf Self:cCst $ "54/64"  
	If cGrupo == '1'
		IF !lIndAprop
			nValor := Self:aRecBruta[1][1] /(Self:aRecBruta[1][1] + Self:aRecBruta[1][3])
		Else
			nValor := (Self:aPERCAPD[1] * 100 / (Self:aPERCAPD[1] + Self:aPERCAPD[3] )) / 100
		EndIF
	Else
		IF !lIndAprop
			nValor :=  Self:aRecBruta[1][3] / (Self:aRecBruta[1][1] + Self:aRecBruta[1][3])
		Else
			nValor := (Self:aPERCAPD[3] * 100 / (Self:aPERCAPD[1] + Self:aPERCAPD[3] )) / 100
		EndIF
	EndIf
ElseIf Self:cCst $ "55/65"  
	If cGrupo == '2'
		IF !lIndAprop
			nValor :=  Self:aRecBruta[1][2] /(Self:aRecBruta[1][2] + Self:aRecBruta[1][3])
		Else
			nValor := (Self:aPERCAPD[2] * 100 / (Self:aPERCAPD[2] + Self:aPERCAPD[3] )) / 100
		EndIF
	Else
		IF !lIndAprop
			nValor :=  Self:aRecBruta[1][3] / (Self:aRecBruta[1][2] + Self:aRecBruta[1][3])
		Else
			nValor := (Self:aPERCAPD[3] * 100 / (Self:aPERCAPD[2] + Self:aPERCAPD[3] )) / 100
		EndIf
	EndIf
ElseIf Self:cCst $ "56/66"  
	If cGrupo == '1'
		IF !lIndAprop
			nValor :=  Self:aRecBruta[1][1] /(Self:aRecBruta[1][1] + Self:aRecBruta[1][2] + Self:aRecBruta[1][3])
		Else
			nValor := Self:aPERCAPD[1] / 100
		EndIF
	Elseif cGrupo == '2'
		IF !lIndAprop
			nValor :=  Self:aRecBruta[1][2] / (Self:aRecBruta[1][1] + Self:aRecBruta[1][2] + Self:aRecBruta[1][3])
		Else
			nValor := Self:aPERCAPD[2] / 100
		EndIF
	Else
		IF !lIndAprop
			nValor :=  Self:aRecBruta[1][3] / (Self:aRecBruta[1][1] + Self:aRecBruta[1][2] + Self:aRecBruta[1][3])
		Else
			nValor := Self:aPERCAPD[3] / 100
		EndIF
	EndIf		
EndIF


Return nValor




//-------------------------------------------------------------------
/*/{Protheus.doc} GrvCredPC()
Método responsável pela gravação da tabela de crédito de PIS e COFINS.

@author Erick G. Dias 
@since 23/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method GrvCredPC() Class FISX001
Local nPos	:= 0
Local cChvCL8 := ""
Local cChvCL9 := ""

cChvCL8 := Self:BuscaxFil('CL8') + dToc(Self:dDtIni) + Self:cIdEFD + Self:cCodBcc + Self:cCst + Self:cIndCre + Self:cConsl
If Self:lBuild
	nPos := Self:FindHash(Self:oHashCL8,cChvCL8)
Else
	nPos := aScan(Self:aCL8,{|aX| aX[1]==  Self:BuscaxFil('CL8') .AND. aX[2] ==Self:dDtIni .AND. aX[3] ==Self:cIdEFD .AND. aX[5] ==Self:cCodBcc .AND. aX[6] ==Self:cCst .AND. aX[7] ==Self:cIndCre .AND. aX[11] == Self:cConsl})
EndIf
//Realiza primeira a gravação do registro na tabela pai
If nPos == 0
	aAdd(Self:aCL8, {})
	nPos := Len(Self:aCL8)
	aAdd (Self:aCL8[nPos], Self:BuscaxFil('CL8'))
	aAdd (Self:aCL8[nPos], Self:dDtIni)
	aAdd (Self:aCL8[nPos], Self:cIdEFD)
	aAdd (Self:aCL8[nPos], Self:cTrib)
	aAdd (Self:aCL8[nPos], Self:cCodBcc)
	aAdd (Self:aCL8[nPos], Self:cCst)
	aAdd (Self:aCL8[nPos], Self:cIndCre)
	aAdd (Self:aCL8[nPos], Self:nBase)
	aAdd (Self:aCL8[nPos], Self:nVal)
	aAdd (Self:aCL8[nPos], Self:nVal)		
	aAdd (Self:aCL8[nPos], Self:cConsl)	
	If Self:lBuild
		Self:AddHash(Self:oHashCL8,cChvCL8,nPos)
	EndIf
Else
	Self:aCL8[nPos][8]	+=	Self:nBase
	Self:aCL8[nPos][9]	+=	Self:nVal	
	Self:aCL8[nPos][10]	+=	Self:nVal	
EndIF

//Realiza depois gravação dos valores detalhados na tabela filho.

cChvCL9 := Self:BuscaxFil('CL9') + dToc(Self:dDtIni) + Self:cIdEFD + Self:cCodBcc + Self:cCst + Self:cPauta + Self:cConsl

If Self:lBuild
	nPos := Self:FindHash(Self:oHashCL9, cChvCL9)
Else
	nPos := aScan(Self:aCL9,{|aX| aX[1]==Self:BuscaxFil('CL9') .AND. aX[2] ==Self:dDtIni .AND. aX[3] ==Self:cIdEFD .AND. aX[5] ==Self:cCodBcc .AND. aX[6] ==Self:cCst .AND. aX[7] ==Self:cPauta .AND. aX[12] == Self:cConsl})
EndIf
If nPos == 0
	aAdd(Self:aCL9, {})
	nPos := Len(Self:aCL9)
	aAdd (Self:aCL9[nPos], Self:BuscaxFil('CL9'))
	aAdd (Self:aCL9[nPos], Self:dDtIni)
	aAdd (Self:aCL9[nPos], Self:cIdEFD)
	aAdd (Self:aCL9[nPos], Self:cCodBcc)
	aAdd (Self:aCL9[nPos], Self:cCst)
	aAdd (Self:aCL9[nPos], Self:cPauta)
	aAdd (Self:aCL9[nPos], Self:nTotBase)
	aAdd (Self:aCL9[nPos], Self:nBaseCum)
	aAdd (Self:aCL9[nPos], Self:nBaseNCum)
	aAdd (Self:aCL9[nPos], Self:nBase)	
	aAdd (Self:aCL9[nPos], Self:cDescri)
	aAdd (Self:aCL9[nPos], Self:cConsl)	
	If Self:lBuild
		Self:AddHash(Self:oHashCL9,cChvCL9,nPos)
	EndIf
Else
	Self:aCL9[nPos][7]	+=	Self:nTotBase
	Self:aCL9[nPos][8]	+=	Self:nBaseCum
	Self:aCL9[nPos][9]	+=	Self:nBaseNCum
	Self:aCL9[nPos][10]	+=	Self:nBase	
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AcumRecBru()
Método que acumula o valor de receita bruta das operações de saídas.

@author Erick G. Dias
@since 28/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method AcumRecBru(lCaixa) Class FISX001
	Local cCstNTrib		:= '04#06#07#08#09#49'
	Local lCumulativ	:= (Self:cRegimeOpe == "2")
	Local nExp			:= 0
	Local nTMI			:= 0
	Local nNTMI			:= 0
	Local nCum			:= 0
	Local cCSTRec 		:= '01/02/03/04/05/06/07/08/09'
	Default lCaixa		:= .F.

	If ( (aModNot(Self:cEspecie)$"  " .AND. LEN(Alltrim(Self:cCfop))<>4) .Or. (Self:lCupom) .or. (Self:cOrigem=='4')  .OR. ;
		 ((AllTrim(Self:cCfop)$Self:aCFOPs[01]) .AND. !(AllTrim(Self:cCfop)$Self:aCFOPs[02]) )).OR. (SubStr( Self:cCfop,2,3) == '949' .And. Self:cCst$cCSTRec) .OR.;
		 (Self:lImob)

		Do Case
		Case SubStr(Self:cCfop,1,1) == '7' .OR. (Alltrim(Self:cCfop)$"5501/5502/6501/6502") .OR. self:lExport
			nExp := Self:nRecBruta - Self:nValIcmsST - Self:nValIPI
		Case Self:cCst $ cCstNTrib .OR. (Self:cCst == '05' .AND. Self:nAlq == 0)
			// Self:cOrigem == "4" = Demais Documentos PIS/COFINS (FISA048)
			nNTMI := Iif(Self:cOrigem == "4", Self:nReceita, Self:nRecBruta - Self:nValIcmsST - Self:nValIPI)
		Case lCumulativ///(Self:nAlq == 0.65 .or. Self:nAlq  == 3) .AND. lCumulativ
			nCum := Self:nRecBruta - Self:nValIcmsST - Self:nValIPI
		OtherWise //Receita Não Cumulativa
			// Self:cOrigem == "4" = Demais Documentos PIS/COFINS (FISA048)
			nTMI := Iif(Self:cOrigem == "4", Self:nReceita, Self:nRecBruta - Self:nValIcmsST - Self:nValIPI)
		EndCase
		
		Self:aRecBruta[1][1]+= nTMI 	//Receita Tributada no mercado interno
		Self:aRecBruta[1][2]+= nNTMI	//Receita Não Tributada no Mercado Interno
		Self:aRecBruta[1][3]+= nExp		//Receita de Exportação
		Self:aRecBruta[1][4]+= nCum		//Receita Cumulativa
		Self:aRecBruta[1][5]+= Self:nReceita
				
		//Para processamento do regime de caixa as informações já foram processadas por meio do método GrvResCST, não será necessário processar aqui novamente
		If !lCaixa
			//Aqui a receita que não é bruta é a parcela do ICMS ST
			Self:ProcRecNB(Self:nReceita, 0)
		EndIF
		
	Else
     	//Para processamento do regime de caixa as informações já foram processadas por meio do método GrvResCST, não será necessário processar aqui novamente
		 If !lCaixa
			//Aqui toda a receita integral não é bruta
			Self:ProcRecNB(Self:nReceita, Self:nReceita)
		EndIF

	EndIF
	Self:lImob	:= .F.
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvRecNB()
Método que fará a gravação da tabela CIC, das receitas totais e receitas brutas

@author Erick G. Dias
@since 09/10/2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Method GrvRecNB() Class FISX001

Local nCont	:= 0

If AliasIndic("CIC")
	dbSelectArea('CIC')
	CIC->(dbSetOrder(1))

	//Laço nas receitas totalizadas por bloco
	For nCont := 1 to Len(Self:aTotRecNB)
		If !CIC->(MSSEEK(Self:BuscaxFil('CIC')+dTos(Self:dDtIni)+Self:cConsl+Self:aTotRecNB[nCont][1]))
			//Registro ainda não existe, será incluído
			RecLock('CIC',.T.)
			CIC->CIC_FILIAL		:=	Self:BuscaxFil('CIC')
			CIC->CIC_PER		:=	Self:dDtIni
			CIC->CIC_CONSOL		:=	Self:cConsl
			CIC->CIC_BLOCO		:=	Self:aTotRecNB[nCont][1]
			CIC->CIC_REC		:=	Self:aTotRecNB[nCont][2]
			CIC->CIC_RECNB		:=	Self:aTotRecNB[nCont][3]
			MsUnLock()
		Else
			RecLock('CIC',.F.)
			CIC->CIC_REC		+=	Self:aTotRecNB[nCont][2]
			CIC->CIC_RECNB		+=	Self:aTotRecNB[nCont][3]
			MsUnLock()
		EndIF
	Next nCont
	Self:aTotRecNB	:= {}

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvRecBru()
Método que realiza a gravação dos valores de receita bruta do período 
e filial.

@author Erick G. Dias
@since 28/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method GrvRecBru() Class FISX001

	dbSelectArea('CKU')
	CKU->(dbSetOrder(1))

//Realiza primeira a gravação do registro na tabela pai
	If !CKU->(MSSEEK(Self:BuscaxFil('CKU')+dTos(Self:dDtIni)+Self:cConsl+Self:cOrigem))
	//INclui nova referência para combinação de data, tributo, indicador do crédito e chave da EFD.
		RecLock('CKU',.T.)
		CKU->CKU_FILIAL	:=	Self:BuscaxFil('CKU')
		CKU->CKU_PER		:=	Self:dDtIni
		CKU->CKU_RTNC		:=	Self:aRecBruta[1][1]
		CKU->CKU_RNTNC	:=	Self:aRecBruta[1][2]
		CKU->CKU_EXP		:=	Self:aRecBruta[1][3]
		CKU->CKU_RTC		:=	Self:aRecBruta[1][4]
		CKU->CKU_CONSOL	:=	Self:cConsl	
		CKU->CKU_ORIGEM	:=	Self:cOrigem		
		MsUnLock()
	Else
		RecLock('CKU',.F.)
		CKU->CKU_RTNC		+=	Self:aRecBruta[1][1]
		CKU->CKU_RNTNC	+=	Self:aRecBruta[1][2]
		CKU->CKU_EXP		+=	Self:aRecBruta[1][3]
		CKU->CKU_RTC		+=	Self:aRecBruta[1][4]
		MsUnLock()
	EndIF

	Self:aRecBruta	:={}
	AADD(Self:aRecBruta,{0,0,0,0,0})

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvCKZ()
Método que realiza a gravação dos valores de receita bruta do período 
e filial.

@author Erick G. Dias
@since 28/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method GrvCKZ() Class FISX001

Local nPos	:= 1

dbSelectArea('CKZ')
CKZ->(dbSetOrder(1))

For nPos:= 1 to Len(Self:aChave)

	If !CKZ->(MSSEEK(Self:BuscaxFil('CKZ')+dTos(Self:aChave[nPos][2])+Self:aChave[nPos][7]+Self:aChave[nPos][8] + Self:aChave[nPos][10]))
	//INclui nova referência para combinação tributo+alíquota+código de contribuição+origem+período.
		RecLock('CKZ',.T.)
		CKZ->CKZ_FILIAL	:=	Self:BuscaxFil('CKZ')
		CKZ->CKZ_PER		:=	Self:aChave[nPos][2]
		CKZ->CKZ_TRIB		:=	Self:aChave[nPos][3]
		CKZ->CKZ_ALIQ		:=	Self:aChave[nPos][4]
		CKZ->CKZ_COD		:=	Self:aChave[nPos][5]
		CKZ->CKZ_ORIGEM	:=  Self:aChave[nPos][6]
		CKZ->CKZ_REGIME	:=  Self:aChave[nPos][7]
		CKZ->CKZ_ID		:=  Self:aChave[nPos][8]
		CKZ->CKZ_DEBCRD	:=  Self:aChave[nPos][9]		
		CKZ->CKZ_CONSOL	:=  Self:aChave[nPos][10]		
		MsUnLock()
	EndIF

Next nPos

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvCL8()
Método que irá gravar os valores de créditos consolidados processados 
na tabela CL8

@author Erick G. Dias
@since 12/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method GrvCL8() Class FISX001

Local nPos	:= 0
dbSelectArea('CL8')
CL8->(dbSetOrder(1))

For nPos:= 1 to Len(Self:aCL8)
	//REtirei verificação da base de cálculo maior que zero, pois em deteminadas situações dos CST com receitas em comum 53,54,55,56,63,64,65 e 66
	//pode acontecer de não ter valor de crédito para determinado grupo da tabela 4.3.6, e deverá gerar M100/M500 zerado, pois o PVA acusa erro e não valida o arquivo.
	//If Self:aCL8[nPos][8] > 0 .Or. Self:aCL8[nPos][7] =='1'
		If !CL8->(MSSEEK(Self:BuscaxFil('CL8')+dTos(Self:aCL8[nPos][2])+Self:aCL8[nPos][3]+Self:aCL8[nPos][7]+Self:aCL8[nPos][5]+Self:aCL8[nPos][6]+Self:aCL8[nPos][11]))
	
			RecLock('CL8',.T.)
			CL8->CL8_FILIAL	:=	Self:aCL8[nPos][1]
			CL8->CL8_PER		:=	Self:aCL8[nPos][2]
			CL8->CL8_CHV		:=	Self:aCL8[nPos][3]
			CL8->CL8_TRIB		:=	Self:aCL8[nPos][4]
			CL8->CL8_CODBCC	:=	Self:aCL8[nPos][5]
			CL8->CL8_CST		:=	Self:aCL8[nPos][6]
			CL8->CL8_INDCRE	:=	Self:aCL8[nPos][7]
			CL8->CL8_BSCALC	:=	Self:aCL8[nPos][8]
			CL8->CL8_VLCRED	:=  Self:aCL8[nPos][9]
			CL8->CL8_TOTCRD	:= 	Self:aCL8[nPos][10]
			CL8->CL8_CONSOL	:= 	Self:aCL8[nPos][11]		
			MsUnLock()
		Else
			RecLock('CL8',.F.)
			CL8->CL8_BSCALC	+=	Self:aCL8[nPos][8]
			CL8->CL8_VLCRED	+=  Self:aCL8[nPos][9]
			CL8->CL8_TOTCRD	+= 	Self:aCL8[nPos][10]
			MsUnLock()	
		EndIF	
	//EndIF
	
Next nPos

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvCL9()
Método que irá gravar os valores de créditos detalhados processados 
na tabela CL9

@author Erick G. Dias
@since 12/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method GrvCL9() Class FISX001

Local nPos	:= 1
//parei aqui
dbSelectArea('CL9')
CL9->(dbSetOrder(1))
For nPos:= 1 to Len(Self:aCL9)	
	If !CL9->(MSSEEK(Self:BuscaxFil('CL9')+dTos(Self:aCL9[nPos][2])+Self:aCL9[nPos][3]+Self:aCL9[nPos][4]+Self:aCL9[nPos][5]+Self:aCL9[nPos][6]+Self:aCL9[nPos][12]))

		RecLock('CL9',.T.)
		CL9->CL9_FILIAL	:=	Self:aCL9[nPos][1]
		CL9->CL9_PER		:=	Self:aCL9[nPos][2]
		CL9->CL9_CHV		:=	Self:aCL9[nPos][3]
		CL9->CL9_CODBCC	:=	Self:aCL9[nPos][4]
		CL9->CL9_CST		:=	Self:aCL9[nPos][5]
		CL9->CL9_PAUTA	:=	Self:aCL9[nPos][6]
		CL9->CL9_TOTBSE	:=	Self:aCL9[nPos][7]
		CL9->CL9_BSCUM	:=	Self:aCL9[nPos][8]
		CL9->CL9_BSNCUM	:=  Self:aCL9[nPos][9]
		CL9->CL9_BSTCRD	:= 	Self:aCL9[nPos][10]
		CL9->CL9_DESCR	:= 	Self:aCL9[nPos][11]		
		CL9->CL9_CONSOL	:= 	Self:aCL9[nPos][12]		
		MsUnLock()
	Else
		RecLock('CL9',.F.)
		CL9->CL9_TOTBSE	+=	Self:aCL9[nPos][7]
		CL9->CL9_BSCUM	+=	Self:aCL9[nPos][8]
		CL9->CL9_BSNCUM	+=  Self:aCL9[nPos][9]
		CL9->CL9_BSTCRD	+= 	Self:aCL9[nPos][10]
		MsUnLock()	
	EndIF	
	
Next nPos


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvCKS()
Método que irá gravar os valores de débitos de PIS e COFINS processados

@author Erick G. Dias
@since 12/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method GrvCKS() Class FISX001

Local nPos			:= 1
Local oCPRB
Local lCprbCnae	:= .F.
Local cCodAtiviv	:= '' //definir de qual parâmetro buscar este código
Local nAlqCprb	:= 2 //definir de qual parâmetro buscar esta alíquota
Local nBrutCPRB	:= 0
Local nValAtiv	:= 0
Local nBaseCprb	:= 0
Local mvAlqCprb	:=GetNewPar('MV_CPRBALQ','')
Local lF3G		:= AliasINdic('F3G')
Local lF3J		:= AliasINdic('F3J')
Local lTribReg	:= .F.
Local lCST		:= .F.
Local lCODCON	:= .F.
Local lTNatRec	:= .F.
Local lCNatRec	:= .F.
Local cF3JTrib	:= ''

cCodAtiviv := Substr(mvAlqCprb,1,  At("/",mvAlqCprb)-1  )
nAlqCprb :=val( Substr(mvAlqCprb,At("/",mvAlqCprb)+1,  len(mvAlqCprb)  ))   

IF Self:lProcCprb .AND. !Empty(cCodAtiviv) .AND. nAlqCprb > 0
	lCprbCnae:= .t.
EndIF

dbSelectArea('CKS')
CKS->(dbSetOrder(1))
For nPos:= 1 to Len(Self:aCKS)

	If !CKS->(MSSEEK(Self:aCKS[nPos][1]+dTos(Self:aCKS[nPos][2])+Self:aCKS[nPos][3]+Self:aCKS[nPos][11]))

		RecLock('CKS',.T.)
		CKS->CKS_FILIAL	:=	Self:aCKS[nPos][1]
		CKS->CKS_PER		:=	Self:aCKS[nPos][2]
		CKS->CKS_CHV		:=	Self:aCKS[nPos][3]
		CKS->CKS_TRIB		:=	Self:aCKS[nPos][4]
		CKS->CKS_PAUTA	:=  Self:aCKS[nPos][5]
		CKS->CKS_VLREC	:=  Self:aCKS[nPos][6]
		CKS->CKS_BASE		:=	Self:aCKS[nPos][7]
		
		//Se os campos de ajustes de base de cálculo existirem, então serão gravados inicialmente com o mesmo valor da base de cálculo
		//Os ajustes serão efetuados posteriormente através da classe de ajustesEFD.
		If Self:lCmpAjuBas .AND. CKS->CKS_PAUTA <> "1"
			CKS->CKS_BCAJUS		:=	Self:aCKS[nPos][7]
			CKS->CKS_AJBCA 		:=	0
			CKS->CKS_AJBCR 		:=	0
		EndIF

		CKS->CKS_VLTRIB	:=	Self:aCKS[nPos][8]
		CKS->CKS_VLDISP	:=	Self:aCKS[nPos][9]
		CKS->CKS_AJRD		:=	Self:aCKS[nPos][10]	//Este ajuste de redução é preenchido somente para valor de exclusão de folah de salários		
		CKS->CKS_CONSOL	:=	Self:aCKS[nPos][11]	//Este ajuste de redução é preenchido somente para valor de exclusão de folah de salários		
		
		MsUnLock()
	Else
		RecLock('CKS',.F.)
		CKS->CKS_VLREC	+=  Self:aCKS[nPos][6]
		CKS->CKS_BASE		+=	Self:aCKS[nPos][7]
		
		//Também acumulará no campo de base ajustada, considerando inicialmente a mesma base original.
		If Self:lCmpAjuBas .AND. CKS->CKS_PAUTA <> "1"
			CKS->CKS_BCAJUS		+=	Self:aCKS[nPos][7]
		EndIF

		CKS->CKS_VLTRIB	+=	Self:aCKS[nPos][8]
		CKS->CKS_VLDISP	+=	Self:aCKS[nPos][9]
		CKS->CKS_AJRD		+=	Self:aCKS[nPos][10]	//Este ajuste de redução é preenchido somente para valor de exclusão de folah de salários					
		MsUnLock()			
	EndIF
	
	IF Self:aCKS[nPos][4] == '1'
		//Valores acumulados para geração da CPRB quando houver desoneração por CNAE
		//Somente fará uma vez, pois os valores das receitas de PIS e COFINS são as mesmas.
		nBrutCPRB  	+= Self:aCKS[nPos][6]
		nValAtiv		+= Self:aCKS[nPos][6]
		nBaseCprb		+=	Self:aCKS[nPos][6]
	EndIF
	
Next nPos


IF lCprbCnae .AND. nBrutCPRB > 0
		
	//Processar neste ponto para gravar CPRB caso seja opção de desoneração por CNAE.	
	//Popula objeto para gravar a CPRB
	oCPRB	:= CPRBEFD():New()	
	oCPRB:SetDtRefer(Self:dDtIni)
	oCPRB:SetFilial(Self:aFilial)
	oCPRB:SetCodAtiv(AllTrim(cCodAtiviv))
	oCPRB:SetVlBrut(nBrutCPRB)
	oCPRB:SetVlExcl(0)//´deverá ser o valor de consórcio	
	oCPRB:SetVlCPRB(Round(nBaseCprb*nAlqCprb/100,2))
	oCPRB:SetAliq(nAlqCprb)	
	oCPRB:SetBase(nBaseCprb)	
	oCPRB:SetVlAtiv(nValAtiv)
	oCPRB:SetConta('')
	oCPRB:SetInform('')
	//Grava valores de CPRB
	oCPRB:AgrupaCPRB()
	oCPRB:DetalhCPRB()
	
	oCPRB:GravaCPRB()
	FreeObj(oCPRB)
	oCPRB:= Nil
EndIF

//Abaixo trecho que irá gravar na F3J os valores de receitas agrupados
If lF3J .AND. lF3G	.AND. Len(Self:aF3J) > 0
	DbSelectArea ("F3G") 
	F3G->(DbSetOrder (1))
	F3G->(DbGoTop ())
	F3G->(MSSEEK(Self:BuscaxFil('F3G')))
	
	//É necessário processar todas as regras da tabela F3G
	Do While !F3G->(Eof ()) .AND. F3G->F3G_FILIAL == Self:BuscaxFil('F3G')
		For nPos	:= 1 to Len(Self:aF3J)
			
			lTribReg	:= .F.
			lCST		:= .F.
			lCODCON		:= .F.
			lTNatRec	:= .F.
			lCNatRec	:= .F.
			
			//Se o tributo e o regime forem diferentes, esta regra não será processada
			IF F3G->F3G_TRIBUT == Self:aF3J[nPos][1] .AND. F3G->F3G_REGIME == Self:aF3J[nPos][2] 
				
				//Enquadrou Regime e tributo
				lTribReg	:= .T.
				
				IF Empty(F3G->F3G_CST) .OR. F3G->F3G_CST == Self:aF3J[nPos][3]
					//Enquadrou CST
					lCST	:= .T.
				EndIF			
	
				IF Empty(F3G->F3G_CODCON) .OR. F3G->F3G_CODCON == Self:aF3J[nPos][4]
					//Enqudrou Código da COntribuição
					lCODCON	:= .T.				
				EndIF			
	
				IF Empty(F3G->F3G_NATREC) .OR. F3G->F3G_NATREC == Self:aF3J[nPos][5]
					//Enquadrou Tabela da Natureza da Receita
					lTNatRec	:= .T.				
				EndIF			
	
				IF Empty(F3G->F3G_CNATRE) .OR. F3G->F3G_CNATRE == Self:aF3J[nPos][6]
					//Enquadrou Código da Receita da Natureza
					lCNatRec	:= .T.				
				EndIF

			EndIF			
			
			IF lTribReg .AND. lCST .AND. lCODCON .AND.  lTNatRec .AND. lCNatRec
				//Todas as informações se enquadraram, então pode adotar o código da receita para o valor acumulado
				Self:aF3J[nPos][8]	:= F3G->F3G_CODREC
			EndIF
		
		Next nPos
		
		F3G->(DbSkip ())
	EndDo
	
	//Aqui tenho o Array com os códigos de receita que se enquadrou. Os valores sem código de receita não serão gravados na F3J, pois não se enquadram com nenhuma regra do cliente			
	For nPos:= 1 to Len(Self:aF3J)
		
		//Somente irei considerar os array com código de receita preenchido, se não tem código de receita significa que não enquadrou nenhuma regra da F3G
		IF !Empty(alltrim(Self:aF3J[nPos][8]))
			//Aqui irei atribou o código que define PIS, COFINS Cumulativo e Não Cumulativo
			cF3JTrib	:= DefTrib(Self:aF3J[nPos][1],Self:aF3J[nPos][2]) 
			If !F3J->(MSSEEK(Self:BuscaxFil('F3J') + dTos(Self:dDtIni) + Self:cConsl +  cF3JTrib +  Self:aF3J[nPos][8] ))
		
				RecLock('F3J',.T.)
				F3J->F3J_FILIAL		:=	Self:BuscaxFil('F3J')
				F3J->F3J_PER		:=	Self:dDtIni
				F3J->F3J_VLTRIB		:=	Self:aF3J[nPos][7]
				F3J->F3J_CODREC		:=	Self:aF3J[nPos][8]
				F3J->F3J_CONSOL		:=	Self:cConsl
				F3J->F3J_TRIBUT		:=	cF3JTrib								
				MsUnLock()
				
			Else
				RecLock('F3J',.F.)
				F3J->F3J_VLTRIB		+=	Self:aF3J[nPos][7]
				MsUnLock()
						
			EndIF	
		
		EndIf
	Next nPos
			
EndIF
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} DefTrib()
Função que retorna o código de tributo conforme a regra
1-PIS NAO CUMULATIVO
2-PIS CUMULATIVO
3-COFINS NÃO CUMULATIVO
4-COFINS CUMULATIVO

@author Erick G. Dias
@since 09/05/17
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function DefTrib(cTrib,cRegime )

Local cRet	:= ''

IF cTrib == '1' .AND. cRegime == '1' //PIS Não Cumulativo	
	cRet	:= '1'
	
ElseIF cTrib == '1' .AND. cRegime == '2' //PIS Cumulativo	
	cRet	:= '2'
	
ElseIF cTrib == '2' .AND. cRegime == '1' //COFINS Não Cumulativo	
	cRet	:= '3'
	
ElseIF cTrib == '2' .AND. cRegime == '2' //COFINS Cumulativo	
	cRet	:= '4'
	
EndIF

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvCL0()
Grava na tabela CL0 os valores das operações agrupados por regime e CST

@author Erick G. Dias
@since 12/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method GrvCL0() Class FISX001

Local nPos	:= 1

dbSelectArea('CL0')
CL0->(dbSetOrder(1))
For nPos:= 1 to Len(Self:aCL0)

	If !CL0->(MSSEEK(Self:BuscaxFil('CL0')+dTos(Self:aCL0[nPos][2])+Self:aCL0[nPos][3] + Self:aCL0[nPos][8]+Self:aCL0[nPos][9]))
	//INclui nova referência para combinação tributo+alíquota+código de contribuição+origem+período.
		RecLock('CL0',.T.)
		CL0->CL0_FILIAL	:=	Self:aCL0[nPos][1]
		CL0->CL0_PER		:=	Self:aCL0[nPos][2]
		CL0->CL0_CST		:=	Self:aCL0[nPos][3]
		CL0->CL0_BASENC	:=	Self:aCL0[nPos][4]
		CL0->CL0_VLOPNC	:=  Self:aCL0[nPos][5]
		CL0->CL0_BASEC	:=	Self:aCL0[nPos][6]
		CL0->CL0_VLOPC	:=  Self:aCL0[nPos][7]
		CL0->CL0_CONSOL	:=  Self:aCL0[nPos][8]		
		CL0->CL0_ORIGEM	:=  Self:aCL0[nPos][9]		
		MsUnLock()
	Else
		RecLock('CL0',.F.)
		CL0->CL0_BASENC	+=	Self:aCL0[nPos][4]
		CL0->CL0_VLOPNC	+=  Self:aCL0[nPos][5]
		CL0->CL0_BASEC	+=	Self:aCL0[nPos][6]
		CL0->CL0_VLOPC	+=  Self:aCL0[nPos][7]
		MsUnLock()
	EndIF


Next nPos

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvCKT()
Realiza gravação dos valores de Receitas Não Tributadas apuradas.

@author Erick G. Dias
@since 12/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method GrvCKT() Class FISX001

Local nPos	:= 1

dbSelectArea('CKT')
CKT->(dbSetOrder(1))
For nPos:= 1 to Len(Self:aCKT)

	If !CKT->(MSSEEK(Self:aCKT[nPos][1]+dTos(Self:aCKT[nPos][2])+Self:aCKT[nPos][3]+Self:aCKT[nPos][4]+Self:aCKT[nPos][5]+Self:aCKT[nPos][7]+Self:aCKT[nPos][9]+Self:aCKT[nPos][10]))
		RecLock('CKT',.T.)
		CKT->CKT_FILIAL	:=	Self:aCKT[nPos][1]
		CKT->CKT_PER		:=	Self:aCKT[nPos][2]
		CKT->CKT_TRIB		:=	Self:aCKT[nPos][3]
		CKT->CKT_CST		:=	Self:aCKT[nPos][4]
		CKT->CKT_CODNAT	:=	Self:aCKT[nPos][5]
		CKT->CKT_VLREC	:=	Self:aCKT[nPos][6]
		CKT->CKT_CONTA	:=	Self:aCKT[nPos][7]
		CKT->CKT_DESCR	:=	Self:aCKT[nPos][8]
		CKT->CKT_CONSOL	:=	Self:aCKT[nPos][9]		
		CKT->CKT_ORIGEM	:=	Self:aCKT[nPos][10]		
	
		MsUnLock()
	Else
		RecLock('CKT',.F.)
		CKT->CKT_VLREC	+=	Self:aCKT[nPos][6]
		MsUnLock()
	EndIF


Next nPos

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReduzBase()
Método que irá reduzir a base de cálculo da contribuição ou do crédito
conforme a chave da passada

@author Erick G. Dias
@since 18/11/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method ReduzCL0(nValBase, nVal) Class FISX001

Local aDiasThr 		:= {}
Local nQtdThread	:= SuperGetMv("MV_QTDTAEC",.F.,0) + 1
Local dDataIni		:= Self:dDtIni

If nQtdThread > 1
	aDiasThr := A001DIATHR(nQtdThread,FirstDay(Self:dDtIni), LastDay(Self:dDtIni))
	If (nPos := Ascan(aDiasThr,{|x| x[1] <= SFT->FT_ENTRADA .And. x[2] >= SFT->FT_ENTRADA }) ) > 0
		dDataIni := aDiasThr[nPos][1]
	EndIf	
EndIf

dbSelectArea('CL0')
CL0->(dbSetOrder(1))
If CL0->(MSSEEK(Self:BuscaxFil('CL0')+dTos(dDataIni)+Self:cCst+Self:cConsl+Self:cOrigem))
	RecLock('CL0',.F.)
	
	IF Self:cTpReg == '1'		  
		CL0->CL0_BASENC-= Iif(CL0->CL0_BASENC>= nValBase,nValBase ,0 ) 
		CL0->CL0_VLOPNC-= Iif(CL0->CL0_VLOPNC>= nVal,nVal ,0 )
	ElseIF Self:cTpReg == '2'		  
		CL0->CL0_BASEC-= Iif(CL0->CL0_BASEC>= nValBase,nValBase ,0 ) 
		CL0->CL0_VLOPC-= Iif(CL0->CL0_VLOPC>= nVal,nVal ,0 )
	EndIF
		
	MsUnLock()
EndIF



//-------------------------------------------------------------------
/*/{Protheus.doc} ReduzBase()
Método que irá reduzir a base de cálculo da contribuição ou do crédito
conforme a chave da passada

@author Erick G. Dias
@since 15/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method ReduzBase(nValBase,nValRed,cDebCred,cChave,cCst,cCodBcc,cPauta,nBaseProp) Class FISX001

Local lTribReg	:= .F.
Local lCST		:= .F.
Local lCODCON	:= .F.
Local lTNatRec	:= .F.
Local lCNatRec	:= .F.
Local lF3G		:= AliasINdic('F3G')
Local lF3J		:= AliasINdic('F3J')
Local nX		:= 0
Local aCST		:= {}
Local cCodCon	:= ''
Local cCodRec	:= ''
Local aDiasThr 		:= {}
Local nQtdThread	:= SuperGetMv("MV_QTDTAEC",.F.,0) + 1
Local dDataIni		:= Self:dDtIni
Local cIndCred		:= Self:cIndCre

DEFAULT cCodBcc	:= ''
DEFAULT cCst	:= ''
DEFAULT cPauta	:= '2' //Sem pauta 
DEFAULT nBaseProp := 0

If nQtdThread > 1
	aDiasThr := A001DIATHR(nQtdThread,FirstDay(Self:dDtIni), LastDay(Self:dDtIni))
	If (nPos := Ascan(aDiasThr,{|x| x[1] <= SFT->FT_EMISSAO .And. x[2] >= SFT->FT_EMISSAO  }) ) > 0
		dDataIni := aDiasThr[nPos][1]
	EndIf	
EndIf

IF !Empty(AllTrim(cChave))

	IF cDebCred == '1' //credito
		dbSelectArea('CL8')
		CL8->(dbSetOrder(1))
		IF CL8->(MSSEEK(Self:BuscaxFil('CL8')+DTos(dDataIni)+cChave+cIndCred+cCodBcc+cCst)) //---1 CL8_FILIAL+DTOS(CL8_PER)+CL8_CHV+CL8_INDCRE+CL8_CODBCC+CL8_CST+CL8_CONSOL---//
			RecLock('CL8',.F.)
			CL8->CL8_BSCALC -= nBaseProp
			CL8_VLCRED	-= nValRed
			CL8->CL8_TOTCRD :=	CL8_VLCRED + CL8->CL8_AJAC - CL8->CL8_AJRD - CL8->CL8_DIF 
			MsUnLock()
			
			//Deverá reduzir também a tabela CL9
			//CL9_FILIAL+DTOS(CL9_PER)+CL9_CHV+CL9_CODBCC+CL9_CST+CL9_PAUTA+CL9_CONSOL
			IF !Empty(cCodBcc) .AND. !Empty(cCodBcc) .AND. CL9->(MSSEEK(Self:BuscaxFil('CL9')+DTos(dDataIni)+cChave+cCodBcc+cCst+cPauta+Self:cConsl))
				RecLock('CL9',.F.)
				CL9->CL9_TOTBSE -= nValBase
				CL9->CL9_BSNCUM -= nValBase
				CL9->CL9_BSTCRD -= nBaseProp
				MsUnLock()
			EndIF
			
		EndIF
	
	ElseIF cDebCred == '2' // débitos

		dbSelectArea('CKS')
		CKS->(dbSetOrder(1))
		IF CKS->(MSSEEK(Self:BuscaxFil('CKS')+DTos(dDataIni)+cChave+Self:cConsl)) 
			RecLock('CKS',.F.)
			//CKS->CKS_VLREC -= nValBase
			CKS->CKS_BASE -= nValBase
			
			If Self:lCmpAjuBas	
				CKS->CKS_BCAJUS -= nValBase
			EndIF
			
			CKS->CKS_VLTRIB -= nValRed
			CKS->CKS_VLDISP	:=	CKS_VLTRIB+CKS_AJAC-CKS_AJRD-CKS_DIF+CKS_DIFANT
			MsUnLock()
		EndIF
	
		If lF3G .and. lF3G
			
			DbSelectArea ("F3G") 
			F3G->(DbSetOrder (1))
			F3G->(DbGoTop ())
			F3G->(MSSEEK(Self:BuscaxFil('F3G')))
			
			//É necessário processar todas as regras da tabela F3G
			Do While !F3G->(Eof ()) .AND. F3G->F3G_FILIAL == Self:BuscaxFil('F3G')
				
				lTribReg	:= .F.
				lCST		:= .F.
				lCODCON		:= .F.
				lTNatRec	:= .F.
				lCNatRec	:= .F.
				
				//Se o tributo e o regime forem diferentes, esta regra não será processada
				IF F3G->F3G_TRIBUT == Self:cTrib .AND. F3G->F3G_REGIME == Self:cRegimeOpe
					
					//Enquadrou Regime e tributo
					lTribReg	:= .T.
					
					IF Empty(F3G->F3G_CST) .OR. F3G->F3G_CST == Self:cCST
						lCST	:= .T.
					EndIF			
		
					IF Empty(F3G->F3G_CODCON) .OR. F3G->F3G_CODCON == Alltrim(Self:cCodConCrd)
						//Enqudrou Código da COntribuição
						lCODCON	:= .T.				
					EndIF			
		
					IF Empty(F3G->F3G_NATREC) .OR. F3G->F3G_NATREC == Self:cTNatRec
						//Enquadrou Tabela da Natureza da Receita
						lTNatRec	:= .T.				
					EndIF			
		
					IF Empty(F3G->F3G_CNATRE) .OR. F3G->F3G_CNATRE == Self:cCNatRec
						//Enquadrou Código da Receita da Natureza
						lCNatRec	:= .T.				
					EndIF
	
				EndIF			
				
				IF lTribReg .AND. lCST .AND. lCODCON .AND.  lTNatRec .AND. lCNatRec
					//Todas as informações se enquadraram, então pode adotar o código da receita para o valor acumulado
					cCodRec := F3G->F3G_CODREC
				EndIF
				
				F3G->(DbSkip ())
			EndDo
			
			If !Empty(cCodRec)
				cF3JTrib := DefTrib(Self:cTrib,Self:cRegimeOpe)
				If F3J->(MSSEEK(Self:BuscaxFil('F3J') + dTos(dDataIni) + Self:cConsl+ cF3JTrib  + cCodRec))
					RecLock('F3J',.F.)
					F3J->F3J_VLTRIB	-= nValRed
					MsUnLock()
				EndIF
			EndIf
			
		EndIf
	
	EndIF
	
EndIF

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} BuscaChave()
Método que irá buscar a chave da EFD conforme aliquota, CST, código do crédito
ou contribuição.

@author Erick G. Dias
@since 15/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method BuscaChave() Class FISX001

Local cChave	:= ''
Local aDiasThr 		:= {}
Local nQtdThread	:= SuperGetMv("MV_QTDTAEC",.F.,0) + 1
Local dDataIni		:= Self:dDtIni

If nQtdThread > 1
	aDiasThr := A001DIATHR(nQtdThread,FirstDay(Self:dDtIni), LastDay(Self:dDtIni))
	If (nPos := Ascan(aDiasThr,{|x| x[1] <= SFT->FT_EMISSAO .And. x[2] >= SFT->FT_EMISSAO  }) ) > 0
		dDataIni := aDiasThr[nPos][1]
	EndIf	
EndIf

dbSelectArea('CKZ')
CKZ->(dbSetOrder(2))

//Busca a chave da EFD para retornar.
If CKZ->(MSSEEK(Self:BuscaxFil('CKZ')+DTos(dDataIni)+Self:cTrib +str(Self:nAlq,8,4) + Self:cCodConCrd +Self:cOrigem + Self:cRegimeOpe))
	cChave:= CKZ->CKZ_ID
EndIf

Return cChave


//-------------------------------------------------------------------
/*/{Protheus.doc} EstornCanc()
Método que irá percorrer tabela CF4 para efetuar os ajustes referentes
aos ajustes de cancelamentos em períodos anteriores.

@author Erick G. Dias
@since 10/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method EstornCanc(cRegime, cOpAju) Class FISX001

Local cAliasCKZ	:='' //x001QRYCKS('6',Self:dDtIni,cRegime)
Local cAliasCF4	:= ''
Local cDtCf4	:= SubStr(DTos(Self:dDtIni),5,2)+SubStr(Dtos(Self:dDtIni),1,4)
Local cDtRefer	:= ''
Local oAjustes 	:= AJUSTEEFD():New()
Local cDebito		:= '2'
Local lProc	    := .F.
Default cOpAju	:= '1' //Considera todas as movimentações da CF4

oAjustes:SetFilial(Self:aFilial)
DbSelectArea ("CF4") 
CF4->(DbSetOrder (2))
CF4->(DbGoTop ())
//Se ao menos houver um registro na CF4, irá processar.
If CF4->( MsSeek(xFilial("CF4")+cDtCf4) )
	lProc := .T.
EndIF

If lProc
	
	oAjustes:SetDtIni(Self:dDtIni)
	oAjustes:SetCrdDeb(cDebito)
	oAjustes:SetConsol(Self:cConsl)
	oAjustes:LoadCKS(Iif(cOpAju=="3", .T., .F.))
	
	cAliasCKZ	:= x001QRYCKS('6',Self:dDtIni,cRegime,Self:BuscaxFil('CKZ'),Self:cConsl)
	
	DbSelectArea (cAliasCKZ)
	(cAliasCKZ)->(DbGoTop ())
	Do While !(cAliasCKZ)->(Eof ())	

		cAliasCF4	:= x001QRYCF4(cDtCf4,AllTrim((cAliasCKZ)->CKZ_COD), (cAliasCKZ)->CKZ_ALIQ, (cAliasCKZ)->CKS_PAUTA,(cAliasCKZ)->CKZ_TRIB)

		Do While !(cAliasCF4)->(Eof ())	
	
			cDtRefer	:= SubStr(Dtos((cAliasCF4)->CF4_DATAE),7,2)+SubStr(Dtos((cAliasCF4)->CF4_DATAE),5,2)+SubStr(Dtos((cAliasCF4)->CF4_DATAE),1,4)
	
			oAjustes:SetTributo((cAliasCKZ)->CKZ_TRIB)
			oAjustes:SetTpAjust('0')//Redução
			oAjustes:SetCodAju('06')//Código de estorno
			oAjustes:SetNumDoc( IIF( !Empty( (cAliasCF4)->FT_NFELETR ), (cAliasCF4)->FT_NFELETR, (cAliasCF4)->CF4_NOTA ) )
			oAjustes:SetDescAju('NOTA FISCAL CANCELADA')
			oAjustes:SetDtRefer(Self:dDtIni)
			oAjustes:SetCodDC((cAliasCKZ)->CKZ_COD)
			oAjustes:SetRegime((cAliasCKZ)->CKZ_REGIME)
			oAjustes:SetOrigem('B') //irá considerar origem das operações de cancelamento gravadas na CF4.		
			oAjustes:SetConta((cAliasCF4)->FT_CONTA)		
			oAjustes:SetInfComp('Ajuste de redução da Contribuição referente documento cancelado que teve sua emissão em período anterior.')
			If (cAliasCKZ)->CKZ_TRIB == '1'
				
				IF cOpAju == '3' .AND. (cAliasCF4)->CF4_CSTPIS <> "03"
					//Ajuste base de cálculo
					oAjustes:SetVlAju((cAliasCF4)->CF4_BASPIS)
				Else
					oAjustes:SetVlAju((cAliasCF4)->CF4_VALPIS)
				EndIF
				
				oAjustes:SetAlq((cAliasCF4)->CF4_ALIPIS)
				oAjustes:SetCst((cAliasCF4)->CF4_CSTPIS)
				oAjustes:SetBase((cAliasCF4)->CF4_BASPIS)				
			Else

				IF cOpAju == '3' .AND. (cAliasCF4)->CF4_CSTCOF <> "03"
					//Ajuste base de cálculo
					oAjustes:SetVlAju((cAliasCF4)->CF4_BASCOF)
				Else
					oAjustes:SetVlAju((cAliasCF4)->CF4_VALCOF)
				EndIF
				
				oAjustes:SetAlq((cAliasCF4)->CF4_ALICOF)
				oAjustes:SetCst((cAliasCF4)->CF4_CSTCOF)	
				oAjustes:SetBase((cAliasCF4)->CF4_BASCOF)
			EndIF
			
			oAjustes:SetAjuBase(.F.)
			If cOpAju == '1'
				//Ajustes normais de contribuição para todos os CSTs
				oAjustes:Ajustar()
			ElseIF cOpAju == '2' .AND. (cAliasCF4)->CF4_CSTPIS == "03"
				//Ajustes de contribuiçã somente para o CST 03
				oAjustes:Ajustar()
			ElseIF cOpAju == '3' .AND. (cAliasCF4)->CF4_CSTPIS <> "03"
				//Ajustes de base de cálculo para todos CSTs com exceção do 03
				oAjustes:SetOrigem('A') //Origem de redução de base de cálculo
				oAjustes:SetCNPJ(SM0->M0_CGC)
				oAjustes:SetCodAju('01')//Código de estorno
				oAjustes:SetAjuBase(.T.)
				oAjustes:Ajustar()
			EndIF					
					
			(cAliasCF4)->(DbSkip ())
		EndDo
		DbSelectArea (cAliasCF4)
		(cAliasCF4)->(DbCloseArea())
	
		(cAliasCKZ)->(DbSkip ())
	EndDo
	DbSelectArea (cAliasCKZ)
	(cAliasCKZ)->(DbCloseArea())
	
	FreeObj(oAjustes)
	oAjustes	:= Nil
EndIF

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Finaliza()
Método que finaliza a gravação das informações processadas, fazendo acesso
em tabelas somente no final com os valores já totalizados

@author Erick G. Dias
@since 12/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method Finaliza(cValor) Class FISX001

Self:GrvCKZ()
Self:GrvCL0()

If cValor == '1' //Saída
	Self:GrvRecBru()
	Self:GrvRecNB()
	Self:GrvCKS()
	Self:GrvCKT()
	Self:aCKS	:= {}
	Self:aCKT	:= {}
ElseIf cValor == '2' //Entrada
	// Consolidar a base de calculo do aCL8 c/ os dados do aCL9.
	Self:AgrCL9CL8()
	Self:GrvCL8()
	Self:aCL8	:= {}
	Self:GrvCL9()
	Self:aCL9	:= {}		
EndIF

Self:aChave	:= {}
Self:aCL0		:= {}
Self:aF3J	 	:={}

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} LoadRecBru()
Método responsável por carregar os valores de Receita Bruta do período
e Filial para processamento dos créditos quando regime Cumulativo e não Cumulativo.

@author Erick G. Dias
@since 28/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method LoadRecBru() Class FISX001

	Local cAliasCKU	:= 'CKU'
	Local cSlctCKU	:= ''
	Local cFiltro		:= ''

	Self:aRecBruta	:= {}
	AADD(Self:aRecBruta,{0,0,0,0,0})

	cSlctCKU:= '%CKU.CKU_RTNC,	CKU.CKU_RNTNC,		CKU.CKU_EXP,		CKU.CKU_RTC%'

	cFiltro := "%"
	cFiltro += "CKU.CKU_FILIAL= '"+ Self:BuscaxFil('CKU')+ "' AND "
	cFiltro += "CKU.CKU_PER>= '" + %Exp:DToS (Self:dDtIni)% + "' AND "
	cFiltro += "CKU.CKU_PER<= '" + %Exp:DToS (Self:dDtIni)% + "' AND "
	cFiltro += "CKU.CKU_CONSOL= '" + Self:cConsl + "' AND "

	cFiltro += "%"

	cAliasCKU	:=	GetNextAlias()
	BeginSql Alias cAliasCKU
    	
		SELECT
		%Exp:cSlctCKU%

		FROM
		%Table:CKU% CKU
		WHERE
		%Exp:cFiltro%
		CKU.%NotDel%
		
	EndSql
	DbSelectArea (cAliasCKU)
	(cAliasCKU)->(DbGoTop ())
	Do While !(cAliasCKU)->(Eof ())
		Self:aRecBruta[1][1]	+=	(cAliasCKU)->CKU_RTNC
		Self:aRecBruta[1][2]	+=	(cAliasCKU)->CKU_RNTNC
		Self:aRecBruta[1][3]	+=	(cAliasCKU)->CKU_EXP
		Self:aRecBruta[1][4]	+=	(cAliasCKU)->CKU_RTC
			
		(cAliasCKU)->(DbSkip ())
	EndDo
	DbSelectArea (cAliasCKU)
	(cAliasCKU)->(DbCloseArea())

//Total da receita bruta
	Self:aRecBruta[1][5]	+= Self:aRecBruta[1][1] +Self:aRecBruta[1][2] +Self:aRecBruta[1][3] +Self:aRecBruta[1][4]

Return Self:aRecBruta


//-------------------------------------------------------------------
/*/{Protheus.doc} OperPauta()
Método responsável pela conversão de pauta de PIS e COFINS, tanto para
crédito quando para débito. 

@return lRet - Indica houve conversão de valores de pauta de PIS e COFINS
@author Erick G. Dias
@since 28/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------

Method OperPauta() Class FISX001
Local nAliqRec	:= 0
Local lRet		:= .F.
Local lSecUnMed	:= GetNewPar("MV_PISCOFP",.F.)

DbSelectArea ("CCZ")
CCZ->(DbSetOrder (1))

Self:cPauta	:= '2'
IF Self:nVlPauta > 0 .AND. !EmpTy(AllTrim(Self:cCNatRec)) .AND. CCZ->(msSeek(xFilial("CCZ")+Self:cTNatRec+Self:cCNatRec+Self:cGNatRec+dTos(Self:dDNatRec	))) .and. CCZ->CCZ_TABELA == '4311'
	if Self:cTrib == '1'
		nAliqRec := CCZ->CCZ_ALQPIS
	ElseIF Self:cTrib == '2'
		nAliqRec := CCZ->CCZ_ALQCOF
	EndIF

	IF nAliqRec > 0
		Self:nAlq	:= nAliqRec
		IF !lSecUnMed
			//Se não utilizar segunda unidade de medida através do parâmetro lSecUnMed, não será necessário fazer conversão 
			//para obter a base, pois a própria base em Self:nBase já estará correta.
			Self:nBase := NoRound((Self:nVlPauta/nAliqRec) * Self:nQtde,3)
		EndIF
		
		lRet:= .T.
		Self:cPauta	:= '1'
	EndIF
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvRecNT()
Método que irá fazer gravação dos valores de receitas não tributadas de 
PIS e COFINS, utilizados posteriormente nos registros M400/M800.

@author Erick G. Dias
@since 28/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------

Method GrvRecNT() Class FISX001

Local nBase	:= Iif(Self:cCSt=='05',Self:nBaseST,Self:nBase)
Local nValor  := Iif(Self:cCSt=='05',Self:nValST,Self:nVal)
Local nPos	:= 0	
Local	lCcz:= .F.

IF Self:cCst $ '04/06/07/08/09/' .OR. (Self:cCst == '05' .AND. Self:nAlq > 0)
	
	dbSelectArea('CKT')
	CKT->(dbSetOrder(1))
	DbSelectArea ("CCZ")
	CCZ->(DbSetOrder (1))
	
	//Procuro CCZ para obter a descrição do código da Natureza da Receita.
	lCcz:= CCZ->(msSeek(xFilial("CCZ")+Self:cTNatRec+Self:cCNatRec+Self:cGNatRec+dTos(Self:dDNatRec)))
	
	nPos:=aScan(Self:aCKT,{|aX| aX[1]==Self:BuscaxFil('CKT').AND. aX[2]==Self:dDtIni .AND. aX[3] == Self:cTrib .AND. aX[4] == Self:cCst ;
								  .AND. aX[5] == Self:cCNatRec  .AND. aX[7] == PADR(Self:cConta,Self:nTamCtaCKT)   .AND. aX[9] == Self:cConsl .AND. aX[10] == Self:cOrigem })
	
	IF nPos == 0
		aAdd(Self:aCKT, {})
		nPos := Len(Self:aCKT)
	
		aAdd (Self:aCKT[nPos], Self:BuscaxFil('CKT'))
		aAdd (Self:aCKT[nPos], Self:dDtIni)
		aAdd (Self:aCKT[nPos], Self:cTrib)
		aAdd (Self:aCKT[nPos], Self:cCst)
		aAdd (Self:aCKT[nPos], Self:cCNatRec)		
		aAdd (Self:aCKT[nPos], Self:nReceita)
		aAdd (Self:aCKT[nPos], PADR(Self:cConta,Self:nTamCtaCKT))
		aAdd (Self:aCKT[nPos], Iif(lCcz ,CCZ->CCZ_DESC,''))
		aAdd (Self:aCKT[nPos], Self:cConsl)	
		aAdd (Self:aCKT[nPos], Self:cOrigem)
	
	Else
		Self:aCKT[nPos][6]	+= Self:nReceita
	EndIF

EndIF	


Return
//----------------------------------------------------

//DECLARAÇÃO DA CLASSE VALORESCST 

//----------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} VALORESCST
CLASSE PARA TRATAR INFORMAÇÕES DE SAÍDAS POR CÓDIGO DE CST DE PIS E DA      
COFINS.  

@author Erick G. Dias
@since 24/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------

CLASS VALORESCST FROM EFDGEN

Data cCst			 As String		HIDDEN   //Código do CST   
Data nBaseNC 	 	 As integer	HIDDEN //Base de Cálculo Não Cumulativo
Data nReceitaNC    As integer	HIDDEN //Valor da Receita Não Cumulativo
Data nBaseC 	 	 As integer 	HIDDEN//Base de Cálculo Cumulativo
Data nReceitaC 	 As integer 	HIDDEN//Valor da Receita Cumulativo
Data aTotCST	  	 As Array		HIDDEN//Array com CFOPS para considerar como receita

METHOD GetBaseNC(Value)
METHOD GetRecNC(Value)
METHOD GetBaseC(Value)
METHOD GetRecC(Value)
METHOD LOADTOTCST(Value)
METHOD New()

ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método Contrutor da Classe VALORESCST

@author Erick G. Dias
@since 24/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
METHOD New() Class VALORESCST
	Self:aTotCST:={}
	Self:cConsl		:= '2'
	Self:IniHash()
Return  Self

//-------------------------------------------------------------------
/*/{Protheus.doc} GetBaseNC()
Método para retornar valor da base de cálculo Não Cumulativo

@author Erick G. Dias
@return	Valor da base de cálculo não cumulativa
@since 24/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method GetBaseNC(cCSt) Class VALORESCST
Return x001SaiCst(Self:aTotCST,cCst,2)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetRecNC()
Método para retornar valor da base de cálculo Não Cumulativo

@author Erick G. Dias
@return	Valor da receita não cumulativa 
@since 24/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method GetRecNC(cCSt) Class VALORESCST
Return x001SaiCst(Self:aTotCST,cCst,3)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetBaseNC()
Método para retornar valor da base de cálculo  Cumulativo

@author Erick G. Dias
@return	Valor da base de cálculo  cumulativa
@since 24/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method GetBaseC(cCSt) Class VALORESCST
Return x001SaiCst(Self:aTotCST,cCst,4)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetRecC()
Método para retornar valor da base de cálculo  Cumulativo

@author Erick G. Dias
@return	Valor da receita  cumulativa 
@since 24/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method GetRecC(cCSt) Class VALORESCST
Return x001SaiCst(Self:aTotCST,cCst,5)

//-------------------------------------------------------------------
/*/{Protheus.doc} x001SaiCst()
Função que irá buscar valor correspondente ao CST para os métodos GetBaseNC,
GetRecNC, GetBaseC e GetRecC.

@param	aTotCST 	- Array com informações da tabela CL0
		cCst		-CST de PIS/COFINS
		nColuna	-Número da coluna da tela de saídas por CST e regime
			

@author Erick G. Dias
@return	Valor correspondente ao CST e coluna passados 
@since 24/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function x001SaiCst(aTotCST,cCst,nColuna)

	Local nRet	:= 0
	Local nPos	:= 0


	If Len(cCst) > 2
		For nPos := 1 to Len(aTotCST)
			nRet	+= Iif(aTotCST[nPos][1] $ cCst,aTotCST[nPos][nColuna],0)
		Next nPos
	Else
		nPos:=aScan(aTotCST,{|aX| aX[1]==cCst})
		If nPos > 0
			nRet := aTotCST[nPos][nColuna]
		EndIF
	EndIF

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadTotCST()
Método que buscar e agrupa valores por CST e regime.


@author Erick G. Dias 
@since 24/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method LoadTotCST() Class VALORESCST

	Local cAliasCL0	:= 'CL0'
	Local cSlctCL0	:= ''
	Local cFiltro		:= ''
	Local cGroupBy	:= ''
	cSlctCL0:= '%CL0.CL0_CST,	SUM(CL0.CL0_BASENC) AS CL0_BASENC,		SUM(CL0.CL0_VLOPNC) AS CL0_VLOPNC,		SUM(CL0.CL0_BASEC) AS CL0_BASEC,		SUM(CL0.CL0_VLOPC) AS CL0_VLOPC%'

	cGroupBy:= '%GROUP BY CL0.CL0_CST%'

	cFiltro := "%"
	cFiltro += "CL0.CL0_FILIAL= '"+ Self:BuscaxFil('CL0')+ "' AND "
	cFiltro += "CL0.CL0_PER>= '" + %Exp:DToS (Self:dDtIni)% + "' AND "
	cFiltro += "CL0.CL0_PER<= '" + %Exp:DToS (Self:dDtIni)% + "' AND "
	cFiltro += "CL0.CL0_CONSOL = '" + Self:cConsl+ "' AND "	
	cFiltro += "%"

	cAliasCL0	:=	GetNextAlias()
	BeginSql Alias cAliasCL0
    	
		SELECT
		%Exp:cSlctCL0%

		FROM
		%Table:CL0% CL0
		WHERE
		%Exp:cFiltro%
		CL0.%NotDel%
		
		%Exp:cGroupBy%
		
	EndSql
	DbSelectArea (cAliasCL0)
	(cAliasCL0)->(DbGoTop ())
	Do While !(cAliasCL0)->(Eof ())
	
	//Adiciona valores agrupados por CST.
		aAdd(Self:aTotCST, {(cAliasCL0)->CL0_CST,(cAliasCL0)->CL0_BASENC,(cAliasCL0)->CL0_VLOPNC,(cAliasCL0)->CL0_BASEC,(cAliasCL0)->CL0_VLOPC})
			
		(cAliasCL0)->(DbSkip ())
	EndDo
	DbSelectArea (cAliasCL0)
	(cAliasCL0)->(DbCloseArea())

Return

//----------------------------------------------------

//DECLARAÇÃO DA CLASSE COMPDEBITO 

//----------------------------------------------------
//-------------------------------------------------------------------
/*/{Protheus.doc} COMPDEBITO
CLASSE PARA TRATAR INFORMAÇÕES DE DA COMPOSIÇÃO DOS DÉBITOS DE PIS E        
COFINS DO PERÍODO

@author Erick G. Dias
@since 24/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------

CLASS COMPDEBITO FROM EFDGEN
	Data nValConPIS 	 As integer //Valor da contribuição apurada de PIS
	Data nValConCOF    As integer //Valor da contribuição apurada de COFINS
	Data nAjuAPis 	 	 As integer //Total de Ajustes de Acréscimo PIS
	Data nAjuACof 	 	 As integer //Total de Ajustes de Acréscimo COFINS
	Data nAjuRPis 	 	 As integer //Total de Ajustes de Redução PIS
	Data nAjuRCof 	 	 As integer //Total de Ajustes de Redução COFINS
	Data nDifPis 	 	 As integer //Total de Diferimento de PIS
	Data nDifCof 	 	 As integer //Total de Diferimento de COFINS
	Data nDifAPis 	 	 As integer //Total de Diferimento Anterior de PIS
	Data nDifACof 	 	 As integer //Total de Diferimento Anterior de COFINS
	Data nPisApur 	 	 As integer //Valor Apurado e disponível de PIS
	Data nCofApur 	 	 As integer //Valor Apurado e disponível de COFINS
	Data nAjuBsAPis 	 As integer //Ajuste de Acréscimo de base de PIS
	Data nAjuBsACof 	 As integer //Ajuste de Acréscimo de base de COFINS
	Data nAjuBsRPis 	 As integer //Ajuste de Acréscimo de base de PIS
	Data nAjuBsRCof 	 As integer //Ajuste de Acréscimo de base de COFINS	
	Data lCmpAjuBas 	As Boolean

	METHOD LoadDebito(Value)
	Method GetTotCon(cTrib)
	METHOD GetAjuAcre(cTrib)
	METHOD GetAjuRed(cTrib)
	METHOD GetDif(cTrib)
	METHOD GetDifAnt(cTrib)
	METHOD GetValDisp(cTrib)
	METHOD AtuSocCoop(cRegime)
	METHOD AtuDebito(cRegime)
	METHOD GetAjBsAcr(cTrib)
	METHOD GetAjBsRed(cTrib)
	METHOD New()

ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método Contrutor da Classe COMPDEBITO

@author Erick G. Dias
@since 24/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
METHOD New() Class COMPDEBITO
	Self:nValConPIS	:= 0
	Self:nValConCOF	:= 0
	Self:nAjuAPis		:= 0
	Self:nAjuACof		:= 0
	Self:nAjuRPis		:= 0
	Self:nAjuRCof		:= 0
	Self:nDifPis		:= 0
	Self:nDifCof		:= 0
	Self:nDifAPis		:= 0
	Self:nDifACof		:= 0
	Self:nPisApur		:= 0
	Self:nCofApur		:= 0
	Self:cConsl		:= '2'
	Self:nAjuBsAPis	:= 0
	Self:nAjuBsACof	:= 0
	Self:nAjuBsRPis	:= 0
	Self:nAjuBsRCof	:= 0
	Self:lCmpAjuBas	:= CKS->(FieldPos("CKS_BCAJUS"))>0 
	Self:IniHash()

Return  Self

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTotCon()
Método que volta o valor da contribuição Processada no período

@author Erick G. Dias
@return	Valor da Contribuição apurada 
@since 24/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method GetTotCon(cTrib) Class COMPDEBITO
Return Iif(cTrib=='1',Self:nValConPIS,Self:nValConCOF)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetAjuAcre()
Método que volta o valor do total de ajuste de crédito de acréscimo

@author Erick G. Dias
@return Valor Total de Ajuste de Acréscimo 
@since 24/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method GetAjuAcre(cTrib) Class COMPDEBITO
Return Iif(cTrib=='1',Self:nAjuAPis,Self:nAjuACof)


Method GetAjBsAcr(cTrib) Class COMPDEBITO
Return Iif(cTrib=='1',Self:nAjuBsAPis,Self:nAjuBsACof)

Method GetAjBsRed(cTrib) Class COMPDEBITO
Return Iif(cTrib=='1',Self:nAjuBsRPis,Self:nAjuBsRCof)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetAjuRed()
Método que volta o valor do total de ajuste de crédito de redução

@author Erick G. Dias
@return	Valor Total de Redução 
@since 24/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method GetAjuRed(cTrib) Class COMPDEBITO
Return Iif(cTrib=='1',Self:nAjuRPis,Self:nAjuRCof)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDif()
Método que volta o valor do total de diferimento do período

@author Erick G. Dias
@return	Valor Total do Diferimento do Período
@since 24/04/2014
@version 11.80
/*/
//------------------------------------------------------------------
Method GetDif(cTrib) Class COMPDEBITO
Return Iif(cTrib=='1',Self:nDifPis,Self:nDifCof)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDifAnt()
Método que volta o valor do total de diferimento de período anterior

@author Erick G. Dias
@return	Valor Total do Diferimento de Período Anterior
@since 24/04/2014
@version 11.80
/*/
//------------------------------------------------------------------
Method GetDifAnt(cTrib) Class COMPDEBITO
Return Iif(cTrib=='1',Self:nDifAPis,Self:nDifACof)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetValDisp()
Método que volta o valor do total disponível do tributo

@author Erick G. Dias
@return	Valor Total disponível do tributo
@since 24/04/2014
@version 11.80
/*/
//------------------------------------------------------------------
Method GetValDisp(cTrib) Class COMPDEBITO
Return Iif(cTrib=='1',Self:nPisApur,Self:nCofApur)

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadDebito()
Método que carrega os valores de débitos processados conforme regime
solicitado

@param	 cRegime	- Regime que deverá ser buscado:1-Não Cumulativo; 2-Cumulativo
@author Erick G. Dias
@since 24/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method LoadDebito(cRegime) Class COMPDEBITO
	Local cAliasCKZ	:= x001QRYCKS('1',Self:dDtIni,cRegime,Self:BuscaxFil('CKZ'),Self:cConsl)

	DbSelectArea (cAliasCKZ)
	(cAliasCKZ)->(DbGoTop ())
	
	Self:nValConPIS	:=	0
	Self:nAjuAPis		:=	0
	Self:nAjuRPis		:=	0
	Self:nDifPis		:=	0
	Self:nDifAPis		:=	0
	Self:nPisApur		:=	0	
	Self:nValConCOF	:=	0
	Self:nAjuACof		:=	0
	Self:nAjuRCof		:=	0
	Self:nDifCof		:=	0
	Self:nDifACof		:=	0
	Self:nCofApur		:=	0	
	Self:nAjuBsAPis		:= 0
	Self:nAjuBsACof		:= 0
	Self:nAjuBsRPis		:= 0
	Self:nAjuBsRCof		:= 0		
	
	Do While !(cAliasCKZ)->(Eof ())
	//----------------------------------------------------------------------
	//AQUI ACUMULA OS VALORES DOS DÉBITOS AGRUPADOS POR TRIBUTO E POR REGIME
	//----------------------------------------------------------------------
		If (cAliasCKZ)->CKZ_TRIB == '1' //Valores de PIS
			Self:nValConPIS	+=	(cAliasCKZ)->CKS_VLTRIB
			Self:nAjuAPis	+=	(cAliasCKZ)->CKS_AJAC
			Self:nAjuRPis	+=	(cAliasCKZ)->CKS_AJRD
			Self:nDifPis	+=  (cAliasCKZ)->CKS_DIF
			Self:nDifAPis	+= (cAliasCKZ)->CKS_DIFANT
			Self:nPisApur	+= (cAliasCKZ)->CKS_VLDISP
			IF Self:lCmpAjuBas
				Self:nAjuBsAPis	+=	(cAliasCKZ)->CKS_AJBCA
				Self:nAjuBsRPis	+=	(cAliasCKZ)->CKS_AJBCR			
			EndIF
		ElseIF (cAliasCKZ)->CKZ_TRIB == '2' // Valores da COFINS
			Self:nValConCOF	+=	(cAliasCKZ)->CKS_VLTRIB
			Self:nAjuACof	+=	(cAliasCKZ)->CKS_AJAC
			Self:nAjuRCof	+=	(cAliasCKZ)->CKS_AJRD
			Self:nDifCof	+=  (cAliasCKZ)->CKS_DIF
			Self:nDifACof	+= (cAliasCKZ)->CKS_DIFANT
			Self:nCofApur	+= (cAliasCKZ)->CKS_VLDISP			
			IF Self:lCmpAjuBas
				Self:nAjuBsACof	+=	(cAliasCKZ)->CKS_AJBCA
				Self:nAjuBsRCof	+=	(cAliasCKZ)->CKS_AJBCR			
			EndIF
		EndIF
		
		(cAliasCKZ)->(DbSkip ())
	EndDo

	DbSelectArea (cAliasCKZ)
	(cAliasCKZ)->(DbCloseArea())
Return

Method AtuDebito(cRegime,cTrib) Class COMPDEBITO

Local nValDeb	:= 0
Self:LoadDebito(cRegime)	//Buscar débitos Não Cumulativos
nValDeb:= Self:GetValDisp(cTrib)

If CKR->(MSSEEK(Self:BuscaxFil('CKR')+dTos(Self:dDtIni)+Self:cConsl+cTrib))
	RecLock('CKR',.F.)
	
	If cRegime == '1'
		CKR_CONNC	:= nValDeb
		CKR_NCREC := CKR_CONNC  - CKR_CRDANT - CKR_CRDATU - CKR_RTANTN - CKR_RTATUN - CKR_OUTDNC				
	ElseIF cRegime == '2'
		CKR_CONC	:= nValDeb
		CKR_CREC := CKR_CONC - CKR_RTANTC - CKR_RTATUC - CKR_OUTDC			
	EndIF
	MsUnLock()
EndIF


Return

Method AtuSocCoop(cRegime) Class COMPDEBITO

Local cAliasCKZ	:= x001QRYCKS('4',Self:dDtIni,cRegime,Self:BuscaxFil('CKZ'),Self:cConsl)
Local cPer		:= StrZero(Month(Self:dDtIni),2)+str(Year(Self:dDtIni),4)
Local nNovaBase	:= 0
Local nValDebPIS := 0
Local nValDebCOF := 0
Local oTabCE9 := TABELACE9():New()
Local nTributo := 0
Local lAtuCKR := .F.
Local nBaseAjus := 0
Local nValExcl := 0
Local nBase := 0

oTabCE9:SetPeriodo(cPer)
oTabCE9:LoadData()  

DbSelectArea (cAliasCKZ)
(cAliasCKZ)->(DbGoTop ())

Do While !(cAliasCKZ)->(Eof ())

	nNovaBase := 0	 
	
	If (cAliasCKZ)->CKZ_TRIB == '1'
		oTabCE9:SetTributo("PIS")	
	ElseIF (cAliasCKZ)->CKZ_TRIB == '2'
		oTabCE9:SetTributo("COF")
	EndIF
	
	//Para as operações com pauta não serão efetuadas as exclusões de Sociedade cooperativa, conforme orientação do guia pratico.
	If !((cAliasCKZ)->CKZ_COD $ '03/53')
		nBase := IIf(dtos(Self:dDtIni) >= '20190101' .And. Self:lCmpAjuBas,;
						(cAliasCKZ)->CKS_BCAJUS,;
						(cAliasCKZ)->CKS_BASE)
		nValExcl := oTabCE9:GetExclusao((cAliasCKZ)->CKZ_COD, nBase, (cAliasCKZ)->CKZ_ALIQ)
		nNovaBase:= (cAliasCKZ)->CKS_BASE - nValExcl
		If dtos(Self:dDtIni) >= '20190101' .And. Self:lCmpAjuBas
			nBaseAjus:= (cAliasCKZ)->CKS_BCAJUS - nValExcl
		EndIf
	EndIf

	/*
	Query agrupada por código e Alíquota CKS

	Rodar query
	
	Verificar se exclusão é maior ou não que o valor da contribuição
	
	se não for rodar array espelho da CKS para fazer a exclusão
	
	Após finalizar atualizar valores do array espelho para CKS
	
	*/
	
	If CKS->(MSSEEK(xFilial('CKS')+dTos(Self:dDtIni)+(cAliasCKZ)->CKZ_ID))
		//Atualiza tabela CKS
		RecLock('CKS',.F.)
		
		CKS->CKS_BASE		:= nNovaBase
		CKS->CKS_VLTRIB	:=	Round((CKS->CKS_BASE	 * (cAliasCKZ)->CKZ_ALIQ) / 100,2)
		If dtos(Self:dDtIni) >= '20190101' .And. Self:lCmpAjuBas
			CKS->CKS_BCAJUS		:= nBaseAjus
			CKS->CKS_VLTRIB	:=	Round((CKS->CKS_BCAJUS	 * (cAliasCKZ)->CKZ_ALIQ) / 100,2)
		EndIf
		CKS->CKS_VLDISP	:=	CKS_VLTRIB+CKS_AJAC-CKS_AJRD-CKS_DIF+CKS_DIFANT
		
		If (cAliasCKZ)->CKZ_TRIB == '1'
			nValDebPIS += CKS->CKS_VLTRIB 
		ElseIF (cAliasCKZ)->CKZ_TRIB == '2'
			nValDebCOF += CKS->CKS_VLTRIB
		EndIf
		
		MsUnLock()
	EndIF
				
	lAtuCKR := .T.

	(cAliasCKZ)->(DbSkip ())
EndDo

DbSelectArea (cAliasCKZ)
(cAliasCKZ)->(DbCloseArea())

// Atualizando Tabela CKR com os valores finais de contribuicao

If lAtuCKR

	For nTributo := 1 to 2
	
		If CKR->(MSSEEK(Self:BuscaxFil('CKR')+dTos(Self:dDtIni)+Self:cConsl+cValToChar(nTributo)))
			RecLock('CKR',.F.)			
			If cRegime == '1'
				CKR_CONNC	:= IIf(nTributo == 1, nValDebPIS, nValDebCOF)
				CKR_NCREC := CKR_CONNC  - CKR_CRDANT - CKR_CRDATU - CKR_RTANTN - CKR_RTATUN - CKR_OUTDNC				
			ElseIF cRegime == '2'
				CKR_CONC	:= IIf(nTributo == 1, nValDebPIS, nValDebCOF)
				CKR_CREC := CKR_CONC - CKR_RTANTC - CKR_RTATUC - CKR_OUTDC			
			EndIF
			MsUnLock()
		EndIF
	
	Next nTributo
	
EndIf

FreeObj(oTabCE9)
oTabCE9:= Nil

Return


//----------------------------------------------------

//DECLARAÇÃO DA CLASSE CMPCREDITO 

//----------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} CMPCREDITO
CLASSE PARA TRATAR INFORMAÇÕES DE DA COMPOSIÇÃO DOS CRÉDITOS DE PIS E        
COFINS DO PERÍODO

@author Erick G. Dias
@since 25/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------

CLASS CMPCREDITO FROM EFDGEN

	Data nBasePis 		 As integer //Valor da contribuição apurada de PIS
	Data nBaseCof 	 	 As integer //Valor da contribuição apurada de PIS
	Data nAtfDPis 	 	 As integer //Valor da contribuição apurada de PIS
	Data nAtfDCof 	  	 As integer //Valor da contribuição apurada de PIS
	Data nAtfAPis 	  	 As integer //Valor da contribuição apurada de PIS
	Data nAtfACof 	 	 As integer //Valor da contribuição apurada de PIS
	Data nCrdPrePis 	 As integer //Valor da contribuição apurada de PIS
	Data nCrdPreCof 	 As integer //Valor da contribuição apurada de PIS
	Data nTotBasPis 	 As integer //Valor da contribuição apurada de PIS
	Data nTotBasCof 	 As integer //Valor da contribuição apurada de PIS
	Data nBaseApPis 	 As integer //Valor da contribuição apurada de PIS
	Data nBaseApCof 	 As integer //Valor da contribuição apurada de PIS
	Data nAjuAcrPis 	 As integer //Valor da contribuição apurada de PIS
	Data nAjuAcrCof 	 As integer //Valor da contribuição apurada de PIS
	Data nAjuRedPis 	 As integer //Valor da contribuição apurada de PIS
	Data nAjuRedCof 	 As integer //Valor da contribuição apurada de PIS
	Data nValDifPis 	 As integer //Valor da contribuição apurada de PIS
	Data nValDifCof 	 As integer //Valor da contribuição apurada de PIS
	Data nVlDispPis	 As integer //Valor da contribuição apurada de PIS
	Data nVlDispCof 	 As integer //Valor da contribuição apurada de PIS
	Data nVlUtiPis		 As integer
	Data nVlUtiCof	 	As integer	
	Data nVlFutPis	 	As integer
	Data nVlFutCof	 	As integer		
	Data nCrdApuPis	As integer	
	Data nCrdApuCof	As integer
	Data aCL8			 As Aray

	METHOD LoadCredit(Value)
	Method GetBseApur(cTrib)
	Method GetCrdAtfD(cTrib)
	Method GetCrdAtfA(cTrib)
	Method GetCrdPres(cTrib)
	Method GeTTotBase(cTrib)
	Method GeTBasApur(cTrib)
	Method GetCredApu(cTrib)
	Method GeTAjuAcre(cTrib)
	Method GeTAjuRed(cTrib)
	Method GeTVlDif(cTrib)
	Method GeTVlDisp(cTrib)
	Method GeTVlFut (cTrib)
	Method GeTVlUti(cTrib)	
	Method DedCred(cTrib)
	Method PercDif(cTrib)
	Method GetAjBsAcr(cTrib)
	Method GetAjBsRed(cTrib)

	METHOD New()

ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método Contrutor da Classe CMPCREDITO

@author Erick G. Dias
@since 28/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
METHOD New() Class CMPCREDITO
	Self:nBasePis		:=0
	Self:nBaseCof		:=0
	Self:nAtfDPis		:=0
	Self:nAtfDCof		:=0
	Self:nAtfAPis		:=0
	Self:nAtfACof		:=0
	Self:nCrdPrePis	:=0
	Self:nCrdPreCof	:=0
	Self:nTotBasPis	:=0
	Self:nCrdApuPis	:=0	
	Self:nCrdApuCof	:=0	
	Self:nTotBasCof	:=0
	Self:nBaseApPis	:=0
	Self:nBaseApCof	:=0
	Self:nAjuAcrPis	:=0
	Self:nAjuAcrCof	:=0
	Self:nAjuRedPis	:=0
	Self:nAjuRedCof	:=0
	Self:nValDifPis	:=0
	Self:nValDifCof	:=0
	Self:nVlDispPis	:=0
	Self:nVlDispCof	:=0	
	Self:nVlUtiPis	:=0
	Self:nVlUtiCof	:=0
	Self:nVlFutPis	:= 0
	Self:nVlFutCof	:= 0
	Self:aCL8			:={}
	Self:cConsl		:= '2'	
	Self:IniHash()

Return  Self

Method GeTVlFut (cTrib)Class CMPCREDITO
Return Iif(cTrib=='1',Self:nVlFutPis ,Self:nVlFutCof)


Method GeTVlUti(cTrib) Class CMPCREDITO
Return Iif(cTrib=='1',Self:nVlUtiPis ,Self:nVlUtiCof)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetBseApur()
Método que volta o valor da base apurada no período, ainda sem sofre 
qualquer ajuste ou redução.

@param - cTrib - Tributo a ser processado 1-PIS;2-COFINS
@author Erick G. Dias
@return	Valor Total do Diferimento de Período Anterior
@since 28/04/2014
@version 11.80
/*/
//------------------------------------------------------------------
Method GetBseApur(cTrib) Class CMPCREDITO
Return Iif(cTrib=='1',Self:nBasePis ,Self:nBaseCof)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCrdAtfD()
Método que volta o valor da base de cálculo referente aos bens
por depreciação.

@param - cTrib - Tributo a ser processado 1-PIS;2-COFINS
@author Erick G. Dias
@return	Valor Total do Diferimento de Período Anterior
@since 28/04/2014
@version 11.80
/*/
//------------------------------------------------------------------
Method GetCrdAtfD(cTrib) Class CMPCREDITO
Return Iif(cTrib=='1',Self:nAtfDPis ,Self:nAtfDCof)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCrdAtfA()
Método que volta o valor da base de cálculo referente aos bens
por aquisição.

@param - cTrib - Tributo a ser processado 1-PIS;2-COFINS
@author Erick G. Dias
@return	Valor Total do Diferimento de Período Anterior
@since 28/04/2014
@version 11.80
/*/
//------------------------------------------------------------------

Method GetCrdAtfA(cTrib) Class CMPCREDITO
Return Iif(cTrib=='1',Self:nAtfAPis ,Self:nAtfACof)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCrdPres()
Método que volta o valor da base de cálculo referente as 
operações com direito ao crédito presumido.

@param - cTrib - Tributo a ser processado 1-PIS;2-COFINS
@author Erick G. Dias
@return	Valor Total do Diferimento de Período Anterior
@since 28/04/2014
@version 11.80
/*/
//------------------------------------------------------------------

Method GetCrdPres(cTrib) Class CMPCREDITO
Return Iif(cTrib=='1',Self:nCrdPrePis ,Self:nCrdPreCof)

//-------------------------------------------------------------------
/*/{Protheus.doc} GeTTotBase()
Método que volta da soma de todas as bases de cálculo ainda sem sofrer
nenhum ajuste ou redução.

@param - cTrib - Tributo a ser processado 1-PIS;2-COFINS
@author Erick G. Dias
@return	Valor Total do Diferimento de Período Anterior
@since 28/04/2014
@version 11.80
/*/
//------------------------------------------------------------------
Method GeTTotBase(cTrib) Class CMPCREDITO
Return Iif(cTrib=='1',Self:nTotBasPis ,Self:nTotBasCof)

//-------------------------------------------------------------------
/*/{Protheus.doc} GeTBasApur()
Método que volta o valor total da base de cálculo após rateio proporcional
se houver.

@param - cTrib - Tributo a ser processado 1-PIS;2-COFINS
@author Erick G. Dias
@return	Valor Total do Diferimento de Período Anterior
@since 28/04/2014
@version 11.80
/*/
//------------------------------------------------------------------
Method GeTBasApur(cTrib) Class CMPCREDITO

Return Iif(cTrib=='1',Self:nTotBasPis ,Self:nTotBasCof)

Method GetCredApu(cTrib) Class CMPCREDITO

Return Iif(cTrib=='1',Self:nCrdApuPis ,Self:nCrdApuCof)

//-------------------------------------------------------------------
/*/{Protheus.doc} GeTAjuAcre()
Método que retorna o valor total de ajustes de acréscimo de crédito

@param - cTrib - Tributo a ser processado 1-PIS;2-COFINS
@author Erick G. Dias
@return	Valor Total do Diferimento de Período Anterior
@since 28/04/2014
@version 11.80
/*/
//------------------------------------------------------------------
Method GeTAjuAcre(cTrib) Class CMPCREDITO
Return Iif(cTrib=='1',Self:nAjuAcrPis ,Self:nAjuAcrCof)

//-------------------------------------------------------------------
/*/{Protheus.doc} GeTAjuRed()
Método que retorna o valor total de ajustes de redução de crédito

@param - cTrib - Tributo a ser processado 1-PIS;2-COFINS
@author Erick G. Dias
@return	Valor Total do Diferimento de Período Anterior
@since 28/04/2014
@version 11.80
/*/
//------------------------------------------------------------------
Method GeTAjuRed(cTrib) Class CMPCREDITO
Return Iif(cTrib=='1',Self:nAjuRedPis ,Self:nAjuRedCof)

//-------------------------------------------------------------------
/*/{Protheus.doc} GeTVlDif()
Método que retorna o valor total de diferimento do crédito

@param - cTrib - Tributo a ser processado 1-PIS;2-COFINS
@author Erick G. Dias
@return	Valor Total do Diferimento de Período Anterior
@since 28/04/2014
@version 11.80
/*/
//------------------------------------------------------------------
Method GeTVlDif(cTrib) Class CMPCREDITO
Return Iif(cTrib=='1',Self:nValDifPis ,Self:nValDifCof)

//-------------------------------------------------------------------
/*/{Protheus.doc} GeTVlDisp()
Método que retorna o valor total de crédito disponível para utilização
para deduzir os débitos na apuração, após todos os ajustes e reduções.

@param - cTrib - Tributo a ser processado 1-PIS;2-COFINS
@author Erick G. Dias
@return	Valor Total do Diferimento de Período Anterior
@since 28/04/2014
@version 11.80
/*/
//------------------------------------------------------------------
Method GeTVlDisp(cTrib) Class CMPCREDITO
Return Iif(cTrib=='1',Self:nVlDispPis ,Self:nVlDispCof)

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadCredit()
Método que carrega os valores de créditos de PIS e COFINS processados.
Como são créditos, irei buscar na tabela CKZ somente as operações
do Regime Não Cumulativo.

@author Erick G. Dias
@since 28/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method LoadCredit(cTributo) Class CMPCREDITO
	Local cAliasCKZ	:= x001QRYCL8('1',Self:dDtIni,,Self:BuscaxFil('CKZ'),Self:cConsl)	

	DbSelectArea (cAliasCKZ)
	(cAliasCKZ)->(DbGoTop ())
	Do While !(cAliasCKZ)->(Eof ())
	//----------------------------------------------------------------------
	//AQUI ACUMULA OS VALORES DOS DÉBITOS AGRUPADOS POR TRIBUTO E POR REGIME
	//----------------------------------------------------------------------
		If (cAliasCKZ)->CKZ_TRIB == '1' //Valores de PIS

			IF (cAliasCKZ)->CL9_PAUTA == '2' //Se não for pauta então considera cálculo na base de cálculo
				IF (cAliasCKZ)->CL8_CODBCC $'09/11'
					Self:nAtfDPis	+= (cAliasCKZ)->CL8_BSCALC
				ElseIF (cAliasCKZ)->CL8_CODBCC =='10'
					Self:nAtfAPis	+= (cAliasCKZ)->CL8_BSCALC
				ElseIF SubStr((cAliasCKZ)->CL8_CST,1,1) == '6'
					Self:nCrdPrePis	+=(cAliasCKZ)->CL8_BSCALC
				Else
					Self:nBasePis		+= (cAliasCKZ)->CL8_BSCALC
				EndIF	
			EndIF	
			
			Self:nAjuAcrPis	+= (cAliasCKZ)->CL8_AJAC
			Self:nAjuRedPis	+= (cAliasCKZ)->CL8_AJRD
			Self:nValDifPis	+= (cAliasCKZ)->CL8_DIF
			Self:nVlDispPis	+= (cAliasCKZ)->CL8_TOTCRD
			IF (cAliasCKZ)->CL9_PAUTA == '2'
				Self:nTotBasPis  += (cAliasCKZ)->CL8_BSCALC
			EndIF			
			Self:nVlUtiPis	+= (cAliasCKZ)->CL8_CRDUTI
			Self:nVlFutPis	+= (cAliasCKZ)->CL8_CRDFUT
			Self:nCrdApuPis	+=	(cAliasCKZ)->CL8_VLCRED 		
			
		ElseIF (cAliasCKZ)->CKZ_TRIB == '2' // Valores da COFINS
			
			IF (cAliasCKZ)->CL9_PAUTA == '2'
				IF (cAliasCKZ)->CL8_CODBCC $'09/11'
					Self:nAtfDCof	+= (cAliasCKZ)->CL8_BSCALC
				ElseIF (cAliasCKZ)->CL8_CODBCC =='10'
					Self:nAtfACof	+= (cAliasCKZ)->CL8_BSCALC
				ElseIF SubStr((cAliasCKZ)->CL8_CST,1,1) == '6'
					Self:nCrdPreCof	+=(cAliasCKZ)->CL8_BSCALC
				Else
					Self:nBaseCof		+= (cAliasCKZ)->CL8_BSCALC
				EndIF
			EndIF
			
			Self:nAjuAcrCof	+= (cAliasCKZ)->CL8_AJAC
			Self:nAjuRedCof	+= (cAliasCKZ)->CL8_AJRD
			Self:nValDifCof	+= (cAliasCKZ)->CL8_DIF
			Self:nVlDispCof	+= (cAliasCKZ)->CL8_TOTCRD
			IF (cAliasCKZ)->CL9_PAUTA == '2'
				Self:nTotBascOF  += (cAliasCKZ)->CL8_BSCALC
			EndIF
			Self:nVlUtiCof	+= (cAliasCKZ)->CL8_CRDUTI
			Self:nVlFutCof	+= (cAliasCKZ)->CL8_CRDFUT
			Self:nCrdApuCof	+=	(cAliasCKZ)->CL8_VLCRED									
		EndIF
		
		(cAliasCKZ)->(DbSkip ())
	EndDo

	DbSelectArea (cAliasCKZ)
	(cAliasCKZ)->(DbCloseArea())
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} DedCred()
Função que irá fazer o controle para deduzir os créditos de PIS e COFINS
dos débitos. Este método somente deverá ser chamado após ter processado
todos ajustes, redução, diferimento tanto do crédito quando débito.
Aqui será feito controle dos créditos do período quanto o do saldo 
de cre´ditos.

@author Erick G. Dias
@since 19/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method DedCred(cTributo) Class CMPCREDITO
Local cAliasCKZ	:= ''//''x001QRYCL8('4',Self:dDtIni,cTributo)
local lGravaSld	:= .F.
local aSaldoAnt	:= {}
Local dDtAnt		:= firstday(Self:dDtIni) - 1
Local cPerAnt		:= Strzero(Month(dDtAnt),2)+cvaltochar(Year(dDtAnt))
Local cPerAtu		:= Strzero(Month(Self:dDtIni),2)+cvaltochar(Year(Self:dDtIni))	
Local nValNaoCum	:= 0
Local nValCum		:= 0
Local nCont			:= 0
Local nCont2		:= 0
Local nCrdAtu		:= 0
Local nCrdAnt		:= 0
Local nCrdAntInd	:= 0 //Crédito anterior utilizado individualmente
Local nSaldo		:= 0
Local nVlDeb		:= 0
Local nVlDebNC		:= 0
Local oSaldoCred
Local aTotCred		:= {}
Local cUltCodCKZ	:= ""
Local nPos			:= 0
Local lAnt			:= .F.
Local cCodCre		:= GetNewPar("MV_OCODCSC","")
Local aCodCre		:= StrTokArr(cCodCre,",")
Local nReserv		:= 0

aAdd(aCodCre,"") //-- todos codigos por ultimo.

IF FindFunction("ISA001NDIF") .AND. ISA001NDIF()
	Self:PercDif(cTributo)
EndIF
//----------------------------------------------------------------------
//CARREGA O VALOR DE DÉBITO NÃO CUMULATIVO PARA PODER ABATER OS CRÉDITOS
//----------------------------------------------------------------------
oDebito:= COMPDEBITO():New()
oDebito:SetConsol(Self:cConsl)
oDebito:SetFilial(Self:aFilial)
oDebito:SetDtIni(Self:dDtIni)
oDebito:LoadDebito('2')	//Buscar débitos Cumulativos
nValCum:= oDebito:GetValDisp(cTributo)
nVlDebNC:= nValCum
oDebito:LoadDebito('1')	//Buscar débitos Não Cumulativos
nValNaoCum:= oDebito:GetValDisp(cTributo)
nVlDeb	:= nValNaoCum 

//----------------------------------------------------------------------
//LIMPA VALORES DE SALDO DO PERÍODO PARA PODER ATUALIZAR O SALDO
//----------------------------------------------------------------------	
oSaldoCred:= SALDOCRED():New()
oSaldoCred:SetConsol(Self:cConsl)
oSaldoCred:SetFilial(Self:aFilial)
oSaldoCred:SetDtIni(Self:dDtIni)
oSaldoCred:SetTributo(cTributo)
oSaldoCred:SetPer(cPerAtu)
oSaldoCred:LimpaSaldo() //Limpa tabela de saldos somente do período

//Para período anterior para buscar os créditos de período anterior se houver.
oSaldoCred:SetPer(cPerAnt)	
//Carrega saldo de crédito do período anterior.
oSaldoCred:LoadSaldo(.T.)		

//Agora passa o período atual para poder buscar os créditos extemporâneos
oSaldoCred:SetPer(cPerAtu)	
//Carrega saldo de crédito do período anterior.
oSaldoCred:LoadExtemp() //e nesta tabela preenche da mesma maneira o array		

//Aqui retorna array com crédito de período anterior e crédito extemporâneo
aSaldoAnt:= oSaldoCred:GetSaldoAt()	
//Retornar data do período atual caso seja necessário inclusão de algum valor no saldo
//oSaldoCred:SetPer(cPerAtu)		

For nCont2 := 1 To Len(aCodCre)

	For nCont := 1 To Len(aSaldoAnt)

		If aSaldoAnt[nCont][1] == aCodCre[nCont2] .Or. (nCont2==Len(aCodCre) .And. !(aSaldoAnt[nCont][1] $ cCodCre))
			nCrdAntInd	:= 0
			IF !aSaldoAnt[nCont][18] =='1'
				If aSaldoAnt[nCont][2] <= nValNaoCum
					//Valor dos créditos menor ou igual ao valor da contribuição, não necessita gravação de saldo
					lGravaSld	:= .F.
					nSaldo		:= 0
					nValNaoCum	-= aSaldoAnt[nCont][2]
					nCrdAnt		+= aSaldoAnt[nCont][2]
					nCrdAntInd	:= aSaldoAnt[nCont][2]
				Else
					//Valor do crédito é maior que o valor da contribuição, neste caso necessita gravar saldo de crédito
					lGravaSld	:= .T.
					nSaldo		:= aSaldoAnt[nCont][2] - nValNaoCum
					nCrdAnt		+= nValNaoCum
					nCrdAntInd	:= nValNaoCum
					nValNaoCum	:= 0
				EndIf
			Else				
				nReserv 	:=   aSaldoAnt[nCont][2]				
			Endif

			If nCrdAnt >= 0 .OR. lGravaSld .Or. aSaldoAnt[nCont][18] =='1' // lGravaSld .OR. aSaldoAnt[nCont][17] //nCrdAnt//If
				oSaldoCred:SetCodCred(aSaldoAnt[nCont][1])
				oSaldoCred:SetCnpj(aSaldoAnt[nCont][10])
				oSaldoCred:SetOrigCrd(aSaldoAnt[nCont][3])
				oSaldoCred:SetAno(aSaldoAnt[nCont][4])
				oSaldoCred:SetMes(aSaldoAnt[nCont][5])
				oSaldoCred:SetTotCred(aSaldoAnt[nCont][7])
				oSaldoCred:SetCredUti(nCrdAntInd)
				oSaldoCred:SetCrdDisp(Iif(aSaldoAnt[nCont][18] =='1',nReserv,nSaldo))
				oSaldoCred:SetLexTem( Iif(aSaldoAnt[nCont][17],aSaldoAnt[nCont][9],0))
				oSaldoCred:SetUtiAnt(aSaldoAnt[nCont][7] - aSaldoAnt[nCont][16] - aSaldoAnt[nCont][14])
				oSaldoCred:SetComp(aSaldoAnt[nCont][12])
				oSaldoCred:SetRessar(aSaldoAnt[nCont][13])
				oSaldoCred:SetCoAnte(aSaldoAnt[nCont][14])
				oSaldoCred:SetReante(aSaldoAnt[nCont][7] - aSaldoAnt[nCont][16] - aSaldoAnt[nCont][15]- aSaldoAnt[nCont][14] - aSaldoAnt[nCont][8] - aSaldoAnt[nCont][11])
				oSaldoCred:SetReserv(aSaldoAnt[nCont][18])
				oSaldoCred:SetMesAtu(.F.)
				//Grava valor de crédito de PIS e COFINS para próximo período
				oSaldoCred:AcumSaldo()
				//Após acumlar os saldos o valor utilizado no periodo anterior deve ser zerado.
				oSaldoCred:SetUtiAnt(0)
			EndIf

		EndIf

	Next nCont

Next nCont2

cAliasCKZ := x001QRYCL8('4',Self:dDtIni,cTributo,Self:BuscaxFil('CKZ'),Self:cConsl)
//----------------------------------------------------------------------
//IRÁ PROCESSAR OS VALORES DOS CRÉDITOS DE PERÍODO ATUAL.
//----------------------------------------------------------------------
DbSelectArea (cAliasCKZ)
For nCont2 := 1 To Len(aCodCre)

	(cAliasCKZ)->(DbGoTop ())
	Do While !(cAliasCKZ)->(Eof ())

		If (cAliasCKZ)->CKZ_COD == aCodCre[nCont2] .Or. (nCont2==Len(aCodCre) .And. !((cAliasCKZ)->CKZ_COD $ cCodCre))
			If (cAliasCKZ)->CL8_TOTCRD <= nValNaoCum
				//Valor dos créditos menor ou igual ao valor da contribuição, não necessita gravação de saldo
				lGravaSld	:= .F.
				nSaldo	:=0
				nValNaoCum	-= (cAliasCKZ)->CL8_TOTCRD
				nCrdAtu		+= (cAliasCKZ)->CL8_TOTCRD
			Else
				//Valor do crédito é maior que o valor da contribuição, neste caso necessita gravar saldo de crédito
				lGravaSld	:= .T.
				nSaldo		:= (cAliasCKZ)->CL8_TOTCRD - nValNaoCum
				nCrdAtu		+= nValNaoCum
				nValNaoCum	:= 0
			EndIf

			If Empty(aTotCred) .Or. (cAliasCKZ)->CKZ_COD <> cUltCodCKZ 
				AADD(aTotCred,{(cAliasCKZ)->CKZ_COD, (cAliasCKZ)->CL8_TOTCRD, nSaldo,nValNaoCum })
			Else
				nPos := ASCAN(aTotCred, {|aX| aX[1]==(cAliasCKZ)->CKZ_COD})
				If nPos > 0
					aTotCred[nPos,2] += (cAliasCKZ)->CL8_TOTCRD
					aTotCred[nPos,3] += Iif(lGravaSld,nSaldo,0)
					aTotCred[nPos,4] += nValNaoCum
				EndIf
			EndIf

			//-------------------------------------------------------------------------------------------
			//ATUALIZA A TABELA DOS CRÉDITOS CONSOLIDADOS CONFORME FOR UTILIZANDO  OS VALORES DE CRÉDITOS
			//-------------------------------------------------------------------------------------------
			If CL8->(MSSEEK(Self:BuscaxFil('CL8')+dTos(Self:dDtIni)+(cAliasCKZ)->CKZ_ID+(cAliasCKZ)->CL8_INDCRE+(cAliasCKZ)->CL8_CODBCC+(cAliasCKZ)->CL8_CST))
				RecLock('CL8',.F.)

				If ! lGravaSld
					//Se não gravou saldo, é porque utilizou valor integral dos créditos
					CL8->CL8_CRDUTI	:= CL8->CL8_TOTCRD
				Else
					//Se gravou saldo, então deverá utilizar valor parcial
					CL8->CL8_CRDUTI	:= CL8->CL8_TOTCRD - nSaldo
				EndIf

				//Atualiza valor de crédito para utilizar em período futuro
				CL8->CL8_CRDFUT	:= CL8->CL8_TOTCRD -  CL8->CL8_CRDUTI

				//deverá reduzir o valor do crédito no caso de ajuste manual na tela

				MsUnLock()
			EndIf
		EndIf
		cUltCodCKZ := (cAliasCKZ)->CKZ_COD
		(cAliasCKZ)->(DbSkip ())
	EndDo

Next nCont2

If !Empty(aTotCred)	
	For nCont := 1  To Len(aTotCred) 	
		If  aTotCred[nCont,3] > 0
			oSaldoCred:SetCodCred(aTotCred[nCont,1])	
			oSaldoCred:SetCnpj(space(14))	
			oSaldoCred:SetOrigCrd('01')
			oSaldoCred:SetAno(cvaltochar(Year(Self:dDtIni)))	
			oSaldoCred:SetMes(Strzero(Month(Self:dDtIni),2))	
			oSaldoCred:SetTotCred(aTotCred[nCont,2])
			oSaldoCred:SetCredUti( aTotCred[nCont,2] - aTotCred[nCont,3] )	
			oSaldoCred:SetCrdDisp(aTotCred[nCont,3])
			oSaldoCred:SetReserv("")
			//Aqui precisa passar zero para as informações de ressarcimento e compensação do período e de período anterior
			//para que esta informação não seja gravada indevidamente nos saldos gerados no período atual.
			oSaldoCred:SetRessar(0)			
			oSaldoCred:SetCoAnte(0)	
			oSaldoCred:SetReante(0)
			oSaldoCred:SetComp(0) 
			oSaldoCred:SetMesAtu(.T.)	
			//Grava valor de crédito de PIS e COFINS para próximo período
			oSaldoCred:AcumSaldo()
		EndIf
	Next nCont
EndIF

//-------------------------------------------------------------------------------------------
//ATUALIZA A TABELA DA APURAÇÃO COM OS VALORES DE CRÉDITOS UTILIZADOS DE PERÍODO ANTERIOR    
//E DO PRÓPRIO P
//-------------------------------------------------------------------------------------------
If CKR->(MSSEEK(Self:BuscaxFil('CKR')+dTos(Self:dDtIni)+Self:cConsl+cTributo))
	RecLock('CKR',.F.)
		
	CKR_CRDANT	:= nCrdAnt		
	CKR_CRDATU	:= nCrdAtu
	CKR_CONNC	:= nVlDeb
				
	CKR_NCREC := CKR_CONNC  - CKR_CRDANT - CKR_CRDATU - CKR_RTANTN - CKR_RTATUN - CKR_OUTDNC
	
	//Cumulativo	
	CKR_CONC	:= nVlDebNC
	CKR_CREC	:= CKR_CONC - CKR_RTANTC - CKR_RTATUC - CKR_OUTDC
	MsUnLock()
EndIF

DbSelectArea (cAliasCKZ)
(cAliasCKZ)->(DbCloseArea())

Return


//----------------------------------------------------

//DECLARAÇÃO DA CLASSE APURPISCOF 

//----------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} APURPISCOF
CLASSE QUE FARÁ O PROCESSAMENTO DA APURAÇÃO, COM BASE NAS INFORMAÇÕES
JÁ GRAVADAS ANTERIORMENTE PELOAS CLASSES FISX001, SAIDASCST, COMPDEBITO
E CMPCREDITO.

@author Erick G. Dias
@since 29/0 4/2014
@version 11.80
/*/
//-------------------------------------------------------------------

CLASS APURPISCOF FROM EFDGEN

	Data nVlContN 	 As integer //Valor da Contribuição de PIS
	Data nCrdAntN 	 As integer //Valor do Crédito de período anterior de PIS utilizado
	Data nCrdAtuN 	 As integer //Valor do crédito de período atual de PIS utilizado
	Data nConDevN 	 As integer //Valor da contribuição devida de PIS
	Data nRetAntN 	 As integer //Valor da retenção de período anterior de PIS utilizado
	Data nRetAtuN 	 As integer //Valor da retenção de período atual de PIS utilizado
	Data nOutDedN 	 As integer //Valor de Outras Deduções de PIS utilizado
	Data nVlRecN 	 As integer //Valor a recolher de PIS
	Data nCrdFutN 	 As integer //Valor do saldo de crédito de PIS para próximo período
	Data nRetFutN 	 As integer //Valor do saldo de retenção de PIS para próximo período
	Data nVlContC 	 As integer //Valor da Contribuição de PIS
	Data nRetAntC 	 As integer //Valor da retenção de período anterior de PIS utilizado
	Data nRetAtuC 	 As integer //Valor da retenção de período atual de PIS utilizado
	Data nOutDedC 	 As integer //Valor de Outras Deduções de PIS utilizado
	Data nVlRecC 	 As integer //Valor a recolher de PIS
	Data nRetFutC 	 As integer //Valor do saldo de retenção de PIS para próximo período
	Data cTributo	 As string //tributo processado
	Data aRecolh	 As array
	Data cGrvDup	 As string	//indica se irá gragar a tabela CL3 com as informações das duplicatas
	Data nTotFolha	 As integer
	Data nExclFolha 	As integer
	Data nBaseFolha 	As integer
	Data nPisFolha	 	As integer
	Data nRegime	 	As Integer	
	Data cSeqTrib	 	As string
	Data lPrcCrdFut	As Boolean //Indica se deverá ser processado valores de créditos para próximo período
	
	METHOD SetREgime(Value)
	METHOD SetValApur(Value)
	METHOD SetGrvDup(Value)
	METHOD setPCrdFut(value)
	METHOD Apurar(cTributo)
	Method LoadApurPC(cTributo)
	MEthod RegraCdRec()

	Method GetVlContr(cRegime)
	Method GetCrdAnt(cRegime)
	Method GetCrdAtu(cRegime)
	Method GetConDev(cRegime)
	Method GetRetAnt(cRegime)
	Method GetRetAtu(cRegime)
	Method GetOutDed(cRegime)
	Method GetVlRecol(cRegime)
	Method GetSldCrd(cRegime)
	Method GetSldRet(cRegime)
	Method GetTrib(cTrib)
	Method GetCodRec(cTrib)
	Method GetValor(cTrib)
	Method GetDtVenc(cTrib)
	Method GetTotFolh()
	Method GetExlFolh()
	Method GetBCFolha()
	Method GetPisFolh()
	Method RecolhTrib(cTrib,cColuna)
	Method GrvRecolhi(cTributo,nValor,cCodRec)
	METHOD LoadRecolh()
	METHOD LoadPisFol()
	Method RatBrut()
	Method setSeqTrib()
	Method getSeqTrib()

	METHOD New()

ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método Contrutor da Classe APURPISCOF. Esta classe será responsável
por realizar os cálculos da aba de apuração e aba das informações
de recolhimento do tributo.

@author Erick G. Dias
@since 30/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------

METHOD New() Class APURPISCOF

	Self:nVlContN		:=0
	Self:nCrdAntN		:=0
	Self:nCrdAtuN		:=0
	Self:nConDevN		:=0
	Self:nRetAntN		:=0
	Self:nRetAtuN		:=0
	Self:nOutDedN		:=0
	Self:nVlRecN		:=0
	Self:nCrdFutN		:=0
	Self:nRetFutN		:=0
	Self:nVlContC		:=0
	Self:nRetAntC		:=0
	Self:nRetAtuC		:=0
	Self:nOutDedC		:=0
	Self:nVlRecC		:=0
	Self:nRetFutC		:=0
	Self:cTributo		:= ''
	Self:aRecolh		:= {}
	Self:nRegime		:= 0
	Self:cGrvDup		:= '2'
	Self:cSeqTrib		:= '4'
	Self:nTotFolha	:=0
	Self:nExclFolha 	:=0
	Self:nBaseFolha 	:=0
	Self:nPisFolha	:=0
	Self:cConsl		:= '2'	
	Self:lPrcCrdFut	:= .F.
	Self:IniHash()

Return Self


METHOD SetRegime(Value) Class APURPISCOF
	Self:nRegime = Value
Return

METHOD SetGrvDup(Value) Class APURPISCOF
	Self:cGrvDup:= Value
Return

Method setPCrdFut(Value) Class APURPISCOF
	Self:lPrcCrdFut	:= Value
Return

Method setSeqTrib(Value) Class APURPISCOF
	Self:cSeqTrib	:= Value
Return

Method getSeqTrib() Class APURPISCOF		
Return Self:cSeqTrib
//-------------------------------------------------------------------
/*/{Protheus.doc} GetVlContr()
Método que retornará o valor total da contribuição

@author Erick G. Dias
@since 30/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method GetVlContr(cRegime) Class APURPISCOF
Return Iif(cRegime=='1',Self:nVlContN,Self:nVlContC)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCrdAnt()
Método que irá retornar o valor do crédito de período anterior utilizado

@author Erick G. Dias
@since 30/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method GetCrdAnt() Class APURPISCOF
Return Self:nCrdAntN

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCrdAtu()
Método que irá retornar o valor do crédito do próprio período

@author Erick G. Dias
@since 30/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method GetCrdAtu() Class APURPISCOF
Return Self:nCrdAtuN

//-------------------------------------------------------------------
/*/{Protheus.doc} GetConDev()
Método que irá retornar o valor da contribução devida, que é valor total
da contribuição - crédito período anterior - crédito período atual

@author Erick G. Dias
@since 30/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method GetConDev()Class APURPISCOF
Return Self:nConDevN

//-------------------------------------------------------------------
/*/{Protheus.doc} GetRetAnt()
Método para retornar valor da retenção da fonte utilizado de período anterior
utilizado na ãpuração.

@author Erick G. Dias
@since 30/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method GetRetAnt(cRegime) Class APURPISCOF
Return Iif(cRegime=='1',Self:nRetAntN,Self:nRetAntC)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetRetAtu()
Método para retornar valor da retenção da fonte utilizado do próprio período
utilizado na ãpuração.

@author Erick G. Dias
@since 30/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method GetRetAtu(cRegime) Class APURPISCOF
Return Iif(cRegime=='1',Self:nRetAtuN,Self:nRetAtuC)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetOutDed()
Método que retorna o valor de outras deduções utilizadas na apuração 

@author Erick G. Dias
@since 30/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method GetOutDed(cRegime) Class APURPISCOF
Return Iif(cRegime=='1',Self:nOutDedN,Self:nOutDedC)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetVlRecol()
Método que retorna o valor do tributo a recolher no período 

@author Erick G. Dias
@since 30/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method GetVlRecol(cRegime) Class APURPISCOF
Return Iif(cRegime=='1',Self:nVlRecN,Self:nVlRecC)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetSldCrd()
Método que retorna o valor do saldo de crédito a transportar para período futuro 

@author Erick G. Dias
@since 30/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method GetSldCrd() Class APURPISCOF
Return Self:nCrdFutN

//-------------------------------------------------------------------
/*/{Protheus.doc} GetSldRet()
Método que retorna o valor do saldo de ~retenção a transportar para período futuro 

@author Erick G. Dias
@since 30/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method GetSldRet(cRegime) Class APURPISCOF
Return Iif(cRegime=='1',Self:nRetFutN,Self:nRetFutC)

Method GetTotFolh()	 Class APURPISCOF
Return		Self:nTotFolha

Method GetExlFolh()	 Class APURPISCOF
Return		Self:nExclFolha

Method GetBCFolha()	 Class APURPISCOF
Return		Self:nBaseFolha

Method GetPisFolh()	 Class APURPISCOF
Return		Self:nPisFolha

Method SetValApur(nValue,cRegime) Class APURPISCOF
	
	If cRegime == '1'
		Self:nVlRecN -= nValue
	ElseIF cRegime == '2'
		Self:nVlRecC -= nValue	
	EndIF

Return 

METHOD LoadPisFol() Class APURPISCOF

Local cAliasCKZ	:= x001QRYCKS('5',Self:dDtIni,,Self:BuscaxFil('CKZ'),Self:cConsl)

DbSelectArea (cAliasCKZ)
(cAliasCKZ)->(DbGoTop ())

Do While !(cAliasCKZ)->(Eof ())
	Self:nTotFolha	+=	(cAliasCKZ)->CKS_VLREC
	Self:nExclFolha	+=	(cAliasCKZ)->CKS_AJRD
	Self:nBaseFolha	+=	(cAliasCKZ)->CKS_BASE
	Self:nPisFolha	+=	(cAliasCKZ)->CKS_VLDISP
	
	(cAliasCKZ)->(DbSkip ())
EndDo

DbSelectArea (cAliasCKZ)
(cAliasCKZ)->(DbCloseArea())


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Apurar()
Método que irá realizar o cálculo da apuração, buscar o valor da 
contribuição apurada, valor do crédito apurado, retenções, ajustes,
diferimentos, realizar apuração e fazer o controle dos slados de créditos
e de retenções. 

@param		cTributo - Tributo a ser processado.
@author Erick G. Dias
@since 30/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
METHOD Apurar(cTributo) Class APURPISCOF

Local nVlCont		:= 0
Local nCrdAnt		:= 0
Local nCrdAtu		:= 0
Local nRetAnt		:= 0
Local nRetAtu		:= 0
Local nOutDed		:= 0
Local nVlRec		:= 0
Local nVlContC	:= 0
Local nRetAntC	:= 0
Local nRetAtuC	:= 0
Local nOutDedC	:= 0
Local nVlRecC		:= 0
Local cNaoCumu	:= '1'
Local cCumu		:= '2'
Local oCredito
Local oDebito

//------------------------------------------------------
//CARREGA O VALOR DA CONTRIBUIÇÃO NÃO CUMULATIVA APURADA
//------------------------------------------------------
oDebito:= COMPDEBITO():New() 	//Cria Objeto da Classe COMPDEBITO
oDebito:SetConsol(Self:cConsl)
oDebito:SetFilial(Self:aFilial)
oDebito:SetDtIni(Self:dDtIni)   	//Passa data de referência
oDebito:SetDtFim(Self:dDtFim)
oDebito:LoadDebito(cNaoCumu)	//Buscar débitos Não Cumulativos
nVlCont:= oDebito:GetValDisp(cTributo)

//------------------------------------------------------
//CARREGA O VALOR DA CONTRIBUIÇÃO CUMULATIVA APURADA
//------------------------------------------------------
oDebito:= COMPDEBITO():New() 	//Cria Objeto da Classe COMPDEBITO
oDebito:SetConsol(Self:cConsl)
oDebito:SetFilial(Self:aFilial)
oDebito:SetDtIni(Self:dDtIni)   //Passa data de referência
oDebito:SetDtFim(Self:dDtFim)
oDebito:LoadDebito(cCumu)	//Buscar débitos Não Cumulativos
nVlContC:= oDebito:GetValDisp(cTributo)

//---------------------------------------
//CARREGA O VALOR DE CRÉDTO JÁ PROCESSADO
//---------------------------------------

oDebito:= NIL
oCredito:= NIL

//---------------------------------------------------------------------------------------------------------
//Valor da Contribuição devida é valor da contribuição menos crédito de perído anterior menos crédito atual
//---------------------------------------------------------------------------------------------------------

//Aqui deverá fazer o controle dos créditos para próximo período
nConDev	:= nVlCont	-nCrdAnt -  nCrdAtu
nConDevC	:= nVlContC

//-----------------------------------------------------------------------------------------------------------------------------
//Valor a recolher será o valor da contrivbuição devida menos retenções de período anterios e do período menos outras deduções.
//-----------------------------------------------------------------------------------------------------------------------------
nVlRec		:= nConDev  -  nRetAnt   -  nRetAtu   - nOutDed
nVlRecC	:= nConDevC -  nRetAntC  -  nRetAtuC  - nOutDedC

dbSelectArea('CKR')
CKR->(dbSetOrder(1))
If !CKR->(MSSEEK(Self:BuscaxFil('CKR')+dTos(Self:dDtIni)+Self:cConsl+cTributo))
	RecLock('CKR',.T.)
	CKR->CKR_FILIAL	:=	Self:BuscaxFil('CKR')
	CKR->CKR_PER		:=	Self:dDtIni
	CKR->CKR_TRIB		:=	cTributo
	CKR->CKR_CONNC	:=	nVlCont
	CKR->CKR_CRDANT	:=	nCrdAnt
	CKR->CKR_CRDATU	:=	nCrdAtu
	CKR->CKR_RTANTN	:=	nRetAnt
	CKR->CKR_RTATUN	:=	nRetAtu
	CKR->CKR_OUTDNC	:=	nOutDed
	CKR->CKR_NCREC	:=	nVlRec
	CKR->CKR_CONC		:=	nVlContC
	CKR->CKR_RTANTC	:=	nRetAntC
	CKR->CKR_RTATUC	:=	nRetAtuC
	CKR->CKR_OUTDC	:=	nOutDedC
	CKR->CKR_CREC		:=	nVlRecC
	CKR->CKR_STATUS	:=	'1' //Pendente geração dasa duplicatas
	CKR->CKR_REGIME	:= Self:nRegime	
	CKR->CKR_CONSOL	:= Self:cConsl
	
	If (CKR->(FieldPos('CKR_DTINI')) > 0 .And. CKR->(FieldPos('CKR_DTFIM')) > 0)
		CKR->CKR_DTINI	:= firstday(Self:dDtIni)
		CKR->CKR_DTFIM	:= lastday(Self:dDtIni)
	EndIf

	If CKR->(Fieldpos("CKR_LIVRO")) > 0
		CKR->CKR_LIVRO := CLIVROAPU
	Endif
			
	MsUnLock()
Else

	RecLock('CKR',.F.)
	CKR->CKR_CONNC	+=	nVlCont
	CKR->CKR_CRDANT	+=	nCrdAnt
	CKR->CKR_CRDATU	+=	nCrdAtu
	CKR->CKR_RTANTN	+=	nRetAnt
	CKR->CKR_RTATUN	+=	nRetAtu
	CKR->CKR_OUTDNC	+=	nOutDed
	CKR->CKR_NCREC	+=	nVlRec
	CKR->CKR_CONC		+=	nVlContC
	CKR->CKR_RTANTC	+=	nRetAntC
	CKR->CKR_RTATUC	+=	nRetAtuC
	CKR->CKR_OUTDC	+=	nOutDedC
	CKR->CKR_CREC		+=	nVlRecC
	
	MsUnLock()
EndIF

Return

Method PercDif(cTrib) Class CMPCREDITO

Local nTribDif		:= 0
Local nValTrib		:= 0
Local nPerc			:= 0
Local cAliasCFA		:= 'CFA'
Local cSlctCFA		:= ''
Local cFiltro		:= ''
Local cPer			:= 	Substr(DTOS(Self:dDtIni),5,2)+Substr(DTOS(Self:dDtIni),1,4)
Local cTributo		:= ''
Local aCredDif		:= {}
Local aTribDif		:= {}
Local aCnpj			:= {}
Local nPos			:= 0
Local cCodCrdDif	:= '01/02/03/06'
Local nContDeb			:= 0
Local nContCred			:= 0
Local aCFA			:= {}
Local nCrdDIf		:= 0
Local nTotPer		:= 0
Local nPercREst		:= 100
Local nCont			:= 0
Local nDifPArc		:= 0 
Local nTotDif		:= 0
Local nDiferenca	:= 0
Local nTotCrdDif	:= 0
Local cFilCL8		:= Self:BuscaxFil('CL8')

If cTrib == '1'
	cTributo		:= 'PIS'
ElseIf cTrib == '2'	
	cTributo		:= 'COF'
EndIf

cSlctCFA:= '%CFA.*%'
cFiltro := "%"
cFiltro += "CFA.CFA_FILIAL= '"+ Self:BuscaxFil('CFA')+ "' AND "
cFiltro += "CFA.CFA_PERAPU = '" + %Exp:cPer% + "' AND CFA.CFA_TPCON ='" + %Exp:cTributo% + "' AND "
cFiltro += "CFA.CFA_CODCON IN ('01','02','03','04','71') AND "
cFiltro += "CFA.CFA_CONSOL = '" +Self:cConsl + "' AND "
cFiltro += "%"

cAliasCFA	:=	GetNextAlias()
BeginSql Alias cAliasCFA
	
	SELECT
	%Exp:cSlctCFA%

	FROM
	%Table:CFA% CFA
	WHERE
	%Exp:cFiltro%
	CFA.%NotDel%
	
	
EndSql

DbSelectArea (cAliasCFA)
(cAliasCFA)->(DbGoTop ())
Do While !(cAliasCFA)->(Eof ())
	
	nPos:=aScan(aTribDif,{|aX| aX[1]==(cAliasCFA)->CFA_CNPJ .AND. aX[2]==(cAliasCFA)->CFA_CODCON  })

	IF nPos == 0
		aAdd(aTribDif, {})
		nPos := Len(aTribDif)
		aAdd (aTribDif[nPos], (cAliasCFA)->CFA_CNPJ)
		aAdd (aTribDif[nPos], (cAliasCFA)->CFA_CODCON )
		aAdd (aTribDif[nPos], (cAliasCFA)->CFA_CONDIF )	
		aAdd (aTribDif[nPos], 0)
						
	Else
		aTribDif[nPos][3] += (cAliasCFA)->CFA_CONDIF
	
	EndIF

	nTribDif	+= (cAliasCFA)->CFA_CONDIF
		
	(cAliasCFA)->(DbSkip ())
EndDo

cSlctCKZ:= '%SUM(CKS.CKS_VLTRIB) as CKS_VLTRIB %'
cFiltro := "%"
cFiltro += "CKZ.CKZ_FILIAL= '"+ Self:BuscaxFil('CKZ')+ "' AND "
cFiltro += "CKZ.CKZ_PER= '" + %Exp:DToS (Self:dDtIni)% + "' AND "
cFiltro += "CKZ.CKZ_CONSOL = '" +Self:cConsl + "' AND "	
cFiltro += "CKZ.CKZ_TRIB = '" +cTrib + "' AND "
cFiltro += "CKZ.CKZ_REGIME = '1' AND "
cFiltro += "%"

cAliasCKZ	:=	GetNextAlias()
BeginSql Alias cAliasCKZ
    	
	SELECT
	%Exp:cSlctCKZ%

	FROM
	%Table:CKZ% CKZ
	INNER JOIN %Table:CKS% CKS ON(CKS.CKS_FILIAL=%Exp:Self:BuscaxFil('CKZ')%  AND CKS.CKS_PER=CKZ.CKZ_PER AND CKS.CKS_CHV=CKZ.CKZ_ID AND CKS.CKS_CONSOL=CKZ.CKZ_CONSOL   AND CKS.%NotDel%)
	WHERE
	%Exp:cFiltro%
	CKZ.%NotDel%
        
EndSql

DbSelectArea (cAliasCKZ)
(cAliasCKZ)->(DbGoTop ())
Do While !(cAliasCKZ)->(Eof ())
	
	nValTrib	:= (cAliasCKZ)->CKS_VLTRIB 
		
	(cAliasCKZ)->(DbSkip ())
EndDo
DbSelectArea (cAliasCKZ)
(cAliasCKZ)->(DbCloseArea())

nPerc	:= nTribDif  / nValTrib

If nTribDif > 0 .AND. CL8->(MSSEEK(Self:BuscaxFil('CL8')+dTos(Self:dDtIni)))
	
	Do While !CL8->(Eof ()) .AND. CL8->CL8_FILIAL == cFilCL8 .AND. CL8->CL8_PER == Self:dDtIni .AND. nTotDif <>	nTribDif
		nPerCL8	:= 0
		If CL8->CL8_TRIB ==cTrib .AND.  CL8->CL8_CONSOL == Self:cConsl .AND. (CL8->CL8_VLCRED + CL8->CL8_AJAC - CL8->CL8_AJRD) > 0 .AND. substr(CL8->CL8_CHV,12,2) $ cCodCrdDif 
			RecLock('CL8',.F.)				 
			
			nDifPArc	:= round((CL8->CL8_VLCRED + CL8->CL8_AJAC - CL8->CL8_AJRD) * nPerc, 2)
			
			nTotDif += nDifPArc									
			
			If nTotDif  <= nTribDif //Se total dos créditos diferidos for menor que o total dos débitos diferidos irá continuar
				CL8->CL8_DIF 	:= nDifPArc				
				CL8->CL8_TOTCRD	:=	CL8_VLCRED+CL8->CL8_AJAC- CL8->CL8_AJRD - CL8->CL8_DIF				
			Else
				
				//Aqui significa que o valor de crédito diferido será maior que o débito diferido, irá diferir somente a diferença e sair do laço da CL8
				CL8->CL8_DIF 	:= nTotDif - (nTotDif - nTribDif ) 				
				CL8->CL8_TOTCRD	:=	CL8_VLCRED+CL8->CL8_AJAC- CL8->CL8_AJRD - CL8->CL8_DIF
				nTotDif	:=	nTribDif							
			EndIF

			nPos:=aScan(aCredDif,{|aX| aX[1]==substr(CL8->CL8_CHV,11,3)})

			IF nPos == 0
				aAdd(aCredDif, {})
				nPos := Len(aCredDif)
				aAdd (aCredDif[nPos], substr(CL8->CL8_CHV,11,3))
				aAdd (aCredDif[nPos], CL8->CL8_DIF )
								
			Else
				aCredDif[nPos][2] += CL8->CL8_DIF
			
			EndIF
			
			msunlock()
		EndIF
			
		CL8->(DbSkip ())
	EndDo

EndIF

For nContDeb	:= 1 to len(aTribDif)	

	//Percentual da receita diferida deste CNPJ
	aTribDif[nContDeb][4]	:= aTribDif[nContDeb][3] * 100 / nTribDif
		
Next nCont


For nContCred	:= 1 to Len(aCredDif)
	
	nTotCrdDif	:= aCredDif[nContCred][2]

	//Chama função para fazer rateio dos créditos diferidos em todos os CNPJs de órgão público.
	RatCredDif(aTribDif, @aCFA, @aCnpj, aCredDif[nContCred][2], aCredDif[nContCred][1], @nTotCrdDif, "1")

	//Após processar todos os CNPJs para o código do crédito, verifio se restou algum valor de crédito remanescente.
	IF nTotCrdDif > 0
		RatCredDif(aTribDif, @aCFA, @aCnpj, nTotCrdDif, aCredDif[nContCred][1], @nTotCrdDif,"2")
	EndIF

Next nContCred

For nCont	:= 1 to len(aCFA)

	nPos:=aScan(aCnpj,{|aX| aX[1]==aCFA[nCont][1] })		
	
	IF nPos > 0
		aCFA[nCont][5]	:=   Round(aCFA[nCont][4] * 100 / aCnpj[nPos][2],2) 				
	EndIF

Next nCont

//deletar todas as linhas da CFA, pois elas serão todas recriadas.
DbSelectArea (cAliasCFA)
(cAliasCFA)->(DbGoTop ())
IF Len(aCFA) > 0
	Do While !(cAliasCFA)->(Eof ())                                              
		
		//Melhoria, retirei o seek e utilizei o DGGOTOP(), é necessário refazer a CFA para ter os percentuais do valores dos créditos diferidos. 
		CFA->(dbGoto( ( cAliasCFA )->R_E_C_N_O_ ))
		RecLock('CFA',.F.)
		dbDelete()		
		MsUnlock()
		FkCommit()

		For nCont	:= 1 to Len(aCFA)
			
			
			IF aCFA[nCont][1] ==  (cAliasCFA)->CFA_CNPJ .AND. aCFA[nCont][2] == (cAliasCFA)->CFA_CODCON 		
				//deve adicionar linha na CFA
		
 				RecLock("CFA",.T.)
				CFA->CFA_FILIAL	:=	(cAliasCFA)->CFA_FILIAL
				CFA->CFA_CODCON	:=	(cAliasCFA)->CFA_CODCON
				CFA->CFA_TPCON	:=	(cAliasCFA)->CFA_TPCON
				CFA->CFA_CNPJ	:=	(cAliasCFA)->CFA_CNPJ
				CFA->CFA_PERAPU	:=	(cAliasCFA)->CFA_PERAPU
				CFA->CFA_CONSOL	:=	'2' //Gravo indicando que não é consolidado, pois veio da movimentação
				CFA->CFA_ALIQ	:=	(cAliasCFA)->CFA_ALIQ
				
				// se percentual for igual a 100%, então não farei conta, adotarei o próprio valor do crédito diferido como valor do débito diferido, para evitar problemas de arredondamento
				IF aCFA[nCont][5] == 100 
					CFA->CFA_CONDIF	:=	(cAliasCFA)->CFA_CONDIF
					CFA->CFA_CREDIF	:=	aCFA[nCont][4]	
				Else
					CFA->CFA_CONDIF	:=	Round((cAliasCFA)->CFA_CONDIF	* aCFA[nCont][5] / 100,2)
					CFA->CFA_CREDIF	:=	aCFA[nCont][4]							
				EndIF
					
				CFA->CFA_CODCRE	:=	aCFA[nCont][3]
				CFA->CFA_TOTVEN	:=	Round((cAliasCFA)->CFA_TOTVEN * aCFA[nCont][5] / 100,2)
				CFA->CFA_TOTDIF	:=	Round((cAliasCFA)->CFA_TOTDIF * aCFA[nCont][5] / 100,2)
				CFA->CFA_CONREC	:=	Round((cAliasCFA)->CFA_CONREC * aCFA[nCont][5] / 100,2)
				CFA->CFA_VLRREC	:=	Round((cAliasCFA)->CFA_VLRREC * aCFA[nCont][5] / 100,2)
				CFA->CFA_VLNREC	:=	Round((cAliasCFA)->CFA_VLNREC * aCFA[nCont][5] / 100,2)
							
				MsUnLock()
				  
			EndiF
		NExt nCont		
		
		(cAliasCFA)->(DbSkip ())
	EndDo
EndIF

DbSelectArea (cAliasCFA)
(cAliasCFA)->(DbCloseArea())

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} RatBrut()
Método que irá refazer o cálculo do rateio proporcional considerando receita bruta.
Este método será chamado somente no processamento Multithread, pois neste cenário
somente teremos a receita quando todas as threads finalizarem, e cada uma fez
o cálculo considerando o dia de cada thread, por este motivo é necessário refazer
o rateio após todas concluirem.

@author Erick G. Dias
@since 30/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method RatBrut(aXFilial) Class APURPISCOF

Local nPercCum	:= 0
Local oRecBrut	
Local aRecBrut	:= {}
Local aPercAux	:= {}
Local nPos			:= 0

CKZ->(dbSetOrder(1))

oRecBrut := FISX001():New()
oRecBrut:SetFilial(aXFilial)
oRecBrut:SetDtIni(Self:dDtIni)
oRecBrut:SetDtFin(LastDay(Self:dDtIni))
aRecBrut	:= oRecBrut:LoadRecBru()

IF Len(aRecBrut) > 0
	nPercCum	:= (aRecBrut[1][4] /aRecBrut[1][5]) * 100
	
	If CL9->(MSSEEK(Self:BuscaxFil('CL9')+dTos(Self:dDtIni)))
	
		Do While !CL9->(Eof ()) .AND. CL9->CL9_PER == Self:dDtIni
			If CL9->CL9_CONSOL == Self:cConsl .AND. CL9->CL9_PAUTA == '2'
				RecLock('CL9',.F.)
				
				Cl9->CL9_BSCUM:= Round(Cl9->Cl9_TOTBSE * nPercCum /100,2)
				Cl9->Cl9_BSNCUM:= Cl9->Cl9_TOTBSE -  Cl9->CL9_BSCUM
				//Somente pode atualizar o campo Cl9_BSTCRD se ele estiver com valor, pois dependendo do CST utilizado, 54,56, e dependento
				//das receitas do período, algumas linhas terão Cl9_BSTCRD com valor zerado mesmo, conforme regra do Guia Prático, então
				//ao efetuar o rateio não deverá atualizar este campo, ele deverá sofrer o rateio somente se houver valor.				
				If Cl9->Cl9_BSTCRD > 0
					Cl9->Cl9_BSTCRD:= Cl9->Cl9_BSNCUM
				EndIF 
				
				MsUnLock()
	
				nPos:=aScan(aPercAux,{|aX| aX[2]==Cl9->Cl9_CHV .AND. aX[3]==Cl9->Cl9_CST .AND. aX[4] == Cl9->Cl9_CODBCC})

				IF nPos == 0
					aAdd(aPercAux, {})
					nPos := Len(aPercAux)
					aAdd (aPercAux[nPos], Cl9->Cl9_BSNCUM )
					aAdd (aPercAux[nPos], Cl9->Cl9_CHV)
					aAdd (aPercAux[nPos], Cl9->Cl9_CST)
					aAdd (aPercAux[nPos], Cl9->Cl9_CODBCC)				
				Else
					aPercAux[nPos][1] += Cl9->Cl9_BSNCUM
				
				EndIF				
				
			EndIF
				
			CL9->(DbSkip ())
		EndDo
	
	EndIF
	
	If CL8->(MSSEEK(Self:BuscaxFil('CL8')+dTos(Self:dDtIni)))
	
		Do While !CL8->(Eof ())  .AND. CL8->CL8_PER == Self:dDtIni
			nPerCL8	:= 0
			If CL8->CL8_CONSOL == Self:cConsl 
				nPos:=aScan(aPercAux,{|aX| aX[2]==Cl8->Cl8_CHV.AND. aX[3]==Cl8->Cl8_CST .AND. aX[4] == Cl8->Cl8_CODBCC})
				If nPos > 0		
					//Somente pode atualizar o campo CL8_VLCRED se ele estiver com valor, pois dependendo do CST utilizado, 54,56, e dependento
					//das receitas do período, algumas linhas terão CL8_VLCRED com valor zerado mesmo, conforme regra do Guia Prático, então
					//ao efetuar o rateio não deverá atualizar este campo, ele deverá sofrer o rateio somente se houver valor.
					If CKZ->(MSSEEK(Self:BuscaxFil('CKZ')+dTos(Self:dDtIni)+'1'+CL8->CL8_CHV+CL8->CL8_CONSOL)) .AND. Substr(CKZ->CKZ_COD,2,2) <>'03' .AND. CL8->CL8_BSCALC > 0
						RecLock('CL8',.F.)
						CL8->CL8_BSCALC:= aPercAux[nPos][1]
						//Busca alíquota para refazer o cálculo do crédito considerando nova base de cálculo						
						CL8->CL8_VLCRED:= Round(CL8->CL8_BSCALC * CKZ->CKZ_ALIQ / 100,2)
						CL8->CL8_TOTCRD:= CL8->CL8_VLCRED
						MsUnLock()
					EndiF					
					
				EndIF
			EndIF
				
			CL8->(DbSkip ())
		EndDo
	
	EndIF
	
EndIF


Return


//-------------------------------------------------------------------
/*/{Protheus.doc} LoadApurPC()
Método que irá buscar valores gravados na tabela de apuração e carregar
para filial e período processado.

@param		cTributo - Tributo a ser processado.
@author Erick G. Dias
@since 30/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
METHOD LoadApurPC(cTributo) Class APURPISCOF

Local aSaldo		:= {}
Local aValF3J		:= {}
Local aCodRec		:=RetCodRec()
Local nCont			:= 0
Local nReduzCL3		:= 0
Local nVlRec		:= 0
Local cAliasCKR		:= 'CKR'
Local cSlctCKR		:= ''
Local cFiltro		:= ''
Local lF3J			:= AliasINdic('F3J')
local oSaldoCred

cSlctCKR:= '%CKR.CKR_CONNC,		CKR.CKR_CRDANT,	CKR.CKR_CRDATU,	CKR.CKR_RTANTN,	CKR.CKR_RTATUN,'
cSlctCKR+= 'CKR.CKR_OUTDNC ,		CKR.CKR_NCREC,	CKR.CKR_CONC	,	CKR.CKR_RTANTC,	CKR.CKR_RTATUC,'
cSlctCKR+= 'CKR.CKR_OUTDC ,		CKR.CKR_CREC%'

cFiltro := "%"
cFiltro += "CKR.CKR_FILIAL= '"+ Self:BuscaxFil('CKR')+ "' AND "
cFiltro += "CKR.CKR_PER>= '" + %Exp:DToS (Self:dDtIni)% + "' AND "
cFiltro += "CKR.CKR_PER<= '" + %Exp:DToS (Self:dDtIni)% + "' AND "
cFiltro += "CKR.CKR_CONSOL = '" + Self:cConsl + "' AND "
cFiltro += "CKR.CKR_TRIB = '" + cTributo + "' AND "
cFiltro += "%"

cAliasCKR	:=	GetNextAlias()
BeginSql Alias cAliasCKR
    	
	SELECT
	%Exp:cSlctCKR%

	FROM
	%Table:CKR% CKR
	WHERE
	%Exp:cFiltro%
	CKR.%NotDel%
EndSql

DbSelectArea (cAliasCKR)
(cAliasCKR)->(DbGoTop ())
Do While !(cAliasCKR)->(Eof ())

//VALORES NÃO CUMULATIVOS
	Self:nVlContN		:=(cAliasCKR)->CKR_CONNC
	Self:nCrdAntN		:=(cAliasCKR)->CKR_CRDANT
	Self:nCrdAtuN		:=(cAliasCKR)->CKR_CRDATU
	Self:nConDevN		:=(cAliasCKR)->CKR_CONNC - (cAliasCKR)->CKR_CRDANT -  (cAliasCKR)->CKR_CRDATU
	Self:nRetAntN		:=(cAliasCKR)->CKR_RTANTN
	Self:nRetAtuN		:=(cAliasCKR)->CKR_RTATUN
	Self:nOutDedN		:=(cAliasCKR)->CKR_OUTDNC
	Self:nVlRecN		:=(cAliasCKR)->CKR_NCREC
//VALORES CUMULATIVOS      
	Self:nVlContC		:=(cAliasCKR)->CKR_CONC
	Self:nRetAntC		:=(cAliasCKR)->CKR_RTANTC
	Self:nRetAtuC		:=(cAliasCKR)->CKR_RTATUC
	Self:nOutDedC		:=(cAliasCKR)->CKR_OUTDC
	Self:nVlRecC		:=(cAliasCKR)->CKR_CREC

	(cAliasCKR)->(DbSkip ())
EndDo

DbSelectArea (cAliasCKR)
(cAliasCKR)->(DbCloseArea())

IF Self:lPrcCrdFut
	//--------------------------------------------------------------------
	//Busca o valor de crédito que foi transportado para período futuro.
	//--------------------------------------------------------------------	
	oSaldoCred:= SALDOCRED():New()
	oSaldoCred:SetConsol(Self:cConsl)
	oSaldoCred:SetFilial(Self:aFilial)
	oSaldoCred:SetTributo(cTributo)
	oSaldoCred:SetPer(Strzero(Month(Self:dDtIni),2)+cvaltochar(Year(Self:dDtIni)))
	oSaldoCred:LoadSaldo()
	aSaldo	:=	oSaldoCred:GetSaldoAt()
	
	For nCont:= 1 to Len(aSaldo)
		Self:nCrdFutN += aSaldo[nCont][16]
	Next nCont
	FreeObj(oSaldoCred)
	oSaldoCred:= nil
EndIF

//--------------------------------------------------------------------
//BUSCA O VALOR DE RETENÇÃO QUE FOI TRANSPORTADO PARA PERÍODO FUTURO.
//--------------------------------------------------------------------	
oOutRet := DEDUCAOPC():New() 
oOutRet:SetConsol(Self:cConsl)
oOutRet:SetFilial(Self:aFilial)
oOutRet:SetPergrva(Strzero(Month(Self:dDtIni),2)+cvaltochar(Year(Self:dDtIni)))
oOutRet:SetTributo(cTributo)
oOutRet:LoadSaldo()
aSaldo	:= oOutRet:GetSldRet()


//Quando SFV|SFW estiver bloqueado(Nao sendo consumida), Valor do saldo de retenção de PIS para próximo período deve desconsiderar 
//os valores ja ressarcidos, ou seja, devo subtrair no calculo tambem o valor que ja foi consumido(ressarcimento|compensacao) do disponivel.
For nCont:= 1 to Len(aSaldo)	
	IF aSaldo[nCont][4] == '1'
		Self:nRetFutN += aSaldo[nCont][6] - IIF(aSaldo[nCont][10] != "2", (aSaldo[nCont][8] + aSaldo[nCont][9]), 0) 
	ElseIF aSaldo[nCont][4] == '2'
		Self:nRetFutC	+= aSaldo[nCont][6] - IIF(aSaldo[nCont][10] != "2", (aSaldo[nCont][8] + aSaldo[nCont][9]), 0) 
	Endif 	
Next nCont
FreeObj(oOutRet)
oOutRet:= nil


//IRÁ BUSCAR INFORMAÇÕES DO PAGAMENTO
IF Self:cGrvDup == '1'
	
	IF cTributo == '1'
		//----------------------------------------------------------
		//Grava informações de recolhimento para PIS não Cumulativo
		//----------------------------------------------------------		
		nVlRec := Self:nVlRecN 
		If lF3J .AND. nVlRec > 0
			nReduzCL3	:= 0
			aValF3J:= Self:RegraCdRec('1', Self:nVlRecN, @nReduzCL3, Self:nVlContN)			
			
			//Se por algum motivo de arredondamento o valor ficar nagativo, então eu zero o M205/M605 legado
			IF nVlRec >= nReduzCL3 
				nVlRec	-= nReduzCL3
			Else
				nVlRec	:= 0
			EndIF		
			
			For nCont	:=1 to Len(aValF3J)
				//Inclui informações na CL3 conforme regra do usuário
				Self:cSeqTrib	:= Soma1(Self:cSeqTrib)
				Self:GrvRecolhi(Self:cSeqTrib,aValF3J[nCont][2],aValF3J[nCont][3],,,,,,,,'1' )				 	
			Next nCont
		EndIF
		//Inclui informações na CL3 conforme o legado
		Self:GrvRecolhi('1',nVlRec,Iif(nVlRec> 0 .AND. Len(aCodRec) >= 1,aCodRec[1] ,'' ))		
		
		//------------------------------------------------------	
		//Grava informações de recolhimento para PIS Cumulativo
		//------------------------------------------------------		
		nVlRec	:= Self:nVlRecC
		If lF3J .AND. nVlRec > 0
			nReduzCL3	:= 0
			aValF3J:= Self:RegraCdRec('2', Self:nVlRecC, @nReduzCL3, Self:nVlContC)						
			//Se por algum motivo de arredondamento o valor ficar nagativo, então eu zero o M205/M605 legado
			IF nVlRec >= nReduzCL3 
				nVlRec	-= nReduzCL3
			Else
				nVlRec	:= 0
			EndIF
			
			For nCont	:=1 to Len(aValF3J)
				//Inclui informações na CL3 conforme regra do usuário
				Self:cSeqTrib	:= Soma1(Self:cSeqTrib)
				Self:GrvRecolhi(Self:cSeqTrib,aValF3J[nCont][2],aValF3J[nCont][3],,,,,,,,'2' )				 	
			Next nCont
		EndIF
		
		//Inclui informações na CL3 conforme o legado
		Self:GrvRecolhi('2',nVlRec, Iif(nVlRec > 0 .AND. Len(aCodRec) >= 3,aCodRec[3],''))				
		
	ElseIf cTributo == '2'
		
		//-------------------------------------------------------------
		//Grava informações de recolhimento para COFINS não Cumulativo
		//-------------------------------------------------------------
		nVlRec	:= Self:nVlRecN
		If lF3J .AND. nVlRec > 0
			nReduzCL3	:= 0
			aValF3J:= Self:RegraCdRec('3', Self:nVlRecN, @nReduzCL3, Self:nVlContN)
			//Se por algum motivo de arredondamento o valor ficar nagativo, então eu zero o M205/M605 legado
			IF nVlRec >= nReduzCL3 
				nVlRec	-= nReduzCL3
			Else
				nVlRec	:= 0
			EndIF
			
			For nCont	:=1 to Len(aValF3J)
				//Inclui informações na CL3 conforme regra do usuário
				Self:cSeqTrib	:= Soma1(Self:cSeqTrib)
				Self:GrvRecolhi(Self:cSeqTrib,aValF3J[nCont][2],aValF3J[nCont][3],,,,,,,,'3' )
			Next nCont
		EndIF
		
		//Inclui informações na CL3 conforme o legado
		Self:GrvRecolhi('3',nVlRec,Iif(nVlRec > 0 .AND. Len(aCodRec) >= 2,aCodRec[2],''))			
		
		//--------------------------------------------------------
		//Grava informações de recolhimento para COFINS Cumulativo
		//--------------------------------------------------------
		nVlRec	:= Self:nVlRecC
		If lF3J .AND. nVlRec > 0
			nReduzCL3	:= 0
			aValF3J:= Self:RegraCdRec('4', Self:nVlRecC, @nReduzCL3, Self:nVlContC)			
			//Se por algum motivo de arredondamento o valor ficar nagativo, então eu zero o M205/M605 legado
			IF nVlRec >= nReduzCL3 
				nVlRec	-= nReduzCL3
			Else
				nVlRec	:= 0
			EndIF
			
			For nCont	:=1 to Len(aValF3J)
				//Inclui informações na CL3 conforme regra do usuário
				Self:cSeqTrib	:= Soma1(Self:cSeqTrib)
				Self:GrvRecolhi(Self:cSeqTrib,aValF3J[nCont][2],aValF3J[nCont][3],,,,,,,,'4' )				 	
			Next nCont
		EndIF
		
		//Inclui informações na CL3 conforme o legado
		Self:GrvRecolhi('4',nVlRec, Iif(nVlRec> 0 .AND. Len(aCodRec) >= 4,aCodRec[4],''))		
		
	EndIF

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RegraCdRec()
@Description Método que realiza o cálculo da proporcionalidade entre o valor da receita
acumulada conforme regra definida pelo usuário, e o total da receita tributada
do período

@author Erick G. Dias
@since 09/05/2017
@version 11.80

/*/
//-------------------------------------------------------------------
METHOD RegraCdRec(cTrib, nValorPag, nReduzCl3, nTotDeb) Class APURPISCOF

Local aRet			:= {}
Local nPercenF3J	:= 0
Local nValF3J		:= 0
Local cChaveF3J		:= ''

cChaveF3J	:= Self:BuscaxFil('F3J')+dTos(Self:dDtIni)+Self:cConsl+cTrib		
If F3J->(MSSEEK(cChaveF3J))
	//Processa o cálculo de todas as regras do tributo 
	Do While !F3J->(Eof ()) .AND. F3J->(F3J_FILIAL+DTOS(F3J_PER)+F3J_CONSOL+F3J_TRIBUT) == cChaveF3J
		//Obtem o percentual
		nPercenF3J	:= F3J->F3J_VLTRIB * 100 / nTotDeb //Percentual do valor acumulado na regra em função do valor total
		
		//Obtem o valor
		nValF3J	:= round(nValorPag * nPercenF3J / 100,2) //Valor da regra, considerando o percentual da receita acumulada em função do total da receita		
		
		//Acumula valor a ser subtraído
		nReduzCl3 += nValF3J		
		
		aAdd(aRet, {cTrib,nValF3J,F3J->F3J_CODREC})				
		
		RecLock('F3J',.F.)
		F3J->F3J_TOTPAG	:= nValorPag
		F3J->F3J_CODPAG	:= nValF3J
		F3J->F3J_PERCEN	:= nPercenF3J
		
		MsUnLock()
		
		F3J->(DBSKIP())
	EndDo

EndIF		

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvRecolhi()
Método que irá fazer gravação das informações sobre recolhimento considerando
valor já processado.

@param		cTributo - Tributo a ser processado.
@author Erick G. Dias
@since 30/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
METHOD GrvRecolhi(cTributo,nValor,cCodRec, dDataVenc, ;
					cNumTit, cPrexTit, cParcTit, cTipoTit, cFornece, cLoja, cTrbori) Class APURPISCOF
	
	Local 		lTit		:= CL3->(FieldPos("CL3_NUMTIT"))>0 	
	Local 		lTrbOri		:= CL3->(FieldPos("CL3_TRBORI"))>0
	Local 		lInclui	:= .F.
	DEFAULT	dDataVenc	:=CTod("  /  /    ")
	DEFAULT 	cNumTit	:= ''
	DEFAULT 	cPrexTit	:= ''
	DEFAULT 	cParcTit	:= ''
	DEFAULT 	cTipoTit	:= ''
	DEFAULT 	cFornece	:= ''
	DEFAULT 	cLoja		:= ''
	DEFAULT 	cTrbori		:= ''
	
	dbSelectArea('CL3')
	CL3->(dbSetOrder(1))
	
	lInclui	:= !CL3->(MSSEEK(Self:BuscaxFil('CL3')+dTos(Self:dDtIni)+Padr(cTributo,1)+Padr(Self:cConsl,1)))

	RecLock('CL3',lInclui)
	If lInclui
		CL3->CL3_FILIAL	:=	Self:BuscaxFil('CL3')
		CL3->CL3_PER		:=	Self:dDtIni
		CL3->CL3_TRIB		:=	cTributo
		CL3->CL3_CONSOL	:=	Self:cConsl	
	EndIF
	
	IF !Empty(cCodRec)
		CL3->CL3_CODREC	:=	Padr(cCodRec,6)

	EndIF
	
	CL3->CL3_VALOR	:=	nValor	
	
	if dDataVenc <> CTod("  /  /    ")
		CL3->CL3_DTVENC	:=	dDataVenc
	endif
	
	//Salva as informações do título gravado na SE2 no Financeiro.
	if lTit .AND. !empty(cNumTit)
		CL3->CL3_NUMTIT	:=	cNumTit
		CL3->CL3_PRETIT	:=	cPrexTit
		CL3->CL3_PARTIT	:=	cParcTit
		CL3->CL3_TPTIT	:=	cTipoTit
		CL3->CL3_FORTIT	:=	cFornece
		CL3->CL3_LOJTIT	:=	cLoja
	endif
	
	IF lTrbOri .AND. !Empty(cTrbori)
		CL3->CL3_TRBORI	:= cTrbori
	EndIF	
	MsUnLock()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadRecolh()
Método que irá carregar valores já gravados na tabela de recolhimento

@author Erick G. Dias
@since 30/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
METHOD LoadRecolh() Class APURPISCOF

	Local cAliasCL3	:= 'CL3'
	Local cSlctCL3	:= ''
	Local cFiltro		:= ''
	Local cDescr	:=''
	Local cTrbOri	:= ''
	Local lF3G		:= AliasINdic('F3G') .AND. CL3->(FieldPos("CL3_TRBORI"))>0
	Local lCprb 	:= .F.
	
	IF lF3G
		DbSelectArea ("F3G") 
		F3G->(DbSetOrder (2))
	EndIF
	
	cSlctCL3:= '%CL3.CL3_TRIB,		CL3.CL3_CODREC,	CL3.CL3_VALOR,	CL3.CL3_DTVENC'
	
	IF lF3G
		cSlctCL3+= ',CL3_TRBORI'
	EndIF
	
	cSlctCL3+='%'

	cFiltro := "%"
	cFiltro += "CL3.CL3_FILIAL= '"+ Self:BuscaxFil('CL3')+ "' AND "
	cFiltro += "CL3.CL3_PER>= '" + %Exp:DToS (Self:dDtIni)% + "' AND "
	cFiltro += "CL3.CL3_PER<= '" + %Exp:DToS (Self:dDtIni)% + "' AND "
	cFiltro += "CL3.CL3_CONSOL = '" + Self:cConsl	 + "' AND "	
	cFiltro += "CL3.D_E_L_E_T_=' ' "
	cFiltro += "ORDER BY CL3.CL3_TRIB%"
	

	cAliasCL3	:=	GetNextAlias()
	BeginSql Alias cAliasCL3
		COLUMN CL3_DTVENC AS DATE
		SELECT
		%Exp:cSlctCL3%

		FROM
		%Table:CL3% CL3
		WHERE
		%Exp:cFiltro%		
	EndSql

	DbSelectArea (cAliasCL3)
	(cAliasCL3)->(DbGoTop ())
	Do While !(cAliasCL3)->(Eof ())
	
		cDescr	:= ''
		cTrbOri	:= ''
		lCprb 	:= .F.
		IF lF3G					
			IF F3G->(MSSEEK(Self:BuscaxFil('F3G')  +  (cAliasCL3)->CL3_CODREC + DefRegCL3((cAliasCL3)->CL3_TRIB)  ))
				//Busco a ~descrição do código de receita informada pelo usuário
				cDescr	:= F3G->F3G_DESC
				//Busco também o código do tributo gravado na CL3, referente as regras cadastradas previamente
				cTrbOri	:=(cAliasCL3)->CL3_TRBORI
			EndIF
		EndIF			
		
		//Mantenho o código do tributo para o legado
		IF (cAliasCL3)->CL3_TRIB $ '1/2/3/4'
			cTrbOri	:= (cAliasCL3)->CL3_TRIB	
		EndIF

		//Se o tributo estiver vazio, não é nenhuma das 4 linhas originais de PIS e COFINS, e também nenhuma configurável de PIS e COFINS, portanto não é PIS e nem COFINS, e sim CPRB.
		If Empty(cTrbOri)
			lCprb	:= .T.
			cDescr	:= "CPRB"
		EndIF
		
		aAdd(Self:aRecolh, {(cAliasCL3)->CL3_TRIB,(cAliasCL3)->CL3_CODREC,(cAliasCL3)->CL3_VALOR,(cAliasCL3)->CL3_DTVENC,cDescr,cTrbOri,lCprb})

		(cAliasCL3)->(DbSkip ())
	EndDo

	DbSelectArea (cAliasCL3)
	(cAliasCL3)->(DbCloseArea())

Return Self:aRecolh

//-------------------------------------------------------------------
/*/{Protheus.doc} DefRegCL3()
Função que irá retornar as opções de tribot e regime.

@author Erick G. Dias
@since 09/05/17
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function DefRegCL3(cTrib)

Local cRet	:= ''

If cTrib == '1'
	cRet	:= '11' //PIS NÃO CUMULATIVO
ElseIf cTrib == '2'
	cRet	:= '12' //PIS CUMULATIVO
ElseIf cTrib == '3'
	cRet	:= '21' //COFINS NÃO CUMULATIVO
ElseIf cTrib == '4'
	cRet	:= '22' //COFINS CUMULATIVO
EndIF

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCodRec()
Método que irá retornar o código da receita 

@param cTrib - Tributo
@author Erick G. Dias
@since 30/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method GetCodRec(cTrib) Class APURPISCOF

Local cCodRec

cCodRec := Self:RecolhTrib(cTrib,2)

Return Iif(cCodRec == Nil,'',cCodRec)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetValor()
Método que irá retornar o valor do tributo referente ao código da receita 

@param cTrib - Tributo
@author Erick G. Dias
@since 30/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method GetValor(cTrib) Class APURPISCOF

Local nValor

nValor:= Self:RecolhTrib(cTrib,3)

Return Iif(nValor == Nil,0,nValor)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDtVenc()
Método que irá retornar a data de vencimento do recolhimento do tributo. 

@param cTrib - Tributo
@author Erick G. Dias
@since 30/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method GetDtVenc(cTrib) Class APURPISCOF

Local dtVenc

dtVenc:= Self:RecolhTrib(cTrib,4)

Return Iif(dtVenc == Nil,CTod("  /  /    "),dtVenc) 

//-------------------------------------------------------------------
/*/{Protheus.doc} RecolhTrib()
Método que irá buscar valores do recolhimento referente ao código da
receita e tributo. 

@param cTrib - Tributo
@author Erick G. Dias
@since 30/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method RecolhTrib(cTrib,cColuna) Class APURPISCOF
	Local nPos	:= 0
	Local xRet

	nPos:=aScan(Self:aRecolh,{|aX| aX[1]==cTrib})
	If nPos > 0
		xRet := Self:aRecolh[nPos][cColuna]
	EndIF

Return xRet
//----------------------------------------------------

//DECLARAÇÃO DA CLASSE AJUSTEEFD 

//----------------------------------------------------
//-------------------------------------------------------------------
/*/{Protheus.doc} AJUSTEEFD
Classe que será responsável por realizar a gravação e verificação de 
todos os ajustes realizados na EFD.

@author Erick G. Dias
@since 05/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------

CLASS AJUSTEEFD FROM EFDGEN

	Data cTributo	As String	 	//tributo processado 1-PIS 2-COFINS
	Data cTpAjuste	As String 		//Tipo do ajuste efetuado 0-Redução 1-Acréscimo
	Data cCodAjuste	As String 		//Código do Ajuste
	Data cNumDoc	As String 		//Número do Documento 
	Data cDescrAju	As String 		//Descrição do ajuste
	Data cCodConCrd	As String		//Código do Crédito ou da contribuição
	Data cChvEfd	As String		//Chave da EFD de relação com registro pai
	Data cAcrescimo	As String	
	Data cReducao	As String	
	Data cAjuCrdDeb	As String
	Data lMesmoCod	As Boolean
	Data cIndCre	As String
	Data cOrigem	As String
	Data cRegime	As String
	Data cNumOri	As String
	Data cNumDev	As String	
	Data nVlAjuste 	As Integer 	//Valor do ajuste efetuado
	Data nVlAjuGrv 	As Integer 	//Valor do ajuste efetuado
	Data nAliqAju 	As Integer 	//Valor do ajuste efetuado	
	Data cEdita 	As String 	//Valor do ajuste efetuado	
	Data dDtRefer	As Date			//Data de referência do ajuste
	Data aCrdPISCOF	As Array		//Array com valores de créditos disponíveis no período
	Data aDebPISCOF	As Array		//Array com valores de créditos disponíveis no período
	Data aCred		As Array
	Data aVlPISCOF	As Array
	Data cTipAtiv	As String

	Data cCSt		As String
	Data cConta		As String
	Data cInfCompl	As String
	Data nBaseCalc	As Integer
	Data nAlq		As Integer
	Data cCodBcc    As String
	Data nTamDesc	As Integer
	Data nTamConta  As Integer
	Data nTamInfCom	As Integer
	Data cCNatRec	As String
	Data cTNatRec	As String
	Data cCnpj		As String	
	Data lAjuBase	As Boolean
	Data lCmpAjuBas As Boolean
	Data lAjuCKR 	As Boolean
	Data lAjuF2Z	As Boolean
	Data nValDebPis As Integer
	Data nValDebCof As Integer
	Data lAtuaCKS	As Boolean

	METHOD SetDtRefer(Value)	
	METHOD SetTributo(Value)
	METHOD SetTpAjust(Value)
	METHOD SetCodAju(Value)
	METHOD SetNumDoc(Value)
	METHOD SetDescAju(Value)
	METHOD SetVlAju(Value)
	METHOD SetVlAjGrv(Value)
	METHOD SetEdita(Value)	
	METHOD SetAcred(Value)
	METHOD SetCodDC(Value)	
	METHOD SetCHVEFD(Value)
	METHOD SetCrdDeb(Value)
	METHOD SetMsmCod(Value)		
	METHOD SetOrigem(Value)
	METHOD SetRegime(Value)
	METHOD SetNumOri(Value)
	METHOD SetNumDev(Value)
	METHOD SetTipAtiv(Value)
	METHOD SetCNPJ(Value)
	METHOD SetAjuBase(Value)
	METHOD SetAjuCKR(Value)
	METHOD SetAjuF2Z(Value)		
	METHOD SetAtuaCKS(Value)	
	METHOD Ajustar()
	METHOD AtuAjuste()
	METHOD GrvAjuste()
	METHOD LoadCL8()
	METHOD LoadCKS()
	METHOD New()
	METHOD SetCst() 
	METHOD SetConta()
	METHOD SetInfComp()
	METHOD SetBase()
	METHOD SetAlq()
	METHOD SetCodBcc()
	METHOD SetTNatRec()
	METHOD SetCNatRec()
	METHOD GetVlrCL8()
	METHOD GetVlAjGrv()
	METHOD GetAtuaCKS(Value)
	METHOD AtuCKR()	
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método Contrutor da Classe AJUSTEEFD. Esta classe será responsável
por realizar os cálculos da aba de apuração e aba das informações
de recolhimento do tributo.

@author Erick G. Dias
@since 30/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------

METHOD New() Class AJUSTEEFD

Self:cTributo	:= ''
Self:cTpAjuste	:= ''
Self:cCodAjuste	:= ''
Self:cNumDoc	:= '' 
Self:cDescrAju	:= ''
Self:cOrigem	:= ''
Self:cNumOri	:= ''
Self:cNumDev	:= ''
Self:cRegime	:= ''
Self:cEdita		:= '2' //Soma
Self:nVlAjuste 	:= 0
Self:nVlAjuGrv	:= 0
Self:nAliqAju	:= 0
Self:dDtRefer	:= CTod("  /  /    ")
Self:dDtIni	 	:= CTod("  /  /    ")
Self:aCred		:= {}
Self:cCodConCrd	:= ''
Self:cChvEfd	:= ''
Self:cAcrescimo	:= '1' 
Self:cReducao	:= '0'
Self:cAjuCrdDeb	:= ''
Self:lMesmoCod	:= .T.
Self:aCrdPISCOF	:= {}
Self:aDebPISCOF	:= {}
Self:cIndCre	:= '0'
Self:aVlPISCOF	:= {}
Self:cConsl		:= '2'

Self:cCSt		:= ''
Self:cConta		:= ''
Self:cInfCompl	:= ''
Self:nBaseCalc	:= 0
Self:nAlq		:= 0
Self:nValDebPis	:= 0
Self:nValDebCof	:= 0
Self:cTipAtiv	:= '' 
Self:cCodBcc	:= ''
Self:cCnpj		:= ''
Self:lAjuBase	:= .F.
Self:lAjuCKR	:= .F.		
Self:lAjuF2Z	:= .F.
Self:lAtuaCKS	:= .F.
Self:lCmpAjuBas	:= CKS->(FieldPos("CKS_BCAJUS"))>0 

Self:IniHash()

IF CL4->(FieldPos('CL4_IDCLA')) > 0
	Self:nTamDesc		:= TamSx3("CL4_DESC")[1]
	Self:nTamConta	:= TamSx3("CL4_CODCTA")[1]
	Self:nTamInfCom	:= TamSx3("CL4_INFO")[1]
EndIF

DbSelectArea('CLA')
CLA->(dbSetOrder(1))
dbSelectArea('CL8')
CL8->(dbSetOrder(1))
dbSelectArea('CKS')
CKS->(dbSetOrder(1))

Return Self


Method SetDtRefer(dData) Class AJUSTEEFD
	Self:dDtRefer	:= dData	
Return 

Method SetTributo(cTrib) Class AJUSTEEFD	
	Self:cTributo	:= cTrib
Return 

Method SetTpAjust(cTpAju) Class AJUSTEEFD
	Self:cTpAjuste	:= cTpAju 
Return 

Method SetCodAju(cCod) Class AJUSTEEFD
	Self:cCodAjuste	:= cCod
Return 

Method SetNumDoc(cNumDoc) Class AJUSTEEFD
	Self:cNumDoc	:= cNumDoc
Return 

Method SetDescAju(cDescr) Class AJUSTEEFD
	Self:cDescrAju	:= cDescr
Return 

Method SetVlAju(nValor) Class AJUSTEEFD
	Self:nVlAjuste	:= nValor 
Return 

Method SetVlAjGrv(nValor) Class AJUSTEEFD
	Self:nVlAjuGrv	:= nValor 
Return 

Method SetEdita(nValor) Class AJUSTEEFD
	Self:cEdita	:= nValor 
Return 

METHOD SetAcred(aArray)  Class AJUSTEEFD
	Self:aCred	:= aArray
Return

METHOD SetCodDC(cCod) Class AJUSTEEFD
	Self:cCodConCrd	:= PADR(cCod,3) 
Return

METHOD SetCHVEFD(cChave) Class AJUSTEEFD
	Self:cChvEfd	:=	cChave 
Return

METHOD SetCrdDeb(cValue) Class AJUSTEEFD
	Self:cAjuCrdDeb	:=	cValue
Return

METHOD SetMsmCod(cValue) Class AJUSTEEFD
	Self:lMesmoCod	:=	cValue
Return

METHOD SetOrigem(cValor) Class AJUSTEEFD
	Self:cOrigem	:=	cValor
Return

METHOD SetNumOri(cValor) Class AJUSTEEFD
	Self:cNumOri	:=	cValor
Return

METHOD SetNumDev(cValor) Class AJUSTEEFD
	Self:cNumDev	:=	cValor
Return

METHOD SetRegime(cValor) Class AJUSTEEFD
	Self:cRegime	:=	cValor
Return


METHOD SetCst(cValor) Class AJUSTEEFD
	Self:cCSt	:=	cValor
Return

METHOD SetConta(cValor) Class AJUSTEEFD
	Self:cConta	:=	cValor
Return

METHOD SetInfComp(cValor) Class AJUSTEEFD
	Self:cInfCompl	:=	cValor
Return

METHOD SetBase(nValor) Class AJUSTEEFD
	Self:nBaseCalc	:=	nValor
Return

METHOD SetAlq(nValor) Class AJUSTEEFD
	Self:nAlq	:=	nValor
Return

METHOD SetTipAtiv(cValor) Class AJUSTEEFD
	Self:cTipAtiv	:=	cValor
Return

METHOD SetCodBcc(cValor) Class AJUSTEEFD
	Self:cCodBcc	:=	cValor
Return

METHOD SetTNatRec(cValor) Class AJUSTEEFD
	Self:cTNatRec	:=	cValor
Return
METHOD SetCNatRec(cValor) Class AJUSTEEFD
	Self:cCNatRec	:=	cValor
Return

METHOD SetCNPJ(cValor) Class AJUSTEEFD
	Self:cCnpj	:=	cValor
Return

METHOD SetAjuBase(lValor) Class AJUSTEEFD
	Self:lAjuBase	:=	lValor
Return

METHOD SetAjuCKR(lValor) Class AJUSTEEFD
	Self:lAjuCKR	:=	lValor
Return

METHOD SetAjuF2Z(lValor) Class AJUSTEEFD
	Self:lAjuF2Z	:=	lValor
Return

METHOD SetAtuaCKS(lValor) Class AJUSTEEFD
	Self:lAtuaCKS	:=	lValor
Return

METHOD GetVlrCL8() Class AJUSTEEFD	
Return Self:aVlPISCOF

Method GetVlAjGrv(nValor) Class AJUSTEEFD
Return	Self:nVlAjuGrv	

METHOD GetAtuaCKS(lValor) Class AJUSTEEFD
Return	Self:lAtuaCKS



//-------------------------------------------------------------------
/*/{Protheus.doc} Ajustar()
Método que fará o ajuste de redução ou de acréscimo dos créditos, irá 
chamar métodos para gravar o ajuste e atualizar os créditos ou de débitos.

@author Erick G. Dias
@since 05/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method Ajustar(lSaldo, lMesmaAlq) Class AJUSTEEFD

Local nCont		:= 0
Local lIntegral	:= .F.
Local lCodBccCst	:= !Empty(Self:cCodBcc) .AND. !Empty(Self:cCst)
Local oSaldoDed	
Default lSaldo	:= .T.
Default lMesmaAlq	:= .F.

/*//-------------------------------------------------------------------
aTemp
Posições:

1 - Tributo
2 - Código
3 - Chave EFD
4 - Valor
5 - Regime
6 - 1= Crédito / 2= Débito
7 - CST de crédito
8 - CODBCC
*///-------------------------------------------------------------------

//É necessário percorrer todos os registros de crédito e débitos para poder fazer o ajuste.
For nCont:=1 to Len (Self:aVlPISCOF)
	lIntegral	:= .F.
	
	If	Self:nVlAjuste == 0 .and. !Self:lAtuaCKS
		Exit
	EndIF	
	
	//Aqui teremos tratamento onde o ajuste será efetuado extamente no mesmo código da contribuição ou de crédito
	//Porém existem situações no legado onde o ajuste não será efetuado exatamento no mesmo código
	//Então será efetuado nos primeiros valores de débitos ou créditos disponíveis.
	IF Self:aVlPISCOF[nCont][1] == Self:cTributo .AND. (Iif (Self:lMesmoCod,Alltrim(Self:aVlPISCOF[nCont][2]) == Alltrim(Self:cCodConCrd),.T.))  .AND. ;	
	Iif(lMesmaAlq, Self:aVlPISCOF[nCont][9] == Self:nAlq ,.T.) .AND. ;
	Iif( lCodBccCst .AND.  Self:aVlPISCOF[nCont][6] == '1', Self:aVlPISCOF[nCont][7] == Self:cCst .AND.  Self:aVlPISCOF[nCont][8] == Self:cCodBcc , .T. ) 
		
		Self:cChvEfd	:= Self:aVlPISCOF[nCont][3]
		Self:nAliqAju	:= Self:aVlPISCOF[nCont][9]
		Self:cRegime	:= Self:aVlPISCOF[nCont][5]

		//Força atualização da CKS para evitar problema de arredondamento.
		IF Self:lAtuaCKS .and. Self:nVlAjuste == 0
			Self:AtuAjuste()
			exit
		Endif

		If Self:cTpAjuste == Self:cAcrescimo 		
			//-------------------------------------------------------------------
			//Para ajuste de acréscimo irá sempre fazer ajuste integral
			//-------------------------------------------------------------------
			lIntegral	:= .T.
			Self:aVlPISCOF[nCont][4] += Self:nVlAjuste
		ElseIf Self:cTpAjuste == Self:cReducao
			IF Self:nVlAjuste <= Self:aVlPISCOF[nCont][4]
				//-------------------------------------------------------------------
				//Para ajuste de redução, onde o valor do ajuste for menor que o valor			
				//do crédito, será ajuste integral
				//-------------------------------------------------------------------
				lIntegral	:= .T.
				Self:aVlPISCOF[nCont][4] -= Self:nVlAjuste			
			Else //Valor do ajuste é de redução e é maior que o valor disponível para se reduzir			  
				//-------------------------------------------------------------------
				//Gravar o ajuste parcial
				//porém não gravar no saldo ainda.
				//-------------------------------------------------------------------
				lIntegral	:= .F.							
			EndIF
			
		EndIF
			
		
		If Empty(Self:aVlPISCOF[nCont][8]) .And. !Empty(Self:aVlPISCOF[nCont][2])
			If Alltrim(Self:aVlPISCOF[nCont][2]) == "31"
				Self:cCST = "05"
			ElseIf Alltrim(Self:aVlPISCOF[nCont][2]) == "51"
				Self:cCST = "01"
			EndIf
		EndIf
		IF lIntegral		
			Self:nVlAjuGrv	:= Self:nVlAjuste					
			//Somente irá gravar ajuste na tabela de ajuste se for corretamente utilizado na apuração
			If Self:AtuAjuste()		
				Self:GrvAjuste(Alltrim(Self:aVlPISCOF[nCont][2]))
				Self:nVlAjuste := 0
			EndIF
			
		Else		
			//Fazer proporcional
			//CHAMAR OBJETO DE SALDO DE DEDUÇÃO PARA GRAVAR DIFERENÇA EM CF3	
			
			//O valor do ajuste será o valor total disponível, pois o ajuste é maior que o disponível, sendo assim irá zerar o valor 
			//do crédito ou do débito.
			Self:nVlAjuGrv	:= Self:aVlPISCOF[nCont][4]
			If Self:nVlAjuGrv > 0 .And. Self:AtuAjuste()	
				//Grava o valor de ajuste na tabela
				Self:GrvAjuste(Alltrim(Self:aVlPISCOF[nCont][2]))
				
				//Zerando o valor, para que não seja mais efetuado nenhum ajuste de redução.
				Self:nVlAjuste	-= Self:aVlPISCOF[nCont][4]
				Self:aVlPISCOF[nCont][4]	:= 0
			EndIF
		EndIF
	EndIf
	
Next nCont

//-------------------------------------------------------------------
//Caso existir ainda valor em Self:nVlAjuste, é porque percorreu todos os registros da apuração com o código
//do ajuste e não havia mais como realizar o ajuste, por este motivo será gravado no saldo de redução.
//-------------------------------------------------------------------

If lSaldo .AND. Self:nVlAjuste > 0
	
	//Cria objeto para fazer a gravação do saldo de dedução.			
	oSaldoDed	:= 	SALDODED():New()
	oSaldoDed:SetConsol(Self:cConsl)
	oSaldoDed:SetDtIni(Self:dDtIni)
	oSaldoDed:SetPerOri(Self:dDtIni)
	oSaldoDed:SetRegime(Self:cRegime)
	oSaldoDed:SetValPis( Iif(Self:cTributo =='1',	Self:nVlAjuste,0  ))
	oSaldoDed:setValCof( Iif(Self:cTributo =='2',	Self:nVlAjuste,0 ))
	oSaldoDed:SetOrigem(Self:cOrigem)
	oSaldoDed:SetNfOri(Self:cNumOri)
	oSaldoDed:SetNfDev(Self:cNumDev)
	oSaldoDed:SetConta(Self:cConta)			
	oSaldoDed:GrvSaldo()
	FreeObj(oSaldoDed)
	oSaldoDed:= nil

EndIF

/* 
Retono para que a cçasse faça os próximos ajustes conderando extamente os mesmos
códigos da contribuição ou de crédito, e caso não seja necessário quem chamar este método
deverá especificar que não será efetuado ajuste com o mesmo código
*/

Self:lMesmoCod := .T.
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuAjuste()
Método que irá realizar o ajuste na tabela CL8 ou CKS, com os valores de ajuste
de acréscimo ou redução do crédito ou do débito

@author Erick G. Dias
@since 05/05/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method AtuAjuste() Class AJUSTEEFD
Local lRet		:= .F.
Local lTribReg	:= .F.
Local lCST		:= .F.
Local lCODCON	:= .F.
Local lTNatRec	:= .F.
local lCNatRec	:= .F.
Local lF3G		:= AliasINdic('F3G')
Local lF3J		:= AliasINdic('F3J')
Local cChave	:= ''
Local cCodRec	:= ""
Local cF3JTrib	:= ""

If Self:cAjuCrdDeb == '1' /*Crédito*/
	
	cChave	:= Self:BuscaxFil('CL8')+dTos(Self:dDtIni)+Self:cChvEfd+Self:cIndCre	
	//Para os ajustes manuais que não possuirem CODBCC, irá buscar informações da CL8 considerando a chaveEFD e indicador do crédito
	If !Empty(Self:cCodBcc)
		cChave	+= PADR(Self:cCodBcc,2)+Self:cCst
	EndIF
	//-------------------------------------------------------------------
	//Atualiza valores referente do crédito considerando o valor do ajuste
	//-------------------------------------------------------------------
	If CL8->(MSSEEK( cChave ))
		RecLock('CL8',.F.)
		
		IF Self:cTpAjuste == Self:cAcrescimo
			If Self:cEdita == '1'
				CL8->CL8_AJAC		-=  Self:nVlAjuGrv
			Else
				CL8->CL8_AJAC		+=  Self:nVlAjuGrv			
			EndIF
		Else
			If Self:cEdita == '1'
				CL8->CL8_AJRD		-=  Self:nVlAjuGrv
			Else
				CL8->CL8_AJRD		+=  Self:nVlAjuGrv			
			EndIF
		EndIF	
	
		CL8->CL8_TOTCRD	:=	CL8->CL8_VLCRED+CL8->CL8_AJAC- CL8->CL8_AJRD //Recalcula valor do valor disponível do crédito
		MsUnLock()
		lRet	:= .T.
	EndIF

ElseIF Self:cAjuCrdDeb == '2' 	
	If Self:lAjuBase //Base de cálculo do Débito
		//Atualização da base de cálculo e refazer a conta novamente
		If Self:lCmpAjuBas .AND. CKS->(MSSEEK(Self:BuscaxFil('CKS')+dTos(Self:dDtIni)+Self:cChvEfd))
			RecLock('CKS',.F.)
		
			IF Self:cTpAjuste == Self:cAcrescimo
				//Acréscimo na base de cálculo
				CKS->CKS_AJBCA 		+= Self:nVlAjuGrv	
			Else
				//Redução na base de cálculo
				CKS->CKS_AJBCR 		+=	Self:nVlAjuGrv
			EndIF			

			//Aqui recomponho a base ajustada integralmente
			CKS->CKS_BCAJUS	:= CKS->CKS_BASE + CKS->CKS_AJBCA - CKS->CKS_AJBCR

			//Aqui é necessário recompor o valor da contribuição novamente, tendo em vista que o valor da base de cálculo foi alterada.
			//Lembrando que como os ajustes da base de cálculo acontecem antes dos ajutes do valor da contribuição, não precisao atualizar os campos
			//de ajustes de acréscimo ou redução da contribuição, bem como os campos do diferimento.				
			CKS->CKS_VLTRIB	:= Round((CKS->CKS_BCAJUS * Self:nAliqAju) / 100,2)

			CKS->CKS_VLDISP	:= CKS->(CKS_VLTRIB+CKS_AJAC-CKS_AJRD-CKS_DIF+CKS_DIFANT)
		
			CKS->(MsUnLock())
			lRet	:= .T.
		EndIF
	Else
		//-------------------------------------------------------------------
		//Atualiza valores referente ao débito considerando o valor do ajuste
		//-------------------------------------------------------------------
		If CKS->(MSSEEK(Self:BuscaxFil('CKS')+dTos(Self:dDtIni)+Self:cChvEfd))
			RecLock('CKS',.F.)
		
			IF Self:cTpAjuste == Self:cAcrescimo
				If Self:cEdita == '1' //Utilizado para ajuste manual na apuração
					CKS->CKS_AJAC		-=  Self:nVlAjuGrv
				Else
					CKS->CKS_AJAC		+=  Self:nVlAjuGrv			
				EndIF
			Else
				If Self:cEdita == '1' //Utilizado para ajuste manual na apuração
					CKS->CKS_AJRD		-=  Self:nVlAjuGrv
				Else
					CKS->CKS_AJRD		+=  Self:nVlAjuGrv			
				EndIF
			EndIF	
	
			CKS->CKS_VLDISP	:=	CKS_VLTRIB+CKS_AJAC-CKS_AJRD-CKS_DIF+CKS_DIFANT
		
			MsUnLock()
			lRet	:= .T.
		EndIf
	EndIf
	If lRet .And. lF3J .And. lF3G
		DbSelectArea ("F3G") 
		F3G->(DbSetOrder (1))
		F3G->(DbGoTop ())
		F3G->(MSSEEK(Self:BuscaxFil('F3G')))
			
		//É necessário processar todas as regras da tabela F3G
		Do While !F3G->(Eof ()) .AND. F3G->F3G_FILIAL == Self:BuscaxFil('F3G')
				
			lTribReg	:= .F.
			lCST		:= .F.
			lCODCON		:= .F.
			lTNatRec	:= .F.
			lCNatRec	:= .F.
				
			//Se o tributo e o regime forem diferentes, esta regra não será processada
			IF F3G->F3G_TRIBUT == Self:cTributo .AND. F3G->F3G_REGIME == Self:cRegime
					
				//Enquadrou Regime e tributo
				lTribReg	:= .T.
					
				IF Empty(F3G->F3G_CST) .OR. F3G->F3G_CST == Self:cCST .OR. Iif(Self:lAjuF2Z , .T., .F.)
					lCST	:= .T.
				EndIF			
		
				IF Empty(F3G->F3G_CODCON) .OR. F3G->F3G_CODCON == Alltrim(Self:cCodConCrd)
					//Enqudrou Código da COntribuição
					lCODCON	:= .T.				
				EndIF			
		
				IF Empty(F3G->F3G_NATREC) .OR. F3G->F3G_NATREC == Self:cTNatRec
					//Enquadrou Tabela da Natureza da Receita
					lTNatRec	:= .T.				
				EndIF			
		
				IF Empty(F3G->F3G_CNATRE) .OR. F3G->F3G_CNATRE == Self:cCNatRec
					//Enquadrou Código da Receita da Natureza
					lCNatRec	:= .T.				
				EndIF
	
			EndIF			
				
			IF lTribReg .AND. lCST .AND. lCODCON .AND.  lTNatRec .AND. lCNatRec
				//Todas as informações se enquadraram, então pode adotar o código da receita para o valor acumulado
				cCodRec := F3G->F3G_CODREC
			EndIF

			F3G->(DbSkip ())
		EndDo
		If !Empty(cCodRec)
			cF3JTrib := DefTrib(Self:cTributo,Self:cRegime)
			If F3J->(MSSEEK(Self:BuscaxFil('F3J') + dTos(Self:dDtIni) + Self:cConsl+ cF3JTrib  + cCodRec ))
				RecLock('F3J',.F.)
				If Self:lAjuBase
					F3J->F3J_VLTRIB	:= CKS->CKS_VLDISP
				Else				
					F3J->F3J_VLTRIB	-= Self:nVlAjuGrv
				EndIf
				MsUnLock()
			EndIF
		EndIF
	EndIf
EndIF

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} GrvAjuste()
Método que irá gravar informações dos ajustes nas respectivas tabelas.
Aqui serão processados somente os valores de ajustes que foram considerados
no processamento da apuração.

@author Erick G. Dias
@since 05/05/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Method GrvAjuste(cCodCon) Class AJUSTEEFD

Local cPerAtu 		:= cvaltochar(strzero(month(Self:dDtIni),2)) + cvaltochar(year(Self:dDtIni))
Local lCl4IdCla		:= CL4->(FieldPos('CL4_IDCLA')) > 0  
Local cIdCLA			:= ''
Local aParam := {}
Local aRet := {}
Default cCodCon	:= ""

If ExistBlock("EFDCON04")
	aParam := {Self:cChvEfd,Self:cTpAjuste,Self:cDescrAju,Self:cConta,Self:cCst,Self:nAlq,Self:nVlAjuGrv,cPerAtu,Self:dDtRefer,Self:lAjuBase,Self:cTributo,Self:cNumDoc,Self:cInfCompl}
	aRet := ExecBlock("EFDCON04", .F., .F.,aParam)
	
	If Len(aRet) == 4 .And. ValType(aRet) == "A"
		If !Empty(aRet[1])
			Self:cDescrAju := aRet[1]
		EndIf
		If !Empty(aRet[2])
			Self:cInfCompl := aRet[2]
		EndIf
		If !Empty(aRet[3])
			Self:cNumDoc := aRet[3]
		EndIf
		If !Empty(aRet[4])
			Self:cConta := aRet[4]
		EndIf
	EndIf
EndIf

If !Self:lAjuBase 

	//Grava informações na tabela CLA, referente ao ajuste	
	If !CLA->(MSSEEK(Self:BuscaxFil('CLA')+Self:cChvEfd+Self:cTpAjuste+Self:cCodAjuste+padr(Self:cNumDoc,50)+dTos(Self:dDtRefer)+Self:cConsl+Self:cDescrAju))
		RecLock('CLA',.T.)
		CLA->CLA_FILIAL	:=	Self:BuscaxFil('CLA')		
		CLA->CLA_CHV	:=	Self:cChvEfd		
		cIdCLA			:= GetSXENum('CLA','CLA_ID',Self:BuscaxFil('CLA'))
		CLA->CLA_ID		:=  cIdCLA
		CLA->CLA_TPAJU	:=	Self:cTpAjuste
		CLA->CLA_VLAJU	:=	Self:nVlAjuGrv	
		CLA->CLA_COD	:=	Self:cCodAjuste
		CLA->CLA_NUM	:=	Self:cNumDoc
		CLA->CLA_DESCR	:=	Self:cDescrAju
		CLA->CLA_DTREF	:=	Self:dDtRefer	
		CLA->CLA_CTA    :=  Self:cConta	
		CLA->CLA_PERUTI	:=	cPerAtu		
		CLA->CLA_CONSOL	:=	Self:cConsl
		If CLA->(FieldPos("CLA_FILORI"))>0
			CLA->CLA_FILORI :=  Self:BuscaxFil('CLA')
		Endif
		MsUnLock()
		ConfirmSX8()
	Else
		RecLock('CLA',.F.)
		CLA->CLA_VLAJU	+=	Self:nVlAjuGrv
		cIdCLA	:= CLA->CLA_ID
		MsUnLock()	
	EndIF

	//Grava informações na tbaela CL4, referente ao detalhamento dos ajustes
	If lCl4IdCla   
		dbSelectArea('CL4')
		DbSetOrder(2)		
		Self:cCst	:= PADR(Self:cCst,2)  
		Self:cDescrAju	:= PADR(Self:cDescrAju,Self:nTamDesc)
		Self:cInfCompl	:= PADR(Self:cInfCompl,Self:nTamInfCom)
		Self:cConta		:= PADR(Self:cConta,Self:nTamConta)
		
		If !CL4->(MSSEEK(Self:BuscaxFil('CL4')+ Self:cChvEfd + cIdCLA + dTos(Self:dDtRefer)+ Self:cCst + Self:cConta + Self:cInfCompl + Self:cDescrAju  +str(Self:nAlq,8,4) ))

			RecLock('CL4',.T.)
			CL4->CL4_FILIAL	:=	Self:BuscaxFil('CL4')		
			CL4->CL4_PER		:=	Self:dDtIni			
			CL4->CL4_ID		:=  GetSXENum('CL4','CL4_ID',Self:BuscaxFil('CL4'))
			CL4->CL4_IDCLA	:=	cIdCLA
			CL4->CL4_CHV		:=	Self:cChvEfd
			CL4->CL4_VLAJU	:=	Self:nVlAjuGrv	
			CL4->CL4_CST		:=	Self:cCst
			CL4->CL4_BASE		:=	Self:nBaseCalc
			CL4->CL4_ALQ		:=	Self:nAlq
			CL4->CL4_DATA		:=	Self:dDtRefer			
			CL4->CL4_DESC		:=	Self:cDescrAju		
			CL4->CL4_CODCTA	:=	Self:cConta	
			CL4->CL4_INFO		:=	Self:cInfCompl						
			MsUnLock()
			ConfirmSX8()
		
		Else

			RecLock('CL4',.F.)
			CL4->CL4_VLAJU += Self:nVlAjuGrv
			CL4->CL4_BASE +=	Self:nBaseCalc
			MsUnLock()
		EndIF	
			
	EndIf
Else
	//Gravação dos ajustes de base de cálculo considerados pela apuração	
	RecLock('F2Z',.T.)
	F2Z->F2Z_FILIAL	:=	Self:BuscaxFil('F2Z')
	F2Z->F2Z_CHV	:=	Self:cChvEfd
	F2Z->F2Z_ID		:=  FWUUID("F2Z")
	F2Z->F2Z_INDAJU	:=	Self:cTpAjuste
	F2Z->F2Z_VALAJU	:=	Self:nVlAjuGrv
	F2Z->F2Z_CODAJU	:=	Self:cCodAjuste
	F2Z->F2Z_NUM	:=	Self:cNumDoc
	F2Z->F2Z_DESCR	:=	Self:cDescrAju
	F2Z->F2Z_DTREF	:=	Self:dDtRefer
	F2Z->F2Z_PERAPU	:=	firstDay(Self:dDtRefer)
	F2Z->F2Z_CONTA	:=	Self:cConta
	F2Z->F2Z_CNPJ	:=	Self:cCnpj
	F2Z->F2Z_COMPL	:=	Self:cInfCompl
	F2Z->F2Z_TRIB	:=	Self:cTributo
	F2Z->F2Z_CODCON	:=	Iif(Empty(Self:cCodConCrd),cCodCon,Self:cCodConCrd)
	F2Z->F2Z_ORIG	:=	"2" //Indica a origem automática do sistema/apuração
	F2Z->F2Z_CONSOL	:=	Self:cConsl	
	MsUnLock()	

EndIF
	
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} AtuCKR()
Método que irá gravar informações dos ajustes nas respectivas tabelas.
Aqui serão processados somente os valores de ajustes que foram considerados
no processamento da apuração.

@since 20/02/2020

/*/
//-------------------------------------------------------------------
Method AtuCKR(cTrib) Class AJUSTEEFD

Local nValDeb := 0 
Local cAliasCKS	:= x001QRYCKS('1',Self:dDtIni,Self:cRegime,Self:BuscaxFil('CKZ'),Self:cConsl)

Do While !(cAliasCKS)->(Eof ())

	If (cAliasCKS)->CKZ_TRIB == cTrib
		nValDeb += (cAliasCKS)->CKS_VLTRIB 
	EndIf		
	(cAliasCKS)->(DbSkip())
EndDo

If Self:lAjuCKR
	If CKR->(MSSEEK(Self:BuscaxFil('CKR')+dTos(Self:dDtIni)+Self:cConsl+cTrib))
		RecLock('CKR',.F.)
		If Self:cRegime == '1'
			CKR_CONNC	:= nValDeb
			CKR_NCREC := CKR_CONNC  - CKR_CRDANT - CKR_CRDATU - CKR_RTANTN - CKR_RTATUN - CKR_OUTDNC				
		ElseIF Self:cRegime == '2'
			CKR_CONC	:= nValDeb
			CKR_CREC := CKR_CONC - CKR_RTANTC - CKR_RTATUC - CKR_OUTDC			
		EndIF
		MsUnLock()
	EndIf	
EndIf

Return

//-------------------------------------------------------------------
Static Function DelInfTab(cAlias,cChave,lExcluCon)
Local lContinua := .T.

Default lExcluCon := .F.

If lExcluCon
	(cAlias)->( DbSetFilter( {|| (cAlias)->&((cAlias+'_CONSOL')) == "1" }, cAlias+'->'+cAlias+'_CONSOL == "1"' ) )
	(cAlias)->(DbGoTop())
EndIf

While lContinua

	If (cAlias)->(MSSEEK(xFilial(cAlias)+cChave))
		RecLock(cAlias,.F.)
		dbDelete()		
		MsUnlock()
		FkCommit()	 
	Else
		lContinua	:=.F.
	EndIF

EndDo

If lExcluCon
	(cAlias)->(DbClearFilter())
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadCL8()
Método que irá agrupar valores dos créditos da tabela CL8 para que sejam feitos 
os devidos ajustes de redução ou acréscimo

@author Erick G. Dias
@since 05/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method LoadCL8() Class AJUSTEEFD

	Local cAliasCKZ	:= x001QRYCL8('2',Self:dDtIni,,Self:BuscaxFil('CKZ'),Self:cConsl)	

	DbSelectArea (cAliasCKZ)
	(cAliasCKZ)->(DbGoTop ())
	Do While !(cAliasCKZ)->(Eof ())
		
		aAdd(Self:aVlPISCOF, {})
		nPos := Len(Self:aVlPISCOF)
		aAdd (Self:aVlPISCOF[nPos], (cAliasCKZ)->CKZ_TRIB)
		aAdd (Self:aVlPISCOF[nPos], (cAliasCKZ)->CKZ_COD)
		aAdd (Self:aVlPISCOF[nPos], (cAliasCKZ)->CKZ_ID)
		aAdd (Self:aVlPISCOF[nPos], (cAliasCKZ)->CL8_TOTCRD)
		aAdd (Self:aVlPISCOF[nPos], (cAliasCKZ)->CKZ_REGIME)
		aAdd (Self:aVlPISCOF[nPos], '1') //Crédito		
		aAdd (Self:aVlPISCOF[nPos], (cAliasCKZ)->CL8_CST)
		aAdd (Self:aVlPISCOF[nPos], (cAliasCKZ)->CL8_CODBCC)
		aAdd (Self:aVlPISCOF[nPos], 0) //Alíquota do débito da CKS		
						
		(cAliasCKZ)->(DbSkip ())
	EndDo

	DbSelectArea (cAliasCKZ)
	(cAliasCKZ)->(DbCloseArea())

Return

Method LoadCKS(lBaseCalc) Class AJUSTEEFD
Local cAliasCKZ		:= ""
Local cOpcaoQry		:= ""
Default lBaseCalc	:= .F.

If lBaseCalc
	//Monta query para reduzir base de cálculo
	cOpcaoQry	:= "7"
Else
	//Monta query para reduzir valor da contribuição
	cOpcaoQry	:= "2"
EndIF

cAliasCKZ	:= x001QRYCKS(cOpcaoQry,Self:dDtIni,,Self:BuscaxFil('CKZ'),Self:cConsl)

DbSelectArea (cAliasCKZ)
(cAliasCKZ)->(DbGoTop ())
Do While !(cAliasCKZ)->(Eof ())

	aAdd(Self:aVlPISCOF, {})
	nPos := Len(Self:aVlPISCOF)
	aAdd (Self:aVlPISCOF[nPos], (cAliasCKZ)->CKZ_TRIB)
	aAdd (Self:aVlPISCOF[nPos], (cAliasCKZ)->CKZ_COD)
	aAdd (Self:aVlPISCOF[nPos], (cAliasCKZ)->CKZ_ID)
	aAdd (Self:aVlPISCOF[nPos], Iif(lBaseCalc,(cAliasCKZ)->CKS_BASE,(cAliasCKZ)->CKS_VLDISP))
	aAdd (Self:aVlPISCOF[nPos], (cAliasCKZ)->CKZ_REGIME)
	aAdd (Self:aVlPISCOF[nPos], '2') //Débito
	//As duas próximas posições do array estarão vazias, pois tratam de informações específicas de ajsute de crédito, e neste caso aqui estão sendo tratados os débitos
	aAdd (Self:aVlPISCOF[nPos], '') //CST de Crédito
	aAdd (Self:aVlPISCOF[nPos], '') //Código Base de Cálculo do Crédito
	aAdd (Self:aVlPISCOF[nPos], Iif(lBaseCalc,(cAliasCKZ)->CKZ_ALIQ,0)) //Alíquota do débito da CKS
			
	(cAliasCKZ)->(DbSkip ())
EndDo

DbSelectArea (cAliasCKZ)
(cAliasCKZ)->(DbCloseArea())
Return

//----------------------------------------------------

//DECLARAÇÃO DA CLASSE AJUSTEEFD 

//----------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} DIFPISCOF
Classe que irá processar os valores e controles de diferimento de débitos
do próprio período, período anteriores e de difeimento de crédit.

@author Erick G. Dias
@since 07/05/2014
@version 11.80

/*/
//-------------------------------------------------------------------

CLASS DIFPISCOF FROM EFDGEN

	Data cTributo	 	As string	 	//tributo processado 1-PIS 2-COFINS
	Data cTpDifer		As string 		//Tipo do diferimento 1-Débito próprio período 2 - débito período anterior 3-crédito
	Data cCodDebCrd	As string 		//Código da Contribuição/Crédito
	Data nAlq			As string 		//Alíquota da contribuição	
	Data aDebPISCOF	As Array
	Data aCrdPISCOF	As Array	
	Data aVlPISCOF		As Array
	Data nVlDif		As Integer	
	Data cChvEfd		As String
	Data cIndCre		As String

	METHOD SetTributo(Value)
	METHOD SetTpDif(Value)	
	METHOD SetCodigo(Value)
	METHOD SetAliq(Value)
	METHOD SetVlDif(Value)
	METHOD LoadDebito()
	Method LoadCredit()
	Method AtuCredito()
	METHOD Diferir()
	Method AtuDebito()
	METHOD New()

ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método Contrutor da Classe DIFPISCOF. Esta classe será responsável
por realizar os cálculos da aba de apuração e aba das informações
de recolhimento do tributo.

@author Erick G. Dias
@since 30/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------

METHOD New() Class DIFPISCOF

Self:dDtIni	 	:= CTod("  /  /    ")
Self:cTributo	 	:= ''
Self:cTpDifer		:= ''
Self:cCodDebCrd	:= ''
Self:nAlq			:= ''
Self:aVlPISCOF	:= {}
Self:nVlDif		:= 0
Self:cChvEfd		:= ''
Self:cIndCre 		:= '0'
Self:cConsl		:= '2'
Self:IniHash()
Return Self

Method SetTributo(cTrib) Class DIFPISCOF
	Self:cTributo		:= cTrib
Return 

Method SetTpDif(cTipo) Class DIFPISCOF
	Self:cTpDifer	:= cTipo	
Return 

Method SetCodigo(cCod) Class DIFPISCOF
	Self:cCodDebCrd		:=PADR(cCod,3)
Return 

Method SetAliq(nAliquota) Class DIFPISCOF
	Self:nAlq	:= nAliquota	
Return 

METHOD SetVlDif(nValor) Class DIFPISCOF
	Self:nVlDif	:= nValor
Return

Method LoadDebito() Class DIFPISCOF

Local cAliasCKZ	:= x001QRYCKS('3',Self:dDtIni,,Self:BuscaxFil('CKZ'),Self:cConsl)

DbSelectArea (cAliasCKZ)
(cAliasCKZ)->(DbGoTop ())
Do While !(cAliasCKZ)->(Eof ())

	aAdd(Self:aVlPISCOF	, {})
	nPos := Len(Self:aVlPISCOF	)
	aAdd (Self:aVlPISCOF	[nPos], (cAliasCKZ)->CKZ_TRIB)
	aAdd (Self:aVlPISCOF	[nPos], (cAliasCKZ)->CKZ_COD)
	aAdd (Self:aVlPISCOF	[nPos], (cAliasCKZ)->CKZ_ID)
	aAdd (Self:aVlPISCOF	[nPos], (cAliasCKZ)->CKZ_ALIQ)
	aAdd (Self:aVlPISCOF	[nPos], (cAliasCKZ)->CKS_VLDISP)
	aAdd (Self:aVlPISCOF	[nPos], '2') // Débito
	//As duas próximas posições do array estarão vazias, pois tratam de informações específicas de ajsute de crédito, e neste caso aqui estão sendo tratados os débitos
	aAdd (Self:aVlPISCOF    [nPos], '') //CST de Crédito
	aAdd (Self:aVlPISCOF    [nPos], '') //Código Base de Cálculo do Crédito
	aAdd (Self:aVlPISCOF    [nPos], 0) //Alíquota do débito da CKS	
			
	(cAliasCKZ)->(DbSkip ())
EndDo

DbSelectArea (cAliasCKZ)
(cAliasCKZ)->(DbCloseArea())


Return

Method LoadCredit() Class DIFPISCOF

Local cAliasCKZ	:= x001QRYCL8('3',Self:dDtIni,,Self:BuscaxFil('CKZ'),Self:cConsl)

DbSelectArea (cAliasCKZ)
(cAliasCKZ)->(DbGoTop ())
Do While !(cAliasCKZ)->(Eof ())

	aAdd(Self:aVlPISCOF, {})
	nPos := Len(Self:aVlPISCOF)
	aAdd (Self:aVlPISCOF[nPos], (cAliasCKZ)->CKZ_TRIB)
	aAdd (Self:aVlPISCOF[nPos], (cAliasCKZ)->CKZ_COD)
	aAdd (Self:aVlPISCOF[nPos], (cAliasCKZ)->CKZ_ID)
	aAdd (Self:aVlPISCOF[nPos], (cAliasCKZ)->CKZ_ALIQ)
	aAdd (Self:aVlPISCOF[nPos], (cAliasCKZ)->CL8_TOTCRD)
	aAdd (Self:aVlPISCOF[nPos], "1") //Crédito
	aAdd (Self:aVlPISCOF[nPos], '') 
	aAdd (Self:aVlPISCOF[nPos], '') 
	aAdd (Self:aVlPISCOF[nPos], 0) //Alíquota do débito da CKS	
			
	(cAliasCKZ)->(DbSkip ())
EndDo

DbSelectArea (cAliasCKZ)
(cAliasCKZ)->(DbCloseArea())


Return

Method Diferir() Class DIFPISCOF

Local nCont		:= 0
Local nPos		:= 0
/*//-------------------------------------------------------------------
aTemp
Posições:

1 - Tributo
2 - Código
3 - Chave EFD
4 - Aliquota
5 - Valor
*///-------------------------------------------------------------------

IF Self:cTpDifer == '3'
	nPos:=aScan(Self:aVlPISCOF,{|aX| aX[1]==Self:cTributo .AND. aX[2]== Self:cCodDebCrd})
ElseIF Self:cTpDifer $ '1/2'
	nPos:=aScan(Self:aVlPISCOF,{|aX| aX[1]==Self:cTributo .AND. aX[2]== Self:cCodDebCrd .AND. aX[4] == Self:nAlq})
EndIF 

IF nPos > 0	
	IF Self:cTpDifer $'1/3'		
		Self:aVlPISCOF[nPos][5]-= Self:nVlDif		
	ElseIF Self:cTpDifer == '2'
		Self:aVlPISCOF[nPos][5]+= Self:nVlDif	
	
	EndIF
	Self:cChvEfd:= Self:aVlPISCOF[nPos][3]
	IF Self:cTpDifer $ '1/2'
		Self:AtuDebito()
	ElseIF Self:cTpDifer == '3' 
		Self:AtuCredito()
	EndIF 
	
EndIF

Return

Method AtuDebito() Class DIFPISCOF

//-------------------------------------------------------------------
//Atualiza valores referente ao débito considerando o valor do ajuste
//-------------------------------------------------------------------
If CKS->(MSSEEK(Self:BuscaxFil('CKS')+dTos(Self:dDtIni)+Self:cChvEfd))
	RecLock('CKS',.F.)
	
	IF Self:cTpDifer == '1'
		CKS->CKS_DIF		+=  Self:nVlDif
	Elseif Self:cTpDifer == '2'
		CKS->CKS_DIFANT	+=  Self:nVlDif
	EndIF	

	CKS->CKS_VLDISP	:=	CKS_VLTRIB+CKS_AJAC-CKS_AJRD-CKS_DIF+CKS_DIFANT
	
	MsUnLock()
EndIF


Return

Method AtuCredito() Class DIFPISCOF

If CL8->(MSSEEK(Self:BuscaxFil('CL8')+dTos(Self:dDtIni)+Self:cChvEfd+Self:cIndCre))
	RecLock('CL8',.F.)		
	CL8->CL8_DIF		+=  Self:nVlDif
	CL8->CL8_TOTCRD	:=	CL8_VLCRED+CL8->CL8_AJAC- CL8->CL8_AJRD - CL8->CL8_DIF //Recalcula valor do valor disponível do crédito	
	MsUnLock()
EndIF

Return

//----------------------------------------------------

//DECLARAÇÃO DA CLASSE SALDODED 

//----------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} SALDODED
Classe que irá processar os valores e controles de diferimento de débitos
do próprio período, período anteriores e de difeimento de crédit.

@author Erick G. Dias
@since 07/05/2014
@version 11.80

/*/
//-------------------------------------------------------------------

CLASS SALDODED FROM EFDGEN

	Data dPerOri	 	As Date	
	Data cRegime	 	As string
	Data nValPis	 	As integer
	Data nValCof	 	As integer
	Data cOrigem	 	As string
	Data cNfOri		As string
	Data cNfDev		As string
	Data cConta     As string

	METHOD SetPerOri(Value)	
	METHOD SetRegime(Value)	
	METHOD SetValPis(Value)
	METHOD setValCof(Value)
	METHOD SetOrigem(Value)
	METHOD SetNfOri(Value)
	METHOD SetNfDev(Value)
	METHOD SetConta(Value)
	METHOD LimpaSaldo()
	METHOD LoadDedAnt()
	METHOD GrvSaldo()
	METHOD New()

ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método contrutor da classe SALDODED

@author Erick G. Dias
@since 07/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD New() Class SALDODED

Self:dDtIni	 	:= CTod("  /  /    ")	
Self:dPerOri	:= CTod("  /  /    ")
Self:cRegime	:= ' '
Self:nValPis	:= 0
Self:nValCof	:= 0
Self:cOrigem	:= ' '
Self:cNfOri		:= PADR('',TamSx3("FT_NFISCAL")[1])
Self:cNfDev		:= PADR('',TamSx3("FT_NFISCAL")[1])
Self:cConta     := Iif(('CF3')->(FieldPos("CF3_CONTA") > 0), CriaVar("CF3_CONTA"), ' ')
Self:cConsl		:= '2'
Self:IniHash()

dbSelectArea('CF3')
DbSetOrder(1)	

Return Self


//-------------------------------------------------------------------
/*/{Protheus.doc} SetPerOri()
Passa o período de origem do valor para o controle de saldo

@author Erick G. Dias
@since 07/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method SetPerOri(dData) Class SALDODED
	Self:dPerOri		:= dData
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetRegime()
Passa o regime da operação

@author Erick G. Dias
@since 07/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method SetRegime(cValor) Class SALDODED
	Self:cRegime		:= padr(cValor,1)
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} setValCof()
Irá pasar o valor do PIS que será incluído no saldo

@author Erick G. Dias
@since 07/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method SetValPis(nValor) Class SALDODED
	Self:nValPis	:=	nValor
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} setValCof()
Irá pasar o valor da COFINS que será incluído no saldo

@author Erick G. Dias
@since 07/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method setValCof(nValor) Class SALDODED
	Self:nValCof		:= nValor
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetOrigem()
Indica a origem da informação A-Origem CF5; C-origem Devolução de Compra;
D-Registro F700; E-Devolução de venda

@author Erick G. Dias
@since 07/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method SetOrigem(cValor) Class SALDODED
	Self:cOrigem	:=	PADR(cValor,1)
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} SetNfOri()
Método que irá passar número do documento original da devolução se houver

@author Erick G. Dias
@since 07/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method SetNfOri(cValor) Class SALDODED
	Self:cNfOri		:= PADR(cValor,TamSx3("FT_NFISCAL")[1])
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetNfDev()
Método que irá passar número do documento de devolução se houver

@author Erick G. Dias
@since 07/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method SetNfDev(cValor) Class SALDODED
	Self:cNfDev	:=	PADR(cValor,TamSx3("FT_NFISCAL")[1])
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} SetConta()
Método que irá passar número da conta contábil se houver

@author pereira.weslley
@since 27/05/2019
@version 17.1.23
/*/
//-------------------------------------------------------------------
Method SetConta(cConta) Class SALDODED
	Self:cConta	:=	cConta
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvSaldo()
Método que irá gravar o saldo de dedução na tabela CF3.
@author Erick G. Dias
@since 07/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method GrvSaldo() Class SALDODED

Local dUltDia 	:= LastDay (Self:dPerOri) + 1
Local cPeruti	:= cvaltochar(strzero(month(dUltDia ),2)) + cvaltochar(year(dUltDia ))
Local lConta := Iif(('CF3')->(FieldPos("CF3_CONTA")) > 0, .T., .F.)

If !CF3->(MsSeek(xFilial('CF3')+dTos(Self:dPerOri)+cPerUti+Self:cRegime+Self:cOrigem+Self:cNfOri+Self:cNfDev+Iif(lConta, Self:cConta, "")))
	RecLock('CF3',.T.)
	CF3->CF3_FILIAL	:=	xFilial('CF3')
	CF3->CF3_PERORI	:=	Self:dPerOri
	CF3->CF3_REGIME	:=	Self:cRegime
	CF3->CF3_PERUTI	:=	cPerUti
	CF3->CF3_VLRPIS 	:=  Self:nValPis
	CF3->CF3_VLRCOF 	:=	Self:nValCof	
	CF3->CF3_ORIGEM 	:=	Self:cOrigem
	CF3->CF3_NFORI 	:=	Self:cNfOri //PADR
	CF3->CF3_NFDEV 	:=	Self:cNfDev//PADR
	If lConta
		CF3->CF3_CONTA 	:=	Self:cConta
	EndIf
	MsUnLock()
	CF3->(FKCommit())
Else
	RecLock('CF3',.F.)
	CF3->CF3_VLRPIS 	+= Self:nValPis
	CF3->CF3_VLRCOF 	+= Self:nValCof	
	MsUnLock()
	CF3->(FKCommit())	
EndIf
	
Return


Method LimpaSaldo(cPer) Class SALDODED

DbSelectArea ('CF3')
CF3->(DbSetOrder (2))
CF3->(DbGoTop ())

If CF3->( MsSeek(xFilial('CF3')+cPer) )
	Do While CF3->(!Eof() .And. CF3->CF3_FILIAL==xFilial('CF3') .And. CF3->CF3_PERUTI==cPer )
		RecLock('CF3',.F.)
		CF3->(dbDelete())
		MsUnLock()
		CF3->(FKCommit())
		CF3->(DbSkip ())			
	EndDo
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadDedAnt()
Método que irá buscar as deduções de períodos anteriores para poder efetuar
os ajustes de redução nos registros M210/M610

@author Erick G. Dias
@since 14/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------

Method LoadDedAnt(cOrigem) Class SALDODED

Local cAliasCF3	:= 'CF3'
Local cSelect		:= ''
Local cWhere		:= ''
Local cPerAtu 	:=	cvaltochar(strzero(month(Self:dDtIni) ,2)) + cvaltochar(year(Self:dDtIni))
Local lConta 	:= Iif((cAliasCF3)->(FieldPos("CF3_CONTA")) > 0, .T., .F.)

cSelect	:=	"CF3.CF3_PERORI, 	CF3.CF3_REGIME, 	CF3.CF3_VLRPIS, 	CF3.CF3_VLRCOF, 	CF3.CF3_ORIGEM,"
cSelect	+=	"CF3.CF3_NFDEV, 	CF3.CF3_NFORI"

If lConta
	cSelect	+= ",      CF3.CF3_CONTA"
EndIf

cFrom	:=	RetSqlName("CF3")+" CF3 "

cWhere	:=	"CF3.CF3_FILIAL='"+xFilial("CF3")+"' AND "
cWhere	+=	"CF3.CF3_PERUTI='"+cPerAtu+"' AND "
cWhere	+=	"CF3.CF3_ORIGEM = ('" + cOrigem + " ') AND "

cSelect:= '%'+cSelect+'%'
cFrom:= '%'+cFrom+'%'
cWhere:= '%'+cWhere+'%'

cAliasCF3	:=	GetNextAlias()
BeginSql Alias cAliasCF3
	COLUMN CF3_PERORI AS DATE
	SELECT
	%Exp:cSelect%

	FROM
	%Exp:cFrom%	

	WHERE
	%Exp:cWhere%
	CF3.%NotDel%

EndSql

Return cAliasCF3

//-------------------------------------------------------------------
/*/{Protheus.doc} x001QRYCL8()
Função que irá montar e executar busca dos créditos, das tabelas CL8
e CKZ

@author Erick G. Dias
@since 08/05/2014
@version 11.80

/*/
//-------------------------------------------------------------------

Static Function x001QRYCL8(cOpcao,dData,cTributo,cFilCKZ,cConsl)

Local cAliasCKZ	:= 'CKZ'
Local cSlctCKZ	:= ''
Local cFiltro		:= ''
Local cGroupBy	:= ''

If cOpcao == '1' 

	cSlctCKZ:= '%CKZ.CKZ_TRIB,	CL8.CL8_CST,	CL8.CL8_CODBCC, CL9.CL9_PAUTA, CL8.CL8_CRDUTI, CL8.CL8_CRDFUT,'
	cSlctCKZ+='CL8.CL8_BSCALC,	CL8.CL8_VLCRED, CL8.CL8_AJAC, CL8.CL8_AJRD, CL8.CL8_DIF, CL8.CL8_TOTCRD%'
	
	cGroupBy:= '% GROUP BY CKZ.CKZ_TRIB, CL8.CL8_CST, CL8.CL8_CODBCC, CL9.CL9_PAUTA, CL8.CL8_CRDUTI, CL8.CL8_CRDFUT,'
	cGroupBy+= 'CL8.CL8_BSCALC, CL8.CL8_VLCRED, CL8.CL8_AJAC, CL8.CL8_AJRD, CL8.CL8_DIF, CL8.CL8_TOTCRD%'
ElseIF cOpcao == '2'
	cSlctCKZ:= '%CKZ.CKZ_TRIB, 	CKZ.CKZ_COD,	CL8.CL8_TOTCRD, CKZ.CKZ_ID,	CKZ.CKZ_REGIME,CL9.CL9_PAUTA, CL8.CL8_CST, CL8.CL8_CODBCC%'

	cGroupBy:= '% GROUP BY CKZ.CKZ_TRIB, CKZ.CKZ_COD ,CKZ.CKZ_ID,CKZ.CKZ_REGIME,CL9.CL9_PAUTA, CL8.CL8_TOTCRD, CL8.CL8_CST, CL8.CL8_CODBCC%'
ElseIF cOpcao == '3'
	cSlctCKZ:= '%CKZ.CKZ_TRIB, 	CKZ.CKZ_COD,	CL8.CL8_TOTCRD, CKZ.CKZ_ID,	CKZ.CKZ_ALIQ,CL9.CL9_PAUTA%'

	cGroupBy:= '% GROUP BY CKZ.CKZ_TRIB, CKZ.CKZ_COD ,CKZ.CKZ_ID, CKZ.CKZ_ALIQ,CL9.CL9_PAUTA, CL8.CL8_TOTCRD%'	

ElseIF cOpcao == '4'
	cSlctCKZ:= '%CKZ.CKZ_TRIB, 	CKZ.CKZ_COD,	CL8.CL8_TOTCRD, CKZ.CKZ_ID,	CKZ.CKZ_ALIQ, CL8.CL8_INDCRE, CL8.CL8_CODBCC, CL8.CL8_CST,CL9.CL9_PAUTA%'

	cGroupBy:= '%%'	


EndIF

cFiltro := "%"
cFiltro += "CKZ.CKZ_FILIAL= '"+ cFilCKZ+ "' AND "
cFiltro += "CKZ.CKZ_PER>= '" + %Exp:DToS (dData)% + "' AND "
cFiltro += "CKZ.CKZ_PER<= '" + %Exp:DToS (dData)% + "' AND "
cFiltro += "CKZ.CKZ_REGIME = '1' AND "
cFiltro += "CKZ.CKZ_CONSOL = '" +cConsl + "' AND "
IF cOpcao == '4'
	cFiltro += "CKZ.CKZ_TRIB = '" + %Exp:cTributo% + "' AND "
EndIF
cFiltro += "%"

cAliasCKZ	:=	GetNextAlias()
BeginSql Alias cAliasCKZ
    	
	SELECT
	%Exp:cSlctCKZ%

	FROM
	%Table:CKZ% CKZ
	INNER JOIN %Table:CL8% CL8 ON(CL8.CL8_FILIAL=%Exp:cFilCKZ%  AND CL8.CL8_PER=CKZ.CKZ_PER AND CL8.CL8_CHV=CKZ.CKZ_ID AND CL8.CL8_CONSOL=CKZ.CKZ_CONSOL AND CL8.%NotDel%)	
	INNER JOIN %Table:CL9% CL9 ON(CL9.CL9_FILIAL=%Exp:cFilCKZ%  AND CL8.CL8_CHV=CL9.CL9_CHV AND CL9.CL9_CST = CL8.CL8_CST AND CL9.CL9_CODBCC = CL8.CL8_CODBCC AND CL8.CL8_CONSOL=CL9.CL9_CONSOL AND CL9.%NotDel%)
	WHERE
	%Exp:cFiltro%
	CKZ.%NotDel%
        
	%Exp:cGroupBy%
EndSql

Return cAliasCKZ


//-------------------------------------------------------------------
/*/{Protheus.doc} x001QRYCKS()
Função que irá montar e executar busca dos débitos, das tabelas CKS
e CKZ

@author Erick G. Dias
@since 08/05/2014
@version 11.80

/*/
//-------------------------------------------------------------------

Static Function x001QRYCKS(cOpcao,dData,cRegime,cFilCKZ,cConsl)
Local cAliasCKZ	:= ''
Local cSlctCKZ	:= ''
Local cFiltro		:= ''
Local cGroupBy	:= ''
Default cRegime	:= ''

dbSelectArea('CKZ')
CKZ->(dbSetOrder(1))

dbSelectArea('CKS')
CKS->(dbSetOrder(1))

IF cOpcao $ '1/5'
	cSlctCKZ:= '%CKZ.CKZ_TRIB,'
	cSlctCKZ+='SUM(CKS.CKS_VLTRIB) AS CKS_VLTRIB, SUM(CKS.CKS_AJAC)   AS CKS_AJAC, SUM(CKS.CKS_AJRD)   AS CKS_AJRD,	SUM(CKS.CKS_BASE) AS CKS_BASE,'
	cSlctCKZ+='SUM(CKS.CKS_DIF) AS CKS_DIF, SUM(CKS.CKS_DIFANT) AS CKS_DIFANT,	SUM(CKS.CKS_VLDISP) AS CKS_VLDISP,	SUM(CKS.CKS_VLREC) AS CKS_VLREC'	
	
	IF CKS->(FieldPos("CKS_BCAJUS"))>0 
		cSlctCKZ+= ' , SUM(CKS.CKS_AJBCA) AS CKS_AJBCA, SUM(CKS.CKS_AJBCR) AS CKS_AJBCR  %'
	Else
		cSlctCKZ+= "%"
	EndIF

	cGroupBy:= '%GROUP BY CKZ.CKZ_TRIB%'
ElseIF cOpcao == '2'
	cSlctCKZ:= '%CKZ.CKZ_TRIB, 	CKZ.CKZ_COD,	SUM(CKS.CKS_VLDISP) AS CKS_VLDISP, CKZ.CKZ_ID, CKZ.CKZ_REGIME%'
	cGroupBy:= '%GROUP BY CKZ.CKZ_TRIB, CKZ.CKZ_COD ,CKZ.CKZ_ID,CKZ.CKZ_REGIME%'
ElseIF cOpcao == '3'
	cSlctCKZ:= '%CKZ.CKZ_TRIB, 	CKZ.CKZ_COD,	SUM(CKS.CKS_VLDISP) AS CKS_VLDISP, SUM(CKS.CKS_BASE) AS CKS_BASE, CKZ.CKZ_ID,	CKZ.CKZ_ALIQ%'
	cGroupBy:= '%GROUP BY CKZ.CKZ_TRIB, CKZ.CKZ_COD ,CKZ.CKZ_ID,CKZ.CKZ_ALIQ%'
ElseIF cOpcao =='4'
	If CKS->(FieldPos("CKS_BCAJUS"))>0
		cSlctCKZ:= '%CKZ.CKZ_TRIB, 	CKZ.CKZ_COD,	SUM(CKS.CKS_BASE) AS CKS_BASE, CKZ.CKZ_ALIQ, CKZ.CKZ_ID,SUM(CKS.CKS_BCAJUS) AS CKS_BCAJUS%'
		cGroupBy:= '%GROUP BY CKZ.CKZ_TRIB, CKZ.CKZ_COD ,CKZ.CKZ_ALIQ, CKZ.CKZ_ID%'
	Else
		cSlctCKZ:= '%CKZ.CKZ_TRIB, 	CKZ.CKZ_COD,	SUM(CKS.CKS_BASE) AS CKS_BASE, CKZ.CKZ_ALIQ, CKZ.CKZ_ID%'
		cGroupBy:= '%GROUP BY CKZ.CKZ_TRIB, CKZ.CKZ_COD ,CKZ.CKZ_ALIQ, CKZ.CKZ_ID%'
	EndIf
ElseIF cOpcao =='6'
	cSlctCKZ:= '%CKZ.CKZ_TRIB, 	CKZ.CKZ_COD, CKZ.CKZ_ALIQ,	CKS.CKS_PAUTA,CKZ.CKZ_REGIME%'
	cGroupBy:= '%GROUP BY CKZ.CKZ_TRIB, CKZ.CKZ_COD, CKZ.CKZ_ALIQ,	CKS.CKS_PAUTA,CKZ.CKZ_REGIME  %'
ElseIF cOpcao =='7'
	cSlctCKZ := '%CKZ.CKZ_TRIB, CKZ.CKZ_COD, CKZ.CKZ_ID, CKZ.CKZ_REGIME, SUM(CKS.CKS_BASE) AS CKS_BASE, CKZ.CKZ_ALIQ%'
	cGroupBy:= '%GROUP BY CKZ.CKZ_TRIB, CKZ.CKZ_COD ,CKZ.CKZ_ID,CKZ.CKZ_REGIME, CKZ.CKZ_ALIQ%'
EndIF

cFiltro := "%"
cFiltro += "CKZ.CKZ_FILIAL= '"+ cFilCKZ+ "' AND "
cFiltro += "CKZ.CKZ_PER>= '" + %Exp:DToS (dData)% + "' AND "
cFiltro += "CKZ.CKZ_PER<= '" + %Exp:DToS (dData)% + "' AND "
cFiltro += "CKZ.CKZ_CONSOL = '" +cConsl + "' AND "

IF cOpcao == '5'
	cFiltro += "CKZ.CKZ_COD = '99'  AND " //INclui aqui somente os valores de PIS folha de salário
Else
	cFiltro += "CKZ.CKZ_COD <> '99'  AND " //Exclui aqui os valores de PIS folha de salário
EndIF

If !Empty(cRegime)
	cFiltro += "CKZ.CKZ_REGIME = '" + cRegime + "' AND "
EndIF

IF cOpcao =='5'
	cFiltro += "CKZ.CKZ_COD = '99' AND "
EndIF

cFiltro += "%"


cAliasCKZ	:=	GetNextAlias()
BeginSql Alias cAliasCKZ
    	
	SELECT
	%Exp:cSlctCKZ%

	FROM
	%Table:CKZ% CKZ
	INNER JOIN %Table:CKS% CKS ON(CKS.CKS_FILIAL=%Exp:cFilCKZ%  AND CKS.CKS_PER=CKZ.CKZ_PER AND CKS.CKS_CHV=CKZ.CKZ_ID AND CKS.CKS_CONSOL=CKZ.CKZ_CONSOL   AND CKS.%NotDel%)
	WHERE
	%Exp:cFiltro%
	CKZ.%NotDel%
        
	%Exp:cGroupBy%
EndSql

Return cAliasCKZ


//-------------------------------------------------------------------
/*/{Protheus.doc} x001QRYCF4()
Função que irá montar e executar busca dos débitos, das tabelas CKS
e CKZ

@author Erick G. Dias
@since 08/05/2014
@version 11.80

@history Vogas Júnior, 23/07/2018, (DSERFIS1-5209) Informar FT_CONTA nos registros M225 e M625.
/*/
//-------------------------------------------------------------------

Static Function x001QRYCF4(dData,cCod, nAlq, cPauta,cTrib)

Local cAliasCF4		:= 'CF4'
Local cSlctCF4		:= ''
Local cFiltro		:= ''
Local lCF4FLORIG	:= CF4->(FieldPos("CF4_FLORIG"))>0
Local cCodIndDeng	:= XFUNCodSef({"I"},.t.)
Local cFrom			:= RetSqlName("CF4")+" CF4 INNER JOIN "+RetSqlName("SFT")+" SFT ON(SFT.FT_FILIAL='"+xFilial("SFT")+"' AND SFT.FT_TIPOMOV=CF4.CF4_TIPMOV  AND SFT.FT_SERIE=CF4.CF4_SERIE "

cFrom += " AND SFT.FT_NFISCAL=CF4.CF4_NOTA AND SFT.FT_CLIEFOR=CF4.CF4_CLIFOR AND SFT.FT_LOJA=CF4.CF4_LOJA AND SFT.FT_ITEM=CF4.CF4_ITEM AND SFT.D_E_L_E_T_=' ') "
cFrom += " INNER JOIN " + RetSqlName( "SF3" ) + " SF3 ON (SF3.F3_FILIAL = '" + xFilial( "SF3" ) + "' AND SF3.F3_ENTRADA = SFT.FT_ENTRADA AND SF3.F3_NFISCAL = SFT.FT_NFISCAL AND SF3.F3_CLIEFOR = SFT.FT_CLIEFOR AND SF3.F3_LOJA = SFT.FT_LOJA AND SF3.F3_IDENTFT = SFT.FT_IDENTF3 AND SF3.D_E_L_E_T_ = ' ')"

dbSelectArea('CF4')
CF4->(dbSetOrder(2))

cSlctCF4:= 'CF4.CF4_VALPIS,		CF4.CF4_ORIPIS,	CF4.CF4_CONPIS,	CF4.CF4_PATPIS,	CF4.CF4_ALIPIS,'
cSlctCF4+= 'CF4.CF4_VALCOF,		CF4.CF4_ORICOF,	CF4.CF4_CONCOF,	CF4.CF4_PATCOF,	CF4.CF4_ALICOF,'
cSlctCF4+= 'CF4.CF4_NOTA,		CF4.CF4_DATAE,	CF4.CF4_DTALT, 	CF4.CF4_CSTPIS,	 CF4.CF4_BASPIS, CF4.CF4_CSTCOF, CF4.CF4_BASCOF, SFT.FT_CONTA, SFT.FT_NFELETR '	
	
cFiltro += "CF4.CF4_FILIAL= '"+ xFilial("CF4")+ "' AND "
cFiltro += "CF4.CF4_DTALT = '" + %Exp:dData% + "' AND "
cFiltro += "CF4.CF4_TIPO = '' AND "

If lCF4FLORIG
	//Faz a ligação com filial de origem do documento cancelado ou devolvido
	cFiltro += "CF4.CF4_FLORIG= '"+ xFilial("SFT")+ "' AND "
EndIF

If cTrib == '1' // PIS

	cFiltro += "CF4.CF4_CONPIS= '" + %Exp:cCod% + "' AND "
	cFiltro += "CF4.CF4_VALPIS > 0  AND "

	IF cPauta == '1'
		cFiltro += "CF4.CF4_PATPIS= " + %Exp:alltrim(str(nAlq,12,2))% + " AND "	
	Else
		cFiltro += "CF4.CF4_ALIPIS= " + %Exp:alltrim(str(nAlq,6,2))% + " AND "	
	EndIF
Else	//COFINS
	cFiltro += "CF4.CF4_CONCOF= '" + %Exp:cCod% + "' AND "
	cFiltro += "CF4.CF4_VALCOF > 0  AND "	

	IF cPauta == '1'
		cFiltro += "CF4.CF4_PATCOF= " + %Exp:alltrim(str(nAlq,12,2))% + " AND "	
	Else
		cFiltro += "CF4.CF4_ALICOF= " + %Exp:alltrim(str(nAlq,6,2))% + " AND "	
	EndIF	
	
EndIF

cFiltro	+=	"CF4.D_E_L_E_T_=''"

cFiltro += " AND SF3.F3_CODRSEF NOT IN "+ cCodIndDeng

cSlctCF4	:= '%'+cSlctCF4+'%'
cFiltro 	:= '%'+cFiltro+'%'
cFrom		:= '%'+cFrom+'%'

cAliasCF4	:=	GetNextAlias()
BeginSql Alias cAliasCF4
	COLUMN CF4_DATAE AS DATE
	SELECT
	%Exp:cSlctCF4%

	FROM
	%Exp:cFrom% 
	WHERE
	%Exp:cFiltro%

EndSql

Return cAliasCF4

//----------------------------------------------------

//DECLARAÇÃO DA CLASSE SALDOCRED 

//----------------------------------------------------
//-------------------------------------------------------------------
/*/{Protheus.doc} SALDOCRED
Classe que será responsável por realizar controle e gravação do controle
de saldo de Créditro de PIS e COFINS.

@author Erick G. Dias
@since 08/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------

CLASS SALDOCRED FROM EFDGEN

	Data cTributo	 	As String
	Data cCodCred	 	As String	
	Data cCnpj		 	As string	
	Data cOrigCred	 	As string	
	Data cAno		 	As string
	Data cMes		 	As string
	Data nTotCred	 	As integer	
	Data nCredUti	 	As integer	
	Data nCredDisp	 	As integer
	Data nLexTem	 	As integer	
	Data nUtiAnt		As integer		
	Data nComp			As integer	
	Data nRessar		As integer	
	Data nCoAnte		As integer
	Data nReante		As integer
	Data cPer			As string
	Data cMV_BCCR		As String	//Código de Crédito que será utilizado para ressarcimento
	Data cMV_BCCC		As String	//Código de Crédito que será utilziado para compensação
	Data aSldCred		As Array	//Array com informações da tabela CCY/CCW
	Data cCodCredEx	As string	//Código do Crédito que não serão apropriados
	Data lMesAtu		As Boolean
	Data cPerLoad		As String
	Data cReserv	 	As string

		  
	METHOD SetPerLoad(value)
	METHOD SetPer(Value)
	METHOD SetTributo(Value)
	METHOD SetCodCred(Value)	
	METHOD SetCnpj(Value)	
	METHOD SetOrigCrd(Value)
	METHOD SetAno(Value)	
	METHOD SetMes(Value)	
	METHOD SetTotCred(Value)	
	METHOD SetCredUti(Value)	
	METHOD SetCrdDisp(Value)	
	METHOD SetLexTem(Value)
	METHOD SetUtiAnt(Value)	
	METHOD SetComp(Value)	
	METHOD SetRessar(Value)
	METHOD SetCoAnte(Value)	
	METHOD SetReante(Value)
	METHOD SetMesAtu(Value)
	METHOD SetReserv(Value)
	METHOD GetTotCred()	
	METHOD GetSaldoAt()	
	METHOD AcumSaldo(Value)
	METHOD LoadSaldo(Value)
	METHOD LoadExtemp(Value)
	METHOD LimpaSaldo(Value)	
	
	
	METHOD New()

ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método contrutor da classe SALDOCRED

@author Erick G. Dias
@since 08/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD New() Class SALDOCRED

Self:cTributo		:= ''
Self:cCodCred	 	:= ''
Self:dDtIni		:= CTOD("  /  /    ")
Self:cAno		 	:= Space(TamSx3("CCY_ANO")[1])
Self:cMes		 	:= Space(TamSx3("CCY_MES")[1])
Self:cCnpj		:= Space(TamSx3("CCY_CNPJ")[1])
Self:cOrigCred	:= Space(TamSx3("CCY_ORICRE")[1])
Self:cPer			:= ''
Self:nTotCred	 	:= 0	
Self:nCredUti	 	:= 0	
Self:nCredDisp	:= 0
Self:nLexTem	 	:= 0		
Self:nUtiAnt		:= 0
Self:nUtiAnt		:= 0		
Self:nComp		:= 0	
Self:nRessar		:= 0	
Self:nCoAnte		:= 0
Self:nReante		:= 0
Self:lMesAtu		:= .F.
Self:cCodCredEx	:= ''
Self:cMV_BCCR		:= GetNewPar('MV_CODTPCR',"201#202#203#204#208#301#302#303#304#307#308"	)
Self:cMV_BCCC		:= GetNewPar('MV_CODTPCC',"301#302#303#304#308")
Self:aSldCred		:={}
Self:cPerLoad		:= ''
Self:cConsl		:= '2'
Self:cReserv		:= ''
Self:IniHash()

Return Self


METHOD GetSaldoAt() Class SALDOCRED
Return Self:aSldCred	

Method SetPer(Value) Class SALDOCRED
	Self:cPer := Value
Return .T.

Method SetTributo(Value) Class SALDOCRED
	Self:cTributo := Value
Return .T.

METHOD GetTotCred() Class SALDOCRED

Return	Self:nTotCred

METHOD SetCodCred(Value)	Class SALDOCRED
	Self:cCodCred	 	:= Value
Return

METHOD SetCnpj(Value)	Class SALDOCRED	
	Self:cCnpj	:= Value
Return

METHOD SetOrigCrd(Value)	Class SALDOCRED
	Self:cOrigCred	:= Value
Return

METHOD SetAno(Value)		Class SALDOCRED
	Self:cAno	:= Value
Return

METHOD SetMes(Value)		Class SALDOCRED
	Self:cMes	 := Value
Return

METHOD SetTotCred(Value)	Class SALDOCRED		
	Self:nTotCred	:= Value
Return

METHOD SetCredUti(Value)	Class SALDOCRED	
	Self:nCredUti	:= Value
Return

METHOD SetCrdDisp(Value)	Class SALDOCRED	
	Self:nCredDisp	:= Value
Return

METHOD SetLexTem(Value)	Class SALDOCRED
	Self:nLexTem		:= Value
Return

METHOD SetUtiAnt(Value)	Class SALDOCRED	
	Self:nUtiAnt	:= Value
Return

METHOD SetComp(Value)	Class SALDOCRED	
	Self:nComp	:= value
Return

METHOD SetRessar(Value)	Class SALDOCRED
	Self:nRessar	:= Value
Return

METHOD SetCoAnte(Value)	Class SALDOCRED	
	Self:nCoAnte := Value
Return

METHOD SetReante(Value)	Class SALDOCRED
	Self:nReante := Value
Return

METHOD SetMesAtu(Value)	Class SALDOCRED
	Self:lMesAtu	:= Value
Return

METHOD SetReserv(Value)	Class SALDOCRED
	Self:cReserv	:= Value
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LimpaSaldo()
Método que irá limpar o saldo dos créditos no início do processamento

@author Erick G. Dias
@since 16/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD LimpaSaldo() Class SALDOCRED

Local cAlias		:= Iif(Self:cTributo == '1','CCY','CCW')

DbSelectArea (cAlias)
(cAlias)->(DbSetOrder (1))
(cAlias)->(DbGoTop ())

If (cAlias)->( MsSeek(xFilial(cAlias)+Self:cPer) )
	Do While (cAlias)->(!Eof()) .And. (cAlias)->( &(cAlias+'_FILIAL')==Self:BuscaxFil(cAlias) .And. &(cAlias+'_PERIOD')==Self:cPer )
		lDelet := .T.
  		IF (cAlias)->&(cAlias+'_ORICRE')=="02" .OR. (!Empty(AllTrim((cAlias)->&(cAlias+'_CONSOL'))) .AND. (cAlias)->&(cAlias+'_CONSOL') <>   Self:cConsl)
			lDelet := .F. //Não deletar, pois este código igula a 02 foi digitado pelo usuário//ou se o flag de consolidação for diferente do processado no momento também não vai excluir 
	  	EndIF
		IF lDelet
			RecLock(cAlias,.F.)
			(cAlias)->(dbDelete())
			MsUnLock()
			(cAlias)->(FKCommit())
		EndIF
		(cAlias)->(DbSkip())			
	EndDo
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadSaldo()
Método qiue irá fazer select dos créditos de PIS e COFINS das tabelas CCY e CCW
para carregar os valores do créditos já gravados anteriormente e popular objeto
com estes valores de créditos

@author Erick G. Dias
@since 16/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD LoadSaldo(lRessComp) Class SALDOCRED

Local cCampos		:= X001QryCCYW(Self:cTributo)
local cFiltro	    := '%'
Local cAlias 	:= Iif(Self:cTributo == '1' ,'CCY','CCW') 
Local cFrom		:=  '%'
Local nPos		:= 0
local cPrefixo	:= Iif(Self:cTributo == '1','CCY.CCY_','CCW.CCW_')
Local cRefer	:= ''
Local cPerAtu	:=  cvaltochar(strzero(month(Self:dDtIni  ) ,2)) + cvaltochar(year(Self:dDtIni  ))
Default lRessComp	:= .F.

cAlias	:=	GetNextAlias()

If Self:cTributo == '1'
	cFrom	   +=  RetSqlName('CCY')+' CCY %'
	cFiltro += cPrefixo+ "FILIAL = '"  +Self:BuscaxFil('CCY')+  "' AND "	
ElseIF Self:cTributo == '2'
	cFrom	   +=  RetSqlName('CCW')+' CCW %'
	cFiltro += cPrefixo+ "FILIAL = '"  +Self:BuscaxFil('CCW')+  "' AND "	
EndIF

cFiltro += cPrefixo+ "PERIOD = '" + %Exp:self:cPer% + "' AND "
cFiltro += "(" +  cPrefixo+"CRDISP > 0 OR " + cPrefixo + "LEXTEM > 0) AND "

If !Empty(Self:cCodCred)
	cFiltro += cPrefixo+"COD = '"  +Self:cCodCred+  "' AND "  		
EndIF

If Self:lMesAtu 	
	cFiltro += cPrefixo+'LEXTEM = 0 AND'
EndIf

If Self:cConsl == '1'
	cFiltro += cPrefixo+"CONSOL = '" + Self:cConsl + "'  AND "
ElseIF Self:cConsl == '2'
	cFiltro += " ( " + cPrefixo+"CONSOL = '" + Self:cConsl + "'  OR " + cPrefixo+"CONSOL = '' ) AND "	
EndIF
 
cFiltro +=	"D_E_L_E_T_=''"
cFiltro  += 'ORDER BY PERIOD, ANO, MES , COD%'

BeginSql Alias cAlias

	SELECT
		%Exp:cCampos%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cFiltro%		
EndSql

DbSelectArea (cAlias)
(cAlias)->(DbGoTop ())
Do While !(cAlias)->(Eof ())
    //Somente irá processar operações onde o código do crédito esteja configurado para
    //permitir o direito ao crédito 
    IF !(cAlias)->COD $ Self:cCodCredEx

		Self:nComp			:=  0
		Self:nRessar		:=  0
		Self:nCoAnte		:=  0
		Self:nReante		:=  0				
		IF lRessComp	
			cRefer	:= (cAlias)->MES + (cAlias)->ANO
	  		If CG4->(MsSeek(xFilial("CG4")+Iif(Self:cTributo == '1','0','1')+cPerAtu+cRefer+(cAlias)->COD ))
	    		If ( CG4->CG4_VALORR + CG4->CG4_VALORC ) <= (cAlias)->CRDISP
		    		If Alltrim((cAlias)->COD)$Self:cMV_BCCR
		    	   		Self:nRessar := CG4->CG4_VALORR
		    	   	EndIf
		    	   	If Alltrim((cAlias)->COD)$Self:cMV_BCCC
		    	   		Self:nComp	:= CG4->CG4_VALORC
		    	   	EndIf
		    	EndIf
	    	EndIf
			Self:nReante	:= (cAlias)->REANTE + (cAlias)->RESSA
			Self:nCoAnte	:= (cAlias)->COANTE + (cAlias)->COMP
	    EndIF

		Self:cOrigCred	:=	Iif(EmpTy((cAlias)->ORICRE),'01',(cAlias)->ORICRE)

		//------------------------------------------------------------------------------
		//FAZ A CARGA DOS VALORES DE CRÉDITOS PARA PODEREM SER UTILIZADOS PELA APURAÇÃO.
		//------------------------------------------------------------------------------		

		aAdd(Self:aSldCred, {})
		nPos := Len(Self:aSldCred)
		aAdd (Self:aSldCred[nPos],(cAlias)->COD	     )
		aAdd (Self:aSldCred[nPos],(cAlias)->CRDISP -(Self:nComp	+Self:nRessar	)   )
		aAdd (Self:aSldCred[nPos],Self:cOrigCred	 		 )
		aAdd (Self:aSldCred[nPos],(cAlias)->ANO		 )
		aAdd (Self:aSldCred[nPos],(cAlias)->MES		 )
		aAdd (Self:aSldCred[nPos],(cAlias)->PERIOD 	 )
		aAdd (Self:aSldCred[nPos],(cAlias)->TOTCRD	 )
		aAdd (Self:aSldCred[nPos],(cAlias)->CREDUT	 )
		aAdd (Self:aSldCred[nPos],(cAlias)->LEXTEM	 )
		aAdd (Self:aSldCred[nPos],(cAlias)->CNPJ	 	 )
		aAdd (Self:aSldCred[nPos],(cAlias)->UTIANT	 )
		aAdd (Self:aSldCred[nPos],Self:nComp	    	     )		
		aAdd (Self:aSldCred[nPos],Self:nRessar			 )
		aAdd (Self:aSldCred[nPos],Self:nCoAnte	 		 )
		aAdd (Self:aSldCred[nPos],Self:nReante	 		 )
		aAdd (Self:aSldCred[nPos],(cAlias)->CRDISP	 )											
		aAdd (Self:aSldCred[nPos],.F.					 )
		aAdd (Self:aSldCred[nPos],(cAlias)->RESERV		 )

	EndIF
	(cAlias)->(DbSkip ())

EndDo

DbSelectArea (cAlias)
(cAlias)->(DbCloseArea ())

Return

METHOD LoadExtemp() Class SALDOCRED

Local cAliasCF6	:= ''
Local cSlctCF6	:= ''
Local nPos 		:= 0 
Local cPerAtu		:= Strzero(Month(Self:dDtIni),2)+cvaltochar(Year(Self:dDtIni))
Local dDtAnt		:= firstday(Self:dDtIni) - 1
Local cAnoAnt		:= Year(dDtAnt)
Local cMesAnt		:= Month(dDtAnt)
Local nValCred	:= 0

//Os valores extemporâneos serão processados somente para período anterios a 31/07/2013 conform guia prático.
If Self:dDtIni <= cToD("31/07/2013") 

	cSlctCF6 :=	"%CF6.*%"
	   	
	cAliasCF6	:=	GetNextAlias()
	   	
	BeginSql Alias cAliasCF6
		SELECT			    
			%Exp:cSlctCF6%
		FROM 
			%Table:CF6% CF6
		WHERE
			CF6.CF6_FILIAL=%xFilial:CF6% AND
			CF6.CF6_DTOPER>=%Exp:DToS (firstday(Self:dDtIni))% AND
			CF6.CF6_DTOPER<=%Exp:DToS (lastday(Self:dDtIni))% AND
			CF6.%NotDel%	
	EndSql
	DbSelectArea (cAliasCF6)
	(cAliasCF6)->(DbGoTop ())
	ProcRegua ((cAliasCF6)->(RecCount ()))
	Do While !(cAliasCF6)->(Eof ())
	
		If Self:cTributo == '1' //pis
			nValCred	:= 	(cAliasCF6)->CF6_VALPIS
		ElseIf Self:cTributo == '2' //cofins
			nValCred	:= 	(cAliasCF6)->CF6_VALCOF		
		EndIF
	
		aAdd(Self:aSldCred, {})
		nPos := Len(Self:aSldCred)
		aAdd (Self:aSldCred[nPos],(cAliasCF6)->CF6_CODCRE)	//CODIGO CREDITO
		aAdd (Self:aSldCred[nPos],nValCred					 )	//CREDITO DISPONÍVEL
		aAdd (Self:aSldCred[nPos],(cAliasCF6)->CF6_ORICRE)	//ORIGEM DO CREDITO
		aAdd (Self:aSldCred[nPos],cvaltochar(cAnoAnt)	 ) //ANO DE ORIGEM DO CRÉDITO
		aAdd (Self:aSldCred[nPos],Strzero(cMesAnt,2)	 ) //MES DA ORIGEM DO CRÉDITO
		aAdd (Self:aSldCred[nPos],cPerAtu					 )	//PERÍODO ONDE FOI GRAVADA CCY CCW
		aAdd (Self:aSldCred[nPos],0	 						 )	//TOTAL DO CRÉDITO DAS ENTRADAS DO PERÍODO
		aAdd (Self:aSldCred[nPos],0	 						 )	//TOTAL DO CRÉDITO UTILIZADO
		aAdd (Self:aSldCred[nPos],nValCred					 )	//CRÉDITO EXTEMPORÂNEO
		aAdd (Self:aSldCred[nPos],space(14) 			     )	//CNPJ DO ESTABELECIMENTO
		aAdd (Self:aSldCred[nPos],0						     )	//CREDITO UTILIZADO PERÍODO ANTERIOR
		aAdd (Self:aSldCred[nPos],0	    	     	         )	//COMPENSAÇÃO DO CREDITO
		aAdd (Self:aSldCred[nPos],0			 			     )	//RESSARCIMENTO
		aAdd (Self:aSldCred[nPos],0	 				 	     )	//??
		aAdd (Self:aSldCred[nPos],0	 				 	     )	//??
		aAdd (Self:aSldCred[nPos],nValCred					 )	//CRÉDITO DISPONÍVEL PARA UTILIZAÇÃO
		aAdd (Self:aSldCred[nPos],.T.						 )	//INDICA SE É EXTEMPORÂNEO
		aAdd (Self:aSldCred[nPos],""						 )	//INDICA SE RESERVADO
	
		(cAliasCF6)->(DbSkip ())			
	EndDo
	
	DbSelectArea (cAliasCF6)
	(cAliasCF6)->(DbCloseArea ())
EndIF

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} X001QryCCYW()
Método que retorna quais campos deverão ser selecionados, das tabelas
CCY ou CCW conforme o parâmetro passado

@paran	cTrib - 1 para CCY ; 2 para CCW
@author Erick G. Dias
@since 16/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function X001QryCCYW(cTrib)

Local cCampos		:= '%'

If cTrib == '1' //PIS

	cCampos += 'CCY.CCY_UTIANT	AS UTIANT,		CCY.CCY_ANO		AS ANO	  ,		CCY.CCY_MES		AS MES,		CCY.CCY_CNPJ		AS CNPJ,'		
	cCampos += 'CCY.CCY_ORICRE	AS ORICRE,		CCY.CCY_PERIOD	AS PERIOD,		CCY.CCY_COD		AS COD, 		CCY.CCY_TOTCRD 	AS TOTCRD,'
	cCampos += 'CCY.CCY_CREDUT	AS CREDUT, 	CCY.CCY_CRDISP	AS CRDISP,		CCY.CCY_REANTE	AS REANTE, 	CCY.CCY_COANTE	AS COANTE,'
	cCampos += 'CCY.CCY_RESSA	AS RESSA,		CCY.CCY_COMP		AS COMP,	 	CCY.CCY_LEXTEM	AS LEXTEM,		CCY.CCY_CONSOL	AS CONSOL'
	If	CCY->(FieldPos('CCY_RESCRE')) > 0
		cCampos += ',CCY.CCY_RESCRE	AS RESERV'
	EndIf

ElseIF cTrib == '2'

	cCampos += 'CCW.CCW_UTIANT	AS UTIANT,		CCW.CCW_ANO		AS ANO	  ,		CCW.CCW_MES		AS MES,		CCW.CCW_CNPJ		AS CNPJ,'		
	cCampos += 'CCW.CCW_ORICRE	AS ORICRE,		CCW.CCW_PERIOD	AS PERIOD,		CCW.CCW_COD		AS COD, 		CCW.CCW_TOTCRD 	AS TOTCRD,'
	cCampos += 'CCW.CCW_CREDUT	AS CREDUT, 	CCW.CCW_CRDISP	AS CRDISP,		CCW.CCW_REANTE	AS REANTE, 	CCW.CCW_COANTE	AS COANTE,'
	cCampos += 'CCW.CCW_RESSA	AS RESSA,		CCW.CCW_COMP		AS COMP,	 	CCW.CCW_LEXTEM	AS LEXTEM,		CCW.CCW_CONSOL	AS CONSOL'
	If CCW->(FieldPos('CCW_RESCRE')) > 0
		cCampos += ',CCW.CCW_RESCRE	AS RESERV'
	EndIf
EndIF

cCampos += '%'

Return cCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} AcumSaldo()
Método que irá fazer a gravação do saldo de crédito para próximo período
incluíndo ou acumulando os valores passados para classe.

@author Erick G. Dias
@since 16/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD AcumSaldo() Class SALDOCRED

Local cAlias		:= Iif(Self:cTributo == '1','CCY','CCW')
Local  cChave   	:= xFilial(cAlias)+Self:cPer+Self:cAno+Self:cMes+Self:cOrigCred+Self:cCnpj+Self:cCodCred+Self:cConsl

dbSelectArea(cAlias)
(cAlias)->(DbSetOrder (5))

If (cAlias)->( !MsSeek(cChave) )
	RecLock(cAlias,.T.)
	(cAlias)->&(cAlias+'_FILIAL')		:=	Self:BuscaxFil(cAlias)
	(cAlias)->&(cAlias+'_PERIOD')		:=	Self:cPer
	(cAlias)->&(cAlias+'_COD')			:=	Self:cCodCred
	(cAlias)->&(cAlias+'_TOTCRD')		:=	Self:nTotCred
	(cAlias)->&(cAlias+'_CREDUT')		:=	Self:nCredUti
	(cAlias)->&(cAlias+'_CRDISP')		:=	Self:nCredDisp
	(cAlias)->&(cAlias+'_LEXTEM')		:=	Self:nLexTem
	(cAlias)->&(cAlias+'_CNPJ')			:=	Self:cCnpj
	(cAlias)->&(cAlias+'_ORICRE')		:=	Self:cOrigCred
	(cAlias)->&(cAlias+'_ANO')			:=	Self:cAno
	(cAlias)->&(cAlias+'_MES')			:=	Self:cMes
	(cAlias)->&(cAlias+'_UTIANT')		:=	Self:nUtiAnt
	(cAlias)->&(cAlias+'_COMP')			:=	Self:nComp
	(cAlias)->&(cAlias+'_RESSA')		:=	Self:nRessar
	(cAlias)->&(cAlias+'_COANTE')		:=	Self:nCoAnte
	(cAlias)->&(cAlias+'_REANTE')		:=	Self:nReante 	
	(cAlias)->&(cAlias+'_CONSOL')		:=	Self:cConsl
	If	(cAlias)->(Fieldpos(cAlias+'_RESCRE')) > 0
		(cAlias)->&(cAlias+'_RESCRE')		:=	Self:cReserv
	EndIf
	MsUnLock()
	(cAlias)->(FKCommit())
Else
	RecLock(cAlias,.F.)
	(cAlias)->&(cAlias+'_TOTCRD')	+=	Self:nTotCred
	(cAlias)->&(cAlias+'_CREDUT')	+=	Self:nCredUti
	(cAlias)->&(cAlias+'_CRDISP')	+=	Self:nCredDisp
	(cAlias)->&(cAlias+'_LEXTEM')	+=	Self:nLexTem
	(cAlias)->&(cAlias+'_UTIANT')	+=	Self:nUtiAnt
	(cAlias)->&(cAlias+'_COMP')		+=	Self:nComp
	(cAlias)->&(cAlias+'_RESSA')	+=	Self:nRessar
	(cAlias)->&(cAlias+'_COANTE')	+=	Self:nCoAnte
	(cAlias)->&(cAlias+'_REANTE')	+=	Self:nReante		
	MsUnLock()
	(cAlias)->(FKCommit())
EndIf

Return

//----------------------------------------------------

//DECLARAÇÃO DA CLASSE OUTDEDUCAO 

//----------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} DEDUCAOPC
Classe que irá processar valores de outras deduções de PIS e COFINS

@author Erick G. Dias
@since 14/05/2014
@version 11.80

/*/
//-------------------------------------------------------------------

CLASS DEDUCAOPC FROM EFDGEN

Data nValDed		As integer
Data nValPisNC		As integer
Data nValPisC		As integer	
Data nValCofNC		As integer
Data nValCofC		As integer
Data cTributo		As string
Data cRegime		As string	
Data cTpDeducao		As String	//Tipo de dedução 1 - Outras Deduções;2-Retenção na fonteõ

Data cNatRet		As String
Data cPerLoad		As String
Data cPerGrava		As String	
Data nTorRet		As integer
Data nVlDisp	  	As integer
Data cTpReg			As string
Data nApuPer  		As integer
Data cMesAno 		As string
Data cProcAnt		As string
Data aSldRet		As array

Data nRessarc  		As integer
Data nComp  		As integer
Data cResret		As string
Data cConta			As string

METHOD SetMesAno(Value)
METHOD SetValDed(Value)	
METHOD SetTributo(Value)
METHOD SetTpDed(Value)	
METHOD SetRegime(Value)
METHOD SetNatRet(Value)
METHOD SetPergrva(Value)	
METHOD SetTotRet(Value)
METHOD SetVlDisp(Value)
METHOD SetTpReg(Value)			
METHOD SetApurPer(Value)
METHOD SetProcAnt(Value)

METHOD SetRessar(Value)
METHOD SetCompen(Value)
METHOD SetBloque(Value)
METHOD SetConta(Value)

METHOD AcumRet()
METHOD	 LimpaSaldo()
METHOD GetSldRet() 

METHOD LoadSaldo()		
METHOD Deduz()
METHOD DeduzOut()
METHOD DeduzRet()	
METHOD Atualiza()	

METHOD New()

ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método contrutor da classe DEDUCAOPC

@author Erick G. Dias
@since 07/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD New() Class DEDUCAOPC

Self:dDtIni	 		:= CTod("  /  /    ")
Self:nValDed	 		:= 0
Self:nValPisNC		:= 0
Self:nValPisC			:= 0	
Self:nValCofNC		:= 0
Self:nValCofC			:= 0
Self:cTributo	 		:= ''
Self:cRegime			:= ''
Self:cTpDeducao		:= ''
Self:cNatRet		:= ''
Self:cMesAno 		:= ''
Self:cTpReg		:= ''
Self:nTorRet		:= 0
Self:nVlDisp	  	:= 0
Self:nApuPer  	:= 0
Self:aSldRet		:= {}
Self:cPerLoad		:= ''
Self:cPerGrava	:= ''
Self:cProcAnt		:= '2' // período atual
Self:cConsl		:= '2'

Self:nRessarc	:= 0
Self:nComp  	:= 0
Self:cResret		:= '2'

Self:IniHash()

Return Self



METHOD SetProcAnt(Value) Class DEDUCAOPC
	Self:cProcAnt	:= Value
Return

METHOD GetSldRet() Class DEDUCAOPC
Return	 Self:aSldRet

METHOD SetNatRet(Value)	Class DEDUCAOPC
	Self:cNatRet := Value
Return

METHOD SetPergrva(Value) Class DEDUCAOPC
		Self:cPerGrava := Value
Return

METHOD SetTotRet(Value) Class DEDUCAOPC
		Self:nTorRet := Value
Return

METHOD SetVlDisp(Value) Class DEDUCAOPC
		Self:nVlDisp := Value
Return

METHOD SetTpReg(Value) Class DEDUCAOPC
		Self:cTpReg := Value
Return

METHOD SetApurPer(Value) Class DEDUCAOPC
		Self:nApuPer := Value
Return

METHOD SetMesAno(Value) Class DEDUCAOPC
		Self:cMesAno := Value
Return

METHOD SetConta(cValue) Class DEDUCAOPC
	Self:cConta := cValue
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetTpDed()
Passa qual o tipo de dedução que será realizado

@author Erick G. Dias
@since 15/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD SetTpDed(Value) Class DEDUCAOPC
	Self:cTpDeducao:=Value
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetValDed()
Método que passa o valor da dedução a ser realizada

@author Erick G. Dias
@since 14/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD SetValDed(Value) Class DEDUCAOPC
	Self:nValDed	:=	Value
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} SetTributo()
Método que passa qual o tributo terá a dedução

@author Erick G. Dias
@since 14/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD SetTributo(Value) Class DEDUCAOPC
	Self:cTributo	:=	Value
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetRegime()
Método que passa qual o regime do tributo

@author Erick G. Dias
@since 14/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD SetRegime(Value) Class DEDUCAOPC
	Self:cRegime	:=	Value
Return


METHOD SetBloque(Value) Class DEDUCAOPC
	Self:cResret	:= Value
Return

METHOD SetRessar(Value) Class DEDUCAOPC
	Self:nRessarc	:= Value
Return

METHOD SetCompen(Value) Class DEDUCAOPC
	Self:nComp	:= Value
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Deduz()
Função que irá fazer o controle do valor possível de dedução, e chamar 
funcções que gravem o saldo e atualize as tabelas da apuração

@author Erick G. Dias
@since 14/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD Deduz(oApur,lSaldo, lPerAnt) Class DEDUCAOPC

Default lSaldo := .F.
Default lPerAnt := .F.

IF Self:cTpDeducao == '1'
	Self:DeduzOut(oApur)
ElseIf Self:cTpDeducao == '2'
	Self:DeduzRet(oApur, lSaldo, lPerAnt)
EndIF
 
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DeduzOut()
Realiza a dedução de Outras Deduções na apuração, e faz o controle de saldo de 
necessário

@author Erick G. Dias
@since 15/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------

METHOD DeduzOut(oApur) Class DEDUCAOPC

Local nValAux	:= 0
Local nValSld	:= 0

//Pega valor da contribuição conforme o regime
nValAux:=	oApur:GetVlRecol(Self:cRegime)

IF Self:nValDed <= nValAux
	//Deduz integral
	Self:Atualiza()	
Else
	//Guarda a diferença em nValSld que será gravada no saldo 
	nValSld := Self:nValDed - nValAux
	//O valor de dedução será o próprio valor da contribuição a pagar
	//Jova o valor máximo para dedução em Self:nValDed 
	Self:nValDed	:= nValAux
	//Realiza õutras deduções
	Self:Atualiza()
	//grava CF3 com nValSld	
	//Realiza a gravação do saldo de dedução.
	oSaldoDed	:= 	SALDODED():New()
	oSaldoDed:SetConsol(Self:cConsl)
	oSaldoDed:SetDtIni(Self:dDtIni)			
	oSaldoDed:SetPerOri(Self:dDtIni)			
	oSaldoDed:SetRegime(Self:cRegime)					
	oSaldoDed:SetValPis( Iif(Self:cTributo =='1',	nValSld,0  ))
	oSaldoDed:setValCof( Iif(Self:cTributo =='2',	nValSld,0 ))
	oSaldoDed:SetOrigem('D') 	
	oSaldoDed:SetConta(Self:cConta)			
	oSaldoDed:GrvSaldo()
	FreeObj(oSaldoDed)
	oSaldoDed:= nil
	
EndIF

//Atualiza o valor da contribuição a recolher
oApur:SetValApur(Self:nValDed,Self:cRegime)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DeduzRet()
Realiza a dedução refernte aos valores de retenção na fonte,
atualiza apuração e grava nas tabelas correspondetes.

@author Erick G. Dias
@since 15/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------

METHOD DeduzRet(oApur, lSaldo, lPerAnt) Class DEDUCAOPC

Local nValAux	:= 0
Local nValSld	:= 0
Local lBloqAtu	:= .T.

Default lSaldo 	:= .F.
Default lPerAnt := .F. //Defini se rotina foi invocada a partir de funcao referente a tratamento de retencoes com saldos de periodos anteriores

//Pega valor da contribuição conforme o regime
nValAux:=	oApur:GetVlRecol(Self:cRegime)

IF Self:nValDed <= nValAux
	If lSaldo
		If !lPerAnt //Quando for periodo anterior matenho o TotRet intacto(afim de demosntracao no arquivo magnetico), pois apenas controlamos o Valor Disponivel.
			Self:nTorRet	:= Self:nValDed
		Else
			If Self:cResret != "1"	
				Self:nVlDisp := 0 //Self:cResret == "2" (DesBloqueado), o valor disponivel ficara sempre zero na SFV|SFW pois sera consumida totalmente por ser (Self:nValDed <= nValAux) neste mes. 
			EndIf	
		EndIf			
		
		Self:AcumRet()

		If lPerAnt .And. Self:cResret == "1" //Quanto for periodo anterior e bloqueado para uso, o valor deduzido nao deve influenciar na gravacao da CKR- Atualiza().
			Self:nValDed := 0
		EndIf

	EndIf
	//Deduz integral
	Self:Atualiza()	
Else

	If !lPerAnt .Or. (Self:cResret $ " 2") //Quando desbloqueado atualizo CKR
		
		//Guarda a diferença em nValSld que será gravada no saldo 
		If !lPerAnt //Quando for periodo anterior matenho o TotRet intacto(afim de demosntracao no arquivo magnetico), pois apenas controlamos o Valor Disponivel.
			Self:nTorRet	:= Self:nValDed
		EndIf	

		nValSld := Self:nValDed - nValAux
		//O valor de dedução será o próprio valor da contribuição a pagar
		//Jova o valor máximo para dedução em Self:nValDed 
		Self:nValDed	:= nValAux
		//Realiza õutras deduções
		Self:Atualiza()
		//inclu valores de retenção no saldo
		Self:nApuPer	:= Self:cPerGrava
		Self:nVlDisp	:= nValSld
	Else	
		lBloqAtu     := .F. //Quando bloqueado, desconsidera o valor disponivel da SFV|SFW criada neste momento do valor da contribuição a recolher deste periodo
	EndIf

	Self:AcumRet()
	
EndIF

If lBloqAtu
	//Atualiza o valor da contribuição a recolher
	oApur:SetValApur(Self:nValDed,Self:cRegime)
EndIf

Return


METHOD AcumRet() Class DEDUCAOPC

Local cAlias	:= IIF(Self:cTributo == '1','SFV','SFW')
Local cCampo	:= IIF(Self:cTributo == '1','FV','FW')
Local lRessa	:= (cAlias)->( FieldPos( cCampo + "_RESSA" ) ) > 0
Local lComp		:= (cAlias)->( FieldPos( cCampo + "_COMP" ) ) > 0
Local lRESRET	:= (cAlias)->( FieldPos( cCampo + "_RESRET" ) ) > 0

dbSelectArea(cAlias)
(cAlias)->(DbSetOrder (2))
If !MsSeek(Self:BuscaxFil(cAlias)+Pad(Self:cNatRet,2)+Pad(Self:cRegime,1)+ Pad(Self:cPerGrava,6)+Pad(Self:cMesAno,6))
   	RecLock(cAlias,.T.)

	(cAlias)->&(cCampo+'_FILIAL')		:=	Self:BuscaxFil(cAlias)
	(cAlias)->&(cCampo+'_NATRET')		:=  Padr(Self:cNatRet,2)
	(cAlias)->&(cCampo+'_PER')			:=  Padr(Self:cPerGrava,6)
	(cAlias)->&(cCampo+'_TOTRET')		:=  Self:nTorRet
	(cAlias)->&(cCampo+'_VLDISP')		:=  Self:nVlDisp
	(cAlias)->&(cCampo+'_TPREG')		:=  Padr(Self:cRegime,1)
	(cAlias)->&(cCampo+'_MESANO')		:=  Padr(Self:cMesAno,6)
	(cAlias)->&(cCampo+'_CONSOL')		:=  Self:cConsl

	If lRESRET .And. lRessa .And. lComp
		(cAlias)->&(cCampo+'_RESSA')	:=  Self:nRessarc
		(cAlias)->&(cCampo+'_COMP')		:=  Self:nComp
		(cAlias)->&(cCampo+'_RESRET')	:=  Self:cResret
	EndIf	

	MsUnLock()

	(cAlias)->(FKCommit())
Else
	RecLock(cAlias,.F.)

	(cAlias)->&(cCampo+'_TOTRET')  += Self:nTorRet 
	(cAlias)->&(cCampo+'_VLDISP')  += Self:nVlDisp

	MsUnLock()
	(cAlias)->(FKCommit())	
EndIF

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} LimpaSaldo()
Método que irá limpar o saldo das retenções no início do processamento

@author Erick G. Dias
@since 16/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD LimpaSaldo(Value)  Class DEDUCAOPC

Local cAlias		:= Iif(Self:cTributo == '1','SFV','SFW')
Local cTab		:= Iif(Self:cTributo == '1','FV','FW')

DbSelectArea (cAlias)
(cAlias)->(DbSetOrder (3))
(cAlias)->(DbGoTop ())

If (cAlias)->( MsSeek(  Self:BuscaxFil(cAlias) +Self:cPerGrava) )
	Do While (cAlias)->(!Eof()) .And. (cAlias)->( &(cTab+'_FILIAL')==Self:BuscaxFil(cAlias) .And. (cAlias)->( &(cTab+'_PER'))==Self:cPerGrava)
		IF (cAlias)->( &(cTab+'_CONSOL')) ==  Self:cConsl
			RecLock(cAlias,.F.)
			(cAlias)->(dbDelete())
			MsUnLock()
			(cAlias)->(FKCommit())
		EndIF
		(cAlias)->(DbSkip ())			
	EndDo
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} LoadSaldo()
Método qiue irá fazer select das retenções de PIS e COFINS das tabelas SFV e SFW
para carregar os valores das retenções já gravados anteriormente e popular objeto
com estes valores de créditos

@author Erick G. Dias
@since 16/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD LoadSaldo() Class DEDUCAOPC

Local cCampos		:= ''
Local cFiltro		:= ''
Local cTabela		:= ''
local cAlias		:= ''
local cTab			:= Iif(Self:cTributo	== '1','SFV','SFW')
Local lFV_RESSA		:=	SFV->( FieldPos( "FV_RESSA"  ) ) > 0
Local lFV_COMP		:=	SFV->( FieldPos( "FV_COMP"   ) ) > 0
Local lFV_RESRET	:=	SFV->( FieldPos( "FV_RESRET" ) ) > 0
Local lFW_RESSA		:=	SFW->( FieldPos( "FW_RESSA"  ) ) > 0
Local lFW_COMP		:=	SFW->( FieldPos( "FW_COMP"   ) ) > 0
Local lFW_RESRET	:=	SFW->( FieldPos( "FW_RESRET" ) ) > 0
	

cAlias   :=  GetNextAlias()

If  Self:cTributo	== '1'
	cCampos	:= '%SFV.FV_FILIAL AS FILIAL,		SFV.FV_NATRET	AS NATRET,		SFV.FV_PER 	 AS PER,		SFV.FV_TOTRET AS TOTRET, Substring(SFV.FV_MESANO ,3,4) as ANO, '

	If lFV_RESSA .And. lFV_COMP .And. lFV_RESRET
		cCampos	+= 'SFV.FV_RESSA	AS RESSA,		SFV.FV_COMP		AS COMP,		SFV.FV_RESRET AS RESRET,'
	EndIf

	cCampos	+= 'SFV.FV_VLDISP	AS VLDISP,		SFV.FV_TPREG	AS TPREG,		SFV.FV_APURPER AS APUPER,	SFV.FV_MESANO	AS MESANO, SFV.FV_CONSOL		AS CONSOL%'
	
	cFiltro += "%SFV.FV_FILIAL = '" + Self:BuscaxFil(cTab) + "'  AND "
	cFiltro += "SFV.FV_PER =  '" +Self:cPerGrava+ "' AND SFV.FV_VLDISP > 0 AND "
	cFiltro += "SFV.FV_CONSOL = '" +Self:cConsl+ "' AND "
	
ElseIF Self:cTributo == '2'
	cCampos	:= '%SFW.FW_FILIAL AS FILIAL,		SFW.FW_NATRET	AS NATRET,		SFW.FW_PER 	 AS PER,		SFW.FW_TOTRET AS TOTRET, Substring(SFW.FW_MESANO ,3,4) as ANO, '

	If lFW_RESSA .And. lFW_COMP .And. lFW_RESRET
		cCampos	+= 'SFW.FW_RESSA	AS RESSA,		SFW.FW_COMP		AS COMP,		SFW.FW_RESRET AS RESRET,'
	EndIf

	cCampos	+= 'SFW.FW_VLDISP	AS VLDISP,		SFW.FW_TPREG	AS TPREG,		SFW.FW_APURPER AS APUPER,	SFW.FW_MESANO	AS MESANO, SFW.FW_CONSOL	 	AS CONSOL%'
	cFiltro += "%SFW.FW_FILIAL = '" + Self:BuscaxFil(cTab) + "'  AND "
	cFiltro += "SFW.FW_PER =  '" +Self:cPerGrava+ "' AND SFW.FW_VLDISP > 0 AND "
	cFiltro += "SFW.FW_CONSOL = '" +Self:cConsl+ "' AND "	
EndIF
 
cTabela := '% ' +RetSqlName(cTab)+ ' '+ cTab+ ' %'
cFiltro += "D_E_L_E_T_ = '' "
cFiltro += ' ORDER BY  PER, ANO, MESANO, NATRET, TOTRET, VLDISP , TPREG  %'

BeginSql Alias cAlias

	SELECT
		%Exp:cCampos%
	FROM
		%Exp:cTabela%
	WHERE
		%Exp:cFiltro%		
EndSql
   
DbSelectArea (cAlias)
(cAlias)->(DbGoTop ())
Do While !(cAlias)->(Eof ())
	
	aAdd(Self:aSldRet, {})
	nPos := Len(Self:aSldRet)
	aAdd (Self:aSldRet[nPos],(cAlias)->NATRET)
	aAdd (Self:aSldRet[nPos],(cAlias)->PER	 )
	aAdd (Self:aSldRet[nPos],(cAlias)->MESANO)
	aAdd (Self:aSldRet[nPos],(cAlias)->TPREG)
	aAdd (Self:aSldRet[nPos],(cAlias)->TOTRET)
	aAdd (Self:aSldRet[nPos],(cAlias)->VLDISP)
	aAdd (Self:aSldRet[nPos],(cAlias)->APUPER)		

	If lFV_RESSA .And. lFV_COMP .And. lFV_RESRET .And. lFW_RESSA .And. lFW_COMP .And. lFW_RESRET
		aAdd (Self:aSldRet[nPos], (cAlias)->RESSA)
		aAdd (Self:aSldRet[nPos], (cAlias)->COMP)
		aAdd (Self:aSldRet[nPos], (cAlias)->RESRET)
	Else
		aAdd (Self:aSldRet[nPos], 0)
		aAdd (Self:aSldRet[nPos], 0)
		aAdd (Self:aSldRet[nPos], "")	
	EndIf	

	(cAlias)->(DbSkip ())
EndDo

DbSelectArea (cAlias)
(cAlias)->(DbCloseArea ())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Atualiza()
Método que irá atualizar as tabelas da apuração com o valor da dedução
diversa

@author Erick G. Dias
@since 14/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD Atualiza() Class DEDUCAOPC

//-------------------------------------------------------------------
//Atualiza valores referente ao débito considerando o valor do ajuste
//-------------------------------------------------------------------
If CKR->(MSSEEK(Self:BuscaxFil('CKR')+dTos(Self:dDtIni)+Self:cConsl+Self:cTributo))
	RecLock('CKR',.F.)
	
	If Self:cRegime  == '1'		
		//Não Cumulativo
		IF Self:cTpDeducao == '1' //Outras Deduções
			CKR_OUTDNC	+= Self:nValDed
		ElseIF Self:cTpDeducao == '2' //Retenção na fonte
			CKR_RTANTN	+= Iif(Self:cProcAnt	== '1',Self:nValDed,0)			
			CKR_RTATUN	+= Iif(Self:cProcAnt	== '2',Self:nValDed,0)		
		EndIF		
		CKR_NCREC := CKR_CONNC  - CKR_CRDANT - CKR_CRDATU - CKR_RTANTN - CKR_RTATUN - CKR_OUTDNC				
	ElseIF Self:cRegime  == '2'
		//Cumulativo
		IF Self:cTpDeducao == '1' //Outras Deduções
			CKR_OUTDC += Self:nValDed
		ElseIF Self:cTpDeducao == '2' //Retenção na fonte
			CKR_RTANTC	+= Iif(Self:cProcAnt	== '1',Self:nValDed,0)			
			CKR_RTATUC	+= Iif(Self:cProcAnt	== '2',Self:nValDed,0)		
			
		EndIF
		CKR_CREC := CKR_CONC - CKR_RTANTC - CKR_RTATUC - CKR_OUTDC			
	EndIF
	
	MsUnLock()
EndIF

Return

//----------------------------------------------------

//DECLARAÇÃO DA CLASSE CPRBEFD

//----------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} CPRBEFD
Classe responsável pela gravação e processamento dos valores da 
CPRB na EFD Contribuições.

@author Erick G. Dias
@since 22/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------

CLASS CPRBEFD FROM EFDGEN


//CKV
Data cCodReceita		As string		//C[odigo da Receita
Data nTotalApur			As integer		//Valor total apurado da CPRB
Data nTotAjCre			As integer		//Valor total de ajuste de acr[escimo da CPRB
Data nTotAjRed			As integer		//Valor total de ajuste de redu;'ao da CPRB
Data nValRecolh			As integer		//Valor da CPRB a Recolher
Data cFilApu			As string	
Data oCKV				
Data oCKX				
Data oF3Z				
//CKX
Data cCodAtiv			As string		//C[odigo da Atividade
Data nVlBrut			As integer		
Data nVlAtivi			As integer
Data nVlExclu			As integer
Data nBaseCalc			As integer
Data nAliquota			As integer
Data nVAlCPRB			As integer
Data cConta				As string
Data cInform			As string
Data lNTrib				As Boolean
//F3Z
Data cCNO				As string
//CKW
Data nValAju			As integer
Data cTpAjus			As string
Data cCodAju			As string
Data cNumero			As string
Data cDescr				As string
Data dDtRef	 			As Date		
//F2S
Data cTributo			As string
Data oF2S

Data aCodRec	As Array

METHOD SetCodRec()
METHOD GetTotCon()
METHOD GetAjusRed()
METHOD GetAjusAcr()
METHOD SetNTrib()
METHOD SetCNO()

METHOD SetTotCon()
METHOD SetAjusRed()
METHOD SetAjusAcr()


METHOD GetCPRBPag()
METHOD SetCPRBPag()
METHOD GetVlBrut()
METHOD GetVlAtiv()
METHOD GetVlExcl()
METHOD GetBase()
METHOD SetCodAtiv(cValue)
METHOD SetVlBrut(nValue)
METHOD SetVlAtiv(nValue)
METHOD SetVlExcl(nValue)
METHOD SetBase(nValue)
METHOD SetAliq(nValue)
METHOD SetVlCPRB(nValue)
METHOD SetConta(cValue)
METHOD SetInform(cValue)
METHOD SetValAju(nValue)
METHOD SetTpAju(nValue)
METHOD SetCodAjus(cValue)
METHOD SetNumero(cValue)
METHOD SetDescr(cValue)
METHOD SetDtRefer(dValue)
METHOD GetaCodRec()
METHOD DeduzBase(cCodAtiv,nAlq,nVlEst,nValcont,nVlExclu)
METHOD New()

METHOD LoadCPRB(cCodReceita)
METHOD LoadNTrib()
METHOD AgrupaCPRB()
METHOD DetalhCPRB()
METHOD GravaCPRB()
METHOD GravaAju() 	 	
METHOD AtualizaCPRB()
METHOD GrvCKW()
Method GravNTrib()
METHOD Clear()
METHOD ClrNtrib()
METHOD GetSldExcl()
METHOD ConsolCPRB(aFil)
METHOD SetDetExcl(cCodAju, nValue, cValue)
METHOD CNOxCPRB()
Method FechaAlias(Value)

ENDCLASS
///
//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método contrutor da classe CPRBEFD

@author Erick G. Dias
@since 07/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD New() Class CPRBEFD

Self:dDtIni	 		:= CTod("  /  /    ")
Self:dDtRef			:= CTod("  /  /    ")

Self:oCKV			:= TABELACKV():New()
Self:oCKX			:= TABELACKX():New()	
Self:oF3Z			:= TABELAF3Z():NEW() //Objeto instânciado da mesma forma que é utilizado o objeto da tabela CKX 	
If AliasIndic('F2S')
	Self:oF2S		:= TABELAF2S():New()
	Self:IniHash()		
EndIf
Self:Clear()

Return Self

METHOD Clear() Class CPRBEFD

Self:cCodReceita		:= ''
Self:cCodAtiv			:= ''
Self:cConta			:= ''
Self:cInform			:= ''
Self:cTpAjus			:= ''
Self:cCodAju			:= ''
Self:cNumero			:= ''
Self:cDescr			:= ''
Self:nTotalApur		:= 0
Self:nTotAjCre		:= 0
Self:nTotAjRed		:= 0
Self:nValRecolh		:= 0
Self:nVlBrut			:= 0		
Self:nVlAtivi			:= 0
Self:nVlExclu			:= 0
Self:nBaseCalc		:= 0
Self:nAliquota		:= 0
Self:nVAlCPRB			:= 0
Self:nValAju			:= 0
Self:cConsl			:= '2'
Self:lNTrib			:= .F.
Self:cCNO			:= ''

Self:aCodRec := {}

Return


METHOD SetCodRec(cValue) Class CPRBEFD
	Self:cCodReceita	:= PADR(cValue,6)
Return

METHOD GetTotCon() Class CPRBEFD
Return	Self:nTotalApur

METHOD GetAjusRed() Class CPRBEFD
Return	Self:nTotAjRed

METHOD GetAjusAcr() Class CPRBEFD
Return Self:nTotAjCre

METHOD SetNTrib(Value) Class CPRBEFD
	Self:lNTrib	:= Value
Return

METHOD SetTotCon(Value) Class CPRBEFD
	Self:nTotalApur	:= value
Return	

METHOD SetAjusRed(Value) Class CPRBEFD
	Self:nTotAjRed	:= Value
Return	

METHOD SetAjusAcr(Value) Class CPRBEFD
	Self:nTotAjCre	:= Value
Return 

METHOD SetCPRBPag(Value) Class CPRBEFD
	Self:nValRecolh := Value
Return 

METHOD GetCPRBPag() Class CPRBEFD
Return Self:nValRecolh

METHOD SetCodAtiv(cValue) Class CPRBEFD
	Self:cCodAtiv := cValue
Return

METHOD GetVlBrut() Class CPRBEFD
Return Self:nVlBrut

METHOD SetVlBrut(nValue) Class CPRBEFD
	Self:nVlBrut := nValue
Return

METHOD SetVlAtiv(nValue) Class CPRBEFD
	Self:nVlAtivi := nValue
Return

METHOD GetVlAtiv() Class CPRBEFD
Return Self:nVlAtivi

METHOD SetVlExcl(nValue) Class CPRBEFD
	Self:nVlExclu := nValue
Return

METHOD GetVlExcl() Class CPRBEFD	
Return Self:nVlExclu 

METHOD SetBase(nValue) Class CPRBEFD
	Self:nBaseCalc := nValue
Return

METHOD GetBase() Class CPRBEFD	
Return Self:nBaseCalc

METHOD SetAliq(nValue) Class CPRBEFD
	Self:nAliquota := nValue
Return

METHOD SetVlCPRB(nValue) Class CPRBEFD
	Self:nVAlCPRB := nValue
Return

METHOD SetCNO(cValue) Class CPRBEFD
	Self:cCNO := cValue
Return

METHOD SetConta(cValue) Class CPRBEFD
	Self:cConta := cValue
Return

METHOD SetInform(cValue) Class CPRBEFD
	Self:cInform := cValue
Return

METHOD SetValAju(nValue) Class CPRBEFD
	Self:nValAju := nValue
Return

METHOD SetTpAju(nValue) Class CPRBEFD
	Self:cTpAjus := nValue
Return

METHOD SetCodAjus(cValue) Class CPRBEFD
	Self:cCodAju := PADR(cValue,2)
Return

METHOD SetNumero(cValue) Class CPRBEFD
	Self:cNumero := cValue
Return

METHOD SetDescr(cValue) Class CPRBEFD
	Self:cDescr := cValue
Return

METHOD SetDtRefer(dValue) Class CPRBEFD
	Self:dDtRef := dValue
Return

Method getaCodRec() Class CPRBEFD
return Self:aCodRec

Method SetDetExcl(cValue, nValue, cValue2) Class CPRBEFD
	Self:cCodAju := cValue
	Self:nValAju := nValue
	Self:cDescr	 := cValue2	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvCKW()
Método que irá fazer persistência na tabela CKW. Considerando sempre
as informações já passadas pela classe.

@author Erick G. Dias
@since 30/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD GrvCKW() Class CPRBEFD

DbSelectArea('CKW')
CKW->(dbSetOrder(1))


//Realiza primeira a gravação do registro na tabela pai
If !CKW->(MSSEEK(Self:BuscaxFil('CKW')+dTos(Self:dDtIni)+Self:cTpAjus+Self:cCodReceita+Self:cCodAju+Padr(Self:cNumero,50)+dTos(Self:dDtRef)+Self:cConsl))

	RecLock('CKW',.T.)
	CKW->CKW_FILIAL	:=	Self:BuscaxFil('CKW')
	CKW->CKW_PER		:=	Self:dDtIni
	CKW->CKW_TPAJU	:=	Self:cTpAjus
	CKW->CKW_CODREC	:=	Self:cCodReceita
	CKW->CKW_VLAJU	:=	Self:nValAju
	CKW->CKW_CODAJU	:=	Self:cCodAju
	CKW->CKW_NUM		:=	Padr(Self:cNumero,50)
	CKW->CKW_DESCR	:=	Self:cDescr
	CKW->CKW_DTREF	:=	Self:dDtRef
	CKW->CKW_CONSOL	:=	Self:cConsl
	
	MsUnLock()
Else
	RecLock('CKW',.F.)
	CKW->CKW_VLAJU	+= Self:nValAju
	MsUnLock()
EndIF
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaAju()
Método que realiza gravação dos ajustes da CPRB, irá verificar se existe
valor para se ajustado, caso não exista o valor do ajuste será transportado
para próximo período.

@author Erick G. Dias
@since 30/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD GravaAju() Class CPRBEFD

Self:LoadCPRB(Self:cCodReceita)
If Self:cTpAjus== '1'
	Self:SetCPRBPag( Self:GetCPRBPag()+ Self:nValAju) // Acumula o valor total da contribuição
	Self:SetAjusAcr(Self:GetAjusAcr()+Self:nValAju) //Acumula o valor de acréscimo no registro consolidado

ElseIf Self:cTpAjus== '0' //Se menor que o valor da CPRB Apurada
	//Faz ajuste de redução de forma integral
	Self:SetCPRBPag( Self:GetCPRBPag() - Self:nValAju) // Subtrai o valor da contribuição a pagar
	Self:SetAjusRed( Self:GetAjusRed() + Self:nValAju) //acumula valor no ajuste de redução.
	
EndIF

//Grava os valores na tabela de ajustes.
Self:GrvCKW()

//Aqui atualiza os valores na tabela da CPRB Consolidada
Self:oCKV	:= TABELACKV():New()
Self:oCKV:OverRide(.T.)
Self:oCKV:SetConsol(Self:cConsl)
Self:oCKV:SetFilial(Self:aFilial)
Self:oCKV:SetParam('CKV_PER'		,Self:dDtIni		)
Self:oCKV:SetParam('CKV_COD'		,Self:cCodReceita	)
Self:oCKV:SetParam('CKV_TOTAP'		,Self:nTotalApur	)
Self:oCKV:SetParam('CKV_VLREC'		,Self:nValRecolh	)
Self:oCKV:SetParam('CKV_AJAC'		,Self:nTotAjCre	)
Self:oCKV:SetParam('CKV_AJRD'		,Self:nTotAjRed	)
Self:oCKV:SetParam('CKV_RECBRU'		,Self:nVlBrut	)
Self:oCKV:SetParam('CKV_RECATI'		,Self:nVlAtivi	)
Self:oCKV:SetParam('CKV_EXCLU'		,Self:nVlExclu	)
Self:oCKV:SetParam('CKV_BASE'		,Self:nBaseCalc	)
Self:oCKV:SetParam('CKV_FILAPU'		,Self:cFilApu 	) 

Self:oCKV:Insert()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GravNTrib()
Método que realiza gravação dos códigos não desenonerados quando valor da desoneração for 95% ou superior
Irá verificar se existe valor para se ajustado, caso não exista o valor do ajuste será transportado para próximo período.

@author Rafael.Soliveira
@since 08/09/2017
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD GravNTrib() Class CPRBEFD

//Aqui atualiza os valores na tabela da CPRB Consolidada
Self:oCKV:SetFilial(Self:aFilial)
Self:oCKV:SetParam('CKV_PER'		,Self:dDtRef		)
Self:oCKV:SetParam('CKV_COD'		,Self:cCodReceita	)
Self:oCKV:SetParam('CKV_TOTAP'		,Self:nVAlCPRB	)
Self:oCKV:SetParam('CKV_VLREC'		,Self:nVAlCPRB	)
Self:oCKV:SetParam('CKV_RECBRU'		,Self:nVlBrut	)
Self:oCKV:SetParam('CKV_RECATI'		,Self:nVlAtivi	)
Self:oCKV:SetParam('CKV_EXCLU'		,Self:nVlExclu	)
Self:oCKV:SetParam('CKV_BASE'		,Self:nBaseCalc	)
Self:oCKV:SetParam('CKV_FILAPU'		,Self:cFilApu 	) 
Self:oCKV:cConsl := '2'

Self:oCKV:Insert()

//------------------------------------------------------
//LIMPA VARIÁVEIS PARA PRÓXIMA OPERAÇÃO A SER PROCESSADA 
//------------------------------------------------------
Self:Clear()

Return



//Consolida valores CKV
METHOD AtualizaCPRB() Class CPRBEFD

Self:oCKV:Save()	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AgrupaCPRB()
Método que irá agrupar os valores da CPRB, consolidados e detalhados, para 
que sejam gravados posteriormente nas tabelas CKV e CKX respectivamente.

@author Erick G. Dias
@since 18/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD AgrupaCPRB() Class CPRBEFD

//---------------------------------------------------------------------------------------------------
//PROCESSA VALORES CONSLOIDADOS POR CÓDIGO DA RECEITA DE SERVIÇO OU DE DEMAIS OPERAÇÕES CONFORME DCTF
//---------------------------------------------------------------------------------------------------
//Quando codigo for não tributado soma somente valor da receita neste momento, somente sera agrupado se desoneração chegar a 95% ou superior
Self:oCKV:SetFilial(Self:aFilial)
Self:oCKV:SetConsol(Self:cConsl)
Self:oCKV:SetParam('CKV_PER'		,Self:dDtRef		)
Self:oCKV:SetParam('CKV_COD'		,Self:cCodReceita	)

If !Self:lNTrib
	Self:oCKV:SetParam('CKV_TOTAP'		,Self:nVAlCPRB	)
	Self:oCKV:SetParam('CKV_VLREC'		,Self:nVAlCPRB	)
	Self:oCKV:SetParam('CKV_RECBRU'		,Self:nVlBrut	)
	Self:oCKV:SetParam('CKV_RECATI'		,Self:nVlAtivi	)
	Self:oCKV:SetParam('CKV_EXCLU'		,Self:nVlExclu	)
	Self:oCKV:SetParam('CKV_BASE'		,Self:nBaseCalc	)	
Else  // Some somente valor bruto
	Self:oCKV:SetParam('CKV_TOTAP'		,0	)
	Self:oCKV:SetParam('CKV_VLREC'		,0	)
	Self:oCKV:SetParam('CKV_RECBRU'		,Self:nVlBrut	)
	Self:oCKV:SetParam('CKV_RECATI'		,0	)
	Self:oCKV:SetParam('CKV_EXCLU'		,0	)
	Self:oCKV:SetParam('CKV_BASE'		,0	)
Endif

If CKV->(FieldPos('CKV_FILAPU'))>0
	Self:oCKV:SetParam('CKV_FILAPU'		,Self:cFilApu		) 
Endif

Self:cConsl			:= '2'

Self:oCKV:Insert()

//-------------------------------------------------------------------------------------------
//PROCESSA VALORES DETALHADOS POR ALÍQUOTA E CÓDIGO, CÓDIGO DE ATIVODADE  E CÓDIGO DA RECEITA 
//-------------------------------------------------------------------------------------------
IF !EmpTy(Self:cCodAtiv)
	Self:oCKX:SetConsol(Self:cConsl)
	Self:oCKX:SetParam('CKX_PER'		,Self:dDtRef		)
	Self:oCKX:SetParam('CKX_CODATI'		,Self:cCodAtiv	)
	Self:oCKX:SetParam('CKX_CODREC'		,Self:cCodReceita	)
	Self:oCKX:SetParam('CKX_VLBRUT'		,Self:nVlBrut		)
	Self:oCKX:SetParam('CKX_VLATI'		,Self:nVlAtivi	)
	Self:oCKX:SetParam('CKX_EXCLU'		,Self:nVlExclu	)
	Self:oCKX:SetParam('CKX_BASE'		,Self:nBaseCalc	)
	Self:oCKX:SetParam('CKX_ALIQ'		,Self:nAliquota	)
	Self:oCKX:SetParam('CKX_VLCPRB'		,Self:nVAlCPRB	)
	Self:oCKX:SetParam('CKX_CONTA'		,Self:cConta		)
	Self:oCKX:SetParam('CKX_INFORM'		,Self:cInform		)
	Self:oCKX:SetParam('CKX_FILAPU'		,Self:cFilApu		)
	Self:oCKX:SetParam('CKX_NTRIB'		,Iif(Self:lNTrib,"S",''))
	Self:oCKX:Insert()

Endif

//------------------------------------------------------
//LIMPA VARIÁVEIS PARA PRÓXIMA OPERAÇÃO A SER PROCESSADA 
//------------------------------------------------------
Self:Clear()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DetalhCPRB() 
Método que irá detalhar os valores de CPRB. 

@author Vogas Júnior
@since 24/09/2018
@version 12.1.18
/*/
//-------------------------------------------------------------------
METHOD DetalhCPRB() Class CPRBEFD

// Gravação dos detalhes da exclusão de receita de CPRB
If AliasIndic('F2S')
	Self:oF2S:SetFilial(Self:aFilial)
	Self:oF2S:SetParam('F2S_TRIBUT'	,'2')
	Self:oF2S:SetParam('F2S_TPAJUS'	,'0')
	Self:oF2S:SetParam('F2S_CODAJU'	,Self:cCodaju)
	Self:oF2S:SetParam('F2S_VLRAJU'	,Self:nValaju)
	Self:oF2S:SetParam('F2S_DESCRI' ,Self:cDescr)
	Self:oF2S:SetParam('F2S_PER'	,Self:dDtRef)
	Self:oF2S:Insert()

	Self:Clear()
EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} GravaCPRB()
Método que irá gravar no banco os valores agrupados da CPRB

@author Erick G. Dias
@since 18/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD GravaCPRB() Class CPRBEFD

//--------------------------------------------------
//GRAVA NO BANCO AS INFORMAÇÕES DE CPRB CONSOLIDADA 
//--------------------------------------------------
Self:oCKV:Save()
Self:oCKV:= nil

//-----------------------------------------------
//GRAVA NO BANCO AS INFORMAÇÕES DE CPRB DETALHADA 
//-----------------------------------------------
Self:oCKX:Save()
Self:oCKX:= nil

//-----------------------------------------------
//GRAVA NO BANCO AS INFORMAÇÕES DE CPRBxCNO 
//-----------------------------------------------

If AliasIndic("F3Z")
	Self:oF3Z:Save()
	Self:oF3Z:= nil
EndIf

//Grava no Banco informações de detalhe da exclusão de receita CPRB
If AliasIndic('F2S')
	Self:oF2S:Save()
	Self:oF2S:= nil
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadCPRB()
Método que irá buscar os valores já gravados da CPRB e consolidar para 
retornar para tela de apuração

@author Erick G. Dias
@since 18/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD LoadCPRB(cCodReceita) Class CPRBEFD
Local cAliasCKV	:= ''
//Local lCPRBNF		:= GetNewPar('MV_CPRBNF',.F.)
Default cCodReceita	:= ''

cAliasCKV	:= Self:oCKV:Load(Self:dDtIni,cCodReceita)

Do While !(cAliasCKV)->(Eof ())
	Self:nTotalApur	+=	(cAliasCKV)->CKV_TOTAP			
	Self:nTotAjCre	+=	(cAliasCKV)->CKV_AJAC
	Self:nTotAjRed	+=	(cAliasCKV)->CKV_AJRD
	Self:nValRecolh	+=	(cAliasCKV)->CKV_VLREC	
	Self:nVlBrut	:=	(cAliasCKV)->CKV_RECBRU	
	Self:nVlAtivi	+=	(cAliasCKV)->CKV_RECATI
	Self:nVlExclu	+=	(cAliasCKV)->CKV_EXCLU
	Self:nBaseCalc	+=	(cAliasCKV)->CKV_BASE	
	
	aAdd(Self:aCodRec, { (cAliasCKV)->CKV_COD, (cAliasCKV)->CKV_TOTAP, (cAliasCKV)->CKV_AJAC, (cAliasCKV)->CKV_AJRD, (cAliasCKV)->CKV_VLREC, (cAliasCKV)->CKV_RECBRU, (cAliasCKV)->CKV_RECATI, (cAliasCKV)->CKV_EXCLU, (cAliasCKV)->CKV_BASE	 } )

	(cAliasCKV)->(DbSkip ())
EndDo

DbSelectArea (cAliasCKV)
(cAliasCKV)->(DbCloseArea())

Self:oCKV	:= Nil

Return

/*/{Protheus.doc} LoadNTrib()
Método que irá buscar os valores já gravados da CPRB na table CKX com Flag de não desenonerado para consolidar na CKV

@author Rafael.Soliveira
@since 08/09/2016
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD LoadNTrib() Class CPRBEFD
Local cAliasCKX	:= ''
Local lFilApu := CKX->(FieldPos('CKX_FILAPU'))>0

Self:oCKV:= TABELACKV():New()

cAliasCKX	:= Self:oCKX:LoadCKX(Self:dDtIni)

Do While !(cAliasCKX)->(Eof())
	Self:dDtRef		:= 	(cAliasCKX)->CKX_PER
	Self:cCodReceita	:=	(cAliasCKX)->CKX_CODREC			
	Self:nVlBrut	:=	0//(cAliasCKX)->CKX_VLBRUT //Ja foi somado no inicio do processamento
	Self:nVlExclu	:=	(cAliasCKX)->CKX_EXCLU
	Self:nVAlCPRB	:=	(cAliasCKX)->CKX_VLCPRB	
	Self:nBaseCalc	:=	(cAliasCKX)->CKX_BASE
	Self:nVlAtivi	:=	(cAliasCKX)->CKX_VLATI
	If lFilApu	
		Self:cFilApu	:=	(cAliasCKX)->CKX_FILAPU	
	Endif
	
	
	//Acumula na CKV
	Self:GravNTrib()
	
	(cAliasCKX)->(DbSkip ())	
EndDo

DbSelectArea (cAliasCKX)
(cAliasCKX)->(DbCloseArea())

//--------------------------------------------------
//GRAVA NO BANCO AS INFORMAÇÕES DE CPRB CONSOLIDADA 
//--------------------------------------------------
//Self:AtualizaCPRB()
Self:oCKV:Save()
Self:oCKV:= nil
Self:oCKX:= Nil

Return


/*/{Protheus.doc} ClrNtrib()
Método limpar registros com Flag de Códigos Genéricos de Outras Receitas que não serão usados quando da Desoneração Comparado a Receita Bruta ficar Abaixo de 95%

@author Rafael.Soliveira
@since 11/09/2016
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD ClrNtrib() Class CPRBEFD

DbSelectArea("CKX")
DbSetOrder(1)

//Indice 1//CKX_FILIAL+DTOS(CKX_PER)+CKX_CODATI+CKX_CODREC+STR(CKX_ALIQ)+CKX_SALDO
CKX->(MsSeek(xFilial("CKX")+DTOS(Self:dDtIni)))

Do While CKX->(!Eof())
	IF CKX->CKX_NTRIB ='S'
		RecLock('CKX',.F.)
			CKX->(dbDelete())
		MsUnLock()
		CKX->(FKCommit())
	Endif
	
	CKX->(DbSkip ())
EndDo


CKX->(DbCloseArea())

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} DeduzBase()
Método que realiza o estorno da base de cálculo da CPRB calculada pela
desoneração por CNAE. Esta dedução é necessária pois as receitas de 
consórcios não deverão fazer parte da base de cálculo da CPRB.

@author Erick G. Dias
@since 09/10/2014
@version 11.80
/*/
//-------------------------------------------------------------------

METHOD DeduzBase(cCodAtiv,nAlq,nVlEst,nValcont,nVlExclu) Class CPRBEFD

Local nVlrCPRB	 := 0

Default nValcont := nVlEst
Default nVlExclu := 0	

DbSelectArea ('CKX')
DbSelectArea ('CKV')
CKX->(dbSetOrder(1))
CKV->(dbSetOrder(1))

//Busca pelas informações da CPRB detalhada
IF CKX->(MsSeek(xFilial('CKX')+dTos(Self:dDtIni)+PADR(cCodAtiv,8)+PADR(Self:cCodReceita,6)+STR(nAlq,8,4)))

	nVlrCPRB := CKX->CKX_VLCPRB 
	RecLock("CKX",.F.)
	CKX->CKX_VLATI -= nValcont
	CKX->CKX_BASE  -= nVlEst
	CKX->CKX_EXCLU -= nVlExclu
	CKX->CKX_VLCPRB := ROUND(CKX->CKX_BASE  * CKX->CKX_ALIQ / 100,2)
	MsUnlock()
	nVlrCPRB -= CKX->CKX_VLCPRB //Preciso pegar a diferença do valor antes e depois da dedução para contemplar posteriormente o campo CKV_VLREC
	
	//Busca pelas informações da CPRB Consolidada
	IF CKV->(mSsEEK(  XfILIAL('CKV') +dTos(Self:dDtIni) +  PADR(Self:cCodReceita,6) + '2' )) 
		RecLock('CKV',.F.)
		CKV->CKV_RECATI -=nValcont
		CKV->CKV_BASE	-=nVlEst
		CKV->CKV_EXCLU	-=nVlExclu
		CKV->CKV_VLREC 	-= nVlrCPRB//Round(	CKV->CKV_BASE * CKX->CKX_ALIQ / 100,2)
		CKV->CKV_TOTAP 	:= CKV->CKV_VLREC
		MsUnlock()
	EndIF

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ConsolCPRB(aFil)
Método que irá Consolidar valor receita Bruta nas tabelas CKV e CKX
Este precesso se faz nescessario quando apurado CBPB por nota
MV_CPRBNF = .T.

@author Rafael.Soliviera
@since 21/09/2017
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD ConsolCPRB(aFil) Class CPRBEFD
Local cChaveCKX := xFilial('CKX')+dTos(Self:dDtIni)
Local cChaveCKV := xFilial('CKV')+dTos(Self:dDtIni)
Local nValBrut	:= 0
Local nVlBrutCKX:= 0
Local nR		:= 0
Local cAliasCKX	:= ""
Local cAliasCKV := ''
Local aAreaSM0 	:= SM0->(GetArea())

Default aFil	:= {}

cAliasCKV	:= Self:oCKV:Load(Self:dDtIni)

Do While !(cAliasCKV)->(Eof ())	
	nValBrut	+=	(cAliasCKV)->CKV_RECBRU	
	(cAliasCKV)->(DbSkip ())
EndDo

If nValBrut > 0
	//Atualiza campo de receita bruta para que todo registros fiquem com mesmo conteudo, da mesma forma tratada pelo faturamento
	CKV->(MsSeek(cChaveCKV)) 
	//CKV_FILIAL+DTOS(CKV_PER)+CKV_COD+CKV_CONSOL
	Do While CKV->(!Eof()) .And.  CKV->CKV_FILIAL+DTOS(CKV->CKV_PER) == cChaveCKV
		RecLock('CKV',.F.)
		CKV->CKV_RECBRU	:=	nValBrut
		MsUnlock()
		
		CKV->(DBSKIP())
	EndDo
EndIf

For nR:=1 to Len(aFil) //Aglutinar valor CKX_VLBRUT por Filial de todos os lançamentos
	
	SM0->(DbGoTop())
	SM0->(MsSeek(aFil[nR][1]+aFil[nR][2], .T.))
	cFilAnt := FWGETCODFILIAL	
	nVlBrutCKX:= 0

	cAliasCKX := Self:oCKX:LoadCKX(Self:dDtIni)
	cChaveCKX := xFilial('CKX')+dTos(Self:dDtIni)

	Do While !(cAliasCKX)->(Eof ())	
		nVlBrutCKX	+=	(cAliasCKX)->CKX_VLBRUT	
		(cAliasCKX)->(DbSkip ())
	EndDo
	
	(cAliasCKX)->(DbCloseArea())

	If nVlBrutCKX > 0
		CKX->(MsSeek(cChaveCKX))
		//CKX_FILIAL+DTOS(CKX_PER)+CKX_CODATI+CKX_CODREC+STR(CKX_ALIQ)+CKX_SALDO
		Do While CKX->(!Eof()) .And.  CKX->CKX_FILIAL+DTOS(CKX->CKX_PER) == cChaveCKX
			RecLock("CKX",.F.)
				CKX->CKX_VLBRUT := 	nVlBrutCKX
			MsUnlock()
			
			CKX->(DBSKIP())
		EndDo
	Endif

Next nR

RestArea (aAreaSM0)
cFilAnt := FWGETCODFILIAL

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} GetSldExcl()
Método que irá buscar valores de exclusão de receita de CPRB de período anterior

@author Erick G. Dias
@since 18/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD GetSldExcl() Class CPRBEFD

Local cAliasCKX	:= 'CKX'
Local cSlctCKX	:= ''
Local cFiltro		:= ''
Local cGroupBy	:= ''
Local dtAnter		:= FirstDay(Self:dDtRef) -1
Local aRetorno	:= {}
Local nPos		:= 0

dtAnter:= FirstDay(dtAnter)

dbSelectArea('CKX')
CKX->(dbSetOrder(1))

cSlctCKX:='%SUM(CKX.CKX_EXCLU) AS CKX_EXCLU,		CKX.CKX_CODATI%'
cGroupBy:= '% GROUP BY CKX.CKX_CODATI %'

cFiltro := "%"
cFiltro += "CKX.CKX_FILIAL= '"+ Self:BuscaxFil('CKX')+ "' AND "
cFiltro += "CKX.CKX_PER>= '" + %Exp:DToS (dtAnter)% + "' AND "
cFiltro += "CKX.CKX_PER<= '" + %Exp:DToS (dtAnter)% + "' AND "
cFiltro += "CKX.CKX_EXCLU > 0  AND "
cFiltro += "CKX.CKX_SALDO = '1' AND "
cFiltro += "%"

cAliasCKX	:=	GetNextAlias()
BeginSql Alias cAliasCKX
    	
	SELECT
	%Exp:cSlctCKX%

	FROM
	%Table:CKX% CKX
	WHERE
	%Exp:cFiltro%
	CKX.%NotDel%
        
	%Exp:cGroupBy%
EndSql

Do While !(cAliasCKX)->(EOF())

	aAdd(aRetorno, {})
	nPos := Len(aRetorno)
	aAdd (aRetorno[nPos], (cAliasCKX)->CKX_CODATI)
	aAdd (aRetorno[nPos], (cAliasCKX)->CKX_EXCLU)	
	
	(cAliasCKX)->(DBSKIP())
EndDo

Self:FechaAlias(cAliasCKX)

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} TITPAGAR()
Classe que irá efetuar a gravação dos títulos a pagar. Será responsável
por verificar se cliente/fornecedo, natureza estão devidamente
cadastrado, realizar a gravação e exclusão dos títulos.

@author Erick G. Dias
@since 15/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------
CLASS TITPAGAR FROM EFDGEN

Data  cPrefixo 		 As String 
Data cNumTitulo		 As String
Data cParcela			 As String
Data cTipo				 As String
Data cFornece			 As String
Data cLoja				 As String
Data nValor			 As Integer
Data dEmis1			 As Date
Data dEmissao			 As DAte
Data dVencto			 As DAte
Data dVenCrea			 As DAte
Data dVenOri			 As DAte
Data nSaldo			 As Integer
Data cNatureza			 As String
Data nVlCruz			 As integer
Data nMoeda			 As integer
Data cRateio			 As String
Data cFluxo			 As String
Data cCodRet			 As String
Data cOrigem			 As String
Data cDescrNat			 As String
Data cNomeFor			 As String
Data cCodLP			 As String
Data lContab			 As Boolean
Data lExibCtb			 As Boolean
Data lGrvTit			 As Boolean
Data lGrvCtb			 As Boolean

METHOD SetPrefixo()
METHOD SetNumTit()
METHOD SetParcela()
METHOD SetTipo()
METHOD SetFornece()
METHOD SetLoja()
METHOD SetNumFor()
METHOD SetValor()
METHOD SetEmis1()
METHOD SetEmissao()
METHOD SetVencto()
METHOD SetVenCrea()
METHOD setVenOri()
METHOD SetSaldo()
METHOD SetNatureza()
METHOD SetVlCruz()
METHOD SetMoeda()
METHOD SetRateio()
METHOD SetFluxo()
METHOD SetCodRet()
METHOD SetOrigem()
METHOD SetCodLp()
METHOD SetDescNat()
METHOD SetNomeFor()
METHOD SetContab()
METHOD SetExibCtb()
METHOD GetGrvTit()
METHOD GetContab()

METHOD Clear()
METHOD New()
METHOD GrvTitulo()
METHOD GrvGuia()
METHOD ChkFornec()
METHOD ChkNaturez()
METHOD DelTitulo()
METHOD ChkDelTit()
METHOD Contabiliz()

ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método Contrutor da classe. Irá iniciar as propriedades.

@author Erick G. Dias
@since 15/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD New() Class TITPAGAR

//Inicia as variáveis da classe
Self:Clear()

Return  Self


//-------------------------------------------------------------------
/*/{Protheus.doc} Clear()
Método para limpar as propiredades

@author Erick G. Dias
@since 15/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD Clear()Class TITPAGAR

Self:cPrefixo 			 := ''
Self:cNumTitulo		 := ''
Self:cParcela			 := ''
Self:cTipo				 := ''
Self:cFornece			 := ''
Self:cLoja				 := ''
Self:nValor			 := 0
Self:dEmis1			 := CTod("  /  /    ")
Self:dEmissao			 := CTod("  /  /    ")
Self:dVencto			 := CTod("  /  /    ")
Self:dVenCrea			 := CTod("  /  /    ")
Self:dVenOri			 := CTod("  /  /    ")
Self:nSaldo			 := 0
Self:cNatureza		 := ''
Self:nVlCruz			 := 0
Self:nMoeda			 := 0
Self:cRateio			 := ''
Self:cFluxo			 := ''
Self:cCodRet			 := ''
Self:cOrigem			 := ''
Self:cCodLP			 := ''
Self:cDescrNat		 := ''
Self:cNomeFor			 := ''
Self:lContab			 := .F.
Self:lExibCtb			 := .F.
Self:lGrvTit			 := .F.
Self:lGrvCtb			 := .F.
Self:cConsl			:= '2'
Self:IniHash()

Return

METHOD SetPrefixo(Value)Class TITPAGAR
	Self:cPrefixo	:= Value
Return

METHOD SetNumTit(Value) Class TITPAGAR
	Self:cNumTitulo	:= Value
Return

METHOD SetParcela(Value) Class TITPAGAR
	Self:cParcela	:= Value
Return

METHOD SetTipo(Value) Class TITPAGAR
	Self:cTipo	:= Value
Return


METHOD SetFornece(Value) Class TITPAGAR
	Self:cFornece	:= PADR(Value,TamSx3("E2_FORNECE")[1])
Return


METHOD SetLoja(Value) Class TITPAGAR
	Self:cLoja	:= PADR(Value,TamSx3("E2_LOJA")[1])
Return

METHOD SetValor(Value) Class TITPAGAR 
	Self:nValor	:= Value
Return


METHOD SetEmis1(Value) Class TITPAGAR
	Self:dEmis1	:= Value
Return

METHOD SetEmissao(Value) Class TITPAGAR
	Self:dEmissao	:= Value
Return

METHOD SetVencto(Value) Class TITPAGAR
	Self:dVencto	:= Value
Return

METHOD SetVenCrea(Value) Class TITPAGAR
	Self:dVenCrea	:= Value
Return

METHOD setVenOri(Value) Class TITPAGAR
	Self:dVenOri	:= Value
Return

METHOD SetSaldo(Value) Class TITPAGAR
	Self:nSaldo	:= Value
Return

METHOD SetNatureza(Value) Class TITPAGAR
	Self:cNatureza	:= Value
Return

METHOD SetVlCruz(Value) Class TITPAGAR
	Self:nVlCruz	:= Value
Return

METHOD SetMoeda(Value) Class TITPAGAR
	Self:nMoeda	:= Value
Return

METHOD SetRateio(Value) Class TITPAGAR
	Self:cRateio	:= Value
Return

METHOD SetFluxo(Value) Class TITPAGAR
	Self:cFluxo	:= Value
Return

METHOD SetCodRet(Value) Class TITPAGAR
	Self:cCodRet	:= Value
Return


METHOD SetOrigem(Value) Class TITPAGAR
	Self:cOrigem	:= Value
Return

METHOD SetCodLp(Value) Class TITPAGAR
	Self:cCodLP = Value
Return

METHOD SetContab(Value) Class TITPAGAR
	Self:lContab := Value
Return

METHOD SetExibCtb(Value) Class TITPAGAR
	Self:lExibCtb := Value
Return

METHOD GetGrvTit() Class TITPAGAR
Return	 Self:lGrvTit


METHOD GetContab() Class TITPAGAR
Return Self:lGrvCtb


//-------------------------------------------------------------------
/*/{Protheus.doc} SetDescNat()
Propriedade para descrição da natureza financeira

@author Erick G. Dias
@since 16/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD SetDescNat(Value) Class TITPAGAR
	Self:cDescrNat	:= Value
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetNomeFor()
Propriedade para nome do fornecedor

@author Erick G. Dias
@since 16/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD SetNomeFor(Value)  Class TITPAGAR
	Self:cNomeFor	:= Value	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GrvTitulo()
Método que irá realizar a gravação do título no contas a pagar, referente
ao valor do tributo que deverá ser recolhido. Todas as informações
devão ser passadas via propriedades da classe antes da gravação.

@author Erick G. Dias
@since 16/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD GrvTitulo() Class TITPAGAR

lGravou		:= .F.
lGravouCtb		:= .F.
//-----------------------------------------------
//Verifica antes se o fornecedor está cadastrado.
//-----------------------------------------------
Self:ChkFornec()

//--------------------------------------------------
//Verifica se a Natureza Financeira está cadastrada.
//--------------------------------------------------
Self:ChkNaturez()

Begin Transaction
	//-----------------------------------------------------------------
	//Caso o título já exista será excluído antes de gravar novo título
	//-----------------------------------------------------------------
	Self:DelTitulo()

	RecLock("SE2",.T.)
	SE2->E2_FILIAL    	:= xFilial("SE2")
	SE2->E2_PREFIXO   	:= Self:cPrefixo
	SE2->E2_NUM      		:= Self:cNumTitulo
	SE2->E2_PARCELA 		:= Self:cParcela
	SE2->E2_TIPO      		:= Self:cTipo
	SE2->E2_FORNECE   	:= Self:cFornece
	SE2->E2_LOJA    	  	:= Self:cLoja
	SE2->E2_NOMFOR    	:= Self:cNomeFor
	SE2->E2_VALOR    	    := Self:nValor
	SE2->E2_EMIS1    	 	:= Self:dEmis1
	SE2->E2_EMISSAO   	:= Self:dEmissao
	SE2->E2_VENCTO    	:= Self:dVencto
	SE2->E2_VENCREA   	:= Self:dVenCrea
	SE2->E2_VENCORI   	:= Self:dVenOri
	SE2->E2_SALDO   	  	:= Self:nSaldo
	SE2->E2_NATUREZ   	:= Self:cNatureza
	SE2->E2_VLCRUZ   		:= Self:nVlCruz
	SE2->E2_ORIGEM   	 	:= Self:cOrigem
	SE2->E2_MOEDA     		:= Self:nMoeda
	SE2->E2_RATEIO    	:= Self:cRateio
	SE2->E2_FLUXO     		:= Self:cFluxo
	SE2->E2_CODRET	  	:= Self:cCodRet

	If SE2->(Fieldpos("E2_FILORIG"))>0
		SE2->E2_FILORIG	:= cFilAnt
	EndIf

	//Se usuário pediu para contabilizar
	IF Self:lContab
		lGravouCtb:= Self:Contabiliz()
	EndIF

	If ExistBlock("CPCPOADC")
		ExecBlock("CPCPOADC",.F.,.F.,{"SE2"})
	Endif

	SE2->(MsUnlock())

End Transaction
lGravou := .T.

//Limpa as propriedades da classe.
Self:Clear()

Self:lGrvTit	 := lGravou
Self:lGrvCtb	 := lGravouCtb

Return lGravou


//-------------------------------------------------------------------
/*/{Protheus.doc} ChkFornec()
Método que verifica se o Fornecedor está cadastrado para gravação 
do título a pagar referente ao tributo. Se estiver cadastrado não faz nenhuma 
ação, se não estiver cadastrado então será incluído novo fornecedor

@author Erick G. Dias
@since 16/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD ChkFornec() Class TITPAGAR

dbSelectArea('SA2')
dbSetOrder(1)
If SA2->(!MsSeek(xFilial('SA2')+Self:cFornece+Self:cLoja))
	Reclock('SA2',.T.)
	SA2->A2_FILIAL	:=	xFilial('SA2')
	SA2->A2_COD 		:=	Self:cFornece
	SA2->A2_LOJA		:=	Self:cLoja
	SA2->A2_NOME		:=	Self:cNomeFor
	SA2->A2_NREDUZ	:=	Self:cNomeFor
	SA2->A2_MUN 		:=	"."
	SA2->A2_EST 		:=	"."
	SA2->A2_BAIRRO	:=	"."
	SA2->A2_END 		:=	"."
	MsUnlock()
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkNaturez()
Método que verifica se a Natureza Financeira está cadastrada para gravação 
do título a pagar referente ao tributo. Se estiver cadastrado não faz nenhuma 
ação, se não estiver cadastrado então será incluída nova natureza.

@author Erick G. Dias
@since 16/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------

METHOD ChkNaturez() Class TITPAGAR

dbSelectArea('SED')
dbSetOrder(1)
If ( !MsSeek(xFilial('SED')+Self:cNatureza) )
	RecLock('SED',.T.)
	SED->ED_FILIAL  := xFilial('SED')
	SED->ED_CODIGO  := Self:cNatureza
	SED->ED_CALCIRF := 'N'
	SED->ED_CALCISS := 'N'
	SED->ED_CALCINS := 'N'
	SED->ED_DESCRIC := Self:cDescrNat
	MsUnlock()                                 
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkDelTit()
Verifica se o título poderá ou não ser excluído. Retornar verdadeiro se
poder excluir, ou falso quando não pode, no caso de já existir baixa por exemplo.

@author Erick G. Dias
@since 26/09/2014
@version 11.80
/*/
//-------------------------------------------------------------------

METHOD ChkDelTit() Class TITPAGAR

Local lRet := .T.

DBSelectArea("SE2")
SE2->(dbSetOrder(1))
If SE2->(MsSeek(xFilial("SE2")+Self:cPrefixo+PadR(Self:cNumTitulo,TamSx3("E2_NUM")[1])+Self:cParcela+Self:cTipo+Self:cFornece+Self:cLoja))

	If !FaCanDelCP("SE2", 'FISA001',.F.)
		lRet := .F.
	EndIf

EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DelTitulo()
Método que irá excluir o título caso já exista. Irá considerar as informações
das propriedades para compor a chave e buscar o título no contas a pagar.

@author Erick G. Dias
@since 16/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------

METHOD DelTitulo() Class TITPAGAR

Begin Transaction
	DBSelectArea("SE2")
	SE2->(dbSetOrder(1))
	If SE2->(MsSeek(xFilial("SE2")+Self:cPrefixo+PadR(Self:cNumTitulo,TamSx3("E2_NUM")[1])+Self:cParcela+Self:cTipo+Self:cFornece+Self:cLoja))
	
		IF Self:lContab
			Self:Contabiliz()
		EndIF

		RecLock('SE2')
		FaAvalSE2(2,Self:cOrigem)
		FaAvalSE2(3,Self:cOrigem)
		SE2->(dbDelete())
		MsUnLock()
	EndIf
End Transaction

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Contabiliz()
Método que realizar contabilização dos valores.

@author Erick G. Dias
@since 16/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD Contabiliz() Class TITPAGAR
  
Local cLoteCtb	:= ''
Local cArqCtb		:= ''
Local nHdlPrv		:= 0
Local nTotalCtb	:= 0
local lCtbOnLine	:= .F.
Local cAuxCod		:= ''
Local aCT5		:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o numero do lote contabil.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX5")
dbSetOrder(1)
If MsSeek(xFilial()+"09FIS")
	cLoteCtb := AllTrim(X5Descri())
Else
	cLoteCtb := "FIS "
EndIf		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa um execblock.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If At(UPPER("EXEC"),X5Descri()) > 0
	cLoteCtb := &(X5Descri())
EndIf				
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o arquivo de contabilizacao. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nHdlPrv := HeadProva(cLoteCtb,Self:cOrigem,Subs(cUsuario,7,6),@cArqCtb)
IF nHdlPrv <= 0
	HELP(" ",1,"SEM_LANC")
	lCtbOnLine := .F.
EndIf

Begin Transaction

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Contabilizacao dos Lancamentos de PIS/COFINS.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	nTotalCtb += DetProva(nHdlPrv,Self:cCodLP,Self:cOrigem,cLoteCtb,,,,,@cAuxCod,@aCT5)

	RodaProva(nHdlPrv,nTotalCtb)
	If nTotalCtb > 0
		cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,Self:lExibCtb,.F.)
	EndIf
	
End Transaction

Return (nTotalCtb > 0)


//-------------------------------------------------------------------
/*/{Protheus.doc} TABELAEFD()
Esta classe auxilia no processamento de agrupar as apurações das filiais
na visão da Matriz. De forma gnérica, podemos efetuar gravação ou
edição de qualquer tabela com esta classe.

@author Erick G. Dias
@since 16/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------
CLASS TABELAEFD 

Data cChave	As string
Data cAlias	As String
Data iIndice	As Integer
Data cStatus	As String
Data cOverRide	As String

Method New()

Method setOverRide()
Method setIndice()
Method setAlias()
Method setChave()
Method Inclui()
Method SetCampo(cCampo,Value,lAcumula)
Method Finaliza()

ENDCLASS

METHOD New() Class TABELAEFD
Self:cOverRide	:= '1' //Sim
Self:cChave 	:= ''
Self:cAlias	:= ''
Self:iIndice	:= 1
Self:cStatus	:= ''

Return

METHOD Inclui() Class TABELAEFD
	dbSelectArea(Self:cAlias)
	(Self:cAlias)->(dbSetOrder(Self:iIndice))
	
	If (Self:cAlias)->(MSSEEK(Self:cChave))
		//Existe irá atualizar
		RecLock(Self:cAlias,.F.)
		Self:cStatus	:= '1' //Edição
	Else
		RecLock(Self:cAlias,.T.)
		Self:cStatus	:= '2' //Inclusão		
	EndIF
	
Return


Method Finaliza() Class TABELAEFD

	(Self:cAlias)->(MsUnLock())
	Self:cStatus	:= '2'
	
Return


Method setOverRide(Value) Class TABELAEFD
	Self:cOverRide := Value
Return

Method setIndice(Value) Class TABELAEFD
	Self:iIndice := Value
Return

Method setChave(Value) Class TABELAEFD
	Self:cChave := Value
Return

Method setAlias(Value) Class TABELAEFD
	Self:cAlias := Value
Return

Method SetCampo(cCampo,Value,lAcumula) Class TABELAEFD
	
	DEFAULT lAcumula := .F.

	IF lAcumula
		(Self:cAlias)->&cCampo	+=	Value	
	ElseIF Self:cStatus == '2'  //Se não for para acumular, somente irá atribuir o valor se for inclusão.
		(Self:cAlias)->&cCampo	:=	Value	
	EndIF

Return



//-------------------------------------------------------------------
/*/{Protheus.doc} TABELACL5
Classe que será responsável por realizar a gravação na tabela CL5

@author Erick G. Dias
@since 16/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
CLASS TABELACL5 FROM EFDGEN

	Data dPeriodo	As Date
	Data cIndice	As string
	Data cChvTab	As string
	Data aCl5		As Array
	//--------------------------------------------------------
	//Variáveis com os campos da tabela
	//--------------------------------------------------------
	Data dPer  	As Date	
	Data cID		As String
	Data cCSt		As String
	Data nAlqPis	As integer
	Data nAlqCof	As integer
	Data nValFat	As integer
	Data nDedG		As Integer
	Data nDedEsp	As Integer	
	Data nBasePis	As integer
	Data nValPis	As integer	
	Data nBaseCof	As integer
	Data nValCof	As integer
	Data cInfCom	As String
	Data cIndPro	As String	
	Data cNumPro	As String	
	Data cNumNf	As String	
	Data cSer		As String	
	Data cCliFor	As String	
	Data cLoja		As String

	Method New()			
	Method Load()
	Method Insert()
	Method Save()
	Method SetParam(cCampo,Value)
	Method ApurarI100(Value)
	
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método Construtor da Classe 

@author Erick G. Dias
@since 16/06/2014
@version 11.80

/*/
//-------------------------------------------------------------------
METHOD New() Class TABELACL5

Self:aCL5		:={}
Self:dPer		:=CTod("  /  /    ")
Self:nAlqPis	:=0
Self:nAlqCof	:=0
Self:nValFat	:=0
Self:nDedG		:=0
Self:nDedEsp	:=0	
Self:nBasePis	:=0
Self:nValPis	:=0	
Self:nBaseCof	:=0
Self:nValCof	:=0
Self:cIndice	:=''
Self:cChvTab	:=''
Self:cID		:=''
Self:cCSt		:=''
Self:cInfCom	:=''
Self:cIndPro	:=''	
Self:cNumPro	:=''	
Self:cNumNf	:=''	
Self:cSer		:=''	
Self:cCliFor	:=''	
Self:cLoja		:=''
Self:cConsl	:= '2'
Self:IniHash()

Return  Self

//-------------------------------------------------------------------
/*/{Protheus.doc} SetParam()
Método que irá alimentar os parâmetro com as informações que deverão ser gravadas
na tabela 

@author Erick G. Dias
@since 16/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method SetParam(cCampo,Value) Class TABELACL5

Do Case		
	Case cCampo == 'CL5_PER'
		Self:dPer		:= Value		
	Case cCampo == 'CL5_ID'
		Self:cID		:= Value		
	Case cCampo == 'CL5_CST'
		Self:cCSt	:= Value		
	Case cCampo == 'CL5_ALQPIS'
		Self:nAlqPis	:= Value
	Case cCampo == 'CL5_ALQCOF'
		Self:nAlqCof	:= Value		
	Case cCampo == 'CL5_VLFAT'
		Self:nValFat	:= Value
	Case cCampo == 'CL5_DEDG'
		Self:nDedG	:= Value
	Case cCampo == 'CL5_DEDESP'
		Self:nDedEsp	:= Value
	Case cCampo == 'CL5_BASPIS'
		Self:nBasePis	:= Value
	Case cCampo == 'CL5_VALPIS'
		Self:nValPis	:= Value
	Case cCampo == 'CL5_BASCOF'
		Self:nBaseCof	:= Value
	Case cCampo == 'CL5_VALCOF'
		Self:nValCof	:= Value
	Case cCampo == 'CL5_INFCOM'
		Self:cInfCom	:= Value
	Case cCampo == 'CL5_INDPRO'
		Self:cIndPro		:= Value
	Case cCampo == 'CL5_NUMPRO'
		Self:cNumPro	:= Value
	Case cCampo == 'CL5_NUMNF'
		Self:cNumNf	:= Value
	Case cCampo == 'CL5_SER'
		Self:cSer	:= Value
	Case cCampo == 'CL5_CLIFOR'
		Self:cCliFor	:= Value
	Case cCampo == 'CL5_LOJA'
		Self:cLoja		:= Value
EndCase

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Load()
Método que irá fazer query na tabela e retornar alias com resultado.
Irá considerar as informações do métodos passados.

@author Erick G. Dias
@since 16/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method Load() Class TABELACL5

local cAlias	:= GetNextAlias()
Local cCampos	:= ''
Local cFrom	:= ''
Local cFiltro	:= '' 

BeginSql Alias cAlias

	SELECT
		%Exp:cCampos%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cFiltro%		
EndSql

Return cAlias

//-------------------------------------------------------------------
/*/{Protheus.doc} Insert()
Método que irá fazer query na tabela e retornar alias com resultado.
Irá considerar as informações do métodos passados.

@author Erick G. Dias
@since 23/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method Insert() Class TABELACL5

Local nPos:=aScan(Self:aCL5,{|aX| aX[1]==Self:BuscaxFil('CL5').AND. aX[2] == Self:dPer .AND.  aX[3]==Self:cCSt .and.;
										aX[4]==Self:nAlqPis .and. aX[5]==Self:nAlqCof })

IF nPos == 0
	aAdd(Self:aCL5, {})
	nPos := Len(Self:aCL5)
	aAdd (Self:aCL5[nPos], Self:BuscaxFil('CL5')	)	//01
	aAdd (Self:aCL5[nPos], Self:dPer		)	//02	
	aAdd (Self:aCL5[nPos], Self:cCSt		)	//03
	aAdd (Self:aCL5[nPos], Self:nAlqPis	)	//04		
	aAdd (Self:aCL5[nPos], Self:nAlqCof	)	//05
	aAdd (Self:aCL5[nPos], Self:nValFat	)	//06
	aAdd (Self:aCL5[nPos], Self:nDedG		)	//07
	aAdd (Self:aCL5[nPos], Self:nDedEsp	)	//08
	aAdd (Self:aCL5[nPos], Self:nBasePis	)	//09
	aAdd (Self:aCL5[nPos], Self:nValPis	)	//10
	aAdd (Self:aCL5[nPos], Self:nBaseCof	)	//11
	aAdd (Self:aCL5[nPos], Self:nValCof	)	//12
	aAdd (Self:aCL5[nPos], Self:cNumPro	)	//13
	aAdd (Self:aCL5[nPos], Self:cIndPro	)	//14
Else
	Self:aCL5[nPos][6]	+= Self:nValFat
	Self:aCL5[nPos][7]	+= Self:nDedG
	Self:aCL5[nPos][8]	+= Self:nDedEsp
	Self:aCL5[nPos][9]	+= Self:nBasePis
	Self:aCL5[nPos][10]	+= Self:nValPis
	Self:aCL5[nPos][11]	+= Self:nBaseCof
	Self:aCL5[nPos][12]	+= Self:nValCof						
	
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Save()
Método que irá gravar na tabela todas as informações passadas pela classe

@author Erick G. Dias
@since 16/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method Save() Class TABELACL5
Local nPos	:= 0

dbSelectArea('CL5')
CL5->(dbSetOrder(1))
For nPos:= 1 to Len(Self:aCL5)

	If !CL5->(MSSEEK(Self:aCL5[nPos][1]+dTos(Self:aCL5[nPos][2])+Self:aCL5[nPos][3]+STR(Self:aCL5[nPos][4],8,4)+ STR(Self:aCL5[nPos][5],8,4)))
		RecLock('CL5',.T.)
		CL5->CL5_FILIAL	:=	Self:aCL5[nPos][1]
		CL5->CL5_PER		:=	Self:aCL5[nPos][2]
		CL5->CL5_CST		:=	Self:aCL5[nPos][3]
		CL5->CL5_ALQPIS	:=	Self:aCL5[nPos][4]
		CL5->CL5_ALQCOF	:=	Self:aCL5[nPos][5]
		CL5->CL5_VLFAT	:=	Self:aCL5[nPos][6]
		CL5->CL5_DEDG		:=	Self:aCL5[nPos][7]
		CL5->CL5_DEDESP	:=	Self:aCL5[nPos][8]
		CL5->CL5_BASPIS	:=	Self:aCL5[nPos][9]
		CL5->CL5_VALPIS	:=	Self:aCL5[nPos][10]
		CL5->CL5_BASCOF	:=	Self:aCL5[nPos][11]
		CL5->CL5_VALCOF	:=	Self:aCL5[nPos][12]
		CL5->CL5_NUMPRO	:=	Self:aCL5[nPos][13]
		CL5->CL5_INDPRO	:=	Self:aCL5[nPos][14]				
		If CL5->(FieldPos('CL5_FILAPU'))>0
			CL5->CL5_FILAPU	:=	Self:cFilApu
		EndIf					
		
		MsUnLock()
	Else
		RecLock('CL5',.F.)
		CL5->CL5_VLFAT	+=	Self:aCL5[nPos][6]
		CL5->CL5_DEDG		+=	Self:aCL5[nPos][7]
		CL5->CL5_DEDESP	+=	Self:aCL5[nPos][8]
		CL5->CL5_BASPIS	+=	Self:aCL5[nPos][9]
		CL5->CL5_VALPIS	+=	Self:aCL5[nPos][10]
		CL5->CL5_BASCOF	+=	Self:aCL5[nPos][11]
		CL5->CL5_VALCOF	+=	Self:aCL5[nPos][12]
		MsUnLock()			
	EndIF
Next nPos

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Apurar()
Método que irá processar os valores de PIS e COFINS considerando os
valores de deduções genéricas e específicas, para assim calcular
o valor dos tributos.

@author Erick G. Dias
@since 16/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD ApurarI100(oApurSai) Class TABELACL5

Local nX	:= 0

For nX	:= 1 to Len(Self:aCL5)
	
	//Processa valor de receita menos dedução genérica menos dedução específica para chegar na base de cálculo
	Self:aCL5[nX][9] := Self:aCL5[nX][6] - Self:aCL5[nX][7] - Self:aCL5[nX][8]	 //Receita - Dedução genérica - Dedução Específica
	Self:aCL5[nX][11] := Self:aCL5[nX][9]	
	
	If Self:aCL5[nX][3] $ "01/02/03"	
		//Valor do PIS considerando as deduções
		Self:aCL5[nX][10]:= Round((Self:aCL5[nX][9] * Self:aCL5[nX][4]) / 100,2)
		//Valor da COFINS considerando as deduções
		Self:aCL5[nX][12]:= Round((Self:aCL5[nX][11] * Self:aCL5[nX][5]) / 100,2)
	EndIF
	oApurSai:SetOrigem('8') //Outros
	oApurSai:SetRegime('1') 
	oApurSai:SetReceita(Self:aCL5[nX][6])
	oApurSai:SetBlocoI('1')
	
	//--------------------
	//Informações do PIS
	//--------------------		
	oApurSai:SetTributo('1')
	oApurSai:SetCST(Self:aCL5[nX][3])		
	oApurSai:SetAlqTrib(Self:aCL5[nX][4])
	oApurSai:SetBcTrib(Self:aCL5[nX][9])
	oApurSai:SetValTrib(Self:aCL5[nX][10])
	oApurSai:AgrpContr()
	
	//---------------------
	//Informações DA COFINS
	//---------------------
	oApurSai:SetTributo('2')
	oApurSai:SetCST(Self:aCL5[nX][3])		
	oApurSai:SetAlqTrib(Self:aCL5[nX][5])
	oApurSai:SetBcTrib(Self:aCL5[nX][11])
	oApurSai:SetValTrib(Self:aCL5[nX][12])
	oApurSai:AgrpContr()

	oApurSai:GrvResCST(,"I")
	oApurSai:AcumRecBru()

Next nX

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} TABELACL6
Classe que será responsável por realizar a gravação na tabela CL6

@author Erick G. Dias
@since 16/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
CLASS TABELACL6 FROM EFDGEN

	Data dPeriodo	As Date
	Data cIndice	As string
	Data cChvTab	As string
	Data aCl6		As Array
	//--------------------------------------------------------
	//Variáveis com os campos da tabela
	//--------------------------------------------------------
	Data dPer  	As Date	
	Data cCst		As String
	Data nAlqPis	As integer
	Data nAlqCof	As integer
	Data cReg		As String
	Data cCodigo	As String	
	Data cNumCpo	As String
	Data nValor	As Integer
	Data cConta	As String
	Data cInfCom	As String

	Method New()			
	Method Clear()
	Method Load()
	Method Insert()
	Method Save()
	Method SetParam(cCampo,Value)
	
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método Construtor da Classe 

@author Erick G. Dias
@since 16/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD New() Class TABELACL6

Self:Clear()
Self:aCL6		:={}
Self:IniHash()
Return  Self

METHOD Clear() Class TABELACL6

Self:cChvTab	:=''
Self:dPer		:=CTod("  /  /    ")
Self:nAlqPis	:=0
Self:nAlqCof	:=0
Self:nValor	:=0
Self:cCst		:=''
Self:cReg		:=''
Self:cCodigo	:=''
Self:cNumCpo	:=''
Self:cConta	:=''
Self:cInfCom	:=''
Self:cConsl	:= '2'

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetParam()
Método que irá alimentar os parâmetro com as informações que deverão ser gravadas
na tabela 

@author Erick G. Dias
@since 16/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method SetParam(cCampo,Value) Class TABELACL6	

Do Case		
	Case cCampo == 'CL6_PER'
		Self:dPer		:= Value		
	Case cCampo == 'CL6_CST'
		Self:cCst		:= Value
	Case cCampo == 'CL6_ALQPIS'
		Self:nAlqPis	:= Value
	Case cCampo == 'CL6_ALQCOF'
		Self:nAlqCof	:= Value		
	Case cCampo == 'CL6_REG'
		Self:cReg	:= Value
	Case cCampo == 'CL6_CODIGO'
		Self:cCodigo		:= Value
	Case cCampo == 'CL6_NUMCPO'
		Self:cNumCpo	:= Value
	Case cCampo == 'CL6_VALOR'
		Self:nValor	:= Value
	Case cCampo == 'CL6_CONTA'
		Self:cConta	:= Value
	Case cCampo == 'CL6_INFCOM'
		Self:cInfCom	:= Value
EndCase

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Load()
Método que irá fazer query na tabela e retornar alias com resultado.
Irá considerar as informações do métodos passados.

@author Erick G. Dias
@since 16/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method Load() Class TABELACL6

local cAlias	:= GetNextAlias()
Local cCampos	:= ''
Local cFrom	:= ''
Local cFiltro	:= '' 

BeginSql Alias cAlias

	SELECT
		%Exp:cCampos%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cFiltro%		
EndSql

Return cAlias

//-------------------------------------------------------------------
/*/{Protheus.doc} Insert()
Método que irá fazer query na tabela e retornar alias com resultado.
Irá considerar as informações do métodos passados.

@author Erick G. Dias
@since 23/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method Insert() Class TABELACL6

Local nPos:=aScan(Self:aCL6,{|aX| aX[1]==Self:BuscaxFil('CL5').AND. aX[2] == Self:dPer .AND.  aX[3]==Self:cCSt .and.;
										aX[4]==Self:nAlqPis .and. aX[5]==Self:nAlqCof .and. aX[6]==Self:cReg .and. aX[7]==Self:cCodigo;
										.and. aX[8]==Self:cNumCpo .and. aX[10]==Self:cConta }) 

IF nPos == 0
	aAdd(Self:aCL6, {})
	nPos := Len(Self:aCL6)
	aAdd (Self:aCL6[nPos], Self:BuscaxFil('CL6')		)	//01
	aAdd (Self:aCL6[nPos], Self:dPer			)	//02
	aAdd (Self:aCL6[nPos], Self:cCSt			)	//03	
	aAdd (Self:aCL6[nPos], Self:nAlqPis		)	//04
	aAdd (Self:aCL6[nPos], Self:nAlqCof		)	//05		
	aAdd (Self:aCL6[nPos], Self:cReg			)	//06
	aAdd (Self:aCL6[nPos], Self:cCodigo		)	//07
	aAdd (Self:aCL6[nPos], Self:cNumCpo		)	//08
	aAdd (Self:aCL6[nPos], Self:nValor			)	//09
	aAdd (Self:aCL6[nPos], Self:cConta			)	//10
	aAdd (Self:aCL6[nPos], Self:cInfCom		)	//11

Else
	Self:aCL6[nPos][9]	+= Self:nValor	
EndIF

Self:Clear()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Save()
Método que irá gravar na tabela todas as informações passadas pela classe

@author Erick G. Dias
@since 16/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method Save() Class TABELACL6
Local nPos	:= 0

dbSelectArea('CL6')
CL6->(dbSetOrder(1))
For nPos:= 1 to Len(Self:aCL6)

	//CL6_FILIAL + CL6_PER + CL6_CST + CL6_ALQPIS + CL6_ALQCOF + CL6_CODIGO + CL6_REG + CL6_NUMCPO + CL6_CONTA 
	If !CL6->(MSSEEK(Self:aCL6[nPos][1]+dTos(Self:aCL6[nPos][2])+Self:aCL6[nPos][3]+STR(Self:aCL6[nPos][4],8,4)+ STR(Self:aCL6[nPos][5],8,4) + padr(Self:aCL6[nPos][7],8) + padr(Self:aCL6[nPos][6],4) + padr(Self:aCL6[nPos][8],2) + padr(Self:aCL6[nPos][10],20) ))
		RecLock('CL6',.T.)
		CL6->CL6_FILIAL	:=	Self:aCL6[nPos][1]
		CL6->CL6_PER		:=	Self:aCL6[nPos][2]
		CL6->CL6_CST		:=	Self:aCL6[nPos][3]
		CL6->CL6_ALQPIS	:=	Self:aCL6[nPos][4]
		CL6->CL6_ALQCOF	:=	Self:aCL6[nPos][5]
		CL6->CL6_REG		:=	Self:aCL6[nPos][6]
		CL6->CL6_CODIGO	:=	Self:aCL6[nPos][7]
		CL6->CL6_NUMCPO	:=	Self:aCL6[nPos][8]
		CL6->CL6_VALOR	:=	Self:aCL6[nPos][9]
		CL6->CL6_CONTA	:=	Self:aCL6[nPos][10]
		CL6->CL6_INFCOM	:=	Self:aCL6[nPos][11]		
		If CL6->(FieldPos('CL6_FILAPU'))>0
			CL6->CL6_FILAPU	:=	Self:cFilApu
		EndIf					
		MsUnLock()
	Else
		RecLock('CL6',.F.)
		CL6->CL6_VALOR	+=	Self:aCL6[nPos][9]
		MsUnLock()			
	EndIF
Next nPos

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TABELACKT
Classe que será responsável por realizar a gravação na tabela CKT

@author Erick G. Dias
@since 16/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
CLASS TABELACKT FROM EFDGEN
	Data dPeriodo	As Date
	Data cIndice	As string
	Data cChvTab	As string
	Data aCKT	As Array
	Data nTamCta As Integer
	//--------------------------------------------------------
	//Variáveis com os campos da tabela
	//--------------------------------------------------------
	Data dPer  	As Date
	Data cTrib		As String
	Data cCst		As String	
	Data cCodNat	As String	
	Data nValRec	As Integer	
	Data cConta	As String
	Data cDescr	As String
	Data cOrigem	As String	

	Method New()			
	Method Load()
	Method Insert()
	Method Save()
	Method SetParam(cCampo,Value)
	
ENDCLASS
//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método Construtor da Classe 

@author Erick G. Dias
@since 16/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD New() Class TABELACKT

Self:aCKT		:={}
Self:cChvTab	:=''
Self:dPer		:=CTod("  /  /    ")
Self:nValRec	:=0
Self:cTrib		:=''
Self:cCst		:=''
Self:cCodNat	:=''
Self:cConta	:=''
Self:cDescr	:=''
Self:cConsl	:= '2'
Self:cOrigem	:= '9'
Self:nTamCta := TamSx3("CKT_CONTA")[1] 
Self:IniHash()

Return  Self

//-------------------------------------------------------------------
/*/{Protheus.doc} SetParam()
Método que irá alimentar os parâmetro com as informações que deverão ser gravadas
na tabela 

@author Erick G. Dias
@since 16/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method SetParam(cCampo,Value) Class TABELACKT

Do Case		
	Case cCampo == 'CKT_PER'
		Self:dPer		:= Value		
	Case cCampo == 'CKT_TRIB'
		Self:cTrib		:= Value
	Case cCampo == 'CKT_CST'
		Self:cCst	:= Value
	Case cCampo == 'CKT_CODNAT'
		Self:cCodNat	:= Value		
	Case cCampo == 'CKT_VLREC'
		Self:nValRec	:= Value
	Case cCampo == 'CKT_CONTA'
		Self:cConta		:= Value
	Case cCampo == 'CKT_DESCR'
		Self:cDescr	:= Value
	Case cCampo == 'CKT_ORIGEM'
		Self:cOrigem	:= Value		
EndCase

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Load()
Método que irá fazer query na tabela e retornar alias com resultado.
Irá considerar as informações do métodos passados.

@author Erick G. Dias
@since 16/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method Load() Class TABELACKT

local cAlias	:= GetNextAlias()
Local cCampos	:= ''
Local cFrom	:= ''
Local cFiltro	:= '' 

BeginSql Alias cAlias

	SELECT
		%Exp:cCampos%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cFiltro%		
EndSql

Return cAlias

//-------------------------------------------------------------------
/*/{Protheus.doc} Insert()
Método que irá fazer query na tabela e retornar alias com resultado.
Irá considerar as informações do métodos passados.

@author Erick G. Dias
@since 23/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method Insert() Class TABELACKT

Local nPos:=	aScan(Self:aCKT,{|aX| aX[1]==Self:BuscaxFil('CKT').AND. aX[2] == Self:dPer .AND.  aX[3]==Self:cTrib .AND. aX[4] == Self:cCst ;
									.AND. aX[5] == Self:cCodNat .AND. aX[7] == PADR(Self:cConta,Self:nTamCta) .AND.	aX[9] == Self:cConsl .AND.	aX[10] == Self:cOrigem})

IF nPos == 0 
	aAdd(Self:aCKT, {})
	nPos := Len(Self:aCKT)
	aAdd (Self:aCKT[nPos], Self:BuscaxFil('CKT')	)	//01
	aAdd (Self:aCKT[nPos], Self:dPer		)	//02
	aAdd (Self:aCKT[nPos], Self:cTrib		)	//03	
	aAdd (Self:aCKT[nPos], Self:cCst		)	//04
	aAdd (Self:aCKT[nPos], Self:cCodNat		)	//05		
	aAdd (Self:aCKT[nPos], Self:nValRec		)	//06
	aAdd (Self:aCKT[nPos], PADR(Self:cConta,Self:nTamCta)		)	//07
	aAdd (Self:aCKT[nPos], Self:cDescr		)	//08
	aAdd (Self:aCKT[nPos], Self:cConsl		)	//09	
	aAdd (Self:aCKT[nPos], Self:cOrigem		)	//10	

Else
	Self:aCKT[nPos][6]	+= Self:nValRec	
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Save()
Método que irá gravar na tabela todas as informações passadas pela classe

@author Erick G. Dias
@since 16/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method Save() Class TABELACKT
Local nPos	:= 0

dbSelectArea('CKT')
CKT->(dbSetOrder(1))
For nPos:= 1 to Len(Self:aCKT)
	
	If !CKT->(MSSEEK(Self:aCKT[nPos][1]+dTos(Self:aCKT[nPos][2])+Self:aCKT[nPos][3]+Self:aCKT[nPos][4]+Self:aCKT[nPos][5]+Self:aCKT[nPos][7]+Self:aCKT[nPos][9]+Self:aCKT[nPos][10]))
		RecLock('CKT',.T.)
		CKT->CKT_FILIAL	:=	Self:aCKT[nPos][1]
		CKT->CKT_PER		:=	Self:aCKT[nPos][2]
		CKT->CKT_TRIB		:=	Self:aCKT[nPos][3]
		CKT->CKT_CST		:=	Self:aCKT[nPos][4]
		CKT->CKT_CODNAT	:=	Self:aCKT[nPos][5]
		CKT->CKT_VLREC	:=	Self:aCKT[nPos][6]
		CKT->CKT_CONTA	:=	Self:aCKT[nPos][7]
		CKT->CKT_DESCR	:=	Self:aCKT[nPos][8]
		CKT->CKT_CONSOL	:=	Self:aCKT[nPos][9]
		CKT->CKT_ORIGEM	:=	Self:aCKT[nPos][10]				
		MsUnLock()
	Else
		RecLock('CKT',.F.)
		CKT->CKT_VLREC	+=	Self:aCKT[nPos][6]
		MsUnLock()			
	EndIF
Next nPos

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TABELACKV
Classe que será responsável por realizar a gravação na tabela CKV

@author Erick G. Dias
@since 18/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
CLASS TABELACKV FROM EFDGEN

	Data dPeriodo	As Date
	Data cIndice	As string
	Data cChvTab	As string
	Data aCKV		As Array
	Data lOverRide	 As Boolean
	//--------------------------------------------------------
	//Variáveis com os campos da tabela
	//--------------------------------------------------------
	Data dPer  	As Date
	Data cCod		As String
	Data nTotApur	As Integer
	Data nAjAc		As Integer
	Data nAjRd		As Integer
	Data nVlRec	As integer
	Data nRecBrut	As integer
	Data nBase	As integer
	Data nRecCod	As integer
	Data nExclu	As integer			

	Method New()
	Method Load(dDtIni,cCodReceita)	
	Method Insert()
	Method OverRide()
	Method Save()
	Method SetParam(cCampo,Value)	
	
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método Construtor da Classe 

@author Erick G. Dias
@since 18/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD New() Class TABELACKV

Self:aCKV		:={}
Self:cChvTab	:=''
Self:dPer		:=CTod("  /  /    ")
Self:cCod		:=''
Self:nTotApur	:=0
Self:nAjAc		:=0
Self:nAjRd		:=0
Self:nVlRec	:=0
Self:cConsl	:= '2'
Self:nRecBrut	:= 0
Self:nRecCod	:= 0
Self:nExclu	:= 0
Self:nBase		:= 0
Self:lOverRide	:= .F.
Self:cFilApu	:= ''
Self:IniHash()

Return  Self

Method OverRide(Value) Class TABELACKV
	Self:lOverRide := Value 
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} SetParam()
Método que irá alimentar os parâmetro com as informações que deverão ser gravadas
na tabela 

@author Erick G. Dias
@since 18/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method SetParam(cCampo,Value) Class TABELACKV

Do Case		
	Case cCampo == 'CKV_PER'
		Self:dPer		:= Value		
	Case cCampo == 'CKV_COD'
		Self:cCod		:= PADR(Value,6)
	Case cCampo == 'CKV_TOTAP'
		Self:nTotApur	:= Value
	Case cCampo == 'CKV_AJAC'
		Self:nAjAc		:= Value		
	Case cCampo == 'CKV_AJRD'
		Self:nAjRd		:= Value
	Case cCampo == 'CKV_VLREC'
		Self:nVlRec	:= Value
	Case cCampo == 'CKV_RECBRU'
		Self:nRecBrut	:= Value		
	Case cCampo == 'CKV_RECATI'
		Self:nRecCod	:= Value		
	Case cCampo == 'CKV_EXCLU'
		Self:nExclu	:= Value		
	Case cCampo == 'CKV_BASE'
		Self:nBase	:= Value
	Case cCampo == 'CKV_FILAPU' .And. CKV->(FieldPos('CKV_FILAPU')) > 0 
		Self:cFilApu	:= Value
	Case cCampo == 'CKV_CONSOL'
		Self:cConsl := Value
		
EndCase

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Load()
Método que irá fazer query na tabela e retornar alias com resultado.
Irá considerar as informações do métodos passados.

@author Erick G. Dias
@since 16/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method Load(dDtIni,cCodReceita) Class TABELACKV
Local cAliasCKV	:= 'CKV'
Local cSlctCKV	:= ''
Local cFiltro		:= ''
Local cGroupBy	:= ''

Default cCodReceita 	:= ''

dbSelectArea('CKV')
CKV->(dbSetOrder(1))

cSlctCKV:='%SUM(CKV.CKV_TOTAP) AS CKV_TOTAP,		SUM(CKV.CKV_AJAC)   AS CKV_AJAC,	SUM(CKV.CKV_AJRD)   AS CKV_AJRD, '
cSlctCKV+='SUM(CKV.CKV_VLREC) AS CKV_VLREC, 		SUM(CKV.CKV_RECBRU) AS CKV_RECBRU,	SUM(CKV.CKV_RECATI) AS CKV_RECATI,'
cSlctCKV+='SUM(CKV.CKV_EXCLU) AS CKV_EXCLU, 		SUM(CKV.CKV_BASE) AS CKV_BASE, '
cSlctCKV+='CKV.CKV_COD AS CKV_COD %'
cGroupBy:= '% GROUP BY CKV.CKV_COD %'

cFiltro := "%"
cFiltro += "CKV.CKV_FILIAL= '"+ Self:BuscaxFil('CKV')+ "' AND "
cFiltro += "CKV.CKV_PER>= '" + %Exp:DToS (dDtIni)% + "' AND "
cFiltro += "CKV.CKV_PER<= '" + %Exp:DToS (dDtIni)% + "' AND "
cFiltro += "CKV.CKV_CONSOL= '" +Self:cConsl + "' AND "
If !EmpTy(cCodReceita)
	cFiltro += "CKV.CKV_COD= '" +cCodReceita + "' AND "
EndIF
cFiltro += "%"

cAliasCKV	:=	GetNextAlias()
BeginSql Alias cAliasCKV
    	
	SELECT
	%Exp:cSlctCKV%

	FROM
	%Table:CKV% CKV
	WHERE
	%Exp:cFiltro%
	CKV.%NotDel%
        
	%Exp:cGroupBy%
EndSql

Return cAliasCKV


//-------------------------------------------------------------------
/*/{Protheus.doc} Insert()
Método que irá fazer query na tabela e retornar alias com resultado.
Irá considerar as informações do métodos passados.

@author Erick G. Dias
@since 18/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method Insert() Class TABELACKV

Local nPos :=	aScan(Self:aCKV,{|aX| aX[1]==Self:BuscaxFil('CKV').AND. aX[2] == Self:dPer .AND.  aX[3]==Self:cCod .AND. aX[8] == Self:cConsl })
Local lCPRBNF		:= GetNewPar('MV_CPRBNF',.F.)

IF nPos == 0
	aAdd(Self:aCKV, {})
	nPos := Len(Self:aCKV)
	aAdd (Self:aCKV[nPos], Self:BuscaxFil('CKV')	)	//01
	aAdd (Self:aCKV[nPos], Self:dPer		)	//02
	aAdd (Self:aCKV[nPos], Self:cCod		)	//03	
	aAdd (Self:aCKV[nPos], Self:nTotApur	)	//04
	aAdd (Self:aCKV[nPos], Self:nAjAc		)	//05		
	aAdd (Self:aCKV[nPos], Self:nAjRd		)	//06
	aAdd (Self:aCKV[nPos], Self:nVlRec		)	//07
	aAdd (Self:aCKV[nPos], Self:cConsl		)	//08
	aAdd (Self:aCKV[nPos], Self:nRecBrut	)	//09		
	aAdd (Self:aCKV[nPos], Self:nRecCod	)	//10
	aAdd (Self:aCKV[nPos], Self:nExclu		)	//11
	aAdd (Self:aCKV[nPos], Self:nBase		)	//12
	aAdd (Self:aCKV[nPos], Self:cFilApu	)	//13  

Else
	Self:aCKV[nPos][4]	+= Self:nTotApur	
	Self:aCKV[nPos][5]	+= Self:nAjAc
	Self:aCKV[nPos][6]	+= Self:nAjRd		
	Self:aCKV[nPos][7]	+= Self:nVlRec
	If lCPRBNF
		Self:aCKV[nPos][9]	+= Self:nRecBrut	
	EndIf
	Self:aCKV[nPos][10]	+= Self:nRecCod
	Self:aCKV[nPos][11]	+= Self:nExclu		
	Self:aCKV[nPos][12]	+= Self:nBase			
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Save()
Método que irá gravar na tabela todas as informações passadas pela classe

@author Erick G. Dias
@since 18/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method Save() Class TABELACKV
Local nPos	:= 0

dbSelectArea('CKV')
CKV->(dbSetOrder(1))
For nPos:= 1 to Len(Self:aCKV)
	
	If !CKV->(MSSEEK(Self:aCKV[nPos][1]+dTos(Self:aCKV[nPos][2])+Self:aCKV[nPos][3]+Self:aCKV[nPos][8]))
		RecLock('CKV',.T.)
		CKV->CKV_FILIAL	:=	Self:aCKV[nPos][1]
		CKV->CKV_PER		:=	Self:aCKV[nPos][2]
		CKV->CKV_COD		:=	Self:aCKV[nPos][3]
		CKV->CKV_TOTAP	:=	Self:aCKV[nPos][4]
		CKV->CKV_AJAC		:=	Self:aCKV[nPos][5]
		CKV->CKV_AJRD		:=	Self:aCKV[nPos][6]
		CKV->CKV_VLREC	:=	Self:aCKV[nPos][7]
		CKV->CKV_CONSOL	:=	Self:aCKV[nPos][8]
		CKV->CKV_RECBRU	:=	Self:aCKV[nPos][9]
		CKV->CKV_RECATI	:=	Self:aCKV[nPos][10]
		CKV->CKV_EXCLU	:=	Self:aCKV[nPos][11]
		CKV->CKV_BASE		:=	Self:aCKV[nPos][12]
		If CKV->(FieldPos('CKV_FILAPU')) > 0  
			CKV->CKV_FILAPU	:=	Self:aCKV[nPos][13]
		Endif

		MsUnLock()
	ElseIF !Self:lOverRide
		RecLock('CKV',.F.)
		CKV->CKV_TOTAP	+=	Self:aCKV[nPos][4]
		CKV->CKV_AJAC		+=	Self:aCKV[nPos][5]
		CKV->CKV_AJRD		+=	Self:aCKV[nPos][6]
		CKV->CKV_VLREC	+=	Self:aCKV[nPos][7]		
		CKV->CKV_RECBRU	+=	Self:aCKV[nPos][9]
		CKV->CKV_RECATI	+=	Self:aCKV[nPos][10]
		CKV->CKV_EXCLU	+=	Self:aCKV[nPos][11]
		CKV->CKV_BASE		+=	Self:aCKV[nPos][12]		
		
		MsUnLock()			
	Else //Irá sobreEscrever os valores
		RecLock('CKV',.F.)
		CKV->CKV_TOTAP	:=	Self:aCKV[nPos][4]
		CKV->CKV_AJAC		:=	Self:aCKV[nPos][5]
		CKV->CKV_AJRD		:=	Self:aCKV[nPos][6]
		CKV->CKV_VLREC	:=	Self:aCKV[nPos][7]
		CKV->CKV_RECBRU	:=	Self:aCKV[nPos][9]
		CKV->CKV_RECATI	:=	Self:aCKV[nPos][10]
		CKV->CKV_EXCLU	:=	Self:aCKV[nPos][11]
		CKV->CKV_BASE		:=	Self:aCKV[nPos][12]		

		MsUnLock()
	EndIF
Next nPos

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TABELACKX
Classe que será responsável por realizar a gravação na tabela CKX

@author Erick G. Dias
@since 18/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
CLASS TABELACKX FROM EFDGEN

	Data dPeriodo	As Date
	Data cIndice	As string
	Data cChvTab	As string
	Data aCKX	As Array
	//--------------------------------------------------------
	//Variáveis com os campos da tabela
	//--------------------------------------------------------
	Data dPer  	As Date
	Data cSaldo 	As String	
	Data cCod		As String
	Data cCodAtiv	As String
	Data cCodRec	As string
	Data nVlBrut	As integer
	Data nVlAti	As integer
	Data nExclu	As integer
	Data nBase  	As Integer
	Data nAlq		As integer
	Data nVlCPRB	As integer
	Data cConta	As Integer
	Data cInform	As string
	Data cNTrib		As string
	
	Method New()			
	Method Load()
	Method LoadCKX(dDtIni)
	Method Insert()
	Method Save()
	Method SetParam(cCampo,Value)
	
ENDCLASS

CLASS TABELAF3Z FROM EFDGEN

	Data dPeriodo	As Date
	Data cIndice	As string
	Data cChvTab	As string
	Data aF3Z	As Array
	//--------------------------------------------------------
	//Variáveis com os campos da tabela
	//--------------------------------------------------------
	Data dPer  		As Date
	Data cSaldo 	As String	
	Data cCodAtiv	As String
	Data nVlBrut	As integer
	Data nVlAti		As integer
	Data nExclu		As integer
	Data nBase  	As Integer
	Data nAlq		As integer
	Data nVlCPRB	As integer
	Data cConta		As Integer
	Data cNTrib		As string
	Data cCNO		As string
	
	Method New()			
	Method Insert()
	Method SetParam(cCampo,Value)
	Method Save()
	
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método Construtor da Classe 

@author Erick G. Dias
@since 18/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD New() Class TABELACKX

Self:aCKX		:={}
Self:cChvTab	:=''
Self:dPer		:=CTod("  /  /    ")
Self:cSaldo	:='2'
Self:cCodAtiv	:=''
Self:cCodRec	:=''
Self:nVlBrut	:=0
Self:nVlAti	:=0
Self:nExclu	:=0
Self:nBase		:=0
Self:nAlq		:=0
Self:nVlCPRB	:=0
Self:cConta	:=''
Self:cInform	:=''	
Self:cConsl	:= '2'
Self:cFilApu  := ''
Self:cNTrib	  := ''
Self:IniHash()

Return  Self

METHOD New() Class TABELAF3Z

Self:aF3Z		:={}
Self:cChvTab	:=''
Self:dPer		:=CTod("  /  /    ")
Self:cSaldo	:='2'
Self:cCodAtiv	:=''
Self:nVlBrut	:=0
Self:nVlAti	:=0
Self:nExclu	:=0 
Self:nBase		:=0
Self:nAlq		:=0
Self:nVlCPRB	:=0
Self:cConta	:=''	
Self:cConsl	:= '2'
Self:cFilApu  := ''
Self:cCNO	:= ''
Self:IniHash()

Return  Self

//-------------------------------------------------------------------
/*/{Protheus.doc} SetParam()
Método que irá alimentar os parâmetro com as informações que deverão ser gravadas
na tabela 

@author Erick G. Dias
@since 18/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method SetParam(cCampo,Value) Class TABELACKX
	
Do Case		
	Case cCampo == 'CKX_PER'
		Self:dPer			:= Value		
	Case cCampo == 'CKX_CODATI'
		Self:cCodAtiv		:= padr(Value,8)
	Case cCampo == 'CKX_CODREC'
		Self:cCodRec		:= padr(Value,6)
	Case cCampo == 'CKX_VLBRUT'
		Self:nVlBrut		:= Value		
	Case cCampo == 'CKX_VLATI'
		Self:nVlAti		:= Value
	Case cCampo == 'CKX_EXCLU'
		Self:nExclu		:= Value
	Case cCampo == 'CKX_BASE'
		Self:nBase			:= Value		
	Case cCampo == 'CKX_ALIQ'
		Self:nAlq			:= Value
	Case cCampo == 'CKX_VLCPRB'
		Self:nVlCPRB		:= Value
	Case cCampo == 'CKX_CONTA'
		Self:cConta		:= Value
	Case cCampo == 'CKX_INFORM'
		Self:cInform		:= Value
	Case cCampo == 'CKX_SALDO'
		Self:cSaldo		:= Value
	Case cCampo == 'CKX_FILAPU' 
       Self:cFilApu    := Value
	Case cCampo == 'CKX_NTRIB' 
		Self:cNTrib    := Value
EndCase

Return

Method SetParam(cCampo,Value) Class TABELAF3Z
	
Do Case		
	Case cCampo == 'F3Z_PER'
		Self:dPer			:= Value		
	Case cCampo == 'F3Z_CODATI'
		Self:cCodAtiv		:= padr(Value,8)
	Case cCampo == 'F3Z_VLBRUT'
		Self:nVlBrut		:= Value		
	Case cCampo == 'F3Z_VLATI'
		Self:nVlAti			:= Value
	Case cCampo == 'F3Z_EXCLU'
		Self:nExclu			:= Value
	Case cCampo == 'F3Z_BASE'
		Self:nBase			:= Value		
	Case cCampo == 'F3Z_ALIQ'
		Self:nAlq			:= Value
	Case cCampo == 'F3Z_VLCPRB'
		Self:nVlCPRB		:= Value
	Case cCampo == 'F3Z_CONTA'
		Self:cConta			:= Value
	Case cCampo == 'F3Z_SALDO'
		Self:cSaldo			:= Value
	Case cCampo == 'F3Z_FILAPU' 
       Self:cFilApu    		:= Value
	Case cCampo == 'F3Z_CNO'
		Self:cCNO			:= Value
EndCase

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Load()
Método que irá fazer query na tabela e retornar alias com resultado.
Irá considerar as informações do métodos passados.

@author Erick G. Dias
@since 16/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method Load() Class TABELACKX

local cAlias	:= GetNextAlias()
Local cCampos	:= ''
Local cFrom	:= ''
Local cFiltro	:= '' 


//Retornar array das informaçlões CKX com campo CKX_PERUTI do período
//Criar campo no UPDFIS CKX_PERUTI - campo preenchido corresponde a saldo, campos vazio corresponde a operação normal.
//Alterar índice colocando o CKX_PERUTI
//Alterar X2Unico colocando CKX_PERUTI
//No momento de gerar P100 verificar se existe CKX com período UTI igual ao processado
//Se existir considerar este valor de exclusão de receita também
//Alterar array com o valor consumido.
//Se ainda restar valor, gravar CKX novamente porém somente com a diferença para próximo período.

BeginSql Alias cAlias

	SELECT
		%Exp:cCampos%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cFiltro%		
EndSql

Return cAlias


//-------------------------------------------------------------------
/*/{Protheus.doc} LoadCKX()
Método que irá fazer query na tabela CKX e retornar Registros consolidados com Flag de não desonerado.

@author Rafael.Soliveira
@since 09/08/2017
@version 11.80
/*/
//-------------------------------------------------------------------
Method LoadCKX(dDtIni) Class TABELACKX
Local cAliasCKX	:= GetNextAlias()
Local cSlctCKX	:= ''
Local cFiltro	:= ''
Local cGroupBy	:= ''
Local lFilApu := CKX->(FieldPos('CKX_FILAPU'))>0
Local lNTrib  := CKX->(FieldPos('CKX_NTRIB'))>0

dbSelectArea('CKX')
CKX->(dbSetOrder(1))

cSlctCKX:='CKX.CKX_FILIAL, CKX.CKX_PER, CKX.CKX_CODATI, CKX.CKX_CODREC, CKX.CKX_ALIQ,'
cSlctCKX+='CKX.CKX_VLBRUT, CKX.CKX_VLATI, CKX.CKX_BASE, CKX.CKX_VLCPRB, CKX.CKX_EXCLU'
If lFilApu
	cSlctCKX+=",CKX.CKX_FILAPU"
Endif

cSlctCKX := "%"+cSlctCKX+"%"

cFiltro := "%"
cFiltro += "CKX.CKX_FILIAL= '"+ Self:BuscaxFil('CKX')+ "' AND "
cFiltro += "CKX.CKX_PER>= '" + %Exp:DToS (dDtIni)% + "' AND "
cFiltro += "CKX.CKX_PER<= '" + %Exp:DToS (dDtIni)% + "' AND "
If lNTrib
	cFiltro += "CKX.CKX_NTRIB= 'S' AND "
EndIf
cFiltro += "%"
BeginSql Alias cAliasCKX
    	
	COLUMN CKX_PER AS DATE
	
	SELECT
	%Exp:cSlctCKX%

	FROM
	%Table:CKX% CKX
	WHERE
	%Exp:cFiltro%
	CKX.%NotDel%
        
	//%Exp:cGroupBy%
EndSql

Return cAliasCKX

//-------------------------------------------------------------------
/*/{Protheus.doc} Insert()
Método que irá fazer query na tabela e retornar alias com resultado.
Irá considerar as informações do métodos passados.

@author Erick G. Dias
@since 18/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method Insert() Class TABELACKX

Local lCPRBNF		:= GetNewPar('MV_CPRBNF',.F.)
Local nPos:=	aScan(Self:aCKX,{|aX| aX[1]==Self:BuscaxFil('CKX').AND. aX[2] == Self:dPer .AND.  aX[3]==Self:cCodAtiv .AND. aX[11]==Self:cConta .AND. ;
									 aX[4]==Self:cCodRec .AND.  (Iif(lCPRBNF,Iif(aX[9]==0,.T.,.F.),aX[9]==Self:nAlq)) .AND.  (Iif(lCPRBNF,Iif(aX[9]==0,.T.,.F.),aX[13]==Self:cSaldo))})

IF nPos == 0
	aAdd(Self:aCKX, {})
	nPos := Len(Self:aCKX)
	aAdd (Self:aCKX[nPos], Self:BuscaxFil('CKX')	)	//01
	aAdd (Self:aCKX[nPos], Self:dPer		)	//02
	aAdd (Self:aCKX[nPos], Self:cCodAtiv	)	//03	
	aAdd (Self:aCKX[nPos], Self:cCodRec	)	//04
	aAdd (Self:aCKX[nPos], Self:nVlBrut	)	//05		
	aAdd (Self:aCKX[nPos], Self:nVlAti		)	//06
	aAdd (Self:aCKX[nPos], Self:nExclu		)	//07
	aAdd (Self:aCKX[nPos], Self:nBase		)	//08	
	aAdd (Self:aCKX[nPos], Self:nAlq		)	//09
	aAdd (Self:aCKX[nPos], Self:nVlCPRB	)	//10		
	aAdd (Self:aCKX[nPos], Self:cConta		)	//11
	aAdd (Self:aCKX[nPos], Self:cInform	)	//12	
	aAdd (Self:aCKX[nPos], Self:cSaldo		)	//13
	aAdd (Self:aCKX[nPos], Self:cNTrib	)		//14	
Else
	Self:aCKX[nPos][5]	+= Self:nVlBrut	
	Self:aCKX[nPos][6]	+= Self:nVlAti
	Self:aCKX[nPos][7]	+= Self:nExclu
	Self:aCKX[nPos][8]	+= Self:nBase
	If lCPRBNF .And. Self:aCKX[nPos][9] == 0  
		Self:aCKX[nPos][9]	+= Self:nAlq
	Endif			
	Self:aCKX[nPos][10]	+= Self:nVlCPRB	
EndIF

Self:cSaldo	:= '2'

Return

Method Insert() Class TABELAF3Z

Local lCPRBNF		:= GetNewPar('MV_CPRBNF',.F.)
Local nPos:=	aScan(Self:aF3Z,{|aX| aX[1]==Self:BuscaxFil('F3Z').AND. aX[2] == Self:dPer .AND.  aX[3]==Self:cCodAtiv .AND. aX[10]==Self:cConta .AND.  (Iif(lCPRBNF,Iif(aX[8]==0,.T.,.F.),aX[8]==Self:nAlq)) .AND.  (Iif(lCPRBNF,Iif(aX[8]==0,.T.,.F.),aX[11]==Self:cSaldo .AND. aX[12]==Self:cCNO))})

IF nPos == 0
	aAdd(Self:aF3Z, {})
	nPos := Len(Self:aF3Z)
	aAdd (Self:aF3Z[nPos], Self:BuscaxFil('F3Z')	)	//01
	aAdd (Self:aF3Z[nPos], Self:dPer		)			//02
	aAdd (Self:aF3Z[nPos], Self:cCodAtiv	)			//03	
	aAdd (Self:aF3Z[nPos], Self:nVlBrut	)				//04		
	aAdd (Self:aF3Z[nPos], Self:nVlAti		)			//05
	aAdd (Self:aF3Z[nPos], Self:nExclu		)			//06
	aAdd (Self:aF3Z[nPos], Self:nBase		)			//07	
	aAdd (Self:aF3Z[nPos], Self:nAlq		)			//08
	aAdd (Self:aF3Z[nPos], Self:nVlCPRB	)				//09		
	aAdd (Self:aF3Z[nPos], Self:cConta		)			//10	
	aAdd (Self:aF3Z[nPos], Self:cSaldo		)			//11	
	aAdd (Self:aF3Z[nPos], Self:cCNO	)				//12
Else
	Self:aF3Z[nPos][4]	+= Self:nVlBrut	
	Self:aF3Z[nPos][5]	+= Self:nVlAti
	Self:aF3Z[nPos][6]	+= Self:nExclu
	Self:aF3Z[nPos][7]	+= Self:nBase
	If lCPRBNF .And. Self:aF3Z[nPos][8] == 0  
		Self:aF3Z[nPos][8]	+= Self:nAlq
	Endif			
	Self:aF3Z[nPos][09]	+= Self:nVlCPRB	
EndIF

Self:cSaldo	:= '2'

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Save()
Método que irá gravar na tabela todas as informações passadas pela classe

@author Erick G. Dias
@since 18/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method Save() Class TABELACKX
Local nPos	:= 0
Local lFilApu := CKX->(FieldPos('CKX_FILAPU'))>0
Local lNTrib  := CKX->(FieldPos('CKX_NTRIB'))> 0

dbSelectArea('CKX')
CKX->(dbSetOrder(1))
For nPos:= 1 to Len(Self:aCKX)

	If !CKX->(MSSEEK(Self:aCKX[nPos][1]+dTos(Self:aCKX[nPos][2])+Padr(Self:aCKX[nPos][3], TAMSX3("CKX_CODATI")[1])+Padr(Self:aCKX[nPos][4], TAMSX3("CKX_CODREC")[1])+STR(Self:aCKX[nPos][9],8,4)+Self:aCKX[nPos][13]+Padr(Self:aCKX[nPos][11], TAMSX3("CKX_CONTA")[1])))
		RecLock('CKX',.T.)
		CKX->CKX_FILIAL	:=	Self:aCKX[nPos][1]
		CKX->CKX_PER		:=	Self:aCKX[nPos][2]
		CKX->CKX_CODATI	:=	Self:aCKX[nPos][3]
		CKX->CKX_CODREC	:=	Self:aCKX[nPos][4]
		CKX->CKX_VLBRUT	:=	Self:aCKX[nPos][5]
		CKX->CKX_VLATI	:=	Self:aCKX[nPos][6]
		CKX->CKX_EXCLU	:=	Self:aCKX[nPos][7]
		CKX->CKX_BASE		:=	Self:aCKX[nPos][8]
		CKX->CKX_ALIQ		:=	Self:aCKX[nPos][9]
		CKX->CKX_VLCPRB	:=	Self:aCKX[nPos][10]
		CKX->CKX_CONTA	:=	Self:aCKX[nPos][11]
		CKX->CKX_INFORM	:=	Self:aCKX[nPos][12]
		CKX->CKX_SALDO	:=	Self:aCKX[nPos][13]	
		If lFilApu
			CKX->CKX_FILAPU	:=	Self:cFilApu
        EndIf
		If lNTrib
			CKX->CKX_NTRIB	:=	Self:aCKX[nPos][14]	
        EndIf 
		MsUnLock()
	Else
		RecLock('CKX',.F.)
		CKX->CKX_VLBRUT	+=	Self:aCKX[nPos][5]
		CKX->CKX_VLATI	+=	Self:aCKX[nPos][6]
		CKX->CKX_EXCLU	+=	Self:aCKX[nPos][7]
		CKX->CKX_BASE		+=	Self:aCKX[nPos][8]
		CKX->CKX_VLCPRB	+=	Self:aCKX[nPos][10]		
		MsUnLock()			
	EndIF
Next nPos

Return

Method Save() Class TABELAF3Z
Local nPos	:= 0
Local lFilApu := F3Z->(FieldPos('F3Z_FILAPU'))>0

dbSelectArea('F3Z')
F3Z->(dbSetOrder(1))
For nPos:= 1 to Len(Self:aF3Z)

	If !F3Z->(MSSEEK(Self:aF3Z[nPos][1]+dTos(Self:aF3Z[nPos][2])+Padr(Self:aF3Z[nPos][3],TAMSX3("F3Z_CODATI")[1]);
    +STR(Self:aF3Z[nPos][8],8,4)+Self:aF3Z[nPos][11]+Padr(Self:aF3Z[nPos][10],TAMSX3("F3Z_CONTA")[1])+Self:aF3Z[nPos][12]))

		RecLock('F3Z',.T.)
		F3Z->F3Z_FILIAL	:=	Self:aF3Z[nPos][1]
		F3Z->F3Z_PER	:=	Self:aF3Z[nPos][2]
		F3Z->F3Z_CODATI	:=	Self:aF3Z[nPos][3]
		F3Z->F3Z_VLBRUT	:=	Self:aF3Z[nPos][4]
		F3Z->F3Z_VLATI	:=	Self:aF3Z[nPos][5]
		F3Z->F3Z_EXCLU	:=	Self:aF3Z[nPos][6]
		F3Z->F3Z_BASE	:=	Self:aF3Z[nPos][7]
		F3Z->F3Z_ALIQ	:=	Self:aF3Z[nPos][8]
		F3Z->F3Z_VLCPRB	:=	Self:aF3Z[nPos][9]
		F3Z->F3Z_CONTA	:=	Self:aF3Z[nPos][10]
		F3Z->F3Z_SALDO	:=	Self:aF3Z[nPos][11]
		F3Z->F3Z_CNO	:=	Self:aF3Z[nPos][12]	
		If lFilApu
			F3Z->F3Z_FILAPU	:=	Self:cFilApu
        EndIf
		MsUnLock()
	Else
		RecLock('F3Z',.F.)
		F3Z->F3Z_VLBRUT	+=	Self:aF3Z[nPos][4]
		F3Z->F3Z_VLATI	+=	Self:aF3Z[nPos][5]
		F3Z->F3Z_EXCLU	+=	Self:aF3Z[nPos][6]
		F3Z->F3Z_BASE		+=	Self:aF3Z[nPos][7]
		F3Z->F3Z_VLCPRB	+=	Self:aF3Z[nPos][9]		 
		MsUnLock()		
	EndIF
Next nPos

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TABELAF2S
Classe que será responsável por realizar a gravação na tabela F2S

@author Vogas Júnior
@since 18/09/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
CLASS TABELAF2S FROM EFDGEN

	Data dPeriodo	As Date
	Data cIndice	As string
	Data cChvTab	As string
	Data aF2S		As Array
	Data cTributo 	As String	
	Data cTpAjus	As String
	Data cCodAju	As String
	Data nValAju	As Integer	
	Data cDescri	As String
	
	If AliasIndic('F2S')
		Method New()			
		Method Insert()
		Method Save()
		Method SetParam(cCampo,Value)
	EndIf	
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método Construtor da Classe 

@author Vogas Júnior
@since 18/09/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
METHOD New() Class TABELAF2S

Self:aF2S		:={}
Self:cTributo	:= ''
Self:cTpAjus	:= ''
Self:cCodAju	:= ''
Self:nValAju	:=0
Self:cDescri	:= ''
Self:dPeriodo	:=CTod("  /  /    ")

Return  Self

//-------------------------------------------------------------------
/*/{Protheus.doc} SetParam()
Método que irá alimentar os parâmetro com as informações que deverão ser gravadas
na tabela 

@author Vogas Júnior
@since 18/09/2018
@version 12.1.17-
/*/
//-------------------------------------------------------------------
Method SetParam(cCampo,Value) Class TABELAF2S
	
Do Case		
	Case cCampo == 'F2S_TRIBUT'
		Self:cTributo	:= Value		
	Case cCampo == 'F2S_TPAJUS'
		Self:cTpAjus	:= Value
	Case cCampo == 'F2S_CODAJU'
		Self:cCodAju	:= Value
	Case cCampo == 'F2S_VLRAJU'
		Self:nValAju	:= Value		
	Case cCampo == 'F2S_DESCRI'
		Self:cDescri	:= Value
	Case cCampo == 'F2S_PER'
		Self:dPeriodo	:= Value
EndCase

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Insert()
Método que irá fazer query na tabela e retornar alias com resultado.
Irá considerar as informações do métodos passados.

@author Vogas Júnior
@since 18/09/2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method Insert() Class TABELAF2S

Local nPos:= 0
If AliasIndic('F2S')

	nPos:=aScan(Self:aF2S,{|aX| aX[1]==Self:BuscaxFil('F2S') .AND. aX[2] == Self:cTributo .AND. aX[3]==Self:cTpAjus .AND. aX[4]==Self:cCodAju})

	IF nPos == 0
		aAdd(Self:aF2S, {})
		nPos := Len(Self:aF2S)
		aAdd (Self:aF2S[nPos], Self:BuscaxFil('F2S'))	//01
		aAdd (Self:aF2S[nPos], Self:cTributo		)	//02
		aAdd (Self:aF2S[nPos], Self:cTpAjus			)	//03	
		aAdd (Self:aF2S[nPos], Self:cCodAju			)	//04
		aAdd (Self:aF2S[nPos], Self:nValAju			)	//05		
		aAdd (Self:aF2S[nPos], Self:cDescri			)	//06
		aAdd (Self:aF2S[nPos], Self:dPeriodo		)	//07
	Else
		Self:aF2S[nPos][5]	+= Self:nValAju	
	EndIF
EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Save()
Método que irá gravar na tabela todas as informações passadas pela classe

@author Vogas Júnior
@since 18/09/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Method Save() Class TABELAF2S
Local nPos	:= 0

If AliasIndic('F2S')
	dbSelectArea('F2S')
	F2S->(dbSetOrder(1))
	For nPos:= 1 to Len(Self:aF2S)

		If !F2S->(MSSEEK(Self:aF2S[nPos][1]+DtoS(Self:aF2S[nPos][7])+Self:aF2S[nPos][2]+Self:aF2S[nPos][3]+Self:aF2S[nPos][4]))
			RecLock('F2S',.T.)
			F2S->F2S_FILIAL	:=	Self:aF2S[nPos][1]
			F2S->F2S_TRIBUT	:=	Self:aF2S[nPos][2]
			F2S->F2S_TPAJUS	:=	Self:aF2S[nPos][3]
			F2S->F2S_CODAJU	:=	Self:aF2S[nPos][4]
			F2S->F2S_VLRAJU	:=	Self:aF2S[nPos][5]
			F2S->F2S_DESCRI	:=	Self:aF2S[nPos][6]
			F2S->F2S_PER	:=	Self:aF2S[nPos][7]
			MsUnLock()
		Else
			RecLock('F2S',.F.)
			F2S->F2S_VLRAJU	+=	Self:aF2S[nPos][5]
			MsUnLock()			
		EndIF
	Next nPos
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TABELACL1
Classe que será responsável por realizar a gravação na tabela CL1

@author Erick G. Dias
@since 25/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
CLASS TABELACL1 FROM EFDGEN

//--------------------------------------------------------
//Variáveis com os campos da tabela
//--------------------------------------------------------
Data dPer  	As Date
Data cId		As String
Data cCstPis	As string
Data cCstCof	As String
Data nAlqPis  As Integer
Data nAlqCof  As Integer
DAta cModelo	As String
Data cCfop		As String
Data lPauta	As Boolean
Data nValRec	As integer
Data nDescPis	As integer
Data nBasePis	As Integer
Data nValPis  	As Integer
Data nDescCof	As integer
Data nBaseCof 	As Integer
Data nValCof	As Integer
Data cConta	As string
Data cInfCom	As String
Data cCnpj		As String
Data cNumDoc	As String
Data cNumNfTit		As String
Data cItem		As String
Data cIndPro	As String
Data cNumPro	As String
Data cSerie	As String
Data cClieFor	As String
Data cLoja 	As String
Data cTnatRec 	As String
Data cCNatRec 	As String
Data cGrupo 	As String
Data cIndRec	As String
Data dtDtFim 	As Date
Data nQuantid As Integer
Data aRegCL1	As Array
Data aRegCL7	As Array
Data aTotRec	As Array
	
Method New()			
Method Clear()
Method Save()
Method CalcCaixa(Value)

Method SetPer(Value)
Method SetCstPis(Value)
Method SetCstCof(Value)
Method SetAlqPis(Value)
Method setAlqCof(Value)
Method SetModelo(Value)
Method SetCfop(Value)
Method SetPauta(Value)
Method SetValRec(Value)
Method SetDescPis(Value)
Method SetBasePis(Value)
Method SetValPis(Value)
Method SetDescCof(Value)
Method SetBaseCof(Value)
Method SetValCof(Value)
Method SetConta(Value)
Method SetInfCom(Value)
Method SetCnPj(Value)
Method SetNumDoc(Value)
Method SetNfTit(Value)
Method SetItem(Value)
Method SetIndPro(Value)
Method SetNumPro(Value)
Method SetSerie(Value)
Method SetClieFor(Value)
Method SetLoja(Value)
Method SetTNatRec(Value)
Method SetCNatRec(Value)
Method SetGrupo(Value)
Method SetDtFim(Value)
Method SetQuantid(Value)
Method SetIndRec(Value)
Method getBase(Value)
Method getAliq(Value)
Method getValor(Value)
Method getCST(Value)
Method getNumDoc()
Method getSerie()
Method getClieFor()
Method getLoja()
Method getTNatRec()
Method getCNatRec()
Method getConta()
	
ENDCLASS


METHOD New() Class TABELACL1

Self:aRegCL1	:= {}
Self:aRegCL7	:= {}
Self:aTotRec	:= {0,0,0,0,0,0,0}
Self:dPer  	:= CTod("  /  /    ")
Self:IniHash()
Self:Clear()

Return  Self

Method Clear() Class TABELACL1

Self:dtDtFim 	:= CTod("  /  /    ")
Self:cId		:= ''
Self:cCstPis	:= ''
Self:cCstCof	:= ''
Self:nAlqPis  := 0
Self:nAlqCof  := 0
Self:cModelo	:= ''
Self:cCfop		:= ''
Self:lPauta	:= .F.
Self:nValRec	:= 0
Self:nDescPis	:= 0
Self:nBasePis	:= 0
Self:nValPis  	:= 0
Self:nDescCof	:= 0
Self:nBaseCof 	:= 0
Self:nValCof	:= 0
Self:cConta	:= ''
Self:cInfCom	:= ''
Self:cCnpj		:= ''
Self:cNumDoc	:= ''
Self:cNumNfTit	:= ''
Self:cItem		:= ''
Self:cIndPro	:= ''
Self:cNumPro	:= ''
Self:cSerie	:= ''
Self:cClieFor	:= ''
Self:cLoja 	:= ''
Self:cTnatRec 	:= ''
Self:cCNatRec 	:= ''
Self:cGrupo 	:= ''
Self:nQuantid := 0
Self:cIndrec	:= ''
Self:cConsl	:= '2'

Return

Method SetPer(Value)	Class TABELACL1
	Self:dPer	:=	Value
Return

Method SetCstPis(Value)	Class TABELACL1
	Self:cCstPis	:=	Value
Return

Method SetCstCof(Value)	Class TABELACL1
	Self:cCstCof	:=	Value
Return

Method SetAlqPis(Value)	Class TABELACL1
	Self:nAlqPis	:=	Value
Return

Method setAlqCof(Value)	Class TABELACL1
	Self:nAlqCof	:=	Value
Return

Method SetModelo(Value)	Class TABELACL1
	Self:cModelo	:=	Value
Return

Method SetCfop(Value)	Class TABELACL1
	Self:cCfop	:=	Value
Return

Method SetPauta(Value)	Class TABELACL1
	Self:lPauta	:=	Value
Return

Method SetValRec(Value)	Class TABELACL1
	Self:nValRec	:=	Value
Return

Method SetDescPis(Value)Class TABELACL1
	Self:nDescPis	:=	Value
Return

Method SetBasePis(Value)Class TABELACL1
	Self:nBasePis	:=	Value
Return

Method SetValPis(Value)	Class TABELACL1
	Self:nValPis	:=	Value
Return

Method SetDescCof(Value)Class TABELACL1
	Self:nDescCof	:=	Value
Return

Method SetBaseCof(Value)Class TABELACL1
	Self:nBaseCof	:=	Value
Return

Method SetValCof(Value)	Class TABELACL1
	Self:nValCof	:=	Value
Return

Method SetConta(Value)	Class TABELACL1
	Self:cConta	:=	Value
Return

Method SetInfCom(Value)	Class TABELACL1
	Self:cInfCom	:=	Value
Return

Method SetCnPj(Value)	Class TABELACL1
	Self:cCnpj	:=	Value
Return

Method SetNumDoc(Value)	Class TABELACL1
	Self:cNumDoc	:=	Value
Return

Method SetNfTit(Value)	Class TABELACL1
	Self:cNumNfTit		:=	Value
Return

Method SetItem(Value)	Class TABELACL1
	Self:cItem	:=	Value
Return

Method SetIndPro(Value)	Class TABELACL1
	Self:cIndPro	:=	Value
Return

Method SetNumPro(Value)	Class TABELACL1
	Self:cNumPro	:=	Value
Return

Method SetSerie(Value)	Class TABELACL1
	Self:cSerie	:=	Value
Return

Method SetClieFor(Value)Class TABELACL1
	Self:cClieFor	:=	Value
Return

Method SetLoja(Value)	Class TABELACL1
	Self:cLoja	:=	Value
Return

Method SetTNatRec(Value)	Class TABELACL1
	Self:cTnatRec 	:= Value
Return

Method SetCNatRec(Value)	Class TABELACL1
	Self:cCNatRec 	:= Value
Return

Method SetGrupo(Value)	Class TABELACL1
	Self:cGrupo 	:= Value
Return

Method SetDtFim(Value)	Class TABELACL1
	Self:dtDtFim	:= Value
Return

Method SetQuantid(Value)	Class TABELACL1
	Self:nQuantid := Value
Return

Method SetIndRec(Value)	Class TABELACL1
	IF Value == 1
		Self:cIndRec:= '01'
	ElseiF Value == 2
		Self:cIndRec:= '03'
	ElseiF Value == 3
		Self:cIndRec:= '04'
	ElseiF Value == 4
		Self:cIndRec:= '05'	
	Else
		Self:cIndRec:= '03'		
	EndIF						

Return

Method getBase(ctributo)	Class TABELACL1
Return Iif(ctributo=='1',Self:nBasePis,Self:nBaseCof )

Method getAliq(ctributo)	Class TABELACL1
Return Iif(ctributo=='1',Self:nAlqPis,	Self:nAlqCof )

Method getValor(ctributo)Class TABELACL1
Return Iif(ctributo=='1',Self:nValPis,Self:nValCof )

Method getCst(ctributo) Class TABELACL1
Return Iif(ctributo=='1',Self:cCstPis,Self:cCstCof )

Method getNumDoc() Class TABELACL1
Return Self:cNumDoc

Method getSerie() Class TABELACL1
Return Self:cSerie

Method getClieFor() Class TABELACL1
Return Self:cClieFor

Method getLoja() Class TABELACL1
Return Self:cLoja

Method getTNatRec()	Class TABELACL1
Return Self:cTnatRec

Method getCNatRec()	Class TABELACL1
Return Self:cCNatRec

Method getConta() Class TABELACL1
Return Self:cConta

Method Save() Class TABELACL1

Local nPos	:= 0
Local cChave	:= ''

//A chave para F500/F510 será:
//CST Pis + CST COF + Alíquota PIS + Alíquota COf + Modelo + CFOP + Conta
cChave:=Self:cCstPis+Self:cCstCof+Str(Self:nAlqPis,8,4)+str(Self:nAlqCof,8,4)+padr(Self:cModelo,2)+padr(Self:cCfop,4)+padr(Self:cConta,60)

nPos:=aScan(Self:aRegCL1,{|aX| aX[1]==cChave .AND. aX[20] == Self:cTnatRec	 .AND. aX[21] == Self:cCNatRec .AND. ;
							        aX[22] == Self:cGrupo .AND. aX[23] == Self:dtDtFim })
If nPos == 0 
	//Adiciona

	aAdd(Self:aRegCL1, {})
	nPos := Len(Self:aRegCL1)
	aAdd (Self:aRegCL1[nPos], cChave					)	//01
	aAdd (Self:aRegCL1[nPos], Self:dPer				)	//02
	aAdd (Self:aRegCL1[nPos], Self:cCstPis				)	//03
	aAdd (Self:aRegCL1[nPos], Self:cCstCof				)	//04
	aAdd (Self:aRegCL1[nPos], Self:nAlqPis				)	//05
	aAdd (Self:aRegCL1[nPos], Self:nAlqCof				)	//06
	aAdd (Self:aRegCL1[nPos], padr(Self:cModelo,2)	)	//07
	aAdd (Self:aRegCL1[nPos], padr(Self:cCfop,4)		)	//08
	aAdd (Self:aRegCL1[nPos], Self:lPauta				)	//09
	aAdd (Self:aRegCL1[nPos], Self:nValRec				)	//10
	aAdd (Self:aRegCL1[nPos], Self:nDescPis			)	//11
	aAdd (Self:aRegCL1[nPos], Self:nBasePis			)	//12
	aAdd (Self:aRegCL1[nPos], Self:nValPis				)	//13
	aAdd (Self:aRegCL1[nPos], Self:nDescCof			)	//14
	aAdd (Self:aRegCL1[nPos], Self:nBaseCof			)	//15
	aAdd (Self:aRegCL1[nPos], Self:nValCof				)	//16
	aAdd (Self:aRegCL1[nPos], padr(Self:cConta,60)	)	//17
	aAdd (Self:aRegCL1[nPos], Self:cInfCom				)	//18	
	aAdd (Self:aRegCL1[nPos], Self:nQuantid			)	//19
	aAdd (Self:aRegCL1[nPos], Self:cTnatRec			)	//20
	aAdd (Self:aRegCL1[nPos], Self:cCNatRec			)	//21
	aAdd (Self:aRegCL1[nPos], Self:cGrupo				)	//22
	aAdd (Self:aRegCL1[nPos], Self:dtDtFim				)	//23
Else
	Self:aRegCL1[nPos][10]	+=	Self:nValRec
	Self:aRegCL1[nPos][11]	+=	Self:nDescPis		
	Self:aRegCL1[nPos][12]	+=	Self:nBasePis
	Self:aRegCL1[nPos][13]	+=	Self:nValPis
	Self:aRegCL1[nPos][14]	+=	Self:nDescCof
	Self:aRegCL1[nPos][15]	+=	Self:nBaseCof
	Self:aRegCL1[nPos][16]	+=	Self:nValCof
EndIF

//IRÁ AGRUPAR VALORES PARA PROCESSAR INFORMAÇÕES DO REGISTRO F525

nPos:=aScan(Self:aRegCL7,{|aX| aX[1]==Self:dPer .AND. aX[3] == Padr(Self:cCnpj,14) .AND. aX[4] == Padr(Self:cNumNfTit,60).AND. ;
							        aX[5] == Padr(Self:cItem,60) .AND. aX[7] == Self:cCstPis .AND. aX[8] == Self:cCstCof .AND.;
							        aX[10] == Padr(Self:cConta,60) .AND. aX[11] == Self:cIndRec})
If nPos == 0
	aAdd(Self:aRegCL7, {})
	nPos := Len(Self:aRegCL7)
	aAdd (Self:aRegCL7[nPos], Self:dPer				)	//01
	aAdd (Self:aRegCL7[nPos], 0							)	//02	
	aAdd (Self:aRegCL7[nPos], Self:cCnpj				)	//03
	aAdd (Self:aRegCL7[nPos], Self:cNumNfTit			)	//04
	aAdd (Self:aRegCL7[nPos], Self:cItem				)	//05	
	aAdd (Self:aRegCL7[nPos], Self:nValRec				)	//06
	aAdd (Self:aRegCL7[nPos], Self:cCstPis				)	//07 
	aAdd (Self:aRegCL7[nPos], Self:cCstCof				)	//08
	aAdd (Self:aRegCL7[nPos], Self:cInfCom				)	//09
	aAdd (Self:aRegCL7[nPos], Self:cConta				)	//10
	aAdd (Self:aRegCL7[nPos], Self:cIndRec				)	//11	
Else
	Self:aRegCL7[nPos][6]	+=	Self:nValRec
	
EndIF

//³Totaliza a Receita conforme o indicador de composição da receita³
Do Case 
	Case Self:cIndRec	 == '01' //CNPJ do cliente
		Self:aTotRec[1]	+=	Self:nValRec	
				
	Case Self:cIndRec	 == '03' 	//Numero do titulo/duplicata
		Self:aTotRec[3]	+=	Self:nValRec	
				
	Case Self:cIndRec	 == '04' //Numero do documento fiscal 		
		Self:aTotRec[4]	+=	Self:nValRec	
				
	Case Self:cIndRec	 == '05' //Produto/Servico 		
		Self:aTotRec[5]	+=	Self:nValRec
EndCase

//Self:Clear()

Return cChave

//-------------------------------------------------------------------
/*/{Protheus.doc} CalcCaixa
Método que irá calcular os valores de PIS e COFINS processados, para que
sejam calculados somente uma vez, assim atualizando tabela CL1 e gravando na
apuração.

@author Erick G. Dias
@since 25/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method CalcCaixa(oApurSai) Class TABELACL1

Local nX			:= 0
Local nReceita		:= 0
Local nTam_Cta     	:= TamSx3("CL7_CODCTA")[1] 
Local nTam_Doc      := TamSx3("CL7_NUMDOC")[1]
Local nTamCnpj		:= TamSx3("CL7_CNPJ")[1]
Local nTamItem		:= TamSx3("CL7_CDITEM")[1]
Local aCL7Agrup     := {}
Local nPosCL7Agr    := 0
Local cChvCL7       := ""

dbSelectArea('CL1')
CL1->(dbSetOrder(1))
dbSelectArea('CL7')
CL7->(dbSetOrder(1))

For nX	:= 1 to Len(Self:aRegCL1)

	//Receita
	Self:aRegCL1[nX][10]	:= Round(Self:aRegCL1[nX][10],2)
	//Base de PIS
	Self:aRegCL1[nX][12]	:= Round(Self:aRegCL1[nX][12],2)
	//Base COFINS
	Self:aRegCL1[nX][15]	:= Round(Self:aRegCL1[nX][15],2)
	//Valor do PIS
	Self:aRegCL1[nX][13]	:= Round(Self:aRegCL1[nX][12]*Self:aRegCL1[nX][5]/Iif(Self:aRegCL1[nX][9]=='0',100,1),2)
	//Valor da COFINS
	Self:aRegCL1[nX][16]	:= Round(Self:aRegCL1[nX][15]*Self:aRegCL1[nX][6]/Iif(Self:aRegCL1[nX][9]=='0',100,1),2)

	//FILIAL+PERÌODO+CHAVE
	If !CL1->(MSSEEK(Self:BuscaxFil('CL1')+dTos(Self:aRegCL1[nX][2])+Self:aRegCL1[nX][1]))
		RecLock('CL1',.T.)

		CL1->CL1_FILIAL	:=	Self:BuscaxFil('CL1')
		CL1->CL1_PER		:=	Self:aRegCL1[nX][2]
		CL1->CL1_ID		:=	Self:aRegCL1[nX][1]
		CL1->CL1_CSTPIS	:=	Self:aRegCL1[nX][3]
		CL1->CL1_CSTCOF	:=	Self:aRegCL1[nX][4]
		CL1->CL1_ALQPIS	:=	Self:aRegCL1[nX][5]
		CL1->CL1_ALQCOF	:=	Self:aRegCL1[nX][6]
		CL1->CL1_MOD		:=	Self:aRegCL1[nX][7]
		CL1->CL1_CFOP		:=	Self:aRegCL1[nX][8]
		CL1->CL1_PAUTA	:=	Self:aRegCL1[nX][9]
		CL1->CL1_VLREC	:=	Self:aRegCL1[nX][10]
		CL1->CL1_DSCPIS	:=	Self:aRegCL1[nX][11]
		CL1->CL1_BSEPIS	:=	Self:aRegCL1[nX][12]
		CL1->CL1_VLPIS	:=	Self:aRegCL1[nX][13]
		CL1->CL1_DSCCOF	:=	Self:aRegCL1[nX][14]
		CL1->CL1_BSECOF	:=	Self:aRegCL1[nX][15]
		CL1->CL1_VLCOF	:=	Self:aRegCL1[nX][16]
		CL1->CL1_CODCTA	:=	Self:aRegCL1[nX][17]
		If CL1->(FieldPos('CL1_FILAPU'))>0
			CL1->CL1_FILAPU	:=	Self:cFilApu
		EndIf	
		//CL1->CL1_INFCOM	:=	Self:aRegCL1[nX][18]
		MsUnLock()		
	Else
		RecLock('CL1',.F.)
		CL1->CL1_VLREC	+=	Self:aRegCL1[nX][10]
		CL1->CL1_DSCPIS	+=	Self:aRegCL1[nX][11]	
		CL1->CL1_BSEPIS	+=	Self:aRegCL1[nX][12]
		CL1->CL1_VLPIS	+=	Self:aRegCL1[nX][13]
		CL1->CL1_DSCCOF	+=	Self:aRegCL1[nX][14]
		CL1->CL1_BSECOF	+=	Self:aRegCL1[nX][15]
		CL1->CL1_VLCOF	+=	Self:aRegCL1[nX][16]
		MsUnLock()
	EndIF
	//------------------------------------------------
	//ATUALIZA OS VALORES DA CONTRIBUIÇÃO NA APURAÇÃO
	//------------------------------------------------

	oApurSai:setOrigem(Iif(EmpTy(AllTrim(Self:aRegCL1[nX][8])),'4','2')) //Outros
	oApurSai:SetRegime('2') //Regime de Caixa é sempre Cumulatiuvo			
	oApurSai:SetCFOP(	CL1->CL1_CFOP)				
	oApurSai:SetReceita(Self:aRegCL1[nX][10])
	oApurSai:SetTNatRec(Self:aRegCL1[nX][20])
	oApurSai:SetCNatRec(Self:aRegCL1[nX][21])		
	oApurSai:SetGNatRec(Self:aRegCL1[nX][22])
	oApurSai:SetDNatRec(CtOD( SUBSTR(Self:aRegCL1[nX][23],7,2) +'/'+ SUBSTR(Self:aRegCL1[nX][23],5,2) + '/' + SUBSTR(Self:aRegCL1[nX][23],1,4)))
	oApurSai:SetQtde(Self:aRegCL1[nX][19])
	oApurSai:SetOrigem('4') //Origem Financeiro

	//-------------------------------------------------------------------
	//Informações de PIS
	//-------------------------------------------------------------------			
	oApurSai:SetTributo('1')
	oApurSai:SetCST(CL1->CL1_CSTPIS)		
	oApurSai:SetAlqTrib(CL1->CL1_ALQPIS)
	oApurSai:SetBcTrib(Self:aRegCL1[nX][12])
	oApurSai:SetValTrib(Self:aRegCL1[nX][13])	
	oApurSai:SetBaseST(Self:aRegCL1[nX][12])
	oApurSai:SetValST(Self:aRegCL1[nX][13])
	oApurSai:SetConta(Self:aRegCL1[nX][17])
	oApurSai:SetAlqSt(CL1->CL1_ALQPIS)
	
	If CL1->CL1_PAUTA == '1'
		oApurSai:SetVlPauta(CL1->CL1_ALQPIS)
	EndIF
	oApurSai:AgrpContr()			

	//-------------------------------------------------------------------
	//Informações da COFINS
	//-------------------------------------------------------------------		
	oApurSai:SetTributo('2')		
	oApurSai:SetCST(CL1->CL1_CSTCOF)
	oApurSai:SetAlqTrib(CL1->CL1_ALQCOF)
	oApurSai:SetBcTrib(Self:aRegCL1[nX][15])
	oApurSai:SetValTrib(Self:aRegCL1[nX][16])
	oApurSai:SetBaseST(Self:aRegCL1[nX][15])
	oApurSai:SetValST(Self:aRegCL1[nX][16])
	oApurSai:SetConta(Self:aRegCL1[nX][17])
	oApurSai:SetAlqSt(CL1->CL1_ALQCOF)
	If CL1->CL1_PAUTA == '1'
		oApurSai:SetVlPauta(CL1->CL1_ALQCOF)
	EndIF
	oApurSai:AgrpContr()	

	oApurSai:GrvResCST(,"F")
	oApurSai:AcumRecBru(.T.)
	
Next nCont 

IF nX > 0
	oApurSai:Finaliza('1')
EndIF

//--------------------------------------
	//ATUALIZA OS VALORES PARA REGISTRO F525
//--------------------------------------

For nX	:= 1 to Len(Self:aRegCL7)

	nReceita:=0

	Do Case
		Case Self:aRegCL7[nX][11] == "01" 
			nReceita	:=	Self:aTotRec[1]			
		//³Agrupado por título/duplicata³
		Case Self:aRegCL7[nX][11] == "03" 	
			nReceita	:=	Self:aTotRec[3]					
		//³Agrupado por documento fiscal³
		Case Self:aRegCL7[nX][11] == "04" 		
			nReceita	:=	Self:aTotRec[4]					
		//³Agrupado por produto/serviço³
		Case Self:aRegCL7[nX][11] == "05" 		
			nReceita	:=	Self:aTotRec[5]					
		//Agrupado por Banco+agencia+conta (Juros de aplicação Financeira)
		Case Self:aRegCL7[nX][11] == "99" 		
			nReceita	:=	Self:aTotRec[7]
	EndCase

	// Faço a totalização dos valores no array aCL7Agrup ao invés de efetuar a gravação direto na tabela
	// para que não ocorra um arredondamento "involuntário" do valor no momento da gravação, ocasionando
	// diferença entre o F500 e o F525. A CL7 será gravada a partir do array já totalizado.

	// Concateno a chave que seria utilizada na CL7 para utilizar no aScan do array.
	cChvCL7 := Self:BuscaxFil('CL7')+dTos(Self:aRegCL7[nX][1])+PADR(Self:aRegCL7[nX][3],nTamCnpj)+PADR(Self:aRegCL7[nX][4],nTam_Doc) + ;
			   PADR(Self:aRegCL7[nX][5],nTamItem)+Self:aRegCL7[nX][7]+Self:aRegCL7[nX][8]+PADR(Self:aRegCL7[nX][10], nTam_Cta)       + ;
			   Self:aRegCL7[nX][11] 

	If (nPosCL7Agr := aScan(aCL7Agrup, {|x| x[1] == cChvCL7})) == 0
		aAdd(aCL7Agrup, {})
		nPosCL7Agr := Len(aCL7Agrup)
		aAdd(aCL7Agrup[nPosCL7Agr], cChvCL7)		
		aAdd(aCL7Agrup[nPosCL7Agr], Self:BuscaxFil('CL7'))
		aAdd(aCL7Agrup[nPosCL7Agr], Self:aRegCL7[nX][1])
		aAdd(aCL7Agrup[nPosCL7Agr], nReceita)
		aAdd(aCL7Agrup[nPosCL7Agr], Self:aRegCL7[nX][3])
		aAdd(aCL7Agrup[nPosCL7Agr], Self:aRegCL7[nX][4])
		aAdd(aCL7Agrup[nPosCL7Agr], Self:aRegCL7[nX][5])
		aAdd(aCL7Agrup[nPosCL7Agr], Self:aRegCL7[nX][6])
		aAdd(aCL7Agrup[nPosCL7Agr], Self:aRegCL7[nX][7])
		aAdd(aCL7Agrup[nPosCL7Agr], Self:aRegCL7[nX][8])
		aAdd(aCL7Agrup[nPosCL7Agr], Self:aRegCL7[nX][9])
		aAdd(aCL7Agrup[nPosCL7Agr], Self:aRegCL7[nX][10])
		aAdd(aCL7Agrup[nPosCL7Agr], Self:aRegCL7[nX][11])
		If CL7->(FieldPos('CL7_FILAPU'))>0
			aAdd(aCL7Agrup[nPosCL7Agr], Self:cFilApu)
		EndIf	
	Else
		aCL7Agrup[nPosCL7Agr, 8] += Self:aRegCL7[nX][6]
	EndIf

Next nX

// Gravação da CL7 - Com base no array já totalizado

For nX := 1 to Len(aCL7Agrup)

	If !CL7->(DBSEEK(aCL7Agrup[nX, 1]))		
		RecLock('CL7',.T.)	
		CL7->CL7_FILIAL	:= aCL7Agrup[nX, 2]
		CL7->CL7_PER	:= aCL7Agrup[nX, 3]
		CL7->CL7_VLREC	:= aCL7Agrup[nX, 4]
		CL7->CL7_CNPJ	:= aCL7Agrup[nX, 5]
		CL7->CL7_NUMDOC	:= aCL7Agrup[nX, 6]
		CL7->CL7_CDITEM	:= aCL7Agrup[nX, 7]
		CL7->CL7_VLRECD	:= aCL7Agrup[nX, 8]
		CL7->CL7_CSTPIS	:= aCL7Agrup[nX, 9]
		CL7->CL7_CSTCOF	:= aCL7Agrup[nX, 10]
		CL7->CL7_INFCOM	:= aCL7Agrup[nX, 11]
		CL7->CL7_CODCTA	:= aCL7Agrup[nX, 12]
		CL7->CL7_INDREC	:= aCL7Agrup[nX, 13]
		If CL7->(FieldPos('CL7_FILAPU'))>0
			CL7->CL7_FILAPU	:= aCL7Agrup[nX, 14]
		EndIf	
		MsUnLock()
	Else
		RecLock('CL7',.F.)
		CL7->CL7_VLRECD	+= aCL7Agrup[nX, 8]
		MsUnLock()
	EndIF

Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TABELACL2
Classe que será responsável por realizar a gravação na tabela CL2

@author Erick G. Dias
@since 27/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
CLASS TABELACL2 FROM EFDGEN

	//--------------------------------------------------------
	//Variáveis com os campos da tabela
	//--------------------------------------------------------
	Data dPer  		As Date	
	Data cID			As String
	Data cRegistro		As String
	Data cIndOp		As String
	Data cParti		As String	
	Data cItem			As String	
	Data dDtOper		As Date	
	Data nVlOper		As Integer	
	Data cCodBcc		As String	
	Data cIndCrd		As String	
	Data cIdBem		As String	
	Data cOriCrd		As String	
	Data cIdUti		As String	
	Data nVlEnca		As Integer	
	Data nVlParc		As Integer	
	Data nVlExcl		As Integer	
	Data cCstPis		As String	
	Data nBasePis		As Integer
	Data nAlqPis		As Integer	
	Data nValPis		As Integer	
	Data cCstCof		As String	
	Data nBaseCof		As Integer
	Data nAlqCof		As Integer	
	Data nValCof		As Integer	
	Data cCta			As String
	Data cCus			As string	
	Data cDescr		As string	
	Data cMesAno		As string	
	Data nVlAqui		As Integer	
	Data cIndPac		As string	
	Data cIndPro		As string	
	Data cNumPro		As string
	Data cPart			As string
	Data cAliasCl2	As string	
	Data lCl2Alias	as Boolean
	Data cNumTit		As string
	Data cPrefixo		As string
	Data cParcela		As string
	Data cRegime 		As String
	Data cIdCF8  		As String
	Data cCodAtf		As String
	Data cDescAtf		As String
	Data cCrtCred		As String
	Data cItemAtf		As String
	Data nTamID		as Integer
	Data cCliFor		as String
	Data cLoja			as String

	Method New()			
	Method Load()
	Method Insert()
	Method Clear()
	Method Save()
	Method SetParam(cCampo,Value)
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método Construtor da Classe 

@author Erick G. Dias
@since 27/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD New() Class TABELACL2

Self:dPer		:= CTod("  /  /    ")
Self:nTamId	:= TamSx3("CL2_ID")[1]
Self:IniHash()
Self:Clear()

Return  Self

Method Clear() Class TABELACL2

Self:cID			:= ''
Self:cIndOp		:= ''
Self:cParti		:= ''	
Self:cItem			:= ''	
Self:dDtOper		:= CTod("  /  /    ")	
Self:nVlOper		:= 0	
Self:cCodBcc		:= ''	
Self:cIndCrd		:= ''	
Self:cIdBem		:= ''	
Self:cOriCrd		:= ''	
Self:cIdUti		:= ''	
Self:nVlEnca		:= 0	
Self:nVlParc		:= 0	
Self:nVlExcl		:= 0	
Self:cCstPis		:= ''	
Self:nBasePis		:= 0
Self:nAlqPis		:= 0	
Self:nValPis		:= 0	
Self:cCstCof		:= ''	
Self:nBaseCof		:= 0
Self:nAlqCof		:= 0	
Self:nValCof		:= 0	
Self:cCta			:= ''
Self:cCus			:= ''	
Self:cDescr		:= ''	
Self:cMesAno		:= ''	
Self:nVlAqui		:= 0	
Self:cIndPac		:= ''	
Self:cIndPro		:= ''	
Self:cNumPro		:= ''	
Self:cPart			:= ''
Self:cConsl		:= '2'
Self:cAliasCl2	:= ''
Self:lCl2Alias	:= CL2->(FieldPos('CL2_ALIAS')) > 0
Self:cFilApu		:= ''
Self:cNumTit		:= ''
Self:cPrefixo		:= ''
Self:cParcela		:= ''
Self:cRegime 		:= ''
Self:cIdCF8  		:= ''
Self:cCodAtf		:= ''
Self:cDescAtf		:= ''
Self:cCrtCred		:= ''
Self:cItemAtf		:= ''
Self:cCliFor		:= ''
Self:cLoja			:= ''


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetParam()
Método que irá alimentar os parâmetro com as informações que deverão ser gravadas
na tabela 

@author Erick G. Dias
@since 27/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method SetParam(cCampo,Value) Class TABELACL2
	
Do Case		
	Case cCampo == 'CL2_PER'
		Self:dPer	:= Value
	Case cCampo == 'CL2_REG'
		Self:cRegistro	:= Value
	Case cCampo == 'CL2_INDOP'
		Self:cIndOp	:= Value
	Case cCampo == 'CL2_PARTI'
		Self:cParti	:= Value
	Case cCampo == 'CL2_ITEM'	
		Self:cItem	:= Value
	Case cCampo == 'CL2_DTOPER'
		Self:dDtOper	:= Value
	Case cCampo == 'CL2_VLOPER'
		Self:nVlOper	:= Value
	Case cCampo == 'CL2_CODBCC'	
		Self:cCodBcc	:= Value
	Case cCampo == 'CL2_INDCRD'
		Self:cIndCrd	:= Value
	Case cCampo == 'CL2_IDBEM'
		Self:cIdBem	:= Value
	Case cCampo == 'CL2_ORICRD'	
		Self:cOriCrd	:= Value
	Case cCampo == 'CL2_IDUTI'
		Self:cIdUti	:= Value
	Case cCampo == 'CL2_VLENCA'
		Self:nVlEnca	:= Value
	Case cCampo == 'CL2_VLPARC'	
		Self:nVlParc	:= Value
	Case cCampo == 'CL2_VLEXCL'
		Self:nVlExcl	:= Value
	Case cCampo == 'CL2_CSTPIS'
		Self:cCstPis	:= Value
	Case cCampo == 'CL2_BCPIS'	
		Self:nBasePis	:= Value
	Case cCampo == 'CL2_ALQPIS'
		Self:nAlqPis	:= Value
	Case cCampo == 'CL2_VLPIS'
		Self:nValPis	:= Value
	Case cCampo == 'CL2_CSTCOF'	
		Self:cCstCof	:= Value
	Case cCampo == 'CL2_BCCOF'
		Self:nBaseCof	:= Value
	Case cCampo == 'CL2_ALQCOF'
		Self:nAlqCof	:= Value
	Case cCampo == 'CL2_VLCOF'	
		Self:nValCof	:= Value
	Case cCampo == 'CL2_CTA'
		Self:cCta	:= Value
	Case cCampo == 'CL2_CCUS'
		Self:cCus	:= Value
	Case cCampo == 'CL2_DESCR'	
		Self:cDescr	:= Value
	Case cCampo == 'CL2_MESANO'
		Self:cMesAno	:= Value
	Case cCampo == 'CL2_VLAQUI'
		Self:nVlAqui	:= Value
	Case cCampo == 'CL2_INDPAC'	
		Self:cIndPac	:= Value
	Case cCampo == 'CL2_INDPRO'
		Self:cIndPro	:= Value
	Case cCampo == 'CL2_NUMPRO'
		Self:cNumPro	:= Value
	Case cCampo == 'CL2_PART'
		Self:cPart	:= Value
	Case cCampo == 'CL2_ALIAS'
		Self:cAliasCl2 := Value		
	Case cCampo == 'CL2_FILAPU'
		Self:cFilApu := Value		
	Case cCampo == 'CL2_NUMTIT'
		Self:cNumTit := Value	
	Case cCampo == 'CL2_PREFIX'
		Self:cPrefixo := Value	
	Case cCampo == 'CL2_PARC'
		Self:cParcela := Value	
	Case cCampo == 'CL2_IDCF8'
		Self:cIdCF8 := Value	
	Case cCampo == 'CL2_REGIME'
		Self:cRegime := Value
	Case cCampo == 'CL2_CODATF'
		Self:cCodAtf := Value
	Case cCampo == 'CL2_DESATF'
		Self:cDescAtf := Value
	Case cCampo == 'CL2_CRTCRD'
		Self:cCrtCred := Value
	Case cCampo == 'CL2_ITATF'
		Self:cItemAtf := Value
	Case cCampo == 'CL2_CLIFOR'
		Self:cCliFor := Value
	Case cCampo == 'CL2_LOJA'
		Self:cLoja := Value		
		
EndCase

Return

Method Save() Class TABELACL2


dbSelectArea('CL2')
CL2->(dbSetOrder(1))

RecLock('CL2',.T.)
CL2->CL2_FILIAL	:=	Self:BuscaxFil('CL2')
If Self:nTamId == 36	
	CL2->CL2_ID		:=	FWUUID('CL2')	
Else
	CL2->CL2_ID		:=	GetSXENum('CL2','CL2_ID')
EndIF
CL2->CL2_PER		:=	Self:dPer
CL2->CL2_REG		:=	Self:cRegistro
CL2->CL2_INDOP	:=	Self:cIndOp
CL2->CL2_PARTI	:=	Self:cParti
CL2->CL2_ITEM		:=	Self:cItem
CL2->CL2_DTOPER	:=	Self:dDtOper
CL2->CL2_VLOPER	:=	Self:nVlOper
CL2->CL2_CODBCC	:=	Self:cCodBcc
CL2->CL2_INDCRD	:=	Self:cIndCrd
CL2->CL2_IDBEM	:=	Self:cIdBem
CL2->CL2_ORICRD	:=	Self:cOriCrd
CL2->CL2_IDUTI	:=	Self:cIdUti
CL2->CL2_VLENCA	:=	Self:nVlEnca
CL2->CL2_VLPARC	:=	Self:nVlParc
CL2->CL2_VLEXCL	:=	Self:nVlExcl
CL2->CL2_CSTPIS	:=	Self:cCstPis
CL2->CL2_BCPIS	:=	Self:nBasePis
CL2->CL2_ALQPIS	:=	Self:nAlqPis
CL2->CL2_VLPIS	:=	Self:nValPis
CL2->CL2_CSTCOF	:=	Self:cCstCof
CL2->CL2_BCCOF	:=	Self:nBaseCof
CL2->CL2_ALQCOF	:=	Self:nAlqCof
CL2->CL2_VLCOF	:=	Self:nValCof
CL2->CL2_CTA		:=	Self:cCta
CL2->CL2_CCUS		:=	Self:cCus
CL2->CL2_DESCR	:=	Self:cDescr
CL2->CL2_MESANO	:=	Self:cMesAno
CL2->CL2_VLAQUI	:=	Self:nVlAqui
CL2->CL2_INDPAC	:=	Self:cIndPac
CL2->CL2_INDPRO	:=	Self:cIndPro
CL2->CL2_NUMPRO	:=	Self:cNumPro
CL2->CL2_PART		:=	Self:cPart

If Self:lCl2Alias
	CL2->CL2_ALIAS		:=	Self:cAliasCl2
EndIF
If CL2->(FieldPos('CL2_FILAPU'))>0
	CL2->CL2_FILAPU	:=	Self:cFilApu
EndIf	
If CL2->(FieldPos('CL2_NUMTIT'))>0 .AND. CL2->(FieldPos('CL2_PREFIX'))>0 .AND. ;
	CL2->(FieldPos('CL2_PARC'))>0 .AND. CL2->(FieldPos('CL2_IDCF8'))>0 .AND. CL2->(FieldPos('CL2_REGIME'))>0

	CL2->CL2_NUMTIT		:=	Self:cNumTit
	CL2->CL2_PREFIX		:=	Self:cPrefixo
	CL2->CL2_PARC			:=	Self:cParcela
	CL2->CL2_IDCF8		:=	Self:cIdCF8
	CL2->CL2_REGIME		:=	Self:cRegime
	
EndIF

If CL2->(FieldPos('CL2_CODATF'))>0 .AND. CL2->(FieldPos('CL2_DESATF'))>0 .AND. CL2->(FieldPos('CL2_CRTCRD'))>0 .AND. CL2->(FieldPos('CL2_ITATF'))>0
	CL2->CL2_CODATF		:=	Self:cCodAtf
	CL2->CL2_DESATF		:=	Self:cDescAtf
	CL2->CL2_CRTCRD		:=	Self:cCrtCred	
	CL2->CL2_ITATF		:=	Self:cItemAtf
EndIF
//Gravação do código do cliente/fornecedor e loja em campos separados
If CL2->(FieldPos('CL2_CLIFOR'))>0 .AND. CL2->(FieldPos('CL2_LOJA'))>0
	CL2->CL2_CLIFOR		:=	Self:cCliFor
	CL2->CL2_LOJA		:=	Self:cLoja
EndIF

CL2->(MsUnLock())
If Self:nTamId <> 36
	ConfirmSX8()
EndIf

Self:Clear()

Return



//-------------------------------------------------------------------
/*/{Protheus.doc} TABELACKY
Classe que será responsável por realizar a gravação na tabela CKY

@author Erick G. Dias
@since 27/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
CLASS TABELACKY FROM EFDGEN

	//--------------------------------------------------------
	//Variáveis com os campos da tabela
	//--------------------------------------------------------

	Data aCKY		As Array
	Data cChvTab	As String
	Data dPer		As Date
	Data dDtRet	As Data
	Data cId		As String
	Data cIndRet	As String
	Data cCodRec	As String	
	Data cIndRec	As String
	Data cCnpj		As String	
	Data cOrigem	As String
	Data nBase		As Integer
	Data nTotRet	As Integer
	Data nPisRet	As Integer
	Data nCofRet	As Integer
	Data cIndCon	As Integer
	Data cNumTit	As String
	Data cPrefixo	As String
	Data cParcela	As String
	Data dDataEmis	As Date
	Data cRotinaOri As String
	Data nTamId	As INteger
	
	Method New()
	Method Insert()
	Method Clear()
	Method Save()
	Method SetParam(cCampo,Value)
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método Construtor da Classe 

@author Erick G. Dias
@since 16/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
METHOD New() Class TABELACKY
Self:nTamId = TamSx3("CKY_ID")[1] 
Self:IniHash() 
Self:Clear()

Return  Self

Method Clear() Class TABELACKY

Self:aCKY		:={}
Self:cChvTab	:= ''
Self:dPer		:=CTod("  /  /    ")
Self:dDtRet	:=CTod("  /  /    ")
Self:cId		:= ''
Self:cIndRet	:= ''
Self:cCodRec	:= ''	
Self:cIndRec	:= ''
Self:cCnpj		:= ''
Self:cConsl	:= '2'
Self:cOrigem	:= '9'
Self:nBase		:= 0
Self:nTotRet	:= 0
Self:nPisRet	:= 0
Self:nCofRet	:= 0
Self:cIndCon	:= 0
Self:cFilApu	:= ''
Self:cNumTit	:= ''
Self:cPrefixo	:= ''
Self:cParcela	:= ''
Self:dDataEmis	:=CTod("  /  /    ")
Self:cRotinaOri	:= ''

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetParam()
Método que irá alimentar os parâmetro com as informações que deverão ser gravadas
na tabela 

@author Erick G. Dias
@since 16/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Method SetParam(cCampo,Value) Class TABELACKY

Do Case		
	Case cCampo == 'CKY_PER'
		Self:dPer		:= Value		
	Case cCampo == 'CKY_INDRET'
		Self:cIndRet	:= Value
	Case cCampo == 'CKY_DTRET'
		Self:dDtRet := Value
	Case cCampo == 'CKY_CODREC'
		Self:cCodRec	:= Value		
	Case cCampo == 'CKY_INDREC'
		Self:cIndRec	:= Value
	Case cCampo == 'CKY_CNPJ'
		Self:cCnpj		:= Value
	Case cCampo == 'CKY_BASE'
		Self:nBase	:= Value
	Case cCampo == 'CKY_TOTRET'
		Self:nTotRet	:= Value		
	Case cCampo == 'CKY_PISRET'
		Self:nPisRet	:= Value
	Case cCampo == 'CKY_COFRET'
		Self:nCofRet	:= Value
	Case cCampo == 'CKY_INDCON'
		Self:cIndCon	:= Value		
	Case cCampo == 'CKY_FILAPU'
		Self:cFilApu	:= Value
	Case cCampo == 'CKY_NUMTIT' 
		Self:cNumTit	:= Value	
	Case cCampo == 'CKY_PREFIX' 
		Self:cPrefixo	:= Value	
	Case cCampo == 'CKY_PARC' 
		Self:cParcela	:= Value	
	Case cCampo == 'CKY_DTEMIS' 
		Self:dDataEmis	:= Value	
	Case cCampo == 'CKY_ORIG' 
		Self:cRotinaOri	:= Value
EndCase

Return

Method Save() Class TABELACKY

dbSelectArea('CKY')
CKY->(dbSetOrder(1))

RecLock('CKY',.T.)
CKY->CKY_FILIAL	:=	Self:BuscaxFil('CKY')
CKY->CKY_PER		:=	Self:dPer

If Self:nTamId == 36	
	CKY->CKY_ID		:=	FWUUID('CKY')	
Else
	CKY->CKY_ID		:=	GetSXENum('CKY','CKY_ID')
EndIF

CKY->CKY_INDRET	:=	Self:cIndRet
CKY->CKY_DTRET	:=	Self:dDtRet
CKY->CKY_CODREC	:=	Self:cCodRec
CKY->CKY_INDREC	:=	Self:cIndRec
CKY->CKY_CNPJ		:=	Self:cCnpj
CKY->CKY_BASE		:=	Self:nBase
CKY->CKY_TOTRET	:=	Self:nTotRet
CKY->CKY_PISRET	:=	Self:nPisRet
CKY->CKY_COFRET	:=	Self:nCofRet
CKY->CKY_INDCON	:=	Self:cIndCon
If CKY->(FieldPos('CKY_FILAPU'))>0
	CKY->CKY_FILAPU	:=	Self:cFilApu 
Endif
If CKY->(FieldPos('CKY_NUMTIT'))>0 .AND. CKY->(FieldPos('CKY_PREFIX'))>0 .AND. CKY->(FieldPos('CKY_PARC'))>0 .AND. ;
	CKY->(FieldPos('CKY_DTEMIS'))>0 .AND. CKY->(FieldPos('CKY_ORIG'))>0

	CKY->CKY_NUMTIT	:=	Self:cNumTit
	CKY->CKY_PREFIX	:=	Self:cPrefixo
	CKY->CKY_PARC		:=	Self:cParcela
	CKY->CKY_DTEMIS	:=	Self:dDataEmis
	CKY->CKY_ORIG		:=	Self:cRotinaOri
EndIF

MsUnLock()
If Self:nTamId <> 36
	ConfirmSX8()
EndIF
Self:Clear()

Return


////-----------------



//-------------------------------------------------------------------
/*/{Protheus.doc} TABELAF07
Classe que será responsável por realizar a gravação na tabela F07

@author Erick G. Dias
@since 24/09/2015
@version 11.80
/*/
//-------------------------------------------------------------------
CLASS TABELAF07 FROM EFDGEN

//--------------------------------------------------------
//Variáveis com os campos da tabela
//--------------------------------------------------------
Data dPer  	As Date
Data cId		As String
Data cIndPro	As string
Data cNumPro	As String
Data cIndAut	As String
Data cIdItem	As String
Data aRegF07	As Array
	
Method New()			
Method Clear()
Method Save()
Method GravaF07()

Method SetPer(Value)
Method SetId(Value)
Method SetNumPro(Value)
Method SetIndPro(Value)
Method SetIndAut(Value)
Method SetIdItem(Value)
	
ENDCLASS


METHOD New() Class TABELAF07

Self:aRegF07	:= {}
Self:dPer  	:= CTod("  /  /    ")
Self:IniHash()
Self:Clear()

Return  Self

Method Clear() Class TABELAF07

Self:cIndPro 	:= ''
Self:cNumPro	:= ''
Self:cIndAut	:= ''
Self:ciditem	:= ''
Self:cId		:= ''
Self:cConsl	:= '2'

Return

Method SetPer(Value)	Class TABELAF07
	Self:dPer	:=	Value
Return

Method SetId(Value)	Class TABELAF07
	Self:cId	:=	Value
Return

Method SetNumPro(Value)	Class TABELAF07
	Self:cNumPro	:=	Value
Return

Method SetIndPro(Value)	Class TABELAF07
	Self:cIndPro	:=	Value
Return

Method SetIndAut(Value)	Class TABELAF07
	Self:cIndAut	:=	Value
Return

Method SetIdItem(Value)	Class TABELAF07
	Self:cIdItem	:=	Value
Return

Method Save() Class TABELAF07

Local nPos	:= 0

nPos:=aScan(Self:aRegF07,{|aX| aX[1]==Self:cId .AND. aX[2] == Self:dPer .AND. aX[3] == Self:cNumPro .AND. ;
							        aX[4] == Self:cIndPro .AND. aX[5] == Self:cIndAut .AND. aX[6] == Self:cIdItem})
If nPos == 0 
	//Adiciona
	aAdd(Self:aRegF07, {})
	nPos := Len(Self:aRegF07)
	aAdd (Self:aRegF07[nPos], Self:cId					)	//01
	aAdd (Self:aRegF07[nPos], Self:dPer				)	//02
	aAdd (Self:aRegF07[nPos], Self:cNumPro				)	//03
	aAdd (Self:aRegF07[nPos], Self:cIndPro				)	//04
	aAdd (Self:aRegF07[nPos], Self:cIndAut				)	//05
	aAdd (Self:aRegF07[nPos], Self:cIdItem				)	//06		
EndIF

//Se já existir não será adicionado

Self:Clear()

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaF07
Método que irá gravar informações na tabela F07 de processo referenciado

@author Erick G. Dias
@since 24/09/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Method GravaF07() Class TABELAF07
Local nX		:= 0
Local lIndAut	:= F07->(FieldPos("F07_INDAUT"))>0

dbSelectArea('F07')
F07->(dbSetOrder(1))

For nX	:= 1 to Len(Self:aRegF07)

	//"F07_FILIAL+DTOS(F07_PER)+F07_ID+F07_INDPRO+F07_NUMPRO
	If !F07->(MSSEEK(Self:BuscaxFil('F07')+dTos(Self:aRegF07[nX][2])+Self:aRegF07[nX][1]+Self:aRegF07[nX][4]+Self:aRegF07[nX][3]+Self:aRegF07[nX][5]+Self:aRegF07[nX][6]))
		RecLock('F07',.T.)

		F07->F07_FILIAL	:=	Self:BuscaxFil('F07')
		F07->F07_PER		:=	Self:aRegF07[nX][2]
		F07->F07_ID		:=	Self:aRegF07[nX][1]
		F07->F07_NUMPRO	:=	Self:aRegF07[nX][3]
		F07->F07_INDPRO	:=	Self:aRegF07[nX][4]
		
		If lIndAut
			F07->F07_INDAUT	:=	Self:aRegF07[nX][5]
			F07->F07_IDITEM	:=	Self:aRegF07[nX][6]		
		EndIF

		MsUnLock()		

	EndIF
	
	
Next nX 


Return
//-------------------------------------------------------------------
/*/{Protheus.doc} isAgrIndust
Método que identifica se a operação está enquadrada nas regras de
agroindustria, visando a geração dos códigos 106,206 e 306 no
Bloco M.

@author Luccas Curcio
@since 24/03/2016
@version 11.80
/*/
//-------------------------------------------------------------------
method isAgrIndust() Class FISX001

local	lRet	:=	.F.

if Self:cCst $ '64|65|66' .and. len( Self:aNcmInsumPres ) > 0
	lRet	:=	.T.
endif

return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} cfgParamPres
Método utilizada para configurar as propriedades utilizadas na identificação
de uma operação de agroindustria.

@author Luccas Curcio
@since 24/03/2016
@version 11.80
/*/
//-------------------------------------------------------------------
method cfgParamPres( aMvSpcXCp1 )  Class FISX001

Self:aNcmInsumPres	:=	aMvSpcXCp1//&( GetNewPar( "MV_SPCXCP1" , "{}" ) ) //NCM dos produtos adquiridos como insumos das receitas classificadas como crédito presumido.

return
//-------------------------------------------------------------------
/*/{Protheus.doc} GetF0X
Método utilizado para montar as strings de consulta na tabela F0X
@author Henrique Pereira
@since 23/06/2016
@version 11.80
/*/
//-------------------------------------------------------------------
method GetF0X(dDataDe) Class FISX001
Local cPeriodo 	:= cvaltochar(strzero(month(dDataDe),2)) + cvaltochar(year(dDataDe ))

	Self:cSlctF0X :=	"%F0X.*%"
	Self:cFromF0X	:=	"%"+RetSqlName("F0X")+" F0X %"
	Self:cWhereF0X	:=	"%F0X.F0X_FILIAL='"+xFilial("F0X")+"' AND "
	Self:cWhereF0X	+=	"F0X.F0X_PERIOD='"+cPeriodo+"' AND "
	Self:cWhereF0X	+=	"F0X.D_E_L_E_T_=''%"

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} RetCodRec
Função que retorna o código da receita a ser utilizado nos registros
M205 e M605.

@author Erick G Dias
@since 31/05/2016
/*/
//-------------------------------------------------------------------
Static Function RetCodRec()
Local cMVCODREC:= GetNewPar("MV_CDRCEC","{'','','',''}")
Local aRetCod:= {}

If !Empty(cMVCODREC) .And. Left(cMVCODREC,1)=="{" .And. SubStr(cMVCODREC,Len(cMVCODREC),1)=="}" .And. Len(&(cMVCODREC))==4
	aRetCod	:=	&(cMVCODREC)
Else
	aRetCod	:=	{'','','',''}
EndIf
Return aRetCod



//-------------------------------------------------------------------
/*/{Protheus.doc} TABELAF0T
Classe que será responsável por realizar a gravação na tabela F07

@author Erick G. Dias
@since 24/09/2015
@version 11.80
/*/
//-------------------------------------------------------------------
CLASS TABELAF0T FROM EFDGEN

//--------------------------------------------------------
//Variáveis com os campos da tabela
//--------------------------------------------------------
Data dPer	     As Date
Data cFilOrig	  As String
Data cTipo	     As String
Data cNumNf	 As String
Data cSerie  	 As String
Data dEmissao	 As Date
Data dReceb	 As Date
Data cCFOP		 As String
Data cItem		 As String
Data cModelo	 As String
Data cNumTit	 As String
Data cPrefixo	 As String
Data cParcela	 As String
Data cIdCF8	 As String
Data nPercRecb As Integer
Data nValCont  As Integer
Data cCStPis   As String
Data cCStCof   As String
Data nBasePis  As Integer
Data nBaseCof  As Integer
Data nAlqPis   As Integer
Data nAlqCof   As Integer
Data nValPis   As Integer
Data nValCof   As Integer
Data nExclCPRB As Integer
Data cCodAtiv  As String
Data nBaseCPRB As Integer
Data nAlqCPRB  As Integer
Data nVAlCPRB  As Integer
Data nRecDif   As Integer
Data nValRec   As Integer
Data nValExc   As Integer
Data cCodBlcI  As Integer
Data lF0T	   As Boolean
Data lF0tCnpj  As Boolean
Data cCnpj     As Boolean

Method New()			
Method Clear()
Method SetValue(cCampo,Value)
Method Grava()

ENDCLASS



METHOD New() Class TABELAF0T

Self:IniHash()
Self:Clear()
Self:lF0T 		:= AliasINdic('F0T')
Self:lF0tCnpj 	:= Self:lF0T .AND. F0T->(FieldPos("F0T_CNPJ")) > 0 
Return  Self

Method Clear() Class TABELAF0T

Self:dPer	     := CTod("  /  /    ")
Self:dEmissao	 := CTod("  /  /    ")
Self:dReceb	 := CTod("  /  /    ")
Self:cTipo	     := ''
Self:cNumNf	 := ''
Self:cSerie  	 := ''
Self:cCFOP		 := ''
Self:cItem		 := ''
Self:cModelo	 := ''
Self:cNumTit	 := ''
Self:cPrefixo	 := ''
Self:cParcela	 := ''
Self:cIdCF8	 := ''
Self:cCStPis   := ''
Self:cCStCof   := ''
Self:cCodAtiv  := ''
Self:cFilOrig	 := ''
Self:nPercRecb := 0
Self:nValCont  := 0
Self:nBasePis  := 0
Self:nBaseCof  := 0
Self:nAlqPis   := 0
Self:nAlqCof   := 0
Self:nValPis   := 0
Self:nValCof   := 0
Self:nExclCPRB := 0
Self:nBaseCPRB := 0
Self:nAlqCPRB  := 0
Self:nVAlCPRB  := 0
Self:nRecDif   := 0
Self:nValRec	 := 0
Self:nValExc	 := 0
Self:cCodBlcI	 := ''
Self:cCnpj	 	:= ''
Return

Method SetValue(cCampo,Value) Class TABELAF0T
	
Do Case		
	Case cCampo == 'F0T_PER'
		Self:dPer	:= Value	
	Case cCampo == 'F0T_TIPO'
		Self:cTipo	:= Value	
	Case cCampo == 'F0T_NUMNF'
		Self:cNumNf:= Value	
	Case cCampo == 'F0T_SER'
		Self:cSerie:= Value				
	Case cCampo == 'F0T_DTEMI'
		Self:dEmissao	:= Value	
	Case cCampo == 'F0T_DTRECB'
		Self:dReceb:= Value	
	Case cCampo == 'F0T_CFOP'
		Self:cCFOP	:= Value
	Case cCampo == 'F0T_ITEM'
		Self:cItem	:= Value	
	Case cCampo == 'F0T_MODELO'
		Self:cModelo:= Value
	Case cCampo == 'F0T_NUMTIT'
		Self:cNumTit:= Value	
	Case cCampo == 'F0T_PREFIX'
		Self:cPrefixo	:= Value	
	Case cCampo == 'F0T_PARC'
		Self:cParcela	:= Value	
	Case cCampo == 'F0T_IDCF8'
		Self:cIdCF8:= Value	
	Case cCampo == 'F0T_PERREC'
		Self:nPercRecb:= Value	
	Case cCampo == 'F0T_VLCONT'
		Self:nValCont	:= Value	
	Case cCampo == 'F0T_CSTPIS'
		Self:cCStPis:= Value	
	Case cCampo == 'F0T_BASPIS'
		Self:nBasePis	:= Value	
	Case cCampo == 'F0T_ALQPIS'
		Self:nAlqPis	:= Value	
	Case cCampo == 'F0T_VALPIS'
		Self:nValPis	:= Value	
	Case cCampo == 'F0T_CSTCOF'	
		Self:cCStCof	:= Value		
	Case cCampo == 'F0T_BASCOF'	
		Self:nBaseCof	:= Value	
	Case cCampo == 'F0T_ALQCOF'	
		Self:nAlqCof	:= Value	
	Case cCampo == 'F0T_VALCOF'
		Self:nValCof	:= Value	
	Case cCampo == 'F0T_EXCPRB'
		Self:nExclCPRB:= Value	
	Case cCampo == 'F0T_BCCPRB'
		Self:nBaseCPRB	:= Value
	Case cCampo == 'F0T_AQCPRB'
		Self:nAlqCPRB	:= Value	
	Case cCampo == 'F0T_VLCPRB'
		Self:nVAlCPRB	:= Value	
	Case cCampo == 'F0T_RECDIF'
		Self:nRecDif	:= Value	
	Case cCampo == 'F0T_VALREC'
		Self:nValRec	:= Value
	Case cCampo == 'F0T_CODATV'
		Self:cCodAtiv	:= Value	
	Case cCampo == 'F0T_FILAPU'
		Self:cFilOrig	:= Value
	Case cCampo == 'F0T_CDBLCI'
		Self:cCodBlcI	:= Value
	Case cCampo == 'F0T_IFEXCL'
		Self:nValExc	:= Value
	Case cCampo == 'F0T_CNPJ'
		Self:cCnpj	:= Value				
	
EndCase

Return

Method Grava() Class TABELAF0T
IF Self:lF0T
	RecLock('F0T',.T.)
	F0T->F0T_FILIAL		:=	xFilial("F0T")
	F0T->F0T_FILAPU		:=	Self:cFilOrig
	F0T->F0T_PER		:=	Self:dPer
	F0T->F0T_CHAVE		:=	FWUUID('F0T')
	F0T->F0T_TIPO  		:=	Self:cTipo
	F0T->F0T_NUMNF  	:=	Self:cNumNf
	F0T->F0T_SER  		:=	Self:cSerie
	F0T->F0T_DTEMI  	:=	Self:dEmissao
	F0T->F0T_DTRECB  	:=	Self:dReceb
	F0T->F0T_CFOP  		:=	Self:cCFOP
	F0T->F0T_ITEM  		:=	Self:cItem
	F0T->F0T_MODELO  	:=	Self:cModelo
	F0T->F0T_NUMTIT  	:=	Self:cNumTit
	F0T->F0T_PREFIX  	:=	Self:cPrefixo
	F0T->F0T_PARC  		:=	Self:cParcela
	F0T->F0T_IDCF8  	:=	Self:cIdCF8
	F0T->F0T_PERREC  	:=	Self:nPercRecb
	F0T->F0T_VLCONT  	:=	Self:nValCont
	F0T->F0T_CSTPIS  	:=	Self:cCStPis
	F0T->F0T_BASPIS  	:=	Self:nBasePis
	F0T->F0T_ALQPIS  	:=	Self:nAlqPis
	F0T->F0T_VALPIS  	:=	Self:nValPis
	F0T->F0T_CSTCOF  	:=	Self:cCStCof
	F0T->F0T_BASCOF  	:=	Self:nBaseCof
	F0T->F0T_ALQCOF  	:=	Self:nAlqCof
	F0T->F0T_VALCOF  	:=	Self:nValCof
	F0T->F0T_EXCPRB  	:=	Self:nExclCPRB
	F0T->F0T_BCCPRB  	:=	Self:nBaseCPRB
	F0T->F0T_AQCPRB  	:=	Self:nAlqCPRB
	F0T->F0T_VLCPRB  	:=	Self:nVAlCPRB
	F0T->F0T_RECDIF  	:=	Self:nRecDif
	F0T->F0T_VALREC  	:=	Self:nValRec
	F0T->F0T_CODATV  	:=	Self:cCodAtiv
	F0T->F0T_CDBLCI  	:=	Self:cCodBlcI
	F0T->F0T_IFEXCL  	:=	Self:nValExc
	IF Self:lF0tCnpj
		F0T->F0T_CNPJ  	:=	Self:cCnpj
	EndIF
	MsUnLock()
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DelFilApu()
Funcao para excluir os registros cujo campo _FILAPU esteja em branco,
pois estes registros nao sao excluidos pelos meios normais.

@author joao.pellegrini
@since 08/08/2016
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function DelFilApu(cTabela, cPeriodo,lConsol) 

Local cAliasTab := ''
Local cSelect := ''
Local cWhere := ''
Local cFrom := ''

Default lConsol := .F.

cSelect := "R_E_C_N_O_ as NRECNO "

If lConsol
	cSelect += ", "+cTabela+"_CONSOL "
Endif

cWhere := cTabela + "_FILIAL = '"+ xFilial(cTabela)+ "' AND "
cWhere += cTabela + "_PER = '" + cPeriodo + "' AND "
cWhere += cTabela + "_FILAPU = ' ' AND "
cWhere += "D_E_L_E_T_ = ' ' "

cFrom := RetSqlName(cTabela)

cSelect := "%" + cSelect + "%"
cFrom   := "%" + cFrom + "%"
cWhere  := "%" + cWhere + "%"

cAliasTab	:=	GetNextAlias()

BeginSql Alias cAliasTab
    	
	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%	
	WHERE
		%Exp:cWhere%

EndSql

Do While !(cAliasTab)->(EOF())
	(cTabela)->(dbGoto((cAliasTab)->NRECNO))		
	RecLock(cTabela,.F.)
	(cTabela)->(dbDelete())
	MsUnLock()
	(cTabela)->(FKCommit())
	(cAliasTab)->(DBSKIP())
EndDo		

DbSelectArea (cAliasTab)
(cAliasTab)->(DbCloseArea ())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TABELACE9
Classe responsavel por disponibilizar os dados da tabela CE9 p/
utilizacao no processamento.

@author joao.pellegrini
@since 28/10/2016
@version 11.80
/*/
//-------------------------------------------------------------------
CLASS TABELACE9 FROM EFDGEN

DATA aDados   as Array HIDDEN
DATA cPeriodo	 as String
DATA cCodDC	 as String
DATA cTrib    as String

Method New()
Method Clear()
Method LoadData()
Method GetExclusao(cCodDC, nBase, nAliq)

// Getters / Setters

Method setPeriodo(value)
Method setCodDC(value)
Method setAliq(value)
Method setTributo(value)

ENDCLASS
Method setPeriodo(value) Class TABELACE9
	Self:cPeriodo := value
Return NIL

Method setCodDC(value) Class TABELACE9
	Self:cCodDC := value
Return NIL

Method setTributo(value) Class TABELACE9
	Self:cTrib := value
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Metodo construtor da classe TABELACE9.

@author joao.pellegrini
@since 28/10/2016
@version 11.80
/*/
//-------------------------------------------------------------------
Method New() Class TABELACE9

Self:IniHash()
Self:Clear()

Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadData()
Metodo responsavel por limpar os atributos do objeto da classe TABELACE9

@author joao.pellegrini
@since 28/10/2016
@version 11.80
/*/
//-------------------------------------------------------------------
Method Clear() Class TABELACE9

Self:aDados := {}
Self:cPeriodo := ""
Self:cCodDC := ""
Self:cTrib := ""

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadData()
Metodo responsavel por consultar a tabela CE9 do periodo e mapea-la no
array Self:aDados para posterior utilizacao.

@author joao.pellegrini
@since 28/10/2016
@version 11.80
/*/
//-------------------------------------------------------------------
Method LoadData() Class TABELACE9

Local cAliasCE9 := ""
Local cSelect := ""
Local cFrom := ""
Local cWhere := ""
Local nPos := 0

cSelect := "CE9_FILIAL, CE9_PER, CE9_CODIGO, CE9_ALQPIS, CE9_ALQCOF, CE9_EXGPIS, CE9_EXEPIS, CE9_EXGCOF, CE9_EXECOF "			 

cFrom := RetSQLName("CE9") + " CE9 "

cWhere := "CE9_FILIAL = '" + xFilial("CE9") + "' AND "
cWhere += "CE9_PER = '" + Self:cPeriodo + "' AND "
cWhere += "D_E_L_E_T_ = ' ' "

cSelect := "%" + cSelect + "%"
cFrom := "%" + cFrom + "%"
cWhere := "%" + cWhere + "%"

cAliasCE9 := GetNextAlias()

BeginSQL Alias cAliasCE9

SELECT
	%Exp:cSelect%
FROM
	%Exp:cFrom%
WHERE
	%Exp:cWhere%
EndSQL

dbSelectArea(cAliasCE9)
(cAliasCE9)->(DbGoTop())

While !(cAliasCE9)->(Eof())				
	
	aAdd(Self:aDados, {})
	nPos := Len(Self:aDados)
	aAdd(Self:aDados[nPos], (cAliasCE9)->CE9_FILIAL)
	aAdd(Self:aDados[nPos], (cAliasCE9)->CE9_PER)
	aAdd(Self:aDados[nPos], (cAliasCE9)->CE9_CODIGO)
	aAdd(Self:aDados[nPos], (cAliasCE9)->CE9_ALQPIS)
	aAdd(Self:aDados[nPos], (cAliasCE9)->CE9_ALQCOF)
	aAdd(Self:aDados[nPos], (cAliasCE9)->(CE9_EXGPIS + CE9_EXEPIS))
	aAdd(Self:aDados[nPos], (cAliasCE9)->(CE9_EXGCOF + CE9_EXECOF))

	(cAliasCE9)->(dbSkip())

EndDo

(cAliasCE9)->(dbCloseArea())

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GetExclusao()
Metodo responsavel por retornar o valor de exclusao de SCP, conforme
cadastrado na tabela CE9. 

@author joao.pellegrini
@since 28/10/2016
@version 11.80
/*/
//-------------------------------------------------------------------
Method GetExclusao(cCodDC, nBase, nAliq) Class TABELACE9

Local nPos := 0
Local nValExcl := 0

If Self:cTrib == "PIS"
	nPos := aScan(Self:aDados, {|aX| AllTrim(aX[3]) == AllTrim(cCodDC) .And. aX[4] == nAliq})
ElseIf Self:cTrib == "COF"
	nPos := aScan(Self:aDados, {|aX| AllTrim(aX[3]) == AllTrim(cCodDC) .And. aX[5] == nAliq})
EndIf

If nPos > 0		
	If Self:cTrib == "PIS"
		
		If Self:aDados[nPos,6] > 0
		
			nValExcl := Self:aDados[nPos,6]
			
			If nBase >= nValExcl 		 
				Self:aDados[nPos,6] := 0 			
			Else
				nValExcl := nBase
				Self:aDados[nPos,6] -= nValExcl		
			EndIf
			
		EndIf
		
	ElseIf Self:cTrib == "COF"
	 
	 	If Self:aDados[nPos,7] > 0
	 
			nValExcl := Self:aDados[nPos,7]
			
			If nBase >= nValExcl
				Self:aDados[nPos,7] := 0
			Else
				nValExcl := nBase
				Self:aDados[nPos,7] -= nValExcl			
			EndIf
			
		EndIf
		 
	EndIf		
EndIf

Return nValExcl

//-------------------------------------------------------------------
/*/{Protheus.doc} RatCredDif()N
Função que fará o rateio dos créditos diferidos em todos os registros 
M230/M630 de cada CNPJ de órgão público.

@author Erick G Dias
@since 16/08/2018
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function RatCredDif(aTribDif, aCFA, aCnpj, nCrdDifTot, cCodCrd, nTotCrdDif, cOp)

Local nContDeb		:= 0
Local nCrdDIf		:= 0
Local nPos			:= 0

If cOp == '1' //Rateio
	For nContDeb	:= 1 to len(aTribDif)
					
		nCrdDIf	:= round((nCrdDifTot * aTribDif[nContDeb][4] / 100),2)				
		
		//Adiciona linha na CFA com cmbinação CNPJ+CODCON+CodCred
		nPos:=aScan(aCFA,{|aX| aX[1]==aTribDif[nContDeb][1] .AND. aX[2]==aTribDif[nContDeb][2] .AND. aX[3]==cCodCrd  })
		
		IF nCrdDIf < nTotCrdDif
			//Pode utilizar normalmente
			nTotCrdDif -= nCrdDIf
		Else
			//Neste caso por conta de arredondamento ficou maior, vai utilizar o crédito até o limite
			nCrdDIf	    := nTotCrdDif
			nTotCrdDif	:= 0
		EndIF

		IF nPos == 0
			aAdd(aCFA, {})
			nPos := Len(aCFA)
			aAdd (aCFA[nPos], aTribDif[nContDeb][1]) //CNPJ
			aAdd (aCFA[nPos], aTribDif[nContDeb][2]) //CODCON
			aAdd (aCFA[nPos], cCodCrd) //CODCRED
			aAdd (aCFA[nPos], Iif(nCrdDIf > 0, nCrdDIf, aTribDif[nContDeb][3] ) ) //valor do crédito
			aAdd (aCFA[nPos], 0 ) // total do crédito
		Else
			aCFA[nPos][4] += nCrdDIf		
		EndIF

		nPos:=aScan(aCnpj,{|aX| aX[1]==aTribDif[nContDeb][1] })		
		IF nPos == 0
			aAdd(aCnpj, {})
			nPos := Len(aCnpj)
			aAdd (aCnpj[nPos], aTribDif[nContDeb][1]) //CNPJ
			aAdd (aCnpj[nPos], Iif(nCrdDIf > 0, nCrdDIf, aTribDif[nContDeb][3] ) ) //valor do crédito
		Else
			aCnpj[nPos][2] += nCrdDIf  //valor do crédito
		EndIF
		
	Next nContDeb

Else
	//Jogará a diferença de centavos no último CNPJ
	For nContDeb	:= 1 to len(aTribDif)
		IF aTribDif[nContDeb][4] > 0

			//Adiciona linha na CFA com cmbinação CNPJ+CODCON+CodCred
			nPos:=aScan(aCFA,{|aX| aX[1]==aTribDif[nContDeb][1] .AND.  aX[2]==aTribDif[nContDeb][2] .AND. aX[3]==cCodCrd })

			IF nPos == 0
				aAdd(aCFA, {})
				nPos := Len(aCFA)
				aAdd (aCFA[nPos], aTribDif[nContDeb][1]) //CNPJ
				aAdd (aCFA[nPos], aTribDif[nContDeb][2]) //CODCON
				aAdd (aCFA[nPos], cCodCrd) //CODCRED
				aAdd (aCFA[nPos], nCrdDifTot ) //valor do crédito
				aAdd (aCFA[nPos], 0 ) // total do crédito
											
			Else
				aCFA[nPos][4] += nCrdDifTot	//valor do crédito
			EndIF

			nPos:=aScan(aCnpj,{|aX| aX[1]==aTribDif[nContDeb][1] })		
			IF nPos == 0
				aAdd(aCnpj, {})
				nPos := Len(aCnpj)
				aAdd (aCnpj[nPos], aTribDif[nContDeb][1]) //CNPJ
				aAdd (aCnpj[nPos], nCrdDifTot)  //valor do crédito

			Else
				aCnpj[nPos][2] += nCrdDifTot  //valor do crédito
			EndIF
			Exit

		EndIF
	Next nContDeb

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} X001GRVF3P()
Função que realiza a gravação da tabela F3P.

@author Erick G Dias
@since 14/12/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function X001GRVF3P(a1050, dPeriodo, cConsol)

Local nX	:= 0

If AliasIndic("F3P") //Verifica se existe tabela criada no ambiente

	dbSelectArea('F3P')
	F3P->(dbSetOrder(1))

	For nX	:= 1 to Len(a1050)	

		If !F3P->(MSSEEK(xFilial("F3P") + dTos(dPeriodo) + a1050[nX][1] + a1050[nX][2] + a1050[nX][15] + a1050[nX][19] + cConsol ))	
			//Se registro não existir na tabela F3P será incluído
			RecLock('F3P',.T.)
			F3P->F3P_FILIAL		:= xFilial("F3P")
			F3P->F3P_PER   		:= dPeriodo
			F3P->F3P_CONSOL   	:= cConsol
			F3P->F3P_CODAJU   	:= a1050[nX][1]
			F3P->F3P_CNPJ    	:= a1050[nX][2]
			F3P->F3P_INDAP     	:= a1050[nX][15]
			F3P->F3P_RECIBO     := a1050[nX][16]
			F3P->F3P_INFCOM     := a1050[nX][17]
			F3P->F3P_VALICM  	:= a1050[nX][18]
			F3P->F3P_REGIME  	:= a1050[nX][19]
			If F3P->(FieldPos("F3P_AJMANU")) > 0
                F3P->F3P_AJMANU := "2"
            EndIf
		Else
			RecLock("F3P", .F.)
		EndIF

		
		//Atualiza os valores do registro 1050
		F3P->F3P_TOTAJU	+= a1050[nX][3]
		F3P->F3P_CST01  += a1050[nX][4]
		F3P->F3P_CST02  += a1050[nX][5]
		F3P->F3P_CST03  += a1050[nX][6]
		F3P->F3P_CST04  += a1050[nX][7]
		F3P->F3P_CST05  += a1050[nX][8]
		F3P->F3P_CST06  += a1050[nX][9]
		F3P->F3P_CST07  += a1050[nX][10]
		F3P->F3P_CST08  += a1050[nX][11]
		F3P->F3P_CST09  += a1050[nX][12]
		F3P->F3P_CST49  += a1050[nX][13]
		F3P->F3P_CST99  += a1050[nX][14]		
		

		MsUnLock()

	Next nX

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} X001GRVF3O()
Função que realiza a gravação da tabela F3O.

@author Erick G Dias
@since 17/12/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function X001GRVF3O(aRecBloco, dPeriodo, cConsol, cMetodo)
Local nX		:= 0
Local nX	:= 0

If AliasIndic("F3O") //Verifica se existe tabela criada no ambiente

	dbSelectArea('F3O')
	F3O->(dbSetOrder(1)) //F3O_FILIAL+DTOS(F3O_PER)+F3O_CST+F3O_CONSOL                                                                                                                     

	For nX	:= 1 to Len(aRecBloco)
		If !F3O->(MSSEEK(xFilial("F3O") + dTos(dPeriodo) + aRecBloco[nX][1]+aRecBloco[nX][3]+cConsol))
			//Se registro não existir na tabela F3O será incluído
			RecLock('F3O',.T.)
			F3O->F3O_FILIAL		:= xFilial("F3O")
			F3O->F3O_PER      	:= dPeriodo
			F3O->F3O_CONSOL   	:= cConsol
			F3O->F3O_CST      	:= aRecBloco[nX][1]
			F3O->F3O_RECBA      := aRecBloco[nX][4]
			F3O->F3O_RECBC      := aRecBloco[nX][5]
			F3O->F3O_RECBD      := aRecBloco[nX][6]
			F3O->F3O_RECBF      := aRecBloco[nX][7]
			F3O->F3O_RECBCD     := F3O->F3O_RECBC + F3O->F3O_RECBD
			F3O->F3O_TOTREC     := F3O->F3O_RECBA + F3O->F3O_RECBC + F3O->F3O_RECBD + F3O->F3O_RECBF
			F3O->F3O_PERCD      := aRecBloco[nX][8]
			F3O->F3O_REGIME     := aRecBloco[nX][3]
			F3O->F3O_METODO     := cMetodo
		Else
			RecLock('F3O',.F.)
			F3O->F3O_RECBA      += aRecBloco[nX][4]
			F3O->F3O_RECBC      += aRecBloco[nX][5]
			F3O->F3O_RECBD      += aRecBloco[nX][6]
			F3O->F3O_RECBF      += aRecBloco[nX][7]
			F3O->F3O_RECBCD     := F3O->F3O_RECBC + F3O->F3O_RECBD
			F3O->F3O_TOTREC     := F3O->F3O_RECBA + F3O->F3O_RECBC + F3O->F3O_RECBD + F3O->F3O_RECBF		
			F3O->F3O_PERCD      += aRecBloco[nX][8]			
		EndIF
		MsUnLock()

	Next nX

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} X001ATUF3O()
Função que realiza a atualização da tabela F3O para Multthread.

@author Rafael Oliveira
@since 08/06/2021
@version 12.1.27
/*/
//-------------------------------------------------------------------
Function X001ATUF3O(aParSX1)
Local nX         := 0
Local cChave     := ""
Local nPercRec   := 0
Local nDiv       := 0
Local nTotRecCD  := 0
Local nTotBlocos := 0
Local aAreaF3O 	 := {}

If AliasIndic("F3O") //Verifica se existe tabela criada no ambiente
	
	cChave	:= xFilial("F3O") + dTos(FirstDate(aParSX1[1]))

	dbSelectArea('F3O')
	F3O->(dbSetOrder(1)) //F3O_FILIAL+DTOS(F3O_PER)+F3O_CST+F3O_REGIME+F3O_CONSOL	
	
	IF F3O->(MSSEEK(cChave))
		aAreaF3O 	 := F3O->(GetArea())
		
		//Soma receita
		While cChave == F3O->F3O_FILIAL	+ DtoS(F3O->F3O_PER)
			nTotRecCD  += F3O->F3O_TOTREC
			nTotBlocos += F3O->F3O_RECBCD
			F3O->(dBskip())
		Enddo
		//Volta para Inicio							
		F3O->(RestArea(aAreaF3O))

		//Divide pelos CST
		nPercRec	:= 100
		While cChave == F3O->F3O_FILIAL	+ DtoS(F3O->F3O_PER) 			

			IF aParSX1[23] == 1
				nDiv := Round(((F3O->F3O_TOTREC) / nTotBlocos) * 100, 8)
			Elseif aParSX1[23] == 2
				nDiv := Round(((F3O->F3O_RECBCD) / nTotRecCD) * 100, 8)
			Endif

			If nDiv < nPercRec
				nPercRec -= nDiv
			Else
				nDiv := nPercRec
				nPercRec	:= 0 
			EndIF

			RecLock('F3O',.F.)			

			F3O->F3O_PERCD := nDiv			

			MsUnLock()

			F3O->(dBskip())
		Enddo
			
		
	Endif
	

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x001GrvCIE()
Função que realiza a gravação da tabela F3O.

@author Erick G Dias
@since 17/12/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function x001GrvCIE(aExigiSusp, dPerApur)

Local nPos	:= 0

dbSelectArea('CIE')
CIE->(dbSetOrder(1)) 

//Laço no array para gravar a tabela CIE
For nPos := 1 to Len(aExigiSusp)

	If !CIE->(MSSEEK(xFilial("CIE")       + ; //CIE_FILIAL
				     dTos(dPerApur)       + ; //DTOS(CIE_PER)
					 aExigiSusp[nPos][1]  + ; //CIE_DOC
					 aExigiSusp[nPos][2]  + ; //CIE_SERIE
					 aExigiSusp[nPos][3]  + ; //CIE_PART
					 aExigiSusp[nPos][4]  + ; //CIE_LOJA					 
					 aExigiSusp[nPos][8]  + ; //CIE_ITEMNF					 
					 aExigiSusp[nPos][5]  + ; //CIE_PROCES
					 aExigiSusp[nPos][6]  + ; //CIE_TIPOPR
					 aExigiSusp[nPos][31] + ; //CIE_INDAUT
					 aExigiSusp[nPos][29] + ; //CIE_IDITEM					 
					 aExigiSusp[nPos][7]  )) //CIE_NATJU					 

		RecLock('CIE',.T.)
		CIE->CIE_FILIAL		:= xFilial("CIE")
		CIE->CIE_PER   		:= dPerApur		
		CIE->CIE_DOC  		:= aExigiSusp[nPos][1] //Número do documento fiscla 
		CIE->CIE_SERIE 		:= aExigiSusp[nPos][2] //Série
		CIE->CIE_PART  		:= aExigiSusp[nPos][3] //Participante
		CIE->CIE_LOJA  		:= aExigiSusp[nPos][4] //Loja		
		CIE->CIE_PROCES 	:= aExigiSusp[nPos][5] //Número do processo
		CIE->CIE_TIPOPR 	:= aExigiSusp[nPos][6] //Tipo do processo
		CIE->CIE_NATJU  	:= aExigiSusp[nPos][7] //Natureja do processo
		CIE->CIE_ITEM  		:= aExigiSusp[nPos][8] //Item da nota fiscal
		CIE->CIE_DTOPER		:= aExigiSusp[nPos][9]  //Data da operação
		CIE->CIE_VLOPER		:= aExigiSusp[nPos][10] //Valor da operação
		CIE->CIE_CPIS    	:= aExigiSusp[nPos][11] //CST do pis escriturado
		CIE->CIE_BPIS  		:= aExigiSusp[nPos][12] //Base do pis escriturado
		CIE->CIE_APIS  		:= aExigiSusp[nPos][13] //Alíquota do PIS escriturado
		CIE->CIE_VPIS    	:= aExigiSusp[nPos][14]	//Valor do pis escriturado
		CIE->CIE_CCOF    	:= aExigiSusp[nPos][15] //CST da Cofins escriturado
		CIE->CIE_BCOF  		:= aExigiSusp[nPos][16] //Base da Cofins escriturado
		CIE->CIE_ACOF  		:= aExigiSusp[nPos][17] //Alíquota da Cofins escriturada
		CIE->CIE_VCOF    	:= aExigiSusp[nPos][18]	//Valor da Cofins esritudado
		CIE->CIE_CPISSU  	:= aExigiSusp[nPos][19] //CST do PIS Suspenso
		CIE->CIE_BPISSU		:= aExigiSusp[nPos][20] //Base do PIS Suspenso
		CIE->CIE_APISSU  	:= aExigiSusp[nPos][21] //Alíquita do PIS Suspenso
		CIE->CIE_VPISSU  	:= aExigiSusp[nPos][22] //Valor do PIS Suspenso
		CIE->CIE_CCOFSU  	:= aExigiSusp[nPos][23] //CST Cofins Suspenso
		CIE->CIE_BCOFSU		:= aExigiSusp[nPos][24] //Base Cofins Suspenso
		CIE->CIE_ACOFSU  	:= aExigiSusp[nPos][25] //Alíquota Cofins Suspenso
		CIE->CIE_VCOFSU  	:= aExigiSusp[nPos][26]	//Valor Cofins Suspenso
		CIE->CIE_CODPIS  	:= aExigiSusp[nPos][27]	//Código de Receita PIS conforme DCTF
		CIE->CIE_CODCOF  	:= aExigiSusp[nPos][28]	//Código de Receita COFINS conforme DCTF
		CIE->CIE_IDITEM		:= aExigiSusp[nPos][29]	//Item do Processo
		CIE->CIE_CHVCL1		:= aExigiSusp[nPos][30]	//Chave da CL1 no processamento do regime de caixa
		CIE->CIE_INDAUT		:= aExigiSusp[nPos][31]	//indicador de autoria do processo		
		MsUnLock()	
	Else
		//Acumula os valores.
		RecLock('CIE',.F.)
		CIE->CIE_VLOPER		+= aExigiSusp[nPos][10] //Valor da operação		
		CIE->CIE_BPIS  		+= aExigiSusp[nPos][12] //Base do PIS Escriturado		
		CIE->CIE_VPIS    	+= aExigiSusp[nPos][14] //Valor do PIS			
		CIE->CIE_BCOF  		+= aExigiSusp[nPos][16]	//BAse da COFINS	
		CIE->CIE_VCOF    	+= aExigiSusp[nPos][18]	//Valor da COFINS		
		CIE->CIE_BPISSU		+= aExigiSusp[nPos][20]	//Base do PIS Suspenso	
		CIE->CIE_VPISSU  	+= aExigiSusp[nPos][22] //Valor do PIS Suspenso
		CIE->CIE_BCOFSU		+= aExigiSusp[nPos][24]	//Base da Cofins Suspenso			
		CIE->CIE_VCOFSU  	+= aExigiSusp[nPos][26]	//Valor da COfins suspenso	
		MsUnLock()
	EndIF

Next nPos

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CNOxCPRB()
Método que irá agrupar os valores da CPRBxCNO , para que sejam 
gravados posteriormente na tabela F3Z.

@author Matheus Prada
@since 04/10/2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
METHOD CNOxCPRB() Class CPRBEFD

IF !EmpTy(Self:cCodAtiv)
	Self:oF3Z:SetConsol(Self:cConsl)
	Self:oF3Z:SetParam('F3Z_PER'		,Self:dDtRef		)
	Self:oF3Z:SetParam('F3Z_CODATI'		,Self:cCodAtiv		)
	Self:oF3Z:SetParam('F3Z_VLBRUT'		,Self:nVlBrut		)
	Self:oF3Z:SetParam('F3Z_VLATI'		,Self:nVlAtivi		)
	Self:oF3Z:SetParam('F3Z_EXCLU'		,Self:nVlExclu		)
	Self:oF3Z:SetParam('F3Z_BASE'		,Self:nBaseCalc		)
	Self:oF3Z:SetParam('F3Z_ALIQ'		,Self:nAliquota		)
	Self:oF3Z:SetParam('F3Z_VLCPRB'		,Self:nVAlCPRB		)
	Self:oF3Z:SetParam('F3Z_CONTA'		,Self:cConta		)
	Self:oF3Z:SetParam('F3Z_FILAPU'		,Self:cFilApu		)
	Self:oF3Z:SetParam('F3Z_CNO'		,Self:cCNO	)
	Self:oF3Z:Insert()
Endif

Self:Clear()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} A001DIATHR
 
Função que irá fazer divisão dos dias para cada Thread, considendo
período passado e número de Threads passada.   

@return array com data inicial e final que cada Thread deverá processar.
@author Erick G. Dias
@since 12/08/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Function A001DIATHR(nThread,dtIni, dtFin)
Local nRestoDia		:= 0
Local nCont			:= 0
Local nDiasThread	:= 0
Local nDiaAux		:= 0
Local nTotDias		:= (dtFin - dtIni) + 1
Local dtI			:= dtIni			
Local dtF			:= dtIni
Local aPer			:= {}

	If nThread <= nTotDias  
		
		For nCont := 1 to nTotDias
			If mod(nTotDias,nThread) == 0
				//Divisão exata
				nDiasThread	:= nTotDias/nThread
				exit		
			Else
				nRestoDia++
				nTotDias -=1					
			EndIF
		
		Next nCont
		
	Else
		//O NÚMERO DE THREAD SERÁ O MESMO QUE A QUANTIDADE DE DIA.
		nThread := nTotDias
		nDiasThread	:= 1
	EndIF

	For nCont := 1 to nThread
		
		nDiaAux := 0
		If nRestoDia > 0
			nDiaAux := 1
			nRestoDia -= 1		
		EndIF
		dtI	:= dtI
		dtF	:= dtI + (nDiasThread-1) + nDiaAux	

		AADD(aPer,{dtI,dtF})
		dtI	:=  dtF + 1
		
	Next nCont

Return aPer

//-------------------------------------------------------------------
/*/{Protheus.doc} FechaAlias()
Método que fecha area do alias pasasdo. 

@author Thiago Y.M.N - Shiny
@since 26/03/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Method FechaAlias(cAliasProc) Class CPRBEFD
	DbSelectArea (cAliasProc)
	(cAliasProc)->(DbCloseArea ())
Return




