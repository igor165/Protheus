#INCLUDE "APWEBSRV.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "WSLOJ030.CH"
#INCLUDE "PROTHEUS.CH"

WSSTRUCT ItVndList
	WSDATA NumDoc		AS Integer
	WSDATA ContOrdOp	AS Float
	WSDATA ItemNum		AS Float
	WSDATA CodProd		AS String
	WSDATA Descricao	AS String
	WSDATA Quantidade	AS Float
	WSDATA UnMedida		AS String
	WSDATA VlrUnit		AS Float
	WSDATA DescItem		AS Float
	WSDATA AcreItem		AS Float
	WSDATA VlrLiq		AS Float
	WSDATA TotParc		AS String
	WSDATA ItCancel		AS Boolean
	WSDATA QtdCanc		AS Float
	WSDATA ValCanc		AS Float
	WSDATA CancAcrIt	AS Float
	WSDATA IndArrTru	AS String
	WSDATA IPPT			AS String
	WSDATA QtdDecQtd	AS Float
	WSDATA QtdDecVUn	AS Float    
	WSDATA NumContDoc	AS Integer 
	WSDATA SerPdv   	AS String	
	WSDATA PAFMD5OK		AS Boolean 	
	WSDATA SitTrib   	AS String	
	WSDATA IncManual	AS Boolean	
	WSDATA ContLoop		AS Boolean
ENDWSSTRUCT


WSSTRUCT VendaList
	WSDATA NumDoc		AS Integer
	WSDATA ContOrdOp	AS Float
	WSDATA DataEmiss	AS Date
	WSDATA HoraEmiss	AS String
	WSDATA SubTotal		AS Float
	WSDATA DescTotal	AS Float
	WSDATA AcreTotal	AS Float
	WSDATA TpDescon		AS String
	WSDATA TpAcresc		AS String 
	WSDATA TotLiquido	AS Float
	WSDATA Cancelado	AS Boolean
	WSDATA ValCancTot	AS Float
	WSDATA OrdAplDesc	AS String
	WSDATA NomeClient	AS String
	WSDATA CNPJClient	AS String  
	WSDATA NumContOnf	AS Integer    
	WSDATA NumContRg	AS Integer    
	WSDATA NumContCdc	AS Integer    
	WSDATA NumContDoc   AS Integer    
	WSDATA DataTef   	AS String
	WSDATA HoraTef   	AS String 
	WSDATA SerPdv   	AS String	
	WSDATA PAFMD5OK		AS Boolean 
	WSDATA IncManual	AS Boolean		
	WSDATA ContLoop		AS Boolean
ENDWSSTRUCT

WSSTRUCT ImpList
	WSDATA Codigo       AS String
	WSDATA CodSfi       AS String        
	WSDATA Valor        AS Float
	WSDATA IncManual 	AS Boolean
	WSDATA PAFMD5OK		AS Boolean
ENDWSSTRUCT

WSSTRUCT RedZList
	WSDATA Serie		AS String
	WSDATA ContRedZ	AS Float
	WSDATA ContOrdOp	AS Float
	WSDATA ContReinic	AS Float
	WSDATA DataMovto	AS Date
	WSDATA DataRedZ	AS Date
	WSDATA HoraRedZ	AS String
	WSDATA TotBrutDia	AS Float  
	WSDATA ImpsSFI   	AS Array of ImpList OPTIONAL
	WSDATA PAFMD5OK	AS Boolean 	
	WSDATA TotCancDia	AS Float  	
	WSDATA TotOpNFis	AS Float
	WSDATA TotCanIss	AS Float
	WSDATA IncManual AS Boolean
	WSDATA DelManual AS Boolean
ENDWSSTRUCT

WSSTRUCT DavList
	WSDATA CNPJ			AS String
	WSDATA SerPDV		AS String
	WSDATA MFAdic		AS String
	WSDATA TipoECF		AS String
	WSDATA Marca		AS String
	WSDATA Modelo		As String
	WSDATA Codigo		AS String
	WSDATA Emissao		AS Date
	WSDATA Titulo		AS String
	WSDATA Valor		AS Float
	WSDATA COO			AS String 
	WSDATA CCF			AS String 	
	WSDATA COODAV		AS String 	
	WSDATA PAFMD5OK		AS Boolean 		
	WSDATA Serie		AS String 		
	WSDATA NomeClient	AS String  
	WSDATA CNPJClient	AS String
	WSDATA IncManual	AS Boolean
	WSDATA LstItemDav	AS Array of ItDavList OPTIONAL
	WSDATA LstItDavLog	AS Array OF ItDavLstLg OPTIONAL
ENDWSSTRUCT

WSSTRUCT ItDavList
	WSDATA CNPJ			AS	String
	WSDATA Emissao		AS Date
	WSDATA NumItem		AS Integer
	WSDATA CodProd		AS String		
	WSDATA Descricao	AS String
	WSDATA Quantidade	AS Float
	WSDATA UnMedida		AS String	
	WSDATA VlrUnit		AS Float
	WSDATA DescItem		AS Float
	WSDATA AcreItem		AS Float
	WSDATA VlrLiq		AS Float
	WSDATA TotParc		AS String 
	WSDATA ItCancel		AS Boolean
	WSDATA PAFMD5OK		AS Boolean
	WSDATA DecQtde		AS Integer
	WSDATA DecVlrUnt	AS Integer
ENDWSSTRUCT

WSSTRUCT ItDavLstLg
	WSDATA Alteracao	AS Date
	WSDATA Hora			AS String
	WSDATA CodProd		AS String		
	WSDATA Descricao	AS String
	WSDATA Quantidade	AS Float
	WSDATA UnMedida		AS String	
	WSDATA VlrUnit		AS Float
	WSDATA DescItem		AS Float
	WSDATA AcreItem		AS Float
	WSDATA VlrLiq		AS Float
	WSDATA TotParc		AS String 
	WSDATA ItCancel		AS Boolean  
	WSDATA TipoAlt		As String
	WSDATA PafMD5OK		As Boolean
	WSDATA IncManual	AS Boolean
	WSDATA DecQtde		AS Integer
	WSDATA DecVlrUnt	AS Integer
ENDWSSTRUCT

WSSTRUCT MeiPgtList
	WSDATA Emissao	AS Date
	WSDATA Tipos		AS Array of String
	WSDATA Totais		AS Array of Float 
	WSDATA DadosPag	AS Array of PagList OPTIONAL
	WSDATA IncManual	AS Boolean
ENDWSSTRUCT

WSSTRUCT PagList                   
	WSDATA TipoPag	AS String
	WSDATA DescTpPag	AS String
	WSDATA TipoDoc	AS String
	WSDATA Valor     AS Float
	WSDATA ContOrdOp	AS Integer 
	WSDATA NumContDoc	AS Integer 
	WSDATA NumContOnf	AS Integer  
	WSDATA SerPdv		AS String	
	WSDATA PAFMD5OK		AS Boolean 	
	WSDATA Cancelado	AS Boolean
	WSDATA IncManual	AS Boolean		
ENDWSSTRUCT                         

WSSTRUCT DocList
	WSDATA SerPdv		AS String
	WSDATA Simbol		AS String
	WSDATA DataEmiss	AS Date
	WSDATA HoraEmiss	AS String
	WSDATA COO			AS String 
	WSDATA GNF			AS String 
	WSDATA GRG			AS String 	
	WSDATA CDC			AS String 		
	WSDATA PAFMD5OK		AS Boolean
	WSDATA IncManual AS Boolean	
ENDWSSTRUCT

WSSTRUCT ProdList
	WSDATA CNPJ			AS	String
	WSDATA Codigo		AS	String
	WSDATA CodBar		AS	String
	WSDATA Preco		AS	Float
	WSDATA Descricao	AS	String 
	WSDATA SitTrib	AS	String 
	WSDATA PIcm		AS	Integer
	WSDATA	AliqISS	AS	Integer 
	WSDATA UM			AS	String 
	WSDATA IAT			AS	String 
	WSDATA IPPT		AS	String
	WSDATA PAFMD5OK	AS	Boolean
	WSDATA IncManual	AS	Boolean
	WSDATA FimLista	AS Boolean 
ENDWSSTRUCT

WSSTRUCT EstList
	WSDATA CNPJ			AS	String
	WSDATA Codigo		AS	String
	WSDATA CodBar		AS	String
	WSDATA Descricao	AS	String
	WSDATA QtdeAtu	AS	Float
	WSDATA UltSaida	AS	Date
	WSDATA UM			AS	String
	WSDATA PAFMD5OK AS Boolean
	WSDATA	IncManual AS Boolean
	WSDATA FimLista	AS Boolean 
ENDWSSTRUCT

WSSTRUCT TrcCrdList
	WSDATA UsaTroco		AS Boolean
	WSDATA CnpjAdm		AS String
	WSDATA COO			AS String // COO do cupom onde foi registrado o troco
	WSDATA CCF			AS String // CCF do cupom onde foi registrado o troco
	WSDATA Troco		As Float  // Valor do Troco
	WSDATA DtEmissao    As Date	  // Data da emissão do cupom fiscal
	WSDATA CpfCli		As String // Cpf do adquirente do titulo
	WSDATA Titulo		As String // numero do titulo adquirido	
	WSDATA PAFMD5OK		As Boolean //MD5 da alteração
	WSDATA CnpjEnti	As	String	//Cnpj da entidade recebedora da doacao 
ENDWSSTRUCT

WSSTRUCT LstInfoPDV
	WSDATA Codigo		AS String
	WSDATA PDV			AS String
	WSDATA Serie		AS String
	WSDATA ImpFisc		AS String 
	WSDATA SerPDV		AS String
	WSDATA ECfInfo    	AS String
	WSDATA AlqInfo		As String
	WSDATA PAFMD5OK		As Boolean
ENDWSSTRUCT  

WSSTRUCT LstEstInfo
	WSDATA SerPDV		AS String
	WSDATA PDV			AS String
	WSDATA Emissao		AS Date 
	WSDATA Hora	   		AS String 
	WSDATA PAFMD5OK		AS Boolean
	WSDATA IncManual	AS Boolean  
ENDWSSTRUCT  

WSSTRUCT oLstProd
	WSDATA aCodProduto AS Array of CodProd OPTIONAL
ENDWSSTRUCT

WSSTRUCT CodProd
	WSDATA xProduto as String OPTIONAL
ENDWSSTRUCT

WSSTRUCT VndsIdent
	Wsdata CpfCnpj	as String
	Wsdata TotalVnd	as Float
	Wsdata DtFirstS	as Date
	Wsdata DtLastS	as Date
	Wsdata PafMd5OK	as Boolean 
ENDWSSTRUCT

WSSTRUCT VndNFMnNF
	WSDATA CnpjEmi		as String
	WSDATA DataEmiss	AS Date
	WSDATA SubTotal		AS Float
	WSDATA DescTotal	AS Float
	WSDATA AcreTotal	AS Float
	WSDATA TpDescon		AS String
	WSDATA TpAcresc		AS String 
	WSDATA TotLiquido	AS Float
	WSDATA Cancelado	AS Boolean
	WSDATA ValCancTot	AS Float
	WSDATA OrdAplDesc	AS String
	WSDATA NomeClient	AS String
	WSDATA CNPJClient	AS String  
	WSDATA NumNota		AS Integer
	WSDATA SerieNota   	AS String
	WSDATA KeyNota		As String
	WSDATA TpDocEmi		As Integer	
	WSDATA PAFMD5OK		AS Boolean 
	WSDATA IncManual	AS Boolean
	WSDATA DelManual	AS Boolean	
	WSDATA ContLoop		AS Boolean
ENDWSSTRUCT

WSSTRUCT ItVndNFMnNF
	WSDATA CnpjEmi		as String
	WSDATA DataEmiss	AS Date
	WSDATA ItemNum		AS Float
	WSDATA CodProd		AS String
	WSDATA Descricao	AS String
	WSDATA Quantidade	AS Float
	WSDATA UnMedida		AS String
	WSDATA VlrUnit		AS Float
	WSDATA DescItem		AS Float
	WSDATA AcreItem		AS Float
	WSDATA VlrLiq		AS Float
	WSDATA TotParc		AS String
	WSDATA ItCancel		AS Boolean
	WSDATA QtdDecQtd	AS Float
	WSDATA QtdDecVUn	AS Float    
	WSDATA NumNota		AS Integer
	WSDATA SerieNota   	AS String
	WSDATA KeyNota		As String
	WSDATA TpDocEmi		As Integer
	WSDATA PAFMD5OK		AS Boolean
	WSDATA DelManual	As Boolean		
	WSDATA IncManual	AS Boolean	
	WSDATA ContLoop		AS Boolean
ENDWSSTRUCT

WSSERVICE FRTPafEcf DESCRIPTION STR0001 //"Serviço de consultas do SIGALOJA/SIGAFRT referentes ao PAF-ECF"

WSDATA EstListRet	AS Array of EstList
WSDATA ProdListRet	AS Array of ProdList 
WSDATA TrcCardRet 	AS Array of TrcCrdList
WSDATA DavListRet	AS Array of DavList
WSDATA MeiPgtRet	AS Array of MeiPgtList
WSDATA RedZRet		AS Array of RedZList
WSDATA LstVdas		AS Array of VendaList
WSDATA LstIt		AS Array of ItVndList
WSDATA PagCanc		As Array Of MeiPgtList
WSDATA DocListRet	AS Array of DocList
WSDATA VndsIdentRet As Array Of VndsIdent
WSDATA LstVndNFMn	As Array Of VndNFMnNF
WSDATA LstItVndNFMn	As Array Of ItVndNFMnNF
WSDATA LstPDV		AS Array of String
WSDATA CrzCro		AS Array of String	
WSDATA aProdutos	AS oLstProd
WSDATA dDataIni		AS Date
WSDATA dDataFim		AS Date
WSDATA cPDV			AS String OPTIONAL
WSDATA cEmpPdv	  	AS String OPTIONAL 
WSDATA cFilPdv	  	AS String OPTIONAL 
WSDATA cFieldRet  	AS String 	OPTIONAL 
WSDATA lHomolPaf	AS Boolean OPTIONAL
WSDATA cSeriePDV	AS String  OPTIONAL	
WSDATA cIniCup		As String OPTIONAL
WSDATA ContLoop		AS Boolean OPTIONAL
WSDATA lFiltraNFe	AS Boolean OPTIONAL
WSDATA lDataRed  	AS Boolean OPTIONAL
WSDATA LstInfoPDVRet AS Array of LstInfoPDV
WSDATA lUpdateEtq   AS Boolean OPTIONAL
WSDATA LsVdESt	  	As Array Of LstEstInfo 
WSDATA nPagina	 	AS Integer OPTIONAL
WSDATA cCodProd    	AS String OPTIONAL
WSDATA CpfCpnj		AS String Optional
WSData cIniDoc		as String OPTIONAL
WsData lIsR07		as Boolean OPTIONAL

WSMETHOD LstEstoque DESCRIPTION "Consulta de Estoque" 
WSMETHOD LstProduto	DESCRIPTION "Consulta de Produtos"
WSMETHOD LstTrcCard DESCRIPTION "Consulta de Troco em Cartão"
WSMETHOD LstDavEmit	DESCRIPTION STR0002 //"Consulta DAVs emitidos"
WSMETHOD LstMePagto DESCRIPTION STR0003 //"Consulta meios de pagamento utilizados no PDV em um periodo"
WSMETHOD LstPdvs	DESCRIPTION STR0004 //"Lista o numero dos PDV's cadastrados no sistema"
WSMETHOD LstRedZ	DESCRIPTION STR0005 //"Lista os dados de reducoes Z de um PDV"
WSMETHOD LerCrzCro	DESCRIPTION STR0006 //"Ler ultimo crz e ultmo cro"
WSMETHOD LstVendas	DESCRIPTION STR0007 //"Lista as vendas de um periodo para um PDV"
WSMETHOD LstVndCanc DESCRIPTION "Consulta de Vendas Canceladas"
WSMETHOD LstItens	DESCRIPTION STR0008 //"Lista os itens das vendas de um periodo para um PDV"
WSMETHOD LstItCanc  DESCRIPTION "Consulta de Itens Cancelados"
WSMETHOD LstDocEmit	DESCRIPTION STR0010	//"Consulta Docs emitidos"	
WSMETHOD LstInfoPDV DESCRIPTION "Lista os PDVS"	//"Consulta Docs emitidos"
WSMETHOD LstVendEst	DESCRIPTION STR0007 //"Lista a primeira venda do PDV que atualizou o estoque"
WSMETHOD LstVndCpf  DESCRIPTION "Vendas Identificadas por Cpf/Cnpj"
WSMETHOD LstVndManu DESCRIPTION "Notas Fiscais Emitidas e Manuais"
WSMETHOD LstItVdManu DESCRIPTION "Itens da Notas Fiscais Emitidas e Manuais"
WSMETHOD LstPagCanc DESCRIPTION "Pagamentos de Vendas Canceladas"
ENDWSSERVICE

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Metodo	 ³LstDavEmit³ Autor ³ Venda Clientes        ³ Data ³24/04/2009	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Lista os orcamentos (DAVs) emitidas dentro de um periodo   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 - Data inicial                                       ³±±
±±³          ³ ExpD2 - Data final                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpA1 - Estrutura contendo os dados dos DAVs emitidos      	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  		³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD LstDavEmit WSRECEIVE dDataIni,dDataFim, cEmpPdv, cFilPdv, lHomolPaf WSSEND DavListRet WSSERVICE FRTPafEcf
Local cFilSL1	:= ""		// Filial da tabela SL1
Local cAlias	:= ""		// Alias utilizado para consulta dos dados na SL1
Local cTitulo	:= ""  		// Titulo dado ao registro do SL1(orcamento, DAV, Pre-venda, etc.)
Local cTipo		:= ""		// Tipo de registro a ser considerado D-DAV/P-Pre-Venda
Local nPos		:= 0		// Posicao atual no retorno do WebService
Local nPosItem	:= 0		// Posicao atual do item no retorno do WebService
Local nVlrTot	:= 0		// Valor total dos itens da DAV, não pega L1_VLRTOT
Local nX		:= 0		// contador 
Local cQuery	:= ""		// Query para selecao de dados no banco de dados
Local cPafMd5	:= ""		// Chave MD5
Local cNomCli	:= ""      // Nome do Cliente
Local cCGCCli	:= ""      // CPF/CGC do Cliente
Local cFilSA1	:= ""      // Filial SA1
Local xDtEmissao		
Local nQtdDecQuant	:= 0
Local nQtdDecVUnit	:= 0       
Local aAux		:=	{}
Local aSL2		:=	{}
LOcal aAreaSLG	:=  {}
Local lIncManual := .F. //Valida inclusão manual direto no banco
Local lDelManual := .F.
Local lMFTManual := .F.
Local lLogDAV	:= .F.
Local lPafMD5OK := .T.
Local lNewField := .F.
Local lTemPDV	:= .F.
Local lExcecaoFcl:= .F. 
Local cTpSolCf  := ""
Local aRetSLG	:= Array(12)
Local aLjExcecao:= {}

LjPreparaWs(::cEmpPdv,::cFilPdv)

lLogDAV	:= AliasInDic("MFT")
DbSelectArea("MFT")
DbSelectArea("SL2")
DbSelectArea("SLG")

lNewField:= SL2->(ColumnPos("L2_DECQTD"))> 0 .And. MFT->(ColumnPos("MFT_DECQTD")) > 0
 
cTpSolCf:= SuperGetMV("MV_TPSOLCF")
cFilSL1	:= xFilial("SL1")		// Filial da tabela SL1
cFilSA1	:= xFilial("SA1")		// Filial da tabela SA1

//Quantidade de casas decimais
nQtdDecQuant	:= TamSX3("L2_QUANT")[2]
nQtdDecVUnit	:= TamSX3("L2_VRUNIT")[2]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica qual a opcao considerada para impressao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SuperGetMv("MV_LJPRVEN",,.T.) //No teste do bloco VII - ajustar o parametro e o campo L1_TPORC
	cTitulo := "Pre-venda"
	cTipo	:= "P"
Else
	cTitulo := "Orcamento"
	cTipo	:= "D"
EndIf

cAlias := "SL1TMP"

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

cQuery	:= "SELECT L1_FILIAL,L1_EMISSAO,L1_DTLIM,L1_NUMORC,L1_TPORC,L1_VLRTOT,L1_HORA,"
cQuery  += "L1_NUMCFIS,L1_CONTDOC,L1_COODAV,L1_DOC,L1_PAFMD5,L1_SERPDV,L1_STORC,L1_SERIE,L1_CLIENTE,L1_LOJA,L1_NUM, "	
cQuery	+= "A1_NOME,A1_CGC, L1_COODAV , L1_CGCCLI, L1_DESCONT, L1_VLRLIQ, L1_PDV,L1_VALMERC,L1_ESPECIE "
cQuery	+= "FROM " + RetSqlName("SL1") + " SL1 "
cQuery	+= "INNER JOIN " + RetSqlName("SA1") + " SA1 "
cQuery	+= "ON A1_FILIAL='"+cFilSA1+"' AND A1_COD=L1_CLIENTE AND A1_LOJA=L1_LOJA AND SA1.D_E_L_E_T_ = ' ' "
cQuery	+= "WHERE "
cQuery	+= "    SL1.D_E_L_E_T_ 	=	' ' AND SL1.L1_FILIAL = '" + cFilSL1 + "' "
cQuery	+= "AND SL1.L1_NUMORC 	<>	' ' AND SL1.L1_TPORC  = '" + cTipo + "' "
cQuery	+= "AND SL1.L1_DTLIM 	>=	'" + DtoS(dDataIni)+ "' "
cQuery	+= "AND SL1.L1_DTLIM 	<=	'" + DtoS(dDataFim) + "' "
cQuery	+= " AND SL1.L1_ESPECIE <> 'NFCF' AND SL1.L1_ESPECIE <> 'NFM' "
cQuery	+= "ORDER BY SL1.L1_FILIAL,SL1.L1_DTLIM,SL1.L1_NUMORC"

cQuery := ChangeQuery( cQuery )

DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlias, .F., .T.)
TcSetField(cAlias,"L1_DTLIM","D")
TcSetField(cAlias,"L1_EMISSAO","D")
(cAlias)->(DbGoTop())

//Validação deleção de SL1 e SL2
If lHomolPaf

	SET DELETED OFF  //Habilita deletados para considerar item cancelado	
	DbSelectArea("SL2")                                     
	SL2->(DbSetOrder(1)) //L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO

	xDtEmissao := SL2->L2_EMISSAO	
	If ValType(xDtEmissao) == "C"
		xDtEmissao := Ctod(xDtEmissao)
	EndIf

	//Verifica se foi adicionado/excluido algum registro da SL1 - teste homologação
	While !SL2->(Eof()) .AND. (SL2->L2_FILIAL == xFilial("SL2")) .AND. ( xDtEmissao <= dDataFim )
		If !Empty(SL2->L2_PAFMD5) .And. ! Empty(AllTrim(L2_PDV))
			
			/*
			 Homologação 2017
			 Condição mantida para uso futuro, caso necessário mas visto que o 
			 L2_NUMORIG não é gravado no Loja, afetando o resultado da pesquisa
			
			// .AND. ( Empty(SL2->L2_CONTDOC) .OR. (!Empty(SL2->L2_CONTDOC) .AND. !Empty(SL2->L2_NUMORIG)) )
			*/			 
			Aadd( aSL2 , SL2->L2_FILIAL+SL2->L2_NUM )
		EndIf	

		SL2->(DbSkip())

		xDtEmissao := SL2->L2_EMISSAO	
		If ValType(xDtEmissao) == "C"
			xDtEmissao := Ctod(xDtEmissao)
		EndIf
	EndDo

	SET DELETED ON 	//Desconsidera deletados

	DbSelectArea("SL1")
	SL1->(DbSetOrder(1))

	For nX := 1 to Len(aSL2)
		If !SL1->(DbSeek(aSL2[nX])) //Se achar L2 e nao tiver o L1, denota L1 deletado manualmente
			lDelManual := .T.
			Exit
		Else
			lDelManual := .F.
		EndIf
	Next nX	

	(cAlias)->(DbGoTop())
EndIf

