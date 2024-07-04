#Include "Protheus.Ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±                             
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RetMod       ³Autor ³ Luciana Pires       ³ Data ³ 05.06.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna codigo do modelo da nota fiscal  de acordo com a    ³±±
±±³          ³DIEF - RJ.	                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RetMod(cEspecie)

Local cNEspecie := GetNewPar('MV_NESPEC',"") 
Local cCodMod:="01" // Default Nota Fiscal
Local lMtRetMod	:=	ExistBlock("MTRETMOD")

Do Case
	Case (AllTrim(cEspecie) == "CTR")
		cCodMod:="16" // Conh.Transp.Rodoviario
	Case (AllTrim(cEspecie) =="NFST")
		cCodMod:="16" // NF Servico de Transporte
	Case (AllTrim(cEspecie) == "NFE")
		cCodMod:="10" // NF Entrada
	Case (AllTrim(cEspecie) == "NFPS")
		cCodMod:="01" // NF Prestacao de Servico
	Case (AllTrim(cEspecie) == "NFS")
		cCodMod:="01" // NF Servico
	Case (AllTrim(cEspecie) == "CF")
		cCodMod:="17" // Cupom Fiscal
	Case (AllTrim(cEspecie) == "NF")
		cCodMod:="01" // NF            
	Case (AllTrim(cEspecie) == "")
		cCodMod:="02" // Fatura
	Case (AllTrim(cEspecie) == "NFF") 
		cCodMod:="02" // Fatura     
	Case (AllTrim(cEspecie) == AllTrim(cNEspecie))
		cCodMod:="04" // Nota Fiscal de Servico Simplificada
    Case lMtRetMod
		cCodMod:= Execblock("MTRETMOD",.F.,.F.,cEspecie)
EndCase

Return (cCodMod)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RetCAliq     ³Autor ³ Luciana Pires       ³ Data ³ 05.06.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ão ³Retorna cod da aliquota de acordo com o manual da DIEF-RJ.  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RetCAliq(cAliquota,cIsento)
Local cCodAliq:="00" // Default Nota Fiscal
Do Case                                                         
	Case (cAliquota == 0.5)
		cCodAliq:="01" 
	Case (cAliquota == 2)
		cCodAliq:="02" 
	Case (cAliquota == 3)
		cCodAliq:="03" 
	Case (cAliquota == 5)
		cCodAliq:="04" 
	Case (cAliquota == 0 .And. AllTrim(cIsento) == "S") 
		cCodAliq:="06" // ISENTO
	Case (cAliquota == 0 .And. AllTrim(cIsento) == "N") 
		cCodAliq:="05" // IMUNE
EndCase

Return (cCodAliq)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DiefRJTmp ºAutor  ³Mary C. Hergert     º Data ³ 18/10/2007  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta a estrutura das notas fiscais a serem apresentadas    º±±
±±º          ³cabecalho - aliquotas - total                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Dief-RJ                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DIEFRJTMP(dDataIni,dDataFin)

Local aTemp 		:= RJGeraTmp(dDataIni,dDataFin)
Local aArea			:= ""

Local cAliasSF3		:= "SF3"
Local cAliasSE2		:= "SE2"
Local cISSRet		:= ""
Local cAutoriza		:= ""
Local cFormIni		:= ""
Local cFormFinal	:= ""
Local cDestaque		:= ""
Local cMunic		:= GetNewPar("MV_CIDADE","")
Local cIsento		:= ""         
Local cDRJSIT		:= GetNewPar("MV_DRJSIT","")
Local cDRJSUB	 	:= GetNewPar("MV_DRJSUB","")
Local cForcont  	:= GetNewPar("MV_FORCONT","")
Local cMun			:= ""
Local cUF			:= ""
Local cTipo			:= ""
Local cSituacao 	:= ""
Local cMotivo		:= ""
Local cDocSub		:= ""
Local cPrestacao 	:= ""
Local cChave        := "" 
Local dDatapag      := CToD("  /  /  ")

Local lQuery		:= .F.
Local lIssRet		:= GetNewPar("MV_F3RECIS",.F.)
Local lPagamento	:= .F.
Local lDRJSIT		:= !Empty(cDRJSIT) 
Local lDRJSUB 		:= !Empty(cDRJSUB) 
Local lForcont 		:= !Empty(cForcont)
Local lLoop         := .F.
Local lRj4          := .F.

Local nId			:= 0
Local nDeducao		:= 0              
Local nTributavel	:= 0
Local nRetido		:= 0

Local aDisp			:=	{"", ""}
Local cLetraNumero	:= GetNewPar('MV_1DUP',"A")


#IFDEF TOP

	Local aCamposSF3	:= {}
	Local aStruSF3		:= {}
	Local aCamposSE2	:= {}
	Local aStruSE2		:= {}
	
	Local cCampos		:= ""
	Local cCodISS		:= ""
	
	Local nX			:= 0

