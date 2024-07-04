#include "OGC061.ch"
#Include "Protheus.ch"
#include "Totvs.ch"
#include "Fwmvcdef.ch"
#include "Rwmake.ch"

#DEFINE MOEDAPERCENTUAL 0
Static oTela	:= nil

/** {Protheus.doc} OGC061
Consulta contratos do item do plano 
@param:		
cProduto 	-	Codigo do produto
dDtfixa 	-	Data da Fixação
dDEntrIni 	-	Data Inicial de Entrega
dDEntrFim 	-	Data Final de Entrega
nQtfixar 	-	Qtidade a Fixar
cTpCtr		-	Tipo do Contrato
cNJRUM1PRO	-	Unidade de Medida do Produto do Ctrato.
cNjrUmPrc	- 	Unidade de Preço do produto do Contrato
nNJRMoeda	- 	Moeda do Ctrato

@Retorno: 	array com dados para gravação da composicao de Preço tabela NKA
@author: 	Equipe AgroIndustria
@since: 	
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGC061( cProduto , dDtfixa , dDEntrIni , dDEntrFim , nQtfixar , cNk7Aplica , cNjrUm1Pro , cNjrUmPrc , nNjrMoeda , nTipMer, cMoeda, cSafra, cGrupo)
	Local cQuery      	:= ""
	Local nVrIndice  	:= 0
	Local nVrInd1   	:= 0
	Local nVrInd2  		:= 0
	Local nQtUMPRC    	:= 0
	Local nQt1AUM    	:= 0
	Local cOrdenacao 	:= 0
	Local nVlrComp      := 0
	Local cUmprc        := ''
	Local c1aUMb5     	:= Posicione("SB5", 1, FwxFilial("SB5")+cProduto, "B5_UMPRC")
	Local nVlPvComp     := 0 
		
	Private oFontAta  		:= TFont():New("Arial",,16,,.F.,,,,,.F.)
	Private aUMNaoConv 		:= {} 									// Array Utilizado na verificação de Conversão de Unidades de Medidas.
	Private aButtons 		:= {}	
	
	//--<< Titulo das Colunas do Browse >>--	
	Private  cCol0tit      	:= 	AllTrim( RetTitle("NJR_CODCTR") ) 	//"Contrato"
	Private  cCol1tit      	:= 	AllTrim( RetTitle("NKA_CODCOM") ) 	//"Componente"
	Private  cCol2tit      	:=	AllTrim( RetTitle("N9A_QUANT") )	//"Quantidade"
	Private  cCol3tit      	:=	AllTrim( RetTitle("NKA_TXACOT") ) 	//"Cotacao"
	Private  cCol4tit      	:=	'UM.'								//AllTrim( RetTitle("NK8_UM1PRO") )	//"Unidade"
	Private  cCol5tit      	:=	AllTrim( RetTitle("NKA_VLRIDX") )	//"Valor Índice"
	Private  cCol6tit      	:=	AllTrim( RetTitle("NKA_VLRCOM") )	//"Valor Compon."
	Private  cCol7tit      	:=	"" 									// Será Abastecida na Função MntQryComp
	Private  cCol8tit      	:=	"" 		
	Private  cCol9tit      	:=	AllTrim( RetTitle("NK8_MOEDA") )	//"Moeda"
	Private  cCo20tit      	:=	AllTrim( RetTitle("NNY_ITEM") ) 
	Private  cCo21tit      	:=	""
	Private  aCOMPPRC		:= {}
			
	
	// Será Abastecida na Função MntQryComp

    cUmPreco	:= IIF(Empty(cProduto),cUmPreco  , cNjrUmPrc)
    c1aUmProd 	:= IIF(Empty(cProduto),cUm1Preco , cNjrUm1Pro)
    
      	
	//--<< Criação do Browse >>--
	Private oBrwComp  	:= NIL

	IIF( oBrwComp == nil,oBrwComp:=FWBrowse():New(),)
	//------------------------------------------------------------------------

	//--<< Abasteço Variavel de titulo da coluna 6  e 7 do Grid >>--
	cCol7Tit	:=	Alltrim(fDesMoeda( nNJRMoeda )) + "/" + cUmPreco
	cCol8Tit	:=  Alltrim(fDesMoeda( nNJRMoeda )) + "/" + c1aUmProd 
	cCo21Tit	:=  Alltrim(fDesMoeda( nNJRMoeda )) + "/" + c1aUmProd + " Plano"

	//--<<Leio o Produto para Encontrar o Grupo e a 1aUm do Produto>>--
	dbSelectArea("SB1")
	SB1->( dbSetOrder(1) )
	If SB1->(DbSeek(xFilial("SB1") + cProduto ))
	   c1aUmProd  	:= SB1->B1_UM
	EndIF
	

	cQuery := ""
	cQuery += " SELECT NJR_FILIAL, NJR_CODCTR, NNY_ITEM , NKA_CODCOM , N9A_QUANT, NJR_UMPRC, NJR_MOEDA, N8Z_VALFIX, N8Z_TIPVAL, NKA_VLRCOM, NNY_FILORG,N9A_FILORG, NNY_MESEMB,  N9A_SEQPRI, N7M_VALOR,  NK8.* , NK7.*   FROM " + RetSqlName('NJR') + ' NJR '
    
    cQuery += " INNER JOIN " + RetSqlName("NNY") + " NNY ON NNY.NNY_FILIAL = '" + xFilial("NNY") + "' AND NNY.NNY_CODCTR = NJR_CODCTR AND NNY.D_E_L_E_T_  = '' "
        
    cQuery += " INNER JOIN  " + RetSqlName("NKA") + " NKA ON  NKA.NKA_filial = NJR.NJR_FILIAL and NKA.NKA_CODCTR = NJR.NJR_CODCTR  AND NKA.NKA_CODCAD = NNY.NNY_ITEM AND NKA.D_E_L_E_T_ = ''
    
    cQuery += " LEFT JOIN " + RetSqlName('N9A') + " N9A  ON  N9A.N9A_FILIAL = NJR.NJR_FILIAL  AND N9A.N9A_CODCTR = NJR_CODCTR AND N9A.D_E_L_E_T_  = ''"
    cQuery += " AND N9A.N9A_ITEM   = NNY.NNY_ITEM  
    
    cQuery += " LEFT JOIN " + RetSqlName('N7M') + " N7M  ON  N7M.N7M_FILIAL = NJR.NJR_FILIAL AND N7M.N7M_CODCTR = NJR_CODCTR AND N7M.D_E_L_E_T_  = ''"
    cQuery += " AND N7M.N7M_CODCAD  = NNY.NNY_ITEM AND N7M.N7M_CODCOM = NKA.NKA_CODCOM "   
    
    if N7M->(ColumnPos('N7M_DATA')) > 0
		cQuery +=   "  AND N7M_DATA <= '"+  dtos(dDEntrFim) + "' AND N7M_DATA >= '" + dtos(dDEntrIni) + "'"
	endIf
    
    cQuery += " LEFT JOIN  " + RetSqlName("NK8") + " NK8 ON NK8.NK8_filial = '" + xFilial("NK8") + "'  and NK8.NK8_CODCOM = NKA.NKA_CODCOM and NK8.NK8_ITEMCO = NKA.NKA_ITEMCO  
    cQuery += "  AND NK8.NK8_ATIVO = 'S'  AND  ((NK8_CODPRO = '"  +  cProduto + "' and NK8_GRPPRO = '" + cGrupo + "') OR (NK8_CODPRO = '"  +  cProduto + "' and NK8_GRPPRO = '')"  
    cQuery += "  OR (NK8_CODPRO = '' and NK8_GRPPRO = '" + cGrupo + "')  OR (NK8_CODPRO = ' ' AND NK8_GRPPRO = ' ' ) )"   
   
    cQuery +=  "  LEFT JOIN " + RetSqlName('NK7') + " NK7 ON NK7.NK7_CODCOM = NK8.NK8_CODCOM AND NK7.D_E_L_E_T_ <> '*' AND NK7.NK7_FILIAL = '" + XFILIAL('NK7') + "'"
    cQuery +=   "  AND NK7.NK7_ATIVO  = 'S'"
    cQuery +=   "  AND NK7.NK7_UTILIZ = 'N' "
    
    if NK8->(ColumnPos('NK8_DATINI')) > 0
		cQuery +=   "  AND ((NK8_DATINI <= '"+  dtos(dDEntrFim) + "' AND NK8_DATFIM >= '"+ dtos(dDEntrIni)+ "') OR (NK8_DATINI = ' ' AND NK8_DATFIM = ' '))"
	endIf
	    
    cQuery +=  "  LEFT JOIN " + RetSqlName('N8Z') + " N8Z ON NKA.NKA_CODCOM = N8Z.N8Z_CODCOM AND N8Z.D_E_L_E_T_ <> '*' AND N8Z.N8Z_FILIAL = '" + XFILIAL('N8Z') + "'"
	cQuery +=   "  AND N8Z.N8Z_SAFRA      = '" + cSafra + "'" 
    cQuery +=   "  AND (( N8Z.N8Z_CODPRO  = '" + cProduto + "' OR  N8Z.N8Z_GRPROD = '" + cGrupo + "')  OR ( N8Z.N8Z_CODPRO = ' ' AND  N8Z.N8Z_GRPROD = ' ' ))"
    cQuery +=   "  AND N8Z.N8Z_TIPMER     = '" + nTipMer + "'" 
    cQuery +=   "  AND N8Z.N8Z_MOEDA      = " + str(nNjrMoeda)       
   
    cQuery += " WHERE NJR.NJR_FILIAL  = '" + xFilial("NJR") + "' AND NJR.D_E_L_E_T_ = '' AND NJR.NJR_CODSAF =  '" + cSafra + "'"  
    cQuery += "   AND NJR.NJR_CODPRO = '" + cProduto + "'  AND NJR.NJR_TIPMER = '" + nTipMer + "'AND NJR.NJR_MOEDA = " + str(nNjrMoeda) 
     
   
    cQuery:=ChangeQuery(cQuery)
    dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"QryNK8",.F.,.T.)
	QryNK8->(DbGoTop())
   
	cComp_Idx	:= ""  //--<< contem o componente e o Indice do Componente >>

	While !QryNK8->(EOF())
	     
	     cUmprc := QryNK8->NJR_UMPRC
	      
	     // gravar valor do componente definido no plano de venda
	     nVlPvComp := QryNK8->N8Z_VALFIX
	     IF QryNK8->N8Z_TIPVAL == '2'	//PREÇO ESPECIFICO
	        nVlPvComp := OG880NCV(cSafra, cGrupo, cProduto, nTipMer, nNjrMoeda, QryNK8->NK8_CODCOM) 
         EndIF
         
		if NK8->(ColumnPos('NK8_DATINI')) <= 0
			//--<< Valida a Dt. de Entrega >>--
			IF ! fValDtEntr( QryNK8->NK8_DIAINI, QryNK8->NK8_MESINI, QryNK8->NK8_DIAFIM, QryNK8->NK8_MESFIM, dDEntrFim )
				QryNK8->(dbSkip())
				Loop
			EndIF
		endIF	
		
		//--<<Encontro o Tipo de Cotação do Indice >>--
		nVrIndice := 0
		dbSelectArea("NK0")
		NK0->( dbSetOrder(1) )
		If NK0->(DbSeek(xFilial("NK0") + QryNK8->NK8_CODIDX ))
			nVrIndice :=AgrGetInd( NK0->NK0_INDICE,NK0->NK0_TPCOTA,dDtfixa )
		EndIF
		
		If  Empty(nVrIndice)
			nVrIndice := QryNK8->N7M_VALOR		 
		EndIF

		nTxacomp := fTxaCot( QryNK8->NK8_MOEDA , QryNK8->NJR_MOEDA ,dDtfixa ) //--<< Conversao de Moeda >>--

		/*Conversao de UM do Indice  Para a UM do Preco do Produto			*/
		nQtUMPrc := AGRX001( QRYNK8->NK8_UM1PRO ,cUmPrc,1, cProduto)

		IF ! Alltrim( QRYNK8->NK8_UM1PRO ) = Alltrim ( cUmPrc ) // Unidades de medidas sao diferentes
			IF !fValConvUM( QRYNK8->NK8_UM1PRO ,cUmPrc,1)  		// Se não foi possivel Converter //
				fMensUM(QRYNK8->NK8_UM1PRO ,cUmPrc )
			EndIF
		EndIF

		/*Conversao de UM do Indice  Para a 1a UM do Produto				*/
		nQt1AUM:= AGRX001( QRYNK8->NK8_UM1PRO ,c1aUMb5, 1, cProduto)

		IF ! Alltrim( QRYNK8->NK8_UM1PRO ) = Alltrim ( c1aUMb5 ) 	// Unidades de medidas sao diferentes
			IF !fValConvUM( QRYNK8->NK8_UM1PRO ,c1aUMb5,1)  		// Se não foi possivel Converter //
				fMensUM(QRYNK8->NK8_UM1PRO ,c1aUMb5 )
			EndIF
		EndIF

		nVrind1 := SfCovUMVal(nVrIndice,QRYNK8->NK8_UM1PRO,cUmPrc)
		nVrind2 := SfCovUMVal(nVrIndice,QRYNK8->NK8_UM1PRO,c1aUMb5)

		nVrind1 := ( nVrind1 * nTxaComp )  	//--<< contem o Vr do Indice na   Um de Preco do produto e na Moeda do Contrato>>--
		nVrind2 := ( nVrind2 * nTxaComp ) 	//--<< contem o Vr do Indice na 1aUm          do produto e na Moeda do Contrato>>--

		//--<< Case que irá Ordenar as Linha do Browse na Seguinte ordem Preco,Custo,Informativo >>
		
		Do Case
			Case Alltrim(QryNK8->NK7_CALCUL) == 'P'
			cOrdenacao := 'A'
			Case Alltrim(QryNK8->NK7_CALCUL) == 'C'
			cOrdenacao := "B"
			Case Alltrim(QryNK8->NK7_CALCUL) == 'I'
			cOrdenacao := 'C'
			Case Alltrim(QryNK8->NK7_UTILIZ) == 'M'  //--<< Margem sera o ultimo >>--
			cOrdenacao := 'D'
			Case Alltrim(QryNK8->NK7_CALCUL) == 'R'  //--<< Margem sera o ultimo >>--
			cOrdenacao := 'E'
		EndCase

		lAddArray := .f.

		//--<< Esta Logica Garante que sempre Tenha o Componente + Especifico no Array >>-- 		    
		IF  Empty( cComp_Idx ) // .and. cTpComp == QryNK8->NK7_UTILIZ //DAGROGAP-1445
			cComp_Idx := QryNK8->NK8_CODCOM+QryNK8->NK8_CODIDX
			lAddArray := .t.
		ElseIF ! cComp_Idx = QryNK8->NK8_CODCOM + QryNK8->NK8_CODIDX 
			cComp_Idx := QryNK8->NK8_CODCOM+QryNK8->NK8_CODIDX
			lAddArray := .t.
		EndIF
          
        nVlrComp:= nVrIndice
            
		IF lAddArray == .t.
			aAdd(aCompPrc , {QryNK8->NJR_CODCTR,QryNK8->NK8_CODCOM,QryNK8->NK8_ITEMCO,QryNK8->NK8_CODIDX,QryNK8->NK7_DESCRI, QryNK8->NK8_MOEDA,nTxaComp,QryNK8->NK8_UM1PRO,nVrIndice,nVrInd1 , nVrind2 ,nQtUMPrc,nQt1aUM,QryNK8->NK7_CALCUL,cOrdenacao, QryNK8->NK7_UTILIZ,nVlPvComp,QryNK8->N9A_QUANT,QryNK8->NNY_ITEM })
			IF /*cTpComp == 'M' .and.*/ Empty( QryNK8->NK8_CODIDX ) .and. QryNK8->NK7_PRCMAR > 0 	//--<< Nao Encontrei Indice de Margem Tenho Q Calcular a Margem Com a Precentagem >>--
				aCompPrc[len(aCompPrc), 05]	:= MOEDAPERCENTUAL 									//--<< Mudo moeda Para percentagem para indicar q o calculo foi por percentual >>--
				aCompPrc[len(aCompPrc), 08]	:= QryNK8->NK7_PRCMAR
				aCompPrc[len(aCompPrc), 09]	:= QryNK8->NK7_PRCMAR
			EndIF  
		Else
			aCompPrc[len(aCompPrc), 01]	:=QryNK8->NJR_CODCTR
			aCompPrc[len(aCompPrc), 02]	:=QryNK8->NK8_CODCOM
			aCompPrc[len(aCompPrc), 03]	:=QryNK8->NK8_ITEMCO
			aCompPrc[len(aCompPrc), 04]	:=QryNK8->NK8_CODIDX
			aCompPrc[len(aCompPrc), 05]	:=QryNK8->NK7_DESCRI
			aCompPrc[len(aCompPrc), 06]	:=QryNK8->NK8_MOEDA
			aCompPrc[len(aCompPrc), 07]	:=nTxaComp
			aCompPrc[len(aCompPrc), 08]	:=QryNK8->NK8_UM1PRO
			aCompPrc[len(aCompPrc), 09]	:=nVrIndice
			aCompPrc[len(aCompPrc), 10]	:=nVrInd1
			aCompPrc[len(aCompPrc), 11]	:=nVrind2
			aCompPrc[len(aCompPrc), 12]	:=nQtUMPrc
			aCompPrc[len(aCompPrc), 13]	:=nQt1aUM
			aCompPrc[len(aCompPrc), 14]	:=QryNK8->NK7_CALCUL
			aCompPrc[len(aCompPrc), 15]	:=cOrdenacao
			aCompPrc[len(aCompPrc), 16]	:=QryNK8->NK7_UTILIZ			
			aCompPrc[len(aCompPrc), 17]	:=nVlPvComp
			aCompPrc[len(aCompPrc), 18]	:=QryNK8->N9A_QUANT
			aCompPrc[len(aCompPrc), 19]	:=QryNK8->NNY_ITEM
			
			/*IF cTpComp == 'M' .and. nVrIndice == 0  				//--<< Nao Encontrei Indice de Margem Tenho Q Calcular a Margem Com a Precentagem >>--
				aCompPrc[len(aCompPrc), 05]	:= MOEDAPERCENTUAL 		//--<< Mudo moeda Para percentagem para indicar q o calculo foi por percentual >>--
				aCompPrc[len(aCompPrc), 08]	:= QryNK8->NK7_PRCMAR
				aCompPrc[len(aCompPrc), 09]	:= QryNK8->NK7_PRCMAR 
			EndIF*/ 
		EndIF
		QryNK8->(dbSkip())
	EndDo
	QryNK8->(dbCloseArea())	

	//--<< Refaz Todos os Calculos >>--
	//Recalc(cUmPreco,c1aUmProd)

	fMontaTela(cProduto , dDtfixa , dDEntrIni , dDEntrFim , nQtfixar , cNk7Aplica , cNjrUm1Pro , cNjrUmPrc , nNjrMoeda , nTipMer, cMoeda, cSafra, cGrupo)

