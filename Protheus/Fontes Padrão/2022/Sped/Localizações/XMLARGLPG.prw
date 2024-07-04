#INCLUDE "ARGWSLPEG.CH"  
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³XMLARLPG³ Autor ³Danilo Santos            ³ Data ³04.06.2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina montagem de XML de liquidação eletronica de graos ARG³±±
±±³          ³Service WSLPG                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Mensagem de retorno                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: cModeloWS do WS                                      ³±±
±±³          ³ExpC2: Pagar ou receber                                     ³±±
±±³          ³ExpC3: Tipo liquidação(Parcial, total ou final)             ³±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
           	
User Function XMLARLPG()

Local aNotas     := {}
Local aArgRetLPG := {}
Local cMonitor  := ""
Local cNumAfip  := ""
Local nNumAfip  := 0
Local cIdEnt  	:= "" 
Local cNroIngBrt := SuperGetMV("MV_NRINGBR",.F.,"")
Local cNroAtvCpr := SuperGetMV("MV_NRACTCP",.F.,"")
Local cNroAtvVnd := SuperGetMV("MV_NRACTVD",.F.,"")
Local cAliasNL3 := InitSqlName("NL3")
Local cAliasNJA	:= InitSqlName("NJA")
Local cQuery
Local cErro     := ""
Local cCanje	:= ""
Local cCoe		:= ""
Local lRetorno  := .T.
Local lCert		:= .F.
Local nX        := 0
Local nY        := 0
Local nZ		:= 0
Local nI        := 0
Local nA		:= 0
Local NVEZES	:= 0
Local cURL      := StaticCall( ARGNFE, FindURL)
Local cTmpCert	:= criatrab(nil,.F.) 
Local oWSRetNum
Local oRetMonitor
Local oWSConsOrd
Local cDescImp  := ""
Local nValPerc  := 0
Local nOpDed    := 0
Local cTipoOper := ""
Local lAchou	:= .F.
Local lTemIva	:= .F.
Local nCont		:= 0
Local aRet := {}
Local nValBasIva := 0
Local nValAlqIva := 0
Local nYC := 0
Local nYD := 0
Local nIva0Cred := 0
Local nIva105Cred := 0
Local nIva21Cred := 0
Local nIva0Deb := 0
Local nIva105Deb := 0
Local nIva21Deb := 0
Local nPrecioOp := 0
Local aAuxImp   := {}
Local nAliqImp := 0
Local lTemDeb	:= .T.
Local lTemCred	:= .T.
Local aImpPercep := {}
Local aImpDeduc  := {}
Local aDebPercep := {}  
Local aCrdPercep := {}
Private cConcepto := ""
Private cDetalle  := ""
Private cDetallI  := ""
Private cConcepI := ""
Private cAliIVa  := ""
Private nValIva	:= 0
Private cDetallG  := ""
Private cConcepG := "" 
Private cAliGan  := ""
Private nValGan	:= 0  
Private cDetallIb  := ""
Private cConcepIb := "" 
Private cAliIB  := ""
Private nValIB  :=  0
Private cDetallO  := ""
Private cConcepO := "" 
Private cAliOtGr := ""
Private nValOtGr := 0

Default PARAMIXB[1]  := ""
Default PARAMIXB[2]  := ""
Default PARAMIXB[3]  := ""
Default PARAMIXB[4]  := {}
Default PARAMIXB[5]  := {}

cModeloWS := PARAMIXB[1]  
cTipo     := PARAMIXB[2]
cTipoLiq  := PARAMIXB[3]
aNotas    := PARAMIXB[4]
aRetNotas := PARAMIXB[5]

//Variaveis privates 
oWs1 := Nil
oWsLP := Nil
oWsLS := Nil
oWSAP := Nil
oWsAS := Nil
oWsMonit := Nil
oWSRetNum := Nil 
oRetMonitor := Nil
oWSConsOrd := Nil

If lAutAfip
	cIdEnt:= "000001"
ElseIf cTipo == "1"
	cIdEnt := StaticCall( Locxnf2, GetIdEnt)
	oWSRetNum := WSWSLPEG():New()
	oWSRetNum:cUserToken := "TOTVS"
	oWSRetNum:cID_ENT    := cIdEnt
	oWSRetNum:_URL       := AllTrim(cURL)+"/WSLPEG.apw"
	oWSRetNum:CPTOEMISION := Alltrim(NJC->NJC_PTOEMI)

	If oWSRetNum:CONSULTIMONROORDEN()
		cNumAfip := oWSRetNum:oWSCONSULTIMONROORDENRESULT:CNROORDEN
	Endif

	nNumAfip := Val(cNumAfip) + 1
	
ElseIf cTipo == "2"
	cIdEnt := StaticCall( Locxnf2, GetIdEnt)
	oWSRetNum := WSWSLPEG():New()
	oWSRetNum:cUserToken := "TOTVS"
	oWSRetNum:cID_ENT    := cIdEnt
	oWSRetNum:_URL       := AllTrim(cURL)+"/WSLPEG.apw"
	oWSRetNum:CPTOEMISION := Alltrim(NJC->NJC_PTOEMI)

	If oWSRetNum:CONSULTIMONROORDENSEC()
		cNumAfip := oWSRetNum:oWSCONSULTIMONROORDENSECRESULT:CNROORDEN
	Endif

	nNumAfip := Val(cNumAfip) + 1
Endif

