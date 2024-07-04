#INCLUDE "PROTHEUS.CH" 
#INCLUDE "PARMTYPE.CH" 

#DEFINE DIR_SCHEMA If(IsSrvUnix(),"/schemas/","\schemas\" )
#DEFINE DIR_SCHEMA_SOCIAL If(IsSrvUnix(),"/schemas/esocial/","\schemas\esocial\" )
#DEFINE BARRA If(IsSrvUnix(),"/","\")

static __GetTCVersao	:= "TC2.00"

Function ColNfeConv(cXML,cIdEnt,cMail,lInverso,cErroSoap,cNFMod,aRespNfe,aImpNFE,cModalCTE,nTpEmisCte)

Local aProd	:= {}
Local aAutXml	:= {}
Local aImp		:= {{0,0,0,0,0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0,0,0,0,0,0,0,0,0},{0,0},{0,0}}
Local aTot		:= {0,0,0,0,0}
Local aPgto	:= {}

Local cNewXML	:= ""
//Local cVersao	:= SpedGetMv("MV_VERSAO",cIdEnt)
Local cVersao	:= IIF(cNFMod=="57",ColGetPar("MV_VERCTE","2.00"),ColGetPar("MV_VERSAO","3.10"))	
Local cAviso	:= ""
Local cErro	:= ""
Local cDepc	:= ""
Local cStr		:= ""
Local cURL		:= ""
Local cChave	:= ""
Local nX		:= 0
Local nHandle	:= 0
Local nY		:= 0
Local nV		:= 0
Local nW		:= 0
Local nZ		:= 0
Local nI		:= 0
Local nJ		:= 0
Local nStr		:= 0
Local nAmbiente	:= 0
Local lRetorno	:= .T.
Local lCdata		:= .F.
Local lBreak		:= .F.
Local bErro		:= Nil
Local lUsaColab	:= .F.

Private cString 	:= ""
Private oNFe

DEFAULT aRespNfe	:= {}
DEFAULT aImpNFE	:= {}
DEFAULT cMail		:= ""
DEFAULT cModalCTE	:= ""
DEFAULT nTpEmisCte	:= 0
DEFAULT lInverso	:= .F.


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico se foi enviado alguma clausula CDATA                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se foi recebido um XML valido                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//oNFe := TSSXmlParser(cXML,"_",@cAviso,@cErro) - cXml := encodeUTF8( XmlClean(cXml) )
cXml := encodeUTF8( LimpaXml(cXml))
		oNFe := XmlParser(cXml,"_",@cAviso,@cErro) 
	
If Empty(cAviso) .And. Empty(cErro) .And. oNFe <> nil
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montagem do novo XML                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Type("oNFe:_TC_RPS")=="U" .And. Type("oNFe:_RPS")=="U"
		If Type("oNFe:_NFE:_INFNFE:_VERSAO:TEXT")=="U" .And. Type("oNFe:_CTE:_INFCTE:_VERSAO:TEXT")=="U" .And. Type("oNFe:_MDFE:_INFMDFE:_VERSAO:TEXT")=="U"
		    
		    If Type("oNFe:_TC_INFRPS")=="U" .And. Type("oNFe:_INFRPS")=="U"
			    If oNFe:_INFNFE:_VERSAO:TEXT=="T02.00"
			    	cNFMod := AllTrim(oNFe:_INFNFE:_MODELO:TEXT)
			    Else
			    	cNFMod := "55"
			    EndIf
			Else
				cNFMod := "56"
			EndIf
		    Do Case
		    	Case cNFMod == "57"
		    		lRetorno := .T.
    				nX := At("[EMAIL=",UPPER(cXml))
					If nX > 0
						cMail := ""
						cMail := SubStr(cXml,nX+7)
						nX    := At("]",UPPER(cMail))
						cMail := SubStr(cMail,1,nX-1)
						cXml  := StrTran(cXml,"[EMAIL="+cMail+"]","")
						cMail := AllTrim(cMail)
					EndIf
					cXml:= StrTran(cXml,'<infNFe versao="T02.00" modelo="57">',"")
					cXml:= StrTran(cXml,'</CTe></infNFe>','</CTe>')
					//oNFe := TSSXmlParser(cXML,"_",@cAviso,@cErro)
					oNFe := XmlParser(cXML,"_",@cAviso,@cErro)
		    	Case cNFMod== "56"
					nAmbiente := Val(SubStr(ColGetPar("MV_AMBINSE","2"),1,1))
					//cURL := GetURLNSe(GetMunCod(SPED001->ID_ENT),Str(nAmbiente,1))
					lRetorno := .T.
					
					If "/bhiss-ws/"$cURL
						cXml := XMLSaveStr(oNFe:_INFRPS,.F.)
			   			cChave := GetUFCode(Upper(Left(LTrim(SM0->M0_ESTENT),2)))+SubStr(oNFe:_INFRPS:_DATAEMISSAO:TEXT,3,2)+SubStr(oNFe:_INFRPS:_DATAEMISSAO:TEXT,6,2)+Alltrim(SPED001->CNPJ)+"56"+StrZero(Val(oNFe:_INFRPS:_IDENTIFICACAORPS:_SERIE:TEXT),3)+StrZero(Val(oNFe:_INFRPS:_IDENTIFICACAORPS:_NUMERO:TEXT),9)+StrZero(Val(oNFe:_INFRPS:_IDENTIFICACAORPS:_NUMERO:TEXT),9)
			   			nY := At(">",cXml)//Posição inicial da tag InfRps
	           			nV := At("</InfRps>",cXml)//Posição final da tag InfRps
	           			cNewXML := '<InfRps Id="NSe'+cChave+'" xmlns="http://www.abrasf.org.br/nfse.xsd"'
			   		    cNewXML := cNewXML + SubStr(cXml,nY,nV-nY)+'</InfRps>'//Conteudo da Tag 
						cXml := cNewXML
					Elseif "issnetonline"$cURL
						cXml := XMLSaveStr(oNFe:_TC_INFRPS,.F.)
			   			cChave := GetUFCode(Upper(Left(LTrim(SM0->M0_ESTENT),2)))+SubStr(oNFe:_TC_INFRPS:_TC_DATAEMISSAO:TEXT,3,2)+SubStr(oNFe:_TC_INFRPS:_TC_DATAEMISSAO:TEXT,6,2)+Alltrim(SPED001->CNPJ)+"56"+StrZero(Val(oNFe:_TC_INFRPS:_TC_IDENTIFICACAORPS:_TC_SERIE:TEXT),3)+StrZero(Val(oNFe:_TC_INFRPS:_TC_IDENTIFICACAORPS:_TC_NUMERO:TEXT),9)+StrZero(Val(oNFe:_TC_INFRPS:_TC_IDENTIFICACAORPS:_TC_NUMERO:TEXT),9)
			   			nY := At(">",cXml)//Posição inicial da tag InfRps
	           			nV := At("</tc:InfRps>",cXml)//Posição final da tag InfRps
	           			cNewXML := '<tc:InfRps Id="NSe'+cChave+'" xmlns="http://www.issnetonline.com.br/webserviceabrasf/vsd/tipos_complexos.xsd" xmlns:tc="http://www.issnetonline.com.br/webserviceabrasf/vsd/tipos_complexos.xsd"'
			   		    cNewXML := cNewXML + SubStr(cXml,nY,nV-nY)+'</tc:InfRps>'//Conteudo da Tag 
						cXml := cNewXML
						
						If nAmbiente=2//Se for ambiente de teste a ISSNET só aceita o código 999 para o municipio de prestacao de serviço
				   			nW := At("<tc:MunicipioPrestacaoServico>",cXml)//Posição inicial da tag MunicipioPrestacaoServico
		           			nZ := At("</tc:MunicipioPrestacaoServico>",cXml)//Posição final da tag MunicipioPrestacaoServico
		           			cNewXML := SubStr(cXml,1,nW-1)+'<tc:MunicipioPrestacaoServico>999'//Conteudo inicio do XML 
				   		    cNewXML := cNewXML + SubStr(cXml,nZ,Len(cXml))//Conteudo da Tag 
							cXml := cNewXML
						EndIf
						
					Else
						lRetorno := .F.
					EndIf
					
		    		cMail    := "" //Provisorio
		    	OtherWise
		    		If cNFMod == "65"
		    			nAmbiente	:= Val(SubStr(ColGetPar("MV_AMBNFCE","2"),1,1)) 
		    			cVersao	:= SubStr(ColGetPar("MV_VERNFCE","3.10"),1,1) //spedGetMV( "MV_VERNFCE", cIdEnt, "3.10" )
		    		Else
		    			nAmbiente   := Val(SubStr(ColGetPar("MV_AMBIENT","2"),1,1)) 
		    		EndIf
		    		bErro     := ErrorBlock({|e| lBreak := .T. ,ErrNfeConv(e,cXML,cNewXML+cString,@cErroSoap)})
		    		lUsaColab  := ColUsaColab("1") //cUsaColab =="S" .And. ( ( cNFMod == "55" .And. "1" $ cDocSCol ) .Or. cDocSCol == "0")
		    		
					Begin Sequence
					
						If(cVersao == "4.00")
							
							cNewXML := ""
							cNewXML := NFeV4Col(cIdEnt, oNFe, cNfMod, nAmbiente)
							cXml := cNewXML
							
						else										
					
							oNFe := oNFe:_infNFe
							cNewXML := ""
							cNewXML := XmlNfeIde(lInverso,cVersao,cIdEnt,oNFe:_Ide,oNFe:_Emit,IIf(Type("oNFe:_Cobr")=="U",Nil,oNFe:_Cobr),cNFMod)
							cNewXML += XmlNfeEmit(cVersao,oNFe:_Emit)
							cNewXML += XmlNfeDest(cVersao,IIf(Type("oNFe:_Dest")=="U",Nil,oNFe:_Dest),@cMail, nAmbiente,cNFMod)
							cNewXML += XmlNfeRetirada(cVersao,IIf(Type("oNFe:_Retirada")=="U",Nil,oNFe:_Retirada))
							cNewXML += XmlNfeEntrega(cVersao,IIf(Type("oNFe:_Entrega")=="U",Nil,oNFe:_Entrega))
							If cVersao >= "3.10"
								If Type("oNFe:_autxml") <> "U"
									If ValType(oNFe:_autxml)=="A"
										aAutXml := oNFe:_autxml
									Else
										aAutXml := {oNFe:_autxml}
									EndIf
								
									For nI := 1 To Len(aAutXml)						
										cNewXML += XmlNfeAut(aAutXml[nI])
									Next nI
								/*NT2015/002 - Grupo Obrigatório para Sefaz BA - 
								Caso o grupo não seja informado, será criado com o CNPJ da Sefaz BA
							
								Rejeicao 486: Não informado o Grupo de Autorização para UF que exige a 
								identificação do Escritório de Contabilidade na Nota Fiscal
								*/	
								ElseIf Type("oNFe:_autxml") == "U" .and. oNFe:_Emit:_ENDEREMIT:_UF:TEXT $ "29"
									cNewXML += '<autXML>'
									cNewXML += '<CNPJ>13937073000156</CNPJ>'
									cNewXML += '</autXML>'															
								EndIf
							EndIf
						
							If ValType(oNfe:_Det)=="A"
								aProd := oNfe:_Det
							Else
								aProd := {oNfe:_Det}
							EndIf
							For nX := 1 To Len(aProd)
								cNewXML += XmlNfeItem(cVersao,aProd[nX],@aImp,@aTot,lCdata,oNFe:_Emit:_ENDEREMIT:_UF:TEXT,lUsaColab)
							Next nX
							cNewXml += XmlNfeTotal(cVersao,oNfe:_Total,@aImp,@aTot)
							cNewXml += XmlNfeTransp(cVersao,oNfe:_Transp)
							cNewXml += XmlNfeCob(cVersao,IIf(Type("oNFe:_Cobr")=="U",Nil,oNFe:_Cobr))
						
							If cVersao >= "3.10" .and. cNFMod == "65"
								If Type("oNFe:_pagamento") <> "U"
									If ValType(oNFe:_pagamento)=="A"
										aPgto := oNFe:_pagamento
									Else
										aPgto := {oNFe:_pagamento}
									EndIf
								
									For nJ := 1 To Len(aPgto)						
										cNewXML += XmlNfePag(aPgto[nJ])
									Next nJ
								EndIf							
							EndIf
							cNewXml += XmlNfeInf(cVersao,IIf(Type("oNFe:_InfAdic")=="U",Nil,oNFe:_InfAdic),lCdata,lUsaColab)
							cNewXml += XmlNfeExp(cVersao,IIf(Type("oNFe:_exporta")=="U",Nil,oNFe:_exporta))
							cNewXml += XmlNfeInfCompra(cVersao,IIf(Type("oNFe:_Compra")=="U",Nil,oNFe:_Compra))
							cNewXml += XmlNfeCana(cVersao,IIf(Type("oNFe:_cana")=="U",Nil,oNFe:_cana))
					
							cNewXml += "</infNFe>"
							cNewXml := '<NFe xmlns="http://www.portalfiscal.inf.br/nfe">'+cNewXML			
							cNewXml += "</NFe>"	
					
							If !lBreak
								cXML    :=cNewXML
								If !Type("oNFe:_INFADIC:_CPL")=="U"
									nX := At("[CONTRTSS=",UPPER(cXml))
									If nX > 0
										cStr	:=	SubStr(cXml,nX+10)
										aAdd(aRespNfe,SToD(StrTran(SubStr(cStr,1,At("#",cStr)-1),"-","")))
								
										cStr	:=	SubStr(cStr,At("#",cStr)+1)
										aAdd(aRespNfe,SubStr(cStr,1,At("#",cStr)-1))
									
										cStr	:=	SubStr(cStr,At("#",cStr)+1)
										nStr	:=	At("]",cStr)
										aAdd(aRespNfe,SubStr(cStr,1,nStr-1))
										cXml	:=	SubStr(cXml,1,nX-1)+SubStr(cStr,nStr+1)
										cXml 	:= StrTran(cXml,"<infAdic><infAdFisco></infAdFisco><infCpl></infCpl></infAdic>","")
										cXml 	:= StrTran(cXml,"<infAdic><infAdFisco></infAdFisco></infAdic>","")
										cXml 	:= StrTran(cXml,"<infAdic><infCpl></infCpl></infAdic>","")
										cXml 	:= StrTran(cXml,"<infAdic>></infCpl></infAdic>","")
										cXml 	:= StrTran(cXml,"<infAdic></infAdic>","")									
										cXml 	:= StrTran(cXml,"<infCpl></infCpl>","")								
									EndIf 
								EndIf 
							Else
								Break
							EndIf
						EndIf
					Recover
						cXml := cNewXML
						lRetorno := .F.
					End Sequence
					ErrorBlock (bErro)
			EndCase
		Else 
			Do Case
				Case Type("oNFe:_CTE:_INFCTE:_VERSAO:TEXT")<>"U"
					cNFMod := "57"
				Case Type("oNFe:_MDFE:_INFMDFE:_VERSAO:TEXT")<>"U"
					cNFMod := "58"	
				Case Type("oNFe:_NFE:_INFNFE:_IDE:_MOD:TEXT")<>"U"
					cNFMod := allTrim( oNFe:_NFE:_INFNFE:_IDE:_MOD:TEXT )
				OtherWise
					cNFMod := "55"		
			EndCase
			
			If cNFMod <> "58"
				nX := At("[EMAIL=",UPPER(cXml))
				If nX > 0
					cMail := ""
					cMail := SubStr(cXml,nX+7)
					nX    := At("]",UPPER(cMail))
					cMail := SubStr(cMail,1,nX-1)
					cXml  := StrTran(cXml,"[EMAIL="+cMail+"]","")
					cMail := AllTrim(cMail)
				ElseIf Empty(cMail) .And. cVersao >="2.00"
					oEmail:= XmlParser(cXml,"_",@cAviso,@cErro)
					If Empty(cAviso+cErro)	
						If Type("oEmail:_NFE:_INFNFE:_DEST:_EMAIL")<>"U" 
						 	cMail :=Alltrim(oEmail:_NFE:_INFNFE:_DEST:_EMAIL:TEXT)
						EndIf
					EndIf			        
				EndIf
				nX := At("[CONTRTSS=",UPPER(cXml))
				If nX > 0
					cStr	:=	SubStr(cXml,nX+10)
					aAdd(aRespNfe,SToD(StrTran(SubStr(cStr,1,At("#",cStr)-1),"-","")))
				
					cStr	:=	SubStr(cStr,At("#",cStr)+1)
					aAdd(aRespNfe,SubStr(cStr,1,At("#",cStr)-1))
					
					cStr	:=	SubStr(cStr,At("#",cStr)+1)
					nStr	:=	At("]",cStr)
					aAdd(aRespNfe,SubStr(cStr,1,nStr-1))
					cXml	:=	SubStr(cXml,1,nX-1)+SubStr(cStr,nStr+1)
				EndIf
				//chave para gravar a tabela sped050 referente algumas informacoes de impressao do danfe.
				nX := At("[IMPDANFE=",UPPER(cXml))
				If nX > 0
					cStr	:=	SubStr(cXml,nX+10)
					aAdd(aImpNFE,SubStr(cStr,1,At("#",cStr)-1))
				
					cStr	:=	SubStr(cStr,At("#",cStr)+1)
					aAdd(aImpNFE,SubStr(cStr,1,At("#",cStr)-1))
					
					cStr	:=	SubStr(cStr,At("#",cStr)+1)
					nStr	:=	At("]",cStr)
					aAdd(aImpNFE,SubStr(cStr,1,nStr-1))
					cXml	:=	SubStr(cXml,1,nX-1)+SubStr(cStr,nStr+1)
				EndIf 
				
				cXml 	:= StrTran(cXml,"<infAdic><infAdFisco></infAdFisco><infCpl></infCpl></infAdic>","")
				cXml 	:= StrTran(cXml,"<infAdic><infAdFisco></infAdFisco></infAdic>","")
				cXml 	:= StrTran(cXml,"<infAdic><infCpl></infCpl></infAdic>","")
				cXml 	:= StrTran(cXml,"<infAdic>></infCpl></infAdic>","")
				cXml 	:= StrTran(cXml,"<infAdic></infAdic>","")									
				cXml 	:= StrTran(cXml,"<infCpl></infCpl>","")		
			EndIf
		EndIf
	Else
		cNFMod := "56"
	EndIf
Else
	cErroSoap := cErro+cAviso
	lRetorno := .F.
EndIf

If ColGetPar("MV_AMBIENT","2")=="2"
	//cMail := SpedGetMV("MV_SMTPFAC",cIdEnt)	verificar
EndIf                                      
If cNFMod == "57"
	If Type("oNFe:_CTE:_INFCTE:_IDE:_MODAL:TEXT") <> "U"
		cModalCTE := AllTrim(oNFe:_CTE:_INFCTE:_IDE:_MODAL:TEXT)
	Endif
	If Type("oNFe:_CTE:_INFCTE:_IDE:_TPEMIS:TEXT") <> "U"
		nTpEmisCte	:= Val(Alltrim(oNFe:_CTE:_INFCTE:_IDE:_TPEMIS:TEXT))
	EndIF 
Endif

Return(lRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} ErrNfeConv
Retorna uma mensagem de erro padrão para erros de conversão de parse do XML.

