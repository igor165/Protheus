#INCLUDE "PLSR445.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"

#define REEMBOLSO   "04"

STATIC ADLei := CtoD('31/12/1999')
STATIC nsomRee := GetNewPar("MV_PLDRE44", 0)

/*/{Protheus.doc} PLSR445
Registro de Eventos Ressarcidos e Recuperados - Glosas
@author DEV
@since 05/03/2016
@version ALL
Remodelado em 2016/10/25 para atendimento a RN 390
/*/
function PLSR445()
local oReport := nil
local cPerg	  := "PLR445"


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
local dDatAte       := LastDay(dDatDe)
local aTpForn       := retSx3Box(X3CBox(Posicione('SX3' , 2 ,"BI3_TPFORN",'X3_CBOX')    ),,,1)
local aModPag       := retSx3Box(X3CBox(Posicione('SX3' , 2 ,"BI3_MODPAG",'X3_CBOX')    ),,,1)
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
oReport := TReport():new("PLSR445",cTexto,cPerg,{|oReport| ReportPrint(oReport,oBGERAL,dDatDe,dDatAte,aTpForn,aModPag,cTexto)},cTexto) //"Registro de Eventos Pagos"
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
TRCell():new(oSTITULO,"MATRIC"	,"TRBLIV", STR0049,, 17)//"Mat.Titular"
TRCell():new(oSTITULO,"INICON"	,"TRBLIV", STR0007, "@D", 10)//"Emissao"
TRCell():new(oSTITULO,"TERCON"	,"TRBLIV", STR0063, "@D", 10)//"Vct Cont"
TRcell():new(oSTITULO,"TPCONTRATO"	,"TRBLIV", "Natureza" ,"@!", 30)
TRcell():new(oSTITULO,"SEGMENTACAO"	,"TRBLIV", "Cobertura" ,"@!", 60)
TRCell():new(oSTITULO,"REGPRO"	,"TRBLIV", STR0055+STR0062,, 10) //"Nr°RegP"
TRCell():new(oSTITULO,"DTCONH"	,"TRBLIV", STR0050, PesqPict("SE5","E5_DATA"), 10) // "Dt Conhec"
TRCell():new(oSTITULO,"NOMETIT"	,"TRBLIV", STR0018,, 35)//"Nome Titular"    
TRCell():new(oSTITULO,"CNPJTIT"	,"TRBLIV", STR0017,, 20) //"CPF Titular"
TRCell():new(oSTITULO,"NOMEBEN"	,"TRBLIV", STR0051,, 35)//"Beneficiário"    
TRCell():new(oSTITULO,"DTOCORR"	,"TRBLIV", STR0052, PesqPict("SE5","E5_DATA"), 10) //"Dt Ocorr"
TRCell():new(oSTITULO,"CODPRE"	,"TRBLIV", "Prest.", "@R XXXXXX", 06)//"Prest."
TRCell():new(oSTITULO,"CNPJPR"	,"TRBLIV", STR0015+" "+STR0053,"@R 99.999.999/9999-99", 18)//"CNPJ/CPF Prest"
TRCell():new(oSTITULO,"NOMEPR"	,"TRBLIV", STR0064,, 34) // "Nome Prestador" 
TRCell():new(oSTITULO,"PFPJ"	,"TRBLIV", "PF/PJ",, 06) // "PF/PJ" 
TRCell():new(oSTITULO,"FORNECE"	,"TRBLIV", "Fornec", "@R XXXXXX", 09)//"Fornec"
TRCell():new(oSTITULO,"TIPDOC"	,"TRBLIV", STR0054, "@!", 04)//"Tp Doc"       
TRCell():new(oSTITULO,"DOCCTB"	,"TRBLIV", STR0055+" "+STR0065,"@R XXXXXX-XXX-XXXXXX", 18)//"Nr° Doc Contábil"
TRcell():new(oSTITULO,"DTCTB"	,"TRBLIV", STR0056, PesqPict("SE5","E5_DATA"), 10) // "Dt Contab"
TRCell():new(oSTITULO,"VLREVE"	,"TRBLIV", STR0019, "@E 9,999,999,999.99", 14)//"Valor"
TRCell():new(oSTITULO,"VLINPT"	,"TRBLIV", STR0057, "@E 9,999,999,999.99", 14)//"Vlr INSS Pat"
TRCell():new(oSTITULO,"VLTXPG"	,"TRBLIV", STR0058, "@E 9,999,999,999.99", 14)//"Vlr Tx Adm"
TRCell():new(oSTITULO,"VLRGLO"	,"TRBLIV", STR0076, "@E 9,999,999,999.99", 14)//"Vlr Glosa"
TRCell():new(oSTITULO,"GLINPT"	,"TRBLIV", STR0085, "@E 9,999,999,999.99", 14)//"Vlr Gl IN Pat"
TRCell():new(oSTITULO,"VLRGTX"	,"TRBLIV", STR0084, "@E 9,999,999,999.99", 14)//"Vlr Gl Tx Adm"
TRCell():new(oSTITULO,"TIPEVE"	,"TRBLIV", STR0060, "@!", 30)//"Eve"       
TRcell():new(oSTITULO,"DTALT"	,"TRBLIV", STR0061, PesqPict("SE5","E5_DATA"), 10) // "Dt Alter"
TRCell():new(oSTITULO,"DTVENC"	,"TRBLIV", STR0008, PesqPict("SE1","E1_VENCREA") , 10)//"Vencto"
TRCell():new(oSTITULO,"DTGER"	,"TRBLIV", STR0083, PesqPict("SE1","E1_EMISSAO"), 10)//"Dt Ger"

