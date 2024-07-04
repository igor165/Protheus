#include "GTPR412.CH"
#include "rwmake.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"

#define DMPAPER_A4 9
//------------------------------------------------------------------------------  
/*/{Protheus.doc} GTPR412  
Extrato de Comissäes   
@sample 	 GTPR412()  
@return	 Nil  
@author	 SI4503 - Marcio Martins Pereira
@since	 12/02/2016  
@version	 P12  
@comments
/*///------------------------------------------------------------------------------
Function GTPR412()	
Local oReport
Local cPerg   := "GTPR412"

If Pergunte(cPerg,.T.)
	oReport := ReportDef(cPerg)
	oReport:PrintDialog()	
EndIf

Return
//------------------------------------------------------------------------------  
/*/{Protheus.doc} ReportDef  
Defini‡äes de Relatorio  
@sample 	 ReportDef(cAliasTmp)   
@return	 Nil  
@author	 SI4503 - Marcio Martins Pereira    
@since	 12/02/2016  
@version	 P12  
@comments  
/*///------------------------------------------------------------------------------ 
Static Function ReportDef(cPerg)	
Local oReport
Local oSecCbEx
Local oSection2
Local oSectiTx
Local oSecDesc
Local oSecBoni
Local cTitulo   := STR0001//'[GTPR412] - Extrato de Pagamento de Comissão'
Local cAliasTmp	:= GetNextAlias()
Local cTmpTaxa	:= GetNextAlias()
Local cTmpDesc	:= GetNextAlias()
Local cTmpBoni	:= GetNextAlias() 

//Relação de comissões sobre bilhetes
QryGQ6(@cAliasTmp)

//Relação de comissões sobre Taxa
QryGZL(@cTmpTaxa)

//Relação de Desconto
QryDesco(@cTmpDesc)
	
//Relação de bonificações 
QryBonif(@cTmpBoni)

oReport := TReport():New('GTPR412', cTitulo, cPerg, {|oReport| PrintReport(oReport,cAliasTmp, cTmpTaxa, cTmpDesc, cTmpBoni  )}, STR0002  )//"Este relatorio ira imprimir o extrato de pagamento de comissão."
oReport:ShowHeader(.F.)

oSecCbEx := TRSection():New( oReport, STR0003 ,{cAliasTmp} )//"Agencia"
oSecCbEx:SetTotalInLine(.F.)
TRCell():New(oSecCbEx, "COL1"  , cAliasTmp, ' '  ,"@!",50)
TRCell():New(oSecCbEx, "COL2"  , cAliasTmp, ' '  ,"@!",50)
TRCell():New(oSecCbEx, "COL3"  , cAliasTmp, ' '  ,"@!",50)

oSecCbEx:Cell("COL1"):SetBorder("ALL",0,0,.T.)
oSecCbEx:Cell("COL2"):SetBorder("ALL",0,0,.T.)
oSecCbEx:Cell("COL3"):SetBorder("ALL",0,0,.T.)
	
oSection2 := TRSection():New(oReport, STR0004 ,{cAliasTmp})//"Tipos de Vendas"
	
TRCell():New(oSection2, "GQ9_CODTPV", cAliasTmp, STR0004	,							 , 30)//'TIPO DE VENDA'
TRCell():New(oSection2, "GQ9_ORIGEM", cAliasTmp, STR0035	,							 , 20)//'Origem do bilhete'
TRCell():New(oSection2, "GQ9_STATUS", cAliasTmp, STR0036	,							 , 20)//'Status do bilhete'
TRCell():New(oSection2, "GQC_DESCRI", cAliasTmp, STR0005	,"@", TamSX3("GQC_DESCRI")[1])//"Tipo de Linha"
TRCell():New(oSection2, "PCOMIS"   , cAliasTmp,  STR0015, PesqPict('GQ7',"GQ7_PCOMIS"), 10 /*TamSX3("GQ7_PCOMIS")[1]*/,,,'CENTER',,'CENTER')//'%Comissão'	
TRCell():New(oSection2, "PIMPOS"   , cAliasTmp, STR0016	, PesqPict('GQ7',"GQ7_PIMPOS"), 10 /*TamSX3("GQ7_PIMPOS")[1]*/,,,'CENTER',,'CENTER')//%Imposto
TRCell():New(oSection2, "VALTOT"   , cAliasTmp, STR0012	,PesqPict('GQ7',"GQ7_VALTOT"), 15 /*TamSX3("GQ7_VALTOT")[1]*/,,,'CENTER',,'CENTER')//Tarifa
TRCell():New(oSection2, "VCANCE"   , cAliasTmp, STR0006	,PesqPict('GQ7',"GQ7_VCANCE"), 25 /*TamSX3("GQ7_VCANCE")[1]*/,,,'CENTER',,'CENTER')//Valor Cancel.
TRCell():New(oSection2, "VIMPOS"   , cAliasTmp, STR0007	,PesqPict('GQ7',"GQ7_VIMPOS"), 25 /*TamSX3("GQ7_VIMPOS")[1]*/,,,'CENTER',,'CENTER')//Valor Imposto
TRCell():New(oSection2, "VCOMIS"   ,          , STR0008	,PesqPict('GQ7',"GQ7_VCOMIS"), 30 /*TamSX3("GQ7_VIMPOS")[1]*/,,,'CENTER',,'CENTER')//Valor Comissão
TRCell():New(oSection2, "SUBTOTAL" , ,""      ,                            , 20                            ,,,'LEFT',,'LEFT')
TRCell():New(oSection2, "VSUB"     , ,""      ,/*PesqPict('GQ7',"GQ7_VIMPOS")*/, 15                            ,,,'RIGHT',,'RIGHT')