@author Cleiton Genuino
@since 29/03/2016
@version 1.0
@param	oErro, objeto, Objeto utilizado para execução que salva bloco de código do tratamento de erro
@param	cOrigXML, string, XML original antes do erro parse do XML
@param	cNewXML, string, XML após o erro parse do XMLs
@param	lBloco, string, indica se a chamada será por | ErrorBlock  | ou  | Funcao  |
@return cErro, string, Mensagem padrão de erro gerada
/*/
//-------------------------------------------------------------------
Function ErrNfeConv(oErro,cOrigXML,cNewXML,cErro,lBloco)
Default cErro  := ""
Default lBloco := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem da mensagem de erro                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if lBloco
cErro:= CRLF+"Mensagem de erro: "+ oErro:Description +CRLF
cErro+= ProcName(2)+": "+AllTrim(Str(ProcLine(2),18))+CRLF
cErro+= CRLF
cErro+= "XML recebido: "+cOrigXML+CRLF
cErro+= "XML convertido: "+cNewXML+CRLF
cErro+= CRLF

Break

Else
	cErro:= CRLF+"Mensagem de erro: "+ cErro +CRLF
	cErro+= ProcName(2)+": "+AllTrim(Str(ProcLine(2),18))+CRLF
	cErro+= CRLF
	cErro+= "XML recebido: "+cOrigXML+CRLF
	cErro+= CRLF
	cErro+= "XML convertido: "+cNewXML+CRLF
	cErro+= CRLF
Endif
Return(cErro)




Static Function XmlNfeIde(lInverso,cVersao,cIdEnt,oIde,oEmit,oCobr,cNFMod)

Local aNfVinc 	:= {}
Local aTpEmis	:= {}

Local cIndPag 	:= ""



Local cDhEmis	:= ""
Local cDhSaiEnt	:= ""
Local cVersaoTC	:= "TC2.00"		//Versao Totvs Colaboracao (Client Neogrid)
Local dDtEmis	:= CtoD("")
Local dDtSaiEnt	:= CtoD("")
Local dDhCont	:= CtoD("")
Local lConting	:= .F.



Local nX      	:= 0


Private oRefNFp
Private oXml  	:= oCobr
Private oXmlRef

Default cNFMod := "55"

aTpEmis	:= GetTpEmis(cIdEnt,cNFMod)
lConting	:= aTpEmis[2] //Retorna se está em contingencia de acordo com o tipo de emissão
cString := ""


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcula a chave de acesso sem o digito verificador                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lInverso
	If cVersao >= "3.10"
		cChave := GetUFCode(oEmit:_EnderEmit:_UF:TEXT)+SubStr(oIde:_dHEmi:TEXT,3,2)+SubStr(oIde:_dHEmi:TEXT,6,2)+oEmit:_CNPJ:TEXT+Alltrim(cNFMod)+StrZero(Val(oIde:_Serie:TEXT),3)+StrZero(Val(oIde:_nNF:TEXT),9)+aTpEmis[1]+StrZero(Val(oIde:_cNF:TEXT),8)
	Else   	
	   	cChave := GetUFCode(oEmit:_EnderEmit:_UF:TEXT)+SubStr(oIde:_dEmi:TEXT,3,2)+SubStr(oIde:_dEmi:TEXT,6,2)+oEmit:_CNPJ:TEXT+"55"+StrZero(Val(oIde:_Serie:TEXT),3)+StrZero(Val(oIde:_nNF:TEXT),9)+aTpEmis[1]+StrZero(Val(oIde:_cNF:TEXT),8)
	EndIf 																																								   										    
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica o tipo de pagamento                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oXml  := oIde
	If Type("oXml:_indpag")<>"U"
		cIndPag := oIde:_indpag:TEXT
	Else
		oXml  := oCobr
		Do Case
			Case oXml==Nil
				cIndPag := "2"
			Case ValType(oXml:_Dup)=="A"
				If Len(oXml:_Dup)==1 .And. oXml:_Dup[01]:_DtVenc:TEXT <= oIde:_dEmi:TEXT
					cIndPag := "0"
				Else
					cIndPag := "1"
				EndIf
			OtherWise
				If oXml:_Dup:_DtVenc:TEXT <= oIde:_dEmi:TEXT
					cIndPag := "0"
				Else
					cIndPag := "1"
				EndIf
		EndCase
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o XML                                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oXml := oIde
	cString += '<infNFe versao="'+cVersao+'" Id="NFe'+cChave+Modulo11(cChave)+'">'
	cString += '<ide>'
	cString += '<cUF>'+GetUFCode(oEmit:_EnderEmit:_UF:TEXT)+'</cUF>'
	cString += '<cNF>'+ConvType(StrZero(Val(oIde:_cNF:TEXT),8,0),8,0)+'</cNF>'
	cString += '<natOp>'+oIde:_natOp:TEXT+'</natOp>'
	cString += '<indPag>'+cIndPag+'</indPag>'
	cString += '<mod>'+Alltrim(cNFMod)+'</mod>'
	cString += '<serie>'+oIde:_Serie:TEXT+'</serie>'
	cString += '<nNF>'+oIde:_nNF:TEXT+'</nNF>'
	If cVersao >= "3.10"
		//Nota Técnica 2013/005 - Data e Hora no formato UTC
		If Type("oXml:_dhEmi:TEXT") <> "U"
			dDtEmis := Ctod(SubStr(oXml:_dhEmi:TEXT,9,2)+"/"+SubStr(oXml:_dhEmi:TEXT,6,2)+"/"+SubStr(oXml:_dhEmi:TEXT,1,4))
			cDhEmis:= DataHoraUTC(dDtEmis,SubStr(oXml:_dhEmi:TEXT,12,8))		
		Else
			cDhEmis:= DataHoraUTC()
		EndIf
		cString += '<dhEmi>'+cDhEmis+'</dhEmi>'
		
		If Type("oXml:_dhSaiEnt") <> "U"
			dDtSaiEnt := Ctod(SubStr(oXml:_dhSaiEnt:TEXT,9,2)+"/"+SubStr(oXml:_dhSaiEnt:TEXT,6,2)+"/"+SubStr(oXml:_dhSaiEnt:TEXT,1,4))
			cDhSaiEnt:= DataHoraUTC(dDtSaiEnt,SubStr(oXml:_dhSaiEnt:TEXT,12,8))
			cString += '<dhSaiEnt>' + cDhSaiEnt + '</dhSaiEnt>'
			//cString += NfeTag('<dhSaiEnt>',cDhSaiEnt)
		EndIf
		
	Else
		cString += '<dEmi>'+oIde:_dEmi:TEXT+'</dEmi>'
		cString += NfeTag('<dSaiEnt>',"oXml:_dSaiEnt:TEXT")
		
		If Type("oXml:_dSaiEnt") <> "U"   // Antes da Nota técnica 2011/004 não era validado se a data estava sendo enviado, agora é obrigatorio enviar a data e hora ou somente a hora.
			cString += NfeTag('<hSaiEnt>',"oXml:_hSaiEnt:TEXT")
		EndIf
	EndIf
                                               
	cString += '<tpNF>'+oIde:_tpNF:TEXT+'</tpNF>'
	If cVersao >= "3.10"
		cString += '<idDest>'+oIde:_idDest:TEXT+'</idDest>'
	EndIf
	If Type("oXml:_cMunFG")<>"U"
		cString += '<cMunFG>'+oIde:_cMunFG:TEXT+'</cMunFG>'
	Else
		cString += '<cMunFG>'+oEmit:_EnderEmit:_cMun:TEXT+'</cMunFG>'
	EndIf

	If Type("oXml:_TpImp:TEXT")=="U"
		cString += '<tpImp>1</tpImp>'
	Else
		cString += '<tpImp>'+oIde:_TpImp:TEXT+'</tpImp>'
	EndIf
	cString += '<tpEmis>'+aTpEmis[1]+'</tpEmis>'

	cString += '<cDV>'+Modulo11(cChave)+'</cDV>'
	cString += '<tpAmb>'+IIf(cNFMod == "65",SubStr(ColGetPar("MV_AMBNFCE","2"),1,1),SubStr(ColGetPar("MV_AMBIENT","2"),1,1))+'</tpAmb>' //VERIFICAR  /*SpedGetMv("MV_AMBIENT",cIdEnt))+*/	
	cString += '<finNFe>'+oIde:_tpNFe:TEXT+'</finNFe>'
	If cVersao >= "3.10" //Novas tags de indicação de operação com consumidor Final e indicador de presença
		cString += '<indFinal>'+oIde:_indFinal:TEXT+'</indFinal>'
		cString += '<indPres>'+oIde:_indPres:TEXT+'</indPres>'
	EndIf
	cString += '<procEmi>0</procEmi>'
	cString += '<verProc>'+cVersaoTC+'</verProc>'	
	
	If lConting 
		cString += '<dhCont>'+ColGetPar("MV_NFINCON")+'</dhCont>'
		cString += '<xJust>'+ColGetPar("MV_NFXJUST")+'</xJust>'
	EndIf 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o grupo NFRef da NFe 3.10                                  		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cVersao >= "3.10"
		cString += MontaNFRef(cVersao,aTpEmis[1])
	EndIf
	cString += '</ide>'
Else
	oXml := oIde
	cString += '<infNFe versao="T01.00">'
	cString += '<ide>'
	cString += '<cNF>'+oIde:_cNF:TEXT+'</cNF>'
	cString += '<natOp>'+oIde:_natOp:TEXT+'</natOp>'
	cString += '<indPag>'+oIde:_indPag:TEXT+'</indPag>'
	cString += '<Serie>'+oIde:_serie:TEXT+'</Serie>'
	cString += '<nNF>'+oIde:_nNF:TEXT+'</nNF>'
	cString += '<dEmi>'+oIde:_dEmi:TEXT+'</dEmi>'
	cString += NfeTag('<dSaiEnt>',"oIde:_dSaiEnt:TEXT")
	cString += '<tpNF>'+oIde:_tpNF:TEXT+'</tpNF>'
	If Type("oXml:_cMunFG")<>"U"
		cString += '<cMunFG>'+oIde:_cMunFG:TEXT+'</cMunFG>'
	EndIf
	                        
	If Type("oXml:_NFRef")<>"U"
		cString += '<NFRef>'
		If Type("oXml:_NFRef:_refNFe")<>"U"
			If ValType(oXml:_NFRef:_refNFe)=="A"
				aNfVinc := oXml:_NFRef:_refNFe
			Else
				aNFVinc := {oXml:_NFRef:_refNFe}
			EndIf
			For nX := 1 To Len(aNFVinc)
				cString += '<refNFe>'+aNFVinc[nX]:TEXT+'</refNFe>'
			Next nX
		EndIf
		If Type("oXml:_NFRef:_RefNF")<>"U"
			If ValType(oXml:_NFRef:_refNF)=="A"
				aNfVinc := oXml:_NFRef:_refNF
			Else
				aNFVinc := {oXml:_NFRef:_refNF}
			EndIf
			cString += '<refNF>'
			For nX := 1 To Len(aNFVinc)
				cString += '<cUF>'  +aNfVinc[nX]:_cUF:TEXT+'</cUF>'
				cString += '<AAMM>' +aNfVinc[nX]:_AAMM:TEXT+'</AAMM>'
				cString += '<CNPJ>' +aNfVinc[nX]:_CNPJ:TEXT+'</CNPJ>'
				cString += '<mod>'  +aNfVinc[nX]:_Mod:TEXT+'</mod>'
				cString += '<Serie>'+aNfVinc[nX]:_Serie:TEXT+'</Serie>'
				cString += '<nNF>'  +aNfVinc[nX]:_nNF:TEXT+'</nNF>'
			Next nX
			cString += '</refNF>'
		EndIf
		cString += '</NFRef>'
	EndIf
	If Type("oXml:_TpAmb:TEXT")
		cString += '<tpAmb>'+oIde:_TpAmb:TEXT+'</tpAmb>'
	EndIf			
	If Type("oXml:_TpNFe:TEXT")
		cString += '<Tpnfe>'+oIde:_TpNFe:TEXT+'</Tpnfe>'
	ElseIf Type("oXml:_finNFe:TEXT")
		cString += '<Tpnfe>'+oIde:_finNFe:TEXT+'</Tpnfe>'
	EndIf
	cString += '</ide>'
EndIf
Return(cString)

Static Function XmlNfeEmit(cVersao,oEmit)

Private oXml    := oEmit
cString := ""

cString := '<emit>'
If Type("oXml:_CNPJ:TEXT")<>"U"
	cString += '<CNPJ>'+oEmit:_CNPJ:TEXT+'</CNPJ>
EndIf
If Type("oXml:_CPF:TEXT")<>"U"
	cString += '<CPF>' +oEmit:_CPF:TEXT+'</CPF>
EndIf
cString += '<xNome>'+oEmit:_Nome:TEXT+'</xNome>'
cString += NfeTag('<xFant>',"oXml:_Fant:TEXT")
cString += '<enderEmit>'
cString += '<xLgr>' +oEmit:_EnderEmit:_Lgr:TEXT+'</xLgr>'
If Type("oXml:_EnderEmit:_Nro:TEXT")<>"U"
	cString += NfeTag('<nro>',"oXml:_EnderEmit:_Nro:TEXT",.T.)
Else
	cString += '<nro>s/n</nro>'
EndIf
cString += NfeTag('<xCpl>',"oXml:_EnderEmit:_Cpl:TEXT")
cString += '<xBairro>'+oEmit:_EnderEmit:_Bairro:TEXT+'</xBairro>'
cString += '<cMun>'   +oEmit:_EnderEmit:_cMun:TEXT+'</cMun>'
cString += '<xMun>'   +oEmit:_EnderEmit:_Mun:TEXT+'</xMun>'
cString += '<UF>'     +oEmit:_EnderEmit:_UF:TEXT+'</UF>'
cString += NfeTag('<CEP>',"oXml:_EnderEmit:_Cep:TEXT")
cString += NfeTag('<cPais>',"oXml:_EnderEmit:_cPais:TEXT")
cString += NfeTag('<xPais>',"oXml:_EnderEmit:_Pais:TEXT")
cString += NfeTag('<fone>',"ConvType(oXml:_EnderEmit:_Fone:TEXT,14,0)")
cString += '</enderEmit>'
cString += '<IE>'+oEmit:_IE:TEXT+'</IE>'
cString += NfeTag('<IEST>',"oXml:_IEST:TEXT",.F.)
cString += NfeTag('<IM>'  ,"oXml:_IM:TEXT")
cString += NfeTag('<CNAE>',"IIF(!Empty(oXml:_IM:TEXT),oXml:_CNAE:TEXT,'')")
cString += '<CRT>'+oEmit:_CRT:TEXT+'</CRT>'
cString += '</emit>'
Return(cString)

Static Function XmlNfeDest(cVersao,oDest,cMail, nAmbiente,cNFMod)

Private oXml    := oDest

cString := ""
If oDest <> Nil
	cString := '<dest>'
	If Type("oXml:_CNPJ:TEXT")<>"U"
		If cVersao >= "3.10" .and. !Empty(oDest:_CNPJ:TEXT) //Campo não aceita valor nulo
			cString += '<CNPJ>'+oDest:_CNPJ:TEXT+'</CNPJ>'
		EndIf
		If cVersao == "2.00"
			cString += '<CNPJ>'+oDest:_CNPJ:TEXT+'</CNPJ>'
		EndIf
	EndIf
	
	If Type("oXml:_CPF:TEXT")<>"U"
		cString += NfeTag('<CPF>' ,"oXml:_CPF:TEXT")
	EndIf
	If cVersao >= "3.10"
		If Type("oXml:_idEstrangeiro:TEXT")<>"U"
			cString += NfeTag('<idEstrangeiro>',"ConvType(oXml:_idEstrangeiro:TEXT,20)",.T.)
		EndIf
	EndIf
	
	If nAmbiente == 2 // Nota Técnica 2011/002
		cString += "<xNome>NF-E EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL</xNome>"
	Else
		If cNFMod == "65" .and. Type("oXml:_Nome:TEXT")<>"U"
			cString += NfeTag('<xNome>' ,"oXml:_Nome:TEXT")
		Else
			cString += '<xNome>'+oDest:_Nome:TEXT+'</xNome>'
		EndIf
	EndIf
	/* Grupo opcional para NFCe na versão 3.10. Na NFe a obrigatoriedade continua*/
	If Type("oXml:_EnderDest") <> "U"
		cString += '<enderDest>'
		cString += '<xLgr>'+oDest:_EnderDest:_Lgr:TEXT+'</xLgr>'
		cString += NfeTag('<nro>',"oXml:_EnderDest:_nro:TEXT",.T.)
		cString += NfeTag('<xCpl>',"oXml:_EnderDest:_Cpl:TEXT")
		cString += '<xBairro>'+oDest:_EnderDest:_Bairro:TEXT+'</xBairro>'
		cString += '<cMun>'+oDest:_EnderDest:_cMun:TEXT+'</cMun>'
		cString += '<xMun>'+oDest:_EnderDest:_Mun:TEXT+'</xMun>'
		cString += '<UF>'+oDest:_EnderDest:_UF:TEXT+'</UF>'
		cString += NfeTag('<CEP>',"oXml:_EnderDest:_CEP:TEXT")
		cString += NfeTag('<cPais>',"oXml:_EnderDest:_cPais:TEXT")
		cString += NfeTag('<xPais>',"oXml:_EnderDest:_Pais:TEXT")
		cString += NfeTag('<fone>',"ConvType(oXml:_EnderDest:_fone:TEXT,14,0)")
		cString += '</enderDest>'
	EndIf
	
	If cVersao >= "3.10"
		cString += '<indIEDest>'+ConvType(oXml:_indIEDest:TEXT,1)+'</indIEDest>'
		If Type("oXml:_IE:TEXT") <> "U"
			cString += NfeTag('<IE>',"oXml:_IE:TEXT")
		EndIf
	Else
		cString += '<IE>'+oDest:_IE:TEXT+'</IE>'
	EndIf
	
	cString += NfeTag('<ISUF>',"oXml:_IESUF:TEXT")
	If cVersao >= "3.10"
		cString += NfeTag('<IM>',"ConvType(oXml:_IM:TEXT,15)")
	EndIf
	If Type("oXml:_eMail:TEXT")<>"U"
		cMail := oXml:_eMail:TEXT
		cString += NfeTag('<email>',"ConvType(oXml:_eMail:TEXT)")
	EndIf
	cString += '</dest>'
EndIf
Return(cString)

Static Function XmlNfeRetirada(cVersao,oRetira)

Private oXml    := oRetira
cString := ""
If oRetira <> Nil
	cString := '<retirada>'
	If Type("oXml:_CNPJ:TEXT")<>"U"
		cString += '<CNPJ>'+oXml:_CNPJ:TEXT+'</CNPJ>'
	ElseIf Type("oXml:_CPF:TEXT")<>"U"
		cString += NfeTag('<CPF>' ,"oXml:_CPF:TEXT")
	Else
		cString += '<CNPJ></CNPJ>'
	EndIf
	cString += '<xLgr>'+oRetira:_Lgr:TEXT+'</xLgr>'
	If Type("oXml:_nro:TEXT")<>"U"
		cString += NfeTag('<nro>',"oXml:_nro:TEXT",.T.)
	Else
		cString += '<nro>s/n</nro>'
	EndIf
	cString += NfeTag('<xCpl>',"oXml:_Cpl:TEXT")
	cString += '<xBairro>'+oRetira:_Bairro:TEXT+'</xBairro>'
	cString += '<cMun>'+oRetira:_cMun:TEXT+'</cMun>'
	cString += '<xMun>'+oRetira:_Mun:TEXT+'</xMun>'
	cString += '<UF>'+oRetira:_UF:TEXT+'</UF>'
	cString += '</retirada>'
EndIf
Return(cString)

Static Function XmlNfeEntrega(cVersao,oEntrega)

Private oXml    := oEntrega
cString := ""
If oEntrega <> Nil
	cString := '<entrega>' 
	
	If Type("oXML:_CNPJ:TEXT")<>"U" .And. !Empty(oXML:_CNPJ:TEXT)
		cString += '<CNPJ>'+oXml:_CNPJ:TEXT+'</CNPJ>'
	ElseIf Type("oXml:_CPF:TEXT")<>"U" .And. !Empty(oXml:_CPF:TEXT) .And. cVersao >= "2.00"
		cString += '<CPF>'+oXml:_CPF:TEXT+'</CPF>'
	Else
		cString += '<CNPJ></CNPJ>'
	EndIf	
	cString += '<xLgr>'+oXML:_Lgr:TEXT+'</xLgr>'
	If Type("oXml:_nro:TEXT")<>"U"
		cString += NfeTag('<nro>',"oXml:_nro:TEXT",.T.)
	Else
		cString += '<nro>s/n</nro>'
	EndIf	
	cString += NfeTag('<xCpl>',"oXml:_Cpl:TEXT")
	cString += '<xBairro>'+oEntrega:_Bairro:TEXT+'</xBairro>'
	cString += '<cMun>'+oEntrega:_cMun:TEXT+'</cMun>'
	cString += '<xMun>'+oEntrega:_Mun:TEXT+'</xMun>'
	cString += '<UF>'+oEntrega:_UF:TEXT+'</UF>'
	cString += '</entrega>'
EndIf
Return(cString)

Static Function XmlNfeItem(cVersao,oDet,aImp,aTot,lCdata,cUf,lUsaColab,cNFMod,nQtdProd,nAmbiente)

Local aNVE		:= {}

Local cGrupo		:= ""
Local cBkpcEAN		:= ""

Local nDI		:= 0
Local nadi		:= 0
Local nMed		:= 0
Local nArma		:= 0
Local nveicProd		:= 0
Local nI		:= 0
Local nValPis		:= 0
Local nValCof		:= 0
Local nDetExp		:= 0
Local nA		:= 0
Local nB		:= 0

Local lICMSComb		:= .F.
Local lPis		:= .F.
Local lCofins		:= .F.
Local nICMSDeson	:= 0

Default lCdata		:= .F.
Default lUsaColab	:= .F.
Default cNFMod		:= ""
Default nQtdProd	:= 0
Default nAmbiente	:= 0

Private aImposto	:= {}
Private aadi		:= {}
Private aDI		:= {}
Private aMed		:= {}
Private aArma		:= {}
Private aveicProd	:= {}
Private aDetExport	:= {}
Private oExpInd
Private oXml		:= oDet

Private cEAN		:= ""
Private cString		:= ""

Private nX		:= 0
Private nY		:= 0
cString += '<det nItem="'+oDet:_nItem:TEXT+'">'
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a tag de produtos                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cString += '<prod>'
cString += '<cProd>' +oDet:_Prod:_cprod:TEXT+'</cProd>'

cEAN:= AllTrim(oDet:_Prod:_EAN:TEXT)
nX := Len(cEAN)
cBkpcEAN := cEAN
cEAN := Val(cEAN)
cEAN := AllTrim(StrZero(cEAN,nX))
nX := Len(cEAN)
If nX <> 8 .And. nX <> 12 .And. nX <> 13 .And. nX <> 14
	cEAN := ""
Else
	cEAN := cBkpcEAN
EndIf
cString += '<cEAN>'  +cEAN+'</cEAN>'
/* Nota Técnica 2015/002
Para a NFC-e, se ambiente de homologação:
- Descrição do primeiro item da Nota Fiscal (tag:xProd) deve ser informada como 
“NOTA FISCAL EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL”*/

If nAmbiente == 2 .and. cNFMod == "65" .and. nQtdProd = 1
	cString += "<xProd>NOTA FISCAL EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL</xProd>"
Else
	cString += '<xProd>' +oDet:_Prod:_prod:TEXT+'</xProd>'