#ELSE

	Local cArqInd		:= ""
	Local cChave		:= ""
	Local cFiltro		:= ""
	
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processamento dos documentos Fiscais                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SF3")
dbSetOrder(1)

#IFDEF TOP
  
    If TcSrvType()<>"AS/400"
 
 		If SerieNfId("SF3",3,"F3_SERIE") == "F3_SDOC"                                          
			cCampos += ", SF3.F3_SDOC" 
		Endif
 
		If lIssRet                                          
			cCampos += ", SF3.F3_RECISS" 
		Endif
                      
		cCampos += ", SF3.F3_ISSMAT" 
                
		If lDRJSIT        
			cCampos += ", " + cDRJSIT
		Endif
		If lDRJSUB                  
			cCampos += ", " + cDRJSUB
		Endif
        If lForcont   
        	cCampos += ", SF3." + cForcont 
        Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Campos que serao adicionados a query somente se existirem na base³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(cCampos)
			cCampos := "%%"
		Else       
			cCampos := "% " + cCampos + " %"
		Endif                              

		lQuery 		:= .T.
		cAliasSF3	:= GetNextAlias()   
			
		BeginSql Alias cAliasSF3
			COLUMN F3_EMISSAO AS DATE
			COLUMN F3_DTCANC AS DATE
			SELECT SF3.F3_FILIAL, SF3.F3_EMISSAO, SF3.F3_NFISCAL, SF3.F3_SERIE, SF3.F3_CLIEFOR, SF3.F3_LOJA, SF3.F3_ALIQICM, SF3.F3_ESPECIE,
				SF3.F3_ISENICM, SF3.F3_VALCONT, SF3.F3_TIPO, SF3.F3_CFO, SF3.F3_VALICM, SF3.F3_DOCOR, SF3.F3_DTCANC, SF3.F3_CODISS, SF3.F3_OBSERV, 
				SF3.F3_ISSSUB, SF3.F3_ISSST, SF3.F3_CNAE, SF3.F3_CFO
				%Exp:cCampos%
				
			FROM %table:SF3% SF3
					
			WHERE SF3.F3_FILIAL = %xFilial:SF3% AND 
			((SF3.F3_EMISSAO >= %Exp:dDataIni% AND
			SF3.F3_EMISSAO <= %Exp:dDataFin%) OR (SF3.F3_DTCANC >= %Exp:dDataIni% AND
			SF3.F3_DTCANC <= %Exp:dDataFin%))AND
			(SF3.F3_TIPO = "S" OR (SF3.F3_TIPO = "L" AND SF3.F3_CODISS <> %Exp:cCodISS%)) AND
			SF3.F3_CFO >= "5" AND
			SF3.%NotDel%
			ORDER BY SF3.F3_EMISSAO,SF3.F3_SERIE,SF3.F3_NFISCAL,SF3.F3_TIPO,SF3.F3_CLIEFOR,SF3.F3_LOJA
		EndSql
   			//GetLastQuery()[2]
		
		dbSelectArea(cAliasSF3)

	Else

#ENDIF
		cArqInd	:=	CriaTrab(NIL,.F.)
		cChave	:=	"DTOS(F3_EMISSAO)+F3_SERIE+F3_NFISCAL+F3_TIPO+F3_CLIEFOR+F3_LOJA"
		cFiltro :=  "F3_FILIAL == '" + xFilial("SF3") + "' .AND. 
		cFiltro	+=	"((DtoS(F3_EMISSAO) >= '" + DtoS(dDataIni) + "' .And. DtoS(F3_EMISSAO) <= '" + DtoS(dDataFin) + "') .OR."
		cFiltro	+=  "(DtoS(F3_DTCANC) >= '" + DtoS(dDataIni) + "' .And. DtoS(F3_DTCANC) <= '" + DtoS(dDataFin) + "'))
		cFiltro	+=  ".And. F3_CFO >= '5' .And. "
		cFiltro	+=	"(F3_TIPO == 'S' .Or. "
		cFiltro	+=	"(F3_TIPO == 'L' .And. !EMPTY(F3_CODISS))) "
			
		IndRegua(cAliasSF3,cArqInd,cChave,,cFiltro,"Selecionando Registros")
		#IFNDEF TOP
			DbSetIndex(cArqInd+OrdBagExt())
		#ENDIF                
		(cAliasSF3)->(dbGotop())

#IFDEF TOP
	Endif    
#ENDIF

SA1->(dbSetOrder(1))

dbSelectArea(cAliasSF3)
ProcRegua(LastRec())
(cAliasSF3)->(DbGoTop())

