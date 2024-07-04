#INCLUDE "PLSR463.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
STATIC ADLei := CtoD('31/12/1999')
Static asumXX	:= {}
Static aDtDisp := { .F., CtoD("") }

/*/{Protheus.doc} PLSR463
Registro de Receitas Recebidas - Operadora

@author DEV
@since 07/12/2016
@version ALL
Remodelado para atendimento a RN 390 - RC
/*/
Function PLSR463()
local oReport := nil
local cPerg	  := "PLR463"

Pergunte(cPerg,.t.)

If findFunction("TRepInUse") .And. TRepInUse()
	oReport := reportDef(cPerg)
	oReport:printDialog()
	freeObj(oReport)
Else
	msgAlert(STR0001)
EndIf

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
local dDatDe        := CtoD('01/'+StrZero(Val(MV_PAR01),2)+'/'+StrZero(Val(MV_PAR02),4))
local dDatAte       := LastDay(dDatDe)
Local cTexto		:= STR0002+' '+STR0044

Do Case
	Case MV_PAR07 == 1
		cTexto	+= STR0040		// Operadora 	
	Case MV_PAR07 == 2
		cTexto	+= STR0041		// Coparticipacao	
	Case MV_PAR07 == 3
		cTexto	+= STR0046		// Outras Operadoras  	
	Case MV_PAR07 == 4
		cTexto	+= STR0047		// Rel.Serviço Odontológico
	Case MV_PAR07 == 5
		cTexto	+= STR0048		// Rel.Plano Med.Hospitalar  	
EndCase

//objeto report
oReport := TReport():new("PLSR463",cTexto,nil,{|oReport| ReportPrint(oReport,oBGERAL,dDatDe,dDatAte,cTexto)},cTexto) //"Registro de Contraprestações Emitidas"
oReport:setTotalInLine(.f.)
oReport:setLandscape()

// Geração de listagem em PDF com totalizações
if MV_PAR06 == 1

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
TRCell():new(oSTITULO,"PARCELA"		,"TRBLIV", STR0035, "@!", 04)//"Parc"    
TRCell():new(oSTITULO,"DESCDOC"		,"TRBLIV", STR0033, "@!", 55)//"Descrição"       
TRcell():new(oSTITULO,"MESANO"		,"TRBLIV", STR0005,	"@R 99/9999", 07)//"Mês/Ano"
TRCell():new(oSTITULO,"VENCTO"		,"TRBLIV", STR0021, "@D", 10)//"Vct.Tit"
TRCell():new(oSTITULO,"BAIXA"		,"TRBLIV", STR0034, "@D", 10)//"Baixa"
TRCell():new(oSTITULO,"VALOR"		,"TRBLIV", STR0022, "@E 9,999,999,999.9999", 16)//"Valor"
TRCell():new(oSTITULO,"TIPCOB"		,"TRBLIV", STR0023, "@!", 15)//"Tipo Mensal."       
TRcell():new(oSTITULO,"MESLCT"		,"TRBLIV", STR0024,	"@!", 07)//"Mês Lct"
TRcell():new(oSTITULO,"CODTIP"		,"TRBLIV", STR0050,	"@!", 08)//"Cod.Fat"
TRcell():new(oSTITULO,"PLNUCO"		,"TRBLIV", STR0051,	"@!", 12)//"Lt.Cobr."
TRcell():new(oSTITULO,"BI3_SUSEP"   ,"TRBLIV", "Número do Registro do Produto", "@!", 12)//"N° Reg ANS"
TRcell():new(oSTITULO,"PER_COB_INI"  ,"TRBLIV", "Período da cobertura - ínicio", "@D", 10) //Período da cobertura assistencial referente a contraprestação (início e término)
TRcell():new(oSTITULO,"PER_COB_FIM"  ,"TRBLIV", "Período da cobertura - fim", "@D", 10)
//Ocorrências
oOCORRENCIAS:= TRSection():New(oReport,,{"TRB"})
TRCell():new(oOCORRENCIAS,"DESCR" ,"TRB"	,STR0025,,500)//"Ocorrências"


// Geração em PDF com totalizações
If MV_PAR06 == 1

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

Return(oReport)

/*/{Protheus.doc} ReportPrint
Impressao

@author DEV
@since 05/03/2016
@version ALL
/*/
static function ReportPrint(oReport,oBGERAL,dDatDe,dDatAte,cTexto)
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
local nTotReg		:= 0
local oSGERAL		:= IIf(MV_PAR06==1, oReport:section(1), oReport:section(3))
local oSMESANO 		:= IIf(MV_PAR06==1, oReport:section(2), oReport:section(4))
local oSSEGMPADL	:= IIf(MV_PAR06==1, oReport:section(3), oReport:section(5))
local oSTPCONTRATO	:= IIf(MV_PAR06==1, oReport:section(4), oReport:section(6))
local oSTITULO		:= IIf(MV_PAR06==1, oReport:section(5), oReport:section(1)) 
local oOCORRENCIAS	:= IIf(MV_PAR06==1, oReport:section(6), oReport:section(2))
Local cPlsCDIE		:= getNewPar("MV_PLSCDIE","1")
local lBaixaDisp := (MV_PAR08 == 1) .AND. ( FK1->(FieldPos("FK1_DTDISP")) > 0 )
Local oTempTable	:= nil
Local nLastRec	:= 0
Local nAcumRec	:= 0
Local nLastRecK1	:= 0
Local nVal1		:= 0
Local nVal2		:= 0
Local lchkVal		:= .F.
Local nValAc		:= 0
Local nValK1Ant	:= 0
Local adatas := { ctoD(""), cToD("") }
Local lTipoY	:= .F.
Local nValY	:= 0

Default cTexto		:= STR0001
private cNroLvr     := "0001"
private cDesc1      := STR0002
private cSigaadv    := Upper(AllTrim(GetPvProfString( GetEnvServer(), "StartPath", "", GetADV97() )))
private nPagina     := 0

If ! getTrbQuery(@lLivro,@lLog,dDatDe,dDatAte,@oTempTable)
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

TRBLIV->(dbGotop())
nTotReg := TRBLIV->(LASTREC())

oReport:setMeter(TRBLIV->(nTotReg))

TRBLIV->(dbGoTop())

If !TRBLIV->(EoF())

	oHashPar := tHashMap():New()
	
	If MV_PAR06 == 1
		oSGERAL:init()	
	EndIf

	if empty(alias())
		dbselectarea('SE1')
	endIf
	
	while !oReport:cancel() .and. !TRBLIV->(eof())
		
		oReport:incMeter()

		if oReport:Cancel()
			Exit
		endIf
		
		//If TRBLIV->(ORIGEM) <> TRBLIV->(FK1ORI)
		// TRBLIV->(dbSkip())
		// Loop
		//endIf
		
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
 
   		If cMesAno <> TRBLIV->(BM1_MES+BM1_ANO) 

			nSeq := 1

			If !empty(cMesAno) .and. MV_PAR06 == 1 
				//reiniciar ar quebras por tipo de contrato, cobertura, modpag e ad lei
				cSeMpADl := ''
		 		cTipCon	 := ''
				oSTPCONTRATO:finish()
				oSSEGMPADL:finish()
				oSMESANO:finish()
			EndIf
			
			cMesAno := TRBLIV->(BM1_MES+BM1_ANO)

			If MV_PAR06 == 1 
				//inicia sessao
				oSMESANO:init()	
				//alimenta celulas
				oSMESANO:cell("MESANO"):setValue(cMesAno)
				//imprime o conteudo das celulas na linha
				oSMESANO:printLine()
			EndIf	
			nLastRec := TRBLIV->FK1REC
			nAcumRec := 0
		EndIf
		
		If TRBLIV->FK1REC <> nLastRec
			nLastRec := TRBLIV->FK1REC
			nAcumRec := 0
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
		cModPag := x3combo("BI3_MODPAG",TRBLIV->BI3_MODPAG)
	
		//data aprovacao do produto pela ans
		cADLei := IIf( TRBLIV->BI3_DTAPPR <= ADLei, 'Antes da lei','Depois da lei' )

		If MV_PAR06 == 1		
		
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
				oSSEGMPADL:cell("SEGMODADLEI"):setValue(cDescSeg + " " + cModPag + " " + cADLei)
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
				cTipCon := ''
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
		
		if lBaixaDisp
		    oSTITULO:cell("BAIXA"):setValue(TRBLIV->BAIXA_DISP)  
		else
           oSTITULO:cell("BAIXA"):setValue(IIF(!Empty(TRBLIV->FK1_DATA),TRBLIV->FK1_DATA,TRBLIV->E1_BAIXA))
		endif
		nValAc	 := IIF( AllTrim(TRBLIV->FKTPDOC) == "ES" .AND. TRBLIV->BM1_VALOR > 0, TRBLIV->BM1_VALOR * -1, TRBLIV->BM1_VALOR)
		nAcumRec += nValAc
		//		If nAcumRec > TRBLIV->FK1_VALOR
		//			oSTITULO:cell("VALOR"):setValue( TRBLIV->FK1_VALOR - nAcumRec + IIF( AllTrim(TRBLIV->FKTPDOC) == "ES", TRBLIV->BM1_VALOR * -1, TRBLIV->BM1_VALOR) )
		//		else
		//			oSTITULO:cell("VALOR"):setValue(IIF( AllTrim(TRBLIV->FKTPDOC) == "ES", TRBLIV->BM1_VALOR * -1, TRBLIV->BM1_VALOR))
		//		endIf
		oSTITULO:cell("TIPCOB"):setValue(IIf(TRBLIV->TIPCOB=='1','Participante','Patronal'))
		oSTITULO:cell("MESLCT"):setValue(cMesLct)
		oSTITULO:cell("CODTIP"):setValue(TRBLIV->BM1_CODTIP)
		oSTITULO:cell("PLNUCO"):setValue(TRBLIV->BM1_PLNUCO) 
		oSTITULO:cell("BI3_SUSEP"):setValue(TRBLIV->BI3_SUSEP)
		aDatas := Perinifim(cMesano)
		oSTITULO:cell("PER_COB_INI"):setValue(aDatas[1])
		oSTITULO:cell("PER_COB_FIM"):setValue(aDatas[2])
		
		nLastRecK1 := TRBLIV->(FK1REC)
		nVal1 := IIF( AllTrim(TRBLIV->FKTPDOC) == "ES" .AND. TRBLIV->BM1_VALOR > 0, TRBLIV->FK1_VALOR - nAcumRec * -1, TRBLIV->FK1_VALOR - nAcumRec)  + IIF( AllTrim(TRBLIV->FKTPDOC) == "ES", TRBLIV->BM1_VALOR * -1, TRBLIV->BM1_VALOR)
		nVal2 := IIF( AllTrim(TRBLIV->FKTPDOC) == "ES" .AND. TRBLIV->BM1_VALOR > 0, TRBLIV->BM1_VALOR * -1, TRBLIV->BM1_VALOR)
		lchkVal	:= nAcumRec > 0 .AND. nAcumRec <> TRBLIV->FK1_VALOR .AND. TRBLIV->FI7_VALOR == 0
		nValK1Ant	:= IIF( AllTrim(TRBLIV->FKTPDOC) == "ES" .AND. TRBLIV->BM1_VALOR > 0, TRBLIV->FK1_VALOR * -1, TRBLIV->FK1_VALOR) 
		lTipoY := .F.
		If TRBLIV->TIPOY == "2"
			SE1->(dbgoTo(TRBLIV->SE1REC))
			//FK1->(DbGoTo(TRBLIV->(FK1REC)))
			FK7->(dbsetOrder(2))
			FK7->(MsSeek(xfilial("FK7") + "SE1" + SE1->(E1_FILIAL)+'|'+SE1->(E1_PREFIXO)+'|'+SE1->(E1_NUM)+'|'+SE1->(E1_PARCELA)+'|'+SE1->(E1_TIPO)+'|'+SE1->(E1_CLIENTE)+'|'+SE1->(E1_LOJA)))
			lTipoY := .T.
			nvalY := 0 
			//tentativa de reaproveitar coisas
			cKeyHashPar := AllTrim(Str(TRBLIV->SE1REC)) + "|" + Alltrim(Str(TRBLIV->BM1REG)) //+ "|" + Dtos(TRBLIV->BAIXA_DISP)
			
			AvalY := {}
			
			if !oHashPar:Get(cKeyHashPar,nvalY)
				AvalY := parparpar(0,xfilial("SE1"), TRBLIV->PREFIXO, TRBLIV->NUMERO, TRBLIV->PARCELA, TRBLIV->BM1_TIPTIT, SE1->E1_CLIENTE, SE1->E1_LOJA, TRBLIV->BM1_VALOR,  TRBLIV->BM1_VALOR / SE1->E1_VALOR, dDatDe, dDatAte,plRetXX(DtoS(dDatDe), FK7->FK7_IDDOC,.T.),TRBLIV->BAIXA_DISP)
			  //nValNG8 := parparpar(0,xfilial("SE1"), TRBLIV->PREFIXO, TRBLIV->NUMERO, TRBLIV->PARCELA, TRBLIV->BM1_TIPTIT, SE1->E1_CLIENTE, SE1->E1_LOJA, TRBLIV->BM1_VALOR,  TRBLIV->BM1_VALOR / SE1->E1_VALOR , dDatDe)
				oHashPar:Set(cKeyHashPar,nvalY)
			else
				AvalY := {}
			endIf
			If empTy(AvalY)
				TRBLIV->(dbSkip())
				Loop
			else
				for nValY := 1 To Len(AvalY)
					oSTITULO:cell("VALOR"):setValue( AvalY[nValY][1] )
					oSTITULO:cell("BAIXA"):setValue( AvalY[nValY][2])
					oSTITULO:printLine()
					oSTITULO:finish()
				next
			endIf
//			If aDtDisp[1]
//				oSTITULO:cell("BAIXA"):setValue(aDtdisp[2])
//				aDtDisp := { .F., CtoD("") }
//			endIf
		endIf
		TRBLIV->(dbSkip())		
		nSeq ++
				
		If .F. //lTipoY .and. nvalY > 0
			oSTITULO:cell("VALOR"):setValue( nvalY )
		elseIf .F. //( TRBLIV->(EoF()) .OR. TRBLIV->(FK1REC) <> nLastRecK1 ) .AND. lchkVal
			If nValK1Ant < 0 .AND. nValK1Ant <> nAcumRec - nValAc + nVal1
				oSTITULO:cell("VALOR"):setValue( nValK1Ant - nAcumRec + nValAc )
			else
				//oSTITULO:cell("VALOR"):setValue( nVal1 )
				oSTITULO:cell("VALOR"):setValue( nVal2 )
			endIf
		elseif !lTipoY
			oSTITULO:cell("VALOR"):setValue( nVal2 )
		endIf
			
		If !lTipoY	
			oSTITULO:printLine()
			oSTITULO:finish()
		endIf
		//		TRBLIV->(dbSkip())		
		//		nSeq ++
		
	EndDo

	oHashPar:Clean()
	
	If MV_PAR06 == 1	
		oSTPCONTRATO:finish()
		oSSEGMPADL:finish()
		oSMESANO:finish()
		oSGERAL:finish()	
	EndIf

	if  lLog .and. len(aLog) > 0
		ocorrencias(oOcorrencias,aLog)
	else
		oOcorrencias:hide()
	endIf

	oReport:endPage()	
	
EndIf
TRBLIV->(dbCloseArea())

//Exclui a tabela temporária 
oTempTable:Delete() 
Return


/*/{Protheus.doc} getTrbQuery
Executa query 

@author DEV
@since 05/03/2016
@version ALL
/*/
static function getTrbQuery(lLivro,lLog,dDatDe,dDatAte,oTempTable)
local lRet      := .f.
Local aFields 	:= {}
Local nI		:= 0
Local cAlias 	:= "TRBLIV"
LOCAL nQryfile 	:= 0
Local aPtoQuery	:= {}
Local aPtoTpDoc	:= {}
Local nPos		:= 0
Local aRecTit	:= 0
Local aTipRel	:= { "O", "C", "B", "D", "M" }		// Tipo de Relatório: Operadora, Coparticipação, Beneficiário Outra Operadora, Rel.Plano Serv.Odontológico e Rel.Plano Med.Hospitalar
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

Local lMsSql	:= Upper(TcGetDb()) $ "MSSQL"

local lDtCTB	:= getNewPar("MV_PLDTREC", '0') == '0'

local lBaixaDisp := (MV_PAR08 == 1) .AND. ( FK1->(FieldPos("FK1_DTDISP")) > 0 )
local cQuery	 := ""
local nStatus    := 0
local nCase      := 0
local cPtoQuery  := ""
local cPtoTpDoc  := ""
Local cAliUpd	 := 'UPDALI'
Local oUpdTable  := nil
Local oFK5FK7	 := nil
Local cSqlBase	 := ""
Local aFiledB	 := {}
Local cAliK57 	 := "TPLFK57"