oSection2:Cell("SUBTOTAL"):lHeaderSize := .F.
oSection2:Cell("VSUB"):lHeaderSize := .F.
	
oBreak:= TRBreak():New(oSecCbEx,{||(cAliasTmp)->(GQ6_AGENCI)},"")
	
oSectiTx := TRSection():New(oReport, STR0012 ,{cTmpTaxa}) //"Taxas" 

TRCell():New(oSectiTx, "DESCRITAXA"	, cTmpTaxa, STR0037 ,"@!"						 ,TamSx3("GYA_DESCRI")[1])//Descrição da Taxa
TRCell():New(oSectiTx, "TTPORTAXA"	, cTmpTaxa, STR0014 ,"@ 9999"					 , 15)// 'Total de Taxas'  	
TRCell():New(oSectiTx, "GZL_PCOMIS"	, cTmpTaxa, STR0015, PesqPict('GZL',"GZL_PCOMIS"),TamSx3("GZL_PCOMIS")[1])//%Comissão
TRCell():New(oSectiTx, "GZL_PIMPOS"	, cTmpTaxa, STR0016, PesqPict('GZL',"GZL_PIMPOS"),TamSx3("GZL_PIMPOS")[1])//%Imposto
TRCell():New(oSectiTx, "GZL_VLRTOT"	, cTmpTaxa, STR0012	,PesqPict('GZL',"GZL_VLRTOT"),TamSx3("GZL_VLRTOT")[1])//Valor Total'
TRCell():New(oSectiTx, "VLIMPO"		, cTmpTaxa, STR0007	,PesqPict('GZL',"GZL_VLIMPO"),TamSx3("GZL_VLRTOT")[1])//Valor Imposto
TRCell():New(oSectiTx, "VLCOMI"		, cTmpTaxa, STR0008	,PesqPict('GZL',"GZL_VLCOMI"),TamSx3("GZL_VLRTOT")[1])//Valor Comissão

oSecDesc := TRSection():New(oReport, STR0020 ,{cTmpDesc}) //"Desconto"
TRCell():New(oSecDesc, "DESCRICAO"	, cTmpDesc, STR0018	,"@!"						 ,TamSx3("G5K_DESCRI")[1])//'Descrição do Desconto'
TRCell():New(oSecDesc,	"VALOR"		, cTmpDesc, STR0025	, PesqPict('GZM',"GZM_VALOR"),TamSx3("GZM_VALOR")[1])//Valor


oSecBoni := TRSection():New(oReport, STR0019 ,{cTmpBoni}) //"Bonificação"
TRCell():New(oSecBoni, "DESCRICAO"	, cTmpBoni, STR0011	,"@!"							,TamSx3("G5K_DESCRI")[1])//Descrição da Bonificação
TRCell():New(oSecBoni,	"VALOR"		, cTmpBoni, STR0025	, PesqPict('GZM',"GZM_VALOR")	,TamSx3("GZM_VALOR")[1])//Valor

oBreak:SetPageBreak(.T.)

oReport:SetLandscape(.T.)
		
