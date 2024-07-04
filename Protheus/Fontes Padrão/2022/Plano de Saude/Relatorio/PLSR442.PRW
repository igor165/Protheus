#INCLUDE "PLSR442.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"

#define lLinux IsSrvUnix()
#IFDEF lLinux
    #define CRLF Chr(13) + Chr(10)
#ELSE
    #define CRLF Chr(10)
#ENDIF

#define REEMBOLSO   "04"

static ADLei := ctod('31/12/1999')
static nSomRee := GetNewPar("MV_PLDRE44", 0)
static cSqlbca := RetSQLName("BCA")
static cSqlfk2 := retSqlName("FK2")
static cSqlfk7 := RetsqlName("FK7")
Static lMvDisp := GetNewPar("MV_PLR4XDS", "0") == "0"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSR442
Registro de Eventos a Liquidar

@author DEV
@since 05/03/2016
@version ALL
Remodelado em 2016/10/25 para atendimento a RN 390
/*/
//--------------------------------------------------------------------------------------------------
function PLSR442()
local cPerg	  		:= "PLR442"
private oReport     := nil

Pergunte(cPerg,.t.)

if findFunction("TRepInUse") .And. TRepInUse()

    oReport := reportDef(cPerg)
            
    oReport:printDialog()
    
    freeObj(oReport)
else
    msgAlert(STR0041)
endIf

return

static function reportDef(cPerg)
private oReport       := nil
Private cTexto		:= STR0002 //"Registro de Eventos a Liquidar"
private oSTITULO		:= nil
oReport := TReport():new("PLSR442",cTexto,cPerg,{|oReport| ReportPrint(oReport)},cTexto) 
oReport:setTotalInLine(.f.)
oReport:setLandscape()

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
TRCell():new(oSTITULO,"VLINSS"	,"TRBLIV", STR0079, "@E 9,999,999,999.99999", 18)//"Vlr INSS"
TRCell():new(oSTITULO,"VLISS"	,"TRBLIV", STR0081, "@E 9,999,999,999.99999", 18)//"Vlr ISS"
TRCell():new(oSTITULO,"VLIRRF"	,"TRBLIV", STR0080, "@E 9,999,999,999.99999", 18)//"Vlr IRRF"
TRCell():new(oSTITULO,"VLDESC"	,"TRBLIV", STR0082, "@E 9,999,999,999.99999", 18)//"Vlr Desc"    
TRCell():new(oSTITULO,"VLLIQR"	,"TRBLIV", "Vlr.Líq.de Ret.", "@E 9,999,999,999.99999", 18)//""
TRCell():new(oSTITULO,"TITULO"	,"TRBLIV", STR0005, "@R XXXX-999999999-999-XXX", 22)//"Titulo"
TRCell():new(oSTITULO,"TIPEVE"	,"TRBLIV", STR0060, "@!", 30)//"Tp Evento"       
TRCell():new(oSTITULO,"DTVENC"	,"TRBLIV", STR0008, PesqPict("SE1","E1_VENCREA") , 10)//"Vencto"
TRCell():new(oSTITULO,"DTGER"	,"TRBLIV", STR0083, PesqPict("SE1","E1_EMISSAO"), 10)//"Dt Ger"

Return(oReport)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Impressao

@author DEV
@since 05/03/2016
@version ALL
/*/
//--------------------------------------------------------------------------------------------------
static function ReportPrint(oReport)
local cTipFat		:= ""
local cMesAno		:= ""
local cSeMpADl		:= ""
local cModPag 		:= ""
local cADLei  		:= "" 
local cTipCon 		:= ""
local cCodSeg		:= ""
local cDescSeg		:= ""
local cNumCon		:= ""
local cLastBD7		:= ""
local dIniCon		:= stod("")
local dTerCon		:= stod("")
local dDatAte		:= MV_PAR01		
local aLog 	   		:= {}
local aStru			:= {}
local aRet			:= {}
local cPlsCDIE		:= getNewPar("MV_PLSCDIE","1")
local aPadProd		:= {}
local aBauVenc		:= {}
local cLastUser		:= ''	// Grava chave do último usuário processado
local cLastRDA		:= ''	// Grava código do último RDA processado 
local cLastProd		:= ''	// Grava código do último Produto (BI3)
local cAliasCAB 	:= ''
local cChaveCAB 	:= ''
local cChaveBD7		:= ''
local cTipDoc		:= ''
local dDtVenc		:= ctod('')
local lCT2Ativo		:= .f.
local lEnd			:= .f.
local nLastBD7		:= 0 
local nTotReg		:= 0
local cPlTpRec	 	:= getNewPar("MV_PLTPREC","016")
local cRDASUS	 	:= getNewPar("MV_RDASUS","SUS")
Local cLastFam		:= ''
Local cNomTit		:= ''
Local cCpfTit		:= ''
Local cMatTit		:= ''
Local lReemb		:= .F.
Local nPosBA1		:= 0
Local cTpEvCt		:= '' 
Local nPosSE2		:= 0
Local nAcuIRRF		:= 0
Local nAcuISS		:= 0
Local nAcuINSS		:= 0
Local cLastCon		:= ''
Local nAcuDesc		:= 0
Local lSaldoSE2		:= .F.
Local nLimFat		:= 0 //GetNewPar("MV_PLREGAX",0.0000004)
Local cSauOcu       := AllTrim(SuperGetMv("MV_SAUOCU",.F.,"14|15|16|17|18|19|20|21"))
Local cBCIDtDigi	:= ""
Local aEmpSauOcu    := {}
Local lLoop         := .F.
Local nPosEmp       := 0
Local lNCLAS		:= GetNewPar("MV_PLNCLAS", .T.)
Local cInterc   	:= GetNewPar("MV_PLSGEIN","0050") 
LOCAL lUnimeds    	:= IF(AllTrim(GETNEWPAR("MV_PLSUNI","1"))=="1",.T.,.F.)
Local lEndIsNear	:= .F.
Local nEINPosatu	:= 0
Local nEIN			:= 0
Local aEndIsNear	:= {}
Local nSaldo	:= 0
Local nAcuDescx	:= 0
Local nValDescx	:= 0
Local nFator2		:= 1
Local nAcuperc2	:= 0
Local nAcuNeg		:= 0
Local nValZX		:= 0
Local dDatProCab	:= cToD("")
Local aProduto 		:= {}
local dDatDe		:= ctod('01/01/1990')
local dDatRef       := MV_PAR01
local aTpForn       := retSx3Box(X3CBox(Posicione('SX3' , 2 ,"BI3_TPFORN",'X3_CBOX')    ),,,1)
local aModPag       := retSx3Box(X3CBox(Posicione('SX3' , 2 ,"BI3_MODPAG",'X3_CBOX')    ),,,1)
Local cTitle		:=""
Local nDescCom	:= 0
Local nTotBD7PG := 0 
Local nFator := 0
Local lRecZero := .F.
Local nPerAglu := 0
Local aareaAglu := {}
Local lTemAglu := .F.
Local ctitAglu := ""
local oSTITULO := oReport:section(1)

if Empty(MV_PAR01)
	msgAlert("Os parametros do relatório não foram preenchidos")
	return()
endIf

Do Case
	Case MV_PAR06 == 1
		cTitle	+= ' - ' + "Operadora" 	
	Case MV_PAR06 == 2
		cTitle	+= ' - ' + "Corresponsabilidade Assumida" 	
	Case MV_PAR06 == 3
		cTitle	+= ' - ' + "Não Rel.Plano Med.Hospitalar"  	
	Case MV_PAR06 == 4
		cTitle	+= ' - ' + "Ressarcimento ao SUS"  	
	Case MV_PAR06 == 5
		cTitle	+= ' - ' + "Não Rel.Serviço Odontológico"  	
EndCase

if existblock("PLCSAUOC")
    aEmpSauOcu := execBlock("PLCSAUOC",.F.,.F.,{})
endIf

aRet := getTrbQuery(dDatDe,dDatRef,@lEnd,@nTotReg)

if aRet[1]
    return()
endIf

oReport:onPageBreak({|| oReport:setTitle(cTitle),.T.} ) //"Registro de Eventos a Liquidar"