//Executa ponto de entrada para filtragem de Tipos de Cobrança...         
If Existblock("PLR46XP1")
	aPtoQuery := ExecBlock("PLR46XP1",.f.,.f.,{ '463'+aTipRel[MV_PAR07] })
Endif

//Executa ponto de entrada para Descrição de Tipos de Documento...        
If Existblock("PLR46XP2")
	aPtoTpDoc := ExecBlock("PLR46XP2",.f.,.f.,{ '463'+aTipRel[MV_PAR07] })
Endif

//Executa ponto de entrada para Complemento de Filtro no BM1...        
If Existblock("PLR46XP3")
//	cWhere  := " AND BM1_NUMTIT = '000003240'" //" + GetNewPar("MV_PLR463", " ") + "' "
//	cWhere := " AND BM1_MATRIC = '002307' " 
	cWhere := ExecBlock("PLR46XP3",.f.,.f.,{ '463'+aTipRel[MV_PAR07] })
Endif

// Elimina array
aSize(aTipRel,1)
aDel(aTipRel,1)

if empty(MV_PAR01) .OR. Empty(MV_PAR02) .or. dDatDe > dDataBase .or. dDatAte > dDataBase 
    msgAlert(STR0029,STR0030) //"O período deve ser determinado."//"Atenção"
    Return(lRet)
endIf

if empty(MV_PAR03)
    msgAlert(STR0031,STR0030) //"Operadora deve ser informada."//"Atenção"
    Return(lRet)
endIf

if empty(MV_PAR04+MV_PAR05)
    msgAlert(STR0032,STR0030) //"Parametros de Empresa devem ser informados."//"Atenção"
    Return(lRet)
endIf
lRet := .T.

//Monta os campos da tabela
aadd(afields,{"FK1REC","N",16 ,0})
aadd(afields,{"SE1REC","N",16 ,0})
aadd(aFields,{"BM1_CODINT","C",04,0})
aadd(aFields,{"BM1_CODEMP","C",04,0})
aadd(aFields,{"BM1_CONEMP","C",12,0})
aadd(aFields,{"BM1_VERCON","C",03,0})
aadd(aFields,{"BM1_SUBCON","C",08,0})
aadd(aFields,{"BM1_VERSUB","C",03,0})
aadd(aFields,{"BM1_MATRIC","C",06,0})
aadd(aFields,{"BM1_TIPREG","C",02,0})
aadd(aFields,{"BM1_DIGITO","C",01,0})
aadd(aFields,{"BM1_MES","C",02,0})
aadd(aFields,{"BM1_ANO","C",04,0})
aadd(aFields,{"BM1_VALOR","N",16,4})
aadd(aFields,{"BM1REG","N",16,0})
aadd(aFields,{"BM1_TIPO","C",01,0})
aadd(aFields,{"BM1_TIPTIT","C",03,0})
aadd(aFields,{"PREFIXO","C",03,0})
aadd(aFields,{"NUMERO","C",09,0})
aadd(aFields,{"PARCELA","C",03,0})
aadd(aFields,{"BM1_CODTIP","C",03,0})
aadd(aFields,{"BM1_CODEVE","C",10,0})
aadd(aFields,{"BM1_ALIAS","C",03,0})
aadd(aFields,{"BM1_ORIGEM","C",20,0})
aadd(aFields,{"BM1_PLNUCO","C",12,0})
aadd(aFields,{"BI3_DTAPPR","D",08,0})
aadd(aFields,{"BI3_CODSEG","C",03,0})
aadd(aFields,{"BI3_MODPAG","C",03,0})
aadd(aFields,{"BI3_TIPCON","C",03,0})
aadd(aFields,{"BA1_NOMUSR","C",40,0})
aadd(aFields,{"BA1_LOCSIB","C",01,0})
aadd(aFields,{"BA1_DIGITO","C",01,0})
aadd(aFields,{"BA1_DATINC","D",08,0})
aadd(aFields,{"NOMTIT","C",40,0})
aadd(aFields,{"CPFTIT","C",40,0})
aadd(aFields,{"BG9_TIPO","C",01,0})
aadd(aFields,{"BG9_DESCRI","C",40,0})
aadd(aFields,{"BT5_INTERC","C",01,0})
aadd(aFields,{"BT5_TIPOIN","C",02,0})
aadd(aFields,{"BQB_DATINI","D",08,0})
aadd(aFields,{"BQB_DATFIN","D",08,0})
aadd(aFields,{"BQC_DESCRI","C",40,0})
aadd(aFields,{"VENCTO","D",08,0})
aadd(aFields,{"E1_SALDO","N",16,2})
aadd(aFields,{"E1_VALOR","N",16,2})
aadd(aFields,{"E1_EMISSAO","D",08,0})
aadd(aFields,{"E1_BAIXA","D",08,0})
aadd(aFields,{"DESCDOC","C",55,0})
aadd(aFields,{"FK1_VALOR","N",16,2})
aadd(aFields,{"FK1_DATA","D",08,0})
aadd(aFields,{"TIPCOB","C",01,0})
aadd(aFields,{"MESLCT","C",06,0})
aadd(aFields,{"BI3_SUSEP","C",12,0})
aadd(aFields,{"BAIXA_DISP","D",08,0})
aadd(aFields,{"FI7_VALOR","N",16,2})
aadd(aFields,{"VALNEG","N",16,2})
aadd(aFields,{"ORIGEM","C",06,0})
aadd(aFields,{"FK1ORI","C",06,0})
aadd(afields,{"E1_VALLIQ","N",16,2})
aadd(afields,{"FKTPDOC","C",tamSX3("FK1_TPDOC")[1] ,0})
aadd(afields,{"TIPOY", "C", 1, 0})
aadd(afields,{"VALDIF","N",16,2})
//Criação do objeto
oUpdTable := FWTemporaryTable():New( cAliUpd, aFields )
oTempTable := FWTemporaryTable():New( cAlias, aFields )

//oTempTable:AddIndex("indice1", {"BM1_ANO","BM1_MES","BI3_CODSEG","BI3_MODPAG","BI3_DTAPPR","BI3_TIPCON",;
//								"BM1_CODINT","BM1_CODEMP","BM1_MATRIC","BM1_TIPREG","BM1_CODTIP","BM1_CODEVE","E1_EMISSAO","NUMERO" } )
oTempTable:AddIndex("indice1", {"SE1REC", "FK1REC" } )

oUpdTable:AddIndex("indice1", {	"BM1_ANO","BM1_MES","BI3_CODSEG","BI3_MODPAG","BI3_DTAPPR","BI3_TIPCON",;
								"BM1_CODINT","BM1_CODEMP","BM1_MATRIC","BM1_TIPREG","BM1_CODTIP","BM1_CODEVE","E1_EMISSAO","NUMERO" } )

//Criação da tabela
oTempTable:Create()
oUpdTable:Create()

aadd(aFiledB, {"FKA_IDPROC", "C", tamSX3("FKA_IDPROC")[1], 0})
aadd(aFiledB, {"FK5_ORIGEM", "C", tamSX3("FK5_ORIGEM")[1], 0})
aadd(aFiledB, {"FK5_DTDISP", "D", 8, 0})
aadd(aFiledB, {"FK5_DATA", "D", 8, 0})

//oFK5FK7	:= FWTemporaryTable():New( cAliK57, aFiledB )
//oFK5FK7:AddIndex("indice1", {"FKA_IDPROC","FK5_ORIGEM"} )

//oFK5FK7:Create()
/*
cSqlBase := " Insert Into " +  oFK5FK7:getrealName() + " (FKA_IDPROC, FK5_ORIGEM, FK5_DATA, FK5_DTDISP) "
cSqlBase += " Select FKA_IDPROC, FK5_ORIGEM, FK5_DATA, FK5_DTDISP "
cSqlBase += " from " + RetSqlName("FK5") + " FK5 "
cSqlBase += " Inner Join " + RetsqlName("FKA") + " FKA "
cSqlBase += " On "
cSqlBase += " FKA.FKA_FILIAL = '" + xfilial("FKA") + "' "
cSqlBase += " AND FKA.FKA_IDORIG = FK5.FK5_IDMOV "
cSqlBase += " AND FKA.D_E_L_E_T_ = ' ' "
cSqlBase += " Where "
cSqlBase += " FK5.FK5_FILIAL = '" + xFilial("FK5") + "' "

if !lBaixaDisp
	cSqlBase += " AND FK5_DATA BETWEEN '" + dtos(dDatDe) + "' AND '" +  dtos(dDatAte) + "' "
else
	cSqlBase += " AND FK5_DTDISP BETWEEN '" + dtos(dDatDe) + "' AND '" +  dtos(dDatAte) + "' "
endIf	

cSqlBase += " AND FK5.D_E_L_E_T_ = ' ' "
cSqlBase += " AND FK5.FK5_TPDOC <> 'ES' "
cSqlBase += " Order By "
cSqlBase += " FKA_IDPROC, FK5_ORIGEM "

TCSQLExec(cSqlBase)
*/

cSql := " WITH NEGOCIACAO " //--( column_name [,...n] )
cSql += " AS "
cSql += " ( "
//--CTE_query_definition –- Anchor member is defined.
cSql += " Select FK7.FK7_CHAVE E1CHV, FK7.FK7_IDDOC, SE1.R_E_C_N_O_ REC, FI7.R_E_C_N_O_ REC7, FI7.*, FI7_FILDES, FI7_PRFDES, FI7_PARDES, FI7_NUMDES, FI7_TIPDES, FI7_CLIDES, FI7_LOJDES, FI7_VALOR, 0 NIVEL From " + RetSqlname("SE1") + " SE1 "
csql += " inner Join " + RetsqlName("FK7") + " FK7 "
cSql += " On "
cSql += "	FK7.FK7_FILIAL = SE1.E1_FILIAL "
cSql += " AND FK7.FK7_CHAVE = SE1.E1_FILIAL + '|' + SE1.E1_PREFIXO + '|' + SE1.E1_NUM + '|' + SE1.E1_PARCELA + '|' + SE1.E1_TIPO + '|' + SE1.E1_CLIENTE + '|' + SE1.E1_LOJA "
csql += " AND FK7.D_E_L_E_T_ = ' ' "
cSql += " Inner Join " + RetsqlName('FI7') + "  FI7 "  
cSql += " On "
csql += " 	FI7_FILIAL = '" + xfilial("FI7") + "' " //E1_FILIAL "
cSql += " AND FI7_PRFORI = E1_PREFIXO "
cSql += " AND FI7_NUMORI = E1_NUM "
csql += " AND FI7_PARORI = E1_PARCELA "
csql += " ANd FI7_TIPORI = E1_TIPO "
cSql += " AND FI7_CLIORI = E1_CLIENTE "
cSql += " AND FI7_LOJORI = E1_LOJA " 
cSql += " AND FI7.D_E_L_E_T_ = ' ' "

cSql += " Inner Join " + RetSqlName("BM1") + " BM1 "
csql += " On "
csql += "    BM1_FILIAL =  '" + xFilial("BM1") + "' "
csql += "   AND BM1_PLNUCO = E1_PLNUCOB "
csql += "   AND BM1_PREFIX = E1_PREFIXO "
csql += "   AND BM1_NUMTIT = E1_NUM "
csql += "   AND BM1_PARCEL = E1_PARCELA " 
csql += "   AND BM1_TIPTIT = E1_TIPO " 
cSql += " AND BM1.D_E_L_E_T_ =  ' ' "

csql += " where " 
//cSql += " SE1.E1_NUM = '000418234' "//--'000504656'--'001438107'-- [001405099] -> Esse é mais simples -- [000750282] -> esse é mais complicado -- [???????] -> último desafio
csql += "   SE1.E1_CODINT = '"+MV_PAR03+"' "
csql += "   AND SE1.E1_CODEMP >= '"+MV_PAR04+"' "
csql += "   AND SE1.E1_CODEMP <= '"+MV_PAR05+"' "
csql += "   AND SE1.E1_TIPO NOT IN ('RA ','PA ',' NCC ',' NDF') "  
csql += "   AND SUBSTRING(SE1.E1_ORIGEM,1,3) = 'PLS' " 
csql += "   AND SE1.E1_TIPOLIQ IN ( 'LIQ', 'NEG' ) "
csql += "   AND E1_EMISSAO <='"+DtoS(dDatAte)+"' "	
csql += " AND SE1.D_E_L_E_T_ = ' ' "

csql += " UNION ALL "
csql += " Select SE1.E1_FILIAL + '|' + SE1.E1_PREFIXO + '|' + SE1.E1_NUM + '|' + SE1.E1_PARCELA + '|' + SE1.E1_TIPO + '|' + SE1.E1_CLIENTE + '|' + SE1.E1_LOJA E1CHV, NEG.FK7_IDDOC, SE1.R_E_C_N_O_ REC, FI7.R_E_C_N_O_ REC7, FI7.*, FI7.FI7_FILDES, FI7.FI7_PRFDES, FI7.FI7_PARDES, FI7.FI7_NUMDES, FI7.FI7_TIPDES, FI7.FI7_CLIDES, FI7.FI7_LOJDES, FI7.FI7_VALOR, NEG.NIVEL + 1 NIVEL From SE1010 SE1 "
csql += " Inner Join FI7010 FI7 "  
csql += " On "
cSql += " 	FI7_FILIAL = E1_FILIAL "
cSql += " AND FI7_PRFORI = E1_PREFIXO "
cSql += " AND FI7_NUMORI = E1_NUM "
cSql += " AND FI7_PARORI = E1_PARCELA "
cSql += " ANd FI7_TIPORI = E1_TIPO "
csql += " AND FI7_CLIORI = E1_CLIENTE "
cSql += " AND FI7_LOJORI = E1_LOJA "
cSql += " AND FI7.D_E_L_E_T_ = ' ' "

csql += " Inner Join NEGOCIACAO NEG "
cSql += " On "
csql += " 	NEG.FI7_FILDES = SE1.E1_FILIAL "
cSql += " AND NEG.FI7_PRFDES = SE1.E1_PREFIXO "
cSql += " AND NEG.FI7_NUMDES = SE1.E1_NUM "
csql += " AND NEG.FI7_PARDES = SE1.E1_PARCELA "
cSql += " AND NEG.FI7_TIPDES = SE1.E1_TIPO "
cSql += " AND NEG.FI7_CLIDES = SE1.E1_CLIENTE "
csql += " AND NEG.FI7_LOJDES = SE1.E1_LOJA "
cSql += " where " 
csql += " SE1.D_E_L_E_T_ = ' ' "
cSql += " ) "

cquery := " " //+ cSql + " " 
// Query principal na Composição dos Itens da Guia
cQuery	+= "SELECT BM1_CODINT,BM1_CODEMP,BM1_CONEMP,BM1_VERCON,BM1_SUBCON,BM1_VERSUB,"
cQuery	+= "BM1_MATRIC,BM1_TIPREG,BM1_DIGITO,BM1_MES,BM1_ANO,BM1_VALOR, BM1.R_E_C_N_O_ AS BM1REG,"
cQuery	+= "BM1_TIPO,BM1_TIPTIT,BM1_PREFIX AS PREFIXO, BM1_NUMTIT AS NUMERO, BM1_PARCEL AS PARCELA,BM1_CODTIP,BM1_CODEVE,"
cQuery	+= "BM1_ALIAS, BM1_ORIGEM, BM1_PLNUCO,"
cQuery	+= "BI3.BI3_DTAPPR,BI3.BI3_CODSEG,BI3.BI3_MODPAG,BI3.BI3_TIPCON,BI3.BI3_SUSEP, "
cQuery	+= "BA1.BA1_NOMUSR,BA1.BA1_LOCSIB,BA1.BA1_DIGITO,BA1.BA1_DATINC, " 

cQuery += " COALESCE(TIT.BA1_NOMUSR, "
cQuery += "        ( "
cQuery += " SELECT TT.BA1_NOMUSR "
cQuery += "      FROM " + RetSqlName("BA1") + " TT " 
cQuery += "     WHERE TT.BA1_FILIAL='" + xFilial("BA1") + "' "
cQuery += "       AND TT.BA1_CODINT=BA1.BA1_CODINT "
cQuery += "       AND TT.BA1_CODEMP=BA1.BA1_CODEMP "
cQuery += "       AND TT.BA1_MATRIC=BA1.BA1_MATRIC "
cQuery += "       AND TT.BA1_RESFAM = '1' "
cQuery += "       AND TT.D_E_L_E_T_ = ' ' "
cQuery += "        ) "
cQuery += "        ) NOMTIT, "  
   
cQuery += " COALESCE(TIT.BA1_CPFUSR, "
cQuery += "        ( "
cQuery += " SELECT TT.BA1_CPFUSR "
cQuery += "      FROM " + RetSqlName("BA1") + " TT " 
cQuery += "     WHERE TT.BA1_FILIAL='" + xFilial("BA1") + "' "
cQuery += "       AND TT.BA1_CODINT=BA1.BA1_CODINT "
cQuery += "       AND TT.BA1_CODEMP=BA1.BA1_CODEMP "
cQuery += "       AND TT.BA1_MATRIC=BA1.BA1_MATRIC "
cQuery += "       AND TT.BA1_RESFAM = '1' "
cQuery += "       AND TT.D_E_L_E_T_ = ' ' "
cQuery += "        ) "
cQuery += "        ) CPFTIT, " 