If (cModeloWS $"8" .And. cTipo == "1" .And. cTipoLiq $ "1|3") //Liquidacion Primaria
		
	lCert := .F.
		
	//1=Nao;2=Troca Parcial;3=Troca Total
	If NJC->NJC_TROCA == "1"
		cCanje := "N"
	ElseIf NJC->NJC_TROCA == "2"
		cCanje := "P"
	ElseIf NJC->NJC_TROCA == "3"
		cCanje := "T"
	Endif
	oWs1 := WSWSLPEG():New()
	oWs1:cUserToken := "TOTVS"
	oWs1:cID_ENT    := cIdEnt
	oWS1:_URL       := AllTrim(cURL)+"/WSLPEG.apw"
	oWS1:OWSAUTLIQUIDACION:CPTOEMISION := Alltrim(NJC->NJC_PTOEMI)
	oWS1:OWSAUTLIQUIDACION:CNRORDEN := IIf(lAutAfip,NJC->NJC_CODLIQ,cValToChar(nNumAfip))
	oWS1:OWSAUTLIQUIDACION:CNROCONTRATO := NJC->NJC_CODCTR // VERIFICAR EM QUE CASO DEVE SER ENVIADO O NR DO CONTRATO
	oWS1:OWSAUTLIQUIDACION:CCUITCOMPRADOR := Alltrim(SM0->M0_CGC) //CUIT DO SIGAMAT
	oWS1:OWSAUTLIQUIDACION:CNROACTCOMPR := cNroAtvCpr //PARAMETRO CRIADO PARARECEBER O VALOR
	oWS1:OWSAUTLIQUIDACION:CNROINGBRUTCOMPR := ALLTRIM(cNroIngBrt)
	oWS1:OWSAUTLIQUIDACION:CCODTIPOOPERACION := NJC->NJC_OPERAC
	oWS1:OWSAUTLIQUIDACION:CESLIQUIDPROPRIA := IIf(NJC->NJC_TIPLIQ == "1","S","N")
	oWS1:OWSAUTLIQUIDACION:CESCANJE := cCanje //NJC->NJC_TROCA
	oWS1:OWSAUTLIQUIDACION:CCODPUERTO := NJC->NJC_PORTO
	oWS1:OWSAUTLIQUIDACION:CDESPUERTOLOCAL := NJC->NJC_NOMEPO 
	oWS1:OWSAUTLIQUIDACION:CCODGRANO := ALLTRIM(NJC->NJC_ESPECI) //<codGrano verificar como tratar esse campo da melhor maneira  SX5 - tabela SU
	If NJC->NJC_INFCER == '1'
		oWS1:OWSAUTLIQUIDACION:CPESONETOSINCERT := ""
		oWS1:OWSAUTLIQUIDACION:CCODLOCPROCSINCERT := "" //codLocalidadProcedenciaSinCertificado
		oWS1:OWSAUTLIQUIDACION:CCODPROVPROCSINCERT := "" //codProvProcedenciaSinCertificado
	Else	
		oWS1:OWSAUTLIQUIDACION:CPESONETOSINCERT := cValToChar(NJC->NJC_PESSCE * 1000) //LpgPesoNetoType ,verificar se é correto multiplicar por mil, pois a afip só permite numeros inteiros

		oWS1:OWSAUTLIQUIDACION:CCODLOCPROCSINCERT :=  ALLTRIM(NJC->NJC_PROPRO) //verificar como tratar esse campo da melhor maneira  SX5 - tabela S1 //codLocalidadProcedenciaSinCertificado// https://www.afip.gob.ar/genericos/guiavirtual/archivos/localidades.pdf
		oWS1:OWSAUTLIQUIDACION:CCODPROVPROCSINCERT := RetCodPro(NJC->NJC_PROVEN) //codProvProcedenciaSinCertificado
	Endif
	If NJC->NJC_TIPLIQ == "1"
		oWS1:OWSAUTLIQUIDACION:CCUITVENDEDOR := Alltrim(SM0->M0_CGC)
	Else
		oWS1:OWSAUTLIQUIDACION:CCUITVENDEDOR := Alltrim(NJC->NJC_CUITVE) 
	Endif
	oWS1:OWSAUTLIQUIDACION:CNROINGBRUTOVEND := Alltrim(NJC->NJC_NROIBV) 
	oWS1:OWSAUTLIQUIDACION:CACTUACORREDOR := IIF(NJC->NJC_ACTCOR == "1","S","N")
	oWS1:OWSAUTLIQUIDACION:CLIQUIDACORREDOR := IIf(NJC->NJC_LIQCOR == "1","S","N") 
	If NJC->NJC_TIPLIQ == "1"
		oWS1:OWSAUTLIQUIDACION:CCUITCORREDOR := ""
		oWS1:OWSAUTLIQUIDACION:CCOMISIONCORREDOR := ""
		oWS1:OWSAUTLIQUIDACION:CNROINGBRUTOCORREDOR := NJC->NJC_NOIBCR
	Else
		If NJC->NJC_LIQCOR == "1"
			oWS1:OWSAUTLIQUIDACION:CCUITCORREDOR := Alltrim(SM0->M0_CGC)//Si liquida corredor el cuit de corredor deve ser o mesmo do cuit representado
			oWS1:OWSAUTLIQUIDACION:CCOMISIONCORREDOR := "10.6" //Leandro comisionCorredor  não utilizamos no teste, verificar como foi a implementação do raul para informar de onde vira informação 
			oWS1:OWSAUTLIQUIDACION:CNROINGBRUTOCORREDOR := NJC->NJC_NOIBCR
		Else
			oWS1:OWSAUTLIQUIDACION:CCUITCORREDOR := Alltrim(NJC->NJC_CUITCR)
			oWS1:OWSAUTLIQUIDACION:CCOMISIONCORREDOR := "" //comisionCorredor 
			oWS1:OWSAUTLIQUIDACION:CNROINGBRUTOCORREDOR := ""  //NJC->NJC_NOIBCR
		Endif
	Endif
	
	oWS1:OWSAUTLIQUIDACION:CFECHAPRECIOOPERACION := ConvDtLPG(NJC->NJC_EMISSA) //fechaPrecioOperacion EX: 2020-03-20 (Ano, Mes, Data)
	oWS1:OWSAUTLIQUIDACION:CPRECIOREFTN := cValToChar(NJC->NJC_PRECO) //Leandro QUal valor deve ser informado nessa TAG observamos nos testes que esse valor tem que ser maior que as bases da retenção de impostos, além de maior do que as deduções.//cValToChar(NJC->NJC_PRECO)
	oWS1:OWSAUTLIQUIDACION:CCODGRADOREF := "" //codGradoRef
	oWS1:OWSAUTLIQUIDACION:CCODGRADOENT := cValToChar(NJC->NJC_GDOREF)
	oWS1:OWSAUTLIQUIDACION:CVALGRADOENT := "" //valGradoEnt
	oWS1:OWSAUTLIQUIDACION:CFACTORENT  := cValToChar(NJC->NJC_FACTOR) // Leandro  "1" //cValToChar(NJC->NJC_FACTOR)
	oWS1:OWSAUTLIQUIDACION:CPRECIOFLETETN := cValToChar(NJC->NJC_FRETE)
	oWS1:OWSAUTLIQUIDACION:CCONTPROTEICO := cValToChar(NJC->NJC_CONPRO)
	oWS1:OWSAUTLIQUIDACION:CALICIVAOPERACION := "10.5"// Leandro temos o campo Alltrim(cValToChar(NJC->NJC_ALIIVA)) porem nao sabemos como utilizar de onde vem a informaçao para o preenchimento desse campo?
	oWS1:OWSAUTLIQUIDACION:CCAMPANIAPPAL := ALLTRIM(NJC->NJC_CODSAF)
	oWS1:OWSAUTLIQUIDACION:CCODPROVPROCEDENCIA := RetCodPro(NJC->NJC_PROVEN)
	oWS1:OWSAUTLIQUIDACION:CDATOSADICIONALES := NJC->NJC_OBS
	
	nZ := 1
					
	If NJC->NJC_INFCER == '1'
		cQuery := " SELECT * FROM "
		cQuery += cAliasNL3 + " AS NL3 " 
		cQuery +=  " INNER JOIN "
		cQuery += cAliasNJA + " AS NJA "
		cQuery += " ON "
		cQuery += " NL3.NL3_CODCET = NJA.NJA_CODCET "
		cQuery += " WHERE " 
		cQuery += " NL3.NL3_CODLIQ = '" + NJC->NJC_CODLIQ + "' AND "
		cQuery += " NL3.D_E_L_E_T_ = '' AND "
		cQuery += " NJA.D_E_L_E_T_ = '' "
		cQuery := ChangeQuery(cQuery)                    
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpCert,.T.,.T.) 
	
		Count to nCont
		lCert := .T.
		(cTmpCert)->(dbGoTop())
		
		oWS1:OWSAUTLIQUIDACION:CCODLOCALPROCEDENCIA :=  ALLTRIM((cTmpCert)->NL3_LOCPRO)
		
		oWS1:OWSAUTLIQUIDACION:OWSCERTIFICADOS := WSLPEG_ARRAYOFCERTIFICADO():New()
		AADD(oWS1:OWSAUTLIQUIDACION:OWSCERTIFICADOS:oWSCERTIFICADO, WSLPEG_CERTIFICADO ():New() )
	
		oWS1:OWSAUTLIQUIDACION:OWSCERTIFICADOS:oWSCERTIFICADO[nZ]:CTIPOCERTDEPOSITO := (cTmpCert)->NL3_TIPLIQ
		oWS1:OWSAUTLIQUIDACION:OWSCERTIFICADOS:oWSCERTIFICADO[nZ]:CNROCERTDEPOSITO := (cTmpCert)->NL3_CODCET
		oWS1:OWSAUTLIQUIDACION:OWSCERTIFICADOS:oWSCERTIFICADO[nZ]:CPESONETO := cValToChar((cTmpCert)->NL3_PESNETO)
		oWS1:OWSAUTLIQUIDACION:OWSCERTIFICADOS:oWSCERTIFICADO[nZ]:CPESONETOTOTALCERT := "" //pesoNetoTotalCertificado
		oWS1:OWSAUTLIQUIDACION:OWSCERTIFICADOS:oWSCERTIFICADO[nZ]:CCODLOCALPROCEDENCIA := (cTmpCert)->NL3_LOCPRO
		oWS1:OWSAUTLIQUIDACION:OWSCERTIFICADOS:oWSCERTIFICADO[nZ]:CCODPROVPROCEDENCIA := RetCodPro((cTmpCert)->NL3_PROPRO) //(cTmpCert)->NL3_PROPRO
		oWS1:OWSAUTLIQUIDACION:OWSCERTIFICADOS:oWSCERTIFICADO[nZ]:CCAMPANIA := (cTmpCert)->NL3_CODSAF
		oWS1:OWSAUTLIQUIDACION:OWSCERTIFICADOS:oWSCERTIFICADO[nZ]:CFECHACIERRE := (Substr((cTmpCert)->NL3_DATA,1,4) + "-" + Substr((cTmpCert)->NL3_DATA,5,2) + "-" + Substr((cTmpCert)->NL3_DATA,7,2))
		
	ElseIf NJC->NJC_INFCER == '2'
	 			
		oWS1:OWSAUTLIQUIDACION:OWSCERTIFICADOS := WSLPEG_ARRAYOFCERTIFICADO():New()
		AADD(oWS1:OWSAUTLIQUIDACION:OWSCERTIFICADOS:oWSCERTIFICADO, WSLPEG_CERTIFICADO ():New() )
	
		oWS1:OWSAUTLIQUIDACION:OWSCERTIFICADOS:oWSCERTIFICADO[nZ]:CTIPOCERTDEPOSITO := ""
		oWS1:OWSAUTLIQUIDACION:OWSCERTIFICADOS:oWSCERTIFICADO[nZ]:CNROCERTDEPOSITO := ""
		oWS1:OWSAUTLIQUIDACION:OWSCERTIFICADOS:oWSCERTIFICADO[nZ]:CPESONETO := ""
		oWS1:OWSAUTLIQUIDACION:OWSCERTIFICADOS:oWSCERTIFICADO[nZ]:CPESONETOTOTALCERT := "" 
		oWS1:OWSAUTLIQUIDACION:OWSCERTIFICADOS:oWSCERTIFICADO[nZ]:CCODLOCALPROCEDENCIA := ALLTRIM(NJC->NJC_PROPRO)  // Leandro  "3"//NJC->NJC_PROPRO verificar como tratar esse campo da melhor maneira  SX5 - tabela S1 //codLocalidadProcedenciaSinCertificado// https://www.afip.gob.ar/genericos/guiavirtual/archivos/localidades.pdf
		oWS1:OWSAUTLIQUIDACION:OWSCERTIFICADOS:oWSCERTIFICADO[nZ]:CCODPROVPROCEDENCIA := RetCodPro(NJC->NJC_PROVEN)// Leandro devido nao possuir informaçoes na NL3 utilize a NJC, porem é necessario verificar qual o conteudo correto a ser utilizado RetCodPro((cTmpCert)->NL3_PROPRO) //  "1"/verificar como tratar esse campo da melhor maneira  SX5 - tabela S1 //codLocalidadProcedenciaSinCertificado// https://www.afip.gob.ar/genericos/guiavirtual/archivos/localidades.pdf
		oWS1:OWSAUTLIQUIDACION:OWSCERTIFICADOS:oWSCERTIFICADO[nZ]:CCAMPANIA := ""
		oWS1:OWSAUTLIQUIDACION:OWSCERTIFICADOS:oWSCERTIFICADO[nZ]:CFECHACIERRE := ""
	Else
	 	oWS1:OWSAUTLIQUIDACION:CCODLOCALPROCEDENCIA := ALLTRIM(NJC->NJC_PROPRO) //codLocalidadProcedencia// https://www.afip.gob.ar/genericos/guiavirtual/archivos/localidades.pdf
	
	Endif
	
	nA := 1
	oWS1:OWSAUTLIQUIDACION:OWSOPCIONALES := WSLPEG_ARRAYOFOPCIONAL():New()
	AADD(oWS1:OWSAUTLIQUIDACION:OWSOPCIONALES:oWSOPCIONAL, WSLPEG_OPCIONAL ():New() )	
	oWS1:OWSAUTLIQUIDACION:OWSOPCIONALES:oWSOPCIONAL[nA]:CCODIGO := ""
	oWS1:OWSAUTLIQUIDACION:OWSOPCIONALES:oWSOPCIONAL[nA]:CDESCRIPCION := ""
	
	//Dados de Deduciones
	oWS1:OWSAUTDEDUCCIONES:OWSDEDUCCIONES := WSLPEG_DEDUCCIONESAUT():New() 
	oWS1:OWSAUTDEDUCCIONES:OWSDEDUCCIONES:=  WSLPEG_ARRAYOFDEDUCCION ():New()
	//AADD(oWS1:OWSAUTDEDUCCIONES:OWSDEDUCCIONES:OWSDEDUCCION, WSLPEG_DEDUCCION ():New() )
	
	//Dados de Percepciones
	oWS1:OWSAUTPERCEPCIONES:OWSPERCEPCIONES := WSLPEG_PERCEPCIONESAUT ():New()
	oWS1:OWSAUTPERCEPCIONES:OWSPERCEPCIONES := WSLPEG_ARRAYOFPERCEPCION ():New()
	//AADD(oWS1:OWSAUTPERCEPCIONES:OWSPERCEPCIONES:oWSPERCEPCION, WSLPEG_PERCEPCION ():New() )
	DbSelectArea("NL4")
	DbSetOrder(1)
	//NL4_FILIAL+NL4_CODLIQ+NL4_ITEM
	
	nY := 1
	nCont := 1
	If  msSeek(xFilial("NL4") + NJC->NJC_CODLIQ) 
		While NL4->(!Eof())
			lTemIva := .F.
			IF NL4->NL4_CODLIQ == NJC->NJC_CODLIQ
				cTipoOper := Posicione("FR8",1,xFilial("FR8") + NL4->NL4_TIPDED,"FR8_TIPOOP")
				ConceptoDed(cTipoOper)
				
				AADD(oWS1:OWSAUTDEDUCCIONES:OWSDEDUCCIONES:OWSDEDUCCION, WSLPEG_DEDUCCION ():New() )

				oWS1:OWSAUTDEDUCCIONES:OWSDEDUCCIONES:OWSDEDUCCION[nY]:CCODIGOCONCEPTO :=  cConcepto  
				oWS1:OWSAUTDEDUCCIONES:OWSDEDUCCIONES:OWSDEDUCCION[nY]:CDETALLEACLARATORIO := cDetalle 
				If oWS1:OWSAUTDEDUCCIONES:OWSDEDUCCIONES:OWSDEDUCCION[nY]:CCODIGOCONCEPTO == "AL" 
					oWS1:OWSAUTDEDUCCIONES:OWSDEDUCCIONES:OWSDEDUCCION[nY]:CDIASALMACENAJE := cValToChar(NL4->NL4_DIAALM)
					oWS1:OWSAUTDEDUCCIONES:OWSDEDUCCIONES:OWSDEDUCCION[nY]:CPRECIOPKGDIARIO := cValtoChar(NL4->NL4_PRECIO) //cValtoChar(NL4->NL4_PRECIO)
				Else
					oWS1:OWSAUTDEDUCCIONES:OWSDEDUCCIONES:OWSDEDUCCION[nY]:CDIASALMACENAJE := ""
					oWS1:OWSAUTDEDUCCIONES:OWSDEDUCCIONES:OWSDEDUCCION[nY]:CPRECIOPKGDIARIO := "" //cValtoChar(NL4->NL4_PRECIO)
				Endif
				If NJC->NJC_OPERAC == "2" 
					oWS1:OWSAUTDEDUCCIONES:OWSDEDUCCIONES:OWSDEDUCCION[nY]:CCOMISIONGASTOSADM := cValtoChar(NL4->NL4_PORCEN) //Informar o campo novo criado pelo Raul
				Else
					oWS1:OWSAUTDEDUCCIONES:OWSDEDUCCIONES:OWSDEDUCCION[nY]:CCOMISIONGASTOSADM := ""
				Endif
				If oWS1:OWSAUTDEDUCCIONES:OWSDEDUCCIONES:OWSDEDUCCION[nY]:CCODIGOCONCEPTO == "AL" 
					oWS1:OWSAUTDEDUCCIONES:OWSDEDUCCIONES:OWSDEDUCCION[nY]:CBASECALCULO := "" 
					oWS1:OWSAUTDEDUCCIONES:OWSDEDUCCIONES:OWSDEDUCCION[nY]:CALICUOTAIVA := ""
				Else
					If SF4->( MsSeek( xFilial("SF4")+NL4->NL4_CODTES) )
						If SFC->( MsSeek( xFilial("SFC")+SF4->F4_CODIGO) )
							While SFC ->( !Eof() .And. SFC->FC_FILIAL+SFC->FC_TES == xFilial("SFC")+SF4->F4_CODIGO )
								If SFB->( MsSeek( xFilial("SFB")+SFC->FC_IMPOSTO ) )
									IF SFB->FB_CLASSIF == "3" .AND. SFB->FB_TIPO == "N"	 .AND. SFB->FB_CLASSE == "I" .AND. !lTemIva 
										lTemIva := .T.									
										nValBasIva := &("NL4->NL4_BASIM"+SFB->FB_CPOLVRO)
										nValAlqIva := &("NL4->NL4_ALQIM"+SFB->FB_CPOLVRO)
										oWS1:OWSAUTDEDUCCIONES:OWSDEDUCCIONES:OWSDEDUCCION[nY]:CBASECALCULO := cValtoChar(nValBasIva) // LEANDRO ENTENDER O CONCEITO DOS CAMPO NL4 BASIM ALQIM E VALIM
										oWS1:OWSAUTDEDUCCIONES:OWSDEDUCCIONES:OWSDEDUCCION[nY]:CALICUOTAIVA := cValtoChar(nValAlqIva)
									EndIf
								EndIf	
								SFC->( DbSkip() )
							Enddo
						EndIf
					EndIf
				EndIf

				IF !lTemIva 
					oWS1:OWSAUTDEDUCCIONES:OWSDEDUCCIONES:OWSDEDUCCION[nY]:CBASECALCULO := "0" 
					oWS1:OWSAUTDEDUCCIONES:OWSDEDUCCIONES:OWSDEDUCCION[nY]:CALICUOTAIVA := "0"
				EndIF
				
				
				//Percepciones
				
				If SF4->( MsSeek( xFilial("SF4")+NL4->NL4_CODTES) )
					If SFC->( MsSeek( xFilial("SFC")+SF4->F4_CODIGO) )
						While SFC ->( !Eof() .And. SFC->FC_FILIAL+SFC->FC_TES == xFilial("SFC")+SF4->F4_CODIGO )
							If SFB->( MsSeek( xFilial("SFB")+SFC->FC_IMPOSTO ) )
								IF SFB->FB_CLASSE == "P"
									cDescImp := SFB->FB_DESCR
									nValPerc := &("NL4->NL4_VALIM"+SFB->FB_CPOLVRO)
									IF nValPerc > 0 // Se tiver Valor de imposto grava.
										lAchou := .T.
										AADD(oWS1:OWSAUTPERCEPCIONES:OWSPERCEPCIONES:oWSPERCEPCION, WSLPEG_PERCEPCION ():New() )
										oWS1:OWSAUTPERCEPCIONES:OWSPERCEPCIONES:oWSPERCEPCION[nCont]:CDESCRIPCION  := cDescImp
										oWS1:OWSAUTPERCEPCIONES:OWSPERCEPCIONES:oWSPERCEPCION[nCont]:CIMPORTEFINAL := cValtoChar(nValPerc)
										nCont ++
									EndiF
								EndIF
							EndIf	
							SFC->( DbSkip() )
						Enddo
					EndIf
				EndIf
		
				IF !lAchou 
					AADD(oWS1:OWSAUTPERCEPCIONES:OWSPERCEPCIONES:oWSPERCEPCION, WSLPEG_PERCEPCION ():New() )
					oWS1:OWSAUTPERCEPCIONES:OWSPERCEPCIONES:oWSPERCEPCION[nCont]:CDESCRIPCION := ""
					oWS1:OWSAUTPERCEPCIONES:OWSPERCEPCIONES:oWSPERCEPCION[nCont]:CIMPORTEFINAL := ""
					nCont ++
				EndIF

				nY ++

			EndIF	
			NL4->(DbSkip())
		EndDo
	Else
		AADD(oWS1:OWSAUTDEDUCCIONES:OWSDEDUCCIONES:OWSDEDUCCION, WSLPEG_DEDUCCION ():New() )
		oWS1:OWSAUTDEDUCCIONES:OWSDEDUCCIONES:OWSDEDUCCION[1]:CCODIGOCONCEPTO :=  ""  
		oWS1:OWSAUTDEDUCCIONES:OWSDEDUCCIONES:OWSDEDUCCION[1]:CDETALLEACLARATORIO := ""
		oWS1:OWSAUTDEDUCCIONES:OWSDEDUCCIONES:OWSDEDUCCION[1]:CDIASALMACENAJE := ""
		oWS1:OWSAUTDEDUCCIONES:OWSDEDUCCIONES:OWSDEDUCCION[1]:CPRECIOPKGDIARIO := ""
		oWS1:OWSAUTDEDUCCIONES:OWSDEDUCCIONES:OWSDEDUCCION[1]:CCOMISIONGASTOSADM := ""
		oWS1:OWSAUTDEDUCCIONES:OWSDEDUCCIONES:OWSDEDUCCION[1]:CBASECALCULO := "" 
		oWS1:OWSAUTDEDUCCIONES:OWSDEDUCCIONES:OWSDEDUCCION[1]:CALICUOTAIVA := ""
		
		AADD(oWS1:OWSAUTPERCEPCIONES:OWSPERCEPCIONES:oWSPERCEPCION, WSLPEG_PERCEPCION ():New() )
		oWS1:OWSAUTPERCEPCIONES:OWSPERCEPCIONES:oWSPERCEPCION[nCont]:CDESCRIPCION := ""
		oWS1:OWSAUTPERCEPCIONES:OWSPERCEPCIONES:oWSPERCEPCION[nCont]:CIMPORTEFINAL := ""
	Endif
	//Dados de Retenciones
	nI := 1
	oWS1:OWSAUTRETENCIONES:OWSRETENCIONES := WSLPEG_RETENCIONESAUT ():New()
	oWS1:OWSAUTRETENCIONES:OWSRETENCIONES :=  WSLPEG_ARRAYOFRETENCION ():New()
	DBSelectArea("FKR")
	DBSetOrder(1)
	DBGoTop()
	If  msSeek(xFilial("FKR") + NJC->NJC_CODLIQ) 
		While FKR->(!Eof())
			IF FKR->FKR_CODIGO == NJC->NJC_CODLIQ
				ConceptoRet(FKR->FKR_TIPO)
			
			EndIF
			FKR->(DbSkip())
		EndDo
		aAdd( aRet, {{ cDetallI, cConcepI, cAliIVa, cValtoChar(nValIva)},{cDetallG, cConcepG,cAliGan, cValtoChar(nValGan)}, {cDetallIb, cConcepIb,cAliIB, cValtoChar(nValIB)}}  )
		IF Len(aRet) > 0
			For nI := 1 to  Len(aRet[1])
				AADD(oWS1:OWSAUTRETENCIONES:OWSRETENCIONES:oWSRETENCION , WSLPEG_RETENCION ():New() )
				oWS1:OWSAUTRETENCIONES:OWSRETENCIONES:oWSRETENCION[nI]:CCODIGOCONCEPTO := aRet[1][nI][2]
				oWS1:OWSAUTRETENCIONES:OWSRETENCIONES:oWSRETENCION[nI]:CDETALLEACLARATORIO := aRet[1][nI][1]
				oWS1:OWSAUTRETENCIONES:OWSRETENCIONES:oWSRETENCION[nI]:CBASECALCULO := aRet[1][nI][4]
				oWS1:OWSAUTRETENCIONES:OWSRETENCIONES:oWSRETENCION[nI]:CALICUOTA := aRet[1][nI][3]
				oWS1:OWSAUTRETENCIONES:OWSRETENCIONES:oWSRETENCION[nI]:CNROCERTRETENCION := ""
				oWS1:OWSAUTRETENCIONES:OWSRETENCIONES:oWSRETENCION[nI]:CFECHACERTRETENCION := ""
				oWS1:OWSAUTRETENCIONES:OWSRETENCIONES:oWSRETENCION[nI]:CIMPORTECERTRETENCION := ""
				
			Next nI
		Else
			AADD(oWS1:OWSAUTRETENCIONES:OWSRETENCIONES:oWSRETENCION , WSLPEG_RETENCION ():New() )
			oWS1:OWSAUTRETENCIONES:OWSRETENCIONES:oWSRETENCION[nI]:CCODIGOCONCEPTO := "" 
			oWS1:OWSAUTRETENCIONES:OWSRETENCIONES:oWSRETENCION[nI]:CDETALLEACLARATORIO := ""
			oWS1:OWSAUTRETENCIONES:OWSRETENCIONES:oWSRETENCION[nI]:CBASECALCULO := ""
			oWS1:OWSAUTRETENCIONES:OWSRETENCIONES:oWSRETENCION[nI]:CALICUOTA := ""
			oWS1:OWSAUTRETENCIONES:OWSRETENCIONES:oWSRETENCION[nI]:CNROCERTRETENCION := ""
			oWS1:OWSAUTRETENCIONES:OWSRETENCIONES:oWSRETENCION[nI]:CFECHACERTRETENCION := ""
			oWS1:OWSAUTRETENCIONES:OWSRETENCIONES:oWSRETENCION[nI]:CIMPORTECERTRETENCION := ""
		EndIF
		

	Else
		AADD(oWS1:OWSAUTRETENCIONES:OWSRETENCIONES:oWSRETENCION , WSLPEG_RETENCION ():New() )
		oWS1:OWSAUTRETENCIONES:OWSRETENCIONES:oWSRETENCION[nI]:CCODIGOCONCEPTO := "" 
		oWS1:OWSAUTRETENCIONES:OWSRETENCIONES:oWSRETENCION[nI]:CDETALLEACLARATORIO := ""
		oWS1:OWSAUTRETENCIONES:OWSRETENCIONES:oWSRETENCION[nI]:CBASECALCULO := ""
		oWS1:OWSAUTRETENCIONES:OWSRETENCIONES:oWSRETENCION[nI]:CALICUOTA := ""
		oWS1:OWSAUTRETENCIONES:OWSRETENCIONES:oWSRETENCION[nI]:CNROCERTRETENCION := ""
		oWS1:OWSAUTRETENCIONES:OWSRETENCIONES:oWSRETENCION[nI]:CFECHACERTRETENCION := ""
		oWS1:OWSAUTRETENCIONES:OWSRETENCIONES:oWSRETENCION[nI]:CIMPORTECERTRETENCION := ""
	EndIF

	
	oWS1:CNROLIQUID := NJC->NJC_CODLIQ
	aadd(aRetNotas,aNotas)
	 
	oWsLP:=	oWs1
	If oWsLP:LIQUIDAUTORIZARLPEG() 
		cMonitor := oWsLP:oWSLIQUIDAUTORIZARLPEGRESULT:OWSID:CSTRING[1]
		RecLock("NJC",.F.) 
			If lAutAfip
				NJC->NJC_FLLPEG := "1"
			Else
				NJC->NJC_FLLPEG := "3"
 			Endif
 			NJC->NJC_COMPRO := "" // Informar o COE depois de autorizar		
 		NJC->(MsUnlock())
 		
 		If lCert
 			(cTmpCert)->(dbCloseArea())
 		Endif
 		NL4->(dbCloseArea())
 		
 		//consulta retorno da afip
 		oWsMonit := WSWSLPEG():New()
 		oWsMonit:cUserToken := "TOTVS"
 		oWsMonit:cID_ENT    := cIdEnt
 		oWsMonit:_URL       := AllTrim(cURL)+"/WSLPEG.apw"
 		oWsMonit:cIdInicial    := cMonitor + "1"
		oWsMonit:cIdFinal      := cMonitor + "1"
	
		While lRetorno .and. nVezes <= 5
			sleep(5000)
			If oWsMonit:MONITORLPEG()                                                                 
				oRetMonitor :=  oWsMonit:OWSMONITORLPEGRESULT:OWSRESPONSEWSLPG
				lRetorno := .F.
			Endif
			nVezes++
    	EndDo
		IF Valtype(oRetMonitor) <> "U"
			If  Valtype(oRetMonitor[1]:OWSRESERROR:OWSERRORARRAY[1]:CCODIGO) <> "U" .And.  oRetMonitor[1]:OWSRESERROR:OWSERRORARRAY[1]:CCODIGO == "1508"
				
				
				oWSConsOrd:= WSWSLPEG():New()
				oWSConsOrd:cUserToken := "TOTVS"
				oWSConsOrd:cID_ENT    := cIdEnt
				oWSConsOrd:_URL       := AllTrim(cURL)+"/WSLPEG.apw"
				oWSConsOrd:CPTOEMISION := Alltrim(NJC->NJC_PTOEMI)
				oWSConsOrd:CNROORDEN := cValToChar(nNumAfip)
				oWSConsOrd:CNROLIQUID := NJC->NJC_CODLIQ
				
				If oWSConsOrd:LIQUIDXNROORDCONS()
					If !Empty(oWSConsOrd:OWSLIQUIDXNROORDCONSRESULT:CCOE) .And. oWSConsOrd:OWSLIQUIDXNROORDCONSRESULT:CESTADO == "AC"
					
						RecLock("NJC",.F.) 
							NJC->NJC_FLLPEG := "1"
							NJC->NJC_STATUS := "3"
							NJC->NJC_COMPRO := oWSConsOrd:OWSLIQUIDXNROORDCONSRESULT:CCOE
							NJC->NJC_NRAFIP := cValToChar(nNumAfip)
							NJC->NJC_STAFIP := IIf(oWSConsOrd:OWSLIQUIDXNROORDCONSRESULT:CESTADO == "AC","1","2") //opcçoes 1=Ativo;2=Anulado
							NJC->NJC_COEAJU := "" // COE Ajustado
							NJC->NJC_DTTRAN := CTOD(oWSConsOrd:OWSLIQUIDXNROORDCONSRESULT:CDATALIQ) //Data Transmissao Afip
						NJC->(MsUnlock())
					Endif
				Endif
				
				DbSelectArea("SD1")
				DBSetOrder(1)
				//D1_FILIAL+D1_DOC+D1_SERIE
				If MSSeek(xFilial("SD1") + NJC->NJC_REMITO + NJC->NJC_SERREM )
					RecLock("SD1",.F.) 
						SD1->D1_COELQ := oWSConsOrd:OWSLIQUIDXNROORDCONSRESULT:CCOE
					SD1->(MsUnlock()) 
					SD1->(dbCloseArea())
				Endif
				FIS828GRVFIN(oWSConsOrd:OWSLIQUIDXNROORDCONSRESULT:CCOE)
			ElseIf (Valtype(oRetMonitor[1]:CRESULTADO) <> "U" .And. oRetMonitor[1]:CRESULTADO == "A")
				RecLock("NJC",.F.) 
				NJC->NJC_FLLPEG := "1"
					NJC->NJC_STATUS := "3"
					NJC->NJC_COMPRO := Alltrim(oRetMonitor[1]:CCOE)
					NJC->NJC_NRAFIP := Alltrim(oRetMonitor[1]:CNRAFIP)
					NJC->NJC_STAFIP := IIf(oRetMonitor[1]:CESTADO == "AC","1","2") //opcçoes 1=Ativo;2=Anulado
					NJC->NJC_COEAJU := "" // COE Ajustado
					NJC->NJC_DTTRAN := dDatabase //CTOD(dDatabase) //Data Transmissao Afip
				NJC->(MsUnlock())

				DbSelectArea("SD1")
				DBSetOrder(1)
				//D1_FILIAL+D1_DOC+D1_SERIE
				If MSSeek(xFilial("SD1") + NJC->NJC_REMITO + NJC->NJC_SERREM )
					RecLock("SD1",.F.) 
						SD1->D1_COELQ := Alltrim(oRetMonitor[1]:CCOE)
					SD1->(MsUnlock()) 
					SD1->(dbCloseArea())
				Endif
				FIS828GRVFIN(Alltrim(oRetMonitor[1]:CCOE))
			Endif
		EndIF
	Else
		If lAutAfip
			RecLock("NJC",.F.) 
				NJC->NJC_FLLPEG := "1"
				cCoe := cValToChar(Randomize( 100000000, 999999999 ))
				NJC->NJC_COMPRO := cCoe
				NJC->NJC_NRAFIP := NJC->NJC_CODLIQ
				NJC->NJC_STATUS := "3"
			NJC->(MsUnlock())
			FIS828GRVFIN(cCoe)
			
			DbSelectArea("SD1")
			DBSetOrder(1)
			//D1_FILIAL+D1_DOC+D1_SERIE
			MSSeek(xFilial("SD1") + NJC->NJC_REMITO + NJC->NJC_SERREM )
			RecLock("SD1",.F.) 
				SD1->D1_COELQ := cCoe
			SD1->(MsUnlock())
			SD1->(dbCloseArea())
			
		Else
			cErro := GetWscError(3)
			DEFAULT cErro := STR0047 //"Erro indeterminado"
			lRetorno := .F.
		Endif
	Endif