Return (oReport)
//------------------------------------------------------------------------------  
/*/{Protheus.doc} PrintReport  
ImpressÆo de Relat¢rio   
@sample 	 PrintReport(oReport)  
@return	 Nil  
@author	 SI4503 - Marcio Martins Pereira     
@since	 12/02/2016
@version	 P12  
@comments  
/*///------------------------------------------------------------------------------
Static Function PrintReport( oReport,cAliasTmp, cTmpTaxa, cTmpDesc, cTmpBoni  )
Local oSecCbEx	 := oReport:Section(1)
Local oSection2  := oReport:Section(2)
Local oSecTax	 := oReport:Section(3)
Local oSecDes	 := oReport:Section(4)
Local oSecBon	 := oReport:Section(5)
Local nTotCan    := 0
Local nTotImp    := 0
Local nTotVal    := 0
Local nTotComis  := 0
Local cAgenc 	 := (cAliasTmp)->GQ6_AGENCI
Local cAgencTx 	 := (cTmpTaxa)->GQ6_AGENCI
Local cAgenDes	 := (cTmpDesc)->GQ6_AGENCI
Local cAgenBon	 := (cTmpBoni)->GQ6_AGENCI
Local lCabec	 := .T.
Local nDiasUt    := 0
Local nTotDesc	 := 0
Local nTotBoni	 := 0
Local nDSR			:= 0


DbSelectArea(cAliasTmp)
(cAliasTmp)->(dbGoTop())
oReport:SetMeter((cAliasTmp)->(RecCount()))
If (cAliasTmp)->(!Eof())
	//Imprimi dados referente a agência
	oSecCbEx	:= ImpCabExt( oSecCbEx, cAliasTmp )
EndIf
While (cAliasTmp)->(!Eof())

	If oReport:Cancel()
		Exit
	EndIf

	//Imprime dados totalizadores
	If (cAliasTmp)->GQ6_AGENCI <> cAgenc

		///Imprime as taxas
		oSecTax	:= ImpTaxas( oSecTax, cTmpTaxa, cAgenc, cAgencTx, oReport )
		oReport:SkipLine(1)

		///Imprime os Descontos
		oSecDes	:= ImpDesco( oSecDes, cTmpDesc, cAgenc, cAgenDes, @nTotDesc, oReport ) 
		oReport:SkipLine(1)

		//Imprime as bonificações
		oSecBon	:= ImpBonif( oSecBon, cTmpBoni, cAgenc, cAgenBon, @nTotBoni, oReport )
		oReport:SkipLine(1)

		//Imprime os subtotais + total

		oSection2	:= ImpSubTt( oReport, oSection2, nTotComis, nDiasUt, nDSR, nTotDesc,oSecCbEx, nTotBoni )							

		//Imprimi dados referente a agência
		oSecCbEx	:= ImpCabExt( oSecCbEx, cAliasTmp )

		cAgenc    :=(cAliasTmp)->GQ6_AGENCIA
		nTotCan   := 0
		nTotImp   := 0
		nTotVal   := 0
		nTotComis := 0
		nTotDesc  := 0
		nTotBoni  := 0
		lCabec	  := .T.

	EndIf

	oReport:IncMeter()
	oSection2:Cell("GQ9_CODTPV"):SetValue((cAliasTmp)->GQ9_CODTPV)
	oSection2:Cell("GQ9_ORIGEM"):SetValue((cAliasTmp)->GQ9_ORIGEM)
	oSection2:Cell("GQ9_STATUS"):SetValue((cAliasTmp)->GQ9_STATUS)
	oSection2:Cell("GQC_DESCRI"):SetValue((cAliasTmp)->GQC_DESCRI)
	oSection2:Cell("PCOMIS"):SetValue((cAliasTmp)->PCOMIS)
	oSection2:Cell("PIMPOS"):SetValue((cAliasTmp)->PIMPOS)
	oSection2:Cell("VALTOT"):SetValue((cAliasTmp)->VALTOT)
	oSection2:Cell("VCANCE"):SetValue((cAliasTmp)->VCANCE)
	oSection2:Cell("VIMPOS"):SetValue((cAliasTmp)->VIMPOS)
	oSection2:Cell("VCOMIS"):SetValue((cAliasTmp)->VCOMIS)
	oSection2:Cell("SUBTOTAL"):SetValue("")
	oSection2:Cell("VSUB"):SetPicture("")
	oSection2:Cell("VSUB"):SetValue("")
	oSection2:init()

	oSection2:lPrintHeader := lCabec
	oSection2:PrintLine()

	nTotVal   += (cAliasTmp)->VALTOT
	nTotCan   += (cAliasTmp)->VCANCE
	nTotImp   += (cAliasTmp)->VIMPOS
	nTotComis += (cAliasTmp)->VCOMIS

	lCabec  := .F.

	cAgenc  := (cAliasTmp)->GQ6_AGENCI

	(cAliasTmp)->(dbSkip())

