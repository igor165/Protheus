#INCLUDE "mata962.ch"
#INCLUDE "PROTHEUS.CH"
   
#DEFINE CRLF Chr(13)+Chr(10)
//Posicoes do array de impostos
#DEFINE IVA  01 
#DEFINE RNI  02 
#DEFINE PIB  03    
#DEFINE PIN  04    
#DEFINE PIM  05    
#DEFINE PII  06    
#DEFINE MAX_DEFIMP  06   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MATA962      ³Autor ³ Luciana Pires        ³Data³ 22/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera o arquivo magnetico com os comprovantes originais da  ³±±  
±±³          ³ nota fiscal eletronica da Argentina - campo _CAE preenc.   ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Function MATA962()
Local aAreaSF3 	:= SF3->(GetArea())
Local aAreaAtu 	:= GetArea()
Local aStruSF3	:= {}
Local lRetor	:= .T.
Local cQuerySF3	:= ""
Local cIndexSF3	:= ""
Local cChaveSF3	:= ""
Local cNfAtu	:= ""
Local cEspecieV	:= GetNewPar("MV_NFEARG1","NF/NDC/NCC")		//Especies de NFs validas
Local cSerieV	:= GetNewPar("MV_NFEARG2","A/B")			//Series de NFs validas
Local cPerg   	:= "MTA962"
Local cNotaIni	:= ""   
Local cNotaFin	:= ""   
Local cCliDe	:= ""   
Local cLojaDe	:= ""   
Local cCliAte	:= ""   
Local cLojaAte	:= ""   
Local nI		:= 0
Local nTotFat	:= 0
Local nIndexSF3	:= 0  

Private lQuery	:= .F.     
Private aDArq    	:= Array(2)    
Private aDImps		:= Array(MAX_DEFIMP,03)
Private cAliasSF3	:= "SF3"   
Private cInscIB		:= "" 
Private cNomeA		:= ""
Private dDmainc	
Private dDmaFin	
Private dDtIniAt 
Private nFatArq		:= 0  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as perguntas selecionadas                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Data Inicio geracao                              ³
//³ mv_par02 - Data Final geracao                               ³ 
//| mv_par03 - Cliente de                                       ³ 
//| mv_par04 - Loja de                                          ³ 
//| mv_par05 - Cliente ate                                      |
//| mv_par06 - Loja ate                                         ³ 
//| mv_par07 - Documento de                                     |
//| mv_par08 - Documento ate                                    |
//| mv_par09 - Nome arquivo                                     |
//| mv_par10 - Caminho a salvar                                 |
//| mv_par11 - Impostos Liquidado - IVA                         |
//| mv_par12 - Impostos RNI                                     | 
//| mv_par13 - Impostos Ingressos Brutos                        | 
//| mv_par14 - Impostos Nacionais                               | 
//| mv_par15 - Impostos Municipais                              | 
//| mv_par16 - Impostos Internos                                | 
//| mv_par17 - Numero de inscripcion e ingresos brutos          |
//³ mv_par18 - Data Inicio atividades da empresa                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.T.)