cQuery	+= "BG9.BG9_TIPO,BG9.BG9_DESCRI,BT5.BT5_INTERC,BT5.BT5_TIPOIN,BQB.BQB_DATINI,BQB.BQB_DATFIN,BQC.BQC_DESCRI," 

if lBaixaDisp
//	cQuery += " TrueFK57.FK5_DTDISP AS BAIXA_DISP, "
	cQuery += " FK1_DTDISP AS BAIXA_DISP, "
else
	cQuery += " FK1_DATA AS BAIXA_DISP, "
endif

cQuery	+= "SE1.E1_VENCREA AS VENCTO, SE1.E1_SALDO, SE1.E1_VALOR E1_VALOR, SE1.E1_EMISSAO, SE1.E1_BAIXA, SE1.E1_VALLIQ, "
cQuery	+= "SX5.X5_DESCRI AS DESCDOC,"

cQuery	+= " (FK1.FK1_VALOR + COALESCE(FK6DC.FK6_VALMOV, 0)) FK1_VALOR, FK1.FK1_DATA,"
cQuery	+= " ' ' AS TIPCOB, '      ' AS MESLCT, 0 AS FI7_VALOR, 0 VALNEG, ' ' ORIGEM, FK1_ORIGEM FK1ORI  "

cQuery += " , 0 AS FI7REC, FK1.FK1_TPDOC FKTPDOC, FK1.R_E_C_N_O_ FK1REC, SE1.R_E_C_N_O_ SE1REC, '1' TIPOY, COALESCE(YU.TOT_MUL, 0) + COALESCE(YU.TOT_JUR, 0) VALDIF "

cQuery += " FROM " + RetSqlName("BM1") + " BM1 "

cQuery += " INNER JOIN " + RetSqlName("SE1") + " SE1 "
cQuery += "    ON E1_FILIAL =  '" + xFilial("SE1") + "' "
cQuery += "   AND BM1_PLNUCO = E1_PLNUCOB "
cQuery += "   AND BM1_PREFIX = E1_PREFIXO "
cQuery += "   AND BM1_NUMTIT = E1_NUM "
cQuery += "   AND BM1_PARCEL = E1_PARCELA " 
cQuery += "   AND BM1_TIPTIT = E1_TIPO " 
cQuery += "   AND SE1.E1_CODINT = '"+MV_PAR03+"' "
cQuery += "   AND SE1.E1_CODEMP >= '"+MV_PAR04+"' "
cQuery += "   AND SE1.E1_CODEMP <= '"+MV_PAR05+"' "
cQuery	+= "  AND SE1.E1_TIPO NOT IN ('RA ','PA ',' NCC ',' NDF') "  
cQuery	+= "  AND SUBSTRING(SE1.E1_ORIGEM,1,3) = 'PLS' " 
cQuery	+= "  AND SE1.E1_TIPOLIQ NOT IN('LIQ','CAN','NEG') "
cQuery += "   AND E1_EMISSAO <='"+DtoS(dDatAte)+"' "	
cQuery += "   AND SE1.D_E_L_E_T_ = ' ' "

cQuery += " Inner Join " + retsqlName("FK7") + " FK7 " 
cQuery += " On "
cQuery += " FK7_FILIAL = '" + xFilial("FK7") + "' "
cQuery += " AND FK7_ALIAS = 'SE1' "

If(SubStr(Alltrim(Upper(TCGetDb())),1,6)) == "ORACLE"
	cQuery += " AND FK7_CHAVE = SE1.E1_FILIAL||'|'||SE1.E1_PREFIXO||'|'||SE1.E1_NUM||'|'||SE1.E1_PARCELA||'|'||SE1.E1_TIPO||'|'||SE1.E1_CLIENTE||'|'||SE1.E1_LOJA" + " "
Else
	cQuery += " AND FK7_CHAVE = SE1.E1_FILIAL+'|'+SE1.E1_PREFIXO+'|'+SE1.E1_NUM+'|'+SE1.E1_PARCELA+'|'+SE1.E1_TIPO+'|'+SE1.E1_CLIENTE+'|'+SE1.E1_LOJA" + " "
Endif
cQuery += " AND FK7.D_E_L_E_T_ = ' ' "

cQuery += " Inner Join " + retSqlName("FK1") + " FK1 "
cQuery += " On "
cQuery += " FK1_FILIAL = '" + xFilial("FK1") + "' "
cQuery += " AND FK1_IDDOC = FK7.FK7_IDDOC "
cQuery += " AND FK1.D_E_L_E_T_ = ' ' "

cQuery += " Left Join ( "
cQuery += " select SUM( Case  when FK6_TPDOC = 'JR' then FK6_VALMOV else 0 END ) TOT_JUR, SUM( Case  when FK6_TPDOC = 'MT' then FK6_VALMOV else 0 END ) TOT_MUL, FK1_IDDOC from "
cQuery += " " + retsqlName("FK6") + " FK6 "
cQuery += " Inner Join " + RetSqlName("FK1") + " FK1 "
cQuery += " On "
cQuery += "   FK1_FILIAL = '" + xFilial("FK1") + "' "
cQuery += "   AND FK1_IDFK1 = FK6.FK6_IDORIG "
cQuery	+= "   AND FK1_MOTBX NOT IN('LIQ','CAN','NEG') "
if lBaixaDisp
	cQuery += " AND FK1_DTDISP BETWEEN '" + dtos(dDatDe) + "' AND '" +  dtos(dDatAte) + "' "
else	
	cQuery += " AND FK1_DATA BETWEEN '" + dtos(dDatDe) + "' AND '" +  dtos(dDatAte) + "' "
endif
cQuery += " Where FK6_FILIAL = '" + xfilial("FK1") +  "' "
cQuery += " 	AND FK6.D_E_L_E_T_ = ' ' " 
cQuery += " group By FK1_IDDOC "
cQuery += " ) YU "
cQuery += " 	On YU.FK1_IDDOC = FK7.FK7_IDDOC "

cQuery += " Left Join " + RetSqlName("FK6") + " FK6DC "
cQuery += " On "
cQuery += " FK6DC.FK6_FILIAL = '" + xfilial("FK6") + "' "
cQuery += " AND FK6DC.FK6_IDORIG = FK1.FK1_IDFK1 "
cQuery += " AND FK6DC.FK6_TPDOC = 'DC' "
cQuery += " AND FK6DC.D_E_L_E_T_ = ' ' "

cQuery += " Inner Join " + RetSqlName("FKA") + " FKA "
cQuery += " On "
cQuery += " FKA_FILIAL = '" + xfilial("FKA") + "' "
cQuery += " AND FKA_TABORI = 'FK1' "
cQuery += " AND FKA_IDORIG = FK1.FK1_IDFK1 "
cQuery += " AND FKA.D_E_L_E_T_ = ' ' "
/*
cQuery += " LEFT JOIN " + oFK5FK7:getrealName() + " TrueFK57 "
cQuery += " On "
cQuery += " TrueFK57.FKA_IDPROC = FKA.FKA_IDPROC "
*/
// Família
cQuery	+= "INNER JOIN "+RetSqlName("BA3")+" BA3 "
cQuery	+= " ON BA3_FILIAL = '"+xFilial('BA3')+"' "
cQuery	+= "AND BA3_CODINT = BM1.BM1_CODINT "
cQuery	+= "AND BA3_CODEMP = BM1.BM1_CODEMP "
cQuery	+= "AND BA3_MATRIC = BM1.BM1_MATRIC "
cQuery	+= "AND BA3.D_E_L_E_T_ = ' ' "
// Usuário
cQuery	+= "INNER JOIN "+RetSqlName("BA1")+" BA1 "
cQuery	+= " ON BA1_FILIAL = '"+xFilial('BA1')+"' "
cQuery	+= "AND BA1_CODINT = BM1.BM1_CODINT "
cQuery	+= "AND BA1_CODEMP = BM1.BM1_CODEMP "
cQuery	+= "AND BA1_MATRIC = BM1.BM1_MATRIC "
cQuery	+= "AND BA1_TIPREG = BM1.BM1_TIPREG "
cQuery	+= "AND BA1.D_E_L_E_T_ = ' ' "
// Grupo Empresa
cQuery	+= "INNER JOIN "+RetSqlName("BG9")+" BG9 "
cQuery	+= " ON BG9_FILIAL = '"+xFilial('BG9')+"' "
cQuery	+= "AND BG9_CODINT = BM1.BM1_CODINT "
cQuery	+= "AND BG9_CODIGO = BM1.BM1_CODEMP "
cQuery	+= "AND BG9.D_E_L_E_T_ = ' ' "

// Usuário Titular
cQuery	+= "LEFT JOIN "+RetSqlName("BA1")+" TIT "
cQuery	+= " ON TIT.BA1_FILIAL = '"+xFilial("BA1")+"' "
cQuery	+= "AND TIT.BA1_CODINT = BM1.BM1_CODINT "
cQuery	+= "AND TIT.BA1_CODEMP = BM1.BM1_CODEMP "
cQuery	+= "AND TIT.BA1_MATRIC = BM1.BM1_MATRIC "
cQuery	+= "  AND TIT.BA1_RESFAM = '1' "
cQuery	+= "AND TIT.D_E_L_E_T_ = ' ' "

// Produto Saúde
cQuery	+= "INNER JOIN "+RetSqlName("BI3")+" BI3 "
cQuery	+= "ON BI3_FILIAL='"+xFilial("BI3")+"' "
cQuery	+= "AND BI3_CODINT=BM1.BM1_CODINT "

If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"		
	cQuery	+= "AND ( BI3_CODIGO = DECODE(BA1.BA1_CODPLA, '    ', BA3.BA3_CODPLA, BA1.BA1_CODPLA) "
	cQuery	+= "AND BI3_VERSAO = DECODE(BA1.BA1_VERSAO, '   ', BA3.BA3_VERSAO, BA1.BA1_VERSAO) ) "
Else
	cQuery	+= "AND BI3_CODIGO = ("
	cQuery	+= "CASE WHEN BA1.BA1_CODPLA = ' ' THEN BA3.BA3_CODPLA "
	cQuery	+= "ELSE BA1.BA1_CODPLA END) "
	cQuery	+= "AND BI3_VERSAO = ("
	cQuery	+= "CASE WHEN BA1.BA1_VERSAO = ' ' THEN BA3.BA3_VERSAO "
	cQuery	+= "ELSE BA1.BA1_VERSAO END) "
EndIf
cQuery	+= "AND BI3.D_E_L_E_T_ = ' ' "

// Tabela Tipos de Títulos
cQuery	+= "INNER JOIN "+RetSqlName("SX5")+" SX5 "
cQuery	+= "ON SX5.X5_FILIAL='"+xFilial('SX5')+"' "
cQuery	+= "AND SX5.X5_TABELA='05' "
cQuery	+= "AND SX5.X5_CHAVE=SE1.E1_TIPO "
cQuery	+= "AND SX5.D_E_L_E_T_ = ' ' "

// Contrato
cQuery	+= "LEFT JOIN "+RetSqlName("BT5")+" BT5 "
cQuery	+= " ON BT5_FILIAL = '"+xFilial('BT5')+"' "
cQuery	+= "AND BT5_CODINT = BM1.BM1_CODINT "
cQuery	+= "AND BT5_CODIGO = BM1.BM1_CODEMP "
cQuery	+= "AND BT5_NUMCON = BM1.BM1_CONEMP "
cQuery	+= "AND BT5_VERSAO = BM1.BM1_VERCON "
cQuery	+= "AND BT5.D_E_L_E_T_ = ' ' "
// Versões dos Contratos
cQuery	+= "LEFT JOIN "+RetSqlName("BQB")+" BQB "
cQuery	+= " ON BQB_FILIAL = '"+xFilial('BQB')+"' "
cQuery	+= "AND BQB_CODINT = BM1.BM1_CODINT "
cQuery	+= "AND BQB_CDEMP  = BM1.BM1_CODEMP "
cQuery	+= "AND BQB_NUMCON = BM1.BM1_CONEMP "
cQuery	+= "AND BQB_VERSAO = BM1.BM1_VERCON "
cQuery	+= "AND BQB.D_E_L_E_T_ = ' ' "
// SubContratos
cQuery	+= "LEFT JOIN "+RetSqlName("BQC")+" BQC "
cQuery	+= " ON BQC_FILIAL = '"+xFilial('BQB')+"' "
cQuery	+= "AND BQC_CODINT = BM1.BM1_CODINT "
cQuery	+= "AND BQC_CODEMP = BM1.BM1_CODEMP "
cQuery	+= "AND BQC_NUMCON = BM1.BM1_CONEMP "
cQuery	+= "AND BQC_VERCON = BM1.BM1_VERCON "
cQuery	+= "AND BQC_SUBCON = BM1.BM1_SUBCON "
cQuery	+= "AND BQC_VERSUB = BM1.BM1_VERSUB "
cQuery	+= "AND BQC.D_E_L_E_T_ = ' ' "

cQuery += " WHERE "

if lBaixaDisp

//	cQuery += " (( TRUEFK57.FKA_IDPROC IS NOT NULL AND TRUEFK57.FK5_DTDISP BETWEEN '" + dtos(dDatDe) + "'	AND '" + dtos(dDatAte) + "' ) "
// 	cQuery += " OR FK1_DATA BETWEEN '" + dtos(dDatDe) + "'	AND '" + dtos(dDatAte) + "'	) "
//	cQuery += " ( TRUEFK57.FKA_IDPROC IS NOT NULL AND TRUEFK57.FK5_DTDISP BETWEEN '" + dtos(dDatDe) + "'	AND '" + dtos(dDatAte) + "' ) "
	cQuery += " FK1_DTDISP BETWEEN '" + dtos(dDatDe) + "' AND '" +  dtos(dDatAte) + "' "
else	
	cQuery += " FK1_DATA BETWEEN '" + dtos(dDatDe) + "' AND '" +  dtos(dDatAte) + "' "
endif

// Filtra Lançamentos conforme retorno do ponto de entrada
If Len(aPtoQuery) > 0
	For nPos := 1 to Len(aPtoQuery)
		cQuery += IIf( nPos==1, "AND BM1_CODTIP IN('"+aPtoQuery[nPos,1], "'"+aPtoQuery[nPos,1] )
		cQuery += IIf( Len(aPtoQuery)>1, IIf(Len(aPtoQuery)==nPos,  "') ", "',"), "') ")
	Next

Else
	
	//Se Benef.Operadoras, filtra tipo de movimentação coparticipação         
	If MV_PAR07 == 1
		cQuery	+= "AND BM1_CODTIP IN ('101','102','103','107','108','109','110','111','113','117','118','128','129','130','131','132','133','135','136','146','180','184','186','188','189','190','191') "
		cQuery	+= "AND BT5_INTERC <> '1' "
	
	//Se Coparticipação, filtra tipos de movimentacao                         
	ElseIf MV_PAR07 == 2
		cQuery	+= "AND BM1_CODTIP IN ('104','116','120','121','122','123','124','125','127','134','137','138','139','140','141','142','143','144','145','147','148','149','150','151','152','153','154','155','156','157','158','159','160','161','162','163','164','165','166','167','168','169','170','171','172','173','174','175','176','177','181','185') "
		cQuery	+= "AND BT5_INTERC <> '1' "
	
	//Se Benef.Outras Operadoras, trata somente contratos de Intercambio.     
	ElseIf MV_PAR07 == 3
		cQuery	+= "AND BT5_INTERC = '1' "
	
	//Se Rel.Plan.Odonto, filtra tipo de movimentação odontologico            
	ElseIf MV_PAR07 == 4 
		cQuery	+= "AND BM1_CODTIP IN ('131','132') "
		cQuery	+= "AND BT5_INTERC <> '1' "
	
	//Se Rel.Pl.Med.Hosp, exclui tipo de movimentação odontologico            
	ElseIf MV_PAR07 == 5 
		cQuery	+= "AND BM1_CODTIP NOT IN ('131','132') "
		cQuery	+= "AND BT5_INTERC <> '1' "
	EndIf

EndIf
cQuery	+= cWhere		// Adição do conteúdo do ponto de entrada, caso exista.
//cQuery  += " AND BM1_NUMTIT ='" + GetNewPar("MV_PLR463", " ") + "' "
//cQuery += " AND BM1_MATRIC = '002057' " 
//cQuery  += " AND BM1_NUMTIT IN('001306200', '001305987') "
cQuery	+= "AND BM1.D_E_L_E_T_ = ' ' "

//consulta de titulos negociados
cQuery  += " UNION "

