#INCLUDE "PROTHEUS.CH"                                                                                      
#INCLUDE "COLORS.CH"                                                                                                               
#INCLUDE "TBICONN.CH"           

#DEFINE ANULADO			7
                                                                              
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA085XML
RDMAKE De Exemplo do XML de geracao do Resguardo Eletronico do Uruguai
Coleta dados do resguardo e armazena nos arrays auxiliares

@author  Fernando Bastos
@version P10
@since 	 08/01/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
User Function FISA085XML(cNumRes,cSerRes,cTipoRes,cForRes,cLojares,cDataRes)    
	            
	Local nX       := 0
	Local aXmlRes  := {}
	Local aResg    := {}
	Local aDest    := {}
	Local aProd    := {}
	Local aReg	   := {}
	Local aCabRes  := {}
	Local cStatus  := ""
	
	Default cNumRes  := PARAMIXB[1] 
	Default cSerRes  := PARAMIXB[2]
	Default cTipoRes := PARAMIXB[3]
	Default cForRes  := PARAMIXB[4]
	Default cLojares := PARAMIXB[5]
	Default cDataRes := PARAMIXB[6]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³      Monta o array de cabecalho do Resguardo      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("CLE")
	CLE->(dbSetOrder(1))
	If CLE->(dbSeek(xFilial("CLE")+cTipoRes+cSerRes+cNumRes))
	
		aadd(aReg,CLE->CLE_TPRESG)		//1
		aadd(aReg,CLE->CLE_SERIER)		//2
		aadd(aReg,CLE->CLE_NUMREG)		//3
		aadd(aReg,CLE->CLE_FORNEC)		//4
		aadd(aReg,CLE->CLE_LOJA)  		//5
		aadd(aReg,CLE->CLE_DTRESG)		//6
		aadd(aReg,CLE->CLE_MDDOC) 		//7
		aadd(aReg,CLE->CLE_TOTRET)      //8 
		aadd(aReg,CLE->CLE_OBS)   		//9 
		aadd(aReg,CLE->CLE_DTTRAN)		//10
		aadd(aReg,CLE->CLE_HRTRAN)		//11
		aadd(aReg,CLE->CLE_PROT)  		//12
		//aadd(aReg,CLE->CLE_STATUS)		//13
		aadd(aReg,CLE->CLE_IMP)			//13 - 14
		aadd(aReg,CLE->CLE_VALIMP)		//14 - 15
		//Campos implementação antiga
		//aadd(aReg,CLE->CLE_CODIRN)		//14
		//aadd(aReg,CLE->CLE_VALIRN)		//15
		//aadd(aReg,CLE->CLE_CODIRP)		//16
		//aadd(aReg,CLE->CLE_VALIRP)		//17
		//aadd(aReg,CLE->CLE_CODIVA)		//18
		//aadd(aReg,CLE->CLE_VALIVA)		//19
		//aadd(aReg,CLE->CLE_CODIRA)     	//20
		//aadd(aReg,CLE->CLE_VALIRA)		//21
			
		//Define a moeda	
		dbSelectArea("SYF")
		SYF->(dbSetOrder(1))
		cMoeda:='GetMV("MV_SIMB'+Alltrim(str(CLE->CLE_MDDOC))+'")'
		If(SYF->(dbseek(xFilial("SYF")+&cMoeda)))
			aadd(aReg,SYF->YF_MOEDA)   //15 - 22 
		Else
			aadd(aReg,"UYU")   		   //15 - 22
		EndIf
		aadd(aReg,CLE->CLE_STATUS)		//16 - 23
		aadd(aReg,CLE->CLE_SERCAE)		//17 - 24
		aadd(aReg,CLE->CLE_CAE)			//18 - 25

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³      Monta o array de itens do Resguardo      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("CLF")
		CLF->(dbSetOrder(1))
		If CLF->(dbSeek(xFilial("CLE")+cTipoRes+cSerRes+cNumRes))
		
			While !Eof() .And. CLF->CLF_NUMREG == cNumRes
			    aadd(aResg,	{Len(aResg)+1,;	  					   
						CLF->CLF_TPRESG,;    		//2
						CLF->CLF_SERIER,; 			//3
						CLF->CLF_NUMREG,; 			//4
						CLF->CLF_ESPECI,; 			//5
						CLF->CLF_SERIE,; 				//6
						CLF->CLF_NUM,; 				//7
						CLF->CLF_FORNEC,;           //8
						CLF->CLF_LOJA,; 				//9
						CLF->CLF_DTEMDC,; 			//10
						CLF->CLF_BASIM,; 				//11
						CLF->CLF_ALQIM,; 				//12
						CLF->CLF_VALIM,;				//13
						CLF->CLF_CODDGI}) 			//14										
						//Campos antiga implementação
						//CLF->CLF_BSEXIR,; 			//11
						//CLF->CLF_VLBSIR,; 			//12				
						//CLF->CLF_ALQIR,; 			//13
						//CLF->CLF_VALIR,;			//14
						//CLF->CLF_CODIRP,;			//15
						//CLF->CLF_BSEXIE,; 			//16				
						//CLF->CLF_VLBSIE,; 			//17				
						//CLF->CLF_ALQIE,; 			//18				
						//CLF->CLF_VALIE,; 			//19
						//CLF->CLF_CODIRA,;			//20
						//CLF->CLF_BSEXIN,; 			//21
						//CLF->CLF_VLBSIN,; 			//22				
						//CLF->CLF_ALQIN,; 			//23				
						//CLF->CLF_VALIN,; 			//24
						//CLF->CLF_CODIRN,;			//25
						//CLF->CLF_BSEXIV,; 			//26
						//CLF->CLF_VLBSIV,; 			//27
						//CLF->CLF_ALQIV,; 			//28			
						//CLF->CLF_VALIV,; 		   	//29
						//CLF->CLF_CODIVA})			//30	    
				CLF->(dbSkip())
			EndDo
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³      Monta o array de destinatarios do Resguardo      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SA2")
		dbSetOrder(1)
		DbGoTop()
		If DbSeek(xFilial("SA2")+aReg[4]+aReg[5])
			aadd(aDest,SA2->A2_PAIS)   
			aadd(aDest,AllTrim(SA2->A2_CGC))
			aadd(aDest,Alltrim(SA2->A2_NOME)) 
			aadd(aDest,MyGetEnd(SA2->A2_END,"SA2")[1])
			aadd(aDest,AllTrim(SA2->A2_MUN))
			aadd(aDest,AllTrim(SA2->A2_ESTADO))						
			aadd(aDest,AllTrim(SA2->A2_TIPO))
		else
			aDest := {"","","","","","",""}			
		Endif 
		
		//Monta a mensagem XML a partir dos dados coletados nos arrays
		If !Empty(aResg)
			aXmlRes := GeraXML(aResg,aDest,aProd,aReg)
		EndIf
		