While !(cAlias)->(Eof()) .AND. (cAlias)->L1_FILIAL == cFilSL1 .AND. (cAlias)->L1_DTLIM <= dDataFim

	If !Empty((cAlias)->L1_NUMORC)

		AAdd(::DavListRet,WSClassNew("DavList"))

		nPos++

		cNomCli		:= AllTrim((cAlias)->A1_NOME)
		cCGCCli		:= AllTrim((cAlias)->A1_CGC) 		    

		::DavListRet[nPos]:CNPJ			:= AllTrim(SM0->M0_CGC)
		::DavListRet[nPos]:Codigo 		:= (cAlias)->L1_NUMORC
		::DavListRet[nPos]:Emissao		:= (cAlias)->L1_EMISSAO
		::DavListRet[nPos]:Titulo		:= cTitulo 
		::DavListRet[nPos]:COO			:= (cAlias)->L1_NUMCFIS //COO do Cupom Fiscal da venda concretizada
		::DavListRet[nPos]:CCF			:= (cAlias)->L1_CONTDOC 
		::DavListRet[nPos]:COODAV		:= (cAlias)->L1_COODAV  //COO do documento onde a DAV foi impressa pelo ECF, quando impressão por equipamento não fiscal será sinalizado pela String: "0000000"
		::DavListRet[nPos]:SerPDV		:= AllTrim((cAlias)->L1_SERPDV)
		
		lTemPDV := .F.

		aAreaSLG := SLG->(GetArea())		
		SLG->(DbSetOrder(1))
		SLG->(DbGoTop())		
		While !SLG->(Eof()) .And. !lTemPDV
			If AllTrim((cAlias)->L1_SERPDV) == AllTrim(SLG->LG_SERPDV)
				lTemPDV := .T.
				Exit
			EndIf
			
			SLG->(DbSkip())
		End

		If !lTemPDV .And. Empty(AllTrim((cAlias)->L1_PDV))		
			::DavListRet[nPos]:Serie  := ""
			::DavListRet[nPos]:MFAdic := ""
			::DavListRet[nPos]:TipoECF:= ""
			::DavListRet[nPos]:Marca  := ""
			::DavListRet[nPos]:Modelo := ""
		
			aRetSLG[1] := ""
			aRetSLG[2] := ""						
		Else
			::DavListRet[nPos]:Serie := (cAlias)->L1_PDV
			STDBusDEst(	AllTrim(SLG->LG_ECFINFO), @aRetSLG[1], @aRetSLG[2], @aRetSLG[3],; 
			@aRetSLG[4], @aRetSLG[5], @aRetSLG[6], @aRetSLG[7] ,;
			@aRetSLG[8], @aRetSLG[9], @aRetSLG[10] , @aRetSLG[11],;
			@aRetSLG[12])
		
			::DavListRet[nPos]:MFAdic := aRetSLG[12]
			::DavListRet[nPos]:TipoECF:= aRetSLG[1]
			::DavListRet[nPos]:Marca  := aRetSLG[8]
			::DavListRet[nPos]:Modelo := aRetSLG[2]
		
			aRetSLG[1] := AllTrim(SLG->LG_PAFMD5)
			aRetSLG[2] := AllTrim(MD5(AllTrim(SLG->LG_ECFINFO)+AllTrim(Upper(SLG->LG_IMPFISC)),2))
		EndIf
		RestArea(aAreaSLG)
		lPafMD5OK := .T.

		/*If lHomolPaf .And. ( AllTrim(cNomCli) <> AllTrim((cAlias)->L1_CLIENTE) .Or. AllTrim(cCGCCli) <> AllTrim((cAlias)->L1_CGCCLI) )
		cNomCli := AllTrim((cAlias)->L1_CLIENTE)
		cCGCCli := AllTrim((cAlias)->L1_CGCCLI)
		lPafMD5OK := .F.
		EndIf*/

		::DavListRet[nPos]:NomeClient	:= cNomCli
		::DavListRet[nPos]:CNPJClient	:= cCGCCli

		//Gera Chave MD5 dos dados armazenados 
		cPafMd5 := STxPafMd5(cAlias)

		/*
		Trecho para que caso necessario atualize o MD-5
		If lHomolPaf
		DbSelectArea("SL1")
		SL1->(DbSetOrder(1))
		SL1->(MsSeek(xFilial("SL1")+(cAlias)->L1_NUM))
		RecLock("SL1",.F.)
		REPLACE SL1->L1_PAFMD5 WITH cPafMd5
		SL1->(MsUnlock())
		EndIf	
		*/

		lPafMD5OK := lPafMD5OK .And.  ((cAlias)->L1_PAFMD5 == cPafMd5 ) .And. (aRetSLG[1] == aRetSLG[2])

		//Valida chave
		::DavListRet[nPos]:PAFMD5OK	:= lPafMD5OK

		SET DELETED OFF  //Habilita deletados para considerar item cancelado
		DbSelectArea("SL2")                                     
		SL2->(DbSetOrder(1)) //L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO     
		SL2->(DbSeek(xFilial("SL2")+(cAlias)->L1_NUM))		

		//Inicializa Array
		::DavListRet[nPos]:LstItemDav := {}
		::DavListRet[nPos]:LstItDavLog := {}
		nPosItem:= 0
		nVlrTot	:= 0

		SL2->(DbSeek(xFilial("SL2")+(cAlias)->L1_NUM))
		While !SL2->(Eof()) .AND. (SL2->(L2_FILIAL+L2_NUM) == xFilial("SL2")+(cAlias)->L1_NUM)

			//Verifica se eh um item do DAV, nao deve trazer itens que foram adicionados no ato da venda
			If (!SL2->(Deleted())  .OR. (SL2->(Deleted()) .AND. SL2->L2_VENDIDO == "N" )) .AND. !Empty(SL2->L2_PAFMD5) 
				//.AND. (Empty(SL2->L2_CONTDOC) .OR. (!Empty(SL2->L2_CONTDOC) .AND. !Empty(SL2->L2_NUMORIG)) ) //L2_NUMORIG não é preenchido no Loja, mantido para caso seja necessário retornar/reavaliar
				
				nPosItem++								                                     

				//Auxiliar para atualizar valor total da DAV
				If AllTrim(SL2->L2_VENDIDO) <> "N" .AND. !SL2->(Deleted())
					nVlrTot += SL2->L2_VLRITEM
				EndIf

				AAdd(::DavListRet[nPos]:LstItemDav, WSClassNew("ItDavList"))
				::DavListRet[nPos]:LstItemDav[nPosItem]:CNPJ		:= AllTrim(SM0->M0_CGC)			                                                                        
				::DavListRet[nPos]:LstItemDav[nPosItem]:Emissao		:= (cAlias)->L1_EMISSAO
				::DavListRet[nPos]:LstItemDav[nPosItem]:NumItem		:= Val(SL2->L2_ITEM)   				
				::DavListRet[nPos]:LstItemDav[nPosItem]:CodProd		:= SL2->L2_PRODUTO
				::DavListRet[nPos]:LstItemDav[nPosItem]:Descricao	:= SL2->L2_DESCRI
				::DavListRet[nPos]:LstItemDav[nPosItem]:Quantidade	:= SL2->L2_QUANT * &("1" + Replicate("0",nQtdDecQuant))
				::DavListRet[nPos]:LstItemDav[nPosItem]:UnMedida	:= SL2->L2_UM
				::DavListRet[nPos]:LstItemDav[nPosItem]:VlrUnit		:= SL2->L2_PRCTAB * &("1" + Replicate("0",nQtdDecVUnit))				
				::DavListRet[nPos]:LstItemDav[nPosItem]:DescItem	:= SL2->L2_VALDESC
				::DavListRet[nPos]:LstItemDav[nPosItem]:AcreItem	:= 0
				::DavListRet[nPos]:LstItemDav[nPosItem]:VlrLiq		:= SL2->L2_VLRITEM
				
				If lNewField
					::DavListRet[nPos]:LstItemDav[nPosItem]:DecQtde		:= SL2->L2_DECQTD
					::DavListRet[nPos]:LstItemDav[nPosItem]:DecVlrUnt	:= SL2->L2_DECVLU
				Else
					::DavListRet[nPos]:LstItemDav[nPosItem]:DecQtde		:= nQtdDecQuant
					::DavListRet[nPos]:LstItemDav[nPosItem]:DecVlrUnt	:= nQtdDecVUnit
				EndIf

				//deve-se pesquisar a aliquota pois caso haja alteração no banco ela deve aparecer - TESTE BLOCO VII
				If lHomolPaf .OR. Empty(AllTrim(SL2->L2_SITTRIB))
					DbSelectArea("SF4")
					DbSelectArea("SB1")

					SB1->(DbSetOrder(1))
					SF4->(DbSetOrder(1))

					SB1->(DbSeek(xFilial("SB1")+SL2->L2_PRODUTO))
					SF4->(DbSeek(xFilial("SF4")+SL2->L2_TES))	

					aLjExcecao := LjxExcecao(.T.)
					lExcecaoFcl:= Len(aLjExcecao) > 0
					
					If SF4->F4_ISS == "S" //Servico

						If SB1->B1_ALIQISS > 0
							nAliqIss:= SB1->B1_ALIQISS
						Else
							nAliqIss:= SuperGetMv("MV_ALIQISS")
						EndIf

						AAdd( aAux , "S" + AllTrim(Str(nAliqIss,5,2)))

					ElseIf ((SB1->B1_PICMRET > 0 .OR. SB1->B1_PICMENT > 0) .OR.;
					 	(lExcecaoFcl .AND. (aLjExcecao[3] > 0 .OR. aLjExcecao[16] > 0 )) );
						.AND. SA1->A1_TIPO $ cTpSolCf .AND. SF4->F4_BSICMST <> 100
						
						AAdd( aAux , "F" )						// Substituicao tributaria (Icms Solidario)

					ElseIf (SF4->F4_BASEICM > 0 .AND. SF4->F4_BASEICM < 100) .Or. ;
						(lExcecaoFcl .AND. (aLjExcecao[14] > 0) .AND. (aLjExcecao[14] < 100))
					
						AAdd( aAux , "T" + Alltrim(Str( SB0->B0_ALIQRED,5,2 )))		  // com reducao de Icms na Base

					ElseIf SF4->F4_LFICM == "I"		// Isento
						AAdd( aAux , "I" )

					ElseIf SF4->F4_LFICM == "N"		// Nao sujeito a ICMS
						AAdd( aAux ,  "N" )
					Else									// Com ICMS
						nAliquota := AliqIcms("N","S",SA1->A1_TIPO,"I")
						AAdd( aAux , "T" + Alltrim(Str(nAliquota,5,2)))			
					EndIf

					If Len(aAux) > 0
						aAux[1] := strtran(aAux[1],",","")
						aAux[1] := strtran(aAux[1],".","")						
					EndIf 	
				Else
					AAdd( aAux , SL2->L2_SITTRIB )	
				EndIf 

				//Verifica a alteração no banco de dados
				If AllTrim(Upper(aAux[1])) == AllTrim(Upper(SL2->L2_SITTRIB))
					::DavListRet[nPos]:LstItemDav[nPosItem]:TotParc		:= AllTrim(SL2->L2_SITTRIB)
				Else
					::DavListRet[nPos]:LstItemDav[nPosItem]:TotParc		:= AllTrim(aAux[1])
				EndIf	

				::DavListRet[nPos]:LstItemDav[nPosItem]:ItCancel	:= (AllTrim(SL2->L2_VENDIDO) == "N")

				//O MD5 do SL2 deve ser composto pelo L1_NUMORC para que seja possível validar
				//ao efetuar alteração pelo Banco de Dados. Teste de Homologação do Bloco VII
				cPafMd5 := STxPafMd5("SL2" , AllTrim((cAlias)->L1_NUMORC) )

				/*
				//Trecho para possivel e necessaria alteração do MD-5
				If lHomolPaf 
				RecLock("SL2",.F.)
				REPLACE SL2->L2_PAFMD5 WITH cPafMd5
				SL2->(MsUnlock())
				EndIf	
				*/

				If AllTrim(SL2->L2_PAFMD5) == AllTrim(cPafMd5) .And. lPafMD5OK
					::DavListRet[nPos]:LstItemDav[nPosItem]:PAFMD5OK	:= .T.
				Else
					::DavListRet[nPos]:LstItemDav[nPosItem]:PAFMD5OK	:= .F.
				EndIf

			EndIf
			SL2->(DbSkip())
		End

		nPosItem	:= 0
		If nPos > 0  
			::DavListRet[nPos]:Valor := nVlrTot
		EndIf

		If lLogDAV 
			DbSelectArea("MFT")			
			MFT->(DbSetOrder(2))  //MFT_FILIAL+MFT_NUM+DTOS(MFT_ALTERA)+MFT_HRALT
			MFT->(DbSeek(xFilial("SL2")+(cAlias)->L1_NUM))
			While !MFT->(Eof()) .AND. (MFT->(MFT_FILIAL+MFT_NUM) == xFilial("SL2")+(cAlias)->L1_NUM)

				nPosItem++

				AAdd(::DavListRet[nPos]:LstItDavLog, WSClassNew("ItDavLstLg"))					                                                          
				::DavListRet[nPos]:LstItDavLog[nPosItem]:Hora 			:= MFT->MFT_HRALT
				::DavListRet[nPos]:LstItDavLog[nPosItem]:Alteracao		:= MFT->MFT_ALTERA  				
				::DavListRet[nPos]:LstItDavLog[nPosItem]:CodProd		:= MFT->MFT_PRODUT
				::DavListRet[nPos]:LstItDavLog[nPosItem]:Descricao		:= MFT->MFT_DESCRI
				::DavListRet[nPos]:LstItDavLog[nPosItem]:Quantidade		:= MFT->MFT_QUANT * &("1" + Replicate("0",nQtdDecQuant))
				::DavListRet[nPos]:LstItDavLog[nPosItem]:UnMedida		:= MFT->MFT_UM
				::DavListRet[nPos]:LstItDavLog[nPosItem]:VlrUnit		:= MFT->MFT_PRCTAB * &("1" + Replicate("0",nQtdDecVUnit))				
				::DavListRet[nPos]:LstItDavLog[nPosItem]:DescItem		:= MFT->MFT_VALDES
				::DavListRet[nPos]:LstItDavLog[nPosItem]:AcreItem		:= 0
				::DavListRet[nPos]:LstItDavLog[nPosItem]:VlrLiq			:= MFT->MFT_VLRITEM
				::DavListRet[nPos]:LstItDavLog[nPosItem]:TotParc		:= AllTrim(MFT->MFT_SITTRI)				
				::DavListRet[nPos]:LstItDavLog[nPosItem]:ItCancel		:= (AllTrim(MFT->MFT_VENDID) == "N")					
				::DavListRet[nPos]:LstItDavLog[nPosItem]:TipoAlt		:= MFT->MFT_SITUA
				If lNewField
					::DavListRet[nPos]:LstItDavLog[nPosItem]:DecQtde		:= MFT->MFT_DECQTD
					::DavListRet[nPos]:LstItDavLog[nPosItem]:DecVlrUnt		:= MFT->MFT_DECVLU
				Else
					::DavListRet[nPos]:LstItDavLog[nPosItem]:DecQtde		:= nQtdDecQuant
					::DavListRet[nPos]:LstItDavLog[nPosItem]:DecVlrUnt		:= nQtdDecVUnit
				EndIf

				cPafMD5 := STxPafMd5("MFT")
				::DavListRet[nPos]:LstItDavLog[nPosItem]:PafMD5OK		:= cPafMd5 == AllTrim(MFT->MFT_PAFMD5) .And. lPafMD5OK
				lMFTManual := .F.
				
				If lNewField
					//Valida Exclusão manual
					If MFT->(Deleted()) .And. !Empty(MFT->MFT_PAFMD5) .And. !Empty(AllTrim(MFT->MFT_DOC))//verificar se não precisa de outro campo
						lMFTManual := .T.
	
						//Valida inclusão manual
					ElseIf !MFT->(Deleted()) .And. Empty(MFT->MFT_PAFMD5) .And. Empty(AllTrim(MFT->MFT_DOC))
						lMFTManual := .T.
					EndIf
				EndIf

				::DavListRet[nPos]:LstItDavLog[nPosItem]:IncManual := lMFTManual

				MFT->(DbSkip())
			End

			MFT->(DbCloseArea())					 
		EndIf

		SET DELETED ON 	//Desconsidera deletados
	EndIf

	If nPos > 0	
		//Valida Inclusão ou Deleção Manual direto no Banco de Dados da Tabela SL2 - Teste Bloco VII - Homologacao PAF-ECF
		If !(nVlrTot == (cAlias)->L1_VLRTOT) .OR. lIncManual
			::DavListRet[nPos]:IncManual := .T.
		Else
			::DavListRet[nPos]:IncManual := .F.	
		EndIf

		If !::DavListRet[nPos]:IncManual .And. lDelManual
			::DavListRet[nPos]:IncManual := .T.
			lDelManual := .F.
		EndIf
	EndIf

	(cAlias)->(DbSkip())
End

(cAlias)->(DbCloseArea())

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Metodo	 ³LstMePagto³ Autor ³ Venda Clientes        ³ Data ³13/05/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consulta meios de pagamento utilizados no PDV em um periodo ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 - Data inicial                                       ³±±
±±³          ³ ExpD2 - Data final                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpA1 - Estrutura contendo os meios de pagamento utilizados³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD LstMePagto WSRECEIVE dDataIni,dDataFim,cPDV,cEmpPdv,;
	cFilPdv,lHomolPaf,lFiltraNFe,;
	lIsR07 WSSEND MeiPgtRet WSSERVICE FRTPafEcf

Local cFilSL1		:= ""					// Filial da tabela SL1
Local cFilSL4		:= ""					// Filial da tabela SL4
Local nPos			:= 0					// Posicao atual no retorno do WebService
Local nCntArr		:= 0					// Contador de elementos no array de retorno
Local dEmisAtu		:= Ctod("")				// Data da emissao atual para quebra
Local aPgtos		:= {{},{}}				// Acumulador de pagamentos para a data
Local cAlias		:= "SL1"				// Alias da tabela SL1
Local cChave		:= ""					// Chave para acumular valores
Local cQuery		:= ""
Local cChaveSX5 	:= ""
Local aDadosPgt 	:= {}
Local aDescTpPag	:= {}					//Array que contera as descricoes das formas de pagamento existentes no X5
Local aAreaSX5		:= {}
Local nX        	:= 0 
Local nY			:= 0
Local cPafMd5		:= ""			        // Chave MD5
Local cFilMDZ 		:= ""					// Filial da tabela MDZ
Local cAliasMDZ		:= "MDZ"				// Alias utilizado para consulta dos dados na MDZ
Local cDescTpPag	:= ""
Local cTipoDoc		:= ""
Local lUsaMDZ		:= .F.	// sinaliza que possui a tabela MDZ
Local lIncManual	:= .F.
Local lDelManual	:= .F.
Local cAlias2		:= "SF2"   
Local cFilSF2		:= "" 
Local cSerPAF		:= ""
Local cSerPDV		:= ""
Local cNumDoc		:= ""
Local nTamSerie		:= 0
Local nValTroco		:= 0

Default lFiltraNFe 	:= .F.
Default lIsR07		:= .T.

//³Chama RPCSETENV³
LjPreparaWs(::cEmpPdv,::cFilPdv)

nTamSerie:= TamSX3("F2_SERIE")[1]
lUsaMDZ	:= AliasInDic( "MDZ" )
cFilSL1	:= xFilial("SL1")		// Filial da tabela SL1
cFilSL4	:= xFilial("SL4")		// Filial da tabela SL4
cFilSF2	:= xFilial("SF2")		//Filial da Tabela SF2

DbSelectArea("SX5")
aAreaSX5 := SX5->(GetArea())
SX5->(DbSetOrder(1))
cChaveSX5 := xFilial("SX5")+"24"
SX5->(DbSeek(cChaveSX5))
While !SX5->(Eof()) .AND. (SX5->X5_FILIAL+SX5->X5_TABELA == cChaveSX5)
	Aadd( aDescTpPag , {SX5->X5_CHAVE,SX5->X5_DESCRI} )
	SX5->(DbSkip())
EndDo 
RestArea(aAreaSX5)

/*Pesquisa dos Pagamentos*/
cAlias := "SL1TMP"	
cQuery	:= " SELECT L1_FILIAL,L1_EMISSAO,L1_NUM,L1_PDV,L1_NUMCFIS,L1_PDV," 
cQuery	+= " L1_CONTDOC,L1_CONTONF,L1_STORC, L1_SERPDV, L1_DOC,L1_SERIE,L1_ESPECIE,"
cQuery	+= " L1_TPORC, L1_CGCCLI "
cQuery	+= " FROM " + RetSqlName("SL1")
cQuery	+= " WHERE D_E_L_E_T_ = ' ' AND L1_FILIAL = '" + cFilSL1 + "'"
cQuery	+= " AND L1_EMISSAO BETWEEN '" + DtoS(dDataIni) + "' AND '" + DtoS(dDataFim) + "' AND L1_DOC <> ' ' "
If !Empty(cPDV)
	cQuery	+= " AND L1_PDV = '" + cPDV + "' " 
EndIf

//No registro R07 não aparece o Nota Fiscal Manual, porem no A2 sim e é usado a mesma pesquisa
If lIsR07
	cQuery += " AND L1_ESPECIE <> 'NFM' "
endIf

cQuery	+= " ORDER BY L1_EMISSAO "
cQuery	:= ChangeQuery(cQuery)

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlias, .F., .T.)
TcSetField(cAlias,"L1_EMISSAO","D")	
(cAlias)->(DbGoTop())

DbSelectArea("SL4")
SL4->(DbSetOrder(1))//L4_FILIAL+L4_NUM+L4_ORIGEM

/*
***************************************************************************************************************************
	Para validar Inclusão/Deleção via Banco de Dados - Teste Bloco VII
Inclusão : verifica se o campo do MD5 está em branco e deve ser incluído um registro com mesmo L2_NUM de uma venda valida
Deleção  : verifica no DbSeek se acha o L4 do L1 se nao achar achar eh porque houve a deleção via banco
***************************************************************************************************************************
*/

While !(cAlias)->(Eof()) .AND. (cAlias)->L1_FILIAL == cFilSL1 .AND. (cAlias)->L1_EMISSAO <= dDataFim

	If dEmisAtu <> (cAlias)->L1_EMISSAO

		If Len(aPgtos[1]) > 0
			AAdd(::MeiPgtRet,WSClassNew("MeiPgtList"))
			nCntArr++

			::MeiPgtRet[nCntArr]:Emissao	:= dEmisAtu
			::MeiPgtRet[nCntArr]:Tipos		:= aClone(aPgtos[1])
			::MeiPgtRet[nCntArr]:Totais		:= aClone(aPgtos[2])
			::MeiPgtRet[nCntArr]:IncManual	:= lIncManual .Or. lDelManual

			//Carrega Detalhes da Forma de Pagamento
			If Len(aDadosPgt) > 0
				::MeiPgtRet[nCntArr]:DadosPag  := Array( Len(aDadosPgt), 11 )

				For nX := 1 To Len(aDadosPgt)
					::MeiPgtRet[nCntArr]:DadosPag[nX] 			:= WSClassNew("PagList")					    				 
					::MeiPgtRet[nCntArr]:DadosPag[nX]:TipoPag   := aDadosPgt[nX][1]
					::MeiPgtRet[nCntArr]:DadosPag[nX]:Valor    	:= aDadosPgt[nX][2]
					::MeiPgtRet[nCntArr]:DadosPag[nX]:ContOrdOp	:= aDadosPgt[nX][3]
					::MeiPgtRet[nCntArr]:DadosPag[nX]:NumContDoc:= aDadosPgt[nX][4]
					::MeiPgtRet[nCntArr]:DadosPag[nX]:NumContOnf:= aDadosPgt[nX][5]
					::MeiPgtRet[nCntArr]:DadosPag[nX]:SerPdv	:= aDadosPgt[nX][6]
					::MeiPgtRet[nCntArr]:DadosPag[nX]:PAFMD5OK	:= aDadosPgt[nX][7]
					::MeiPgtRet[nCntArr]:DadosPag[nX]:Cancelado	:= aDadosPgt[nX][8]
					::MeiPgtRet[nCntArr]:DadosPag[nX]:DescTpPag	:= aDadosPgt[nX][9]
					::MeiPgtRet[nCntArr]:DadosPag[nX]:TipoDoc	:= aDadosPgt[nX][10]

					//A ultima posição valida a inclusão manual pelo banco , L4_PAFMD5 em branco
					::MeiPgtRet[nCntArr]:DadosPag[nX]:IncManual	:= aDadosPgt[nX][11]
				Next nX
			EndIf
		EndIf

		dEmisAtu	:= (cAlias)->L1_EMISSAO
		aPgtos 	:= {{},{}} 
		aDadosPgt	:= {}

		//Totaliza Suprimentos(R$) via tabela de movimento do ECF para PAF-ECF(MDZ)
		If lUsaMDZ

			cFilMDZ	:= xFilial("MDZ")
			cChave	:= "R$"				
			cAliasMDZ := "MDZTMP"

			If Select(cAliasMDZ) > 0
				(cAliasMDZ)->(DbCloseArea())
			EndIf

			cQuery	:=	"SELECT MDZ_FILIAL,MDZ_COO,MDZ_CDC,MDZ_CCF,MDZ_GNF,MDZ_GRG,MDZ_SIMBOL,MDZ_TIPO,"
			cQuery	+=	"MDZ_VALOR,MDZ_SERPDV,MDZ_DATA,MDZ_HORA,MDZ_PAFMD5,MDZ_PDV "
			cQuery	+=	"FROM " + RetSqlName("MDZ") + " "
			cQuery	+=	"WHERE D_E_L_E_T_ = ' ' AND MDZ_FILIAL = '" + cFilMDZ + "' "
			If !Empty(cPDV)
				cQuery	+=	"AND MDZ_PDV = '" + cPDV + "' "  	
			EndIf
			cQuery	+=	" AND MDZ_DATA = '" + DtoS(dEmisAtu)+ "' "
			cQuery	+=	" AND MDZ_SIMBOL = 'CN' "
			cQuery	+=	" AND MDZ_TIPO NOT IN ('SUPRIMENTO','SANGRIA') " //Não pode aparecer SANGRIA e SUPRIMENTO no A2
			cQuery	:=	ChangeQuery( cQuery )

			DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAliasMDZ, .F., .T.)
			TcSetField(cAliasMDZ,"MDZ_DATA","D")	
			(cAliasMDZ)->(DbGoTop())

			While !(cAliasMDZ)->(Eof())
				 
				nPos 	:= aScan(aPgtos[1],cChave)

				If nPos == 0
					AAdd(aPgtos[1],cChave)
					AAdd(aPgtos[2],(cAliasMDZ)->MDZ_VALOR)  
				Else
					aPgtos[2][nPos] += (cAliasMDZ)->MDZ_VALOR
				EndIf

				cPafMd5 := STxPafMd5(cAliasMDZ)			

				nY := Ascan(aDescTpPag , { |x| AllTrim(x[1]) == AllTrim(cChave) })
				If nY > 0
					cDescTpPag	 := aDescTpPag[nY][2]
				Else
					cDescTpPag	 := "Dinheiro"
				EndIf
				If Val((cAliasMDZ)->MDZ_GNF) > 0
					cTipoDoc := "Documento Não Fiscal"
				ElseIf Val((cAliasMDZ)->MDZ_CCF) == 0
					cTipoDoc := "Nota Fiscal"
				ElseIf Val((cAliasMDZ)->MDZ_CCF) > 0
					cTipoDoc := "Cupom Fiscal" 
				EndIf  

				If Empty((cAliasMDZ)->MDZ_PAFMD5) 
					lIncManual := .T.
				Else
					lIncManual := .F.
				EndIf
				//A ultima posição valida a inclusão manual pelo banco , L4_PAFMD5 em branco       		
				AAdd(aDadosPgt, {cChave, (cAliasMDZ)->MDZ_VALOR, Val((cAliasMDZ)->MDZ_COO),;
				Val((cAliasMDZ)->MDZ_GNF), Val((cAliasMDZ)->MDZ_CCF), ;
				If(!Empty(AllTrim((cAliasMDZ)->MDZ_SERPDV)), (cAliasMDZ)->MDZ_SERPDV, LjPesqPdv((cAliasMDZ)->MDZ_PDV,"") ),;
				((cAliasMDZ)->MDZ_PAFMD5 == cPafMd5),.F.,;
				cDescTpPag, cTipoDoc, Empty((cAliasMDZ)->MDZ_PAFMD5)})

				(cAliasMDZ)->(DbSkip())
			EndDo
			
			(cAliasMDZ)->(DbCloseArea())
		EndIf
	EndIf

	If  ( Empty(cPDV) .OR. AllTrim((cAlias)->L1_PDV) == AllTrim(cPDV)  ) .AND. !Empty((cAlias)->L1_DOC) 
		//Se nao foi encontrado o SL4 da venda, significa que 
		//foi deletado manualmente via banco de dados - Teste Bloco VII
		If !SL4->(DbSeek(cFilSL4+(cAlias)->L1_NUM)) .OR. Empty(SL4->L4_PAFMD5)
			lDelManual := .T.
		Else
			lDelManual := .F.
		EndIf

		While !SL4->(Eof()) .AND. SL4->L4_NUM == (cAlias)->L1_NUM

			If Empty(SL4->L4_INSTITU)
				cChave	:= AllTrim(SL4->L4_FORMA)
			Else
				cChave	:= AllTrim(SL4->L4_FORMA) + "-" + AllTrim(SL4->L4_INSTITU)
			EndIf

			nPos 	:= aScan(aPgtos[1],cChave)

			If nPos == 0
				AAdd(aPgtos[1],cChave)
				AAdd(aPgtos[2],SL4->L4_VALOR)
			Else
				aPgtos[2][nPos] += SL4->L4_VALOR
			EndIf

			cPafMd5 := STxPafMd5("SL4")

			nY := Ascan(aDescTpPag , { |x| AllTrim(x[1]) == AllTrim(SL4->L4_FORMA) })
			If nY > 0
				cDescTpPag	 := aDescTpPag[nY][2]
			Else
				cDescTpPag	 := "Dinheiro"
			EndIF

			If !Empty(Alltrim(SL4->L4_SERPDV))
				cSerPdv := SL4->L4_SERPDV
			ElseIf !Empty(Alltrim((cAlias)->L1_SERPDV))
				cSerPDV := (cAlias)->L1_SERPDV
			EndIf

			If Empty(AllTrim(cSerPDV))
				cSerPDV := LjPesqPdv((cAlias)->L1_PDV,(cAlias)->L1_SERIE)
			EndIf

			cNumDoc := iif( Val(SL4->L4_DOC) == 0 , Val((cAlias)->L1_DOC) ,Val(SL4->L4_DOC) )

			If Val((cAlias)->L1_NUMCFIS) == 0 .AND. Empty(AllTrim((cAlias)->L1_PDV))					
				cTipoDoc := "Nota Fiscal"
			ElseIf Val((cAlias)->L1_NUMCFIS) > 0 .AND. !Empty(AllTrim((cAlias)->L1_SERPDV))
				cTipoDoc := "Cupom Fiscal"

				If AllTrim((cAlias)->L1_ESPECIE) == "NFCF" //o L1_DOC contem o numero da nota e deve mostrar o COO pois foi impresso um cupom
					cNumDoc := Val((cAlias)->L1_NUMCFIS)
				EndIf
			ElseIf Val((cAlias)->L1_CONTONF) > 0
				cTipoDoc := "Documento Não Fiscal"
			EndIf

			nValTroco := 0

			If SL4->L4_TROCO > 0
				nValTroco := SL4->L4_TROCO
			EndIf

			//A ultima posição valida a inclusão manual pelo banco , L4_PAFMD5 em branco       		
			AAdd(aDadosPgt, {cChave, SL4->L4_VALOR-nValTroco,  cNumDoc  ,;
			IF ( Val(SL4->L4_CONTDOC)== 0, Val((cAlias)->L1_CONTDOC),Val(SL4->L4_CONTDOC)),;
			IF ( Val(SL4->L4_CONTONF)== 0, Val((cAlias)->L1_CONTONF),Val(SL4->L4_CONTONF)), ;
			cSerPDV ,(SL4->L4_PAFMD5 == cPafMd5) .And. WsLeMD5LG(cSerPDV),((cAlias)->L1_STORC == "C"), cDescTpPag , cTipoDoc,;
			Empty(SL4->L4_PAFMD5)} ) 		    

			SL4->(DbSkip())
		End
	EndIf

	(cAlias)->(DbSkip())