ElseIf (cModeloWS $"8" .And. cTipo == "2" .And. cTipoLiq $ "1|3") //Liquidacion Secundaria
		
	oWs1 := WSWSLPEG():New()
	oWs1:cUserToken := "TOTVS"
	oWs1:cID_ENT    := cIdEnt
	oWS1:_URL       := AllTrim(cURL)+"/WSLPEG.apw"	//
	oWS1:oWSLIQSECUNBASE:CPTOEMISION := Alltrim(NJC->NJC_PTOEMI)
	oWS1:oWSLIQSECUNBASE:CNROORDEN := IIf(lAutAfip,NJC->NJC_CODLIQ,cValToChar(nNumAfip))
	oWS1:oWSLIQSECUNBASE:CNUMEROCONTRATO := NJC->NJC_CODCTR
	oWS1:oWSLIQSECUNBASE:CCUITCOMPRADOR := NJC->NJC_CUITCO
	oWS1:oWSLIQSECUNBASE:CNROINGBRUTOCOMPRADOR := NJC->NJC_NROIB  
	oWS1:oWSLIQSECUNBASE:CCODPUERTO := NJC->NJC_PORTO
	oWS1:oWSLIQSECUNBASE:CDESPUERTOLOCALIDAD := Alltrim(NJC->NJC_NOMEPO)
	oWS1:oWSLIQSECUNBASE:CCODGRANO := ALLTRIM(NJC->NJC_ESPECI)
	
	nPrecioOp := (NJC->NJC_PRECO * 1000) * (NJC->NJC_PESSCE/1000)
	oWS1:oWSLIQSECUNBASE:CCANTIDADTN := cValtoChar(Round(NJC->NJC_PESSCE/1000,3))
	oWS1:oWSLIQSECUNBASE:CPRECIOOPERACION := cValtoChar(nPrecioOp)
	oWS1:oWSLIQSECUNBASE:CCUITVENDEDOR := Alltrim(SM0->M0_CGC) //CUIT DO SIGAMAT
	oWS1:oWSLIQSECUNBASE:CNROACTVENDEDOR := cNroAtvVnd //""
	oWS1:oWSLIQSECUNBASE:CNROINGBRUTOVENDEDOR := cNroIngBrt //NJC->NJC_NROIBV
	oWS1:oWSLIQSECUNBASE:CACTUACORREDOR := IIF(NJC->NJC_ACTCOR == "1","S","N")
	oWS1:oWSLIQSECUNBASE:CLIQUIDACORREDOR := IIf(NJC->NJC_LIQCOR == "1","S","N")
	If NJC->NJC_LIQCOR == "1"
		oWS1:oWSLIQSECUNBASE:CCUITCORREDOR := Alltrim(SM0->M0_CGC)
	Else
		oWS1:oWSLIQSECUNBASE:CCUITCORREDOR := NJC->NJC_CUITCR
	Endif
	oWS1:oWSLIQSECUNBASE:CNROINGBRUTOCORREDOR := NJC->NJC_NOIBCR
	oWS1:oWSLIQSECUNBASE:CFECHAPRECIOOPERACION := ConvDtLPG(NJC->NJC_EMISSA)
	oWS1:oWSLIQSECUNBASE:CPRECIOREFTN := cValToChar(NJC->NJC_PRECO)
	aLiqImp := RetImpLPG(NJC->NJC_CODLIQ,"NJC")
	oWS1:oWSLIQSECUNBASE:CALICIVAOPERACION := cValToChar(aLiqImp[1][2]) //RetImpLPG(NJC->NJC_TES,"NJC") 
	oWS1:oWSLIQSECUNBASE:CCAMPANIAPPAL := ALLTRIM(NJC->NJC_CODSAF)
	oWS1:oWSLIQSECUNBASE:CCODLOCALIDAD := NJC->NJC_PROPRO
	oWS1:oWSLIQSECUNBASE:CCODPROVINCIA := RetCodPro(NJC->NJC_PROVEN)
	
	nOpDed := 1
	oWS1:oWSLIQSECUNBASE:OWSDEDUCCION := WSLPEG_ARRAYOFDEDUCCIONSEC  ():New()
		
	//Estrutura Deducciones
	aImpDeduc := RetImpLPG(NJC->NJC_CODLIQ,"NL4","Deduccion")		
	If Len(aImpDeduc) > 0
		
		For nOpDed := 1 To Len(aImpDeduc)
			//Estrutura Deducciones
			AADD(oWS1:oWSLIQSECUNBASE:OWSDEDUCCION:oWSDEDUCCIONSEC, WSLPEG_DEDUCCIONSEC ():New() )
			oWS1:oWSLIQSECUNBASE:OWSDEDUCCION:oWSDEDUCCIONSEC[nOpDed]:CDETALLEACLARATORIA := "DEDUCCION " + STR(nOpDed)     
			oWS1:oWSLIQSECUNBASE:OWSDEDUCCION:oWSDEDUCCIONSEC[nOpDed]:CBASECALCULO := cValtoChar(aImpDeduc[nOpDed][2])
			oWS1:oWSLIQSECUNBASE:OWSDEDUCCION:oWSDEDUCCIONSEC[nOpDed]:CALICUOTAIVA := cValtoChar(aImpDeduc[nOpDed][1]) 		
		Next nOpDed ++
	Else
		oWS1:oWSLIQSECUNBASE:OWSDEDUCCION := WSLPEG_ARRAYOFDEDUCCIONSEC  ():New()
		AADD(oWS1:oWSLIQSECUNBASE:OWSDEDUCCION:oWSDEDUCCIONSEC, WSLPEG_DEDUCCIONSEC ():New() )			
		oWS1:oWSLIQSECUNBASE:OWSDEDUCCION:oWSDEDUCCIONSEC[nOpDed]:CDETALLEACLARATORIA := ""  
		oWS1:oWSLIQSECUNBASE:OWSDEDUCCION:oWSDEDUCCIONSEC[nOpDed]:CBASECALCULO := ""
		oWS1:oWSLIQSECUNBASE:OWSDEDUCCION:oWSDEDUCCIONSEC[nOpDed]:CALICUOTAIVA := ""
	Endif 

	//estrutura Percepciones
	oWS1:oWSLIQSECUNBASE:oWSPERCEPCION := WSLPEG_ARRAYOFPERCPSEC ():New()
	aImpPercep := RetImpLPG(NJC->NJC_CODLIQ,"NL4","Percepcion")
	If Len(aImpPercep) > 0
		nOpDed := 0
		For nOpDed := 1 To Len(aImpPercep )
			AADD(oWS1:oWSLIQSECUNBASE:oWSPERCEPCION:OWSPERCPSEC, WSLPEG_PERCPSEC ():New() )
			oWS1:oWSLIQSECUNBASE:oWSPERCEPCION:OWSPERCPSEC[nOpDed]:CDETALLEACLARATORIA := "PERCEPCION" + " " + cValToChar(nOpDed)
			oWS1:oWSLIQSECUNBASE:oWSPERCEPCION:OWSPERCPSEC[nOpDed]:CBASECALCULO := cValtoChar(aImpPercep[nOpDed][2])
			oWS1:oWSLIQSECUNBASE:oWSPERCEPCION:OWSPERCPSEC[nOpDed]:CALICUOTA := cValtoChar(aImpPercep[nOpDed][1])
		Next nOpDed ++
	Else
		AADD(oWS1:oWSLIQSECUNBASE:oWSPERCEPCION:OWSPERCPSEC, WSLPEG_PERCPSEC ():New() )
		oWS1:oWSLIQSECUNBASE:oWSPERCEPCION:OWSPERCPSEC[1]:CDETALLEACLARATORIA := ""
		oWS1:oWSLIQSECUNBASE:oWSPERCEPCION:OWSPERCPSEC[1]:CBASECALCULO := ""
		oWS1:oWSLIQSECUNBASE:oWSPERCEPCION:OWSPERCPSEC[1]:CALICUOTA := ""
	Endif
	//Esturuta opcionales
	oWS1:oWSLIQSECUNBASE:oWSOPCIONALES := WSLPEG_ARRAYOFOPCIONALSEC  ():New()
	AADD(oWS1:oWSLIQSECUNBASE:oWSOPCIONALES:oWSOPCIONALSEC, WSLPEG_OPCIONALSEC ():New() )
	oWS1:oWSLIQSECUNBASE:oWSOPCIONALES:oWSOPCIONALSEC[1]:CCODIGO := ""
	oWS1:oWSLIQSECUNBASE:oWSOPCIONALES:oWSOPCIONALSEC[1]:CDESCRIPCION := ""
	
	oWS1:oWSLIQSECUNBASE:CDATOSADICIONALES := NJC->NJC_OBS
		
	oWS1:OWSFACTPAPEL:CNROCAI := ""
	oWS1:OWSFACTPAPEL:CNROFACTURAPAPEL := ""
	oWS1:OWSFACTPAPEL:CFECHAFACTURA := ""
	oWS1:OWSFACTPAPEL:CTIPOCOMPROBANTE := ""
	oWS1:CNROLIQUID := NJC->NJC_CODLIQ
	
	aadd(aRetNotas,aNotas)
	
	oWsLS:=	oWs1
	If oWsLS:LIQUIDAUTSECLPEG ()
		cMonitor := oWsLS:oWSLIQUIDAUTSECLPEGRESULT:oWSID:CSTRING[1]
		
		RecLock("NJC",.F.) 
			If lAutAfip
				NJC->NJC_FLLPEG := "1"
			Else
				NJC->NJC_FLLPEG := "3"
 			Endif
 			NJC->NJC_COMPRO := "" // Informar o COE depois de autorizar
		NJC->(MsUnlock())
	 		
	 	//consulta retorno da afip
	 	oWsMonit := WSWSLPEG():New()
 		oWsMonit:cUserToken := "TOTVS"
 		oWsMonit:cID_ENT    := cIdEnt
 		oWsMonit:_URL       := AllTrim(cURL)+"/WSLPEG.apw"
 		oWsMonit:cIdInicial    := cMonitor + "3"
		oWsMonit:cIdFinal      := cMonitor + "3"
		
		While lRetorno .and. nVezes <= 5
			sleep(5000)
			If oWsMonit:MONITORLPEG()                                                                 
				oRetMonitor :=  oWsMonit:OWSMONITORLPEGRESULT:OWSRESPONSEWSLPG
				lRetorno := .F.
			Endif
			nVezes++
    	EndDo
		IF Valtype(oRetMonitor) <> "U"  
			If  Valtype(oRetMonitor[1]:OWSRESERROR:OWSERRORARRAY[1]:CCODIGO) <> "U" .And.  oRetMonitor[1]:OWSRESERROR:OWSERRORARRAY[1]:CCODIGO == "1508"

				oWSConsOrd:= WSWSLPEG():New()
				oWSConsOrd:cUserToken := "TOTVS"
				oWSConsOrd:cID_ENT    := cIdEnt
				oWSConsOrd:_URL       := AllTrim(cURL)+"/WSLPEG.apw"
				oWSConsOrd:CPTOEMISION := Alltrim(NJC->NJC_PTOEMI)
				oWSConsOrd:CNROORDEN := cValToChar(nNumAfip)
				oWSConsOrd:CNROLIQUID := NJC->NJC_CODLIQ
				
				If oWSConsOrd:LIQUIDXNROORDCONS()
					If !Empty(oWSConsOrd:OWSLIQUIDXNROORDCONSRESULT:CCOE) .And. oWSConsOrd:OWSLIQUIDXNROORDCONSRESULT:CESTADO == "AC"
					
						RecLock("NJC",.F.) 
							NJC->NJC_FLLPEG := "1"
							NJC->NJC_STATUS := "3"
							NJC->NJC_COMPRO := oWSConsOrd:OWSLIQUIDXNROORDCONSRESULT:CCOE
							NJC->NJC_NRAFIP := cValToChar(nNumAfip)
							NJC->NJC_STAFIP := IIf(oWSConsOrd:OWSLIQUIDXNROORDCONSRESULT:CESTADO == "AC","1","2") //opcçoes 1=Ativo;2=Anulado
							NJC->NJC_COEAJU := "" // COE Ajustado
							NJC->NJC_DTTRAN := CTOD(oWSConsOrd:OWSLIQUIDXNROORDCONSRESULT:CDATALIQ) //Data Transmissao Afip
						NJC->(MsUnlock())
					Endif
				Endif
				
				DbSelectArea("SD2")
				DBSetOrder(3)
				//D2_FILIAL+D2_DOC+D2_SERIE
				If MSSeek(xFilial("SD2") + NJC->NJC_REMITO + NJC->NJC_SERREM )
					RecLock("SD2",.F.) 
						SD2->D2_COELQ := oWSConsOrd:OWSLIQUIDXNROORDCONSRESULT:CCOE
					SD2->(MsUnlock()) 
					SD2->(dbCloseArea())
				Endif
				FIS828GRVFIN(oWSConsOrd:OWSLIQUIDXNROORDCONSRESULT:CCOE)
			ElseIf (Valtype(oRetMonitor[1]:CRESULTADO) <> "U" .And. oRetMonitor[1]:CRESULTADO == "A")
				RecLock("NJC",.F.) 
				NJC->NJC_FLLPEG := "1"
					NJC->NJC_STATUS := "3"
					NJC->NJC_COMPRO := Alltrim(oRetMonitor[1]:CCOE)
					NJC->NJC_NRAFIP := Alltrim(oRetMonitor[1]:CNRAFIP)
					NJC->NJC_STAFIP := IIf(oRetMonitor[1]:CESTADO == "AC","1","2") //opcçoes 1=Ativo;2=Anulado
					NJC->NJC_COEAJU := "" // COE Ajustado
					NJC->NJC_DTTRAN := dDatabase //Data Transmissao Afip
				NJC->(MsUnlock())

				DbSelectArea("SD2")
				DBSetOrder(3)
				//D2_FILIAL+D2_DOC+D2_SERIE
				If MSSeek(xFilial("SD2") + NJC->NJC_REMITO + NJC->NJC_SERREM )
					RecLock("SD2",.F.) 
						SD2->D2_COELQ := Alltrim(oRetMonitor[1]:CCOE)
					SD2->(MsUnlock()) 
					SD2->(dbCloseArea())
				Endif
				FIS828GRVFIN(Alltrim(oRetMonitor[1]:CCOE))
			Endif
		EndIF
	Else
		If lAutAfip
			RecLock("NJC",.F.) 
				NJC->NJC_FLLPEG := "1"
				cCoe := cValToChar(Randomize( 100000000, 999999999 ))
				NJC->NJC_COMPRO := cCoe
				NJC->NJC_NRAFIP := NJC->NJC_CODLIQ
				NJC->NJC_STATUS := "AC"
			NJC->(MsUnlock())
			
			FIS828GRVFIN(cCoe)
			DbSelectArea("SD2")
			DBSetOrder(3)
			//D2_FILIAL+D2_DOC+D2_SERIE
			MSSeek(xFilial("SD2") + NJC->NJC_REMITO + NJC->NJC_SERREM )
			RecLock("SD2",.F.) 
				SD2->D2_COELQ := cCoe
			SD2->(MsUnlock())
			SD2->(dbCloseArea())
		Else	
			cErro := GetWscError(3)
			DEFAULT cErro := STR0047 //"Erro indeterminado"
			lRetorno := .F.
		Endif	
	Endif

