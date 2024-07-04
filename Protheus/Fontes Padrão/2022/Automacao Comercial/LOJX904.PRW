#include 'lojx904.ch'
#Include 'TOTVS.CH'
#include "AP5MAIL.CH"
Static aCodErro := {}
//-------------------------------------------------------------------
/*/{Protheus.doc} LOJX904
Funções e-commerce
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs     
@sample LOJX904()
/*/
//-------------------------------------------------------------------

Function LOJX904()
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Lj904WS
Retorna os dados para acesso ao webservice da ciashop
@param 	cWSuser - Usuário
@param 	cWSpass - Senha
@param 	cWSURL - URL
@param 	oWS - Objeto WS
@return	oWS - Objeto WS
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs     
@sample Lj904WS(cWSuser,cWSpass, cWSURL, oWS)
/*/
//-------------------------------------------------------------------
Function Lj904WS(cWSuser,cWSpass, cWSURL, oWS)
	
	DEFAULT cWSuser := SuperGetMv("MV_LJECOMH",.T.,"ECOMMERCE")
	DEFAULT cWSpass := SuperGetMv("MV_LJECOMI",.T.,"ECOMMERCE")
	DEFAULT cWSURL	:= SuperGetMv("MV_LJECOMK",.T.,"")
	
	If Right(AllTRim(cWSURL),1) <> "/"
		cWSURL := AllTrim(cWSURL) +  "/"
	EndIf
	
	If Right(AllTRim(Lower(cWSURL)),4) <> "/ws/"
		cWSURL := AllTrim(cWSURL) + "ws/
	EndIf
	
	cWSURL += "wsintegracao.asmx"

	
	If oWs = NIL
		oWs := WSWSIntegracao():New()
		oWs:_URL := cWSURL
		oWs:clogin := cWSuser
		oWS:cSenha := cWSpass
	EndIf
	
Return oWs

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj904XES
Retorna o Saldo em Estoque do Produto
@param 	cProduto - Produto
@retun nSaldo - Saldo em estoque do produto
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@sample Lj904XES(cProduto)
/*/
//-------------------------------------------------------------------
Function Lj904XES(cProduto, lAltera, cFilEst, aLocais)

	Local nSaldo := 0 //Saldo em Estoque
	Local aArea := GetArea() //Area
	Local aAreaSB2 := SB2->(GetArea())
	Local nSaldoAtu := 0
	Local cLocEst := SuperGetMv("MV_LJECOMG", .T., "")
	Local aEstoques := StrTokArr ( StrTran(cLocEst, " ", ""), ",") //Ja retira espaços em branco para não dar alltrim toda hora
	Local nLastPos := 1
	Local nC := 0
	Local lLJX904ES := ExistBlock("LJX904ES")
	Local aAreaPE := {}
	Local aRet := {} //Retorno do Ponto de Entrada
	Local cFilSB2 := "" //Filial do SB2
	
	Default lAltera := .f.
	Default cFilEst := cFilAnt // Filial do Estoque
	Default aLocais := {}//Locais de Estoque
	
	If Len(aLocais) = 0
		aLocais := aClone(aEstoques)
	EndIf
	
	//Muda para o local de estoque passado
	aEstoques := aClone(aLocais)
	
	
	cFilSB2 := xFilial("SB2", cFilEst) //Busca pela filial do estoque
	
	
	aSort(aEstoques,,, { |x, y| x < y })

	SB2->( dbSetOrder(1) ) //B2_FILIAL+B2_COD+B2_LOCAL
	                                                                                                                                 
	SB2->( dbSeek(cFilSB2 + cProduto  ) )

	While !SB2->( Eof() ) .And. SB2->B2_FILIAL + SB2->B2_COD == cFilSB2 + cProduto
		
		If Len(aEstoques) = 0 .OR. ;
				( nC := aScan( aEstoques , { |e| e == AllTrim(SB2->B2_LOCAL )}, nLastPos)  ) > 0
			
			nLastPos := nC //Atualiza a ultima posicao localizada para não buscar sempre do inicio
			nSaldoAtu := SaldoSB2()
			
			nSaldo += nSaldoAtu
			
			If nSaldoAtu <> SB2->B2_ECSALDO
				lAltera := .T.
				If  SB2->( SoftLock("SB2") )  //Se nao conseguir travar ira provavelmente ser enviado novamente no proximo processamento.
					SB2->B2_ECSALDO := nSaldoAtu //Grava com o mesmo calculo usado na Query da MF1.
					SB2->( MsUnLock() )
				EndIf
			EndIf
		EndIf
		
		If Len(aEstoques) > 0 .AND. nC = Len(aEstoques)
			//Se localizou o ultimo registro do array, então sai do laço
			Exit
		EndIf

		SB2->( dbSkip() )
	EndDO
	
	
	If lLJX904ES
		aAreaPE := GetArea()
		aRet := ExecBlock("LJX904ES",.f., .f., { cProduto,lAltera,  nSaldo })
		
		If Len(aRet) >= 2
			nSaldo := aRet[1] //Retorna o saldo em estoque do ponto de entrada
			lAltera := aRet[2] //Retorna se houve alteração do saldo
		EndIf
		
		RestArea(aAreaPE)
	EndIf

	
	IF nSaldo < 0
		nSaldo := 0
	EndIf
	
	RestArea(aAreaSB2)
	RestArea(aArea)
	
Return nSaldo


//-------------------------------------------------------------------
/*/{Protheus.doc} Lj904XPr
Retorna o Preço de Venda do Produto, segundo tabela DA1
@param 	cCodProd - Produto
@param 	cTabProm - Tabela
@param lAtuPrc  - Atualiza tabela de Preço 
@return nVlProm - Preço de Venda da Tabela
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@sample Lj904XPr(cCodProd, cTabProm)
/*/
//-------------------------------------------------------------------
Function Lj904XPr(cCodProd, cTabProm, lAtuPrc)
	Local nVlProm 	:= 0 //Valor da tabela
	Local cAlias    := GetNextAlias() //Alias de Consulta
	Local aAreaSB0	:= ""
	Local nTamSB0   := SB0->(TamSX3("B0_COD"))[1]
	Local lLJX904Pr := ExistBlock("LJX904PR")
	Local aAreaPE 	:= {}
	Local lRet 		:= .F.
	Local lSendPrc 	:= .T.
	Local lLJX904VP := ExistBlock("LJX904VP")
	
	Default cCodProd:= ""
	Default cTabProm := SuperGetMV("MV_LJECOMQ", , "001")
	Default lAtuPrc := .f. //verifica alteração do preco de Venda


