
#INCLUDE "PROTHEUS.CH"

#DEFINE __cPictUsr "@R !!!.!!!!.!!!!!!-!!"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsTrtPos ºAutor  ³Armando M. Tessaroliº Data ³  06/07/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada para manipular o autorizador remoto do PLS º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Unimed Taubate                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PlsTrtPos()

Local aCab := {}
Local aIte := {}
Local aRet
Local nI
Local cCodPro
Local cCodInt
Local cCodMed
Local cCodMed2
Local cCodEsp
Local cUniSol
Local cCidPri
Local cCodGuia
Local cNumImp
Local cCodAMB
Local nH
Local cCodRDA
Local cSQL
Local lRegulamentado := .F.
Local cTrailler := ""
Local aDadProntu
Local cLinProntu
Local nLimite := 50 // limite de linhas para o pronturario eletronico

cCodInt := PlsPosGet("CDUNISOL",aItens[1])
cCodUsu := SubStr(cCodInt,2)+PlsPosGet("CDUSUARIO",aItens[1])

// verifica usuario regulamentado
If	(SubStr(cCodUsu,1,7) >= "0407200" .AND. SubStr(cCodUsu,1,7) <= "0407651")	.OR.;
	(SubStr(cCodUsu,1,7) >= "0401200" .AND. SubStr(cCodUsu,1,7) <= "0401299")	.OR.;
	(SubStr(cCodUsu,1,7) >= "0403500" .AND. SubStr(cCodUsu,1,7) <= "0403700")	.OR.;
	(SubStr(cCodUsu,1,7) >= "0405100" .AND. SubStr(cCodUsu,1,7) <= "0405499")
	lRegulamentado := .T.
Endif

If !lRegulamentado
	PlsPosLog( "Eliminando " + cCodUsu + " <<<<<<<<<<<<<<<<<   N Ã O   R E G U L A M E N T A D O   >>>>>>>>>>>>>>>>>" )
	PlsPosPut("CODRES","01",aDados)
	For nI := 1 to Len(aItens)
		PlsPosPut("CODRES","01",aItens[nI])
		PlsPosPut("MENSAGEM","Nao Regulamentado",aItens[nI])
	Next
	Return(.F.)
Endif