While (cAliasSF3)->(!Eof())                  

	IncProc()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica o cliente do movimento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCNPJ		:= ""
	If !(SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA)))
		(cAliasSF3)->(dbSkip())
		Loop
	Endif 
	cCNPJ		:= SA1->A1_CGC
	cISSRet 	:= SA1->A1_RECISS
	If Empty(cISSRet)
		cISSRet := "2"
	Endif
	cMun		:= SA1->A1_MUN
	cUF			:= SA1->A1_EST
	cTipo		:= RetPessoa(SA1->A1_CGC)
	cTpNota		:= "S"
	
	If lIssRet       
		cISSRet := (cAliasSF3)->F3_RECISS
	Endif
	             
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o movimento e isento de ISS³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cAliasSF3)->F3_ISENICM > 0
		cIsento := "S"
	Else
		cIsento	:= "N"
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Autorizacao AIDF³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(RetAIDF((cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE)) >= 7
		cAutoriza	:= RetAIDF((cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE)[7]
		If (LeFCAIDF(@aDisp, cAliasSF3))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorno array com o conteudo dos campos relacionados no paramentro MV_FORCONT exista no dicionario de dados³
			//³[1] = Numero do formulario continuo inicial                                                                ³
			//³[2] = Numero do formulario continuo final                                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cFormIni	:= aDisp[1]
			cFormFinal	:= aDisp[2]
           
		Else
			cFormIni	:= RetAIDF((cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE)[3]
			cFormFinal	:= RetAIDF((cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE)[4]
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Destaque do ISS³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cISSRet $ "1S"
		cDestaque := "1"
	Else
		cDestaque := "2"
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o imposto sera pago fora do municipio³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty((cAliasSF3)->F3_ISSST) .And. (cAliasSF3)->F3_ISSST == "2" .And. !(cMunic$cMun)
		lPagamento := .T.
	Else
		lPagamento := .F.
	Endif   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existem deducoes legais³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nDeducao := 0
	nDeducao += (cAliasSF3)->F3_ISSSUB                           
	nDeducao += (cAliasSF3)->F3_ISSMAT
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valor tributado no movimento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Year(dDataIni) > 2006
		nTributavel := 0
	Else
		If cDestaque == "1"
			nTributavel := (cAliasSF3)->F3_VALCONT
		Else 
			nTributavel := 0
		Endif
	Endif	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cabecalho do documento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !RJ2->(dbSeek(DTOS((cAliasSF3)->F3_EMISSAO)+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_ESPECIE+(cAliasSF3)->F3_SERIE+cTpNota))
	
		RecLock("RJ2",.T.)
		
		nId += 1
		
		RJ2->ID_CAB	:= StrZero(nId,10)
		RJ2->TIPO		:= cTpNota
		RJ2->EMISSAO	:= (cAliasSF3)->F3_EMISSAO
		RJ2->ESPECIE	:= RetMod((cAliasSF3)->F3_ESPECIE)
		RJ2->ESPECF3	:= (cAliasSF3)->F3_ESPECIE
		RJ2->SERIE		:= (cAliasSF3)->F3_SERIE
		RJ2->DOCTO		:= (cAliasSF3)->F3_NFISCAL
		RJ2->DOCOR		:= (cAliasSF3)->F3_DOCOR         
		RJ2->FORMINI	:= cFormIni
		RJ2->FOMRFIN	:= cFormFinal
	  	RJ2->CLIEFOR 	:= (cAliasSF3)->F3_CLIEFOR         
		RJ2->LOJA    	:= (cAliasSF3)->F3_LOJA
		RJ2->SDOC    	:= SerieNfId(cAliasSF3 , 2 , "F3_SERIE")           
		
		If !Empty((cAliasSF3)->F3_DOCOR)
			RJ2->TIPOTOM := "0"
		Else
			If cUF == "EX"
				RJ2->TIPOTOM := "3"
			Else
				If cTipo == "J"
					RJ2->TIPOTOM := "2"
				Else
					RJ2->TIPOTOM :="1"
				Endif
			Endif
		Endif
		
		If !Empty((cAliasSF3)->F3_DOCOR)
			RJ2->CNPJ	:= "0"
		Else
			RJ2->CNPJ	:= cCNPJ
		Endif
		
		RJ2->IDENTAUT	:= cAutoriza
		
		If Year(dDataIni) > 2006
			RJ2->DESTAQUE	:= "2"        
		Else
			RJ2->DESTAQUE	:= cDestaque
		Endif     
		
		cPrestacao := "1"
		
		If !Empty((cAliasSF3)->F3_DTCANC) .And. month (dDataIni) == month((cAliasSF3)->F3_DTCANC)
			RJ2->DTCANC 	:= (cAliasSF3)->F3_DTCANC 
								
			If lDRJSIT
				cSituacao	:= (cAliasSF3)->&(cDRJSIT)
			Else
				cSituacao	:= "4"
			Endif
			
			If lDRJSUB        
				cDocSub		:= (cAliasSF3)->&(cDRJSUB)
			Else                   
				cDocSub		:= "0"
			Endif
			
			//Preenchimento padrao quando nao ha informacao no SF3
			If Empty(cSituacao)
				cSituacao := "4"
			Endif              
			
			If Empty(cDocSub)
				cDocSub := "0"
			Endif              
			
			cMotivo	:= (cAliasSF3)->F3_OBSERV
			
			Do Case
				Case cSituacao == "1"
					cMotivo		:= ""
					cDocSub		:= "0"
					cSituacao	:= "2"
					cPrestacao	:= "2"
				Case cSituacao == "2"
					cMotivo		:= ""
					cDocSub		:= "0"
					cPrestacao	:= "2"
				Case cSituacao == "3"  
					cDocSub		:= "0"
					cPrestacao	:= "2"
				Case cSituacao == "4"
				
			EndCase
			
			RJ2->SITUACAO 	:= cSituacao 
			RJ2->DOCSUB		:= cDocSub
			RJ2->MOTIVO		:= cMotivo
			
		Endif
		       
		RJ2->PRESTSERV	:= cPrestacao
		
		MsUnLock()
		
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Aliquotas do movimento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RecLock("RJ3",.T.)
	
	RJ3->ID_CAB		:= StrZero(nId,10)                                     

	If lPagamento
		RJ3->ALIQ	:= "08"
	Else 
		RJ3->ALIQ	:= RetCAliq((cAliasSF3)->F3_ALIQICM,cIsento)
	Endif
	 
	RJ3->ATIVID		:= (cAliasSF3)->F3_CNAE
	RJ3->VALSERV	:= (cAliasSF3)->F3_VALCONT
	RJ3->VALDED		:= nDeducao
	
	If lPagamento .And. cTpNota == "S"
		nRetido	:= 0
	Else
		If cISSRet $ "1S"
			If cTpNota == "S" 
				nRetido	:= (cAliasSF3)->F3_VALICM
			Else
				nRetido	:= 0
			Endif        
		Else               
			If cTpNota == "S" 
				nRetido	:= 0
			Else
				nRetido	:= (cAliasSF3)->F3_VALICM
			Endif
		Endif                  
	Endif
	
	RJ3->VALRET := nRetido
	
	MsUnLock()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Totais do documento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If RJ4->(dbSeek(StrZero(nId,10)))
		RecLock("RJ4",.F.)
		RJ4->TOTTRIB 	+= nTributavel
		RJ4->RETIDO		+= nRetido
		RJ4->SERVICO	+= (cAliasSF3)->F3_VALCONT
		RJ4->TOTDOC		+= (cAliasSF3)->F3_VALCONT
	Else
		RecLock("RJ4",.T.)
		RJ4->ID_CAB 	:= StrZero(nId,10)
		RJ4->TOTTRIB 	:= nTributavel
		RJ4->RETIDO		:= nRetido
		RJ4->TOTDOC		:= (cAliasSF3)->F3_VALCONT
		RJ4->SERVICO	:= (cAliasSF3)->F3_VALCONT
	Endif

	MsUnLock()	
	
	(cAliasSF3)->(dbSkip())

Enddo          

If !lQuery
	RetIndex("SF3")	
	dbClearFilter()	
	Ferase(cArqInd+OrdBagExt())
Else
	dbSelectArea(cAliasSF3)
	dbCloseArea()
Endif
   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para inclusao da data de pagamento da NF      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "DIEFRJPG" )   
	aArea = GetArea()
	ExecBlock( "DIEFRJPG", .F., .F., { dDataIni,dDataFin }, .F. ) 
	RestArea(aArea)
Else      
	If ((Select ("SE2CPY"))<>0)
		SE2CPY->(DbCloseArea ())
	EndIf
	ChkFile ("SE2", .F., "SE2CPY")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processamento dos documentos Fiscais de Entrada                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SE2")
	dbSetOrder(1)
	
	#IFDEF TOP
	  
	    If TcSrvType()<>"AS/400"   
	    
	   		lQuery 		:= .T.
			cAliasSE2	:= GetNextAlias()   
	    
			BeginSql Alias cAliasSE2
				COLUMN E2_BAIXA AS DATE
				SELECT SE2.E2_BAIXA, SE2.E2_FORNECE, SE2.E2_LOJA, SE2.E2_NUM ,SE2.E2_PREFIXO,SE2.E2_PARCELA, SE2.E2_VALOR, SE2.E2_ISS
					
				FROM %table:SE2% SE2
						
				WHERE SE2.E2_FILIAL = %xFilial:SE2% AND 
				SE2.E2_BAIXA >= %Exp:dDataIni% AND
				SE2.E2_BAIXA <= %Exp:dDataFin% AND 
				SE2.E2_TIPO = "NF " AND
				SE2.%NotDel%
				ORDER BY SE2.E2_FORNECE,SE2.E2_LOJA,SE2.E2_NUM,SE2.E2_PREFIXO
			EndSql
	    
			dbSelectArea(cAliasSE2)
		Else
	
	#ENDIF
			cArqInd	:=	CriaTrab(NIL,.F.)
			cChave	:=	"E2_FORNECE,E2_LOJA,E2_NUM,E2_PREFIXO"
			cFiltro :=  "E2_FILIAL == '" + xFilial("SE2") + "' .AND. E2_TIPO == 'NF ' .AND.
			cFiltro	+=	"DtoS(E2_BAIXA) >= '" + DtoS(dDataIni) + "' .And. DtoS(E2_BAIXA) <= '" + DtoS(dDataFin) + "'"
				
			IndRegua(cAliasSE2,cArqInd,cChave,,cFiltro,"Selecionando Registros")
			#IFNDEF TOP
				DbSetIndex(cArqInd+OrdBagExt())
			#ENDIF                
			(cAliasSE2)->(dbGotop())
	
	#IFDEF TOP
		Endif    
	#ENDIF
	
	SA2->(dbSetOrder(1))
	
	dbSelectArea(cAliasSE2)
	ProcRegua(LastRec())
	(cAliasSE2)->(DbGoTop())
	
	While (cAliasSE2)->(!Eof())                  
	
        If cChave<> xFilial("SE2")+(cAliasSE2)->(E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM)
        	lLoop	:=	.T.
        EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|Se for PARCELAMENTO, utiliza APENAS a primeira parcela paga             |
		//| De acordo com tratamento informado pela Sefaz-RJ, sera usado APENAS a  |
		//|    	primeira parcela e sera desconsiderada as parcelas seguintes.      |
	   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SE2CPY->(DbSetOrder(6))
		If  SE2CPY->(DbSeek(xFilial("SE2")+(cAliasSE2)->(E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM)))
			While SE2CPY->(!Eof()) .And.;
				SE2CPY->(E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM)==(cAliasSE2)->(E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) .And. lLoop
				If !Empty(SE2CPY->E2_BAIXA)   
					If SE2CPY->E2_BAIXA <= dDatapag .Or. Empty(dDatapag)
						dDatapag := SE2CPY->E2_BAIXA
						cChave   := xFilial("SE2")+(cAliasSE2)->(E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM)
					EndIf
					If dDatapag >= dDataIni .And. dDatapag <= dDataFin
						lRj4	:= .T.
					EndIf
				EndIf
			SE2CPY->(dbSkip())
			Enddo
			lLoop	:= .F.
		EndIf
		
	    SF3->(DbSetOrder(4))
    	SF3->(DbSeek(xFilial("SF3")+(cAliasSE2)->E2_FORNECE+(cAliasSE2)->E2_LOJA+(cAliasSE2)->E2_NUM+(cAliasSE2)->E2_PREFIXO))

	    cChave	:=	xFilial("SF3")+(cAliasSE2)->E2_FORNECE+(cAliasSE2)->E2_LOJA+(cAliasSE2)->E2_NUM+(cAliasSE2)->E2_PREFIXO
    	Do While SF3->(!EOF()) .And. cChave == xFilial("SF3")+(cAliasSE2)->E2_FORNECE+(cAliasSE2)->E2_LOJA+(cAliasSE2)->E2_NUM+(cAliasSE2)->E2_PREFIXO

    	If  (SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE)==(cAliasSE2)->E2_FORNECE+(cAliasSE2)->E2_LOJA+(cAliasSE2)->E2_NUM+(cAliasSE2)->E2_PREFIXO .And.;
		   	(SF3->F3_TIPO == "S" .Or. (SF3->F3_TIPO == "L" .And. !EMPTY(SF3->F3_CODISS))) .And. SubStr(SF3->F3_CFO,1,1) $ "123"
	       		
			IncProc()
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica o fornecedor do movimento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCNPJ		:= ""
			If !(SA2->(dbSeek(xFilial("SA2")+SF3->F3_CLIEFOR+SF3->F3_LOJA)))
				SF3->(dbSkip())
				Loop
			Endif 
			cCNPJ		:= SA2->A2_CGC
			cISSRet 	:= SA2->A2_RECISS
			If Empty(cISSRet)
				cISSRet := "1"
			Endif
			cMun		:= SA2->A2_MUN
			cUF			:= SA2->A2_EST
			cTipo		:= RetPessoa(SA2->A2_CGC)
			cTpNota		:= "E"
			
			If lIssRet       
				cISSRet := SF3->F3_RECISS
			Endif
			             
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se o movimento e isento de ISS³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SF3->F3_ISENICM > 0
				cIsento := "S"
			Else
				cIsento	:= "N"
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Destaque do ISS³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cISSRet $ "1S" 
				cDestaque := "2"
			Else
				cDestaque := "1"
			Endif
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se o imposto sera pago fora do municipio³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(SF3->F3_ISSST) .And. SF3->F3_ISSST == "2" .And. !(cMunic$cMun)
				lPagamento := .T.
			Else
				lPagamento := .F.
			Endif   
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se existem deducoes legais³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nDeducao := 0
			nDeducao += SF3->F3_ISSSUB                           
			nDeducao += SF3->F3_ISSMAT
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valor tributado no movimento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Year(dDataIni) > 2006
				nTributavel := 0
			Else
				If cDestaque == "1"
					nTributavel := SF3->F3_VALCONT
				Else 
					nTributavel := 0
				Endif
			Endif	
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Cabecalho do documento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !RJ2->(dbSeek(DTOS(SF3->F3_EMISSAO)+SF3->F3_NFISCAL+SF3->F3_ESPECIE+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA+cTpNota))
					
				RecLock("RJ2",.T.)
				
				nId += 1
				
				RJ2->ID_CAB		:= StrZero(nId,10)
				RJ2->TIPO		:= cTpNota
				RJ2->EMISSAO	:= SF3->F3_EMISSAO
				RJ2->ESPECIE	:= Iif(!Empty((cAliasSE2)->E2_PARCELA),"14",RetMod(SF3->F3_ESPECIE))				
				RJ2->ESPECF3	:= SF3->F3_ESPECIE
				RJ2->SERIE		:= SF3->F3_SERIE
				RJ2->DOCTO		:= SF3->F3_NFISCAL
				RJ2->DOCOR		:= SF3->F3_DOCOR
				RJ2->DTPAGTO 	:= (cAliasSE2)->E2_BAIXA 
				RJ2->SDOC    	:= SerieNfId("SF3", 2 , "F3_SERIE") 				   
				
				If !Empty(SF3->F3_DOCOR)
					RJ2->TIPOTOM := "0"
				Else
					If cUF == "EX"
						RJ2->TIPOTOM := "3"
					Else
						If cTipo == "J"
							RJ2->TIPOTOM := "2"
						Else
							RJ2->TIPOTOM :="1"
						Endif
					Endif
				Endif
				
				If !Empty(SF3->F3_DOCOR)
					RJ2->CNPJ	:= "0"
				Else
					RJ2->CNPJ	:= cCNPJ
				Endif
				
				RJ2->IDENTAUT	:= cAutoriza
				
				If Year(dDataIni) > 2006
					RJ2->DESTAQUE	:= "2"        
				Else
					RJ2->DESTAQUE	:= cDestaque
				Endif     
				
				cPrestacao := "1"
				
			If	!Empty(SF3->F3_DTCANC)	.And.	month(RJ2->DTCANC) == month(SF3->F3_DTCANC)
		   			RJ2->DTCANC 	:= SF3->F3_DTCANC 
					
					If lDRJSIT
						cSituacao	:= SF3->&(cDRJSIT)
					Else
						cSituacao	:= "4"
					Endif
					
					If lDRJSUB        
						cDocSub		:= SF3->&(cDRJSUB)
					Else                   
						cDocSub		:= "0"
					Endif
					
					//Preenchimento padrao quando nao ha informacao no SF3
					If Empty(cSituacao)
						cSituacao := "4"
					Endif              
					
					If Empty(cDocSub)
						cDocSub := "0"
					Endif              
					
					cMotivo	:= SF3->F3_OBSERV
					
					Do Case
						Case cSituacao == "1"
							cMotivo		:= ""
							cDocSub		:= "0"
							cSituacao	:= "2"
							cPrestacao	:= "2"
						Case cSituacao == "2"
							cMotivo		:= ""
							cDocSub		:= "0"
							cPrestacao	:= "2"
						Case cSituacao == "3"  
							cDocSub		:= "0"
							cPrestacao	:= "2"
						Case cSituacao == "4"
						
					EndCase
					
					RJ2->SITUACAO 	:= cSituacao 
					RJ2->DOCSUB		:= cDocSub
					RJ2->MOTIVO		:= cMotivo
					
				Endif
				       
				RJ2->PRESTSERV	:= cPrestacao
				
				MsUnLock()
				
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Aliquotas do movimento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("RJ3",.T.)
			
			RJ3->ID_CAB		:= StrZero(nId,10)                                     
		
			If lPagamento
				RJ3->ALIQ	:= "08"
			Else 
				RJ3->ALIQ	:= RetCAliq(SF3->F3_ALIQICM,cIsento)
			Endif

			RJ3->ATIVID		:= SF3->F3_CNAE     			
			RJ3->VALSERV	:= SF3->F3_VALCONT
			RJ3->VALDED		:= nDeducao
			
			If lPagamento .And. cTpNota == "S"
				nRetido	:= 0
			Else
				If cISSRet $ "1S"
					nRetido	:= 0
				Else
					If !Empty((cAliasSE2)->E2_PARCELA) //verifica se e' parcela
						nRetido := SF3->F3_ICMSRET
					Else
						nRetido	:= SF3->F3_VALICM
					EndIf
				Endif                  
			Endif
			
			RJ3->VALRET := nRetido
			
			MsUnLock()
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Totais do documento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRj4
				RecLock("RJ4",.T.)
				RJ4->ID_CAB 	:= StrZero(nId,10)
				RJ4->TOTTRIB 	:= nTributavel
				RJ4->TOTDOC		:= SF3->F3_VALCONT
				RJ4->SERVICO	:= SF3->F3_VALCONT
				RJ4->RETIDO		:= nRetido
				lRj4            := .F.
    	    EndIf
		    
			MsUnLock()
		EndIf	
	   	SF3->(DbSkip())
   	Enddo              
   	
   		(cAliasSE2)->(dbSkip())
	Enddo
	
	If !lQuery
		RetIndex("SE2")	
		dbClearFilter()	
		Ferase(cArqInd+OrdBagExt())
	Else
		dbSelectArea(cAliasSE2)
		dbCloseArea()
	Endif
EndIf

Return(aTemp)                       
                          
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RJGeraTmp ºAutor  ³Mary C. Hergert     º Data ³ 18/10/2007  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria as tabelas temporarias                                 º±±
±±º          ³cabecalho - aliquotas - total                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³aTemp: [01] Alias do temporario                             º±±
±±º          ³       [02] Nome fisico da tabela temporaria                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Dief-RJ                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RJGeraTmp()

Local aTemp 	:= {}
Local aCab		:= {}
Local aAliq		:= {}
Local aTotal	:= {}

Local cArqCab	:= ""
Local cArqAliq	:= ""
Local cArqTot	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cabecalho do documento fiscal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aCab,{"ID_CAB"		,"C",015,0})
AADD(aCab,{"TIPO"			,"C",001,0})
AADD(aCab,{"EMISSAO"		,"D",008,0})
AADD(aCab,{"ESPECIE"		,"C",TamSX3("F3_ESPECIE")[01],0})
AADD(aCab,{"ESPECF3"		,"C",TamSX3("F3_ESPECIE")[01],0})
AADD(aCab,{"SERIE"		,"C",TamSX3("F3_SERIE")[01],0})
AADD(aCab,{"DOCTO"		,"C",TamSX3("F3_NFISCAL")[01],0})
AADD(aCab,{"DOCOR"		,"C",TamSX3("F3_DOCOR")[01],0})
AADD(aCab,{"FORMINI"		,"C",TamSX3("F3_NFISCAL")[01],0})
AADD(aCab,{"FOMRFIN"		,"C",TamSX3("F3_NFISCAL")[01],0})
AADD(aCab,{"TIPOTOM"		,"C",1,0})
AADD(aCab,{"CNPJ"			,"C",14,0})
AADD(aCab,{"IDENTAUT"	,"C",12,0})
AADD(aCab,{"PRESTSERV"	,"C",1,0})
AADD(aCab,{"DESTAQUE"	,"C",1,0})
AADD(aCab,{"SITUACAO"	,"C",1,0})
AADD(aCab,{"DTCANC"		,"D",8,0})
AADD(aCab,{"DOCSUB"		,"C",TamSX3("F3_NFISCAL")[01],0})
AADD(aCab,{"MOTIVO"		,"C",250,0})
AADD(aCab,{"DTPAGTO"    ,"D",008,0})
AADD(aCab,{"CLIEFOR"    ,"C",6,0})
AADD(aCab,{"LOJA"      	,"C",2,0})
AADD(aCab,{"SDOC"			,"C",003,0})
cArqCab	:=	CriaTrab(aCab)
dbUseArea(.T.,__LocalDriver,cArqCab,"RJ2")
IndRegua("RJ2",cArqCab,"DTOS(EMISSAO)+DOCTO+ESPECF3+SERIE+TIPO+CLIEFOR+LOJA")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Aliquotas do documento fiscal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aAliq,{"ID_CAB"	,"C",015,0})
AADD(aAliq,{"ALIQ"		,"C",002,0})
AADD(aAliq,{"ATIVID"	,"C",006,0})
AADD(aAliq,{"VALSERV"	,"N",TamSX3("F3_VALCONT")[01],TamSX3("F3_VALCONT")[02]})
AADD(aAliq,{"VALDED"	,"N",TamSX3("F3_VALCONT")[01],TamSX3("F3_VALCONT")[02]})
AADD(aAliq,{"VALRET"	,"N",TamSX3("F3_VALCONT")[01],TamSX3("F3_VALCONT")[02]})
cArqAliq	:=	CriaTrab(aAliq)
dbUseArea(.T.,__LocalDriver,cArqAliq,"RJ3")
IndRegua("RJ3",cArqAliq,"ID_CAB+ALIQ")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Totais do documento fiscal   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aTotal,{"ID_CAB"	,"C",015,0})
AADD(aTotal,{"TOTTRIB"	,"N",TamSX3("F3_VALCONT")[01],TamSX3("F3_VALCONT")[02]})
AADD(aTotal,{"TOTDOC"	,"N",TamSX3("F3_VALCONT")[01],TamSX3("F3_VALCONT")[02]})
AADD(aTotal,{"SERVICO"	,"N",TamSX3("F3_VALCONT")[01],TamSX3("F3_VALCONT")[02]})
AADD(aTotal,{"RETIDO"	,"N",TamSX3("F3_VALCONT")[01],TamSX3("F3_VALCONT")[02]})
cArqTot	:=	CriaTrab(aTotal)
dbUseArea(.T.,__LocalDriver,cArqTot,"RJ4")
IndRegua("RJ4",cArqTot,"ID_CAB")

