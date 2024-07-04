#INCLUDE "PROTHEUS.CH"      
#INCLUDE "NFEARG.CH"

//Posicoes do array de impostos
#DEFINE IVA  01 
#DEFINE RNI  02 
#DEFINE PIB  03    
#DEFINE PIN  04    
#DEFINE PIM  05    
#DEFINE PII  06    
#DEFINE MAX_DEFIMP  06           

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³NFEARG    ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 17.04.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Nota Fiscal Eletronica - Argentina                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NfeArg()

Local lQuery	:= .F.
Local cQuerySF3	:= ""
Local aStruSF3	:= {}
Local cIndexSF3	:= ""
Local nIndexSF3	:= 0
Local cChaveSF3	:= ""
Local cNfAtu	:= ""
Local cEspecieV	:= GetNewPar("MV_NFEARG1","NF/NDC/NCC")		//Especies de NFs validas
Local cSerieV	:= GetNewPar("MV_NFEARG2","A/B")			//Series de NFs validas
Local cPtoVen	:= ""										//Ponto de Venda 
Local cPerg		:= "FACARG"
Local nI		:= 0

Private cAliasSF3	:= "SF3"
Private aSeqNf		:= {"",0}
Private cTipoVen	:= ""
Private lReenvia	:= .F.
Private lFechas		:= .T.
Private oTpTable1	:= NIL
Private oTpTable2	:= NIL

Pergunte(cPerg,.T.)

cPtoVen	 := StrZero(Val(MV_PAR01),4)					//Ponto de Venda 
cTipoVen := Iif(MV_PAR02==1,"B","S")					//Tipo de Venda
lReenvia := Iif(MV_PAR09==1,.T.,.F.)					//Reenvia nfe's do periodo selecionado
lFechas  := Iif(MV_PAR10==1,.T.,.F.)					//Se as datas estarao zeradas, ou nao.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera arquivo temporario                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GeraTemp()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico se e um ponto de venda valido             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPtoVen == "0000" .Or. cPtoVen == "9999"
    MsgAlert(STR0004) //"Atención!! El punto de venta nos es válido. Tiene que estar entre 0001 y 9998!"
	Return()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se as categorias de impostos foram        ³
//³configuradas corretamente                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ChecaParam()

	_aTotal[12] := Substr(Dtos(dDmainc),1,6)
	_aTotal[13] := SM0->M0_CGC	
	
	#IFDEF TOP
		If TcSrvType()<>"AS/400"
			lQuery := .T.
		Endif
	#ENDIF
	
	dbSelectArea("SF3")
	If lQuery
		cAliasSF3	:= "TopSF3"
		aStruSF3	:= SF3->(dbStruct())           
		cQuerySF3	:= "SELECT *"
		cQuerySF3	+= " FROM " + RetSQLName("SF3") 
		cQuerySF3	+= " WHERE F3_FILIAL = '"+xFilial("SF3")+"' AND"
		cQuerySF3	+= " F3_DTCANC = ' ' AND"	
		cQuerySF3	+= " F3_FORMUL = 'S' AND"		
		cQuerySF3	+= " SUBSTRING(F3_NFISCAL,1,4) = '"+cPtoVen+"' AND"
		cQuerySF3	+= " F3_EMISSAO BETWEEN '"+Dtos(dDmainc)+ "' AND '"+Dtos(dDmaFin)+"' AND"    
		cQuerySF3	+= " F3_CAE = ' ' AND"	
		
		If !lReenvia
			cQuerySF3	+= " F3_NFEARG = ' ' AND" 
		Endif
		cQuerySF3	+= " D_E_L_E_T_ = ' '"
		cQuerySF3	+= " ORDER BY F3_EMISSAO,F3_SERIE,F3_NFISCAL"
	
		cQuerySF3	:= ChangeQuery(cQuerySF3)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuerySF3),cAliasSF3,.F.,.T.)	
	
		For nI := 1 To Len(aStruSF3)
			If aStruSF3[nI][2] != "C" 
				TCSetField(cAliasSF3,aStruSF3[nI][1],aStruSF3[nI][2],aStruSF3[nI][3],aStruSF3[nI][4])
			EndIf
		Next nI           
	Else
		cIndexSF3 := CriaTrab(Nil,.F.)
		cChaveSF3 := "DTOS(F3_EMISSAO)+F3_SERIE+F3_NFISCAL"
		cQuerySF3 := "F3_FILIAL == '"+xFilial("SF3")+"' .And. "
		cQuerySF3 += "Empty(F3_DTCANC) .And. "	
		cQuerySF3 += "F3_FORMUL == 'S' .And. "		
		cQuerySF3 += "Left(F3_NFISCAL,4) == '"+cPtoVen+"' .And. "
		cQuerySF3 += "Empty(F3_CAE) .And. "	
		cQuerySF3 += "Dtos(F3_EMISSAO) >= '"+Dtos(dDmainc)+"' .And. Dtos(F3_EMISSAO) <= '"+Dtos(dDmaFin)+"'"

		If !lReenvia
			cQuerySF3	+= " .And. Empty(F3_NFEARG) " 
		Endif
		
		IndRegua("SF3",cIndexSF3,cChaveSF3,,cQuerySF3,OemToAnsi(STR0001)) //"Selecionando Registros..."
			
		nIndexSF3 := RetIndex("SF3")
		dbSelectArea("SF3")
		dbSetIndex(cIndexSF3+OrdBagExt())
		dbSetOrder(nIndexSF3+1)
	Endif
	                                                                    	
	dbSelectArea(cAliasSF3)
	dbGoTop()
	While !Eof()
		IncProc()
		If Alltrim(F3_TPVENT) == cTipoVen .Or. Alltrim(F3_TPVENT) == IIf(cTipoVen == "B","1","2")
			If Alltrim(F3_ESPECIE) $ cEspecieV .And. Left(Alltrim(F3_SERIE),1) $ cSerieV
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se eh a mesma nota                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cNfAtu <> Dtos(F3_EMISSAO)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA
					cNfAtu := Dtos(F3_EMISSAO)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA
					ProcReg(cAliasSF3)
			    Endif
			Endif
		Endif
		dbSelectArea(cAliasSF3)
		dbSkip() 
	Enddo
	
	If lQuery
		dbSelectArea(cAliasSF3)
		dbCloseArea()
	Else
	  	dbSelectArea(cAliasSF3)
		RetIndex(cAliasSF3)
		dbClearFilter()
		Ferase(cIndexSF3+OrdBagExt())
	EndIf
	