EndIf
cString += '<NCM>'+oXml:_Prod:_ncm:TEXT+'</NCM>'

If cVersao >= "3.10" .and. Type("oDet:_nve") <> "U" 
	If ValType(oDet:_nve)=="A"
		aNVE := oDet:_nve
	Else
		aNVE := {oDet:_nve}
	EndIf
	
	For nI := 1 To Len(aNVE)						
		cNewXML += NfeTag('<NVE>',"ConvType(aNVE[nI]:text,6)")
	Next nI	
EndIf

cString += NfeTag('<CEST>',"oXml:_Prod:_cest:TEXT")
cString += NfeTag('<EXTIPI>',"oXml:_Prod:_extipi:TEXT")

cString += '<CFOP>'  +oDet:_Prod:_cfop:TEXT+'</CFOP>'

cString += NfeTag('<uCom>',"oXml:_Prod:_uCom:TEXT",.T.)

If Type("oXml:_Prod:_qCom:TEXT") <> "U"
	cString += NfeTag('<qCom>',"Convtype(Val(oXml:_Prod:_qCom:TEXT),15,4)",.T.)
Else
	cString += "<qCom>0.0000</qCom>"
EndIf

If Type("oXml:_Prod:_vUnCom:TEXT") <> "U"
	cString += NfeTag('<vUnCom>',"Convtype(oXml:_Prod:_vUnCom:TEXT,21,10,'N')",.T.)
Else
	cString += "<vUnCom>0.0000</vUnCom>"
EndIf

cString += '<vProd>' +ConvType(Val(oDet:_Prod:_vProd:TEXT),15,2)+'</vProd>'

If Type("oXml:_Prod:_cEANTrib:TEXT")<>"U"	
	cEAN:= AllTrim(oXml:_Prod:_cEANTrib:TEXT)
	nX := Len(cEAN)
	cBkpcEAN := cEAN
	cEAN := Val(cEAN)
	cEAN := AllTrim(StrZero(cEAN,nX))
	nX := Len(cEAN)
	If nX <> 8 .And. nX <> 12 .And. nX <> 13 .And. nX <> 14
		cEAN := ""
	Else
		cEAN := cBkpcEAN
	EndIf
EndIf
cString += NfeTag('<cEANTrib>',"cEAN",.T.)
cString += '<uTrib>' +oDet:_Prod:_uTrib:TEXT+'</uTrib>'	
cString += '<qTrib>' +ConvType(Val(oDet:_Prod:_qTrib:TEXT),15,4)+'</qTrib>'
cString += NfeTag('<vUnTrib>',"ConvType(oXml:_Prod:_vUnTrib:TEXT,21,10,'N')",.T.)
cString += NfeTag('<vFrete>',"ConvType(Val(oXml:_Prod:_vFrete:TEXT),15,2)")
cString += NfeTag('<vSeg>'  ,"ConvType(Val(oXml:_Prod:_vSeg:TEXT),15,2)")
cString += NfeTag('<vDesc>' ,"ConvType(Val(oXml:_Prod:_vDesc:TEXT),15,2)")
cString += NfeTag('<vOutro>' ,"ConvType(Val(oXml:_Prod:_vOutro:TEXT),15,2)")
cString += '<indTot>'+oDet:_Prod:_indTot:TEXT+'</indTot>'
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a tag de DI                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("oXml:_Prod:_DI")<>"U" 
	If ValType(oXml:_Prod:_DI)=="A"
		aDI := oXml:_Prod:_DI
	Else
		aDI := {oXml:_Prod:_DI}
	EndIf
	If ValType(oXml:_Prod:_DI:_adicao)=="A"
		aAdi := oXml:_Prod:_DI:_adicao
	Else
		aAdi := {oXml:_Prod:_DI:_adicao}
	EndIf
	For nDi := 1 To Len(aDI)	
		cString += '<DI>'
		cString += '<nDI>' +aDI[nDI]:_ndi:TEXT+'</nDI>'
		cString += '<dDI>' +aDI[nDI]:_dtdi:TEXT+'</dDI>'
		cString += '<xLocDesemb>' +aDI[nDI]:_LocDesemb:TEXT+'</xLocDesemb>'
		cString += '<UFDesemb>' +aDI[nDI]:_UFDesemb:TEXT+'</UFDesemb>'
		cString += '<dDesemb>' +aDI[nDI]:_dtDesemb:TEXT+'</dDesemb>'
		If cVersao >= "3.10"
			cString += '<tpViaTransp>' + ConvType(aDI[nDI]:_viaTransp:TEXT,2) + '</tpViaTransp>'			
			If Val( aDI[nDI]:_viaTransp:TEXT ) == 1	// Via de Transporte Maritima
				If Type( "aDI["+cValToChar(nDI)+"]:_AFRMM:TEXT" ) <> "U" .And. Val(aDI[nDI]:_AFRMM:TEXT) > 0
					cString += '<vAFRMM>' + ConvType(Val(aDI[nDI]:_AFRMM:TEXT),15,2) + '</vAFRMM>'
				Else
					cString += '<vAFRMM>0</vAFRMM>'
				Endif
			Else
				cString +=  NfeTag('<vAFRMM>',"ConvType(Val(aDI["+Alltrim(Str(nDI))+"]:_AFRMM:TEXT),15,2)")
			Endif
			cString += '<tpIntermedio>' + ConvType(aDI[nDI]:_Intermedio:TEXT,2) + '</tpIntermedio>'
			cString +=  NfeTag('<CNPJ>',"ConvType(aDI["+Alltrim(Str(nDI))+"]:_CNPJ:TEXT,14)")
			cString +=  NfeTag('<UFTerceiro>',"ConvType(aDI["+Alltrim(Str(nDI))+"]:_UFTerceiro:TEXT,2)")
		EndIf
		cString += '<cExportador>' +aDI[nDI]:_Exportador:TEXT+'</cExportador>'
		For nAdi := 1 To Len(aAdi)
			cString += '<adi>'
			cString += '<nAdicao>' +aAdi[nAdi]:_Adicao:TEXT+'</nAdicao>'
			cString += '<nSeqAdic>' +aAdi[nAdi]:_SeqAdic:TEXT+'</nSeqAdic>'
			cString += '<cFabricante>' +aAdi[nAdi]:_Fabricante:TEXT+'</cFabricante>'
			cString += NfeTag('<vDescDI>' ,"ConvType(Val(aAdi[nAdi]:_vDescDI:TEXT),15,2)")
			If cVersao >= "3.10"
				cString += NfeTag('<nDraw>' ,"ConvType(aAdi["+Alltrim(Str(nAdi))+"]:_Draw:TEXT,11)")
			EndIf
			cString += '</adi>'
		Next nAdi
		cString += '</DI>'
	Next nDi
EndIf 
If cVersao >= "3.10"
	If Type("oXml:_Prod:_detExport")<>"U" 
		If ValType(oXml:_Prod:_detExport)=="A"
			aDetExport := oXml:_Prod:_detExport
		Else
			aDetExport := {oXml:_Prod:_detExport}
		EndIf



		For nDetExp := 1 To Len(aDetExport)
			cString += '<detExport>'
			cString += NfeTag('<nDraw>' ,"ConvType(aDetExport["+Alltrim(Str(nDetExp))+"]:_Draw:TEXT,11)")
			
			If Type("oXml:_Prod:_detExport:_exportInd")<>"U"
				oExpInd := oXml:_Prod:_detExport:_exportInd
				cString += '<exportInd>'
				cString += '<nRE>' + ConvType(oExpInd:_nre:TEXT,12) + '</nRE>'
				cString += '<chNFe>' + ConvType(oExpInd:_chNFe:TEXT,44) + '</chNFe>'
				cString += '<qExport>' + ConvType(Val(oExpInd:_qExport:TEXT),15,4) + '</qExport>'
				cString += '</exportInd>'
			ElseIf Type("oXml:_Prod:_detExport["+Alltrim(Str(nDetExp))+"]:_exportInd")<>"U"
				oExpInd := oXml:_Prod:_detExport[nDetExp]:_exportInd
				cString += '<exportInd>'
				cString += '<nRE>' + ConvType(oExpInd:_nre:TEXT,12) + '</nRE>'
				cString += '<chNFe>' + ConvType(oExpInd:_chNFe:TEXT,44) + '</chNFe>'
				cString += '<qExport>' + ConvType(Val(oExpInd:_qExport:TEXT),15,4) + '</qExport>'
				cString += '</exportInd>'
			EndIf
			
			cString +=	'</detExport>'
		Next nDetExp
	EndIf
	
EndIf
If Type("oXml:_Prod:_xPed:TEXT")<>"U"
	cString+= '<xPed>'+oXml:_Prod:_xPed:TEXT+'</xPed>'
EndIf
If Type("oXml:_Prod:_nItemPed:TEXT")<>"U"
	cString+= '<nItemPed>'+oXml:_Prod:_nItemPed:TEXT+'</nItemPed>'
EndIf

If Type("oXml:_Prod:_nFCI:TEXT")<>"U"
	cString+= '<nFCI>'+oXml:_Prod:_nFCI:TEXT+'</nFCI>'
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta da tag de Veiculos Novos                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("oXml:_Prod:_veicProd")<>"U" 
	If 	ValType(oXml:_Prod:_veicProd)=="A"
		aveicProd := oXml:_Prod:_veicProd
	Else
		aveicProd := {oXml:_Prod:_veicProd}
	EndIf
	For nveicProd := 1 To Len(aveicProd)
		nY := nveicProd
		cString += '<veicProd>'
		cString += NfeTag('<tpOp>'   ,"convtype(aVeicProd[nY]:_tpOp:TEXT,1)"   ,.T.)
		cString += NfeTag('<chassi>' ,"convtype(aVeicProd[nY]:_chassi:TEXT,17)",.T.)
		cString += NfeTag('<cCor>'   ,"convtype(aVeicProd[nY]:_cCor:TEXT,4)"   ,.T.)
		cString += NfeTag('<xCor>'   ,"convtype(aVeicProd[nY]:_xCor:TEXT,40)"  ,.T.)
		cString += NfeTag('<pot>'    ,"convtype(aVeicProd[nY]:_pot:TEXT,4)"    ,.T.)
		cString += NfeTag('<cilin>'    ,"convtype(aVeicProd[nY]:_cilin:TEXT,4)"    ,.T.)
		cString += NfeTag('<pesoL>'  ,"convtype(aVeicProd[nY]:_pesol:TEXT,9)"  ,.T.)
		cString += NfeTag('<pesoB>'  ,"convtype(aVeicProd[nY]:_pesob:TEXT,9)"  ,.T.)
		cString += NfeTag('<nSerie>' ,"convtype(aVeicProd[nY]:_nserie:TEXT,9)" ,.T.)
		cString += NfeTag('<tpComb>' ,"convtype(aVeicProd[nY]:_tpcomb:TEXT,2)" ,.T.)
		cString += NfeTag('<nMotor>' ,"convtype(aVeicProd[nY]:_nmotor:TEXT,21)",.T.)
		cString += NfeTag('<CMT>'   ,"convtype(aVeicProd[nY]:_CMT:TEXT,9)"   ,.T.)
		cString += NfeTag('<dist>'   ,"convtype(aVeicProd[nY]:_dist:TEXT,4)"   ,.T.)
		If Type("aVeicProd[nY]:_renavam")<>"U"
			cString += NfeTag('<RENAVAM>',"convtype(aVeicProd[nY]:_renavam:TEXT,9)",.T.)
		EndIf
		cString += NfeTag('<anoMod>' ,"convtype(aVeicProd[nY]:_anomod:TEXT,4)" ,.T.)
		cString += NfeTag('<anoFab>' ,"convtype(aVeicProd[nY]:_anofab:TEXT,4)" ,.T.)
		cString += NfeTag('<tpPint>' ,"convtype(aVeicProd[nY]:_tppint:TEXT,1)" ,.T.)
		cString += NfeTag('<tpVeic>' ,"convtype(aVeicProd[nY]:_tpveic:TEXT,2)" ,.T.)
		cString += NfeTag('<espVeic>',"convtype(aVeicProd[nY]:_espvei:TEXT,1)" ,.T.)
		cString += NfeTag('<VIN>'    ,"convtype(aVeicProd[nY]:_vin:TEXT,1)"    ,.T.)
		cString += NfeTag('<condVeic>',"convtype(aVeicProd[nY]:_condvei:TEXT,1)",.T.)
		cString += NfeTag('<cMod>'   ,"convtype(aVeicProd[nY]:_cmod:TEXT,6)"   ,.T.)
		cString += NfeTag('<cCorDENATRAN>'   ,"convtype(aVeicProd[nY]:_cCorDENATRAN:TEXT,2)"   ,.T.)
		cString += '<lota>'+aVeicProd[nY]:_lota:TEXT+'</lota>'
		cString += NfeTag('<tpRest>'   ,"convtype(aVeicProd[nY]:_tpRest:TEXT,1)"   ,.T.)
		cString += '</veicProd>'
	Next nveicProd
EndIf 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta da tag de medicamentos                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("oXml:_Prod:_med")<>"U" 
	If 	ValType(oXml:_Prod:_med)=="A"
		aMed := oXml:_Prod:_med
	Else
		aMed := {oXml:_Prod:_med}
	EndIf
	For nMed := 1 To Len(aMed)
		nY := nMed
		cString += '<med>'
		cString += NfeTag('<nLote>',"convtype(aMed[nY]:_lote:TEXT,20)",.T.)
		cString += NfeTag('<qLote>',"convtype(val(aMed[nY]:_qlote:TEXT),11,3)",.T.)	
		cString += NfeTag('<dFab>' ,"convtype(aMed[nY]:_dtfab:TEXT)",.T.)	
		cString += NfeTag('<dVal>' ,"convtype(aMed[nY]:_dtval:TEXT)",.T.)		
		cString += NfeTag('<vPMC>' ,"convtype(val(aMed[nY]:_vpmc:TEXT),15,2)",.T.)
		cString += '</med>'
	Next nMed
EndIf 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta da tag de armamentos                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("oXml:_Prod:_arma")<>"U" 
	If 	ValType(oXml:_Prod:_arma)=="A"
		aArma := oXml:_Prod:_arma
	Else
		aArma := {oXml:_Prod:_arma}
	EndIf
	For nArma := 1 To Len(aArma)
		nY := nArma
		cString += '<arma>'
		cString += NfeTag('<tpArma>',"convtype(aArma[nY]:_tpArma:TEXT)",.T.)
		cString += NfeTag('<nSerie>',"convtype(aArma[nY]:_nSerie:TEXT)",.T.)	
		cString += NfeTag('<nCano>' ,"convtype(aArma[nY]:_nCano:TEXT)",.T.)	
		cString += NfeTag('<descr>' ,"convtype(aArma[nY]:_descr:TEXT)",.T.)		
		cString += '</arma>'
	Next nArma
EndIf  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta da tag de combustiveis                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("oXml:_Prod:_comb")<>"U" 
	cString += '<comb>'
	cString += NfeTag('<cProdANP>',"oXml:_Prod:_comb:_cProdANP:TEXT")
	If cVersao >= "3.10"
		cString += NfeTag('<pMixGN>',"ConvType(Val(oXml:_Prod:_comb:_mixGn:TEXT),6,4)")
	EndIf
	cString += NfeTag('<CODIF>',"oXml:_Prod:_comb:_CODIF:TEXT")	
	cString += NfeTag('<qTemp>',"oXml:_Prod:_comb:_qTemp:TEXT")
	If Type("oXml:_Prod:_comb:_ICMSCons:_UFCons:TEXT") <> "U"
		cString += '<UFCons>'+oXml:_Prod:_comb:_ICMSCons:_UFCons:TEXT+'</UFCons>'
	EndIf	
	If Type("oXml:_Prod:_comb:_CIDE")<>"U" 
		cString += '<CIDE>'
		cString += '<qBCProd>' +ConvType(Val(oXml:_Prod:_comb:_CIDE:_qBCProd:TEXT),16,4)+'</qBCProd>'
		cString += '<vAliqProd>'+ConvType(Val(oXml:_Prod:_comb:_CIDE:_vAliqProd:TEXT),15,4)+'</vAliqProd>'
		cString += '<vCIDE>'+ConvType(Val(oXml:_Prod:_comb:_CIDE:_vCIDE:TEXT),15,2)+'</vCIDE>'
		cString += '</CIDE>'
	EndIf
	//Novo Grupo NT2015/002
	If Type("oXml:_Prod:_comb:_encerrante") <> "U"
		cString += '<encerrante>'
		cString += '<nBico>'+oXml:_Prod:_comb:_encerrante:_nBico:TEXT+'</nBico>'
		cString += NfeTag('<nBomba>',"oXml:_Prod:_comb:_encerrante:_nBomba:TEXT")
		cString += '<nTanque>'+oXml:_Prod:_comb:_encerrante:_nTanque:TEXT+'</nTanque>'
		cString += '<vEncIni>'+ConvType(Val(oXml:_Prod:_comb:_encerrante:_vEncIni:TEXT),15,3)+'</vEncIni>'
		cString += '<vEncFin>'+ConvType(Val(oXml:_Prod:_comb:_encerrante:_vEncFin:TEXT),15,3)+'</vEncFin>'
		cString += '</encerrante>'		
	EndIf
	cString += '</comb>'
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta da tag de RECOPI                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cVersao >= "3.10" .And. Type("oXml:_Prod:_RECOPI:_nrecopi")<>"U"
	cString += '<nRECOPI>' + ConvType(oXml:_Prod:_RECOPI:_nrecopi:TEXT) + '</nRECOPI>'
EndIf

cString += '</prod>'                                        
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a tag de impostos                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cString += '<imposto>'
cString += NfeTag('<vTotTrib>' ,"ConvType(Val(oXml:_Prod:_vTotTrib:TEXT),15,2)")
If ValType(oXml:_Imposto)=="A"
	aImposto := oXml:_Imposto
Else
	aImposto := {oXml:_Imposto}
EndIf
//--------------------------------------------------------------------------
// Atribui os totais
//--------------------------------------------------------------------------
If oDet:_Prod:_indTot:TEXT == "1" 

	nX := Ascan(aImposto,{|o| o:_Codigo:TEXT == "ISS"})
   	
   	If nX > 0 .And. cVersao >= "3.10" .And. cNFMod == "65" 
   		aTot[1] += 0
   	Else
	   	aTot[1] += Val(oDet:_Prod:_vProd:TEXT)
	Endif

EndIf

