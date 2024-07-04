#INCLUDE "PLSR443.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"

#define REEMBOLSO   "04"

STATIC ADLei := CtoD('31/12/1999')
Static lOracle := "ORACLE" $ Upper(TCGetDb())    
STATIC nsomRee := GetNewPar("MV_PLDRE44", 0)
Static lMvDisp := GetNewPar("MV_PLR4XDS", "0") == "0"
/* {Protheus.doc} PLSR443
Registro de Eventos Pagos

@author DEV
@since 05/03/2016
@version ALL
Remodelado em 2016/10/25 para atendimento a RN 390
*/
function PLSR443()
local oReport := nil
local cPerg	  := "PLR443"

Pergunte(cPerg,.t.)

if findFunction("TRepInUse") .And. TRepInUse()
	oReport := reportDef(cPerg)
	oReport:printDialog()
	freeObj(oReport)
else
	msgAlert(STR0041)
endIf

return

/*/{Protheus.doc} ReportDef
Definicoes

@author DEV
@since 05/03/2016
@version ALL
/*/
static function reportDef(cPerg)
local oReport       := nil
local oSMESANO		:= nil
local oSSEGMPADL	:= nil
local oSTPCONTRATO	:= nil
local oSTITULO		:= nil
local oSGERAL		:= nil
local oOCORRENCIAS	:= nil
local oBMESANO		:= nil
local oBSEGMDADL	:= nil
local oBTPCONTRATO	:= nil
local OBGERAL		:= nil
Local dDatDe		:= CtoD('01/'+MV_PAR01+'/'+MV_PAR02)
local dDatAte       := lastDay(dDatDe)
local aTpForn       := retSx3Box( X3CBox( posicione('SX3', 2,"BI3_TPFORN", 'X3_CBOX') ),,,1 )
local aModPag       := retSx3Box( X3CBox( posicione('SX3', 2,"BI3_MODPAG", 'X3_CBOX') ),,,1 )
Local cTexto		:= STR0001

Do Case
	Case MV_PAR07 == 1
		cTexto	+= ' - '+STR0087		// Operadora 	
	Case MV_PAR07 == 2
		cTexto	+= ' - '+STR0088		// Corresponsabilidade Assumida 	
	Case MV_PAR07 == 3
		cTexto	+= ' - '+STR0089		// Não Rel.Plano Med.Hospitalar  	
	Case MV_PAR07 == 4
		cTexto	+= ' - '+STR0090		// Ressarcimento ao SUS  	
	Case MV_PAR07 == 5
		cTexto	+= ' - '+STR0091		// Não Rel.Serviço Odontológico  	
EndCase

//objeto report
oReport := TReport():new("PLSR443",cTexto,cPerg,{|oReport| ReportPrint(oReport,oBGERAL,dDatDe,dDatAte,aTpForn,aModPag,cTexto)},cTexto) //"Registro de Eventos Pagos"
oReport:setTotalInLine(.f.)
oReport:setLandscape()

// Geração de listagem em PDF com totalizações
if ! MV_PAR06 == 1

	// Geração do arquivo em lista
    oReport:cFontBody       := 'Courier New'
    oReport:nFontBody       := 6
    oReport:lEmptyLineExcel := .t.
    oReport:lHeaderVisible  := .f.
    oReport:onPageBreak(,.f.)

EndIf

//celulas da sessao oSTITULO
oSTITULO := TRSection():new(oReport, "TITULO", {"TRBLIV"},,.f.,.t.)
oSTITULO:setPageBreak(.F.)
oSTITULO:setLineBreak(.T.)
oSTITULO:setHeaderPage(.T.)
oSTITULO:SetAutoSize(.T.)
oSTITULO:SetHeaderSection(.T.) 

// Campos para impressão
TRCell():new(oSTITULO,"CODLDP"	,"TRBLIV", "Ldp", "@R 9999", 04)//"Nrº" COD.LDP
TRCell():new(oSTITULO,"NUMPRT"	,"TRBLIV", "Num.Prt.", "@R 99999999", 08)//"Nrº"
TRCell():new(oSTITULO,"NUMGUI"	,"TRBLIV", "Guia", "@R 99999999", 08)//"Nrº"
TRCell():new(oSTITULO,"CONTRATO","TRBLIV", STR0009,, 21)//"Contrato"
TRCell():new(oSTITULO,"MATRIC"	,"TRBLIV", STR0049,, 17)//"Matrícula"
TRCell():new(oSTITULO,"INICON"	,"TRBLIV", STR0007, "@D", 10)//"Emissao"
TRCell():new(oSTITULO,"TERCON"	,"TRBLIV", STR0063, "@D", 10)//"Venc.Cont"
TRcell():new(oSTITULO,"TPCONTRATO"	,"TRBLIV", "Natureza" ,"@!", 30)
TRcell():new(oSTITULO,"SEGMENTACAO"	,"TRBLIV", "Cobertura" ,"@!", 60)
TRCell():new(oSTITULO,"REGPRO"	,"TRBLIV", STR0055+STR0062,, 10) //"Nr° Reg Prod"
TRCell():new(oSTITULO,"DTCONH"	,"TRBLIV", STR0050, PesqPict("SE5","E5_DATA"), 10) // "Dt Conh"
TRCell():new(oSTITULO,"NOMETIT"	,"TRBLIV", STR0018,, 35)//"Nome Titular"    
TRCell():new(oSTITULO,"CNPJTIT"	,"TRBLIV", STR0017,, 20) //"CPF Titular"
TRCell():new(oSTITULO,"NOMEBEN"	,"TRBLIV", STR0051,, 35)//"Beneficiário"    
TRCell():new(oSTITULO,"DTOCORR"	,"TRBLIV", STR0052, PesqPict("SE5","E5_DATA"), 10) //"Dt Ocorr"
TRCell():new(oSTITULO,"CODPRE"	,"TRBLIV", "Prest.", "@R XXXXXX", 06)//"Prest"
TRCell():new(oSTITULO,"CNPJPR"	,"TRBLIV", STR0015+" "+STR0053,"@R 99.999.999/9999-99", 18)//"CNPJ/CPF Prest"
TRCell():new(oSTITULO,"NOMEPR"	,"TRBLIV", STR0064,, 34) // "Nome Prestador" 
TRCell():new(oSTITULO,"PFPJ"	,"TRBLIV", "PF/PJ",, 06) // "" 
TRCell():new(oSTITULO,"FORNECE"	,"TRBLIV", "Fornec", "@R XXXXXX-XX", 09)//"Fornecedor+Loja"
TRCell():new(oSTITULO,"TIPDOC"	,"TRBLIV", STR0054, "@!", 04)//"Tp Doc"       
TRCell():new(oSTITULO,"DOCCTB"	,"TRBLIV", STR0055+" "+STR0065,"@R XXXXXX-XXX-XXXXXX", 18)//"Nr° Doc Contábil"
TRcell():new(oSTITULO,"DTCTB"	,"TRBLIV", STR0056, PesqPict("SE5","E5_DATA"), 10) // "Dt Contab"
TRCell():new(oSTITULO,"VLREVE"	,"TRBLIV", STR0019, "@E 9,999,999,999.99", 14)//"Valor"
TRCell():new(oSTITULO,"VLTXPG"	,"TRBLIV", STR0058, "@E 9,999,999,999.99", 14)//"Vlr Tx Adm"
TRCell():new(oSTITULO,"VLRGLO"	,"TRBLIV", STR0076, "@E 9,999,999,999.99", 14)//"Vlr Glosa"
TRCell():new(oSTITULO,"VLRGTX"	,"TRBLIV", STR0084, "@E 9,999,999,999.99", 14)//"Vlr Gl Tx Adm"

TRCell():new(oSTITULO,"VLLIQG"	,"TRBLIV", "Vlr.Liq.de Glosa", "@E 9,999,999,999.99", 14)//""
TRCell():new(oSTITULO,"VLINSS"	,"TRBLIV", STR0079, "@E 9,999,999,999.999999", 18)//"Vlr INSS"
TRCell():new(oSTITULO,"VLISS"	,"TRBLIV", STR0081, "@E 9,999,999,999.999999", 18)//"Vlr ISS"
TRCell():new(oSTITULO,"VLIRRF"	,"TRBLIV", STR0080, "@E 9,999,999,999.999999", 18)//"Vlr IRRF"
TRCell():new(oSTITULO,"VLPIS"	,"TRBLIV", "Vlr.PIS", "@E 9,999,999,999.999999", 19)//""
TRCell():new(oSTITULO,"VLCOF"	,"TRBLIV", "Vlr.COF.", "@E 9,999,999,999.999999", 19)//""
TRCell():new(oSTITULO,"VLCSLL"	,"TRBLIV", "Vlr.CSLL", "@E 9,999,999,999.999999", 19)//""
TRCell():new(oSTITULO,"VLDESC"	,"TRBLIV", STR0082, "@E 9,999,999,999.999999", 18)//"Vlr Desc"    

TRCell():new(oSTITULO,"TITULO"	,"TRBLIV", STR0005, "@R XXXX-999999999-999-XXX", 22)//"Titulo"
TRCell():new(oSTITULO,"TIPEVE"	,"TRBLIV", STR0060, "@!", 30)//"Tp Evento"       
TRCell():new(oSTITULO,"DTVENC"	,"TRBLIV", STR0008, PesqPict("SE1","E1_VENCREA") , 10)//"Vencto"
TRCell():new(oSTITULO,"DTGER"	,"TRBLIV", STR0083, PesqPict("SE1","E1_EMISSAO"), 10)//"Dt Ger"
TRCell():new(oSTITULO,"VLLIQR"	,"TRBLIV", "Vlr.Pago", "@E 9,999,999,999.999999", 18)//""
TRCell():new(oSTITULO,"DTBAIX"	,"TRBLIV", STR0086, PesqPict("SE1","E1_VENCREA") , 10)//"baixa"

Return(oReport)

/*/{Protheus.doc} ReportPrint
Impressao

@author DEV
@since 05/03/2016
@version ALL
/*/
static function ReportPrint(oReport,OBGERAL,dDatDe,dDatAte,aTpForn,aModPag,cTexto)
local lLog   		:= .t.
local nTmp			:= 0
local cTipFat		:= ""
local cMesAno		:= ""
local cSeMpADl		:= ""
local cModPag 		:= ""
local cADLei  		:= "" 
local cTipCon 		:= ""
Local cCodSeg		:= ""
local cDescSeg		:= ""
local cSusEp 		:= ""
local cNumCon		:= ""
local dIniCon		:= stod("")
local dTerCon		:= stod("")
local dRegAns 		:= stod("")
local aLog 	   		:= {}
local aStru			:= {}
local aRet			:= {}
local oSTITULO		:= oReport:section(1) //IIf(MV_PAR06==1, oReport:section(5), oReport:section(1)) 
Local cPlsCDIE		:= getNewPar("MV_PLSCDIE","1")
local aPadProd		:= {}
local aBauVenc		:= {}
local cLastRDA		:= ''	// Grava código do último RDA processado 
local cLastProd		:= ''	// Grava código do último Produto (BI3)
local cAliasCAB 	:= 'SE2'
local cChaveCAB 	:= ''
local cChaveBD7		:= ''
local cTipDoc		:= ''
local dDtVenc		:= ctod('')
local nTotReg		:= 0
local cPlTpRec	 	:= getNewPar("MV_PLTPREC","016")
local cRDASUS	 	:= getNewPar("MV_RDASUS","SUS")
Local cLastFam		:= ''
Local cNomTit		:= ''
Local cCpfTit		:= ''
Local cMatTit		:= ''
Local lReemb		:= .F.
Local nPosBA1		:= 0

Local nVlrLiqG 		:= 0
Local nValINSS 		:= 0
Local nValIRRF 		:= 0
Local nValISS  		:= 0
Local nValPIS  		:= 0
Local nValCOF  		:= 0
Local nValCSLL 		:= 0
Local nValDesc 		:= 0
Local nVlrLiqR 		:= 0
Local nPosSE2		:= 0

Local cTpEvCt		:= '' 
Local cLastPEG		:= ''
Local nLimFat		:= 0 //GetNewPar("MV_PLREGAX",0.0000004)
Local cSauOcu		:= AllTrim(SuperGetMv("MV_SAUOCU",.F.,"14|15|16|17|18|19|20|21"))
Local cBCIDtDigi	:= ""
Local nPosSE2ORI	:= 0
local cChvCtb		:= ''
local nAcuIRRF	:= 0	// Acumula o IR em valor
local nAcuISS	:= 0	// Acumula o ISS em valor
local nAcuINSS	:= 0	// Acumula o INSS em valor
local nAcuPIS	:= 0	// Acumula o PIS em valor
local nAcuCOF	:= 0	// Acumula o COFINS em valor
local nAcuCSLL	:= 0	// Acumula o CSLL em valor
local nAcuDesc	:= 0	// Acumula o Desconto em valor
local nAcuPerc	:= 0	// Acumula o percentual do valor pago para ajuste do último registro do título
Local nTotTot		:= 0

Local cTmpTbl 		:= 'TMPFK7_PLSR443'

Local cNroLvr     := "0001"
Local cTexto		:= STR0001

Local lEndIsNear	:= .F.
Local nEINPosatu	:= 0
Local nEIN			:= 0
Local aEndIsNear	:= {}
Local nSaldo	:= 0
Local nAcutotXX	:= 0
Local linvertido := .F.
Local lisrecFat	:= .F.
Local nCSLLRF	:= 0
Local nPISRF	:= 0
Local nCOFINRF := 0
Local nVRETPIS := 0
Local nVRETCSL := 0
Local nVRETCOF := 0
Local nE2VLRX	:= 0
Local nXfactor := 0
Local nXtot	:= 0
Local nI8tottot := 0
Local aI8Acutot := {0, 0, 0}
Local nfatPagY	:= 0
local nFatBD7E2 := 0
Local nDescCom := 0
Local nTotBD7PG := 0
Local nPosFK2 := 0
Local lMudouFK2 := .F.
local lBaixaDisp := ( FK2->(FieldPos("FK2_DTDISP")) > 0 ) .AND. lMvDisp
aRet := getTrbQuery(@lLog,dDatDe,dDatAte, cTmpTbl)

