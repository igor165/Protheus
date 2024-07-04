#Include "Protheus.ch"
#Include "NFAII.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³NFAII     ³ Autor ³  Vitor Felipe         ³ Data ³ 28.12.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Nota Fiscal Alagoana                                  	  ³±±
±±³          ³      													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpD -> Data incial do periodo - mv_par01     			  	 ³±±
±±³          ³ExpD -> Data final do periodo - mv_par02                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function NFAII()
	Local aTrbs		:= {}
	Private aCfp 	:= {}
	Private aStru10 := {}
	Private aStru20 := {}
	Private aStru30 := {}
	Private aStru40 := {}
	Private aStru50 := {}
	Private aStru60 := {}
	Private aStru90 := {}
	Private aQuant	:= {0,0,0,0,0}
	Private nQuant10:= 0
	Private nQuant20:= 0
	Private nQuant30:= 0
	Private nQuant40:= 0
	Private nQuant50:= 0
	Private nQuant60:= 0
	Private nTotal20:= 0
	Private nTotal30:= 0
	Private nTotal40:= 0
	Private nTotal50:= 0
	Private nTotal60:= 0
	Private nTotProd:= ""
	Private nTotIPI	:= ""
	Private nTotDesc:= ""
	Private nTotFret:= ""
	Private nTotSegu:= ""
	Private nTotDpAc:= ""
	Private nTotAISS := ""
	Private nTotVISS := ""
	Private nTotBICM := ""
	Private nTotTICM := ""
	Private nTotBICS := ""
	Private nTotTICS := ""

	Private lCancel := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega os parametros através da LoadCfp ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If LoadCfp()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Recupera dados do arquivo Cfp                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		xMagLeWiz("NFAII",@aCfp,.T.)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gera arquivos temporarios            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aTrbs := GeraTemp()
		Processa({||ProcNFA() })
		
	Endif
	IncProc(STR0001) //"Apagando dados temporários..."

	NfaIIDel(aTrbs)
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcNFA    ³ Autor ³  Vitor Felipe         ³ Data ³ 28.12.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro da NFA                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcNFA()

Local DtAIni  := Stod(aCfp[1][01])
Local DtAFim  := Stod(aCfp[1][02])
Local cDir    := AllTrim(aCfp[1][03])
Local cArqTxt := AllTrim(aCfp[1][04])

Default aQuant	:= {}	
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa Regitros                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcRegua(-1)

ProcReg10(DtAIni, DtAFim)
ProcReg20(DtAIni, DtAFim)
 
//--------------------------------------------------------//
// Verifica se diretório contem barra para designar pasta //
//--------------------------------------------------------//
If Substr(cDir,(Len(cDir)-1),1) <> "\"
	cDir += "\"
EndIf
//--------------------------------------------------------//
// Se diretório não existir, cria                         //
//--------------------------------------------------------//
If !ExistDir(cDir)
	Makedir(cDir)
EndIf
//--------------------------------------------------------//
// Cria o Arquivo //
//--------------------------------------------------------//
nArq1 := MSFCREATE(cDir+cArqTxt)

GravaArq("10",aStru10)
aQuant:= GravaArq("20",aStru20)
ProcReg90(DtAIni,DtAFim,aQuant) 
GravaArq("90",aStru90)


fClose(nArq1)  


If Len(Memoread(cDir+cArqTxt)) >= 500000
	cMensagem := ""
    cMensagem += STR0035 //"Arquivo muito grande para ser transmitido."+CRLF
    cMensagem += STR0036 // "Diminua o periodo de geração e tente gerar novamente."
	Aviso("NFA",cMensagem,{STR0014})	
EndIf	


If lCancel
	MsgInfo(STR0002)//"Operação Cancelada!"
Else
	MsgInfo(STR0003 + cDir+cArqTxt)//"Arquivo gerado com sucesso em "
EndIf
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcReg10  ³ Autor ³  Vitor Felipe         ³ Data ³ 28.12.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo 10                                    ³±±
±±³			 ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcReg10(dDtInicial, dDtFinal)

	RecLock("RT10",.T.)
	RT10->TIPOREG := "10"
	RT10->VERSAO  := aCfp[1][05]
	RT10->CNPJ    := StrZero(Val(GravaCpo(SM0->M0_CGC)),14)
	RT10->DATAINI := GravaCpo(dDtInicial)
	RT10->DATAFIM := GravaCpo(dDtFinal)
	MsUnlock()

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcReg20  ³ Autor ³  Vitor Felipe         ³ Data ³ 28.12.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo 20                                    ³±±
±±³			 ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcReg20(dDtInicial, dDtFinal)

Local cAlias20  := ""
Local lQuery 	:= .F.
Local cQuery 	:= ""
Local cSerIni   := SubStr(aCfp[2][01],1,3)
Local cNFIni    := SubStr(aCfp[2][02],1,9)
Local cSerFim   := SubStr(aCfp[2][03],1,3)
Local cNFFim    := SubStr(aCfp[2][04],1,9)
Local cSerie1   := AllTrim(aCfp[3][01])
Local cSerie2   := AllTrim(aCfp[3][02])
Local cSerie3   := AllTrim(aCfp[3][03])
Local cTPNota	:= aCfp[1][06]
Local cDTHRSA	:= ""
Local cDTHRS1	:= ""
Local cSerDoc   := "3"
Local cDadFat	:= ""
Local cFunreg	:= AllTrim(aCfp[2][5])
Local cJustCa	:= "" 

Local cSerieId	:= SerieNfId("SF2",3,"F2_SERIE")

If cFunreg == "C"
	cJustCa:=AllTrim(aCfp[2][6])
EndIf

If Empty(cSerie1) .Or. Empty(cSerie2) .Or. Empty(cSerie3)

	cAviso := STR0004 + CRLF+CRLF
	cAviso += STR0005 + cSerie1 +CRLF
	cAviso += STR0006 + cSerie2 +CRLF
	cAviso += STR0007 + cSerie3 +CRLF+CRLF
	cAviso += STR0008 + STR0009  + cSerDoc+CRLF
	cAviso += Replicate("#",150)
	If Aviso(STR0016 ,cAviso,{STR0010 ,STR0011 }) == 1
		lCancel:= .T.
    	Return(Nil)
	EndIf
EndIf

#IFDEF TOP
If TcSrvType()<>"AS/400"

		lQuery 		:= .T.
		cAlias20	:= GetNextAlias()   
       	
     	cQuery += " SELECT SF2.F2_FILIAL
		cQuery += " ,SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_CLIENTE,SF2.F2_LOJA,SF2.F2_COND,SF2.F2_DUPL,SF2.F2_EMISSAO,SF2.F2_EST,SF2.F2_FRETE"
		cQuery += " ,SF2.F2_ICMFRET,SF2.F2_TIPOCLI,SF2.F2_VALBRUT,SF2.F2_VALMERC,SF2.F2_DESCONT,SF2.F2_TIPO,SF2.F2_TRANSP,SF2.F2_DTLANC"
		cQuery += " ,SF2.F2_DESPESA,SF2.F2_ESPECIE,SF2.F2_PREFIXO,SF2.F2_TIPODOC,SF2.F2_DTDIGIT,SF2.F2_CLIENT,SF2.F2_LOJENT,SF2.F2_HORA"
		cQuery += " ,SF2.F2_SEGURO,SF2.F2_BASEICM,SF2.F2_BASEISS,SF2.F2_VALISS,SF2.F2_VALICM,SF2.F2_BASETST,SF2.F2_VALIPI,SF2.F2_VALFAT"
		cQuery += " ,SF2.F2_VOLUME1,SF2.F2_PLIQUI,SF2.F2_PBRUTO,SF2.F2_TRANSP,SF2.F2_VEICUL1,SF2.F2_TPFRETE,SF2.F2_ICMSRET,SF2.F2_DUPL"

		If cSerieId == "F2_SDOC"
			cQuery += " ,SF2.F2_SDOC"
		EndIf

		cQuery += " ,SA1.A1_NOME,SA1.A1_PESSOA,SA1.A1_END,SA1.A1_EST,SA1.A1_MUN,SA1.A1_BAIRRO,SA1.A1_ESTADO,SA1.A1_CEP,SA1.A1_DDD,SA1.A1_TEL,SA1.A1_CGC,SA1.A1_INSCR,SA1.A1_NATUREZ"
		cQuery += " FROM "
		cQuery += RetSqlName("SF2") + " SF2,"
		cQuery += RetSqlName("SA1") + " SA1 "		
		cQuery += " WHERE "
		cQuery += " SF2.F2_FILIAL = '" + xFilial("SF2") + "' AND "
		cQuery += " SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND "
		cQuery += " SF2.F2_CLIENTE = SA1.A1_COD AND SF2.F2_LOJA = SA1.A1_LOJA AND"
		cQuery += " SF2.F2_EMISSAO >= '"+Dtos(dDtInicial)+"' AND "
		cQuery += " SF2.F2_EMISSAO <= '"+Dtos(dDtFinal)  +"' AND "

		If cSerieId == "F2_SDOC"
			cQuery += " (SF2.F2_SDOC BETWEEN '"+cSerIni+"' AND '"+cSerFim+"') AND " 		
		Else
			cQuery += " (SF2.F2_SERIE BETWEEN '"+cSerIni+"' AND '"+cSerFim+"') AND " 		
		EndIf

		cQuery += " (SF2.F2_DOC >='"+cNFIni+"' AND SF2.F2_DOC <='"+cNFFim+"') AND " 		
		cQuery += " SF2.F2_TIPO NOT IN ('D','B') AND "
		cQuery += " SF2.D_E_L_E_T_='' AND "
		cQuery += " SA1.D_E_L_E_T_=''"
		cQuery += " ORDER BY F2_EMISSAO,F2_DOC,F2_SERIE"
	
		cQuery := ChangeQuery(cQuery)                       
        
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias20,.T.,.T.)
		
		TcSetField(cAlias20,"F2_EMISSAO","D",8,0)

		DbSelectArea(cAlias20)