aTot[2] += Val(IIf(Type("oXml:_Prod:_vFrete:TEXT")=="U","0",oDet:_Prod:_vFrete:TEXT))
aTot[3] += Val(IIf(Type("oXml:_Prod:_vSeg:TEXT")  =="U","0",oDet:_Prod:_vSeg:TEXT))
aTot[4] += Val(IIf(Type("oXml:_Prod:_vDesc:TEXT") =="U","0",oDet:_Prod:_vDesc:TEXT))
aTot[5] += Val(IIf(Type("oXml:_Prod:_vTotTrib:TEXT") =="U","0",oDet:_Prod:_vTotTrib:TEXT))
nX := Ascan(aImposto,{|o| o:_Codigo:TEXT == "ICMS"})
If nX > 0
	nY := aScan(aImposto,{|x| x:_codigo:TEXT == "ICMSST"})
	aImposto[nX]:_Tributo:_CST:TEXT := Alltrim( aImposto[nX]:_Tributo:_CST:TEXT )
	cGrupo  := aImposto[nX]:_Tributo:_CST:TEXT
	If cGrupo $ "40,41,50"
		cGrupo := "40"
	EndIf
	cString += '<ICMS>'
	cString += '<ICMS'    +cGrupo+'>'
	cString += '<orig>'   +aImposto[nX]:_Cpl:_orig:TEXT+'</orig>'
	cString += '<CST>'    +aImposto[nX]:_Tributo:_CST:TEXT+'</CST>'
	If aImposto[nX]:_Tributo:_CST:TEXT$"00,10,20,70,90" .Or. (aImposto[nX]:_Tributo:_CST:TEXT == "51")
		If 	NfeDifSefaz( aImposto, cVersao, nX )
			cString += '<modBC>'  +aImposto[nX]:_Tributo:_MODBC:TEXT+'</modBC>'
		EndIf
	EndIf
	If aImposto[nX]:_Tributo:_CST:TEXT$"00,10"
		cString += '<vBC>'    +ConvType(Val(aImposto[nX]:_Tributo:_vBC:TEXT),15,2)+'</vBC>'

	ElseIf aImposto[nX]:_Tributo:_CST:TEXT$"20,70" .Or. (aImposto[nX]:_Tributo:_CST:TEXT == "51")
		If cVersao >= "3.10"
			If NfeDifSefaz( aImposto, cVersao, nX )
				If aImposto[nX]:_Tributo:_CST:TEXT$"70" .And. Type("aImposto[nX]:_Tributo:_PREDBC") <> "U"
					cString += NfeTag('<pRedBC>',"ConvType(Val(aImposto[nX]:_Tributo:_PREDBC:TEXT),7,4)",.T.)
				Else
					cString += NfeTag('<pRedBC>',"ConvType(Val(aImposto[nX]:_Tributo:_PREDBC:TEXT),7,4)")
				EndIf
			EndIf
		Else
			cString += NfeTag('<pRedBC>',"ConvType(Val(aImposto[nX]:_Tributo:_PREDBC:TEXT),6,2)")
		EndIf
		If 	NfeDifSefaz( aImposto, cVersao, nX )
			cString += '<vBC>'    +ConvType(Val(aImposto[nX]:_Tributo:_vBC:TEXT),15,2)+'</vBC>'
		EndIf

	ElseIf aImposto[nX]:_Tributo:_CST:TEXT$"90"
		cString += '<vBC>'    +ConvType(Val(aImposto[nX]:_Tributo:_vBC:TEXT),15,2)+'</vBC>'
		If cVersao >= "3.10"
			cString += NfeTag('<pRedBC>',"ConvType(Val(aImposto[nX]:_Tributo:_PREDBC:TEXT),7,4)")
		Else
			cString += NfeTag('<pRedBC>',"ConvType(Val(aImposto[nX]:_Tributo:_PREDBC:TEXT),6,2)")
		EndIf
	EndIf		 

	If aImposto[nX]:_Tributo:_CST:TEXT$"00,10,20,70,90" .Or. (aImposto[nX]:_Tributo:_CST:TEXT == "51")		
		If cVersao >= "3.10" 		
			If NfeDifSefaz( aImposto, cVersao, nX )
				cString += '<pICMS>'  +ConvType(Val(aImposto[nX]:_Tributo:_Aliquota:TEXT),7,4)+'</pICMS>'
				If aImposto[nX]:_Tributo:_CST:TEXT == "51"
					//Colocar UFs que necessitam que sejam geradas as tags mesmo sem valor 
					if GetUFCode(Upper(Left(LTrim(SM0->M0_ESTENT),2))) $ "41" //PR
						cString += NfeTag('<vICMSOp>',"ConvType(Val(aImposto[nX]:_Tributo:_vICMSOp:TEXT),15,2)",.T.)	
						cString += NfeTag('<pDif>',"ConvType(Val(aImposto[nX]:_Tributo:_pDif:TEXT),8,4)",.T.)
						cString += NfeTag('<vICMSDif>',"ConvType(Val(aImposto[nX]:_Tributo:_vICMSDif:TEXT),15,2)",.T.)
					else
						cString += NfeTag('<vICMSOp>',"ConvType(Val(aImposto[nX]:_Tributo:_vICMSOp:TEXT),15,2)",.F.)	
						cString += NfeTag('<pDif>',"ConvType(Val(aImposto[nX]:_Tributo:_pDif:TEXT),8,4)",.F.)
						cString += NfeTag('<vICMSDif>',"ConvType(Val(aImposto[nX]:_Tributo:_vICMSDif:TEXT),15,2)",.F.)
					endif	
				EndIf
			EndIf
		Else
			cString += '<pICMS>'  +ConvType(Val(aImposto[nX]:_Tributo:_Aliquota:TEXT),6,2)+'</pICMS>'
		EndIf
		
		/*Na versão 3.10, para CST=51, O Valor do ICMS(vICMS) deve ser a diferença do Valor do ICMS da Operação (vICMSOp) e o Valor do ICMS diferido (vICMSDif),
		para não apresentar a rejeição 353-Valor do ICMS no CST=51 não corresponde a diferença do ICMS operação e ICMS diferido*/
		If NfeDifSefaz( aImposto, cVersao, nX )
			cString += '<vICMS>'  +ConvType(Val(aImposto[nX]:_Tributo:_Valor:TEXT),15,2)+'</vICMS>'
		EndIf
		If aImposto[nX]:_Tributo:_CST:TEXT$"20" .And. cVersao >= "3.10"
			cString += NfeTag('<vICMSDeson>' ,"ConvType(Val(aImposto[nX]:_Tributo:_vICMSDeson:TEXT),15,2)")
			cString += NfeTag('<motDesICMS>' ,"aImposto[nX]:_Tributo:_motDesICMS:TEXT")
			aImp[1][3] += Val(IIf(Type("aImposto[nX]:_Tributo:_vICMSDeson:TEXT")=="U","0",aImposto[nX]:_Tributo:_vICMSDeson:TEXT))	
		EndIf

		If aImposto[nX]:_Tributo:_CST:TEXT <> "51"
			If 	NfeDifSefaz( aImposto, cVersao, nX )
				aImp[1][1] += Val(IIf(Type("aImposto[nX]:_Tributo:_vBC:TEXT")  =="U","0",aImposto[nX]:_Tributo:_vBC:TEXT))
				aImp[1][2] += Val(IIf(Type("aImposto[nX]:_Tributo:_valor:TEXT")=="U","0",aImposto[nX]:_Tributo:_valor:TEXT))
			EndIf		
		Else
			If cVersao >= "3.10"
				aImp[1][1] += Val(IIf(Type("aImposto[nX]:_Tributo:_vBC:TEXT")  =="U","0",aImposto[nX]:_Tributo:_vBC:TEXT))
				/*Nesta versão, a tag vICMS no grupo de totais deve ser gerada quando a tag vICMSDif estiver preenchida
				para não apresentar a rejeição 532-Total do ICMS difere do somatório dos itens*/
				If Type("aImposto[nX]:_Tributo:_vICMSDif:TEXT") <> "U" .and. !Empty(aImposto[nX]:_Tributo:_vICMSDif:TEXT)						
					aImp[1][2] += Val(IIf(Type("aImposto[nX]:_Tributo:_valor:TEXT")=="U","0",aImposto[nX]:_Tributo:_valor:TEXT))
				EndIf
			EndIf
		EndIf

	EndIf
	If aImposto[nX]:_Tributo:_CST:TEXT$"40,41,50"
		// Alterado o nome da tag vICMS para vICMSDeson no leiaute 3.10 para este grupo de tributação
		If cVersao >= "3.10"
			// Nota Tecnica 2013/005 - "Se informado tag:motDesICMS, o vICMSDeson deve ser maior do que zero"
			If Type( "aImposto[nX]:_Tributo:_motDesICMS:TEXT" ) <> "U" .And. !Empty( aImposto[nX]:_Tributo:_motDesICMS:TEXT )
				nICMSDeson := Val(IIf(Type("aImposto[nX]:_Tributo:_Valor:TEXT")=="U","0",aImposto[nX]:_Tributo:_Valor:TEXT))

				If nICMSDeson > 0
					aImp[1][3]	+= nICMSDeson
					cString 	+= NfeTag('<vICMSDeson>',"ConvType(Val(aImposto[nX]:_Tributo:_Valor:TEXT),15,2)")
					cString 	+= NfeTag('<motDesICMS>',"aImposto[nX]:_Tributo:_motDesICMS:TEXT")
				Endif
			Endif
		Else
			cString += NfeTag('<vICMS>',"ConvType(Val(aImposto[nX]:_Tributo:_Valor:TEXT),15,2)")
			cString += NfeTag('<motDesICMS>',"aImposto[nX]:_Tributo:_motDesICMS:TEXT")
		EndIf					
	EndIf
	If aImposto[nX]:_Tributo:_CST:TEXT$"10,30,70" .And. nY > 0
		cString += '<modBCST>'+aImposto[nY]:_Tributo:_MODBC:TEXT+'</modBCST>'
		If cVersao >= "3.10"
			cString += NfeTag('<pMVAST>'  ,"ConvType(Val(aImposto[nY]:_Cpl:_PMVAST:TEXT),8,4)")
			cString += NfeTag('<pRedBCST>',"ConvType(Val(aImposto[nY]:_Tributo:_PREDBC:TEXT),7,4)")
		Else
			cString += NfeTag('<pMVAST>'  ,"ConvType(Val(aImposto[nY]:_Cpl:_PMVAST:TEXT),6,2)")
			cString += NfeTag('<pRedBCST>',"ConvType(Val(aImposto[nY]:_Tributo:_PREDBC:TEXT),6,2)")
		EndIf		
	EndIf
	If aImposto[nX]:_Tributo:_CST:TEXT$"10,30,60,70" .And. nY > 0
		If aImposto[nX]:_Tributo:_CST:TEXT$"60"
			If Type("aImposto[nY]:_Tributo:_vBC:TEXT") <> "U"
				cString +=  '<vBCSTRet>' + ConvType(Val(aImposto[nY]:_Tributo:_vBC:TEXT),15,2) + '</vBCSTRet>'           			
			EndIF	
		Else	
			cString += '<vBCST>'  +ConvType(Val(aImposto[nY]:_Tributo:_vBC:TEXT),15,2)+'</vBCST>'
		EndIf	
	EndIf
	If aImposto[nX]:_Tributo:_CST:TEXT$"10,30,70" .And. nY > 0
		If cVersao >= "3.10"
			cString += '<pICMSST>'+ConvType(Val(aImposto[nY]:_Tributo:_Aliquota:TEXT),7,4)+'</pICMSST>'
		Else
			cString += '<pICMSST>'+ConvType(Val(aImposto[nY]:_Tributo:_Aliquota:TEXT),6,2)+'</pICMSST>'
		EndIf

		aImp[2][1] += Val(IIf(Type("aImposto[nY]:_Tributo:_vBC:TEXT")  =="U","0",aImposto[nY]:_Tributo:_vBC:TEXT))
		aImp[2][2] += Val(IIf(Type("aImposto[nY]:_Tributo:_valor:TEXT")=="U","0",aImposto[nY]:_Tributo:_valor:TEXT))		
	EndIf
	If aImposto[nX]:_Tributo:_CST:TEXT$"10,30,60,70" .And. nY > 0
		If aImposto[nX]:_Tributo:_CST:TEXT$"60"
			If Type("aImposto[nY]:_Tributo:_valor:TEXT") <> "U"
				cString += '<vICMSSTRet>'+ConvType(Val(aImposto[nY]:_Tributo:_valor:TEXT),15,2)+'</vICMSSTRet>'
			EndIF	
		Else
			cString += '<vICMSST>'+ConvType(Val(aImposto[nY]:_Tributo:_valor:TEXT),15,2)+'</vICMSST>'
			If aImposto[nX]:_Tributo:_CST:TEXT$"30" .And. cVersao >= "3.10"
				cString += NfeTag('<vICMSDeson>' ,"ConvType(Val(aImposto[nY]:_Tributo:_vICMSDeson:TEXT),15,2)")
				cString += NfeTag('<motDesICMS>' ,"aImposto[nY]:_Tributo:_motDesICMS:TEXT")
				aImp[1][3] += Val(IIf(Type("aImposto[nY]:_Tributo:_vICMSDeson:TEXT")=="U","0",aImposto[nY]:_Tributo:_vICMSDeson:TEXT))
			EndIf			
		EndIf	
	EndIf
	/*Chamado TUMGKU 
	Só montar as tags do ICMS ST do grupo ICMS90 quando realmente possuir valores de ICMS ST.
	Alteração realizada pelo fato da Sefaz MG rejeitar a nota com "806-Operação com ICMS-ST 
	sem informação do CEST" para uma NFe com CST90 sem ICMS ST.
	
	De acordo com uma das regras de validação desta rejeição o CEST é obrigatório 
	quando possuir a tag vICMSST do grupo 90*/
	If aImposto[nX]:_Tributo:_CST:TEXT$"90"  .And. nY > 0
		If (Val(aImposto[nY]:_Tributo:_vBC:TEXT) > 0 .or. Val(aImposto[nY]:_Tributo:_Aliquota:TEXT) > 0 .or. Val(aImposto[nY]:_Tributo:_valor:TEXT) > 0)
			cString += '<modBCST>'+aImposto[nY]:_Tributo:_MODBC:TEXT+'</modBCST>'
			cString += NfeTag('<pMVAST>'  ,"ConvType(Val(aImposto[nY]:_Cpl:_PMVAST:TEXT),8,4)")
			cString += NfeTag('<pRedBCST>',"ConvType(Val(aImposto[nY]:_Tributo:_PREDBC:TEXT),7,4)")
			cString += '<vBCST>'  +ConvType(Val(aImposto[nY]:_Tributo:_vBC:TEXT),15,2)+'</vBCST>'
			cString += '<pICMSST>'+ConvType(Val(aImposto[nY]:_Tributo:_Aliquota:TEXT),7,4)+'</pICMSST>'
			cString += '<vICMSST>'+ConvType(Val(aImposto[nY]:_Tributo:_valor:TEXT),15,2)+'</vICMSST>'
			
			aImp[2][1] += Val(IIf(Type("aImposto[nY]:_Tributo:_vBC:TEXT")  =="U","0",aImposto[nY]:_Tributo:_vBC:TEXT))
			aImp[2][2] += Val(IIf(Type("aImposto[nY]:_Tributo:_valor:TEXT")=="U","0",aImposto[nY]:_Tributo:_valor:TEXT))
		EndIf
	EndIf
	If aImposto[nX]:_Tributo:_CST:TEXT$"70,90" .And. cVersao >= "3.10"
		cString += NfeTag('<vICMSDeson>' ,"ConvType(Val(aImposto[nX]:_Tributo:_vICMSDeson:TEXT),15,2)")
		cString += NfeTag('<motDesICMS>' ,"aImposto[nX]:_Tributo:_motDesICMS:TEXT")
		aImp[1][3] += Val(IIf(Type("aImposto[nX]:_Tributo:_vICMSDeson:TEXT")=="U","0",aImposto[nX]:_Tributo:_vICMSDeson:TEXT))	
	EndIf
	cString += '</ICMS'+cGrupo+'>'
	cString += '</ICMS>'
EndIf                          

nX := aScan(aImposto,{|x| x:_codigo:TEXT == "ICMSPART"})
If  nX > 0
	aImposto[nX]:_Tributo:_CST:TEXT := Alltrim( aImposto[nX]:_Tributo:_CST:TEXT )
	If aImposto[nX]:_Tributo:_CST:TEXT$"10,90"
		cString += '<ICMS>'
		cString += '<ICMSPart>'
		cString += '<orig>'   +aImposto[nX]:_Cpl:_orig:TEXT+'</orig>'
		cString += '<CST>'    +aImposto[nX]:_Tributo:_CST:TEXT+'</CST>'
		cString += '<modBC>'  +aImposto[nX]:_Tributo:_MODBC:TEXT+'</modBC>'               
		cString += '<vBC>'    +ConvType(Val(aImposto[nX]:_Tributo:_vBC:TEXT),15,2)+'</vBC>'		
		If cVersao >= "3.10"
			cString += NfeTag('<pRedBC>',"ConvType(Val(aImposto[nX]:_Tributo:_PREDBC:TEXT),7,4)")		
			cString += '<pICMS>'  +ConvType(Val(aImposto[nX]:_Tributo:_Aliquota:TEXT),7,4)+'</pICMS>'
		Else
			cString += NfeTag('<pRedBC>',"ConvType(Val(aImposto[nX]:_Tributo:_PREDBC:TEXT),6,2)")
			cString += '<pICMS>'  +ConvType(Val(aImposto[nX]:_Tributo:_Aliquota:TEXT),6,2)+'</pICMS>'
		EndIf
		cString += '<vICMS>'  +ConvType(Val(aImposto[nX]:_Tributo:_Valor:TEXT),15,2)+'</vICMS>'
		cString += '<modBCST>'+aImposto[nX]:_Tributo:_MODBCST:TEXT+'</modBCST>'
		If cVersao >= "3.10"
			cString += NfeTag('<pMVAST>'  ,"ConvType(Val(aImposto[nX]:_Cpl:_PMVAST:TEXT),8,4)")
			cString += NfeTag('<pRedBCST>',"ConvType(Val(aImposto[nX]:_Tributo:_PREDBCST:TEXT),6,2)")
		Else
			cString += NfeTag('<pMVAST>'  ,"ConvType(Val(aImposto[nX]:_Cpl:_PMVAST:TEXT),6,2)")
			cString += NfeTag('<pRedBCST>',"ConvType(Val(aImposto[nX]:_Tributo:_PREDBCST:TEXT),6,2)")
		EndIf
		cString += '<vBCST>'  +ConvType(Val(aImposto[nX]:_Tributo:_vBCST:TEXT),15,2)+'</vBCST>'
		If cVersao >= "3.10"
			cString += '<pICMSST>'+ConvType(Val(aImposto[nX]:_Tributo:_AliquotaST:TEXT),7,4)+'</pICMSST>'
		Else
			cString += '<pICMSST>'+ConvType(Val(aImposto[nX]:_Tributo:_AliquotaST:TEXT),6,2)+'</pICMSST>'
		EndIf
		cString += '<vICMSST>'+ConvType(Val(aImposto[nX]:_Tributo:_valorST:TEXT),15,2)+'</vICMSST>'
		If cVersao >= "3.10"
			cString += '<pBCOp>'+ConvType(Val(aImposto[nX]:_Tributo:_pBCOp:TEXT),7,4)+'</pBCOp>'
		Else
			cString += '<pBCOp>'+aImposto[nX]:_Tributo:_pBCOp:TEXT+'</pBCOp>'
		EndIf				
		cString += '<UFST>'	+aImposto[nX]:_Tributo:_UFST:TEXT+'</UFST>'						
		cString += '</ICMSPart>'
		cString += '</ICMS>'
		
		aImp[1][1] += Val(IIf(Type("aImposto[nX]:_Tributo:_vBC:TEXT")  =="U","0",aImposto[nX]:_Tributo:_vBC:TEXT))
		aImp[1][2] += Val(IIf(Type("aImposto[nX]:_Tributo:_valor:TEXT")=="U","0",aImposto[nX]:_Tributo:_valor:TEXT))
		
		aImp[2][1] += Val(IIf(Type("aImposto[nX]:_Tributo:_vBCST:TEXT")  =="U","0",aImposto[nX]:_Tributo:_vBCST:TEXT))
		aImp[2][2] += Val(IIf(Type("aImposto[nX]:_Tributo:_valorST:TEXT")=="U","0",aImposto[nX]:_Tributo:_valorST:TEXT))
	Endif	
EndIF

nX := aScan(aImposto,{|x| x:_codigo:TEXT == "ICMSST41"})
If  nX > 0 
	aImposto[nX]:_Tributo:_CST:TEXT := Alltrim( aImposto[nX]:_Tributo:_CST:TEXT )
	If aImposto[nX]:_Tributo:_CST:TEXT$"41"
		cString += '<ICMS>'	 
		cString += '<ICMSST>'
		cString += '<orig>'   +aImposto[nX]:_Cpl:_orig:TEXT+'</orig>'
		cString += '<CST>'    +aImposto[nX]:_Tributo:_CST:TEXT+'</CST>'  
		If Type("aImposto[nX]:_Tributo:_vBC:TEXT") <> "U"
			cString += '<vBCSTRet>'+ConvType(Val(aImposto[nX]:_Tributo:_vBC:TEXT),15,2)+'</vBCSTRet>'
		EndIf	
		If ("aImposto[nX]:_Tributo:_valor:TEXT") <> "U"
			cString += '<vICMSSTRet>'+ConvType(Val(aImposto[nX]:_Tributo:_valor:TEXT),15,2)+'</vICMSSTRet>'
		EndIf			
		cString += '<vBCSTDest>'+ConvType(Val(aImposto[nX]:_Tributo:_vBCSTDest:TEXT),15,2)+'</vBCSTDest>'
		cString += '<vICMSSTDest>'+ConvType(Val(aImposto[nX]:_Tributo:_vICMSSTDest:TEXT),15,2)+'</vICMSSTDest>'					
		cString += '</ICMSST>'
		cString += '</ICMS>'
	Endif
