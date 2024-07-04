#INCLUDE "PLSR462.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
STATIC ADLei := CtoD('31/12/1999')
Static lOracle := "ORACLE" $ Upper(TCGetDb())  
Static asumXX	:= {}

/*/{Protheus.doc} PLSR462
Registro de Receitas a Receber 

@author DEV
@since 07/12/2016
@version ALL
Remodelado para atendimento a RN 390 - RC
/*/
Function PLSR462()
local oReport := nil
local cPerg	  := "PLR462"

Pergunte(cPerg,.t.)
			
If findFunction("TRepInUse") .And. TRepInUse()
	oReport := reportDef(cPerg)
//	//conout('Geração do relatório - pós - return 98'  + ' : ' + Time() )
	oReport:printDialog()
	//conout('Geração do relatório - pós - return 99'  + ' : ' + Time() )
//	freeObj(oReport)
Else
	msgAlert(STR0001)
EndIf
//MsgInfo("terminou")
Return

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
local oBGERAL		:= nil
local dDatDe        := MV_PAR01
local dDatAte       := MV_PAR01
local aTpForn       := retSx3Box(X3CBox(Posicione('SX3' , 2 ,"BI3_TPFORN",'X3_CBOX')    ),,,1)
local aModPag       := retSx3Box(X3CBox(Posicione('SX3' , 2 ,"BI3_MODPAG",'X3_CBOX')    ),,,1)
Local cTexto		:= STR0002+' '+STR0043

Do Case
	Case MV_PAR06 == 1
		cTexto	+= STR0040		// Operadora 	
	Case MV_PAR06 == 2
		cTexto	+= STR0041		// Coparticipacao	
	Case MV_PAR06 == 3
		cTexto	+= STR0046		// Outras Operadoras  	
	Case MV_PAR06 == 4
		cTexto	+= STR0047		// Rel.Serviço Odontológico
	Case MV_PAR06 == 5
		cTexto	+= STR0048		// Rel.Plano Med.Hospitalar  	
EndCase

//objeto report
oReport := TReport():new("PLSR462",cTexto,nil,{|oReport| ReportPrint(oReport,oBGERAL,dDatDe,dDatAte,aTpForn,aModPag,cTexto)},cTexto) //"Registro de Contraprestações Emitidas"
////conout('Geração do relatório - pós - return 0'  + ' : ' + Time() )
oReport:setTotalInLine(.f.)
oReport:setLandscape()
////conout('Geração do relatório - pós - return 1'  + ' : ' + Time() )
// Geração de listagem em PDF com totalizações
if MV_PAR05 == 1

    //celulas da sessao GERAL
    oSGERAL := TRSection():new(oReport, "GERAL", {"SE1"},,.f.,.t.)
    oSGERAL:setPageBreak(.t.)
    TRcell():new(oSGERAL,"GERAL", "TRBLIV", STR0004+":","@E 9,999,999,999.99", 16)//"Total Geral"
    
    //celulas da sessao MES/ANO
    oSMESANO := TRSection():new(oReport, "MESANO", {"SE1"},,.f.,.t.)
    TRcell():new(oSMESANO,"MESANO", "TRBLIV", STR0005+":","@R 99/9999", 07)//"Mês/Ano"
    
    //celulas da sessao SEGMODADLEI
    oSSEGMPADL := TRSection():new(oReport, "SEGMODADLEI", {"SE1"},,.f.,.t.)
    TRcell():new(oSSEGMPADL,"SEGMODADLEI","TRBLIV", STR0006+":","@!", 300)//"Cobertura, Modalidade de Pag. e Ante/Depois da Lei" 
    
    //celulas da sessao TPCONTRATO
    oSTPCONTRATO := TRSection():new(oReport, "TPCONTRATO", {"SE1"},,.f.,.t.)
    TRcell():new(oSTPCONTRATO,"TPCONTRATO","TRBLIV", STR0007+":","@!", 100)//"Natureza"
  
Else    
	// Geração do arquivo em lista
    oReport:cFontBody       := 'Courier New'
    oReport:nFontBody       := 6
    oReport:lEmptyLineExcel := .t.
    oReport:lHeaderVisible  := .f.
    oReport:onPageBreak(,.f.)
EndIf
////conout('Geração do relatório - pós - return 2'  + ' : ' + Time() )
//celulas da sessao oSTITULO
oSTITULO := TRSection():new(oReport, "TITULO", {"TRBLIV"},,.f.,.t.)
oSTITULO:setPageBreak(.F.)
oSTITULO:setLineBreak(.T.)
oSTITULO:setHeaderPage(.T.)
oSTITULO:SetAutoSize(.T.)
oSTITULO:SetHeaderSection(.T.) 

// Campos para impressão
TRCell():new(oSTITULO,"CODEMP"		,"TRBLIV", STR0008, "@R 9999", 04)//"Empresa"
TRCell():new(oSTITULO,"CONTRATO"	,"TRBLIV", STR0009+"-"+STR0010+"."+STR0011+"-"+STR0010, "@R 999999999999-999.999999999-999", 31)//"Contrato-Vers.Subcontrato-Vers"
TRCell():new(oSTITULO,"ZNCONT"		,"TRBLIV", STR0012+" "+STR0009,	"@!", 40)//"Nome"+"Contrato"    
TRCell():new(oSTITULO,"MATRIC"		,"TRBLIV", STR0013,	"@!", 17)//"Matrícula"
TRCell():new(oSTITULO,"INICON"		,"TRBLIV", STR0014, "@D", 10)//"Ini.Cont"
TRCell():new(oSTITULO,"TERCON"		,"TRBLIV", STR0015, "@D", 10)//"Term.Cont"
TRcell():new(oSTITULO,"TPCONTRATO"	,"TRBLIV", STR0016,	"@!", 30) //"Natureza" 
TRcell():new(oSTITULO,"SEGMENTACAO"	,"TRBLIV", STR0017,	"@!", 60) //"Cobertura" 
TRCell():new(oSTITULO,"NOMETIT"		,"TRBLIV", STR0012+" "+STR0018, "@!", 35)//"Nome"+"Titular"    
TRCell():new(oSTITULO,"CNPJTIT"		,"TRBLIV", STR0019+" "+STR0018, "@R 999.999.999-99", 20) //"CPF"+" "+"Titular"
TRCell():new(oSTITULO,"TIPDOC"		,"TRBLIV", STR0020, "@!", 04)//"Tipo"       
TRCell():new(oSTITULO,"PREFIXO"		,"TRBLIV", STR0036, "@!", 04)//"Pref"
TRCell():new(oSTITULO,"NUMERO"		,"TRBLIV", STR0037, "@!", 09)//"Numero"
TRCell():new(oSTITULO,"PARCELA"		,"TRBLIV", STR0035, "@!", 03)//"Parc"    
TRCell():new(oSTITULO,"DESCDOC"		,"TRBLIV", STR0033, "@!", 55)//"Descrição"       
TRcell():new(oSTITULO,"MESANO"		,"TRBLIV", STR0005,	"@R 99/9999", 07)//"Mês/Ano"
TRCell():new(oSTITULO,"VENCTO"		,"TRBLIV", STR0021, "@D", 10)//"Vct.Tit"
TRCell():new(oSTITULO,"VALOR"		,"TRBLIV", STR0022, "@E 9,999,999,999.99999", 18)//"Valor"
TRCell():new(oSTITULO,"TIPCOB"		,"TRBLIV", STR0023, "@!", 15)//"Tipo Mensal."       
TRcell():new(oSTITULO,"MESLCT"		,"TRBLIV", STR0024,	"@!", 07)//"Mês Lct"
TRcell():new(oSTITULO,"CODTIP"		,"TRBLIV", STR0050,	"@!", 08)//"Cod.Fat"
TRcell():new(oSTITULO,"PLNUCO"		,"TRBLIV", STR0051,	"@!", 12)//"Lt.Cobr."
TRcell():new(oSTITULO,"BI3_SUSEP"   ,"TRBLIV", "Número do Registro do Produto", "@!", 12)//"N° Reg ANS"
TRcell():new(oSTITULO,"PER_COB_INI"  ,"TRBLIV", "Período da cobertura - ínicio", "@D", 10) //Período da cobertura assistencial referente a contraprestação (início e término)
TRcell():new(oSTITULO,"PER_COB_FIM"  ,"TRBLIV", "Período da cobertura - fim", "@D", 10)
////conout('Geração do relatório - pós - return 3'  + ' : ' + Time() )
//Ocorrências
//oOCORRENCIAS:= TRSection():New(oReport,,{"TRB"})
//TRCell():new(oOCORRENCIAS,"DESCR" ,"TRB"	,STR0025,,500)//"Ocorrências"

// Geração em PDF com totalizações
If .F. //MV_PAR05 == 1

    //quebra/totalizadores da sessao tipo de contratacao
    oBTPCONTRATO := TRBreak():new(oSTPCONTRATO,oSTPCONTRATO:cell("TPCONTRATO"),STR0022+" "+STR0009+":",.f.)//"Valor Contrato:"   
    TRFunction():new(oSTITULO:cell("VALOR"), 'VLR_TPC', "SUM", oBTPCONTRATO,, "@E 999,999,999.99",, .f., .f.)

    //quebra/totalizadores da sessao cobertura, preco e ad da lei
    oBSEGMDADL := TRBreak():new(oSSEGMPADL,oSSEGMPADL:cell("SEGMODADLEI"),STR0026+" - "+STR0006+":",.f.)//"Sub-Total - (Cobertura, Modalidade de Pag. e Ante/Depois da Lei):"   
    TRFunction():new(oSTITULO:cell("VALOR"), 'VLR_SMA', "SUM", oBSEGMDADL,, "@E 999,999,999.99",, .f., .f.)

    //quebra/totalizadores da sessao dados mes/ano
    oBMESANO := TRBreak():new(oSMESANO,oSMESANO:cell("MESANO"), STR0027+" "+STR0005+":",.f.)//"Total Mês/Ano:"
    TRFunction():new(oSTITULO:cell("VALOR"), 'VLR_MESANO', "SUM", oBMESANO,, "@E 999,999,999.99",, .f., .f.)
    
	//quebra/totalizadores geral
    oBGERAL := TRBreak():new(oSGERAL,oSGERAL:cell("GERAL"), STR0004+":",.f.)//"Total Geral:"   
	TRFunction():new(oSTITULO:cell("VALOR"), 'VLR_GERAL', "SUM", oBGERAL,, "@E 999,999,999.99",, .f., .f.)
    
EndIf
////conout('Geração do relatório - pós - return 4'  + ' : ' + Time() )
Return(oReport)


/*/{Protheus.doc} ReportPrint
Impressao

@author DEV
@since 05/03/2016
@version ALL
/*/
static function ReportPrint(oReport,oBGERAL,dDatDe,dDatAte,aTpForn,aModPag,cTexto)
local lLivro 		:= .f.
local lLog   		:= .f.
local lFoundBI3		:= .f.
local nRecBA1		:= 0
local nTmp			:= 0
local nSeq     		:= 1
local nLog			:= 0
local cChave		:= ""
local cTipFat		:= ""
local cTmp 			:= ""	
local cMesAno		:= ""
local cSeMpADl		:= ""
local cModPag 		:= ""
local cADLei  		:= "" 
local cTipCon 		:= ""
Local cCodSeg		:= ""
local cDescSeg		:= ""
local cSusEp 		:= ""
local cNumCon		:= ""
local cNomCon		:= ""
local cCpfCnpj		:= ""
local cCodUsu		:= ""
local dIniCon		:= stod("")
local dTerCon		:= stod("")
local dRegAns 		:= stod("")
local dDatCan       := stod("")
local aLog 	   		:= {}
local aStru			:= {}
local aFicha		:= {}
local aTmp			:= {}
local aRet			:= {}
local oSGERAL		:= IIf(MV_PAR05==1, oReport:section(1), oReport:section(3))
local oSMESANO 		:= IIf(MV_PAR05==1, oReport:section(2), oReport:section(4))
local oSSEGMPADL	:= IIf(MV_PAR05==1, oReport:section(3), oReport:section(5))
local oSTPCONTRATO	:= IIf(MV_PAR05==1, oReport:section(4), oReport:section(6))
local oSTITULO		:= IIf(MV_PAR05==1, oReport:section(5), oReport:section(1)) 
local oOCORRENCIAS	:= IIf(MV_PAR05==1, oReport:section(6), oReport:section(2))
Local cPlsCDIE		:= getNewPar("MV_PLSCDIE","1")
local oTempTable	:= nil
Local lTroca		:= .F.
Local nTroca		:= 0

Local lEndIsNear	:= .F.
Local nEINPosatu	:= 0
Local nEIN			:= 0
Local aEndIsNear	:= {}
Local nAcuValor	:= 0
Local nAcuPerc	:= 0
Local cTitAtu		:= ''
Local lNG6			:= .F.
Local nPerNG6		:= 0

Default cTexto		:= STR0001
private cNroLvr     := "0001"
private cDesc1      := STR0002
private cSigaadv    := Upper(AllTrim(GetPvProfString( GetEnvServer(), "StartPath", "", GetADV97() )))
private nPagina     := 0

If ! getTrbQuery(@lLivro,@lLog,dDatDe,dDatAte, @oTempTable)
    return()
EndIf

if lLivro
	if oReport:page() == 1
		oReport:setTitle(STR0028 + cNroLvr) //"REGISTRO AUXILIAR NR. "
	endIf
endIf

oReport:onPageBreak({|| oReport:setTitle(cTexto),.T.} ) //"Registro de Contratos e Contraprestacoes Emitidas"

// Prepara Indices para utilização no loop e subfunções
BA0->(dbSetOrder(1))
BA1->(dbSetOrder(2))
BA3->(dbSetOrder(1))
BQC->(dbSetOrder(1))
SA1->(dbSetOrder(1))
BI6->(dbSetOrder(1))
BSQ->(dbSetOrder(1))
BII->(dbSetOrder(1))

//define regua

TRBLIV->(dbGoTop())

If !TRBLIV->(EoF())

	asumXX := {}
	
	If MV_PAR05 == 1
		oSGERAL:init()	
	EndIf
	
	if empty(alias())
		dbselectarea('SE1')
	endIf

	//conout('Verificação quebras dos títulos - inicio'  + ' : ' + Time() )

//	TRBLIV->(DbgoTop())
	
/*	While !TRBLIV->(eof())

//		If TRBLIV->BM1_VALOR == 0
//			TRBLIV->(dbSkip())
//			Loop
//		endIf
		//Verifica se estamos no último registro dos totais, pra tratar os casos que a soma dos proporcionais proporcionados da proporção proporcional ficam inferiores ao valor total
		lEndIsNear	:= .F.
		nEINPosatu++ 
		
		If nEINPosatu == 1
			cTitAtu := TRBLIV->NUMERO
		endIf
		
		If TRBLIV->NUMERO <> cTitAtu//( nPosSE2 <> TRBLIV->SE2Recno .and. TRBLIV->SE2Recno > 0 ) .OR. (nPosSE2ORI <> TRBLIV->RECNOTFAT .and. TRBLIV->RECNOTFAT > 0 )
			lEndIsNear := .T.
			cTitAtu := TRBLIV->NUMERO
		endIf
		If lEndIsNear
			//aadd(aEndIsNear, nEINPosatu - 1)
			TRBLIV->(RecLock("TRBLIV", .F.))
				TRBLIV->LINOK := "XX"
			TRBLIV->(MsUnLock())
		endIf
		TRBLIV->(DbSkip())	
	EndDo
*/	
	oReport:setMeter(0)
		
//	aadd(aEndIsNear, nEINPosatu )
	
	//conout('Verificação quebras dos títulos - fim'  + ' : ' + Time() )
	
	TRBLIV->(DbgoTop())
	
	//conout('Geração do relatório - início'  + ' : ' + Time() )
	
	while /*!oReport:cancel() .and.*/ !TRBLIV->(eof())
		
//		oReport:incMeter()
		
//		If TRBLIV->BM1_VALOR == 0
//			TRBLIV->(dbSkip())
//			Loop
//		endIf

//		nEIN++
//		lEndIsNear := aScan(aEndIsNear, nEIN) > 0
//		//conout('Registro'  + ' : ' + Str(nEIN) )
		nPerNG6  := BM1VLRORI / TRBLIV->E1_VALOR
		nAcuPerc += nPerNG6 //TRBLIV->BM1_VALOR / TRBLIV->E1_VALOR
		lNG6 := TRBLIV->TIPOZ == 'NG6'
		
		If TRBLIV->TIPOZ == 'NG2' .OR. TRBLIV->TIPOZ == 'NG7'//.F. //TRBLIV->TIPOZ == 'NG6'
/*			nxy := plRetXX(DtoS(MV_PAR01), TRBLIV->IDDOCZ)
			If nxy >= TRBLIV->E1_VALOR
				TRBLIV->(dbSkip())
				Loop
			else
				nTroca := TRBLIV->BM1_VALOR / TRBLIV->E1_VALOR * ( TRBLIV->E1_VALOR - nxy )
				If TRBLIV->BM1_TIPO == "2"
					nTroca := nTroca * -1
				EndIf
				lTroca := .T.
			endIf*/
			lTroca := .T.
			nTroca := TRBLIV->BM1_VALOR
		else
			lTroca	:= .F.
		EndIF
		// Valida Registro
        If Empty(TRBLIV->BG9_TIPO)
			cMsg := "Grupo Empresa (BG9) nao cadastrado."
			cMsg += "Usuario: " + TRBLIV->(BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_TIPREG)
			aadd(aLog,cMsg)
			TRBLIV->(dbSkip())
			Loop
		EndIf

	    If TRBLIV->BG9_TIPO == "1" //PF
			cTipFat := "F"     
		Else
	        If Empty(TRBLIV->BM1_CONEMP)
				cMsg := "Contrato (BT5) não cadastrado."
				cMsg += "Usuário: " + TRBLIV->(BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_TIPREG)
				aadd(aLog,cMsg)
	            TRBLIV->(dbSkip())
	        	Loop
	        Else
	            If TRBLIV->BT5_TIPOIN == cPlsCDIE
	                cTipFat := "E" // Eventual
	            ElseIf TRBLIV->BT5_TIPOIN == '02'
	                cTipFat := "R" // Repasse
	            ElseIf TRBLIV->BT5_TIPOIN == '03'
	                cTipFat := "RC" // Reciprocidade
	            Else
	                cTipFat := "J" // PJ
	            EndIf
		    EndIf
		EndIf    
 		
 		nEIN++
// 		//conout('Registro'  + ' : ' + Str(nEIN) )
 
   		If cMesAno <> TRBLIV->(BM1_MES+BM1_ANO) 

			nSeq := 1
			
			If !empty(cMesAno) .and. MV_PAR05 == 1 
				//reiniciar ar quebras por tipo de contrato, cobertura, modpag e ad lei
				cSeMpADl := ''
		 		cTipCon	 := ''
				oSTPCONTRATO:finish()
				oSSEGMPADL:finish()
				oSMESANO:finish()
			EndIf
			
			cMesAno := TRBLIV->(BM1_MES+BM1_ANO)

			If MV_PAR05 == 1 
				//inicia sessao
				oSMESANO:init()	
				//alimenta celulas
				oSMESANO:cell("MESANO"):setValue(cMesAno)
				//imprime o conteudo das celulas na linha
				oSMESANO:printLine()
			EndIf				

		EndIf
	
		//Alimenta o numero do contrato...
		do case
			case cTipFat == "F"
				cNumCon := TRBLIV->BM1_CODINT + "." + TRBLIV->BM1_CODEMP + "." + TRBLIV->BM1_MATRIC + space(16) 
				cNomCon := substr(TRBLIV->BG9_DESCRI,1,40)
			case cTipFat == "J"
				cNumCon := TRBLIV->BM1_CODINT+ "." + TRBLIV->BM1_CODEMP + "." + TRBLIV->BM1_CONEMP + "-" + TRBLIV->BM1_VERCON + "." + TRBLIV->BM1_SUBCON + "-" + TRBLIV->BM1_VERSUB 
				cNomCon := substr(TRBLIV->BQC_DESCRI,1,40)
			otherWise
				cNumCon := TRBLIV->BM1_CODINT + "." + TRBLIV->BM1_CODEMP + "." + TRBLIV->BM1_CONEMP + space(10)
				cNomCon := substr(BA0->BA0_NOMINT,1,40)
		endCase
		
		//Alimenta data de inicio e termino do contrato
		If cTipFat $ "F#J"
			dIniCon := TRBLIV->BA1_DATINC
		Else
			dIniCon := TRBLIV->BQB_DATINI
			dTerCon := IIf(Empty(dTerCon), TRBLIV->BQB_DATFIN, dTerCon)
		EndIf
			
		dRegAns	:= TRBLIV->BI3_DTAPPR
		cCodSeg := TRBLIV->BI3_CODSEG
		
		If BI6->(msSeek(xfilial('BI6')+cCodSeg))
			cDescSeg := allTrim(BI6->BI6_DESCRI)
		EndIf
			
		//1=Pre-Pagamento;2=Demais Modalidades;3=Pos-Estabelecido;4=Misto (Pre/Pos); 9=Nao Definida
		nPos := ascan(aModPag,{|x| x[2] == allTrim(TRBLIV->BI3_MODPAG)})

		cModPag := ""
		If nPos > 0 
			cModPag := allTrim(aModPag[nPos,3])
		EndIf	 
	
		//data aprovacao do produto pela ans
		cADLei := IIf( TRBLIV->BI3_DTAPPR <= ADLei, 'Antes da lei','Depois da lei' )

		If MV_PAR05 == 1
		
			If !empty(cTipCon) .and. cTipCon <> TRBLIV->BI3_TIPCON 
				cTipCon := ''		
				oSTPCONTRATO:finish()
			EndIf
			
			If !empty(cSeMpADl) .and. cSeMpADl <> cCodSeg+' - '+cModPag+' - '+cADLei			

				if !empty(cTipCon)
					oSTPCONTRATO:finish()
				endIf
				//reiniciar quebra de segmento
				cTipCon := ''
				oSSEGMPADL:finish()

			EndIf	
			
			//segregado por seguimento, modalidade de pagamento e Ad lei			
			If cSeMpADl <> cCodSeg+' - '+cModPag+' - '+cADLei

				cSeMpADl := cCodSeg+' - '+cModPag+' - '+cADLei
				//inicia sessao
				oSSEGMPADL:init()	
				//alimenta celulas
				oSSEGMPADL:cell("SEGMODADLEI"):setValue(cDescSeg + " | " + cModPag + " | " + cADLei)
				//imprime o conteudo das celulas na linha
				oSSEGMPADL:printLine()
				
			EndIf
	
			//Tipo de contrato - TPCONTRATO
			If cTipCon <> TRBLIV->BI3_TIPCON

				cTipCon := TRBLIV->BI3_TIPCON 
				//inicia sessao
				oSTPCONTRATO:init()			
				//alimenta celulas
				BII->(dbSeek(xFilial("BII") + cTipCon,.F.))
				oSTPCONTRATO:cell("TPCONTRATO"):setValue( BII->BII_DESCRI )			
				//imprime o conteudo das celulas na linha
				oSTPCONTRATO:printLine()

			EndIf

		Else

			//segregado por seguimento, modalidade de pagamento e Ad lei			
			If cSeMpADl <> cCodSeg+' - '+cModPag+' - '+cADLei
				cSeMpADl := cCodSeg+' - '+cModPag+' - '+cADLei
				cTipCon  := ''
			EndIf
		
			//Tipo de contrato - TPCONTRATO
			If cTipCon <> TRBLIV->BI3_TIPCON
				cTipCon := TRBLIV->BI3_TIPCON 
			EndIf
			
		EndIf

		cMesLct := ''		
		If TRBLIV->BM1_ALIAS == 'BSQ'
			BSQ->(dbSeek(xFilial('BSQ')+AllTrim(TRBLIV->BM1_ORIGEM),.F.))
			cMesLct := BSQ->BSQ_MES+'/'+BSQ->BSQ_ANO
		EndIf
		
		//informacoes do REGISTRO
		oSTITULO:init()	
		oSTITULO:cell("CODEMP"):setValue(TRBLIV->(BM1_CODEMP))
		oSTITULO:cell("CONTRATO"):setValue(cNumCon)
		oSTITULO:cell("ZNCONT"):setValue(cNomCon)
		oSTITULO:cell("MATRIC"):setValue(TRBLIV->(BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_TIPREG+BM1_DIGITO))
       oSTITULO:cell("INICON"):setValue(dIniCon)
       oSTITULO:cell("TERCON"):setValue(IIf(Empty(dTerCon), CtoD('31/12/2999'), dTerCon))
       oSTITULO:cell("TPCONTRATO"):setValue(BII->BII_DESCRI)
       oSTITULO:cell("SEGMENTACAO"):setValue(cSeMpADl)
		oSTITULO:cell("NOMETIT"):setValue(TRBLIV->NOMTIT)
		oSTITULO:cell("CNPJTIT"):setValue(TRBLIV->CPFTIT)
		oSTITULO:cell("TIPDOC"):setValue(TRBLIV->BM1_TIPTIT)
		oSTITULO:cell("PREFIXO"):setValue(TRBLIV->PREFIXO)
		oSTITULO:cell("NUMERO"):setValue(TRBLIV->NUMERO)
		oSTITULO:cell("PARCELA"):setValue(TRBLIV->PARCELA)
		oSTITULO:cell("DESCDOC"):setValue(TRBLIV->DESCDOC)
		oSTITULO:cell("MESANO"):setValue(cMesAno)
		oSTITULO:cell("VENCTO"):setValue(TRBLIV->VENCTO)