Return(oReport)



/*/{Protheus.doc} ReportPrint
Impressao

@author DEV
@since 05/03/2016
@version ALL
/*/
static function ReportPrint(oReport,OBGERAL,dDatDe,dDatAte,aTpForn,aModPag,cTexto)
local lLivro 		:= .f.
local lLog   		:= .t.
local nTmp			:= 0
local nSeq     		:= 1
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
local dDatCan       := stod("")
local aLog 	   		:= {}
local aStru			:= {}
local aFicha		:= {}
local aTmp			:= {}
local aRet			:= {}
local oSTITULO		:= oReport:section(1) 
Local cPlsCDIE		:= getNewPar("MV_PLSCDIE","1")
Local aPadProd		:= {}
Local aBauVenc		:= {}
Local cLastUser		:= ''	// Grava chave do último usuário processado
Local cLastRDA		:= ''	// Grava código do último RDA processado 
Local cLastProd		:= ''	// Grava código do último Produto (BI3)
Local nLastBD7		:= 0 
local cChaveCAB 	:= ''
local cChaveBD7		:= ''
local cTipDoc		:= ''
Local dDtVenc		:= Ctod('')
Local lEnd			:= .F.
local nTotReg		:= 0
Local cLastFam		:= ''
Local cNomTit		:= ''
Local cCpfTit		:= ''
Local cPlTpRec		:= GetNewPar("MV_PLTPREC","016")
Local cMatTit		:= ''
Local nPosBA1		:= 0
Local cTpEvCt		:= '' 
Local cBCIDtDigi	:= ""
Local cSauOcu		:= AllTrim(SuperGetMv("MV_SAUOCU",.F.,"14|15|16|17|18|19|20|21"))
Local cRDASUS		:= getNewPar("MV_RDASUS","SUS")
Local lNCLAS		:= GetNewPar("MV_PLNCLAS", .T.)
Local cInterc   	:= GetNewPar("MV_PLSGEIN","0050") 
LOCAL lUnimeds    	:= IF(AllTrim(GETNEWPAR("MV_PLSUNI","1"))=="1",.T.,.F.)
local cAliasCab		:= 'SE2'