Else
#ELSE

	dbSelectArea("SF2")
	cIndSF2	:=	CriaTrab(NIL,.F.)
	cChave	:=	IndexKey()
	cFiltro	:=	"SF2->F2_FILIAL=='"+xFilial("SF2")+"' .And. DTOS(SF2->F2_EMISSAO)>='"+Dtos(dDtInicial)+"' .AND. DTOS(SF2->F2_EMISSAO)<='"+Dtos(dDtFinal)+"'"						
	cFiltro	+=  " .And. SF2->F2_SERIE >= '"+cSerIni+"'"
	cFiltro	+=  " .And. SF2->F2_SERIE <= '"+cSerFim+"'" 		
	cFiltro	+=  " .And. SF2->F2_DOC >= '"+cNFIni+"'"
	cFiltro	+=  " .And. SF2->F2_DOC <= '"+cNFFim+"'" 		
	cFiltro	+=  " .And. SF2->F2_TIPO !$ 'DB'"
 
	IndRegua("SF2",cIndSF2,cChave,,cFiltro)
	SF2->(DbgoTop()) 

#ENDIF

#IFDEF TOP
Endif 

If TcSrvType()<>"AS/400"
	Do While !(cAlias20)->(Eof())
		DbSelectArea("RT20")
		
		If	SerieNfId(cAlias20,2,"F2_SERIE") $ cSerie1
			cSerDoc := "1"		
		ElseIf SerieNfId(cAlias20,2,"F2_SERIE") $ cSerie2
			cSerDoc := "2"		
		ElseIf SerieNfId(cAlias20,2,"F2_SERIE") $ cSerie3
			cSerDoc := "3"		
		EndIf		
		
		If AllTrim((cAlias20)->F2_CLIENT) == "" .And. AllTrim((cAlias20)->F2_LOJENT) == ""
            
			If DbSeek(xFilial("SA1")+ (cAlias20)->F2_CLIENT + (cAlias20)->F2_LOJENT)
				cEndEnt := (FisGetEnd(SA1->A1_END)[1])
				cNumEnt	:= IIF(FisGetEnd(SA1->A1_END)[2]<>0, AllTrim(Str(FisGetEnd(SA1->A1_END)[2])) ,"SN") 
				cCompEnt:= FisGetEnd( SA1->A1_END )[4]  
				cBairEnt:= AllTrim(SA1->A1_BAIRRO)
				cMunEnt := AllTrim(SA1->A1_MUN)
				cUfEnt  := AllTrim(SA1->A1_EST)
			Else			
				cEndEnt := cNumEnt := cCompEnt := cBairEnt := cMunEnt := cUfEnt := ""
			EndIf
		Else
			cEndEnt := cNumEnt := cCompEnt := cBairEnt := cMunEnt := cUfEnt := ""
		EndIf        
		cDTHRS1 := DTOS((cAlias20)->F2_EMISSAO)	   
		cDTHRSA	:= SubStr(cDTHRS1,7,2)+"/"+SubStr(cDTHRS1,5,2)+"/"+SubStr(cDTHRS1,1,4)+" "+(cAlias20)->F2_HORA+":00"
		
		RecLock("RT20",.T.)
 	       
  		RT20->TIPOREG	:="20"
 		RT20->FUNREG	:=GravaCpo(cFunreg)
		RT20->JUSTCANC	:=GravaCpo(cJustCa)
 		RT20->NATOPER	:=GravaCpo((cAlias20)->A1_NATUREZ) 		 		 		 		
  		RT20->SDOC		:=GravaCpo(SerieNfId(cAlias20,2,"F2_SERIE"))
 		RT20->NUMERO	:=GravaCpo((cAlias20)->F2_DOC)
  		RT20->DTEMISS	:=cDTHRSA
   		RT20->DTSAIDA	:=cDTHRSA	
 		RT20->TIPONF	:=cTPNota
   		RT20->CODFIS	:=GravaCpo((cAlias20)->A1_NATUREZ)
		RT20->IESUBST	:=""
		RT20->IEEMITE	:=GravaCpo(SM0->M0_INSC)
 		RT20->CPFCNPJ	:=GravaCpo((cAlias20)->A1_CGC)
		RT20->NOMEDEST	:=GravaCpo((cAlias20)->A1_NOME)
		RT20->LOGRADOURO:=GravaCpo( FisGetEnd( (cAlias20)->A1_END )[1] )
		RT20->NUMEND	:=IIF(FisGetEnd((cAlias20)->A1_END)[2]<>0, AllTrim(Str(FisGetEnd((cAlias20)->A1_END)[2])) ,"SN") 
		RT20->COMPL		:=GravaCpo(FisGetEnd((cAlias20)->A1_END)[4])
		RT20->BAIRRO	:=GravaCpo((cAlias20)->A1_BAIRRO)
 		RT20->MUNICPIO	:=GravaCpo((cAlias20)->A1_MUN)
 		RT20->UF		:=GravaCpo((cAlias20)->A1_EST)	
 		RT20->CEP		:=GravaCpo((cAlias20)->A1_CEP)
  		RT20->PAIS		:="BRASIL"
		RT20->TELEFONE	:=GravaCpo( Strzero(Val((cAlias20)->A1_DDD),2)+AllTrim(Str(FisGetTel((cAlias20)->A1_TEL)[3]))    ) 	
		RT20->IEDEST	:=GravaCpo((cAlias20)->A1_INSCR)
		RT20->CLIENTE	:=GravaCpo((cAlias20)->F2_CLIENTE) 	
		RT20->LOJA		:=GravaCpo((cAlias20)->F2_LOJA)
  		RT20->SERIE		:=GravaCpo((cAlias20)->F2_SERIE)
	
		RT20->(MsUnlock())
		
	   	ProcReg30((cAlias20)->F2_DOC,(cAlias20)->F2_SERIE,(cAlias20)->F2_CLIENTE,(cAlias20)->F2_LOJA,dDtInicial, dDtFinal, SerieNfId(cAlias20,2,"F2_SERIE"))
				
		IncProc()
      		
		nTotProd := (cAlias20)->F2_VALMERC
		nTotIPI	 := (cAlias20)->F2_VALIPI
		nTotDesc := (cAlias20)->F2_DESCONT
		nTotFret := (cAlias20)->F2_FRETE
		nTotSegu := (cAlias20)->F2_SEGURO
		nTotDpAc := (cAlias20)->F2_DESPESA
		nTotAISS := ((cAlias20)->F2_VALISS*100)/(cAlias20)->F2_BASEISS
		nTotVISS := (cAlias20)->F2_VALISS
		nTotBICM := (cAlias20)->F2_BASEICM
		nTotTICM := (cAlias20)->F2_VALICM
		nTotBICS :=	(cAlias20)->F2_BASETST
		nTotTICS := (cAlias20)->F2_ICMSRET
        nTotNF 	 := (cAlias20)->F2_VALBRUT
        	
 		ProcReg40(nTotProd,nTotIPI,nTotDesc,nTotFret,nTotSegu,nTotDpAc,nTotAISS,nTotVISS,nTotBICM,nTotTICM,nTotBICS,nTotTICS,nTotNF,(cAlias20)->F2_DOC,(cAlias20)->F2_SERIE,(cAlias20)->F2_CLIENTE,(cAlias20)->F2_LOJA) 
		ProcReg50(dDtInicial, dDtFinal,(cAlias20)->F2_DOC,(cAlias20)->F2_SERIE,(cAlias20)->F2_CLIENTE,(cAlias20)->F2_LOJA)
		cDadFat:="Fatura: "+(cAlias20)->F2_DUPL+" Prefixo: "+(cAlias20)->F2_PREFIXO+" Valor: "+StrTran(TRANSFORM((cAlias20)->F2_VALFAT,"999999999999999.99"),".",",")
		ProcReg60(dDtInicial, dDtFinal, cDadfat,(cAlias20)->F2_DOC,(cAlias20)->F2_SERIE,(cAlias20)->F2_CLIENTE,(cAlias20)->F2_LOJA,(cAlias20)->F2_ESPECIE,(cAlias20)->F2_VOLUME1,(cAlias20)->F2_PLIQUI,(cAlias20)->F2_PBRUTO,(cAlias20)->F2_TRANSP,(cAlias20)->F2_VEICUL1)
	  	ProcReg90(dDtInicial, dDtFinal)

	(cAlias20)->(dbSkip())  				
	EndDo

