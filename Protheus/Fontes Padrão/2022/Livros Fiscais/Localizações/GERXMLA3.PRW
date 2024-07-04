#INCLUDE "Protheus.ch"

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณLFeqXMLdv3 ณ Autor ณNilton (Onsten)       ณ Data ณ 15.07.2010ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณExtrai arquivo de trabalho (NF entrada) para uso no INI de   ณฑฑ
ฑฑณ          ณgera็ใo de arq. magneticos (XML) com impostos IVA, ICE, IR e ณฑฑ
ฑฑณ          ณ Reten็ใo de IVA e AIR	                                   ดฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณLuisEnriquezณ10/01/17ณSERINN001-940ณ-Se realiza merge para hacer modifi-ณฑฑ
ฑฑณ            ณ        ณ             ณ cacion en creacion de tablas tempo-ณฑฑ
ฑฑณ            ณ        ณ             ณ rales. CTREE.                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
*/

Function LFeqXMLdv3 (cDtIni, cDtfim)

Local aCampos	:= {}
Local aCpLivr	:= {}
Local aPosLiv	:= {}  
Local nLop		:= 0              
Local nCont		:= 0  
Local aEspecie  := {}  
Local cEspecie	:= ""
Local cTpNF 
Local nVal
Local cCdSust 
Local cChave
Local cKey	
Local aAIR := {}
Local oTmpTable := Nil
Local aOrdem := {}

dbSelectArea("SFB")
dbSetOrder(1)
dbgotop()
dBSeek(xFilial("SFB"),.T.)
While SFB->(!EOF()) 
	aadd(aPosLiv,{SFB->FB_CODIGO,SFB->FB_CPOLVRO})
	SFB->(dbSkip())	
endDo

// 1=NF;2=NCI;3=NDI;4=NCP;5=NDP    (SFP)
aadd(aespecie, {"NF ","1"})
aadd(aespecie, {"NCI","2"})
aadd(aespecie, {"NDI","3"})
aadd(aespecie, {"NCP","4"})
aadd(aespecie, {"NDP","5"})
                                   
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria็ใo do arquivo de trabalho
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู  

AADD(aCampos,{"CDSUSTEN","C",002,0})   
AADD(aCampos,{"TPLDPROV","C",002,0})   
AADD(aCampos,{"IDPROV"	,"C",013,0})   
AADD(aCampos,{"TPCOMPRO","C",002,0})   
AADD(aCampos,{"DTFECH"  ,"C",010,0})   
AADD(aCampos,{"ESTABEL"	,"C",003,0})   
AADD(aCampos,{"PTEMIS"	,"C",003,0})   
AADD(aCampos,{"SEQUENC"	,"C",009,0})   
AADD(aCampos,{"AUTORIZ"	,"C",010,0})   
AADD(aCampos,{"BASIMPON","N",013,2})   
AADD(aCampos,{"TOTALIVA","N",013,2})   
AADD(aCampos,{"IVASOLIC","N",013,2})   

oTmpTable := FWTemporaryTable():New("TRA") 
oTmpTable:SetFields( aCampos ) 
aOrdem	:=	{"ESTABEL","PTEMIS","SEQUENC"} 
oTmpTable:AddIndex("IN1", aOrdem) 
oTmpTable:Create() 

cNpos := aposliv[aScan(aposliv,{|x| x[1] == "IVA"})][2]