EndIF
nX := aScan(aImposto,{|o| o:_Codigo:TEXT == "ICMSSN"})
If nX > 0
	cGrupo  := aImposto[nX]:_Tributo:_CSOSN:TEXT
	If cGrupo $ "102,103,300,400"
		cGrupo := "102"
	ElseIf cGrupo $ "202,203"
		cGrupo := "202"
	ElseIf cGrupo $ "201"				
		cGrupo := "201"		
	EndIf     
	cString += '<ICMS>'
	cString += '<ICMSSN'  +cGrupo+'>'
	cString += '<orig>'   +aImposto[nX]:_Cpl:_orig:TEXT+'</orig>'
	cString += '<CSOSN>'    +aImposto[nX]:_Tributo:_CSOSN:TEXT+'</CSOSN>'		                       
	If aImposto[nX]:_Tributo:_CSOSN:TEXT$"900"
		If Type("aImposto[nX]:_Tributo:_modBC:TEXT") <> "U"
			cString += '<modBC>'+aImposto[nX]:_Tributo:_modBC:TEXT+'</modBC>'
			cString += '<vBC>'  +ConvType(Val(aImposto[nX]:_Tributo:_vBC:TEXT),15,2)+'</vBC>'
			If cVersao >= "3.10"
				cString += NfeTag('<pRedBC>'  ,"ConvType(Val(aImposto[nX]:_pRedBC:TEXT),7,4)")
				cString += '<pICMS>'+ConvType(Val(aImposto[nX]:_Tributo:_pICMS:TEXT),7,4)+ '</pICMS>'
			Else
				cString += NfeTag('<pRedBC>'  ,"ConvType(Val(aImposto[nX]:_pRedBC:TEXT),6,2)")
				cString += '<pICMS>'+ConvType(Val(aImposto[nX]:_Tributo:_pICMS:TEXT),6,2)+ '</pICMS>'
			EndIf
			cString += '<vICMS>'+ConvType(Val(aImposto[nX]:_Tributo:_vICMS:TEXT),15,2)+'</vICMS>'
		EndIf
   		
   		aImp[1][1] += Val(IIf(Type("aImposto[nX]:_Tributo:_vBC:TEXT")  =="U","0",aImposto[nX]:_Tributo:_vBC:TEXT))
		aImp[1][2] += Val(IIf(Type("aImposto[nX]:_Tributo:_vICMS:TEXT")=="U","0",aImposto[nX]:_Tributo:_vICMS:TEXT))	
		
		If Type("aImposto[nX]:_Tributo:_modBCST:TEXT") <> "U"
			cString += '<modBCST>'+aImposto[nX]:_Tributo:_modBCST:TEXT+'</modBCST>'				
			If cVersao >= "3.10"
				cString += NfeTag('<pMVAST>'  ,"ConvType(Val(aImposto[nX]:_pMVAST:TEXT),8,4)")
				cString += NfeTag('<pRedBCST>'  ,"ConvType(Val(aImposto[nX]:_pRedBCST:TEXT),7,4)")
			Else
				cString += NfeTag('<pMVAST>'  ,"ConvType(Val(aImposto[nX]:_pMVAST:TEXT),6,2)")
				cString += NfeTag('<pRedBCST>'  ,"ConvType(Val(aImposto[nX]:_pRedBCST:TEXT),6,2)")
			EndIf
			cString += '<vBCST>'  +ConvType(Val(aImposto[nX]:_Tributo:_vBCST:TEXT),15,2)+  '</vBCST>'                 
			If cVersao >= "3.10"
				cString += '<pICMSST>'+ConvType(Val(aImposto[nX]:_Tributo:_pICMSST:TEXT),7,4)+ '</pICMSST>' 
			Else               
				cString += '<pICMSST>'+ConvType(Val(aImposto[nX]:_Tributo:_pICMSST:TEXT),6,2)+ '</pICMSST>'
			EndIf
			cString += '<vICMSST>'+ConvType(Val(aImposto[nX]:_Tributo:_vICMSST:TEXT),15,2)+'</vICMSST>'
		EndIf                

   		aImp[2][1] += Val(IIf(Type("aImposto[nX]:_Tributo:_vBCST:TEXT")  =="U","0",aImposto[nX]:_Tributo:_vBCST:TEXT))
		aImp[2][2] += Val(IIf(Type("aImposto[nX]:_Tributo:_vICMSST:TEXT")=="U","0",aImposto[nX]:_Tributo:_vICMSST:TEXT))
		
		If Type("aImposto[nX]:_Tributo:_pCredSN:TEXT") <> "U"
			If cVersao >= "3.10"
				cString += '<pCredSN>'  +ConvType(Val(aImposto[nX]:_Tributo:_pCredSN:TEXT),7,4)+ '</pCredSN>'
			Else
				cString += '<pCredSN>'  +ConvType(Val(aImposto[nX]:_Tributo:_pCredSN:TEXT),6,2)+       '</pCredSN>'
			EndIf
			cString += '<vCredICMSSN>'+ConvType(Val(aImposto[nX]:_Tributo:_vCredICMSSN:TEXT),15,2)+'</vCredICMSSN>'
		EndIf
	EndIf      
	If aImposto[nX]:_Tributo:_CSOSN:TEXT$"201,202,203"
		cString += '<modBCST>'    +aImposto[nX]:_Tributo:_modBCST:TEXT+'</modBCST>'				
		If cVersao >= "3.10"
			cString += NfeTag('<pMVAST>'  ,"ConvType(Val(aImposto[nX]:_pMVAST:TEXT),8,4)")
			cString += NfeTag('<pRedBCST>'  ,"ConvType(Val(aImposto[nX]:_pRedBCST:TEXT),7,4)")
		Else
			cString += NfeTag('<pMVAST>'  ,"ConvType(Val(aImposto[nX]:_pMVAST:TEXT),6,2)")
			cString += NfeTag('<pRedBCST>'  ,"ConvType(Val(aImposto[nX]:_pRedBCST:TEXT),6,2)")
		EndIf
		cString += '<vBCST>'  +ConvType(Val(aImposto[nX]:_Tributo:_vBCST:TEXT),15,2)+  '</vBCST>'                 
		If cVersao >= "3.10"
			cString += '<pICMSST>'+ConvType(Val(aImposto[nX]:_Tributo:_pICMSST:TEXT),7,4)+ '</pICMSST>' 
		Else               
			cString += '<pICMSST>'+ConvType(Val(aImposto[nX]:_Tributo:_pICMSST:TEXT),6,2)+ '</pICMSST>'
		EndIf
		cString += '<vICMSST>'+ConvType(Val(aImposto[nX]:_Tributo:_vICMSST:TEXT),15,2)+'</vICMSST>'                 

   		aImp[2][1] += Val(IIf(Type("aImposto[nX]:_Tributo:_vBCST:TEXT")  =="U","0",aImposto[nX]:_Tributo:_vBCST:TEXT))
		aImp[2][2] += Val(IIf(Type("aImposto[nX]:_Tributo:_vICMSST:TEXT")=="U","0",aImposto[nX]:_Tributo:_vICMSST:TEXT))			
	
	EndIF                                       		
	If aImposto[nX]:_Tributo:_CSOSN:TEXT$"500"
		If Type("aImposto[nX]:_Tributo:_vBCSTRet:TEXT") <> "U"
			cString += '<vBCSTRet>'    +ConvType(Val(aImposto[nX]:_Tributo:_vBCSTRet:TEXT),15,2)+  '</vBCSTRet>'
		EndIf	
		If Type("aImposto[nX]:_Tributo:_vICMSSTRet:TEXT") <> "U"
			cString += '<vICMSSTRet>'  +ConvType(Val(aImposto[nX]:_Tributo:_vICMSSTRet:TEXT),15,2)+'</vICMSSTRet>'
		EndIF	
	EndIF								
	If aImposto[nX]:_Tributo:_CSOSN:TEXT$"101,151,201"
		If cVersao >= "3.10"
			cString += '<pCredSN>'  +ConvType(Val(aImposto[nX]:_Tributo:_pCredSN:TEXT),7,4)+ '</pCredSN>'
		Else
			cString += '<pCredSN>'  +ConvType(Val(aImposto[nX]:_Tributo:_pCredSN:TEXT),6,2)+       '</pCredSN>'
		EndIf
		cString += '<vCredICMSSN>'+ConvType(Val(aImposto[nX]:_Tributo:_vCredICMSSN:TEXT),15,2)+'</vCredICMSSN>'
	EndIF
	cString += '</ICMSSN'+cGrupo+'>'
	cString += '</ICMS>'		 	
EndIf
//Para a versão 3.10 é possível informar no mesmo item 
//a tributação de IPI e ISSQN

nX := Ascan(aImposto,{|o| o:_Codigo:TEXT == "IPI"})
If nX > 0
	aImposto[nX]:_Tributo:_CST:TEXT := Alltrim( aImposto[nX]:_Tributo:_CST:TEXT )
	cString += '<IPI>'
	cString += NfeTag('<clEnq>'   ,"aImposto[nX]:_Cpl:_clEnq:TEXT")
	cString += NfeTag('<CNPJProd>',"aImposto[nX]:_Cpl:_CNPJProd:TEXT")
	cString += NfeTag('<cSelo>'   ,"aImposto[nX]:_Cpl:_cSelo:TEXT")
	cString += NfeTag('<qSelo>'   ,"aImposto[nX]:_Cpl:_qSelo:TEXT")
	If Type("aImposto[nX]:_Cpl:_cEnq:TEXT")=="U"
		cString += '<cEnq>999</cEnq>'
	Else
		cString += '<cEnq>' + aImposto[nX]:_Cpl:_cEnq:TEXT + '</cEnq>'
	EndIf
	If aImposto[nX]:_Tributo:_CST:TEXT$"00,49,50,99"
		cString += '<IPITrib>'
		cString += '<CST>'  +aImposto[nX]:_Tributo:_CST:TEXT+'</CST>'
		If ((Type("aImposto[nX]:_Tributo:_vlTrib:TEXT")<>"U" .And. Val(aImposto[nX]:_Tributo:_vlTrib:TEXT)==0) .Or. Type("aImposto[nX]:_Tributo:_vlTrib:TEXT")=="U"  )
			cString += '<vBC>'  +ConvType(Val(aImposto[nX]:_Tributo:_vBC:TEXT),15,2)+'</vBC>'                                                                          
			If cVersao >= "3.10"
				cString += NfeTag('<pIPI>' ,"ConvType(Val(aImposto[nX]:_Tributo:_Aliquota:TEXT),7,4)",.T.)
			Else
				cString += NfeTag('<pIPI>' ,"ConvType(Val(aImposto[nX]:_Tributo:_Aliquota:TEXT),6,2)",.T.)
			EndIf
		EndIF	
		If (Type("aImposto[nX]:_Tributo:_vlTrib:TEXT")<>"U" .And. Val(aImposto[nX]:_Tributo:_vlTrib:TEXT)>0 .And.;
			(Type("aImposto[nX]:_Tributo:_modBC:TEXT")=="U" .Or. Empty(aImposto[nX]:_Tributo:_modBC:TEXT)) .Or.;
			(Type("aImposto[nX]:_Tributo:_modBC:TEXT")<>"U" .And. AllTrim(aImposto[nX]:_Tributo:_modBC:TEXT)$'12'))
			cString += NfeTag('<qUnid>',"ConvType(Val(aImposto[nX]:_Tributo:_qTrib:TEXT),16,4)")
			cString += NfeTag('<vUnid>',"ConvType(Val(aImposto[nX]:_Tributo:_vlTrib:TEXT),15,4)")
		EndIf
		cString += NfeTag('<vIPI>' ,"ConvType(Val(aImposto[nX]:_Tributo:_valor:TEXT),15,2)",.T.)
		cString += '</IPITrib>'
		
		aImp[3][1] += Val(IIf(Type("aImposto[nX]:_Tributo:_vBC:TEXT")  =="U","0",aImposto[nX]:_Tributo:_vBC:TEXT))
		aImp[3][2] += Val(IIf(Type("aImposto[nX]:_Tributo:_valor:TEXT")=="U","0",aImposto[nX]:_Tributo:_valor:TEXT))	
	Else
		cString += '<IPINT>'
		cString += '<CST>'+aImposto[nX]:_Tributo:_CST:TEXT+'</CST>'
		cString += '</IPINT>'
	EndIf
	cString += '</IPI>'
EndIf
                      
//Para versão 2.00,o grupo ISSQN é mutuamente exclusivo 
//com os grupos ICMS,IPI e II, isto é se ISSQN for
//informado os grupos ICMS, IPI e II não serão informados e viceversa
//Caso o ERP envie as TAGS de ICMS e ISS, as duas serão geradas,
//acusando rejeição de SCHEMA posteriormente.
nX := Ascan(aImposto,{|o| o:_Codigo:TEXT == "ISS"})
If nX > 0 
	cString += '<ISSQN>'
	cString += '<vBC>'      +ConvType(Val(aImposto[nX]:_Tributo:_vBC:TEXT),15,2)+'</vBC>'
	If cVersao >= "3.10"
		cString += '<vAliq>'    +ConvType(Val(aImposto[nX]:_Tributo:_Aliquota:TEXT),7,4)+'</vAliq>'
	Else
		cString += '<vAliq>'    +ConvType(Val(aImposto[nX]:_Tributo:_Aliquota:TEXT),6,2)+'</vAliq>'
	EndIf
	cString += '<vISSQN>'   +ConvType(Val(aImposto[nX]:_Tributo:_Valor:TEXT),15,2)+'</vISSQN>'
	cString += '<cMunFG>'   +aImposto[nX]:_Cpl:_cMunFg:TEXT+'</cMunFG>'
	cString += '<cListServ>'+aImposto[nX]:_Cpl:_cListServ:TEXT+'</cListServ>'
	If cVersao >= "3.10"
		cString += NfeTag('<vDeducao>' ,"ConvType(Val(aImposto[nX]:_Tributo:_deducao:TEXT),15,2)")
		cString += NfeTag('<vOutro>' ,"ConvType(Val(aImposto[nX]:_Tributo:_outro:TEXT),15,2)")
		cString += NfeTag('<vDescIncond>' ,"ConvType(Val(aImposto[nX]:_Tributo:_descIncond:TEXT),15,2)")
		cString += NfeTag('<vDescCond>' ,"ConvType(Val(aImposto[nX]:_Tributo:_descCond:TEXT),15,2)")
		cString += NfeTag('<vISSRet>' ,"ConvType(Val(aImposto[nX]:_Tributo:_ISSRet:TEXT),15,2)")
		If Type("aImposto["+Alltrim(Str(nX))+"]:_Cpl:_indISS:TEXT") <> "U"
			cString += '<indISS>'+aImposto[nX]:_Cpl:_indISS:TEXT+'</indISS>'
		EndIf
		cString += NfeTag('<cServico>' ,"aImposto[nX]:_Cpl:_codserv:TEXT")
		cString += NfeTag('<cMun>' ,"aImposto[nX]:_Cpl:_cmunInc:TEXT")
		cString += NfeTag('<cPais>' ,"aImposto[nX]:_Cpl:_codpais:TEXT")
		cString += NfeTag('<nProcesso>' ,"aImposto[nX]:_Cpl:_Processo:TEXT")
		If Type("aImposto["+Alltrim(Str(nX))+"]:_Cpl:_incentivo:TEXT") <> "U"
			cString += '<indIncentivo>'+aImposto[nX]:_Cpl:_incentivo:TEXT+'</indIncentivo>'
		EndIf
	Else
		cString += '<cSitTrib>'+aImposto[nX]:_Cpl:_cSitTrib:TEXT+'</cSitTrib>'
	EndIf
	cString += '</ISSQN>'			
EndIf				

nX := Ascan(aImposto,{|o| o:_Codigo:TEXT == "II"})
If nX > 0	
	cString += '<II>'
	cString += '<vBC>'      +ConvType(Val(aImposto[nX]:_Tributo:_vBC:TEXT),15,2)+'</vBC>'
	cString += '<vDespAdu>' +ConvType(Val(aImposto[nX]:_Cpl:_vDespAdu:TEXT),15,2)+'</vDespAdu>'
	cString += '<vII>'      +ConvType(Val(aImposto[nX]:_Tributo:_Valor:TEXT),15,2)+'</vII>'
	cString += '<vIOF>'     +ConvType(Val(aImposto[nX]:_Cpl:_vIOF:TEXT),15,2)+'</vIOF>'
	cString += '</II>'
	
	aImp[4][1] += Val(IIf(Type("aImposto[nX]:_Tributo:_vBC:TEXT")  =="U","0",aImposto[nX]:_Tributo:_vBC:TEXT))
	aImp[4][2] += Val(IIf(Type("aImposto[nX]:_Tributo:_valor:TEXT")=="U","0",aImposto[nX]:_Tributo:_valor:TEXT))
EndIf
nX := Ascan(aImposto,{|o| o:_Codigo:TEXT == "PIS"})
If nX > 0
	lPIS := .T.
	cString += '<PIS>'
	aImposto[nX]:_Tributo:_CST:TEXT := Alltrim( aImposto[nX]:_Tributo:_CST:TEXT )	
	If aImposto[nX]:_Tributo:_CST:TEXT $ "01,02"
		cString += '<PISAliq>'
		cString += '<CST>'    +aImposto[nX]:_Tributo:_CST:TEXT+'</CST>'
		cString += '<vBC>'    +ConvType(Val(aImposto[nX]:_Tributo:_VBC:TEXT),15,2)+'</vBC>'
		If cVersao >= "3.10"
			cString += '<pPIS>'   +ConvType(Val(aImposto[nX]:_Tributo:_Aliquota:TEXT),7,4)+'</pPIS>'
		Else
			cString += '<pPIS>'   +ConvType(Val(aImposto[nX]:_Tributo:_Aliquota:TEXT),6,2)+'</pPIS>'
		EndIf
		cString += '<vPIS>'   +ConvType(Val(aImposto[nX]:_Tributo:_Valor:TEXT),15,2)+'</vPIS>'
		cString += '</PISAliq>'

		If !(oDet:_Prod:_indTot:TEXT == "0")
			aImp[5][1] += Val(IIf(Type("aImposto[nX]:_Tributo:_vBC:TEXT")  =="U","0",aImposto[nX]:_Tributo:_vBC:TEXT))
		   	If Ascan(aImposto,{|o| o:_Codigo:TEXT == "ISS"}) > 0 .And. cVersao >= "3.10" .And. cNFMod == "65"
				aImp[5][2] += 0
			Else
				aImp[5][2] += Val(IIf(Type("aImposto[nX]:_Tributo:_valor:TEXT")=="U","0",aImposto[nX]:_Tributo:_valor:TEXT))
			Endif
		Else
			aImp[10][1] += Val(IIf(Type("aImposto[nX]:_Tributo:_vBC:TEXT")  =="U","0",aImposto[nX]:_Tributo:_vBC:TEXT))
			aImp[10][2] += Val(IIf(Type("aImposto[nX]:_Tributo:_valor:TEXT")=="U","0",aImposto[nX]:_Tributo:_valor:TEXT))		
		EndIf
		nValPis    := Val(IIf(Type("aImposto[nX]:_Tributo:_valor:TEXT")=="U","0",aImposto[nX]:_Tributo:_valor:TEXT))		
	EndIf
	If aImposto[nX]:_Tributo:_CST:TEXT $ "03"
		cString += '<PISQtde>'
		cString += '<CST>'      +aImposto[nX]:_Tributo:_CST:TEXT+'</CST>'
		cString += '<qBCProd>'  +ConvType(Val(aImposto[nX]:_Tributo:_qTrib:TEXT),16,4)+'</qBCProd>'
		cString += '<vAliqProd>'+ConvType(Val(aImposto[nX]:_Tributo:_VlTrib:TEXT),15,4)+'</vAliqProd>'
		cString += '<vPIS>'     +ConvType(Val(aImposto[nX]:_Tributo:_Valor:TEXT),15,2)+'</vPIS>'
		cString += '</PISQtde>'

		aImp[5][1] += Val(IIf(Type("aImposto[nX]:_Tributo:_vBC:TEXT")  =="U","0",aImposto[nX]:_Tributo:_vBC:TEXT))
		aImp[5][2] += Val(IIf(Type("aImposto[nX]:_Tributo:_valor:TEXT")=="U","0",aImposto[nX]:_Tributo:_valor:TEXT))
		nValPis    := Val(IIf(Type("aImposto[nX]:_Tributo:_valor:TEXT")=="U","0",aImposto[nX]:_Tributo:_valor:TEXT))			
	EndIf
	If aImposto[nX]:_Tributo:_CST:TEXT $ "04,06,07,08,09" + IIf( cVersao >= "3.10", ",05", "" )
		cString += '<PISNT>'
		cString += '<CST>'    +aImposto[nX]:_Tributo:_CST:TEXT+'</CST>'
		cString += '</PISNT>'
	EndIf
	If aImposto[nX]:_Tributo:_CST:TEXT $ "99,49,50,51,52,53,54,55,56,60,61,62,63,64,65,66,67,70,71,72,73,74,75,98"
		cString += '<PISOutr>'
		cString += '<CST>'    +aImposto[nX]:_Tributo:_CST:TEXT+'</CST>'
		If (Type("aImposto[nX]:_Tributo:_vlTrib:TEXT")<>"U" .And. Val(aImposto[nX]:_Tributo:_vlTrib:TEXT)>0 .And.;
			(Type("aImposto[nX]:_Tributo:_modBC:TEXT")=="U" .Or. Empty(aImposto[nX]:_Tributo:_modBC:TEXT)) .Or.;
			(Type("aImposto[nX]:_Tributo:_modBC:TEXT")<>"U" .And. AllTrim(aImposto[nX]:_Tributo:_modBC:TEXT)$'12'))				
			cString += '<qBCProd>'  +ConvType(Val(aImposto[nX]:_Tributo:_qTrib:TEXT),16,4)+'</qBCProd>'
			cString += '<vAliqProd>'+ConvType(Val(aImposto[nX]:_Tributo:_vlTrib:TEXT),15,4)+'</vAliqProd>'
		Else
			cString += '<vBC>'      +ConvType(Val(aImposto[nX]:_Tributo:_vBC:TEXT),15,2)+'</vBC>'
			If cVersao >= "3.10"
				cString += '<pPIS>'     +ConvType(Val(aImposto[nX]:_Tributo:_Aliquota:TEXT),7,4)+'</pPIS>'
			Else
				cString += '<pPIS>'     +ConvType(Val(aImposto[nX]:_Tributo:_Aliquota:TEXT),6,2)+'</pPIS>'
			EndIf
		EndIf
		cString += '<vPIS>'   +ConvType(Val(aImposto[nX]:_Tributo:_Valor:TEXT),15,2)+'</vPIS>'
		cString += '</PISOutr>'
		
		aImp[5][1] += Val(IIf(Type("aImposto[nX]:_Tributo:_vBC:TEXT")  =="U","0",aImposto[nX]:_Tributo:_vBC:TEXT))
		aImp[5][2] += Val(IIf(Type("aImposto[nX]:_Tributo:_valor:TEXT")=="U","0",aImposto[nX]:_Tributo:_valor:TEXT))
		nValPis    := Val(IIf(Type("aImposto[nX]:_Tributo:_valor:TEXT")=="U","0",aImposto[nX]:_Tributo:_valor:TEXT))		
	EndIf
	cString += '</PIS>'			
EndIf
If !lPIS
	cString += '<PIS>'
	cString += '<PISNT>'
	cString += '<CST>08</CST>'
	cString += '</PISNT>'
	cString += '</PIS>'