If Len(aItens) > 0 .AND. PlsPosGet("TIPOTRANSA",aItens[1]) == "UNI"
	
	// Manda mensagem para o monitor
	PlsPosLog("")
	PlsPosLog("")
	PlsPosLog("")
	PlsPosLog(Replicate("=", 95))
	PlsPosLog("Usuário... " + cCodUsu)
	
	// Pesquisa Especialidades Medicas
	cCodEsp := Subs(PlsPosGet("ESPMED",aItens[1]),2,3)
	DbSelectArea("BAQ")
	DbSetOrder(3)		// BAQ_FILIAL + BAQ_CODINT + BAQ_CODANT
	MsSeek(xFilial("BAQ")+cCodInt+cCodEsp)
	
	cUniSol := StrZero(Val(PlsPosGet("UNISOL",aItens[1])),4)
	cCidPri := PlsPosGet("CID",aItens[1])
	
	Aadd(aCab, {"OPEMOV",	cCodInt} )
	Aadd(aCab, {"USUARIO",	cCodUsu} )
	Aadd(aCab, {"DATPRO",	dDataBase} )
	Aadd(aCab, {"HORAPRO",	SubStr(StrTran(Time(),":",""),1,4)} )
	Aadd(aCab, {"CIDPRI",	cCidPri } )
	Aadd(aCab, {"CODESP",	BAQ->BAQ_CODESP } )
	Aadd(aCab, {"OPESOL",	cUniSol} )
	
	cCodMed := StrZero(Val(PlsPosGet("CODMED",aItens[1])),8)
	cCodMed2 := StrZero(Val(PlsPosGet("CODMED2",aItens[1])),8)
	
	If Val(cCodMed2) > 0
		// Pesquisa Operadoras da Rede Atendimento
		DbSelectArea("BAW")
		DbSetOrder(3)		// BAW_FILIAL + BAW_CODINT + BAW_CODANT
		MsSeek(xFilial("BAW")+cCodInt+cCodMed2)
		
		// Pesquisa Redes de Atendimento
		DbSelectArea("BAU")
		DbSetOrder(1)		// BAU_FILIAL + BAU_CODIGO
		MsSeek(xFilial("BAU")+BAW->BAW_CODIGO)
		Aadd(aCab, {"CDPFSO",	BAU->BAU_CODIGO} )
	Endif
	
	// Pesquisa Operadoras da Rede Atendimento
	DbSelectArea("BAW")
	DbSetOrder(3)		// BAW_FILIAL + BAW_CODINT + BAW_CODANT
	MsSeek(xFilial("BAW")+cCodInt+cCodMed)
	
	// Pesquisa Redes de Atendimento
	DbSelectArea("BAU")
	DbSetOrder(1)		// BAU_FILIAL + BAU_CODIGO
	MsSeek(xFilial("BAU")+BAW->BAW_CODIGO)
	Aadd(aCab, {"CODRDA",	BAU->BAU_CODIGO} )
	
	// Envia mensagens para o monitor
	PlsPosLog("RDA/Médico... " + BAU->BAU_CODIGO)
	PlsPosLog("Nome... " + BAU->BAU_NOME)
	PlsPosLog("cCodMed... " + cCodMed)
	PlsPosLog("cCodMed2... " + cCodMed2)
	
	aIte := {}
	For nI := 1 to Len(aItens)
		cCodPro := "01"+SubStr(PlsPosGet("AMB",aItens[nI]),2)
		cCodAMB := PlsPosGet("AMB",aItens[nI])
		PlsPosLog("Código da AMB" + cCodAMB )
		Aadd(aIte,{})
		Aadd(aIte[nI],{"SEQMOV",StrZero(nI,3) })
		Aadd(aIte[nI],{"CODPAD",SubStr(cCodPro,1,2)  })
		Aadd(aIte[nI],{"CODPRO",SubStr(cCodPro,3)  })
		Aadd(aIte[nI],{"QTD",1 })
	Next
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Envio informacoes para AUTORIZACAO e trato o retorno³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
	    
		// Codigo especifico para atualizacao de CID
		Case cCodAMB == "000010019"
			PlsPosLog("Atualizando CID")
			cNumImp := SubStr(PlsPosGet("DESCVALAD",aItens[1]),1,9)
			cCodGuia := Imp2Guia(StrZero(Val(cNumImp),16))
			If Empty(cCodGuia)
				PlsPosPut("CODRES","01",aDados)
				PlsPosPut("MENSAGEM","Guia nao Localizada para atualizar CID.",aDados)
			Else
				PLSSTAGUI(Subs(cCodGuia,1,4),Subs(cCodGuia,5,4),Subs(cCodGuia,9,2),Subs(cCodGuia,11),"",.F.,"",.F.,cCidPri,.T.)
				PlsPosLog("*** GUIA ["+cCodGuia+"] atualizada com o CID ["+cCidPri+"] ***")
				PlsPosPut("CODRES","90",aDados)
				PlsPosPut("MENSAGEM","/ok GUIA atualizada com o CID ["+cCidPri+"]",aDados)
			Endif
			aItens := Array(1)
			aItens[1] := aClone(aDados)
			
		// Envia o cancelamento de uma autorizacao
		Case cCodAMB == "000000000"
			cNumImp := SubStr(PlsPosGet("DESCVALAD",aItens[1]),1,9)
			PlsPosLog("cancelando impresso ["+cNumImp+"]")
			cCodGuia := Imp2Guia(StrZero(Val(cNumImp),16))
			PlsPosLog("cancelando guia ["+cCodGuia+"]")
			If Empty(cCodGuia)
				PlsPosPut("CODRES","01",aDados)
				PlsPosPut("MENSAGEM","Guia nao Localizada.",aDados)
			Else
				PLSXEXCA(cCodGuia)
				PlsPosLog("*** GUIA CANCELADA ["+cCodGuia+"]***")
				PlsPosLog("*** IMPRESSO ["+cNumImp+"]***")
				PlsPosPut("CODRES","90",aDados)
				PlsPosPut("MENSAGEM","/ok GUIA cancelada. Impresso ["+cNumImp+"] codigo Microsiga ["+cCodGuia+"]",aDados)
			Endif
			aItens := Array(1)
			aItens[1] := aClone(aDados)
		
		// Executa a autorizacao padrao para o procedimento
		Otherwise
			// Inicia o processo de autorizacao
			nH := PLSAbreSem("PLSTRTPOS.SMF")
				// Pesquisa o proximo numero de impressao
				cSQL     := "SELECT MAX(BD6_NUMIMP) NUMIMP FROM "+RetSQLName("BD6")+" WHERE BD6_FILIAL = '"+xFilial("BD6")+"' AND D_E_L_E_T_ = '' AND SUBSTRING(BD6_NUMIMP,1,3)='000' "
				PLSQUERY(cSQL,"PLSTEMP")
				Aadd(aCab, {"NUMIMP", StrZero(Val(PLSTEMP->NUMIMP)+1,16)} )
				Aadd(aCab, {"TPGRV", "3"} ) // 3=POS
				PLSTEMP->(DbCloseArea())
				
				// Executa a autorizacao
				PlsPosLog("Aguarde autorizando...")
				aRet := PLSXAUTP(aCab,aIte)
			PLSFechaSem(nH)
			
			Do Case
				// .T. Procedimento AUTORIZADO
				Case aRet[1]
					PlsPosPut("RESPOSTA","01",aDados)
					PlsPosPut("CODRES","00",aDados)
					For nI := 1 to Len(aItens)
						PlsPosLog("*** AUTORIZADO ***")
						
						// Pesquisa Familias/Usuarios
						DbSelectArea("BA3")
						DbSetOrder(4)		// BA3_FILIAL + BA3_MATANT
						MsSeek(xFilial("BA3") + cCodUsu)
						
						// Pesquisa Grupo / Empresa
						DbSelectArea("BG9")
						DbSetOrder(1)		// BG9_FILIAL + BG9_CODINT + BG9_CODIGO + BG9_TIPO
						MsSeek(xFilial("BG9")+BA3->BA3_CODINT+BA3->BA3_CODEMP)
						
						PlsPosPut("EMPRESA",AllTrim(BG9->BG9_DESCRI),aItens[nI])
						PlsPosPut("DATA",DtoC(dDataBase)+" "+Time()  ,aItens[nI])
						PlsPosPut("ESPECIALID",BAQ->BAQ_DESCRI,aItens[nI])
						PlsPosPut("PRESTADOR",AllTrim(BAU->BAU_NOME),aItens[nI])
						PlsPosPut("COMENTARIO",  ,aItens[nI])
						PlsPosPut("DESCAMB",Posicione("BR8",1,xFilial("BR8")+cCodPro,"BR8_DESCRI"),aItens[nI])
					Next
                    // adiciona dados do prontuario eletronico
                    // inicio
                    //                                  / aqui estao os campos pedidos para retorno /
                    aDadProntu := PLSGETMOV(cCodUsu,180,{"BD6_DATPRO","BD6_CODPRO","BD6_DESPRO"},nLimite)
                    If Len(aDadProntu) > 0
                       cTrailler := '/ext'
                       For nI := 1 to Len(aDadProntu)
                          // aqui no CLINPRONTU vc monta a string que sera enviada ao client do POS
                          cLinProntu := DtoC(aDadProntu[nI,1])+' - '+Transform(aDadProntu[nI,2],"@R 99.99.999-9")+' '+aDadProntu[nI,3]
                          cTrailler+='"'+cLinProntu+'"'
                          If nI # Len(aDadProntu)
                             cTrailler+=','
                          EndIf
                       Next
                    EndIf   
                    // fim
					
				// .F. Procedimento NEGADO
				Otherwise
					PlsPosLog("*** NAO AUTORIZADO ***")
					PlsPosPut("CODRES","01",aDados)
					PlsPosLog("************ LOG DE ERRO 01 ***********")
					For nI := 1 to Len(aRet[4])
						PlsPosLog("**** "+StrZero(Val(aRet[4,nI,1]),2))
						PlsPosLog("Codigo da Critica "+aRet[4,Val(aRet[4,nI,1]),2])
						PlsPosLog("Descricao         "+aRet[4,Val(aRet[4,nI,1]),3])
						PlsPosPut("CODRES","01",aItens[Val(aRet[4,nI,1])])
						If Empty(PlsPosGet("MENSAGEM",aItens[Val(aRet[4,nI,1])]))
							PlsPosPut("MENSAGEM",AllTrim(aRet[4,1,3]),aItens[Val(aRet[4,nI,1])])
							PlsPosLog("mensagem          "+PlsPosGet("MENSAGEM",aItens[Val(aRet[4,nI,1])]))
						Endif
					Next
					PlsPosLog("************ LOG DE ERRO 02 ***********")
					For nI := 1 to Len(aItens)
						PlsPosLog("**** "+StrZero(nI,2))
						PlsPosLog("Codigo da Critica "+aRet[4,1,2])
						PlsPosLog("Descricao         "+aRet[4,1,3])
						PlsPosPut("CODRES","01",aItens[nI])
						If Empty(PlsPosGet("MENSAGEM",aItens[nI]))
							PlsPosPut("MENSAGEM",AllTrim(aRet[4,1,3]),aItens[nI])
							PlsPosLog("mensagem          "+PlsPosGet("MENSAGEM",aItens[nI]))
						Endif
					Next
					
			EndCase
			
	Endcase
	
	PlsPosLog(Replicate("=", 95))
	PlsPosLog("")
	PlsPosLog("")
	PlsPosLog("")
	