// Prepara Indices para utilização no loop e subfunções
BAU->(dbSetOrder(1)) //BAU_FILIAL+BAU_CODIGO
BA1->(dbSetOrder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
BA3->(dbSetOrder(1)) //BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB
BG9->(dbSetOrder(1)) //BG9_FILIAL+BG9_CODINT+BG9_CODIGO+BG9_TIPO
BT5->(dbSetOrder(1)) //BT5_FILIAL+BT5_CODINT+BT5_CODIGO+BT5_NUMCON+BT5_VERSAO
BOW->(dbSetOrder(1)) //BOW_FILIAL+BOW_PROTOC
BQB->(dbSetOrder(2)) //BQB_FILIAL+BQB_CODINT+BQB_CDEMP+BQB_NUMCON+BQB_VERSAO+DTOS(BQB_DATINI)
SX5->(dbSetOrder(1)) //X5_FILIAL+X5_TABELA+X5_CHAVE
CV3->(dbSetOrder(3)) //CV3_FILIAL+CV3_RECORI
B45->(dbSetOrder(1)) //B45_FILIAL+B45_OPEMOV+B45_ANOAUT+B45_MESAUT+B45_NUMAUT+B45_SEQUEN
BK6->(dbSetOrder(4)) //BK6_FILIAL+BK6_CGC
BCI->(dbsetOrder(1))

lSaldoSE2	:= .T.	// Verifica se há saldo, senão pula registro
 
//define regua
oReport:setMeter(0)
	
if !TRBLIV->(eof())

	//carrego as propriedades do produto
	cSql := "  SELECT BI3_CODIGO, "
	cSql += "         BI3_SUSEP,  "
	cSql += " 	      BI3_MODPAG, "
	cSql += " 	      BI3_DTAPPR, "
	cSql += " 	      COALESCE (BII_DESCRI, ' ') BII_DESCRI, "
	cSql += " 	      BI3_CODSEG, "
	cSql += " 	      BI6_DESCRI  "
	cSql += "   FROM "+retsqlName("BI3")+" BI3 "
	cSql += " INNER JOIN "+retsqlName("BI6")+" BI6"
	cSql += "   ON BI6_FILIAL = '"+xFilial("BI6")+"' "
	cSql += "  AND BI6_CODSEG = BI3_CODSEG "
	cSql += "  AND BI6.D_E_L_E_T_ = ' ' "

	cSql += " LEFT JOIN "+retsqlName("BII")+" BII"
	cSql += "   ON BII_FILIAL = '"+xFilial("BII")+"' "
	cSql += "  AND BII_CODIGO = BI3_TIPCON "
	cSql += "  AND BII.D_E_L_E_T_ = ' ' "

	cSql += " WHERE BI3.D_E_L_E_T_ =  ' ' "

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"BI3TMP",.F.,.T.)

	while !BI3TMP->(eof())
		aadd(aProduto, {BI3TMP->BI3_CODIGO, BI3TMP->BI3_SUSEP, BI3TMP->BI3_MODPAG, StoD(BI3TMP->BI3_DTAPPR), BI3TMP->BII_DESCRI, BI3TMP->BI3_CODSEG, BI3TMP->BI6_DESCRI} )
		BI3TMP->(dbSkip())
	endDo

	BI3TMP->(DbCloseArea())

	TRBLIV->(DbgoTop())
	nPosSE2	:= 0
	nPosSE2ORI	:= 0

	BCI->( DBSetOrder(1) )

	//conout("inicio while : " + time())

	while !oReport:cancel() .and. !TRBLIV->(eof()) 
		nEIN++
		oReport:incMeter()

		//conout(Str(nEIN) + " M1 : " + time())
		
		dbSelectArea("SE2")
		SE2->( msGoTo( TRBLIV->SE2Recno ) )	
		// Controle de arredondamento de títulos
		// Se Titulo diferente do recno e recno válido
		//lEndIsNear := aScan(aEndIsNear, nEIN) > 0
		lEndIsNear := .F.
		lRecZero := .F.
		if TRBLIV->SE2Recno == 0
			lRecZero := .T.
			nValDescy := 0
		endIF
		If (nPosSE2 <> TRBLIV->SE2Recno  /*.or. cLastCon <> TRBLIV->BD7_CONEMP*/ ) .and. TRBLIV->SE2Recno > 0    
			
			nPosSE2 := TRBLIV->SE2Recno
			cLastCon:= TRBLIV->BD7_CONEMP
			nAcuIRRF	:= 0	// Acumula o IR em valor
			nAcuISS		:= 0	// Acumula o ISS em valor
			nAcuINSS	:= 0	// Acumula o INSS em valor
			nAcuDesc	:= 0	// Acumula o Desconto em valor
			nAcuPerc	:= 0	// Acumula o percentual do valor pago para ajuste do último registro do título
			nAcuDescx	:= 0
			nAcuperc2	:= 0
			nAcuNeg	:= 0
			lArred		:= .F.	// Flag de controle de arredondamento
			lTemAglu := .F.
			ctitAglu := ""
			If TRBLIV->RECAGLU > 0
				aareaAglu := SE2->(Getarea())
				SE2->( msGoTo( TRBLIV->RECAGLU ) )
				If SE2->E2_EMISSAO <= MV_PAR01
					ctitAglu := SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)
				endIf
				nPerAglu := 1 - ( plRetXY( DtoS(MV_PAR01) ) / SE2->E2_VALOR )
				If nPerAglu < 0
					nPerAglu := 0
				endIf
				Restarea(aareaAglu)
				lTemAglu := .T.
			endIf
			nValDescy := plRetXY( DtoS(MV_PAR01) )
			If (lTemAglu .AND. nPerAglu >0) .OR. !lTemAglu
				If TRBLIV->ORIQRY == '2'
					lSaldoSE2 := .T.
					nSaldo := SE2->E2_VALOR
				else
					nSaldo := SE2->E2_VALOR - nValDescy
					lSaldoSE2	:= nSaldo > 0 //( nSaldo:= SaldoTit(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_NATUREZ, 'P', SE2->E2_FORNECE, 1, , MV_PAR01, SE2->E2_LOJA, xFilial('SE2'), , 2 ) ) > 0
				endIf
				If lTemAglu
					nSaldo := nSaldo * nPerAglu
				EndIf
			else
				lSaldoSE2 := .F.
			endIf		
			If !lSaldoSE2
				TRBLIV->(dbSkip())
				Loop
			EndIf				
			//nDescCom	:= DescSF1()
			nTotBD7PG := SumBD7PG(SE2->E2_FILIAL + '|' + SE2->E2_PREFIXO + '|' + SE2->E2_NUM + '|' + SE2->E2_PARCELA + '|' + SE2->E2_TIPO + '|' + SE2->E2_FORNECE + '|' + SE2->E2_LOJA)

		// Se Mesmo titulo e recno válido, avalia se tem saldo a considerar
		ElseIf TRBLIV->SE2Recno > 0 .and. !lSaldoSE2
			TRBLIV->(dbSkip())
			Loop
						
		EndIf
		
		//posiciona no cabecalho da guia
		If cChaveCAB <> TRBLIV->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO)

			If BCI->( MSSeek( xFilial("BCI") + TRBLIV->( BD7_CODOPE+BD7_CODLDP+BD7_CODPEG ) ) ) .AND. TRBLIV->BD7_TIPGUI <> REEMBOLSO
				cBCIDtDigi := DtoC(BCI->BCI_DTDIGI)
			elseIf TRBLIV->BD7_TIPGUI == REEMBOLSO
				cBCIDtDigi := DtoC( StoD(TRBLIV->BD7_DTDIGI) )
			Else
				cBCIDtDigi := ""
			EndIf	
			    	
	        cAliasCAB := IIF( TRBLIV->BD7_TIPGUI == "05", "BE4", "BD5")
	        cChaveCAB := TRBLIV->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO)
	       	       	  
	        (cAliasCAB)->( msSeek( xFilial(cAliasCAB) + cChaveCAB ) )
	        If cAliasCAB == "BE4"
	        	dDatProCab := BE4->BE4_DATPRO //((cAliasCAB)->(cAliasCAB+"_DATPRO"))
	        else
	        	dDatProCab := BD5->BD5_DATPRO
	        endIf 
	        lReemb	:= .F.
	        //guia de reembolso
	        if TRBLIV->BD7_TIPGUI == REEMBOLSO .and. cAliasCAB =="BD5"
		        B44->( msSeek( xFilial("B44") + (cAliasCAB)->(BD5_OPEMOV+BD5_ANOAUT+BD5_MESAUT+BD5_NUMAUT) ) )
		        BOW->( msSeek( xFilial("BOW") + B44->B44_PROTOC ) )
				B45->( msSeek( xFilial("B45") + (cAliasCAB)->(BD5_OPEMOV+BD5_ANOAUT+BD5_MESAUT+BD5_NUMAUT)   ) )
				BK6->( msSeek( xFilial("BK6") + B45->B45_CODREF ) )
		        lReemb	:= .T.       
	        endIf
		    
		    //Posiciona nas tabelas auxliares  
			fposTAux()
		    

			// DATA DE VENCIMENTO PARA O USUÁRIO
			aRetBlq	:= blqlbq(dtos(dDatAte),dtos(dDatAte),,TRBLIV->(BD7_OPEUSR+BD7_CODEMP+BD7_MATRIC),TRBLIV->BD7_TIPREG,BA1->BA1_LOCSIB,'')
			if Len(aRetBlq) > 0 .and. valType("aRetBlq[Len(aRetBlq)]") == 'L'
				dTerCon	:= iIf(aRetBlq[len(aRetBlq),7], Iif(aRetBlq[len(aRetBlq)]=='0', aRetBlq[len(aRetBlq),3], aRetBlq[len(aRetBlq),4] ), ctod('') )
			else
				dTerCon	:= ctod('')
			endIf 		
				

			// Valida registro, se retornar .T. nao reposiciona
			if cLastFam <> BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)
				
				nPosBA1	:= BA1->(Recno())
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
			
			cChvGui := TRBLIV->(BD7_CODLDP+BD7_CODPEG+BD7_NUMERO)
	
			if	TRBLIV->BD7_TIPGUI == REEMBOLSO
				B44->(dbSetOrder(5))
				If B44->(MsSeek(xfilial("B44") + TRBLIV->BD7_CODPEG + TRBLIV->BD7_NUMERO))
					If BOW->(MsSeek(xfilial("BOW") + B44->B44_PROTOC))
						dDtVenc := (BOW->BOW_DTDIGI + nsomRee)
						cBCIDtDigi := DtoC(BOW->BOW_DTDIGI)
					endIf
				endIf
			elseIf BCI->(msseek( xfilial("BCI") + TRBLIV->(BD7_CODOPE + BD7_CODLDP + BD7_CODPEG) ))
				dDtVenc := (BCI->BCI_DATPAG)
			endIf
	    EndIf

		// Classificações abaixo ficam fora do if de cabeçalho porque pode rejeitar o primeiro registro		

	    // Classifica o tipo de documento
		If TRBLIV->BD7_TIPGUI == REEMBOLSO
			cTipDoc	:= 'REM'
		ElseIf BAU->BAU_TIPPRE = cPlTpRec
			cTipDoc	:= 'RECT'
		ElseIf cAliasCab == 'BD5' .and. !empty(BD5->BD5_TIPATE) .and. BD5->BD5_TIPATE $ cSauOcu
       		cTipDoc := 'SO'
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
	
		// Nao considera se nao conseguiu classificar
		if empty(cTipDoc)
			TRBLIV->(dbSkip())
			loop
		endIf		
		
		//Se Benef.Operadoras, não deve considerar outras operadoras               
		if MV_PAR06 == 1 .and. ( (lUnimeds .and. BT5->BT5_CODIGO == cInterc) .or.(BT5->BT5_INTERC == '1') .OR. cTipDoc == 'SO' .or. TRBLIV->BD7_CODRDA == cRDASUS )
			TRBLIV->(dbSkip())
			loop
		endIf	
		
		//Se Benef.Outras Operadoras, não deve considerar guias de reembolsos.     
		if MV_PAR06 == 2 .and. ( BT5->BT5_INTERC <> '1' .or. TRBLIV->BD7_TIPGUI == '04' )
			TRBLIV->(dbSkip())
			loop
        Elseif MV_PAR06 == 2
        	cTipDoc := 'RECA'
		endIf	
		
		//Se N.Rel.Atd Medico/Hospitalar.
		If MV_PAR06 <> 3 .AND. cTipDoc == 'SO'
			TRBLIV->(dbSkip())
			loop
		endIf	
		
		//Se Ressarcimento ao SUS, filtra atendimentos por RDA = MV_RDASUS         
		if MV_PAR06 == 4 .and. ( BT5->BT5_INTERC == '1' .or. TRBLIV->BD7_CODRDA != cRDASUS )
			TRBLIV->(dbSkip())
			loop
        Elseif MV_PAR06 == 4
        	cTipDoc := 'SUS'
		endIf
	
		If MV_PAR06 == 5
        	cTipDoc := 'ODO'
		EndIf
		
		if oReport:Cancel()
			exit
		endIf
				
		if cLastProd <> iif(EMPTY(BA1->BA1_CODPLA),BA3->BA3_CODPLA,BA1->BA1_CODPLA)

			cLastProd 	:= iif(EMPTY(BA1->BA1_CODPLA),BA3->BA3_CODPLA,BA1->BA1_CODPLA)

			if ( nPos := aScan(aProduto,{|x| x[1] == cLastProd }) ) > 0
  				 			
				cSusEp		:= aProduto[nPos,2]
				cTipCon		:= aProduto[nPos,5]
				cCodSeg 	:= aProduto[nPos,6]
				cDescSeg 	:= aProduto[nPos,7]
				
				//1=Pre-Pagamento;2=Demais Modalidades;3=Pos-Estabelecido;4=Misto (Pre/Pos); 9=Nao Definida
				nPos := ascan(aModPag,{|x| x[2] == allTrim(aProduto[nPos,3])})
				if nPos > 0 
					cModPag := allTrim(aModPag[nPos,3])
				else
					cModPag := ""
				endIf
				//data aprovacao do produto pela ans
				cADLei := Iif( aProduto[nPos,4] <= ADLei, 'Antes da lei','Depois da lei' )

			endIf

		endIf
				
		cChvCtb := iIf( empty(TRBLIV->BD7_CHVLA), TRBLIV->BD7_CHVPRO, TRBLIV->BD7_CHVLA )
		
		If empTy(cChvCtb)
			cChvCtb := fnChvCTB(TRBLIV->BD7_CODOPE, TRBLIV->BD7_CODLDP, TRBLIV->BD7_CODPEG, TRBLIV->BD7_NUMERO)
		endIf
		
		cDocCtb	:= allTrim( subStr(cChvCtb, 9, len(cChvCtb)) )
		dDtCtb	:= stod( allTrim(subStr(cChvCtb, 1, 8)) )
		lCT2Ativo := .T.

		// Limpa variaveis a cada registro para nao influenciar na soma dos totalizadores
		nValINSS := 0
		nValIRRF := 0
		nValISS  := 0
		nValDesc := 0
		nVlrLiqG := 0
		nValBrut := 0		
		nValDescx := 0
		
		//informacoes do titulo
		oSTITULO:init()	

		oSTITULO:cell("CODLDP"):setValue(TRBLIV->BD7_CODLDP)
		If TRBLIV->BD7_TIPGUI == REEMBOLSO
			lReemb	:= .T.
			oSTITULO:cell("NUMPRT"):setValue(TRBLIV->BD7_PROTOC)		
			oSTITULO:cell("NUMGUI"):setValue(' ')				
		else
			lReemb	:= .F.
			oSTITULO:cell("NUMPRT"):setValue(TRBLIV->BD7_CODPEG)		
			oSTITULO:cell("NUMGUI"):setValue(TRBLIV->BD7_NUMERO)		
		EndIF	
		oSTITULO:cell("CONTRATO"):setValue(BA1->(BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB))
		oSTITULO:cell("MATRIC"):setValue(cMatTit)
        oSTITULO:cell("INICON"):setValue(dIniCon)
        oSTITULO:cell("TERCON"):setValue(IIf(Empty(dTerCon), CtoD('31/12/9999'), dTerCon))
        oSTITULO:cell("DTCONH"):setValue(cBCIDtDigi)
		
		oSTITULO:cell("NOMETIT"):setValue(cNomTit)	
		oSTITULO:cell("CNPJTIT"):setValue(cCpfTit)
  		oSTITULO:cell("NOMEBEN"):setValue(BA1->BA1_NOMUSR)
  		
		oSTITULO:cell("DTOCORR"):setValue(DtoC( StoD(TRBLIV->BD7_DATPRO) ))
		oSTITULO:cell("CODPRE"):setValue(TRBLIV->BD7_CODRDA)
		cCnpjPre := IIf( TRBLIV->BD7_TIPGUI == REEMBOLSO, IIf(!Empty(B45->B45_CODREF), IIf(!Empty(BK6->BK6_CGC) ,BK6->BK6_CGC ,cCpfTit), IIf(!Empty(BOW->BOW_CODREF),BOW->BOW_CODREF, cCpfTit ) ), BAU->BAU_CPFCGC )
		oSTITULO:cell("CNPJPR"):setValue( cCnpjPre )
		oSTITULO:cell("NOMEPR"):setValue( IIf( TRBLIV->BD7_TIPGUI == REEMBOLSO, IIf(!Empty(B45->B45_CODREF), IIf(!Empty(BK6->BK6_NOME),BK6->BK6_NOME,cNomTit), IIf(!Empty(BOW->BOW_NOMREF),BOW->BOW_NOMREF, cNomTit ) ), BAU->BAU_NOME   ) )
		oSTITULO:cell("FORNECE"):setValue(IIf( TRBLIV->BD7_TIPGUI == REEMBOLSO, BOW->BOW_FORNEC, BAU->BAU_CODSA2 ) )
		oSTITULO:cell("TIPDOC"):setValue(cTipDoc)
		oSTITULO:cell("DOCCTB"):setValue( Iif(lCT2Ativo,cDocCtb,'') )
		oSTITULO:cell("DTCTB"):setValue( Iif(lCT2Ativo,dDtCtb,ctod('') ) )
		oSTITULO:cell("VLREVE"):setValue( IIf(lReemb, TRBLIV->BD7TVLRPAG, TRBLIV->BD7TVLRY ) - TRBLIV->BD7TVLTXPG )
		oSTITULO:cell("VLTXPG"):setValue( TRBLIV->BD7TVLTXPG + TRBLIV->BD7TVLRGTX )
		oSTITULO:cell("VLRGTX"):setValue( TRBLIV->BD7TVLRGTX )
		oSTITULO:cell("VLRGLO"):setValue(IIf( TRBLIV->BD7_FASE > '1',IIf(lReemb, 0, IIf( StoD(TRBLIV->BD7_DTCTBF) <= dDatAte, TRBLIV->BD7TVLRGLO, 0 ) ), 0))
		oSTITULO:cell("DTGER"):setValue(IIf( StoD(TRBLIV->BD7_DTPAGT)<=MV_PAR01, StoD(TRBLIV->BD7_DTPAGT), CtoD('') ) )
		oSTITULO:cell("TIPEVE"):setValue( TRBLIV->X5YR_DESCRI )  
		oSTITULO:cell("REGPRO"):setValue(cSusEp)
		oSTITULO:cell("SEGMENTACAO"):setValue(cDescSeg + " | " + cModPag + " | " + cADLei)			
		oSTITULO:cell("TPCONTRATO"):setValue( cTipCon  )			

		// Data de vencimento trará a data prevista de pagamento do RDA, se houver título atualizará abaixo
		oSTITULO:cell("DTVENC"):setValue(dDtVenc)

		// PFPJ
		oSTITULO:cell("PFPJ"):setValue(IIf(Len(AllTrim(cCnpjPre))<14, 'PF', 'PJ' ))

		// Forcar limpeza para registro sem titulo
		// Vlr.Liq.de Glosa= Vlr,Evento + Tx.Adm. - Glosas (VLLIQG)
		
		// Se fase 1 e Glosa = 0, trazer mesmo valor que apresentado (atentar que há ponto de entrada, não dá para fixar BD7TVLRPAG)
		If TRBLIV->BD7_FASE == '1' .AND. TRBLIV->(BD7TVLRGLO+BD7TVLRGTX)== 0 
			nVlrLiqG := IIf(lReemb, TRBLIV->BD7TVLRPAG, IIf(TRBLIV->BD7TVLRAPR==0, TRBLIV->BD7TVLRPAG+TRBLIV->BD7TVLRGLO, TRBLIV->BD7TVLRAPR ) )	
		Else
			nVlrLiqG := TRBLIV->BD7TVLRPAG 
		EndIf	
		oSTITULO:cell("VLLIQG"):setValue(nVlrLiqG)
		
		// Se já tem título, confirma se foi emitido até a data parametrizada e se o valor a pagar é maior que zero
		If TRBLIV->SE2Recno > 0 .and. SE2->E2_EMISSAO <= MV_PAR01 .and. nVlrLiqG > 0