EndDo

If lFiltraNFe  

	cSerPAF	:= SuperGetMv("MV_LJSNFEP",,"") //Serie da NF-e no PAF

	cAlias2 := "SF2TMP"
	cQuery	:= " SELECT F2_FILIAL, F2_SERIE, F2_EMISSAO,  F2_CHVNFE, F2_VALBRUT " 	
	cQuery	+= " FROM " + RetSqlName("SF2")
	cQuery	+= " WHERE D_E_L_E_T_ = ' ' AND F2_FILIAL = '" + cFilSF2 + "'"
	//Tem que ser exatamente a serie de NF-e de venda em PAF senão virão 
	//todas as vendas do Protheus, inclusive vendas da SL1 que já foram acumuladas  
	cQuery	+= " AND F2_SERIE = '" + cSerPAF + "' "
	cQuery	+= " AND F2_EMISSAO BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"' "
	cQuery	+= " AND F2_CHVNFE <> ' ' "
	cQuery	+= " ORDER BY F2_EMISSAO "

	cQuery	:= ChangeQuery(cQuery)

	If Select(cAlias2) > 0
		(cAlias2)->(DbCloseArea())
	EndIf

	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlias2, .F., .T.)
	TcSetField(cAlias2,"F2_EMISSAO","D")		
	(cAlias2)->(DbGoTop())
	cChave	:= "DU - DUPLICATA"

	While !(cAlias2)->(Eof())

		lIncManual  := .F.

		If !Empty((cAlias2)->F2_CHVNFE)

			If dEmisAtu <> (cAlias2)->F2_EMISSAO

				If Len(aPgtos[1]) > 0
					AAdd(::MeiPgtRet,WSClassNew("MeiPgtList"))
					nCntArr++

					::MeiPgtRet[nCntArr]:Emissao	:= dEmisAtu
					::MeiPgtRet[nCntArr]:Tipos		:= aClone(aPgtos[1])
					::MeiPgtRet[nCntArr]:Totais		:= aClone(aPgtos[2])
					::MeiPgtRet[nCntArr]:IncManual	:= lIncManual .Or. lDelManual

					//Carrega Detalhes da Forma de Pagamento
					If Len(aDadosPgt) > 0
						::MeiPgtRet[nCntArr]:DadosPag  := Array( Len(aDadosPgt), 11 )

						For nX := 1 To Len(aDadosPgt)
							::MeiPgtRet[nCntArr]:DadosPag[nX] 			:= WSClassNew("PagList")					    				 
							::MeiPgtRet[nCntArr]:DadosPag[nX]:TipoPag   := aDadosPgt[nX][1]
							::MeiPgtRet[nCntArr]:DadosPag[nX]:Valor    	:= aDadosPgt[nX][2]
							::MeiPgtRet[nCntArr]:DadosPag[nX]:ContOrdOp	:= aDadosPgt[nX][3]
							::MeiPgtRet[nCntArr]:DadosPag[nX]:NumContDoc:= aDadosPgt[nX][4]
							::MeiPgtRet[nCntArr]:DadosPag[nX]:NumContOnf:= aDadosPgt[nX][5]
							::MeiPgtRet[nCntArr]:DadosPag[nX]:SerPdv	:= aDadosPgt[nX][6]
							::MeiPgtRet[nCntArr]:DadosPag[nX]:PAFMD5OK	:= aDadosPgt[nX][7]
							::MeiPgtRet[nCntArr]:DadosPag[nX]:Cancelado	:= aDadosPgt[nX][8]
							::MeiPgtRet[nCntArr]:DadosPag[nX]:DescTpPag	:= aDadosPgt[nX][9]
							::MeiPgtRet[nCntArr]:DadosPag[nX]:TipoDoc	:= aDadosPgt[nX][10]

							//A ultima posição valida a inclusão manual pelo banco , L4_PAFMD5 em branco
							::MeiPgtRet[nCntArr]:DadosPag[nX]:IncManual	:= aDadosPgt[nX][11]
						Next nX
					EndIf
				EndIf

				dEmisAtu	:= (cAlias2)->F2_EMISSAO
				aPgtos 	:= {{},{}} 
				aDadosPgt	:= {}
			EndIf

			nPos 	:= aScan(aPgtos[1],cChave)

			If nPos == 0
				AAdd(aPgtos[1],cChave)
				AAdd(aPgtos[2],(cAlias2)->F2_VALBRUT)  
			Else
				aPgtos[2][nPos] += (cAlias2)->F2_VALBRUT
			EndIf

			cDescTpPag := "Duplicata"
			cTipoDoc := "Nota Fiscal"		   		 	

			//Gera o Registro da NF-e  
			AAdd(aDadosPgt, {"", (cAlias2)->F2_VALBRUT, 0, 0, 0,"",.T.,.F., cDescTpPag , cTipoDoc,.F.} )   		 		
		EndIf

		(cAlias2)->(DbSkip())
	EndDo	

	(cAlias2)->(DbCloseArea())	
EndIf

If Len(aPgtos[1]) > 0
	AAdd(::MeiPgtRet,WSClassNew("MeiPgtList"))
	nCntArr++

	::MeiPgtRet[nCntArr]:Emissao	:= dEmisAtu
	::MeiPgtRet[nCntArr]:Tipos		:= aClone(aPgtos[1])
	::MeiPgtRet[nCntArr]:Totais		:= aClone(aPgtos[2])
	::MeiPgtRet[nCntArr]:IncManual	:= lIncManual .Or. lDelManual

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega Detalhes da Forma de Pagamento.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aDadosPgt) > 0 
		::MeiPgtRet[nCntArr]:DadosPag  := Array( Len(aDadosPgt), 11 )

		For nX := 1 To Len(aDadosPgt)   
			::MeiPgtRet[nCntArr]:DadosPag[nX] 			 := WSClassNew("PagList")	

			::MeiPgtRet[nCntArr]:DadosPag[nX]:TipoPag   := aDadosPgt[nX][1]
			::MeiPgtRet[nCntArr]:DadosPag[nX]:Valor     := aDadosPgt[nX][2]
			::MeiPgtRet[nCntArr]:DadosPag[nX]:ContOrdOp := aDadosPgt[nX][3]
			::MeiPgtRet[nCntArr]:DadosPag[nX]:NumContDoc:= aDadosPgt[nX][4]
			::MeiPgtRet[nCntArr]:DadosPag[nX]:NumContOnf:= aDadosPgt[nX][5]
			::MeiPgtRet[nCntArr]:DadosPag[nX]:SerPdv	:= aDadosPgt[nX][6]
			::MeiPgtRet[nCntArr]:DadosPag[nX]:PAFMD5OK	:= aDadosPgt[nX][7]
			::MeiPgtRet[nCntArr]:DadosPag[nX]:Cancelado	:= aDadosPgt[nX][8]
			::MeiPgtRet[nCntArr]:DadosPag[nX]:DescTpPag	:= aDadosPgt[nX][9]
			::MeiPgtRet[nCntArr]:DadosPag[nX]:TipoDoc	:= aDadosPgt[nX][10]

			//A ultima posição valida a inclusão manual pelo banco , L4_PAFMD5 em branco
			::MeiPgtRet[nCntArr]:DadosPag[nX]:IncManual	:= aDadosPgt[nX][11]
		Next nX
	EndIf
EndIf  

(cAlias)->(DbCloseArea())

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Metodo	 ³LstPdvs   ³ Autor ³ Venda Clientes        ³ Data ³13/05/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Lista pontos de venda cadastrados na retaguarda             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpA1 - Lista com o numero dos PDVs disponiveis            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD LstPdvs WSRECEIVE cEmpPdv, cFilPdv, cFieldRet, lHomolPaf, cPDV, cSeriePDV WSSEND LstPDV WSSERVICE FRTPafEcf
Local cAlias 		:= "SLG"
Local cQuery		:= ""
Local cCampos		:= ""

DEFAULT cFieldRet 	:= "LG_PDV"  
DEFAULT cPDV 		:= ""                 // Numero do ECF extraido do PDV    - Retorno da funcao IfPegPDV
DEFAULT cSeriePDV   := ""				  // Numero de Serie extraido do PDV  - Retorno da funcao IfPegSerie	

//³Chama RPCSETENV³
LjPreparaWs(::cEmpPdv,::cFilPdv)

cAlias := "SLGTMP"

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

cQuery := "SELECT "	
cCampos := " LG_CODIGO,LG_PDV,LG_SERPDV "

If At(cFieldRet,cCampos) == 0
	cCampos += "," + cFieldRet
EndIf

cQuery += cCampos	
cQuery += " FROM " + RetSqlName("SLG")
cQuery += " WHERE LG_FILIAL = '" + xFilial("SLG") + "'"
cQuery += " AND LG_PDV <> ' ' AND D_E_L_E_T_ = ' '"

cQuery := ChangeQuery( cQuery )

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlias, .F., .T.)
(cAlias)->(DbGoTop())

::LstPDV := {}

While !(cAlias)->(Eof())
	//  Se encontrar PDV e Serie estiver diferente, atualiza com o numero recebido
	If !Empty(cSeriePDV) .AND. (Alltrim((cAlias)->LG_PDV) == Alltrim(cPDV)) .AND. (Alltrim((cAlias)->LG_SERPDV) <> Alltrim(cSeriePDV))
		DbSelectArea("SLG")
		SLG->(DbSetOrder(1))
		If SLG->(DbSeek(xFilial("SLG")+(cAlias)->LG_CODIGO))
			RecLock("SLG",.F.)
			REPLACE SLG->LG_SERPDV WITH cSeriePDV  
			SLG->(MsUnLock())                 
			(cAlias)->&(cFieldRet) := cSeriePDV  
		EndIf
	Endif

	DbSelectArea("SLGTMP")		
	If !Empty((cAlias)->&(cFieldRet))
		AAdd(::LstPDV,(cAlias)->&(cFieldRet))
	EndIf
	(cAlias)->(DbSkip())
End                                              

aSort(::LstPDV)

(cAlias)->(DbCloseArea())

Return .T.


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Metodo	 ³LerCrzCro ³ Autor ³ Venda Clientes        ³ Data ³13/05/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna os contadores da reducao Z e reinicio de operacao.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Numero do PDV                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpA1 - Lista com contadores                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD LerCrzCro WSRECEIVE cPdv, cEmpPdv,cFilPdv, lHomolPaf WSSEND CrzCro WSSERVICE FRTPafEcf

Local cAlias	:= ""				// Alias utilizado para consulta dos dados na SL1
Local cQuery	:= ""				// Query para selecao de dados no banco de dados
Local cFilSFI	:= ""

LjPreparaWs(::cEmpPdv,::cFilPdv)

cFilSFI	:= xFilial("SFI")
cAlias := "SFITMP"

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

cQuery	:= "select FI_FILIAL,FI_PDV, FI_NUMREDZ, FI_CRO, FI_DTREDZ, FI_GTFINAL, FI_GTINI"
cQuery	+= "FROM " + RetSqlName("SFI") + " "
cQuery	+= "WHERE D_E_L_E_T_ = ' ' AND FI_FILIAL = '" + cFilSFI + "' "
cQuery	+= "AND FI_PDV ='" + cPDV + "' "
cQuery	+= "ORDER BY FI_DTREDZ"

cQuery := ChangeQuery( cQuery )
DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlias, .F., .T.)
DbGoTop()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Armazena os registros validos no retorno do WebService³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Conout("4 - Inicializa ::CrzCro")
::CrzCro := {'000000000','000000000', 0}

Conout("5 - Entra no loop")

While !(cAlias)->(Eof())

	Conout("6.1 - Entra no loop de crz")
	If  (cAlias)->FI_NUMREDZ > ::CrzCro[1]
		::CrzCro[1] := (cAlias)->FI_NUMREDZ
		::CrzCro[3] := Val(FI_GTFINAL) - Val(FI_GTINI)
	EndIf	

	Conout("6.2 - Entra no loop de crz")	
	If  (cAlias)->FI_CRO > ::CrzCro[2]
		::CrzCro[2] := (cAlias)->FI_CRO
	EndIf	

	(cAlias)->(DbSkip())	
End

(cAlias)->(DbCloseArea())

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Metodo	 ³LstRedZ   ³ Autor ³ Venda Clientes        ³ Data ³18/05/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Lista os dados de reducoes Z de um PDV                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 - Data inicial                                       ³±±
±±³          ³ ExpD2 - Data final                                         ³±±
±±³          ³ ExpC3 - Numero do PDV                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpA1 - Lista com dados das reducoes Z efetuadas           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD LstRedZ WSRECEIVE	dDataIni,dDataFim,cPDV, cEmpPdv,;
	cFilPdv, lHomolPaf, lDataRed WSSEND RedZRet WSSERVICE FRTPafEcf 

Local nPos		:= 0
Local cAlias	:= "SFITMP"
Local cPafMd5	:= ""
Local bWhile	:= Nil
Local lDtRedZ	:= .F.
Local lHrRedZ	:= .F.
Local cQuery	:= ""
Local cIndex	:= ""
Local cChave	:= ""
Local cCond		:= ""               
Local nCont     := 1
Local nPosImp		:= 0
Local aAux      	:= {} 
Local nTotOpNFis	:= 0 					//totaliza operação não fiscal                   
Local lUsaMdz		:= .F.					//sinaliza que possui a tabela MDZ
Local lIncManual	:= .F.
Local lDelManual	:= .F.
Local nTotalSFI		:= 0
Local nTotalValid	:= 0
Local nValISS		:= 0
Local lAlterado		:= .F.
Local lTrataISS		:= .F.
Local lPesquisa		:= .F.
Local lVerSIG031430 := .F. //deve validar a versão da SIGALOJA (versao "0.3.143.0" ou superior) que separou os valores de ISS do ICMS
Local aAreaSX3		:= {}
Local aMd5Del		:= {}

//************************************************************************************************/
// 								NOTA SOBRE O CONTEUDO DAS INFORMAÇÕES DA SFI
//
// 1 -	o campo FI_CANCEL é preenchido de acordo com o modelo do ECF, existem ECFs que mandam 
//		somente os valores de cancelamento de ICMS mas outras somam ICMS + ISS
// 2 - o campo FI_DESC também depende do modelo, alguns modelos mandam desconto de ICMS 
//		e outras mandam desconto de ISS + ICMS
//-> Portanto se no processo de homologação houver alguma diferença nos valores acumulados, 
//utilizar FI_CANCEL-FI_CANISS e FI_DESC-FI_DESISS
//
//-> os campos FI_DESISS e FI_CANISS sao criados pelo UPDLOJ72 e utilizados para o sistema em geral
//************************************************************************************************/
/*Chama RPCSETENV*/
LjPreparaWs(::cEmpPdv,::cFilPdv)

lVerSIG031430 := LjDLLVer(.F.,.F.) >= "0.3.143.0"
lUsaMdz	:= AliasInDic( "MDZ" )	 //Deve ser colocado apos o LjPreparaWs senao retorna erro devido o ambiente nao estar preparado
cPDV := AllTrim(cPDV)

aAreaSX3 := SX3->(GetArea())
SX3->(DbSetOrder(1))
SX3->(DbSeek("SFI"))
While SX3->(!Eof()) .And. AllTrim(SX3->X3_ARQUIVO) == "SFI"
	If SubStr(SX3->X3_CAMPO,1,6) == "FI_BIS"
		lTrataISS	:= .T.
		Exit
	EndIf
	SX3->(DbSkip())
End

RestArea(aAreaSX3)

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

cQuery := " SELECT  "
cQuery += " R_E_C_N_O_ NumReg, SFI.*"
cQuery += " FROM " + RetSqlName("SFI") + " SFI"
/*
Homologação 2017
Remoção do deletado pois para validar se houve deleção
devo trazer esse registro e sinalizar pro PDV 
que houve uma deleção manual
*/ 
//cQuery += " WHERE SFI.D_E_L_E_T_ = ' ' " 
cQuery += " where FI_FILIAL = '" + xFilial('SFI') + "'"

If !Empty(cPDV)
	cCond +=  + " AND Trim(SFI->FI_PDV)='" + cPDV + "'" 
EndIf

cQuery += " AND FI_DTREDZ >= '" + Dtos(dDataIni) + "' AND FI_DTREDZ <= '" + Dtos(dDataFim) + "'"

cQuery := ChangeQuery( cQuery )
DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlias, .F., .T.)
TcSetField(cAlias,"FI_DTREDZ","D")
TcSetField(cAlias,"FI_DTMOVTO","D")
(cAlias)->(DbGoTop())
lPesquisa := .T.

If lHomolPaf 
	SET DELETED OFF  //Habilita deletados para considerar item cancelado
	
	DbSelectArea("SFI")
	cIndex	:= CriaTrab(Nil,.F.)
	cChave	:= "FI_FILIAL+DTOS(FI_DTREDZ)"
	cCond	:= "FI_FILIAL= '"+xFilial("SFI")+"'"

	If !Empty(cPDV)
		cCond +=  + " .AND. Trim(SFI->FI_PDV)='" + cPDV + "'" 
	EndIf

	IndRegua("SFI",cIndex,cChave,,cCond,"")
	SFI->(DbSeek(xFilial("SFI")+DtoS(dDataIni), .T.)) 		
	bWhile	:= {||SFI->FI_DTREDZ <= dDataFim}

	//Valida se houve inclusão ou deleção pelo banco de Dados - Teste BLOCO VII
	//Inclusão - nao preencher o MD5
	//Deleção - deletar pelo apsdu e deixar no banco , setado como deletado
	While !(SFI->(Eof())) .AND. Eval(bWhile)
		If SFI->(Deleted()) .And. !Empty(AllTrim(SFI->FI_PAFMD5))				
			Aadd(aMd5Del,AllTrim(SFI->FI_PAFMD5))
		EndIf
		SFI->(DbSkip())
	EndDo

	SET DELETED ON  //Desabilita deletados

	SFI->(DbSeek(xFilial("SFI")+DtoS(dDataIni),.T.))

	/*SFI->(DbGoTop())
	While !SFI->(Eof())
	RecLock("SFI",.F.)
	REPLACE SFI->FI_MD5TRIB WITH STxPafMd5("SFI","","2")
	Conout("SFI MD5TRIB T")
	SFI->(MsUnlock())
	SFI->(DbSkip())
	End

	SFI->(DbSeek(xFilial("SFI")+DtoS(dDataIni),.T.))*/
EndIf

If lUsaMdz
	DbSelectArea("MDZ")
	MDZ->( DbSetOrder(1) )
EndIf

If lPesquisa

	While !(cAlias)->(Eof())

		AAdd(::RedZRet,WSClassNew("RedZList"))
		nPos++                                        

		::RedZRet[nPos]:Serie 		:= AllTrim((cAlias)->FI_SERPDV)
		::RedZRet[nPos]:ContRedZ 	:= Val((cAlias)->FI_NUMREDZ)
		::RedZRet[nPos]:ContOrdOp	:= Val((cAlias)->FI_COO)
		::RedZRet[nPos]:ContReinic	:= Val((cAlias)->FI_CRO)
		::RedZRet[nPos]:DataMovto	:= (cAlias)->FI_DTMOVTO
		
		nValISS := 0
		If lVerSIG031430
			nValISS := (cAlias)->(FI_DESISS+FI_CANISS)
		EndIf
		
		::RedZRet[nPos]:TotBrutDia	:= (cAlias)->(FI_VALCON+FI_DESC+FI_CANCEL+FI_ISS+nValISS)		
		::RedZRet[nPos]:DataRedZ	:= (cAlias)->FI_DTREDZ
		::RedZRet[nPos]:HoraRedZ	:= (cAlias)->FI_HRREDZ

		//O campo FI_CANCEL possui o valor referente ao cancelamento em ISS e ICMS
		::RedZRet[nPos]:TotCancDia	:= (cAlias)->(FI_CANCEL)

		//Valor do cancelamento para ISS
		::RedZRet[nPos]:TotCanIss	:= (cAlias)->FI_CANISS

		//Totaliza Operação não fiscal
		nTotOpNFis := 0
		If lUsaMdz
			MDZ->(DbSeek(xFilial("MDZ")+DtoS((cAlias)->FI_DTMOVTO)))

			While (!MDZ->( EOF() ) ) .AND. (MDZ->MDZ_DATA == (cAlias)->FI_DTMOVTO)
				If MDZ->MDZ_SIMBOL == "CN"  .AND. ;
				( AllTrim(MDZ->MDZ_PDV) == Alltrim(SFI->FI_PDV) ) 
					nTotOpNFis += MDZ->MDZ_VALOR	
				EndIf

				MDZ->(DbSkip())
			End    
		EndIf

		::RedZRet[nPos]:TotOpNFis	:= nTotOpNFis

		cPafMd5 := STxPafMd5(cAlias)

		//Valida chave
		::RedZRet[nPos]:PAFMD5OK	:= (cAlias)->FI_PAFMD5 == cPafMd5 .And. WsLeMD5LG(AllTrim((cAlias)->FI_SERPDV))
		::RedZRet[nPos]:IncManual	:= .F.
		
		//Seta Deleção Manual
		nCont := Ascan(aMd5Del, { |x| x == AllTrim((cAlias)->FI_PAFMD5)} )
		::RedZRet[nPos]:DelManual	:= (nCont > 0)

		//Seta inclusão manual
		If Empty(AllTrim((cAlias)->FI_PAFMD5))
			::RedZRet[nPos]:IncManual := .T.
		EndIf

		/*Carrega Aliquotas e Valores de Impostos*/
		aAux := aClone( TotalizSFI((cAlias)->NumReg, .T., .T.) )    //Localizada no SPEDXFUN     

		//Com os dados de aAux serão gerados os R03 do arquivo do Menu Fiscal, para teste do bloco VII 
		//alterar o valor de algum campo que compoe este array 		
		If Len(aAux) > 0

			//Valida se houve alteração dos valores no banco para inclusão ou exclusao de dados do R03
			cPafMD5 := STxPafMd5(cAlias,"","2")
			lAlterado := Empty(AllTrim((cAlias)->FI_MD5TRIB))

			::RedZRet[nPos]:ImpsSFI := {}
			nPosImp := 0

			For nCont := 1 To Len(aAux)

				//O registro Can-T e Can-S já é acumulado em outro registro, aparecia duas vezes no movimento por ECF
				If !( Upper(aAux[nCont][1]) $ Upper("Can-T|Can-S"))
					Aadd( ::RedZRet[nPos]:ImpsSFI , WSClassNew("ImpList"))
					nPosImp++

					::RedZRet[nPos]:ImpsSFI[nPosImp]:Codigo   := aAux[nCont][1]  //Codigo do Impostos
					::RedZRet[nPos]:ImpsSFI[nPosImp]:Valor    := aAux[nCont][2]  //Valor de Base do Imposto 

					If SubStr(aAux[nCont][1],1,1) $ "T|S"
						If lTrataISS

							::RedZRet[nPos]:ImpsSFI[nPosImp]:CodSfi   := aAux[nCont][4]  //Valor de Base do Imposto

						ElseIf !lTrataISS .AND. SubStr(aAux[nCont][1],1,1) == "S" 

							::RedZRet[nPos]:ImpsSFI[nPosImp]:CodSfi   := aAux[nCont][1]  //Valor de Base do Imposto

						Else
							::RedZRet[nPos]:ImpsSFI[nPosImp]:CodSfi   := aAux[nCont][4]  //Valor de Base do Imposto
						EndIf
					Else
						::RedZRet[nPos]:ImpsSFI[nPosImp]:CodSfi   := aAux[nCont][1]  //Valor de Base do Imposto
					EndIf

					::RedZRet[nPos]:ImpsSFI[nPosImp]:IncManual := lAlterado
					::RedZRet[nPos]:ImpsSFI[nPosImp]:PAFMD5OK  := ::RedZRet[nPos]:PAFMD5OK .And. (cPafMD5 == (cAlias)->FI_MD5TRIB)
					
					//Valido novamente o MD5 do Registro Pai para que ao alterar o MD5 do filho seja evidenciado no pai
					If ::RedZRet[nPos]:PAFMD5OK .And. !::RedZRet[nPos]:ImpsSFI[nPosImp]:PAFMD5OK 
						::RedZRet[nPos]:PAFMD5OK := .F.
					EndIf
				EndIf	
			Next nCont			
		EndIf

		(cAlias)->(DbSkip())
	End

	(cAlias)->(DbCloseArea())
