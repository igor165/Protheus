#Include "PROTHEUS.CH"     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGNREON    บAutor  ณNatalia Antonucci   บ Data ณ  22/05/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPreparacao do meio magnetico GNREON - A Guia Nacional de    บฑฑ
ฑฑบ          ณRecolhimento de Tributos Estaduais, tem sido um documento   บฑฑ
ฑฑบ          ณde uso habitual por todos os contribuintes que realizam 	  บฑฑ
ฑฑบ          ณopera็๕es de vendas interestaduais sujeitas เ substitui็ใo  บฑฑ
ฑฑบ          ณtributแria.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                

Function GNREON()
Local	lEnd		:=	.F.
Local	aWizard		:=	{}
Local	cFileDest	:=	"GNREON.XML"
Local	cNomWiz		:=	"GNREON"
Local 	aArea		:= GetArea()
Local	aAreaSM0	:= SM0->(GetArea())

If Wizard(cNomWiz)

	Processa({||PrGNREON(@lEnd, aWizard, @cFileDest)})
	
	If !Empty(cFileDest)
		MsgInfo("Arquivo "  + cFileDest + " gerado com sucesso!") //"Arquivo "###" gerado com sucesso!"
	Else
		MsgAlert("Nใo foi possํvel gerar o arquivo!") //"Nใo foi possํvel gerar o arquivo!"
	EndIf 
	
Endif	

RestArea(aAreaSM0)
RestArea(aArea)

Return()                                                                                                           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPrGNREON  บAutor  ณNatalia Antonucci   บ Data ณ  22/05/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao principal de processamento do arq. magnetico GNREON  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PrGNREON(lEnd,aWizard,cFileDest)         

Local cFilDe   	:= ""
Local cFilAte  	:= "" 
Local cDir     	:= ""
Local cNomeCfp 	:= "GNREON"
Local cMvEstado	:= ""
Local cAliasSF6	:= "SF6"                                       
Local cFiltro  	:= ""
Local cIndex   	:= ""
Local cXml     	:= ""
Local cCampos  	:= ""
lOCAL cCodR    	:= ""
Local cInsc    	:= ""
Local cFilBkp	:= "" 
Local cTipoDoc	:= ""
Local cTipoRef	:= ""
Local cCodDoc	:= ""
Local cCODRECAP :=  GetNewPar("MV_RECEAPU","")
Local cMVSUBTRIB:= 	GetNewPar("MV_SUBTRIB")
Local cMVUFGNRE := 	GetNewPar("MV_UFGNRE","")
Local dDataDe  	:= 	ctod("//")
Local dDataAte 	:= 	ctod("//")
Local aAreaSM0	:=	SM0->(GetArea())
Local aFieldDt 	:=	{} 
Local aScan		:=  {}

Local aPeriodo :=	{{"AC","100021"},;				 
					 {"AM","100013"},;
 					 {"AM","100021"},; 
  					 {"AM","100030"},;
 					 {"AM","100056"},;
 					 {"DF","100013"},;
 					 {"DF","100030"},;
					 {"MA","100013"},;
					 {"MA","100021"},;
					 {"MA","100030"},;
					 {"PE","100013"},;
					 {"PR","100013"},;
					 {"PR","100021"},;
					 {"PR","100030"},; 
 					 {"BA","100013"},;
					 {"RR","100013"},;
					 {"RS","100013"},;
					 {"RS","100021"},; 
		 			 {"BA","100021"},;
		 			 {"BA","100030"},;
					 {"SE","100056"}}

Local aPartDest := 	{{"AL","100056"},;
					 {"AM","100021"},;				
 					 {"AM","100030"},;  
 					 {"GO","100056"},;
 					 {"MA","100013"},;
 					 {"MA","100021"},;
 					 {"MA","100056"},;
 					 {"MS","100056"},;
					 {"MT","100030"},;					    
					 {"MT","100056"},;
					 {"PB","100013"},;
					 {"RN","100013"},;
					 {"RN","100021"},;
					 {"RN","100056"},;
					 {"SE","100056"},;		
					 {"TO","100030"},;
 					 {"TO","100056"}}
	 						
Local aTagEx	:=	{{"AL","100013"},;
					 {"AL","100021"},;
					 {"AL","100030"},;
 					 {"AL","100056"},;
				     {"AM","100030"},;
  				     {"GO","100013"},;
   				     {"GO","100021"},;
   				     {"GO","100030"},;
  					 {"GO","100056"},;
  				     {"MG","100013"},;
   				     {"MG","100021"},;
   				     {"MG","100030"},;
  				     {"MG","100056"},;
  				     {"PE","100013"},;
   				     {"PI","100056"},;
   				     {"PR","100056"},;
  				     {"RN","100013"},;
  				     {"RN","100021"},;
  				     {"RN","100030"},;
   				     {"RN","100056"},;
  				     {"RS","100013"},;
			         {"RS","100030"},;
  				     {"RS","100056"}}

Local aTipoExc  :=  {{"GO","10"},;
					 {"AL","65"},;
					 {"MG","45"},;
					 {"PR","56"},;
					 {"RN","61"},;
					 {"BA","64"},;
					 {"RS","62"},;
					 {"PI","11"},;
					 {"AM","13"},;
					 {"PE","04"}}		
					 
Local nIndex   	:= 0
Local nCount   	:= 0 
Local nLote    	:= 0
Local nX	   	:= 0

Local nPos		:= 0 
Local nPosEx	:= 0
Local aX		:= 0

Local lGerou 	:= .F.
Local lParcela 	:= .F.

Local	cFilBack	:= cFilAnt
Local	aFilsCalc	:= {}
Local   aFilClone	:= {}
Local   lPriFil		:= .T.        
Local 	lSelFil		:= .F.
Local 	lAglFil		:= .F. 
Local 	nPosFil		:= 0
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtribuo o conteudo do CFP gerado pelo wizard no array aWizardณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (!xMagLeWiz (cNomeCfp, @aWizard, .T.))
	Return	//Se por algum motivo a leitura do CFP falhar aborto a rotina.
EndIf

dDataDe	 :=	SToD(aWizard[1][1])
dDataAte :=	SToD(aWizard[1][2])
cDir     := Alltrim(aWizard[1][3])
cFilDe   := Alltrim(aWizard[1][5]) 
cFilAte  := Alltrim(aWizard[1][6])                                                                                             

lSelFil	 := (aWizard[1][7] == 'Sim')
lAglFil	 := ( (aWizard[1][8] == 'Sim') .and. lSelFil )

If !lSelFil
	cFilDe	:=	cFilAte	:=	cFilAnt
	Aadd(aFilsCalc,{.T., SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_NOME,SM0->M0_CGC,SM0->M0_INSC})
Else
	aFilsCalc := MatFilCalc( lSelFil, , , (lSelFil .and. lAglFil), , 2 )
EndIf

