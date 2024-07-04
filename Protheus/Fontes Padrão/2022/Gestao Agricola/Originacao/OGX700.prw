#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "fwMvcDef.ch"
#INCLUDE "OGX700.ch"

Static __aNgcCtr := OGX700DEP()
static lAutomato   := IsBlind() 
Static __lCtrRisco 	 := SuperGetMv('MV_AGRO041', , .F.) 

/*{Protheus.doc} OGX700COM
Retorna os componentes disponíveis conforme filtro
@author jean.schulze
@since 17/08/2017
@version undefined
@param cProduto, characters, código do produto
@param cSafra, characters, safra do contrato
@param cQtdNegoc, characters, qtd negociada
@param dDtfixacao, date, data da fixação
@param dDEntrIni, date, data inicial da cadencia
@param dDEntrFim, date, data final da cadencia
@param nMoedactr, numeric, moeda do contrato
@type function
*/ 
Function OGX700COM (cTp, cProduto, cSafra, cQtdNegoc, dDtfixacao , dDEntrIni , dDEntrFim, nMoedactr, lMulta)
	Local nVrIndice  	:= 0
	Local nVrInd1   	:= 0
	Local nVrInd2  		:= 0
	Local nQtUMPRC    	:= 0
	Local nQt1AUM    	:= 0
	Local aCompPrc      := {}
	Local cAliasNK7	    := GetNextAlias()
	Local cFiltro       := ""
	Local cGrupo        := "" //SB1->B1_GRUPO
	Local c1aUM     	:= "" //SB1->B1_UM
	Local cUmPrc        := "" //Unidade de Medida de preço
	Local cTpComp       := "N" //N-Normal / M-Margem
	Local cComp_Idx	    := ""  //--<< contem o componente e o Indice do Componente >>
	Local cUMComp       := ""
	Local nMoedaCom     := 0
	
	Private aUMNaoConv 	:= {} 		
	
	/*Busca os dados do Produto*/
	dbSelectArea("SB1")
	SB1->( dbSetOrder(1) )
	If SB1->(DbSeek(xFilial("SB1") + cProduto ))
		cGrupo 		:= SB1->B1_GRUPO
		c1aUM    	:= SB1->B1_UM
		cUmPrc      := AgrUmPrc( cProduto )
	EndIF
	
	/*Filtro de Pesquisa de Componentes*/
	cFiltro  = "  AND ((NK8_CODPRO = '"  +  cProduto +"' AND NK8_GRPPRO = '"+ cGrupo + "') OR (NK8_CODPRO = '"  +  cProduto +"' AND NK8_GRPPRO = ' ') OR (NK8_CODPRO = ' ' AND NK8_GRPPRO = '"+ cGrupo + "')  OR (NK8_CODPRO = ' ' AND NK8_GRPPRO = ' ' ))"
	cFiltro += "  AND (NK7.NK7_APLICA = 'A' OR NK7.NK7_APLICA = '" + cTp + "')"
	cFiltro += "  AND NK7.NK7_UTILIZ ='" + cTpComp+ "'"
	cFiltro += "  AND NK8.NK8_ATIVO = 'S'"
	cFiltro += "  AND NK7.NK7_ATIVO = 'S'"
	
	if lMulta //só traz os componente multa
		cFiltro += "  AND NK7.NK7_CALCUL = 'M'"
	else
		cFiltro += "  AND NK7.NK7_CALCUL <> 'M'"
	endif
	
	cFiltro += "  AND NK7.NK7_PLVEND <> '3'"
	
	cFiltro := "%" + cFiltro + "%" 
	
	/*Consulta os componentes Relacionados*/
	BeginSql Alias cAliasNK7

		SELECT NK8.NK8_DIAINI, NK8.NK8_MESINI, NK8.NK8_DIAFIM, NK8.NK8_MESFIM, NK8.NK8_CODIDX, 
			   NK8.NK8_UM1PRO, NK8.NK8_MOEDA,  NK7.NK7_CALCUL, NK7.NK7_TIPPRC, NK8.NK8_CODCOM, 
			   NK8.NK8_ITEMCO, NK7.NK7_DESABR, NK7.NK7_ALTERA, NK7.NK7_ORDEM,  NK7.NK7_UTILIZ, 
			   NK7.NK7_REGRA,  NK7.NK7_FIXAVE, NK8.NK8_BOLSA,  NK7.NK7_HEDGE,  
			   NK7.NK7_FHEDGE, NK7.NK7_PRCMAR, SB1.B1_GRUPO		      
		  FROM %Table:NK8% NK8
		  LEFT JOIN %Table:SB1% SB1 ON SB1.B1_COD = NK8.NK8_CODPRO
		                           AND SB1.%notDel%
		                           AND SB1.B1_FILIAL =  %xFilial:SB1%
		  LEFT JOIN %Table:NK7% NK7 ON NK7.NK7_CODCOM = NK8.NK8_CODCOM 
		                           AND NK7.%notDel%
		                           AND NK7.NK7_FILIAL =  %xFilial:NK7%	
		 WHERE NK8.%notDel%
		   AND NK8_FILIAL = %xFilial:NK8%
		   %exp:cFiltro% 
		 ORDER BY NK8_CODCOM, NK8_CODPRO
				         		           
	EndSQL
	
	DbselectArea( cAliasNK7 )
	DbGoTop()
	While ( cAliasNK7 )->( !Eof() )

		//Valida a Dt. de Entrega
		IF !fValDtEntr( (cAliasNK7)->NK8_DIAINI,(cAliasNK7)->NK8_MESINI,(cAliasNK7)->NK8_DIAFIM,(cAliasNK7)->NK8_MESFIM, dDEntrIni)
			(cAliasNK7)->(dbSkip())
			Loop
		EndIF

		//Encontro o Tipo de Cotação do Indice 
		nVrIndice := 0
		dbSelectArea("NK0")
		NK0->( dbSetOrder(1) )
		If NK0->(DbSeek(xFilial("NK0") + (cAliasNK7)->NK8_CODIDX ))
			nVrIndice :=AgrGetInd( NK0->NK0_INDICE,NK0->NK0_TPCOTA, dDtFixacao )
		EndIF

		//Unidade de medida do componente de resultado (negocio e faturado) devem ter UM do negócio e do produto
		//A moeda também deve ser do negócio para os dois tipos.
		cUMComp   := (cAliasNK7)->NK8_UM1PRO      
		nMoedaCom := (cAliasNK7)->NK8_MOEDA
		If (cAliasNK7)->NK7_CALCUL = 'R' .and. (((cAliasNK7)->NK7_TIPPRC = '2') .or. ((cAliasNK7)->NK7_TIPPRC = '4')) //negociado ou faturado 
		    cUMComp   := Iif((cAliasNK7)->NK7_TIPPRC = '2', cUmPrc, c1aUM )
		    nMoedaCom := nMoedactr
		EndIf

		nTxacomp := OGX700CTAX( nMoedaCom , nMoedactr,dDtfixacao ) //--<< Conversao de Moeda >>--

		//Conversao de UM do Indice  Para a UM de Preco
		nQtUMPrc := AGRX001( cUMComp ,cUmPrc,1, cProduto) //agrexps.prw

		IF ! Alltrim( cUMComp ) = Alltrim ( cUmPrc ) // Unidades de medidas sao diferentes
			IF !fValConvUM( cUMComp , cUmPrc, 1)  		//oga420 - Se não foi possivel Converter //
				fMensUM( cUMComp , cUmPrc )
			EndIF
		EndIF

		//Conversao de UM do Indice  Para a 1a UM do Produto	
		nQt1AUM:= AGRX001( cUMComp ,c1aUM,1, cProduto) //agrexps.prw

		IF ! Alltrim( cUMComp ) = Alltrim ( c1aUM ) 	// Unidades de medidas sao diferentes
			IF !fValConvUM( cUMComp , c1aUM, 1)  		// Se não foi possivel Converter //
				fMensUM( cUMComp , c1aUM )
			EndIF
		EndIF
		
		///revisado
		nVrind1 := OGX700UMVL(nVrIndice,cUMComp,cUmPrc, cProduto)
		nVrind2 := OGX700UMVL(nVrIndice,cUMComp,c1aUM, cProduto)

		if nMoedactr > 1 
			nVrind1 := ( nVrind1 * nTxaComp )  	//--<< contem o Vr do Indice na   Um de Preco do produto e na Moeda do Contrato>>--
			nVrind2 := ( nVrind2 * nTxaComp ) 	//--<< contem o Vr do Indice na 1aUm          do produto e na Moeda do Contrato>>--
        else
        	nVrind1 := ( nVrind1 / nTxaComp )  	//--<< contem o Vr do Indice na   Um de Preco do produto e na Moeda do Contrato>>--
        	nVrind2 := ( nVrind2 / nTxaComp ) 	//--<< contem o Vr do Indice na 1aUm          do produto e na Moeda do Contrato>>--
        end if

		lAddArray := .f.

		//Logica Garante que sempre Tenha o Componente + Especifico no Array  		    
		IF  Empty( cComp_Idx )
			cComp_Idx := (cAliasNK7)->NK8_CODCOM+(cAliasNK7)->NK8_CODIDX
			lAddArray := .t.
		ElseIF ! cComp_Idx = (cAliasNK7)->NK8_CODCOM .and. cTpComp == 'N'
			cComp_Idx := (cAliasNK7)->NK8_CODCOM
			lAddArray := .t.
		EndIF
		
		//cria novo array
		IF lAddArray
			aAdd(aCompPrc , Array(29))
		endif
		
		aCompPrc[len(aCompPrc), 01]	:=(cAliasNK7)->NK8_CODCOM 
		aCompPrc[len(aCompPrc), 02]	:=(cAliasNK7)->NK8_ITEMCO
		aCompPrc[len(aCompPrc), 03]	:=(cAliasNK7)->NK8_CODIDX
		aCompPrc[len(aCompPrc), 04]	:=(cAliasNK7)->NK7_DESABR 
		aCompPrc[len(aCompPrc), 05]	:=nMoedaCom //moeda componente
		aCompPrc[len(aCompPrc), 06]	:=nTxaComp //cotação moeda
		aCompPrc[len(aCompPrc), 07]	:=cUMComp // unidade de medida do componente
		aCompPrc[len(aCompPrc), 08]	:=nVrIndice // valor indice - valor inicial do componente
		aCompPrc[len(aCompPrc), 09] := iif((cAliasNK7)->NK7_ALTERA == '1', nVrIndice, 0) //usar o indice somente se não puder alterar o valor.
		aCompPrc[len(aCompPrc), 10]	:=nVrInd1 //valor na unidade de medida de preço
		aCompPrc[len(aCompPrc), 11]	:=nVrind2 //valor na unidade de medida do produto
		aCompPrc[len(aCompPrc), 12]	:=nQtUMPrc //quantidade na unidade de medida de preço -> SB5->B5_UMPRC
		aCompPrc[len(aCompPrc), 13]	:=nQt1aUM //quantidade na unidade de medida do produto -> SB1->B1_UM
		aCompPrc[len(aCompPrc), 14]	:=(cAliasNK7)->NK7_CALCUL
		aCompPrc[len(aCompPrc), 15]	:=(cAliasNK7)->NK7_ORDEM
		aCompPrc[len(aCompPrc), 16]	:=(cAliasNK7)->NK7_UTILIZ
		aCompPrc[len(aCompPrc), 17]	:=(cAliasNK7)->NK7_TIPPRC //forma de preço 1=Preco Calculado;2=Preco Negociado;3=Preco Demonstrativo;4=Preco de Faturamento                                                
		aCompPrc[len(aCompPrc), 18]	:=(cAliasNK7)->NK7_REGRA 
		aCompPrc[len(aCompPrc), 19]	:=(cAliasNK7)->NK7_FIXAVE 
		aCompPrc[len(aCompPrc), 20]	:= 0 //quantidade a fixar para o componente
		aCompPrc[len(aCompPrc), 21]	:=(cAliasNK7)->NK7_ALTERA 
		aCompPrc[len(aCompPrc), 22]	:= 0 //quantidade fixada para o componente.
		aCompPrc[len(aCompPrc), 23]	:= 0 //quantidade fixada para o componente.
		aCompPrc[len(aCompPrc), 24]	:= '' //tipo de ordem.
		aCompPrc[len(aCompPrc), 27]	:= (cAliasNK7)->NK8_BOLSA //bolsa
		aCompPrc[len(aCompPrc), 28]	:= (cAliasNK7)->NK7_HEDGE //bolsa
		aCompPrc[len(aCompPrc), 29]	:= (cAliasNK7)->NK7_FHEDGE //bolsa
		//tratamento de margem
		IF cTpComp == 'M' .and. ((lAddArray .and. Empty( (cAliasNK7)->NK8_CODIDX ) .and. (cAliasNK7)->NK7_PRCMAR > 0 ) .or. (!lAddArray .and. nVrIndice == 0 ) ) //--<< Nao Encontrei Indice de Margem Tenho Q Calcular a Margem Com a Precentagem >>--
			aCompPrc[len(aCompPrc), 05]	:= 0 //MOEDAPERCENTUAL 		//--<< Mudo moeda Para percentagem para indicar q o calculo foi por percentual >>--
			aCompPrc[len(aCompPrc), 08]	:= (cAliasNK7)->NK7_PRCMAR
			aCompPrc[len(aCompPrc), 09]	:= (cAliasNK7)->NK7_PRCMAR
		EndIF 
		
		(cAliasNK7)->(dbSkip())
	EndDo
	
	(cAliasNK7)->(dbCloseArea())	
	
	//ordenando o array
	ASORT(aCompPrc, , , { | x,y | x[15] < y[15] } )
	
	//verifica se tem campo de resultado para o produto
	if !lMulta //só traz os componente multa
		if ASCAN(aCompPrc, {|x| AllTrim(x[17]) == "2"}) == 0 //não existe preço faturado.
			Help( , , STR0001, , STR0002, 1, 0 ) //Ajuda#"Não existe Preço Negociado cadastrado. Verificar o cadastro de componentes." 
		endif
	endif
	
return(aCompPrc)

/** {Protheus.doc} fValDtEntr
Função que Valida a Data de Entrega
@author: 	Equipe AgroIndustria
@Uso...: 	SIGAAGR
*/
Static Function fValDtEntr(cDiaIni, cMesIni,cDiaFim,cMesFim, dDtEntrFim  )
	Local lOk 		:= .t.
	Local dDtIni 	:= ctod( cDiaIni + '/' + cMesIni +'/'+ strzero(year(ddtentrfim),4) )
	Local dDtFim 	:= ctod( cDiaFim + '/' + cMesFim +'/'+ strzero(year(ddtentrfim),4) )

	If ! Empty(dDtIni)

		IF Month(dDtIni) > Month(dDtFim)
			dDtIni := YearSub( dDtIni , 1 )  //Subtrai um do no da Dt Ini
		Elseif Month(dDtIni) == Month(dDtFim) .and. Day(dDtini) >= Day(dDtFim)
			dDtIni := YearSub( dDtIni , 1 )  //Subtrai um do no da Dt Ini
		EndIF

		//Verifica se a data esta dentro do enterva-lo
		Do Case
			Case dDtEntrFim < dDtIni
			lOk :=.f.
			Case dDtEntrFim > dDtFim
			lok :=.f.
		EndCase
	EndIF
Return( lOk )

/** {Protheus.doc} OGX700CTAX
Funcao que Encontra indice multiplicador de conversao de moeda
@author: 	Equipe Agroindustria
@since:		30/10/2014
@Uso...: 	SIGAAGR
*/
Function OGX700CTAX( nMoedaComp , nMoedactr,dDtfixacao )
	Local nTxaComp 	:= 0
	Local nTxaCtr	:= 0
    
	//Ao Final do IF, o nTxaComp, Contera um indice multiplicador de conversao de moeda 
	//Baseado na Moeda do Componente e Moeda do Contrato										
	IF ! nMoedaComp = nMoedaCtr //a Moeda do indice não é Igual a Moeda do Ctrato 
		nTxaComp := 0 	//Ctacao da Moeda do Componente 	
		nTxaCtr  := 0 	//Ctacao da Moeda do Ctrato 		
		
		DBSelectArea("SM2")
		SM2->(DBSetOrder(1) )
		SM2->( DbSeek( DtoS( dDtFixacao) ) )

		nTxaComp 	:= &('SM2->M2_MOEDA'+ STRZERO(nMoedaComp,1) )
		nTxaCtr	:= &('SM2->M2_MOEDA'+ STRZERO(nMoedaCtr,1) )

		IF  ! nMoedaCtr == 1 //--<< Se a Moeda do Ctrato não for a Moeda Padrao >>--
			IF  nMoedaComp == 1 //--<< Se a Moeda do componente for a Moeda Padrao >>--
				nTxaComp :=  nTxaCtr
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
@author: 	Equipe Agroindustria
@since: 	02/10/2014
@Uso: 		SIGAAGR
*/
Static function fMensUM(UmOri , UmDest)
	Local cUmNaoConv	:=''
	Local nPos			:=0

	cUmNaoConv += STR0003 + '	' + UmOri + '	' + STR0004 + '	' + UmDest   // DE:###Para:
	nPos:=ascan(aUMNaoConv , cUmNaoConv )
	IF npos == 0 //Não consta no array, então eu adiciono 
		aAdd( aUMNaoConv , cUmNaoConv )
	EndIF
Return(nil)

/** {Protheus.doc} OGX700UMVL
Rotina que converte unidade de medida em valores
@param.: 	VlrIndice, Um.Origem, Um.Destino
Retorno: 	Valor do Indice Convertido 
@since.: 	02/10/2014
@Uso...: 	SIGAAGR
*/
Function OGX700UMVL(nVlrIndice, cUMOrig, cUMDest, cProduto)
	Local aAreaAnt 	:= GetArea()
	Local nValConv 	:= 0
	Local nQtUM		:= 0

	//Encontra o valor da qt
	nQtUM	:= AGRX001(cUMDest, cUMOrig,1, cProduto)
	
	nValConv := nVlrIndice * nQtUM
	
	RestArea(aAreaAnt)
Return( nValConv )

/*{Protheus.doc} OGX700RECG
//trata as regras dos componentes
@author jean.schulze
@since 09/11/2017
@version undefined
@param aComponent, array, descricao
@param oModel, object, descricao
@type function
*/
function OGX700RECG(aComponent, oModel)
	Local oModelN79  := oModel:GetModel( "N79UNICO" )
	Local nA         := 0
	Local cRegra     := ""
	Local aCompClone := aClone(aComponent)  
	Local nPos       := 0
	
	//verifica a regra
	for nA := 1 to len(aCompClone)
	
		if !empty(aCompClone[nA][18]) //trata a regra
			
			cRegra := aCompClone[nA][18] //apropria a regra original
				
			if !OGX700CKRG(cRegra, oModelN79)
			 	//se for para não estar remove do array		
			 	If ( nPos := aScan( aComponent, { |x| AllTrim( x[1] ) == AllTrim( aCompClone[nA][1] ) } ) ) > 0			 	
			 		ADel( aComponent, nPos ) //remove a posição do array
			 		ASize( aComponent, len(aComponent) -1 ) //redimensiona o array
			 	endif	
			endif									
		endif
		
	next nA	
	
return aComponent

/*{Protheus.doc} OGX700CKRG
Checagem de Regra
@author jean.schulze
@since 09/11/2017
@version undefined
@param cRegra, characters, descricao
@param oModelN79, object, descricao
@type function
*/
function OGX700CKRG(cRegra, oModelN79)
	Local lret     := .t.
	Local nB       := 0	
	Local aCmpsN79 :=  oModelN79:GetStruct() 
	
	//replace de dados
	for nB:=1 to Len(aCmpsN79:aFields) 
		cRegra := StrTran( cRegra, aCmpsN79:aFields[nB][3], IIf(aCmpsN79:aFields[nB][4] != "N", '"' + TRANSFORM(oModelN79:GetValue(aCmpsN79:aFields[nB][3]),"@") + '"'  , alltrim(str(oModelN79:GetValue(aCmpsN79:aFields[nB][3]))) )) //array de campos + local de valor
	next nB				

	if !&(cRegra)
		lret := .f.
	endif
	
return lret

/*{Protheus.doc} OGX700LEG
Legenda dos componentes
@author jean.schulze
@since 17/08/2017
@version undefined
@param cTpCalc, characters, descricao
@type function
*/
function OGX700LEG(cTpCalc)
	Local cCor := ""
	
	if cTpCalc = "C"
		cCor := STR0005 //"BR_VERMELHO"
	elseif  cTpCalc = "P"
		cCor := STR0006 //"BR_VERDE"
	elseif  cTpCalc = "I"
		cCor := STR0007 //"BR_AMARELO"
	elseif  cTpCalc = "T"
		cCor := STR0008 //"BR_LARANJA"
	elseif  cTpCalc = "M"
		cCor := STR0009 //"BR_VIOLETA"	
	elseif  cTpCalc = "R"
		cCor := STR0010 //"BR_PRETO"	
	endif
	
return cCor

/*{Protheus.doc} OGX700TLG
Chamada da Legenda
@author jean.schulze
@since 17/08/2017
@version undefined
@param oModel, object, descricao
@param oGridModel, object, descricao
@param cIDField, characters, descricao
@param xValue, , descricao
@param cTarget, characters, descricao
@type function
*/
function OGX700TLG(oModel, oGridModel, cIDField, xValue, cTarget)
	 Local aLegenda := { { STR0005, STR0011 },; //"BR_VERMELHO"#"Custo"
	    				 { STR0006   , STR0012 },; //"BR_VERDE"#"Preço"
	                     { STR0007 , STR0013 },; //"BR_AMARELO"#"Informativo"
	                     { STR0008 , STR0014 },; //"BR_LARANJA"#"Tributo"
	                     { STR0009 , STR0015 },; //"BR_VIOLETA"#"Multa"
	                     { STR0010   , STR0016 } } //"BR_PRETO"#"Resultado"
	 //verifica se é legenda
	 
	 if cIDField = "N7C_STSLEG"
	 	BrwLegenda( STR0017, STR0018,  aLegenda) //"Componentes"#"Legenda"
	 else
	 	//tratamento dos campos
	 	oModel:setValue(oGridModel,cIDField,xValue)	 		 		
	 endif
	 	
return .t.

/*{Protheus.doc} OGX700DLGC
Descrição Legenda dos componentes
@author claudineia.reinert
@since 23/09/2021
@version p12
@param cTpCalc, characters, Valor do campo N7C_TPCALC
@type function
*/
function OGX700DLGC(cTpCalc)
	Local cDesc := ""
	 
	if cTpCalc = "C"
		cDesc := STR0011 //#"Custo"
	elseif  cTpCalc = "P" 
		cDesc := STR0012 //#"Preço"
	elseif  cTpCalc = "I" 
		cDesc := STR0013 //#"Informativo"
	elseif  cTpCalc = "T"
		cDesc := STR0014 //#"Tributo"
	elseif  cTpCalc = "M"
		cDesc := STR0015 //#"Multa"
	elseif  cTpCalc = "R"
		cDesc := STR0016 //#"Resultado"
	endif
	 	
return cDesc


/*{Protheus.doc} OGX700VUPV
Atualiza valores da View
@author jean.schulze
@since 09/10/2017
@version undefined
@param oView, object, descricao
@type function
*/
Function OGX700VUPV(oView)
	Local oModel     := oView:getModel()
	Local oModelN7C  := oModel:getModel("N7CUNICO")
	Local nLine      := oModelN7C:GetLine() //oView:GetViewObj("VIEW_N7C")[3]:obrowse:At() 
	
	oView:refresh("VIEW_N7C")

	//atualiza browser
	if oView:GetViewObj("VIEW_N7C")[3]:obrowse:Filtrate() //tratamento quando tem fitro
		
	else
		oView:GetViewObj("VIEW_N7C")[3]:obrowse:GoTo( 1 )
		oView:GetViewObj("VIEW_N7C")[3]:obrowse:GoColumn( oView:GetViewObj("VIEW_N7C")[3]:obrowse:ColPos() - 1 )
		oView:GetViewObj("VIEW_N7C")[3]:obrowse:GoDown( nLine - 1 )
	endif
	
return .t.

/*{Protheus.doc} OGX700INDC
Filtro da consulta de indíces.
@author jean.schulze
@since 14/11/2017
@version 1.0
@return ${return}, ${return_description}
@type function
*/
Function OGX700INDC()
	Local oModel  := FwModelActive()
	Local cFiltro := ""
	Local cData   := ""
	
	if valtype(oModel) == "O" //é um objeto
		if oModel:GetId() == "OGA700" //tela negócio
			
			//Monta a data inicial
			cData := SUBSTR(DtoS(oModel:GetValue("N79UNICO" , "N79_DATA")), 1, 4) + SUBSTR(DtoS(oModel:GetValue("N79UNICO" , "N79_DATA")), 5, 2)
				
			//Filtro com todos os indices de mercador para o negócio.
			cFiltro := "@  NK0_CODBOL = '"+oModel:GetValue("N79UNICO" , "N79_BOLSA")+"' AND NK0_CODPRO = '"+oModel:GetValue("N79UNICO" , "N79_CODPRO") +"' AND NK0_MESBOL >= '"+cData+"' "
			
		elseif oModel:GetId() == "OGA410" //tela de componente
		
			if !empty(oModel:GetValue("NK8DETAIL" , "NK8_BOLSA"))
				cFiltro := "@  NK0_CODBOL = '"+oModel:GetValue("NK8DETAIL" , "NK8_BOLSA")+"'"
			endif	
		
		endif
	endif
	
Return(cFiltro)	


/*{Protheus.doc} OGX700VLEP
Validação de entidade
@author jean.schulze
@since 31/01/2018
@version 1.0
@return ${return}, ${return_description}
@param cTpCont, characters, descricao
@param cCodEnt, characters, descricao
@param cCodLoja, characters, descricao
@type function
*/
Function OGX700VLEP(cTpCont, cCodEnt, cCodLoja, cOpengc)
	Default cCodLoja := ""
	
	if cTpCont == "1" //entidade
		if !ExistCpo('NJ0',cCodEnt+iif(!empty(cCodLoja), cCodLoja, ""))
			return .f.				
		else
			if !empty(cCodLoja)
				if cOpengc == "1" //compra
					 if !AGRXVALENT("F",cCodEnt,cCodLoja) //valida entidade fornecedor
					 	return .f.
					 endif
				else //venda
					 if !AGRXVALENT("C",cCodEnt,cCodLoja) //valida entidade cliente
					 	return .f.
					 endif
				endif	
			endif	
		endif		
	elseif cTpCont == "2" //Prospect
		if !ExistCpo('SUS',cCodEnt+iif(!empty(cCodLoja), cCodLoja, ""))
			return .f.
		elseif !empty(cCodLoja) .and.  POSICIONE("SUS",1,XFILIAL("SUS")+cCodEnt+cCodLoja,"US_STATUS") $ "5|6" //cancelado ou cliente
			Help( , , STR0001, , STR0019, 1, 0, ,,,,,{STR0020} ) //"Ajuda"#"O prospect está com status cancelado ou cliente."#"Informe um prospect válido."
			return .f.
		endif
	endif
	
return .t.

/*******************************************************************
*********************FUNÇÕES DE CALCULO ****************************
/*******************************************************************/

/*{Protheus.doc} OGX700GVLR
Atualiza os valores dos campos de valor
@author jean.schulze
@since 17/08/2017
@version undefined
@param oField, object, descricao
@type function
*/
function OGX700GVLR(oField, cFieldRet)
	Local oModel    	:= oField:GetModel()
	Local oView			:= FwViewActive()    
	Local oModelN7C 	:= oModel:GetModel( "N7CUNICO" )
	Local c1aUM 		:= iiF(FWIsInCallStack("OGX701"),oModel:GetValue("XXXUNICO","XUMPROD"),oModel:GetValue( "N79UNICO","N79_UM1PRO"))
	Local cUmPrc 		:= iiF(FWIsInCallStack("OGX701"),oModel:GetValue("XXXUNICO","XUMPRC"),oModel:GetValue( "N79UNICO","N79_UMPRC"  )) 
	Local cTipoNgc		:= iiF(FWIsInCallStack("OGX701"),oModel:GetValue("XXXUNICO","XTIPNGC"),oModel:GetValue( "N79UNICO","N79_TIPO"))
	Local cTipoFix 		:= iiF(FWIsInCallStack("OGX701"),oModel:GetValue("XXXUNICO","XTIPFIX"),oModel:GetValue( "N79UNICO","N79_FIXAC" )) 
	Local cCodProd 		:= iiF(FWIsInCallStack("OGX701"),oModel:GetValue("XXXUNICO","XPRODUTO"),oModel:GetValue( "N79UNICO","N79_CODPRO" )) 
	Local dValor    	:= 0
	Local aSaveRows 	:= FwSaveRows(oModel)
	Local lFilterAct 	:= .F.
	Local lViewAct		:= .F.
	
	If ValType(oView) == 'O'
		lViewAct	:= .T.
		lFilterAct := Iif(aScan(oView:GetViewObj("VIEW_N7C")[3]:oBrowse:FwFilter():aCheckFil, {|x| x}) > 0, .T., .F.)
	EndIf
		 		
	//atualiza os valores do componente na unidade de medida do contrato e produto
	OGX700LNCP(oModelN7C,cUmPrc,c1aUM, iif(cTipoNgc $ "2|5" /*Fixação*/ .and. cTipoFix == "1" /*Preço*/, .T., .F. ),cCodProd ) 
	
	dValor := oModelN7C:GetValue(cFieldRet) //valor que será atualizado
	
	if oModelN7C:GetValue("N7C_TPCALC") <> "R" .and. oModelN7C:GetValue("N7C_COMAJU") == "1" //componente que foi alterado
		//reset
		oModelN7C:LoadValue("N7C_VLORIG", 0)
		oModelN7C:LoadValue("N7C_COMAJU", "0")
		
		//busca os calculos que ele é ajuste para  resetar
		DbselectArea( "N74" )
		DbSetOrder( 2 ) //via componente de ajuste
		DbGoTop()
		If dbSeek( xFilial( "N74" ) +  oModelN7C:GetValue( "N7C_CODCOM") )
			While !N74->( EoF() ) .And. N74->( N74_FILIAL + N74_CODAJU ) == xFilial( "N74" ) + oModelN7C:GetValue( "N7C_CODCOM") 
				if oModelN7C:SeekLine( { {"N7C_CODCOM", N74->(N74_CODCOM)  } } )
					oModelN7C:LoadValue( "N7C_VLRCOM", 0) 
			        oModelN7C:LoadValue( "N7C_VLRUN1", 0) 
					oModelN7C:LoadValue( "N7C_VLRUN2", 0) 
					oModelN7C:LoadValue( "N7C_VLTOTC", 0) 
					oModelN7C:LoadValue( "N7C_VLORIG", 0)
					oModelN7C:LoadValue( "N7C_COMAJU", "0")
				endif
			Enddo						
		endif
	else
		//atualização reverse
		OGX700CTRE(oModel)
	endif

    If __lCtrRisco .and. oModel:GetValue("N79UNICO", "N79_TIPO") $  '2|3' .and. oModelN7C:GetValue("N7C_HEDGE") == '1'
        oModelN7C:LoadValue( "N7C_QTDCTR", OGX700TQCT(oModel, "N7C_QTDCTR" ) )
    EndIf
			 
	//atualiza os campos totais
	OGX700CTPP(oModel)
			
	//atualiza valores na variavel principal
	if !FWIsInCallStack("OGX701")
		OGX700GTOT(oModel)
	endif
	
	If lViewAct .AND. lFilterAct
		oView:GetViewObj("VIEW_N7C")[3]:oBrowse:ExecuteFilter()
		FwRestRows(aSaveRows)
		oView:GetViewObj("VIEW_N7C")[3]:Refresh()
	Else
		FwRestRows(aSaveRows)
	EndIf
	