/*		If !lEndIsNear
			If lTroca
				oSTITULO:cell("VALOR"):setValue(noround(nTroca, 2))
				nAcuValor+= nTroca
			else
				oSTITULO:cell("VALOR"):setValue(TRBLIV->BM1_VALOR)
				nAcuValor+= TRBLIV->BM1_VALOR
			EndIf
		else
			
			If lTroca
				oSTITULO:cell("VALOR"):setValue( IIF(nTroca + nAcuValor > nAcuPerc * ( TRBLIV->E1_VALOR - nxy ), nAcuPerc * ( TRBLIV->E1_VALOR - nxy ) - nAcuValor, nTroca ) )
			else
				oSTITULO:cell("VALOR"):setValue(TRBLIV->BM1_VALOR)
			EndIf
		endIf*/
				
		oSTITULO:cell("TIPCOB"):setValue(IIf(TRBLIV->TIPCOB=='1','Participante','Patronal'))
		oSTITULO:cell("MESLCT"):setValue(cMesLct)
		oSTITULO:cell("CODTIP"):setValue(TRBLIV->BM1_CODTIP)
		oSTITULO:cell("PLNUCO"):setValue(TRBLIV->BM1_PLNUCO)
		oSTITULO:cell("BI3_SUSEP"):setValue(TRBLIV->BI3_SUSEP)
		aDatas := Perinifim(cMesano)
		oSTITULO:cell("PER_COB_INI"):setValue(aDatas[1])
		oSTITULO:cell("PER_COB_FIM"):setValue(aDatas[2])
//		oSTITULO:printLine()
//		oSTITULO:finish()

		nValXZZY := TRBLIV->BM1_VALOR
		nValYZZX := TRBLIV->E1_VALOR - TRBLIV->TOT_NES + TRBLIV->TOT_ES
//		nValZYYX := TRBLIV->E1_SALDO
		cTipCobT := TRBLIV->TIPCOB
		lIsNG3	  := TRBLIV->TIPOZ == 'NG3' .OR. TRBLIV->TIPOZ == 'NG4'
		lIsNG8   := TRBLIV->TIPOZ == 'NG8'
		
		If lIsNG8
			SE1->(DbgoTo(TRBLIV->(SE1REC)))
			nValNG8 := parparpar(0,xfilial("SE1"), TRBLIV->PREFIXO, TRBLIV->NUMERO, TRBLIV->PARCELA, TRBLIV->BM1_TIPTIT, SE1->E1_CLIENTE, SE1->E1_LOJA, /* TRBLIV->VALFI7*/ TRBLIV->BM1_VALOR, /*TRBLIV->BM1_VALOR / TRBLIV->E1_VALOR * */ /*TRBLIV->VALFI7 / TRBLIV->VALSLDPAS*/ TRBLIV->BM1_VALOR / SE1->E1_VALOR , dDatDe)
			If nValNG8 == 0
				TRBLIV->(Dbskip())
				Loop
			endIf
		//	nValNG8 := VALSLDPAS * TRBLIV->BM1_VALOR / TRBLIV->E1_VALOR * TRBLIV->VALFI7 / TRBLIV->VALNEG 
		endIf
		
		If nEIN == 1
			cTitAtu := TRBLIV->NUMERO
		endIf
		
		TRBLIV->(dbSkip())		
		
//		If TRBLIV->(EoF()) .OR. TRBLIV->NUMERO <> cTitAtu//( nPosSE2 <> TRBLIV->SE2Recno .and. TRBLIV->SE2Recno > 0 ) .OR. (nPosSE2ORI <> TRBLIV->RECNOTFAT .and. TRBLIV->RECNOTFAT > 0 )
//			lEndIsNear := .T.
//			cTitAtu := TRBLIV->NUMERO
//		endIf

		If !lEndIsNear
			If lTroca
				//oSTITULO:cell("VALOR"):setValue(noround(nTroca, 2))
				oSTITULO:cell("VALOR"):setValue(nTroca)
				nAcuValor+= nTroca
		//	elseif lNG6
		//		oSTITULO:cell("VALOR"):setValue(nValXZZY * nPerNG6)
		//		nAcuValor+= nValXZZY * nPerNG6
			elseif lIsNG8
				oSTITULO:cell("VALOR"):setValue(nValNG8)
				nAcuValor+= nValNG8
			else
				oSTITULO:cell("VALOR"):setValue(nValXZZY)
				nAcuValor+= nValXZZY
			EndIf
		else
			
			If lTroca
				//oSTITULO:cell("VALOR"):setValue( IIF(nTroca + nAcuValor > nAcuPerc * ( nValYZZX - nxy ), nAcuPerc * ( nValYZZX - nxy ) - nAcuValor, nTroca ) )
				oSTITULO:cell("VALOR"):setValue(nTroca)
			elseIf lNG6
				oSTITULO:cell("VALOR"):setValue( nAcuPerc * (nValYZZX - nAcuValor) )
			elseif lIsNG8
				oSTITULO:cell("VALOR"):setValue(nValNG8)
			else//if //lNG6
				oSTITULO:cell("VALOR"):setValue( nValXZZY  )
			//else
			//	oSTITULO:cell("VALOR"):setValue( IIF( !lIsNG3 .AND. cTipCobT == '1' .AND. nValXZZY + nAcuValor <> nValYZZX, nValXZZY + (nValYZZX - nAcuValor - nValXZZY), nValXZZY  ) )
			EndIf
		endIf

		oSTITULO:printLine()
		oSTITULO:finish()

		nSeq ++
		
		If lEndIsnear
			nAcuValor	:= 0
			nAcuPerc	:= 0
			lEndIsnear	:= .F.
		endIf
	EndDo
	
	//conout('Geração do relatório - fim' + Str(nEIN) + ' registros processados' + ' : ' + Time() )
	
	If MV_PAR05 == 1	
		oSTPCONTRATO:finish()
		oSSEGMPADL:finish()
		oSMESANO:finish()
		oSGERAL:finish()	
	EndIf

	//conout('Geração do relatório - fim - 2'  + ' : ' + Time() )
//	if  lLog .and. len(aLog) > 0
//		ocorrencias(oOcorrencias,aLog)
//	else
//		oOcorrencias:hide()
//	endIf

	//oReport:finish()
	oReport:endPage()	
	//conout('Geração do relatório - fim - 3'  + ' : ' + Time() )
EndIf
TRBLIV->(dbCloseArea())

//Exclui a tabela temporária 
oTempTable:Delete() 
//conout('Geração do relatório - fim - return'  + ' : ' + Time() )
Return

/*/{Protheus.doc} getTrbQuery
Executa query 

@author DEV
@since 05/03/2016
@version ALL
/*/
Static Function getTrbQuery(lLivro,lLog,dDatDe,dDatAte,oTempTable)
local lRet      := .f.
Local aFields 	:= {}
Local oTempTabl2:= nil
Local nI		:= 0
Local cAlias 	:= "TRBLIV"
LOCAL nQryfile 	:= 0
Local aPtoQuery	:= {}
Local aPtoTpDoc	:= {}
Local nPos		:= 0
Local aRecTit	:= 0
Local aTipRel	:= { "O", "C", "B", "D", "M" }		// Tipo de Relatório: Operadora, Coparticipação, Beneficiário Outra Operadora, Não Rel.Plano Serv.Odontológico e Não Rel.Plano Med.Hospitalar
Local cWhere	:= ''
Local aSetField := {}
local nTFilial	:= tamSX3("E1_FILIAL")[1]
local nPFilial	:= 1
local nTPrefixo	:= tamSX3("E1_PREFIXO")[1]
local nPPrefixo	:= nPFilial + nTFilial + 1
local nTNumero	:= tamSX3("E1_NUM")[1]
local nPNumero	:= nPPrefixo + nTPrefixo + 1
local nTParcela	:= tamSX3("E1_PARCELA")[1]
local nPParcela	:= nPNumero + nTNumero +  1
local nTTipo	:= tamSX3("E1_TIPO")[1]
local nPTipo	:= nPParcela + nTParcela + 1
local nTCliente	:= tamSX3("E1_CLIENTE")[1]
local nPCliente	:= nPTipo + nTTipo + 1
local nTLoja	:= tamSX3("E1_LOJA")[1]
local nPLoja	:= nPCliente + nTCliente + 1
local lMsSql	:= Upper(TcGetDb()) $ "MSSQL"
local lDtCTB	:= getNewPar("MV_PLDTREC", '0') == '0'
local cQuery	:= ""
local nStatus   := 0
local nCase     := 0
local cPtoQuery := ""
local cPtoTpDoc := ""
Local cAliUpd	:= 'UPDALI'
Local oUpdTable := nil
Local oFK5FK7	:= nil
Local cSqlBase	:= ""
Local aFiledB	:= {}
Local cAliK57 := "TPLFK57"
Local cTmpTbl := 'TMP_TRUEFK'
Local cSpaceN := space(tamsx3('E1_NUM')[1]) + space(tamsx3('E1_PARCELA')[1])

//Executa ponto de entrada para filtragem de Tipos de Cobrança...         
If Existblock("PLR46XP1")
	aPtoQuery := ExecBlock("PLR46XP1",.f.,.f.,{ '462'+aTipRel[MV_PAR06] })
Endif

//Executa ponto de entrada para Descrição de Tipos de Documento...         
If Existblock("PLR46XP2")
	aPtoTpDoc := ExecBlock("PLR46XP2",.f.,.f.,{ '462'+aTipRel[MV_PAR06] })
Endif

//Executa ponto de entrada para Complemento de Filtro no BM1...         
If Existblock("PLR46XP3")
	cWhere := ExecBlock("PLR46XP3",.f.,.f.,{ '462'+aTipRel[MV_PAR06] }) //" AND BM1_NUMTIT = '001402272' " //
//	cWhere := " AND BM1_NUMTIT = '001373329' "
//	cWhere := " AND BM1_NUMTIT IN ('000791947',  '001488549') "
Endif

/* o objetivo do TcSqlExec abaixo é substituir todo o loop por um unico update*/
For nCase := 1 to len(aPtoQuery)
	cPtoQuery += " WHEN LTRIM(RTRIM(BM1_CODTIP))='" + allTrim(aPtoQuery[nCase][1]) + "' AND LTRIM(RTRIM(BM1_CODEVE))='" + allTrim(aPtoQuery[nCase][2]) +"' THEN '" + aPtoQuery[nCase][3]+"' " + chr(10) + chr(13)
	cPtoQuery += " WHEN LTRIM(RTRIM(BM1_CODTIP))='" + allTrim(aPtoQuery[nCase][1]) + "' THEN '" + aPtoQuery[nCase][3]+"' " + chr(10) + chr(13)
next nCase

For nCase := 1 to len(aPtoTpDoc)
 	cPtoTpDoc += " WHEN LTRIM(RTRIM(BM1_TIPTIT))='" + allTrim(aPtoTpDoc[nCase][1]) +"' THEN '" + aPtoTpDoc[nCase][2]+"' " + chr(10) + chr(13)
next nCase


// Elimina array
aSize(aTipRel,1)
aDel(aTipRel,1)

if empty(MV_PAR01) .or. dDatDe > Date() 
    msgAlert(STR0029,STR0030) //"O período deve ser determinado."//"Atenção"
    Return(lRet)
endIf

if Empty(MV_PAR02)
    msgAlert(STR0031,STR0030) //"Operadora deve ser informada."//"Atenção"
    Return(lRet)
endIf

if Empty(MV_PAR03+MV_PAR04)
    msgAlert(STR0032,STR0030) //"Parametros de Empresa devem ser informados."//"Atenção"
    Return(lRet)
endIf
lRet := .T.

//Monta os campos da tabela
aadd(aFields,{"BM1_CODINT","C",04,0})
aadd(aFields,{"BM1_CODEMP","C",04,0})
aadd(aFields,{"BM1_CONEMP","C",TAMSX3("BM1_CONEMP")[1],0})
aadd(aFields,{"BM1_VERCON","C",TAMSX3("BM1_VERCON")[1],0})
aadd(aFields,{"BM1_SUBCON","C",TAMSX3("BM1_SUBCON")[1],0})
aadd(aFields,{"BM1_VERSUB","C",TAMSX3("BM1_VERSUB")[1],0})
aadd(aFields,{"BM1_MATRIC","C",TAMSX3("BM1_MATRIC")[1],0})
aadd(aFields,{"BM1_TIPREG","C",TAMSX3("BM1_TIPREG")[1],0})
aadd(aFields,{"BM1_DIGITO","C",TAMSX3("BM1_DIGITO")[1],0})
aadd(aFields,{"BA1_DATINC","D",8,0})
aadd(aFields,{"BM1_MES","C",TAMSX3("BM1_MES")[1],0})
aadd(aFields,{"BM1_ANO","C",TAMSX3("BM1_ANO")[1],0})
aadd(aFields,{"BM1_VALOR","N",TAMSX3("BM1_VALOR")[1],5})
aadd(aFields,{"BM1REG","N",16,0})
aadd(aFields,{"BM1_TIPO","C",TAMSX3("BM1_TIPO")[1],0})
aadd(aFields,{"BM1_TIPTIT","C",TAMSX3("BM1_TIPTIT")[1],0})
aadd(aFields,{"PREFIXO","C",TAMSX3("E1_PREFIXO")[1],0})
aadd(aFields,{"NUMERO","C",TAMSX3("E1_NUM")[1],0})
aadd(aFields,{"PARCELA","C",TAMSX3("E1_PARCELA")[1],0})
aadd(aFields,{"BM1_CODTIP","C",TAMSX3("BM1_CODTIP")[1],0})
aadd(aFields,{"BM1_CODEVE","C",TAMSX3("BM1_CODEVE")[1],0})
aadd(aFields,{"BM1_ALIAS","C",03,0})
aadd(aFields,{"BM1_ORIGEM","C",TAMSX3("BM1_ORIGEM")[1],0})
aadd(aFields,{"BM1_PLNUCO","C",TAMSX3("BM1_PLNUCO")[1],0})
aadd(aFields,{"BI3_DTAPPR","D",08,0})
aadd(aFields,{"BI3_CODSEG","C",TAMSX3("BI3_CODSEG")[1],0})
aadd(aFields,{"BI3_MODPAG","C",TAMSX3("BI3_MODPAG")[1],0})
aadd(aFields,{"BI3_TIPCON","C",TAMSX3("BI3_TIPCON")[1],0})
aadd(aFields,{"NOMTIT","C",TAMSX3("BA1_NOMUSR")[1],0})
aadd(aFields,{"CPFTIT","C",TAMSX3("BA1_CPFUSR")[1],0})
aadd(aFields,{"BG9_TIPO","C",TAMSX3("BG9_TIPO")[1],0})
aadd(aFields,{"BG9_DESCRI","C",TAMSX3("BG9_DESCRI")[1],0})
aadd(aFields,{"BT5_INTERC","C",TAMSX3("BT5_INTERC")[1],0})
aadd(aFields,{"BT5_TIPOIN","C",TAMSX3("BT5_TIPOIN")[1],0})
aadd(aFields,{"BQB_DATINI","D",08,0})
aadd(aFields,{"BQB_DATFIN","D",08,0})
aadd(aFields,{"BQC_DESCRI","C",TAMSX3("BQC_DESCRI")[1],0})
aadd(aFields,{"VENCTO","D",08,0})
aadd(aFields,{"E1_SALDO","N",16,2})
aadd(aFields,{"E1_VALOR","N",16,2})
aadd(aFields,{"E1_EMISSAO","D",08,0})
aadd(aFields,{"DESCDOC","C",100,0})
aadd(aFields,{"TIPCOB","C",1,0})
aadd(aFields,{"MESLCT","C",6,0})
aadd(aFields,{"VALNEG","N",16,2})
aadd(aFields,{"VALSLDPAS", "N", 16, 2})
aadd(aFields,{"TIPOZ","C",03,0})
aadd(aFields,{"LINOK","C",02,0})
aadd(aFields,{"IDDOCZ","C",32,0})
aadd(aFields,{"TOT_NES","N",16,2})
aadd(aFields,{"TOT_ES","N",16,2})
aadd(aFields,{"SE1REC","N",16,0})
aadd(aFields,{"VALFI7","N",16,2})
aadd(aFields,{"PARNEG","C",(tamsx3('E1_NUM')[1]) + (tamsx3('E1_PARCELA')[1]),0})
aadd(aFields,{"BI3_SUSEP","C",12,0})
aadd(aFields,{"BM1VLRORI","N",TAMSX3("BM1_VALOR")[1],5})

//Criação do objeto
oTempTable 	:= FWTemporaryTable():New( cAlias, aFields )
oUpdTable 	:= FWTemporaryTable():New( cAliUpd, aFields )

//oTempTable:AddIndex("indice1", {"BM1_ANO","BM1_MES","BI3_CODSEG","BI3_MODPAG","BI3_DTAPPR","BI3_TIPCON",;
//								"BM1_CODINT","BM1_CODEMP","BM1_MATRIC","BM1_TIPREG","BM1_CODTIP","BM1_CODEVE","E1_EMISSAO","NUMERO" } )
oTempTable:AddIndex("indice1", {"SE1REC" } )

oUpdTable:AddIndex("indice1", {	"BM1_ANO","BM1_MES","BI3_CODSEG","BI3_MODPAG","BI3_DTAPPR","BI3_TIPCON",;
								"BM1_CODINT","BM1_CODEMP","BM1_MATRIC","BM1_TIPREG","BM1_CODTIP","BM1_CODEVE","E1_EMISSAO","NUMERO" } )

aadd(aFiledB, {"FKA_IDPROC", "C", tamSX3("FKA_IDPROC")[1], 0})
aadd(aFiledB, {"FK5_DTDISP", "D", 8, 0})

//oFK5FK7	:= FWTemporaryTable():New( cAliK57, aFiledB )

//oFK5FK7:AddIndex("indice1", {"FKA_IDPROC" } )

//Criação da tabela
oTempTable:Create()
oUpdTable:Create()
//oFK5FK7:Create()
/*
cSqlBase := " Select FKA_IDPROC, "

if lDtCTB
	cSqlBase += " FK5_DATA "
else
	cSqlBase += " FK5_DTDISP "
endIf	
//z
cSqlBase += " from " + RetSqlName("FK5") + " FK5 "
cSqlBase += " Inner Join " + RetsqlName("FKA") + " FKA "
cSqlBase += " On "
cSqlBase += " FKA.FKA_FILIAL='" + xfilial("FKA") + "' "
cSqlBase += " AND FKA.FKA_IDORIG=FK5.FK5_IDMOV "
cSqlBase += " AND FKA.D_E_L_E_T_=' ' "
cSqlBase += " Where "
cSqlBase += " FK5.FK5_FILIAL='" + xFilial("FK5") + "' "

if lDtCTB
	cSqlBase += " AND FK5_DATA <= '" + dtos(dDatDe) + "' "
else
	cSqlBase += " AND FK5_DTDISP <= '" + dtos(dDatDe) + "' "
endIf	

cSqlBase += " AND FK5.D_E_L_E_T_=' ' "
cSqlBase += " AND FK5.FK5_TPDOC <> 'ES' "
cSqlBase += " Order By "
cSqlBase += " FKA_IDPROC "
//CriaTempFK7(cTmpTbl, dDatDe, LDTCTB)
MPSysOpenQuery( cSqlBase, 'TABFK5K7' )

dbSelectArea('TPLFK57')
Append From 'TABFK5K7'
dbGoTop()
*/
//conout('Passou pela criação da tabela base'  + ' : ' + Time() )

//Registros Sem FK5
cQuery	:= "SELECT DISTINCT BM1_CODINT,BM1_CODEMP,BM1_CONEMP,BM1_VERCON,BM1_SUBCON,BM1_VERSUB,"
cQuery	+= "BM1_MATRIC,BM1_TIPREG,BM1_DIGITO,BA1.BA1_DATINC," 
cQuery	+= "BM1_MES,BM1_ANO,BM1_VALOR, BM1.R_E_C_N_O_ AS BM1REG,"
cQuery	+= "BM1_TIPO,BM1_TIPTIT,BM1_PREFIX AS PREFIXO, BM1_NUMTIT AS NUMERO, BM1_PARCEL AS PARCELA,BM1_CODTIP,BM1_CODEVE,"
cQuery	+= "BM1_ALIAS, BM1_ORIGEM, BM1_PLNUCO,"
cQuery	+= "BI3.BI3_DTAPPR,BI3.BI3_CODSEG,BI3.BI3_MODPAG,BI3.BI3_TIPCON,"
cQuery	+= " COALESCE(TIT.BA1_NOMUSR, ' ' ) NOMTIT, COALESCE(TIT.BA1_CPFUSR, ' ') CPFTIT," 
cQuery	+= "BG9.BG9_TIPO,BG9.BG9_DESCRI,BT5.BT5_INTERC,BT5.BT5_TIPOIN,BQB.BQB_DATINI,BQB.BQB_DATFIN,COALESCE(BQC.BQC_DESCRI, ' ')," 
cQuery	+= "SE1.E1_VENCREA AS VENCTO, "	
cQuery	+= "SE1.E1_SALDO, SE1.E1_VALOR, SE1.E1_EMISSAO, SX5.X5_DESCRI AS DESCDOC,"
cQuery	+= " ' ' AS TIPCOB, '      ' AS MESLCT, 'NG1' TIPOZ, 0 VALNEG, SE1.E1_VALLIQ VALSLDPAS, COALESCE(FK1ES.FK1_TPDOC, 'OK') LINOK, ' ' IDDOCZ, 0 TOT_NES, 0 TOT_ES, SE1.R_E_C_N_O_ SE1REC, 0 VALFI7, '" + cSpaceN + "' PARNEG, BI3.BI3_SUSEP, BM1_VALOR BM1VLRORI  "

cQuery += " FROM " + RetSqlName("BM1") + " BM1 "

cQuery += " INNER JOIN " + RetSqlName("SE1") + " SE1 "
cQuery += "    ON BM1_FILIAL= '" + xFilial("BM1") + "' "
cQuery += "   AND BM1_PLNUCO=E1_PLNUCOB "
cQuery += "   AND BM1_PREFIX=E1_PREFIXO "
cQuery += "   AND BM1_NUMTIT=E1_NUM "
cQuery += "   AND BM1_PARCEL=E1_PARCELA " 
cQuery += "   AND BM1_TIPTIT=E1_TIPO " 
cQuery	+= "  AND SE1.E1_CODINT='"+MV_PAR02+"' "
cQuery	+= "  AND SE1.E1_CODEMP >= '"+MV_PAR03+"' "
cQuery	+= "  AND SE1.E1_CODEMP <= '"+MV_PAR04+"' "
cQuery	+= "  AND SE1.E1_TIPO NOT IN ('RA ','PA ',' NCC ',' NDF') "  
cQuery	+= "  AND SUBSTRING(SE1.E1_ORIGEM,1,3)='PLS' " 
cQuery	+= "  AND SE1.E1_TIPOLIQ NOT IN('LIQ','CAN','NEG') "
cQuery += "   AND SE1.E1_EMISSAO <='"+DtoS(MV_PAR01)+"' "	
cQuery += "   AND SE1.D_E_L_E_T_=' ' "

cQuery += " Inner Join " + retsqlName("FK7") + " FK7 " 
cQuery += " On "
cQuery += " FK7_FILIAL='" + xFilial("FK7") + "' "
cQuery += " AND FK7_ALIAS='SE1' "

If(SubStr(Alltrim(Upper(TCGetDb())),1,6)) == "ORACLE"
	cQuery += " AND FK7_CHAVE=SE1.E1_FILIAL||'|'||SE1.E1_PREFIXO||'|'||SE1.E1_NUM||'|'||SE1.E1_PARCELA||'|'||SE1.E1_TIPO||'|'||SE1.E1_CLIENTE||'|'||SE1.E1_LOJA" + " "
Else
	cQuery += " AND FK7_CHAVE=SE1.E1_FILIAL+'|'+SE1.E1_PREFIXO+'|'+SE1.E1_NUM+'|'+SE1.E1_PARCELA+'|'+SE1.E1_TIPO+'|'+SE1.E1_CLIENTE+'|'+SE1.E1_LOJA" + " "
Endif

cQuery += " AND FK7.D_E_L_E_T_=' ' "

cQuery += " Left Join " + retSqlName("FK1") + " FK1 "
cQuery += " On "
cQuery += " FK1.FK1_FILIAL='" + xFilial("FK1") + "' "
cQuery += " AND FK1.FK1_IDDOC=FK7.FK7_IDDOC "
if lDtCTB
	cQuery += " AND FK1_DATA=' ' "
else
	cQuery += " AND FK1_DTDISP=' ' "
endIf
//cQuery += " AND FK1.FK1_DATA > '"+ DtoS(MV_PAR01) +"' "
cQuery += " AND FK1.D_E_L_E_T_=' ' "

cQuery += " LEFT Join " + retSqlName("FK1") + " FK1ES "
cQuery += " On "
cQuery += " FK1ES.FK1_FILIAL='" + xFilial("FK1") + "' "
cQuery += " AND FK1ES.FK1_IDDOC=FK1.FK1_IDDOC "
cQuery += " AND FK1ES.FK1_IDPROC=FK1.FK1_IDPROC "
cQuery += " AND FK1ES.FK1_TPDOC='ES' "

//cQuery += " AND FK1ES.FK1_DATA > '"+DtoS(MV_PAR01)+"' "
if lDtCTB
	cQuery += " AND FK1ES.FK1_DATA <= ' ' "
else
	cQuery += " AND FK1ES.FK1_DTDISP <= ' ' "
endIf
cQuery += " AND FK1ES.D_E_L_E_T_=' ' "
/*
cQuery += " Inner Join " + RetSqlName("FKA") + " FKA "
cQuery += " On "
cQuery += " FKA_FILIAL='" + xfilial("FKA") + "' "
cQuery += " AND FKA_TABORI='FK1' "
cQuery += " AND FKA_IDORIG=FK1.FK1_IDFK1 "
cQuery += " AND FKA.D_E_L_E_T_=' ' "

cQuery += " LEFT JOIN " + oFK5FK7:getRealName() + " TrueFK57 "
cQuery += " On "
cQuery += " TrueFK57.FKA_IDPROC=FKA.FKA_IDPROC "
*/
// Família
cQuery += "INNER JOIN "+RetSqlName("BA3")+" BA3 "
cQuery += "   ON BA3_FILIAL='"+xFilial('BA3')+"' "
cQuery += "  AND BA3_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BA3_CODEMP=BM1.BM1_CODEMP "
cQuery += "  AND BA3_MATRIC=BM1.BM1_MATRIC "
cQuery += "  AND BA3.D_E_L_E_T_=' ' "

// Usuário
cQuery += "INNER JOIN "+RetSqlName("BA1")+" BA1 "
cQuery += "ON BA1_FILIAL='"+xFilial('BA1')+"' "
cQuery += "  AND BA1_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BA1_CODEMP=BM1.BM1_CODEMP "
cQuery += "  AND BA1_MATRIC=BM1.BM1_MATRIC "
cQuery += "  AND BA1_TIPREG=BM1.BM1_TIPREG "
cQuery += "  AND BA1.D_E_L_E_T_=' ' "