Enddo


	///Imprime as taxas da ultima agéncia
	oSecTax	:= ImpTaxas( oSecTax, cTmpTaxa, cAgenc, cAgencTx, oReport )
	oReport:SkipLine(1)

	///Imprime os Descontos
	oSecDes	:= ImpDesco( oSecDes, cTmpDesc, cAgenc, cAgenDes, @nTotDesc, oReport )
	oReport:SkipLine(1)

	//Imprime as bonificações
	oSecBon	:= ImpBonif( oSecBon, cTmpBoni, cAgenc, cAgenBon, @nTotBoni, oReport )
	oReport:SkipLine(1)

If nTotDesc > 0 .or. nTotBoni > 0 .or. nTotComis > 0

	//Imprime totais 		
	oSection2	:= ImpSubTt( oReport, oSection2, nTotComis, nDiasUt, nDSR, nTotDesc, oSecCbEx, nTotBoni )	

EndIf

oSection2:Finish()
oSecCbEx:Finish()

If Select(cAliasTmp) > 0 

	(cAliasTmp)->(DbCloseArea())

Endif

If Select(cTmpTaxa) > 0 

	(cTmpTaxa)->(DbCloseArea())

Endif
			
If Select(cTmpDesc) > 0 

	(cTmpDesc)->(DbCloseArea())

Endif
			
If Select(cTmpBoni) > 0 

	(cTmpBoni)->(DbCloseArea())

Endif

Return
//------------------------------------------------------------------------------  
/*/{Protheus.doc} ImpCabExt
Imprime dados do cabeçalho do extrato
@type function
@author crisf
@since 01/12/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------  
Static Function ImpCabExt( oSecCbEx, cAliasTmp )
If (cAliasTmp)->(!Eof())
	oSecCbEx:Init()
	oSecCbEx:Cell("COL1"):SetValue(STR0028 + (cAliasTmp)->GYG_NOME)//"Responsável:"
	oSecCbEx:Cell("COL2"):SetValue((cAliasTmp)->GQ6_AGENCI+" - "+(cAliasTmp)->GI6_DESCRI)//"Agência:"
	oSecCbEx:Cell("COL3"):SetValue(DTOC(STOD((cAliasTmp)->GQ6_DATADE)) + "  -  " + DTOC(STOD((cAliasTmp)->GQ6_DATATE)))//" a "
	oSecCbEx:Cell("COL1"):SetAlign("LEFT")
	oSecCbEx:Cell("COL2"):SetAlign("CENTER")
	oSecCbEx:Cell("COL3"):SetAlign("RIGHT")
	oSecCbEx:PrintLine()
	oSecCbEx:Cell("COL1"):SetValue("")
	oSecCbEx:Cell("COL2"):SetValue("")
	oSecCbEx:Cell("COL3"):SetValue("")
	oSecCbEx:Cell("COL1"):SetAlign("LEFT")
	oSecCbEx:Cell("COL2"):SetAlign("CENTER")
	oSecCbEx:Cell("COL3"):SetAlign("RIGHT")
	oSecCbEx:PrintLine()
	oSecCbEx:Cell("COL1"):SetValue("")
	oSecCbEx:Cell("COL2"):SetValue("")
	oSecCbEx:Cell("COL3"):SetValue("")
	oSecCbEx:Cell("COL1"):SetAlign("LEFT")
	oSecCbEx:Cell("COL2"):SetAlign("CENTER")
	oSecCbEx:Cell("COL3"):SetAlign("RIGHT")
	oSecCbEx:PrintLine()
	oSecCbEx:Cell("COL1"):SetValue("")
	oSecCbEx:Cell("COL2"):SetValue("")
	oSecCbEx:Cell("COL3"):SetValue("")
	oSecCbEx:Cell("COL1"):SetAlign("LEFT")
	oSecCbEx:Cell("COL2"):SetAlign("CENTER")
	oSecCbEx:Cell("COL3"):SetAlign("RIGHT")
	oSecCbEx:PrintLine()
EndIf
Return oSecCbEx
//------------------------------------------------------------------------------
/*/{Protheus.doc} ImpTaxas
Imprime as taxas relacionadas
@type function
@author crisf
@since 01/12/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------
Static Function ImpTaxas( oSecTax, cTmpTaxa, cAgenc, cAgencTx, oReport )