Endif

Return(aXmlRes)   

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GeraXML
RDMAKE De Exemplo do XML de geracao do Resguardo Eletronico do Uruguai a partir dos arrays
recebidos como parametro

@author  Fernando Bastos
@version P10
@since 	 08/01/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Static Function GeraXML(aResg,aDest,aProd,aReg)

	Local cString 		:= ""
	Local cTipoCli	 	:= IIf(!Empty(Alltrim(aDest[7])),Alltrim(aDest[7]),"")
	Local cData			:= ""
	Local cSucursal  	:= GETMV("MV_URUSUCU") // Código registrado na DGI, associado ao RUC emissor
	Local cValMoeda	 	:= GETMV("MV_VALMOIU") // Parametro com a informação de onde esta cadastrado a Moeda UI
		
	Local nNun			:= 0
	Local nX			:= 0
	Local nTotMed		:= 0
	
	Local aXmlRes 		:= {}
	
	Default aResg  		:= {}
	Default aDest  		:= {}
	Default aProd  		:= {}
	Default aReg  		:= {}
	
	cData := FsDateConv(Date(),"YYYYMMDD")
	cData := SubStr(cData,1,4)+"-"+SubStr(cData,5,2)+"-"+SubStr(cData,7)+"T"+Time()+"-03:00"  
	cString += '<?xml version="1.0" encoding="UTF-8"?><ns0:CFE_Adenda xmlns:ns0="http://cfe.dgi.gub.uy" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://cfe.dgi.gub.uy CFEEmpresas_v1.15.xsd">'
	cString += '<ns0:CFE version="1.0" xmlns:ns0="http://cfe.dgi.gub.uy">'
	cString += '<ns0:eResg>'
	cString += "<ns0:TmstFirma>"+cData+"</ns0:TmstFirma>"
	cString += "<ns0:Encabezado>"	    
	cString += "<ns0:IdDoc>"
	cString += "<ns0:TipoCFE>"+RetTpCbte(aReg[1])+"</ns0:TipoCFE>"
	cString += "<ns0:Serie>"+Alltrim(aReg[2])+"</ns0:Serie>"
	cString += "<ns0:Nro>"+aReg[3]+"</ns0:Nro>"
	cString += "<ns0:FchEmis>"+StrZero(Year(STOD(DTOS(aReg[6]))),4)+"-"+StrZero(Month(STOD(DTOS(aReg[6]))),2)+"-"+StrZero(Day(STOD(DTOS(aReg[6]))),2)+"</ns0:FchEmis>"
	cString += "</ns0:IdDoc>"
	cString += "<ns0:Emisor>"
	cString += "<ns0:RUCEmisor>"+Alltrim(SM0->M0_CGC)+"</ns0:RUCEmisor>"
	cString += "<ns0:RznSoc>"+Convtype(Alltrim(SM0->M0_NOMECOM))+"</ns0:RznSoc>"
	cString += "<ns0:NomComercial>"+Convtype(Alltrim(SM0->M0_NOMECOM))+"</ns0:NomComercial>"
	cString += "<ns0:CdgDGISucur>"+IIF(!Empty(cSucursal),cSucursal,Convtype(Alltrim(Strtran(SM0->M0_CODFIL,"0"))))+"</ns0:CdgDGISucur>"
	cString += "<ns0:DomFiscal>"+Convtype(Alltrim(SM0->M0_ENDENT))+"</ns0:DomFiscal>"
	cString += "<ns0:Ciudad>"+Convtype(Alltrim(SM0->M0_CIDENT))+"</ns0:Ciudad>"
	cString += "<ns0:Departamento>"+Convtype(RetProvin(Alltrim(SM0->M0_ESTENT)))+"</ns0:Departamento>"
	cString += "</ns0:Emisor>"	        
	cString += "<ns0:Receptor>"
	IF !Empty(aDest[7]) 
		cString+="<ns0:TipoDocRecep>"+IIF(Alltrim(aDest[7])=="1","2","3")+"</ns0:TipoDocRecep>" 
	Else 
		cString+="<ns0:TipoDocRecep>2</ns0:TipoDocRecep>" 
	Endif
	cString+="<ns0:CodPaisRecep>"+RetCodPais(aDest[1])+"</ns0:CodPaisRecep>"
	cString+="<ns0:DocRecep>"+aDest[2]+"</ns0:DocRecep>"
	cString+="<ns0:RznSocRecep>"+Convtype(aDest[3])+"</ns0:RznSocRecep>"
	cString+="<ns0:DirRecep>"+Convtype(aDest[4])+"</ns0:DirRecep>"
	cString+="<ns0:CiudadRecep>"+Convtype(aDest[5])+"</ns0:CiudadRecep>"
	cString+="<ns0:DeptoRecep>"+Convtype(aDest[6])+"</ns0:DeptoRecep>"
	cString += "</ns0:Receptor>"
	cString += "<ns0:Totales>"
	cString += "<ns0:TpoMoneda>"+aReg[15]+"</ns0:TpoMoneda>"	          
	If Alltrim(aReg[15]) <> "UYU"
		dbSelectArea("SM2")                  			
		SM2->(dbSetOrder(1))
		If SM2->(dbSeek(aReg[9])) //Data
			nTxMoeda := &("SM2->M2_MOEDA"+CVALTOCHAR(aReg[10])) 	
			cString+="<ns0:TpoCambio>"+Alltrim (Transform(nTxMoeda,"@! 9999.999"))+"</ns0:TpoCambio>"			     
		Endif
		SM2->(dbCloseArea())
	Else 		 
		cString += "<ns0:TpoCambio>1</ns0:TpoCambio>"   
	  	dbCloseArea()
	EndIf	          
	cString += "<ns0:MntTotRetenido>"+CVALTOCHAR(aReg[8])+"</ns0:MntTotRetenido>"
	cString += "<ns0:CantLinDet>1</ns0:CantLinDet>"
	//cString += "<ns0:CantLinDet>"+CVALTOCHAR(TotImp(aReg))+"</ns0:CantLinDet>"
	
	//Nova implementtação - Somente um imposto por resguardo.
	cString += "<ns0:RetencPercep>"
	cString += "<ns0:CodRet>"+CVALTOCHAR(aReg[13])+"</ns0:CodRet>"
	cString += "<ns0:ValRetPerc>"+CVALTOCHAR(aReg[14])+"</ns0:ValRetPerc>"
	cString += "</ns0:RetencPercep>"
	
	/*
	If !Empty(aReg[14]) .and. !Empty(aReg[15]) // Codigo e valor de retencao do IRN
		cString += "<ns0:RetencPercep>"
		cString += "<ns0:CodRet>"+CVALTOCHAR(aReg[14])+"</ns0:CodRet>"
		cString += "<ns0:ValRetPerc>"+CVALTOCHAR(aReg[15])+"</ns0:ValRetPerc>"
		cString += "</ns0:RetencPercep>"	          
	EndIf
    
	If !Empty(aReg[16]) .and. !Empty(aReg[17]) // Codigo e Valor de retencao do IRPF
		cString += "<ns0:RetencPercep>"
		cString += "<ns0:CodRet>"+CVALTOCHAR(aReg[16])+"</ns0:CodRet>"
		cString += "<ns0:ValRetPerc>"+CVALTOCHAR(aReg[17])+"</ns0:ValRetPerc>"
		cString += "</ns0:RetencPercep>"	          
	EndIf
    
	If !Empty(aReg[18]) .and. !Empty(aReg[19]) // Codigo e Valor  de retencao do IVA
		cString += "<ns0:RetencPercep>"
		cString += "<ns0:CodRet>"+CVALTOCHAR(aReg[18])+"</ns0:CodRet>"
		cString += "<ns0:ValRetPerc>"+CVALTOCHAR(aReg[19])+"</ns0:ValRetPerc>"
		cString += "</ns0:RetencPercep>"
	EndIf
    
	If !Empty(aReg[20]) .and. !Empty(aReg[21]) // Codigo e Valor de retencao do IRAE
		cString += "<ns0:RetencPercep>"
		cString += "<ns0:CodRet>"+CVALTOCHAR(aReg[20])+"</ns0:CodRet>"
		cString += "<ns0:ValRetPerc>"+CVALTOCHAR(aReg[21])+"</ns0:ValRetPerc>"
		cString += "</ns0:RetencPercep>"
	Endif	
	*/
	cString += "</ns0:Totales>"	    
	cString += "</ns0:Encabezado>"	       
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³     Bloco de Itens (Notas)     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cString += "<ns0:Detalle>"		      	          
	For nX = 1 To Len(aResg)
		
		
		nNun++
		cString += "<ns0:Item>"
		cString += "<ns0:NroLinDet>"+CVALTOCHAR(nNun)+"</ns0:NroLinDet>"                     		
		cString += "<ns0:IndFact>9</ns0:IndFact>"
		cString += "<ns0:RetencPercep>"
		cString += "<ns0:CodRet>"+CVALTOCHAR(aResg[nX][14])+"</ns0:CodRet>"
		cString += "<ns0:Tasa>"+CVALTOCHAR(aResg[nX][12])+"</ns0:Tasa>"
		cString += "<ns0:MntSujetoaRet>"+CVALTOCHAR(aResg[nX][11])+"</ns0:MntSujetoaRet>"
		cString += "<ns0:ValRetPerc>"+CVALTOCHAR(aResg[nX][13])+"</ns0:ValRetPerc>"
		cString += "</ns0:RetencPercep>"
		cString += "</ns0:Item>"	
		
		/*
		If !Empty(aResg[nX][15]) .and. !Empty(aResg[nX][14]) //Codigo e Valor de retencao do IRPF	
			nNun++
			cString += "<ns0:Item>"
			cString += "<ns0:NroLinDet>"+CVALTOCHAR(nNun)+"</ns0:NroLinDet>"                     		
			cString += "<ns0:IndFact>9</ns0:IndFact>"
			cString += "<ns0:RetencPercep>"
			cString += "<ns0:CodRet>"+CVALTOCHAR(aResg[nX][15])+"</ns0:CodRet>"
			cString += "<ns0:Tasa>"+CVALTOCHAR(aResg[nX][13])+"</ns0:Tasa>"
			cString += "<ns0:MntSujetoaRet>"+CVALTOCHAR(aResg[nX][12])+"</ns0:MntSujetoaRet>"
			cString += "<ns0:ValRetPerc>"+CVALTOCHAR(aResg[nX][14])+"</ns0:ValRetPerc>"
			cString += "</ns0:RetencPercep>"
			cString += "</ns0:Item>"	
		Endif
        
        If !Empty(aResg[nX][20]) .and. !Empty(aResg[nX][19]) //Codigo e Valor de retencao do IRAE
			nNun++
			cString += "<ns0:Item>"
			cString += "<ns0:NroLinDet>"+CVALTOCHAR(nNun)+"</ns0:NroLinDet>"
			cString += "<ns0:IndFact>9</ns0:IndFact>"
			cString += "<ns0:RetencPercep>"
			cString += "<ns0:CodRet>"+CVALTOCHAR(aResg[nX][20])+"</ns0:CodRet>"
			cString += "<ns0:Tasa>"+CVALTOCHAR(aResg[nX][18])+"</ns0:Tasa>"
			cString += "<ns0:MntSujetoaRet>"+CVALTOCHAR(aResg[nX][17])+"</ns0:MntSujetoaRet>"
			cString += "<ns0:ValRetPerc>"+CVALTOCHAR(aResg[nX][19])+"</ns0:ValRetPerc>"
			cString += "</ns0:RetencPercep>"
			cString += "</ns0:Item>"	
		EndiF
        
		If !Empty(aResg[nX][25]) .and. !Empty(aResg[nX][24]) //Codigo e Valor de Retencao do IRN
			nNun++
			cString += "<ns0:Item>"
			cString += "<ns0:NroLinDet>"+CVALTOCHAR(nNun)+"</ns0:NroLinDet>" 
			cString += "<ns0:IndFact>9</ns0:IndFact>"
			cString += "<ns0:RetencPercep>"
			cString += "<ns0:CodRet>"+CVALTOCHAR(aResg[nX][25])+"</ns0:CodRet>"
			cString += "<ns0:Tasa>"+CVALTOCHAR(aResg[nX][23])+"</ns0:Tasa>"
			cString += "<ns0:MntSujetoaRet>"+CVALTOCHAR(aResg[nX][22])+"</ns0:MntSujetoaRet>"
			cString += "<ns0:ValRetPerc>"+CVALTOCHAR(aResg[nX][24])+"</ns0:ValRetPerc>"
			cString += "</ns0:RetencPercep>"
			cString += "</ns0:Item>"	          	
		EndIf
        
		If !Empty(aResg[nX][30]) .and. !Empty(aResg[nX][29]) //Codigo e Valor de retencao do IVA
			nNun++
			cString += "<ns0:Item>"
			cString += "<ns0:NroLinDet>"+CVALTOCHAR(nNun)+"</ns0:NroLinDet>"
			cString += "<ns0:IndFact>9</ns0:IndFact>"
			cString += "<ns0:RetencPercep>"
			cString += "<ns0:CodRet>"+CVALTOCHAR(aResg[nX][30])+"</ns0:CodRet>"
			cString += "<ns0:Tasa>"+CVALTOCHAR(aResg[nX][28])+"</ns0:Tasa>"
			cString += "<ns0:MntSujetoaRet>"+CVALTOCHAR(aResg[nX][27])+"</ns0:MntSujetoaRet>"
			cString += "<ns0:ValRetPerc>"+CVALTOCHAR(aResg[nX][29])+"</ns0:ValRetPerc>"
			cString += "</ns0:RetencPercep>"
			cString += "</ns0:Item>"
		Endif 
		*/        
	Next nX
	nNun := 0	        
	cString += "</ns0:Detalle>"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³     Bloco de Anulacao (referencia)     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If len(aReg) > 16 .and. aReg[16] == ANULADO
		cString +="<ns0:Referencia>"
		cString +="<ns0:Referencia>"
		cString +="<ns0:NroLinRef>1</ns0:NroLinRef>"
		cString +="<ns0:IndGlobal>1</ns0:IndGlobal>"
		cString +="<ns0:Serie>"+ alltrim(aReg[17]) +"</ns0:Serie>"
		cString +="<ns0:NroCFERef>"+ alltrim(aReg[18]) +"</ns0:NroCFERef>"
		cString +="<ns0:RazonRef>Anulacion</ns0:RazonRef>"
		cString += "</ns0:Referencia>"
		cString += "</ns0:Referencia>"
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³     Bloco Final     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	cString += "<ns0:CAEData>"
	cString += "<ns0:CAE_ID>0</ns0:CAE_ID>"
	cString += "<ns0:DNro>1</ns0:DNro>"
	cString += "<ns0:HNro>100</ns0:HNro>"
	cString += "<ns0:FecVenc>2013-12-31</ns0:FecVenc>"
	cString += "</ns0:CAEData>"	    	
	cString += '</ns0:eResg>'
	cString +="</ns0:CFE>"  
	cString +="<ns0:Adenda>"
	cString +="<Rondanet>"
	cString +="<A01>"
	cString +="<Numerar>1</Numerar>"
	cString +="<Firmar>1</Firmar>"
	//cString +="</NroDocInterno>"	
	cString +="<NroDocInterno>"+aReg[3]+"</NroDocInterno>"	
	//cString +="</SerieDocInterna>"	
	cString +="<SerieDocInterna>"+aReg[2]+"</SerieDocInterna>"	
	cString +="</A01>"
	cString +="</Rondanet>"
	cString +="</ns0:Adenda>"
	cString +="</ns0:CFE_Adenda>" 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Controle TK menores - verifica se a nota convertida ³
	//³fica com o valor maior ou menos que 100000 de acordo³
	//³com a cotação da moeda                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aadd(aXmlRes,cString)
	dbSelectArea("SM2")
	SM2->(dbSetOrder(1))
    If SM2->(dbSeek(CLE->CLE_DTRESG))
		nTxMoeUI := &("SM2->M2_MOEDA"+CVALTOCHAR(cValMoeda))	
		nTotMed  := (aReg[14])
		nValCon  := nTotMed * nTxMoeUI
		aadd(aXmlRes,IIF(nValCon < 10000,.T.,.F.))
	Else
		aadd(aXmlRes,.F.)
	Endif   
	aadd(aXmlRes,RetTpCbte(aReg[1]))
	aadd(aXmlRes,aReg[2])
	aadd(aXmlRes,aReg[3])