aTemp	:=	{{cArqCab,"RJ2"},{cArqAliq,"RJ3"},{cArqTot,"RJ4"}}

Return(aTemp)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao   ³RJDelArq   ºAutor  ³ Mary C. Hergert    º Data ³ 18/10/2007  º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³Apaga arquivos temporarios criados para gerar o arquivo      º±±
±±º         ³Magnetico                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³DiefRJ                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RJDelArq(aDelArqs)

Local aAreaDel	:= GetArea()

Local nI 		:= 0

For nI := 1 To Len(aDelArqs)

	If File(aDelArqs[ni,1]+GetDBExtension())
		dbSelectArea(aDelArqs[ni,2])
		dbCloseArea()
		Ferase(aDelArqs[ni,1]+GetDBExtension())
		Ferase(aDelArqs[ni,1]+OrdBagExt())
	Endif	

Next

RestArea(aAreaDel)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RJStr     ºAutor  ³Mary Hergert        º Data ³ 18/10/2007  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Montar um array apenas com os campos utiLizados na query    º±±
±±º          ³para passagem na funcao TCSETFIELD                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Array com os campos da query                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³aCampos: campos a serem tratados na query                   º±±
±±º          ³cCmpQry: string contendo os campos para select na query     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³RJStr                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
#IFDEF TOP

	Static Function RJStr(aCampos,cCmpQry)
	
	Local	aRet	:=	{}
	Local	nX		:=	0
	Local	aTamSx3	:=	{}
	
	For nX := 1 To Len(aCampos)
		If(FieldPos(aCampos[nX])>0)
			aTamSx3 := TamSX3(aCampos[nX])
			aAdd (aRet,{aCampos[nX],aTamSx3[3],aTamSx3[1],aTamSx3[2]})
			cCmpQry	+=	aCampos[nX]+", "
		EndIf
	Next(nX)
	
	If(Len(cCmpQry)>0)
		cCmpQry	:=	" " + SubStr(cCmpQry,1,Len(cCmpQry)-2) + " "
	EndIf 
		
	Return(aRet)        
	