Else
#ELSE
	Do While !SF2->(Eof())
		DbSelectArea("RT20")
		
		If  SF2->F2_SERIE $ cSerie1
			cSerDoc := "1"		
		ElseIf SF2->F2_SERIE $ cSerie2
			cSerDoc := "2"		
		ElseIf SF2->F2_SERIE $ cSerie3
			cSerDoc := "3"		
		EndIf
        
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbGoTop()
		If AllTrim(SF2->F2_CLIENT) == "" .And. AllTrim(SF2->F2_LOJENT) == ""
            
			If DbSeek(xFilial("SA1")+ SF2->F2_CLIENT + SF2->F2_LOJENT)
				cEndEnt := (FisGetEnd(SA1->A1_END)[1])
				cNumEnt	:= IIF(FisGetEnd(SA1->A1_END)[2]<>0, AllTrim(Str(FisGetEnd(SA1->A1_END)[2])) ,"SN") 
				cCompEnt:= FisGetEnd( SA1->A1_END )[4]  
				cBairEnt:= AllTrim(SA1->A1_BAIRRO)
				cMunEnt := AllTrim(SA1->A1_MUN)
				cUfEnt  := AllTrim(SA1->A1_EST)
			Else			
				cEndEnt := cNumEnt := cCompEnt := cBairEnt := cMunEnt := cUfEnt := ""
			EndIf
		Else
			cEndEnt := cNumEnt := cCompEnt := cBairEnt := cMunEnt := cUfEnt := ""
		EndIf        

		DbSeek(xFilial("SA1")+ SF2->F2_CLIENTE + SF2->F2_LOJA)
		
		cDTHRS1 := DTOS(SF2->F2_EMISSAO)	   
		cDTHRSA	:= SubStr(cDTHRS1,7,2)+"/"+SubStr(cDTHRS1,5,2)+"/"+SubStr(cDTHRS1,1,4)+" "+SF2->F2_HORA+":00"
		
		RecLock("RT20",.T.)

		RT20->TIPOREG	:="20"
 		RT20->FUNREG		:=GravaCpo(cFunreg)
		RT20->JUSTCANC	:=GravaCpo(cJustCa)
 		RT20->NATOPER		:=GravaCpo(SA1->A1_NATUREZ)
  		RT20->SERIE		:=GravaCpo(SF2->F2_SERIE)
 		RT20->NUMERO		:=GravaCpo(SF2->F2_DOC)
  		RT20->DTEMISS		:=cDTHRSA
   		RT20->DTSAIDA		:=cDTHRSA
 		RT20->TIPONF		:=cTPNota
   		RT20->CODFIS		:=GravaCpo(SA1->A1_NATUREZ)
		RT20->IESUBST		:=""
		RT20->IEEMITE		:=GravaCpo(SM0->M0_INSC)
 		RT20->CPFCNPJ		:=GravaCpo(SA1->A1_CGC)
		RT20->NOMEDEST	:=GravaCpo(SA1->A1_NOME)
		RT20->LOGRADOURO	:=GravaCpo( FisGetEnd(SA1->A1_END )[1] )
		RT20->NUMEND		:=IIF(FisGetEnd(SA1->A1_END)[2]<>0, AllTrim(Str(FisGetEnd(SA1->A1_END)[2])) ,"SN") 
		RT20->COMPL		:=GravaCpo(FisGetEnd((cAlias20)->A1_END)[4])
		RT20->BAIRRO		:=GravaCpo(SA1->A1_BAIRRO)
 		RT20->MUNICPIO	:=GravaCpo(SA1->A1_MUN)
 		RT20->UF			:=GravaCpo(SA1->A1_EST)	
 		RT20->CEP			:=GravaCpo(SA1->A1_CEP)
  		RT20->PAIS			:="BRASIL"
		RT20->TELEFONE	:=GravaCpo( Strzero(Val(SA1->A1_DDD),2)+AllTrim(Str(FisGetTel(SA1->A1_TEL)[3]))    ) 	
		RT20->IEDEST		:=GravaCpo(SA1->A1_INSCR)
		RT20->CLIENTE		:=GravaCpo(SF2->F2_CLIENTE) 	
		RT20->LOJA			:=GravaCpo(SF2->F2_LOJA)
		RT20->(MsUnlock())
				
		ProcReg30(SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,dDtInicial,dDtFinal)
				
		IncProc()

		nTotProd := SF2->F2_VALMERC
		nTotIPI	 := SF2->F2_VALIPI
		nTotDesc := SF2->F2_DESCONT
		nTotFret := SF2->F2_FRETE
		nTotSegu := SF2->F2_SEGURO
		nTotDpAc := SF2->F2_DESPESA
		nTotAISS := ((SF2->F2_VALISS*100)/SF2->F2_BASEISS)
		nTotVISS := SF2->F2_VALISS
		nTotBICM := SF2->F2_BASEICM
		nTotTICM := SF2->F2_VALICM
		nTotBICS := SF2->F2_BASETST
		nTotTICS := SF2->F2_ICMSRET
		nTotNF 	 := SF2->F2_VALBRUT
		
		ProcReg40(nTotProd,nTotIPI,nTotDesc,nTotFret,nTotSegu,nTotDpAc,nTotAISS,nTotVISS,nTotBICM,nTotTICM,nTotBICS,nTotTICS,nTotNF,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA)
		ProcReg50(dDtInicial, dDtFinal,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA)
		cDadFat	:="Fatura: "+SF2->F2_DUPL+" Prefixo: "+SF2->F2_PREFIXO+" Valor: "+StrTran(TRANSFORM(SF2->F2_VALFAT,"999999999999999.99"),".",",")
		ProcReg60(dDtInicial,dDtFinal,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_ESPECIE,SF2->F2_VOLUME1,SF2->F2_PLIQUI,SF2->F2_PBRUTO,SF2->F2_TRANSP,SF2->F2_VEICUL1)
  		ProcReg90(dDtInicial, dDtFinal)
		
		SF2->(dbSkip())  				
	EndDo

#ENDIF

#IFDEF TOP
EndIF
#ENDIF


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui area de trabalho utilizada - SF2³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lQuery
		dbSelectArea(cAlias20)
		dbCloseArea()
	ElSE
		RetIndex("SF2")	
		dbClearFilter()	
		Ferase(cIndex+OrdBagExt())
	Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcReg30  ³ Autor ³  Vitor Felipe         ³ Data ³ 28.12.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo 30                                    ³±±
±±³			 ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcReg30(nDoc, nSerie, nCliente, nLoja,dDtInicial, dDtFinal, cSerPesq) 
Local cAlias30  := ""
Local lQuery 	:= .F.
Local cQuery 	:= ""
Local cRec1     := AllTrim(aCfp[3][04])
Local cRec2     := AllTrim(aCfp[3][05])
Local cRec3     := AllTrim(aCfp[3][06]) 

Local cSerieId	:= SerieNfId("SD2",3,"D2_SERIE")

