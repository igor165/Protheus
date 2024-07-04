#Include "Protheus.Ch"          


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³EDISC     ³ Autor ³  Cleber S. A. Santos  ³ Data ³ 28.09.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³EDISC - Informações de Cargas Transportadas através do      ³±±
±±³          ³Estado de Santa Catarina - SC                        		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ProcEDISC(cFilori,cViagem)
Local aTrbs := {}


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera arquivos temporarios            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTrbs := GeraTemp()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa Registros                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
ProcReg(cFilori,cViagem)                          

Return( aTrbs )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcReg    ³ Autor ³Cleber S. A. Santos    ³ Data ³ 28.09.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa os documentos contidos nas Cargas                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcReg(cFilori,cViagem)
Local aDud          := {"DUD",""}
Local aDtx          := {"DTX",""}
Local aDtc          := {"DTC",""}
Local cModelo       := ""

DTX->(dbSetOrder(3))
FsQuery(aDtx,1,"DTX_FILIAL='"+ xFilial("DTX") +"' AND DTX_FILORI='"+ cFilori+"' AND DTX_VIAGEM='"+  cViagem +"'","DTX_FILIAL=='"+ xFilial("DTX") +"' .AND. DTX_FILORI=='"+ cFilori+"' .AND. DTX_VIAGEM=='"+ cViagem+"'",DTX->(IndexKey()))
DTX->(dbGotop())