return(dValor)



/*/{Protheus.doc} OGA700TQCT()
// Gatilha a tabela n7c - Calcula quantida de contratos futuros
@author MARCELO FERRARI
@since 23/10/2018
@version 1.0
@return lRet 

@type function
/*/
Function OGX700TQCT(oModel, cFieldRet)
	Local oModelN79     := oModel:GetModel( "N79UNICO" )
	Local oModelN7A 	:= oModel:GetModel( "N7AUNICO" )
	Local oModelN7C 	:= oModel:GetModel( "N7CUNICO" )
	Local cCodPro 	    := oModelN79:GetValue("N79_CODPRO")
	Local cCodBol       := POSICIONE('NK0',1,XFILIAL('NK0')+oModelN7A:GetValue("N7A_IDXCTF"),'NK0_CODBOL')
	Local cUMProd       := oModelN79:GetValue("N79_UM1PRO")
	Local cTipoNgc		:= iiF(FWIsInCallStack("OGX701"),oModel:GetValue("XXXUNICO","XTIPNGC"),oModel:GetValue( "N79UNICO","N79_TIPO"))
	Local lModeView := iif(FWIsInCallStack("OGA700FIXA") .or. FWIsInCallStack("OGA700CANC") .or. FWIsInCallStack("OGA700MODF") .or. (FWIsInCallStack("OGA700UPDT") .and. cTipoNgc $ "2|3") , SuperGetMv("MV_AGRO007",,.T.) , .F.)//abre em modo resumido
	Local nQtdFix   := 0
	Local nNewQtdFix := 0

	//Buscar a unidade de medida do
	Local cQry		:= ""
	Local nQtdCtrF	:= 0

	If __lCtrRisco
		IF lModeView 
			nQtdFix := oModelN7C:GetValue("N7C_QTAFIX")
		Else
			nQtdFix := oModelN7A:GetValue("N7A_QTDINT")
		EndIf

		cQry := "SELECT N8U_QTDCTR, N8U_UMCTR " + ;
				"FROM " + RetSqlName("N8U")+ " N8U " + ;
				"WHERE N8U_CODBOL = '" + cCodBol + "' " + ;
				"AND N8U_CODPRO = '" + cCodPro + "' " + ;
				"AND D_E_L_E_T_ = ' '"
		
		aRes := getDataSqa(cQry)
		If !Empty(aRes[1])
			nQtdCtrF := oModelN7C:GetValue(cFieldRet) //valor que será atualizado
			nNewQtdFix  := AGRX001(cUMProd, aRes[2], nQtdFix, cCodPro)
			If aRes[1] <> 0
				nQtdCtrF := nNewQtdFix / aRes[1]
			endif
		EndIf
	EndIf

Return nQtdCtrF

/*/{Protheus.doc} OGX700CFUT()
// Validação disparada no PosModelo do OGA700
@author marcos.wagner
@since 08/02/2018
@version 1.0
@return lRet 
@type function
/*/
Function OGX700CFUT(oModel, cCadencia)
	Local oModelN79     := oModel:GetModel( "N79UNICO" )
	Local cCodPro 	    := oModelN79:GetValue("N79_CODPRO")
	Local cCodBol       := oModelN79:GetValue("N79_BOLSA")
	Local cQry		    := ""
	Local lRet          := .t.

	cQry := "SELECT N8U_QTDCTR, N8U_UMCTR " + ;
            "FROM " + RetSqlName("N8U")+ " N8U " + ;
            "WHERE N8U_CODBOL = '" + cCodBol + "' " + ;
            "AND N8U_CODPRO = '" + cCodPro + "' " + ;
            "AND D_E_L_E_T_ = ' '"
	
	aRes := getDataSqa(cQry)
	If Empty(aRes[1])
		AGRHELP(  STR0044, STR0045 + CHR(13) + CHR(13) + STR0060 + cCadencia, STR0046) //"Quantidade de Contratos Futuros" ## "Cadência: "
											  //"Não existe cadastro de quantidade por contrato para esta bolsa/produto",  ;
											  //"Informar quantidade por contrato no cadastro de indices da bolsa")
		lRet := .f.
	EndIf

Return lRet

/*{Protheus.doc} OGX700LNCP
Cálcula a linha do componente
@author jean.schulze
@since 17/08/2017
@version undefined
@param oModel, object, descricao
@param cUmPrc, characters, descricao
@param c1aUmPrd, characters, descricao
@type function
*/
function  OGX700LNCP(oModel,cUmPrc,c1aUmPrd, lExecMedia, cProduto) 
	Local nDecCompon := TamSx3('N7C_VLRCOM')[2] //casa decimais componentes
	Local nValor     := oModel:GetValue("N7C_VLRCOM")
	Local nValort1   := 0
	Local nValort2   := 0
    Local cTipVlMu   := SuperGetMv("MV_AGRMUAV", .F., "UN")
	
	/*Tratamento para negócios com fixações parciais*/
	if lExecMedia //aplicamos a média do valor
		if oModel:GetValue("N7C_QTAFIX") > 0 //vou estar fixando algo, é pq somente o valor total não me ajuda
			nValor := ((oModel:GetValue("N7C_VLRCOM") * oModel:GetValue("N7C_QTAFIX")) + (oModel:GetValue("N7C_VLRFIX") * oModel:GetValue("N7C_QTDFIX"))) / (oModel:GetValue("N7C_QTAFIX") + oModel:GetValue("N7C_QTDFIX"))  
		else //usamos o valor da fixação obtida no seu total
			nValor := oModel:GetValue("N7C_VLRFIX") 
		endif	
	endif
	
	/*Calcula os valores, conforme a unidade de medida do componente*/
	if oModel:GetValue("N7C_QTAFIX") > 0 .or. oModel:GetValue("N7C_QTDFIX") > 0
		oModel:SetValue( "N7C_VLRUN1", Round(OGX700UMVL(nValor,oModel:GetValue("N7C_UMCOM"),cUmPrc, cProduto) ,nDecCompon )) //preco
		oModel:SetValue( "N7C_VLRUN2", Round(OGX700UMVL(nValor,oModel:GetValue("N7C_UMCOM"),c1aUmPrd, cProduto) ,nDecCompon )) //produto	
	Else
		oModel:SetValue( "N7C_VLRUN1", 0) //preco
		oModel:SetValue( "N7C_VLRUN2",0) //produto	
	EndIf
	
	/*calcula o valor total do componente de forma diferente, não realizando a média ponderada*/
    if oModel:GetValue("N7C_QTAFIX") > 0  // se foi marcado quantidade para o valor a fixar
    	nValort1 := Round(OGX700UMVL(oModel:GetValue("N7C_VLRCOM"),oModel:GetValue("N7C_UMCOM"),c1aUmPrd, cProduto) ,nDecCompon ) * oModel:GetValue("N7C_QTAFIX")
    endif
	if oModel:GetValue("N7C_VLRFIX") > 0 //se possui valor fixado	
		nValort2 := Round(OGX700UMVL(oModel:GetValue("N7C_VLRFIX"),oModel:GetValue("N7C_UMCOM"),c1aUmPrd, cProduto) ,nDecCompon ) * oModel:GetValue("N7C_QTDFIX")	
	endif
	
    If oModel:GetValue("N7C_TPCALC") == "M" .AND. cTipVlMu == "TT" // Se for multa pelo total, então gatilha o valor informado para o total do componente
        oModel:SetValue( "N7C_VLTOTC", Round(oModel:GetValue("N7C_VLRCOM"), nDecCompon )) //valor total componente	
    Else
        oModel:SetValue( "N7C_VLTOTC", Round((nValort1 + nValort2), nDecCompon )) //valor total componente	
    EndIf
    /**/

	if oModel:GetValue("N7C_MOEDA") <> oModel:GetValue("N7C_MOEDCO") // se as moedas forem diferentes...
		/*Aplica Cotação*/
		if oModel:GetValue("N7C_MOEDCO") > 1 //moeda corrente
			oModel:SetValue( "N7C_VLRUN1", Round(oModel:GetValue("N7C_VLRUN1") * oModel:GetValue("N7C_TXCOTA") ,nDecCompon ))
			oModel:SetValue( "N7C_VLRUN2", Round(oModel:GetValue("N7C_VLRUN2") * oModel:GetValue("N7C_TXCOTA") ,nDecCompon ))
		else
			oModel:SetValue( "N7C_VLRUN1", Round(oModel:GetValue("N7C_VLRUN1") / oModel:GetValue("N7C_TXCOTA") ,nDecCompon ))
			oModel:SetValue( "N7C_VLRUN2", Round(oModel:GetValue("N7C_VLRUN2") / oModel:GetValue("N7C_TXCOTA") ,nDecCompon ))
		endif
	endif
		
return( .t. )

/*{Protheus.doc} OGX700GTOT
Retorna o valor do contrato
@author jean.schulze
@since 17/08/2017
@version undefined
@param oModel, object, descricao
@param lDelAcept, logical, descricao
@type function
*/
function OGX700GTOT(oModel, lDelAcept)
	Local oModelN7C := oModel:GetModel( "N7CUNICO" )
	Local oModelN7A := oModel:GetModel( "N7AUNICO" )
	Local nLinha    := oModelN7A:GetLine()
	Local nLinhaCom := oModelN7C:GetLine()
	Local nX        := 0
	Local dValor    := 0
	Local dQtdCad   := 0
	Local dValorTot := 0
	
	Default lDelAcept := .f.
	
	if oModel:GetValue( "N79UNICO","N79_TIPFIX" ) == "1" //é fixo 
		nX := 1 //start variable
		//aplica os componentes a todas as cadências
		while nX <= oModelN7A:Length() 
			oModelN7A:GoLine( nX )	
			if (!oModelN7A:IsDeleted() .or. lDelAcept ) .and. oModelN7A:GetValue( "N7A_USOFIX" ) <> "LBNO" //força deeltado		
			    //busca os componentes que é de resultado
				if !oModelN7C:IsDeleted()  
					if oModelN7C:SeekLine( { {"N7C_TPPREC", "2"  } } ) //preço negociado
						dValor      += oModelN7C:GetValue("N7C_VLRUN1") * oModelN7A:GetValue("N7A_QTDINT")
						dQtdCad     += oModelN7A:GetValue("N7A_QTDINT")
						dValorTot   += oModelN7C:GetValue("N7C_VLTOTC")
					else
						return(.f.)
					endif
				endif				
			endif
			nX++		
		endDo	
	endif 
			
	oModel:SetValue("N79UNICO", "N79_VLRUNI" ,dValor/dQtdCad ) //aplicando média ponderada em valor base - valor unitário
	oModel:SetValue("N79UNICO", "N79_VALOR"  ,dValorTot ) 
	
	oModelN7A:GoLine(nLinha) //reposiciona a cadencia
	oModelN7C:GoLine(nLinhaCom) //reposiciona linha do componente

return( .t. )

/*{Protheus.doc} OGX700CTPP
Atualiza os valores dos campos totalizadores
@author jean.schulze
@since 17/08/2017
@version undefined
@param oModel, object, descricao
@type function
*/
function OGX700CTPP(oModel) //totalizar os componentes de resultado
	Local oModelN7C  := oModel:GetModel( "N7CUNICO" )
	Local nX         := 0
	Local nValor     := 0
	Local nValor1    := 0
	Local nValor2    := 0
	Local nValorC    := 0
	Local cCodPro	 := oModel:GetValue( "N79UNICO","N79_CODPRO")
	Local cUmComRes  := ""
	Local dTaxaCom   := ""
	Local nMoedaCom  := 0
	Local nDecCompon := TamSx3('N7C_VLRCOM')[2]
	Local nValorComp := 0
	Local nValorTot1 := 0  
	Local nValorTot2 := 0
	Local nValorTotC := 0
	Local aArea		 := GetArea()
	Local aSaveRows  := FwSaveRows(oModel)
	
	//busca os componentes que é de resultado
	For nX := 1 to oModelN7C:Length()
		oModelN7C:GoLine( nX )
		
		if  oModelN7C:GetValue( "N7C_TPCALC") == "R" // é resultado - calcula os valores   
			
			if oModelN7C:GetValue( "N7C_VLORIG") == oModelN7C:GetValue( "N7C_VLRCOM") .and. oModelN7C:GetValue( "N7C_COMAJU") == "0" //foi editado os valores
				//reset   
				nValor    := 0 
				nValor1   := 0
				nValor2   := 0
				nValorC   := 0			
				cUmComRes := oModelN7C:GetValue("N7C_UMCOM")
				dTaxaCom  := oModelN7C:GetValue("N7C_TXCOTA")
				nMoedaCom := oModelN7C:GetValue("N7C_MOEDCO")
				
				//procurar na N75 - verificar necessidade de converter os valores (Uniddade de Medida e Moeda)
				DbselectArea( "N75" )
				DbSetOrder( 1 )
				DbGoTop()
				If dbSeek( xFilial( "N75" ) +  oModelN7C:GetValue( "N7C_CODCOM") )
					While !N75->( EoF() ) .And. N75->( N75_FILIAL + N75_CODCOM ) == xFilial( "N75" ) + oModelN7C:GetValue( "N7C_CODCOM") 
						//seekline
						if oModelN7C:SeekLine( { {"N7C_CODCOM", N75->(N75_CODCOP)  } } )
							
							if !oModelN7C:IsDeleted() //pode ter uma regra q está removendo um componente
							
								//vamos colocar na unidade de medida do componente resultado
								nValorComp := Round(OGX700UMVL(oModelN7C:GetValue("N7C_VLRCOM"),oModelN7C:GetValue("N7C_UMCOM"),cUmComRes, cCodPro ) ,nDecCompon )
								
								nValorTot1 := Round(oModelN7C:GetValue("N7C_VLRUN1"), nDecCompon)
								
								nValorTot2 := Round(oModelN7C:GetValue("N7C_VLRUN2"), nDecCompon)	
																					
								nValorTotC := Round(oModelN7C:GetValue("N7C_VLTOTC"), nDecCompon) 
								
								//vamos aplicar a cotação
								if nMoedaCom <> oModelN7C:GetValue("N7C_MOEDCO")
									if oModelN7C:GetValue("N7C_MOEDCO") > 1 //moeda corrente
										nValorComp := Round(nValorComp * oModelN7C:GetValue("N7C_TXCOTA") ,nDecCompon )
										nValorTotC := Round(nValorTotC * oModelN7C:GetValue("N7C_TXCOTA") ,nDecCompon )
									else
										nValorComp := Round(nValorComp / oModelN7C:GetValue("N7C_TXCOTA") ,nDecCompon ) //retornamos na cotacao
										nValorTotC := Round(nValorTotC / oModelN7C:GetValue("N7C_TXCOTA") ,nDecCompon )
									endif
								endif
														
								nValor  += iif(N75->( N75_OPERAC) == "1", 1, -1) * nValorComp //fazer tratamento de unidade de medida
								nValor1 += iif(N75->( N75_OPERAC) == "1", 1, -1) * nValorTot1 //fazer tratamento de unidade de medida
								nValor2 += iif(N75->( N75_OPERAC) == "1", 1, -1) * nValorTot2 //fazer tratamento de unidade de medida
								nValorC += iif(N75->( N75_OPERAC) == "1", 1, -1) * nValorTotC //fazer tratamento de unidade de medida
							endif
							
						endif					
						//reecoloca na linha correta
						oModelN7C:GoLine( nX )
						
						N75->( dbSkip() )
					enddo
				endif
				
				//reecoloca na linha correta
				oModelN7C:GoLine( nX )				
				
				cTipPrc := Posicione("NK7", 1, FwXFilial("NK7")+oModelN7C:GetValue( "N7C_CODCOM") , "NK7_TIPPRC")
				
				//update da quantidade		
	            If cTipPrc $ "2"   //Negociado
	            	oModelN7C:LoadValue( "N7C_VLRCOM", nValor1) //atualiza os campos resultado
	            ElseIf cTipPrc $ "4" //Faturado
	            	oModelN7C:LoadValue( "N7C_VLRCOM", nValor2) //atualiza os campos resultado
	            Else //outros
	            	oModelN7C:LoadValue( "N7C_VLRCOM", nValor) //atualiza os campos resultado
	            EndIF
	            
			    oModelN7C:LoadValue( "N7C_VLRUN1", nValor1) //atualiza os campos resultado
			    oModelN7C:LoadValue( "N7C_VLRUN2", nValor2) //atualiza os campos resultado
			    oModelN7C:LoadValue( "N7C_VLTOTC", nValorC) //atualiza os campos resultado
			    oModelN7C:LoadValue( "N7C_VLORIG", oModelN7C:GetValue( "N7C_VLRCOM")) //atualiza os campos resultado	
			endif   
	    endif
	nExt nX
	
	RestArea(aArea)
	FwRestRows(aSaveRows)
		
return(.t.)


/*{Protheus.doc} OGX700CTRE
Calculo de Valores Reverso
@author jean.schulze
@since 06/02/2018
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
*/
function OGX700CTRE(oModel) //totalizar reverso de componentes
	Local oModelN7C  := oModel:GetModel( "N7CUNICO" )
	Local nX         := 0
	Local nValor     := 0
	Local nValor1    := 0
	Local nValor2    := 0
	Local nValorC    := 0
	Local cCodPro	 := oModel:GetValue("N79UNICO","N79_CODPRO") 
	Local cUmComRes  := ""
	Local dTaxaCom   := ""
	Local nMoedaCom  := 0
	Local nDecCompon := TamSx3('N7C_VLRCOM')[2]
	Local nValorComp := 0
	Local nValorTot1 := 0  
	Local nValorTot2 := 0
	Local nValorTotC := 0
	Local aArea		 := GetArea()
	Local aSaveRows  := FwSaveRows(oModel)
	Local nConverter := 0
			
	//busca os componentes que é de resultado
	For nX := 1 to oModelN7C:Length()
		oModelN7C:GoLine( nX )
		
		if  oModelN7C:GetValue( "N7C_TPCALC") == "R" // é resultado - calcula os valores   
			
			if oModelN7C:GetValue( "N7C_VLORIG") <> oModelN7C:GetValue( "N7C_VLRCOM") .or. oModelN7C:GetValue( "N7C_COMAJU") == "1" //foi editado os valores
			
				//reset
				nValor     := -1 * oModelN7C:GetValue( "N7C_VLRCOM") //atualiza os campos resultado 
				nValor1    := -1 * oModelN7C:GetValue( "N7C_VLRUN1") //atualiza os campos resultado
				nValor2    := -1 * oModelN7C:GetValue( "N7C_VLRUN2") //atualiza os campos resultado
				nValorC    := -1 * oModelN7C:GetValue( "N7C_VLTOTC") //atualiza os campos resultado	
				cCodComAju := ""		
				cUmComRes  := oModelN7C:GetValue("N7C_UMCOM")
				dTaxaCom   := oModelN7C:GetValue("N7C_TXCOTA")
				nMoedaCom  := oModelN7C:GetValue("N7C_MOEDCO")
				
				oModelN7C:LoadValue( "N7C_COMAJU", "1") //ajustado 
				
				DbselectArea( "N74" )
				DbSetOrder( 1 )
				DbGoTop()
				If dbSeek( xFilial( "N74" ) +  oModelN7C:GetValue( "N7C_CODCOM") )
					cCodComAju := N74->( N74_CODAJU)
				endif
				
				if !empty(cCodComAju) 
					//procurar na N75 - verificar necessidade de converter os valores (Uniddade de Medida e Moeda)
					DbselectArea( "N75" )
					DbSetOrder( 1 )
					DbGoTop()
					If dbSeek( xFilial( "N75" ) +  oModelN7C:GetValue( "N7C_CODCOM") )
						While !N75->( EoF() ) .And. N75->( N75_FILIAL + N75_CODCOM ) == xFilial( "N75" ) + oModelN7C:GetValue( "N7C_CODCOM") 
							
							if cCodComAju <> N75->(N75_CODCOP)
								//seekline
								if oModelN7C:SeekLine( { {"N7C_CODCOM", N75->(N75_CODCOP)  } } )
									
									if !oModelN7C:IsDeleted() //pode ter uma regra q está removendo um componente
									
										//vamos colocar na unidade de medida do componente resultado
										nValorComp := Round(OGX700UMVL(oModelN7C:GetValue("N7C_VLRCOM"),oModelN7C:GetValue("N7C_UMCOM"),cUmComRes, cCodPro ) ,nDecCompon )
										
										nValorTot1 := Round(oModelN7C:GetValue("N7C_VLRUN1"), nDecCompon)
										
										nValorTot2 := Round(oModelN7C:GetValue("N7C_VLRUN2"), nDecCompon)	
																							
										nValorTotC := Round(oModelN7C:GetValue("N7C_VLTOTC"), nDecCompon) 
										
										//vamos aplicar a cotação
										if nMoedaCom <> oModelN7C:GetValue("N7C_MOEDCO")
											if oModelN7C:GetValue("N7C_MOEDCO") > 1 //moeda corrente
												nValorComp := Round(nValorComp * oModelN7C:GetValue("N7C_TXCOTA") ,nDecCompon )
												nValorTotC := Round(nValorTotC * oModelN7C:GetValue("N7C_TXCOTA") ,nDecCompon )
											else
												nValorComp := Round(nValorComp / oModelN7C:GetValue("N7C_TXCOTA") ,nDecCompon ) //retornamos na cotacao
												nValorTotC := Round(nValorTotC / oModelN7C:GetValue("N7C_TXCOTA") ,nDecCompon )
											endif
										endif
																
								  		nValor  += iif(N75->( N75_OPERAC) == "1", 1, -1) * nValorComp //fazer tratamento de unidade de medida
										nValor1 += iif(N75->( N75_OPERAC) == "1", 1, -1) * nValorTot1 //fazer tratamento de unidade de medida
										nValor2 += iif(N75->( N75_OPERAC) == "1", 1, -1) * nValorTot2 //fazer tratamento de unidade de medida
										nValorC += iif(N75->( N75_OPERAC) == "1", 1, -1) * nValorTotC //fazer tratamento de unidade de medida
									endif
									
								endif					
								//reecoloca na linha correta
								oModelN7C:GoLine( nX )
							else 
								//informa o operador do mesmo(está somando ou subtraindo)
								nConverter := iif(N75->( N75_OPERAC) == "1", -1, 1) 							
							endif
							N75->( dbSkip() )
						enddo
					endif
					
					//reecoloca na linha do componente de ajuste
					if oModelN7C:SeekLine( { {"N7C_CODCOM", cCodComAju  } } )	
						oModelN7C:LoadValue( "N7C_COMAJU", "1") //atualiza os campos do componente de ajuste
						if nMoedaCom <> oModelN7C:GetValue("N7C_MOEDCO")
							if oModelN7C:GetValue("N7C_MOEDCO") > 1 //moeda corrente
								nValor := Round(nValor / oModelN7C:GetValue("N7C_TXCOTA") ,nDecCompon )
							else
								nValor := Round(nValor * oModelN7C:GetValue("N7C_TXCOTA") ,nDecCompon ) //retornamos na cotacao
							endif
						endif
						oModelN7C:LoadValue( "N7C_VLRCOM", nConverter * Round(OGX700UMVL(nValor,cUmComRes,oModelN7C:GetValue("N7C_UMCOM"), cCodPro ) ,nDecCompon ) ) //atualiza os campos resultado
			            oModelN7C:LoadValue( "N7C_VLRUN1", nConverter * nValor1) //atualiza os campos do componente de ajuste
					    oModelN7C:LoadValue( "N7C_VLRUN2", nConverter * nValor2) //atualiza os campos resultado
					    oModelN7C:LoadValue( "N7C_VLTOTC", nConverter * nValorC) //atualiza os campos resultado
					else //não encontrou o componente de ajuste - 
						RestArea(aArea)
						FwRestRows(aSaveRows)
						return .f.
					endif
				    
			    endif
		    endif	
		    
		 endif
	nExt nX
	
	RestArea(aArea)
	FwRestRows(aSaveRows)
		
return(.t.)


/*{Protheus.doc} OGX700RPLI
Replicação de dados do componente
@author jean.schulze
@since 08/11/2017
@version undefined
@param oModel, object, descricao
@param cIDField, characters, descricao
@param xValue, , descricao
@param cCodComp, characters, descricao
@type function
*/
Function OGX700RPLI(oModel, cIDField, xValue, cCodComp)
	Local oModelN79   := oModel:getModel("N79UNICO")
	Local oModelN7A   := oModel:getModel("N7AUNICO")
	Local oModelN7C   := oModel:getModel("N7CUNICO")
	Local nLinhaAtual := oModelN7A:GetLine()
	Local aSaveLines  := FWSaveRows()
	Local nX          := 1 //start variable
	Local lOk		  := .F.
	
	//não realizamos a copia quando é quantidade e preço
	if cIDField == "N7C_QTAFIX" .and. oModelN79:GetValue("N79_FIXAC") == "1" //preço
		return .t.
    elseif oModelN7C:GetValue("N7C_TPCALC") == "M" // Tratamento para não replicar componentes de multa, verificação de reforço
        return .t.		
	endif
	
	//aplica os componentes a todas as cadências
	while nX <= oModelN7A:Length() 
		oModelN7A:GoLine( nX )	
		if !oModelN7A:IsDeleted() .and. nLinhaAtual <> nX
			if oModelN7A:GetValue('N7A_USOFIX') == 'LBNO'
				oModelN7A:SetValue('N7A_USOFIX', 'LBOK')
				lOk	:= .T.
			endif
		    //posiciona no componente relativo
			if !oModelN7C:IsDeleted()  
				if oModelN7C:SeekLine( { {"N7C_CODCOM", cCodComp } } ) //preço negociado
					oModelN7C:SetValue(cIDField,xValue) 
				else
					return(.f.)
				endif
			endif
			if lOk
				oModelN7A:SetValue('N7A_USOFIX', 'LBNO')
				lOk := .F.	
			endif				
		endif
		nX++		
	endDo	
	
	FWRestRows(aSaveLines)	
	
return .t.


/*{Protheus.doc} OGX700TPCL
Trata tipo de cliente, retornando os dados virtuais do mesmo.
@author jean.schulze
@since 29/01/2018
@version 1.0
@return ${return}, ${return_description}
@param cTpNgc, characters, descricao
@param cTpCont, characters, descricao
@param cCodEnt, characters, descricao
@param cLojEnt, characters, descricao
@param nCampo, numeric, 1 = "Estado", 2 = "Cidade", 3 = "País"
@type function
*/
Function OGX700TPCL(cTpNgc, cTpCont, cCodEnt, cLojEnt, nCampo)
	Local cRetorno := " "
	Local aCampos  := {{"A1_EST", "A1_MUN", "A1_PAIS"}, {"A2_EST", "A2_MUN", "A2_PAIS"}, {"US_EST", "US_MUN", "US_PAIS"}}
	
	if cTpCont == "2" //Prospect
		cRetorno := Posicione("SUS",1,FwxFilial("SUS") + cCodEnt+cLojEnt , aCampos[3][nCampo]	) 
	elseif cTpCont <> "3" //Entidade 
		DbSelectArea("NJ0")
		DbSetOrder(1)
		If DbSeek(xFilial("NJ0")+cCodEnt+cLojEnt)
			if cTpNgc == "1" //Compras - fornecedor
				cRetorno := Posicione("SA2",1,FwxFilial("SA2") + NJ0->(NJ0_CODFOR) + NJ0->(NJ0_LOJFOR), aCampos[2][nCampo]	) 
			else //vendas - cliente
				cRetorno := Posicione("SA1",1,FwxFilial("SA1") + NJ0->(NJ0_CODCLI) + NJ0->(NJ0_LOJCLI), aCampos[1][nCampo]	) 
			endif
		EndIf			
	Endif
	
return cRetorno


/**********************************************************************************
*********************TRATAMENTOS DE FIXAÇÂO / CANCELAMENTOS ***********************
/**********************************************************************************/

/*{Protheus.doc} OGX700VNGA
verfica se existe um negócio para o contrato "trabalhando"
@author jean.schulze
@since 02/10/2017
@version undefined
@param cFilCtr, characters, descricao
@param cCodCtr, characters, descricao
@type function
*/
function OGX700VNGA(cFilCtr, cCodCtr, cTipo)
 	Local cRet      := ""
 	Local cAliasN79 := GetNextAlias()
	
	BeginSql Alias cAliasN79

		SELECT N79_CODNGC
	  	  FROM %Table:N79% N79 
		WHERE N79.%notDel%
		  AND N79.N79_FILIAL = %exp:cFilCtr% 
		  AND N79.N79_CODCTR = %exp:cCodCtr% 
	 	  AND N79.N79_TIPO   = %exp:cTipo% //fixação ou cancelamento
	 	  AND (N79.N79_STATUS <> "3" AND N79.N79_STATUS <> "4")  //diferente de aprovado ou rejeitado
	 	  			         		           
	EndSQL
	
	DbselectArea( cAliasN79 )
	DbGoTop()
	if ( cAliasN79 )->( !Eof() )
	  	cRet :=  ( cAliasN79 )->N79_CODNGC//existe fixação pendente
	Endif
	( cAliasN79 )->( dbCloseArea() )
return cRet

/*{Protheus.doc} OGX700TNN8
Verfica se todas fixações de preço já foram efetuadas
@author jean.schulze
@since 02/10/2017
@version undefined
@param cFilNgc, characters, descricao
@param cCodCtr, characters, descricao
@param cCodCad, characters, descricao
@type function
*/
Function OGX700TNN8(cFilNgc, cCodCtr, cCodCad)
	Local cAliasNN8 := GetNextAlias()
	Local nQtdFix   := 0
	
	//trazer o que já foi aprorpriado -  verifciaçao de saldos etc - só salva no N7o quando se trata de um negócio de fixação de preço
	//não esquecer das que estao trabalhando.
	BeginSql Alias cAliasNN8

		SELECT NN8.NN8_FILIAL, NN8.NN8_CODCTR, NN8.NN8_CODCAD, SUM(NN8_QTDFIX) NN8_QTDFIX
	  	  FROM %Table:NN8% NN8 
		WHERE NN8.%notDel%
		  AND NN8.NN8_FILIAL = %exp:cFilNgc% 
		  AND NN8.NN8_CODCTR = %exp:cCodCtr% 
		  AND NN8.NN8_CODCAD = %exp:cCodCad% 		 		 
        GROUP BY NN8.NN8_FILIAL, NN8.NN8_CODCTR, NN8.NN8_CODCAD      
				         		           
	EndSQL
	
	DbselectArea( cAliasNN8 )
	DbGoTop()
	if ( cAliasNN8 )->( !Eof() )
	 	
	 	nQtdFix   := ( cAliasNN8 )->NN8_QTDFIX
		
		( cAliasNN8 )->( dbSkip() )
	Endif
	
	( cAliasNN8 )->( dbCloseArea() )
		
return nQtdFix

/*{Protheus.doc} OGX700N79S
Obtem a ultima  versão utilizada
@author jean.schulze
@since 25/10/2017
@version undefined
@param cFilNgc, characters, descricao
@param cCodNgc, characters, descricao
@type function
*/
Function OGX700N79S(cFilNgc, cCodNgc)
	Local cAliasN79 := GetNextAlias()
	Local nSeqNgc   := 0
		
	BeginSql Alias cAliasN79

		SELECT CAST(N79.N79_VERSAO as int) AS VERSAO, N79.N79_VERSAO
	  	  FROM %Table:N79% N79
		WHERE N79.%notDel%
		  AND N79.N79_FILIAL = %exp:cFilNgc% 
		  AND N79.N79_CODNGC = %exp:cCodNgc% 
		ORDER BY VERSAO DESC	 		         		           
	EndSQL
	
	DbselectArea( cAliasN79 )
	DbGoTop()
	if ( cAliasN79 )->( !Eof() )
	 	
	 	nSeqNgc   := VAL(( cAliasN79 )->N79_VERSAO)
		
		( cAliasN79 )->( dbSkip() )
	Endif
	
	( cAliasN79 )->( dbCloseArea() )
		