cQry:=" SELECT F3.F3_FILIAL FILIAL, F3.F3_CLIEFOR CLIEFOR, F3.F3_LOJA LOJA, F3.F3_NFISCAL NFISCAL, F3.F3_SERIE SERIE, "
cQry+=" F3.F3_ESPECIE ESPECIE"
cQry+=" FROM "+RetSqlName("SF3")+" F3, "+RetSqlName("SA2")+" A2  "
cQry+=" WHERE F3.D_E_L_E_T_='' AND F3.F3_FILIAL='"+xFilial("SF3")+"' AND A2.A2_COD = F3.F3_CLIEFOR AND A2.A2_PAIS <> 'EX' AND"
cQry+=" F3.F3_EMISSAO >='"+cDtIni+"' AND F3.F3_EMISSAO <= '"+cDtfim+"' AND F3.F3_TIPOMOV = 'C' AND F3.F3_VALIMP"+cNpos+" > 0 AND F3.F3_ESPECIE = 'NF' "
cQry+=" GROUP BY F3.F3_FILIAL, F3.F3_CLIEFOR, F3.F3_LOJA, F3.F3_NFISCAL, F3.F3_SERIE, F3.F3_ESPECIE "
cQry+=" ORDER BY F3.F3_FILIAL, F3.F3_CLIEFOR, F3.F3_LOJA, F3.F3_NFISCAL, F3.F3_SERIE, F3.F3_ESPECIE "


ChangeQuery(cQry)
dbUseArea(.T.,'TOPCONN',TcGenQry(,,Alltrim(cQry)),'NF1',.F.,.T.)

DbSelectArea("NF1")
DBGOTOP()                                                  
While NF1->(!EOF())
        RecLock("TRA",.T.)		
        dbselectarea("SF3")
		dbsetorder(4)
		dbgotop()
		SF3->(dbseek(xFilial("SF3")+NF1->CLIEFOR+NF1->LOJA+NF1->NFISCAL+NF1->SERIE))
		While SF3->(!EOF()) .AND. SF3->F3_FILIAL  = xFilial("SF3") .AND. SF3->F3_CLIEFOR = NF1->CLIEFOR  ; 
		                    .AND. SF3->F3_LOJA    = NF1->LOJA      .AND. SF3->F3_NFISCAL = NF1->NFISCAL  ;
		                    .AND. SF3->F3_SERIE	  = NF1->SERIE

			TRA->CDSUSTEN	:=	"01"
			dbselectarea("SF4")
			dbsetorder(1)
			dbgotop()
			if SF4->(dbseek(xFilial("SF3")+SF3->F3_TES))
				IF SF4->F4_ATUATF	= "S"
					TRA->CDSUSTEN	:= 	"03"
				endIf			
            endIf
			dbSelectArea("SA2")
			dbSetOrder(1)
			dbgotop() 
			SA2->(dbSeek(xFilial("SA2")+SF3->F3_CLIEFOR))			
       		If alltrim(SA2->A2_TIPDOC) $ "01|02|04|05|08"
       			TRA->TPLDPROV		:= "02"
       		EndIf
       		If alltrim(SA2->A2_TIPDOC) $ "03"
       			TRA->TPLDPROV		:= "01"
       		EndIf			
       		If alltrim(SA2->A2_TIPDOC) $ "07"
       			TRA->TPLDPROV		:= "03"
       		EndIf	
			TRA->IDPROV				:= SA2->A2_CGC 
			If alltrim(substr(SF3->F3_ESPECIE,1,2)) == "NF"
				TRA->TPCOMPRO 	:= "01"
			ElseIf alltrim(substr(SF3->F3_ESPECIE,1,2)) == "NC"
				TRA->TPCOMPRO 	:= "04"			
			ElseIf alltrim(substr(SF3->F3_ESPECIE,1,2)) == "ND"			
				TRA->TPCOMPRO 	:= "05"				
			Else					
				TRA->TPCOMPRO	:= SF3->F3_ESPECIE
			EndIf 
			TRA->DTFECH	:= "00/00/00"
			dbselectarea("SF1")
			dbsetorder(1)
			dbgotop()
			iF SF1->(dbseek(xFilial("SF3")+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA))        
				TRA->DTFECH	:= DTOC(SF1->F1_DTLANC)
			endIf
			TRA->ESTABEL 		:= Substr(SF3->F3_NFISCAL,1,3)
			TRA->PTEMIS			:= Substr(SF3->F3_NFISCAL,4,3)
			TRA->SEQUENC		:= Iif(len(Substr(SF3->F3_NFISCAL,7,10)) > 7,substr(SF3->F3_NFISCAL,LEN(SF3->F3_NFISCAL) - 13,7),substr(SF3->F3_NFISCAL,7,7))
			dbSelectArea("SFP")
			dbSetOrder(5)
			dbgotop()
			cEspecie := ascan(aEspecie,{|x| x[1] == PADR(SF3->F3_ESPECIE,3)}) 
			SFP->(dbSeek(xFilial("SFP")+SF3->F3_FILIAL+PADR(SF3->F3_SERIE,3)+iIf (cEspecie > 0, aespecie[cEspecie][2] ," ")))
			IF SFP->FP_ATIVO = '1' .AND. SF3->F3_EMISSAO <= SFP->FP_DTAVAL
				If VAL(SF3->F3_NFISCAL)	>= 	VAL(SFP->FP_NUMINI)	.AND. VAL(SF3->F3_NFISCAL)	<=	VAL(SFP->FP_NUMFIM) 
					TRA->AUTORIZ        := SFP->FP_NUMAUT
				EndIf    
			EndIf
			aCpLivr := TesImpInf(SF3->F3_TES) 
			if aCpLivr[1][1] $ "IVA|IVC"
				cNpos := aposliv[aScan(aposliv,{|x| x[1] == aCpLivr[1][1]})][2]	
	            dbselectarea("SF3")     
				If fieldget(fieldpos('F3_BASIMP'+alltrim(cNpos))) > 0
					if fieldget(fieldpos('F3_ALQIMP'+alltrim(cNpos))) <> 0
						TRA->BASIMPON += 	fieldget(fieldpos('F3_BASIMP'+alltrim(cNpos))) 
					endIf
				ENDIF
				if fieldget(fieldpos('F3_VALIMP'+alltrim(cNpos))) > 0
					TRA->TOTALIVA 		  +=    fieldget(fieldpos('F3_VALIMP'+alltrim(cNpos)))
					TRA->IVASOLIC 		  +=    fieldget(fieldpos('F3_VALIMP'+alltrim(cNpos)))
				endIf
			endif
			SF3->(dbSkip())
		endDo  
		msunlock()
    	NF1->(dbSkip())