//			nValDescy := plRetXY( DtoS(MV_PAR01) )
			If empty(ctitAglu)
				oSTITULO:cell("TITULO"):setValue(SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO))
			else
				oSTITULO:cell("TITULO"):setValue(ctitAglu)
			endIf
	
			nValBrut:= nTotBD7PG // SE2->(E2_VALOR+E2_INSS+E2_IRRF+E2_ISS+E2_DESCONT)
			// Fator de representacao desse item no total do titulo
	//		If MV_PAR06 <> 1
	//			nFator := IIf( TRBLIV->BD7TVLRPAG/nValBrut >0, NoRound(TRBLIV->BD7TVLRPAG/nValBrut,16) , 1 )
	//		else
				nFator := IIf( TRBLIV->BD7TVLRPAG/nValBrut >0, TRBLIV->BD7TVLRPAG/nValBrut , 1 )
	//		EndIf
			// No fator, aplica o percentual que já foi pago desse título, para sobrar o que há em aberto
			
			nFator2 := nFator * ( ( nSaldo + nValDescy ) / (SE2->E2_VALOR)) 
			nFator := nFator * ( ( nSaldo  ) / (SE2->E2_VALOR) ) 
			
			nAcuPerc	+= nFator2		// Acumula o percentual do valor pago para ajuste do último registro do título
			nAcuperc2	+= nFator2
			
			If nAcuPerc > 1.0001 //caso fique 1.00XXX, desconsideramos os decimais
				nFator2 := nAcuperc - 1
				nAcuPerc := 1
			EndIf
			If nFator > nLimFat	

				nValINSS	:= (SE2->E2_INSS * nFator2)
				nAcuINSS	+= nValINSS		// Acumula o INSS em valor
				If nAcuINSS > SE2->E2_INSS
					nValDif  := SE2->E2_INSS - nAcuINSS
					nValINSS += nValDif
					nAcuINSS := SE2->E2_INSS
				elseIf /*(lEndIsNear .OR. nAcuPerc == 1 )*/ .F. .AND. nAcuINSS <> (SE2->E2_INSS * nAcuPerc) 
					nValDif := (SE2->E2_INSS * nAcuPerc) - nAcuINSS 
					If lendIsNear .aNd. nAcuPerc < 1 .AND. MV_PAR06 == 1
						nValDif := (nValDif)
					endIf
					nValINSS += nValDif
					nAcuINSS := (SE2->E2_INSS * nAcuPerc) 
				EndIf
				oSTITULO:cell("VLINSS"):setValue(nValINSS)
				
				nValIRRF	:= (SE2->E2_IRRF * nFator2)
				nAcuIRRF	+= nValIRRF		// Acumula o IR em valor
				If nAcuIRRF > SE2->E2_IRRF
					nValDif  := SE2->E2_IRRF - nAcuIRRF
					nValIRRF += nValDif
					nAcuIRRF := SE2->E2_IRRF
				elseIf /*(lEndIsNear .OR. nAcuPerc == 1 )*/ .F.  .AND. nAcuIRRF <> SE2->E2_IRRF * nAcuPerc //nAcuIRRF < Noround(SE2->E2_IRRF * nAcuPerc, 2)					
					nValDif := SE2->E2_IRRF * nAcuPerc - nAcuIRRF//Noround(SE2->E2_IRRF * nAcuPerc, 2) - nAcuIRRF
					If lendIsNear .aNd. nAcuPerc < 1 .AND. MV_PAR06 == 1
						If .F. ///*noround(nValDif, 3)*/ nValDif - noround(nValDif, 2) <= 0.005
							nValDif := NoRound(nValDif, 2)
						else
							//nValDif := round(nValDif, 2)
							nValDif := (nValDif)
						endIf
					endIf
					nValIRRF += nValDif
					nAcuIRRF := SE2->E2_IRRF * nAcuPerc //Noround(SE2->E2_IRRF * nAcuPerc, 2)
				endIf	
				oSTITULO:cell("VLIRRF"):setValue(nValIRRF)
					
				nValISS		:= (SE2->E2_ISS * nFator2)
				nAcuISS		+= nValISS		// Acumula o ISS em valor
				If nAcuISS > SE2->E2_ISS
					nValDif := SE2->E2_ISS - nAcuISS
					nValISS += nValDif
					nAcuISS := SE2->E2_ISS
				elseIf /*(lEndIsNear .OR. nAcuPerc == 1 )*/ .F.  .AND. nAcuISS <> SE2->E2_ISS * nAcuPerc//Noround(SE2->E2_ISS * nAcuPerc, 2)
					nValDif := (SE2->E2_ISS * nAcuPerc) - nAcuISS //Noround(SE2->E2_ISS * nAcuPerc, 2) - nAcuISS
					If lendIsNear .aNd. nAcuPerc < 1 .AND. MV_PAR06 == 1
						nValDif := (nValDif)
					endIf
					nValISS += nValDif
					nAcuISS := SE2->E2_ISS * nAcuPerc //Noround(SE2->E2_ISS * nAcuPerc, 2)
				endIf	
				oSTITULO:cell("VLISS"):setValue(nValISS)
					
				nValDesc	:= (SE2->E2_DESCONT * nFator2)
				nAcuDesc	+= nValDesc	// Acumula o Desconto em valor
				If nAcuDesc > SE2->E2_DESCONT
					nValDif  := SE2->E2_DESCONT - nAcuDesc
					nValDesc += nValDif
					nAcuDesc := SE2->E2_DESCONT
				elseIf /*(lEndIsNear .OR. nAcuPerc == 1 )*/ .F.  .AND. nAcuDesc <> SE2->E2_DESCONT * nAcuPerc //Noround(SE2->E2_DESCONT * nAcuPerc, 2)
					nValDif  := SE2->E2_DESCONT * nAcuPerc - nAcuDesc
					If lendIsNear .aNd. nAcuPerc < 1 .AND. MV_PAR06 == 1
						If .F. ///*noround(nValDif, 3)*/ nValDif - noround(nValDif, 2) <= 0.005
							nValDif := NoRound(nValDif, 2)
						else
							//nValDif := round(nValDif, 2)
							nValDif := (nValDif)
						endIf
					endIf
					nValDesc += nValDif
					nAcuDesc := SE2->E2_DESCONT * nAcuPerc
				endIf
				oSTITULO:cell("VLDESC"):setValue(nValDesc)
				
				If nValDescy > 0
					nValDescx	:= (nValDescy * nFator2)
					nAcuDescx	+= nValDescx	// Acumula o Desconto em valor
					If nAcuDescx > nValDescy
						nValDif  := nValDescy - nAcuDescx 
						nValDescx += nValDif
						nAcuDescx := nValDescy
					elseIf lEndIsNear .AND. nAcuDescx <> nValDescy * nAcuperc2 
						nValDif  := nValDescy * nAcuperc2 - nAcuDescx
						If lendIsNear .aNd. nAcuperc2 < 1 .AND. MV_PAR06 == 1
							If noround(nValDif, 3) - noround(nValDif, 2) <= 0.005
								nValDif := NoRound(nValDif, 2)
							else
								nValDif := round(nValDif, 2)
							endIf
						endIf
						nValDescx += nValDif
						nAcuDescx := nValDescy * nAcuperc2
					endIf
				else
					nValDescx := 0
				endIf	
			
			Else
				nValINSS	:= 0
				oSTITULO:cell("VLINSS"):setValue(nValINSS)
	
				nValIRRF	:= 0
				oSTITULO:cell("VLIRRF"):setValue(nValIRRF)
	
				nValISS		:= 0
				oSTITULO:cell("VLISS"):setValue(nValISS)
	
				nValDesc	:= 0
				oSTITULO:cell("VLDESC"):setValue(nValDesc)
				
				nValDescx := 0
			EndIf
					
			// Viro o registro antes de fechar a linha para recalcular arredondamento, se foi o último registro do título
			TRBLIV->(dbSkip())		
			//z
		Else	
			// Zera as variáveis
			oSTITULO:cell("TITULO"):setValue('')

			nValINSS	:= 0
			oSTITULO:cell("VLINSS"):setValue(nValINSS)
	
			nValIRRF	:= 0
			oSTITULO:cell("VLIRRF"):setValue(nValIRRF)
	
			nValISS		:= 0
			oSTITULO:cell("VLISS"):setValue(nValISS)
	
			nValDesc	:= 0
			oSTITULO:cell("VLDESC"):setValue(nValDesc)
			
			nValDescx := 0
			
			TRBLIV->(dbSkip())						

		EndIf
		
		// Vlr.Liq.de Ret.= Vlr.Eve + Tx.Adm -Glosas -Impostos na Fonte - Descontos (VLLIQR)
		If lRecZero .OR. SE2->E2_EMISSAO > MV_PAR01 //.and. //.f. //nValDescx > 0
			oSTITULO:cell("VLLIQR"):setValue( nVlrLiqG )
		else
			nValZX	:= SE2->E2_VALOR * nfator //nVlrLiqG - ( nValINSS + nValIRRF + nValISS + nValDesc + nValDescx )
			
			If nValZX < 0
				nAcuNeg += nValZX
				nValZX	:= 0
			endIf
			
			If nAcuNeg < 0 .AND. nValZX > 0
				If abs(nAcuNeg) > abs(nValZX)
					nAcuNeg += nValZX
					nValZX	:= 0
				else
					nValZX += nAcuNeg
					nAcuNeg := 0
				endIf
			endIf 
			
			If nValZX > nVlrLiqG * 2
				nValZX := nVlrLiqG
			endIf
			//oSTITULO:cell("VLLIQR"):setValue( nVlrLiqG - ( nValINSS + nValIRRF + nValISS + nValDesc + nValDescx ) )
			oSTITULO:cell("VLLIQR"):setValue( nValZX )
		endIf

		oSTITULO:printLine()
		oSTITULO:finish()
	endDo

	oReport:endPage()
	
