#Include "Protheus.ch"
#Include "TopConn.ch"
Static oTmpTable := Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGERXMLREOCบAutor  ณRenato Nagib        บ Data ณ  26/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera xml das retencoes de IR por outros conceitos           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                  Equador                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณLuisEnrํquezณ13/01/17ณSERINN001-952ณ-Se realiza merge para agregar cam-ณฑฑ
ฑฑณ            ณ        ณ             ณ bio en creaci๓n de tablas tempora-ณฑฑ
ฑฑณ            ณ        ณ             ณ les CTREE.                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GerXmlReoc(dDataIni,dDataFim)
	
	Local cQry
    Local aStruct:={}
	Local cAutRet
	Local cEstabRet
	Local cPtoEmiRet
	Local cSecRet   
	Local cDataEmiRet
	Local nItens:= 1		
	Local cLivroIva:=GETLIVRO('IVA')
	Local cLivroIR:=GETLIVRO('IR')		
	Local aTipoComp:={}
	Local cNumAut:=''
	Local aOrdem := {}
	//DEFINICAO DOS TIPOS DE COMPROVANTE DE ACORDO COM O VALIDADOR DIMM
	Aadd(aTipoComp,{'1','NF'})
	Aadd(aTipoComp,{'4','NC'})
	Aadd(aTipoComp,{'5','ND'})

	Aadd(aStruct,{"NFISCAL"  ,"C",20,0}) //NOTA FISCAL                                   (F3_NFISCAL)
	Aadd(aStruct,{"DETCOMP"   ,"C",40,0}) //TAG                                            (<DETALLECOMPRAS>)
   	Aadd(aStruct,{"TPIDPROV"  ,"C",40,0}) //TIPO DE IDENTIFICACAO DO FORNECEDOR            (A2_TIPDOC)
	Aadd(aStruct,{"IDPROV"    ,"C",40,0}) //NUMERO DE IDENTIFICACAO DO FORNECEDOR          (A2_CGC)
	Aadd(aStruct,{"TIPOCOMP"  ,"C",40,0}) //CODIGO TIPO DE NOTA                            (F3_ESPECIE)
	Aadd(aStruct,{"AUT"       ,"C",40,0}) //COMPROVANTE DE VENDA AUTORIZACAO               (FP_NUMAUT)
	Aadd(aStruct,{"ESTAB"     ,"C",40,0}) //CAMPROVANTE DE VENDA -  SERIE ESTABELECIMNENTO (F3_NFISCAL)
	Aadd(aStruct,{"PTOEMI"    ,"C",40,0}) //CAMPROVANTE DE VENDA -  SERIE -PONTO DE VENDA  (F3_NFISCAL)
	Aadd(aStruct,{"SEC"       ,"C",40,0}) //CAMPROVANTE DE VENDA -  SEQUENCIAL             (F3_NFISCAL)
	Aadd(aStruct,{"DATAEMICOM","C",40,0}) //DATA DE EMISSAO DO COMPROVANTE DE VENDA        (F3_ENTRADA)
	
	Aadd(aStruct,{"AIR"       ,"C",40,0}) //DATA DE EMISSAO DO COMPROVANTE DE VENDA        (<AIR>)
	Aadd(aStruct,{"DETAIR"    ,"C",40,0}) //DATA DE EMISSAO DO COMPROVANTE DE VENDA        (<DETALLEAIR>)
	Aadd(aStruct,{"CODRETAIR" ,"C",40,0}) //CODIGO CONCEPTO DE RETENCAO                    (FE_CONCEPT)
	Aadd(aStruct,{"PORCENTAJE","C",40,0}) //ALIQUOTA CONCEPTO DE RETENCAO                  (FE_ALIQ)
	Aadd(aStruct,{"BASE0"     ,"C",40,0}) //BASE COM ALIQUOTA =O                           (BASIMP->IVA)
	Aadd(aStruct,{"BASEGRAV"  ,"C",40,0}) //BASE NAO IVA                                   (BASE->IR)
	Aadd(aStruct,{"BASENOGRAV","C",40,0}) //BASE NAO IR                                    (BASIMP->NAO IVA)
	Aadd(aStruct,{"VALRETAIR" ,"C",40,0}) //VALOR RETIDO DO IR                             (FE_RETENC)
	Aadd(aStruct,{"_DETAIR"   ,"C",40,0}) //DATA DE EMISSAO DO COMPROVANTE DE VENDA	    (</DETALLEAIR>)
	Aadd(aStruct,{"_AIR"      ,"C",40,0}) //TAG                                            (</AIR>)
	Aadd(aStruct,{"AUTRET"    ,"C",40,0}) //COMPROVANTE DE RETENCAO                        (FP_NUMAUT)
	Aadd(aStruct,{"ESTABRET"  ,"C",40,0}) //COMPROVANTE DE RETENCAO -SERIE ESTABELECIMENTO (FE_NROCERT)
	Aadd(aStruct,{"PTOEMIRET" ,"C",40,0}) //COMPROVANTE DE RETENCAO - SERIE PONTO DE VENDA (FE_NROCERT)
	Aadd(aStruct,{"SECRET"    ,"C",40,0}) //COMPROVANTE DE RETENCAO - SEQUENCIAL           (FE_NROCERT)
	Aadd(aStruct,{"DATAEMIRET","C",40,0}) //DATA DE EMISSAO DO COMPROVANTE DE RETENCAO     (FE-EMISSAO)
	Aadd(aStruct,{"_DETCOMP"  ,"C",40,0}) //TAG                                            (</DETALLECOMPRAS>)

	oTmpTable := FWTemporaryTable():New('TRB') 
	oTmpTable:SetFields( aStruct ) 
	aOrdem	:=	{"NFISCAL"} 
	oTmpTable:AddIndex("IN1", aOrdem) 
	oTmpTable:Create() 

	cQry:=" SELECT  F3_FILIAL FILIAL,F3_TIPO TIPO,FE_NFISCAL NFISCAL,FE_SERIE SERIE,FE_FORNECE FORNECE,FE_LOJA LOJA,FE_ESPECIE ESPECIE,FE_NROCERT NROCERT,"
	cQry+=" A2_TIPDOC TPIDPROV,"
	cQry+="SUBSTRING(A2_CGC,1,13) IDPROV,"
	cQry+="SUBSTRING(FE_ESPECIE,1,2) TIPOCOMP,"
	cQry+="SUBSTRING(FE_NFISCAL,1,3) ESTAB,"
	cQry+="SUBSTRING(FE_NFISCAL,4,3) PTOEMI,"
	cQry+="FE_NFISCAL SEC," 
	cQry+="F3_ENTRADA DATAEMICOM," 
	cQry+="SUBSTRING(FE_CONCEPT,1,3) CODRETAIR," 
	cQry+="FE_ALIQ PORCENTAJE," 
	cQry+="SUM(CASE WHEN F3_BASIMP"+cLivroIva+" > 0 AND F3_ALQIMP"+cLivroIva+" =0 THEN" 
	cQry+="	F3_BASIMP"+cLivroIva+" "  
	cQry+="	ELSE"  	
	cQry+="	0" 
	cQry+=" END) BASE0," 
	cQry+="SUM(CASE WHEN F3_ALQIMP"+cLivroIva+" > 0 THEN" 
	cQry+=" F3_BASIMP"+cLivroIva+" END) BASEGRAV,"  	
	cQry+="SUM(F3_VALCONT)-SUM(F3_BASIMP"+cLivroIva+") AS BASENOGRAV," 
	cQry+="SUM(FE_RETENC) VALRETAIR," 
	cQry+=" FE_NUMAUT AUTRET," 
	cQry+="SUBSTRING(FE_NROCERT,1,3) ESTABRET," 
	cQry+="SUBSTRING(FE_NROCERT,4,3) PTOEMIRET," 
	cQry+=" FE_NROCERT SECRET,"
	cQry+="FE_EMISSAO DATAEMIRET"
	cQry+=" FROM "+RetSqlName('SFE')+" SFE"
	cQry+=" INNER JOIN (SELECT DISTINCT F3_FILIAL,F3_ENTRADA,F3_NFISCAL,F3_ESPECIE,F3_SERIE,F3_TIPO,SUBSTRING(F3_CONCEPT,1,3) F3_CONCEPT,F3_TES,"
	cQry+="	F3_CLIEFOR,F3_LOJA,F3_VALCONT,F3_BASIMP"+cLivroIva+",F3_ALQIMP"+cLivroIva+" FROM "+RetSqlName('SF3')+" SF3"+" WHERE D_E_L_E_T_=''"
	cQry+=" AND F3_FILIAL='"+xFilial('SF3')+"' AND F3_TIPOMOV='C' AND F3_ENTRADA BETWEEN '"+dTos(MV_PAR01)+"' AND '"+dTOs(MV_PAR02)+"') SF3"
	cQry+=" ON F3_NFISCAL=FE_NFISCAL AND F3_SERIE=FE_SERIE AND F3_CLIEFOR=FE_FORNECE AND F3_LOJA=FE_LOJA AND"
	cQry+=" F3_CONCEPT=FE_CONCEPT AND FE_TES=F3_TES AND F3_ESPECIE=FE_ESPECIE"
	cQry+=" INNER JOIN "+RetSqlName('SA2')+" SA2"
	cQry+=" ON F3_CLIEFOR=A2_COD AND F3_LOJA=A2_LOJA AND SA2.D_E_L_E_T_='' AND A2_FILIAL='"+xFilial('SA2')+"'"
	cQry+=" WHERE FE_FILIAL='"+xFilial('SFE')+"'"
	cQry+=" AND FE_TIPO='R'"
	cQry+=" AND SFE.D_E_L_E_T_=''"
	cQry+=" GROUP BY FE_NFISCAL,A2_TIPDOC,A2_CGC,FE_ESPECIE,F3_ENTRADA,FE_CONCEPT,FE_ALIQ,FE_NROCERT,FE_EMISSAO,"
	cQry+=" FE_SERIE,FE_FORNECE,FE_LOJA,FE_NUMAUT,F3_FILIAL,F3_TIPO"
	cQry+=" ORDER BY FE_ESPECIE,FE_NFISCAL,FE_SERIE,FE_FORNECE,FE_LOJA"

	cQry:=ChangeQuery(cQry)
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,Alltrim(cQry)),'DET',.F.,.T.)		

	TCSetField('DET','DATAEMICOM','D')
	TCSetField('DET','DATAEMIRET','D')
	dbSelectArea('SF1')    

	dbSelectArea('SF1')    
	SF1->(dbSetOrder(1))
	dbSelectArea('SF2')    
	SF1->(dbSetOrder(1))

	While DET->(!EOF()) 

		RecLock('TRB',.T.)
		
		//DETALHES DAS NOTAS
		TRB->NFISCAL   :=DET->NFISCAL			
		TRB->DETCOMP   :="<detalleCompras>"
		TRB->TPIDPROV  :="<tpIdProv>"+Alltrim(DET->TPIDPROV)+"</tpIdProv>"	
		TRB->IDPROV    :="<idProv>"+Alltrim(DET->IDPROV)+"</idProv>"
		TRB->TIPOCOMP  :="<tipoComp>"+aTipoComp[aScan(aTipoComp,{|X| X[2]==Substr(DET->TIPOCOMP,1,2)})][1]+"</tipoComp>"
		If DET->ESPECIE $("NCI|NDI")
			cNumAut:=GetSFP(DET->FILIAL,DET->SERIE,DET->NFISCAL,DET->ESPECIE)
        Else
	        If SF1->(dbSeek(DET->FILIAL+DET->NFISCAL+DET->SERIE+DET->FORNECE+DET->LOJA+DET->TIPO))
				cNumAut:=SF1->F1_NUMAUT
			ElseIf SF2->(dbSeek(DET->FILIAL+DET->NFISCAL+DET->SERIE+DET->FORNECE+DET->LOJA+DET->TIPO))
				cNumAut:=SF2->F2_NUMAUT
			EndIf
		EndIf
		TRB->AUT:="<aut>"+cNumAut+"</aut>"			
		TRB->ESTAB     :="<estab>"+Alltrim(DET->ESTAB)+"</estab>"
		TRB->PTOEMI    :="<ptoEmi>"+Alltrim(DET->PTOEMI)+"</ptoEmi>"
		TRB->SEC       :="<sec>"+Alltrim(Iif(Len(DET->SEC)-6<=7,Subs(DET->SEC,7,Len(DET->SEC)-6),Subs(DET->SEC,Len(DET->SEC)-6,7)))+"</sec>"
		TRB->DATAEMICOM:="<fechaEmiCom>"+dTOc(DET->DATAEMICOM)+"</fechaEmiCom>"
		//ITENS
        TRB->AIR       :="<air>"
    	cChave:=DET->ESPECIE+DET->NFISCAL+DET->SERIE+DET->FORNECE+DET->LOJA
    	
    	// DADOS DOS COMPROVANTES DAS RETENCOES(ARMAZENO OS VALORES ANTES DO DBSKIP)
		If DET->ESPECIE $("NCI|NDI")
			cAutRet:=GetSFP(DET->FILIAL,DET->SERIE,DET->NROCERT,'RIR')
        Else
	        If SF1->(dbSeek(DET->FILIAL+DET->NFISCAL+DET->SERIE+DET->FORNECE+DET->LOJA+DET->TIPO))
				cAutRet:=SF1->F1_NUMAUT
			ElseIf SF2->(dbSeek(DET->FILIAL+DET->NFISCAL+DET->SERIE+DET->FORNECE+DET->LOJA+DET->TIPO))
				cAutRet:=SF2->F2_NUMAUT
			EndIf
		EndIf		
	 	cEstabRet  :=Alltrim(DET->ESTABRET)
		cPtoEmiRet :=Alltrim(DET->PTOEMIRET)
		cSecRet    :=Alltrim(Iif(Len(DET->SECRET)-6<=7,Subs(DET->SECRET,7,Len(DET->SECRET)-6),Subs(DET->SECRET,Len(DET->SECRET)-6,7)))
		cDataEmiRet:=dTOc(DET->DATAEMIRET)
		
    	//DETALHES DAS RETENCOES POR CONCEPTO
    	While DET->(!EOF()) .AND. cChave == DET->ESPECIE+DET->NFISCAL+DET->SERIE+DET->FORNECE+DET->LOJA

    		RecLock('TRB',.T.)
	    	TRB->DETAIR:="<detalleAir>
	    	TRB->CODRETAIR :="<codRetAir>"+Alltrim(DET->CODRETAIR)+"</codRetAir>"
	    	TRB->PORCENTAJE:="<porcentaje>"+Alltrim(Transform(DET->PORCENTAJE,"@R 999.99"))+"</porcentaje>"
	    	TRB->BASE0     :="<base0>"+Alltrim(Transform(DET->BASE0          ,"@R 999999999.99"))+"</base0>"    	
	    	TRB->BASEGRAV  :="<baseGrav>"+Alltrim(Transform(DET->BASEGRAV    ,"@R 999999999.99"))+"</baseGrav>"
	    	TRB->BASENOGRAV:="<baseNoGrav>"+Alltrim(Transform(DET->BASENOGRAV,"@R 999999999.99"))+"</baseNoGrav>"
	    	TRB->VALRETAIR :="<valRetAir>"+Alltrim(Transform(DET->VALRETAIR  ,"@R 999999999.99"))+"</valRetAir>"
	    	TRB->_DETAIR   :="</detalleAir>"
	    	cChave:=DET->ESPECIE+DET->NFISCAL+DET->SERIE+DET->FORNECE+DET->LOJA
	    	DET->(dbSkip())	
			If cChave == DET->ESPECIE+DET->NFISCAL+DET->SERIE+DET->FORNECE+DET->LOJA
				TRB->(MsUnLock())
			EndIf
		End
        //DADOS DO COMPROVANTE DE RETENCAO
		TRB->_AIR      :="</air>"		
  		TRB->AUTRET    :="<autRet>"+cAutRet+"</autRet>"
	 	TRB->ESTABRET  :="<estabRet>"+cEstabRet+"</estabRet>"
		TRB->PTOEMIRET :="<ptoEmiRet>"+cPtoEmiRet+"</ptoEmiRet>"
		TRB->SECRET    :="<secRet>"+cSecRet+"</secRet>"
		TRB->DATAEMIRET:="<fechaEmiRet>"+cDataEmiRet+"</fechaEmiRet>"
        TRB->_DETCOMP  :="</detalleCompras>"
    	TRB->(MsUnLock())
 	End

