#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'GPEW030.CH'

//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
//³Fun‡„o    ³GPEW030   ³Autor³Flavio Correa                                 ³ Data ³07/07/15³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
//³Descri‡„o ³JOB para email de férias em dobro	    					                     ³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³Uso       ³Generico                                                                       ³
//ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³            ACTUALIZACIONES DESDE LA CONTRUCCION INICIAL                                  ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³Programador ³Data      ³ BOPS/FNC  ³                   Motivo da Alteracao                ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³            ³          ³           ³                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Function GPEW030()
Local _cEmp
Local _cFil                  
Local _aArea 	:= "" 
Local _aLog := {}
Local cMail	:= ""

_aArea := GetArea()
_cFil := FWCodFil()
_cEmp := FWCodEmp() 

cMail		:= SuperGetMV("MV_WFFEREM") //email a ser utilizado caso o superior não tenha email definido e para envio do log 

aadd(_aLog,Replicate("*",50))
aadd(_aLog,STR0001 + DTOC(DATE()) + STR0002 + TIME()) //PROCESSAMENTO GPEW030 INICIO - //" HORA : "
aadd(_aLog,Replicate("*",50))

	WFAvisoFer(_cEmp,_cFil,@_aLog,cMail)

aadd(_aLog,Replicate("*",50))
aadd(_aLog,STR0003 + DTOC(DATE()) + STR0002 + TIME())//"PROCESSAMENTO GPEW030 FIM - "//" HORA : "
aadd(_aLog,Replicate("*",50))

GeraLog("GPEW030_"+FWCodFil(),_aLog,cMail)

RestArea(_aArea)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³WFAvisoFer ³ Autor ³ 					    ³ Data ³ 07/07/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Workflow ferias em dobro		   				              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEW030                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function WFAvisoFer(_cEmp,_cFil,_aLog,cMail)
Local aArea		:= GetArea()
Local cAliasTmp	:= GetNextAlias()
Local nDias		:= SuperGetMV("MV_WFFERVE",,65) // dias para acrescentar na database para usar como criterio de busca
Local dDtLimite	:= ddatabase + nDias
Local cVerba	:= FGetCodFol("0072") //ferias
Local lProc		:= .F.
Local dDtAfast
Local aFunc		:= {}
Local nCount	:= 0
Local cTypeOrg	:= SuperGetMV("MV_ORGCFG",,"0")
Local cVision	:= SuperGetMv("MV_APDVIS")
Local aDeptos	:= {}

If cTypeOrg == "0"
	aDeptos := fEstrutDepto(_cFil)
EndIf

dbSelectArea("SRA")
SRA->(dbSetOrder(1))

BeginSql alias cAliasTmp
	SELECT RF_FILIAL,RF_MAT,SRA.R_E_C_N_O_ RECSRA, COUNT(1) 
	FROM %table:SRF% SRF
	INNER JOIN %table:SRA% SRA ON RA_FILIAL=RF_FILIAL AND RA_MAT=RF_MAT 
				AND RA_SITFOLH IN (' ','F','A') AND SRA.%notDel% 
	WHERE SRF.%notDel% 
	AND RF_STATUS =  %exp:'1'% 
	AND RF_DATAFIM <= %exp:Dtos(dDtLimite)% 
	AND RF_FILIAL =  %exp:_cFil% 
	AND RF_PD =  %exp:cVerba% 
	GROUP BY RF_FILIAL,RF_MAT,SRA.R_E_C_N_O_
	HAVING COUNT(1) > 1
	ORDER BY RF_FILIAL,RF_MAT
EndSql