Private cNroLvr     := "0001"
Default cTexto		:= STR0001
private cSigaadv    := Upper(AllTrim(GetPvProfString( GetEnvServer(), "StartPath", "", GetADV97() )))
private nPagina     := 0

aRet := getTrbQuery(@lLivro,@lLog,dDatDe,dDatAte,@lEnd)
If aRet[1]
    return()
EndIf

if lLivro
	if oReport:page() == 1
		oReport:setTitle(STR0024 + cNroLvr) //"LIVRO AUXILIAR NR. "
	endIf
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
BCI->(dbSetOrder(1))

nTotReg := TRBLIV->(LASTREC())
TRBLIV->(dbGotop())

//define regua
oReport:setMeter(nTotReg)
	
If !TRBLIV->(EoF())

	if empty(alias())
		dbselectarea(cAliasCab)
	endIf	

	while !oReport:cancel() .and. !TRBLIV->(eof())
		
		oReport:incMeter()

		BD7->( msGoTo( TRBLIV->BD7Recno ) )
		BD6->( msGoTo( TRBLIV->BD6Recno ) )
		
		// GUSTAVO BARCELOS - 07/02/2018 - Posiciona em BCI para buscar BCI_DTDIGI
		BCI->( DBSetOrder(1) )
		If BCI->( MSSeek( xFilial("BCI") + BD7->( BD7_CODOPE+BD7_CODLDP+BD7_CODPEG ) ) ) .AND. BD7->BD7_TIPGUI <> REEMBOLSO
			cBCIDtDigi := DtoC(BCI->BCI_DTDIGI)
		elseIf BD7->BD7_TIPGUI == REEMBOLSO
			cBCIDtDigi := BD7->BD7_DTDIGI
		Else
			cBCIDtDigi := ""
		EndIf	
		
		//posiciona no cabecalho da guia
		If cChaveCAB <> BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO)
	    	
	       	cAliasCAB := PlRetAlias( BD7->BD7_CODOPE,BD7->BD7_TIPGUI)     	          
	        cChaveCAB := BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO)
	       	  
	        (cAliasCAB)->( msSeek( cChaveCAB ) )
	        
	        //guia de reembolso
	        If BD7->BD7_TIPGUI == REEMBOLSO
			    // Se for reembolso com provisao e glosa a contabilizar, desconsiderar a glosa pulando o registro
				If Month(BD7->BD7_DTDIGI) == Month(BD7->BD7_DTCTBF)
					TRBLIV->(dbSkip())
					Loop
				EndIf
		        B44->( msSeek( xFilial("B44") + (cAliasCAB)->(BD5_OPEMOV+BD5_ANOAUT+BD5_MESAUT+BD5_NUMAUT) ) )
		        BOW->( msSeek( xFilial("BOW") + B44->B44_PROTOC ) )
	        EndIf

		    //Posiciona nas tabelas auxliares  
			fposTAux()
		    
			// DATA DE VENCIMENTO PARA O USUÁRIO
			aRetBlq	:= PLSIBBLQ(dtos(dDatAte),dtos(dDatAte),,BD7->(BD7_OPEUSR+BD7_CODEMP+BD7_MATRIC),BD7->BD7_TIPREG,BA1->BA1_LOCSIB,'')
			dTerCon	:= ctod('')
			
			if Len(aRetBlq) > 0 .and. valType("aRetBlq[Len(aRetBlq)]") == 'L'
				dTerCon	:= iIf(aRetBlq[len(aRetBlq),7], Iif(aRetBlq[len(aRetBlq)]=='0', aRetBlq[len(aRetBlq),3], aRetBlq[len(aRetBlq),4] ), ctod('') )
			endIf 		
				
			cChvGui := BD7->(BD7_CODLDP+BD7_CODPEG+BD7_NUMERO)

	    // Se for reembolso com provisao e glosa a contabilizar, desconsiderar a glosa pulando o registro
		ElseIf BD7->BD7_TIPGUI == REEMBOLSO .and. Month(BD7->BD7_DTDIGI) == Month(BD7->BD7_DTCTBF)
			
			TRBLIV->(dbSkip())
			Loop
			    
	    EndIf

		// Classificações abaixo ficam fora do if de cabeçalho porque pode rejeitar o primeiro registro		

	    // Classifica o tipo de documento
		If BD7->BD7_TIPGUI == REEMBOLSO
			cTipDoc	:= 'REM'
		ElseIf BAU->BAU_TIPPRE = cPlTpRec
			cTipDoc	:= 'RECT'	
		ElseIf cAliasCab == 'BD5' .and. !empty(BD5->BD5_TIPATE) .and. BD5->BD5_TIPATE $ cSauOcu
			cTipDoc	:= 'SO'
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
	        EndIf

		EndIf 	
		
		// Nao considera se nao conseguiu classificar
		if empty(cTipDoc)
			TRBLIV->(dbSkip())
			loop
		endIf
		
		//Se Benef.Operadoras, não deve considerar outras operadoras               
		if MV_PAR07 == 1 .and. ( (lUnimeds .and. BT5->BT5_CODIGO==cInterc) .or.(BT5->BT5_INTERC == '1') .OR. cTipDoc == 'SO' .OR. BD7->BD7_CODRDA == cRDASUS)
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

		if	BD7->BD7_TIPGUI == REEMBOLSO
			B44->(dbSetOrder(5))
			If B44->(MsSeek(xfilial("B44") + BD7->BD7_CODPEG + BD7->BD7_NUMERO))
				If BOW->(MsSeek(xfilial("BOW") + B44->B44_PROTOC))
					dDtVenc := BOW->BOW_DTDIGI + nsomRee
				endIf
			endIf
		elseIf BCI->(msseek( xfilial("BCI") + BD7->(BD7_CODOPE + BD7_CODLDP + BD7_CODPEG) ))
			dDtVenc := BCI->BCI_DATPAG
		endIf

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
			cModPag := ""
			nPos 	:= ascan(aModPag,{|x| x[2] == allTrim(BI3->BI3_MODPAG)})
			if nPos > 0 
				cModPag := allTrim(aModPag[nPos,3])
			endIf

			//data aprovacao do produto pela ans
			cADLei := Iif( BI3->BI3_DTAPPR <= ADLei, 'Antes da lei','Depois da lei' )

		EndIf
				
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

		//informacoes do titulo
		oSTITULO:init()	
		
		oSTITULO:cell("CODLDP"):setValue(BD7->BD7_CODLDP)
		If BD7->BD7_TIPGUI == REEMBOLSO
			oSTITULO:cell("NUMPRT"):setValue(BD7->BD7_PROTOC)		
		else
			oSTITULO:cell("NUMPRT"):setValue(BD7->BD7_CODPEG)		
		EndIF
		oSTITULO:cell("NUMGUI"):setValue(BD7->BD7_NUMERO)		
			
		oSTITULO:cell("CONTRATO"):setValue(BA1->(BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB))
		oSTITULO:cell("MATRIC"):setValue(cMatTit)
        oSTITULO:cell("INICON"):setValue(dIniCon)
        oSTITULO:cell("TERCON"):setValue(IIf(Empty(dTerCon), CtoD('31/12/9999'), dTerCon))
        oSTITULO:cell("DTCONH"):setValue(cBCIDtDigi)							//setValue(BD7->BD7_DTDIGI)
		
		oSTITULO:cell("NOMETIT"):setValue(cNomTit)	// posicione("BA1",1,xFilial("BA1") + BD7->(BD7_OPEUSR+BD7_CODEMP+BD7_MATRIC) + getNewPar("MV_PLTRTIT",'00'), "BA1_NOMUSR")
		oSTITULO:cell("CNPJTIT"):setValue(cCpfTit)
  		oSTITULO:cell("NOMEBEN"):setValue(BA1->BA1_NOMUSR)
  		
		oSTITULO:cell("DTOCORR"):setValue(BD7->BD7_DATPRO)
		oSTITULO:cell("CODPRE"):setValue(BD7->BD7_CODRDA)

		cCnpjPre := IIf(BD7->BD7_TIPGUI == REEMBOLSO, IIf(Empty(BOW->BOW_CODREF),cCpfTit,BOW->BOW_CODREF), BAU->BAU_CPFCGC )
		
		oSTITULO:cell("CNPJPR"):setValue( cCnpjPre )
		oSTITULO:cell("NOMEPR"):setValue(IIf(BD7->BD7_TIPGUI == REEMBOLSO, IIf(Empty(BOW->BOW_NOMREF),cNomTit,BOW->BOW_NOMREF), BAU->BAU_NOME))
		oSTITULO:cell("FORNECE"):setValue(BAU->BAU_CODSA2)
		oSTITULO:cell("TIPDOC"):setValue(cTipDoc)
		
		oSTITULO:cell("PFPJ"):setValue(IIf(Len( alltrim(cCnpjPre) ) < 14, 'PF', 'PJ' ))
		
		oSTITULO:cell("DOCCTB"):setValue(cDocCtb)
		oSTITULO:cell("DTCTB"):setValue(dDtCtb)
		
		oSTITULO:cell("VLREVE"):setValue( TRBLIV->BD7TVLRY  - TRBLIV->BD7TVLTXPG ) 
		oSTITULO:cell("VLINPT"):setValue(TRBLIV->BD7TVLINPT+TRBLIV->BD7TGLINPT)
		oSTITULO:cell("VLTXPG"):setValue( TRBLIV->BD7TVLTXPG + TRBLIV->BD7TVLRGTX )
		oSTITULO:cell("VLRGTX"):setValue(TRBLIV->BD7TVLRGTX)
		oSTITULO:cell("GLINPT"):setValue(TRBLIV->BD7TGLINPT)

		oSTITULO:cell("VLRGLO"):setValue(TRBLIV->BD7TVLRGLO)
		oSTITULO:cell("DTGER"):setValue(BD7->BD7_DTPAGT)
		oSTITULO:cell("DTVENC"):setValue(dDtVenc)
		oSTITULO:cell("TIPEVE"):setValue(cTpEvCt) 
		oSTITULO:cell("REGPRO"):setValue(cSusEp)
		oSTITULO:cell("SEGMENTACAO"):setValue(cDescSeg + " | " + cModPag + " | " + cADLei)			
		oSTITULO:cell("TPCONTRATO"):setValue( BII->BII_DESCRI )			

		oSTITULO:printLine()
		oSTITULO:finish()

	TRBLIV->(dbSkip())		
	EndDo

	oReport:endPage()
	
