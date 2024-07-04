#INCLUDE "PLSR461.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
STATIC ADLei := CtoD('31/12/1999')

/*/{Protheus.doc} PLSR461
Registro de Receitas Emitidas

@author DEV
@since 29/11/2016
@version ALL
Remodelado para atendimento a RN 390 - RC
/*/
Function PLSR461()
local oReport := nil
local cPerg	  := "PLR461"

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
local aTpForn       := retSx3Box(X3CBox(Posicione('SX3' , 2 ,"BI3_TPFORN",'X3_CBOX')    ),,,1)
local aModPag       := retSx3Box(X3CBox(Posicione('SX3' , 2 ,"BI3_MODPAG",'X3_CBOX')    ),,,1)
Local cTexto		:= STR0002+' '+STR0042

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
oReport := TReport():new("PLSR461",cTexto,nil,{|oReport| ReportPrint(oReport,oBGERAL,dDatDe,dDatAte,aTpForn,aModPag,cTexto)},cTexto) //"Registro de Contraprestações Emitidas"
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
TRCell():new(oSTITULO,"VALOR"		,"TRBLIV", STR0022, "@E 9,999,999,999.99", 14)//"Valor"
TRCell():new(oSTITULO,"TIPCOB"		,"TRBLIV", STR0023, "@!", 15)//"Tipo Mensal."       
TRcell():new(oSTITULO,"MESLCT"		,"TRBLIV", STR0024,	"@!", 07)//"Mês Lct"
TRcell():new(oSTITULO,"CODTIP"		,"TRBLIV", STR0050,	"@!", 08)//"Cod.Fat"
TRcell():new(oSTITULO,"PLNUCO"		,"TRBLIV", STR0051,	"@!", 12)//"Lt.Cobr."

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
local oTempTable	:= nil
local dIniCon		:= stod("")
local dTerCon		:= stod("")
local dRegAns 		:= stod("")
local dDatCan       := stod("")
local aLog 	   		:= {}
local aStru			:= {}
local aFicha		:= {}
local aTmp			:= {}
local oSGERAL		:= IIf(MV_PAR06==1, oReport:section(1), oReport:section(3))
local oSMESANO 		:= IIf(MV_PAR06==1, oReport:section(2), oReport:section(4))
local oSSEGMPADL	:= IIf(MV_PAR06==1, oReport:section(3), oReport:section(5))
local oSTPCONTRATO	:= IIf(MV_PAR06==1, oReport:section(4), oReport:section(6))
local oSTITULO		:= IIf(MV_PAR06==1, oReport:section(5), oReport:section(1)) 
local oOCORRENCIAS	:= IIf(MV_PAR06==1, oReport:section(6), oReport:section(2))
Local cPlsCDIE		:= getNewPar("MV_PLSCDIE","1")
Default cTexto		:= STR0001
private cNroLvr     := "0001"
private cDesc1      := STR0002
private cSigaadv    := Upper(AllTrim(GetPvProfString( GetEnvServer(), "StartPath", "", GetADV97() )))
private nPagina     := 0

if ! getTrbQuery(@lLivro,@lLog,dDatDe,dDatAte, @oTempTable)
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
oReport:SetMeter(TRBLIV->(LastRec()))	
dbSelectArea('TRBLIV')
TRBLIV->(dbGoTop())
If !TRBLIV->(EoF())

	If MV_PAR06 == 1
		//inicia sessao
		oSGERAL:init()	
	EndIf

	while !oReport:cancel() .and. !TRBLIV->(eof())
		
		oReport:incMeter()

		if oReport:Cancel()
			Exit
		endIf

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
		If nPos > 0 
			cModPag := allTrim(aModPag[nPos,3])
		Else
			cModPag := ""
		EndIf	 
	
		//data aprovacao do produto pela ans
		cADLei := IIf( TRBLIV->BI3_DTAPPR <= ADLei, 'Antes da lei','Depois da lei' )
		If MV_PAR06 == 1		
			If !empty(cTipCon) .and. cTipCon <> TRBLIV->BI3_TIPCON
				//reiniciar quebra tipo de contrato
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
		oSTITULO:cell("VALOR"):setValue(TRBLIV->BM1_VALOR)
		oSTITULO:cell("TIPCOB"):setValue(IIf(TRBLIV->TIPCOB=='1','Participante','Patronal'))
		oSTITULO:cell("MESLCT"):setValue(cMesLct)
		oSTITULO:cell("CODTIP"):setValue(TRBLIV->BM1_CODTIP)
		oSTITULO:cell("PLNUCO"):setValue(TRBLIV->BM1_PLNUCO)
		oSTITULO:printLine()
		oSTITULO:finish()
		TRBLIV->(dbSkip())		
		nSeq ++
		
	EndDo

	If MV_PAR06 == 1	
		oSTPCONTRATO:finish()
		oSSEGMPADL:finish()
		oSMESANO:finish()
		oSGERAL:finish()	
	EndIf

	If  lLog .and. len(aLog) > 0
		ocorrencias(oOcorrencias,aLog)
	Else
		oOcorrencias:hide()
	EndIf

	//oReport:finish()
	oReport:endPage()	
	