#IFDEF TOP
If TcSrvType()<>"AS/400"

		lQuery 		:= .T.
		cAlias30	:= GetNextAlias()   
        
      	cQuery += " SELECT SD2.D2_FILIAL
		cQuery += " ,SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SD2.D2_LOJA,SD2.D2_EMISSAO,SD2.D2_UM"
		cQuery += " ,SD2.D2_COD,SD2.D2_CF,SD2.D2_ITEM,SD2.D2_QUANT,SD2.D2_PRCVEN,SD2.D2_TOTAL,SD2.D2_CLASFIS,SD2.D2_VALIPI,SD2.D2_IPI,SD2.D2_PICM"

		If cSerieId == "D2_SDOC"
			cQuery += " ,SD2.D2_SDOC"
		EndIf

		cQuery += " ,SB1.B1_FILIAL,SB1.B1_COD,SB1.B1_DESC,SB1.B1_UM,SB1.B1_POSIPI"
		cQuery += " FROM "
		cQuery += RetSqlName("SD2") + " SD2,"
		cQuery += RetSqlName("SB1") + " SB1 "		
		cQuery += " WHERE "
		cQuery += " SD2.D2_FILIAL = '" + xFilial("SD2") + "' AND "
		cQuery += " SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND "
	   	cQuery += " SD2.D2_EMISSAO >='"+Dtos(dDtInicial)+ "' AND "
		cQuery += " SD2.D2_EMISSAO <='"+Dtos(dDtFinal)  + "' AND "
		cQuery += " SD2.D2_COD = B1_COD AND "
		cQuery += " SD2.D2_TIPO NOT IN ('D','B') AND "

		If cSerieId == "D2_SDOC"		
			cQuery += " SD2.D2_SDOC = '"+cSerPesq+"' AND " 	
		Else
			cQuery += " SD2.D2_SERIE = '"+cSerPesq+"' AND " 		
		EndIf

		cQuery += " SD2.D2_DOC = '"+nDoc+"' AND " 		
		cQuery += " SD2.D_E_L_E_T_='' AND "
		cQuery += " SB1.D_E_L_E_T_=''"
		cQuery += " ORDER BY D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_ITEM" 
		    
		cQuery := ChangeQuery(cQuery)                       
        
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias30,.T.,.T.)
		
		TcSetField(cAlias30,"D2_EMISSAO","D",8,0)

		DbSelectArea(cAlias30)

Else
#ELSE

	dbSelectArea("SD2")
	cIndSD2	:=	CriaTrab(NIL,.F.)
	cChave	:=	IndexKey()
	cFiltro	:=	"SD2->D2_FILIAL=='"+xFilial("SD2")+"' .And. DTOS(SD2->D2_EMISSAO)>='"+Dtos(dDtInicial)+"' .AND. DTOS(SD2->D2_EMISSAO)<='"+Dtos(dDtFinal)+"'"						
	cFiltro	+=  " .And. SD2->D2_SERIE == '"+nSerie+"'"
	cFiltro	+=  " .And. SD2->D2_DOC == '"+nDoc+"'"
	cFiltro	+=  " .And. SD2->D2_TIPO !$ 'DB'"
 
	IndRegua("SD2",cIndSD2,cChave,,cFiltro)
	SD2->(DbgoTop()) 

#ENDIF

#IFDEF TOP
EndIF

If TcSrvType()<>"AS/400"
	Do While !(cAlias30)->(Eof())
		DbSelectArea("RT30")
		cReceita:= "1"
		Do Case
			Case (cAlias30)->D2_CF $ cRec1
				cReceita:= "1"
			Case (cAlias30)->D2_CF $ cRec2						
				cReceita:= "2"
			Case (cAlias30)->D2_CF $ cRec3		
				cReceita:= "3"
		EndCase
		RecLock("RT30",.T.)
 		RT30->TIPOREG	:="30"
		RT30->CODPROD	:= GravaCpo((cAlias30)->D2_COD)
		RT30->DESPROD	:= GravaCpo((cAlias30)->B1_DESC)
		RT30->CODNCM	:= GravaCpo((cAlias30)->B1_POSIPI)
		RT30->UNICOM	:= GravaCpo((cAlias30)->D2_UM)
		RT30->QTDCOM	:= StrTran(TRANSFORM((cAlias30)->D2_QUANT,"999999999999.9999"),".",",")
		RT30->VLRCOM	:= StrTran(TRANSFORM((cAlias30)->D2_PRCVEN,"9999999999999999.9999"),".",",")
		RT30->VLRTOT	:= GravaCpo((cAlias30)->D2_TOTAL)
		RT30->CODCST	:= GravaCpo((cAlias30)->D2_CLASFIS)
 		RT30->ALQICM	:= StrTran(TRANSFORM((cAlias30)->D2_PICM,"99.99"),".",",")
   		RT30->ALQIPI	:= StrTran(TRANSFORM((cAlias30)->D2_IPI,"99.99"),".",",")
		RT30->VALIPI	:= GravaCpo((cAlias30)->D2_VALIPI)
		RT30->DOC		:= GravaCpo((cAlias30)->D2_DOC)
		RT30->SERIE		:= GravaCpo((cAlias30)->D2_SERIE)
		RT30->CLIENTE	:= GravaCpo((cAlias30)->D2_CLIENTE)
		RT30->LOJA		:= GravaCpo((cAlias30)->D2_LOJA)
		RT30->(MsUnlock())
		IncProc()
		(cAlias30)->(dbSkip())
   EndDo

Else
#ELSE

	Do While ! SD2->(Eof())
		DbSelectArea("RT30")
		
		cReceita:= "1"
		Do Case
			Case SD2->D2_CF $ cRec1
				cReceita:= "1"
			Case SD2->D2_CF $ cRec2						
				cReceita:= "2"
			Case SD2->D2_CF $ cRec3		
				cReceita:= "3"
		EndCase
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+SD2->D2_COD)
		
		RecLock("RT30",.T.)
 		RT30->TIPOREG	:="30"
		RT30->CODPROD	:= GravaCpo(SD2->D2_COD)
		RT30->DESPROD	:= GravaCpo(SB1->B1_DESC)
		RT30->CODNCM	:= GravaCpo(SB1->B1_POSIPI)
		RT30->UNICOM	:= GravaCpo(SD2->D2_UM)
   		RT30->QTDCOM	:= StrTran(TRANSFORM(SD2->D2_QUANT,"999999999999.9999"),".",",")
		RT30->VLRCOM	:= StrTran(TRANSFORM(SD2->D2_PRCVEN,"9999999999999999.9999"),".",",")
		RT30->VLRTOT	:= GravaCpo(SD2->D2_TOTAL)
		RT30->CODCST	:= GravaCpo(SD2->D2_CLASFIS)
		RT30->ALQICM	:= GravaCpo(SD2->D2_PICM)
		RT30->ALQIPI	:= GravaCpo(SD2->D2_IPI)
		RT30->VALIPI	:= GravaCpo(SD2->D2_VALIPI)
		RT30->DOC		:= GravaCpo(SD2->D2_DOC)
		RT30->SERIE		:= GravaCpo(SD2->D2_SERIE)
		RT30->CLIENTE	:= GravaCpo(SD2->D2_CLIENTE)
		RT30->LOJA		:= GravaCpo(SD2->D2_LOJA)
		
		RT30->(MsUnlock())

		IncProc()
		SD2->(dbSkip())
					
	EndDo
#ENDIF

#IFDEF TOP
EndIF
#ENDIF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exclui area de trabalho utilizada - SD2³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If lQuery
		dbSelectArea(cAlias30)
		dbCloseArea()
	ElSE
		RetIndex("SD2")	
		dbClearFilter()	
		Ferase(cIndex+OrdBagExt())
Endif


Return Nil
  
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcReg40  ³ Autor ³  Vitor Felipe         ³ Data ³ 28.12.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo 40                                    ³±±
±±³			 ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcReg40(nTotProd,nTotIPI,nTotDesc,nTotFret,nTotSegu,nTotDpAc,nTotAISS,nTotVISS,nTotBICM,nTotTICM,nTotBICS,nTotTICS,nTotNF,nDoc,nSerie,nCliente,nLoja)

	RecLock("RT40",.T.)
	RT40->TIPOREG :="40"
       
	RT40->BASICMS := GravaCpo(nTotBICM)
	RT40->VTOTICM := GravaCpo(nTotTICM)
	RT40->BASICST := GravaCpo(nTotBICS)
	RT40->VTOTICS := GravaCpo(nTotTICS)
	RT40->VALTOTP := GravaCpo(nTotProd)
	RT40->VALFRET := GravaCpo(nTotFret)
	RT40->VALSEGU := GravaCpo(nTotSegu)
	RT40->VALDESC := GravaCpo(nTotDesc)
	RT40->VTOTIPI := GravaCpo(nTotIPI)
	RT40->VALOUTD := GravaCpo(nTotDpAc)
	RT40->VALTONF := GravaCpo(nTotNF)
	RT40->VALTCON := GravaCpo(nTotNF)
	RT40->ALIQISS := StrTran(TRANSFORM(nTotAISS,"99.99"),".",",")
	RT40->VALTISS := GravaCpo(nTotVISS)
	//Itens que não vão.
	RT40->DOC		:= GravaCpo(nDoc)
	RT40->SERIE		:= GravaCpo(nSerie)
	RT40->CLIENTE	:= GravaCpo(nCliente)
	RT40->LOJA		:= GravaCpo(nLoja)
	
	RT40->(MsUnlock())
 
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcReg50  ³ Autor ³  Vitor Felipe         ³ Data ³ 28.12.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo 50                                    ³±±
±±³			 ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcReg50(dDtInicial,dDtFinal,nDoc,nSerie,nCliente,nLoja,nEspecie,nVolume,nPLiqui,nPBruto,cTransp,cVeicu)