Return



/*/{Protheus.doc} fMontaTela
//TODO Descrição auto-gerada.
@author 
@since 16/06/2017
@version undefined

@type function
/*/
Static Function fMontaTela(cProduto , dDtfixa , dDEntrIni , dDEntrFim , nQtfixar , cNk7Aplica , cNjrUm1Pro , cNjrUmPrc , nNjrMoeda , nTipMer, cMoeda, cSafra, cGrupo)
	Local aSizeDlg 		:= MsAdvSize()
	Local nLinIniTel 	:= 0
	Local oPanelComp	:= 0
	Local nLinAuxIni	:= 0

	Local nwidth        := 506//478//420
	Local nAuxV12       := 0 //Variável criada por causa que na Versão 12 a EnchoiceBar foi alterada para ficar no topo.

	nLinIniTel 	:= aSizeDlg[7]
	nLinAuxIni	:= 030
	nAuxV12     := 022
	oTela := MsDialog():New(nLinIniTel,000,450/*370*/,1010, STR0001,,,.F.,,,,,oMainWnd,.T.,,,.F.)  //"Composição de Preços"

	oPanelTop := TPanel():New(nLinIniTel+nLinAuxIni ,nLinIniTel + 01,/*Descricao*/,oTela,oFontAta,.F.,.F.,,,(nwidth),(nAuxV12),.F.,.F.)

	//--<< Labels e Get antes do Grid
	@ 002, 007 SAY  STR0002 SIZE 020, 010 OF oPanelTop PIXEL   	//"Periodo"
	@ 002, 038 Say  dtoc(dDtFixa)   SIZE 037, 010 OF oPanelTop PIXEL	
	@ 002, 077 SAY  STR0003 SIZE 030, 007 OF oPanelTop PIXEL 	//"Entrega de"
	@ 002, 110 SAY  dToc(dDEntrIni) + " a " + dToc(dDEntrFim)SIZE 075, 007 OF oPanelTop PIXEL
	
	@ 002, 185 SAY STR0004 SIZE 032, 011 OF oPanelTop PIXEL		//"Produto"
	@ 002, 218 SAY Trim(cProduto) + " - " + SB1->B1_DESC  SIZE 100, 011 OF oPanelTop PIXEL

	@ 002, 335 SAY STR0005 SIZE 018, 011 OF oPanelTop PIXEL		//"Moeda"
	@ 002, 350 SAY Str(nNjrMoeda) + " - " + cMoeda  SIZE 50, 011 OF oPanelTop PIXEL
	
	@ 002, 440 SAY STR0006 SIZE 025, 011 OF oPanelTop PIXEL		//"Mercado"
	@ 002, 465 SAY Trim(nTipMer)  + " - " + X3CboxDesc( "N8W_TIPMER", nTipMer, 1, 0,) SIZE 100, 011 OF oPanelTop PIXEL
	
	@ 010, 335 SAY "Quantidade Plano: "  + str(nQtfixar) SIZE 100, 011 OF oPanelTop PIXEL
	
