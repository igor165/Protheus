#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'GTPR111.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR111()
Relatório de recibo de prestação de contas 

@sample GTPR111()
@return Nil

@author	Renan Ribeiro Brando -  Inovação
@since		08/03/2017
@version	P12
/*/
//-------------------------------------------------------------------
Function GTPR111()

Local oReport     := Nil
       
// Interface de impressao
oReport := ReportDef()
oReport:PrintDialog()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()

@sample ReportDef()
@return oReport - Objeto - Objeto TREPORT

@author	Renan Ribeiro Brando -  Inovação
@since	08/03/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef()

Local oRecibo   

oRecibo := TReport():New('GTPR111', STR0002,,{|oReport|ReportPrint(oRecibo)},STR0001,/*lLandscape*/,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/) //#Recibo de Vale, #Imprime um recibo para um vale
//oReport := TReport():New(     /*Nome do Relatório*/          , /*Titulo do Relatório*/, /*Pergunte*/, {|oReport| ReportPrint(oReport)}, /*Descricao do relatório*/ )
oRecibo:HideFooter()
oRecibo:HideHeader()
oRecibo:HideParamPage() 
Pergunte(oRecibo:uParam, .F.)

Return oRecibo

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint(oRecibo)

@sample ReportPrint(oRecibo)
@param oRecibo
@return Nil

@author	Renan Ribeiro Brando -  Inovação
@since	08/03/2017
@version	P12
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

DbSelectArea("GQQ")

oRecibo:Box(0100, 0200, 1200, 1900)	// Formulário do Recibo

oRecibo:Box(0100, 0200, 0200, 1600)	
oRecibo:Say(0115, 0825, STR0002, oArial18N) // #Recibo de Vale

oRecibo:Box(0100, 1600, 0200, 1900)	
oRecibo:Say(0115, 1630, STR0003, oArial18N) // #Nº
oRecibo:Say(0115, 1720, GQQ_NUMVAL, oArial18N)

oRecibo:Box(0200, 0200, 0350, 1100)	
oRecibo:Say(0210, 0210, STR0004, oArial08N) // #Empresa
oRecibo:Say(0280, 0210, cEmpresa, oArial10N)

oRecibo:Box(0200, 1100, 0350, 1600)	
oRecibo:Say(0210, 1320, STR0005, oArial08N) // #CNPJ
oRecibo:Say(0280, 1120, cCNPJ, oArial10N)

oRecibo:Box(0200, 1600, 0350, 1900)	
oRecibo:Say(0210, 1715, STR0006, oArial08N) // #Data de Prestação
oRecibo:Say(0280, 1700, Dtoc(GQQ_DTPRES), oArial10N)

oRecibo:Box(0350, 0200, 0500, 1100)	
oRecibo:Say(0360, 0210, STR0007, oArial08N) // #Funcionário
oRecibo:Say(0430, 0210, GQQ_CODFUN + "-" + Posicione("SRA",1,xFilial("SRA")+GQQ_CODFUN,"RA_NOME"), oArial10N)

oRecibo:Box(0350, 1100, 0500, 1900)	
oRecibo:Say(0360, 1120, STR0008, oArial08N) // #Valor
oRecibo:Say(0430, 1120, Transform(GQQ_VALOR,"@E 99,999.99"), oArial10N)

oRecibo:Box(0350, 1500, 0500, 1900)	
oRecibo:Say(0360, 1600, STR0009, oArial08N) // #Saldo Devedor do Vale
oRecibo:Say(0430, 1500, Transform(GQQ_SLDDEV,"@E 99,999.99"), oArial10N)

oRecibo:Say(0900, 0300, STR0010, oArial10)  // #Declaro ter recebido a importância líquida discriminada neste recibo.

oRecibo:Say(1100, 0300, STR0011 + Dtoc(DDATABASE), oArial10) // #Data da impressão

oRecibo:Line(1100, 1100, 1100, 1700) // Linha da assinatura
	
Return Nil