EndIf

Return .T.


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LstVendas ºAutor  ³Microsiga           º Data ³  06/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Lista as vendas de um periodo para um PDV                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpD1 - Data inicial                                       º±±
±±º          ³ ExpD2 - Data final                                         º±±
±±º          ³ ExpC3 - Numero do PDV                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno	 ³ ExpA1 - Lista com dados das reducoes Z efetuadas           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FrontLoja                                                  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD LstVendas WSRECEIVE dDataIni,dDataFim,cPDV, cEmpPdv,;
	cFilPdv, lHomolPaf, cIniCup WSSEND LstVdas WSSERVICE FRTPafEcf

Local cFilSL1		:= ""
Local cFilSA1		:= ""
Local cNomCli		:= ""
Local cCGCCli		:= ""
Local cSL1			:= "SL1"
Local nPos			:= 0
Local nAcrescimo	:= 0        
Local cQuery		:= "" 
Local cPafMd5		:= ""
Local lIncManual	:= .F.
Local lDelManual	:= .F.
Local lCancelado	:= .F.
Local nSizeFile	:= 0

/* Chama RPCSETENV */
LjPreparaWs(::cEmpPdv,::cFilPdv)

cFilSL1	:= xFilial("SL1")
cFilSA1	:= xFilial("SA1")

//Para validar a deleção: excluir SL1 via apsdu e deixar como detelado no banco de dados - Teste Bloco VII
If lHomolPaf
	SET DELETED OFF

	DbSelectArea("SL1")
	SL1->(DbSetOrder(4)) //L1_FILIAL+DtoS(L1_EMISSAO)
	SL1->(DbSeek(cFilSL1+DtoS(dDataIni),.T.))

	//Valida Deleção Manual
	While !SL1->(Eof()) .AND. SL1->L1_EMISSAO <= dDataFim
		If ( (Empty(cPDV) .AND. !Empty(SL1->L1_PDV) ) .OR.  AllTrim(SL1->L1_PDV) == cPDV ) ;
		.AND. !Empty(SL1->L1_NUMCFIS) .AND.; 
		SL1->L1_FILIAL == cFilSL1 .AND. SL1->(Deleted())
			lDelManual := .T.
		EndIf
		SL1->(DbSkip())
	EndDo

	SET DELETED ON
EndIf

cSL1	:= "SL1TMP"

If Select(cSL1) > 0
	(cSL1)->(DbCloseArea())
EndIf

cQuery	:= "SELECT L1_FILIAL,L1_EMISSAO,L1_PDV,L1_DOC,L1_VLRTOT,L1_VALBRUT,"
cQuery	+= "L1_NUMCFIS,L1_EMISNF,L1_HORA,L1_DESCONT,L1_VLRLIQ,L1_CONTONF,L1_CONTRG,"   
cQuery	+= "L1_CONTCDC,L1_CONTDOC,L1_DATATEF,L1_HORATEF,L1_SERPDV,L1_STORC,L1_NUMORC,"
cQuery	+= "L1_PAFMD5,L1_COODAV,L1_SERIE,L1_NUM,L1_VALMERC,L1_ESPECIE,L1_TPORC, L1_DTLIM,"
cQuery  += "L1_CLIENTE,A1_NOME,A1_CGC , L1_CGCCLI "
cQuery	+= "FROM " + RetSqlName("SL1") + " SL1 "
cQuery	+= "INNER JOIN " + RetSqlName("SA1") + " SA1 "
cQuery	+= "ON A1_FILIAL='"+cFilSA1+"' AND A1_COD=L1_CLIENTE AND A1_LOJA=L1_LOJA AND SA1.D_E_L_E_T_ = ' ' "
cQuery	+= "WHERE SL1.D_E_L_E_T_ = ' '  "
cQuery	+= " AND SL1.L1_FILIAL ='" + cFilSL1 + "' "
If !Empty(cPDV)
	cQuery	+= " AND L1_PDV = '" + AllTrim(cPDV) + "' "
EndIf
cQuery	+= "AND L1_EMISSAO BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"' "  
cQuery	+= "AND L1_NUMCFIS <> ' ' "
If !Empty(cIniCup)
	cQuery	+= "AND L1_NUMCFIS > '" + cIniCup + "' "
EndIf

cQuery	+= " AND L1_ESPECIE <> 'NFM' " //Nota Manual Gerada pela rotina FRTA080 não aparece aqui
cQuery	+= "ORDER BY L1_EMISSAO,L1_NUMCFIS"

cQuery := ChangeQuery( cQuery )
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cSL1, .F., .T.)
TcSetField(cSL1,"L1_EMISSAO","D")
TcSetField(cSL1,"L1_EMISNF","D")
TcSetField(cSL1,"L1_DTLIM","D")
(cSL1)->(DbGoTop())

While !(cSL1)->(Eof())

	cNomCli		:= (cSL1)->A1_NOME  
	cCGCCli		:= (cSL1)->L1_CGCCLI
	nAcrescimo	:= (cSL1)->L1_VLRTOT - (cSL1)->L1_VALBRUT
	lCancelado	:= ((cSL1)->L1_STORC == "C")

	AAdd(::LstVdas,WSClassNew("VendaList"))
	nPos++

	::LstVdas[nPos]:NumDoc		:= Val((cSL1)->L1_DOC) //Não utilizado
	::LstVdas[nPos]:ContOrdOp	:= Val((cSL1)->L1_NUMCFIS)
	::LstVdas[nPos]:DataEmiss	:= (cSL1)->L1_EMISSAO
	::LstVdas[nPos]:HoraEmiss	:= (cSL1)->L1_HORA     			
	::LstVdas[nPos]:SubTotal	:= (cSL1)->L1_VALMERC //(cSL1)->L1_VALBRUT
	::LstVdas[nPos]:DescTotal	:= (cSL1)->L1_DESCONT
	::LstVdas[nPos]:AcreTotal	:= IIf(nAcrescimo > 0, nAcrescimo , 0)
	::LstVdas[nPos]:TpDescon	:= IIf((cSL1)->L1_DESCONT > 0, "V", " ")
	::LstVdas[nPos]:TpAcresc	:= IIf(nAcrescimo > 0, "V" , " ")
	::LstVdas[nPos]:TotLiquido	:= (cSL1)->L1_VLRLIQ
	::LstVdas[nPos]:Cancelado	:= lCancelado	//Indicador de Cancelamento
	::LstVdas[nPos]:ValCancTot	:= If( lCancelado , nAcrescimo , 0 ) //Indicador de cancelamento do acrescimo 
	::LstVdas[nPos]:OrdAplDesc	:= IIf(nAcrescimo > 0, "A" , IIf((cSL1)->L1_DESCONT > 0, "D", " "))
	::LstVdas[nPos]:NomeClient	:= cNomCli
	::LstVdas[nPos]:CNPJClient	:= cCGCCli
	::LstVdas[nPos]:NumContOnf	:= Val((cSL1)->L1_CONTONF) 	//16
	::LstVdas[nPos]:NumContRg	:= Val((cSL1)->L1_CONTRG ) 	//17
	::LstVdas[nPos]:NumContCdc	:= Val((cSL1)->L1_CONTCDC) 	//18
	::LstVdas[nPos]:NumContDoc	:= Val((cSL1)->L1_CONTDOC) 	//19
	::LstVdas[nPos]:DataTef   	:= (cSL1)->L1_DATATEF     	//20
	::LstVdas[nPos]:HoraTef		:= (cSL1)->L1_HORATEF	  	//21

	If !Empty(Alltrim((cSL1)->L1_SERPDV))
		::LstVdas[nPos]:SerPdv		:= (cSL1)->L1_SERPDV 		//22
	Else
		::LstVdas[nPos]:SerPdv		:= LjPesqPdv((cSL1)->L1_PDV,(cSL1)->L1_SERIE)
	EndIf	    

	/* Gera/Valida chave MD5 dos Registros */
	cPafMd5 := STxPafMd5(cSL1)		    

	/*
	If lHomolPaf
	#IFDEF TOP
	DbSelectArea("SL1")
	SL1->(DbSetOrder(1))
	SL1->(MsSeek(cFilSL1+(cSL1)->L1_NUM))				
	#ENDIF

	RecLock("SL1",.F.)
	REPLACE SL1->L1_PAFMD5 WITH cPafMd5
	SL1->(MsUnlock())
	EndIf
	*/

	::LstVdas[nPos]:PAFMD5OK	:= ( (cSL1)->L1_PAFMD5 == cPafMd5 ) .And. WsLeMD5LG(AllTrim(::LstVdas[nPos]:SerPdv))

	//************************************************************************************
	//Valida Inclusão do registro via Banco de Dados, L1_PAFMD5 em branco - Teste Bloco VII
	//************************************************************************************
	If Empty(AllTrim((cSL1)->L1_PAFMD5))
		lIncManual := .T.
	Else
		lIncManual := .F.
	EndIf

	::LstVdas[nPos]:IncManual := lIncManual

	IF lDelManual
		::LstVdas[nPos]:IncManual := .T.		
	EndIf

	nSizeFile += (cSL1)->(RecSize())

	//Limitador para não estourar carga maxima do WS:
	If nPos == 150 .Or. nSizeFile >= 500000
		::LstVdas[nPos]:ContLoop := .T.
		Conout('Método LstVendas - Quebra - Motivo :' + IIf(!(nSizeFile >= 500000),'Quantidade','Tamanho do node'))
		Exit
	ELse
		::LstVdas[nPos]:ContLoop := .F.
	EndIf

	(cSL1)->(DbSkip())
End

(cSL1)->(DbCloseArea())

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LstVndCanc ºAutor  ³Microsiga           º Data ³  06/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Lista as vendas de um periodo para um PDV                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpD1 - Data inicial                                       º±±
±±º          ³ ExpD2 - Data final                                         º±±
±±º          ³ ExpC3 - Numero do PDV                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno	 ³ ExpA1 - Lista com dados das reducoes Z efetuadas           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FrontLoja                                                  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD LstVndCanc WSRECEIVE dDataIni,dDataFim,cPDV, cEmpPdv,;
	cFilPdv, lHomolPaf, cIniCup WSSEND LstVdas WSSERVICE FRTPafEcf
Local cSL1			:= "SLX"
Local nPos			:= 0
Local nAcrescimo	:= 0        
Local cQuery		:= "" 
Local cPafMd5		:= ""
Local cNumCup		:= ""
Local lUsaSLX		:= .F.
Local lIncManual	:= .F.
Local lCancelado	:= .F.
Local lDadoCli		:= .F.
Local lLX_CONTDOC	:= .F.
Local cIndex		:= ""
Local cChave		:= ""
Local nIndex		:= 0
Local cSerPDV		:= ""
Local nSizeFile		:= 0

Local cArq	:= "SL1TMP"
Local cL4NUm:= ""

/* Chama RPCSETENV */
LjPreparaWs(::cEmpPdv,::cFilPdv)

lUsaSLX	:= AliasInDic("SLX")
DbSelectArea("SL1")
SL1->(DBSetOrder(1))
lLX_CONTDOC := SLX->(ColumnPos("LX_CONTDOC")) > 0

//Para validar a deleção: excluir SL1 via apsdu e deixar como detelado no banco de dados - Teste Bloco VII
/*If lHomolPaf
SET DELETED OFF

DbSelectArea("SL1")
SL1->(DbSetOrder(4)) //L1_FILIAL+DtoS(L1_EMISSAO)
SL1->(DbSeek(cFilSL1+DtoS(dDataIni),.T.))

While !SL1->(Eof()) .AND. SL1->L1_EMISSAO <= dDataFim
If ( (Empty(cPDV) .AND. !Empty(SL1->L1_PDV) ) .OR.  AllTrim(SL1->L1_PDV) == cPDV ) ;
.AND. !Empty(SL1->L1_NUMCFIS) .AND.; 
SL1->L1_FILIAL == cFilSL1 .AND. SL1->(Deleted())
lIncManual := .T.
EndIf
SL1->(DbSkip())
EndDo

SET DELETED ON
EndIf*/

(cSL1)->(DbCloseArea())		
cSL1	:= "SLXTMP"
cPDV	:= AllTrim(cPDV)
cIniCup	:= Alltrim(cIniCup)

If Select(cSL1) > 0
	(cSL1)->(DbCloseArea())
EndIf

cQuery	:= "SELECT * "
cQuery	+= "FROM " + RetSqlName("SLX") + " SLX "
cQuery	+= "WHERE LX_FILIAL='"+xFilial('SLX')+"' "
cQuery	+= " AND LX_TPCANC <> 'D' AND LX_TPCANC <> 'I'" //D = Devolucao/I = Item -> não devem aparecer na pesquisa
cQuery	+= " AND SLX.D_E_L_E_T_ = ' '  "
If !Empty(cPDV)
	cQuery	+= " AND LX_PDV = '" + cPDV + "' "
EndIf

If !Empty(cIniCup)
	cQuery	+= " AND LX_CUPOM > '" + cIniCup + "' "
EndIf

cQuery	+= "AND LX_DTMOVTO BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"' "
cQuery	+= "ORDER BY LX_DTMOVTO,LX_CUPOM"

cQuery := ChangeQuery( cQuery )
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cSL1, .F., .T.)
TcSetField(cSL1,"LX_DTMOVTO","D")
(cSL1)->(DbGoTop())	
cNumCup := (cSL1)->LX_CUPOM

While !(cSL1)->(Eof())

	nPos := Ascan(::LstVdas, {|a| a:NumDoc == Val(AllTrim(cNumCup))})

	If cNumCup == (cSL1)->LX_CUPOM .And. (nPos > 0)
		::LstVdas[nPos]:SubTotal	+= (cSL1)->LX_VALOR
		::LstVdas[nPos]:TotLiquido	+= (cSL1)->LX_VALOR
	Else
		nAcrescimo		:= 0
		lCancelado		:= .T.

		AAdd(::LstVdas,WSClassNew("VendaList"))
		nPos := Len(::LstVdas)

		::LstVdas[nPos]:NumDoc		:= Val((cSL1)->LX_CUPOM) //Não utilizado
		::LstVdas[nPos]:ContOrdOp	:= Val((cSL1)->LX_CUPOM)
		::LstVdas[nPos]:DataEmiss	:= (cSL1)->LX_DTMOVTO
		::LstVdas[nPos]:HoraEmiss	:= (cSL1)->LX_HORA     			
		::LstVdas[nPos]:SubTotal	:= (cSL1)->LX_VALOR
		::LstVdas[nPos]:DescTotal	:= 0				
		::LstVdas[nPos]:AcreTotal	:= nAcrescimo
		::LstVdas[nPos]:TpDescon	:= " "
		::LstVdas[nPos]:TpAcresc	:= " "
		::LstVdas[nPos]:TotLiquido	:= (cSL1)->LX_VALOR
		::LstVdas[nPos]:Cancelado	:= lCancelado	//Indicador de Cancelamento
		::LstVdas[nPos]:ValCancTot	:= If( lCancelado , nAcrescimo , 0 ) //Indicador de cancelamento do acrescimo 
		::LstVdas[nPos]:OrdAplDesc	:= " "
		::LstVdas[nPos]:NomeClient	:= SuperGetMV('MV_CLIPAD')
		::LstVdas[nPos]:CNPJClient	:= " "

		//Pesquisa SL4
		If Select(cArq) > 0
			(cArq)->(DbCloseArea())
		EndIf

		cQuery	:= " select SL4.*"
		cQuery	+= " FROM " + RetSqlName("SL4") + " SL4 "
		cQuery	+= " WHERE L4_FILIAL = '" + xFilial("SL1") + "' "
		cQuery	+= " AND L4_DOC ='" + (cSL1)->LX_CUPOM + "' "
		cQuery := ChangeQuery( cQuery )
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cArq, .F., .T.)
		(cArq)->(DbGotop())

		If !(cArq)->(Eof())				
			cL4NUm := (carq)->L4_NUM
		Else
			cL4Num := ""
		EndIf

		If !Empty(cL4Num)
			//Pesquisa SL1
			SL1->(DbSeek(xFilial("SL1")+cL4NUm))

			::LstVdas[nPos]:NumContOnf	:= Val(SL1->L1_CONTONF) 	//16
			::LstVdas[nPos]:NumContRg	:= Val(SL1->L1_CONTRG)  	//17
			::LstVdas[nPos]:NumContCdc	:= Val(SL1->L1_CONTCDC)  	//18
			::LstVdas[nPos]:DataTef   	:= SL1->L1_DATATEF     	//20
			::LstVdas[nPos]:HoraTef		:= SL1->L1_HORATEF		
		Else
			::LstVdas[nPos]:NumContOnf	:= 0 	//16
			::LstVdas[nPos]:NumContRg	:= 0 	//17
			::LstVdas[nPos]:NumContCdc	:= 0 	//18			
			::LstVdas[nPos]:DataTef   	:= ''  	//20
			::LstVdas[nPos]:HoraTef		:= ''	//21
		EndIf

		If lLX_CONTDOC
			::LstVdas[nPos]:NumContDoc		:= Val((cSL1)->LX_CONTDOC)
		Else
			::LstVdas[nPos]:NumContDoc		:= Val((cSL1)->LX_CUPOM)
		EndIf

		::LstVdas[nPos]:SerPdv 		:= LjPesqPdv(AllTrim((cSL1)->LX_PDV),AllTrim((cSL1)->LX_SERIE)) //22
		::LstVdas[nPos]:IncManual	:= .F.

		nSizeFile += (cSL1)->(RecSize())

		//Limitador para não estourar carga maxima do WS:
		If nPos == 150 .Or. nSizeFile >= 500000
			::LstVdas[nPos]:ContLoop := .T.
			Conout('Método LstVndCanc - Quebra - Motivo :' + IIf(!(nSizeFile >= 500000),'Quantidade','Tamanho do node'))
			Exit
		ELse
			::LstVdas[nPos]:ContLoop := .F.
		EndIf

		//Gera/Valida chave MD5 dos Registros
		//--Aqui não atualiza pois como são vendas canceladas, favor efetuar teste de alteração (BLOCO 7) com dados da SL1 normal
		cPafMd5 := ''//STxPafMd5(cSL1)
		::LstVdas[nPos]:PAFMD5OK	:= .T.
	EndIf

	(cSL1)->(DbSkip())
	cNumCup := (cSL1)->LX_CUPOM
EndDo

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LstItens  ºAutor  ³Microsiga           º Data ³  03/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Lista os itens das vendas por periodo para um PDV           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpD1 - Data inicial                                       º±±
±±º          ³ ExpD2 - Data final                                         º±±
±±º          ³ ExpC3 - Numero do PDV                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno	 ³ ExpA1 - Lista com dados dos itens vendidos no periodo      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FrontLoja                                                  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD LstItens WSRECEIVE dDataIni,dDataFim,cPDV, cEmpPdv,;
	cFilPdv, lHomolPaf, cIniCup  WSSEND LstIt WSSERVICE FRTPafEcf

Local cFilSL2		:= ""
Local cSL2			:= "SL2"
Local nPos			:= 0
Local nQtdDecQuant	:= 0
Local nQtdDecVUnit	:= 0
Local nTamPDV		:= 0
Local nIndex		:= 0
Local cPDVLst		:= cPDV + Space(nTamPDV - Len(cPDV)) 
Local nContDoc	:= 0   
Local cTotParc	:= "" 
Local cAux			:= ""
Local cQuery		:= ""
Local cIndex		:= ""
Local cChave		:= ""
Local cNumOrc		:= ""
Local aArea		:= {}
Local aAreaSL2	:= {}		//Guarda a area do SL2 para atualizar o MD5 em homologacao
Local lIncManual	:= .F.
Local lNewFields	:= .F.
Local nSizeFile	:= 0

Default cIniCup		:= "" 

LjPreparaWs(::cEmpPdv,::cFilPdv)

cFilSL2		:= xFilial("SL2")
cFilSL1		:= xFilial("SL1") 
nQtdDecQuant:= TamSX3("L2_QUANT")[2]
nQtdDecVUnit:= TamSX3("L2_VRUNIT")[2]
nTamPDV		:= TamSX3("L2_PDV")[1]
lNewFields	:= SL2->(ColumnPos("L2_IAT")) > 0 //Valido somente 1 campo pois um UPD cria todos os campos
/*
//Trecho inserido para em caso de necessidade incluir MD5 nos campos
If lHomolPaf
DbSelectArea("SL1")
DbSelectArea("SL2")
SL1->(DbSetOrder(1))
SL2->(DbSetOrder(1))
While !SL2->(Eof())
SL1->(DbSeek(SL2->L2_FILIAL+SL2->L2_NUM))
cNumOrc := AllTrim(SL1->L1_NUMORC)

cPafMd5 := STxPafMd5("SL2",cNumOrc)

RecLock("SL2",.F.)
REPLACE SL2->L2_PAFMD5 WITH cPafMd5
SL2->(MsUnlock())
SL2->(DbSkip())
EndDo
EndIf
*/

//Para validar a deleção: excluir SL2 via apsdu e deixar como detelado no banco de dados - Teste Bloco VII
If lHomolPaf
	SET DELETED OFF
	DbSelectArea("SL1")
	SL1->(DbSetOrder(4)) //L1_FILIAL+DtoS(L1_EMISSAO)
	SL1->(DbSeek(cFilSL1+DtoS(dDataIni),.T.))

	DbSelectArea("SL2")
	SL2->(dbsetorder(1))

	While !SL1->(Eof()) .AND. SL1->L1_FILIAL == cFilSL1 .and.  SL1->L1_EMISSAO <= dDataFim    

		SL2->(DbSeek(cFilSL2 + SL1->L1_NUM))

		While !SL2->(Eof()) .AND. SL2->(L2_FILIAL+L2_NUM) == SL1->(L1_FILIAL+L1_NUM) .AND.;
		  ( Empty(cPDVLst) .OR.  AllTrim(SL2->L2_PDV) == AllTrim(cPDVLst) )
		   
			If !Empty(SL2->L2_DOC)  .AND. SL2->(deleted())
				lIncManual := .T.	
			EndIf
			SL2->(DbSkip())
		EndDo 

		SL1->(DbSkip(1))
	EndDo
	SET DELETED ON
EndIf

cSL2	:= "SL2TMP"

If Select(cSL2) > 0
	(cSL2)->(DbCloseArea())
EndIf

cQuery	:= "SELECT L2_FILIAL,L2_EMISSAO,L2_PDV,L2_DOC,L2_DESCRI,L2_QUANT,L2_SERIE, "
cQuery	+= "L2_VENDIDO,L2_CONTDOC,L2_SERPDV,L2_SITTRIB,L2_PAFMD5,L2_VRUNIT, "
cQuery	+= "L2_UM,L2_PRCTAB,L2_VALDESC,L2_VLRITEM,L2_ITEM,L2_PRODUTO,L2_DESC,L2_NUM,L2_TES,"

If lNewFields
	cQuery	+= " L2_IAT,L2_IPPT,L2_DECVLU,L2_DECQTD,"
EndIf

cQuery	+= "L1_CONTDOC,L1_NUMORC,L1_SERPDV,L1_ESPECIE,L1_NUMCFIS "	
cQuery	+= "FROM " + RetSqlName("SL2") + " SL2 "      
cQuery	+= "INNER JOIN " + RetSqlName("SL1") + " SL1 "

/*
" AND L2_PDV=L1_PDV " - não inserir essa condição senão 
os registros de nota não aparecem, uma vez que estes não tem o 
campo _PDV preenchido
*/

cQuery	+= "ON L2_FILIAL=L1_FILIAL AND L2_DOC=L1_DOC "	
cQuery	+= "WHERE SL2.D_E_L_E_T_ = ' ' "
cQuery	+= " AND SL2.L2_FILIAL = '" + cFilSL2 + "'"

If !Empty(cPDV)
	cQuery	+= 	" AND SL2.L2_PDV = '" + cPDVLst + "' " 
EndIf

cQuery	+= "AND SL2.L2_EMISSAO BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"' "	  
cQuery	+= "AND SL2.L2_DOC <> ' ' "

If !Empty(cIniCup)
	cQuery	+= "AND SL2.L2_DOC > '"	+ cIniCup + "' "
EndIf

/*Não mostra o Registro gerado pela rotina de contigencia(FRTA080)*/
cQuery	+= " AND SL1.L1_ESPECIE <> 'NFM' "

cQuery	+= " ORDER BY L2_EMISSAO,L2_DOC,L2_ITEM"	

cQuery := ChangeQuery( cQuery )
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cSL2, .F., .T.)
TcSetField(cSL2,"L2_EMISSAO","D")	
(cSL2)->(DbGoTop())