Endif

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcReg    ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 17.04.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registros                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcReg(cAliasSF3)

Local aArea		:= GetArea()
Local cNota		:= (cAliasSF3)->F3_NFISCAL
Local cSerie	:= (cAliasSF3)->F3_SERIE
Local cCliFor	:= (cAliasSF3)->F3_CLIEFOR
Local cLoja		:= (cAliasSF3)->F3_LOJA
Local cTES		:= (cAliasSF3)->F3_TES
Local aCab      := {} 
Local aImps     := {}        
Local cAliasSF  := Iif(cTES >= "500","SF2","SF1")     
Local cAliasSD  := Iif(cTES >= "500","SD2","SD1")     
LocaL cAliasCF  := "SA1"
Local nTotIsen  := 0
Local nTotNAlc  := 0
Local nLimLotB	:= GetNewPar("MV_NFEARG3",1000)			//Limite em pesos para geracao em Lote
Local cPtoVen	:= StrZero(Val(MV_PAR01),4)				//Ponto de Venda
Local cCpoSF    := ""
Local cIDAnt	:= ""                     
Local cDtaIniSer := "00000000"	
Local cDtaFinSer := "00000000" 
Local cFecEmis	 := "00000000" 
Local  nValImp:=0
Local cVencto := ""  
Local cSF := SubStr(cAliasSF,2,2) 
Local cSD := SubStr(cAliasSD,2,2)
Local nDecimais := MsDecimais(1)
Local cCpo13	:= 0
Private aDImps	:= Array(MAX_DEFIMP,03)

// Moeda e Taxa para a factura/nota corrente.
Private nMoedaCor := 0
Private nTaxaMoeda:= 0
Private dDtaDgt 

//Chama funcao que cria os arrays de impostos...
CriaArrayImp()