return nSeqNgc

/*{Protheus.doc} OGX700NN8S
Retorna a ultima sequencia usada na nn8
@author jean.schulze
@since 02/10/2017
@version undefined
@param cFilNgc, characters, descricao
@param cCodCtr, characters, descricao
@param cCodCad, characters, descricao
@type function
*/
Function OGX700NN8S(cFilNgc, cCodCtr, cCodCad)
	Local cAliasNN8 := GetNextAlias()
	Local nSeqFix   := 0
		
	BeginSql Alias cAliasNN8

		SELECT NN8.NN8_ITEMFX
	  	  FROM %Table:NN8% NN8 
		WHERE NN8.%notDel%
		  AND NN8.NN8_FILIAL = %exp:cFilNgc% 
		  AND NN8.NN8_CODCTR = %exp:cCodCtr% 
		  //AND NN8.NN8_CODCAD = %exp:cCodCad% 	
		ORDER BY  NN8_ITEMFX DESC	 		         		           
	EndSQL
	
	DbselectArea( cAliasNN8 )
	DbGoTop()
	if ( cAliasNN8 )->( !Eof() )
	 	
	 	nSeqFix   := VAL(( cAliasNN8 )->NN8_ITEMFX)
		
		( cAliasNN8 )->( dbSkip() )
	Endif
	
	( cAliasNN8 )->( dbCloseArea() )
		
return nSeqFix


/*{Protheus.doc} OGX700N7MS
Retorna a ultima sequencia usada na N7M
@author jean.schulze
@since 02/10/2017
@version undefined
@param cFilNgc, characters, descricao
@param cCodCtr, characters, descricao
@param cCodCad, characters, descricao
@param cCodComp, characters, descricao
@type function
*/
Function OGX700N7MS(cFilNgc, cCodCtr, cCodCad, cCodComp)
	Local cAliasN7M := GetNextAlias()
	Local nSeqFix   := 0
		
	
	//trazer o que já foi aprorpriado - somente vai permitir um negócio ativo por vez!
	BeginSql Alias cAliasN7M

		SELECT N7M_SEQFIX 
	  	  FROM %Table:N7M% N7M 
		WHERE N7M.%notDel%
		  AND N7M.N7M_FILIAL = %exp:cFilNgc% 
		  AND N7M.N7M_CODCTR = %exp:cCodCtr% 
		  AND N7M.N7M_CODCAD = %exp:cCodCad% 	
		  AND N7M.N7M_CODCOM = %exp:cCodComp% 			 		 
        ORDER BY  N7M_SEQFIX DESC	 		   
				         		           
	EndSQL
	
	DbselectArea( cAliasN7M )
	DbGoTop()
	if ( cAliasN7M )->( !Eof() )
	 	
	 	nSeqFix := VAL(( cAliasN7M )->N7M_SEQFIX)
		
		( cAliasN7M )->( dbSkip() )
	Endif
	
	( cAliasN7M )->( dbCloseArea() )
		
return nSeqFix

/*{Protheus.doc} OGX700SLDC
Devolve a quantidade do componente disponível
@author jean.schulze
@since 25/10/2017
@version undefined
@param cFilNgc, characters, descricao
@param cCodNgc, characters, descricao
@param cVersao, characters, descricao
@param cCodCad, characters, descricao
@param cCodComp, characters, descricao
@type function
*/
Function OGX700SLDC(cFilNgc, cCodNgc, cVersao, cCodCad, cCodComp)
	Local cAliasN7M := GetNextAlias()
	Local nQtdFix   := 0
	Local cFiltro   := ""
	
	Default cCodComp :=  ""
	
	if !empty(cCodComp)
		cFiltro := "AND N7M.N7M_CODCOM = '" + cCodComp + "'"	
	endif
	
	cFiltro := "%" + cFiltro + "%"	
	
	BeginSql Alias cAliasN7M

		SELECT N7M_QTDSLD 
	  	  FROM %Table:N7M% N7M 
		WHERE N7M.%notDel%
		  %exp:cFiltro%		
		  AND N7M.N7M_FILIAL = %exp:cFilNgc% 
		  AND N7M.N7M_CODNGC = %exp:cCodNgc% 
		  AND N7M.N7M_VERSAO = %exp:cVersao% 
		  AND N7M.N7M_CODCAD = %exp:cCodCad% 				         		           
	EndSQL
	
	DbselectArea( cAliasN7M )
	DbGoTop()
	if ( cAliasN7M )->( !Eof() )
	 	
	 	nQtdFix := ( cAliasN7M )->N7M_QTDSLD
		
		( cAliasN7M )->( dbSkip() )
	Endif
			
	( cAliasN7M )->( dbCloseArea() )
		
return nQtdFix

/*{Protheus.doc} OGX700SLDC
Devolve a quantidade do componente disponível por contrato
@author jean.schulze
@since 25/10/2017
@version undefined
@param cFilNgc, characters, descricao
@param cCodNgc, characters, descricao
@param cVersao, characters, descricao
@param cCodCad, characters, descricao
@param cCodComp, characters, descricao
@type function
*/
Function OGX700SDCC(cFilNgc, cCodCtr, cCodCad, cCodComp)
	Local cAliasN7M := GetNextAlias()
	Local nQtdFix   := 0
	Local cFiltro   := ""
	
	Default cCodComp :=  ""
	
	if !empty(cCodComp)
		cFiltro := "AND N7M.N7M_CODCOM = '" + cCodComp + "'"	
	endif
	
	cFiltro := "%" + cFiltro + "%"	
	
	BeginSql Alias cAliasN7M

		SELECT SUM(N7M_QTDSLD) AS N7M_QTDSLD, N7M_CODCOM 
	  	  FROM %Table:N7M% N7M 
		WHERE N7M.%notDel%
		  %exp:cFiltro%		
		  AND N7M.N7M_FILIAL = %exp:cFilNgc% 
		  AND N7M.N7M_CODCTR = %exp:cCodCtr% 
		  AND N7M.N7M_CODCAD = %exp:cCodCad% 				         		           
		  GROUP BY N7M_CODCOM
		  ORDER BY N7M_QTDSLD DESC

	EndSQL
	
	DbselectArea( cAliasN7M )
	DbGoTop()
	 	
	nQtdFix := ( cAliasN7M )->N7M_QTDSLD
		
	( cAliasN7M )->( dbCloseArea() )
		
return nQtdFix

/*{Protheus.doc} OGX700SLDP
Devolve a quantidade disponível da negociação.
@author jean.schulze
@since 25/10/2017
@version undefined
@param cFilNgc, characters, descricao
@param cCodNgc, characters, descricao
@param cVersao, characters, descricao
@param cCodCad, characters, descricao
@type function
*/
Function OGX700SLDP(cFilNgc, cCodNgc, cVersao, cCodCad)
	Local cAliasNN8 := GetNextAlias()
	Local nQtdFix   := 0
		
	BeginSql Alias cAliasNN8

		SELECT NN8_QTDFIX, NN8_QTDENT
	  	  FROM %Table:NN8% NN8 
		WHERE NN8.%notDel%
		  AND NN8.NN8_FILIAL = %exp:cFilNgc% 
		  AND NN8.NN8_CODNGC = %exp:cCodNgc%
		  AND NN8.NN8_VERSAO = %exp:cVersao% 	 
		  AND NN8.NN8_CODCAD = %exp:cCodCad% 		 				         		           
	EndSQL
	
	DbselectArea( cAliasNN8 )
	DbGoTop()
	if ( cAliasNN8 )->( !Eof() )
	 	
	 	nQtdFix := ( cAliasNN8 )->NN8_QTDFIX /*- ( cAliasNN8 )->NN8_QTDENT*/ //saldo do que não foi vinculado
		
		( cAliasNN8 )->( dbSkip() )
	Endif
	
	( cAliasNN8 )->( dbCloseArea() )
		
return nQtdFix

/*{Protheus.doc} OGX700SDCT
Devolve a quantidade disponível do contrato.
@author niara.caetano
@since 23/11/2017
@version undefined
@param cFilNgc, characters, descricao
@param cCodCtr, characters, descricao
@type function
*/
Function OGX700SDCT(cFilNgc, cCodCtr)
	Local cAliasNN8 := GetNextAlias()
	Local nQtdSld   := 0
		
	BeginSql Alias cAliasNN8

		SELECT SUM(NN8_QTDFIX) NN8_QTDFIX, 
		       SUM(NN8_QTDENT) NN8_QTDENT
	  	  FROM %Table:NN8% NN8 
		 WHERE NN8.%notDel%
		   AND NN8.NN8_FILIAL = %exp:cFilNgc% 
		   AND NN8.NN8_CODCTR = %exp:cCodCtr%
	EndSQL
	
	DbselectArea( cAliasNN8 )
	DbGoTop()
	if ( cAliasNN8 )->( !Eof() )
	 	
	 	nQtdSld := ( cAliasNN8 )->NN8_QTDFIX /*- ( cAliasNN8 )->NN8_QTDENT*/ //saldo do que não foi vinculado
		
		( cAliasNN8 )->( dbSkip() )
	Endif
	
	( cAliasNN8 )->( dbCloseArea() )
		
return nQtdSld


/*{Protheus.doc} OGX700TN7M
@author jean.schulze
@since 25/09/2017
@version undefined
@param cFilNgc, characters, descricao
@param cCodCtr, characters, descricao
@param cCodCad, characters, descricao
@param cCodComp, characters, descricao
@type function
*/
Function OGX700TN7M(cFilNgc, cCodCtr, cCodCad, cCodComp)
	Local cAliasN7M := GetNextAlias()
	Local nValorFix := 0
	Local nQtdFix   := 0
	
	//Somente Buscar os Componentes com Fixações Com Saldos
	BeginSql Alias cAliasN7M

		SELECT N7M_FILIAL, N7M_CODCTR, N7M.N7M_CODCOM, N7M.N7M_CODCAD, SUM(N7M_QTDSLD) N7M_QTDSLD, SUM(N7M_VALOR * N7M_QTDSLD ) N7M_VALOR  
	  	  FROM %Table:N7M% N7M 
		WHERE N7M.%notDel%
		  AND N7M.N7M_FILIAL = %exp:cFilNgc% 
		  AND N7M.N7M_CODCTR = %exp:cCodCtr% 
		  AND N7M.N7M_CODCAD = %exp:cCodCad% 	
		  AND N7M.N7M_CODCOM = %exp:cCodComp% 	
		  AND N7M.N7M_QTDSLD > 0			 		 
        GROUP BY N7M_FILIAL, N7M_CODCTR, N7M.N7M_CODCAD, N7M.N7M_CODCOM       
				         		           
	EndSQL
	
	DbselectArea( cAliasN7M )
	DbGoTop()
	if ( cAliasN7M )->( !Eof() )
	 	
	 	nValorFix := ( cAliasN7M )->N7M_VALOR / ( cAliasN7M )->N7M_QTDSLD
	 	nQtdFix   := ( cAliasN7M )->N7M_QTDSLD
		
		( cAliasN7M )->( dbSkip() )
	Endif
	
	( cAliasN7M )->( dbCloseArea() )
		
return {nValorFix, nQtdFix}

/*{Protheus.doc} OGX700QLMT
Retorna a quantidade disponível para a fixação.
@author jean.schulze
@since 17/10/2017
@version undefined
@param cFilNgc, characters, descricao
@param cCodCtr, characters, descricao
@param cCodCad, characters, descricao
@type function
*/
Function OGX700QLMT(cFilNgc, cCodCtr, cCodCad, cCodNeg, cVersao)
	Local nQtdFixMax  := 0
	
	DbselectArea( "NNY" )
	NNY->(DbGoTop())
	NNY->(DbSetOrder(1))
	if NNY->(DbSeek(cFilNgc+cCodCtr+cCodCad))
		
		//busca a quantidade a ser fixada de preço
		nQtdFixMax := NNY->NNY_QTDINT - (OGX700TNN8(cFilNgc, cCodCtr, cCodCad) + OGX700MFIX(cFilNgc, cCodCtr, cCodCad, cCodNeg, cVersao))
		
	endif
	
	NNY->( dbCloseArea() )
			
return nQtdFixMax

/*{Protheus.doc} OGX700SDCQ
Retorna saldo disponível cancelamento quantidade
@author jean.schulze
@since 17/10/2017
@version undefined
@param cFilNgc, characters, descricao
@param cCodCtr, characters, descricao
@param cCodCad, characters, descricao
@type function
*/
Function OGX700SDCQ(cFilNgc, cCodCtr, cCodCad)
	Local nQtdFixMax  := 0
	
	DbselectArea( "NNY" )
	NNY->(DbGoTop())
	NNY->(DbSetOrder(1))
	if NNY->(DbSeek(cFilNgc+cCodCtr+cCodCad))
		
		//busca a quantidade a ser fixada de preço
		nQtdFixMax := NNY->NNY_QTDINT - OGX700TNN8(cFilNgc, cCodCtr, cCodCad) - OGX700SDCC(cFilNgc, cCodCtr, cCodCad)
		
	endif
	
	NNY->( dbCloseArea() )
			
return nQtdFixMax

/*{Protheus.doc} OGX700QN7M
Retorna a quantidade disponível para fixação de componente.
@author jean.schulze
@since 17/10/2017
@version undefined
@param cFilNgc, characters, descricao
@param cCodCtr, characters, descricao
@param cCodCad, characters, descricao
@param cCodComp, characters, descricao
@type function
/*/
Function OGX700QN7M(cFilNgc, cCodCtr, cCodCad, cCodComp)
	Local cAliasN7M := GetNextAlias()
	Local nQtdFix   := 0
	
	//buscar o total fixado
	BeginSql Alias cAliasN7M

		SELECT N7M_FILIAL, N7M_CODCTR, N7M.N7M_CODCOM, N7M.N7M_CODCAD, SUM(N7M_QTDFIX) N7M_QTDFIX 
	  	  FROM %Table:N7M% N7M 
		WHERE N7M.%notDel%
		  AND N7M.N7M_FILIAL = %exp:cFilNgc% 
		  AND N7M.N7M_CODCTR = %exp:cCodCtr% 
		  AND N7M.N7M_CODCAD = %exp:cCodCad% 	
		  AND N7M.N7M_CODCOM = %exp:cCodComp% 			 		 
        GROUP BY N7M_FILIAL, N7M_CODCTR, N7M.N7M_CODCAD, N7M.N7M_CODCOM       
				         		           
	EndSQL
	
	DbselectArea( cAliasN7M )
	DbGoTop()
	if ( cAliasN7M )->( !Eof() )
	 	
	 	nQtdFix   := ( cAliasN7M )->N7M_QTDFIX
		
		( cAliasN7M )->( dbSkip() )
	Endif
	
	( cAliasN7M )->( dbCloseArea() )
		
return nQtdFix

/*{Protheus.doc} OGX700FIXA
Tratamento para gravação da fixação no contrato. 
@author jean.schulze
@since 02/10/2017
@version undefined
@param oModel, object, descricao
@type function
*/
function OGX700FIXA(oModel)
	Local lRet := .t.
	Local oModelN79 := oModel:GetModel("N79UNICO")
	
	If oModelN79:GetValue("N79_FIXAC") == "1" //fixação de preço
		//verifica se tem componente fixado - componentes fixados N7M e N7O- Negócios fixos X componentes fixos
		lRet := OGX700CPFX(oModel,oModelN79:GetValue("N79_CODCTR"))
		//verifica se é fixação de preço - NN8, NKA e N7N
		if lRet
			lRet := OGX700PRFX(oModel,oModelN79:GetValue("N79_CODCTR")) 
		endif	
	else
		//verifica se tem componente fixado - componentes fixados N7M
		 lRet := OGX700CPFX(oModel,oModelN79:GetValue("N79_CODCTR")) 
	endif 		
	
return lRet

/*{Protheus.doc} OGX700CANC
Proceesa o0 cancelamento de fixações
@author jean.schulze
@since 25/10/2017
@version undefined
@param oModel, object, descricao
@type function
*/
Function OGX700CANC(oModel)
	Local lRet       := .t.
	Local oModelN79  := oModel:GetModel("N79UNICO")
	Local oModelN7A  := oModel:GetModel("N7AUNICO")
	Local oModelN7C  := oModel:GetModel("N7CUNICO")
	Local nA	     := 1
	Local nB	     := 1
	Local nQtdCancel := 0
	Local nQtdAbater := 0
	Local aMultaRec  := {}   // indica que é uma multa a receber pela empresa ( Cliente irá pagar )
	Local aMultaPag  := {}   // indica que é uma multa a pagar	 pela empresa ( Cliente irá Receber )
	Local nPorcApro  := 1
	Local nPos       := 0

	//verifica se é cancelamento de fixação ou de contrato
	//cancelamento de contrato, procedimento para subtratir o contrato
	
	if oModelN79:GetValue("N79_TPCANC") == '2' //quantidade
		nA := 1
		nTotal := 0
		while nA <= oModelN7A:Length() //percorre as cadencias 
			oModelN7A:GoLine(nA)
			
			nTotal += oModelN7A:GetValue("N7A_QTDINT")

			For nB := 1 to oModelN7C:Length() 
				oModelN7C:GoLine( nB )

				//Apropria as multas ( Atenção como negocio, não devemos ter multas a Pagar e a Receber no mesmo negocio de cancelamento)
				IF oModelN7C:GetValue("N7C_TPCALC") = "M" //Multa
					//verifica se a quantidade e valor foram preenchidos - vamos ter multa
					IF oModelN7C:GetValue("N7C_VLTOTC") > 0
						DbselectArea( "NK7" )
						///NK7->(DbGoTop())
						NK7->(DbSetOrder(1)) //busca por contrato
		
						IF NK7->(DbSeek(FwXfilial("NK7")+oModelN7C:GetValue("N7C_CODCOM")))
							Do Case
								Case NK7->NK7_GERMUL == "2" //Titulo a receber
								//verifica se a multa já existe
									IF (nPos := ASCAN(aMultaRec, {|x| AllTrim(x[1]) == oModelN7C:GetValue("N7C_CODCOM")}) ) > 0 //existe a multa
										aMultaRec[nPos][3] += oModelN7C:GetValue("N7C_VLTOTC")
									Else
										aAdd(aMultaRec, {oModelN7C:GetValue("N7C_CODCOM"), NK7->NK7_GERMUL , oModelN7C:GetValue("N7C_VLTOTC"), NK7->NK7_MPREFI, NK7->NK7_MTIPO, NK7->NK7_MNATUR, oModelN7C:GetValue("N7C_MOEDCO") })
									EndIF
								Case NK7->NK7_GERMUL == "1" //Titulo a receber
									//verifica se a multa já existe
									IF (nPos := ASCAN(aMultaPag, {|x| AllTrim(x[1]) == oModelN7C:GetValue("N7C_CODCOM")}) ) > 0 //existe a multa
										aMultaPag[nPos][3] += oModelN7C:GetValue("N7C_VLTOTC")
									Else
										aAdd(aMultaPag, {oModelN7C:GetValue("N7C_CODCOM"), NK7->NK7_GERMUL , oModelN7C:GetValue("N7C_VLTOTC"), NK7->NK7_MPREFI, NK7->NK7_MTIPO, NK7->NK7_MNATUR, oModelN7C:GetValue("N7C_MOEDCO") })
									EndIF
							EndCase
						EndIF
					EndIF						
				EndIF
			next nB		
						
			nA ++																							
		endDo
		
		
	//cancelamento de fixação	
	elseif oModelN79:GetValue("N79_FIXAC") == "1" //se for preço     
		
		while nA <= oModelN7A:Length() //percorre as cadencias 

			oModelN7A:GoLine( nA )	

			If !oModelN7A:IsDeleted() .and. oModelN7A:GetValue( "N7A_USOFIX" ) <> "LBNO" .and.  oModelN7A:GetValue( "N7A_QTDINT" ) > 0 
				//cancela saldo da NN8
				DbselectArea( "NN8" )
				NN8->(DbGoTop())
				NN8->(DbSetOrder(3)) //CODNGC+VERSAO - consulta por negócio

				if NN8->(DbSeek(oModelN79:GetValue("N79_FILIAL")+oModelN79:GetValue("N79_NGCREL")+oModelN79:GetValue("N79_VRSREL") +oModelN7A:GetValue("N7A_CODCAD")))  

					//percorre os componentes da cadencia
					For nB := 1 to oModelN7C:Length() 
						oModelN7C:GoLine( nB )

						if oModelN7C:GetValue("N7C_TPCALC") $ "P|C" //Preço ou Custo

							//cancela e retorna saldo das N7M
							nQtdCancel := oModelN7A:GetValue("N7A_QTDINT")
							nQtdN7OAlo := 0 //quantidade alocada
							nCntN7OAlo := 0 //quantidade de registros
							nCntN7OIte := 1 //count de registros
							aLstN70New := {} //itens novos criados com a modificacao
							
							DbSelectArea("N7O")
							N7O->(DbGoTop())
							if N7O->(DbSeek(FwxFilial("N7O")+oModelN79:GetValue("N79_NGCREL")+oModelN79:GetValue("N79_VRSREL")+oModelN7A:GetValue("N7A_CODCAD")+oModelN7C:GetValue("N7C_CODCOM")))
								
								//faz as proporções
								while FwxFilial("N7O")+oModelN79:GetValue("N79_NGCREL")+oModelN79:GetValue("N79_VRSREL")+oModelN7A:GetValue("N7A_CODCAD")+oModelN7C:GetValue("N7C_CODCOM") == N7O->N7O_FILIAL+N7O->N7O_CODNGC+N7O->N7O_VERSAO+N7O->N7O_CODCAD+N7O->N7O_CODCOM .and. nQtdCancel > 0

									nQtdN7OAlo += N7O->N7O_QTDALO 
									nCntN7OAlo += 1
									
									N7O->(dbSkip())			
								enddo	
								
								if nQtdN7OAlo <> oModelN7A:GetValue("N7A_QTDINT")
									nPorcApro := ((100 / nQtdN7OAlo) * oModelN7A:GetValue("N7A_QTDINT") / 100)   
								else 
									nPorcApro := 1
								endif
								
								//reposiciona a tabela para recomeçar a leitura
								N7O->(DbGoTop())
								N7O->(DbSeek(FwxFilial("N7O")+oModelN79:GetValue("N79_NGCREL")+oModelN79:GetValue("N79_VRSREL")+oModelN7A:GetValue("N7A_CODCAD")+oModelN7C:GetValue("N7C_CODCOM")))
								
								//executa as proporções
								while FwxFilial("N7O")+oModelN79:GetValue("N79_NGCREL")+oModelN79:GetValue("N79_VRSREL")+oModelN7A:GetValue("N7A_CODCAD")+oModelN7C:GetValue("N7C_CODCOM") == N7O->N7O_FILIAL+N7O->N7O_CODNGC+N7O->N7O_VERSAO+N7O->N7O_CODCAD+N7O->N7O_CODCOM .and. nQtdCancel > 0
									
									//verifica o quantum deve ser abatido
									if nCntN7OAlo = nCntN7OIte
										if N7O->N7O_QTDALO > nQtdCancel
											nQtdAbater := nQtdCancel
										else
											nQtdAbater := N7O->N7O_QTDALO
										endif
									else //busca proporcional
										nQtdAbater := N7O->N7O_QTDALO * nPorcApro //busca a quantidade prorporcional ao uso da mesma
									endif
																		
									DbselectArea( "N7M" )
									N7M->(DbGoTop())
									N7M->(DbSetOrder(1)) //busca por contrato

									if N7M->(DbSeek(N7O->N7O_FILIAL+N7O->N7O_CODCTR+N7O->N7O_CODCAD+N7O->N7O_CODCOM+N7O->N7O_SEQFIX))

										Reclock("N7M", .F.)
										//verifica se quem criou a fixação foi o negócio de preço, ou se usou fixação de componente anterior
										if alltrim(N7O->N7O_CODNGC+N7O->N7O_VERSAO) <> alltrim(N7M->N7M_CODNGC+N7M->N7M_VERSAO)	 //precisamos retornar os saldos disponíveis		
											N7M->N7M_QTDSLD += nQtdAbater
											N7M->N7M_QTDALO -= nQtdAbater
										else //reset na quantidade - fixação própria
											N7M->N7M_QTDFIX -= nQtdAbater
											N7M->N7M_QTDALO -= nQtdAbater
										endif
										N7M->(MsUnlock())     // Destrava o registro																							

									else
										oModel:GetModel():SetErrorMessage( oModelN79:GetId(), , oModelN79:GetId(), "", "", STR0021, "", "") //"Ajuda"#"Não existe Componente com Saldo para apropriação. Verificar as fixações do componente."										
										return .f.
									endif	

									//remove valores N7N
									DbselectArea( "N7N" )
									N7N->(DbGoTop())
									N7N->(DbSetOrder(1)) //busca por contrato
									if N7N->(DbSeek(N7O->N7O_FILIAL+N7O->N7O_CODCTR+NN8->NN8_ITEMFX+N7O->N7O_CODCOM+N7O->N7O_SEQFIX))
										Reclock("N7N", .F.)
										N7N->N7N_QTDALO -= nQtdAbater
										N7N->(MsUnlock()) // Destrava o registro	
									else
										oModel:GetModel():SetErrorMessage( oModelN79:GetId(), , oModelN79:GetId(), "", "", STR0022, "", "") ////"Ajuda"# "Não existe Componente com Saldo para apropriação. Verificar relacionamento de Preços e Componentes."										
										return .f.
									endif		
									
									//reset N7O
									Reclock("N7O", .F.)
										N7O->N7O_QTDALO -= nQtdAbater
									N7O->(MsUnlock())     

									//apropria a variavel controladora
									nQtdCancel -= nQtdAbater 

									N7O->(dbSkip())								
								enddo	

							endif
						endif	
						
						//Apropria as multas ( Atenção como negocio, não devemos ter multas a Pagar e a Receber no mesmo negocio de cancelamento)
						IF oModelN7C:GetValue("N7C_TPCALC") = "M" //Multa
							//verifica se a quantidade e valor foram preenchidos - vamos ter multa
							IF oModelN7C:GetValue("N7C_VLTOTC") > 0
								DbselectArea( "NK7" )
								///NK7->(DbGoTop())
								NK7->(DbSetOrder(1)) //busca por contrato

								IF NK7->(DbSeek(FwXfilial("NK7")+oModelN7C:GetValue("N7C_CODCOM")))
									Do Case
										Case NK7->NK7_GERMUL == "2" //Titulo a receber
										//verifica se a multa já existe
										IF (nPos := ASCAN(aMultaRec, {|x| AllTrim(x[1]) == oModelN7C:GetValue("N7C_CODCOM")}) ) > 0 //existe a multa
											aMultaRec[nPos][3] += oModelN7C:GetValue("N7C_VLTOTC")
										Else
											aAdd(aMultaRec, {oModelN7C:GetValue("N7C_CODCOM"), NK7->NK7_GERMUL , oModelN7C:GetValue("N7C_VLTOTC"), NK7->NK7_MPREFI, NK7->NK7_MTIPO, NK7->NK7_MNATUR, oModelN7C:GetValue("N7C_MOEDCO") })
										EndIF
										Case NK7->NK7_GERMUL == "1" //Titulo a receber
										//verifica se a multa já existe
										IF (nPos := ASCAN(aMultaPag, {|x| AllTrim(x[1]) == oModelN7C:GetValue("N7C_CODCOM")}) ) > 0 //existe a multa
											aMultaPag[nPos][3] += oModelN7C:GetValue("N7C_VLTOTC")
										Else
											aAdd(aMultaPag, {oModelN7C:GetValue("N7C_CODCOM"), NK7->NK7_GERMUL , oModelN7C:GetValue("N7C_VLTOTC"), NK7->NK7_MPREFI, NK7->NK7_MTIPO, NK7->NK7_MNATUR, oModelN7C:GetValue("N7C_MOEDCO") })
										EndIF
									EndCase
								EndIF
							EndIF						
						EndIF

					next nB	
					
					//cria as pendencias
					if !OGX700PEND(oModel)
						return .f.
					endif
					
					//reset on NN8										
					Reclock("NN8", .F.)
						NN8->NN8_QTDFIX -= oModelN7A:GetValue("N7A_QTDINT") //verificar mais os campos que vamos utiliza.
					NN8->(MsUnlock())     // Destrava o registro																					
																		
				else
					oModel:GetModel():SetErrorMessage( oModelN79:GetId(), , oModelN79:GetId(), "", "", STR0023, "", "") //"Ajuda"#"Não existe Fixação de Preço Com Saldo Suficiente." 					
					return .f.
				endif					
				
			endif
			
			nA++
		enddo			
		
	else //componente
		//se for componente - cancela as N7M
			
		while nA <= oModelN7A:Length() //percorre as cadencias 
			
			oModelN7A:GoLine( nA )	
						
			If !oModelN7A:IsDeleted() .and. oModelN7A:GetValue( "N7A_USOFIX" ) <> "LBNO" 
			
				For nB := 1 to oModelN7C:Length() //percorre os componentes da cadencia
					oModelN7C:GoLine( nB )
										
					if oModelN7C:GetValue("N7C_QTAFIX") > 0  .and. oModelN7C:GetValue("N7C_TPCALC") $ "P|C" //Preço ou Custo //fixação e diferente de resultado
						 																				
						DbselectArea( "N7M" )
						N7M->(DbGoTop())
						N7M->(DbSetOrder(2)) //CODNGC+VERSAO - consulta por negócio
						
						if N7M->(DbSeek(oModelN79:GetValue("N79_FILIAL")+oModelN79:GetValue("N79_NGCREL")+oModelN79:GetValue("N79_VRSREL") +oModelN7A:GetValue("N7A_CODCAD")+oModelN7C:GetValue("N7C_CODCOM"))) .and.  N7M->N7M_QTDSLD >= oModelN7C:GetValue("N7C_QTAFIX")
																	
							Reclock("N7M", .F.)
								N7M->N7M_QTDSLD -= oModelN7C:GetValue("N7C_QTAFIX")
								N7M->N7M_QTDFIX -= oModelN7C:GetValue("N7C_QTAFIX")
	 						N7M->(MsUnlock())     // Destrava o registro																					
																				
						else
							oModel:GetModel():SetErrorMessage( oModelN79:GetId(), , oModelN79:GetId(), "", "", STR0021, "", "") //"Ajuda"#"Não existe Componente com Saldo para apropriação. Verificar as fixações do componente."							
							return .f.
						endif								
							
					endif
					
					//apropria as multas
					IF oModelN7C:GetValue("N7C_TPCALC") = "M" //Multa
						IF oModelN7C:GetValue("N7C_VLTOTC") > 0
							DbselectArea( "NK7" )
							///NK7->(DbGoTop())
							NK7->(DbSetOrder(1)) //busca por contrato

							IF NK7->(DbSeek(FwXfilial("NK7")+oModelN7C:GetValue("N7C_CODCOM")))
								Do Case
									Case NK7->NK7_GERMUL == "2" //Titulo a receber
									//verifica se a multa já existe
									IF (nPos := ASCAN(aMultaRec, {|x| AllTrim(x[1]) == oModelN7C:GetValue("N7C_CODCOM")}) ) > 0 //existe a multa
										aMultaRec[nPos][3] += oModelN7C:GetValue("N7C_VLTOTC")
									Else
										aAdd(aMultaRec, {oModelN7C:GetValue("N7C_CODCOM"), NK7->NK7_GERMUL , oModelN7C:GetValue("N7C_VLTOTC"), NK7->NK7_MPREFI, NK7->NK7_MTIPO, NK7->NK7_MNATUR, oModelN7C:GetValue("N7C_MOEDCO") })
									EndIF
									Case NK7->NK7_GERMUL == "1" //Titulo a receber
									//verifica se a multa já existe
									IF (nPos := ASCAN(aMultaPag, {|x| AllTrim(x[1]) == oModelN7C:GetValue("N7C_CODCOM")}) ) > 0 //existe a multa
										aMultaPag[nPos][3] += oModelN7C:GetValue("N7C_VLTOTC")
									Else
										aAdd(aMultaPag, {oModelN7C:GetValue("N7C_CODCOM"), NK7->NK7_GERMUL , oModelN7C:GetValue("N7C_VLTOTC"), NK7->NK7_MPREFI, NK7->NK7_MTIPO, NK7->NK7_MNATUR, oModelN7C:GetValue("N7C_MOEDCO") })
									EndIF
								EndCase
							EndIF
						EndIF						

					EndIF
					
				next nB	
			endif
			
			nA++
		enddo			
	endif
		
	//verifica se temos que criar as multas ( Em um mesmo Reg.Negocio, não podemos ter vr. de multa a receber e a pagar)
	if len(aMultaRec) > 0
		For nB := 1 to  len(aMultaRec) //percorre os componentes da cadencia
			if !OGX700MTRC(oModel, aMultaRec[nB])
				lRet := .f.
			endif
		next nB	
	ElseIF len(aMultaPag) > 0
		For nB := 1 to  len(aMultaPag) //percorre os componentes da cadencia
			if ! OGX700MTPG(oModel, aMultaPag[nB] )
				lRet := .f.
			endif
		next nB	
	EndIF

	If oModelN79:GetValue("N79_TPCANC") == '2' .and. lRet
		if OGX700QCTR(nTotal, oModel) = .f.
			return .f.
		endif	
	EndIf

	If !lRet
		Return .F.
	EndIf