Do While !DTX->(Eof ())
	
	DUD->(dbSetOrder(5))
	FsQuery(aDud,1,"DUD_FILIAL='"+ xFilial("DUD") +"' AND DUD_FILORI='"+ DTX->DTX_FILORI +"' AND DUD_VIAGEM='"+ DTX->DTX_VIAGEM+"' AND DUD_FILMAN='"+ DTX->DTX_FILMAN+"' AND DUD_MANIFE='"+ DTX->DTX_MANIFE+"'","DUD_FILIAL=='"+xFilial("DUD")+"' .AND. DUD_FILORI=='"+ DTX->DTX_FILORI +"' .AND. DUD_VIAGEM=='"+ DTX->DTX_VIAGEM +"' .AND. DUD_FILMAN=='"+ DTX->DTX_FILMAN+"' .AND. DUD_MANIFE=='"+ DTX->DTX_MANIFE+"'",DUD->(IndexKey()))
	DUD->(dbGotop())
	
	Do While !DUD->(Eof ())
		
		DT6->(dbSetOrder(1))
		DT6->(dbSeek(xFilial("DT6")+DUD->DUD_FILDOC+DUD->DUD_DOC+DUD->DUD_SERIE))
		
		DTC->(dbSetOrder(7))//Usa-se esse indice para que ele traga em ordem as notas fiscais
		SA1->(dbSetOrder(1))
		SB1->(dbSetOrder(1))
		SBM->(dbSetOrder(1))
		
		
		FsQuery(aDtc,1,"DTC_FILIAL='"+ xFilial("DTC") +"' AND DTC_FILDOC='"+ DT6->DT6_FILDOC +"' AND DTC_DOC='"+ DT6->DT6_DOC +"' AND DTC_SERIE='"+ DT6->DT6_SERIE+"'","DTC_FILIAL=='"+xFilial("DTC")+"' .AND. DTC_FILDOC=='"+ DT6->DT6_FILDOC +"' .AND. DTC_DOC=='"+ DT6->DT6_DOC+"' .AND. DTC_SERIE=='"+ DT6->DT6_SERIE+"'",DTC->(IndexKey()))
		DTC->(dbGotop())
		
		Do While !DTC->(Eof())
			
			SB1->(dbSeek(xFilial("SB1")+DTC->DTC_CODPRO))
			SBM->(dbSeek(xFilial("SBM")+SB1->B1_GRUPO))
			
			cModelo := DTC->DTC_MODELO
			
			dbSelectArea("RT2")
			
			If RT2->(dbseek(DT6->DT6_DOC +DTC->DTC_NUMNFC+DTC->DTC_SERNFC))
				RecLock("RT2",.F.)
			Else
				RecLock("RT2",.T.)
			Endif
			
			SA1->(dbSeek(xFilial("SA1")+DT6->DT6_CLIREM+DT6->DT6_LOJREM))
			
			RT2->CNPJREM    	:= SA1->A1_CGC
			RT2->TPREGEMI   	:= "2"
			RT2->TPCADEMI   	:= "0"
			RT2->INSCREM    	:= SA1->A1_INSCR
			RT2->NOMEREM    	:= SA1->A1_NOME
			RT2->DTEMIREM   	:= "0001-01-01T00:00:00.0000000-02:00"
			RT2->TIPODOCR   	:=	"0"
			RT2->UFEMIT     	:= SA1->A1_EST
			SA1->(dbSeek(xFilial("SA1")+DT6->DT6_CLIDES+DT6->DT6_LOJDES))
			
			RT2->CNPJDEST   	:= SA1->A1_CGC
			RT2->TPREGDES   	:= "2"
			RT2->TPCADDES   	:= "0"
			RT2->INSCDEST   	:= SA1->A1_INSCR
			RT2->NOMEDEST   	:= SA1->A1_NOME
			RT2->DTEMIDEST  	:= "0001-01-01T00:00:00.0000000-02:00"
			RT2->TIPODOCD   	:= "0"
			RT2->UFDEST     	:= SA1->A1_EST
			RT2->NF        	:= DTC->DTC_NUMNFC
			RT2->SERIE      	:= DTC->DTC_SERNFC
			RT2->SUBSERIE   	:= ""
			RT2->MODELO     	:= Iif(Empty (cModelo),"1",cModelo)
			RT2->DTEMI      	:= SUBSTR(DTOS(DTC->DTC_EMINFC),1,4) +"-"+ SUBSTR(DTOS(DTC->DTC_EMINFC),5,2) +"-"+SUBSTR(DTOS(DTC->DTC_EMINFC),7,2)+ "T00:00:00.0000000-02:00"
			RT2->CODMER     	:= Iif(Empty (SBM->BM_TIPGRU),"0",SBM->BM_TIPGRU)
			RT2->NATURE     	:= Iif(Empty (DTC->DTC_CF),"0",DTC->DTC_CF)
			RT2->QUANT      	+= DTC->DTC_QTDVOL
			RT2->CODUNI		:= Iif(Empty (DTC->DTC_CODEMB),"0",DTC->DTC_CODEMB)
			RT2->BASEICM    	+= DTC->DTC_BASICM
			RT2->VALORICM   	+= DTC->DTC_VALICM
			RT2->BASESUB    	+= DTC->DTC_BASESU
			RT2->ICMSUBST   	+= DTC->DTC_ICMRET
			RT2->VALORNF    	+= DTC->DTC_VALOR
			RT2->DTTRANS    	:= "0001-01-01T00:00:00.0000000-02:00"
			RT2->NROCON     	:= DT6->DT6_DOC
			RT2->SDOC      	:= SerieNfId("DTC",2,"DTC_SERNFC")

			MsUnlock()
			
			DTC->(dbSkip())
			
		Enddo
		FsQuery (aDtc,2,)
		
		DUD->(dbSkip())
	Enddo
	FsQuery (aDud,2,)
	
	DTX->(dbSkip())