Local cModFrete := ""
Local cCGC		:= ""
Local cNOME		:= ""
Local cINSEST	:= ""
Local cEnd		:= ""
Local cMun		:= ""
Local cEst		:= ""
Local cEmail	:= ""
Local cPlaca	:= ""
Local cUFPla	:= ""

If !Empty(cTransp)
	dbSelectArea("SA4")
	dbSetOrder(1)
	MsSeek(xFilial("SA4")+SF2->F2_TRANSP)
		cCGC	:= AllTrim(SA4->A4_CGC)
		cNOME	:= SA4->A4_NOME
		cINSEST	:= SA4->A4_INSEST
		cEnd	:= SA4->A4_END
		cMun	:= SA4->A4_MUN
		cEst	:= Upper(SA4->A4_EST)
		cEmail	:= SA4->A4_EMAIL
				
	If !Empty(cVeicu)
		dbSelectArea("DA3")
		dbSetOrder(1)
		MsSeek(xFilial("DA3")+SF2->F2_VEICUL1)
					
		cPlaca	:=	DA3->DA3_PLACA
		cUFPla	:= Upper(DA3->DA3_ESTPLA)

	EndIf
EndIf

DbSelectArea("SD2")
DbSetOrder(3)
DbSeek(xFilial("SD2")+nDoc+nSerie+nCliente+nLoja)

DbSelectArea("SC5")
DbSetOrder(1)
DbSeek(xFilial("SC5")+SD2->D2_PEDIDO)

If SC5->C5_TPFRETE=="C"
	cModFrete := "0"
ElseIf SC5->C5_TPFRETE=="F"
 	cModFrete := "1"
ElseIf SC5->C5_TPFRETE=="T"
 	cModFrete := "2"
ElseIf SC5->C5_TPFRETE=="S"
 	cModFrete := "9" 
Else
	cModFrete := "1" 			 	 	
EndIf  

	RecLock("RT50",.T.)                                       
	RT50->TIPOREG :="50"
	RT50->MODFRET :=GravaCpo(cModFrete)
	RT50->TCNPCPF :=GravaCpo(cCGC)
	RT50->TRSNOME :=GravaCpo(cNOME)
	RT50->TRSIE   :=GravaCpo(cINSEST)
	RT50->TRSEND  :=GravaCpo(cEnd)
	RT50->TRSMUN  :=GravaCpo(cMun)
	RT50->TRSUF   :=GravaCpo(cEst)
	RT50->TRSPLAC :=GravaCpo(cPlaca)
	RT50->TRSUFPL :=GravaCpo(cUFPla)
	RT50->TRSQVOL :=GravaCpo(nVolume)
	RT50->TRSESPE :=GravaCpo(nEspecie)
	RT50->TRSMARC :=""
	RT50->TRSNVOL :=""
	RT50->TRSPESL :=GravaCpo(nPLiqui)
	RT50->TRSPESB :=GravaCpo(nPBruto)
	//Itens que não vão.
	RT50->DOC		:= GravaCpo(nDoc)
	RT50->SERIE		:= GravaCpo(nSerie)
	RT50->CLIENTE	:= GravaCpo(nCliente)
	RT50->LOJA		:= GravaCpo(nLoja)
	
	RT50->(MsUnlock())
  

dbSelectArea("SD2")
dbCloseArea()

dbSelectArea("SC5")
dbCloseArea()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcReg60  ³ Autor ³  Vitor Felipe         ³ Data ³ 28.12.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo 60                                    ³±±
±±³			 ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcReg60(dDtInicial,dDtFinal,cDadfat,nDoc,nSerie,nCliente,nLoja)

Local cMenscli 	:= ""
Local cMensFis	:= ""

DbSelectArea("SD2")
DbSetOrder(3)
DbSeek(xFilial("SD2")+nDoc+nSerie+nCliente+nLoja)

DbSelectArea("SC5")
DbSetOrder(1)
DbSeek(xFilial("SC5")+SD2->D2_PEDIDO)


If !AllTrim(SC5->C5_MENNOTA) $ cMensCli
	If Len(cMensCli) > 0 .And. SubStr(cMensCli, Len(cMensCli), 1) <> " "
		cMensCli += " "
	EndIf
		cMensCli += AllTrim(SC5->C5_MENNOTA)
EndIf
If !Empty(SC5->C5_MENPAD) .And. !AllTrim(FORMULA(SC5->C5_MENPAD)) $ cMensFis
	If Len(cMensFis) > 0 .And. SubStr(cMensFis, Len(cMensFis), 1) <> " "
		cMensFis += " "
	EndIf
		cMensFis += AllTrim(FORMULA(SC5->C5_MENPAD))
EndIf


	RecLock("RT60",.T.)
	RT60->TIPOREG :="60"
	RT60->DADFATU :=GravaCpo(cDadfat)
	RT60->INFADFI :=GravaCpo(cMensfis)
	RT60->INFCPLC :=GravaCpo(cMenscli)
	//Itens que não vão.
	RT60->DOC		:= GravaCpo(nDoc)
	RT60->SERIE		:= GravaCpo(nSerie)
	RT60->CLIENTE	:= GravaCpo(nCliente)
	RT60->LOJA		:= GravaCpo(nLoja)
	
	RT60->(MsUnlock())


dbSelectArea("SD2")
dbCloseArea()

dbSelectArea("SC5")
dbCloseArea()

Return Nil
          
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcReg90  ³ Autor ³  Vitor Felipe         ³ Data ³ 28.12.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo 90                                    ³±±
±±³			 ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcReg90(dDtInicial, dDtFinal)

Default aQuant := {}

