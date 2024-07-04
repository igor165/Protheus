#Include 'TmsPamcard.ch'
#Include 'Protheus.ch'
#Include 'Prconst.ch'

Static nTipoCerti := 2 //Tipo do Certificado (1=.CRT;2=.PFX)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamCertDig ³ Autor:³ Gilson da Silva        ³ Data:³12/12/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Leitura do arquivo de Certificado Digital                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamCertDig(cCodOpe)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS	- INTEGRACAO VIA WEB SERVICE SISTEMA PAMCARD            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function APamCertDig(cCodOpe, aCertif )
Local lRet      	:= .T.
Local cCertDir     	:= GetSrvProfString("Startpath","")
Local cFilePemKey	:= ""
Local cFilePemCer	:= ""
Local aFilial 		:= {}
Local ckeyCNPJ		:= ''
Local cCerCNPJ		:= ''

Default cCodOpe 	:= '02'  //Codigo da operadora Pamcard no TMS.
Default aCertif		:= {}

DEG->(DbSetOrder(1)) 
If DEG->(DbSeek(xFilial('DEG')+cCodOpe))	

	cFilePemKey	:= cCertDir+AllTrim(cFilAnt)+"_certif_key.pem"
	cFilePemCer	:= cCertDir+AllTrim(cFilAnt)+"_certif_cert.pem"

	aFilial 	:= FWArrFilAtu(cEmpAnt, cFilAnt)		
	If Len(aFilial)	> 0 
		ckeyCNPJ 	:= cCertDir+AllTrim(aFilial[18])+"_certif_key.pem"
		cCerCNPJ 	:= cCertDir+AllTrim(aFilial[18])+"_certif_cert.pem"
	EndIf	

	If File(cKeyCNPJ) .And. File(cCerCNPJ)
		aAdd(aCertif,cCerCNPJ)
		aAdd(aCertif,ckeyCNPJ)
		aAdd(aCertif,Decode64(AllTrim(DEG->DEG_CODACE)))
	ElseIf File(cFilePemKey) .And. File(cFilePemCer)
		aAdd(aCertif,cFilePemCer)
		aAdd(aCertif,cFilePemKey)
		aAdd(aCertif,Decode64(AllTrim(DEG->DEG_CODACE)))							
	Else  
		Help("",1, "TMSPAM003",, STR0021 + " " + cFilePemKey + " " + STR0022 + " " + cFilePemCer + " " + STR0023 + " " + ;
					cCertDir + " " + STR0024 ,4,0)  //"Verificar se os arquivos"###" e "###" estao no diretorio "### "ou se existem."
		lRet := .F.
	EndIf	
Else  
	Help("",1, "TMSPAM018",,,3,0)  //"Operadora de Frotas não cadastrada no Protheus/TMS.
	lRet := .F.
EndIf

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSCORNTRC ³ Autor ³ Gilson da Silva      ³ Data ³ 27.Dez.11³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta RNTRC										      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSCORNTRC()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA020 - Cadastro de Fornecedores 				          ³±±
±±³          ³ INTEGRACAO VIA WEB SERVICE SISTEMA PAMCARD		    	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function aTMSCORNTRC(aRetCNPJ, cTipoCGC, cRNTRC, aCertif )
Local aFields   := {} // Array para envio de dados para Pamcard
Local oObjPam
Local cMetodo	:= 'FindRNTRC'
//--Variáveis com a posição de cada retorno do ws da Pamcard.
Local nCount    := 0
Local nPosCodMsg:= 0
Local nPosDesMsg:= 0
Local nPosSitRNT:= 0
Local nPosTipRNT:= 0
Local nPosDtVldR:= 0
Local nPosEqpRNT:= 0
Local lTMSXML    := GetMV( 'MV_TMSXML',, .F. )
Local oModelM020 := Nil
Local oViewM020	 := Nil

Default	aRetCNPJ := {}
Default cTipoCGC := ''
Default cRNTRC	 := ''
Default aCertif	 := {}

AAdd (aFields,{'viagem.contratante.documento.numero',aRetCNPJ[1]} )
AAdd (aFields,{'viagem.unidade.documento.tipo', aRetCNPJ[2] })
AAdd (aFields,{'viagem.unidade.documento.numero', aRetCNPJ[3]} )
AAdd (aFields,{'viagem.favorecido.documento.qtde', '2' } )
AAdd (aFields,{'viagem.favorecido.documento1.tipo', cTipoCGC } )
AAdd (aFields,{'viagem.favorecido.documento1.numero', AllTrim(M->A2_CGC) } )
AAdd (aFields,{'viagem.favorecido.documento2.tipo', cRNTRC } )
AAdd (aFields,{'viagem.favorecido.documento2.numero', AllTrim(M->A2_RNTRC) } )
		
/*
	Função que instância o webservice client da Operadora de Frota - Pamcard
*/

APamIsMetdo(@oObjPam, aFields, aCertif,cMetodo)
	
If !WsdlDbgLevel(3)
	GetWSCerror()
EndIf
If lTMSXML
	WSDLSaveXML(.T.)
EndIf	
If oObjPam:execute()
	If !Empty(oObjPam:oWSResponseTo:oWSFields)

		For nCount := 1 To Len(oObjPam:oWSResponseTo:oWSFields)
			If oObjPam:oWSResponseTo:oWSFields[nCount]:cKey  == 'mensagem.codigo'
				nPosCodMsg := nCount
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey  == 'mensagem.descricao'
				nPosDesMsg := nCount
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey  == 'viagem.antt.rntrc.situacao'
				nPosSitRNT := nCount				
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'viagem.antt.rntrc.tipo'
				nPosTipRNT := nCount 
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'viagem.antt.rntrc.validade'
				nPosDtVldR := nCount
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'viagem.antt.rntrc.equiparado.tac'
				nPosEqpRNT := nCount
			EndIf
		Next

		If oObjPam:oWSResponseTo:oWSFields[nPosCodMsg]:cValue == "0"
			
			If oObjPam:oWSResponseTo:oWSFields[nPosSitRNT]:cValue == "Ativo"
				M->A2_STRNTRC := "1"
			ElseIf oObjPam:oWSResponseTo:oWSFields[nPosSitRNT]:cValue == "Inativo"
				M->A2_STRNTRC := "2"
			EndIf
			
			M->A2_DTRNTRC := CToD(oObjPam:oWSResponseTo:oWSFields[nPosDtVldR]:cValue)
			
			If oObjPam:oWSResponseTo:oWSFields[nPosTipRNT]:cValue == "TAC"
				M->A2_TPRNTRC :=  "1"
			ElseIf oObjPam:oWSResponseTo:oWSFields[nPosTipRNT]:cValue == "ETC"
				M->A2_TPRNTRC := "2"
			ElseIf oObjPam:oWSResponseTo:oWSFields[nPosTipRNT]:cValue == "CTC"
				M->A2_TPRNTRC := "3"
			EndIf
			
			If oObjPam:oWSResponseTo:oWSFields[nPosEqpRNT]:cValue == "SIM"
				M->A2_EQPTAC := "1"
			ElseIf oObjPam:oWSResponseTo:oWSFields[nPosEqpRNT]:cValue $ "NAO/NÃO"
				M->A2_EQPTAC := "2"
			EndIf

			oModelM020 := FwModelActive()
			If oModelM020 <> Nil .And. oModelM020:cID == "CUSTOMERVENDOR"
				oModelM020:SetValue("SA2MASTER", "A2_STRNTRC", M->A2_STRNTRC )
				oModelM020:SetValue("SA2MASTER", "A2_TPRNTRC", M->A2_TPRNTRC )
				oModelM020:SetValue("SA2MASTER", "A2_DTRNTRC", M->A2_DTRNTRC )
				oModelM020:SetValue("SA2MASTER", "A2_EQPTAC" , M->A2_EQPTAC )
				oViewM020 := FwViewActive()
				oViewM020:SetModified(.T.)
			EndIf
		Else
			Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oWSFields[nPosDesMsg]:cValue,4,0)
		EndIf
	EndIf
EndIf

FwFreeObj(aFields)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  PamIsMetdo ºAutor  ³Leandro Paulino º 	   Data ³  02/04/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função que retorna o cabeçalho do método a ser utilizado naº±±
±±º          ³ integração com a Pamcard.                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMS - Retorna os valores do do contrato ou da viagem		  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function APamIsMetdo(oObjPam, aFields, aCertif,cMetodo, cIdcli, aRet)

Local nCount := 1
Local nCount2:= 1

Default oObjPam := Nil //--Objeto que será utilizado no execute do método da Pamcard.
Default	aFields	:= {}
Default aCertif	:= {}
Default cMetodo	:= ''	
Default cIdCli	:= '' //Variável que obtem o conteúdo da tag: viagem.id.cliente
Default aRet    :=  Array(3)

oObjPam := WSWSTransacional():New()
oObjPam:_URL 		:= PamUrlWs()
If Len(aCertif) > 2
	oObjPam:oWSarg0:ccontext := cMetodo
	oObjPam:_CERT		:= aCertif[1]
	oObjPam:_PRIVKEY	:= aCertif[2]
	oObjPam:_PASSPHRASE	:= aCertif[3]
EndIf	