dbSelectArea(cAliasSF)
dbSetOrder(1)
If dbSeek(xFilial(cAliasSF)+cNota+cSerie+cCliFor+cLoja)
	
	cCpoSF := (cAliasSF)->(&(cSF+"_CAE"))
		
	If Empty(cCpoSF)
			
		// Armazena a moeda e a respectiva taxa...
		nMoedaCor  := (cAliasSF)->(&(cSF+"_MOEDA"))
		nTaxaMoeda := (cAliasSF)->(&(cSF+"_TXMOEDA"))
		dDtaDgt    := (cAliasSF)->(&(cSF+"_DTDIGIT"))
		cDtaIniSer := Dtos((cAliasSF)->(&(cSF+"_FECDSE")))	
		cDtaFinSer := Dtos( (cAliasSF)->(&(cSF+"_FECHSE")) ) 
		cFecEmis   := Iif(lFechas,Dtos((cAliasSF)->(&(cSF+"_DTDIGIT")) ),"00000000")
			
		If cAliasSD == "SD2"
			(cAliasSD)->(dbSetOrder(3))
		Else
			(cAliasSD)->(dbSetOrder(1))
		EndIf
			
		If (cAliasSD)->(dbSeek(xFilial(cAliasSD)+cNota+cSerie+cCliFor+cLoja))
			While !(cAliasSD)->(Eof()) .And.	xFilial(cAliasSD)+(cAliasSD)->(&(cSD+"_DOC"))+(cAliasSD)->(&(cSD+"_SERIE"))+(cAliasSD)->(&(cSD+Iif(cAliasSD == "SD2","_CLIENTE","_FORNECE")))+(cAliasSD)->(&(cSD+"_LOJA")) == ;
				xFilial(cAliasSD)+(cAliasSF)->(&(cSF+"_DOC"))+(cAliasSF)->(&(cSF+"_SERIE"))+(cAliasSF)->(&(cSF+Iif(cAliasSF == "SF2","_CLIENTE","_FORNECE")))+(cAliasSF)->(&(cSF+"_LOJA"))
					
				nCpo13 := PesqInfImp(cAliasSD,IVA,"3",(cAliasSD)->(&(cSD+"_TES")) )[1]	//Campo 13 - Aliquota de IVA
				IndExGrv(DesTrans(nCpo13,2),@nTotIsen,@nTotNAlc,cAliasSD,.F.)				//Campo 14 - Indicacao de Isento ou Gravado

				//Gera array com o total de cada imposto...
				AAdd(aImps,aClone(aDImps))
					
				(cAliasSD)->(dbSkip())
			Enddo
		Endif

		AAdd(aCab,"1")                      	//Campo 01 - Tipo de Registro
		AAdd(aCab,cFecEmis)						//Campo 02 - Data do comprovante
		AAdd(aCab,M991TpComp(cAliasSF,(cAliasSF)->(&(cSF+"_SERIE")),(cAliasSF)->(&(cSF+"_ESPECIE")) ))	//Campo 03 - Tipo de comprovante
		AAdd(aCab,"")							//Campo 04 - Controlador Fiscal ( *** NAO INFORMAR *** )
		AAdd(aCab,cPtoVen)						//Campo 05 - Ponto de Venda
		AAdd(aCab,Substr(cNota,5,8))			//Campo 06 - Numero do comprovante
		AAdd(aCab,Substr(cNota,5,8))			//Campo 07 - Numero do comprovante registrado
		AAdd(aCab,0)							//Campo 08 - Quantidade de paginas ( *** NAO INFORMAR *** )
			
		Do Case									//Campo 09 - Codigo de documento identificador do comprador
			Case (Left(Alltrim(cSerie),1) == "B" .And. Round(xMoeda((cAliasSF)->(&(cSF+"_VALBRUT")),(cAliasSF)->(&(cSF+"_MOEDA")),1,(cAliasSF)->(&(cSF+"_EMISSAO")),nDecimais+1,(cAliasSF)->(&(cSF+"_TXMOEDA")) ),nDecimais) < nLimLotB)	//Por Lote
				AAdd(aCab,"99")
			Otherwise
				cIDAnt := PesqIdCliFor(cAliasCF,"5",Round(xMoeda((cAliasSF)->(&(cSF+"_VALBRUT")),(cAliasSF)->(&(cSF+"_MOEDA")),1,(cAliasSF)->(&(cSF+"_EMISSAO")),nDecimais+1,(cAliasSF)->(&(cSF+"_TXMOEDA")) ),nDecimais))
				AAdd(aCab,cIDAnt)
		EndCase
			
		If Left(Alltrim(cSerie),1) == "B" .And. Round(xMoeda((cAliasSF)->(&(cSF+"_VALBRUT")),(cAliasSF)->(&(cSF+"_MOEDA")),1,(cAliasSF)->(&(cSF+"_EMISSAO")),nDecimais+1,(cAliasSF)->(&(cSF+"_TXMOEDA"))),nDecimais) < nLimLotB	//Por Lote
			AAdd(aCab,Replicate("0",11))	//Campo 10 - Numero de identificacao do comprador
			AAdd(aCab,"")					//Campo 11 - Nome e sobrenome do comprador ou denominacao do comprador
		Else
			AAdd(aCab,PesqIdCliFor(cAliasCF,"2",Round(xMoeda((cAliasSF)->(&(cSF+"_VALBRUT")),(cAliasSF)->(&(cSF+"_MOEDA")),1,(cAliasSF)->(&(cSF+"_EMISSAO")),nDecimais+1,(cAliasSF)->(&(cSF+"_TXMOEDA"))),nDecimais),cIDAnt))	//Campo 10 - Numero de identificacao do comprador
			AAdd(aCab,PesqIdCliFor(cAliasCF,"4",Round(xMoeda((cAliasSF)->(&(cSF+"_VALBRUT")),(cAliasSF)->(&(cSF+"_MOEDA")),1,(cAliasSF)->(&(cSF+"_EMISSAO")),nDecimais+1,(cAliasSF)->(&(cSF+"_TXMOEDA"))),nDecimais)))		//Campo 11 - Nome e sobrenome do comprador ou denominacao do comprador
		Endif
		nValImp := TotCat(IVA,"1",aImps,"2",,,,,.T.)
			
		If nValImp == 0 
	   		nValImp:=Round(xMoeda((cAliasSF)->(&(cSF+"_VALMERC")),(cAliasSF)->(&(cSF+"_MOEDA")),1,(cAliasSF)->(&(cSF+"_EMISSAO")),nDecimais+1,(cAliasSF)->(&(cSF+"_TXMOEDA")) ),nDecimais) - (nTotIsen+nTotNAlc) 
	   	EndIf	         
		
		AAdd(aCab,Round(xMoeda((cAliasSF)->(&(cSF+"_VALBRUT")),(cAliasSF)->(&(cSF+"_MOEDA")),1,(cAliasSF)->(&(cSF+"_EMISSAO")),nDecimais+1,(cAliasSF)->(&(cSF+"_TXMOEDA"))),nDecimais))					//Campo 12 - Importe total de la operacion			
		AAdd(aCab,Round(xMoeda(nTotNAlc,(cAliasSF)->(&(cSF+"_MOEDA")),1,(cAliasSF)->(&(cSF+"_EMISSAO")),nDecimais+1,(cAliasSF)->(&(cSF+"_TXMOEDA"))),nDecimais))								//Campo 13 - Valor total que nao teve incidencia de IVA
		AAdd(aCab,nValImp)																														//Campo 14 - Importe neto gravado			

		AAdd(aCab,TotCat(IVA,"2",aImps,"2",,,,,.T.)) 	//Campo 15 - Imposto Liquidado
		AAdd(aCab,TotCat(RNI,"2",aImps,"2",,,,,.T.))	//Campo 16 - Imposto Liquidado a RNI
		AAdd(aCab,Round(xMoeda(nTotIsen,(cAliasSF)->(&(cSF+"_MOEDA")),1,(cAliasSF)->(&(cSF+"_EMISSAO")),nDecimais+1,(cAliasSF)->(&(cSF+"_TXMOEDA")) ),nDecimais))								//Campo 17 - Importe de operacoes Isentas			
		AAdd(aCab,TotCat(PIN,"2",aImps,"2",,,,,.T.))	//Campo 18 - Importe de percepciones ou pagos a conta sobre impostos nacionais
		AAdd(aCab,TotCat(PIB,"2",aImps,"2",,,,,.T.))	//Campo 19 - Importe de percepciones de ingresos brutos
		AAdd(aCab,TotCat(PIM,"2",aImps,"2",,,,,.T.))	//Campo 20 - Importe de percepciones de impostos municipais
		AAdd(aCab,TotCat(PII,"2",aImps,"2",,,,,.T.))	//Campo 21 - Importe de impostos internos		
		If (Alias()$"SF2|SD2")
			cPrefixo :=	Iif(Empty((cAliasSF)->F2_PREFIXO), &(SuperGetMV ("MV_1DUPREF")), SF2->F2_PREFIXO) 
			
			DbSelectArea("SE1")				
			SE1->(dbSetOrder(2))
			If SE1->(MsSeek(xFilial("SE1")+(cAliasSF)->F2_CLIENTE+(cAliasSF)->F2_LOJA+cPrefixo+(cAliasSF)->F2_DOC))
			
				Do While SE1->(!EOF()) .AND. (cAliasSF)->F2_CLIENTE == SE1->E1_CLIENTE .AND. (cAliasSF)->F2_LOJA == SE1->E1_LOJA .AND. (cAliasSF)->F2_DOC == SE1->E1_NUM
					cVencto := alltrim(str(year(SE1->E1_VENCREA)))+strzero(month(SE1->E1_VENCREA),2)+alltrim(strzero(day(SE1->E1_VENCREA),2))
					dbSkip()
				EndDo					
			EndIf
			DbCloseArea()					
				
		Else
	   		cPrefixo :=	Iif (Empty((cAliasSF)->F1_PREFIXO), &(SuperGetMV ("MV_2DUPREF")), SF1->F1_PREFIXO)		
				
			DbSelectArea("SE1")
			SE1->(dbSetOrder(2))
			If SE1->(MsSeek(xFilial("SE1")+(cAliasSF)->F1_FORNECE+(cAliasSF)->F1_LOJA+cPrefixo+(cAliasSF)->F1_DOC))
			
				Do While SE1->(!EOF()) .AND. (cAliasSF)->F1_FORNECE == SE1->E1_CLIENTE .AND. (cAliasSF)->F1_LOJA == SE1->E1_LOJA .AND. (cAliasSF)->F1_DOC == SE1->E1_NUM
					cVencto := alltrim(str(year(SE1->E1_VENCREA)))+strzero(month(SE1->E1_VENCREA),2)+alltrim(strzero(day(SE1->E1_VENCREA),2))
					dbSkip()
				EndDo					
			EndIf
			DbCloseArea()					
			
	   	EndIF			
			
		If cTipoVen == "B" 
			AAdd(aCab,0)							//Campo 22 - Transporte ( *** NAO INFORMAR *** )
			AAdd(aCab,PesqIdCliFor(cAliasCF,"3"))	//Campo 23 - Tipo de responsavel
			AAdd(aCab,"")							//Campo 24 - Codigo da moeda ( *** NAO INFORMAR *** )
			AAdd(aCab,0)							//Campo 25 - Tipo de cambio ( *** NAO INFORMAR *** )
		Else			
			AAdd(aCab,cDtaIniSer)					//Campo 22 - Fecha desde del servicio faturado
			AAdd(aCab,cDtaFinSer)					//Campo 23 - Fecha hasta del servicio faturado		
			AAdd(aCab,cVencto)				   		//Campo 24 - Fecha de vencimiento para el pago del servicio faturado   
			AAdd(aCab,"")							//Campo 25 - branco		
		EndIF				
		AAdd(aCab,0)	 						//Campo 26 - Quantidade de aliquotas de IVA ( *** NAO INFORMAR *** )
		AAdd(aCab,"")							//Campo 27 - Codigo da operacao ( *** NAO INFORMAR *** )
		AAdd(aCab,0)							//Campo 28 - CAE ( *** COMPLETAR COM ZEROS *** )
		AAdd(aCab,0)							//Campo 29 - Data de vencimento ( *** COMPLETAR COM ZEROS *** )
		AAdd(aCab,Replicate("0",8))				//Campo 30 - Data de Anulacao do comprovante ( *** COMPLETAR COM ZEROS *** )
			
		//Limpa o array que possui o total dos impostos...
		aImps := {}
			
		// Atualizo o campo F3_NFEARG como "S" para definir que ja esta no arquivo magnetico
		aAliasSF3:=SF3->(GetArea())
		SF3->(DbsetOrder(1))
		If(SF3->(dbSeek(xFilial("SF3")+Dtos((cAliasSF3)->F3_ENTRADA)+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_CFO)) )
			RecLock("SF3",.F.)
			SF3->F3_NFEARG := "S"
			MsUnlock()
		EndIf
		SF3->(RestArea(aAliasSF3))	
			
		dbSelectArea(cAliasSF)
		//Grava o registro
		If Left(Alltrim(cSerie),1)=="A" .Or. (Left(Alltrim(cSerie),1)=="B" .And. Round(xMoeda((cAliasSF)->(&(cSF+"_VALBRUT")),(cAliasSF)->(&(cSF+"_MOEDA")),1,(cAliasSF)->(&(cSF+"_EMISSAO")),nDecimais+1,(cAliasSF)->(&(cSF+"_TXMOEDA"))),nDecimais)>=nLimLotB)
			GravaReg(aCab,"I")
		Else
			GravaReg(aCab,"L")
		Endif
				
	Endif
			