// Usuário Titular
cQuery += "LEFT JOIN "+RetSqlName("BA1")+" TIT "
cQuery += "ON TIT.BA1_FILIAL='"+xFilial("BA1")+"' "
cQuery += "  AND TIT.BA1_CODINT=BM1.BM1_CODINT "
cQuery += "  AND TIT.BA1_CODEMP=BM1.BM1_CODEMP "
cQuery += "  AND TIT.BA1_MATRIC=BM1.BM1_MATRIC "
cQuery += "  AND TIT.BA1_RESFAM='1' "
cQuery += " AND TIT.D_E_L_E_T_=' ' "

// Produto Saúde
cQuery += "INNER JOIN "+RetSqlName("BI3")+" BI3 "
cQuery += "ON BI3_FILIAL='"+xFilial("BI3")+"' "
cQuery += " AND BI3_CODINT=BM1.BM1_CODINT "

If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"		
	cQuery += "  AND ( BI3_CODIGO=DECODE(BA1.BA1_CODPLA, '    ', BA3.BA3_CODPLA, BA1.BA1_CODPLA) "
	cQuery += "  AND BI3_VERSAO=DECODE(BA1.BA1_VERSAO, '   ', BA3.BA3_VERSAO, BA1.BA1_VERSAO) ) "
Else
	cQuery += "  AND BI3_CODIGO=("
	cQuery += "CASE WHEN BA1.BA1_CODPLA=' ' THEN BA3.BA3_CODPLA "
	cQuery += "ELSE BA1.BA1_CODPLA END) "
	cQuery += "  AND BI3_VERSAO=("
	cQuery += "CASE WHEN BA1.BA1_VERSAO=' ' THEN BA3.BA3_VERSAO "
	cQuery += "ELSE BA1.BA1_VERSAO END) "
EndIf
cQuery += "  AND BI3.D_E_L_E_T_=' ' "

// Tabela Tipos de Títulos
cQuery += "INNER JOIN "+RetSqlName("SX5")+" SX5 "
cQuery += "ON SX5.X5_FILIAL='"+xFilial('SX5')+"' "
cQuery += "  AND SX5.X5_TABELA='05' "
cQuery += "  AND SX5.X5_CHAVE=SE1.E1_TIPO "
cQuery += "  AND SX5.D_E_L_E_T_= ' ' "

// Grupo Empresa
cQuery += "INNER JOIN "+RetSqlName("BG9")+" BG9 "
cQuery += "ON BG9_FILIAL='"+xFilial('BG9')+"' "
cQuery += "  AND BG9_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BG9_CODIGO=BM1.BM1_CODEMP "
cQuery += "  AND BG9.D_E_L_E_T_=' ' "

// Contrato
cQuery += "LEFT JOIN "+RetSqlName("BT5")+" BT5 "
cQuery += "ON BT5_FILIAL='"+xFilial('BT5')+"' "
cQuery += "  AND BT5_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BT5_CODIGO=BM1.BM1_CODEMP "
cQuery += "  AND BT5_NUMCON=BM1.BM1_CONEMP "
cQuery += "  AND BT5_VERSAO=BM1.BM1_VERCON "
cQuery += "  AND BT5.D_E_L_E_T_= ' ' "

// Versões dos Contratos
cQuery += "LEFT JOIN "+RetSqlName("BQB")+" BQB "
cQuery += "ON BQB_FILIAL='"+xFilial('BQB')+"' "
cQuery += "  AND BQB_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BQB_CDEMP=BM1.BM1_CODEMP "
cQuery += "  AND BQB_NUMCON=BM1.BM1_CONEMP "
cQuery += "  AND BQB_VERSAO=BM1.BM1_VERCON "
cQuery += "  AND BQB.D_E_L_E_T_= ' ' "

// SubContratos
cQuery += "LEFT JOIN "+RetSqlName("BQC")+" BQC "
cQuery += "ON BQC_FILIAL='"+xFilial('BQB')+"' "
cQuery += "  AND BQC_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BQC_CODEMP=BM1.BM1_CODEMP "
cQuery += "  AND BQC_NUMCON=BM1.BM1_CONEMP "
cQuery += "  AND BQC_VERCON=BM1.BM1_VERCON "
cQuery += "  AND BQC_SUBCON=BM1.BM1_SUBCON "
cQuery += "  AND BQC_VERSUB=BM1.BM1_VERSUB "
cQuery += "  AND BQC.D_E_L_E_T_=' ' "

cQuery += " WHERE "
//cQuery += " TrueFK57.FKA_IDPROC IS NULL "
cQuery += " (FK1.FK1_IDDOC IS NOT NULL OR FK1ES.FK1_IDDOC IS NOT NULL) "
cQuery	+= " AND BM1.D_E_L_E_T_=' ' "

// Filtra Lançamentos conforme retorno do ponto de entrada
If Len(aPtoQuery) > 0

	For nPos := 1 to Len(aPtoQuery)
		cQuery += IIf( nPos==1, "AND BM1_CODTIP IN('"+aPtoQuery[nPos,1], "'"+aPtoQuery[nPos,1] )
		cQuery += IIf( Len(aPtoQuery)>1, IIf(Len(aPtoQuery)==nPos,  "') ", "',"), "') ")
	Next

Else

	//Se Benef.Operadoras, filtra tipo de movimentação coparticipação          
	If MV_PAR06 == 1		// Beneficiário da Operadora 
		
		cQuery	+= "AND BM1_CODTIP IN ('101','102','103','107','108','109','110','111','113','117','118','128','129','130','131','132','133','135','136','146','180','184','186','188','189','190','191') "
		cQuery	+= "AND BT5_INTERC <> '1' "

	//Se Coparticipação, filtra tipos de movimentacao                          
	ElseIf MV_PAR06 == 2	// Coparticipação

		cQuery	+= "AND BM1_CODTIP IN ('104','116','120','121','122','123','124','125','127','134','137','138','139','140','141','142','143','144','145','147','148','149','150','151','152','153','154','155','156','157','158','159','160','161','162','163','164','165','166','167','168','169','170','171','172','173','174','175','176','177','181','185') "
		cQuery	+= "AND BT5_INTERC <> '1' "

	//Se Benef.Outras Operadoras, trata somente contratos de Intercambio.      
	ElseIf MV_PAR06 == 3

		cQuery	+= "AND BT5_INTERC='1' "

	//Se Rel.Plan.Odonto, filtra tipo de movimentação odontologico             
	ElseIf MV_PAR06 == 4 

		cQuery	+= "AND BM1_CODTIP IN ('131','132') "
		cQuery	+= "AND BT5_INTERC <> '1' "

	//Se Rel.Pl.Med.Hosp, exclui tipo de movimentação odontologico             
	ElseIf MV_PAR06 == 5 

		cQuery	+= "AND BM1_CODTIP NOT IN ('131','132') "
		cQuery	+= "AND BT5_INTERC <> '1' "

	EndIf

EndIf

cQuery	+= cWhere		// Adição do conteúdo do ponto de entrada, caso exista.
//cQuery  += " AND BM1_NUMTIT IN( 'xxxx') " //'xxxx' , 'xxxx', '000178972', '000219318', '000379560'
//cQuery  += " AND BM1_NUMTIT='001336691' "//IN('001117812', '001082331') "
//cQuery += " AND BM1_MATRIC='010696' "
//cQuery	+= "  AND BM1.D_E_L_E_T_=' ' "
//cQuery  += " AND BM1_NUMTIT IN('000942518', '001297911', '001301496', '001344814', '001294497') "

//Registros só com BM1 e SE1
cQuery += " UNION ALL "

cQuery	+= "SELECT BM1_CODINT,BM1_CODEMP,BM1_CONEMP,BM1_VERCON,BM1_SUBCON,BM1_VERSUB,"
cQuery	+= "BM1_MATRIC,BM1_TIPREG,BM1_DIGITO,BA1.BA1_DATINC," 
cQuery	+= "BM1_MES,BM1_ANO,BM1_VALOR, BM1.R_E_C_N_O_ AS BM1REG,"
cQuery	+= "BM1_TIPO,BM1_TIPTIT,BM1_PREFIX AS PREFIXO, BM1_NUMTIT AS NUMERO, BM1_PARCEL AS PARCELA,BM1_CODTIP,BM1_CODEVE,"
cQuery	+= "BM1_ALIAS, BM1_ORIGEM, BM1_PLNUCO,"
cQuery	+= "BI3.BI3_DTAPPR,BI3.BI3_CODSEG,BI3.BI3_MODPAG,BI3.BI3_TIPCON,"
cQuery	+= " COALESCE(TIT.BA1_NOMUSR, ' ' ) NOMTIT, COALESCE(TIT.BA1_CPFUSR, ' ') CPFTIT," 
cQuery	+= "BG9.BG9_TIPO,BG9.BG9_DESCRI,BT5.BT5_INTERC,BT5.BT5_TIPOIN,BQB.BQB_DATINI,BQB.BQB_DATFIN,COALESCE(BQC.BQC_DESCRI, ' ')," 
cQuery	+= "SE1.E1_VENCREA AS VENCTO, "	
cQuery	+= "SE1.E1_SALDO, SE1.E1_VALOR, SE1.E1_EMISSAO, SX5.X5_DESCRI AS DESCDOC,"
cQuery	+= " ' ' AS TIPCOB, '      ' AS MESLCT, 'NG2' TIPOZ, 0 VALNEG, SE1.E1_VALLIQ VALSLDPAS, 'OK' LINOK, ' ' IDDOCZ, 0 TOT_NES, 0 TOT_ES, SE1.R_E_C_N_O_ SE1REC, 0 VALFI7, '" + cSpaceN + "' PARNEG, BI3.BI3_SUSEP, BM1_VALOR BM1VLRORI   "

cQuery += " FROM " + RetSqlName("BM1") + " BM1 "

cQuery += " INNER JOIN " + RetSqlName("SE1") + " SE1 "
cQuery += "    ON BM1_FILIAL= '" + xFilial("BM1") + "' "
cQuery += "   AND BM1_PLNUCO=E1_PLNUCOB "
cQuery += "   AND BM1_PREFIX=E1_PREFIXO "
cQuery += "   AND BM1_NUMTIT=E1_NUM "
cQuery += "   AND BM1_PARCEL=E1_PARCELA " 
cQuery += "   AND BM1_TIPTIT=E1_TIPO " 
cQuery += "   AND SE1.E1_CODINT='"+MV_PAR02+"' "
cQuery += "   AND SE1.E1_CODEMP >= '"+MV_PAR03+"' "
cQuery += "   AND SE1.E1_CODEMP <= '"+MV_PAR04+"' "
cQuery += "   AND SE1.E1_TIPO NOT IN ('RA ','PA ',' NCC ',' NDF') "  
cQuery += "   AND SUBSTRING(SE1.E1_ORIGEM,1,3)='PLS' " 
cQuery += "   AND SE1.E1_TIPOLIQ NOT IN('LIQ','CAN','NEG') "
cQuery += "   AND E1_EMISSAO <='"+DtoS(MV_PAR01)+"' "	
cQuery += "   AND SE1.D_E_L_E_T_=' ' "

cQuery += " Left Join " + retsqlName("FK7") + " FK7 " 
cQuery += " On "
cQuery += " FK7_FILIAL='" + xFilial("FK7") + "' "
cQuery += " AND FK7_ALIAS='SE1' "

If(SubStr(Alltrim(Upper(TCGetDb())),1,6)) == "ORACLE"
	cQuery += " AND FK7_CHAVE=SE1.E1_FILIAL" + "||'|'||" + "SE1.E1_PREFIXO" + "||'|'||" + "SE1.E1_NUM" + "||'|'||" + "SE1.E1_PARCELA" + "||'|'||" + "SE1.E1_TIPO" + "||'|'||" + "SE1.E1_CLIENTE" + "||'|'||" + "SE1.E1_LOJA" + " "
Else
	cQuery += " AND FK7_CHAVE=SE1.E1_FILIAL" + "+'|'+" + "SE1.E1_PREFIXO" + "+'|'+" + "SE1.E1_NUM" + "+'|'+" + "SE1.E1_PARCELA" + "+'|'+" + "SE1.E1_TIPO" + "+'|'+" + "SE1.E1_CLIENTE" + "+'|'+" + "SE1.E1_LOJA" + " "
Endif

cQuery += " AND FK7.D_E_L_E_T_=' ' "

cQuery += " Left Join " + retSqlName("FK1") + " FK1 "
cQuery += " On "
cQuery += " FK1_FILIAL='" + xFilial("FK1") + "' "
cQuery += " AND FK1_IDDOC=FK7.FK7_IDDOC "
cQuery += " AND FK1.D_E_L_E_T_=' ' "

// Família
cQuery += "INNER JOIN "+RetSqlName("BA3")+" BA3 "
cQuery += "   ON BA3_FILIAL='"+xFilial('BA3')+"' "
cQuery += "  AND BA3_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BA3_CODEMP=BM1.BM1_CODEMP "
cQuery += "  AND BA3_MATRIC=BM1.BM1_MATRIC "
cQuery += "  AND BA3.D_E_L_E_T_=' ' "

// Usuário
cQuery += "INNER JOIN "+RetSqlName("BA1")+" BA1 "
cQuery += "ON BA1_FILIAL='"+xFilial('BA1')+"' "
cQuery += "  AND BA1_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BA1_CODEMP=BM1.BM1_CODEMP "
cQuery += "  AND BA1_MATRIC=BM1.BM1_MATRIC "
cQuery += "  AND BA1_TIPREG=BM1.BM1_TIPREG "
cQuery += "  AND BA1.D_E_L_E_T_=' ' "

// Usuário Titular
cQuery += "LEFT JOIN "+RetSqlName("BA1")+" TIT "
cQuery += "ON TIT.BA1_FILIAL='"+xFilial("BA1")+"' "
cQuery += "  AND TIT.BA1_CODINT=BM1.BM1_CODINT "
cQuery += "  AND TIT.BA1_CODEMP=BM1.BM1_CODEMP "
cQuery += "  AND TIT.BA1_MATRIC=BM1.BM1_MATRIC "
cQuery	+= "  AND TIT.BA1_RESFAM='1' "
cQuery	+= "AND TIT.D_E_L_E_T_=' ' "

// Produto Saúde
cQuery += "INNER JOIN "+RetSqlName("BI3")+" BI3 "
cQuery += "ON BI3_FILIAL='"+xFilial("BI3")+"' "
cQuery += " AND BI3_CODINT=BM1.BM1_CODINT "

If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"		
	cQuery += "  AND ( BI3_CODIGO=DECODE(BA1.BA1_CODPLA, '    ', BA3.BA3_CODPLA, BA1.BA1_CODPLA) "
	cQuery += "  AND BI3_VERSAO=DECODE(BA1.BA1_VERSAO, '   ', BA3.BA3_VERSAO, BA1.BA1_VERSAO) ) "
Else
	cQuery += "  AND BI3_CODIGO=("
	cQuery += "CASE WHEN BA1.BA1_CODPLA=' ' THEN BA3.BA3_CODPLA "
	cQuery += "ELSE BA1.BA1_CODPLA END) "
	cQuery += "  AND BI3_VERSAO=("
	cQuery += "CASE WHEN BA1.BA1_VERSAO=' ' THEN BA3.BA3_VERSAO "
	cQuery += "ELSE BA1.BA1_VERSAO END) "
EndIf

cQuery += "  AND BI3.D_E_L_E_T_=' ' "

// Tabela Tipos de Títulos
cQuery += "INNER JOIN "+RetSqlName("SX5")+" SX5 "
cQuery += "ON SX5.X5_FILIAL='"+xFilial('SX5')+"' "
cQuery += "  AND SX5.X5_TABELA='05' "
cQuery += "  AND SX5.X5_CHAVE=SE1.E1_TIPO "
cQuery += "  AND SX5.D_E_L_E_T_= ' ' "

// Grupo Empresa
cQuery += "INNER JOIN "+RetSqlName("BG9")+" BG9 "
cQuery += "ON BG9_FILIAL='"+xFilial('BG9')+"' "
cQuery += "  AND BG9_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BG9_CODIGO=BM1.BM1_CODEMP "
cQuery += "  AND BG9.D_E_L_E_T_=' ' "

// Contrato
cQuery += "LEFT JOIN "+RetSqlName("BT5")+" BT5 "
cQuery += "ON BT5_FILIAL='"+xFilial('BT5')+"' "
cQuery += "  AND BT5_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BT5_CODIGO=BM1.BM1_CODEMP "
cQuery += "  AND BT5_NUMCON=BM1.BM1_CONEMP "
cQuery += "  AND BT5_VERSAO=BM1.BM1_VERCON "
cQuery += "  AND BT5.D_E_L_E_T_= ' ' "

// Versões dos Contratos
cQuery += "LEFT JOIN "+RetSqlName("BQB")+" BQB "
cQuery += "ON BQB_FILIAL='"+xFilial('BQB')+"' "
cQuery += "  AND BQB_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BQB_CDEMP=BM1.BM1_CODEMP "
cQuery += "  AND BQB_NUMCON=BM1.BM1_CONEMP "
cQuery += "  AND BQB_VERSAO=BM1.BM1_VERCON "
cQuery += "  AND BQB.D_E_L_E_T_= ' ' "

// SubContratos
cQuery += "LEFT JOIN "+RetSqlName("BQC")+" BQC "
cQuery += "ON BQC_FILIAL='"+xFilial('BQB')+"' "
cQuery += "  AND BQC_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BQC_CODEMP=BM1.BM1_CODEMP "
cQuery += "  AND BQC_NUMCON=BM1.BM1_CONEMP "
cQuery += "  AND BQC_VERCON=BM1.BM1_VERCON "
cQuery += "  AND BQC_SUBCON=BM1.BM1_SUBCON "
cQuery += "  AND BQC_VERSUB=BM1.BM1_VERSUB "
cQuery += "  AND BQC.D_E_L_E_T_=' ' "

cQuery += " WHERE "
cQuery += " FK1_IDDOC IS NULL "

// Filtra Lançamentos conforme retorno do ponto de entrada
If Len(aPtoQuery) > 0

	For nPos := 1 to Len(aPtoQuery)
		cQuery += IIf( nPos==1, "AND BM1_CODTIP IN('"+aPtoQuery[nPos,1], "'"+aPtoQuery[nPos,1] )
		cQuery += IIf( Len(aPtoQuery)>1, IIf(Len(aPtoQuery)==nPos,  "') ", "',"), "') ")
	Next

Else

	//Se Benef.Operadoras, filtra tipo de movimentação coparticipação          
	If MV_PAR06 == 1		// Beneficiário da Operadora 

		cQuery	+= "AND BM1_CODTIP IN ('101','102','103','107','108','109','110','111','113','117','118','128','129','130','131','132','133','135','136','146','180','184','186','188','189','190','191') "
		cQuery	+= "AND BT5_INTERC <> '1' "

	//Se Coparticipação, filtra tipos de movimentacao                          
	ElseIf MV_PAR06 == 2	// Coparticipação

		cQuery	+= "AND BM1_CODTIP IN ('104','116','120','121','122','123','124','125','127','134','137','138','139','140','141','142','143','144','145','147','148','149','150','151','152','153','154','155','156','157','158','159','160','161','162','163','164','165','166','167','168','169','170','171','172','173','174','175','176','177','181','185') "
		cQuery	+= "AND BT5_INTERC <> '1' "

	//Se Benef.Outras Operadoras, trata somente contratos de Intercambio.      
	ElseIf MV_PAR06 == 3

		cQuery	+= "AND BT5_INTERC='1' "

	//Se Rel.Plan.Odonto, filtra tipo de movimentação odontologico             
	ElseIf MV_PAR06 == 4 

		cQuery	+= "AND BM1_CODTIP IN ('131','132') "
		cQuery	+= "AND BT5_INTERC <> '1' "

	//Se Rel.Pl.Med.Hosp, exclui tipo de movimentação odontologico             
	ElseIf MV_PAR06 == 5 

		cQuery	+= "AND BM1_CODTIP NOT IN ('131','132') "
		cQuery	+= "AND BT5_INTERC <> '1' "

	EndIf

EndIf

cQuery	+= cWhere		// Adição do conteúdo do ponto de entrada, caso exista.
//cQuery  += " AND BM1_NUMTIT IN( 'xxxx') "//cQuery  += " AND BM1_NUMTIT ='001117772' "
//cQuery  += " AND BM1_NUMTIT='001336691' "//cQuery  += " AND BM1_NUMTIT  IN('001117812', '001082331') "
//cQuery += " AND BM1_MATRIC='010696' "
cQuery	+= "  AND BM1.D_E_L_E_T_=' ' "
//cQuery  += " AND BM1_NUMTIT IN('001077347') "

//Registros negociados e renegociados
cQuery += " UNION ALL "

cQuery	+= "SELECT DISTINCT BM1_CODINT,BM1_CODEMP,BM1_CONEMP,BM1_VERCON,BM1_SUBCON,BM1_VERSUB,"
cQuery	+= "BM1_MATRIC,BM1_TIPREG,BM1_DIGITO,BA1.BA1_DATINC," 
cQuery	+= "BM1_MES,BM1_ANO,BM1_VALOR, BM1.R_E_C_N_O_ AS BM1REG,"
cQuery	+= "BM1_TIPO,BM1_TIPTIT,BM1_PREFIX AS PREFIXO, BM1_NUMTIT AS NUMERO, BM1_PARCEL AS PARCELA,BM1_CODTIP,BM1_CODEVE,"
cQuery	+= "BM1_ALIAS, BM1_ORIGEM, BM1_PLNUCO,"
cQuery	+= "BI3.BI3_DTAPPR,BI3.BI3_CODSEG,BI3.BI3_MODPAG,BI3.BI3_TIPCON,"
cQuery	+= " COALESCE(TIT.BA1_NOMUSR, ' ' ) NOMTIT, COALESCE(TIT.BA1_CPFUSR, ' ') CPFTIT," 
cQuery	+= "BG9.BG9_TIPO,BG9.BG9_DESCRI,BT5.BT5_INTERC,BT5.BT5_TIPOIN,BQB.BQB_DATINI,BQB.BQB_DATFIN,COALESCE(BQC.BQC_DESCRI, ' ')," 
cQuery	+= "SE1.E1_VENCREA AS VENCTO, "	
cQuery	+= "SE1_NEG.E1_SALDO, SE1.E1_VALOR, SE1.E1_EMISSAO, SX5.X5_DESCRI AS DESCDOC,"
cQuery	+= " ' ' AS TIPCOB, '      ' AS MESLCT, 'NG3' TIPOZ, SE1_NEG.E1_VALOR VALNEG, "

//SE1.E1_VALLIQ 
//---
cQuery += "( Select SUM(FI7_VALOR) VALSLDPAS "
cQuery += " From "  + RetsqlName("FI7") + " FI7 "
cQuery += " Where "
cQuery += " FI7_FILIAL=SE1.E1_FILIAL "
cQuery += " AND FI7_PRFORI=SE1.E1_PREFIXO "
cQuery += " AND FI7_NUMORI=SE1.E1_NUM "
cQuery += " AND FI7_PARORI=SE1.E1_PARCELA "
cQuery += " AND FI7_TIPORI=SE1.E1_TIPO "
cQuery += " AND FI7_CLIORI=SE1.E1_CLIENTE "
cQuery += " AND FI7_LOJORI=SE1.E1_LOJA "
cQuery += " AND FI7.D_E_L_E_T_=' ' ) "
//----
cQuery += " VALSLDPAS, 'OK' LINOK, ' ' IDDOCZ, COALESCE(J.TOT_NES, 0) TOT_NES, COALESCE(J.TOT_ES, 0) TOT_ES, SE1.R_E_C_N_O_ SE1REC, (FI7.FI7_VALOR - Case When FK1.FK1_IDDOC IS NULL then 0 else COALESCE(YU.TOT_DES, 0) - COALESCE(J.TOT_ES, 0) + COALESCE(J.TOT_NES, 0) end ) VALFI7, "+IIf(lOracle,"SE1_NEG.E1_NUM || SE1_NEG.E1_PARCELA","SE1_NEG.E1_NUM + SE1_NEG.E1_PARCELA")+" PARNEG, BI3.BI3_SUSEP, BM1_VALOR BM1VLRORI  "

cQuery += " FROM " + RetSqlName("BM1") + " BM1 "

cQuery += " INNER JOIN " + RetSqlName("SE1") + " SE1 "
cQuery += "    ON BM1_FILIAL= '" + xFilial("BM1") + "' "
cQuery += "   AND BM1_PLNUCO=E1_PLNUCOB "
cQuery += "   AND BM1_PREFIX=E1_PREFIXO "
cQuery += "   AND BM1_NUMTIT=E1_NUM "
cQuery += "   AND BM1_PARCEL=E1_PARCELA " 
cQuery += "   AND BM1_TIPTIT=E1_TIPO " 
cQuery += "   AND SE1.E1_CODINT='"+MV_PAR02+"' "
cQuery += "   AND SE1.E1_CODEMP >= '"+MV_PAR03+"' "
cQuery += "   AND SE1.E1_CODEMP <= '"+MV_PAR04+"' "
cQuery += "   AND SE1.E1_TIPO NOT IN ('RA ','PA ',' NCC ',' NDF') "  
cQuery += "   AND SUBSTRING(SE1.E1_ORIGEM,1,3)='PLS' " 
//cQuery += "   AND ( SE1.E1_BAIXA <=  '" + dtos(dDatDe) + "' ) "
cQuery += "   AND E1_EMISSAO <='"+DtoS(MV_PAR01)+"' "	
cQuery += "   AND SE1.D_E_L_E_T_=' ' "

cQuery += " Inner Join " + retsqlName("FK7") + " FK7E1 " 
cQuery += " On "
cQuery += " FK7E1.FK7_FILIAL='" + xFilial("FK7") + "' "
cQuery += " AND FK7E1.FK7_ALIAS='SE1' "

If(SubStr(Alltrim(Upper(TCGetDb())),1,6)) == "ORACLE"
	cQuery += " AND FK7E1.FK7_CHAVE=SE1.E1_FILIAL||'|'||SE1.E1_PREFIXO||'|'||SE1.E1_NUM||'|'||SE1.E1_PARCELA||'|'||SE1.E1_TIPO||'|'||SE1.E1_CLIENTE||'|'||SE1.E1_LOJA" + " "
