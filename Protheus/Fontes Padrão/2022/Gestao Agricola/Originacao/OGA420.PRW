#include "OGA420.ch"
#Include "Protheus.ch"
#include "Totvs.ch"
#include "Fwmvcdef.ch"
#include "Rwmake.ch"

#DEFINE MOEDAPERCENTUAL 0

Static oTela	:= nil
Static __lAutomato   := IiF(IsBlind(),.T.,.F.)

/** {Protheus.doc} OGA420
Rotina para Manutenção Composição de Preço
@param:		cCtrato	-	Nr. do Contrato
cProduto 	-	Codigo do produto
dDtfixa 	-	Data da Fixação
dDEntrIni 	-	Data Inicial de Entrega
dDEntrFim 	-	Data Final de Entrega
nQtfixar 	-	Qtidade a Fixar
cTpCtr		-	Tipo do Contrato
cNJRUM1PRO	-	Unidade de Medida do Produto do Ctrato.
cNjrUmPrc	- 	Unidade de Preço do produto do Contrato
nNJRMoeda	-	Moeda do Ctrato
aComPreco	-	aRRay com dados da NKA, (Qdo ja existir fixação esse array deve estar preenchido
lEditar	-	Logico contendo .f. ou .t. Indicando se permite fazer alterações na fixação, qdo já existir. 	
@Retorno: 	array com dados para gravação da composicao de Preço tabela NKA
@author: 	Equipe AgroIndustria
@since: 	08/06/2010
@Uso: 		SIGAARM - Originação de Grãos
*/
Function OGA420( cCtrato , cProduto , dDtfixa , dDEntrIni , dDEntrFim , nQtfixar , cNk7Aplica , cNjrUm1Pro , cNjrUmPrc , nNjrMoeda , aCompreco , lEditar, nTipMer, cMoeda, cSafra, cGrupo, nTaxCon, cTpFix, cItFxOrg)
	Local lContinua			:= .t.
	Local cUm1Preco         := ''

	Default cCtrato 		:= '' //000320
	Default cProduto 		:= '' //SOJACOM
	Default dDtFixa  		:= cToD('03/10/2014')
	Default dDEntrIni		:= cToD('25/01/2014')
	Default dDEntrFim		:= cToD('10/02/2015')
	Default nQtFixar    	:= 100000 // Baseado na 1a Unidade de medida do Produto (Segundo Marlon)
	Default cNk7Aplica  	:= 'V' //Ambos
	Default cNJRUM1pro  	:= ''//'KG'
	Default cNjrUmPrc   	:= ''//'S6'
	Default nNjrMoeda   	:= 0//1	
	Default aCompreco     	:= {}
	Default lEditar     	:= .t.
	Default nTipMer         := 1
	Default nTaxCon         := 0
	Default cMoeda			:= 1
	Default cSafra			:= ""
	Default cGrupo			:= ""
   	Default cTpFix	 		:= '1'  //tipo de fixação --> 0=Prevista, 1=Firme, 2=Basis) //DAGROGAP-1445
	Default cItFxOrg 		:= '000' //item da fixação DE ORIGEM //DAGROGAP-1445
	
	Private oFontAta  		:= TFont():New("Arial",,16,,.F.,,,,,.F.)
	Private aMargem    		:= {}
	Private aButtons 		:= {}	
	Private lEhOGA460		:= IsInCallStack('OGA460')	
	Private __lTemMargem    := .F.	
	Private __lCallPV       := IsInCallStack("OGAA880") //Se foi chamado pelo plano de vendas


	/*/--<< Composicao do Array aCcompPrc, aMargem>>--
	1=NK8_CODCOM 
	2=NK8_ITEMCO
	3=NK8_CODIDX
	4=Descricao Componente 
	5=Moeda do Componente 
	6=Indice Multiplicador de conversao entre Moeda/Indice e Moeda/Ctrato(TxaCtaca) 
	7=UM (NK8_UM1PRO) 
	8=Vr_Indice 
	9=VrCompor 
	10=R$/SC ( Moeda do Ctrato,B5_UMPRC) 
	11=R$/KG ( Moeda do Ctrato,B1_UM_UM  				) 
	12=Qt Convertida da UM do Indice Para UM (B5_UMPRC)
	13=Qt Convertida da UM do Indice Para UM (B1_1aUM)
	14=Tp Calc ( NK7_CALCUL )
	15=Coluna Para ordenacao do Array Cfe solicitacao sempre aparecer na ordem Preco,Custo,Informativo,M
	16=Tp Componente N=Normal , M=Margem ( NK7_UTILIZ )
	/*/
	
	//--<< Titulo das Colunas do Browse >>--	
	Private  cCol1tit      	:= 	AllTrim( RetTitle("NKA_CODCOM") ) 	//"Componente"
	Private  cCol2tit      	:=	AllTrim( RetTitle("NK8_MOEDA") )	//"Moeda"
	Private  cCol3tit      	:=	AllTrim( RetTitle("NKA_TXACOT") ) 	//"Cotacao"
	Private  cCol4tit      	:=	'UM.'								//AllTrim( RetTitle("NK8_UM1PRO") )	//"Unidade"
	Private  cCol5tit      	:=	AllTrim( RetTitle("NKA_VLRIDX") )	//"Valor Índice"
	Private  cCol6tit      	:=	AllTrim( RetTitle("NKA_VLRCOM") )	//"Valor Compon."
	Private  cCol7tit      	:=	"" 									// Será Abastecida na Função MntQryComp
	Private  cCol8tit      	:=	"" 									// Será Abastecida na Função MntQryComp

	Private aGrvNKA     	:= {}
	Private nVrPMarg 		:= 0  									//--<< Percentual de Margem em % >>-
	Private aUMNaoConv 		:= {} 									// Array Utilizado na verificação de Conversão de Unidades de Medidas.
	Private _nDecCasas		:= TamSx3('NJM_VLRUNI')[2]   	// O nr de decimais de arredontamento para o resoltado de composicao de preco em UN/UMPR deve seguir o Campo D1_VUNT
    Private _nDecLoc		:= TamSx3('NN8_VLRUNI')[2]
	
	
	// -- Quando chamada pela rotina OGA460
	// -- Tratamento Para Declarar as Variaveis Private --
	If lEhOGA460 .and. ! Type("oBrwComp") == "O" 
		_SetNamedPrvt( "nQtidade" 	, nil , "OGA460" )
		_SetNamedPrvt( "c1aUmProd" 	, nil , "OGA460" )
		_SetNamedPrvt( "nPrcCalc1" 	, nil , "OGA460" )
		_SetNamedPrvt( "nPrcCalc2"	, nil , "OGA460" )
		_SetNamedPrvt( "nVrMarg1"	, nil , "OGA460" )
		_SetNamedPrvt( "nVrMarg2"	, nil , "OGA460" )
		_SetNamedPrvt( "nPrcProp1"	, nil , "OGA460" )
		_SetNamedPrvt( "nPrcProp2"	, nil , "OGA460" )
		_SetNamedPrvt( "nSalMarg1"	, nil , "OGA460" )
		_SetNamedPrvt( "nSalMarg2"	, nil , "OGA460" )
		_SetNamedPrvt( "nTotCalc"	, nil , "OGA460" )
		_SetNamedPrvt( "nTotProp"	, nil , "OGA460" )
		_SetNamedPrvt( "lEdit"		, nil , "OGA460" )
		_SetNamedPrvt( "nTratoMoed" , nil , "OGA460" )

		//------- Vars que n. sao dos Gets ----
		_SetNamedPrvt( "aCompPrc"	, nil , "OGA460" )
		_SetNamedPrvt( "oBrwComp"	, nil , "OGA460" )
		_SetNamedPrvt( "dDt_aFixar"	, nil , "OGA460" )
		_SetNamedPrvt( "cUmPreco"	, nil , "OGA460" )
		_SetNamedPrvt( "c1aUmProd"	, nil , "OGA460" )
		_SetNamedPrvt( "cProdCmp"	, nil , "OGA460" )
        _SetNamedPrvt( "nTMerComp"  , nil , "OGA460" )
        _SetNamedPrvt( "nMoedComp"  , nil , "OGA460" )
		_SetNamedPrvt( "cMoedComp"  , nil , "OGA460" )
		
	
	// -- Quando chamado por outras rotinas
	ElseIF !lEhOGA460 .and. ! Type("oBrwComp") == "O"

		Private nQtidade  	:= 0
		Private c1aUmProd 	:= ""
		Private cUmPreco	:= ""
		
		//--<< Variaveis dos Gets (Rodape)>>--
		Private nPrcCalc1 	:= 0
		Private nPrcCalc2 	:= 0
		Private nVrMarg1	:= 0
		Private nVrMarg2	:= 0
		Private nPrcProp1	:= 0
		Private nPrcProp2	:= 0
		Private nSalMarg1	:= 0
		Private nSalMarg2	:= 0
		Private nTotCalc	:= 0
		Private nTotProp	:= 0
		Private lEdit       := lEditar
		Private nTratoMoed 	:= 0
		Private aCompPrc	:= {}
		
		//--<< Criação do Browse >>--
		Private oBrwComp  	:= NIL
		Private dDt_aFixar	:= dDtFixa
		Private dDt_EntIni  := dDEntrIni
		Private dDt_EntFim	:= dDEntrFim
	
		Private cProdCmp	:= cProduto
		Private cGrupCmp    := cGrupo 
		Private cContrato 	:= cCtrato
		Private nTMerComp   := nTipMer
		Private nMoedComp   := nNjrMoeda
		Private cMoedComp   := cMoeda 
    	Private cSafrComp   := cSafra
		Private cNK7Apl		:= cNk7Aplica
		Private nTaxConPV   := nTaxCon
				 
		//--<< Tenta Encontrar a UM de Preço do Produto >>-
		If empty(cProduto)		   
		   cProdGru := AgrProdGru(cGrupo)
		   cUm1Preco:= AgrProdGru(cGrupo,2) 
		   cUmPreco := AgrUmPrc ( cProdGru )
		Else
			cUmPreco := AgrUmPrc ( cProduto )			
		Endif
			
		IF Empty(cUmPreco) 							//--<< Se o produto não Tem UmPRC dar mensagem e sai fora >>-
			Help( , , STR0002, , STR0003, 1, 0 ) 	//"AJUDA"###"Produto não possui U.M. de Preço."
			Return( aGrvNKA )
		Endif
	EndIF
	
	// ---- Inicializando as Variaveis Privadas ---- //	
	cContrato 	:= cCtrato
	cProdCmp	:= cProduto	
	c1aUmProd 	:= IIF(Empty(cProduto),cUm1Preco , cNjrUm1Pro)
	cUmPreco	:= IIF(Empty(cProduto),cUmPreco  , cNjrUmPrc)
	cNK7Apl		:= cNk7Aplica
	nQtidade  	:= nQtfixar
	nTratoMoed 	:= nNJRMoeda
	lEdit       := lEditar
	dDt_aFixar	:= dDtFixa
	dDt_EntIni  := dDEntrIni
	dDt_EntFim	:= dDEntrFim		
	cGrupCmp    := cGrupo 
	nTMerComp   := nTipMer
	nMoedComp   := nNjrMoeda
	cMoedComp   := cMoeda 
    cSafrComp   := cSafra
    cTipoFix 	:= cTpFix //Tipo da fixação 0=Prevista,1=Firme,2=Basis	//DAGROGAP-1445
	cItOrig	    := cItFxOrg //item da fixação DE ORIGEM //DAGROGAP-1445
    	
	IF cUmPreco == NIL
		cUmPreco := ''
	EndIf
	//--<< Variaveis dos Gets (Rodape)>>--
	nPrcCalc1 	:= 0
	nPrcCalc2 	:= 0
	nVrMarg1	:= 0
	nVrMarg2	:= 0
	nPrcProp1	:= 0
	nPrcProp2	:= 0
	nSalMarg1	:= 0
	nSalMarg2	:= 0
	nTotCalc	:= 0
	nTotProp	:= 0
	aCompPrc	:= {}
	
	//--<< Criação do Browse >>--
	IIF( oBrwComp == nil,oBrwComp:=FWBrowse():New(),)
	//------------------------------------------------------------------------

	//--<<Leio o Produto para Encontrar o Grupo e a 1aUm do Produto>>--
	dbSelectArea("SB1")
	SB1->( dbSetOrder(1) )
	If SB1->(DbSeek(xFilial("SB1") + cProdCmp ))
		cGrupo 		:= SB1->B1_GRUPO
		cGrupCmp	:= SB1->B1_GRUPO
		c1aUmProd  	:= SB1->B1_UM
	EndIF
	
	If __lCallPV
    	If !empty(N8Y->N8Y_UM1PRO)
    		c1aUmProd 	:= N8Y->N8Y_UM1PRO
		EndIF
	EndIf
	
	//--<< Abasteço Variavel de titulo da coluna 6  e 7 do Grid >>--
	cCol7Tit	:=	Alltrim(fDesMoeda( nTratoMoed )) + "/" + cUmPreco
	cCol8Tit	:=  Alltrim(fDesMoeda( nTratoMoed )) + "/" + c1aUmProd
	
	If lEhOGA460 .and. l460CriaTl .and. l460Insert	 // Chamado do Oga460 / Devo Criar a Tela, é se é inserção 
		fMontaTela()
		Return()
	EndIF

	IF Len(aCompreco) > 0
		aCompPrc := fLoadArray( aComPreco ,c1aUmProd , dDt_aFixar )
	Else
		//atualiza array aCompPrc
		lContinua := fGetComp(cProdCmp , cNK7Apl, dDt_aFixar, cContrato,cUmPreco,nQtidade,dDt_EntIni , dDt_EntFim, cGrupo,c1aUmProd, nTratoMoed, cUmPreco, cGrupo)
        
        If cItOrig != '000' .and. (cPaisLoc == "PAR" .or. cPaisLoc == "ARG") //DAGROGAP-1445 
			CpIteOrig( cContrato , cItOrig ) //mantem valor do componente igual item de fixações de origem
		EndIf

		IF ! lContinua
			Return( aGrvNKA )
		EndIF
	EndIF

	IF lEhOGA460 .and. Type("lAtuTaxas") != "U"
		//atualiza taxas da moeda e indices de mercado
		If lAtuTaxas
			AtTaxComp(dDt_aFixar, nTratoMoed, cUmPreco, c1aUmProd)
		EndIf
	EndIf

	//--<< Refaz Todos os Calculos >>--
	Recalc(cUmPreco,c1aUmProd)

	IF lEhOGA460
		//ordena para mostrar em tela pelas posições 15 e 04
		aSortLines := ASORT( aCompPrc,,, { |x, y| (x[15]+x[04]) < (y[15]+y[04]) } )
		aCompPrc   := Aclone( aSortLines )
		
		IF L460CriaTl
		   fMontaTela()
		EndIF
	        		
     	oBrwcomp:Acolumns:= {}
        oBrwcomp:Data():DeActivate()
        
        SetcolObrw()
		oBrwComp:SetArray( aCompPrc )    		// Ajustando os Dados
		oBrwcomp:Data():Activate()
		oBrwcomp:UpdateBrowse(.T.)
		oBrwComp:Refresh()						// Fazendo o Refresh do Browse
	else
		If __lAutomato
			nPrcProp1 := 65
			fPrcProp( cUMPreco , c1aUmProd )
			fArrayNKA(cContrato, nTratoMoed ,cUmPreco, c1aUmProd,aCompPrc,@aGRVNKa)			
		Else
			fMontaTela()
		Endif
	EndIF

	IF lok := .F.
		aGrvNKA := {}
	EndIF