endIf

//Fecha a tabela temporária 
TRBLIV->(dbCloseArea())

// Limpa os arrays
aSize(aBauVenc,1)
aDel(aBauVenc,1)

aSize(aPadProd,1)
aDel(aPadProd,1)
//conout(Str(nEIN) + " MY : " + time())
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getTrbQuery
Executa query 

@author DEV
@since 05/03/2016
@version ALL
/*/
//--------------------------------------------------------------------------------------------------
static function getTrbQuery(dDatDe,dDatRef,lEnd,nTotReg)
local nX		 := 0
local nPos		 := 0
local nFator	 := 0  
local cQuery	 := ""
local cWhere	 := "" 
local aStruSQL 	 := {}
local aPadProd	 := {}
local aTipEvct	 := {}
local aSetField	 := {}
local aTipRel	 := { "O", "C", "M", "S", "D" }		// Tipo de Relatório: Operadora, Corresp.Assumida, N.Rel.Pl.Med.Hosp, Ressar.SUS, N.Rel.Pl.Odonto 
local cPlTpRec	 := getNewPar("MV_PLTPREC","016")
Local lMsSql     := Upper(TcGetDb()) $ "MSSQL"
local cRDASUS	 := getNewPar("MV_RDASUS","SUS")
Local cCodLDPExc := GetNewPar("MV_PLEXDAC", "")

Default nTotReg  := 0

if empty(MV_PAR01) 
    msgAlert(STR0042,STR0046) //"O período deve ser determinado."//"Atenção"
    return({.T.})
endIf

if empty(MV_PAR02)
    msgAlert(STR0043,STR0046) //"Operadora deve ser informada."//"Atenção"
    return({.T.})
endIf

if empty(MV_PAR03+MV_PAR04)
    msgAlert(STR0044,STR0046) //"Parametros de Empresa devem ser informados."//"Atenção"
    return({.T.})
endIf

if !empty(cCodLDPExc)
    cCodLDPExc := ConvStrRel(cCodLDPExc)
endif

// Query principal na Composição dos Itens da Guia

//PRIMEIRA QUERY: JA FOI GERADO SE2 MAS AINDA NÃO FOI BAIXADO OU TEM SALDO NA DATA
cQuery := " SELECT * FROM ( "  
cQuery	+= "SELECT "
cQuery	+= "BD7_TIPGUI,BD7_DTDIGI,BD7_CODRDA,BD7_CODOPE,"
cQuery	+= "BD7_CODLDP,BD7_CODPEG,BD7_NUMERO,BD7_OPEUSR,"
cQuery	+= "BD7_CODEMP,BD7_MATRIC,BD7_TIPREG,COALESCE(SX5YR.X5_DESCRI,' ') X5YR_DESCRI," 
cQuery	+= "BD7_CONEMP,BD7_FASE  ,BD7_ANOPAG,BD7_MESPAG,"
cQuery	+= "BD7_CHVLA,BD7_CHVPRO,BD7_DTPAGT,"
cQuery	+= "BD7_DTCTBF,BD7_ORIMOV,BD7_PROTOC," 
cQuery	+= "SE2.R_E_C_N_O_ AS SE2Recno, "
cQuery	+= "'1' AS ORIQRY, "
cQuery	+= "SUM(BD7_VLRMAN) AS BD7TVLRMAN, "
cQuery	+= "SUM(BD7_VALORI) BD7TVLRAPR, "
cQuery	+= "SUM(BD7_VLRPAG+BD7_VLRGLO) BD7TVLRY, "
cQuery	+= "SUM(BD7_VLRPAG) AS BD7TVLRPAG, SUM(BD7_VLRGLO) AS BD7TVLRGLO, "
cQuery	+= "SUM(BD7_VLINPT) AS BD7TVLINPT, SUM(BD7_VLTXPG) AS BD7TVLTXPG,"
cQuery	+= "SUM(BD7_VLRGTX) AS BD7TVLRGTX, SUM(BD7_GLINPT) AS BD7TGLINPT,"
cQuery += " SUM(BD7_VLTXAP ) BD7TVTXAP, 0 RECAGLU, BD7_DATPRO "

cQuery += " FROM " + RetSqlName("SE2") + " SE2 "  

// Composição dos Itens da Guia		
cQuery += " INNER JOIN " + RetSqlName("BD7") + " BD7 " 
cQuery += "    ON BD7_FILIAL = '" + xFilial("BD7") + "' "
cQuery += " AND BD7_CHKSE2 = SE2.E2_FILIAL || '|' || SE2.E2_PREFIXO || '|' || SE2.E2_NUM || '|' || SE2.E2_PARCELA || '|' || SE2.E2_TIPO || '|' || SE2.E2_FORNECE || '|' || SE2.E2_LOJA "

cQuery += "   AND BD7_SITUAC <> '2' " // 1 - Ativo / 2 - Cancelado / 3 - Bloqueado
If MV_PAR03 <> MV_PAR04
	cQuery += "   AND BD7_CODEMP >= '" + MV_PAR03 + "' "
	cQuery += "   AND BD7_CODEMP <= '" + MV_PAR04 + "' "
else
	cQuery += "   AND BD7_CODEMP = '" + MV_PAR03 + "' "
endIf
cQuery += "   AND BD7_DTDIGI <= '" + DtoS(MV_PAR01) + "' "
cQuery += "   AND BD7_CODLDP NOT IN( '" + PLSRETLDP(9) + "', '" + PLSRETLDP(4) + "'" + cCodLDPExc + " ) " //e99
cQuery += "   AND BD7.D_E_L_E_T_ = ' ' "

If MV_PAR06 == 4
	cQuery	+= " AND BD7.BD7_CODRDA = '" + cRDASUS + "' "
else
	if !empty(MV_PAR07)
		cQuery	+= " AND BD7.BD7_CODRDA >= '" + MV_PAR07 + "' "
	endIf
	if !empty(MV_PAR08) .AND. UPPER(MV_PAR08) <>  "ZZZZZZ"
		cQuery	+= " AND BD7.BD7_CODRDA <= '" + MV_PAR08 + "' "
	endIf
EndIf

cQuery += " AND BD7_BLOPAG <> '1' "
If MV_PAR06 == 2
	cQuery	+= "   AND BD7_TIPGUI <> '04' "
endIf

cQuery	+= " INNER JOIN " + RetSqlName("BT5") + " BT5 "
cQuery	+= "  ON BT5_FILIAL = BD7.BD7_FILIAL " 
cQuery	+= " AND BT5_CODINT = BD7.BD7_CODOPE "
cQuery	+= " AND BT5_CODIGO = BD7.BD7_CODEMP "
cQuery	+= " AND BT5_NUMCON = BD7.BD7_CONEMP "
cQuery	+= " AND BT5_VERSAO = BD7.BD7_VERCON "
cQuery	+= " AND BT5.D_E_L_E_T_ = ' ' "

If MV_PAR06 == 2
	cQuery	+= " AND BT5_INTERC = '1' "
else
	cQuery	+= " AND BT5_INTERC <> '1' "
endIf

cQuery	+= " LEFT JOIN "+retsqlName("SX5")+" SX5YR  "
cQuery	+= "   ON X5_FILIAL = ' '  "
cQuery	+= "  AND X5_TABELA = 'YR'  "
cQuery	+= "  AND X5_CHAVE = BD7.BD7_TPEVCT  "
cQuery	+= "  AND SX5YR.D_E_L_E_T_ = ' ' "
////se for somente saúde ocupacional (mv_par06 = 3) vou economizar processamento já filtrando os BD5 aqui pra não precisar de skip depois
// Cabeçalho das Guias
if MV_PAR06 == 3
	cQuery	+= " INNER JOIN "+RetSqlName("BD5")+" BD5 " 
	cQuery	+= "  ON BD5_FILIAL = '"+xFilial('BD5')+"' "
	cQuery	+= " AND BD5_CODOPE = BD7.BD7_CODOPE "
	cQuery	+= " AND BD5_CODLDP = BD7.BD7_CODLDP "
	cQuery	+= " AND BD5_CODPEG = BD7.BD7_CODPEG "
	cQuery	+= " AND BD5_NUMERO = BD7.BD7_NUMERO "
	cQuery	+= " AND BD5_SITUAC = BD7.BD7_SITUAC "
	cQuery	+= " AND BD5_FASE   = BD7.BD7_FASE   "
	cQuery	+= " AND BD5_DATPRO = BD7.BD7_DATPRO "
	cQuery	+= " AND BD5_OPERDA = BD7.BD7_CODOPE "
	cQuery	+= " AND BD5_CODRDA = BD7.BD7_CODRDA "
	cQuery	+= " AND BD5_TIPATE >= '14' "
	cQuery	+= " AND BD5_TIPATE <= '21' "
	cQuery	+= " AND BD5.D_E_L_E_T_ = ' ' "
endif

If MV_PAR06 == 5

	cQuery += " Inner Join " + retsqlName("BR8") + " BR8 "
	cQuery += " On "
	cQuery += " BR8_FILIAL = '" + xfilial("BR8") + "' "
	cQuery += " AND BR8_CODPAD = BD7.BD7_CODPAD "
	cQuery += " AND BR8_CODPSA = BD7.BD7_CODPRO "
	cQuery += " AND BR8_ODONTO = '1' "
	cquery += " AND BR8.D_E_L_E_T_ = ' ' "

endIf

/*
cQuery += " LEFT Join " + cSqlfk7 + " FK7 "
cQuery += " On "
cQuery += " FK7.FK7_FILIAL = '" + xfilial("FK7") + "' "
cQuery += " AND FK7.FK7_CHAVE = SE2.E2_FILIAL + '|' + SE2.E2_PREFIXO + '|' + SE2.E2_NUM + '|' + SE2.E2_PARCELA + '|' + SE2.E2_TIPO + '|' + SE2.E2_FORNECE + '|' + SE2.E2_LOJA "
cQuery += " AND FK7.D_E_L_E_T_ = ' ' "

cQuery += " Left Join ( "
cQuery += " select SUM( Case  when FK2_TPDOC = 'ES' then FK2_VALOR else 0 END ) TOT_ES, SUM( Case  when FK2_TPDOC <> 'ES' then FK2_VALOR else 0 END ) TOT_NES, FK2_IDDOC from "
cQuery += " " + retsqlName("FK2") + " "
cQuery += " Where FK2_FILIAL = '" + xfilial("FK2") +  "' "
cQuery += " 	AND FK2_DTDISP < '"+DtoS(dDatDe)+"' "
cQuery += "   AND FK2_MOTBX NOT IN ('LIQ', 'NEG') "
cQuery += " 	AND D_E_L_E_T_ = ' ' " 
cQuery += " group By FK2_IDDOC "
cQuery += " ) J "
cQuery += " 	On J.FK2_IDDOC = FK7.FK7_IDDOC "
*/