Endif

PlsPosPut("TRAILLER",cTrailler)
Return(.T.)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsEndPos ºAutor  ³Armando M. Tessaroliº Data ³  06/07/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Unimed Taubate                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PlsEndPos()

Local cDriveProc := ParamIxb[1]
Local cPathOut := ParamIxb[2]
Local cPathIn  := ParamIxb[3]
Local aFilesP
Local nTotFiles
Local nI

aFilesP := Directory(cDriveProc+cPathOut+'*.*')

For nI := 1 to len(aFilesP)
	Ferase(cPathIn+aFilesP[nI][1])
	If Frename(cDriveProc+cPathOut+aFilesP[nI][1] , cPathIn+aFilesP[nI][1] )#-1
		PlsPosLog("renomeado para "+cPathIn+aFilesP[nI][1])
	Endif
	PlsPosLog(Replicate("-", 143))
Next

Return(.T.)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsArqPos ºAutor  ³Armando M. Tessaroliº Data ³  06/04/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que pega os arquivos enviados para serem processados º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Unimed Taubate                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PlsArqPos()

Local cPathIn := ParamIxb[1]
Local aFiles

aFiles := Directory(cPathIn+'TD*.*')

Return(aFiles)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Guia2Imp  ºAutor  ³Armando M. Tessaroliº Data ³  06/07/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Unimed Taubate                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Guia2Imp(cGuia)