If aRet[1]
    return()
EndIf


if oReport:page() == 1
	oReport:setTitle(STR0024 + cNroLvr) //"LIVRO AUXILIAR NR. "
endIf


oReport:onPageBreak({|| oReport:setTitle(cTexto),.T.} ) //"Registro de Eventos Pagos"

// Prepara Indices para utilização no loop e subfunções
BAU->(dbSetOrder(1)) //BAU_FILIAL+BAU_CODIGO
BA1->(dbSetOrder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
BA3->(dbSetOrder(1)) //BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB
BG9->(dbSetOrder(1)) //BG9_FILIAL+BG9_CODINT+BG9_CODIGO+BG9_TIPO
BT5->(dbSetOrder(1)) //BT5_FILIAL+BT5_CODINT+BT5_CODIGO+BT5_NUMCON+BT5_VERSAO
BI3->(dbSetOrder(5)) //BI3_FILIAL+BI3_CODINT+BI3_CODIGO
BI6->(dbSetOrder(1)) //BI6_FILIAL+BI6_CODSEG
BII->(dbSetOrder(1)) //BII_FILIAL+BII_CODIGO
BOW->(dbSetOrder(1)) //BOW_FILIAL+BOW_PROTOC
BR8->(dbSetOrder(1)) //BR8_FILIAL+BR8_CODPAD+BR8_CODPSA+BR8_ANASIN
BQB->(dbSetOrder(2)) //BQB_FILIAL+BQB_CODINT+BQB_CDEMP+BQB_NUMCON+BQB_VERSAO+DTOS(BQB_DATINI)
SX5->(dbSetOrder(1)) //X5_FILIAL+X5_TABELA+X5_CHAVE
B45->(dbSetOrder(1)) //B45_FILIAL+B45_OPEMOV+B45_ANOAUT+B45_MESAUT+B45_NUMAUT+B45_SEQUEN
BK6->(dbSetOrder(4)) //BK6_FILIAL+BK6_CGC
BCI->(DBSetOrder(1)) //BCI_FILIAL+BCI_CODOPE+BCI_CODLDP+BCI_CODPEG+BCI_FASE+BCI_SITUAC

nTotReg := TRBLIV->(LASTREC())

//define regua
oReport:setMeter(nTotReg)
	
If !TRBLIV->(EoF())

	if empty(alias())
		dbselectarea(cAliasCab)
	endIf	
	
//	TRBLIV->(DbgoTop())
	
//	While !TRBLIV->(eof())
//		//Verifica se estamos no último registro dos totais, pra tratar os casos que a soma dos proporcionais proporcionados da proporção proporcional ficam inferiores ao valor total
//		lEndIsNear	:= .F.
//		nEINPosatu++ //	:= 0
		
//		If nEINPosatu == 1
//			nPosSE2 := TRBLIV->SE2Recno
//			nPosSE2ORI := TRBLIV->RECNOTFAT
//		endIf
//		
//		If ( nPosSE2 <> TRBLIV->SE2Recno .and. TRBLIV->SE2Recno > 0 ) .OR. (nPosSE2ORI <> TRBLIV->RECNOTFAT .and. TRBLIV->RECNOTFAT > 0 )
//			lEndIsNear := .T.
//			nPosSE2 := TRBLIV->SE2Recno
//			nPosSE2ORI := TRBLIV->RECNOTFAT
//		endIf
//		If lEndIsNear
//			aadd(aEndIsNear, nEINPosatu - 1)
//		endIf
//		TRBLIV->(DbSkip())	
//	EndDo
	
//	aadd(aEndIsNear, nEINPosatu )
	
	TRBLIV->(DbgoTop())
	nPosSE2	:= 0
	nPosSE2ORI	:= 0
	nPosFK2 := 0
	while !oReport:cancel() .and. !TRBLIV->(eof())
		nEIN++
		oReport:incMeter()
		//conout(" M1 " + Str(nEIN) + " : " + time())
		SE2->( msGoTo( TRBLIV->SE2Recno ) )	
		BD7->( msGoTo( TRBLIV->BD7Recno ) )
		
		//limpa variaveis publicas	
		ratGLBPub('SE2')

		cBCIDtDigi := ""
		If BCI->( MSSeek( xFilial("BCI") + BD7->( BD7_CODOPE+BD7_CODLDP+BD7_CODPEG ) ) ) .AND. BD7->BD7_TIPGUI <> REEMBOLSO
			cBCIDtDigi := DtoC(BCI->BCI_DTDIGI)
		elseIf BD7->BD7_TIPGUI == REEMBOLSO
			cBCIDtDigi := DtoC(BD7->BD7_DTDIGI)
		EndIf

		// Controle de arredondamento de títulos
		// Se Peg diferente ou Titulo diferente do recno e recno válido
		lMudouTitulo := .f.
		//lEndIsNear := aScan(aEndIsNear, nEIN) > 0
		lEndIsNear := .F.
		lMudouFK2 := TRBLIV->RECFK2 <> nPosFK2
		nPosFK2 := TRBLIV->RECFK2
		If ( nPosSE2 <> TRBLIV->SE2Recno .and. TRBLIV->SE2Recno > 0 ) 

			nPosSE2 	:= TRBLIV->SE2Recno
			cLastPEG	:= BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG)
			lMudouTitulo:= .T.
			if empty(alias())
            	dbselectarea(cAliasCab)
            endif