EndIf

RestArea(aArea)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GravaReg   ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 17.04.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Grava Registros                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GravaReg(aCab,cTipo)

Local aArea		:= GetArea()
Local lNovo		:= .T.
Local cSerie	:= IIf(cTipo=="L","B","A")

If cTipo == "L"		
	If Empty(aSeqNf[1])
		aSeqNf[1] := StrZero(Val(aCab[06]),8)	// 06-Nro. de comprovante (Nota Fiscal)
		aSeqNf[2] += 1		  					// Contador
	Else
		If aSeqNf[1] == StrZero(Val(aCab[06])-aSeqNf[2],8)
			aSeqNf[2] 	+= 1
			lNovo 		:= .F.
		Else
			aSeqNf[1]	:= StrZero(Val(aCab[06]),8)	// 06-Nro. de comprovante (Nota Fiscal)
			aSeqNf[2] 	:= 1		  					// Contador
		Endif
	Endif
Endif

If cTipoVen	== "B"
	dbSelectArea("R01")
	dbSetOrder(1)
	If lNovo
		RecLock("R01",.T.)
		R01->SERIE		:= cSerie		// Serie da Nota Fiscal
		R01->TIPO		:= aCab[01]		// 01-Tipo de registro
		R01->DTCOMP		:= aCab[02]		// 02-Data do comprovante
		R01->TPCOMP		:= aCab[03]		// 03-Tipo do comprovante
		R01->CTRLFISC	:= aCab[04]		// 04-Controlador fiscal ( *** NAO INFORMAR *** )
		R01->PTOVENDA	:= aCab[05]		// 05-Ponto de venda
		R01->NUMCOMP	:= aCab[06]		// 06-Nro. de comprovante
		R01->QTDEFOL	:= aCab[08]		// 08-Quantidade de Folhas ( *** NAO INFORMAR *** )
		R01->CODDOCCLI	:= aCab[09]		// 09-Cod. documento indentificador do comprador
		R01->CODCLI		:= aCab[10]		// 10-Nro. de identificacao do comprador
		R01->CLIENTE	:= aCab[11]		// 11-Descricao do comprador
		R01->TRANSP		:= aCab[22]		// 22-Transporte ( *** NAO INFORMAR *** )
		R01->TPRESP		:= aCab[23]		// 23-Tipo de responsable
		R01->CODMOEDA	:= aCab[24]		// 24-Codigos de moneda ( *** NAO INFORMAR *** )
		R01->TPCAMBIO	:= aCab[25]		// 25-Tipo de cambio ( *** NAO INFORMAR *** )
		R01->QTDALQIVA	:= aCab[26]		// 26-Quantidade de aliquotada de IVA ( *** NAO INFORMAR *** )
		R01->CODOPER	:= aCab[27]		// 27-Codigo de operacion ( *** NAO INFORMAR *** )
		R01->CODAUT		:= aCab[28]		// 28-Codigo de Autorizacao ou de Emissao - COMPLETAR COM ZEROS
		R01->DTAUT		:= aCab[29]		// 29-Data de vencimento ou de autorizacao - COMPLETAR COM ZEROS
		R01->DTANUL		:= aCab[30]		// 30-Data de anulacao do comprovante - COMPLETAR COM ZEROS
	Else
		dbSeek("B"+aSeqNf[1])
		RecLock("R01",.F.)			
	Endif
	R01->NUMCOMPRG	:= aCab[07]			// 07-Nro. de comprovante registrado
	R01->VLRTOT		+= aCab[12]			// 12-Importe total da operacao
	R01->VLRTOTN	+= aCab[13]			// 13-Imp. tot. conc. que no integran precio neto gravado
	R01->VLRLIQ		+= aCab[14]			// 14-Importe neto gravado
	R01->IMPLIQ		+= aCab[15]			// 15-Impuesto liquido
	R01->IMPLIQRNI	+= aCab[16]			// 16-Impuesto liq. a RNI o percep. a no categorizados
	R01->VLRISEN	+= aCab[17]			// 17-Importe de operaciones exentas
	R01->VLRPERCPG	+= aCab[18]			// 18-Importe de percep. o pagos a cta. de impuestos nac.
	R01->VLRIB		+= aCab[19]			// 19-Importe de percepcion de ingresos brutos
	R01->VLRIM		+= aCab[20]			// 20-Importe de percepcion por impuestos municipales
	R01->VLRII		+= aCab[21]			// 21-Importe de impuestos internos
	MsUnlock()