return .t.

/*{Protheus.doc} OGX700MODF
Modifica Fixação.
@author jean.schulze
@since 24/09/2018
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
*/
function OGX700MODF(oModel)
	//cria o item de cancelamento
	if OGX700CANC(oModel)	
		//cria as novas fixações
		if OGX700FIXA(oModel)
			return .t.
		endif
	endif		
return .f.


/*{Protheus.doc} OGX700PEND
Cria as pendencias quando o contrato está fixo e é solicitado o cancelamento.
@author jean.schulze
@since 02/10/2018
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
*/
Function OGX700PEND(oModel)
	Local oModelN79  := oModel:GetModel("N79UNICO")
	Local oModelN7A  := oModel:GetModel("N7AUNICO")
	Local nQtdCancel := oModelN7A:GetValue("N7A_QTDINT") 
	Local cCodProd   := oModelN79:GetValue("N79_CODPRO")
	Local cAliasN8T  := ""
	Local cAliasDXI  := ""
	Local nQtdFatCan := 0 
	Local nQtdDebit  := 0
	Local aPendencia := {}
	Local aListN8T   := {}
	Local aListN8D   := {}
	Local aLstResN8D := {}
	Local nA         := 0
	Local nTotFatCan := 0
	Local nTotResCan := 0
	Local aFarInativ := {}
	Local nPos       := 0
	
	DbselectArea( "NN8" )
	NN8->(DbGoTop())
	NN8->(DbSetOrder(3)) //CODNGC+VERSAO - consulta por negócio

	if NN8->(DbSeek(oModelN79:GetValue("N79_FILIAL")+oModelN79:GetValue("N79_NGCREL")+oModelN79:GetValue("N79_VRSREL") +oModelN7A:GetValue("N7A_CODCAD")))  
		//verifica se a quantidade cancelada está associada e se está faturada
		if (NN8->NN8_QTDFIX - NN8->NN8_QTDENT) < nQtdCancel
			
			nQtdFatCan := nQtdCancel - (NN8->NN8_QTDFIX - NN8->NN8_QTDENT) //saldo que vamos ter que tirar de romaneios já emitidos
						
			//se estiver faturada verificar os romaneios que usaram a fixação
			cAliasN8T := GetNextAlias()
			BeginSql Alias cAliasN8T
				SELECT N8T_FILIAL, N8T_CODROM, N8T_ITEROM, N8T_QTDVNC, N8T_ITEMFX, N8T_SEQFIX , N8T_CODCAD, N8T_CODREG,  R_E_C_N_O_ REC_N8T  
				  FROM %Table:N8T% N8T                    
				 WHERE N8T.%notDel%
				   AND N8T.N8T_FILCTR  = %exp:NN8->NN8_FILIAL%
				   AND N8T.N8T_CODCTR  = %exp:NN8->NN8_CODCTR%
				   AND N8T.N8T_ITEMFX  = %exp:NN8->NN8_ITEMFX%
				   AND N8T.N8T_TIPPRC  = '1' //Preço Fixo 					    			 		   
			EndSQL 
		  	
		  	//verifica os valores de cotação utilizados -  N8T
		  	DbSelectArea( cAliasN8T )		
			(cAliasN8T)->( dbGoTop() )
			While .Not. (cAliasN8T)->( Eof( ) ) .and. nQtdFatCan > 0
			 	
			 	//cria array de pendencia
			 	aAdd( aPendencia, {(cAliasN8T)->N8T_FILIAL, (cAliasN8T)->N8T_CODROM, (cAliasN8T)->N8T_ITEROM, (cAliasN8T)->N8T_CODCAD, (cAliasN8T)->N8T_CODREG  } )
			 	
			 	//cria o array de N8D
			 	if (nPos := aScan( aListN8D, { |x| x[1] == (cAliasN8T)->N8T_SEQFIX } )) > 0
			 		aListN8D[nPos][2] += (cAliasN8T)->N8T_QTDVNC
			 	else
			 		aadd( aListN8D , {(cAliasN8T)->N8T_SEQFIX, (cAliasN8T)->N8T_QTDVNC})
			 	endif
			 	
			 	//ajusta a N8T
			 	aadd( aListN8T , (cAliasN8T)->REC_N8T)
			 	
			 	//ajusta a quantidade
			 	nQtdFatCan -= (cAliasN8T)->N8T_QTDVNC 
			 	  
				//cria as informações 
				(cAliasN8T)->( dbSkip() )				
			Enddo
			
		  	(cAliasN8T)->( dbCloseArea() )
			//update proporcional
		endif
		
		//ajusta a quantidade faturada conforme os dados
		for nA := 1 to len(aListN8D)
			//ajusta as apropriações				
			N8D->(dbSetOrder(2)) //N8D_FILIAL+N8D_CODCTR+N8D_ITEMFX+N8D_SEQVNC
			if N8D->(DbSeek(NN8->NN8_FILIAL + NN8->NN8_CODCTR + NN8->NN8_ITEMFX + aListN8D[nA][1]))
				RecLock('N8D',.f.)
					N8D->N8D_QTDFAT -= aListN8D[nA][2] //soma a quantidade
					nTotFatCan      += aListN8D[nA][2] 				
				N8D->(MsUnLock())				
			endif				
		next nA
		
		//corrige a informação na n8t
		for nA := 1 to len(aListN8T)
			//ajusta as apropriações				
			N8T->(dbGoTop()) //N8D_FILIAL+N8D_CODCTR+N8D_ITEMFX+N8D_SEQVNC
			N8T->(dbGoTo(aListN8T[nA]))
			if N8T->(RECNO()) == aListN8T[nA] // mesmo recno
				RecLock('N8T',.f.)
					N8T->N8T_TIPPRC := "2" //TROCA E COLOCA COMO A FIXAR
				N8T->(MsUnLock())				
			endif				
		next nA
					
		//cria as pendencias se nao tiver nenhuma para o romaneio
		for nA := 1 to len(aPendencia)
			//ajusta as apropriações				
			NC8->(dbSetOrder(1)) 
			if NC8->(DbSeek(aPendencia[nA][1] + aPendencia[nA][2] + aPendencia[nA][3]))
				if NC8->NC8_STATUS <> "1" /*Diferente de pendente*/ .or.  NC8->NC8_PENDEN == "2" /*Somente Cotação retroativa*/
					//se tiver em aprovação dar uma limpada na tabela de alçada
					RecLock('NC8',.f.)
						NC8->NC8_STATUS := "1" //pendente
						NC8->NC8_PENDEN := iif(NC8->NC8_PENDEN $ "2|3", "3", "1")
					NC8->(MsUnLock())
				endif	
			else
				//cria nova pendencia.
				dbSelectArea("NC8")
				dbSetOrder(1)
				If !dbSeek(aPendencia[nA][1]+aPendencia[nA][2]+aPendencia[nA][3])
					RecLock('NC8',.t.)
						NC8->NC8_FILIAL := aPendencia[nA][1] //filial do romaneio
						NC8->NC8_CODROM := aPendencia[nA][2] //código do romaneio
						NC8->NC8_ITEMRO := aPendencia[nA][3] //item romaneio
						NC8->NC8_FILCTR := NN8->NN8_FILIAL   //filial do contrato
						NC8->NC8_CODCTR := NN8->NN8_CODCTR   //Código do contrato
						NC8->NC8_CODCAD := aPendencia[nA][4] //Código da cadencia
						NC8->NC8_REGRA  := aPendencia[nA][5] //Código da regra  
						NC8->NC8_STATUS := "1" //status da pendencia  
						NC8->NC8_PENDEN := "1" //tipo de pendencia
					NC8->(MsUnLock())
				EndIf					
			endif				
		next nA
				
		//desapropria item na n8D
		if NN8->NN8_QTDFIX - NN8->NN8_QTDRES < nQtdCancel
		   
		   //verifica quanto temos q cancelar de fato	
		   nQtdCancel :=  nQtdCancel - (NN8->NN8_QTDFIX - NN8->NN8_QTDRES) //somente a sobra
		   	
		   if AGRTPALGOD(cCodProd) // se algodao
		   		
		   	   //primeiro remove o que está em romaneios DXI_FATURA == "2" + romaneios já selecionados
		   	   for nA := 1 to len(aPendencia)
		   	   	   cAliasDXI := GetNextAlias()
			   	   BeginSql Alias cAliasDXI
						SELECT DXI.R_E_C_N_O_ REC_DXI 
						  FROM %Table:N9D% N9D			 
						 INNER JOIN %Table:DXI% DXI ON DXI.DXI_FILIAL = N9D.N9D_FILIAL 
												   AND DXI.DXI_SAFRA  = N9D.N9D_SAFRA
				                                   AND DXI.DXI_ETIQ   = N9D.N9D_FARDO  
				                                   AND DXI.%notDel%      
						 WHERE N9D.%notDel%
						   AND N9D.N9D_FILORG = %exp:aPendencia[nA][1]% 
						   AND N9D.N9D_CODROM = %exp:aPendencia[nA][2]%
	                       AND N9D.N9D_ITEROM = %exp:aPendencia[nA][3]%
	                       AND N9D.N9D_CODCTR = %exp:NN8->NN8_CODCTR% 
	                       AND N9D.N9D_ITEETG = %exp:aPendencia[nA][4]%
	                       AND N9D.N9D_ITEREF = %exp:aPendencia[nA][5]% 
	                       AND N9D.N9D_STATUS = "2"
	                       AND N9D.N9D_TIPMOV = "07"	
	                       AND DXI.DXI_ITEMFX = %exp:NN8->NN8_ITEMFX% //nesse item da fixação
	                       AND DXI.DXI_FATURA = "2"			    			 		   
				   EndSQL 
					
				   DbSelectArea( cAliasDXI )		
				   (cAliasDXI)->( dbGoTop() )
				   While .Not. (cAliasDXI)->( Eof( ) ) .and. nQtdCancel > 0
						//busca o recno e remove a fixação
						DXI->(dbGoTop()) //N8D_FILIAL+N8D_CODCTR+N8D_ITEMFX+N8D_SEQVNC
						DXI->(dbGoTo((cAliasDXI)->REC_DXI))
						if DXI->(RECNO()) == (cAliasDXI)->REC_DXI // mesmo recno
							
							//guarda a sequencia
							if (nPos := aScan( aLstResN8D, { |x| x[1] == DXI->DXI_ORDENT } )) > 0
						 		aLstResN8D[nPos][2] += DXI->DXI_PSLIQU
						 		aLstResN8D[nPos][3] += DXI->DXI_PSBRUT
						 		aLstResN8D[nPos][4] += 1
						 	else
						 		aadd( aLstResN8D , {DXI->DXI_ORDENT, DXI->DXI_PSLIQU, DXI->DXI_PSBRUT, 1})
						 	endif
						 	
						 																				
							//remove da N9D	
							aAdd(aFarInativ,  { /*aFilds*/{{"N9D_STATUS","3"}}, /*aChave*/{{DXI->DXI_FILIAL},; // Filial Origem Fardo
																			   {FwXFilial("NJR")},; // FILIAL CTR
																			   {DXI->DXI_SAFRA},; // Safra
																			   {DXI->DXI_ETIQ},; // Etiqueta do Fardo
																			   {"03"},; // Tipo de Movimentação ("03" - Fixação)
																			   {"2"}} }) // Ativo		
							
							//remove o vinculo						
							RecLock('DXI',.f.)
								DXI->DXI_TIPPRE := "2" //base do contrato
								DXI->DXI_ITEMFX := ""
								DXI->DXI_ORDENT := ""
								nQtdCancel      -= DXI->DXI_PSLIQU
							DXI->(MsUnLock())
	
						endif	
							
						(cAliasDXI)->( dbSkip() )
				   Enddo
				   (cAliasDXI)->( dbCloseArea() )
			   next nA
				   
		   	   //remove o que não foi faturado -> DXI_FATURA == "1" 
		   	   if nQtdCancel > 0
		   	   		cAliasDXI := GetNextAlias()
		   	   		BeginSql Alias cAliasDXI
						SELECT DXI.R_E_C_N_O_ REC_DXI 
						  FROM %Table:N9D% N9D			 
						 INNER JOIN %Table:DXI% DXI ON DXI.DXI_FILIAL = N9D.N9D_FILIAL 
												   AND DXI.DXI_SAFRA  = N9D.N9D_SAFRA
				                                   AND DXI.DXI_ETIQ   = N9D.N9D_FARDO  
				                                   AND DXI.%notDel%      
						 WHERE N9D.%notDel%
						   AND N9D.N9D_FILORG = %exp:NN8->NN8_FILIAL% 
						   AND N9D.N9D_CODCTR = %exp:NN8->NN8_CODCTR% 	                  
	                       AND N9D.N9D_STATUS = "2"
	                       AND N9D.N9D_TIPMOV = "03"	
	                       AND DXI.DXI_ITEMFX = %exp:NN8->NN8_ITEMFX% //nesse item da fixação
	                       AND DXI.DXI_FATURA = "1"			    			 		   
				   EndSQL 
					
				   DbSelectArea( cAliasDXI )		
				   (cAliasDXI)->( dbGoTop() )
				   While .Not. (cAliasDXI)->( Eof( ) ) .and. nQtdCancel > 0
						//busca o recno e remove a fixação
						DXI->(dbGoTop()) //N8D_FILIAL+N8D_CODCTR+N8D_ITEMFX+N8D_SEQVNC
						DXI->(dbGoTo((cAliasDXI)->REC_DXI))
						if DXI->(RECNO()) == (cAliasDXI)->REC_DXI // mesmo recno
							
							//guarda a sequencia
							if (nPos := aScan( aLstResN8D, { |x| x[1] == DXI->DXI_ORDENT } )) > 0
						 		aLstResN8D[nPos][2] += DXI->DXI_PSLIQU
						 		aLstResN8D[nPos][3] += DXI->DXI_PSBRUT
						 		aLstResN8D[nPos][4] += 1
						 	else
						 		aadd( aLstResN8D , {DXI->DXI_ORDENT, DXI->DXI_PSLIQU, DXI->DXI_PSBRUT, 1})
						 	endif
						 	
						 	//remove da N9D	
							aAdd(aFarInativ,  { /*aFilds*/{{"N9D_STATUS","3"}}, /*aChave*/{{DXI->DXI_FILIAL},; // Filial Origem Fardo
																			   {FwXFilial("NJR")},; // FILIAL CTR
																			   {DXI->DXI_SAFRA},; // Safra
																			   {DXI->DXI_ETIQ},; // Etiqueta do Fardo
																			   {"03"},; // Tipo de Movimentação ("03" - Fixação)
																			   {"2"}} }) // Ativo	
							
							//remove o vinculo						
							RecLock('DXI',.f.)
								DXI->DXI_TIPPRE := "2" //base do contrato
								DXI->DXI_ITEMFX := ""
								DXI->DXI_ORDENT := ""
								nQtdCancel      -= DXI->DXI_PSLIQU
							DXI->(MsUnLock())																			
								
						endif		
						
						(cAliasDXI)->( dbSkip() )
												
				   Enddo
				   (cAliasDXI)->( dbCloseArea() )
		   	   				   	   	   	
		   	   endif
		   	   
		   	   //remove as n8d
		   	   for nA := 1 to len(aLstResN8D)
					//ajusta as apropriações				
					N8D->(dbSetOrder(2)) //N8D_FILIAL+N8D_CODCTR+N8D_ITEMFX+N8D_SEQVNC(DXI_ORDENT = N8D_SEQVNC  )
					if N8D->(DbSeek(NN8->NN8_FILIAL + NN8->NN8_CODCTR + NN8->NN8_ITEMFX + aLstResN8D[nA][1]))
						RecLock('N8D',.f.)
							N8D->N8D_QTDVNC -= aLstResN8D[nA][2] //soma a quantidade
							N8D->N8D_QTDBTO -= aLstResN8D[nA][3] //soma a quantidade
							N8D->N8D_QTDFAR -= aLstResN8D[nA][4] //soma a quantidade
							nTotResCan      += aLstResN8D[nA][2] 				
						N8D->(MsUnLock())				
					endif				
			   next nA
			   
			   //cancela os movimentos da N9D
			   if len(aFarInativ) > 0
			   	  aRetMov := AGRMOVFARD(, 2, 2, , aFarInativ) // Inativa os fardos removidos	
			   	  if !empty(aRetMov[2]) //occoreram erros
			   	      Help( , , STR0001, , STR0024 + aRetMov[2], 1, 0 )//"Ajuda"#"Não foi possível remover os vinculos de preco do fardo. "
		   	  	  	  return .f.
			   	  endif
			   endif
		   	   	
		   else			 			   			   
			   //posiciona na leitura da fixação
			   N8D->(dbSetOrder(2)) //N8D_FILIAL+N8D_CODCTR+N8D_ITEMFX+N8D_SEQVNC
			   if N8D->(DbSeek(NN8->NN8_FILIAL + NN8->NN8_CODCTR + NN8->NN8_ITEMFX))
				   
				   //lista das apropriações pertinentes.
				   while nQtdCancel > 0 .and. (NN8->NN8_FILIAL+NN8->NN8_CODCTR+NN8->NN8_ITEMFX) == (N8D->N8D_FILIAL+N8D->N8D_CODCTR+N8D->N8D_ITEMFX)
				   		if N8D->N8D_QTDVNC > N8D->N8D_QTDFAT 
							nQtdDebit := N8D->N8D_QTDVNC - N8D->N8D_QTDFAT 
							
							if nQtdDebit > nQtdCancel
								nQtdDebit := nQtdCancel
							endif
							
							RecLock('N8D',.f.)
								N8D->N8D_QTDVNC -= nQtdDebit //diminui a quantidade vinculada
								nQtdCancel      -= nQtdDebit //ajusta o contador
								nTotResCan      += nQtdDebit
							
							If N8D->N8D_QTDVNC == 0 .and. N8D->N8D_QTDFAT == 0
								N8D->(dbdelete())
							EndIf
							
							N8D->(MsUnLock())	
										
					    endif
					    
					    N8D->(dbSkip())
				   enddo	
				   
			   endif  
			   
			   if nQtdCancel > 0
			   	  Help( , , STR0001, , STR0025, 1, 0 )//"Ajudar"#"Quantidade cancelada de apropriação é insuficiente."
				  return .f.
			   endif 
			   			   			   
		   endif
		   
		   Reclock("NN8", .F.)
				NN8->NN8_QTDENT -= nTotFatCan //verificar mais os campos que vamos utiliza.
				NN8->NN8_QTDRES -= nTotResCan
		   NN8->(MsUnlock())  // Destrava o registro 
		endif
		
	endif
	
	//RestArea(aAreaNN8)

return .t.
/*{Protheus.doc} OGX700MTRC
Cria multa a receber
@author jean.schulze
@since 24/09/2018
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@param aMultaInfo, array, descricao
@type function
*/
Function OGX700MTRC(oModel, aMultaInfo) //multa a receber
	Local aFina040  := {}
	Local nVlrTit   := aMultaInfo[3]
	Local nVlrCrz   := xMoeda( nVlrTit, aMultaInfo[7], 1, dDataBase) // Conversão moeda do componente para moeda local
	Local aVncCRec	:= {}
	Local aLinVncAux	:= {}
	Local cNextParc		:= ''
	
	Private lMsErroAuto := .F.
	
	dbSelectArea("NJ0")	
	NJ0->( dbSetOrder( 1 ) )
	if NJ0->( dbSeek( xFilial( "NJ0" ) + oModel:GetValue("N79UNICO", "N79_CODENT") + oModel:GetValue("N79UNICO", "N79_LOJENT") ) )  //achou o devedor
	   cNextParc:= fGetParcRC( aMultaInfo[4], oModel:GetValue("N79UNICO", "N79_CODNGC") )
	   
		aAdd( aFina040, { "E1_PREFIXO" , aMultaInfo[4]                        		, Nil } )
		aAdd( aFina040, { "E1_TIPO"    , aMultaInfo[5]                        		, Nil } )
		aAdd( aFina040, { "E1_NATUREZ" , aMultaInfo[6]                        		, Nil } )
		aAdd( aFina040, { "E1_NUM"     , oModel:GetValue("N79UNICO", "N79_CODNGC") 	, Nil } )
		aAdd( aFina040, { "E1_PARCELA" , cNextParc 									, Nil } )
		aAdd( aFina040, { "E1_CLIENTE" , NJ0->( NJ0_CODCLI )                  		, Nil } )
		aAdd( aFina040, { "E1_LOJA"    , NJ0->( NJ0_LOJCLI )                  		, Nil } )
		aAdd( aFina040, { "E1_EMISSAO" , dDataBase                            		, Nil } )
		aAdd( aFina040, { "E1_VENCTO"  , oModel:GetValue("N79UNICO", "N79_DTMULT") 	, Nil } )
		aAdd( aFina040, { "E1_VALOR"   , nVlrTit                              		, Nil } )
		aAdd( aFina040, { "E1_MOEDA"   , aMultaInfo[7]                              , Nil } ) // moeda componente
		aAdd( aFina040, { "E1_VLCRUZ"  , nVlrCrz                              		, Nil } )
		aAdd( aFina040, { "E1_ORIGEM"  , "OGA700"                             		, Nil } )
		aAdd( aFina040, { "E1_HIST"    , "Multa Contrato: " + oModel:GetValue("N79UNICO", "N79_CODCTR")  , Nil } ) //"Tit. Prov. Ctr. Orig."
		
		//ponto de entrada para criação de título
		If ExistBlock("OGX70SE1")
			aRetPeSE1 := ExecBlock("OGX70SE1",.F.,.F.,{aFina040, oModel})
			If ValType( aRetPeSE1 ) == "A"
				aFina040 := aClone(aRetPeSE1)
			EndIf	
		EndIf
		
		//Criando Vinculo com SE1
		
		aLinVncAux := {}
		IF Empty(FWxFilial("SE1"))
		   aadd( aLinVncAux, { "N8L_FILIAL"    	, FwXfilial('SE1') 							} )
		   aadd( aLinVncAux, { "N8L_FILORI"    	, FwFilial()								} )
		Else
		   aadd( aLinVncAux, { "N8L_FILIAL"    	, Fwxfilial('SE1')		 					} )
		   aadd( aLinVncAux, { "N8L_FILORI"    	, ''										} )
		EndIF
		
		aadd( aLinVncAux, { "N8L_PREFIX"    	, aMultaInfo[4]								} )
		aadd( aLinVncAux, { "N8L_NUM"    		, oModel:GetValue("N79UNICO", "N79_CODNGC") } )
		aadd( aLinVncAux, { "N8L_PARCEL"    	, cNextParc									} )
		aadd( aLinVncAux, { "N8L_TIPO"    		, aMultaInfo[5]								} )
		aadd( aLinVncAux, { "N8L_CODCTR"    	, oModel:GetValue("N79UNICO", "N79_CODCTR")	} )
		aadd( aLinVncAux, { "N8L_SAFRA"	    	, oModel:GetValue("N79UNICO", "N79_CODSAF")	} )
		aadd( aLinVncAux, { "N8L_CODROM"    	, ''										} )
		aadd( aLinVncAux, { "N8L_ITEROM"   		, ''										} )
		aadd( aLinVncAux, { "N8L_CODFIX"   		, ''										} )
		aadd( aLinVncAux, { "N8L_CODOTR"    	, ''										} )
		aadd( aLinVncAux, { "N8L_ORPGRC"   		, ''										} )
		aadd( aLinVncAux, { "N8L_CODNGC"    	, oModel:GetValue("N79UNICO", "N79_CODNGC")	} )
		aadd( aLinVncAux, { "N8L_NGCVER"   		, oModel:GetValue("N79UNICO", "N79_VERSAO")	} )		
		aadd( aLinVncAux, { "N8L_ORIGEM"    	, 'OGA700'		 							} )
		aAdd( aLinVncAux, { "N8L_HISTOR"    	, "Multa Contrato: " + oModel:GetValue("N79UNICO", "N79_CODCTR")		} )  //Previsão financeira, Contrato de vendas
		
		aAdd(aVncCRec,aLinVncAux)
								
			
		MsExecAuto( { |x,y| Fina040( x, y ) }, aFina040, 3 ) //inclusao de titulos
		If lMsErroAuto
			MostraErro()
			return .f.
		EndIf
		
		IF Len( aVncCRec ) > 0
		  	IF .not. fAgrVncRec (aVncCRec, 3 )  //Incluir Vinculo tab N8L X SE1
		  	  Return .f.
		  	EndIF
		EndIF
	else
		Help( , , STR0001, , STR0026, 1, 0 )//"Ajuda"#"Não existe cliente para criar o título de multa a receber."
		return .f.
	endif
	
return .t.

/*{Protheus.doc} OGX700MPAG
//Verifica o componente de multa a Pagar, para geração de alçada de aprovação
@author roney.maia
@since 07/11/2017
@version 1.0
@return ${return}, ${.T. - Alçada Criada, .F. - Erro ao criar alçada}
@param oModel, object, Objeto modelo da rotina OGA700
@param aMultaInfo, array, Array de multa com os dados necessarios
@type function
*/
Function OGX700MPAG( oModel )
	
	Local aArea			:= GetArea()
	Local aMultaInfo	:= {}
	Local oModelN7C		:= oModel:GetModel("N7CUNICO")
	Local oModelN7A		:= oModel:GetModel("N7AUNICO")
	Local lRet 			:= .T.
	Local nA			:= 1
	Local nB			:= 1
    Local lNK7_ALTERA   := iif(ColumnPos( 'NK7_ALCADA' ) > 0, .t., .f.) 
    Local lGerAlc       := .F.    
	
	
	While nA <= oModelN7A:Length() //percorre as cadencias 
		
		oModelN7A:GoLine( nA )				
		If !oModelN7A:IsDeleted() .AND. oModelN7A:GetValue( "N7A_USOFIX" ) != "LBNO" 
				
			For nB := 1 to oModelN7C:Length() //percorre os componentes da cadencia
				oModelN7C:GoLine( nB )
										
				//Verifica os componentes de multa
				If oModelN7C:GetValue("N7C_TPCALC") = "M" //Multa
					//verifica se a quantidade e valor foram preenchidos - vamos ter multa
					If oModelN7C:GetValue("N7C_VLTOTC") > 0 											
						//verifica se a multa já existe
						If (nPos := ASCAN(aMultaInfo, {|x| AllTrim(x[1]) == oModelN7C:GetValue("N7C_CODCOM")}) ) > 0 //existe a multa
							aMultaInfo[nPos][3] += oModelN7C:GetValue("N7C_VLTOTC")
						Else								
							//busca os dados da multa e verifica se é pedido de compra
							DbselectArea( "NK7" )
							NK7->(DbGoTop())
							NK7->(DbSetOrder(1)) //busca por contrato
							
							If NK7->(DbSeek(FwXfilial("NK7")+oModelN7C:GetValue("N7C_CODCOM")))										
								If NK7->NK7_GERMUL == "1" // Multa a Pagar ( Necessita passar pela Alçada de Aprovação) 
								   lGerAlc := .F.
                                   If lNK7_ALTERA //campo existe
                                        If NK7->NK7_ALCADA == '1'  //Alçada
                                           lGerAlc := .t.
                                        EndIf
                                   EndIf 

                                   If lGerAlc
                                        aAdd(aMultaInfo, {	oModelN7C:GetValue("N7C_CODCOM"),;
                                                                NK7->NK7_GERMUL,;
                                                                oModelN7C:GetValue("N7C_VLTOTC"),;
                                                                NK7->NK7_MPREFI,;
                                                                NK7->NK7_MTIPO,;
                                                                NK7->NK7_MNATUR,;
                                                                oModelN7C:GetValue("N7C_MOEDCO"),;
                                                                oModelN7C:GetValue("N7C_TXCOTA")})
                                    EndIf
								EndIf										
							EndIf									
						EndIf								
					 EndIf						
				EndIf
				
			Next nB	
		Endif
		nA++
	EndDo
	
	If Select('NK7') > 0
		NK7->(dbCloseArea())
	EndIf
	
	If len(aMultaInfo) > 0
		For nB := 1 to  len(aMultaInfo) //percorre os componentes da cadencia
			//####################### GERA O PEDIDO DE COMPRA #####################################################
			If aMultaInfo[nB][2] == "1" // Tit. com multa a Pagar			
				Processa({|| lRet := OGX700ALCD(oModel, aMultaInfo[nB])}, STR0027) // # Gerando Documen para Aprovação...			
				If !lRet
					Return lRet
				EndIf
			EndIf
			//########################################################################################################
		Next nB	
	EndIf
	
	RestArea(aArea)
	
Return lRet