EndIf
TRBLIV->(dbCloseArea())

//---------------------------------
//Exclui a tabela temporária 
//---------------------------------
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
Local aFields := {}
Local nI		:= 0
Local cAlias 	:= "TRBLIV"
Local cQuery
Local aPtoQuery:= {}
Local aPtoTpDoc:= {}
Local nPos	:= 0
Local aTipRel	:= { "O", "C", "B", "D", "M" }		// Tipo de Relatório: Operadora, Coparticipação, Beneficiário Outra Operadora, Não Rel.Plano Serv.Odontológico e Não Rel.Plano Med.Hospitalar
Local cWhere	:= '' 
Local aSetField := {}
Local lMsSql	:= Upper(TcGetDb()) $ "MSSQL"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa ponto de entrada para filtragem de Tipos de Cobrança...         |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Existblock("PLR46XP1")
	aPtoQuery := ExecBlock("PLR46XP1",.f.,.f.,{ '461'+aTipRel[MV_PAR07] })
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa ponto de entrada para Descrição de Tipos de Documento...         |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Existblock("PLR46XP2")
	aPtoTpDoc := ExecBlock("PLR46XP2",.f.,.f.,{ '461'+aTipRel[MV_PAR07] })
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa ponto de entrada para Complemento de Filtro no BM1...         |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Existblock("PLR46XP3")
	cWhere := ExecBlock("PLR46XP3",.f.,.f.,{ '461'+aTipRel[MV_PAR07] })
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

lRet := .t.

//--------------------------
//Monta os campos da tabela
//--------------------------
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
aadd(aFields,{"BM1_VALOR","N",16,2})
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
aadd(aFields,{"E1_EMISSAO","D",08,0})
aadd(aFields,{"VENCTO","D",08,0})
aadd(aFields,{"DESCDOC","C",55,0})
aadd(aFields,{"TIPCOB","C",01,0})
aadd(aFields,{"MESLCT","C",06,0})

//-------------------
//Criação do objeto
//-------------------
oTempTable := FWTemporaryTable():New( cAlias, aFields )
oTempTable:AddIndex("indice1", {"BM1_ANO","BM1_MES","BI3_CODSEG","BI3_MODPAG","BI3_DTAPPR","BI3_TIPCON",;
"BM1_CODINT","BM1_CODEMP","BM1_MATRIC","BM1_TIPREG","BM1_CODTIP","BM1_CODEVE","E1_EMISSAO","NUMERO" } )
//------------------
//Criação da tabela
//------------------
oTempTable:Create()