Else
	dbSelectArea("R02")
	dbSetOrder(1)
	If lNovo
		RecLock("R02",.T.)
		R02->SERIE		:= cSerie		// Serie da Nota Fiscal
		R02->TIPO		:= aCab[01]		// 01-Tipo de registro
		R02->DTCOMP		:= aCab[02]		// 02-Data do comprovante
		R02->TPCOMP		:= aCab[03]		// 03-Tipo do comprovante
		R02->CTRLFISC	:= aCab[04]		// 04-Controlador fiscal ( *** NAO INFORMAR *** )
		R02->PTOVENDA	:= aCab[05]		// 05-Ponto de venda
		R02->NUMCOMP	:= aCab[06]		// 06-Nro. de comprovante
		R02->QTDEFOL	:= aCab[08]		// 08-Quantidade de Folhas ( *** NAO INFORMAR *** )
		R02->CODDOCCLI	:= aCab[09]		// 09-Cod. documento indentificador do comprador
		R02->CODCLI		:= aCab[10]		// 10-Nro. de identificacao do comprador
		R02->CLIENTE	:= aCab[11]		// 11-Descricao do comprador
		R02->FECDES		:= aCab[22]		// 22-Fecha desde del servicio faturado
		R02->FECHAS		:= aCab[23]		// 23-Fecha hasta del servicio faturado
		R02->FECVEN	    := aCab[24]		// 24-Fecha de vencimiento para el pago del servicio faturado
		R02->QTDALQIVA	:= aCab[26]		// 26-Quantidade de aliquotada de IVA ( *** NAO INFORMAR *** )
		R02->CODOPER	:= aCab[27]		// 27-Codigo de operacion ( *** NAO INFORMAR *** )
		R02->CODAUT		:= aCab[28]		// 28-Codigo de Autorizacao ou de Emissao - COMPLETAR COM ZEROS
		R01->DTAUT		:= aCab[29]		// 29-Data de vencimento ou de autorizacao - COMPLETAR COM ZEROS
		R02->DTANUL		:= aCab[30]		// 30-Data de anulacao do comprovante - COMPLETAR COM ZEROS
	Else
		dbSeek("B"+aSeqNf[1])
		RecLock("R02",.F.)			
	Endif
	R02->NUMCOMPRG	:= aCab[07]			// 07-Nro. de comprovante registrado
	R02->VLRTOT		+= aCab[12]			// 12-Importe total da operacao
	R02->VLRTOTN	+= aCab[13]			// 13-Imp. tot. conc. que no integran precio neto gravado
	R02->VLRLIQ		+= aCab[14]			// 14-Importe neto gravado
	R02->IMPLIQ		+= aCab[15]			// 15-Impuesto liquido
	R02->IMPLIQRNI	+= aCab[16]			// 16-Impuesto liq. a RNI o percep. a no categorizados
	R02->VLRISEN	+= aCab[17]			// 17-Importe de operaciones exentas
	R02->VLRPERCPG	+= aCab[18]			// 18-Importe de percep. o pagos a cta. de impuestos nac.
	R02->VLRIB		+= aCab[19]			// 19-Importe de percepcion de ingresos brutos
	R02->VLRIM		+= aCab[20]			// 20-Importe de percepcion por impuestos municipales
	R02->VLRII		+= aCab[21]			// 21-Importe de impuestos internos
	MsUnlock()