Else
	cQuery += " AND FK7E1.FK7_CHAVE=SE1.E1_FILIAL+'|'+SE1.E1_PREFIXO+'|'+SE1.E1_NUM+'|'+SE1.E1_PARCELA+'|'+SE1.E1_TIPO+'|'+SE1.E1_CLIENTE+'|'+SE1.E1_LOJA" + " "
Endif

cQuery += " AND FK7E1.D_E_L_E_T_=' ' "

cQuery += " Inner Join " + retSqlName("FK1") + " FK1E1 "
cQuery += " On "
cQuery += " FK1E1.FK1_FILIAL='" + xFilial("FK1") + "' "
cQuery += " AND FK1E1.FK1_IDDOC=FK7E1.FK7_IDDOC "
cQuery += " AND FK1E1.FK1_DTDISP <= '" + dtos(dDatDe) + "' "
cQuery += " AND FK1E1.D_E_L_E_T_=' ' "

cQuery += "   INNER JOIN " + retSQLName("FI7") + " FI7 " 
cQuery += "      ON FI7.FI7_FILIAL=E1_FILIAL "
cQuery += "     AND FI7.FI7_PRFORI=E1_PREFIXO "
cQuery += "     AND FI7.FI7_NUMORI=E1_NUM "
cQuery += "     AND FI7.FI7_PARORI=E1_PARCELA "
cQuery += "     AND FI7.FI7_TIPORI=E1_TIPO "
cQuery += "     AND FI7.FI7_CLIORI=E1_CLIENTE "
cQuery += "     AND FI7.FI7_LOJORI=E1_LOJA "
cQuery += "     AND FI7.D_E_L_E_T_=' ' "

cQuery += " Inner Join " + retsqlName("SE1") + " SE1_NEG "
cQuery += " On "
cQuery += " SE1_NEG.E1_FILIAL=FI7.FI7_FILDES "
cQuery += " AND SE1_NEG.E1_PREFIXO=FI7.FI7_PRFDES "
cQuery += " AND SE1_NEG.E1_NUM=FI7.FI7_NUMDES "
cQuery += " AND SE1_NEG.E1_PARCELA=FI7.FI7_PARDES "
cQuery += " AND SE1_NEG.E1_TIPO=FI7.FI7_TIPDES "
cQuery += " AND SE1_NEG.E1_CLIENTE=FI7.FI7_CLIDES "
cQuery += " AND SE1_NEG.E1_LOJA=FI7.FI7_LOJDES "
cQuery += " AND SE1_NEG.E1_EMISSAO <= '" + dtos(dDatDe) + "' "
cQuery += " AND SE1_NEG.E1_TIPOLIQ NOT IN ( 'LIQ', 'NEG' ) "
cQuery += " AND SE1_NEG.D_E_L_E_T_=' ' "

cQuery += " Inner Join " + retsqlName("FK7") + " FK7 " 
cQuery += " On "
cQuery += " FK7.FK7_FILIAL='" + xFilial("FK7") + "' "
cQuery += " AND FK7.FK7_ALIAS='SE1' "

If(SubStr(Alltrim(Upper(TCGetDb())),1,6)) == "ORACLE"
	cQuery += " AND FK7.FK7_CHAVE=SE1_NEG.E1_FILIAL||'|'||SE1_NEG.E1_PREFIXO||'|'||SE1_NEG.E1_NUM||'|'||SE1_NEG.E1_PARCELA||'|'||SE1_NEG.E1_TIPO||'|'||SE1_NEG.E1_CLIENTE||'|'||SE1_NEG.E1_LOJA" + " "
Else
	cQuery += " AND FK7.FK7_CHAVE=SE1_NEG.E1_FILIAL+'|'+SE1_NEG.E1_PREFIXO+'|'+SE1_NEG.E1_NUM+'|'+SE1_NEG.E1_PARCELA+'|'+SE1_NEG.E1_TIPO+'|'+SE1_NEG.E1_CLIENTE+'|'+SE1_NEG.E1_LOJA" + " "
Endif

cQuery += " AND FK7.D_E_L_E_T_=' ' "

cQuery += " LEFT Join " + retSqlName("FK1") + " FK1 "
cQuery += " On "
cQuery += " FK1.FK1_FILIAL='" + xFilial("FK1") + "' "
cQuery += " AND FK1.FK1_IDDOC=FK7.FK7_IDDOC "
cQuery += " AND FK1.D_E_L_E_T_=' ' "

//---

cQuery += " Left Join ( "
cQuery += " select SUM( Case  when FK1_TPDOC='ES' then FK1_VALOR else 0 END ) TOT_ES, SUM( Case  when FK1_TPDOC <> 'ES' then FK1_VALOR else 0 END ) TOT_NES, FK1_IDDOC from "
cQuery += " " + retsqlName("FK1") + " "
cQuery += " Where FK1_FILIAL='" + xfilial("FK1") +  "' "
cQuery += " 	AND FK1_DTDISP <= '"+DtoS(MV_PAR01)+"' "
cQuery += " 	AND D_E_L_E_T_=' ' " 
cQuery += " group By FK1_IDDOC "
cQuery += " ) J "
cQuery += " 	On J.FK1_IDDOC=FK7.FK7_IDDOC "

cQuery += " Left Join ( "
cQuery += " select SUM( Case  when FK6_TPDOC='DC' then FK6_VALMOV else 0 END ) TOT_DES, FK1_IDDOC from "
cQuery += " " + retsqlName("FK6") + " FK6 "
cQuery += " Inner Join " + RetSqlName("FK1") + " FK1 "
cQuery += " On "
cQuery += "   FK1_FILIAL='" + xFilial("FK1") + "' "
cQuery += "   AND FK1_IDFK1=FK6.FK6_IDORIG "
cQuery += " 	AND FK1_DTDISP <= '"+DtoS(MV_PAR01)+"' "
cQuery += " Where FK6_FILIAL='" + xfilial("FK1") +  "' "
cQuery += " 	AND FK6.D_E_L_E_T_=' ' " 
cQuery += " group By FK1_IDDOC "
cQuery += " ) YU "
cQuery += " 	On YU.FK1_IDDOC=FK7.FK7_IDDOC "


//---

cQuery += " LEFT Join " + RetSqlName("FKA") + " FKA "
cQuery += " On "
cQuery += " FKA_FILIAL='" + xfilial("FKA") + "' "
cQuery += " AND FKA_TABORI='FK1' "
cQuery += " AND FKA_IDORIG=FK1.FK1_IDFK1 "
cQuery += " AND FKA.D_E_L_E_T_=' ' "
/*
cQuery += " LEFT JOIN " + oFK5FK7:getRealName() + " TrueFK57 "
cQuery += " On "
cQuery += " TrueFK57.FKA_IDPROC=FKA.FKA_IDPROC "
*/
// Família
cQuery += "INNER JOIN "+RetSqlName("BA3")+" BA3 "
cQuery += "   ON BA3_FILIAL='"+xFilial('BA3')+"' "
cQuery += "  AND BA3_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BA3_CODEMP=BM1.BM1_CODEMP "
cQuery += "  AND BA3_MATRIC=BM1.BM1_MATRIC "
cQuery += "  AND BA3.D_E_L_E_T_=' ' "

// Usuário
cQuery += "INNER JOIN "+RetSqlName("BA1")+" BA1 "
cQuery += "ON BA1_FILIAL='"+xFilial('BA1')+"' "
cQuery += "  AND BA1_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BA1_CODEMP=BM1.BM1_CODEMP "
cQuery += "  AND BA1_MATRIC=BM1.BM1_MATRIC "
cQuery += "  AND BA1_TIPREG=BM1.BM1_TIPREG "
cQuery += "  AND BA1.D_E_L_E_T_=' ' "

// Usuário Titular
cQuery += "LEFT JOIN "+RetSqlName("BA1")+" TIT "
cQuery += "ON TIT.BA1_FILIAL='"+xFilial("BA1")+"' "
cQuery += "  AND TIT.BA1_CODINT=BM1.BM1_CODINT "
cQuery += "  AND TIT.BA1_CODEMP=BM1.BM1_CODEMP "
cQuery += "  AND TIT.BA1_MATRIC=BM1.BM1_MATRIC "
cQuery	+= "  AND TIT.BA1_RESFAM='1' "
cQuery	+= "AND TIT.D_E_L_E_T_=' ' "

// Produto Saúde
cQuery += "INNER JOIN "+RetSqlName("BI3")+" BI3 "
cQuery += "ON BI3_FILIAL='"+xFilial("BI3")+"' "
cQuery += " AND BI3_CODINT=BM1.BM1_CODINT "

If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"		
	cQuery += "  AND ( BI3_CODIGO=DECODE(BA1.BA1_CODPLA, '    ', BA3.BA3_CODPLA, BA1.BA1_CODPLA) "
	cQuery += "  AND BI3_VERSAO=DECODE(BA1.BA1_VERSAO, '   ', BA3.BA3_VERSAO, BA1.BA1_VERSAO) ) "
Else
	cQuery += "  AND BI3_CODIGO=("
	cQuery += "CASE WHEN BA1.BA1_CODPLA=' ' THEN BA3.BA3_CODPLA "
	cQuery += "ELSE BA1.BA1_CODPLA END) "
	cQuery += "  AND BI3_VERSAO=("
	cQuery += "CASE WHEN BA1.BA1_VERSAO=' ' THEN BA3.BA3_VERSAO "
	cQuery += "ELSE BA1.BA1_VERSAO END) "
EndIf
cQuery += "  AND BI3.D_E_L_E_T_=' ' "

// Tabela Tipos de Títulos
cQuery += "INNER JOIN "+RetSqlName("SX5")+" SX5 "
cQuery += "ON SX5.X5_FILIAL='"+xFilial('SX5')+"' "
cQuery += "  AND SX5.X5_TABELA='05' "
cQuery += "  AND SX5.X5_CHAVE=SE1.E1_TIPO "
cQuery += "  AND SX5.D_E_L_E_T_= ' ' "

// Grupo Empresa
cQuery += "INNER JOIN "+RetSqlName("BG9")+" BG9 "
cQuery += "ON BG9_FILIAL='"+xFilial('BG9')+"' "
cQuery += "  AND BG9_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BG9_CODIGO=BM1.BM1_CODEMP "
cQuery += "  AND BG9.D_E_L_E_T_=' ' "

// Contrato
cQuery += "LEFT JOIN "+RetSqlName("BT5")+" BT5 "
cQuery += "ON BT5_FILIAL='"+xFilial('BT5')+"' "
cQuery += "  AND BT5_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BT5_CODIGO=BM1.BM1_CODEMP "
cQuery += "  AND BT5_NUMCON=BM1.BM1_CONEMP "
cQuery += "  AND BT5_VERSAO=BM1.BM1_VERCON "
cQuery += "  AND BT5.D_E_L_E_T_= ' ' "

// Versões dos Contratos
cQuery += "LEFT JOIN "+RetSqlName("BQB")+" BQB "
cQuery += "ON BQB_FILIAL='"+xFilial('BQB')+"' "
cQuery += "  AND BQB_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BQB_CDEMP=BM1.BM1_CODEMP "
cQuery += "  AND BQB_NUMCON=BM1.BM1_CONEMP "
cQuery += "  AND BQB_VERSAO=BM1.BM1_VERCON "
cQuery += "  AND BQB.D_E_L_E_T_= ' ' "

// SubContratos
cQuery += "LEFT JOIN "+RetSqlName("BQC")+" BQC "
cQuery += "ON BQC_FILIAL='"+xFilial('BQB')+"' "
cQuery += "  AND BQC_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BQC_CODEMP=BM1.BM1_CODEMP "
cQuery += "  AND BQC_NUMCON=BM1.BM1_CONEMP "
cQuery += "  AND BQC_VERCON=BM1.BM1_VERCON "
cQuery += "  AND BQC_SUBCON=BM1.BM1_SUBCON "
cQuery += "  AND BQC_VERSUB=BM1.BM1_VERSUB "
cQuery += "  AND BQC.D_E_L_E_T_=' ' "

cQuery += " WHERE "
//cQuery += " COALESCE(TRUEFK57.FKA_IDPROC, '0')='0' "
cQuery	+= "  BM1.D_E_L_E_T_=' ' "
cQuery += " AND ( FK1.FK1_IDDOC IS NULL  OR ( SE1_NEG.E1_VALOR - COALESCE(YU.TOT_DES, 0) + COALESCE(J.TOT_ES, 0) - COALESCE(J.TOT_NES, 0) > 0.01) )"
// Filtra Lançamentos conforme retorno do ponto de entrada
If Len(aPtoQuery) > 0
	For nPos := 1 to Len(aPtoQuery)
		cQuery += IIf( nPos==1, "AND BM1_CODTIP IN('"+aPtoQuery[nPos,1], "'"+aPtoQuery[nPos,1] )
		cQuery += IIf( Len(aPtoQuery)>1, IIf(Len(aPtoQuery)==nPos,  "') ", "',"), "') ")
	Next
Else

	//Se Benef.Operadoras, filtra tipo de movimentação coparticipação          
	If MV_PAR06 == 1		// Beneficiário da Operadora 

		cQuery	+= "AND BM1_CODTIP IN ('101','102','103','107','108','109','110','111','113','117','118','128','129','130','131','132','133','135','136','146','180','184','186','188','189','190','191') "
		cQuery	+= "AND BT5_INTERC <> '1' "

	//Se Coparticipação, filtra tipos de movimentacao                          
	ElseIf MV_PAR06 == 2	// Coparticipação

		cQuery	+= "AND BM1_CODTIP IN ('104','116','120','121','122','123','124','125','127','134','137','138','139','140','141','142','143','144','145','147','148','149','150','151','152','153','154','155','156','157','158','159','160','161','162','163','164','165','166','167','168','169','170','171','172','173','174','175','176','177','181','185') "
		cQuery	+= "AND BT5_INTERC <> '1' "

	//Se Benef.Outras Operadoras, trata somente contratos de Intercambio.      
	ElseIf MV_PAR06 == 3

		cQuery	+= "AND BT5_INTERC='1' "

	//Se Rel.Plan.Odonto, filtra tipo de movimentação odontologico             
	ElseIf MV_PAR06 == 4 

		cQuery	+= "AND BM1_CODTIP IN ('131','132') "
		cQuery	+= "AND BT5_INTERC <> '1' "

	//Se Rel.Pl.Med.Hosp, exclui tipo de movimentação odontologico             
	ElseIf MV_PAR06 == 5 

		cQuery	+= "AND BM1_CODTIP NOT IN ('131','132') "
		cQuery	+= "AND BT5_INTERC <> '1' "

	EndIf

EndIf

cQuery	+= cWhere		// Adição do conteúdo do ponto de entrada, caso exista.
//cQuery  += " AND BM1_NUMTIT IN( 'xxxx') "//cQuery  += " AND BM1_NUMTIT ='001117772' "
//cQuery  += " AND BM1_NUMTIT IN('001117812', '001082331') "
//cQuery  += " AND BM1_NUMTIT='001336691' "
//cQuery += " AND BM1_MATRIC='010696' "
//cQuery	+= "  AND BM1.D_E_L_E_T_=' ' "
//cQuery  += " AND BM1_NUMTIT IN('000942518', '001297911', '001301496', '001344814', '001294497') "
/*
cQuery += " UNION ALL "

cQuery	+= "SELECT BM1_CODINT,BM1_CODEMP,BM1_CONEMP,BM1_VERCON,BM1_SUBCON,BM1_VERSUB,"
cQuery	+= "BM1_MATRIC,BM1_TIPREG,BM1_DIGITO,BA1.BA1_DATINC," 
cQuery	+= "BM1_MES,BM1_ANO,BM1_VALOR, BM1.R_E_C_N_O_ AS BM1REG,"
cQuery	+= "BM1_TIPO,BM1_TIPTIT,BM1_PREFIX AS PREFIXO, BM1_NUMTIT AS NUMERO, BM1_PARCEL AS PARCELA,BM1_CODTIP,BM1_CODEVE,"
cQuery	+= "BM1_ALIAS, BM1_ORIGEM, BM1_PLNUCO,"
cQuery	+= "BI3.BI3_DTAPPR,BI3.BI3_CODSEG,BI3.BI3_MODPAG,BI3.BI3_TIPCON,"
cQuery	+= " COALESCE(TIT.BA1_NOMUSR, ' ' ) NOMTIT, COALESCE(TIT.BA1_CPFUSR, ' ') CPFTIT," 
cQuery	+= "BG9.BG9_TIPO,BG9.BG9_DESCRI,BT5.BT5_INTERC,BT5.BT5_TIPOIN,BQB.BQB_DATINI,BQB.BQB_DATFIN,BQC.BQC_DESCRI," 
cQuery	+= "SE1.E1_VENCREA AS VENCTO, "
cQuery	+= "SE1_NEG.E1_SALDO, SE1.E1_VALOR, SE1.E1_EMISSAO, SX5.X5_DESCRI AS DESCDOC,"
cQuery	+= " ' ' AS TIPCOB, '      ' AS MESLCT, 'NG4' TIPOZ, SE1_NEG.E1_VALOR VALNEG, SE1.E1_VALLIQ VALSLDPAS, 'OK' LINOK, ' ' IDDOCZ, 0 TOT_NES, 0 TOT_ES, SE1.R_E_C_N_O_ SE1REC, FI7.FI7_VALOR VALFI7, SE1_NEG.E1_NUM + SE1_NEG.E1_PARCELA PARNEG, BI3.BI3_SUSEP, BM1_VALOR BM1VLRORI  "

cQuery += " FROM " + RetSqlName("BM1") + " BM1 "

cQuery += " INNER JOIN " + RetSqlName("SE1") + " SE1 "
cQuery += "    ON BM1_FILIAL= '" + xFilial("BM1") + "' "
cQuery += "   AND BM1_PLNUCO=E1_PLNUCOB "
cQuery += "   AND BM1_PREFIX=E1_PREFIXO "
cQuery += "   AND BM1_NUMTIT=E1_NUM "
cQuery += "   AND BM1_PARCEL=E1_PARCELA " 
cQuery += "   AND BM1_TIPTIT=E1_TIPO " 
cQuery	+= "   AND SE1.E1_CODINT='"+MV_PAR02+"' "
cQuery	+= "   AND SE1.E1_CODEMP >= '"+MV_PAR03+"' "
cQuery	+= "   AND SE1.E1_CODEMP <= '"+MV_PAR04+"' "
cQuery	+= "   AND SE1.E1_TIPO NOT IN ('RA ','PA ',' NCC ',' NDF') "  
cQuery	+= "   AND SUBSTRING(SE1.E1_ORIGEM,1,3)='PLS' " 
//cQuery	+= "   AND SE1.E1_TIPOLIQ IN ( 'LIQ', 'NEG' ) "
cQuery += "   AND E1_EMISSAO <='"+DtoS(MV_PAR01)+"' "	
cQuery += "   AND SE1.D_E_L_E_T_=' ' "

cQuery += "   INNER JOIN " + retSQLName("FI7") + " FI7 " 
cQuery += "      ON FI7.FI7_FILIAL=E1_FILIAL "
cQuery += "     AND FI7.FI7_PRFORI=E1_PREFIXO "
cQuery += "     AND FI7.FI7_NUMORI=E1_NUM "
cQuery += "     AND FI7.FI7_PARORI=E1_PARCELA "
cQuery += "     AND FI7.FI7_TIPORI=E1_TIPO "
cQuery += "     AND FI7.FI7_CLIORI=E1_CLIENTE "
cQuery += "     AND FI7.FI7_LOJORI=E1_LOJA "
cQuery += " AND FI7.D_E_L_E_T_=' ' "

cQuery += " Inner Join " + retsqlName("SE1") + " SE1_NEG "
cQuery += " On "
cQuery += " SE1_NEG.E1_FILIAL=FI7.FI7_FILDES "
cQuery += " AND SE1_NEG.E1_PREFIXO=FI7.FI7_PRFDES "
cQuery += " AND SE1_NEG.E1_NUM=FI7.FI7_NUMDES "
cQuery += " AND SE1_NEG.E1_PARCELA=FI7.FI7_PARDES "
cQuery += " AND SE1_NEG.E1_TIPO=FI7.FI7_TIPDES "
cQuery += " AND SE1_NEG.E1_CLIENTE=FI7.FI7_CLIDES "
cQuery += " AND SE1_NEG.E1_LOJA=FI7.FI7_LOJDES "
cQuery += " AND SE1_NEG.E1_TIPOLIQ NOT IN ( 'LIQ', 'NEG') "
cQuery += " AND SE1_NEG.D_E_L_E_T_=' ' "

cQuery += " Inner Join " + retsqlName("FK7") + " FK7 " 
cQuery += " On "
cQuery += " FK7_FILIAL='" + xFilial("FK7") + "' "
cQuery += " AND FK7_ALIAS='SE1' "
cQuery += " AND FK7_CHAVE=SE1_NEG.E1_FILIAL+'|'+SE1_NEG.E1_PREFIXO+'|'+SE1_NEG.E1_NUM+'|'+SE1_NEG.E1_PARCELA+'|'+SE1_NEG.E1_TIPO+'|'+SE1_NEG.E1_CLIENTE+'|'+SE1_NEG.E1_LOJA" + " "
cQuery += " AND FK7.D_E_L_E_T_=' ' "

cQuery += " Inner Join " + retSqlName("FK1") + " FK1 "
cQuery += " On "
cQuery += " FK1_FILIAL='" + xFilial("FK1") + "' "
cQuery += " AND FK1_IDDOC=FK7.FK7_IDDOC "
if lDtCTB
	cQuery += " AND FK1_DATA > '" + DtoS(MV_PAR01) + "' "
else
	cQuery += " AND FK1_DTDISP > '" + DtoS(MV_PAR01) + "' "
endIf
cQuery += " AND FK1.D_E_L_E_T_=' ' "

cQuery += " Left Join " + retSqlName("FK1") + " FK1PAS "
cQuery += " On "
cQuery += " FK1PAS.FK1_FILIAL='" + xFilial("FK1") + "' "
cQuery += " AND FK1PAS.FK1_IDDOC=FK7.FK7_IDDOC "
if lDtCTB
	cQuery += " AND FK1PAS.FK1_DATA <= '" + DtoS(MV_PAR01) + "' "
else
	cQuery += " AND FK1PAS.FK1_DTDISP <= '" + DtoS(MV_PAR01) + "' "
endIf
cQuery += " AND FK1PAS.D_E_L_E_T_=' ' "

// Família
cQuery += "INNER JOIN "+RetSqlName("BA3")+" BA3 "
cQuery += "   ON BA3_FILIAL='"+xFilial('BA3')+"' "
cQuery += "  AND BA3_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BA3_CODEMP=BM1.BM1_CODEMP "
cQuery += "  AND BA3_MATRIC=BM1.BM1_MATRIC "
cQuery += "  AND BA3.D_E_L_E_T_=' ' "

// Usuário
cQuery += "INNER JOIN "+RetSqlName("BA1")+" BA1 "
cQuery += "ON BA1_FILIAL='"+xFilial('BA1')+"' "
cQuery += "  AND BA1_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BA1_CODEMP=BM1.BM1_CODEMP "
cQuery += "  AND BA1_MATRIC=BM1.BM1_MATRIC "
cQuery += "  AND BA1_TIPREG=BM1.BM1_TIPREG "
cQuery += "  AND BA1.D_E_L_E_T_=' ' "

// Usuário Titular
cQuery += "LEFT JOIN "+RetSqlName("BA1")+" TIT "
cQuery += "ON TIT.BA1_FILIAL='"+xFilial("BA1")+"' "
cQuery += "  AND TIT.BA1_CODINT=BM1.BM1_CODINT "
cQuery += "  AND TIT.BA1_CODEMP=BM1.BM1_CODEMP "
cQuery += "  AND TIT.BA1_MATRIC=BM1.BM1_MATRIC "
cQuery	+= "  AND TIT.BA1_RESFAM='1' "
cQuery	+= "AND TIT.D_E_L_E_T_=' ' "

// Produto Saúde
cQuery += "INNER JOIN "+RetSqlName("BI3")+" BI3 "
cQuery += "ON BI3_FILIAL='"+xFilial("BI3")+"' "
cQuery += " AND BI3_CODINT=BM1.BM1_CODINT "

If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"		
	cQuery += "  AND ( BI3_CODIGO=DECODE(BA1.BA1_CODPLA, '    ', BA3.BA3_CODPLA, BA1.BA1_CODPLA) "
	cQuery += "  AND BI3_VERSAO=DECODE(BA1.BA1_VERSAO, '   ', BA3.BA3_VERSAO, BA1.BA1_VERSAO) ) "
Else
	cQuery += "  AND BI3_CODIGO=("
	cQuery += "CASE WHEN BA1.BA1_CODPLA=' ' THEN BA3.BA3_CODPLA "
	cQuery += "ELSE BA1.BA1_CODPLA END) "
	cQuery += "  AND BI3_VERSAO=("
	cQuery += "CASE WHEN BA1.BA1_VERSAO=' ' THEN BA3.BA3_VERSAO "
	cQuery += "ELSE BA1.BA1_VERSAO END) "
EndIf
cQuery += "  AND BI3.D_E_L_E_T_=' ' "

// Tabela Tipos de Títulos
cQuery += "INNER JOIN "+RetSqlName("SX5")+" SX5 "
cQuery += "ON SX5.X5_FILIAL='"+xFilial('SX5')+"' "
cQuery += "  AND SX5.X5_TABELA='05' "
cQuery += "  AND SX5.X5_CHAVE=SE1.E1_TIPO "
cQuery += "  AND SX5.D_E_L_E_T_= ' ' "

// Grupo Empresa
cQuery += "INNER JOIN "+RetSqlName("BG9")+" BG9 "
cQuery += "ON BG9_FILIAL='"+xFilial('BG9')+"' "
cQuery += "  AND BG9_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BG9_CODIGO=BM1.BM1_CODEMP "
cQuery += "  AND BG9.D_E_L_E_T_=' ' "

// Contrato
cQuery += "LEFT JOIN "+RetSqlName("BT5")+" BT5 "
cQuery += "ON BT5_FILIAL='"+xFilial('BT5')+"' "
cQuery += "  AND BT5_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BT5_CODIGO=BM1.BM1_CODEMP "
cQuery += "  AND BT5_NUMCON=BM1.BM1_CONEMP "
cQuery += "  AND BT5_VERSAO=BM1.BM1_VERCON "
cQuery += "  AND BT5.D_E_L_E_T_= ' ' "

// Versões dos Contratos
cQuery += "LEFT JOIN "+RetSqlName("BQB")+" BQB "
cQuery += "ON BQB_FILIAL='"+xFilial('BQB')+"' "
cQuery += "  AND BQB_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BQB_CDEMP=BM1.BM1_CODEMP "
cQuery += "  AND BQB_NUMCON=BM1.BM1_CONEMP "
cQuery += "  AND BQB_VERSAO=BM1.BM1_VERCON "
cQuery += "  AND BQB.D_E_L_E_T_= ' ' "

// SubContratos
cQuery += "LEFT JOIN "+RetSqlName("BQC")+" BQC "
cQuery += "ON BQC_FILIAL='"+xFilial('BQB')+"' "
cQuery += "  AND BQC_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BQC_CODEMP=BM1.BM1_CODEMP "
cQuery += "  AND BQC_NUMCON=BM1.BM1_CONEMP "
cQuery += "  AND BQC_VERCON=BM1.BM1_VERCON "
cQuery += "  AND BQC_SUBCON=BM1.BM1_SUBCON "
cQuery += "  AND BQC_VERSUB=BM1.BM1_VERSUB "
cQuery += "  AND BQC.D_E_L_E_T_=' ' "

cQuery += " WHERE "
cQuery	+= "  BM1.D_E_L_E_T_=' ' "
cQuery += " AND FK1PAS.FK1_IDDOC IS NULL "
// Filtra Lançamentos conforme retorno do ponto de entrada
If Len(aPtoQuery) > 0
	For nPos := 1 to Len(aPtoQuery)
		cQuery += IIf( nPos==1, "AND BM1_CODTIP IN('"+aPtoQuery[nPos,1], "'"+aPtoQuery[nPos,1] )
		cQuery += IIf( Len(aPtoQuery)>1, IIf(Len(aPtoQuery)==nPos,  "') ", "',"), "') ")
	Next
Else

	//Se Benef.Operadoras, filtra tipo de movimentação coparticipação          
	If MV_PAR06 == 1		// Beneficiário da Operadora 

		cQuery	+= "AND BM1_CODTIP IN ('101','102','103','107','108','109','110','111','113','117','118','128','129','130','131','132','133','135','136','146','180','184','186','188','189','190','191') "
		cQuery	+= "AND BT5_INTERC <> '1' "

	//Se Coparticipação, filtra tipos de movimentacao                          
	ElseIf MV_PAR06 == 2	// Coparticipação

		cQuery	+= "AND BM1_CODTIP IN ('104','116','120','121','122','123','124','125','127','134','137','138','139','140','141','142','143','144','145','147','148','149','150','151','152','153','154','155','156','157','158','159','160','161','162','163','164','165','166','167','168','169','170','171','172','173','174','175','176','177','181','185') "
		cQuery	+= "AND BT5_INTERC <> '1' "

	//Se Benef.Outras Operadoras, trata somente contratos de Intercambio.      
	ElseIf MV_PAR06 == 3

		cQuery	+= "AND BT5_INTERC='1' "

	//Se Rel.Plan.Odonto, filtra tipo de movimentação odontologico             
	ElseIf MV_PAR06 == 4 

		cQuery	+= "AND BM1_CODTIP IN ('131','132') "
		cQuery	+= "AND BT5_INTERC <> '1' "

	//Se Rel.Pl.Med.Hosp, exclui tipo de movimentação odontologico             
	ElseIf MV_PAR06 == 5 

		cQuery	+= "AND BM1_CODTIP NOT IN ('131','132') "
		cQuery	+= "AND BT5_INTERC <> '1' "

	EndIf

EndIf

cQuery	+= cWhere		// Adição do conteúdo do ponto de entrada, caso exista.
//cQuery  += " AND BM1_NUMTIT IN( 'xxxx') "//cQuery  += " AND BM1_NUMTIT ='001117772' "
//cQuery  += " AND BM1_NUMTIT IN('001117812', '001082331') "
//cQuery  += " AND BM1_NUMTIT='001336691' "
//cQuery += " AND BM1_MATRIC='010696' "
//cQuery  += " AND BM1_NUMTIT IN('000942518', '001297911', '001301496', '001344814', '001294497') "
*/
//------------------------- Neg do futuro no passado
//Prepare seu delorean pra esse union... aqui vamos tratar os casos que o título nasceu em X e estava com estado A
//em Y, o título X foi negociado, passando para o estado B. O usuário quer um relatório de uma data maior ou igual à X 
//e menor que Y... com isso, a negociação não aconteceu ainda nessa data.. ah... e tem o valor também, jovem, apesar de
//estarmos num momento de tempo que tinha saldo nesse E1, no E1 não tem mais saldo... isso gera valor zerado no relatóri..
//então vamos assumir que o valor nesse dado momento é o atual E1_VALLIQ que foi o valor da liquidação no momento Y, que
//era pra ser o saldo pré-liquidação.

