#Include "PROTHEUS.CH" 
                  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGNRESP    บAutor  ณNatalia Antonucci   บ Data ณ  13/06/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPreparacao do meio magnetico GNRESP - A SEFAZ esta colocandoบฑฑ
ฑฑบ          ณa disposi็ใo do contribuinte, contabilista e popula็ใo em   บฑฑ
ฑฑบ          ณgeral o sistema de Gera็ใo de Guias de Recolhimento em lote.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                

Function GnreSP(lAutomato,aWizard)

Local	lEnd		:=	.F.
Local	cFileDest	:=	"GNRESP.XML"
Local	cNomWiz		:=	"GNRESP"
Local 	lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)
Local	nNaoProc	:= 	0
Local   cMensagem   :=  ""
Local	aNaoProc	:=  {}
Local	lArqGerado  :=  .F.
Local 	cNomeCfp 	:=  cNomWiz
Default	aWizard		:=	{}
Default lAutomato	:= .f.
If lVerpesssen .And. Wizard(cNomWiz)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Valida็๕es realizadas na Wizard antes da gera็ใo do arquivo  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !lAutomato
		If (!xMagLeWiz(cNomeCfp, @aWizard, .T.))
			Return	//Se por algum motivo a leitura do CFP falhar aborto a rotina.
		Endif
		If  SToD(aWizard[1][1]) > SToD(aWizard[1][2])
			cMensagem += iif( empty(cMensagem),"", chr(13)+chr(10)) + "- Data Inicial superior a Data Final !" 
		Endif
		If  empty( Alltrim(aWizard[1][3]) ) .or. !ExistDir( Alltrim(aWizard[1][3]) )
			cMensagem += iif( empty(cMensagem),"", chr(13)+chr(10)) + "- Informe um Diret๓rio Vแlido !" 
		Endif
		If empty( Alltrim(aWizard[1][4]) )
			cMensagem += iif( empty(cMensagem),"", chr(13)+chr(10)) + "- Informe um nome para o arquivo !" 
		EndIf

		if !empty( cMensagem )
			MsgStop( cMensagem , "Aten็ใo" )
			Return
		endif

	Endif

	Processa({||PrGNRESP(@lEnd, aWizard, @cFileDest, @aNaoProc, @lArqGerado )})
	
	cMensagem := 'Arquivo: "'  + cFileDest + '..."' + iif( lArqGerado, " gerado com sucesso!", " nใo foi gerado ") + Chr(13)+Chr(10)+Chr(13)+Chr(10) 

	If 	len( aNaoProc ) >= 1

		aSort( aNaoProc )
		cMensagem += "Aten็ใo: " + iif( len(aNaoProc) == 1, "Guias de recolhimento cadastrada com o c๓digo ", "Guias de recolhimento cadastradas com os c๓digos ")

		For nNaoProc:= 1 to len( aNaoProc )
			cMensagem += iif( nNaoProc == 1, "",", ") + aNaoProc[nNaoProc]
		Next

		cMensagem += " nใo tem o seu leiaute atendido pelo Backoffice Protheus Fiscal, por tratar de normas para segmento especifico."
	Endif		

	If !lAutomato
		If lArqGerado 
			MsgInfo( cMensagem ) //"Arquivo "###" gerado com sucesso!"
		Else
			MsgAlert( cMensagem ) //"Nใo foi possํvel gerar o arquivo!"
		EndIf
	Endif

EndIf
	
Return()                                                                                                           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPrGNRESP  บAutor  ณNatalia Antonucci   บ Data ณ  13/06/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao principal de processamento do arq. magnetico GNRESP  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PrGNRESP(lEnd,aWizard,cFileDest,aNaoProc,lArqGerado)

Local cFilDe   	:= ""
Local cFilAte  	:= "" 
Local cDir     	:= ""
Local cAliasSF6	:= "SF6"                                       
Local cIndex   	:= ""
Local cXml     	:= ""
Local cCorpo 	:= ""
Local cData 	:= ""
Local cDaRef 	:= ""
Local cInsc 	:= ""
Local cCodR 	:= ""
Local cCodRec	:= ""
Local cMVSUBTRIB:= IIf(FindFunction("GETSUBTRIB"), GetSubTrib(), SuperGetMv("MV_SUBTRIB")) 
Local cCODRECAP := GetNewPar("MV_RECEAPU","") 
Local dDataDe  	:= ctod("//")
Local dDataAte 	:= ctod("//") 
Local aFieldDt 	:= {}                                   
Local nCount   	:= 0 
Local nLote    	:= 0
Local nX	   	:= 0 
Local lGerou 	:= .F.
Local lQuery    := .F.
Local lRemet    := .T.
Local lArqTemp  := .F.
Local cPag  	:= ""
Local cCnpjCPF	:= ""
Local cNomeCont	:= ""
Local cEnd		:= ""
Local cMun		:= ""
Local cUF		:= ""
Local cTel		:= ""
Local cIE		:= ""
Local cCEP 		:= ""