Endif	

RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CriaArrayImp ³Autor ³ Julio Cesar          ³Data³ 13/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria o array que ira armazenar as informacoes dos impostos ³±±  
±±³          ³ conforme a sua categoria (IVA, RNI, PIB).                  ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CriaArrayImp()

//Sempre que valorizar o array aDImps eh necessario seguir a configuracao
//dos defines criados (IVA,RNI,PIB). Caso seja necessario aumente o numero
//de Defines.

//Dados referentes a categoria IVA
aDImps[IVA][1] := IVA
aDImps[IVA][2] := AllTrim(MV_PAR03) 
aDImps[IVA][3] := {}

//Dados referentes a categoria RNI (Responsable no Inscripto)
aDImps[RNI][1] := RNI
aDImps[RNI][2] := AllTrim(MV_PAR04) 
aDImps[RNI][3] := {}
                                  
//Dados referentes a categoria PIB (Percepcion de Ingreso Bruto)
aDImps[PIB][1] := PIB
aDImps[PIB][2] := AllTrim(MV_PAR05) 
aDImps[PIB][3] := {} 

//Dados referentes a categoria PIN (Percepcion de Impuestos Nacionales)
aDImps[PIN][1] := PIN
aDImps[PIN][2] := AllTrim(MV_PAR06) 
aDImps[PIN][3] := {}
                     
//Dados referentes a categoria PIM (Percepcion de Impuestos Municipales)
aDImps[PIM][1] := PIM
aDImps[PIM][2] := AllTrim(MV_PAR07) 
aDImps[PIM][3] := {}