EndIf

//---------------------------------
//Fecha a tabela temporária 
//---------------------------------
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
static function getTrbQuery(lLivro,lLog,dDatDe,dDatAte,lEnd)
Local aFields 	:= {}
Local cAlias 	:= "TRBLIV"
Local aPadProd	:= {}
Local aBauVenc	:= {}
Local nPos		:= 0
Local aTipRel	:= { "O", "C", "M", "S", "D" }		// Tipo de Relatório: Operadora, Corresp.Assumida, N.Rel.Pl.Med.Hosp, Ressar.SUS, N.Rel.Pl.Odonto 
Local aTipEvct	:= {}
Local aSetField	:= {}
Local cWhere	:= '' 
Local cRDASUS	:= getNewPar("MV_RDASUS","SUS")
Local cCampo1	:= ''
Local cPlTpRec	:= GetNewPar("MV_PLTPREC","016")
Local nX		:= 0
Local cQuery	:= ''
Local lMsSql	:= Upper(TcGetDb()) $ "MSSQL"

if empty(MV_PAR01) .OR. Empty(MV_PAR02) .or. dDatDe > Date() 
    msgAlert(STR0042,STR0046) //"O período deve ser determinado."//"Atenção"
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
			
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa ponto de entrada para Complemento de Filtro principal.           |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Existblock("PLR44XP1")
	cWhere += ExecBlock("PLR44XP1",.f.,.f.,{ '445'+aTipRel[MV_PAR07] })