//			nSaldo		:= SaldoTit(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_NATUREZ, 'P', SE2->E2_FORNECE, 1, SE2->E2_BAIXA, SE2->E2_BAIXA, SE2->E2_LOJA, xFilial('SE2'), 1, 2 ) 
//			SE2->(E2_FILIAL) + '|' + SE2->E2_PREFIXO + '|' + SE2->E2_NUM + '|' + SE2->E2_PARCELA + '|' + SE2->E2_TIPO + '|' + SE2->E2_FORNECE + '|' + SE2->E2_LOJA
			nDescCom	:= DescSF1()
			nTotBD7PG := SumBD7PG(SE2->E2_FILIAL + '|' + SE2->E2_PREFIXO + '|' + SE2->E2_NUM + '|' + SE2->E2_PARCELA + '|' + SE2->E2_TIPO + '|' + SE2->E2_FORNECE + '|' + SE2->E2_LOJA)
		EndIf

		//se mudou o titulo baixado, ou algum titulo origem em caso de aglitinacao, zero as variaveis 
		if lMudouFK2 .OR. lMudouTitulo .Or. (nPosSE2ORI <> TRBLIV->RECNOTFAT .and. TRBLIV->RECNOTFAT > 0 )
			If lMudouTitulo
				nI8tottot := 0
				aI8Acutot := {0, 0, 0}
			endIf
			nAcuIRRF	:= 0	// Acumula o IR em valor
			nAcuISS		:= 0	// Acumula o ISS em valor
			nAcuINSS	:= 0	// Acumula o INSS em valor
			nAcuPIS		:= 0	// Acumula o PIS em valor
			nAcuCOF		:= 0	// Acumula o COFINS em valor
			nAcuCSLL	:= 0	// Acumula o CSLL em valor
			nAcuDesc	:= 0	// Acumula o Desconto em valor
			nAcuPerc	:= 0	// Acumula o percentual do valor pago para ajuste do último registro do título
			nAcutotXX	:= 0
			nTotTot	:= 0
			nPosSE2ORI	:= TRBLIV->RECNOTFAT
			nXtot	:= 0
		endif

		BD6->( msGoTo( TRBLIV->BD6Recno ) )

		//posiciona no cabecalho da guia
		if cChaveCAB <> BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO)
	    	
	       	cAliasCAB := PlRetAlias( BD7->BD7_CODOPE,BD7->BD7_TIPGUI)
	        cChaveCAB := BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO)
	       	  
	        (cAliasCAB)->( msSeek( cChaveCAB ) )
	        
	        lReemb	:= .F.

	        //guia de reembolso
	        if BD7->BD7_TIPGUI == REEMBOLSO
		        B44->( msSeek( xFilial("B44") + (cAliasCAB)->(BD5_OPEMOV+BD5_ANOAUT+BD5_MESAUT+BD5_NUMAUT) ) )
		        BOW->( msSeek( xFilial("BOW") + B44->B44_PROTOC ) )
		        lReemb	:= Month(BD7->BD7_DTDIGI) == Month(BD7->BD7_DTCTBF) 	        
	        endIf
		    
		    //Posiciona nas tabelas auxliares  
			fposTAux()
		    
			// DATA DE VENCIMENTO PARA O USUÁRIO
			aRetBlq	:= PLSIBBLQ(dtos(dDatAte),dtos(dDatAte),,BD7->(BD7_OPEUSR+BD7_CODEMP+BD7_MATRIC),BD7->BD7_TIPREG,BA1->BA1_LOCSIB,'')

			dTerCon	:= ctod('')
			if Len(aRetBlq) > 0 .and. valType("aRetBlq[Len(aRetBlq)]") == 'L'
				dTerCon	:= iIf(aRetBlq[len(aRetBlq),7], Iif(aRetBlq[len(aRetBlq)]=='0', aRetBlq[len(aRetBlq),3], aRetBlq[len(aRetBlq),4] ), ctod('') )
			endIf 		
				
			cChvGui := BD7->(BD7_CODLDP+BD7_CODPEG+BD7_NUMERO)
			
			if	BD7->BD7_TIPGUI == REEMBOLSO
				B44->(dbSetOrder(5))
				If B44->(MsSeek(xfilial("B44") + BD7->BD7_CODPEG + BD7->BD7_NUMERO))
					If BOW->(MsSeek(xfilial("BOW") + B44->B44_PROTOC))
						dDtVenc := BOW->BOW_DTDIGI + nsomRee
						cBCIDtDigi := Dtoc(BOW->BOW_DTDIGI)
					endIf
				endIf
			elseIf BCI->(msseek( xfilial("BCI") + BD7->(BD7_CODOPE + BD7_CODLDP + BD7_CODPEG) ))
				dDtVenc := BCI->BCI_DATPAG
			endIf
	    
	    EndIf

		// Classificações abaixo ficam fora do if de cabeçalho porque pode rejeitar o primeiro registro		
	    // Classifica o tipo de documento
		If BD7->BD7_TIPGUI == REEMBOLSO
			cTipDoc	:= 'REM'
		ElseIf BAU->BAU_TIPPRE = cPlTpRec
			cTipDoc	:= 'RECT'		
		ElseIf cAliasCab == 'BD5' .and. !empty(BD5->BD5_TIPATE) .and. BD5->BD5_TIPATE $ cSauOcu
			cTipDoc	:= 'SO'
		elseIf ( BT5->BT5_INTERC == '1' .AND. BD7->BD7_TIPGUI <> '04' )
			//	( BT5->BT5_INTERC <> '1' .or. BD7->BD7_TIPGUI == '04' )
			ctipdoc := 'RECA'
		elseIf ( BT5->BT5_INTERC <> '1' .AND. BD7->BD7_CODRDA == cRDASUS )
			//	( BT5->BT5_INTERC == '1' .or. BD7->BD7_CODRDA != cRDASUS )
			ctipdoc	:= 'SUS'
		Else
			cTipDoc	:= 'FAT'
		EndIf

		// Classifica o tipo de faturamento
	    if BG9->BG9_TIPO == "1" //PF
			cTipFat := "F"     
		else

	        if empty(BA1->BA1_CONEMP)
		
				cMsg := "Contrato (BT5) não cadastrado."
				cMsg += "Usuário: " + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
				aadd(aLog,cMsg)
	    
		        TRBLIV->(dbSkip())
	        	loop
	        	
	        else

	        	// Eventual
	            if BT5->BT5_TIPOIN == cPlsCDIE
	                cTipFat := "E" 
	            // Repasse
	            elseIf BT5->BT5_TIPOIN == '02'
	                cTipFat := "R"
	            // Reciprocidade
	            elseIf BT5->BT5_TIPOIN == '03'
	                cTipFat := "RC"
	            // PJ
	            else
	                cTipFat := "J" 
	            endIf

		    endIf

		endIf    
		
		//Alimenta data de inicio, e término do contrato quando outro tipo de faturamento. 
		If cTipFat $ "F#J"
			dIniCon := BA1->BA1_DATINC
		Else
			dIniCon := BQB->BQB_DATINI
			dTerCon := IIf(Empty(dTerCon), BQB->BQB_DATFIN, dTerCon )
		EndIf

		//Alimenta o numero do contrato...
		Do Case
			Case cTipFat == "F"
				cNumCon := BA1->BA1_CODINT + "." + BA1->BA1_CODEMP + "." + BA1->BA1_MATRIC + space(16) 
			Case cTipFat == "J"
				cNumCon := BA1->BA1_CODINT + "." + BA1->BA1_CODEMP + "." + BA1->BA1_CONEMP + "." + BA1->BA1_SUBCON
			OtherWise
				cNumCon := BA1->BA1_CODINT + "." + BA1->BA1_CODEMP + "." + BA1->BA1_CONEMP + space(10)
		EndCase
		
		//Checa se repete item da guia para posicionamentos 
		If cChaveBD7 <> BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)
		    
			cChaveBD7 := xFilial("BD7") + BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)
			
			//posiciona na tabela YR - por Item
			If !EMPTY(BD7->BD7_TPEVCT)
			
				If SX5->( X5_FILIAL + X5_TABELA + AllTrim(X5_CHAVE) ) <> xFilial("SX5") + 'YR' + BD7->BD7_TPEVCT 	
					SX5->( msSeek( xFilial("SX5") + 'YR' + BD7->BD7_TPEVCT  ) )
					cTpEvCt	:= SX5->X5_DESCRI
				else
					cTpEvCt	:= SX5->X5_DESCRI
				EndIf

			Else
				cCodEve := PlTpServ(BD7->BD7_CODPAD,BD7->BD7_CODPRO)
				cTpEvCt := Posicione("SX5",1,xFilial("SX5")+"YR"+cCodEve,"X5_DESCRI")
			EndIf	

	        //guia de reembolso
	        If BD7->BD7_TIPGUI == REEMBOLSO
				B45->( msSeek( xFilial("B45") + (cAliasCAB)->(BD5_OPEMOV+BD5_ANOAUT+BD5_MESAUT+BD5_NUMAUT) + BD7->BD7_SEQUEN  ) )
				BK6->( msSeek( xFilial("BK6") + B45->B45_CODREF ) )
		        lReemb	:= Month(BD7->BD7_DTDIGI) == Month(BD7->BD7_DTCTBF) 	        
	        EndIf
		EndIf 	
		
		// Nao considera se nao conseguiu classificar
		if empty(cTipDoc)
			TRBLIV->(dbSkip())
			loop
		endIf		

		//Se Benef.Operadoras, não deve considerar outras operadoras               
		if MV_PAR07 == 1 .and. ( BT5->BT5_INTERC == '1' .OR. cTipDoc == 'SO' .OR. BD7->BD7_CODRDA == cRDASUS )
			TRBLIV->(dbSkip())
			loop
		endIf	
		
		//Se Benef.Outras Operadoras, não deve considerar guias de reembolsos.     
		if MV_PAR07 == 2 .and. ( BT5->BT5_INTERC <> '1' .or. BD7->BD7_TIPGUI == '04' )
			TRBLIV->(dbSkip())
			loop
		Elseif MV_PAR07 == 2
			cTipDoc	:= 'RECA'
		endIf	
		
		//Se N.Rel.Atd Medico/Hospitalar.
		If MV_PAR07 <> 3 .AND. cTipDoc == 'SO'
			TRBLIV->(dbSkip())
			loop
		endIf	
		
		//Se Ressarcimento ao SUS, filtra atendimentos por RDA = MV_RDASUS         
		if MV_PAR07 == 4 .and. ( BT5->BT5_INTERC == '1' .or. BD7->BD7_CODRDA != cRDASUS )
			TRBLIV->(dbSkip())
			loop
		Elseif MV_PAR07 == 4
			cTipDoc	:= 'SUS'
		endIf
		
		if oReport:Cancel()
			exit
		endIf
		
		// Valida registro, se retornar .T. nao reposiciona
		if cLastFam <> BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)

			nPosBA1	 := BA1->(Recno())
   			cLastFam := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)

			if ! (BA1->( msSeek( xFilial("BA1") + TRBLIV->( BD7_OPEUSR + BD7_CODEMP + BD7_MATRIC )+ getNewPar("MV_PLTRTIT",'00') ) ))
				
				BA1->(dbSetOrder(1))
				If ! (BA1->( msSeek( xFilial("BA1") + TRBLIV->( BD7_OPEUSR + BD7_CODEMP + BD7_MATRIC )+ GetNewPar("MV_PLCDTIT","T") )))
					nURUindex := PLSBUIND("BA1","BA1_FILIAL+BA1_ORGEM+BA1_DRGUSR")
					If nURUindex > 0
						BA1->(DbSetOrder(21))
					else
						BA1->(DbSetOrder(20))
					endIf
					(BA1->( msSeek( xFilial("BA1") + TRBLIV->( BD7_OPEUSR + BD7_CODEMP + BD7_MATRIC )+ '1' )))
				EndIf
				BA1->(dbsetOrder(2))

			endIf

			cMatTit := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
			cCpfTit := BA1->BA1_CPFUSR
			cNomTit := BA1->BA1_NOMUSR

			BA1->(msGoTo(nPosBA1))

		EndIf
 
   		if cMesAno <> BD7->(BD7_MESPAG+BD7_ANOPAG)  

			//reiniciar ar quebras por tipo de contrato, cobertura, modpag e ad lei
			if !empty(cMesAno) .and. MV_PAR06 == 1 

				cSeMpADl := ''
		 		cTipCon	 := ''
			endIf
			
			cMesAno := BD7->(BD7_MESPAG+BD7_ANOPAG)
		endIf
	
		if cLastProd <> BI3->BI3_CODIGO

			cLastProd 	:= BI3->BI3_CODIGO  			
			cSusEp		:= BI3->BI3_SUSEP
			dRegAns		:= BI3->BI3_DTAPPR
			cCodSeg 	:= BI3->BI3_CODSEG
			cDescSeg 	:= allTrim(BI6->BI6_DESCRI)
								
			//1=Pre-Pagamento;2=Demais Modalidades;3=Pos-Estabelecido;4=Misto (Pre/Pos); 9=Nao Definida
			nPos := ascan(aModPag,{|x| x[2] == allTrim(BI3->BI3_MODPAG)})

			cModPag := ""
			if nPos > 0 
				cModPag := allTrim(aModPag[nPos,3])
			endIf

			//data aprovacao do produto pela ans
			cADLei := Iif( BI3->BI3_DTAPPR <= ADLei, 'Antes da lei','Depois da lei' )

		endIf
				
		if MV_PAR06 == 1

			//reiniciar quebra tipo de contrato
			if !empty(cTipCon) .and. cTipCon <> BI3->BI3_TIPCON
				cTipCon := ''
			endIf
			
			if !empty(cSeMpADl) .and. cSeMpADl <> cCodSeg+' - '+cModPag+' - '+cADLei									
				//reiniciar quebra de segmento
				cTipCon := ''
			endIf	
		
			//segregado por seguimento, modalidade de pagamento e Ad lei			
			if cSeMpADl <> cCodSeg + ' - ' + cModPag + ' - ' + cADLei
				cSeMpADl := cCodSeg + ' - ' + cModPag + ' - ' + cADLei
			endIf

			//Tipo de contrato - TPCONTRATO
			if cTipCon <> BI3->BI3_TIPCON 

				cTipCon := BI3->BI3_TIPCON 
			endIf
			
		else
			
			//segregado por seguimento, modalidade de pagamento e Ad lei			
			if cSeMpADl <> cCodSeg + ' - ' + cModPag + ' - ' + cADLei
				cSeMpADl := cCodSeg + ' - ' + cModPag + ' - ' + cADLei
				cTipCon := ''
			endIf

			//Tipo de contrato - TPCONTRATO
			if cTipCon <> BI3->BI3_TIPCON
				cTipCon := BI3->BI3_TIPCON 
			endIf

		endIf
		
		//chave CT2
		cChvCtb := iIf( empty(BD7->BD7_CHVLA), BD7->BD7_CHVPRO, BD7->BD7_CHVLA )
		
		If empTy(cChvCtb)
			cChvCtb := fnChvCTB(BD7->BD7_CODOPE, BD7->BD7_CODLDP, BD7->BD7_CODPEG, BD7->BD7_NUMERO, BD7->BD7_SEQUEN)
		endIf
		
		cDocCtb	:= allTrim( subStr(cChvCtb, 9, len(cChvCtb)) )
		dDtCtb	:= stod( allTrim(subStr(cChvCtb, 1, 8)) )

		// Limpa variaveis a cada registro para nao influenciar na soma dos totalizadores
		nValINSS := 0
		nValIRRF := 0
		nValISS  := 0
		nValDesc := 0
		nVlrLiqG := 0
		nValBrut := 0		
		nValPIS  := 0 
		nValCOF  := 0 
		nValCSLL := 0

		//informacoes do titulo
		oSTITULO:init()
		
		If TRBLIV->FK2_TPDOC == 'ES'
			nMulSinal := -1
		else
			nMulSinal := 1
		EndIf
		

		oSTITULO:cell("CODLDP"):setValue(BD7->BD7_CODLDP)		
		If BD7->BD7_TIPGUI == REEMBOLSO
			oSTITULO:cell("NUMPRT"):setValue(BD7->BD7_PROTOC)
			oSTITULO:cell("NUMGUI"):setValue('')		
		else
			oSTITULO:cell("NUMPRT"):setValue(BD7->BD7_CODPEG)
			oSTITULO:cell("NUMGUI"):setValue(BD7->BD7_NUMERO)		
		EndIF
				
		
		oSTITULO:cell("CONTRATO"):setValue(BA1->(BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB))
		oSTITULO:cell("MATRIC"):setValue(cMatTit)
        oSTITULO:cell("INICON"):setValue(dIniCon)
        oSTITULO:cell("TERCON"):setValue(IIf(Empty(dTerCon), CtoD('31/12/9999'), dTerCon))
        oSTITULO:cell("DTCONH"):setValue(cBCIDtDigi)
		
		oSTITULO:cell("NOMETIT"):setValue(cNomTit)
		oSTITULO:cell("CNPJTIT"):setValue(cCpfTit)
  		oSTITULO:cell("NOMEBEN"):setValue(BA1->BA1_NOMUSR)
  		
		oSTITULO:cell("DTOCORR"):setValue(BD7->BD7_DATPRO)
		oSTITULO:cell("CODPRE"):setValue(BD7->BD7_CODRDA)

		cCnpjPre := IIf( BD7->BD7_TIPGUI == REEMBOLSO, IIf(!Empty(B45->B45_CODREF), IIf(!Empty(BK6->BK6_CGC) ,BK6->BK6_CGC ,cCpfTit), IIf(!Empty(BOW->BOW_CODREF),BOW->BOW_CODREF, cCpfTit ) ), BAU->BAU_CPFCGC )
		
		oSTITULO:cell("CNPJPR"):setValue( cCnpjPre )
		oSTITULO:cell("NOMEPR"):setValue( IIf( BD7->BD7_TIPGUI == REEMBOLSO, IIf(!Empty(B45->B45_CODREF), IIf(!Empty(BK6->BK6_NOME),BK6->BK6_NOME,cNomTit), IIf(!Empty(BOW->BOW_NOMREF),BOW->BOW_NOMREF, cNomTit ) ), BAU->BAU_NOME   ) )
		oSTITULO:cell("FORNECE"):setValue( SE2->E2_FORNECE ) //IIf( BD7->BD7_TIPGUI == REEMBOLSO, BOW->BOW_FORNEC, BAU->BAU_CODSA2 ) )
		oSTITULO:cell("TIPDOC"):setValue(cTipDoc)
		
		oSTITULO:cell("DOCCTB"):setValue(cDocCtb)
		oSTITULO:cell("DTCTB"):setValue(dDtCtb)
		
		//oSTITULO:cell("VLREVE"):setValue( IIf(lReemb, TRBLIV->BD7TVLRPAG, IIF( TRBLIV->BD7TVLRY <= 0, TRBLIV->BD7TVLRAPR, TRBLIV->BD7TVLRY ) ) - ( IIF( TRBLIV->BD7TVTXAP <= 0 , TRBLIV->BD7TVLTXPG + TRBLIV->BD7TVLRGTX, TRBLIV->BD7TVTXAP ) ) )
		oSTITULO:cell("VLREVE"):setValue( (IIf(lReemb, TRBLIV->BD7TVLRPAG, TRBLIV->BD7TVLRY ) - TRBLIV->BD7TVLTXPG) * nMulSinal )
		oSTITULO:cell("VLTXPG"):setValue( (TRBLIV->BD7TVLTXPG + TRBLIV->BD7TVLRGTX) * nMulSinal )
		oSTITULO:cell("VLRGTX"):setValue(TRBLIV->BD7TVLRGTX * nMulSinal)
		oSTITULO:cell("VLRGLO"):setValue( (IIf(BD7->BD7_FASE > '1',IIf(lReemb, 0, IIf( BD7->BD7_DTCTBF <= dDatAte, TRBLIV->BD7TVLRGLO, 0 ) ), 0)) * nMulSinal)
		oSTITULO:cell("DTGER"):setValue(BD7->BD7_DTPAGT)
		
		oSTITULO:cell("TIPEVE"):setValue(cTpEvCt) 
		
		oSTITULO:cell("REGPRO"):setValue(cSusEp)
		
		oSTITULO:cell("SEGMENTACAO"):setValue(cDescSeg + " | " + cModPag + " | " + cADLei)			
		oSTITULO:cell("TPCONTRATO"):setValue( BII->BII_DESCRI )			
		
		FK2->(DbgoTo(TRBLIV->RECFK2))
		
		If lBaixaDisp
			oSTITULO:cell("DTBAIX"):setValue(FK2->FK2_DTDISP)
		Else
			oSTITULO:cell("DTBAIX"):setValue(FK2->FK2_DATA)
		EndIf
		oSTITULO:cell("PFPJ"):setValue(IIf(Len( Alltrim(cCnpjPre) ) < 14, 'PF', 'PJ' ))

		oSTITULO:cell("TITULO"):setValue(SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO))
		oSTITULO:cell("DTVENC"):setValue(DtoC(dDtVenc))
		
		If TRBLIV->RECNOTFAT > 0
			zBkpRecSE2 := SE2->(Recno())
			lisrecFat	:= .T.
			nCSLLRF	:= SE2->E2_VRETCSL
			nPISRF		:= SE2->E2_VRETPIS
			nCOFINRF 	:= SE2->E2_VRETCOF
			nE2VLRX	:= SE2->E2_VALOR
			SE2->(DbGoto(TRBLIV->RECNOTFAT))
			nTotBD7PG := SumBD7PG(SE2->E2_FILIAL + '|' + SE2->E2_PREFIXO + '|' + SE2->E2_NUM + '|' + SE2->E2_PARCELA + '|' + SE2->E2_TIPO + '|' + SE2->E2_FORNECE + '|' + SE2->E2_LOJA)
		else
			lisrecFat	:= .F.
		endIf
		
		If lisrecFat
			nValBrut := nE2VLRX
		else
			nValBrut := IIF(nTotBD7PG > 0, nTotBD7PG /*+ nDescCom*/, SE2->(E2_VALOR+E2_INSS+E2_IRRF+E2_ISS) + nDescCom)
		endIf
		// Fator de representacao desse item no total do titulo
		//nFator := IIf( TRBLIV->BD7TVLRPAG/nValBrut >0, NoRound(TRBLIV->BD7TVLRPAG/nValBrut,8) , 1 )
		nFator := IIf( TRBLIV->BD7TVLRPAG/nValBrut >0, (TRBLIV->BD7TVLRPAG/nValBrut) , 1 )
		nFatBD7E2 := nFator
		If lisrecFat
			nFator := TRBLIV->BD7TVLRPAG / nTotBD7PG * SE2->E2_VALLIQ / nValBrut//SE2->(E2_VALOR+E2_INSS+E2_IRRF+E2_ISS) * SE2->E2_VALLIQ / nValBrut
			nXfactor := TRBLIV->BD7TVLRPAG / nTotBD7PG //SE2->(E2_VALOR+E2_INSS+E2_IRRF+E2_ISS)
			nFatBD7E2 := nXfactor
		endIf
		nfatorz := nFator
		
		If !lisrecFat .AND. FK2->FK2_VALOR <= SE2->E2_VALOR - SE2->( E2_VRETCOF + E2_VRETPIS + E2_VRETCSL )
			nFator := nfator * ( FK2->FK2_VALOR ) /  ( SE2->E2_VALOR - SE2->( E2_VRETCOF + E2_VRETPIS + E2_VRETCSL ) )
			nfatPagY := ( FK2->FK2_VALOR ) /  ( SE2->E2_VALOR - SE2->( E2_VRETCOF + E2_VRETPIS + E2_VRETCSL ) )
		elseIf lisrecFat .AND. FK2->FK2_VALOR <= (nE2VLRX - nCSLLRF - nPISRF - nCOFINRF)//SE2->( E2_VRETCOF + E2_VRETPIS + E2_VRETCSL )
			nFator := nfator * ( FK2->FK2_VALOR ) /  ( nE2VLRX - nCSLLRF - nPISRF - nCOFINRF)
			nXfactor := nXfactor * ( FK2->FK2_VALOR ) /  ( nE2VLRX - nCSLLRF - nPISRF - nCOFINRF)
			nfatPagY := ( FK2->FK2_VALOR ) /  ( nE2VLRX - nCSLLRF - nPISRF - nCOFINRF)
		else
			linvertido := .T.
			nfatPagY := nFator
		EndIf
		// No fator, aplica o percentual que pagou desse título, analisando o que está em aberto
		If .F. // !lisrecFat .AND. nSaldo > 0 .AND. nSaldo <> SE2->E2_VALOR
			nFator := nFator * ( 1- NoRound(nSaldo / SE2->E2_VALOR,8) )
		EndIf

		nAcuPerc	+= nFator		// Acumula o percentual do valor pago para ajuste do último registro do título
		nXtot		+= nXfactor
		lPassou100	:= .F.
		If nAcuPerc > 1
			nFator := nFator - (nAcuPerc - 1)
			nAcuPerc := 1
			lPassou100 := .T.
		endIf
		
		nI8tottot += nFator
		If nI8tottot > 1
			nI8tottot := 1
		endIf
		
		If nFator > nLimFat	
			//INSS - 
			//nValINSS	:= NoRound(SE2->E2_INSS * IIF(lisrecFat, nXfactor,nFator),2)
			nValINSS	:= (SE2->E2_INSS * IIF(lisrecFat, nXfactor,nFator))
			nAcuINSS	+= nValINSS		// Acumula o INSS em valor
			If nAcuINSS > SE2->E2_INSS
				nValDif := SE2->E2_INSS - nAcuINSS
				nValINSS += nValDif
				nAcuINSS := SE2->E2_INSS
			elseIf lEndIsNear .AND. nAcuINSS < (SE2->E2_INSS * IIF(lisrecFat, nXtot,nAcuPerc)) //nAcuINSS < Noround(SE2->E2_INSS * nAcuPerc, 2)
				nValDif := (SE2->E2_INSS * IIF(lisrecFat, nXfactor,nAcuPerc)) - nAcuINSS // Noround(SE2->E2_INSS * nAcuPerc, 2) - nAcuINSS
				nValINSS += nValDif
				If MV_PAR07 == 1
					nValINSS := Upsidedown(nValINSS)
				endIf
				nAcuINSS := (SE2->E2_INSS * nAcuPerc) //Noround(SE2->E2_INSS * nAcuPerc, 2)
			EndIf
			//oSTITULO:cell("VLINSS"):setValue(nValINSS * nMulSinal)
			If lPassou100
				oSTITULO:cell("VLINSS"):setValue(nValINSS * nMulSinal)
			else
				oSTITULO:cell("VLINSS"):setValue(SE2->E2_INSS * nFatBD7E2 * nMulSinal)
			endIf
	
			//nValIRRF	:= NoRound(SE2->E2_IRRF * IIF(lisrecFat, nXfactor,nFator),2)
			nValIRRF	:= (SE2->E2_IRRF * IIF(lisrecFat, nXfactor,nFator))
			nAcuIRRF	+= nValIRRF		// Acumula o IR em valor
			If nAcuIRRF > SE2->E2_IRRF
				nValDif := SE2->E2_IRRF - nAcuIRRF
				nValIRRF += nValDif
				nAcuIRRF := SE2->E2_IRRF
			elseIf lEndIsNear .AND. nAcuIRRF < SE2->E2_IRRF * IIF(lisrecFat, nXtot,nAcuPerc) //nAcuIRRF < Noround(SE2->E2_IRRF * nAcuPerc, 2)
				nValDif := SE2->E2_IRRF * IIF(lisrecFat, nXtot,nAcuPerc) - nAcuIRRF//Noround(SE2->E2_IRRF * nAcuPerc, 2) - nAcuIRRF
				nValIRRF += nValDif
				If MV_PAR07 == 1
					nValIRRF := Upsidedown(nValIRRF)
				endIf
				nAcuIRRF := SE2->E2_IRRF * IIF(lisrecFat, nXtot,nAcuPerc) //Noround(SE2->E2_IRRF * nAcuPerc, 2)
			EndIf
			//oSTITULO:cell("VLIRRF"):setValue(nValIRRF * nMulSinal)
			If lPassou100
				oSTITULO:cell("VLIRRF"):setValue(nValIRRF * nMulSinal)
			else
				oSTITULO:cell("VLIRRF"):setValue(SE2->E2_IRRF  * nFatBD7E2 * nMulSinal)
			endIf
			//nValISS		:= NoRound(SE2->E2_ISS * IIF(lisrecFat, nXfactor,nFator),2)
			nValISS		:= (SE2->E2_ISS * IIF(lisrecFat, nXfactor,nFator))
			nAcuISS		+= nValISS		// Acumula o ISS em valor
			If nAcuISS > SE2->E2_ISS
				nValDif := SE2->E2_ISS - nAcuISS
				nValISS += nValDif
				nAcuISS := SE2->E2_ISS
			elseIf lEndIsNear .AND. nAcuISS < SE2->E2_ISS * IIF(lisrecFat, nXtot,nAcuPerc)//Noround(SE2->E2_ISS * nAcuPerc, 2)
				nValDif := (SE2->E2_ISS * IIF(lisrecFat, nXtot,nAcuPerc)) - nAcuISS //Noround(SE2->E2_ISS * nAcuPerc, 2) - nAcuISS
				nValISS += nValDif
				If MV_PAR07 == 1
					nValISS := Upsidedown(nValISS)
				endIf
				nAcuISS := SE2->E2_ISS * IIF(lisrecFat, nXtot,nAcuPerc) //Noround(SE2->E2_ISS * nAcuPerc, 2)
			EndIf
			//oSTITULO:cell("VLISS"):setValue(nValISS * nMulSinal)
			If lPassou100
				oSTITULO:cell("VLISS"):setValue(nValISS * nMulSinal)
			else
				oSTITULO:cell("VLISS"):setValue(SE2->E2_ISS * nFatBD7E2 * nMulSinal)
			endIf
			
			If lisrecFat
				//nValPIS := NoRound(nPISRF*nFator,2)
				nValPIS := (nPISRF*nFator)
				nVRETPIS := nPISRF
			else
				//nValPIS := NoRound(SE2->E2_VRETPIS*nFator,2)
				nValPIS := (SE2->E2_VRETPIS*nFator)
				nVRETPIS := SE2->E2_VRETPIS
			endIf
			nAcuPIS		+= nValPIS		// Acumula o PIS em valor
			If lIsRecFat
				aI8Acutot[1] += nValPIS// := {0, 0, 0}
			endIf
			
			if nAcuPIS > nVRETPIS
				nValDif := nVRETPIS - nAcuPIS
				nValPIS += nValDif
				nAcuPIS := nVRETPIS
			elseIf lEndIsNear .AND. nAcuPIS < nVRETPIS * nAcuPerc //Noround(SE2->E2_VRETPIS * nAcuPerc, 2)
				If lisrecFat
					nValDif := nVRETPIS * nI8tottot - aI8Acutot[1]
				else
					nValDif := nVRETPIS * nAcuPerc - nAcuPIS
				endIf
				If lIsRecFat
					aI8Acutot[1] -= nValPIS// := {0, 0, 0}
				endIf
				nValPIS += nValDif
				If MV_PAR07 == 1
					nValPIS := Upsidedown(nValPIS)
				endIf
				nAcuPIS := nVRETPIS * nAcuPerc
				If lIsRecFat
					//aI8Acutot[1] += round(nValPIS,2)// := {0, 0, 0}
					aI8Acutot[1] += (nValPIS)// := {0, 0, 0}
				endIf
			endIf
			oSTITULO:cell("VLPIS"):setValue(nValPIS * nMulSinal)
						
			If lisrecFat
				//nValCOF	:= NoRound(nCOFINRF*nFator,2)
				nValCOF	:= (nCOFINRF*nFator)
				nVRETCOF := nCOFINRF
			else
				//nValCOF	:= NoRound(SE2->E2_VRETCOF*nFator,2)
				nValCOF	:= (SE2->E2_VRETCOF*nFator)
				nVRETCOF := SE2->E2_VRETCOF
			endIf
			nAcuCOF		+= nValCOF		// Acumula o COFINS em valor
			If lIsRecFat
				aI8Acutot[2] += nValCOF// := {0, 0, 0}
			endIf
			if nAcuCOF > nVRETCOF
				nValDif := nVRETCOF - nAcuCOF
				nValCOF += nValDif
				nAcuCOF := nVRETCOF
			elseIf lEndIsNear .AND. nAcuCOF < nVRETCOF * nAcuPerc //Noround(SE2->E2_VRETCOF * nAcuPerc, 2)
				If lisrecFat
					nValDif := nVRETCOF * nI8tottot - aI8Acutot[2]
				else
					nValDif := nVRETCOF * nAcuPerc - nAcuCOF
				endIf
				If lIsRecFat
					aI8Acutot[2] -= nValCOF// := {0, 0, 0}
				endIf
				nValCOF += nValDif
				If MV_PAR07 == 1
					nValCOF := Upsidedown(nValCOF)
				endIf
				nAcuCOF := nVRETCOF * nAcuPerc
				If lIsRecFat
					//aI8Acutot[2] += round(nValCOF,2)// := {0, 0, 0}
					aI8Acutot[2] += (nValCOF)// := {0, 0, 0}
				endIf
			endIf
			oSTITULO:cell("VLCOF"):setValue(nValCOF * nMulSinal)
			
			If lisrecFat
				//nValCSLL := NoRound(nCSLLRF*nFator,2)
				nValCSLL := (nCSLLRF*nFator)
				nVRETCSL := nCSLLRF
			else
				//nValCSLL	:= NoRound(SE2->E2_VRETCSL*nFator,2)
				nValCSLL	:= (SE2->E2_VRETCSL*nFator)
				nVRETCSL := SE2->E2_VRETCSL
			endIf
			nAcuCSLL	+= nValCSLL		// Acumula o CSLL em valor
			If lIsRecFat
				aI8Acutot[3] += nValCSLL// := {0, 0, 0}
			endIf
			If nAcuCSLL > nVRETCSL
				nValDif  := nVRETCSL - nAcuCSLL
				nValCSLL += nValDif
				nAcuCSLL := nVRETCSL
			elseIf lEndIsNear .AND. nAcuCSLL < nVRETCSL * nAcuPerc //Noround(SE2->E2_VRETCSL * nAcuPerc, 2)
				If lisrecFat
					nValDif := nVRETCSL * nI8tottot - aI8Acutot[3]
				else
					nValDif  := nVRETCSL * nAcuPerc - nAcuCSLL
				endIf
				If lIsRecFat
					aI8Acutot[3] -= nValCSLL// := {0, 0, 0}
				endIf
				nValCSLL += nValDif
				If MV_PAR07 == 1
					nValCSLL := Upsidedown(nValCSLL)
				endIf
				nAcuCSLL := nVRETCSL * nAcuPerc	
				If lIsRecFat
					//aI8Acutot[3] += round(nValCSLL,2)// := {0, 0, 0}
					aI8Acutot[3] += (nValCSLL)// := {0, 0, 0}
				endIf
			EndIf
			oSTITULO:cell("VLCSLL"):setValue(nValCSLL * nMulSinal)

			//nValDesc	:= NoRound(SE2->E2_DESCONT*nFator,2)
			nValDesc	:= (SE2->E2_DESCONT*nFator)
			nAcuDesc	+= nValDesc	// Acumula o Desconto em valor
			If nAcuDesc > SE2->E2_DESCONT
				nValDif  := SE2->E2_DESCONT - nAcuDesc
				nValDesc += nValDif
				nAcuDesc := SE2->E2_DESCONT
			elseIf lEndIsNear .AND. nAcuDesc < SE2->E2_DESCONT * nAcuPerc //Noround(SE2->E2_DESCONT * nAcuPerc, 2)
				nValDif  := SE2->E2_DESCONT * nAcuPerc - nAcuDesc
				nValDesc += nValDif
				If MV_PAR07 == 1
					nValDesc := Upsidedown(nValDesc)
				endIf
				nAcuDesc := SE2->E2_DESCONT * nAcuPerc
			endIf
			oSTITULO:cell("VLDESC"):setValue(nValDesc * nMulSinal)

		Else
			// Zera variaveis
			nValINSS	:= 0
			oSTITULO:cell("VLINSS"):setValue(nValINSS)

			nValIRRF	:= 0
			oSTITULO:cell("VLIRRF"):setValue(nValIRRF)

			nValISS		:= 0
			oSTITULO:cell("VLISS"):setValue(nValISS)

			nValDesc	:= 0
			oSTITULO:cell("VLDESC"):setValue(nValDesc)
			
			nValPIS := 0
			oSTITULO:cell("VLPIS"):setValue(nValPIS)
			
			nValCOF := 0
			oSTITULO:cell("VLCOF"):setValue(nValCOF)
			
			nValCSLL := 0
			oSTITULO:cell("VLCSLL"):setValue(nValCSLL)
			
			nValDesc := 0
			oSTITULO:cell("VLDESC"):setValue(nValDesc)
		EndIf

		//nVlrLiqG := NoRound(TRBLIV->BD7TVLRPAG*nFator,2) //TRBLIV->BD7TVLRPAG //+ TRBLIV->BD7TVLTXPG - TRBLIV->BD7TVLRGTX + IIf(BD7->BD7_FASE>'1',IIf(lReemb, 0, IIf( BD7->BD7_DTCTBF <= dDatAte, TRBLIV->BD7TVLRGLO, 0 ) ), 0) 
		If nDescCom > 0
			nfatPagY := nfatPagY * (1 - (nDescCom / nValbrut))
		endIf
		nVlrLiqG := (TRBLIV->BD7TVLRPAG*nfatPagY)
		
		If TRBLIV->RECNOTFAT > 0
			SE2->(DbGoto(zBkpRecSE2))
		endIf

		oSTITULO:cell("VLLIQG"):setValue(TRBLIV->BD7TVLRPAG * nMulSinal)

		//uso as proprias colunas do relatório. Só preciso garantir que cada valor esteja correto.
		// Vlr Glosa + Vlr Gl Tx Adm - Vlr INSS - Vlr ISS - Vlr IRRF - Vlr.PIS - Vlr.COF. - Vlr.CSLL - Vlr Desc
		nVlrLiqR := nVlrLiqG //oSTITULO:cell("VLREVE"):GetValue() + oSTITULO:cell("VLTXPG"):GetValue()
	//	nVlrLiqR -= oSTITULO:cell("VLRGLO"):GetValue() 
	//	nVlrLiqR -= oSTITULO:cell("VLRGTX"):GetValue()
		nVlrLiqR -= nValINSS //oSTITULO:cell("VLINSS"):GetValue()
		nVlrLiqR -= nValISS //oSTITULO:cell("VLISS"):GetValue()
		nVlrLiqR -= nValIRRF //oSTITULO:cell("VLIRRF"):GetValue()
		nVlrLiqR -= nValPIS //oSTITULO:cell("VLPIS"):GetValue()
		nVlrLiqR -= nValCOF //oSTITULO:cell("VLCOF"):GetValue()
		nVlrLiqR -= nValCSLL //oSTITULO:cell("VLCSLL"):GetValue()
		nVlrLiqR -= nValDesc //oSTITULO:cell("VLDESC"):GetValue()
