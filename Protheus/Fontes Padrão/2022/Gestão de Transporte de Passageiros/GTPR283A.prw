#INCLUDE "PROTHEUS.CH"
#INCLUDE "GTPR283A.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR283A()
Imprime Recibo de Requisições

@sample GTPR283A()

@author Renan Ribeiro Brando
@since 21/08/2017
@version P12
/*/
//-------------------------------------------------------------------
Function GTPR283A()
Local oReport	:= Nil
       
	oReport := ReportDef()
	oReport:PrintDialog()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()
Imprime o recibo de Requisições

@sample ReportDef(oBrowse)

@param oBrowse - Browse ativo

@return oReport - Objeto - Objeto TREPORT

@author Renan Ribeiro Brando
@since 21/08/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef()

Local oRecibo   

oRecibo := TReport():New('GTPR283A', STR0002,,{|oReport|ReportPrint(oRecibo)}, STR0001,/*lLandscape*/,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/) // #Recibo de Requisição, #Imprime um recibo para uma requisição

oRecibo:HideFooter()
oRecibo:HideHeader()
oRecibo:HideParamPage() 
Pergunte(oRecibo:uParam, .F.)
oRecibo:DisableOrientation()

Return oRecibo

//-------------------------------------------------------------------
/*/{Protheus.doc} RecCabec(oReport)
description
@author  Flavio Martins
@since   24/08/2017
@version version
/*/
//-------------------------------------------------------------------

Static Function RecCabec(oRecibo)
Local oArial08N	:= TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)	// Negrito
Local oArial10N	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)	// Negrito
Local oArial18N	:= TFont():New("Arial",18,18,,.T.,,,,.T.,.F.)	// Negrito
Local aCliente 	:= getCliente(GQY->GQY_CODCLI, GQY->GQY_CODLOJ)
Local aQtdRec	:= getTickets(GQY->GQY_CODIGO)
Local aBanco	:= getBankData()
 
oRecibo:StartPage()

// Header
oRecibo:Box(0100, 0100, 0100, 2299)	// Linha Horizontal 1
oRecibo:Box(0350, 0100, 0350, 2299)	// Linha Horizontal 2
oRecibo:Box(0500, 0100, 0500, 2299)	// Linha Horizontal 3
oRecibo:Box(0650, 0100, 0650, 2299)	// Linha Horizontal 4
oRecibo:Box(0800, 0100, 0800, 2299)	// Linha Horizontal 5
oRecibo:Box(0100, 0100, 0800, 0100)	// Linha Vertical Margem Esquerda
oRecibo:Box(0100, 2299, 0800, 2299)	// Linha Vertical Margem Direita
oRecibo:Box(0100, 1200, 0350, 1200)	// Linha divisória Cliente x CNPJ
oRecibo:Box(0100, 1600, 0350, 1600) // Linha divisória CNPJ x Loja
oRecibo:Box(0100, 1700, 0350, 1700)	// Linha divisória Loja x Nota
oRecibo:Box(0350, 1200, 0500, 1200)	// Linha divisória Endereço x Localidade
oRecibo:Box(0350, 1950, 0500, 1950)	// Linha divisória Localidade x Qtd. Requisições
oRecibo:Box(0500, 0800, 0650, 0800)	// Linha divisória Bairro x Cidade
oRecibo:Box(0500, 1570, 0650, 1570)	// Linha divisória Cidade x Tel. Contato
oRecibo:Box(0500, 1900, 0650, 1900)	// Linha divisória Tel. Conto x Estado
oRecibo:Box(0500, 2100, 0650, 2100)	// Linha divisória Estado x CEP
oRecibo:Box(0650, 0800, 0800, 0800)	// Linha divisória Email x Emissão
oRecibo:Box(0650, 1000, 0800, 1000)	// Linha divisória Emissão x Data
oRecibo:Box(0650, 1180, 0800, 1180)	// Linha divisória Data x Valor Total
oRecibo:Box(0650, 1400, 0800, 1400)	// Linha divisória Valor Total x Dados Depósito

