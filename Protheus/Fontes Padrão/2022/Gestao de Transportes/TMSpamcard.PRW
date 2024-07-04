#Include 'TmsPamcard.ch'
#Include 'Protheus.ch'
#Include 'Prconst.ch'
#INCLUDE "FWMVCDEF.CH"

Static lDTYParCTC := DTY->(FieldPos('DTY_PARCTC') > 0 )
Static nTipoCerti := 1 //Tipo do Certificado (1=.CRT;2=.PFX)

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
Function PamCertDig(cCodOpe, cCertDig, aCertif )
Local cArq      	:= ""
Local nHandle 		:= ""
Local aVetor    	:= {}                                     
Local cString 		:= ''
Local lRet      	:= .T.
Local cCertDir     	:= GetSrvProfString("Startpath","")
Local cFilePemKey	:= ""
Local cFilePemCer	:= ""
Local cFormatArq	:= 'CRT'
Local aFilial 		:= {}
Local ckeyCNPJ		:= ''
Local cCerCNPJ		:= ''
Default cCodOpe 	:= '02'  //Codigo da operadora Pamcard no TMS.
Default cCertDig	:= ''	 //Certificado digital
Default aCertif		:= {}

DEG->(DbSetOrder(1)) 
If DEG->(DbSeek(xFilial('DEG')+cCodOpe))	
	cArq := AllTrim(DEG->DEG_CERTDG)
	cFormatArq := UPPER(SubStr(cArq,Len(cArq) - 2,3))
	nTipoCerti := IIf(cFormatArq == 'CRT',1,IIf(cFormatArq == 'PFX',2,0))
	If (nTipoCerti) == 1	

		If File(cArq)
			nHandle := FOpen(cArq)
			If nHandle < 0
				Aviso(STR0001, STR0002 + DEG->DEG_CODOPE, {STR0003}  )  //"Atenção" ###"Nao foi possivel abrir o arquivo do Certificado Digital da Operadora"###"Continuar"
				cCertDig := ""
			EndIf
			FRead( nHandle, cString, 5000) // Ler os primeiros 5000 bytes do arquivo
			aVetor := StrTokArr(cString, '-----')
			cCertDig := Alltrim(aVetor[2])
			Fclose(nHandle)
		Else
			Aviso( STR0001, STR0004, {STR0005} )  //"Atenção"###"Arquivo de Certificado Digital não encontrado no local informado, verifique na rotina Cadastro da Operadora de Frotas se o local indicado está correto."###"Verifique"
			cCertDig := ""
			lRet := .F.
		EndIf
	ElseIf nTipoCerti == 2

		aFilial 	:= FWArrFilAtu(cEmpAnt, cFilAnt)		
		
		ckeyCNPJ 	:= cCertDir+AllTrim(aFilial[18])+"_certif_key.pem"
		cCerCNPJ 	:= cCertDir+AllTrim(aFilial[18])+"_certif_cert.pem"
				
		cFilePemKey	:= cCertDir+AllTrim(cFilAnt)+"_certif_key.pem"
		cFilePemCer	:= cCertDir+AllTrim(cFilAnt)+"_certif_cert.pem"
		
		If File(cKeyCNPJ) .And. File(cCerCNPJ)
			aAdd(aCertif,cCerCNPJ)
			aAdd(aCertif,ckeyCNPJ)
			aAdd(aCertif,Decode64(AllTrim(DEG->DEG_CODACE)))							
		ElseIf File(cFilePemKey) .And. File(cFilePemCer)
			aAdd(aCertif,cFilePemCer)
			aAdd(aCertif,cFilePemKey)
			aAdd(aCertif,Decode64(AllTrim(DEG->DEG_CODACE)))							
		Else
			Aviso( 	STR0001, STR0021 + " " + cFilePemKey + " " + STR0022 + " " + cFilePemCer + " " + STR0023 + " " + ;
					cCertDir + " " + STR0024, {STR0005} )  //"Atenção"###"Verificar se os arquivos"###" e "###" estao no diretorio "### "ou se existem."
			lRet := .F.
		EndIf	
	EndIf
Else
	Aviso(STR0001 , STR0006, {STR0005} ) //"Atenção"###"Operadora de Frotas não cadastrada no Protheus/TMS."###"Verifique"
	lRet := .F.
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamUrlWs   ³ Autor:³ Gilson da Silva        ³ Data:³12/12/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Retorna a URL da Operadora Pamcard informada na tabela DEG.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamUrlWs()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS	- INTEGRACAO VIA WEB SERVICE SISTEMA PAMCARD            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamUrlWs()
Local cURL 	:= ''

DEG->(DbSetOrder(1))
If DEG->(DbSeek(xFilial('DEG')+'02'))
	cURL := AllTrim(DEG->DEG_URLWS)
EndIf

Return cURL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamCNPJEmp ³ Autor:³ Gilson da Silva        ³ Data:³19/12/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Verifica se quem esta realizando a autenticação eh a empresa  ³±±
±±³		     ³Contratante ou uma Filial. Retorna somente o CNPJ da	empresa ³±±
±±³		     ³Contratante qdo a mesma estiver realizando a autenticacao e   ³±±
±±³		     ³retorna o CNPJ da Contratante,Tipo do documento,CNPJ da Filial³±±
±±³		     ³qdo for uma filial que estiver realizando a autenticacao.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamCNPJEmp(cCodOpe, cFilOri)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS - INTEGRACAO VIA WEB SERVICE SISTEMA PAMCARD             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamCNPJEmp(cCodOpe, cFilOri)
Local   aRet    :=  Array(3)
Default cCodOpe := '02'     //Codigo da operadora Pamcard no TMS.
Default cFilOri := cFilAnt  //Codigo da filial que estah realizando o procedimento.

Afill(aRet,'')
If Pamcary()
	DEG->(DbSetOrder(1))                  	
	If DEG->(DbSeek(xFilial('DEG')+cCodOpe))   
		If AllTrim(cFilOri) == AllTrim(DEG->DEG_FILCTR)		//Autenticação realizada pela Empresa Contratante
		  	aRet[1] := Posicione("SM0", 1, cEmpAnt  + DEG->DEG_FILCTR, "M0_CGC") 
		Else 
		   aRet[1] := Posicione("SM0", 1, cEmpAnt  + DEG->DEG_FILCTR, "M0_CGC") 
		   aRet[2] := '1' //Tipo do documento CNPJ
		   aRet[3] := Posicione("SM0", 1, cEmpAnt  + cFilOri, "M0_CGC")
		EndIf
	Else
		Help('',1,'OMSA10002') //-"O cadastro desta Operadora não foi realizado!"
	EndIf
EndIf

Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamCatVeic ³ Autor:³ Thiago Torelli         ³ Data:³12/12/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Define Código referente Quantidade de Eixos                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamCatVei()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS			                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamCatVeic(nQtdEixos)
Local nCount   := 0
Local nCodEixo := 0
Local aEixos   := Array(11,2) // Array contendo dados para comparação de eixos e codigo no sistema PamCard

aEixos[1]  := {2,2}
aEixos[2]  := {3,4}
aEixos[3]  := {4,6}
aEixos[4]  := {5,7}
aEixos[5]  := {6,8}
aEixos[6]  := {7,10}
aEixos[7]  := {8,11}
aEixos[8]  := {9,12}
aEixos[9]  := {10,13}
aEixos[10] := {0, 1}
aEixos[11] := {1, 1} //-- Nao considera Eixo para Utilitario

For nCount := 1 to Len(aEixos)
	If nQtdEixos == aEixos[nCount][1]
		nCodEixo := aEixos[nCount][2]
		Exit
	EndIf
Next nCount

FwFreeObj(aEixos)

Return nCodEixo


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
Function TMSCORNTRC()
Local nOpcao     := 0
Local oDlg
Local aFields    := {} // Array para envio de dados para Pamcard
Local oObjPam
Local nCount     := 1
Local nCount2    := 1
Local lFail      := .F.
Local aMsgErr    := {}    
Local aRetCNPJ	 := {} 
Local cFilFor    := Posicione( 'DEG',1,xFilial('DEG')+'02','DEG_FILCTR')
Local cRetCert   := ''
Local cTipoCGC   := ''
Local cRNTRC     := ''
Local lRet       := .T.
Local aCertif	 := {}
Local oModelM020 := Nil
Local oViewM020	 := Nil
Local lPagBem	 := FindFunction("TMSIntgPB") .AND. DA3->(FieldPos("DA3_CODMUN")) > 0
Local aData      := {} 
Local oObj, aRetOpe

Private cCodOpe  := CriaVar('DEG->DEG_CODOPE',.F.)
Private cNomOpe  := CriaVar('DEG->DEG_NOMOPE',.F.)

DEFINE MSDIALOG oDlg FROM 00,00 TO 090,350 PIXEL TITLE 'Consulta RNTRC'

@ 011,005 SAY Posicione( 'SX3',2,'DEG_CODOPE','X3_TITULO') SIZE 100,15 COLOR CLR_HBLUE PIXEL
@ 010,045 MSGET cCodOpe  F3 "DEG" PICTURE  PesqPict("DEG","DEG_CODOPE") SIZE 6,9  ;
VALID TMSValField(,.T.,'DEG_NOMOPE') .And. TMSValField(,.F.,'cNomOpe') PIXEL
@ 010,070 MSGET cNomOpe WHEN .F. SIZE 100,9 PIXEL
DEFINE SBUTTON FROM 30,115 TYPE 1 OF oDlg ENABLE ACTION (nOpcao := 1,oDlg:End())
DEFINE SBUTTON FROM 30,145 TYPE 2 OF oDlg ENABLE ACTION (nOpcao := 0,oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED

If nOpcao == 1  .And. cCodOpe == "02"
	
	If (M->A2_TIPO) == 'F'
		cTipoCGC := "2"
		cRNTRC	 := "5"
	ElseIf (M->A2_TIPO) == 'J'
		cTipoCGC := "1"
		cRNTRC	 := "6"
	EndIf
	
	aRetCNPJ := PamCNPJEmp(cCodOpe, cFilFor) //Função para obter CNPJ da contrante e filial de origem
	
	If lRet := PamCertDig(cCodOpe, @cRetCert, aCertif)
	
		If nTipoCerti == 2
			If ExistFunc('aTMSCORNTRC')
				aTMSCORNTRC(aRetCNPJ, cTipoCGC, cRNTRC, aCertif)
			Else
				MsgStop(STR0025, STR0001) //--"Para utilização do Certificado com extensão .PFX é necessário atualizar o programa: PamcardNew.prw"###"Atenção"				
			EndIf
		ElseIf nTipoCerti == 1
		
			AAdd (aFields,{'viagem.contratante.documento.numero',aRetCNPJ[1]} )
			AAdd (aFields,{'viagem.unidade.documento.tipo', aRetCNPJ[2] })
			AAdd (aFields,{'viagem.unidade.documento.numero', aRetCNPJ[3]} )
			AAdd (aFields,{'viagem.favorecido.documento.qtde', '2' } )
			AAdd (aFields,{'viagem.favorecido.documento1.tipo', cTipoCGC } )
			AAdd (aFields,{'viagem.favorecido.documento1.numero', AllTrim(M->A2_CGC) } )
			AAdd (aFields,{'viagem.favorecido.documento2.tipo', cRNTRC } )
			AAdd (aFields,{'viagem.favorecido.documento2.numero', AllTrim(M->A2_RNTRC) } )
			

			oObjPam := WSWSPamcardDocumentService():New()
			oObjPam:oWSarg0:ccertificate := cRetCert
			oObjPam:oWSarg0:ccontext := 'FindRNTRC'
			oObjPam:_URL := PamUrlWs()
			oObjPam:oWSarg0:oFieldTOs := WSPamcardDocumentService_ArrayOf_tns1_FieldTO():New()

			For nCount := 1 To Len(aFields)

				If !Empty(aFields[nCount][2])
					
					AAdd(oObjPam:oWSarg0:oFieldTOs:oFieldTo , WSPamcardDocumentService_FieldTO():New())
					oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:ckey := aFields[nCount][1]
					oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:cvalue := aFields[nCount][2]
					nCount2++ 
				EndIf

			Next nCount

					
			If !WsdlDbgLevel(3)
				GetWSCerror()
			EndIF
			
			WSDLSaveXML(.T.)
			If oObjPam:execute()				
				If oObjPam:oWSResponseTo:oReturn:oFieldTo[1]:cValue == "0"	
					
					If oObjPam:oWSResponseTo:oReturn:oFieldTo[5]:cValue == "Ativo"
						M->A2_STRNTRC := "1"
					ElseIf oObjPam:oWSResponseTo:oReturn:oFieldTo[5]:cValue == "Inativo"
						M->A2_STRNTRC := "2"
					EndIf
					
					M->A2_DTRNTRC := CToD(oObjPam:oWSResponseTo:oReturn:oFieldTo[7]:cValue)
					
					If oObjPam:oWSResponseTo:oReturn:oFieldTo[6]:cValue == "TAC"
						M->A2_TPRNTRC :=  "1"
					ElseIf oObjPam:oWSResponseTo:oReturn:oFieldTo[6]:cValue == "ETC"
						M->A2_TPRNTRC := "2"
					ElseIf oObjPam:oWSResponseTo:oReturn:oFieldTo[6]:cValue == "CTC"
						M->A2_TPRNTRC := "3"
					EndIf
					
					If oObjPam:oWSResponseTo:oReturn:oFieldTo[4]:cValue == "SIM"
						M->A2_EQPTAC := "1"
					ElseIf oObjPam:oWSResponseTo:oReturn:oFieldTo[4]:cValue $ "NAO/NÃO"
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
					Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oReturn:oFieldTo[2]:cValue,4,0)
				EndIf				
			Else
				aMsgErr := TMSErrOper(cCodOpe,, '2')
				lFail := .T.
			EndIf
		EndIf
	Else
		Help(" ",1,"TMSPAM001",,,3,0) //"Nao foi possivel abrir o"###"arquivo do Certificado Digital"###"da Operadora."
	EndIf	
	If lFail
		TmsMsgErr( aMsgErr )
	EndIf
ElseIf nOpcao == 1  .And. cCodOpe == "03" .And. lPagBem //--PAGBEM
	oObj := TMSBCAPagBem():New()
	oObj:Auth()
	aRetOpe := oObj:PutSitANTT( M->A2_COD, M->A2_LOJA ) 
	
	lFail    := !aRetOpe[1]
	If !lFail 
		If aRetOpe[2][1] == .T. 
			M->A2_STRNTRC := "1"
		Else
			M->A2_STRNTRC := "2"
		EndIf

		aData := FwDateTimeToLocal(aRetOpe[2][2])			
		If Len(aData) > 0
			M->A2_DTRNTRC := aData[1]
		EndIf 
		
		If aRetOpe[2][3] == "TAC"
			M->A2_TPRNTRC :=  "1"
		ElseIf aRetOpe[2][3] == "ETC"
			M->A2_TPRNTRC := "2"
		ElseIf aRetOpe[2][3] == "CTC"
			M->A2_TPRNTRC := "3"
		EndIf
		
		If aRetOpe[2][4]  == .T. 
			M->A2_EQPTAC := "1"
		Else
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
		AAdd( aMsgErr, { "Erro sistema PagBem:" + aRetOpe[3], '06', } ) // "Erro Sistema PagBem: "
		TmsMsgErr(aMsgErr)
	EndIf 
Else
	Help(" ",1,"TMSAE6007") //--Opção não disponível para","essa operadora.
EndIf

FwFreeObj( oObj )
FwFreeObj(aMsgErr)
FwFreeObj(aRetCNPJ)
FwFreeObj(aCertif)
FwFreeObj(aFields)

Return

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
Function PamRouter(aFields)
Local nValPdg := 0 // Valor do Pedágio retornado pela Pamcard
Local nCount  := 1
Local nCount2 := 1
Local oObjPam
Local cRetCert:= '' //Certificado Digital
Local lRet    := .T.    
Local aCertif := {}

If lRet := PamCertDig('02', @cRetCert, aCertif)

	If nTipoCerti == 2
		If ExistFunc('aPamRouter')
			nValPdg := APamRouter(aFields,aCertif)
		Else
			MsgStop(STR0025, STR0001) //--"Para utilização do Certificado com extensão .PFX é necessário atualizar o programa: PamcardNew.prw"###"Atenção"		
		EndIf
	ElseIf nTipoCerti == 1
		If lRet
			oObjPam := WSWSPamcardDocumentService():New()
			oObjPam:oWSarg0:ccertificate := cRetCert
			oObjPam:oWSarg0:ccontext := 'Router'
			oObjPam:_URL :=  PamUrlWs()
			oObjPam:oWSarg0:oFieldTOs := WSPamcardDocumentService_ArrayOf_tns1_FieldTO():New()
			
			For nCount := 1 To Len(aFields)
				If !Empty(aFields[nCount][2])
					AAdd(oObjPam:oWSarg0:oFieldTOs:oFieldTo , WSPamcardDocumentService_FieldTO():New())
					oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:ckey := aFields[nCount][1]
					oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:cvalue := aFields[nCount][2]
					nCount2++
				EndIf
			Next nCount
			
			WsdlDbgLevel(3)		
			If oObjPam:execute()
				If oObjPam:oWSresponseTO:oReturn:oFieldTo[1]:cValue == '0'
					nValPdg := Val(oObjPam:oWSresponseTO:oReturn:oFieldTo[6]:cValue)
				Else
					Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oReturn:oFieldTo[2]:cValue,4,0)
				EndIf
			Else
				Help("",1, "TMSPAM003",,,3,0)
			EndIf
		EndIf
	EndIf
EndIf

FwFreeObj(aCertif)
Return nValPdg

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
Function PamFindCar(aFields, lValida, lRespCart, cStatus, lAviso, cCodFor, cLojFor, lTelaTC)

Local nCount    := 1
Local nCount2   := 1
Local oObjPam
Local cRetCert  := '' //Certificado Digital
Local lRet      := .F.
Local nPosStatus:= 0
Local nVetor    := 0
Local aArea     := GetArea()
Local aAreaDEL  := DEL->(GetArea())
Local nX        := 0        
Local aCertif 	:= {}

Default lValida	:= .F.                         
Default lRespCart	:= .F.
Default cStatus   := ""
Default lAviso	:= .F. 
Default cCodFor 	:= ""
Default cLojFor 	:= "" 
Default lTelaTC		:= .F.

If lRet := PamCertDig('02', @cRetCert,aCertif)
	If nTipoCerti == 2
		If ExistFunc('aPamFindCar')
			lRet := APamFindCar(aFields, lValida, lRespCart, @cStatus, lAviso, aCertif,cCodFor, cLojFor, lTelaTC)
		Else
			MsgStop(STR0025, STR0001) //--"Para utilização do Certificado com extensão .PFX é necessário atualizar o programa: PamcardNew.prw"###"Atenção"
			lRet := .F.		
		EndIf
	Else
		oObjPam := WSWSPamcardDocumentService():New()
		oObjPam:oWSarg0:ccertificate := cRetCert
		oObjPam:oWSarg0:ccontext := 'FindCard'
		oObjPam:_URL :=  PamUrlWs()
		oObjPam:oWSarg0:oFieldTOs := WSPamcardDocumentService_ArrayOf_tns1_FieldTO():New()
		
		For nCount := 1 To Len(aFields)
			If !Empty(aFields[nCount][2])
				AAdd(oObjPam:oWSarg0:oFieldTOs:oFieldTo , WSPamcardDocumentService_FieldTO():New())
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:ckey := aFields[nCount][1]
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:cvalue := aFields[nCount][2]
				nCount2++
			EndIf
		Next nCount
		
		WsdlDbgLevel(3)
		
		If oObjPam:execute()
			If oObjPam:oWSResponseTo:oReturn:oFieldTo[1]:cValue == "0"
				nVetor := Len(oObjPam:oWSResponseTo:oReturn:oFieldTo)
				lRet := .T.
				For nX := 1 To Len(oObjPam:oWSResponseTo:oReturn:oFieldTo)
					If oObjPam:OWSResponseTo:oReturn:oFieldTo[nX]:cKey  == 'viagem.cartao.status.id'
						Exit
					EndIf
				Next
				If lRespCart
					If !Empty(cCodFor)					
						DbSelectArea("DDQ")
						DDQ->(DbSetOrder(1))
						If MsSeek(xFilial("DDQ")+aFields[4][2]+cCodFor+ cLojFor) 
							If  DDQ->DDQ_STATUS <>  oObjPam:oWSResponseTo:oReturn:oFieldTo[nX]:cValue
								RecLock("DDQ", .F.)	
								DDQ->DDQ_STATUS := oObjPam:oWSResponseTo:oReturn:oFieldTo[nX]:cValue
								MsUnlock()
							EndIf
						Else
							DbSelectArea("DEL")
							DEL->(DbSetOrder(2))
							If DEL->(DbSeek(xFilial("DEL") + DA4->DA4_COD + '02' + aFields[4][2]))
								If  DEL->DEL_STATUS <>  oObjPam:oWSResponseTo:oReturn:oFieldTo[nX]:cValue
									
									RecLock("DEL", .F.)					
									DEL->DEL_STATUS := oObjPam:oWSResponseTo:oReturn:oFieldTo[nX]:cValue
									MsUnlock()
								EndIf
							EndIf
						EndIf
						If nVetor == 4
							If oObjPam:oWSResponseTo:oReturn:oFieldTo[4]:cValue == '3'
								If !lTelaTC
									Help("",1, "TMSPAM004",,,3,0)
									lRet := .F.
								Else
									cStatus := "3"
								EndIf
							EndIf
						Else
							If oObjPam:oWSResponseTo:oReturn:oFieldTo[nX]:cValue == '3'
								If !lTelaTC
									Help("",1, "TMSPAM004",,,3,0)
									lRet := .F.
								Else
									cStatus := "3"
								EndIf
							EndIf
						EndIf	
					Else
						M->DDQ_STATUS := oObjPam:oWSResponseTo:oReturn:oFieldTo[nX]:cValue
					EndIf
				ElseIf lValida
					DbSelectArea("DEL")
					DEL->(DbSetOrder(2))
					If DEL->(DbSeek(xFilial("DEL") + DA4->DA4_COD + '02' + aFields[4][2]))
						RecLock("DEL", .F.)
						If nVetor == 4 .And. DEL->DEL_STATUS <>  oObjPam:oWSResponseTo:oReturn:oFieldTo[4]:cValue
							DEL->DEL_STATUS := oObjPam:oWSResponseTo:oReturn:oFieldTo[4]:cValue
						ElseIf DEL->DEL_STATUS <>  oObjPam:oWSResponseTo:oReturn:oFieldTo[nX]:cValue
							DEL->DEL_STATUS := oObjPam:oWSResponseTo:oReturn:oFieldTo[nX]:cValue
						EndIf
						MsUnlock()
					EndIf
					If nVetor == 4
						If oObjPam:oWSResponseTo:oReturn:oFieldTo[4]:cValue == '3'
							If !lTelaTC
								Help("",1, "TMSPAM004",,,3,0)
								lRet := .F.
							Else
								cStatus := "3"
							EndIf
						EndIf
					Else
						If oObjPam:oWSResponseTo:oReturn:oFieldTo[nX]:cValue == '3'
							If !lTelaTC
								Help("",1, "TMSPAM004",,,3,0)
								lRet := .F.
							Else
								cStatus := "3"
							EndIf
						EndIf
					EndIf
				Else			
					If Type("aCols") <> "U"  .And. Len(aCols) > 0				
						nPosStatus:= GDFieldPos( "DEL_STATUS" )
						If nVetor == 4
							aCols[n][nPosStatus] := oObjPam:oWSResponseTo:oReturn:oFieldTo[4]:cValue
						Else
						aCols[n][nPosStatus] := oObjPam:oWSResponseTo:oReturn:oFieldTo[nX]:cValue
						EndIf
					EndIf	
				EndIf
			ElseIf oObjPam:oWSResponseTo:oReturn:oFieldTo[1]:cValue == "4"
				If lAviso 
					Aviso('PAMCARD',oObjPam:oWSresponseTO:oReturn:oFieldTo[2]:cValue,{'Ok'})
					lRet := .T.
				Else			
					Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oReturn:oFieldTo[2]:cValue,4,0)
					lRet := .F.
				EndIf
			Else
				If lAviso
					Aviso('PAMCARD',oObjPam:oWSresponseTO:oReturn:oFieldTo[2]:cValue,{'Ok'})
					
					lRet := .T.
				Else
					Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oReturn:oFieldTo[2]:cValue,4,0)
					lRet := .F.
				EndIf
			EndIf
			If Len(oObjPam:oWSResponseTo:oReturn:oFieldTo) == nX
				cStatus := oObjPam:oWSResponseTo:oReturn:oFieldTo[nX]:cValue
			EndIf
			
		Else
			Help("",1, "TMSPAM003",,,3,0)
			lRet := .F.
		EndIf
		
		RestArea(aAreaDEL)
		RestArea(aArea)
	EndIf
EndIf

FwFreeObj(aAreaDEL)
FwFreeObj(aArea)
FwFreeObj(aCertif)

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
Function PamInsCard(aFields)
Local nCount   	:= 1
Local nCount2  	:= 1
Local oObjPam
Local cRetCert 	:= '' //Certificado Digital
Local lRet     	:= .T.
Local aCertif	:= {}

If lRet := PamCertDig('02', @cRetCert, aCertif) 
	If nTipoCerti == 2
		If ExistFunc('aPamInsCard')
			lRet := APamInsCard(aFields,aCertif)
		Else
			MsgStop(STR0025, STR0001) //--"Para utilização do Certificado com extensão .PFX é necessário atualizar o programa: PamcardNew.prw"###"Atenção"		
			lRet := .F.
		EndIf
	ElseIf lRet
		oObjPam := WSWSPamcardDocumentService():New()
		oObjPam:oWSarg0:ccertificate := cRetCert
		oObjPam:oWSarg0:ccontext := 'InsertCardFreight'
		oObjPam:_URL := PamUrlWs()
		oObjPam:oWSarg0:oFieldTOs := WSPamcardDocumentService_ArrayOf_tns1_FieldTO():New()
		
		For nCount := 1 To Len(aFields)
			If !Empty(aFields[nCount][2])
				AAdd(oObjPam:oWSarg0:oFieldTOs:oFieldTo , WSPamcardDocumentService_FieldTO():New())
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:ckey := aFields[nCount][1]
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:cvalue := aFields[nCount][2]
				nCount2++
			EndIf
		Next nCount
		
		WsdlDbgLevel(3)
		
		If oObjPam:execute()
			If oObjPam:oWSResponseTo:oReturn:oFieldTo[1]:cValue <> "0"
				Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oReturn:oFieldTo[2]:cValue,4,0)
				lRet := .F.
			EndIf
		Else
			Help("",1, "TMSPAM003",,,3,0)
			lRet := .F.
		EndIf
	EndIf
EndIf

FwFreeObj(aCertif)

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
Function PamFindFav(aFields)
Local nCount   := 1
Local nCount2  := 1
Local oObjPam
Local cRetCert := '' //Certificado Digital
Local lRet     := .T.
Local aCertif  := {}
Default	aFields:= {}
If lRet := PamCertDig('02', @cRetCert, aCertif)

	If nTipoCerti == 2
		If ExistFunc('APamFindFav')
			lRet := APamFindFav(aFields, aCertif)	
		Else
			MsgStop(STR0025, STR0001) //--"Para utilização do Certificado com extensão .PFX é necessário atualizar o programa: PamcardNew.prw"###"Atenção"
			lRet := .F.
		EndIf	
	ElseIf nTipoCerti == 1
		oObjPam := WSWSPamcardDocumentService():New()
		oObjPam:oWSarg0:ccertificate := cRetCert
		oObjPam:oWSarg0:ccontext := 'FindFavored'
		oObjPam:_URL := PamUrlWs()
		oObjPam:oWSarg0:oFieldTOs := WSPamcardDocumentService_ArrayOf_tns1_FieldTO():New()
		
		For nCount := 1 To Len(aFields)
			If !Empty(aFields[nCount][2])
				AAdd(oObjPam:oWSarg0:oFieldTOs:oFieldTo , WSPamcardDocumentService_FieldTO():New())
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:ckey := aFields[nCount][1]
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:cvalue := aFields[nCount][2]
				nCount2++
			EndIf
		Next nCount
		WsdlDbgLevel(3)
		
		If oObjPam:execute()
			If oObjPam:oWSResponseTo:oReturn:oFieldTo[1]:cValue == "0"
				lRet := .T.
			ElseIf oObjPam:oWSResponseTo:oReturn:oFieldTo[1]:cValue == "4"
				lRet := .F.     
				Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oReturn:oFieldTo[2]:cValue,4,0)
			Else
				Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oReturn:oFieldTo[2]:cValue,4,0)
				lRet:= .F.
			EndIf
		Else
			aMsgErr := TMSErrOper('02',, '2')
			lRet:= .F.
		EndIf
	EndIf
EndIf

FwFreeObj(aCertif)

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
Function PamInsFav(aFields)
Local nCount   := 1
Local nCount2  := 1
Local oObjPam
Local cRetCert := '' //Certificado Digital
Local lRet     := .T.
Local aMsgErr  := {}
Local aCertif  := {}

Default	aFields:= {}
If lRet := PamCertDig('02', @cRetCert, aCertif)
	If nTipoCerti == 2
		If ExistFunc('aPamInsFav')
			lRet := aPamInsFav(aFields, aCertif)
		Else
			MsgStop(STR0025, STR0001) //--"Para utilização do Certificado com extensão .PFX é necessário atualizar o programa: PamcardNew.prw"###"Atenção"
			lRet := .F.
		EndIf
	ElseIf nTipoCerti == 1
		oObjPam := WSWSPamcardDocumentService():New()
		oObjPam:oWSarg0:ccertificate := cRetCert
		oObjPam:oWSarg0:ccontext := 'InsertFavored'
		oObjPam:_URL := PamUrlWs()
		oObjPam:oWSarg0:oFieldTOs := WSPamcardDocumentService_ArrayOf_tns1_FieldTO():New()
		
		For nCount := 1 To Len(aFields)
			If !Empty(aFields[nCount][2])
				AAdd(oObjPam:oWSarg0:oFieldTOs:oFieldTo , WSPamcardDocumentService_FieldTO():New())
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:ckey := aFields[nCount][1]
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:cvalue := aFields[nCount][2]
				nCount2++
			EndIf
		Next nCount
		
		WsdlDbgLevel(3)
		
		If oObjPam:execute()
			If oObjPam:oWSResponseTo:oReturn:oFieldTo[1]:cValue <> "0"
				Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oReturn:oFieldTo[2]:cValue,4,0)
				lRet := .F.
			EndIf
		Else
			aMsgErr := TMSErrOper('02',, '2')
			lRet := .F.
		EndIf
	EndIf
EndIf

FwFreeObj(aCertif)
FwFreeObj(aMsgErr)
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
Function PamFindAcc(aFields)
Local nCount   	:= 1
Local nCount2  	:= 1
Local oObjPam
Local cRetCert 	:= '' //Certificado Digital
Local lRet     	:= .T.
Local aMsgErr	:= {}
Local aCertif	:= {}

Default aFields := {}
If lRet := PamCertDig('02', @cRetCert, aCertif)

	If nTipoCerti == 2
		If ExistFunc('aPamFindAcc')
			lRet := aPamFindAcc(aFields, aCertif)
		Else	
			MsgStop(STR0025, STR0001) //--"Para utilização do Certificado com extensão .PFX é necessário atualizar o programa: PamcardNew.prw"###"Atenção"
			lRet := .F.
		EndIf
	ElseIf nTipoCerti == 1
		oObjPam := WSWSPamcardDocumentService():New()
		oObjPam:oWSarg0:ccertificate := cRetCert
		oObjPam:oWSarg0:ccontext := 'FindFavoredAccount'
		oObjPam:_URL := PamUrlWs()
		oObjPam:oWSarg0:oFieldTOs := WSPamcardDocumentService_ArrayOf_tns1_FieldTO():New()
		
		For nCount := 1 To Len(aFields)
			If !Empty(aFields[nCount][2])
				AAdd(oObjPam:oWSarg0:oFieldTOs:oFieldTo , WSPamcardDocumentService_FieldTO():New())
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:ckey := aFields[nCount][1]
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:cvalue := aFields[nCount][2]
				nCount2++
			EndIf
		Next nCount
		
		WsdlDbgLevel(3)
		
		If oObjPam:execute()
			If oObjPam:oWSResponseTo:oReturn:oFieldTo[1]:cValue == "0"
				lRet := .T.
			ElseIf oObjPam:oWSResponseTo:oReturn:oFieldTo[1]:cValue == "4"
				lRet := .F.
			Else
				Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oReturn:oFieldTo[2]:cValue,4,0)
			EndIf
		Else
			aMsgErr := TMSErrOper('02',, '2')
		EndIf	
	EndIf
EndIf

FwFreeObj(aCertif)
FwFreeObj(aMsgErr)
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
Function PamInsAcc(aFields)

Local nCount   := 1
Local nCount2  := 1
Local oObjPam
Local cRetCert := '' //Certificado Digital
Local lRet     := .T.
Local aMsgErr  := {}
Local aCertif  := {}

Default	aFields:= {}

If lRet := PamCertDig('02', @cRetCert, aCertif)

	If nTipoCerti == 2
		If ExistFunc('aPamInsAcc')
			lRet := aPamInsAcc(aFields)
		Else	
			MsgStop(STR0025, STR0001) //--"Para utilização do Certificado com extensão .PFX é necessário atualizar o programa: PamcardNew.prw"###"Atenção"
			lRet := .F.
		EndIf
	ElseIf nTipoCerti == 1	
		oObjPam := WSWSPamcardDocumentService():New()
		oObjPam:oWSarg0:ccertificate := cRetCert
		oObjPam:oWSarg0:ccontext := 'InsertFavoredAccount'
		oObjPam:_URL := PamUrlWs()
		oObjPam:oWSarg0:oFieldTOs := WSPamcardDocumentService_ArrayOf_tns1_FieldTO():New()
		
		For nCount := 1 To Len(aFields)
			If !Empty(aFields[nCount][2])
				AAdd(oObjPam:oWSarg0:oFieldTOs:oFieldTo , WSPamcardDocumentService_FieldTO():New())
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:ckey := aFields[nCount][1]
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:cvalue := aFields[nCount][2]
				nCount2++
			EndIf
		Next nCount
		
		WsdlDbgLevel(3)
		
		If oObjPam:execute()
			If oObjPam:oWSResponseTo:oReturn:oFieldTo[1]:cValue <> "0"
				Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oReturn:oFieldTo[2]:cValue,4,0)
			EndIf
		Else
			aMsgErr := TMSErrOper('02',, '2')
		EndIf
	EndIf
EndIf

FwFreeObj(aCertif)
FwFreeObj(aMsgErr)
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamVldFor  ³ Autor:³ Thiago Torelli         ³ Data:³02/01/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Valida Dados do Fornecedor/Motorista.		                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamVldFor()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS			                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamVldFor(cCodFor, cLojFor, lRespCart)
Local lRet 		 := .T.
Local aArea		 := GetArea()
Local aAreaSA2   := SA2->(GetArea())

Default lRespCart := .F.
DbSelectArea("SA2")
DbSetOrder(1)    

If DbSeek(xFilial("SA2") + cCodFor + cLojFor)
	If lRespCart //--Valida dados do Responsável do Cartão
		If Empty(SA2->A2_RNTRC)
			lRet := .F.
		Else
			lRet := .T.
		EndIf	
	Else //--Valida dados do motorista e Fornecedor
		If  Empty(DA4->DA4_RG) .Or.  Empty(DTOC(DA4->DA4_DATNAS)) .Or. Empty(DA4->DA4_RGEST) .Or. Empty(SA2->A2_END)  .Or.; 
			Empty(SA2->A2_MUN) .Or. Empty(SA2->A2_EST) .Or. Empty(SA2->A2_CEP) .Or. Empty(SA2->A2_TEL) .Or. Empty(SA2->A2_DDD) .Or.;
			Empty(SA2->A2_COD_MUN) .Or. Empty(SA2->A2_RNTRC) .Or. Empty(SA2->A2_BAIRRO)
			lRet := .F.
		Else
			lRet := .T.
		EndIf
	EndIf
Else
	lRet := .F.
EndIf

RestArea(aAreaSA2)
RestArea(aArea)

FwFreeObj(aArea)
FwFreeObj(aAreaSA2)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamFdRNTRC ³ Autor:³ Thiago Torelli         ³ Data:³13/01/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Busca RNTRC para Veiculo e Reboques			                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamFdRNTRC()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS			                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamFdRNTRC(cCodFor, cLojaFor)
Local cTipoCGC := ''
Local cRNTRC   := ''
Local cRetCert := ''
Local aArea    := GetArea()
Local aAreaSA2 := SA2->(GetArea())
Local aFields  := Array(8,2)
Local aCertif  := {}
Local oObjPam

Local nCount   := 0
Local nCount2  := 1

Local lRet     := .T.

DbSelectArea("SA2")
DbSetOrder(1)
If lRet := PamCertDig('02', @cRetCert, aCertif) 
	
	If nTipoCerti == 2				
		If ExistFunc('aPamFdRNTRC')
			lRet := aPamFdRNTRC(cCodFor,cLojaFor,aCertif)
		Else
			MsgStop(STR0025, STR0001) //--"Para utilização do Certificado com extensão .PFX é necessário atualizar o programa: PamcardNew.prw"###"Atenção"
			lRet := .F.
		EndIf
	ElseIf nTipoCerti == 1 
		If lRet := DbSeek(xFilial("SA2") + cCodFor + cLojaFor)
			If (SA2->A2_TIPO) == 'F'
				cTipoCGC := "2"
				cRNTRC	 := "5"
			ElseIf (SA2->A2_TIPO) == 'J'
				cTipoCGC := "1"
				cRNTRC	 := "6"
			EndIf

			aRetCNPJ := PamCNPJEmp('02', cFilAnt) //Função para obter CNPJ da contrante e filial de origem	
	
			aFields[1][1] := 'viagem.contratante.documento.numero'
			aFields[1][2] := aRetCNPJ[1]
			aFields[2][1] := 'viagem.unidade.documento.tipo'
			aFields[2][2] := aRetCNPJ[2]
			aFields[3][1] := 'viagem.unidade.documento.numero'
			aFields[3][2] := aRetCNPJ[3]
			aFields[4][1] := 'viagem.favorecido.documento.qtde'
			aFields[4][2] := '2'
			aFields[5][1] := 'viagem.favorecido.documento1.tipo'
			aFields[5][2] := cTipoCGC
			aFields[6][1] := 'viagem.favorecido.documento1.numero'
			aFields[6][2] := Alltrim(SA2->A2_CGC)
			aFields[7][1] := 'viagem.favorecido.documento2.tipo'
			aFields[7][2] := cRNTRC
			aFields[8][1] := 'viagem.favorecido.documento2.numero'
			aFields[8][2] := AllTrim(SA2->A2_RNTRC)
			
			oObjPam := WSWSPamcardDocumentService():New()
			oObjPam:oWSarg0:ccertificate := cRetCert
			oObjPam:oWSarg0:ccontext := 'FindRNTRC'
			oObjPam:_URL := PamUrlWs()
			oObjPam:oWSarg0:oFieldTOs := WSPamcardDocumentService_ArrayOf_tns1_FieldTO():New()
			
			For nCount := 1 To Len(aFields)
				If !Empty(aFields[nCount][2])
					AAdd(oObjPam:oWSarg0:oFieldTOs:oFieldTo , WSPamcardDocumentService_FieldTO():New())
					oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:ckey := aFields[nCount][1]
					oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:cvalue := aFields[nCount][2]
					nCount2++
				EndIf
			Next nCount
			
			WsdlDbgLevel(3)
			
			If lRet := oObjPam:execute()
				If lRet := oObjPam:oWSResponseTo:oReturn:oFieldTo[1]:cValue == "0"
					RecLock("SA2", .F.)
					If oObjPam:oWSResponseTo:oReturn:oFieldTo[5]:cValue == "Ativo"
						SA2->A2_STRNTRC := "1"
					ElseIf oObjPam:oWSResponseTo:oReturn:oFieldTo[5]:cValue == "Inativo"
						SA2->A2_STRNTRC := "2"
						lRet := .F.
					EndIf
					
					SA2->A2_DTRNTRC := CToD(oObjPam:oWSResponseTo:oReturn:oFieldTo[7]:cValue)
					
					If oObjPam:oWSResponseTo:oReturn:oFieldTo[6]:cValue == "TAC"
						SA2->A2_TPRNTRC :=  "1"
					ElseIf oObjPam:oWSResponseTo:oReturn:oFieldTo[6]:cValue == "ETC"
						SA2->A2_TPRNTRC := "2"
					ElseIf oObjPam:oWSResponseTo:oReturn:oFieldTo[6]:cValue == "CTC"
						SA2->A2_TPRNTRC := "3"
					EndIf
					
					If oObjPam:oWSResponseTo:oReturn:oFieldTo[4]:cValue == "SIM"
						SA2->A2_EQPTAC := "1"
					ElseIf oObjPam:oWSResponseTo:oReturn:oFieldTo[4]:cValue == "NAO"
						SA2->A2_EQPTAC := "2"
					EndIf
					
					MsUnlock()
				ElseIf lRet :=  oObjPam:oWSResponseTo:oReturn:oFieldTo[1]:cValue == "6"
				EndIf			
			EndIf
		EndIf
	EndIf	
Else
	lRet := .F.
EndIf

RestArea(aAreaSA2)
RestArea(aArea)

FwFreeObj(aArea)
FwFreeObj(aAreaSA2)
FwFreeObj(aFields)
FwFreeObj(aCertif)

Return lRet



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamConParc ³ Autor:³ Gilson da Silva        ³ Data:³06/02/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Consulta Parcela da Viagem.								       	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ExpC1 = Filial Origem da Viagem                               ³±±
±±³           ³ExpC2 = Numero da Viagem                                      ³±±
±±³           ³ExpA1 = Dados da Transportadora                               ³±±
±±³           ³ExpC3 = Numero da Parcela                                     ³±±
±±³           ³ExpC4 = Id da Viagem na PAMCARD                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamConParc(ExpC1, ExpC2, ExpA1, ExpC3)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS.												                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamConParc(cFilOri, cViagem, aRetCNPJ, cParc, cViagemId,lHelp)
Local aFields    := {}
Local nRet       := 0

Default cFilOri		:= ''
Default cViagem		:= ''
Default aRetCNPJ	:= {}
Default	cParc		:= ''
Default cViagemId 	:= AllTrim(Posicione('DTQ',2,xFilial('DTQ')+cFilOri+cViagem,'DTQ_IDOPE'))
Default lHelp 		:= .T. 


AAdd (aFields,{'viagem.id', cViagemId})
AAdd (aFields,{'viagem.contratante.documento.numero',aRetCNPJ[1]} )
AAdd (aFields,{'viagem.unidade.documento.tipo', aRetCNPJ[2] })
AAdd (aFields,{'viagem.unidade.documento.numero', aRetCNPJ[3]} )
AAdd (aFields,{'viagem.parcela.numero.cliente', cParc} )
nRet := PamConStPa(aFields,lHelp) //Chamada da Função

FwFreeObj(aFields)
Return nRet



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamConPdVg ³ Autor:³ Gilson da Silva        ³ Data:³09/02/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Consulta Status do Pedagio.									        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ExpC1 = Filial Origem da Viagem                               ³±±
±±³           ³ExpC2 = Numero da Viagem                                      ³±±
±±³           ³ExpA1 = Dados da Transportadora                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamConPdVg(ExpC1, ExpC2, ExpA1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS.												                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamConPdVg(cFilOri, cViagem, aRetCNPJ,cMsgRet,cNumIdOpe,cNumIdCli,cNumIdPdg)
Local aFields    := {}
Local nRet       := 0
Local aArea      := GetArea()
Local aAreaDTR   := DTR->(GetArea())
Local aAreaDUP   := DUP->(GetArea())
Local lOk        := .F.
Local lDTRTPSPDG := DTR->(ColumnPos("DTR_TPSPDG")) > 0
Local cTipPagPDG := ''
Local lTabDLD    := TableInDic('DLD')
Local aForPag	 := {}	
Local nParcPedag := 0
Local cCartPedag := ''

Default cFilOri	:= ''
Default cViagem	:= ''
Default aRetCNPJ:= ''
Default cMsgRet := ''
Default cNumIdOpe:= ''
Default cNumIdCli:= ''
Default cNumIdPdg:= ''

//Posiciona na tabela de Complementos da viagem (Veiculo da viagem).
DTR->(DbSetOrder(1))
DTR->(DbSeek(xFilial('DTR') + cFilOri + cViagem))

//Posiciona na tabela de Motorista da viagem.
DUP->(DbSetOrder(1))
If DUP->(DbSeek(xFilial('DUP')+cFilOri + cViagem))

	lOk := PamCondut (cFilOri, cViagem)
	
	If lDTRTPSPDG
		cTipPagPDG := DTR->DTR_TPSPDG
	Else
		cTipPagPDG := DUP->DUP_TPSPDG
	EndIf

	If lOk .And. cTipPagPDG == '5' .And. DTR->DTR_VALPDG > 0
		If lTabDLD .And. FindFunction('TmsForPag')
			//Formas de Pagamento da viagem
			aForPag 	:= TmsForPag(cFilOri,cViagem)
		EndIf
		If Len(aForPag) > 0 // Se existir a tabela DLD
			If (nParcPedag := Ascan(aForPag, {|x|  x[2] == '3'})) > 0 //Se existir parcela de ped?io
				cCartPedag := Alltrim(aForPag[nParcPedag,4])
                
			ElseIf (nParcPedag := Ascan(aForPag, {|x|  x[2] == '2'})) > 0 //Se  n? existir parcela de ped?io considera o cart? da parcela de saldo do frete
				cCartPedag := Alltrim(aForPag[ nParcPedag,4])
			Endif
			If Empty(cCartPedag) .And.  (nParcPedag := Ascan(aForPag, {|x|  x[2] == '1'})) > 0 //Se n? encontrar cart? considera o cart? da parcela de adiantamento
				cCartPedag := Alltrim(aForPag[ nParcPedag,4])
			EndIf
		Else //Regra antiga
			cCartPedag := AllTrim(DUP->DUP_IDOPE)
		EndIf

		If DTQ->(ColumnPos("DTQ_IDPDG")) > 0 .And. (!Empty(DTQ->DTQ_IDPDG) .Or. !Empty(cNumIdPdg))
			AAdd (aFields,{'viagem.id', AllTrim(DTQ->DTQ_IDPDG)})
		Else
			AAdd (aFields,{'viagem.id', AllTrim(DTQ->DTQ_IDOPE)})
		EndIf
		AAdd (aFields,{'viagem.contratante.documento.numero',aRetCNPJ[1]} )
		AAdd (aFields,{'viagem.unidade.documento.tipo', aRetCNPJ[2] })
		AAdd (aFields,{'viagem.unidade.documento.numero', aRetCNPJ[3]} )
		AAdd (aFields,{'viagem.cartao.numero', AllTrim(cCartPedag)} )
		nRet := PamStPedag(aFields,@cMsgRet) //Chamada da Função		
	Else
		nRet := 3
	EndIf
EndIf
		
RestArea(aAreaDTR)
RestArea(aAreaDUP)
RestArea(aArea)

FwFreeObj(aArea)
FwFreeObj(aAreaDTR)
FwFreeObj(aAreaDUP)
Return nRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamConPdCt ³ Autor:³ Gilson da Silva        ³ Data:³09/02/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Consulta Status do Pedagio para Contrato						     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ExpC1 = Filial Origem da Viagem                               ³±±
±±³           ³ExpC2 = Numero da Viagem                                      ³±±
±±³           ³ExpA1 = Dados da Transportadora                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamConPdCt(ExpC1, ExpC2, ExpA1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS.												                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamConPdCt(cFilOri, cViagem, aRetCNPJ, cMsgRet)
Local aFields    := {}
Local nRet       := 0        
Local aArea      := GetArea()
Local aAreaDTR   := DTR->(GetArea())
Local aAreaDUP   := DUP->(GetArea())
Local lOk        := .F.
Local lDTRTPSPDG := DTR->(ColumnPos("DTR_TPSPDG")) > 0
Local cTipPagPDG := ''

Default	cFilOri	:= ''
Default cViagem	:= ''
Default aRetCNPJ:= {}
Default cMsgRet := ''

//Posiciona na tabela de Complementos da viagem (Veiculo da viagem).
DTR->(DbSetOrder(1))
DTR->(DbSeek(xFilial('DTR') + cFilOri + cViagem))

//Posiciona na tabela de Motorista da viagem.
DUP->(DbSetOrder(1))
If DUP->(DbSeek(xFilial('DUP')+cFilOri + cViagem))
	lOk := PamCondut (cFilOri, cViagem)
	
	If lDTRTPSPDG
		cTipPagPDG := DTR->DTR_TPSPDG
	Else
		cTipPagPDG := DUP->DUP_TPSPDG
	EndIf

	If lOk .And. cTipPagPDG == '5' .And. DTR->DTR_VALPDG > 0
		If DTQ->(FieldPos("DTQ_IDPDG")) > 0 .And. !Empty(DTQ->DTQ_IDPDG)
			AAdd (aFields,{'viagem.id', AllTrim(DTQ->DTQ_IDPDG)})
		Else
			AAdd (aFields,{'viagem.id', AllTrim(DTQ->DTQ_IDOPE)})
		EndIf
		AAdd (aFields,{'viagem.contratante.documento.numero',aRetCNPJ[1]} )
		AAdd (aFields,{'viagem.unidade.documento.tipo', aRetCNPJ[2] })
		AAdd (aFields,{'viagem.unidade.documento.numero', aRetCNPJ[3]} )
		AAdd (aFields,{'viagem.antt.ciot.numero', AllTrim(DTR->DTR_CIOT)} )
		nRet := PamStPedag(aFields,@cMsgRet) //Chamada da Função
	Else 
		nRet := 3
	Endif 
EndIf

RestArea(aAreaDTR)
RestArea(aAreaDUP)
RestArea(aArea)

FwFreeObj(aArea)
FwFreeObj(aAreaDTR)
FwFreeObj(aAreaDUP)
FwFreeObj(aFields)

Return nRet



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamIncViag ³ Autor:³ Gilson da Silva        ³ Data:³16/01/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Inclusao da Viagem no Sistema Pamcard     	                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamIncViag)                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS			                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamIncViag(cFilOri, cViagem,aRetCNPJ, lOnlyPdg )
Local cTipDoc    := Iif(DTQ->DTQ_SERTMS == "1", "11", "5") //Se a viagem for de coleta o tipo de docto sera 11-Ordem de Coleta, senão sera 5=Conhecimento.
Local cPlacaVei  := ''
Local cAliasDUD  := ''
Local cIDOpe     := '' 

Local lCfUtSaldo := GetMv('MV_TMSCFUS',,'.F.') //Empresa configurada para Utilizar o Saldo do Cartão.
Local lUtilSaldo := GetMv('MV_TMSUTSL',,'.F.') // Utiçiza o saldo do pedágio .

Local nQtdDoc    := 0
Local nAdiFre    := 0
Local nCont      := 0
Local lRet       := .F.
Local aFields    := {}
Local aAreaDTR   := DTR->(GetArea())
Local aAreaDUP   := DUP->(GetArea())
Local aAreaDA4   := DA4->(GetArea())
Local aAreaDA3   := DA3->(GetArea())
Local aAreaDTQ   := DTQ->(GetArea())
Local aAreaDUD   := DUD->(GetArea())
Local lOk        := .F.
Local lDTRTPSPDG := DTR->(ColumnPos("DTR_TPSPDG")) > 0
Local cTipPagPDG := ''
Local lTabDLD    := TableInDic('DLD')
Local aForPag	 := {}	
Local nParcPedag := 0
Local cCartPedag := ''
Local cCartSaldo := ''
Local cRoteiriza := 'N'
Local cCodOpe    := '02'  //Codigo da operadora Pamcard no TMS.
Local lDTRAbast  := DTR->(ColumnPos("DTR_VLABST")) > 0
Local cParAdi    := '1'

Default cFilOri	 := ''
Default cViagem	 := ''
Default aRetCNPJ := {}
Default lOnlyPdg := .F.
//Posiciona na tabela de Complementos da viagem (Veiculo da viagem).
DTR->(DbSetOrder(1))
DTR->(DbSeek(xFilial('DTR') + cFilOri + cViagem))

//Posiciona na tabela de Motorista da viagem.
DUP->(DbSetOrder(1))
If DUP->(DbSeek(xFilial('DUP')+cFilOri + cViagem))
	lOk := PamCondut (cFilOri, cViagem)
EndIf

If lOk
	If lTabDLD .And. FindFunction('TmsForPag')
		//Formas de Pagamento da viagem
		aForPag 	:= TmsForPag(cFilOri,cViagem)
	EndIf

	//Posiciona na tabela de Motoristas.
	DA4->(DbSetOrder(1))
	DA4->(DbSeek(xFilial('DA4')+DUP->DUP_CODMOT))
	
	//Posiciona na tabela de veículos.
	DA3->(DbSetOrder(1))
	DA3->(DbSeek(xFilial('DA3')+DTR->DTR_CODVEI))
	
	//Posiciona na Tabela de Fornecedor do veículo
	SA2->(dbSetOrder(1))
	SA2->(DbSeek(xFilial("SA2")+DA3->DA3_CODFOR+DA3->DA3_LOJFOR) )
	cTpPessoa := Iif(SA2->A2_TIPO=="F", '2', '1')
	cPlacaVei := StrTran(DA3->DA3_PLACA," ","")
	cPlacaVei := StrTran(cPlacaVei,"-","")
	
	AAdd (aFields,{'viagem.contratante.documento.numero',aRetCNPJ[1]} )
	
	If cTpPessoa == '1'
		AAdd (aFields,{'viagem.cartao.empresa.nome', AllTrim(SA2->A2_NOME)} )
		AAdd (aFields,{'viagem.cartao.empresa.cnpj', AllTrim(SA2->A2_CGC) } )	
	EndIf
	AAdd (aFields,{'viagem.unidade.documento.tipo', aRetCNPJ[2] })
	AAdd (aFields,{'viagem.unidade.documento.numero', aRetCNPJ[3]} )
	
	//Verifica a quantidade de documentos da viagem
	cQuery := " SELECT COUNT(DUD_DOC) QTDDOC "
	cQuery += "   FROM " + RetSqlName("DUD")
	cQuery += " Where DUD_FILIAL = '"+xFilial("DUD")+"'"
	cQuery += " AND DUD_FILORI = '"+cFilAnt+"'"
	cQuery += " AND DUD_VIAGEM = '"+cViagem+"'"
	cQuery += " AND DUD_STATUS <> '9' "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	cAliasDUD := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDUD,.F.,.T.)
	If (cAliasDUD)->(!Eof())
		nQtdDoc := (cAliasDUD)->QTDDOC
	EndIf		
	(cAliasDUD)->(DbCloseArea())
	
	AAdd (aFields,{'viagem.documento.qtde', AllTrim(Str(nQtdDoc))})//Quantidade de doctos.
	
	nCont := 0
	DUD->(DbSetOrder(2))
	If DUD->(DbSeek(xFilial('DUD')+ cFilOri + cViagem))
		While DUD->(DUD_FILIAL+DUD_FILORI+DUD_VIAGEM) == xFilial('DUD')+cFilOri+CViagem
			If DUD->DUD_STATUS <> '9'
				nCont++
				AAdd (aFields, {'viagem.documento'+AllTrim(Str(nCont))+'.tipo', cTipDoc}) //Se Coleta = 11 -ordem de coleta  se transferencia ou entrega = 5=conhecimento
				AAdd (aFields, {'viagem.documento'+AllTrim(Str(nCont))+'.numero', AllTrim(DUD->DUD_DOC)})
			EndIf
			DUD->(DbSkip())
		EndDo
	EndIf
	
	cCartSaldo := TMSIDPAM(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,'2')  //Tipo Parcela do Pagamento da Viagem
	
	AAdd (aFields, {'viagem.contrato.numero', AllTrim(DTQ->DTQ_FILORI) + AllTrim(DTQ->DTQ_VIAGEM)} )
	AAdd (aFields, {'viagem.cartao.numero', AllTrim(cCartSaldo)} )
	AAdd (aFields, {'viagem.cartao.portador.documento.tipo', '2'} )
	AAdd (aFields, {'viagem.cartao.portador.documento.numero', AllTrim(DA4->DA4_CGC) } )
	AAdd (aFields, {'viagem.cartao.portador.nome', AllTrim(DA4->DA4_NOME)} )
	AAdd (aFields, {'viagem.veiculo.placa', cPlacaVei} )
	AAdd (aFields, {'viagem.veiculo.categoria', cValToChar(PamCatVeic(DTR->DTR_QTDEIX)) } )
	AAdd (aFields, {'viagem.data.partida', SubStr(DtoS(dDataBase),7,2) + '/' + SubStr(DtoS(dDataBase),5,2) + '/' + SubStr(DtoS(dDataBase),1,4) } )
	
	//-- Verifica se o cliente trabalha com rota ou com pontos de descarga para calculo de pedagio e envio do contrato
	If SuperGetMv("MV_PAMROTA",.F.,.T.)
		AAdd (aFields,{'viagem.rota.nome', AllTrim(DTQ->DTQ_ROTA) })  			
	Else        
		//-- Retorna pontos de descarga da viagem
		PamPtoDca(@aFields, cFilOri, cViagem )
	EndIf		
	If Posicione('DEG',1,xFilial('DEG')+cCodOpe,'DEG_CALPDG') == '1' 	
		cRoteiriza := 'S'
	EndIf
	If lOnlyPdg .And. DTR->DTR_VALPDG > 0
		If lDTRTPSPDG
			cTipPagPDG := DTR->DTR_TPSPDG
		Else
			cTipPagPDG := DUP->DUP_TPSPDG
		EndIf
		If Len(aForPag) > 0 // Se existir a tabela DLD
			If (nParcPedag := Ascan(aForPag, {|x|  x[2] == '3'})) > 0 //Se existir parcela de ped?io
				cCartPedag := Alltrim(aForPag[nParcPedag,4])
			ElseIf (nParcPedag := Ascan(aForPag, {|x|  x[2] == '2'})) > 0 //Se  n? existir parcela de ped?io considera o cart? da parcela de saldo do frete
				cCartPedag := Alltrim(aForPag[ nParcPedag,4])
			Endif
			If Empty(cCartPedag) .And.  (nParcPedag := Ascan(aForPag, {|x|  x[2] == '1'})) > 0 //Se n? encontrar cart? considera o cart? da parcela de adiantamento
				cCartPedag := Alltrim(aForPag[ nParcPedag,4])
			EndIf
		Else //Regra antiga
			cCartPedag := AllTrim(DUP->DUP_IDOPE)
		EndIf

		AAdd (aFields,{'viagem.pedagio.solucao.id', AllTrim(cTipPagPDG) })
		AAdd (aFields,{'viagem.pedagio.valor', StrTran( AllTrim(TransForm( DTR->DTR_VALPDG, '@E 999999999.99')), ',','.' ) })

		If cTipPagPDG == '5' //Pedagio pago pelo sistema Pamcard
			AAdd (aFields,{'viagem.pedagio.status.id', '2'})
			AAdd (aFields,{'viagem.pedagio.roteirizar',  cRoteiriza})
			AAdd (aFields,{'viagem.pedagio.obter.praca', cRoteiriza})
			If lCfUtSaldo
				AAdd (aFields, {'viagem.pedagio.utiliza.saldo', Iif(lUtilSaldo == .T., 'S', 'N')} )
			EndIf
			AAdd (aFields,{'viagem.pedagio.cartao.numero', AllTrim(cCartPedag)})
		EndIf
	Else
		If DTR->DTR_VALPDG > 0
			AAdd (aFields, {'viagem.pedagio.origem', '1'} )
			AAdd (aFields, {'viagem.pedagio.valor', StrTran( AllTrim(TransForm( DTR->DTR_VALPDG, '@E 999999999.99')), ',','.' ) } )
			AAdd (aFields, {'viagem.pedagio.status.id', '2' })
			AAdd (aFields, {'viagem.pedagio.roteirizar', cRoteiriza} )
			AAdd (aFields, {'viagem.pedagio.obter.praca', cRoteiriza} )
		EndIf	
		If DTR->DTR_VALPDG > 0 .And. lCfUtSaldo
			AAdd (aFields, {'viagem.pedagio.utiliza.saldo', Iif(lUtilSaldo == .T., 'S', 'N')} )
		EndIf
	EndIf	
	
	
	If !lOnlyPdg
		nAdiFre	:= PamAdiFre(cFilOri, cViagem, DTR->DTR_CODVEI, .F.)
	
		If nAdiFre  > 0  //Funcao que retorna o valor de adiantamento do frete (Pega as despesas da tabela SDG que movimenta Banco).
			AAdd (aFields, {'viagem.parcela.qtde', '1' })
			AAdd (aFields, {'viagem.parcela1.tipo', '1'} ) //Adiantamento
			AAdd (aFields, {'viagem.parcela1.origem', '1'}) //Valor fixo
			AAdd (aFields, {'viagem.parcela1.data', SubStr(DtoS(dDataBase),7,2) + '/' + SubStr(DtoS(dDataBase),5,2) + '/' + SubStr(DtoS(dDataBase),1,4) })
			AAdd (aFields, {'viagem.parcela1.valor', StrTran( AllTrim(TransForm( nAdiFre, '@E 999999999.99')), ',','.' ) } )  //valor do adiantamento
			AAdd (aFields, {'viagem.parcela1.base','N' })
			AAdd (aFields, {'viagem.parcela1.status.id', '1'}) //Status  Pendente
			AAdd (aFields, {'viagem.parcela1.efetivacao.tipo', '2'}) //Efetivação automatica
			AAdd (aFields, {'viagem.parcela1.numero.cliente', cParAdi})//Adiantamento

        Else //Parcela com valor zerado
            AAdd (aFields, {'viagem.parcela.qtde', '1' })
			AAdd (aFields, {'viagem.parcela1.tipo', '1'} ) //Adiantamento
			AAdd (aFields, {'viagem.parcela1.origem', '1'}) //Valor fixo
			AAdd (aFields, {'viagem.parcela1.data', SubStr(DtoS(dDataBase),7,2) + '/' + SubStr(DtoS(dDataBase),5,2) + '/' + SubStr(DtoS(dDataBase),1,4) })
			AAdd (aFields, {'viagem.parcela1.valor', '1.00' } )  //valor do adiantamento
			AAdd (aFields, {'viagem.parcela1.base','N' })
			AAdd (aFields, {'viagem.parcela1.status.id', '1'}) //Status  Pendente
			AAdd (aFields, {'viagem.parcela1.efetivacao.tipo', '1'}) //Efetivação Pendente
			AAdd (aFields, {'viagem.parcela1.numero.cliente', cParAdi})//Adiantamento
		EndIf
	EndIf
	
	If	lDTRAbast 
		If cTpPessoa == '1' .And. DTR->DTR_VLABST > 0 
			AAdd(aFields, {'viagem.favorecido1.consumo.responsavel.nome'    ,AllTrim(DA4->DA4_NOME)} )
			AAdd(aFields, {'viagem.favorecido1.consumo.responsavel.cpf'	    ,AllTrim(DA4->DA4_CGC) } )
		EndIf
	EndIf

	lRet := PamInsTrip(aFields, @cIDOpe) //Chamada da Função
	
	If lRet
		RecLock('DTQ',.F.)
		If lOnlyPdg .And. DTQ->(ColumnPos("DTQ_IDPDG")) > 0
			DTQ->DTQ_IDPDG := cIdOpe
		Else
			DTQ->DTQ_IDOPE := cIdOpe
		EndIf
		DTQ->(MsUnLock())
	EndIf
EndIf

RestArea(aAreaDTR)
RestArea(aAreaDUP)
RestArea(aAreaDA4)
RestArea(aAreaDA3)
RestArea(aAreaDTQ)
RestArea(aAreaDUD)

FwFreeObj(aFields)
FwFreeObj(aAreaDTR)
FwFreeObj(aAreaDUP)
FwFreeObj(aAreaDA4)
FwFreeObj(aAreaDA3)
FwFreeObj(aAreaDTQ)
FwFreeObj(aAreaDUD)
Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamAltPaVg ³ Autor:³ Gilson da Silva        ³ Data:³17/01/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Altera o Status da Parcela da Viagem de pendente para liberada³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ExpC1 = Filial Origem da Viagem                               ³±±
±±³           ³ExpC2 = Numero da Viagem                                      ³±±
±±³           ³ExpA1 = Dados da Transportadora                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamAltPaVg(ExpC1, ExpC2, ExpA1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ Apontamento da Operacao de saida, viagem Frota Propria.      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamAltPaVg(cFilOri, cViagem, aRetCNPJ)
Local lRet       := .T.
Local aFields    := {}
Local nAdiFre    := 0
Local nRetParc   := 0
Local aArea      := GetArea()
Local aAreaDTR   := DTR->(GetArea())                 
Local cParAdi    := '1'
Local lCIOTPerio := .F.

//Posiciona na tabela de Complementos da viagem (Veiculo da viagem).
DTR->(DbSetOrder(1))
If !DTR->(DbSeek(xFilial('DTR') + cFilOri + cViagem))
	Help("",1, "REGNOIS")
	lRet := .F.
EndIf

If lRet
	lCIOTPerio := DTR->(FieldPos("DTR_TPCIOT")) > 0 .And. DTR->DTR_TPCIOT == "2"

	//-- Quando utiliza CIOT por período, o id da parcela conterá o nro da viagem pois não pode ser duplicado na pamcard
	If lCIOTPerio
		cParAdi := PamIdAdto(cFilOri, cViagem, DTR->DTR_CODVEI)
	EndIf

	nAdiFre := PamAdiFre(cFilOri, cViagem, DTR->DTR_CODVEI, .F.)

	If nAdiFre > 0
		//Chama a rotina que consulta a parcela da viagem
		nRetParc := PamConParc(cFilOri, cViagem, aRetCNPJ, cParAdi )
		
		If nRetParc == 0   //Nao encontrou parcela.
			Return .T.
		EndIf
		
		If nRetParc == 1 .Or. nRetParc == 3   //Parcela pendente ou bloqueada.
			AAdd (aFields,{'viagem.id', AllTrim(DTQ->DTQ_IDOPE)})
			AAdd (aFields,{'viagem.contratante.documento.numero',aRetCNPJ[1]} )
			AAdd (aFields,{'viagem.unidade.documento.tipo', aRetCNPJ[2] })
			AAdd (aFields,{'viagem.unidade.documento.numero', aRetCNPJ[3]} )
			AAdd (aFields,{'viagem.parcela.qtde', '1' })
			AAdd (aFields,{'viagem.parcela1.numero', cParAdi} )
			AAdd (aFields,{'viagem.parcela1.status.id', '2' } ) //--Liberado para Pagto.
			
			lRet := PamAltStPa(aFields) //Chamada da Função
		Else
			Help("",1, "TMSPAM008",,,3,0)//		"O status da parcela da viagem no sistema Pamcard", " nao permite apontar a operacao de saida da viagem. ", "Entre no sistema Pamcard via Web e verifique."
			lRet := .F.
		EndIf
	EndIf
EndIf
RestArea(aAreaDTR)
RestArea(aArea)

FwFreeObj(aArea 	)
FwFreeObj(aAreaDTR	)
FwFreeObj(aFields	)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamEstPaVg ³ Autor:³ Gilson da Silva        ³ Data:³17/01/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Altera Status da Parcela da Viagem de Liberada para Bloqueada ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ExpC1 = Filial Origem da Viagem                               ³±±
±±³           ³ExpC2 = Numero da Viagem                                      ³±±
±±³           ³ExpA1 = Dados da Transportadora                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamEstPaVg(ExpC1, ExpC2, ExpA1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ Estorno da operacao de saida, viagem frota propria.          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamEstPaVg(cFilOri, cViagem, aRetCNPJ)
Local lRet       := .T.
Local aFields    := {}
Local nRetParc   := 0
Local aArea      := GetArea()
Local aAreaDTR   := DTR->(GetArea())
Local nRet       := 0                               
Local cParAdi	   := '1'
Local lCIOTPerio := .F.

//Posiciona na tabela de Complementos da viagem.
DTR->(DbSetOrder(1))
DTR->(DbSeek(xFilial('DTR') + cFilOri + cViagem))

lCIOTPerio := DTR->(FieldPos("DTR_TPCIOT")) > 0 .And. DTR->DTR_TPCIOT == "2"

//-- Quando utiliza CIOT por período, o id da parcela conterá o nro da viagem pois não pode ser duplicado na pamcard
If lCIOTPerio
	cParAdi := PamIdAdto(cFilOri, cViagem, DTR->DTR_CODVEI)
EndIf
                                                           
//Chama a rotina que consulta o status do pedágio da viagem
nRet := PamConPdVg(cFilOri, cViagem, aRetCNPJ)
If nRet == 0 .Or. nRet == 5 .Or. nRet == 8
	If nRet == 5 .Or. nRet == 8
		Help("",1, "TMSPAM011",,oObjPam:oWSResponseTo:oReturn:oFieldTo[2]:cValue,4,0) //"Valor do pedagio ja carregado no cartão.", "Estorno não permitido."
	EndIf
	Return .F.
EndIf

//Chama a rotina que consulta a parcela da viagem
nRetParc := PamConParc(cFilOri, cViagem, aRetCNPJ,  cParAdi)

If nRetParc == 0     //Nao encontrou parcela
	Return .T.
EndIf

If nRetParc = 5 //Parcela já efetivada, nao permitir estornar a operacao de saida da viagem
	Help("",1, "TMSPAM009",,,3,0)  //"Parcela ja efetivada no sistema"###" Pamcard, estorno da saida ou exclusao"###" do contrato nao sera realizado."
	lRet := .F.
EndIf

If lRet
	aFields    := {}
	AAdd (aFields,{'viagem.id', AllTrim(DTQ->DTQ_IDOPE)})
	AAdd (aFields,{'viagem.contratante.documento.numero',aRetCNPJ[1]} )
	AAdd (aFields,{'viagem.unidade.documento.tipo', aRetCNPJ[2] })
	AAdd (aFields,{'viagem.unidade.documento.numero', aRetCNPJ[3]} )
	AAdd (aFields,{'viagem.parcela.qtde', '1' })
	AAdd (aFields,{'viagem.parcela1.numero', cParAdi} )
	AAdd (aFields,{'viagem.parcela1.status.id', '3' } ) //--Parcela Bloqueada
	lRet := PamAltStPa(aFields) //Chamada da Função
EndIf

RestArea(aAreaDTR)
RestArea(aArea)

FwFreeObj(aFields )
FwFreeObj(aArea	  )
FwFreeObj(aAreaDTR)
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamExcVge  ³ Autor:³ Gilson da Silva        ³ Data:³17/01/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Exclui a viagem no Sitema Pamcard							        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamExcVge                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³Estorno do Fechamento, viagem frota propria.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamExcVge(cFilOri, cViagem, aRetCNPJ)
Local lRet       := .T.
Local aFields    := {}
Local nRet       := 0
Local cMsgRet	 := ''

//Chama a rotina que consulta o status do pedágio da viagem
nRet := PamConPdVg(cFilOri, cViagem, aRetCNPJ,@cMsgRet)
If nRet == 0 .Or. nRet == 5 .Or. nRet == 8
	If nRet == 5 .Or. nRet == 8
		Help("",1, "TMSPAM011",,cMsgRet,4,0)//"Valor do pedagio ja carregado no cartão.", "Estorno não permitido."
	EndIf
	Return .F.
EndIf

If DTQ->(ColumnPos("DTQ_IDPDG")) > 0 .And. !Empty(DTQ->DTQ_IDPDG)
	AAdd (aFields,{'viagem.id', AllTrim(DTQ->DTQ_IDPDG)})
Else
	AAdd (aFields,{'viagem.id', AllTrim(DTQ->DTQ_IDOPE)})
EndIf
AAdd (aFields,{'viagem.contratante.documento.numero',aRetCNPJ[1]} )
AAdd (aFields,{'viagem.unidade.documento.tipo', aRetCNPJ[2] })
AAdd (aFields,{'viagem.unidade.documento.numero', aRetCNPJ[3]} )

lRet := PamCanTrip(aFields) //Chamada da Função
If lRet 	
	RecLock('DTQ',.F.)
		DTQ->DTQ_IDOPE := ''
		If IsInCallStack("A310EstPam")
			DTQ->DTQ_IDCLI := ''
		EndIf
	MsUnLock()
EndIf
FwFreeObj(aFields)
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamIncCont ³ Autor:³ Gilson da Silva        ³ Data:³16/01/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Inclusao do Contrato no Sistema Pamcard   	                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamIncCont)                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³No Fechamento da viagem.                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamIncCont(cFilOri, cViagem, aRetCNPJ)
Local cTipDoc    := Iif(DTQ->DTQ_SERTMS == "1", "11", "5") //Se a viagem for de coleta o tipo de docto sera 11-Ordem de Coleta, senão sera 5=Conhecimento.
Local cNatCarga  := ''
Local cQuery     := ''
Local cPlacaVei  := ''
Local cPlacaRb1  := ''
Local cPlacaRb2  := ''
Local cPlacaRb3  := ''
Local cAliasDT6  := ''
Local cAliasDOC  := ''
Local cTpPessoa  := ''
Local cPesoVge   := ''
Local cCodMun    := ''   
Local lCfUtSaldo := GetMv('MV_TMSCFUS',,'.F.') //Empresa configurada para Utilizar o Saldo do Cartão.
Local lUtilSaldo := GetMV('MV_TMSUTSL',,'.F.') // Utiçiza o saldo do pedágio .
Local nFimCont   := GetMV('MV_FIMCONT',,0)    
Local lRet       := .T. 

Local nQtdDoc    := 0
Local nCont      := 0
Local nQtdVei    := 0
Local nAdiFre    := 0 
Local nValPdg	  := 0

Local aRet       := Array(3)
Local aFields    := {}
Local aAreaDTR   := DTR->(GetArea())
Local aAreaDUP   := DUP->(GetArea())
Local aAreaDA3   := DA3->(GetArea())
Local aAreaSA2   := SA2->(GetArea())
Local aAreaDTQ   := DTQ->(GetArea())
Local aAreaDA4   := DA4->(GetArea())
Local aAreaDEL   := DEL->(GetArea())
Local aAreaSA2_1
Local aAreaSA2_2

Local dFimContr  := dDataBase + nFimCont
Local lOk        := .F.                              
Local cCodOpe	 := ''
Local aVeiculos  := {}                              
Local aPtoDca	 := {}                              

Local cParAdi    := '1'
Local cParTaxa   := '2'
Local aCodFav	 := {}
Local nQtdFav	 := 1
Local cCodFav	 := ''
Local cLojFav	 := ''
Local nX		 := 0                       
Local aFav		 := {} //Dados dos Favorecidos
Local lExistFav  := .F.
Local cIdCli	 := ""                                                                                  
Local lRespCart  := .F.	
Local nCount	 := 0
Local cCodBan	 := ""  
Local aTaxBan	 := {}                                                  
Local nTxAdBan	 := 0
Local lExpMot 	 := .F.
Local cCPFMot 	 := ''
Local aPrcPdgOP	 := {}
Local lCIOTPerio := .F.
Local lTabDLD    := TableInDic('DLD')
Local aForPag	 := {}	
Local cTipFav	 := ""
Local nPosFav	 := 0
Local nParcPedag := 0
Local cCartPedag := ''
Local lDTRTPSPDG := DTR->(ColumnPos("DTR_TPSPDG")) > 0
Local cTipPagPDG := ''
Local cIdOpe     := ""
Local nQtdSaq    := 0
Local nQtdTra    := 0
Local lDTRQtdSaq := DTR->(ColumnPos("DTR_QTDSAQ")) > 0 
Local lDvcta	 := SA2->(ColumnPos("A2_DVCTA")) > 0 
Local cDvCta	 := ""
Local cCalcPdg   := ''//--INforma que é responsávle pelo cálculo do pedágio '1'-Operadora;'2'-TMS
Local lLotacao   := .F.
Local aCEPeDist  := {}
Local cCepRet    := ""
Local nKMRet     := 0
Local aDocVgeLot := {}
Local lUltDest   := SuperGetMv('MV_ULTDEST',,.F.) // Define se utiliza o ultimo destino da coleta/entrega.
Local lPagaRet   := .F.
Local lFrotaProp := .F.
Local cRoteiriza := "N"
Local lTagPedag  := .F.
Local lPayToll   := .T.
Local lDTRAbast  := DTR->(ColumnPos("DTR_VLABST")) > 0
Local cQtdParce  := '2'

//Posiciona na tabela de Complementos da viagem (Veiculo da viagem).
DTR->(DbSetOrder(1))
If DTR->(!dbSeek(xFilial('DTR') + cFilOri + cViagem))
	Help( ' ', 1, 'TMSXFUNA24' ) //-- Complemento de viagem nao encontrado (DTR)
	Return .F.         
Else
	cCodOpe := DTR->DTR_CODOPE	
	lCIOTPerio := DTR->(ColumnPos("DTR_TPCIOT")) > 0 .And. DTR->DTR_TPCIOT == "2"
EndIf
cCalcPdg := Posicione('DEG',1,xFilial('DEG')+cCodOpe,'DEG_CALPDG') 
//-- Quando utiliza CIOT por período, o id da parcela conterá o nro da viagem pois não pode ser duplicado na pamcard
If lCIOTPerio
	cParAdi := PamIdAdto(cFilOri, cViagem, DTR->DTR_CODVEI)
EndIf

nRecDTR := DTR->(Recno())	
//Posiciona na tabela de viagens
DTQ->(DbSetOrder(2))
If DTQ->(!dbSeek(xFilial('DTQ') + cFilOri + cViagem))
	Help(' ', 1, 'TMSXFUNA07') 	//-- Viagem nao encontrada (DTQ).
	Return .F.                        
Else
	cRotaVge := DTQ->DTQ_ROTA	
EndIf
nRecDTQ := DTQ->(Recno())	

//Posiciona na tabela de Motorista da viagem.
DUP->(DbSetOrder(1))
If DUP->(DbSeek(xFilial('DUP') + cFilOri + cViagem))
	lOk := PamCondut (cFilOri, cViagem)
EndIf

If lOk
	//Posiciona na tabela de veículos.
	DA3->(DbSetOrder(1))
	DA3->(DbSeek(xFilial('DA3')+DTR->DTR_CODVEI))
	lFrotaProp:= (DA3->DA3_FROVEI ==  StrZero(1,Len(DA3->DA3_FROVEI)) ) //1-Propria
		
	AAdd(aVeiculos,{ DTR->DTR_CODVEI, DTR->DTR_QTDEIX , DTR->DTR_QTEIXV })
	
	//Posiciona na Tabela de Fornecedor do veículo
	SA2->(dbSetOrder(1))
	If !SA2->(DbSeek(xFilial("SA2")+DA3->DA3_CODFOR+DA3->DA3_LOJFOR) )
		lRet := .F.
	EndIf

	//-- Verifica se a Viagem é do Tipo Lotacao (um unico Documento na Viagem)
	If lRet
		//Quantidade de documentos da viagem
		nQtdDoc:= PamQtDocVg(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,DTQ->DTQ_SERTMS)
		If nQtdDoc == 1 .And. lFrotaProp
			lLotacao:= .T. 
		EndIf
	EndIf	

	If lRet
		cTpPessoa   := Iif(SA2->A2_TIPO=="F", '2', '1')
		cPlacaVei  	:= StrTran(DA3->DA3_PLACA," ","")
		cPlacaVei   := StrTran(cPlacaVei,"-","")
		cNatCarga	:= PamVldCarg(cFilOri, cViagem)

/*		If lLotacao .And. lFrotaProp
			nQtdFav  := 1
		Else*/
			If lTabDLD .And. FindFunction('TmsForPag')
				//Formas de Pagamento da viagem
				aForPag 	:= TmsForPag(cFilOri,cViagem)
				lExpMot 	:= Ascan(aForPag, {|x|  x[3] == '2'}) > 0
				lExistFav 	:= Ascan(aForPag, {|x|  !Empty(x[5]) }) > 0
				
				If lExistFav
					nPosFav := Ascan(aForPag, {|x|  !Empty(x[5]) })
					cCodFav := aForPag[nPosFav][5]
					cLojFav := aForPag[nPosFav][6]
				Endif
		
				If lExpMot
					DA4->(DbSetOrder(1))
					If DA4->(MsSeek(xFilial("DA4")+DUP->DUP_CODMOT))
						cCPFMot := DA4->DA4_CGC
					EndIF
				EndIf

				aFav := PamQtdFav(lExistFav,lExpMot,aForPag,cCodOpe)
			Else
				/*	VERIFICA SE POSSUI FAVORECIDO NO VEICULO OU FORNECEDOR*/
				aCodFav := T250BscFav(DTR->DTR_CODVEI,DA3->DA3_CODFOR,DA3->DA3_LOJFOR,DTR->DTR_FILORI,DTR->DTR_VIAGEM)	// retorna o codigo do Favorecido 
				If !Empty(aCodFav)
					cCodFav := aCodFav[1][1]
					cLojFav := aCodFav[1][2]
					lExistFav := .T.
				EndIf
					DA4->(DbSetOrder(1))
					If DA4->(MsSeek(xFilial("DA4")+DUP->DUP_CODMOT))
						cCPFMot := DA4->DA4_CGC
					EndIF

				If cTpPessoa == '2'
					lExpMot := AllTrim(cCPFMot) <> AllTrim(SA2->A2_CGC) .AND. !Empty(cCPFMot)
				Else
					DDQ->(dbSetOrder(1))	
					If DDQ->(MsSeek(xFilial('DDQ')+DUP->DUP_IDOPE))
						lExpMot := AllTrim(cCPFMot) <> AllTrim(DDQ->DDQ_CGC) .AND. !Empty(cCPFMot)
					EndIf
				EndIf

				aFav := PamQtdFav(lExistFav,lExpMot,,cCodOpe)		
			EndIf				
			nQtdFav		:=Len(aFav)
		//EndIf

		AAdd (aFields,{'viagem.contratante.documento.numero',aRetCNPJ[1]} )
		AAdd (aFields,{'viagem.unidade.documento.tipo', aRetCNPJ[2] })
		AAdd (aFields,{'viagem.unidade.documento.numero', aRetCNPJ[3]} )

		If cTpPessoa == '1' .And. !lLotacao
			AAdd (aFields,{'viagem.cartao.empresa.nome', AllTrim(SA2->A2_NOME)} )
			AAdd (aFields,{'viagem.cartao.empresa.cnpj', AllTrim(SA2->A2_CGC) } )				
		EndIf	
		
		AAdd (aFields,{'viagem.contrato.numero',cFilOri+cViagem})
		AAdd (aFields,{'viagem.favorecido.qtde',AllTrim(Str(nQtdFav))})
		
/*		If lLotacao .And. lFrotaProp
			AAdd (aFields,{'viagem.favorecido1.tipo','1' })
			AAdd (aFields,{'viagem.favorecido1.documento.qtde', '1' })  //Se for incluir o favorecido do veiculo ou fornecedor envia apenas um documento.
			AAdd (aFields,{'viagem.favorecido1.documento1.tipo', '1'})			
			AAdd (aFields,{'viagem.favorecido1.documento1.numero', AllTrim(SM0->M0_CGC) })
			AAdd (aFields,{'viagem.favorecido1.documento2.tipo', '6' })  //Se pessoa juridica o tipo de docto RNTRC eh igual a 6, senao o tipo de docto RNTRC eh igual a 5.
			AAdd (aFields,{'viagem.favorecido1.documento2.numero', AllTrim(SM0->M0_RNTRC)  })
		Else*/
			For nX := 1 To Len(aFav)
				aAreaSA2_1 := SA2->(GetArea())		
				If aFav[nX][1] == '2' //Se houver necessidade de enviar o Favorecido Posiciona no SA2 do mesmo.
					If !SA2->(dbSeek(xFilial('SA2')+cCodFav+cLojFav))
						Help(' ', 1, 'TMSA24071') //'Não foi encontrado o favorecido', 'no cadastro de fornecedor.'
						lRet := .F.
						Exit
					EndIf
				EndIf          
				If lRet          
					lRespCart := .F.
					If aFav[nX][1] <> '3'
						If !Empty(AllTrim(aFav[nX][3]))
							DDQ->(dbSetOrder(1))
							If DDQ->(dbSeek(xFilial('DDQ')+AllTrim(aFav[nX][3])))
								lRespCart := .T.
							EndIf
						EndIf	
						AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.tipo',AllTrim(Str(nX))})
						AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.documento.qtde', IIf(nx==1,'2','1')})  //Se for incluir o favorecido do veiculo ou fornecedor envia apenas um documento.
						AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.documento1.tipo', cTpPessoa})			
						AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.documento1.numero', Iif(lRespCart,AllTrim(DDQ->DDQ_CGC),AllTrim(SA2->A2_CGC)) })
						If nX == 1 //Manda o RNTRC apenas do Proprietario do Veiculo
							AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.documento2.tipo', Iif(cTpPessoa== '1', '6', '5') })  //Se pessoa juridica o tipo de docto RNTRC eh igual a 6, senao o tipo de docto RNTRC eh igual a 5.
							AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.documento2.numero', AllTrim(SA2->A2_RNTRC) })
						EndIf
						AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.meio.pagamento', aFav[nX][2]})
						If aFav[nX][2] == '2'
							If lDvcta
								cDvCta := SA2->A2_DVCTA 
							EndIf 
							AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.conta.banco'	 , AllTrim(SA2->A2_BANCO) 	})
							AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.conta.agencia', AllTrim(SA2->A2_AGENCIA)})
							AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.conta.numero' , AllTrim(SA2->A2_NUMCON) + AllTrim(cDvCta)	})
							AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.conta.tipo'	 , AllTrim(SA2->A2_TPCONTA)})
						Else
							AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.cartao.numero', AllTrim(aFav[nX][3])})
						EndIf	
			
					Else
						If Len(aFav) == 2
							cFavId := Alltrim(aFav[nX][1])
						Else
							cFavId := AllTrim(Str(nX))
						EndIf
						AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.tipo',cFavId})
						AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.documento.qtde','2'})
						AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.documento1.tipo','2'})
						AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.documento1.numero', AllTrim(DA4->DA4_CGC)})
						AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.documento2.tipo','3'})
						AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.documento2.numero', AllTrim(DA4->DA4_RG)})
						AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.documento2.uf', AllTrim(DA4->DA4_RGEST)})
						AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.nome', AllTrim(DA4->DA4_NOME)})	  
						AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.data.nascimento', SubStr(DtoS(DA4->DA4_DATNAS),7,2) + '/' + SubStr(DtoS(DA4->DA4_DATNAS),5,2) + '/' + SubStr(DtoS(DA4->DA4_DATNAS),1,4) } )	  
						AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.endereco.logradouro', AllTrim(FisGetEnd(DA4->DA4_END)[1])})
						AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.endereco.numero', AllTrim(cValtoChar( FisGetEnd(DA4->DA4_END)[2]))})
						AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.endereco.bairro', AllTrim(DA4->DA4_BAIRRO)})
						AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.endereco.cidade.ibge', TMS120CDUF(DA4->DA4_EST, '1') + AllTrim(DA4->DA4_CODMUN) } )
						AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.endereco.cep', AllTrim(DA4->DA4_CEP)})
						AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.telefone.ddd', AllTrim(DA4->DA4_DDD)})
						AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.telefone.numero', AllTrim(StrTran(DA4->DA4_TEL,"-","")) } )
						
						If !Empty(aFav[nX][3])
							AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.meio.pagamento','1'})
							AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.cartao.numero', AllTrim(aFav[nX][3])})
						Else	
							aAreaSA2_2 := SA2->(GetArea())
							SA2->(dbSetOrder(1))
							If SA2->(DbSeek(xFilial("SA2")+DA4->DA4_FORNEC+DA4->DA4_LOJA) )
								If lDvcta
									cDvCta := SA2->A2_DVCTA 
								EndIf 
								AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.meio.pagamento','2'})	      
								AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.conta.banco', AllTrim(SA2->A2_BANCO)})
								AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.conta.agencia', AllTrim(SA2->A2_AGENCIA)})
								AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.conta.numero', AllTrim(SA2->A2_NUMCON)+ AllTrim(cDvCta)})
								AAdd (aFields,{'viagem.favorecido'+AllTrim(Str(nX))+'.conta.tipo', AllTrim(SA2->A2_TPCONTA)})
							Else
								Help(' ', 1, 'TMSA24071') //'Não foi encontrado o fornecedor do ', 'motorista no cadastro de fornecedor.'
							lRet := .F.
							EndIf
							RestArea(aAreaSA2_2)
						EndIf	  	
					EndIf
				EndIf
				RestArea(aAreaSA2_1)	
			Next
		//EndIf

	EndIf

	If lRet
		nQtdVei:= 1
		If !Empty(DTR->DTR_CODRB1)
			nQtdVei++
		EndIf
		
		If !Empty(DTR->DTR_CODRB2)
			nQtdVei++
		EndIf

		If !Empty(DTR->DTR_CODRB3)
			nQtdVei++
		EndIf

		AAdd (aFields,{'viagem.veiculo.qtde', cValToChar(nQtdVei)})
		AAdd (aFields,{'viagem.veiculo1.placa', AllTrim(cPlacaVei)})
		AAdd (aFields,{'viagem.veiculo1.rntrc', AllTrim(SA2->A2_RNTRC) })

		If !Empty(DTR->DTR_CODRB1)
			//Posiciona na tabela de veículos.
			DA3->(DbSetOrder(1))
			DA3->(DbSeek(xFilial('DA3')+DTR->DTR_CODRB1))
				
			AAdd(aVeiculos,{ DTR->DTR_CODRB1, 0 ,0 })
				
			//Posiciona na Tabela de Fornecedor do primeiro reboque
			SA2->(dbSetOrder(1))
			SA2->(DbSeek(xFilial("SA2")+DA3->DA3_CODFOR+DA3->DA3_LOJFOR) )
				
			cPlacaRB1  := StrTran(DA3->DA3_PLACA," ","")
			cPlacaRB1  := StrTran(cPlacaRB1,"-","")
				
			AAdd (aFields,{'viagem.veiculo2.placa', AllTrim(cPlacaRB1)})
			AAdd (aFields,{'viagem.veiculo2.rntrc', AllTrim(SA2->A2_RNTRC)})
		EndIf
			
		If !Empty(DTR->DTR_CODRB2)
			//Posiciona na tabela de veículos.
			DA3->(DbSetOrder(1))
			DA3->(DbSeek(xFilial('DA3')+DTR->DTR_CODRB2))
			
			AAdd(aVeiculos,{ DTR->DTR_CODRB2, 0 , 0 })
				
			//Posiciona na Tabela de Fornecedor do segundo reboque
			SA2->(dbSetOrder(1))
			SA2->(DbSeek(xFilial("SA2")+DA3->DA3_CODFOR+DA3->DA3_LOJFOR) )
				
			cPlacaRB2  := StrTran(DA3->DA3_PLACA," ","")
			cPlacaRB2  := StrTran(cPlacaRB2,"-","")
			
			AAdd (aFields,{'viagem.veiculo3.placa', AllTrim(cPlacaRB2)})
			AAdd (aFields,{'viagem.veiculo3.rntrc', AllTrim(SA2->A2_RNTRC) })
		EndIf
			
		If !Empty(DTR->DTR_CODRB3)
			//Posiciona na tabela de veículos.
			DA3->(DbSetOrder(1))
			DA3->(DbSeek(xFilial('DA3')+DTR->DTR_CODRB3))
			
			AAdd(aVeiculos,{ DTR->DTR_CODRB3, 0 , 0 })
				
			//Posiciona na Tabela de Fornecedor do terceiro reboque
			SA2->(dbSetOrder(1))
			SA2->(DbSeek(xFilial("SA2")+DA3->DA3_CODFOR+DA3->DA3_LOJFOR) )
				
			cPlacaRB3  := StrTran(DA3->DA3_PLACA," ","")
			cPlacaRB3  := StrTran(cPlacaRB3,"-","")
			
			AAdd (aFields,{'viagem.veiculo4.placa', AllTrim(cPlacaRB3)})
			AAdd (aFields,{'viagem.veiculo4.rntrc', AllTrim(SA2->A2_RNTRC) })
		EndIf
		AAdd (aFields,{'viagem.veiculo.categoria', AllTrim(cValToChar( PamCatVeic(DTR->DTR_QTDEIX) ) ) })
		AAdd (aFields,{'viagem.data.partida', SubStr(DtoS(dDataBase),7,2) + '/' + SubStr(DtoS(dDataBase),5,2) + '/' + SubStr(DtoS(dDataBase),1,4) })
		If lCIOTPerio
			dFimContr := DTR->DTR_DTFMCI
		EndIf
		AAdd (aFields,{'viagem.data.termino', SubStr(DtoS(dFimContr),7,2) + '/' + SubStr(DtoS(dFimContr),5,2) + '/' + SubStr(DtoS(dFimContr),1,4) })
		
			
		//-- Verifica se o cliente trabalha com rota ou com pontos de descarga para calculo de pedagio e envio do contrato
		If SuperGetMv("MV_PAMROTA",.F.,.T.)
			AAdd (aFields,{'viagem.rota.nome', AllTrim(DTQ->DTQ_ROTA) })  							
		Else                                                  			
			//-- Retorna pontos de descarga da viagem                      
			PamPtoDca(@aFields, cFilOri, cViagem, @aPtoDca )					
		EndIf	

		If lDTRTPSPDG
			cTipPagPDG := DTR->DTR_TPSPDG
		Else
			cTipPagPDG := DUP->DUP_TPSPDG
		EndIf

		If cTipPagPDG <> '4' .And. !lFrotaProp
			nValPdg := TmsCalPdg(aVeiculos,cRotaVge,cCodOpe,,aPtoDca,,@aPrcPdgOP)
		EndIf

		//--Se o cálculo do pedágio for realizado pelo Protheus, só será chamada a funçaõ se o valor não estiver informado na DTR
		If cCalcPdg == '1'  .Or. DTR->DTR_VALPDG == 0 //-- Calcula pela operadora			
			RecLock('DTR',.F.)
			DTR->DTR_VALPDG := nValPdg
			MsUnLock()
		Else //--Se o pedágio tiver sido calculado ou informado na geração da viagem altera, considera este valor para envio a Pamcard.
			nValPdg := DTR->DTR_VALPDG 
		EndIf
			
		If nValPdg > 0 .And. !lCIOTPerio

			AAdd (aFields,{'viagem.pedagio.solucao.id', AllTrim(cTipPagPDG) })
			AAdd (aFields,{'viagem.pedagio.valor', StrTran( AllTrim(TransForm( nValPDG, '@E 999999999.99')), ',','.' ) })

			If cTipPagPDG == '6' //Pedagio pago pelo sistema Pamcard TAG
				If Posicione('DEG',1,xFilial('DEG')+cCodOpe,'DEG_CALPDG') == '1' 	
					cRoteiriza := 'S'
				EndIf
				AAdd (aFields,{'viagem.pedagio.tag.emissor.id',  PamIDTag('02',DTR->DTR_CODVEI)})
				AAdd (aFields, {'viagem.pedagio.status.id', '2' })
				AAdd (aFields,{'viagem.pedagio.roteirizar',  cRoteiriza})
			EndIf

			If cTipPagPDG == '5' //Pedagio pago pelo sistema Pamcard
				If Len(aForPag) > 0 // Se existir a tabela DLD
					If (nParcPedag := Ascan(aForPag, {|x|  x[2] == '3'})) > 0 //Se existir parcela de pedágio
						cCartPedag := Alltrim(aForPag[nParcPedag,4])
					ElseIf (nParcPedag := Ascan(aForPag, {|x|  x[2] == '2'})) > 0 //Se  não existir parcela de pedágio considera o cartão da parcela de saldo do frete
						cCartPedag := Alltrim(aForPag[ nParcPedag,4])
					Endif
					If Empty(cCartPedag) .And.  (nParcPedag := Ascan(aForPag, {|x|  x[2] == '1'})) > 0 //Se não encontrar cartão considera o cartão da parcela de adiantamento
							cCartPedag := Alltrim(aForPag[ nParcPedag,4])
					EndIf
				Else //Regra antiga
					cCartPedag := AllTrim(DUP->DUP_IDOPE)
				EndIf
				AAdd (aFields,{'viagem.pedagio.status.id', '2'})

				If cCalcPdg = '1' //-- Calcula pela operadora   
					AAdd (aFields,{'viagem.pedagio.roteirizar', 'S'})
					AAdd (aFields,{'viagem.pedagio.obter.praca', 'S'})
					If lCfUtSaldo
						AAdd (aFields, {'viagem.pedagio.utiliza.saldo', Iif(lUtilSaldo == .T., 'S', 'N')} )
					EndIf
					AAdd (aFields,{'viagem.pedagio.cartao.numero', cCartPedag})
				Else
					AAdd (aFields,{'viagem.pedagio.roteirizar', 'N'})
					AAdd (aFields,{'viagem.pedagio.obter.praca', 'N'})
					If lCfUtSaldo
						AAdd (aFields, {'viagem.pedagio.utiliza.saldo', Iif(lUtilSaldo == .T., 'S', 'N')} )
					EndIf
					AAdd (aFields,{'viagem.pedagio.cartao.numero', cCartPedag})
		
					If !Empty(aPrcPdgOP)
						AAdd (aFields, {'viagem.pedagio.praca.qtde', cValToChar(Len(aPrcPdgOP))})
						For nCount := 1 to Len(aPrcPdgOP)
							AAdd (aFields, {'viagem.pedagio.praca'+cValToChar(nCount)+'.id', cValToChar(aPrcPdgOP[nCount][1]) })
							AAdd (aFields, {'viagem.pedagio.praca'+cValToChar(nCount)+'.valor', cValToChar(aPrcPdgOP[nCount][2]) })
						Next nCount
					EndIf
				EndIf
			EndIf
		EndIf                                                                                                           
			
		AAdd(aFields,{'viagem.carga.natureza', AllTrim(cNatCarga)})
			
		If DTQ->DTQ_SERTMS == '1' //Viagem de coleta   
			//Somatoria do Peso da viagem  
			cQuery := " SELECT SUM(DT6_PESO) PESO "
			cQuery += "   FROM " + RetSqlName("DUD") + " DUD, "
			cQuery +=              RetSqlName("DT6") + " DT6, "
			cQuery +=              RetSqlName("DT5") + " DT5, "
			cQuery +=              RetSqlName("DUE") + " DUE, "
			cQuery +=              RetSqlName("SA1") + " SA1R, "
			cQuery +=              RetSqlName("SA1") + " SA1D "
			cQuery += " WHERE DUD.DUD_FILIAL = '" + xFilial("DUD")+"'"
			cQuery += " AND DUD.DUD_FILORI = '" + cFilOri+"'"
			cQuery += " AND DUD.DUD_VIAGEM = '" + cViagem + "'"
			cQuery += " AND DUD.DUD_STATUS <> '9' "
			cQuery += " AND DUD.D_E_L_E_T_ = ' ' "
			cQuery += " AND DT6.DT6_FILIAL = '" + xFilial("DT6") + "'"
			cQuery += " AND DT6.DT6_FILDOC = DUD.DUD_FILDOC"
			cQuery += " AND DT6.DT6_DOC = DUD.DUD_DOC"
			cQuery += " AND DT6.DT6_SERIE = DUD.DUD_SERIE"
			cQuery += " AND DT6.D_E_L_E_T_ = ' ' "
			cQuery += " AND DT5.DT5_FILIAL = '" + xFilial("DT5") + "'"
			cQuery += " AND DT5.DT5_FILDOC = DT6.DT6_FILDOC"
			cQuery += " AND DT5.DT5_DOC = DT6.DT6_DOC"
			cQuery += " AND DT5.DT5_SERIE = DT6.DT6_SERIE"
			cQuery += " AND DT5.D_E_L_E_T_ = ' ' "  
			cQuery += " AND DUE.DUE_FILIAL = '" + xFilial("DUE")+"'""
			cQuery += " AND DUE.DUE_CODSOL = DT5_CODSOL "
			cQuery += " AND DUE.D_E_L_E_T_ = ' ' "  
			cQuery += " AND SA1R.A1_FILIAL = '" + xFilial("SA1")+"'"
			cQuery += " AND SA1R.A1_COD    = DUE_CODCLI "
			cQuery += " AND SA1R.A1_LOJA   = DUE_LOJCLI "  
			cQuery += " AND SA1R.A1_TIPO <> 'X' "
			cQuery += " AND SA1R.D_E_L_E_T_ = ' ' "  
			cQuery += " AND SA1D.A1_FILIAL = '" + xFilial("SA1")+"'"  
			cQuery += " AND SA1D.A1_COD    = DT5_CLIDES "
			cQuery += " AND SA1D.A1_LOJA   = DT5_LOJDES "  
			cQuery += " AND SA1D.A1_TIPO   <> 'X' "
			cQuery += " AND SA1D.D_E_L_E_T_ = ' '
			
			cQuery := ChangeQuery(cQuery)
			
			cAliasDT6 := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDT6,.F.,.T.)
				
			cPesoVge := Iif( (cAliasDT6)->PESO == 0, '1',  AllTrim(TransForm( (cAliasDT6)->PESO, PesqPict('DT6','DT6_VALFRE'))) )
			cPesoVge := StrTran(cPesoVge, '.','')
			cPesoVge := StrTran(cPesoVge, ',','.')
			(cAliasDT6)->(DbCloseArea())
				
			//Quantidade de documentos da viagem
		    //	nQtdDoc:= PamQtDocVg(cFilOri,cViagem,DTQ->DTQ_SERTMS)
			
			//Seleciona os documentos da viagem                                                                                          
			cQuery := " SELECT DUD_FILDOC, DUD_DOC, DUD_SERIE, DT6_QTDVOL, SA1R.A1_PESSOA PESSOAREM, SA1R.A1_EST ESTREM, SA1R.A1_COD_MUN COD_MUNREM, "
			cQuery += " SA1R.A1_CGC CGCREM, SA1R.A1_NOME NOMEREM, SA1R.A1_END ENDEREM, SA1R.A1_BAIRRO BAIRROREM , SA1R.A1_CEP CEPREM,"
			cQuery += " SA1D.A1_PESSOA PESSOADES, SA1D.A1_EST ESTDES, SA1D.A1_COD_MUN COD_MUNDES, SA1D.A1_CGC CGCDES, SA1D.A1_NOME NOMEDES, "
			cQuery += "  SA1D.A1_END ENDDES, SA1D.A1_BAIRRO BAIRRODES, SA1D.A1_CEP CEPDES, DT6_VALFRE  "
			cQuery += "   FROM " + RetSqlName("DUD") + " DUD, "
			cQuery +=              RetSqlName("DT6") + " DT6, "
			cQuery +=              RetSqlName("DT5") + " DT5, "
			cQuery +=              RetSqlName("DUE") + " DUE, "
			cQuery +=              RetSqlName("SA1") + " SA1R, "
			cQuery +=              RetSqlName("SA1") + " SA1D "
			cQuery += " WHERE DUD.DUD_FILIAL = '"+xFilial("DUD")+"'"
			cQuery += " AND DUD.DUD_FILORI = '"+cFilOri+"'"
			cQuery += " AND DUD.DUD_VIAGEM = '"+cViagem+"'"
			cQuery += " AND DUD.DUD_STATUS <> '9' "
			cQuery += " AND DUD.D_E_L_E_T_ = ' ' "
			cQuery += " AND DT6.DT6_FILIAL = '"+xFilial("DT6") + "'"
			cQuery += " AND DT6.DT6_FILDOC = DUD.DUD_FILDOC"
			cQuery += " AND DT6.DT6_DOC = DUD.DUD_DOC"
			cQuery += " AND DT6.DT6_SERIE = DUD.DUD_SERIE"
			cQuery += " AND DT6.D_E_L_E_T_ = ' ' "
			cQuery += " AND DT5.DT5_FILIAL = '"+xFilial("DT5") + "'"
			cQuery += " AND DT5.DT5_FILDOC = DT6.DT6_FILDOC"
			cQuery += " AND DT5.DT5_DOC = DT6.DT6_DOC"
			cQuery += " AND DT5.DT5_SERIE = DT6.DT6_SERIE"
			cQuery += " AND DT5.D_E_L_E_T_ = ' ' "  
			cQuery += " AND DUE.DUE_FILIAL = '"+xFilial("DUE")+"'""
			cQuery += " AND DUE.DUE_CODSOL = DT5_CODSOL "
			cQuery += " AND DUE.D_E_L_E_T_ = ' ' "  
			cQuery += " AND SA1R.A1_FILIAL = '"+xFilial("SA1")+"'"
			cQuery += " AND SA1R.A1_COD    = DUE_CODCLI "
			cQuery += " AND SA1R.A1_LOJA   = DUE_LOJCLI "    
			cQuery += " AND SA1R.A1_TIPO <> 'X' "
			cQuery += " AND SA1R.D_E_L_E_T_ = ' ' "  
			cQuery += " AND SA1D.A1_FILIAL = '"+xFilial("SA1")+"'"  
			cQuery += " AND SA1D.A1_COD    = DT5_CLIDES "
			cQuery += " AND SA1D.A1_LOJA   = DT5_LOJDES " 
			cQuery += " AND SA1D.A1_TIPO   <> 'X' " 
			cQuery += " AND SA1D.D_E_L_E_T_ = ' '    
			cQuery += " ORDER BY DUD_DOC, DUD_SERIE
			cQuery := ChangeQuery(cQuery)
			
			cAliasDOC := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDOC,.F.,.T.) 
			  
		Else//Viagens de Transferencia e Entrega
				
			//Somatoria do Peso da viagem      
			cQuery := " SELECT SUM(DT6_PESO) PESO "
			cQuery += "   FROM " + RetSqlName("DUD") + " DUD, "
			cQuery +=              RetSqlName("DT6") + " DT6, "
			cQuery +=              RetSqlName("SA1") + " SA1R, "
			cQuery +=              RetSqlName("SA1") + " SA1D, "
			cQuery += " WHERE DUD.DUD_FILIAL = '" + xFilial("DUD")+"'"
			cQuery += " AND DUD.DUD_FILORI = '" + cFilOri+"'"
			cQuery += " AND DUD.DUD_VIAGEM = '" + cViagem+"'"
			cQuery += " AND DUD.DUD_STATUS <> '9' "
			cQuery += " AND DUD.D_E_L_E_T_ = ' ' "
			cQuery += " AND DT6.DT6_FILIAL = '" + xFilial("DT6") + "'"
			cQuery += " AND DT6.DT6_FILDOC = DUD.DUD_FILDOC"
			cQuery += " AND DT6.DT6_DOC = DUD.DUD_DOC"
			cQuery += " AND DT6.DT6_SERIE = DUD.DUD_SERIE"
			cQuery += " AND DT6.D_E_L_E_T_ = ' ' "
			cQuery += " AND SA1R.A1_FILIAL = '" + xFilial("SA1")+"'"  
			cQuery += " AND SA1R.A1_COD  = DT6.DT6_CLIREM "
			cQuery += " AND SA1R.A1_LOJA = DT6.DT6_LOJREM "  
			cQuery += " AND SA1R.A1_TIPO <> 'X' "
			cQuery += " AND SA1R.D_E_L_E_T_ = ' ' "   
			cQuery += " AND SA1D.A1_FILIAL = '" + xFilial("SA1")+"'"  
			cQuery += " AND SA1D.A1_COD    = DT6.DT6_CLIDES "
			cQuery += " AND SA1D.A1_LOJA   = DT6.DT6_LOJDES "  
			cQuery += " AND SA1D.A1_TIPO <> 'X' "
			cQuery += " AND SA1D.D_E_L_E_T_ = ' ' "    
			cQuery := ChangeQuery(cQuery)
			
			cAliasDT6 := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDT6,.F.,.T.)
			
			cPesoVge := Iif( (cAliasDT6)->PESO == 0, '1',  AllTrim(TransForm( (cAliasDT6)->PESO, PesqPict('DT6','DT6_VALFRE'))) )
			cPesoVge := StrTran(cPesoVge, '.','')
			cPesoVge := StrTran(cPesoVge, ',','.')  
			(cAliasDT6)->(DbCloseArea())

			//Quantidade de documentos da viagem
		    //	nQtdDoc:= PamQtDocVg(cFilOri,cViagem,DTQ->DTQ_SERTMS)	
			
			//Seleciona os documentos da viagem
			cQuery := " SELECT DUD_FILDOC, DUD_DOC, DUD_SERIE, DT6_QTDVOL, SA1R.A1_PESSOA PESSOAREM, SA1R.A1_EST ESTREM, SA1R.A1_COD_MUN COD_MUNREM, "
			cQuery += " SA1R.A1_CGC CGCREM, SA1R.A1_NOME NOMEREM, SA1R.A1_END ENDEREM, SA1R.A1_BAIRRO BAIRROREM , SA1R.A1_CEP CEPREM,"
			cQuery += " SA1D.A1_PESSOA PESSOADES, SA1D.A1_EST ESTDES, SA1D.A1_COD_MUN COD_MUNDES, SA1D.A1_CGC CGCDES, SA1D.A1_NOME NOMEDES, "
			cQuery += " SA1D.A1_END ENDDES, SA1D.A1_BAIRRO BAIRRODES, SA1D.A1_CEP CEPDES, DT6_VALFRE "
			cQuery += " FROM " + RetSqlName("DUD") + " DUD, "
			cQuery +=            RetSqlName("DT6") + " DT6, "
			cQuery +=            RetSqlName("SA1") + " SA1R, "
			cQuery +=            RetSqlName("SA1") + " SA1D "
			cQuery += " WHERE DUD.DUD_FILIAL = '"+xFilial("DUD")+"'"
			cQuery += " AND DUD.DUD_FILORI = '"+cFilOri+"'"
			cQuery += " AND DUD.DUD_VIAGEM = '"+cViagem+"'"
			cQuery += " AND DUD.DUD_STATUS <> '9' "
			cQuery += " AND DUD.D_E_L_E_T_ = ' ' "
			cQuery += " AND DT6.DT6_FILIAL = '"+xFilial("DT6") + "'"
			cQuery += " AND DT6.DT6_FILDOC = DUD.DUD_FILDOC"
			cQuery += " AND DT6.DT6_DOC = DUD.DUD_DOC"
			cQuery += " AND DT6.DT6_SERIE = DUD.DUD_SERIE"
			cQuery += " AND DT6.D_E_L_E_T_ = ' ' "
			cQuery += " AND SA1R.A1_FILIAL = '"+xFilial("SA1")+"'"
			cQuery += " AND SA1R.A1_COD    = DT6.DT6_CLIREM "
			cQuery += " AND SA1R.A1_LOJA   = DT6.DT6_LOJREM "    
			cQuery += " AND SA1R.A1_TIPO <> 'X' "
			cQuery += " AND SA1R.D_E_L_E_T_ = ' ' "  
			cQuery += " AND SA1D.A1_FILIAL = '"+xFilial("SA1")+"'"  
			cQuery += " AND SA1D.A1_COD    = DT6.DT6_CLIDES "
			cQuery += " AND SA1D.A1_LOJA   = DT6.DT6_LOJDES " 
			cQuery += " AND SA1D.A1_TIPO   <> 'X' " 
			cQuery += " AND SA1D.D_E_L_E_T_ = ' '    
			cQuery += " ORDER BY DUD_DOC, DUD_SERIE
			cQuery := ChangeQuery(cQuery)
			
			cAliasDOC := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDOC,.F.,.T.) 
		EndIf		
		
		AAdd (aFields,{'viagem.carga.peso', cPesoVge })  //Peso da viagem
		AAdd (aFields,{'viagem.documento.qtde', Iif(nQtdDoc == 0, '1', AllTrim(Str(nQtdDoc)) )})//Quantidade de doctos.   
			
		If nQtdDoc > 0  
			(cAliasDOC)->(dbGoTop()) 

			nCont := 0
			While (cAliasDOC)->(!Eof())
		
				nCont++
						
				AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.tipo', cTipDoc})//Se Coleta = 11 -ordem de coleta  se transferencia ou entrega = 5=conhecimento
				AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.numero',  AllTrim((cAliasDOC)->DUD_FILDOC)+"-"+AllTrim((cAliasDOC)->DUD_DOC)})
				AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.serie', AllTrim((cAliasDOC)->DUD_SERIE)})
				AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.quantidade', AllTrim(cValToChar((cAliasDOC)->DT6_QTDVOL))})
					
				//Informacoes do Remetente
				cTpPessoa := Iif((cAliasDOC)->PESSOAREM=="F", '2', '1')
		  		cCodMun   := TMS120CDUF((cAliasDOC)->ESTREM, '1') + AllTrim((cAliasDOC)->COD_MUNREM)
				AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal.qtde', '2'})
				AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.tipo', '1'})
				AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.documento.tipo', AllTrim(cTpPessoa)})
				AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.documento.numero', AllTrim((cAliasDOC)->CGCREM)})
				AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.nome', SubStr(AllTrim((cAliasDOC)->NOMEREM),1,40)})
				AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.endereco.logradouro', SubStr(AllTrim((cAliasDOC)->ENDEREM),1,40)})
				AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.endereco.numero', '01'})
				AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.endereco.bairro', Substr(AllTrim((cAliasDOC)->BAIRROREM),1,30) })
				AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.endereco.cidade.ibge', AllTrim(cCodMun)})
				AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.endereco.cep', AllTrim((cAliasDOC)->CEPREM)})
							
				//Informacoes do Destinatario  
				cTpPessoa := Iif((cAliasDOC)->PESSOADES=="F", '2', '1')
				cCodMun   := 	TMS120CDUF((cAliasDOC)->ESTDES, '1') + AllTrim((cAliasDOC)->COD_MUNDES)
				AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.tipo', '2'})
				AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.documento.tipo', AllTrim(cTpPessoa) })
				AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.documento.numero', AllTrim((cAliasDOC)->CGCDES)})
				AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.nome', SubStr(AllTrim((cAliasDOC)->NOMEDES),1,40) })
				AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.endereco.logradouro', SubStr(AllTrim((cAliasDOC)->ENDDES),1,40) })
				AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.endereco.numero', '01'})
				AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.endereco.bairro', SubStr(AllTrim((cAliasDOC)->BAIRRODES),1,40) })
				AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.endereco.cidade.ibge', AllTrim(cCodMun)})
				AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.endereco.cep', AllTrim((cAliasDOC)->CEPDES)})
			
				//Documentos da Viagem para ser utilizados na Tag Lotação 
				If lLotacao
					AAdd (aDocVgeLot, {(cAliasDOC)->DUD_FILDOC, (cAliasDOC)->DUD_DOC, (cAliasDOC)->DUD_SERIE, (cAliasDOC)->DT6_VALFRE })
				EndIf	

				(cAliasDOC)->(DbSkip())
			EndDo 
		Else   //Viagem vazia ou viagem sem informacao dos documentos.
			nCont := 1
			AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.tipo', '5'})
			AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.numero',  'Nao Declarado'}) 
				
			//Informacoes da Transportadora
			cCodMun   := AllTrim(SM0->M0_CODMUN)
			AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal.qtde', '2'})
			AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.tipo', '1'})
			AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.documento.tipo', '1'})
			AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.documento.numero', AllTrim(SM0->M0_CGC)})
			AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.nome', SubStr(AllTrim(SM0->M0_NOMECOM),1,40)})
			AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.endereco.logradouro', SubStr(AllTrim(SM0->M0_ENDCOB),1,40)})
			AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.endereco.numero', '01'})
			AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.endereco.bairro', Substr(AllTrim(SM0->M0_BAIRCOB),1,30) })
			AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.endereco.cidade.ibge', AllTrim(cCodMun)})
			AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.endereco.cep', AllTrim(SM0->M0_CEPCOB)})
						
			AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.tipo', '2'})
			AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.documento.tipo', '1' })
			AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.documento.numero', AllTrim(SM0->M0_CGC)})
			AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.nome', SubStr(AllTrim(SM0->M0_NOMECOM),1,40) })
			AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.endereco.logradouro', SubStr(AllTrim(SM0->M0_ENDCOB),1,40) })
			AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.endereco.numero', '01'})
			AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.endereco.bairro', SubStr(AllTrim(SM0->M0_BAIRCOB),1,40) })
			AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.endereco.cidade.ibge', AllTrim(cCodMun)})
			AAdd (aFields,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.endereco.cep', AllTrim(SM0->M0_CEPCOB)})
		EndIf	
		(cAliasDOC)->(DbCloseArea()) 
				
		DTR->(dbGoTo(nRecDTR))
		nAdiFre := PamAdiFre(cFilOri, cViagem, DTR->DTR_CODVEI, .F. )
			
		cIdOpe:= DUP->DUP_IDOPE
		nQtdSaq:= DUP->DUP_QTDSAQ
		nQtdTra:= DUP->DUP_QTDTRA

		If lDTRQtdSaq 
			cIdOpe := TMSIDPAM(DTR->DTR_FILORI,DTR->DTR_VIAGEM,'2')  //Tipo Parcela do Pagamento da Viagem
			If DTR->DTR_QTDSAQ > 0 .And.  DTR->DTR_QTDTRA > 0  //Tratamento caso os campos criados recentemente estejam com conteudo vazio
				nQtdSaq:= DTR->DTR_QTDSAQ
				nQtdTra:= DTR->DTR_QTDTRA
			EndIf	
		EndIf
		
		cCodBan		:= PamCodBan(DUP->DUP_CODMOT, cIdOpe,cFilOri, cViagem)
		If nAdiFre > 0 
			nTxAdBan	:= PamTaxTot(cCodBan, nQtdSaq, nQtdTra)
		EndIf
				
		//-- Quando tem taxa de banco, divide adiantamento da taxa de banco
		If lCIOTPerio .And. !Empty(nTxAdBan) .And. !Empty(nAdiFre) .And. lDTRAbast .And. DTR->DTR_VLABST > 0
			AAdd (aFields,{'viagem.parcela.qtde', '3'})
		ElseIf (lDTRAbast .And. DTR->DTR_VLABST > 0) .Or. (lCIOTPerio .And. !Empty(nTxAdBan) .And. !Empty(nAdiFre))
			AAdd (aFields,{'viagem.parcela.qtde', '2'})
		Else
			AAdd (aFields,{'viagem.parcela.qtde', '1'})
		EndIf
		
		AAdd (aFields,{'viagem.parcela1.efetivacao.tipo', '2'})//Efetivacao automatica
		
		If !lCIOTPerio
			nAdiFre += nTxAdBan
		EndIf
		
		If nAdiFre + nTxAdBan == 0
			If lLotacao   //Valor do Frete a Receber (DT6_VALFRE). Se o valor zerado , será enviado o valor de R# 1.00
				AAdd (aFields,{'viagem.parcela1.valor', Iif(aDocVgeLot[Len(aDocVgeLot)][4] > 0,  StrTran( AllTrim(TransForm( aDocVgeLot[Len(aDocVgeLot)][4]  , '@E 999999999.99')), ',','.' ), '1.00') }) 
			Else
				AAdd (aFields,{'viagem.parcela1.valor', '1.00'}) //Informar o Valor de R$ 1.00 - Normalmente para viagem que tera contrato por periodo, esse valor eh necessario para que o sistema Pamcard nao finaize a viagem.
			EndIf	
		ElseIf !Empty(nAdiFre)
			AAdd (aFields,{'viagem.parcela1.valor', StrTran( AllTrim(TransForm( nAdiFre , '@E 999999999.99')), ',','.' )})
		ElseIf !Empty(nTxAdBan)
			AAdd (aFields,{'viagem.parcela1.valor', StrTran( AllTrim(TransForm( nTxAdBan , '@E 999999999.99')), ',','.' )})
		EndIf
			
		If FindFunction('TmsFavPar')
			cTipFav := TmsFavPar(aForPag,lExistFav,nQtdFav,"1") //Adiantamento
		Else
			If nQtdFav > 1
				cTipFav := '2'
			Else
				cTipFav := '1'
			EndIf
		EndIf
			
		AAdd (aFields,{'viagem.parcela1.subtipo', '1'}) //1=Adiantamento
		AAdd (aFields,{'viagem.parcela1.status.id', '1'})//Pendente
		AAdd (aFields,{'viagem.parcela1.data', SubStr(DtoS(dDataBase),7,2) + '/' + SubStr(DtoS(dDataBase),5,2) + '/' + SubStr(DtoS(dDataBase),1,4)})
		AAdd (aFields,{'viagem.parcela1.favorecido.tipo.id', cTipFav })//Se existir favorecido manda a parcela para o subcontratante.
		AAdd (aFields,{'viagem.parcela1.numero.cliente', cParAdi})//Adiantamento
		//-- Quando tem taxa de banco, divide adiantamento da taxa de banco
		If lCIOTPerio .And. !Empty(nTxAdBan) .And. !Empty(nAdiFre)
			AAdd (aFields,{'viagem.parcela2.efetivacao.tipo', '2'})//Efetivacao automatica
			AAdd (aFields,{'viagem.parcela2.valor', StrTran( AllTrim(TransForm( nTxAdBan , '@E 999999999.99')), ',','.' )})
			AAdd (aFields,{'viagem.parcela2.subtipo', '1'}) //1=Adiantamento
			AAdd (aFields,{'viagem.parcela2.status.id', '1'})//Pendente
			AAdd (aFields,{'viagem.parcela2.data', SubStr(DtoS(dDataBase),7,2) + '/' + SubStr(DtoS(dDataBase),5,2) + '/' + SubStr(DtoS(dDataBase),1,4)})
			AAdd (aFields,{'viagem.parcela2.favorecido.tipo.id', cTipFav })//Se existir favorecido manda a parcela para o subcontratante.
			AAdd (aFields,{'viagem.parcela2.numero.cliente', cParTaxa})//Taxa 
			cQtdParce := '3'
		EndIf

		If lDTRAbast  //Trecho para a geração da TAG de abastecimento
			If DTR->DTR_VLABST > 0 
				AAdd (aFields,{'viagem.parcela'+cQtdParce+'.efetivacao.tipo', '2'})
				AAdd (aFields,{'viagem.parcela'+cQtdParce+'.valor', StrTran(AllTrim(TransForm(DTR->DTR_VLABST, '@E 999999999.99')), ',','.' )})
				AAdd (aFields,{'viagem.parcela'+cQtdParce+'.subtipo', '5'})
				AAdd (aFields,{'viagem.parcela'+cQtdParce+'.base', 'S'})
				AAdd (aFields,{'viagem.parcela'+cQtdParce+'.status.id', '1'}) // 1-Pendente/ 2-Liberada
				AAdd (aFields,{'viagem.parcela'+cQtdParce+'.data', SubStr(DtoS(dDataBase),7,2) + '/' + SubStr(DtoS(dDataBase),5,2) + '/' + SubStr(DtoS(dDataBase),1,4)})
				AAdd (aFields,{'viagem.parcela'+cQtdParce+'.favorecido.tipo.id', '1'})
				AAdd (aFields,{'viagem.parcela'+cQtdParce+'.numero.cliente', '3'})
			EndIf
		EndIf

		nAdiFre := PamAdiFre(cFilOri, cViagem, DTR->DTR_CODVEI, .F. )
		If nAdiFre > 0 //Existe Adiantamento de Frete
			AAdd (aFields,{'viagem.frete.valor.bruto', StrTran( AllTrim(TransForm( nAdiFre, '@E 999999999.99')), ',','.' )})
		Else //Informar o Valor de R$ 1.00
			If lLotacao   //Valor do Frete a Recebert (DT6_VALFRE). Se o valor zerado , será enviado o valor de R# 1.00
				AAdd (aFields,{'viagem.frete.valor.bruto', Iif(aDocVgeLot[Len(aDocVgeLot)][4]  > 0,  StrTran( AllTrim(TransForm( aDocVgeLot[Len(aDocVgeLot)][4]  , '@E 999999999.99')), ',','.' ), '1.00') }) 
			Else
				AAdd (aFields,{'viagem.frete.valor.bruto', '1.00'})
			EndIf	
		EndIf
			
		If !Empty(cCodBan) .And. nAdiFre > 0 
		
			nQtdTaf := nQtdSaq + nQtdTra
			aTaxBan := PamTaxBan(cCodBan, nQtdSaq, nQtdTra)	
			If !Empty(aTaxBan)
				AAdd (aFields,{'viagem.frete.item.qtde', AllTrim(Str(Len(aTaxBan)))})
				For nCount := 1 to Len(aTaxBan)
					//aTaxBan[1] DJB_CODBAN
					//aTaxBan[2] DJB_TARIFA
					//aTaxBan[3] DJB_CODTAF
					//aTaxBan[4] VALOR
					//aTaxBan[5] QTDTARIFA
					AAdd (aFields,{'viagem.frete.item'+cValToChar(nCount)+'.tipo', aTaxBan[nCount][3]  })
					AAdd (aFields,{'viagem.frete.item'+cValToChar(nCount)+'.tarifa.quantidade', AllTrim(Str(aTaxBan[nCount][5])) })
					AAdd (aFields,{'viagem.frete.item'+cValToChar(nCount)+'.valor', StrTran( AllTrim(TransForm(aTaxBan[nCount][4], '@E 999999999.99')), ',','.' )})
				Next nCount
			EndIf
		Else
			AAdd (aFields,{'viagem.frete.item.qtde', '0'})
		EndIf
	
		If lLotacao .And. lFrotaProp
			AAdd (aFields,{'viagem.veiculo.altodesempenho.indicador'    , 'S' })       
			AAdd (aFields,{'viagem.carga.destinacaocomercial.indicador' , 'S' })       

			If DTQ->DTQ_SERTMS <> StrZero(2,Len(DTQ->DTQ_SERTMS)) .And. !lUltDest //--Se não for considerado o ultimo documento da viagem , a origem e destino será a Filial...
				lPagaRet:= .T.
			EndIf

			AAdd (aFields,{'viagem.retorno.frete.indicador', Iif(lPagaRet,'S','N') })   
			If lPagaRet
				If ExistFunc('TMSCEOrDes') .And. Len(aCEPeDist:= TMSCEOrDes(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,DTQ->DTQ_SERTMS, DTQ->DTQ_ROTA, aDocVgeLot, .T. )) > 0
					If Len(aCEPeDist) > 1
						cCepRet := aCEPeDist[2]
						nKMRet  := Iif(Len(aCEPeDist)>2,aCEPeDist[3],0)
						nKMRet  := Iif(!lUltDest,(nKMRet/2),nKMRet)
					EndIf
				EndIf		
				AAdd (aFields,{'viagem.retorno.cep'          , cCepRet  })                     
				AAdd (aFields,{'viagem.retorno.distancia.km' , cValToChar(nKMRet) })   
			EndIf

			AAdd (aFields,{'viagem.ciot.emissor.cliente.documento.tipo'   , '1' })   //1-CNPJ  
			AAdd (aFields,{'viagem.ciot.emissor.cliente.documento.numero' , SM0->M0_CGC  })   
			AAdd (aFields,{'viagem.ciot.emissor.cliente.nome'             , SubStr(AllTrim(SM0->M0_NOMECOM),1,60) })   
			AAdd (aFields,{'viagem.ciot.emissor.cliente.rntrc'            , SM0->M0_RNTRC })   	       
			AAdd (aFields,{'viagem.contratacao.tipo'                      , '1' })   //1-Carga Lotacao
		EndIf	
		//---- Fim Lotação

		If	lDTRAbast 
			If cTpPessoa == '1' .And. DTR->DTR_VLABST > 0 
				AAdd(aFields, {'viagem.favorecido1.consumo.responsavel.nome'    ,AllTrim(DA4->DA4_NOME)} )
				AAdd(aFields, {'viagem.favorecido1.consumo.responsavel.cpf'	    ,AllTrim(DA4->DA4_CGC) } )
			EndIf
		EndIf

		If !Empty(DTQ->DTQ_IDCLI)
			cIdCli := AllTrim(DTQ->DTQ_IDCLI) 
		EndIf
				
		lRet := PamInsCont(aFields, @aRet, cIdCli) //Chamada da Função
		If lRet .And. nValPdg > 0 .And. lCIOTPerio
		//-- Para CIOT por período, o pedágio será gerado em viagem à parte na Pamcard, por limitações do sistema deles.
			lRet := PamIncViag(cFilOri, cViagem, aRetCNPJ, .T.)
		EndIf
				
		If lRet        
			DTR->(dbGoTo(nRecDTR))
			RecLock('DTR',.F.)
			DTR->DTR_CIOT   := aRet[1]  //Retorno do sistema Pamcard com o nr do CIOT - viagem.antt.ciot.numero		
			MsUnLock()
		
			DTQ->(dbGoTo(nRecDTQ))
			RecLock('DTQ',.F.)
			DTQ->DTQ_IDOPE  := aRet[2]  //Retorno do Sistema Pamcard  - viagem.id
			DTQ->DTQ_IDCLI := aRet[3]  //Retorno do Sistema Pamcard  - viagem.id.cliente
			MsUnLock()

			
			If TableInDic("DJL") .And. DTR->DTR_TPCIOT == '2'
				RecLock("DJL",.T.)
				DJL_FILIAL := xFilial("DJL")
				DJL_CIOT   := DTR->DTR_CIOT
				DJL_CODVEI := DTR->DTR_CODVEI
				DJL_DATINI := dDataBase
				DJL_DATFIM := DTR->DTR_DTFMCI
				DJL_DATFEC := CtoD('')
				DJL_STATUS := '1'
				DJL->(MsUnLock())
			EndIf
		EndIf
        //--------- Chamada do Paytoll somente para TAG
        If (nParcPedag := Ascan(aForPag, {|x|  x[2] == '3'})) > 0 //Se existir parcela de pedágio
			lTagPedag  := Alltrim(aForPag[nParcPedag,1]) == '3' //Pagamento pedagio 3-TAG
		EndIf
		If lRet .And. nValPdg > 0 .And. lTagPedag
            lRet:= PamPayToll(DTQ->DTQ_IDOPE,DTQ->DTQ_IDCLI,DTR->DTR_CIOT)
			If !lRet
				lRet := ExcVgePam( .T., lFrotaProp, lLotacao, cFilOri, cViagem, aRetCNPJ, DTR->DTR_CIOT, lPayToll )
				If lRet
					lRet := .F.  // Viagem excluida da PAMCARD devido a nao execucao do metodo PayToll
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaDTR)
RestArea(aAreaDUP)
RestArea(aAreaDA3)
RestArea(aAreaSA2)
RestArea(aAreaDTQ)
RestArea(aAreaDA4)
RestArea(aAreaDEL)

FwFreeObj(aRet	 	)
FwFreeObj(aFields	)
FwFreeObj(aAreaDTR	)
FwFreeObj(aAreaDUP	)
FwFreeObj(aAreaDA3	)
FwFreeObj(aAreaSA2	)
FwFreeObj(aAreaDTQ	)
FwFreeObj(aAreaDA4	)
FwFreeObj(aAreaDEL	)
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamLibPaAd ³ Autor:³ Gilson da Silva        ³ Data:³08/02/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Libera Parcela do adiantamento do contrato no sistema Pamcard.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ExpC1 = Filial Origem da Viagem                               ³±±
±±³           ³ExpC2 = Numero da Viagem                                      ³±±
±±³           ³ExpA1 = Dados da Transportadora                               ³±±
±±³           ³ExpN1 = Valor do Adiantamento                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamLibPaAd(ExpC1, ExpC2, ExpA1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ Apto Operação de Saida da viagem Frota Terceiro/Agregado.    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamLibPaAd(cFilOri, cViagem, aRetCNPJ, lAbast)

Local cParAdi      := '1'
Local lRet         := .F.
Local aFields      := {}
Local aAreaDTR     := DTR->(GetArea())
Local aArea        := GetArea()
Local lCIOTPerio   := .F.
Local cParc        := '1'
Local nPosParc	   := 0
Local nRetParc	   := 0

Default cFilOri	   := ''
Default cViagem	   := ''
Default	aRetCNPJ   := aRetCNPJ
Default lAbast     := .F.
//Posiciona na tabela de Complementos da viagem.
DTR->(DbSetOrder(1))
DTR->(DbSeek(xFilial('DTR') + cFilOri + cViagem))

lCIOTPerio := DTR->(ColumnPos("DTR_TPCIOT")) > 0 .And. DTR->DTR_TPCIOT == "2"

//-- Quando utiliza CIOT por período, o id da parcela conterá o nro da viagem pois não pode ser duplicado na pamcard
If lCIOTPerio
	cParAdi := PamIdAdto(cFilOri, cViagem, DTR->DTR_CODVEI)
EndIf
If lAbast
	cParAdi := "3" // Para os casos de TAG de Abastecimento
EndIf
//--Traz parcelas não excluídas na PAMCARD
aParCTC := PamGetParc(cFilOri, cViagem, aRetCNPJ, DTQ->DTQ_IDOPE, 2)
If (nPosParc:= aScan(aParCTC, {|x| AllTrim(x[1]) == AllTrim(cParAdi)}) ) > 0
	cParc 	:= cValToChar(aParCTC[nPosParc][5])
	nRetParc:= Val(aParCTC[nPosParc][3])
EndIf

If nRetParc == 1 .Or. nRetParc == 3   //Parcela pendente ou bloqueada.
	aFields := {}
	AAdd (aFields,{'viagem.id', AllTrim(DTQ->DTQ_IDOPE) })
	AAdd (aFields,{'viagem.contratante.documento.numero',aRetCNPJ[1] } )
	AAdd (aFields,{'viagem.unidade.documento.tipo', aRetCNPJ[2] })
	AAdd (aFields,{'viagem.unidade.documento.numero', aRetCNPJ[3] } )
	AAdd (aFields,{'viagem.parcela.qtde', '1' })
	AAdd (aFields,{'viagem.parcela1.numero', cParc } )
	AAdd (aFields,{'viagem.parcela1.status.id', '2' } )
	AAdd (aFields,{'viagem.antt.ciot.numero', AllTrim(DTR->DTR_CIOT)} )

	lRet := PamAltStPa(aFields) //Chamada da Função
EndIf
	
RestArea(aAreaDTR)
RestArea(aArea)

FwFreeObj(aFields  )
FwFreeObj(aAreaDTR )
FwFreeObj(aArea	   )
Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamLibPaCt ³ Autor:³ Gilson da Silva        ³ Data:³17/01/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Inclui/Altera/libera valor da Parcela Saldo a Pagar e Impostos³±±
±±³			  ³no sistema Pamcard. 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ExpC1 = Filial Origem da Viagem                               ³±±
±±³           ³ExpC2 = Numero da Viagem                                      ³±±
±±³           ³ExpA1 = Dados da Transportadora                               ³±±
±±³           ³ExpC3 = Numero do Contrato                                    ³±±
±±³           ³ExpD1 = Data do Vencimento da Parcela			                 ³±±
±±³           ³ExpN1 = Valor da parcela a ser gerada na PAMCARD	           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamLibPaCt(ExpC1, ExpC2, ExpA1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ Apto Operação de Saida da viagem Frota Terceiro/Agregado,    ³±±
±±³		     ³ quando gerar o contrato de carreteiro apos apontar a saida   ³±±
±±³		     ³ da viagem, Na Liberação do Contrato.         			        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamLibPaCt(cFilOri, cViagem, aRetCNPJ, cContrat, dDtPgtSld, nVlBxE2)

Local lRet       := .T.
Local aFields    := {}
Local nValFre	 := 0
Local nVlrBru    := 0
Local nAdiFre    := 0 //--Adiantamento de Frete do Contrato.
Local nIRRF      := 0
Local nSEST      := 0
Local nINSS      := 0
Local nISS       := 0
Local nPIS       := 0
Local nCOFINS    := 0
Local nCSLL      := 0
Local nVLRDEB    := 0
Local nQtdImp    := 0
Local nRetParc   := 0

Local cDesIRRF   := GetMV('MV_PAMIRRF',,'1')
Local cDesINSS   := GetMV('MV_PAMINSS',,'2')
Local cDesSEST   := GetMV('MV_PAMSEST',,'3')
Local cDesDeb    := GetMV('MV_PAMDEB',,'41')
Local cDesISS    := GetMV('MV_PAMISS',,'61')
Local cDesPIS    := GetMV('MV_PAMPIS',,'62')
Local cDesCOFINS := GetMV('MV_PAMCOFI',,'63')
Local cDesCSLL   := GetMV('MV_PAMCSLL',,'241')

Local aAreaDTR   := DTR->(GetArea())
Local aAreaSA2   := SA2->(GetArea())
Local aArea      := GetArea()

Local cPrefixo   := TMA250GerPrf(cFilAnt)
Local cQuery 	 := ''
Local aAreaDTY   := DTY->(GetArea())
Local aAreaSE2   := SE2->(GetArea())   
Local cTipCTC    := Padr( GetMV("MV_TPTCTC"), Len( SE2->E2_TIPO ) )    // Tipo Contrato de Carreteiro
Local cParAdi	 := '1'
Local cParCTC	 := ''
Local nParCTC	 := 1
Local cStatus    := '2' //--1=Pendente;2=Liberada
Local cNumCli	 := '1'                                   
Local cSubTipo   := Iif(DTY->DTY_TIPCTC <> '5','3','2')
Local cParDTY	 := '1'
Local cFavId	 := ''//1=Proprietario;2=SubContrante
Local aCodFav	 := {}
Local lExistFav  := .F.
Local nCount	 := 0
Local cCodBan	 := ""
Local ntxAdBan	 := 0
Local aTaxBan	 := {}
Local lCIOTPerio := .F.
Local nSumParcel := 0
Local nAdiFreVia := 0 //--Valor do adiantamento de Frete da viagem do contrato. Difere do nAdiFre, tendo em vista que os contratos complementares não possuem adiantamentos. Sendo assim a viagem terá adiantamento, porém o contrato não.
Local nPosFav	 := 0
Local aForPag	 := {} 
Local aFav		 := {}
Local lExpMot	 := .F.
Local lTabDLD    := TableInDic('DLD')
Local cIdOpe     := ""
Local nQtdSaq    := 0
Local nQtdTra    := 0
Local lDTRQtdSaq := DTR->(ColumnPos("DTR_QTDSAQ")) > 0 

Default cContrat := ''
Default dDtPgtSld:= dDataBase
Default nVlBxE2  := 0

//Posiciona na tabela de Complementos da viagem.
DTR->(DbSetOrder(1))
DTR->(DbSeek(xFilial('DTR') + cFilOri + cViagem))   
nAdiFreVia := PamAdiFre(cFilOri, cViagem, DTR->DTR_CODVEI, .T.)

lCIOTPerio := DTR->(ColumnPos("DTR_TPCIOT")) > 0 .And. DTR->DTR_TPCIOT == "2"

//-- Quando utiliza CIOT por período, o id da parcela conterá o nro da viagem pois não pode ser duplicado na pamcard
If lCIOTPerio
	cParAdi := PamIdAdto(cFilOri, cViagem, DTR->DTR_CODVEI)
EndIf

//Posiciona na tabela de Fornecedores
SA2->(dbSetOrder(1))
SA2->(DbSeek(xFilial("SA2")+DTR->DTR_CODFOR+DTR->DTR_LOJFOR))

If Substr(FunName(),1,7) == "TMSA251"
	//--Obtem o 1.o Vencimento do titulo para passar essa informação ao sistema Pamcard como data para efetivacao do pagamento
	aVenctos := Condicao( DTY->DTY_VALFRE, SA2->A2_COND,, dDataBase )
	If Len(aVenctos) > 0
		dDtPgtSld := aVenctos[1,1]
	EndIf	
EndIf

PamValTot(1,cFilOri, cViagem, cContrat,@nVlrBru,@nIRRF,@nSEST,@nINSS,@nISS,@nPIS,@nCOFINS,@nCSLL,@nAdiFre )

If DTY->DTY_TIPCTC <> "5" // /Não for complemento.
    nVLRDEB := PamDebVge(cFilOri, cViagem, DTR->DTR_CODVEI)
EndIf
nValFre := (nVlrBru - (nAdiFre + nIRRF + nSEST + nINSS + nISS + nPIS + nCOFINS + nCSLL + nVLRDEB ) ) //--Valor da Parcela

//-- Se houve baixa parcial do título fora da operadora, desconta o valor já baixado da(s) parcela(s)
If !Empty(nVlBxE2)
	//-- Se a parcela é maior que o valor já pago, desconta o valor da parcela
	If nValFre > nVlBxE2
		nValFre -= nVlBxE2
		nVlBxE2 := 0
	//-- Se a parcela for menor ou igual ao valor já pago, não desconta o valor da parcela da variável para que a próxima parcela compense o restante já baixado
	Else
		nVlBxE2 -= nValFre //-- Desconta o valor da parcela da variável nVlBxE2 (passada por referência, com o "@") e retorna .T. para ler o próximo DTY e, próxima parcela.
		Return .T.
	EndIf
EndIf

//Busca o valor Bruto de todas as vianges ref. ao contato complementar.
If cSubTipo == '2'
	PamValTot(2,cFilOri, cViagem, cContrat,@nVlrBru)
EndIf

If Empty(cTipCTC)
	cTipCTC := Padr( "C"+cFilAnt, Len( SE2->E2_TIPO ) ) // Tipo Contrato de Carreteiro
EndIf

DTQ->(dbSetOrder(2))
DTQ->(dbSeek(xFilial('DTQ')+cFilOri+cViagem))
                           
cParDTY := StrZero(Len(PamGetParc(cFilOri, cViagem, aRetCNPJ, DTQ->DTQ_IDOPE)) + 1 ,2)

If cParDTY == '01' //--Não encontrou parcela na Pamcard.
	Return .F.
EndIf

aFields := {}
AAdd (aFields,{'viagem.contratante.documento.numero',aRetCNPJ[1]} )
AAdd (aFields,{'viagem.unidade.documento.tipo', aRetCNPJ[2] })
AAdd (aFields,{'viagem.unidade.documento.numero', aRetCNPJ[3]} )
AAdd (aFields,{'viagem.id', AllTrim(DTQ->DTQ_IDOPE)})
AAdd (aFields,{'viagem.antt.ciot.numero', AllTrim(DTR->DTR_CIOT)} )

//--Usa o E2_IDCNAB quando a parcela for gerada a partir da liberação de contrato
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seleciona o IDCNAB do contrato no SE2³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNumCli := PamRetIDPa(cPrefixo, cTipCTC, cFilOri, cContrat)

//--Traz parcelas não excluídas na PAMCARD
aParCTC := PamGetParc(cFilOri, cViagem, aRetCNPJ, DTQ->DTQ_IDOPE, 2)

If lTabDLD .And. FindFunction('TmsForPag')	
	//Formas de Pagamento da viagem
	aForPag 	:= TmsForPag(cFilOri,cViagem)
	lExpMot 	:= Ascan(aForPag, {|x|  x[3] == '2'}) > 0
	lExistFav 	:= Ascan(aForPag, {|x|  !Empty(x[5]) }) > 0
	
	If lExistFav
		nPosFav := Ascan(aForPag, {|x|  !Empty(x[5]) })
		aCodFav := {aForPag[nPosFav][5],aForPag[nPosFav][6]}
	Endif
	
	aFav := PamQtdFav(lExistFav,lExpMot,aForPag)
Else
	aCodFav := T250BscFav(DTR->DTR_CODVEI,DA3->DA3_CODFOR,DA3->DA3_LOJFOR,DTR->DTR_FILORI,DTR->DTR_VIAGEM)	// retorna o codigo do Favorecido 
	If Len(aCodFav) > 0
		lExistFav := .T.
	EndIf	                                                                                                             
EndIf

AAdd (aFields,{'viagem.parcela.qtde', AllTrim(Str(Len(aParCTC)+1))})

If Len(aForPag) > 0
	cFavId := TmsFavPar(aForPag,lExistFav,Len(aFav),"2") //Saldo do frete
Else
	cFavId := PamRetFvId(cFilOri, cViagem, lExistFav)
EndIf
                                                                
cIdOpe  := DUP->DUP_IDOPE
nQtdSaq := DUP->DUP_QTDSAQ
nQtdTra := DUP->DUP_QTDTRA

If lDTRQtdSaq 
	cIdOpe := TMSIDPAM(DTR->DTR_FILORI,DTR->DTR_VIAGEM,'2')  //Tipo Parcela do Pagamento da Viagem
	If DTR->DTR_QTDSAQ > 0 .And.  DTR->DTR_QTDTRA > 0  //Tratamento caso os campos criados recentemente estejam com conteudo vazio
		nQtdSaq:= DTR->DTR_QTDSAQ
		nQtdTra:= DTR->DTR_QTDTRA
	EndIf	
EndIf
	                                                                
cCodBan	 := PamCodBan(DUP->DUP_CODMOT,cIdOpe, cFilOri, cViagem)
nTxAdBan := PamTaxTot(cCodBan, nQtdSaq, nQtdTra)

If (Substr(FunName(),1,6) == "TMSA25" .Or. FunName()=="TMSAF60") .And. nAdifre == 0 .And. nAdiFreVia == 0
	//Quando nao existe adiantameto no TMS, consulta a parcela de adiantamento no sistema Pamcard, pois no sistema Pamcard sempre ;
	//existirá uma parcela de adiantamento e se gerar um contrato no TMS e exclui-lo, exclui a parcela de adiantamento no sistema Pamcard.
	If lCIOTPerio .And. cParAdi == '1'
		nRetParc := PamConParc(cFilOri, cViagem, aRetCNPJ, cParAdi, , .F. )
	Else
		nRetParc := PamConParc(cFilOri, cViagem, aRetCNPJ, cParAdi ) //Chama a rotina que consulta a parcela da viagem de Adiantamento			
	EndIf	
	If nRetParc == 1 .Or. nRetParc == 2 //Existe a parcela de adiantamento e esta com o status pendente ou liberada.
		For nParCTC := 1 To Len(aParCTC)            
			cParCTC := AllTrim(Str(nParCTC))
			//Se na geracao do contrato de carreteiro nao existir adiantamento de Frete, zera o valor da primeira parcela que foi informado o valor de 1.00 no fechamento da viagem.
			If AllTrim(aParCTC[nParCTC,1]) == '1' 
				AAdd (aFields,{'viagem.parcela'+cParCTC+'.valor', IIF(nTxAdBan > 0, StrTran( AllTrim(TransForm( nTxAdBan, '@E 999999999.99')), ',','.' ), '0.00') })
				AAdd (aFields,{'viagem.parcela'+cParCTC+'.numero.cliente', cParAdi })//Adiantamento
			Else			                                                                
				AAdd (aFields,{'viagem.parcela'+cParCTC+'.valor', StrTran( AllTrim(TransForm( aParCTC[nParCTC,2], '@E 999999999.99')), ',','.' )})
				AAdd (aFields,{'viagem.parcela'+cParCTC+'.numero.cliente', AllTrim(aParCTC[nParCTC,1]) })//Parcela do Saldo a Pagar
				nSumParcel += aParCTC[nParCTC,2]
			EndIf	
		Next						
		cParCTC := AllTrim(Str(nParCTC))
		AAdd (aFields,{'viagem.parcela'+cParCTC+'.efetivacao.tipo', '2'})//Efetivacao automatica
		AAdd (aFields,{'viagem.parcela'+cParCTC+'.valor', StrTran( AllTrim(TransForm( nValFre, '@E 999999999.99')), ',','.' )})
		AAdd (aFields,{'viagem.parcela'+cParCTC+'.subtipo', cSubTipo}) //2=Intermediaria;3=Saldo Final
		AAdd (aFields,{'viagem.parcela'+cParCTC+'.status.id', cStatus })//Liberada
		AAdd (aFields,{'viagem.parcela'+cParCTC+'.data',SubStr(DtoS(dDtPgtSld),7,2) + '/' + SubStr(DtoS(dDtPgtSld),5,2) + '/' + SubStr(DtoS(dDtPgtSld),1,4) })
		AAdd (aFields,{'viagem.parcela'+cParCTC+'.favorecido.tipo.id', cFavId})//SubContrante, Contratado ou Motorista
		AAdd (aFields,{'viagem.parcela'+cParCTC+'.numero.cliente', cNumCli})//Saldo Final
		nSumParcel += nValFre	
	Else
		For nParCTC := 1 To Len(aParCTC)                                                                       		
			cParCTC := AllTrim(Str(nParCTC))		
			If AllTrim(aParCTC[nParCTC,1]) == '1' 			
				AAdd (aFields,{'viagem.parcela'+cParCTC+'.valor', IIF(nTxAdBan > 0, StrTran( AllTrim(TransForm( nTxAdBan, '@E 999999999.99')), ',','.' ), '0.00') })
				AAdd (aFields,{'viagem.parcela'+cParCTC+'.numero.cliente', '1'})//Adiantamento
			Else			                                                                
				AAdd (aFields,{'viagem.parcela'+cParCTC+'.valor', StrTran( AllTrim(TransForm( aParCTC[nParCTC,2], '@E 999999999.99')), ',','.' )})
				AAdd (aFields,{'viagem.parcela'+cParCTC+'.numero.cliente', AllTrim(aParCTC[nParCTC,1]) })//Parcela do Saldo a Pagar
				nSumParcel += aParCTC[nParCTC,2]
			EndIf	
		Next 
		cParCTC := AllTrim(Str(nParCTC))
		AAdd (aFields,{'viagem.parcela'+cParCTC+'.efetivacao.tipo', '2'})//Efetivacao automatica
		AAdd (aFields,{'viagem.parcela'+cParCTC+'.valor', StrTran( AllTrim(TransForm( nValFre, '@E 999999999.99')), ',','.' )})
		AAdd (aFields,{'viagem.parcela'+cParCTC+'.subtipo', cSubTipo}) //2=Intermediaria;3=Saldo Final
		AAdd (aFields,{'viagem.parcela'+cParCTC+'.status.id', cStatus })//Liberada
		AAdd (aFields,{'viagem.parcela'+cParCTC+'.data',SubStr(DtoS(dDtPgtSld),7,2) + '/' + SubStr(DtoS(dDtPgtSld),5,2) + '/' + SubStr(DtoS(dDtPgtSld),1,4) })
		AAdd (aFields,{'viagem.parcela'+cParCTC+'.favorecido.tipo.id', cFavId})//SubContrante, Contratado ou Motorista
		AAdd (aFields,{'viagem.parcela'+cParCTC+'.numero.cliente', cNumCli})//Saldo Final	
		nSumParcel += nValFre	
	EndIf
Else
   If (Substr(FunName(),1,6) == "TMSA25" .Or. FunName()=='TMSAF60')//Verifica se rotina é TMSA250,251 ou Viagem Mod.3 (browse)
		For nParCTC := 1 To Len(aParCTC)
			cParCTC := AllTrim(Str(nParCTC))		                                                                
			AAdd (aFields,{'viagem.parcela'+cParCTC+'.valor', StrTran( AllTrim(TransForm( aParCTC[nParCTC,2], '@E 999999999.99')), ',','.' )})
			AAdd (aFields,{'viagem.parcela'+cParCTC+'.numero.cliente', AllTrim(aParCTC[nParCTC,1]) })//Parcela do Saldo a Pagar
			nSumParcel += aParCTC[nParCTC,2]
		Next
	EndIf	
	cParCTC := AllTrim(Str(nParCTC))                                               
	AAdd (aFields,{'viagem.parcela'+cParCTC+'.efetivacao.tipo', '2'})//Efetivacao automatica
	AAdd (aFields,{'viagem.parcela'+cParCTC+'.valor', StrTran( AllTrim(TransForm( nValFre, '@E 999999999.99')), ',','.' )})
	AAdd (aFields,{'viagem.parcela'+cParCTC+'.subtipo', cSubTipo}) //2=Intermediaria;3=Saldo Final
	AAdd (aFields,{'viagem.parcela'+cParCTC+'.status.id', cStatus })//1=Pendente;2=Liberada
	AAdd (aFields,{'viagem.parcela'+cParCTC+'.data',SubStr(DtoS(dDtPgtSld),7,2) + '/' + SubStr(DtoS(dDtPgtSld),5,2) + '/' + SubStr(DtoS(dDtPgtSld),1,4) })
	AAdd (aFields,{'viagem.parcela'+cParCTC+'.favorecido.tipo.id', cFavId})//SubContrante, Contratado ou Motorista
	AAdd (aFields,{'viagem.parcela'+cParCTC+'.numero.cliente', cNumCli})//Saldo Final		
	nSumParcel += nValFre
	
	If !Empty(cCodBan) .And. (nQtdSaq + nQtdTra) > 0				
		aTaxBan := PamTaxBan(cCodBan, nQtdSaq, nQtdTra)	
			If !Empty(aTaxBan)
				AAdd (aFields,{'viagem.frete.item.qtde', AllTrim(Str(Len(aTaxBan)))})
				For nCount := 1 to Len(aTaxBan)
					//aTaxBan[1] DJB_CODBAN
					//aTaxBan[2] DJB_TARIFA
					//aTaxBan[3] DJB_CODTAF
					//aTaxBan[4] VALOR
					//aTaxBan[5] QTDTARIFA
					AAdd (aFields,{'viagem.frete.item'+cValToChar(nCount)+'.tipo', aTaxBan[nCount][3]  })
					AAdd (aFields,{'viagem.frete.item'+cValToChar(nCount)+'.tarifa.quantidade', AllTrim(Str(aTaxBan[nCount][5])) })
					AAdd (aFields,{'viagem.frete.item'+cValToChar(nCount)+'.valor', StrTran( AllTrim(TransForm(aTaxBan[nCount][4], '@E 999999999.99')), ',','.' )})
				Next nCount
			EndIf
		Else
			AAdd (aFields,{'viagem.frete.item.qtde', '0'})
		EndIf
	EndIf

//-- IMPORTANTE: qdo CIOT por período o valor bruto é o do CIOT e não do contrato que está liberando a parcela (DTY)
AAdd (aFields,{'viagem.frete.valor.bruto', StrTran( AllTrim(TransForm( Max(nVlrBru,nSumParcel), '@E 999999999.99')), ',','.' )})
	
If nIRRF > 0
	nQtdImp ++
EndIf

If nSEST > 0
	nQtdImp ++
EndIf

If nINSS > 0
	nQtdImp ++
EndIf

If nISS > 0
	nQtdImp ++
EndIf

If nPIS > 0
	nQtdImp ++
EndIf

If nCOFINS > 0
	nQtdImp ++
EndIf

If nCSLL > 0
	nQtdImp ++
EndIf

If nVLRDEB > 0
	nQtdImp ++
EndIf

If !Empty(cCodBan) .And.  (nQtdSaq + nQtdTra) > 0

	aTaxBan := PamTaxBan(cCodBan, nQtdSaq, nQtdTra)	
	If !Empty(aTaxBan)
		AAdd (aFields,{'viagem.frete.item.qtde', AllTrim(Str(Len(aTaxBan)+ nQtdImp))})
		For nCount := 1 to Len(aTaxBan)
			//aTaxBan[1] DJB_CODBAN
			//aTaxBan[2] DJB_TARIFA
			//aTaxBan[3] DJB_CODTAF
			//aTaxBan[4] VALOR
			//aTaxBan[5] QTDTARIFA
			AAdd (aFields,{'viagem.frete.item'+cValToChar(nCount)+'.tipo', aTaxBan[nCount][3]  })
			AAdd (aFields,{'viagem.frete.item'+cValToChar(nCount)+'.tarifa.quantidade', AllTrim(Str(aTaxBan[nCount][5])) })
			AAdd (aFields,{'viagem.frete.item'+cValToChar(nCount)+'.valor', StrTran( AllTrim(TransForm(aTaxBan[nCount][4], '@E 999999999.99')), ',','.' )})
		Next nCount
	Else
		AAdd (aFields,{'viagem.frete.item.qtde', cValToChar(nQtdImp)})//Qtde de Impostos	
	EndIf
Else
	AAdd (aFields,{'viagem.frete.item.qtde', cValToChar(nQtdImp)})//Qtde de Impostos
EndIf

If !Empty(aTaxBan)
	nQtdImp := Len(aTaxBan)
Else
	nQtdImp := 0
EndIf
If nIRRF > 0
	nQtdImp ++
	PamTagImp(cDesIRRF, @aFields, nQtdImp, nIRRF)
EndIf

If nINSS > 0
	nQtdImp ++
	PamTagImp(cDesINSS, @aFields, nQtdImp, nINSS)
EndIf

If nSEST > 0
	nQtdImp ++
	PamTagImp(cDesSEST, @aFields, nQtdImp, nSEST)
EndIf

If nVLRDEB > 0
	nQtdImp ++
	PamTagImp(cDesDeb, @aFields, nQtdImp, nVLRDEB)
EndIf

If nISS > 0
	nQtdImp ++
	PamTagImp(cDesISS, @aFields, nQtdImp, nISS)
EndIf

If nPIS > 0
	nQtdImp ++                                	
	PamTagImp(cDesPIS, @aFields, nQtdImp, nPIS)
EndIf                                        	

If nCOFINS > 0
	nQtdImp ++
	PamTagImp(cDesCOFINS, @aFields, nQtdImp, nCOFINS)
EndIf

If nCSLL > 0
	nQtdImp ++
	PamTagImp(cDesCSLL, @aFields, nQtdImp, nCSLL)
EndIf

If nVLRDEB > 0
	nQtdImp ++
	PamTagImp(cDesDeb, @aFields, nQtdImp, nCSLL)
EndIf

lRet := PamVlrParc(aFields) //Chamada da Função para Alterar o valor das parcelas do contrato de frete, metodo UpdateFreightContractValues.

If lRet .And. lDTYParCTC
	If Alltrim( Upper( TCGetDB() ) ) == 'ORACLE'
		DTY->( DbSetOrder(4) ) //DTY_FILIAL, DTY_FILORI, DTY_NUMCTC
		If DTY->( DbSeek( xFilial("DTY") + cFilOri + cContrat ) )
			
			While DTY->( DTY_FILIAL + DTY_FILORI + DTY_NUMCTC ) == xFilial("DTY") + cFilOri + cContrat
				
				RecLock( "DTY", .F. )
					DTY->DTY_PARCTC := cParDTY
				DTY->( MsUnLock() )

				DTY->( DbSkip() )
			EndDo

			lRet := .T.
		EndIf
	Else
		cQuery := " UPDATE " + RetSqlName("DTY") + " SET DTY_PARCTC = '"+cParDTY+"'"
		cQuery += " WHERE DTY_FILIAL = '" + xFilial("DTY")	+ "' "
		cQuery += "   AND DTY_FILORI = '" + cFilOri			+ "'"		
		cQuery += "   AND DTY_NUMCTC = '" + cContrat		+ "'" 	
		cQuery += "   AND D_E_L_E_T_ = ' ' "
		lRet := TCSqlExec( cQuery ) == 0
	EndIf
EndIf
If nTxAdBan > 0 .And. nAdifre == 0
	PamLibPaAd(cFilOri, cViagem, aRetCNPJ)
EndIf
RestArea(aAreaDTR)
RestArea(aAreaSA2)
RestArea(aAreaDTY)
RestArea(aAreaSE2)
RestArea(aArea)

FwFreeObj(aAreaDTR)
FwFreeObj(aAreaSA2)
FwFreeObj(aAreaDTY)
FwFreeObj(aAreaSE2)
FwFreeObj(aArea	 )
FwFreeObj(aFields)
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamEstPaCt ³ Autor:³ Gilson da Silva        ³ Data:³17/01/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Altera Status  da Parcela de Adto do contrato no Pamcard      ³±±
±±³			  ³de Liberada para Bloqueada. Ou Exclui a parcela de Pagto.Saldo³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ExpC1 = Filial Origem da Viagem                               ³±±
±±³           ³ExpC2 = Numero da Viagem                                      ³±±
±±³           ³ExpA1 = Dados da Transportadora                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamEstPaCt(ExpC1, ExpC2, ExpA1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³Estorno da operacao de saida viagem,frota terceiro e agregado.³±±
±±³		      ³Exclusao do contrato de frete.							   	     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamEstPaCt(cFilOri, cViagem, aRetCNPJ, cNumCtc, cIdParcela)
Local lRet       := .T.
Local aFields    := {}
Local nAdiFre    := 0
Local aAreaDTR   := DTR->(GetArea())
Local aAreaDTY   := DTY->(GetArea())
Local aAreaDTQ   := DTQ->(GetArea())
Local aArea      := GetArea()
Local nRet       := 0                             
Local cParAdi	 := '1'                                                 
Local aParCTC	 := {}
Local cParCTC 	 := '0'
Local nParCTC	 := 1              

//Somatoria dos valores do contrato original e complementar
Local nVlrBru    := 0
Local nIRRF      := 0
Local nSEST      := 0
Local nINSS      := 0
Local nISS       := 0
Local nPIS       := 0
Local nCOFINS    := 0
Local nCSLL      := 0  
Local nVLRDEB	 := 0
Local nQtdImp	 := 0 

Local cDesIRRF   := GetMV('MV_PAMIRRF',,'1')
Local cDesINSS   := GetMV('MV_PAMINSS',,'2')
Local cDesSEST   := GetMV('MV_PAMSEST',,'3')
Local cDesDeb    := GetMV('MV_PAMDEB',,'41')
Local cDesISS    := GetMV('MV_PAMISS',,'61')
Local cDesPIS    := GetMV('MV_PAMPIS',,'62')
Local cDesCOFINS := GetMV('MV_PAMCOFI',,'63')
Local cDesCSLL   := GetMV('MV_PAMCSLL',,'241')
Local lIncParAdi := .F.
Local lAtuVlr	 := .F. //Atualiza o Valor da Parcela. Usado para exclusão da parcela
Local lCIOTPerio := .F. 
Local cMsgRet	 := ''
Local cFavId	 := ''
Local cPrefixo   := TMA250GerPrf(cFilAnt)
Local cTipCTC    := Padr( GetMV("MV_TPTCTC"), Len( SE2->E2_TIPO ) )    // Tipo Contrato de Carreteiro
Local cAliasDTY  := ''

Default cNumCTc  	:= ''
Default cIdParcela	:= ''
//Posiciona na tabela de viagem.
DTQ->(DbSetOrder(2))
DTQ->(DbSeek(xFilial('DTQ') + cFilOri + cViagem))

//Posiciona na tabela de Complementos da viagem.
DTR->(DbSetOrder(1))
DTR->(DbSeek(xFilial('DTR') + cFilOri + cViagem))

lCIOTPerio := DTR->(ColumnPos("DTR_TPCIOT")) > 0 .And. DTR->DTR_TPCIOT == "2"

//-- Quando utiliza CIOT por período, o id da parcela conterá o nro da viagem pois não pode ser duplicado na pamcard
If lCIOTPerio
	cParAdi := PamIdAdto(cFilOri, cViagem, DTR->DTR_CODVEI)
EndIf
//Pegar os valores de frete, adiantamento e impostos do contrato original.
cAliasDTY := GetNextAlias()
cQuery := " SELECT SUM(DTY_VALFRE) DTY_VALFRE, SUM(DTY_IRRF) DTY_IRRF, SUM(DTY_INSS) DTY_INSS, SUM(DTY_SEST) DTY_SEST, SUM(DTY_ISS) DTY_ISS, " 
cQuery += " 	SUM(DTY_PIS) DTY_PIS, SUM(DTY_COFINS) DTY_COFINS, SUM(DTY_CSLL) DTY_CSLL "
cQuery += "    FROM " + RetSqlName("DTY")
cQuery += "    WHERE DTY_FILIAL = '" + xFilial("DTY")  + "' "
cQuery += "      AND DTY_FILORI = '" + cFilOri + "' "
cQuery += "      AND DTY_VIAGEM = '" + cViagem + "' "   
cQuery += "      AND (DTY_TIPCTC = '1' OR DTY_NUMCTC <> '" + cNumCtc + "') "    
cQuery += "      AND D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDTY, .F., .T.)

If (cAliasDTY)->(!Eof())
	nVlrBru   :=  (cAliasDTY)->DTY_VALFRE
	nIRRF     :=  (cAliasDTY)->DTY_IRRF
	nSEST     :=  (cAliasDTY)->DTY_SEST
	nINSS     :=  (cAliasDTY)->DTY_INSS
	nISS      :=  (cAliasDTY)->DTY_ISS
	nPIS      :=  (cAliasDTY)->DTY_PIS
	nCOFINS   :=  (cAliasDTY)->DTY_COFINS
EndIf
(cAliasDTY)->( DbCloseArea() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄp¿
//³Se for estorno de contrato de complemento considera o valor das despesas que não movimentam banco.  ³
//³Quando o estorno é do saldo não deve enviar as despesas, pois a despesa será deletada no Financeiro.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄpÙ
If DTY->DTY_TIPCTC == '5'
	nVLRDEB := PamDebVge(cFilOri, cViagem, DTR->DTR_CODVEI)
EndIf	

//Verifica se tem adiantamento para a viagem                                                                                  
nAdiFre  := PamAdiFre(cFilOri, cViagem,DTR->DTR_CODVEI, .T. )
nVlrBru += nAdiFre                                                                                                            

aFields    := {}					                                                                                            
AAdd (aFields,{'viagem.id', AllTrim(DTQ->DTQ_IDOPE)})
AAdd (aFields,{'viagem.contratante.documento.numero',aRetCNPJ[1]} )
AAdd (aFields,{'viagem.unidade.documento.tipo', aRetCNPJ[2] })
AAdd (aFields,{'viagem.unidade.documento.numero', aRetCNPJ[3]} )

//Chama a rotina que consulta o status do pedágio e da parcela de adiantamento, nao chamar quando exclusao do contrato no TMS.
If Substr(FunName(),1,6) <> "TMSA25" .And. Substr(FunName(),1,4) <> "FINA"
	If DTR->DTR_VALPDG > 0
		nRet := PamConPdCt(cFilOri, cViagem, aRetCNPJ, @cMsgRet)
		If nRet == 0 .Or. nRet == 5 .Or. nRet == 8
			If  nRet == 5 .Or. nRet == 8
				Help("",1, "TMSPAM011",,cMsgRet,4,0)//"Valor do pedagio ja carregado no cartão.", "Estorno não permitido."
			EndIf
			Return .F.
		EndIf
	EndIf
	
	If nAdiFre > 0
		aParCTC := PamGetParc(cFilOri, cViagem, aRetCNPJ, DTQ->DTQ_IDOPE, 2)
		If (nPosParc:= aScan(aParCTC, {|x| AllTrim(x[1]) == AllTrim(cParAdi)}) ) > 0
			cParc 	:= cValToChar(aParCTC[nPosParc][5])
			nRetParc:= Val(aParCTC[nPosParc][3])
			nParc	:= aParCTC[nPosParc][5]
		EndIf
		If nRetParc = 5 //Parcela ja efetivada, nao permitir estornar a operacao de saida da viagem
			Help("",1, "TMSPAM009",, ,3,0)  //"Parcela ja efetivada no sistema"###" Pamcard, estorno da saida ou exclusao"###" do contrato nao sera realizado."
			Return .F.
		EndIf
		
		If nRetParc == 2  //Somente faz o bloqueio da parcela com status de Liberada.

		
			If cParAdi != '1' .And. (!lCIOTPerio .Or. Len(PamVgsCiot(DTR->DTR_CIOT)) == 1)
				nRetParc := PamConParc(cFilOri, cViagem, aRetCNPJ, '1' ) //Chama a rotina que consulta a parcela de Adiantamento.
				If nRetParc = 5 //Parcela ja efetivada, nao permitir estornar a operacao de saida da viagem
					Help("",1, "TMSPAM009",, ,3,0)  //"Parcela ja efetivada no sistema"###" Pamcard, estorno da saida ou exclusao"###" do contrato nao sera realizado."
					Return .F.
				Else
					AAdd (aFields,{'viagem.parcela.qtde', '2' })
					AAdd (aFields,{'viagem.parcela1.numero.cliente', '1' } )
					AAdd (aFields,{'viagem.parcela1.status.id', '3' })  //Parcela Bloqueada
					AAdd (aFields,{'viagem.parcela2.numero.cliente', cParAdi } )
					AAdd (aFields,{'viagem.parcela2.status.id', '3' })  //Parcela Bloqueada
				EndIf
			Else
				AAdd (aFields,{'viagem.parcela.qtde', '1' })
				AAdd (aFields,{'viagem.parcela1.numero', cParc } )
				AAdd (aFields,{'viagem.parcela1.status.id', '3' })  //Parcela Bloqueada
			EndIf
			AAdd (aFields,{'viagem.antt.ciot.numero', AllTrim(DTR->DTR_CIOT)} )
			lRet := PamAltStPa(aFields) //Chamada da Função
		EndIf
	EndIf
EndIf

If lRet .And. (Substr(FunName(),1,6) == "TMSA25" .Or. Substr(FunName(),1,4) == "FINA")  //Entra na rotina quando a chamada for originada do fonte que libera o contrato.
	lAtuVlr := .T.
	//Verifica se existe contrato de carreteiro.
	DTY->(dbSetOrder(1))
	If DTY->(DbSeek(xFilial('DTY')+cNumCtc))//Se existir Contrato de Carreteiro, exclui a parcela de saldo a pagar.
		//REtorna da parcela do Título a Pagar.
		If Empty(cIdParcela )
			cIdParcela := PamRetIDPa (cPrefixo, cTipCTC, cFilOri, cNumCtc)									
		EndIf	
		//Chama a rotina que consulta a parcela da viagem Saldo Final
		nRetParc := PamConParc(cFilOri, cViagem, aRetCNPJ, cIdParcela )
		
		If nRetParc = 5 //Parcela ja efetivada, nao permitir estornar a operacao de saida da viagem
			Help("",1, "TMSPAM009",, ,4,0)  //"Parcela ja efetivada no sistema"###" Pamcard, estorno da saida ou exclusao"###" do contrato nao sera realizado."
			Return .F.                                               		
		EndIf                                                                                       
		
		If nRetParc == 2 .Or. nRetParc == 3   //Somente faz a exclusao da parcela com o status de Liberada ou Bloqueada.
			aParCTC:= PamGetParc(cFilOri, cViagem, aRetCNPJ, DTQ->DTQ_IDOPE, 1)
			For nParCTC := 1 To Len(aParCTC)
				If AllTrim(aParCTC[nParCTC,3]) <> '4'
					cParCTC := cValToChar(Val(cParCTC)+1)
					If nParCTC == Val(DTY->DTY_PARCTC) //--Manda a exclusão da parcela estornada 
					//--Se não for a única parcela e o adiantamento e não existir adiantamento. Altera o valor da parcela para 1.00 e o Tipo.
					//--Porque na PAMCARD sempre é necessário existir uma parcela.
						If cParCTC == '1' .And. nAdiFre == 0						
							lIncParAdi := .T.
						EndIf
						AAdd (aFields,{'viagem.parcela'+cParCTC+'.valor', '0.00' })
						AAdd (aFields,{'viagem.parcela'+cParCTC+'.numero.cliente',AllTrim(aParCTC[nParCTC,1]) })//Numero Id do Cliente						
					Else
						AAdd (aFields,{'viagem.parcela'+cParCTC+'.valor', StrTran( AllTrim(TransForm( (aParCTC[nParCTC,2]), '@E 999999999.99')), ',','.' )})
						AAdd (aFields,{'viagem.parcela'+cParCTC+'.numero.cliente', AllTrim(aParCTC[nParCTC,1]) })//Numero Id Cliente
					EndIf	
				EndIf	
			Next	
		EndIf
	EndIf
	aParCTC:= PamGetParc(cFilOri, cViagem, aRetCNPJ, DTQ->DTQ_IDOPE, 2)        
	If lIncParAdi                                 

		DA3->(DbSetOrder(1))
		If DA3->(DbSeek(xFilial('DA3')+DTR->DTR_CODVEI))

			lExistFav := !Empty(T250BscFav(DTR->DTR_CODVEI,DA3->DA3_CODFOR,DA3->DA3_LOJFOR,DTR->DTR_FILORI,DTR->DTR_VIAGEM))	// retorna o codigo do Favorecido 
		
			cFavId := PamRetFvId(cFilOri, cViagem, lExistFav)
			//--Traz parcelas não excluídas! Parcelas excluídas não devem ser enviadas na exclusão de outra.
			AAdd (aFields,{'viagem.parcela.qtde', AllTrim(Str(Len(aParCTC)+1))})
			cParCtc := Soma1(cParCtc)
			AAdd (aFields,{'viagem.parcela'+cParCtc+'.valor', '1.00' })
			AAdd (aFields,{'viagem.parcela'+cParCtc+'.numero.cliente',cParAdi})//Numero Id do Cliente
			AAdd (aFields,{'viagem.parcela'+cParCtc+'.subtipo','1'}) //1=Adiantamento
			AAdd (aFields,{'viagem.parcela'+cParCtc+'.status.id', '1'})//Pendente
			AAdd (aFields,{'viagem.parcela'+cParCtc+'.data', SubStr(DtoS(dDataBase),7,2) + '/' + SubStr(DtoS(dDataBase),5,2) + '/' + SubStr(DtoS(dDataBase),1,4)})
			AAdd (aFields,{'viagem.parcela'+cParCtc+'.favorecido.tipo.id', cFavId})//Contratado
			AAdd (aFields, {'viagem.parcela'+cParCtc+'.efetivacao.tipo', '2'}) //Efetivação Automática
			AAdd (aFields,{'viagem.frete.valor.bruto', '1.00'})
			AAdd (aFields,{'viagem.frete.valor.liquido', '1.00'})

		EndIf
	Else                                                                   
		AAdd (aFields,{'viagem.parcela.qtde', AllTrim(Str(Len(aParCTC)))})
		AAdd (aFields,{'viagem.frete.valor.bruto', StrTran( AllTrim(TransForm( nVlrBru, '@E 999999999.99')), ',','.' ) })
	EndIf	
EndIf                                                                                              
If lRet	
	If !lIncParAdi
		If nIRRF > 0
			nQtdImp ++
		EndIf
		
		If nSEST > 0
			nQtdImp ++
		EndIf
		
		If nINSS > 0
			nQtdImp ++
		EndIf
		
		If nISS > 0
			nQtdImp ++
		EndIf
		
		If nPIS > 0
			nQtdImp ++
		EndIf
		
		If nCOFINS > 0
			nQtdImp ++
		EndIf
		
		If nCSLL > 0
			nQtdImp ++
		EndIf
		
		If nVLRDEB > 0
			nQtdImp ++
		EndIf
		
		AAdd (aFields,{'viagem.frete.item.qtde', cValToChar(nQtdImp)})//Qtde de Impostos/Debitos e Creditos
		
		nQtdImp := 0    
		
		//Serão informado os valores dos impostos do contrato Original, pois o contrato complementar esta sendo excluiido ou estornado a liberacao.
		If nIRRF > 0
			nQtdImp ++
			PamTagImp(cDesIRRF, @aFields, nQtdImp, nIRRF)
		EndIf
		
		If nINSS > 0
			nQtdImp ++
			PamTagImp(cDesINSS, @aFields, nQtdImp, nINSS)
		EndIf
		
		If nSEST > 0
			nQtdImp ++
			PamTagImp(cDesSEST, @aFields, nQtdImp, nSEST)
		EndIf
		
		If nISS > 0
			nQtdImp ++
			PamTagImp(cDesISS, @aFields, nQtdImp, nISS)
		EndIf
		
		If nPIS > 0
			nQtdImp ++
			PamTagImp(cDesPIS, @aFields, nQtdImp, nPIS)
		EndIf
		
		If nCOFINS > 0
			nQtdImp ++
			PamTagImp(cDesCOFINS, @aFields, nQtdImp, nCOFINS)
		EndIf
		
		If nCSLL > 0
			nQtdImp ++
			PamTagImp(cDesCSLL, @aFields, nQtdImp, nCSLL)
		EndIf
		
		If nVLRDEB > 0
			nQtdImp ++
			PamTagImp(cDesDeb, @aFields, nQtdImp, nVLRDEB)
		EndIf
	EndIf
	If lAtuVlr //--So atualiza o valor da parcela caso seja estorno do saldo a pagar ou complemento. 
		lRet := PamVlrParc(aFields) //Chamada da Função para Alterar o valor do saldo a pagar e dos impostos no sistema Pamcard.
	EndIf	
EndIf
RestArea(aAreaDTR)
RestArea(aAreaDTY)
RestArea(aAreaDTQ)
RestArea(aArea)

FwFreeObj(aFields)
FwFreeObj(aParCTC)
FwFreeObj(aArea)
FwFreeObj(aAreaDTR)
FwFreeObj(aAreaDTY)
FwFreeObj(aAreaDTQ)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamExcCtr  ³ Autor:³ Gilson da Silva        ³ Data:³17/01/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Exclui o Contrato de Frete no Sitema Pamcard	    			     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamExcCtr                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ Estorno do Fechamento, viagem terceiro e agregado.           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamExcCtr(cFilOri, cViagem, aRetCNPJ, lPayToll, cNumCiot,cNumIdOpe,cNumIdCli,cNumIdPdg )

Local lRet      := .T.
Local aFields   := {}
Local nRet      := 0
Local cMsgRet	:= ''
Local aAreaDTQ	:= DTQ->(GetArea())
Local cRetCert	:= ''
Local aCertif	:= {}

Default cFilOri	:= ''
Default cViagem := ''
Default	aRetCNPJ:= {}
Default lPayToll:= .F.
Default cNumCiot:= ""
Default cNumIdOpe:= ""
Default cNumIdCli:= ""
Default cNumIdPdg:= ""

If PamCertDig('02',@cRetCert,aCertif)
	//Chama a rotina que consulta o status do pedágio da viagem
	nRet := PamConPdVg(cFilOri, cViagem, aRetCNPJ,@cMsgRet)
	If nRet == 0 .Or. nRet == 5 .Or. nRet == 8
		If  nRet == 5 .Or. nRet == 8
			Help("",1, "TMSPAM011",,cMsgRet,4,0)//"Valor do pedagio ja carregado no cartão.", "Estorno não permitido."			
		EndIf
		lRet := .F.
	Else			
		AAdd (aFields,{'viagem.id', AllTrim(DTQ->DTQ_IDOPE)})
		AAdd (aFields,{'viagem.contratante.documento.numero',aRetCNPJ[1]} )
		AAdd (aFields,{'viagem.unidade.documento.tipo', aRetCNPJ[2] })
		AAdd (aFields,{'viagem.unidade.documento.numero', aRetCNPJ[3]} )
		If lPayToll
			AAdd (aFields,{'viagem.antt.cancelamento.motivo', STR0029} )  //"Contrato cancelado devido ao problema no pagamento de pegadio por TAG (Metodo PayToll)."
		Else
			AAdd (aFields,{'viagem.antt.cancelamento.motivo', STR0010} )  //"Contrato cancelado para corrigir informacoes."
		EndIf
		AAdd (aFields,{'viagem.antt.ciot.numero',Iif(!Empty(DTR->DTR_CIOT),AllTrim(DTR->DTR_CIOT),AllTrim(cNumCiot))} )

		lRet := PamCanTrip(aFields,cRetCert,aCertif) //Chamada da Função

		If lRet
			RecLock('DTR',.F.)
			DTR->DTR_CIOT := ' '
			DTR->(MsUnLock())
			
            DTQ->(dbSetOrder(2))
			If DTQ->(DbSeek(fwxFilial('DTQ')+DTR->(DTR_FILORI+DTR_VIAGEM)))
				RecLock('DTQ',.F.)
				DTQ->DTQ_IDOPE := ''
				If IsInCallStack("A310EstPam")
					DTQ->DTQ_IDCLI := ''
				EndIf
				DTQ->(MsUnlock())
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaDTQ)

FwFreeObj(aAreaDTQ)
FwFreeObj(aCertif)
FwFreeObj(aFields)

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
Function PamInsTrip(aFields, cIDOpe, cRetCert, aCertif)
Local nCount   	:= 1
Local nCount2  	:= 1
Local oObjPam
Local lRet		:= .T.
Local nX		:= 0
Local aMsgErr  	:= {}

Default aFields := {}
Default cIdOpe	:= ''
Default cRetCert:= ''
Default aCertif	:= {}

If lRet := PamCertDig('02', @cRetCert, aCertif)
	If nTipoCerti == 2
		If ExistFunc('aPamInsTrip')
			lRet := aPamInsTrip(aFields, @cIDOpe, cRetCert, aCertif)
		Else
			MsgStop(STR0025, STR0001) //--"Para utilização do Certificado com extensão .PFX é necessário atualizar o programa: PamcardNew.prw"###"Atenção"
			lRet := .F.
		EndIf
	ElseIf nTipoCerti == 1
		If lRet
			oObjPam := WSWSPamcardDocumentService():New()
			oObjPam:oWSarg0:ccertificate := cRetCert
			oObjPam:oWSarg0:ccontext := 'InsertTrip'
			oObjPam:_URL := PamUrlWs()
			oObjPam:oWSarg0:oFieldTOs := WSPamcardDocumentService_ArrayOf_tns1_FieldTO():New()
			
			For nCount := 1 To Len(aFields)
				If !Empty(aFields[nCount][2])
					AAdd(oObjPam:oWSarg0:oFieldTOs:oFieldTo , WSPamcardDocumentService_FieldTO():New())
					oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:ckey := aFields[nCount][1]
					oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:cvalue := aFields[nCount][2]
					nCount2++
				EndIf
			Next nCount
			
			WsdlDbgLevel(3)
			
			If oObjPam:execute()
				nX := PamRetPos(oObjPam:oWSResponseTo:oReturn:oFieldTo, 'mensagem.codigo')
				If nX > 0 .And. oObjPam:oWSResponseTo:oReturn:oFieldTo[nX]:cValue == "0"
					If (nX := PamRetPos(oObjPam:oWSResponseTo:oReturn:oFieldTo, 'viagem.id')) > 0
						cIDOpe := AllTrim(oObjPam:oWSResponseTo:oReturn:oFieldTo[nX]:cValue)
						lRet := .T.
					Else
						aMsgErr := TMSErrOper('02',, '2')
						lRet := .F.
					EndIf
				Else
					Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oReturn:oFieldTo[2]:cValue,4,0)
					lRet := .F.
				EndIf
			Else
				aMsgErr := TMSErrOper('02',, '2')
				lRet := .F.
			EndIf
		EndIf

	EndIf
EndIf
FwFreeObj(aMsgErr)
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
Function PamInsCont(aFields, aRet, cIdCli)
Local nCount   	:= 1
Local nCount2  	:= 2
Local oObjPam
Local cRetCert 	:= '' //Certificado Digital
Local lRet     	:= .T.
Local aMsgErr  	:= {}
Local aCertif	:= {}

Default aFields	:= {}
Default aRet	:= {}
Default cIdCli 	:= ""

If Empty(cIdCli)
	cIdCli := PamDtHora()
EndIf

If lRet := PamCertDig('02', @cRetCert, aCertif)
	If nTipoCerti == 2
		If ExistFunc ('aPamInsCont')
			lRet := aPamInsCont( aFields, aRet, cIdCli,  aCertif)
		Else
			MsgStop(STR0025, STR0001) //--"Para utilização do Certificado com extensão .PFX é necessário atualizar o programa: PamcardNew.prw"###"Atenção"
			lRet := .F.		
		EndIf
	Else
		oObjPam := WSWSPamcardDocumentService():New()
		oObjPam:oWSarg0:ccertificate := cRetCert
		oObjPam:oWSarg0:ccontext := 'InsertFreightContract'
		oObjPam:_URL := PamUrlWs()
		oObjPam:oWSarg0:oFieldTOs := WSPamcardDocumentService_ArrayOf_tns1_FieldTO():New()
		
		AAdd(oObjPam:oWSarg0:oFieldTOs:oFieldTo , WSPamcardDocumentService_FieldTO():New())
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[1]:ckey := 'viagem.id.cliente'
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[1]:cvalue:= cIdCli
		aRet[3] := cIdCli
		
		For nCount := 1 To Len(aFields)
			If !Empty(aFields[nCount][2])
				AAdd(oObjPam:oWSarg0:oFieldTOs:oFieldTo , WSPamcardDocumentService_FieldTO():New())
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:ckey := aFields[nCount][1]
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:cvalue:= aFields[nCount][2]
				nCount2++
			EndIf
		Next nCount
		
		WsdlDbgLevel(3)
		
		If oObjPam:execute()
			If oObjPam:oWSResponseTo:oReturn:oFieldTo[1]:cValue == "0"
				
				For nCount := 1 To Len(oObjPam:oWSResponseTo:oReturn:oFieldTo) 
					If oObjPam:oWSResponseTo:oReturn:oFieldTo[nCount]:cKey == 'viagem.id' 
						aRet[2] := oObjPam:oWSResponseTo:oReturn:oFieldTo[nCount]:cValue
				ElseIf oObjPam:oWSResponseTo:oReturn:oFieldTo[nCount]:cKey == 'viagem.antt.ciot.numero' 
					aRet[1] := oObjPam:oWSResponseTo:oReturn:oFieldTo[nCount]:cValue
					EndIf	
				Next nCount

				lRet := .T.
			Else
				Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oReturn:oFieldTo[2]:cValue,4,0)
				lRet := .F.
			EndIf
		Else
			aMsgErr := TMSErrOper('02',, '2') 
			Help("",1, "TMSPAM003",, STR0011,4,0)//"Verifique se as informacoes no cadastro da operadora estão corretas."
			lRet := .F.
		EndIf
	EndIf
EndIf
FwFreeObj(aCertif)
FwFreeObj(aMsgErr)
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
Function PamConStPa(aFields,lHelp)
Local nCount   	:= 1
Local nCount2  	:= 1
Local oObjPam
Local cRetCert 	:= '' //Certificado Digital
Local nRet     	:= 0
Local lRet     	:= .T.
Local aCertif	:= {}

Default lHelp 	:= .T.
If lRet := PamCertDig('02', @cRetCert, aCertif)
	If nTipoCerti == 2
		If ExistFunc('aPamConStPa')
			nRet := aPamConStPa(aFields,aCertif,lHelp)
		Else
			MsgStop(STR0025, STR0001) //--"Para utilização do Certificado com extensão .PFX é necessário atualizar o programa: PamcardNew.prw"###"Atenção"
		EndIf
	ElseIf nTipoCerti == 1
		
		oObjPam := WSWSPamcardDocumentService():New()
		oObjPam:oWSarg0:ccertificate := cRetCert
		oObjPam:oWSarg0:ccontext := 'FindParcelStatus'
		oObjPam:_URL := PamUrlWs()
		oObjPam:oWSarg0:oFieldTOs := WSPamcardDocumentService_ArrayOf_tns1_FieldTO():New()
		
		For nCount := 1 To Len(aFields)
			If !Empty(aFields[nCount][2])
				AAdd(oObjPam:oWSarg0:oFieldTOs:oFieldTo, WSPamcardDocumentService_FieldTO():New())
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:ckey := aFields[nCount][1]
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:cvalue := aFields[nCount][2]
				nCount2++
			EndIf
		Next nCount
		
		WsdlDbgLevel(3)
		
		If oObjPam:execute()
			If oObjPam:oWSResponseTo:oReturn:oFieldTo[1]:cValue == "0"
				For nCount := 1 To Len(oObjPam:oWSResponseTo:oReturn:oFieldTo) 
					If oObjPam:oWSResponseTo:oReturn:oFieldTo[nCount]:cKey == 'viagem.parcela.status.id' 
						nRet := Val(oObjPam:oWSResponseTo:oReturn:oFieldTo[nCount]:cValue)
						Exit
					EndIf	
				Next	
			EndIf
		EndIf
	EndIf
	
EndIf

FwFreeObj(aCertif)
Return nRet

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
Function PamStPedag(aFields,cMsgRet)
Local nCount   	:= 1
Local nCount2  	:= 1
Local oObjPam
Local cRetCert 	:= '' //Certificado Digital
Local nRet     	:= 0
Local lRet     	:= .T.
Local aCertif	:= {}

Default aFields	:= {}
Default cMsgRet := ''

If lRet := PamCertDig('02', @cRetCert, aCertif)
	If nTipoCerti == 2
		If ExistFunc('APamStPedag')
			nRet:= APamStPedag(aFields, aCertif,@cMsgRet)		
		Else
			MsgStop(STR0025, STR0001) //--"Para utilização do Certificado com extensão .PFX é necessário atualizar o programa: PamcardNew.prw"###"Atenção"
		EndIf
	ElseIF nTipoCerti == 1

		oObjPam := WSWSPamcardDocumentService():New()
		oObjPam:oWSarg0:ccertificate := cRetCert
		oObjPam:oWSarg0:ccontext := 'FindTollStatus'
		oObjPam:_URL := PamUrlWs()
		oObjPam:oWSarg0:oFieldTOs := WSPamcardDocumentService_ArrayOf_tns1_FieldTO():New()
		
		For nCount := 1 To Len(aFields)
			If !Empty(aFields[nCount][2])
				AAdd(oObjPam:oWSarg0:oFieldTOs:oFieldTo , WSPamcardDocumentService_FieldTO():New())
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:ckey := aFields[nCount][1]
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:cvalue := aFields[nCount][2]
				nCount2++
			EndIf
		Next nCount
	
		WsdlDbgLevel(3)
		
		If oObjPam:execute()
			If oObjPam:oWSResponseTo:oReturn:oFieldTo[1]:cValue == "0"
				nRet := Val(oObjPam:oWSResponseTo:oReturn:oFieldTo[4]:cValue)
				cMsgRet := 	oObjPam:oWSResponseTo:oReturn:oFieldTo[2]:cValue
			Else
				Help("",1, "TMSPAM003",,oObjPam:oWSResponseTo:oReturn:oFieldTo[2]:cValue,4,0)
			EndIf
		EndIf
	EndIf
EndIf

FwFreeObj(aCertif)
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
Function PamAltStPa(aFields)
Local nCount   := 1
Local nCount2  := 1
Local oObjPam
Local cRetCert := '' //Certificado Digital
Local lRet     := .T.
Local aMsgErr  := {}
Local aCertif  := {}

If lRet := PamCertDig('02', @cRetCert, aCertif)
	If nTipoCerti == 2
		If ExistFunc('aPamAltStPa')
			lRet := aPamAltStPa(aFields, aCertif)
		Else
			MsgStop(STR0025, STR0001) //--"Para utilização do Certificado com extensão .PFX é necessário atualizar o programa: PamcardNew.prw"###"Atenção"
			lRet := .F.
		EndIf

	ElseIf nTipoCerti == 1
		oObjPam := WSWSPamcardDocumentService():New()
		oObjPam:oWSarg0:ccertificate := cRetCert
		oObjPam:oWSarg0:ccontext := 'UpdateParcelStatus'
		oObjPam:_URL := PamUrlWs()
		oObjPam:oWSarg0:oFieldTOs := WSPamcardDocumentService_ArrayOf_tns1_FieldTO():New()
		
		For nCount := 1 To Len(aFields)
			If !Empty(aFields[nCount][2])
				AAdd(oObjPam:oWSarg0:oFieldTOs:oFieldTo , WSPamcardDocumentService_FieldTO():New())
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:ckey := aFields[nCount][1]
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:cvalue := aFields[nCount][2]
				nCount2++
			EndIf
		Next nCount
		
		WsdlDbgLevel(3)
		
		If oObjPam:execute()
			If oObjPam:oWSResponseTo:oReturn:oFieldTo[1]:cValue == "0"
				lRet := .T.
			Else
				Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oReturn:oFieldTo[2]:cValue,4,0)
				lRet := .F.
			EndIf
		Else
			aMsgErr := TMSErrOper('02',, '2')
			lRet := .F.
		EndIf		
	EndIf
EndIf

FwFreeObj(aCertif)
FwFreeObj(aMsgErr)
Return lRet

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
Function PamCanTrip(aFields,cRetCert, aCertif)
Local nCount   	:= 1
Local nCount2  	:= 1
Local oObjPam
Local lRet     	:= .T.
Local aMsgErr  	:= {}

Default aFields	:= {}
Default cRetCert:= ''//Certificado Digital
Default aCertif	:= {}

If Empty(aCertif) .And. Empty(cRetCert)
	lRet := PamCertDig('02', @cRetCert, aCertif)
EndIf
If lRet
	If nTipoCerti == 2
		If ExistFunc('aPamCanTrip')
			lRet := aPamCanTrip(aFields, aCertif)
		Else
			MsgStop(STR0025, STR0001) //--"Para utilização do Certificado com extensão .PFX é necessário atualizar o programa: PamcardNew.prw"###"Atenção"
			lRet := .F.
		EndIf
	ElseIf nTipoCerti == 1	
		oObjPam := WSWSPamcardDocumentService():New()
		oObjPam:oWSarg0:ccertificate := cRetCert
		oObjPam:oWSarg0:ccontext := 'CancelTrip'
		oObjPam:_URL := PamUrlWs()
		oObjPam:oWSarg0:oFieldTOs := WSPamcardDocumentService_ArrayOf_tns1_FieldTO():New()
		
		For nCount := 1 To Len(aFields)
			If !Empty(aFields[nCount][2])
				AAdd(oObjPam:oWSarg0:oFieldTOs:oFieldTo , WSPamcardDocumentService_FieldTO():New())
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:ckey := aFields[nCount][1]
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:cvalue := aFields[nCount][2]
				nCount2++
			EndIf
		Next nCount
		
		WsdlDbgLevel(3)
		
		If oObjPam:execute()
			If oObjPam:oWSResponseTo:oReturn:oFieldTo[1]:cValue == "0"
				lRet := .T.
			Else
				Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oReturn:oFieldTo[2]:cValue,4,0)
				lRet := .F.
			EndIf
		Else
			aMsgErr := TMSErrOper('02',, '2')
			lRet := .F.
		EndIf
	EndIf          
EndIf

FwFreeObj(aMsgErr)
Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PamTagImp  ³ Autor ³ Gilson da Silva      ³ Data ³ 16/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta a Tag dos Tipos de Impostos                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PamTagImp(cTipoImp, aFields, nQtdImp, nValor)
AAdd (aFields,{'viagem.frete.item'+AllTrim(cValToChar(nQtdImp))+'.tipo', AllTrim(cTipoImp ) })
AAdd (aFields,{'viagem.frete.item'+AllTrim(cValToChar(nQtdImp))+'.valor',StrTran( AllTrim(TransForm( nValor, '@E 999999999.99')), ',','.' ) })
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PamVldCarg ³ Autor ³ Gilson da Silva      ³ Data ³ 19/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Se Frota Terceiro ou Agregado e Carga do tipo Lotacao,      ³±±
±±³			 ³valida se tem a informacao do codigo harmonizado da natureza³±±
±±³			 ³do produto na tabela SB1.  								           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PamVldCarg(cFilOri, cViagem)
Local aArea   	  := GetArea()
Local cQuery     := ""
Local cAliasQry  := GetNextAlias()    
Local cNatPadCrg := GetMV('MV_PAMNATC',,'0001') // Natureza Padrão para as cargas.   
Local cNatCarga  := ""
Local cTpCarga   := DTR->DTR_TIPCRG

If cTpCarga == '2'    
	cNatCarga := cNatPadCrg
Else	
	cQuery += "SELECT B1_TNATREC "
	cQuery += " FROM " + RetSqlName("DUD") + " DUD, "
	cQuery += RetSqlName("DTC") + " DTC, "
	cQuery += RetSqlName("SB1") + " SB1 "
	cQuery += " WHERE "
	cQuery += " DUD.DUD_FILIAL = '" + xFilial("DUD") + "' AND "
	cQuery += " DUD.DUD_FILORI = '" + cFilOri + "' AND "
	cQuery += " DUD.DUD_VIAGEM = '" + cViagem + "' AND "
	cQuery += " DUD.DUD_STATUS = '3' AND "
	cQuery += " DUD.D_E_L_E_T_ = ' ' AND "
	cQuery += " DTC.DTC_FILIAL = '" + xFilial("DTC") + "' AND "
	cQuery += " DTC.DTC_FILDOC = DUD.DUD_FILDOC AND "
	cQuery += " DTC.DTC_DOC    = DUD.DUD_DOC AND "
	cQuery += " DTC.DTC_SERIE  = DUD.DUD_SERIE AND "
	cQuery += " DTC.D_E_L_E_T_ = ' ' AND "
	cQuery += " SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND "
	cQuery += " SB1.B1_COD = DTC.DTC_CODPRO AND "
	cQuery += " SB1.D_E_L_E_T_ = ' '  "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)     
	cNatCarga := (cAliasQry)->B1_TNATREC
	(cAliasQry)->( dbCloseArea() )
	If Empty(cNatCarga)
		cNatCarga := cNatPadCrg
	EndIf
EndIf	

RestArea(aArea)
Return cNatCarga

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamVlrParc ³ Autor:³ Thiago Torelli         ³ Data:³19/01/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Atualiza Valores para os Contratos no Sistema Pamcard		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamVlrParc()											         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS			                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamVlrParc(aFields)
Local nCount   := 1
Local nCount2  := 1
Local oObjPam
Local cRetCert := '' //Certificado Digital
Local lRet	   := .T.
Local aCertif  := {}		

If lRet := PamCertDig('02', @cRetCert, aCertif)
	If ExistBlock('TMPAMXML')
        aPeItens := ExecBlock('TMPAMXML',.F.,.F.,{ aFields })
        If ValType(aPeItens) == "A"
            aFields := aPeItens
        EndIf
    EndIf
	If nTipoCerti == 2
		If ExistFunc('aPamVlrParc')
			lRet := aPamVlrParc(aFields)
		Else 
			MsgStop(STR0025, STR0001) //--"Para utilização do Certificado com extensão .PFX é necessário atualizar o programa: PamcardNew.prw"###"Atenção"
			lRet := .F.			
		EndIf
	ElseIf nTipoCerti == 1
		oObjPam := WSWSPamcardDocumentService():New()
		oObjPam:oWSarg0:ccertificate := cRetCert
		oObjPam:oWSarg0:ccontext := 'UpdateValuesFreightContract'
		oObjPam:_URL := PamUrlWs()
		oObjPam:oWSarg0:oFieldTOs := WSPamcardDocumentService_ArrayOf_tns1_FieldTO():New()
		
		For nCount := 1 To Len(aFields)
			
			If !Empty(aFields[nCount][2])
				AAdd(oObjPam:oWSarg0:oFieldTOs:oFieldTo , WSPamcardDocumentService_FieldTO():New())
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:ckey := aFields[nCount][1]
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:cvalue := aFields[nCount][2]
				nCount2++
			EndIf
			
		Next nCount
		
		WsdlDbgLevel(3)
		
		If oObjPam:execute()
			If oObjPam:oWSResponseTo:oReturn:oFieldTo[1]:cValue == "0"
				lRet := .T.
			Else
				Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oReturn:oFieldTo[2]:cValue,4,0)
				lRet := .F.
			EndIf
		Else
			lRet := .F.
		EndIf
	EndIf

EndIf
FwFreeObj(aCertif)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PamDtUltCh³ Autor ³ Gilson da Silva     		             ³ Data ³ 03/02/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna a data de chegada da viagem na ultima filial da rota.     	       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PamDtUltCh(ExpC1,ExpC2)	                                     		       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Filial Origem da Viagem          				                       ³±±
±±³          ³ExpC2 = Viagem                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMS 						                        	         		       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PamDtUltCh(cFilOri, cViagem)

Local cQuery 	:= ""
LocAL cAliasQry := ""
Local cAtivChg  := GetMV("MV_ATIVCHG")
Local dDtUltChg

cQuery += "SELECT MAX(DTW_SEQUEN) DTW_SEQUEN "
cQuery += " FROM " + RetSqlName("DTW") + " DTW "
cQuery += " WHERE "
cQuery += " DTW.DTW_FILIAL = '" + xFilial("DTW") + "' AND "
cQuery += " DTW.DTW_FILORI = '" + cFilOri + "' AND "
cQuery += " DTW.DTW_VIAGEM = '" + cViagem + "' AND "
cQuery += " DTW.DTW_ATIVID = '" + cAtivChg +  "' AND "
cQuery += " DTW.D_E_L_E_T_ = ' '"
cAliasQry := GetNextAlias()
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
dDtUltChg := Posicione("DTW",1,xFilial("DTW")+cFilOri+cViagem+(cAliasQry)->DTW_SEQUEN,"DTW_DATPRE")
(cAliasQry)->( dbCloseArea() )

Return (dDtUltChg)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PamAdiFre ³ Autor ³ Gilson da Silva     		             ³ Data ³ 03/02/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna o valor das despesas da viagem de Adiantamento de Frete.   		    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PamAdiFre(ExpC1,ExpC2, ExpC3)	                                		          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Filial Origem da Viagem          				                         ³±±
±±³          ³ExpC2 = Viagem                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMS 						                        	         			          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PamAdiFre(cFilOri, cViagem, cCodVei, lAllBco)

Local cQuery 	:= ""
LocAL cAliasQry := ""
Local nAdiFre   := 0
Local cCodOpe   := '02'  //Codigo da operadora Pamcard no TMS.
Local cDesPdg   := SuperGetMv("MV_DESPDG",,"") 
Local aAreaDTY  := DTY->(GetArea())
Local aArea     := GetArea()
Local cDesABST  := Padr( SuperGetMV('MV_DESABST',,''), Len( DT7->DT7_CODDES ) ) // Codigo de Despesa de Abastecimento

Default cCodVei := ''
Default lAllBco := .T.

DEG->(DbSetOrder(1)) //-- DEG_FILIAL+DEG_CODOPE
If DEG->(DbSeek(xFilial('DEG')+cCodOpe))

	cQuery += "SELECT SUM (DG_VALCOB) DG_VALCOB "
	cQuery += " FROM " + RetSqlName("SDG") + " SDG, "
	cQuery += RetSqlName("DT7") + " DT7 "
	cQuery += " WHERE "
	cQuery += " SDG.DG_FILIAL  = '" + Iif(Empty(xFilial("SDG")),xFilial('SDG'),cFilOri) + "' AND "
	cQuery += " SDG.DG_FILORI  = '" + cFilOri + "' AND "
	cQuery += " SDG.DG_VIAGEM  = '" + cViagem + "' AND "
	cQuery += " SDG.DG_CODVEI  = '" + cCodVei + "' AND "
	If !lAllBco
		cQuery += " SDG.DG_BANCO   = '" + DEG->DEG_BANCO 	+ "' AND "
		cQuery += " SDG.DG_AGENCIA = '" + DEG->DEG_AGENCI 	+ "' AND "
		cQuery += " SDG.DG_NUMCON  = '" + DEG->DEG_NUMCON 	+ "' AND "
	EndIf
	cQuery += " SDG.DG_ORIGEM <> 'DTY' AND "
	cQuery += " SDG.D_E_L_E_T_ = ' ' AND "
	cQuery += " DT7.DT7_FILIAL = '" + xFilial("DT7") + "' AND "
	cQuery += " DT7.DT7_CODDES = SDG.DG_CODDES AND "
	If !Empty(cDesPdg)
		cQuery += " DT7.DT7_CODDES <> '" + cDesPdg + "' AND "
	Endif
	If !Empty(cDesABST) // Tag de Abastecimento não deve fazer parte do adiantamento de frete, nem do total do frete
		cQuery += " DT7.DT7_CODDES <> '" + cDesABST + "' AND "
	Endif
	cQuery += " DT7.DT7_MOVBCO = '1' AND"
	cQuery += " DT7.D_E_L_E_T_ = ' '  "
	cAliasQry := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	
	If (cAliasQry)->(!Eof())
		nAdiFre := (cAliasQry)->DG_VALCOB
	EndIf	
	
	(cAliasQry)->( dbCloseArea() )
EndIf

RestArea(aAreaDTY)
RestArea(aArea)
Return (nAdiFre)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PamDebVge ³ Autor ³ Gilson da Silva     		             ³ Data ³ 03/02/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna o valor das despesas da viagem que nao movimentam banco (Debitos).   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PamDebVge(ExpC1,ExpC2)	                                     		          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Filial Origem da Viagem          				                         ³±±
±±³          ³ExpC2 = Viagem                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMS 						                        	         			          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PamDebVge(cFilOri, cViagem, cCodVei)

Local   cQuery 		:= ""
LocAL   cAliasQry 	:= ""
Local   nDebVge   	:= 0
Local 	cDesPdg   	:= SuperGetMv("MV_DESPDG",,"")

Default cCodVei   	:= ''

cQuery += "SELECT SUM (DG_VALCOB) DG_VALCOB "
cQuery += " FROM " + RetSqlName("SDG") + " SDG, "
cQuery += RetSqlName("DT7") + " DT7 "
cQuery += " WHERE "
cQuery += " SDG.DG_FILORI = '" + cFilOri + "' AND "
cQuery += " SDG.DG_VIAGEM = '" + cViagem + "' AND "
cQuery += " SDG.DG_CODVEI = '" + cCodVei + "' AND "
cQuery += " SDG.DG_ORIGEM <> 'DTY' AND "
cQuery += " SDG.D_E_L_E_T_ = ' ' AND "
cQuery += " DT7.DT7_FILIAL = '" + xFilial("DT7") + "' AND "
cQuery += " DT7.DT7_CODDES = SDG.DG_CODDES AND "
If !Empty(cDesPdg)
	cQuery += " DT7.DT7_CODDES <> '" + cDesPdg + "' AND "
Endif
cQuery += " DT7.DT7_MOVBCO <> '1' AND"
cQuery += " DT7.D_E_L_E_T_ = ' '  "
cAliasQry := GetNextAlias()
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

If (cAliasQry)->(!Eof())
	nDebVge := (cAliasQry)->DG_VALCOB
EndIf
(cAliasQry)->( dbCloseArea() )

Return (nDebVge)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamGetParc ³ Autor:³ Gilson da Silva        ³ Data:³10/02/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Obtem o numero da Parcela Saldo Final no sistema Pamcard.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ExpC1 = Filial Origem da Viagem                               ³±±
±±³           ³ExpC2 = Numero da Viagem                                      ³±±
±±³           ³ExpA1 = Dados da Transportadora                               ³±±
±±³           ³ExpC3 = Id Ope                                                ³±±
±±³           ³ExpC4 = nAcao (1=Inclusao;2=Estorno)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamGetParc(ExpC1, ExpC2, ExpA1, Expc3, Expc4)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS.												                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamGetParc(cFilOri, cViagem, aRetCNPJ, cIdOpe, nAcao)
Local aFields    := {}
Local aParCTC   := '' //numero da parcela do Saldo a pagar ou complemento

Default nAcao := 1

AAdd (aFields,{'viagem.id', AllTrim(cIdOpe)})
AAdd (aFields,{'viagem.contratante.documento.numero',aRetCNPJ[1]} )
AAdd (aFields,{'viagem.unidade.documento.tipo', aRetCNPJ[2] })
AAdd (aFields,{'viagem.unidade.documento.numero', aRetCNPJ[3]} )
AAdd (aFields,{'viagem.antt.ciot.numero', AllTrim(DTR->DTR_CIOT)} )
AAdd (aFields,{'viagem.pedagio.obter.praca', 'N'} )
AAdd (aFields,{'viagem.pedagio.obter.rota', 'N'} )
AAdd (aFields,{'viagem.obter.favorecido', 'S'} )
AAdd (aFields,{'viagem.obter.documento', 'N' } )
AAdd (aFields,{'viagem.obter.valores' , 'S' } )
AAdd (aFields,{'viagem.obter.veiculo', 'N' } )
AAdd (aFields,{'viagem.obter.quitacao', 'N' } )

aParCTC := PamSldParc(aFields,nAcao) //Chamada da Função

Return aParCTC

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
Function PamSldParc(aFields,nAcao)  
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
Local aCertif	:= {}

Default aFields := {}
Default nAcao 	:= 1

If lRet := PamCertDig('02', @cRetCert, aCertif)
	If nTipoCerti == 2
		If ExistFunc('aPamSldParc')
			aParCTC := aPamSldParc( aFields, nAcao, aCertif )  
		Else
			MsgStop(STR0025, STR0001) //--"Para utilização do Certificado com extensão .PFX é necessário atualizar o programa: PamcardNew.prw"###"Atenção"
		EndIf
	ElseIf lRet
		oObjPam := WSWSPamcardDocumentService():New()
		oObjPam:oWSarg0:ccertificate := cRetCert
		oObjPam:oWSarg0:ccontext := 'FindFreightContract'
		oObjPam:_URL := PamUrlWs()
		oObjPam:oWSarg0:oFieldTOs := WSPamcardDocumentService_ArrayOf_tns1_FieldTO():New()
		
		For nCount := 1 To Len(aFields)
			If !Empty(aFields[nCount][2])
				AAdd(oObjPam:oWSarg0:oFieldTOs:oFieldTo, WSPamcardDocumentService_FieldTO():New())
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:ckey := aFields[nCount][1]
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:cvalue := aFields[nCount][2]
				nCount2++
			EndIf
		Next nCount
		
		WsdlDbgLevel(3)

		If oObjPam:execute()
			If oObjPam:oWSResponseTo:oReturn:oFieldTo[1]:cValue == "0"  	
				nPos := Ascan(oObjPam:oWSResponseTo:oReturn:oFieldTo,{|x| AllTrim(x:cKey)=="viagem.parcela.qtde"})
				nQtdParc := Val(oObjPam:oWSResponseTo:oReturn:oFieldTo[nPos]:cValue)
				For nParc := 1  To nQtdParc
					//--Só traz as parcelas que não foram excluídas se a acao for 2--Estorno
					nPos := Ascan(oObjPam:oWSResponseTo:oReturn:oFieldTo,{|x| AllTrim(x:cKey)=="viagem.parcela"+Alltrim(Str(nParc))+".status.id"})
					cStatus := Iif(nPos >0,AllTrim(oObjPam:oWSResponseTo:oReturn:oFieldTo[nPos]:cValue),'')
					If nAcao == 1 .Or. ( nAcao == 2 .and. cStatus <> '4')
						nPos := Ascan(oObjPam:oWSResponseTo:oReturn:oFieldTo,{|x| AllTrim(x:cKey)=="viagem.parcela"+Alltrim(Str(nParc))+".numero.cliente"}) 
						cNumCli := Iif(nPos >0,AllTrim(oObjPam:oWSResponseTo:oReturn:oFieldTo[nPos]:cValue),'')
						nPos := Ascan(oObjPam:oWSResponseTo:oReturn:oFieldTo,{|x| AllTrim(x:cKey)=="viagem.parcela"+Alltrim(Str(nParc))+".valor"})
						nVlrPar := Iif(nPos >0,Val(AllTrim(oObjPam:oWSResponseTo:oReturn:oFieldTo[nPos]:cValue)),0)
						nPos := Ascan(oObjPam:oWSResponseTo:oReturn:oFieldTo,{|x| AllTrim(x:cKey)=="viagem.favorecido"+Alltrim(Str(nParc))+".cartao.numero"})
						cCartao := Iif(nPos >0,Val(AllTrim(oObjPam:oWSResponseTo:oReturn:oFieldTo[nPos]:cValue)),0)
						AAdd(aParCTC,{cNumCli,nVlrPar, cStatus, cCartao, nParc})	
					EndIf	
				Next
			Else
				Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oReturn:oFieldTo[2]:cValue,4,0)			
			EndIf
		Else	
			Help("",1, "TMSPAM003",,,3,0)
		EndIf		
		
	EndIf    
EndIf

Return aParCTC

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamInsCtPF ³ Autor:³ Gilson da Silva        ³ Data:³10/02/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Insere cartao portador frete p/o contratado no sistema Pamcard³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamInsCtPF()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS			                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamInsCtPF(aRetCNPJ, cCodFor, cLojFor, cIdOpe, lRespCart)
Local lRet 		 := .T.
Local aFields   := {}
Local aArea     := GetArea()
Local aAreaSA2  := SA2->(GetArea()) 
Local cTpPessoa := ''
Local cEmissorRg := ''
Default lRespCart := .F. 

DbSelectArea("SA2")
DbSetOrder(1)    

If DbSeek(xFilial("SA2") + cCodFor + cLojFor) 
	
	If SA2->A2_TIPO == 'J'
		cTpPessoa := '1'
	EndIf

	AAdd (aFields,{'viagem.contratante.documento.numero',aRetCNPJ[1]} )
	AAdd (aFields,{'viagem.unidade.documento.tipo', aRetCNPJ[2] })
	AAdd (aFields,{'viagem.unidade.documento.numero', aRetCNPJ[3]} )
	AAdd (aFields,{'viagem.cartao.numero',  cIdOpe })
	If lRespCart  		
		//--Dados do Portador do Cartão (Motorista)
		AAdd (aFields,{'viagem.cartao.portador.documento.tipo', '2' } )
		AAdd (aFields,{'viagem.cartao.portador.documento.numero', AllTrim(M->DDQ_CGC) } )
		AAdd (aFields,{'viagem.cartao.portador.rg', AllTrim(M->DDQ_RG) } ) 
		AAdd (aFields,{'viagem.cartao.portador.uf.rg', AllTrim(M->DDQ_RGEST) } )
		If !Empty(M->DDQ_RGORG)
			Do Case
				Case Upper(AllTrim(M->DDQ_RGORG)) == 'SSP'
					cEmissorRg	:=	'01'
				Case Upper(AllTrim(M->DDQ_RGORG)) == 'CNH'
					cEmissorRg	:=	'02'
				Case Upper(AllTrim(M->DDQ_RGORG)) == 'MMA'
					cEmissorRg	:=	'03'
				Case Upper(AllTrim(M->DDQ_RGORG)) == 'DIC'
					cEmissorRg	:=	'04'
				Case Upper(AllTrim(M->DDQ_RGORG)) == 'POF'
					cEmissorRg	:=	'05'
				Case Upper(AllTrim(M->DDQ_RGORG)) == 'IFP'
					cEmissorRg	:=	'06'
				Case Upper(AllTrim(M->DDQ_RGORG)) == 'POM'
					cEmissorRg	:=	'07'
				Case Upper(AllTrim(M->DDQ_RGORG)) == 'IPF'
					cEmissorRg	:=	'08'
				Case Upper(AllTrim(M->DDQ_RGORG)) == 'SES'
					cEmissorRg	:=	'09'
				Case Upper(AllTrim(M->DDQ_RGORG)) == 'MAE'
					cEmissorRg	:=	'10'
				Case Upper(AllTrim(M->DDQ_RGORG)) == 'MEX'
					cEmissorRg	:=	'11'
			EndCase
			AAdd (aFields,{'viagem.cartao.portador.rg.emissor.id', cEmissorRg } )
		EndIF
		If !Empty(M->DDQ_RGDT)
			AAdd (aFields,{'viagem.cartao.portador.rg.emissao.data', SubStr(DtoS(M->DDQ_RGDT),7,2) + '/' + SubStr(DtoS(M->DDQ_RGDT),5,2) + '/' + SubStr(DtoS(M->DDQ_RGDT),1,4) } )
		EndIF
		If SA2->A2_TIPO == 'F'
			AAdd (aFields,{'viagem.cartao.portador.rntrc', AllTrim(SA2->A2_RNTRC) } )
		Else
			AAdd (aFields,{'viagem.cartao.portador.rntrc', "" } )
		EndIF 
		AAdd (aFields,{'viagem.cartao.portador.nome', AllTrim(M->DDQ_NOME) } )
		AAdd (aFields,{'viagem.cartao.portador.data.nascimento', SubStr(DtoS(M->DDQ_DTNASC),7,2) + '/' + SubStr(DtoS(M->DDQ_DTNASC),5,2) + '/' + SubStr(DtoS(M->DDQ_DTNASC),1,4) } )
		AAdd (aFields,{'viagem.cartao.portador.nacionalidade.id', '1' } )		
		If !Empty(M->DDQ_ESTNAT) .AND. !Empty(M->DDQ_CMUNAT)
			AAdd (aFields,{'viagem.cartao.portador.naturalidade.ibge', AllTrim(TMS120CdUf(M->DDQ_ESTNAT,'1')+M->DDQ_CMUNAT) } )
		EndIF
		If !Empty(M->DDQ_SEXO)
			If M->DDQ_SEXO == '1'
				AAdd (aFields,{'viagem.cartao.portador.sexo', 'M' } )
			EndIf
			If M->DDQ_SEXO == '2'
				AAdd (aFields,{'viagem.cartao.portador.sexo', 'F' } )
			EndIf
		EndIF		
		AAdd (aFields,{'viagem.cartao.portador.endereco.logradouro', AllTrim(FisGetEnd(M->DDQ_END)[1]) } )
		AAdd (aFields,{'viagem.cartao.portador.endereco.numero', AllTrim(cValtoChar( FisGetEnd(M->DDQ_END)[2]))} )
		AAdd (aFields,{'viagem.cartao.portador.endereco.bairro', AllTrim(M->DDQ_BAIRRO) } )
		AAdd (aFields,{'viagem.cartao.portador.endereco.cidade', AllTrim(M->DDQ_MUN) } )
		AAdd (aFields,{'viagem.cartao.portador.endereco.uf', AllTrim(M->DDQ_EST) } )
		AAdd (aFields,{'viagem.cartao.portador.endereco.pais', 'BRASIL' } )
		AAdd (aFields,{'viagem.cartao.portador.endereco.cep', AllTrim(M->DDQ_CEP) } )
		If !Empty(M->DDQ_TPPROP)
			AAdd (aFields,{'viagem.cartao.portador.endereco.propriedade.tipo.id', AllTrim(CValToChar(Val(M->DDQ_TPPROP))) } )
		EndIF
		If !Empty(M->DDQ_RESDES)
			AAdd (aFields,{'viagem.cartao.portador.endereco.reside.desde', AllTrim(SUBSTR(M->DDQ_RESDES,1,2)+'/'+SUBSTR(M->DDQ_RESDES,3,4)) } )
		EndIF
		AAdd (aFields,{'viagem.cartao.portador.telefone.ddd', StrZero(Val(M->DDQ_DDD),3) } )
		AAdd (aFields,{'viagem.cartao.portador.telefone.numero', AllTrim(StrTran(M->DDQ_TEL,"-","")) } )
		
		If DDQ->(FieldPos("DDQ_OPECEL")) > 0
			If !Empty(M->DDQ_OPECEL)
				AAdd (aFields,{'viagem.cartao.portador.celular.operadora.id', AllTrim(M->DDQ_OPECEL) } )
			EndIF 		
		EndIF
		If DDQ->(FieldPos("DDQ_DDDCEL")) > 0
			If !Empty(M->DDQ_DDDCEL)
				AAdd (aFields,{'viagem.cartao.portador.celular.ddd', StrZero(Val(M->DDQ_DDDCEL),3) } )
			EndIF
		EndIF
		If DDQ->(FieldPos("DDQ_CEL")) > 0
			If !Empty(M->DDQ_CEL)
				AAdd (aFields,{'viagem.cartao.portador.celular.numero', AllTrim(StrTran(M->DDQ_CEL,"-","")) } )
			EndIF
		EndIF
	Else
	//--Dados do Portador do Cartão (Motorista)
	AAdd (aFields,{'viagem.cartao.portador.documento.tipo', '2' } )
	AAdd (aFields,{'viagem.cartao.portador.documento.numero', AllTrim(DA4->DA4_CGC) } )
	AAdd (aFields,{'viagem.cartao.portador.rg', AllTrim(DA4->DA4_RG) } ) 
	AAdd (aFields,{'viagem.cartao.portador.uf.rg', AllTrim(DA4->DA4_RGEST) } )
	AAdd (aFields,{'viagem.cartao.portador.rntrc', "" } ) 
	AAdd (aFields,{'viagem.cartao.portador.nome', AllTrim(DA4->DA4_NOME) } )
	AAdd (aFields,{'viagem.cartao.portador.data.nascimento', SubStr(DtoS(DA4->DA4_DATNAS),7,2) + '/' + SubStr(DtoS(DA4->DA4_DATNAS),5,2) + '/' + SubStr(DtoS(DA4->DA4_DATNAS),1,4) } )
	AAdd (aFields,{'viagem.cartao.portador.endereco.logradouro', AllTrim(DA4->DA4_END) } )
	AAdd (aFields,{'viagem.cartao.portador.endereco.numero', '1' } )
	AAdd (aFields,{'viagem.cartao.portador.endereco.bairro', AllTrim(DA4->DA4_BAIRRO) } )
	AAdd (aFields,{'viagem.cartao.portador.endereco.cidade', AllTrim(DA4->DA4_MUN) } )
	AAdd (aFields,{'viagem.cartao.portador.endereco.uf', AllTrim(DA4->DA4_EST) } )
	AAdd (aFields,{'viagem.cartao.portador.endereco.pais', 'Brasil' } )
	AAdd (aFields,{'viagem.cartao.portador.endereco.cep', AllTrim(DA4->DA4_CEP) } )
	AAdd (aFields,{'viagem.cartao.portador.telefone.ddd', AllTrim(DA4->DA4_DDD)})
	AAdd (aFields,{'viagem.cartao.portador.telefone.numero', AllTrim(StrTran(DA4->DA4_TEL,"-","")) } )
	EndIf
	If cTpPessoa == '1'
		AAdd (aFields,{'viagem.cartao.empresa.nome',  AllTrim(SA2->A2_NOME) })
		AAdd (aFields,{'viagem.cartao.empresa.cnpj',  SA2->A2_CGC })
	EndIf	
	lRet := PamInsCard(aFields)
Else     
	Help('',1,'TMSA24061',,,3,0) //Não foi encontrado fornecedor'###'para este motorista.
	lRet := .F.
EndIf	                

RestArea(aAreaSA2)
RestArea(aArea)
Return lRet                                                         

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³Pamcary    ³ Autor:³ Gilson da Silva        ³ Data:³12/03/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Valida Integracao Pamcary			                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³Pamcary()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMSAE60                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/    
Function Pamcary(lHelp)   

Local   lRet  := .T.    
Default lHelp := .T.
                                 
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamPtoDca  ³ Autor:³ Richard Anderson       ³ Data:³01/10/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Retorna pontos de descarga da viagem                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamPtoDca(ExpA1, ExpC1, ExpC2, aExpA2)                        ³±±
±±³           ³ aExpA1 - Array contendo o XML da integracao PAMCARD até o    ³±±
±±³           ³          momento                                             ³±±
±±³           ³ cExpC1 - Filial de origem da viagem                          ³±±
±±³           ³ cExpC2 - Numero da viagem                                    ³±±
±±³           ³ cExpA2 - Pontos de descarga opicional                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ SIGATMS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/    
Function PamPtoDca(aFields, cFilOri, cViagem, aPtoDca)

Local   cCdrOri   := ""
Local   cCodMun   := ''
Local   cRotVge   := DTQ->DTQ_ROTA
Local   cSerTms   := ''
Local   cAliasQry := ''
Local   nCnt		:= 0
Local   nUltPto   := 0
Local   nI			:= 0
Local   aPtoUsr   := {}

Default aFields	  := {}
Default cFilOri   := ''
Default cViagem   := ''
Default aPtoDca   := {{ '', '' }} 

If Empty(DTQ->DTQ_CDRORI)
	DA8->(DbSetOrder(1))
	If DA8->(DbSeek(xFilial("DA8") + DTQ->DTQ_ROTA)) 
		cCdrOri:= DA8->DA8_CDRORI
	EndIf
Else
	cCdrOri := DTQ->DTQ_CDRORI
EndIf

If DTQ->DTQ_TIPVIA == '2'
	If ExistBlock( "PAMPTDCA" )	//-- Permite incluir os pontos de descarga
		aPtoUsr := ExecBlock("PAMPTDCA",.F.,.F.,{ cFilOri, cViagem })
		If ValType(aPtoUsr) == "A"
			For nI := 1 To Len(aPtoUsr)
				If Ascan(aPtoDca,{ | e | e[2] == aPtoUsr[nI] }) == 0
					Aadd(aPtoDca, { cCdrOri, aPtoUsr[nI] } )
				EndIf					
			Next nI
		EndIf							
	Else
		aPtoDca := TmsRegDCA(cRotVge)
	EndIf
Else	
	If Empty(aPtoDca)
		cSerTms := Posicione("DTQ",2,xFilial("DTQ")+cFilOri+cViagem,"DTQ_SERTMS")
		If cSerTms == '1' //-- Coleta
			cQuery := " SELECT DUD_SEQUEN, DT5_CDRORI, DUE_CDRSOL "
			
			cQuery += "		FROM " + RetSqlName("DUD")	+ " DUD	"
						
			cQuery += " 	INNER JOIN " + RetSqlName("DT6") + " DT6		"
			cQuery += " 		ON 	DT6.DT6_FILDOC 	= DUD.DUD_FILDOC		"
			cQuery += "			AND DT6.DT6_DOC 	= DUD.DUD_DOC 			"
			cQuery += "			AND DT6.DT6_SERIE 	= DUD.DUD_SERIE			"
			cQuery += "			AND DT6.DT6_FILIAL  = '" + xFilial("DT6") + "'"
			cQuery += "			AND DT6.D_E_L_E_T_  = ' ' 					" 

			cQuery += "		INNER JOIN " + RetSqlName("DT5") + " DT5		"
			cQuery += "			ON 	DT5.DT5_FILDOC 	= DT6.DT6_FILDOC 		"
			cQuery += "			AND DT5.DT5_DOC		= DT6.DT6_DOC 			"
			cQuery += "			AND DT5.DT5_SERIE	= DT6.DT6_SERIE 		"
			cQuery += "			AND DT5.DT5_FILIAL  ='" + xFilial("DT5") + 	"'"
			cQuery += "			AND DT5.D_E_L_E_T_ 	= ' ' 					"

			cQuery += "		INNER JOIN " + RetSqlName("DUE") + " DUE		"
			cQuery += "			ON 	DUE.DUE_CODSOL 	= DT5.DT5_CODSOL		"
			cQuery += "			AND DUE.DUE_FILIAL = '" + xFilial("DUE") + 	"'"
			cQuery += "			AND DUE.D_E_L_E_T_ = ' ' "

			cQuery += "		WHERE DUD.DUD_FILIAL = '" + xFilial('DUD') + 	"'"
			cQuery += "   		AND DUD.DUD_FILORI  = '"+cFilOri+"'"
			cQuery += "   		AND DUD.DUD_VIAGEM  = '"+cViagem+"'"
			cQuery += "   		AND DUD.DUD_STATUS <> '9' "
			cQuery += "			AND DUD.D_E_L_E_T_  = ' '					"
			cQuery += "		ORDER BY DUD.DUD_SEQUEN "
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
			While (cAliasQry)->(!Eof())
				If Ascan(aPtoDca,{ | e | e[1]+e[2] == (cAliasQry)->DT5_CDRORI+(cAliasQry)->DUE_CDRSOL }) == 0
					Aadd(aPtoDca,{ (cAliasQry)->DT5_CDRORI, (cAliasQry)->DUE_CDRSOL })
				EndIf
				(cAliasQry)->(dbSkip())
			EndDo
			(cAliasQry)->(dbCloseArea())
			
		ElseIf cSerTms == '2' //-- Transporte
			//--Envia Informacao do CODIBGE dos Municipios do Trecho, assim não será necessário enviar o nome da rota cadastrada no PAMCARD
			aPtoDca := TmsRegDCA(cRotVge)
			
		ElseIf cSerTms == '3' //-- Entrega	
			//Seleciona os documentos da viagem
			cQuery := " SELECT DUD_SEQUEN, DT6_CDRORI ,DT6_CDRCAL  "
			cQuery += " FROM " + RetSqlName("DUD") + " DUD, "
			cQuery +=            RetSqlName("DT6") + " DT6, "
			cQuery += " WHERE DUD.DUD_FILIAL  = '"+xFilial("DUD")+"'"
			cQuery += "   AND DUD.DUD_FILORI  = '"+cFilOri+"'"
			cQuery += "   AND DUD.DUD_VIAGEM  = '"+cViagem+"'"
			cQuery += "   AND DUD.DUD_STATUS <> '9' "
			cQuery += "   AND DUD.D_E_L_E_T_  = ' ' "
			cQuery += "   AND DT6.DT6_FILIAL  = '"+xFilial("DT6") + "'"
			cQuery += "   AND DT6.DT6_FILDOC  = DUD.DUD_FILDOC"
			cQuery += "   AND DT6.DT6_DOC     = DUD.DUD_DOC"
			cQuery += "   AND DT6.DT6_SERIE   = DUD.DUD_SERIE"
			cQuery += "   AND DT6.D_E_L_E_T_  = ' ' "
			cQuery += " ORDER BY DUD_SEQUEN"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
			While (cAliasQry)->(!Eof())
				If Ascan(aPtoDca,{ | e | e[1]+e[2] == (cAliasQry)->DT6_CDRORI+(cAliasQry)->DT6_CDRCAL }) == 0
					Aadd(aPtoDca,{ (cAliasQry)->DT6_CDRORI, (cAliasQry)->DT6_CDRCAL })
				EndIf
				(cAliasQry)->(dbSkip())
			EndDo
			(cAliasQry)->(dbCloseArea())
		EndIf
	EndIf	
EndIf
If ExistFunc('TMSCEOrDes') .And. Len(aCEPeDist:= TMSCEOrDes(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,DTQ->DTQ_SERTMS)) > 0
	If aCEPeDist[3] > 0
		AAdd(aFields, {'viagem.origem.cidade.cep'	   , aCEPeDist[1] })
        AAdd(aFields, {'viagem.destino.cidade.cep'	   , aCEPeDist[2] })
		AAdd(aFields, {'viagem.distancia.km'		   , AllTrim(TransForm( aCEPeDist[3], '@E 999999999')) }) 
		AAdd(aFields, {'viagem.pedagio.roteirizar.tipo', '1'})
    EndIf	
EndIf	
If Len(aPtoDca) > 0
	cCodMun := Posicione("DUY",1,xFilial("DUY")+cCdrOri,"DUY_CODMUN")         
	nUltPto := Len(aPtoDca)
		AAdd(aFields, {'viagem.origem.cidade.ibge', TMS120CdUf(DUY->DUY_EST,'1')+cCodMun })			
		cCodMun := Posicione("DUY",1,xFilial("DUY")+aPtoDca[nUltPto,2],"DUY_CODMUN")
		AAdd(aFields, {'viagem.destino.cidade.ibge', TMS120CdUf(DUY->DUY_EST,'1')+cCodMun} )
		If nUltPto > 2
			AAdd(aFields, {'viagem.ponto.qtde', AllTrim(Str(nUltPto-1))})
			For nCnt := 1 To (nUltPto - 1)
				cCodMun := Posicione('DUY',1,xFilial('DUY')+aPtoDca[nCnt,2],'DUY_CODMUN')
				AAdd(aFields, {'viagem.ponto'+AllTrim(Str(nCnt))+'.cidade.ibge', TMS120CdUf(DUY->DUY_EST,'1')+cCodMun})
			Next nCnt
		EndIf		
EndIf

Return aFields
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PamCanBx	ºAutor  ³Leandro Paulino     º Data ³  30/10/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetua a exclusão da Parcela no PAMCARD - SIGATMS          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMS - INTEGRACAO VIA WEB SERVICE SISTEMA PAMCARD			  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function PamCanBx(cFilOri,cNum,cCodOpe)

Local lLibCTC 	 := SuperGetMv('MV_LIBCTC',.F.,.F.)
Local lRet		 := .T.    
Local aRetCNPJ  := {}
Local nRetParc	 := 0
Local cTipPdg    	:= Padr( GetMV("MV_TPTPDG"), Len( SE2->E2_TIPO ) )    // Tipo Pedagio 
               
Default cFilOri := ''
Default cNum    := ''
Default cCodOpe := ''

If cCodOPe  == '02' .And. Substr(FunName(),1,4) == "FINA" .And. SE2->E2_TIPO <> cTipPdg
	
	DTY->(dbSetOrder(4))
	If !DTY->(dbSeek(xFilial('DTY')+cFilOri+cNum))
		Help('',1,'TMSPAM015',,,3,0) //"O contrato de carreteiro que originou o", " titulo nao foi encontrado.","Não foi possível estornar a baixa!" 
		lRet := .F.	
	EndIf
	If lRet
		aRetCNPJ   := PamCNPJEmp(DTY->DTY_CODOPE, DTY->DTY_FILORI) //Função para obter CNPJ da contrante e filial de origem
			                                                       
		DTQ->(dbSetOrder(2))
		If DTQ->(dbSeek(xFilial('DTQ') + DTY->(DTY_FILORI+DTY_VIAGEM)))			
			//Consulta parcela para saber se ja foi efetivada
			nRetParc := PamConParc(DTY->DTY_FILORI, DTY->DTY_VIAGEM, aRetCNPJ, AllTrim(Str(Val(DTY->DTY_PARCTC))),AllTrim(DTQ->DTQ_IDOPE) ) //Chama a rotina que consulta a parcela de Saldo Final.
			If nRetParc == 5 //Parcela Efetivada                         
				Help('',1,'TMSPAM014',,,3,0) //"Parcela ja efetivada no sistema", " Pamcard, estorno da liberação","do contrato não permitida."
				lRet:= .F.
			ElseIf nRetParc <> 4  //-- Se já foi excluido não chama função de estorno
				lRet := PamEstPaCt(DTY->DTY_FILORI, DTY->DTY_VIAGEM, aRetCNPJ, DTY->DTY_NUMCTC) //Modifica o status da parcela de liberada para Excluída						
			EndIf                             								
		Else
			Help('',1,'TMSPAM016',,,3,0) //"A viagem que originou o", " titulo nao foi encontrada.","Não foi possível estornar a baixa!" 
		EndIf
	EndIf
	If lRet
		RecLock('DTY',.F.)
		DTY->DTY_STATUS := IIf(lLibCTC,'2','1')
		MsUnLock()			
	EndIf			
EndIf             

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PamOrgEmisºAutor  ³Leandro Paulino     º Data ³  16/09/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetua De/Para para o Orgao Emissor do RG				        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMS - INTEGRACAO VIA WEB SERVICE SISTEMA PAMCARD			  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PamOrgEmis(cOrgEmi)

Local cResult	 := ""

Default cOrgEmi := ""

Do Case 
	Case cOrgEmi == "SSP"  //--Secretaria de Seguranca Publica
		cResult := '1'
	Case cOrgEmi == "CNH"  //--Carteira Nacional de habilitacao
		cResult := '2'
	Case cOrgEmi == "MMA" //--Ministerio da Marinha
		cResult := '3'	  
	Case cOrgEmi == "DIC" //--Diretoria de Identificacao Civil
		cResult := '4'
	Case cOrgEmi == "POF" //--Policia Federal
		cResult := '5'                                         
	Case cOrgEmi == "IFP" //--Instituto Felix Pacheco
		cResult := '6'
	Case cOrgEmi == "POM" //--Policia Militar
		cResult := '7'
	Case cOrgEmi == "IPF" //--Instituto Pereira Faustino
		cResult := '8'
	Case cOrgEmi == "SES" //--Carteira de Estrangeiro
		cResult := '9'
	Case cOrgEmi == "MAE" //--Ministerio da Aeronautica
		cResult := '10'                                 
	Case cOrgEmi == "MEX" //--Ministerio do Exercito
		cResult := '11'	
EndCase 

Return cResult

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PamQtdFav ºAutor  ³Leandro Paulino     º Data ³  16/09/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para saber os favorecidos enviados				        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMS - INTEGRACAO VIA WEB SERVICE SISTEMA PAMCARD			  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±                                                          
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PamQtdFav(lExistFav,lExpMot,aForPag,cCodOpe)

Local aFav    		:= {} //Favorecido,;Forma de Pagamento;id Cartão
Local cProprieta	:= '1'//1=Proprietario;2=Favorecido;3=Motorista
Local cFavorecid	:= '2'//1=Proprietario;2=Favorecido;3=Motorista
Local cMotorista	:= '3'//1=Proprietario;2=Favorecido;3=Motorista
Local cPar1	  		:= '1'//1=Cartao;2=Conta
Local cPar2	  		:= '2'//1=Cartao;2=Conta
Local cIdOpe  		:= ''
Local cRecFre 		:= ''
Local cRecAdt 		:= ''
Local cRecPDG		:= ''
Local nPosFre		:= 0
Local nPosAdt		:= 0
Local nPosPDG 		:= 0
Local lTagid   		:= .F.

Default lExistFav 	:= .F.
Default lExpMot		:= .F.
Default aForPag		:= {}         
Default cCodOpe 	:= '02'  //Codigo da operadora Pamcard no TMS.   

If Len(aForPag) > 0 //Quando existir a tabela DLD
	nPosFre := Ascan(aForPag, {|x|  x[2] == '2'})
	nPosAdt := Ascan(aForPag, {|x|  x[2] == '1'})
	nPosPdg := Ascan(aForPag, {|x|  x[2] == '3'})
	//Tratamento para quando não é informada a parcela de andiamento considera os dados da parcela de saldo	
	If nPosAdt = 0
		nPosAdt := nPosFre
	EndIf
	If nPosPDG = 0
		nPosPDG = nPosFre
	EndIf
	
	cRecFre := aForPag [nPosFre,3]
	cRecAdt := aForPag [nPosAdt,3]
	cRecPDG := aForPag [nPosPDG,3]
	
	lTagid := iIf (aForPag [nPosPdg,1] == '3',.T.,.F.) 

	If aForPag [nPosFre,1] == aForPag [nPosAdt,1] .And. cRecFre == cRecAdt  .And.  cRecFre == '1'// Forma de pagamento igual e recebedor igual e recebedor proprietário
		
		If !lExistFav  //--Manda apenas o proprietário como favorecido e a forma de pagamento.
			
			Aadd(aFav,{cProprieta,aForPag [nPosAdt,1],aForPag [nPosAdt,4]})
						
			If aForPag [nPosFre,4] <> aForPag [nPosAdt,4] //Cartão das parcelas diferente
				Aadd(aFav,{cProprieta,aForPag [nPosFre,1],aForPag [nPosFre,4]})
			EndIf
			
			//--Verifica se a parcela de pedágio está diferente da parcela de Frete	
			If (aForPag [nPosFre,1] != aForPag [nPosPDG,1] .Or. cRecFre != cRecPDG) .And. !lTagid //Verifica se o pagamento do pedágio não é via Tag
					Aadd(aFav,{cMotorista,aForPag [nPosPDG,1],aForPag [nPosPDG,4]})
			EndIf
			
		Else	//Se existir Favorecido Envia o Proprietario como Favorecido1 e Favorecido(Protheus) como Favorecido2 na Pamcard.
			Aadd(aFav,{cProprieta,'2',""})
			If aForPag [nPosFre,4] <> aForPag [nPosAdt,4] //Cartão das parcelas diferente
				Aadd(aFav,{cFavorecid,aForPag [nPosAdt,1],aForPag [nPosAdt,4]})
			EndIf
			Aadd(aFav,{cFavorecid,aForPag [nPosFre,1],aForPag [nPosFre,4]})
		EndIf	
		
	ElseIf  aForPag [nPosFre,1] <> aForPag [nPosAdt,1] .And. cRecFre == cRecAdt .And.  cRecFre == '1' // Forma de pagamento diferente e recebedor igual e recebedor proprietário
		If !lExistFav //Se a forma de Pagto for diferente e não existir favorecido, manda dois favorecidos(proprietario) um para cada forma de pagto.
			Aadd(aFav,{cProprieta,aForPag [nPosAdt,1],aForPag [nPosAdt,4]})
			Aadd(aFav,{cProprieta,aForPag [nPosFre,1],aForPag [nPosFre,4]})
		Else //Se a forma de Pagto for diferente e existir favorecido, manda Favorecido1 e Favorecido(Protheus) como Favorecido2 na Pamcard.
			Aadd(aFav,{cProprieta,'2',""})
			Aadd(aFav,{cFavorecid,aForPag [nPosAdt,1],aForPag [nPosAdt,4]})
			Aadd(aFav,{cFavorecid,aForPag [nPosFre,1],aForPag [nPosFre,4]})
		EndIf			
	ElseIf aForPag [nPosFre,1] == aForPag [nPosAdt,1] .And. cRecFre == cRecAdt  .And.  cRecFre == '2'// Forma de pagamento igual e recebedor igual e recebedor motorista envia o proprietario e o motorista como favorecido
		Aadd(aFav,{cProprieta,'2',""})
		Aadd(aFav,{cMotorista,aForPag [nPosAdt,1],aForPag [nPosAdt,4]})
		If aForPag [nPosFre,4] <> aForPag [nPosAdt,4] //Cartão das parcelas diferente
			Aadd(aFav,{cMotorista,aForPag [nPosFre,1],aForPag [nPosFre,4]})
		Endif
	ElseIf  aForPag [nPosFre,1] <> aForPag [nPosAdt,1] .And. cRecFre == cRecAdt .And.  cRecFre == '2' // Forma de pagamento diferente e recebedor igual e recebedor motorista  envia o proprietario e o motorista como favorecido
		Aadd(aFav,{cProprieta,'2',""})
		Aadd(aFav,{cMotorista,aForPag [nPosAdt,1],aForPag [nPosAdt,4]})
		Aadd(aFav,{cMotorista,aForPag [nPosFre,1],aForPag [nPosFre,4]})
	Else //Recebedor das parcelas diferente
		If !lExistFav //Se não existir favorecido (Protheus) envia o proprietário e o motorista como favorecido
			If cRecFre =='1'
				Aadd(aFav,{cProprieta,aForPag [nPosFre,1],aForPag [nPosFre,4]})
				Aadd(aFav,{cMotorista,aForPag [nPosAdt,1],aForPag [nPosAdt,4]})
			Else
				Aadd(aFav,{cProprieta,aForPag [nPosAdt,1],aForPag [nPosAdt,4]})
				Aadd(aFav,{cMotorista,aForPag [nPosFre,1],aForPag [nPosFre,4]})
			Endif
		Else //Se a forma de Pagto for diferente e existir favorecido, envia o proprietário, favorecido (Protheus) e motorista como favorecido 
			If cRecFre =='1'
				Aadd(aFav,{cProprieta,'2',""})
				Aadd(aFav,{cFavorecid,aForPag [nPosFre,1],aForPag [nPosFre,4]})
				Aadd(aFav,{cMotorista,aForPag [nPosAdt,1],aForPag [nPosAdt,4]})
			Else
				Aadd(aFav,{cProprieta,'2',""})
				Aadd(aFav,{cFavorecid,aForPag [nPosAdt,1],aForPag [nPosAdt,4]})
				Aadd(aFav,{cMotorista,aForPag [nPosFre,1],aForPag [nPosFre,4]})
			Endif
		EndIf	
	EndIf
Else //Regra antiga
	If DUP->DUP_FORADT == DUP->DUP_FORPAG //--Se o Tipo do Pagto do Saldo e do Adto forem iguais
		If !lExistFav .Or. DUP->DUP_FORPAG == '1' //--Manda apenas um favorecido e a forma de pagamento.
			Aadd(aFav,{cProprieta,DUP->DUP_FORPAG,DUP->DUP_IDOPE})
		Else	//Se existir Favorecido Envia o Proprietario como Favorecido1 e Favorecido(Protheus) como Favorecido2 na Pamcard.
			Aadd(aFav,{cProprieta,DUP->DUP_FORPAG,DUP->DUP_IDOPE}) 
			Aadd(aFav,{cFavorecid,DUP->DUP_FORADT,DUP->DUP_IDOPE})
		EndIf
	ElseIf !lExistFav //Se a forma de Pagto for diferente e não existir favorecido, manda dois favorecidos(proprietario) um para cada forma de pagto.
		Aadd(aFav,{cProprieta,DUP->DUP_FORPAG,DUP->DUP_IDOPE})
		Aadd(aFav,{cProprieta,DUP->DUP_FORADT,DUP->DUP_IDOPE})
	Else //Se a forma de Pagto for diferente e existir favorecido, manda Favorecido1 e Favorecido(Protheus) como Favorecido2 na Pamcard.
		Aadd(aFav,{cProprieta,cPar1,,DUP->DUP_IDOPE})
		Aadd(aFav,{cFavorecid,cPar2,,DUP->DUP_IDOPE})
	EndIf
	If lExpMot
		DEL->( DbSetOrder(2) )
		If DEL->( MsSeek(xFilial('DEL') + DA4->DA4_COD + cCodOpe ))
			cIdOpe := DEL->DEL_IDOPE
		Endif	
		Aadd(aFav,{cMotorista,"",cIdOpe})			
	Endif
EndIf     

Return aFav

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PamDtHora ºAutor  ³Felipe BarbieriData ³  01/07/2015        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que retorna a Data e Hora Atual                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMS - INTEGRACAO VIA WEB SERVICE SISTEMA PAMCARD  		    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±                                                          
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamDtHora() 
Local nHH, nMM , nSS, nMS := seconds() 
Local cData := DTOS(dDataBase)

nHH := int(nMS/3600) 
nMS -= (nHH*3600) 
nMM := int(nMS/60) 
nMS -= (nMM*60) 
nSS := int(nMS) 
nMS := (nMs - nSS)*1000
 
Return cData + strzero(nHH,2) + strzero(nMM,2) + strzero(nSS,2) + strzero(nMS,3) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PamTaxBan ºAutor ³Fabio Marchiori SampaioData ³  11/12/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que retorna o bandeira (codigo do banco) do cartao  .±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMS - INTEGRACAO VIA WEB SERVICE SISTEMA PAMCARD  		    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±                                                          
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamCodBan(cCodMot, cIDOPE, cFilOri, cViagem) 

Local cCodBan		:= ''
Local cQuery		:= ''
Local cAliasDTR		:= ''

Default cCodMot 	:= ''
Default cIDOPE		:= ''
Default cFilOri 	:= ''
Default cViagem		:= ''

If Empty(cIdOpe)
	//--Como não existe um cartão principal para a viagem, iremos procurar o código do banco do recebedor da parcela
	//--Procurar na DLD a parcela de saldo de frete para verificar o favorecido do frete.
	cQuery      := " SELECT DTR.DTR_FILORI, DTR.DTR_VIAGEM, SA2.A2_BANCO BANCO"
	cQuery      += " FROM " + RetSqlName ("DTR") + " DTR " 
	cQuery 		+= " INNER JOIN " + RetSqlName ("SA2") + " SA2 "
	If DTR->(ColumnPos('DTR_CODFAV')) > 0 .And. DTR->(ColumnPos('DTR_LOJFAV')) > 0 
		cQuery		+= " ON SA2.A2_COD = CASE WHEN DTR.DTR_CODFAV <> ' ' THEN DTR_CODFAV ELSE DTR_CODFOR END   "
		cQuery      += " AND SA2.A2_LOJA = CASE WHEN DTR.DTR_LOJFAV <> ' ' THEN DTR_LOJFAV ELSE DTR_LOJFOR END "
	Else
		cQuery		+= " ON SA2.A2_COD = DTR.DTR_CODFOR 	"
		cQuery		+= " AND SA2.A2_LOJA = DTR.DTR_LOJFOR 	"
	EndIf
	cQuery      += " AND SA2.A2_FILIAL = '" + fwxFilial ("SA2") + "' "
	cQuery 		+= " AND SA2.D_E_L_E_T_ = ' ' "
	cQuery      += " WHERE DTR.DTR_FILIAL = '" + xFilial ("DTR") + "' " 
	cQuery      += " AND DTR.DTR_FILORI = '" + cFilOri + "' " 
	cQuery      += " AND DTR.DTR_VIAGEM = '" + cViagem + "' " 
	cQuery      += " AND DTR.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	
	cAliasDTR := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDTR,.F.,.T.)
	cCodBan := (cAliasDTR)->(BANCO) 
Else

	DbSelectArea("DEL")
	DEL->(DbSetOrder(2)) //DEL_FILIAL+DEL_CODMOT+DEL_CODOPE+DEL_IDOPE                                                                                                                      
	If DEL->(DbSeek(xFilial("DEL") + cCodMot + '02' + cIDOPE))
		cCodBan := DEL->DEL_CODBAN
	Else
		DbSelectArea("DDQ")
		DDQ->(DbSetOrder(1)) //DDQ_FILIAL+DDQ_IDCART+DDQ_CODFOR+DDQ_LOJFOR                                                                                                                                                                                                                                           
		If DDQ->(DbSeek(xFilial("DDQ") + cIDOPE + DA3->DA3_CODFOR + DA3->DA3_LOJFOR))
			cCodBan := DDQ->DDQ_CODBAN
		EndIf
	EndIf
EndIf
					                                                                                                                      
Return(cCodBan)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PamTaxBan ºAutor ³Fabio Marchiori SampaioData ³  11/12/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que retorna a tarifa com os valores de saque e transf.±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMS - INTEGRACAO VIA WEB SERVICE SISTEMA PAMCARD  		    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±                                                          
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamTaxBan(cCodBan, nQtdSaq, nQtdTransf) 

Local aTaxBan		:= {}
Local nValor		:= 0

	DbSelectArea("DJB")
	DJB->(DbSetOrder(1))//DJB_FILIAL+DJB_CODBAN+DJB_TARIFA+DJB_CODTAF                                                                                                                     
	If DJB->(DbSeek(xFilial('DJB')+ cCodBan))
		While DJB->(!EOF()) .And. DJB->(DJB_CODBAN) == cCodBan
			If DJB->DJB_TARIFA == '1' // SAQUE
				nValor :=  nQtdSaq * DJB->DJB_VALOR
				AAdd(aTaxBan, {DJB->DJB_CODBAN, DJB->DJB_TARIFA, DJB->DJB_CODTAF, nValor, nQtdSaq} ) 
			Else //TRANSFERENCIA
				nValor :=  nQtdTransf * DJB->DJB_VALOR
				AAdd(aTaxBan, {DJB->DJB_CODBAN, DJB->DJB_TARIFA, DJB->DJB_CODTAF, nValor, nQtdTransf} )
			EndIf
		DJB->(DbSkip())
		EndDo
	EndIf

Return(aTaxBan)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PamTaxTot ºAutor ³Fabio Marchiori SampaioData ³  11/12/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que retorna a tarifa com os valores totais          .±±
±±º          ³ de saque e transf                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMS - INTEGRACAO VIA WEB SERVICE SISTEMA PAMCARD  		    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±                                                          
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamTaxTot(cCodBan, nQtdSaq, nQtdTransf) 

Local nValTot		:= 0
Local nValSaq		:= 0
Local nValTran	:= 0

	DbSelectArea("DJB")
	DJB->(DbSetOrder(1))//DJB_FILIAL+DJB_CODBAN+DJB_TARIFA+DJB_CODTAF                                                                                                                     
	If DJB->(DbSeek(xFilial('DJB')+ cCodBan))
		While DJB->(!EOF()) .And. DJB->(DJB_CODBAN) == cCodBan
			If DJB->DJB_TARIFA == '1' // SAQUE
				nValSaq :=  nQtdSaq * DJB->DJB_VALOR
			Else //TRANSFERENCIA
				nValTran :=  nQtdTransf * DJB->DJB_VALOR
			EndIf
		DJB->(DbSkip())
		EndDo
	nValTot := nValSaq + nValTran
	EndIf

Return(nValTot)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamAltCont ³ Autor:³ Daniel Carlos Leme     ³ Data:³16/08/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Alteracao do Contrato (uso para CIOT por periodo - Agregados) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamAltCont()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³PAMCARD                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamAltCont(cCIOT,cParFil,cParVge,aRetCNPJ,lEstorno)
Local cTipDoc    := Iif(DTQ->DTQ_SERTMS == "1", "11", "5") //Se a viagem for de coleta o tipo de docto sera 11-Ordem de Coleta, senão sera 5=Conhecimento.
Local cNatCarga  := ''
Local cQuery     := ''
Local cPlacaVei  := ''
Local cAliasDUD  := ''
Local cAliasDT6  := ''
Local cAliasDOC  := ''
Local cTpPessoa  := ''
Local cPesoVge   := ''
Local cCodMun    := ''   
Local lRet       := .T. 

Local nQtdDoc    	:= 0
Local nCont      	:= 0
Local nQtdVei    	:= 0
Local nAdiFre    	:= 0 
Local nValPdg	  	:= 0
Local nValBru	  	:= 0

Local aFieldsDoc   	:= {}
Local aFieldsVlr   	:= {}
Local aAreaDTR   	:= DTR->(GetArea())
Local aAreaDUP   	:= DUP->(GetArea())
Local aAreaDA3   	:= DA3->(GetArea())
Local aAreaSA2   	:= SA2->(GetArea())
Local aAreaDTQ   	:= DTQ->(GetArea())

Local lOk        	:= .F.                              
Local cCodOpe	  	:= ''
Local aVeiculos  	:= {}                              
Local aPtoDca	  	:= {}                              
Local cParAdi    	:= '1'
Local aCodFav	 	:= {}
Local cCodFav	  	:= ''
Local cLojFav	  	:= ''
Local cTipFav		:= ''
Local nQtdFav	  	:= 1
Local nPosFav		:= 0
Local lTabDLD    := TableInDic('DLD')
Local aForPag	 := {}	
Local aFav			:= {} //Dados dos Favorecidos
Local lExistFav		:= .F.            
Local cIdCli		:= ""         
Local cFilOri		:= ""
Local cViagem		:= ""
Local cAliasDTR		:= ""
Local cIdOpe		:= ""
Local nParcela		:= 0
Local nAux			:= 0
Local lExcContr		:= .F.
Local cCodBan	    := ""
Local nTxAdBan      := 0

Local lMV_PAMROT	:= SuperGetMv("MV_PAMROTA",.F.,.T.)
Local lDTRTPSPDG    := DTR->(ColumnPos("DTR_TPSPDG")) > 0
Local cTipPagPDG    := ''
Local cIdOpe1		:= ""
Local nQtdSaq       := 0
Local nQtdTra       := 0
Local lExpMot		:= .F.
Local cCPFMot		:= ""

Default lEstorno := .F.

cQuery := " SELECT DTR_FILORI, DTR_VIAGEM "
cQuery += " FROM " + RetSqlName("DTR")
cQuery += " WHERE DTR_FILIAL = '" + xFilial("DTR") + "' "
cQuery += "   AND D_E_L_E_T_ = ' ' "
cQuery += "   AND DTR_CIOT   = '" + cCIOT + "' "
If lEstorno
	cQuery += " AND DTR_FILORI+DTR_VIAGEM <> '"+cParFil+cParVge+"'" 
EndIf
cQuery += " GROUP BY DTR_FILORI, DTR_VIAGEM "
cQuery := ChangeQuery(cQuery)

cAliasDTR := GetNextAlias()
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDTR,.F.,.T.)

//-- Se é estorno e tem apenas 1 viagem no CIOT por período, estorna o contrato e, consequentemente, o CIOT.
If lEstorno .And. (cAliasDTR)->(Eof())
	lExcContr := .T.
EndIf	

Do While lRet .And. ((cAliasDTR)->(!Eof()) .Or. !Empty(cParVge))
	//-- Percorre primeiro todas as viagens anteriores com o CIOT e, por último, a viagem que está sendo vinculada ao CIOT
 	If (cAliasDTR)->(!Eof())
		cFilOri := (cAliasDTR)->DTR_FILORI
		cViagem := (cAliasDTR)->DTR_VIAGEM
	Else
		cFilOri := cParFil
		cViagem := cParVge
	EndIf

	aVeiculos := {} 	 
	//Posiciona na tabela de Complementos da viagem (Veiculo da viagem).
	DTR->(DbSetOrder(1))
	If DTR->(!dbSeek(xFilial('DTR') + cFilOri + cViagem))
		Help( ' ', 1, 'TMSXFUNA24' ) //-- Complemento de viagem nao encontrado (DTR)
		lRet := .F.
		Exit         
	Else
		cCodOpe := DTR->DTR_CODOPE	
	EndIf

	cParAdi := PamIdAdto(cFilOri, cViagem, DTR->DTR_CODVEI)
	nRecDTR := DTR->(Recno())	

	//Posiciona na tabela de viagens
	DTQ->(DbSetOrder(2))
	If DTQ->(!dbSeek(xFilial('DTQ') + cFilOri + cViagem))
		Help(' ', 1, 'TMSXFUNA07') 	//-- Viagem nao encontrada (DTQ).
		lRet := .F.
		Exit         
	Else
		cRotaVge := DTQ->DTQ_ROTA
		//-- Guarda o ID da operação e o Id do cliente para colocá-lo na outra viagem.
		If !Empty(DTQ->DTQ_IDOPE)
			cIdOpe   := AllTrim( DTQ->DTQ_IDOPE )
			cIdcli := AllTrim( DTQ->DTQ_IDCLI )
		EndIf
	EndIf
	nRecDTQ := DTQ->(Recno())	
	
	//Posiciona na tabela de Motorista da viagem.
	DUP->(DbSetOrder(1))
	If DUP->(DbSeek(xFilial('DUP') + cFilOri + cViagem))
		lOk := PamCondut (cFilOri, cViagem)
	EndIf
	
	If lOk
		cIdOpe1 := DUP->DUP_IDOPE
		nQtdSaq := DUP->DUP_QTDSAQ
		nQtdTra := DUP->DUP_QTDTRA

		If lDTRTPSPDG 
			cIdOpe1 := TMSIDPAM(DTR->DTR_FILORI,DTR->DTR_VIAGEM,'2')  //Tipo Parcela do Pagamento da Viagem
			If DTR->DTR_QTDSAQ > 0 .And.  DTR->DTR_QTDTRA > 0  //Tratamento caso os campos criados recentemente estejam com conteudo vazio
				nQtdSaq:= DTR->DTR_QTDSAQ
				nQtdTra:= DTR->DTR_QTDTRA
			EndIf	
		EndIf


		//Posiciona na tabela de veículos.
		DA3->(DbSetOrder(1))
		DA3->(DbSeek(xFilial('DA3')+DTR->DTR_CODVEI))
		
		AAdd(aVeiculos,{ DTR->DTR_CODVEI, DTR->DTR_QTDEIX , DTR->DTR_QTEIXV })
													 
		
		//Posiciona na Tabela de Fornecedor do veículo
		SA2->(dbSetOrder(1))
		If !SA2->(DbSeek(xFilial("SA2")+DA3->DA3_CODFOR+DA3->DA3_LOJFOR) )
			Help(' ', 1, 'TMSA24071') //'Não foi encontrado o fornecedor do ', 'motorista no cadastro de fornecedor.'
			lRet := .F.
		EndIf

		If lRet
			cTpPessoa := Iif(SA2->A2_TIPO=="F", '2', '1')
		
			cPlacaVei  := StrTran(DA3->DA3_PLACA," ","")
			cPlacaVei  := StrTran(cPlacaVei,"-","")
		
			cNatCarga:= PamVldCarg(cFilOri, cViagem)
		
			If Empty(nCont)
				//--Inicia montagem do array de campos para Inclusão de documentos
				aFieldsDoc := {}
				AAdd (aFieldsDoc,{'viagem.contratante.documento.numero'	, aRetCNPJ[1]   } )
				AAdd (aFieldsDoc,{'viagem.unidade.documento.tipo'		, aRetCNPJ[2]   })
				AAdd (aFieldsDoc,{'viagem.unidade.documento.numero'		, aRetCNPJ[3]   } )
				AAdd (aFieldsDoc,{'viagem.antt.ciot.numero'				, AllTrim(cCIOT)} )

			EndIf
	
			If lTabDLD .And. FindFunction('TmsForPag')
				//Formas de Pagamento da viagem
				aForPag := TmsForPag(cFilOri,cViagem)
				lExpMot := Ascan(aForPag, {|x|  x[3] == '2'}) > 0
				lExistFav 	:= Ascan(aForPag, {|x|  !Empty(x[5]) }) > 0
			
				If lExistFav
					nPosFav := Ascan(aForPag, {|x|  !Empty(x[5]) })
					cCodFav := aForPag[nPosFav][5]
					cLojFav := aForPag[nPosFav][6]
				Endif
				
				aFav := PamQtdFav(lExistFav,lExpMot,aForPag)
			Else	
				/*	VERIFICA SE POSSUI FAVORECIDO NO VEICULO OU FORNECEDOR*/
				aCodFav := T250BscFav(DTR->DTR_CODVEI,DA3->DA3_CODFOR,DA3->DA3_LOJFOR,DTR->DTR_FILORI,DTR->DTR_VIAGEM)	// retorna o codigo do Favorecido 
				If !Empty(aCodFav)
					cCodFav := aCodFav[1][1]
					cLojFav := aCodFav[1][2]
					lExistFav := .T.
				EndIf	
				
				If cTpPessoa == '2'
					lExpMot := AllTrim(cCPFMot) <> AllTrim(SA2->A2_CGC) .AND. !Empty(cCPFMot)
				Else
					If AliasIndic('DDQ')
						DDQ->(dbSetOrder(1))	
						If DDQ->(MsSeek(xFilial('DDQ')+DUP->DUP_IDOPE))
							lExpMot := AllTrim(cCPFMot) <> AllTrim(DDQ->DDQ_CGC) .AND. !Empty(cCPFMot)
						EndIf
					EndIf
				EndIf
				aFav := PamQtdFav(lExistFav,lExpMot)
			EndIf	
			
			nQtdFav:=Len(aFav)

			nQtdVei:= 1
			If !Empty(DTR->DTR_CODRB1)
				nQtdVei++
			EndIf
				
			If !Empty(DTR->DTR_CODRB2)
				nQtdVei++
			EndIf
				
			If !Empty(DTR->DTR_CODRB1) 
				//Posiciona na tabela de veículos.
				DA3->(DbSetOrder(1))
				DA3->(DbSeek(xFilial('DA3')+DTR->DTR_CODRB1))
				AAdd(aVeiculos,{ DTR->DTR_CODRB1,  0, 0 })					
			EndIf
				
			If !Empty(DTR->DTR_CODRB2)
				//Posiciona na tabela de veículos.
				DA3->(DbSetOrder(1))
				DA3->(DbSeek(xFilial('DA3')+DTR->DTR_CODRB2))
				AAdd(aVeiculos,{ DTR->DTR_CODRB2, 0, 0 })					
			EndIf

			If !Empty(DTR->DTR_CODRB3)
				//Posiciona na tabela de veículos.
				DA3->(DbSetOrder(1))
				DA3->(DbSeek(xFilial('DA3')+DTR->DTR_CODRB3))
				AAdd(aVeiculos,{ DTR->DTR_CODRB3, 0 , 0 })								
			EndIf
			
			nValPdg := DTR->DTR_VALPDG
				
			//-- Verifica se o cliente trabalha com rota ou com pontos de descarga para calculo de pedagio e envio do contrato
			If !lMV_PAMROT
				PamPtoDca(@aFieldsDoc, cFilOri, cViagem, @aPtoDca )
				If DEG->(FieldPos('DEG_CALPDG')) > 0 .And. Posicione('DEG',1,xFilial('DEG')+cCodOpe,'DEG_CALPDG') == '1' //-- Calcula pela operadora
					//-- Retorna pontos de descarga da viagem                      
					If cTipPagPDG <> '4' .And. !lFrotaProp
						nValPdg := TmsCalPdg(aVeiculos,cRotaVge,cCodOpe,,aPtoDca)
					EndIf
					If nValPdg > 0 .And. Empty(DTR->DTR_CIOT)
						RecLock('DTR',.F.)
						DTR->DTR_VALPDG := nValPdg
						MsUnLock()
					EndIf
				EndIf	
			EndIf		
				
			If DTQ->DTQ_SERTMS == '1' //Viagem de coleta   
				//Somatoria do Peso da viagem  
				cQuery := " SELECT SUM(DT6_PESO) PESO "
				cQuery += "   FROM " + RetSqlName("DUD") + " DUD, "
				cQuery +=              RetSqlName("DT6") + " DT6, "
				cQuery +=              RetSqlName("DT5") + " DT5, "
				cQuery +=              RetSqlName("DUE") + " DUE, "
				cQuery +=              RetSqlName("SA1") + " SA1R, "
				cQuery +=              RetSqlName("SA1") + " SA1D "
				cQuery += " WHERE DUD.DUD_FILIAL = '" + xFilial("DUD")+"'"
				cQuery += " AND DUD.DUD_FILORI = '" + cFilOri+"'"
				cQuery += " AND DUD.DUD_VIAGEM = '" + cViagem + "'"
				cQuery += " AND DUD.DUD_STATUS <> '9' "
				cQuery += " AND DUD.D_E_L_E_T_ = ' ' "
				cQuery += " AND DT6.DT6_FILIAL = '" + xFilial("DT6") + "'"
				cQuery += " AND DT6.DT6_FILDOC = DUD.DUD_FILDOC"
				cQuery += " AND DT6.DT6_DOC = DUD.DUD_DOC"
				cQuery += " AND DT6.DT6_SERIE = DUD.DUD_SERIE"
				cQuery += " AND DT6.D_E_L_E_T_ = ' ' "
				cQuery += " AND DT5.DT5_FILIAL = '" + xFilial("DT5") + "'"
				cQuery += " AND DT5.DT5_FILDOC = DT6.DT6_FILDOC"
				cQuery += " AND DT5.DT5_DOC = DT6.DT6_DOC"
				cQuery += " AND DT5.DT5_SERIE = DT6.DT6_SERIE"
				cQuery += " AND DT5.D_E_L_E_T_ = ' ' "  
				cQuery += " AND DUE.DUE_FILIAL = '" + xFilial("DUE")+"'""
				cQuery += " AND DUE.DUE_DDD = DT5_DDD "
				cQuery += " AND DUE.DUE_TEL = DT5_TEL "
				cQuery += " AND DUE.D_E_L_E_T_ = ' ' "  
				cQuery += " AND SA1R.A1_FILIAL = '" + xFilial("SA1")+"'"
				cQuery += " AND SA1R.A1_COD    = DUE_CODCLI "
				cQuery += " AND SA1R.A1_LOJA   = DUE_LOJCLI "  
				cQuery += " AND SA1R.A1_TIPO <> 'X' "
				cQuery += " AND SA1R.D_E_L_E_T_ = ' ' "  
				cQuery += " AND SA1D.A1_FILIAL = '" + xFilial("SA1")+"'"  
				cQuery += " AND SA1D.A1_COD    = DT5_CLIDES "
				cQuery += " AND SA1D.A1_LOJA   = DT5_LOJDES "  
				cQuery += " AND SA1D.A1_TIPO   <> 'X' "
				cQuery += " AND SA1D.D_E_L_E_T_ = ' '
			
				cQuery := ChangeQuery(cQuery)
					
				cAliasDT6 := GetNextAlias()
				DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDT6,.F.,.T.)
					
				cPesoVge := Iif( (cAliasDT6)->PESO == 0, '1',  AllTrim(TransForm( (cAliasDT6)->PESO, PesqPict('DT6','DT6_VALFRE'))) )
				cPesoVge := StrTran(cPesoVge, '.','')
				cPesoVge := StrTran(cPesoVge, ',','.')
				(cAliasDT6)->(DbCloseArea())
					
				//Quantidade de documentos da viagem
				cQuery := " SELECT COUNT(DUD_DOC) QTDDOC "
				cQuery += "   FROM " + RetSqlName("DUD") + " DUD, "
				cQuery +=              RetSqlName("DT6") + " DT6, "
				cQuery +=              RetSqlName("DT5") + " DT5, "
				cQuery +=              RetSqlName("DUE") + " DUE, "
				cQuery +=              RetSqlName("SA1") + " SA1R,"
				cQuery +=              RetSqlName("SA1") + " SA1D "
				cQuery += " WHERE DUD.DUD_FILIAL = '"+xFilial("DUD")+"'"
				cQuery += " AND DUD.DUD_FILORI = '"+cFilOri+"'"
				cQuery += " AND DUD.DUD_VIAGEM = '"+cViagem+"'"
				cQuery += " AND DUD.DUD_STATUS <> '9' "
				cQuery += " AND DUD.D_E_L_E_T_ = ' ' "
				cQuery += " AND DT6.DT6_FILIAL = '"+xFilial("DT6") + "'"
				cQuery += " AND DT6.DT6_FILDOC = DUD.DUD_FILDOC"
				cQuery += " AND DT6.DT6_DOC = DUD.DUD_DOC"
				cQuery += " AND DT6.DT6_SERIE = DUD.DUD_SERIE"
				cQuery += " AND DT6.D_E_L_E_T_ = ' ' "
				cQuery += " AND DT5.DT5_FILIAL = '"+xFilial("DT5") + "'"
				cQuery += " AND DT5.DT5_FILDOC = DT6.DT6_FILDOC"
				cQuery += " AND DT5.DT5_DOC = DT6.DT6_DOC"
				cQuery += " AND DT5.DT5_SERIE = DT6.DT6_SERIE"
				cQuery += " AND DT5.D_E_L_E_T_ = ' ' "  
				cQuery += " AND DUE.DUE_FILIAL = '"+xFilial("DUE")+"'""
				cQuery += " AND DUE.DUE_DDD = DT5_DDD "
				cQuery += " AND DUE.DUE_TEL = DT5_TEL "
				cQuery += " AND DUE.D_E_L_E_T_ = ' ' "  
				cQuery += " AND SA1R.A1_FILIAL = '"+xFilial("SA1")+"'"
				cQuery += " AND SA1R.A1_COD    = DUE_CODCLI "
				cQuery += " AND SA1R.A1_LOJA   = DUE_LOJCLI "    
				cQuery += " AND SA1R.A1_TIPO <> 'X' "
				cQuery += " AND SA1R.D_E_L_E_T_ = ' ' "  
				cQuery += " AND SA1D.A1_FILIAL = '"+xFilial("SA1")+"'"  
				cQuery += " AND SA1D.A1_COD    = DT5_CLIDES "
				cQuery += " AND SA1D.A1_LOJA   = DT5_LOJDES " 
				cQuery += " AND SA1D.A1_TIPO   <> 'X' " 
				cQuery += " AND SA1D.D_E_L_E_T_ = ' '
					
				cQuery := ChangeQuery(cQuery)
				
				cAliasDUD := GetNextAlias()
				DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDUD,.F.,.T.) 
				nQtdDoc := (cAliasDUD)->QTDDOC
				(cAliasDUD)->(DbCloseArea()) 
					
				//Seleciona os documentos da viagem                                                                                          
				cQuery := " SELECT DUD_FILDOC, DUD_DOC, DUD_SERIE, DT6_QTDVOL, SA1R.A1_PESSOA PESSOAREM, SA1R.A1_EST ESTREM, SA1R.A1_COD_MUN COD_MUNREM, "
				cQuery += " SA1R.A1_CGC CGCREM, SA1R.A1_NOME NOMEREM, SA1R.A1_END ENDEREM, SA1R.A1_BAIRRO BAIRROREM , SA1R.A1_CEP CEPREM,"
				cQuery += " SA1D.A1_PESSOA PESSOADES, SA1D.A1_EST ESTDES, SA1D.A1_COD_MUN COD_MUNDES, SA1D.A1_CGC CGCDES, SA1D.A1_NOME NOMEDES, "
				cQuery += "  SA1D.A1_END ENDDES, SA1D.A1_BAIRRO BAIRRODES, SA1D.A1_CEP CEPDES "
				cQuery += "   FROM " + RetSqlName("DUD") + " DUD, "
				cQuery +=              RetSqlName("DT6") + " DT6, "
				cQuery +=              RetSqlName("DT5") + " DT5, "
				cQuery +=              RetSqlName("DUE") + " DUE, "
				cQuery +=              RetSqlName("SA1") + " SA1R, "
				cQuery +=              RetSqlName("SA1") + " SA1D "
				cQuery += " WHERE DUD.DUD_FILIAL = '"+xFilial("DUD")+"'"
				cQuery += " AND DUD.DUD_FILORI = '"+cFilOri+"'"
				cQuery += " AND DUD.DUD_VIAGEM = '"+cViagem+"'"
				cQuery += " AND DUD.DUD_STATUS <> '9' "
				cQuery += " AND DUD.D_E_L_E_T_ = ' ' "
				cQuery += " AND DT6.DT6_FILIAL = '"+xFilial("DT6") + "'"
				cQuery += " AND DT6.DT6_FILDOC = DUD.DUD_FILDOC"
				cQuery += " AND DT6.DT6_DOC = DUD.DUD_DOC"
				cQuery += " AND DT6.DT6_SERIE = DUD.DUD_SERIE"
				cQuery += " AND DT6.D_E_L_E_T_ = ' ' "
				cQuery += " AND DT5.DT5_FILIAL = '"+xFilial("DT5") + "'"
				cQuery += " AND DT5.DT5_FILDOC = DT6.DT6_FILDOC"
				cQuery += " AND DT5.DT5_DOC = DT6.DT6_DOC"
				cQuery += " AND DT5.DT5_SERIE = DT6.DT6_SERIE"
				cQuery += " AND DT5.D_E_L_E_T_ = ' ' "  
				cQuery += " AND DUE.DUE_FILIAL = '"+xFilial("DUE")+"'""
				cQuery += " AND DUE.DUE_DDD = DT5_DDD "
				cQuery += " AND DUE.DUE_TEL = DT5_TEL "
				cQuery += " AND DUE.D_E_L_E_T_ = ' ' "  
				cQuery += " AND SA1R.A1_FILIAL = '"+xFilial("SA1")+"'"
				cQuery += " AND SA1R.A1_COD    = DUE_CODCLI "
				cQuery += " AND SA1R.A1_LOJA   = DUE_LOJCLI "    
				cQuery += " AND SA1R.A1_TIPO <> 'X' "
				cQuery += " AND SA1R.D_E_L_E_T_ = ' ' "  
				cQuery += " AND SA1D.A1_FILIAL = '"+xFilial("SA1")+"'"  
				cQuery += " AND SA1D.A1_COD    = DT5_CLIDES "
				cQuery += " AND SA1D.A1_LOJA   = DT5_LOJDES " 
				cQuery += " AND SA1D.A1_TIPO   <> 'X' " 
				cQuery += " AND SA1D.D_E_L_E_T_ = ' '    
				cQuery += " ORDER BY DUD_DOC, DUD_SERIE
				cQuery := ChangeQuery(cQuery)
				
				cAliasDOC := GetNextAlias()
				DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDOC,.F.,.T.) 
				  
			Else//Viagens de Transferencia e Entrega
					
				//Somatoria do Peso da viagem      
				cQuery := " SELECT SUM(DT6_PESO) PESO "
				cQuery += "   FROM " + RetSqlName("DUD") + " DUD, "
				cQuery +=              RetSqlName("DT6") + " DT6, "
				cQuery +=              RetSqlName("SA1") + " SA1R, "
				cQuery +=              RetSqlName("SA1") + " SA1D, "
				cQuery += " WHERE DUD.DUD_FILIAL = '" + xFilial("DUD")+"'"
				cQuery += " AND DUD.DUD_FILORI = '" + cFilOri+"'"
				cQuery += " AND DUD.DUD_VIAGEM = '" + cViagem+"'"
				cQuery += " AND DUD.DUD_STATUS <> '9' "
				cQuery += " AND DUD.D_E_L_E_T_ = ' ' "
				cQuery += " AND DT6.DT6_FILIAL = '" + xFilial("DT6") + "'"
				cQuery += " AND DT6.DT6_FILDOC = DUD.DUD_FILDOC"
				cQuery += " AND DT6.DT6_DOC = DUD.DUD_DOC"
				cQuery += " AND DT6.DT6_SERIE = DUD.DUD_SERIE"
				cQuery += " AND DT6.D_E_L_E_T_ = ' ' "
				cQuery += " AND SA1R.A1_FILIAL = '" + xFilial("SA1")+"'"  
				cQuery += " AND SA1R.A1_COD  = DT6.DT6_CLIREM "
				cQuery += " AND SA1R.A1_LOJA = DT6.DT6_LOJREM "  
				cQuery += " AND SA1R.A1_TIPO <> 'X' "
				cQuery += " AND SA1R.D_E_L_E_T_ = ' ' "   
				cQuery += " AND SA1D.A1_FILIAL = '" + xFilial("SA1")+"'"  
				cQuery += " AND SA1D.A1_COD    = DT6.DT6_CLIDES "
				cQuery += " AND SA1D.A1_LOJA   = DT6.DT6_LOJDES "  
				cQuery += " AND SA1D.A1_TIPO <> 'X' "
				cQuery += " AND SA1D.D_E_L_E_T_ = ' ' "    
					
				cQuery := ChangeQuery(cQuery)
					
				cAliasDT6 := GetNextAlias()
				DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDT6,.F.,.T.)
					
				cPesoVge := Iif( (cAliasDT6)->PESO == 0, '1',  AllTrim(TransForm( (cAliasDT6)->PESO, PesqPict('DT6','DT6_VALFRE'))) )
				cPesoVge := StrTran(cPesoVge, '.','')
				cPesoVge := StrTran(cPesoVge, ',','.')  
				(cAliasDT6)->(DbCloseArea())
					
				//Quantidade de documentos da viagem
				cQuery := " SELECT COUNT(DUD_DOC) QTDDOC  "
				cQuery += "   FROM " + RetSqlName("DUD") + " DUD, "
				cQuery +=              RetSqlName("DT6") + " DT6, "
				cQuery +=              RetSqlName("SA1") + " SA1R, "
				cQuery +=              RetSqlName("SA1") + " SA1D, "
				cQuery += " WHERE DUD.DUD_FILIAL = '" + xFilial("DUD")+"'"
				cQuery += " AND DUD.DUD_FILORI = '" + cFilOri+"'"
				cQuery += " AND DUD.DUD_VIAGEM = '" + cViagem+"'"
				cQuery += " AND DUD.DUD_STATUS <> '9' "
				cQuery += " AND DUD.D_E_L_E_T_ = ' ' "
				cQuery += " AND DT6.DT6_FILIAL = '" + xFilial("DT6") + "'"
				cQuery += " AND DT6.DT6_FILDOC = DUD.DUD_FILDOC"
				cQuery += " AND DT6.DT6_DOC = DUD.DUD_DOC"
				cQuery += " AND DT6.DT6_SERIE = DUD.DUD_SERIE"
				cQuery += " AND DT6.D_E_L_E_T_ = ' ' "
				cQuery += " AND SA1R.A1_FILIAL = '" + xFilial("SA1")+"'"  
				cQuery += " AND SA1R.A1_COD  = DT6.DT6_CLIREM "
				cQuery += " AND SA1R.A1_LOJA = DT6.DT6_LOJREM "  
				cQuery += " AND SA1R.A1_TIPO <> 'X' "
				cQuery += " AND SA1R.D_E_L_E_T_ = ' ' "   
				cQuery += " AND SA1D.A1_FILIAL = '" + xFilial("SA1")+"'"  
				cQuery += " AND SA1D.A1_COD    = DT6.DT6_CLIDES "
				cQuery += " AND SA1D.A1_LOJA   = DT6.DT6_LOJDES "  
				cQuery += " AND SA1D.A1_TIPO <> 'X' "
				cQuery += " AND SA1D.D_E_L_E_T_ = ' ' "    
				
				cQuery := ChangeQuery(cQuery)
				
				cAliasDUD := GetNextAlias()
				DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDUD,.F.,.T.) 
				nQtdDoc := (cAliasDUD)->QTDDOC
				(cAliasDUD)->(DbCloseArea()) 
					
				//Seleciona os documentos da viagem
				cQuery := " SELECT DUD_FILDOC, DUD_DOC, DUD_SERIE, DT6_QTDVOL, SA1R.A1_PESSOA PESSOAREM, SA1R.A1_EST ESTREM, SA1R.A1_COD_MUN COD_MUNREM, "
				cQuery += " SA1R.A1_CGC CGCREM, SA1R.A1_NOME NOMEREM, SA1R.A1_END ENDEREM, SA1R.A1_BAIRRO BAIRROREM , SA1R.A1_CEP CEPREM,"
				cQuery += " SA1D.A1_PESSOA PESSOADES, SA1D.A1_EST ESTDES, SA1D.A1_COD_MUN COD_MUNDES, SA1D.A1_CGC CGCDES, SA1D.A1_NOME NOMEDES, "
				cQuery += " SA1D.A1_END ENDDES, SA1D.A1_BAIRRO BAIRRODES, SA1D.A1_CEP CEPDES "
				cQuery += " FROM " + RetSqlName("DUD") + " DUD, "
				cQuery +=            RetSqlName("DT6") + " DT6, "
				cQuery +=            RetSqlName("SA1") + " SA1R, "
				cQuery +=            RetSqlName("SA1") + " SA1D "
				cQuery += " WHERE DUD.DUD_FILIAL = '"+xFilial("DUD")+"'"
				cQuery += " AND DUD.DUD_FILORI = '"+cFilOri+"'"
				cQuery += " AND DUD.DUD_VIAGEM = '"+cViagem+"'"
				cQuery += " AND DUD.DUD_STATUS <> '9' "
				cQuery += " AND DUD.D_E_L_E_T_ = ' ' "
				cQuery += " AND DT6.DT6_FILIAL = '"+xFilial("DT6") + "'"
				cQuery += " AND DT6.DT6_FILDOC = DUD.DUD_FILDOC"
				cQuery += " AND DT6.DT6_DOC = DUD.DUD_DOC"
				cQuery += " AND DT6.DT6_SERIE = DUD.DUD_SERIE"
				cQuery += " AND DT6.D_E_L_E_T_ = ' ' "
				cQuery += " AND SA1R.A1_FILIAL = '"+xFilial("SA1")+"'"
				cQuery += " AND SA1R.A1_COD    = DT6.DT6_CLIREM "
				cQuery += " AND SA1R.A1_LOJA   = DT6.DT6_LOJREM "    
				cQuery += " AND SA1R.A1_TIPO <> 'X' "
				cQuery += " AND SA1R.D_E_L_E_T_ = ' ' "  
				cQuery += " AND SA1D.A1_FILIAL = '"+xFilial("SA1")+"'"  
				cQuery += " AND SA1D.A1_COD    = DT6.DT6_CLIDES "
				cQuery += " AND SA1D.A1_LOJA   = DT6.DT6_LOJDES " 
				cQuery += " AND SA1D.A1_TIPO   <> 'X' " 
				cQuery += " AND SA1D.D_E_L_E_T_ = ' '    
				cQuery += " ORDER BY DUD_DOC, DUD_SERIE
				cQuery := ChangeQuery(cQuery)
					
				cAliasDOC := GetNextAlias()
				DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDOC,.F.,.T.) 
			EndIf		
				
			If !lEstorno .Or. cParFil+cParVge != cFilOri+cViagem 

				If Empty(nCont)
					AAdd (aFieldsDoc,{'viagem.carga.peso', cPesoVge })  //Peso da viagem
					AAdd (aFieldsDoc,{'viagem.documento.qtde', Iif(nQtdDoc == 0, '1', AllTrim(Str(nQtdDoc)) )})//Quantidade de doctos.
				Else
					nAux := aScan(aFieldsDoc,{|x| x[1] == 'viagem.carga.peso'})  //Peso da viagem
					aFieldsDoc[nAux][2] := AllTrim(Str( Val(aFieldsDoc[nAux][2])+Val(cPesoVge) )) 
	
					nAux := aScan(aFieldsDoc,{|x| x[1] == 'viagem.documento.qtde'})  //Quantidade de doctos.
					aFieldsDoc[nAux][2] := AllTrim(Str( Val(aFieldsDoc[nAux][2])+Max(1,nQtdDoc) )) 
				EndIf

				If nQtdDoc > 0   
						(cAliasDOC)->(dbGoTop()) 
						
					While (cAliasDOC)->(!Eof())
					
						nCont++
								
						AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.tipo', cTipDoc})//Se Coleta = 11 -ordem de coleta  se transferencia ou entrega = 5=conhecimento
						AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.numero',  AllTrim((cAliasDOC)->DUD_FILDOC)+"-"+AllTrim((cAliasDOC)->DUD_DOC)})
						AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.serie', AllTrim((cAliasDOC)->DUD_SERIE)})
						AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.quantidade', AllTrim(cValToChar((cAliasDOC)->DT6_QTDVOL))})
							
						//Informacoes do Remetente
							cTpPessoa := Iif((cAliasDOC)->PESSOAREM=="F", '2', '1')
					  	cCodMun   := TMS120CDUF((cAliasDOC)->ESTREM, '1') + AllTrim((cAliasDOC)->COD_MUNREM)
						AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal.qtde', '2'})
						AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.tipo', '1'})
						AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.documento.tipo', AllTrim(cTpPessoa)})
						AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.documento.numero', AllTrim((cAliasDOC)->CGCREM)})
						AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.nome', SubStr(AllTrim((cAliasDOC)->NOMEREM),1,40)})
						AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.endereco.logradouro', SubStr(AllTrim((cAliasDOC)->ENDEREM),1,40)})
						AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.endereco.numero', '01'})
						AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.endereco.bairro', Substr(AllTrim((cAliasDOC)->BAIRROREM),1,30) })
						AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.endereco.cidade.ibge', AllTrim(cCodMun)})
						AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.endereco.cep', AllTrim((cAliasDOC)->CEPREM)})
									
						//Informacoes do Destinatario  
						cTpPessoa := Iif((cAliasDOC)->PESSOADES=="F", '2', '1')
						cCodMun   := 	TMS120CDUF((cAliasDOC)->ESTDES, '1') + AllTrim((cAliasDOC)->COD_MUNDES)
						AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.tipo', '2'})
						AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.documento.tipo', AllTrim(cTpPessoa) })
						AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.documento.numero', AllTrim((cAliasDOC)->CGCDES)})
						AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.nome', SubStr(AllTrim((cAliasDOC)->NOMEDES),1,40) })
						AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.endereco.logradouro', SubStr(AllTrim((cAliasDOC)->ENDDES),1,40) })
						AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.endereco.numero', '01'})
						AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.endereco.bairro', SubStr(AllTrim((cAliasDOC)->BAIRRODES),1,40) })
						AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.endereco.cidade.ibge', AllTrim(cCodMun)})
						AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.endereco.cep', AllTrim((cAliasDOC)->CEPDES)})
						
						(cAliasDOC)->(DbSkip())
					EndDo 
				Else   //Viagem vazia ou viagem sem informacao dos documentos.
					nCont++
					AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.tipo', '5'})
					AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.numero',  'Nao Declarado'}) 
					
					//Informacoes da Transportadora
					cCodMun   := AllTrim(SM0->M0_CODMUN)
					AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal.qtde', '2'})
					AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.tipo', '1'})
					AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.documento.tipo', '1'})
					AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.documento.numero', AllTrim(SM0->M0_CGC)})
					AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.nome', SubStr(AllTrim(SM0->M0_NOMECOM),1,40)})
					AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.endereco.logradouro', SubStr(AllTrim(SM0->M0_ENDCOB),1,40)})
					AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.endereco.numero', '01'})
					AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.endereco.bairro', Substr(AllTrim(SM0->M0_BAIRCOB),1,30) })
					AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.endereco.cidade.ibge', AllTrim(cCodMun)})
					AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal1.endereco.cep', AllTrim(SM0->M0_CEPCOB)})
							
					AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.tipo', '2'})
					AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.documento.tipo', '1' })
					AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.documento.numero', AllTrim(SM0->M0_CGC)})
					AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.nome', SubStr(AllTrim(SM0->M0_NOMECOM),1,40) })
					AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.endereco.logradouro', SubStr(AllTrim(SM0->M0_ENDCOB),1,40) })
					AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.endereco.numero', '01'})
					AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.endereco.bairro', SubStr(AllTrim(SM0->M0_BAIRCOB),1,40) })
					AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.endereco.cidade.ibge', AllTrim(cCodMun)})
					AAdd (aFieldsDoc,{'viagem.documento'+cValToChar(nCont)+'.pessoafiscal2.endereco.cep', AllTrim(SM0->M0_CEPCOB)})
				EndIf	
			EndIf	
			(cAliasDOC)->(DbCloseArea())
	
			nAdiFre := 0
			DTR->(dbGoTo(nRecDTR))
			nAdiFre := PamAdiFre(cFilOri, cViagem, DTR->DTR_CODVEI, .F. )
				
			nValBru += nAdiFre  
			If cParFil+cParVge == cFilOri+cViagem .And. nAdiFre > 0
				//-- Quando há taxas bancárias na primeira parcela, não a exclui. Apenas se for a parcela com valor mínimo (R$ 1,00).
			 	If lEstorno 
					aFieldsVlr := {}
					AAdd (aFieldsVlr,{'viagem.contratante.documento.numero'	, aRetCNPJ[1]   } )
					AAdd (aFieldsVlr,{'viagem.unidade.documento.tipo'		, aRetCNPJ[2]   } )
					AAdd (aFieldsVlr,{'viagem.unidade.documento.numero'		, aRetCNPJ[3]   } )
					AAdd (aFieldsVlr,{'viagem.antt.ciot.numero'				, AllTrim(cCIOT)} )
			 		
					AAdd (aFieldsVlr,{'viagem.parcela.qtde'					, '1' 			} )
					AAdd (aFieldsVlr,{'viagem.parcela1.numero.cliente'		, cParAdi		} )
					AAdd (aFieldsVlr,{'viagem.parcela1.status.id'			, '4' 			} ) //--Parcela Excluída
			 	ElseIf !lEstorno
				 	//--Inicia montagem do array de campos para Inclusão de parcelas
					aFieldsVlr := {}
					AAdd (aFieldsVlr,{'viagem.contratante.documento.numero'	, aRetCNPJ[1]   } )
					AAdd (aFieldsVlr,{'viagem.unidade.documento.tipo'		, aRetCNPJ[2]   } )
					AAdd (aFieldsVlr,{'viagem.unidade.documento.numero'		, aRetCNPJ[3]   } )
					AAdd (aFieldsVlr,{'viagem.antt.ciot.numero'				, AllTrim(cCIOT)} )

					AAdd (aFieldsVlr,{'viagem.parcela.qtde', AllTrim(Str(++nParcela))})
					AAdd (aFieldsVlr,{'viagem.parcela'+AllTrim(Str(nParcela))+'.efetivacao.tipo', '2'})//Efetivacao automatica
					AAdd (aFieldsVlr,{'viagem.parcela'+AllTrim(Str(nParcela))+'.valor', StrTran( AllTrim(TransForm( nAdiFre , '@E 999999999.99')), ',','.' )})

					If FindFunction('TmsFavPar')
						cTipFav := TmsFavPar(aForPag,lExistFav,nQtdFav,"1") // busca o  favorecido da parcela de Adiantamento
					Else
						If nQtdFav > 1
							cTipFav := '2'
						Else
							cTipFav := '1'
						EndIf
					EndIf
					If !Empty(DTR->DTR_CIOT)						
						AAdd (aFieldsVlr,{'viagem.parcela'+AllTrim(Str(nParcela))+'.subtipo', '1'}) //1=Adiantamento
						AAdd (aFieldsVlr,{'viagem.parcela'+AllTrim(Str(nParcela))+'.status.id', '1'})//Pendente
						AAdd (aFieldsVlr,{'viagem.parcela'+AllTrim(Str(nParcela))+'.data', SubStr(DtoS(dDataBase),7,2) + '/' + SubStr(DtoS(dDataBase),5,2) + '/' + SubStr(DtoS(dDataBase),1,4)})
						AAdd (aFieldsVlr,{'viagem.parcela'+AllTrim(Str(nParcela))+'.favorecido.tipo.id', cTipFav }) //favorecido da parcela
					Else
						AAdd (aFieldsVlr,{'viagem.parcela'+AllTrim(Str(nParcela))+'.subtipo', '1'}) //1=Adiantamento
						AAdd (aFieldsVlr,{'viagem.parcela'+AllTrim(Str(nParcela))+'.data', SubStr(DtoS(dDataBase),7,2) + '/' + SubStr(DtoS(dDataBase),5,2) + '/' + SubStr(DtoS(dDataBase),1,4)})
						AAdd (aFieldsVlr,{'viagem.parcela'+AllTrim(Str(nParcela))+'.favorecido.tipo.id', cTipFav }) //favorecido da parcela
					EndIf
					AAdd (aFieldsVlr,{'viagem.parcela'+AllTrim(Str(nParcela))+'.numero.cliente',  cParAdi})//Adiantamento
						
					cCodBan	:= PamCodBan(DUP->DUP_CODMOT, AllTrim(cIdOpe1))
					nTxAdBan:= PamTaxTot(cCodBan, nQtdSaq, nQtdTra)
						
					AAdd (aFieldsVlr,{'viagem.frete.valor.bruto', StrTran( AllTrim(TransForm( nValBru  , '@E 999999999.99')), ',','.' )})
						
				EndIf
			EndIf
			
			DTR->(dbGoTo(nRecDTR))
		
			If lRet .And. (cAliasDTR)->(Eof())

				//-- Quando estorna a única viagem do CIOT por período, exclui-se o contrato
				If 	lEstorno .And. lExcContr
					lRet := PamExcCtr(cParFil, cParVge, aRetCNPJ) 
				Else
				    //-- Inclusão dos doctos no CIOT
					If (lRet := PamAltCtWs(aFieldsDoc, cIdCli)) //Chamada da Função - Inclusão de doctos)
						If !Empty(aFieldsVlr)
							If !lEstorno 
								//-- Inclusão das parcelas no CIOT
								lRet := PamAltVrWs(aFieldsVlr, cIdCli)  //Chamada da Função - Inclusão de parcelas
							Else
								//Chama a rotina que consulta a parcela da viagem
								nRetParc := PamConParc(cFilOri, cViagem, aRetCNPJ, cParAdi )
								
								//-- Exclusão de parcela de adiantamento
								If nRetParc == 1 .Or. nRetParc == 3   //Parcela pendente ou bloqueada.
									lRet := PamAltStPa(aFieldsVlr)
								ElseIf nRetParc != 0 .And. nRetParc != 4 //Nao encontrou parcela. ou está excluida
									Help('',1,'TMSPAM014',,,3,0) //"Parcela ja efetivada no sistema", " Pamcard, estorno da liberação","do contrato não permitida."
									lRet := .F.
								EndIf
							EndIf
						EndIf					
					EndIf					
				EndIf
				//-- Se houver valor de pedágio, trata-o em novas viagens					
				If lRet .And. DTR->DTR_VALPDG > 0
					If lDTRTPSPDG
						cTipPagPDG := DTR->DTR_TPSPDG
					Else
						cTipPagPDG := DUP->DUP_TPSPDG
					EndIf
					
					If !lEstorno .And. cTipPagPDG == '5' //Pedagio pago pelo sistema Pamcard
						//-- Para CIOT por período, o valor do pedágio será lançado em outra viagem na pamcard, por limitações do sistema da Pamcard
						lRet := PamIncViag(cFilOri, cViagem, aRetCNPJ, .T.)
						
					ElseIf lEstorno .And. DTQ->(FieldPos("DTQ_IDPDG")) > 0 .And. !Empty(DTQ->DTQ_IDPDG)
						//-- Para estorno de viagem em CIOT por período
						lRet := PamExcVge(cFilOri, cViagem, aRetCNPJ)
					EndIf
				EndIf

				If lRet
					//-- Quando estorna a única viagem do CIOT por período, cancela o CIOT
					If 	lEstorno .And. lExcContr
						DJL->(DbSetOrder(1)) //-- DJL_FILIAL+DJL_CIOT+DJL_CODVEI
						If DJL->(DbSeek(xFilial("DJL")+cCIOT+DTR->DTR_CODVEI))
							RecLock("DJL",.F.)
							DJL->DJL_STATUS := "9" //--Cancelado
							MsUnLock()
						EndIf
					EndIf
					
					RecLock('DTR',.F.)			
					DTR->DTR_CIOT   := Iif(lEstorno,"",cCIOT)		
					MsUnLock()

					DTQ->(dbGoTo(nRecDTQ))
					RecLock('DTQ',.F.)
					DTQ->DTQ_IDOPE  := Iif(lEstorno,"",cIdOpe) //Retorno do Sistema Pamcard  - viagem.id
					DTQ->DTQ_IDCLI := Iif(lEstorno,"",cIdCli)  //Retorno do Sistema Pamcard  - viagem.id.cliente

					If lEstorno .And. DTR->DTR_VALPDG > 0 .And. DTQ->(FieldPos("DTQ_IDPDG")) > 0 .And. !Empty(DTQ->DTQ_IDPDG)
					 	DTQ->DTQ_IDPDG := "" //CIOT por período => Campo que guarda a viagem com o Vr. do Pedágio
					EndIf
					
					MsUnLock()
				EndIf
			EndIf
		EndIf
	EndIf

 	If (cAliasDTR)->(!Eof())
 		(cAliasDTR)->(DbSkip())
 	Else
 		cParVge := cParFil := ""
 	EndIf
EndDo
(cAliasDTR)->(DbCloseArea())

RestArea(aAreaDTR)
RestArea(aAreaDUP)
RestArea(aAreaDA3)
RestArea(aAreaSA2)
RestArea(aAreaDTQ)
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
Function PamAltCtWs(aFields, cIdCli)
Local nCount   := 1
Local nCount2  := 2
Local oObjPam
Local cRetCert := '' //Certificado Digital
Local lRet     := .T.
Local aMsgErr  := {}
Local aCertif  := {}

Default aFields:= {}
Default cIdCli := ""

If Empty(cIdCli)
	cIdCli := PamDtHora()
EndIf

If lRet := PamCertDig('02', @cRetCert, aCertif)

	If nTipoCerti == 2
		If ExistFunc('aPamAltCtWs')
			lRet := aPamAltCtWs(aFields, cIdCli, aCertif)
		Else
			MsgStop(STR0025, STR0001) //--"Para utilização do Certificado com extensão .PFX é necessário atualizar o programa: PamcardNew.prw"###"Atenção"				
			lRet := .F.
		EndIf
	ElseIf nTipoCerti == 1

	
		oObjPam := WSWSPamcardDocumentService():New()
		oObjPam:oWSarg0:ccertificate := cRetCert
		oObjPam:oWSarg0:ccontext := 'UpdateFreightContract'
		oObjPam:_URL := PamUrlWs()
		oObjPam:oWSarg0:oFieldTOs := WSPamcardDocumentService_ArrayOf_tns1_FieldTO():New()
		
		AAdd(oObjPam:oWSarg0:oFieldTOs:oFieldTo , WSPamcardDocumentService_FieldTO():New())
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[1]:ckey := 'viagem.id.cliente'
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[1]:cvalue:= cIdCli		
				
		For nCount := 1 To Len(aFields)
			If !Empty(aFields[nCount][2])
				AAdd(oObjPam:oWSarg0:oFieldTOs:oFieldTo , WSPamcardDocumentService_FieldTO():New())
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:ckey := aFields[nCount][1]
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:cvalue:= aFields[nCount][2]
				nCount2++
			EndIf
		Next nCount
		
		WsdlDbgLevel(3)
		
		If oObjPam:execute()
			If oObjPam:oWSResponseTo:oReturn:oFieldTo[1]:cValue <> "0"								
				Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oReturn:oFieldTo[2]:cValue,4,0)
				lRet := .F.
			EndIf
		Else
			aMsgErr := TMSErrOper('02',, '2') 
			Help("",1, "TMSPAM003",, STR0011,4,0)//"Verifique se as informacoes no cadastro da operadora estão corretas."
			lRet := .F.
		EndIf
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
Function PamAltVrWs(aFields, cIdCli)
Local nCount   := 1
Local nCount2  := 2
Local oObjPam
Local cRetCert := '' //Certificado Digital
Local lRet     := .T.
Local aMsgErr  := {}
Local aCertif  := {}

Default aFields:= {}
Default cIdCli := ""

If Empty(cIdCli)
	cIdCli := PamDtHora()
EndIf

If lRet := PamCertDig('02', @cRetCert, aCertif)
	
	If nTipoCerti == 2
		lRet := aPamAltVrWs(aFields, cIdCli, aCertif)
	ElseIf nTipoCerti == 1

		oObjPam := WSWSPamcardDocumentService():New()
		oObjPam:oWSarg0:ccertificate := cRetCert
		oObjPam:oWSarg0:ccontext := 'UpdateValuesFreightContract'
		oObjPam:_URL := PamUrlWs()
		oObjPam:oWSarg0:oFieldTOs := WSPamcardDocumentService_ArrayOf_tns1_FieldTO():New()
		
		AAdd(oObjPam:oWSarg0:oFieldTOs:oFieldTo , WSPamcardDocumentService_FieldTO():New())
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[1]:ckey := 'viagem.id.cliente'
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[1]:cvalue:= cIdCli		
				
		For nCount := 1 To Len(aFields)
			If !Empty(aFields[nCount][2])
				AAdd(oObjPam:oWSarg0:oFieldTOs:oFieldTo , WSPamcardDocumentService_FieldTO():New())
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:ckey := aFields[nCount][1]
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:cvalue:= aFields[nCount][2]
				nCount2++
			EndIf
		Next nCount
		
		WsdlDbgLevel(3)
		
		If oObjPam:execute()
			If oObjPam:oWSResponseTo:oReturn:oFieldTo[1]:cValue <> "0"							
				Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oReturn:oFieldTo[2]:cValue,4,0)
				lRet := .F.
			EndIf
		Else
			aMsgErr := TMSErrOper('02',, '2') 
			Help("",1, "TMSPAM003",, STR0011,4,0)//"Verifique se as informacoes no cadastro da operadora estão corretas."
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamIdAdto  ³Autor: ³ Daniel Carlos Leme     ³Data: ³17/08/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Retorna o IDCNAB do adiantamento da viagem                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamIdAdto() 		                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS			                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamIdAdto(cFilOri, cViagem, cCodVei)
Local aArea		:= GetArea()
Local cDesPdg	:= SuperGetMv("MV_DESPDG",,"")
Local cRet		:= '1'
Local cAliasQry	:= ""
Local cQuery	:= ""
Local cDesABST  := Padr( SuperGetMV('MV_DESABST',,''), Len( DT7->DT7_CODDES ) ) // Codigo de Despesa de Abastecimento

Default cFilOri := ''
Default cViagem := ''
Default cCodVei := ''

cAliasQry  := GetNextAlias()
cQuery += "SELECT SDG.DG_NUMSEQ"
cQuery += " FROM " + RetSqlName("SDG") + " SDG, "
cQuery += RetSqlName("DT7") + " DT7 "
cQuery += " WHERE "
cQuery += " SDG.DG_FILIAL  = '" + Iif(Empty(xFilial("SDG")),xFilial('SDG'),cFilOri) + "' AND "
cQuery += " SDG.DG_FILORI  = '" + cFilOri + "' AND "
cQuery += " SDG.DG_VIAGEM  = '" + cViagem + "' AND "
cQuery += " SDG.DG_CODVEI  = '" + cCodVei + "' AND "
cQuery += " SDG.DG_ORIGEM <> 'DTY' AND "
cQuery += " SDG.D_E_L_E_T_ = ' ' AND "
cQuery += " DT7.DT7_FILIAL = '" + xFilial("DT7") + "' AND "
cQuery += " DT7.DT7_CODDES = SDG.DG_CODDES AND "
If !Empty(cDesPdg)
	cQuery += " DT7.DT7_CODDES <> '" + cDesPdg + "' AND "
Endif
If !Empty(cDesABST)  // Tag de Abastecimento não deve fazer parte do adiantamento de frete, nem do total do frete
	cQuery += " DT7.DT7_CODDES <> '" + cDesABST + "' AND "
Endif
cQuery += " DT7.DT7_MOVBCO = '1' AND"
cQuery += " DT7.D_E_L_E_T_ = ' '  "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
If (cAliasQry)->(!Eof()) .AND. !Empty((cAliasQry)->DG_NUMSEQ)
	cRet := (cAliasQry)->DG_NUMSEQ
EndIf

(cAliasQry)->(dbCloseArea())

RestArea(aArea)
Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamVgsCiot ³Autor: ³ Daniel Carlos Leme     ³Data: ³17/08/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Retorna array com viagens utilizando um CIOT                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamVgsCiot() 		                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS			                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamVgsCiot(cCiot)
Local aRet  := {}
Local aArea := GetArea()

Local cAliasQry, cQuery 

cAliasQry := GetNextAlias()
cQuery := " SELECT DTR_FILORI, DTR_VIAGEM "
cQuery += " FROM " + RetSqlName("DTR")
cQuery += " WHERE DTR_FILIAL = '" + xFilial("DTR") + "'"
cQuery += "   AND D_E_L_E_T_ = ' '"
cQuery += "   AND DTR_CIOT   = '" + cCiot + "'"
cQuery += " GROUP BY DTR_FILORI, DTR_VIAGEM "
cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
Do While (cAliasQry)->(!Eof())
	aAdd(aRet,{(cAliasQry)->DTR_FILORI,(cAliasQry)->DTR_VIAGEM})
	(cAliasQry)->(DbSkip())
EndDo
(cAliasQry)->(dbCloseArea())
RestArea(aArea)
Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamEncCIOT ³Autor: ³ Daniel Carlos Leme     ³Data: ³17/08/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Chama o WS para encerramento do CIOT por Periodo              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamEncCIOT() 		                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS			                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamEncCiot(cCiot,cCodVei)
Local lRet         := .T.
Local aFields      := {}
Local aRetWs       := Array(3)
Local aAreaDTR     := DTR->(GetArea())
Local aArea        := GetArea()
Local aViagens     := PamVgsCiot(cCiot)
Local nValBru      := 0
Local nI,cAliasQry,cQuery,aParCTC

If (lRet := !Empty(aViagens))
	For nI := 1 To Len(aViagens)
		cAliasQry := GetNextAlias()
		cQuery := " SELECT R_E_C_N_O_ NREG "
		cQuery += " FROM " + RetSqlName("DTY")
		cQuery += " WHERE DTY_FILIAL = '" + xFilial("DTY") + "'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		cQuery += "   AND DTY_FILORI = '" + aViagens[nI][1] + "'"
		cQuery += "   AND DTY_VIAGEM = '" + aViagens[nI][2] + "'"
	
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		lRet := (cAliasQry)->(!Eof())
		
		Do While lRet .And. (cAliasQry)->(!Eof())
			DTY->(dbGoto((cAliasQry)->NREG))
			lRet := DTY->(DTY_STATUS=='4' .Or. (Empty(DTY_STATUS) .And. !Empty(DTY_NUMPC))) .Or.; //-- "Contrato Quitado com Ped. Compra"
			        DTY->(DTY_STATUS=='5')
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
		
		If !lRet
			Exit
		EndIf
	Next nI 
EndIf

If lRet
	aRetCNPJ   := PamCNPJEmp("02", cFilAnt) //Função para obter CNPJ da contrante e filial  
	
	aFields := {}
	AAdd (aFields,{'viagem.contratante.documento.numero', aRetCNPJ[1]    } )
	AAdd (aFields,{'viagem.unidade.documento.tipo'      , aRetCNPJ[2]    } )
	AAdd (aFields,{'viagem.unidade.documento.numero'    , aRetCNPJ[3]    } )
	AAdd (aFields,{'viagem.antt.ciot.numero'            , AllTrim(cCiot) } )
	AAdd (aFields,{'viagem.frete.item.qtde'             , '0'            } )
	
	aParCTC := PamGetParc(aViagens[1][1], aViagens[1][2], aRetCNPJ, Posicione("DTQ",2,xFilial("DTQ")+aViagens[1][1]+aViagens[1][2],"DTQ_IDOPE"), 2)
	aEval(aParCTC,{|x| nValBru += x[2] })
	AAdd (aFields,{'viagem.frete.valor.bruto'           , StrTran( AllTrim(TransForm( nValBru, '@E 999999999.99')), ',','.' )})

	If (lRet := PamEncWs(aFields,aRetWs))
		DJL->(DbSetOrder(1)) //-- DJL_FILIAL+DJL_CIOT+DJL_CODVEI
		If DJL->(DbSeek(xFilial("DJL")+cCiot+cCodVei))
			RecLock("DJL",.F.)
			DJL->DJL_STATUS := "3" //--Encerrado
			MsUnLock()
		EndIf
	EndIf
Else
	Help("",1, "TMSPAM003",, STR0020,4,0)//-- "O CIOT não pode ser encerrado. Verifique se todas as viagens estão com contrato quitado"
EndIf	

RestArea(aAreaDTR)
RestArea(aArea)

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
Function PamEncWs(aFields, aRet)
Local nCount   := 1
Local nCount2  := 1
Local oObjPam
Local cRetCert := '' //Certificado Digital
Local lRet     := .T.
Local aCertif  := {}

Default aFields:= {}
Default aRet   := {}

If lRet := PamCertDig('02', @cRetCert, aCertif)
	If nTipoCerti == 2
		If ExistFunc('aPamEncWs')
			lRet := aPamEncWs(aFields, aCertif)
		Else
			MsgStop(STR0025, STR0001) //--"Para utilização do Certificado com extensão .PFX é necessário atualizar o programa: PamcardNew.prw"###"Atenção"				
		EndIf	
	ElseIf nTipoCerti == 1
	
		oObjPam := WSWSPamcardDocumentService():New()
		oObjPam:oWSarg0:ccertificate := cRetCert
		oObjPam:oWSarg0:ccontext := 'CloseFreightContract'
		oObjPam:_URL := PamUrlWs()
		oObjPam:oWSarg0:oFieldTOs := WSPamcardDocumentService_ArrayOf_tns1_FieldTO():New()
		
		For nCount := 1 To Len(aFields)
			If !Empty(aFields[nCount][2])
				AAdd(oObjPam:oWSarg0:oFieldTOs:oFieldTo , WSPamcardDocumentService_FieldTO():New())
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:ckey := aFields[nCount][1]
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:cvalue:= aFields[nCount][2]
				nCount2++
			EndIf
		Next nCount
		
		WsdlDbgLevel(3)
		
		If oObjPam:execute()
			If oObjPam:oWSResponseTo:oReturn:oFieldTo[1]:cValue == "0"
				lRet := .T.
			Else
				Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oReturn:oFieldTo[2]:cValue,4,0)
				lRet := .F.
			EndIf
		Else
			Help("",1, "TMSPAM003",, STR0011,4,0)//"Verifique se as informacoes no cadastro da operadora estão corretas."
			lRet := .F.
		EndIf
	EndIf

EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PamRetPos ºAutor  ³Ramon Neves     º 	   Data ³  19/05/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que retorna posição da string no array		        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMS - INTEGRACAO VIA WEB SERVICE SISTEMA PAMCARD  		  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PamRetPos(oFieldTo, cStrPesq)
Local nX := 0

For nX := 1 To Len(oFieldTo)
	If oFieldTo[nX]:cKey  == cStrPesq
		Exit
	EndIf
Next

Return nX
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  PamValTot ºAutor  ³Leandro Paulino º 	   Data ³  02/03/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que retorna posição da string no array		      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMS - Retorna os valores do do contrato ou da viagem		  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PamValTot(nTipo,cFilOri, cViagem, cContrat,nVlrBru,nIRRF,nSEST,nINSS,nISS,nPIS,nCOFINS,nCSLL,nAdiFre)

Local cAliasDTY := GetNextAlias()
Local cQuery 	:= ""
Local aAreaDTY  := DTY->(GetArea())

Default nTipo	:= 1
Default cFilOri	:= ''
Default cViagem	:= ''
Default cContrat:= ''
Default nVlrBru	:= 0
Default nIRRF	:= 0
Default nSEST	:= 0
Default nINSS	:= 0
Default nISS	:= 0
Default nPIS	:= 0
Default nCOFINS	:= 0
Default nCSLL	:= 0
Default nAdiFre	:= 0

//Pegar os valores de frete, de todos os contratos da viagem. No PAMCARD todos farão parte do mesmo contrato.
cQuery := " SELECT SUM(DTY_VALFRE) DTY_VALFRE, SUM(DTY_IRRF) DTY_IRRF, SUM(DTY_INSS) DTY_INSS,"
cQuery += "        SUM(DTY_SEST) DTY_SEST, SUM(DTY_ISS) DTY_ISS, SUM(DTY_PIS) DTY_PIS, "
cQuery += "        SUM(DTY_COFINS) DTY_COFINS, SUM(DTY_CSLL) DTY_CSLL, SUM(DTY_ADIFRE) DTY_ADIFRE"
cQuery += "    FROM " + RetSqlName("DTY")
cQuery += "    WHERE DTY_FILIAL = '" + xFilial("DTY")  + "' "
cQuery += "      AND DTY_FILORI = '" + cFilOri         + "'"		
If nTipo == 1
	cQuery += "      AND DTY_NUMCTC = '" + cContrat    + "'"
Else	 		
	cQuery += "      AND DTY_VIAGEM = '" + cViagem 	   + "'" 	
EndIf
cQuery += "      AND D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDTY, .F., .T.)

If (cAliasDTY)->(!Eof())
	nVlrBru	     :=  (cAliasDTY)->DTY_VALFRE
	nIRRF		 :=  (cAliasDTY)->DTY_IRRF
	nSEST		 :=  (cAliasDTY)->DTY_SEST
	nINSS 	     :=  (cAliasDTY)->DTY_INSS
	nISS	   	 :=  (cAliasDTY)->DTY_ISS
	nPIS		 :=  (cAliasDTY)->DTY_PIS
	nCOFINS      :=  (cAliasDTY)->DTY_COFINS
	nCSLL        :=  (cAliasDTY)->DTY_CSLL
	nAdiFre      :=  (cAliasDTY)->DTY_ADIFRE  
EndIf
(cAliasDTY)->( DbCloseArea() )

RestArea(aAreaDTY)

Return Nil
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  PamValTot ºAutor  ³Leandro Paulino º 	   Data ³  20/04/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que retorna o Id do Tipo de Favorecido		      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMS - Integração TMS x Pamcard							  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PamRetFvId(cFilOri, cViagem, lExistFav)

Local lOk 		:= .F.
Local cFavId	:= ''

Default cFilOri 	:= ''
Default	cViagem 	:= ''
Default lExistFav	:= .F.

	DUP->(DbSetOrder(1))
	If DUP->(DbSeek(xFilial('DUP')+cFilOri + cViagem))
		lOk := PamCondut (cFilOri, cViagem)
	EndIf		
	//Se o Tipo de Pagamento do Saldo for Cartão o ID enviado sera do proprietario do veiculo .1.
	If DUP->DUP_FORPAG == '1' .Or. !lExistFav
		cFavId := '1'
	Else //Se o Tipo do Pagamento do For Conta, verifica se Favorecido
		cFavId := '2'	//Se existir manda o subcontratado (favorecido)
	EndIf	

Return cFavId

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PamRetIDPa ºAutor  ³Leandro Paulino º   Data ³  31/05/2018  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que Retorna o Id da Parcela no SIGATMS, quando o TMSº±±
±±º			 ³ estiver integrado com Protheus o Id de cada parcela será o º±±
±±º			 ³ E2_IDCNAB 												  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMS - Integração TMS x Pamcard							  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamRetIDPa (cPrefixo, cTipCTC, cFilOri, cContrat)

Local cAliasDTY	:= 	GetNextAlias()
Local cQuery	:= ''
Local cNumCli   := ''
Local cCodDes	:= SuperGetMv("MV_DESCTC",,"")
Local aArea  	:= GetArea()

Default cPrefixo:= ''
Default CTipCTC	:= ''
Default cFilOri	:= ''
Default cContrat:= ''

cQuery := " SELECT SDG.DG_NUMSEQ "	
cQuery += "   FROM " + RetSqlName("DTY") + " DTY "
cQuery += "   JOIN " + RetSqlName("SDG") + " SDG "
cQuery += "      ON     SDG.DG_FILIAL  = '" + Iif(Empty(xFilial("SDG")), xFilial('SDG'), cFilOri) + "'"
cQuery += " 		AND SDG.DG_FILORI  = DTY.DTY_FILORI "
cQuery += " 		AND SDG.DG_VIAGEM  = DTY.DTY_VIAGEM "
cQuery += " 		AND SDG.DG_CODVEI  = DTY.DTY_CODVEI "
cQuery += " 		AND SDG.DG_DOC     = DTY.DTY_DOCSDG "
cQuery += " 		AND SDG.DG_ORIGEM  = 'DTY'"
If !Empty(cCodDes)
	cQuery += "		AND SDG.DG_CODDES  = '" + cCodDes + "'"
EndIf
cQuery += "   WHERE DTY.DTY_FILIAL = '" + xFilial("DTY") + "'"
cQuery += "     AND DTY.DTY_FILORI = '" + cFilOri + "'"		
cQuery += "     AND DTY.DTY_NUMCTC = '" + cContrat + "'" 	
cQuery += "     AND DTY.D_E_L_E_T_ = ' ' "
cQuery += "     AND SDG.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY SDG.DG_NUMSEQ"	
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDTY, .F., .T.)
cNumCli := (cAliasDTY)->(DG_NUMSEQ)
(cAliasDTY)->( dbCloseArea() )

RestArea(aArea)
FwFreeObj(aArea)

Return cNumCli

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  PamCondut  ºAutor  ³ Katia Bianchi   º   Data ³  05/07/2018  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que Retorna o condutor principal da viagem          º±±
±±º			 ³                                                            º±±
±±º			 ³                   										  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMS - Integração TMS x Pamcard							  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamCondut (cFilOri, cViagem)

Local cAliasDUP	:= 	GetNextAlias()
Local lRet 		:= .F.
Local cQuery	:= ''

Default cFilOri	:= ''
Default cViagem:= ''
	
cQuery := " SELECT DUP.R_E_C_N_O_  RECNO"	
cQuery += "   FROM " + RetSqlName("DUP") + " DUP "
cQuery += "   WHERE DUP.DUP_FILIAL = '" + xFilial("DUP") + "'"
cQuery += "     AND DUP.DUP_FILORI = '" + cFilOri + "'"		
cQuery += "     AND DUP.DUP_VIAGEM = '" + cViagem + "'"	
cQuery += "     AND DUP.DUP_CONDUT = '1'" 	
cQuery += "     AND DUP.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDUP, .F., .T.)
If (cAliasDUP)->(!EOF())
	lRet := .T. 
	DUP->(dbGoTo((cAliasDUP)->RECNO))
Endif
(cAliasDUP)->( dbCloseArea() )

Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamGetFav ³ Autor:³ Katia Bianchi          ³ Data:³22/08/2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Obtem o tipo de favorecido do cartão  no sistema Pamcard.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ExpC1 = Filial Origem da Viagem                               ³±±
±±³           ³ExpC2 = Numero da Viagem                                      ³±±
±±³           ³ExpA1 = Dados da Transportadora                               ³±±
±±³           ³ExpC3 = Id Ope                                                ³±±
±±³           ³ExpC4 = nAcao (1=Inclusao;2=Estorno)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamGetFav(ExpC1, ExpC2, ExpA1, Expc3, Expc4)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS.												         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamGetFav(cFilOri, cViagem, aRetCNPJ, cIdOpe, cCard)
Local aFields    := {}
Local cTipFav    := '' //numero da parcela do Saldo a pagar ou complemento

Default cCard 	 := ''

AAdd (aFields,{'viagem.id', AllTrim(cIdOpe)})
AAdd (aFields,{'viagem.contratante.documento.numero',aRetCNPJ[1]} )
AAdd (aFields,{'viagem.unidade.documento.tipo', aRetCNPJ[2] })
AAdd (aFields,{'viagem.unidade.documento.numero', aRetCNPJ[3]} )
AAdd (aFields,{'viagem.antt.ciot.numero', AllTrim(DTR->DTR_CIOT)} )
AAdd (aFields,{'viagem.obter.favorecido', 'S'} )

cTipFav := PamTipFav(aFields,cCard) //Chamada da Função

Return cTipFav

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o:    ³PamTipFav ³ Autor:³ Katia Bianchi           ³ Data:³22/08/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o: ³Pesquisa o tipo de favorecido no sistema Pamcard              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe:   ³PamTipFav()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso:       ³ TMS			                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PamTipFav(aFields,cCard)  
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
Local aCertif	:= {}

Default aFields := {}
Default cCard 	:= ""

If lRet := PamCertDig('02', @cRetCert, aCertif)
	If nTipoCerti == 2
		If ExistFunc('aPamTipFav')
			cTipFav := aPamTipFav( aFields, cCard, aCertif )  
		Else
			MsgStop(STR0025, STR0001) //--"Para utilização do Certificado com extensão .PFX é necessário atualizar o programa: PamcardNew.prw"###"Atenção"
		EndIf
	ElseIf lRet
		oObjPam := WSWSPamcardDocumentService():New()
		oObjPam:oWSarg0:ccertificate := cRetCert
		oObjPam:oWSarg0:ccontext := 'FindFreightContract'
		oObjPam:_URL := PamUrlWs()
		oObjPam:oWSarg0:oFieldTOs := WSPamcardDocumentService_ArrayOf_tns1_FieldTO():New()
		
		For nCount := 1 To Len(aFields)
			If !Empty(aFields[nCount][2])
				AAdd(oObjPam:oWSarg0:oFieldTOs:oFieldTo, WSPamcardDocumentService_FieldTO():New())
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:ckey := aFields[nCount][1]
				oObjPam:oWSarg0:oFieldTOs:oFieldTo[nCount2]:cvalue := aFields[nCount][2]
				nCount2++
			EndIf
		Next nCount
		
		WsdlDbgLevel(3)

		If oObjPam:execute()
			If oObjPam:oWSResponseTo:oReturn:oFieldTo[1]:cValue == "0"  	
				nPos := Ascan(oObjPam:oWSResponseTo:oReturn:oFieldTo,{|x| AllTrim(x:cKey)=="viagem.favorecido.qtde"})
				nQtdFav := Val(oObjPam:oWSResponseTo:oReturn:oFieldTo[nPos]:cValue)
				For nFav := 1  To nQtdFav			
					nPos 	 := Ascan(oObjPam:oWSResponseTo:oReturn:oFieldTo,{|x| AllTrim(x:cKey)=="viagem.favorecido"+Alltrim(Str(nFav))+".cartao.numero"}) 
					cCartao := Iif(nPos >0,AllTrim(oObjPam:oWSResponseTo:oReturn:oFieldTo[nPos]:cValue),'')
					If cCard == cCartao
						nPos 	 := Ascan(oObjPam:oWSResponseTo:oReturn:oFieldTo,{|x| AllTrim(x:cKey)=="viagem.favorecido"+Alltrim(Str(nFav))+".tipo"}) 
						cTipFav  := Iif(nPos >0,AllTrim(oObjPam:oWSResponseTo:oReturn:oFieldTo[nPos]:cValue),'')
					EndIf
				Next
			Else
				Help("",1, "TMSPAM003",, oObjPam:oWSresponseTO:oReturn:oFieldTo[2]:cValue,4,0)			
			EndIf
		Else	
			Help("",1, "TMSPAM003",,,3,0)
		EndIf				
	EndIf    
EndIf

Return cTipFav


//-------------------------------------------------------------------
/*PamQtDocVg
Retorna Quantidade de documentos da viagem
@author  Katia
@since   12/02/2020
@version 1.0      
*/
//-------------------------------------------------------------------
Function PamQtDocVg(cFilOri,cViagem,cSerTMSDTQ)
Local nQtdDoc  := 0
Local cQuery   := ""
Local cAliasDUD:= ""
Local aArea    := GetArea()

Default cFilOri    := ""
Default cViagem    := ""
Default cSerTMSDTQ := ""

//Quantidade de documentos da viagem
If cSerTMSDTQ <> StrZero(1,Len(DTQ->DTQ_SERTMS))  
	cQuery := " SELECT COUNT(DUD_DOC) QTDDOC  "
	cQuery += "   FROM " + RetSqlName("DUD") + " DUD, "
	cQuery +=              RetSqlName("DT6") + " DT6, "
	cQuery +=              RetSqlName("SA1") + " SA1R, "
	cQuery +=              RetSqlName("SA1") + " SA1D, "
	cQuery += " WHERE DUD.DUD_FILIAL = '" + xFilial("DUD")+"'"
	cQuery += " AND DUD.DUD_FILORI = '" + cFilOri+"'"
	cQuery += " AND DUD.DUD_VIAGEM = '" + cViagem+"'"
	cQuery += " AND DUD.DUD_STATUS <> '9' "
	cQuery += " AND DUD.D_E_L_E_T_ = ' ' "
	cQuery += " AND DT6.DT6_FILIAL = '" + xFilial("DT6") + "'"
	cQuery += " AND DT6.DT6_FILDOC = DUD.DUD_FILDOC"
	cQuery += " AND DT6.DT6_DOC = DUD.DUD_DOC"
	cQuery += " AND DT6.DT6_SERIE = DUD.DUD_SERIE"
	cQuery += " AND DT6.D_E_L_E_T_ = ' ' "
	cQuery += " AND SA1R.A1_FILIAL = '" + xFilial("SA1")+"'"  
	cQuery += " AND SA1R.A1_COD  = DT6.DT6_CLIREM "
	cQuery += " AND SA1R.A1_LOJA = DT6.DT6_LOJREM "  
	cQuery += " AND SA1R.A1_TIPO <> 'X' "
	cQuery += " AND SA1R.D_E_L_E_T_ = ' ' "   
	cQuery += " AND SA1D.A1_FILIAL = '" + xFilial("SA1")+"'"  
	cQuery += " AND SA1D.A1_COD    = DT6.DT6_CLIDES "
	cQuery += " AND SA1D.A1_LOJA   = DT6.DT6_LOJDES "  
	cQuery += " AND SA1D.A1_TIPO <> 'X' "
	cQuery += " AND SA1D.D_E_L_E_T_ = ' ' "    
Else   //Coleta
	cQuery := " SELECT COUNT(DUD_DOC) QTDDOC "
	cQuery += "   FROM " + RetSqlName("DUD") + " DUD, "
	cQuery +=              RetSqlName("DT6") + " DT6, "
	cQuery +=              RetSqlName("DT5") + " DT5, "
	cQuery +=              RetSqlName("DUE") + " DUE, "
	cQuery +=              RetSqlName("SA1") + " SA1R, "
	cQuery +=              RetSqlName("SA1") + " SA1D "
	cQuery += " WHERE DUD.DUD_FILIAL = '"+xFilial("DUD")+"'"
	cQuery += " AND DUD.DUD_FILORI = '"+cFilOri+"'"
	cQuery += " AND DUD.DUD_VIAGEM = '"+cViagem+"'"
	cQuery += " AND DUD.DUD_STATUS <> '9' "
	cQuery += " AND DUD.D_E_L_E_T_ = ' ' "
	cQuery += " AND DT6.DT6_FILIAL = '"+xFilial("DT6") + "'"
	cQuery += " AND DT6.DT6_FILDOC = DUD.DUD_FILDOC"
	cQuery += " AND DT6.DT6_DOC = DUD.DUD_DOC"
	cQuery += " AND DT6.DT6_SERIE = DUD.DUD_SERIE"
	cQuery += " AND DT6.D_E_L_E_T_ = ' ' "
	cQuery += " AND DT5.DT5_FILIAL = '"+xFilial("DT5") + "'"
	cQuery += " AND DT5.DT5_FILDOC = DT6.DT6_FILDOC"
	cQuery += " AND DT5.DT5_DOC = DT6.DT6_DOC"
	cQuery += " AND DT5.DT5_SERIE = DT6.DT6_SERIE"
	cQuery += " AND DT5.D_E_L_E_T_ = ' ' "  
	cQuery += " AND DUE.DUE_FILIAL = '"+xFilial("DUE")+"'""
	cQuery += " AND DUE.DUE_CODSOL = DT5_CODSOL "
	cQuery += " AND DUE.D_E_L_E_T_ = ' ' "  
	cQuery += " AND SA1R.A1_FILIAL = '"+xFilial("SA1")+"'"
	cQuery += " AND SA1R.A1_COD    = DUE_CODCLI "
	cQuery += " AND SA1R.A1_LOJA   = DUE_LOJCLI "    
	cQuery += " AND SA1R.A1_TIPO <> 'X' "
	cQuery += " AND SA1R.D_E_L_E_T_ = ' ' "  
	cQuery += " AND SA1D.A1_FILIAL = '"+xFilial("SA1")+"'"  
	cQuery += " AND SA1D.A1_COD    = DT5_CLIDES "
	cQuery += " AND SA1D.A1_LOJA   = DT5_LOJDES " 
	cQuery += " AND SA1D.A1_TIPO   <> 'X' " 
	cQuery += " AND SA1D.D_E_L_E_T_ = ' '
EndIf			
cQuery := ChangeQuery(cQuery)
			
cAliasDUD := GetNextAlias()
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDUD,.F.,.T.) 
nQtdDoc := (cAliasDUD)->QTDDOC
(cAliasDUD)->(DbCloseArea()) 

RestArea(aArea)
Return nQtdDoc			