If lSelFil .And. ( Len(aFilsCalc) >= 1 )
	aFilClone := aSort(aFilsCalc, , , { | x,y | x[2] < y[2] } )	
	cFilDe 	:= aFilClone[01][02]
	cFilAte	:= aFilClone[Len(aFilClone)][02]
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTrata Diretorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (SubStr (cDir, Len (cDir), 1)<>"\")
	cDir	+=	"\"
EndIf
cFileDest	:= AllTrim(aWizard[1][4])
                                                                        
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefinicao da ordem das tabelasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

DbSelectArea ("SA1")	//Cadastro do Cliente
SA1->(DbSetOrder (1))
DbSelectArea ("SA2")	//Cadastro do Cliente
SA1->(DbSetOrder (1))
DbSelectArea ("SF6")	//GNRE
SF6->(DbSetOrder (1))
DbSelectArea ("SF3")    //Livros Fiscais
SF3->(dbSetOrder(4))  
                                             
cFilBKP := FWGETCODFILIAL
aAreaSM0 := SM0->(GetArea())
DbSelectArea("SM0")  
SM0->(DbGoTop()) 
SM0->(DbSeek (cEmpAnt+cFilDe, .T.))	//Pego a filial mais proxima 
Do While !SM0->(Eof()) .And. (cEmpAnt==SM0->M0_CODIGO .And. FWGETCODFILIAL<=cFilAte) 
	cFilAnt := FWGETCODFILIAL
   
	cMvEstado := GetNewPar("MV_ESTADO", "")    
 	
 	DbSelectArea("SF6")
	SF6->(DbSetOrder(1))

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe foram selecionadas as filiais, identifica se a filial posicionada esta selecionada no arrayณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lSelFil .and. ( ( nPosFil := aScan(aFilsCalc,{|x| Alltrim(x[2]) == Alltrim(SM0->M0_CODFIL)}) ) = 0 .or. !aFilsCalc[nPosFil,1] )
		SM0->(dbSkip())
		Loop
	EndIf 	    	    		
	
	cAliasSF6	:=	GetNextAlias()
   	
   	aAdd(aFieldDt,"F6_DTVENC")
	aAdd(aFieldDt,"F6_DTPAGTO")
  	
  	cCampos := "%"                                  
  	If  SF6->(FieldPos("F6_DETRECE")) > 0  .AND. SF6->(FieldPos("F6_PROCESS")) > 0
		cCampos += ", SF6.F6_DETRECE, SF6.F6_PROCESS"
   	    cCampos += "%"
	EndIf   
  		   	
	BeginSql Alias cAliasSF6    	
		SELECT SF6.F6_FILIAL, SF6.F6_DTARREC, SF6.F6_MESREF, SF6.F6_EST, SF6.F6_CODREC, SF6.F6_TIPOIMP, SF6.F6_VALOR, SF6.F6_ANOREF, 
		SF6.F6_DOC, SF6.F6_NUMCONV, SF6.F6_CLIFOR, SF6.F6_LOJA, SF6.F6_NUMERO, SF6.F6_DTVENC, SF6.F6_DTPAGTO, SF6.F6_OPERNF, 
		SF6.F6_SERIE, SF6.F6_MULTA, SF6.F6_JUROS, SF6.F6_ATMON, SF6.F6_CODPROD, SF6.F6_REF, SF6.F6_INF, SF6.F6_DESCOMP, SF6.F6_TIPODOC, SF6.F6_INSC, SF6.F6_CNPJ
		%Exp:cCampos%      
		FROM 
			%Table:SF6% SF6 
		WHERE 
			SF6.F6_FILIAL=%xFilial:SF6% AND 
			SF6.F6_DTARREC>=%Exp:dDataDe% AND 
			SF6.F6_DTARREC<=%Exp:dDataAte% AND
			SF6.F6_TIPOIMP = '3' AND 
			SF6.F6_EST <> %Exp:cMvEstado% AND	
			SF6.%NotDel%
		ORDER BY %Order:SF6%					               			
	EndSql 
	For nX := 1 To Len(aFieldDt)
		TcSetField(cAliasSF6,aFieldDt[nX],"D",8,0)
	Next nX
	
	DbSelectArea (cAliasSF6)
	(cAliasSF6)->(DbGoTop ())
	ProcRegua ((cAliasSF6)->(RecCount ()))

	If !lAglFil
	    cNomeArq := cFileDest+cFilAnt
		nLote := 1
    	lGerou := .F.
 	Else
 		cNomeArq := cFileDest+cFilBack
 	EndIf

    While !(cAliasSF6)->(Eof ()) 
   		nCount := 0

		If !lAglFil .or. lPriFil
			cXml	 :=	""
			cXml:= GrvCab(nLote,@cNomeArq)
			lPriFil	:= .F.
		EndIf

   		While !(cAliasSF6)->(Eof ()) .and. nCount < 50
   		  	If Empty((cAliasSF6)->F6_PROCESS) .Or. (cAliasSF6)->F6_PROCESS=="2"      		  	
   		      lGerou:= .T.
	          If (cAliasSF6)->F6_EST$cMVUFGNRE
	           	cInsc := IESubTrib((cAliasSF6)->F6_EST)
	           	cCodR := IIf(!Empty(cCODRECAP), cCODRECAP,Alltrim((cAliasSF6)->F6_CODREC))  
           	   
				If (cAliasSF6)->F6_OPERNF == "2"
					SA1->(Dbseek(xFilial("SA1")+(cAliasSF6)->F6_CLIFOR+(cAliasSF6)->F6_LOJA))
				Else  
					SA2->(Dbseek(xFilial("SA2")+(cAliasSF6)->F6_CLIFOR+(cAliasSF6)->F6_LOJA)) 
				Endif	           
	           
	           	SF3->(dbSeek(xFilial("SF3")+(cAliasSF6)->F6_CLIFOR+(cAliasSF6)->F6_LOJA+(cAliasSF6)->F6_DOC+(cAliasSF6)->F6_SERIE))
		           	
              If (cAliasSF6)->F6_EST$cMVSUBTRIB .and. cCodR=="100048" .and. !Alltrim( (cAliasSF6)->F6_CODREC ) == "100099"	   
				   	cXml += MontaXML("TDadosGNRE",,,,,,5,.T.,.F.,.T.)
					cXml += MontaXML("c01_UfFavorecida",(cAliasSF6)->F6_EST,,,,,9,.T.,.T.,.T.)			
					cXml += MontaXML("c02_receita",cCodR,"C",9,2,,9,.T.,.T.,.T.)
					
					If (cAliasSF6)->(FieldPos("F6_DETRECE")) > 0 .AND. !Empty((cAliasSF6)->F6_DETRECE) 
				   		cXml += MontaXML("c25_detalhamentoReceita",AllTrim((cAliasSF6)->F6_DETRECE),"C",9,2,,9,.T.,.T.,.T.)		
				   	Endif
				   	
				   	If (cAliasSF6)->F6_CODPROD > 0 .AND. (cAliasSF6)->F6_EST$"AL/GO/MA/MG/PI/RN/RO/SE/TO/CE/MS/RR/DF"
				   		cXml += MontaXML("c26_produto",(cAliasSF6)->F6_CODPROD,"N",9,2,,9,.T.,.T.,.T.)
				   	Endif 
 					   
				  	If !Empty((cAliasSF6)->F6_DOC) 
				  	   	cXml += MontaXML("c28_tipoDocOrigem","10","C",9,2,,9,.T.,.T.,.T.)
						cXml += MontaXML("c04_docOrigem",(cAliasSF6)->F6_DOC,"C",9,2,,9,.T.,.T.,.T.)
					Endif					  
					
					If (cAliasSF6)->F6_VALOR > 0
						cXml += MontaXML("c06_valorPrincipal",(cAliasSF6)->F6_VALOR,"N",9,2,"@R 9999999999999999999.99",9,.T.,.T.,.T.)
					Endif 
				   
					If (cAliasSF6)->F6_VALOR > 0 .or. (cAliasSF6)->F6_ATMON > 0 .or. (cAliasSF6)->F6_JUROS > 0 .or. (cAliasSF6)->F6_MULTA > 0
						cXml += MontaXML("c10_valorTotal",(cAliasSF6)->F6_VALOR+(cAliasSF6)->F6_ATMON+(cAliasSF6)->F6_JUROS+(cAliasSF6)->F6_MULTA,"N",9,2,"@R 9999999999999999999.99",9,.T.,.T.,.T.)
					Endif				

					cXml += MontaXML("c14_dataVencimento",StrZero (Year ((cAliasSF6)->F6_DTVENC), 4)+"-"+StrZero (Month ((cAliasSF6)->F6_DTVENC), 2)+"-"+StrZero (Day ((cAliasSF6)->F6_DTVENC), 2),"C",,,,9,.T.,.T.,.T.)
					
					If !Empty((cAliasSF6)->F6_NUMCONV)
				   		cXml += MontaXML("c15_convenio",(cAliasSF6)->F6_NUMCONV,"N",9,2,,9,.T.,.T.,.T.)
					Endif		                	
				
					cXml += MontaXML("c17_inscricaoEstadualEmitente",cInsc,,,,,9,.T.,.T.,.T.)															
					
                    cXml += MontaXML("c33_dataPagamento",StrZero (Year ((cAliasSF6)->F6_DTPAGTO), 4)+"-"+StrZero (Month ((cAliasSF6)->F6_DTPAGTO), 2)+"-"+StrZero (Day ((cAliasSF6)->F6_DTPAGTO), 2),"C",,,,9,.T.,.T.,.T.)			
					
					cXml += MontaXML("c05_referencia",,,,,,5,.T.,.F.,.T.)                 
					
					If (cAliasSF6)->F6_REF$"1" .AND. (cAliasSF6)->F6_EST$"AC/AM/AP/BA/CE/MA/MS/PE/PR/RO/RR/RS/SE/DF" 
				   		cXml += MontaXML("periodo",0,"N",9,2,,9,.T.,.T.,.T.)
					Endif
					
					If (cAliasSF6)->F6_MESREF > 0
						cXml += MontaXML("mes",StrZero((cAliasSF6)->F6_MESREF,2),"N",9,2,,9,.T.,.T.,.T.)
					Endif
					
					If (cAliasSF6)->F6_ANOREF > 0
						cXml += MontaXML("ano",(cAliasSF6)->F6_ANOREF,"N",9,2,,9,.T.,.T.,.T.)
					Endif 
				    
			    	If !(cAliasSF6)->F6_EST$"BA/GO"
					    cXml += MontaXML("parcela","1","N",9,2,,9,.T.,.T.,.T.)		
					EndIf
					
					cXml += MontaXML("c05_referencia",,,,,,5,.F.,.T.,.T.)			 
							 		  
		 			If (cAliasSF6)->F6_EST=="RR" .And. !Empty(SF3->F3_CHVNFE)
						cXml += MontaXML("c39_camposExtras",,,,,,5,.T.,.F.,.T.)
						cXml += MontaXML("campoExtra",,,,,,5,.T.,.F.,.T.) 
				   		cXml += MontaXML("codigo","36","C",9,2,,9,.T.,.T.,.T.)
	     				cXml += MontaXML("tipo","T","C",9,2,,9,.T.,.T.,.T.)
	     				cXml += MontaXML("valor",SF3->F3_CHVNFE,"C",9,2,,9,.T.,.T.,.T.)
	    				cXml += MontaXML("campoExtra",,,,,,5,.F.,.T.,.T.)
						cXml += MontaXML("c39_camposExtras",,,,,,5,.F.,.T.,.T.)
					Endif
					cXml += MontaXML("TDadosGNRE",,,,,,5,.F.,.T.,.T.)		
					cXml += Chr (13)+Chr (10)				
				Elseif Alltrim((cAliasSF6)->F6_CODREC)=="100099"
				   	cXml += MontaXML("TDadosGNRE",,,,,,5,.T.,.F.,.T.)
					cXml += MontaXML("c01_UfFavorecida",(cAliasSF6)->F6_EST,,,,,9,.T.,.T.,.T.)			
					cXml += MontaXML("c02_receita",AllTrim((cAliasSF6)->F6_CODREC),"C",9,2,,9,.T.,.T.,.T.)
		   			If (cAliasSF6)->(FieldPos("F6_DETRECE")) > 0 .AND. !Empty((cAliasSF6)->F6_DETRECE) 
				   		cXml += MontaXML("c25_detalhamentoReceita",AllTrim((cAliasSF6)->F6_DETRECE),"C",9,2,,9,.T.,.T.,.T.)		
				   	Endif
				   	
				   	If (cAliasSF6)->F6_CODPROD > 0 .AND. (cAliasSF6)->F6_EST$"AL/AM/BA/CE/DF/GO/MA/MS/PE/PI/RN/RO/RR/SC/SE/TO"
				   		cXml += MontaXML("c26_produto",(cAliasSF6)->F6_CODPROD,"N",9,2,,9,.T.,.T.,.T.)
				   	Endif
				   			
					If Len(AllTrim(SM0->M0_CGC))>=14 
						cXml += MontaXML("c27_tipoIdentificacaoEmitente","1",,,,,9,.T.,.T.,.T.)
					Endif	
				   			
				   	cXml += MontaXML("c03_idContribuinteEmitente",,,,,,5,.T.,.F.,.T.)
								
					If Len(AllTrim(SM0->M0_CGC))>=14  
						cXml += MontaXML("CNPJ",SM0->M0_CGC,,,,,24,.T.,.T.,.T.)
					Endif
					
				   	cXml += MontaXML("c03_idContribuinteEmitente",,,,,,5,.F.,.T.,.T.)			
					
					If !Empty(SF3->F3_ESPECIE)
				   		cXml += MontaXML("c28_tipoDocOrigem",Iif(Alltrim(SF3->F3_ESPECIE)=="NFA","01",Iif(Alltrim(SF3->F3_ESPECIE)$"NF/SPED","10",Iif(Alltrim(SF3->F3_ESPECIE)$"CTR/CTE","07","00"))),"C",9,2,,9,.T.,.T.,.T.)
					Endif
					
					If !Empty((cAliasSF6)->F6_DOC)
						cXml += MontaXML("c04_docOrigem",(cAliasSF6)->F6_DOC,"C",9,2,,9,.T.,.T.,.T.)
					Endif
					
					If (cAliasSF6)->F6_VALOR > 0
						cXml += MontaXML("c06_valorPrincipal",(cAliasSF6)->F6_VALOR,"N",9,2,"@R 9999999999999999999.99",9,.T.,.T.,.T.)
					Endif 
				   
					If (cAliasSF6)->F6_VALOR > 0 .or. (cAliasSF6)->F6_ATMON > 0 .or. (cAliasSF6)->F6_JUROS > 0 .or. (cAliasSF6)->F6_MULTA > 0
						cXml += MontaXML("c10_valorTotal",(cAliasSF6)->F6_VALOR+(cAliasSF6)->F6_ATMON+(cAliasSF6)->F6_JUROS+(cAliasSF6)->F6_MULTA,"N",9,2,"@R 9999999999999999999.99",9,.T.,.T.,.T.)
					Endif
					
					//Para Ceara, considerar data vencimento = data pagamento
					If (cAliasSF6)->F6_EST == "CE"
						cXml += MontaXML("c14_dataVencimento",StrZero (Year ((cAliasSF6)->F6_DTPAGTO), 4)+"-"+StrZero (Month ((cAliasSF6)->F6_DTPAGTO), 2)+"-"+StrZero (Day ((cAliasSF6)->F6_DTPAGTO), 2),"C",,,,9,.T.,.T.,.T.)						
					Else
						cXml += MontaXML("c14_dataVencimento",StrZero (Year ((cAliasSF6)->F6_DTVENC), 4)+"-"+StrZero (Month ((cAliasSF6)->F6_DTVENC), 2)+"-"+StrZero (Day ((cAliasSF6)->F6_DTVENC), 2),"C",,,,9,.T.,.T.,.T.)
					EndIf
					
					If !Empty((cAliasSF6)->F6_NUMCONV)
				   		cXml += MontaXML("c15_convenio",(cAliasSF6)->F6_NUMCONV,"N",9,2,,9,.T.,.T.,.T.)
					Endif			
			
				   	cXml += MontaXML("c16_razaoSocialEmitente",HTMLEnc(SM0->M0_NOMECOM),,,,,9,.T.,.T.,.T.,,,,.T.)
					cXml += MontaXML("c18_enderecoEmitente",Substr(AllTrim(SM0->M0_ENDENT)+IIf(!Empty(SM0->M0_COMPENT),'-'+AllTrim(SM0->M0_COMPENT),''),1,60),,,,,9,.T.,.T.,.T.)
					cXml += MontaXML("c19_municipioEmitente",Substr(SM0->M0_CODMUN,3),,,,,9,.T.,.T.,.T.)	
					cXml += MontaXML("c20_ufEnderecoEmitente",SM0->M0_ESTENT,,,,,9,.T.,.T.,.T.)   
					If (cAliasSF6)->F6_EST$"MT"
						cXml += MontaXML("c21_cepEmitente",SM0->M0_CEPENT,,,,,9,.T.,.T.,.T.)
						cXml += MontaXML("c22_telefoneEmitente",SM0->M0_TEL,,,,,9,.T.,.T.,.T.)	
					EndIf
				
					If !Empty(SA1->A1_CGC) .And. (Empty(SA1->A1_INSCR) .Or.  Alltrim(SA1->A1_INSCR)=="ISENTO" ) .And. !(cAliasSF6)->F6_EST$"AC/BA/PB/RS/SC/PA/PR/RR"
				   		cXml += MontaXML("c34_tipoIdentificacaoDestinatario",Iif(!Empty(SA1->A1_CGC) .and. RetPessoa(SA1->A1_CGC) == "J","1","2"),,,,,9,.T.,.T.,.T.)
				    Endif 
					
				    if (Empty(SA1->A1_INSCR) .Or.  Alltrim(SA1->A1_INSCR)=="ISENTO") .and. (cAliasSF6)->F6_EST$"AL/AM/GO/MA/MT/PI/RN/RO/SE/TO/MG/MS/CE/AP/MS/PE/DF"
			   	   		cXml += MontaXML("c35_idContribuinteDestinatario",,,,,,5,.T.,.F.,.T.)
		   	  		Endif 
			   	 	
			   	 	If !Empty(SA1->A1_CGC) .and. RetPessoa(SA1->A1_CGC) == "F" .And. (Empty(SA1->A1_INSCR) .Or.  Alltrim(SA1->A1_INSCR)=="ISENTO") .and. (cAliasSF6)->F6_EST$"AL/AM/GO/MA/MT/PI/RN/RO/SE/TO/MG/MS/CE/AP/MS/PE/DF"
			   	 		cXml += MontaXML("CPF",SA1->A1_CGC,,,,,9,.T.,.T.,.T.)
					Endif
					
					If !Empty(SA1->A1_CGC) .and. RetPessoa(SA1->A1_CGC) == "J" .And. (Empty(SA1->A1_INSCR) .Or.  Alltrim(SA1->A1_INSCR)=="ISENTO") .and. (cAliasSF6)->F6_EST$"AL/AM/GO/MA/MT/PI/RN/RO/SE/TO/MG/MS/CE/AP/MS/PE/DF"
						cXml += MontaXML("CNPJ",SA1->A1_CGC,,,,,9,.T.,.T.,.T.)
				    Endif
					    			
					if (Empty(SA1->A1_INSCR) .Or.  Alltrim(SA1->A1_INSCR)=="ISENTO") .and. (cAliasSF6)->F6_EST$"AL/AM/GO/MA/MT/PI/RN/RO/SE/TO/MG/MS/CE/AP/MS/PE/DF"
				   		cXml += MontaXML("c35_idContribuinteDestinatario",,,,,,5,.F.,.T.,.T.)
					endif
					
					//ISENTO nao manda IE, que soh aceita numeros
					If !Empty(SA1->A1_INSCR) .and. (cAliasSF6)->F6_EST$"AL/AM/GO/MA/MT/PI/RN/RO/SE/TO/MG/MS/CE/AP/MS/PE" .And. Alltrim(SA1->A1_INSCR)<>"ISENTO"
						cXml += MontaXML("c36_inscricaoEstadualDestinatario",ConvType(VldIE(SA1->A1_INSCR,.F.,.F.)),,,,,9,.T.,.T.,.T.)
					Endif
					
					If !Empty(SA1->A1_NOME) .And. (Empty(SA1->A1_INSCR) .Or.  Alltrim(SA1->A1_INSCR)=="ISENTO") .and. (cAliasSF6)->F6_EST$"AL/AM/GO/MA/MT/PI/RN/RO/SE/TO/MG/MS/CE/AP/MS/PE"
				   		cXml += MontaXML("c37_razaoSocialDestinatario",Alltrim(SA1->A1_NOME),,,,,9,.T.,.T.,.T.)
					Endif
					
					If !Empty(SA1->A1_COD_MUN) .And. (Empty(SA1->A1_INSCR) .Or.  Alltrim(SA1->A1_INSCR)=="ISENTO") .and.(cAliasSF6)->F6_EST$"AL/AM/GO/MA/MT/PI/RN/RO/SE/TO/MG/MS/CE/AP/MS/PE"
				   		cXml += MontaXML("c38_municipioDestinatario",Alltrim(SA1->A1_COD_MUN),,,,,9,.T.,.T.,.T.)
					Endif
					
					cXml += MontaXML("c33_dataPagamento",StrZero (Year ((cAliasSF6)->F6_DTPAGTO), 4)+"-"+StrZero (Month ((cAliasSF6)->F6_DTPAGTO), 2)+"-"+StrZero (Day ((cAliasSF6)->F6_DTPAGTO), 2),"C",,,,9,.T.,.T.,.T.)			
					
					cXml += MontaXML("c05_referencia",,,,,,5,.T.,.F.,.T.)			
									
				 	If (cAliasSF6)->F6_EST$"AM/BA/SE" 
				   		cXml += MontaXML("periodo",IIF((cAliasSF6)->F6_REF$"1","0",IIF((cAliasSF6)->F6_REF$"2","1",IIF((cAliasSF6)->F6_REF$"3","2",IIF((cAliasSF6)->F6_REF$"4","3",IIF((cAliasSF6)->F6_REF$"5","4",IIF((cAliasSF6)->F6_REF$"6","5","")))))),"C",9,2,,9,.T.,.T.,.T.)
					Endif
					
					If (cAliasSF6)->F6_MESREF > 0
						cXml += MontaXML("mes",StrZero((cAliasSF6)->F6_MESREF,2),"N",9,2,,9,.T.,.T.,.T.)
					Endif
					
					If (cAliasSF6)->F6_ANOREF > 0
						cXml += MontaXML("ano",(cAliasSF6)->F6_ANOREF,"N",9,2,,9,.T.,.T.,.T.)
					Endif
					
					If !(cAliasSF6)->F6_EST$"BA/GO"
						cXml += MontaXML("parcela","1","N",9,2,,9,.T.,.T.,.T.)
					EndIf
                        
					cXml += MontaXML("c05_referencia",,,,,,5,.F.,.T.,.T.)
										
					If (cAliasSF6)->F6_EST=="PB"
					    cCodDoc := Iif(AModNot(Alltrim(SF3->F3_ESPECIE))$"55","30",Iif(AModNot(Alltrim(SF3->F3_ESPECIE))$"01#1B","31",""))
						
						cXml += MontaXML("c39_camposExtras",,,,,,5,.T.,.F.,.T.)
						cXml += MontaXML("campoExtra",,,,,,5,.T.,.F.,.T.) 
				   		cXml += MontaXML("codigo",cCodDoc,"C",9,2,,9,.T.,.T.,.T.)
	     				cXml += MontaXML("tipo","T","C",9,2,,9,.T.,.T.,.T.)
	     				cXml += MontaXML("valor",Iif(cCodDoc=="30",SF3->F3_CHVNFE,(cAliasSF6)->F6_DOC),"C",9,2,,9,.T.,.T.,.T.)
	    				cXml += MontaXML("campoExtra",,,,,,5,.F.,.T.,.T.)
						cXml += MontaXML("c39_camposExtras",,,,,,5,.F.,.T.,.T.)
					Endif
					If (cAliasSF6)->F6_EST$"RR/AP/MS" .And. !Empty(SF3->F3_CHVNFE)
						cXml += MontaXML("c39_camposExtras",,,,,,5,.T.,.F.,.T.)
						cXml += MontaXML("campoExtra",,,,,,5,.T.,.F.,.T.) 
				   		cXml += MontaXML("codigo",Iif((cAliasSF6)->F6_EST=="RR","36",Iif((cAliasSF6)->F6_EST=="AP","47",Iif((cAliasSF6)->F6_EST=="MS","27",""))),"C",9,2,,9,.T.,.T.,.T.)
	     				cXml += MontaXML("tipo","T","C",9,2,,9,.T.,.T.,.T.)
	     				cXml += MontaXML("valor",SF3->F3_CHVNFE,"C",9,2,,9,.T.,.T.,.T.)
	    				cXml += MontaXML("campoExtra",,,,,,5,.F.,.T.,.T.)
						cXml += MontaXML("c39_camposExtras",,,,,,5,.F.,.T.,.T.)
					Endif		
					cXml += MontaXML("TDadosGNRE",,,,,,5,.F.,.T.,.T.)		
					cXml += Chr(13)+ Chr(10)
				Endif
	
				lParcela := .F.
	          	
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณDefino se a Parcela sera preenchidaณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If  (cAliasSF6)->F6_EST == "DF" .And. Alltrim((cAliasSF6)->F6_CODREC) $ "100013/100021/100030/100056"			
					lParcela := .T.				
				EndIf	
						
				If (Alltrim((cAliasSF6)->F6_CODREC)$"100013/100021/100030" .Or. Alltrim((cAliasSF6)->F6_CODREC)$"100056")
				            
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		   			//ณInicializa Impressao da GNRE   ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					cXml += MontaXML( "TDadosGNRE",,,,,,9,.T.,.F.,.T. )						
			        
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	   				//ณUF Favorecida (Obrigatorio) ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					cXml += MontaXML( "c01_UfFavorecida", (cAliasSF6)->F6_EST, , , , , 12, .T., .T., .T. )
					
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณCodigo da Receita (Obrigatorio) ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
					cXml += MontaXML( "c02_receita", Alltrim((cAliasSF6)->F6_CODREC), , , , , 12, .T., .T., .T. )	
	
	                 
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณCodigo do Detalhamento da Receitaณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If !Empty((cAliasSF6)->F6_DETRECE)
						 cXml += MontaXML("c25_detalhamentoReceita",AllTrim((cAliasSF6)->F6_DETRECE),"C",9,2,,9,.T.,.T.,.T.)		
					EndIf
				
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณCodigo do Produto  ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
					If !Empty( (cAliasSF6)->F6_CODPROD )
						cXml += MontaXML("c26_produto",(cAliasSF6)->F6_CODPROD,"N",9,2,,9,.T.,.T.,.T.)
					EndIf
				   
					If  !((cAliasSF6)->F6_EST$"PR" .And. Alltrim((cAliasSF6)->F6_CODREC)$"100013/100021/100030") 
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณTipo de Identificacao do Emitente, de acordo com o Layout quando informada        ณ
						//ณa IE do Emitente este campo deve ser emitido, caso contrario eh exibido "1" (CNPJ)ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						If Alltrim((cAliasSF6)->F6_CODREC)$"100056"
							If Len(Alltrim((cAliasSF6)->F6_CNPJ)) == 14 .And. CGC(Alltrim((cAliasSF6)->F6_CNPJ))
								cXml += MontaXML("c27_tipoIdentificacaoEmitente","1",,,,,9,.T.,.T.,.T.)			
							Elseif Len(Alltrim((cAliasSF6)->F6_CNPJ)) == 11 .And. CGC(Alltrim((cAliasSF6)->F6_CNPJ))
									cXml += MontaXML("c27_tipoIdentificacaoEmitente","2",,,,,9,.T.,.T.,.T.)		
							Endif
						Elseif !Empty((cAliasSF6)->F6_INSC) .And. !(Alltrim((cAliasSF6)->F6_CODREC)=="100013" .And. ((cAliasSF6)->F6_EST$"PE"))		
							cXml += MontaXML("c27_tipoIdentificacaoEmitente",Iif(!Empty(SA1->A1_CGC) .and. RetPessoa(SA1->A1_CGC) == "J","1","2"),,,,,9,.T.,.T.,.T.)			
						EndIf					   	
						
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณCNPJ do Emitente   ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู				
						If !Empty( SM0->M0_CGC )   
							cXml += MontaXML( "c03_idContribuinteEmitente", , , , , , 12, .T., .F., .T. )  
										
							cXml += MontaXML( "CNPJ", SM0->M0_CGC, , , , , 15, .T., .T., .T. )					
								
							cXml += MontaXML( "c03_idContribuinteEmitente", , , , , , 12, .F., .T., .T. )  								
						EndIf
					
						Do Case		
							Case Alltrim(SF3->F3_ESPECIE)="NFA"
								cTipoDoc := "01"			
							Case Alltrim(SF3->F3_ESPECIE)$"NF/SPED"
								cTipoDoc := "10"			
							Case Alltrim(SF3->F3_ESPECIE)=="CA"						
								cTipoDoc := "08"				
							Case Alltrim(SF3->F3_ESPECIE)$"CTR/CTE"
								cTipoDoc := "07"	
							Case (Alltrim(SF3->F3_ESPECIE)$"NTST/NFCEE" .And. Alltrim((cAliasSF6)->F6_CODREC)$"100013/100021" .And. !(cAliasSF6)->F6_EST$"PI")
								cTipoDoc := "10"	 
							Case (Alltrim((cAliasSF6)->F6_CODREC)=="100013" .And. (cAliasSF6)->F6_EST=="PI")
								cTipoDoc := "01"	 
							OtherWise
								cTipoDoc := "00"	 
						EndCase	
					  
					    If Alltrim((cAliasSF6)->F6_CODREC)$"100056" .And. !(cAliasSF6)->F6_EST$"AC" 
					  		If !Empty((cAliasSF6)->F6_TIPODOC)
								cXml += MontaXML("c28_tipoDocOrigem",(cAliasSF6)->F6_TIPODOC,"C",2,2,,9,.T.,.T.,.T.)
							EndIf
					 		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณNumero do Documento de Origem|
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู			
							If !Empty((cAliasSF6)->F6_DOC)
								cXml += MontaXML("c04_docOrigem",(cAliasSF6)->F6_DOC,"C",9,2,,9,.T.,.T.,.T.)	
							EndIf				    
					    Endif
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณTipo do Documento de Origem  ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู  
						If !Alltrim((cAliasSF6)->F6_CODREC)$"100056"			
							If !((cAliasSF6)->F6_EST$"BA/PR" .And. Alltrim((cAliasSF6)->F6_CODREC)$"100030/100013")   
								If Alltrim(SF3->F3_ESPECIE)$"CTR/CTE" .And. Alltrim((cAliasSF6)->F6_CODREC)$"100030" .And. (cAliasSF6)->F6_EST$"TO/SC"   
									cTipoDoc := "10"
								Endif
								If !Empty( cTipoDoc )  
									cXml += MontaXML("c28_tipoDocOrigem",cTipoDoc,"C",2,2,,9,.T.,.T.,.T.)
								EndIf
				
								//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
								//ณNumero do Documento de Origem|
								//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู			
								If !Empty((cAliasSF6)->F6_DOC)
									cXml += MontaXML("c04_docOrigem",(cAliasSF6)->F6_DOC,"C",9,2,,9,.T.,.T.,.T.)	
								EndIf
							EndIf  
						Endif
					EndIf
		
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณValor Original da Guia (Sem Impostos)   ฤฤ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณValor Original da Guia (Com Impostos)   ฤฤ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
					If (cAliasSF6)->F6_VALOR > 0
		                If !((cAliasSF6)->F6_EST$"MA/PA/PI/RO/RR/TO") .And. !((cAliasSF6)->F6_EST=="SC" .And. Alltrim((cAliasSF6)->F6_CODREC)$"100021/100030/100056")
					   		cXml += MontaXML("c06_valorPrincipal",(cAliasSF6)->F6_VALOR,"N",9,2,"@R 9999999999999999999.99",9,.T.,.T.,.T.)
						Elseif !((cAliasSF6)->F6_EST$"RS/TO/PE")
							cXml += MontaXML("c10_valorTotal",(cAliasSF6)->F6_VALOR+(cAliasSF6)->F6_ATMON+(cAliasSF6)->F6_JUROS+(cAliasSF6)->F6_MULTA,"N",9,2,"@R 9999999999999999999.99",9,.T.,.T.,.T.)	    		
						Elseif((cAliasSF6)->F6_VALOR > 0 .Or. (cAliasSF6)->F6_ATMON > 0 .Or. (cAliasSF6)->F6_JUROS > 0 .Or. (cAliasSF6)->F6_MULTA > 0);
								.And. (cAliasSF6)->F6_EST$"MA/PA/PI/RO/RR/TO" .And. Alltrim((cAliasSF6)->F6_CODREC)$"100013/100021/100030/100056"
									cXml += MontaXML("c06_valorPrincipal",(cAliasSF6)->F6_VALOR,"N",9,2,"@R 9999999999999999999.99",9,.T.,.T.,.T.)
									cXml += MontaXML("c10_valorTotal",(cAliasSF6)->F6_VALOR+(cAliasSF6)->F6_ATMON+(cAliasSF6)->F6_JUROS+(cAliasSF6)->F6_MULTA,"N",9,2,"@R 9999999999999999999.99",9,.T.,.T.,.T.)	    		
						Endif
					Endif
		
	               //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณData de Vencimento da Guia (Obrigatorio) ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If !Empty((cAliasSF6)->F6_DTVENC)
	   					cXml += MontaXML("c14_dataVencimento",StrZero (Year ((cAliasSF6)->F6_DTVENC), 4)+"-"+StrZero (Month ((cAliasSF6)->F6_DTVENC), 2)+"-"+StrZero (Day ((cAliasSF6)->F6_DTVENC), 2),"C",,,,9,.T.,.T.,.T.)
				    Endif
	                 
	                //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณCodigo do Convenio     ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
					If !Empty((cAliasSF6)->F6_NUMCONV)
						cXml += MontaXML( "c15_convenio", (cAliasSF6)->F6_NUMCONV, , , , , 12, .T., .T., .T. )	
					EndIf
		            
		 			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณRazao Social, de acordo com o Layout quando informada    ณ
					//ณa IE do Emitente este campo deve ser emitido             ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If !((cAliasSF6)->F6_EST$"PR" .And. Alltrim((cAliasSF6)->F6_CODREC)$"100013/100021/100030") 
						If !Empty( SM0->M0_INSC )    
							If !Empty( SM0->M0_NOMECOM )
								cXml += MontaXML("c16_razaoSocialEmitente",HTMLEnc(SM0->M0_NOMECOM),,,,,9,.T.,.T.,.T.,,,,.T.)
							EndIf
						EndIf 
					EndIf
		
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณInscricao Estadual do Emitente     ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู				
	   				IF !Empty((cAliasSF6)->F6_INSC) .And. ((Alltrim((cAliasSF6)->F6_CODREC)=="100013" .And. ((cAliasSF6)->F6_EST$"PE")) .Or. (cAliasSF6)->F6_EST$"PR/RR") 
						cXml += MontaXML("c17_inscricaoEstadualEmitente",(cAliasSF6)->F6_INSC,,,,,9,.T.,.T.,.T.)
	   				Endif				
	               	
	               	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณEndereco do Emitente, de acordo com o Layout quando informada    ณ
					//ณa IE do Emitente este campo deve ser emitido                     ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If !((cAliasSF6)->F6_EST$"PR" .And. Alltrim((cAliasSF6)->F6_CODREC)$"100013/100021") 
						If !Empty( SM0->M0_ENDENT )
							cXml += MontaXML("c18_enderecoEmitente",Substr(AllTrim(SM0->M0_ENDENT)+IIf(!Empty(SM0->M0_COMPENT),'-'+AllTrim(SM0->M0_COMPENT),''),1,60),,,,,9,.T.,.T.,.T.)
						EndIf
	       
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณMunicipio do Emitente, de acordo com o Layout quando informada     ณ
						//ณa IE do Emitente este campo deve ser emitido                       ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				
						If !Empty( SM0->M0_CODMUN )		
							cXml += MontaXML( "c19_municipioEmitente", Right( Alltrim( SM0->M0_CODMUN ), 5 ), , , , , 12, .T., .T., .T. )	
						EndIf
	
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณUF do Emitente, de acordo com o Layout quando informada            ณ
						//ณa IE do Emitente este
						//campo deve ser emitido                       ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				
						If !Empty( SM0->M0_ESTCOB )
							cXml += MontaXML("c20_ufEnderecoEmitente",SM0->M0_ESTENT,,,,,9,.T.,.T.,.T.)
						EndIf
			   		
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณCEP do emitente, de acordo com o Layout quando informada           ณ
						//ณa IE do Emitente este campo deve ser emitido                       ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
				
						If !Empty( SM0->M0_CEPENT )
							cXml += MontaXML("c21_cepEmitente",SM0->M0_CEPENT,,,,,8,.T.,.T.,.T.)
						EndIf
	
					    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณTelefone do emitente, de acordo com o Layout quando informada      ณ
						//ณa IE do Emitente este campo deve ser emitido                       ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู				
				
						If !Empty( SM0->M0_TEL )
					  		cXml += MontaXML("c22_telefoneEmitente",SM0->M0_TEL,,,,,10,.T.,.T.,.T.)	
						EndIf
	
		              	EndIf  

		          
	                
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณCaso seja informado o Participante no cadastro de Guias, deve-se gerar ณ
					//ณas informacoes de destinatario (Substituicao Tributaria)               ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	      
	               	nPos := aScan(aPartDest,{ |x| x[1] == (cAliasSF6)->F6_EST .And. x[2]== Alltrim((cAliasSF6)->F6_CODREC)})   
	    
	    			If nPos > 0
	                    
						If (cAliasSF6)->F6_OPERNF == "2"
							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณ1 = Pessoa Juridicaณ
							//ณ2 = Pessoa Fisica  ณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
							cTpPessoa := Iif(!Empty(SA1->A1_CGC) .and. RetPessoa(SA1->A1_CGC) == "J","1","2")
				
				   			cXml += MontaXML("c34_tipoIdentificacaoDestinatario",cTpPessoa,,,,,9,.T.,.T.,.T.)
		
					   		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณInscricao Estadual do Destinatarioณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู       	    
							If !Empty(SA1->A1_INSCR) .And. !((cAliasSF6)->F6_EST$"AM" .And. Alltrim((cAliasSF6)->F6_CODREC)=="100021")					
								cXml += MontaXML( "c36_inscricaoEstadualDestinatario", ConvType(VldIE(SA1->A1_INSCR,.F.,.F.)), , , , , 12, .T., .T., .T. )				
					        Else
				        	         
				        		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
								//ณCPF/CNPJ do Destinatarioณ
								//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
								If cTpPessoa == "1" 
									If !Empty( (SA1->A1_CGC) ) 
										cXml += MontaXML( "c35_idContribuinteDestinatario", , , , , , 12, .T., .F., .T. )  			
										
											cXml += MontaXML( "CNPJ", SA1->A1_CGC, , , , , 15, .T., .T., .T. )             
											
										cXml += MontaXML( "c35_idContribuinteDestinatario", , , , , , 12, .F., .T., .T. )  				
									EndIf
								Else 
									If !Empty( SA1->A1_CGC )                       
										cXml += MontaXML( "c35_idContribuinteDestinatario", , , , , , 12, .T., .F., .T. )
										  			
											cXml += MontaXML( "CPF", SA1->A1_CGC, , , , , 15, .T., .T., .T. )               
											
										cXml += MontaXML( "c35_idContribuinteDestinatario", , , , , , 12, .F., .T., .T. )  			
									EndIf
								EndIf				
								//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
								//ณRazao Social do Destinatario      ณ
								//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู			
								If !Empty( SA1->A1_NOME )
									cXml += MontaXML( "c37_razaoSocialDestinatario", SA1->A1_NOME, , , , , 12, .T., .T., .T. )
								EndIf		
					
								
								//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
								//ณCodigo do Municipio do Destinatario ณ
								//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู						
								If !Empty( SA1->A1_COD_MUN )   				
									cXml += MontaXML("c38_municipioDestinatario",Alltrim(SA1->A1_COD_MUN),,,,,12,.T.,.T.,.T.)
								EndIf
							EndIf
			
				   		Else
							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณ1 = Pessoa Juridicaณ
							//ณ2 = Pessoa Fisica  ณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
							cTpPessoa := Iif(!Empty(SA2->A2_CGC) .and. RetPessoa(SA2->A2_CGC) == "J","1","2")
				
				   			cXml += MontaXML("c34_tipoIdentificacaoDestinatario",cTpPessoa,,,,,9,.T.,.T.,.T.)
		
					   		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณInscricao Estadual do Destinatarioณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู       	    
							If !Empty(SA2->A2_INSCR) .And. !((cAliasSF6)->F6_EST$"AM" .And. Alltrim((cAliasSF6)->F6_CODREC)=="100021") .And.  !(Alltrim((cAliasSF6)->F6_CODREC)$"100056" .And. (cAliasSF6)->F6_EST$"TO") 
								cXml += MontaXML( "c36_inscricaoEstadualDestinatario", ConvType(VldIE(SA2->A2_INSCR,.F.,.F.)), , , , , 12, .T., .T., .T. )				
					        Else
				        	         
				        		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
								//ณCPF/CNPJ do Destinatarioณ
								//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
								If cTpPessoa == "1" 
									If !Empty( (SA2->A2_CGC) ) 
										cXml += MontaXML( "c35_idContribuinteDestinatario", , , , , , 12, .T., .F., .T. )  			
										
											cXml += MontaXML( "CNPJ", SA2->A2_CGC, , , , , 15, .T., .T., .T. )             
											
										cXml += MontaXML( "c35_idContribuinteDestinatario", , , , , , 12, .F., .T., .T. )  				
									EndIf
								Else 
									If !Empty( SA1->A2_CGC )                       
										cXml += MontaXML( "c35_idContribuinteDestinatario", , , , , , 12, .T., .F., .T. )
										  			
											cXml += MontaXML( "CPF", SA1->A2_CGC, , , , , 15, .T., .T., .T. )               
											
										cXml += MontaXML( "c35_idContribuinteDestinatario", , , , , , 12, .F., .T., .T. )  			
									EndIf
								EndIf				
								//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
								//ณRazao Social do Destinatario      ณ
								//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู			
								If !Empty( SA2->A2_NOME )
									cXml += MontaXML( "c37_razaoSocialDestinatario", SA2->A2_NOME, , , , , 12, .T., .T., .T. )
								EndIf		
						
			
								
								//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
								//ณCodigo do Municipio do Destinatario ณ
								//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู						
								If !Empty( SA2->A2_COD_MUN )   				
									cXml += MontaXML("c38_municipioDestinatario",Alltrim(SA2->A2_COD_MUN),,,,,12,.T.,.T.,.T.)
								EndIf
							EndIf
						EndIf
					Endif
						
						
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณData de Pagamento da Guia (Obrigatorio)  ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If !Empty((cAliasSF6)->F6_DTPAGTO)
						cXml += MontaXML("c33_dataPagamento",StrZero (Year ((cAliasSF6)->F6_DTPAGTO), 4)+"-"+StrZero (Month ((cAliasSF6)->F6_DTPAGTO), 2)+"-"+StrZero (Day ((cAliasSF6)->F6_DTPAGTO), 2),"C",,,,9,.T.,.T.,.T.)			
					Endif 	
			
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณPeriodo, Mes, Ano e Parcela a qual se refere a Guia ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					
		
					cXml += MontaXML( "c05_referencia", , , , , , 12, .T., .F., .T. )  
			            
		 			Do Case		
						Case (cAliasSF6)->F6_REF="1"
							cTipoRef := "0"			
						Case (cAliasSF6)->F6_REF="2"
							cTipoRef := "1"			
						Case (cAliasSF6)->F6_REF="3"
							cTipoRef := "2"				
						Case (cAliasSF6)->F6_REF="4"
							cTipoRef := "3"	
						Case (cAliasSF6)->F6_REF="5"
							cTipoRef := "4"	
						Case (cAliasSF6)->F6_REF="6"
							cTipoRef := "5"	 
						OtherWise
							cTipoRef := "0"	 
					EndCase	
				
					nPos := 0 
		
	   		   		nPos := aScan(aPeriodo,{ |x| x[1] == (cAliasSF6)->F6_EST .And. x[2]== Alltrim((cAliasSF6)->F6_CODREC)})   
	   		   		
	    	   		If nPos > 0
		   				cXml += MontaXML( "periodo", cTipoRef, , , , , 15, .T., .T., .T. )
	   				EndIf
	                   
			   		If (cAliasSF6)->F6_MESREF > 0 
						cXml += MontaXML("mes",StrZero((cAliasSF6)->F6_MESREF,2),"N",9,2,,9,.T.,.T.,.T.)
			    	Endif 
			    	If (cAliasSF6)->F6_ANOREF > 0
						cXml += MontaXML("ano",(cAliasSF6)->F6_ANOREF,"N",9,2,,9,.T.,.T.,.T.) 
			   		Endif 
				   
				   	If lParcela			
			  			cXml += MontaXML("parcela","1","N",9,2,,9,.T.,.T.,.T.)
		   			EndIf
	   		
	   				cXml += MontaXML( "c05_referencia" , , , , , , 12, .F. , .T. , .T. )  
	
					nPos := 0 
					nPos := aScan(aTipoExc,{ |aX| aX[1] == (cAliasSF6)->F6_EST })   
					nPosEx := 0
					nPosEx := aScan(aTagEx,{ |x| x[1] == (cAliasSF6)->F6_EST .And. x[2]== Alltrim((cAliasSF6)->F6_CODREC)})   
					
					If nPosEx > 0 
						cXml += MontaXML("c39_camposExtras",,,,,,5,.T.,.F.,.T.)		
						//Informa็๕es complementares e Observa็ใo						
						If (cAliasSF6)->F6_EST$"GO/AL/MG/PR/RN/BA/PI/AM/PE/RS"
							cXml += MontaXML("campoExtra",,,,,,5,.T.,.F.,.T.)   
							cXml += MontaXML("codigo",aTipoExc[nPos][2],"C",9,2,,9,.T.,.T.,.T.)	 									
						    cXml += MontaXML("tipo","T","C",9,2,,9,.T.,.T.,.T.)
						    cXml += MontaXML("valor",(cAliasSF6)->F6_INF,"C",9,2,,9,.T.,.T.,.T.)
					    	cXml += MontaXML("campoExtra",,,,,,5,.F.,.T.,.T.)	
						Endif        
						
						//Rela็ใo a Chave
						If (((cAliasSF6)->F6_EST$"MS" .And. Alltrim((cAliasSF6)->F6_CODREC)=="100056") .And. !((cAliasSF6)->F6_EST$"AM" .And. Alltrim((cAliasSF6)->F6_CODREC)=="100030") .And.  !Empty(SF3->F3_CHVNFE))
							cXml += MontaXML("campoExtra",,,,,,5,.T.,.F.,.T.)   
							cXml += MontaXML("codigo",Iif((cAliasSF6)->F6_EST$"MS","27","36"),"C",9,2,,9,.T.,.T.,.T.)
							cXml += MontaXML("tipo","T","C",9,2,,9,.T.,.T.,.T.)
							cXml += MontaXML("valor",SF3->F3_CHVNFE,"C",9,2,,9,.T.,.T.,.T.)
							cXml += MontaXML("campoExtra",,,,,,5,.F.,.T.,.T.)	
						Endif 
						If (cAliasSF6)->F6_EST=="AM" .And. Alltrim((cAliasSF6)->F6_CODREC)=="100030" 
							cXml += MontaXML("campoExtra",,,,,,5,.T.,.F.,.T.)   
						   	cXml += MontaXML("codigo","14","N",9,2,,9,.T.,.T.,.T.) 
						   	cXml += MontaXML("tipo","N","N",9,2,,9,.T.,.T.,.T.)
						   	cXml += MontaXML("valor",(cAliasSF6)->F6_DESCOMP,"N",9,2,,9,.T.,.T.,.T.)
					   		cXml += MontaXML("campoExtra",,,,,,5,.F.,.T.,.T.)	
						Endif
						If (cAliasSF6)->F6_EST=="AC" .And. Alltrim((cAliasSF6)->F6_CODREC)=="100030" 
							cXml += MontaXML("campoExtra",,,,,,5,.T.,.F.,.T.)   
							cXml += MontaXML("codigo","24","C",9,2,,9,.T.,.T.,.T.)
						   	cXml += MontaXML("tipo","T","C",9,2,,9,.T.,.T.,.T.)
							cXml += MontaXML("valor",HTMLEnc(SM0->M0_NOMECOM),,,,,9,.T.,.T.,.T.,,,,.T.)
							cXml += MontaXML("campoExtra",,,,,,5,.F.,.T.,.T.)	
							cXml += MontaXML("campoExtra",,,,,,5,.T.,.F.,.T.)   
							cXml += MontaXML("codigo","25","C",9,2,,9,.T.,.T.,.T.)
						   	cXml += MontaXML("tipo","T","C",9,2,,9,.T.,.T.,.T.)
							cXml += MontaXML("valor",SM0->M0_CGC,,,,,24,.T.,.T.,.T.)
							cXml += MontaXML("campoExtra",,,,,,5,.F.,.T.,.T.)	
							cXml += MontaXML("campoExtra",,,,,,5,.T.,.F.,.T.)   
							cXml += MontaXML("codigo","26","C",9,2,,9,.T.,.T.,.T.)
						   	cXml += MontaXML("tipo","T","C",9,2,,9,.T.,.T.,.T.)
							cXml += MontaXML("valor",(cAliasSF6)->F6_DOC,"C",9,2,,9,.T.,.T.,.T.)
							cXml += MontaXML("campoExtra",,,,,,5,.F.,.T.,.T.)	
						Endif
			   			cXml += MontaXML("c39_camposExtras",,,,,,5,.F.,.T.,.T.)
					EndIf 	  
	  				
	  				cXml += MontaXML("TDadosGNRE",,,,,,5,.F.,.T.,.T.)		
	   	   			cXml += Chr (13)+Chr (10)
		        Endif
           	EndIf   
		   		nCount++
			EndIf 	

		SF6->( dbSetOrder(1))
 	 	If SF6->(MsSeek(xFilial("SF6")+(cAliasSF6)->F6_EST+(cAliasSF6)->F6_NUMERO)) .And. (cAliasSF6)->F6_EST$cMVUFGNRE
				If  ( Empty((cAliasSF6)->F6_PROCESS) .Or. (cAliasSF6)->F6_PROCESS=="2" ) .and. lGerou
       			RecLock("SF6",.F.)
	       		SF6->F6_PROCESS := "1"
	        	SF6->(MsUnlock())       
	        Endif
        Endif               	     
    		(cAliasSF6)->(DbSkip())     	           
       	Enddo

		If lGerou .and. !lAglFil

	       	cXml += MontaXML("guias",,,,,,,.F.,.T.,.T.)
			cXml += MontaXML("TLote_GNRE",,,,,,,.F.,.T.,.T.) 
      	 	MemoWrite(cDir+cNomeArq,cXml)
      	  	nLote++ 
      	   	cNomeArq := cFileDest+cFilAnt

      	ElseIf lGerou
			nLote++ 

   		Endif 
 		 	 	     	 		                    	
  	EndDo 
	
  	DbSelectArea(cAliasSF6)
	(cAliasSF6)->(DbCloseArea())

	SM0->(DbSkip())      
EndDo 


If lGerou .and. lAglFil
   	cXml += MontaXML("guias",,,,,,,.F.,.T.,.T.)
	cXml += MontaXML("TLote_GNRE",,,,,,,.F.,.T.,.T.) 
 	MemoWrite(cDir+cNomeArq,cXml)
Endif 

SM0->(RestArea(aAreaSM0))

cFilAnt := cFilBkp

Return (.T.) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGrvCab   บAutor  ณNatalia Antonucci   บ Data ณ  22/05/12    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o Cabecalho do XML                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function  GrvCab(nLote,cNomeArq)
Local cMontXml := ""

cNomeArq := cNomeArq + ALLTRIM(Str(nLote)) + ".XML"
 
		cMontXml += MontaXML("?xml",,,,,,,.T.,.F.,.T.,"version="+'"1.0"'+" encoding="+'"UTF-8" standalone="yes"'+" ?")
		cMontXml += MontaXML("TLote_GNRE",,,,,,,.T.,.F.,.T.,' xmlns="http://www.gnre.pe.gov.br"' )
		cMontXml += MontaXML("guias",,,,,,,.T.,.F.,.T.,.T.)  

Return(cMontXml)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณWizard    บAutor  ณNatalia Antonucci   บ Data ณ  22/05/12   บฑฑ
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
aAdd (aTxtApre, "Informa็๕es necessแrias para a gera็ใo do meio-magn้tico GNREON.")

//ฺฤฤฤฤฤฤฤฤฟ
//ณPainel 1ณ
//ภฤฤฤฤฤฤฤฤู
aAdd (aPaineis, {})
nPos	:=	Len (aPaineis)
aAdd (aPaineis[nPos], "Preencha corretamente as informa็๕es solicitadas.")
aAdd (aPaineis[nPos], "Parโmetros para Gera็ใo")
aAdd (aPaineis[nPos], {})
//
cTitObj1	:=	"Data de";								   		cTitObj2	:=	"Data at้"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});				aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
//
aAdd (aPaineis[nPos][3], {2,,,3,,,,});						aAdd (aPaineis[nPos][3], {2,,,3,,,,}) 
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj1	:=	"Diret๓rio do Arquivo Destino";					cTitObj2	:=	"Nome do Arquivo Destino"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});				aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
//
cTitObj1	:=	Replicate ("X", 50);							cTitObj2	:=	Replicate ("X", 20)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});				aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,20})
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj1	:=	"Filial de"; 									cTitObj2	:=	"Filial ate"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});				aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
//
cTitObj1	:=	Replicate ("X", 8);								cTitObj2	:=	Replicate ("X", 8)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,8});				aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,8})
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})