(cTmpTaxa)->(dbGotop())
While !(cTmpTaxa)->(Eof())
			
	if cAgenc == cAgencTx
	
		While cAgenc == cAgencTx  .AND. !(cTmpTaxa)->(Eof())
			
			oSecTax:Init()
						
			oSecTax:Cell("DESCRITAXA"):SetValue((cTmpTaxa)->DESCRITAXA )
			oSecTax:Cell("TTPORTAXA"):SetValue((cTmpTaxa)->TTPORTAXA )
			oSecTax:Cell("GZL_PCOMIS"):SetValue((cTmpTaxa)->GZL_PCOMIS )
			oSecTax:Cell("GZL_PIMPOS"):SetValue((cTmpTaxa)->GZL_PIMPOS )
			oSecTax:Cell("GZL_VLRTOT"):SetValue((cTmpTaxa)->GZL_VLRTOT )
			oSecTax:Cell("VLIMPO"):SetValue((cTmpTaxa)->VLIMPO )
			oSecTax:Cell("VLCOMI"):SetValue((cTmpTaxa)->VLCOMI )
			
			oSecTax:PrintLine()
			
			(cTmpTaxa)->(dbSkip())		
			
			cAgencTx	:= (cTmpTaxa)->GQ6_AGENCI
		
		EndDo
			oSecTax:Finish()
	Else
		
		(cTmpTaxa)->(dbSkip())	
		cAgencTx	:= (cTmpTaxa)->GQ6_AGENCI
		
						
	EndIf
			
EndDo

Return oSecTax
//------------------------------------------------------------------------------
/*/{Protheus.doc} ImpDesco
Imprime os descontos associados
@type function
@author crisf
@since 01/12/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------
Static Function ImpDesco( oSecDes, cTmpDesc, cAgenc, cAgenDes, nTtDesc, oReport ) 

(cTmpDesc)->(dbGotop())
While !(cTmpDesc)->(Eof())
						
	if cAgenc == cAgenDes
		
		While cAgenc == cAgenDes .AND. !(cTmpDesc)->(Eof())
			oSecDes:Init()
			oSecDes:Cell("DESCRICAO"):SetValue((cTmpDesc)->DESCRI)
			oSecDes:Cell("VALOR"):SetValue((cTmpDesc)->VALOR )
			oSecDes:PrintLine()
			
			nTtDesc	:= nTtDesc + (cTmpDesc)->VALOR 
		
			(cTmpDesc)->(dbSkip())
				
			cAgenDes	:= (cTmpDesc)->GQ6_AGENCI

		EndDo
		oSecDes:Finish()
	Else
	
		(cTmpDesc)->(dbSkip())
		cAgenDes	:= (cTmpDesc)->GQ6_AGENCI
		
	EndIf
	
EndDo

Return oSecDes
//------------------------------------------------------------------------------
/*/{Protheus.doc} ImpBonif
Imprime as bonificações
@type function
@author crisf
@since 01/12/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------
Static Function ImpBonif( oSecBon, cTmpBoni, cAgenc, cAgenBon, nTtBoni, oReport )

(cTmpBoni)->(dbGotop())
While !(cTmpBoni)->(Eof())
						
	if cAgenc == cAgenBon
		
		While cAgenc == cAgenBon .AND.  !(cTmpBoni)->(Eof())
			
			oSecBon:Init()
			oSecBon:Cell("DESCRICAO"):SetValue((cTmpBoni)->DESCRI)
			oSecBon:Cell("VALOR"):SetValue((cTmpBoni)->VALOR )
			oSecBon:PrintLine()
			
			nTtBoni	:= nTtBoni + (cTmpBoni)->VALOR
		
			(cTmpBoni)->(dbSkip())			
			
			cAgenBon	:= (cTmpBoni)->GQ6_AGENCI
		
		EndDo
			oSecBon:Finish()
	Else
	
		(cTmpBoni)->(dbSkip())
		cAgenBon	:= (cTmpBoni)->GQ6_AGENCI
	
	EndIf
	
EndDo