/*{Protheus.doc} OGX700ALCD
//Gera documento para Aprovação de acordo com Alçada.
@author Emerson Coelho
@since 20/03/2018
@version 1.0
@return ${return}, ${.T. - Doc.alçada Gerado, .F. - Erro ao criar Doc.Alcada}
@param oModel, object, Objeto modelo da rotina OGA700
@param aMultaInfo, array, Array de multa com os dados necessarios
@type function
*/
Function OGX700ALCD(oModel, aMultaInfo)

	Local aArea			:= GetArea()
	Local oModelN79		:= oModel:GetModel("N79UNICO")

	Local lRet 			:= .T.

	Local lGerCpagar	:= .f.
	Local lGeraAlc		:= .t.

	Local cGrpAprov	   	:= SuperGetMv("MV_AGRO016") // Grupo de Aprovação padrão do Reg. negocio de cancelamento.
	Local cDocAlcada	:= ''	
	Local cObs			:= ''


	IF Empty( cGrpAprov )  // Se o Parametro estiver vazio, ( Vazio == não utiliza controle de alçadas)
		lGeraAlc := .f.
	EndIF
	IF lGeraAlc
	                                                                                                                       
		cDocAlcada 	:= oModelN79:GetValue("N79_CODNGC") + oModelN79:GetValue("N79_VERSAO") + oModelN79:GetValue("N79_TIPO")
		cObs		:= oModelN79:GetValue("N79_OBSERV")

		//Gera o documento para aprovação no compras
		//Se geração retornar .T., titulo pode ser gerado direto sem alçada, caso contrário foi gerado com bloqueio, necessitando de aprovaçã                    
		If MaAlcDoc({cDocAlcada,"A1", aMultaInfo[3],,,cGrpAprov,,aMultaInfo[7],aMultaInfo[8],dDataBase,cObs},dDataBase,1)
			lGerCPagar := .t.
		EndIf
    Else
        lGerCPagar := .t.	
	EndIF	
	
	IF lGerCpagar   //Indica que o titulo da multa não irá passar pelo controle de alçadas;
		cStatus := OGA700STU(oModel) // Verifico se o proximo status do negocio será o completo
		IF Alltrim( cStatus ) == '3'  // Indica que o reg. negocio não vai cair em trabalhando/aprov. de hedge
	   		lRet := OGX700CANC( oModel )
	   EndIF 
	   oModel:SetValue("N79UNICO","N79_STATUS", cStatus )
	   
	EndIF

	NJ0->(dbCloseArea())
	RestArea(aArea)

Return lRet

/*{Protheus.doc} OGX700MTPG
//Gera Tit. a Pagar, ref. a multa de canc. de registro de negocios.
@author Emerson Coelho
@since 20/03/2018
@version 1.0
@return ${return}, ${.T. - Tit. Gerado, .F. - Erro ao criar Tit. }
@param Modelo de dados
@param aMultaInfo, array, Array de multa com os dados necessarios
@type function
*/
Function OGX700MTPG(oModel, aMultaInfo )		

	Local aFina050 	    := {}
    Local aVncCRec      := {}
	Local nVlrTit   	:= aMultaInfo[3]
	Local nVlrCrz   	:= xMoeda(nVlrTit, aMultaInfo[7], 1, dDataBase) // Conversão moeda do componente para moeda local
	Local aVncCPag		:= {}
	Local aLinVncAux2	:= {}
	Local cNextParc		:= ''

	Private lMsErroAuto := .F.
	
	IF !ChkPsw( 23 ) 
		MsgAlert(STR0028)//"Usuário sem acesso ao módulo financeiro. Não foi possível gerar os títulos."		
	    Return .F. 
	EndIf

	dbSelectArea("NJ0")	
	NJ0->( dbSetOrder( 1 ) )
	If NJ0->( dbSeek( xFilial( "NJ0" ) + oModel:GetValue("N79UNICO", "N79_CODENT") + oModel:GetValue("N79UNICO", "N79_LOJENT") ) )  //achou o devedor
		If aMultaInfo[5] == "NCC" .OR. aMultaInfo[5] == "NDC"            
            cNextParc:= fGetParcPG( aMultaInfo[4], oModel:GetValue("N79UNICO", "N79_CODNGC") )        
            
            //gera titulo na SE1
            aFina040 := {}
            aAdd( aFina040, { "E1_FILIAL"  , FwXfilial('SE1'), Nil } )
            aAdd( aFina040, { "E1_PREFIXO" , aMultaInfo[4]        , Nil } )
            aAdd( aFina040, { "E1_NUM"     , oModel:GetValue("N79UNICO", "N79_CODNGC") + oModel:GetValue("N79UNICO", "N79_VERSAO")            , Nil } )
            aAdd( aFina040, { "E1_PARCELA" , cNextParc        ,Nil } )
            aAdd( aFina040, { "E1_TIPO"    , aMultaInfo[5]    ,Nil } )
            aAdd( aFina040, { "E1_CLIENTE" , NJ0->NJ0_CODCLI,  Nil } )
            aAdd( aFina040, { "E1_LOJA"    , NJ0->NJ0_LOJCLI,  Nil } )
            aAdd( aFina040, { "E1_NATUREZ" , aMultaInfo[6] ,   Nil } )
            aAdd( aFina040, { "E1_EMISSAO" , ddatabase       , Nil } )
            aAdd( aFina040, { "E1_VENCTO"  , oModel:GetValue("N79UNICO", "N79_DTMULT")       , Nil } )
            aAdd( aFina040, { "E1_VALOR"   , nVlrTit          , Nil } )
            aAdd( aFina040, { "E1_MOEDA"   , aMultaInfo[7]  , Nil } )
            aAdd( aFina040, { "E1_VLCRUZ"  , nVlrTit  , Nil } )            
            aAdd( aFina040, { "E1_CCUSTO"  , Posicione("SB1",1,FwXFilial("SB1") + oModel:GetValue("N79UNICO", "N79_CODPRO")  ,"B1_CC") , Nil } )
            aAdd( aFina040, { "E1_CLVL", oModel:GetValue("N79UNICO", "N79_CODSAF"), Nil } )                
            aAdd( aFina040, { "E1_CLVLCR", oModel:GetValue("N79UNICO", "N79_CODSAF"), Nil } )
            
            aAdd( aFina040, { "E1_HIST"    , "Multa Contrato: " + oModel:GetValue("N79UNICO", "N79_CODCTR")        , Nil } )
            aAdd( aFina040, { "E1_ORIGEM"  , "OGA700"        , Nil } )

            //Cria ponto de entrada
            If ExistBlock("OGX70SE1")
                aRetPeSE1 := ExecBlock("OGX70SE1",.F.,.F.,{aFina040, oModel})
                If ValType( aRetPeSE1 ) == "A"
                    aFina040 := aClone(aRetPeSE1)
                EndIf	
            EndIf

            //Criando Vinculo com SE1
		
            aLinVncAux := {}
            IF Empty(FWxFilial("SE1"))
                aadd( aLinVncAux, { "N8L_FILIAL"    	, FwXfilial('SE1') 							} )
                aadd( aLinVncAux, { "N8L_FILORI"    	, FwFilial()								} )
            Else
                aadd( aLinVncAux, { "N8L_FILIAL"    	, Fwxfilial('SE1')		 					} )
                aadd( aLinVncAux, { "N8L_FILORI"    	, ''										} )
            EndIF
            
            aadd( aLinVncAux, { "N8L_PREFIX"    	, aMultaInfo[4]								} )
            aadd( aLinVncAux, { "N8L_NUM"    		, oModel:GetValue("N79UNICO", "N79_CODNGC") + oModel:GetValue("N79UNICO", "N79_VERSAO") } )
            aadd( aLinVncAux, { "N8L_PARCEL"    	, cNextParc									} )
            aadd( aLinVncAux, { "N8L_TIPO"    		, aMultaInfo[5]								} )
            aadd( aLinVncAux, { "N8L_CODCTR"    	, oModel:GetValue("N79UNICO", "N79_CODCTR")	} )
            aadd( aLinVncAux, { "N8L_SAFRA"	    	, oModel:GetValue("N79UNICO", "N79_CODSAF")	} )
            aadd( aLinVncAux, { "N8L_CODROM"    	, ''										} )
            aadd( aLinVncAux, { "N8L_ITEROM"   		, ''										} )
            aadd( aLinVncAux, { "N8L_CODFIX"   		, ''										} )
            aadd( aLinVncAux, { "N8L_CODOTR"    	, ''										} )
            aadd( aLinVncAux, { "N8L_ORPGRC"   		, ''										} )
            aadd( aLinVncAux, { "N8L_CODNGC"    	, oModel:GetValue("N79UNICO", "N79_CODNGC")	} )
            aadd( aLinVncAux, { "N8L_NGCVER"   		, oModel:GetValue("N79UNICO", "N79_VERSAO")	} )		
            aadd( aLinVncAux, { "N8L_ORIGEM"    	, 'OGA700'		 							} )
            aAdd( aLinVncAux, { "N8L_HISTOR"    	, "Multa Contrato: " + oModel:GetValue("N79UNICO", "N79_CODCTR")		} )  //Previsão financeira, Contrato de vendas
            
            aAdd(aVncCRec,aLinVncAux)

            //ordena os arrays de acordo com o dicionário para passar para rotina automarica
            aFina040   := FWVetByDic(aFina040	, 'SE1', .F.) 
            
            MsExecAuto( { |x,y| Fina040( x, y ) }, aFina040, 3)
            
            If lMsErroAuto
                MostraErro()
                Return .f.
            EndIf

            IF Len( aVncCRec ) > 0
                IF .not. fAgrVncRec (aVncCRec, 3 )  //Incluir Vinculo tab N8L X SE1
                Return .f.
                EndIF
            EndIF
        Else        
            cNextParc:= fGetParcPG( aMultaInfo[4], oModel:GetValue("N79UNICO", "N79_CODNGC") )

            aFina050 := {}
            aAdd( aFina050, { "E2_PREFIXO" , aMultaInfo[4]                        		, Nil } )
            aAdd( aFina050, { "E2_TIPO"    , aMultaInfo[5]                        		, Nil } )
            aAdd( aFina050, { "E2_NATUREZ" , aMultaInfo[6]                        		, Nil } )
            aAdd( aFina050, { "E2_NUM"     , oModel:GetValue("N79UNICO", "N79_CODNGC") + oModel:GetValue("N79UNICO", "N79_VERSAO")	, Nil } )
            aAdd( aFina050, { "E2_PARCELA" , cNextParc 									, Nil } )
            aAdd( aFina050, { "E2_FORNECE" , NJ0->NJ0_CODFOR    	              		, Nil } )
            aAdd( aFina050, { "E2_LOJA"    , NJ0->NJ0_LOJFOR	                  		, Nil } )
            aAdd( aFina050, { "E2_EMISSAO" , dDataBase                            		, Nil } )
            aAdd( aFina050, { "E2_VENCTO"  , oModel:GetValue("N79UNICO", "N79_DTMULT") 	, Nil } )
            aAdd( aFina050, { "E2_VALOR"   , nVlrTit                              		, Nil } )
            aAdd( aFina050, { "E2_MOEDA"   , aMultaInfo[7]                              , Nil } ) //moeda componente
            aAdd( aFina050, { "E2_VLCRUZ"  , nVlrCrz                              		, Nil } )
            aAdd( aFina050, { "E2_ORIGEM"  , "OGA700"                             		, Nil } )
            aAdd( aFina050, { "E2_HIST"    , "Multa Contrato: " + oModel:GetValue("N79UNICO", "N79_CODCTR")  , Nil } ) //"Tit. Prov. Ctr. Orig."
            
            //Cria ponto de entrada
            If ExistBlock("OGX70SE2")
                aRetPeSE2 := ExecBlock("OGX70SE2",.F.,.F.,{aFina050, oModel})
                If ValType( aRetPeSE2 ) == "A"
                    aFina050 := aClone(aRetPeSE2)
                EndIf	
            EndIf
            
            
            //Criando Vinculo com SE2

            aLinVncAux := {}
            IF Empty(FWxFilial("SE2"))
                aadd( aLinVncAux2, { "N8M_FILIAL"    	, FwXfilial('SE2') 							} )
                aadd( aLinVncAux2, { "N8M_FILORI"    	, FwFilial()								} )
            Else
                aadd( aLinVncAux2, { "N8M_FILIAL"    	, Fwxfilial('SE2')		 					} )
                aadd( aLinVncAux,  { "N8M_FILORI"    	, ''										} )
            EndIF

            aLinvncAux2 := {}
            
            aadd( aLinvncAux2, { "N8M_PREFIX"    	, aMultaInfo[4] 									} )
            aadd( aLinvncAux2, { "N8M_NUM"    		, oModel:GetValue("N79UNICO", "N79_CODNGC") + oModel:GetValue("N79UNICO", "N79_VERSAO") 		} )
            aadd( aLinvncAux2, { "N8M_PARCEL"    	, cNextParc											} )
            aadd( aLinvncAux2, { "N8M_TIPO"    		, aMultaInfo[5]  					    			} )
            aadd( aLinvncAux2, { "N8M_FORNEC"    	, NJ0->NJ0_CODFOR									} )
            aadd( aLinvncAux2, { "N8M_LOJA"    		, NJ0->NJ0_LOJFOR			    					} )
            aadd( aLinVncAux2, { "N8M_CODCTR"    	, oModel:GetValue("N79UNICO", "N79_CODCTR")			} )
            aadd( aLinVncAux2, { "N8M_CODSAF"	    , oModel:GetValue("N79UNICO", "N79_CODSAF")			} )
            aadd( aLinVncAux2, { "N8M_CODROM"    	, ''			                					} )
            aadd( aLinVncAux2, { "N8M_ITEROM"   	, ''				            					} )
            aadd( aLinVncAux2, { "N8M_ITEMFX"   	, ''												} )
            aadd( aLinVncAux2, { "N8M_ORDTRA"    	, ''												} )
            aadd( aLinVncAux2, { "N8M_ORPGRC"    	, ''												} )
            aadd( aLinVncAux2, { "N8M_ITPGRC"    	, ''												} )
            aadd( aLinVncAux2, { "N8M_CODNGC"   	, oModel:GetValue("N79UNICO", "N79_CODNGC")			} )
            aadd( aLinVncAux2, { "N8M_VERNGC"   	, oModel:GetValue("N79UNICO", "N79_VERSAO")			} )
            aadd( aLinVncAux2, { "N8M_ORIGEM"    	, 'OGA700'		 				} )
            aAdd( aLinVncAux2, { "N8M_HISTOR"    	, "Multa Contrato: " + oModel:GetValue("N79UNICO", "N79_CODCTR")		} )  // Multa contrato #########
        
            aAdd(aVncCPag, aLinvncAux2)
            MsExecAuto( { |x,y| Fina050( x, y ) }, aFina050, 3 )
            If lMsErroAuto
                MostraErro()
                Return .f.
            EndIf

            IF Len( aVncCPag ) > 0
                IF .not. fAgrVncPag  (aVncCPag, 3 )  //Incluir Vinculo tab N8M X SE2
                    Return .f.
                EndIF
            EndIF 
        EndIf
	Else
		Help( , , STR0001, , STR0029, 1, 0 )//"Não existe cliente fornnecedor cadastrado para criar o título de multa a pagar."
		return .f.
	Endif


return .t.

/*******************************************************************
*********************TRATAMENTOS NO CONTRATO ***********************
/*******************************************************************/
/*{Protheus.doc} OGX700CTR
Geração do contrato
@author jean.schulze
@since 05/09/2017
@version undefined
@param oModel, object, descricao
@type function
*/
function OGX700CTR(oModel)
	Local oModelN79 := oModel:GetModel("N79UNICO")
	Local oModelNJR	:= Nil
	Local oModelNNF := Nil
	Local oModelN7R := Nil
	Local oAux 		:= Nil
	Local oStruct	:= Nil
	Local nI 		:= 0
	Local nJ 		:= 0
	Local nPos 		:= 0
	Local lRet 		:= .T.
	Local aAux 		:= {}
	Local nItErro 	:= 0
	Local lAux 		:= .T.
	Local cNjrCodCtr:= ' '
	Local nIt       := 0
	
	//verifica se cria o contrato
	
	if  oModel:GetValue("N79UNICO","N79_TIPO") == "1" /*Novo Negócio*/ .and. oModel:GetValue("N79UNICO","N79_GERCTR") == '2' /*Contrato Não gerado*/ 
		//apropriar valores nas tabelas correspondentes
		aFldNJR := {}
		aFldNNY := {}
		aFldNNF := {}
		aFldN7R := {}		
		
		CarrCtrArr(@aFldNJR, @aFldNNY, @aFldNNF, aFldN7R, oModel) //carregar dados da tabela de contrato
	
		//coloca numa transação? yeah
		If oModelN79:GetValue("N79_OPENGC") == '1' //compras
			oModelNJR := FWLoadModel( 'OGA280' )
		ElseIf oModelN79:GetValue("N79_OPENGC") = '2'
			oModelNJR := FWLoadModel( 'OGA290' )
		EndIf
		
		// Temos que definir qual a operação deseja: 3 – Inclusão / 4 – Alteração / 5 - Exclusão
		oModelNJR:SetOperation( 3 )
		
		//remove todos os campos obrigatórios e when de campo
		For nIt := 1 To Len(oModelNJR:aAllSubModels)
			oModelNJR:aAllSubModels[nIt]:GetStruct():SetProperty( "*", MODEL_FIELD_OBRIGAT, .F.  )
			oModelNJR:aAllSubModels[nIt]:GetStruct():SetProperty( "*", MODEL_FIELD_WHEN, {| oField | .T. } ) 
		Next nIt
		
		// Antes de atribuirmos os valores dos campos temos que ativar o modelo
		oModelNJR:Activate()
		
		// Instanciamos apenas a parte do modelo referente aos dados de cabeçalho
		oAux := oModelNJR:GetModel( 'NJRUNICO' )   
		// Obtemos a estrutura de dados do cabeçalho
		oStruct := oAux:GetStruct()
		aAux    := oStruct:GetFields()
		
		/*Negócios*/
		If lRet
			For nI := 1 To Len( aFldNJR )
				// Verifica se os campos passados existem na estrutura do cabeçalho
				If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aFldNJR[nI][1] ) } ) ) > 0
					// È feita a atribuição do dado aos campo do Model do cabeçalho
					If !( lAux := oModelNJR:SetValue( 'NJRUNICO', aFldNJR[nI][1],aFldNJR[nI][2] ) )
						// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
						// o método SetValue retorna .F.
						lRet := .F.
						Exit
					EndIf
				EndIf
			Next
		EndIf
		
		/*Cadências*/
		If lRet
			// Instanciamos apenas a parte do modelo referente aos dados do item
			oAux := oModelNJR:GetModel( 'NNYUNICO' )
			// Obtemos a estrutura de dados do item
			oStruct := oAux:GetStruct()
			aAux := oStruct:GetFields()
			nItErro := 0
			For nI := 1 To Len( aFldNNY )
				// Incluímos uma linha nova
				// ATENÇÃO: O itens são criados em uma estrutura de grid (FORMGRID), portanto já é criada uma primeira linha
				//branco automaticamente, desta forma começamos a inserir novas linhas a partir da 2ª vez
				If nI > 1
					// Incluímos uma nova linha de item
					If ( nItErro := oAux:AddLine() ) <> nI
						// Se por algum motivo o método AddLine() não consegue incluir a linha, // ele retorna a quantidade de linhas já // existem no grid. Se conseguir retorna a quantidade mais 1
						lRet := .F.
						Exit
					EndIf
				EndIf
				For nJ := 1 To Len( aFldNNY[nI] )
					// Verifica se os campos passados existem na estrutura de item
					If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aFldNNY[nI][nJ][1] ) } ) ) > 0
						If !( lAux := oModelNJR:SetValue( 'NNYUNICO', aFldNNY[nI][nJ][1], aFldNNY[nI][nJ][2] ) )
							// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
							// o método SetValue retorna .F.
							lRet := .F.
							nItErro := nI
							Exit
						EndIf
					EndIf
				Next nJ

				If !lRet
					Exit
				EndIf
				
				//chama função AGRXNJRN9A() para setar dados corretramente na N9A, apos criar NNY acima
				AGRXNJRN9A(oModelNJR,"NJR_CODENT") 
				AGRXNJRN9A(oModelNJR,"NJR_CODTER") 
				AGRXNJRN9A(oModelNJR,"NJR_CODFIN") 
				AGRXNJRN9A(oModelNJR,"NJR_INCOTE") 
				AGRXNJRN9A(oModelNJR,"NJR_CONDPA") 
				AGRXNJRN9A(oModelNJR,"NJR_CONDPG") 
				AGRXNJRN9A(oModelNJR,"NJR_CTREXT") 
				AGRXNJRN9A(oModelNJR,"NJR_CODPRO") 
				AGRXNJRN9A(oModelNJR,"NJR_TIPO") 
				
			Next nI
		EndIf
		
		/*Corretores*/
		If lRet .AND. !Empty(aFldNNF)
			oStruct := NIL
			aAux    := NIL
			oModelNNF := oModelNJR:GetModel( 'NNFUNICO' )
			// Obtemos a estrutura de dados do item
			oStruct := oModelNNF:GetStruct()
			aAux := oStruct:GetFields()			
			For nI := 1 To Len( aFldNNF )

				// Incluímos uma linha nova
				// ATENÇÃO: O itens são criados em uma estrutura de grid (FORMGRID), portanto já é criada uma primeira linha
				//branco automaticamente, desta forma começamos a inserir novas linhas a partir da 2ª vez
				If nI > 1
					// Incluímos uma nova linha de item
					If ( nItErro := oModelNNF:AddLine() ) <> nI
						// Se por algum motivo o método AddLine() não consegue incluir a linha, // ele retorna a quantidade de linhas já // existem no grid. Se conseguir retorna a quantidade mais 1
						lRet := .F.
						Exit
					EndIf
				EndIf
				
				For nJ := 1 To Len( aFldNNF[nI] )
					// Verifica se os campos passados existem na estrutura do cabeçalho
					If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aFldNNF[nI][nJ][1] ) } ) ) > 0
						// È feita a atribuição do dado aos campo do Model do cabeçalho
						If !( lAux := oModelNNF:SetValue( aFldNNF[nI][nJ][1],aFldNNF[nI][nJ][2] ) )
							// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
							// o método SetValue retorna .F.
							lRet := .F.
							Exit
						EndIf
					EndIf
				Next nJ
			Next
		EndIf

		/*Exportação/Portos*/
		If lRet .AND. !Empty(aFldN7R)
			oStruct := NIL
			aAux    := NIL
			oModelN7R := oModelNJR:GetModel( 'N7RUNICO' )
			// Obtemos a estrutura de dados do item
			oStruct := oModelN7R:GetStruct()
			aAux := oStruct:GetFields()			
			For nI := 1 To Len( aFldN7R )
				// Incluímos uma linha nova
				// ATENÇÃO: O itens são criados em uma estrutura de grid (FORMGRID), portanto já é criada uma primeira linha
				//branco automaticamente, desta forma começamos a inserir novas linhas a partir da 2ª vez
				If nI > 1
					// Incluímos uma nova linha de item
					If ( nItErro := oModelN7R:AddLine() ) <> nI
						// Se por algum motivo o método AddLine() não consegue incluir a linha, // ele retorna a quantidade de linhas já // existem no grid. Se conseguir retorna a quantidade mais 1
						lRet := .F.
						Exit
					EndIf
				EndIf
				
				For nJ := 1 To Len( aFldN7R[nI] )				
					// Verifica se os campos passados existem na estrutura do cabeçalho
					If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aFldN7R[nI][nJ][1] ) } ) ) > 0
						// È feita a atribuição do dado aos campo do Model do cabeçalho
						If !( lAux := oModelN7R:SetValue( aFldN7R[nI][nJ][1],aFldN7R[nI][nJ][2] ) )
							// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
							// o método SetValue retorna .F.
							lRet := .F.
							Exit
						EndIf
					EndIf
				Next nJ
			Next nI
		EndIf
		//Tratamento para não criar previsao de pagamento zerada
		oModelNJR:GetModel("NN7UNICO"):ClearData()
	
		If lRet
			// Faz-se a validação dos dados, note que diferentemente das tradicionais "rotinas automáticas"
			// neste momento os dados não são gravados, são somente validados.
			If ( lRet := oModelNJR:VldData() ) 
				// Se o dados foram validados faz-se a gravação efetiva dos
				// dados (commit)
				//guarda o código do contrato a ser gravado 
				cNjrCodCtr    := oModelNJR:GetValue("NJRUNICO","NJR_CODCTR")
				lRet := oModelNJR:CommitData()
			EndIf
			 	
		EndIf
		
		If lRet
						
			/******* TRATAMENTOS DE FIXAÇÃO/CANCELAMENTO ******/
			
			If oModelN79:GetValue("N79_FIXAC") == "1" //fixação de preço
				//verifica se tem componente fixado - componentes fixados N7M e N7O- Negócios fixos X componentes fixos
				lRet := OGX700CPFX(oModel,cNjrCodCtr)
				//verifica se é fixação de preço - NN8, NKA e N7N
				if lRet
					lRet := OGX700PRFX(oModel,cNjrCodCtr) 
				endif
			else
				//verifica se tem componente fixado - componentes fixados N7M
				lRet := OGX700CPFX(oModel,cNjrCodCtr) 
			endif 			
			
			if lRet 
				//Altera o campo de gera contrato para 1=SIM
				if oModel:GetOperation() == MODEL_OPERATION_VIEW
					RECLOCK("N79", .F.)
						N79->N79_CODCTR := cNjrCodCtr
						N79->N79_GERCTR := '1'
					MSUNLOCK()
				else
				   oModelN79:SetValue("N79_CODCTR", cNjrCodCtr)		
				   oModelN79:SetValue("N79_GERCTR", "1")	
				endif
			endif			
		Else
			// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
			aErro := oModelNJR:GetErrorMessage()
			
			AutoGrLog( STR0030 + ' [' + AllToChar( aErro[1] ) + ']' )//"Id do formulário de origem:"
			AutoGrLog( STR0031 + ' [' + AllToChar( aErro[2] ) + ']' )//"Id do campo de origem: "
			AutoGrLog( STR0032 + ' [' + AllToChar( aErro[3] ) + ']' )//"Id do formulário de erro: "
			AutoGrLog( STR0033 + ' [' + AllToChar( aErro[4] ) + ']' )//"Id do campo de erro: "
			AutoGrLog( STR0034 + ' [' + AllToChar( aErro[5] ) + ']' )//"Id do erro: "
			AutoGrLog( STR0035 + ' [' + AllToChar( aErro[6] ) + ']' )//"Mensagem do erro: "
			AutoGrLog( STR0036 + ' [' + AllToChar( aErro[7] ) + ']' )//"Mensagem da solução: "
			AutoGrLog( STR0037 + ' [' + AllToChar( aErro[8] ) + ']' )//"Valor atribuído: "
			AutoGrLog( STR0038 + ' [' + AllToChar( aErro[9] ) + ']' )//"Valor anterior: "
			If nItErro > 0
				AutoGrLog( STR0039 + ' [' + AllTrim( AllToChar( nItErro ) ) + ']' )//"Erro no Item: "
			EndIf
			
            If !lAutomato
                MostraErro()
            EndIf
			
			lRet := .F.
	
			//Altera o campo de gera contrato para 2= NÃO
			if oModel:GetOperation() == MODEL_OPERATION_VIEW
				RECLOCK("N79", .F.)
					N79->N79_CODCTR := ""
					N79->N79_GERCTR := '2'
				MSUNLOCK()
			else
			   oModelN79:SetValue("N79_CODCTR", "")		
			   oModelN79:SetValue("N79_GERCTR", "2")	
			endif	
			
			Help( ,,STR0001,,STR0040, 1, 0 ) //"AJUDA"#"Não foi possivel gerar o contrato."
			
					
		EndIf
	
		// Desativamos o Model
		oModelNJR:DeActivate()
	endif
return (lRet)

/*{Protheus.doc} OGX700CPFX
Fixação de componente
@author jean.schulze
@since 08/09/2017
@version undefined
@param oModel, object, descricao
@param cNjrCodCtr, characters, descricao
@type function
*/
Function OGX700CPFX(oModel,cNjrCodCtr) 
	Local oModelN7C  := oModel:GetModel("N7CUNICO") 
	Local oModelN7A	 := oModel:GetModel("N7AUNICO")
	Local oModelN79	 := oModel:GetModel("N79UNICO")
	Local nA         := 1
	Local nB         := 0
	Local nSeqfix    := 0
		
	// para fixações vamos ter que debitar os valores, verificar para tratar em 2 frentes ... coinsumindo componente e criando novo registro... criar 2 modulações...
	
	while nA <= oModelN7A:Length() //percorre as cadencias 
		oModelN7A:GoLine( nA )	
		
				
		If !oModelN7A:IsDeleted() .and. oModelN7A:GetValue( "N7A_USOFIX" ) <> "LBNO"
					
			For nB := 1 to oModelN7C:Length() //percorre os componentes da cadencia
				oModelN7C:GoLine( nB )
													
				If  !oModelN7C:IsDeleted()  .and. oModelN7C:GetValue("N7C_QTAFIX") > 0 .and. oModelN7C:GetValue("N7C_TPCALC") $ "P|C" //Preço ou Custo calcula os valores   
					
					nSeqfix := OGX700N7MS(FwxFilial("N7M"), cNjrCodCtr, oModelN7A:GetValue("N7A_CODCAD"), oModelN7C:GetValue("N7C_CODCOM")) //reset sequencie	
					
					nSeqfix++ //incremento no sequencie de dados
					
					//popula dados na N7M - Componentes Fixados
					DbSelectArea("N7M")
					Reclock("N7M", .T.)
					
						N7M->N7M_FILIAL := FwxFilial("N7M")
						N7M->N7M_CODCTR := cNjrCodCtr
						N7M->N7M_CODCAD := oModelN7A:GetValue("N7A_CODCAD")
						N7M->N7M_CODCOM := oModelN7C:GetValue("N7C_CODCOM")
						N7M->N7M_SEQFIX := PadL(cValToChar(nSeqfix), TamSX3( "N7M_SEQFIX" )[1], "0")
						N7M->N7M_DATA   := oModelN79:GetValue("N79_DATA")
						N7M->N7M_CODNGC := oModelN79:GetValue("N79_CODNGC")
						N7M->N7M_VERSAO	:= oModelN79:GetValue("N79_VERSAO")
						N7M->N7M_QTDFIX := oModelN7C:GetValue("N7C_QTAFIX")
						N7M->N7M_QTDALO := IIF(oModelN79:GetValue("N79_FIXAC") == "1" /*Preço*/,oModelN7C:GetValue("N7C_QTAFIX"), 0 )
						N7M->N7M_QTDSLD := IIF(oModelN79:GetValue("N79_FIXAC") == "1" /*Preço*/,0, oModelN7C:GetValue("N7C_QTAFIX") ) 
						N7M->N7M_QTDORI := oModelN7C:GetValue("N7C_QTAFIX")
						N7M->N7M_VALOR  := oModelN7C:GetValue("N7C_VLRCOM")
						N7M->N7M_UMCOM  := oModelN7C:GetValue("N7C_UMCOM")
						N7M->N7M_MOEDA  := oModelN7C:GetValue("N7C_MOEDCO")
						N7M->N7M_TXMOED := oModelN7C:GetValue("N7C_TXCOTA")
						
					N7M->(MsUnlock()) // Destrava o registro
					
					//se usou para preço vamos colocar na N70	
					if oModelN79:GetValue("N79_FIXAC") == "1" //1-Preço , 2-Componente
						//GRVAR ASSOCIATIVA DE Negócios(Fixados) X Componentes Fixados 
					    DbSelectArea("N7O")
						Reclock("N7O", .T.)
							
							N7O->N7O_FILIAL := FwxFilial("N7O")
							N7O->N7O_CODNGC := oModelN79:GetValue("N79_CODNGC") 
							N7O->N7O_VERSAO	:= oModelN79:GetValue("N79_VERSAO")
							N7O->N7O_CODCAD := oModelN7A:GetValue("N7A_CODCAD")
							N7O->N7O_CODCOM := oModelN7C:GetValue("N7C_CODCOM")
							N7O->N7O_SEQFIX := PadL(cValToChar(nSeqfix), TamSX3( "N7O_SEQFIX" )[1], "0") //sequencia usada no cadastro de componente
							N7O->N7O_CODCTR := cNjrCodCtr
							N7O->N7O_QTDALO := oModelN7C:GetValue("N7C_QTAFIX")
							N7O->N7O_VALOR  := oModelN7C:GetValue("N7C_VLRCOM")
							N7O->N7O_ORINGC := oModelN79:GetValue("N79_CODNGC") //negócio que criou a fixação		
							N7O->N7O_ORIVER := oModelN79:GetValue("N79_VERSAO") //negócio que criou a fixação	
																															
						N7O->(MsUnlock())     // Destrava o registro
					endif
						
				EndIf				
				
			next nB
		EndIf
		nA++		
	endDo	
	