Endif
 
// Query principal na Composição dos Itens da Guia
cQuery	+= " SELECT BD7_TIPGUI,BD7_DTDIGI,BI3_CODSEG,BI3_MODPAG,BI3_DTAPPR,"
cQuery	+= "BI3_TIPCON,BD7_CODRDA,BD7_CODOPE,BD7_CODLDP,BD7_CODPEG,BD7_NUMERO,BD7_OPEUSR,BD7_CODEMP,BD7_MATRIC,BD7_TIPREG,"
cQuery	+= "BD7_TPEVCT,BD7_DATPRO,  "
cQuery	+= "BD7_FASE,MIN(BD7.R_E_C_N_O_) AS BD7Recno, "
cQuery	+= "MIN(BD6.R_E_C_N_O_) AS BD6Recno, "
cQuery	+= "SUM(BD7_VLRMAN) AS BD7TVLRMAN, "

cQuery	+= " SUM(BD7_VALORI) BD7TVLRAPR, "
cQuery	+= " SUM(BD7_VLRPAG+BD7_VLRGLO) BD7TVLRY, "

cQuery	+= "SUM(BD7_VLRPAG) AS BD7TVLRPAG, SUM(BD7_VLRTPF) AS BD7TVLRTPF, "
cQuery	+= "SUM(BD7_VLINPT) AS BD7TVLINPT, SUM(BD7_VLTXPG) AS BD7TVLTXPG,"
cQuery	+= "SUM(BD7_VLRGTX) AS BD7TVLRGTX, SUM(BD7_GLINPT) AS BD7TGLINPT,"
cQuery += " SUM(BD7_VLTXAP * BD6.BD6_QTDPRO) BD7TVTXAP, "
cQuery	+= "SUM(BD7_VLRGLO) AS BD7TVLRGLO "
cQuery	+= "FROM "+RetSqlName("BD7")+" BD7 " 
// Itens da Guia
cQuery	+= "INNER JOIN "+RetSqlName("BD6")+" BD6 " 
cQuery	+= "ON BD6_FILIAL  = '"+xFilial('BD6')+"' "
cQuery	+= "AND BD6_CODOPE = BD7.BD7_CODOPE "
cQuery	+= "AND BD6_CODLDP = BD7.BD7_CODLDP "
cQuery	+= "AND BD6_CODPEG = BD7.BD7_CODPEG "
cQuery	+= "AND BD6_NUMERO = BD7.BD7_NUMERO "
cQuery += "AND BD6_ORIMOV = BD7.BD7_ORIMOV "
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
	cQuery	+= "  ON BD5_FILIAL = '"+xFilial('BD5')+"' "
	cQuery	+= " AND BD5_CODOPE = BD7.BD7_CODOPE "
	cQuery	+= " AND BD5_CODLDP = BD7.BD7_CODLDP "
	cQuery	+= " AND BD5_CODPEG = BD7.BD7_CODPEG "
	cQuery	+= " AND BD5_NUMERO = BD7.BD7_NUMERO "
	cQuery	+= " AND BD5.D_E_L_E_T_ = ' ' "
	cQuery	+= " AND BD5_TIPATE >= '14' "
	cQuery	+= " AND BD5_TIPATE <= '21' "