EndIf
nX := Ascan(aImposto,{|o| o:_Codigo:TEXT == "PISST"})
If nX > 0	
	If Val(aImposto[nX]:_Tributo:_Valor:TEXT)<>0
		cString += '<PISST>'
		If (Type("aImposto[nX]:_Tributo:_vlTrib:TEXT")<>"U" .And. Val(aImposto[nX]:_Tributo:_vlTrib:TEXT)>0 .And.;
			(Type("aImposto[nX]:_Tributo:_modBC:TEXT")=="U" .Or. Empty(aImposto[nX]:_Tributo:_modBC:TEXT)) .Or.;
			(Type("aImposto[nX]:_Tributo:_modBC:TEXT")<>"U" .And. AllTrim(aImposto[nX]:_Tributo:_modBC:TEXT)$'12'))				
			cString += '<qBCProd>'  +ConvType(Val(aImposto[nX]:_Tributo:_qTrib:TEXT),16,4)+'</qBCProd>'
			cString += '<vAliqProd>'+ConvType(Val(aImposto[nX]:_Tributo:_vlTrib:TEXT),15,4)+'</vAliqProd>'
		Else
			cString += '<vBC>'    +ConvType(Val(aImposto[nX]:_Tributo:_vBC:TEXT),15,2)+'</vBC>'
			If cVersao >= "3.10"
				cString += '<pPIS>'   +ConvType(Val(aImposto[nX]:_Tributo:_Aliquota:TEXT),7,4)+'</pPIS>'
			Else
				cString += '<pPIS>'   +ConvType(Val(aImposto[nX]:_Tributo:_Aliquota:TEXT),6,2)+'</pPIS>'
			EndIf
		EndIf
		cString += '<vPIS>'+ConvType(Val(aImposto[nX]:_Tributo:_Valor:TEXT),15,2)+'</vPIS>'
		cString += '</PISST>'
		aImp[6][1] += Val(IIf(Type("aImposto[nX]:_Tributo:_vBC:TEXT")  =="U","0",aImposto[nX]:_Tributo:_vBC:TEXT))
		aImp[6][2] += Val(IIf(Type("aImposto[nX]:_Tributo:_valor:TEXT")=="U","0",aImposto[nX]:_Tributo:_valor:TEXT))
	EndIf
EndIf
nX := Ascan(aImposto,{|o| o:_Codigo:TEXT == "COFINS"})
If nX > 0
	lCofins := .T.		
	cString += '<COFINS>'
	aImposto[nX]:_Tributo:_CST:TEXT := Alltrim( aImposto[nX]:_Tributo:_CST:TEXT )	
	If aImposto[nX]:_Tributo:_CST:TEXT $ "01,02"
		cString += '<COFINSAliq>'
		cString += '<CST>'       +aImposto[nX]:_Tributo:_CST:TEXT+'</CST>'
		cString += '<vBC>'       +ConvType(Val(aImposto[nX]:_Tributo:_vBC:TEXT),15,2)+'</vBC>'
		If cVersao >= "3.10"
			cString += '<pCOFINS>'   +ConvType(Val(aImposto[nX]:_Tributo:_Aliquota:TEXT),7,4)+'</pCOFINS>'
		Else
			cString += '<pCOFINS>'   +ConvType(Val(aImposto[nX]:_Tributo:_Aliquota:TEXT),6,2)+'</pCOFINS>'
		EndIf
		cString += '<vCOFINS>'   +ConvType(Val(aImposto[nX]:_Tributo:_Valor:TEXT),15,2)+'</vCOFINS>'
		cString += '</COFINSAliq>'
	
		If !(oDet:_Prod:_indTot:TEXT == "0")
			aImp[7][1] += Val(IIf(Type("aImposto[nX]:_Tributo:_vBC:TEXT")  =="U","0",aImposto[nX]:_Tributo:_vBC:TEXT))
		   	If Ascan(aImposto,{|o| o:_Codigo:TEXT == "ISS"}) > 0 .And. cVersao >= "3.10" .And. cNFMod == "65"
				aImp[7][2] += 0
			Else
				aImp[7][2] += Val(IIf(Type("aImposto[nX]:_Tributo:_valor:TEXT")=="U","0",aImposto[nX]:_Tributo:_valor:TEXT))
			Endif
		Else
			aImp[11][1] += Val(IIf(Type("aImposto[nX]:_Tributo:_vBC:TEXT")  =="U","0",aImposto[nX]:_Tributo:_vBC:TEXT))
			aImp[11][2] += Val(IIf(Type("aImposto[nX]:_Tributo:_valor:TEXT")=="U","0",aImposto[nX]:_Tributo:_valor:TEXT))
		EndIf
		nValCOF    := Val(IIf(Type("aImposto[nX]:_Tributo:_valor:TEXT")=="U","0",aImposto[nX]:_Tributo:_valor:TEXT))
	EndIf
	If aImposto[nX]:_Tributo:_CST:TEXT $ "03"
		cString += '<COFINSQtde>'
		cString += '<CST>'      +aImposto[nX]:_Tributo:_CST:TEXT+'</CST>'
		cString += '<qBCProd>'  +ConvType(Val(aImposto[nX]:_Tributo:_qTrib:TEXT),16,4)+'</qBCProd>'
		cString += '<vAliqProd>'+ConvType(Val(aImposto[nX]:_Tributo:_vlTrib:TEXT),15,4)+'</vAliqProd>'
		cString += '<vCOFINS>'  +ConvType(Val(aImposto[nX]:_Tributo:_Valor:TEXT),15,2)+'</vCOFINS>'
		cString += '</COFINSQtde>'

		aImp[7][1] += Val(IIf(Type("aImposto[nX]:_Tributo:_vBC:TEXT")  =="U","0",aImposto[nX]:_Tributo:_vBC:TEXT))
		aImp[7][2] += Val(IIf(Type("aImposto[nX]:_Tributo:_valor:TEXT")=="U","0",aImposto[nX]:_Tributo:_valor:TEXT))
		nValCOF    := Val(IIf(Type("aImposto[nX]:_Tributo:_valor:TEXT")=="U","0",aImposto[nX]:_Tributo:_valor:TEXT))
	EndIf
	If aImposto[nX]:_Tributo:_CST:TEXT $ "04,06,07,08,09" + IIf( cVersao >= "3.10", ",05", "" )
		cString += '<COFINSNT>'
		cString += '<CST>'    +aImposto[nX]:_Tributo:_CST:TEXT+'</CST>'
		cString += '</COFINSNT>'
	EndIf
	If aImposto[nX]:_Tributo:_CST:TEXT $ "99,49,50,51,52,53,54,55,56,60,61,62,63,64,65,66,67,70,71,72,73,74,75,98"
		cString += '<COFINSOutr>'
		cString += '<CST>'    +aImposto[nX]:_Tributo:_CST:TEXT+'</CST>'		
		If (Type("aImposto[nX]:_Tributo:_vlTrib:TEXT")<>"U" .And. Val(aImposto[nX]:_Tributo:_vlTrib:TEXT)>0 .And.;
			(Type("aImposto[nX]:_Tributo:_modBC:TEXT")=="U" .Or. Empty(aImposto[nX]:_Tributo:_modBC:TEXT)) .Or.;
			(Type("aImposto[nX]:_Tributo:_modBC:TEXT")<>"U" .And. AllTrim(aImposto[nX]:_Tributo:_modBC:TEXT)$'12'))				
			cString += '<qBCProd>'  +ConvType(Val(aImposto[nX]:_Tributo:_qTrib:TEXT),16,4)+'</qBCProd>'
			cString += '<vAliqProd>'+ConvType(Val(aImposto[nX]:_Tributo:_vlTrib:TEXT),15,4)+'</vAliqProd>'
		Else
			cString += '<vBC>'      +ConvType(Val(aImposto[nX]:_Tributo:_vBC:TEXT),15,2)+'</vBC>'
			If cVersao >= "3.10"
				cString += '<pCOFINS>'  +ConvType(Val(aImposto[nX]:_Tributo:_Aliquota:TEXT),7,4)+'</pCOFINS>'
			Else
				cString += '<pCOFINS>'  +ConvType(Val(aImposto[nX]:_Tributo:_Aliquota:TEXT),6,2)+'</pCOFINS>'
			EndIf				
		EndIf
		cString += '<vCOFINS>'   +ConvType(Val(aImposto[nX]:_Tributo:_Valor:TEXT),15,2)+'</vCOFINS>'
		cString += '</COFINSOutr>'

		aImp[7][1] += Val(IIf(Type("aImposto[nX]:_Tributo:_vBC:TEXT")  =="U","0",aImposto[nX]:_Tributo:_vBC:TEXT))
		aImp[7][2] += Val(IIf(Type("aImposto[nX]:_Tributo:_valor:TEXT")=="U","0",aImposto[nX]:_Tributo:_valor:TEXT))
		nValCOF    := Val(IIf(Type("aImposto[nX]:_Tributo:_valor:TEXT")=="U","0",aImposto[nX]:_Tributo:_valor:TEXT))
	EndIf
	cString += '</COFINS>'
EndIf
If !lCofins
	cString += '<COFINS>'
	cString += '<COFINSNT>'
	cString += '<CST>08</CST>'
	cString += '</COFINSNT>'
	cString += '</COFINS>'
EndIf
nX := Ascan(aImposto,{|o| o:_Codigo:TEXT == "COFINSST"})
If nX > 0
	If Val(aImposto[nX]:_Tributo:_Valor:TEXT)<>0
		cString += '<COFINSST>'
		If (Type("aImposto[nX]:_Tributo:_vlTrib:TEXT")<>"U" .And. Val(aImposto[nX]:_Tributo:_vlTrib:TEXT)>0 .And.;
			(Type("aImposto[nX]:_Tributo:_modBC:TEXT")=="U" .Or. Empty(aImposto[nX]:_Tributo:_modBC:TEXT)) .Or.;
			(Type("aImposto[nX]:_Tributo:_modBC:TEXT")<>"U" .And. AllTrim(aImposto[nX]:_Tributo:_modBC:TEXT)$'12'))				
			cString += '<qBCProd>'+ConvType(Val(aImposto[nX]:_Tributo:_qTrib:TEXT),16,4)+'</qBCProd>'
			cString += '<vAliqProd>'+ConvType(Val(aImposto[nX]:_Tributo:_vlTrib:TEXT),15,4)+'</vAliqProd>'
		Else
			cString += '<vBC>'+ConvType(Val(aImposto[nX]:_Tributo:_vBC:TEXT),15,2)+'</vBC>'
			If cVersao >= "3.10"
				cString += '<pCOFINS>'+ConvType(Val(aImposto[nX]:_Tributo:_Aliquota:TEXT),7,4)+'</pCOFINS>'
			Else
				cString += '<pCOFINS>'+ConvType(Val(aImposto[nX]:_Tributo:_Aliquota:TEXT),6,2)+'</pCOFINS>'
			EndIf
		EndIf
		cString += '<vCOFINS>'+ConvType(Val(aImposto[nX]:_Tributo:_Valor:TEXT),15,2)+'</vCOFINS>'
		cString += '</COFINSST>'			
		aImp[8][1] += Val(IIf(Type("aImposto[nX]:_Tributo:_vBC:TEXT")  =="U","0" ,aImposto[nX]:_Tributo:_vBC:TEXT))
		aImp[8][2] += Val(IIf(Type("aImposto[nX]:_Tributo:_valor:TEXT")=="U","0",aImposto[nX]:_Tributo:_valor:TEXT))
	EndIf
EndIf
/*NOTA TÉCNICA 2015/003 - ICMSUFDest
Grupo a ser informado nas vendas interestaduais para consumidor final, não contribuinte do ICMS
*/
nX := aScan(aImposto,{|x| x:_codigo:TEXT == "ICMSUFDest"})
If  nX > 0
	//cString += '<ICMS>'
	cString += '<ICMSUFDest>'
	cString += '<vBCUFDest>'+ConvType(Val(aImposto[nX]:_Tributo:_vBC:TEXT),15,2)+'</vBCUFDest>'
	cString += '<pFCPUFDest>'+ConvType(Val(aImposto[nX]:_Tributo:_pFCPUF:TEXT),7,4)+'</pFCPUFDest>'	
	cString += '<pICMSUFDest>'+ConvType(Val(aImposto[nX]:_Tributo:_Aliquota:TEXT),7,4)+'</pICMSUFDest>'
	cString += '<pICMSInter>'+ConvType(Val(aImposto[nX]:_Tributo:_AliquotaInter:TEXT),6,2)+'</pICMSInter>'
	cString += '<pICMSInterPart>'+ConvType(Val(aImposto[nX]:_Tributo:_pICMSInter:TEXT),7,4)+'</pICMSInterPart>'
	cString += '<vFCPUFDest>'+ConvType(Val(aImposto[nX]:_Tributo:_ValorFCP:TEXT),15,2)+'</vFCPUFDest>'
	cString += '<vICMSUFDest>'+ConvType(Val(aImposto[nX]:_Tributo:_ValorICMSDes:TEXT),15,2)+'</vICMSUFDest>'
	cString += '<vICMSUFRemet>'+ConvType(Val(aImposto[nX]:_Tributo:_ValorICMSRem:TEXT),15,2)+'</vICMSUFRemet>'
	cString += '</ICMSUFDest>'
	
	aImp[1][4] += Val(IIf(Type("aImposto[nX]:_Tributo:_ValorFCP:TEXT")=="U","0",aImposto[nX]:_Tributo:_ValorFCP:TEXT))	
	aImp[1][5] += Val(IIf(Type("aImposto[nX]:_Tributo:_ValorICMSDes:TEXT")=="U","0",aImposto[nX]:_Tributo:_ValorICMSDes:TEXT))	
	aImp[1][6] += Val(IIf(Type("aImposto[nX]:_Tributo:_ValorICMSRem:TEXT")=="U","0",aImposto[nX]:_Tributo:_ValorICMSRem:TEXT))	
EndIf
nX := Ascan(aImposto,{|o| o:_Codigo:TEXT == "ISS"})
If nX > 0
	aImp[9][1] += Val(IIf(Type("aImposto[nX]:_Tributo:_vBC:TEXT")  =="U","0" ,aImposto[nX]:_Tributo:_vBC:TEXT))
	aImp[9][2] += Val(IIf(Type("aImposto[nX]:_Tributo:_valor:TEXT")=="U","0",aImposto[nX]:_Tributo:_valor:TEXT))
	aImp[9][3] += Val(oDet:_Prod:_vProd:TEXT)
	aImp[9][4] += nValPis
	aImp[9][5] += nValCof 			
	If cVersao >= "3.10"
		aImp[9][6] += Val(IIf(Type("aImposto[nX]:_Tributo:_deducao:TEXT")  =="U","0" ,aImposto[nX]:_Tributo:_deducao:TEXT))
		aImp[9][7] += Val(IIf(Type("aImposto[nX]:_Tributo:_outro:TEXT")  =="U","0" ,aImposto[nX]:_Tributo:_outro:TEXT))
		aImp[9][8] += Val(IIf(Type("aImposto[nX]:_Tributo:_descIncond:TEXT")  =="U","0" ,aImposto[nX]:_Tributo:_descIncond:TEXT))
		aImp[9][9] += Val(IIf(Type("aImposto[nX]:_Tributo:_descCond:TEXT")  =="U","0" ,aImposto[nX]:_Tributo:_descCond:TEXT))
		aImp[9][10] += Val(IIf(Type("aImposto[nX]:_Tributo:_ISSRet:TEXT")  =="U","0" ,aImposto[nX]:_Tributo:_ISSRet:TEXT))
	EndIf
EndIf
cString += '</imposto>'
/* Incluído um novo grupo opcional na 3.10 para que as empresas possam
informar o valor do IPI devolvido, para um determinado item da NF-e. 
Este novo grupo somente poderá ocorrer para NF-e de devolução (tag: Tpnfe =4).
*/
/* Nota Técnica 2015/002
Eliminada a possibilidade de informação do grupo de Devolução de Tributos na NFC-e (RV: UA01-20);
*/
If cVersao >= "3.10" .and. Type("oXml:_IPIDEV")<>"U" .and. cNFMod <> "65"
	cString += '<impostoDevol>'
	cString += '<pDevol>' + ConvType(Val(oXml:_IPIDEV:_pdevol:text),6,2) + '</pDevol>'
	cString += '<IPI>'
	cString += '<vIPIDevol>' + ConvType(Val(oXml:_IPIDEV:_vipidevol:text),15,2) + '</vIPIDevol>'
	cString += '</IPI>'	
	cString += '</impostoDevol>'
EndIf
//ANFAVEA Informacoes adicionais do item
If Type("oXml:_ANFAVEAPROD:TEXT")<>"U"
	//Se utiliza TOTVS Colaboração, o XML não é Assinado e não 
	//passa pela função de Canonização da assinatura e não precisa
	//colocar 2 CDATA
	If lUsaColab
		cString += '<infAdProd>'+"<![CDATA["+oXml:_ANFAVEAPROD:TEXT+"]]>"
		cString += IIF(Type("oXml:_infAdProd:TEXT")=="U","",oXml:_infAdProd:TEXT)
		cString +='</infAdProd>'                                                 		
	Else
		cString += '<infAdProd>'+"<![CDATA[<![CDATA["+oXml:_ANFAVEAPROD:TEXT+"]]]]><![CDATA[>]]>"
		cString += IIF(Type("oXml:_infAdProd:TEXT")=="U","",oXml:_infAdProd:TEXT)
		cString +='</infAdProd>'                                                                 
	EndIF	
ElseIf Type("oXml:_infAdProd:TEXT")<>"U"
	If !Empty(oXml:_infAdProd:TEXT)
		cString += '<infAdProd>'+oXml:_infAdProd:TEXT+'</infAdProd>'
	EndIf
EndIf
cString += '</det>'
Return(cString)

Static Function XmlNfeInf(cVersao,oInf,lCdata,lUsaColab)
                    
Local aprocRef  := {}

Local nZ        := 0 

Default lCdata		:=.F.
Default lUsaColab	:=.F.
Private nX      := 0 

Private oXml    := oInf 

cString := ""      

If oInf <> Nil
	cString += '<infAdic>'
	cString += NfeTag('<infAdFisco>',"ConvType(oXml:_FISCO:TEXT,2000,0)")
	If 	Type("oXml:_ANFAVEACPL:TEXT")=="U" .And. Type("oXml:_Cpl")<>"U" .And. !Empty("oXml:_Cpl:TEXT") 
		cString += NfeTag('<infCpl>',"ConvType(oXml:_Cpl:TEXT,5000,0)")
	ElseIf Type("oXml:_ANFAVEACPL:TEXT")<>"U"
		If lUsaColab		   		
   			cString += '<infCpl>'
			cString +="<![CDATA["+oXml:_ANFAVEACPL:TEXT+"]]>"
			cString += IIF(Type("oXml:_Cpl:TEXT")=="U","",ConvType(oXml:_Cpl:TEXT,5000,0))
			cString +='</infCpl>'
	    Else
			cString += '<infCpl>'
			cString +="<![CDATA[<![CDATA["+oXml:_ANFAVEACPL:TEXT+"]]]]><![CDATA[>]]>"
			cString += IIF(Type("oXml:_Cpl:TEXT")=="U","",ConvType(oXml:_Cpl:TEXT,5000,0))
			cString +='</infCpl>'
		EndIF	
	EndIf

	If Type("oXml:_obsCont")<>"U"
		If Type("oXml:_obsCont")=="A"
			aObsCont := oXml:_obsCont
	    Else
	        aObsCont := {oXml:_obsCont}
	    EndIf
	    For nZ := 1 To Len(aObsCont) // conforme manual da SEFAZ possibilita ter informacoes somente 10 TAG's obsCont
			nX := nZ 
			If nx <= 10
				cXcampo := Convtype(aObsCont[nX]:_xCampo:TEXT,20)
		        cString += '<obsCont xCampo="'+cXcampo+'">'
		        cString += '<xTexto>'+Convtype(aObsCont[nX]:_xTexto:TEXT,60)+'</xTexto>'
		        cString += '</obsCont>'
		  	Else
		  		Exit
		  	EndIf
	 	Next nZ
	EndIf
	If Type("oXml:_procRef")<>"U"
		If Type("oXml:_procRef")=="A"
			aprocRef := oXml:_procRef
	    Else
	        aprocRef := {oXml:_procRef}
	    EndIf
	    For nZ := 1 To Len(aprocRef) // conforme manual da SEFAZ possibilita ter informacoes somente 10 TAG's obsCont
	    	cString += '<procRef>'
		    cString += '<nProc>'+Convtype(aprocRef[nZ]:_nProc:TEXT,60)+'</nProc>'
		    cString += '<indProc>'+Convtype(aprocRef[nZ]:_indProc:TEXT,1)+'</indProc>'
		    cString += '</procRef>'		  	
	 	Next nZ
	EndIf
	cString += '</infAdic>'	
EndIf
Return(cString)

Static Function XmlNfeExp(cVersao,oExp)

Private oXml    := oExp
cString := ""
If oExp <> Nil
	cString += '<exporta>'
	If cVersao >= "3.10"
		cString += '<UFSaidaPais>' + oXml:_UFEmbarq:TEXT + '</UFSaidaPais>'
		cString += '<xLocExporta>' + Convtype(oXml:_locembarq:TEXT,60) + '</xLocExporta>'
		cString += NfeTag('<xLocDespacho>',"Convtype(oXml:_locdespacho:TEXT,60)")		
	Else
		cString += NfeTag('<UFEmbarq>',"oXml:_UFEmbarq:TEXT")
		cString += NfeTag('<xLocEmbarq>',"oXml:_locembarq:TEXT")
	EndIf
	cString += '</exporta>'	
EndIf
Return(cString)