Local cRet := ""

DbSelectArea("BEA")		// Complemento Movimentacao
DbSetOrder(1)			// BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
If MsSeek(xFilial("BEA")+cGuia)
	cRet := BEA->BEA_NUMIMP
Endif

Return(cRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Imp2Guia  ºAutor  ³Armando M. Tessaroliº Data ³  06/07/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Unimed Taubate                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Imp2Guia(cImp)

Local cRet := ""

DbSelectArea("BEA")		// Complemento Movimentacao
DbSetOrder(9)			// BEA_FILIAL + BEA_NUMIMP
If MsSeek(xFilial("BEA")+StrZero(Val(cImp),16))
	cRet := BEA->BEA_OPEMOV + BEA->BEA_ANOAUT + BEA->BEA_MESAUT + BEA->BEA_NUMAUT
Endif

Return(cRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetGuia   ºAutor  ³Armando M. Tessaroliº Data ³  06/07/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Unimed Taubate                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RetGuia(aDados)

Local nPos		:= 0
Local cMatric   := Eval( { || nPos := Ascan(aDados,{|x| x[1] = "USUARIO"}),	IF(nPos>0,aDados[nPos,2],"") })
Local dDatPro   := Eval( { || nPos := Ascan(aDados,{|x| x[1] = "DATPRO"}),		IF(nPos>0,aDados[nPos,2],"") })
Local cHora     := Eval( { || nPos := Ascan(aDados,{|x| x[1] = "HORAPRO"}),	IF(nPos>0,aDados[nPos,2],"") })
Local cCodRda   := Eval( { || nPos := Ascan(aDados,{|x| x[1] = "CODRDA"}),		IF(nPos>0,aDados[nPos,2],"") })
Local cUsuario	:= ""
Local cNumGui   := ""

If PLSA090USR(cMatric,dDatPro,cHora,"BE1",.F.,.T.)[1]
	cUsuario := PLSGETUSR()[2]
	
	DbSelectArea("BEA")		// Complemento Movimentacao
	DbSetOrder(8)			// BEA_FILIAL + BEA_OPEUSR + BEA_CODEMP + BEA_MATRIC + BEA_TIPREG + BEA_DIGITO + BEA_CODRDA + DTOS(BEA_DATPRO) + BEA_TIPGUI + BEA_CID
	If BEA->(DbSeek(xFilial("BEA")+cUsuario+cCodRda+dtos(dDatPro)+"01"+Space(Len(BEA->BEA_CID))))
		cNumGui := BEA->BEA_OPEMOV + BEA->BEA_ANOAUT + BEA->BEA_MESAUT + BEA->BEA_NUMAUT
	Endif
Endif

Return(cNumGui)