oRecibo:Say(0130, 0425, STR0002, oArial18N) // "Recibo de Requisição"

oRecibo:Say(0145, 1930, STR0003, oArial18N) // "Nº"
oRecibo:Say(0145, 2000, GQY->GQY_CODIGO, oArial18N)

oRecibo:Say(0210, 0110, STR0004, oArial10N) 	// "Cliente"
oRecibo:Say(0280, 0110, aCliente[1] + ' - ' + aCliente[3], oArial08N)

oRecibo:Say(0210, 1220, STR0005, oArial10N) // "CNPJ", 2. 1520
oRecibo:Say(0280, 1220, maskCNPJ(aCliente[4]), oArial08N)

oRecibo:Say(0110, 1620, STR0006, oArial10N) // "Loja"
oRecibo:Say(0280, 1620, aCliente[2], oArial08N)

oRecibo:Say(0110, 1720, STR0027, oArial10N) // "Nota"

oRecibo:Say(0360, 0110, STR0010, oArial10N) // "Endereço"
oRecibo:Say(0430, 0110, aCliente[8], oArial08N)

oRecibo:Say(0360, 1220, STR0028, oArial10N) // "Localidade" 
oRecibo:Say(0430, 1220, "Ponta Grossa", oArial08N)

oRecibo:Say(0360, 1970, STR0029, oArial10N) // "Qtd. Requisições" 
oRecibo:Say(0430, 1970, cValToChar(nQtdRec), oArial08N)

oRecibo:Say(0510, 0110, STR0025, oArial10N) // "Bairro"
oRecibo:Say(0580, 0110, aCliente[10], oArial08N)

oRecibo:Say(0510, 0820, STR0008, oArial10N) // "Cidade"
oRecibo:Say(0580, 0820, aCliente[6], oArial08N)

oRecibo:Say(0510, 1590, STR0035, oArial10N) // "Telefone p/ Contato"
oRecibo:Say(0580, 1590, "(42)3220-3535", oArial08N)

oRecibo:Say(0510, 1920, STR0009, oArial10N) // "Estado"
oRecibo:Say(0580, 1920, aCliente[7], oArial08N)

oRecibo:Say(0510, 2120, STR0011, oArial10N) // "CEP" //de 1920 p 2300
oRecibo:Say(0580, 2120, aCliente[9], oArial08N)

oRecibo:Say(0660, 0110, STR0007, oArial10N) // "E-mail"
oRecibo:Say(0730, 0110, "financeiro.pbc@princesadoscampos.com.br", oArial08N)

oRecibo:Say(0660, 0820, STR0012, oArial10N) // "Emissão"
oRecibo:Say(0730, 0820, DTOC(GQY->GQY_DTEMIS), oArial08N)

oRecibo:Say(0660, 1020, STR0013, oArial10N) // "Data"
oRecibo:Say(0730, 1020, Dtoc(DDATABASE), oArial08N)

oRecibo:Say(0660, 1200, STR0014, oArial10N) // "Valor Total"
oRecibo:Say(0730, 1200, ALLTRIM(Transform(GQY->GQY_TOTAL,"@E 999,999,999.99")), oArial08N)

oRecibo:Say(0660, 1420, STR0030, oArial10N) // "Dados para depósito"
//oRecibo:Say(0730, 1420, "Banco: " +ALLTRIM(aBanco[1][1]) + ' Agência: ' + ALLTRIM(aBanco[1][2]) + ' Conta: ' + ALLTRIM(aBanco[1][3]) + '-' + ALLTRIM(aBanco[1][4]), oArial08N) // "Banco: ", "Agência: ", "Conta: "
oRecibo:Say(0730, 1420, "Banco do Brasil, Agência: 4121-1 Conta: 75025-5",oArial08N)