Return (oTmpTable)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTRelIR    บAutor  ณRenato Nagib        บ Data ณ 29/07/10    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRelatorio para conferencia dos dados para declaracao do IR  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                 Equador                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TRelREOC()

	Local oReport

	If TRepInUse()
		oReport := ReportDef()
		oReport:PrintDialog()	
	EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |ReportDef บAutor  ณRenato Nagib        บ Data ณ  29/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ               DEFINICAO DO RELATORIO                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                     EQUADOR                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReportDef()

	Local oReport
	Local oSection1
	Local oSection2
	Local oSection3
	
	oReport := TReport():New("TRelIR","Declaracao de IR",,{|oReport| PrintReport(oReport)},"Declaracao de retencao de IR")

	oReport:SetLandScape(.T.)
	
	//SECAO1 - Detalles Das notas de compras
	oSection1 := TRSection():New(oReport,"Detalhe das notas de compras",{"TRB"})	
	TRCell():New(oSection1,"TpIdProv"   ,,,,15,.F.)
	TRCell():New(oSection1,"IdProv"     ,,,,15,.F.)
	TRCell():New(oSection1,"TipoComp"   ,,,,15,.F.)
	TRCell():New(oSection1,"Aut"        ,,,,15,.F.)
	TRCell():New(oSection1,"Estab"      ,,,,15,.F.)	
	TRCell():New(oSection1,"PtoEmi"     ,,,,10,.F.)	
	TRCell():New(oSection1,"Sec"        ,,,,10,.F.)	
	TRCell():New(oSection1,"DataEmiCom" ,,,,15,.F.)	

	//Detalles do Air
	oSection2 := TRSection():New(oReport,"Detalhe do Air",{"TRB"})	
	TRCell():New(oSection2,"CodRetAir"  ,,,,15,.F.)	
	TRCell():New(oSection2,"porcentaje" ,,,,15,.F.)	
	TRCell():New(oSection2,"Base0"      ,,,,15,.F.)	
	TRCell():New(oSection2,"Basegrav"   ,,,,15,.F.)	
	TRCell():New(oSection2,"BaseNoGrave",,,,15,.F.)	
	TRCell():New(oSection2,"ValRetAir"  ,,,,15,.F.)	
	
	//Detalles da retencao	
	oSection3 := TRSection():New(oReport,"Detalhe das Retencoes",{"TRB"})	
	TRCell():New(oSection3,"AutRet"     ,,,,15,.F.)	
	TRCell():New(oSection3,"EstabRet"   ,,,,15,.F.)	
	TRCell():New(oSection3,"PtoEmiRet"  ,,,,15,.F.)	
	TRCell():New(oSection3,"SecRet"     ,,,,10,.F.)	
	TRCell():New(oSection3,"DataEmiRet" ,,,,10,.F.)	