Return (aXmlRes) 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MyGetEnd
 Verifica se o participante e do DF, ou se tem um tipo de endereco que nao se enquadra 
 na regra padrao de preenchimento de endereco 
 Por exemplo: Enderecos de Area Rural (essa verificção e feita atraves do campo ENDNOT)
          Caso seja do DF, ou ENDNOT = 'S', somente ira retornar o campo Endereco 
          (sem numero ou complemento). Caso contrario ira retornar o padrao do FisGetEnd 

@author  Fernando Bastos
@version P10
@since 	 08/01/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Static Function MyGetEnd(cEndereco,cAlias)

	Local cCmpEndN	:= SubStr(cAlias,2,2)+"_ENDNOT"
	Local cCmpEst	:= SubStr(cAlias,2,2)+"_EST"
	
	Local nIb		:=0
	Local nIv		:=0
	
	Local aRet		:= {"",0,"",""}   
	
	//Campo ENDNOT indica que endereco participante mao esta no formato <logradouro>, <numero> <complemento>
	//Se tiver com 'S' somente o campo de logradouro sera atualizado (numero sera SN)
	If (&(cAlias+"->"+cCmpEst) == "DF") .Or. ((cAlias)->(FieldPos(cCmpEndN)) > 0 .And. &(cAlias+"->"+cCmpEndN) == "1")
		aRet[1] := cEndereco
		aRet[3] := "SN"
	Else
		aRet := FisGetEnd(cEndereco)
	EndIf