#ENDIF

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³LeFCAIDF   ³ Autor ³Luciana Pires         ³ Data ³26.08.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que retorna em uma array passado como referencia    ³±±
±±³          ³ as informacoes sobre o formulario continuo autorizado      |±±
±±³          ³ para o documento fiscal 									  |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> .T. se os campos existirem e possuirem conteudo ou  ³±±
±±³          ³ .F. caso contrario.                                        |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA -> valores contidos no parametro MV_FORCONT            ³±±
±±³          ³aDisp -> Array passado por ref que contera os campos do SF3 ³±±
±±³          ³ExpC -> Alias para a tabela SF3 em processamento            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/	
Static Function LeFCAIDF(aDisp, cSF3)
	Local	cMVFORCONT	:=	GetNewPar("MV_FORCONT","")	//Campo da tabela SF3 que possuem os campos com numero do formulario de impressao da NF
	Local	lRet		:=	.F.
	Local	nAtCntSF	:=	0
	Local	cCntSF		:=	""
	//
	aDisp				:=	{"", ""}
	//
	If !(Empty(cMVFORCONT))
		If (SF3->(FieldPos(cMVFORCONT))>0)
			cCntSF	:=	(cSF3)->&(cMVFORCONT)
		EndIf
		cCntSF	:=	AllTrim(Iif(ValType(cCntSF)=="N", Str(cCntSF),cCntSF))

		//Somente se os campos existirem
		If !(Empty(cCntSF))
			lRet		:= .T.
			nAtCntSF 	:= At(";",cCntSF)
			If nAtCntSF > 0	//Possibilito interpretacao do campo quando tiver o numero do form continuo inicial e final seprada por ";"
				aDisp[1]	:=	SubStr(cCntSF,1,nAtCntSF-1)						//Form Continuo incial
				aDisp[2]	:=	SubStr(cCntSF,nAtCntSF+1,Len(cCntSF))			//Form Continuo final
			Else
				aDisp[1]	:=	cCntSF											//Form Continuo incial
				aDisp[2]	:=	cCntSF				  							//Form Continuo final
			EndIf
		EndIf
	EndIf
Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIEF-RJ    ³ Autor ³ Murilo Alves         ³ Data ³23.01.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que retorna o X3_RELACAO de um campo especifico     ³±±
±±³          ³                                                            |±±
±±³          ³    									                      |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Conteudo do X3_RELACAO de um determinado campo              |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetornaRelacao(cCampo)                                              

Local cDescr   := ""
Local aAreaSX3 := {}
Local aAreaAtu := GetArea()

dbSelectArea("SX3")
aAreaSX3 := GetArea()
dbSetOrder(2)
If 	SX3->(dbSeek(cCampo))
	cDescr := X3_RELACAO
Else
	cDescr := cCampo
EndIf
RestArea(aAreaSX3)
RestArea(aAreaAtu)

Return(cDescr)