While !(cSL2)->(Eof()) 

	cTotParc := ""
	nContDoc := Val((cSL2)->L1_CONTDOC)

	If !Empty(AllTrim((cSL2)->L2_SITTRIB))
		cTotParc	:=	AllTrim((cSL2)->L2_SITTRIB)
	EndIf

	cNumOrc := (cSL2)->L1_NUMORC

	AAdd(::LstIt,WSClassNew("ItVndList"))

	nPos++

	::LstIt[nPos]:NumDoc		:= Val((cSL2)->L2_DOC)
	If AllTrim((cSL2)->L1_ESPECIE) == "NFCF" //Quando nota+cf o numero do cupom esta no campo L1_NUMCFIS
		::LstIt[nPos]:ContOrdOp		:= Val((cSL2)->L1_NUMCFIS)
	Else
		::LstIt[nPos]:ContOrdOp		:= Val((cSL2)->L2_DOC)
	EndIf
	::LstIt[nPos]:ItemNum		:= Val((cSL2)->L2_ITEM)
	::LstIt[nPos]:CodProd		:= (cSL2)->L2_PRODUTO
	::LstIt[nPos]:Descricao		:= (cSL2)->L2_DESCRI
	::LstIt[nPos]:Quantidade	:= (cSL2)->L2_QUANT * &("1" + Replicate("0",nQtdDecQuant))
	::LstIt[nPos]:UnMedida		:= (cSL2)->L2_UM
	::LstIt[nPos]:VlrUnit		:= (cSL2)->L2_PRCTAB * &("1" + Replicate("0",nQtdDecVUnit))
	::LstIt[nPos]:DescItem		:= (cSL2)->L2_VALDESC
	::LstIt[nPos]:AcreItem		:= 0
	::LstIt[nPos]:VlrLiq		:= (cSL2)->L2_VLRITEM
	::LstIt[nPos]:TotParc		:= cTotParc
	::LstIt[nPos]:ItCancel		:= (cSL2)->L2_VENDIDO == "N"
	::LstIt[nPos]:QtdCanc		:= 0
	::LstIt[nPos]:ValCanc		:= 0
	::LstIt[nPos]:CancAcrIt		:= 0
	
	If lNewFields
		::LstIt[nPos]:IndArrTru		:= (cSL2)->L2_IAT
		::LstIt[nPos]:IPPT			:= (cSL2)->L2_IPPT
		::LstIt[nPos]:QtdDecQtd		:= (cSL2)->L2_DECQTD
		::LstIt[nPos]:QtdDecVUn		:= (cSL2)->L2_DECVLU
	Else
		::LstIt[nPos]:IndArrTru		:= "T"
		::LstIt[nPos]:IPPT			:= "T"
		::LstIt[nPos]:QtdDecQtd		:= nQtdDecQuant
		::LstIt[nPos]:QtdDecVUn		:= nQtdDecVUnit
	EndIf
	
	::LstIt[nPos]:NumContDoc	:= IIF(Val((cSL2)->L2_CONTDOC) == 0 , nContDoc, Val((cSL2)->L2_CONTDOC)) 
	::LstIt[nPos]:SerPdv		:= (cSL2)->L2_SERPDV
	::LstIt[nPos]:SitTrib		:= (cSL2)->L2_SITTRIB		

	If Empty(::LstIt[nPos]:SerPdv)
		::LstIt[nPos]:SerPdv := (cSL2)->L1_SERPDV
	EndIf

	If Empty(Alltrim(::LstIt[nPos]:SerPdv))
		::LstIt[nPos]:SerPdv		:= LjPesqPdv((cSL2)->L2_PDV,(cSL2)->L2_SERIE)
	EndIf

	//Gera Chave MD5 dos dados armazenados    
	cPafMd5 := STxPafMd5(cSL2, cNumOrc) 

	/*
	If lHomolPaf
	#IFDEF TOP
	aAreaSL2 := GetArea(cSL2)
	DbSelectArea("SL2")
	SL2->(DbSetOrder(1))
	SL2->(DbSeek(cFilSL2+(cSL2)->L2_NUM))
	#ENDIF

	RecLock("SL2",.F.)
	REPLACE SL2->L2_PAFMD5 WITH cPafMd5
	SL2->(MsUnlock())

	#IFDEF TOP
	RestArea(aAreaSL2)
	#ENDIF
	EndIf    
	*/

	//Valida chave
	::LstIt[nPos]:PAFMD5OK		:= ( (cSL2)->L2_PAFMD5 == cPafMd5 ) .And. WsLeMD5LG(::LstIt[nPos]:SerPdv)

	/*Valida Inclusão do registro via Banco de Dados, L2_PAFMD5 em branco
	Associar o L2_NUM a um SL1 valido - Teste Bloco VII */
	If Empty(AllTrim((cSL2)->L2_PAFMD5))
		lIncManual := .T.
	Else
		lIncManual := .F.
	EndIf

	::LstIt[nPos]:IncManual	:= lIncManual
	nSizeFile += (cSL2)->(RecSize())		

	(cSL2)->(DbSkip())

	If nPos > 0	
		//Limitador para não estourar carga maxima do WS:
		//Valida para que seja levado todos os itens da venda
		If (nPos >= 100 .And. ::LstIt[nPos]:NumDoc <> Val((cSL2)->L2_DOC)) .Or.;
		(nSizeFile >= 500000 .And. ::LstIt[nPos]:NumDoc <> Val((cSL2)->L2_DOC))

			::LstIt[nPos]:ContLoop := .T.
			Conout('Método LstItens - Quebra - Motivo :' + IIf(!(nSizeFile >= 500000),'Quantidade','Tamanho do node'))
			Exit
		ELse
			::LstIt[nPos]:ContLoop := .F.
		EndIf	
	EndIf
End

(cSL2)->(DbCloseArea())

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LstItCanc ºAutor  ³Microsiga           º Data ³  03/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Lista os itens das vendas por periodo para um PDV           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpD1 - Data inicial                                       º±±
±±º          ³ ExpD2 - Data final                                         º±±
±±º          ³ ExpC3 - Numero do PDV                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno	 ³ ExpA1 - Lista com dados dos itens vendidos no periodo      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FrontLoja                                                  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD LstItCanc WSRECEIVE dDataIni,dDataFim,cPDV, cEmpPdv,;
			cFilPdv, lHomolPaf, cIniCup  WSSEND LstIt WSSERVICE FRTPafEcf
Local nPos			:= 0
Local nQtdDecQuant	:= 0
Local nQtdDecVUnit	:= 0
Local nTamPDV		:= 0
Local nIndex		:= 0
Local cPDVLst		:= cPDV + Space(nTamPDV - Len(cPDV)) 
Local nContDoc		:= 0   
Local cTotParc		:= "" 
Local cAux			:= ""
Local cQuery		:= ""
Local cIndex		:= ""
Local cChave		:= ""
Local cNumOrc		:= ""
Local aArea			:= {}
Local aAreaSL2		:= {}		//Guarda a area do SL2 para atualizar o MD5 em homologacao
Local lIncManual	:= .F.
Local cSLX			:= ""
Local lUsaSLX		:= .F.
Local lLxDesc		:= .F.
Local lLX_CONTDOC	:= .F.
Local cDescri		:= ""
Local nSizeFile		:= 0

Default cIniCup		:= "" 

LjPreparaWs(::cEmpPdv,::cFilPdv)

nQtdDecQuant:= TamSX3("L2_QUANT")[2]
nQtdDecVUnit:= TamSX3("L2_VRUNIT")[2]
nTamPDV		:= TamSX3("L2_PDV")[1]
lUsaSLX		:= AliasInDic('SLX')
lLX_CONTDOC	:= SLX->(ColumnPos("LX_CONTDOC")) > 0

//Para validar a deleção: excluir SL2 via apsdu e deixar como detelado no banco de dados - Teste Bloco VII
/*If lHomolPaf
SET DELETED OFF
DbSelectArea("SL1")
SL1->(DbSetOrder(4)) //L1_FILIAL+DtoS(L1_EMISSAO)
SL1->(DbSeek(cFilSL1+DtoS(dDataIni),.T.))

DbSelectArea("SL2")	
SL2->(dbsetorder(1))


While !SL1->(Eof()) .AND. SL1->L1_FILIAL == cFilSL1 .and.  SL1->L1_EMISSAO <= dDataFim    

SL2->(DbSeek(cFilSL2 + SL1->L1_NUM))

While !SL2->(Eof()) .AND. SL2->(L2_FILIAL+L2_NUM) == SL1->(L1_FILIAL+L1_NUM) .AND.  ( Empty(cPDVLst) .OR.  AllTrim(SL2->L2_PDV) == AllTrim(cPDVLst) ) 
If !Empty(SL2->L2_DOC)  .AND. SL2->(deleted())
lIncManual := .T.	
EndIf
SL2->(DbSkip())
EndDo 

SL1->(DbSkip(1))
EndDo
SET DELETED ON
EndIf*/

//Captura registros da SLX
If lUsaSLX
	lLxDesc := SLX->(ColumnPos('LX_DESCON')) > 0
	cSLX	:= "SLXTMP"

	If Select(cSLX) > 0
		(cSLX)->(DbCloseArea())
	EndIf

	cQuery	:= " SELECT " 
	cQuery	+= "SLX.* " 
	cQuery	+= ", SB1.B1_DESC,SB1.B1_PICM,SB1.B1_ALIQISS,SB1.B1_CEST,SB1.B1_POSIPI "
	cQuery	+= " FROM " + RetSqlName("SLX") + " SLX "
	cQuery	+= " INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery	+= " ON LX_PRODUTO = B1_COD AND SLX.D_E_L_E_T_ = SB1.D_E_L_E_T_ "
	cQuery	+= " WHERE LX_FILIAL='"+xFilial('SLX')+"' AND SB1.B1_FILIAL ='" + xFilial('SB1') + "'"
	cQuery	+= " AND LX_TPCANC <> 'D' "
	cQuery	+= " AND SLX.D_E_L_E_T_ = ' '  "
	If !Empty(cPDV)
		cQuery	+= " AND LX_PDV = '" + AllTrim(cPDV) + "' "
	EndIf

	If !Empty(cIniCup)
		cQuery	+= " AND LX_CUPOM > '" + cIniCup + "' "
	EndIf

	cQuery	+= "AND LX_DTMOVTO BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"' "
	cQuery	+= "ORDER BY LX_DTMOVTO,LX_CUPOM"

	cQuery := ChangeQuery( cQuery )
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cSLX, .F., .T.)
	TcSetField(cSLX,"LX_DTMOVTO","D")
	(cSLX)->(DbGoTop())

	While !(cSLX)->(Eof())
		cTotParc := ""
		nContDoc := 0

		cDescri := "#" + AllTrim((cSLX)->B1_CEST) + "#" + AllTrim((cSLX)->B1_POSIPI) + "#" +  AllTrim((cSLX)->B1_DESC)
		
		/* 		 
		If (cSLX)->B1_PICM > 0 
			cTotParc := 'T' + StrTran(StrTran(StrZero((cSLX)->B1_PICM,5,2),","),".")
		ElseIf (cSLX)->B1_ALIQISS > 0
			cTotParc := 'S' + StrTran(StrTran(StrZero((cSLX)->B1_ALIQISS,5,2),","),".")
		Else
			cTotParc := 'T' + StrTran(StrTran(StrZero(SuperGetMV("MV_ICMPAD",,18),5,2),","),".")
		EndIf*/
		cTotParc := STBFMSitTrib(Padr(AllTrim((cSLX)->LX_PRODUTO),TamSx3("B1_COD")[1]))

		AAdd(::LstIt,WSClassNew("ItVndList"))	
		nPos++

		::LstIt[nPos]:NumDoc		:= Val((cSLX)->LX_CUPOM)
		::LstIt[nPos]:ContOrdOp		:= Val((cSLX)->LX_CUPOM)
		::LstIt[nPos]:ItemNum		:= Val((cSLX)->LX_ITEM)
		::LstIt[nPos]:CodProd		:= Alltrim((cSLX)->LX_PRODUTO)
		::LstIt[nPos]:Descricao		:= cDescri
		::LstIt[nPos]:Quantidade	:= (cSLX)->LX_QTDE * &("1" + Replicate("0",nQtdDecQuant))
		::LstIt[nPos]:UnMedida		:= SB1->B1_UM
		::LstIt[nPos]:VlrUnit		:= ((cSLX)->LX_VALOR / (cSLX)->LX_QTDE) * &("1" + Replicate("0",nQtdDecVUnit))

		If lLxDesc 				
			::LstIt[nPos]:DescItem		:= (cSLX)->LX_DESCON
		Else
			::LstIt[nPos]:DescItem		:= 0
		EndIf

		::LstIt[nPos]:AcreItem		:= 0
		::LstIt[nPos]:VlrLiq		:= (cSLX)->LX_VALOR
		::LstIt[nPos]:TotParc		:= cTotParc

		If AllTrim((cSLX)->LX_TPCANC) <> "I"
			::LstIt[nPos]:QtdCanc		:= 0
			::LstIt[nPos]:ValCanc		:= 0
			::LstIt[nPos]:ItCancel		:= .F.
		Else
			::LstIt[nPos]:QtdCanc		:= (cSLX)->LX_QTDE * &("1" + Replicate("0",nQtdDecQuant))
			::LstIt[nPos]:ValCanc		:= ((cSLX)->LX_VALOR / (cSLX)->LX_QTDE) * &("1" + Replicate("0",nQtdDecVUnit))
			::LstIt[nPos]:ItCancel		:= .T.
		EndIf
		::LstIt[nPos]:CancAcrIt		:= 0
		::LstIt[nPos]:IndArrTru		:= IIf( SuperGetMV("MV_ARREFAT",,"N") == "S", "A", "T" )
		::LstIt[nPos]:IPPT			:= "T" //Indicador de produção: Propria ou Terceiros - Fixo somente para registros da SLX
		::LstIt[nPos]:QtdDecQtd		:= nQtdDecQuant
		::LstIt[nPos]:QtdDecVUn		:= nQtdDecVUnit

		If lLX_CONTDOC
			::LstIt[nPos]:NumContDoc		:= Val((cSLX)->LX_CONTDOC)
		Else
			::LstIt[nPos]:NumContDoc		:= Val((cSLX)->LX_CUPOM)
		EndIf

		::LstIt[nPos]:SerPdv 		:= LjPesqPdv(AllTrim((cSLX)->LX_PDV),AllTrim((cSLX)->LX_SERIE))
		::LstIt[nPos]:SitTrib		:= cTotParc

		//Gera Chave MD5 dos dados armazenados    
		cPafMd5 := ''//STxPafMd5(cSL2, cNumOrc)
		
		//Valida chave
		::LstIt[nPos]:PAFMD5OK	:= .T. //( (cSL2)->L2_PAFMD5 == cPafMd5 )

		/* Valida Inclusão do registro via Banco de Dados, L2_PAFMD5 em branco
		Associar o L2_NUM a um SL1 valido - Teste Bloco VII */
		//If Empty(AllTrim((cSL2)->L2_PAFMD5))
		//	lIncManual := .T.
		//EndIf

		::LstIt[nPos]:IncManual	:= .F. //lIncManual

		nSizeFile	+= (cSLX)->(RecSize()) 

		(cSLX)->(DbSkip())

		//Limitador para não estourar carga maxima do WS:
		//Valida para que seja levado todos os itens da venda
		If (nPos >= 100 .And. ::LstIt[nPos]:NumDoc <> Val((cSLX)->LX_CUPOM)) .Or.;
		(nSizeFile >= 500000 .And. ::LstIt[nPos]:NumDoc <> Val((cSLX)->LX_CUPOM) )

			::LstIt[nPos]:ContLoop := .T.
			Conout('Método LstItensCanc - Quebra - Motivo :' + IIf(!(nSizeFile >= 500000),'Quantidade','Tamanho do node'))
			Exit
		ELse
			::LstIt[nPos]:ContLoop := .F.
		EndIf
	EndDo	
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LstPagCanc ºAutor  ³Microsiga           º Data ³  03/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Lista os pagamentos           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpD1 - Data inicial                                       º±±
±±º          ³ ExpD2 - Data final                                         º±±
±±º          ³ ExpC3 - Numero do PDV                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno	 ³ ExpA1 - Lista com dados dos itens vendidos no periodo      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FrontLoja                                                  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD LstPagCanc WSRECEIVE dDataIni,dDataFim,cPDV,;
	cEmpPdv,cFilPdv, lHomolPaf,cIniCup  WSSEND PagCanc WSSERVICE FRTPafEcf

Local nPos			:= 0
Local nQtdDecQuant	:= 0
Local nQtdDecVUnit	:= 0
Local nContDoc		:= 0   
Local cTotParc		:= "" 
Local cQuery		:= ""
Local cIndex		:= ""
Local cChave		:= ""
Local cNumOrc		:= ""
Local lIncManual	:= .F.
Local cSLX			:= ""
Local caSL4			:= ""
Local lLxDesc		:= .F.
Local nCntArr		:= 0
Local dEmisAtu		:= CTOD('')
Local aPgtos		:= {{},{}}				// Acumulador de pagamentos para a data
Local cChaveSX5 	:= ""
Local aDadosPgt 	:= {}
Local aDescTpPag	:= {}					//Array que contera as descricoes das formas de pagamento existentes no X5
Local nX        	:= 0 
Local nY			:= 0
Local cDescTpPag	:= ""
Local cTipoDoc		:= ""
Local cSerPDV		:= ""
Local cLX_cupom		:= ""

Default cIniCup		:= "" 

LjPreparaWs(::cEmpPdv,::cFilPdv)

nQtdDecQuant:= TamSX3("L2_QUANT")[2]
nQtdDecVUnit:= TamSX3("L2_VRUNIT")[2]

If !(Select("SX5") > 0)
	DbSelectArea("SX5")
	SX5->(DbSetOrder(1)) 
EndIf

cChaveSX5 := xFilial("SX5")+"24"
SX5->(DbSeek(cChaveSX5))
While !SX5->(Eof()) .AND. (SX5->X5_FILIAL+SX5->X5_TABELA == cChaveSX5)
	Aadd( aDescTpPag , {SX5->X5_CHAVE,SX5->X5_DESCRI} )
	SX5->(DbSkip())
EndDo

//Captura registros da SLX	
cSLX	:= "SLXTMP"

If Select(cSLX) > 0
	(cSLX)->(DbCloseArea())
EndIf

cQuery	:= "SELECT SLX.* "
cQuery	+= " FROM " + RetSqlName("SLX") + " SLX "
cQuery	+=  "WHERE LX_FILIAL='"+xFilial('SLX')+"' "
cQuery	+= " AND LX_TPCANC <> 'D' AND LX_TPCANC <> 'I' " //D = Devolucao/I = Item -> não devem aparecer na pesquisa
cQuery	+= " AND LX_VALOR > 0 " //Vendas que foram canceladas apos serem impressas tem valor maior que 0 
cQuery	+= " AND SLX.D_E_L_E_T_ = ' '  "
If !Empty(cPDV)
	cQuery	+= " AND LX_PDV = '" + cPDV + "' "
EndIf

If !Empty(cIniCup)
	cQuery	+= " AND LX_CUPOM > '" + cIniCup + "' "
EndIf

cQuery	+= " AND LX_DTMOVTO BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"' "
cQuery	+= " ORDER BY LX_DTMOVTO,LX_CUPOM "

cQuery := ChangeQuery( cQuery )
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cSLX, .F., .T.)
TcSetField(cSLX,"LX_DTMOVTO","D")
(cSLX)->(DbGoTop())

While !(cSLX)->(Eof())

	If dEmisAtu <> (cSLX)->LX_DTMOVTO

		If Len(aPgtos[1]) > 0
			AAdd(::PagCanc,WSClassNew("MeiPgtList"))
			nCntArr++

			::PagCanc[nCntArr]:Emissao	:= dEmisAtu
			::PagCanc[nCntArr]:Tipos		:= aClone(aPgtos[1])
			::PagCanc[nCntArr]:Totais		:= aClone(aPgtos[2])
			::PagCanc[nCntArr]:IncManual	:= lIncManual

			//Carrega Detalhes da Forma de Pagamento
			If Len(aDadosPgt) > 0
				::PagCanc[nCntArr]:DadosPag  := Array( Len(aDadosPgt), 11 )

				For nX := 1 To Len(aDadosPgt)
					::PagCanc[nCntArr]:DadosPag[nX] 			:= WSClassNew("PagList")					    				 
					::PagCanc[nCntArr]:DadosPag[nX]:TipoPag  	:= aDadosPgt[nX][1]
					::PagCanc[nCntArr]:DadosPag[nX]:Valor    	:= aDadosPgt[nX][2]
					::PagCanc[nCntArr]:DadosPag[nX]:ContOrdOp	:= aDadosPgt[nX][3]
					::PagCanc[nCntArr]:DadosPag[nX]:NumContDoc	:= aDadosPgt[nX][4]
					::PagCanc[nCntArr]:DadosPag[nX]:NumContOnf	:= aDadosPgt[nX][5]
					::PagCanc[nCntArr]:DadosPag[nX]:SerPdv		:= aDadosPgt[nX][6]
					::PagCanc[nCntArr]:DadosPag[nX]:PAFMD5OK	:= aDadosPgt[nX][7]
					::PagCanc[nCntArr]:DadosPag[nX]:Cancelado	:= aDadosPgt[nX][8]
					::PagCanc[nCntArr]:DadosPag[nX]:DescTpPag	:= aDadosPgt[nX][9]
					::PagCanc[nCntArr]:DadosPag[nX]:TipoDoc		:= aDadosPgt[nX][10]

					//A ultima posição valida a inclusão manual pelo banco , L4_PAFMD5 em branco
					::PagCanc[nCntArr]:DadosPag[nX]:IncManual	:= aDadosPgt[nX][11]
				Next nX
			EndIf
		EndIf

		dEmisAtu	:= (cSLX)->LX_DTMOVTO
		aPgtos 	:= {{},{}} 
		aDadosPgt	:= {}
	EndIf

	If cLX_cupom <> (cSLX)->LX_CUPOM
		caSL4 := "SL4TMP"

		If Select(caSL4) > 0
			(caSL4)->(DbCloseArea())
		EndIf

		//Nesse caso SL4 está deletado e para retornar as informações corretas busco nela
		cQuery	:= " select SL4.*"
		cQuery	+= " FROM " + RetSqlName("SL4") + " SL4 "
		cQuery	+= " WHERE L4_FILIAL = '" + xFilial("SL1") + "' "
		cQuery	+= " AND L4_DOC ='" + (cSLX)->LX_CUPOM + "' "

		cQuery := ChangeQuery( cQuery )
		DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),caSL4, .F., .T.)
		(caSL4)->(DbGoTop())
	
		While !(caSL4)->(Eof())
			cChave	:= (caSL4)->L4_FORMA
			nPos 	:= aScan(aPgtos[1],cChave)

			If nPos == 0
				AAdd(aPgtos[1],cChave)
				AAdd(aPgtos[2],(caSL4)->L4_VALOR)
			Else
				aPgtos[2][nPos] += (caSL4)->L4_VALOR
			EndIf

			nY := Ascan(aDescTpPag , { |x| AllTrim(x[1]) == AllTrim(cChave) })
			If nY > 0
				cDescTpPag	 := aDescTpPag[nY][2]
			Else
				cDescTpPag	 := "Dinheiro"
			EndIf

			cSerPDV		:= LjPesqPdv((cSLX)->LX_PDV , (cSLX)->LX_SERIE)

			If Val((caSL4)->L4_CONTONF) > 0
				cTipoDoc := "Documento Não Fiscal"
			Else
				cTipoDoc := "Cupom Fiscal"
			EndIf		
       		
			AAdd(aDadosPgt, {cChave, (caSL4)->L4_VALOR, Val((cSLX)->LX_CUPOM),Val((cSLX)->LX_CONTDOC),;
							Val((caSL4)->L4_CONTONF),cSerPDV ,.T.,((cSLX)->LX_TPCANC == "C"), cDescTpPag , cTipoDoc,.F. } )

			(caSL4)->(DbSkip())	
		End
		cLX_cupom := (cSLX)->LX_CUPOM 
	EndIf

	(cSLX)->(DbSkip())
End

If Len(aPgtos[1]) > 0
	AAdd(::PagCanc,WSClassNew("MeiPgtList"))
	nCntArr++

	::PagCanc[nCntArr]:Emissao	:= dEmisAtu
	::PagCanc[nCntArr]:Tipos		:= aClone(aPgtos[1])
	::PagCanc[nCntArr]:Totais		:= aClone(aPgtos[2])
	::PagCanc[nCntArr]:IncManual	:= lIncManual  

	/*Carrega Detalhes da Forma de Pagamento*/
	If Len(aDadosPgt) > 0 
		::PagCanc[nCntArr]:DadosPag  := Array( Len(aDadosPgt), 11 )

		For nX := 1 To Len(aDadosPgt)   
			::PagCanc[nCntArr]:DadosPag[nX] 			 := WSClassNew("PagList")
			::PagCanc[nCntArr]:DadosPag[nX]:TipoPag   	:= aDadosPgt[nX][1]
			::PagCanc[nCntArr]:DadosPag[nX]:Valor     	:= aDadosPgt[nX][2]
			::PagCanc[nCntArr]:DadosPag[nX]:ContOrdOp 	:= aDadosPgt[nX][3]
			::PagCanc[nCntArr]:DadosPag[nX]:NumContDoc	:= aDadosPgt[nX][4]
			::PagCanc[nCntArr]:DadosPag[nX]:NumContOnf	:= aDadosPgt[nX][5]
			::PagCanc[nCntArr]:DadosPag[nX]:SerPdv	 	:= aDadosPgt[nX][6]
			::PagCanc[nCntArr]:DadosPag[nX]:PAFMD5OK	:= aDadosPgt[nX][7]
			::PagCanc[nCntArr]:DadosPag[nX]:Cancelado	:= aDadosPgt[nX][8]
			::PagCanc[nCntArr]:DadosPag[nX]:DescTpPag	:= aDadosPgt[nX][9]
			::PagCanc[nCntArr]:DadosPag[nX]:TipoDoc	 	:= aDadosPgt[nX][10]

			//A ultima posição valida a inclusão manual pelo banco , L4_PAFMD5 em branco
			::PagCanc[nCntArr]:DadosPag[nX]:IncManual	:= aDadosPgt[nX][11]
		Next nX
	EndIf
EndIf  