endif 

If MV_PAR07 == 5
	cQuery += " Inner Join " + retsqlName("BR8") + " BR8 "
	cQuery += " On "
	cQuery += " BR8_FILIAL = '" + xfilial("BR8") + "' "
	cQuery += " AND BR8_CODPAD = BD6.BD6_CODPAD "
	cQuery += " AND BR8_CODPSA = BD6.BD6_CODPRO "
	cQuery += " AND BR8_ODONTO = '1' "
	cquery += " AND BR8.D_E_L_E_T_ = ' ' "
endIf

// Produto Saúde
cQuery	+= "LEFT JOIN "+RetSqlName("BI3")+" BI3 " 
cQuery	+= " ON BI3_FILIAL = '"+xFilial("BI3")+"' "
cQuery	+= "AND BI3_CODINT = BD7.BD7_CODOPE "
cQuery	+= "AND BI3_CODIGO = BD7.BD7_CODPLA "
cQuery	+= "AND BI3_VERSAO = '001' "
cQuery	+= "AND BI3.D_E_L_E_T_ = ' ' "

cQuery	+= " WHERE BD7_FILIAL   = '" + xFilial("BD7") + "' "
cQuery	+= "   AND BD7_CODOPE   = '" + MV_PAR03 + "' "
cQuery  += "   AND BD7_CODLDP NOT IN( '" + PLSRETLDP(9) + "', '" + PLSRETLDP(4) + "') "