Return( aGrvNKA )



/*/{Protheus.doc} fMontaTela
@author Agroindustria
@since 16/06/2017
@version undefined

@type function
/*/
Static Function fMontaTela()
	Local aSizeDlg 		:= MsAdvSize()
	Local nLinIniTel 	:= 0
	Local oPanelComp	:= 0
	Local nLinAuxIni	:= 0
	Local nLinAuxPan	:= 0
	
	Local nAux			:= 0
	Local nwidth        := 506//478//420
	Local nAuxV12       := 0 //Variável criada por causa que na Versão 12 a EnchoiceBar foi alterada para ficar no topo.

	//--------------------------------------------Cria a Tela Principal----------------------------------------------------
	IF lEhOGA460
	   	oTela		:= OG460PANEL
	   	nLinIniTel	:= 001
	   	nLinAuxIni	:= 000
	   	nLinAuxPan	:= 000
	   	nAux		:= 023
	Else
		nLinIniTel 	:= aSizeDlg[7]
		nLinAuxIni	:= 030
		nLinAuxPan	:= 038 
		nAuxV12     := 022
		oTela := MsDialog():New(nLinIniTel,000,450/*370*/,1010, STR0001,,,.F.,,,,,oMainWnd,.T.,,,.F.)  //"Composição de Preços"

		oPanelTop := TPanel():New(nLinIniTel+nLinAuxIni ,nLinIniTel + 01,/*Descricao*/,oTela,oFontAta,.F.,.F.,,,(nwidth),(nAuxV12),.T.,.T.)

		//--<< Labels e Get antes do Grid
		@ 002, 007 SAY  STR0004 SIZE 050, 010 OF oPanelTop PIXEL   	//"Data Fixação"
		@ 002, 060 Say  dToc(dDt_aFixar)  SIZE 037, 010 OF oPanelTop PICTURE "99/99/9999" PIXEL
		
		@ 002, 120 SAY  STR0005 SIZE 030, 007 OF oPanelTop PIXEL 	//"Entrega de"
		@ 002, 157 SAY  dToc(dDt_EntIni) + " a " + dToc(dDt_EntFim)SIZE 075, 007 OF oPanelTop PIXEL

		@ 010, 007 SAY STR0006 SIZE 032, 011 OF oPanelTop PIXEL		//"Produto"
		@ 010, 060 SAY Trim(cProdCmp) + " - " + SB1->B1_DESC  SIZE 100, 011 OF oPanelTop PIXEL
		
		If __lCallPV
			@ 010, 150 SAY STR0033 SIZE 018, 011 OF oPanelTop PIXEL		//"Moeda"
			@ 010, 160 SAY Str(nMoedComp) + " - " + cMoedComp  SIZE 50, 011 OF oPanelTop PIXEL
			
			@ 010, 250 SAY STR0034 SIZE 025, 011 OF oPanelTop PIXEL		//"Mercado"
			@ 010, 280 SAY Trim(nTMerComp)  + " - " + X3CboxDesc( "N8W_TIPMER", nTMerComp) SIZE 100, 011 OF oPanelTop PIXEL
		EndIf
		
		@ 010, 383 SAY STR0011	SIZE 200, 011 OF oPanelTop PIXEL	//"Quantidade"
		@ 010, 430 MSGET oGQtd VAR nQtidade WHEN .f.  SIZE 060, 008 OF oPanelTop PICTURE PesqPict( "NJR", "NJR_QTDINI" ) PIXEL
		@ 010, 493 SAY c1aUmProd	SIZE 200, 011 OF oPanelTop PIXEL
	EndIF

	//--------------------Cria o Panel que Delimita o Tamanho do Browse do Composicao de preçõs------------
	
    nheight:=120-nAux//70
	
	oPanelComp := TPanel():New(nLinIniTel+nLinAuxIni+nAuxV12 ,nLinIniTel + 01,/*Descricao*/,oTela,oFontAta,.F.,.F.,,,(nwidth),(nheight-nAuxV12),.T.,.T.)

	//--<< Seta as Propriedades do Browse >>--
	setoBrwCP( oPanelComp )

	oPnCalcs := Nil
	@ 112 + nLinAuxPan, 320 MSPANEL oPnCalcs PROMPT "" SIZE 188, 055 OF oTela /*12632256 LOWERED */

	If !__lCallPV
		// Colocando as Unidades de Medida			
		@ 008, 0087 SAY Alltrim(fDesMoeda( nTratoMoed )) +  "/" + cUmPreco 	SIZE 060, 011 OF oPnCalcs PIXEL	//"Valor da Margem"
		@ 008, 0147 SAY Alltrim(fDesMoeda( nTratoMoed )) +	"/" + c1aUmProd	SIZE 060, 011 OF oPnCalcs PIXEL	//"Valor da Margem"

		// Preco Calculado
		@ 016, 0003  SAY STR0007 SIZE 200, 011 OF oPnCalcs PIXEL  	//"Preço Calculado"
        @ 016, 0060 MSGET oGPrcCalc1 VAR nPrcCalc1  WHEN .f. SIZE 065, 008 OF oPnCalcs PICTURE PesqPict( "NJM", "NJM_VLRUNI" ) PIXEL
        
        If (cPaisLoc == "PAR" .or. cPaisLoc == "ARG")  //dekalpar
            @ 016, 0125 MSGET oGPrcCalc2 VAR nPrcCalc2  WHEN .f. SIZE 062, 008 OF oPnCalcs PICTURE PesqPict( "NN8", "NN8_VLRUNI" ) PIXEL
        Else
            @ 016, 0125 MSGET oGPrcCalc2 VAR nPrcCalc2  WHEN .f. SIZE 062, 008 OF oPnCalcs PICTURE PesqPict( "NJM", "NJM_VLRUNI" ) PIXEL
        EndIf
	
	
		@ 025, 0003 SAY STR0008 SIZE 200, 011 OF oPnCalcs PIXEL		//"Valor da Margem"
		@ 025, 0060 MSGET oGMarg1 VAR nVrmarg1 WHEN .f.  SIZE 065, 008 OF oPnCalcs PICTURE "@E 9,999,999.999999" PIXEL
		@ 025, 0125 MSGET oGMarg2 VAR nVrmarg2 WHEN .f.  SIZE 062, 008 OF oPnCalcs PICTURE "@E 9,999,999.999999" PIXEL
		 	
		@ 034, 0003 SAY STR0009 SIZE 200, 011 OF oPnCalcs PIXEL		//"Preço Proposto:"
		
		If (cPaisLoc == "PAR" .or. cPaisLoc == "ARG")  //dekalpar
			@ 034, 0060 MSGET oGPrcProp1 VAR nPrcProp1 WHEN .f.  	SIZE 065, 008 OF oPnCalcs Valid fPrcProp( cUMPreco , c1aUmProd )PICTURE PesqPict( "NJR", "NJR_VLRBAS" ) PIXEL
            @ 034, 0125 MSGET oGPrcProp2 VAR nPrcProp2 WHEN .f.  	SIZE 062, 008 OF oPnCalcs 					 					PICTURE PesqPict( "NN8", "NN8_VLRUNI" ) PIXEL
		else
			@ 034, 0060 MSGET oGPrcProp1 VAR nPrcProp1 WHEN lEdit  	SIZE 065, 008 OF oPnCalcs Valid fPrcProp( cUMPreco , c1aUmProd )PICTURE PesqPict( "NJM", "NJM_VLRUNI" ) PIXEL
            @ 034, 0125 MSGET oGPrcProp2 VAR nPrcProp2 WHEN .f.  	SIZE 062, 008 OF oPnCalcs                                       PICTURE PesqPict( "NJM", "NJM_VLRUNI" ) PIXEL
		EndIf
	
		@ 044, 0003 SAY STR0010 SIZE 200, 011 OF oPnCalcs PIXEL		//"Saldo da Margem"
		@ 044, 0060 MSGET oGSalMarg1 VAR nSalMarg1 WHEN .f.  SIZE 065, 008 OF oPnCalcs PICTURE PesqPict( "NJM", "NJM_VLRUNI" ) PIXEL
		@ 044, 0125 MSGET oGSalMarg2 VAR nSalMarg2 WHEN .f.  SIZE 062, 008 OF oPnCalcs PICTURE PesqPict( "NJM", "NJM_VLRUNI" ) PIXEL
		
		//--------------------Cria o Grupo do Total ------------
		oPnTotal	:=nil
	 	
		@ 125 + nLinAuxIni , 003 MSPANEL oPnTotal PROMPT "" SIZE 130, 030 OF oTela //LOWERED
	
		@ 003, 010 SAY 	STR0012+Alltrim(fDesMoeda( nTratoMoed ))	SIZE 200, 011 OF oPnTotal PIXEL		//"Total Calculado R$"
		@ 003, 065 MSGET oGTotCalc 	VAR nTotCalc WHEN .f. SIZE 060, 008 OF oPnTotal PICTURE PesqPict( "NJR", "NJR_QTDINI" ) PIXEL
	
		@ 015, 010 SAY 	STR0013+Alltrim(fDesMoeda( nTratoMoed ))	SIZE 200, 011 OF oPnTotal PIXEL		//"Total Proposto  R$"
		@ 015, 065 MSGET GTotProp 	VAR nTotProp WHEN .f. SIZE 060, 008 OF oPnTotal PICTURE PesqPict( "NJR", "NJR_QTDINI" ) PIXEL
	    
		lok := .F.
	
		IF ! lEhOGA460 

			Aadd(aButtons,{/*bitmap*/,{||fRefresh(cProdCmp, cNK7Apl, dDt_aFixar, cContrato,cUmPreco,nQtidade,dDt_EntIni , dDt_EntFim, cGrupCmp,c1aUmProd, nTratoMoed, c1aUmProd, lEdit)}, STR0026})	//"Refresh"
			
			Aadd(aButtons,{/*bitmap*/,{||fRefIdcMd(dDt_aFixar, nTratoMoed, cUmPreco,c1aUmProd, lEdit)}, "Atualizar Taxas"})	//"Refresh"
		EndIF
	EndIF
	
	IF ! lEhOGA460	
		ACTIVATE MSDIALOG oTela CENTERED ON INIT (EnchoiceBar(oTela,{||lOk := fArrayNKA(cContrato, nTratoMoed ,cUmPreco, c1aUmProd,aCompPrc,@aGRVNKa),if(lOk,oTela:End(),)},{||oTela:End()},,aButtons))
	EndIF
	