cQuery	+= "SELECT BM1_CODINT,BM1_CODEMP,BM1_CONEMP,BM1_VERCON,BM1_SUBCON,BM1_VERSUB,"
cQuery	+= "BM1_MATRIC,BM1_TIPREG,BM1_DIGITO,BM1_MES,BM1_ANO,BM1_VALOR, BM1.R_E_C_N_O_ AS BM1REG,"
cQuery	+= "BM1_TIPO,BM1_TIPTIT,BM1_PREFIX AS PREFIXO, BM1_NUMTIT AS NUMERO, BM1_PARCEL AS PARCELA,BM1_CODTIP,BM1_CODEVE,"
cQuery	+= "BM1_ALIAS, BM1_ORIGEM, BM1_PLNUCO,"
cQuery	+= "BI3.BI3_DTAPPR,BI3.BI3_CODSEG,BI3.BI3_MODPAG,BI3.BI3_TIPCON,BI3.BI3_SUSEP, "
cQuery	+= "BA1.BA1_NOMUSR,BA1.BA1_LOCSIB,BA1.BA1_DIGITO,BA1.BA1_DATINC, " 
cQuery	+= "TIT.BA1_NOMUSR NOMTIT, TIT.BA1_CPFUSR CPFTIT," 
cQuery	+= "BG9.BG9_TIPO,BG9.BG9_DESCRI,BT5.BT5_INTERC,BT5.BT5_TIPOIN,BQB.BQB_DATINI,BQB.BQB_DATFIN,BQC.BQC_DESCRI," 

if lBaixaDisp
	//cQuery += " TrueFK57.FK5_DTDISP AS BAIXA_DISP, "
	cQuery += " FK1_DTDISP AS BAIXA_DISP, "
else
	cQuery += " FK1_DATA AS BAIXA_DISP, "
endif

cQuery	+= "SE1.E1_VENCREA AS VENCTO, SE1.E1_SALDO, SE1.E1_VALOR E1_VALOR, SE1.E1_EMISSAO, SE1.E1_BAIXA, "

cQuery += "( Select SUM(FI7_VALOR) VALSLDPAS "
cQuery += " From "  + RetsqlName("FI7") + " FI7 "
cQuery += " Where "
cQuery += " FI7_FILIAL = SE1.E1_FILIAL "
cQuery += " AND FI7_PRFORI = SE1.E1_PREFIXO "
cQuery += " AND FI7_NUMORI = SE1.E1_NUM "
cQuery += " AND FI7_PARORI = SE1.E1_PARCELA "
cQuery += " AND FI7_TIPORI = SE1.E1_TIPO "
cQuery += " AND FI7_CLIORI = SE1.E1_CLIENTE "
cQuery += " AND FI7_LOJORI = SE1.E1_LOJA "
cQuery += " AND FI7.D_E_L_E_T_ = ' ' ) "
cQuery += " E1_VALLIQ, "

cQuery	+= "SX5.X5_DESCRI AS DESCDOC, "
cQuery	+= "FK1.FK1_VALOR, FK1.FK1_DATA,"
cQuery	+= " ' ' AS TIPCOB, '      ' AS MESLCT, FI7.FI7_VALOR AS FI7_VALOR, "

cQuery += " SE1_NEG.E1_VALOR - SE1_NEG.E1_DESCONT VALNEG, "
//SE1.E1_VALLIQ 
//---
//cQuery += "( Select SUM(FI7_VALOR) VALNEG "
//cQuery += " From "  + RetsqlName("FI7") + " FI7 "
//cQuery += " Where "
//cQuery += " FI7_FILIAL = SE1.E1_FILIAL "
//cQuery += " AND FI7_PRFORI = SE1.E1_PREFIXO "
//cQuery += " AND FI7_NUMORI = SE1.E1_NUM "
//cQuery += " AND FI7_PARORI = SE1.E1_PARCELA "
//cQuery += " AND FI7_TIPORI = SE1.E1_TIPO "
//cQuery += " AND FI7_CLIORI = SE1.E1_CLIENTE "
//cQuery += " AND FI7_LOJORI = SE1.E1_LOJA "
//cQuery += " AND FI7.D_E_L_E_T_ = ' ' ) "
//----
//cQuery += " VALNEG, "

cQuery += " ' ' ORIGEM, FK1_ORIGEM FK1ORI  "

cQuery += " , FI7.R_E_C_N_O_ AS FI7REC, FK1.FK1_TPDOC FKTPDOC, FK1.R_E_C_N_O_ FK1REC, SE1.R_E_C_N_O_ SE1REC, '3' TIPOY, COALESCE(J.TOT_NES, 0) - COALESCE(J.TOT_ES, 0) VALDIF "

cQuery += " FROM " + RetSqlName("BM1") + " BM1 "

cQuery += " INNER JOIN " + RetSqlName("SE1") + " SE1 "
cQuery += "    ON BM1_FILIAL =  '" + xFilial("BM1") + "' "
cQuery += "   AND BM1_PLNUCO = E1_PLNUCOB "
cQuery += "   AND BM1_PREFIX = E1_PREFIXO "
cQuery += "   AND BM1_NUMTIT = E1_NUM "
cQuery += "   AND BM1_PARCEL = E1_PARCELA " 
cQuery += "   AND BM1_TIPTIT = E1_TIPO " 
cQuery += "   AND SE1.E1_CODINT = '"+MV_PAR03+"' "
cQuery += "   AND SE1.E1_CODEMP >= '"+MV_PAR04+"' "
cQuery += "   AND SE1.E1_CODEMP <= '"+MV_PAR05+"' "
cQuery += "   AND SE1.E1_TIPO NOT IN ('RA ','PA ',' NCC ',' NDF') "  
cQuery += "   AND SUBSTRING(SE1.E1_ORIGEM,1,3) = 'PLS' " 
cQuery += "   AND SE1.E1_TIPOLIQ IN ( 'LIQ', 'NEG' ) "
cQuery += "   AND E1_EMISSAO <='"+DtoS(dDatAte)+"' "	
cQuery += "   AND SE1.D_E_L_E_T_ = ' ' "

cQuery += " Inner Join " + retsqlName("FK7") + " FK7ORI " 
cQuery += " On "
cQuery += " FK7ORI.FK7_FILIAL = '" + xFilial("FK7") + "' "
cQuery += " AND FK7ORI.FK7_ALIAS = 'SE1' "

If(SubStr(Alltrim(Upper(TCGetDb())),1,6)) == "ORACLE"
	cQuery += " AND FK7ORI.FK7_CHAVE = SE1.E1_FILIAL||'|'||SE1.E1_PREFIXO||'|'||SE1.E1_NUM||'|'||SE1.E1_PARCELA||'|'||SE1.E1_TIPO||'|'||SE1.E1_CLIENTE||'|'||SE1.E1_LOJA" + " "
Else
	cQuery += " AND FK7ORI.FK7_CHAVE = SE1.E1_FILIAL+'|'+SE1.E1_PREFIXO+'|'+SE1.E1_NUM+'|'+SE1.E1_PARCELA+'|'+SE1.E1_TIPO+'|'+SE1.E1_CLIENTE+'|'+SE1.E1_LOJA" + " "
Endif

cQuery += " AND FK7ORI.D_E_L_E_T_ = ' ' "

cQuery += "   INNER JOIN " + retSQLName("FI7") + " FI7 " 
cQuery += "      ON FI7.FI7_FILIAL = E1_FILIAL "
cQuery += "     AND FI7.FI7_PRFORI = E1_PREFIXO "
cQuery += "     AND FI7.FI7_NUMORI = E1_NUM "
cQuery += "     AND FI7.FI7_PARORI = E1_PARCELA "
cQuery += "     AND FI7.FI7_TIPORI = E1_TIPO "
cQuery += "     AND FI7.FI7_CLIORI = E1_CLIENTE "
cQuery += "     AND FI7.FI7_LOJORI = E1_LOJA "
cQuery += " AND FI7.D_E_L_E_T_ = ' ' "

cQuery += " Inner Join " + retsqlName("SE1") + " SE1_NEG "
cQuery += " On "
cQuery += " SE1_NEG.E1_FILIAL = FI7.FI7_FILDES "
cQuery += " AND SE1_NEG.E1_PREFIXO = FI7.FI7_PRFDES "
cQuery += " AND SE1_NEG.E1_NUM = FI7.FI7_NUMDES "
cQuery += " AND SE1_NEG.E1_PARCELA = FI7.FI7_PARDES "
cQuery += " AND SE1_NEG.E1_TIPO = FI7.FI7_TIPDES "
cQuery += " AND SE1_NEG.E1_CLIENTE = FI7.FI7_CLIDES "
cQuery += " AND SE1_NEG.E1_LOJA = FI7.FI7_LOJDES "
cQuery += " AND SE1_NEG.E1_TIPOLIQ NOT IN('LIQ','CAN', 'NEG') "
cQuery += " AND SE1_NEG.D_E_L_E_T_ = ' ' "

cQuery += " Inner Join " + retsqlName("FK7") + " FK7 " 
cQuery += " On "
cQuery += " FK7.FK7_FILIAL = '" + xFilial("FK7") + "' "
cQuery += " AND FK7.FK7_ALIAS = 'SE1' "

If(SubStr(Alltrim(Upper(TCGetDb())),1,6)) == "ORACLE"
	cQuery += " AND FK7.FK7_CHAVE = SE1_NEG.E1_FILIAL||'|'||SE1_NEG.E1_PREFIXO||'|'||SE1_NEG.E1_NUM||'|'||SE1_NEG.E1_PARCELA||'|'||SE1_NEG.E1_TIPO||'|'||SE1_NEG.E1_CLIENTE||'|'||SE1_NEG.E1_LOJA" + " "
Else
	cQuery += " AND FK7.FK7_CHAVE = SE1_NEG.E1_FILIAL+'|'+SE1_NEG.E1_PREFIXO+'|'+SE1_NEG.E1_NUM+'|'+SE1_NEG.E1_PARCELA+'|'+SE1_NEG.E1_TIPO+'|'+SE1_NEG.E1_CLIENTE+'|'+SE1_NEG.E1_LOJA" + " "
Endif

cQuery += " AND FK7.D_E_L_E_T_ = ' ' "

cQuery += " Inner Join " + retSqlName("FK1") + " FK1 "
cQuery += " On "
cQuery += " FK1_FILIAL = '" + xFilial("FK1") + "' "
cQuery += " AND FK1_IDDOC = FK7.FK7_IDDOC "
cQuery += " AND FK1.D_E_L_E_T_ = ' ' "

cQuery += " Inner Join " + RetSqlName("FKA") + " FKA "
cQuery += " On "
cQuery += " FKA_FILIAL = '" + xfilial("FKA") + "' "
cQuery += " AND FKA_TABORI = 'FK1' "
cQuery += " AND FKA_IDORIG = FK1.FK1_IDFK1 "
cQuery += " AND FKA.D_E_L_E_T_ = ' ' "

cQuery += " Left Join ( "
cQuery += " select SUM( Case  when FK1_TPDOC = 'ES' then FK1_VALOR else 0 END ) TOT_ES, SUM( Case  when FK1_TPDOC <> 'ES' then FK1_VALOR else 0 END ) TOT_NES, FK1_IDDOC from "
cQuery += " " + retsqlName("FK1") + " "
cQuery += " Where FK1_FILIAL = '" + xfilial("FK1") +  "' "

if lBaixaDisp 
	cQuery += " 	AND FK1_DTDISP < '"+DtoS(dDatDe)+"' "
Else
	cQuery += " 	AND FK1_DATA < '"+DtoS(dDatDe)+"' "
EndIf


cQuery += "   AND FK1_MOTBX NOT IN ('LIQ', 'NEG') "
cQuery += " 	AND D_E_L_E_T_ = ' ' " 
cQuery += " group By FK1_IDDOC "
cQuery += " ) J "
cQuery += " 	On J.FK1_IDDOC = FK7ORI.FK7_IDDOC "

/*
cQuery += " LEFT JOIN " + oFK5FK7:getrealName() + " TrueFK57 "
cQuery += " On "
cQuery += " TrueFK57.FKA_IDPROC = FKA.FKA_IDPROC "
*/
// Família
cQuery	+= "INNER JOIN "+RetSqlName("BA3")+" BA3 "
cQuery	+= "ON BA3_FILIAL='"+xFilial('BA3')+"' "
cQuery	+= "  AND BA3_CODINT=BM1.BM1_CODINT "
cQuery	+= "  AND BA3_CODEMP=BM1.BM1_CODEMP "
cQuery	+= "  AND BA3_MATRIC=BM1.BM1_MATRIC "
cQuery	+= "  AND BA3.D_E_L_E_T_ = ' ' "

// Usuário
cQuery	+= "INNER JOIN "+RetSqlName("BA1")+" BA1 "
cQuery	+= "ON BA1_FILIAL='"+xFilial('BA1')+"' "
cQuery	+= "  AND BA1_CODINT=BM1.BM1_CODINT "
cQuery	+= "  AND BA1_CODEMP=BM1.BM1_CODEMP "
cQuery	+= "  AND BA1_MATRIC=BM1.BM1_MATRIC "
cQuery	+= "  AND BA1_TIPREG=BM1.BM1_TIPREG "
cQuery	+= "  AND BA1.D_E_L_E_T_ = ' ' "

// Grupo Empresa
cQuery	+= "INNER JOIN "+RetSqlName("BG9")+" BG9 "
cQuery	+= "ON BG9_FILIAL='"+xFilial('BG9')+"' "
cQuery	+= "  AND BG9_CODINT=BM1.BM1_CODINT "
cQuery	+= "  AND BG9_CODIGO=BM1.BM1_CODEMP "
cQuery	+= "  AND BG9.D_E_L_E_T_ = ' ' "

// Usuário Titular
cQuery	+= "LEFT JOIN "+RetSqlName("BA1")+" TIT "
cQuery	+= "ON TIT.BA1_FILIAL='"+xFilial("BA1")+"' "
cQuery	+= "  AND TIT.BA1_CODINT=BM1.BM1_CODINT "
cQuery	+= "  AND TIT.BA1_CODEMP=BM1.BM1_CODEMP "
cQuery	+= "  AND TIT.BA1_MATRIC=BM1.BM1_MATRIC "
cQuery	+= "  AND TIT.BA1_RESFAM = '1' "
cQuery	+= "  AND TIT.D_E_L_E_T_ = ' ' "

// Produto Saúde
cQuery	+= "INNER JOIN "+RetSqlName("BI3")+" BI3 "
cQuery	+= "ON BI3_FILIAL='"+xFilial("BI3")+"' "
cQuery	+= "  AND BI3_CODINT=BM1.BM1_CODINT "
If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"		
	cQuery	+= "  AND ( BI3_CODIGO = DECODE(BA1.BA1_CODPLA, '    ', BA3.BA3_CODPLA, BA1.BA1_CODPLA) "
	cQuery	+= "  AND BI3_VERSAO = DECODE(BA1.BA1_VERSAO, '   ', BA3.BA3_VERSAO, BA1.BA1_VERSAO) ) "
Else
	cQuery	+= "  AND BI3_CODIGO = ("
	cQuery	+= "CASE WHEN BA1.BA1_CODPLA = ' ' THEN BA3.BA3_CODPLA "
	cQuery	+= "ELSE BA1.BA1_CODPLA END) "
	cQuery	+= "  AND BI3_VERSAO = ("
	cQuery	+= "CASE WHEN BA1.BA1_VERSAO = ' ' THEN BA3.BA3_VERSAO "
	cQuery	+= "ELSE BA1.BA1_VERSAO END) "
EndIf
cQuery	+= "  AND BI3.D_E_L_E_T_ = ' ' "

// Tabela Tipos de Títulos
cQuery	+= "INNER JOIN "+RetSqlName("SX5")+" SX5 "
cQuery	+= "ON SX5.X5_FILIAL='"+xFilial('SX5')+"' "
cQuery	+= "  AND SX5.X5_TABELA='05' "
cQuery	+= "  AND SX5.X5_CHAVE=SE1.E1_TIPO "
cQuery	+= "  AND SX5.D_E_L_E_T_ = ' ' "

// Contrato
cQuery	+= "LEFT JOIN "+RetSqlName("BT5")+" BT5 "
cQuery	+= "ON BT5_FILIAL='"+xFilial('BT5')+"' "
cQuery	+= "  AND BT5_CODINT=BM1.BM1_CODINT "
cQuery	+= "  AND BT5_CODIGO=BM1.BM1_CODEMP "
cQuery	+= "  AND BT5_NUMCON=BM1.BM1_CONEMP "
cQuery	+= "  AND BT5_VERSAO=BM1.BM1_VERCON "
cQuery	+= "  AND BT5.D_E_L_E_T_ = ' ' "