If MV_PAR04 <> MV_PAR05
	cQuery += "   AND BD7_CODEMP >= '" + MV_PAR04 + "' "
	cQuery += "   AND BD7_CODEMP <= '" + MV_PAR05 + "' "
else
	cQuery += "   AND BD7_CODEMP = '" + MV_PAR04 + "' "
endIf

cQuery	+= "   AND BD7_SITUAC  = '1' "
cQuery	+= "   AND BD7.D_E_L_E_T_ = ' ' "

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

// Ultima modificacao considera glosa em todas as fases, nao somente na fase 4
cQuery	+= "AND BD7_VLRGLO+BD7_VLRGTX+BD7_GLINPT > 0 "

If MV_PAR07 == 2
	cQuery	+= "   AND BD7_TIPGUI <> '04' "
endIf
cQuery	+= "AND BD7_DTDIGI >= '"+DtoS(dDatDe)+"' "
cQuery	+= "AND BD7_DTDIGI <= '"+DtoS(dDatAte)+"' "
//cQuery += " AND BD7_ALIAUS <> 'B4R' " //Exceção de pagamento

cQuery	+= cWhere		// Adição do conteúdo do ponto de entrada, caso exista.

cQuery	+= " GROUP BY BD7_TIPGUI,BD7_DTDIGI,BI3_CODSEG,BI3_MODPAG,BI3_DTAPPR,BI3_TIPCON,BD7_CODRDA,"
cQuery	+= "BD7_CODOPE,BD7_CODLDP,BD7_CODPEG,BD7_NUMERO,BD7_OPEUSR,BD7_CODEMP,BD7_MATRIC,BD7_TIPREG,BD7_FASE,"
cQuery	+= "BD7_TPEVCT,BD7_DATPRO"
cQuery	+= " ORDER BY BD7_TIPGUI,BD7_DTDIGI,BI3_CODSEG,BI3_MODPAG,BI3_DTAPPR,BI3_TIPCON,BD7_CODRDA,BD7_CODOPE,BD7_CODLDP,"
cQuery	+= "BD7_CODPEG,BD7_NUMERO,BD7_OPEUSR,BD7_CODEMP,BD7_MATRIC,BD7_TIPREG,"
cQuery	+= "BD7_TPEVCT,BD7_DATPRO  "

//Executa ponto de entrada para filtragem específica de usuário...         
If Existblock("PLR445F7")
	cQuery := ExecBlock("PLR445F7",.f.,.f.,{ cQuery })
Endif

cQuery	:= ChangeQuery(cQuery)

MPSysOpenQuery( changeQuery(cQuery), 'TRBLIV' )

aStruSQL := TRBLIV->( dbStruct() )

for nX := 1 to len(aStruSQL)

	if aStruSQL[nX][2] <> "C"
		tcSetField('TRBLIV' ,aStruSQL[nX][1],aStruSQL[nX][2],aStruSQL[nX][3],aStruSQL[nX][4])
	endIf
	
next nX

TRBLIV->(dbGotop())

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
Local lMsSql	:= Upper(TcGetDb()) $ "MSSQL"

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