cQuery += " UNION ALL "

cQuery	+= "SELECT DISTINCT BM1_CODINT,BM1_CODEMP,BM1_CONEMP,BM1_VERCON,BM1_SUBCON,BM1_VERSUB,"
cQuery	+= "BM1_MATRIC,BM1_TIPREG,BM1_DIGITO,BA1.BA1_DATINC," 
cQuery	+= "BM1_MES,BM1_ANO,BM1_VALOR, BM1.R_E_C_N_O_ AS BM1REG,"
cQuery	+= "BM1_TIPO,BM1_TIPTIT,BM1_PREFIX AS PREFIXO, BM1_NUMTIT AS NUMERO, BM1_PARCEL AS PARCELA,BM1_CODTIP,BM1_CODEVE,"
cQuery	+= "BM1_ALIAS, BM1_ORIGEM, BM1_PLNUCO,"
cQuery	+= "BI3.BI3_DTAPPR,BI3.BI3_CODSEG,BI3.BI3_MODPAG,BI3.BI3_TIPCON,"
cQuery	+= " COALESCE(TIT.BA1_NOMUSR, ' ' ) NOMTIT, COALESCE(TIT.BA1_CPFUSR, ' ') CPFTIT," 
cQuery	+= "BG9.BG9_TIPO,BG9.BG9_DESCRI,BT5.BT5_INTERC,BT5.BT5_TIPOIN,BQB.BQB_DATINI,BQB.BQB_DATFIN,COALESCE(BQC.BQC_DESCRI, ' ')," 
cQuery	+= "SE1.E1_VENCREA AS VENCTO, "	
cQuery	+= "SE1.E1_SALDO, SE1.E1_VALOR, SE1.E1_EMISSAO, SX5.X5_DESCRI AS DESCDOC,"
cQuery	+= " ' ' AS TIPCOB, '      ' AS MESLCT, 'NG5' TIPOZ, 0 VALNEG, (SE1.E1_VALLIQ - SE1.E1_MULTA - SE1.E1_JUROS + COALESCE(J.TOT_NES,0) - COALESCE(J.TOT_ES,0) ) VALSLDPAS, 'OK' LINOK, ' ' IDDOCZ, COALESCE(K.TOT_NES,0) TOT_NES, COALESCE(K.TOT_ES,0) TOT_ES, SE1.R_E_C_N_O_ SE1REC, ( (COALESCE(K.TOT_NES,0) - COALESCE(K.TOT_ES,0) - COALESCE(YU.TOT_JURMUL, 0)) )VALFI7, '" + cSpaceN + "' PARNEG, BI3.BI3_SUSEP, BM1_VALOR BM1VLRORI  "

cQuery += " FROM " + RetSqlName("BM1") + " BM1 "

cQuery += " INNER JOIN " + RetSqlName("SE1") + " SE1 "
cQuery += "    ON BM1_FILIAL= '" + xFilial("BM1") + "' "
cQuery += "   AND BM1_PLNUCO=E1_PLNUCOB "
cQuery += "   AND BM1_PREFIX=E1_PREFIXO "
cQuery += "   AND BM1_NUMTIT=E1_NUM "
cQuery += "   AND BM1_PARCEL=E1_PARCELA " 
cQuery += "   AND BM1_TIPTIT=E1_TIPO " 
cQuery += "   AND SE1.E1_CODINT='"+MV_PAR02+"' "
cQuery += "   AND SE1.E1_CODEMP >= '"+MV_PAR03+"' "
cQuery += "   AND SE1.E1_CODEMP <= '"+MV_PAR04+"' "
cQuery += "   AND SE1.E1_TIPO NOT IN ('RA ','PA ',' NCC ',' NDF') "  
cQuery += "   AND SUBSTRING(SE1.E1_ORIGEM,1,3)='PLS' " 
//cQuery += "   AND SE1.E1_TIPOLIQ IN('LIQ','CAN','NEG') "
//cQuery += "   AND (SE1.E1_BAIXA=' ' OR SE1.E1_BAIXA >  '" + dtos(dDatDe) + "') "
cQuery += "   AND SE1.E1_EMISSAO <='"+DtoS(MV_PAR01)+"' "	
cQuery += "   AND SE1.D_E_L_E_T_=' ' "

cQuery += " Inner Join " + retsqlName("FK7") + " FK7 " 
cQuery += " On "
cQuery += " FK7_FILIAL='" + xFilial("FK7") + "' "
cQuery += " AND FK7_ALIAS='SE1' "

If(SubStr(Alltrim(Upper(TCGetDb())),1,6)) == "ORACLE"
	cQuery += " AND FK7_CHAVE=SE1.E1_FILIAL||'|'||SE1.E1_PREFIXO||'|'||SE1.E1_NUM||'|'||SE1.E1_PARCELA||'|'||SE1.E1_TIPO||'|'||SE1.E1_CLIENTE||'|'||SE1.E1_LOJA" + " "
Else
	cQuery += " AND FK7_CHAVE=SE1.E1_FILIAL+'|'+SE1.E1_PREFIXO+'|'+SE1.E1_NUM+'|'+SE1.E1_PARCELA+'|'+SE1.E1_TIPO+'|'+SE1.E1_CLIENTE+'|'+SE1.E1_LOJA" + " "
Endif

cQuery += " AND FK7.D_E_L_E_T_=' ' "

cQuery += "   INNER JOIN " + retSQLName("FI7") + " FI7 " 
cQuery += "      ON FI7.FI7_FILIAL=SE1.E1_FILIAL "
cQuery += "     AND FI7.FI7_PRFORI=SE1.E1_PREFIXO "
cQuery += "     AND FI7.FI7_NUMORI=SE1.E1_NUM "
cQuery += "     AND FI7.FI7_PARORI=SE1.E1_PARCELA "
cQuery += "     AND FI7.FI7_TIPORI=SE1.E1_TIPO "
cQuery += "     AND FI7.FI7_CLIORI=SE1.E1_CLIENTE "
cQuery += "     AND FI7.FI7_LOJORI=SE1.E1_LOJA "
cQuery += "     AND FI7.D_E_L_E_T_=' ' "

cQuery += " Inner Join " + retSqlName("FK1") + " FK1 "
cQuery += " On "
cQuery += " FK1_FILIAL='" + xFilial("FK1") + "' "
cQuery += " AND FK1_IDDOC=FK7.FK7_IDDOC "
if lDtCTB
	cQuery += " AND FK1_DATA > '" + DtoS(MV_PAR01) + "' "
else
	cQuery += " AND FK1_DTDISP > '" + DtoS(MV_PAR01) + "' "
endIf
cQuery += " AND FK1.D_E_L_E_T_=' ' "

cQuery += " Left Join ( "
cQuery += " select SUM( Case  when FK1_TPDOC='ES' then FK1_VALOR else 0 END ) TOT_ES, SUM( Case  when FK1_TPDOC <> 'ES' then FK1_VALOR else 0 END ) TOT_NES, FK1_IDDOC from "
cQuery += " " + retsqlName("FK1") + " "
cQuery += " Where FK1_FILIAL='" + xfilial("FK1") +  "' "
cQuery += " 	AND FK1_DTDISP <= '"+DtoS(MV_PAR01)+"' "
cQuery += "   AND FK1_MOTBX NOT IN ('LIQ', 'NEG') "
cQuery += " 	AND D_E_L_E_T_=' ' " 
cQuery += " group By FK1_IDDOC "
cQuery += " ) K "
cQuery += " 	On K.FK1_IDDOC=FK7.FK7_IDDOC "

cQuery += " Left Join ( "
cQuery += " select SUM( Case  when FK1_TPDOC='ES' then FK1_VALOR else 0 END ) TOT_ES, SUM( Case  when FK1_TPDOC <> 'ES' then FK1_VALOR else 0 END ) TOT_NES, FK1_IDDOC from "
cQuery += " " + retsqlName("FK1") + " "
cQuery += " Where FK1_FILIAL='" + xfilial("FK1") +  "' "
cQuery += " 	AND FK1_DTDISP > '"+DtoS(MV_PAR01)+"' "
cQuery += "   AND FK1_MOTBX NOT IN ('LIQ', 'NEG') "
cQuery += " 	AND D_E_L_E_T_=' ' " 
cQuery += " group By FK1_IDDOC "
cQuery += " ) J "
cQuery += " 	On J.FK1_IDDOC=FK7.FK7_IDDOC "

cQuery += " Left Join ( "
cQuery += " select SUM( Case  when FK6_TPDOC != 'DC' then FK6_VALMOV else 0 END ) TOT_JURMUL, FK1_IDDOC from "
cQuery += " " + retsqlName("FK6") + " FK6 "
cQuery += " Inner Join " + RetSqlName("FK1") + " FK1 "
cQuery += " On "
cQuery += "   FK1_FILIAL='" + xFilial("FK1") + "' "
cQuery += "   AND FK1_IDFK1=FK6.FK6_IDORIG "
cQuery += " 	AND FK1_DTDISP <= '"+DtoS(MV_PAR01)+"' "
cQuery += " Where FK6_FILIAL='" + xfilial("FK1") +  "' "
cQuery += " 	AND FK6.D_E_L_E_T_=' ' " 
cQuery += " group By FK1_IDDOC "
cQuery += " ) YU "
//cQuery += " 	On YU.FK1_IDDOC=FK7.FK7_IDDOC "
cQuery += " 	On YU.FK1_IDDOC=K.FK1_IDDOC "

cQuery += " Inner Join " + RetSqlName("FKA") + " FKA "
cQuery += " On "
cQuery += " FKA_FILIAL='" + xfilial("FKA") + "' "
cQuery += " AND FKA_TABORI='FK1' "
cQuery += " AND FKA_IDORIG=FK1.FK1_IDFK1 "
cQuery += " AND FKA.D_E_L_E_T_=' ' "
/*
cQuery += " LEFT JOIN " + oFK5FK7:getRealName() + " TrueFK57 "
cQuery += " On "
cQuery += " TrueFK57.FKA_IDPROC=FKA.FKA_IDPROC "
*/
// Família
cQuery += "INNER JOIN "+RetSqlName("BA3")+" BA3 "
cQuery += "   ON BA3_FILIAL='"+xFilial('BA3')+"' "
cQuery += "  AND BA3_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BA3_CODEMP=BM1.BM1_CODEMP "
cQuery += "  AND BA3_MATRIC=BM1.BM1_MATRIC "
cQuery += "  AND BA3.D_E_L_E_T_=' ' "

// Usuário
cQuery += "INNER JOIN "+RetSqlName("BA1")+" BA1 "
cQuery += "ON BA1_FILIAL='"+xFilial('BA1')+"' "
cQuery += "  AND BA1_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BA1_CODEMP=BM1.BM1_CODEMP "
cQuery += "  AND BA1_MATRIC=BM1.BM1_MATRIC "
cQuery += "  AND BA1_TIPREG=BM1.BM1_TIPREG "
cQuery += "  AND BA1.D_E_L_E_T_=' ' "

// Usuário Titular
cQuery += "LEFT JOIN "+RetSqlName("BA1")+" TIT "
cQuery += "ON TIT.BA1_FILIAL='"+xFilial("BA1")+"' "
cQuery += "  AND TIT.BA1_CODINT=BM1.BM1_CODINT "
cQuery += "  AND TIT.BA1_CODEMP=BM1.BM1_CODEMP "
cQuery += "  AND TIT.BA1_MATRIC=BM1.BM1_MATRIC "
cQuery	+= "  AND TIT.BA1_RESFAM='1' "
cQuery	+= "AND TIT.D_E_L_E_T_=' ' "

// Produto Saúde
cQuery += "INNER JOIN "+RetSqlName("BI3")+" BI3 "
cQuery += "ON BI3_FILIAL='"+xFilial("BI3")+"' "
cQuery += " AND BI3_CODINT=BM1.BM1_CODINT "

If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"		
	cQuery += "  AND ( BI3_CODIGO=DECODE(BA1.BA1_CODPLA, '    ', BA3.BA3_CODPLA, BA1.BA1_CODPLA) "
	cQuery += "  AND BI3_VERSAO=DECODE(BA1.BA1_VERSAO, '   ', BA3.BA3_VERSAO, BA1.BA1_VERSAO) ) "
Else
	cQuery += "  AND BI3_CODIGO=("
	cQuery += "CASE WHEN BA1.BA1_CODPLA=' ' THEN BA3.BA3_CODPLA "
	cQuery += "ELSE BA1.BA1_CODPLA END) "
	cQuery += "  AND BI3_VERSAO=("
	cQuery += "CASE WHEN BA1.BA1_VERSAO=' ' THEN BA3.BA3_VERSAO "
	cQuery += "ELSE BA1.BA1_VERSAO END) "
EndIf
cQuery += "  AND BI3.D_E_L_E_T_=' ' "

// Tabela Tipos de Títulos
cQuery += "INNER JOIN "+RetSqlName("SX5")+" SX5 "
cQuery += "ON SX5.X5_FILIAL='"+xFilial('SX5')+"' "
cQuery += "  AND SX5.X5_TABELA='05' "
cQuery += "  AND SX5.X5_CHAVE=SE1.E1_TIPO "
cQuery += "  AND SX5.D_E_L_E_T_= ' ' "

// Grupo Empresa
cQuery += "INNER JOIN "+RetSqlName("BG9")+" BG9 "
cQuery += "ON BG9_FILIAL='"+xFilial('BG9')+"' "
cQuery += "  AND BG9_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BG9_CODIGO=BM1.BM1_CODEMP "
cQuery += "  AND BG9.D_E_L_E_T_=' ' "

// Contrato
cQuery += "LEFT JOIN "+RetSqlName("BT5")+" BT5 "
cQuery += "ON BT5_FILIAL='"+xFilial('BT5')+"' "
cQuery += "  AND BT5_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BT5_CODIGO=BM1.BM1_CODEMP "
cQuery += "  AND BT5_NUMCON=BM1.BM1_CONEMP "
cQuery += "  AND BT5_VERSAO=BM1.BM1_VERCON "
cQuery += "  AND BT5.D_E_L_E_T_= ' ' "

// Versões dos Contratos
cQuery += "LEFT JOIN "+RetSqlName("BQB")+" BQB "
cQuery += "ON BQB_FILIAL='"+xFilial('BQB')+"' "
cQuery += "  AND BQB_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BQB_CDEMP=BM1.BM1_CODEMP "
cQuery += "  AND BQB_NUMCON=BM1.BM1_CONEMP "
cQuery += "  AND BQB_VERSAO=BM1.BM1_VERCON "
cQuery += "  AND BQB.D_E_L_E_T_= ' ' "

// SubContratos
cQuery += "LEFT JOIN "+RetSqlName("BQC")+" BQC "
cQuery += "ON BQC_FILIAL='"+xFilial('BQB')+"' "
cQuery += "  AND BQC_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BQC_CODEMP=BM1.BM1_CODEMP "
cQuery += "  AND BQC_NUMCON=BM1.BM1_CONEMP "
cQuery += "  AND BQC_VERCON=BM1.BM1_VERCON "
cQuery += "  AND BQC_SUBCON=BM1.BM1_SUBCON "
cQuery += "  AND BQC_VERSUB=BM1.BM1_VERSUB "
cQuery += "  AND BQC.D_E_L_E_T_=' ' "

cQuery += " WHERE "
//cQuery += " TrueFK57.FKA_IDPROC IS NULL "
cQuery	+= "  BM1.D_E_L_E_T_=' ' "
//cQuery += "  AND J.FK1_IDDOC IS NULL "
// Filtra Lançamentos conforme retorno do ponto de entrada
If Len(aPtoQuery) > 0
	For nPos := 1 to Len(aPtoQuery)
		cQuery += IIf( nPos==1, "AND BM1_CODTIP IN('"+aPtoQuery[nPos,1], "'"+aPtoQuery[nPos,1] )
		cQuery += IIf( Len(aPtoQuery)>1, IIf(Len(aPtoQuery)==nPos,  "') ", "',"), "') ")
	Next
Else

	//Se Benef.Operadoras, filtra tipo de movimentação coparticipação          
	If MV_PAR06 == 1		// Beneficiário da Operadora 

		cQuery	+= "AND BM1_CODTIP IN ('101','102','103','107','108','109','110','111','113','117','118','128','129','130','131','132','133','135','136','146','180','184','186','188','189','190','191') "
		cQuery	+= "AND BT5_INTERC <> '1' "

	//Se Coparticipação, filtra tipos de movimentacao                          
	ElseIf MV_PAR06 == 2	// Coparticipação

		cQuery	+= "AND BM1_CODTIP IN ('104','116','120','121','122','123','124','125','127','134','137','138','139','140','141','142','143','144','145','147','148','149','150','151','152','153','154','155','156','157','158','159','160','161','162','163','164','165','166','167','168','169','170','171','172','173','174','175','176','177','181','185') "
		cQuery	+= "AND BT5_INTERC <> '1' "

	//Se Benef.Outras Operadoras, trata somente contratos de Intercambio.      
	ElseIf MV_PAR06 == 3

		cQuery	+= "AND BT5_INTERC='1' "

	//Se Rel.Plan.Odonto, filtra tipo de movimentação odontologico             
	ElseIf MV_PAR06 == 4 

		cQuery	+= "AND BM1_CODTIP IN ('131','132') "
		cQuery	+= "AND BT5_INTERC <> '1' "

	//Se Rel.Pl.Med.Hosp, exclui tipo de movimentação odontologico             
	ElseIf MV_PAR06 == 5 
		cQuery	+= "AND BM1_CODTIP NOT IN ('131','132') "
		cQuery	+= "AND BT5_INTERC <> '1' "
	EndIf

EndIf

cQuery	+= cWhere		// Adição do conteúdo do ponto de entrada, caso exista.
//cQuery  += " AND BM1_NUMTIT IN('001117812', '001082331') "
//cQuery  += " AND BM1_NUMTIT IN( 'xxxx') "
//cQuery  += " AND BM1_NUMTIT IN('000942518', '001297911', '001301496', '001344814', '001294497') "
//cQuery += " AND BM1_MATRIC='010696' "
//cQuery	+= "  AND BM1.D_E_L_E_T_=' ' "


//Registros com FK1, vamos ver se tem pagamento proporcional
cQuery += " UNION ALL "

cQuery	+= "SELECT DISTINCT BM1_CODINT,BM1_CODEMP,BM1_CONEMP,BM1_VERCON,BM1_SUBCON,BM1_VERSUB,"
cQuery	+= "BM1_MATRIC,BM1_TIPREG,BM1_DIGITO,BA1.BA1_DATINC," 
cQuery	+= "BM1_MES,BM1_ANO,BM1_VALOR, BM1.R_E_C_N_O_ AS BM1REG,"
cQuery	+= "BM1_TIPO,BM1_TIPTIT,BM1_PREFIX AS PREFIXO, BM1_NUMTIT AS NUMERO, BM1_PARCEL AS PARCELA,BM1_CODTIP,BM1_CODEVE,"
cQuery	+= "BM1_ALIAS, BM1_ORIGEM, BM1_PLNUCO,"
cQuery	+= "BI3.BI3_DTAPPR,BI3.BI3_CODSEG,BI3.BI3_MODPAG,BI3.BI3_TIPCON,"
cQuery	+= " COALESCE(TIT.BA1_NOMUSR, ' ' ) NOMTIT, COALESCE(TIT.BA1_CPFUSR, ' ') CPFTIT," 
cQuery	+= "BG9.BG9_TIPO,BG9.BG9_DESCRI,BT5.BT5_INTERC,BT5.BT5_TIPOIN,BQB.BQB_DATINI,BQB.BQB_DATFIN,COALESCE(BQC.BQC_DESCRI, ' ')," 
cQuery	+= "SE1.E1_VENCREA AS VENCTO, "	
cQuery	+= "SE1.E1_SALDO, SE1.E1_VALOR, SE1.E1_EMISSAO, SX5.X5_DESCRI AS DESCDOC,"
cQuery	+= " ' ' AS TIPCOB, '      ' AS MESLCT, 'NG6' TIPOZ, 0 VALNEG, SE1.E1_VALLIQ VALSLDPAS, 'OK' LINOK, FK1_IDDOC IDDOCZ, K.TOT_NES + SE1.E1_DESCONT TOT_NES, TOT_ES, SE1.R_E_C_N_O_ SE1REC, 0 VALFI7, '" + cSpaceN + "' PARNEG, BI3.BI3_SUSEP, BM1_VALOR BM1VLRORI   "

cQuery += " FROM " + RetSqlName("BM1") + " BM1 "

cQuery += " INNER JOIN " + RetSqlName("SE1") + " SE1 "
cQuery += "    ON BM1_FILIAL= '" + xFilial("BM1") + "' "
cQuery += "   AND BM1_PLNUCO=E1_PLNUCOB "
cQuery += "   AND BM1_PREFIX=E1_PREFIXO "
cQuery += "   AND BM1_NUMTIT=E1_NUM "
cQuery += "   AND BM1_PARCEL=E1_PARCELA " 
cQuery += "   AND BM1_TIPTIT=E1_TIPO " 
cQuery += "   AND SE1.E1_CODINT='"+MV_PAR02+"' "
cQuery += "   AND SE1.E1_CODEMP >= '"+MV_PAR03+"' "
cQuery += "   AND SE1.E1_CODEMP <= '"+MV_PAR04+"' "
cQuery += "   AND SE1.E1_TIPO NOT IN ('RA ','PA ',' NCC ',' NDF') "  
cQuery += "   AND SUBSTRING(SE1.E1_ORIGEM,1,3)='PLS' " 
cQuery += "   AND SE1.E1_TIPOLIQ NOT IN('LIQ','CAN','NEG') "
cQuery += "   AND E1_EMISSAO <='"+DtoS(MV_PAR01)+"' "	
cQuery += "   AND SE1.D_E_L_E_T_=' ' "

