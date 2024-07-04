#INCLUDE "Protheus.ch"
#include 'GERXMLA1.ch'

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LFeqXMLan1 ³ Autor ³Nilton (Onsten)       ³ Data ³ 15.07.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Extrai arquivo de trabalho (NF entrada) para uso no INI de   ³±±
±±³          ³geração de arq. magneticos (XML) com impostos IVA, ICE, IR e ³±±
±±³          ³ Retenção de IVA e AIR	GERXMLA1                           ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³LuisEnríquez³13/01/17³SERINN001-934³-Se realiza merge para agregar cam- ³±±
±±³            ³        ³             ³ bios de creación de tablas tempo-  ³±±
±±³            ³        ³             ³ rales CTREE.                       ³±±
±±³Oscar G.    ³25/01/17³DMINA-5197   ³-Se crea Fun. RetIR para generacion ³±±
±±³            ³        ³             ³ de nodo de detalle de retenciones.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
*/

Function LFeqXMLan1 (cDtIni, cDtfim)

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
local oTmpTable	:= Nil
Local cFilSFB	:= xFilial("SFB")
Local cFilSFC	:= xFilial("SFC")
Local cFilSFE	:= xFilial("SFE")
Local cFilSF1	:= xFilial("SF1")
Local cFilSF2	:= xFilial("SF2")
Local cFilSF3	:= xFilial("SF3")
Local cFilSA1	:= xFilial("SA1")
Local cFilSA2	:= xFilial("SA2")
Local cFilSD1	:= xFilial("SD1")
Local cFilSB1	:= xFilial("SB1")
Local aSM0Tmp	:= GetArea("SM0")
local dDtConta	:= ""
Local cLibExe	:= SuperGetMv("MV_LIBEXE",.F.,"")
Local aLibExe	:= {}
Local aTabelas	:= {}
Local aInfo		:= {}
Local cFilEm	:= ""
Local nX		:= 0
Local cSecuen	:= ""
Local cEmiCod	:= ""
Local nAutori	:= ""
Local cPtoEmi	:= ""
Local cEstab	:= ""
Local cFilTmp	:= cFilAnt
Local cFilTmp2	:= ""
Local nPos		:= 0
Local cTipCom   := "" 
Local cTipSus   := ""
Local cCodProvS	:= ""
Local cLojaS    := ""
Local lTpComRee := IIf(SF2->(ColumnPos("F2_TPDOC"))==0 .OR. SF2->(ColumnPos("F2_TPVENT"))==0 .OR. SF2->(ColumnPos("F2_TIPOPE"))==0,.F.,.T.)


LFilEmp (@aTabelas, @ainfo)

If !Empty(cLibExe)
	aLibExe := StrTokArr( cLibExe, "|" )
	cLibExe := ""
	For nX := 1 To Len(aLibExe)
		cLibExe += "D1_BASIMP" + Alltrim(aLibExe[nX]) + " | "
	Next nX 
EndIf

dbSelectArea("SFB")
SFB->(dbSetOrder(1)) //FB_FILIAL+FB_CODIGO
SFB->(dbgotop())
SFB->(dBSeek(xFilial("SFB"),.T.))
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
aadd(aespecie, {"RIR","6"})
aadd(aespecie, {"ICE","7"})
aadd(aespecie, {"IVA","8"})
                                   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criação do arquivo de trabalho
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
AADD(aCampos,{"FILIAL"  ,"C",TamSX3("F3_FILIAL")[01],0})
AADD(aCampos,{"CLIEFOR" ,"C",015,0})   
AADD(aCampos,{"LOJA" 	,"C",002,0})
AADD(aCampos,{"NFISCAL" ,"C",015,0})   
AADD(aCampos,{"SERIE"	,"C",005,0})   
AADD(aCampos,{"ESPECIE"	,"C",005,0})   
AADD(aCampos,{"CDSUSTEN","C",002,0})   
AADD(aCampos,{"TPLDPROV","C",002,0})   
AADD(aCampos,{"IDPROV"	,"C",013,0})   
AADD(aCampos,{"TPCOMPRO","C",002,0})   
AADD(aCampos,{"DTFECH"  ,"D",010,0})
AADD(aCampos,{"ESTABEL"	,"C",003,0})   
AADD(aCampos,{"PTEMIS"	,"C",003,0})   
AADD(aCampos,{"SEQUENC"	,"C",009,0})   
AADD(aCampos,{"DTEMISS" ,"C",010,0})   
AADD(aCampos,{"AUTORIZ"	,"C",TamSX3("F1_NUMAUT")[01],0})   
AADD(aCampos,{"BASIMPEX","N",015,0})
AADD(aCampos,{"RETBIE10","N",015,0})
AADD(aCampos,{"RETSER20","N",015,0})
AADD(aCampos,{"RETSER50","N",015,0})
AADD(aCampos,{"BASNOGRV","N",013,2})   
AADD(aCampos,{"BASIMPON","N",013,2})   
AADD(aCampos,{"BASIMPGR","N",013,2})   
AADD(aCampos,{"TOTALICE","N",013,2})  
AADD(aCampos,{"TOTALIVA","N",013,2})   
AADD(aCampos,{"VLRETBEN","N",013,2})  
AADD(aCampos,{"VLRETSRV","N",013,2})  
AADD(aCampos,{"RETIVA100","N",013,2})  
AADD(aCampos,{"CDRETAIR","C",005,0})  
AADD(aCampos,{"BASRETAIR","N",013,2}) 
AADD(aCampos,{"ALQRETAIR","N",005,2}) 
AADD(aCampos,{"VALRETAIR","N",013,2}) 
AADD(aCampos,{"ESTRET1"	,"C",003,0}) 
AADD(aCampos,{"PTEMRET1","C",003,0}) 
AADD(aCampos,{"SEQRET1"	,"C",009,0}) 
AADD(aCampos,{"AUTRET1"	,"C",010,0}) 
AADD(aCampos,{"DTEMRET1","D",010,0}) 
AADD(aCampos,{"ESTRET2"	,"C",003,0}) 
AADD(aCampos,{"PTEMRET2","C",003,0}) 
AADD(aCampos,{"SEQRET2"	,"C",009,0}) 
AADD(aCampos,{"AUTRET2"	,"C",010,0}) 
AADD(aCampos,{"DTEMRET2","D",010,0})
AADD(aCampos,{"DOCMOD"	,"C",002,0}) 
AADD(aCampos,{"ESTMOD"	,"C",003,0})    
AADD(aCampos,{"PTEMMOD"	,"C",003,0})    
AADD(aCampos,{"SEQMOD"	,"C",009,0})    
AADD(aCampos,{"AUTMOD"	,"C",010,0})
AADD(aCampos,{"FORPAGO" ,"C",002,0})    
//campos para control de Reembolsos
AADD(aCampos,{"TPDOC"	,"C",002,0})    
AADD(aCampos,{"TPVENT"	,"C",001,0})
AADD(aCampos,{"TIPOPE" ,"C",003,0})   


oTmpTable := FWTemporaryTable():New("TRA") 
oTmpTable:SetFields( aCampos ) 
aOrdem	:=	{"FILIAL","CLIEFOR","NFISCAL","SERIE","ESPECIE","CDSUSTEN"} 
oTmpTable:AddIndex("I1", aOrdem) 
oTmpTable:Create() 
 
cQry:=" SELECT F3.F3_FILIAL FILIAL, F3.F3_CLIEFOR CLIEFOR, F3.F3_LOJA LOJA, F3.F3_NFISCAL NFISCAL, F3.F3_SERIE SERIE, "
cQry+=" F3.F3_ESPECIE ESPECIE,  CASE WHEN FC.FC_IMPOSTO <> 'RIR' THEN 'IVA' ELSE 'RIR' END CODIMP , CASE F4.F4_ATUATF WHEN ' ' THEN 'N' ELSE F4.F4_ATUATF END ATUATF, F3.F3_EMISSAO EMISSAO "
cQry+=" ,'  ' TPDOC, ' ' TPVENT, '  ' TIPOPE "
cQry+=" FROM "+RetSqlName("SF3")+" F3,"+RetSqlName("SF4")+" F4,"+RetSqlName("SFC")+" FC,"+RetSqlName("SFB")+ " FB "
cQry+=" WHERE F3.D_E_L_E_T_='' AND F4.D_E_L_E_T_='' AND F3.F3_EMISSAO >='"+cDtIni+"' AND F3.F3_EMISSAO <= '"+cDtfim+"' AND F3.F3_TIPOMOV = 'C' "
cQry+=" AND F4.F4_FILIAL = F3.F3_FILIAL AND F4.F4_CODIGO = F3.F3_TES "
cQry+=" AND FC.FC_TES = F3.F3_TES AND FC.FC_SEQ = '01' AND FB.FB_CODIGO = FC.FC_IMPOSTO "
cQry+=" GROUP BY F3.F3_FILIAL, F3.F3_CLIEFOR, F3.F3_LOJA, F3.F3_NFISCAL, F3.F3_SERIE, F3.F3_ESPECIE, CASE WHEN FC.FC_IMPOSTO <> 'RIR' THEN 'IVA' ELSE 'RIR' END , F4.F4_ATUATF, F3.F3_EMISSAO "

If lTpComRee
	cQry+=" UNION ALL "
	cQry+=" SELECT F3.F3_FILIAL FILIAL, F3.F3_CLIEFOR CLIEFOR, F3.F3_LOJA LOJA, F3.F3_NFISCAL NFISCAL, F3.F3_SERIE SERIE, "
	cQry+=" F3.F3_ESPECIE ESPECIE,  CASE WHEN FC.FC_IMPOSTO <> 'RIR' THEN 'IVA' ELSE 'RIR' END CODIMP , CASE F4.F4_ATUATF WHEN ' ' THEN 'N' ELSE F4.F4_ATUATF END ATUATF, F3.F3_EMISSAO EMISSAO "
	cQry+=" , F2.F2_TPDOC TPDOC, F2.F2_TPVENT TPVENT, F2.F2_TIPOPE TIPOPE"
	cQry+=" FROM "+RetSqlName("SF3")+" F3,"+RetSqlName("SF4")+" F4,"+RetSqlName("SFC")+" FC,"+RetSqlName("SFB")+ " FB ," + RetSqlName("SF2")+ " F2 "
	cQry+=" WHERE F3.D_E_L_E_T_='' AND F4.D_E_L_E_T_='' AND F3.F3_EMISSAO >='"+cDtIni+"' AND F3.F3_EMISSAO <= '"+cDtfim+"' AND  F3.F3_TIPOMOV = 'V' "
	cQry+=" AND F4.F4_FILIAL = F3.F3_FILIAL AND F4.F4_CODIGO = F3.F3_TES "
	cQry+=" AND FC.FC_TES = F3.F3_TES AND FC.FC_SEQ = '01' AND FB.FB_CODIGO = FC.FC_IMPOSTO "
	cQry+=" AND F3.F3_FILIAL = F2.F2_FILIAL AND F3.F3_NFISCAL = F2.F2_DOC AND F3.F3_SERIE = F2.F2_SERIE AND F3.F3_CLIEFOR = F2.F2_CLIENTE AND F3.F3_LOJA = F2.F2_LOJA "
	cQry+=" AND (F2_TPDOC = '01' AND F2_TPVENT = '1' AND F2_TIPOPE='41') "
	cQry+=" GROUP BY F3.F3_FILIAL, F3.F3_CLIEFOR, F3.F3_LOJA, F3.F3_NFISCAL, F3.F3_SERIE, F3.F3_ESPECIE, CASE WHEN FC.FC_IMPOSTO <> 'RIR' THEN 'IVA' ELSE 'RIR' END , F4.F4_ATUATF, F3.F3_EMISSAO "
	cQry+=" , F2.F2_TPDOC , F2.F2_TPVENT , F2.F2_TIPOPE "	
EndIf
cQry+=" ORDER BY FILIAL, CLIEFOR, LOJA, NFISCAL, SERIE, ESPECIE, CODIMP , ATUATF, EMISSAO "

ChangeQuery(cQry)
dbUseArea(.T.,'TOPCONN',TcGenQry(,,Alltrim(cQry)),'NF1',.F.,.T.)

cFilSFB	:= xFilial("SFB")
cFilSFC	:= xFilial("SFC")
cFilSFE	:= xFilial("SFE")
cFilSF1	:= xFilial("SF1")
cFilSF2	:= xFilial("SF2")
cFilSF3	:= xFilial("SF3")
cFilSA1	:= xFilial("SA1")
cFilSA2	:= xFilial("SA2")
cFilSD1	:= xFilial("SD1")
cFilSB1	:= xFilial("SB1")