//--------------------Cria o Panel que Delimita o Tamanho do Browse do Composicao de preçõs------------

nheight:=120 // -nAux//70 ***

oPanelComp := TPanel():New(nLinIniTel+nLinAuxIni+nAuxV12 ,nLinIniTel ,/*Descricao*/,oTela,oFontAta,.F.,.F.,,,(nwidth)  ,(nheight-nAuxV12) +70 ,.F.,.F.)

//--<< Seta as Propriedades do Browse >>--
setoBrwCP( oPanelComp )


lok := .T.

ACTIVATE MSDIALOG oTela CENTERED ON INIT (EnchoiceBar(oTela,{||lOk := .T.,if(lOk,oTela:End(),)},{||oTela:End()},,aButtons))

Return 


/** {Protheus.doc} SetoBrwCP
Seta as Propriedades do Browse de Composicao de preço

@author: 	Equipe AgroIndustria
@Uso...: 	SIGAARM - Originação de Grãos
*/
Static Function SetoBrwCP( oPanelComp )
	Local aSortLines	:= {}
	
	//Ordena o Array Multidimensional levando em consideração somente a Coluna 15
	aSortLines := ASORT(aCompPrc,,, { |x, y| (x[1]+x[19]+x[15]+x[04]) < (y[1]+y[19]+y[15]+y[04]) })
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
	oBrwComp:SetEditCell( .F. ) 					// indica que o grid éeditavel
	oBrwComp:SetLineHeight(13) 

	oBrwComp:Activate()	