//Dados referentes a categoria PII (Percepcion de Impuestos Internos)
aDImps[PII][1] := PII
aDImps[PII][2] := AllTrim(MV_PAR08) 
aDImps[PII][3] := {} 

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ChecaParam ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 17.04.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Checa parametros dos impostos                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ChecaParam()

Local lRet	:= .T.
Local nTam	:= TamSX3("FB_CODIGO")[1]
Local nI	:= 0
Local nX	:= 0
Local nY	:= 0

//Verifica se as categorias de impostos foram configuradas corretamente...
For nI := 3 To 8
	cParam := AllTrim(&("MV_PAR"+StrZero(nI,2)))
	For nX := 1 To Len(cParam)
		cImp := SubStr(cParam,nX,nTam)
		For nY := 3 To 8
			If nY <> nI
				If cImp$AllTrim(&("MV_PAR"+StrZero(nY,2)))
					MsgAlert(OemToAnsi(STR0002)+cImp+OemToAnsi(STR0003)) //"O imposto "#cImp#" esta compondo mais de uma categoria. Por favor, para continuar com o processo, acerte os parametros."
					lRet := .F.
					Exit
				EndIf
			EndIf
			If !lRet
				Exit
			EndIf
		Next nY
		If !lRet
			Exit
		EndIf
		nX += (nTam)
	Next nX
	If !lRet
		Exit
	EndIf
Next nI

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GeraTemp   ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 17.04.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera arquivo temporario                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraTemp()

Local aArea := GetArea()
Local aStru1	:= {}
Local aStru2	:= {}
Local aArq1	:= ""
Local aArq2	:= ""

Local aArq3	:= ""
Local aArq4	:= ""

If Select("R01") > 0
	dbSelectArea("R01")
	dbCloseArea()
Endif	

If Select("R02") > 0
	dbSelectArea("R02")
	dbCloseArea()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Layout do Registro de Importacao - Ventas      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aStru1,{"SERIE"		,"C",001,0})	// Serie
AADD(aStru1,{"TIPO"		,"C",001,0})	// 01-Tipo de registro
AADD(aStru1,{"DTCOMP"	,"C",008,0})	// 02-Data do comprovante
AADD(aStru1,{"TPCOMP"	,"C",002,0})	// 03-Tipo do comprovante
AADD(aStru1,{"CTRLFISC"	,"C",001,0})	// 04-Controlador fiscal ( *** NAO INFORMAR *** )
AADD(aStru1,{"PTOVENDA"	,"C",004,0})	// 05-Ponto de venda
AADD(aStru1,{"NUMCOMP"	,"C",008,0})	// 06-Nro. de comprovante
AADD(aStru1,{"NUMCOMPRG"	,"C",008,0})	// 07-Nro. de comprovante registrado
AADD(aStru1,{"QTDEFOL"	,"N",003,0})	// 08-Quantidade de Folhas ( *** NAO INFORMAR *** )
AADD(aStru1,{"CODDOCCLI"	,"C",002,0})	// 09-Cod. documento indentificador do comprador
AADD(aStru1,{"CODCLI"	,"C",011,0})	// 10-Nro. de identiificacao do comprador
AADD(aStru1,{"CLIENTE"	,"C",030,0})	// 11-Descricao do comprador
AADD(aStru1,{"VLRTOT"	,"N",015,2})	// 12-Importe total da operacao
AADD(aStru1,{"VLRTOTN"	,"N",015,2})	// 13-Imp. tot. conc. que no integran precio neto gravado
AADD(aStru1,{"VLRLIQ"	,"N",015,2})	// 14-Importe neto gravado
AADD(aStru1,{"IMPLIQ"	,"N",015,2})	// 15-Impuesto liquido
AADD(aStru1,{"IMPLIQRNI"	,"N",015,2})	// 16-Impuesto liq. a RNI o percep. a no categorizados
AADD(aStru1,{"VLRISEN"	,"N",015,2})	// 17-Importe de operaciones exentas
AADD(aStru1,{"VLRPERCPG"	,"N",015,2})	// 18-Importe de percep. o pagos a cta. de impuestos nac.
AADD(aStru1,{"VLRIB"		,"N",015,2})	// 19-Importe de percepcion de ingresos brutos
AADD(aStru1,{"VLRIM"		,"N",015,2})	// 20-Importe de percepcion por impuestos municipales
AADD(aStru1,{"VLRII"		,"N",015,2})	// 21-Importe de impuestos internos
AADD(aStru1,{"TRANSP"	,"N",015,0})	// 22-Transporte ( *** NAO INFORMAR *** )
AADD(aStru1,{"TPRESP"	,"C",002,0})	// 23-Tipo de responsable
AADD(aStru1,{"CODMOEDA"	,"C",003,0})	// 24-Codigos de moneda ( *** NAO INFORMAR *** )
AADD(aStru1,{"TPCAMBIO"	,"N",010,0})	// 25-Tipo de cambio ( *** NAO INFORMAR *** )
AADD(aStru1,{"QTDALQIVA"	,"N",001,0})	// 26-Quantidade de aliquotada de IVA ( *** NAO INFORMAR *** )
AADD(aStru1,{"CODOPER"	,"C",001,0})	// 27-Codigo de operacion ( *** NAO INFORMAR *** )
AADD(aStru1,{"CODAUT"	,"N",014,0})	// 28-CAE-Codigo de Autorizacao ou de Emissao - COMPLETAR COM ZEROS
AADD(aStru1,{"DTAUT"		,"N",008,0})	// 29-Data de vencimento ou de autorizacao - COMPLETAR COM ZEROS
AADD(aStru1,{"DTANUL"	,"C",008,0})	// 30-Data de anulacao do comprovante - COMPLETAR COM ZEROS

