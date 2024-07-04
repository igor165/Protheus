#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'GTPR107.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR107()
Imprime Recibo de Vale

@sample GTPR107()

@author Cláudio Macedo 
@since 22/12/2015
@version P12
/*/
//-------------------------------------------------------------------
Function GTPR107()

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

@author Cláudio Macedo 
@since 22/12/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef()

Local oRecibo   

oRecibo := TReport():New('GTPR107', STR0002,,{|oReport|ReportPrint(oRecibo)}, STR0001,/*lLandscape*/,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/) // #Recibo de Vale, #Imprime um recibo para um vale

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

@author Cláudio Macedo 
@since 22/12/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oRecibo)

Local oArial08N	:= TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)	// Negrito
Local oArial10	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)	// Normal
Local oArial10N	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)	// Negrito
Local oArial18N	:= TFont():New("Arial",18,18,,.T.,,,,.T.,.F.)	// Negrito

Local cCNPJ    
Local cEmpresa 

DbSelectArea("SM0")
cCNPJ    := SubStr(M0_CGC,1,2)+'.'+SubStr(M0_CGC,3,3)+'.'+SubStr(M0_CGC,6,3)+'/'+SubStr(M0_CGC,9,4)+'-'+SubStr(M0_CGC,13,2)
cEmpresa := M0_NOMECOM

DbSelectArea("GQP")

oRecibo:Box(0100, 0200, 1200, 1900)	// Formulário do Recibo

oRecibo:Box(0100, 0200, 0200, 1600)	
oRecibo:Say(0115, 0825, STR0002, oArial18N) // "Recibo de Vale"

oRecibo:Box(0100, 1600, 0200, 1900)	// "Nº"
oRecibo:Say(0115, 1630, STR0003, oArial18N)
oRecibo:Say(0115, 1720, GQP_CODIGO, oArial18N)

oRecibo:Box(0200, 0200, 0350, 1100)	
oRecibo:Say(0210, 0210, STR0004, oArial08N) // "Empresa"
oRecibo:Say(0280, 0210, cEmpresa, oArial10N)

oRecibo:Box(0200, 1100, 0350, 1600)	
oRecibo:Say(0210, 1320, STR0005, oArial08N) // "CNPJ"
oRecibo:Say(0280, 1120, cCNPJ, oArial10N)

oRecibo:Box(0200, 1600, 0350, 1900)	
oRecibo:Say(0210, 1715, STR0006, oArial08N) // "Emissão"
oRecibo:Say(0280, 1700, Dtoc(GQP_EMISSA), oArial10N)

oRecibo:Box(0350, 0200, 0500, 1100)	
oRecibo:Say(0360, 0210, STR0007, oArial08N) // "Funcionário"
oRecibo:Say(0430, 0210, GQP_CODFUN + "-" + Posicione("SRA",1,xFilial("SRA")+GQP_CODFUN,"RA_NOME"), oArial10N)

oRecibo:Box(0350, 1100, 0500, 1900)	
oRecibo:Say(0360, 1120, STR0008, oArial08N) // "Departamento"
oRecibo:Say(0430, 1120, GQP_DEPART + "-" + Posicione("SQB",1,xFilial("SQB")+GQP_DEPART,"QB_DESCRIC"), oArial10N)

oRecibo:Box(0500, 0200, 0650, 1100)	// "Agência"
oRecibo:Say(0510, 0210, STR0009, oArial08N)
If !Empty(GQP_CODAGE)
	oRecibo:Say(0580, 0210, GQP_CODAGE + "-" + Posicione("GI6",1,xFilial("SQB")+GQP_CODAGE,"GI6_DESCRI"), oArial10N)
Endif
oRecibo:Box(0500, 1100, 0650, 1500)	
oRecibo:Say(0510, 1260, STR0010, oArial08N) // "Vigência"
oRecibo:Say(0580, 1240, Dtoc(GQP_VIGENC), oArial10N)

oRecibo:Box(0500, 1500, 0650, 1900)	
oRecibo:Say(0510, 1820, STR0011, oArial08N) // "Valor"
oRecibo:Say(0580, 1780, Transform(GQP_VALOR,"@E 99,999.99"), oArial10N)

oRecibo:Box(0650, 0200, 0800, 1900) 
oRecibo:Say(0660, 1000, STR0012, oArial08N) // "Finalidade"
oRecibo:Say(0730, 0210, GQP_DESFIN, oArial10N)

oRecibo:Say(0900, 0300, STR0013, oArial10)  // "Texto da declaração"

oRecibo:Say(1100, 0300, STR0014+Dtoc(DDATABASE), oArial10) // "Data da impressão"

oRecibo:Line(1100, 1100, 1100, 1700) // Linha da assinatura

	
	
Return Nil