Return

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
Static Function fValDtEntr(cDiaIni, cMesIni,cDiaFim,cMesFim, dDtEntrFim  )
	Local lOk 		:= .t.
	Local dDtIni 	:= ctod( cDiaIni + '/' + cMesIni +'/'+ strzero(year(ddtentrfim),4) )
	Local dDtFim 	:= ctod( cDiaFim + '/' + cMesFim +'/'+ strzero(year(ddtentrfim),4) )

	If ! Empty(dDtIni)

		IF Month(dDtIni) > Month(dDtFim)
			dDtIni := YearSub( dDtIni , 1 )  //--<< Subtrai um do no da Dt Ini >>--
		Elseif Month(dDtIni) == Month(dDtFim) .and. Day(dDtini) >= Day(dDtFim)
			dDtIni := YearSub( dDtIni , 1 )  //--<< Subtrai um do no da Dt Ini >>--
		EndIF

		//--<< Verifica se a data esta dentro do enterva-lo >>--
		Do Case
			Case dDtEntrFim < dDtIni
			lOk :=.f.
			Case dDtEntrFim > dDtFim
			lok :=.f.
		EndCase
	EndIF
Return( lOk )
/** {Protheus.doc} MntStatus
Seta as Cores de Acordo Com o Tipo do Componente NK7

@author: 	Equipe AgroIndustria
@Uso...: 	SIGAARM - Originação de Grãos
*/
Static Function MntStatus()
	cColor :=''
	Do Case
		Case ALLTRIM(aCompPrc[oBrwComp:NAT,14])='P'
		cColor = 'Br_Azul'
		Case ALLTRIM(aCompPrc[oBrwComp:NAT,14])='C'
		cColor = 'Br_Vermelho'
		Case ALLTRIM(aCompPrc[oBrwComp:NAT,14])='I'
		cColor = 'Br_Amarelo'
		Case ALLTRIM(aCompPrc[oBrwComp:NAT,14])='R'
		cColor = 'Br_Cinza'
	EndCase	