Return oReport
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPrintReportบAutor ณRenato Nagib        บ Data ณ  29/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao auxiliar do TReport para impressao dos dados         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                 EQUADOR                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PrintReport(oReport)
	
	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)
	Local oSection3	:= oReport:Section(3)	
	
	oReport:PrintText('IDENTIFICACION DEL CONTRIBUYENTE',(oReport:Row()),800,CLR_RED)
    oReport:IncRow(100)
	oReport:PrintText("Ruc del contribuyente -> "+SM0->M0_CGC,(oReport:Row()),100)
    oReport:IncRow(050)
	oReport:PrintText("Ano Declaracion -> "     +Substr(dTOs(MV_PAR01),1,4),(oReport:Row()),100)
    oReport:IncRow(050)
	oReport:PrintText("Mes Declaracion->"       +Substr(dTOs(MV_PAR01),5,2),(oReport:Row()),100)	
    oReport:IncRow(100)


	TRB->(dbGoTop())
	While TRB->(!EOF())		

		oSection1:Init() 	
		oReport:SetMeter(RecCount())	
		oReport:PrintText('FACTURA -> '+TRB->NFISCAL,(oReport:Row()),700,CLR_RED)


		oReport:Section(1):Cell("TpIdProv"  ):SetBlock({|| GetXml(TRB->TPIDPROV)  })   
		oReport:Section(1):Cell("IdProv"    ):SetBlock({|| GetXml(TRB->IDPROV)    })   
		oReport:Section(1):Cell("TipoComp"  ):SetBlock({|| GetXml(TRB->TIPOCOMP)  })   
		oReport:Section(1):Cell("Aut"       ):SetBlock({|| GetXml(TRB->AUT)       })  
		oReport:Section(1):Cell("TipoComp"  ):SetBlock({|| GetXml(TRB->TIPOCOMP)  })  
		oReport:Section(1):Cell("Aut"       ):SetBlock({|| GetXml(TRB->AUT)       })  
		oReport:Section(1):Cell("Estab"     ):SetBlock({|| GetXml(TRB->ESTAB)     })  
		oReport:Section(1):Cell("PtoEmi"    ):SetBlock({|| GetXml(TRB->PTOEMI)    })  
		oReport:Section(1):Cell("Sec"       ):SetBlock({|| GetXml(TRB->SEC)       })  
		oReport:Section(1):Cell("DataEmiCom"):SetBlock({|| GetXml(TRB->DATAEMICOM)}) 

		oSection1:Printline()				
	    oSection1:Finish()			
		TRB->(dbSkip())		
		oReport:PrintText('RETENCION:'+TRB->NFISCAL,(oReport:Row()),010,CLR_RED)
	    
	    While Alltrim(TRB->DETAIR) == '<detalleAir>' 
			oSection2:Init() 
			oReport:Section(2):Cell("CodRetAir"  ):SetBlock({|| GetXml(TRB->CODRETAIR  )})
			oReport:Section(2):Cell("porcentaje" ):SetBlock({|| GetXml(TRB->PORCENTAJE )})
			oReport:Section(2):Cell("Base0"      ):SetBlock({|| GetXml(TRB->BASE0      )}) 
			oReport:Section(2):Cell("Basegrav"   ):SetBlock({|| GetXml(TRB->BASEGRAV   )}) 
			oReport:Section(2):Cell("BaseNoGrave"):SetBlock({|| GetXml(TRB->BASENOGRAVE)})
			oReport:Section(2):Cell("ValRetAir"  ):SetBlock({|| GetXml(TRB->VALRETAIR  )})
		
			oSection2:Printline()				
			oSection2:Finish()			
			If Alltrim(TRB->_AIR) == '</air>'
			 	
				//COMPROVANTE DAS RETENCOES
				oSection3:Init() 				
				oReport:PrintText('COMPROBANTE DE RETENCION:'+TRB->NFISCAL,(oReport:Row()),010,CLR_RED)
				oReport:Section(3):Cell("AutRet"     ):SetBlock({|| GetXml(TRB->AUTRET    )})
				oReport:Section(3):Cell("EstabRet"   ):SetBlock({|| GetXml(TRB->ESTABRET  )})
				oReport:Section(3):Cell("PtoEmiRet"  ):SetBlock({|| GetXml(TRB->PTOEMIRET )})
				oReport:Section(3):Cell("SecRet"     ):SetBlock({|| GetXml(Alltrim(Iif(Len(DET->SECRET)-6<=7,Subs(DET->SECRET,7,Len(DET->SECRET)-6),Subs(DET->SECRET,Len(DET->SECRET)-6,7)   ) ))})
				oReport:Section(3):Cell("DataEmiRet" ):SetBlock({|| GetXml(TRB->DATAEMIRET)})
				oSection3:Printline()	
				oSection3:Finish()
			    oReport:IncRow(150)
			EndIf
			TRB->(dbSkip())
		End
    End
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGETLIVRO  บAutor  ณRENATO NAGIB        บ Data ณ  16/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ BUSCA NUMERO DO LIVRO PARA  PARA ALIQ IVA                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                     EQUADOR                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GETLIVRO(cImp)

	Local cQuery
	
	cQuery:=" SELECT FB_CPOLVRO AS LIVRO"
	cQuery+=" FROM "+RetSqlName('SFB990')+" SFB"
	cQuery+=" WHERE FB_CODIGO='"+cImp+"'" 
	cQuery+=" AND FB_FILIAL= '"+xFilial('SFB')+"'"
	cQuery+=" AND D_E_L_E_T_=''"
	ChangeQuery(cQuery)    
    dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQuery),'TRBSFB',.F.,.T.)
    
    cLivro:=TRBSFB->LIVRO
	TRBSFB->(dbCloseArea())