endDo
dbclosearea() 

return

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณLFeqXMLdi3   ณ Autor ณNilton (Onsten)     ณ Data ณ 15.07.2010ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณExtrai arquivo de trabalho (NF Saidas) para uso no INI de    ณฑฑ
ฑฑณ          ณgera็ใo de arq. magneticos (XML) com impostos IVA, ICE, IR e ณฑฑ
ฑฑณ          ณ Reten็ใo de IVA 									   		   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
*/

Function LFeqXMLdi3 (cDtIni, cDtfim)

Local aCampos	:= {}
Local aCpLivr	:= {}
Local aPosLiv	:= {}  
Local nLop		:= 0              
Local nCont		:= 0  
Local aEspecie  := {}  
Local cEspecie	:= ""
Local cTpNF 
Local nVal
Local cCdSust 
Local cChave
Local cKey	
Local aAIR := {}
Local oTmpTable := Nil
Local aOrdem := {}

dbSelectArea("SFB")
dbSetOrder(1)
dbgotop()
dBSeek(xFilial("SFB"),.T.)
While SFB->(!EOF()) 
	aadd(aPosLiv,{SFB->FB_CODIGO,SFB->FB_CPOLVRO})
	SFB->(dbSkip())	
endDo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria็ใo do arquivo de trabalho
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู  

AADD(aCampos,{"CDSUSTEN","C",002,0})   
AADD(aCampos,{"NRREFER" ,"C",003,0})   
AADD(aCampos,{"ANOREFER","C",004,0})   
AADD(aCampos,{"REGREFER","C",002,0})   
AADD(aCampos,{"CORRREFE","C",006,0})   
AADD(aCampos,{"DGNRREFE","C",001,0})   
AADD(aCampos,{"BASIMPON","N",013,2})   
AADD(aCampos,{"TOTALIVA","N",013,2})   
AADD(aCampos,{"IVASOLIC","N",013,2})   