Return

/** {Protheus.doc} fQryComp
Realiza Query da Tabela produtos x componentes de preços

@param.: 	cProd , cTp, dDtFixacao , cContrato, cUmPrc,nQtidade,dDt_EntIni , dDt_EntFim , cGrupo , c1aUM, nMoedaCtr,cTpComp
@author: 	Equipe AgroIndustria
@Uso...: 	SIGAARM - Originação de Grãos
*/
Static Function fQryComp(cProd , cTp, dDtFixacao , cContrato, cUmPrc,nQtidade,dDt_EntIni , dDt_EntFim , cGrupo , c1aUM, nMoedaCtr, cTpComp)
	Local cQuery      	:= ""
	Local nVrIndice  	:= 0
	Local nVrInd1   	:= 0
	Local nVrInd2  		:= 0
	Local nQtUMPRC    	:= 0
	Local nQt1AUM    	:= 0
	Local cOrdenacao 	:= 0
	Local cUm1Pro       := ""
	Local cMoedaCom     := ""
	Default nTaxConPV   := 0

	//--<< Consulta que retorna Componentes x itens  Somente os Itens que o N7_UTILIZ = 'N'>>-- 
	cQuery := ""
	cQuery += " SELECT NK8.* , SB1.B1_GRUPO, NK7.* "
	
	If __lCallPV
		cQuery += ", N8Z.N8Z_VALFIX, N8Z.N8Z_MOEDA, N8Z.N8Z_TIPVAL, N8Z.N8Z_PERAPL, N8Z.N8Z_ORDEM, N8Z.N8Z_MOEDA2, N8Z.N8Z_UNIMED "
	EndIF
	
	cQuery += " FROM " + RetSqlName('NK8') + ' NK8 '
	cQuery +=  "  LEFT JOIN " + RetSqlName('SB1') + " SB1  ON SB1.B1_COD = NK8.NK8_CODPRO AND SB1.D_E_L_E_T_ = ''  AND SB1.B1_FILIAL = '" +  XFILIAL('SB1') +  "'"
	cQuery +=  "  LEFT JOIN " + RetSqlName('NK7') + " NK7 ON NK7.NK7_CODCOM = NK8.NK8_CODCOM AND NK7.D_E_L_E_T_ = '' AND NK7.NK7_FILIAL = '" + XFILIAL('NK7') + "'"
	
	IF __lCallPV
		cQuery +=  "  LEFT JOIN " + RetSqlName('N8Z') + " N8Z ON NK7.NK7_CODCOM = N8Z.N8Z_CODCOM AND N8Z.D_E_L_E_T_ = '' AND N8Z.N8Z_FILIAL = '" + XFILIAL('N8Z') + "'"
	ENDIF
		
	cQuery += "  WHERE ((NK8_CODPRO = '"+  cProd +"' AND NK8_GRPPRO = '"+ cGrupo + "') OR (NK8_CODPRO = '"  +  cProd +"' AND NK8_GRPPRO = ' ') OR (NK8_CODPRO = ' ' AND NK8_GRPPRO = '"+ cGrupo + "')  OR (NK8_CODPRO = ' ' AND NK8_GRPPRO = ' ' ))"
	
	if NK8->(ColumnPos('NK8_DATINI')) > 0
		cQuery +=   "  AND ((NK8_DATINI <= '"+ Dtos(dDtFixacao) + "' AND NK8_DATFIM >= '"+ Dtos(dDtFixacao) + "') OR (NK8_DATINI = ' ' AND NK8_DATFIM = ' '))"
	endIf

	cQuery +=   "  AND (NK7.NK7_APLICA = 'A' OR NK7.NK7_APLICA = '" + cTp + "')"
	cQuery +=   "  AND NK7.NK7_UTILIZ ='" + cTpComp+ "'"
	cQuery +=   "  AND NK8.NK8_ATIVO = 'S'"
	cQuery +=   "  AND NK7.NK7_ATIVO = 'S'"
    
    If cTipoFix == '2' .and. (cPaisLoc == "PAR" .or. cPaisLoc == "ARG")  //cTipoFix = '2' ==> Basis  //DAGROGAP-1445
		cQuery +=   "  AND NK7.NK7_GRUPO = '1' "  //NK7==>1=Basis;2=Fixo
	EndIf
	
	IF __lCallPV
       cQuery +=   "  AND N8Z.N8Z_SAFRA  = '" + cSafrComp + "'" 
       cQuery +=   "  AND N8Z_CODPRO     = '" + cProd + "'"
       cQuery +=   "  AND N8Z_GRPROD     = '" + cGrupo + "'"
       cQuery +=   "  AND N8Z.N8Z_TIPMER = '" + nTMerComp + "'" 
       cQuery +=   "  AND N8Z.N8Z_MOEDA  = " + STR(nMoedComp)       
    endIf
	
	cQuery +=   "  AND NK8.D_E_L_E_T_ = ''"
	cQuery +=  " ORDER BY  " 
	If __lCallPV
		cQuery += " N8Z_ORDEM, "
	EndIf
	cQuery += " NK8_CODCOM,NK8.NK8_CODPRO,NK8.NK8_GRPPRO "
	cQuery:=ChangeQuery(cQuery)

	If Select("QryNK8") != 0
		QryNK8->(dbCloseArea())
	EndIf
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"QryNK8",.F.,.T.)
	QryNK8->(DbGoTop())

	cComp_Idx	:= ""  //--<< contem o componente e o Indice do Componente >>

	While !QryNK8->(EOF())	     
         
		if NK8->(ColumnPos('NK8_DATINI')) <= 0
			//--<< Valida a Dt. de Entrega >>--
			IF ! fValDtEntr(QryNK8->NK8_DIAINI, QryNK8->NK8_MESINI, QryNK8->NK8_DIAFIM, QryNK8->NK8_MESFIM, dDt_EntIni , dDt_EntFim )
				QryNK8->(dbSkip())
				Loop
			EndIF
		endIF	
		
		nVrIndice := 0
		 // gravar valor do componente definido no plano de venda
	     IF __lCallPV
		     If QryNK8->NK7_CALCUL = 'R' .or. QryNK8->NK7_CALCUL = 'T' //Tributo ou resultado
		     	 nVrIndice := AG420CTPP(QryNK8->NK8_CODCOM,QryNK8->N8Z_PERAPL,QryNK8->N8Z_MOEDA2,QryNK8->N8Z_UNIMED,dDtfixacao, nTaxConPV)
     		 Else
     		 	nVrIndice := AG420NCV(cSafrComp, cGrupo, cProd, nTMerComp, QryNK8->N8Z_MOEDA, QryNK8->NK8_CODCOM) 
	         EndIf
         Else
		 	//--<<Encontro o Tipo de Cotação do Indice >>--
			dbSelectArea("NK0")
			NK0->( dbSetOrder(1) )
			If NK0->(DbSeek(xFilial("NK0") + QryNK8->NK8_CODIDX ))
				nVrIndice :=AgrGetInd( NK0->NK0_INDICE,NK0->NK0_TPCOTA,dDtFixacao )
			EndIF
		EndIf
		
		cMoedaCom :=  IIF(__lCallPV , QRYNK8->N8Z_MOEDA2, QRYNK8->NK8_MOEDA ) 
		cUm1Pro    := IIF(__lCallPV , QRYNK8->N8Z_UNIMED, QRYNK8->NK8_UM1PRO )
		
		nTxacomp := fTxaCot( cMoedaCom , nMoedactr,dDtfixacao, IIF(nTaxConPV==NIL,0,nTaxConPV)) //--<< Conversao de Moeda >>--
		
		/*/
		!-----------------------------------------------------------------	!
		!Conversao de UM do Indice  Para a UM do Preco do Produto			!
		!Ex. indice esta em TN e a Unidade de medida de preco eh em kg		!
		!Obtendo a correspondencia de TN para KG por Exemplo			    !
		!-----------------------------------------------------------------	!
		/*/
		nQtUMPrc := AGRX001( cUm1Pro ,cUmPrc,1, cProd)

		IF ! Alltrim( cUm1Pro ) = Alltrim ( cUmPrc ) // Unidades de medidas sao diferentes
			IF !fValConvUM( cUm1Pro ,cUmPrc,1)  		// Se não foi possivel Converter //
				fMensUM(cUm1Pro ,cUmPrc )
			EndIF
		EndIF

		/*/
		!--------------------------------------------------------------!
		!Conversao de UM do Indice  Para a 1a UM do Produto				!
		!Ex. indice esta em TN e a Unidade de medida do produto em kg	!
		!Obtendo a correspondencia de TN para KG por Exemplo				!
		!--------------------------------------------------------------!
		/*/
		
		
		
		nQt1AUM:= AGRX001( cUm1Pro ,c1aUM,1, cProd)

		IF ! Alltrim( cUm1Pro ) = Alltrim ( c1aUM ) 	// Unidades de medidas sao diferentes
			IF !fValConvUM( cUm1Pro ,c1aUM,1)  		// Se não foi possivel Converter //
				fMensUM(cUm1Pro ,c1aUM )
			EndIF
		EndIF

		nVrind1 := SfCovUMVal(nVrIndice,cUm1Pro,cUmPrc)
		nVrind2 := SfCovUMVal(nVrIndice,cUm1Pro,c1aUM)

		nVrind1 := ( nVrind1 * nTxaComp )  	//--<< contem o Vr do Indice na   Um de Preco do produto e na Moeda do Contrato>>--
		nVrind2 := ( nVrind2 * nTxaComp ) 	//--<< contem o Vr do Indice na 1aUm          do produto e na Moeda do Contrato>>--

		//--<< Case que irá Ordenar as Linha do Browse na Seguinte ordem Preco,Custo,Informativo >>
		If __lCallPV 
			cOrdenacao := QRYNK8->N8Z_ORDEM
		Else
			Do Case
				Case Alltrim(QryNK8->NK7_CALCUL) == 'P'
				cOrdenacao := 'A'
				Case Alltrim(QryNK8->NK7_CALCUL) == 'C'
				cOrdenacao := "B"
				Case Alltrim(QryNK8->NK7_CALCUL) == 'I'
				cOrdenacao := 'C'
				Case Alltrim(QryNK8->NK7_UTILIZ) == 'M'  //--<< Margem sera o ultimo >>--
				cOrdenacao := 'D'
			EndCase
		EndIF

		If Alltrim(QryNK8->NK7_UTILIZ) == 'M' 
        	__lTemMargem := .T.
    	EndIF
    	
		lAddArray := .f.

		//--<< Esta Logica Garante que sempre Tenha o Componente + Especifico no Array >>-- 		    
		IF  Empty( cComp_Idx ) .and. cTpComp == QryNK8->NK7_UTILIZ //DAGROGAP-1445
			cComp_Idx := QryNK8->NK8_CODCOM+QryNK8->NK8_CODIDX
			lAddArray := .t.
		ElseIF ! cComp_Idx = QryNK8->NK8_CODCOM + QryNK8->NK8_CODIDX .and. cTpComp == 'N'
			cComp_Idx := QryNK8->NK8_CODCOM+QryNK8->NK8_CODIDX
			lAddArray := .t.
		EndIF

       IF lAddArray == .t.
			aAdd(aCompPrc , {QryNK8->NK8_CODCOM,QryNK8->NK8_ITEMCO,QryNK8->NK8_CODIDX,QryNK8->NK7_DESCRI, cMoedaCom,nTxaComp,cUm1Pro,nVrIndice,nVrIndice,nVrInd1 , nVrind2 ,nQtUMPrc,nQt1aUM,QryNK8->NK7_CALCUL,cOrdenacao, QryNK8->NK7_UTILIZ })
			IF cTpComp == 'M' .and. Empty( QryNK8->NK8_CODIDX ) .and. QryNK8->NK7_PRCMAR > 0 	//--<< Nao Encontrei Indice de Margem Tenho Q Calcular a Margem Com a Precentagem >>--
				aCompPrc[len(aCompPrc), 05]	:= MOEDAPERCENTUAL 									//--<< Mudo moeda Para percentagem para indicar q o calculo foi por percentual >>--
				aCompPrc[len(aCompPrc), 08]	:= QryNK8->NK7_PRCMAR
				aCompPrc[len(aCompPrc), 09]	:= IIF(__lCallPV, nVrIndice, QryNK8->NK7_PRCMAR)
			EndIF 
		Else
			aCompPrc[len(aCompPrc), 01]	:= QryNK8->NK8_CODCOM
			aCompPrc[len(aCompPrc), 02]	:=QryNK8->NK8_ITEMCO
			aCompPrc[len(aCompPrc), 03]	:=QryNK8->NK8_CODIDX
			aCompPrc[len(aCompPrc), 04]	:=QryNK8->NK7_DESCRI
			aCompPrc[len(aCompPrc), 05]	:=cMoedaCom
			aCompPrc[len(aCompPrc), 06]	:=nTxaComp
			aCompPrc[len(aCompPrc), 07]	:=cUm1Pro
			aCompPrc[len(aCompPrc), 08]	:=nVrIndice
			aCompPrc[len(aCompPrc), 09]	:=nVrIndice
			aCompPrc[len(aCompPrc), 10]	:=nVrInd1
			aCompPrc[len(aCompPrc), 11]	:= nVrind2
			aCompPrc[len(aCompPrc), 12]	:=nQtUMPrc
			aCompPrc[len(aCompPrc), 13]	:=nQt1aUM
			aCompPrc[len(aCompPrc), 14]	:=QryNK8->NK7_CALCUL
			aCompPrc[len(aCompPrc), 15]	:=cOrdenacao
			aCompPrc[len(aCompPrc), 16]	:=QryNK8->NK7_UTILIZ
			IF cTpComp == 'M' .and. nVrIndice == 0  				//--<< Nao Encontrei Indice de Margem Tenho Q Calcular a Margem Com a Precentagem >>--
				aCompPrc[len(aCompPrc), 05]	:= MOEDAPERCENTUAL 		//--<< Mudo moeda Para percentagem para indicar q o calculo foi por percentual >>--
				aCompPrc[len(aCompPrc), 08]	:= QryNK8->NK7_PRCMAR
				aCompPrc[len(aCompPrc), 09]	:= IIF(__lCallPV, nVrIndice, QryNK8->NK7_PRCMAR) 
			EndIF 
		EndIF
		QryNK8->(dbSkip())
	EndDo
	QryNK8->(dbCloseArea())	