(cSLX)->(DbCloseArea())

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} LjPesqPDV
usado para pesquisar o Numero do PDV
@param cNumPDV , String , Numero do PDV
@param cSerie , String, Serie do PDV 
@param cCampo, String, Campo de Pesquisa
@author  Varejo
@version 	P12
@since   	03/08/2017
@return  	cRet , String , retorno da pesquisa
/*/
//-------------------------------------------------------------------
Function LjPesqPdv( cNumPDV , cSerie , cCampo, cCpPesq)
Local cQuery	:= ''
Local cSLG		:= 'RLGTMP'
Local cRet		:= ''
Local cWhere	:= ''

Default cCampo	:= ""
Default cCpPesq:= ""

If ! Empty(cCpPesq)
	//Para buscar a partir de qualquer parametro, preenche no cNumPDV o conteudo que se deseja buscar
	cWhere := " AND " + cCpPesq + " = '" + cNumPDV + "'"

//A SLX também é gravada no LOJA720, com o NUMPDV em branco portanto altero o where
ElseIf Empty(AllTrim(cNumPDV))
	cWhere := " AND LG_SERIE ='" + cSerie + "'"
Else
	cWhere := " AND LG_PDV = '" + cNumPDV + "'"
EndIf

If Select(cSLG) > 0
	(cSLG)->(DbCloseArea())
EndIf

cQuery	:= "SELECT SLG.* "
cQuery	+= " FROM " + RetSqlName("SLG") + " SLG "
cQuery	+= " WHERE LG_FILIAL='"+xFilial('SLG')+"' "
cQuery	+= cWhere
cQuery	+= " AND SLG.D_E_L_E_T_ = ' '  "
cQuery	+= "ORDER BY LG_CODIGO"

cQuery := ChangeQuery( cQuery )
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cSLG, .F., .T.)
(cSLG)->(DbGoTop())
If !(cSLG)->(Eof())
	If Empty(AllTrim(cCampo))
		cRet := AllTrim((cSLG)->LG_SERPDV)
	Else
		cRet := AllTrim((cSLG)->&(cCampo))
	EndIf
EndIf

(cSLG)->(DbCloseArea())

Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Metodo	 ³LstDocEmit³ Autor ³ Venda Clientes        ³ Data ³30/12/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Lista de documentos emitidos dentro de um periodo 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 - Data inicial                                       ³±±
±±³          ³ ExpD2 - Data final                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpA1 - Estrutura contendo os dados dos DOCs emitidos      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SigaLoja												  	  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD LstDocEmit WSRECEIVE dDataIni,dDataFim, cEmpPdv, cFilPdv, lHomolPaf, cPDV WSSEND DocListRet WSSERVICE FRTPafEcf 
Local cFilMDZ 	:= ""		// Filial da tabela MDZ
Local cAlias	:= "MDZ"	// Alias utilizado para consulta dos dados na MDZ
Local nPos		:= 0		// Posicao atual no retorno do WebService
Local cQuery	:= ""		// Query para selecao de dados no banco de dados
Local cPafMd5	:= ""		// Chave MD5
Local cTpDocMDZ	:= "R4,NC,RP,PV,XM"
Local cTpQryMDZ := "'R4','NC','RP','PV','XM'"
Local lIncManual := .F.	//valida se foi inclusão/deleção manual

Default cPDV := "" 

LjPreparaWs(::cEmpPdv,::cFilPdv)

cFilMDZ := xFilial("MDZ")		// Filial da tabela MDZ
cPDV	:= AllTrim(cPDV)

//Para validar a deleção: excluir MDZ via apsdu e deixar como detelado no banco de dados - Teste Bloco VII
If lHomolPaf
	SET DELETED OFF

	DbSelectArea("MDZ")
	MDZ->(DbSetOrder(1)) //MDZ_FILIAL+DTOS(MDZ_DATA)
	MDZ->(DbSeek(cFilMDZ+DtoS(dDataIni),.T.))

	While !MDZ->(Eof()) .AND. MDZ->MDZ_FILIAL == cFilMDZ .AND. MDZ->MDZ_DATA <= dDataFim    
		If (Empty(cPDV) .and. !Empty(MDZ->MDZ_PDV) ) .OR. (Alltrim(MDZ->MDZ_PDV) == Alltrim(cPDV))
			If !(MDZ->MDZ_SIMBOL $ cTpDocMDZ) .AND. MDZ->(deleted())
				lIncManual := .T.
			EndIf 
		EndIf
		MDZ->(DbSkip())
	EndDo	
	SET DELETED ON

	MDZ->(DbCloseArea())
EndIf

cAlias := "MDZTMP"

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

cQuery	:= "SELECT MDZ.* " 
cQuery	+= " FROM " + RetSqlName("MDZ") + " MDZ "
cQuery	+= " WHERE D_E_L_E_T_ = ' ' AND MDZ_FILIAL = '" + cFilMDZ + "' "
cQuery	+= " AND MDZ_DATA >= '" + DtoS(dDataIni)+ "' "
cQuery	+= " AND MDZ_DATA <='" + DtoS(dDataFim) + "' "
If !Empty(cPDV)
	cQuery	+= "AND MDZ_PDV = '" + cPDV + "' "
EndIf

cQuery	+= " AND MDZ_SIMBOL NOT IN ( " + cTpQryMDZ + ")"
cQuery	+= "ORDER BY MDZ_FILIAL,MDZ_DATA"

cQuery := ChangeQuery( cQuery )

DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlias, .F., .T.)
TcSetField(cAlias,"MDZ_DATA","D")	
(cAlias)->(DbGoTop())

//Armazena os registros validos no retorno do WebService
While !(cAlias)->(Eof())
	AAdd(::DocListRet,WSClassNew("DocList"))
	nPos++

	::DocListRet[nPos]:SerPdv		:= Iif(!Empty(AllTrim((cAlias)->MDZ_SERPDV)),(cAlias)->MDZ_SERPDV , LjPesqPdv((cAlias)->MDZ_PDV,"")) 
	::DocListRet[nPos]:Simbol 		:= (cAlias)->MDZ_SIMBOL
	::DocListRet[nPos]:DataEmiss	:= (cAlias)->MDZ_DATA
	::DocListRet[nPos]:HoraEmiss	:= (cAlias)->MDZ_HORA
	::DocListRet[nPos]:COO		 	:= (cAlias)->MDZ_COO
	::DocListRet[nPos]:GNF		 	:= (cAlias)->MDZ_GNF
	::DocListRet[nPos]:GRG		 	:= (cAlias)->MDZ_GRG
	::DocListRet[nPos]:CDC		 	:= (cAlias)->MDZ_CDC

	//Gera Chave MD5 dos dados armazenados 
	cPafMd5 := STxPafMd5(cAlias)

	/*If lHomolPaf
	Dbselectarea("MDZ")
	MDZ->(DbSetOrder(1))

	RecLock("MDZ",.F.)
	REPLACE MDZ->MDZ_PAFMD5 WITH cPafMD5
	MDZ->(MsUnlock())
	EndIf*/

	//Valida chave
	::DocListRet[nPos]:PAFMD5OK	:= (cAlias)->MDZ_PAFMD5 == cPafMd5 .And. WsLeMD5LG((cAlias)->MDZ_SERPDV)

	//************************************************************************************
	//Valida Inclusão do registro via Banco de Dados, MDZ_PAFMD5 em branco - Teste Bloco VII
	//************************************************************************************
	If lIncManual .OR. Empty(AllTrim((cAlias)->MDZ_PAFMD5))
		::DocListRet[nPos]:IncManual:= .T.
	Else
		lIncManual := .F.
		::DocListRet[nPos]:IncManual:= .F.
	EndIf

	(cAlias)->(DbSkip())

End

(cAlias)->(DbCloseArea())

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Metodo	 ³LstTrcCard³ Autor ³ Venda Clientes        ³ Data ³27/02/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Lista as vendas em CC e CD com Troco efetuadas 			  ³±±
±±³			 ³	dentro do periodo			  							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 - Data inicial                                       ³±±
±±³          ³ ExpD2 - Data final                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpA1 - Estrutura contendo os dados das vendas que possuem ³±±
±±³			 ³ troco em cartão											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Sigaloja												      ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/   
WSMETHOD LstTrcCard WSRECEIVE dDataIni,dDataFim, cEmpPdv, cFilPdv, lHomolPaf WSSEND TrcCardRet WSSERVICE FRTPafEcf
Local cAlias	:= "SL1"	// Alias utilizado para consulta dos dados na SL1
Local cQuery	:= ""		// Query para selecao de dados no banco de dados
Local cCnpjAdmFi:= ""		// Cnpj da AdmFinanceira
Local nPos		:= 0		// Posicao atual no retorno do WebService
Local nQtdeSL4:= 0		// Qtde registros da SL4
Local lRet		:= .F.      // retorno da função
Local lL1_TROCO1:= .F.      // verifica se o campo troco existe na base
Local aRet		:= {}

//³Chama RPCSETENV³
LjPreparaWs(::cEmpPdv,::cFilPdv)

//Verifica o param e o campo pois o troco somente será registrado com a combinação verdadeira do campo e do MV_LJTROCO 
//e se o ambiente nao estiver configurado para tal, os valores viriam zerados e segundo o Ato Cotepe 01.13
//nao se pode haver relatorio sem mostrar o valor do troco do cartão.
lL1_TROCO1 := ((cAlias)->(ColumnPos("L1_TROCO1")) > 0) .AND. SuperGetMV("MV_LJTROCO",,.F.)

If !lL1_TROCO1
	AAdd(::TrcCardRet,WSClassNew("TrcCrdList"))
	::TrcCardRet[1]:UsaTroco := .F.
	lRet := .T.  					//Retorna com .T. para impedir no PDV que mostre como um erro
Else
	cAlias := "SL1TMP"

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf

	cQuery	:= " Select SL1.* "	
	cQuery	+= " From " + RetSqlName("SL1") + " SL1 "
	cQuery	+= " Where "           
	cQuery  += " D_E_L_E_T_ = ' ' AND L1_FILIAL = '" + cFilPdv + "' "
	cQuery  += " AND L1_EMISNF BETWEEN '" + DToS(dDataIni) + "' AND '" + DToS(dDataFim) + "' "
	cQuery  += " ORDER BY L1_NUM "
	cQuery  := ChangeQuery( cQuery )
	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlias, .F., .T.)
	(cAlias)->(DbGoTop())

	DbSelectArea("SL4")
	DbSelectArea("SAE")
	DbSelectArea("SA1")
	lRet := .T.

	// Armazena os registros validos no retorno do WebService
	//Segundo Ato Cotepe 01.13 o Troco em Cartão deve ser somente para SC ( tratado no LOJA701C ) 
	//e para troco de no máximo R$ 10, 00 - Requisito XIV
	If (cAlias)->L1_TROCO1 > 0 .AND. (cAlias)->L1_TROCO1 <= 10

		While !(cAlias)->(Eof()) .AND. ;
		( !(cAlias)->L1_TIPO == '' .OR. ((cAlias)->L1_TIPO == 'P' .AND. !(cAlias)->L1_DOCPED == '') .OR. ;
		((cAlias)->L1_TIPO == 'V' .AND. !(cAlias)->L1_DOC == ''))

			aRet 	:= {}
			nQtdeSL4:= 0
			If ((cAlias)->L1_CARTAO > 0 .OR. (cAlias)->L1_VLRDEBI > 0) .AND.;
				(cAlias)->L1_TROCO1 > 0 .AND. !Empty(AllTrim((cAlias)->L1_CGCCLI))//so permite gerar documento qdo CPF do cliente preenchido - Ato Cotepe 01.12 Anexo XV Item 7.2.1.1

				SL4->(DbSetOrder(1))
				SL4->(DbSeek( (cAlias)->L1_FILIAL + (cAlias)->L1_NUM ))
				While !SL4->(Eof()) .AND. (SL4->L4_NUM == (cAlias)->L1_NUM) .AND.;
				(SL4->L4_FILIAL == (cAlias)->L1_FILIAL) .AND. Empty(SL4->L4_ORIGEM)

					If RTrim( SL4->L4_FORMA ) == "CC" .OR. RTrim( SL4->L4_FORMA ) == "CD"
						SAE->( DbSetOrder( 1 ) )
						If SAE->(DbSeek( xFilial( "SAE" ) + Left( SL4->L4_ADMINIS, 3 ) ) )
							SA1->(DbSetOrder(1))
							If SA1->(DbSeek(xFilial("SA1")+ PadR(Left( SL4->L4_ADMINIS, 3 ),TamSx3("A1_COD")[2]) ))
								cCnpjAdmFi := AllTrim(SA1->A1_CGC)
							EndIf
						EndIf
						Aadd( aRet , SL4->L4_NUM )
					Else
						aRet := {}
					EndIf

					nQtdeSL4++
					SL4->(DbSkip())
				End

				//Segundo o Ato Cotepe só deve ser gerado Troco em Cartão qdo a única forma de pagto for CC ou CD
				If Len(aRet) > 0 .AND. nQtdeSL4 == Len(aRet)
					AAdd(::TrcCardRet,WSClassNew("TrcCrdList"))

					nPos++
					::TrcCardRet[nPos]:UsaTroco := .T.
					::TrcCardRet[nPos]:CnpjAdm	:= cCnpjAdmFi
					::TrcCardRet[nPos]:COO		:= (cAlias)->L1_NUMCFIS // COO do cupom onde foi registrado o troco
					::TrcCardRet[nPos]:CCF		:= IIF(Empty((cAlias)->L1_CONTDOC), (cAlias)->L1_NUMCFIS, (cAlias)->L1_CONTDOC) //  CCF do cupom onde foi registrado o troco
					::TrcCardRet[nPos]:Troco	:= (cAlias)->L1_TROCO1  // Valor do Troco
					::TrcCardRet[nPos]:DtEmissao:= Stod((cAlias)->L1_EMISNF)	// Data da emissão do cupom fiscal
					If (cAlias)->(FieldPos("L1_CGCCLI")) > 0
						::TrcCardRet[nPos]:CpfCli	:= (cAlias)->L1_CGCCLI	// Cpf do adquirente do titulo 
					Else
						::TrcCardRet[nPos]:CpfCli	:= " "
					EndIf	
					::TrcCardRet[nPos]:Titulo	:= (cAlias)->L1_NUM		// numero do titulo adquirido
					::TrcCardRet[nPos]:PAFMD5OK	:= ( (cAlias)->L1_PAFMD5 == cPafMd5 )

					::TrcCardRet[nPos]:CnpjEnti	:= "" // preencher
				EndIf			
			EndIf

			(cAlias)->(DbSkip())
		End
	EndIf

	(cAlias)->(DbCloseArea())

EndIf	

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Metodo	 ³LstProduto³ Autor ³ Venda Clientes        ³ Data ³14/05/2013	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Lista pontos de venda cadastrados na retaguarda             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpA1 - Lista com o numero dos PDVs disponiveis           	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  		³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD LstProduto WSRECEIVE cEmpPdv, cFilPdv, lHomolPaf, nPagina, cCodProd WSSEND ProdListRet WSSERVICE FRTPafEcf
Local cQuery		:= ""		// Query para selecao de dados no banco de dados
Local cAlias		:= "SB1"	// Alias utilizado para consulta dos dados na SB1                  
Local cPafMd5		:= ""		// Chave MD5
Local cCodBusca	:= ""	   	// Codigo de Busca
Local cCodBar		:= ""		// codigo de barra
Local nPos			:= 0		// Posicao atual no retorno do WebService
Local nTotalB0	:= 0
Local nTotalB1	:= 0
Local nPreco		:= 0
Local lIncManual	:= .F.
Local lFindSLK  	:=	ExistFunc("Lj701DSLK")    	//verifica se procura por código de barras
Local lFieldMD5	:=	.T.
Local lB1_QATUPAF:=	.F.
Local lSTxPafMd5	:=	.T.
Local aAreaSB1	:=	{}
Local nConta		:=	1

Default nPagina  := 0   //Numero de registros paginados
Default cCodProd	:= "" //Ultimo produto processado

//³Chama RPCSETENV³
LjPreparaWs(::cEmpPdv,::cFilPdv)

//Valida inclusão ou exclusão pelo Banco de Dados - TESTE BLOCO VII
If lHomolPaf

	If Select("SB0TMP") > 0
		SB0TMP->(DbCloseArea())
		SB1TMP->(DbCloseArea())
	EndIf	

	cQuery := "select COUNT(B0_COD) TotalB0 from " +RetSqlName("SB0") + " where D_E_L_E_T_ = ' '  and B0_FILIAL = '" + xFilial("SB0") + "'"	
	cQuery	:= ChangeQuery(cQuery)
	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"SB0TMP", .F., .T.)
	nTotalB0 := SB0TMP->TotalB0

	cQuery := "select COUNT(B1_COD) TotalB1 from "+RetSqlName("SB1") +" where D_E_L_E_T_ = ' ' and B1_FILIAL = '" + xFilial("SB1") + "'" + " AND B1_MSBLQL <> '1' "	
	cQuery	:= ChangeQuery(cQuery)
	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"SB1TMP", .F., .T.)
	nTotalB1 := SB1TMP->TotalB1

	SB0TMP->(DbCloseArea())
	SB1TMP->(DbCloseArea())


	If !(nTotalB0 == nTotalB1)
		lIncManual := .T.
	EndIf
EndIf

DbSelectArea("SB1")
lFieldMD5	:= .T.
lB1_QATUPAF	:= IIf( SB1->(ColumnPos("B1_QATUPAF")) > 0 ,.T., .F.)

SB1->(DbCloseArea())

cAlias	:= "SB1TMP"
If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

cQuery := "Select  "
cQuery += " B1_FILIAL, B1_COD , B1_DESC, B1_SITTRIB, B1_ALIQISS, B1_PICM, "
cQuery += " B1_UM, B1_IAT, B1_IPPT , B1_PAFMD5, B1_CODBAR, B1_PRV1 "

If lB1_QATUPAF
	cQuery += " , B1_QATUPAF " 
EndIf

cQuery += " From " + RetSqlName("SB1") + "  SB1 "  
cQuery += " Where SB1.D_E_L_E_T_= ' ' AND B1_FILIAL = '" + xFilial('SB1') + "'" + " AND B1_MSBLQL <> '1' "	
If !Empty(AllTrim(cCodProd))
	cQuery += " AND B1_COD > '" + cCodProd + "'"
EndIf
cQuery += " Order By B1_COD "

cQuery	:= ChangeQuery(cQuery)
DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlias, .F., .T.)
(cAlias)->(DbGoTop())

While !(cAlias)->(Eof()) .AND. ( nPagina == 0 .OR. nPagina >= nConta )
 	
	AAdd(::ProdListRet,WSClassNew("ProdList"))
	nPos++

	::ProdListRet[nPos]:CNPJ := AllTrim(SM0->M0_CGC)

	If lFindSLK
		cCodBusca	:=	(cAlias)->B1_COD
		cCodBar	:=	(cAlias)->B1_CODBAR
		::ProdListRet[nPos]:CodBar := Lj701DSLK(cCodBusca,cCodBar,"S")
	Else
		::ProdListRet[nPos]:CodBar := ""	
	EndIf

	::ProdListRet[nPos]:Codigo	:=	(cAlias)->B1_COD

	nPreco := LjGetB0Prv( (cAlias)->B1_COD )
	if nPreco == 0 //Busca somente da B1_PRV1 caso em branco mas deve deixar a B0 como prioridade devido a chave do MD5
		nPreco := (cAlias)->B1_PRV1
	EndIf

	::ProdListRet[nPos]:Preco		:=	nPreco

	//Para validar a Sit Trib nos testes do bloco VII alterar a TES do produto ( de Icms para Iss, ou para NTrib)
	aAreaSB1 := (cAlias)->(GetArea())
	::ProdListRet[nPos]:SitTrib		:=	STBFMSitTrib( (cAlias)->B1_COD ,"P", "SB1" )
	RestArea(aAreaSB1)

	::ProdListRet[nPos]:Descricao	:=	(cAlias)->B1_DESC
	::ProdListRet[nPos]:PIcm		:=	(cAlias)->B1_PICM
	::ProdListRet[nPos]:AliqISS		:=	(cAlias)->B1_ALIQISS
	::ProdListRet[nPos]:UM			:=	(cAlias)->B1_UM
	::ProdListRet[nPos]:IAT			:=	(cAlias)->B1_IAT
	::ProdListRet[nPos]:IPPT		:=	(cAlias)->B1_IPPT

	If lFieldMD5 .AND. lSTxPafMd5
		cPafMd5 := STxPafMd5(cAlias)

		If (cAlias)->B1_PAFMD5 == cPafMd5
			::ProdListRet[nPos]:PAFMD5OK := .T.
		Else
			::ProdListRet[nPos]:PAFMD5OK := .F.	
		EndIf
	Else
		::ProdListRet[nPos]:PAFMD5OK := .T.	
	EndIf

	If Empty((cAlias)->B1_PAFMD5)
		lIncManual := .T.
	Else
		lIncManual := .F.
	EndIf

	::ProdListRet[nPos]:IncManual	:=	lIncManual
	::ProdListRet[nPos]:FimLista := .F.

	(cAlias)->(DbSkip())
	nConta++
EndDo

If nPagina > 0 .And. nPos > 0
	::ProdListRet[nPos]:FimLista := (cAlias)->(Eof())
EndIf

(cAlias)->(DbCloseArea())

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Metodo	 ³LstEstoque³ Autor ³ Venda Clientes        ³ Data ³13/05/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Lista pontos de venda cadastrados na retaguarda             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpA1 - Lista com o numero dos PDVs disponiveis           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD LstEstoque WSRECEIVE cEmpPdv, cFilPdv ,aProdutos ,lHomolPaf ,;
	lUpdateEtq, nPagina, cCodProd WSSEND EstListRet WSSERVICE FRTPafEcf

Local cQuery		:= ""		// Query para selecao de dados no banco de dados
Local cQryProd	:= ""		//Trecho da query contendo os produtos vindo de aProdutos
Local cAlias		:= "SB1"	// Alias utilizado para consulta dos dados na SL1
Local cPafMd5		:= ""		// Chave MD5
Local cMD5SB1		:= ""		// Chave MD5 da SB1 para atualização
Local cCodBar		:= ""		//Código de barras
Local nTotalB0 	:= 0		//contador de registros da SB0
Local nTotalB1	:= 0		//contador de registros da SB1
Local nPos			:= 0		// Posicao atual no retorno do WebService
Local nX			:= 0		// variavel de contador
Local lProdutos	:= .F.
Local lIncManual	:= .F.		// Sinaliza se algum item foi inserido manualmente, dispensando a consulta no final para item excluidos
Local lDelManual	:= .F.
Local lB1_QATUPAF	:= .F.		// valida se o campo B1_QATUPAF existe
Local lFindSLK 	:=	ExistFunc("Lj701DSLK")  	// Se existe funcao para buscar informacoes do slk
Local lFindSB2	:= .F.		// Valida se achou o produto na SB2
Local nConta		:= 1

Default aProdutos:aCodProduto := {}
Default lUpdateEtq 			:= .T.	// Verifica se atualiza Estoque do produto na B1_QATUPAF 
Default nPagina	:= 0
Default cCodProd  := ""

//³Chama RPCSETENV³
LjPreparaWs(::cEmpPdv,::cFilPdv)

lProdutos := Len(aProdutos:aCodProduto) > 0 //Verifica se foi selecionado algum produto especifico

//Permite a validação de adicionado/excluídos no banco somente se for em homologação e qdo selecionado todos os registros.
//Valida inclusão ou exclusão pelo Banco de Dados - TESTE BLOCO VII
If lHomolPaf
	If Select("SB0TMP") > 0
		SB0TMP->(DbCloseArea())
		SB1TMP->(DbCloseArea())
	EndIf

	cQuery := "select COUNT(B0_COD) TotalB0 from "+RetSqlName("SB0") +" where D_E_L_E_T_ = ' ' and B0_FILIAL = '" + xFilial("SB0") + "'"		
	cQuery	:= ChangeQuery(cQuery)
	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"SB0TMP", .F., .T.)
	nTotalB0 := SB0TMP->TotalB0

	cQuery := "select COUNT(B1_COD) TotalB1 from "+RetSqlName("SB1") +" where D_E_L_E_T_ = ' ' and B1_FILIAL = '" + xFilial("SB1") + "'" + " AND B1_MSBLQL <> '1' "			
	cQuery	:= ChangeQuery(cQuery)
	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"SB1TMP", .F., .T.)
	nTotalB1 := SB1TMP->TotalB1

	SB0TMP->(DbCloseArea())
	SB1TMP->(DbCloseArea())		

	If nTotalB0 <> nTotalB1
		lDelManual := .T.
	EndIf
EndIf

//Atualiza campo, caso exista pois ele possui a qtde em estoque da SB2 ( B2_QATU ) e tornar mais facil a validação do MD-5
DbSelectArea("SB1")
lB1_QATUPAF := SB1->(ColumnPos("B1_QATUPAF")) > 0

cAlias	:= "SB1TMP"

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

cQuery	:= " SELECT "
cQuery	+= " B1_COD, B1_DESC, B1_SITTRIB, B1_PICM, B1_ALIQISS, B1_PICM, "
cQuery	+= " B1_PRV1, B1_PAFMD5, B1_UM, B1_IAT, B1_IPPT,B1_CODBAR, "
cQuery	+= " B2_COD, Max(B2_USAI) B2_USAI , Sum(B2_QATU) B2_QATU "

If lB1_QATUPAF
	cQuery	+= ", B1_QATUPAF "
EndIf

cQuery	+= " FROM " + RetSqlName("SB1") + " SB1 "
cQuery	+= " LEFT JOIN " + RetSqlName("SB2") + " SB2 "
cQuery	+= " ON B1_COD = B2_COD "
cQuery	+= " WHERE SB1.D_E_L_E_T_ =	' '  AND SB1.B1_MSBLQL <> '1' "	
cQuery	+= " And B1_FILIAL = '" + xFilial('SB1') + "'"
cQuery	+= " And B2_FILIAL = '" + xFilial('SB2') + "'"

If lProdutos		
	cQryProd := " AND B1_COD IN ( "

	For nX := 1 to Len(aProdutos:aCodProduto)
		cQryProd += "'" + aProdutos:aCodProduto[nX]:xProduto + "'," 
	Next nX
	cQryProd := Substr( cQryProd , 1 , Len(cQryProd)-1 ) //remove a ultima virgula
	cQryProd += " ) "

	cQuery += cQryProd
EndIf

If nPagina > 0
	cQuery  +=" AND B1_COD > '" + cCodProd + "'"
EndIf

cQuery += " GROUP BY B1_COD, B1_DESC, B1_SITTRIB, B1_PICM,B1_CODBAR, "
cQuery += " B1_PRV1, B1_PAFMD5, B1_UM, B1_IAT, B1_IPPT, B1_ALIQISS,B1_PICM, B2_COD "

If lB1_QATUPAF
	cQuery	+= " , B1_QATUPAF "
EndIf

cQuery += " ORDER BY B1_COD "
cQuery := ChangeQuery( cQuery )

DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlias, .F., .T.)
TcSetField(cAlias,"B2_USAI","D")
(cAlias)->(DbGoTop())

//Atualiza o campo valor do estoque na B1 de acordo com a B2 e atualiza o MD5
If lB1_QATUPAF 
	lUpdateEtq := !LjxDGerMdz("PV")
	If lUpdateEtq
		LjPafUPEst(cAlias)
		(cAlias)->(DbGoTop()) //a função acima desposiciona o cAlias
		LjxDDelMdz("PV",dDataBase)	
	EndIf
EndIf