Static Function XmlNfeInfCompra(cVersao,oCompra)

Private oXml    := oCompra
cString := ""
If oCompra <> Nil
	cString += '<compra>'
	cString += NfeTag('<xNEmp>',"oXml:_NEmp:TEXT")
	cString += NfeTag('<xPed>',"oXml:_Pedido:TEXT")
	cString += NfeTag('<xCont>',"oXml:_Contrato:TEXT")
	cString += '</compra>'
EndIf
Return(cString)

//Funcao para geracao das informacoes do Registro de Aquisicao de Cana previsto na Versao 2.00 da Nf-e.
Static Function XmlNfeCana(cVersao,oCana)
Local nZ :=0
Private aForDia := {}
Private aDeduc	:= {}
Private oXml    := oCana
cString := ""

If oCana <> Nil
	cString += '<cana>'
	cString += '<safra>'+oXml:_safra:TEXT+'</safra>'
	cString += '<ref>'+oXml:_ref:TEXT+'</ref>'
	If Type("oXml:_forDia")<>"U"
		If Type("oXml:_forDia")=="A"
			aForDia := oXml:_forDia
		Else
			aForDia := {oXml:_forDia}
		EndIf
		For nZ := 1 To Len(aForDia) // conforme manual da SEFAZ possibilita ter informacoes somente 31 TAG's forDia
			If nZ <= 31    
				cString += '<forDia dia="'+aForDia[nZ]:_dia:Text+'">'
				cString += '<qtde>'+ConvType(Val(aForDia[nZ]:_qtde:Text),21,10)+'</qtde>'
				cString += '</forDia>'
			Else
				Exit
			EndIf
		Next nZ
	EndIf
	cString += '<qTotMes>'+ConvType(Val(oXml:_qTotMes:Text),21,10)+'</qTotMes>'
	cString += '<qTotAnt>'+ConvType(Val(oXml:_qTotAnt:Text),21,10)+'</qTotAnt>'
	cString += '<qTotGer>'+ConvType(Val(oXml:_qTotGer:Text),21,10)+'</qTotGer>' 
	If Type("oXml:_deduc")<>"U"
		If Type("oXml:_deduc")=="A"
			aDeduc := oXml:_deduc
		Else
			aDeduc := {oXml:_deduc}
		EndIf
		For nZ := 1 To Len(aDeduc) // conforme manual da SEFAZ possibilita ter informacoes somente 10 TAG's deduc
			If nZ <= 10    
				cString += '<deduc>'
				cString += '<xDed>'+ConvType(aDeduc[nZ]:_xDed:Text,60)+'</xDed>'           
				cString += '<vDed>'+ConvType(Val(aDeduc[nZ]:_vDed:Text),17,2)+'</vDed>'
				cString += '</deduc>'
			Else
				Exit
			EndIf
		Next nZ
	EndIF	
	cString += '<vFor>'+ConvType(Val(oXml:_vFor:Text),17,2)+'</vFor>'
	cString += '<vTotDed>'+ConvType(Val(oXml:_vTotDed:Text),17,2)+'</vTotDed>'
	cString += '<vLiqFor>'+ConvType(Val(oXml:_vLiqFor:Text),17,2)+'</vLiqFor>'
	cString += '</cana>'
EndIf
Return(cString)                                      
Static Function XmlDpec(oXml,cVersao,aImp,cIdent,lFormSef)

Local aTpEmis	:= GetTpEmis(cIdEnt,"55")
Private oXMLD := oXml

If cVersao == "2.00"
	cChave := GetUFCode(oXMLD:_Emit:_EnderEmit:_UF:TEXT)+SubStr(oXMLD:_Ide:_dEmi:TEXT,3,2)+SubStr(oXMLD:_Ide:_dEmi:TEXT,6,2)+oXMLD:_Emit:_CNPJ:TEXT+"55"+StrZero(Val(oXMLD:_Ide:_Serie:TEXT),3)+StrZero(Val(oXMLD:_Ide:_nNF:TEXT),9)+aTpEmis[1]+StrZero(Val(oXMLD:_Ide:_cNF:TEXT),8)
ElseIf cVersao >= "3.10"
	cChave := GetUFCode(oXMLD:_Emit:_EnderEmit:_UF:TEXT)+SubStr(oXMLD:_Ide:_dHEmi:TEXT,3,2)+SubStr(oXMLD:_Ide:_dHEmi:TEXT,6,2)+oXMLD:_Emit:_CNPJ:TEXT+"55"+StrZero(Val(oXMLD:_Ide:_Serie:TEXT),3)+StrZero(Val(oXMLD:_Ide:_nNF:TEXT),9)+aTpEmis[1]+StrZero(Val(oXMLD:_Ide:_cNF:TEXT),8)
Endif

cString := ""
cString += '<infDPEC Id="DPEC'+oXMLD:_Emit:_CNPJ:TEXT+'">'
cString += '<ideDec>'
cString += '<cUF>'+GetUFCode(oXMLD:_Emit:_EnderEmit:_UF:TEXT)+'</cUF>'
cString += '<tpAmb>'+ SubStr(ColGetPar("MV_AMBIENT","2"),1,1)+'</tpAmb>'
cString += '<verProc>'+__GetTCVersao+'</verProc>'
If Type("oXMLD:_Emit:_CNPJ:TEXT")<>"U"
	cString += '<CNPJ>'+oXMLD:_Emit:_CNPJ:TEXT+'</CNPJ>'              	
EndIf
cString += '<IE>'+oXMLD:_Emit:_IE:TEXT+'</IE>'
cString += '</ideDec>'
cString += '<resNFe>'
cString += '<chNFe>'+cChave+Modulo11(cChave)+'</chNFe>'        
If Type("oXMLD:_Dest:_CNPJ:TEXT")<>"U"                           
	cString += '<CNPJ>'+oXMLD:_Dest:_CNPJ:TEXT+'</CNPJ>'
ElseIf Type("oXMLD:_Dest:_CPF:TEXT")<>"U"
	cString += NfeTag('<CPF>' ,"oXMLD:_Dest:_CPF:TEXT")
Else
	cString += '<CNPJ></CNPJ>'
EndIf
cString += '<UF>'+oXMLD:_Dest:_EnderDest:_UF:TEXT+'</UF>'
If lFormSef
	cString += '<vNF>'+ConvType(Val(oXMLD:_TOTAL:_ICMSTOT:_VNF:TEXT),15,2)+'</vNF>'
	cString += '<vICMS>'+ConvType(Val(oXMLD:_TOTAL:_ICMSTOT:_VICMS:TEXT),15,2)+'</vICMS>'
	cString += '<vST>'+ConvType(Val(oXMLD:_TOTAL:_ICMSTOT:_VST:TEXT),15,2)+'</vST>'
Else
	cString += '<vNF>'+ConvType(Val(oXMLD:_Total:_vNF:TEXT),15,2)+'</vNF>'
	cString += '<vICMS>'+ConvType(aImp[1][2],15,2)+'</vICMS>'
	cString += '<vST>'+ConvType(aImp[2][2],15,2)+'</vST>'
EndIf
cString += '</resNFe>'

Return(cString)        


//-----------------------------------------------------------------------
/*/{Protheus.doc} XmlNfeAut
Função que monta o grupo autXML da NFe 3.10

@param		oAutXml	 grupo autXML	

@return	cString	 String contendo o grupo autXML  

@author Natalia Sartori
@since 20/05/2014
@version 1.0 
/*/
//-----------------------------------------------------------------------

Static Function XmlNfeAut(oAutXml)

Local cString := ""

Private oXml		:= oAutXml

If oAutXml <> Nil
	cString := '<autXML>' 
	
	If Type("oXml:_CNPJ:TEXT")<>"U" .And. !Empty(oXml:_CNPJ:TEXT)
		cString += '<CNPJ>'+oXml:_CNPJ:TEXT+'</CNPJ>'
	ElseIf Type("oXml:_CPF:TEXT")<>"U" .And. !Empty(oXml:_CPF:TEXT)
		cString += '<CPF>'+oXml:_CPF:TEXT+'</CPF>'
	EndIf
	cString += '</autXML>'
EndIf


Return(cString)



Static Function XmlNfeTotal(cVersao,oTotal,aImp,aTot)

Local nX       := 0
Local aLacre   := {}
Private aAux   := aImp
Private aTrib  := {}
Private oXml   := oTotal
Private cString:= ""
Private aAuxTot:= aTot

cString += '<total>'
cString += '<ICMSTot>'
cString += '<vBC>'    +ConvType(aImp[1][1],15,2)+'</vBC>'
cString += '<vICMS>'  +ConvType(aImp[1][2],15,2)+'</vICMS>'
cString += '<vICMSDeson>' + ConvType(aImp[1][3],15,2) + '</vICMSDeson>'

/*NOTA TÉCNICA 2015/003_v1.10*/
cString += '<vFCPUFDest>'  +ConvType(aImp[1][4],15,2)+'</vFCPUFDest>'
cString += '<vICMSUFDest>'  +ConvType(aImp[1][5],15,2)+'</vICMSUFDest>'
cString += '<vICMSUFRemet>'  +ConvType(aImp[1][6],15,2)+'</vICMSUFRemet>'
cString += '<vBCST>'  +ConvType(aImp[2][1],15,2)+'</vBCST>'
cString += '<vST>'    +ConvType(aImp[2][2],15,2)+'</vST>'
cString += '<vProd>'  +ConvType(aAuxTot[1],15,2)+'</vProd>'
cString += '<vFrete>' +ConvType(aAuxTot[2],15,2)+'</vFrete>'
cString += '<vSeg>'   +ConvType(aAuxTot[3],15,2)+'</vSeg>'
cString += '<vDesc>'  +ConvType(aAuxTot[4],15,2)+'</vDesc>'
cString += '<vII>'    +ConvType(aImp[4][2],15,2)+'</vII>'
cString += '<vIPI>'   +ConvType(aImp[3][2],15,2)+'</vIPI>'
cString += '<vPIS>'   +ConvType(aImp[5][2],15,2)+'</vPIS>'
cString += '<vCOFINS>'+ConvType(aImp[7][2],15,2)+'</vCOFINS>'
cString += '<vOutro>' +ConvType(Val(oTotal:_Despesa:TEXT),15,2)+'</vOutro>'
cString += '<vNF>'    +ConvType(Val(oTotal:_vNF:TEXT),15,2)+'</vNF>'
cString += NfeTag('<vTotTrib>',"ConvType(aAuxTot[5],15,2)")
cString += '</ICMSTot>'
If aImp[9][3]>0
	cString += '<ISSQNtot>'
	cString += NfeTag('<vServ>'  ,"ConvType(aAux[9][3],15,2)")	
	cString += NfeTag('<vBC>'    ,"ConvType(aAux[9][1],15,2)")
	cString += NfeTag('<vISS>'   ,"ConvType(aAux[9][2],15,2)")
	cString += NfeTag('<vPIS>'   ,"ConvType(aAux[9][4],15,2)")
	cString += NfeTag('<vCOFINS>',"ConvType(aAux[9][5],15,2)")
	If Type("oXml:_dCompet:TEXT") <> "U"
	cString += '<dCompet>' + SubStr(oXml:_dCompet:TEXT,1,4) + "-" + SubStr(oXml:_dCompet:TEXT,5,2) + "-" + SubStr(oXml:_dCompet:TEXT,7,2) +'</dCompet>'
	EndIf 
	cString += NfeTag('<vDeducao>',"ConvType(aAux[9][6],15,2)")
	cString += NfeTag('<vOutro>',"ConvType(aAux[9][7],15,2)")
	cString += NfeTag('<vDescIncond>',"ConvType(aAux[9][8],15,2)")
	cString += NfeTag('<vDescCond>',"ConvType(aAux[9][9],15,2)")
	cString += NfeTag('<vISSRet>',"ConvType(aAux[9][10],15,2)")
	cString += NfeTag('<cRegTrib>',"oTotal:_cRegTrib:TEXT")
	cString += '</ISSQNtot>'
EndIf
If Type("oXml:_TributoRetido")<>"U"
	If Type("oXml:_TributoRetido")=="A"
		aTrib := oTotal:_TributoRetido
	Else
		aTrib := {oTotal:_TributoRetido}
	EndIf
	cString += '<retTrib>'	
	nX := Ascan(aTrib,{|o| o:_Codigo:TEXT == "PIS"})
	If nX > 0
		cString += '<vRetPIS>'+ConvType(Val(aTrib[nX]:_Valor:TEXT),15,2)+'</vRetPIS>'
	EndIf
	nX := Ascan(aTrib,{|o| o:_Codigo:TEXT == "COFINS"})
	If nX > 0
		cString += '<vRetCOFINS>'+ConvType(Val(aTrib[nX]:_Valor:TEXT),15,2)+'</vRetCOFINS>'
	EndIf
	nX := Ascan(aTrib,{|o| o:_Codigo:TEXT == "CSLL"})
	If nX > 0
		cString += '<vRetCSLL>'+ConvType(Val(aTrib[nX]:_Valor:TEXT),15,2)+'</vRetCSLL>'
	EndIf
	nX := Ascan(aTrib,{|o| o:_Codigo:TEXT == "IRRF"})
	If nX > 0
		cString += '<vBCIRRF>'+ConvType(Val(aTrib[nX]:_BC:TEXT),15,2)+'</vBCIRRF>'
		cString += '<vIRRF>'+ConvType(Val(aTrib[nX]:_Valor:TEXT),15,2)+'</vIRRF>'
	EndIf
	nX := Ascan(aTrib,{|o| o:_Codigo:TEXT == "INSS"})
	If nX > 0	
		cString += '<vBCRetPrev>'+ConvType(Val(aTrib[nX]:_BC:TEXT),15,2)+'</vBCRetPrev>'
		If type (aTrib[nX]:_Valor:TEXT)<>"U"
			cString += '<vRetPrev>'+ConvType(Val(aTrib[nX]:_Valor:TEXT),15,2)+'</vRetPrev>'
		EndIf
	EndIf
	cString += '</retTrib>'
EndIf
cString += '</total>'
Return(cString)



Static Function XmlNfeTransp(cVersao,oTransp)
        
Local nZ        := 0
Local nY        := 0
Private aVol    := {}
Private nX      := 0
Private oXml    := oTransp
Private aReboque := {}
cString := ""

cString += '<transp>'
If Type("oXml:_ModFrete")<>"U"
cString += '<modFrete>'+oXml:_ModFrete:TEXT+'</modFrete>'
Else
	cString += '<modFrete></modFrete>'
EndIf
If Type("oXml:_Transporta")<>"U"
	cString += '<transporta>'
	cString += NfeTag('<CNPJ>'  ,"oXml:_Transporta:_CNPJ:TEXT")
	cString += NfeTag('<CPF>'   ,"oXml:_Transporta:_CPF:TEXT")
	cString += NfeTag('<xNome>' ,"oXml:_Transporta:_Nome:TEXT")
	cString += NfeTag('<IE>'    ,"oXml:_Transporta:_IE:TEXT")
	cString += NfeTag('<xEnder>',"oXml:_Transporta:_Ender:TEXT")
	cString += NfeTag('<xMun>'  ,"oXml:_Transporta:_Mun:TEXT")
	cString += NfeTag('<UF>'    ,"oXml:_Transporta:_UF:TEXT")
	cString += '</transporta>'
EndIf
If Type("oXml:_RetTransp")<>"U" .And. Val(oXml:_RetTransp:_Tributo:_Valor:TEXT)>0
	cString += '<retTransp>'
	cString += '<vServ>'   +ConvType(Val(oXml:_RetTransp:_Cpl:_vServ:TEXT),15,2)+'</vServ>'
	cString += '<vBCRet>'  +ConvType(Val(oXml:_RetTransp:_Tributo:_vBC:TEXT),15,2)+'</vBCRet>'
	If cVersao >= "3.10"	
		cString += '<pICMSRet>'+ConvType(Val(oXml:_RetTransp:_Tributo:_Aliquota:TEXT),7,4)+'</pICMSRet>'
	Else
		cString += '<pICMSRet>'+ConvType(Val(oXml:_RetTransp:_Tributo:_Aliquota:TEXT),15,2)+'</pICMSRet>'
	EndIf
	cString += '<vICMSRet>'+ConvType(Val(oXml:_RetTransp:_Tributo:_Valor:TEXT),15,2)+'</vICMSRet>'
	cString += '<CFOP>'    +oXml:_RetTransp:_Cpl:_CFOP:TEXT+'</CFOP>'
	cString += '<cMunFG>'  +oXml:_RetTransp:_Cpl:_cMunFG:TEXT+'</cMunFG>'
	cString += '</retTransp>'
EndIf
If Type("oXml:_Veictransp")<>"U"
	cString += '<veicTransp>'
	cString += '<placa>'+oXml:_Veictransp:_Placa:TEXT+'</placa>'
	cString += '<UF>'   +oXml:_Veictransp:_UF:TEXT+'</UF>'
	cString += NfeTag('<RNTC>',"oXml:_Veictransp:_RNTC:TEXT")
	cString += '</veicTransp>'
EndIf
If Type("oXml:_Reboque")<>"U"
	If Type("oXml:_Reboque")=="A"
		aReboque := oXml:_Reboque
    Else
        aReboque := {oXml:_Reboque}
    EndIf
    For nZ := 1 To Min(2,Len(aReboque))
		nX := nZ
        cString += '<reboque>'
        cString += '<placa>'+aReboque[nX]:_Placa:TEXT+'</placa>'
        cString += '<UF>'   +aReboque[nX]:_UF:TEXT+'</UF>'
        cString += NfeTag('<RNTC>',"aReboque[nX]:_RNTC:TEXT")
        cString += '</reboque>'
 	Next nZ
EndIf
If Type("oXml:_vagao") <> "U" 
	cString += NfeTag('<vagao>',"oXml:_vagao:TEXT")
EndIf	

If Type("oXml:_balsa") <> "U" 
	cString += NfeTag('<balsa>',"oXml:_balsa:TEXT")
EndIf

If Type("oXml:_Vol")<>"U"
	If ValType(oXml:_Vol)=="A"
		aVol := oXml:_Vol
	Else
		aVol := {oXml:_Vol}
	EndIf
	For nZ := 1 To Len(aVol)		
		nX := nZ
		cString += '<vol>'
		cString += NfeTag('<qVol>'  ,"ConvType(Val(aVol[nX]:_qVol:TEXT),15,0)")
		cString += NfeTag('<esp>'   ,"aVol[nX]:_esp:TEXT")
		cString += NfeTag('<marca>' ,"aVol[nX]:_Marca:TEXT")
		cString += NfeTag('<nVol>'  ,"aVol[nX]:_nVol:TEXT")
		cString += NfeTag('<pesoL>' ,"ConvType(Val(aVol[nX]:_pesol:TEXT),15,3)")
		cString += NfeTag('<pesoB>' ,"ConvType(Val(aVol[nX]:_pesob:TEXT),15,3)")
		If Type("aVol[nX]:_Lacres")<>"U"
			If ValType(aVol[nX]:_Lacres) == "A"
				aLacres := aVol[nX]:_Lacres
			Else
				aLacres := {aVol[nX]:_Lacres}
			EndIf
			For nY := 1 To Len(aLacres)
				cString += '<lacres>'
				cString += '<nLacre>'+aLacres[nY]:_LACRE:TEXT+'</nLacre>'
				cString += '</lacres>'
			Next nY
		EndIf
		cString += '</vol>'
	Next nX
EndIf
cString += '</transp>'
Return(cString)

Static Function XmlNfeCob(cVersao,oDupl)

Local nZ        := 0
Private oXml    := oDupl
Private aDupl   := {} 
Private nX      := 0
cString := ""

If oDupl <> Nil
	If ValType(oDupl:_Dup)=="A"
		aDupl := oDupl:_Dup
	Else
		aDupl := {oDupl:_Dup}
	EndIf
	cString += '<cobr>'
	For nZ := 1 To Len(aDupl)
		nX := nZ
		cString += '<dup>'
		cString += '<nDup>' +aDupl[nX]:_Dup:TEXT+'</nDup>'
		cString += '<dVenc>'+aDupl[nX]:_dtVenc:TEXT+'</dVenc>'
		cString += '<vDup>' +ConvType(Val(aDupl[nX]:_vDup:TEXT),15,2)+'</vDup>'
		cString += '</dup>'
	Next nX	
	cString += '</cobr>'
EndIf
Return(cString)



//-----------------------------------------------------------------------
/*/{Protheus.doc} XmlNfePag
Função que monta o grupo Pag da NFe 3.10

@param		aPgto	 	grupo Pag	

@return	cString	String contendo o grupo Pag  

@author Natalia Sartori
@since 20/05/2014
@version 1.0 
/*/
//-----------------------------------------------------------------------

Static Function XmlNfePag(aPgto)

Local cString := ""

Private oXml		:= aPgto

If aPgto <> Nil
	cString := '<pag>'
	cString += '<tPag>'+oXml:_forma:TEXT+'</tPag>'
	cString += '<vPag>'+Convtype(Val(oXml:_valor:TEXT),15,2)+'</vPag>'
	If Type("oXml:_cartoes")<>"U"
		cString += '<card>'
		cString += '<CNPJ>'+oXml:_cartoes:_cnpj:TEXT+'</CNPJ>'
		cString += '<tBand>'+oXml:_cartoes:_bandeira:TEXT+'</tBand>'
		cString += '<cAut>'+oXml:_cartoes:_autorizacao:TEXT+'</cAut>'
		cString += '</card>'
	EndIf	
	cString += '</pag>'