dDmainc		:= MV_PAR01
dDmaFin		:= MV_PAR02
dDtIniAt	:= MV_PAR18
cNotaIni	:= MV_PAR07
cNotaFin	:= MV_PAR08
cCliDe		:= MV_PAR03
cLojaDe		:= MV_PAR04
cCliAte		:= MV_PAR05
cLojaAte	:= MV_PAR06    
cNomeA		:= Alltrim(MV_PAR09)
cInscIB		:= MV_PAR17    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se as categorias de impostos foram        ³
//³configuradas corretamente e se existe o diret.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If VerifDir() .And. ChecaParam()
	
	#IFDEF TOP
		If TcSrvType()<>"AS/400"
			lQuery := .T.
		Endif
	#ENDIF
	
	dbSelectArea("SF3")
	If lQuery
		cAliasSF3	:= "TopSF3"
		aStruSF3	:= SF3->(dbStruct())           
		cQuerySF3	:= "SELECT *"
		cQuerySF3	+= " FROM " + RetSQLName("SF3") 
		cQuerySF3	+= " WHERE F3_FILIAL = '"+xFilial("SF3")+"' AND"
		cQuerySF3	+= " F3_EMISSAO BETWEEN '"+Dtos(dDmainc)+ "' AND '"+Dtos(dDmaFin)+"' AND" 
		cQuerySF3	+= " F3_NFISCAL BETWEEN '"+cNotaIni+"' AND '"+cNotaFin+"' AND" 
		cQuerySF3	+= " F3_CLIEFOR BETWEEN '"+cCliDe+"' AND '"+cCliAte+"' AND" 
		cQuerySF3	+= " F3_LOJA BETWEEN '"+cLojaDe+"' AND '"+cLojaAte+"' AND" 
		cQuerySF3	+= " F3_CAE <> ' ' AND" 
		cQuerySF3	+= " F3_DTCANC = ' ' AND"		
		cQuerySF3	+= " D_E_L_E_T_ = ' '"
		cQuerySF3	+= " ORDER BY F3_EMISSAO,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_CAE"

		cQuerySF3	:= ChangeQuery(cQuerySF3)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuerySF3),cAliasSF3,.F.,.T.)	
	
		For nI := 1 To Len(aStruSF3)
			If aStruSF3[nI][2] != "C" .And. FieldPos(aStruSF3[nI][1]) != 0
				TCSetField(cAliasSF3,aStruSF3[nI][1],aStruSF3[nI][2],aStruSF3[nI][3],aStruSF3[nI][4])
			EndIf
		Next nI           
	Else
		cIndexSF3 := CriaTrab(Nil,.F.)
		cChaveSF3 := "DTOS(F3_EMISSAO)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA+F3_CAE"
		cQuerySF3 := "F3_FILIAL == '"+xFilial("SF3")+"' .And. "
		cQuerySF3 += "Dtos(F3_EMISSAO) >= '"+Dtos(dDmainc)+"' .And. Dtos(F3_EMISSAO) <= '"+Dtos(dDmaFin)+"' .And. "
		cQuerySF3 += "F3_NFISCAL >= '"+cNotaIni+"' .And. F3_NFISCAL <= '"+cNotaFin+"' .And. "
		cQuerySF3 += "F3_CLIEFOR >= '"+cCliDe+"' .And. F3_CLIEFOR <= '"+cCliAte+"' .And. "
		cQuerySF3 += "F3_LOJA >= '"+cLojaDe+"' .And. F3_LOJA <= '"+cLojaAte+"' .And. "
		cQuerySF3 += "!(Empty(F3_CAE)) .And. "	
		cQuerySF3 += "Empty(F3_DTCANC) "	

		IndRegua("SF3",cIndexSF3,cChaveSF3,,cQuerySF3,OemToAnsi(STR0001)) //"Selecionando Registros..."
			
		nIndexSF3 := RetIndex("SF3")
		dbSelectArea("SF3")
		dbSetIndex(cIndexSF3+OrdBagExt())
		dbSetOrder(nIndexSF3+1)
	Endif
	                                                                    	
	dbSelectArea(cAliasSF3)
	dbGoTop()
	While !Eof()
		IncProc()
		If Alltrim(F3_ESPECIE) $ cEspecieV .And. Left(Alltrim(F3_SERIE),1) $ cSerieV
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se eh a mesma nota                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cNfAtu <> Dtos(F3_EMISSAO)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA
				cNfAtu := Dtos(F3_EMISSAO)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA

				nFatArq++
				//Funcao que cria o array com os dados referentes ao arquivo .txt e tambem
				//chama a funcao responsavel pela criacao fisica do arquivo .txt
				If !CriaArqTxt(@aDArq,nFatArq)
					Return()
				EndIf   
                
                If lQuery
					nTotFat := (cAliasSF3)->(RecCount())
					If nFatArq == 1 .And. nTotFat > 10
		    			lRetor := MsgNoYes(STR0009+Alltrim(Str(nTotFat))+" "+STR0010) //"Atención!! Serão gerados aproximadamente "#"arquivos, com base nos parâmetros informados! Deseja continuar o processamento?"
					Endif
				Endif
				
				If lRetor
					//Gera o arquivo de Comprovantes
					GeraDadCmp(F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_EMISSAO,F3_DTCANC,@aDArq,F3_TES)		
				Else
					//Caso o usuario escolhar abortar a rotina o arquivo
					//aberto deve ser fechado...
					TrabArqTxt(.T.,,,aDArq[2],"")	

					Return()				
				Endif
		    Endif
		Endif
		dbSelectArea(cAliasSF3)
		dbSkip()

		//Realiza o fechamento do .TXT...
		TrabArqTxt(.T.,,,aDArq[2],"")				
	Enddo
	
	If lQuery
		dbSelectArea(cAliasSF3)
		dbCloseArea()
	Else
	  	dbSelectArea(cAliasSF3)
		RetIndex(cAliasSF3)
		dbClearFilter()
		Ferase(cIndexSF3+OrdBagExt())
	EndIf
	
	If nFatArq == 0
	    MsgAlert(STR0011) //"Atención!! Não existem notas fiscais com número de CAE preenchido e com os parâmetros informados!"				
	Endif
Endif

//Restaura o indice original do arquivo SF3...
RestArea(aAreaSF3)

//Retorna a area original...
RestArea(aAreaAtu)
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ChecaParam ³ Autor ³Luciana Pires          ³ Data ³ 28.12.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Checa parametros dos impostos                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ChecaParam()
Local lRet	:= .T.
Local nTam	:= TamSX3("FB_CODIGO")[1]
Local nI	:= 0
Local nX	:= 0
Local nY	:= 0