Return( nil )

/** {Protheus.doc} SetoBrwCP
Seta as Propriedades do Browse de Composicao de preço

@author: 	Equipe AgroIndustria
@Uso...: 	SIGAARM - Originação de Grãos
*/
Static Function SetoBrwCP( oPanelComp )
	Local aSortLines	:= {}
	
	//Ordena o Array Multidimensional levando em consideração somente a Coluna 15
	aSortLines := ASORT(aCompPrc,,, { |x, y| (x[15]+x[04]) < (y[15]+y[04]) })
	aCompPrc   := Aclone( aSortLines )
	
	SetColObrw()   // Define colunas do Browse e quais delas podem ser alteradas.
	
	oBrwComp:setdataArray()  											//	É abastecido por arraY
	oBrwComp:setArray(aCompPrc)											//	Informo ao Browse o Array que contem os Dados
	oBrwComp:SetDescription( STR0001 )									//	Definimos o título que será exibido como método SetDescription.

	oBrwComp:DisableReport()
	oBrwComp:DisableConfig()
	oBrwComp:DisableLocate()
	oBrwComp:SetOwner(oPanelComp)
	obrwcomp:lheaderclick :=.f.
	oBrwComp:SetEditCell( lEdit ) 					// indica que o grid éeditavel
	
    If  Len(aCompPrc) > 0 .and. (cPaisLoc == "PAR" .or. cPaisLoc == "ARG") 
		oBrwComp:SetChange({|| fEditLine()})  	//DAGROGAP-1445	
	EndIF

    oBrwComp:bValidEdit := {|| fvalEdit(dDt_aFixar, nTratoMoed,cUmPreco,c1aUmProd)} 			// valida e move o valor para o array	
	oBrwComp:SetLineHeight(13) 

	oBrwComp:Activate()	
Return

/** {Protheus.doc} fvalEdit
Valida o que Foi digitado na coluna do Grid

@author: 	Equipe AgroIndustria
@Uso...: 	SIGAARM - Originação de Grãos
*/
Static Function fvalEdit(dDtFixacao, nMoedaCtr,cUmPrc,c1aUM)  
	Recalc(cUmPreco,c1aUmProd)  //--<< Recalc Infs. no Array >>--

	oBrwComp:setArray(aCompPrc)	// Forço o Browse a ler os novos Vrs.
	oBrwComp:Refresh()			// Refresh do Grid
Return ( .t. )

/** {Protheus.doc} fDesMoeda
Função que Retorna a Descricao da Moeda

@author: 	Equipe AgroIndustria
@Uso...: 	SIGAARM - Originação de Grãos
*/
Static Function fDesMoeda( nMoeda )
	Local cDesMoeda	:= ""
	IF nMoeda > 0
		cDesMoeda 		:= SuperGetMv("MV_SIMB"+AllTrim(Str(nMoeda,2)))
	EndIF
Return cDesMoeda

/** {Protheus.doc} fValDtEntr
Função que Valida a Data de Entrega

@author: 	Equipe AgroIndustria
@Uso...: 	SIGAARM - Originação de Grãos
*/                         
Static Function fValDtEntr(cDiaIni, cMesIni,cDiaFim,cMesFim, dDtEntrIni, dDtEntFim)
	Local lOk 		:= .t.
	Local dDtIni 	:= ctod( cDiaIni + '/' + cMesIni +'/'+ strzero(year(dDtEntrIni),4) )
	Local dDtFim 	:= ctod( cDiaFim + '/' + cMesFim +'/'+ strzero(year(dDtEntrIni),4) )

	If ! Empty(dDtIni)

		IF Month(dDtIni) > Month(dDtFim)
			dDtIni := YearSub( dDtIni , 1 )  //--<< Subtrai um do no da Dt Ini >>--
		Elseif Month(dDtIni) == Month(dDtFim) .and. Day(dDtini) >= Day(dDtFim)
			dDtIni := YearSub( dDtIni , 1 )  //--<< Subtrai um do no da Dt Ini >>--
		EndIF

		//--<< Verifica se a data esta dentro do enterva-lo >>--
		Do Case
			Case dDtEntrIni < dDtIni
			lOk :=.f.
			Case dDtEntrIni > dDtFim
			lok :=.f.
		EndCase
	EndIF
Return( lOk )

/** {Protheus.doc} Recalc
Função que Recalcula os Vrs.

@author: 	Equipe AgroIndustria
@Uso...: 	SIGAARM - Originação de Grãos
*/
Static function Recalc(cUmPrc,c1aUmPrd)
	Local aCompAux 	   := Aclone(aCompPrc)
	Local nQtaux	   := 0
	Local nI           := 1
	Local nPosMarg     := 0
	Local nDecCompon   := TamSx3('NKA_VLRCOM')[2]   	// O nr de decimais de arredontamento para o resultado dos componentes, sao baseados nos decimais dos componentes padrao 6	
    Local nDecLoc      := 0

	nPrcCalc1 := 0
	nPrcCalc2 := 0

	If TYPE ("__lCallPV") == "U"
		__lCallPV := .F.
	EndIf
	If TYPE ("_NDECCASAS") == "U"
		_NDECCASAS := TamSx3('NJM_VLRUNI')[2] 
	EndIf	
	For nI := 1 to len(aCompAux) Step 1
		IF aCompaux[nI, 16] == "M"  //--<< Trato a Margem fora do If >>--
			Loop
		EndIF

		aCompAux[ nI, 10 ] := Round(SfCovUMVal(aCompAux[ nI, 9 ],aCompAux[ nI, 7 ],cUmPrc)    	,nDecCompon )		
		aCompAux[ nI, 11 ] := Round(SfCovUMVal(aCompAux[ nI, 9 ],aCompAux[ nI, 7 ],c1aUmPrd)	,nDecCompon )

		//--<< Recalculo das colunas 10  e 11 do Array >>--
		aCompAux[ nI, 10 ] :=  Round(aCompAux[ nI, 10 ] * aCompAux[ nI, 6 ] ,nDecCompon )//* aCompAux[ nI, 12 ]
		aCompAux[ nI, 11 ] :=  Round(aCompAux[ nI, 11 ] * aCompAux[ nI, 6 ] ,nDecCompon )//* aCompAux[ nI, 13 ]
		
		If !__lCallPV
			//--<< Preço Calculado >>--
			Do Case
				Case Alltrim( aCompAux[ nI , 14 ] ) == 'P'  //-Preço ( Somar )
				nPrcCalc1 += aCompAux[ nI , 10 ] 
				nPrcCalc2 += aCompAux[ nI , 11 ]
				Case Alltrim( aCompAux[ nI , 14 ] ) == 'C'  //-Custo ( Subtrair )
				nPrcCalc1 -= aCompAux[ nI , 10 ]
				nPrcCalc2 -= aCompAux[ nI , 11 ]
			EndCase
		Else
			If Alltrim( aCompAux[ nI , 14 ] ) == 'R' //-Resultado 
				nPrcCalc1 := aCompAux[ nI , 10 ] 
				nPrcCalc2 := aCompAux[ nI , 11 ]
			EndIf
		EndIF
	Next nI
	
	//--<< Faço tratamento da margem >>--
	nVrmarg1 := 0
	nVrmarg2 := 0
	nPosMarg := aSCAN(aCompaux, {|aCompaux| aCompaux[16] == "M" })
	IF nPosMarg > 0
		IF EMPTY(aCompAux[ nPosMarg, 3 ]) //--<< Se não foi encontrado indice ref. a Margem  , Faz pelo percentual >>--
			nVrMarg1 := Round(nPrcCalc1 * aCompAux[ nPosMarg, 09 ] / 100	,nDecCompon )
			nVrMarg2 := Round(nPrcCalc2 * aCompAux[ nPosMarg, 09 ] / 100	,nDecCompon )

			aCompAux[ nPosMarg, 10 ] :=  nVrMarg1
			aCompAux[ nPosMarg, 11 ] :=  nVrMarg2
		Else
			//--<< Recalculo das colunas 10  e 11 do Array >>--
			aCompAux[ nPosMarg, 10 ] := Round(SfCovUMVal(aCompAux[ nPosMarg, 9 ],aCompAux[ nPosMarg, 7 ],cUmPrc)		,nDecCompon )		
			aCompAux[ nPosMarg, 11 ] := Round(SfCovUMVal(aCompAux[ nPosMarg, 9 ],aCompAux[ nPosMarg, 7 ],c1aUmPrd)	,nDecCompon )

			aCompAux[ nPosMarg, 10 ] := Round(aCompAux[ nPosMarg, 10 ] * aCompAux[ nPosMarg, 6 ] ,nDecCompon )/// aCompAux[ nPosMarg, 12 ]
			aCompAux[ nPosMarg, 11 ] := Round(aCompAux[ nPosMarg, 11 ] * aCompAux[ nPosMarg, 6 ] ,nDecCompon )/// aCompAux[ nPosMarg, 13 ]

			nVrMarg1	:= aCompAux[ nPosMarg, 10 ]
			nVrMarg2	:= aCompAux[ nPosMarg, 11 ]
		EndIF
		//--<< Refaço o preço Calc. Considerando a Margem , a Pedido da Fernanda>>--
		Do Case
			Case Alltrim( aCompAux[ nPosMarg , 14 ] ) == 'P'  //-Preço ( Somar )
			nPrcCalc1 += nVrMarg1
			nPrcCalc2 += nVrMarg2
			Case Alltrim( aCompAux[ nPosMarg , 14 ] ) == 'C'  //-Custo ( Subtrair )
			nPrcCalc1 -= nVrMarg1
			nPrcCalc2 -= nVrMarg2
		EndCase
	EndIF
	
    If (cPaisLoc == "PAR" .or. cPaisLoc == "ARG")
        nDecLoc := _nDecLoc
    Else
        nDecLoc := _nDecCasas
    EndIf
	// Arredondando os vrs. calculados de acordo com necessario
	nPrcCalc1  	:= Round(nPrcCalc1,	_nDecCasas) 	
    nPrcCalc2 	:= Round( nPrcCalc2, nDecLoc)    			

	//--<< Saldo da Margem (Preco Calc - Preco Proposto + Margem ) >--
	if (cPaisLoc == "PAR" .or. cPaisLoc == "ARG") //dekalpar
	    nPrcProp1 := Round(nPrcCalc1 + nVrMarg1	,_nDecCasas )  //Arredondamento baseado no tamanho das casas do componente // dekalpar
	Endif // dekalpar
	nPrcProp2 := Round(nPrcProp2, nDecLoc )
	
	//Trata se for compra ou venda
    if cPaisLoc != "PAR" .and. cPaisLoc != "ARG"
        If  (IsInCallStatck('OGA460') .and. FwFldGet('NKN_TIPSIM') == "1") .OR. (!IsInCallStatck('OGA460') .AND. FwFldGet('NJR_TIPO') == "1" )
            nsalMarg1 := Round(nPrcCalc1 - nPrcProp1 + nVrMarg1	,_nDecCasas )  //Arredondamento baseado no tamanho das casas do componente
            nsalMarg2 := Round(nPrcCalc2 - nPrcProp2 + nVrMarg2	,_nDecCasas )  //Arredondamento baseado no tamanho das casas do componente
        ElseIf (IsInCallStatck('OGA460') .and. FwFldGet('NKN_TIPSIM') == "2") .Or. (!IsInCallStatck('OGA460') .AND. FwFldGet('NJR_TIPO') == "2" )
            nsalMarg1 := Round(nPrcProp1 - nPrcCalc1 + nVrMarg1	,_nDecCasas )  //Arredondamento baseado no tamanho das casas do componente
            nsalMarg2 := Round(nPrcProp2 - nPrcCalc2 + nVrMarg2	,_nDecCasas )  //Arredondamento baseado no tamanho das casas do componente
        EndIf
    Else
        nsalMarg1 := Round(nPrcCalc1 - nPrcProp1 + nVrMarg1	,nDecLoc )  //Arredondamento baseado no tamanho das casas do componente
        nsalMarg2 := Round(nPrcCalc2 - nPrcProp2 + nVrMarg2	,nDecLoc )  //Arredondamento baseado no tamanho das casas do componente
    EndIf
    
	
	IF nSalMarg1 == 0 .AND. ! nSalmarg2 > 0     //Tratamento para garantir q o Saldo da Margem 2 seja Zerado Quando o Saldo da Margem1 estiver zerado
	   nPrcProp2 += nsalMarg2
	   nsalMarg2 := nPrcCalc2 - nPrcProp2 + nVrMarg2
	EndIF

	//--<< CalCulando Totais >--
	nQtAux		:= 	AGRX001( c1aUmProd ,c1aUmProd,nQtidade, cProdCmp)  //--<< Garantindo Integridade da UM do cTrato e 1aUm Produto >>--
	
	// Arredontamento dos totais tem q ser 2 casas
	nTotCalc	:=	Round(nQtAux * nPrcCalc2	,2 )
	nTotProp   	:=  Round(nQtAux * nPrcprop2	,2 )
	
	aCompPrc 	:= Aclone(aCompAux) //--<< Atualiza Array >>--
	