cQuery += " LEFT Join " + RetSqlName("FI8") + " FI8ORI "
cquery += " On "
cQuery += " FI8ORI.FI8_FILIAL = '" + xfilial("FI8") + "' "
cQuery += " AND FI8ORI.FI8_PRFORI = SE2.E2_PREFIXO "
cQuery += " AND FI8ORI.FI8_NUMORI = SE2.E2_NUM "  
cQuery += " AND FI8ORI.FI8_PARORI = SE2.E2_PARCELA "
cQuery += " AND FI8ORI.FI8_TIPORI = SE2.E2_TIPO " 
cQuery += " AND FI8ORI.FI8_FORORI = SE2.E2_FORNECE "
cQuery += " AND FI8ORI.FI8_LOJORI = SE2.E2_LOJA "
cQuery += " AND FI8ORI.D_E_L_E_T_ = ' ' "

cQuery += " WHERE E2_FILIAL  = '" + xFilial("SE2") + "' "
//cquery += " AND E2_NUM = '700174605' "
cQuery += "   AND E2_TIPO NOT IN " + formatIn(MVABATIM+"|"+MVIRABT+"|"+MVINABT,"|") //AB-|FB-|FC-|FU-|IR-|IN-|IS-|PI-|CF-|CS-|FE-|IV-//IR-//IN- 
cQuery += "   AND (FI8ORI.FI8_NUMDES IS NULL AND ( E2_SALDO > 0  OR E2_BAIXA > '" + dtoS(MV_PAR01) + "')) "
cQuery += "   AND SE2.D_E_L_E_T_ = ' ' "

//--------------------------------------------------------------------------------------------------
//Executa ponto de entrada para Complemento de Filtro principal.  
//--------------------------------------------------------------------------------------------------         
if existblock("PLR44XP1")
	cQuery	+= execBlock("PLR44XP1",.f.,.f.,{ '442' + aTipRel[MV_PAR06] })
endIf

//cquery += " AND SE2.E2_NUM = '700106646' "

cQuery	+= " GROUP BY "
cQuery	+= "BD7_TIPGUI,BD7_DTDIGI,BD7_CODRDA,BD7_CODOPE,"
cQuery	+= "BD7_CODLDP,BD7_CODPEG,BD7_NUMERO,BD7_OPEUSR,"
cQuery	+= "BD7_CODEMP,BD7_MATRIC,BD7_TIPREG,SX5YR.X5_DESCRI," 
cQuery	+= "BD7_CONEMP,BD7_FASE  ,BD7_ANOPAG,BD7_MESPAG,"
cQuery	+= "BD7_CHVLA,BD7_CHVPRO,BD7_DTPAGT,"
cQuery	+= "BD7_DTCTBF,BD7_ORIMOV,BD7_PROTOC," 
cQuery	+= "SE2.R_E_C_N_O_,BD7_DATPRO"