oRecibo:Box(0800, 0100, 0850, 2299)
	
oRecibo:Say(0810, 0110, STR0036, oArial08N, 050)  // "Requisição"
oRecibo:Say(0810, 0260, STR0037, oArial08N, 050)  // "Req. Original"
oRecibo:Say(0810, 0410, STR0015, oArial08N, 050)  // "Número"
oRecibo:Say(0810, 0560, STR0016, oArial08N, 300)  // "Origem"
oRecibo:Say(0810, 0975, STR0017, oArial08N, 300)  // "Destino"
oRecibo:Say(0810, 1390, STR0018, oArial08N, 150)  // "Seguro"
oRecibo:Say(0810, 1540, STR0019, oArial08N, 150)  // "Pedágio"
oRecibo:Say(0810, 1690, STR0020, oArial08N, 150)  // "Tarifa"
oRecibo:Say(0810, 1840, STR0021, oArial08N, 150)  // "Taxa"
oRecibo:Say(0810, 1990, STR0022, oArial08N, 150)  // "Outros"
oRecibo:Say(0810, 2140, STR0023, oArial08N, 150)  // "Total"


Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint()
Seleciona dados para o Relatorio de vales autorizados para desconto

@sample ReportPrint(oRecibo, oDados)

@param oReport - Objeto - Objeto TREPORT

@author Cláudio Macedo 
@since 22/12/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oRecibo)

Local aTickets 	:= {}
Local nI 		:= 0
Local oArial07	:= TFont():New("Arial",07,07,,.F.,,,,.T.,.F.)	// Normal
Local oArial07n	:= TFont():New("Arial",07,07,,.T.,,,,.T.,.F.)	// Negrito
Local oArial08N	:= TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)	// Negrito
Local oArial10	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)	// Normal
Local oArial10N	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)	// Negrito
Local oPen		:= TPen():New(100,1,5)
Local nLinha	:= 0
Local aCliente	:= getCliente(GQY->GQY_CODCLI, GQY->GQY_CODLOJ)
Local aQtdPass 	:= getQtdPass(GQY->GQY_CODIGO)

oPen:Activate()

RecCabec(oRecibo)

aTickets := getTickets(GQY->GQY_CODIGO)

nLinha := 0880

FOR nI := 1 to Len(aTickets)

	oRecibo:Box(nLinha-31, 0100, nLinha, 0100)
	oRecibo:Box(nLinha-31, 2299, nLinha, 2299)

    oRecibo:Say(nLinha, 0110, aTickets[nI][10], oArial07, 050)  // "Requisição"
    oRecibo:Say(nLinha, 0260, aTickets[nI][11], oArial07, 050)  // "Req. Original"
	oRecibo:Say(nLinha, 0410, aTickets[nI][01], oArial07, 050)  // "Número"
	oRecibo:Say(nLinha, 0560, aTickets[nI][02], oArial07, 415)  // "Origem"
	oRecibo:Say(nLinha, 0975, aTickets[nI][03], oArial07, 415)  // "Destino"
	oRecibo:Say(nLinha, 1390, Transform(aTickets[nI][04],"@E 99,999.99"), oArial07, 150)  // "Seguro"
	oRecibo:Say(nLinha, 1540, Transform(aTickets[nI][05],"@E 99,999.99"), oArial07, 150)  // "Pedágio"
	oRecibo:Say(nLinha, 1690, Transform(aTickets[nI][06],"@E 99,999.99"), oArial07, 150)  // "Tarifa"
	oRecibo:Say(nLinha, 1840, Transform(aTickets[nI][07],"@E 99,999.99"), oArial07, 150)  // "Taxa"
	oRecibo:Say(nLinha, 1990, Transform(aTickets[nI][08],"@E 99,999.99"), oArial07, 150)  // "Outros"
	oRecibo:Say(nLinha, 2140, Transform(aTickets[nI][09],"@E 99,999.99"), oArial07, 150)  // "Total"
	
	nLinha += 30
	
	If nLinha > oRecibo:PageHeight() -200
		
		oRecibo:Box(nLinha-31, 0100, nLinha, 0100)
		oRecibo:Box(nLinha-31, 2299, nLinha, 2299)
		oRecibo:Box(nLinha, 0100, nLinha, 2299)
		oRecibo:Say(nLinha+40, 2000, STR0026 + cValToChar(oRecibo:oPage:nPage), oArial07, 150)  // Página"
		oRecibo:EndPage()
		oRecibo:StartPage()
		RecCabec(oRecibo)
		nLinha := 0880
	Endif