If !Empty(aQuant[1])
	RecLock("RT90",.T.)
	RT90->TIPOREG := "90"
	RT90->QUANT20 := AllTrim(StrZero(aQuant[1],5))
	RT90->QUANT30 := AllTrim(StrZero(aQuant[2],5))
	RT90->QUANT40 := AllTrim(StrZero(aQuant[3],5))
	RT90->QUANT50 := AllTrim(StrZero(aQuant[4],5))
	RT90->QUANT60 := AllTrim(StrZero(aQuant[5],5))
	MsUnlock()
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GeraTemp   ³ Autor ³  Vitor Felipe         ³ Data ³ 28.12.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera arquivos temporarios                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraTemp()
	Local aTrbs		:= {}
	Local cArq		:= ""
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³RT10 - Registro Tipo 10 - Cabeçalho (obrigatório um registro por arquivo)  									  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru10	:= {}
	cArq	:= ""
	AADD(aStru10,{"TIPOREG"	    ,"C",002,0})
	AADD(aStru10,{"VERSAO"    	,"C",004,0})
	AADD(aStru10,{"CNPJ"	   	,"C",014,0})
	AADD(aStru10,{"DATAINI"   	,"C",010,0})
	AADD(aStru10,{"DATAFIM"   	,"C",010,0})
	
	cArq := CriaTrab(aStru10)
	dbUseArea(.T.,__LocalDriver,cArq,"RT10")
	IndRegua("RT10",cArq,"TIPOREG")
	AADD(aTrbs,{cArq,"RT10"})


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³RT20 - Registro Tipo 20 - Registro da NFVC (obrigatório, no mínimo, um registro por arquivo) 				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru20	:= {}
	cArq	:= ""
	
	AADD(aStru20,{"TIPOREG"       ,"C",002,0})
	AADD(aStru20,{"FUNREG"        ,"C",001,0})//FUNCAO DO REGISTRO	
	AADD(aStru20,{"JUSTCANC"      ,"C",256,0})//JUSTIFICATIVA DE CANCELAMENTO
	AADD(aStru20,{"NATOPER"       ,"C",060,0})//NATUREZA DA OPERACAO	
	AADD(aStru20,{"SDOC"         ,"C",003,0})//SERIE DA NOTA FISCAL
	AADD(aStru20,{"NUMERO"        ,"C",009,0})//NUMERO DA NOTA FISCAL
	AADD(aStru20,{"DTEMISS"       ,"C",019,0})//DATA DE EMISSAO
	AADD(aStru20,{"DTSAIDA"       ,"C",019,0})//DATA DE SAIDA OU ENTRADA
	AADD(aStru20,{"TIPONF"        ,"C",001,0})//TIPO DE NOTA FISCAL
	AADD(aStru20,{"CODFIS"        ,"C",004,0})//CODIGO FISCAL DE OPERACOES E PRESTACOES
	AADD(aStru20,{"IESUBST"       ,"C",014,0})//IE DO SUBISTITUTO
	AADD(aStru20,{"IEEMITE"       ,"C",015,0})//INCRICAO MUNICIPAL DO EMITENTE
	AADD(aStru20,{"CPFCNPJ"       ,"C",014,0})//CNPF OU CPF DO DESTINATARIO
	AADD(aStru20,{"NOMEDEST"      ,"C",060,0})//Nome do destinatário
	AADD(aStru20,{"LOGRADOURO"    ,"C",060,0})//Logradouro
	AADD(aStru20,{"NUMEND"        ,"C",060,0})//NUmero
	AADD(aStru20,{"COMPL"         ,"C",060,0})//Complemento
	AADD(aStru20,{"BAIRRO"        ,"C",060,0})//Bairro / Distrito
	AADD(aStru20,{"MUNICPIO"      ,"C",060,0})//Município
	AADD(aStru20,{"UF"            ,"C",002,0})//UF
	AADD(aStru20,{"CEP"           ,"C",008,0})//CEP
	AADD(aStru20,{"PAIS"          ,"C",060,0})//PAIS
	AADD(aStru20,{"TELEFONE"      ,"C",010,0})// Telefone
	AADD(aStru20,{"IEDEST"        ,"C",014,0})// INSCRICAO ESTADUAL DO DESTINATARIO
	AADD(aStru20,{"CLIENTE"		  ,"C",030,0})//COD. CLIENTE	
	AADD(aStru20,{"LOJA"		  ,"C",002,0})//COD. LOJA
	AADD(aStru20,{"SERIE"         ,"C",TamSx3("F2_SERIE")[1],0})//SERIE DA NOTA FISCAL
		
	cArq := CriaTrab(aStru20)
	dbUseArea(.T.,__LocalDriver,cArq,"RT20")
	IndRegua("RT20",cArq,"TIPOREG")
	AADD(aTrbs,{cArq,"RT20"})



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³RT30 - Registro Tipo 30 - Mercado, Produto ou Serviço														  |	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru30	:= {}
	cArq	:= ""
	
	AADD(aStru30,{"TIPOREG"       	,"C",002,0})
	AADD(aStru30,{"CODPROD"       	,"C",060,0})//CODIGO PRODUTO SERVICO
	AADD(aStru30,{"DESPROD"       	,"C",120,0})//DESCRICAO DO PRODUTO
	AADD(aStru30,{"CODNCM"        	,"C",008,0})//COD NCM	
	AADD(aStru30,{"UNICOM"        	,"C",006,0})//UNIDADE COMERCIAL
	AADD(aStru30,{"QTDCOM"        	,"C",018,0})//QUANTIDADE COMERCIAL
	AADD(aStru30,{"VLRCOM"        	,"C",021,0})//VALOR UNITARIO COMERCIAL
	AADD(aStru30,{"VLRTOT"        	,"C",018,0})//VALRO TOTAL COMERCIAL
	AADD(aStru30,{"CODCST"        	,"C",003,0})//CODIGO DA SITUACAO TRIBUTARIA
	AADD(aStru30,{"ALQICM"        	,"C",008,0})//ALIQUOTA DO ICMS
	AADD(aStru30,{"ALQIPI"        	,"C",008,0})//ALIQUOTA DO IPI
	AADD(aStru30,{"VALIPI"        	,"C",018,0})//VALOR DO IPI
	//Itens que não vao
	AADD(aStru30,{"DOC"			  	,"C",009,0})//DOCUMENTO NF		
	AADD(aStru30,{"SERIE"		  	,"C",TamSx3("D2_SERIE")[1],0})//SERIE NF	
	AADD(aStru30,{"CLIENTE"		  	,"C",030,0})//COD. CLIENTE	
	AADD(aStru30,{"LOJA"		  		,"C",002,0})//COD. LOJA	
	
	cArq := CriaTrab(aStru30)
	dbUseArea(.T.,__LocalDriver,cArq,"RT30")
	IndRegua("RT30",cArq,"DOC+SERIE+CLIENTE+LOJA")
	AADD(aTrbs,{cArq,"RT30"})
   	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³RT40 - Registro Tipo 40 - Valores totais da NF																  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru40	:= {}
	cArq	:= ""
	
	AADD(aStru40,{"TIPOREG"       ,"C",002,0})
	AADD(aStru40,{"BASICMS"       ,"C",018,0})//BASE DE CALCULO DO ICMS
	AADD(aStru40,{"VTOTICM"       ,"C",018,0})//VALOR TOTAL DO ICMS
	AADD(aStru40,{"BASICST"       ,"C",018,0})//BASE DE CALCULO DO ICMS ST
	AADD(aStru40,{"VTOTICS"       ,"C",018,0})//VALOR TOTAL DO ICMS ST
	AADD(aStru40,{"VALTOTP"       ,"C",018,0})//VALOR TOTAL DE PRODUTOS OU SERVICOS
	AADD(aStru40,{"VALFRET"       ,"C",018,0})//VALOR TOTAL DO FRETE
	AADD(aStru40,{"VALSEGU"       ,"C",018,0})//VALOR TOTAL DO SEGURO
	AADD(aStru40,{"VALDESC"       ,"C",018,0})//VALOR TOTAL DO DESCONTO
	AADD(aStru40,{"VTOTIPI"       ,"C",018,0})//VALOR TOTAL DO IPI
	AADD(aStru40,{"VALOUTD"       ,"C",018,0})//VALOR TOTAL DE OUTRAS DESPESAS
	AADD(aStru40,{"VALTONF"       ,"C",018,0})//VALOR TOTAL DA NOTA FISCAL
	AADD(aStru40,{"VALTCON"       ,"C",018,0})//VALOR TOTAL DE NOTA CONJUGADA
	AADD(aStru40,{"ALIQISS"       ,"C",008,0})//ALIQUOTA DO ISS
	AADD(aStru40,{"VALTISS"       ,"C",018,0})//VALOR TOTAL DO ISS
	//Itens que não vao
	AADD(aStru40,{"DOC"			  ,"C",009,0})//DOCUMENTO NF		
	AADD(aStru40,{"SERIE"		  ,"C",TamSx3("D2_SERIE")[1],0})//SERIE NF	
	AADD(aStru40,{"CLIENTE"		  ,"C",030,0})//COD. CLIENTE	
	AADD(aStru40,{"LOJA"		  ,"C",002,0})//COD. LOJA
	
	cArq := CriaTrab(aStru40)
	dbUseArea(.T.,__LocalDriver,cArq,"RT40")
	IndRegua("RT40",cArq,"DOC+SERIE+CLIENTE+LOJA")
	AADD(aTrbs,{cArq,"RT40"})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³RT50 - Registro Tipo 50 -  Informações do Tranporte da NF													  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru50	:= {}
	cArq	:= ""
	
	AADD(aStru50,{"TIPOREG"       ,"C",002,0})
	AADD(aStru50,{"MODFRET"       ,"C",001,0})//MODALIDADE DO FRETE
	AADD(aStru50,{"TCNPCPF"       ,"C",014,0})//CNPJ OU CPF DO TRANSPORTADOR
	AADD(aStru50,{"TRSNOME"       ,"C",060,0})//NOME DO TRANSPORTADOR
	AADD(aStru50,{"TRSIE"         ,"C",014,0})//IE DO TRANSPORTADOR
	AADD(aStru50,{"TRSEND"   	  ,"C",060,0})//ENDERECO DO TRANSPORTADOR
	AADD(aStru50,{"TRSMUN"        ,"C",060,0})//MUNICIPIO DO TRANSPORTADOR
	AADD(aStru50,{"TRSUF" 	      ,"C",002,0})//UF DO TRANSPORTADOR
	AADD(aStru50,{"TRSPLAC"       ,"C",008,0})//PLACA DO TRANSPORTADOR
	AADD(aStru50,{"TRSUFPL"       ,"C",002,0})//UF PLACA DO TRANSPORTADOR
	AADD(aStru50,{"TRSQVOL"       ,"C",015,0})//QUANTIDADE DE VOLUMES
	AADD(aStru50,{"TRSESPE"       ,"C",060,0})//ESPECIE DOS VOLUMES
	AADD(aStru50,{"TRSMARC"       ,"C",060,0})//MARCA DOS VOLUMES
	AADD(aStru50,{"TRSNVOL"       ,"C",060,0})//NUMERACAO DOS VOLUMES
	AADD(aStru50,{"TRSPESL"       ,"C",015,0})//PESO LIQUIDO
	AADD(aStru50,{"TRSPESB"       ,"C",015,0})//PESO BRUTO
	//Itens que não vao
	AADD(aStru50,{"DOC"			  ,"C",009,0})//DOCUMENTO NF		
	AADD(aStru50,{"SERIE"		  ,"C",TamSx3("D2_SERIE")[1],0})//SERIE NF	
	AADD(aStru50,{"CLIENTE"		  ,"C",030,0})//COD. CLIENTE	
	AADD(aStru50,{"LOJA"		  ,"C",002,0})//COD. LOJA
	
	cArq := CriaTrab(aStru50)
	dbUseArea(.T.,__LocalDriver,cArq,"RT50")
	IndRegua("RT50",cArq,"DOC+SERIE+CLIENTE+LOJA")
	AADD(aTrbs,{cArq,"RT50"})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³RT60 - Registro Tipo 60 - Informações Adicionais ou de Cobrança.												  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru60	:= {}
	cArq	:= ""
	
	AADD(aStru60,{"TIPOREG"       ,"C",002,0})
	AADD(aStru60,{"DADFATU"       ,"C",256,0})//DADOS DA FATURA
	AADD(aStru60,{"INFADFI"       ,"C",256,0})//INFORMACOES ADICIONAIS FISCO
	AADD(aStru60,{"INFCPLC"       ,"C",256,0})//INFORMACOES ADICIONAIS CONTRIBUINTE
	//Itens que não vao
	AADD(aStru60,{"DOC"			  ,"C",009,0})//DOCUMENTO NF		
	AADD(aStru60,{"SERIE"		  ,"C",TamSx3("D2_SERIE")[1],0})//SERIE NF	
	AADD(aStru60,{"CLIENTE"		  ,"C",030,0})//COD. CLIENTE	
	AADD(aStru60,{"LOJA"		  ,"C",002,0})//COD. LOJA
		
	cArq := CriaTrab(aStru60)
	dbUseArea(.T.,__LocalDriver,cArq,"RT60")
	IndRegua("RT60",cArq,"DOC+SERIE+CLIENTE+LOJA")
	AADD(aTrbs,{cArq,"RT60"})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³RT90 - Registro do Tipo 90 - Registro rodapé (obrigatório um registro por arquivo)             				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru90	:= {}
	cArq	:= ""

	AADD(aStru90,{"TIPOREG"       ,"C",002,0})//	Tipo de registro	2	-	Numérico	Sim	Preencher com o valor "90" para indicar o tipo de registro
	AADD(aStru90,{"QUANT20"       ,"C",005,0})//	Quantidade de registros tipo 20
	AADD(aStru90,{"QUANT30"       ,"C",005,0})//	Quantidade de registros tipo 30
	AADD(aStru90,{"QUANT40"       ,"C",005,0})//	Quantidade de registros tipo 40
	AADD(aStru90,{"QUANT50"       ,"C",005,0})//	Quantidade de registros tipo 50
	AADD(aStru90,{"QUANT60"       ,"C",005,0})//	Quantidade de registros tipo 60

	cArq := CriaTrab(aStru90)
	dbUseArea(.T.,__LocalDriver,cArq,"RT90")
	IndRegua("RT90",cArq,"TIPOREG")
	AADD(aTrbs,{cArq,"RT90"})