//		nvlrLiqR -= (nSaldo * nFator)
		
		If lPassou100 //lendIsNear .ANd. nAcutotXX + nVlrLiqR < SE2->E2_VALLIQ * nAcuPerc .ANd. !linvertido
			nVlrLiqR := SE2->E2_VALLIQ * nAcuPerc - nAcutotXX //- nVlrLiqR		
		else
		//	If lisrecFat
		//		nVlrLiqR := nE2VLRX * nFator
		//	else
				nVlrLiqR := (SE2->E2_VALOR - SE2->( E2_VRETCOF + E2_VRETPIS + E2_VRETCSL ) ) * nFator
		//	endIf
		EndIf
		
		nAcutotXX += nVlrLiqR
		
		If lEndIsNear .AND. (TRBLIV->FK2_TPDOC == 'CP' .OR. SE2->E2_VALOR <> SE2->E2_VALLIQ) .ANd. !linvertido .AND. !lisrecFat
			oSTITULO:cell("VLLIQR"):setValue( FK2->FK2_VALOR * nfatorz * nmulsinal )
		elseif lEndIsNear .AND. lisrecFat
			oSTITULO:cell("VLLIQR"):setValue( (FK2->FK2_VALOR * nAcuPerc -  nTotTot) * nmulsinal)
		else
			oSTITULO:cell("VLLIQR"):setValue( nVlrLiqR * nmulsinal)
		EndIf
		nTotTot += nVlrLiqR
		
		// Viro o registro antes de fechar a linha para recalcular arredondamento, se foi o último registro do título
		TRBLIV->(dbSkip())	
		
		oSTITULO:printLine()
		oSTITULO:finish()
	EndDo

	//conout(" MY : " + time())
	//oReport:finish()
	oReport:endPage()
	