ElseIf (cModeloWS $"8" .And. cTipo == "1" .And. cTipoLiq $ "2") //Ajuste Primario
	
	oWs1 := WSWSLPEG():New()
	oWs1:cUserToken := "TOTVS"
	oWs1:cID_ENT    := cIdEnt
	oWS1:_URL       := AllTrim(cURL)+"/WSLPEG.apw"
	oWS1:OWSAJUSTBASE:CPTOEMISION := Alltrim(NJC->NJC_PTOEMI)
	oWS1:OWSAJUSTBASE:CNRORDEN := IIf(lAutAfip,NJC->NJC_CODLIQ,cValToChar(nNumAfip))
	oWS1:OWSAJUSTBASE:CCOEAJUSTADO := ALLTRIM(NJC->NJC_COEAJU)
	
	
	cQuery := " SELECT * FROM "
	cQuery += cAliasNL3 + " AS NL3 " 
	cQuery +=  " INNER JOIN "
	cQuery += cAliasNJA + " AS NJA "
	cQuery += " ON "
	cQuery += " NL3.NL3_CODCET = NJA.NJA_CODCET "
	cQuery += " WHERE " 
	cQuery += " NL3.NL3_CODLIQ = '"+NJC->NJC_CODLIQ+"' AND " 
	cQuery += " NL3.D_E_L_E_T_ = '' AND "
	cQuery += " NJA.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)                    
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpCert,.T.,.T.) 
		
	Count to nCont
	lCert := .T.
	(cTmpCert)->(dbGoTop())
		
	nZ := 1
			
	oWS1:OWSAJUSTBASE:OWSCERTIFICADOS := WSLPEG_ARRAYOFCERTIFICADO():New()
	AADD(oWS1:OWSAJUSTBASE:OWSCERTIFICADOS:oWSCERTIFICADO, WSLPEG_CERTIFICADO ():New() )
		
	oWS1:OWSAJUSTBASE:OWSCERTIFICADOS:oWSCERTIFICADO[nZ]:CTIPOCERTDEPOSITO := (cTmpCert)->NL3_TIPLIQ // Leandro tres casas decimais - 100
	oWS1:OWSAJUSTBASE:OWSCERTIFICADOS:oWSCERTIFICADO[nZ]:CNROCERTDEPOSITO := (cTmpCert)->NL3_CODCET // Leandro 100000001 confirmar o retorno que teremos nos certificado.
	oWS1:OWSAJUSTBASE:OWSCERTIFICADOS:oWSCERTIFICADO[nZ]:CPESONETO := cValToChar((cTmpCert)->NL3_PESNETO * 100) // Leandro mesmo problema da mascara da liquidação primaria nao pode ter virgula cValToChar((cTmpCert)->NL3_PESNETO) 
	oWS1:OWSAJUSTBASE:OWSCERTIFICADOS:oWSCERTIFICADO[nZ]:CPESONETOTOTALCERT := cValToChar((cTmpCert)->NL3_PESNETO) //pesoNetoTotalCertificado
	oWS1:OWSAJUSTBASE:OWSCERTIFICADOS:oWSCERTIFICADO[nZ]:CCODLOCALPROCEDENCIA :=  "3"// Leandro (cTmpCert)->NL3_LOCPRO
	oWS1:OWSAJUSTBASE:OWSCERTIFICADOS:oWSCERTIFICADO[nZ]:CCODPROVPROCEDENCIA := "1"// Leandro RetCodPro((cTmpCert)->NL3_PROPRO) //(cTmpCert)->NL3_PROPRO
	oWS1:OWSAJUSTBASE:OWSCERTIFICADOS:oWSCERTIFICADO[nZ]:CCAMPANIA := (cTmpCert)->NL3_CODSAF
	oWS1:OWSAJUSTBASE:OWSCERTIFICADOS:oWSCERTIFICADO[nZ]:CFECHACIERRE :=   (Substr(DtoS(dDatabase),1,4) + "-" + Substr(DtoS(dDatabase),5,2) + "-" + Substr(DtoS(dDatabase),7,2)) // Leandro campo obrigatorio para afip... Observar se a tabela nl3 esta preenchida. (Substr((cTmpCert)->NL3_DATA,1,4) + "-" + Substr((cTmpCert)->NL3_DATA,5,2) + "-" + Substr((cTmpCert)->NL3_DATA,7,2)) 
		
	oWS1:OWSAJUSTBASE:CCODLOCALIDAD := ALLTRIM(NJC->NJC_PROPRO)
	oWS1:OWSAJUSTBASE:CCODPROV := RetCodPro(NJC->NJC_PROVEN)

	oWS1:OWSAJUSTBASE:OWSFUSION := WSLPEG_AJUSTFUSION():New()
	oWS1:OWSAJUSTBASE:OWSFUSION:CNROINGBRUTOS := ""
	oWS1:OWSAJUSTBASE:OWSFUSION:CNROACTIVIDAD := ""
	nYC := 1
	nYD := 1

	DbSelectArea("NL4")
	DbSetOrder(1)
	If  msSeek(xFilial("NL4") + NJC->NJC_CODLIQ) 
		While NL4->(!Eof())
			IF NL4->NL4_CODLIQ == NJC->NJC_CODLIQ
				cTipoOper := Posicione("FR8",1,xFilial("FR8") + NL4->NL4_TIPDED,"FR8_TIPOOP")
				ConceptoDed(cTipoOper)
				IF NL4->NL4_TIPAJU  == "2"
					//Dados Ajuste Credito
					If oWS1:OWSAJUSTCREDT:OWSCERTIFICADOS == Nil
						oWS1:OWSAJUSTCREDT:OWSCERTIFICADOS:= WSLPEG_ARRAYOFCERTIFICADOAJUSTE():New()
					EndIf
					AADD(oWS1:OWSAJUSTCREDT:OWSCERTIFICADOS:OWSCERTIFICADOAJUSTE, WSLPEG_CERTIFICADOAJUSTE ():New() )
					oWS1:OWSAJUSTCREDT:OWSCERTIFICADOS:OWSCERTIFICADOAJUSTE[nYC]:CCOE := ALLTRIM(NJC->NJC_COMPRO)
					oWS1:OWSAJUSTCREDT:OWSCERTIFICADOS:OWSCERTIFICADOAJUSTE[nYC]:CPESOAJUSTADO := cValToChar((cTmpCert)->NL3_PESNETO)
					
					oWS1:OWSAJUSTCREDT:CDIFERENCIAPESONETO := cValToChar( NJC->NJC_PESSCE - NL4->NL4_QUANT) // Leandro Valor entero de un total de  8 dígitos. Valor mínimo permitido (inclusivo) 0 Valor máximo permitido (inclusivo) 99999999
					oWS1:OWSAJUSTCREDT:CDIFERENCIAPRECIOOPERACION :=  cValToChar( NJC->NJC_PRECO - NL4->NL4_PRECIO)
					oWS1:OWSAJUSTCREDT:CCODGRADO := ALLTRIM(NJC->NJC_GDOREF)
					oWS1:OWSAJUSTCREDT:CVALGRADO := cValToChar(NJC->NJC_PRECO) // Leandro Valores posibles desde 0.001 a 1.999 inclusive
					oWS1:OWSAJUSTCREDT:CFACTOR := cValToChar(NJC->NJC_FACTOR) // Leandro Valores posibles desde 0.001 a 999.999 inclusive
					oWS1:OWSAJUSTCREDT:CDIFERENCIAPRECIOFLETETN := cValToChar(NJC->NJC_FRETE) // Leandro Valores posibles desde 0.00 a 99999.99 inclusive
					oWS1:OWSAJUSTCREDT:CDATOSADICIONALES := ""
						
					//Dados Opicionales Credito
					If oWS1:OWSAJUSTCREDT:OWSOPCIONALES == Nil
						oWS1:OWSAJUSTCREDT:OWSOPCIONALES := WSLPEG_ARRAYOFOPICIONALAJUSTE():New()
					EndIf
					AADD(oWS1:OWSAJUSTCREDT:OWSOPCIONALES:oWSOPICIONALAJUSTE, WSLPEG_OPICIONALAJUSTE ():New() )
					oWS1:OWSAJUSTCREDT:OWSOPCIONALES:oWSOPICIONALAJUSTE[nYC]:CCODIGO := ""
					oWS1:OWSAJUSTCREDT:OWSOPCIONALES:oWSOPICIONALAJUSTE[nYC]:CDESCRIPCION := ""
					oWS1:OWSAJUSTCREDT:CCONCEPTOIMPORTEIVA0 := ""
					oWS1:OWSAJUSTCREDT:CIMPORTEAJUSTARIVA0  := "0"
					oWS1:OWSAJUSTCREDT:CCONCEPTOIMPORTEIVA105 := ""
					oWS1:OWSAJUSTCREDT:CIMPORTEAJUSTARIVA105  := "0"
					oWS1:OWSAJUSTCREDT:CCONCEPTOIMPORTEIVA21 := ""
					oWS1:OWSAJUSTCREDT:CIMPORTEAJUSTARIVA21  := "0"

					
					//Dados Deducciones Credito
					If oWS1:OWSAJUSTCREDT:OWSDEDUCCIONES == Nil
						oWS1:OWSAJUSTCREDT:OWSDEDUCCIONES := WSLPEG_ARRAYOFDEDUCCIONAJUSTE():New()
					EndIf
					AADD(oWS1:OWSAJUSTCREDT:OWSDEDUCCIONES:OWSDEDUCCIONAJUSTE, WSLPEG_DEDUCCIONAJUSTE ():New() )
					oWS1:OWSAJUSTCREDT:OWSDEDUCCIONES:OWSDEDUCCIONAJUSTE[nYC]:CCODIGOCONCEPTO := cConcepto
					oWS1:OWSAJUSTCREDT:OWSDEDUCCIONES:OWSDEDUCCIONAJUSTE[nYC]:CDETALLEACLARATORIO := cDetalle
					IF oWS1:OWSAJUSTCREDT:OWSDEDUCCIONES:OWSDEDUCCIONAJUSTE[nYC]:CCODIGOCONCEPTO == "AL"
						oWS1:OWSAJUSTCREDT:OWSDEDUCCIONES:OWSDEDUCCIONAJUSTE[nYC]:CDIASALMACENAJE  := cValToChar(NL4->NL4_DIAALM) // Leandro Valor entero de un total de  4 dígitos. Valor mínimo permitido (inclusivo) 0 Valor máximo permitido (inclusivo) 9999 
						oWS1:OWSAJUSTCREDT:OWSDEDUCCIONES:OWSDEDUCCIONAJUSTE[nYC]:CPRECIOPKGDIARIO := cValtoChar(NL4->NL4_PRECIO)
					Else
						oWS1:OWSAJUSTCREDT:OWSDEDUCCIONES:OWSDEDUCCIONAJUSTE[nYC]:CDIASALMACENAJE  := "0"
						oWS1:OWSAJUSTCREDT:OWSDEDUCCIONES:OWSDEDUCCIONAJUSTE[nYC]:CPRECIOPKGDIARIO := "0"
					EndIf
					If NJC->NJC_OPERAC == "2" 
						oWS1:OWSAJUSTCREDT:OWSDEDUCCIONES:OWSDEDUCCIONAJUSTE[nYC]:CCOMISIONGASTOSADM := cValtoChar(NL4->NL4_PORCEN)
					Else
						oWS1:OWSAJUSTCREDT:OWSDEDUCCIONES:OWSDEDUCCIONAJUSTE[nYC]:CCOMISIONGASTOSADM := ""
					EndIf
					IF oWS1:OWSAJUSTCREDT:OWSDEDUCCIONES:OWSDEDUCCIONAJUSTE[nYC]:CCODIGOCONCEPTO == "AL"
						oWS1:OWSAJUSTCREDT:OWSDEDUCCIONES:OWSDEDUCCIONAJUSTE[nYC]:CBASECALCULO := ""
						oWS1:OWSAJUSTCREDT:OWSDEDUCCIONES:OWSDEDUCCIONAJUSTE[nYC]:CALICUOTAIVA := ""
					Else
						If SF4->( MsSeek( xFilial("SF4")+NL4->NL4_CODTES) )
							If SFC->( MsSeek( xFilial("SFC")+SF4->F4_CODIGO) )
								While SFC ->( !Eof() .And. SFC->FC_FILIAL+SFC->FC_TES == xFilial("SFC")+SF4->F4_CODIGO )
									If SFB->( MsSeek( xFilial("SFB")+SFC->FC_IMPOSTO ) )
										IF SFB->FB_CLASSIF == "3" .AND. SFB->FB_TIPO == "N"	 .AND. SFB->FB_CLASSE == "I" .AND. !lTemIva 
											lTemIva := .T.									
											nValBasIva := &("NL4->NL4_BASIM"+SFB->FB_CPOLVRO)
											nValAlqIva := &("NL4->NL4_ALQIM"+SFB->FB_CPOLVRO)
											oWS1:OWSAJUSTCREDT:OWSDEDUCCIONES:OWSDEDUCCIONAJUSTE[nYC]:CBASECALCULO := cValtoChar(nValBasIva) // LEANDRO ENTENDER O CONCEITO DOS CAMPO NL4 BASIM ALQIM E VALIM
											oWS1:OWSAJUSTCREDT:OWSDEDUCCIONES:OWSDEDUCCIONAJUSTE[nYC]:CALICUOTAIVA := cValtoChar(nValAlqIva)
											Do Case 
												Case SFB->FB_ALIQ == 0
													oWS1:OWSAJUSTCREDT:CCONCEPTOIMPORTEIVA0 := cConcepto
													nIva0Cred += NL4->NL4_IMPORT
													oWS1:OWSAJUSTCREDT:CIMPORTEAJUSTARIVA0  := cValtoChar(nIva0Cred)
												Case SFB->FB_ALIQ == 10.5
													oWS1:OWSAJUSTCREDT:CCONCEPTOIMPORTEIVA105 := cConcepto
													nIva105Cred += NL4->NL4_IMPORT
													oWS1:OWSAJUSTCREDT:CIMPORTEAJUSTARIVA105  := cValtoChar(nIva105Cred)
												Case SFB->FB_ALIQ == 21
													oWS1:OWSAJUSTCREDT:CCONCEPTOIMPORTEIVA21 := cConcepto
													nIva21Cred += NL4->NL4_IMPORT
													oWS1:OWSAJUSTCREDT:CIMPORTEAJUSTARIVA21  := cValtoChar(nIva21Cred)

											EndCase
										EndIf
									EndIf	
									SFC->( DbSkip() )
								Enddo
							EndIf
						EndIf
					EndIf
					IF !lTemIva 
						oWS1:OWSAJUSTCREDT:OWSDEDUCCIONES:OWSDEDUCCIONAJUSTE[nYC]:CBASECALCULO := "0" 
						oWS1:OWSAJUSTCREDT:OWSDEDUCCIONES:OWSDEDUCCIONAJUSTE[nYC]:CALICUOTAIVA := "0"
					EndIF
					nYC ++
					
					//Carrega o tipo de ajuste NÃO utilizado, para que o sistema gere o xml corretamente.
					IF lTemDeb
						lTemDeb := .F.
						//Dados Ajuste Debito 
						If oWS1:OWSAJUSTDEBT:OWSCERTIFICADOS == Nil
							oWS1:OWSAJUSTDEBT:OWSCERTIFICADOS := WSLPEG_ARRAYOFCERTIFICADOAJUSTE():New()
						EndIf
						AADD(oWS1:OWSAJUSTDEBT:OWSCERTIFICADOS:OWSCERTIFICADOAJUSTE, WSLPEG_CERTIFICADOAJUSTE ():New() )
						oWS1:OWSAJUSTDEBT:OWSCERTIFICADOS:OWSCERTIFICADOAJUSTE[nYD]:CCOE := ""
						oWS1:OWSAJUSTDEBT:OWSCERTIFICADOS:OWSCERTIFICADOAJUSTE[nYD]:CPESOAJUSTADO := "0"
						oWS1:OWSAJUSTDEBT:CDIFERENCIAPESONETO := "0"
						oWS1:OWSAJUSTDEBT:CDIFERENCIAPRECIOOPERACION := "0"
						oWS1:OWSAJUSTDEBT:CCODGRADO := ""
						oWS1:OWSAJUSTDEBT:CVALGRADO := "0"
						oWS1:OWSAJUSTDEBT:CFACTOR := "0"
						oWS1:OWSAJUSTDEBT:CDIFERENCIAPRECIOFLETETN := ""
						oWS1:OWSAJUSTDEBT:CDATOSADICIONALES := ""
						//Dados Opicionales Debito
						If oWS1:OWSAJUSTDEBT:oWSOPCIONALES == Nil
							oWS1:OWSAJUSTDEBT:oWSOPCIONALES := WSLPEG_ARRAYOFOPICIONALAJUSTE():New()
						EndIf
						AADD(oWS1:OWSAJUSTDEBT:OWSOPCIONALES:OWSOPICIONALAJUSTE, WSLPEG_OPICIONALAJUSTE ():New() )
						oWS1:OWSAJUSTDEBT:OWSOPCIONALES:OWSOPICIONALAJUSTE[1]:CCODIGO := ""
						oWS1:OWSAJUSTDEBT:OWSOPCIONALES:OWSOPICIONALAJUSTE[1]:CDESCRIPCION := ""
						oWS1:OWSAJUSTDEBT:CCONCEPTOIMPORTEIVA0 := ""
						oWS1:OWSAJUSTDEBT:CIMPORTEAJUSTARIVA0  := "0"
						oWS1:OWSAJUSTDEBT:CCONCEPTOIMPORTEIVA105 := ""
						oWS1:OWSAJUSTDEBT:CIMPORTEAJUSTARIVA105  := "0"
						oWS1:OWSAJUSTDEBT:CCONCEPTOIMPORTEIVA21 := ""
						oWS1:OWSAJUSTDEBT:CIMPORTEAJUSTARIVA21  := "0"
						//Dados Deducciones Debito
						If oWS1:OWSAJUSTDEBT:OWSDEDUCCIONES == Nil
							oWS1:OWSAJUSTDEBT:OWSDEDUCCIONES := WSLPEG_ARRAYOFDEDUCCIONAJUSTE():New()
						EndIf
						AADD(oWS1:OWSAJUSTDEBT:OWSDEDUCCIONES:oWSDEDUCCIONAJUSTE, WSLPEG_DEDUCCIONAJUSTE ():New() )
						oWS1:OWSAJUSTDEBT:OWSDEDUCCIONES:oWSDEDUCCIONAJUSTE[nYD]:CCODIGOCONCEPTO := ""
						oWS1:OWSAJUSTDEBT:OWSDEDUCCIONES:oWSDEDUCCIONAJUSTE[nYD]:CDETALLEACLARATORIO := ""
						oWS1:OWSAJUSTDEBT:OWSDEDUCCIONES:oWSDEDUCCIONAJUSTE[nYD]:CDIASALMACENAJE := ""
						oWS1:OWSAJUSTDEBT:OWSDEDUCCIONES:oWSDEDUCCIONAJUSTE[nYD]:CPRECIOPKGDIARIO := ""
						oWS1:OWSAJUSTDEBT:OWSDEDUCCIONES:oWSDEDUCCIONAJUSTE[nYD]:CCOMISIONGASTOSADM := ""
						oWS1:OWSAJUSTDEBT:OWSDEDUCCIONES:oWSDEDUCCIONAJUSTE[nYD]:CBASECALCULO := ""
						oWS1:OWSAJUSTDEBT:OWSDEDUCCIONES:oWSDEDUCCIONAJUSTE[nYD]:CALICUOTAIVA := ""
					EndIF
		
				
				Else
			
					//Dados Ajuste Debito 
					If oWS1:OWSAJUSTDEBT:OWSCERTIFICADOS == Nil
						oWS1:OWSAJUSTDEBT:OWSCERTIFICADOS := WSLPEG_ARRAYOFCERTIFICADOAJUSTE():New()
					EndIf
					AADD(oWS1:OWSAJUSTDEBT:OWSCERTIFICADOS:OWSCERTIFICADOAJUSTE, WSLPEG_CERTIFICADOAJUSTE ():New() )
					oWS1:OWSAJUSTDEBT:OWSCERTIFICADOS:OWSCERTIFICADOAJUSTE[nYD]:CCOE := ALLTRIM(NJC->NJC_COMPRO)
					oWS1:OWSAJUSTDEBT:OWSCERTIFICADOS:OWSCERTIFICADOAJUSTE[nYD]:CPESOAJUSTADO := cValToChar((cTmpCert)->NL3_PESNETO)
						
					oWS1:OWSAJUSTDEBT:CDIFERENCIAPESONETO := cValToChar( NJC->NJC_PESSCE - NL4->NL4_QUANT) // Leandro Valor entero de un total de  8 dígitos. Valor mínimo permitido (inclusivo) 0 Valor máximo permitido (inclusivo) 99999999
					oWS1:OWSAJUSTDEBT:CDIFERENCIAPRECIOOPERACION := cValToChar( NJC->NJC_PRECO - NL4->NL4_PRECIO)
					oWS1:OWSAJUSTDEBT:CCODGRADO := ALLTRIM(NJC->NJC_GDOREF) 
					oWS1:OWSAJUSTDEBT:CVALGRADO := cValToChar(NJC->NJC_PRECO) // Leandro Valores posibles desde 0.001 a 1.999 inclusive
					oWS1:OWSAJUSTDEBT:CFACTOR := cValToChar(NJC->NJC_FACTOR) // Leandro Valores posibles desde 0.001 a 999.999 inclusive
					oWS1:OWSAJUSTDEBT:CDIFERENCIAPRECIOFLETETN := cValToChar(NJC->NJC_FRETE) // Leandro confirmar essa informaçao.
					oWS1:OWSAJUSTDEBT:CDATOSADICIONALES := ""
						
					//Dados Opicionales Debito
					If oWS1:OWSAJUSTDEBT:oWSOPCIONALES == Nil
						oWS1:OWSAJUSTDEBT:oWSOPCIONALES := WSLPEG_ARRAYOFOPICIONALAJUSTE():New()
					EndIf
					AADD(oWS1:OWSAJUSTDEBT:OWSOPCIONALES:OWSOPICIONALAJUSTE, WSLPEG_OPICIONALAJUSTE ():New() )
					oWS1:OWSAJUSTDEBT:OWSOPCIONALES:OWSOPICIONALAJUSTE[nYD]:CCODIGO := ""
					oWS1:OWSAJUSTDEBT:OWSOPCIONALES:OWSOPICIONALAJUSTE[nYD]:CDESCRIPCION := ""
					oWS1:OWSAJUSTDEBT:CCONCEPTOIMPORTEIVA0 := ""
					oWS1:OWSAJUSTDEBT:CIMPORTEAJUSTARIVA0  := "0"
					oWS1:OWSAJUSTDEBT:CCONCEPTOIMPORTEIVA105 := ""
					oWS1:OWSAJUSTDEBT:CIMPORTEAJUSTARIVA105  := "0"
					oWS1:OWSAJUSTDEBT:CCONCEPTOIMPORTEIVA21 := ""
					oWS1:OWSAJUSTDEBT:CIMPORTEAJUSTARIVA21  := "0"
				
						
					//Dados Deducciones Debito
					If oWS1:OWSAJUSTDEBT:OWSDEDUCCIONES == Nil
						oWS1:OWSAJUSTDEBT:OWSDEDUCCIONES := WSLPEG_ARRAYOFDEDUCCIONAJUSTE():New()
					EndIf
					AADD(oWS1:OWSAJUSTDEBT:OWSDEDUCCIONES:oWSDEDUCCIONAJUSTE, WSLPEG_DEDUCCIONAJUSTE ():New() )
					oWS1:OWSAJUSTDEBT:OWSDEDUCCIONES:oWSDEDUCCIONAJUSTE[nYD]:CCODIGOCONCEPTO := cConcepto
					oWS1:OWSAJUSTDEBT:OWSDEDUCCIONES:oWSDEDUCCIONAJUSTE[nYD]:CDETALLEACLARATORIO := cDetalle
					IF oWS1:OWSAJUSTDEBT:OWSDEDUCCIONES:oWSDEDUCCIONAJUSTE[nYD]:CCODIGOCONCEPTO == "AL"
						oWS1:OWSAJUSTDEBT:OWSDEDUCCIONES:oWSDEDUCCIONAJUSTE[nYD]:CDIASALMACENAJE := cValToChar(NL4->NL4_DIAALM) // Leandro Valor entero de un total de  4 dígitos. Valor mínimo permitido (inclusivo) 0 Valor máximo permitido (inclusivo) 9999 
						oWS1:OWSAJUSTDEBT:OWSDEDUCCIONES:oWSDEDUCCIONAJUSTE[nYD]:CPRECIOPKGDIARIO := cValtoChar(NL4->NL4_PRECIO)
					Else
						oWS1:OWSAJUSTDEBT:OWSDEDUCCIONES:oWSDEDUCCIONAJUSTE[nYD]:CDIASALMACENAJE := "0"
						oWS1:OWSAJUSTDEBT:OWSDEDUCCIONES:oWSDEDUCCIONAJUSTE[nYD]:CPRECIOPKGDIARIO := "0"
					EndiF
					If NJC->NJC_OPERAC == "2" 
						oWS1:OWSAJUSTDEBT:OWSDEDUCCIONES:oWSDEDUCCIONAJUSTE[nYD]:CCOMISIONGASTOSADM := cValtoChar(NL4->NL4_PORCEN)
					Else
						oWS1:OWSAJUSTDEBT:OWSDEDUCCIONES:oWSDEDUCCIONAJUSTE[nYD]:CCOMISIONGASTOSADM := ""
					EndIf
					IF oWS1:OWSAJUSTDEBT:OWSDEDUCCIONES:oWSDEDUCCIONAJUSTE[nYD]:CCODIGOCONCEPTO == "AL"
						oWS1:OWSAJUSTDEBT:OWSDEDUCCIONES:oWSDEDUCCIONAJUSTE[nYD]:CBASECALCULO := ""
						oWS1:OWSAJUSTDEBT:OWSDEDUCCIONES:oWSDEDUCCIONAJUSTE[nYD]:CALICUOTAIVA := ""
					Else
						If SF4->( MsSeek( xFilial("SF4")+NL4->NL4_CODTES) )
							If SFC->( MsSeek( xFilial("SFC")+SF4->F4_CODIGO) )
								While SFC ->( !Eof() .And. SFC->FC_FILIAL+SFC->FC_TES == xFilial("SFC")+SF4->F4_CODIGO )
									If SFB->( MsSeek( xFilial("SFB")+SFC->FC_IMPOSTO ) )
										IF SFB->FB_CLASSIF == "3" .AND. SFB->FB_TIPO == "N"	 .AND. SFB->FB_CLASSE == "I" .AND. !lTemIva 
											lTemIva := .T.									
											nValBasIva := &("NL4->NL4_BASIM"+SFB->FB_CPOLVRO)
											nValAlqIva := &("NL4->NL4_ALQIM"+SFB->FB_CPOLVRO)
											oWS1:OWSAJUSTDEBT:OWSDEDUCCIONES:oWSDEDUCCIONAJUSTE[nYD]:CBASECALCULO := cValtoChar(nValBasIva) // LEANDRO ENTENDER O CONCEITO DOS CAMPO NL4 BASIM ALQIM E VALIM
											oWS1:OWSAJUSTDEBT:OWSDEDUCCIONES:oWSDEDUCCIONAJUSTE[nYD]:CALICUOTAIVA := cValtoChar(nValAlqIva)
											Do Case 
												Case SFB->FB_ALIQ == 0
													oWS1:OWSAJUSTDEBT:CCONCEPTOIMPORTEIVA0 := cConcepto
													nIva0Deb += NL4_IMPORT
													oWS1:OWSAJUSTDEBT:CIMPORTEAJUSTARIVA0  := cValtoChar(nIva0Deb)
												Case SFB->FB_ALIQ == 10.5
													oWS1:OWSAJUSTDEBT:CCONCEPTOIMPORTEIVA105 := cConcepto
													nIva105Deb += NL4_IMPORT
													oWS1:OWSAJUSTDEBT:CIMPORTEAJUSTARIVA105  := cValtoChar(nIva105Deb)
												Case SFB->FB_ALIQ == 21
													oWS1:OWSAJUSTDEBT:CCONCEPTOIMPORTEIVA21 := cConcepto
													nIva21Deb += NL4_IMPORT
													oWS1:OWSAJUSTDEBT:CIMPORTEAJUSTARIVA21  := cValtoChar(nIva21Deb)

											EndCase

										EndIf
									EndIf	
									SFC->( DbSkip() )
								Enddo
							EndIf
						EndIf
						IF !lTemIva 
							oWS1:OWSAJUSTDEBT:OWSDEDUCCIONES:oWSDEDUCCIONAJUSTE[nYD]:CBASECALCULO := "0" 
							oWS1:OWSAJUSTDEBT:OWSDEDUCCIONES:oWSDEDUCCIONAJUSTE[nYD]:CALICUOTAIVA := "0"
						EndIF
						nYD ++
					EndIF
					//Carrega o tipo de ajuste NÃO utilizado, para que o sistema gere o xml corretamente.
					//Dados Ajuste Credito
					IF lTemCred
						lTemCred := .F.
						If oWS1:OWSAJUSTCREDT:OWSCERTIFICADOS == Nil
							oWS1:OWSAJUSTCREDT:OWSCERTIFICADOS:= WSLPEG_ARRAYOFCERTIFICADOAJUSTE():New()
						EndIf
						AADD(oWS1:OWSAJUSTCREDT:OWSCERTIFICADOS:OWSCERTIFICADOAJUSTE, WSLPEG_CERTIFICADOAJUSTE ():New() )
						oWS1:OWSAJUSTCREDT:OWSCERTIFICADOS:OWSCERTIFICADOAJUSTE[nYC]:CCOE := ""
						oWS1:OWSAJUSTCREDT:OWSCERTIFICADOS:OWSCERTIFICADOAJUSTE[nYC]:CPESOAJUSTADO := "0"
						oWS1:OWSAJUSTCREDT:CDIFERENCIAPESONETO := "0"
						oWS1:OWSAJUSTCREDT:CDIFERENCIAPRECIOOPERACION := "0"
						oWS1:OWSAJUSTCREDT:CCODGRADO := ""
						oWS1:OWSAJUSTCREDT:CVALGRADO := "0"
						oWS1:OWSAJUSTCREDT:CFACTOR := "0"
						oWS1:OWSAJUSTCREDT:CDIFERENCIAPRECIOFLETETN := ""
						oWS1:OWSAJUSTCREDT:CDATOSADICIONALES := ""
						//Dados Opicionales Credito
						If oWS1:OWSAJUSTCREDT:OWSOPCIONALES == Nil
							oWS1:OWSAJUSTCREDT:OWSOPCIONALES := WSLPEG_ARRAYOFOPICIONALAJUSTE():New()
						EndIf
						AADD(oWS1:OWSAJUSTCREDT:OWSOPCIONALES:oWSOPICIONALAJUSTE, WSLPEG_OPICIONALAJUSTE ():New() )
						oWS1:OWSAJUSTCREDT:OWSOPCIONALES:oWSOPICIONALAJUSTE[1]:CCODIGO := ""
						oWS1:OWSAJUSTCREDT:OWSOPCIONALES:oWSOPICIONALAJUSTE[1]:CDESCRIPCION := ""
						oWS1:OWSAJUSTCREDT:CCONCEPTOIMPORTEIVA0 := ""
						oWS1:OWSAJUSTCREDT:CIMPORTEAJUSTARIVA0  := "0"
						oWS1:OWSAJUSTCREDT:CCONCEPTOIMPORTEIVA105 := ""
						oWS1:OWSAJUSTCREDT:CIMPORTEAJUSTARIVA105  := "0"
						oWS1:OWSAJUSTCREDT:CCONCEPTOIMPORTEIVA21 := ""
						oWS1:OWSAJUSTCREDT:CIMPORTEAJUSTARIVA21  := "0"
						//Dados Deducciones Credito
						If oWS1:OWSAJUSTCREDT:OWSDEDUCCIONES == Nil
							oWS1:OWSAJUSTCREDT:OWSDEDUCCIONES := WSLPEG_ARRAYOFDEDUCCIONAJUSTE():New()
						EndIf
						AADD(oWS1:OWSAJUSTCREDT:OWSDEDUCCIONES:OWSDEDUCCIONAJUSTE, WSLPEG_DEDUCCIONAJUSTE ():New() )
						oWS1:OWSAJUSTCREDT:OWSDEDUCCIONES:OWSDEDUCCIONAJUSTE[nYC]:CCODIGOCONCEPTO := ""
						oWS1:OWSAJUSTCREDT:OWSDEDUCCIONES:OWSDEDUCCIONAJUSTE[nYC]:CDETALLEACLARATORIO := ""
						oWS1:OWSAJUSTCREDT:OWSDEDUCCIONES:OWSDEDUCCIONAJUSTE[nYC]:CDIASALMACENAJE  := ""
						oWS1:OWSAJUSTCREDT:OWSDEDUCCIONES:OWSDEDUCCIONAJUSTE[nYC]:CPRECIOPKGDIARIO := ""
						oWS1:OWSAJUSTCREDT:OWSDEDUCCIONES:OWSDEDUCCIONAJUSTE[nYC]:CCOMISIONGASTOSADM := ""
						oWS1:OWSAJUSTCREDT:OWSDEDUCCIONES:OWSDEDUCCIONAJUSTE[nYC]:CBASECALCULO := "0"
						oWS1:OWSAJUSTCREDT:OWSDEDUCCIONES:OWSDEDUCCIONAJUSTE[nYC]:CALICUOTAIVA := "0"
					EndIF

				
				EndIf
			EndIF
		
			NL4->(DbSkip())
		EndDo
	EndIF
	NL4->(DBCloseArea())

	
	//Dados Retenciones Credito
	oWS1:OWSAJUSTCREDT:OWSRETENCIONES := WSLPEG_ARRAYOFRETENCIONAJUSTE():New()
	AADD(oWS1:OWSAJUSTCREDT:OWSRETENCIONES:OWSRETENCIONAJUSTE, WSLPEG_RETENCIONAJUSTE ():New() )
	oWS1:OWSAJUSTCREDT:OWSRETENCIONES:OWSRETENCIONAJUSTE[1]:CCODIGOCONCEPTO := ""
	oWS1:OWSAJUSTCREDT:OWSRETENCIONES:OWSRETENCIONAJUSTE[1]:CDETALLEACLARATORIO := ""
	oWS1:OWSAJUSTCREDT:OWSRETENCIONES:OWSRETENCIONAJUSTE[1]:CBASECALCULO := ""
	oWS1:OWSAJUSTCREDT:OWSRETENCIONES:OWSRETENCIONAJUSTE[1]:CALICUOTA := ""
	oWS1:OWSAJUSTCREDT:OWSRETENCIONES:OWSRETENCIONAJUSTE[1]:CNROCERTIFICADORETENCION := ""
	oWS1:OWSAJUSTCREDT:OWSRETENCIONES:OWSRETENCIONAJUSTE[1]:CFECHACERTIFICADORETENCION := ""
	oWS1:OWSAJUSTCREDT:OWSRETENCIONES:OWSRETENCIONAJUSTE[1]:CIMPORTECERTIFICADORETENCION := ""

	//Dados Retenciones Debito
	oWS1:OWSAJUSTDEBT:OWSRETENCIONES := WSLPEG_ARRAYOFRETENCIONAJUSTE():New()
	AADD(oWS1:OWSAJUSTDEBT:OWSRETENCIONES:OWSRETENCIONAJUSTE, WSLPEG_RETENCIONAJUSTE ():New() )
	oWS1:OWSAJUSTDEBT:OWSRETENCIONES:OWSRETENCIONAJUSTE[1]:CCODIGOCONCEPTO := ""
	oWS1:OWSAJUSTDEBT:OWSRETENCIONES:OWSRETENCIONAJUSTE[1]:CDETALLEACLARATORIO := ""
	oWS1:OWSAJUSTDEBT:OWSRETENCIONES:OWSRETENCIONAJUSTE[1]:CBASECALCULO := ""
	oWS1:OWSAJUSTDEBT:OWSRETENCIONES:OWSRETENCIONAJUSTE[1]:CALICUOTA := ""
	oWS1:OWSAJUSTDEBT:OWSRETENCIONES:OWSRETENCIONAJUSTE[1]:CNROCERTIFICADORETENCION := ""
	oWS1:OWSAJUSTDEBT:OWSRETENCIONES:OWSRETENCIONAJUSTE[1]:CFECHACERTIFICADORETENCION := ""
	oWS1:OWSAJUSTDEBT:OWSRETENCIONES:OWSRETENCIONAJUSTE[1]:CIMPORTECERTIFICADORETENCION := ""
	
	oWS1:CNROLIQUID := NJC->NJC_CODLIQ
		
	aadd(aRetNotas,aNotas)
		
	oWSAP:=	oWs1
	If oWSAP:AJUSTLIQUIDACIONLPEG() //Executa o Metodo de Ajuste Primario
		cMonitor := oWSAP:oWSAJUSTLIQUIDACIONLPEGRESULT:oWSID:CSTRING[1]
		
		RecLock("NJC",.F.) 
 			If lAutAfip
				NJC->NJC_FLLPEG := "1"
			Else
				NJC->NJC_FLLPEG := "3"
 			Endif
 			NJC->NJC_NRAFIP := Alltrim(NJC->NJC_PTOEMISION) + cValToChar(nNumAfip)
 		NJC->(MsUnlock())
		
 		If lCert
 			(cTmpCert)->(dbCloseArea())
 		Endif
 		//consulta retorno da afip
 		oWsMonit := WSWSLPEG():New()
 		oWsMonit:cUserToken := "TOTVS"
 		oWsMonit:cID_ENT    := cIdEnt
 		oWsMonit:_URL       := AllTrim(cURL)+"/WSLPEG.apw"
 		oWsMonit:cIdInicial    := cMonitor + "2"
		oWsMonit:cIdFinal      := cMonitor + "2"
		
		While lRetorno .and. nVezes <= 5
			sleep(5000)
			If oWsMonit:MONITORLPEG()                                                                 
				oRetMonitor :=  oWsMonit:OWSMONITORLPEGRESULT:OWSRESPONSEWSLPG
				lRetorno := .F.
			Endif
			nVezes++
    	EndDo
    	
    	If Valtype(oRetMonitor) <> "U"  
			IF Valtype(oRetMonitor[1]:OWSRESERROR:OWSERRORARRAY[1]:CCODIGO) <> "U" .And.  oRetMonitor[1]:OWSRESERROR:OWSERRORARRAY[1]:CCODIGO == "1508"

				oWSConsOrd:= WSWSLPEG():New()
				oWSConsOrd:cUserToken := "TOTVS"
				oWSConsOrd:cID_ENT    := cIdEnt
				oWSConsOrd:_URL       := AllTrim(cURL)+"/WSLPEG.apw"
				oWSConsOrd:CPTOEMISION := Alltrim(NJC->NJC_PTOEMI)
				oWSConsOrd:CNROORDEN := cValToChar(nNumAfip)
				oWSConsOrd:CNROLIQUID := NJC->NJC_CODLIQ
				
				If oWSConsOrd:LIQUIDXNROORDCONS()
					If !Empty(oWSConsOrd:OWSLIQUIDXNROORDCONSRESULT:CCOEAJUSTADO) .And. oWSConsOrd:OWSLIQUIDXNROORDCONSRESULT:CESTADO == "AC"
					
						RecLock("NJC",.F.) 
							NJC->NJC_FLLPEG := "1"
							NJC->NJC_STATUS := "3"
							NJC->NJC_COMPRO := ""
							NJC->NJC_NRAFIP := cValToChar(nNumAfip)
							NJC->NJC_STAFIP := IIf(oWSConsOrd:OWSLIQUIDXNROORDCONSRESULT:CESTADO == "AC","1","2") //opcçoes 1=Ativo;2=Anulado
							NJC->NJC_COEAJU := oWSConsOrd:OWSLIQUIDXNROORDCONSRESULT:CCOEAJUSTADO
							NJC->NJC_DTTRAN := CTOD(oWSConsOrd:OWSLIQUIDXNROORDCONSRESULT:CDATALIQ) //Data Transmissao Afip
						NJC->(MsUnlock())
					Endif
				Endif
				FIS828GRVFIN(oWSConsOrd:OWSLIQUIDXNROORDCONSRESULT:CCOEAJUSTADO)
			ElseIf (Valtype(oRetMonitor[1]:CRESULTADO) <> "U" .And. oRetMonitor[1]:CRESULTADO == "A")
				RecLock("NJC",.F.) 
					NJC->NJC_FLLPEG := "1"
					NJC->NJC_STATUS := "3"
					NJC->NJC_COMPRO := ""
					NJC->NJC_NRAFIP := Alltrim(oRetMonitor[1]:CNRAFIP)
					NJC->NJC_STAFIP := IIf(oRetMonitor[1]:CESTADO == "AC","1","2") //opcçoes 1=Ativo;2=Anulado
					NJC->NJC_COEAJU := oRetMonitor[1]:CCOEAJUSTADO
					NJC->NJC_DTTRAN := dDatabase //Data Transmissao Afip
				NJC->(MsUnlock())
				FIS828GRVFIN(oRetMonitor[1]:CCOEAJUSTADO)
			EndIF
    	Endif

	Else
		
		If lAutAfip
			RecLock("NJC",.F.) 
				NJC->NJC_FLLPEG := "1"
				cCoe := cValToChar(Randomize( 100000000, 999999999 ))
				NJC->NJC_COMPRO := cCoe
				NJC->NJC_NRAFIP := NJC->NJC_CODLIQ
				NJC->NJC_STATUS := "AC"
			NJC->(MsUnlock())
			FIS828GRVFIN(cCoe)
		Else
			cErro := GetWscError(3)
			DEFAULT cErro := STR0047 //"Erro indeterminado"
			lRetorno := .F.
		Endif
	Endif
	