Enddo
FsQuery (aDtx,2,)

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GeraTemp   ³ Autor ³Cleber S. A. Santos    ³ Data ³ 22.03.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera arquivos temporarios                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraTemp()
Local aStru2	:= {}
Local aTrbs		:= {}
Local cArq		:= ""
	                        
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 2 - Informações das Notas Fiscais (Detalhe)   								       				  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru2	:= {}
cArq	:= ""
AADD(aStru2,{"CNPJREM"    	,"C" ,014 ,0})	//CNPJ REMETENTE
AADD(aStru2,{"TPREGEMI"    	,"C" ,001 ,0})	//Tipo do Registro
AADD(aStru2,{"TPCADEMI"    	,"C" ,001 ,0})	//Tipo de Cadastro
AADD(aStru2,{"INSCREM"    	,"C" ,018 ,0})	//INSCRICAO ESTADUAL REMETENTE
AADD(aStru2,{"NOMEREM"    	,"C" ,040 ,0})	//RAZAO SOCIAL REMETENTE    
AADD(aStru2,{"DTEMIREM"   	,"C" ,033 ,0})	//DATA EMISSAO PESSOA FISICA        
AADD(aStru2,{"TIPODOCR"    	,"C" ,001 ,0})	//Tipo de Documento   
AADD(aStru2,{"UFEMIT"    	,"C" ,002 ,0})	//UF REMETENTE
AADD(aStru2,{"CNPJDEST"   	,"C" ,014 ,0})	//CNPJ DESTINATARIO
AADD(aStru2,{"TPREGDES"    	,"C" ,001 ,0})	//Tipo do Registro
AADD(aStru2,{"TPCADDES"    	,"C" ,001 ,0})	//Tipo de Cadastro
AADD(aStru2,{"INSCDEST"    	,"C" ,018 ,0})	//INSCRICAO ESTADUAL DESTINATARIO
AADD(aStru2,{"NOMEDEST"    	,"C" ,040 ,0})	//RAZAO SOCIAL DESTINATARIO
AADD(aStru2,{"DTEMIDEST"   	,"C" ,033 ,0})	//DATA EMISSAO PESSOA FISICA        
AADD(aStru2,{"TIPODOCD"    	,"C" ,001 ,0})	//Tipo de Documento   
AADD(aStru2,{"UFDEST"    	,"C" ,002 ,0})	//UF DESTINATARIO           
AADD(aStru2,{"NF"   		   ,"C" ,006 ,0})	//NOTA FISCAL
AADD(aStru2,{"SERIE"   		,"C" ,TamSx3("DTC_SERNFC")[1] ,0})	//SERIE NF
AADD(aStru2,{"SUBSERIE"		,"C" ,003 ,0})	//SUBSERIE NF
AADD(aStru2,{"MODELO"		,"C" ,010 ,0})	//MODELO NF    
AADD(aStru2,{"DTEMI"   		,"C" ,033 ,0})	//DATA EMISSAO NOTA FISCAL 
AADD(aStru2,{"CODMER"  		,"C" ,002 ,0})	//CODIGO MERCADORIA CONFORME TABELA NO LAYOUT
AADD(aStru2,{"NATURE"  		,"C" ,005 ,0})	//NATUREZA OPERACAO
AADD(aStru2,{"QUANT"  		,"N" ,005 ,0})	//QUANTIDADE
AADD(aStru2,{"CODUNI"  		,"C" ,002 ,0})	//CODIGO UNIDADE DE MEDIDA
AADD(aStru2,{"BASEICM"  		,"N" ,014 ,2})	//VALOR BASE ICMS    
AADD(aStru2,{"VALORICM" 		,"N" ,014 ,2})	//VALOR ICMS                                                                              
AADD(aStru2,{"BASESUB"  		,"N" ,014 ,2})	//VALOR BASE ICMS RETIDO              
AADD(aStru2,{"ICMSUBST" 		,"N" ,014 ,2})	//VALOR ICMS RETIDO SUBST. TRIB.
AADD(aStru2,{"VALORNF"  		,"N" ,014 ,2})	//VALOR TOTAL NOTA FISCAL
AADD(aStru2,{"DTTRANS"   	,"C" ,033 ,0})	//DATA TRANSMISSAO
AADD(aStru2,{"NROCON"    	,"C" ,006 ,0})	//Numero Conhecimento  
AADD(aStru2,{"SDOC"   		,"C" ,003 ,0})	//SERIE NF

cArq := CriaTrab(aStru2)
dbUseArea(.T.,__LocalDriver,cArq,"RT2")                      	
IndRegua("RT2",cArq,"NROCON + NF + SERIE")
AADD(aTrbs,{cArq,"RT2"})
	
Return( aTrbs )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EDISCDel    ºAutor  ³Cleber S. A. Santos º Data ³ 28.09.2007  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Deleta os arquivos temporarios processados                    º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³EDISCDel                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
         
Function EDISCDel(aDelArqs)
Local aAreaDel := GetArea()
Local nI := 0
	
For nI:= 1 To Len(aDelArqs)
	If File(aDelArqs[nI,1]+GetDBExtension())
		dbSelectArea(aDelArqs[ni,2])
		dbCloseArea()
		Ferase(aDelArqs[nI,1]+GetDBExtension())
		Ferase(aDelArqs[nI,1]+OrdBagExt())
	Endif	
Next
	
RestArea(aAreaDel)
	
Return