/*   Dados da funcao fMudouTots
	VrCUNUUM1  vR. UNITARIO CALCULADO Unitario na UM do Produto
	VrCUNUUMP  vR. uNITARIO cALCULADO Unitario na UM de Preco
	VrCTOUUM1  vR. UNITARIO CALCULADO Total na UM do Produto

	VrPUNUUM1  vR. UNITARIO proposto Unitario na UM do Produto
	VrPUNUUMP  vR. Unitario proposto Unitario na UM de Preco
	VrPTOUUM1  vR. UNITARIO proposto total	  na UM do Produto

*/
	fMudouTots(nPrcCalc2, nPrcCalc1, nTotCalc, nPrcProp2, nPrcProp1, nTotProp )
		
Return

/** {Protheus.doc} fPrcProp
Valida o preço Proposto

@author: 	Equipe AgroIndustria
@Uso...: 	SIGAARM - Originação de Grãos
*/
Static Function fPrcProp(cUmPrc, c1aUM )
	Private __LCALLPV := .F.
	Private _nDecCasas		:= TamSx3('NJM_VLRUNI')[2]   	// O nr de decimais de arredontamento para o resoltado de composicao de preco em UN/UMPR deve seguir o Campo D1_VUNT	
	
	//--<< Calcula o Valor Proposto 2 de acordo com o Vr. Proposto 1 , Informado >>--		
	/*/
	!--------------------------------------------------------------!
	!Conversao de UM do Indice  Para a 1a UM do Produto				!
	!Ex. indice esta em TN e a Unidade de medida do produto em kg	!
	!Obtendo a correspondencia de TN para KG por Exemplo				!
	!--------------------------------------------------------------!
	/*/
	//nQtAux1:= AGRX001( cUmPrc ,c1aUM,1)
	// nPrcProp2 := nPrcProp1 / nQtAux1
	///retirado em 06042016 //emerson

	nPrcProp2 := SfCovUMVal(nPrcProp1,cUmPrc,c1aUM)
	Recalc(cUmPreco,c1aUmProd) //--<< Recalculo os Dados dos Totais >>--
Return

/** {Protheus.doc} MntStatus
Seta as Cores de Acordo Com o Tipo do Componente NK7

@author: 	Equipe AgroIndustria
@Uso...: 	SIGAARM - Originação de Grãos
*/
Static Function MntStatus()
	cColor :=''
    If Len(aCompPrc) > 0
        Do Case
            Case ALLTRIM(aCompPrc[oBrwComp:NAT,14])='P'
            cColor = 'Br_Azul'
            Case ALLTRIM(aCompPrc[oBrwComp:NAT,14])='C'
            cColor = 'Br_Vermelho'
            Case ALLTRIM(aCompPrc[oBrwComp:NAT,14])='I'
            cColor = 'Br_Amarelo'
            Case ALLTRIM(aCompPrc[oBrwComp:NAT,14])='T'
            cColor = 'Br_Cinza'
            Case ALLTRIM(aCompPrc[oBrwComp:NAT,14])='R'
            cColor = 'Br_Verde'
        EndCase	
    EndIf
Return cColor

/** {Protheus.doc} Mntlegend
Função para montar a legenda da Browse.

@author: 	Emerson	
@since:		30/10/2014
@Uso...: 	SIGAARM - Originação de Grãos
*/
Static Function MntLegend()
	Local oLegenda  :=  FWLegend():New()

	oLegenda:Add( '', 'BR_AZUL', 		STR0014 )		//'Preço'
	oLegenda:Add( '', 'BR_VERMELHO'	, 	STR0015 )		//'Custo'
	oLegenda:Add( '', 'BR_AMARELO'	, 	STR0016 )		//'Informativo'
	IF __lCallPV 	
		oLegenda:Add( '', 'BR_CINZA'	, 	STR0035 )		//'Tributo'
		oLegenda:Add( '', 'BR_VERDE'	, 	STR0036 )		//'Resultado'
	EndIF
	oLegenda:Activate()
	oLegenda:View()
	oLegenda:DeActivate()
Return Nil


/** {Protheus.doc} fArrayNKA
Função Que gera array para a Gravação da NKA

@author: 	Emerson	
@since:		30/10/2014
@Uso...: 	SIGAARM - Originação de Grãos
*/
Static Function fArrayNKA( cContrato, nCtrMoeda ,cUmPrc, cUmProd,	aCompaux,aGravaNKA )
	Local nI        := 1
	Local cItemFx   := 0
	Local cTpValor  := "" //--<< 1=Componente , 2=Margem , 3=Total >>--
	/*/--<< Composicao do Array aGravaNKA >>--
	01 _CODCTR
	02 _ITEMFX
	03	_CODCOM	
	04	_ITEMCO	
	05	_CODIDX	
	06	_DESCRI		
	07	_TPVALOR	
	08	_MOEDCO	
	09	_UMCOM	
	10	_VLRIDX	
	11	_VLRCOM	
	12	_MOEDCT	
	13	_UMPRC	
	14	_VLRUN1	
	15	_UMPROD	
	16	_VLRUN2
	17 _Ctacao
	--<< Fim Comp.  do Array AGravaNKA >>--	
	/*/		

	For nI := 1 to len(aCompAux) Step 1 //--<< Leio todos os Componentes >>--
		IF 	AllTrim( aCompaux[nI,16] ) == 'N'
			cTpValor:= '1' //--<< Dado refere-se a um Componente >>-
		Else
			cTpValor:= '2' 				//--<< Dado refere-se a Margem			 				>>-
		EndIF

		aAdd(agravaNKA , {;
		cContrato,;
		cItemFx,;
		aCompAux[nI,1],;
		aCompAux[nI,2],;
		aCompAux[nI,3],;
		aCompAux[nI,4],;
		cTpValor,;
		aCompAux[nI,5],;
		aCompAux[nI,7],;
		aCompAux[nI,8],;
		aCompAux[nI,9],;
		nCtrMoeda,;
		cUmPrc,;
		aCompAux[nI,10],;
		cUmProd,;
		aCompAux[nI,11],;
		aCompAux[nI,6];
		})
	Next nI

	//--<< Tratamento do Vr. Total >>--
	nI-=1
	cTpValor:= '3'
	aAdd(agravaNKA , {;
	cContrato,;
	cItemFx,;
	/* O _CODCOM Fica como total para Não dar Problemas na Gravação */		STR0027,;	//"TOTAL" 
	'',;
	'',;
	STR0027,;	//"TOTAL"
	cTpValor,;
	nCtrMoeda,;
	CumPrc,;
	nPrcCalc1,;
	nPrcProp1,;
	nCtrMoeda,;
	cUmPrc,;
	nPrcCalc2,;
	cUmProd,;
	nPrcProp2,;
	0;
	})
Return ( .t. )

/** {Protheus.doc} fTxaCot
Funcao que Encontra indice multiplicador de conversao de moeda
@author: 	Emerson	
@since:		30/10/2014
@Uso...: 	SIGAARM - Originação de Grãos
*/
Static Function fTxaCot( nMoedaComp, nMoedactr, dDtfixacao, nTaxConPV)
	Local nTxaComp 	:= 0
	Local nTxaCtr	:= 0    
    
	//--<<  Ao Final do IF, o nTxaComp, Contera um indice multiplicador de conversao de moeda 	>>--
	//--<< Baseado na Moeda do Componente e Moeda do Contrato										>>--
	IF ! nMoedaComp = nMoedaCtr //--<< a Moeda do indice não é Igual a Moeda do Ctrato >>--
		
		if !__lCallPV 
			nTxaComp := 0 	//--<< Ctacao da Moeda do Componente 	>>--
			nTxaCtr  := 0 	//--<< Ctacao da Moeda do Ctrato 		>>--
			DBSelectArea("SM2")
			SM2->(DBSetOrder(1) )
			SM2->( DbSeek( DtoS( dDtFixacao) ) )
	
			nTxaComp := &('SM2->M2_MOEDA'+ STRZERO(nMoedaComp,1) )		
			nTxaCtr	 := &('SM2->M2_MOEDA'+ STRZERO(nMoedaCtr,1) )
        Else
			 nTxaComp := nTaxConPV
			 nTxaCtr  := nTaxConPV
        EndIf
            
		IF  ! nMoedaCtr == 1 //--<< Se a Moeda do Ctrato não for a Moeda Padrao >>--
			IF  nMoedaComp == 1 //--<< Se a Moeda do componente for a Moeda Padrao >>--
				nTxaComp := 1 / nTxaCtr
			ElseIF __lCallPV   								 //--<< Não é a moeda padrão
			    nTxaComp := nTaxConPV
		    Else 		
				nTxaComp :=  nTxaCtr / nTxaComp
			EndIF
		EndIf
	Else
		nTxacomp := 1
	EndIF
Return ( nTxaComp )