Return oSecBon
//------------------------------------------------------------------------------  
/*/{Protheus.doc} ImpSubTt
Imprime os subtotais e totais
@type function
@author crisf
@since 01/12/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------  
Static Function ImpSubTt( oReport, oSection2, nTotComis, nDiasUt, nDSR, nTotDes, oSecCbEx, nTotBoni )

oSection2:Cell("GQ9_CODTPV"):Hide()
oSection2:Cell("GQ9_ORIGEM"):Hide()
oSection2:Cell("GQ9_STATUS"):Hide()
oSection2:Cell("GQC_DESCRI"):Hide()
oSection2:Cell("PCOMIS"):Hide()
oSection2:Cell("PIMPOS"):Hide()
oSection2:Cell("VALTOT"):Hide()
oSection2:Cell("VCANCE"):Hide()
oSection2:Cell("VIMPOS"):Hide()
oSection2:Cell("VCOMIS"):Hide()

oSection2:Init()

oSection2:lPrintHeader := .F.
oSection2:Cell("SUBTOTAL"):SetValue(STR0022)	//"SUBTOTAL"
oSection2:Cell("VSUB"):SetPicture(PesqPict('GQ7',"GQ7_VCOMIS"))
oSection2:Cell("VSUB"):SetValue(nTotComis)
oSection2:PrintLine()

oSection2:Cell("SUBTOTAL"):SetValue(STR0023)//"Total Bonificação"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
oSection2:Cell("VSUB"):SetValue(nTotBoni)
oSection2:PrintLine()

oSection2:Cell("SUBTOTAL"):SetValue(STR0024)//"(+)"Total Desconto"
oSection2:Cell("VSUB"):SetValue(nTotDes)

oSection2:PrintLine()
oReport:ThinLine()

oSection2:Cell("SUBTOTAL"):SetValue(STR0026)//"Valor Total de Comissão"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
oSection2:Cell("VSUB"):SetPicture(PesqPict('GQ7',"GQ7_VCOMIS"))
oSection2:Cell("VSUB"):SetValue(nTotComis+nTotBoni-nTotDes)//somar as bonificações-desconto
oSection2:PrintLine()

	//reahabilito as variaveis
	oSection2:Cell("GQ9_CODTPV"):Show()
oSection2:Cell("GQ9_ORIGEM"):Show()
oSection2:Cell("GQ9_STATUS"):Show()
oSection2:Cell("GQC_DESCRI"):Show()
oSection2:Cell("PCOMIS"):Show()
oSection2:Cell("PIMPOS"):Show()
oSection2:Cell("VALTOT"):Show()
oSection2:Cell("VCANCE"):Show()
oSection2:Cell("VIMPOS"):Show()
oSection2:Cell("VCOMIS"):Show()

oSection2:Finish()
oSecCbEx:Finish()
		
Return oSection2	
//------------------------------------------------------------------------------
/*/{Protheus.doc} QryGQ6
busca as comissões associadas aos parametros informados
@type function
@author crisf
@since 30/11/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------
Static Function QryGQ6(cAliasTmp)