oObjPam:oWSarg0:oWSfields  := {} //WSTransacional_requestTO():New()

If !Empty(cIdCli)
	AAdd(oObjPam:oWSarg0:oWSfields , WSTransacional_fieldTO():New())
	oObjPam:oWSarg0:oWSfields[1]:ckey := 'viagem.id.cliente'
	oObjPam:oWSarg0:oWSfields[1]:cvalue:= cIdCli
	aRet[3] := cIdCli
EndIf				
For nCount := 1 To Len(aFields)
	If nCount == 1 .And. !Empty(cIdCli) 
		nCount2++
	EndIf

	If !Empty(aFields[nCount][2])		
		AAdd(oObjPam:oWSarg0:oWSfields , WSTransacional_fieldTO():New())													   
		oObjPam:oWSarg0:oWSfields[nCount2]:ckey := aFields[nCount][1]
		oObjPam:oWSarg0:oWSfields[nCount2]:cvalue := aFields[nCount][2]
		nCount2++
	EndIf
	
Next nCount

Return Nil
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamFindCar ³ Autor:³ Thiago Torelli         ³ Data:³02/01/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Procura um cartão no sistema Pamcard			                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamFindCar()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS			                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function APamFindCar(aFields, lValida, lRespCart, cStatus, lAviso, aCertif, cCodFor, cLojFor, lTelaTC)
Local nCount    := 1
Local nCount2   := 1
Local oObjPam
Local cRetCert  := '' //Certificado Digital
Local lRet      := .T.
Local nPosStatus:= 0
Local aArea     := GetArea()
Local aAreaDEL  := DEL->(GetArea())
Local cMetodo 	:= 'FindCard'
Local nPosCodMsg:= 0
Local nPosCarSta:= 0
Local nPosDesMsg:= 0
Local nTamObj	:= 0
Local lTMSXML    := GetMV( 'MV_TMSXML',, .F. )

Default aFields		:= {}
Default lValida		:= .F.                         
Default lRespCart	:= .F.
Default cStatus 	:= ""
Default lAviso		:= .F.  
Default	aCertif		:= {}
Default cCodFor 	:= ""
Default cLojFor 	:= ""
Default lTelaTC		:= .F.

If Empty(aCertif)
	lRet := aPamCertDig('02', aCertif)
EndIf

If lRet
	APamIsMetdo(@oObjPam, aFields, aCertif,cMetodo)
	
	If !WsdlDbgLevel(3)
		GetWSCerror()
	EndIf
	
	If lTMSXML	
		WSDLSaveXML(.T.)
	EndIf	

	If oObjPam:execute()
		nTamObj := Len(oObjPam:oWSResponseTo:oWSFields)
		For nCount := 1 To nTamObj
			If oObjPam:oWSResponseTo:oWSFields[nCount]:cKey  == 'mensagem.codigo'
				nPosCodMsg := nCount
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey  == 'viagem.cartao.status.id'
				nPosCarSta := nCount			
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey  == 'mensagem.descricao'
				nPosDesMsg := nCount			
			EndIf
		Next

		If oObjPam:oWSResponseTo:oWSFields[nPosCodMsg]:cValue == "0"			
			lRet := .T.
			If lRespCart
				If !Empty(cCodFor)					
					DbSelectArea("DDQ")
					DDQ->(DbSetOrder(1))
					If MsSeek(xFilial("DDQ")+aFields[4][2]+cCodFor+ cLojFor) 
						If  DDQ->DDQ_STATUS <>  oObjPam:oWSResponseTo:oWSFields[nPosCarSta]:cValue
							RecLock("DDQ", .F.)	
							DDQ->DDQ_STATUS := oObjPam:oWSResponseTo:oWSFields[nPosCarSta]:cValue
							MsUnlock()
						EndIf
					Else
						DbSelectArea("DEL")
						DEL->(DbSetOrder(2))
						If DEL->(DbSeek(xFilial("DEL") + DA4->DA4_COD + '02' + aFields[4][2]))
							If  DEL->DEL_STATUS <>  oObjPam:oWSResponseTo:oWSFields[nPosCarSta]:cValue
								
								RecLock("DEL", .F.)					
								DEL->DEL_STATUS := oObjPam:oWSResponseTo:oWSFields[nPosCarSta]:cValue
								MsUnlock()
							EndIf
						EndIf
					EndIf
					
					If oObjPam:oWSResponseTo:oWSFields[nPosCarSta]:cValue == '3' 
						If !lTelaTC
							Help("",1, "TMSPAM004",,,3,0)
							lRet := .F.
						Else
							cStatus := "3"
						EndIf
					EndIf		
				Else
					M->DDQ_STATUS := oObjPam:oWSResponseTo:oWSFields[nPosCarSta]:cValue
				EndIf
			ElseIf lValida
				DbSelectArea("DEL")
				DEL->(DbSetOrder(2))
				If DEL->(DbSeek(xFilial("DEL") + DA4->DA4_COD + '02' + aFields[4][2]))
					If  DEL->DEL_STATUS <>  oObjPam:oWSResponseTo:oWSFields[nPosCarSta]:cValue
						
						RecLock("DEL", .F.)					
						DEL->DEL_STATUS := oObjPam:oWSResponseTo:oWSFields[nPosCarSta]:cValue
						MsUnlock()

					EndIf
					
				EndIf
				If oObjPam:oWSResponseTo:oWSFields[nPosCarSta]:cValue == '3' 
					If !lTelaTC
						Help("",1, "TMSPAM004",,,3,0)
						lRet := .F.
					Else
						cStatus := "3"
					EndIf
				EndIf
			Else			
				If Type("aCols") <> "U"  .And. Len(aCols) > 0				
					nPosStatus:= GDFieldPos( "DEL_STATUS" )
					aCols[n][nPosStatus] := oObjPam:oWSResponseTo:oWSFields[nPosCarSta]:cValue					
				EndIf	
			EndIf
		ElseIf oObjPam:oWSResponseTo:oWSFields[nPosCodMsg]:cValue == "4"
			If lAviso 
				Aviso('PAMCARD',oObjPam:oWSresponseTO:oWSFields[nPosDesMsg]:cValue,{'Ok'})
				lRet := .T.
			Else			
				Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oWSFields[nPosDesMsg]:cValue,4,0)
				lRet := .F.
			EndIf
		Else
			If lAviso
				Aviso('PAMCARD',oObjPam:oWSresponseTO:oWSFields[nPosDesMsg]:cValue,{'Ok'})
				
				lRet := .T.
			Else
				Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oWSFields[nPosDesMsg]:cValue,4,0)
				lRet := .F.
			EndIf
		EndIf
		If Empty(cStatus) .And. nPosCarSta > 0
			cStatus := oObjPam:oWSResponseTo:oWSFields[nPosCarSta]:cValue
		EndIf
		
	Else
		Help("",1, "TMSPAM003",,,3,0)
		lRet := .F.
	EndIf
	
	RestArea(aAreaDEL)
	RestArea(aArea)
EndIf

FwFreeObj(aAreaDEL)
FwFreeObj(aArea)


Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamRouter  ³ Autor:³ Thiago Torelli         ³ Data:³02/01/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Calcula o Valor do Pedagio de determinada Rota                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamRouter()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS			                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function APamRouter(aFields,aCertif)

Local nValPdg 	:= 0 // Valor do Pedágio retornado pela Pamcard
Local nCount  	:= 1
Local oObjPam
Local cMetodo 	:= 'Router'
Local nQtdIteRet:= 0 //--Quantidade de Itens no Retorno
Local nPosCodMsg:= 0 //--Posição do código da mensagem
Local nPosDesMsg:= 0 //--Posição da descrição da mensagem
Local nPosPdgVlr:= 0 //--Posição do valor do pedágio
Local lRet		:= .T.
Local lTMSXML   := GetMV( 'MV_TMSXML',, .F. )


Default aFields	:= {}
Default aCertif	:= {}

If Empty(aCertif)
	lRet := aPamCertDig('02', aCertif )
EndIf
If lRet
		
	APamIsMetdo(@oObjPam, aFields, aCertif,cMetodo)
	If lTMSXML
		WSDLSaveXML(.T.)
	EndIf	
	
	If oObjPam:execute()
		
		If !Empty(oObjPam:oWSresponseTO:oWSfields)

			nQtdIteRet := Len(oObjPam:oWSresponseTO:oWSfields)
			For nCount := 1 To nQtdIteRet	
				If oObjPam:oWSResponseTo:oWSFields[nCount]:cKey  == 'mensagem.codigo'
					nPosCodMsg := nCount
				ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey  == 'mensagem.descricao'
					nPosDesMsg := nCount
				ElseIf 	oObjPam:oWSResponseTo:oWSFields[nCount]:cKey  == 'viagem.pedagio.valor'
					nPosPdgVlr := nCount
				EndIf
			Next nCount


			If oObjPam:oWSresponseTO:oWSfields[nPosCodMsg]:cValue == '0'
				nValPdg := Val(oObjPam:oWSresponseTO:oWSFields[nPosPdgVlr]:cValue)
			Else
				Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oWSFields[nPosDesMsg]:cValue,4,0)
			EndIf
		EndIf
	Else
		Help("",1, "TMSPAM003",,,3,0)
	EndIf
EndIf