//Preço de venda

	lSendPrc := .T.
	If lLJX904Pr
		lRet := .T.
		aAreaPE := GetArea()
		lRet := ExecBlock("LJX904PR",.f., .f., { cCodProd,cTabProm,lAtuPrc })
		
		If ValType(lRet) == "L"
			lSendPrc := lRet //Retorna se envia preço de venda
		EndIf
		If lAtuPrc
			lAtuPrc := lSendPrc
		EndIf
		RestArea(aAreaPE)
	EndIf
	
	If lSendPrc
		//CARREGA O VALOR DA TABELA PADRÃO - MV_LJECOMQ
		cQueryPrc := " SELECT DA1_PRCVEN, DA1_VLRDES, DA1_DATVIG FROM "+RetSqlname('DA1')+" "
		cQueryPrc += " WHERE "
		cQueryPrc += " 		DA1_FILIAL = '"+xFilial('DA1')+"' AND DA1_CODTAB = '" + cTabProm +  "' AND DA1_CODPRO = '"+cCodProd + "' AND D_E_L_E_T_ != '*' "
		cQueryPrc += " 	AND DA1_DATVIG <= '"+DtoS(dDataBase)+"' ORDER BY DA1_DATVIG DESC "
	
		cQueryPrc := ChangeQuery(cQueryPrc)
	
		dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQueryPrc),cAlias, .F., .T.)
	
		If !(cAlias)->(Eof())
			nVlProm := (cAlias)->DA1_PRCVEN
		EndIf
		
		(cAlias )->( DbCloseArea())
		
		//Ponto de Entrada de Retorno no Preço
		If lLJX904VP
			aAreaPE := GetArea()
			
			Lj900XLg( AllTrim(cCodProd) + "Produto com  P.E de atualização de Preços(LJX904VP) - Valor anterior " + cValToChar(nVlProm))
			nVlProm := ExecBlock("LJX904VP",.f., .f., { cCodProd,cTabProm,lAtuPrc, nVlProm })
			Lj900XLg( AllTrim(cCodProd) + "Produto com  P.E de atualização de Preços(LJX904VP) - Valor atual após P.E. " + cValToChar(nVlProm))
			RestArea(aAreaPE)
		EndIf
		
	    //verifica alteração do Preço de venda
		If lAtuPrc
			aAreaSB0	:= SB0->(GetArea())
			lAtuPrc := .f.
			SB0->(DbSetOrder(1)) //Filial + Codigo
			If !SB0->(DbSeek(xFilial("SB0") + PadR(cCodProd, nTamSB0)))
				Reclock("SB0", .T.)
				SB0->B0_FILIAL := xFilial("SB0")
				SB0->B0_COD := cCodProd
				SB0->(MsUnLock())
				lAtuPrc := .t.
			EndIf
			If ( SB0->(Found()) .OR.  lAtuPrc) .and. SB0->B0_ECPRV <> nVlProm
				RecLock("SB0", .F.)
				SB0->B0_ECPRV  := nVlProm
				SB0->(MsUnLock())
				lAtuPrc := .t.
			EndIf
			RestArea(aAreaSB0)
		EndIf
	
	EndIf

Return nVlProm
 
//-------------------------------------------------------------------
/*/{Protheus.doc} Lj904XEL
Retorna o Saldo em Estoque do Local
@param 	cProduto - Produto
@param 	cLocal - Local em estoque
@param 	nProd - Tamanho do campo Produto
@param 	nLocal - Tamanho do campo Local
@return nSaldo - Saldo do Local de Estoque
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@sample Lj904XES(cProduto)
/*/
//-------------------------------------------------------------------
Function Lj904XEL(cProduto, cLocal, nProd, nLocal, cFilEst )
	Local aArea := GetArea() //Area
	Local aAreaSB2 := SB2->(GetArea())
	Local nSaldo := 0
	
	Default nProd := SB2->(TamSx3("B2_COD"))[1]
	Default  nLocal := SB2->(TamSx3("B2_LOCAL"))[1]
	Default cFilEst := cFilAnt
	
	cProduto := PadR(cProduto, nProd)
	cLocal := PadR(cLocal, nLocal)
 
	SB2->( dbSetOrder(1) ) //B2_FILIAL+B2_COD+B2_LOCAL
		                                                                                                                                 
	If SB2->( dbSeek(xFilial("SB2", cFilEst) + cProduto + cLocal ) )
		nSaldo := SaldoSB2()
	EndIf
 
	IF nSaldo < 0
		nSaldo := 0
	EndIf
	
	RestArea(aAreaSB2)
	RestArea(aArea)
	
Return nSaldo

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj904XWC
Converte os caracteres especiais no código HTML correspondente
@param 	cString - String XML
@retun cString - String Convertida
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@sample j904XWC(cString)
/*/
//-------------------------------------------------------------------

Function Lj904XWC(cString)


	If FwNoAccent(cString) <> cString
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Trata caracter especial e acentuados
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		cString := StrTran(cString,"á","&aacute;")
		cString := StrTran(cString,"à","&agrave;")
		cString := StrTran(cString,"â","&acirc;")
		cString := StrTran(cString,"ã","&atilde;")
		cString := StrTran(cString,"ä","&auml;")
		cString := StrTran(cString,"Á","&Aacute;")
		cString := StrTran(cString,"À","&Agrave;")
		cString := StrTran(cString,"Ã","&Atilde;")
		cString := StrTran(cString,"Â","&Acirc;")
		cString := StrTran(cString,"Ä","&Auml;")
	
		cString := StrTran(cString,"é","&eacute;")
		cString := StrTran(cString,"è","&egrave;")
		cString := StrTran(cString,"ê","&ecirc;")
		cString := StrTran(cString,"ë","&euml;")
		cString := StrTran(cString,"É","&Eacute;")
		cString := StrTran(cString,"È","&Egrave;")
		cString := StrTran(cString,"Ê","&Ecirc;")
		cString := StrTran(cString,"Ë","&Euml;")
	
		cString := StrTran(cString,"í","&iacute;")
		cString := StrTran(cString,"ì","&igrave;")
		cString := StrTran(cString,"ï","&iuml;")
		cString := StrTran(cString,"Í","&Iacute;")
		cString := StrTran(cString,"Ì","&Igrave;")
		cString := StrTran(cString,"Î","&Icirc;")
		cString := StrTran(cString,"Ï","&Iuml;")
	
		cString := StrTran(cString,"ó","&oacute;")
		cString := StrTran(cString,"ò","&ograve;")
		cString := StrTran(cString,"õ","&otilde;")
		cString := StrTran(cString,"ô","&ocirc;")
		cString := StrTran(cString,"ö","&ouml;")
		cString := StrTran(cString,"Ó","&Oacute;")
		cString := StrTran(cString,"Ò","&Ograve;")
		cString := StrTran(cString,"Õ","&Otilde;")
		cString := StrTran(cString,"Ô","&Ocirc;")
		cString := StrTran(cString,"Ö","&Ouml;")
	
		cString := StrTran(cString,"ú","&uacute;")
		cString := StrTran(cString,"ù","&ugrave;")
		cString := StrTran(cString,"ü","&uuml;")
		cString := StrTran(cString,"û","&ucirc;")
		cString := StrTran(cString,"Û","&Ucirc;")
		cString := StrTran(cString,"Ú","&Uacute;")
		cString := StrTran(cString,"Ù","&Ugrave;")
		cString := StrTran(cString,"Ü","&Uuml;")
	
		cString := StrTran(cString,"ç","&ccedil;")
		cString := StrTran(cString,"Ç","&Ccedil;")

	EndIf
	cString := StrTran(cString,"µ","")
	cString := StrTran(cString,"¿","")
	cString := StrTran(cString,"´","'")
	cString := StrTran(cString,"¨","&uml")
	cString := StrTran(cString,"°","&deg")
	cString := StrTran(cString,"º","&deg")
	cString := StrTran(cString,"Chr(166)","&ordf;")
	cString := StrTran(cString,"Chr(167)","&ordm;")



Return cString
//-------------------------------------------------------------------
/*/{Protheus.doc} LOJX904Url
Retorna a Url e a String Token para a conexao com o JSON Ciashop   
@Parametros  Empesa - Filial 	
@retun aRRay -	Url , Token
@author  		Varejo
@version 		P11.8
@since   		05/11/2016