Next

oRecibo:Say(nLinha, 0110, STR0031, oArial10N) 		// "Totais"

oRecibo:Box(nLinha-30, 0100, nLinha+50, 0100)
oRecibo:Box(nLinha-30, 2299, nLinha+50, 2299)
oRecibo:Box(nLinha+50, 0100, nLinha+50, 2299)


oRecibo:Say(nLinha, 1390, Transform(nTotalSeguro	,"@E 99,999.99"), oArial07n, 150)
oRecibo:Say(nLinha, 1540, Transform(nTotalPedagio	,"@E 99,999.99"), oArial07n, 150)
oRecibo:Say(nLinha, 1690, Transform(nTotalTarifa	,"@E 99,999.99"), oArial07n, 150)
oRecibo:Say(nLinha, 1840, Transform(nTotalTaxa		,"@E 99,999.99"), oArial07n, 150)
oRecibo:Say(nLinha, 1990, Transform(nTotalOutros	,"@E 99,999.99"), oArial07n, 150)
oRecibo:Say(nLinha, 2140, Transform(nTotalTOTAL		,"@E 99,999.99"), oArial07n, 150)

nLinha += 100

	If (nLinha + 170) > (oRecibo:PageHeight() - 200)
		
		oRecibo:Say(nLinha+40, 2000, STR0026 + cValToChar(oRecibo:oPage:nPage), oArial07, 150)  // Página"
		oRecibo:EndPage()
		oRecibo:StartPage()
		RecCabec(oRecibo)
		nLinha := 0880
		
	Endif


oRecibo:Box(nLinha, 0100, nLinha, 2299) // Box da Qtd. de passagens por Itinerário
oRecibo:Box(nLinha, 0100, nLinha+200, 0100) // Box da Qtd. de passagens por Itinerário
oRecibo:Box(nLinha, 2299, nLinha+200, 2299) // Box da Qtd. de passagens por Itinerário

oRecibo:Say(nLinha+30, 0110, STR0032, oArial10N) 	// "Qtd. de Passagens por Itinerário"
oRecibo:Say(nLinha+70, 0110, STR0033, oArial08N) // "Itinerário"
oRecibo:Say(nLinha+70, 1200, STR0034, oArial08N)	// "Qtd. Passagens"

nLinha += 100

nI := 0

For nI := 1 to Len(aQtdPass)
    
    nLinha += 40
    
	If nLinha > oRecibo:PageHeight() -200
		
		oRecibo:Box(nLinha-31, 0100, nLinha, 0100)
		oRecibo:Box(nLinha-31, 2299, nLinha, 2299)
		oRecibo:Box(nLinha, 0100, nLinha, 2299)
		oRecibo:Say(nLinha+40, 2000, STR0026 + cValToChar(oRecibo:oPage:nPage), oArial07, 150)  // Página"
		oRecibo:EndPage()
		oRecibo:StartPage()
		RecCabec(oRecibo)
		nLinha := 0880
    	oRecibo:Box(nLinha, 0100, nLinha, 2299) // Box da Qtd. de passagens por Itinerário
		
	Endif

	oRecibo:Box(nLinha-1, 0100, nLinha+40, 0100) // Box da Qtd. de passagens por Itinerário
	oRecibo:Box(nLinha-1, 2299, nLinha+40, 2299) // Box da Qtd. de passagens por Itinerário
	oRecibo:Say(nLinha, 0110, ALLTRIM(aQtdPass[nI][1]) + " -> " + ALLTRIM(aQtdPass[nI][2]), oArial07)
	oRecibo:Say(nLinha, 1200, cValToChar(aQtdPass[nI][3]), oArial07)	
	
