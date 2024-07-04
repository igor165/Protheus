#Include "PCPR107.CH"
#Include "FIVEWIN.CH"

/*-------------------------------------------------------------------*/
/*/{Protheus.doc} PCPR107
MRP

@author Lucas Konrad França
@since 29/05/2015
@version P12
@obs Programa cópia do MATR882, lendo as novas tabelas do MRP Multi-empresa
/*/
/*-------------------------------------------------------------------*/

Function PCPR107(lUsed)
Local   oReport

Default lUsed := .F.

// Tela com aviso de descontinuação do programa
PCPMsgExp("PCPR107", STR0030, "https://tdn.totvs.com/pages/viewpage.action?pageId=699201724", "https://tdn.totvs.com/display/PROT/Resultados+do+MRP") // "Resultados MRP (resultadomrp)"


//Interface de impressao                                                  
oReport := ReportDef(lUsed)
oReport:PrintDialog()

Return NIL

/*------------------------------------------------------------------------//
//Programa:	ReportDef 
//Autor:		Felipe Nunes Toledo    
//Data:		11/07/06
//Descricao:	A funcao estatica ReportDef devera ser criada para todos os relatorios que poderao ser agendados pelo usuario
//Uso: 		PCPR107
//------------------------------------------------------------------------*/
Static Function ReportDef(lUsed)
Local oReport
Local oSection1
Local cTitle := OemToAnsi(STR0001) //"MRP"

//Criacao do componente de impressao                                      
//TReport():New                                                           
//ExpC1 : Nome do relatorio                                               
//ExpC2 : Titulo                                                          
//ExpC3 : Pergunte                                                        
//ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  
//ExpC5 : Descricao                                                       
oReport:= TReport():New("PCPR107",cTitle,"PCPR107", {|oReport| ReportPrint(oReport,cTitle,lUsed)},OemToAnsi(STR0002)) //"Este programa ira imprimir a Rela‡„o do MRP"
oReport:SetPortrait() //Define a orientacao de pagina do relatorio como paisagem.

//Criacao das secoes utilizadas pelo relatorio                            
//                                                                        
//TRSection():New                                                         
//ExpO1 : Objeto TReport que a secao pertence                             
//ExpC2 : Descricao da seçao                                              
//ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   
//        sera considerada como principal para a seção.                   
//ExpA4 : Array com as Ordens do relatório                                
//ExpL5 : Carrega campos do SX3 como celulas                              
//        Default : False                                                 
//ExpL6 : Carrega ordens do Sindex                                        
//        Default : False                                                 

//oSection1                                                  
oSection1 := TRSection():New(oReport,STR0027,{"SB1"},/*Ordem*/) //"Produtos"
oSection1:SetHeaderPage()