DbSelectArea("NF1")
NF1->(DBGOTOP())                                                  
While NF1->(!EOF())
	If cFilTmp2 <> NF1->FILIAL
		cFilAnt := NF1->FILIAL
		cFilTmp2:= NF1->FILIAL
		cFilAnt	:= cFilTmp
		dbSelectArea("SFB")
		SFB->(dbSetOrder(1)) //FB_FILIAL+FB_CODIGO
		SFB->(dbgotop())
		SFB->(MsSeek(cFilSFB,.T.))
		aPosLiv := {}
		While SFB->(!EOF()) 
			aadd(aPosLiv,{SFB->FB_CODIGO,SFB->FB_CPOLVRO})
			SFB->(dbSkip())	
		endDo
	EndIf
	
	If Alltrim(NF1->ESPECIE) $ "NF|NDP"
		dbSelectArea("SF1")
		SF1->(DbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
		SF1->(DbGoTop())			
		If SF1->(MsSeek(cFilSF1+NF1->NFISCAL+padr(NF1->SERIE,3)+NF1->CLIEFOR+NF1->LOJA))
			cSecuen		:= IIf(Len(Alltrim(SF1->F1_DOC)) > 9, RIGHT(Alltrim(SF1->F1_DOC),9), Padr(Alltrim(SF1->F1_DOC), 9, "0"))
			nAutori		:= SF1->F1_NUMAUT		 
			dDtConta	:= SF1->F1_DTLANC
			cEstab		:= SF1->F1_ESTABL
			cPtoEmi		:= SF1->F1_PTOEMIS	
			If SF1->(ColumnPos( "F1_TIPOPE" )) > 0
				If Empty(SF1->F1_TIPOPE)
					cTipCom := "01"
				Else
					cTipCom := AllTrim(SF1->F1_TIPOPE)
				EndIf
			Else	
				cTipCom := "01"
			EndIf

			If SF1->(ColumnPos( "F1_CODCTR" )) > 0
				If !Empty(SF1->F1_CODCTR)
					cTipSus:= AllTrim(SF1->F1_CODCTR)
				EndIf
			EndIf
		Else 
			If Alltrim(NF1->ESPECIE) == "NF" .and. NF1->TPDOC == '01' .AND. NF1->TPVENT =='1' .AND. AllTrim(NF1->TIPOPE) == '41' 
				dbSelectArea("SF2")
				SF2->(DbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
				SF2->(DbGoTop())			
				If SF2->(MsSeek(cFilSF2+NF1->NFISCAL+padr(NF1->SERIE,3)+NF1->CLIEFOR+NF1->LOJA))
					cSecuen		:= IIf(Len(Alltrim(SF2->F2_DOC)) > 9, RIGHT(Alltrim(SF2->F2_DOC),9), Alltrim(SF2->F2_DOC))	
					nAutori		:= SF2->F2_NUMAUT
					dDtConta	:= SF2->F2_EMISSAO
					cEstab		:= SF2->F2_ESTABL
					cPtoEmi		:= SF2->F2_PTOEMIS
					If SF2->(ColumnPos( "F2_TIPOPE" )) > 0
						If Empty(SF2->F2_TIPOPE)
							cTipCom := "01"
						Else
							cTipCom := AllTrim(SF2->F2_TIPOPE)
						EndIf
					Else	
						cTipCom := "01"
					EndIf

					If SF2->(ColumnPos( "F2_CODCTR" )) > 0
						If !Empty(SF2->F2_CODCTR)
							cTipSus:= AllTrim(SF2->F2_CODCTR)
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	ElseIf Alltrim(NF1->ESPECIE) $ "NCP"
		dbSelectArea("SF2")
		SF2->(DbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		SF2->(DbGoTop())			
		If SF2->(MsSeek(cFilSF2+NF1->NFISCAL+padr(NF1->SERIE,3)+NF1->CLIEFOR+NF1->LOJA))
			cSecuen		:= IIf(Len(Alltrim(SF2->F2_DOC)) > 9, RIGHT(Alltrim(SF2->F2_DOC),9), Alltrim(SF2->F2_DOC))
			nAutori		:= SF2->F2_NUMAUT
			dDtConta	:= SF2->F2_DTLANC
			cEstab		:= SF2->F2_ESTABL
			cPtoEmi		:= SF2->F2_PTOEMIS
		EndIf
	EndIf 
	
	If !Empty(dDtConta)
        RecLock("TRA",.T.)
        TRA->DTFECH		:= dDtConta
        TRA->SEQUENC	:= cSecuen
        TRA->AUTORIZ	:= nAutori
		cNpos := aposliv[aScan(aposliv,{|x| x[1] == iif(NF1->CODIMP <> "RIR","IVA","RIR")})][2]	
		If !Empty(cTipSus)
			TRA->CDSUSTEN :=cTipSus
		Else
			If NF1->CODIMP	$ "IVA|IVC|ICE|ICC"
				TRA->CDSUSTEN	:=	"01"
				IF NF1->ATUATF	= "S"
					TRA->CDSUSTEN	:= 	"03"
				endIf			
			EndIf
			If NF1->CODIMP	= "RIR"
				cNpos := aposliv[aScan(aposliv,{|x| x[1] == "IVA"})][2]	
				TRA->CDSUSTEN	:=	"02"
				IF NF1->ATUATF	= "S"
					TRA->CDSUSTEN	:= 	"04"                                           
				endIf			
			EndIf
		Endif
		TRA->FILIAL		:=		NF1->FILIAL
		TRA->CLIEFOR    :=		NF1->CLIEFOR
		TRA->LOJA		:=		NF1->LOJA
		TRA->NFISCAL    :=		NF1->NFISCAL                                
		TRA->SERIE		:=		NF1->SERIE
		TRA->ESPECIE	:=      NF1->ESPECIE
		If alltrim(substr(NF1->ESPECIE,1,2)) == "NF"
			TRA->TPCOMPRO 	:= cTipCom
		ElseIf alltrim(substr(NF1->ESPECIE,1,2)) == "NC"
			TRA->TPCOMPRO 	:= "04"			
		ElseIf alltrim(substr(NF1->ESPECIE,1,2)) == "ND"			
			TRA->TPCOMPRO 	:= "05"				
		Else					
			TRA->TPCOMPRO	:= NF1->ESPECIE
		EndIf 
				
		TRA->ESTABEL            := cEstab
		TRA->PTEMIS				:= cPtoEmi
		TRA->DTEMISS			:= dtoc(stod(NF1->EMISSAO))
   		TRA->TPLDPROV			:= "01"	
		
		cCodProvS	:= NF1->CLIEFOR
		If Alltrim(NF1->ESPECIE) == "NF" .and. NF1->TPDOC == '01' .AND. NF1->TPVENT =='1' .AND. AllTrim(NF1->TIPOPE) == '41'
			ObtProvCli(@cCodProvS, @cLojaS,NF1->CLIEFOR, NF1->LOJA ) // obtiene el proveedor relaciondo al cliente
		EndIf

		dbSelectArea("SA2")
		SA2->(dbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
		SA2->(dbgotop()) 
		SA2->(dbSeek(cFilSA2+cCodProvS))
		TRA->FORPAGO := SA2->A2_MPAGO
       	If alltrim(SA2->A2_TIPDOC) $ "01"
       		TRA->TPLDPROV		:= "01"
       	EndIf
       	If alltrim(SA2->A2_TIPDOC) $ "02"
       		TRA->TPLDPROV		:= "02"
       	EndIf			
       	If alltrim(SA2->A2_TIPDOC) $ "03 "
       		TRA->TPLDPROV		:= "03"
       	EndIf	
		TRA->IDPROV				:= SA2->A2_CGC 
		if SA2->A2_CGC == " " 
			dbSelectArea("SA1")
			SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
			SA1->(DbGoTop()) 
			SA1->(MsSeek(xFilSA1+NF1->CLIEFOR))			
			TRA->IDPROV	:= SA1->A1_CGC 			
		endif	
		TRA->TPDOC := NF1->TPDOC
		TRA->TPVENT:= NF1->TPVENT 
		TRA->TIPOPE:= NF1->TIPOPE
		TRA->CDRETAIR   := "303"
		TRA->ALQRETAIR  := 8.00
		TRA->ESTRET1	:= "000"
		TRA->PTEMRET1   := "000"
		TRA->SEQRET1    := "0"
		TRA->AUTRET1	:= "000"
		TRA->ESTRET2	:= "000"
		TRA->PTEMRET2   := "000"
		TRA->SEQRET2    := "0"
		TRA->AUTRET2	:= "000"
		TRA->DTEMRET2   := stod("00000000")
		TRA->DOCMOD     := "0"
		TRA->ESTMOD    	:= "000"
		TRA->PTEMMOD	:= "000"
		TRA->SEQMOD     := "0"
		TRA->AUTMOD     := "000"

        dbselectarea("SF3")
		SF3->(dbsetorder(4)) //F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE
		SF3->(dbgotop())
		SF3->(MsSeek(NF1->FILIAL + NF1->CLIEFOR + NF1->LOJA + NF1->NFISCAL + NF1->SERIE))
		While SF3->(!EOF()) .AND. SF3->F3_FILIAL  = NF1->FILIAL .AND. SF3->F3_CLIEFOR = NF1->CLIEFOR  ; 
		                    .AND. SF3->F3_LOJA    = NF1->LOJA      .AND. SF3->F3_NFISCAL = NF1->NFISCAL  ;
		                    .AND. SF3->F3_SERIE	  = NF1->SERIE

			DbSelectArea("SFC")
			SFC->(DbSetOrder(1)) //FC_FILIAL+FC_TES+FC_SEQ+FC_IMPOSTO
			SFC->(MsSeek(cFilSFC + SF3->F3_TES))
			While SFC->(!EOF()) .And. SFC->FC_FILIAL = cFilSFC .And. SFC->FC_TES = SF3->F3_TES
				nPos := aScan(aposliv,{|x| x[1] == SFC->FC_IMPOSTO})
				aAdd(aCpLivr,{SFC->FC_IMPOSTO, "D1_VALIMP" + aposliv[nPos][2]})
				SFC->(DbSkip())
			EndDo
			cNpos := aposliv[aScan(aposliv,{|x| x[1] == aCpLivr[1][1]})][2]	

			cTpNF := Iif (aCpLivr[1][1] <> "RIR","IVA","RIR")
			if cTpNF = NF1->CODIMP
				if cTpnf = "IVA" 
		            dbselectarea("SF3")     
					if substr(aCpLivr[1][1],1,1) = "I" 
						If SF3->F3_EXENTAS	> 0
							TRA->BASNOGRV   += fieldget(fieldpos('F3_BASIMP'+alltrim(cNpos))) 
						endif
						If substr(aCpLivr[1][1],1,2)	= "IV"				
							If fieldget(fieldpos('F3_BASIMP'+alltrim(cNpos))) > 0
								if fieldget(fieldpos('F3_ALQIMP'+alltrim(cNpos))) = 0
									TRA->BASIMPON += 	fieldget(fieldpos('F3_BASIMP'+alltrim(cNpos))) 
								endIf
								if fieldget(fieldpos('F3_ALQIMP'+alltrim(cNpos))) <> 0
									TRA->BASIMPGR += 	fieldget(fieldpos('F3_BASIMP'+alltrim(cNpos))) 
								endIf							
								TRA->TOTALIVA 		  +=    fieldget(fieldpos('F3_VALIMP'+alltrim(cNpos)))
							endIf						
						endIf
						If substr(aCpLivr[1][1],1,2)	= "IC"				
						    TRA->TOTALICE 		  += 	fieldget(fieldpos('F3_VALIMP'+alltrim(cNpos))) 			
						endIf
					endIf
					if len(aCpLivr) > 1
						If aCpLivr[2][1] = "RV2"				
							cNpos := aposliv[aScan(aposliv,{|x| x[1] == aCpLivr[2][1]})][2]
						    TRA->RETIVA100 			  += 	fieldget(fieldpos('F3_VALIMP'+alltrim(cNpos))) 
						EndIf
					EndIf
					dbselectarea("SF1")
					SF1->(dbsetorder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
					SF1->(dbgotop())
					SF1->(MsSeek(cFilSF1 + SF3->F3_NFISCAL + SF3->F3_SERIE + SF3->F3_CLIEFOR + SF3->F3_LOJA))			
		
					dbSelectArea("SD1")
					SD1->(dbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
					SD1->(dbgotop())
					SD1->(MsSeek(cFilSD1 + SF3->F3_NFISCAL + SF3->F3_SERIE + SF3->F3_CLIEFOR + SF3->F3_LOJA))
					While SD1->(!EOF()) .AND. SD1->D1_FILIAL = xFilial("SD1") .AND. SD1->D1_DOC = SF3->F3_NFISCAL .AND. SD1->D1_SERIE = SF3->F3_SERIE ;
										.AND. SD1->D1_FORNECE = SF3->F3_CLIEFOR .AND. SD1->D1_LOJA = SF3->F3_LOJA
						dbSelectArea("SB1")
						SB1->(dbSetOrder(4)) //B1_FILIAL+B1_GRUPO+B1_COD
						SB1->(MsSeek(cFilSB1 + SD1->D1_COD))								
		
						IF SB1->B1_TPCLAS = "B"
							cNpos := aposliv[aScan(aposliv,{|x| x[1] == 'RV0'})][2]	
							nval := fieldget(fieldpos('D1_VALIMP'+alltrim(cNpos))) 
							If SF1->F1_TXMOEDA <> "1"					
		                        TRA->VLRETBEN += xMoeda(nval, SF1->F1_MOEDA,"1",f1_emissao,5,SF1->F1_TXMOEDA)
							endIf
						End
						If SB1->B1_TPCLAS = "S"
							cNpos := aposliv[aScan(aposliv,{|x| x[1] == 'RV1'})][2]	
							nval := fieldget(fieldpos('D1_VALIMP'+alltrim(cNpos))) 	
							If SF1->F1_TXMOEDA <> "1"					
		                        TRA->VLRETSER += xMoeda(nval, SF1->F1_MOEDA,"1",f1_emissao,5,SF1->F1_TXMOEDA)
							endIf
						End
						SD1->(dbSkip())
					endDo
				endIF
	       	    if cTpnf = "RIR"
					aAIR:={}			
					dbSelectArea("SFE")
					SFE->(dbSetOrder(4)) //FE_FILIAL+FE_FORNECE+FE_LOJA+FE_NFISCAL+FE_SERIE+FE_TIPO+FE_CONCEPT
					SFE->(dbgotop())
					SFE->(MsSeek(cFilSFE + NF1->CLIEFOR + NF1->LOJA + NF1->NFISCAL + NF1->SERIE))
					While SFE->(!EOF()) .AND. SFE->FE_FILIAL  = xFilial("SFE") .AND. SFE->FE_FORNECE = NF1->CLIEFOR  ; 
			    	                    .AND. SFE->FE_LOJA    = NF1->LOJA      .AND. SFE->FE_NFISCAL = NF1->NFISCAL  ;
	         		                    .AND. PADR(SFE->FE_SERIE,3)	  = NF1->SERIE
						iF SFE->FE_TIPO	= 	"R"
							nLop := ascan(aAIR,{|x| x[1] == SFE->FE_CONCEPT})				
			    	        if nLop == 0
				    			aadd(aAIR,{SFE->FE_CONCEPT,SFE->FE_VALBASE,SFE->FE_ALIQ,SFE->FE_RETENC,SFE->FE_NROCERT,SFE->FE_NUMAUT,SFE->FE_EMISSAO})
							Else	
						        aAIR[nLop][2] += aAIR[nLop][2] + SFE->FE_VALBASE
						        aAIR[nLop][4] += aAIR[nLop][4] + SFE->FE_RETENC		
							endIf		         
						EndIf 			
						SFE->(dbskip())
					enddo 
					for ncont := 1 to len(aAir)
						TRA->CDRETAIR   :=  aAir[ncont][1]
						TRA->BASRETAIR  := 	aAir[ncont][2]
						TRA->ALQRETAIR  := 	aAir[ncont][3]
						TRA->VALRETAIR  := 	aAir[ncont][4]
				    next ncont					
				endif
			endIf
			SF3->(dbSkip())
		endDo  
		dbSelectArea("SFE")
		SFE->(dbSetOrder(4)) //FE_FILIAL+FE_FORNECE+FE_LOJA+FE_NFISCAL+FE_SERIE+FE_TIPO+FE_CONCEPT
		SFE->(dbgotop())
		SFE->(MsSeek(cFilSFE+NF1->CLIEFOR+NF1->LOJA+NF1->NFISCAL+NF1->SERIE))
		While SFE->(!EOF()) .AND. SFE->FE_FILIAL  = cFilSFE        .AND. SFE->FE_FORNECE = NF1->CLIEFOR  ; 
    	                    .AND. SFE->FE_LOJA    = NF1->LOJA      .AND. SFE->FE_NFISCAL = NF1->NFISCAL  ;
   		                    .AND. SFE->FE_SERIE	  = NF1->SERIE
			iF SFE->FE_TIPO	=  substr(cTpNF,1,1)
				TRA->ESTRET1	:=  substr(SFE->FE_NROCERT,1,3)
				TRA->PTEMRET1   :=  substr(SFE->FE_NROCERT,4,3)
				TRA->SEQRET1    :=  substr(SFE->FE_NROCERT,7,7)
				TRA->AUTRET1	:=  SFE->FE_NUMAUT
				TRA->DTEMRET1	:=	SFE->FE_EMISSAO
				TRA->DOCMOD     := Iif (SFE->FE_ESPECIE $ "NCP|NCI","23","0")
				if TRA->DOCMOD = "0"
					TRA->DOCMOD 	:= Iif(SFE->FE_ESPECIE $ "NDP|NDI","24","0")
    			endif
				TRA->ESTMOD    	:= Iif (SFE->FE_ESPECIE $ "NCP|NCI|NDP|NDI",substr(SFE->FE_NROCERT,1,3),"000")
				TRA->PTEMMOD	:= Iif (SFE->FE_ESPECIE $ "NCP|NCI|NDP|NDI",substr(SFE->FE_NROCERT,4,3),"000")
				TRA->SEQMOD     := Iif (SFE->FE_ESPECIE $ "NCP|NCI|NDP|NDI",substr(SFE->FE_NROCERT,7,7),"0")
				TRA->AUTMOD     := Iif (SFE->FE_ESPECIE $ "NCP|NCI|NDP|NDI",TRA->AUTRET1,"000") 
			endif
			SFE->(DbSkip())	
		enddo	
		TRA->ESTRET2	:= "000"
		TRA->PTEMRET2   := "000"
		TRA->SEQRET2    := "0"
		TRA->AUTRET2	:= "000"
		TRA->DTEMRET2   := stod("00000000")
		MsUnlock()
	EndIf
	NF1->(DbSkip())
EndDo
NF1->(DbCloseArea())

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LFeqXMLanV   ³ Autor ³Nilton (Onsten)     ³ Data ³ 15.07.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Extrai arquivo de trabalho (NF Saidas) para uso no INI de    ³±±
±±³          ³geração de arq. magneticos (XML) com impostos IVA, ICE, IR e ³±±
±±³          ³ Retenção de IVA 									   		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
*/

Function LFeqXMLanV (cDtIni, cDtfim)

Local aCampos	:= {}
Local aCpLivr	:= {}
Local aPosLiv	:= {}
// controle de quebra de acumulado
Local cQbFIL    := ""
Local cQbCLI    := ""
Local cQbLOJA   := ""
Local cQbSERIE  := ""
Local cQbESP    := ""
Local cTpComp   := ""
Local oTmpTable:= Nil
Local oTmpTabDet:= Nil
Local aOrdem 	:= {}
Local aCampDet	:= {}
Local aTabelas	:= {}
Local aInfo		:= {}
Local cFilEm	:= ""
Local nX		:= 0
Local cIvaComp	:= SuperGetMv("MV_IVACOMP",.F.,"") 
Local cLibICE	:= SuperGetMv("MV_LIBICE",.F.,"")
Local aIvaComp	:= {}
Local aLibICE	:= {}
Local nTotVen	:= 0
Local aBasImp	:= {}
Local cNumSuc	:= 0
Local lTpoCom   := SF2->(ColumnPos( "F2_TIPOPE" )) > 0
Local lTpDoc	:= SF2->(ColumnPos( "F2_TPDOC" )) > 0 
Local lCposExp	:= (SF2->(ColumnPos( "F2_TPACTIV" )) > 0)
Local cFilSA1	:= xFilial("SA1")
Local cFilAI0	:= xFilial("AI0")
Local nTotRIVAC := 0 //Total de Retenciones de IVA por Cliente
Local nTotRIRC  := 0 //Total de Retenciones de IR por Cliente
Local cCliAt	:= ""
Local cTCoAt	:= ""
Local cLojAt	:= ""
Local lFormCbr	:= .F.

LFilEmp (@aTabelas, @ainfo)

cNumSuc := Padl(Alltrim(Str(Len(aTabelas))), 3, "0")

DbSelectArea("SX3")
SX3->(DbSetOrder(1))
SX3->(MsSeek("SD2"))
While ! SX3->(Eof()) .And. (SX3->X3_ARQUIVO == "SD2")
	If Alltrim(SX3->X3_CAMPO) = "D2_BASIMP"
		aAdd(aBasImp, SX3->X3_CAMPO)
	EndIf
	SX3->(DbSkip())
EndDo

AADD(aCampDet,{"CODEST"	,"C",003,0})   
AADD(aCampDet,{"VENEST"	,"N",015,0})
AADD(aCampDet,{"IVAEST"	,"N",015,0})

oTmpTabDet := FWTemporaryTable():New("TRV")
oTmpTabDet:SetFields( aCampDet )
oTmpTabDet:AddIndex("I1", {"CODEST"})
oTmpTabDet:Create()

DbSelectArea("TRV")
TRV->(DbGoTop())

For nX := 1 To Len(aTabelas)
	RecLock("TRV",.T.)
	TRV->CODEST := aTabelas[nX][1]
	TRV->VENEST := 0
	TRV->IVAEST := 0
	MsUnlock()
Next nX

dbSelectArea("SFB")
SFB->(dbSetOrder(1)) //FB_FILIAL+FB_CODIGO
SFB->(dbgotop())
SFB->(MsSeek(xFilial("SFB"),.T.))
While SFB->(!EOF()) 
	aadd(aPosLiv,{SFB->FB_CODIGO,SFB->FB_CPOLVRO})
	SFB->(DbSkip())	
endDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criação do arquivo de trabalho
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

AADD(aCampos,{"CLIEFOR"	,"C",006,0})
AADD(aCampos,{"ESPECIE"	,"C",002,0})
AADD(aCampos,{"CODESP"	,"C",002,0})
AADD(aCampos,{"CDCGC"	,"C",015,0})
AADD(aCampos,{"TIPDOC"  ,"C",002,0})
AADD(aCampos,{"QTDNF"	,"N",005,0})
AADD(aCampos,{"EXENTAS"	,"N",013,2})
AADD(aCampos,{"ALQZERO"	,"N",013,2})
AADD(aCampos,{"ALQNOZER","N",013,2})
AADD(aCampos,{"VALIMP"	,"N",013,2})
AADD(aCampos,{"VALICE"	,"N",013,2})
AADD(aCampos,{"IVARET"	,"N",013,2})
AADD(aCampos,{"VALIRR"	,"N",013,2})
AADD(aCampos,{"FILIAL"	,"C",012,0})
AADD(aCampos,{"LOJA"	,"C",002,0})
AADD(aCampos,{"SERIE"	,"C",005,0})
AADD(aCampos,{"NFISCAL" ,"C",015,0})
AADD(aCampos,{"FORPAGO" ,"C",002,0})
AADD(aCampos,{"TIPCLIE"	,"C",002,0})
AADD(aCampos,{"DENOCLI"	,"C",500,0})
If SF2->(ColumnPos("F2_MODTRAD")) > 0 // Forma Cobro
	lFormCbr := .T.  
EndIf

oTmpTable := FWTemporaryTable():New("TRB") 
oTmpTable:SetFields( aCampos ) 
aOrdem	:=	{"CLIEFOR","ESPECIE"} 
oTmpTable:AddIndex("I1", aOrdem) 
oTmpTable:Create() 

DbSelectArea("TRB")

cQry:=" SELECT F3.F3_FILIAL FILIAL, F3.F3_CLIEFOR CLIEFOR, F3.F3_LOJA LOJA, F3.F3_NFISCAL NFISCAL, F3.F3_SERIE SERIE, F3.F3_ESPECIE ESPECIE , "
cQry+=" SUM(1) QTDNF , SUM(F3_EXENTAS) EXENTAS, SUM( CASE F3.F3_ALQIMP"+alltrim(aposliv[aScan(aposliv,{|x| x[1] == 'IVA'})][2])+" WHEN 0 THEN "
cQry+=" F3_BASIMP"+alltrim(aposliv[aScan(aposliv,{|x| x[1] == 'IVA'})][2])+" ELSE 0 END) ALQZERO, "
cQry+=" SUM( CASE F3_ALQIMP"+alltrim(aposliv[aScan(aposliv,{|x| x[1] == 'IVA'})][2])+" WHEN 0 THEN 0 ELSE 
cQry+=" F3_BASIMP"+alltrim(aposliv[aScan(aposliv,{|x| x[1] == 'IVA'})][2])+" END) ALQNOZER , "
cQry+=" SUM(F3_VALIMP"+alltrim(aposliv[aScan(aposliv,{|x| x[1] == 'IVA'})][2])+") VALIMP, 
cQry+=" SUM(F3_VALIMP"+alltrim(aposliv[aScan(aposliv,{|x| x[1] == 'RV0'})][2])+"+ "
cQry+=" F3_VALIMP"+alltrim(aposliv[aScan(aposliv,{|x| x[1] == 'RV1'})][2])+"+ "
cQry+=" F3_VALIMP"+alltrim(aposliv[aScan(aposliv,{|x| x[1] == 'RV2'})][2])+") IVARET, "
cQry+=" SUM(F3_VALIMP"+alltrim(aposliv[aScan(aposliv,{|x| x[1] == 'RIR'})][2])+") VALIRR "
If lTpoCom
	cQry+=",F2.F2_TIPOPE TIPOPE"
EndIf
If lFormCbr
	cQry+=", F2.F2_MODTRAD FORMCRB "
EndIf
cQry+=" FROM " + RetSqlName("SF3") + " F3 "
If lTpoCom
	cQry+=" INNER JOIN " + RetSqlName("SF2") + " F2 ON "
	cQry+="F3.F3_FILIAL = F2.F2_FILIAL AND F3.F3_NFISCAL = F2.F2_DOC AND F3.F3_SERIE = F2.F2_SERIE AND F3.F3_CLIEFOR = F2.F2_CLIENTE AND F3.F3_LOJA = F2.F2_LOJA"
EndIf
cQry+=" WHERE F3_EMISSAO >= '"+cDtIni+"' AND F3_EMISSAO <= '"+cDtfim+"' AND F3_TIPOMOV = 'V' AND F3.D_E_L_E_T_ = ' '"
If  lTpDoc
	cQry+=" AND (F2_TPDOC != '01') "
EndIf
If lCposExp
	cQry+=" AND (F2_TPACTIV != 'S') "
EndIf
cQry+=" GROUP BY F3.F3_FILIAL , F3.F3_CLIEFOR , F3.F3_LOJA , F3.F3_NFISCAL , F3.F3_SERIE , F3.F3_ESPECIE "
If lTpoCom
	cQry+=" , F2.F2_TIPOPE"
EndIf
If lFormCbr
	cQry+=" , F2.F2_MODTRAD "
EndIf

//Retención de Cobros

cQry += GXMLRetSEL(SD2->D2_LOJA,cDtIni,cDtfim)
cQry += " ORDER BY FILIAL, CLIEFOR,  ESPECIE, LOJA, NFISCAL, SERIE  "

ChangeQuery(cQry)
dbUseArea(.T.,'TOPCONN',TcGenQry(,,Alltrim(cQry)),'NFV',.F.,.T.)

DbSelectArea("NFV")
NFV->(DbGoTop())
While NFV->(!EOF())
        If NFV->FILIAL <> cQbFIL .OR. NFV->CLIEFOR <> cQbCLI .OR. NFV->LOJA <> cQbLOJA .OR. ;
		   NFV->SERIE <> cQbSERIE .OR. NFV->ESPECIE <> cQbESP .OR. IIf(lTpoCom,NFV->TIPOPE <> cTpComp,.T.)
			If cQbCLI <> ' '
			   msunlock()
            endIf
			RecLock("TRB",.T.)
			cQbFIL     	:= NFV->FILIAL
			cQbCLI    	:= NFV->CLIEFOR 
			cQbLOJA 	:= NFV->LOJA
			cQbSERIE	:= NFV->SERIE
			cQbESP		:= NFV->ESPECIE
			If lTpoCom
				cTpComp := NFV->TIPOPE 
			Endif
			TRB->FILIAL	:= NFV->FILIAL
			TRB->CLIEFOR:= NFV->CLIEFOR 
			TRB->LOJA	:= NFV->LOJA
			TRB->SERIE	:= NFV->SERIE
			TRB->NFISCAL:= NFV->NFISCAL
			
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
			SA1->(MsSeek(cFilSA1+NFV->CLIEFOR+NFV->LOJA))
			TRB->TIPDOC		:= SA1->A1_TIPDOC
			TRB->CDCGC		:= SA1->A1_CGC
			TRB->TIPCLIE	:= "0"+SA1->A1_TIPO
			TRB->DENOCLI	:= AllTrim(SA1->A1_NOME)
			If lFormCbr
				If !Empty(NFV->FORMCRB)
					TRB->FORPAGO := NFV->FORMCRB
				Else
					TRB->FORPAGO := IIF(!Empty(SA1->A1_COND), GERXMLAFRC(SA1->A1_COND),"")	
				EndIf
			EndIf
			dbselectarea("SF2")
			SF2->(dbsetorder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
			SF2->(dbgotop())
			SF2->(MsSeek(NFV->FILIAL + NFV->NFISCAL + NFV->SERIE + NFV->CLIEFOR + NFV->LOJA))
			If substr(NFV->ESPECIE,1,2) == "NF"
				If lTpoCom
					If !Empty(TRB->ESPECIE)
						TRB->ESPECIE := "18"
					Else 
						TRB->ESPECIE := AllTrim(SF2->F2_TIPOPE)
					EndIf
				Else	
					TRB->ESPECIE := "18"
				EndIf				
			ElseIf substr(NFV->ESPECIE,1,2) == "NC"
				TRB->ESPECIE 	:= "04"			
			ElseIf substr(NFV->ESPECIE,1,2) == "ND"			
				TRB->ESPECIE 	:= "05"				
			ElseIF NFV->ESPECIE ==	"NV"
				If SF2->F2_RG <> ' '
					TRB->CDCGC	:=	SF2->F2_RG
					TRB->TIPDOC :=  '05'
				Else
				    If SA1->A1_CGC = ' '
				    	TRB->CDCGC	= '9999999999999'
				    	TRB->TIPDOC = '07'
				    EndIf				
				EndIf
			EndIf
			DBSelectArea("SD2")
			SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			SD2->(MsSeek(NFV->FILIAL + NFV->NFISCAL + NFV->SERIE + NFV->CLIEFOR + NFV->LOJA))
			While SD2->(!EOF()) .AND. SD2->D2_FILIAL = NFV->FILIAL .AND. SD2->D2_DOC = NFV->NFISCAL ; 
    	                    .AND. SD2->D2_SERIE = NFV->SERIE .AND. SD2->D2_CLIENTE = NFV->CLIEFOR ;
   		                    .AND. SD2->D2_LOJA = NFV->LOJA
				If !Empty(cLibICE)
					aLibICE := StrTokArr(cLibICE, "|")
					For nX := 1 To Len(aLibICE)
						TRB->VALICE += SD2->&("D2_VALIMP" + Alltrim(aLibICE[nX]))
					Next nX
				EndIf
				For nX := 1 To Len(aBasImp)
					nTotVen += SD2->&(aBasImp[Nx])
				Next nX
				SD2->(DbSkip())
			EndDo
			For nX := 1 To Len(aTabelas)
				If NFV->FILIAL $ aTabelas[nX][2]
					Exit
				EndIf
			Next nX
			DbSelectArea("AI0")
			AI0->(DbSetOrder(1))//AI0_FILIAL+AI0_CODCLI+AI0_LOJA
			AI0->(MsSeek(cFilAI0 + NFV->CLIEFOR + NFV->LOJA))
			If !lFormCbr // Forma Cobro
				TRB->FORPAGO := AI0->AI0_MPAGO
			EndIf
			TRV->(MsSeek(aTabelas[nX][1]))
			RecLock("TRV",.F.)
			For nX := 1 To Len(aBasImp)
				TRV->VENEST += SF2->&("F2_BASIMP" + RIGHT(aBasImp[nX],1))
			Next nX
			If !Empty(cIvaComp)
				aIvaComp := StrTokArr(cIvaComp, "|")
				For nX := 1 To Len(aIvaComp)
					TRV->IVAEST += SF2->&("F2_VALIMP" + Alltrim(aIvaComp[nX]))
				Next nX
			EndIf
			MsUnlock()
		Endif			
	    TRB->QTDNF			+= NFV->QTDNF
	    TRB->EXENTAS		+= NFV->EXENTAS
		TRB->ALQZERO		+= NFV->ALQZERO
		TRB->ALQNOZER		+= NFV->ALQNOZER
		TRB->VALIMP			+= NFV->VALIMP
		TRB->IVARET			+= NFV->IVARET
		TRB->VALIRR			+= NFV->VALIRR

		If NFV->CLIEFOR == cCliAt .And. NFV->LOJA == cLojAt .And. SubStr(NFV->ESPECIE,1,3) == cTCoAt 
			nTotRIVAC := 0
			nTotRIRC  := 0
		Else
			GXMLObtIVC(NFV->CLIEFOR, NFV->LOJA,cDtIni,cDtfim, Substr(NFV->ESPECIE,1,3),@nTotRIVAC,@nTotRIRC) // obtiene el IVA e IR relacionado al cliente
		EndIf
		cCliAt	:= NFV->CLIEFOR
		cTCoAt	:= SubStr(NFV->ESPECIE,1,3)
		cLojAt	:= NFV->LOJA

		NFV->(dbSkip())
		TRB->IVARET := TRB->IVARET + nTotRIVAC
		TRB->VALIRR := TRB->VALIRR + nTotRIRC
EndDo
If cQbCLI <> ' '
   msunlock()
endIf
		      
NFV->(DbCloseArea())

return {nTotVen, cNumSuc}

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LFeqXMLcan   ³ Autor ³Nilton (Onsten)     ³ Data ³ 15.07.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Extrai arquivo de trabalho (nf Canceladas) para uso no INI de³±±
±±³          ³geração de arq. magneticos (XML) 					   		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
*/

Function LFeqXMLcan (cDtIni, cDtfim)

Local aCampos	:= {}
Local aCpLivr	:= {}
Local aPosLiv	:= {}      
Local aespecie	:= {}
Local aNf		:= {}
Local cFlag		:= ""
Local cNfiscal
Local nCont
Local oTmpTable := Nil
Local aOrdem	:= {}

aadd(aespecie, {"NF ","1"})
aadd(aespecie, {"NCI","2"})
aadd(aespecie, {"NDI","3"})
aadd(aespecie, {"NCP","4"})
aadd(aespecie, {"NDP","5"}) 
aadd(aespecie, {"RIR","6"})
aadd(aespecie, {"ICE","7"})
aadd(aespecie, {"IVA","8"})

AADD(aCampos,{"TIPDOC"  ,"C",002,0})
AADD(aCampos,{"ESTAB"	,"C",003,0})
AADD(aCampos,{"PTEMIS"	,"C",003,0})
AADD(aCampos,{"SEQINI"	,"C",009,0})
AADD(aCampos,{"SEQFIM"	,"C",009,0})
AADD(aCampos,{"AUTORIZ"	,"C",010,0})

If oTmpTable <> Nil
	oTmpTable:Delete()
	oTmpTable:=Nil
EndIf

oTmpTable := FWTemporaryTable():New("TRC") 
oTmpTable:SetFields( aCampos )
aOrdem	:=	{"TIPDOC","ESTAB","PTEMIS"} 
oTmpTable:AddIndex("I1", aOrdem) 
oTmpTable:Create()
	 
DbSelectArea("TRC")


cQry:=" SELECT F3.F3_FILIAL FILIAL, F3.F3_CLIEFOR CLIEFOR, F3.F3_LOJA LOJA, F3.F3_NFISCAL NFISCAL, F3.F3_SERIE SERIE, F3.F3_ESPECIE ESPECIE "
cQry+=" FROM "+RetSqlName("SF3")+" F3 WHERE D_E_L_E_T_ = '*' AND F3_DTCANC >= '"+cDtini+"' AND F3_DTCANC <= '"+cDtfim+"'" 
cQry+=" GROUP BY F3.F3_FILIAL , F3.F3_CLIEFOR , F3.F3_LOJA , F3.F3_NFISCAL , F3.F3_ESPECIE, F3.F3_SERIE  "
cQry+=" ORDER BY F3.F3_FILIAL , F3.F3_CLIEFOR , F3.F3_LOJA , F3.F3_NFISCAL , F3.F3_ESPECIE, F3.F3_SERIE  "

ChangeQuery(cQry)
dbUseArea(.T.,'TOPCONN',TcGenQry(,,Alltrim(cQry)),'NFC',.F.,.T.)


DbSelectArea("NFC")
DBGOTOP()                                                  
While NFC->(!EOF())
		cFlag := ""		
		for nCont = 1 to len(aNf)
			if NFC->FILIAL = aNf[nCont][1] .AND. NFC->CLIEFOR = aNf[nCont][2] .AND. NFC->LOJA = aNf[nCont][3] .AND. substr(NFC->NFISCAL,1,3) = aNf[nCont][4] ;
			   .AND. substr(NFC->NFISCAL,3,3) = aNf[nCont][4] .AND. substr(NFC->NFISCAL,7,7) - 1 = aNf[nCont][6]
			   aNf[nCont][6] := substr(NFC->NFISCAL,7,7)
			   cFlag := "1"
			endIf
		next nCont
		if cFlag = ""
			aadd(aNf, {NFC->FILIAL,NFC->CLIEFOR,NFC->LOJA,substr(NFC->NFISCAL,1,3),substr(NFC->NFISCAL,4,3),substr(NFC->NFISCAL,7,7),substr(NFC->NFISCAL,7,7),NFC->SERIE,NFC->ESPECIE})
		endIf
		NFC->(DBSKIP())
endDo

for nCont = 1 to len(aNf)
    RecLock("TRC",.T.)
	If alltrim(substr(aNf[nCont][9],1,2)) == "NF"
		TRC->TIPDOC 	:= "01"
	ElseIf alltrim(substr(aNf[nCont][9],1,2)) == "NC"
		TRC->TIPDOC 	:= "04"			
	ElseIf alltrim(substr(aNf[nCont][9],1,2)) == "ND"			
		TRC->TIPDOC 	:= "05"				
	Else
		TRC->TIPDOC 	:= "07"
	EndIf
	TRC->ESTAB		:=	aNf[nCont][4]
	TRC->PTEMIS		:=	aNf[nCont][5]
	TRC->SEQINI  	:=	aNf[nCont][6]
	TRC->SEQFIM  	:=	aNf[nCont][7]
	cNfiscal		:= aNf[nCont][4]+aNf[nCont][5]+aNf[nCont][6]
	dbSelectArea("SFP")
	dbSetOrder(5)
	cEspecie := ascan(aEspecie,{|x| x[1] == PADR(aNf[nCont][9],3)})  
	SFP->(dbSeek(xFilial("SFP")+aNf[nCont][1]+PADR(aNf[nCont][8],3)+iIf (cespecie > 0,aespecie[cEspecie][2]," ")))
	If VAL(cNfiscal)	>= 	VAL(SFP->FP_NUMINI)	.AND. VAL(cNfiscal)	<=	VAL(SFP->FP_NUMFIM) 
		TRC->AUTORIZ        := SFP->FP_NUMAUT
	EndIf 
	MsUnlock()
next nCont

dbclosearea()     

TRelAN1()

return       



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TRelAN1  ºAutor  ³ Nilton MK          º Data ³  02/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relatorio para conferencia dos dados para devolução de IVA  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                 Equador                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TRelAN1()

	Local oReport

	If TRepInUse()
		oReport := TRelAN1DeF()
		oReport:PrintDialog()	
	EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TRelAN1DeF	ºAutor  ³ Nilton MK          º Data ³  02/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³               DEFINE O RELATORIO                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³              Livro fiscal de entrada                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TRelAN1DeF()

	Local oReport
	Local oSection1	:= Nil
	Local oSection2	:= Nil
	Local oSection3	:= Nil
	Local oSection4	:= Nil
	Local lSecExp	:= (SF2->(ColumnPos( "F2_TPACTIV" )) > 0)

	If Type('lVenExpor') == "U"
		Private lVenExpor := .F.
	EndIf
	oReport := TReport():New("TRelIR",STR0001,,{|oReport| PrTRepAN1(oReport)},STR0002)//"Anexo 1 Transaccional" ## "Anexo Devolução de IVA"

	oReport:SetLandScape(.T.)


	//SECAO1 - Detalhe Das notas de compras
	oSection1 := TRSection():New(oReport,STR0003,{"TRA"})//"Detalle Compras"
	TRCell():New(oSection1,"codsustento"    	,,,,25,.F.)
	TRCell():New(oSection1,"TpIdProv"       	,,,,25,.F.)
	TRCell():New(oSection1,"IdProv"   			,,,,25,.F.)
	TRCell():New(oSection1,"TipoComprobante"	,,,,25,.F.)
	TRCell():New(oSection1,"FechaRegist"    	,,,,25,.F.)
	TRCell():New(oSection1,"Estab"          	,,,,25,.F.)	
	TRCell():New(oSection1,"PtoEmi"         	,,,,25,.F.)	
	TRCell():New(oSection1,"Sec"     			,,,,25,.F.)
	TRCell():New(oSection1,"Emision"  			,,,,25,.F.)	
	TRCell():New(oSection1,"Autorizacion"   	,,,,25,.F.)	
	TRCell():New(oSection1,"BaseImponibleIVA"	,,,,25,.F.)	
	TRCell():New(oSection1,"BaseAliqZero"  		,,,,25,.F.)	
	TRCell():New(oSection1,"BaseAliqNOZer" 		,,,,25,.F.)	
	TRCell():New(oSection1,"MontoICE"	   		,,,,25,.F.)	
	TRCell():New(oSection1,"MontoIVA"	   		,,,,25,.F.)	
	TRCell():New(oSection1,"RetIVABienes"   	,,,,25,.F.)	
	TRCell():New(oSection1,"RetIVAServicios"   	,,,,25,.F.)	
	TRCell():New(oSection1,"RetIVA100%"   		,,,,25,.F.)	
	TRCell():New(oSection1,"conceptAIR"   		,,,,25,.F.)	
	TRCell():New(oSection1,"BaseImpAIR"   		,,,,25,.F.)		
	TRCell():New(oSection1,"AliqImpAIR"   		,,,,25,.F.)		
	TRCell():New(oSection1,"ValRetAir"   		,,,,25,.F.)		
	TRCell():New(oSection1,"Estabelec"   		,,,,25,.F.)		
	TRCell():New(oSection1,"PuntoEmis"   		,,,,25,.F.)		
	TRCell():New(oSection1,"Secuencia"   		,,,,25,.F.)		
	TRCell():New(oSection1,"Autorizacion"   	,,,,25,.F.)		
	TRCell():New(oSection1,"FechaEmisCERT"   	,,,,25,.F.)		
	TRCell():New(oSection1,"DocModific"   		,,,,25,.F.)		
	TRCell():New(oSection1,"EstabDOC"   		,,,,25,.F.)		
	TRCell():New(oSection1,"PuntoDOC"   		,,,,25,.F.)		
	TRCell():New(oSection1,"SecDOC"   			,,,,25,.F.)		
	TRCell():New(oSection1,"AutorDOC"   		,,,,25,.F.)	 

	//Detales das notas de vendas
	oSection2 := TRSection():New(oReport,STR0004,{"TRB"})//"Detalhe Vendas"
	TRCell():New(oSection2,"Tp Id Cliente"  ,,,,25,.F.)	
	TRCell():New(oSection2,"Id Cliente"  	,,,,25,.F.)	
	TRCell():New(oSection2,"Tipo Comprov."  ,,,,25,.F.)	
	TRCell():New(oSection2,"Nr.Comprov."	,,,,25,.F.)
	TRCell():New(oSection2,"Base No Obj.IVA",,,,25,.F.)
	TRCell():New(oSection2,"Base Aliq 0 "   ,,,,25,.F.)	
	TRCell():New(oSection2,"Base Aliq > 0"  ,,,,25,.F.)	
	TRCell():New(oSection2,"Monto IVA"		,,,,25,.F.)	
	TRCell():New(oSection2,"Valor Ret IVA"  ,,,,25,.F.)	
	TRCell():New(oSection2,"Val. IR Retido" ,,,,25,.F.)	

	//Detales das notas canceladas
	oSection3 := TRSection():New(oReport,STR0005,{"TRC"})//"Detalhe Anulados"
	TRCell():New(oSection3,"Tp Comprov"	,,,,25,.F.)	
	TRCell():New(oSection3,"Establec"  	,,,,25,.F.)	
	TRCell():New(oSection3,"Punto Emis" ,,,,25,.F.)	
	TRCell():New(oSection3,"Seq. Inic."	,,,,25,.F.)
	TRCell():New(oSection3,"Seq. Final"	,,,,25,.F.)
	TRCell():New(oSection3,"Autoriz"   	,,,,25,.F.)	

	If lSecExp .and. lVenExpor
		//Detales das notas de exportación
		oSection4 := TRSection():New(oReport,STR0006,{"TEX"})//"Detalhe Exportación"
		TRCell():New(oSection4,"Tp Id Cliente"	,,,,10,.F.)
		TRCell():New(oSection4,"Id Cliente"		,,,,20,.F.)
		TRCell():New(oSection4,"Parte Rel"		,,,,10,.F.)
		TRCell():New(oSection4,"Tp Clie"		,,,,10,.F.)
		TRCell():New(oSection4,"Tp Regi"		,,,,10,.F.)
		TRCell():New(oSection4,"Pais Pago"		,,,,10,.F.)
		TRCell():New(oSection4,"Pais Par Fis"	,,,,20,.F.)
		TRCell():New(oSection4,"PaisEfecExp"	,,,,10,.F.)
		TRCell():New(oSection4,"Export De"		,,,,10,.F.)
		TRCell():New(oSection4,"Tp Ing Ext"		,,,,10,.F.)
		TRCell():New(oSection4,"Ing Ext Grav"	,,,,10,.F.)
		TRCell():New(oSection4,"Imp Otro Pais"	,,,,20,.F.)
		TRCell():New(oSection4,"Tp Comprobante"	,,,,10,.F.)
		TRCell():New(oSection4,"Dist Aduanero"	,,,,10,.F.)
		TRCell():New(oSection4,"Ref Regimen"	,,,,10,.F.)
		TRCell():New(oSection4,"Ref Correla"	,,,,25,.F.)
		TRCell():New(oSection4,"Doc Transporte"	,,,,25,.F.)
		TRCell():New(oSection4,"Val FOB Comp"	,,,,20,.F.)
		TRCell():New(oSection4,"Establecim."	,,,,20,.F.)
		TRCell():New(oSection4,"Pto Emision"	,,,,10,.F.)
		TRCell():New(oSection4,"Secuencial"		,,,,25,.F.)
		TRCell():New(oSection4,"Autorizacion"	,,,,25,.F.)
		TRCell():New(oSection4,"Fch Emision"	,,,,25,.F.)
	EndIf

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PrTRepAN1ºAutor ³Nilton  SServices   º Data ³  26/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Relatorio de conferencia de apoio a geração de XML ao DIMMº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Funcao oReport                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrTRepAN1(oReport)

	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)	
	Local oSection3 := oReport:Section(3)
	Local oSection4 := oReport:Section(4)
	Local lSecExp	:= (SF2->(ColumnPos( "F2_TPACTIV" )) > 0)	
		
	If Type('lVenExpor') == "U"
		Private lVenExpor := .F.
	EndIf
	oReport:PrintText(STR0007,(oReport:Row()),700,CLR_RED) //"Relación de Notas para conferencia XML para anexo 1 (Transaccional) - Compras"
    oReport:IncRow(050)
	oReport:PrintText(STR0008+SM0->M0_CGC,(oReport:Row()),700,CLR_RED) //"Ruc do contribuinte : "
    oReport:IncRow(050)
	oReport:PrintText(STR0009+Substr(dTOs(MV_PAR01),1,4),(oReport:Row()),700,CLR_RED)//"Ano Declaracao : "
    oReport:IncRow(050)
	oReport:PrintText(STR0010+Substr(dTOs(MV_PAR01),5,2),(oReport:Row()),700,CLR_RED)//"Mes Declaración : "
    oReport:IncRow(100)
	oReport:PrintText(STR0011,(oReport:Row()),700,CLR_RED) //"COMPRAS"
    oReport:IncRow(100)
      
	TRA->(dbGoTop())
	While TRA->(!EOF())		
		oReport:SetMeter(RecCount())	

		oSection1:Init() 	

		oReport:Section(1):Cell("codsustento"  		)	:SetBlock({|| TRA->CDSUSTEN})   	
		oReport:Section(1):Cell("TpIdProv"     		)	:SetBlock({|| TRA->TPLDPROV})   
		oReport:Section(1):Cell("IdProv"       		)	:SetBlock({|| TRA->IDPROV})   
		oReport:Section(1):Cell("TipoComprobante"	)	:SetBlock({|| TRA->TPCOMPRO})   
		oReport:Section(1):Cell("FechaRegist"  		)	:SetBlock({|| TRA->DTFECH}) 
		oReport:Section(1):Cell("Estab"        		)	:SetBlock({|| TRA->ESTABEL})  
		oReport:Section(1):Cell("PtoEmi"       		)	:SetBlock({|| TRA->PTEMIS  })  
		oReport:Section(1):Cell("Sec"          		)	:SetBlock({|| TRA->SEQUENC })  
		oReport:Section(1):Cell("Emision"	   		)	:SetBlock({|| TRA->DTEMISS })  
		oReport:Section(1):Cell("Autorizacion" 		)	:SetBlock({|| TRA->AUTORIZ })  
		oReport:Section(1):Cell("BaseImponibleIVA"	)	:SetBlock({|| TRA->BASNOGRV})  		
		oReport:Section(1):Cell("BaseAliqZero"    	)	:SetBlock({|| TRA->BASIMPON})  		
		oReport:Section(1):Cell("BaseAliqNOZer"		)	:SetBlock({|| TRA->BASIMPGR})  		
		oReport:Section(1):Cell("MontoICE"	   		)	:SetBlock({|| TRA->TOTALICE})  		
		oReport:Section(1):Cell("MontoIVA"	   		)	:SetBlock({|| TRA->TOTALIVA})  		
		oReport:Section(1):Cell("RetIVABienes"   	)	:SetBlock({|| TRA->VLRETBEN})  		
		oReport:Section(1):Cell("RetIVAServicios"   )	:SetBlock({|| TRA->VLRETSRV})  		
		oReport:Section(1):Cell("RetIVA100%"   		)	:SetBlock({|| TRA->RETIVA100})  		
		oReport:Section(1):Cell("conceptAIR"   		)	:SetBlock({|| TRA->CDRETAIR})  		
		oReport:Section(1):Cell("BaseImpAIR"   		)	:SetBlock({|| TRA->BASRETAIR})  			
		oReport:Section(1):Cell("AliqImpAIR"   		)	:SetBlock({|| TRA->ALQRETAIR})  				
		oReport:Section(1):Cell("ValRetAir"   		)	:SetBlock({|| TRA->VALRETAIR})  			
		oReport:Section(1):Cell("Estabelec"   		)	:SetBlock({|| TRA->ESTRET1})  				
		oReport:Section(1):Cell("PuntoEmis"   		)	:SetBlock({|| TRA->PTEMRET1})  			
		oReport:Section(1):Cell("Secuencia"   		)	:SetBlock({|| TRA->SEQRET1})  		
		oReport:Section(1):Cell("Autorizacion"   	)	:SetBlock({|| TRA->AUTRET1})  			
		oReport:Section(1):Cell("FechaEmisCERT"   	)	:SetBlock({|| TRA->DTEMRET1})  				
		oReport:Section(1):Cell("DocModific"   		)	:SetBlock({|| TRA->DOCMOD})  				
		oReport:Section(1):Cell("EstabDOC"   		)	:SetBlock({|| TRA->ESTMOD})  			
		oReport:Section(1):Cell("PuntoDOC"   		)	:SetBlock({|| TRA->PTEMMOD})  		
		oReport:Section(1):Cell("SecDOC"   			)	:SetBlock({|| TRA->SEQMOD})  		
		oReport:Section(1):Cell("AutorDOC"   		)	:SetBlock({|| TRA->AUTMOD})  			
			
		oSection1:Printline()				
	    oReport:IncRow(010)
		TRA->(dbSkip())
    End
	oSection1:Finish() 
	
    oReport:IncRow(100)
	oReport:PrintText(STR0012,(oReport:Row()),700,CLR_RED) //"VENTAS"
    oReport:IncRow(100)		    
	    
	TRB->(dbGoTop())
	While TRB->(!EOF())		
		oReport:SetMeter(RecCount())	

		oSection2:Init() 	

		oReport:Section(2):Cell("Tp Id Cliente"  	)	:SetBlock({|| TRB->TIPDOC})   	
		oReport:Section(2):Cell("Id Cliente"  		)	:SetBlock({|| TRB->CDCGC}) 	
		oReport:Section(2):Cell("Tipo Comprov."		)	:SetBlock({|| TRB->ESPECIE})   
		oReport:Section(2):Cell("Nr.Comprov."		)   :SetBlock({|| TRB->QTDNF}) 
		oReport:Section(2):Cell("Base No Obj.IVA"	)   :SetBlock({|| TRB->EXENTAS}) 		  
		oReport:Section(2):Cell("Base Aliq 0 " 		)	:SetBlock({|| TRB->ALQZERO})   
		oReport:Section(2):Cell("Base Aliq > 0"		)	:SetBlock({|| TRB->ALQNOZER}) 
		oReport:Section(2):Cell("Monto IVA"			)	:SetBlock({|| TRB->VALIMP})  
		oReport:Section(2):Cell("Valor Ret IVA"     )	:SetBlock({|| TRB->IVARET})  
		oReport:Section(2):Cell("Val. IR Retido"	)	:SetBlock({|| TRB->VALIRR}) 
		
		oSection2:Printline()				
	    oReport:IncRow(010)
		TRB->(dbSkip())
    End	    
	oSection2:Finish()
	
    oReport:IncRow(100)
	oReport:PrintText(STR0013,(oReport:Row()),700,CLR_RED)//"ANULADOS"
    oReport:IncRow(100)		    
	    
	TRC->(dbGoTop())
	While TRC->(!EOF())		
		oReport:SetMeter(RecCount())	

		oSection3:Init() 	

		oReport:Section(3):Cell("Tp Comprov" 	)	:SetBlock({|| TRC->TIPDOC})   	
		oReport:Section(3):Cell("Establec" 		)	:SetBlock({|| TRC->ESTAB})   	
		oReport:Section(3):Cell("Punto Emis"	)	:SetBlock({|| TRC->PTEMIS})   
		oReport:Section(3):Cell("Seq. Inic."	)   :SetBlock({|| TRC->SEQINI}) 
		oReport:Section(3):Cell("Seq. Final"	)   :SetBlock({|| TRC->SEQFIM}) 		  
		oReport:Section(3):Cell("Autoriz"  		)	:SetBlock({|| TRC->AUTORIZ})   
		
		oSection3:Printline()				
	    oReport:IncRow(010)
		TRC->(dbSkip())
    End	    
	oSection3:Finish()

	If lSecExp .and. lVenExpor
		oReport:IncRow(100)
		oReport:PrintText(STR0014,(oReport:Row()),700,CLR_RED)//"EXPORTACIÓN"
		oReport:IncRow(100)		    
			
		TEX->(dbGoTop())
		While TEX->(!EOF())		
			oReport:SetMeter(RecCount())	

			oSection4:Init() 	
			oReport:Section(4):Cell("Tp Id Cliente"	):SetBlock({|| TEX->TPIDCLIEXT})
			oReport:Section(4):Cell("Id Cliente"	):SetBlock({|| TEX->IDCLIEXT})
			oReport:Section(4):Cell("Parte Rel"		):SetBlock({|| TEX->PARTREL})
			oReport:Section(4):Cell("Tp Clie"		):SetBlock({|| TEX->TIPCLIE})
			oReport:Section(4):Cell("Tp Regi"		):SetBlock({|| TEX->TIPREGI})
			oReport:Section(4):Cell("Pais Pago"		):SetBlock({|| TEX->PEFEPAGGEN})
			oReport:Section(4):Cell("Pais Par Fis"	):SetBlock({|| TEX->PPAGPARFIS})
			oReport:Section(4):Cell("PaisEfecExp"	):SetBlock({|| TEX->PAISEFEEXP})
			oReport:Section(4):Cell("Export De"		):SetBlock({|| TEX->TPEXPING})
			oReport:Section(4):Cell("Tp Ing Ext"	):SetBlock({|| TEX->TPINGEXT})
			oReport:Section(4):Cell("Ing Ext Grav"	):SetBlock({|| TEX->INGEXTGAV})
			oReport:Section(4):Cell("Imp Otro Pais"	):SetBlock({|| TEX->IMPOTROPA})
			oReport:Section(4):Cell("Tp Comprobante"):SetBlock({|| TEX->TPCOMP})
			oReport:Section(4):Cell("Dist Aduanero"	):SetBlock({|| TEX->REFDISADUA})
			oReport:Section(4):Cell("Ref Regimen"	):SetBlock({|| TEX->REFREGIME})
			oReport:Section(4):Cell("Ref Correla"	):SetBlock({|| TEX->REFCORREL1})
			oReport:Section(4):Cell("Doc Transporte"):SetBlock({|| TEX->DOCTRANSP})
			oReport:Section(4):Cell("Val FOB Comp"	):SetBlock({|| TEX->VLFOBCOMP})
			oReport:Section(4):Cell("Establecim."	):SetBlock({|| TEX->NOSERCOMPR})
			oReport:Section(4):Cell("Pto Emision"	):SetBlock({|| TEX->PTOEMISION})
			oReport:Section(4):Cell("Secuencial"	):SetBlock({|| TEX->COMPRSECU})
			oReport:Section(4):Cell("Autorizacion"	):SetBlock({|| TEX->COMPRAUTOR})
			oReport:Section(4):Cell("Fch Emision"	):SetBlock({|| TEX->COMPFCHEMI})

			oSection4:Printline()				
			oReport:IncRow(010)
			TEX->(dbSkip())
		End	    
		oSection4:Finish()
	EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LFilEmp 	³ Autor ³Oscar                  ³ Data ³23/01/2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcion para obtencion de codigo de establecimiento, punto  ³±±
±±³          ³de emision y filiales de la empresa.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³      :                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 : Array para guardado de filiales por CodEst 	      ³±±
±±³          ³ExpA2 : Array para guardado de CodEst y PtoEmi por filial   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LFilEmp (aTabelas, aInfo)
	Local aAreaSM0	:= GetArea()
	Local aTmp		:= {}
	Local nX		:= 0
	Local nTemp		:= 0
	
	Default	aTabelas	:= {}
	Default	aInfo		:= {}
	
	DbSelectArea("SM0")
	SM0->(DbGoTop())
	While !SM0->( EOF() )
		If SM0->M0_CODIGO == cEmpAnt .And. !Empty(SM0->M0_DSCCNA)
			aAdd( aTmp, {LEFT(Alltrim(SM0->M0_DSCCNA),3), SM0->M0_CODFIL, SM0->M0_DSCCNA} )
		EndIf
		SM0->(DbSkip())
	End
	aInfo := aTmp
	For nX := 1 To Len(aTmp)
		nTemp := Ascan(aTabelas,{|x| x[1] == aTmp[nX,1]} )
		If nTemp == 0
			aAdd(aTabelas, {aTmp[nX][1],"'" + aTmp[nX][2] + "'"})
		Else
			aTabelas[nTemp][2] += ",'" + aTmp[nX][2] + "'"
		EndIf
	Next nX
	RestArea(aAreaSM0)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³RetIR 	³ Autor ³Luis/Oscar             ³ Data ³23/01/2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcion para calculo de Ret. de Imp. sobre la Renta e impor-³±±
±±³          ³tes de retencion de IVA al 10, 20 y 50%                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1 : linha em xml                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 : Filial del documento   				    	      ³±±
±±³          ³ExpC2 : Codigo de cliente                                   ³±±
±±³          ³ExpC3 : Codigo de tienda                                    ³±±
±±³          ³ExpC4 : Numero de documento                                 ³±±
±±³          ³ExpC5 : Serie de documento                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
Function RetIR (cFilDoc, cClie, cLoja, cDoc, cSer)
	Local cXml 		:= ""
	Local aAIR		:= {}
	Local nX		:= 0
	Local nBase10	:= 0
	Local nBase20	:= 0
	Local nBase30	:= 0
	Local nBase50	:= 0
	Local nBase70	:= 0
	Local nBase100	:= 0
	Local nBaseExe	:= 0
	Local aArea		:= GetArea("SM0")
	Local cLibExe	:= SuperGetMv("MV_LIBEXE",.F.,"")
	Local aLibExe	:= Iif(!Empty(cLibExe), StrTokArr( cLibExe, "|" ), {})
	Local lReten	:= .T.
	Local cSeq		:= ""
	
	cClie	:= SubStr(cClie	, 1, TamSX3("F3_CLIEFOR")[1])
	cLoja	:= SubStr(cLoja	, 1, TamSX3("F3_LOJA")[1])
	cDoc	:= SubStr(cDoc	, 1, TamSX3("F3_NFISCAL")[1])
	cSer	:= SubStr(cSer	, 1, TamSX3("F3_SERIE")[1])
	
	DbSelectArea("SFE")
	SFE->(DbSetOrder(4)) //FE_FILIAL+FE_FORNECE+FE_LOJA+FE_NFISCAL+FE_SERIE+FE_TIPO+FE_CONCEPT
	SFE->(DbGoTop())
	SFE->(MsSeek(cFilDoc + cClie + cLoja + cDoc + cSer)) 
	While SFE->(!EOF()) .And. SFE->FE_FILIAL  = cFilDoc    .And. SFE->FE_FORNECE = cClie  ;
	                    .And. SFE->FE_LOJA    = cLoja      .And. SFE->FE_NFISCAL = cDoc  ;
	                    .And. SFE->FE_SERIE	  = cSer
		If SFE->FE_TIPO	= "R"
			nLop := aScan(aAIR,{|x| x[1] == SFE->FE_CONCEPT})				
	        If nLop == 0
				aAdd(aAIR,{SFE->FE_CONCEPT,SFE->FE_VALBASE,SFE->FE_ALIQ,SFE->FE_RETENC})
			Else	
		        aAIR[nLop][2] += aAIR[nLop][2] + SFE->FE_VALBASE
		        aAIR[nLop][4] += aAIR[nLop][4] + SFE->FE_RETENC		
			EndIf	
		EndIf
		If SFE->FE_TIPO	= 	"I"
			Do Case
				Case SFE->FE_ALIQ == 10
					nBase10 += SFE->FE_RETENC
				Case SFE->FE_ALIQ == 20
					nBase20 += SFE->FE_RETENC
				Case SFE->FE_ALIQ == 30
					nBase30 += SFE->FE_RETENC
				Case SFE->FE_ALIQ == 50
					nBase50 += SFE->FE_RETENC
				Case SFE->FE_ALIQ == 70
					nBase70 += SFE->FE_RETENC
				Case SFE->FE_ALIQ == 100
					nBase100 += SFE->FE_RETENC
			EndCase
		EndIf
		SFE->(DbSkip())	
	EndDo
	
	DbSelectArea("SD1")
	SD1->(DbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	SD1->(DbGoTop())
	SD1->(DbSeek(cFilDoc + cDoc + cSer + cClie + cLoja))
	While SD1->(!EOF()) .AND. SD1->D1_FILIAL = cFilDoc .AND. SD1->D1_DOC = cDoc .AND. SD1->D1_SERIE = cSer ;
										.AND. SD1->D1_FORNECE = cClie .AND. SD1->D1_LOJA = cLoja .And. !Empty(aLibExe)
		For nX := 1 To Len(aLibExe)
			nBaseExe += SD1->&("D1_VALIMP" + Alltrim(aLibExe[nX]))
		Next nX
		SD1->(DbSkip())
	EndDo
	If Len(aAir) > 0
		cXml+=MontaXML('air'			,						,,,,,12,.T.,.F.,.T.)
		For nX := 1 To Len(aAIR)
			cXml+=MontaXML("detalleAir"		,						,,,,,16,.T.,.F.,.T.)
			cXml+=MontaXML("codRetAir"		,aAIR[nX][1]			,,,,,20,.T.,.T.,.T.)
			cXml+=MontaXML("baseImpAir"		,STRTRAN(TRANSFORM(aAIR[nX][2],"@E 9999999999.99"),',','.') ,,,,,20,.T.,.T.,.T.)
			cXml+=MontaXML("porcentajeAir"	,STRTRAN(TRANSFORM(aAIR[nX][3],"@E 9999999999.99"),',','.') ,,,,,20,.T.,.T.,.T.)
			cXml+=MontaXML("valRetAir"		,STRTRAN(TRANSFORM(aAIR[nX][4],"@E 9999999999.99"),',','.') ,,,,,20,.T.,.T.,.T.)
			cXml+=MontaXML("detalleAir"		,						,,,,,16,.F.,.T.,.T.)
		Next nX
		cXml+=MontaXML('air'			,						,,,,,12,.F.,.T.,.T.)
	EndIf
	
Return {cXml, nBase10, nBase20, nBase50, nBaseExe, nBase30, nBase70, nBase100}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M486VALSX5 ³ Autor ³ Luis Enriquez         ³ Data ³ 31.05.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtiene Descripción de item en SX5                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M486VALSX5(cClave)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ CClave = (X5_TABELA + X5_CHAVE).                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet = Valor obtenido de campo X5_DESCSPA de tabla generica. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M486NFXML - M486NDCXML - M486NCCXML                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GERVALSX5(cClave)
	Local cRet := ""
	Local aArea 	:= getArea()

	Default cClave := ""

	If !Empty(cClave)
		dbSelectArea("SX5")
		SX5->(dbSetOrder(1)) //X5_FILIAL + X5_TABELA + X5_CHAVE
		If SX5->(dbSeek(xFilial("SX5") + cClave))
			cRet := X5Descri()
		EndIf
	EndIf
	RestArea(aArea)
Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ObtProvCli ³ Autor ³Alfredo Medrano        ³ Data ³09/09/2021³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Obtiene Proveedor relacionado al Cliente                   -³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1 : linha em xml                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 : Cod proveedor   				    	              ³±±
±±³          ³ExpC2 : Tieneda proveedor                                   ³±±
±±³          ³ExpC3 : Cod cliente                                        ³±±
±±³          ³ExpC4 : Tienda cliente                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
 /*/
Function ObtProvCli(cCodProvS, cLojaS, cNF1Cli,cNF1Loja )
Local aArea 	:= GetArea()
Local cQuery 	:= ""
Local cSA2Tmp 	:= ""
Local cFilSA2	:= xFilial("SA2")
default cCodProvS := ""
default cLojaS  := ""
default cFilSA2 := ""
	IF empty(cFilSA2) .OR. Empty(cNF1Cli) .OR. Empty(cNF1Loja)
		cQuery := "SELECT A2_COD, A2_LOJA FROM " + RetSqlName("SA2")+" SA2  WHERE "
		cQuery += " A2_CLIENTE = '" + cNF1Cli+ "' AND A2_LOJA = '" + cNF1Loja + "' AND A2_FILIAL = '" + cFilSA2 + "'  AND D_E_L_E_T_ <> '*' " 
		cSA2Tmp := ChangeQuery(cQuery)
		dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSA2Tmp ) ,"TMPSA2", .T., .F.)
		If TMPSA2->(!EOF())
			cCodProvS  := TMPSA2->A2_COD
			cLojaS	  := TMPSA2->A2_LOJA
		EndIf 
		TMPSA2->(dbCloseArea())
	EndIf
	RestArea(aArea)
Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ObtReem 	³ Autor ³Alfredo Medrano        ³ Data ³02/09/2021³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcion para obtener los reembolsos de la factua de venta  -³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1 : linha em xml                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 : Filial del documento   				    	      ³±±
±±³          ³ExpC2 : Numero de documento                                 ³±±
±±³          ³ExpC3 : Serie de documento                                  ³±±
±±³          ³ExpC4 : Codigo de cliente                                   ³±±
±±³          ³ExpC5 : Codigo de tienda                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
 /*/
Function ObtReem (cFilDoc, cDoc, cSerie, cCliente, cLoja)
	Local aArea 	:= GetArea()
	Local nX        := 0
	Local cXml 		:= ""
	Local aReem		:= {}
	Local cTpDocu	:= ""
	Local cTpCompr	:= ""
	Local dFecha
	Local cFechaRet := ""


	cCliente:= SubStr(cCliente	, 1, TamSX3("F2_CLIENTE")[1])
	cLoja	:= SubStr(cLoja	, 1, TamSX3("F2_LOJA")[1])
	cDoc	:= SubStr(cDoc	, 1, TamSX3("F2_DOC")[1])
	cSerie	:= SubStr(cSerie	, 1, TamSX3("F2_SERIE")[1])

	dbSelectArea('AQ0')
	DbSetOrder(1)//AQ0_FILIAL+AQ0_SERIE+AQ0_DOC+AQ0_CLIENT+AQ0_TIENDA+AQ0_ESTABL+AQ0_PTOEMI+AQ0_NUMDOC
	
	If AQ0->(MSSeek(xFilial("AQ0")+cSerie+cDoc+cCliente+cLoja))
	
		While AQ0->(!Eof()) .and. AQ0->(AQ0_FILIAL+AQ0_SERIE+AQ0_DOC+AQ0_CLIENT+AQ0_TIENDA) == xFilial("AQ0")+cSerie+cDoc+cCliente+cLoja

			dFecha:=  AQ0->AQ0_FECHA	
			cFechaRet :=  Strzero(Day(dFecha),2) + "/" + Strzero(Month(dFecha),2) + "/" + Strzero(Year(dFecha),4) 
			cTpDocu := 	ObtColSAT('S002',AQ0->AQ0_TIPDOC,1,2,79,81)	
			cTpDocu := IIF(cTpDocu == "", AQ0->AQ0_TIPDOC,cTpDocu)

			cTpCompr := 	ObtColSAT('S004',AQ0->AQ0_TPDOC,1,3,237,239) 
			cTpCompr := IIF(cTpCompr == "", AQ0->AQ0_TPDOC,cTpCompr)

					AADD( aReem , {	cTpDocu,;			// 1 Tipo Doc 
									AQ0->AQ0_CGC,;		// 2 Documento identificación
									AQ0->AQ0_PAIS,;		// 3 PAIS
									AQ0->AQ0_TPPROV,;	// 4 Tipo de proveedor
									cTpCompr,; 			// 5 Tipo de comprobante
									AQ0->AQ0_ESTABL,;	// 6 Establecimiento
									AQ0->AQ0_PTOEMIS,;	// 7 Punto Emisión
									AQ0->AQ0_NUMDOC,;	// 8 Número de comprobante
									AQ0->AQ0_FECHA,;	// 9 Fecha de emisión
									AQ0->AQ0_AUTOR,;	// 10 Número de autorización
									AQ0->AQ0_VALOR,; 	// 11 Valor reembolso 
									AQ0->AQ0_VALIMP,;	// 12 Impuesto
									AQ0->AQ0_TES,;		// 13 Tes
												 "" }) 	// 14 Detalle 
			AQ0->(dbskip())
		EndDo
	EndIf

	If Len(aReem) > 0
		cXml+= MontaXML("reembolsos" 	,								,,,,,12 ,.T.,.F.,.T.)
		For nX := 1 To Len(aReem)
			
				cXml+= MontaXML("reembolso" 		,													,,,,,16 ,.T.,.F.,.T.) 
				cXml+= MontaXML("tipoComprobanteReemb"	,Alltrim(aReem[nX,5])						,,,,,20,.T.,.T.,.T.)
				cXml+= MontaXML("tpIdProvReemb"		,Alltrim( aReem[nX,1])							,,,,,20,.T.,.T.,.T.)
				cXml+= MontaXML("idProvReemb"		,Alltrim(aReem[nX,2])								,,,,,20,.T.,.T.,.T.)
				cXml+= MontaXML("establecimientoReemb"	,Alltrim(aReem[nX,6])						,,,,,20,.T.,.T.,.T.)
				cXml+= MontaXML("puntoEmisionReemb"		,Alltrim(aReem[nX,7])						,,,,,20,.T.,.T.,.T.)
				cXml+= MontaXML("secuencialReemb"		,Alltrim(aReem[nX,8])							,,,,,20,.T.,.T.,.T.)
				cXml+= MontaXML("fechaEmisionReemb"		,cFechaRet									,,,,,20,.T.,.T.,.T.)
				cXml+= MontaXML("autorizacionReemb"		,Alltrim(aReem[nX,10])						,,,,,20,.T.,.T.,.T.)
				cXml+= MontaXML("baseImponibleReemb"	,STRTRAN(TRANSFORM(aReem[nX,11] ,"@E 9999999999.99"),',','.')	,,,,,20,.T.,.T.,.T.)
				cXml+= MontaXML("baseImpGravReemb"		,STRTRAN(TRANSFORM(0,"@E 9999999999.99"),',','.') 			,,,,,20,.T.,.T.,.T.)
				cXml+= MontaXML("baseNoGraIvaReemb"		,STRTRAN(TRANSFORM(0,"@E 9999999999.99"),',','.') 			,,,,,20,.T.,.T.,.T.)
				cXml+= MontaXML("baseImpExeReemb"		,STRTRAN(TRANSFORM(0,"@E 9999999999.99"),',','.') 				,,,,,20,.T.,.T.,.T.)
				cXml+= MontaXML("montoIceRemb"		,STRTRAN(TRANSFORM(0,"@E 9999999999.99"),',','.')				,,,,,20,.T.,.T.,.T.)
				cXml+= MontaXML("montoIvaRemb"		,STRTRAN(TRANSFORM(0,"@E 9999999999.99"),',','.')				,,,,,20,.T.,.T.,.T.)
				cXml+= MontaXML("reembolso"			,																,,,,,16,.F.,.T.,.T.)
		
		Next nX
		cXml+= MontaXML("reembolsos"		,								,,,,,12 ,.F.,.T.,.T.)
	Endif
	RestArea(aArea)
Return {cXml}

/*/{Protheus.doc} LFeXMLaVEx
	Extrae archivo de trabajo NF venta de exportacion para uso en INI de generac. de archivos magneticos.
	@type  Function
	@author oscar.lopez
	@since 07/11/2021
	@version 1.0
	@param cDtIni, string, Fecha inicial para filtro de documentos
	@param cDtfim, string, Fecha final para filtro de documentos
	@return true
	@example
	LFeXMLaVEx(cDtIni, cDtfim)
	/*/
Function LFeXMLaVEx(cDtIni, cDtfim)

	Local aCampos	:= {}
	Local aPosLiv	:= {}
	// controle de quebra de acumulado
	Local oTmpTabExt:= Nil
	Local aOrdem 	:= {}
	Local lTpoCom   := SF2->(ColumnPos( "F2_TIPOPE" )) > 0
	Local lTpDoc	:= SF2->(ColumnPos( "F2_TPDOC" )) > 0 
	Local cTpIdClie	:= ""
	Local cFilSA1	:= xFilial("SA1")
	If Type('lVenExpor') == "U"
		Private lVenExpor := .F.
	EndIf
	
	If (SF2->(ColumnPos( "F2_TPACTIV" )) > 0 .And. SF2->(ColumnPos( "F2_REGIME" )) > 0 .And. SF2->(ColumnPos( "F2_TPRENTA" )) > 0;
	  .And. SF2->(ColumnPos( "F2_EXPCONF" )) > 0 .And. SF2->(ColumnPos( "F2_VALIMPD" )) > 0 .And. SF2->(ColumnPos( "F2_TCOMP" )) > 0 .And. SF2->(ColumnPos( "F2_FECHSE" )) > 0) 
		lVenExpor := .T.
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
		dbSelectArea("SFB")
		SFB->(dbSetOrder(1)) //FB_FILIAL+FB_CODIGO
		SFB->(dbgotop())
		SFB->(MsSeek(xFilial("SFB"),.T.))
		While SFB->(!EOF()) 
			aadd(aPosLiv,{SFB->FB_CODIGO,SFB->FB_CPOLVRO})
			SFB->(DbSkip())	
		endDo

		dbselectarea("SF2")
		SF2->(dbsetorder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Criação do arquivo de trabalho
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		AADD(aCampos,{"TPIDCLIEXT"	,"C",002,0})
		AADD(aCampos,{"IDCLIEXT"	,"C",013,0})
		AADD(aCampos,{"PARTREL"		,"C",002,0})
		AADD(aCampos,{"TIPCLIE"		,"C",002,0})
		AADD(aCampos,{"DENEXPCLI"	,"C",500,0})
		AADD(aCampos,{"TIPREGI"		,"C",002,0})
		AADD(aCampos,{"PEFEPAGGEN"	,"C",003,0})
		AADD(aCampos,{"PPAGPARFIS"	,"C",003,0})
		AADD(aCampos,{"DENREGFIS"	,"C",500,0})
		AADD(aCampos,{"PAISEFEEXP"	,"C",003,0})
		AADD(aCampos,{"TPEXPING"	,"C",002,0})
		AADD(aCampos,{"TPINGEXT"	,"C",003,0})
		AADD(aCampos,{"INGEXTGAV"	,"C",002,0})
		AADD(aCampos,{"IMPOTROPA"	,"N",015,2})
		AADD(aCampos,{"TPCOMP"		,"C",003,0})
		AADD(aCampos,{"REFDISADUA"	,"C",003,0})
		AADD(aCampos,{"REFREGIME"	,"C",002,0})
		AADD(aCampos,{"REFCORREL1"	,"C",008,0})
		AADD(aCampos,{"DOCTRANSP"	,"C",013,0})
		AADD(aCampos,{"FCHREGCONT"	,"D",010,0})
		AADD(aCampos,{"VALORFOB"	,"N",015,2})
		AADD(aCampos,{"VLFOBCOMP"	,"N",015,2})
		AADD(aCampos,{"NOSERCOMPR"	,"C",003,0})
		AADD(aCampos,{"PTOEMISION"	,"C",003,0})
		AADD(aCampos,{"COMPRSECU"	,"C",009,0})
		AADD(aCampos,{"COMPRAUTOR"	,"C",049,0})
		AADD(aCampos,{"COMPFCHEMI"	,"D",010,0})

		If oTmpTabExt <> Nil
			oTmpTabExt:Delete()
			oTmpTabExt:=Nil
		EndIf

		oTmpTabExt := FWTemporaryTable():New("TEX") 
		oTmpTabExt:SetFields( aCampos ) 
		aOrdem	:=	{"TPIDCLIEXT","IDCLIEXT"} 
		oTmpTabExt:AddIndex("I1", aOrdem) 
		oTmpTabExt:Create() 

		DbSelectArea("TEX")

		cQry:=" SELECT F3.F3_FILIAL FILIAL, F3.F3_CLIEFOR CLIEFOR, F3.F3_LOJA LOJA, F3.F3_NFISCAL NFISCAL, F3.F3_SERIE SERIE, F3.F3_ESPECIE ESPECIE , "
		cQry+=" SUM(1) QTDNF , SUM(F3_EXENTAS) EXENTAS, SUM( CASE F3.F3_ALQIMP"+alltrim(aposliv[aScan(aposliv,{|x| x[1] == 'IVA'})][2])+" WHEN 0 THEN "
		cQry+=" F3_BASIMP"+alltrim(aposliv[aScan(aposliv,{|x| x[1] == 'IVA'})][2])+" ELSE 0 END) ALQZERO, "
		cQry+=" SUM( CASE F3_ALQIMP"+alltrim(aposliv[aScan(aposliv,{|x| x[1] == 'IVA'})][2])+" WHEN 0 THEN 0 ELSE 
		cQry+=" F3_BASIMP"+alltrim(aposliv[aScan(aposliv,{|x| x[1] == 'IVA'})][2])+" END) ALQNOZER , "
		cQry+=" SUM(F3_VALIMP"+alltrim(aposliv[aScan(aposliv,{|x| x[1] == 'IVA'})][2])+") VALIMP, 
		cQry+=" SUM(F3_VALIMP"+alltrim(aposliv[aScan(aposliv,{|x| x[1] == 'RV0'})][2])+"+ "
		cQry+=" F3_VALIMP"+alltrim(aposliv[aScan(aposliv,{|x| x[1] == 'RV1'})][2])+"+ "
		cQry+=" F3_VALIMP"+alltrim(aposliv[aScan(aposliv,{|x| x[1] == 'RV2'})][2])+") IVARET, "
		cQry+=" SUM(F3_VALIMP"+alltrim(aposliv[aScan(aposliv,{|x| x[1] == 'RIR'})][2])+") VALIRR "
		If lTpoCom
			cQry+=",F2.F2_TIPOPE TIPOPE"
		EndIf
		cQry+=" FROM " + RetSqlName("SF3") + " F3 "
		If lTpoCom
			cQry+=" INNER JOIN " + RetSqlName("SF2") + " F2 ON "
			cQry+="F3.F3_FILIAL = F2.F2_FILIAL AND F3.F3_NFISCAL = F2.F2_DOC AND F3.F3_SERIE = F2.F2_SERIE AND F3.F3_CLIEFOR = F2.F2_CLIENTE AND F3.F3_LOJA = F2.F2_LOJA"
		EndIf
		cQry+=" WHERE F3_EMISSAO >= '"+cDtIni+"' AND F3_EMISSAO <= '"+cDtfim+"' AND F3_TIPOMOV = 'V' AND F3.D_E_L_E_T_ = ' '"
		If  lTpDoc
			cQry+=" AND (F2_TPDOC != '01') "
		EndIf
		cQry+=" AND (F2_TPACTIV = 'S') "
		cQry+=" GROUP BY F3.F3_FILIAL , F3.F3_CLIEFOR , F3.F3_LOJA , F3.F3_NFISCAL , F3.F3_SERIE , F3.F3_ESPECIE "
		If lTpoCom
			cQry+=" , F2.F2_TIPOPE"
		EndIf
		cQry+=" ORDER BY F3.F3_FILIAL , F3.F3_CLIEFOR , F3.F3_LOJA , F3.F3_NFISCAL , F3.F3_SERIE , F3.F3_ESPECIE "

		ChangeQuery(cQry)
		dbUseArea(.T.,'TOPCONN',TcGenQry(,,Alltrim(cQry)),'NVE',.F.,.T.)

		DbSelectArea("NVE")
		NVE->(DbGoTop())
		While NVE->(!EOF())
			RecLock("TEX",.T.)
			SA1->(MsSeek(cFilSA1+NVE->CLIEFOR+NVE->LOJA))
			If SA1->A1_TIPDOC == '04'
				cTpIdClie := '20'
			ElseIf SA1->A1_TIPDOC $ '06|08'
				cTpIdClie := '21'
			EndIf
			TEX->TPIDCLIEXT := cTpIdClie

			If SA1->A1_TIPDOC == '04'
				TEX->IDCLIEXT := SA1->A1_CGC
			ElseIf SA1->A1_TIPDOC $ '06|08'
				TEX->IDCLIEXT := SA1->A1_NIF
			EndIf

			TEX->PARTREL := IIf(SA1->A1_ACN == 'S', 'SI', 'NO')

			If cTpIdClie == '21'
				TEX->TIPCLIE	:= IIf(SA1->A1_TIPO == "1", '01', '02')
				TEX->DENEXPCLI	:= AllTrim(SA1->A1_NOME)
			EndIf

			TEX->TIPREGI	:= SA1->A1_TFN

			If SA1->A1_TFN == "01"
				TEX->PEFEPAGGEN	:= SA1->A1_TP
				TEX->DENREGFIS :=  AllTrim(ObtColSAT("S028",SA1->A1_TP,1,3,4,53))
			ElseIf  SA1->A1_TFN == "02"
				TEX->PPAGPARFIS	:= SA1->A1_GLN
				TEX->DENREGFIS := AllTrim(ObtColSAT("S029",SA1->A1_GLN,1,2,3,107))
			EndIf
			TEX->PAISEFEEXP := SA1->A1_RETIR

			SF2->(dbgotop())
			SF2->(MsSeek(NVE->FILIAL + NVE->NFISCAL + NVE->SERIE + NVE->CLIEFOR + NVE->LOJA))
			TEX->TPEXPING	:= SF2->F2_REGIME
			TEX->REFDISADUA	:= SF2->F2_MUNDESC
			TEX->REFREGIME	:= SF2->F2_CMUNDE
			TEX->REFCORREL1	:= SF2->F2_DOCMAN
			TEX->DOCTRANSP	:= SF2->F2_LTRAN
			TEX->TPINGEXT	:= SF2->F2_TPRENTA
			TEX->INGEXTGAV	:= IIf(SF2->F2_EXPCONF=='S','SI','NO')
			TEX->IMPOTROPA	:= SF2->F2_VALIMPD
			TEX->TPCOMP		:= SF2->F2_TCOMP
			TEX->FCHREGCONT	:= SF2->F2_FECHSE
			TEX->VALORFOB	:= SF2->F2_VALBRUT
			TEX->VLFOBCOMP	:= SF2->F2_VALBRUT
			TEX->NOSERCOMPR	:= SF2->F2_ESTABL
			TEX->PTOEMISION	:= SF2->F2_PTOEMIS
			TEX->COMPRSECU	:= IIf(Len(Alltrim(SF2->F2_DOC)) > 9, RIGHT(Alltrim(SF2->F2_DOC),9), Alltrim(SF2->F2_DOC))
			TEX->COMPFCHEMI	:= SF2->F2_EMISSAO
			TEX->COMPRAUTOR	:= SF2->F2_NUMAUT
			MsUnlock()
			NVE->(dbSkip())
		EndDo
		NVE->(DbCloseArea())
	EndIf
Return .T.

 /*/{Protheus.doc} GXMLCarEsp
	Eliminación de caracteres especiales para nombres en ATS.
	@type  Function
	@author oscar.lopez
	@since 18/11/2021
	@version 1.0
	@param cTexto, string, Texto a procesar para eliminar caracteres especiales.
	@return cRet, string, Texto procesado sin caracteres especiales.
	@example
	GXMLCarEsp(cTexto)
	/*/
Function GXMLCarEsp(cTexto)
	Local aCarEsp 	:= {"(", ")", "-", "+", ",", "<", ">", "$", "&", "*", "|", "/", "\", "#", '"', "'", "¿", "?", "!", "¡", "^", "{", "}", ".", "[", "]"}
	Local cRet		:= ""
	Local nX		:= 0

	Default cTexto := ""
	
	cRet := AllTrim(cTexto)

	If !Empty(cRet)
		For nX := 1 To Len(aCarEsp)
			cRet := StrTran(cRet,aCarEsp[nX],"")
		Next nX
	EndIf
Return cRet

/*/{Protheus.doc} GERXMLAFRC
	obtiene valor de campo E4_MPAGSAT (Forma Cobro) relacionado al cliente
	@type  Static Function
	@author alfredo.medrano
	@since 05/04/2022
	@version 1.0
	@param1 Código de condición de pago 
	@return Código de Forma de Cobro
	@see ( ISSUE DMICNS-15094)
/*/
Function GERXMLAFRC(cCodCndP)
	Local aArea := GetArea()
	Local cFormCob := ""
	Default cCodCndP := ""

	If cCodCndP != ""
		DbSelectArea("SE4")
		SE4->(DbSetOrder(1)) //E4_FILIAL+E4_CODIGO
		If SE4->(MsSeek(xFilial("SE4")+cCodCndP))
			If SE4->(FieldPos("E4_MPAGSAT")) > 0
				cFormCob :=  SE4->E4_MPAGSAT
			Endif
		EndIf
	EndIf
	RestArea(aArea)

Return cFormCob

/*/{Protheus.doc} GXMLObtIVC
Obtiene la retención del IVA e IR de un cliente.
@type  Function
@author Martha Diana Diosdado
@since 19/04/2022
@version 1.0
@param cCliente, string, Código de Cliente a obtener retenciones.
@param cLoja, string, Código de Tienda a obtener retenciones.                              
@param cDtIni, string, Fecha Inicial a obtener retenciones.
@param cDtFin, string, Fecha Final a obtener retenciones. 
@param cTipoDoc, string, Tipo de Documento a obtener retenciones. 
@return nTotRIVA, numeric, Valor total de Retención de IVA. 
@return nTotRIR, numeric, Valor total de Retención de IR. 
@example
GXMLObtIVC(cCliente,cLoja,cDtIni,cDtFin,cTipoDoc,nTotRIVA,nTotRIR)
/*/
Static Function GXMLObtIVC(cCliente,cLoja,cDtIni,cDtFin,cTipoDoc,nTotRIVA,nTotRIR)
	Local aArea 	:= GetArea()
	Local cQuery 	:= ""
	Local cSELTmp 	:= ""
	Local cFilSEL	:= xFilial("SEL")
	Local cAreaSEL  := GetNextAlias()

	Default cCliente := ""
	Default cLoja    := ""
	Default cDtIni   := ""
	Default cDtFin   := ""
	Default cTipoDoc := ""
	Default nTotRIVA := 0
	Default nTotRIR  := 0

	cQuery := "SELECT EL_TIPODOC, SUM(EL_VALOR) TOTAL FROM " + RetSqlName("SEL") + " SEL  "
	cQuery += " WHERE EL_TIPODOC IN('RI','RR') AND EL_CLIORIG = '" + cCliente + "' AND EL_LOJA = '" + cLoja + "' AND EL_FILIAL = '" + cFilSEL + "'  "
	cQuery += " AND D_E_L_E_T_ = '' AND EL_EMISSAO >='" + cDtIni + "' AND EL_EMISSAO <= '" + cDtFin + "'" 
	cQuery += " AND EL_RECIBO IN (SELECT DISTINCT(EL_RECIBO) "
	cQuery += " FROM  " + RetSqlName("SEL") + " SEL   "
	cQuery += " WHERE EL_TIPO = '" + cTipoDoc + "'   AND EL_CLIORIG = '" + cCliente + "'  AND EL_LOJA = '" + cLoja + "'  "
	cQuery += " AND EL_FILIAL = '" + cFilSEL + "'  AND D_E_L_E_T_ = '')  "
	cQuery += " GROUP BY EL_TIPODOC "
	cQuery += " ORDER BY EL_TIPODOC "
	
	cSELTmp := ChangeQuery(cQuery)

	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSELTmp ) ,cAreaSEL, .T., .F.)
	DbSelectArea(cAreaSEL)
	(cAreaSEL)->(DbGoTop())
	While (cAreaSEL)->(!EOF())
		If AllTrim(EL_TIPODOC) == "RI"
			nTotRIVA := (cAreaSEL)->TOTAL
		ElseIf AllTrim(EL_TIPODOC) == "RR"
			nTotRIR := (cAreaSEL)->TOTAL
		EndIf	
	(cAreaSEL)->(dbSkip())
	EndDo
	(cAreaSEL)->(DbCloseArea())
		
	RestArea(aArea)
Return Nil

/*/{Protheus.doc} GXMLRetSEL
Genera query para la generación nodos de retención de Ventas.
@type  Function
@author Martha Diana Diosdado
@since 21/04/2022
@version 1.0
@param cLoja, string, Código de Tienda. 
@param cDtIni, string, Fecha Inial de emisión de retenciones. 
@param cDtFin, string, Fecha Final de emisión de retenciones. 
@return cQueryC, string, Query para consulta a tabla SEL para obtener retenciones. 
@example
GXMLRetSEL(cLoja,cDtIni,cDtFin)
/*/
static Function GXMLRetSEL(cLoja,cDtIni,cDtFin)
	Local cQueryC 	:= ""
	Local cFilSEL	:= xFilial("SEL")

	Default cLoja  := ""
	Default cDtIni := ""
	Default cDtFin := ""

	cQueryC := " UNION "
	cQueryC += "SELECT SEL.EL_FILIAL FILIAL,SEL.EL_CLIORIG CLIEFOR, SEL.EL_LOJA LOJA, "
	cQueryC += "E1_NUM NFISCAL,E1_SERIE SERIE, EL_TIPO ESPECIE,  "
	cQueryC += " 0 QTDNF, 0 EXENTAS, 0 ALQZERO, 0 ALQNOZER, 0 VALIMP, 0 IVARET, 0 VALIRR, "
	cQueryC += " CASE EL_TIPO WHEN 'NF' THEN '18 ' "
	cQueryC += " 		 WHEN 'NDC' THEN '5  ' "
	cQueryC += " 		 WHEN 'NCC' THEN '4  ' END TIPOPE, '' FORMCRB "
	cQueryC += " FROM " + RetSqlName("SEL") + " SEL INNER JOIN " + RetSqlName("SE1") +" SE1 "
	cQueryC += " ON SEL.EL_RECIBO=SE1.E1_RECIBO AND SEL.EL_FILIAL=SE1.E1_FILIAL "
	cQueryC += " AND   SEL.EL_CLIORIG=SE1.E1_CLIENTE  AND  SEL.EL_LOJA=SE1.E1_LOJA "
	cQueryC += " WHERE EL_TIPO IN('NF','NDC') "
	cQueryC += " AND EL_RECIBO IN(SELECT DISTINCT(EL_RECIBO) "
	cQueryC += " 				FROM " + RetSqlName("SEL") +" SEL "
	cQueryC += " 				WHERE EL_TIPO IN('RR','RI')  AND EL_LOJA = '" + cLoja + "'  "
	cQueryC += " 				AND EL_FILIAL = '" + cFilSEL + "'   AND SEL.D_E_L_E_T_ = ' ' "
	cQueryC += " 				AND EL_EMISSAO >='"+ cDtIni +"' AND EL_EMISSAO <= '"+ cDtFin +"' ) "
	cQueryC += " AND EL_LOJA = '" + cLoja + "' AND EL_FILIAL = '" + cFilSEL + "'   AND SEL.D_E_L_E_T_ = ' ' "
	cQueryC += " AND (SEL.EL_CLIORIG NOT IN(SELECT DISTINCT(F3.F3_CLIEFOR) "
	cQueryC += " 							FROM " + RetSqlName("SF3")+" F3  INNER JOIN " + RetSqlName("SF2")+" F2 "
	cQueryC += " 							ON F3.F3_FILIAL = F2.F2_FILIAL AND F3.F3_NFISCAL = F2.F2_DOC AND F3.F3_SERIE = F2.F2_SERIE "
	cQueryC += " 							AND F3.F3_CLIEFOR = F2.F2_CLIENTE AND F3.F3_LOJA = F2.F2_LOJA "
	cQueryC += " 							WHERE F3_EMISSAO >= '" + cDtIni + "' AND F3_EMISSAO <= '" + cDtFin + "' AND F3_TIPOMOV = 'V' AND F3.D_E_L_E_T_ = ' ' "
	cQueryC += " 							AND (F2_TPDOC <> '01')  ) "
	cQueryC += " AND  EL_TIPO NOT IN(SELECT DISTINCT(F2.F2_TIPOPE) "
	cQueryC += " 					FROM " + RetSqlName("SF3") + " F3  INNER JOIN " + RetSqlName("SF2") + " F2 "
	cQueryC += " 					ON F3.F3_FILIAL = F2.F2_FILIAL AND F3.F3_NFISCAL = F2.F2_DOC AND F3.F3_SERIE = F2.F2_SERIE AND "
	cQueryC += " 					F3.F3_CLIEFOR = F2.F2_CLIENTE AND F3.F3_LOJA = F2.F2_LOJA "
	cQueryC += " 					WHERE F3_EMISSAO >= '" + cDtIni + "' AND F3_EMISSAO <= '" + cDtFin + "' AND F3_TIPOMOV = 'V' AND F3.D_E_L_E_T_ = ' ' "
	cQueryC += " 					AND (F2_TPDOC <> '01')  ) ) "
	cQueryC += " GROUP BY SEL.EL_FILIAL, SEL.EL_CLIORIG, SEL.EL_LOJA, EL_TIPO, E1_NUM, E1_SERIE "
Return cQueryC