cQuery += " UNION ALL "

cQuery	+= " SELECT "
cQuery	+= "BD7_TIPGUI,BD7_DTDIGI,BD7_CODRDA,BD7_CODOPE,"
cQuery	+= "BD7_CODLDP,BD7_CODPEG,BD7_NUMERO,BD7_OPEUSR,"
cQuery	+= "BD7_CODEMP,BD7_MATRIC,BD7_TIPREG,COALESCE(SX5YR.X5_DESCRI,' ') X5YR_DESCRI," 
cQuery	+= "BD7_CONEMP,BD7_FASE  ,BD7_ANOPAG,BD7_MESPAG,"
cQuery	+= "BD7_CHVLA,BD7_CHVPRO,BD7_DTPAGT,"
cQuery	+= "BD7_DTCTBF,BD7_ORIMOV,BD7_PROTOC," 
cQuery	+= " 0 AS SE2Recno, '1' AS ORIQRY, " 
cQuery	+= "SUM(BD7_VLRMAN) AS BD7TVLRMAN, "
cQuery	+= "SUM(BD7_VALORI) BD7TVLRAPR, "
cQuery	+= "SUM(BD7_VLRPAG+BD7_VLRGLO) BD7TVLRY, "
cQuery	+= "SUM(BD7_VLRPAG) AS BD7TVLRPAG, SUM(BD7_VLRGLO) AS BD7TVLRGLO, "
cQuery	+= "SUM(BD7_VLINPT) AS BD7TVLINPT, SUM(BD7_VLTXPG) AS BD7TVLTXPG,"
cQuery	+= "SUM(BD7_VLRGTX) AS BD7TVLRGTX, SUM(BD7_GLINPT) AS BD7TGLINPT,"
cQuery  += "SUM(BD7_VLTXAP) BD7TVTXAP, 0 RECAGLU, BD7_DATPRO "


cQuery	+= "FROM " + RetSqlName("BD7") + " BD7 "

cQuery	+= " INNER JOIN " + RetSqlName("BT5") + " BT5 "
cQuery	+= "  ON BT5_FILIAL = BD7.BD7_FILIAL " 
cQuery	+= " AND BT5_CODINT = BD7.BD7_CODOPE "
cQuery	+= " AND BT5_CODIGO = BD7.BD7_CODEMP "
cQuery	+= " AND BT5_NUMCON = BD7.BD7_CONEMP "
cQuery	+= " AND BT5_VERSAO = BD7.BD7_VERCON "
cQuery	+= " AND BT5.D_E_L_E_T_ = ' ' "

If MV_PAR06 == 2
	cQuery	+= " AND BT5_INTERC = '1' "
elseif MV_PAR06 == 1
	cQuery	+= " AND BT5_INTERC <> '1' "
endIf

cQuery	+= " LEFT JOIN "+retsqlName("SX5")+" SX5YR  "
cQuery	+= "   ON X5_FILIAL = ' '  "
cQuery	+= "  AND X5_TABELA = 'YR'  "
cQuery	+= "  AND X5_CHAVE = BD7.BD7_TPEVCT  "
cQuery	+= "  AND SX5YR.D_E_L_E_T_ = ' ' "

////se for somente saúde ocupacional (mv_par06 = 3) vou economizar processamento já filtrando os BD5 aqui pra não precisar de skeep depois
// Cabeçalho das Guias
if MV_PAR06 == 3
	cQuery	+= " INNER JOIN "+RetSqlName("BD5")+" BD5 " 
	cQuery	+= "  ON BD5_FILIAL = '"+xFilial('BD5')+"' "
	cQuery	+= " AND BD5_CODOPE = BD7.BD7_CODOPE "
	cQuery	+= " AND BD5_CODLDP = BD7.BD7_CODLDP "
	cQuery	+= " AND BD5_CODPEG = BD7.BD7_CODPEG "
	cQuery	+= " AND BD5_NUMERO = BD7.BD7_NUMERO "
	cQuery	+= " AND BD5_SITUAC = BD7.BD7_SITUAC "
	cQuery	+= " AND BD5_FASE   = BD7.BD7_FASE   "
	cQuery	+= " AND BD5_DATPRO = BD7.BD7_DATPRO "
	cQuery	+= " AND BD5_OPERDA = BD7.BD7_CODOPE "
	cQuery	+= " AND BD5_CODRDA = BD7.BD7_CODRDA "
	cQuery	+= " AND BD5_TIPATE >= '14' "
	cQuery	+= " AND BD5_TIPATE <= '21' "
	cQuery	+= " AND BD5.D_E_L_E_T_ = ' ' "
endif

If MV_PAR06 == 5

	cQuery += " Inner Join " + retsqlName("BR8") + " BR8 "
	cQuery += " On "
	cQuery += " BR8_FILIAL = '" + xfilial("BR8") + "' "
	cQuery += " AND BR8_CODPAD = BD7.BD7_CODPAD "
	cQuery += " AND BR8_CODPSA = BD7.BD7_CODPRO "
	cQuery += " AND BR8_ODONTO = '1' "
	cquery += " AND BR8.D_E_L_E_T_ = ' ' "

endIf

cQuery	+= " WHERE BD7_FILIAL = '" + xFilial("BD7") + "' "
cQuery	+= "   AND BD7_CODOPE = '" + MV_PAR02 + "' "
cQuery	+= "   AND BD7_CODLDP NOT IN( '" + PLSRETLDP(9) + "', '" + PLSRETLDP(4) + "'" + cCodLDPExc + " ) " //e99
If MV_PAR03 <> MV_PAR04
	cQuery += "   AND BD7_CODEMP >= '" + MV_PAR03 + "' "
	cQuery += "   AND BD7_CODEMP <= '" + MV_PAR04 + "' "
else
	cQuery += "   AND BD7_CODEMP = '" + MV_PAR03 + "' "
endIf

cQuery	+= "   AND BD7_SITUAC != '2' " // 1 - Ativo / 2 - Cancelado / 3 - Bloqueado
cQuery += "   AND BD7_BLOPAG != '1' "	// Pagamento liberado 
cQuery	+= "   AND BD7_CHKSE2 = '" + Space(tamSx3("BD7_CHKSE2")[1]) + "' "
cQuery	+= "   AND BD7_DTDIGI <= '" + DtoS(MV_PAR01) + "' "
cQuery	+= "   AND BD7.D_E_L_E_T_ = ' ' "

If MV_PAR06 == 4
	cQuery	+= " AND BD7.BD7_CODRDA = '" + cRDASUS + "' "
else
	if !empty(MV_PAR07)
		cQuery	+= " AND BD7.BD7_CODRDA >= '" + MV_PAR07 + "' "
	endIf
	if !empty(MV_PAR08) .AND. UPPER(MV_PAR08) <>  "ZZZZZZ"
		cQuery	+= " AND BD7.BD7_CODRDA <= '" + MV_PAR08 + "' "
	endIf
EndIf

If MV_PAR06 == 2
	cQuery	+= "   AND BD7_TIPGUI != '04' "
endIf

cQuery += " AND BD7_ALIAUS != 'B4R' " //Exceção de pagamento

//Executa ponto de entrada para Complemento de Filtro principal.           
if existblock("PLR44XP1")
	cQuery	+= execBlock("PLR44XP1",.f.,.f.,{ '442' + aTipRel[MV_PAR06] })
endIf

//cquery += " AND BD7_TIPGUI = '700106646' "

cQuery	+= " GROUP BY "
cQuery	+= "BD7_TIPGUI,BD7_DTDIGI,BD7_CODRDA,BD7_CODOPE,"
cQuery	+= "BD7_CODLDP,BD7_CODPEG,BD7_NUMERO,BD7_OPEUSR,"
cQuery	+= "BD7_CODEMP,BD7_MATRIC,BD7_TIPREG,SX5YR.X5_DESCRI," 
cQuery	+= "BD7_CONEMP,BD7_FASE  ,BD7_ANOPAG,BD7_MESPAG,"
cQuery	+= "BD7_CHVLA,BD7_CHVPRO,BD7_DTPAGT,"
cQuery	+= "BD7_DTCTBF,BD7_ORIMOV,BD7_PROTOC,BD7_DATPRO" 

cQuery += " UNION ALL "

cQuery	+= "SELECT "
cQuery	+= "BD7_TIPGUI,BD7_DTDIGI,BD7_CODRDA,BD7_CODOPE,"
cQuery	+= "BD7_CODLDP,BD7_CODPEG,BD7_NUMERO,BD7_OPEUSR,"
cQuery	+= "BD7_CODEMP,BD7_MATRIC,BD7_TIPREG,COALESCE(SX5YR.X5_DESCRI,' ') X5YR_DESCRI," 
cQuery	+= "BD7_CONEMP,BD7_FASE  ,BD7_ANOPAG,BD7_MESPAG,"
cQuery	+= "BD7_CHVLA,BD7_CHVPRO,BD7_DTPAGT,"
cQuery	+= "BD7_DTCTBF,BD7_ORIMOV,BD7_PROTOC," 
cQuery	+= "SE2.R_E_C_N_O_ AS SE2Recno, '2' AS ORIQRY, " 

cQuery	+= "SUM(BD7_VLRMAN) AS BD7TVLRMAN, "
cQuery	+= "SUM(BD7_VALORI) BD7TVLRAPR, "
cQuery	+= "SUM(BD7_VLRPAG+BD7_VLRGLO) BD7TVLRY, "
cQuery	+= "SUM(BD7_VLRPAG) AS BD7TVLRPAG, SUM(BD7_VLRGLO) AS BD7TVLRGLO, "
cQuery	+= "SUM(BD7_VLINPT) AS BD7TVLINPT, SUM(BD7_VLTXPG) AS BD7TVLTXPG,"
cQuery	+= "SUM(BD7_VLRGTX) AS BD7TVLRGTX, SUM(BD7_GLINPT) AS BD7TGLINPT,"
cQuery  += "SUM(BD7_VLTXAP) BD7TVTXAP, E2DEST.R_E_C_N_O_ RECAGLU, BD7_DATPRO "

cQuery += " FROM " + RetSqlName("SE2") + " SE2 "  