While !(cAliasTmp)->(Eof())
	nCount++
	SRA->(dbGoto((cAliasTmp)->RECSRA))
	lProc := .F.
	dDtAfast := Ctod(" /  /")
	//Verifica se funcionario afastado ira participar da busca
	lProc := fAfast(SRA->RA_SITFOLH,dDtLimite,@dDtAfast,SRA->RA_ADMISSA)
	
	//verifica SRH X SRF pra ver se é necessario processar o funcionario
	If lProc 	
		fSRH(@aFunc,SRA->RA_FILIAL, SRA->RA_MAT,dDtLimite,Alltrim(SRA->RA_NOME),SRA->RA_SITFOLH,dDtAfast,SRA->RA_DEPTO,aDeptos,cTypeOrg,cVision)
	Endif
	
	(cAliasTmp)->(dbSkip())
EndDo
(cAliasTmp)->(dbCloseArea())

AAdd(_aLog,STR0004 + alltrim(str(nCount)) )//"Registros pesquisados : "

//Envia emails
fSendMail(_aLog,aFunc,cMail,dDtLimite,_cFil)

aFunc := aSize(aFunc,0)
aFunc := nil

RestArea(aArea)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fSRH    ³ Autor ³ 					    ³ Data ³ 07/07/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Busca se periodo aquisitivo ja esta calculado	              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEW030                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fSRH(aFunc,cFilFun, cMat,dDtBusca,cNome,cSit,dDtAfast,cDepto,aDeptos,cTypeOrg,cVision)
Local aArea 	:= GetArea()
Local lRet		:= .T.
Local cTmp		:= GetNextAlias()
Local dLimite		
Local aSup		:= {}
Local nPos		:= 0
Local nI		:= 1
Local nAfunc	:= 0
Local nTreg	:= 0
	
BeginSql alias cTmp
	SELECT SRF.* ,COALESCE(RH_DATABAS,'') AS RH_DATABAS
	FROM  %table:SRF%  SRF 
	LEFT JOIN  %table:SRH% SRH on RH_FILIAL=RF_FILIAL AND RH_MAT=RF_MAT 
				AND SRH.%notDel%  AND RF_DATABAS = RH_DATABAS 
	WHERE RF_MAT = %exp:cMat% 
	AND RF_FILIAL =  %exp:cFilFun% 
	AND SRF.%notDel% 
	AND RF_DATAFIM <= %exp:Dtos(dDtBusca)% 
	AND RF_STATUS = %exp:'1'% 
	ORDER BY RF_DATABAS DESC
EndSql

Count To nTReg	
(cTmp)->(dbGotop())
nTreg--
While !(cTmp)->(Eof())

	dLimite := StoD((cTmp)->RF_DATAFIM) - 31

	If nI == 1
		//verifica se ja tem calculo para o ultimo periodo
		lRet := stod((cTmp)->RF_DATABAS) > sTod((cTmp)->RH_DATABAS)
		
		//caso não tenha calculo, verifica se tem programação
		If lRet
			//data limite tem que ser sempre segunda feira
			If Dow(dLimite) != 2
				While ( Dow( --dLimite ) != 2 )
				End While
			EndIf
			If Empty((cTmp)->RF_DATAINI) .Or. StoD((cTmp)->RF_DATAINI) > dLimite .Or. StoD((cTmp)->RF_DATAINI) < ddatabase
				//ferias em dobro
				aSup := {}
				cChave := fSuperior(@aSup,cVision,cFilFun,cMat,cDepto,aDeptos,cTypeOrg)
				If Len(aFunc) > 0
					nPos := Ascan(aFunc,{|x| x[1] == cChave})
					If nPos <= 0
						aadd(aFunc , {cChave, aSup,{ } })
						nPos := Len(aFunc)
					EndIf	
				Else
					nPos := 1
					aadd(aFunc , {cChave, aSup ,{ } })
				EndIf
				
				aadd(aFunc[nPos][3],{cFilFun,cMat,cNome,cSit,stod((cTmp)->RF_DATABAS),StoD((cTmp)->RF_DATAFIM),dLimite,dDtAfast,dLimite<ddatabase})
				nAfunc := Len(aFunc[nPos][3])
			EndIf		
		EndIf
	EndIf
	If nAfunc > 0
		aFunc[nPos][3][nAfunc][5] := stod((cTmp)->RF_DATABAS)
	EndIf
	If nI == nTreg .And. nPos > 0
		aFunc[nPos][3][nAfunc][7] := dLimite
		aFunc[nPos][3][nAfunc][9] := dLimite<ddatabase
	EndIf
	nI++
	(cTmp)->(dbSkip())