// Versões dos Contratos
cQuery	+= "LEFT JOIN "+RetSqlName("BQB")+" BQB "
cQuery	+= "ON BQB_FILIAL='"+xFilial('BQB')+"' "
cQuery	+= "  AND BQB_CODINT=BM1.BM1_CODINT "
cQuery	+= "  AND BQB_CDEMP=BM1.BM1_CODEMP "
cQuery	+= "  AND BQB_NUMCON=BM1.BM1_CONEMP "
cQuery	+= "  AND BQB_VERSAO=BM1.BM1_VERCON "
cQuery	+= "  AND BQB.D_E_L_E_T_ = ' ' "

// SubContratos
cQuery	+= "LEFT JOIN "+RetSqlName("BQC")+" BQC "
cQuery	+= "ON BQC_FILIAL='"+xFilial('BQB')+"' "
cQuery	+= "  AND BQC_CODINT=BM1.BM1_CODINT "
cQuery	+= "  AND BQC_CODEMP=BM1.BM1_CODEMP "
cQuery	+= "  AND BQC_NUMCON=BM1.BM1_CONEMP "
cQuery	+= "  AND BQC_VERCON=BM1.BM1_VERCON "
cQuery	+= "  AND BQC_SUBCON=BM1.BM1_SUBCON "
cQuery	+= "  AND BQC_VERSUB=BM1.BM1_VERSUB "
cQuery	+= "  AND BQC.D_E_L_E_T_ = ' ' "

cQuery += " WHERE "
//cQuery += " TrueFK57.FKA_IDPROC IS NOT NULL "

if lBaixaDisp
    //cQuery += "   AND FK5_DTDISP BETWEEN '" + dtos(dDatDe) + "' AND '" +  dtos(dDatAte) + "' "
    cQuery += "   FK1_DTDISP BETWEEN '" + dtos(dDatDe) + "' AND '" +  dtos(dDatAte) + "' "
else    
    //cQuery += "   AND FK1_DATA BETWEEN '" + dtos(dDatDe) + "' AND '" +  dtos(dDatAte) + "' "
    cQuery += "   FK1_DATA BETWEEN '" + dtos(dDatDe) + "' AND '" +  dtos(dDatAte) + "' "
endif

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
		cQuery	+= "AND BT5_INTERC = '1' "
	
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
//cQuery  += " AND BM1_NUMTIT ='" + GetNewPar("MV_PLR463", " ") + "' "
//cQuery += " AND BM1_MATRIC = '007922' " 
//cQuery  += " AND BM1_NUMTIT IN('001306200', '001305987') "
cQuery	+= "  AND BM1.D_E_L_E_T_=' ' "

cQuery += " UNION "

cQuery	+= "SELECT BM1_CODINT,BM1_CODEMP,BM1_CONEMP,BM1_VERCON,BM1_SUBCON,BM1_VERSUB,"
cQuery	+= "BM1_MATRIC,BM1_TIPREG,BM1_DIGITO,BM1_MES,BM1_ANO,BM1_VALOR, BM1.R_E_C_N_O_ AS BM1REG,"
cQuery	+= "BM1_TIPO,BM1_TIPTIT,BM1_PREFIX AS PREFIXO, BM1_NUMTIT AS NUMERO, BM1_PARCEL AS PARCELA,BM1_CODTIP,BM1_CODEVE,"
cQuery	+= "BM1_ALIAS, BM1_ORIGEM, BM1_PLNUCO,"
cQuery	+= "BI3.BI3_DTAPPR,BI3.BI3_CODSEG,BI3.BI3_MODPAG,BI3.BI3_TIPCON,BI3.BI3_SUSEP, "
cQuery	+= "BA1.BA1_NOMUSR,BA1.BA1_LOCSIB,BA1.BA1_DIGITO,BA1.BA1_DATINC, " 

cQuery += " COALESCE(TIT.BA1_NOMUSR, "
cQuery += "        ( "
cQuery += " SELECT TT.BA1_NOMUSR "
cQuery += "      FROM " + RetSqlName("BA1") + " TT " 
cQuery += "     WHERE TT.BA1_FILIAL='" + xFilial("BA1") + "' "
cQuery += "       AND TT.BA1_CODINT=BA1.BA1_CODINT "
cQuery += "       AND TT.BA1_CODEMP=BA1.BA1_CODEMP "
cQuery += "       AND TT.BA1_MATRIC=BA1.BA1_MATRIC "
cQuery += "       AND TT.BA1_RESFAM = '1' "
cQuery += "       AND TT.D_E_L_E_T_ = ' ' "
cQuery += "        ) "
cQuery += "        ) NOMTIT, "  
   
cQuery += " COALESCE(TIT.BA1_CPFUSR, "
cQuery += "        ( "
cQuery += " SELECT TT.BA1_CPFUSR "
cQuery += "      FROM " + RetSqlName("BA1") + " TT " 
cQuery += "     WHERE TT.BA1_FILIAL='" + xFilial("BA1") + "' "
cQuery += "       AND TT.BA1_CODINT=BA1.BA1_CODINT "
cQuery += "       AND TT.BA1_CODEMP=BA1.BA1_CODEMP "
cQuery += "       AND TT.BA1_MATRIC=BA1.BA1_MATRIC "
cQuery += "       AND TT.BA1_RESFAM = '1' "
cQuery += "       AND TT.D_E_L_E_T_ = ' ' "
cQuery += "        ) "
cQuery += "        ) CPFTIT, " 

cQuery	+= "BG9.BG9_TIPO,BG9.BG9_DESCRI,BT5.BT5_INTERC,BT5.BT5_TIPOIN,BQB.BQB_DATINI,BQB.BQB_DATFIN,BQC.BQC_DESCRI," 

if lBaixaDisp
//	cQuery += " TrueFK57.FK5_DTDISP AS BAIXA_DISP, "
	cQuery += " FK1.FK1_DTDISP AS BAIXA_DISP, "
else
	cQuery += " FK1.FK1_DATA AS BAIXA_DISP, "
endif

cQuery	+= "SE1.E1_VENCREA AS VENCTO, SE1.E1_SALDO, SE1.E1_VALOR, SE1.E1_EMISSAO, SE1.E1_BAIXA, SE1.E1_VALLIQ, "
cQuery	+= "SX5.X5_DESCRI AS DESCDOC,"

cQuery	+= " (K.TOT_NES - K.TOT_ES + COALESCE(FK6DC.FK6_VALMOV, 0)) FK1_VALOR, FK1.FK1_DATA,"
cQuery	+= " ' ' AS TIPCOB, '      ' AS MESLCT, 0 AS FI7_VALOR, 0 VALNEG, ' ' ORIGEM, FK1_ORIGEM FK1ORI  "

cQuery += " , 0 AS FI7REC, FK1.FK1_TPDOC FKTPDOC, FK1.R_E_C_N_O_ FK1REC, SE1.R_E_C_N_O_ SE1REC, 'A' TIPOY,  COALESCE(YU.TOT_MUL, 0) + COALESCE(YU.TOT_JUR, 0) VALDIF "

cQuery += " FROM " + RetSqlName("BM1") + " BM1 "

cQuery += " INNER JOIN " + RetSqlName("SE1") + " SE1 "
cQuery += "    ON E1_FILIAL =  '" + xFilial("SE1") + "' "
cQuery += "   AND BM1_PLNUCO = E1_PLNUCOB "
cQuery += "   AND BM1_PREFIX = E1_PREFIXO "
cQuery += "   AND BM1_NUMTIT = E1_NUM "
cQuery += "   AND BM1_PARCEL = E1_PARCELA " 
cQuery += "   AND BM1_TIPTIT = E1_TIPO " 
cQuery += "   AND SE1.E1_CODINT = '"+MV_PAR03+"' "
cQuery += "   AND SE1.E1_CODEMP >= '"+MV_PAR04+"' "
cQuery += "   AND SE1.E1_CODEMP <= '"+MV_PAR05+"' "
cQuery	+= "  AND SE1.E1_TIPO NOT IN ('RA ','PA ',' NCC ',' NDF') "  
cQuery	+= "  AND SUBSTRING(SE1.E1_ORIGEM,1,3) = 'PLS' " 
cQuery	+= "  AND SE1.E1_TIPOLIQ IN('LIQ','CAN','NEG') "
cQuery += "   AND E1_EMISSAO <='"+DtoS(dDatAte)+"' "	
cQuery += "   AND SE1.D_E_L_E_T_ = ' ' "

cQuery += " Inner Join " + retsqlName("FK7") + " FK7 " 
cQuery += " On "
cQuery += " FK7_FILIAL = '" + xFilial("FK7") + "' "
cQuery += " AND FK7_ALIAS = 'SE1' "

If(SubStr(Alltrim(Upper(TCGetDb())),1,6)) == "ORACLE"
	cQuery += " AND FK7_CHAVE = SE1.E1_FILIAL||'|'||SE1.E1_PREFIXO||'|'||SE1.E1_NUM||'|'||SE1.E1_PARCELA||'|'||SE1.E1_TIPO||'|'||SE1.E1_CLIENTE||'|'||SE1.E1_LOJA" + " "
Else
	cQuery += " AND FK7_CHAVE = SE1.E1_FILIAL+'|'+SE1.E1_PREFIXO+'|'+SE1.E1_NUM+'|'+SE1.E1_PARCELA+'|'+SE1.E1_TIPO+'|'+SE1.E1_CLIENTE+'|'+SE1.E1_LOJA" + " "
Endif

cQuery += " AND FK7.D_E_L_E_T_ = ' ' "

cQuery += " Inner Join " + retSqlName("FK1") + " FK1 "
cQuery += " On "
cQuery += " FK1_FILIAL = '" + xFilial("FK1") + "' "
cQuery += " AND FK1_IDDOC = FK7.FK7_IDDOC "

if lBaixaDisp
	cQuery += " 	AND FK1_DTDISP <= '"+DtoS(dDatAte)+"' "
	cQuery += " 	AND FK1_DTDISP >= '"+DtoS(dDatDe)+"' "
else
	cQuery += " 	AND FK1_DATA <= '"+DtoS(dDatAte)+"' "
	cQuery += " 	AND FK1_DATA >= '"+DtoS(dDatDe)+"' "
endif

cQuery += " AND FK1_MOTBX NOT IN('LIQ' , 'CAN' , 'NEG') "
cQuery += " AND FK1.D_E_L_E_T_ = ' ' "

cQuery += " Inner Join ( "
cQuery += " select SUM( Case  when FK1_TPDOC = 'ES' then FK1_VALOR else 0 END ) TOT_ES, SUM( Case  when FK1_TPDOC <> 'ES' then FK1_VALOR else 0 END ) TOT_NES, FK1_IDDOC 
if lBaixaDisp
	cQuery += " , FK1_DTDISP "
else
	cQuery += " , FK1_DATA  "
endif
cQuery += " from "
cQuery += " " + retsqlName("FK1") + " "
cQuery += " Where FK1_FILIAL = '" + xfilial("FK1") +  "' "
cQuery += "   AND FK1_MOTBX NOT IN('LIQ' , 'CAN' , 'NEG') "
cQuery += " 	AND D_E_L_E_T_ = ' ' " 
cQuery += " group By FK1_IDDOC "

if lBaixaDisp
	cQuery += " , FK1_DTDISP "
else
	cQuery += " , FK1_DATA  "
endif

cQuery += " ) K "
cQuery += " 	On K.FK1_IDDOC = FK7.FK7_IDDOC "

if lBaixaDisp
	cQuery += " 	AND FK1.FK1_DTDISP = K.FK1_DTDISP "
else
	cQuery += " 	AND FK1.FK1_DATA = K.FK1_DATA "
endif

cQuery += " Left Join ( "
cQuery += " select SUM( Case  when FK6_TPDOC = 'JR' then FK6_VALMOV else 0 END ) TOT_JUR, SUM( Case  when FK6_TPDOC = 'MT' then FK6_VALMOV else 0 END ) TOT_MUL, FK1_IDDOC from "
cQuery += " " + retsqlName("FK6") + " FK6 "
cQuery += " Inner Join " + RetSqlName("FK1") + " FK1 "
cQuery += " On "
cQuery += "   FK1_FILIAL = '" + xFilial("FK1") + "' "
cQuery += "   AND FK1_IDFK1 = FK6.FK6_IDORIG "
cQuery	+= "   AND FK1_MOTBX NOT IN('LIQ','CAN','NEG') "
if lBaixaDisp
	cQuery += " AND FK1.FK1_DTDISP BETWEEN '" + dtos(dDatDe) + "' AND '" +  dtos(dDatAte) + "' "
else	
	cQuery += " AND FK1.FK1_DATA BETWEEN '" + dtos(dDatDe) + "' AND '" +  dtos(dDatAte) + "' "
endif
cQuery += " Where FK6_FILIAL = '" + xfilial("FK1") +  "' "
cQuery += " 	AND FK6.D_E_L_E_T_ = ' ' " 
cQuery += " group By FK1_IDDOC "
cQuery += " ) YU "
cQuery += " 	On YU.FK1_IDDOC = FK7.FK7_IDDOC "

cQuery += " Left Join " + RetSqlName("FK6") + " FK6DC "
cQuery += " On "
cQuery += " FK6DC.FK6_FILIAL = '" + xfilial("FK6") + "' "
cQuery += " AND FK6DC.FK6_IDORIG = FK1.FK1_IDFK1 "
cQuery += " AND FK6DC.FK6_TPDOC = 'DC' "
cQuery += " AND FK6DC.D_E_L_E_T_ = ' ' "


cQuery += " Inner Join " + RetSqlName("FKA") + " FKA "
cQuery += " On "
cQuery += " FKA_FILIAL = '" + xfilial("FKA") + "' "
cQuery += " AND FKA_TABORI = 'FK1' "
cQuery += " AND FKA_IDORIG = FK1.FK1_IDFK1 "
cQuery += " AND FKA.D_E_L_E_T_ = ' ' "

/*
cQuery += " LEFT JOIN " + oFK5FK7:getrealName() + " TrueFK57 "
cQuery += " On "
cQuery += " TrueFK57.FKA_IDPROC = FKA.FKA_IDPROC "
*/
// Família
cQuery	+= "INNER JOIN "+RetSqlName("BA3")+" BA3 "
cQuery	+= " ON BA3_FILIAL = '"+xFilial('BA3')+"' "
cQuery	+= "AND BA3_CODINT = BM1.BM1_CODINT "
cQuery	+= "AND BA3_CODEMP = BM1.BM1_CODEMP "
cQuery	+= "AND BA3_MATRIC = BM1.BM1_MATRIC "
cQuery	+= "AND BA3.D_E_L_E_T_ = ' ' "
// Usuário
cQuery	+= "INNER JOIN "+RetSqlName("BA1")+" BA1 "
cQuery	+= " ON BA1_FILIAL = '"+xFilial('BA1')+"' "
cQuery	+= "AND BA1_CODINT = BM1.BM1_CODINT "
cQuery	+= "AND BA1_CODEMP = BM1.BM1_CODEMP "
cQuery	+= "AND BA1_MATRIC = BM1.BM1_MATRIC "
cQuery	+= "AND BA1_TIPREG = BM1.BM1_TIPREG "
cQuery	+= "AND BA1.D_E_L_E_T_ = ' ' "
// Grupo Empresa
cQuery	+= "INNER JOIN "+RetSqlName("BG9")+" BG9 "
cQuery	+= " ON BG9_FILIAL = '"+xFilial('BG9')+"' "
cQuery	+= "AND BG9_CODINT = BM1.BM1_CODINT "
cQuery	+= "AND BG9_CODIGO = BM1.BM1_CODEMP "
cQuery	+= "AND BG9.D_E_L_E_T_ = ' ' "

// Usuário Titular
cQuery	+= "LEFT JOIN "+RetSqlName("BA1")+" TIT "
cQuery	+= " ON TIT.BA1_FILIAL = '"+xFilial("BA1")+"' "
cQuery	+= "AND TIT.BA1_CODINT = BM1.BM1_CODINT "
cQuery	+= "AND TIT.BA1_CODEMP = BM1.BM1_CODEMP "
cQuery	+= "AND TIT.BA1_MATRIC = BM1.BM1_MATRIC "
cQuery	+= "  AND TIT.BA1_RESFAM = '1' "
cQuery	+= "AND TIT.D_E_L_E_T_ = ' ' "

// Produto Saúde
cQuery	+= "INNER JOIN "+RetSqlName("BI3")+" BI3 "
cQuery	+= "ON BI3_FILIAL='"+xFilial("BI3")+"' "
cQuery	+= "AND BI3_CODINT=BM1.BM1_CODINT "

If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"		
	cQuery	+= "AND ( BI3_CODIGO = DECODE(BA1.BA1_CODPLA, '    ', BA3.BA3_CODPLA, BA1.BA1_CODPLA) "
	cQuery	+= "AND BI3_VERSAO = DECODE(BA1.BA1_VERSAO, '   ', BA3.BA3_VERSAO, BA1.BA1_VERSAO) ) "