nPos := 0
While !(cAlias)->(Eof()) .and. ( nPagina = 0 .or. nPagina >= nConta )

	AAdd(::EstListRet,WSClassNew("EstList"))	
	nPos++	

	::EstListRet[nPos]:CNPJ		:= AllTrim(SM0->M0_CGC)	
	::EstListRet[nPos]:Codigo	:= (cAlias)->B1_COD
	cCodBar := ""

	If lFindSLK
		cCodBar := Lj701DSLK((cAlias)->B1_COD , (cAlias)->B1_CODBAR ,"S")
	EndIf

	::EstListRet[nPos]:CodBar		:= cCodBar		
	::EstListRet[nPos]:Descricao	:= (cAlias)->B1_DESC

	//Colocada validação pois no PDV valida se esse campo está <> 0, senão não gera e dá problema no arquivo do PAF
	If lUpdateEtq .And. lB1_QATUPAF .And. (cAlias)->B1_QATUPAF == 0 
		::EstListRet[nPos]:QtdeAtu		:= (cAlias)->B2_QATU
	ElseIf lUpdateEtq .OR. !lB1_QATUPAF
		::EstListRet[nPos]:QtdeAtu		:= (cAlias)->B2_QATU
	Else 
		::EstListRet[nPos]:QtdeAtu		:= (cAlias)->B1_QATUPAF
	EndIf
	::EstListRet[nPos]:UltSaida		:= (cAlias)->B2_USAI
	::EstListRet[nPos]:UM			:= (cAlias)->B1_UM

	//compara com cMD5SB1 pois a alteração do MD5 foi efetuada e o campo da pesquisa SQL será diferente contera um valor diferente
	If !lHomolPaf
		::EstListRet[nPos]:PAFMD5OK		:= .T.
	Else
		cPafMd5 := STxPafMd5(cAlias)
		::EstListRet[nPos]:PAFMD5OK		:= (cPafMd5 == (cAlias)->B1_PAFMD5)
	EndIf

	//Valida Inclusão Manual
	If Empty((cAlias)->B1_PAFMD5) 
		lIncManual := .T.
	EndIf

	::EstListRet[nPos]:IncManual	:= lIncManual

	IF lDelManual
		::EstListRet[nPos]:IncManual := .T.
		lDelManual := .F.
	EndIf

	(cAlias)->(dbSkip())
	cMD5SB1	:= ""
	cPafMd5	:= ""
	nConta++
	::EstListRet[nPos]:FimLista	:= .F.
EndDo

If nPagina > 0 .AND. nPos > 0 .And. (cAlias)->(Eof())
	::EstListRet[nPos]:FimLista	:= .T.
EndIf

IIf( Select("SB0TMP") > 0 , SB0TMP->(DbCloseArea()) , .F. )
IIf( Select("SB1TMP") > 0 , SB1TMP->(DbCloseArea()) , .F. )

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Metodo	 ³LstInfoPDV³ Autor ³ Venda Clientes        ³ Data ³30/12/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Lista de documentos emitidos dentro de um periodo 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 - Data inicial                                       ³±±
±±³          ³ ExpD2 - Data final                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpA1 - Estrutura contendo os dados dos DOCs emitidos      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SigaLoja												  	  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD LstInfoPDV WSRECEIVE cEmpPdv, cFilPdv, cPDV  WSSEND LstInfoPDVRet WSSERVICE FRTPafEcf
Local cFilMDZ 		:= ""		// Filial da tabela MDZ
Local cAlias		:= ""	// Alias utilizado para consulta dos dados na SLG
Local nPos			:= 0		// Posicao atual no retorno do WebService
Local cQuery		:= ""		// Query para selecao de dados no banco de dados
Local cPafMd5		:= ""		// Chave MD5
Local lIncManual	:= .F.		// Valida se foi inclusão/deleção manual
Local lPosECFINFO	:= .T.		// Existe LG_ECFINFO ?
Local lPosALQINFO	:= .T.

LjPreparaWs(::cEmpPdv,::cFilPdv)

DbSelectArea("SLG")
lPosECFINFO :=  SLG->(ColumnPos("LG_ECFINFO")) > 0
lPosALQINFO :=  SLG->(ColumnPos("LG_ALQINFO")) > 0

cAlias := "SLGTMP"

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

cQuery := "SELECT "
cQuery += " LG_FILIAL, LG_CODIGO, LG_PDV, LG_SERIE,"
cQuery += " LG_IMPFISC, LG_SERPDV, LG_PAFMD5 "

If lPosALQINFO
	cQuery += ", LG_ALQINFO "
EndIf

If lPosECFINFO
	cQuery += ",LG_ECFINFO "
Endif

cQuery += " FROM "+RetSqlName("SLG")
cQuery += " WHERE LG_FILIAL = '" + xFilial("SLG") + "'"
cQuery += " AND LG_PDV <> '"+ cPDV +" ' AND D_E_L_E_T_ = ' '"

cQuery := ChangeQuery( cQuery )

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlias, .F., .T.)
(cAlias)->(DbGoTop())

::LstPDV := {}

While !(cAlias)->(Eof())

	AAdd(::LstInfoPDVRet,WSClassNew("LstInfoPDV"))	
	nPos++
	::LstInfoPDVRet[nPos]:Codigo	:= (cAlias)->LG_CODIGO
	::LstInfoPDVRet[nPos]:PDV		:= (cAlias)->LG_PDV
	::LstInfoPDVRet[nPos]:Serie		:= (cAlias)->LG_SERIE
	::LstInfoPDVRet[nPos]:ImpFisc	:= (cAlias)->LG_IMPFISC
	::LstInfoPDVRet[nPos]:SerPDV	:= (cAlias)->LG_SERPDV
	If lPosECFINFO
		::LstInfoPDVRet[nPos]:ECfInfo := (cAlias)->LG_ECFINFO
	Else
		::LstInfoPDVRet[nPos]:ECfInfo := ""
	EndIf

	If lPosALQINFO
		::LstInfoPDVRet[nPos]:AlqInfo	:= (cAlias)->LG_ALQINFO
	Else
		::LstInfoPDVRet[nPos]:AlqInfo	:= ""
	EndIf

	cPafMd5 := STxPafMd5(cAlias)
	::LstInfoPDVRet[nPos]:PAFMD5OK  := cPafMd5 == (cAlias)->LG_PAFMD5

	(cAlias)->(DbSkip())
End

(cAlias)->(DbCloseArea())

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LstVendEst ºAutor  ³Microsiga           º Data ³  06/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a primeira venda					                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpD1 - Data inicial                                       º±±
±±º          ³ ExpD2 - Data final                                         º±±
±±º          ³ ExpC3 - Numero do PDV                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FrontLoja                                                  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD LstVendEst WSRECEIVE dDataIni,dDataFim, cEmpPdv,cFilPdv,;
	lHomolPaf WSSEND LsVdESt WSSERVICE FRTPafEcf
Local cQuery	:= ""
Local cFilSL1	:= ""
Local cSL1		:= "SL1TMP"
Local cSB2		:= "SB2TMP"
Local cPafMd5	:= ""
Local dDtEst	:= CTOD("")   

LjPreparaWs(::cEmpPdv,::cFilPdv)

If Select(cSL1) > 0
	(cSL1)->(DbCloseArea())
EndIf

If Select(cSB2) > 0
	(cSB2)->(DbCloseArea())
EndIf

//Pesquisa ultima atualização de estoque e considera a venda dessa data como a mais recente
cQuery	:= " SELECT B2_USAI "
cQuery	+= " FROM " + RetSqlName("SB2")
cQuery	+= " WHERE "
cQuery	+= " B2_FILIAL = '" + xFilial("SB2") + "'" 
cQuery	+= " AND D_E_L_E_T_ = ' ' "
cQuery	+= " ORDER BY B2_USAI DESC"
cQuery	:= ChangeQuery( cQuery )
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cSB2, .F., .T.)
TcSetField(cSB2,"B2_USAI","D")
(cSB2)->(DbGoTop())

If !(cSB2)->(Eof())
	dDtEst := (cSB2)->B2_USAI
	If DtoS(dDtEst) <> DtoS(CTOD(""))
		//Pesquisa a venda
		cQuery	:= "SELECT L1_FILIAL,L1_EMISSAO,L1_PDV,L1_DOC,L1_VLRTOT,L1_VALBRUT,"
		cQuery	+= "L1_NUMCFIS,L1_EMISNF,L1_HORA,L1_DESCONT,L1_VLRLIQ,L1_CONTONF,L1_CONTRG,"   
		cQuery	+= "L1_CONTCDC,L1_CONTDOC,L1_DATATEF,L1_HORATEF,L1_SERPDV,L1_STORC,L1_NUMORC,"
		cQuery	+= "L1_PAFMD5,L1_COODAV,L1_SERIE,L1_NUM,L1_CLIENTE ,L1_CGCCLI,L1_VALMERC,L1_ESPECIE, "
		cQuery	+= "L1_TPORC,L1_PDV,L1_DTLIM "
		cQuery	+= " FROM " + RetSqlName("SL1") + " SL1 "
		cQuery	+= " WHERE "
		cQuery	+= " SL1.L1_FILIAL = '" + xFilial("SL1") + "' AND "
		cQuery	+= " SL1.D_E_L_E_T_ = ' '  AND "
		cQuery	+= " SL1.L1_NUMCFIS <> ' ' AND "	
		cQuery	+= " SL1.L1_EMISSAO = '" + Dtos(dDtEst) + "'"
		cQuery	+= " ORDER BY L1_EMISSAO,L1_HORA"
		cQuery := ChangeQuery( cQuery )
		
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cSL1, .F., .T.)
		TcSetField(cSL1,"L1_EMISSAO","D")	
		TcSetField(cSL1,"L1_EMISNF","D")
		TcSetField(cSL1,"L1_DTLIM","D")
		(cSL1)->(DbGoTop())
		
		If !(cSL1)->(Eof())
			AAdd(::LsVdESt,WSClassNew("LstEstInfo"))
		
			/* Gera/Valida chave MD5 dos Registros */
			cPafMd5 := STxPafMd5(cSL1)
		
			::LsVdESt[1]:SerPDV 		:=	IF(!Empty(AllTrim((cSL1)->L1_SERPDV)),(cSL1)->L1_SERPDV,LjPesqPdv((cSL1)->L1_PDV,(cSL1)->L1_SERIE))
			::LsVdESt[1]:PDV			:=	(cSL1)->L1_PDV
			::LsVdESt[1]:Emissao		:=	(cSL1)->L1_EMISSAO
			::LsVdESt[1]:Hora			:=	(cSL1)->L1_HORA
			
			//Valida Inclusão/Alteração do registro via Banco de Dados, L1_PAFMD5 em branco - Teste Bloco VII 
			::LsVdESt[1]:PAFMD5OK		:=	((cSL1)->L1_PAFMD5 == cPafMd5 )
			::LsVdESt[1]:IncManual		:=	Empty(AllTrim((cSL1)->L1_PAFMD5))
		
			(cSL1)->(DbSkip())
		EndIf
	EndIf
	
	(cSL1)->(DbCloseArea())
EndIf

(cSB2)->(DbCloseArea())

Return .T.

//--------------------------------------------------------
/*{Protheus.doc}LstVndCpf
Lista das vendas identificadas por Cpf/Cnpj
@author  	Varejo
@version 	P11.8
@since   	06/07/2015
@return  	lRet  - função executada com sucesso 
@obs     
@sample
*/
//--------------------------------------------------------
WSMETHOD LstVndCpf WSRECEIVE dDataIni,dDataFim,cEmpPdv,cFilPdv,CpfCpnj,lHomolPaf WSSEND VndsIdentRet WSSERVICE FRTPafEcf
Local lRet		:= .T.
Local nPos		:= 0
Local nLstPos	:= 0
Local cCpfCnpj	:= ""
Local cSL1		:= 'SL1TMP'
Local dFstData:= Ctod('')
Local dLstData:= Ctod('')

//³Chama RPCSETENV³
LjPreparaWs(::cEmpPdv,::cFilPdv)

/*
WSSTRUCT VndsIdent
Wsdata CpfCnpj	as String
Wsdata TotalVnd	as Float
Wsdata DtFirstS	as Date
Wsdata DtLastS	as Date
Wsdata PafMd5OK	as Boolean 
ENDWSSTRUCT
*/

If Select(cSL1) > 0
	(cSL1)->(DbCloseArea())
EndIf

cQuery	:= " select Sum(L1_VLRTOT) VlrTotal,L1_FILIAL,L1_EMISSAO,L1_CGCCLI,D_E_L_E_T_ "
cQuery	+= " FROM " + RetSqlName("SL1") + " SL1 "

If Empty(AllTrim(CpfCpnj)) //Pesquisa por Cpf/cnpj, pode ser todos ou especifico
	cQuery	+= " where L1_CGCCLI <> ' ' "
Else
	cQuery	+= " where L1_CGCCLI = '" + CpfCpnj + "' "
EndIf

cQuery	+= " And L1_STORC <> 'C' "
cQuery	+= " And L1_FILIAL ='" + xFilial('SL1') + "'"
cQuery	+= " And D_E_L_E_T_ = ' ' "
cQuery	+= " And L1_EMISSAO BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"' " 	
cQuery	+= " Group by L1_FILIAL,L1_CGCCLI,L1_EMISSAO,D_E_L_E_T_"

cQuery := ChangeQuery( cQuery )
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cSL1, .F., .T.)
TcSetField(cSL1,"L1_EMISSAO","D")
(cSL1)->(DbGoTop())

While !(cSL1)->(Eof())
	nPos := Ascan(::VndsIdentRet, {|x| x:CpfCnpj == (cSL1)->L1_CGCCLI})

	If nPos > 0
		::VndsIdentRet[nPos]:TotalVnd	+= (cSL1)->VlrTotal
	Else
		AAdd(::VndsIdentRet,WSClassNew("VndsIdent"))
		nPos := Len(::VndsIdentRet)
		::VndsIdentRet[nPos]:CpfCnpj	:= (cSL1)->L1_CGCCLI
		::VndsIdentRet[nPos]:TotalVnd	:= (cSL1)->VlrTotal
		::VndsIdentRet[nPos]:PafMd5OK	:= .T.
	EndIf

	(cSL1)->(DbSkip())
End

(cSL1)->(DbGoTop())
While !(cSL1)->(Eof())
	nPos := Ascan(::VndsIdentRet, {|x| x:CpfCnpj == (cSL1)->L1_CGCCLI})

	If nPos > 0
		cCpfCnpj := (cSL1)->L1_CGCCLI
		dLstData := (cSL1)->L1_EMISSAO

		If ::VndsIdentRet[nPos]:DtFirstS == NIL
			::VndsIdentRet[nPos]:DtFirstS := (cSL1)->L1_EMISSAO
		EndIf
	EndIf
	(cSL1)->(DbSkip())

	If (nPos > 0) .And. ( (cSL1)->(Eof()) .Or. (cCpfCnpj <> (cSL1)->L1_CGCCLI) )
		::VndsIdentRet[nPos]:DtLastS	:= dLstData
	EndIf
End

(cSL1)->(DbCloseArea())

Return lRet

//--------------------------------------------------------
/*{Protheus.doc}LstSumReg
Efetua validação dos dados 

@param1	dDataIni - Data Inicial
@param2	dDataFim - Data Final

@author  	Varejo
@version 	P11.8
@since   	10/11/2015
@return  	lRet  - função executada com sucesso 
@obs     
@sample
*/
//--------------------------------------------------------
Function LstSumReg(dDataIni, dDataFim)
Local cQuery	:= ""
Local cQryExe	:= ""
Local cAlsTab	:= "SL1TMP"
Local nTotSFI	:= 0
Local nTotSL1	:= 0
Local nTotSL2 := 0
Local cIndex	:= ""
Local cChave	:= ""
Local cCond	:= ""
Local cWhere	:= ""
Local bWhile	:= {||}
Local aTotalRedZ	:= {}
Local aTotalSL1	:= {}
Local nX		:= 0
Local aRetLog	:= {}

/*/
Validação da SFI com SL1
/*/

DbSelectArea('SFI')

If Select(cAlsTab) > 0
	DbCloseArea(cAlsTab)
EndIf

cIndex	:= CriaTrab(Nil,.F.)
cChave	:= "FI_FILIAL+DTOS(FI_DTREDZ)"
cCond	:= "FI_FILIAL= '"+xFilial("SFI") + "'"

IndRegua("SFI",cIndex,cChave,,cCond,"")
SFI->(DbSeek(xFilial("SFI")+DtoS(dDataIni), .T.)) 

bWhile	:= {||SFI->FI_DTREDZ <= dDataFim}

While !(SFI->(Eof())) .AND. Eval(bWhile)
	Aadd(aTotalRedZ,{SFI->FI_DTREDZ,SFI->FI_PDV,SFI->FI_VALCON+SFI->FI_ISS,SFI->FI_DESC+SFI->FI_DESISS,SFI->FI_CANCEL+SFI->FI_CANISS,SFI->FI_SERPDV})
	SFI->(DbSkip())
EndDo

cQuery := " SELECT	SUM(L1_VLRLIQ) Total " 
cQuery += " FROM " + RetSQLName("SL1") + " SL1 "
cQuery += " INNER JOIN " + RetSqlName('SA1') + " SA1 "
cQuery += " ON A1_FILIAL='" + xFilial('SA1') +  "' AND A1_COD=L1_CLIENTE AND A1_LOJA=L1_LOJA AND SA1.D_E_L_E_T_ = ' '"	
cQuery += " WHERE SL1.D_E_L_E_T_ = ' ' "
cQuery += " AND L1_NUMCFIS <> ' ' AND L1_STORC <> 'C' AND L1_FILIAL = '" + xFilial('SL1') + "'"

For nX:= 1 to Len(aTotalRedZ)
	cQryExe := cQuery
	cWhere := " AND L1_EMISSAO = '" + Dtos(aTotalRedZ[nX][1]) + "'"	
	cWhere += " AND L1_PDV	 = '" + aTotalRedZ[nX][2] + "'"

	cQryExe := cQuery + cWhere	
	cQryExe := ChangeQuery( cQryExe )

	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQryExe),cAlsTab, .F., .T.)
	(cAlsTab)->(DbGoTop())
	If !(cAlsTab)->(Eof())
		If (cAlsTab)->Total <> aTotalRedZ[nX][3] //Compara o Valor Contabil
			AAdd(aRetLog,{aTotalRedZ[nX][1],;
						" Divergencia de valores -> " + Chr(10) + Chr(13) +;
			" Total da Reducao Z :" + AllTrim(Str(aTotalRedZ[nX][3],14,2)) + Chr(10) + Chr(13) +;
			" Total das Vendas SL1 :" + AllTrim(Str((cAlsTab)->Total,14,2)) ,;
			aTotalRedZ[nX][2],;
			aTotalRedZ[nX][6]})
		EndIf

		Aadd(aTotalSL1,{aTotalRedZ[nX][1],(cAlsTab)->Total})
	EndIf	

	DbCloseArea(cAlsTab)
Next nX

/*/
Validação da SL1 com a SL2
/*/
/*cQuery := " SELECT	SUM(L1_VLRLIQ) Total " 
cQuery += " FROM " + RetSQLName("SL1") + " SL1 "
cQuery += " INNER JOIN " + RetSqlName('SA1') + " SA1 "
cQuery += " ON A1_FILIAL='" + xFilial('SA1') +  "' AND A1_COD=L1_CLIENTE AND A1_LOJA=L1_LOJA AND SA1.D_E_L_E_T_ = ''"	
cQuery += " WHERE SL1.D_E_L_E_T_ = '' "
cQuery += " AND L1_NUMCFIS <> '' AND L1_STORC <> 'C' AND L1_FILIAL = '" + xFilial('SL1') + "'"

For nX:= 1 to Len(aTotalRedZ)
cQryExe := cQuery 	 
cWhere := " AND L1_EMISSAO = '" + Dtos(aTotalRedZ[nX][1]) + "'"	
cWhere += " AND L1_PDV	 = '" + aTotalRedZ[nX][2] + "'"

cQryExe := cQuery + cWhere	
cQryExe := ChangeQuery( cQryExe )

DBUseArea(.T., "TOPCONN", TCGenQry(,,cQryExe),cAlsTab, .F., .T.)
(cAlsTab)->(DbGoTop())
If !(cAlsTab)->(Eof())
If (cAlsTab)->Total <> aTotalRedZ[nX][3] //Compara o Valor Contabil
AAdd(aRetLog,{aTotalRedZ[nX][1],;
"Divergencia de valores -> SFI :" + StrZero(aTotalRedZ[nX][3],15,2) + "; SL1 :" + StrZero((cAlsTab)->Total,15,2)})
EndIf

Aadd(aTotalSL1,{aTotalRedZ[nX][1],(cAlsTab)->Total})
EndIf	

DbCloseArea(cAlsTab)
Next nX
*/

Return aRetLog


//--------------------------------------------------------
/*{Protheus.doc}LstTabPaf
Efetua validação das tabelas do PAF 

@author  	Varejo
@version 	P11.8
@since   	10/11/2015
@return  	lRet  - função executada com sucesso 
@obs     
@sample
*/
//--------------------------------------------------------
Function LstTabPaf()
Local aRet := {}

AAdd(aRet,{ AliasInDic('CF5') , "CF5"}) //Caso não exista, dá problema na pesquisa da SFI (SPEDXFUN)
AAdd(aRet,{ AliasInDic('MFT') , "MFT"})
AAdd(aRet,{ AliasInDic('MDZ') , "MDZ"})

Return aRet

//---------------------------------------------------------------------------
/*/
{Protheus.Doc} LstVndManu
lista de vendas manuais ( NF [manual e nota CF], NFCe e NF-e)

@author Varejo
@version P12
@since   17/05/2017
@return  lRet , Boolean , Retorno
/*/
//---------------------------------------------------------------------------
WSMETHOD LstVndManu WSRECEIVE dDataIni,dDataFim,cPDV, cEmpPdv,;
	cFilPdv, lHomolPaf, cIniDoc WSSEND LstVndNFMn WSSERVICE FRTPafEcf
Local cFilSF2		:= ""
Local cFilSA1		:= ""
Local cNomCli		:= ""
Local cCGCCli		:= ""
Local cSF2Tmp		:= ""
Local cQuery		:= "" 
Local cPafMd5		:= ""
Local lIncManual	:= .F.
Local lDelManual	:= .F.
Local lCancelado	:= .F.
Local lDadoCli		:= .F.
Local lNewField		:= .F.
Local nSizeFile		:= 0
Local nPos			:= 0
Local nAcrescimo	:= 0
Local nTotalValid	:= 0
Local nTotalSF2		:= 0 

/* Chama RPCSETENV */
LjPreparaWs(::cEmpPdv,::cFilPdv)

lDadoCli:= .T.

cFilSF2	:= xFilial("SF2")
cFilSA1	:= xFilial("SA1")
cPDV := AllTrim(cPDV)

DbSelectArea("SF2")
DbSelectArea("SF3")
SF3->(DbSetOrder(6)) //F3_FILIAL, F3_NFISCAL, F3_SERIE

lNewField := SF2->(ColumnPos("F2_PAFMD5")) > 0

//Para validar a deleção: excluir SF2 via apsdu e deixar como detelado no banco de dados - Teste Bloco VII
If lHomolPaf
	SET DELETED OFF

	DbSelectArea("SF2")
	SF2->(DbSetOrder(3)) //F2_FILIAL, F2_ECF, F2_EMISSAO, F2_PDV, F2_SERIE, F2_MAPA, F2_DOC
	SF2->(DbSeek(cFilSF2+ Space(TamSx3("F2_ECF")[1]) + DtoS(dDataIni),.T.))

	While !SF2->(Eof()) .AND. SF2->F2_EMISSAO <= dDataFim
		If ( (Empty(cPDV) .AND. !Empty(SF2->F2_PDV) ) .OR.  AllTrim(SF2->F2_PDV) == cPDV ) ;
		.AND. !Empty(SF2->F2_DOC) .AND. (AllTrim(SF2->F2_ESPECIE) $ "SPED|NFCE|NFCF|NF") .And. SF2->F2_FILIAL == cFilSF2

			lCancelado := SF3->(DbSeek(xFilial("SF3")+SF2->(F2_DOC+F2_SERIE))) .And. "CANCELADA" $ Upper(AllTrim(SF3->F3_OBSERV)) //Notas Canceladas tbm são validas				

			If ! Empty(AllTrim(SF2->F2_DOC)) .And. ((!SF2->(Deleted()) .And. !lCancelado) .Or. (SF2->(Deleted()) .And. lCancelado))					
				nTotalValid++				
			EndIf

			nTotalSF2++
		EndIf
		SF2->(DbSkip())
	EndDo

	SET DELETED ON

	If nTotalSF2 < nTotalValid
		lDelManual := .T.
	EndIf
EndIf

cSF2Tmp	:= "SF2TMP"
If Select(cSF2Tmp) > 0
	(cSF2Tmp)->(DbCloseArea())
EndIf

cQuery	:= " SELECT "
cQuery	+= " F2_FILIAL,F2_CHVNFE,F2_ESPECIE,F2_DESCONT,F2_VALBRUT,F2_PDV,F2_ECF, "   
cQuery	+= " F2_EMISSAO,F2_VALFAT,F2_CLIENTE,F2_LOJA,F2_CGCCLI,F2_DOC,F2_SERIE, "
If lNewField
	cQuery	+= " F2_PAFMD5,"
EndIf
cQuery 	+= " A1_NOME,A1_CGC "
cQuery	+= " FROM " + RetSqlName("SF2") + " SF2 "
cQuery	+= " INNER JOIN " + RetSqlName("SA1") + " SA1 "
cQuery	+= " ON A1_FILIAL='"+cFilSA1+"' AND A1_COD=F2_CLIENTE AND A1_LOJA=F2_LOJA AND SA1.D_E_L_E_T_ = ' ' "
cQuery	+= " WHERE " 
cQuery	+= " (F2_ESPECIE IN ('SPED','NFCE','NF','NFCF') ) " //Modelo 55,65, Nota Manual e Cupom Sobre Nota
cQuery	+= "AND F2_EMISSAO BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"' "  
cQuery	+= "AND F2_DOC <> ' ' "
cQuery	+= "AND F2_FILIAL ='" + cFilSF2 + "'"

If !Empty(cPDV)
	cQuery	+= " AND F2_PDV = '" + cPDV + "' "
EndIf

If !Empty(cIniDoc)
	cQuery	+= "AND F2_DOC > '" + cIniDoc + "' "
EndIf

//"SF2.D_E_L_E_T_ = ' '  "
//Não insere o D_E_L_E_T_ aqui pois quando tenho estorno da Danfe ele apaga a SF2 e marca na SF3

cQuery	+= "ORDER BY F2_EMISSAO,F2_DOC"

cQuery := ChangeQuery( cQuery )
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cSF2Tmp, .F., .T.)
TcSetField(cSF2Tmp,"F2_EMISSAO","D")
(cSF2Tmp)->(DbGoTop())