Return cColor

/** {Protheus.doc} Mntlegend
Função para montar a legenda da Browse.

@author: 	Emerson	
@since:		30/10/2014
@Uso...: 	SIGAARM - Originação de Grãos
*/
Static Function MntLegend()
	Local oLegenda  :=  FWLegend():New()

	oLegenda:Add( '', 'BR_AZUL', 		STR0007 )		//'Preço'
	oLegenda:Add( '', 'BR_VERMELHO'	, 	STR0008 )		//'Custo'
	oLegenda:Add( '', 'BR_AMARELO'	, 	STR0009 )		//'Informativo'
	oLegenda:Add( '', 'BR_CINZA'	, 	STR0016 )		//'Resultado'

	oLegenda:Activate()
	oLegenda:View()
	oLegenda:DeActivate()
Return Nil


/** {Protheus.doc} fTxaCot
Funcao que Encontra indice multiplicador de conversao de moeda

@author: 	Emerson	
@since:		30/10/2014
@Uso...: 	SIGAARM - Originação de Grãos
*/
Static Function fTxaCot( nMoedaComp , nMoedactr,dDtfixacao )
	Local nTxaComp 	:= 0
	Local nTxaCtr		:= 0
    
	//--<<  Ao Final do IF, o nTxaComp, Contera um indice multiplicador de conversao de moeda 	>>--
	//--<< Baseado na Moeda do Componente e Moeda do Contrato										>>--
	IF ! nMoedaComp = nMoedaCtr //--<< a Moeda do indice não é Igual a Moeda do Ctrato >>--
		nTxaComp := 0 	//--<< Ctacao da Moeda do Componente 	>>--
		nTxaCtr  := 0 	//--<< Ctacao da Moeda do Ctrato 		>>--
		DBSelectArea("SM2")
		SM2->(DBSetOrder(1) )
		SM2->( DbSeek( DtoS( dDtFixacao) ) )

		nTxaComp 	:= &('SM2->M2_MOEDA'+ STRZERO(nMoedaComp,1) )
		nTxaCtr	:= &('SM2->M2_MOEDA'+ STRZERO(nMoedaCtr,1) )

		IF  ! nMoedaCtr == 1 //--<< Se a Moeda do Ctrato não for a Moeda Padrao >>--
			IF  nMoedaComp == 1 //--<< Se a Moeda do componente for a Moeda Padrao >>--
				nTxaComp := 1 / nTxaCtr
			Else  								 //--<< Não é a moeda padrão
				nTxaComp :=  nTxaCtr / nTxaComp
			EndIF
		EndIf
	Else
		nTxacomp := 1
	EndIF