aArq1 := {"SERIE","NUMCOMP"}
aArq2 := {"TPCOMP","NUMCOMP"}

//*****************************
oTpTable1 := FWTemporaryTable():New( "R01" ) // R01=> Registro de Importacao - Ventas
oTpTable1:SetFields( aStru1 )
oTpTable1:AddIndex("R011", aArq1 ) //Indice 1
oTpTable1:AddIndex("R012", aArq2 ) //Indice 2
oTpTable1:Create()
//*****************************

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Layout do Registro de Importacao - Prest Serv  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aStru2,{"SERIE"		,"C",001,0})	// Serie
AADD(aStru2,{"TIPO"		,"C",001,0})	// 01-Tipo de registro
AADD(aStru2,{"DTCOMP"	,"C",008,0})	// 02-Data do comprovante
AADD(aStru2,{"TPCOMP"	,"C",002,0})	// 03-Tipo do comprovante
AADD(aStru2,{"CTRLFISC"	,"C",001,0})	// 04-Controlador fiscal ( *** NAO INFORMAR *** )
AADD(aStru2,{"PTOVENDA"	,"C",004,0})	// 05-Ponto de venda
AADD(aStru2,{"NUMCOMP"	,"C",008,0})	// 06-Nro. de comprovante
AADD(aStru2,{"NUMCOMPRG"	,"C",008,0})	// 07-Nro. de comprovante registrado
AADD(aStru2,{"QTDEFOL"	,"N",003,0})	// 08-Quantidade de Folhas ( *** NAO INFORMAR *** )
AADD(aStru2,{"CODDOCCLI"	,"C",002,0})	// 09-Cod. documento indentificador do comprador
AADD(aStru2,{"CODCLI"	,"C",011,0})	// 10-Nro. de identiificacao do comprador
AADD(aStru2,{"CLIENTE"	,"C",030,0})	// 11-Descricao do comprador
AADD(aStru2,{"VLRTOT"	,"N",015,2})	// 12-Importe total da operacao
AADD(aStru2,{"VLRTOTN"	,"N",015,2})	// 13-Imp. tot. conc. que no integran precio neto gravado
AADD(aStru2,{"VLRLIQ"	,"N",015,2})	// 14-Importe neto gravado
AADD(aStru2,{"IMPLIQ"	,"N",015,2})	// 15-Impuesto liquido
AADD(aStru2,{"IMPLIQRNI"	,"N",015,2})	// 16-Impuesto liq. a RNI o percep. a no categorizados
AADD(aStru2,{"VLRISEN"	,"N",015,2})	// 17-Importe de operaciones exentas
AADD(aStru2,{"VLRPERCPG"	,"N",015,2})	// 18-Importe de percep. o pagos a cta. de impuestos nac.
AADD(aStru2,{"VLRIB"		,"N",015,2})	// 19-Importe de percepcion de ingresos brutos
AADD(aStru2,{"VLRIM"		,"N",015,2})	// 20-Importe de percepcion por impuestos municipales
AADD(aStru2,{"VLRII"		,"N",015,2})	// 21-Importe de impuestos internos
AADD(aStru2,{"FECDES"	,"C",008,0})	// 22-Fecha desde del servicio facturado 
AADD(aStru2,{"FECHAS"	,"C",008,0})	// 23-Fecha hasta del servicio facturado 
AADD(aStru2,{"FECVEN"	,"C",008,0})	// 24-Fecha vencimiento para el pago 
AADD(aStru2,{"QTDALQIVA"	,"N",001,0})	// 26-Quantidade de aliquotada de IVA ( *** NAO INFORMAR *** )
AADD(aStru2,{"CODOPER"	,"C",001,0})	// 27-Codigo de operacion ( *** NAO INFORMAR *** )
AADD(aStru2,{"CODAUT"	,"N",014,0})	// 28-CAE-Codigo de Autorizacao ou de Emissao - COMPLETAR COM ZEROS
AADD(aStru2,{"DTAUT"		,"N",008,0})	// 29-Data de vencimento ou de autorizacao - COMPLETAR COM ZEROS
AADD(aStru2,{"DTANUL"	,"C",008,0})	// 30-Data de anulacao do comprovante - COMPLETAR COM ZEROS
	
aArq3 := {"SERIE","NUMCOMP"}
aArq4 := {"TPCOMP","NUMCOMP"}
	
//******************************
oTpTable2 := FWTemporaryTable():New( "R02" ) // R02=> Registro de Importacao - Prest Serv
oTpTable2:SetFields( aStru2 )
oTpTable2:AddIndex("R021", aArq3 ) //Indice 1
oTpTable2:AddIndex("R022", aArq4 ) //Indice 2
oTpTable2:Create()
//******************************


Return (oTpTable1,oTpTable2)