#IFDEF WINDOWS
	//
	cTitObj1	:=	"Seleciona Filiais?";							cTitObj2	:=	"Aglutina por CNPJ + I.E.?"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});				aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
	//
	aAdd (aPaineis[nPos][3], {3,,,,,{"Sim", "Nใo"},,});			aAdd (aPaineis[nPos][3], {3,,,,,{"Sim", "Nใo"},,})
#ENDIF
//
aAdd (aPaineis[nPos][3], {1,"",,,,,,});						aAdd (aPaineis[nPos][3], {1,"",,,,,,})

lRet	:=	xMagWizard (aTxtApre, aPaineis, cNomWiz)
Return (lRet)
                                           
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณConvType  บAutor  ณNatalia.antonucci   บ Data ณ  27/11/12	  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTratamento de caracteres especiais                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ConvType(xValor,nTam)
Local cNovo := ""

If nTam==Nil
	xValor := AllTrim(xValor)
EndIf

Default nTam := 60
cNovo := AllTrim(EnCodeUtf8(NoAcento(SubStr(xValor,1,nTam))))
Return(cNovo)
                                           
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVldIE     บAutor  ณNatalia Antonucci   บ Data ณ  27/11/12	  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida Incricao Estadual                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldIE(cInsc,lContr,lIsent)
Local 		cRet	:=	""
Local 		nI		:=	1
Default 	lContr  :=	.T.
Default		lIsent	:=	.T.

For nI:=1 To Len(cInsc)
	If Isdigit(Subs(cInsc,nI,1)) .Or. IsAlpha(Subs(cInsc,nI,1))
		cRet+=Subs(cInsc,nI,1)
	Endif
Next
cRet := AllTrim(cRet)

If lIsent
	If "ISENT"$Upper(cRet)
		cRet := ""
	EndIf
	If !(lContr) .And. !Empty(cRet)
		cRet := "ISENTA"
	EndIf
EndIf
Return(cRet)