cQuery += " Inner Join " + RetSqlName("FI8") + " FI8ORI "
cquery += " On "
cQuery += " FI8ORI.FI8_FILIAL = '" + xfilial("FI8") + "' "
cQuery += " AND FI8ORI.FI8_PRFORI = SE2.E2_PREFIXO "
cQuery += " AND FI8ORI.FI8_NUMORI = SE2.E2_NUM "  
cQuery += " AND FI8ORI.FI8_PARORI = SE2.E2_PARCELA "
cQuery += " AND FI8ORI.FI8_TIPORI = SE2.E2_TIPO " 
cQuery += " AND FI8ORI.FI8_FORORI = SE2.E2_FORNECE "
cQuery += " AND FI8ORI.FI8_LOJORI = SE2.E2_LOJA "
cQuery += " AND FI8ORI.D_E_L_E_T_ = ' ' 

cQuery += " Inner Join " + RetSqlName("SE2") + " E2DEST "
cQuery += " On "
cQuery += " E2DEST.E2_FILIAL = FI8ORI.FI8_FILDES "
cquery += " AND E2DEST.E2_PREFIXO = FI8ORI.FI8_PRFDES "
cQuery += " AND E2DEST.E2_NUM = FI8ORI.FI8_NUMDES "
cQuery += " AND E2DEST.E2_PARCELA = FI8ORI.FI8_PARDES "
cQuery += " AND E2DEST.E2_TIPO = FI8ORI.FI8_TIPDES "
cQuery += " AND E2DEST.E2_FORNECE = FI8ORI.FI8_FORDES "
cquery += " AND E2DEST.E2_LOJA = FI8ORI.FI8_LOJDES "
cQuery += " AND E2DEST.D_E_L_E_T_ = ' ' "

cQuery += " LEFT Join " + cSqlfk7 + " K7FI8 "
cQuery += " On "
cQuery += " K7FI8.FK7_FILIAL = '" + xfilial("FI8") + "' "
cQuery += " AND K7FI8.FK7_ALIAS = 'SE2' "
cQuery += " AND K7FI8.FK7_CHAVE = E2DEST.E2_FILIAL || '|' || E2DEST.E2_PREFIXO || '|' || E2DEST.E2_NUM || '|' || E2DEST.E2_PARCELA || '|' || E2DEST.E2_TIPO || '|' || E2DEST.E2_FORNECE || '|' || E2DEST.E2_LOJA "
cQuery += " AND K7FI8.D_E_L_E_T_ = ' ' "

cQuery += " LEFT Join " + cSqlfk2 + " FK2DES "
cQuery += " On "
cQuery += " FK2DES.FK2_FILIAL = '" + xfilial("FK2") + "' "
cQuery += " AND FK2DES.FK2_IDDOC = K7FI8.FK7_IDDOC "
If ( FK2->(FieldPos("FK2_DTDISP")) > 0 ) .AND. lMvDisp
	cQuery += " AND FK2DES.FK2_DTDISP > '" + dtos(dDatRef) + "' "
else
	cQuery += " AND FK2DES.FK2_DATA > '" + dtos(dDatRef) + "' "
endif
cquery += " AND FK2DES.FK2_TPDOC = 'VL' "
cQuery += " AND FK2DES.D_E_L_E_T_ = ' ' "

// Composição dos Itens da Guia		
cQuery += " INNER JOIN " + RetSqlName("BD7") + " BD7 " 
cQuery += "    ON BD7_FILIAL = '" + xFilial("BD7") + "' "
cQuery += "   AND BD7_CHKSE2 = SE2.E2_FILIAL || '|' || SE2.E2_PREFIXO || '|' || SE2.E2_NUM || '|' || SE2.E2_PARCELA || '|' || SE2.E2_TIPO || '|' || SE2.E2_FORNECE || '|' || SE2.E2_LOJA " //K7FI8.FK7_CHAVE "
cQuery += "   AND BD7_DTDIGI <= '" + DtoS(MV_PAR01) + "' "
If MV_PAR03 <> MV_PAR04
	cQuery += "   AND BD7_CODEMP >= '" + MV_PAR03 + "' "
	cQuery += "   AND BD7_CODEMP <= '" + MV_PAR04 + "' "
else
	cQuery += "   AND BD7_CODEMP = '" + MV_PAR03 + "' "
endIf
cQuery += "   AND BD7.D_E_L_E_T_ = ' ' "

If MV_PAR06 == 4
	cQuery	+= " AND BD7.BD7_CODRDA = '" + cRDASUS + "' "
else
	if !empty(MV_PAR07)
		cQuery	+= " AND BD7.BD7_CODRDA >= '" + MV_PAR07 + "' "
	endIf
	if !empty(MV_PAR08) .AND. UPPER(MV_PAR08) <>  "ZZZZZZ"
		cQuery	+= " AND BD7.BD7_CODRDA <= '" + MV_PAR08 + "' "
	endIf
EndIf

cQuery += " AND BD7_BLOPAG <> '1' "
If MV_PAR06 == 2
	cQuery	+= "   AND BD7_TIPGUI <> '04' "
endIf

cQuery	+= " INNER JOIN " + RetSqlName("BT5") + " BT5 "
cQuery	+= "  ON BT5_FILIAL = BD7.BD7_FILIAL " 
cQuery	+= " AND BT5_CODINT = BD7.BD7_CODOPE "
cQuery	+= " AND BT5_CODIGO = BD7.BD7_CODEMP "
cQuery	+= " AND BT5_NUMCON = BD7.BD7_CONEMP "
cQuery	+= " AND BT5_VERSAO = BD7.BD7_VERCON "
cQuery	+= " AND BT5.D_E_L_E_T_ = ' ' "

If MV_PAR06 == 2
	cQuery	+= " AND BT5_INTERC = '1' "
else
	cQuery	+= " AND BT5_INTERC <> '1' "
endIf

cQuery	+= " LEFT JOIN "+retsqlName("SX5")+" SX5YR  "
cQuery	+= "   ON X5_FILIAL = ' '  "
cQuery	+= "  AND X5_TABELA = 'YR'  "
cQuery	+= "  AND X5_CHAVE = BD7.BD7_TPEVCT  "
cQuery	+= "  AND SX5YR.D_E_L_E_T_ = ' ' "

////se for somente saúde ocupacional (mv_par06 = 3) vou economizar processamento já filtrando os BD5 aqui pra não precisar de skip depois
// Cabeçalho das Guias
if MV_PAR06 == 3
	cQuery	+= " INNER JOIN "+RetSqlName("BD5")+" BD5 " 
	cQuery	+= "  ON BD5_FILIAL = '"+xFilial('BD5')+"' "
	cQuery	+= " AND BD5_CODOPE = BD7.BD7_CODOPE "
	cQuery	+= " AND BD5_CODLDP = BD7.BD7_CODLDP "
	cQuery	+= " AND BD5_CODPEG = BD7.BD7_CODPEG "
	cQuery	+= " AND BD5_NUMERO = BD7.BD7_NUMERO "
	cQuery	+= " AND BD5_SITUAC = BD7.BD7_SITUAC "
	cQuery	+= " AND BD5_FASE   = BD7.BD7_FASE   "
	cQuery	+= " AND BD5_DATPRO = BD7.BD7_DATPRO "
	cQuery	+= " AND BD5_OPERDA = BD7.BD7_CODOPE "
	cQuery	+= " AND BD5_CODRDA = BD7.BD7_CODRDA "
	cQuery	+= " AND BD5_TIPATE >= '14' "
	cQuery	+= " AND BD5_TIPATE <= '21' "
	cQuery	+= " AND BD5.D_E_L_E_T_ = ' ' "
endif

If MV_PAR06 == 5

	cQuery += " Inner Join " + retsqlName("BR8") + " BR8 "
	cQuery += " On "
	cQuery += " BR8_FILIAL = '" + xfilial("BR8") + "' "
	cQuery += " AND BR8_CODPAD = BD7.BD7_CODPAD "
	cQuery += " AND BR8_CODPSA = BD7.BD7_CODPRO "
	cQuery += " AND BR8_ODONTO = '1' "
	cquery += " AND BR8.D_E_L_E_T_ = ' ' "

endIf

cQuery += " WHERE SE2.E2_FILIAL  = '" + xFilial("SE2") + "' "
//cquery += " AND SE2.E2_NUM = '700174605' "
cQuery += "   AND SE2.E2_TIPO NOT IN " + formatIn(MVABATIM+"|"+MVIRABT+"|"+MVINABT,"|") //AB-|FB-|FC-|FU-|IR-|IN-|IS-|PI-|CF-|CS-|FE-|IV-//IR-//IN- 
cQuery += "   AND ( FK2DES.FK2_IDDOC IS NOT NULL OR ( FK2DES.FK2_IDDOC IS NULL AND ( E2DEST.E2_SALDO > 0 OR E2DEST.E2_BAIXA > '" + dtoS(MV_PAR01) + "') )) "
cQuery += "   AND SE2.D_E_L_E_T_ = ' ' "

//cquery += " AND SE2.E2_NUM = '700106646' "

//--------------------------------------------------------------------------------------------------
//Executa ponto de entrada para Complemento de Filtro principal.  
//--------------------------------------------------------------------------------------------------         
if existblock("PLR44XP1")
	cQuery	+= execBlock("PLR44XP1",.f.,.f.,{ '442' + aTipRel[MV_PAR06] })
endIf

cQuery	+= " GROUP BY "
cQuery	+= "BD7_TIPGUI,BD7_DTDIGI,BD7_CODRDA,BD7_CODOPE,"
cQuery	+= "BD7_CODLDP,BD7_CODPEG,BD7_NUMERO,BD7_OPEUSR,"
cQuery	+= "BD7_CODEMP,BD7_MATRIC,BD7_TIPREG,SX5YR.X5_DESCRI," 
cQuery	+= "BD7_CONEMP,BD7_FASE  ,BD7_ANOPAG,BD7_MESPAG,"
cQuery	+= "BD7_CHVLA,BD7_CHVPRO,BD7_DTPAGT,"
cQuery	+= "BD7_DTCTBF,BD7_ORIMOV,BD7_PROTOC," 
cQuery	+= "SE2.R_E_C_N_O_,E2DEST.R_E_C_N_O_,BD7_DATPRO "
//---

cQuery += " ) Z "
cQuery += " Where BD7TVLRPAG > 0 "
cQuery	+= " ORDER BY SE2Recno,BD7_CODOPE,BD7_CODLDP,BD7_CODPEG,BD7_NUMERO"