//Verifica se as categorias de impostos foram configuradas corretamente...
For nI := 11 To 16
	cParam := AllTrim(&("MV_PAR"+StrZero(nI,2)))
	For nX := 1 To Len(cParam)
		cImp := SubStr(cParam,nX,nTam)
		For nY := 11 To 16
			If nY <> nI
				If cImp$AllTrim(&("MV_PAR"+StrZero(nY,2)))
					MsgAlert(OemToAnsi(STR0002)+cImp+OemToAnsi(STR0003)) //"O imposto "#cImp#" esta compondo mais de uma categoria. Por favor, para continuar com o processo, acerte os parametros."
					lRet := .F.
					Exit
				EndIf
			EndIf
			If !lRet
				Exit
			EndIf
		Next nY
		If !lRet
			Exit
		EndIf
		nX += (nTam)
	Next nX
	If !lRet
		Exit
	EndIf
Next nI

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³VerifDir   ³ Autor ³Luciana Pires          ³ Data ³ 28.12.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica se o diretorio informado para gravacao existe       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function VerifDir()
Local lRet	:= .T.
		     
If !Empty(MV_PAR10)
	If Left(MV_PAR10,1) <> "\"
		MV_PAR10 := Upper(RTrim(MV_PAR10))+"\"
	Else
		MV_PAR10 := Upper(RTrim(MV_PAR10))  
	EndIf
	If !ExistDir(MV_PAR10)  
		MsgInfo(OemToAnsi(STR0004)) //"O diretorio informado para a gravacao dos arquivo nao existe. E necessario cria-lo para depois seguir com o processamento dos dados."
		lRet := .F.
	Else
		If Right(MV_PAR10,1) <> "\"
			MV_PAR10 += "\"
		EndIf
	EndIf
Else
   	MV_PAR10 := GetSrvProfString("Startpath","")+"\"
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GeraDadCmp   ³Autor ³ Luciana Pires        ³Data³ 22/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera arquivo com os dados referentes aos comprovantes elet.³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraDadCmp(cNota,cSerie,cCliFor,cLoja,dDtaEmis,dDtaCanc,aDArq,cTES)

Local aAreaSF   := {}
Local aAreaSD   := {}
Local aAreaAtu  := GetArea()
Local aReg01	:= {}
Local aReg02	:= {}
Local aLin      := {}        //Array com os dados referentes registro 03
Local aImps     := {}        
Local cStr      := ""
Local cAliasSF  := Iif(cTES > "500","SF2","SF1")     
Local cAliasSD  := Iif(cTES > "500","SD2","SD1")     
LocaL cAliasCF  := "SA1"  
Local cIDAnt	:= "" 
Local cEstado	:= "" 
Local cDescProd	:= ""    
Local cEndereco := ""
Local cNumero	:= ""   
Local cCep 		:= ""
Local cLocal 	:= ""

Local nTotIsen  := 0
Local nTotNAlc  := 0       
Local nI		:= 0 
Local lRECE		:= .F.