dDataDe	 :=	SToD(aWizard[1][1])
dDataAte :=	SToD(aWizard[1][2])
cDir     := Alltrim(aWizard[1][3])
cFileDest:= Alltrim(aWizard[1][4])
cFilDe   := Alltrim(aWizard[1][5]) 
cFilAte  := Alltrim(aWizard[1][6])
cPag  	 := Alltrim(aWizard[1][7])

lRemet   := cPag == "Remetente"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTrata Diretorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (SubStr (cDir, Len (cDir), 1)<>"\")
	cDir	+=	"\"
EndIf

                                                                        
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefinicao da ordem das tabelasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

dbSelectArea("SA1")	//Cadastro do Cliente
SA1->(dbSetOrder(1))
dbSelectArea("SF6")	//GNRE
SF6->(dbSetOrder(1))                                

If Empty(cFilDe) .And. Empty(cFilAte)
	cFilDe  := cFilAnt
	cFilAte := cFilAnt
EndIf

DbSelectArea ("SM0")
SM0->(DbGoTop ())
SM0->(DbSeek (cEmpAnt+cFilDe, .T.))	//Pego a filial mais proxima 
Do While !SM0->(Eof()) .And. cEmpAnt==SM0->M0_CODIGO .And. FWGETCODFILIAL<=cFilAte

	cFilAnt := FWGETCODFILIAL

 	DbSelectArea("SF6")
	SF6->(DbSetOrder(1))

	lQuery    := .T.
	
	aAdd(aFieldDt,"F6_DTVENC")
	aAdd(aFieldDt,"F6_DTPAGTO")
	
	If SF6->(FieldPos("F6_PROCESS")) > 0
		cAliasSF6 := GetNextAlias()

		BeginSql Alias cAliasSF6    	
			SELECT SF6.F6_FILIAL, SF6.F6_DTARREC, SF6.F6_MESREF, SF6.F6_EST, SF6.F6_CODREC, SF6.F6_TIPOIMP, SF6.F6_VALOR, SF6.F6_ANOREF, 
			SF6.F6_DOC, SF6.F6_NUMCONV, SF6.F6_CLIFOR, SF6.F6_LOJA, SF6.F6_NUMERO, SF6.F6_DTVENC, SF6.F6_DTPAGTO, SF6.F6_OPERNF, 
			SF6.F6_SERIE, SF6.F6_MULTA, SF6.F6_JUROS, SF6.F6_ATMON, SF6.F6_INF, SF6.F6_PROCESS, SF6.R_E_C_N_O_, 
			SA1.A1_CGC, SA1.A1_NOME, SA1.A1_END, SA1.A1_MUN, SA1.A1_EST, SA1.A1_TEL, SA1.A1_INSCR, SA1.A1_CEP ,SA1.A1_TIPO
			FROM 
				%Table:SF6% SF6
				INNER JOIN  %Table:SA1% SA1 ON %xFilial:SA1%=SA1.A1_FILIAL AND SF6.F6_CLIFOR=SA1.A1_COD AND SF6.F6_LOJA=SA1.A1_LOJA AND SA1.D_E_L_E_T_ = ' '
			WHERE 
				SF6.F6_FILIAL=%xFilial:SF6% AND 
				SF6.F6_DTARREC>=%Exp:dDataDe% AND 
				SF6.F6_DTARREC<=%Exp:dDataAte% AND
				SF6.F6_PROCESS <> '1' AND
				(SF6.F6_TIPOIMP = '3' OR SF6.F6_TIPOIMP = 'B')  AND
				SF6.F6_EST = 'SP' AND
				SF6.%NotDel%
			ORDER BY %Order:SF6%					               			
		EndSql 
		For nX := 1 To Len(aFieldDt)
			TcSetField(cAliasSF6,aFieldDt[nX],"D",8,0)
		Next nX
			
		DbSelectArea (cAliasSF6)
		(cAliasSF6)->(DbGoTop())
		ProcRegua ((cAliasSF6)->(RecCount ()))
		nLote := 1
		While !(cAliasSF6)->(Eof ()) 
			cNomeArq := cFileDest + '_' + AllTrim(cFilAnt) + '_'
			lArqTemp := .F.
			nCount   := 0 
			cXml	 :=	""
			cXml     := GravaCab(nLote,@cNomeArq)
			While !(cAliasSF6)->(Eof()) .and. nCount < 50
				lGerou   := .F.	

				cData  := StrZero (Day ((cAliasSF6)->F6_DTVENC), 2)+StrZero (Month ((cAliasSF6)->F6_DTVENC), 2)+StrZero (Year ((cAliasSF6)->F6_DTVENC), 4)
				cDaRef := StrZero (Month (dDataDe), 2)+StrZero (Year (dDataDe), 4)
				cInsc  := IESubTrib((cAliasSF6)->F6_EST)
				cCodRec:= Alltrim((cAliasSF6)->F6_CODREC)
				cCodR  := IIf(!Empty(cCODRECAP), cCODRECAP, cCodRec ) 

				//Verifica se hแ IE em Sใo Paulo e se o c๓digo da receita ้ por APURAวยO, ou, Se c๓digo da receita por opera็ใo e "Dados do pagador quando por opera็ใo" estแ preenchido com remetente. Se
				//obedecer uma destas regras os dados da Guia serใo preenchidos com o SM0(dados do emissor da guia). 
				If ("SP"$cMVSUBTRIB .and. cCodR=="100048" .and. cCodRec <> "100099") .OR. (lRemet .and. cCodRec $ "100099/100080") .OR. (cCodRec $ "100080"   .AND.  (cAliasSF6)->F6_OPERNF =='1') .OR. cCodRec=='100102'
					cCnpjCPF	:= Alltrim(SM0->M0_CGC)
					cNomeCont	:= Alltrim(SM0->M0_NOME)
					cEnd		:= Alltrim(SM0->M0_ENDENT)
					cMun		:= Alltrim(SM0->M0_CODMUN)
					cUF			:= Alltrim(SM0->M0_ESTENT)	
					cTel		:= Alltrim(SM0->M0_TEL)
					cIE			:= cInsc
					cCEP 		:= Alltrim(SM0->M0_CEPENT)
					lGerou:= .T.
				//Se nใo passar pela condi็ใo acima s๓ pode ser uma opera็ใo onde o destinatแrio deve ser preenchido na guia como pagador.		
				Elseif ((cCodRec $ "100099/100080") .and.  (cAliasSF6)->F6_OPERNF =='2') 
					cCnpjCPF	:= Alltrim((cAliasSF6)->A1_CGC)	
					cNomeCont	:= Alltrim((cAliasSF6)->A1_NOME)
					cEnd		:= Alltrim((cAliasSF6)->A1_END)
					cMun		:= Alltrim((cAliasSF6)->A1_MUN)
					cUF			:= Alltrim((cAliasSF6)->A1_EST)
					cTel		:= Alltrim((cAliasSF6)->A1_TEL)
					cIE			:= Alltrim((cAliasSF6)->A1_INSCR)
					cCEP 		:= Alltrim((cAliasSF6)->A1_CEP)
					lGerou:= .T. 
				Else
					If 	aScan( aNaoProc, cCodRec ) == 0
						aAdd( aNaoProc, cCodRec )
					Endif
				EndIf
				if lGerou // se falso nใo cria as tags.
					cCorpo := '<dados Vias='+'"3" ' + 'CodigoReceita="' + cCodRec + '" CnpjCpf="'+ cCnpjCPF + '" NomeContribuinte="'+ cNomeCont +;
					'" Endereco="'+ cEnd + '" Municipio="'+ cMun + '" Uf="'+ cUF + '" Telefone="'+ cTel + '" ValorOriginal="'+ Alltrim(StrTran(str((cAliasSF6)->F6_VALOR),".",",")) +;
					'" Juros="'+Alltrim(StrTran(str((cAliasSF6)->F6_JUROS),".",",")) + '" Observacoes="'+Alltrim((cAliasSF6)->F6_INF) + '" DataVencimento="'+ cData + '" Nf="'+Alltrim((cAliasSF6)->F6_DOC) +;
					'" Referencia="'+ cDaRef + '" Multa="'+ Alltrim(StrTran(str((cAliasSF6)->F6_MULTA),".",",")) + '" ConvenioProtocolo="'+Alltrim((cAliasSF6)->F6_NUMCONV) +;
					'" InscricaoEstadual="'+ cIE + '" Cep="'+ cCEP + '" DocumentoDeOrigem="'+Alltrim((cAliasSF6)->F6_DOC) +'"/>'

					cXml += cCorpo                        	         
					cXml += Chr(13)+Chr(10)
			
					lArqTemp := .t.
	
					SF6->(dbGoTo( (cAliasSF6)->R_E_C_N_O_ ))
					RecLock("SF6",.F.)
					SF6->F6_PROCESS := "1"
					SF6->(MsUnlock())
				EndIf

				(cAliasSF6)->(DbSkip())
				nCount++ 
			EndDo
			If lArqTemp
				lArqGerado := .t.
				cXml += "</Guia>"                            		
				MemoWrite(cDir+cNomeArq,cXml)
				nLote++ 
			Endif   	  	 	     	 		                    	
		EndDo

		DbSelectArea(cAliasSF6)
		(cAliasSF6)->(DbCloseArea())
	EndIf
	
	SM0->(DbSkip())
EndDo

If !lQuery    
	RetIndex("SF6")
	dbClearFilter()
	Ferase(cIndex+OrdBagExt()) 
EndIf

Return (.T.) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGravaCab บAutor  ณNatalia Antonucci   บ Data ณ  13/06/12    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o Cabecalho do XML                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function  GravaCab(nLote,cNomeArq)
Local cMontXml := ""

cNomeArq := cNomeArq + ALLTRIM(Str(nLote)) + ".XML"
 
	cMontXml += "<Guia>"  

Return(cMontXml)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณWizard   บAutor  ณNatalia Antonucci   บ Data ณ  13/06/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o Wizard da rotina.                                  บฑฑ
ฑฑบ          ณ Retorna .T. se finalizado com sucesso                      บฑฑ
ฑฑบ          ณ Retorna .F. se foi cancelado                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Wizard(cNomWiz)
Local	aTxtApre	:=	{}
Local	aPaineis	:=	{}
Local	cTitObj1	:=	""
Local	cTitObj2	:=	""
Local	lRet		:=	.T.

//ฺฤฤฤฤฤฤฤฤฟ
//ณPainel 0ณ
//ภฤฤฤฤฤฤฤฤู
aAdd (aTxtApre, "Parโmetros necessแrios.")
aAdd (aTxtApre, "")
aAdd (aTxtApre, "Preencha corretamente as informa็๕es solicitadas.")
aAdd (aTxtApre, "Informa็๕es necessแrias para a gera็ใo do meio-magn้tico GNRESP.")

//ฺฤฤฤฤฤฤฤฤฟ
//ณPainel 1ณ
//ภฤฤฤฤฤฤฤฤู
aAdd (aPaineis, {})
nPos	:=	Len (aPaineis)
aAdd (aPaineis[nPos], "Preencha corretamente as informa็๕es solicitadas.")
aAdd (aPaineis[nPos], "Parโmetros para Gera็ใo")
aAdd (aPaineis[nPos], {})
//
cTitObj1	:=	"Data de";								   	cTitObj2	:=	"Data at้"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});				aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
//
aAdd (aPaineis[nPos][3], {2,,,3,,,,});						aAdd (aPaineis[nPos][3], {2,,,3,,,,}) 
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj1	:=	"Diret๓rio do Arquivo Destino";				cTitObj2	:=	"Nome do Arquivo Destino"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});				aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
//
cTitObj1	:=	Replicate ("X", 50);						cTitObj2	:=	Replicate ("X", 20)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});			aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,20})
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj1	:=	"Filial de"; 								cTitObj2	:=	"Filial ate"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});				aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
//
cTitObj1	:=	Replicate ("X", 8);							cTitObj2	:=	Replicate ("X", 8)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,8});				aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,8})
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj1	:=	"Dados do pagador quando por opera็ใo"					
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});				aAdd (aPaineis[nPos][3], {1, "",,,,,,})
//
aAdd (aPaineis[nPos][3], {3,,,,,{"Remetente", "Destinatแrio"},,});

lRet	:=	xMagWizard (aTxtApre, aPaineis, cNomWiz)

Return (lRet)