Return nValPdg
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamFdRNTRC ³ Autor:³ Thiago Torelli         ³ Data:³13/01/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Busca RNTRC para Veiculo e Reboques			                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamFdRNTRC()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS			                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function APamFdRNTRC(cCodFor, cLojaFor, aCertif)
Local cTipoCGC := ''
Local cRNTRC   := ''
Local aArea    := GetArea()
Local aAreaSA2 := SA2->(GetArea())
Local aFields  := {}
Local cMetodo  := 'FindRNTRC'
Local oObjPam
Local nTamObj  := 0
Local nCount   := 0
Local nCount2  := 1
Local lRet     := .T.
Local lTMSXML    := GetMV( 'MV_TMSXML',, .F. )

DbSelectArea("SA2")
DbSetOrder(1)

If DbSeek(xFilial("SA2") + cCodFor + cLojaFor)
	If (SA2->A2_TIPO) == 'F'
		cTipoCGC := "2"
		cRNTRC	 := "5"
	ElseIf (SA2->A2_TIPO) == 'J'
		cTipoCGC := "1"
		cRNTRC	 := "6"
	EndIf
	
	aRetCNPJ := PamCNPJEmp('02', cFilAnt) //Fun?o para obter CNPJ da contrante e filial de origem
	
	If Empty(aCertif)
		lRet := aPamCertDig('02', aCertif)
	EndIf
	If lRet
		AAdd (aFields,{'viagem.contratante.documento.numero',aRetCNPJ[1]} )
		AAdd (aFields,{'viagem.unidade.documento.tipo', aRetCNPJ[2] })
		AAdd (aFields,{'viagem.unidade.documento.numero', aRetCNPJ[3]} )
		AAdd (aFields,{'viagem.favorecido.documento.qtde', '2' } )
		AAdd (aFields,{'viagem.favorecido.documento1.tipo', cTipoCGC } )
		AAdd (aFields,{'viagem.favorecido.documento1.numero', Alltrim(SA2->A2_CGC)} )
		AAdd (aFields,{'viagem.favorecido.documento2.tipo', cRNTRC } )
		AAdd (aFields,{'viagem.favorecido.documento2.numero', AllTrim(SA2->A2_RNTRC) } )
				
		/*
			Função que instância o webservice client da Operadora de Frota - Pamcard
		*/

		APamIsMetdo(@oObjPam, aFields, aCertif,cMetodo)
				
		If !WsdlDbgLevel(3)
			GetWSCerror()
		EndIf
		
		If lTMSXML
			WSDLSaveXML(.T.)
		EndIf	

		If oObjPam:execute()
			If !Empty(oObjPam:oWSResponseTo:oWSFields)
				nTamObj := Len(oObjPam:oWSResponseTo:oWSFields)
				For nCount := 1 To nTamObj 
					If oObjPam:oWSResponseTo:oWSFields[nCount]:cKey  == 'mensagem.codigo'
						nPosCodMsg := nCount
					ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey  == 'mensagem.descricao'
						nPosDesMsg := nCount
					ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey  == 'viagem.antt.rntrc.situacao'
						nPosSitRNT := nCount				
					ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'viagem.antt.rntrc.tipo'
						nPosTipRNT := nCount 
					ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'viagem.antt.rntrc.validade'
						nPosDtVldR := nCount
					ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'viagem.antt.rntrc.equiparado.tac'
						nPosEqpRNT := nCount
					EndIf
				Next

				If lRet := oObjPam:oWSResponseTo:oWSFields[nPosCodMsg]:cValue == "0"
					RecLock("SA2", .F.)	
					If oObjPam:oWSResponseTo:oWSFields[nPosSitRNT]:cValue == "Ativo"
						SA2->A2_STRNTRC := "1"
					ElseIf oObjPam:oWSResponseTo:oWSFields[nPosSitRNT]:cValue == "Inativo"
						SA2->A2_STRNTRC := "2"
						lRet := .F.
					EndIf
					
					SA2->A2_DTRNTRC := CToD(oObjPam:oWSResponseTo:oWSFields[nPosDtVldR]:cValue)
					
					If oObjPam:oWSResponseTo:oWSFields[nPosTipRNT]:cValue == "TAC"
						SA2->A2_TPRNTRC :=  "1"
					ElseIf oObjPam:oWSResponseTo:oWSFields[nPosTipRNT]:cValue == "ETC"
						SA2->A2_TPRNTRC := "2"
					ElseIf oObjPam:oWSResponseTo:oWSFields[nPosTipRNT]:cValue == "CTC"
						SA2->A2_TPRNTRC := "3"
					EndIf
					
					If oObjPam:oWSResponseTo:oWSFields[nPosEqpRNT]:cValue == "SIM"
						SA2->A2_EQPTAC := "1"
					ElseIf oObjPam:oWSResponseTo:oWSFields[nPosEqpRNT]:cValue $ "NAO/NÃO"
						SA2->A2_EQPTAC := "2"
					EndIf
					MsUnLock()
				ElseIf lRet := oObjPam:oWSResponseTo:oWSFields[nPosCodMsg]:cValue == "6"									
				EndIf
			EndIf
		Else
			lRet := .F.
		EndIf
	EndIf
Else
	lRet := .F.
EndIf

RestArea(aAreaSA2)
RestArea(aArea)

FwFreeObj(aAreaSA2)
FwFreeObj(aFields)

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamFindFav ³ Autor:³ Thiago Torelli         ³ Data:³02/01/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Procura um Favorecido no Sistema Pamcard.	                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamFindFav()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS			                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function APamFindFav(aFields, aCertif)
Local nCount   	:= 1
Local nCount2  	:= 1
Local oObjPam
Local cRetCert 	:= '' //Certificado Digital
Local lRet     	:= .T.
Local cMetodo  	:= 'FindFavored'
Local nPosCodMsg:= 0
Local nPosDesMsg:= 0
Local lTMSXML    := GetMV( 'MV_TMSXML',, .F. )

Default aFields:= {}
Default	aCertif:= {}

If Empty(aCertif)
	lRet := aPamCertDig('02', aCertif)
EndIf
If lRet
	APamIsMetdo(@oObjPam,aFields, aCertif,cMetodo)				
	If !WsdlDbgLevel(3)
		GetWSCerror()
	EndIf

	If lTMSXML
		WSDLSaveXML(.T.)
	EndIf	

	If oObjPam:execute()
		nTamObj := Len(oObjPam:oWSResponseTo:oWSFields)
		For nCount := 1 To nTamObj 
			If oObjPam:oWSResponseTo:oWSFields[nCount]:cKey  == 'mensagem.codigo'
				nPosCodMsg := nCount
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey  == 'mensagem.descricao'
				nPosDesMsg := nCount
			EndIf
		Next

		If oObjPam:oWSResponseTo:oWSFields[nPosCodMsg]:cValue == "0"
			lRet := .T.
		ElseIf oObjPam:oWSResponseTo:oWSFields[nPosCodMsg]:cValue == "4"
			lRet := .F.     
			Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oWSFields[nPosDesMsg]:cValue,4,0)
		Else
			Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oWSFields[nPosDesMsg]:cValue,4,0)
			lRet:= .F.
		EndIf
	Else
		TMSErrOper('02',, '2')
		lRet:= .F.
	EndIf
EndIf
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamInsFav          ³ Autor:³ Thiago Torelli ³ Data:³02/01/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Insere um Favorecido no Sistema Pamcard		                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamInsFav()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS			                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function APamInsFav(aFields, aCertif)

Local nCount   	:= 1
Local nCount2  	:= 1
Local oObjPam
Local cRetCert 	:= '' //Certificado Digital
Local lRet     	:= .T.
Local cMetodo  	:= 'InsertFavored'
Local nTamObj  	:= 0
Local nPosCodMsg:= 0
Local nPosDesMsg:= 0
Local lTMSXML    := GetMV( 'MV_TMSXML',, .F. )

Default	aFields	:= {}
Default aCertif	:= {}

If Empty(aCertif)
	lRet := aPamCertDig('02', aCertif)
EndIf

If lRet
	
	APamIsMetdo(@oObjPam, aFields, aCertif,cMetodo)
	
	If !WsdlDbgLevel(3)
		GetWSCerror()
	EndIf
	
	If lTMSXML
		WSDLSaveXML(.T.)
	EndIf	
	
	If oObjPam:execute()
		nTamObj := Len(oObjPam:oWSResponseTo:oWSFields)
		For nCount := 1 To nTamObj 
			If oObjPam:oWSResponseTo:oWSFields[nCount]:cKey  == 'mensagem.codigo'
				nPosCodMsg := nCount
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey  == 'mensagem.descricao'
				nPosDesMsg := nCount
			EndIf
		Next
		If oObjPam:oWSResponseTo:oWSFields[nPosCodMsg]:cValue <> "0"
			Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oWSFields[nPosDesMsg]:cValue,4,0)
			lRet := .F.
		EndIf
	Else
		TMSErrOper('02',, '2')
		lRet := .F.
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamFindAcc ³ Autor:³ Thiago Torelli         ³ Data:³02/01/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Busca uma Conta de Favorecido no Pamcard.		                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamFindAcc()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS			                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function APamFindAcc(aFields,aCertif)
Local nCount   	:= 1
Local nCount2  	:= 1
Local oObjPam
Local cRetCert 	:= '' //Certificado Digital
Local lRet     	:= .T.
Local cMetodo	:= 'FindFavoredAccount'