// Query principal na Composição dos Itens da Guia
cQuery	:= "SELECT BM1_CODINT,BM1_CODEMP,BM1_CONEMP,BM1_VERCON,BM1_SUBCON,BM1_VERSUB,"
cQuery	+= "BM1_MATRIC,BM1_TIPREG,BM1_DIGITO,BM1_MES,BM1_ANO,BM1_VALOR,"
cQuery	+= "BM1_TIPO,BM1_TIPTIT,BM1_PREFIX AS PREFIXO, BM1_NUMTIT AS NUMERO, BM1_PARCEL AS PARCELA,BM1_CODTIP,BM1_CODEVE,"
cQuery	+= "BM1_ALIAS, BM1_ORIGEM, BM1_PLNUCO,"
cQuery	+= "BI3.BI3_DTAPPR,BI3.BI3_CODSEG,BI3.BI3_MODPAG,BI3.BI3_TIPCON,"
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
cQuery	+= "SE1.E1_EMISSAO, SE1.E1_VENCREA AS VENCTO, SE1.E1_TIPO AS TIPDOC, SX5.X5_DESCRI AS DESCDOC, ' ' AS TIPCOB, '      ' AS MESLCT "
cQuery	+= "FROM "+RetSqlName("BM1")+" BM1 "
// Família
cQuery	+= "INNER JOIN "+RetSqlName("BA3")+" BA3 "
cQuery	+= "ON BA3_FILIAL='"+xFilial('BA3')+"' "
cQuery	+= "AND BA3_CODINT=BM1.BM1_CODINT "
cQuery	+= "AND BA3_CODEMP=BM1.BM1_CODEMP "
cQuery	+= "AND BA3_MATRIC=BM1.BM1_MATRIC "
cQuery	+= "AND BA3.D_E_L_E_T_ = ' ' "
// Usuário
cQuery	+= "INNER JOIN "+RetSqlName("BA1")+" BA1 "
cQuery	+= "ON BA1_FILIAL='"+xFilial('BA1')+"' "
cQuery	+= "AND BA1_CODINT=BM1.BM1_CODINT "
cQuery	+= "AND BA1_CODEMP=BM1.BM1_CODEMP "
cQuery	+= "AND BA1_MATRIC=BM1.BM1_MATRIC "
cQuery	+= "AND BA1_TIPREG=BM1.BM1_TIPREG "
cQuery	+= "AND BA1.D_E_L_E_T_ = ' ' "
// Grupo Empresa
cQuery	+= "INNER JOIN "+RetSqlName("BG9")+" BG9 "
cQuery	+= "ON BG9_FILIAL='"+xFilial('BG9')+"' "
cQuery	+= "AND BG9_CODINT=BM1.BM1_CODINT "
cQuery	+= "AND BG9_CODIGO=BM1.BM1_CODEMP "
cQuery	+= "AND BG9.D_E_L_E_T_ = ' ' "

// Usuário Titular
cQuery	+= "LEFT JOIN "+RetSqlName("BA1")+" TIT "
cQuery	+= "ON TIT.BA1_FILIAL='"+xFilial("BA1")+"' "
cQuery	+= "AND TIT.BA1_CODINT=BM1.BM1_CODINT "
cQuery	+= "AND TIT.BA1_CODEMP=BM1.BM1_CODEMP "
cQuery	+= "AND TIT.BA1_MATRIC=BM1.BM1_MATRIC "
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

// Titulo a Receber
cQuery	+= "INNER JOIN "+RetSqlName("SE1")+" SE1 "
cQuery	+= "ON SE1.E1_FILIAL   = '"+xFilial("SE1")+"' "
cQuery	+= "AND SE1.E1_PREFIXO = BM1.BM1_PREFIX "
cQuery	+= "AND SE1.E1_NUM	   = BM1.BM1_NUMTIT "
cQuery	+= "AND SE1.E1_PARCELA = BM1.BM1_PARCEL "
cQuery	+= "AND SE1.E1_TIPO    = BM1.BM1_TIPTIT "
cQuery	+= "AND SE1.D_E_L_E_T_ = ' ' "
// Tabela Tipos de Títulos
cQuery	+= "INNER JOIN "+RetSqlName("SX5")+" SX5 "
cQuery	+= " ON SX5.X5_FILIAL = '"+xFilial('SX5')+"' "
cQuery	+= "AND SX5.X5_TABELA = '05' "
cQuery	+= "AND SX5.X5_CHAVE  = SE1.E1_TIPO "
cQuery	+= "AND SX5.D_E_L_E_T_ = ' ' "