EndIf

//Fecha a tabela temporária 
TRBLIV->(dbCloseArea())

// Limpa os arrays
aSize(aBauVenc,1)
aDel(aBauVenc,1)

aSize(aPadProd,1)
aDel(aPadProd,1)

Return

/*/{Protheus.doc} getTrbQuery
Executa query 

@author DEV
@since 05/03/2016
@version ALL
/*/
static function getTrbQuery(lLog,dDatDe,dDatAte,cTmpTbl)
local nX	 	 	:= 0
local nPos	 		:= 0
local nFator		:= 0
local cQuery	 	:= ''
local cWhere	 	:= '' 
local aStruSQL 	 	:= {}
local aPadProd	 	:= {}
local aTipRel	 	:= { "O", "C", "M", "S", "D" }		// Tipo de Relatório: Operadora, Corresp.Assumida, N.Rel.Pl.Med.Hosp, Ressar.SUS, N.Rel.Pl.Odonto 
local cPlTpRec	 	:= getNewPar("MV_PLTPREC","016")
Local cRDASUS	 	:= getNewPar("MV_RDASUS","SUS")
Local aMotBx		:= {}
Local cMovBan	 	:= ''
local nTFilial		:= tamSX3("E2_FILIAL")[1]
local nPFilial		:= 1
local nTPrefixo		:= tamSX3("E2_PREFIXO")[1]
local nPPrefixo		:= nPFilial + nTFilial + 1
local nTNumero		:= tamSX3("E2_NUM")[1]
local nPNumero		:= nPPrefixo + nTPrefixo + 1
local nTParcela		:= tamSX3("E2_PARCELA")[1]
local nPParcela		:= nPNumero + nTNumero +  1
local nTTipo		:= tamSX3("E2_TIPO")[1]
local nPTipo		:= nPParcela + nTParcela + 1
local nTFornecedor	:= tamSX3("E2_FORNECE")[1]
local nPFornecedor	:= nPTipo + nTTipo + 1
local lBaixaDisp 	:= ( FK2->(FieldPos("FK2_DTDISP")) > 0 ) .AND. lMvDisp
local cCodLDPExc	:= GetNewPar("MV_PLEXDAC", "")


if empty(MV_PAR01) .OR. Empty(MV_PAR02) .or. dDatDe > Date()
    msgAlert(STR0042,STR0046) //"Insira um período válido."//"Atenção"
    Return({.T.})
endIf

if empty(MV_PAR03)
    msgAlert(STR0043,STR0046) //"Operadora deve ser informada."//"Atenção"
    Return({.T.})
endIf

if empty(MV_PAR04+MV_PAR05)
    msgAlert(STR0044,STR0046) //"Parametros de Empresa devem ser informados."//"Atenção"
    Return({.T.})
endIf
		
//Executa ponto de entrada para Complemento de Filtro principal.           
If Existblock("PLR44XP1")
	cWhere += ExecBlock("PLR44XP1",.f.,.f.,{ '443'+aTipRel[MV_PAR07] })
//else
//	cwhere += " AND SE2.E2_NUM = '700151057' "
Endif
//cWhere := " AND SE2.E2_NUM = '8622' "
//motivos de baixa que faz movimentacao bancaria
aMotBx := readMotBx() 
for nX = 1 to len(aMotBx)
    if subStr(aMotBx[nX],19,1) == 'S'  
        if nX > 1
            cMovBAN += "|"
        endIf  
        cMovBAN += subStr(aMotBx[nX],01,03)
    endIf
next

if !empty(cCodLDPExc)
    cCodLDPExc := ConvStrRel(cCodLDPExc)
endif

// Elimina array
aSize(aMotBx,1)
aDel(aMotBx,1)

//cria o temporário da FK7 ou gera uma query, ou sei lá
cqryAAA := CriaTempFK7(cTmpTbl, dDatDe, dDatAte)

// Query principal na Composição dos Itens da Guia
cQuery	+= " SELECT BD7_TIPGUI,BD7_DTDIGI,BI3_CODSEG,BI3_MODPAG,BI3_DTAPPR,"
cQuery	+= "        BI3_TIPCON,BD7_CODRDA,BD7_CODOPE,BD7_CODLDP,BD7_CODPEG,BD7_NUMERO,BD7_OPEUSR,BD7_CODEMP,BD7_MATRIC,BD7_TIPREG,"
cQuery	+= "        BD7_TPEVCT,BD7_DATPRO,  "
cQuery	+= "        BD7_CONEMP,"
cQuery	+= "        BD7_FASE,MIN(BD7.R_E_C_N_O_) AS BD7Recno, "
cQuery	+= "        MIN(BD6.R_E_C_N_O_) AS BD6Recno, "
cQuery	+= "        SUM(BD7_VLRMAN) AS BD7TVLRMAN, "

cQuery	+= "        SUM(BD7_VALORI) BD7TVLRAPR, "
cQuery	+= "        SUM(BD7_VLRPAG+BD7_VLRGLO) BD7TVLRY, "

cQuery	+= "        SUM(BD7_VLRPAG) AS BD7TVLRPAG, SUM(BD7_VLRGLO) AS BD7TVLRGLO, "
cQuery	+= "        SUM(BD7_VLINPT) AS BD7TVLINPT, SUM(BD7_VLTXPG) AS BD7TVLTXPG,"
cQuery	+= "        SUM(BD7_VLRGTX) AS BD7TVLRGTX, SUM(BD7_GLINPT) AS BD7TGLINPT,"
cQuery  += "        SUM(BD7_VLTXAP * BD6.BD6_QTDPRO) BD7TVTXAP, "
cQuery	+= "        SE2.R_E_C_N_O_ AS SE2Recno, " 
cQuery  += "        0 RECNOTFAT, "
cQuery  += "        FK7FK2.FK2_TPDOC, FK7FK2.FK2RECNO RECFK2 "

cQuery	+= " FROM ( " + cqryAAA + " )  FK7FK2 "
	
cQuery += " INNER JOIN " + PLSSQLNAME("SE2") + " SE2 "
cQuery += "    ON E2_FILIAL		= FK7FK2.A "
cQuery += "   AND E2_PREFIXO	= FK7FK2.B "
cQuery += "   AND E2_NUM		= FK7FK2.C "
cQuery += "   AND E2_PARCELA	= FK7FK2.D "
cQuery += "   AND E2_TIPO		= FK7FK2.E "
cQuery += "   AND E2_FORNECE	= FK7FK2.F "
cQuery += "   AND E2_LOJA		= FK7FK2.G "
cQuery += "   AND E2_TIPO NOT IN " + formatIn(MVABATIM+"|"+MVIRABT+"|"+MVINABT,"|")//AB-|FB-|FC-|FU-|IR-|IN-|IS-|PI-|CF-|CS-|FE-|IV-//IR-//IN- 
cQuery += "   AND SE2.D_E_L_E_T_ = ' ' "
		
//cQuery += " AND SE2.E2_NUM = '700151057' "
		
cQuery += " INNER JOIN " + PLSSQLNAME("BD7") + " BD7 "
cQuery += "    ON BD7_FILIAL = '" + xFilial("BD7") + "' "
cQuery += "   AND BD7_CHKSE2 = E2_FILIAL || '|' || E2_PREFIXO || '|' || E2_NUM || '|' || E2_PARCELA || '|' || E2_TIPO || '|' || E2_FORNECE || '|' || E2_LOJA "
cQuery += "   AND BD7_CODOPE = '" + MV_PAR03 + "' "

If MV_PAR04 <> MV_PAR05
	cQuery += "   AND BD7_CODEMP >= '" + MV_PAR04 + "' "
	cQuery += "   AND BD7_CODEMP <= '" + MV_PAR05 + "' "
else
	cQuery += "   AND BD7_CODEMP = '" + MV_PAR04 + "' "