Default	aFields := {}
Default aCertif	:= {}

If Empty(aCertif)
	lRet := aPamCertDig('02', aCertif)
EndIf
If lRet

	APamIsMetdo(@oObjPam, aFields, aCertif,cMetodo)
	
	WsdlDbgLevel(3)
	
	If oObjPam:execute()
		nTamObj := Len(oObjPam:oWSResponseTo:oWSFields)
		For nCount := 1 To nTamObj 
			If oObjPam:oWSResponseTo:oWSFields[nCount]:cKey  == 'mensagem.codigo'
				nPosCodMsg := nCount
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey  == 'mensagem.descricao'
				nPosDesMsg := nCount
			EndIf
		Next
		If oObjPam:oWSResponseTo:oWSFields[nPosCodMsg]:cValue <> "0"
			Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oWSFields[nPosDesMsg]:cValue,4,0)
			lRet := .F.
		EndIf
	Else
		Help("",1, "TMSPAM003",,,3,0)
		lRet := .F.
	EndIf

EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamInsAcc    ³ Autor:³ Thiago Torelli    Data:³02/01/2012     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Insere uma Conta de Favorecido no Pamcard.		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamInsAcc(	 )                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS			                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function APamInsAcc(aFields, aCertif)

Local nCount   := 1
Local nCount2  := 1
Local oObjPam
Local cRetCert := '' //Certificado Digital
Local lRet     := .T.
Local cMetodo  := 'InsertFavoredAccount'
Local nTamObj  := 0

Default aFields:= {}
Default aCertif:= {}

If Empty(aCertif)
	lRet := aPamCertDig('02', aCertif)
EndIf

If lRet 

	APamIsMetdo(@oObjPam, aFields, aCertif,cMetodo)
	
	WsdlDbgLevel(3)
	
	If oObjPam:execute()
		nTamObj := Len(oObjPam:oWSResponseTo:oWSFields)
		For nCount := 1 To nTamObj 
			If oObjPam:oWSResponseTo:oWSFields[nCount]:cKey  == 'mensagem.codigo'
				nPosCodMsg := nCount
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey  == 'mensagem.descricao'
				nPosDesMsg := nCount
			EndIf
		Next
		If oObjPam:oWSResponseTo:oWSFields[nPosCodMsg]:cValue <> "0"
			Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oWSFields[nPosDesMsg]:cValue,4,0)
			lRet := .F.
		EndIf
	Else
		Help("",1, "TMSPAM003",,,3,0)
		lRet := .F.
	EndIf
	
EndIf

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamInsCard ³ Autor:³ Thiago Torelli         ³ Data:³02/01/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Insere um Cartão Portador no Sistema Pamcard	                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamInsCard()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS			                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function APamInsCard(aFields, aCertif)
Local nCount   := 1
Local nCount2  := 1
Local oObjPam
Local cRetCert := '' //Certificado Digital
Local lRet     := .T.
Local cMetodo  := 'InsertCardFreight'
Local nTamObj  := 0

Default aFields:= {}
Default aCertif:= {}

If Empty(aCertif)
	lRet := aPamCertDig('02', aCertif)
EndIf

If lRet 

	APamIsMetdo(@oObjPam, aFields, aCertif,cMetodo)
	
	WsdlDbgLevel(3)
	
	If oObjPam:execute()
		nTamObj := Len(oObjPam:oWSResponseTo:oWSFields)
		For nCount := 1 To nTamObj 
			If oObjPam:oWSResponseTo:oWSFields[nCount]:cKey  == 'mensagem.codigo'
				nPosCodMsg := nCount
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey  == 'mensagem.descricao'
				nPosDesMsg := nCount
			EndIf
		Next
		If oObjPam:oWSResponseTo:oWSFields[nPosCodMsg]:cValue <> "0"
			Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oWSFields[nPosDesMsg]:cValue,4,0)
			lRet := .F.
		EndIf
	Else
		Help("",1, "TMSPAM003",,,3,0)
		lRet := .F.
	EndIf
	
EndIf

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamInsCont ³Autor: ³Thiago T Gamito         ³Data: ³17/01/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Inclui Contrato de Frete no Sistema Pamcard		  		        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamInsCont() 			                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS			                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function APamInsCont(aFields, aRet, cIdCli, aCertif)
Local nCount   	:= 1
Local nCount2  	:= 2
Local oObjPam
Local cRetCert 	:= '' //Certificado Digital
Local lRet     	:= .T.
Local cMetodo  	:= 'InsertFreightContract'
Local nTamObj	:= 0
Local nPosCodMsg:= 0
Local nPosDesMsg:= 0
Local nPosNumCIO:= 0
Local nPosIdViag:= 0
Local lTMSXML    := GetMV( 'MV_TMSXML',, .F. )

Default aFields	:= {}
Default aRet	:= {}
Default cIdCli 	:= ""
Default aCertif	:= {}

If Empty(cIdCli)
	cIdCli := PamDtHora()
EndIf

If lRet := aPamCertDig('02', aCertif)

	APamIsMetdo(@oObjPam, aFields, aCertif,cMetodo,cIdCli, aRet)

	If !WsdlDbgLevel(3)
		GetWSCerror()
	EndIf

	If lTMSXML
		WSDLSaveXML(.T.)
	EndIf	
	
	If oObjPam:execute()
		nTamObj := Len(oObjPam:oWSResponseTo:oWSFields)
		For nCount := 1 To nTamObj
			If oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'mensagem.codigo'				
				nPosCodMsg := nCount
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'mensagem.descricao'
				nPosDesMsg := nCount
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'viagem.id' 	
				nPosIdViag := nCount
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'viagem.antt.ciot.numero' 	
				nPosNumCIO := nCount
			EndIf
		Next nCount
		
		If oObjPam:oWSResponseTo:oWSFields[nPosCodMsg]:cValue == "0"			
			aRet[2] := oObjPam:oWSResponseTo:oWSFields[nPosIdViag]:cValue
            aRet[1] := oObjPam:oWSResponseTo:oWSFields[nPosNumCIO]:cValue							
		Else
			Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oWSFields[nPosDesMsg]:cValue,4,0)
			lRet := .F.
		EndIf
	Else
		TMSErrOper('02',, '2') 
		Help("",1, "TMSPAM003",, STR0011,4,0)//"Verifique se as informacoes no cadastro da operadora estão corretas."
		lRet := .F.
	EndIf
EndIf

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamStPedag ³Autor: ³Gilson da Silva         ³Data: ³09/02/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Consulta Status do Pedagio no Sistema Pamcard	  		        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamStPedag()              		                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS			                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function APamStPedag(aFields, aCertif, cMsgRet)
Local nCount   	:= 1
Local oObjPam
Local cRetCert 	:= '' //Certificado Digital
Local nRet     	:= 0
Local lRet     	:= .T.
Local cMetodo  	:= "FindTollStatus"
Local nTamObj  	:= 0
Local nPosCodMsg:= 0
Local nPosDesMsg:= 0
Local nPosStaPdg:= 0
Local lTMSXML    := GetMV( 'MV_TMSXML',, .F. )

Default aFields	:= {}
Default aCertif	:= {}
Default cMsgRet	:= ''

If Empty(aCertif)
	lRet := aPamCertDig('02', aCertif)
EndIf

If lRet
	
	aPamIsMetdo(@oObjPam, aFields, aCertif, cMetodo)

	If !WsdlDbgLevel(3)
		GetWSCerror()
	EndIf
	
	If lTMSXML	
		WSDLSaveXML(.T.)
	EndIf	

	If oObjPam:execute()
		nTamObj := Len(oObjPam:oWSResponseTo:oWSFields)
		For nCount := 1 To nTamObj
			If oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'mensagem.codigo'
				nPosCodMsg	:= nCount
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'mensagem.descricao'
				nPosDesMsg := nCount
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'viagem.pedagio.status.id'
				nPosStaPdg := nCount
			EndIf
		Next nCount

		If oObjPam:oWSResponseTo:oWSFields[nPosCodMsg]:cValue == "0"
			nRet := Val(oObjPam:oWSResponseTo:oWSFields[nPosStaPdg]:cValue)
			cMsgRet := oObjPam:oWSResponseTo:oWSFields[nPosDesMsg]:cValue
		Else
			Help("",1, "TMSPAM003",,oObjPam:oWSResponseTo:oWSFields[nPosDesMsg]:cValue,4,0)
		EndIf
	EndIf

EndIf

Return nRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamCanTrip ³Autor: ³Thiago T Gamito         ³Data: ³17/01/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Cancela uma Viagem/Contrato no Sistema Pamcard	    	        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³Cancel()				          		                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS			                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function APamCanTrip(aFields, aCertif)
Local nCount   	:= 1
Local nCount2  	:= 1
Local oObjPam
Local cRetCert 	:= '' //Certificado Digital
Local lRet     	:= .T.
Local cMetodo  	:= 'CancelTrip'
Local nPosCodMsg:= 0
Local nPosDesMsg:= 0
Local nTamObj	:= 0
Local lTMSXML    := GetMV( 'MV_TMSXML',, .F. )