Return aRet  

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RetTpCbte
 Retorna o tipo de comprovante

@author  Fernando Bastos
@version P10
@since 	 08/01/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Static Function RetTpCbte(cTipo) 

	Local cCbte   := ""
	Local lCont   := GETMV("MV_URUCONT")   //Parametro referente a Contingencia da nota do Uruguai 
	
	Default cTipo := "X"           
	         
	If !lCont
		if (Alltrim(cTipo) $ "VIG|HON|ALQ|X")  
				cCbte := "182"		
		Endif	
	Else
		if (Alltrim(cTipo) $ "VIG|HON|ALQ|X")  
				cCbte := "282"		
		Endif 
	Endif 

Return cCbte

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RetCodPais
Retorna o código de País

@author  Fernando Bastos
@version P10
@since 	 08/01/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Static Function RetCodPais(cPais)  

Local cCod 	  := ""
Local aArea := GetArea()
Default cPais := "845" //Uruguai
If SYA->(ColumnPos("YA_SGLLOC")) > 0	
	DbSelectArea("SYA")
	SYA->(dbSetOrder(1))
	If SYA->(dbSeek(xFilial("SYA")+cPais))
		cCod := SYA->YA_SGLLOC
	Endif	
	RestArea(aArea)
Else
	cCod := "UY"