TRCell():New(oSection1,'B1_COD'    ,'SB1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'B1_DESC' 	,'SB1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'B1_UM'   	,'SB1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'B1_LE'   	,'SB1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,  {|| RetFldProd(SB1->B1_COD,"B1_LE") })
TRCell():New(oSection1,'B1_ESTSEG' ,'SB1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,  {|| RetFldProd(SB1->B1_COD,"B1_ESTSEG") })
TRCell():New(oSection1,'B1_EMIN' 	,'SB1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,  {|| RetFldProd(SB1->B1_COD,"B1_EMIN") })
TRCell():New(oSection1,'B1_TIPO' 	,'SB1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

Return(oReport)

/*------------------------------------------------------------------------//
//Programa:	ReportPrint 
//Autor:		Felipe Nunes Toledo    
//Data:		11/07/06
//Descricao:	A funcao estatica ReportPrint devera ser criada para todos os relatorios que poderao ser agendados pelo usuario.
//Uso: 		PCPR107
//------------------------------------------------------------------------*/
Static Function ReportPrint(oReport,cTitle,lUsed)
//Variaveis do tipo objeto
Local oSection1 := oReport:Section(1)
Local oSection2,oSection3,oSection4,oSection5,oBreak,oSectEmp

Local lContinua 	:= .T.
Local lVNecesEst	:= .F. 
Local lLista		:= .F.
Local lAchou    	:= .T.
Local lLogMrp		:= .F.
Local lMultiEmp     := .T.

Local nTipo     	:= 0
Local j         	:= 0
Local i				:= 0
Local nCusto    	:= 0
Local nRec		 	:= 0
Local nParRel		:= 0
Local nTotValor		:= 0
Local nQtdPer		:= 0
Local nH5_Quant 	:= 0

Local cSeekLog	:= ""
Local cCondSH5 	:= "OQ_PROD != '"+Criavar("B1_COD",.F.)+"'"
Local cCampo		:= ""
Local cFilUsrSB1	:= ""  
Local cFil		  	:= ""
Local cAliasSOR 	:= ""
Local cFili         := ""
Local cEmpresa      := ""

Local aPerOri   	:= {}
Local aTam     		:= TamSX3("B2_QFIM")
Local cDoc			:= ''

Private aPerQuebra  := {}
Private cPerg       := "PCPR107"
Private nPeriodos   := 0
Private nTipoCusto  := 1
Private aPeriodos	:= {}
Private lQuebraPer	:= .F.
Private nNumPer		:= 0
Private cEmpFil     := ""

Private cCriaTrab

//Verifica as perguntas selecionadas (PCPR107)                 
//Variaveis utilizadas para parametros                                    
//mv_par01 - Lista ? Tudo     So' c/ Saidas   So' c/ Neces.               
//mv_par02 - De Produto                                                   
//mv_par03 - Ate Produto                                                  
//mv_par04 - Lista log de eventos  1 = sim 2 = nao                        
//mv_par05 - Custo Produto: 1-Custo Standard;2-Custo Medio;3-Preco Compra 
//mv_par06 - Aglutina Periodos     1 = sim 2 = nao                        
//mv_par07 - Periodos para aglutina                                       
//mv_par08 - Lista a Necess. da Estrutura? 1 = sim 2 = nao                

Pergunte(oReport:GetParam(),.F.)

nParRel     := mv_par01
nTipoCusto  := mv_par05
lLogMrp     := mv_par04 == 1
lQuebraPer  := mv_par06 == 1
nNumPer     := mv_par07
lVNecesEst  := mv_par08 == 1

lMultiEmp := verMultEmp()

//Monta os Cabecalhos                                         
If lUsed != .T.
	lContinua := PCPA107LCK()
EndIf

cCriaTrab := CriaTrab(Nil, .F.)

If lContinua
	dbSelectArea("SOQ")
	
	If !Empty(dbFilter())
		dbClearFilter()
	EndIf
	
	dbSetOrder(1)
	dbSeek(xFilial("SOQ"))
	
	//Definindo o titulo do relatorio
	oReport:SetTitle(cTitle+" - "+STR0018+" "+SOQ->OQ_NRMRP) //"MRP"##"Programacao"
	
	aPeriodos := R107PER(@nTipo)
	
	If cPaisLoc = "RUS"
	   cAliasSOR := PCPA107MVW(.F.,cCriaTrab)
    Else 
	   cAliasSOR := PCPA107MVW(.F.,"CRIATABR")
	EndIf
	
	If lQuebraPer
		aPerOri    := aClone(aPeriodos)
		aPerQuebra := R107DivPeriodo(aPeriodos,.T.)
		aPeriodos  := R107DivPeriodo(aPeriodos)
	EndIf
	
	dbSelectArea("SOQ")
	Set Filter to &cCondSH5
Else
	If cPaisLoc = "RUS"
	   cAliasSOR := PCPA107MVW(.F.,cCriaTrab)
    Else 
	   cAliasSOR := PCPA107MVW(.F.,"CRIATABR")
	EndIf
EndIf



//oSection2                                                  
oSection2 := TRSection():New(oSection1,cTitle,{cAliasSOR,"SB1","SOQ"},/*Ordem*/) //"MRP"
oSection2:SetHeaderPage()

TRCell():New(oSection2,'TEXTO',cAliasSOR,STR0016 ,'',25,/*lPixel*/,/*{|| code-block de impressao }*/) //'Periodos'

For i := 1 to Len(aPeriodos)
	cCampo := "PER"+StrZero(i,3)
	TRCell():New(oSection2,cCampo,cAliasSOR,DtoC(aPeriodos[i]),"999999999999.99",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	oSection2:Cell(cCampo):SetLineBreak() // Define quebra de linha caso as colunas nao couberem na pagina
Next i

TRCell():New(oSection2,'PRODUTO',cAliasSOR,STR0028,'',/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //Produtos

//oSectEmp
If lMultiEmp
	oSectEmp := TRSection():New(oSection2,cTitle,{cAliasSOR,"SB1","SOQ"},/*Ordem*/) //"MRP"
	oSectEmp:SetHeaderPage()
	TRCell():New(oSectEmp,'',,STR0029,,50,.F.,{|| cEmpFil })  //empresa
EndIf

//oSection3                                                  
oSection3 := TRSection():New(oSection2,cTitle,{cAliasSOR,"SB1","SOQ"},/*Ordem*/) //"MRP"
oSection3:SetHeaderPage(.F.)
oSection3:SetHeaderSection(.F.)

TRCell():New(oSection3,'TEXTO',cAliasSOR,STR0026,'',25,/*lPixel*/,/*{|| code-block de impressao }*/)

For i := 1 to Len(aPeriodos)
	cCampo := "PER"+StrZero(i,3)
	TRCell():New(oSection3,cCampo,cAliasSOR,DtoC(aPeriodos[i]),"999999999999.99",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 
	oSection2:Cell(cCampo):SetLineBreak() // Define quebra de linha caso as colunas nao couberem na pagina
Next i

If lVNecesEst //-- Lista Neces. da Estrutura
	//oSection4                                                  
	oSection4 := TRSection():New(oSection2,cTitle,{cAliasSOR,"SB1","SOQ"},/*Ordem*/) //"MRP"
	oSection4:SetHeaderPage(.F.)
	oSection4:SetHeaderSection(.F.)

	TRCell():New(oSection4,'OQ_DOC','SOQ',STR0026,'',25,/*lPixel*/,/*{|| code-block de impressao }*/)
	For i := 1 to Len(aPeriodos)
		cCampo := "OQ_PER"+StrZero(i,3)
		TRCell():New(oSection4,cCampo,'SOQ',DtoC(aPeriodos[i]),"999999999999.99",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
		oSection4:Cell(cCampo):SetLineBreak() // Define quebra de linha caso as colunas nao couberem na pagina
	Next i
EndIf

If lLogMRP //-- Lista Log do MRP
	//oSection5 (Log do MRP)                                      
	oSection5 := TRSection():New(oSection3,cTitle,{cAliasSOR,"SHG"},/*Ordem*/) //"MRP"
	oSection5:SetHeaderPage(.F.)
	oSection5:SetHeaderSection(.F.)
	
	TRCell():New(oSection5,'HG_LOGMRP','SHG',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	oSection5:Cell('HG_LOGMRP'):SetLineBreak() // Define quebra de linha caso as colunas nao couberem na pagina
EndIf

//Definindo a Quebra
oBreak := TRBreak():New(oSection2,oSection2:Cell("PRODUTO"),NIL,.F.)

If lContinua
	dbSelectArea(cAliasSOR)
	//Condicao de Filtragem do SOR                                 ³
	Set Filter to PRODUTO >= MV_PAR02 .And. PRODUTO <= MV_PAR03
	dbGotop()

	//Transforma parametros Range em expressao ADVPL                         
	MakeAdvplExpr(oReport:GetParam())

	//Posicionamento da tabela SB1 
	TRPosition():New(oSection1,"SB1",1,{||xFilial("SB1")+(cAliasSOR)->PRODUTO})

	//Inibindo Celula
	oSection2:Cell("PRODUTO"):Hide()
	oSection2:Cell("PRODUTO"):HideHeader()
	
	//Inicio da impressao do fluxo do relatorio                               
	oReport:SetMeter((cAliasSOR)->(LastRec()) )
	oSection1:Init()
	oSection2:Init()
	If lMultiEmp
		oSectEmp:Init()
	EndIf
	oSection3:Init()
	
	cFilUsrSB1:= oSection1:GetAdvplExp()
	
	While !oReport:Cancel() .And. !(cAliasSOR)->(Eof())
		If !Empty(cFilUsrSB1)
		    SB1->(MsSeek(xFilial("SB1")+(cAliasSOR)->PRODUTO))
		    If !(&("SB1->"+cFilUsrSB1))
		       (cAliasSOR)->(dbSkip())
	    	   Loop
	    	EndIf   
		EndIf
		
		lLista := R107FILTRO(nParRel,nTipo,cAliasSOR) //-- Filtro conforme MV_PAR01
		
		If lLista
		   oSection1:PrintLine() //-- Impressao da secao 1
		   //oReport:SkipLine()
	       cFil	    := xFilial("SOQ")
	       cEmpresa := (cAliasSOR)->EMPRESA
	       cFili    := (cAliasSOR)->FILIAL
	       cProdAnt := (cAliasSOR)->PRODUTO
	       cOpcAnt  := (cAliasSOR)->OPCIONAL
	       cSeekLog := (cAliasSOR)->MRP+(cAliasSOR)->PRODUTO
           If lMultiEmp
	          cEmpFil := AllTrim(cEmpresa) + "/" + AllTrim(cFili) + " - " + AllTrim(FWEmpName(cEmpresa)) + " / " + AllTrim(FWFilialName(cEmpresa,cFili,1))
		      oSectEmp:PrintLine()
		   EndIf

    	   nPerIni  := 1
	       While (cAliasSOR)->PRODUTO == cProdAnt .And. (cAliasSOR)->OPCIONAL == cOpcAnt
	            If lMultiEmp .And. ((cAliasSOR)->EMPRESA != cEmpresa .Or. (cAliasSOR)->FILIAL != cFili)
                   oReport:SkipLine()
                   cEmpresa := (cAliasSOR)->EMPRESA
                   cFili    := (cAliasSOR)->FILIAL
                   cEmpFil := AllTrim(cEmpresa) + "/" + AllTrim(cFili) + " - " + AllTrim(FWEmpName(cEmpresa)) + " / " + AllTrim(FWFilialName(cEmpresa,cFili,1))
                   oSectEmp:PrintLine()
	            EndIf
				If lQuebraPer
					For i := 1 to 6
						For j := 1 to 6
							If j > Len(aPeriodos)
								Exit
							EndIf
							nQtdPer := R107ValField(j,cAliasSOR)
							cCampo  := "PER"+StrZero(j,3)
							oSection2:Cell(cCampo):SetValue( nQtdPer )
						Next
						oReport:IncMeter()
						oSection2:PrintLine() //-- Impressao da secao 2
						nRec := Recno()
						(cAliasSOR)->(dbSkip())
					Next
				Else
					oReport:IncMeter()
					oSection2:PrintLine() //-- Impressao da secao 2
					nRec := Recno()
					(cAliasSOR)->(dbSkip())
				EndIf
			EndDo
			
			//Definindo o Valor da Necessidade
			nTotValor := 0
			(cAliasSOR)->(DbGoto(nRec))
		   	oSection3:Cell('TEXTO'):SetValue("Valor")
			
			For i:= 1 To Len(aPeriodos)
	  			nCusto	:= R107Custo((cAliasSOR)->PRODUTO)
	  			dbSelectArea(cAliasSOR)
	  			nQtdPer := R107ValField(i,cAliasSOR)
	  			cCampo  := "PER"+StrZero(i,3)
				oSection3:Cell(cCampo):SetValue(nQtdPer * nCusto)
				nTotValor += oSection3:Cell(cCampo):GetValue()
	       Next i	
			oSection3:PrintLine() //-- Impressao da secao 3
			(cAliasSOR)->(dbSkip())    

			//Lista a necessidade da estrutura do produto possicionado a partir da tabela SOQ com OQ_ALIAS igual a "SOR".                               ³
			If lVNecesEst 
				oSection4:Init()
				SOQ->(dbSetOrder(3))
				If (lAchou:=SOQ->(dbSeek(xFilial("SOQ")+cEmpresa+cFili+cProdAnt+"SOR")))
					oReport:SkipLine()
					oReport:PrintText(STR0022)
				EndIf
				
				nH5_Quant:=0
				cDoc := ''
				While SOQ->(!Eof() .AND. OQ_EMP+OQ_FILEMP+OQ_PROD+OQ_ALIAS == cEmpresa+cFili+cProdAnt+"SOR")
					cDoc := SOQ->OQ_DOC
					oSection4:Cell('OQ_DOC'):SetValue(SOQ->OQ_DOC )
					lExit := .F.
					For i:= 1 To Len(aPeriodos)
						cCampo  := "OQ_PER"+StrZero(i,3) 
						If SOQ->OQ_DTOG <= aPeriodos[i] .And. !lExit
							if !lQuebraPer
						 		oSection4:Cell(cCampo):SetValue(SOQ->OQ_QUANT)  
						 	else
						 		nH5_Quant += SOQ->OQ_QUANT
							Endif
							
							SOQ->(dbSkip())
							
							If SOQ->(Eof()) .Or. SOQ->OQ_EMP+SOQ->OQ_FILEMP+SOQ->OQ_PROD+SOQ->OQ_ALIAS+SOQ->OQ_DOC # cEmpresa+cFili+cProdAnt+"SOR"+cDoc
								lExit := .T.
							EndIf
						Elseif !lQuebraPer
							oSection4:Cell(cCampo):SetValue( 0 )
						EndIf
					Next i 
					
					

					if !lQuebraPer
						oSection4:PrintLine() //-- Impressao da secao 4
					EndIf
				EndDo
				if lQuebraPer .And. lAchou
					oSection4:Cell(cCampo):SetValue( nH5_Quant )  
					oSection4:PrintLine() //-- Impressao da secao 4
				EndIf
				
				oSection4:Finish()
			EndIf
   			oReport:SkipLine()
			//Imprime o Vlr. Total do Produto
		    oReport:PrintText(STR0021+"          "+Str(nTotValor,aTam[1],aTam[2]))
		    
 			//Lista os eventos de log desse produto
			If lLogMrp
				oSection5:Init()
				dbSelectArea("SHG")
				If dbSeek(xFilial("SHG")+cSeekLog)
					oReport:PrintText(STR0019) //"Eventos relacionados ao produto"
					While !EOF() .AND. xFilial("SHG")+cSeekLog == HG_FILIAL+HG_SEQMRP+HG_COD
						oSection5:PrintLine() //-- Impressao da secao 5
						SHG->(dbSkip())
					EndDo
				EndIf
				oSection5:Finish()
				oReport:SkipLine()
				dbSelectArea(cAliasSOR)
			EndIf
			oReport:ThinLine()
		Else
	    	(cAliasSOR)->(dbSkip(6))
	    EndIf
	EndDo
	oSection3:Finish()
	
	If lMultiEmp
	   oSectEmp:Finish()
	Endif   
	oSection2:Finish()
	oSection1:Finish()

EndIf
If (lContinua = .T.) .And. (lUsed != .T.)
	dbSelectArea(cAliasSOR)
	dbCloseArea()
	dbSelectArea("SOQ")
	dbCloseArea()
ElseIf lContinua
	(cAliasSOR)->(dbClearFilter())
	SOQ->(dbClearFilter())
EndIF

dbSelectArea("SB1")
dbClearFilter()
dbSetOrder(1)

Return Nil

/*------------------------------------------------------------------------//
//Programa:	R107PER 
//Autor:		Rodrigo de A Sartorio
//Data:		03/02/97
//Descricao:	Rotina de montagem de array aperiodos para Impressao
//Uso: 		PCPR107
//------------------------------------------------------------------------*/
Static Function R107PER(nTipo)
Local i
Local dInicio
Local aRet := {}
Local nPosAno
Local nTamAno
Local cForAno
Local lConsSabDom := Nil

Pergunte("MTA712",.F.)
lConsSabDom := mv_par12 == 1
Pergunte(cPerg, .F.)

If __SetCentury()
	nPosAno := 1
	nTamAno := 4
	cForAno := "ddmmyyyy"
Else
	nPosAno := 3
	nTamAno := 2
	cForAno := "ddmmyy"
EndIf

//Adiciona registro em array totalizador utilizado no TREE  
dbSelectArea("SOQ")
dbSetOrder(1)
dbGotop()
While !Eof()
	// Recupera parametrizacao gravada no ultimo processamento
	// A T E N C A O
	// Quando utilizado o processamento por periodos variaveis o sistema monta o array com
	// os periodos de maneira desordenada, por causa do indice do arquivo SH5
	// O array aRet é corrigido logo abaixo
	If OQ_ALIAS == "PAR"
		nTipo       := OQ_NRRGAL
		dInicio     := OQ_DTOG
		nPeriodos   := OQ_QUANT
		If nTipo == 7
			AADD(aRet,DTOS(CTOD(Alltrim(OQ_OPC))))
		EndIf
		//NUMERO DO MRP                                                ³
		c711NumMRP := OQ_NRMRP
	EndIf
	dbSkip()
End

//Somente para nTipo==7 (Periodos Diversos) re-ordena aRet
//pois como o H5_OPC esta gravado a data como caracter ex:(09/10/05)
//o arquivo esta indexado incorretamente (diferente de 20051009)
If !Empty(aRet)
	ASort(aRet)
	For i:=1 To Len(aRet)
		aRet[i] := STOD(aRet[i])
	Next i
EndIf

If (nTipo == 2)                         // Semanal
	While Dow(dInicio)!=2
		dInicio--
	EndDo
ElseIf (nTipo == 3) .or. (nTipo=4)      // Quinzenal ou Mensal
		dInicio:= CtoD("01/"+Substr(DtoS(dInicio),5,2)+Substr(DtoC(dInicio),6),cForAno)
ElseIf (nTipo == 5)                     // Trimestral
	If Month(dInicio) < 4
		dInicio := CtoD("01/01/"+Substr(DtoC(dInicio),7),cForAno)
	ElseIf (Month(dInicio) >= 4) .and. (Month(dInicio) < 7)
		dInicio := CtoD("01/04/"+Substr(DtoC(dInicio),7),cForAno)
	ElseIf (Month(dInicio) >= 7) .and. (Month(dInicio) < 10)
		dInicio := CtoD("01/07/"+Substr(DtoC(dInicio),7),cForAno)
	ElseIf (Month(dInicio) >=10)
		dInicio := CtoD("01/10/"+Substr(DtoC(dInicio),7),cForAno)
	EndIf
ElseIf (nTipo == 6)                     // Semestral
	If Month(dInicio) <= 6
		dInicio := CtoD("01/01/"+Substr(DtoC(dInicio),7),cForAno)
	Else
		dInicio := CtoD("01/07/"+Substr(DtoC(dInicio),7),cForAno)
	EndIf
EndIf

If nTipo != 7
	For i := 1 to nPeriodos
		AADD(aRet,dInicio)
		If nTipo == 1
			dInicio ++
			While !lConsSabDom .And. ( DOW(dInicio) == 1 .or. DOW(dInicio) == 7 )
				dInicio++
			EndDo
		ElseIf nTipo == 2
			dInicio+=7
		ElseIf nTipo == 3
			dInicio := StoD(If(Substr(DtoS(dInicio),7,2)<"15",Substr(DtoS(dInicio),1,6)+"15",;
	 		If(Month(dInicio)+1<=12,Str(Year(dInicio),4)+StrZero(Month(dInicio)+1,2)+"01",;
			Str(Year(dInicio)+1,4)+"0101")),cForAno)			
		ElseIf nTipo == 4
			dInicio := CtoD("01/"+If(Month(dInicio)+1<=12,StrZero(Month(dInicio)+1,2)+;
			"/"+Substr(Str(Year(dInicio),4),nPosAno,nTamAno),"01/"+Substr(Str(Year(dInicio)+1,4),nPosAno,nTamAno)),cForAno)
		ElseIf nTipo == 5
			dInicio := CtoD("01/"+If(Month(dInicio)+3<=12,StrZero(Month(dInicio)+3,2)+;
			"/"+Substr(Str(Year(dInicio),4),nPosAno,nTamAno),"01/"+Substr(Str(Year(dInicio)+1,4),nPosAno,nTamAno)),cForAno)
		ElseIf nTipo == 6
			dInicio := CtoD("01/"+If(Month(dInicio)+6<=12,StrZero(Month(dInicio)+6,2)+;
			"/"+Substr(Str(Year(dInicio),4),nPosAno,nTamAno),"01/"+Substr(Str(Year(dInicio)+1,4),nPosAno,nTamAno)),cForAno)
		EndIf
	Next i
EndIf

Return aRet

/*------------------------------------------------------------------------//
//Programa:	R107FILTRO 
//Autor:		Rodrigo de A Sartorio
//Data:		03/02/97
//Descricao:	Filtra período
//Uso: 		PCPR107
//------------------------------------------------------------------------*/
Static Function R107FILTRO(nParRel,nTipo,cAliasSOR)
Local ni		:= 0
Local lRet 	:= .F.
Local cAlias 	:= Alias()
Local nReg		:=0

dbSelectArea(cAliasSOR)
nReg := Recno()

If nParRel == 1
	lRet := .T.
ElseIf nParRel == 2
	dbSkip(2)
	For ni := 1 to nPeriodos
		cCampo := "PER"+StrZero(ni,3)
		If &(cCampo) != 0
			lRet := .t.
			Exit
		EndIf
	Next
	If !lRet
		dbSkip()
		For ni := 1 to nPeriodos
			cCampo := "PER"+StrZero(ni,3)
			If &(cCampo) != 0
				lRet := .t.
				Exit
			EndIf
		Next
	EndIf
ElseIf nParRel == 3
	dbSkip(5)
	For ni := 1 to nPeriodos
		cCampo := "PER"+StrZero(ni,3)
		If &(cCampo) != 0
			lRet := .t.
			Exit
		EndIf
	Next
EndIf

dbGoto(nReg)
dbSelectArea(cAlias)

Return (lRet)

/*------------------------------------------------------------------------//
//Programa:	R107Custo 
//Autor:		Marcelo Iuspa 
//Data:		05/01/05 
//Descricao:	Retorna o custo do produto informado baseado na opcao do pergunte (mv_par05):
//				Custo Produto: 1-Custo Standard;2-Custo Medio;3-Preco Compra
//Uso: 		PCPR107
//------------------------------------------------------------------------*/
Function R107Custo(cProd)
Local nCusto := 0

SB1->(MsSeek(xFilial("SB1") + cProd))
If nTipoCusto == 1
	nCusto := RetFldProd(SB1->B1_COD,"B1_CUSTD")
	cStr:="1"
ElseIf nTipoCusto == 2
	nCusto := PegaCmAtu(cProd, RetFldProd(SB1->B1_COD,"B1_LOCPAD"))[1]
	cStr:="2"
ElseIf nTipoCusto == 3
	nCusto := RetFldProd(SB1->B1_COD,"B1_UPRC")
	cStr:="3"
EndIf

Return(nCusto)

/*------------------------------------------------------------------------//
//Programa:	R107DivPeriodo 
//Autor:		Marcelo Iuspa 
//Data:		18/01/05
//Descricao:	Retorna o array de periodos aglutinados conforme parametro
//Uso: 		PCPR107
//------------------------------------------------------------------------*/
Function R107DivPeriodo(aPeriodos, lRetQuebra)
Local nLenArr := Len(aPeriodos)
Local nLoop   := Nil
Local nAglut  := 1
Local aRetPer := {aPeriodos[1]}
Local aQuebra := {{1, {1}}}

Default lRetQuebra := .F.

For nLoop := 2 to nLenArr
	If nAglut >= nNumPer
		Aadd(aRetPer, aPeriodos[nLoop])
		Aadd(aQuebra, {Len(aQuebra)+1, {}})
		nAglut := 1
	Else
		nAglut ++
	EndIf
	Aadd(aQuebra[Len(aQuebra), 2], nLoop)
Next

Return(If(lRetQuebra, aQuebra, aRetPer))

/*------------------------------------------------------------------------//
//Programa:	R107ValField 
//Autor:		Marcelo Iuspa 
//Data:		18/01/05
//Descricao:	Retorna o array de periodos aglutinados conforme parametro
//Uso: 		PCPR107
//------------------------------------------------------------------------*/
Function R107ValField(nPeriodo,cAliasSOR)
Local nRet  := 0
Local nLoop := 0
Local aPer  := Nil

If ! lQuebraPer
	nRet := (cAliasSOR)->(FieldGet(FieldPos("PER" + StrZero(nPeriodo, 3))))
Else
	aPer := aPerQuebra[nPeriodo, 2]
	For nLoop := 1 to Len(aPer)
		nRet += (cAliasSOR)->(FieldGet(FieldPos("PER" + StrZero(aPer[nLoop], 3))))
		If (cAliasSOR)->TIPO == "1"
			Exit
		ElseIf (cAliasSOR)->TIPO == "5"
			nRet := (cAliasSOR)->(FieldGet(FieldPos("PER" + StrZero(aPer[nLoop], 3))))
		EndIf
	Next
EndIf
Return(nRet)

/*------------------------------------------------------------------------//
//Programa:	 verMultEmp 
//Autor:	 Lucas Konrad França
//Data:		 01/06/2015
//Descricao: Verifica se a ultima execução do MRP foi realizada em um ambiente multi-empresa.
//Uso: 		 PCPR107
//------------------------------------------------------------------------*/
Static Function verMultEmp()
   Local cQuery := ""
   Local aArea  := GetArea()
   Local cAlias := GetNextAlias()
   Local lRet   := .T.

   cQuery := " SELECT COUNT(*) TOTAL "
   cQuery +=   " FROM (SELECT DISTINCT OQ_EMP, OQ_FILEMP FROM " + RetSqlName("SOQ") + " ) T "
   
   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

   If (cAlias)->TOTAL > 1
      lRet := .T.
   Else
      lRet := .F.
   EndIf
   (cAlias)->(dbCloseArea())
   RestArea(aArea)
Return lRet