return .t.

/*{Protheus.doc} OGX700PRFX
Fixação de preço
@author jean.schulze
@since 08/09/2017
@version undefined
@param oModel, object, descricao
@param cNjrCodCtr, characters, descricao
@type function
*/
Function OGX700PRFX(oModel,cNjrCodCtr ) 
	Local oModelN7C  := oModel:GetModel("N7CUNICO") 
	Local oModelN7A	 := oModel:GetModel("N7AUNICO")
	Local oModelN7O	 := oModel:GetModel("N7OUNICO")
	Local oModelN79	 := oModel:GetModel("N79UNICO")
	Local nA         := 1
	Local nB         := 0
	Local nC         := 0
	Local nSeqfix 	 := 1 
	Local nSeqAprop  := 0
	Local nValorFix  := 0
	Local nQtdPrior  := 0
	
	if !AGRTPALGOD(oModel:GetValue("N79UNICO","N79_CODPRO")) //somente busca os valores se for granel
		nSeqAprop := OGX720N8DS( FwxFilial("NJR") , cNjrCodCtr ) //Verifica a ultima sequencia (N8D_SEQVNC) que existepara a fixação a ser criada
		nSeqAprop := PadL(nSeqAprop, TamSX3( "N8D_SEQVNC" )[1], "0") 	
	endif
	
	nSeqfix := OGX700NN8S(oModelN79:GetValue("N79_FILIAL"), cNjrCodCtr) //reset sequencie
	
	while nA <= oModelN7A:Length() //percorre as cadencias 
		oModelN7A:GoLine( nA )	
		
		If !oModelN7A:IsDeleted() .and. oModelN7A:GetValue( "N7A_USOFIX" ) <> "LBNO" .and. oModelN7C:GetValue("N7C_QTAFIX") > 0
						
			//busca os dados de componente de resultado para grava na NN8
			if !oModelN7C:IsDeleted()  
				
				nQtdPrior := 0
				nValorFix := 0
						
				//busca o preço negociado
				if oModelN7C:SeekLine( { {"N7C_TPPREC", "2"  } } ) //preço negociado
					
					nSeqfix++ //incremento no sequencie de dados
					
					//grava os dados
					DbSelectArea("NN8")
					Reclock("NN8", .T.)
						
						NN8->NN8_FILIAL := FwxFilial("NN8")
						NN8->NN8_CODCTR := cNjrCodCtr
						NN8->NN8_CODCAD := oModelN7A:GetValue("N7A_CODCAD")
						NN8->NN8_ITEMFX := PadL(cValToChar(nSeqfix), TamSX3( "NN8_ITEMFX" )[1], "0") //sequencia usada na NN8
 						NN8->NN8_CODNGC := oModelN79:GetValue("N79_CODNGC") 
						NN8->NN8_VERSAO	:= oModelN79:GetValue("N79_VERSAO")
 						NN8->NN8_TIPOFX := "1" //fixo
						NN8->NN8_STATUS := "2" //fixo  
						NN8->NN8_DATA   := oModelN79:GetValue("N79_DATA") 
						NN8->NN8_DATINI := oModelN7A:GetValue("N7A_DATINI")
						NN8->NN8_DATFIN := oModelN7A:GetValue("N7A_DATINI")
						NN8->NN8_QTDFIX := oModelN7C:GetValue("N7C_QTAFIX")

                        If !AGRTPALGOD(oModelN79:GetValue("N79_CODPRO"))
						    NN8->NN8_QTDRES := oModelN7C:GetValue("N7C_QTAFIX")
                        EndIf
                         
						//NN8->NN8_CODIDX := oModelN7C:GetValue("N7C_VLRCOM") - não usado
						NN8->NN8_MOEDA 	:= oModelN7C:GetValue("N7C_MOEDCO")
						NN8->NN8_TXMOED := oModelN7C:GetValue("N7C_TXCOTA")
						
						//valor na moeda corrente
						NN8->NN8_VLRUNI := oModelN7C:GetValue("N7C_VLRCOM") //verifica a necessidade de conversao para estar no valor da unidade de medida de preço
						NN8->NN8_VLRTOT := oModelN7C:GetValue("N7C_VLTOTC")
						
						//valor sem impostos em R$
						NN8->NN8_VLRLIQ := NN8->NN8_VLRUNI // verificar o tratamento a ser realizado no estudo dos impostos
						NN8->NN8_VLRLQT := NN8->NN8_VLRTOT 						
						
						
						//valor em outra moeda
						if oModelN7C:GetValue("N7C_MOEDCO") <> 1 
							
							If oModelN7C:GetValue("N7C_TXCOTA") <= 0 //se a cotação não foi informada
								NN8->NN8_VALUNI := Round(xMoeda( NN8->NN8_VLRUNI, oModelN7C:GetValue("N7C_MOEDCO"), 1, oModelN79:GetValue("N79_DATA") ,TamSX3("NN8_TXMOED")[2] ),TamSX3("NN8_VALUNI")[2] )  								
								NN8->NN8_VALTOT := Round(xMoeda( NN8->NN8_VLRTOT, oModelN7C:GetValue("N7C_MOEDCO"), 1, oModelN79:GetValue("N79_DATA") ,TamSX3("NN8_TXMOED")[2] ),TamSX3("NN8_VLRTOT")[2] )  								
							Else
								NN8->NN8_VALUNI  := Round(NN8->NN8_VLRUNI / oModelN7C:GetValue("N7C_TXCOTA"), TamSX3("NN8_VALUNI")[2] )
								NN8->NN8_VALTOT  := Round(NN8->NN8_VLRTOT / oModelN7C:GetValue("N7C_TXCOTA"), TamSX3("NN8_VLRTOT")[2] )
							EndIf
							
							//sem imposots na outra moeda
							NN8->NN8_VALLIQ := NN8->NN8_VALUNI 
							NN8->NN8_VALLQT := NN8->NN8_VALTOT  //total da fixação sem impostos
						else //moeda corrente
							//valor na unidade de medida de preço em dólar - converter
							NN8->NN8_VALUNI := NN8->NN8_VLRUNI
							NN8->NN8_VALTOT := NN8->NN8_VLRTOT
							
							//sem imposots na outra moeda
							NN8->NN8_VALLIQ := NN8->NN8_VLRUNI 
							NN8->NN8_VALLQT := NN8->NN8_VLRTOT //total da fixação sem impostos
							
						endif
						
						nQtdPrior := NN8->NN8_QTDFIX
						nValorFix := NN8->NN8_VLRUNI
																
					NN8->(MsUnlock())     // Destrava o registro	
				else
					Help( , , STR0001, , STR0041, 1, 0 )//"Ajuda"#"Não existe Preço Negociado cadastrado. Verificar o cadastro de componentes."
					return .f.
				endif
			endif	
						
			//grava os demais componentes na tabela de componentes e 
			For nB := 1 to oModelN7C:Length() //percorre os componentes da cadencia
				oModelN7C:GoLine( nB )
				
				if oModelN79:GetValue("N79_TIPO") <> "1" //itens diferentes de novo negócio
					//debita as quantidades nas fixações alocadas  e trata as demais operações
					For nC := 1 to oModelN7O:Length() //percorre as fixações utilizadas do componente
						oModelN7O:GoLine( nC )
						
						
						if oModel:GetOperation() == 3 //se for insert(item sem aprovação)
							//grava relação na N7N
							DbSelectArea("N7N")
							Reclock("N7N", .T.)
								
								N7N->N7N_FILIAL := FwxFilial("N7N")
								N7N->N7N_CODCTR := cNjrCodCtr
								N7N->N7N_ITEMFX := PadL(cValToChar(nSeqfix), TamSX3( "N7N_ITEMFX" )[1], "0") //sequencia usada no cadastro de componente
								N7N->N7N_CODCOM := oModelN7C:GetValue("N7C_CODCOM")
								N7N->N7N_SEQFIX := oModelN7O:GetValue("N7O_SEQFIX")
								N7N->N7N_QTDALO := oModelN7O:GetValue("N7O_QTDALO")
															
							N7N->(MsUnlock())     // Destrava o registro	
						endif					
					next nC
				
				endif
								 		
				//grava NKA
				DbSelectArea("NKA")
				Reclock("NKA", .T.)
					
					NKA->NKA_FILIAL := FwxFilial("NKA")
					NKA->NKA_CODCTR := cNjrCodCtr
					NKA->NKA_CODCAD := oModelN7A:GetValue("N7A_CODCAD")
					NKA->NKA_ITEMFX := PadL(cValToChar(nSeqfix), TamSX3( "NKA_ITEMFX" )[1], "0") //sequencia usada na NN8
					NKA->NKA_CODCOM := oModelN7C:GetValue("N7C_CODCOM")
					NKA->NKA_ITEMCO := oModelN7C:GetValue("N7C_ITEMCO")
					NKA->NKA_CODIDX := oModelN7C:GetValue("N7C_CODIDX") //código do indice
					NKA->NKA_DESCRI := ALLTRIM(POSICIONE("NK7",1,XFILIAL("NK7")+oModelN7C:GetValue("N7C_CODCOM"),"NK7_DESABR")) //posione
					NKA->NKA_TPVLR	:= "1" /*Normal*/
					NKA->NKA_MOEDCO := oModelN7C:GetValue("N7C_MOEDCO")
					NKA->NKA_UMCOM 	:= oModelN7C:GetValue("N7C_UMCOM")
					NKA->NKA_VLRIDX := oModelN7C:GetValue("N7C_VLRIDX") //fazer média ponderada ???
					NKA->NKA_VLRCOM := (oModelN7C:GetValue("N7C_VLRFIX") * oModelN7C:GetValue("N7C_QTDFIX") + oModelN7C:GetValue("N7C_VLRCOM") * oModelN7C:GetValue("N7C_QTAFIX")) / (oModelN7C:GetValue("N7C_QTDFIX") + oModelN7C:GetValue("N7C_QTAFIX"))
					NKA->NKA_MOEDCT := oModelN7C:GetValue("N7C_MOEDA")
					NKA->NKA_UMPRC 	:= oModelN7C:GetValue("N7C_UMPRC")
					NKA->NKA_VLRUN1 := oModelN7C:GetValue("N7C_VLRUN1") //tomar cuidado para usar valores atualizados - sempre update quando quantidade fixada maior
					NKA->NKA_UMPROD := oModelN7C:GetValue("N7C_UMPROD")
					NKA->NKA_VLRUN2 := oModelN7C:GetValue("N7C_VLRUN2") //tomar cuidado para usar valores atualizados
					NKA->NKA_TXACOT := oModelN7C:GetValue("N7C_TXCOTA")
					NKA->NKA_CODNGC := oModelN79:GetValue("N79_CODNGC") 
					NKA->NKA_VERSAO	:= oModelN79:GetValue("N79_VERSAO")
												
				NKA->(MsUnlock())     // Destrava o registro
				
				//busca as N7O criadas e grava conforme o componente -
				DbSelectArea("N7O")
				N7O->(DbGoTop())
				N7O->(DbSeek(FwxFilial("N7O")+oModelN79:GetValue("N79_CODNGC")+oModelN79:GetValue("N79_VERSAO")+oModelN7A:GetValue("N7A_CODCAD")+oModelN7C:GetValue("N7C_CODCOM")))
				while FwxFilial("N7O")+oModelN79:GetValue("N79_CODNGC")+oModelN79:GetValue("N79_VERSAO")+oModelN7A:GetValue("N7A_CODCAD")+oModelN7C:GetValue("N7C_CODCOM") == N7O->N7O_FILIAL+N7O->N7O_CODNGC+N7O->N7O_VERSAO+N7O->N7O_CODCAD+N7O->N7O_CODCOM
					//grava N7N
				    DbSelectArea("N7N")
					Reclock("N7N", .T.)
						
						N7N->N7N_FILIAL := FwxFilial("N7N")
						N7N->N7N_CODCTR := cNjrCodCtr
						N7N->N7N_ITEMFX := PadL(cValToChar(nSeqfix), TamSX3( "N7N_ITEMFX" )[1], "0") //sequencia usada no cadastro de componente
						N7N->N7N_CODCOM := oModelN7C:GetValue("N7C_CODCOM")
						N7N->N7N_SEQFIX := N7O->N7O_SEQFIX
						N7N->N7N_QTDALO := oModelN7C:GetValue("N7C_QTAFIX")
													
					N7N->(MsUnlock())     // Destrava o registro
					
					N7O->(DbSkip())
				enddo	
												
				
			next nB
			
			if !AGRTPALGOD(oModel:GetValue("N79UNICO","N79_CODPRO")) //somente busca os valores se for granel
				
				//listaRegras 
				aRegrasFis := OGA570SLRG(FwxFilial("N8D"), cNjrCodCtr, oModelN7A:GetValue("N7A_CODCAD"))  
				
				For nB := 1 to len(aRegrasFis)
					if aRegrasFis[nB][2] > 0 .and. nQtdPrior > 0 
						//cria automaticamente a N8D se for granel...
						nSeqAprop  := Soma1(nSeqAprop)
										
						//Criando novo registo da N8D
						dbSelectArea("N8D")
						RecLock("N8D", .t.) // Se existir irei ( adicionar o bloco e seus fardos ao  vinculo, senao irei criar um novo vinculo)
							N8D->N8D_FILIAL	:= FwxFilial("N8D")
							N8D->N8D_CODCTR	:= cNjrCodCtr
							N8D->N8D_ITEMFX	:= PadL(cValToChar(nSeqfix), TamSX3( "N8D_ITEMFX" )[1], "0")
							N8D->N8D_SEQVNC	:= nSeqAprop
							N8D->N8D_ORDEM	:= nSeqAprop //usa a mesma vinculação do campo de sequencia
							N8D->N8D_VALOR	:= nValorFix
							N8D->N8D_REGRA	:= aRegrasFis[nB][1] 
							N8D->N8D_CODCAD	:= oModelN7A:GetValue("N7A_CODCAD")
							
							if nQtdPrior > aRegrasFis[nB][2] 
							   N8D->N8D_QTDVNC := aRegrasFis[nB][2]
							   nQtdPrior -= aRegrasFis[nB][2]
							else
							   N8D->N8D_QTDVNC := nQtdPrior
							   nQtdPrior := 0 //sem saldo	
							endif
				
						N8D->( MsUnlock() )
					endif
				next nB
			endif
						
		EndIf				
		nA++		
	endDo
	
return .t.

/*{Protheus.doc} CarrCtrArr
CarRega o array de dados do contrato
@author jean.schulze
@since 08/09/2017
@version undefined
@param aFldNJR, array, descricao
@param aFldNNY, array, descricao
@param aFldNNF, array, Campos da tabela de corretores
@param aFldN7R, array, Campos da tabela de Exportação/Portos
@param oModel, object, descricao
@type function
*/
Static Function CarrCtrArr(aFldNJR, aFldNNY, aFldNNF, aFldN7R, oModel)
	Local oModelN79 := oModel:GetModel("N79UNICO")  
	Local oModelN7A := oModel:GetModel("N7AUNICO")  
	Local oModelN8S := oModel:GetModel("N8SUNICO")   
	Local oModelN7C := oModel:GetModel("N7CUNICO")   
	Local aAux	    := {}
	Local cX	    := 0	
	Local nX	    := 0
	Local nQtdFut   := 0

	
	//dados NJR
	//Completo e Aprovado
	if oModelN79:GetValue("N79_STATUS") == '3' .AND. oModelN79:GetValue("N79_STCLIE") == '4' 
		aAdd( aFldNJR, { 'NJR_MODELO', '2'} ) 	//1=Pre-Contrato;2=Contrato;3=Automatico
	else
		aAdd( aFldNJR, { 'NJR_MODELO', '1'} ) 	//1=Pre-Contrato;2=Contrato;3=Automatico
	endif 
	aAdd( aFldNJR, { OGX700REL( "N79_OPENGC", 1, "FLD"), If( oModelN79:GetValue("N79_OPENGC") == '1', '1','2')} ) 		//1 = compra / 2 = vendas 
	aAdd( aFldNJR, { OGX700REL( "N79_DESCTR", 1, "FLD"), oModelN79:GetValue('N79_DESCTR')} )
	aAdd( aFldNJR, { OGX700REL( "N79_DATA", 1, "FLD"), oModelN79:GetValue('N79_DATA')} )
	
	//tratamento gmo
	aAdd( aFldNJR, { OGX700REL( "N79_GENMOD", 1, "FLD"), oModelN79:GetValue('N79_GENMOD')} )
	aAdd( aFldNJR, { OGX700REL( "N79_TECGMO", 1, "FLD"), oModelN79:GetValue('N79_TECGMO')} )

	if oModelN79:GetValue('N79_TPCONT') == "1" //Entidade
		aAdd( aFldNJR, { OGX700REL( "N79_CODENT", 1, "FLD"), oModelN79:GetValue('N79_CODENT')} )
		aAdd( aFldNJR, { OGX700REL( "N79_LOJENT", 1, "FLD"), oModelN79:GetValue('N79_LOJENT')} )
	endif	
	
	aAdd( aFldNJR, { OGX700REL( "N79_TIPMER", 1, "FLD")  , If( oModelN79:GetValue('N79_TIPMER') == '1', '1','2')} ) 		//1 = Interno / 2 = Externo
	
	aAdd( aFldNJR, { OGX700REL( "N79_CODOPE", 1, "FLD"), oModelN79:GetValue('N79_CODOPE')} )
	aAdd( aFldNJR, { OGX700REL( "N79_CODSAF", 1, "FLD"), oModelN79:GetValue('N79_CODSAF')} )
	aAdd( aFldNJR, { OGX700REL( "N79_CODPRO", 1, "FLD"), oModelN79:GetValue('N79_CODPRO')} )
	aAdd( aFldNJR, { OGX700REL( "N79_UM1PRO", 1, "FLD"), oModelN79:GetValue('N79_UM1PRO')} )
	aAdd( aFldNJR, { OGX700REL( "N79_UM2PRO", 1, "FLD"), oModelN79:GetValue('N79_UM2PRO')} )
	aAdd( aFldNJR, { OGX700REL( "N79_QTDUM2", 1, "FLD"), oModelN79:GetValue('N79_QTDUM2')} )
	aAdd( aFldNJR, { OGX700REL( "N79_OBSERV", 1, "FLD"), oModelN79:GetValue('N79_OBSERV')} )
	
	If !Empty(oModelN79:GetValue('N79_TABELA'))
		aAdd( aFldNJR, { OGX700REL( "N79_TABELA", 1, "FLD"), oModelN79:GetValue('N79_TABELA')} )
	EndIf
	
	aAdd( aFldNJR, { OGX700REL( "N79_QTDNGC", 1, "FLD"), oModelN79:GetValue('N79_QTDNGC')} )
	aAdd( aFldNJR, { OGX700REL( "N79_QTDNGC", 1, "FLD", 1), oModelN79:GetValue('N79_QTDNGC')} )
	aAdd( aFldNJR, { OGX700REL( "N79_TIPFIX", 1, "FLD"), oModelN79:GetValue('N79_TIPFIX')} )
	
	aAdd( aFldNJR, { OGX700REL( "N79_VLRUNI", 1, "FLD"), iif(oModelN79:GetValue('N79_VLRUNI') > 0, oModelN79:GetValue('N79_VLRUNI'), 0)} ) 
	aAdd( aFldNJR, { OGX700REL( "N79_VALOR", 1, "FLD"), iif(oModelN79:GetValue('N79_VALOR')  > 0, oModelN79:GetValue('N79_VALOR'), 0)} ) //verifica a unidade de medida
	aAdd( aFldNJR, { OGX700REL( "N79_VLRUNI", 1, "FLD", 1), iif(oModelN79:GetValue('N79_VLRUNI') > 0, oModelN79:GetValue('N79_VLRUNI'), 0)} ) //verifica a unidade de medida
		
	aAdd( aFldNJR, { OGX700REL( "N79_UMPRC", 1, "FLD"),  oModelN79:GetValue('N79_UMPRC')} )
	aAdd( aFldNJR, { OGX700REL( "N79_TPFRET", 1, "FLD"), oModelN79:GetValue('N79_TPFRET')} )
	aAdd( aFldNJR, { OGX700REL( "N79_MOEDA", 1, "FLD"),  oModelN79:GetValue('N79_MOEDA')} )
	aAdd( aFldNJR, { OGX700REL( "N79_MOEDA", 1, "FLD", 1),  oModelN79:GetValue('N79_MOEDA')} )
	aAdd( aFldNJR, { OGX700REL( "N79_MODAL", 1, "FLD"),  oModelN79:GetValue('N79_MODAL')} )
	aAdd( aFldNJR, { OGX700REL( "N79_CODFIN", 1, "FLD"),  oModelN79:GetValue('N79_CODFIN')} )
	aAdd( aFldNJR, { OGX700REL( "N79_CODNGC", 1, "FLD"), oModelN79:GetValue('N79_CODNGC')} )
	aAdd( aFldNJR, { OGX700REL( "N79_VERSAO", 1, "FLD"), oModelN79:GetValue('N79_VERSAO')} )
	aAdd( aFldNJR, { OGX700REL( "N79_BOLSA", 1, "FLD"),  oModelN79:GetValue('N79_BOLSA')} )

	If !Empty(oModelN79:GetValue('N79_INCOTE'))
	   aAdd( aFldNJR, { OGX700REL( "N79_INCOTE", 1, "FLD"), oModelN79:GetValue('N79_INCOTE')} )
	EndIf
	aAdd( aFldNJR, { OGX700REL( "N79_RESFIX", 1, "FLD"), oModelN79:GetValue('N79_RESFIX')} )

	//DAGROCOM-7282
    If oModelN79:HasField("N79_CLASSP")
        aAdd( aFldNJR, { OGX700REL( "N79_CLASSP", 1, "FLD"), oModelN79:GetValue('N79_CLASSP')} )
        aAdd( aFldNJR, { OGX700REL( "N79_CLASSQ", 1, "FLD"), oModelN79:GetValue('N79_CLASSQ')} )
    EndIf
	
	//dados cadencias
	For cX := 1 to oModelN7A:Length()
		oModelN7A:GoLine( cX )

		If __lCtrRisco
			nQtdFut := 0

			If __lCtrRisco
				For nX := 1 to oModelN7C:Length()			
					oModelN7C:GoLine( nX )

					nQtdFut += oModelN7C:GetValue('N7C_QTDCTR') //Somo as quantidades de todos os componentes por cadencia
				Next nX  
			EndIf
		EndIf
		
		aAux := {}
		aAdd(aAux, {OGX700REL( "N7A_CODCAD", 1, "FLD"),   oModelN7A:GetValue('N7A_CODCAD')})
		aAdd(aAux, {OGX700REL( "N7A_DATINI", 1, "FLD"), oModelN7A:GetValue('N7A_DATINI')})
		aAdd(aAux, {OGX700REL( "N7A_DATFIM", 1, "FLD"), oModelN7A:GetValue('N7A_DATFIM')})
		aAdd(aAux, {OGX700REL( "N7A_MESEMB", 1, "FLD"), oModelN7A:GetValue('N7A_MESEMB')})
		If !Empty(oModelN7A:GetValue('N7A_FILORG'))
			aAdd(aAux, {OGX700REL( "N7A_FILORG", 1, "FLD"), oModelN7A:GetValue('N7A_FILORG')})
		EndIf
		aAdd(aAux, {OGX700REL( "N7A_QTDINT", 1, "FLD"), oModelN7A:GetValue('N7A_QTDINT')})
		aAdd(aAux, {OGX700REL( "N7A_DTLFIX", 1, "FLD"), oModelN7A:GetValue('N7A_DTLFIX')})
		aAdd(aAux, {OGX700REL( "N7A_DTLTKP", 1, "FLD"), oModelN7A:GetValue('N7A_DTLTKP')})
		aAdd(aAux, {OGX700REL( "N7A_MESBOL", 1, "FLD"), oModelN7A:GetValue('N7A_MESBOL')})
		aAdd(aAux, {OGX700REL( "N7A_ENTORI", 1, "FLD"), oModelN7A:GetValue('N7A_ENTORI')})
		aAdd(aAux, {OGX700REL( "N7A_LOJORI", 1, "FLD"), oModelN7A:GetValue('N7A_LOJORI')})
		aAdd(aAux, {OGX700REL( "N7A_ENTDES", 1, "FLD"), oModelN7A:GetValue('N7A_ENTDES')})
		aAdd(aAux, {OGX700REL( "N7A_LOJDES", 1, "FLD"), oModelN7A:GetValue('N7A_LOJDES')})
		aAdd(aAux, {OGX700REL( "N7A_MESANO", 1, "FLD"), oModelN7A:GetValue('N7A_MESANO')})
		aAdd(aAux, {OGX700REL( "N7A_IDXNEG", 1, "FLD"), oModelN7A:GetValue('N7A_IDXNEG')})
		aAdd(aAux, {OGX700REL( "N7A_IDXCTF", 1, "FLD"), oModelN7A:GetValue('N7A_IDXCTF')})
		
		If __lCtrRisco
			aAdd(aAux, {OGX700REL( "N7C_QTDCTR", 1, "FLD"), nQtdFut })
		EndIf

		aAdd( aFldNNY, aAux )
	Next cX  

	//dados Corretor: No negócio existe a opção de informar apenas 1 corretor.
	aFldNNF := {}
	If !Empty(oModelN79:GetValue('N79_CODCOR')) .AND. !Empty(oModelN79:GetValue('N79_LOJCOR'))
	   aAux := {}
	   aAdd(aAux, {'NNF_ITEM'  , "001" })
	   aAdd(aAux, {OGX700REL( "N79_CODCOR", 1, "FLD"), oModelN79:GetValue('N79_CODCOR')})
	   aAdd(aAux, {OGX700REL( "N79_LOJCOR", 1, "FLD"), oModelN79:GetValue('N79_LOJCOR')})
	   aAdd( aFldNNF, aAux )
	EndIF

    //Dados de Logistica: Porto de Origem e Destino
    aFldN7R := {}
    if oModelN79:GetValue('N79_TIPMER') == "2" //somente se for externo
		For cX := 1 to oModelN8S:Length()
			oModelN8S:GoLine( cX )
			
			If !Empty(oModelN8S:GetValue('N8S_CODROT'))
				aAux := {}
				aAdd(aAux, {OGX700REL( "N8S_ITEM"  , 1, "FLD"), oModelN8S:GetValue('N8S_ITEM')})
				aAdd(aAux, {OGX700REL( "N8S_TIPO"  , 1, "FLD"), oModelN8S:GetValue('N8S_TIPO')})
				aAdd(aAux, {OGX700REL( "N8S_CODROT", 1, "FLD"), oModelN8S:GetValue('N8S_CODROT')})
				aAdd( aFldN7R, aAux )
			EndIf
		Next cX  
	endif
return .T.

/*{Protheus.doc} OGX700ERRO
Trata erro do model
@author jean.schulze
@since 01/11/2017
@version undefined
@param oModel, object, descricao
@type function
*/
Function OGX700ERRO(oModel)
	Local aErros := {}
	
	if oModel:HasErrorMessage()
		
		aErros := oModel:GetErrorMessage()
		if empty(aErros[6]) //exibe toda pilha de erro do model
			AutoGrLog( STR0030 + ' [' + AllToChar( aErros[1] ) + ']' )//"Id do formulário de origem:"
			AutoGrLog( STR0031 + ' [' + AllToChar( aErros[2] ) + ']' )//"Id do campo de origem: "
			AutoGrLog( STR0032 + ' [' + AllToChar( aErros[3] ) + ']' )//"Id do formulário de erro: "
			AutoGrLog( STR0033 + ' [' + AllToChar( aErros[4] ) + ']' )//"Id do campo de erro: "
			AutoGrLog( STR0034 + ' [' + AllToChar( aErros[5] ) + ']' )//"Id do erro: "
			AutoGrLog( STR0035 + ' [' + AllToChar( aErros[6] ) + ']' )//"Mensagem do erro: "
			AutoGrLog( STR0036 + ' [' + AllToChar( aErros[7] ) + ']' )//"Mensagem da solução: "
			AutoGrLog( STR0037 + ' [' + AllToChar( aErros[8] ) + ']' )//"Valor atribuído: "
			AutoGrLog( STR0038 + ' [' + AllToChar( aErros[9] ) + ']' )//"Valor anterior: "
			MostraErro()
		else //montamos um help
			Help( ,,STR0001,,aErros[6], 1, 0 ) //"AJUDA"
		endif
		
		return .t.
		
	endif
	
return .f.

/*{Protheus.doc} OGX700VSM0
//Valida a filial informada.
@author roney.maia
@since 06/12/2017
@version 1.0
@return ${return}, ${return_description}
@param cCampo, characters, descricao
@type function
*/
Function OGX700VSM0(cCampo, lConteud)

	Local aArea		:= GetArea()
	Local lRet		:= .F.
	Local aSM0		:= FwLoadSM0()
	Local cVlrCamp	:= ""
	Default lConteud := .F.
	
	If !lConteud
		If At("->", cCampo) > 0
			cVlrCamp := &(cCampo)
		Else
			cVlrCamp := FwFldGet(cCampo)
		EndIf
	Else
		cVlrCamp := cCampo
	EndIf
	
	// Posição 2 do array de Filiais contem o M0_CODFIL
	If aScan(aSM0, {|x| x[1] == cEmpAnt .AND. cVlrCamp $ x[2]}) > 0
		lRet := .T.
	EndIf
	
	RestArea(aArea)
	
Return lRet

/*{Protheus.doc} OGX700PSM0
//Recupera o campo M0_NOME da filial informada.
@author roney.maia
@since 06/12/2017
@version 1.0
@return ${return}, ${M0_FILIAL}
@param cCampo, characters, Campo Filial
@type function
*/
Function OGX700PSM0(cCampo)

	Local aArea		:= GetArea()
	Local aSM0		:= nil
	Local cValor	:= ""
	Local nPos		:= 0
	Local cVlrCamp	:= ""	
	
	If "NNY_FILORG" $ cCampo			
		cVlrCamp := M->NNY_FILORG
	Else
		If "N7A" $ cCampo
			If FWIsInCallStack("OGA700CPY") .AND. TYPE("_aNCPN7A") != "U" .AND. !Empty(_aNCPN7A) .AND. aScan(_aNCPN7A, {|x| "N7A_FILDES" $ x}) > 0 .AND. _lOGA700I
				_lOGA700I := .F.
				Return cValor
			EndIf
		EndIf
		
		If At("->", cCampo) > 0
			cVlrCamp := &(cCampo)
		Else
			cVlrCamp := &(substr(cCampo,1,3)+"->"+(cCampo))
		EndIf	
	EndIf

	If !Empty(cVlrCamp)
		aSM0 := FwLoadSM0()
		If (nPos := aScan(aSM0, {|x| x[1] == cEmpAnt .AND. cVlrCamp $ x[2]})) > 0
			cValor := aSM0[nPos][7] // Posição 6 do array SM0 contem o M0_FILIAL que seria a descrição
		EndIf
	EndIf
	
	RestArea(aArea)
	
Return cValor