Enddo
(cTmp)->(dbCloseArea())

RestArea(aArea)
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fSendMail ³ Autor ³ 					    ³ Data ³ 07/07/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Envia Emails 			   		   				              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEW030                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fSendMail(_aLog,aFunc,cMail,dLimite,cFilFun)
Local nI		:= 1
Local nJ		:= 1
Local cSubject	:= STR0005//"[WORKFLOW] - Atenção! Férias em Dobro a Vencer!"
Local cHtml		:= ""
Local cEmail	:= cMail
Local cNome		:= "Superior"
Local cErro		:= ""
For nI := 1 To Len(aFunc)
	//destinatario
	cNome		:= "Superior"
	cEmail	:= cMail
	If len(aFunc[nI][2]) > 0
		If !Empty(aFunc[nI][2][1][3])
			cEmail := aFunc[nI][2][1][3]
		EndIf
		cNome := aFunc[nI][2][1][4]
	EndIf
	
	cHtml := "<html>"
	cHtml += "<p>"
	cHtml += "    " + STR0010 +" " +Alltrim(cNome)+",</p>" //"Prezado(a) "
	cHtml += "<p>"
	cHtml += STR0011 + " " + dtoc(dLimite)+"!</p>"//"Os seguintes funcionários listados abaixo possuem férias em dobro a vencer em até "
	cHtml += "<p>"
	cHtml += "    " + STR0012 + " " +cFilFun+" - " + FWFilName ( cEmpAnt, cFilFun )+"</p>" //Filial : "
	cHtml += "<table border='1'>"
	cHtml += "    <tr>"
	cHtml += "        <td align='center'><b>"+STR0013+"</b></td>"//Matrícula
	cHtml += "        <td><b>"+STR0014+"</b></td>"//Nome
	cHtml += "        <td align='center'><b>"+STR0015+"</b></td>"//Sit. Folha
	cHtml += "        <td align='center'><b>"+STR0016+"</b></td>"//Data Base Férias
	cHtml += "        <td align='center'><b>"+STR0017+"</b></td>"//"Vencimento último período"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
	cHtml += "        <td align='center'><b>"+STR0018+"</b></td>"//Data limite de Gozo
	cHtml += "        <td align='center'><b>"+STR0019+"</b></td>"//Retorno Afastamento
	cHtml += "        <td align='center'><b>"+STR0020+"</b></td>"//Status Férias em dobro
	cHtml += "    </tr>"
	For nJ := 1 To Len( aFunc[nI][3] )
		cHtml += "    <tr>"
		cHtml += "        <td align='center'>"+aFunc[nI][3][nJ][2]+"</td>"
		cHtml += "        <td>"+aFunc[nI][3][nJ][3]+"</td>"
		cHtml += "        <td align='center'>"+AllTrim(fDesc("SX5", "31" + aFunc[nI][3][nJ][4], "X5DESCRI()", NIL, aFunc[nI][3][nJ][1]))+"</td>"
		cHtml += "        <td align='center'>"+Dtoc(aFunc[nI][3][nJ][5])+"</td>"
		cHtml += "        <td align='center'>"+Dtoc(aFunc[nI][3][nJ][6])+"</td>"
		cHtml += "        <td align='center'>"+Dtoc(aFunc[nI][3][nJ][7])+"</td>"
		cHtml += "        <td align='center'>"+Dtoc(aFunc[nI][3][nJ][8])+"</td>"
		If aFunc[nI][3][nJ][9] 
			cHtml += "        <td align='center'>"+STR0021+"</td>"//Vencida
		Else
			cHtml += "        <td align='center'>"+STR0022+"</td>"//No prazo
		EndIf
		cHtml += "    </tr>"
	Next nJ
	cHtml += "</table>"	
	cHtml += "</html>"	

	If !gpeMail(cSubject,cHtml,cEMail,{},@cErro)
		aadd(_aLog,STR0006 + cErro)//"Erro ao enviar email : "
	EndIf