EndIf

Return(cString)


//-----------------------------------------------------------------------
/*/{Protheus.doc}GetTpEmis
Funcao que retorna o tipo de emissão do documento no padrão esperado pela 
Sefaz e se esta modalidade é uma contingencia.

@author Natalia Sartori
@since 20/05/2014
@version 2.0 

@param		cIdEnt		Id da Entidade
			cNFMod		Modelo do Documento 55=NFe 65= NFCe
					
@return	Array		[1]Tipo de emissão/modalidade
						[2]Variavel logica que define se o tipo de emissao
							é uma contingencia
/*/
//-----------------------------------------------------------------------
Function GetTpEmis(cIdEnt,cNFMod)

Local cRet 	:= "1"
//Local cModal	:= SpedGetMv("MV_MODALID",cIdEnt,"1")
Local cModal	:= SubStr(ColGetPar("MV_MODALID","1"),1,1)
Local lCont	:= .F.

Default cNFMod:= "55"

If cNFMod == "65" //verificar
	cModal:= SubStr(ColGetPar("MV_MODNFCE","1"),1,1) //subStr( spedGetMV( "MV_MODNFCE", cIdEnt, "1" ), 1, 1 )
	cRet:= cModal
	If cModal <> "1" 
		lCont:= .T.
	EndIf
Else
	
	cRet	:= cModal
		
	if cModal <> "1"
		lCont := .T.
	endif	

EndIf

Return ({cRet, lCont})


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GetUFCode ³ Rev.  ³Eduardo Riera          ³ Data ³11.05.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de recuperacao dos codigos de UF do IBGE             ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do Estado ou UF                               ³±±
±±³          ³ExpC2: lForceUf                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta funcao tem como objetivo retornar o codigo do IBGE da  ³±±
±±³          ³UF                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Totvs SPED Services Gateway                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GetUFCode(cUF,lForceUF)

Local nX         := 0
Local cRetorno   := ""
Local aUF        := {}
DEFAULT lForceUF := .F.

aadd(aUF,{"RO","11"})
aadd(aUF,{"AC","12"})
aadd(aUF,{"AM","13"})
aadd(aUF,{"RR","14"})
aadd(aUF,{"PA","15"})
aadd(aUF,{"AP","16"})
aadd(aUF,{"TO","17"})
aadd(aUF,{"MA","21"})
aadd(aUF,{"PI","22"})
aadd(aUF,{"CE","23"})
aadd(aUF,{"RN","24"})
aadd(aUF,{"PB","25"})
aadd(aUF,{"PE","26"})
aadd(aUF,{"AL","27"})
aadd(aUF,{"SE","28"})
aadd(aUF,{"BA","29"})
aadd(aUF,{"MG","31"})
aadd(aUF,{"ES","32"})
aadd(aUF,{"RJ","33"})
aadd(aUF,{"SP","35"})
aadd(aUF,{"PR","41"})
aadd(aUF,{"SC","42"})
aadd(aUF,{"RS","43"})
aadd(aUF,{"MS","50"})
aadd(aUF,{"MT","51"})
aadd(aUF,{"GO","52"})
aadd(aUF,{"DF","53"})

If !Empty(cUF)
	nX := aScan(aUF,{|x| x[1] == cUF})
	If nX == 0
		nX := aScan(aUF,{|x| x[2] == cUF})
		If nX <> 0
			cRetorno := aUF[nX][1]
		EndIf
	Else
		cRetorno := aUF[nX][IIF(!lForceUF,2,1)]
	EndIf
Else
	cRetorno := aUF
EndIf
Return(cRetorno)


//-------------------------------------------------------------------
/*/{Protheus.doc} DataHoraUTC
Retorna a Data e Hora no formato UTC

@param dData			Date: Data - YYYY-MM-DD

@param cHora			String: Hora - HH:MM:SS

@param cIdEnt			String: ID da entidade no TSS
						Se o parametro cIdEnt nao for passado, a Entidade
						devera obrigatoriamente estar posicionada

@param cUF				String: UF em que se deseja obter a hora
						Quando se tratar de Fernando de Noronha,
						Trindade e Martin Vaz, passar no parametro
						cUF da seguinte forma:
						1 - Fernando de Noronha
						2 - Trindade e Martim Vaz

@param lHVerao			Logical: Indica se iniciou o horario de verao

@param lSrvSummer		Logical: Indica se o SERVER esta em uma regiao com horario de verao ATIVO

@return	cRetorno		AAAA-MM-DDTHH:MM:SS-TDZ, onde TDZ
						-02:00 (Fernando de Noronha)
						-03:00 (Brasilia) ou 
						-04:00 (Manaus), no horario de verao serao:
						-01:00, -02:00 e -03:00, respectivamente

@author Sergio S. Fuzinaka
@since 08.11.2012
@version 12
/*/
//-------------------------------------------------------------------
Function DataHoraUTC(dData,cHora,cUF,lHVerao,lSrvSummer)

Local cRetorno		:= ""
Local aDataUTC		:= {}
Local cTDZ			:= ""

Default dData		:= CToD("")
Default cHora		:= ""
Default cUF			:= Upper(Left(LTrim(SM0->M0_ESTENT),2))
Default lHVerao		:= ""
Default lSrvSummer	:= ""

if lHVerao == ""
	lHVerao		:= iif( ColGetPar( "MV_HRVERAO", "2" ) == "1", .T., .F. )
endIf
if lSrvSummer == ""
	lSrvSummer	:= GetNewPar("MV_HVERAO",.F.)
endIf

If FindFunction( "FwTimeUF" ) .And. FindFunction( "FwGMTByUF" )

	// Tratamento para Fernando de Noronha, Trindade e Martim Vaz
	If "1" $ cUF
	
		cUF := "FERNANDO DE NORONHA"
	
	ElseIf "2" $ cUF
	
		cUF := "TRINDADE E MARTIM VAZ"
	
	Endif	
	
	aDataUTC := FwTimeUF(cUF,,lSrvSummer)

	If Empty( dData )
		dData := SToD( aDataUTC[ 1 ] )
		
		If Empty( dData )
			dData := Date()
		Endif
	Endif
	
	If Empty( cHora )
		cHora := aDataUTC[ 2 ]
		
		If Empty( cHora )
			cHora := Time()
		Endif
	Endif

	// Montagem da Data UTC
	cRetorno 	:= StrZero( Year( dData ), 4 )
	cRetorno 	+= "-"
	cRetorno 	+= Strzero( Month( dData ), 2 )
	cRetorno 	+= "-"
	cRetorno 	+= Strzero( Day( dData ), 2 )

	// Montagem da Hora UTC
	cRetorno += "T"
	cRetorno += cHora
	
	// Montagem do TDZ	
	cTDZ := Substr( Alltrim( FwGMTByUF( cUF ) ), 1, 6 )
	
	If !Empty( cTDZ )
	
		If lHVerao
		    
	   		cTDZ := StrTran( cTDZ, Substr( cTDZ, 3, 1 ), Str( Val( Substr( cTDZ, 3, 1 ) ) -1, 1 ) )
			
		Endif
		
		cRetorno += cTDZ

	Endif
	
Endif

Return( cRetorno )


//-----------------------------------------------------------------------
/*/{Protheus.doc}	MontaNFRef
Função que monta o grupo NFRef da NFe

@param		cVersao	 Versão da NFe		

@return	cString	 String contendo o grupo NFRef  

@author Natalia Sartori
@since 20/05/2014
@version 1.0 
/*/
//-----------------------------------------------------------------------
Function MontaNFRef (cVersao,nAutoriz)

Local aXmlVinc	:= {}  
Local aNfRef	:= {}
Local aNfVinc	:= {}

Local cNFRef  	:= ""
Local cString	:= ""

Local nY      	:= 0
Local nX		:= 0

default cVersao := "4.00"

If Type("oXml:_NFRef")<>"U"
	If Type("oXml:_NFRef") == "A"
		aNfRef :=  oXml:_NFRef
	Else
		aNfRef := {oXml:_NFRef}
	EndIf
	
	For nY := 1 to Len( aNfRef )
		
		oXmlRef := aNfRef[nY]
			
		If Type("oXmlRef:_refNFe")<>"U"
			If ValType(oXmlRef:_refNFe)=="A"
				aNfVinc := oXmlRef:_refNFe
			Else
				aNfVinc := {oXmlRef:_refNFe}
			EndIf
			For nX := 1 To Len(aNfVinc)
				cString += "<NFref>"
				If Len(aNfVinc[nX]:TEXT)<44
					cString += '<refNFe>'+aNfVinc[nX]:TEXT+Modulo11(aNfVinc[nX]:TEXT)+'</refNFe>'
				Else
					cString += '<refNFe>'+aNfVinc[nX]:TEXT+'</refNFe>'
				EndIf
				cString += "</NFref>"
			Next nX	
		EndIf
		If Type("oXmlRef:_refNF")<>"U"
			If ValType(oXmlRef:_refNF)=="A"
				aNfVinc := oXmlRef:_refNF
			Else
				aNfVinc := {oXmlRef:_refNF}
			EndIf
			For nX := 1 To Len(aNfVinc)				
				If aNfVinc[nX]:_Mod:TEXT == "55"
					cNFREF := aNfVinc[nX]:_cUF:TEXT+aNfVinc[nX]:_AAMM:TEXT+aNfVinc[nX]:_CNPJ:TEXT+aNfVinc[nX]:_Mod:TEXT+StrZero(Val(aNfVinc[nX]:_Serie:TEXT),3)+StrZero(Val(aNfVinc[nX]:_nNF:TEXT),9)+nAutoriz+StrZero(Val(SubStr(aNfVinc[nX]:_cNF:TEXT,2,8)),8)
					cString += "<NFref>"
					cString += '<refNFe>'
					cString += cNFRef+Modulo11(cNFRef)
					cString += '</refNFe>'
					cString += "</NFref>"
				EndIf
			Next nX			
			For nX := 1 To Len(aNfVinc) 
				If aNfVinc[nX]:_Mod:TEXT <> "55"
					cString += "<NFref>"
					cString += '<refNF>'
					cString += '<cUF>'  +aNfVinc[nX]:_cUF:TEXT+'</cUF>'
					cString += '<AAMM>' +aNfVinc[nX]:_AAMM:TEXT+'</AAMM>'
					cString += '<CNPJ>' +aNfVinc[nX]:_CNPJ:TEXT+'</CNPJ>'
					cString += '<mod>'  +aNfVinc[nX]:_Mod:TEXT+'</mod>'
					cString += '<serie>'+aNfVinc[nX]:_Serie:TEXT+'</serie>'
					cString += '<nNF>'  +aNfVinc[nX]:_nNF:TEXT+'</nNF>' 
					cString += '</refNF>'
					cString += "</NFref>"
				EndIf
			Next nX			
		EndIf			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³NOTA FISCAL DE PRODUTOR RURAL REFERENCIADA³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If Type("oXmlRef:_refNFP")<>"U"
			If ValType(oXmlRef:_refNFP)=="A"
				aXmlVinc := oXmlRef:_refNFP
			Else
				aXmlVinc := {oXmlRef:_refNFP}
			EndIf
			For nX := 1 To Len(aXmlVinc)
				If aXmlVinc[nX]:_Mod:TEXT <> "55"
				    oRefNFp := aXmlVinc[nX]
					cString += "<NFref>"
					cString += '<refNFP>'					
					cString += '<cUF>'  +aXmlVinc[nX]:_cUF:TEXT+'</cUF>'
					cString += '<AAMM>' +aXmlVinc[nX]:_AAMM:TEXT+'</AAMM>'
						If Type("oRefNFp:_CNPJ:TEXT")<>"U" 
							cString += '<CNPJ>' +oRefNFp:_CNPJ:TEXT+'</CNPJ>'
						ElseIf Type("oRefNFp:_CPF:TEXT") <> "U"
							cString += '<CPF>'+oRefNFp:_CPF:TEXT+'</CPF>'
						Else
							cString += '<CNPJ></CNPJ>'
						EndIf
					cString += '<IE>'  +aXmlVinc[nX]:_IE:TEXT+'</IE>'
					cString += '<mod>'  +aXmlVinc[nX]:_Mod:TEXT+'</mod>'
					cString += '<serie>'+aXmlVinc[nX]:_Serie:TEXT+'</serie>'
					cString += '<nNF>'  +aXmlVinc[nX]:_nNF:TEXT+'</nNF>'
					cString += '</refNFP>'
					cString += "</NFref>"
				EndIf
			Next nX
		EndIf			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³CT-E EMITIDO ANTERIORMENTE REFERENCIADA   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Type("oXmlRef:_refCTE:TEXT")<>"U"
			aNfVinc := {}
			If ValType(oXmlRef:_refCTE)=="A"
				aNfVinc := oXmlRef:_refCTE
			Else
				aNfVinc := {oXmlRef:_refCTE}            
			EndIf
			For nX := 1 To Len(aNfVinc)
				cString += "<NFref>"
				If Len(aNfVinc[nX]:TEXT)<44
					cString += '<refCTe>'+aNfVinc[nX]:TEXT+Modulo11(aNfVinc[nX]:TEXT)+'</refCTe>'
				Else
					cString += '<refCTe>'+aNfVinc[nX]:TEXT+'</refCTe>'
				EndIf
				cString += "</NFref>"
			Next nX
		EndIF
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³INFORMACAO DO CUPOM FISCAL REFERENCIADO³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If Type("oXmlRef:_refECF")<>"U"
			aNfVinc := {}
			If ValType(oXmlRef:_refECF)=="A"
				aNfVinc := oXmlRef:_refECF
			Else
				aNfVinc := {oXmlRef:_refECF}
			EndIf
			For nX := 1 To Len(aNfVinc)
				If aNfVinc[nX]:_Mod:TEXT <> "55"
					cString += "<NFref>"
					cString += '<refECF>'
					cString += '<mod>'  +aNfVinc[nX]:_Mod:TEXT+'</mod>'
					cString += '<nECF>' +aNfVinc[nX]:_nECF:TEXT+'</nECF>'
					cString += '<nCOO>' +aNfVinc[nX]:_nCOO:TEXT+'</nCOO>'
					cString += '</refECF>'
					cString += "</NFref>"
				EndIf
			Next nX
		EndIf
	
	Next nY	
EndIf

Return cString


Static Function NfeTag(cTag,cConteudo,lBranco)

Local cRetorno := ""
Local lBreak   := .F.
Local bErro    := ErrorBlock({|e| , break(e), lBreak := .T. })
Local nFimTag  := 0
DEFAULT lBranco := .F.
Begin Sequence
	cConteudo := &(cConteudo)
	If lBreak
		BREAK
	EndIf	
Recover
	If lBranco
		cConteudo := ""
	Else
		cConteudo := Nil
	EndIf
End Sequence
ErrorBlock(bErro)
If cConteudo<>Nil .And. ((!Empty(AllTrim(cConteudo)) .And. (HasAlpha(AllTrim(cConteudo))) .Or. Val(AllTrim(cConteudo))<>0) .Or. lBranco)
	
	nFimTag :=At(" ",cTag)
		                                                       
	cRetorno := cTag+AllTrim(cConteudo)
	cRetorno+="</"    

    If nFimTag > 0
		cRetorno+=SubStr(cTag,2,nFimTag-1)+">"
	Else
		cRetorno+=SubStr(cTag,2)
	EndIf	         
	     
EndIf
Return(cRetorno)


Static Function ConvType(xValor,nTam,nDec,cTipo)

Local cNovo 	:= ""  

DEFAULT nDec 	:= 0   
DEFAULT cTipo 	:= ""

Do Case
	Case ValType(xValor)=="N"  	
		If xValor <> 0
			cNovo := AllTrim(Str(xValor,nTam,nDec))	
		Else
			cNovo := "0"
		EndIf		
	Case ValType(xValor)=="D"
		cNovo := FsDateConv(xValor,"YYYYMMDD")
		cNovo := SubStr(cNovo,1,4)+"-"+SubStr(cNovo,5,2)+"-"+SubStr(cNovo,7)
	Case ValType(xValor)=="C" 
	
		if ( cTipo == "N" ) 			  
			
			cDecOk := substr(xValor,at(".",xValor)+1)
			
			if ( len(cDecOk) > nDec )
				xValor := substr(xValor,1,len(xValor)-(len(cDecOk)-nDec))
			endif
		
			if ( len(xValor) > nTam )
				nDesconto := len(xValor) - nTam
				xValor := subStr(xValor,1,len(xValor)-nDesconto)
			endif   
			
			if ( substr(xValor,len(xValor)) == "." )
				xValor := substr(xValor,1,len(xValor)-1)				
			endif  						  						
			
			cNovo := allTrim(xValor)
			
		else
		
			If nTam==Nil
				xValor := AllTrim(xValor)
			EndIf
			DEFAULT nTam := 60
			cNovo := AllTrim(EnCodeUtf8(NoAcento(SubStr(xValor,1,nTam))))
		
		endif
EndCase
Return(cNovo)

Static Function HasAlpha(cTexto)
Local lRetorno := .F.
Local cAux     := ""

While !Empty(cTexto)
	cAux := SubStr(cTexto,1,1)
	If (Asc(cAux) > 64 .And. Asc(cAux) < 123) .OR. cAux $ '|#'
		lRetorno := .T.
		cTexto := ""
	EndIf
		cTexto := SubStr(cTexto,2)
EndDo
Return(lRetorno)



//-----------------------------------------------------------------------
/*/{Protheus.doc} TSSDirSchema
Funcao que retorna nome da pasta do schema.

@author Henrique Brugugnoli
@since 20/01/2011
@version 1.0 
					
@return		cDirSchema Noma da pasta do schema
/*/
//-----------------------------------------------------------------------
Function TSSDirSchema( nTipo ) 

Local cDirSchema	:= "" 

Default nTipo		:= 0

// eSocial
If IsESocial( nTipo ) // "12-13-14-15"
	cDirSchema := DIR_SCHEMA_SOCIAL
Else
	cDirSchema := DIR_SCHEMA
Endif

Return cDirSchema  


//-------------------------------------------------------------------
/*/{Protheus.doc} IsESocial
Verifica se o tipo pertence ao eSocial.

@author Sergio S. Fuzinaka
@since 19/05/2014
@version 12
/*/
//-------------------------------------------------------------------
Function IsESocial( nTipo )

Local lRetorno	:= .F.

/*
-----------------------------------------
Codigos definidos no arquivo TSSSCHEMA.CH
-----------------------------------------
12 - Iniciais
13 - Tabelas
14 - Não Periódicos
15 - Periódicos
-----------------------------------------
*/

If Str( nTipo, 2 ) $ "12-13-14-15"

	lRetorno := .T.
	
Endif

Return( lRetorno )
//-------------------------------------------------------------------
/*/{Protheus.doc} LimpaXml
Retira e valida algumas informações e caracteres indesejados para o parse do XML.

@author Henrique de Souza Brugugnoli
@since 06/07/2010
@version 1.0

@param	cXml, string, XML que será feito a validação e a retirada dos caracteres especiais

@return	cRetorno	XML limpo
/*/
//-------------------------------------------------------------------

static function LimpaXml( cXml )

Local cRetorno		:= ""

DEFAULT cXml		:= ""

If ( !Empty(cXml) )

	cRetorno := cXml

	/*
	< - &lt;
	> - &gt;
	& - &amp;
	" - &quot;
	' - &#39;
	*/
	If !( "&amp;" $ cRetorno .or. "&lt;" $ cRetorno .or. "&gt;" $ cRetorno .or. "&quot;" $ cRetorno .or. "&#39;" $ cRetorno )
		/*Retira caracteres especiais e faz a substituição*/
		cRetorno := StrTran(cRetorno,"&","&amp;amp;")
	EndIf

EndIf

Return cRetorno

//-------------------------------------------------------------------
//-----------------------------------------------------------------------
/*/{Protheus.doc} NfeDifSefaz
Funcao para verificar se a NFe eh "ICMS 51" Diferimento e se eh SEFAZ de SP

Obs.: Sefaz de SP nao valida as tags Nao Obrigatorias para o ICMS 51

@param	aImposto		Imposto da NFe

@author  Douglas Parreja
@since   04/12/2014
/*/
//-----------------------------------------------------------------------
Function NfeDifSefaz( aImposto, cVersao , nPos )

	local lReturn 	:= .T.
	default aImposto	:= {}
	default cVersao	:= ""
	
	//------------------------------------------------------------------------------------
	// Verifico se estah na versao 3.10 e a Entidade nao eh de SP e ICMS="51" Diferimento
	//------------------------------------------------------------------------------------
	If ( cVersao >= "3.10" .AND. GetUFCode(Upper(Left(LTrim(SM0->M0_ESTENT),2))) $ "35|31" .AND. Type("aImposto["+Alltrim(Str(nPos))+"]:_Tributo") <> "U" )
		
		If ( (aImposto[nPos]:_Tributo:_CST:TEXT == "51") .AND.	;
			(Val(aImposto[nPos]:_Tributo:_ALIQUOTA:TEXT) == 0) .AND.;
			(Val(aImposto[nPos]:_Tributo:_QTRIB:TEXT) == 0) .AND.;
			(Val(aImposto[nPos]:_Tributo:_VALOR:TEXT) == 0) .AND.;
			(Val(aImposto[nPos]:_Tributo:_VBC:TEXT) == 0) .AND. ;
			(Val(aImposto[nPos]:_Tributo:_VLTRIB:TEXT) == 0))
	
			lReturn := .F.
		EndIf
	
	EndIf

Return lReturn