If Empty(aCertif)
	lRet := aPamCertDig('02', aCertif)
EndIf

If lRet

	aPamIsMetdo(@oObjPam, aFields, aCertif, cMetodo)
		
	If !WsdlDbgLevel(3)
		GetWSCerror()
	EndIf
	
	If lTMSXML	
		WSDLSaveXML(.T.)
	EndIf	
	
	If oObjPam:execute()

		nTamObj := Len(oObjPam:oWSResponseTo:oWSFields)
		For nCount := 1 To nTamObj
			If oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'mensagem.codigo'
				nPosCodMsg	:= nCount
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'mensagem.descricao'
				nPosDesMsg := nCount
			EndIf
		Next nCount

		If oObjPam:oWSResponseTo:oWSFields[nPosCodMsg]:cValue == "0"
			lRet := .T.
		Else
			Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oWSFields[nPosDesMsg]:cValue,4,0)
			lRet := .F.
		EndIf
	Else
		TMSErrOper('02',, '2')
		lRet := .F.	
	EndIf
	
EndIf          

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamInsTrip ³ Autor:³ Thiago T Gamito        ³ Data:³17/01/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Inclui Viagem no Sistema Pamcard		  		    			        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamInsTrip()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ Fechamento da viagem, frota propria.                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function APamInsTrip(aFields, cIDOpe, cRetCert, aCertif)

Local nCount   	:= 1
Local nCount2  	:= 1
Local oObjPam
Local lRet		:= .T.
Local cMetodo  	:= 'InsertTrip'
Local nTamObj	:= 0
Local nPosCodMsg:= 0
Local nPosDesMsg:= 0
Local nPosViagId:= 0

Default aFields	:= {}
Default	cIDOpe 	:= ''
Default cRetCert:= ''
Default	aCertif	:= {}

If Empty(aCertif)
	lRet := aPamCertDig('02', aCertif)
EndIf

If lRet

	APamIsMetdo(@oObjPam, aFields, aCertif,cMetodo)

	WsdlDbgLevel(3)
	
	If oObjPam:execute()
		If !Empty(oObjPam:oWSResponseTo:oWSFields)
			nTamObj := Len(oObjPam:oWSResponseTo:oWSFields)
			For nCount := 1 To nTamObj
				If oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'mensagem.codigo'
					nPosCodMsg	:= nCount
				ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'mensagem.descricao'
					nPosDesMsg	:= nCount	
				ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'viagem.id'
					nPosViagId	:= nCount
				EndIf

			Next nCount
			
			If oObjPam:oWSResponseTo:oWSFields[nPosCodMsg]:cValue == "0"
				cIDOpe := AllTrim(oObjPam:oWSResponseTo:oWSFields[nPosViagId]:cValue)
			Else
				Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oWSFields[nPosDesMsg]:cValue,4,0)
				lRet := .F.
			EndIf
		EndIf
	Else
		TMSErrOper('02',, '2')
		lRet := .F.
	EndIf
EndIf

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamConStPa ³Autor: ³Thiago T Gamito         ³Data: ³17/01/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Consulta Status da Parcela no Sistema Pamcard	  		        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamConStPa()              		                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS			                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function APamConStPa(aFields, aCertif,lHelp)
Local nCount   	:= 0
Local oObjPam
Local cRetCert 	:= '' //Certificado Digital
Local nRet     	:= 0
Local cMetodo  	:= 'FindParcelStatus'
Local nTamObj  	:= 0
Local nPosViPaSt:= 0
Local nPosCodMsg:= 0
Local nPosDesMsg:= 0
Default	aFields	:= {}
Default aCertif	:= {}
Default lHelp 	:= .T.

If aPamCertDig('02', aCertif)

	APamIsMetdo(@oObjPam, aFields, aCertif,cMetodo)
	
	WsdlDbgLevel(3)
	
	If oObjPam:execute()
		nTamObj	:= Len(oObjPam:oWSResponseTo:oWSFields)
		For nCount := 1 To nTamObj
			If oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'mensagem.codigo' 
				nPosCodMsg := nCount
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'mensagem.descricao' 
				nPosDesMsg := nCount
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'viagem.parcela.status.id' 
				nPosViPaSt := nCount
			EndIf
		Next nCount
		If oObjPam:oWSResponseTo:oWSFields[nPosCodMsg]:cValue == "0"
			nRet := Val(oObjPam:oWSResponseTo:oWSFields[nPosViPaSt]:cValue)		
		ElseIf lHelp	
			Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oWSFields[nPosDesMsg]:cValue,4,0)
		EndIf
	EndIf
EndIf

Return nRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamAltStPa ³Autor: ³Thiago T Gamito         ³Data: ³17/01/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Altera Status da Parcela no Sistema Pamcard	     		        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamAltStPa()                   		                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS			                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function APamAltStPa(aFields, aCertif)
Local nCount   	:= 1
Local oObjPam
Local cRetCert 	:= '' //Certificado Digital
Local lRet     	:= .T.
Local cMetodo  	:= 'UpdateParcelStatus'
Local nTamObj 	:= 0
Local nPosCodMsg:= 0
Local nPosDesMsg:= 0
Default	aFields := {}
Default	aCertif	:= {}

If lRet := aPamCertDig('02', aCertif)

	aPamIsMetdo(@oObjPam, aFields, aCertif, cMetodo)

	WsdlDbgLevel(3)
	
	If oObjPam:execute()
		nTamObj := Len(oObjPam:oWSResponseTo:oWSFields)
		For nCount := 1 To nTamObj
			If oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'mensagem.codigo' 
				nPosCodMsg := nCount
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey  == 'mensagem.descricao'
				nPosDesMsg := nCount
			EndIf
		Next nCount 
		If oObjPam:oWSResponseTo:oWSFields[nPosCodMsg]:cValue == "0"
			lRet := .T.
		Else
			Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oWSFields[nPosDesMsg]:cValue,4,0)
			lRet := .F.
		EndIf
	Else
		TMSErrOper('02',, '2')
		lRet := .F.
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamSldParc ³ Autor:³ Gilson da Silva        ³ Data:³10/02/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Pesquisa numero da Parcela de Saldo a pagar no sistema Pamcard³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamSldParc()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS			                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function APamSldParc(aFields,nAcao, aCertif)  
Local nCount 	:= 1
Local nCount2  	:= 1 
Local nQtdParc  := 0    
Local nParc     := 0
Local nPos      := 0  
Local oObjPam
Local cRetCert 	:= '' //Certificado Digital
Local lRet     	:= .T.
Local nVlrPar	:= 0
Local cNumCli	:= ''
Local aParCTC   := {}                         
Local cStatus	:= ''     
Local cCartao   := ""     
Local cMetodo 	:= "FindFreightContract"
Local nPosQtdPar:= 0 	//--Posicao da Quantidade de Parcelas
Local nPosCodMsg:= 0
Local nPOsDesMsg:= 0
Local nTamObj	:= 0
Local nExit		:= 0 //Variavel de Controle para sair do laço que busca posições das tags
Local nQtdTag	:= 3 //--Quantidade de Tags que devem ter suas posições ser verificadas
Local lTMSXML    := GetMV( 'MV_TMSXML',, .F. )

Default aFields := {}
Default nAcao 	:= 1
Default aCertif	:= {}

If Empty(aCertif)
	lRet := aPamCertDig('02', aCertif)
EndIf

If lRet
	
	APamIsMetdo(@oObjPam, aFields, aCertif,cMetodo)

	If !WsdlDbgLevel(3)
		GetWSCerror()
	EndIf
	
	If lTMSXML
		WSDLSaveXML(.T.)
	EndIf	

	If oObjPam:execute()
		
		nTamObj := Len(oObjPam:oWSResponseTo:oWSFields)
		For nCount:= 1 To nTamObj
			
			If oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'mensagem.codigo' 
				nPosCodMsg	:= nCount
				nExit ++
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'mensagem.descricao' 
				nPOsDesMsg	:= nCount
				nExit ++
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'viagem.parcela.qtde' 
				nPosQtdPar	:= nCount
				nExit ++
			EndIf
			If nExit == nQtdTag
				Exit
			EndIf
		Next nCount
		
		If oObjPam:oWSResponseTo:oWSFields[nPosCodMsg]:cValue == "0"
						
			nQtdParc := Val(oObjPam:oWSResponseTo:oWSFields[nPosQtdPar]:cValue)
			For nParc := 1  To nQtdParc
				//--Só traz as parcelas que não foram excluídas se a acao for 2--Estorno
				nPos := Ascan(oObjPam:oWSResponseTo:oWSFields,{|x| AllTrim(x:cKey)=="viagem.parcela"+Alltrim(Str(nParc))+".status.id"})
				cStatus := Iif(nPos >0,AllTrim(oObjPam:oWSResponseTo:oWSFields[nPos]:cValue),'')
				If nAcao == 1 .Or. ( nAcao == 2 .and. cStatus <> '4')
					nPos := Ascan(oObjPam:oWSResponseTo:oWSFields,{|x| AllTrim(x:cKey)=="viagem.parcela"+Alltrim(Str(nParc))+".numero.cliente"}) 
					cNumCli := Iif(nPos >0,AllTrim(oObjPam:oWSResponseTo:oWSFields[nPos]:cValue),'')
					nPos := Ascan(oObjPam:oWSResponseTo:oWSFields,{|x| AllTrim(x:cKey)=="viagem.parcela"+Alltrim(Str(nParc))+".valor"})
					nVlrPar := Iif(nPos >0,Val(AllTrim(oObjPam:oWSResponseTo:oWSFields[nPos]:cValue)),0)
					nPos := Ascan(oObjPam:oWSResponseTo:oWSFields,{|x| AllTrim(x:cKey)=="viagem.favorecido"+Alltrim(Str(nParc))+".cartao.numero"})
					cCartao := Iif(nPos >0,Val(AllTrim(oObjPam:oWSResponseTo:oWSFields[nPos]:cValue)),0)
					AAdd(aParCTC,{cNumCli,nVlrPar, cStatus, cCartao, nParc})	
				EndIf	
			Next
		Else
			Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oWSFields[2]:cValue,4,0)			
		EndIf
	Else	
		Help("",1, "TMSPAM003",,,3,0)
	EndIf		
	