Next nI

Return



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fAfast ³ Autor ³ 					    ³ Data ³ 07/07/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Busca afastamentos     		   				              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEW030                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fAfast(cSit,dDtLimite,dDtAfast,dAdmissa)
Local aAfast := {}
Local nI	:= 1
Local lProc	:= .T.
If cSit == "A"
	fRetAfas( dAdmissa,dDtLimite, , , ,, @aAfast, ,.T., , , )
	For nI := 1 To Len(aAfast)
		If !Empty(aAfast[nI][4]) .And. aAfast[nI][4] <= dDtLimite
			dDtAfast := aAfast[nI][4]
			lProc := .T.
			//Exit
		Else
			lProc	:= .F.
		EndIf
	Next nI
EndIf
Return lProc

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GeraLog   ³ Autor ³ 					    ³ Data ³ 28/11/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para gravar arq TXT				              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEA030                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GeraLog(cNomeArq,aDados,cMail)
Local aArea := GetArea()
Local cArq 	:= ""                                     
Local nHdlA       
Local cServer:= "\_logs\"      
Local nI	 := 0
Local cErro	:= ""

If !ExistDir(cServer) 
	if makeDir( cServer ) != 0
			conout(STR0007)//"Erro ao criar diretorio de saida."   
		return
	endIf                    
EndIf         
cNome := cNomeArq + "_"+dtos(date())+"_"+Replace(Time(),":","")+".log"
If !File (cServer + "\" +cNome)
	nHdlA  := fCreate( cServer + "\" +cNome)
Else
	If fErase(cServer + "\" +cNome) >= 0
		nHdlA  := fCreate( cServer + "\" +cNome)
	Else      
		conout(STR0008)//"Não foi possível gerar o arquivo, ele já existe."
		Return	
	EndIf
EndIf

For nI := 1 To Len(aDados)
	cArq := aDados[nI] + chr(13)+chr(10)
	fWrite(nHdlA,cArq,Len(cArq)) 
Next nI

fClose(nHdlA) 

If !gpeMail(STR0009,"",cMail,{cServer + "\" +cNome},@cErro)//"[WORKFLOW] - Log de geração"
	conout(STR0006 + cErro)//"Erro enviar email"
EndIf
RestArea(aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SchedDef   ³ Autor ³ 					    ³ Data ³ 28/11/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao static para carregar ambiente do schedule            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEA030                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SchedDef()
Local aOrd		:= {}
Local aParam	:= {}

aParam := {"P",;
			"PARAMDEF",;
			"",;
			aOrd,;
}	
Return aParam

/*/{Protheus.doc} fSuperior
Retorna superior
@author Flavio S. Correa
@since 09/04/2014
/*/
Function fSuperior(aRet, cVision, cFilFun, cMatFun, cDepto, aDeptos, cTypeOrg)
	
	Local aArea		:= GetArea()
	Local aTemp		:= {}
	Local nPos		:= 0
	Local cChave	:= ""
	
	aTemp := fBuscaSuperior(cFilFun, cMatFun, cDepto, aDeptos, cTypeOrg, cVision)
	
	If Len(aTemp) > 0
		If aTemp[1][4] <> 99
			dbSelectArea("SRA")
			SRA->(dbSetOrder(1))
			SRA->(dbSeek(aTemp[1][1] + aTemp[1][2]))
			aadd(aRet, {aTemp[1][1], aTemp[1][2], SRA->RA_EMAIL, SRA->RA_NOME})		
			cChave := aTemp[1][1] + aTemp[1][2]
		EndIf
	EndIf
	
	RestArea(aArea)
	
Return cChave