/*{Protheus.doc} fLoadArray
Função Que Preenche o Grid com os Dados Do Array Recebido

@sample 	fLoadArray( aCompPrc , cUM_Ctrato , dDtFixacao )
@author  	Emerson coelho
@version 	P11 
@Since   	30/10/2014
*/
Static Function fLoadArray( aReadNKA , cUM_Ctrato , dDtFixacao )
	Local aComporPrc 	:={}
	Local nI        	:= 1		
	Local nTxaComp    	:= 0
	Local nMoedaComp  	:= ""	
	Local nQtUMPrc		:= 0
	Local nQt1AUM		:= 0
	Local cNK8_UM1PRO 	:= ""
	Local cUmPRC       	:= ""
	Local c1aUM		 	:= ""
	Local nVrInd1    	:= 0
	Local nVrInd2    	:= 0
	Local cOrdenacao  	:= ""
	Local nVrIndice   	:= 0
	Local nPostotal   	:= 0

	/*/--<< Composicao do Array aReadNKA >>--
	01 _CODCTR
	02 _ITEMFX
	03 _CODCOM	
	04 _ITEMCO	
	05 _CODIDX	
	06 _DESCRI		
	07 _TPVALOR	
	08 _MOEDCO	
	09 _UMCOM	
	10 _VLRIDX	
	11 _VLRCOM	
	12 _MOEDCT	
	13 _UMPRC	
	14 _VLRUN1	
	15 _UMPROD	
	16 _VLRUN2
	17 _Ctacao
	--<< Fim Comp.  do Array aReadNKA >>--/*/		

	aComporPrc :={}

	For nI := 1 to len( aReadNKA ) Step 1 	//--<< Leio todos os Componentes >>--
		IF aReadNKA[nI,07] == '3'  			//--<< Registro de TOTAL //
			Loop
		EndIF
		nMoedaComp 		:= aReadNKA[nI,08] 	// Moeda do Componente
		nMoedaCTra 		:= aReadNKA[nI,12]	// Moeda do Contrato

		cNK8_UM1PRO 	:= aReadNKA[nI,09]	// UM, do componente
		cUmPRC  	    := aReadNKA[nI,13]	// Unid. Medida de Preco
		c1aUM	        := aReadNKA[nI,15]	// Unid Med. do Produto

		nTxacomp 		:= aReadNKA[nI,17]	//Txa de Cotacao
		nVrIndice		:= aReadNKA[nI,10]	//Vr. do Indice

		/*/
		!-----------------------------------------------------------------	!
		!Conversao de UM do Indice  Para a UM do Preco do Produto			!
		!Ex. indice esta em TN e a Unidade de medida de preco eh em kg		!
		!Obtendo a correspondencia de TN para KG por Exemplo					!
		!-----------------------------------------------------------------	!
		/*/
		nQtUMPrc := AGRX001( cNK8_UM1PRO ,cUmPrc,1, cProdCmp)

		/*/
		!--------------------------------------------------------------!
		!Conversao de UM do Indice  Para a 1a UM do Produto				!
		!Ex. indice esta em TN e a Unidade de medida do produto em kg	!
		!Obtendo a correspondencia de TN para KG por Exemplo				!
		!--------------------------------------------------------------!
		/*/
		nQt1AUM:= AGRX001( cNK8_UM1PRO ,c1aUM,1, cProdCmp)

		nVrind1 := ( nVrIndice * nTxaComp / nQtUMPrc )  //--<< contem o Vr do Indice na   Um de Preco do produto e na Moeda do Contrato>>--
		nVrind2 := ( nVrIndice * nTxaComp / nQt1aUM  )  //--<< contem o Vr do Indice na 1aUm          do produto e na Moeda do Contrato>>--

		dbSelectArea("NK7")
		NK7->( dbSetOrder(1) )
		NK7->(DbSeek(xFilial("NK7") + aReadNKA[nI,03] ))

		//--<< Case que irá Ordenar as Linha do Browse na Seguinte ordem Preco,Custo,Informativo >>
		Do Case
			Case Alltrim(NK7->NK7_CALCUL) == 'P'
			cOrdenacao := 'A'
			Case Alltrim(NK7->NK7_CALCUL) == 'C'
			cOrdenacao := "B"
			Case Alltrim(NK7->NK7_CALCUL) == 'I'
			cOrdenacao := 'C'
			Case Alltrim(NK7->NK7_UTILIZ) == 'M'  //--<< Margem sera o ultimo >>--
			cOrdenacao := 'D'
		EndCase

		aAdd(aComporPrc , {;
		aReadNKA[nI,03],;
		aReadNKA[nI,04],;
		aReadNKA[nI,05],;
		aReadNKA[nI,06],;
		aReadNKA[nI,08],;
		nTxaComp,;
		aReadNKA[nI,09],;
		aReadNKA[nI,10],;
		aReadNKA[nI,11],;
		aReadNKA[nI,14],;
		aReadNKA[nI,16],;
		nQtUMPrc,;
		nQt1aUM,;
		NK7->NK7_CALCUL,;
		cOrdenacao,;
		NK7->NK7_UTILIZ;
		})
	Next nI

	//--<< Tratamento do Total >>--
	//--<< Faço tratamento da margem >>--

	nPosTotal := aSCAN(aReadNKA, {|aReadNKA| aReadNKA[07] == "3" })
	IF nPosTotal > 0
		nPrcCalc1	:= aReadNKA[nPosTotal,10]
		nPrcProp1	:= aReadNKA[nPosTotal,11]
		nPrcCalc2	:= aReadNKA[nPosTotal,14]
		nPrcProp2	:= aReadNKA[nPosTotal,16]
	EndIF

Return ( aComporPRC )

//------------------------------------------------------------------------------
/*/ {Protheus.doc} oGa420NKAW
Função Que Grava a Tabela NKA

@sample 	fLoadArray( aCompPrc )
@Parametros:  aGravaNKA - Recebe array com os Dados a Serem Gravados
--<< Composicao do Array aGravaNKA >>--
01 _CODCTR
02 _ITEMFX
03	_CODCOM	
04	_ITEMCO	
05	_CODIDX	
06	_DESCRI		
07	_TPVALOR	
08	_MOEDCO	
09	_UMCOM	
10	_VLRIDX	
11	_VLRCOM	
12	_MOEDCT	
13	_UMPRC	
14	_VLRUN1	
15	_UMPROD	
16	_VLRUN2
17 _Ctacao
--<< Fim Comp.  do Array AGravaNKA >>--	
@author	Emerson
@since		30/10/2014
@version	P11
/*/
//------------------------------------------------------------------------------
Function OGA420NKAW( aGravaNKA, cNkaItemFx )
	Local nI 			:= 1
	Local lGrava 		:= .f.
	Local cNkaCodCtr	:=''
	Local cNkaCodcom	:=''
	Local cNkaItemCo	:=''

	BEGIN TRANSACTION
	dbSelectArea("NKA")
	NKA->( dbSetOrder(1) ) //"Contrato + Item Fixacao "

	For nI:=1 to Len(aGravaNKA) Step 1

		cNKACODCTR := aGravaNKA[ni,1]
		cNKACODCOM := aGravaNKA[ni,3]
		cNKAITEMCO := aGravaNKA[ni,4]

		lGrava := NKA->(DbSeek(xFilial("NKA") + cNkaCodCtr + cNKaItemFx + cNkaCodCom + cNkaItemCo ))

		RecLock("NKA", !lGrava )
		NKA->NKA_FILIAL 	:= XFILIAL('NKA')
		NKA->NKA_CODCTR 	:= aGravaNKA[ nI , 01 ]
		NKA->NKA_ITEMFX 	:= cNkaItemFx // aGravaNKA[ nI , 02 ]
		NKA->NKA_CODCOM 	:= aGravaNKA[ nI , 03 ]
		NKA->NKA_ITEMCO 	:= aGravaNKA[ nI , 04 ]
		NKA->NKA_CODIDX 	:= aGravaNKA[ nI , 05 ]
		NKA->NKA_DESCRI 	:= aGravaNKA[ nI , 06 ]
		NKA->NKA_TPVLR		:= aGravaNKA[ nI , 07 ]
		NKA->NKA_MOEDCO 	:= aGravaNKA[ nI , 08 ]
		NKA->NKA_UMCOM 		:= aGravaNKA[ nI , 09 ]
		NKA->NKA_VLRIDX 	:= aGravaNKA[ nI , 10 ]
		NKA->NKA_VLRCOM 	:= aGravaNKA[ nI , 11 ]
		NKA->NKA_MOEDCT 	:= aGravaNKA[ nI , 12 ]
		NKA->NKA_UMPRC 		:= aGravaNKA[ nI , 13 ]
		NKA->NKA_VLRUN1 	:= aGravaNKA[ nI , 14 ]
		NKA->NKA_UMPROD 	:= aGravaNKA[ nI , 15 ]
		NKA->NKA_VLRUN2 	:= aGravaNKA[ nI , 16 ]
		NKA->NKA_TXACOT 	:= aGravaNKA[ nI , 17 ]

		NKA->(msUnLock())
	Next Ni
	END TRANSACTION
Return

//------------------------------------------------------------------------------
/*/ {Protheus.doc} oGa420NKAR
Função Que Le a Tabela NKA E ABASTECE O Array aCompPrc de Retorno
@sample 	fLoadArray( cNrCtrato , cNkaItemFx )
@Parametros:  Numero do Contrato ( NJR_Codigo )
Numero do Item de Fixacao ( NKA_ITEMFX )
@Parametros:  aGravaNKA - Recebe array com os Dados a Serem Gravados
--<< Composicao do Array aGravaNKA >>--
01 _CODCTR
02 _ITEMFX
03	_CODCOM	
04	_ITEMCO	
05	_CODIDX	
06	_DESCRI		
07	_TPVALOR	
08	_MOEDCO	
09	_UMCOM	
10	_VLRIDX	
11	_VLRCOM	
12	_MOEDCT	
13	_UMPRC	
14	_VLRUN1	
15	_UMPROD	
16	_VLRUN2
17 _Ctacao
--<< Fim Comp.  do Array aReadNKA >>--	
@author	Emerson
@since		30/10/2014
@version	P11
/*/
//------------------------------------------------------------------------------
Function oGa420NKAR( cNrCtrato , cNkaItemFx )
	Local aReadNKA:= {}

	dbSelectArea("NKA")
	NKA->( dbSetOrder(1) )
	NKA->(DbSeek(xFilial("NKA") + cNrCtrato + cNkaItemFx ))
	While NKA->(NKA_FILIAL + NKA_CODCTR + NKA_ITEMFX ) == XFILIAL('NKA') + cNrCtrato + cNkaItemFx
		aAdd(aReadNKA ,{;
		NKA->NKA_CODCTR,;
		NKA->NKA_ITEMFX,;
		NKA->NKA_CODCOM,;
		NKA->NKA_ITEMCO,;
		NKA->NKA_CODIDX,;
		NKA->NKA_DESCRI,;
		NKA->NKA_TPVLR,;
		NKA->NKA_MOEDCO,;
		NKA->NKA_UMCOM,;
		NKA->NKA_VLRIDX,;
		NKA->NKA_VLRCOM,;
		NKA->NKA_MOEDCT,;
		NKA->NKA_UMPRC,;
		NKA->NKA_VLRUN1,;
		NKA->NKA_UMPROD,;
		NKA->NKA_VLRUN2,;
		NKA->NKA_TXACOT;
		})
		NKA->( dbSkip() )
	EndDo

Return ( aReadNKA )

/** {Protheus.doc} oGa420NKAD
Função Que Deleta os Registros da NKA de um determinado contrato e Item de Fixação

@Parametros:  Numero do Contrato ( NJR_Codigo )
Numero do Item de Fixacao ( NKA_ITEMFX )
@Parametros:  aGravaNKA - Recebe array com os Dados a Serem Gra
@author: 	Emerson	
@since:		30/10/2014
@Uso...: 	SIGAARM - Originação de Grãos
*/
Function oGa420NKAD ( cNrCtrato , cNkaItemFx )

	BEGIN TRANSACTION
	DbSelectArea("NKA")
	NKA->( dbSetOrder(1) )
	NKA->(DbSeek(xFilial("NKA") + cNrCtrato + cNkaItemFx ))

	While NKA->(NKA_FILIAL + NKA_CODCTR + NKA_ITEMFX ) == XFILIAL('NKA') + cNrCtrato + cNkaItemFx

		Reclock('NKA',.f.)

		NKA->( DbDelete() )
		NKA->( dbSkip() )
	EndDo

	END TRANSACTION

	Return ( nIl )
	**************

/** {Protheus.doc} fValConvum
Rotina que verifica se foi possivel converter uma Un. Medida para Outra

@param: 	Um. Origem, Um.destino, Qtd. na UM origem
Retorno:  	Verdadeiro(.t.) Indicando q foi possivel converter, Falso(.f.) indicando que não foi Possivel 
@author: 	Emerson Coelho
@since: 	02/10/2014
@Uso: 		SIGAARM - Originação de Grãos
*/
Function fValConvUM(cUMOrig, cUMDest, nValor)
	Local aAreaAnt := GetArea()
	Local nValConv := 0
	Local lConverteu := .f.

	dbSelectArea('NNX')
	dbSetOrder(1)
	If dbSeek(xFilial('NNX')+cUMOrig+cUMDest)
		Do Case
			Case NNX->NNX_OPERA == '/'
			lConverteu := .t.
			Case NNX->NNX_OPERA == '*'
			lConverteu := .t.
			OtherWise
			lConverteu := .f.
		EndCase
	Else
		If dbSeek(xFilial('NNX')+cUMDest+cUMOrig)
			Do Case
				Case NNX->NNX_OPERA == '/'
				lConverteu := .t.
				Case NNX->NNX_OPERA == '*'
				lConverteu := .t.
				OtherWise
				nValConv := nValor
				lConverteu := .f.
			EndCase
		Else
			lConverteu :=.f.
		EndIf
	EndIf

	RestArea(aAreaAnt)
Return( lConverteu )

/** {Protheus.doc} fMensUM
Rotina que Monta mensagem informando que não foi possivel executar a conversao entre:
UMs dos componentes de fixação x Um de Preco;
UMs dos componentes de fixação x 1a UM. do produto;
UM  do  Contrato x x 1a UM. do produto;
@param:   Unidade de Medida origem e Destino
Retorno:  Alimenta a variavel cUMNaoConv contendo mensagem informando que não foi possivel executar a conversão 
@author: 	Emerson Coelho
@since: 	02/10/2014
@Uso: 		SIGAARM - Originação de Grãos
*/
Static function fMensUM(UmOri , UmDest)
	Local cUmNaoConv	:=''
	Local nPos			:=0

	cUmNaoConv += STR0017 + '	' + UmOri + '	' + STR0018 + '	' + UmDest   // DE:###Para:
	nPos:=ascan(aUMNaoConv , cUmNaoConv )
	IF npos == 0 //--<< Não consta no array, então eu adiciono >>--
		aAdd( aUMNaoConv , cUmNaoConv )
	EndIF