Else
	cQuery	+= "AND BI3_CODIGO = ("
	cQuery	+= "CASE WHEN BA1.BA1_CODPLA = ' ' THEN BA3.BA3_CODPLA "
	cQuery	+= "ELSE BA1.BA1_CODPLA END) "
	cQuery	+= "AND BI3_VERSAO = ("
	cQuery	+= "CASE WHEN BA1.BA1_VERSAO = ' ' THEN BA3.BA3_VERSAO "
	cQuery	+= "ELSE BA1.BA1_VERSAO END) "
EndIf
cQuery	+= "AND BI3.D_E_L_E_T_ = ' ' "

// Tabela Tipos de Títulos
cQuery	+= "INNER JOIN "+RetSqlName("SX5")+" SX5 "
cQuery	+= "ON SX5.X5_FILIAL='"+xFilial('SX5')+"' "
cQuery	+= "AND SX5.X5_TABELA='05' "
cQuery	+= "AND SX5.X5_CHAVE=SE1.E1_TIPO "
cQuery	+= "AND SX5.D_E_L_E_T_ = ' ' "

// Contrato
cQuery	+= "LEFT JOIN "+RetSqlName("BT5")+" BT5 "
cQuery	+= " ON BT5_FILIAL = '"+xFilial('BT5')+"' "
cQuery	+= "AND BT5_CODINT = BM1.BM1_CODINT "
cQuery	+= "AND BT5_CODIGO = BM1.BM1_CODEMP "
cQuery	+= "AND BT5_NUMCON = BM1.BM1_CONEMP "
cQuery	+= "AND BT5_VERSAO = BM1.BM1_VERCON "
cQuery	+= "AND BT5.D_E_L_E_T_ = ' ' "
// Versões dos Contratos
cQuery	+= "LEFT JOIN "+RetSqlName("BQB")+" BQB "
cQuery	+= " ON BQB_FILIAL = '"+xFilial('BQB')+"' "
cQuery	+= "AND BQB_CODINT = BM1.BM1_CODINT "
cQuery	+= "AND BQB_CDEMP  = BM1.BM1_CODEMP "
cQuery	+= "AND BQB_NUMCON = BM1.BM1_CONEMP "
cQuery	+= "AND BQB_VERSAO = BM1.BM1_VERCON "
cQuery	+= "AND BQB.D_E_L_E_T_ = ' ' "
// SubContratos
cQuery	+= "LEFT JOIN "+RetSqlName("BQC")+" BQC "
cQuery	+= " ON BQC_FILIAL = '"+xFilial('BQB')+"' "
cQuery	+= "AND BQC_CODINT = BM1.BM1_CODINT "
cQuery	+= "AND BQC_CODEMP = BM1.BM1_CODEMP "
cQuery	+= "AND BQC_NUMCON = BM1.BM1_CONEMP "
cQuery	+= "AND BQC_VERCON = BM1.BM1_VERCON "
cQuery	+= "AND BQC_SUBCON = BM1.BM1_SUBCON "
cQuery	+= "AND BQC_VERSUB = BM1.BM1_VERSUB "
cQuery	+= "AND BQC.D_E_L_E_T_ = ' ' "

cQuery += " WHERE "

if lBaixaDisp

//	cQuery += " (( TRUEFK57.FKA_IDPROC IS NOT NULL AND TRUEFK57.FK5_DTDISP BETWEEN '" + dtos(dDatDe) + "'	AND '" + dtos(dDatAte) + "' ) "
// 	cQuery += " OR FK1_DATA BETWEEN '" + dtos(dDatDe) + "'	AND '" + dtos(dDatAte) + "'	) "
//	cQuery += " ( TRUEFK57.FKA_IDPROC IS NOT NULL AND TRUEFK57.FK5_DTDISP BETWEEN '" + dtos(dDatDe) + "'	AND '" + dtos(dDatAte) + "' ) "
	cQuery += " FK1.FK1_DTDISP BETWEEN '" + dtos(dDatDe) + "' AND '" +  dtos(dDatAte) + "' "
else	
	cQuery += " FK1.FK1_DATA BETWEEN '" + dtos(dDatDe) + "' AND '" +  dtos(dDatAte) + "' "
endif

// Filtra Lançamentos conforme retorno do ponto de entrada
If Len(aPtoQuery) > 0
	For nPos := 1 to Len(aPtoQuery)
		cQuery += IIf( nPos==1, "AND BM1_CODTIP IN('"+aPtoQuery[nPos,1], "'"+aPtoQuery[nPos,1] )
		cQuery += IIf( Len(aPtoQuery)>1, IIf(Len(aPtoQuery)==nPos,  "') ", "',"), "') ")
	Next

Else
	
	//Se Benef.Operadoras, filtra tipo de movimentação coparticipação         
	If MV_PAR07 == 1
		cQuery	+= "AND BM1_CODTIP IN ('101','102','103','107','108','109','110','111','113','117','118','128','129','130','131','132','133','135','136','146','180','184','186','188','189','190','191') "
		cQuery	+= "AND BT5_INTERC <> '1' "
	
	//Se Coparticipação, filtra tipos de movimentacao                         
	ElseIf MV_PAR07 == 2
		cQuery	+= "AND BM1_CODTIP IN ('104','116','120','121','122','123','124','125','127','134','137','138','139','140','141','142','143','144','145','147','148','149','150','151','152','153','154','155','156','157','158','159','160','161','162','163','164','165','166','167','168','169','170','171','172','173','174','175','176','177','181','185') "
		cQuery	+= "AND BT5_INTERC <> '1' "
	
	//Se Benef.Outras Operadoras, trata somente contratos de Intercambio.     
	ElseIf MV_PAR07 == 3
		cQuery	+= "AND BT5_INTERC = '1' "
	
	//Se Rel.Plan.Odonto, filtra tipo de movimentação odontologico            
	ElseIf MV_PAR07 == 4 
		cQuery	+= "AND BM1_CODTIP IN ('131','132') "
		cQuery	+= "AND BT5_INTERC <> '1' "
	
	//Se Rel.Pl.Med.Hosp, exclui tipo de movimentação odontologico            
	ElseIf MV_PAR07 == 5 
		cQuery	+= "AND BM1_CODTIP NOT IN ('131','132') "
		cQuery	+= "AND BT5_INTERC <> '1' "
	EndIf

EndIf
cQuery	+= cWhere		// Adição do conteúdo do ponto de entrada, caso exista.
//cQuery  += " AND BM1_NUMTIT ='" + GetNewPar("MV_PLR463", " ") + "' "
//cQuery += " AND BM1_MATRIC = '007922' " 
//cQuery  += " AND BM1_NUMTIT IN('001306200', '001305987') "
cQuery += " AND (K.TOT_NES - K.TOT_ES >= 0.01 OR K.TOT_NES - K.TOT_ES <= -0.01 ) "
cQuery	+= " AND BM1.D_E_L_E_T_ = ' ' "

//----
cQuery += " UNION "
cQuery	+= "SELECT BM1_CODINT,BM1_CODEMP,BM1_CONEMP,BM1_VERCON,BM1_SUBCON,BM1_VERSUB,"
cQuery	+= "BM1_MATRIC,BM1_TIPREG,BM1_DIGITO,BM1_MES,BM1_ANO,BM1_VALOR, BM1.R_E_C_N_O_ AS BM1REG,"
cQuery	+= "BM1_TIPO,BM1_TIPTIT,BM1_PREFIX AS PREFIXO, BM1_NUMTIT AS NUMERO, BM1_PARCEL AS PARCELA,BM1_CODTIP,BM1_CODEVE,"
cQuery	+= "BM1_ALIAS, BM1_ORIGEM, BM1_PLNUCO,"
cQuery	+= "BI3.BI3_DTAPPR,BI3.BI3_CODSEG,BI3.BI3_MODPAG,BI3.BI3_TIPCON,BI3.BI3_SUSEP, "
cQuery	+= "BA1.BA1_NOMUSR,BA1.BA1_LOCSIB,BA1.BA1_DIGITO,BA1.BA1_DATINC, " 
cQuery	+= "TIT.BA1_NOMUSR NOMTIT, TIT.BA1_CPFUSR CPFTIT," 
cQuery	+= "BG9.BG9_TIPO,BG9.BG9_DESCRI,BT5.BT5_INTERC,BT5.BT5_TIPOIN,BQB.BQB_DATINI,BQB.BQB_DATFIN,BQC.BQC_DESCRI," 

if lBaixaDisp
	//cQuery += " TrueFK57.FK5_DTDISP AS BAIXA_DISP, "
	cQuery += " FK1_DTDISP AS BAIXA_DISP, "
else
	cQuery += " FK1_DATA AS BAIXA_DISP, "
endif

cQuery	+= "SE1.E1_VENCREA AS VENCTO, SE1.E1_SALDO, SE1.E1_VALOR, SE1.E1_EMISSAO, SE1.E1_BAIXA, "

//SE1.
cQuery += "( Select SUM(FI7_VALOR) VALNEG "
cQuery += " From "  + RetsqlName("FI7") + " FI7 "
cQuery += " Where "
cQuery += " FI7_FILIAL = SE1.E1_FILIAL "
cQuery += " AND FI7_PRFORI = SE1.E1_PREFIXO "
cQuery += " AND FI7_NUMORI = SE1.E1_NUM "
cQuery += " AND FI7_PARORI = SE1.E1_PARCELA "
cQuery += " AND FI7_TIPORI = SE1.E1_TIPO "
cQuery += " AND FI7_CLIORI = SE1.E1_CLIENTE "
cQuery += " AND FI7_LOJORI = SE1.E1_LOJA "
cQuery += " AND FI7.D_E_L_E_T_ = ' ' ) "

cQuery += " E1_VALLIQ, "
cQuery	+= "SX5.X5_DESCRI AS DESCDOC, "
cQuery	+= "FK1.FK1_VALOR, FK1.FK1_DATA,"
cQuery	+= " ' ' AS TIPCOB, '      ' AS MESLCT, FI7.FI7_VALOR AS FI7_VALOR, "

cQuery += " SE1_NEG.E1_VALOR - SE1_NEG.E1_DESCONT "
//cQuery += "( Select SUM(FI7_VALOR) VALNEG "
//cQuery += " From "  + RetsqlName("FI7") + " FI7 "
//cQuery += " Where "
//cQuery += " FI7_FILIAL = SE1.E1_FILIAL "
//cQuery += " AND FI7_PRFORI = SE1.E1_PREFIXO "
//cQuery += " AND FI7_NUMORI = SE1.E1_NUM "
//cQuery += " AND FI7_PARORI = SE1.E1_PARCELA "
//cQuery += " AND FI7_TIPORI = SE1.E1_TIPO "
//cQuery += " AND FI7_CLIORI = SE1.E1_CLIENTE "
//cQuery += " AND FI7_LOJORI = SE1.E1_LOJA "
//cQuery += " AND FI7.D_E_L_E_T_ = ' ' ) "

cQuery += " VALNEG, ' ' ORIGEM, FK1_ORIGEM FK1ORI  "

cQuery += " , FI7.R_E_C_N_O_ AS FI7REC, FK1.FK1_TPDOC FKTPDOC, FK1.R_E_C_N_O_ FK1REC, SE1.R_E_C_N_O_ SE1REC, '2' TIPOY,  SE1.E1_MULTA + SE1.E1_JUROS VALDIF "

cQuery += " FROM " + RetSqlName("BM1") + " BM1 "

cQuery += " INNER JOIN " + RetSqlName("SE1") + " SE1 "
cQuery += "    ON BM1_FILIAL =  '" + xFilial("BM1") + "' "
cQuery += "   AND BM1_PLNUCO = E1_PLNUCOB "
cQuery += "   AND BM1_PREFIX = E1_PREFIXO "
cQuery += "   AND BM1_NUMTIT = E1_NUM "
cQuery += "   AND BM1_PARCEL = E1_PARCELA " 
cQuery += "   AND BM1_TIPTIT = E1_TIPO " 
cQuery += "   AND SE1.E1_CODINT = '"+MV_PAR03+"' "
cQuery += "   AND SE1.E1_CODEMP >= '"+MV_PAR04+"' "
cQuery += "   AND SE1.E1_CODEMP <= '"+MV_PAR05+"' "
cQuery += "   AND SE1.E1_TIPO NOT IN ('RA ','PA ',' NCC ',' NDF') "  
cQuery += "   AND SUBSTRING(SE1.E1_ORIGEM,1,3) = 'PLS' " 
cQuery += "   AND SE1.E1_TIPOLIQ IN ( 'LIQ', 'NEG' ) "
cQuery += "   AND E1_EMISSAO <='"+DtoS(dDatAte)+"' "	
cQuery += "   AND SE1.D_E_L_E_T_ = ' ' "

cQuery += "   INNER JOIN " + /*'NEGOCIACAO'*/ retSqlName("FI7") + " FI7 " 
cQuery += "      ON FI7.FI7_FILIAL = E1_FILIAL "
cQuery += "     AND FI7.FI7_PRFORI = E1_PREFIXO "
cQuery += "     AND FI7.FI7_NUMORI = E1_NUM "
cQuery += "     AND FI7.FI7_PARORI = E1_PARCELA "
cQuery += "     AND FI7.FI7_TIPORI = E1_TIPO "
cQuery += "     AND FI7.FI7_CLIORI = E1_CLIENTE "
cQuery += "     AND FI7.FI7_LOJORI = E1_LOJA "
cQuery += " AND FI7.D_E_L_E_T_ = ' ' "

cQuery += " Inner Join " + retsqlName("SE1") + " SE1_NEG "
cQuery += " On "
cQuery += " SE1_NEG.E1_FILIAL = FI7.FI7_FILDES "
cQuery += " AND SE1_NEG.E1_PREFIXO = FI7.FI7_PRFDES "
cQuery += " AND SE1_NEG.E1_NUM = FI7.FI7_NUMDES "
cQuery += " AND SE1_NEG.E1_PARCELA = FI7.FI7_PARDES "
cQuery += " AND SE1_NEG.E1_TIPO = FI7.FI7_TIPDES "
cQuery += " AND SE1_NEG.E1_CLIENTE = FI7.FI7_CLIDES "
cQuery += " AND SE1_NEG.E1_LOJA = FI7.FI7_LOJDES "
//cQuery += " AND SE1_NEG.E1_TIPOLIQ IN('LIQ', 'NEG') "
cQuery += " AND SE1_NEG.D_E_L_E_T_ = ' ' "

cQuery += " Inner Join " + retsqlName("FK7") + " FK7 " 
cQuery += " On "
cQuery += " FK7_FILIAL = '" + xFilial("FK7") + "' "
cQuery += " AND FK7_ALIAS = 'SE1' "

If(SubStr(Alltrim(Upper(TCGetDb())),1,6)) == "ORACLE"
	cQuery += " AND FK7_CHAVE = SE1_NEG.E1_FILIAL||'|'||SE1_NEG.E1_PREFIXO||'|'||SE1_NEG.E1_NUM||'|'||SE1_NEG.E1_PARCELA||'|'||SE1_NEG.E1_TIPO||'|'||SE1_NEG.E1_CLIENTE||'|'||SE1_NEG.E1_LOJA" + " "
Else
	cQuery += " AND FK7_CHAVE = SE1_NEG.E1_FILIAL+'|'+SE1_NEG.E1_PREFIXO+'|'+SE1_NEG.E1_NUM+'|'+SE1_NEG.E1_PARCELA+'|'+SE1_NEG.E1_TIPO+'|'+SE1_NEG.E1_CLIENTE+'|'+SE1_NEG.E1_LOJA" + " "
Endif

cQuery += " AND FK7.D_E_L_E_T_ = ' ' "

cQuery += " Inner Join " + retSqlName("FK1") + " FK1 "
cQuery += " On "
cQuery += " FK1_FILIAL = '" + xFilial("FK1") + "' "
cQuery += " AND FK1_IDDOC = FK7.FK7_IDDOC "
cQuery += " AND FK1_MOTBX IN ('LIQ', 'NEG') "
cQuery += " AND FK1.D_E_L_E_T_ = ' ' "



/*
cQuery += " Inner Join " + RetSqlName("FKA") + " FKA "
cQuery += " On "
cQuery += " FKA_FILIAL = '" + xfilial("FKA") + "' "
cQuery += " AND FKA_TABORI = 'FK1' "
cQuery += " AND FKA_IDORIG = FK1.FK1_IDFK1 "
cQuery += " AND FKA.D_E_L_E_T_ = ' ' "
*/
/*
cQuery += " LEFT JOIN " + oFK5FK7:getrealName() + " TrueFK57 "
cQuery += " On "
cQuery += " TrueFK57.FKA_IDPROC = FKA.FKA_IDPROC "
*/
// Família
cQuery	+= "INNER JOIN "+RetSqlName("BA3")+" BA3 "
cQuery	+= "ON BA3_FILIAL='"+xFilial('BA3')+"' "
cQuery	+= "  AND BA3_CODINT=BM1.BM1_CODINT "
cQuery	+= "  AND BA3_CODEMP=BM1.BM1_CODEMP "
cQuery	+= "  AND BA3_MATRIC=BM1.BM1_MATRIC "
cQuery	+= "  AND BA3.D_E_L_E_T_ = ' ' "