BeginSql Alias cAliasTmp

	SELECT GQ6.GQ6_CODIGO,
			GQ6.GQ6_AGENCI,
			GI6.GI6_DESCRI,
			GQ6.GQ6_DATADE,
			GQ6.GQ6_DATATE,
			GQ3.GQ3_FERINI,
			GQ3.GQ3_FERFIM,
			GQC.GQC_DESCRI,
			GYG.GYG_NOME,
			CASE GQ9.GQ9_CODTPV
				WHEN 'I' THEN 'Informatizada'
				WHEN 'M' THEN 'Manual'
				WHEN 'E' THEN 'Embarcada'
				WHEN 'T' THEN 'Troca'
				WHEN 'P' THEN 'Impressão Posterior'
				WHEN 'W' THEN 'Venda Web'
			END  GQ9_CODTPV,
			
			CASE GQ9.GQ9_ORIGEM
				WHEN '1' THEN 'Manual'
				WHEN '2' THEN 'Eletronica'
			END  GQ9_ORIGEM,
			
			CASE GQ9.GQ9_STATUS
				WHEN 'V' THEN 'Vendido'
				WHEN 'C' THEN 'Cancelado'
				WHEN 'D' THEN 'Devolvido'
				WHEN 'T' THEN 'Transferido'
				WHEN 'E' THEN 'Entregue'
				WHEN 'I' THEN 'Inutilizado'
			END  GQ9_STATUS,
			
			CASE GQ9.GQ9_TPCALC
				WHEN '1' THEN 'Linha'
				WHEN '2' THEN 'Venda'
			END  GQ9_TPCALC,
			
			CASE
				WHEN GQ9.GQ9_TPCALC = '1' THEN GQ7.GQ7_PCOMIS
				ELSE GQ9.GQ9_PCOMIS
			END PCOMIS,
			
			CASE
				WHEN GQ9.GQ9_TPCALC = '1' THEN GQ7.GQ7_PIMPOS
				ELSE GQ9.GQ9_PIMPOS
			END PIMPOS,
			
			CASE
				WHEN GQ9.GQ9_TPCALC = '1' THEN GQ7.GQ7_VALTOT
				ELSE GQ9.GQ9_VALTOT
			END VALTOT,
			
			CASE
				WHEN GQ9.GQ9_TPCALC = '1' THEN GQ7.GQ7_VIMPOS
				ELSE GQ9.GQ9_VIMPOS
			END VIMPOS,
			
			CASE
				WHEN GQ9.GQ9_TPCALC = '1' THEN GQ7.GQ7_VCANCE
				ELSE GQ9.GQ9_VCANCE
			END VCANCE,
			
			CASE
				WHEN GQ9.GQ9_TPCALC = '1' THEN GQ7.GQ7_VCOMIS
				ELSE GQ9.GQ9_VCOMIS
			END VCOMIS
			
	FROM %Table:GQ6% GQ6
	
	INNER JOIN %Table:GI6% GI6 ON 
		GI6.GI6_CODIGO = GQ6.GQ6_AGENCI
		AND GI6.GI6_FILIAL =  GQ6.GQ6_FILIAL 
		AND GI6.%NotDel%
		
	LEFT JOIN %Table:GYG% GYG ON 
		GYG.GYG_CODIGO = GQ6.GQ6_CODCOL
		AND GYG.GYG_FILIAL = GQ6.GQ6_FILIAL 
		AND GYG.%NotDel%
		
	INNER JOIN %Table:GQ9% GQ9 ON 
		GQ9.GQ9_CODGQ6 = GQ6.GQ6_CODIGO
		AND GQ9.GQ9_FILIAL = GQ6.GQ6_FILIAL 
		AND GQ9.%NotDel%
		
	LEFT JOIN %Table:GQ7% GQ7 ON 
		GQ7.GQ7_CODGQ6 = GQ6.GQ6_CODIGO
		AND GQ7.GQ7_FILIAL = GQ6.GQ6_FILIAL 
		AND GQ7.GQ7_TPCALC = GQ9.GQ9_TPCALC
		AND GQ7.GQ7_CODTPV = GQ9.GQ9_CODTPV
		AND GQ7.GQ7_ORIGEM = GQ9.GQ9_ORIGEM
		AND GQ7.GQ7_STATUS = GQ9.GQ9_STATUS
		AND GQ7.%NotDel%
		
	LEFT JOIN  %Table:GQ3% GQ3 ON 
		GQ3.GQ3_FILIAL = GQ6.GQ6_FILIAL
		AND GQ3.GQ3_PROCES = GQ6.GQ6_CODIGO
		AND GQ3.GQ3_SIMULA = GQ6.GQ6_SIMULA
		AND GQ3.%NotDel%
		
	LEFT  JOIN %Table:GQC% GQC ON 	
		GQC.GQC_CODIGO = GQ7.GQ7_CODGQC
		AND GQC.GQC_FILIAL = %xFilial:GQC% 
		AND GQC.%NotDel%
		
	WHERE GQ6.GQ6_FILIAL = %xFilial:GQ6%
		AND GQ6.GQ6_AGENCI BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02% 
		AND GQ6.GQ6_DATADE BETWEEN %exp:Dtos(MV_PAR03)% AND %exp:Dtos(MV_PAR04)%
		AND GQ6.GQ6_SIMULA = ''
		AND GQ6.%NotDel%
	ORDER BY GQ6.GQ6_FILIAL, GQ6.GQ6_AGENCI
		
EndSql