Return(nil)

/** {Protheus.doc} SfCovUMVal
Rotina que converte unidade de medida em valores

@param.: 	VlrIndice, Um.Origem, Um.Destino
Retorno: 	Valor do Indice Convertido 
@since.: 	02/10/2014
@Uso...: 	SIGAARM - Originação de Grãos
*/
Static Function SfCovUMVal(nVlrIndice, cUMOrig, cUMDest)
	Local aAreaAnt 	:= GetArea()
	Local nValConv 	:= 0
	Local nQtUM		:= 0

	//Encontra o valor da qt
	nQtUM	:= AGRX001(cUMDest, cUMOrig,1, /*cProduto*/)
	
	nValConv := nVlrIndice * nQtUM
	
	RestArea(aAreaAnt)
Return( nValConv )

/** {Protheus.doc} fRefresh
Função que realiza o refresh dos componentes

@author: 	Ana Laura Olegini	
@since:		01/04/2016
@Uso...: 	SIGAARM - Originação de Grãos
*/
Static Function fRefresh(cProdCmp , cNK7Apl, dDt_aFixar, cContrato,cUmPreco,nQtidade,dDt_EntIni , dDt_EntFim, cGrupo,c1aUmProd, nTratoMoed, c1aUmProd, lEdit)
	Local aComprcBKP 	:= aCompPrc
	Local lcontinua		:= .t.

	//Se for um contrato do tipo fixo e possuir entregas NN8 
	If lEdit == .F.
		Aviso(STR0020, STR0021,{STR0022}) //"Atenção"#"Não foi possivel converter as Unidades de Medida:#Voltar
		Return( .t. )
	EndIf 

	If MsgYesNo(STR0023, STR0024)  		//"Tem certeza que deseja realizar o refresh?"#"Refresh Composição de Preço"
		//limpa o array para atualizar em tela
		aCompPrc := {}

		//funcao para atualizar o array
		lContinua := fGetComp(cProdCmp , cNK7Apl, dDt_aFixar, cContrato,cUmPreco,nQtidade,dDt_EntIni , dDt_EntFim, cGrupo,c1aUmProd, nTratoMoed, c1aUmProd, cGrupo)
		IF ! lContinua
			aCompPrc := aComprcBKP
			Aviso(STR0020,STR0025,{STR0022})	//"Atenção"#"Não foi possivel realizar o Refresh."#Voltar
		EndIF

		//ordena para mostrar em tela pelas posições 15 e 04
		aSortLines := ASORT(aCompPrc,,, { |x, y| (x[15]+x[04]) < (y[15]+y[04]) })
		aCompPrc   := Aclone( aSortLines )

		//Seta o objeto do browser com as novas informações do array
		oBrwComp:SetArray(aCompPrc)    
		oBrwComp:Refresh()
	Else
		Return()
	EndIf	
Return( .t. )

/** {Protheus.doc} fGetComp
Atualiza o array aCompPrc

@param.: 	cProdCmp , cNK7Apl, dDt_aFixar, cContrato,cUmPreco,nQtidade,dDt_EntIni , dDt_EntFim, cGrupo,c1aUmProd, nTratoMoed, c1aUmProd
@since.: 	01/04/2016
@Uso...: 	SIGAARM - Originação de Grãos
*/
Static Function fGetComp(cProdCmp , cNK7Apl, dDt_aFixar, cContrato,cUmPreco,nQtidade,dDt_EntIni , dDt_EntFim, cGrupo,c1aUmProd, nTratoMoed, c1aUmProd, cGrupo)
	Local cPulaLinha	 	:= CHR(13) + CHR(10)
	Local cUmNaoConv  		:= ""
	Local nI 				:= 0

	//--<< Processo Componentes que são do Tipo Normal >>---
	aUmNaoConv:={}

	If cTipoFix == '0' .and. (cPaisLoc == "PAR" .or. cPaisLoc == "ARG")  //0=prevista //DAGROGAP-1445
		aCompPrc := {}
	Else	
        cTpComp := 'N'
        fQryComp(cProdCmp , cNK7Apl, dDt_aFixar, cContrato,cUmPreco,nQtidade,dDt_EntIni , dDt_EntFim, cGrupo,c1aUmProd, nTratoMoed, cTpComp)

        //--<< Processa os Componentes do Tipo Margem >>--
        cTpComp := 'M'
        fQryComp(cProdCmp , cNK7Apl, dDt_aFixar, cContrato,cUmPreco,nQtidade,dDt_EntIni , dDt_EntFim, cGrupo,c1aUmProd, nTratoMoed,cTpComp)
    EndIf

	IF ! Alltrim( c1aUmProd ) = Alltrim ( c1aUmProd ) //Unidades de Medidas diferentes
		IF !fValConvUM( c1aUmProd ,c1aUmProd,1)  //--<< Garantindo Integridade da UM do cTrato e 1aUm Produto >>--
			fMensUM( c1aUmProd ,c1aUmProd ) //monta mensagem inform. que Conversao entre U.Ms. de componentes de fixacao x Um Preco x UmProduto x Um contrato não são possiveis
		EndIF
	EndIF

	IF len(aUmNaoConv) > 0 // Este array contem todas as Unidades de medidas que n. foram possiveis de converter o q Indica erro, no calculo.
		cUmNaoConv := STR0019 + cPulaLInha  //Não foi possivel converter as Unidades de Medida:

		For nI := 1 to Len( aUmNaoConv ) Step 1
			cUmNaoConv += aUmNaoConv[nI] + cPulaLInha
		Next nI
		cUmNaoConv+= cPulaLinha
		Aviso(STR0020,cUmNaoConv,{STR0021}) //"ATENCAO"###"Não foi possivel converter as Unidades de Medida:###Voltar
		Return( .f. )

	EndIF

	//--<< Refaz Todos os Calculos >>--
	Recalc(cUmPreco,c1aUmProd)
Return( .t. )


/*
Vr. Unitario	na UM do Produto
Vr. Unitario	na UM de preço
Vr. Total 		na UM do produto
Vr. Total 		na UM de preco
*/
Static function fMudouTots(nUnCalcUm1, nUnCalcUmP, nTotCalUm1, nUnPropUm1, nUnPrpUmP, nTotPrpUmp )
	Local oModel    	:= nil
	Local oView			:= nil
	
	IF IsInCallStatck('OGA460') .and. ledit	// Se foi Chamado do OGA460   //.and. otela:classname() == "TPANELCSS"  // Panel da View
		oModel    		:= FWModelActive()
		oView         	:= FWViewActive()	
		If oModel:GetModel("OGA460_NKN"):IsActive()
		
		If !oModel:GetValue( "OGA460_NKN", "NKN_UNCUM1") = nUnCalcUm1
			oModel:SetValue( "OGA460_NKN", "NKN_UNCUM1", nUnCalcUm1 ) // Un Um1 	Calculado
			oView:lModify := .T. 	
		EndIf
		If !oModel:GetValue( "OGA460_NKN", "NKN_UNCUMP") = nUnCalcUmP
			oModel:SetValue( "OGA460_NKN", "NKN_UNCUMP", nUnCalcUmP ) // Un Um Prc	Calculado
			oView:lModify := .T.
		EndIf
		If !oModel:GetValue( "OGA460_NKN", "NKN_TOCUM1") = nTotCalUm1
			oModel:SetValue( "OGA460_NKN", "NKN_TOCUM1", nTotCalUm1 ) // Total Um1 	Calculado
			oView:lModify := .T.					
		EndIf
		If !oModel:GetValue( "OGA460_NKN", "NKN_UNPUM1") = nUnPropUm1
			oModel:SetValue( "OGA460_NKN", "NKN_UNPUM1", nUnPropUm1 ) // Un Um1 	Proposto
			oView:lModify := .T.
		EndIf
		If !oModel:GetValue( "OGA460_NKN", "NKN_UNPUMP") = nUnPrpUmP
			oModel:SetValue( "OGA460_NKN", "NKN_UNPUMP", nUnPrpUmP  ) // Un Um Prc	Proposto
			oView:lModify := .T.
		EndIf	
		If !oModel:GetValue( "OGA460_NKN", "NKN_TOPUM1") = nTotPrpUmp
			oModel:SetValue( "OGA460_NKN", "NKN_TOPUM1", nTotPrpUmp ) // Total Um1 	Proposto	
			oView:lModify := .T.		
		EndIf
		
		IF valType(oView) == 'O'
			oView:Refresh('OGA460_NKN')
		EndIF
		EndIf 
	EndIf
Return ( .t. )


/** {Protheus.doc} SetColObrw
Define as colunas do Browse, e Ajusta
as colunas que podem ser alteradas

@param.: 	nil
@since.: 	01/04/2016
@Uso...: 	SIGAARM - Originação de Grãos
*/
Static Function SetColObrw()
	Local aBrowseCol := {}
	
	//Titulo,obrwforn1 na Linha Atual recebe o q sta no array ,Tipo,Picture ,AlinhaEsquerda,Tamanho,Decimais
	oBrwComp:AddStatusColumns ( {|| MntStatus() },{|| MntLegend( ) } )	//	Adiciona Coluna de Status

	aAdd(aBrowseCol, {cCol1Tit	,{||IIF(Len(aCompPrc) > 0 , aCompPrc[oBrwComp:NAT,04], Nil)}  			,   'C'   ,'@!'    					, 1    ,30     	,0  })
	aAdd(aBrowseCol, {cCol2Tit	,{||IIF(Len(aCompPrc) > 0 , fDesMoeda(aCompPrc[oBrwComp:NAT,05] ), Nil)} 	,  	'C'   ,'@!' 					, 1    ,05		,0  })
	aAdd(aBrowseCol, {cCol3tit 	,{||IIF(Len(aCompPrc) > 0 , aCompPrc[oBrwComp:NAT,06], Nil)}  			,   'N'   ,'@E 9,999,999.999999'	, 2    ,06     	,6  })
	aAdd(aBrowseCol, {cCol4tit 	,{||IIF(Len(aCompPrc) > 0 , Alltrim(aCompPrc[oBrwComp:NAT,07]), Nil)}  	,   'C'   ,'@!'    					, 1    ,03     	,0  })
	If !__lCallPV 
		aAdd(aBrowseCol, {cCol5tit 	,{||IIF(Len(aCompPrc) > 0 , aCompPrc[oBrwComp:NAT,08], Nil)}  			,   'N'   ,'@E 9,999,999.999999' 	, 2    ,06     	,6	})
	EndIF
	aAdd(aBrowseCol, {cCol6tit 	,{||IIF(Len(aCompPrc) > 0 , aCompPrc[oBrwComp:NAT,09], Nil)}  			,   'N'   ,'@E 9,999,999.999999'	, 2    ,06     	,6	})
	aAdd(aBrowseCol, {cCol7tit 	,{||IIF(Len(aCompPrc) > 0 , aCompPrc[oBrwComp:NAT,10], Nil)} 	 			,   'N'   ,'@E 9,999,999.999999'	, 2    ,06     	,6	})
	aAdd(aBrowseCol, {cCol8tit	,{||IIF(Len(aCompPrc) > 0 , aCompPrc[oBrwComp:NAT,11], Nil)}  			,	'N'   ,'@E 9,999,999.999999'	, 2    ,06     	,6	})
	
	oBrwComp:setcolumns( aBrowseCol )
	
	If !__lCallPV 
		If Len(aCompPrc) > 0
			obrwComp:acolumns[4]:ledit		:= .t. 				// indica que a 3 coluna eh editavel
			obrwComp:acolumns[7]:ledit		:= .t. 				// indica que a 4 coluna eh editavel
		EndIF
		obrwComp:acolumns[4]:cReadVar	:= 'aCompPrc[oBrwComp:nat,6]'
		obrwComp:acolumns[7]:cReadVar	:= 'aCompPrc[oBrwComp:nat,9]'
	EndIf

Return()