cQuery += " Left Join " + retsqlName("FK7") + " FK7 " 
cQuery += " On "
cQuery += " FK7_FILIAL='" + xFilial("FK7") + "' "
cQuery += " AND FK7_ALIAS='SE1' "

If(SubStr(Alltrim(Upper(TCGetDb())),1,6)) == "ORACLE"
	cQuery += " AND FK7_CHAVE=SE1.E1_FILIAL" + "||'|'||" + "SE1.E1_PREFIXO" + "||'|'||" + "SE1.E1_NUM" + "||'|'||" + "SE1.E1_PARCELA" + "||'|'||" + "SE1.E1_TIPO" + "||'|'||" + "SE1.E1_CLIENTE" + "||'|'||" + "SE1.E1_LOJA" + " "
Else
	cQuery += " AND FK7_CHAVE=SE1.E1_FILIAL" + "+'|'+" + "SE1.E1_PREFIXO" + "+'|'+" + "SE1.E1_NUM" + "+'|'+" + "SE1.E1_PARCELA" + "+'|'+" + "SE1.E1_TIPO" + "+'|'+" + "SE1.E1_CLIENTE" + "+'|'+" + "SE1.E1_LOJA" + " "
Endif

cQuery += " AND FK7.D_E_L_E_T_=' ' "
/*
cQuery += " Left Join " + retSqlName("FK1") + " FK1 "
cQuery += " On "
cQuery += " FK1_FILIAL='" + xFilial("FK1") + "' "
cQuery += " AND FK1_IDDOC=FK7.FK7_IDDOC "
//cQuery += " AND FK1_TPDOC='ES' "
cQuery += " AND FK1.D_E_L_E_T_=' ' "
*/

cQuery += " Left Join ( "
cQuery += " select SUM( Case  when FK1_TPDOC='ES' AND FK1_DTDISP <= '"+DtoS(MV_PAR01)+"' then FK1_VALOR else 0 END ) TOT_ES, SUM( Case  when FK1_TPDOC <> 'ES' AND FK1_DTDISP <= '"+DtoS(MV_PAR01)+"' then FK1_VALOR else 0 END ) TOT_NES, FK1_IDDOC from "
cQuery += " " + retsqlName("FK1") + " "
cQuery += " Where FK1_FILIAL='" + xfilial("FK1") +  "' "
//cQuery += " 	AND FK1_DTDISP <= '"+DtoS(MV_PAR01)+"' "
cQuery += " 	AND D_E_L_E_T_=' ' " 
cQuery += " group By FK1_IDDOC "
cQuery += " ) K "
cQuery += " 	On K.FK1_IDDOC=FK7.FK7_IDDOC "

// Família
cQuery += "INNER JOIN "+RetSqlName("BA3")+" BA3 "
cQuery += "   ON BA3_FILIAL='"+xFilial('BA3')+"' "
cQuery += "  AND BA3_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BA3_CODEMP=BM1.BM1_CODEMP "
cQuery += "  AND BA3_MATRIC=BM1.BM1_MATRIC "
cQuery += "  AND BA3.D_E_L_E_T_=' ' "

// Usuário
cQuery += "INNER JOIN "+RetSqlName("BA1")+" BA1 "
cQuery += "ON BA1_FILIAL='"+xFilial('BA1')+"' "
cQuery += "  AND BA1_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BA1_CODEMP=BM1.BM1_CODEMP "
cQuery += "  AND BA1_MATRIC=BM1.BM1_MATRIC "
cQuery += "  AND BA1_TIPREG=BM1.BM1_TIPREG "
cQuery += "  AND BA1.D_E_L_E_T_=' ' "

// Usuário Titular
cQuery += "LEFT JOIN "+RetSqlName("BA1")+" TIT "
cQuery += "ON TIT.BA1_FILIAL='"+xFilial("BA1")+"' "
cQuery += "  AND TIT.BA1_CODINT=BM1.BM1_CODINT "
cQuery += "  AND TIT.BA1_CODEMP=BM1.BM1_CODEMP "
cQuery += "  AND TIT.BA1_MATRIC=BM1.BM1_MATRIC "
cQuery	+= "  AND TIT.BA1_RESFAM='1' "
cQuery	+= "AND TIT.D_E_L_E_T_=' ' "

// Produto Saúde
cQuery += "INNER JOIN "+RetSqlName("BI3")+" BI3 "
cQuery += "ON BI3_FILIAL='"+xFilial("BI3")+"' "
cQuery += " AND BI3_CODINT=BM1.BM1_CODINT "

If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"		
	cQuery += "  AND ( BI3_CODIGO=DECODE(BA1.BA1_CODPLA, '    ', BA3.BA3_CODPLA, BA1.BA1_CODPLA) "
	cQuery += "  AND BI3_VERSAO=DECODE(BA1.BA1_VERSAO, '   ', BA3.BA3_VERSAO, BA1.BA1_VERSAO) ) "
Else
	cQuery += "  AND BI3_CODIGO=("
	cQuery += "CASE WHEN BA1.BA1_CODPLA=' ' THEN BA3.BA3_CODPLA "
	cQuery += "ELSE BA1.BA1_CODPLA END) "
	cQuery += "  AND BI3_VERSAO=("
	cQuery += "CASE WHEN BA1.BA1_VERSAO=' ' THEN BA3.BA3_VERSAO "
	cQuery += "ELSE BA1.BA1_VERSAO END) "
EndIf

cQuery += "  AND BI3.D_E_L_E_T_=' ' "

// Tabela Tipos de Títulos
cQuery += "INNER JOIN "+RetSqlName("SX5")+" SX5 "
cQuery += "ON SX5.X5_FILIAL='"+xFilial('SX5')+"' "
cQuery += "  AND SX5.X5_TABELA='05' "
cQuery += "  AND SX5.X5_CHAVE=SE1.E1_TIPO "
cQuery += "  AND SX5.D_E_L_E_T_= ' ' "

// Grupo Empresa
cQuery += "INNER JOIN "+RetSqlName("BG9")+" BG9 "
cQuery += "ON BG9_FILIAL='"+xFilial('BG9')+"' "
cQuery += "  AND BG9_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BG9_CODIGO=BM1.BM1_CODEMP "
cQuery += "  AND BG9.D_E_L_E_T_=' ' "

// Contrato
cQuery += "LEFT JOIN "+RetSqlName("BT5")+" BT5 "
cQuery += "ON BT5_FILIAL='"+xFilial('BT5')+"' "
cQuery += "  AND BT5_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BT5_CODIGO=BM1.BM1_CODEMP "
cQuery += "  AND BT5_NUMCON=BM1.BM1_CONEMP "
cQuery += "  AND BT5_VERSAO=BM1.BM1_VERCON "
cQuery += "  AND BT5.D_E_L_E_T_= ' ' "

// Versões dos Contratos
cQuery += "LEFT JOIN "+RetSqlName("BQB")+" BQB "
cQuery += "ON BQB_FILIAL='"+xFilial('BQB')+"' "
cQuery += "  AND BQB_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BQB_CDEMP=BM1.BM1_CODEMP "
cQuery += "  AND BQB_NUMCON=BM1.BM1_CONEMP "
cQuery += "  AND BQB_VERSAO=BM1.BM1_VERCON "
cQuery += "  AND BQB.D_E_L_E_T_= ' ' "

// SubContratos
cQuery += "LEFT JOIN "+RetSqlName("BQC")+" BQC "
cQuery += "ON BQC_FILIAL='"+xFilial('BQB')+"' "
cQuery += "  AND BQC_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BQC_CODEMP=BM1.BM1_CODEMP "
cQuery += "  AND BQC_NUMCON=BM1.BM1_CONEMP "
cQuery += "  AND BQC_VERCON=BM1.BM1_VERCON "
cQuery += "  AND BQC_SUBCON=BM1.BM1_SUBCON "
cQuery += "  AND BQC_VERSUB=BM1.BM1_VERSUB "
cQuery += "  AND BQC.D_E_L_E_T_=' ' "

cQuery += " WHERE "
cQuery	+= "  FK1_IDDOC IS NOT NULL "
cQuery += " AND SE1.E1_VALOR > K.TOT_NES + SE1.E1_DESCONT - K.TOT_ES "
// Filtra Lançamentos conforme retorno do ponto de entrada
If Len(aPtoQuery) > 0

	For nPos := 1 to Len(aPtoQuery)
		cQuery += IIf( nPos==1, "AND BM1_CODTIP IN('"+aPtoQuery[nPos,1], "'"+aPtoQuery[nPos,1] )
		cQuery += IIf( Len(aPtoQuery)>1, IIf(Len(aPtoQuery)==nPos,  "') ", "',"), "') ")
	Next

Else

	//Se Benef.Operadoras, filtra tipo de movimentação coparticipação          
	If MV_PAR06 == 1		// Beneficiário da Operadora 

		cQuery	+= "AND BM1_CODTIP IN ('101','102','103','107','108','109','110','111','113','117','118','128','129','130','131','132','133','135','136','146','180','184','186','188','189','190','191') "
		cQuery	+= "AND BT5_INTERC <> '1' "

	//Se Coparticipação, filtra tipos de movimentacao                          
	ElseIf MV_PAR06 == 2	// Coparticipação

		cQuery	+= "AND BM1_CODTIP IN ('104','116','120','121','122','123','124','125','127','134','137','138','139','140','141','142','143','144','145','147','148','149','150','151','152','153','154','155','156','157','158','159','160','161','162','163','164','165','166','167','168','169','170','171','172','173','174','175','176','177','181','185') "
		cQuery	+= "AND BT5_INTERC <> '1' "

	//Se Benef.Outras Operadoras, trata somente contratos de Intercambio.      
	ElseIf MV_PAR06 == 3

		cQuery	+= "AND BT5_INTERC='1' "

	//Se Rel.Plan.Odonto, filtra tipo de movimentação odontologico             
	ElseIf MV_PAR06 == 4 

		cQuery	+= "AND BM1_CODTIP IN ('131','132') "
		cQuery	+= "AND BT5_INTERC <> '1' "

	//Se Rel.Pl.Med.Hosp, exclui tipo de movimentação odontologico             
	ElseIf MV_PAR06 == 5 

		cQuery	+= "AND BM1_CODTIP NOT IN ('131','132') "
		cQuery	+= "AND BT5_INTERC <> '1' "

	EndIf

EndIf

cQuery	+= cWhere		// Adição do conteúdo do ponto de entrada, caso exista.

//cQuery  += " AND BM1_NUMTIT IN( 'xxxx') " //, '001296447', '001300235', '001308711', '001308960', '001330569', '001333091', '001336161', '001340297', '001343632', '001344808', '001374170', '001376193') "//cQuery  += " AND BM1_NUMTIT ='001117772' "
//cQuery  += " AND BM1_NUMTIT IN('001117812', '001082331') "
//cQuery  += " AND BM1_NUMTIT='001336691' "
//cQuery += " AND BM1_MATRIC='010696' "
//cQuery  += " AND BM1_NUMTIT IN('000942518', '001297911', '001301496', '001344814', '001294497') "
cQuery	+= "  AND BM1.D_E_L_E_T_=' ' "

//------
iF MV_PAR06 == 2
	cQuery += " UNION ALL "
	
	cQuery	+= "SELECT DISTINCT BD6.BD6_CODOPE BM1_CODINT, BD6.BD6_CODEMP BM1_CODEMP, BD6.BD6_CONEMP BM1_CONEMP, BD6.BD6_VERCON BM1_VERCON, BD6.BD6_SUBCON BM1_SUBCON, BD6.BD6_VERSUB BM1_VERSUB,"
	cQuery	+= " BD6.BD6_MATRIC BM1_MATRIC, BD6.BD6_TIPREG BM1_TIPREG, BD6.BD6_DIGITO BM1_DIGITO,BA1.BA1_DATINC," 
	cQuery	+= " BD6.BD6_MESPAG BM1_MES, BD6.BD6_ANOPAG BM1_ANO, BD6.BD6_VLRTPF BM1_VALOR, BD6.R_E_C_N_O_ BM1REG,"
	cQuery	+= " ' ' BM1_TIPO,'   ' BM1_TIPTIT, ' ' PREFIXO, BD7.BD7_CODPEG NUMERO, ' ' PARCELA, '   ' BM1_CODTIP, ' ' BM1_CODEVE,"
	cQuery	+= " '   ' BM1_ALIAS, ' ' BM1_ORIGEM, ' ' BM1_PLNUCO,"
	cQuery	+= " BI3.BI3_DTAPPR,BI3.BI3_CODSEG,BI3.BI3_MODPAG,BI3.BI3_TIPCON,"
	cQuery	+= " COALESCE(TIT.BA1_NOMUSR, ' ' ) NOMTIT, COALESCE(TIT.BA1_CPFUSR, ' ') CPFTIT," 
	cQuery	+= " BG9.BG9_TIPO,BG9.BG9_DESCRI,COALESCE(BT5.BT5_INTERC, ' ' ),COALESCE(BT5.BT5_TIPOIN, ' '), COALESCE(BQB.BQB_DATINI, '" + DtoS(ctoD("")) + "'), COALESCE(BQB.BQB_DATFIN, '" + DtoS(ctoD("")) + "'), COALESCE(BQC.BQC_DESCRI, ' ')," 
	cQuery	+= " '" + DtoS(cToD("")) + "' VENCTO, "	
	cQuery	+= " 0 E1_SALDO, BD6.BD6_VLRTPF E1_VALOR, '" + DtoS(cToD("")) + "' E1_EMISSAO, ' ' DESCDOC,"
	cQuery	+= " ' ' AS TIPCOB, '      ' AS MESLCT, 'NG7' TIPOZ, 0 VALNEG, 0 VALSLDPAS, 'OK' LINOK, ' ' IDDOCZ, 0 TOT_NES, 0 TOT_ES, 0 SE1REC, 0 VALFI7, '" + cSpaceN + "' PARNEG, BI3.BI3_SUSEP, 0 BM1VLRORI   "
	
	cQuery += " FROM " + RetSqlName("BD7") + " BD7 "
//	cQuery += " FROM " + RetSqlName("BD6") + " BD6 "
	
	cQuery += " Inner Join " + RetSqlName("BD6") + " BD6 "
	cQuery += " On BD6.BD6_FILIAL='"+ xFilial("BD6") + "' "
	cQuery += " AND BD6.BD6_CODOPE=BD7_CODOPE "
	cQuery += " AND BD6.BD6_CODPEG=BD7_CODPEG "
	cQuery += " AND BD6.BD6_NUMERO=BD7_NUMERO "
	cQuery += " AND BD6.BD6_ORIMOV=BD7_ORIMOV "
	cQuery += " AND BD6.BD6_SEQUEN=BD7_SEQUEN "
	cQuery += " AND BD6.BD6_FASE='4' "
	cQuery += " AND ( ( BD6.BD6_SEQPF <> ' ' "
	cQuery += " AND BD6.BD6_NUMFAT=' ' ) OR ( Exists( "
	cQuery += " Select '1' from " + RetSqlName("BDC") + " BDC "
	cQuery += " Where "
	cQuery += " BDC_FILIAL='" + xfilial("BDC") + "' "
	cQuery += " AND BDC_CODOPE + BDC_NUMERO = BD6.BD6_NUMFAT "
	cQuery += " AND BDC_DATGER > '" + DtoS(MV_PAR01) + "' "
	cQuery += " AND BDC.D_E_L_E_T_=' ' ) ) "
	cQuery += " ) AND BD6.D_E_L_E_T_=' ' "
	
	// Família
	cQuery += "INNER JOIN "+RetSqlName("BA3")+" BA3 "
	cQuery += "   ON BA3_FILIAL='"+xFilial('BA3')+"' "
	cQuery += "  AND BA3_CODINT=BD6.BD6_CODOPE "
	cQuery += "  AND BA3_CODEMP=BD6.BD6_CODEMP "
	cQuery += "  AND BA3_MATRIC=BD6.BD6_MATRIC "
	cQuery += "  AND BA3.D_E_L_E_T_=' ' "
	
	// Usuário
	cQuery += "INNER JOIN "+RetSqlName("BA1")+" BA1 "
	cQuery += "ON BA1_FILIAL='"+xFilial('BA1')+"' "
	cQuery += "  AND BA1_CODINT=BD6.BD6_CODOPE "
	cQuery += "  AND BA1_CODEMP=BD6.BD6_CODEMP "
	cQuery += "  AND BA1_MATRIC=BD6.BD6_MATRIC "
	cQuery += "  AND BA1_TIPREG=BD6.BD6_TIPREG "
	cQuery += "  AND BA1.D_E_L_E_T_=' ' "
	
	// Usuário Titular
	cQuery += "LEFT JOIN "+RetSqlName("BA1")+" TIT "
	cQuery += "ON TIT.BA1_FILIAL='"+xFilial("BA1")+"' "
	cQuery += "  AND TIT.BA1_CODINT=BD6.BD6_CODOPE "
	cQuery += "  AND TIT.BA1_CODEMP=BD6.BD6_CODEMP "
	cQuery += "  AND TIT.BA1_MATRIC=BD6.BD6_MATRIC "
	cQuery	+= "  AND TIT.BA1_RESFAM='1' "
	cQuery	+= "  AND TIT.D_E_L_E_T_=' ' "
	
	// Produto Saúde
	cQuery += "INNER JOIN "+RetSqlName("BI3")+" BI3 "
	cQuery += "ON BI3_FILIAL='"+xFilial("BI3")+"' "
	cQuery += " AND BI3_CODINT=BD6.BD6_CODOPE "
	
	If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"		
		cQuery += "  AND ( BI3_CODIGO=DECODE(BA1.BA1_CODPLA, '    ', BA3.BA3_CODPLA, BA1.BA1_CODPLA) "
		cQuery += "  AND BI3_VERSAO=DECODE(BA1.BA1_VERSAO, '   ', BA3.BA3_VERSAO, BA1.BA1_VERSAO) ) "
	Else
		cQuery += "  AND BI3_CODIGO=("
		cQuery += "CASE WHEN BA1.BA1_CODPLA=' ' THEN BA3.BA3_CODPLA "
		cQuery += "ELSE BA1.BA1_CODPLA END) "
		cQuery += "  AND BI3_VERSAO=("
		cQuery += "CASE WHEN BA1.BA1_VERSAO=' ' THEN BA3.BA3_VERSAO "
		cQuery += "ELSE BA1.BA1_VERSAO END) "
	EndIf
	
	cQuery += "  AND BI3.D_E_L_E_T_=' ' "
	/*
	// Tabela Tipos de Títulos
	cQuery += "INNER JOIN "+RetSqlName("SX5")+" SX5 "
	cQuery += "ON SX5.X5_FILIAL='"+xFilial('SX5')+"' "
	cQuery += "  AND SX5.X5_TABELA='05' "
	cQuery += "  AND SX5.X5_CHAVE=SE1.E1_TIPO "
	cQuery += "  AND SX5.D_E_L_E_T_= ' ' "
	*/
	// Grupo Empresa
	cQuery += "INNER JOIN "+RetSqlName("BG9")+" BG9 "
	cQuery += "ON BG9_FILIAL='"+xFilial('BG9')+"' "
	cQuery += "  AND BG9_CODINT=BD6.BD6_CODOPE "
	cQuery += "  AND BG9_CODIGO=BD6.BD6_CODEMP "
	cQuery += "  AND BG9.D_E_L_E_T_=' ' "
	
	// Contrato
	cQuery += "LEFT JOIN "+RetSqlName("BT5")+" BT5 "
	cQuery += "ON BT5_FILIAL='"+xFilial('BT5')+"' "
	cQuery += "  AND BT5_CODINT=BD6.BD6_CODOPE "
	cQuery += "  AND BT5_CODIGO=BD6.BD6_CODEMP "
	cQuery += "  AND BT5_NUMCON=BD6.BD6_CONEMP "
	cQuery += "  AND BT5_VERSAO=BD6.BD6_VERCON "
	cQuery += "  AND BT5.D_E_L_E_T_= ' ' "
	
	// Versões dos Contratos
	cQuery += "LEFT JOIN "+RetSqlName("BQB")+" BQB "
	cQuery += "ON BQB_FILIAL='"+xFilial('BQB')+"' "
	cQuery += "  AND BQB_CODINT=BD6.BD6_CODOPE "
	cQuery += "  AND BQB_CDEMP =BD6.BD6_CODEMP "
	cQuery += "  AND BQB_NUMCON=BD6.BD6_CONEMP "
	cQuery += "  AND BQB_VERSAO=BD6.BD6_VERCON "
	cQuery += "  AND BQB.D_E_L_E_T_= ' ' "
	
	// SubContratos
	cQuery += "LEFT JOIN "+RetSqlName("BQC")+" BQC "
	cQuery += "ON BQC_FILIAL='"+xFilial('BQB')+"' "
	cQuery += "  AND BQC_CODINT=BD6.BD6_CODOPE "
	cQuery += "  AND BQC_CODEMP=BD6.BD6_CODEMP "
	cQuery += "  AND BQC_NUMCON=BD6.BD6_CONEMP "
	cQuery += "  AND BQC_VERCON=BD6.BD6_VERCON "
	cQuery += "  AND BQC_SUBCON=BD6.BD6_SUBCON "
	cQuery += "  AND BQC_VERSUB=BD6.BD6_VERSUB "
	cQuery += "  AND BQC.D_E_L_E_T_=' ' "
	
	cQuery += " WHERE "
	cQuery += "   BD7.BD7_FILIAL='" + xFilial("BD7") + "' "
	cQuery += "   AND BD7.BD7_CODOPE='"+MV_PAR02+"' "
	cQuery += "   AND BD7.BD7_CODLDP NOT IN( '" + PLSRETLDP(9) + "', '" + PLSRETLDP(4) + "') "
	cQuery += "   AND BD7.BD7_TIPGUI <> '04' "
	cQuery += "   AND BD7.BD7_SITUAC <> '2' " // 1 - Ativo / 2 - Cancelado / 3 - Bloqueado
	cQuery += "   AND BD7.BD7_FASE='4' "
	cQuery += "   AND BD7.BD7_VLRTPF > 0 "
	cQuery += "   AND BD7.BD7_CODEMP >= '"+MV_PAR03+"' "
	cQuery += "   AND BD7.BD7_CODEMP <= '"+MV_PAR04+"' "
	cQuery += "   AND BD7.BD7_DTDIGI <= '" + DtoS(MV_PAR01) + "' "
//	cQuery += "   AND BD7.BD7_DTDIGI >= '" + DtoS(MV_PAR01 - 3) + "' "
	cQuery	+= "   AND BD7.D_E_L_E_T_=' ' "
/*	
	cQuery += " BD6.BD6_FILIAL='"+ xFilial("BD6") + "' "
	cQuery += " AND BD6.BD6_CODOPE='"+MV_PAR02+"' "
	cQuery += " AND BD6.BD6_CODLDP NOT IN( '" + PLSRETLDP(9) + "', '" + PLSRETLDP(4) + "') "
	cQuery += " AND BD6.BD6_VLRTPF > 0 "
	cQuery += " AND BD6.BD6_CODEMP >= '"+MV_PAR03+"' "
	cQuery += " AND BD6.BD6_CODEMP <= '"+MV_PAR04+"' "
	cQuery += " AND BD6.BD6_FASE='4' "
	cQuery += " AND BD6.BD6_SEQPF <> ' ' "
	cQuery += " AND BD6.BD6_NUMFAT=' ' "
	cQuery += " AND BD6.BD6_SITUAC <> '2' "
	cQuery += " AND BD6.BD6_DTDIGI <= '" + DtoS(MV_PAR01) + "' "
	cQuery += " AND BD6.BD6_DTDIGI >= '" + DtoS(MV_PAR01 - 30) + "' "
	cQuery += " AND BD6.D_E_L_E_T_=' ' "
*/	
ENDiF
//------

//Feito num domingo à tarde
cQuery += " UNION ALL "

cQuery	+= "SELECT DISTINCT BM1_CODINT,BM1_CODEMP,BM1_CONEMP,BM1_VERCON,BM1_SUBCON,BM1_VERSUB,"
cQuery	+= "BM1_MATRIC,BM1_TIPREG,BM1_DIGITO,BA1.BA1_DATINC," 
cQuery	+= "BM1_MES,BM1_ANO,BM1_VALOR, BM1.R_E_C_N_O_ AS BM1REG,"
cQuery	+= "BM1_TIPO,BM1_TIPTIT,BM1_PREFIX AS PREFIXO, BM1_NUMTIT AS NUMERO, BM1_PARCEL AS PARCELA,BM1_CODTIP,BM1_CODEVE,"
cQuery	+= "BM1_ALIAS, BM1_ORIGEM, BM1_PLNUCO,"
cQuery	+= "BI3.BI3_DTAPPR,BI3.BI3_CODSEG,BI3.BI3_MODPAG,BI3.BI3_TIPCON,"
cQuery	+= " COALESCE(TIT.BA1_NOMUSR, ' ' ) NOMTIT, COALESCE(TIT.BA1_CPFUSR, ' ') CPFTIT," 
cQuery	+= "BG9.BG9_TIPO,BG9.BG9_DESCRI,BT5.BT5_INTERC,BT5.BT5_TIPOIN,BQB.BQB_DATINI,BQB.BQB_DATFIN,COALESCE(BQC.BQC_DESCRI, ' ')," 
cQuery	+= "SE1.E1_VENCREA AS VENCTO, "	
cQuery	+= "SE1_NEG.E1_SALDO, SE1.E1_VALOR, SE1.E1_EMISSAO, SX5.X5_DESCRI AS DESCDOC,"
cQuery	+= " ' ' AS TIPCOB, '      ' AS MESLCT, 'NG8' TIPOZ, SE1_NEG.E1_VALOR VALNEG, SE1.E1_VALLIQ VALSLDPAS, 'OK' LINOK, ' ' IDDOCZ, 0 TOT_NES, 0 TOT_ES, SE1.R_E_C_N_O_ SE1REC, FI7.FI7_VALOR VALFI7, "+IIf(lOracle,"SE1_NEG.E1_NUM || SE1_NEG.E1_PARCELA","SE1_NEG.E1_NUM + SE1_NEG.E1_PARCELA")+" PARNEG, BI3.BI3_SUSEP, BM1_VALOR BM1VLRORI  "