ElseIf (cModeloWS $"8" .And. cTipo == "2" .And. cTipoLiq $ "2") //Ajuste Secundario
		
	oWs1 := WSWSLPEG():New()
	oWs1:cUserToken := "TOTVS"
	oWs1:cID_ENT    := cIdEnt
	oWS1:_URL       := AllTrim(cURL)+"/WSLPEG.apw"
	oWs1:CCOE :=  NJC->NJC_COMPRO
	oWs1:CPTOEMISION := Alltrim(NJC->NJC_PTOEMI)
	oWs1:CNROORDEN :=  IIf(lAutAfip,NJC->NJC_CODLIQ,cValToChar(nNumAfip))
	oWs1:CCODLOCALIDAD := NJC->NJC_PROPRO
	oWs1:CCODPROVINCIA := RetCodPro(NJC->NJC_PROVEN)
	
	
	//Dados Ajuste Credito Secundario
	
	aCrdPercep := ImpDebCred(NJC->NJC_CODLIQ,"Credito")
	If Len(aCrdPercep) > 0
		
		If aCrdPercep[1][3] > 0
			oWs1:oWSAJUSTECREDITSEC:CCONCEPTOIVA0 := "IVA 0"
			oWs1:oWSAJUSTECREDITSEC:CIMPORTEAJUSTAR0  := cValToChar(aCrdPercep[1][3]) //verificar com paulo de onde vira esse valor
		Else
			oWs1:oWSAJUSTECREDITSEC:CCONCEPTOIVA0 := ""
			oWs1:oWSAJUSTECREDITSEC:CIMPORTEAJUSTAR0  := "" 
		Endif
		
		If aCrdPercep[1][4] > 0
			oWs1:oWSAJUSTECREDITSEC:CCONCEPTOIVA10    := "IVA 10.5"
			oWs1:oWSAJUSTECREDITSEC:CIMPORTEAJUSTAR10 :=  cValToChar(aCrdPercep[1][4]) //verificar com paulo de onde vira esse valor
		Else
			oWs1:oWSAJUSTECREDITSEC:CCONCEPTOIVA10    := ""
			oWs1:oWSAJUSTECREDITSEC:CIMPORTEAJUSTAR10 := ""
		Endif
		
		If aCrdPercep[1][5]
			oWs1:oWSAJUSTECREDITSEC:CCONCEPTOIVA21    := "IVA 21"
			oWs1:oWSAJUSTECREDITSEC:CIMPORTEAJUSTAR21 := cValToChar(aCrdPercep[1][5]) //verificar com paulo de onde vira esse valor
		Else
			oWs1:oWSAJUSTECREDITSEC:CCONCEPTOIVA21 := ""
			oWs1:oWSAJUSTECREDITSEC:CIMPORTEAJUSTAR21 := ""
		Endif
	Else
		oWs1:oWSAJUSTECREDITSEC:CCONCEPTOIVA0     := ""
		oWs1:oWSAJUSTECREDITSEC:CIMPORTEAJUSTAR0  := "" //verificar com paulo de onde vira esse valor
		oWs1:oWSAJUSTECREDITSEC:CCONCEPTOIVA10    := ""
		oWs1:oWSAJUSTECREDITSEC:CIMPORTEAJUSTAR10 := "" //verificar com paulo de onde vira esse valor
		oWs1:oWSAJUSTECREDITSEC:CCONCEPTOIVA21    := ""
		oWs1:oWSAJUSTECREDITSEC:CIMPORTEAJUSTAR21 := "" //verificar com paulo de onde vira esse valor
	Endif
		
	//Dados Percepicion
	oWs1:oWSAJUSTECREDITSEC:oWSPERCEPSEC := WSLPEG_ARRAYOFPERCEPCIONSEC():New()
	If Len(aCrdPercep) > 0
		nOpDed := 0
		For nOpDed := 1 To Len(aCrdPercep )
			AADD(oWs1:oWSAJUSTECREDITSEC:oWSPERCEPSEC:oWSPERCEPCIONSEC, WSLPEG_PERCEPCIONSEC ():New() )
			oWs1:oWSAJUSTECREDITSEC:oWSPERCEPSEC:oWSPERCEPCIONSEC[nOpDed]:CDETALLEACLARATORIA := "PERCEPCION" + " " + cValToChar(nOpDed)
			oWs1:oWSAJUSTECREDITSEC:oWSPERCEPSEC:oWSPERCEPCIONSEC[nOpDed]:CBASECALCULO := cValtoChar(aCrdPercep[nOpDed][2])
			oWs1:oWSAJUSTECREDITSEC:oWSPERCEPSEC:oWSPERCEPCIONSEC[nOpDed]:CALICUOTA := cValtoChar(aCrdPercep[nOpDed][1])
		Next nOpDed ++
	Else
		AADD(oWs1:oWSAJUSTECREDITSEC:oWSPERCEPSEC:oWSPERCEPCIONSEC, WSLPEG_PERCEPCIONSEC ():New() )
		oWs1:oWSAJUSTECREDITSEC:oWSPERCEPSEC:oWSPERCEPCIONSEC[1]:CDETALLEACLARATORIA := ""
		oWs1:oWSAJUSTECREDITSEC:oWSPERCEPSEC:oWSPERCEPCIONSEC[1]:CBASECALCULO := ""
		oWs1:oWSAJUSTECREDITSEC:oWSPERCEPSEC:oWSPERCEPCIONSEC[1]:CALICUOTA := ""
	Endif	

	oWs1:oWSAJUSTECREDITSEC:CDATOSADICIONALES := ""
	
	//Dados Ajuste Debito Secundario
	aDebPercep := ImpDebCred(NJC->NJC_CODLIQ,"Debito")
	If Len(aDebPercep) > 0 
		If aDebPercep[1][3] > 0
			oWs1:oWSAJUSTEDEBITSEC:CCONCEPTOIVA0 := "IVA 0"
			oWs1:oWSAJUSTEDEBITSEC:CIMPORTEAJUSTAR0 := cValToChar(aDebPercep[1][3]) //verificar com paulo de onde vira esse valor
		Else
			oWs1:oWSAJUSTEDEBITSEC:CCONCEPTOIVA0 := ""
			oWs1:oWSAJUSTEDEBITSEC:CIMPORTEAJUSTAR0 := ""
		Endif
		
		If aDebPercep[1][4] > 0
			oWs1:oWSAJUSTEDEBITSEC:CCONCEPTOIVA10 := "IVA 10"
			oWs1:oWSAJUSTEDEBITSEC:CIMPORTEAJUSTAR10 := cValToChar(aDebPercep[1][4]) //verificar com paulo de onde vira esse valor
		Else
			oWs1:oWSAJUSTEDEBITSEC:CCONCEPTOIVA10 := ""
			oWs1:oWSAJUSTEDEBITSEC:CIMPORTEAJUSTAR10 := ""
		Endif
		
		If aDebPercep[1][5] > 0
			oWs1:oWSAJUSTEDEBITSEC:CCONCEPTOIVA21 := "IVA 21"
			oWs1:oWSAJUSTEDEBITSEC:CIMPORTEAJUSTAR21 := cValToChar(aDebPercep[1][5])
		Else
			oWs1:oWSAJUSTEDEBITSEC:CCONCEPTOIVA21 := ""
			oWs1:oWSAJUSTEDEBITSEC:CIMPORTEAJUSTAR21 := ""
		Endif
	Else
		oWs1:oWSAJUSTEDEBITSEC:CCONCEPTOIVA0     := ""
		oWs1:oWSAJUSTEDEBITSEC:CIMPORTEAJUSTAR0  := "" 
		oWs1:oWSAJUSTEDEBITSEC:CCONCEPTOIVA10    := ""
		oWs1:oWSAJUSTEDEBITSEC:CIMPORTEAJUSTAR10 := "" 
		oWs1:oWSAJUSTEDEBITSEC:CCONCEPTOIVA21    := ""
		oWs1:oWSAJUSTEDEBITSEC:CIMPORTEAJUSTAR21 := "" 
	Endif				
	
	//Dados Percepicion
	oWs1:oWSAJUSTEDEBITSEC:oWSPERCEPSEC := WSLPEG_ARRAYOFPERCEPCIONSEC():New()
	If Len(aDebPercep) > 0
		nOpDed := 0
		For nOpDed := 1 To Len(aDebPercep )
			AADD(oWs1:oWSAJUSTEDEBITSEC:oWSPERCEPSEC:OWSPERCEPCIONSEC, WSLPEG_PERCEPCIONSEC ():New() )
			oWs1:oWSAJUSTEDEBITSEC:oWSPERCEPSEC:OWSPERCEPCIONSEC[nOpDed]:CDETALLEACLARATORIA := "PERCEPCION" + " " + cValToChar(nOpDed)
			oWs1:oWSAJUSTEDEBITSEC:oWSPERCEPSEC:OWSPERCEPCIONSEC[nOpDed]:CBASECALCULO := cValtoChar(aDebPercep[nOpDed][2])
			oWs1:oWSAJUSTEDEBITSEC:oWSPERCEPSEC:OWSPERCEPCIONSEC[nOpDed]:CALICUOTA := cValtoChar(aDebPercep[nOpDed][1])
		Next nOpDed ++
	Else
		AADD(oWs1:oWSAJUSTEDEBITSEC:oWSPERCEPSEC:OWSPERCEPCIONSEC, WSLPEG_PERCEPCIONSEC ():New() )
		oWs1:oWSAJUSTEDEBITSEC:oWSPERCEPSEC:OWSPERCEPCIONSEC[1]:CDETALLEACLARATORIA := ""
		oWs1:oWSAJUSTEDEBITSEC:oWSPERCEPSEC:OWSPERCEPCIONSEC[1]:CBASECALCULO := "" 
		oWs1:oWSAJUSTEDEBITSEC:oWSPERCEPSEC:OWSPERCEPCIONSEC[1]:CALICUOTA := ""
	Endif	
	
	oWs1:oWSAJUSTEDEBITSEC:CDATOSADICIONALES := ""
	
	oWs1:oWSFUSIONSEC:CNROINGBRUTOS := ""
	oWs1:oWSFUSIONSEC:CNROACTIVIDAD := ""
	
	oWS1:CNROLIQUID := NJC->NJC_CODLIQ
		
	aadd(aRetNotas,aNotas)
		
	oWSAS:=	oWs1
	
	If oWSAS:AJUSTLIQUIDSECLPEG() //Executa o Metodo de Ajuste Secundario
		cMonitor := oWSAS:oWSAJUSTLIQUIDSECLPEGRESULT:oWSID:CSTRING[1]
			
		RecLock("NJC",.F.) 
 			If lAutAfip
				NJC->NJC_FLLPEG := "1"
			Else
				NJC->NJC_FLLPEG := "3"
 			Endif
 			NJC->NJC_COEAJU := "" // Informar o COE depois de autorizar
 			NJC->NJC_NRAFIP := cValToChar(nNumAfip)
 		NJC->(MsUnlock())

 		//consulta retorno da afip
 		oWsMonit := WSWSLPEG():New()
 		oWsMonit:cUserToken := "TOTVS"
 		oWsMonit:cID_ENT    := cIdEnt
 		oWsMonit:_URL       := AllTrim(cURL)+"/WSLPEG.apw"
 		oWsMonit:cIdInicial    := cMonitor + "4"
		oWsMonit:cIdFinal      := cMonitor + "4"
		
		While lRetorno .and. nVezes <= 5
			sleep(5000)
			If oWsMonit:MONITORLPEG()                                                                 
				oRetMonitor :=  oWsMonit:OWSMONITORLPEGRESULT:OWSRESPONSEWSLPG
				lRetorno := .F.
			Endif
			nVezes++
    	EndDo
		IF Valtype(oRetMonitor) <> "U" 
    	
			If Valtype(oRetMonitor[1]:OWSRESERROR:OWSERRORARRAY[1]:CCODIGO) <> "U" .And.  oRetMonitor[1]:OWSRESERROR:OWSERRORARRAY[1]:CCODIGO == "1508"

				oWSConsOrd:= WSWSLPEG():New()
				oWSConsOrd:cUserToken := "TOTVS"
				oWSConsOrd:cID_ENT    := cIdEnt
				oWSConsOrd:_URL       := AllTrim(cURL)+"/WSLPEG.apw"
				oWSConsOrd:CPTOEMISION := Alltrim(NJC->NJC_PTOEMI)
				oWSConsOrd:CNROORDEN := cValToChar(nNumAfip)
				oWSConsOrd:CNROLIQUID := NJC->NJC_CODLIQ
				
				If oWSConsOrd:LIQUIDXNROORDCONS()
					If !Empty(oWSConsOrd:OWSLIQUIDXNROORDCONSRESULT:CCOEAJUSTADO) .And. oWSConsOrd:OWSLIQUIDXNROORDCONSRESULT:CESTADO == "AC"
					
						RecLock("NJC",.F.) 
							NJC->NJC_FLLPEG := "1"
							NJC->NJC_STATUS := "3"
							NJC->NJC_COMPRO := ""
							NJC->NJC_NRAFIP := cValToChar(nNumAfip)
							NJC->NJC_STAFIP := IIf(oWSConsOrd:OWSLIQUIDXNROORDCONSRESULT:CESTADO == "AC","1","2") //opcçoes 1=Ativo;2=Anulado
							NJC->NJC_COEAJU := oWSConsOrd:OWSLIQUIDXNROORDCONSRESULT:CCOEAJUSTADO
							NJC->NJC_DTTRAN := CTOD(oWSConsOrd:OWSLIQUIDXNROORDCONSRESULT:CDATALIQ) //Data Transmissao Afip
						NJC->(MsUnlock())
					Endif
					FIS828GRVFIN(oWSConsOrd:OWSLIQUIDXNROORDCONSRESULT:CCOEAJUSTADO)
				Endif
				
			ElseIf (Valtype(oRetMonitor[1]:CRESULTADO) <> "U" .And. oRetMonitor[1]:CRESULTADO == "A")
				RecLock("NJC",.F.) 
					NJC->NJC_FLLPEG := "1"
					NJC->NJC_STATUS := "3"
					NJC->NJC_COMPRO := ""
					NJC->NJC_NRAFIP := Alltrim(oRetMonitor[1]:CNRAFIP)
					NJC->NJC_STAFIP := IIf(oRetMonitor[1]:CESTADO == "AC","1","2") //opcçoes 1=Ativo;2=Anulado
					NJC->NJC_COEAJU := oRetMonitor[1]:CCOEAJUSTADO
					NJC->NJC_DTTRAN := dDatabase //Data Transmissao Afip
				NJC->(MsUnlock())
				FIS828GRVFIN(oRetMonitor[1]:CCOEAJUSTADO)
			Endif
		EndIF
	Else
		If lAutAfip
			RecLock("NJC",.F.) 
				NJC->NJC_FLLPEG := "1"
				cCoe := cValToChar(Randomize( 100000000, 999999999 ))
				NJC->NJC_COEAJU := cCoe
				NJC->NJC_NRAFIP := NJC->NJC_CODLIQ
				NJC->NJC_STATUS := "AC"
			NJC->(MsUnlock())
			FIS828GRVFIN(cCoe)
		Else	
			cErro := GetWscError(3)
			DEFAULT cErro := STR0047 //"Erro indeterminado"
			lRetorno := .F.
		Endif
	Endif
		
EndIf

aadd(aArgRetLPG,{aRetNotas,lRetorno})

Return(aArgRetLPG)