/*{Protheus.doc} OGX700CNPJ
//Recupera o campo M0_CNPJ da filial informada.
@author marcelo.wesan
@since 26/02/2018
@version 1.0
@return ${return}, ${M0_CNPJ}
@param cCampo, characters, Campo cnpj
@type function
*/
Function OGX700CNPJ(cCampo)

	Local aArea		:= GetArea()
	Local aSM0		:= FwLoadSM0()
	Local cCnpj	    := ""
	Local nPos		:= 0
	Local cVlrCamp	:= ""
	
	If FWIsInCallStack("OGA700CPY") .AND. TYPE("_aNCPN7A") != "U" .AND. !Empty(_aNCPN7A) .AND. aScan(_aNCPN7A, {|x| "N7A_FILDES" $ x}) > 0 .AND. _lOGA700I
		_lOGA700I := .F.
		Return cCnpj
	EndIf
	
	If At("->", cCampo) > 0
		cVlrCamp := &(cCampo)
	Else
		cVlrCamp := FwFldGet(cCampo)
	EndIf
	
	If (nPos := aScan(aSM0, {|x| x[1] == cEmpAnt .AND. cVlrCamp $ x[2]})) > 0
		cCnpj := aSM0[nPos][18] // Posição 18 do array SM0 contem o M0_CGC que seria O cnpj
	EndIf
	
	RestArea(aArea)
	
Return cCnpj

/*{Protheus.doc} OGX700SLCA
//Retorna saldo disponível para cancelamento.
@author rafael.voltz
@since 20/12/2017
@version 1
@param cCodNgc, char, Código do Negócio
@param cVersao, char, Versão
@param cCodCad, char, Código da Cadência
@return nQtdCanc, Quantidade disponível para cancelamento
@example
(examples)
@see (links_or_references)
*/
Function OGX700SLCA(cCodNgc, cVersao, cCodCad)
	Local cAliasNN8 as char 
	Local nQtdCanc  as numeric 
		
	cAliasNN8 := GetNextAlias()
	nQtdCanc  := 0
	
	BeginSql Alias cAliasNN8

		SELECT (NN8_QTDFIX /* - (NN8_QTDRES + NN8_QTDENT)*/) QTD_CANCEL
	  	  FROM %Table:NN8% NN8 
		WHERE NN8.NN8_FILIAL = %xFilial:NN8% 
		  AND NN8.NN8_CODNGC = %exp:cCodNgc%
		  AND NN8.NN8_VERSAO = %exp:cVersao% 	 
		  AND NN8.NN8_CODCAD = %exp:cCodCad% 
		  AND NN8.%notDel%		 				         		           
	EndSQL
	
	DbselectArea( cAliasNN8 )
	DbGoTop()
	if ( cAliasNN8 )->( !Eof() )
	 	
	 	nQtdCanc := ( cAliasNN8 )->QTD_CANCEL //quantidade não vinculada
		
		( cAliasNN8 )->( dbSkip() )
	Endif
	
	( cAliasNN8 )->( dbCloseArea() )
		
return nQtdCanc

/*{Protheus.doc} OGX700CVUM
//Verifica se existe cadastro de fator de conversão de unidade de medida.
@author rafael.voltz
@since 26/12/2017
@version 1
@param cUMOrig, char, Unidade de Medida de Origem
@param cUMDest, char, Unidade de Medida Destino
@return lRet, True / False
@example
(examples)
@see (links_or_references)
*/
function OGX700CVUM(cUMOrig as char, cUMDest as char)
	Local lRet := .F.
	 
	dbSelectArea('NNX')
	dbSetOrder(1)
	 
	If dbSeek(xFilial('NNX')+cUMOrig+cUMDest)
		lRet := .T.
	ElseIf dbSeek(xFilial('NNX')+cUMDest+cUMOrig)
		lRet := .T.
	EndIf

Return lRet

/*{Protheus.doc} OGX700CNEG
//antes de reprovar o negócio, exclui o pré-contrato
@author Marcelo Ferrari
@since 09/11/2017
@version 1.0
@return ${return}, ${.T. - Ok, .F. - Pedido não gerado}
@param cFilNgc, characters, Filial do Negócio
@param cCodNgc, characters, Código do Negócio
@param cVersao, characters, Versão do Negócio
@type function
*/
Function OGX700CNEG(cCodCtr)
	Local aArea			:= GetArea()
	Local lRet 			:= .T.
	Local oModelNJR		:= Nil

	DbselectArea( "NJR" ) // Abre o alias da NJR - Cadencias do negócio
	NJR->(DbGoTop())
	NJR->(dbSetOrder(1))
	
	If NJR->(DbSeek( fwxFilial("NJR") + cCodCtr )) // Posiciona nas cadencias do negócio		
		
		If N79->N79_OPENGC = '2'
		   oModelNJR := FWLoadModel( 'OGA290' )
		ElseIf N79->N79_OPENGC = '1' //compras
		   oModelNJR := FWLoadModel( 'OGA280' )
		EndIf
		// definir a operação 5 - Exclusão
		oModelNJR:SetOperation(5)
		// Antes de atribuirmos os valores dos campos temos que ativar o modelo
		If !oModelNJR:Activate()
			cMsg := oModelNJR:GetErrorMessage()[3] + oModelNJR:GetErrorMessage()[6]
			//Help( ,,"AJUDA",,cMsg, 1, 0 ) //"AJUDA"
			HELP(' ',1,"AJUDA" ,,cMsg,2,0,,,,,, {oModelNJR:GetErrorMessage()[7]})
			lRet := .F.
		Else
			DbselectArea('N8D')
			DbSetOrder(1)			
			
			If DbSeek(FWxFilial('N8D')+ cCodCtr)
				While N8D->(!Eof()) .And. N8D->N8D_CODCTR == cCodCtr
					If Reclock('N8D', .F.)
						Dbdelete()
						MsUnLock()
					Endif			
					N8D->(DbSkip())		
				EndDo
			Endif

			// Faz-se a validação dos dados, note que diferentemente das tradicionais "rotinas automáticas"
			// neste momento os dados não são gravados, são somente validados.
			If ( lRet :=  oModelNJR:VldData() ) .OR. (IsInCallStack("OGA700REPR")) //Quando for rejeiç?o, deverá ignorar as validaç?es
				// Se o dados foram validados faz-se a gravação efetiva dos
				// dados (commit)
				If !(lRet := oModelNJR:CommitData())
			       cMsg := oModelNJR:GetErrorMessage()[3] + oModelNJR:GetErrorMessage()[6]
			       Help( ,,"AJUDA",,cMsg, 1, 0 ) //"AJUDA"
		           lRet := .F.
		        endif
		     else 	
		     	cMsg := oModelNJR:GetErrorMessage()[3] + oModelNJR:GetErrorMessage()[6]
		     	Help( ,,"AJUDA",,cMsg, 1, 0 ) //"AJUDA   
		   endif

		   N8D->(DbCloseArea())
		EndIf		
	EndIf	

	NJR->(DbGoTop())
	If lRet
	   lRet := !NJR->(DbSeek( fwxFilial("NJR") + cCodCtr ))  //se encontrar o contrato é porque não foi excluído
    EndIF
    RestArea(aArea)
Return lRet

/** {Protheus.doc} fGetParcRC
Função que retorna o número da proxima parcela do CReceber

@param: 	Prefixo e Titulo
@return:	cParcela 
@author: 	Equipe Agroindustria
@since: 	09/02/18
@Uso: 		OGX700
*/
Static Function fGetParcRC( cTitPrefix, cTitNum )
	Local aSaveArea 	:= GetArea()
	Local cAliasQry 	:= GetNextAlias()
	Local lSe1Comp		:= .f.
	Local cSe1FilTFil	:= ''
	
	
	lSE1Comp 	:= If(Empty(FWxFilial("SE1")), .T., .F.)
	
	IF lSe1Comp 
	   cSe1FilTFil := "%AND SE1.E1_FILORIG 	= '" + fwfilial() + "'%"
	Else
	   cSe1FilTFil := "%AND SE1.E1_FILIAL 	= '" + fWXfilial('SE1') + "'%"
	EndIF
	

	BeginSql Alias cAliasQry
		SELECT MAX(E1_PARCELA) as PROXPARC
		FROM %Table:SE1% SE1
			WHERE SE1.%notDel%
				%exp:cSe1FilTFil%
				AND E1_PREFIXO = %exp:cTitPrefix%
				AND E1_NUM = %exp:cTitNum%
	EndSQL

	DbselectArea( cAliasQry )
	DbGoTop()
	If ( cAliasQry )->( !Eof() )
		If !Empty( AllTrim( ( cAliasQry )->PROXPARC ) )
			cParcela := Soma1( ( cAliasQry )->PROXPARC )
		Else
			cParcela := StrZero( 1, TamSX3( "E1_PARCELA" )[1] )
		EndIf
	Else
		cParcela := StrZero( 1, TamSX3( "E1_PARCELA" )[1] )
	EndIf
	( cAliasQry )->( DbCloseArea() )

	RestArea( aSaveArea )
	 
	 
Return( cParcela )

/** {Protheus.doc} fGetParcPG
Função que retorna o número da proxima parcela do CPagar

@param: 	Prefixo e Titulo
@return:	cParcela 
@author: 	Equipe Agroindustria
@since: 	09/02/18
@Uso: 		OGX700
*/
Static Function fGetParcPG( cTitPrefix, cTitNum )
	Local aSaveArea 	:= GetArea()
	Local cAliasQry 	:= GetNextAlias()
	Local lSe2Comp		:= .f.
	Local cSe2FilTFil	:= ''
	
	lSE2Comp 	:= If(Empty(FWxFilial("SE2")), .T., .F.)
	
	IF lSE2Comp 
	   cSE2FilTFil := "%AND SE2.E2_FILORIG 	= '" + fwfilial() + "'%"
	Else
	   cSE2FilTFil := "%AND SE2.E2_FILIAL 	= '" + fWXfilial('SE2') + "'%"
	EndIF
	

	BeginSql Alias cAliasQry
		SELECT MAX(E2_PARCELA) as PROXPARC
		FROM %Table:SE2% SE2
			WHERE SE2.%notDel%
				%exp:cSE2FilTFil%
				AND E2_PREFIXO = %exp:cTitPrefix%
				AND E2_NUM = %exp:cTitNum%
	EndSQL

	DbselectArea( cAliasQry )
	DbGoTop()
	If ( cAliasQry )->( !Eof() )
		If !Empty( AllTrim( ( cAliasQry )->PROXPARC ) )
			cParcela := Soma1( ( cAliasQry )->PROXPARC )
		Else
			cParcela := StrZero( 1, TamSX3( "E2_PARCELA" )[1] )
		EndIf
	Else
		cParcela := StrZero( 1, TamSX3( "E2_PARCELA" )[1] )
	EndIf
	( cAliasQry )->( DbCloseArea() )

	RestArea( aSaveArea )
	 
	 
Return( cParcela )

/*{Protheus.doc} OGX700ACTR
//Função de validação de campos alterados do negócio.
@author roney.maia
@since 15/02/2018
@version 1.0
@return ${return}, ${.T. - Valido, .F. - Invalido}
@param oModel, object, Modelo Pai Negocio
@type function
*/
Function OGX700ACTR(oModel)
	
	Local aArea			:= GetArea()
	Local aAreaN7M      := N7M->(GetArea())
	Local cAltFields	:= SuperGetMv("MV_AGRO014", .F., "")
	
	Local oModelN79 	:= oModel:GetModel("N79UNICO")
	Local oModelN7A 	:= oModel:GetModel("N7AUNICO")  
	Local oModelN7C 	:= oModel:GetModel("N7CUNICO")  
	Local oModelN8S     := oModel:GetModel("N8SUNICO")  
	
	Local aMStruN79 	:= oModelN79:GetStruct():GetFields() // Obtem o array de campos da N79
	Local aMStruN7A 	:= oModelN7A:GetStruct():GetFields() // Obtem o array de campos da N7A
	Local aMStruN8S 	:= oModelN8S:GetStruct():GetFields() // Obtem o array de campos da N8S
		
	Local cFieldsN7A 	:= ""
	Local cFieldsN8S 	:= ""

	Local aFieldsN79 	:= {}
	Local aFieldsN7A 	:= {}
	Local aFieldsN8S 	:= {}
	Local aXFields		:= {}

	Local aCtrNgc		:= OGX700REL() // Obtém o array com a relação DE-PARA dos campos (contrato X negócio)
	
	Local oModelCtr		:= Nil
	Local oXCtrModel	:= Nil
	Local oXNgcModel	:= Nil
	
	Local nIt			:= 0
	Local nX			:= 0
	Local lRet			:= .T.
	Local aErro			:= {}
	Local lExist 		:= .F.
	Local lAltFlds		:= .F.
	Local aN7ADLin		:= {}
	Local aN8SDLin		:= {}
	Local lretN7C 		:= .F.
	Local nN7C			:= 0
	Local lConvtResv    := .f.
	Local iCont         := 0
	
	// ############# Verifica se algum dos campos modificados pertencem ao parametro de campos alterados para retorno do status cliente como Não Enviado ###
	For nIt := 1 To Len(oModel:aAllSubModels) // Verifica em cada submodelo que foi alterado, quail campo foi alterado e se algum esta contido no parametro.
		If oModel:aAllSubModels[nIt]:GetId() != "OGA700CALC1"  //pula o modelo de calc
			If oModel:aAllSubModels[nIt]:IsModified() 
				aXFields := oModel:aAllSubModels[nIt]:GetStruct():GetFields()
				For nX := 1 To Len(aXFields)		
					If oModel:aAllSubModels[nIt]:IsFieldUpdated(aXFields[nX][3]) .AND. aXFields[nX][3] $ cAltFields // Se encontrar algum parametro contido
						lAltFlds := .T. // Atribui Verdadeiro, há um campo alterado
						Exit
					EndIf
				Next nX
				If lAltFlds // Se ja encontrou um campo modificado dos campos do parametro então sai do lopp
					Exit
				EndIf
			Endif
		EndIf
	Next nIt
	
	// ######### Verificação de campos atualizados ##########
	
	// Verifica os campos alterados da N79
	If oModelN79:IsModified()
		For nIt := 1 To Len(aMStruN79)
			If oModelN79:IsFieldUpdated(aMStruN79[nIt][3])				
				aAdd(aFieldsN79, aMStruN79[nIt][3])
			EndIf
		Next nIt
	EndIf
	
	// Verifica os campos alterados de cada previsão de entrega
	
	If oModelN7A:IsModified()
		For nX := 1 To oModelN7A:Length()
			oModelN7A:GoLine(nX)
			cFieldsN7A := ""
			
			If !oModelN7A:IsDeleted()
				For nIt := 1 To Len(aMStruN7A)											 //Força a atualização do campo N7A_FILORG - DAGROCOM-7037
					If oModelN7A:IsFieldUpdated(aMStruN7A[nIt][3], nX) .Or. aMStruN7A[nIt][3] = "N7A_FILORG"
						cFieldsN7A += aMStruN7A[nIt][3] + ";"
					EndIf
				Next nIt
				If !Empty(cFieldsN7A)
					cFieldsN7A += "N7A_CODCAD;" // Adicionado para controle de linhas da grid
					aAdd(aFieldsN7A, {nX, cFieldsN7A})
				EndIf
			Else
				aAdd(aN7ADLin, nX)
			EndIf
		Next nX
	EndIf
	
	If oModelN8S:IsModified()
		For nX := 1 To oModelN8S:Length()
			oModelN8S:GoLine(nX)
			cFieldsN8S := ""
			
			If !oModelN8S:IsDeleted()
				For nIt := 1 To Len(aMStruN8S)
					If oModelN8S:IsFieldUpdated(aMStruN8S[nIt][3], nX)
						cFieldsN8S += aMStruN8S[nIt][3] + ";"
					EndIf
				Next nIt
				If !Empty(cFieldsN8S)
					cFieldsN8S += "N8S_ITEM;" // Adicionado para controle de linhas da grid
					aAdd(aFieldsN8S, {oModelN8S:GetValue("N8S_ITEM"), cFieldsN8S})
				EndIf
			Else
				aAdd(aN8SDLin, oModelN8S:GetValue("N8S_ITEM"))
			EndIf
		Next nX
	EndIf
	
	//Valida se algum registro foi alterado na N7C em cada N7A, solicitado na DAGROCOM-3799
	For nX := 1 To oModelN7A:Length()
		oModelN7A:GoLine(nX)
		for nN7C := 1 to oModelN7C:Length()
			oModelN7C:goline(nN7C)
			if oModelN7C:IsModified()
				lretN7C := .T.
				Exit
			endif
		next nN7C
	Next nX

	// ############## Verifica se existe algum campo alterado do contrato para validação
	For nIt := 1 To Len(aFieldsN79)
		If aScan(aCtrNgc, {|x| x[4] $ aFieldsN79[nIt] }) > 0
			lExist := .T.
		EndIf
	Next nIt
	
	For nIt := 1 To Len(aFieldsN7A)			
		If aScan(aCtrNgc, {|x| x[4] $ aFieldsN7A[nIt][2] }) > 0
			lExist := .T.
		EndIf
	Next nIt
	
	For nIt := 1 To Len(aFieldsN8S)			
		If aScan(aCtrNgc, {|x| x[4] $ aFieldsN8S[nIt][2] }) > 0
			lExist := .T.
		EndIf
	Next nIt
	
	//verifica se precisa atualizar o modelo do contrato
	If oModelN79:GetValue("N79_STATUS") == '3' .AND. oModelN79:GetValue("N79_STCLIE") == '4'
		lExist := .T.	
	Endif 
	
	// Validação se houve campos alterados
	If !lExist .and. !lretN7C
		RestArea(aArea)
		Return .T.
	EndIf
		
	dbSelectArea("NJR") // Abre o alias NJR para uso posterior no seek para procurar o contrato
	If lExist .and. NJR->(dbSeek(FwXFilial("NJR") + oModelN79:GetValue("N79_CODCTR"))) // Procura o contrato e posiciona respectivamente
		
		// Verifica quando o contrato será atualizado se é de compra ou venda
		If oModelN79:GetValue("N79_OPENGC") == '1' 
			oModelCtr := FWLoadModel('OGA280')
		ElseIf oModelN79:GetValue("N79_OPENGC") = '2'
			oModelCtr := FWLoadModel('OGA290')
		EndIf
	
		oModelCtr:SetOperation( MODEL_OPERATION_UPDATE )
		
		// Remoção de when de campos e obrigatoriedades
		For nIt := 1 To Len(oModelCtr:aAllSubModels)
			oModelCtr:aAllSubModels[nIt]:GetStruct():SetProperty( "*", MODEL_FIELD_OBRIGAT, .F.  )
			oModelCtr:aAllSubModels[nIt]:GetStruct():SetProperty( "*", MODEL_FIELD_WHEN, {| oField | .T. } ) 
		Next nIt
	
		IF oModelCtr:Activate()
		
			If oModelCtr:GetValue("NJRUNICO", "NJR_MODELO") != "1" .AND. !FWIsInCallStack("AGRXCNGC")
				RestArea(aArea)
				Return .T.
			EndIf
			
			// ############ Update de campos caso algum campo foi alterado ##################
			For nIt := 1 To Len(aFieldsN79)
			
				If (nPos := aScan(aCtrNgc, {|x| x[4] $ aFieldsN79[nIt] })) > 0
					oXCtrModel := oModelCtr:GetModel(aCtrNgc[nPos][1])
					oXNgcModel := oModel:GetModel(aCtrNgc[nPos][3])
					
					If Len(aCtrNgc[nPos]) > 4
						oXCtrModel:SetValue(aCtrNgc[nPos][2], oXNgcModel:GetValue(aCtrNgc[nPos][4]))
						For nX := 1 To aCtrNgc[nPos][5]	
							oXCtrModel:SetValue(aCtrNgc[nPos + nX][2], oXNgcModel:GetValue(aCtrNgc[nPos + nX][4]))
						Next nX
					Else
						oXCtrModel:SetValue(aCtrNgc[nPos][2], oXNgcModel:GetValue(aCtrNgc[nPos][4]))
					EndIf  
				EndIf
				
			Next nIt
			
			If oModelN79:GetValue("N79_STATUS") == '3' .AND. oModelN79:GetValue("N79_STCLIE") == '4'
				oModelCtr:SetValue("NJRUNICO", "NJR_MODELO", "2")  //contrato
				lConvtResv := .t. //seta para converter a reserva em especifica
			Endif 

			// Update NNY - N7A
			For nIt := 1 To Len(aFieldsN7A)
			
				oXCtrModel := oModelCtr:GetModel("NNYUNICO")
			
				oXCtrModel:SetNoInsertLine(.F.) // habilita inserção
				oXCtrModel:SetNoUpdateLine(.F.) // habilita atualização de campos
				
							
				If aFieldsN7A[nIt][1] > oXCtrModel:Length()  // Se é uma nova linha então adiciona a mesma
					oXCtrModel:AddLine()
				Else
					oXCtrModel:GoLine(aFieldsN7A[nIt][1])
				EndIf
				
				While (nPos := aScan(aCtrNgc, {|x| x[4] $ aFieldsN7A[nIt][2] })) > 0
					aFieldsN7A[nIt][2] := StrTran(aFieldsN7A[nIt][2], aCtrNgc[nPos][4], "")
					
					oXNgcModel := oModel:GetModel(aCtrNgc[nPos][3])
					oXCtrModel:SetValue(aCtrNgc[nPos][2], oXNgcModel:GetValue(aCtrNgc[nPos][4], aFieldsN7A[nIt][1]))
				End					
				
			Next nIt
			
			//força o update de datas da regra fiscal
			if Len(aFieldsN7A) > 0 .and. oModelCtr:getId() == "OGA290" .or. oModelCtr:getId() == "OGA280"
			   	oXCtrModel := oModelCtr:GetModel("N9AUNICO")
			  	For nIt := 1 To oXCtrModel:Length()
			   		oXCtrModel:GoLine(nIt)
			   		oXCtrModel:SetValue("N9A_DATINI",oModelCtr:GetModel("NNYUNICO"):GetValue("NNY_DATINI"))
			   		oXCtrModel:SetValue("N9A_DATFIM",oModelCtr:GetModel("NNYUNICO"):GetValue("NNY_DATFIM"))
			   	Next nIt
			endif
			
			//Delete de linhas caso deletadas N7A - NNY
			For nIt := 1 To Len(aN7ADLin)
				oXCtrModel := oModelCtr:GetModel("NNYUNICO")
				oXCtrModel:SetNoDeleteLine(.F.) // habilita o delete de linha
				
				If !(aN7ADLin[nIt] > oXCtrModel:Length())
					oXCtrModel:GoLine(aN7ADLin[nIt])

					cCodCtr := oModelCtr:GetModel("NJRUNICO"):GetValue("NJR_CODCTR")
					cSeq := oXCtrModel:GetValue("NNY_ITEM")

					DbselectArea('N7M')
					DbSetOrder(1)

					If N7M->(DbSeek(xFilial('N7M')+cCodCtr+cSeq))
						While N7M->(!Eof()) .And. N7M->N7M_CODCTR == cCodCtr .And. N7M->N7M_CODCAD == cSeq
							If RecLock('N7M', .F.)
								Dbdelete()
								MsUnLock()
							Endif
							N7M->(DbSkip())
						EndDo						
					Endif
					oXCtrModel:DeleteLine()
					N7M->(DbCloseArea())
				EndIf
			Next nIt
			
			// Update N7R - N8S
			For nIt := 1 To Len(aFieldsN8S)
			
				oXCtrModel := oModelCtr:GetModel("N7RUNICO")
			
				oXCtrModel:SetNoInsertLine(.F.) // habilita inserção
				oXCtrModel:SetNoUpdateLine(.F.) // habilita atualização de campos
				
				//posiciona no registro correto
				if !oXCtrModel:SeekLine( { {"N7R_ITEM", aFieldsN8S[nIt][1]  } } )
					oXCtrModel:AddLine()
				EndIf
				
				While (nPos := aScan(aCtrNgc, {|x| x[4] $ aFieldsN8S[nIt][2] })) > 0
					aFieldsN8S[nIt][2] := StrTran(aFieldsN8S[nIt][2], aCtrNgc[nPos][4], "")
					
					oXNgcModel := oModel:GetModel(aCtrNgc[nPos][3])
					if oXNgcModel:SeekLine( { {"N8S_ITEM", aFieldsN8S[nIt][1]  } } )
						oXCtrModel:SetValue(aCtrNgc[nPos][2], oXNgcModel:GetValue(aCtrNgc[nPos][4]))
					endif	
				End
		
			Next nIt
			
			//Delete de linhas caso deletadas N7R - N8S
			For nIt := 1 To Len(aN8SDLin)
				oXCtrModel := oModelCtr:GetModel("N7RUNICO")
				oXCtrModel:SetNoDeleteLine(.F.) // habilita o delete de linha
				
				if oXCtrModel:SeekLine( { {"N7R_ITEM", aN8SDLin[nIt]  } } )
					oXCtrModel:DeleteLine()
				EndIf
				
			Next nIt			
			
			// ############ Validação do modelo #############################################
			If lRet := oModelCtr:VldData()  // Valida o Model
				lRet := oModelCtr:CommitData() // Realiza o commit
			EndIf
									
			// ############ Montagem de mensagem de erro caso ocorrer algum erro na validação ou commit dos dados
			If !lRet
				aErro := oModelCtr:GetErrorMessage()
				
				AutoGrLog( STR0030 + ' [' + AllToChar( aErro[1] ) + ']' )//"Id do formulário de origem:"
				AutoGrLog( STR0031 + ' [' + AllToChar( aErro[2] ) + ']' )//"Id do campo de origem: "
				AutoGrLog( STR0032 + ' [' + AllToChar( aErro[3] ) + ']' )//"Id do formulário de erro: "
				AutoGrLog( STR0033 + ' [' + AllToChar( aErro[4] ) + ']' )//"Id do campo de erro: "
				AutoGrLog( STR0034 + ' [' + AllToChar( aErro[5] ) + ']' )//"Id do erro: "
				AutoGrLog( STR0035 + ' [' + AllToChar( aErro[6] ) + ']' )//"Mensagem do erro: "
				AutoGrLog( STR0036 + ' [' + AllToChar( aErro[7] ) + ']' )//"Mensagem da solução: "
				AutoGrLog( STR0037 + ' [' + AllToChar( aErro[8] ) + ']' )//"Valor atribuído: "
				AutoGrLog( STR0038 + ' [' + AllToChar( aErro[9] ) + ']' )//"Valor anterior: "

				If !IsBlind()
					MostraErro()
				EndIf

				lRet := .F.
			EndIf
			
			oModelCtr:DeActivate() // Desativa o model
			oModelCtr:Destroy() // Destroi o objeto do model
			
		EndIf	
	EndIf
	
	if lRet .and. lretN7C //refaz os valores das fixações
				
		//RESET NN8 
		DbSelectArea("NN8")
		NN8->(DbGoTop())
		if NN8->(DbSeek(FwxFilial("NN8")+oModelN79:GetValue("N79_CODCTR")))
			while FwxFilial("NN8")+oModelN79:GetValue("N79_CODCTR") == NN8->NN8_FILIAL+NN8->NN8_CODCTR
										
				If RecLock( "NN8", .f. )
					NN8->(dbdelete())
					msUnLock()
				EndIf
				
				NN8->(DbSkip())
			enddo	
		endif
		
		//RESET NKA
		DbSelectArea("NKA")
		NKA->(DbGoTop())
		if NKA->(DbSeek(FwxFilial("NKA")+oModelN79:GetValue("N79_CODCTR")))
			while FwxFilial("NKA")+oModelN79:GetValue("N79_CODCTR") == NKA->NKA_FILIAL+NKA->NKA_CODCTR
										
				If RecLock( "NKA", .f. )
					NKA->(dbdelete())
					MsUnLock()
				EndIf
				
				NKA->(DbSkip())
			enddo	
		endif
				
		//RESET N7M
		DbSelectArea("N7M")
		N7M->(DbGoTop())
		if N7M->(DbSeek(FwxFilial("N7M")+oModelN79:GetValue("N79_CODCTR")))
			while FwxFilial("N7M")+oModelN79:GetValue("N79_CODCTR") == N7M->N7M_FILIAL+N7M->N7M_CODCTR
										
				If RecLock( "N7M", .f. )
					N7M->(dbdelete())
					msUnLock()
				EndIf
				
				N7M->(DbSkip())
			enddo	
		endif
		
		//reset N7N
		DbSelectArea("N7N")
		N7N->(DbGoTop())
		if N7N->(DbSeek(FwxFilial("N7N")+oModelN79:GetValue("N79_CODCTR")))
			while FwxFilial("N7N")+oModelN79:GetValue("N79_CODCTR") == N7N->N7N_FILIAL+N7N->N7N_CODCTR
										
				If RecLock( "N7N", .f. )
					N7N->(dbdelete())
					MsUnLock()
				EndIf
				
				N7N->(DbSkip())
			enddo	
		endif
		
		//reset N7O
		DbSelectArea("N7O")
		N7O->(DbGoTop())
		if N7O->(DbSeek(FwxFilial("N7O")+oModelN79:GetValue("N79_CODNGC")+oModelN79:GetValue("N79_VERSAO")))
			while FwxFilial("N7O")+oModelN79:GetValue("N79_CODNGC")+oModelN79:GetValue("N79_VERSAO") == N7O->N7O_FILIAL+N7O->N7O_CODNGC+N7O_VERSAO
										
				If RecLock( "N7O", .f. )
					N7O->(dbdelete())
					MsUnLock()
				EndIf
				
				N7O->(DbSkip())
			enddo	
		endif
		
		//reset N8D
		DbSelectArea("N8D")
		N8D->(DbGoTop())
		if N8D->(DbSeek(FwxFilial("N8D")+oModelN79:GetValue("N79_CODCTR")))
			while FwxFilial("N8D")+oModelN79:GetValue("N79_CODCTR") == N8D->N8D_FILIAL+N8D->N8D_CODCTR
										
				If RecLock( "N8D", .f. )
					N8D->(dbdelete())
					MsUnLock()
				EndIf
				
				N8D->(DbSkip())
			enddo	
		endif
		                                                                                                                              		 
		If oModelN79:GetValue("N79_FIXAC") == "1" //fixação de preço
			//verifica se tem componente fixado - componentes fixados N7M e N7O- Negócios fixos X componentes fixos
			lRet := OGX700CPFX(oModel,oModelN79:GetValue("N79_CODCTR"))
			//verifica se é fixação de preço - NN8, NKA e N7N
			if lRet
				lRet := OGX700PRFX(oModel,oModelN79:GetValue("N79_CODCTR")) 
			endif
		else
			//verifica se tem componente fixado - componentes fixados N7M
			lRet := OGX700CPFX(oModel,oModelN79:GetValue("N79_CODCTR")) 
		endif 
		
	endif
	
	If lRet .AND. lAltFlds
		oModelN79:SetValue("N79_STCLIE", "1") // Atribui o status para não enviado, devido a alteração de campo pertencente ao parametro MV_AGRO014
	EndIf
	
	//refaz as reservas	
	if lConvtResv
		dbSelectArea("NJR") // Abre o alias NJR para uso posterior no seek para procurar o contrato
		If  NJR->(dbSeek(FwXFilial("NJR") + oModelN79:GetValue("N79_CODCTR")))
			
			For iCont := 1 to oModelN7A:Length()
				oModelN7A:GoLine( iCont )
			 
				if !oModelN7A:IsDeleted() .and. oModelN7A:GetValue( "N7A_USOFIX" ) <> "LBNO" //sem delete e marcado para fixar
					if !empty(oModelN7A:GetValue( "N7A_CODRES" ))
						//cria a reserva de contrato
						//edita a dxp direto
						dbSelectArea("DXP")
						dbSetOrder(1)
						If DXP->(dbSeek(FwXFilial("DXP")+oModelN7A:GetValue( "N7A_CODRES" )))
							RecLock( "DXP", .F. )
								DXP->DXP_CODCTP := NJR->NJR_CODCTR
								DXP->DXP_ITECAD := oModelN7A:GetValue( "N7A_CODCAD" )
								DXP->DXP_TIPRES := "1" //reserva de contrato		
								
								if !empty(NJR->NJR_TIPALG) .and. empty(DXP->DXP_CLACOM)
									DXP->DXP_CLACOM := NJR->NJR_TIPALG
								endif							
								
								if !empty(NJR->NJR_CODENT) .and. empty(DXP->DXP_CLIENT)
									DXP->DXP_CLIENT := NJR->NJR_CODENT
								endif
								
								if !empty(NJR->NJR_LOJENT) .and. empty(DXP->DXP_LJCLI)
									DXP->DXP_LJCLI:= NJR->NJR_LOJENT
								endif
															
							DXP->(MsUnLock())
						endif
					endif
				endif
				
			next iCont
		endif	
	endif	
		
	RestArea(aArea)
	RestArea(aAreaN7M)
	