oTmpTable := FWTemporaryTable():New("TRB") 
oTmpTable:SetFields( aCampos ) 
aOrdem	:=	{"CDSUSTEN","NRREFER","ANOREFER","REGREFER","CORRREFE","DGNRREFE"} 
oTmpTable:AddIndex("IN1", aOrdem) 
oTmpTable:Create() 

cNpos := aposliv[aScan(aposliv,{|x| x[1] == "IVA"})][2]
 
cQry:=" SELECT F3.F3_FILIAL FILIAL, F3.F3_CLIEFOR CLIEFOR, F3.F3_LOJA LOJA, F3.F3_NFISCAL NFISCAL, F3.F3_SERIE SERIE, "
cQry+=" F3.F3_ESPECIE ESPECIE"
cQry+=" FROM "+RetSqlName("SF3")+" F3, "+RetSqlName("SA2")+" A2  "
cQry+=" WHERE F3.D_E_L_E_T_='' AND F3.F3_FILIAL='"+xFilial("SF3")+"' AND A2.A2_COD = F3.F3_CLIEFOR AND A2.A2_PAIS = 'EX' AND"
cQry+=" F3.F3_EMISSAO >='"+cDtIni+"' AND F3.F3_EMISSAO <= '"+cDtfim+"' AND F3.F3_TIPOMOV = 'C' AND F3.F3_VALIMP"+cNpos+" > 0 AND F3.F3_ESPECIE = 'NF' "
cQry+=" GROUP BY F3.F3_FILIAL, F3.F3_CLIEFOR, F3.F3_LOJA, F3.F3_NFISCAL, F3.F3_SERIE, F3.F3_ESPECIE "
cQry+=" ORDER BY F3.F3_FILIAL, F3.F3_CLIEFOR, F3.F3_LOJA, F3.F3_NFISCAL, F3.F3_SERIE, F3.F3_ESPECIE "


ChangeQuery(cQry)
dbUseArea(.T.,'TOPCONN',TcGenQry(,,Alltrim(cQry)),'NF2',.F.,.T.)

DbSelectArea("NF2")
DBGOTOP()                                                  
While NF2->(!EOF())
        RecLock("TRB",.T.)
		dbselectarea("SF1")
		dbsetorder(1)
		dbgotop()
		iF SF1->(dbseek(xFilial("SF3")+NF2->NFISCAL+NF2->SERIE+NF2->CLIEFOR+NF2->LOJA))        
			TRB->NRREFER	:=	substr(SF1->F1_NUMREF,1,3)
			TRB->ANOREFER	:=	substr(SF1->F1_NUMREF,4,4)
			TRB->REGREFER	:=  substr(SF1->F1_NUMREF,8,2)
			TRB->CORRREFE	:=  substr(SF1->F1_NUMREF,10,6)
			TRB->DGNRREFE	:=  substr(SF1->F1_NUMREF,16,1)
		endIf
        dbselectarea("SF3")
		dbsetorder(4)
		dbgotop()
		SF3->(dbseek(xFilial("SF3")+NF2->CLIEFOR+NF2->LOJA+NF2->NFISCAL+NF2->SERIE))
		While SF3->(!EOF()) .AND. SF3->F3_FILIAL  = xFilial("SF3") .AND. SF3->F3_CLIEFOR = NF2->CLIEFOR  ; 
		                    .AND. SF3->F3_LOJA    = NF2->LOJA      .AND. SF3->F3_NFISCAL = NF2->NFISCAL  ;
		                    .AND. SF3->F3_SERIE	  = NF2->SERIE

			TRB->CDSUSTEN	:=	"01"
			dbselectarea("SF4")
			dbsetorder(1)
			dbgotop()
			if SF4->(dbseek(xFilial("SF4")+SF3->F3_TES))
				IF SF4->F4_ATUATF	= "S"
					TRB->CDSUSTEN	:= 	"03"
				endIf			
            endIf
			aCpLivr := TesImpInf(SF3->F3_TES)
			if aCpLivr[1][1] $ "IVA|IVC"			
				cNpos := aposliv[aScan(aposliv,{|x| x[1] == aCpLivr[1][1]})][2]	
	            dbselectarea("SF3")     
				If fieldget(fieldpos('F3_BASIMP'+alltrim(cNpos))) > 0
					if fieldget(fieldpos('F3_ALQIMP'+alltrim(cNpos))) <> 0
						TRB->BASIMPON += 	fieldget(fieldpos('F3_BASIMP'+alltrim(cNpos))) 
					endIf
				ENDIF
				if fieldget(fieldpos('F3_VALIMP'+alltrim(cNpos))) > 0
					TRB->TOTALIVA 		  +=    fieldget(fieldpos('F3_VALIMP'+alltrim(cNpos)))
					TRB->IVASOLIC 		  +=    fieldget(fieldpos('F3_VALIMP'+alltrim(cNpos)))
				endIf
			endIf
			SF3->(dbSkip())
		endDo  
		msunlock()
    	NF2->(dbSkip())