EndIf    

Return aParCTC

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamVlrParc ³ Autor:³ Thiago Torelli         ³ Data:³19/01/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Atualiza Valores para os Contrato no Sistema Pamcard			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamVlrParc()											                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS			                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function APamVlrParc(aFields, aCertif)
Local nCount   	:= 1
Local nCount2  	:= 1
Local oObjPam
Local cRetCert 	:= '' //Certificado Digital
Local lRet		:= .T.
Local cMetodo  	:= 'UpdateValuesFreightContract'
Local nTamObj  	:= 0
Local nExit	   	:= 0	//--Variavel de Controle para sair do laço que busca posições das tags
Local nQtdTag  	:= 2 //--Quantidade de Tags que devem ter suas posições ser verificadas
Local nPosCodMsg:= 0
Local nPosDesMsg:= 0
Local lTMSXML    := GetMV( 'MV_TMSXML',, .F. )

Default aFields:= {}	
Default aCertif:= {}

If Empty(aCertif)
	lRet := aPamCertDig('02', aCertif)
EndIf

If lRet

	APamIsMetdo(@oObjPam, aFields, aCertif,cMetodo)

	If !WsdlDbgLevel(3)
		GetWSCerror()
	EndIf
	
	If lTMSXML
		WSDLSaveXML(.T.)
	EndIf
	
	If oObjPam:execute()

		nTamObj := Len(oObjPam:oWSResponseTo:oWSFields)
		For nCount:= 1 To nTamObj
			
			If oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'mensagem.codigo' 
				nPosCodMsg	:= nCount
				nExit ++
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'mensagem.descricao' 
				nPOsDesMsg	:= nCount
				nExit ++			
			EndIf
			If nExit == nQtdTag
				Exit
			EndIf

		Next nCount
		
		If oObjPam:oWSResponseTo:oWSFields[nPosCodmsg]:cValue == "0"
			lRet := .T.
		Else
			Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oWSFields[nPosDesMsg]:cValue,4,0)
			lRet := .F.
		EndIf
	Else
		lRet := .F.
	EndIf
	
EndIf

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamAltCtWs ³Autor: ³ Daniel Carlos Leme     ³Data: ³17/08/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Altera Contrato de Frete no Sistema Pamcard		  	        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamAltCtWs() 		                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS			                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function APamAltCtWs(aFields, cIdCli, aCertif)
Local nCount   	:= 1
Local cRetCert 	:= '' //Certificado Digital
Local lRet     	:= .T.
Local cMetodo  	:= 'UpdateFreightContract'
Local oObjPam
Local nPosCodmsg:= 0
Local nPosDesMsg:= 0
Local nPosViagId:= 0
Local nPosNumCIO:= 0
Local nTamObj	:= 0
Local lTMSXML    := GetMV( 'MV_TMSXML',, .F. )

Default aFields	:= {}
Default cIdCli 	:= ""
Default aCertif := {}

If Empty(cIdCli)
	cIdCli := PamDtHora()
EndIf

If Empty(aCertif)
	lRet := aPamCertDig('02', aCertif)
EndIf

If lRet

	APamIsMetdo(@oObjPam, aFields, aCertif,cMetodo, cIdCli)

	If !WsdlDbgLevel(3)
		GetWSCerror()
	EndIf

	If lTMSXML
		WSDLSaveXML(.T.)
	EndIf	
	
	If oObjPam:execute()
		nTamObj := Len(oObjPam:oWSResponseTo:oWSFields) 
		For nCount := 1 To nTamObj
			If oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'mensagem.codigo' 				
				nPosCodMsg := nCount			
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey  == 'mensagem.descricao'
				nPosDesMsg := nCount
			EndIf	
		Next nCount
		
		If oObjPam:oWSResponseTo:oWSFields[nPosCodmsg]:cValue <> "0"
			Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oWSFields[nPosDesMsg]:cValue,4,0)
			lRet := .F.
		EndIf
	Else
		TMSErrOper('02',, '2') 
		Help("",1, "TMSPAM003",, STR0011,4,0)//"Verifique se as informacoes no cadastro da operadora estão corretas."
		lRet := .F.
	EndIf
EndIf

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamAltVrWs ³Autor: ³ Daniel Carlos Leme     ³Data: ³17/08/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Altera Valores no CIOT por periodo no sistema Pamcard         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamAltVrWs() 		                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS			                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function APamAltVrWs(aFields, cIdCli, aCertif)
Local nCount   	:= 1
Local oObjPam
Local cRetCert 	:= '' //Certificado Digital
Local lRet     	:= .T.
Local cMetodo  	:= "UpdateValuesFreightContract"
Local nTamObj  	:= 0
Local nPosCodMsg:= 0
Local nPosDesMsg:= 0
Local lTMSXML    := GetMV( 'MV_TMSXML',, .F. )

Default aFields := {}
Default cIdCli  := ""
Default aCertif := ""

If Empty(cIdCli)
	cIdCli := PamDtHora()
EndIf

If Empty(aCertif)
	lRet := aPamCertDig('02', aCertif)
EndIf

If lRet
	
	APamIsMetdo(@oObjPam, aFields, aCertif,cMetodo, cIdcli)	

	If !WsdlDbgLevel(3)
		GetWSCerror()
	EndIf
	
	If lTMSXML
		WSDLSaveXML(.T.)
	EndIf
	
	If oObjPam:execute()
		
		nTamObj := Len(oObjPam:oWSResponseTo:oWSFields) 
		For nCount := 1 To nTamObj
			If oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'mensagem.codigo' 				
				nPosCodMsg := nCount			
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey  == 'mensagem.descricao'
				nPosDesMsg := nCount
			EndIf	
		Next nCount
		
		If oObjPam:oWSResponseTo:oWSFields[nPosCodMsg]:cValue <> "0"			
			Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oWSFields[nPosDesMsg]:cValue,4,0)
			lRet := .F.
		EndIf
	Else
		TMSErrOper('02',, '2') 
		Help("",1, "TMSPAM003",, STR0011,4,0)//"Verifique se as informacoes no cadastro da operadora estão corretas."
		lRet := .F.
	EndIf
EndIf

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamEncWs   ³Autor: ³ Daniel Carlos Leme     ³Data: ³17/08/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Altera Valores no CIOT por periodo no sistema Pamcard         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamAltVrWs() 		                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS			                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function APamEncWs(aFields, aCertif)
Local nCount   	:= 1
Local nCount2  	:= 1
Local oObjPam
Local cRetCert 	:= '' //Certificado Digital
Local lRet     	:= .T.
Local cMetodo  	:= 'CloseFreightContract'
Local nTamObj  	:= 0
Local nPosCodMsg:= 0
Local nPosDesMsg:= 0
Local lTMSXML    := GetMV( 'MV_TMSXML',, .F. )

Default aFields	:= {}
Default aCertif	:= {}

If Empty(aCertif)
	lRet := aPamCertDig('02', aCertif)
EndIf

If lRet

	APamIsMetdo(@oObjPam, aFields, aCertif,cMetodo)	
	
	If !WsdlDbgLevel(3)
		GetWSCerror()
	EndIf
	If lTMSXML
		WSDLSaveXML(.T.)	
	EndIf
	
	If oObjPam:execute()		
		nTamObj := Len(oObjPam:oWSResponseTo:oWSFields) 
		
		For nCount := 1 To nTamObj
			If oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'mensagem.codigo' 				
				nPosCodMsg := nCount
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey  == 'mensagem.descricao'
				nPosDesMsg := nCount
			EndIf	
		Next nCount		

		If oObjPam:oWSResponseTo:oWSFields[nPosCodMsg]:cValue <> "0"
			Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oWSFields[nPosDesMsg]:cValue,4,0)
			lRet := .F.
		EndIf
	Else
		Help("",1, "TMSPAM003",, STR0011,4,0)//"Verifique se as informacoes no cadastro da operadora estão corretas."
		lRet := .F.
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³aPamTipFav ³ Autor:³ Katia Bianchi          ³ Data:³22/08/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Pesquisa o tipo de favorecido no sistema Pamcard              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³aPamTipFav()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS			                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function aPamTipFav(aFields,cCard, aCertif)  
Local nCount 	:= 1
Local nCount2  	:= 1 
Local nQtdFav   := 0    
Local nFav      := 0
Local nPos      := 0  
Local oObjPam
Local cRetCert 	:= '' //Certificado Digital
Local lRet     	:= .T.
Local cTipFav   := ''                         
Local cCartao   := ""     
Local cMetodo 	:= "FindFreightContract"
Local nPosQtdFav:= 0 	//--Posicao da Quantidade de Favorecidos
Local nPosCodMsg:= 0
Local nPOsDesMsg:= 0
Local nTamObj	:= 0
Local nExit		:= 0 //Variavel de Controle para sair do laço que busca posições das tags
Local nQtdTag	:= 3 //--Quantidade de Tags que devem ter suas posições ser verificadas
Local lTMSXML    := GetMV( 'MV_TMSXML',, .F. )