EndIf

Return cCod


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ConvType
Converte tipos para elaboração de um XML

@author  Fernando Bastos
@version P10
@since 	 08/01/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Static Function ConvType(xValor,nTam,nDec)
	Local cNovo := ""
	DEFAULT nDec := 0
	Do Case
		Case ValType(xValor)=="N"
			If xValor <> 0
				cNovo := AllTrim(Str(xValor,nTam,nDec))
				cNovo := StrTran(cNovo,",",".")
			Else
				cNovo := "0"
			EndIf
		Case ValType(xValor)=="D"
			cNovo := FsDateConv(xValor,"YYYYMMDD")
			cNovo := SubStr(cNovo,1,4)+"-"+SubStr(cNovo,5,2)+"-"+SubStr(cNovo,7)   
		Case ValType(xValor)=="C"
			If nTam==Nil
				xValor := AllTrim(xValor)
			EndIf
			DEFAULT nTam := 100
			cNovo := AllTrim(EnCodeUtf8(NoAcento(SubStr(xValor,1,nTam)))) 
	EndCase
Return(cNovo)


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} NoAcento
Substitui caracteres acentuados para composicao de um XML em UTF-8
@author  Fernando Bastos
@version P10
@since 	 08/01/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Static Function NoAcento(cString)

	Local cChar  := ""
	Local cVogal := "aeiouAEIOU"
	Local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
	Local cCircu := "âêîôû"+"ÂÊÎÔÛ"
	Local cTrema := "äëïöü"+"ÄËÏÖÜ"
	Local cCrase := "àèìòù"+"ÀÈÌÒÙ" 
	Local cTio   := "ãõ"
	Local cCecid := "çÇ"
	Local cEComer:= "&"  
	Local nX     := 0 
	Local nY     := 0
	
	For nX:= 1 To Len(cString)
		cChar:=SubStr(cString, nX, 1)
		IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase+cEComer
			nY:= At(cChar,cAgudo)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cCircu)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cTrema)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cCrase)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf		
			nY:= At(cChar,cTio)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr("ao",nY,1))
			EndIf		
			nY:= At(cChar,cCecid)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr("cC",nY,1))
			EndIf
		 	nY:= At(cChar,cEComer)
		 	If nY > 0
				cString := StrTran(cString,cChar,SubStr("y",nY,1))
			EndIf
		Endif
	Next
	For nX:=1 To Len(cString)
		cChar:=SubStr(cString, nX, 1)
		If Asc(cChar) < 32 .Or. Asc(cChar) > 123 
			cString:=StrTran(cString,cChar,".")
		Endif
	Next nX
	cString := _NoTags(cString)
Return cString    

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TotImp
@author  Fernando Bastos
@version P10
@since 	 08/01/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Static Function TotImp(aReg)	
	Local nNun := 0	
	Default aReg :={} 
	
	If !Empty(aReg[14])  // Codigo de retencao do IRN
		nNun ++
	EndIf
	If !Empty(aReg[16])  // Codigo de retencao do IRPF
	  	nNun ++          
	EndIf
	If !Empty(aReg[18])  // Codigo de retencao do IVA
	    nNun ++ 
	EndIf
	If !Empty(aReg[20])  // Codigo de retencao do IRAE
	    nNun ++ 
	Endif     
	
Return(nNun)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RetProvin
Busca da SX5 A Providencia
@author  Fernando Bastos
@version P10
@since 	 08/01/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Static Function RetProvin (cProvin)
	Local cPro := ""
	Default cProvin :="MO"
	
	dbSelectArea("SX5")
	SX5->(dbSetOrder(1))
	If SX5->(dbSeek(xFilial("SX5")+"12"+cProvin))
		cPro := (SX5->X5_DESCSPA) 
	Else 
		cPro := cProvin
	Endif
Return (cPro)