/*/
//-------------------------------------------------------------------
Function LOJX904CUT(cEmp_lj,cFil_lj)
	Local aRet 		:= { "", ""} //Retorno da rotina
	Local cChave 		:= "" //Chave de busca
	Local cUrlCiaSh := SuperGetMV("MV_LJECOMK",,"") //Url do Token
	Local cToken    := "" //Token

	Default cEmp_lj := cEmpAnt
	Default cFil_lj := cFilant

// monta url de acesso CiaShop
	If !Empty(cUrlCiaSh)   //https://totvsdev.myciashop.com.br/ws/

		If Right(AllTRim(cUrlCiaSh),1) <> "/"
			cUrlCiaSh :=  AllTrim(cUrlCiaSh) + "/"
		EndIf
		cUrlCiaSh := StrTran(Lower(cUrlCiaSh),"/ws/", "")
	EndIf

// Token 
	If SLJ->(ColumnPos("LJ_TOKEN") > 0 )
	// posiciona tabela token filial
		SLJ->(DbSetOrder(3))	//LJ_FILIAL+LJ_RPCEMP+LJ_RPCFIL - Cod.Empresa + Cod.Filial
		If SLJ->(DbSeek(xFilial("SLJ") + cEmp_lj + cFil_lj))
			cChave := xFilial("SLJ") + cEmp_lj + cFil_lj
			If Empty(SLJ->LJ_TOKEN)
				While !SLJ->(EOF()) .And.  cChave == xFilial("SLJ")+ SLJ->LJ_RPCEMP + SLJ->LJ_RPCFIL
					If !Empty(SLJ->LJ_TOKEN)
						cToken := AllTrim(SLJ->LJ_TOKEN)
						Exit
					EndIf
					SLJ->(DbSkip())
				End
			Else
				cToken := Alltrim(SLJ->LJ_TOKEN)
			EndIf
		EndIf
	EndIf
	aRet[1] := cUrlCiaSh
	aRet[2] := cToken
Return(aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJX904Loc
Retorna um array com as filiais e os locais de estoque  
@@param  
@return Array  [1] - Filial
@return array[2] - Local de Estoque {}
@author  		Varejo
@version 		P11.8
@since   		05/11/2016

/*/
//-------------------------------------------------------------------
Function LOJX904Loc()
	Local aRet 		:= {}
	Local bCond 		:= {}
	Local aLocais	    := {} //Locais de Estoque
	Local cCond		:= ""
	Local aAreaSLJ    := {}


	If SLJ->(ColumnPos("LJ_ECFLAG") > 0 )
		bCond := { || LJ_FILIAL == xFilial("SLJ") .AND. LJ_ECFLAG = "1"}
		cCond := "LJ_FILIAL == '" + xFilial("SLJ") + "' .AND. LJ_ECFLAG = '1'"
	
		aAreaSLJ := SLJ->(GetArea())
	
		SLJ->(DbSetOrder(3))	//LJ_FILIAL+LJ_RPCEMP+LJ_RPCFIL - Cod.Empresa + Cod.Filial

	
		SLJ->(DbSetFilter(bCond, cCond))

		SLJ->(DbGoTop())

		While !SLJ->(Eof())
			aLocais := {}
		
			aLocais := StrTokArr ( StrTran(SLJ->LJ_LOCAL, " ", ""), ",") //Ja retira espaços em branco para não dar alltrim toda hora
			
			aAdd(aRet, { SLJ->LJ_RPCFIL, aClone(aLocais) } )
		
			SLJ->(DbSkip())
		
		End
		SLJ->(DbClearFilter())
		RestArea(aAreaSLJ)

	EndIf

	If Len(aRet) = 0
		aRet := {{cFilAnt, {}}}
	EndIf

Return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} Lj904Prom
Retorna um array com os dados da promoção  
@Param	cTabProm - Tabela de Preço
@Param 	nVlrNorm - Preço de Venda
@Param 	cProduto - Código do Produto
@Param 	cOrigem - Origem da rotina (LOJA900A - Produtos ou LOJA900C - Estoque)
@return Array[1] - Valor do Desconto
@return Array[2] - Preço de Venda
@return Array[3] - Preço Promocional
@return Array[4] - Data Inicial da Promoção
@return Array[5] - Data Final da Promoção
@return Array[6] -  XML da Promoção
@author  		Varejo
@version 		P11.8
@since   		05/11/2016

/*/
//-------------------------------------------------------------------
Function Lj904Prom(cTabProm, nVlrNorm, cProduto, cOrigem)
	Local aRet 			:= {} //Retorno
	Local aAreaDA0 		:= DA0->(GetArea()) //WorkArea Tabela de Preço
	Local dIniOferta 	:= CtoD("") //Data Inicial da Oferta
	Local dFimOferta 	:= CtoD("") //Data Final da Oferta
	Local nVlrDesc 		:= 0  //Valor do desconto
	Local nPrcEnv		:= 0 //Preço promocional enviado
	Local dIniPromo 	:= Ctod("")//Data Inicial da Promocao
	Local dFimPromo 	:= Ctod("") //Data Final da Promoção

	Default cTabProm 	:= SuperGetMV("MV_LJECOML", , "")
	Default cProduto 	:= ""
	Default nVlrNorm 	:= Lj904XPr(cProduto) //Valor do Produto
	Default cOrigem 	:= "LOJA900C"
//Array contendo:
//Dados Promocionais
//Data Vigencia

	If nVlrNorm > 0
		DA0->(DbSetOrder(1))
		If !Empty(cTabProm)
			if DA0->(DbSeek(xFilial("DA0") + cTabProm))
				dIniOferta := DA0->DA0_DATDE
				dFimOferta := DA0->DA0_DATATE
			endif
		EndIf
	
	//Apura os dados da tabela de preco promocao
		If !Empty(cTabProm) .AND.  ( Empty(dFimOferta) .OR.  dFimOferta >= Date() )
			nVlrDesc := Lj904XPr(cProduto, cTabProm)
			If nVlrDesc > 0 .AND. nVlrDesc  < nVlrNorm
				nVlrDesc := (nVlrNorm - nVlrDesc)
			Else
				nVlrDesc := 0
			EndIf
		Else
			nVlrDesc := 0
		EndIf
	
		If nVlrDesc > 0
			If cOrigem = "LOJA900A"
				nPrcEnv := Lj900APP(cProduto)
				If (nVlrNorm - nVlrDesc) <> nPrcEnv
					dDataVig := dDatabase-1
					aRet := { nVlrDesc,nVlrNorm,(nVlrNorm - nVlrDesc), dDataVig, dFimOferta, ""}
				EndIf

			Else
				dDataVig 	:= dDatabase-1
				dIniPromo 	:= dDataVig
				//Coloca Data Final  porque ela não pode vir vazia
				If Empty(dFimOferta)
					dFimOferta := IIF(Year(date()) >= 2049, StoD(Str(Year(date()+30),4)+"0101"), CToD("01/01/2049"))
				EndIf
				
				dFimPromo 	:= dFimOferta
				
				nPrcEnv := Lj904PP(cProduto, @dIniPromo, @dFimPromo)

			//verifica se mudou preço promocional ou vigência da promoção
				If (nVlrNorm - nVlrDesc) <> nPrcEnv .OR. (dIniPromo <> dDataVig) .OR.  (dFimPromo <> dFimOferta)
				//dDataVig := dDatabase-1
					aRet := { nVlrDesc,nVlrNorm,(nVlrNorm - nVlrDesc), dDataVig, dFimOferta, ""}
				EndIf
			EndIf
		
		ElseIf nVlrDesc = 0

		//PreçoPromocional (Multiplicado por 100)
		//Estamos enviado o ultimo preco enviado de date()-2 ate date()-1
		// pois esta é uma unica forma de enviar uma exclusão de tabela de preço					

		 //Busca o ultimo preço promocional enviado para o produto
			If cOrigem = "LOJA900A" .AND. ExistFunc("Lj900APP")
				nPrcEnv := Lj900APP(cProduto)
			ElseIf cOrigem = "LOJA904"
				nPrcEnv := Lj904PP(cProduto)
			EndIf
			If nPrcEnv > 0
				aRet := { nPrcEnv,nPrcEnv,nVlrDesc, Date()-2 , Date()-1, "" }				
			EndIf
		EndIf
	
		If Len(aRet) >= 6
			aRet[6] := 	' sale_price="' + cValToChar(IIF( aRet[3] = 0, aRet[1], aRet[3]) * 100) + '"'+;
				IIF( !Empty(aRet[5]), ' sale_end="' + TransForm(DtoS(iif(aRet[2]> 0, aRet[5], CToD("01/01/2049"))),"@R 9999-99-99") + '"', "")+;
				' sale_start="' + TransForm(Dtos(iif(aRet[2]> 0, aRet[4], CToD("01/01/1975"))),"@R 9999-99-99") + '"'
		EndIf

		RestArea(aAreaDA0)

	EndIf

Return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} Ljx904Arm
Retorna o código do armazém
@Param cFilArm - Filial do Armazém
@Param cArmCod - Código do Armazém
@Param nOpc - Opção de retorno 1 - Default Código e-commerce, 2 - Codigo ERP
@return  cArmazem - Código do Aramazém
@author  		Varejo
@version 		P11.8
@since   		05/11/2016

/*/
//-------------------------------------------------------------------
Function Ljx904Arm(cFilArm, cArmCod, nOpc)
	Local cRet := cArmCod
	Local nPos := 0
	Local cArmTmp := ""