Default aFields := {}
Default cCard 	:= ''
Default aCertif	:= {}

If Empty(aCertif)
	lRet := aPamCertDig('02', aCertif)
EndIf

If lRet
	
	APamIsMetdo(@oObjPam, aFields, aCertif,cMetodo)

	If !WsdlDbgLevel(3)
		GetWSCerror()
	EndIf
	
	If lTMSXML
		WSDLSaveXML(.T.)
	EndIf	

	If oObjPam:execute()
		
		nTamObj := Len(oObjPam:oWSResponseTo:oWSFields)
		For nCount:= 1 To nTamObj
			
			If oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'mensagem.codigo' 
				nPosCodMsg	:= nCount
				nExit ++
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'mensagem.descricao' 
				nPOsDesMsg	:= nCount
				nExit ++
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'viagem.favorecido.qtde' 
				nPosQtdFav	:= nCount
				nExit ++
			EndIf
			If nExit == nQtdTag
				Exit
			EndIf
		Next nCount
		
		If oObjPam:oWSResponseTo:oWSFields[nPosCodMsg]:cValue == "0"
						
			nQtdFav := Val(oObjPam:oWSResponseTo:oWSFields[nPosQtdFav]:cValue)
			For nFav := 1  To nQtdFav
				nPos := Ascan(oObjPam:oWSResponseTo:oWSFields,{|x| AllTrim(x:cKey)=="viagem.favorecido"+Alltrim(Str(nFav))+".cartao.numero"})
				cCartao := Iif(nPos >0,AllTrim(oObjPam:oWSResponseTo:oWSFields[nPos]:cValue),"0")
				If cCard == cCartao
					nPos := Ascan(oObjPam:oWSResponseTo:oWSFields,{|x| AllTrim(x:cKey)=="viagem.favorecido"+Alltrim(Str(nFav))+".tipo"})
					cTipFav := Iif(nPos >0,AllTrim(oObjPam:oWSResponseTo:oWSFields[nPos]:cValue),0)
				EndIf
			Next
		Else
			Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oWSFields[2]:cValue,4,0)			
		EndIf
	Else	
		Help("",1, "TMSPAM003",,,3,0)
	EndIf		
	
EndIf    

Return cTipFav

//-------------------------------------------------------------------
/*PamFrtMin
Monta array com os dados necessários para consulta do Frete Mínimo 
@author  Leandro Paulino
@since   07/10/2019
@version 1.0      
*/
//-------------------------------------------------------------------
Function PamFrtMin(cCatVei, nKmDista, cCargaTipo, nVlrFrete)

Local aFields 		:= {}
Local aRetCNPJ		:= {}
Local aAreaDEG		:= DEG->(GetArea()) 
Local cCodOpe		:= '02' //-Códiga operadora
Local cFilFor   	:= Posicione( 'DEG',1,FwxFilial('DEG')+cCodOpe,'DEG_FILCTR')
Local lRet 			:= 	.F.
Local oObjPam		
Local aCertif 		:= {}
Local cMetodo 		:= "FindMinimumFreight"
Local lTMSXML   	:= GetMV( 'MV_TMSXML',, .F. )
Local nPosCodMsg	:= 0
Local nPOsDesMsg	:= 0
Local nPosFrtMin	:= 0
Local nFrtMinPam	:= 0 //--Valor do Frete Mínimo retornado pela Pamcard.
Local nCount		:= 0
Local nTamObj		:= 0
Local cContrat		:= '1'
Local cAltoDes		:= 'S'
Local lVgeMod3      := Iif(FindFunction('TmsVgeMod3'),TmsVgeMod3(),.F.)  //Viagem Modelo 3

Default cCatVei		:= ''
Default nKmDista	:= 0
Default cCargaTipo	:= ''
Default nVlrFrete	:= 0

aRetCNPJ := PamCNPJEmp(cCodOpe, cFilFor) //Função para obter CNPJ da contrante e filial de origem

If IsFrotProp(M->DTR_CODVEI) .And. IsLotacao( M->DTQ_FILORI , M->DTQ_VIAGEM , M->DTQ_SERTMS )
	cContrat	:= '1'
	cAltoDes	:= 'S'
Else
	cContrat	:= '2'
	cAltoDes	:= 'N'
EndIf

AAdd (aFields,{'viagem.contratante.documento.numero'		, aRetCNPJ[1]})
AAdd (aFields,{'viagem.unidade.documento.tipo'				, aRetCNPJ[2]})
AAdd (aFields,{'viagem.unidade.documento.numero'			, aRetCNPJ[3]})
AAdd (aFields,{'viagem.veiculo.categoria'					, cCatVei 		})
AAdd (aFields,{'viagem.carga.tipo'							, cCargaTipo 	})
AAdd (aFields,{'viagem.distancia.km'						, AllTrim(TransForm( nKmDista, '@E 999999999'))})
AAdd (aFields,{'viagem.frete.valor.bruto'					, AllTrim(TransForm( nVlrFrete, '@E 999999999.99'))})
AAdd (aFields,{'viagem.contratacao.tipo'                    , cContrat }) 
AAdd (aFields,{'viagem.veiculo.altodesempenho.indicador'    , cAltoDes })

lRet := aPamCertDig('02', aCertif)

If lRet
	
	APamIsMetdo(@oObjPam, aFields, aCertif,cMetodo)

	If !WsdlDbgLevel(3)
		GetWSCerror()		
	EndIf
	
	If lTMSXML
		WSDLSaveXML(.T.)
	EndIf	

	If oObjPam:execute()
		nTamObj := Len(oObjPam:oWSResponseTo:oWSFields)		

		For nCount:= 1 To nTamObj
		
			If oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'mensagem.codigo' 
				nPosCodMsg	:= nCount
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'mensagem.descricao' 
				nPOsDesMsg	:= nCount
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'viagem.frete.minimo.valor' 
				nPosFrtMin	:= nCount
			EndIf
		Next nCount

		If oObjPam:oWSResponseTo:oWSFields[nPosCodMsg]:cValue == "0"
						
			nFrtMinPam := Val(oObjPam:oWSResponseTo:oWSFields[nPosFrtMin]:cValue)
			If nVlrFrete < nFrtMinPam 
				lRet := .F. 				
				If lVgeMod3
					MsgInfo(STR0026 + Chr(13) + CHR(10) +  STR0027 + TransForm( nFrtMinPam, '@E 999999999.99'),'TMSPAM017')
				Else
					Help( ,,'TmsPam017',, STR0026 + Chr(13) + CHR(10) +  STR0027 + TransForm( nFrtMinPam, '@E 999999999.99') , 1 , 0 ) //--"Valor Mínimo de Frete não atende tabela ANTT. "//--" Valor ANTT: "
				EndIf
			EndIf
			
		Else
			If lVgeMod3
				MsgInfo(STR0028 + Chr(13) + CHR(10) + oObjPam:oWSresponseTO:oWSFields[nPOsDesMsg]:cValue,'TMSPAM003') // "Falha na Integração com Sistema Pamcard."
			Else
				Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oWSFields[nPOsDesMsg]:cValue,4,0)			
			EndIf
			LRet := .F.
		EndIf
	Else	
		If lVgeMod3
			MsgInfo(STR0028,'TMSPAM003') // "Falha na Integração com Sistema Pamcard."
		Else
			Help("",1, "TMSPAM003",,,3,0)
		EndIf
		
		lRet := .F.
	EndIf		
	
EndIf

RestArea(aAreaDEG)

FwFreeObj(aFields)

Return lRet

//-------------------------------------------------------------------
/*IsLotacao
Verifica se a viagem é lotacao
@author  Caio Murakami
@since   10/03/2020
@version 1.0      
*/
//-------------------------------------------------------------------
Static Function IsLotacao( cFilOri , cViagem , cSerTMS )
Local lRet		:= .F. 
Local nQtdDoc	:= 0 

Default cFilOri		:= ""
Default cViagem		:= ""
Default cSerTMS		:= ""

//-- Verifica se a Viagem ?do Tipo Lotacao (um unico Documento na Viagem)
//-- Quantidade de documentos da viagem
If PamQtDocVg(cFilOri,cViagem,cSerTMS) == 1
	lRet:= .T.
EndIf
	
Return lRet

//-------------------------------------------------------------------
/*IsFrotProp
Verifica se é frota própria
@author  Caio Murakami
@since   10/03/2020
@version 1.0      
*/
//-------------------------------------------------------------------
Static Function IsFrotProp(cCodVei)
Local lRet		:= .F. 
Local aAreaDA3	:= DA3->(GetArea())