Return ( nTxaComp )



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

	cUmNaoConv += STR0011 + '	' + UmOri + '	' + STR0012 + '	' + UmDest   // DE:###Para:
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

    aAdd(aBrowseCol, {cCol0Tit	,{||IIF(Len(aCompPrc) > 0 , aCompPrc[oBrwComp:NAT,01], Nil)}  			,   'C'   ,'@!'    					, 1    ,10     	,0  })
	aAdd(aBrowseCol, {cCo20Tit	,{||IIF(Len(aCompPrc) > 0 , aCompPrc[oBrwComp:NAT,19], Nil)}  			,   'C'   ,'@!'    					, 1    ,06     	,0  })
	aAdd(aBrowseCol, {cCol1Tit	,{||IIF(Len(aCompPrc) > 0 , aCompPrc[oBrwComp:NAT,05], Nil)}  			,   'C'   ,'@!'    					, 1    ,20     	,0  })
	aAdd(aBrowseCol, {cCol2Tit	,{||IIF(Len(aCompPrc) > 0 , aCompPrc[oBrwComp:NAT,18], Nil)}  			,   'N'   ,'@E 9,999,999.999999'    , 1    ,10     	,6  })
	aAdd(aBrowseCol, {cCol9Tit	,{||IIF(Len(aCompPrc) > 0 , fDesMoeda(aCompPrc[oBrwComp:NAT,06] ), Nil)},  	'C'   ,'@!' 	       			, 1    ,05		,0  })
	aAdd(aBrowseCol, {cCol3tit 	,{||IIF(Len(aCompPrc) > 0 , aCompPrc[oBrwComp:NAT,07], Nil)}  			,   'N'   ,'@E 9,999,999.999999'	, 2    ,06     	,6  })
	aAdd(aBrowseCol, {cCol4tit 	,{||IIF(Len(aCompPrc) > 0 , Alltrim(aCompPrc[oBrwComp:NAT,08]), Nil)}  	,   'C'   ,'@!'    					, 1    ,03     	,0  })
	aAdd(aBrowseCol, {cCol5tit 	,{||IIF(Len(aCompPrc) > 0 , aCompPrc[oBrwComp:NAT,09], Nil)}  			,   'N'   ,'@E 9,999,999.999999' 	, 2    ,06     	,6	})
	aAdd(aBrowseCol, {cCol6tit 	,{||IIF(Len(aCompPrc) > 0 , aCompPrc[oBrwComp:NAT,10], Nil)}  			,   'N'   ,'@E 9,999,999.999999'	, 2    ,06     	,6	})
	aAdd(aBrowseCol, {cCol7tit 	,{||IIF(Len(aCompPrc) > 0 , aCompPrc[oBrwComp:NAT,11], Nil)} 	 		,   'N'   ,'@E 9,999,999.999999'    , 2    ,06     	,6	})
	aAdd(aBrowseCol, {cCol8tit	,{||IIF(Len(aCompPrc) > 0 , aCompPrc[oBrwComp:NAT,12], Nil)}  			,	'N'   ,'@E 9,999,999.999999'	, 2    ,06     	,6	})
	aAdd(aBrowseCol, {cCo21tit	,{||IIF(Len(aCompPrc) > 0 , aCompPrc[oBrwComp:NAT,17], Nil)}  			,	'N'   ,'@E 9,999,999.999999'	, 2    ,06     	,6	})


	oBrwComp:setcolumns( aBrowseCol )
	If Len(aCompPrc) > 0
		obrwComp:acolumns[4]:ledit		:= .t. 				// indica que a 3 coluna eh editavel
		obrwComp:acolumns[7]:ledit		:= .t. 				// indica que a 4 coluna eh editavel
	EndIF
	
	obrwComp:acolumns[4]:cReadVar	:= 'aCompPrc[oBrwComp:nat,7]'
	obrwComp:acolumns[7]:cReadVar	:= 'aCompPrc[oBrwComp:nat,9]'

Return()


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
STATIC FUNCTION OG880NCV(pSafra, pGrupo, pProd, pTpMerc, pMoen8z, pCompn8z)
local nRetorno := 0

	dbSelectArea("NCV")
	dbSetOrder(1)
	dbGoTop()
	If dbSeek(FwxFilial("NCV") + pSafra + pGrupo + pProd + pTpMerc + PadR(Alltrim(Str(pMoen8z)),TamSx3('N8Z_MOEDA')[1] ) + pCompn8z)
       nRetorno := NCV->NCV_VALOR	
	EndIF

return nRetorno	