endDo
dbclosearea() 

TRelDIVA()

return             



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTRelDIVA  บAutor  ณ Nilton MK          บ Data ณ  02/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRelatorio para conferencia dos dados para devolu็ใo de IVA  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                 Equador                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function TRelDIVA()

	Local oReport

	If TRepInUse()
		oReport := TRelDEF()
		oReport:PrintDialog()	
	EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTRelDEF	บAutor  ณ Nilton MK          บ Data ณ  02/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ               DEFINE O RELATORIO                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ              Livro fiscal de entrada                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TRelDEF()

	Local oReport
	Local oSection1
//	Local oSection2

	oReport := TReport():New("TRelIR","Anexo Devolu็ใo de IVA",,{|oReport| PrintReport(oReport)},"Anexo Devolu็ใo de IVA")

	oReport:SetLandScape(.T.)


	//SECAO1 - Detalhe Das notas de compras
	oSection1 := TRSection():New(oReport,"Detalhe das notas de compras",{"TRA"})	
	TRCell():New(oSection1,"codsustento"    ,,,,25,.F.)
	TRCell():New(oSection1,"TpIdProv"       ,,,,25,.F.)
	TRCell():New(oSection1,"IdProv"   		,,,,25,.F.)
	TRCell():New(oSection1,"TipoComprobante",,,,25,.F.)
	TRCell():New(oSection1,"FechaRegist"    ,,,,25,.F.)
	TRCell():New(oSection1,"Estab"          ,,,,25,.F.)	
	TRCell():New(oSection1,"PtoEmi"         ,,,,25,.F.)	
	TRCell():New(oSection1,"Sec"     		,,,,25,.F.)	
	TRCell():New(oSection1,"Autorizacion"   ,,,,25,.F.)	
	TRCell():New(oSection1,"BaseImponible"  ,,,,25,.F.)	
	TRCell():New(oSection1,"MontoIVA" 		,,,,25,.F.)	
	TRCell():New(oSection1,"IvaSolicitado"  ,,,,25,.F.)	

	//Detales das notas de importa็๕es
	oSection2 := TRSection():New(oReport,"Detalhe do Air",{"TRB"})	
	TRCell():New(oSection2,"Cod Sustento"   ,,,,25,.F.)	
	TRCell():New(oSection2,"Dist. Aduanero" ,,,,25,.F.)	
	TRCell():New(oSection2,"Anio"		    ,,,,25,.F.)
	TRCell():New(oSection2,"Regimen"	    ,,,,25,.F.)
	TRCell():New(oSection2,"Correlativo"    ,,,,25,.F.)	
	TRCell():New(oSection2,"Dg Verificador" ,,,,25,.F.)	
	TRCell():New(oSection2,"Base Imponible"	,,,,25,.F.)	
	TRCell():New(oSection2,"Monto Iva"      ,,,,25,.F.)	
	TRCell():New(oSection2,"Iva solicitado" ,,,,25,.F.)	

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPrintReportบAutor ณNilton  SServices   บ Data ณ  26/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Relatorio de conferencia de apoio a gera็ใo de XML ao DIMMบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao oReport                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PrintReport(oReport)

	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)	
	
	oReport:PrintText('Rela็ใo de Notas para conferencia da devolu็ใo de IVA - DIMM Anexo 3 - COMPRAS',(oReport:Row()),700,CLR_RED)
    oReport:IncRow(050)
	oReport:PrintText("Ruc do contribuinte : "+SM0->M0_CGC,(oReport:Row()),700,CLR_RED)
    oReport:IncRow(050)
	oReport:PrintText("Ano Declaracao : "+Substr(dTOs(MV_PAR01),1,4),(oReport:Row()),700,CLR_RED)
    oReport:IncRow(050)
	oReport:PrintText("Mes Declaracao : "+Substr(dTOs(MV_PAR01),5,2),(oReport:Row()),700,CLR_RED)	
    oReport:IncRow(100)
	oReport:PrintText('COMPRAS',(oReport:Row()),700,CLR_RED)
    oReport:IncRow(100)
      
	TRA->(dbGoTop())
	While TRA->(!EOF())		
		oReport:SetMeter(RecCount())	

		oSection1:Init() 	

		oReport:Section(1):Cell("codsustento"  )	:SetBlock({|| TRA->CDSUSTEN})   	
		oReport:Section(1):Cell("TpIdProv"     )	:SetBlock({|| TRA->TPLDPROV})   
		oReport:Section(1):Cell("IdProv"       )	:SetBlock({|| TRA->IDPROV})   
		oReport:Section(1):Cell("TipoComprobante")	:SetBlock({|| TRA->TPCOMPRO})   
		oReport:Section(1):Cell("FechaRegist"  )	:SetBlock({|| TRA->DTFECH}) 
		oReport:Section(1):Cell("Estab"        )	:SetBlock({|| TRA->ESTABEL})  
		oReport:Section(1):Cell("PtoEmi"       )	:SetBlock({|| TRA->PTEMIS  })  
		oReport:Section(1):Cell("Sec"          )	:SetBlock({|| TRA->SEQUENC })  
		oReport:Section(1):Cell("Autorizacion" )	:SetBlock({|| TRA->AUTORIZ })  
		oReport:Section(1):Cell("BaseImponible")	:SetBlock({|| TRA->BASIMPON})  		
		oReport:Section(1):Cell("MontoIVA"     )	:SetBlock({|| TRA->TOTALIVA})  		
		oReport:Section(1):Cell("IvaSolicitado")	:SetBlock({|| TRA->IVASOLIC})  		
			
		oSection1:Printline()				
	    oReport:IncRow(010)
		TRA->(dbSkip())
    End
	oSection1:Finish() 
	
    oReport:IncRow(100)
	oReport:PrintText('IMPORTACIONES',(oReport:Row()),700,CLR_RED)
    oReport:IncRow(100)		    
	    
	TRB->(dbGoTop())
	While TRB->(!EOF())		
		oReport:SetMeter(RecCount())	

		oSection2:Init() 	

		oReport:Section(2):Cell("Cod Sustento"  )	:SetBlock({|| TRB->CDSUSTEN})   	
		oReport:Section(2):Cell("Dist. Aduanero")	:SetBlock({|| TRB->NRREFER})   
		oReport:Section(2):Cell("Anio")       		:SetBlock({|| TRB->ANOREFER}) 
		oReport:Section(2):Cell("Regimen")      	:SetBlock({|| TRB->REGREFER}) 		  
		oReport:Section(2):Cell("Correlativo")		:SetBlock({|| TRB->CORRREFE})   
		oReport:Section(2):Cell("Dg Verificador")	:SetBlock({|| TRB->DGNRREFE}) 
		oReport:Section(2):Cell("Base Imponible")	:SetBlock({|| TRB->BASIMPON})  
		oReport:Section(2):Cell("Monto Iva"     )	:SetBlock({|| TRB->TOTALIVA})  
		oReport:Section(2):Cell("Iva solicitado")	:SetBlock({|| TRB->IVASOLIC})  

		oSection2:Printline()				
	    oReport:IncRow(010)
		TRB->(dbSkip())
    End	    
	oSection2:Finish()
Return