endIf

cQuery += "   AND BD7_SITUAC <> '2' " // 1 - Ativo / 2 - Cancelado / 3 - Bloqueado
cQuery += "   AND BD7_CODLDP NOT IN( '" + PLSRETLDP(9) + "', '" + PLSRETLDP(4) + "'" + cCodLDPExc + " ) " //e99
cQuery += "   AND BD7_VLRPAG > 0  " 	// Não deve considerar item glosado 100%
cQuery += "   AND BD7_DTDIGI <= '"+DtoS(dDatAte)+"' "
cQuery += "   AND BD7.D_E_L_E_T_ = ' ' "
//cQuery += " AND BD7_CODLDP = '0001' AND BD7_CODPEG = '00438006' AND BD7_NUMERO = '00000001' "

If MV_PAR07 == 4
	cQuery	+= " AND BD7.BD7_CODRDA = '" + cRDASUS + "' "
else
	if !empty(MV_PAR08)
		cQuery	+= " AND BD7.BD7_CODRDA >= '" + MV_PAR08 + "' "
	endIf
	if !empty(MV_PAR09) .AND. UPPER(MV_PAR09) <>  "ZZZZZZ"
		cQuery	+= " AND BD7.BD7_CODRDA <= '" + MV_PAR09 + "' "
	endIf
EndIf

If MV_PAR07 == 2
	cQuery	+= "   AND BD7_TIPGUI <> '04' "
endIf

// Produto Saúde
cQuery	+= "INNER JOIN "+RetSqlName("BI3")+" BI3 "
cQuery	+= " ON BI3_FILIAL = '"+xFilial("BI3")+"' "
cQuery	+= "AND BI3_CODINT = BD7.BD7_CODOPE "
cQuery	+= "AND BI3_CODIGO = BD7.BD7_CODPLA "
cQuery	+= "AND BI3_VERSAO = '001' "
cQuery	+= "AND BI3.D_E_L_E_T_ = ' ' "

// Itens da Guia
cQuery	+= "INNER JOIN "+RetSqlName("BD6")+" BD6 "
cQuery	+= "ON BD6_FILIAL  = '"+xFilial('BD6')+"' "
cQuery	+= "AND BD6_CODOPE = BD7.BD7_CODOPE "
cQuery	+= "AND BD6_CODLDP = BD7.BD7_CODLDP "
cQuery	+= "AND BD6_CODPEG = BD7.BD7_CODPEG "
cQuery	+= "AND BD6_NUMERO = BD7.BD7_NUMERO "
cQuery	+= "AND BD6_ORIMOV = BD7.BD7_ORIMOV "
cQuery	+= "AND BD6_SEQUEN = BD7.BD7_SEQUEN "
cQuery	+= "AND BD6_CODPAD = BD7.BD7_CODPAD "
cQuery	+= "AND BD6_CODPRO = BD7.BD7_CODPRO "
cQuery	+= "AND BD6.D_E_L_E_T_ = ' ' "

cQuery	+= " INNER JOIN " + RetSqlName("BT5") + " BT5 "
cQuery	+= " ON BT5_FILIAL = BD6_FILIAL " 
cQuery	+= " AND BT5_CODINT = BD6_CODOPE "
cQuery	+= " AND BT5_CODIGO = BD6_CODEMP "
cQuery	+= " AND BT5_NUMCON = BD6_CONEMP "
cQuery	+= " AND BT5_VERSAO = BD6_VERCON "
cQuery	+= " AND BT5.D_E_L_E_T_ = ' ' "

If MV_PAR07 == 2
	cQuery	+= " AND BT5_INTERC = '1' "
else
	cQuery	+= " AND BT5_INTERC <> '1' "
endIf

////se for somente saúde ocupacional (mv_par07 = 3) vou economizar processamento já filtrando os BD5 aqui pra não precisar de skeep depois
// Cabeçalho das Guias
if MV_PAR07 == 3
	cQuery	+= " INNER JOIN "+RetSqlName("BD5")+" BD5 " 
	cQuery	+= "  ON BD5.BD5_FILIAL = '"+xFilial('BD5')+"' "
	cQuery	+= " AND BD5.BD5_CODOPE = BD7.BD7_CODOPE "
	cQuery	+= " AND BD5.BD5_CODLDP = BD7.BD7_CODLDP "
	cQuery	+= " AND BD5.BD5_CODPEG = BD7.BD7_CODPEG "
	cQuery	+= " AND BD5.BD5_NUMERO = BD7.BD7_NUMERO "
	cQuery += " AND BD5.BD5_TIPGUI = BD7.BD7_TIPGUI "
	cQuery	+= " AND BD5.D_E_L_E_T_ = ' ' "
	cQuery	+= " AND BD5_TIPATE >= '14' "
	cQuery	+= " AND BD5_TIPATE <= '21' "
else
	cQuery	+= " LEFT JOIN "+RetSqlName("BD5")+" BD5 " 
	cQuery	+= "  ON BD5.BD5_FILIAL = '"+xFilial('BD5')+"' "
	cQuery	+= " AND BD5.BD5_CODOPE = BD7.BD7_CODOPE "
	cQuery	+= " AND BD5.BD5_CODLDP = BD7.BD7_CODLDP "
	cQuery	+= " AND BD5.BD5_CODPEG = BD7.BD7_CODPEG "
	cQuery	+= " AND BD5.BD5_NUMERO = BD7.BD7_NUMERO "
	cQuery += " AND BD5.BD5_TIPGUI = BD7.BD7_TIPGUI "
	cQuery	+= " AND BD5.D_E_L_E_T_ = ' ' "
	cQuery	+= " AND BD5_TIPATE >= '14' "
	cQuery	+= " AND BD5_TIPATE <= '21' "
endif 

If MV_PAR07 == 5

	cQuery += " Inner Join " + retsqlName("BR8") + " BR8 "
	cQuery += " On "
	cQuery += " BR8_FILIAL = '" + xfilial("BR8") + "' "
	cQuery += " AND BR8_CODPAD = BD7.BD7_CODPAD "
	cQuery += " AND BR8_CODPSA = BD7.BD7_CODPRO "
	cQuery += " AND BR8_ODONTO = '1' "
	cquery += " AND BR8.D_E_L_E_T_ = ' ' "

endIf

cQuery += "   WHERE FK7FK2.FK2_DTDISP BETWEEN '" + dtos(dDatDe) + "' AND '" +  dtos(dDatAte) + "' "
//cQuery += "     AND ( FK7FK2.FK2_MOTBX IN " + formatIn(cMovBAN,"|")
cQuery += "     AND ( FK7FK2.FK2_MOTBX NOT IN ( 'FAT', 'LIQ', 'PCC' ) "
cQuery += "      OR (FK7FK2.FK2_MOTBX = 'CMP' AND FK7FK2.FK2_TPDOC = 'CP') "
cQuery += "      OR (FK7FK2.FK2_MOTBX = 'CEC') ) "
//cQuery += "     AND FK7FK2.FK2_RECPAG = 'P' "
/*
//retorna baixas que nao foram canceladas na competencia
cQuery += "     AND NOT EXISTS ( SELECT FK2EST.R_E_C_N_O_ "
cQuery += "                        FROM " + retSqlName("FKA") + " FKA_A "

cQuery += "                  INNER JOIN " + retSqlName("FKA") + " FKA_B "
cQuery += "                          ON FKA_B.FKA_FILIAL = '" + xFilial("FKA") + "' "
cQuery += "                         AND FKA_B.FKA_IDPROC = FKA_A.FKA_IDPROC "
cQuery += "                         AND FKA_B.D_E_L_E_T_ = ' ' "

cQuery += "                  INNER JOIN " + retSqlName("FK2") + " FK2EST "
cQuery += "                          ON FK2EST.FK2_FILIAL = '" + xFilial("FK2") + "' "
cQuery += "                         AND FK2EST.FK2_IDFK2  = FKA_B.FKA_IDORIG "
//cQuery += "                         AND FK2EST.FK2_DATA BETWEEN '" + dtos(dDatDe) + "' AND '" +  dtos(dDatAte) + "' "
cQuery += "                         AND FK2EST.FK2_RECPAG = 'R' "
cQuery += "                         AND FK2EST.D_E_L_E_T_ = ' ' "

cQuery += "                       WHERE FKA_A.FKA_FILIAL = '" + xFilial("FKA") + "' "
cQuery += "                         AND FKA_A.FKA_IDORIG = FK7FK2.FK2_IDFK2 "
cQuery += "                         AND FKA_A.D_E_L_E_T_ = ' ' ) "
*/
If MV_PAR07 <> 3
	cQuery += " AND BD5.BD5_CODPEG IS NULL "
endIf

cQuery += cWhere

cQuery	+= " GROUP BY SE2.R_E_C_N_O_,BD7_TIPGUI,BD7_DTDIGI,BI3_CODSEG,BI3_MODPAG,BI3_DTAPPR,BI3_TIPCON,BD7_CODRDA,"
cQuery	+= "          BD7_CODOPE,BD7_CODLDP,BD7_CODPEG,BD7_NUMERO,BD7_OPEUSR,BD7_CODEMP,BD7_CONEMP,BD7_MATRIC,BD7_TIPREG,BD7_FASE,FK2_TPDOC,FK7FK2.FK2RECNO,"
cQuery	+= "          BD7_TPEVCT,BD7_DATPRO"

//resultado de titulos negociados ou aglutinados em fatura.
cQuery += " UNION ALL "

cQuery	+= " SELECT BD7_TIPGUI,BD7_DTDIGI,BI3_CODSEG,BI3_MODPAG,BI3_DTAPPR,"
cQuery	+= "        BI3_TIPCON,BD7_CODRDA,BD7_CODOPE,BD7_CODLDP,BD7_CODPEG,BD7_NUMERO,BD7_OPEUSR,BD7_CODEMP,BD7_MATRIC,BD7_TIPREG,"
cQuery	+= "        BD7_TPEVCT,BD7_DATPRO,  "
cQuery	+= "        BD7_CONEMP,"
cQuery	+= "        BD7_FASE,MIN(BD7.R_E_C_N_O_) AS BD7Recno, "
cQuery	+= "        MIN(BD6.R_E_C_N_O_) AS BD6Recno, "
cQuery	+= "        SUM(BD7_VLRMAN) AS BD7TVLRMAN, "

cQuery	+= " SUM(BD7_VALORI) BD7TVLRAPR, "
cQuery	+= " SUM(BD7_VLRPAG+BD7_VLRGLO) BD7TVLRY, "

cQuery	+= " SUM(BD7_VLRPAG) AS BD7TVLRPAG, SUM(BD7_VLRGLO) AS BD7TVLRGLO, "
cQuery	+= " SUM(BD7_VLINPT) AS BD7TVLINPT, SUM(BD7_VLTXPG) AS BD7TVLTXPG,"
cQuery	+= " SUM(BD7_VLRGTX) AS BD7TVLRGTX, SUM(BD7_GLINPT) AS BD7TGLINPT,"
cQuery  += " SUM(BD7_VLTXAP * BD6.BD6_QTDPRO) BD7TVTXAP, "
cQuery	+= " SE2.R_E_C_N_O_ AS SE2Recno, " 

cQuery += " COALESCE(SE2ORI.R_E_C_N_O_, 0) RECNOTFAT, "
cQuery += " FK7FK2.FK2_TPDOC, FK7FK2.FK2RECNO RECFK2 "

cQuery	+= " FROM ( " + cqryAAA + " ) FK7FK2 "

cQuery += " INNER JOIN " + PLSSQLNAME("SE2") + " SE2 "
cQuery += "    ON SE2.E2_FILIAL		= FK7FK2.A "
cQuery += "   AND SE2.E2_PREFIXO	= FK7FK2.B "
cQuery += "   AND SE2.E2_NUM		= FK7FK2.C "
cQuery += "   AND SE2.E2_PARCELA	= FK7FK2.D "
cQuery += "   AND SE2.E2_TIPO		= FK7FK2.E "
cQuery += "   AND SE2.E2_FORNECE	= FK7FK2.F "
cQuery += "   AND SE2.E2_LOJA		= FK7FK2.G "
cQuery += "   AND SE2.E2_TIPO NOT IN " + formatIn(MVABATIM+"|"+MVIRABT+"|"+MVINABT,"|") //AB-|FB-|FC-|FU-|IR-|IN-|IS-|PI-|CF-|CS-|FE-|IV-//IR-//IN-
cQuery += "   AND SE2.D_E_L_E_T_ = ' ' "

//cQuery += " AND SE2.E2_NUM = '700151057' "

//titulos negociados ou aglutinados em fatura
cQuery += " INNER JOIN " + PLSSQLNAME("FI8") + " FI8 "
cQuery += "    ON FI8.FI8_FILIAL = FK7FK2.A "
cQuery += "   AND FI8.FI8_PRFDES = FK7FK2.B "
cQuery += "   AND FI8.FI8_NUMDES = FK7FK2.C "
cQuery += "   AND FI8.FI8_PARDES = FK7FK2.D "
cQuery += "   AND FI8.FI8_TIPDES = FK7FK2.E "
cQuery += "   AND FI8.FI8_FORDES = FK7FK2.F "
cQuery += "   AND FI8.FI8_LOJDES = FK7FK2.G "
cQuery += "   AND FI8.D_E_L_E_T_ = ' ' "

cQuery += " INNER JOIN " + PLSSQLNAME("BD7") + " BD7 "
cQuery += "    ON BD7_FILIAL = '" + xFilial("BD7") + "' "
cQuery += "   AND BD7_CHKSE2 = FI8_FILIAL || '|' || FI8_PRFORI || '|' || FI8_NUMORI || '|' || FI8_PARORI || '|' || FI8_TIPORI || '|' || FI8_FORORI || '|' || FI8_LOJORI "
cQuery += "   AND BD7_CODOPE   = '" + MV_PAR03 + "' "