cQuery += " FROM " + RetSqlName("BM1") + " BM1 "

cQuery += " INNER JOIN " + RetSqlName("SE1") + " SE1 "
cQuery += "    ON BM1_FILIAL= '" + xFilial("BM1") + "' "
cQuery += "   AND BM1_PLNUCO=E1_PLNUCOB "
cQuery += "   AND BM1_PREFIX=E1_PREFIXO "
cQuery += "   AND BM1_NUMTIT=E1_NUM "
cQuery += "   AND BM1_PARCEL=E1_PARCELA " 
cQuery += "   AND BM1_TIPTIT=E1_TIPO " 
cQuery += "   AND SE1.E1_CODINT='"+MV_PAR02+"' "
cQuery += "   AND SE1.E1_CODEMP >= '"+MV_PAR03+"' "
cQuery += "   AND SE1.E1_CODEMP <= '"+MV_PAR04+"' "
cQuery += "   AND SE1.E1_TIPO NOT IN ('RA ','PA ',' NCC ',' NDF') "  
cQuery += "   AND SUBSTRING(SE1.E1_ORIGEM,1,3)='PLS' " 
cQuery += "   AND ( SE1.E1_BAIXA <=  '" + dtos(dDatDe) + "' ) "
cQuery += "   AND E1_EMISSAO <='"+DtoS(MV_PAR01)+"' "	
cQuery += "   AND SE1.D_E_L_E_T_=' ' "

cQuery += "   INNER JOIN " + retSQLName("FI7") + " FI7 " 
cQuery += "      ON FI7.FI7_FILIAL=E1_FILIAL "
cQuery += "     AND FI7.FI7_PRFORI=E1_PREFIXO "
cQuery += "     AND FI7.FI7_NUMORI=E1_NUM "
cQuery += "     AND FI7.FI7_PARORI=E1_PARCELA "
cQuery += "     AND FI7.FI7_TIPORI=E1_TIPO "
cQuery += "     AND FI7.FI7_CLIORI=E1_CLIENTE "
cQuery += "     AND FI7.FI7_LOJORI=E1_LOJA "
cQuery += "     AND FI7.D_E_L_E_T_=' ' "

cQuery += " Inner Join " + retsqlName("SE1") + " SE1_NEG "
cQuery += " On "
cQuery += " SE1_NEG.E1_FILIAL=FI7.FI7_FILDES "
cQuery += " AND SE1_NEG.E1_PREFIXO=FI7.FI7_PRFDES "
cQuery += " AND SE1_NEG.E1_NUM=FI7.FI7_NUMDES "
cQuery += " AND SE1_NEG.E1_PARCELA=FI7.FI7_PARDES "
cQuery += " AND SE1_NEG.E1_TIPO=FI7.FI7_TIPDES "
cQuery += " AND SE1_NEG.E1_CLIENTE=FI7.FI7_CLIDES "
cQuery += " AND SE1_NEG.E1_LOJA=FI7.FI7_LOJDES "
cQuery += " AND SE1_NEG.E1_TIPOLIQ IN ( 'LIQ', 'NEG' ) "
cQuery += " AND SE1_NEG.D_E_L_E_T_=' ' "

cQuery += " Inner Join " + retsqlName("FK7") + " FK7 " 
cQuery += " On "
cQuery += " FK7_FILIAL='" + xFilial("FK7") + "' "
cQuery += " AND FK7_ALIAS='SE1' "

If(SubStr(Alltrim(Upper(TCGetDb())),1,6)) == "ORACLE"
	cQuery += " AND FK7_CHAVE=SE1_NEG.E1_FILIAL||'|'||SE1_NEG.E1_PREFIXO||'|'||SE1_NEG.E1_NUM||'|'||SE1_NEG.E1_PARCELA||'|'||SE1_NEG.E1_TIPO||'|'||SE1_NEG.E1_CLIENTE||'|'||SE1_NEG.E1_LOJA" + " "
Else
	cQuery += " AND FK7_CHAVE=SE1_NEG.E1_FILIAL+'|'+SE1_NEG.E1_PREFIXO+'|'+SE1_NEG.E1_NUM+'|'+SE1_NEG.E1_PARCELA+'|'+SE1_NEG.E1_TIPO+'|'+SE1_NEG.E1_CLIENTE+'|'+SE1_NEG.E1_LOJA" + " "
Endif

cQuery += " AND FK7.D_E_L_E_T_=' ' "

cQuery += " LEFT Join " + retSqlName("FK1") + " FK1 "
cQuery += " On "
cQuery += " FK1_FILIAL='" + xFilial("FK1") + "' "
cQuery += " AND FK1_IDDOC=FK7.FK7_IDDOC "
cQuery += " AND FK1.D_E_L_E_T_=' ' "

cQuery += " LEFT Join " + RetSqlName("FKA") + " FKA "
cQuery += " On "
cQuery += " FKA_FILIAL='" + xfilial("FKA") + "' "
cQuery += " AND FKA_TABORI='FK1' "
cQuery += " AND FKA_IDORIG=FK1.FK1_IDFK1 "
cQuery += " AND FKA.D_E_L_E_T_=' ' "
/*
cQuery += " LEFT JOIN " + oFK5FK7:getRealName() + " TrueFK57 "
cQuery += " On "
cQuery += " TrueFK57.FKA_IDPROC=FKA.FKA_IDPROC "
*/
// Família
cQuery += "INNER JOIN "+RetSqlName("BA3")+" BA3 "
cQuery += "   ON BA3_FILIAL='"+xFilial('BA3')+"' "
cQuery += "  AND BA3_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BA3_CODEMP=BM1.BM1_CODEMP "
cQuery += "  AND BA3_MATRIC=BM1.BM1_MATRIC "
cQuery += "  AND BA3.D_E_L_E_T_=' ' "

// Usuário
cQuery += "INNER JOIN "+RetSqlName("BA1")+" BA1 "
cQuery += "ON BA1_FILIAL='"+xFilial('BA1')+"' "
cQuery += "  AND BA1_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BA1_CODEMP=BM1.BM1_CODEMP "
cQuery += "  AND BA1_MATRIC=BM1.BM1_MATRIC "
cQuery += "  AND BA1_TIPREG=BM1.BM1_TIPREG "
cQuery += "  AND BA1.D_E_L_E_T_=' ' "

// Usuário Titular
cQuery += "LEFT JOIN "+RetSqlName("BA1")+" TIT "
cQuery += "ON TIT.BA1_FILIAL='"+xFilial("BA1")+"' "
cQuery += "  AND TIT.BA1_CODINT=BM1.BM1_CODINT "
cQuery += "  AND TIT.BA1_CODEMP=BM1.BM1_CODEMP "
cQuery += "  AND TIT.BA1_MATRIC=BM1.BM1_MATRIC "
cQuery	+= "  AND TIT.BA1_RESFAM='1' "
cQuery	+= "AND TIT.D_E_L_E_T_=' ' "

// Produto Saúde
cQuery += "INNER JOIN "+RetSqlName("BI3")+" BI3 "
cQuery += "ON BI3_FILIAL='"+xFilial("BI3")+"' "
cQuery += " AND BI3_CODINT=BM1.BM1_CODINT "

If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"		
	cQuery += "  AND ( BI3_CODIGO=DECODE(BA1.BA1_CODPLA, '    ', BA3.BA3_CODPLA, BA1.BA1_CODPLA) "
	cQuery += "  AND BI3_VERSAO=DECODE(BA1.BA1_VERSAO, '   ', BA3.BA3_VERSAO, BA1.BA1_VERSAO) ) "
Else
	cQuery += "  AND BI3_CODIGO=("
	cQuery += "CASE WHEN BA1.BA1_CODPLA=' ' THEN BA3.BA3_CODPLA "
	cQuery += "ELSE BA1.BA1_CODPLA END) "
	cQuery += "  AND BI3_VERSAO=("
	cQuery += "CASE WHEN BA1.BA1_VERSAO=' ' THEN BA3.BA3_VERSAO "
	cQuery += "ELSE BA1.BA1_VERSAO END) "
EndIf
cQuery += "  AND BI3.D_E_L_E_T_=' ' "

// Tabela Tipos de Títulos
cQuery += "INNER JOIN "+RetSqlName("SX5")+" SX5 "
cQuery += "ON SX5.X5_FILIAL='"+xFilial('SX5')+"' "
cQuery += "  AND SX5.X5_TABELA='05' "
cQuery += "  AND SX5.X5_CHAVE=SE1.E1_TIPO "
cQuery += "  AND SX5.D_E_L_E_T_= ' ' "

// Grupo Empresa
cQuery += "INNER JOIN "+RetSqlName("BG9")+" BG9 "
cQuery += "ON BG9_FILIAL='"+xFilial('BG9')+"' "
cQuery += "  AND BG9_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BG9_CODIGO=BM1.BM1_CODEMP "
cQuery += "  AND BG9.D_E_L_E_T_=' ' "

// Contrato
cQuery += "LEFT JOIN "+RetSqlName("BT5")+" BT5 "
cQuery += "ON BT5_FILIAL='"+xFilial('BT5')+"' "
cQuery += "  AND BT5_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BT5_CODIGO=BM1.BM1_CODEMP "
cQuery += "  AND BT5_NUMCON=BM1.BM1_CONEMP "
cQuery += "  AND BT5_VERSAO=BM1.BM1_VERCON "
cQuery += "  AND BT5.D_E_L_E_T_= ' ' "

// Versões dos Contratos
cQuery += "LEFT JOIN "+RetSqlName("BQB")+" BQB "
cQuery += "ON BQB_FILIAL='"+xFilial('BQB')+"' "
cQuery += "  AND BQB_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BQB_CDEMP=BM1.BM1_CODEMP "
cQuery += "  AND BQB_NUMCON=BM1.BM1_CONEMP "
cQuery += "  AND BQB_VERSAO=BM1.BM1_VERCON "
cQuery += "  AND BQB.D_E_L_E_T_= ' ' "

// SubContratos
cQuery += "LEFT JOIN "+RetSqlName("BQC")+" BQC "
cQuery += "ON BQC_FILIAL='"+xFilial('BQB')+"' "
cQuery += "  AND BQC_CODINT=BM1.BM1_CODINT "
cQuery += "  AND BQC_CODEMP=BM1.BM1_CODEMP "
cQuery += "  AND BQC_NUMCON=BM1.BM1_CONEMP "
cQuery += "  AND BQC_VERCON=BM1.BM1_VERCON "
cQuery += "  AND BQC_SUBCON=BM1.BM1_SUBCON "
cQuery += "  AND BQC_VERSUB=BM1.BM1_VERSUB "
cQuery += "  AND BQC.D_E_L_E_T_=' ' "

cQuery += " WHERE "
//cQuery += " COALESCE(TRUEFK57.FKA_IDPROC, '0')='0' "
cQuery	+= "  BM1.D_E_L_E_T_=' ' "
cQuery += " AND FK1.FK1_IDDOC IS NOT NULL "
// Filtra Lançamentos conforme retorno do ponto de entrada
If Len(aPtoQuery) > 0
	For nPos := 1 to Len(aPtoQuery)
		cQuery += IIf( nPos==1, "AND BM1_CODTIP IN('"+aPtoQuery[nPos,1], "'"+aPtoQuery[nPos,1] )
		cQuery += IIf( Len(aPtoQuery)>1, IIf(Len(aPtoQuery)==nPos,  "') ", "',"), "') ")
	Next
Else

	//Se Benef.Operadoras, filtra tipo de movimentação coparticipação          
	If MV_PAR06 == 1		// Beneficiário da Operadora 

		cQuery	+= "AND BM1_CODTIP IN ('101','102','103','107','108','109','110','111','113','117','118','128','129','130','131','132','133','135','136','146','180','184','186','188','189','190','191') "
		cQuery	+= "AND BT5_INTERC <> '1' "

	//Se Coparticipação, filtra tipos de movimentacao                          
	ElseIf MV_PAR06 == 2	// Coparticipação

		cQuery	+= "AND BM1_CODTIP IN ('104','116','120','121','122','123','124','125','127','134','137','138','139','140','141','142','143','144','145','147','148','149','150','151','152','153','154','155','156','157','158','159','160','161','162','163','164','165','166','167','168','169','170','171','172','173','174','175','176','177','181','185') "
		cQuery	+= "AND BT5_INTERC <> '1' "

	//Se Benef.Outras Operadoras, trata somente contratos de Intercambio.      
	ElseIf MV_PAR06 == 3

		cQuery	+= "AND BT5_INTERC='1' "

	//Se Rel.Plan.Odonto, filtra tipo de movimentação odontologico             
	ElseIf MV_PAR06 == 4 

		cQuery	+= "AND BM1_CODTIP IN ('131','132') "
		cQuery	+= "AND BT5_INTERC <> '1' "

	//Se Rel.Pl.Med.Hosp, exclui tipo de movimentação odontologico             
	ElseIf MV_PAR06 == 5 

		cQuery	+= "AND BM1_CODTIP NOT IN ('131','132') "
		cQuery	+= "AND BT5_INTERC <> '1' "

	EndIf

EndIf

cQuery	+= cWhere		// Adição do conteúdo do ponto de entrada, caso exista.
//cQuery  += " AND BM1_NUMTIT IN( 'xxxx') "//cQuery  += " AND BM1_NUMTIT ='001117772' "
//cQuery  += " AND BM1_NUMTIT IN('001117812', '001082331') "
//cQuery  += " AND BM1_NUMTIT='001336691' "
//cQuery += " AND BM1_MATRIC='010696' "
//cQuery	+= "  AND BM1.D_E_L_E_T_=' ' "
//cQuery  += " AND BM1_NUMTIT IN('000942518', '001297911', '001301496', '001344814', '001294497') "

cQuery	+= "ORDER BY SE1REC, BM1_ANO,BM1_MES,BI3_CODSEG,BI3_MODPAG,BI3_DTAPPR,BI3_TIPCON,E1_EMISSAO,"
cQuery	+= "BM1_CODINT,BM1_CODEMP,BM1_CONEMP,BM1_VERCON,BM1_SUBCON,BM1_VERSUB,BM1_MATRIC,BM1_TIPREG "

nHandle := fCreate('c:\temp\Qry462a.sql', 0)

if nHandle > 0
	fWrite(nHandle, CHR(13)+CHR(10)+cQuery+CHR(13)+CHR(10) )
	fClose(nHandle)
endif

//MPSysOpenQuery( cQuery, 'QRYTMP' )
//cQuery := ""
/*
TCSetField("QRYTMP","BM1_VALOR","N",16,2)
TCSetField("QRYTMP","E1_VALOR","N",16,2)
TCSetField("QRYTMP","E1_SALDO","N",16,2)
TCSetField("QRYTMP","BI3_DTAPPR","D",08,0)
TCSetField("QRYTMP","VENCTO","D",08,0)
TCSetField("QRYTMP","BM1REG","N",16,0)
TCSetfield("QRYTMP","VALNEG","N",16,2)
TCSetField("QRYTMP","VALSLDPAS","N",16,2)
*/
//conout('Passou pela criação da tabela principal'  + ' : ' + Time() )

//Criação da Temporaria para Evitar recalculo de saldo do Titulo
aFields := {}
aadd(aFields,{"CHAVE","C",40,0})
aadd(aFields,{"VALOR1","N",16,2})
aadd(aFields,{"VALOR2","N",16,2})

//dbSelectArea("QRYTMP")
//QRYTMP->(dbGoTop())
//yfiltro := QRYTMP->BM1REG
dbSelectArea('UPDALI') 
//Append From 'QRYTMP' While !(QRYTMP->(EoF())) .AND. QRYTMP->BM1REG == yfiltro
//UPDALI->(dbGoTop())

/*

cQuery	+= "SELECT BM1_CODINT,BM1_CODEMP,BM1_CONEMP,BM1_VERCON,BM1_SUBCON,BM1_VERSUB,"
cQuery	+= "BM1_MATRIC,BM1_TIPREG,BM1_DIGITO,BA1.BA1_DATINC," 
cQuery	+= "BM1_MES,BM1_ANO,BM1_VALOR, BM1.R_E_C_N_O_ AS BM1REG,"
cQuery	+= "BM1_TIPO,BM1_TIPTIT,BM1_PREFIX AS PREFIXO, BM1_NUMTIT AS NUMERO, BM1_PARCEL AS PARCELA,BM1_CODTIP,BM1_CODEVE,"
cQuery	+= "BM1_ALIAS, BM1_ORIGEM, BM1_PLNUCO,"
cQuery	+= "BI3.BI3_DTAPPR,BI3.BI3_CODSEG,BI3.BI3_MODPAG,BI3.BI3_TIPCON,"
cQuery	+= "TIT.BA1_NOMUSR NOMTIT, TIT.BA1_CPFUSR CPFTIT," 
cQuery	+= "BG9.BG9_TIPO,BG9.BG9_DESCRI,BT5.BT5_INTERC,BT5.BT5_TIPOIN,BQB.BQB_DATINI,BQB.BQB_DATFIN,BQC.BQC_DESCRI," 
cQuery	+= "SE1.E1_VENCREA AS VENCTO, "	
cQuery	+= "SE1.E1_SALDO, SE1.E1_VALOR, SE1.E1_EMISSAO, SX5.X5_DESCRI AS DESCDOC,"
cQuery	+= " ' ' AS TIPCOB, '      ' AS MESLCT, 'NG5' TIPOZ, 0 VALNEG, SE1.E1_VALLIQ VALSLDPAS, 'OK' LINOK, ' ' IDDOCZ "
*/

//cUpd	:= " DELETE FROM " + oUpdTable:GetRealName()

//nStatus := TCSQLExec(cUpd)

cUpd 	:= " INSERT INTO " + oUpdTable:GetRealName()

cUpd	+= "( BM1_CODINT,BM1_CODEMP,BM1_CONEMP,BM1_VERCON,BM1_SUBCON,BM1_VERSUB,"
cUpd	+= "BM1_MATRIC,BM1_TIPREG,BM1_DIGITO,BA1_DATINC," 
cUpd	+= "BM1_MES,BM1_ANO,BM1_VALOR, BM1REG,"
cUpd	+= "BM1_TIPO,BM1_TIPTIT, PREFIXO,  NUMERO, PARCELA,BM1_CODTIP,BM1_CODEVE,"
cUpd	+= "BM1_ALIAS, BM1_ORIGEM, BM1_PLNUCO,"
cUpd	+= "BI3_DTAPPR,BI3_CODSEG,BI3_MODPAG,BI3_TIPCON,"
cUpd	+= " NOMTIT, CPFTIT," 
cUpd	+= "BG9_TIPO,BG9_DESCRI,BT5_INTERC,BT5_TIPOIN,BQB_DATINI,BQB_DATFIN,BQC_DESCRI," 
cUpd	+= " VENCTO, "	
cUpd	+= "E1_SALDO, E1_VALOR, E1_EMISSAO, DESCDOC,"
cUpd	+= " TIPCOB, MESLCT, TIPOZ, VALNEG, VALSLDPAS,  LINOK,  IDDOCZ, TOT_NES, TOT_ES, SE1REC, VALFI7, PARNEG, BI3_SUSEP, BM1VLRORI ) "
cUpd 	+= cQuery
/*
cUpd	+= " (BM1_CODINT,BM1_CODEMP,BM1_CONEMP,BM1_VERCON,BM1_SUBCON,BM1_VERSUB,"
cUpd	+= "BM1_MATRIC,BM1_TIPREG,BM1_DIGITO,BA1_DATINC," 
cUpd	+= "BM1_MES,BM1_ANO,BM1_VALOR, BM1REG,"
cUpd	+= "BM1_TIPO,BM1_TIPTIT, PREFIXO, NUMERO, PARCELA,BM1_CODTIP,BM1_CODEVE,"
cUpd	+= "BM1_ALIAS, BM1_ORIGEM, BM1_PLNUCO,"
cUpd	+= "BI3_DTAPPR,BI3_CODSEG,BI3_MODPAG,BI3_TIPCON,"
cUpd	+= " NOMTIT, CPFTIT," 
cUpd	+= "BG9_TIPO,BG9_DESCRI,BT5_INTERC,BT5_TIPOIN,BQB_DATINI,BQB_DATFIN,BQC_DESCRI," 
cUpd 	+= " VENCTO, "	
cUpd	+= " E1_SALDO, E1_VALOR, E1_EMISSAO, DESCDOC,"
cUpd	+= " TIPCOB, MESLCT, TIPOZ, VALNEG, VALSLDPAS, LINOK, IDDOCZ) "
//cUpd 	+= cQuery

cUpd	+= " SELECT BM1_CODINT,BM1_CODEMP,BM1_CONEMP,BM1_VERCON,BM1_SUBCON,BM1_VERSUB,"
cUpd	+= "BM1_MATRIC,BM1_TIPREG,BM1_DIGITO,BA1_DATINC," 
cUpd	+= "BM1_MES,BM1_ANO,BM1_VALOR, BM1REG,"
cUpd	+= "BM1_TIPO,BM1_TIPTIT, PREFIXO, NUMERO, PARCELA,BM1_CODTIP,BM1_CODEVE,"
cUpd	+= "BM1_ALIAS, BM1_ORIGEM, BM1_PLNUCO,"
cUpd	+= "BI3_DTAPPR,BI3_CODSEG,BI3_MODPAG,BI3_TIPCON,"
cUpd	+= " NOMTIT, CPFTIT," 
cUpd	+= "BG9_TIPO,BG9_DESCRI,BT5_INTERC,BT5_TIPOIN,BQB_DATINI,BQB_DATFIN,BQC_DESCRI," 
cUpd 	+= " VENCTO, "	
cUpd	+= " E1_SALDO, E1_VALOR, E1_EMISSAO, DESCDOC,"
cUpd	+= " TIPCOB, MESLCT, TIPOZ, VALNEG, VALSLDPAS, LINOK, IDDOCZ "
cUpd	+= " From " + ( cQuery //oUpdTable:GetRealName()
*/
nStatus := TCSQLExec(cUpd)


//conout('finalizou montagem da tabela principal' + ' : ' + Time() )

cUpd := " UPDATE " + oUpdTable:GetRealName()
cUpd += " SET BM1_VALOR=CASE "
cUpd += "   WHEN E1_VALOR=0 THEN 0 "
cUpd += "   WHEN LINOK <> 'OK'  AND TIPOZ IN ('NG1') THEN 0 " //O X marca o local
//cUpd += "   WHEN BM1_TIPO='2'  AND TIPOZ IN ('NG1', 'NG2') THEN ( (BM1_VALOR / E1_VALOR) * ( E1_VALOR - (E1_VALOR - ( CASE WHEN E1_SALDO > 0 THEN E1_SALDO WHEN VALSLDPAS > 0 THEN VALSLDPAS ELSE 0 END )) ) * - 1 ) " //O X marca o local 
//cUpd += "   WHEN BM1_TIPO <> '2' AND TIPOZ IN ('NG1', 'NG2') THEN ( (BM1_VALOR / E1_VALOR) * ( E1_VALOR - (E1_VALOR - ( CASE WHEN E1_SALDO > 0 THEN E1_SALDO WHEN VALSLDPAS > 0 THEN VALSLDPAS ELSE 0 END )) ) ) "
//cUpd += "   WHEN BM1_TIPO='2'  AND TIPOZ IN ('NG3', 'NG4') THEN ( (BM1_VALOR / E1_VALOR) * ( VALNEG ) * (VALFI7 / VALSLDPAS) * - 1 ) " //O X marca o local 
//cUpd += "   WHEN BM1_TIPO <> '2' AND TIPOZ IN ('NG3', 'NG4') THEN ( (BM1_VALOR / E1_VALOR) * ( VALNEG ) * (VALFI7 / VALSLDPAS) ) "
cUpd += "   WHEN BM1_TIPO='2'  AND TIPOZ IN ('NG4') THEN ( (BM1_VALOR / E1_VALOR) * ( VALFI7 ) * (E1_VALOR / VALSLDPAS) * - 1 ) " //O X marca o local 
cUpd += "   WHEN BM1_TIPO <> '2' AND TIPOZ IN ('NG4') THEN ( (BM1_VALOR / E1_VALOR) * ( VALFI7 ) * (E1_VALOR / VALSLDPAS) ) "
cUpd += "   WHEN BM1_TIPO='2'  AND TIPOZ IN ('NG3') THEN ( (BM1_VALOR / E1_VALOR) * ( VALFI7 ) * (E1_VALOR / VALSLDPAS) * - 1 ) " //O X marca o local 
cUpd += "   WHEN BM1_TIPO <> '2' AND TIPOZ IN ('NG3') THEN ( (BM1_VALOR / E1_VALOR) * ( VALFI7 ) * (E1_VALOR / VALSLDPAS) ) "

//cUpd += "   WHEN BM1_TIPO='2'  AND TIPOZ IN ('NG1', 'NG2') THEN ( (BM1_VALOR / E1_VALOR) * ( E1_VALOR - (E1_VALOR - ( CASE WHEN E1_SALDO > 0 THEN E1_SALDO ELSE 0 END )) ) * - 1 ) " //O X marca o local 
//cUpd += "   WHEN BM1_TIPO <> '2' AND TIPOZ IN ('NG1', 'NG2') THEN ( (BM1_VALOR / E1_VALOR) * ( E1_VALOR - (E1_VALOR - ( CASE WHEN E1_SALDO > 0 THEN E1_SALDO ELSE 0 END )) ) ) "
//cUpd += "   WHEN BM1_TIPO='2'  AND TIPOZ IN ('NG1', 'NG2', 'NG6') THEN ( (BM1_VALOR / E1_VALOR) * ( E1_VALOR - TOT_NES + TOT_ES ) * - 1 ) " //O X marca o local 
//cUpd += "   WHEN BM1_TIPO <> '2' AND TIPOZ IN ('NG1', 'NG2', 'NG6') THEN ( (BM1_VALOR / E1_VALOR) * ( E1_VALOR - TOT_NES + TOT_ES ) ) "
cUpd += "   WHEN BM1_TIPO='2'  AND TIPOZ IN ('NG1', 'NG6') THEN ( (BM1_VALOR / E1_VALOR) * ( E1_VALOR - TOT_NES + TOT_ES ) * - 1 ) " //O X marca o local 
cUpd += "   WHEN BM1_TIPO <> '2' AND TIPOZ IN ('NG1', 'NG6') THEN ( (BM1_VALOR / E1_VALOR) * ( E1_VALOR - TOT_NES + TOT_ES ) ) "