// Usuário
cQuery	+= "INNER JOIN "+RetSqlName("BA1")+" BA1 "
cQuery	+= "ON BA1_FILIAL='"+xFilial('BA1')+"' "
cQuery	+= "  AND BA1_CODINT=BM1.BM1_CODINT "
cQuery	+= "  AND BA1_CODEMP=BM1.BM1_CODEMP "
cQuery	+= "  AND BA1_MATRIC=BM1.BM1_MATRIC "
cQuery	+= "  AND BA1_TIPREG=BM1.BM1_TIPREG "
cQuery	+= "  AND BA1.D_E_L_E_T_ = ' ' "

// Grupo Empresa
cQuery	+= "INNER JOIN "+RetSqlName("BG9")+" BG9 "
cQuery	+= "ON BG9_FILIAL='"+xFilial('BG9')+"' "
cQuery	+= "  AND BG9_CODINT=BM1.BM1_CODINT "
cQuery	+= "  AND BG9_CODIGO=BM1.BM1_CODEMP "
cQuery	+= "  AND BG9.D_E_L_E_T_ = ' ' "

// Usuário Titular
cQuery	+= "LEFT JOIN "+RetSqlName("BA1")+" TIT "
cQuery	+= "ON TIT.BA1_FILIAL='"+xFilial("BA1")+"' "
cQuery	+= "  AND TIT.BA1_CODINT=BM1.BM1_CODINT "
cQuery	+= "  AND TIT.BA1_CODEMP=BM1.BM1_CODEMP "
cQuery	+= "  AND TIT.BA1_MATRIC=BM1.BM1_MATRIC "
cQuery	+= "  AND TIT.BA1_RESFAM = '1' "
cQuery	+= "  AND TIT.D_E_L_E_T_ = ' ' "

// Produto Saúde
cQuery	+= "INNER JOIN "+RetSqlName("BI3")+" BI3 "
cQuery	+= "ON BI3_FILIAL='"+xFilial("BI3")+"' "
cQuery	+= "  AND BI3_CODINT=BM1.BM1_CODINT "
If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"		
	cQuery	+= "  AND ( BI3_CODIGO = DECODE(BA1.BA1_CODPLA, '    ', BA3.BA3_CODPLA, BA1.BA1_CODPLA) "
	cQuery	+= "  AND BI3_VERSAO = DECODE(BA1.BA1_VERSAO, '   ', BA3.BA3_VERSAO, BA1.BA1_VERSAO) ) "
Else
	cQuery	+= "  AND BI3_CODIGO = ("
	cQuery	+= "CASE WHEN BA1.BA1_CODPLA = ' ' THEN BA3.BA3_CODPLA "
	cQuery	+= "ELSE BA1.BA1_CODPLA END) "
	cQuery	+= "  AND BI3_VERSAO = ("
	cQuery	+= "CASE WHEN BA1.BA1_VERSAO = ' ' THEN BA3.BA3_VERSAO "
	cQuery	+= "ELSE BA1.BA1_VERSAO END) "
EndIf
cQuery	+= "  AND BI3.D_E_L_E_T_ = ' ' "

// Tabela Tipos de Títulos
cQuery	+= "INNER JOIN "+RetSqlName("SX5")+" SX5 "
cQuery	+= "ON SX5.X5_FILIAL='"+xFilial('SX5')+"' "
cQuery	+= "  AND SX5.X5_TABELA='05' "
cQuery	+= "  AND SX5.X5_CHAVE=SE1.E1_TIPO "
cQuery	+= "  AND SX5.D_E_L_E_T_ = ' ' "

// Contrato
cQuery	+= "LEFT JOIN "+RetSqlName("BT5")+" BT5 "
cQuery	+= "ON BT5_FILIAL='"+xFilial('BT5')+"' "
cQuery	+= "  AND BT5_CODINT=BM1.BM1_CODINT "
cQuery	+= "  AND BT5_CODIGO=BM1.BM1_CODEMP "
cQuery	+= "  AND BT5_NUMCON=BM1.BM1_CONEMP "
cQuery	+= "  AND BT5_VERSAO=BM1.BM1_VERCON "
cQuery	+= "  AND BT5.D_E_L_E_T_ = ' ' "

// Versões dos Contratos
cQuery	+= "LEFT JOIN "+RetSqlName("BQB")+" BQB "
cQuery	+= "ON BQB_FILIAL='"+xFilial('BQB')+"' "
cQuery	+= "  AND BQB_CODINT=BM1.BM1_CODINT "
cQuery	+= "  AND BQB_CDEMP=BM1.BM1_CODEMP "
cQuery	+= "  AND BQB_NUMCON=BM1.BM1_CONEMP "
cQuery	+= "  AND BQB_VERSAO=BM1.BM1_VERCON "
cQuery	+= "  AND BQB.D_E_L_E_T_ = ' ' "

// SubContratos
cQuery	+= "LEFT JOIN "+RetSqlName("BQC")+" BQC "
cQuery	+= "ON BQC_FILIAL='"+xFilial('BQB')+"' "
cQuery	+= "  AND BQC_CODINT=BM1.BM1_CODINT "
cQuery	+= "  AND BQC_CODEMP=BM1.BM1_CODEMP "
cQuery	+= "  AND BQC_NUMCON=BM1.BM1_CONEMP "
cQuery	+= "  AND BQC_VERCON=BM1.BM1_VERCON "
cQuery	+= "  AND BQC_SUBCON=BM1.BM1_SUBCON "
cQuery	+= "  AND BQC_VERSUB=BM1.BM1_VERSUB "
cQuery	+= "  AND BQC.D_E_L_E_T_ = ' ' "

cQuery += " WHERE "
//cQuery += " TrueFK57.FKA_IDPROC IS NOT NULL "
/*
if lBaixaDisp
    //cQuery += "   AND FK5_DTDISP BETWEEN '" + dtos(dDatDe) + "' AND '" +  dtos(dDatAte) + "' "
    cQuery += "   FK1_DTDISP BETWEEN '" + dtos(dDatDe) + "' AND '" +  dtos(dDatAte) + "' "
else    
    //cQuery += "   AND FK1_DATA BETWEEN '" + dtos(dDatDe) + "' AND '" +  dtos(dDatAte) + "' "
    cQuery += "   FK1_DATA BETWEEN '" + dtos(dDatDe) + "' AND '" +  dtos(dDatAte) + "' "
endif
*/
cQuery	+= "  BM1.D_E_L_E_T_=' ' "
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
		cQuery	+= "AND BT5_INTERC = '1' "
	
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
//cQuery  += " AND BM1_NUMTIT ='" + GetNewPar("MV_PLR463", " ") + "' "
//cQuery += " AND BM1_MATRIC = '007922' " 
//cQuery  += " AND BM1_NUMTIT IN('001306200', '001305987') "

//----

cQuery	+= "ORDER BY TIPOY, SE1REC, FK1REC, BM1_ANO,BM1_MES, "
cQuery	+= "BM1_CODINT,BM1_CODEMP,BM1_CONEMP,BM1_VERCON,BM1_SUBCON,BM1_VERSUB,BM1_MATRIC,BM1_TIPREG, "
cQuery += "BI3_CODSEG,BI3_MODPAG,BI3_DTAPPR,BI3_TIPCON,E1_EMISSAO "

nHandle := fCreate('c:\temp\QRY463.sql',0)
if nHandle > 0 
	fWrite(nHandle, CHR(13)+CHR(10)+cQuery+CHR(13)+CHR(10) )
	fClose(nHandle)
endif

MPSysOpenQuery( cQuery, 'QRYTMP' )
TCSetField("QRYTMP","BM1_VALOR","N",16,4)
TCSetField("QRYTMP","E1_VALOR","N",16,2)
TCSetField("QRYTMP","E1_SALDO","N",16,2)
TCSetField("QRYTMP","BI3_DTAPPR","D",08,0)
TCSetField("QRYTMP","VENCTO","D",08,0)
TCSetField("QRYTMP","E1_EMISSAO","D",08,0)
TCSetField("QRYTMP","E1_BAIXA","D",08,0)
TCSetField("QRYTMP","BM1REG","N",16,0)
TCSetField("QRYTMP","FK1_VALOR","N",16,2)
TCSetField("QRYTMP","VALNEG","N",16,2)
TCSetField("QRYTMP","FK1_DATA","D",08,0)
TCSetField("QRYTMP","FK1REC","N",16,0)
TCSetField("QRYTMP","SE1REC","N",16,0)
TCSetField("QRYTMP","BAIXA_DISP","D",08,0)

dbSelectArea("QRYTMP")
dbGoTop()

dbSelectArea('UPDALI')
Append From 'QRYTMP'
dbGoTop()

/* o objetivo do TcSqlExec abaixo é substituir todo o loop por um unico update*/
For nCase := 1 to len(aPtoQuery)

	cPtoQuery += " WHEN LTRIM(RTRIM(BM1_CODTIP)) = '" + allTrim(aPtoQuery[nCase][1]) + "' AND LTRIM(RTRIM(BM1_CODEVE)) = '" + allTrim(aPtoQuery[nCase][2]) +"' THEN '" + aPtoQuery[nCase][3]+"' " + chr(10) + chr(13)
	cPtoQuery += " WHEN LTRIM(RTRIM(BM1_CODTIP)) = '" + allTrim(aPtoQuery[nCase][1]) + "' THEN '" + aPtoQuery[nCase][3]+"' " + chr(10) + chr(13)

next nCase

For nCase := 1 to len(aPtoTpDoc)
 	cPtoTpDoc += " WHEN LTRIM(RTRIM(BM1_TIPTIT)) = '" + allTrim(aPtoTpDoc[nCase][1]) +"' THEN '" + aPtoTpDoc[nCase][2]+"' " + chr(10) + chr(13)
next nCase

cUpd := " UPDATE "+oUpdTable:GetRealName()
cUpd += " SET BM1_VALOR = CASE "
cUpd += " WHEN TIPOY = '2' AND BM1_TIPO = '2' THEN BM1_VALOR * -1 "
cUpd += " WHEN TIPOY = '2' THEN BM1_VALOR "
cUpd += "   WHEN VALNEG > 0 AND FI7_VALOR > 0 AND FI7_VALOR <> E1_VALOR AND BM1_TIPO = '2' THEN (BM1_VALOR/E1_VALOR) * FK1_VALOR * FI7_VALOR /VALNEG  * (E1_VALOR - VALDIF)/E1_VALLIQ * -1"//(BM1_VALOR/E1_VALLIQ) * FI7_VALOR * -1 * FK1_VALOR/VALNEG "
cUpd += "   WHEN VALNEG > 0 AND FI7_VALOR > 0 AND FI7_VALOR <> E1_VALOR                    THEN (BM1_VALOR/E1_VALOR) * FK1_VALOR * FI7_VALOR /VALNEG  * (E1_VALOR - VALDIF)/E1_VALLIQ " 

//cUpd += "   WHEN BM1_TIPO = '2'  AND TIPOZ IN ('NG3') THEN ( (BM1_VALOR / E1_VALOR) * ( VALFI7 ) * (E1_VALOR / VALSLDPAS) * - 1 ) " //O X marca o local 
//cUpd += "   WHEN BM1_TIPO <> '2' AND TIPOZ IN ('NG3') THEN ( (BM1_VALOR / E1_VALOR) * ( VALFI7 ) * (E1_VALOR / VALSLDPAS) ) "

cUpd += "   WHEN BM1_TIPO = '2' THEN ( BM1_VALOR * (FK1_VALOR/ (E1_VALOR + VALDIF)) ) * - 1 "
cUpd += "   ELSE BM1_VALOR * (FK1_VALOR/(E1_VALOR + VALDIF)) "
cUpd += "   END "

If Len(aPtoQuery) > 0
	cUpd += ", TIPCOB = CASE "
	cUpd += cPtoQuery
	cUpd += " ELSE TIPCOB "
	cUpd += " END "
endIf

If Len(aPtoTpDoc) > 0 
	cUpd += ", DESCDOC = CASE "
	cUpd += cPtoTpDoc
	cUpd += " ELSE DESCDOC " 
	cUpd += " END "
EndIf

//nHandle2 := fCreate('c:\temp\463upd.txt', 0)
//if nHandle2 > 0 
//	fWrite(nHandle2, CHR(13)+CHR(10)+cUpd+CHR(13)+CHR(10) )
//	fClose(nHandle2)
//endIf

nStatus := TCSQLExec(cUpd)

//if (nStatus < 0)
	
//	nHandle3 := fCreate('c:\temp\463TCSQLError.txt', 0)
//	if nHandle3 > 0
//		fWrite(nHandle3, CHR(13)+CHR(10)+TCSQLError()+CHR(13)+CHR(10) )
//		fClose(nHandle3)
//	endif

//	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "TCSQLError() " + TCSQLError(), 0, 0, {})	
//endif

cUpd 	:= " INSERT INTO " + oTempTable:GetRealName()

cUpd	+= "(BM1_CODINT,BM1_CODEMP,BM1_CONEMP,BM1_VERCON,BM1_SUBCON,BM1_VERSUB,"
cUpd	+= "BM1_MATRIC,BM1_TIPREG,BM1_DIGITO,BM1_MES,BM1_ANO,BM1_VALOR, BM1REG,"
cUpd	+= "BM1_TIPO,BM1_TIPTIT,PREFIXO ,NUMERO ,PARCELA ,BM1_CODTIP,BM1_CODEVE,"
cUpd	+= "BM1_ALIAS, BM1_ORIGEM, BM1_PLNUCO,"
cUpd	+= "BI3_DTAPPR,BI3_CODSEG,BI3_MODPAG,BI3_TIPCON,BI3_SUSEP, "
cUpd	+= "BA1_NOMUSR,BA1_LOCSIB,BA1_DIGITO,BA1_DATINC, "
cUpd 	+= " NOMTIT, "
cUpd 	+= " CPFTIT, "
cUpd	+= " BG9_TIPO,BG9_DESCRI,BT5_INTERC,BT5_TIPOIN,BQB_DATINI,BQB_DATFIN,BQC_DESCRI,BAIXA_DISP,"
cUpd	+= " VENCTO, E1_SALDO, E1_VALOR, E1_EMISSAO, E1_BAIXA, "
cUpd	+= " DESCDOC,"
cUpd	+= " FK1_VALOR, FK1_DATA,"
cUpd	+= " TIPCOB, MESLCT, FI7_VALOR, ORIGEM, FK1ORI, FKTPDOC, FK1REC, SE1REC, TIPOY, VALNEG )"

cUpd	+= "SELECT DISTINCT BM1_CODINT,BM1_CODEMP,BM1_CONEMP,BM1_VERCON,BM1_SUBCON,BM1_VERSUB,"
cUpd	+= "BM1_MATRIC,BM1_TIPREG,BM1_DIGITO,BM1_MES,BM1_ANO,BM1_VALOR, BM1REG,"
cUpd	+= "BM1_TIPO,BM1_TIPTIT,PREFIXO ,NUMERO ,PARCELA ,BM1_CODTIP,BM1_CODEVE,"
cUpd	+= "BM1_ALIAS, BM1_ORIGEM, BM1_PLNUCO,"
cUpd	+= "BI3_DTAPPR,BI3_CODSEG,BI3_MODPAG,BI3_TIPCON,BI3_SUSEP, "
cUpd	+= "BA1_NOMUSR,BA1_LOCSIB,BA1_DIGITO,BA1_DATINC, "
cUpd 	+= " NOMTIT, "
cUpd 	+= " CPFTIT, "
cUpd	+= " BG9_TIPO,BG9_DESCRI,BT5_INTERC,BT5_TIPOIN,BQB_DATINI,BQB_DATFIN,BQC_DESCRI,BAIXA_DISP,"
cUpd	+= " VENCTO, E1_SALDO, E1_VALOR, E1_EMISSAO, E1_BAIXA, "
cUpd	+= " DESCDOC,"
cUpd	+= " FK1_VALOR, FK1_DATA,"
cUpd	+= " TIPCOB, MESLCT, FI7_VALOR, ORIGEM, FK1ORI, FKTPDOC, FK1REC, SE1REC, TIPOY, VALNEG "
cUpd	+= " From " + oUpdTable:GetRealName()
cUpd	+= " Order By SE1REC , FK1REC "
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
QRYTMP->(dbCloseArea())
UPDALI->(dbCloseArea())
//TPLFK57->(DbCloseArea())

//oFK5FK7:Delete()
oUpdTable:Delete()

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

oOcorrencias:setMeter(("TRB")->(lastRec()))
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

Return()

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

//Static function parparpar(npilha,cfil, cpref, cnum, cpar, ctipo, ccli, cloj, nValI7, nPerBM1E1, dDatDe, dDatAte)
Static function parparpar(npilha,cfil, cpref, cnum, cpar, ctipo, ccli, cloj, nValI7, nPerBM1E1, dDatDe, dDatAte, nValK1NES, lUltimo, dDataDisp)