Return (aTrbs)
                 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CFP        ³ Autor ³  Vitor Felipe         ³ Data ³ 28.12.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Rotina LoadCFP                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LoadCFP()
	Local aTxtPre 		:= {}
	Local aPaineis 		:= {}
	
	Local cTitObj1		:= ""
	Local cTitObj2		:= ""       
	Local cMask2		:= Replicate("!",20)
	Local cMask3		:= Replicate("!",50)
    Local cMask4		:= Replicate("!",04)
    Local cMask5		:= Replicate("!",03)
    Local cMask6		:= Replicate("!",09)    
	Local nPos			:= 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta wizard com as perguntas necessarias³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aTxtPre,STR0015)			//"Assistente de parametrização da NFA Nota Fiscal Alagoana"
	AADD(aTxtPre,STR0016)			//"Atenção"
	AADD(aTxtPre,STR0017)			//"Preencha as informações solicitadas para a geração do arquivo magnetico"
	AADD(aTxtPre,STR0018)	   		//"NFA Nota Fiscal Alagoana - Sefaz AL"

		

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 1 -  Configuração do período e parametros da geração :                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	aAdd(aPaineis,{})
	nPos :=	Len(aPaineis)
	aAdd(aPaineis[nPos],STR0019)	//"Assistente de parametrização"
	aAdd(aPaineis[nPos],STR0020)	//"Configuração do período e parametros da geração : "

	aAdd(aPaineis[nPos],{})
	
	cTitObj1 :=	STR0012 //"Data Inicial "		
	cTitObj2 :=	STR0013// "Data Final "		    
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,"@d",3,,,,8})	
	aAdd(aPaineis[nPos][3],{2,,"@d",3,,,,8})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	

	cTitObj1 :=	STR0031 //"Diretorio de Geracao"
	cTitObj2 :=	STR0032 //"Nome do arquivo"  	
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask3,1,,,,20})
	aAdd(aPaineis[nPos][3],{2,,cMask2,1,,,,20})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})     

	cTitObj1 :=	STR0033 //"Versão do arquivo"
	cTitObj2 :=	STR0042	//"Tipo de Nota"			          
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask4,1,,,,20})	
	aAdd(aPaineis[nPos][3],{3,,,,,{STR0043,STR0044},,})//"0=Entrada""1=Saida"
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})     

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 2 - Informação de Filtro                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	aAdd(aPaineis,{})
	nPos :=	Len(aPaineis)
	aAdd(aPaineis[nPos],STR0019)
	aAdd(aPaineis[nPos],STR0037)//"Informação de Filtro" ) 
	aAdd(aPaineis[nPos],{})


	cTitObj1 :=	STR0038//"Serie Inicial"
	cTitObj2 :=	STR0039//"Nota Fiscal Inicial"
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask5,1,,,,20})
	aAdd(aPaineis[nPos][3],{2,,cMask6,1,,,,20})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})     


	cTitObj1 :=	STR0040 //"Serie Final"
	cTitObj2 :=	STR0041 //"Nota Fiscal Final"
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask5,1,,,,20})
	aAdd(aPaineis[nPos][3],{2,,cMask6,1,,,,20})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})     

   	cTitObj1 :=	STR0048 //"Funcao do Registro"
   	cTitObj2 :=	STR0049 //"Justi. de Cancelamento"
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{3,,,,,{STR0045,STR0046,STR0047},,20}) //INCLUSAO/RETIFICACAO/CANCELAMENTO
	aAdd(aPaineis[nPos][3],{2,,cMask2,1,,,,20})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})     

	


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 3 - Informação de operaç]oes fiscais                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	aAdd(aPaineis,{})
	nPos :=	Len(aPaineis)
	aAdd(aPaineis[nPos],STR0019)
	aAdd(aPaineis[nPos],STR0034 ) //"Informação de operacoes fiscais e financeiras"
	aAdd(aPaineis[nPos],{})
	
	cTitObj1 :=	STR0021 //"Serie D (Separadas por '/' - Exemplo: '001/2  /UNI')"
	cTitObj2 :=	STR0022 //"Serie D Unica (Separadas por '/' - Exemplo: '001/2  /UNI')"
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask3,1,,,,20})	
	aAdd(aPaineis[nPos][3],{2,,cMask3,1,,,,20})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	
	cTitObj1 :=	STR0023 //"Serie Unica (Separadas por '/' - Exemplo: '001/2  /UNI')"		          		    	            //Cfp[1][01]
	cTitObj2 :=	STR0028 //"CFOP's Revenda"
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask3,1,,,,20})
	aAdd(aPaineis[nPos][3],{2,,cMask2,1,,,,20})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})     
	
	cTitObj1 :=	STR0029 //"CFOP's Venda Industrialização"
	cTitObj2 :=	STR0030 //"CFOP's Venda Substituição tributária"
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask3,1,,,,20})	
	aAdd(aPaineis[nPos][3],{2,,cMask3,1,,,,20})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})     

	cTitObj1 :=	STR0024 //"Empresa efetua venda à prazo?"
	cTitObj2 := STR0025 //"Empresa entrega em domicilio?"
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{3,,,,,{STR0026,STR0027},,}) //"Sim"###"Não"
	aAdd(aPaineis[nPos][3],{3,,,,,{STR0026,STR0027},,}) //"Sim"###"Não"
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})     
		