//Retorna o codigo do armazem
	Default cFilArm := ""
	Default cArmCod := ""
	Default nOpc := 1


	If nOpc = 1
		cArmCod := StrTran(cFilArm, " ", "_")+RTrim(cArmCod)
	Else
		cArmTmp := cArmCod
		cArmTmp := StrTran(cArmTmp, "_", " ")
		nPos := At(cFilArm, cArmTmp)
		If nPos > 0
			nPos += Len(cFilArm)
			cArmCod := Substr(cArmTmp, nPos)
		EndIf
	EndIf

Return cArmCod

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj9004PP
Busca os dados do ultimo preço promocional enviado	
@author  Varejo
@version 	P11.8
@since   	26/04/2016
@obs     
@sample Lj900APP(cCodigo)
/*/
//-------------------------------------------------------------------
Static Function Lj904PP(cCodigo, dIniPromo, dFimPromo)
	Local cAlias 	:= GetNextAlias()
	Local nVlrProm 	:= 0
	
		
	If MGR->(ColumnPos("MGR_PROINI")) > 0
			
		BeginSQL Alias cAlias
	
			column MGR_PROINI as Date, MGR_PROFIN  as Date
		
			%noparser%
		
	
			SELECT MGR_PRODUT, MGR.MGR_VLRPRO, MGR.MGR_PROINI, MGR.MGR_PROFIN
				FROM %table:MGR% MGR
				WHERE
				    MGR.MGR_FILIAL  = %xFilial:MGR%
				AND MGR.MGR_PRODUT =  %Exp: cCodigo %
				AND MGR.D_E_L_E_T_ = ' '
				AND MGR.MGR_SEQ = (
						SELECT MAX(MGR_2.MGR_SEQ)
						FROM %table:MGR% MGR_2
							INNER JOIN %table:MGM% MGM_2
								ON  MGM_2.MGM_FILIAL  = MGR_2.MGR_FILIAL
								AND MGR_2.MGR_PRODUT = %Exp: cCodigo %
								AND MGM_2.MGM_SEQ     = MGR_2.MGR_SEQ
								AND MGM_2.MGM_RESULT  = '1'
								AND MGM_2.D_E_L_E_T_ = ' '
						WHERE
						    MGR_2.MGR_FILIAL  = %xFilial:MGR%
						AND MGR.MGR_PRODUT = %Exp: cCodigo %
						AND MGR_2.MGR_PRODUT  = MGR.MGR_PRODUT
						AND MGR_2.D_E_L_E_T_ = ' '	)							
	
			   EndSQL
		
		If	!(cAlias)->(Eof())
			nVlrProm 	:= (cAlias)->MGR_VLRPRO
			dIniPromo 	:= (cAlias)->MGR_PROINI
			dFimPromo 	:= (cAlias)->MGR_PROFIN
		Endif
		(cAlias)->(DbCloseArea())
	EndIf
		
Return nVlrProm

//-------------------------------------------------------------------
/*/{Protheus.doc} Ljx904JsOb
Realiza o envio/recebimento dos métodos da API
@Param cUrl - Filial do Armazém
@Param cMetodo - Código do Armazém
@Param cJson - Código do Armazém
@Param aConnJson - Código do Armazém
@Param cMsgErro - Retorno da Mensagem de Erro
@Param cRetMsg - Retorno do Json
@return  oJson - Objeto Json de Retorno
@author  		Varejo
@version 		P11.8
@since   		05/11/2016

/*/
//-------------------------------------------------------------------
Function Ljx904JsOb(cUrl, cMetodo, cJson, aConnJson, ;
		cMsgErro, cRetMsg)
	Local oJson := NIL //Objeto de retorno
	Local aHeader := {} //header do Json
	Local cRetorno := "" //Retorno
	Local lRet := .F. //Falha na execução
	Local nHttpRet := 0 //Retorno Http
	Local cGetParms := ""
	Local cHeaderGet := ""

	Default cMetodo := "GET"
	Default aConnJson := LOJX904CUT()
	Default cJson := NIL
	Default cMsgErro := ""
	Default cUrl := ""
	Default cRetMsg := ""


	If Len(aConnJson) >= 2

	// desceraliza o JSon
		If Upper(cMetodo) = "POST" .AND. !FWJsonDeserialize(cJSon,@oJson)
			cMsgErro := STR0001//"Erro no formato do JSon Envio"
		Else
			oJson := NIL
		Endif
		If Empty(cMsgErro)
		
			aHeader := { "Authorization: Bearer " + aConnJson[2],;
				"Content-Type: application/json; charset=UTF-8";
				}

	
			cUrl := aConnJson[1] + "/api/v1/"+ cUrl
		
			If !Empty(cJson)
				cJson := EncodeUTF8(cJson)
			EndIf
			
			If Upper(cMetodo) ==  "GET"
				cRetorno := HTTPSGet( cUrl, "", "", "", cGetParms, 120, aHeader,@cHeaderGet)
			Else
				cRetorno := HTTPSPost( cUrl, "", "", "", cGetParms, cJson, 120, aHeader, @cHeaderGet)
			EndIf
		
			If !Empty(cRetorno)
				cRetorno := DecodeUTF8( cRetorno )
			EndIf

			nHttpRet := HTTPGetStatus(@cMsgErro)
			If !(nHttpRet > 199 .and. nHttpRet < 300)
				cMsgErro := cUrl + CRLF + STR0002 + cValToChar(nHttpRet) + " " +  cMsgErro	//"Falha na conexão com o e-commerce CiaShop. Verifique a chave de acesso Token e/ou Url cadastrados. Status: "
				cMsgErro += Chr(13) + CHR(10) + STR0003  + cValToChar(cRetorno) + "] " //"Resposta Server [ "
			Else
			// deseraliza e teste o JSon de retorno
				cRetMsg := cMsgErro + " httpRet [" + Str(nHttpRet) + "]"
				If !FWJsonDeserialize(cRetorno,@oJson)
					cMsgErro := cUrl + CRLF + STR0004 //"Erro no processamento do JSon Retorno"
					cMgErro += Chr(13) + CHR(10) + STR0005 +cRetorno + "]"//"Resposta Server [ "
				Else
					cMsgErro := ""
					cRetMsg := cRetorno + CRLF + cRetMsg
				EndIf
			EndIf
		EndIf
	EndIf

Return oJson

//-------------------------------------------------------------------
/*/{Protheus.doc} Ljx904JCria
Cria o Array com dados dos atributos Json
@Param aDados - Array de Atributos
@return  
@author  		Varejo
@version 		P11.8
@since   		05/11/2016