If Existblock("PLR44XP3")
	cQuery := ExecBlock("PLR44XP3",.f.,.f.,{ '442'+aTipRel[MV_PAR06], cQuery } ) 
EndIf

if( select( "TRBLIV" ) > 0 )
	TRBLIV->( dbCloseArea() )
endIf

cQuery := changeQuery(cQuery)

nHandle := fCreate('c:\temp\Qry442c.sql', 0)
if nHandle > 0
	fWrite(nHandle, CHR(13)+CHR(10)+cQuery+CHR(13)+CHR(10) )
	fClose(nHandle)
endif

//conout("Antes da criação da tabela principal : " + Time())
MPSysOpenQuery(cQuery , 'TRBLIV' )
//conout("Passou criação da tabela principal : " + time())

aStruSQL := TRBLIV->( dbStruct() )

for nX := 1 to len(aStruSQL)
	if aStruSQL[nX][2] <> "C"
		tcSetField('TRBLIV' ,aStruSQL[nX][1],aStruSQL[nX][2],aStruSQL[nX][3],aStruSQL[nX][4])
	endIf	
next nX

// Elimina array
aSize(aTipRel,1)
aDel(aTipRel,1)
//conout("return função da query : " + time())
return( {.f.} )


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} fposTAux 

@author  PLS TEAM
@version P12
@since   15.11.05
/*/
//--------------------------------------------------------------------------------------------------
static function fposTAux()
local aArea 	  	:= getArea()

if BAU->(BAU_FILIAL+BAU_CODIGO) <> xFilial("BAU") + TRBLIV->BD7_CODRDA
    BAU->( msSeek( xFilial("BAU") + TRBLIV->BD7_CODRDA ) )
endIf

//Posiciona BA1 - Usuarios                                            
if BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG) <> xFilial("BA1") + TRBLIV->( BD7_OPEUSR + BD7_CODEMP + BD7_MATRIC + BD7_TIPREG  )
    BA1->( msSeek( xFilial("BA1") + TRBLIV->( BD7_OPEUSR + BD7_CODEMP + BD7_MATRIC + BD7_TIPREG ),.F. ) )
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

//Versões dos Contratos
if BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON) <> xFilial("BQB") + BQB->(BQB_CODINT+BQB_CDEMP+BQB_NUMCON+BQB_VERSAO)
	BQB->( msSeek( xFilial('BQB') + BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON) ) )
endIf	

restarea(aArea)

return 



static function plRetXY(cData)

Local csql := ""
Local nRet := 0

csql += " select SUM( Case  when FK2_TPDOC = 'ES' then FK2_VALOR else 0 END ) TOT_ES, SUM( Case  when FK2_TPDOC <> 'ES' then FK2_VALOR else 0 END ) TOT_NES from "
cSql +=  cSqlfk2 + " FK2_BX "
csql += " Inner Join "
csql +=  cSqlfk7 + " FK7_BX "
cSql += " On "
cSql += " FK7_BX.FK7_FILIAL = '" + xfilial("FK7") + "' "
cSql += " AND FK7_BX.FK7_ALIAS = 'SE2' "
csql += " AND FK7_BX.FK7_CHAVE = '" + SE2->(E2_FILIAL)+'|'+SE2->(E2_PREFIXO)+'|'+SE2->(E2_NUM)+'|'+SE2->(E2_PARCELA)+'|'+SE2->(E2_TIPO)+'|'+SE2->(E2_FORNECE)+'|'+SE2->(E2_LOJA) + "' "
cSql += " AND FK7_BX.D_E_L_E_T_ = ' ' "
cSql += " Where "
cSql += " FK2_BX.FK2_FILIAL = '" + xfilial("FK2") + "' "
cSql += " AND FK2_BX.FK2_IDDOC = FK7_BX.FK7_IDDOC "

If ( FK2->(FieldPos("FK2_DTDISP")) > 0 ) .AND. lMvDisp
	cSql += " AND FK2_BX.FK2_DTDISP <= '" + cData + "' "
	cSql += " AND FK2_BX.FK2_DTDISP <> '        '  "
else
	cSql += " AND FK2_BX.FK2_DATA <= '" + cData + "' "
endIf

cSql += " AND FK2_BX.D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TOTCMPES",.T.,.F.)

nRet := TOTCMPES->(TOT_NES) - TOTCMPES->(TOT_ES)

If nret < 0
	nRet := 0
EndIf

TOTCMPES->(DbcloseArea())

return nRet

static function fnChvCTB(cCodOpe, ccodLdp, cCodPEG, cNumero)
Local cRet := ""
Local cSql := ""

cSql += " Select BD7_CHVLA, BD7_CHVPRO from " + retsqlName("BD7")
cSql += " where "
cSql += " BD7_FILIAL = '" + xfilial("BD7") + "' "
cSql += " AND BD7_CODOPE = '" + cCodOpe + "' "
cSql += " AND BD7_CODLDP = '" + ccodLdp + "' "
cSql += " AND BD7_CODPEG = '" + cCodPEG + "' "
cSql += " AND BD7_NUMERO = '" + cNumero + "' "
cSql += " AND (BD7_CHVLA <> ' ' OR BD7_CHVPRO <> ' ')
cSql += " AND D_E_L_E_T_ = ' ' "

dbUseArea (.T., "TOPCONN", TcGenQry (,,cSql), "CHVCTB", .T., .T.)

If !(CHVCTB->(EoF()))
	cRet := iIf( empty(CHVCTB->BD7_CHVLA), CHVCTB->BD7_CHVPRO, CHVCTB->BD7_CHVLA )
endIf

CHVCTB->(dbclosearea())
return cRet

static Function blqlbq(dDatDe,dDatAte,aRetBlq,cMatric,cTipReg,cLocSib,cExcAns)
Local cQryBlq := ""
Local cStmBlq := ""
Local nRetBlq := 0
aRetBlq := {"",{"00","","00000000","00000000","","",.F.}}
nRetBlq := Len(aRetBlq)
/*
aRetBlq[1]   0=Bloqueio/1=Desbloqueio
aRetBlq[2,1] Motivo bloqueio
aRetBlq[2,2] Nivel bloqueio
aRetBlq[2,3] Data cancelamento
aRetBlq[2,4] Data reinclusao
aRetBlq[2,5] Data bloqueio
aRetBlq[2,6] Data ultimo bloqueio
aRetBlq[2,7] Interessa a ANS ?
*/

cQryBlq := " SELECT BCA_TIPO, BCA_DATA, BCA_MOTBLO, BCA_NIVBLQ FROM " + cSqlbca
cQryBlq += " WHERE BCA_FILIAL = '" + xFilial("BCA") + "' AND"
cQryBlq += " BCA_MATRIC = '" + cMatric + "' AND"
cQryBlq += " BCA_TIPREG = '" + cTipReg + "' AND"
cQryBlq += " BCA_DATA <= '" + dDatAte + "' AND " + cSqlbca + ".D_E_L_E_T_ = ' '"
cQryBlq += " ORDER BY R_E_C_N_O_"
cStmBlq := cQryBlq //ChangeQuery(cQryBlq)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cStmBlq),"TRBBLQ",.F.,.T.)

While TRBBLQ->(!Eof())
	//Caso a data do (des)bloqueio seja maior que a data final, ignoro, exceto para os usuArios com critica de exclusão BA1_LOCSIB='8'
	If TRBBLQ->BCA_DATA > dDatAte .And. cLocSib <> "8"
		TRBBLQ->(dbSkip())
		Loop
	EndIf

	If nRetBlq > 2
		aAdd(aRetBlq,"")
		aAdd(aRetBlq,{"00","","00000000","00000000","","",.F.})
		nRetBlq :=  Len(aRetBlq)
	EndIf

	aRetAns := VerifAns(TRBBLQ->BCA_NIVBLQ,TRBBLQ->BCA_MOTBLO)	//Verifico se o bloqueio interessa a ANS

	If TRBBLQ->BCA_TIPO == "0" // bloqueio

		aRetBlq[nRetBlq-1] := "0"

		If aRetAns[1]
			aRetBlq[nRetBlq,1] := aRetAns[2] // Motivo bloqueio
			aRetBlq[nRetBlq,2] := TRBBLQ->BCA_NIVBLQ
			aRetBlq[nRetBlq,3] := TRBBLQ->BCA_DATA
			aRetBlq[nRetBlq,4] := StrZero(0,8,0)
			aRetBlq[nRetBlq,5] := TRBBLQ->BCA_DATA
			aRetBlq[nRetBlq,6] := TRBBLQ->BCA_DATA
		EndIf

	Else

		aRetBlq[nRetBlq-1] := "1" // desbloqueio
		
		If aRetAns[1]
			aRetBlq[nRetBlq,1] := aRetAns[2] // Motivo desbloqueio
			aRetBlq[nRetBlq,2] := TRBBLQ->BCA_NIVBLQ
			aRetBlq[nRetBlq,3] := cExcAns
			aRetBlq[nRetBlq,4] := TRBBLQ->BCA_DATA
			aRetBlq[nRetBlq,5] := StrZero(0,11,0)
			aRetBlq[nRetBlq,6] := cExcAns
		EndIf
		aRetBlq[nRetBlq,4] := TRBBLQ->BCA_DATA

	EndIf

	aRetBlq[nRetBlq,7] := aRetAns[1] // Interessa para ANS ?
	TRBBLQ->(dbSkip())
	nRetBlq++
EndDo
TRBBLQ->(DbCloseArea())

Return aRetBlq

Static Function VerifAns(cNivel,cMotBlo)
Local lRet := .F.
Local cCod := ""

Do Case
	Case cNivel == 'U' // Nivel de Usuario
		If BG3->(dbSeek(xFilial("BG3")+cMotBlo))
			If !Empty(BG3->BG3_BLQANS)
				lRet := .T.
				cCod := StrZero(Val(BG3->BG3_BLQANS),2)
			EndIf
		EndIf
	Case cNivel == 'F' // Nivel de Familia
		If BG1->(dbSeek(xFilial("BG1")+cMotBlo))
			If !Empty(BG1->BG1_BLQANS)
				lRet := .T.
				cCod := StrZero(Val(BG1->BG1_BLQANS),2)
			EndIf
		EndIf
	Case cNivel == 'S' // Nivel de Sub-Contrato
		If BQU->(msSeek(xFilial("BQU")+cMotBlo))
			If !Empty(BQU->BQU_BLQANS)
				lRet := .T.
				cCod := StrZero(Val(BQU->BQU_BLQANS),2)
			EndIf
		EndIf
EndCase

Return({lRet,cCod})


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