While !(cSF2Tmp)->(Eof())

	//Se não tiver o numero da DANFE não pode aparecer no registro do PAF
	If Empty(AllTrim((cSF2Tmp)->F2_CHVNFE)) .And. ;
		(AllTrim((cSF2Tmp)->F2_ESPECIE) == "SPED" .Or. AllTrim((cSF2Tmp)->F2_ESPECIE) == "NFCE")
		
		(cSF2Tmp)->(DbSkip())		
		Loop
	EndIf

	//Alterar: o F2_CLIENTE para um cliente valido para mostrar no registro 
	cNomCli		:= (cSF2Tmp)->A1_NOME  
	cCGCCli		:= (cSF2Tmp)->F2_CGCCLI
	nAcrescimo	:= (cSF2Tmp)->F2_VALFAT - (cSF2Tmp)->F2_VALBRUT
	lCancelado	:= .F.

	If SF3->(DbSeek(xFilial("SF3")+(cSF2Tmp)->(F2_DOC+F2_SERIE))) .And. "CANCELADA" $ Upper(AllTrim(SF3->F3_OBSERV))		
		lCancelado	:= .T.
	EndIf

	AAdd(::LstVndNFMn,WSClassNew("VndNFMnNF"))
	nPos++

	::LstVndNFMn[nPos]:CnpjEmi		:= StrTran(StrTran(StrTran(SM0->M0_CGC,"-"),"/"),".") 
	::LstVndNFMn[nPos]:DataEmiss	:= (cSF2Tmp)->F2_EMISSAO
	::LstVndNFMn[nPos]:SubTotal		:= (cSF2Tmp)->F2_VALBRUT
	::LstVndNFMn[nPos]:DescTotal	:= (cSF2Tmp)->F2_DESCONT
	::LstVndNFMn[nPos]:AcreTotal	:= IIf(nAcrescimo > 0, nAcrescimo , 0)
	::LstVndNFMn[nPos]:TpDescon		:= IIf((cSF2Tmp)->F2_DESCONT > 0, "V", " ")
	::LstVndNFMn[nPos]:TpAcresc		:= IIf(nAcrescimo > 0, "V" , " ")
	::LstVndNFMn[nPos]:TotLiquido	:= (cSF2Tmp)->F2_VALFAT
	//Para Validar a alteração de cancelamento - Altere o SF3 (F3_OBSERV) e F2_ECF com isso vai validar MD5 em branco e dar erro no registro
	::LstVndNFMn[nPos]:Cancelado	:= lCancelado	//Indicador de Cancelamento
	::LstVndNFMn[nPos]:ValCancTot	:= If( lCancelado , nAcrescimo , 0 ) //Indicador de cancelamento do acrescimo 
	::LstVndNFMn[nPos]:OrdAplDesc	:= IIf(nAcrescimo > 0, "A" , IIf((cSF2Tmp)->F2_DESCONT > 0, "D", " "))
	::LstVndNFMn[nPos]:NomeClient	:= cNomCli
	::LstVndNFMn[nPos]:CNPJClient	:= cCGCCli
	::LstVndNFMn[nPos]:NumNota		:= Val((cSF2Tmp)->F2_DOC)
	::LstVndNFMn[nPos]:SerieNota	:= (cSF2Tmp)->F2_SERIE

	If AllTrim((cSF2Tmp)->F2_ESPECIE) == "NF" .Or. AllTrim((cSF2Tmp)->F2_ESPECIE) == "NFCF"
		::LstVndNFMn[nPos]:KeyNota		:= StrZero(0,44)
	Else
		::LstVndNFMn[nPos]:KeyNota		:= (cSF2Tmp)->F2_CHVNFE
	EndIf

	//o teste de alteração deve ser feito no 
	Do Case
		Case AllTrim((cSF2Tmp)->F2_ESPECIE) == "NF" .Or. AllTrim((cSF2Tmp)->F2_ESPECIE) == "NFCF"
		::LstVndNfMn[nPos]:TpDocEmi		:= 1

		Case AllTrim((cSF2Tmp)->F2_ESPECIE) == "SPED"
		::LstVndNFMn[nPos]:TpDocEmi		:= 2

		Case AllTrim((cSF2Tmp)->F2_ESPECIE) == "NFCE"
		::LstVndNFMn[nPos]:TpDocEmi		:= 3
	EndCase    

	/* Gera/Valida chave MD5 dos Registros */
	cPafMd5 := STxPafMd5(cSF2Tmp)		    

	/*
	If lHomolPaf
	DbSelectArea("SF2")
	SF2->(DbSetOrder(1)) //F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO
	SF2->(MsSeek((cSF2Tmp)->(F2_FILIAL+F2_DOC+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
	RecLock("SF2",.F.)
	REPLACE SF2->F2_PAFMD5 WITH cPafMd5
	SF2->(MsUnlock())
	EndIf
	*/
	If lNewField
		If lCancelado
			If !Empty((cSF2Tmp)->F2_PAFMD5)
				::LstVndNFMn[nPos]:PAFMD5OK	:= (cSF2Tmp)->F2_PAFMD5 == cPafMd5
			Else
				::LstVndNFMn[nPos]:PAFMD5OK := .T.
			EndIf
		Else
			::LstVndNFMn[nPos]:PAFMD5OK := (cSF2Tmp)->F2_PAFMD5 == cPafMd5
		EndIf
	Else
		::LstVndNFMn[nPos]:PAFMD5OK := .T.
	EndIf

	//************************************************************************************
	//Valida Inclusão do registro via Banco de Dados, F2_PAFMD5 em branco - Teste Bloco VII
	//************************************************************************************
	If lNewField .And. Empty(AllTrim((cSF2Tmp)->F2_PAFMD5))
		lIncManual := IIf(lCancelado,.F.,.T.)
	Else
		lIncManual := .F.
	EndIf

	::LstVndNFMn[nPos]:IncManual := lIncManual 
	::LstVndNFMn[nPos]:DelManual := .F.

	If lDelManual
		::LstVndNFMn[nPos]:DelManual := .T.
		lDelManual := .F.
	EndIf

	nSizeFile += (cSF2Tmp)->(RecSize())

	//Limitador para não estourar carga maxima do WS:
	If nPos == 150 .Or. nSizeFile >= 500000
		::LstVndNFMn[nPos]:ContLoop := .T.
		Conout('Método LstVndNFMn - Quebra - Motivo :' + IIf(!(nSizeFile >= 500000),'Quantidade','Tamanho do node'))
		Exit
	ELse
		::LstVndNFMn[nPos]:ContLoop := .F.
	EndIf

	(cSF2Tmp)->(DbSkip())
End

(cSF2Tmp)->(DbCloseArea())

Return .T.

//---------------------------------------------------------------------------
/*/
{Protheus.Doc} LstItVdManu
lista os itens de vendas manuais ( NF [manual e nota CF], NFCe e NF-e)

@author Varejo
@version P12
@since   17/05/2017
@return  lRet , Boolean , Retorno
/*/
//---------------------------------------------------------------------------
WSMETHOD LstItVdManu WSRECEIVE dDataIni,dDataFim,cPDV, cEmpPdv,;
	cFilPdv, lHomolPaf, cIniDoc WSSEND LstItVndNFMn WSSERVICE FRTPafEcf
Local cFilSF2		:= ""
Local cFilSA1		:= ""
Local cNomCli		:= ""
Local cCGCCli		:= ""
Local cSD2Tmp		:= ""
Local cQuery		:= "" 
Local cPafMd5		:= ""
Local cTotParc		:= ""
Local nPos			:= 0
Local nAcrescimo	:= 0
Local nSizeFile		:= 0
Local nQtdDecQuant	:= 0
Local nQtdDecVUnit	:= 0
Local nVldSd2		:= 0
Local nTotalReg		:= 0
Local lIncManual	:= .F.
Local lDelManual	:= .F.
Local lCancelado	:= .F.
Local lDadoCli		:= .F.  
Local lPAFSL2MD5	:= .T.
Local lPAFSB1MD5	:= .T.
Local lNewField		:= .F.
Local cPAFSL2MD5	:= ""
Local cPAFSB1MD5	:= ""

/* Chama RPCSETENV */
LjPreparaWs(::cEmpPdv,::cFilPdv)

lDadoCli	:= .T.

nQtdDecQuant:= TamSX3("D2_QUANT")[2]
nQtdDecVUnit:= TamSX3("D2_PRUNIT")[2]
cFilSF2	:= xFilial("SF2")
cFilSA1	:= xFilial("SA1")
cPDV	:= AllTrim(cPDV)

DbSelectArea("SD2")
lNewField:= SD2->(ColumnPos("D2_DECQTD")) > 0

/*
//Trecho inserido para em caso de necessidade incluir MD5 nos campos
If lHomolPaf
DbSelectArea("SF2")
DbSelectArea("SD2")
SF2->(DbSetOrder(1))
SD2->(DbSetOrder(3)) //D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM
While !SD2->(Eof())
SF2->(DbSeek(SD2->D2_FILIAL+SD2->D2_DOC))
cPafMd5 := STxPafMd5("SD2")
RecLock("SD2",.F.)
REPLACE SD2->L2_PAFMD5 WITH cPafMd5
SD2->(MsUnlock())
SD2->(DbSkip())
EndDo
EndIf	
*/

DbSelectArea("SF3")
SF3->(DbSetOrder(6)) //F3_FILIAL, F3_NFISCAL, F3_SERIE

//Para validar a deleção: excluir SD2 via apsdu e deixar como detelado no banco de dados - Teste Bloco VII
If lHomolPaf
	SET DELETED OFF

	DbSelectArea("SF2")
	DbSelectArea("SD2")
	SD2->(DbSetOrder(3)) //D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM
	SF2->(DbSetOrder(3)) //F2_FILIAL, F2_ECF, F2_EMISSAO, F2_PDV, F2_SERIE, F2_MAPA, F2_DOC
	SF2->(DbSeek(cFilSF2+ Space(TamSx3("F2_ECF")[1]) + DtoS(dDataIni),.T.))

	While !SF2->(Eof()) .AND. SF2->F2_EMISSAO <= dDataFim
		SD2->(DbSeek(SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))

		While SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)

			lCancelado := SF3->(DbSeek(xFilial("SF3")+SF2->(F2_DOC+F2_SERIE))) .And. "CANCELADA" $ Upper(AllTrim(SF3->F3_OBSERV)) //Notas Canceladas tbm são validas

			If  ( SD2->(Deleted()) .And. ! Empty(AllTrim(SD2->D2_DOC)) .And. !lCancelado )				
				lDelManual := .T.
			EndIf
			SD2->(DbSkip())
		EndDo
		SF2->(DbSkip())
	EndDo

	SET DELETED ON
EndIf

lCancelado := .F.
cSD2Tmp	:= "SD2TMP"
If Select(cSD2Tmp) > 0
	(cSD2Tmp)->(DbCloseArea())
EndIf

cQuery	:= " SELECT "
cQuery	+= " F2_FILIAL,F2_CHVNFE,F2_ESPECIE,F2_CGCCLI,F2_DOC,F2_SERIE,"

If lNewField
	cQuery += "F2_PAFMD5,D2_DECQTD,D2_DECVLU,D2_PAFMD5,"
EndIf

cQuery	+= " D2_ITEM,D2_DOC,D2_DESC,D2_PRCVEN,D2_PDV,D2_EMISSAO, "   
cQuery	+= " D2_QUANT,D2_TOTAL,D2_CLIENTE,D2_LOJA,D2_COD, "
cQuery	+= " D2_UM,D2_PRUNIT,D2_DESCON,D2_VALACRS, D2_PICM,D2_ALIQISS,"
cQuery	+= " D2_SERIE,D2_FILIAL"

cQuery	+= " FROM " + RetSqlName("SD2") + " SD2 "
cQuery	+= " INNER JOIN " + RetSqlName("SF2") + " SF2 "
cQuery	+= " ON F2_FILIAL='"+cFilSF2+"' AND F2_DOC=D2_DOC AND F2_SERIE=D2_SERIE "
cQuery	+= " AND (F2_ESPECIE = 'SPED' OR F2_ESPECIE = 'NFCE' OR F2_ESPECIE = 'NF' OR F2_ESPECIE = 'NFCF') " //Modelo Manual,55 ou 65

/*Removido o D_E_L_E_T_ pois em notas canceladas os dados são deletados*/
//cQuery	+= " AND SF2.D_E_L_E_T_ = ' ' "
//cQuery	+= " WHERE SD2.D_E_L_E_T_ = ' '  "

cQuery	+= " WHERE D2_EMISSAO BETWEEN '"+ DtoS(dDataIni) +"' AND '"+ Dtos(dDataFim) +"' "  
cQuery	+= "AND D2_DOC <> ' ' "
cQuery	+= "AND D2_FILIAL = '" + cFilSF2 + "'"
If !Empty(cPDV)
	cQuery	+= " AND D2_PDV = '" + cPDV + "' "
EndIf

If !Empty(cIniDoc)
	cQuery	+= "AND D2_DOC > '" + cIniDoc + "' "
EndIf

cQuery	+= " ORDER BY D2_EMISSAO,D2_DOC "

cQuery := ChangeQuery( cQuery )
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cSD2Tmp, .F., .T.)
TcSetField(cSD2Tmp,"D2_EMISSAO","D")
(cSD2Tmp)->(DbGoTop())

DbSelectArea("SF3")
DbSelectArea("SA1")
DbSelectArea("SB1")
DbSelectArea("SL1")
DbSelectArea("SL2")
SF3->(DbSetOrder(6)) //F3_FILIAL, F3_NFISCAL, F3_SERIE
SA1->(DbSetOrder(1)) //A1_FILIAL, A1_COD, A1_LOJA
SB1->(DbSetOrder(1)) //B1_FILIAL, B1_COD
SL1->(DbSetOrder(2)) //L1_FILIAL, L1_SERIE, L1_DOC, L1_PDV
SL2->(DbSetOrder(1)) //L2_FILIAL, L2_NUM, L2_ITEM, L2_PRODUTO

While !(cSD2Tmp)->(Eof())

	//Se não tiver o numero da DANFE não pode aparecer no registro do PAF
	If Empty(AllTrim((cSD2Tmp)->F2_CHVNFE)) .And. ;
		(AllTrim((cSD2Tmp)->F2_ESPECIE) == "SPED" .Or.  AllTrim((cSD2Tmp)->F2_ESPECIE) == "NFCE")
		
		(cSD2Tmp)->(DbSkip())
		Loop
	EndIf

	cNomCli := ""
	If SA1->(DbSeek(cFilSA1+(cSD2Tmp)->(D2_CLIENTE+D2_LOJA)))
		cNomCli	:= SA1->A1_NOME
	EndIf

	cCGCCli		:= (cSD2Tmp)->F2_CGCCLI
	nAcrescimo	:= (cSD2Tmp)->D2_VALACRS
	lCancelado	:= .F.
	lPAFSL2MD5	:= .T.
	lPAFSB1MD5  := .T.
	cPAFSL2MD5	:= ""
	cPAFSB1MD5  := ""

	If SF3->(DbSeek(xFilial("SF3")+(cSD2Tmp)->(D2_DOC+D2_SERIE))) .And. "CANCELADA" $ Upper(AllTrim(SF3->F3_OBSERV))		
		lCancelado	:= .T.
	EndIf

	AAdd(::LstItVndNFMn,WSClassNew("ItVndNFMnNF"))
	nPos++

	::LstItVndNFMn[nPos]:CnpjEmi	:= StrTran(StrTran(StrTran(SM0->M0_CGC,"-"),"/"),".") 
	::LstItVndNFMn[nPos]:DataEmiss	:= (cSD2Tmp)->D2_EMISSAO
	::LstItVndNFMn[nPos]:ItemNum	:= Val((cSD2Tmp)->D2_ITEM)
	::LstItVndNFMn[nPos]:CodProd	:= (cSD2Tmp)->D2_COD

	SB1->(DbSeek(xFilial("SB1")+(cSD2Tmp)->D2_COD))

	//Para validar interrogacoes aqui, altera o SB1 e o SL2
	//efetuo a pesquisa na SL2 pois se houver alteração do SB1 mantem o que foi impresso no cupom
	If AllTrim((cSD2Tmp)->F2_ESPECIE) == 'NF' .OR. AllTrim((cSD2Tmp)->F2_ESPECIE) == 'NFCF'
		SL1->(DbSeek(xFilial("SL1")+(cSD2Tmp)->F2_SERIE+(cSD2Tmp)->F2_DOC+(cSD2Tmp)->D2_PDV))
		SL2->(DbSeek(SL1->(L1_FILIAL+L1_NUM)+(cSD2Tmp)->D2_ITEM))

		::LstItVndNFMn[nPos]:Descricao	:= AllTrim(SL2->L2_DESCRI)

		cPAFSL2MD5 := AllTrim(SL2->L2_PAFMD5)
	Else
		::LstItVndNFMn[nPos]:Descricao	:= "#" + Alltrim(SB1->B1_CEST) + "#" + Alltrim(SB1->B1_POSIPI) + "#" + Alltrim(SB1->B1_DESC)
		cPAFSB1MD5 := AllTrim(SB1->B1_PAFMD5)
	EndIf
	::LstItVndNFMn[nPos]:Quantidade	:= (cSD2Tmp)->D2_QUANT * &("1" + Replicate("0",nQtdDecQuant))
	::LstItVndNFMn[nPos]:UnMedida	:= (cSD2Tmp)->D2_UM
	::LstItVndNFMn[nPos]:VlrUnit	:= (cSD2Tmp)->D2_PRUNIT
	::LstItVndNFMn[nPos]:DescItem	:= (cSD2Tmp)->D2_DESCON
	::LstItVndNFMn[nPos]:AcreItem	:= IIf(nAcrescimo > 0, nAcrescimo , 0)
	::LstItVndNFMn[nPos]:VlrLiq		:= (cSD2Tmp)->D2_TOTAL

	If (cSD2Tmp)->D2_PICM > 0 
		cTotParc := 'T' + StrTran(StrTran(StrZero((cSD2Tmp)->D2_PICM,5,2),","),".")
	ElseIf (cSD2Tmp)->D2_ALIQISS > 0
		cTotParc := 'S' + StrTran(StrTran(StrZero((cSD2Tmp)->D2_ALIQISS,5,2),","),".")
	Else
		cTotParc := 'T' + StrTran(StrTran(StrZero(SuperGetMV("MV_ICMPAD",,18),5,2),","),".")
	EndIf

	::LstItVndNFMn[nPos]:TotParc	:= cTotParc
	::LstItVndNFMn[nPos]:ItCancel	:= .F. //lCancelado	//Indicador de Cancelamento
	
	If lNewField
		::LstItVndNFMn[nPos]:QtdDecQtd	:= (cSD2Tmp)->D2_DECQTD
		::LstItVndNFMn[nPos]:QtdDecVUn	:= (cSD2Tmp)->D2_DECVLU
	Else
		::LstItVndNFMn[nPos]:QtdDecQtd	:= nQtdDecQuant
		::LstItVndNFMn[nPos]:QtdDecVUn	:= nQtdDecVUnit
	EndIf
	
	::LstItVndNFMn[nPos]:NumNota	:= Val((cSD2Tmp)->D2_DOC)
	::LstItVndNFMn[nPos]:SerieNota	:= (cSD2Tmp)->D2_SERIE

	If AllTrim((cSD2Tmp)->F2_ESPECIE) == "NF" .Or. AllTrim((cSD2Tmp)->F2_ESPECIE) == "NFCF"
		::LstItVndNFMn[nPos]:KeyNota	:= StrZero(0,44)
	Else
		::LstItVndNFMn[nPos]:KeyNota	:= (cSD2Tmp)->F2_CHVNFE
	EndIf

	//o teste de alteração deve ser feito no 
	Do Case
		Case AllTrim((cSD2Tmp)->F2_ESPECIE) == "NF" .Or. AllTrim((cSD2Tmp)->F2_ESPECIE) == "NFCF"
		::LstItVndNFMn[nPos]:TpDocEmi		:= 1

		Case AllTrim((cSD2Tmp)->F2_ESPECIE) == "SPED"
		::LstItVndNFMn[nPos]:TpDocEmi		:= 2

		Case AllTrim((cSD2Tmp)->F2_ESPECIE) == "NFCE"
		::LstItVndNFMn[nPos]:TpDocEmi		:= 3
	EndCase

	/* Gera/Valida chave MD5 dos Registros */
	cPafMd5 := STxPafMd5(cSD2Tmp,(cSD2Tmp)->(AllTrim(F2_CHVNFE)+AllTrim(F2_ESPECIE)))	    

	/*
	If lHomolPaf
	DbSelectArea("SF2")
	SF2->(DbSetOrder(1)) //F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO
	SF2->(MsSeek((cSD2Tmp)->(F2_FILIAL+F2_DOC+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
	RecLock("SF2",.F.)
	REPLACE SF2->F2_PAFMD5 WITH cPafMd5
	SF2->(MsUnlock())
	EndIf
	*/

	If !Empty(cPAFSL2MD5)
		lPAFSL2MD5 := STxPafMd5("SL2", SL1->L1_NUMORC) == cPAFSL2MD5
	ElseIf !Empty(cPAFSB1MD5)
		lPAFSB1MD5 := STxPafMd5("SB1") == cPAFSB1MD5
	EndIf

	If lNewField
		If lCancelado
			If !Empty((cSD2Tmp)->D2_PAFMD5)
				::LstItVndNFMn[nPos]:PAFMD5OK := (cSD2Tmp)->D2_PAFMD5 == cPafMd5  .And. lPAFSL2MD5 .And. lPAFSB1MD5
			Else
				::LstItVndNFMn[nPos]:PAFMD5OK := .T.
			EndIf
		Else
			::LstItVndNFMn[nPos]:PAFMD5OK := (cSD2Tmp)->D2_PAFMD5 == cPafMd5 .And. lPAFSL2MD5 .And. lPAFSB1MD5
		EndIf
	Else
		::LstItVndNFMn[nPos]:PAFMD5OK := .T.
	EndIf

	//************************************************************************************
	//Valida Inclusão do registro via Banco de Dados, D2_PAFMD5 em branco - Teste Bloco VII
	//************************************************************************************
	If lNewField .And. Empty(AllTrim((cSD2Tmp)->D2_PAFMD5))
		lIncManual := IIf(lCancelado,.F.,.T.)
	Else
		lIncManual := .F.
	EndIf

	::LstItVndNFMn[nPos]:IncManual := lIncManual
	::LstItVndNFMn[nPos]:DelManual := .F.

	If lDelManual
		::LstItVndNFMn[nPos]:DelManual := .T.
		lDelManual := .F.
	EndIf

	nSizeFile += (cSD2Tmp)->(RecSize())

	//Limitador para não estourar carga maxima do WS:
	If nPos == 150 .Or. nSizeFile >= 500000
		::LstItVndNFMn[nPos]:ContLoop := .T.
		Conout('Método LstItVndNFMn - Quebra - Motivo :' + IIf(!(nSizeFile >= 500000),'Quantidade','Tamanho do node'))
		Exit
	ELse
		::LstItVndNFMn[nPos]:ContLoop := .F.
	EndIf

	(cSD2Tmp)->(DbSkip())
End

(cSD2Tmp)->(DbCloseArea())

Return .T.

//----------------------------------------------
/*/
{Protheus.Doc} LjPAFUpest
Atuliza Primeiro Stock

@param	cAlias , String, Alias corrente 
@author Varejo
@version P12
@since   03/08/2017
@return  lRet , Boolean , Retorno
/*/
//----------------------------------------------
Function LjPAFUpest(cAlias)
Local lRet		:= .F.
Local lB1_QATUPAF:= .F.
Local cQuery	:= ""
Local cPafMd5	:= ""
Local cMD5SB1	:= ""
Local aAreaSB1	:= {}
Local cAlsSB1	:= ""

Default cAlias := ""

DbSelectArea("SB1")
lB1_QATUPAF := SB1->(ColumnPos("B1_QATUPAF")) > 0
aAreaSB1:= SB1->(GetArea())

cAlsSB1 := cAlias

If Empty(cAlsSB1)
	cAlsSB1	:= "SB1TPP" //Mudo o nome pra não ser o mesmo alias da SB1TMP

	If Select(cAlsSB1) > 0
		(cAlsSB1)->(DbCloseArea())
	EndIf

	cQuery	:= " SELECT "
	cQuery	+= " SB1.*, "
	cQuery	+= " SB2.* "
	cQuery	+= " FROM " + RetSqlName("SB1") + " SB1 "
	cQuery	+= " LEFT JOIN " + RetSqlName("SB2") + " SB2 "
	cQuery	+= " ON SB1.B1_COD = SB2.B2_COD "
	cQuery	+= " WHERE "		
	cQuery	+= " SB1.B1_FILIAL = '" + xFilial('SB1') + "'"
	cQuery	+= " And SB2.B2_FILIAL = '" + xFilial('SB2') + "'"
	cQuery	+= " And SB1.D_E_L_E_T_ = ' '  AND SB1.B1_MSBLQL <> '1' "	
	cQuery  += " ORDER BY SB1.B1_COD "
	cQuery := ChangeQuery( cQuery )
	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlsSB1, .F., .T.)
	(cAlsSB1)->(DbGoTop())
EndIf

If lB1_QATUPAF
	While !(cAlsSB1)->(Eof())
		cPafMd5 := STxPafMd5(cAlsSB1)
	
		//Valida se o campo do MD5 está correto pois se algum registro da tabela SB1 foi alterado
		//via banco de dados nao deve-se alterar
		If ((cAlsSB1)->B1_PAFMD5 == cPafMd5) .AND. ( (cAlsSB1)->B1_QATUPAF <> (cAlsSB1)->B2_QATU )

			SB1->(DbSeek(xFilial("SB1")+(cAlsSB1)->B1_COD))
	
			RecLock("SB1",.F.)
			REPLACE B1_QATUPAF	WITH (cAlsSB1)->B2_QATU
			SB1->(MsUnlock())
	
			cMD5SB1 := STxPafMd5("SB1")
			RecLock("SB1",.F.)
			REPLACE B1_PAFMD5	WITH cMD5SB1
			SB1->(MsUnlock())
			Conout("Estoque atualizado para o produto [" + (cAlsSB1)->B1_COD + "]")
			LjGrvLog( Nil, "Estoque atualizado para o produto [" + (cAlsSB1)->B1_COD + "]")
		EndIf
		
		(cAlsSB1)->(DbSkip())
	End
EndIf

RestArea(aAreaSB1)

Return lRet

//---------------------------------------------------------------------------
/*/
{Protheus.Doc} WsLeMD5LG
Validação do MD5 da SLG

@param	cSERPDV , String, serie do PDV que gerou o registro 
@author Varejo
@version P12
@since   03/08/2017
@return  lRet , Boolean , Retorno
/*/
//---------------------------------------------------------------------------
Function WsLeMD5LG(cSERPDV)
Local aRetSLG := Array(2)
Local aAreaSLG:= {}
Local lRet	:= .T.

If Select("SLG") > 0
	aAreaSLG := SLG->(GetArea())
	SLG->(DbCloseArea())
EndIf

DbSelectArea("SLG")
SLG->(DbSetOrder(1))
While !SLG->(Eof())
	If Upper(AllTrim(cSERPDV)) == Upper(AllTrim(SLG->LG_SERPDV))
		aRetSLG[1] := AllTrim(SLG->LG_PAFMD5)
		Exit
	EndIf
	SLG->(DbSkip())
End

aRetSLG[2] := STxPafMd5("SLG")

SLG->(DbCloseArea())

DbSelectArea("SLG")

If Len(aAreaSLG) > 0
	RestArea(aAreaSLG)
EndIf

lRet := aRetSLG[1] == aRetSLG[2]

Return lRet