Next

nLinha += 40

oRecibo:Say(nLinha-10, 0110, STR0031, oArial10N) 		// "Totais"
oRecibo:Say(nLinha-10, 1200, cValToChar(Len(aTickets)), oArial08N)
nLinha += 30

oRecibo:Box(nLinha-31, 0100, nLinha, 0100) // Box da Qtd. de passagens por Itinerário
oRecibo:Box(nLinha-31, 2299, nLinha, 2299) // Box da Qtd. de passagens por Itinerário
oRecibo:Box(nLinha, 0100, nLinha, 2299) // Box da Qtd. de passagens por Itinerário


oRecibo:Say(nLinha+400, 2000, STR0026 + cValToChar(oRecibo:oPage:nPage), oArial07, 150)  // Página"
oRecibo:Say(nLinha+400, 0300, STR0024 + Dtoc(DDATABASE), oArial10) // "Data da impressão"
oRecibo:Box(nLinha+400, 1100, nLinha+400, 1800) // Linha da assinatura

oRecibo:Finish()

oRecibo:lNoPrint := .F.

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} maskCNPJ(cCNPJ)
Função que aplica mascára para o CNPJ
@author  RenanRibeiro Brando    
@since   21/08/2017
@version p12
/*/
//-------------------------------------------------------------------
Static Function maskCNPJ(cCNPJ)

Return SubStr(cCNPJ,1,2)+'.'+SubStr(cCNPJ,3,3)+'.'+SubStr(cCNPJ,6,3)+'/'+SubStr(cCNPJ,9,4)+'-'+SubStr(cCNPJ,13,2)


//-------------------------------------------------------------------
/*/{Protheus.doc} getCliente(cCodigo)
Pega todos os dados do cliente da requisição 
@author  Renan Ribeiro Brando   
@since   21/08/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function getCliente(cCodCli, cCodLoja)

Local aCliente := {}
Local cAliasSA1 := GetNextAlias()

BeginSQL Alias cAliasSA1
    SELECT 
        SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, 
        SA1.A1_CGC, SA1.A1_EMAIL, SA1.A1_MUN,
        SA1.A1_BAIRRO, SA1.A1_EST, SA1.A1_END, 
        SA1.A1_CEP 
    FROM 
        %TABLE:SA1% SA1 
    WHERE 
        SA1.A1_FILIAL = %xFilial:SA1%
        AND SA1.%NotDel%   
        AND SA1.A1_COD = %Exp:cCodCli%  
        AND SA1.A1_LOJA = %Exp:cCodLoja% 

EndSQL

// Se não achar nenhuma informação do cliente retorna nulo
If ((cAliasSA1)->(BOF()))
    (cAliasSA1)->(DbCloseArea())
    Return Nil
EndIf

// Preenche o array com 
AADD(aCliente, (cAliasSA1)->A1_COD)
AADD(aCliente, (cAliasSA1)->A1_LOJA)
AADD(aCliente, (cAliasSA1)->A1_NOME)
AADD(aCliente, (cAliasSA1)->A1_CGC)
AADD(aCliente, (cAliasSA1)->A1_EMAIL)
AADD(aCliente, (cAliasSA1)->A1_MUN)
AADD(aCliente, (cAliasSA1)->A1_EST)
AADD(aCliente, (cAliasSA1)->A1_END)
AADD(aCliente, (cAliasSA1)->A1_CEP)
AADD(aCliente, (cAliasSA1)->A1_BAIRRO)