Return (cLivro)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGERXMLREOCบAutor  ณMicrosiga           บ Data ณ  07/30/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ          Obtem o conteudo das tags xml                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                  Equador                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetXml(cTag)

	cTag:=Alltrim(cTag)
	nOpenTag :=At('>',cTag)
	nCloseTag:=At('<',Substr(cTag,2))

	cCont:=Substr(cTag,nOpenTag+1,nCloseTag-nOpenTag)

Return (cCont)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFDelSUSS    บAutor  ณRenato Cruz nagib               28/07/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExclui  o arquivo temporario processado                       บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                 EQUADOR                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/         
Function FDelREOC(cArq)
   
	Local aAreaDel := GetArea()
	dbSelectArea('TRB')
	dbCloseArea()
	If oTmpTable <> Nil   
		oTmpTable:Delete()  
		oTmpTable := Nil 
	EndIf 
		RestArea(aAreaDel)
		DET->(dbCloseArea())
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetSFP    บAutor  ณ    Reanto Nagib    บ Data ณ  04/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ             Busca numero de auorizacao                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ              Equador                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetSFP(cFi,cSe,cNFis,cEsp)

	Local cQuery
	Local cAut
	local aEspec:={ {'1','NF'},{'2','NCI'},{'3','NDI'},{'4','NCC'},{'5','NDC'},{'6','RIR'},{'7','ICE'},{'8','IVA'}}	
	cEsp:=aEspec[aScan(aEspec,{|X| X[2]==cEsp})][1]

	cQuery:=" SELECT FP_NUMAUT AS AUT"
	cQuery+=" FROM "+RetSqlname('SFP')+" SFP"
	cQuery+=" WHERE FP_FILIAL='"+xFilial('SFP')+"'"
	cQuery+=" AND D_E_L_E_T_=''"
	cQuery+=" AND FP_FILUSO='"+cFi+"'"
	cQuery+=" AND FP_SERIE='"+cSe+"'"
	cQuery+=" AND FP_ESPECIE='"+cEsp+"'"
	cQuery+=" AND '"+cNFis+"' BETWEEN FP_NUMINI AND FP_NUMFIM"

	ChangeQuery(cQuery)    
    dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQuery),'TRBSFP',.F.,.T.)

	cAut:=TRBSFP->AUT
	
	TRBSFP->(dbCloseArea())
Return (cAut)