Default cCodVei		:= ""

//Posiciona na tabela de veiculos.
DA3->(DbSetOrder(1))
If DA3->(DbSeek(xFilial('DA3')+ cCodVei ))
	If DA3->DA3_FROVEI ==  StrZero(1,Len(DA3->DA3_FROVEI))  //-- 1-Propria
		lRet	:= .T. 
	EndIf
EndIf

RestArea( aAreaDA3 )
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamFindTag ³ Autor:³                        ³ Data:³05/04/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Consulta TAG									                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamFindTag()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS			                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamFindTag(aFields)

Local nCount        := 1
Local oObjPam
Local lRet          := .T.
Local aArea         := GetArea()
Local cMetodo 	    := 'FindTag'
Local nPosCodMsg    := 0
Local nPosCarSta    := 0
Local nPosDesMsg    := 0
Local nTamObj	    := 0
Local lTMSXML       := GetMV( 'MV_TMSXML',, .F. )
Local aCertif       := {}

If Empty(aCertif)
	lRet := aPamCertDig('02', aCertif)
EndIf

If lRet
	APamIsMetdo(@oObjPam, aFields, aCertif,cMetodo)
	
	If !WsdlDbgLevel(3)
		GetWSCerror()
	EndIf
	
	If lTMSXML	
		WSDLSaveXML(.T.)
	EndIf	

	If oObjPam:execute()
		nTamObj := Len(oObjPam:oWSResponseTo:oWSFields)
		For nCount := 1 To nTamObj
			If oObjPam:oWSResponseTo:oWSFields[nCount]:cKey  == 'mensagem.codigo'
				nPosCodMsg := nCount
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey  == 'mensagem.descricao'
				nPosDesMsg := nCount			
			EndIf
		Next
		If oObjPam:oWSResponseTo:oWSFields[nPosCodMsg]:cValue == "0"			
			lRet := .T.
		Else
			Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oWSFields[nPosDesMsg]:cValue,4,0)
			lRet := .F.
		EndIf

	Else
		Help("",1, "TMSPAM003",,,3,0)
		lRet := .F.
	EndIf
	

	RestArea(aArea)
EndIf

FwFreeObj(aArea)

Return lRet


//-------------------------------------------------------------------
/*PamPayToll - Pagamento de Pedagio via TAG
@author  Katia
@since   05/04/2021
@version 1.0      
*/
//-------------------------------------------------------------------
Function PamPayToll(cIdOpe,cIdCli,cCiot)

Local aFields 		:= {}
Local aRetCNPJ		:= {}
Local aAreaDEG		:= DEG->(GetArea()) 
Local cCodOpe		:= '02' //-C?iga operadora
Local cFilFor   	:= Posicione( 'DEG',1,FwxFilial('DEG')+cCodOpe,'DEG_FILCTR')
Local lRet 			:= 	.F.
Local oObjPam		
Local aCertif 		:= {}
Local cMetodo 		:= "PayToll"
Local lTMSXML   	:= GetMV( 'MV_TMSXML',, .F. )
Local nPosCodMsg	:= 0
Local nPOsDesMsg	:= 0
Local nCount		:= 0
Local nTamObj		:= 0

Default cIdOpe      := ""
Default cIdCli      := ""
Default cCiot       := ""

aRetCNPJ := PamCNPJEmp(cCodOpe, cFilFor) //Fun?o para obter CNPJ da contrante e filial de origem

AAdd (aFields,{'viagem.contratante.documento.numero'		, aRetCNPJ[1]})
AAdd (aFields,{'viagem.unidade.documento.tipo'				, aRetCNPJ[2]})
AAdd (aFields,{'viagem.unidade.documento.numero'			, aRetCNPJ[3]})
AAdd (aFields,{'viagem.id'								    , AllTrim(cIdOpe) })
AAdd (aFields,{'viagem.id.cliente'							,  })
AAdd (aFields,{'viagem.antt.ciot.numero'					, AllTrim(cCiot) })

lRet := aPamCertDig('02', aCertif)

If lRet
	
	APamIsMetdo(@oObjPam, aFields, aCertif,cMetodo)

	If !WsdlDbgLevel(3)
		GetWSCerror()		
	EndIf
	
	If lTMSXML
		WSDLSaveXML(.T.)
	EndIf	

	If oObjPam:execute()
		nTamObj := Len(oObjPam:oWSResponseTo:oWSFields)		

		For nCount:= 1 To nTamObj
		
			If oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'mensagem.codigo' 
				nPosCodMsg	:= nCount
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'mensagem.descricao' 
				nPOsDesMsg	:= nCount
			EndIf
		Next nCount

		If oObjPam:oWSResponseTo:oWSFields[nPosCodMsg]:cValue == "0"
			lRet:= .T.									
		Else
			Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oWSFields[nPosDesMsg]:cValue,4,0)
			lRet := .F.
		EndIf
	Else	
		Help("",1, "TMSPAM003",,,4,0)
		lRet := .F.
	EndIf		
	
EndIf

RestArea(aAreaDEG)

FwFreeObj(aFields)

Return lRet

//-------------------------------------------------------------------
/*PamUpdToll - Altera Status do Pedagio
@author  Katia
@since   06/04/2021
@version 1.0      
*/
//-------------------------------------------------------------------
Function PamUpdToll(cIdOpe,cIdCli,cCiot,cStatus)

Local aFields 		:= {}
Local aRetCNPJ		:= {}
Local aAreaDEG		:= DEG->(GetArea()) 
Local cCodOpe		:= '02' //-Códiga operadora
Local cFilFor   	:= Posicione( 'DEG',1,FwxFilial('DEG')+cCodOpe,'DEG_FILCTR')
Local lRet 			:= 	.F.
Local oObjPam		
Local aCertif 		:= {}
Local cMetodo 		:= "UpdateTollStatus"
Local lTMSXML   	:= GetMV( 'MV_TMSXML',, .F. )
Local nPosCodMsg	:= 0
Local nPOsDesMsg	:= 0
Local nCount		:= 0
Local nTamObj		:= 0

Default cIdOpe      := ""
Default cIdCli      := ""
Default cCiot       := ""
Default cStatus     := ""
/*------- Status 
1- Pendente   (Entrada/saida)
2- Liberado   (Entrada/saida)
3- Bloqueado  (Entrada/saida)
4- excluido   (saida)
5- carregado  (saida)
6- sem fundo  (saida)
7- Erro       (saida) 
8- Autorizado (saida)
----------------------*/

/*--------------------
1- Pendente -> 2- Liberado   //Se pendente, deve alterar para liberado
2- Liberado -> 3- Bloqueado  //Se liberado, deve alterar para bloqueado
5- carregamento (TAG)    - viagem deve ser cancelada dentro do prazo, dependendo da Pamcard com estorno ou não do valor
5- carregamento (CARTAO) - viagem é cancelada, porem não há estorno do valor
---------------------*/

aRetCNPJ := PamCNPJEmp(cCodOpe, cFilFor) //Função para obter CNPJ da contrante e filial de origem

AAdd (aFields,{'viagem.contratante.documento.numero'		, aRetCNPJ[1]})
AAdd (aFields,{'viagem.unidade.documento.tipo'				, aRetCNPJ[2]})
AAdd (aFields,{'viagem.unidade.documento.numero'			, aRetCNPJ[3]})
AAdd (aFields,{'viagem.id'								    , AllTrim(cIdOpe) })
AAdd (aFields,{'viagem.id.cliente'							, AllTrim(cIdCli) })
AAdd (aFields,{'viagem.antt.ciot.numero'					, AllTrim(cCiot) })
AAdd (aFields,{'viagem.pedagio.status.id'					, cStatus })

lRet := aPamCertDig('02', aCertif)

If lRet
	
	APamIsMetdo(@oObjPam, aFields, aCertif,cMetodo)

	If !WsdlDbgLevel(3)
		GetWSCerror()		
	EndIf
	
	If lTMSXML
		WSDLSaveXML(.T.)
	EndIf	

	If oObjPam:execute()
		nTamObj := Len(oObjPam:oWSResponseTo:oWSFields)		

		For nCount:= 1 To nTamObj
		
			If oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'mensagem.codigo' 
				nPosCodMsg	:= nCount
			ElseIf oObjPam:oWSResponseTo:oWSFields[nCount]:cKey == 'mensagem.descricao' 
				nPOsDesMsg	:= nCount
			EndIf
		Next nCount

		If oObjPam:oWSResponseTo:oWSFields[nPosCodMsg]:cValue == "0"
			lRet:= .T.									
		Else
			MsgInfo(STR0028 + Chr(13) + CHR(10) + oObjPam:oWSresponseTO:oWSFields[nPOsDesMsg]:cValue,'TMSPAM003') // "Falha na Integração com Sistema Pamcard."
			LRet := .F.
		EndIf
	Else	
		MsgInfo(STR0028,'TMSPAM003') // "Falha na Integração com Sistema Pamcard."
		lRet := .F.
	EndIf		
	
EndIf

RestArea(aAreaDEG)

FwFreeObj(aFields)

Return lRet