If MV_PAR04 <> MV_PAR05
	cQuery += "   AND BD7_CODEMP >= '" + MV_PAR04 + "' "
	cQuery += "   AND BD7_CODEMP <= '" + MV_PAR05 + "' "
else
	cQuery += "   AND BD7_CODEMP = '" + MV_PAR04 + "' "
endIf

cQuery += "   AND BD7_SITUAC <> '2' " // 1 - Ativo / 2 - Cancelado / 3 - Bloqueado
cQuery += "   AND BD7_BLOPAG <> '1' "	// Pagamento liberado 
cQuery += "   AND BD7_CODLDP NOT IN( '" + PLSRETLDP(9) + "', '" + PLSRETLDP(4) + "'" + cCodLDPExc + " ) " //e99
cQuery += "   AND BD7_VLRPAG > 0  " 	// Não deve considerar item glosado 100%
cQuery += "   AND BD7_DTDIGI <= '" + DtoS(dDatAte) + "' "
cQuery += "   AND BD7.D_E_L_E_T_ = ' ' "
//cQuery += " AND BD7_CODLDP = '0001' AND BD7_CODPEG = '00438006' AND BD7_NUMERO = '00000001' "

If MV_PAR07 == 4
	cQuery	+= " AND BD7.BD7_CODRDA = '" + cRDASUS + "' "
else
	if !empty(MV_PAR08)
		cQuery	+= " AND BD7.BD7_CODRDA >= '" + MV_PAR08 + "' "
	endIf
	if !empty(MV_PAR09) .AND. UPPER(MV_PAR09) <>  "ZZZZZZ"
		cQuery	+= " AND BD7.BD7_CODRDA <= '" + MV_PAR09 + "' "
	endIf
EndIf

If MV_PAR07 == 2
	cQuery	+= "   AND BD7_TIPGUI <> '04' "
endIf

// Itens da Guia
cQuery	+= "INNER JOIN "+RetSqlName("BD6")+" BD6 "
cQuery	+= "   ON BD6.BD6_FILIAL = '"+xFilial('BD6')+"' "
cQuery	+= "  AND BD6.BD6_CODOPE = BD7.BD7_CODOPE "
cQuery	+= "  AND BD6.BD6_CODLDP = BD7.BD7_CODLDP "
cQuery	+= "  AND BD6.BD6_CODPEG = BD7.BD7_CODPEG "
cQuery	+= "  AND BD6.BD6_NUMERO = BD7.BD7_NUMERO "
cQuery	+= "  AND BD6.BD6_ORIMOV = BD7.BD7_ORIMOV "
cQuery	+= "  AND BD6.BD6_SEQUEN = BD7.BD7_SEQUEN "
cQuery	+= "  AND BD6.BD6_CODPAD = BD7.BD7_CODPAD "
cQuery	+= "  AND BD6.BD6_CODPRO = BD7.BD7_CODPRO "
cQuery	+= "  AND BD6.D_E_L_E_T_ = ' ' "
  
cQuery	+= " INNER JOIN " + RetSqlName("BT5") + " BT5 "
cQuery	+= "    ON BT5.BT5_FILIAL = BD6.BD6_FILIAL " 
cQuery	+= "   AND BT5.BT5_CODINT = BD6.BD6_CODOPE "
cQuery	+= "   AND BT5.BT5_CODIGO = BD6.BD6_CODEMP "
cQuery	+= "   AND BT5.BT5_NUMCON = BD6.BD6_CONEMP "
cQuery	+= "   AND BT5.BT5_VERSAO = BD6.BD6_VERCON "
cQuery	+= "   AND BT5.D_E_L_E_T_ = ' ' "

If MV_PAR07 == 2
	cQuery	+= " AND BT5.BT5_INTERC = '1' "
elseif MV_PAR07 == 1
	cQuery	+= " AND BT5.BT5_INTERC <> '1' "
endIf

//se for somente saúde ocupacional (mv_par07 = 3) vou economizar processamento já filtrando os BD5 aqui pra não precisar de skeep depois
// Cabeçalho das Guias

if MV_PAR07 == 3
	cQuery	+= " INNER JOIN "+RetSqlName("BD5")+" BD5 " 
	cQuery	+= "  ON BD5.BD5_FILIAL = '"+xFilial('BD5')+"' "
	cQuery	+= " AND BD5.BD5_CODOPE = BD7.BD7_CODOPE "
	cQuery	+= " AND BD5.BD5_CODLDP = BD7.BD7_CODLDP "
	cQuery	+= " AND BD5.BD5_CODPEG = BD7.BD7_CODPEG "
	cQuery	+= " AND BD5.BD5_NUMERO = BD7.BD7_NUMERO "
	cQuery += " AND BD5.BD5_TIPGUI = BD7.BD7_TIPGUI "
	cQuery	+= " AND BD5.D_E_L_E_T_ = ' ' "
	cQuery	+= " AND BD5.BD5_TIPATE >= '14' "
	cQuery	+= " AND BD5_TIPATE <= '21' "
else
	cQuery	+= " LEFT JOIN "+RetSqlName("BD5")+" BD5 " 
	cQuery	+= "  ON BD5.BD5_FILIAL = '"+xFilial('BD5')+"' "
	cQuery	+= " AND BD5.BD5_CODOPE = BD7.BD7_CODOPE "
	cQuery	+= " AND BD5.BD5_CODLDP = BD7.BD7_CODLDP "
	cQuery	+= " AND BD5.BD5_CODPEG = BD7.BD7_CODPEG "
	cQuery	+= " AND BD5.BD5_NUMERO = BD7.BD7_NUMERO "
	cQuery += " AND BD5.BD5_TIPGUI = BD7.BD7_TIPGUI "
	cQuery	+= " AND BD5.D_E_L_E_T_ = ' ' "
	cQuery	+= " AND BD5.BD5_TIPATE >= '14' "
	cQuery	+= " AND BD5.BD5_TIPATE <= '21' "
endif 

// Produto Saúde
cQuery	+= "LEFT JOIN "+RetSqlName("BI3")+" BI3 "
cQuery	+= " ON BI3.BI3_FILIAL = '" + xFilial("BI3") + "' "
cQuery	+= "AND BI3.BI3_CODINT = BD7.BD7_CODOPE "
cQuery	+= "AND BI3.BI3_CODIGO = BD6.BD6_CODPLA "
cQuery	+= "AND BI3.BI3_VERSAO = '001' "
cQuery	+= "AND BI3.D_E_L_E_T_ = ' ' "

cQuery += " LEFT JOIN " + retSqlName("SE2") + " SE2ORI "
cquery += "   ON SE2ORI.E2_FILIAL  = SE2.E2_FILIAL "
cQuery += "  AND SE2ORI.E2_PREFIXO = FI8.FI8_PRFORI  "
cQuery += "  AND SE2ORI.E2_NUM     = FI8.FI8_NUMORI "
cQuery += "  AND SE2ORI.E2_PARCELA = FI8.FI8_PARORI"
cQuery += "  AND SE2ORI.E2_TIPO    = FI8.FI8_TIPORI"
cQuery += "  AND SE2ORI.E2_FORNECE = FI8.FI8_FORORI"
cQuery += "  AND SE2ORI.E2_LOJA    = FI8.FI8_LOJORI"
cQuery += "  AND SE2.E2_FATURA = '" + "NOTFAT" + Space(TamSX3("E2_FATURA")[1] - 6) + "' "
cQuery += "  AND SE2ORI.D_E_L_E_T_ = ' ' "

If MV_PAR07 == 5

	cQuery += " Inner Join " + retsqlName("BR8") + " BR8 "
	cQuery += " On "
	cQuery += " BR8_FILIAL = '" + xfilial("BR8") + "' "
	cQuery += " AND BR8_CODPAD = BD7.BD7_CODPAD "
	cQuery += " AND BR8_CODPSA = BD7.BD7_CODPRO "
	cQuery += " AND BR8_ODONTO = '1' "
	cquery += " AND BR8.D_E_L_E_T_ = ' ' "

endIf

cQuery += "   WHERE FK7FK2.FK2_DTDISP BETWEEN '" + dtos(dDatDe) + "' AND '" +  dtos(dDatAte) + "' "
//cQuery += "     AND ( FK7FK2.FK2_MOTBX IN " + formatIn(cMovBAN,"|")
cQuery += "     AND ( FK7FK2.FK2_MOTBX NOT IN ( 'FAT', 'LIQ', 'PCC' ) "
cQuery += "      OR (FK7FK2.FK2_MOTBX = 'CMP' AND FK7FK2.FK2_TPDOC = 'CP') "
cQuery += "      OR (FK7FK2.FK2_MOTBX = 'CEC') ) "
//cQuery += "     AND FK7FK2.FK2_RECPAG = 'P' "
/*
//retorna baixas que nao foram canceladas na competencia
cQuery += "     AND NOT EXISTS ( SELECT FK2EST.R_E_C_N_O_ "
cQuery += "                        FROM " + retSqlName("FKA") + " FKA_A "

cQuery += "                  INNER JOIN " + retSqlName("FKA") + " FKA_B "
cQuery += "                          ON FKA_B.FKA_FILIAL = '" + xFilial("FKA") + "' "
cQuery += "                         AND FKA_B.FKA_IDPROC = FKA_A.FKA_IDPROC "
cQuery += "                         AND FKA_B.D_E_L_E_T_ = ' ' "

cQuery += "                  INNER JOIN " + retSqlName("FK2") + " FK2EST "
cQuery += "                          ON FK2EST.FK2_FILIAL = '" + xFilial("FK2") + "' "
cQuery += "                         AND FK2EST.FK2_IDFK2  = FKA_B.FKA_IDORIG "
//cQuery += "                         AND FK2EST.FK2_DATA BETWEEN '" + dtos(dDatDe) + "' AND '" +  dtos(dDatAte) + "' "
cQuery += "                         AND FK2EST.FK2_RECPAG = 'R' "
cQuery += "                         AND FK2EST.D_E_L_E_T_ = ' ' "

cQuery += "                       WHERE FKA_A.FKA_FILIAL = '" + xFilial("FKA") + "' "
cQuery += "                         AND FKA_A.FKA_IDORIG = FK7FK2.FK2_IDFK2 "
cQuery += "                         AND FKA_A.D_E_L_E_T_ = ' ' ) "
*/
If MV_PAR07 <> 3
	cQuery += " AND BD5.BD5_CODPEG IS NULL "
endIf

cQuery += cWhere

cQuery	+= " GROUP BY SE2.R_E_C_N_O_,BD7_TIPGUI,BD7_DTDIGI,BI3_CODSEG,BI3_MODPAG,BI3_DTAPPR,BI3_TIPCON,BD7_CODRDA,"
cQuery	+= "          BD7_CODOPE,BD7_CODLDP,BD7_CODPEG,BD7_NUMERO,BD7_OPEUSR,BD7_CODEMP,BD7_CONEMP,BD7_MATRIC,BD7_TIPREG,BD7_FASE,SE2ORI.R_E_C_N_O_,FK2_TPDOC,FK7FK2.FK2RECNO,"
cQuery	+= "          BD7_TPEVCT,BD7_DATPRO"
cQuery  += " ORDER BY SE2RECNO, RECFK2 , RECNOTFAT, BD7_TIPGUI, BD7_DTDIGI, BI3_CODSEG, BI3_MODPAG, BI3_DTAPPR, BI3_TIPCON, BD7_CODRDA, BD7_CODOPE, BD7_CODLDP,"
cQuery  += "          BD7_CODPEG, BD7_NUMERO, BD7_OPEUSR, BD7_CODEMP, BD7_CONEMP, BD7_MATRIC, BD7_TIPREG,"
cQuery  += "          BD7_TPEVCT, BD7_DATPRO "

If Existblock("PLR44XP3")
	cQuery := ExecBlock("PLR44XP3",.f.,.f.,{ '443'+aTipRel[MV_PAR07], cQuery } ) 
EndIf

MPSysOpenQuery( changeQuery(cQuery), 'TRBLIV' )

aStruSQL := TRBLIV->( dbStruct() )

for nX := 1 to len(aStruSQL)

	if aStruSQL[nX][2] <> "C"
		tcSetField('TRBLIV' ,aStruSQL[nX][1],aStruSQL[nX][2],aStruSQL[nX][3],aStruSQL[nX][4])
	endIf
	
next nX

// Elimina array
aSize(aTipRel,1)
aDel(aTipRel,1)

return( {.f.} )


/*/{Protheus.doc} VerifBloq
VerifBloq

@author DEV
@since 05/03/2016
@version ALL
/*/
static function VerifBloq(cMatricula,cTipoReg,dFim)
local cBCAName 	:= retSQLName("BCA") 
local cQuery 	:= ""
local lBlqAns	:= .f. 
local dDatBlo	:= stod("")

//Verifica se o usuario esta bloqueado.
cQuery  := " SELECT BCA_TIPO, BCA_DATA, BCA_MOTBLO, BCA_NIVBLQ FROM " + cBCAName
cQuery  += " WHERE BCA_FILIAL = '"+xFilial("BCA")+"' AND BCA_MATRIC = '" + cMatricula + "' AND"
cQuery  += " BCA_TIPREG = '" + cTipoReg + "' AND"
cQuery  += " BCA_DATA <= '" + dtos(dFim) + "' AND "
cQuery  += cBCAName + ".D_E_L_E_T_ = ' ' "
cQuery  += " ORDER BY BCA_DATA, R_E_C_N_O_"

cQuery 	:= 	ChangeQuery (cQuery)