(cAliasSA1)->(DbCloseArea())

Return ACLONE(aCliente)

//-------------------------------------------------------------------
/*/{Protheus.doc} getTickets(cCodLote)
description
@author  Renan Ribeiro Brando
@since   22/08/2017
@version version
/*/
//-------------------------------------------------------------------
Static Function getTickets(cCodLote)

Local cAliasGIC := GetNextAlias()
Local aTickets 	:= {}
Local aTicket 	:= {}
Local aQtdRec 	:= {}

Public nQtdRec		:= 0

Public nTotalSeguro := 0 //ok
Public nTotalPedagio:= 0 //ok
Public nTotalTarifa	:= 0 //ok
Public nTotalTaxa	:= 0 
Public nTotalOutros	:= 0 
Public nTotalTOTAL	:= 0 

    BeginSQL Alias cAliasGIC

        SELECT 
        		GQY.GQY_CODIGO As LOTE,
                GQW.GQW_CODORI,
                GQW.GQW_CODCLI,
                GQW.GQW_CODIGO,
                GIC.GIC_CODIGO,
                ORI.GI1_DESCRI AS ORIGEM,
                DEST.GI1_DESCRI AS DESTINO,
                GIC.GIC_SGFACU,
                GIC.GIC_PED,
                GIC.GIC_TAR,
                GIC.GIC_TAX,
                GIC.GIC_OUTTOT,
                GIC.GIC_VALTOT,
                GQY.GQY_NOTA As NOTA

        FROM %TABLE:GQY% GQY 
        LEFT JOIN %TABLE:GQW% GQW 	ON (GQW.GQW_CODLOT = GQY.GQY_CODIGO)
        LEFT JOIN %TABLE:GIC% GIC 	ON (GIC.GIC_CODREQ = GQW.GQW_CODIGO)
        LEFT JOIN %TABLE:GI1% ORI	ON (GIC.GIC_LOCORI = ORI.GI1_COD)
        LEFT JOIN %TABLE:GI1% DEST	ON (GIC.GIC_LOCDES = DEST.GI1_COD) 

        WHERE
            GIC.GIC_FILIAL = %xFilial:GIC%
            AND GIC.%NotDel%   
            AND GQW.%NotDel%
            AND ORI.%NotDel%  
            AND DEST.%NotDel%  
            AND GQY.GQY_CODIGO = %Exp:cCodLote%
        Order by GQY.GQY_CODIGO,GQW.GQW_CODIGO

    EndSQL
    
    WHILE ((cAliasGIC)->(!Eof()))
    	nQtdRec ++
    	
    	//Total do Seguro
        nTotalSeguro += (cAliasGIC)->GIC_SGFACU
        
        //Total do Pedágio
        nTotalPedagio += (cAliasGIC)->GIC_PED
        
        //Total da Tarifa
        nTotalTarifa += (cAliasGIC)->GIC_TAR
        
        //Total Taxa
        nTotalTaxa += (cAliasGIC)->GIC_TAX
        
        //Total Outros
        nTotalOutros += (cAliasGIC)->GIC_OUTTOT        
        
        //Total TOTAL
        nTotalTOTAL += (cAliasGIC)->GIC_VALTOT        
        
        AADD(aTicket, (cAliasGIC)->GIC_CODIGO)
        AADD(aTicket, (cAliasGIC)->ORIGEM)
        AADD(aTicket, (cAliasGIC)->DESTINO)
        AADD(aTicket, (cAliasGIC)->GIC_SGFACU)
        AADD(aTicket, (cAliasGIC)->GIC_PED)
        AADD(aTicket, (cAliasGIC)->GIC_TAR)
        AADD(aTicket, (cAliasGIC)->GIC_TAX)
        AADD(aTicket, (cAliasGIC)->GIC_OUTTOT)
        AADD(aTicket, (cAliasGIC)->GIC_VALTOT)
        AADD(aTicket, (cAliasGIC)->GQW_CODIGO)
        AADD(aTicket, (cAliasGIC)->GQW_CODORI)
        AADD(aTickets, aTicket)
        (cAliasGIC)->(DbSkip())
        
        aTicket := {}
    END