Return lRet

/*{Protheus.doc} OGX700REL
//DE-PARA de campos do contrato para o negócio.
@author roney.maia
@since 14/02/2018
@version 1.0
@parameter cField - Nome do Campo que será pesquisado para retorno do campo referente da relação - * Obrigatório
@parameter nModo - Modo 1 - Negócio para Contrato, Modo 2 - Contrato para Negócio
@parameter cSubOrFld - "FLD" - Retorna o campo correspondente. "SUB" - retorna o submodelo correspondente.
@return ${return}, ${Array de campos relacionados contrato x negocio}
@type function
*/
Static Function OGX700REL( cField, nModo, cSubOrFld, nOrd)

	Local aRet 		 	:= __aNgcCtr
	Local nPos		 	:= 0
	Local cRet			:= ""
	
	Default cField 		:= ""
	Default nModo  		:= 1
	Default cSubOrFld	:= "FLD"
	Default nOrd		:= 0
	
		
	If Empty(cField) .AND. nModo == 1 .AND. cSubOrFld $ "FLD" // Se nenhum parametro foi informado então retorna o array de relação
		Return aRet
	EndIf
	
	Do Case
		Case nModo == 1 // De Negócio para Contrato - Retorna Contrato
			If (nPos := aScan(aRet, {|x| x[4] $ cField})) > 0
				If cSubOrFld $ "FLD" // Retorna campo referente ao contrato
					If nOrd != 0
						cRet := aRet[nPos + nOrd][2]
					Else
						cRet := aRet[nPos][2]
					EndIf
				EndIf
				If cSubOrFld $ "SUB" // Retorna submodelo referente ao contrato
					If nOrd != 0
						cRet := aRet[nPos + nOrd][1]
					Else
						cRet := aRet[nPos][1]
					EndIf
				EndIf	
			EndIf
			
		Case nModo == 2 // De Contrato para Negócio - Retorna negócio
			If (nPos := aScan(aRet, {|x| x[2] $ cField})) > 0
				If cSubOrFld $ "FLD" // Retorna campo referente ao contrato
					If nOrd != 0
						cRet := aRet[nPos + nOrd][4]
					Else
						cRet := aRet[nPos][4]
					EndIf
				EndIf
				If cSubOrFld $ "SUB" // Retorna submodelo referente ao contrato
					If nOrd != 0
						cRet := aRet[nPos + nOrd][3]
					Else
						cRet := aRet[nPos][3]
					EndIf
				EndIf
			EndIf
	EndCase
	
Return cRet

/*{Protheus.doc} OGX700DEP
De-Para de Campos do Contrato X Negociação
@author jean.schulze
@since 21/02/2018
@version 1.0
@return ${return}, ${return_description}

@type function
*/
Static Function OGX700DEP()

	Local aRet := {}
	
	// ####################### ARRAY COM RELAÇÃO DE CAMPOS ENTRE O NEGÓCIO E O CONTRATO ################
	// Tabela - NJR
	aAdd(aRet, {'NJRUNICO' ,'NJR_TIPO'  , 'N79UNICO', 'N79_OPENGC'}) 
	aAdd(aRet, {'NJRUNICO', 'NJR_DESCRI', 'N79UNICO', 'N79_DESCTR'}) 
	aAdd(aRet, {'NJRUNICO', 'NJR_OBSADT', 'N79UNICO', 'N79_OBSERV'}) 
	aAdd(aRet, {'NJRUNICO', 'NJR_DATA'  , 'N79UNICO', 'N79_DATA'}) 
	aAdd(aRet, {'NJRUNICO', 'NJR_CODENT', 'N79UNICO', 'N79_CODENT'}) 
	aAdd(aRet, {'NJRUNICO', 'NJR_LOJENT', 'N79UNICO', 'N79_LOJENT'}) 
	aAdd(aRet, {'NJRUNICO', 'NJR_CODOPE', 'N79UNICO', 'N79_CODOPE'}) 
	aAdd(aRet, {'NJRUNICO', 'NJR_CODSAF', 'N79UNICO', 'N79_CODSAF'}) 
	aAdd(aRet, {'NJRUNICO', 'NJR_CODPRO', 'N79UNICO', 'N79_CODPRO'})
	aAdd(aRet, {'NJRUNICO', 'NJR_UM1PRO', 'N79UNICO', 'N79_UM1PRO'})
	aAdd(aRet, {'NJRUNICO', 'NJR_UM2PRO', 'N79UNICO', 'N79_UM2PRO'})
	aAdd(aRet, {'NJRUNICO', 'NJR_QTDUM2', 'N79UNICO', 'N79_QTDUM2'})
	aAdd(aRet, {'NJRUNICO', 'NJR_TABELA', 'N79UNICO', 'N79_TABELA'}) 
	
	aAdd(aRet, {'NJRUNICO', 'NJR_TIPFIX', 'N79UNICO', 'N79_TIPFIX'}) 
	
	aAdd(aRet, {'NJRUNICO', 'NJR_VLRTOT', 'N79UNICO', 'N79_VALOR'})
	 
	aAdd(aRet, {'NJRUNICO', 'NJR_UMPRC' , 'N79UNICO', 'N79_UMPRC'})
	aAdd(aRet, {'NJRUNICO', 'NJR_TPFRET', 'N79UNICO', 'N79_TPFRET'})
	aAdd(aRet, {'NJRUNICO', 'NJR_MOEDA' , 'N79UNICO', 'N79_MOEDA'})
	aAdd(aRet, {'NJRUNICO', 'NJR_MOEDAR', 'N79UNICO', 'N79_MOEDA'})
	aAdd(aRet, {'NJRUNICO', 'NJR_MODAL' , 'N79UNICO', 'N79_MODAL'})
	aAdd(aRet, {'NJRUNICO', 'NJR_CODFIN', 'N79UNICO', 'N79_CODFIN'})
	aAdd(aRet, {'NJRUNICO', 'NJR_CODNGC', 'N79UNICO', 'N79_CODNGC'})
	aAdd(aRet, {'NJRUNICO', 'NJR_VERSAO', 'N79UNICO', 'N79_VERSAO'})
	aAdd(aRet, {'NJRUNICO', 'NJR_BOLSA' , 'N79UNICO', 'N79_BOLSA'})	
	aAdd(aRet, {'NJRUNICO', 'NJR_TIPMER', 'N79UNICO', 'N79_TIPMER'}) 			
	aAdd(aRet, {'NJRUNICO', 'NJR_INCOTE', 'N79UNICO', 'N79_INCOTE'})
	aAdd(aRet, {'NJRUNICO', 'NJR_RESFIX', 'N79UNICO', 'N79_RESFIX'})
	//tratamento gmo
	aAdd(aRet, {'NJRUNICO', 'NJR_GENMOD', 'N79UNICO', 'N79_GENMOD'})
	aAdd(aRet, {'NJRUNICO', 'NJR_MSGNFS', 'N79UNICO', 'N79_TECGMO'})
	
	// De - Para Mais de um Campo
	aAdd(aRet, {'NJRUNICO', 'NJR_QTDINI', 'N79UNICO', 'N79_QTDNGC', 1}) // Quarto parametro para informar quantidade repetida
	aAdd(aRet, {'NJRUNICO', 'NJR_QTDCTR', 'N79UNICO', 'N79_QTDNGC'}) 
	
	aAdd(aRet, {'NJRUNICO', 'NJR_VLRBAS', 'N79UNICO', 'N79_VLRUNI', 1})
	aAdd(aRet, {'NJRUNICO', 'NJR_VLRUNI', 'N79UNICO', 'N79_VLRUNI'})

	//DAGROCOM-7282
	aAdd(aRet, {'NJRUNICO', 'NJR_CLASSP', 'N79UNICO', 'N79_CLASSP'})
	aAdd(aRet, {'NJRUNICO', 'NJR_CLASSQ', 'N79UNICO', 'N79_CLASSQ'}) 
	
	// Tabela - NNY     
	aAdd(aRet, {'NNYUNICO', 'NNY_ITEM'  , 'N7AUNICO', 'N7A_CODCAD'})
	aAdd(aRet, {'NNYUNICO', 'NNY_DATINI', 'N7AUNICO', 'N7A_DATINI'})
	aAdd(aRet, {'NNYUNICO', 'NNY_DATFIM', 'N7AUNICO', 'N7A_DATFIM'})
	aAdd(aRet, {'NNYUNICO', 'NNY_MESEMB', 'N7AUNICO', 'N7A_MESEMB'})
	aAdd(aRet, {'NNYUNICO', 'NNY_FILORG', 'N7AUNICO', 'N7A_FILORG'})
	aAdd(aRet, {'NNYUNICO', 'NNY_QTDINT', 'N7AUNICO', 'N7A_QTDINT'})
	aAdd(aRet, {'NNYUNICO', 'NNY_DTLFIX', 'N7AUNICO', 'N7A_DTLFIX'})
	aAdd(aRet, {'NNYUNICO', 'NNY_DTLTKP', 'N7AUNICO', 'N7A_DTLTKP'})
	aAdd(aRet, {'NNYUNICO', 'NNY_MESBOL', 'N7AUNICO', 'N7A_MESBOL'})
	aAdd(aRet, {'NNYUNICO', 'NNY_ENTORI', 'N7AUNICO', 'N7A_ENTORI'})
	aAdd(aRet, {'NNYUNICO', 'NNY_LOJORI', 'N7AUNICO', 'N7A_LOJORI'})
	aAdd(aRet, {'NNYUNICO', 'NNY_ENTDES', 'N7AUNICO', 'N7A_ENTDES'})
	aAdd(aRet, {'NNYUNICO', 'NNY_LOJDES', 'N7AUNICO', 'N7A_LOJDES'})
	aAdd(aRet, {'NNYUNICO', 'NNY_MESANO', 'N7AUNICO', 'N7A_MESANO'})
	aAdd(aRet, {'NNYUNICO', 'NNY_IDXNEG', 'N7AUNICO', 'N7A_IDXNEG'})
	aAdd(aRet, {'NNYUNICO', 'NNY_IDXCTF', 'N7AUNICO', 'N7A_IDXCTF'})
	aAdd(aRet, {'NNYUNICO', 'NNY_QTDCTR', 'N7CUNICO', 'N7C_QTDCTR'})
    
    // Tabela - NNF     
	aAdd(aRet, {'NNFUNICO', 'NNF_CODENT', 'N79UNICO', 'N79_CODCOR'})
	aAdd(aRet, {'NNFUNICO', 'NNF_LOJENT', 'N79UNICO', 'N79_LOJCOR'})
    
    // Tabela - N7R   
    aAdd(aRet, {'N7RUNICO', 'N7R_ITEM'  , 'N8SUNICO', 'N8S_ITEM'})  
    aAdd(aRet, {'N7RUNICO', 'N7R_TIPO'  , 'N8SUNICO', 'N8S_TIPO'})
	aAdd(aRet, {'N7RUNICO', 'N7R_CODROT', 'N8SUNICO', 'N8S_CODROT'})
	
	// ######################################################################################

Return aRet

/*{Protheus.doc} OGX700QCTR
Alteração de quantidade do contrato (adição/supressão)
@author niara.caetano
@since 12/03/2018
@version 1.0
@return ${return}, ${return_description}

@type function
*/
function OGX700QCTR(nTotal, oModel)
	Local oModelN79 := oModel:GetModel("N79UNICO")
	Local oModelNNW	:= Nil
	Local lRet 		:= .T.
	Local nItErro 	:= 0
	

	oModelNNW := FWLoadModel( 'OGA335' )
		
	// Temos que definir qual a operação deseja: 3 – Inclusão / 4 – Alteração / 5 - Exclusão
	oModelNNW:SetOperation( 3 )
	
	// Antes de atribuirmos os valores dos campos temos que ativar o modelo
	oModelNNW:Activate()
		
	// Instanciamos apenas a parte do modelo referente aos dados de cabeçalho
	//oAux := oModelNNW:GetModel( 'NNWUNICO' )   
	
	// Obtemos a estrutura de dados do cabeçalho
	//oStruct := oAux:GetStruct()
	//aAux    := oStruct:GetFields()
		
	oModelNNW:SetValue( 'NNWUNICO', "NNW_CODCTR", oModelN79:GetValue("N79_CODCTR") )
	oModelNNW:SetValue( 'NNWUNICO', "NNW_TIPO",   '2'  )  //supressão
	oModelNNW:SetValue( 'NNWUNICO', "NNW_DATA",   DATE()  )  
	oModelNNW:SetValue( 'NNWUNICO', "NNW_QTDALT", nTotal  )
	oModelNNW:SetValue( 'NNWUNICO', "NNW_STATUS", '1'  ) //previsto
	oModelNNW:SetValue( 'NNWUNICO', "NNW_CODMTV", oModelN79:GetValue("N79_CODMTV") )  

	If lRet
		If ( lRet := oModelNNW:VldData() ) 
			lRet := oModelNNW:CommitData()
		EndIf
 	EndIf
 	
 	if lRet = .F. 
		aErro := oModelNNW:GetErrorMessage()
			
		AutoGrLog( STR0030 + ' [' + AllToChar( aErro[1] ) + ']' )//"Id do formulário de origem:"
		AutoGrLog( STR0031 + ' [' + AllToChar( aErro[2] ) + ']' )//"Id do campo de origem: "
		AutoGrLog( STR0032 + ' [' + AllToChar( aErro[3] ) + ']' )//"Id do formulário de erro: "
		AutoGrLog( STR0033 + ' [' + AllToChar( aErro[4] ) + ']' )//"Id do campo de erro: "
		AutoGrLog( STR0034 + ' [' + AllToChar( aErro[5] ) + ']' )//"Id do erro: "
		AutoGrLog( STR0035 + ' [' + AllToChar( aErro[6] ) + ']' )//"Mensagem do erro: "
		AutoGrLog( STR0036 + ' [' + AllToChar( aErro[7] ) + ']' )//"Mensagem da solução: "
		AutoGrLog( STR0037 + ' [' + AllToChar( aErro[8] ) + ']' )//"Valor atribuído: "
		AutoGrLog( STR0038 + ' [' + AllToChar( aErro[9] ) + ']' )//"Valor anterior: "
		If nItErro > 0
			AutoGrLog( STR0039 + ' [' + AllTrim( AllToChar( nItErro ) ) + ']' )//"Erro no Item: "
		EndIf
		MostraErro()
			
		lRet := .F.
	
		Help( ,,STR0001,,STR0043, 1, 0 ) //"AJUDA"#"Não foi possivel gerar alteração no contrato."
	end if
	
	oModelNNW:DeActivate()
	
	If lRet 		
		
		//confirma a alteração no OGA335
		lRet := OGX700CAQC(oModel)
	
	endIf

return (lRet)


/*{Protheus.doc} OGX700CAQC
Alteração de quantidade do contrato (adição/supressão)
@author niara.caetano
@since 12/03/2018
@version 1.0
@return ${return}, ${return_description}

@type function
*/
function OGX700CAQC(oModel)
	Local oModelN7A := oModel:GetModel("N7AUNICO")
	Local oModelNNW	:= Nil
	Local oAux 		:= Nil
	Local oStruct	:= Nil
	Local nI 		:= 0
	Local lRet 		:= .T.
	Local aAux 		:= {}
	Local nItErro 	:= 0
	
	/*     MODEL PARA ALTERAÇÃO DA NNY  */

	oModelNNW := FWLoadModel( 'OGA335' )
		
	// Temos que definir qual a operação deseja: 3 – Inclusão / 4 – Alteração / 5 - Exclusão
	oModelNNW:SetOperation( 4 )
	
	// Antes de atribuirmos os valores dos campos temos que ativar o modelo
	oModelNNW:Activate()
		
	oModelNNW:SetValue( 'NNWUNICO', "NNW_STATUS", '2'  ) //confirmado
		
	// Instanciamos apenas a parte do modelo referente aos dados do item
	oAux := oModelNNW:GetModel( 'NNYUNICO' )
	oModelNNY := oModelNNW:GetModel( 'NNYUNICO' )
	// Obtemos a estrutura de dados do item
	oStruct := oAux:GetStruct()
	aAux := oStruct:GetFields()
	nItErro := 0

	For nI := 1 To oModelN7A:Length()
			
		oModelN7A:GoLine(nI)
		oModelNNY:GoLine(nI)
		
		//oModelNNW:SetValue( 'NNYUNICO', "TMP_QTDALT", oModelN7A:GetValue("N7A_QTDINT") )
		oModelNNY:SetValue("TMP_QTDALT", oModelN7A:GetValue("N7A_QTDINT") )
			
	Next nI
		
	// Faz-se a validação dos dados, note que diferentemente das tradicionais "rotinas automáticas"
	// neste momento os dados não são gravados, são somente validados.
	If ( lRet := oModelNNW:VldData() ) 
		lRet := oModelNNW:CommitData()
	EndIf
		 	
		
	If lRet = .F.
		// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
		aErro := oModelNNW:GetErrorMessage()
		
		AutoGrLog( STR0030 + ' [' + AllToChar( aErro[1] ) + ']' )//"Id do formulário de origem:"
		AutoGrLog( STR0031 + ' [' + AllToChar( aErro[2] ) + ']' )//"Id do campo de origem: "
		AutoGrLog( STR0032 + ' [' + AllToChar( aErro[3] ) + ']' )//"Id do formulário de erro: "
		AutoGrLog( STR0033 + ' [' + AllToChar( aErro[4] ) + ']' )//"Id do campo de erro: "
		AutoGrLog( STR0034 + ' [' + AllToChar( aErro[5] ) + ']' )//"Id do erro: "
		AutoGrLog( STR0035 + ' [' + AllToChar( aErro[6] ) + ']' )//"Mensagem do erro: "
		AutoGrLog( STR0036 + ' [' + AllToChar( aErro[7] ) + ']' )//"Mensagem da solução: "
		AutoGrLog( STR0037 + ' [' + AllToChar( aErro[8] ) + ']' )//"Valor atribuído: "
		AutoGrLog( STR0038 + ' [' + AllToChar( aErro[9] ) + ']' )//"Valor anterior: "
		If nItErro > 0
			AutoGrLog( STR0039 + ' [' + AllTrim( AllToChar( nItErro ) ) + ']' )//"Erro no Item: "
		EndIf
		MostraErro()
			
		Help( ,,STR0001,,STR0043, 1, 0 ) //"AJUDA"#"Não foi possivel gerar alteração no contrato."
					
	EndIf
	
	oModelNNW:DeActivate()
	
return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} OGX700TBLQ
Verifica saldo em aprovação de negócio e trabalhando da fixação
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Function OGX700CBLQ(cFilNgc, cCodCtr, cCodCad, cCodCom, cCodNeg, cVersao)
	Local cAliasQry := GetNextAlias()
	Local nQtdFix 	:= 0
	Local cJoin     := ""
	Local cWhere    := ""
	Local cSelect   := "SUM(N7A_QTDINT) QTDAFIX"
	
	
	If !Empty(cCodCom)
		cSelect := "SUM(N7C_QTAFIX) QTDAFIX"
		cJoin   := "INNER JOIN " + RETSQLNAME("N7C") + " N7C ON N7C.N7C_FILIAL = N7A.N7A_FILIAL AND N7C.N7C_CODNGC = N7A.N7A_CODNGC AND N7C.N7C_VERSAO = N7A.N7A_VERSAO AND N7C.N7C_CODCAD = N7A.N7A_CODCAD AND N7C.D_E_L_E_T_ = ''"
		cWhere  := "AND N7C.N7C_CODCOM = '" + Alltrim(cCodCom) + "'  AND N7C.N7C_QTAFIX > 0"		
	EndIf
	
	cSelect := "%" + cSelect  	+ "%"
	cJoin  	:= "%" + cJoin  	+ "%"
	cWhere 	:= "%" + cWhere 	+ "%"

	BeginSql Alias cAliasQry
		SELECT %Exp:cSelect%
		  FROM %table:N79% N79
		 INNER JOIN %table:N7A% N7A ON N7A.N7A_FILIAL = N79.N79_FILIAL AND N7A.N7A_CODNGC = N79.N79_CODNGC AND N7A.N7A_VERSAO = N79.N79_VERSAO AND N7A.%notDel%
		 %Exp:cJoin%
		 WHERE N79.N79_FILIAL = %Exp:cFilNgc%
		   AND N79.N79_CODCTR = %Exp:cCodCtr%
		   AND N79.N79_TIPO   = '2'  //fixação 		   
		   AND N7A.N7A_CODCAD = %Exp:cCodCad%
		   AND (N79.N79_CODNGC != %Exp:cCodNeg% OR N79.N79_VERSAO != %Exp:cVersao% ) 	   
		   AND N79.N79_STATUS NOT IN ('3','4','5') //apenas o que está em andamento - aprovação
		   AND N79.%notDel%	
		   %Exp:cWhere%
	EndSql

	While (cAliasQry)->(!Eof())		
		nQtdFix += (cAliasQry)->QTDAFIX
		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())	
	

Return nQtdFix


//-------------------------------------------------------------------
/*/{Protheus.doc} OGX700MFIX
Verifica maior fixação (preço + componente) pendente, para mostrar
o a quantidade disponível para fixação de preço.
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Function OGX700MFIX(cFilNgc, cCodCtr, cCodCad, cCodNeg, cVersao)
	Local cAliasQry := GetNextAlias()
	Local nMaiorFixa := 0

	BeginSql Alias cAliasQry
		SELECT SUM(N7C_QTAFIX) N7C_QTAFIX , N7C_CODCOM
		  FROM %table:N79% N79
		 INNER JOIN %table:N7A% N7A  ON N7A.N7A_FILIAL = N79.N79_FILIAL AND N7A.N7A_CODNGC = N79.N79_CODNGC AND N7A.N7A_VERSAO = N79.N79_VERSAO AND N7A.%notDel%
		 INNER JOIN %table:N7C% N7C  ON N7C.N7C_FILIAL = N7A.N7A_FILIAL AND N7C.N7C_CODNGC = N7A.N7A_CODNGC AND N7C.N7C_VERSAO = N7A.N7A_VERSAO AND N7C.N7C_CODCAD = N7A.N7A_CODCAD AND N7C.%notDel%
		 WHERE N79.N79_FILIAL = %Exp:cFilNgc%
		   AND N79.N79_CODCTR = %Exp:cCodCtr%
		   AND N79.N79_TIPO   = '2'  //fixação 		   
		   AND N7A.N7A_CODCAD = %Exp:cCodCad%
		   AND N79.N79_STATUS NOT IN ('3','4','5') //apenas o que está em andamento - aprovação
		   AND (N79.N79_CODNGC != %Exp:cCodNeg% OR N79.N79_VERSAO != %Exp:cVersao% ) 	   
		   AND N79.%notDel%			   
		   AND N7C.N7C_QTAFIX > 0
		   GROUP BY N7C_CODCOM
	EndSql

	While (cAliasQry)->(!Eof())		
		If (cAliasQry)->N7C_QTAFIX > nMaiorFixa 
			nMaiorFixa := (cAliasQry)->N7C_QTAFIX		
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo*/
	(cAliasQry)->(dbCloseArea())

	BeginSql Alias cAliasQry
		SELECT N79_FILIAL , N79_CODCTR, N7A_CODCAD, SUM(N7A_QTDINT) N7A_QTDINT 
		  FROM %table:N79% N79
		 INNER JOIN %table:N7A% N7A  ON N7A.N7A_FILIAL = N79.N79_FILIAL 
		 							AND N7A.N7A_CODNGC = N79.N79_CODNGC 
		 							AND N7A.N7A_VERSAO = N79.N79_VERSAO 
		 							AND N7A.%notDel%
		 WHERE N79.N79_FILIAL = %Exp:cFilNgc%
		   AND N79.N79_CODCTR = %Exp:cCodCtr%
		   AND N7A.N7A_CODCAD = %Exp:cCodCad%
		   AND N7A.N7A_USOFIX <> 'LBNO'
		   AND N79.N79_TIPO   = '2'  //fixação 
		   AND N79.N79_STATUS NOT IN ('3','4','5') //apenas o que está em andamento - aprovação
		   AND (N79.N79_CODNGC <> %Exp:cCodNeg% OR N79.N79_VERSAO <> %Exp:cVersao%		)		   
		   AND N79.%notDel%			   
		   GROUP BY N79_FILIAL , N79_CODCTR, N7A_CODCAD
	EndSql
	
	
	DbselectArea( cAliasQry )
	(cAliasQry)->(DbGoTop())

	if (cAliasQry)->(!Eof())
		nMaiorFixa := (cAliasQry)->N7A_QTDINT			
	Endif
	
	(cAliasQry)->(dbCloseArea())	

Return nMaiorFixa

//-------------------------------------------------------------------
/*/{Protheus.doc} OGX700SLFX
Função para atualizar quantidade alocada e saldo dos componentes fixados
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Function OGX700SLFX(oModel)
	Local lRet := .T.
	Local nA   := 1
	Local nB   := 0
	Local nC   := 0
	Local oModelN7C  := oModel:GetModel("N7CUNICO") 
	Local oModelN7A	 := oModel:GetModel("N7AUNICO")
	Local oModelN7O	 := oModel:GetModel("N7OUNICO")
	Local oModelN79	 := oModel:GetModel("N79UNICO")
	

	//grava os demais componentes na tabela de componentes 
	If (oModelN79:GetValue("N79_TIPO") == "2" .AND. oModelN79:GetValue("N79_FIXAC")  == '1') .AND. (!FWIsInCallStack("OGA700APVA") .OR. oModelN79:GetValue("N79_STATUS") == '4') //nao for acao de aprovacao ou status de rejeicao, pois é alocado na inclusao
		while nA <= oModelN7A:Length() //percorre as cadencias 
			If !oModelN7A:IsDeleted() .and. oModelN7A:GetValue( "N7A_USOFIX" ) <> "LBNO" .and. oModelN7C:GetValue("N7C_QTAFIX") > 0
			
				oModelN7A:GoLine( nA )	
				For nB := 1 to oModelN7C:Length() //percorre os componentes da cadencia
					oModelN7C:GoLine( nB )					
					
					//debita as quantidades nas fixações alocadas  
					For nC := 1 to oModelN7O:Length() //percorre as fixações utilizadas do componente
						oModelN7O:GoLine( nC )

						DbselectArea( "N7M" )
						N7M->(DbGoTop())
						N7M->(dbSetOrder(1))
						if N7M->(DbSeek(oModelN79:GetValue("N79_FILIAL")+oModelN7O:GetValue("N7O_CODCTR")+oModelN7A:GetValue("N7A_CODCAD")+oModelN7C:GetValue("N7C_CODCOM")+oModelN7O:GetValue("N7O_SEQFIX")))
							If oModelN79:GetValue("N79_STATUS") == '4' //rejeitado
								Reclock("N7M", .F.)								
									N7M->N7M_QTDALO -= oModelN7O:GetValue("N7O_QTDALO")
									N7M->N7M_QTDSLD += oModelN7O:GetValue("N7O_QTDALO")							  								
								N7M->(MsUnlock())     // Destrava o registro	
							Else
								if N7M->N7M_QTDSLD >= oModelN7O:GetValue("N7O_QTDALO")	
									Reclock("N7M", .F.)										
										N7M->N7M_QTDALO += oModelN7O:GetValue("N7O_QTDALO")
										N7M->N7M_QTDSLD -= oModelN7O:GetValue("N7O_QTDALO")							  										
									N7M->(MsUnlock())     // Destrava o registro	
								else 
									oModel:GetModel():SetErrorMessage( oModelN79:GetId(), , oModelN79:GetId(), "", "", STR0042, "", "") //"Houve um problema ao consumir o saldo do componente já fixado."
									return .f.
								endif	
							EndIf							
						endif
					Next nC									
				Next nB			
			EndIf
			nA++		
		EndDo	
	EndIf

Return lRet


/*/{Protheus.doc} OGX700NCT
//Verifica Vínculo da Fixacao com contratos futuros
@author carlos.augusto
@since 23/11/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function OGX700NCT(oModel)
	Local lRet := .T.
	Local x	   := 0
	Local y	   := 0
	Local nX
	Local nY
	Local oModelN7C := oModel:GetModel( "N7CUNICO" )
	Local oModelN7A := oModel:GetModel("N7AUNICO")
	Local lHedge	:= .F.
	Local cSqlx
	Local cSqly

	If __lCtrRisco
		For nY := 1 to oModelN7A:Length()
			oModelN7A:GoLine( nY )
			if !oModelN7A:IsDeleted() .and. oModelN7A:GetValue( "N7A_USOFIX" ) <> "LBNO"	
				For nX := 1 To oModelN7C:Length()					
					oModelN7C:Goline(nX)
					If oModel:GetValue("N7CUNICO","N7C_HEDGE") == '1' .AND. oModel:GetValue("N7CUNICO","N7C_QTDCTR") > 0
						lHedge := .T.
						exit
					endif
				next nY
				endif
		next nY
	
		If .Not. lHedge
			Return .T.
		EndIf
		
		For nY := 1 to oModelN7A:Length()
			oModelN7A:GoLine( nY )
			if !oModelN7A:IsDeleted() .and. oModelN7A:GetValue( "N7A_USOFIX" ) <> "LBNO" //sem delete e marcado para fixar

				For nX := 1 To oModelN7C:Length()					
					oModelN7C:Goline(nX)
					If oModelN7C:GetValue("N7C_HEDGE") == '1'	
						cSqlx := "Select SUM(N7C_QTDCTR) QTDCTR "+;
										" From " + RetSqlName("N7C") + " N7C "+;
										" Where N7C_FILIAL = '" + oModel:GetValue("N79UNICO","N79_FILIAL") + "'"+;
										" AND N7C_CODNGC  = '" + oModel:GetValue("N79UNICO","N79_CODNGC") + "'"+;
										" AND N7C_VERSAO  = '" + oModel:GetValue("N79UNICO","N79_VERSAO") + "'"+;
										" AND N7C_CODCAD  = '" + oModelN7A:GetValue( "N7A_CODCAD" )  + "' AND D_E_L_E_T_ = ' '"
						x := getDataSql(cSqlx)
						cSqly := "Select SUM(NCT_QTDCTR) QTDCTR "+;
										" From " + RetSqlName("NCT") + " NCT "+;
										" Where NCT_FILIAL = '" + oModel:GetValue("N79UNICO","N79_FILIAL") + "'"+;
										" AND NCT_CODNGC  = '" + oModel:GetValue("N79UNICO","N79_CODNGC") + "'"+;
										" AND NCT_VERSAO  = '" + oModel:GetValue("N79UNICO","N79_VERSAO") + "'"+;
										" AND NCT_CODCAD  = '" + oModelN7A:GetValue( "N7A_CODCAD" )  + "' AND D_E_L_E_T_ = ' '"
						y := getDataSql(cSqly)
				
						If !(y > 0 .And. x = y)
							lRet := .F.
						EndIf
					EndIf
				Next nX
			endif
		next nY
	EndIf
	
Return lRet