/*/
//-------------------------------------------------------------------
Function Ljx904JCria(uData)

	uData := nil

	uData := JSONObject():New()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} Ljx904JAdd
Adiciona no Array os dados do atributos Json
@Param cAtribute - Nome do Atributo
@Param cType - Tipo do Atributo (ATT - Atributo Json ou Obj - Objeto Json)
@Param uValue - Valor do Atributo Importante: Atributos do tipo Obj devem vier como array Instanciados pelas rotinas Ljx904JCria e Ljx904JAdd
@Param aData - Array de Atributos
@return  
@author  		Varejo
@version 		P11.8
@since   		05/11/2016

/*/
//-------------------------------------------------------------------
Function Ljx904JAdd(cAtribute, cType, uValue, uData, uSep, uSep2)

	Default uSep := ""
	Default uSep2 := ""

	uData[cAtribute]	:= uValue

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Ljx904JBuild
Gera o String do Json
@Param aData - Array de Atributos
@return  cJson - String do Json Criado
@author  		Varejo
@version 		P11.8
@since   		05/11/2016

/*/
//-------------------------------------------------------------------
Function Ljx904JBuild(uData)
	Local cJson := "" //Retorno da rotina

	cJson := FWJsonSerialize(uData)

Return cJson
//-------------------------------------------------------------------
/*/{Protheus.doc} Ljx904ErrE
Função para gerar informação do problema da geração do execAuto. 
@param aLog 	- Array com as mensagens que foi obtida pela leitura do erro no execauto
@param nRotina  - Variavel para diferenciar a Rotina que esta sendo executada loja901 ou loja901a
@param cFunc    - Determina que tipo de função foi executada.
@param cPedecom - Numero do pedido e-commerce
@param cAux    	- Variavel auxiliar para complemento de mensagem 
@param cArmzEC 	- Deverá conter o codigo do armazem para o estoque dos pedidos 
@author  Varejo
@version 	P11.8
@since   	16/03/2017
@obs     
@sample Ljx904ErrE()
/*/
//-------------------------------------------------------------------

Function Ljx904ErrE(aLog,nRotina,cFunc,cPedecom,cAux,cArmzEC)
	Local aMensagem := {"","","","",""}
	Local nX 		:= 0
	Local cPLinha 	:= chr(10) + chr(13)
	Local cHtml   	:= ""
	Local cDestinat := SuperGetMv("MV_LJECO01",,"")	// E-mail para recebimento de erro referente aos execuçoes de execauto
	Local cCliProd  := ""
	Local cTitulo   := ""
	Local cErro     := ""

	Default aLog 		:= {}
	Default nRotina 	:= 0
	Default cFunc   	:= ""
	Default cPedecom 	:= ""
	Default cAux 		:= ""
	Default cArmzEC     := ""
	
	If len(aLog) > 0

		If cFunc == "CLIE"
			cTitulo   := STR0009 + If (!Empty(cPedecom), " " + STR0020 + cPedecom, "")  //"Alerta de Impossibilidade de Cadastro de Clientes"
			For nX := 1 To Len(aLog)
				If "HELP:" $ aLog[nX]
					aMensagem[1] := alog[nX]
				EndIf
				If "Invalido" $ aLog[nX]
					aMensagem[2] := alog[nX]
				EndIf
				If "A1_COD:" $ Upper(aLog[nX])
					aMensagem[3] := alog[nX]
				EndIf
			
				If "A1_NOME" $ Upper(aLog[nX])
					aMensagem[4] :=  alog[nX]
				EndIf
				cCliProd := STR0015 //"Cliente:"
			Next nX
			If nRotina == 1
				aMensagem[5] := " LOJA9001 "
			ElseIf nRotina == 2
				aMensagem[5] := " LOJA901A "
			Else
				aMensagem[5] := STR0018 //" OUTRAS "
			EndIf
		ElseIf cFunc $ "18|19|21"
			cTitulo   	 := STR0010 + If (!Empty(cPedecom), " " + STR0020 + cPedecom, "") //"Alerta Problemas de Armazem no Pedido"
			aMensagem[1] := aLog[1]
			aMensagem[2] := STR0019 + cArmzEC //"Armazem com problema de Cadastro:"
			aMensagem[3] := STR0020 + cPedecom  //"Pedido E-Commerce:"
			aMensagem[5] := " LOJA901A "
		 
		ElseIf cFunc == "PEDI"
			cTitulo   := STR0022 + If (!Empty(cPedecom), " " + STR0020 + cPedecom, "") //"Alerta Problemas no Pedido de Vendas"
			If Len(aLog) < 5
					
				aMensagem[1] := alog[1]  //HELP:
				If Len(alog) >= 3
					aMensagem[2] := alog[3] 	// Invalido
				EndIf
						
				If !Empty(cPedecom)
					aMensagem[3] := cPedecom
				EndIf
			
				aMensagem[5] := " LOJA901A"
			
			Else
				For nX := 1 to Len(aLog)
					If "HELP:" $ aLog[nX]
						aMensagem[1] := alog[nX]
					EndIf
					If "Invalido" $ aLog[nX]
						aMensagem[2] := alog[nX]
					EndIf
					If "C5_PEDECOM" $ Upper(aLog[nX])
						aMensagem[3] := alog[nX]
					EndIf
				
					If "C6_PRODUTO" $ Upper(aLog[nX])
						aMensagem[4] :=  alog[nX]
					EndIf
					cCliProd := STR0026 //"Produto:"
				Next nX
				aMensagem[5] := " LOJA901A"
			EndIf
	
		ElseIf cFunc == "ORCA"
			cTitulo   := STR0024 + "Loja701" + If (!Empty(cPedecom), " " + STR0020 + cPedecom, "") //"Alerta Problemas no Orçamento "
			If Len(aLog) > 0 .And. Len(aLog) < 2
	
				aMensagem[1] := alog[1]   //Help:
		
				aMensagem[2] := STR0025 + "Loja701"  //Invalido " "Erro na Rotina "
			
				aMensagem[3] := cPedecom   // Pedecom
			
				aMensagem[5] := " LOJA901A"

			ElseIf Len(aLog) > 1
				For nX := 1 to Len(aLog)
					If "HELP:" $ aLog[nX]
						aMensagem[1] := alog[nX]
					EndIf
					If "Invalido" $ aLog[nX]
						aMensagem[2] := alog[nX]
					EndIf
					If Empty(aMensagem[3]) //Pedecom
						aMensagem[3] := cPedecom
					EndIf
				
					If "LR_PRODUTO" $ Upper(aLog[nX])
						aMensagem[4] :=  alog[nX]
					EndIf
				Next nX
			EndIf
			aMensagem[5] := " LOJA901A"
		ElseIf cFunc == "FINA"
			cTitulo  := STR0017 + If (!Empty(cPedecom), " " + STR0020 + cPedecom, "") //"Alerta Problemas na geração do Título Fina040"
			For nX := 1 To Len(aLog)
				If "HELP:" $ aLog[nX]
					aMensagem[1] := alog[nX]
				EndIf
				If "Invalido" $ aLog[nX]
					aMensagem[2] := alog[nX]
				EndIf
				If Empty(aMensagem[3])
					aMensagem[3] := cPedecom
				EndIf
			Next nX
			aMensagem[5] := " LOJA9001A"
		ElseIf cFunc $ "01|02|03|04|05|06|07|08|09|10|15|17|22|23|24|25|50"
			If cFunc $ "01|02|03"
				cTitulo   := STR0009 + If (!Empty(cPedecom), " " + STR0020 + cPedecom, "") //"Alerta de Impossibilidade de Cadastro de Clientes"
			ElseIf	cFunc == "04"
				cTitulo   := STR0039 + If (!Empty(cPedecom), " " + STR0020 + cPedecom, "") //"Alerta de Impossibilidade de Cadastro de Transportadora"
			ElseIf	cFunc $ "06|07|25"
				cTitulo   := STR0040 + If (!Empty(cPedecom), " " + STR0020 + cPedecom, "")  //"Alerta de Impossibilidade de Cadastro de Produto"
			ElseIf	cFunc == "08"
				cTitulo   := STR0041 + If (!Empty(cPedecom), " " + STR0020 + cPedecom, "")  //"Alerta de Impossibilidade de Cadastro de Vendedor"
			ElseIf	cFunc $ "05|09|23|50"
				cTitulo   := STR0042 + If (!Empty(cPedecom), " " + STR0020 + cPedecom, "") //"Alerta Problema no Método de pagamento"
			ElseIf	cFunc $ "10|22|24"
				cTitulo   := STR0022 + If (!Empty(cPedecom), " " + STR0020 + cPedecom, "")  //"Alerta Problemas no Pedido de Vendas"
			ElseIf	cFunc $ "15|17"
				cTitulo   := STR0043 + If (!Empty(cPedecom), " " + STR0020 + cPedecom, "")  //"Alerta Problemas na Reserva do Produto"
			EndIf
			aMensagem[1] := alog[1]
			If cFunc == "01"
				cCliProd := STR0015
				If !Empty(cPedecom)
					aMensagem[3] := cPedecom
				EndIf
				If !Empty(cAux)
					aMensagem[4] := cAux
				EndIf
			ElseIf cFunc == "06" .And. !Empty(cPedecom)
				cCliProd := STR0027 //"Produto:"
				If !Empty(cPedecom)
					aMensagem[3] := cPedecom
				EndIf
				If !Empty(cAux)
					aMensagem[4] := cAux
				EndIf
			ElseIf !Empty(cPedecom)
				aMensagem[3] := cPedecom
			EndIf
			aMensagem[5] := " LOJA901A"
		ElseIf cFunc = "LJI9PCIA" //Processamento de status de pedidos e-commerce
			cTitulo   	 := STR0060 + cPedecom  //"Problemas no processamento do status do pedido e-commerce  ""
			aMensagem[1] := aLog[1] //Help - Retorno da rotina automatica
			aMensagem[2] := alog[2]//Mensagem
			aMensagem[3] := cPedecom  //"Pedido E-Commerce:"
			aMensagem[5] := "LOJA900E "

		ElseIf cFunc = "LJI9PCAN" //Cancelamento automático de venda e-commerce
			cTitulo   	 := STR0061 + cPedecom  //"Problemas na exclusão da Venda cancelada pelo e-commmerce "
			aMensagem[1] := aLog[1] //Help - Retorno da rotina automatica
			aMensagem[2] := alog[2]//Mensagem
			aMensagem[3] := cPedecom  //"Pedido E-Commerce:"
			aMensagem[5] := "LOJA900E "
		EndIf
	EndIf
		
	cHtml := Ljx904Html(aMensagem,aLog,cTitulo,cCliProd)
	
	If ExistFunc("STFMail") .And. !Empty(cDestinat)
		STFMail( cTitulo , cHtml, .F. , cDestinat , @cErro )
	EndIf

	If !Empty(cErro) .And. !Empty(cDestinat)
		Lj900XLg("Erro no Envio de e-mail erro: " + cErro )
	ElseIf Empty(cDestinat)
		Lj900XLg("Parametro nao configurado MV_LJECO01, nao e possivel o envio e-mail de ocorrencia")
	EndIf
		
Return


//-------------------------------------------------------------------
/*{Protheus.doc} Ljx904Html
Montagem de um hTml para envio de mensagem por e-mail 

@param aMensagem - Array que deve conter as informações de montagem do corpo da mensagem deo e-mail
@param aLog		 - Array com as mensagens que foi obtida pela leitura do erro no execauto
@param cTitHtml  - Titulo do E-mail
@param cFunc	 - variavel de direfenciação de produto e cliente.	
@author  Varejo
@version P11
@since   08/03/2017
@return  cMensagem
@obs     
@sample
*/
//-------------------------------------------------------------------
Static Function Ljx904Html(aMensagem,aLog,cTitHtml,cFunc )
	Local cMensagem := ""
	Local nX        := 0

	Default aMensagem	:= {}
	Default aLog  	  	:= {}
	Default cTitHtml    := ""
	Default cFunc       := ""

	If Len(aMensagem) > 0
		cMensagem += '<html>'
		cMensagem += '<head>'
		cMensagem += '<title>'+ cTitHtml + '</title>'
		cMensagem += '<style type="text/css">'
		cMensagem += '#Layer1 {'
		cMensagem += ' 	position:absolute'
		cMensagem += '	left:27px;'
		cMensagem += '	top:387px;'
		cMensagem += '	width:139px;'
		cMensagem += '	height:26px;'
		cMensagem += '	z-index:1;'
		cMensagem += '}'
		cMensagem += '#Layer2 {'
		cMensagem += 'position:absolute;'
		cMensagem += ' 	left:174px;'
		cMensagem += '	top:402px;'
		cMensagem += '	width:97px;'
		cMensagem += '	height:30px;'
		cMensagem += '	z-index:2;'
		cMensagem += '}'
		cMensagem += '#Layer3 {'
		cMensagem += '	position:absolute;'
		cMensagem += '	left:284px;'
		cMensagem += '	top:386px;'
		cMensagem += '	width:116px;'
		cMensagem += '	height:31px;'
		cMensagem += '	z-index:3;'
		cMensagem += '}'
		cMensagem += '#Layer4 {'
		cMensagem += '	position:absolute;'
		cMensagem += '	left:559px;'
		cMensagem += '	top:393px;'
		cMensagem += '	width:132px;'
		cMensagem += '	height:39px;'
		cMensagem += '	z-index:4;'
		cMensagem += '}'
		cMensagem += '.style4 {font-size: 10px; font-weight: bold; }'
		cMensagem += '.style6 {font-size: 10px;'
		cMensagem += 'font-family:Verdana, Arial, Helvetica, sans-serif;}'
		cMensagem += '.style9 {font-size: 12px;'
		cMensagem += 'font-family:Verdana, Arial, Helvetica, sans-serif;'
		cMensagem += 'color:#FF0000}'
		cMensagem += 'body,td,th {'
		cMensagem += '	font-family: Verdana, Arial, Helvetica, sans-serif;'
		cMensagem += '	font-size: 10px;'
		cMensagem += '}'
		cMensagem += 'body {'
		cMensagem += '	margin-left: 0px;'
		cMensagem += '	margin-top: 0px;'
		cMensagem += '	margin-right: 0px;'
		cMensagem += '	margin-bottom: 0px;'
		cMensagem += '}'
		cMensagem += '.style8 {'
		cMensagem += '	font-size: 12px;'
		cMensagem += '	font-weight: bold;'
		cMensagem += '	font-family: Verdana, Arial, Helvetica, sans-serif;'
		cMensagem += '}'
		cMensagem += '.style10 {'
		cMensagem += '	color: #FF0000;'
		cMensagem += '	font-weight: bold;'
		cMensagem += '}'
		cMensagem += '.style11 {'
		cMensagem += '	color: #009900;'
		cMensagem += '	font-weight: bold;'
		cMensagem += '}'
		cMensagem += '.style12 {font-size: 9px}'
		cMensagem += '.style13 {color: #FFFFFF}'
		cMensagem += '</style>'
		cMensagem += '<meta http-equiv="Content-Type" content="text/html;charset=utf-8"/></head>'
		cMensagem += '<body bgproperties="fixed">'
		cMensagem += '<table border="0" width="950">'
		cMensagem += '        <tr>'
		cMensagem += '          <td width="757" valign="top"><table border="0" width="950"'
		cMensagem += '            height="68">'
		cMensagem += '<tr>'
		cMensagem += '<td height="24" colspan="2" align="center" valign="middle">'
		cMensagem += ' <h2 align="center">'
		cMensagem += '   <font color="#009900" size="4" face="Verdana, Arial, Helvetica, sans-serif"><strong>'+cTitHtml + '</strong></font></h2></td>'
		cMensagem += '</tr>'
		cMensagem += '                <tr>'
		cMensagem += '                    <td width="544"'
		cMensagem += '                    height="18" align="left" valign="middle"><p align="left"><font size="2"'
		cMensagem += '                    face="Verdana, Arial, Helvetica, sans-serif"><b>Ocorrencia:</b>'+aMensagem[1]+'</font></p>                    </td>'
		cMensagem += '                    <td width="396"'
		cMensagem += '                    height="18" align="right" valign="middle"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><b>Emissao</b> :'
		cMensagem += DtoC(Date()) +'</font></td>'
		cMensagem += '                </tr>                	'
		cMensagem += '                <tr>'
		cMensagem += '                    <td height="18" colspan="2" align="left" valign="middle"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>Pedido E-Commerce:</strong>'+ aMensagem[3] +'</font></td>'
		cMensagem += '                </tr>'
		If  !Empty(aMensagem[2])
			cMensagem += '                <tr>'
			cMensagem += '                    <td height="18" colspan="2" align="left" valign="middle"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>Problema:</strong>'+ aMensagem[2] +'</font></td>'
			cMensagem += '                </tr>'
		EndIf
		If !Empty(aMensagem[4])
			cMensagem += '                <tr>'
			cMensagem += '                    <td height="18" colspan="2" align="left" valign="middle"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>'+ cFunc +'</strong>'+ aMensagem[4] +'</font></td>'
			cMensagem += '                </tr>'
		EndIf
		cMensagem += '            </table>'
		cMensagem += '<table border="1" width="950" height="45">'
		cMensagem += '            </table>'
		cMensagem += '            <br>'
		cMensagem += '            <table width="950" border="0" cellspacing="0" cellpadding="0">'
		cMensagem += '              <tr>'
		cMensagem += '                <td><input name="hiddenField" type="hidden" value="%diasA%">'
		cMensagem += '                <input name="hiddenField2" type="hidden" value="%cCODUSR%"></td>'
		cMensagem += '                <td height="30" class="style12"><strong>Rotina:</strong>Integra;&atilde;o -'+ aMensagem[5] +'</td>'
		cMensagem += '              </tr>'
		cMensagem += '              <tr>'
		cMensagem += '                <td colspan="2"><table width="50%" border="0" align="left" cellpadding="0" cellspacing="0">'
		cMensagem += '              </tr>'
		cMensagem += '            </table>'
		cMensagem += '        </tr>'
		cMensagem += '  </table>'
		cMensagem += '</body>'
		cMensagem += '</html>'

		If Len(aLog) > 0
			cMensagem +=  chr(13) +chr(10)
			cMensagem += STR0008 //"Informação do Sistema "
			For nX := 1 to Len(aLog)
				cMensagem += aLog[nX] + chr(13) +chr(10)
			Next nX
		EndIf
	EndIf