//Campos dos arquivos SF?
Local nSFDoc    := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_DOC"))
Local nSFSer    := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_SERIE"))
Local nSFCliFor := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+Iif(cAliasSF == "SF2","_CLIENTE","_FORNECE")))
Local nSFLoja   := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_LOJA"))
Local nSFDtaEmis:= (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_EMISSAO"))
Local nSFDtaDgt := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_DTDIGIT")) 
Local nSFVBrut  := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_VALBRUT"))
Local nSFEsp    := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_ESPECIE")) 
Local nSFCAE   	:= (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_CAE"))    
Local nSFVenCAE := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_VCTOCAE"))    
Local nSFMotivo	:= (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_MOTIVO"))  
Local nSFMoeda  := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_MOEDA"))
Local nSFTxMoeda:= (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_TXMOEDA"))

//Campos dos arquivos SD?
Local nSDDoc    := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_DOC"))
Local nSDSer    := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_SERIE"))
Local nSDCliFor := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+Iif(cAliasSD == "SD2","_CLIENTE","_FORNECE")))
Local nSDLoja   := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_LOJA"))
Local nSDEsp    := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_ESPECIE"))
Local nSDQtde   := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_QUANT"))
Local nSDUm     := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_UM"))
Local nSDPrUnit := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+Iif(cAliasSD == "SD2","_PRCVEN","_VUNIT")))
Local nSDDesc   := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+Iif(cAliasSD == "SD2","_DESCON","_VALDESC")))
Local nSDTotal  := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_TOTAL"))
Local nSDTes    := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_TES"))
Local nSDAliq   := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_PICM"))
Local nSDCod	:= (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_COD"))

// Moeda e Taxa para a factura/nota corrente.
Private nMoedaCor := 0
Private nTaxaMoeda:= 0

//Verifica se o cliente faz parte do regime Nfe
lRECE := PesqCliRECE(cAliasCF)

If lRECE
	//Chama funcao que cria os arrays de impostos...
	CriaArrayImp()
		
	// Caso o campo de Data da digitacao nao exista considera a data de emissao.
	If nSFDtaDgt == 0
		nSFDtaDgt := nSFDtaEmis
	EndIf
	
	dbSelectArea(cAliasSF)
	aAreaSF := GetArea()
	dbSetOrder(1)
	If dbSeek(xFilial(cAliasSF)+cNota+cSerie+cCliFor+cLoja)	

		// Armazena a moeda e a respectiva taxa...
		nMoedaCor  	:= FieldGet(nSFMoeda)
		nTaxaMoeda 	:= FieldGet(nSFTxMoeda)
		cEndereco 	:= Substr(SM0->M0_ENDCOB,At(" ",SM0->M0_ENDCOB)+1,(At(",",SM0->M0_ENDCOB)-At(" ",SM0->M0_ENDCOB))-1)
		cNumero		:= AllTrim(If(Val(Substr(SM0->M0_ENDCOB,At(",",SM0->M0_ENDCOB)+1,Len(AllTrim(SM0->M0_ENDCOB))))==0,Replicate("0",6 ),Substr(SM0->M0_ENDCOB,At(",",SM0->M0_ENDCOB)+1,Len(AllTrim(SM0->M0_ENDCOB))))) 
				
		//Gravo o registro tipo 01
		AAdd(aReg01,"1")
		AAdd(aReg01,SubStr(SM0->M0_CGC,1,11))
		AAdd(aReg01,SubStr(SM0->M0_NOMECOM,1,30))
		AAdd(aReg01,SubStr(cInscIB,1,30))
		AAdd(aReg01,"01")
		AAdd(aReg01,"IVA RESPONSABLE INSCRIPTO")
		AAdd(aReg01,Dtos(dDtIniAt))
		AAdd(aReg01,Alltrim(cEndereco)+Replicate(" ",30-Len(Alltrim(cEndereco))))
		AAdd(aReg01,Replicate("0",6-Len(Alltrim(cNumero)))+Alltrim(cNumero))
		AAdd(aReg01,Space(05))
		AAdd(aReg01,Space(05))
		AAdd(aReg01,Space(05))
		AAdd(aReg01,Space(05))
		AAdd(aReg01,Space(05))
		AAdd(aReg01,PesqCodPv(SM0->M0_ESTCOB))
		AAdd(aReg01,SubStr(SM0->M0_CEPCOB,1,8))
		AAdd(aReg01,SubStr(SM0->M0_BAIRCOB,1,20)+Space(5))
	
		cStr := ""              
		aEval(aReg01,{|x| cStr += x})                
		cStr += Chr(13)+Chr(10)
	
		//Grava linha no arquivo...
		TrabArqTxt(.F.,@aDArq,aDArq[01],aDArq[02],cStr)	
	
		aAreaSD := (cAliasSD)->(GetArea())		
		If cAliasSD == "SD2"
			(cAliasSD)->(dbSetOrder(3))
		Else
			(cAliasSD)->(dbSetOrder(1))
		EndIf
	
		If (cAliasSD)->(dbSeek(xFilial(cAliasSD)+cNota+cSerie+cCliFor+cLoja))
			While !(cAliasSD)->(Eof()) .And.	xFilial(cAliasSD)+(cAliasSD)->(FieldGet(nSDDoc))+(cAliasSD)->(FieldGet(nSDSer))+(cAliasSD)->(FieldGet(nSDCliFor))+(cAliasSD)->(FieldGet(nSDLoja)) == ;
				xFilial(cAliasSD)+FieldGet(nSFDoc)+FieldGet(nSFSer)+FieldGet(nSFCliFor)+FieldGet(nSFLoja)
				
				If AllTrim(FieldGet(nSFEsp)) <> AllTrim((cAliasSD)->(FieldGet(nSDEsp)))
					(cAliasSD)->(dbSkip())
					Loop
				EndIf			
	
				nCpo13 := PesqInfImp(cAliasSD,IVA,"3",(cAliasSD)->(FieldGet(nSDTes)))[1]	//Aliquota de IVA
				IndExGrv(DesTrans(nCpo13,2),@nTotIsen,@nTotNAlc,cAliasSD,.F.)				//Indicacao de Isento ou Gravado
	            
				If SB1->(dbSeek(xFilial("SB1")+(cAliasSD)->(FieldGet(nSDCod))))
	                cDescProd := SubStr(SB1->B1_DESC,1,30)+Space(70)
				Else
					cDescProd := Space(100)
				Endif
				
				AAdd(aLin,{	"3",;															   			//Campo 01 - Tipo de registro			
							cDescProd,;																	//Campo 02 - Descricao
							MontaValor((cAliasSD)->(FieldGet(nSDQtde)),"@E 9999999.99999",12),;		//Campo 03 - Quantidade
							(cAliasSD)->(FieldGet(nSDUm)),;											//Campo 04 - Unidade de Medida
							MontaValor((cAliasSD)->(FieldGet(nSDPrUnit)),"@E 9999999999999.999",16),;	//Campo 05 - Preco Unitario
							MontaValor((cAliasSD)->(FieldGet(nSDDesc)),"@E 9999999999999.99",15),;	//Campo 06 - Valor de Bonificacao 
							Replicate("0",16),;															//Campo 07 - Valor de Ajuste
							MontaValor((cAliasSD)->(FieldGet(nSDTotal)),"@E 9999999999999.999",16),;	//Campo 08 - SubTotal por registro
							MontaValor((cAliasSD)->(FieldGet(nSDAliq)),"@E 99.99",4),;				//Campo 09 - Aliquota de IVA
							MontaValor((cAliasSD)->(FieldGet(nSDTotal)),"@E 9999999999999.999",16),;	//Campo 10 - Subtotal por Aliquota de IVA
							Space(1)})																	//Campo 11 - indicacao de isento, gravado e nao gravado

				//Gera array com o total de cada imposto...
				AAdd(aImps,aClone(aDImps))	
				
				(cAliasSD)->(dbSkip())
			Enddo
		Endif
	
	
		//Gravo o registro tipo 02
		AAdd(aReg02,"2")						   								//Campo 01 - Tipo de Registro
		AAdd(aReg02,"ORIGINAL")													//Campo 02 - Identificador de original
		AAdd(aReg02,Dtos(FieldGet(nSFDtaEmis)))								//Campo 03 - Data do comprovante
		AAdd(aReg02,M991TpComp(cAliasSF,FieldGet(nSFSer),FieldGet(nSFEsp)))	//Campo 04 - Tipo de comprovante
		AAdd(aReg02,Left(Alltrim(cSerie),1))	   								//Campo 05 - Letra do tipo de comprovante A ou B (serie)
		AAdd(aReg02,Substr(cNota,1,4))											//Campo 06 - Ponto de Venda
		AAdd(aReg02,Substr(cNota,5,8))											//Campo 07 - Numero do comprovante
		AAdd(aReg02,Substr(cNota,5,8))											//Campo 08 - Numero do comprovante registrado
		
		cIDAnt := PesqIdCliFor(cAliasCF,"5",FieldGet(nSFVBrut))
		AAdd(aReg02,cIDAnt)					  									//Campo 09 - Cod documento identif. do comprador
		AAdd(aReg02,PesqIdCliFor(cAliasCF,"2",FieldGet(nSFVBrut),cIDAnt))		//Campo 10 - Numero de identificacao do comprador
		AAdd(aReg02,PesqIdCliFor(cAliasCF,"4",FieldGet(nSFVBrut)))				//Campo 11 - Nome e sobrenome do comprador ou denominacao do comprador
		AAdd(aReg02,PesqIdCliFor(cAliasCF,"3"))									//Campo 12 - Tipo de responsavel

		cEndereco 	:= PesqIdCliFor(cAliasCF,"6",0,"",.F.)
		cNumero		:= PesqIdCliFor(cAliasCF,"6",0,"",.T.)
		AAdd(aReg02,Alltrim(cEndereco)+Replicate(" ",30-Len(Alltrim(cEndereco))))	//Campo 13 - endereco comprador
		AAdd(aReg02,Replicate("0",6-Len(Alltrim(cNumero)))+Alltrim(cNumero))		//Campo 14 - numero endereco do comprador 
		AAdd(aReg02,Space(05))													//Campo 15 - Piso do domicilio do comprador
		AAdd(aReg02,Space(05))													//Campo 16 - Depto do domicilio do comprador
		AAdd(aReg02,Space(05))													//Campo 17 - Setor do domicilio do comprador
		AAdd(aReg02,Space(05))													//Campo 18 - Torre do domicilio do comprador
		AAdd(aReg02,Space(05))													//Campo 19 - Manzana do domicilio do comprador
	
		cEstado := PesqIdCliFor(cAliasCF,"7")	
		cCep 	:= PesqIdCliFor(cAliasCF,"8")
		cLocal 	:= PesqIdCliFor(cAliasCF,"9")
		AAdd(aReg02,PesqCodPv(cEstado))											//Campo 20 - Provincia do domicilio do comprador
		AAdd(aReg02,Replicate("0",8-Len(Alltrim(cCep)))+Alltrim(cCep))		//Campo 21 - CEP do domicilio do comprador
		AAdd(aReg02,Alltrim(cLocal)+Replicate(" ",25-Len(Alltrim(cLocal))))	//Campo 22 - Localidade do domicilio do comprador
		AAdd(aReg02,MontaValor(FieldGet(nSFVBrut),"@E 9999999999999.99",15))	//Campo 23 - Importe total de la operacion
		AAdd(aReg02,MontaValor(nTotNAlc,"@E 9999999999999.99",15))				//Campo 24 - Valor total que nao teve incidencia de IVA
		AAdd(aReg02,MontaValor(TotCat(IVA,"1",aImps,"2"),"@E 9999999999999.99",15))	//Campo 25 - Importe neto gravado
		AAdd(aReg02,MontaValor(TotCat(IVA,"2",aImps,"2"),"@E 9999999999999.99",15)) 	//Campo 26 - Imposto Liquidado
		AAdd(aReg02,MontaValor(TotCat(RNI,"2",aImps,"2"),"@E 9999999999999.99",15))	//Campo 27 - Imposto Liquidado a RNI
		AAdd(aReg02,MontaValor(nTotIsen,"@E 9999999999999.99",15))						//Campo 28 - Importe de operacoes Isentas
		AAdd(aReg02,MontaValor(TotCat(PIN,"2",aImps,"2"),"@E 9999999999999.99",15))	//Campo 29 - Importe de percepciones ou pagos a conta sobre impostos nacionais
		AAdd(aReg02,MontaValor(TotCat(PIB,"2",aImps,"2"),"@E 9999999999999.99",15))	//Campo 30 - Importe de percepciones de ingresos brutos
		AAdd(aReg02,MontaValor(TotCat(PIM,"2",aImps,"2"),"@E 9999999999999.99",15))	//Campo 31 - Importe de percepciones de impostos municipais
		AAdd(aReg02,MontaValor(TotCat(PII,"2",aImps,"2"),"@E 9999999999999.99",15))	//Campo 32 - Importe de impostos internos
		AAdd(aReg02,"000")														//Campo 33 - Codigo da moeda ( *** NAO INFORMAR *** )
		AAdd(aReg02,"0000000000")												//Campo 34 - Tipo de cambio ( *** NAO INFORMAR *** )
		AAdd(aReg02,"0") 														//Campo 35 - Quantidade de aliquotas de IVA ( *** NAO INFORMAR *** )
		AAdd(aReg02," ")														//Campo 36 - Codigo da operacao ( *** NAO INFORMAR *** )
		AAdd(aReg02,Substr(FieldGet(nSFCAE),1,14))								//Campo 37 - CAE ( *** COMPLETAR COM ZEROS *** )
		AAdd(aReg02,Dtos(FieldGet(nSFVenCAE)))									//Campo 38 - Data de vencimento ( *** COMPLETAR COM ZEROS *** )
		AAdd(aReg02,Substr(FieldGet(nSFMotivo),1,8))							//Campo 39 - Data de Anulacao do comprovante ( *** COMPLETAR COM ZEROS *** )
	
		//Limpa o array que possui o total dos impostos...
		aImps := {}
		
		cStr := ""              
		aEval(aReg02,{|x| cStr += x})                
		cStr += Chr(13)+Chr(10)
	
		//Grava linha no arquivo...
		TrabArqTxt(.F.,@aDArq,aDArq[01],aDArq[02],cStr)	
	
		//Gera Linha que sera gravada no arquivo de itens... 
		For nI := 1 To Len(aLin)
			cStr := ""              
			aEval(aLin[nI],{|x| cStr += x})                
			cStr += Chr(13)+Chr(10)
			
			//Grava linha no arquivo no arquivo de itens...
			TrabArqTxt(.F.,@aDArq,aDArq[01],aDArq[02],cStr)	
	    Next nI           
	                 
		//Restaura a area original do arquivo SD?...
		RestArea(aAreaSD)
	EndIf 
	RestArea(aAreaSF)            
Endif
	
//Retorna as areas originais...
RestArea(aAreaAtu)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TrabArqTxt   ³Autor ³ Luciana Pires        ³Data³ 22/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que realiza as principais acoes com os arquivos .TXT³±±  
±±³          ³ (Criacao, inclusao de linhas e fechamento do arquivo)      ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TrabArqTxt(lFecha,aDArq,cNomeArq,nHdl,cStr) 
Local lRet 	:= .T.

Default lFecha 	:= .F.
Default aDArq	:= Array(2)
Default cNomeArq:= ""
Default nHdl	:= 0
Default cStr 	:= ""

If !lFecha
	If nHdl == 0
		//Cria e abre o arquivo de cabecalho
		nHdl := FOpen(MV_PAR10+cNomeArq,2+64)
		If nHdl == -1
			nHdl := MsFCreate(MV_PAR10+cNomeArq)
			If nHdl == -1
				MsgAlert(STR0005+cNomeArq) //"Nao foi possivel criar o arquivo "
				lRet := .F.
			Else
				aDArq[02] := nHdl
			EndIf
		Else
			aDArq[02] := nHdl
			If MsgYesNo(STR0006+cNomeArq+STR0007) //"O arquivo "###" ja existe. Deseja continuar o processo e criar um novo arquivo?"
				FClose(nHdl)
				nHdl :=FErase(MV_PAR10+cNomeArq)
				If nHdl == -1
					MsgAlert(STR0008+cNomeArq) //"Nao foi possivel excluir o arquivo "
					lRet := .F.
				Else
					nHdl := MsFCreate(MV_PAR10+cNomeArq)
					If nHdl == -1
						MsgAlert(STR0005+cNomeArq) //"Nao foi possivel criar o arquivo "
						lRet := .F.
					Else
						aDArq[02] := nHdl
					EndIf
				EndIf
			Else                    
				//Caso o usuario escolhar abortar a rotina o arquivo
				//aberto deve ser fechado...
				If aDArq[02] <> Nil .And. aDArq[02] <> 0
					nHdl := aDArq[02]
					FClose(nHdl)
				EndIf
				lRet := .F.
			EndIf
		EndIf
	Else        
		FWrite(nHdl,cStr)
	EndIf
Else 
	FClose(nHdl)                
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CriaArqTxt   ³Autor ³ Luciana Pires        ³Data³ 22/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria o array aDarq, que possue todas as informacoes dos    ³±±  
±±³          ³ arquivos .TXT e executa a funcao responsavel pela criacao  ³±±  
±±³          ³ ou abertura dos mesmos.                                    ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CriaArqTxt(aDArq,nFatArq)

Default aDarq 	:= Array(2)
Default nFatArq := 0

//Verifico se esta sendo informado o nome com .txt
If Substr(cNomeA,len(cNomeA)-3,len(cNomeA)) == ".txt"
	cNomeA := Substr(cNomeA,1,len(cNomeA)-4)
Endif

//Arquivo de Facturas - Comprobantes Electronicos
aDArq[01] := cNomeA+"_"+StrZero(nFatArq,5)+".txt"
aDArq[02] := 0 

//Manipula arquivos .TXT
lRet := TrabArqTxt(.F.,@aDArq,aDArq[01],aDArq[02],"")

Return(lRet) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CriaArrayImp ³Autor ³ Luciana Pires        ³Data³ 22/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria o array que ira armazenar as informacoes dos impostos ³±±  
±±³          ³ conforme a sua categoria (IVA, RNI, PIB).                  ³±±                      	
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CriaArrayImp()

//Sempre que valorizar o array aDImps eh necessario seguir a configuracao
//dos defines criados (IVA,RNI,PIB). Caso seja necessario aumente o numero
//de Defines.

//Dados referentes a categoria IVA
aDImps[IVA][1] := IVA
aDImps[IVA][2] := AllTrim(MV_PAR11) 
aDImps[IVA][3] := {}

//Dados referentes a categoria RNI (Responsable no Inscripto)
aDImps[RNI][1] := RNI
aDImps[RNI][2] := AllTrim(MV_PAR12) 
aDImps[RNI][3] := {}
                                  
//Dados referentes a categoria PIB (Percepcion de Ingreso Bruto)
aDImps[PIB][1] := PIB
aDImps[PIB][2] := AllTrim(MV_PAR13) 
aDImps[PIB][3] := {} 

//Dados referentes a categoria PIN (Percepcion de Impuestos Nacionales)
aDImps[PIN][1] := PIN
aDImps[PIN][2] := AllTrim(MV_PAR14) 
aDImps[PIN][3] := {}
                     
//Dados referentes a categoria PIM (Percepcion de Impuestos Municipales)
aDImps[PIM][1] := PIM
aDImps[PIM][2] := AllTrim(MV_PAR15) 
aDImps[PIM][3] := {}

//Dados referentes a categoria PII (Percepcion de Impuestos Internos)
aDImps[PII][1] := PII
aDImps[PII][2] := AllTrim(MV_PAR16) 
aDImps[PII][3] := {} 

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PesqCodPv    ³Autor ³ Luciana Pires        ³Data³ 28/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o codigo da provincia do domicilio                 ³±±  
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PesqCodPv(cProvin)
Local cCodProv   := ""

Default cProvin := ""

If !Empty(cProvin)
	Do Case
		Case cProvin == "CF" 	//CAPITAL FEDERAL
			cCodProv := "00"
		Case cProvin == "BA" 	//BUENOS AIRES
			cCodProv := "01"      
		Case cProvin == "CA" 	//CATAMARCA
			cCodProv := "02"
		Case cProvin == "CO"	//CORDOBA
			cCodProv := "03"
		Case cProvin == "CR"	//CORRIENTES
			cCodProv := "04"
		Case cProvin == "ER" 	//ENTRE RIOS
			cCodProv := "05"
		Case cProvin == "JU" 	//JUJUY
			cCodProv := "06"
		Case cProvin == "ME" 	//MENDONZA
			cCodProv := "07"
		Case cProvin == "LR" 	//LA RIOJA
			cCodProv := "08"
		Case cProvin == "SA" 	//SALTA
			cCodProv := "09"
		Case cProvin == "SJ" 	//SAN JUAN
			cCodProv := "10"
		Case cProvin == "SL" 	//SAN LUIS
			cCodProv := "11"
		Case cProvin == "SF" 	//SANTA FE
			cCodProv := "12"
		Case cProvin == "SE"	//SANTIAGO DEL ESTERO
			cCodProv := "13"
		Case cProvin == "TU" 	//TUCUMAN
			cCodProv := "14"
		Case cProvin == "CH" 	//CHACO
			cCodProv := "16"
		Case cProvin == "CB" 	//CHUBUT
			cCodProv := "17"
		Case cProvin == "FO" 	//FORMOSA
			cCodProv := "18"
		Case cProvin == "MI" 	//MISIONES
			cCodProv := "19"
		Case cProvin == "NE" 	//NEUQUEN
			cCodProv := "20"
		Case cProvin == "LP" 	//LA PAMPA
			cCodProv := "21"
		Case cProvin == "RN"	//RIO NEGRO
			cCodProv := "22"
		Case cProvin == "SC"	//SANTA CRUZ
			cCodProv := "23"
		Case cProvin == "TF"	//TIERRA DEL FUEGO 
			cCodProv := "24"
	EndCase	
Else
	cCodProv := Space(02)
EndIf

Return(cCodProv)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PesqCliRECE  ³Autor ³ Luciana Pires        ³Data³ 04/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna se o cliente faz parte do regime de Nota Fiscal    ³±± 
±±³          ³ eletronica, a partir do campo A1_RECE                      ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PesqCliRECE(cAlias)
Local aAreaSA  	:= {} 
Local aAreaAtu 	:= GetArea()
Local cCpoRECE 	:= ""
Local cCliRECE	:= ""
Local lRECE 	:= .F.
Local cTmpAlias := ""

If cAlias == "SA1" .And. cPaisLoc == "ARG"
	cTmpAlias := "AI0"
	dbSelectArea(cTmpAlias)
	aAreaSA := GetArea()
	dbSetOrder(RetOrdem("AI0_FILIAL+AI0_CODCLI+AI0_LOJA")) //AI0_FILIAL+AI0_CODCLI+AI0_LOJA
	If dbSeek(xFilial(cTmpAlias)+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA)
		cCpoRECE := cTmpAlias+"_RECE"
	   	cCliRECE := (cTmpAlias)->&cCpoRECE                 
	Endif
	RestArea(aAreaSA)
Else
	dbSelectArea(cAlias)
	aAreaSA := GetArea()
	dbSetOrder(1)
	If dbSeek(xFilial(cAlias)+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA)
		cCpoRECE := SubStr(cAlias,2,2)+"_RECE"
	   	cCliRECE := (cAlias)->&cCpoRECE                 
	Endif	
	RestArea(aAreaSA)	
EndIf

lRECE := Iif(Alltrim(cCliRECE) == "S",.T.,.F.) 

//Restauro as areas
RestArea(aAreaAtu)
	
Return(lRECE)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MontaValor   ³Autor ³ Luciana Pires        ³Data³ 05/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Converte o valor passado para a string que sera gravada    ³±± 
±±³          ³ no arquivo texto.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaValor(nValor,cPicture,nTam,lConverte)

Local cValAux := ""
Local nPos    := 0

Default lConverte := .T.

// Verifica se eh necessario realizar a conversao do valor
If lConverte .And. (nMoedaCor <> 1) .And. (nTam >= 15) .And. (nValor <> 0)
	nValor := Round(xMoeda(nValor,nMoedaCor,1,dDtaDgt,nDecimais+1,nTaxaMoeda),nDecimais)
EndIf

cValAux  := Transform(nValor,cPicture)
nPos     := At(",",cValAux)
If nPos > 0
	cValAux  := SubStr(cValAux,1,nPos-1)+SubStr(cValAux,nPos+1,Len(cValAux))
	cValAux  := Replicate("0",nTam-Len(AllTrim(cValAux)))+AllTrim(cValAux)
Else
	cValAux  := Replicate("0",nTam-Len(AllTrim(cValAux)))+AllTrim(cValAux)
EndIf

Return(cValAux)