Local cSql := ""
Local nRet := 0
Local nAux := 1
Local ctab := GetNextAlias() //"parpar" + AllTrim(Str(npilha))
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
Local nValorNeg := 0
Local lfim := .T.
Local aRecnoFK1 := {}
local lBaixaDisp := (MV_PAR08 == 1) .AND. ( FK1->(FieldPos("FK1_DTDISP")) > 0 )
local aRet	:= {} //{ 0, Stod("") }
Local nPosData := 0
Local aAuxYTW	:= {}
Local cTabFi7 := GetNextAlias()

default cfil := xfilial('FI7')
default nValK1NES := 0
default lUltimo := .F.
If npilha == 0
	lZero := .T.
endIf
npilha++

DbSelectArea("BUZ")

cSql := QueryPar(lBaixaDisp,cDatax, dDatAte,cfil, cpref, cnum, cpar, ctipo, ccli, cloj)

dbUseArea(.T.,"TOPCONN",tcGenQry(,,cSql + cSqldif),ctab,.F.,.T.)

nTotPar := Contar(ctab,"!Eof()")
(ctab)->(DbGoTop())

//=======================================================================================

cFi7 := ChkFI7(cfil, cpref, cnum, ctipo, ccli, cloj)

dbUseArea(.T.,"TOPCONN",tcGenQry(,,cFi7),cTabFi7,.F.,.T.)

nTotFI7 := Contar(cTabFi7,"!Eof()")
(cTabFi7)->(DbGoTop())

//=======================================================================================

SE1->(dbSetOrder(1))
SE1->(Msseek(cfil+ cpref+ cnum+ cpar+ ctipo+ ccli+ cloj))
aArea := SE1->(Getarea())
If !((ctab)->(EoF()))
	
	nValLiqI7 := fi7fi7fi7(cfil, cpref, cnum, cpar, ctipo, ccli, cloj)
	while !((ctab)->(EoF())) 
		nCountT++
		If (cTab)->(TEMFK) == "LOOP"
			(ctab)->(dbskip())
			Loop
		endIf 
		SE1->(Msseek((cTab)->(BUZ_FILDES)+ (cTab)->(BUZ_PRFDES)+ (cTab)->(BUZ_NUMDES)+(ctab)->(PARCELA)+(cTab)->(BUZ_TIPDES)+ (cTab)->(BUZ_CLIDES)+ (cTab)->(BUZ_LOJDES)))
		nValorNeg := SE1->E1_VALOR
		nAux := 0
		aDtDisp := {}
		If (cTab)->(TEMFK) == "TUDO"

			If lZero
				nAux := 0 //já tratado em outra regra
				(ctab)->(dbskip())
				Loop
			else
				If (ctab)->(K1REC) > 0 .AND.  ascan(aRecnoFK1, (ctab)->(K1REC)) == 0
					aadd(aRecnoFK1, (ctab)->(K1REC))
					FK1->(dbgoTo((ctab)->(K1REC)))		
											
					nAUx := (ctab)->(K1VAL) + SumFK6DC() //* nValI7 / SE1->E1_VALLIQ

					if lBaixaDisp
						aDtDisp := { .T., FK1->FK1_DTDISP, nAux }
					Else
						aDtDisp := { .T., FK1->FK1_DATA, nAux }
					EndIf
					
				else
					nAux := 0
				endIf
			endIf
		else
			nBaixa	:= 0
			if !(EmpTy((cTab)->(IDDOC)))
				nBaixa := plRetXX(cDatax, (cTab)->(IDDOC),.T.)
			endIf

			lUltimo := .F.

			If nCountT >= nTotPar 
				aAuxYTW := parparpar(npilha,(ctab)->(BUZ_FILDES), (ctab)->(BUZ_PRFDES), (ctab)->(BUZ_NUMDES), (cTab)->(PARCELA), (ctab)->(BUZ_TIPDES), (ctab)->(BUZ_CLIDES), (ctab)->(BUZ_LOJDES), (cTabFi7)->(FI7_VALOR),nPerBM1E1, dDatDe, dDatAte, nBaixa, @lfim)	
			ElseIf (cTab)->(TEMFK) == "NTUD"
				(ctab)->(dbskip())
				(cTabFi7)->(dbskip())
				Loop	
			Endif

		endIf
		//Restarea(aarea)
		If nAux > 0
			
			If empty(aRet)
				aadd(aRet, { 0, aDtDisp[2]})
				nPosData := 1
			else
				nPosData := ascan(aRet , {|x| x[2] == aDtDisp[2]} )
			
				If nPosData == 0
					aadd(aRet, { 0, aDtDisp[2]})
					nPosData := Len(aRet)
				endIf
			endIF
			aRet[nPosData][1] += aDtDisp[3]  *  (SE1->E1_VALOR - nValK1NES )/ nValLiqI7 * (cTabFi7)->(FI7_VALOR) / nValorNeg
		else
			for nI := 1 To Len(aAuxYTW)
			
				If empty(aRet)
					aadd(aRet, { 0, aAuxYTW[nI][2]})
					nPosData := 1
				else
					nPosData := ascan(aRet , {|x| x[2] == aAuxYTW[nI][2]} )
				
					If nPosData == 0
						aadd(aRet, { 0, aAuxYTW[nI][2]})
						nPosData := Len(aRet)
					endIf
				endIF
			
				aRet[nPosData][1] += aAuxYTW[nI][1]  *  (SE1->E1_VALOR - nValK1NES )/ nValLiqI7 * (cTabFi7)->(FI7_VALOR) / nValorNeg
			next
		endIf
		nCountV++
		(ctab)->(dbskip())
		(cTabFi7)->(dbskip())
	endDo
	//nRet := nRet / ncountV // ncountT
	aRecnoFK1 := {}
endIf

If lZero
	Restarea(aarea)
	nRet := nRet * nValI7 / SE1->E1_VALOR
	for nPosData := 1 To Len(aret)
		aRet[nPosData][1] := aRet[nPosData][1] * nValI7 / SE1->E1_VALOR //aDtDisp[3]  *  (SE1->E1_VALOR - nValK1NES )/ nValLiqI7 * (ctab)->(FI7_VALOR) / nValorNeg
	next
endIf
(ctab)->(dbcloseArea())
(cTabFi7)->(dbcloseArea())

return aRet


static function fi7fi7fi7(cfil, cpref, cnum, cpar, ctipo, ccli, cloj)

	Local cFi7 := ""
	Local nRet := 0

	cFi7 := QueryFi7(cfil, cpref, cnum, cpar, ctipo, ccli, cloj)

	If !( (cFi7)->(EoF()) )
		nRet := (cFi7)->TOTFI7
	EndIf

	(cFi7)->(DbcloseArea())

return nRet

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

Static function SumFK6DC()

	Local nRet := 0
	Local cFK6DC := ""

	cFK6DC := QueryFK6DC()

	nRet := (cFK6DC)->TOTDES

	(cFK6DC)->(dbCloseArea())

return nRet

/*/{Protheus.doc} QueryPar
	FWPreparedStatement
	@author Cesar Almeida
	@since 22/07/2022
	@version P12
/*/
Static Function QueryPar(lBaixaDisp,cDatax, dDatAte,cfil, cpref, cnum,cpar, ctipo, ccli, cloj)

	local oFwQuery := FWPreparedStatement():New()
	local cSql := ""

	cSql := " SELECT "
	cSql += " CASE WHEN FK1.FK1_IDDOC IS NOT NULL "
	If lBaixaDisp
		cSql += "  AND FK1.FK1_DTDISP >= ? AND FK1.FK1_DTDISP <= ? "
	Else
		cSql += "  AND FK1.FK1_DATA >= ? AND FK1.FK1_DATA <= ? "
	Endif
	cSql += " AND FK1_MOTBX NOT IN( 'LIQ','NEG' ) THEN 'TUDO' "
	cSql += " WHEN FK1.FK1_IDDOC IS NOT NULL AND FK1_MOTBX IN( 'LIQ','NEG' )THEN 'NTUD' ELSE 'LOOP' "
	cSql += " END TEMFK, "
    cSql += "     BUZ_FILDES, "
    cSql += "     BUZ_PRFDES, "
    cSql += "     BUZ_NUMDES, "
    cSql += "     BUZ_TIPDES, "
    cSql += "     BUZ_CLIDES, "
    cSql += "     BUZ_LOJDES, "
    cSql += "     COALESCE(FK1.FK1_IDDOC, ' ') IDDOC, "
    cSql += "     COALESCE(FK1.FK1_VALOR, 0)   K1VAL, "
    cSql += "     COALESCE(FK1.R_E_C_N_O_, 0)  K1REC, "
	cSql += "     FK7.FK7_PARCEL AS PARCELA "
	cSql += " FROM "+ RetSqlName("BUZ") + " BUZ "
	cSql += " INNER JOIN " + RetSqlName("SE1") + " SE1_NEG ON "
	cSql += " 			SE1_NEG.E1_FILIAL  = BUZ.BUZ_FILDES "
	cSql += " 	AND     SE1_NEG.E1_PREFIXO = BUZ.BUZ_PRFDES "
	cSql += " 	AND     SE1_NEG.E1_NUM     = BUZ.BUZ_NUMDES "
	cSql += " 	AND     SE1_NEG.E1_CLIENTE = BUZ.BUZ_CLIDES "
	cSql += " 	AND     SE1_NEG.E1_LOJA    = BUZ.BUZ_LOJDES "
	cSql += " 	AND     SE1_NEG.D_E_L_E_T_ = ' ' "
	cSql += " INNER JOIN " + RetSqlName("FK7") + " FK7  ON "
	cSql += " 			FK7_FILIAL     = ? "
	cSql += " 	AND     FK7_ALIAS      = 'SE1' "
	If(SubStr(Alltrim(Upper(TCGetDb())),1,6)) == "ORACLE"
		cSql += " AND FK7_CHAVE = SE1_NEG.E1_FILIAL||'|'||SE1_NEG.E1_PREFIXO||'|'||SE1_NEG.E1_NUM||'|'||SE1_NEG.E1_PARCELA||'|'||SE1_NEG.E1_TIPO||'|'||SE1_NEG.E1_CLIENTE||'|'||SE1_NEG.E1_LOJA" + " "
	else
		cSql += " AND FK7_CHAVE = SE1_NEG.E1_FILIAL+'|'+SE1_NEG.E1_PREFIXO+'|'+SE1_NEG.E1_NUM+'|'+SE1_NEG.E1_PARCELA+'|'+SE1_NEG.E1_TIPO+'|'+SE1_NEG.E1_CLIENTE+'|'+SE1_NEG.E1_LOJA" + " "
	Endif
	cSql += " 	AND     FK7.D_E_L_E_T_ = ? "
	cSql += " LEFT JOIN " + RetSqlName("FK1") + " FK1 ON "	
	cSql += " 			FK1_FILIAL     = ? "
	cSql += " 	AND     FK1_IDDOC      = FK7.FK7_IDDOC "
	cSql += " 	AND     FK1.D_E_L_E_T_ = ? "
	cSql += " WHERE
	cSql += " 			BUZ_FILIAL     = ? "
	cSql += " 	AND     BUZ_PRFORI     = ? "
	cSql += " 	AND     BUZ_NUMORI     = ? "
	cSql += " 	AND     BUZ_TIPORI     = ? "
	cSql += " 	AND     BUZ_CLIORI     = ? "
	cSql += " 	AND     BUZ_LOJORI     = ? "
	cSql += " 	AND     BUZ.D_E_L_E_T_ = ? "

	oFwQuery:SetQuery(cSql)
	oFwQuery:SetString(1,cDatax)
	oFwQuery:SetString(2,DTOS(dDatAte))
	oFwQuery:SetString(3, xFilial("FK7"))
	oFwQuery:SetString(4, ' ')
	oFwQuery:SetString(5, xFilial("FK1"))
	oFwQuery:SetString(6, ' ')
	oFwQuery:SetString(7, cfil)
	oFwQuery:SetString(8, cpref)
	oFwQuery:SetString(9, cnum)
	oFwQuery:SetString(10, ctipo)
	oFwQuery:SetString(11, ccli)
	oFwQuery:SetString(12, cloj)
	oFwQuery:SetString(13, ' ')

	cSql := oFwQuery:GetFixQuery()

Return cSql

/*/{Protheus.doc} QueryFi7
	FWPreparedStatement
	@author Cesar Almeida
	@since 22/07/2022
	@version P12
/*/
Static Function QueryFi7(cfil, cpref, cnum, cpar, ctipo, ccli, cloj)

	local oFwQuery := FWPreparedStatement():New()
	local cSql := ""
	local cAlias := ""

	cSql := " SELECT SUM(FI7_VALOR) TOTFI7 "
	cSql += " FROM " + RetsqlName("FI7") + " FI7 "
	csql += " WHERE FI7_FILIAL = ? AND FI7_PRFORI = ? AND FI7_NUMORI = ? AND FI7_PARORI = ?  AND FI7_TIPORI = ? AND FI7_CLIORI = ?  AND FI7_LOJORI = ? AND FI7.D_E_L_E_T_ = ? "
	
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

/*/{Protheus.doc} QueryFK6DC
	FWPreparedStatement
	@author Cesar Almeida
	@since 22/07/2022
	@version P12
/*/
Static Function QueryFK6DC()
	
	Local oFwQuery := FWPreparedStatement():New()
	Local cSql := ""
	Local cAlias := ""

	cSql := " SELECT SUM( CASE WHEN FK6_TPDOC = 'DC' THEN FK6_VALMOV ELSE 0 END ) TOTDES "
	cSql += " FROM " + RetSqlName("FK6") + " FK6 "
	cSql += " WHERE FK6_FILIAL = ?  AND FK6.FK6_TABORI = 'FK1' AND FK6.FK6_IDORIG = ? AND FK6.D_E_L_E_T_ = ? "

	oFwQuery:SetQuery(cSql)
	oFwQuery:SetString(1, xFilial("FK1"))
	oFwQuery:SetString(2, FK1->FK1_IDFK1)
	oFwQuery:SetString(3, ' ')

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
		csql += " select SUM( Case  when FK1_TPDOC = 'ES' then FK1_VALOR else 0 END ) TOT_ES, SUM( Case  when FK1_TPDOC NOT IN ('ES') AND FK1_MOTBX NOT IN ('LIQ', 'NEG') then FK1_VALOR else 0 END ) TOT_NES from "
	else
		csql += " select SUM( Case  when FK1_TPDOC = 'ES' then FK1_VALOR else 0 END ) TOT_ES, SUM( Case  when FK1_TPDOC <> 'ES' then FK1_VALOR else 0 END ) TOT_NES from "
	endif

	cSql +=  + retSqlName("FK1") + " FK1_BX WHERE FK1_FILIAL = ? AND FK1_IDDOC = ? "
	if lDtCTB
		csql += " AND FK1_DATA < ? "
	else
		csql += " AND FK1_DTDISP < ? "
	endIf
	cSql += " AND D_E_L_E_T_ = ? "

	oFwQuery:SetQuery(cSql)
	oFwQuery:SetString(1, xFilial("FK1"))
	oFwQuery:SetString(2, cIdFK1)
	oFwQuery:SetString(3, cData)
	oFwQuery:SetString(4, ' ')

	cSql := oFwQuery:GetFixQuery()
	cAlias := MpSysOpenQuery(cSql)
	
Return cAlias


/*/{Protheus.doc} ChkFI7
	Verifca campo FI7_VALOR.
	@author Cesar Almeida
	@since 11/08/2022
	@version P12
/*/
Static Function ChkFI7(cfil, cpref, cnum, ctipo, ccli, cloj)

	Local oFwQuery := FWPreparedStatement():New()
	Local cSql := ""

	cSql := " SELECT " 
	cSql += " 	FI7_NUMDES, FI7_PARDES,FI7_VALOR " 
	cSql += " FROM  " 
	cSql += 	+ retSqlName("FI7") + " FI7 "
	cSql += " WHERE  " 
	cSql += " 	FI7.FI7_FILIAL    = ? " 
	cSql += " AND FI7.FI7_PRFORI  = ? " 
	cSql += " AND FI7.FI7_NUMORI  = ? " 
	cSql += " AND FI7.FI7_TIPORI  = ? " 
	cSql += " AND FI7.FI7_CLIORI  = ? " 
	cSql += " AND FI7.FI7_LOJORI  = ? " 
	cSql += " AND FI7.D_E_L_E_T_  = ? " 
	cSql += " GROUP BY FI7_NUMDES, FI7_PARDES,FI7_VALOR " 

	oFwQuery:SetQuery(cSql)
	oFwQuery:SetString(1, cfil)
	oFwQuery:SetString(2, cpref)
	oFwQuery:SetString(3, cnum)
	oFwQuery:SetString(4, ctipo)
	oFwQuery:SetString(5, ccli)
	oFwQuery:SetString(6, cloj)
	oFwQuery:SetString(7, ' ')

	cSql := oFwQuery:GetFixQuery()
		
Return cSql