Return ACLONE(aTickets)

//-------------------------------------------------------------------
/*/{Protheus.doc} getBankData()
Retorna Dados Bancários para depósito do valor referente às requisições de passagens   
@author  fabio.veiga
@since   28/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function getBankData()
Local cAliasSA6 := GetNextAlias()
Local aDados := {}
Local aDado := {}

    BeginSQL Alias cAliasSA6

		SELECT 	TOP 1 
				SA6.A6_NREDUZ AS BANCO, 
				SA6.A6_AGENCIA AS AGENCIA, 
				SA6.A6_CONTA AS CONTA, 
				SA6.A6_DVCTA AS DIGITO
		FROM %TABLE:SA2% SA2
		JOIN %TABLE:SA6% SA6 ON (SA6.A6_COD = SA2.A2_BANCO)
		WHERE A2_NOME LIKE '%PRINCESA%'
		AND A2_BANCO = '001'
		AND SA6.%NotDel%
        AND SA2.%NotDel%  

    EndSQL

    WHILE ((cAliasSA6)->(!Eof()))
        AADD(aDado, (cAliasSA6)->BANCO)
        AADD(aDado, (cAliasSA6)->AGENCIA)
        AADD(aDado, (cAliasSA6)->CONTA)
        AADD(aDado, (cAliasSA6)->DIGITO)
        AADD(aDados, aDado)
        (cAliasSA6)->(DbSkip())
        aTicket := {}
    END
            
    (cAliasSA6)->(DbCloseArea())

Return ACLONE(aDados)

//-------------------------------------------------------------------
/*/{Protheus.doc} getQtdPass(cCodLote)
Retorna a Qtd de Passagens por Itinerario
@author  fabio.veiga
@since   29/06/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function getQtdPass(cCodLote)

Local cAliasGI1 := GetNextAlias()
Local aTickets 	:= {}
Local aTicket 	:= {}

    BeginSQL Alias cAliasGI1

        SELECT	ORI.GI1_DESCRI AS ORIGEM,
        		DEST.GI1_DESCRI AS DESTINO,
        		COUNT(ORI.GI1_DESCRI) QTD

        FROM %TABLE:GQY% GQY 
        LEFT JOIN %TABLE:GQW% GQW 	ON (GQW.GQW_CODLOT = GQY.GQY_CODIGO)
        LEFT JOIN %TABLE:GIC% GIC 	ON (GIC.GIC_CODREQ = GQW.GQW_CODIGO)
        LEFT JOIN %TABLE:GI1% ORI	ON (GIC.GIC_LOCORI = ORI.GI1_COD)
        LEFT JOIN %TABLE:GI1% DEST	ON (GIC.GIC_LOCDES = DEST.GI1_COD) 

        WHERE
            GIC.GIC_FILIAL = %xFilial:GIC%
            AND GIC.%NotDel%   
            AND GQY.GQY_CODIGO = %Exp:cCodLote%
            AND GQW.%NotDel% 
            AND ORI.%NotDel%  
            AND DEST.%NotDel% 
        GROUP BY ORI.GI1_DESCRI, DEST.GI1_DESCRI            

    EndSQL
    
    WHILE ((cAliasGI1)->(!Eof()))
        AADD(aTicket, (cAliasGI1)->ORIGEM)
        AADD(aTicket, (cAliasGI1)->DESTINO)
        AADD(aTicket, (cAliasGI1)->QTD)
        AADD(aTickets, aTicket)
        (cAliasGI1)->(DbSkip())
        aTicket := {}
    END

Return ACLONE(aTickets)
