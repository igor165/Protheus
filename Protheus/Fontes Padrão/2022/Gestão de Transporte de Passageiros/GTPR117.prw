#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'GTPR117.CH'


//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR117()
Imprime Recibo de Taxa de Embarque
@sample GTPR107()

@author Gabriela Naomi Kamimoto 
@since 17/10/2017
@version P12
/*/
//-------------------------------------------------------------------
Function GTPR117()

Local oReport     := Nil
       
// Interface de impressao
oReport := ReportDef()
oReport:PrintDialog()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()
Imprime o recibo de um vale.

@sample ReportDef(oBrowse)

@param oBrowse - Browse ativo

@return oReport - Objeto - Objeto TREPORT

@author Gabriela Naomi Kamimoto 
@since 17/10/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef()

Local oRecibo   

oRecibo := TReport():New('GTPR117', STR0001,,{|oReport|ReportPrint(oRecibo)}, STR0001,/*lLandscape*/,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/) // #Recibo de Vale, #Imprime um recibo para um vale

oRecibo:HideFooter()
oRecibo:HideHeader()
oRecibo:HideParamPage() 
Pergunte(oRecibo:uParam, .F.)

Return oRecibo

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint()
Seleciona dados para o Relatorio de vales autorizados para desconto

@sample ReportPrint(oRecibo, oDados)

@param oReport - Objeto - Objeto TREPORT

@author Gabriela Naomi Kamimoto 
@since 17/10/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oRecibo)

Local oArial08N	:= TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)	// Negrito
Local oArial10N	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)	// Negrito
Local oArial18N	:= TFont():New("Arial",18,18,,.T.,,,,.T.,.F.)	// Negrito

DbSelectArea("G57")

oRecibo:Box(0100, 0200, 1200, 1900)	// Formulário do Recibo

oRecibo:Box(0100, 0200, 0200, 1900)	
oRecibo:Say(0115, 0825, STR0002, oArial18N) // "Taxa de Embarque"

oRecibo:Box(0200, 0200, 0350, 1100)	
oRecibo:Say(0210, 0210, STR0003 + " - " + STR0004 + " - " + STR0005 + " - " + STR0006 + " - " + STR0007, oArial08N) // "Nº de Movimento"
oRecibo:Say(0280, 0210, AllTrim(G57->G57_NUMMOV) + " - " + AllTrim(G57->G57_CODIGO) + " - " + AllTrim(G57->G57_SERIE) + " - " + AllTrim(G57->G57_SUBSER) + " - " + AllTrim(G57->G57_NUMCOM), oArial10N)

oRecibo:Box(0200, 1100, 0350, 1900)	
//oRecibo:Say(0210, 1320, "", oArial08N) 
oRecibo:Say(0280, 1120, STR0008, oArial10N) // "1º Via do Cliente"

oRecibo:Box(0350, 0200, 0500, 1100)	
oRecibo:Say(0360, 0210, STR0009, oArial08N) // "Emissor"
oRecibo:Say(0430, 0210, G57->G57_EMISSO + "-" + Posicione("GYG",1,xFilial("GYG")+G57->G57_EMISSO,"GYG_NOME"), oArial10N)

oRecibo:Box(0350, 1100, 0500, 1900)	
oRecibo:Say(0360, 1120, STR0010, oArial08N) // "Data de Emissão"
oRecibo:Say(0430, 1130, dtoc(G57->G57_EMISSA), oArial10N)


oRecibo:Box(0500, 0200, 0650, 1900)	// "Agência"
oRecibo:Say(0510, 0210, STR0011, oArial08N)
If !Empty(G57->G57_AGENCI)
	oRecibo:Say(0580, 0210, G57->G57_AGENCI + "-" + Posicione("GI6",1,xFilial("G57") + G57->G57_AGENCI,"GI6_DESCRI"), oArial10N)
Endif

oRecibo:Box(0500, 1100, 0650, 1900)	
oRecibo:Say(0510, 1820, STR0012, oArial08N) // "Valor"
oRecibo:Say(0580, 1780, Transform(G57->G57_VALOR ,"@E 99,999.99"), oArial10N)

oRecibo:Line(1100, 1100, 1100, 1700) // Linha da assinatura

// 2º Via da Agência.

oRecibo:EndPage(.F.)
	
oRecibo:StartPage()
	
oRecibo:Box(0100, 0200, 1200, 1900)	// Formulário do Recibo

oRecibo:Box(0100, 0200, 0200, 1900)	
oRecibo:Say(0115, 0825, STR0002, oArial18N) // "Taxa de Embarque"

oRecibo:Box(0200, 0200, 0350, 1100)	
oRecibo:Say(0210, 0210, STR0003 + " - " + STR0004 + " - " + STR0005 + " - " + STR0006 + " - " + STR0007, oArial08N) // "Nº de Movimento"
oRecibo:Say(0280, 0210, AllTrim(G57->G57_NUMMOV) + " - " + AllTrim(G57->G57_CODIGO) + " - " + AllTrim(G57->G57_SERIE) + " - " + AllTrim(G57->G57_SUBSER) + " - " + AllTrim(G57->G57_NUMCOM), oArial10N)

oRecibo:Box(0200, 1100, 0350, 1900)	

oRecibo:Say(0280, 1120, STR0013, oArial10N) // "1º Via do Cliente"

oRecibo:Box(0350, 0200, 0500, 1100)	
oRecibo:Say(0360, 0210, STR0009, oArial08N) // "Emissor"
oRecibo:Say(0430, 0210, G57->G57_NEMISS + "-" + Posicione("SRA",1,xFilial("SRA")+G57->G57_EMISSO,"RA_NOME"), oArial10N)

oRecibo:Box(0350, 1100, 0500, 1900)	
oRecibo:Say(0360, 1120, STR0010, oArial08N) // "Data de Emissão"
oRecibo:Say(0430, 1130, dtoc(G57->G57_EMISSA), oArial10N)


oRecibo:Box(0500, 0200, 0650, 1900)	// "Agência"
oRecibo:Say(0510, 0210, STR0011, oArial08N)
If !Empty(G57->G57_AGENCI)
	oRecibo:Say(0580, 0210, G57->G57_AGENCI + "-" + Posicione("GI6",1,xFilial("G57")+G57->G57_AGENCI,"GI6_DESCRI"), oArial10N)
Endif

oRecibo:Box(0500, 1100, 0650, 1900)	
oRecibo:Say(0510, 1820, STR0012, oArial08N) // "Valor"
oRecibo:Say(0580, 1780, Transform(G57->G57_VALOR ,"@E 99,999.99"), oArial10N)

oRecibo:Line(1100, 1100, 1100, 1700) // Linha da assinatura

oRecibo:EndPage(.F.)

Return Nil