//------------------------------------------------------------------------------
/*/ {Protheus.doc} CpIteOrig
Função Que Le a Tabela NKA do item de fixação anterior para carregar 
os valores no item de fixação novo(ROLOVER)
@sample 	CpIteOrig( cNrCtrato , cNkaItemFx )
@Parametros:  Numero do Contrato ( NN8_CODIGO )

@Parametros:  cNrCtrato - Numero do contrato
@author		Claudineia 
@since		15/09/2017
@version	P12.1.18
/*/
//------------------------------------------------------------------------------
Static Function CpIteOrig( cNN8Ctr , cNN8ItFx )
	//DAGROGAP-1445
	Local nPosComp := nil
	dbSelectArea("NKA")
	NKA->( dbSetOrder(1) )
	NKA->(DbSeek(xFilial("NKA") + cNN8Ctr + cNN8ItFx ))
	While NKA->(NKA_FILIAL + NKA_CODCTR + NKA_ITEMFX ) == XFILIAL('NKA') + cNN8Ctr + cNN8ItFx
		nPosComp := aSCAN(aCompPrc, {|aCompPrc| aCompPrc[01]+aCompPrc[02]+aCompPrc[03] == NKA->NKA_CODCOM+NKA->NKA_ITEMCO+NKA->NKA_CODIDX })
		If nPosComp > 0
			aCompPrc[nPosComp, 09]	:= NKA->NKA_VLRCOM //VALOR COMPONENTE			
		EndIf
		NKA->( dbSkip() )
	EndDo

Return .T.

/** {Protheus.doc} fEditLine
Função para permitir editar a celula

@author: 	claudineia	
@since:		18/09/2017
@Uso...: 	SIGAARM - Originação de Grãos
*/
Static function fEditLine()	
	Local nLinPos := obrwcomp:nat
	Local lEdit := .T. //Permite EDIÇÃO

	If  cPaisLoc == "PAR" .or. cPaisLoc == "ARG"
		dbSelectArea("NN8")
		NN8->( dbSetOrder(1) )
		NN8->(DbSeek(xFilial("NN8") + cContrato + cItOrig ))
		If cTipoFix == '1' .AND. (NN8->NN8_TIPOFX == '1' .OR. NN8->NN8_TIPOFX == '2')  //SE NOVA FIXAÇÃO = FIRME E FIXAÇÃO ORIGEM = BASIS OU FIRME  
			NK7->( dbSetOrder(1) )
			NK7->(DbSeek(xFilial("NK7") + Alltrim(aCompPrc[nLinPos, 01 ]) ))
			If NK7->NK7_GRUPO == '1' //COMPONENTE É BASIS
				lEdit := .F. //BLOQUEIA EDIÇÃO
			Else
				lEdit := .T. //Permite EDIÇÃO
			EndIf
		EndIf

		obrwComp:acolumns[7]:ledit:= lEdit 

	EndIf

Return ()

/** {Protheus.doc} fRefIdcMd
Função disponivel na tela atraves do botão "Outras Ações"->"Atualizar Taxas" 
quando chamado pelas rotinas de contrato de compra(OGA280)
e contrato de venda(OGA290) 

@author: 	Claudineia Reinert	
@since:		05/07/2017
@Uso...: 	OGA420
*/
Static Function fRefIdcMd(dDt_aFixar , nTratoMoed, cUmPreco, c1aUmProd,lEdit)
	//Se for um contrato do tipo fixo e possuir entregas NN8 
	If lEdit == .F.
		Aviso(STR0020,STR0030,{STR0021})	//"Atenção"#"Não foi possivel realizar o Refresh."#Voltar
		Return( .T. )
	EndIf 

	If MsgYesNo(STR0031, STR0032)  		//"Tem certeza que deseja realizar o refresh?"#"Refresh Composição de Preço"
		
		AtTaxComp(dDt_aFixar, nTratoMoed, cUmPreco, c1aUmProd)
		//Seta o objeto do browser com as novas informações do array
		oBrwComp:SetArray(aCompPrc)    
		oBrwComp:Refresh()

	EndIf
Return( .T. )


/** {Protheus.doc} AtTaxComp
Função que atualiza na tela a cotação da moeda e indice de mercado
chamado tambem na tela de simulação de composição de preço(OGA460),
atraves do botão "Atualizar Taxas"

@author:    Claudineia Heerdt Reinert
@since.:    05/07/2017
@Uso...:    OGA420
*/
Static Function AtTaxComp(dDtFixacao, nMoeda, cUmPreco, c1aUmProd)
	Local nElem			:= 0
	Local nTxaComp 		:= 0
	Local nVrIndice 	:= 0
	Local lRet 			:= .t.

	//função integração M2M - busca atualização de moeda e indoces de mercado
	MsgRun( STR0028 ,STR0029, {|| lRet := IntegM2M(dDtFixacao,nTratoMoed,aCompPrc) } )//"Realizando Atualização de Projeto"

	FOR nElem := 1 To len(aCompPrc)		

		dbSelectArea("NK0")
		NK0->( dbSetOrder(1) )
		If NK0->(DbSeek(xFilial("NK0") +  aCompPrc[nElem, 03] ))
			nVrIndice := AgrGetInd( NK0->NK0_INDICE,NK0->NK0_TPCOTA,dDtFixacao )
		EndIF

		nTxaComp := fTxaCot( aCompPrc[nElem, 05] , nMoeda , dDtfixacao ) //--<< Conversao de Moeda >>--

		aCompPrc[nElem, 06]	:= nTxaComp
		aCompPrc[nElem, 08]	:= nVrIndice

	NEXT nElem

	Recalc(cUmPreco,c1aUmProd)

Return .t.

/** {Protheus.doc} IntegM2M
Função que chama rotina de integração com M2M e atualiza as taxas de moeda e indice de mercado

@author:    Claudineia Heerdt Reinert
@since.:    05/07/2017
@Uso...:    OGA420
*/
Static function IntegM2M(cData,cMoeda,aComp)	
	Local nElem		:= 0
	Local aIndices 	:= {}	
	Local aMoedas	:= {}	
	Local recebe    := ""
	Local cIM 		:= ""
	Local lRet 		:= .t.

	aAdd(aMoedas,cMoeda)
	recebe := "MOEDA"
	lRet := OGX300A(cMoeda,cData, recebe) //atualiza cotação da moeda do contrato

	FOR nElem := 1 To len(aCompPrc)			

		If( aSCAN(aMoedas, cValToChar(aComp[nElem][5]) ) == 0)
			aAdd(aMoedas,cValToChar(aComp[nElem][5]))
			cIM := cValToChar(aComp[nElem][5]) 
			recebe := "MOEDA"
			If !empty(cIM) .and. cIM != "0"
				lRet := OGX300A(cIM,cData, recebe) //atualiza cotação da moeda do componente de preço
			EndIf
		EndIf

		If( aSCAN(aIndices, cValToChar(aComp[nElem][3]) ) == 0)
			aAdd(aIndices,cValToChar(aComp[nElem][3]))
			cIM := cValToChar(aComp[nElem][3]) 
			recebe := "INDICE"
			If !empty(cIM)
				lRet := OGX300A(cIM,cData, recebe) //atualiza cotação da moeda do componente de preço
			EndIf
		EndIf	

	Next nElem	

Return lRet

/*/{Protheus.doc} AgrProdGru
@author vanilda.moggio
@since 07/02/2019
@version 1.0
@return produto 
@param pGrupo 
@type function
/*/
Static Function AgrProdGru (pGrupo, nTipo)
local cRetorno := ''

	dbSelectArea("SB1")
	dbSetOrder(4)
	dbGoTop()
	If dbSeek(fwxFilial("SB1")+ pGrupo,.t.)
	    if nTipo = 2
	     cRetorno := SB1->B1_UM
	    else 
		cRetorno := SB1->B1_COD
		EndIF
	EndIf
return cRetorno	
	
	
/*/{Protheus.doc} AG420NCV
//Buscar o valor especifico do componente do plano de venda 
@author vanilda.moggio
@since 08/02/2019
@version 1.0
@return ${return}, ${return_description}
@param pFilN8Z, , descricao
@param pSafra, , descricao
@param pGrupo, , descricao
@param pProd, , descricao
@param pTpMerc, , descricao
@param pMoen8z, , descricao
@param pCompn8z, , descricao
@type function
/*/
STATIC FUNCTION AG420NCV(pSafra, pGrupo, pProd, pTpMerc, pMoen8z, pCompn8z)
local nRetorno := 0

	cAliasQry2  := GetNextAlias()
	cQuery2 := "SELECT NCV_VALOR  "
	cQuery2 += " FROM " + RetSqlName("NCV") + " NCV "
	cQuery2 += " WHERE NCV.NCV_FILIAL  = '" + xFilial("NCV") + "' "
	cQuery2 += "   AND NCV.NCV_SAFRA  = '" + pSafra + "' "
	cQuery2 += "   AND NCV.NCV_GRPROD = '" + pGrupo + "' "
	cQuery2 += "   AND NCV.NCV_CODPRO = '" + pProd + "' "
	cQuery2 += "   AND NCV.NCV_TIPMER = '" + pTpMerc + "' "
	cQuery2 += "   AND NCV.NCV_MOEDA  = '" + AllTrim(Str(pMoen8z)) + "' "
	cQuery2 += "   AND NCV.NCV_CODCOM = '" + pCompn8z + "' "
	cQuery2 += "   AND (NCV.NCV_FILCOM = '' OR NCV.NCV_FILCOM LIKE '" + AllTrim(N8Y->N8Y_FILIAL) + "%' )"
	cQuery2 += "   AND NCV.NCV_DATVIG <= '" + DtoS(dDt_aFixar) + "' "
	cQuery2 += "   AND NCV.D_E_L_E_T_ = '' "
	cQuery2 += " ORDER BY NCV_DATVIG DESC, NCV_FILCOM DESC "
	cQuery2 := ChangeQuery(cQuery2)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery2),cAliasQry2,.F.,.T.)

	dbSelectArea(cAliasQry2)
	(cAliasQry2)->(dbGoTop())
	If (cAliasQry2)->(!Eof() )
		nRetorno := (cAliasQry2)->NCV_VALOR
	EndIf
	(cAliasQry2)->(DbcloseArea())

return nRetorno	

/*{Protheus.doc} AG420CTPP
Atualiza os valores dos campos totalizadores
@author tamyris.g	
@since 05/03/2019
@version undefined
@param 
@type function
*/
Static Function AG420CTPP(cCodComp,nPerApl,cMoeda,cUniMed,dDtfixacao, nTaxConPV) //totalizar os componentes de resultado
	Local nValorComp := 0
	Local nPos       := 0
	Local nValor     := 0
	
	//procurar na N75 - verificar necessidade de converter os valores (Uniddade de Medida e Moeda)
	DbselectArea( "N75" )
	DbSetOrder( 1 )
	DbGoTop()
	If dbSeek( xFilial( "N75" ) +  cCodComp )
		While !N75->( EoF() ) .And. N75->( N75_FILIAL + N75_CODCOM ) == xFilial( "N75" ) + cCodComp
		
			//Procura o componente
			nPos := aScan( aCompPrc, { |x| AllTrim( x[1] ) == AllTrim(N75->(N75_CODCOP) ) } )
			//seekline
			if nPos > 0
				nValorComp := aCompPrc[npos][9] //Valor Componente
				
				//Converte Unidade de Medida
				If cUniMed <> aCompPrc[npos][7] //UnidMed  
					nValorComp := SfCovUMVal(nValorComp,aCompPrc[npos][7],cUniMed)
				EndIf
				
				//Converte Moeda
				If cMoeda <> aCompPrc[npos][5] //Moeda  
					nTxacomp := fTxaCot( aCompPrc[npos][5], cMoeda , dDtfixacao, nTaxConPV ) //--<< Conversao de Moeda >>--
					If !empty(nTxacomp)
						nValorComp := nValorComp * nTxacomp
					EndIf
				EndIf
				
				nValor += iif(N75->( N75_OPERAC) == "1", 1, -1) * nValorComp 
			endif
			
			N75->( dbSkip() )
		enddo
	endif   
	
	/* Se o componente tiver um % de aplicação, o valor calculado deverá ser reduzido para o % de aplicação informado */ 
	/* Ex.: % Aplicação: 40%, valor calculado do componente = 1,00, valor final 1 * 40/100 = 0,40. */
	If !Empty(nPerApl)
		nValor := nValor *  (nPerApl / 100)
	EndIF
	
	nValor := Round(nValor, TamSX3( "N8W_VLUPFI" )[2] )
			
return nValor

/*/{Protheus.doc} OGA420TOT()
	função centralizada para calcular o total
	@type  Function
	@author mauricio.joao
	@since 24/08/2019
	@version 1.0
	@param nValor, numeric, valor
	@param nQuant, numeric, quantidade
	@param nConvert, numeric, valor para conversao
	@return nTotal, numeric, total calculado.
	/*/
 Function OGA420TOT(nValor, nQuant, nConvert)
 Local nTotal as numeric 
 
	//calcula o total
	If cPaisLoc == "PAR" .Or. cPaisLoc == "ARG" 
		nTotal := nQuant * round((nValor/nConvert),5)        
	Else
		nTotal := nQuant * round((nValor/nConvert),TamSx3('NJM_VLRUNI')[2])        
	EndIf
	
	//arredonda
	nTotal := round(nTotal,2)

Return nTotal