//cUpd += "   WHEN BM1_TIPO='2'  AND TIPOZ IN ('NG3', 'NG4') THEN ( (BM1_VALOR / E1_VALOR) * ( VALNEG - (VALNEG - ( CASE WHEN E1_SALDO > 0 THEN E1_SALDO ELSE 0 END )) ) * - 1 ) " //O X marca o local 
//cUpd += "   WHEN BM1_TIPO <> '2' AND TIPOZ IN ('NG3', 'NG4') THEN ( (BM1_VALOR / E1_VALOR) * ( VALNEG - (VALNEG - ( CASE WHEN E1_SALDO > 0 THEN E1_SALDO ELSE 0 END )) ) ) "
//1
cUpd += "   WHEN BM1_TIPO='2' AND VALSLDPAS > 0  AND TIPOZ IN ('NG5') AND VALSLDPAS > TOT_NES - TOT_ES THEN ( (BM1_VALOR / E1_VALOR) * ( VALNEG - (VALNEG - VALSLDPAS) ) * -1 ) " //O X marca o local
cUpd += "   WHEN BM1_TIPO <> '2'AND VALSLDPAS > 0  AND TIPOZ IN ('NG5') AND VALSLDPAS > TOT_NES - TOT_ES THEN ( (BM1_VALOR / E1_VALOR) * ( VALNEG - (VALNEG - VALSLDPAS) ) ) "
cUpd += "   WHEN BM1_TIPO='2' AND VALSLDPAS > 0  AND TIPOZ IN ('NG5') AND VALSLDPAS=TOT_NES - TOT_ES THEN ( (BM1_VALOR / E1_VALOR) * ( VALFI7 ) * -1 ) " //O X marca o local
cUpd += "   WHEN BM1_TIPO <> '2'AND VALSLDPAS > 0  AND TIPOZ IN ('NG5') AND E1_VALOR - TOT_NES - TOT_ES < 0.01 THEN ( (BM1_VALOR / E1_VALOR) * ( VALFI7 ) ) "

cUpd += "   WHEN BM1_TIPO='2'  AND TIPOZ IN ('NG2') THEN ( BM1_VALOR * -1 ) "
//- TOT_NES + TOT_ES
cUpd += " ELSE BM1_VALOR "
cUpd += " END "

If Len(aPtoQuery) > 0
	cUpd += ", TIPCOB=CASE "
	cUpd += cPtoQuery
	cUpd += " ELSE TIPCOB "
	cUpd += " END "
endIf
If Len(aPtoTpDoc) > 0 
	cUpd += ", DESCDOC=CASE "
	cUpd += cPtoTpDoc
	cUpd += " ELSE DESCDOC "
	cUpd += " END "
EndIf
/*
nHandle2 := fCreate('c:\temp\462upd.txt', 0)
fWrite(nHandle2, CHR(13)+CHR(10)+cUpd+CHR(13)+CHR(10) )
fClose(nHandle2)
*/
nStatus := TCSQLExec(cUpd)
//conout('Atualização de valores'  + ' : ' + Time() )
/*
cUpd := " UPDATE " + oUpdTable:GetRealName()
cUpd += " SET LINOK='ZC' "
cUpd += " Where "
*/
/*
if (nStatus < 0)
	
	nHandle3 := fCreate('c:\temp\462TCSQLError.txt', 0)
	fWrite(nHandle3, CHR(13)+CHR(10)+TCSQLError()+CHR(13)+CHR(10) )
	fClose(nHandle3)

	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "TCSQLError() " + TCSQLError(), 0, 0, {})	

endif
*/
cUpd 	:= " INSERT INTO " + oTempTable:GetRealName()

cUpd	+= " (BM1_CODINT,BM1_CODEMP,BM1_CONEMP,BM1_VERCON,BM1_SUBCON,BM1_VERSUB,"
cUpd	+= "BM1_MATRIC,BM1_TIPREG,BM1_DIGITO,BA1_DATINC," 
cUpd	+= "BM1_MES,BM1_ANO,BM1_VALOR, BM1REG,"
cUpd	+= "BM1_TIPO,BM1_TIPTIT, PREFIXO, NUMERO, PARCELA,BM1_CODTIP,BM1_CODEVE,"
cUpd	+= "BM1_ALIAS, BM1_ORIGEM, BM1_PLNUCO,"
cUpd	+= "BI3_DTAPPR,BI3_CODSEG,BI3_MODPAG,BI3_TIPCON,"
cUpd	+= " NOMTIT, CPFTIT," 
cUpd	+= "BG9_TIPO,BG9_DESCRI,BT5_INTERC,BT5_TIPOIN,BQB_DATINI,BQB_DATFIN,BQC_DESCRI," 
cUpd 	+= " VENCTO, "	
cUpd	+= " E1_SALDO, E1_VALOR, E1_EMISSAO, DESCDOC,"
cUpd	+= " TIPCOB, MESLCT, TIPOZ, IDDOCZ, TOT_NES, TOT_ES, SE1REC, BI3_SUSEP,BM1VLRORI, VALFI7, VALNEG, VALSLDPAS) "

cUpd	+= " SELECT BM1_CODINT,BM1_CODEMP,BM1_CONEMP,BM1_VERCON,BM1_SUBCON,BM1_VERSUB,"
cUpd	+= "BM1_MATRIC,BM1_TIPREG,BM1_DIGITO,BA1_DATINC," 
cUpd	+= "BM1_MES,BM1_ANO,BM1_VALOR, BM1REG,"
cUpd	+= "BM1_TIPO,BM1_TIPTIT, PREFIXO, NUMERO, PARCELA,BM1_CODTIP,BM1_CODEVE,"
cUpd	+= "BM1_ALIAS, BM1_ORIGEM, BM1_PLNUCO,"
cUpd	+= "BI3_DTAPPR,BI3_CODSEG,BI3_MODPAG,BI3_TIPCON,"
cUpd	+= " NOMTIT, CPFTIT," 
cUpd	+= "BG9_TIPO,BG9_DESCRI,BT5_INTERC,BT5_TIPOIN,BQB_DATINI,BQB_DATFIN,BQC_DESCRI," 
cUpd 	+= " VENCTO, "	
cUpd	+= " E1_SALDO, E1_VALOR, E1_EMISSAO, DESCDOC,"
cUpd	+= " TIPCOB, MESLCT, TIPOZ, IDDOCZ, TOT_NES, TOT_ES, SE1REC, BI3_SUSEP, BM1VLRORI, VALFI7, VALNEG, VALSLDPAS "
cUpd	+= " From " + oUpdTable:GetRealName()
cUpd	+= " ORDER BY SE1REC, BM1_ANO,BM1_MES,BI3_CODSEG,BI3_MODPAG,BI3_DTAPPR,BI3_TIPCON,E1_EMISSAO, "
cUpd	+= " BM1_CODINT,BM1_CODEMP,BM1_CONEMP,BM1_VERCON,BM1_SUBCON,BM1_VERSUB,BM1_MATRIC,BM1_TIPREG  "
nStatus := TCSQLExec(cUpd)

//conout('Inserção de valores'  + ' : ' + Time() )

//DELETE FROM table_name WHERE condition;
cUpd	:= " DELETE FROM " + oTempTable:GetRealName()
cUpd 	+= " Where "
cUpd 	+= " BM1_VALOR < 0.0001 AND BM1_VALOR > - 0.0001 "

nStatus := TCSQLExec(cUpd)

dbSelectArea('TRBLIV')
dbGoTop()

// Limpa os arrays
aSize(aPtoQuery,1)
aDel(aPtoQuery,1)
aSize(aPtoTpDoc,1)
aDel(aPtoTpDoc,1)
aSize(aFields,1)
aDel(aFields,1)

// Fecha os temporarios
//QRYTMP->(dbCloseArea())
UPDALI->(dbCloseArea())
//TPLFK57->(DbCloseArea())

oUpdTable:Delete()
//oFK5FK7:Delete()

//conout('Fim da preparação'  + ' : ' + Time() )

Return(lRet)


/*/{Protheus.doc} ocorrencias
Ocorrencias

@author DEV
@since 05/03/2016
@version ALL
/*/
static function ocorrencias(oOcorrencias,aLog)
local nTmp 	:= 0
local cTrb 	:= ""
local aStru := {}
local oTempTable

aadd(aStru,{"TIPREG" ,"C",003,0})
aadd(aStru,{"DESCR" ,"C",500,0})

//--< Criação do objeto FWTemporaryTable >---
oTempTable := FWTemporaryTable():New( "TRB" )
oTemptable:SetFields( aStru )
oTempTable:AddIndex( "INDTRB",{ "TIPREG" } )

if( select( "TRB" ) > 0 )
	TRB->( dbCloseArea() )
endIf

oTempTable:Create()

for nTmp := 1 to len(aLog)
	recLock("TRB",.t.)
		TRB->DESCR := aLog[nTmp]
	TRB->(MsUnlock())
next

//oOcorrencias:setMeter(("TRB")->(lastRec()))
oOcorrencias:pageBreak(.t.)
oOcorrencias:init()

dbSelectArea("TRB")
TRB->(dbGoTop())
while ! TRB->(eof())

	oOcorrencias:cell("DESCR"):setValue(TRB->DESCR)
	oOcorrencias:printLine()

	TRB->(dbSkip())
endDo

if( select( "TRB" ) > 0 )
	oTempTable:Delete()
endIf

oOcorrencias:finish()

return()



static function plRetXX(cData, cIdFK1,lNG8)

Local cTTCMPES := ""
Local nRet := 0
Local nX	:= IIF(Empty(asumXX), 0, ascan( asumXX, { |x| x[1] == cIdFK1} ) )
lDtCTB	:= getNewPar("MV_PLDTREC", '0') == '0'
If nX == 0

	cTTCMPES := QryRetXX(cData, cIdFK1,lNG8)

	nRet := (cTTCMPES)->(TOT_NES) - (cTTCMPES)->(TOT_ES)
	
	If nret < 0
		nRet := 0
	EndIf
	
	If Len(asumXX) > 500
		asumXX := {}
	EndIf
	
	aadd( asumXX, { cIdFK1, nret} )
	
	(cTTCMPES)->(DbcloseArea())
else
	nRet := asumXX[nX][2]
endIf

return nRet


/* funcao para criacao de uma tabela temporária em tempo de execução para contornar problema de travamento na MPSysOpenQuery */
Static function CriaTempFK7(cTmpTbl, dDatDe, LDTCTB)
Local cSubStr		:= iIf( "SQL" $ allTrim( TCGetDB() ) ,'SUBSTRING',  'SUBSTR' )
Local csqlZ			:= ""			
Local nTamZTot 		:= 0
Local nTamZCmp 		:= 0
Local nZPosIniAnt	:= 0 
/*
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

cSqlZ += " FK2.FK2_DATA FK2_DATA, "
cSqlZ += " FK2.FK2_RECPAG FK2_RECPAG, "
cSqlZ += " FK2.FK2_IDFK2 FK2_IDFK2, "
cSqlZ += " FK2.FK2_MOTBX FK2_MOTBX, "
cSqlZ += " FK2.FK2_TPDOC FK2_TPDOC, "
cSqlZ += " FK2.R_E_C_N_O_ FK2RECNO "
cSqlZ += " FROM " + RetsqlName("FK7") + " FK7 "

cSqlZ += " INNER JOIN " + RetSqlName("FK2") + " FK2 "
cSqlZ += "   ON FK2.FK2_FILIAL='" + xfilial("FK2") + "' "
cSqlZ += "  AND FK2.FK2_IDDOC=FK7_IDDOC "
cSqlZ += "  AND FK2.D_E_L_E_T_=' ' "

cSqlZ += " WHERE FK7.FK7_FILIAL='" + xfilial("FK7") + "' "
cSqlZ += "   AND FK7.FK7_ALIAS='SE2' "
cSqlZ += "   AND FK7.D_E_L_E_T_=' ' "
*/

cSqlZ := " Select FKA_IDPROC, "

if lDtCTB
	cSqlZ += " FK5_DATA "
else
	cSqlZ += " FK5_DTDISP "
endIf	

cSqlZ += " from " + RetSqlName("FK5") + " FK5 "
cSqlZ += " Inner Join " + RetsqlName("FKA") + " FKA "
cSqlZ += " On "
cSqlZ += " FKA.FKA_FILIAL='" + xfilial("FKA") + "' "
cSqlZ += " AND FKA.FKA_IDORIG=FK5.FK5_IDMOV "
cSqlZ += " AND FKA.D_E_L_E_T_=' ' "
cSqlZ += " Where "
cSqlZ += " FK5.FK5_FILIAL='" + xFilial("FK5") + "' "

if lDtCTB
	cSqlZ += " AND FK5_DATA <= '" + dtos(dDatDe) + "' "
else
	cSqlZ += " AND FK5_DTDISP <= '" + dtos(dDatDe) + "' "
endIf	

cSqlZ += " AND FK5.D_E_L_E_T_=' ' "
cSqlZ += " AND FK5.FK5_TPDOC <> 'ES' "
//cSqlZ += " Order By "
//cSqlZ += " FKA_IDPROC "

nRet := TcSqlEXEC(" CREATE VIEW "+cTmpTbl+" AS " + cSqlZ) 

If nRet < 0
	tcsqlError()
	TcSqlEXEC("DROP VIEW "+cTmpTbl)
	if lOracle
		TcSqlEXEC("COMMIT") 
	endif
EndIf

nRet := TcSqlEXEC(" CREATE VIEW "+cTmpTbl+" AS " + cSqlZ) //SELECT * FROM " + oTmpTable:getrealName() )

if nRet >= 0
	if lOracle
		TcSqlEXEC("COMMIT") 
	endif
endif

Return

Static function Perinifim(cMesano)

Local aRet := { ctoD(""), cToD("") }
local cMes := ""
Local cAno := ""

cMes := substr(cMesano,1, 2)
cAno := substr(cMesAno, 3, 4)

If cMes == "01"
	cMes := "12"
	cAno := Alltrim(Str( Val(cAno) - 1))
else	
	cMes := Alltrim(Str( Val(cMes) - 1))
endIf

aret[1] := ctoD( "01" + "/" + cMes + "/" + cAno )
aret[2] := LastDay(aret[1])

return aRet

Static function parparpar(npilha,cfil, cpref, cnum, cpar, ctipo, ccli, cloj, nValI7, nPerBM1E1, dDatDe,nValK1NES)

Local cSql := ""
Local nRet := 0
Local nAux := 1
Local ctab := "parpar" + AllTrim(Str(npilha))
Local nI	:= 0
Local lZero := .F.
Local cSqldif := ""
Local ctab2 := "y62" + ctab
Local cDatax := DtoS( dDatDe)
Local aArea := {}
Local nCountV := 0
Local ncountT := 0
Local nValLiqI7 := 0
Local nBaixa	:= 0
default cfil := xfilial('FI7')
default nValK1NES := 0
If npilha == 0
	lZero := .T.
endIf
npilha++

cSql := QueryPar(npilha,cfil, cpref, cnum, cpar, ctipo, ccli, cloj, nValI7, nPerBM1E1, cDatax,nValK1NES)

dbUseArea(.T.,"TOPCONN",tcGenQry(,,cSql + cSqldif),ctab,.F.,.T.)

SE1->(Msseek(cfil+ cpref+ cnum+ cpar+ ctipo+ ccli+ cloj))
aArea := SE1->(Getarea())
If !((ctab)->(EoF()))
	SE1->(dbSetOrder(1))
	nValLiqI7 := fi7fi7fi7(cfil, cpref, cnum, cpar, ctipo, ccli, cloj)
	while !((ctab)->(EoF())) 
		nCountT++
		If (cTab)->(TEMFK) == "LOOP"
			(ctab)->(dbskip())
			Loop
		elseIf (cTab)->(TEMFK) == "TUDO"
			nAUx := (ctab)->(FI7_VALOR) //* nValI7 / SE1->E1_VALLIQ
		else
			nBaixa	:= 0
			//		SE1->(Msseek(cfil+ cpref+ cnum+ cpar+ ctipo+ ccli+ cloj))
			if !(EmpTy((cTab)->(IDDOC)))
				nBaixa := plRetXX(cDatax, (cTab)->(IDDOC),.T.)
			endIf
			nAux := parparpar(npilha,(ctab)->(FI7_FILDES), (ctab)->(FI7_PRFDES), (ctab)->(FI7_NUMDES), (ctab)->(FI7_PARDES), (ctab)->(FI7_TIPDES), (ctab)->(FI7_CLIDES), (ctab)->(FI7_LOJDES), (ctab)->(FI7_VALOR),nPerBM1E1, dDatDe, nBaixa)
			Restarea(aarea)
		endIf
			nRet += nAux  *  (SE1->E1_VALOR - nValK1NES )/ nValLiqI7 //SE1->E1_VALLIQ  //* nPerBM1E1

		nCountV++
		(ctab)->(dbskip())
	endDo
	nRet := nRet / ncountV // ncountT
else
	cSqldif := " AND (FK1.FK1_IDDOC IS NOT NULL AND FK1_MOTBX NOT IN( 'LIQ', 'NEG' ) ) "
	cSqlDif += " AND FK1.FK1_DTDISP <= '" + cDatax + "' "
	dbUseArea(.T.,"TOPCONN",tcGenQry(,,cSql + cSqldif),ctab2,.F.,.T.)
	If !((ctab2)->(EoF()))
		nRet := 0
	else
		nRet := nValI7
	endIf
	(ctab2)->(dbcloseArea())
endIf

If lZero
	Restarea(aarea)
	nRet := nRet * nValI7 / SE1->E1_VALOR
endIf
(ctab)->(dbcloseArea())

return nRet


static function fi7fi7fi7(cfil, cpref, cnum, cpar, ctipo, ccli, cloj)

	Local cFi7 := ""
	Local nRet := 0

	cFi7 := QueryFi7(cfil, cpref, cnum, cpar, ctipo, ccli, cloj)

	If !( (cFi7)->(EoF()) )
		nRet := (cFi7)->TOTFI7
	EndIf
	(cFi7)->(DbClosearea())

return nRet

/*/{Protheus.doc} QueryPar
	FWPreparedStatement
	@author Cesar Almeida
	@since 25/07/2022
	@version P12
/*/
Static Function QueryPar(npilha,cfil, cpref, cnum, cpar, ctipo, ccli, cloj, nValI7, nPerBM1E1, cDatax,nValK1NES)

	local oFwQuery := FWPreparedStatement():New()
	local cSql := ""
	local cAlias := ""

	cSql += " Select CASE when FK1.FK1_IDDOC IS NULL "
	cSql += " OR FK1.FK1_DTDISP > ? "
	cSql += " then 'TUDO' " 
	cSql += " When FK1.FK1_IDDOC IS NOT NULL AND FK1_MOTBX IN( 'LIQ', 'NEG' ) "
	cSql += " then 'NTUD' ELSE 'LOOP' END TEMFK, "
	cSql += " FI7_FILDES, FI7_PRFDES, FI7_PARDES, FI7_NUMDES, FI7_TIPDES, FI7_CLIDES, FI7_LOJDES, FI7_VALOR, COALESCE(FK1.FK1_IDDOC, ' ') IDDOC from " + retSqlName("FI7") + " FI7 "
	cSql += " Inner Join " + retsqlName("SE1") + " SE1_NEG "
	cSql += " On "
	cSql += " SE1_NEG.E1_FILIAL=FI7.FI7_FILDES "
	cSql += " AND SE1_NEG.E1_PREFIXO=FI7.FI7_PRFDES "
	cSql += " AND SE1_NEG.E1_NUM=FI7.FI7_NUMDES "
	cSql += " AND SE1_NEG.E1_PARCELA=FI7.FI7_PARDES "
	cSql += " AND SE1_NEG.E1_CLIENTE=FI7.FI7_CLIDES "
	cSql += " AND SE1_NEG.E1_LOJA=FI7.FI7_LOJDES "
	cSql += " AND SE1_NEG.D_E_L_E_T_=' ' "
	cSql += " Inner Join " + retsqlName("FK7") + " FK7 " 
	cSql += " On "
	cSql += " FK7_FILIAL= ? "
	cSql += " AND FK7_ALIAS='SE1' "

	If(SubStr(Alltrim(Upper(TCGetDb())),1,6)) == "ORACLE"
		cSql += " AND FK7_CHAVE=SE1_NEG.E1_FILIAL||'|'||SE1_NEG.E1_PREFIXO||'|'||SE1_NEG.E1_NUM||'|'||SE1_NEG.E1_PARCELA||'|'||SE1_NEG.E1_TIPO||'|'||SE1_NEG.E1_CLIENTE||'|'||SE1_NEG.E1_LOJA" + " "
	Else
		cSql += " AND FK7_CHAVE=SE1_NEG.E1_FILIAL+'|'+SE1_NEG.E1_PREFIXO+'|'+SE1_NEG.E1_NUM+'|'+SE1_NEG.E1_PARCELA+'|'+SE1_NEG.E1_TIPO+'|'+SE1_NEG.E1_CLIENTE+'|'+SE1_NEG.E1_LOJA" + " "
	Endif

	cSql += " AND FK7.D_E_L_E_T_=' ' "
	cSql += " LEFT Join " + retSqlName("FK1") + " FK1 "
	cSql += " On "
	cSql += " FK1_FILIAL= ? "
	cSql += " AND FK1_IDDOC=FK7.FK7_IDDOC "
	cSql += " AND FK1.D_E_L_E_T_=' ' "
	csql += " Where "
	cSql += " FI7_FILIAL= ? "
	cSql += " AND FI7_PRFORI= ? "
	cSql += " AND FI7_NUMORI= ? "
	cSql += " AND FI7_PARORI= ? "
	cSql += " AND FI7_TIPORI= ? "
	cSql += " AND FI7_CLIORI= ? "
	cSql += " AND FI7_LOJORI= ? "
	cSql += " AND FI7.D_E_L_E_T_=' ' "

	oFwQuery:SetQuery(cSql)
	oFwQuery:SetString(1,cDatax)
	oFwQuery:SetString(2, xFilial("FK7"))
	oFwQuery:SetString(3, xFilial("FK1"))
	oFwQuery:SetString(4, cfil)
	oFwQuery:SetString(5, cpref)
	oFwQuery:SetString(6, cnum)
	oFwQuery:SetString(7, cpar)
	oFwQuery:SetString(8, ctipo)
	oFwQuery:SetString(9, ccli)
	oFwQuery:SetString(10, cloj)
	
	cSql := oFwQuery:GetFixQuery()
	//cAlias := MpSysOpenQuery(cSql)

Return cSql

/*/{Protheus.doc} QueryFi7
	FWPreparedStatement
	@author Cesar Almeida
	@since 25/07/2022
	@version P12
/*/
Static Function QueryFi7(cfil, cpref, cnum, cpar, ctipo, ccli, cloj)

	local oFwQuery := FWPreparedStatement():New()
	local cSql := ""
	local cAlias := ""

	cSql += " Select SUM(FI7_VALOR) TOTFI7 "
	cSql += " From "  + RetsqlName("FI7") + " FI7 "
	csql += " Where "
	cSql += " FI7_FILIAL= ? "
	cSql += " AND FI7_PRFORI= ? "
	cSql += " AND FI7_NUMORI= ? "
	cSql += " AND FI7_PARORI= ? "
	cSql += " AND FI7_TIPORI= ? "
	cSql += " AND FI7_CLIORI= ? "
	cSql += " AND FI7_LOJORI= ? "
	cSql += " AND FI7.D_E_L_E_T_= ? "
	
	oFwQuery:SetQuery(cSql)
	oFwQuery:SetString(1, cfil)
	oFwQuery:SetString(2, cpref)
	oFwQuery:SetString(3, cnum)
	oFwQuery:SetString(4, cpar)
	oFwQuery:SetString(5, ctipo)
	oFwQuery:SetString(6, ccli)
	oFwQuery:SetString(7, cloj)
	oFwQuery:SetString(8, ' ')

	cSql := oFwQuery:GetFixQuery()
	cAlias := MpSysOpenQuery(cSql)
	
Return cAlias

/*/{Protheus.doc} QryRetXX
	FWPreparedStatement
	@author Cesar Almeida
	@since 25/07/2022
	@version P12
/*/
Static Function QryRetXX(cData, cIdFK1,lNG8)

	Local oFwQuery := FWPreparedStatement():New()
	Local cSql := ""
	Local cAlias := ""

	if lNG8
		csql += " select SUM( Case  when FK1_TPDOC='ES' then FK1_VALOR else 0 END ) TOT_ES, SUM( Case  when FK1_TPDOC NOT IN ('ES', 'BA') then FK1_VALOR else 0 END ) TOT_NES from "
	else
		csql += " select SUM( Case  when FK1_TPDOC='ES' then FK1_VALOR else 0 END ) TOT_ES, SUM( Case  when FK1_TPDOC <> 'ES' then FK1_VALOR else 0 END ) TOT_NES from "
	endif
	cSql +=  retSqlName("FK1") + " FK1_BX "
	cSql += " WHERE "
	cSql += " FK1_FILIAL= ? "
	csql += " AND FK1_IDDOC= ? "
	if lDtCTB
		csql += " AND FK1_DATA <= ? "
	else
		csql += " AND FK1_DTDISP <= ?"
	endIf
	cSql += " AND D_E_L_E_T_= ? "
	
	oFwQuery:SetQuery(cSql)
	oFwQuery:SetString(1, xFilial("FK1"))
	oFwQuery:SetString(2, cIdFK1)
	oFwQuery:SetString(3, cData)
	oFwQuery:SetString(4, ' ')

	cSql := oFwQuery:GetFixQuery()
	cAlias := MpSysOpenQuery(cSql)
	
Return cAlias