// Contrato
cQuery	+= "LEFT JOIN "+RetSqlName("BT5")+" BT5 "
cQuery	+= "ON BT5_FILIAL='"+xFilial('BT5')+"' "
cQuery	+= "AND BT5_CODINT=BM1.BM1_CODINT "
cQuery	+= "AND BT5_CODIGO=BM1.BM1_CODEMP "
cQuery	+= "AND BT5_NUMCON=BM1.BM1_CONEMP "
cQuery	+= "AND BT5_VERSAO=BM1.BM1_VERCON "
cQuery	+= "AND BT5.D_E_L_E_T_ = ' ' "
// Versões dos Contratos
cQuery	+= "LEFT JOIN "+RetSqlName("BQB")+" BQB "
cQuery	+= "ON BQB_FILIAL='"+xFilial('BQB')+"' "
cQuery	+= "AND BQB_CODINT=BM1.BM1_CODINT "
cQuery	+= "AND BQB_CDEMP=BM1.BM1_CODEMP "
cQuery	+= "AND BQB_NUMCON=BM1.BM1_CONEMP "
cQuery	+= "AND BQB_VERSAO=BM1.BM1_VERCON "
cQuery	+= "AND BQB.D_E_L_E_T_ = ' ' "
// SubContratos
cQuery	+= "LEFT JOIN "+RetSqlName("BQC")+" BQC "
cQuery	+= "ON BQC_FILIAL='"+xFilial('BQB')+"' "
cQuery	+= "AND BQC_CODINT=BM1.BM1_CODINT "
cQuery	+= "AND BQC_CODEMP=BM1.BM1_CODEMP "
cQuery	+= "AND BQC_NUMCON=BM1.BM1_CONEMP "
cQuery	+= "AND BQC_VERCON=BM1.BM1_VERCON "
cQuery	+= "AND BQC_SUBCON=BM1.BM1_SUBCON "
cQuery	+= "AND BQC_VERSUB=BM1.BM1_VERSUB "
cQuery	+= "AND BQC.D_E_L_E_T_ = ' ' "
//1
cQuery	+= "WHERE BM1_FILIAL = '"+xFilial("BM1")+"' "
cQuery	+= "AND BM1_CODINT = '"+MV_PAR03+"' "
cQuery	+= "AND BM1_CODEMP >= '"+MV_PAR04+"' "
cQuery	+= "AND BM1_CODEMP <= '"+MV_PAR05+"' "
//cQuery	+= "AND BM1_MES = '"+MV_PAR01+"' "
//cQuery	+= "AND BM1_ANO = '"+MV_PAR02+"' "
cQuery += " AND E1_EMISSAO BETWEEN '" + DtoS(dDatDe) + "' AND '" + DtoS(dDatAte) + "' "
// Filtra Lançamentos conforme retorno do ponto de entrada
If Len(aPtoQuery) > 0
	For nPos := 1 to Len(aPtoQuery)
		cQuery += IIf( nPos==1, "AND BM1_CODTIP IN('"+aPtoQuery[nPos,1], "'"+aPtoQuery[nPos,1] )
		cQuery += IIf( Len(aPtoQuery)>1, IIf(Len(aPtoQuery)==nPos,  "') ", "',"), "') ")
	Next

Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se Benef.Operadoras, filtra tipo de movimentação coparticipação          |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If MV_PAR07 == 1
		cQuery	+= "AND BM1_CODTIP IN ('101','102','103','107','108','109','110','111','113','117','118','128','129','130','131','132','133','135','136','146','180','184','186','188','189','190','191') "
		cQuery	+= "AND BT5_INTERC <> '1' "
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se Coparticipação, filtra tipos de movimentacao                          |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf MV_PAR07 == 2
		cQuery	+= "AND BM1_CODTIP IN ('104','116','120','121','122','123','124','125','127','134','137','138','139','140','141','142','143','144','145','147','148','149','150','151','152','153','154','155','156','157','158','159','160','161','162','163','164','165','166','167','168','169','170','171','172','173','174','175','176','177','181','185') "
		cQuery	+= "AND BT5_INTERC <> '1' "
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se Benef.Outras Operadoras, trata somente contratos de Intercambio.      |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf MV_PAR07 == 3
		cQuery	+= "AND BT5_INTERC = '1' "
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se Rel.Plan.Odonto, filtra tipo de movimentação odontologico             |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf MV_PAR07 == 4 
		cQuery	+= "AND BM1_CODTIP IN ('131','132') "
		cQuery	+= "AND BT5_INTERC <> '1' "
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se Rel.Pl.Med.Hosp, exclui tipo de movimentação odontologico             |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf MV_PAR07 == 5 
		cQuery	+= "AND BM1_CODTIP NOT IN ('131','132') "
		cQuery	+= "AND BT5_INTERC <> '1' "
	EndIf