Return(cMensagem)

//-------------------------------------------------------------------
/*/{Protheus.doc} Ljx901CErr
Monta mensagem para que seja enviada por e-mail
@param	cCodErro   - passar o codigo do erro para localizar a mensagem a ser enviada por e-mail
@param  cPedecom   - Numero do pedido e-commerce
@param  cAuxiliar  - Variavel que poderá conter um codigo para auxiliar o possivel problema
@param	cArmzEC    - Deverá conter o codigo do armazem para o estoque dos pedidos
@param  cAuxiliar2 - Variavel que poderá conter informação para auxiliar o possivel problema para compor mensagem 
@param	cMsgTran - Mensagem de controle Transacional
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs
@sample Lj901ASErr(cACodErro)
/*/
//-------------------------------------------------------------------
Function Ljx901CErr(cCodErro,cPedecom,cAuxiliar,cArmzEC,cAuxiliar2, cMsgTran)
	Local cRetorno := ""
	Local nPos     := 0
	Local aLog     := Array(1)
 
	Default cCodErro  := ""
	Default cPedecom  := ""
	Default cAuxiliar := ""
	Default cArmzEC   := ""
	Default cAuxiliar2:= ""
	Default cMsgTran := ""

//01 - Cliente não encontrado;
//02 - CPF do pedido diferente do CPF do cadastro do cliente;
//03 - Documento inválido;
//04 - Transportadora não cadastrada;
//05 - Método de pagamento não cadastrado;
//06 - Produto não cadastrado;
//07 - TES não informada no cadastro do produto;
//08 - Vendedor (Promoter) não cadastrado
//09 - Forma de pagamento inválida
//10 - Problemas na geração do Pedido de Venda
//11 - Problemas na geração do Orçamento
//12 - Problemas na geração do Título de Contas a Receber
//13 - Problemas na geração do Título de Contas a Pagar da Taxa Administrativa
//15 - Problemas ao gerar reserva de produto
//17 - Problemas ao desfazer reserva pois pedido náo foi feito
//18 - Existe mais de um armazém vinculado a um item
//19 - Existe mais de uma filial vinculada a um Pedido
//21 - Armazém não cadastrado ERP 
//22- Valor de venda do item Tributado pelo IPI inválido. Verifque configuração de IPI na TES do item.
//23 - "Método de Pagamento não homologado pelo Protheus "
//50 - Problema na condição de Pagamento, Campo não Cadastro no Sistema 'AE_ECCODIG'

	If Len(aCodErro) == 0
		AAdd(aCodErro,{"01", STR0028 } )  //"Cliente não encontrado ,CPF: "
		AAdd(aCodErro,{"02", STR0029 } )  //"CPF do pedido diferente do CPF do cadastro do cliente, E-Commerce CPF : "
		AAdd(aCodErro,{"03", STR0030 } )  //"CPF do cliente do não é válido, CPF: "
		AAdd(aCodErro,{"04", STR0031 } )  //"Transportadora não cadastrada, Codigo: "
		AAdd(aCodErro,{"05", STR0032 } )  //"Método de pagamento não cadastrado, Codigo: "
		AAdd(aCodErro,{"06", STR0033 } )  //"Produto não cadastrado, Codigo: "
		AAdd(aCodErro,{"07", STR0034 } )  //"TES não informada no cadastro do produto"
		AAdd(aCodErro,{"08", STR0035 } )  //"Vendedor (Promoter) não cadastrado, Codigo: "
		AAdd(aCodErro,{"09", STR0036 } )  //"Forma de pagamento inválida, Codigo: "
		AAdd(aCodErro,{"10", STR0037 } )  //"problemas na geração do Pedido de Venda"
		AAdd(aCodErro,{"15", STR0021 } )  //"Problemas ao gerar reserva de produto, Codigo: "
		AAdd(aCodErro,{"17", STR0016 } )  //"Problemas ao desfazer reserva pois pedido náo foi feito"
		AAdd(aCodErro,{"18", STR0011 } )  //"Existe mais de um armazém vinculado a um item"
		AAdd(aCodErro,{"19", STR0012 } )  //"Existe mais de uma filial vinculada a um Pedido"
		AAdd(aCodErro,{"21", STR0013 } )  //"Armazém não cadastrado no Protheus"
		AAdd(aCodErro,{"22", STR0045 } )  //Valor de venda do item Tributado pelo IPI inválido. Verifque configuração de IPI na TES do item.
		AAdd(aCodErro,{"23", STR0044 } )  //"Método de Pagamento não homologado pelo Protheus "
		AAdd(aCodErro,{"50", STR0038 + "'AE_ECCODIG'"}) //"Problema no Método de pagamento, Campo não Cadastro no Sistema 'AE_ECCODIG'"
		AAdd(aCodErro,{"24", Lj903DErr("24")}) //"Houve uma falha no processamento deste pedido anteriormente e já foi emitido documento de saída, realize a exclusão do documento de saída para reprocessar o pedido e-commerce completamente."
		AAdd(aCodErro,{"25", Lj903DErr("25")}) //"TES não encontrada. Verifique o cadastro de TES Inteligente ou Produtos ou o parâmetro MV_TESSAI"
	EndIf


	nPos := aScan(aCodErro,{|X| X[1] == cCodErro})
	If nPos > 0
		If aCodErro[nPos][1] $ "01|02|03|04|05|06|07|21|22|23|24|07"
			aLog[1]:= "HELP:" + aCodErro[nPos][2] + cAuxiliar
			If aCodErro[nPos][1] $ "01|02|03"  // Passo o nome do cliente
				cAuxiliar := cAuxiliar2
			EndIf
				
		ElseIf aCodErro[nPos][1] $ "18|19"
			aLog[1]:= "HELP:" + aCodErro[nPos][2]
		Else
			aLog[1]:= "HELP:" + aCodErro[nPos][2] + cPedecom
		EndIf
		If !Empty(cMsgTran)
			aAdd(aLog, cMsgTran)
		EndIf
		Ljx904ErrE(aLog,Nil,cCodErro,cPedecom,cAuxiliar,cArmzEC)
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj904IntOk
Verifica se estão configurados corretamente os principais parametros da integração CiaShop
@param	lWS   - Integração por WebService
@author  Varejo
@version 	P11.8
@since   	01/12/2017
@obs
@sample Lj901ASErr(cACodErro)
/*/
//-------------------------------------------------------------------
Function Lj904IntOk(lWS, cMessage)
Local lOK	:= .T.
Local aValid   := {}		 	
Local nTam := 3
Local nC := 1
Local uValue := ""
Local lOKT	:= .T.
				 
Default lWS := .T.
Default cMessage := ""

aValid   := { { "MV_LJECOMM", { |a, u| ( u := SuperGetMV(a, .T., .F.) )  }, ".T."},;
				 	{ "MV_LJECOMO", { |a, u| ( u := SuperGetMV(a, .T., .F.)  ) }, ".T."},;
				 	{ "MV_LJECOMK", { |a, u| !Empty(u := SuperGetMV(a, .T., "") ) }, "deve ser informado"},;
				 	{ "MV_LJECOMH", { |a, u| !Empty(u := SuperGetMV(a, .T., "ECOMMERCE") ) }, "deve ser informado"}}

If lWS
	nTam := 4
EndIf

For nC := 1 To nTam
	uValue := NIL
	lOKT := Eval( aValid[nC, 02], aValid[nC, 01] , @uValue)
	If !lOKT
		lOK := .F.
		cMessage += CRLF + space(5) + aValid[nC, 01] + STR0055 + " [" + cValToChar(uValue) + "] " + STR0056 + "  [" + aValid[nC, 03] + "]"//" está cadastradado com valor"##"que não atende o exigido para integração"
	EndIf
Next

If !lOK
	cMessage := STR0057 + CRLF + STR0058 + cMessage //"Integração e-commerce CiaShop não habilitada corretamente."##"Favor verificar os parâmetros da integração e-commerce CiaShop abaixo listados: "
	Help( " ", 1, "Lj904IntOk",, cMessage, 1, 0 )
EndIf

Return lOK

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj904Ft140
Função de Validação do Model de Categorias (FATA140)
@param 	lECommerce - Usa e-commerce
@param 	oMdl - Model
@return	lRet - Modelo válido
@author  fabiana.silva
@version 	P12.1.17
@since   	02/02/2018
@obs     
@sample Lj904Ft140(lECommerce, @oMdl)
/*/
//-------------------------------------------------------------------
Function Lj904Ft140(lECommerce, oMdl)
Local lRet 			:= .T.
Local lIsNumber		:= .T.
Local cCodTmp		:= ""
Local lECCia 		:= SuperGetMV("MV_LJECOMO",,.F.)

Default lEcommerce := .F.
Default oMdl := NIL

If lEcommerce .And. oMdl <> NIL .And. lECCia  .AND. !Empty(oMdl:GetValue("ACUMASTER", "ACU_ECFLAG") )
	//Valida se o código da categoria é numérico
	cCodTmp := AllTrim(oMdl:GetValue("ACUMASTER", "ACU_COD") )
	
	While lIsNumber .AND. !Empty(cCodTmp)
		lIsNumber := IsDigit(Left(cCodTmp,1))
		If Len(cCodTmp) > 1
			cCodTmp := Substr(cCodTmp, 2)
		Else
			cCodTmp := ""
		EndIf
	End
	If !lIsNumber
		Help(" ",1,"Lj904Ft140", , STR0059,1,0)  // "Para categoria e-commerce CiaShop, informar código numérico." 
		lRet := .F.
	EndIf
EndIf
Return lRet