Return(xMagWizard(aTxtPre,aPaineis,"NFAII")) 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NfaIIDel    ºAutor  ³  Vitor Felipe         ³ Data ³ 28.12.10 ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Deleta os arquivos temporarios processados                    º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³NFA                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/         
Function NfaIIDel(aDelArqs)
	Local aAreaDel := GetArea()
	Local nI := 0
	
	For nI:= 1 To Len(aDelArqs)
		If File(aDelArqs[nI,1]+GetDBExtension())
			dbSelectArea(aDelArqs[ni,2])
			dbCloseArea()
			Ferase(aDelArqs[nI,1]+GetDBExtension())
			Ferase(aDelArqs[nI,1]+OrdBagExt())
		Endif	
	Next
	
	RestArea(aAreaDel)
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NFADATA     ºAutor  ³  Vitor Felipe      ³ Data ³ 28.12.10    ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Deleta os arquivos temporarios processados                    º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³NFA                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

Static Function NFADATA(dDataEnt,cChar) 
Local cData  := ""
Default cChar:= "/"

cData := Dtos(dDataEnt)
cData := Substr(cData,7,2) + cChar + Substr(cData,5,2) + cChar + Substr(cData,1,4)

Return(cData)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GravaCpo    ºAutor  ³  Vitor Felipe      ³ Data ³ 28.12.10    ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Deleta os arquivos temporarios processados                    º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³NFA                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

Static Function GravaCpo(uDado,nTamMax) 
Local uRetorno  := ""
Default nTamMax := 0

Do Case 
	Case ValType(uDado)=="C"
		uDado := StrTran(uDado,".","")
		uDado := StrTran(uDado,",","")
		uDado := StrTran(uDado,"-","")
		uDado := StrTran(uDado,"_","")

		If nTamMax > 0
			uRetorno := Substr(uDado,1,nTamMax)
		Else
			uRetorno := uDado
		EndIf

	Case ValType(uDado)=="N"
		uRetorno := StrTran(TRANSFORM(uDado,"999999999999999.99"),".",",")

	Case ValType(uDado)=="D"	
			uRetorno := NFADATA(uDado,"/")
	OtherWise
			uRetorno := uDado
EndCase

Return(uRetorno)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GravaArq    ºAutor  ³  Vitor Felipe      ³ Data ³ 28.12.10    ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Deleta os arquivos temporarios processados                    º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³NFA                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

Static Function GravaArq(cReg,aStruImp) 
Local lRetorno  := ""
Local Nx        := 0
Local Ny        := 0
Local Nz        := 0
Local cAlias	:= "RT"+cReg
Local cFiltro	:= ""
Default aQuant	:= {}
Default aStruImp:= {}
Default aStru10	:= {}
Default aStru20	:= {}
Default aStru30	:= {}
Default aStru40	:= {}
Default aStru50	:= {}
Default aStru60	:= {}

Do Case

Case cReg == "10"
	DbSelectArea(cAlias)
	DbSetOrder(1)
	DbGoTop()
	//REGISTRO 10
	For Nx:=1 to Len(aStru10)
		If nX == Len(aStru10)	
			GravaReg( AllTrim( RT10->&(aStru10[nX][1]) ) ,"END" )  
		Else
			GravaReg( AllTrim( RT10->&(aStru10[nX][1]) ) ,"|"   )  
		EndIf
	nQuant10 += 1
	Next nX

//REGISTRO 20
Case cReg == "20"
	DbSelectArea("RT20")
	DbSetOrder(1)
	DbGoTop()
	Do While ("RT20")->(!Eof())
		For nX:=1 to Len(aStru20)  -1 
			If nX == (Len(aStru20)) -1	
				GravaReg( AllTrim( RT20->&(aStru20[nX][1]) ) ,"END" )
				aQuant[1] += 1 
				
				//REGISTRO 30
				DbSelectArea("RT30")
   				DbSetOrder(1)			
				dbGoTop()
				If("RT20")->FUNREG <> "C" //Se cancelamento nao gerar Registro 30
					cFiltro := 'AllTrim(RT30->DOC)==Alltrim(("RT20")->NUMERO).AND.AllTrim(RT30->SERIE)==AllTrim(("RT20")->SERIE).AND.AllTrim(RT30->CLIENTE)==AllTrim(("RT20")->CLIENTE)'
					dbSetFilter({|| &cFiltro }, cFiltro )
					dbGotop()
						nLenStru30 := len(aStru30) - 4
						Do While("RT30")->(!Eof())
							For nY := 1 to nLenStru30
								If Ny == nLenStru30	
									GravaReg( AllTrim( RT30->&(aStru30[ny][1]) ) ,"END" )  
									aQuant[2] += 1
								Else
									GravaReg( AllTrim( RT30->&(aStru30[ny][1]) ) ,"|" )  
								EndIf				
							Next nY
						("RT30")->(dbSkip())
					    EndDo

				//REGISTRO 40
					DbSelectArea("RT40")
					DbSetOrder(1)			
					dbGoTop()	
					If DbSeek(Padr(("RT20")->NUMERO,9)+Padr(("RT20")->SERIE,3)+Padr(("RT20")->CLIENTE,30)+Padr(("RT20")->LOJA,2))
						For nZ:=1 to Len(aStru40)-4
							If nZ == Len(aStru40)-4	
								GravaReg( AllTrim( RT40->&(aStru40[nZ][1]) ) ,"END" )  
								aQuant[3] += 1
							Else
								GravaReg( AllTrim( RT40->&(aStru40[nZ][1]) ) ,"|"   )  
							EndIf
						Next nZ
					EndIf

				//REGISTRO 50
					DbSelectArea("RT50")
					DbSetOrder(1)			
					dbGoTop()	
					If DbSeek(Padr(("RT20")->NUMERO,9)+Padr(("RT20")->SERIE,3)+Padr(("RT20")->CLIENTE,30)+Padr(("RT20")->LOJA,2))
						For nZ:=1 to Len(aStru50)-4
							If nZ == Len(aStru50)-4	
								GravaReg( AllTrim( RT50->&(aStru50[nZ][1]) ) ,"END" )  
								aQuant[4] += 1
							Else
								GravaReg( AllTrim( RT50->&(aStru50[nZ][1]) ) ,"|"   )  
							EndIf
						Next nZ
					EndIF

				//REGISTRO 60
					DbSelectArea("RT60")
					DbSetOrder(1)			
					dbGoTop()	
					If DbSeek(Padr(("RT20")->NUMERO,9)+Padr(("RT20")->SERIE,3)+Padr(("RT20")->CLIENTE,30)+Padr(("RT20")->LOJA,2))
						For nZ:=1 to Len(aStru60)-4	
							If nZ == Len(aStru60)-4	
								GravaReg( AllTrim( RT60->&(aStru60[nZ][1]) ) ,"END" )  
								aQuant[5] += 1
							Else
								GravaReg( AllTrim( RT60->&(aStru60[nZ][1]) ) ,"|"   )  
							EndIf
						Next nZ
					EndIf
				EndIf
			Else
				GravaReg( AllTrim( ("RT20")->&(aStru20[nx][1]) ) ,"|"   )  
			EndIf				
		Next nX
		("RT20")->(dbSkip())
	EndDo	

Case cReg == "90"
//REGISTRO 90
	DbSelectArea("RT90")
	DbSetOrder(1)			
	dbGoTop()	
	For nX:=1 to Len(aStru90)
		If nX == Len(aStru90)	
			GravaReg( AllTrim( RT90->&(aStru90[nX][1]) ) ,"END" )  
		Else
			GravaReg( AllTrim( RT90->&(aStru90[nX][1]) ) ,"|"   )  
		EndIf
	Next nX

EndCase

Return(aQuant) //(.T.)	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GravaReg    ºAutor  ³  Vitor Felipe      ³ Data ³ 28.12.10    ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Deleta os arquivos temporarios processados                    º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³NFA                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

Static Function GravaReg(cDetalhe, cChar)

	cHandle := "nArq1"
    If cChar == "END"
		FWrite(&cHandle,cDetalhe + CRLF)
    Else
		FWrite(&cHandle,cDetalhe + cChar,Len(cDetalhe+cChar))    
    EndIf

Return 