Return		
//------------------------------------------------------------------------------
/*/{Protheus.doc} QryGZL
Consulta as taxas
@type function
@author crisf
@since 01/12/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------
Static Function QryGZL(cTmpTaxa)

BeginSql Alias cTmpTaxa
	
	SELECT 	GQ6.GQ6_FILIAL, 
			GQ6.GQ6_AGENCI, 
			COUNT(GZL_CODGQ6) TTPORTAXA, 
			GZL.GZL_CODGIH,
			(	SELECT GYA.GYA_DESCRI
				FROM %Table:GYA% GYA
				WHERE GYA.GYA_FILIAL = %xFilial:GYA%
					AND GYA.GYA_CODIGO =  GZL.GZL_CODGIH
					AND GYA.%NotDel%
			) DESCRITAXA, 
			GZL.GZL_PCOMIS, 
			GZL.GZL_PIMPOS, 
			GZL_VLRTOT, 
			SUM(GZL_VLIMPO) VLIMPO, 
			SUM(GZL.GZL_VLCOMI) VLCOMI
	FROM %Table:GZL% GZL
	INNER JOIN %Table:GQ6% GQ6
			ON GQ6.GQ6_FILIAL = %xFilial:GQ6%
			AND GQ6.GQ6_AGENCI BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02% 
			AND GQ6.GQ6_DATADE >= %exp:Dtos(MV_PAR03)%
			AND GQ6.GQ6_DATADE <= %exp:Dtos(MV_PAR04)%				   
			AND GQ6.GQ6_SIMULA = ''
			AND GZL.GZL_FILIAL = GQ6.GQ6_FILIAL
			AND GZL.GZL_CODGQ6 = GQ6.GQ6_CODIGO
			AND  GZL.GZL_SIMULA = GQ6.GQ6_SIMULA
			AND GQ6.%NotDel%
			AND GZL.%NotDel%
	GROUP BY GQ6.GQ6_FILIAL, GQ6.GQ6_AGENCI, GZL.GZL_CODGIH, GZL.GZL_PCOMIS, GZL.GZL_PIMPOS, GZL_VLRTOT 
	ORDER BY GQ6.GQ6_FILIAL, GQ6.GQ6_AGENCI

EndSql
			
Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} QryDesco
Seleciona os descontos associados
@type function
@author crisf
@since 01/12/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------
Static Function QryDesco(cTmpDesc)

BeginSql Alias cTmpDesc
	
	SELECT 	GQ6.GQ6_FILIAL, 
			GQ6.GQ6_AGENCI, 
			GZM.GZM_G5KG5L,
			(	SELECT G5K.G5K_DESCRI
				FROM %Table:G5K% G5K
				WHERE G5K.G5K_FILIAL = %xFilial:G5K%
					AND G5K.G5K_CODIGO = GZM.GZM_G5KG5L
					AND G5K.%NotDel%
			) DESCRI,
			SUM(GZM.GZM_VALOR) AS VALOR
	FROM %Table:GZM% GZM
	INNER JOIN %Table:GQ6% GQ6
			ON GQ6.GQ6_FILIAL = %xFilial:GQ6%
			AND GQ6.GQ6_AGENCI BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02% 
			AND GQ6.GQ6_DATADE >= %exp:Dtos(MV_PAR03)%
			AND GQ6.GQ6_DATADE <= %exp:Dtos(MV_PAR04)%
			AND GQ6.GQ6_SIMULA = ''
			AND GZM.GZM_CODGQ6 = GQ6.GQ6_CODIGO
			AND GZM.GZM_SIMULA = GQ6.GQ6_SIMULA
			AND GZM.%NotDel%
			AND GQ6.%NotDel%
			AND GZM.GZM_BONDES = '2'
			AND GZM.GZM_FILIAL = GQ6.GQ6_FILIAL
	GROUP BY GQ6.GQ6_FILIAL, GQ6.GQ6_AGENCI, GZM.GZM_G5KG5L 

EndSql
       
Return 
//------------------------------------------------------------------------------
/*/{Protheus.doc} QryBonif
Retorna as bonificações
@type function
@author crisf
@since 01/12/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------
Static Function QryBonif(cTmpBoni)

BeginSql Alias cTmpBoni
	
	SELECT 	GQ6.GQ6_FILIAL, 
			GQ6.GQ6_AGENCI, 
			GZM.GZM_G5KG5L,
			(	SELECT G5K.G5K_DESCRI
				FROM %Table:G5K% G5K
				WHERE G5K.G5K_FILIAL = %xFilial:G5K%
					AND G5K.G5K_CODIGO = GZM.GZM_G5KG5L
					AND G5K.%NotDel%
			) DESCRI,
			SUM(GZM.GZM_VALOR) AS VALOR
	FROM %Table:GZM% GZM
	INNER JOIN %Table:GQ6% GQ6
			ON GQ6.GQ6_FILIAL = %xFilial:GQ6%
			AND GQ6.GQ6_AGENCI BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02% 
			AND GQ6.GQ6_DATADE >= %exp:Dtos(MV_PAR03)%
			AND GQ6.GQ6_DATADE <= %exp:Dtos(MV_PAR04)%
			AND GQ6.GQ6_SIMULA = ''
			AND GZM.GZM_CODGQ6 = GQ6.GQ6_CODIGO
			AND GZM.GZM_SIMULA = GQ6.GQ6_SIMULA
			AND GZM.%NotDel%
			AND GQ6.%NotDel%
			AND GZM.GZM_BONDES = '1'
			AND GZM.GZM_FILIAL = GQ6.GQ6_FILIAL
	GROUP BY GQ6.GQ6_FILIAL, GQ6.GQ6_AGENCI, GZM.GZM_G5KG5L 

EndSql

Return