EndIf

cQuery	+= cWhere		// Adição do conteúdo do ponto de entrada, caso exista.
cQuery	+= "AND BM1.D_E_L_E_T_ = ' ' "
cQuery	+= "ORDER BY BM1_ANO,BM1_MES,BI3_CODSEG,BI3_MODPAG,BI3_DTAPPR,BI3_TIPCON,E1_EMISSAO,"
cQuery	+= "BM1_CODINT,BM1_CODEMP,BM1_CONEMP,BM1_VERCON,BM1_SUBCON,BM1_VERSUB,BM1_MATRIC,BM1_TIPREG "

cQuery	:= ChangeQuery(cQuery)

//nHandle := fCreate('c:\temp\QRY461.qry',0)
//if nHandle > 0 
//	fWrite(nHandle, cQuery)
//	fClose(nHandle)
//endif

//------------------
//Criação da tabela
//------------------
aAdd(aSetField,{"BM1_VALOR","N",16,2})
aAdd(aSetField,{"BI3_DTAPPR","D",08,0})
aAdd(aSetField,{"VENCTO","D",08,0})
MPSysOpenQuery( cQuery, 'QRYTMP', aSetField )

dbSelectArea("QRYTMP")
dbGoTop()

dbSelectArea('TRBLIV')
Append From 'QRYTMP'
dbGoTop()
While !TRBLIV->(EOF())
	RecLock('TRBLIV',.F.)
	// Se for crédito, deve aparecer subtraindo
	If TRBLIV->BM1_TIPO == '2'		
		TRBLIV->BM1_VALOR := TRBLIV->BM1_VALOR * -1
	EndIf 		  
	// Se ponto de entrada para classificar cobrança retornou algo
	If Len(aPtoQuery) > 0 .and. ( nPos := ascan(aPtoQuery,{|x| x[1]+x[2] == TRBLIV->(BM1_CODTIP+BM1_CODEVE) }) ) > 0
		TRBLIV->TIPCOB	:= aPtoQuery[nPos,3]
	ElseIf Len(aPtoQuery) > 0 .and. ( nPos := ascan(aPtoQuery,{|x| x[1] == TRBLIV->BM1_CODTIP }) ) > 0
		TRBLIV->TIPCOB	:= aPtoQuery[nPos,3]
	EndIf
	// Se ponto de entrada para alteração de descrição retornou algo
	If Len(aPtoTpDoc) > 0 .and. ( nPos := ascan(aPtoTpDoc,{|x| x[1] == AllTrim(TRBLIV->BM1_TIPTIT)}) ) > 0
		TRBLIV->DESCDOC	:= aPtoTpDoc[nPos,2]
	EndIf
	TRBLIV->(msUnlock())
	TRBLIV->(dbSkip())
EndDo

// Limpa os arrays
aSize(aPtoQuery,1)
aDel(aPtoQuery,1)
aSize(aPtoTpDoc,1)
aDel(aPtoTpDoc,1)

// Fecha o temporario
QRYTMP->(dbCloseArea())

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
While ! TRB->(eof())
	oOcorrencias:cell("DESCR"):setValue(TRB->DESCR)
	oOcorrencias:printLine()
	TRB->(dbSkip())
EndDo

if( select( "TRB" ) > 0 )
	oTempTable:Delete()
endIf

oOcorrencias:finish()

Return()


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
			if BG3->(dbSeek(xFilial("BG3")+BCAQRY->BCA_MOTBLO))
				if ! empty(BG3->BG3_BLQANS)
					lBlqAns := .T.
				endIf
			endIf
		case BCAQRY->BCA_NIVBLQ == 'F' //Nivel de Familia
			if BG1->(dbSeek(xFilial("BG1")+BCAQRY->BCA_MOTBLO))
				if ! empty(BG1->BG1_BLQANS)
					lBlqAns := .T.
				endIf
			endIf
		case BCAQRY->BCA_NIVBLQ == 'S' //Nivel de Sub-Contrato
			if BQU->(dbSeek(xFilial("BQU")+BCAQRY->BCA_MOTBLO))
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