dbUseArea (.T., "TOPCONN", TcGenQry (,,cQuery), "BCAQRY", .T., .T.)

while ! BCAQRY->(eof())

	lBlqAns := .F.

	do case
		case BCAQRY->BCA_NIVBLQ == 'U' //Nivel de Usuario
			if BG3->(msSeek(xFilial("BG3")+BCAQRY->BCA_MOTBLO))
				if ! empty(BG3->BG3_BLQANS)
					lBlqAns := .T.
				endIf
			endIf
		case BCAQRY->BCA_NIVBLQ == 'F' //Nivel de Familia
			if BG1->(msSeek(xFilial("BG1")+BCAQRY->BCA_MOTBLO))
				if ! empty(BG1->BG1_BLQANS)
					lBlqAns := .T.
				endIf
			endIf
		case BCAQRY->BCA_NIVBLQ == 'S' //Nivel de Sub-Contrato
			if BQU->(msSeek(xFilial("BQU")+BCAQRY->BCA_MOTBLO))
				if ! empty(BQU->BQU_BLQANS)
					lBlqAns := .T.
				endIf
			endIf
	endcase

	if lBlqAns .and. BCAQRY->BCA_TIPO == "0" //Bloqueio
		dDatBlo := Stod(BCAQRY->BCA_DATA)
	else
		dDatBlo := stod("        ")
	endIf

	BCAQRY->(dbSkip())
endDo

BCAQRY->(dbCloseArea())

return dDatBlo

/*/{Protheus.doc} fposTAux 

@author  PLS TEAM
@version P12
@since   15.11.05
/*/
static function fposTAux()
local aArea := getArea()

if BAU->(BAU_FILIAL+BAU_CODIGO) <> xFilial("BAU") + BD7->BD7_CODRDA
    BAU->( msSeek( xFilial("BAU") + BD7->BD7_CODRDA ) )
endIf

//Posiciona BA1 - Usuarios                                            
if BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG) <> xFilial("BA1") + BD7->( BD7_OPEUSR + BD7_CODEMP + BD7_MATRIC + BD7_TIPREG  )
    BA1->( msSeek( xFilial("BA1") + BD7->( BD7_OPEUSR + BD7_CODEMP + BD7_MATRIC + BD7_TIPREG ),.F. ) )
endIf

//Posiciona BA3 - Familias                                            
if BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB) <> xFilial("BA3") + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)

    if BA3->( msSeek( xFilial("BA3") + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))

		//Posiciona BG9 - Grupo/Empresa                                       
        if BG9->(BG9_FILIAL+BG9_CODINT+BG9_CODIGO+BG9_TIPO) <> xFilial("BG9") + BA3->(BA3_CODINT+BA3_CODEMP+BA3_TIPOUS)
            BG9->(msSeek(xFilial("BG9") + BA3->(BA3_CODINT+BA3_CODEMP+BA3_TIPOUS)))
        endIf
		
		//Posiciona BT5 - Contrato                                            
        if BT5->(BT5_FILIAL+BT5_CODINT+BT5_CODIGO+BT5_NUMCON+BT5_VERSAO) <> xFilial("BT5") + BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON)
            BT5->(msSeek(xFilial("BT5") + BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON)))
        endIf
        
    endIf
    
endIf

// Posiciona BI3-Produto Saude                                     
If BI3->(BI3_FILIAL+BI3_CODINT+BI3_CODIGO) <> xFilial("BI3") + BD7->BD7_OPEUSR + BD6->BD6_CODPLA
    BI3->( msSeek( xFilial("BI3") + BD7->BD7_OPEUSR + BD6->BD6_CODPLA ) )
endIf

//Segmentação
if BI6->(BI6_FILIAL+BI6->BI6_CODSEG) <> xFilial("BI6") + BI3->BI3_CODSEG
	BI6->( msSeek( xfilial('BI6') + BI3->BI3_CODSEG ) )
endIf	

//Tipos de Contratos
if BII->(BII_FILIAL+BII_CODIGO) <> xFilial("BII") + BI3->BI3_TIPCON
	BII->( msSeek( xFilial("BII") + BI3->BI3_TIPCON ) )
endIf	
	
//posiciona tabela padrao
If BR8->(BR8_FILIAL+BR8_CODPAD+BR8_CODPSA) <> xFilial("BR8") + BD7->(BD7_CODPAD+BD7_CODPRO)
	BR8->( msSeek( xFilial("BR8") + BD7->(BD7_CODPAD+BD7_CODPRO)) )
endIf	
//Versões dos Contratos
if BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON) <> xFilial("BQB") + BQB->(BQB_CODINT+BQB_CDEMP+BQB_NUMCON+BQB_VERSAO)
	BQB->( msSeek( xFilial('BQB') + BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON) ) )
endIf	

restarea(aArea)

return 


/* funcao para criacao de uma tabela temporária em tempo de execução para contornar problema de travamento na MPSysOpenQuery */
Static function CriaTempFK7(cTmpTbl, dDatDe, dDatAte)
Local cSubStr		:= iIf( "SQL" $ allTrim( TCGetDB() ) ,'SUBSTRING',  'SUBSTR' )
Local csqlZ			:= ""			
Local nTamZTot 		:= 0
Local nTamZCmp 		:= 0
Local nZPosIniAnt	:= 0 
local lBaixaDisp := ( FK2->(FieldPos("FK2_DTDISP")) > 0 ) .AND. lMVDisp

csqlZ 		:= " SELECT FK7_IDDOC, "
nTamZTot 	:= 0
nTamZCmp 	:= tamSX3("E2_FILIAL")[1]

cSqlZ 		+= " " + cSubStr + "(FK7_CHAVE,1," + Str(nTamZCmp) + " )  A,   "
nZPosIniAnt := 1
nTamZTot 	+= nTamZCmp

csqlZ		+= " " + cSubStr + "(FK7_CHAVE," + Str(nZPosIniAnt + nTamZCmp + 1) + "," 
nZPosIniAnt := nZPosIniAnt + nTamZCmp + 1
nTamZCmp 	:= tamSX3("E2_PREFIXO")[1]
cSqlZ 		+= " " + Str(nTamZCmp) + "  ) B, "
nTamZTot 	+= nTamZCmp
			
csqlZ 		+= " " + cSubStr + "(FK7_CHAVE," + Str(nZPosIniAnt + nTamZCmp + 1) + "," 
nZPosIniAnt := nZPosIniAnt + nTamZCmp + 1
nTamZCmp 	:= tamSX3("E2_NUM")[1]
cSqlZ		+= " "+ Str(nTamZCmp) + "  )  C,  
nTamZTot 	+= nTamZCmp

csqlZ 		+= " " + cSubStr + "(FK7_CHAVE," + Str(nZPosIniAnt + nTamZCmp + 1) + "," 
nZPosIniAnt := nZPosIniAnt + nTamZCmp + 1
nTamZCmp 	:= tamSX3("E2_PARCELA")[1]			
cSqlZ 		+= " "+ Str(nTamZCmp) + "  )  D,  
nTamZTot 	+= nTamZCmp

csqlZ 		+= " " + cSubStr + "(FK7_CHAVE," + Str(nZPosIniAnt + nTamZCmp + 1) + "," 
nZPosIniAnt := nZPosIniAnt + nTamZCmp + 1
nTamZCmp 	:= tamSX3("E2_TIPO")[1]			
cSqlZ 		+= " "+ Str(nTamZCmp) + "  )  E,  
nTamZTot 	+= nTamZCmp			

csqlZ 		+= " " + cSubStr + "(FK7_CHAVE," + Str(nZPosIniAnt + nTamZCmp + 1) + "," 
nZPosIniAnt := nZPosIniAnt + nTamZCmp + 1
nTamZCmp 	:= tamSX3("E2_FORNECE")[1]			
cSqlZ 		+= " "+ Str(nTamZCmp) + "  )  F,  
nTamZTot 	+= nTamZCmp			

csqlZ 		+= " " + cSubStr + "(FK7_CHAVE," + Str(nZPosIniAnt + nTamZCmp + 1) + "," 
nZPosIniAnt := nZPosIniAnt + nTamZCmp + 1
nTamZCmp 	:= tamSX3("E2_LOJA")[1]			
cSqlZ 		+= " "+ Str(nTamZCmp) + "  )  G, 
nTamZTot 	+= nTamZCmp	

If lBaixaDisp
	cSqlZ += " FK2.FK2_DTDISP FK2_DTDISP, "
Else
	cSqlZ += " FK2.FK2_DATA FK2_DTDISP, "
EndIf
cSqlZ += " FK2.FK2_RECPAG FK2_RECPAG, "
cSqlZ += " FK2.FK2_IDFK2 FK2_IDFK2, "
cSqlZ += " FK2.FK2_MOTBX FK2_MOTBX, "
cSqlZ += " FK2.FK2_TPDOC FK2_TPDOC, "
cSqlZ += " FK2.R_E_C_N_O_ FK2RECNO "
cSqlZ += " FROM " + RetsqlName("FK7") + " FK7 "

cSqlZ += " INNER JOIN " + RetSqlName("FK2") + " FK2 "
cSqlZ += "   ON FK2.FK2_FILIAL = '" + xfilial("FK2") + "' "
cSqlZ += "  AND FK2.FK2_IDDOC = FK7_IDDOC "
cSqlZ += "  AND FK2.D_E_L_E_T_ = ' ' "

cSqlZ += " WHERE FK7.FK7_FILIAL = '" + xfilial("FK7") + "' "
cSqlZ += "   AND FK7.FK7_ALIAS = 'SE2' "
cSqlZ += "   AND FK7.D_E_L_E_T_ = ' ' "
If lBaixaDisp
	cSqlZ += "   AND FK2.FK2_DTDISP BETWEEN '" + dtos(dDatDe) + "' AND '" +  dtos(dDatAte) + "' "
Else
	cSqlZ += "   AND FK2.FK2_DATA BETWEEN '" + dtos(dDatDe) + "' AND '" +  dtos(dDatAte) + "' "
EndIf
cSqlZ += "   AND FK2.FK2_MOTBX <> 'FAT' "
/*
cSqlZ := ChangeQuery(cSqlz)

TcSqlEXEC("DROP VIEW "+cTmpTbl)

if lOracle
	TcSqlEXEC("COMMIT") 
endif

nRet := TcSqlEXEC(" CREATE VIEW "+cTmpTbl+" AS " + cSqlZ) //SELECT * FROM " + oTmpTable:getrealName() )

if nRet >= 0
	
	if lOracle
		TcSqlEXEC("COMMIT") 
	endif

endif
*/
Return cSqlZ


static function Upsidedown(nValor)

local nRet := 0

//if nValor - noround(nValor, 2) <= 0.005						
if .F. //nValor - noround(nValor, 2) <= 0.005
	nret := noround(nValor, 2) 
else
	nRet := nValor
EndIf

return nRet

static function fnChvCTB(cCodOpe, ccodLdp, cCodPEG, cNumero, cSequen)
Local cRet := ""
Local cSql := ""

cSql += " Select BD7_CHVLA, BD7_CHVPRO from " + retsqlName("BD7")
cSql += " where "
cSql += " BD7_FILIAL = '" + xfilial("BD7") + "' "
cSql += " AND BD7_CODOPE = '" + cCodOpe + "' "
cSql += " AND BD7_CODLDP = '" + ccodLdp + "' "
cSql += " AND BD7_CODPEG = '" + cCodPEG + "' "
cSql += " AND BD7_NUMERO = '" + cNumero + "' "
//cSql += " AND BD7_SEQUEN = '" + cSequen + "' "
cSql += " AND (BD7_CHVLA <> ' ' OR BD7_CHVPRO <> ' ')
cSql += " AND D_E_L_E_T_ = ' ' "

dbUseArea (.T., "TOPCONN", TcGenQry (,,cSql), "CHVCTB", .T., .T.)

If !(CHVCTB->(EoF()))
	cRet := iIf( empty(CHVCTB->BD7_CHVLA), CHVCTB->BD7_CHVPRO, CHVCTB->BD7_CHVLA )
endIf

CHVCTB->(dbclosearea())
return cRet


static function DescSF1()
Local nRet := 0
Local cSql := ""

cSql += " Select F1_DESCONT DESCONTO From " + RetsqlName("SF1") + " SF1 "
cSql += " where "
cSql += " F1_FILIAL = '" + xfilial("SF1") + "' "
cSql += " AND F1_FORNECE = '" + SE2->E2_FORNECE + "' "
cSql += " AND F1_LOJA = '" + SE2->E2_LOJA + "' "
cSql += " AND F1_DOC = '" + SE2->E2_NUM + "' "
cSql += " AND F1_PREFIXO = '" + SE2->E2_PREFIXO + "' "
cSql += " AND D_E_L_E_T_ = ' ' "

dbUseArea (.T., "TOPCONN", TcGenQry (,,cSql), "PDESCF1", .T., .T.)

If !(PDESCF1->(EoF()))
	nRet := PDESCF1->DESCONTO
endIf

PDESCF1->(dbclosearea())

return nRet


static function SumBD7PG(cChkSE2)
Local nRet := 0
Local cSql := ""

cSql += " Select SUM(BD7_VLRPAG) TOTPAG From " + RetSqlName("BD7") + " BD7 "
cSql += " Where "
cSql += " BD7_FILIAL = '" + xFilial("BD7") + "' "
cSql += " AND BD7_CHKSE2 = '" + cChkSE2 + "' "
cSql += " AND D_E_L_E_T_ = ' ' "

dbUseArea (.T., "TOPCONN", TcGenQry (,,cSql), "PBD7PG", .T., .T.)

If !(PBD7PG->(EoF()))
	nRet := PBD7PG->TOTPAG
endIf

PBD7PG->(dbclosearea())

return nRet
