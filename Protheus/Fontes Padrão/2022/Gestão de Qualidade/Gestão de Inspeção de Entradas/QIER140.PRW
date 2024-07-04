
#INCLUDE "QIER140.CH"
#INCLUDE "PROTHEUS.CH"
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    Ё QIER140  Ё Autor Ё Cleber Souza          Ё Data Ё 23.09.03 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Indice Gerais de Fornecimento                              Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё QIER140(void)                                              Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё SIGAQIE                                                    Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё			ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.			  Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data	Ё BOPS Ё  Motivo da Alteracao 					  Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            Ё        Ё      Ё                                          Ё╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function QIER140()
Local wnrel
Local cDesc1		:= STR0001	//"Serao impressos os Indices Gerais de Fornecimento"
Local cDesc2		:= ""
Local cDesc3		:= ""
Local cString		:= "QEV"
Local cTitulo		:= STR0002	//"Indices Gerais de Fornecimento"

Private	cTamanho	:= "M"
Private	cPerg		:= "QER140"
Private	aReturn	    := { STR0003, 1,STR0004,1,2,1,"",1}		//"Zebrado"###"Administracao"
Private	cNomeprog   := "QIER140"
Private nLastKey    := 0
Private nRec        := 0

Private aNC		    :={}
Private aNaoConf    :={}

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis utilizadas para parametros                         Ё
//Ё mv_par01             // Ano                                  Ё
//Ё mv_par02             // M┬s                                  Ё
//Ё mv_par03             // Indice p/ Classif. atual Prod/Forn.  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica as perguntas selecionadas                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
pergunte(cPerg,.F.)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis utilizadas para Impressao do Cabecalho e Rodape    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
wnrel := "QIER140"

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Envia controle para a funcao SETPRINT                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
wnrel := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,cTamanho,,.F.)

If nLastKey == 27
	Set Filter To
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter To
	Return
Endif

RptStatus({|lEnd| R140Imp(@lEnd,wnrel,cString,cTitulo)},cTitulo)

Return

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    Ё R140IMP  Ё Autor Ё Cleber Souza          Ё Data Ё 23/09/03 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Chamada do Relatorio                                       Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё QIER140                                                    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function R140Imp(lEnd,wnrel,cString,cTitulo)

Local aMeses       := {STR0005,STR0006,STR0007,STR0008,STR0009,STR0010,STR0011,STR0012,STR0013,STR0014,STR0015,STR0016 }	//"JANEIRO"###"FEVEREIRO"###"MARCO"###"ABRIL"###"MAIO"###"JUNHO"###"JULHO"###"AGOSTO"###"SETEMBRO"###"OUTUBRO"###"NOVEMBRO"###"DEZEMBRO"
Local aClaIQI      := {}
Local aClaIQS      := {}
Local aEstatistica := {} 
Local cIndice      := ""
Local cQassIqs     := GetMv("MV_QASSIQS") 
Local cSitu        := ""
Local nY           := 0   
Local nC           := 0  
Local nX           := 0  
Local cAval        := ""
Local nPos         := 0
Local nPosI        := 0
Local cDbMs        := ""   
Local aForEnt      := {}
Local aForEnt2     := {}
Local aForEnt3     := {}
Local aProEnt      := {}
Local aNotFor      := {}
Local aNotPro      := {} 
Local nDias        := 0
Local cTitProd     := TitSx3("QEK_PRODUT")[1]  
Local nTipo		   := GetMV("MV_COMP")
Local Cabec1	   :=""
Local Cabec2	   :=""
Local lImp		   := .F. 
Local cLaud		   :=""
Local lRoda		   := .F.
Local lImpCab      := .f.   
Local cDesc        := "" 
Local cStrUsado    := ""
Local nCbCont	   := 00 
Local cProdut	   := ""   
Local nCt          := 0
Local cQEIQSNA := SuperGetMv("MV_QEIQSNA")


cDbMs := Alltrim(TcGetDb())
	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁMonta array com as classificaГУes do Produto e Fornecedor Quadro01Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea("QEG")
dbSetOrder(1)
dbSeek(xFilial("QEG"))
While QEG->(!EOF()) .and. QEG->QEG_FILIAL == xFilial("QEG")
	AADD(aClaIQI,{QEG_SITU,QEG_NIVEL,0,0})     
	QEG->(dbSkip())
EndDo

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁMonta array com as Estatisticas 									 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
AADD(aEstatistica,{STR0024,0})  //(01)"| Numero total de Entradas no periodo"
AADD(aEstatistica,{STR0025,0})	//(02)"| Entregas com laudo"
AADD(aEstatistica,{STR0026,0})	//(03)"| Entregas sem laudo"
AADD(aEstatistica,{STR0027,0})	//(04)"| Entregas em Skip-Lote"
AADD(aEstatistica,{STR0028,0})	//(05)"| Entregas em Permuta"
AADD(aEstatistica,{STR0048,0})	//(06)"| Entregas com Liberacao Urgente"
AADD(aEstatistica,{STR0029,0})	//(07)"| Notificacoes nao-conformidade emitidas"
AADD(aEstatistica,{STR0030,0})	//(08)"| Fornecedores notificados"
AADD(aEstatistica,{STR0031,0})	//(09)"| Produtos notificados"
AADD(aEstatistica,{STR0032,0})	//(10)"| Fornecedores com entregas no periodo"
AADD(aEstatistica,{STR0033,0})	//(11)"| Produtos entregues no periodo"
AADD(aEstatistica,{STR0034,0})	//(12)"| Lead Time maximo em transito"
AADD(aEstatistica,{STR0035,0})	//(13)"| Lead Time maximo em laboratorio"
AADD(aEstatistica,{STR0036,0})	//(14)"| Lead Time maximo com Laudo"
AADD(aEstatistica,{STR0037,0})	//(15)"| Numero total de fornecedores"
AADD(aEstatistica,{STR0038,0})	//(16)"| Numero total de produtos"  
     
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Verifica se possui indice de qualidade gerado.                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea("QEV")
dbSetOrder(1)
If !dbSeek(xFilial("QEV")+Str(mv_par01,4)+StrZero(mv_par02,2))
	Set Device To Screen
	Help(" ",1,"R140NAOIQU")
	Return
EndIF	

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Gera Arquivo de trabalho principal atravИs da tabela QEK.          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Q140TRB01() 

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Gera Arquivo de trabalho principal atravИs da tabela QEV.          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Q140TRB02() 

TRB02->(dbGoTop())
While TRB02->(!EOF())
    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Qualificacao de Fornecedores e Produtos (IQI - A)            Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    
	If mv_par03==1
		If TRB02->IQIA <> 999.99  
			dbSelectArea("QEG")
			dbSetOrder(2)
			QEG->(dbSeek(xFilial("QEG")+AllTrim(str(TRB02->IQIA,6,2)),.T.)) // cIndice, depende de mv_par03 IQI acumulado ou nфo...
			
			If QEG->QEG_CATEG == "1" .And. TRB02->IQS == 0 .And. cQassIqs == "N"
				dbSetOrder(1)
				dbSeek(xFilial("QEG"))
				While !Eof() .And. QEG_FILIAL == xFilial("QEG")
					If QEG_CATEG > "1"
						cSitu := QEG_SITU
						Exit 
					EndIf
					dbSkip()
				EndDo
			Else
				cSitu := QEG->QEG_SITU	
		EndIF
		Else
			cSitu := "N/A" 
		EndIf
    Else
		If TRB02->IQFA <> 999.99 
			dbSelectArea("QEG")
			dbSetOrder(2)
			QEG->(dbSeek(xFilial("QEG")+AllTrim(str(TRB02->IQFA,6,2)),.T.))  // cIndice, depende de mv_par03 IQI acumulado ou nфo...
			
			If QEG->QEG_CATEG == "1" .And. TRB02->IQS == 0 .And. cQassIqs == "N"
				dbSetOrder(1)
				dbSeek(xFilial("QEG"))
				While !Eof() .And. QEG_FILIAL == xFilial("QEG")
					If QEG_CATEG > "1"
						cSitu := QEG_SITU
						Exit
					EndIf
					dbSkip()
				EndDo
			Else
				cSitu := QEG->QEG_SITU	
		EndIF
		Else
			cSitu := "N/A" 
		EndIf
	Endif

    //Verifica se SituaГЦo N/A existe na array
    If cSitu == "N/A" 
        nPos := AsCan(aClaIQI,{|x| x[1] == "N/A" })
		If nPos == 0
			AADD(aClaIQI,{"N/A","N/A",0,0})     
	    EndIF
	EndIF    

  	nPosI := aScan(aClaIQI,{|x| x[1] == cSitu })
		
	nPos := AsCan(aForEnt,{|x| x[1] == TRB02->FORNEC})
	If nPos == 0
		If nPosI <> 0 
			aClaIQI[nPosI,3] += 1
  			Aadd(aForEnt,{TRB02->FORNEC,0})
		EndIF
  	EndIf
  
	nPos := AsCan(aProEnt,{|x| x[1] == TRB02->PRODUT+Alltrim(cSitu)})
	If nPos == 0
		If nPosI <> 0 
			aClaIQI[nPosI,4] += 1
			Aadd(aProEnt,{TRB02->PRODUT+Alltrim(cSitu),0})
  		EndIF
	EndIf
    
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Qualificacao de Fornecedores (IQS)                           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If TRB02->IQS == 999.99
		cAval :=  "N/A"
	    cDesc :=  "N/A"
	Else
		DbSelectArea("QA8")
		DbSetOrder(2)
		If DbSeek(xFilial("QA8")+Str(TRB02->IQS,6,2),.T.)
		    cAval := Alltrim(Upper(QA8->QA8_AVALIA))
		    cDesc := QA8->QA8_DESCPO
		Else 
		    cAval := "N/A"
		    cDesc := "N/A"
		EndIF
	EndIf	   
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁNumero total de fornecedores por periodo                      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nPosI := aScan(aClaIQS,{|x| x[1] == cAval })
	
	nPos := AsCan(aForEnt3,{|x| x[1] == TRB02->FORNEC+Alltrim(cAval) })
	If nPos == 0
		If nPosI==0	 
			AADD(aClaIQS,{cAval,1,cDesc})
		Else
			aClaIQS[nPosI,2] += 1
   		EndIF
   		Aadd(aForEnt3,{TRB02->FORNEC+Alltrim(cAval),0})
	EndIf
    
	TRB02->(dbSkip())
EndDo   

aForEnt := {}
aProEnt := {}

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁNumero total de fornecedores                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !Empty(cDbMs) .and. cDbMs <> "POSTGRES" .AND. TcSrvType() != "AS/400"

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁNumero total de Fornecedores                                  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cQuery := "SELECT "
		cQuery += " COUNT(*) TOTFOR "
	cQuery += "FROM "
		cQuery += " " + RetSQLName("SA2") + " SA2 "
	cQuery += "WHERE "
		cQuery += " SA2.A2_FILIAL  = '" + xFilial("SA2")	+"'and"
		cQuery += " SA2.D_E_L_E_T_ <> '*' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB04",.T.,.T.)
	aEstatistica[15,2] := TRB04->TOTFOR
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁNumero total de Produtos                                      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cQuery := "SELECT "
		cQuery += " COUNT(DISTINCT QE6_PRODUT) TOTPROD "
	cQuery += "FROM "
		cQuery += " " + RetSQLName("QE6") + " QE6 "
	cQuery += "WHERE "
		cQuery += " QE6.QE6_FILIAL  = '" + xFilial("QE6")	+"'and"
		cQuery += " QE6.D_E_L_E_T_ <> '*' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB05",.T.,.T.)
	aEstatistica[16,2]  := TRB05->TOTPROD
	
	TRB04->(dbCloseArea())
	TRB05->(dbCloseArea())
Else
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁNumero total de Fornecedores                                  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("SA2")
	dbSeek(xFilial("SA2"))
	While !Eof() .And. xFilial("SA2") == A2_FILIAL
		aEstatistica[15,2] += 1
		dbSkip()
	EndDo

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁNumero total de Produtos                                      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("QE6")
	dbSeek(xFilial("QE6"))
	While !Eof() .And. xFilial("QE6")  == QE6_FILIAL
		If cProdut != QE6_PRODUT
			aEstatistica[16,2] += 1
			cProdut := QE6_PRODUT
		EndIf
		dbSkip()
	EndDo	
EndIF 

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Gera Arquivo de trabalho atravИs da tabela QER.			         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
TRB01->(dbGoTop())
While TRB01->(!EOF()) 

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁNumero total de entregas no Periodo                           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aEstatistica[1,2] += 1 

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁNumero total de fornecedores por periodo                      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nPos := AsCan(aForEnt,{|x| x[1] == TRB01->QEK_FORNEC })
	If nPos == 0
		aEstatistica[10,2]+=1
		Aadd(aForEnt,{TRB01->QEK_FORNEC,aEstatistica[10,2]})
	EndIf

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁNumero total de produtos por periodo                          Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nPos := aScan(aProEnt,{|x| x[1] == TRB01->QEK_PRODUT })
	If nPos == 0
		aEstatistica[11,2]+=1
		Aadd(aProEnt,{TRB01->QEK_PRODUT,aEstatistica[11,2]})
	EndIf
	
 	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁEntregas com Laudo (Liberacao Urgente nao eh considerada aqui) Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If TRB01->QEK_VERIFI != 2 .And. !Empty(TRB01->QEL_LAUDO) .And. !QIEXLdLU(TRB01->QEL_LAUDO)
		aEstatistica[2,2]+=1
	EndIf

	//зддддддддддддддддддддддддддддддддддддддддд©
	//ЁEntregas com Laudo de Liberacao Urgente  Ё
	//юддддддддддддддддддддддддддддддддддддддддды
	If !Empty(TRB01->QEL_LAUDO) .And. QIEXLdLU(TRB01->QEL_LAUDO)
		aEstatistica[6,2]+=1
	EndIf

	//зддддддддддддддддддд©
	//ЁEntregas sem Laudo Ё
	//юддддддддддддддддддды
	If TRB01->QEK_VERIFI !=2 .And. Empty(TRB01->QEL_LAUDO)
		aEstatistica[3,2]+=1
	EndIf

	//здддддддддддддддддддддд©
	//ЁEntregas em Skip-Lote Ё
	//юдддддддддддддддддддддды
	If TRB01->QEK_VERIFI == 2
		aEstatistica[4,2]+=1
	EndIf                      
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁEntregas em Permuta                                           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If TRB01->A5_FABREV == "P"
		aEstatistica[5,2]+=1
	EndIf

	If !Empty(TRB01->QEK_NNC)
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁNotificacoes nao-conformidade                                 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aEstatistica[7,2]+=1

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Total de Fornecedores Notificados                            Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		nPos := Ascan(aNotFor,{|x| x[1] == TRB01->QEK_FORNEC })
		If nPos == 0
			aEstatistica[8,2]+=1
			Aadd(aNotFor,{TRB01->QEK_FORNEC,aEstatistica[7,2]})
		EndIf

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Total de Produtos Notificados                                Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		nPos := Ascan(aNotPro,{|x| x[1] == TRB01->QEK_PRODUT })
		If nPos == 0
			aEstatistica[9,2]+=1
			Aadd(aNotPro,{TRB01->QEK_PRODUT,aEstatistica[9,2]})
		EndIf
	EnDif

	// Localiza o Laudo final da entrega
	If 	TRB01->QEK_SITENT > "1"
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Calculo do Lead-Time - em Laborat╒rio                        Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Empty(TRB01->QEL_LAUDO) .And. !Empty(TRB01->QEL_DTENLA)
			nDias:= DiaUtil(TRB01->QEL_DTENLA,dDataBase) + 1
			If nDias > aEstatistica[13,2]
				aEstatistica[13,2] := nDias
			EndIf
		EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Calculo do Lead-Time - com Laudo                             Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If !Empty(TRB01->QEL_DTENLA) .And. !Empty(TRB01->QEL_LAUDO)
			nDias := DiaUtil(TRB01->QEL_DTENLA,TRB01->QEL_DTLAUD) + 1
			If nDias > aEstatistica[14,2]
				aEstatistica[14,2] := nDias
			EndIf
		EndIf
		//здддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Calculo das Nao Conformidades - 4o. quadro Ё
		//юдддддддддддддддддддддддддддддддддддддддддддды
  		Q140TRB03(	TRB01->QEK_PRODUT,TRB01->QEK_REVI,TRB01->QEK_FORNEC,TRB01->QEK_LOJFOR,TRB01->QEK_DTENTR,;
	 					TRB01->QEK_LOTE,TRB01->QEL_LAUDO,TRB01->QEK_LOTINV,TRB01->QEK_ENTINV,TRB01->QEK_NNC,TRB01->QEK_TAMLOT)

	Else
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Calculo do Lead-Time - Transito                              Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		nDias:= DiaUtil(TRB01->QEK_DTENTR,dDataBase) + 1
		If nDias > aEstatistica[12,2]
			aEstatistica[12,2] := nDias
		Endif
	EndIf

	TRB01->(dbSkip())
EndDo 

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁImpressao do 1o. Quadro : QUALIFICACAO DE FORNECEDORES        Ё
//Ё                          E PRODUTOS (IQI-A/IQF-A)            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды 
Cabec1 :=STR0017+aMeses[mv_par02] +  " / " + Str(mv_par01,4)		//"Periodo :"
li     := 80
m_pag  := 1
cCbtxt := SPACE(10)
If Li > 60
	Cabec(cTitulo,Cabec1,Cabec2,cNomeProg,cTamanho,nTipo) 
	Li := 8
EndIf

@Li,00 PSAY STR0018+" ("+;	//"Qualificacao de Fornecedores e Produtos"
		If(mv_par03==1,AllTrim(TitSX3("QEV_IQI")[1]),AllTrim(TitSX3("QEV_IQF")[1]))+ "-A)"
Li+=2
@Li,00 PSAY Replicate("-",75)
Li++
@Li,00 PSAY STR0019+Pad(Subs(cTitProd,1,21),21," ")+"|" 	//"| Classificacao               | Fornecedores        | Produtos            |"

Li++
@Li,00 PSAY "|"+Replicate("-",73)+"|"
Li++

For nY:=1 to Len(aClaIQI)
	@Li,00 PSAY "|"+aClaIQI[nY,2]
	@Li,30 PSAY "| " + AllTrim(Str(aClaIQI[nY,3])) 
	@Li,52 PSAY "| " + AllTrim(Str(aClaIQI[nY,4]))
	@Li,74 PSAY "|"
	Li++
Next nY
@Li,00 PSAY Replicate("-",75)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁImpressao do 2o. Quadro : QUALIFICACAO DE FORNECEDORES (IQS)  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Li+=2
@Li,00 PSAY STR0020	//"Qualificacao de Fornecedores (IQS)"
Li+=2
@Li,00 PSAY Replicate("-",75)
Li++
@Li,00 PSAY STR0021	//"| Classificacao               | Fornecedores                              |"
Li++
@Li,00 PSAY "|"+Replicate("-",73)+"|"
Li++

For nY:=1 to Len(aClaIQS)

	@Li,00 PSAY "|"+aClaIQS[nY,3]
	@Li,30 PSAY "| "+If(!Empty(aClaIQS[nY,2]),Alltrim(Str(aClaIQS[nY,2])),"0")
	@Li,74 PSAY "|"
	Li++

Next nY

@Li,00 PSAY Replicate("-",75)
Li++

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁImpressфo do 3o. Quadro : ESTATISTICAS                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
@Li,00 PSAY STR0022	//"Estatisticas"
Li+=2
@Li,00 PSAY Replicate("-",75)
Li++

@Li,00 PSAY STR0023	//"| Topico                                 |   Numero    |   % Sobre Total  |"
Li++
@Li,00 PSAY "|"+Replicate("-",73)+"|"
Li++
@Li,00 PSAY STR0024	//"| Numero total de entregas no periodo"
@Li,41 PSAY "| "+ AllTrim(Str(aEstatistica[1,2]))
@Li,55 PSAY "|       100.00"
@Li,74 PSAY "|"
Li++
@Li,00 PSAY STR0025	//"| Entregas com laudo"
@Li,41 PSAY "| "+AllTrim(Str(aEstatistica[2,2]))
@Li,55 PSAY "|       "+Str((aEstatistica[2,2]/aEstatistica[1,2])*100,6,2)
@Li,74 PSAY "|"
Li++
@Li,00 PSAY STR0026	//"| Entregas sem laudo"
@Li,41 PSAY "| "+AllTrim(Str(aEstatistica[3,2]))
@Li,55 PSAY "|       "+Str((aEstatistica[3,2]/aEstatistica[1,2])*100,6,2)
@Li,74 PSAY "|"
Li++
@Li,00 PSAY STR0027	//"| Entregas em Skip-Lote"
@Li,41 PSAY "| "+AllTrim(Str(aEstatistica[4,2]))
@Li,55 PSAY "|       "+Str((aEstatistica[4,2]/aEstatistica[1,2])*100,6,2)
@Li,74 PSAY "|"
Li++
@Li,00 PSAY STR0028	//"| Entregas em Permuta"
@Li,41 PSAY "| "+AllTrim(Str(aEstatistica[5,2]))
@Li,55 PSAY "|       "+Str((aEstatistica[5,2]/aEstatistica[1,2])*100,6,2)
@Li,74 PSAY "|"
Li++
@Li,00 PSAY STR0048	//"| Entregas com Liberacao Urgente"
@Li,41 PSAY "| "+AllTrim(Str(aEstatistica[6,2]))
@Li,55 PSAY "|       "+Str((aEstatistica[6,2]/aEstatistica[1,2])*100,6,2)
@Li,74 PSAY "|"
Li++
@Li,00 PSAY STR0029	//"| Notificacoes nao-conformidade emitidas"
@Li,41 PSAY "| "+AllTrim(Str(aEstatistica[7,2]))
@Li,55 PSAY "|       "+Str((aEstatistica[7,2]/aEstatistica[1,2])*100,6,2)
@Li,74 PSAY "|"
Li++
@Li,00 PSAY STR0030	//"| Fornecedores notificados"
@Li,41 PSAY "| "+AllTrim(Str(aEstatistica[8,2]))
@Li,55 PSAY "|       "+Str((aEstatistica[8,2]/aEstatistica[10,2])*100,6,2)
@Li,74 PSAY "|"
Li++
@Li,00 PSAY STR0031	//"| Produtos notificados"
@Li,41 PSAY "| "+AllTrim(Str(aEstatistica[9,2]))
@Li,55 PSAY "|       "+Str((aEstatistica[9,2]/aEstatistica[11,2])*100,6,2)
@Li,74 PSAY "|"
Li++
@Li,00 PSAY STR0032	//"| Fornecedores com entregas no periodo"
@Li,41 PSAY "| "+AllTrim(Str(aEstatistica[10,2]))
@Li,55 PSAY "|       "+Str((aEstatistica[10,2]/aEstatistica[15,2])*100,6,2)
@Li,74 PSAY "|"
Li++
@Li,00 PSAY STR0033	//"| Produtos entregues no periodo"
@Li,41 PSAY "| "+AllTrim(Str(aEstatistica[11,2]))
@Li,55 PSAY "|       "+Str((aEstatistica[11,2]/aEstatistica[16,2])*100,6,2)
@Li,74 PSAY "|"
Li++
@Li,00 PSAY STR0034	//"| Lead Time maximo em transito"
@Li,41 PSAY "| "+AllTrim(Str(aEstatistica[12,2]))+" dia(s)"
@Li,55 PSAY "| "
@Li,74 PSAY "|"
Li++
@Li,00 PSAY STR0035	//"| Lead Time maximo em laboratorio"
@Li,41 PSAY "| "+AllTrim(Str(aEstatistica[13,2]))+" dia(s)"
@Li,55 PSAY "| "
@Li,74 PSAY "|"
Li++
@Li,00 PSAY STR0036	//"| Lead Time maximo com Laudo"
@Li,41 PSAY "| "+AllTrim(Str(aEstatistica[14,2]))+" dia(s)"
@Li,55 PSAY "| "
@Li,74 PSAY "|"
Li++
@Li,00 PSAY STR0037	//"| Numero total de fornecedores"
@Li,41 PSAY "| "+AllTrim(Str(aEstatistica[15,2]))
@Li,55 PSAY "| "
@Li,74 PSAY "|"
Li++
@Li,00 PSAY STR0038	//"| Numero total de produtos"
@Li,41 PSAY "| "+AllTrim(Str(aEstatistica[16,2]))
@Li,55 PSAY "| "
@Li,74 PSAY "|"
Li++
@Li,00 PSAY Replicate("-",75)
Li++

Cabec(cTitulo,Cabec1,Cabec2,cNomeProg,cTamanho,nTipo)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ordena as Nao Conformidades de acordo com o laudo das entregas Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aNaoConf := ASort(aNaoConf,,,{|x,y|x[1]<y[1]})

If Len(aNaoConf) > 0
	@Li,00 PSAY STR0017+aMeses[mv_par02] +  " / " + Str(mv_par01,4)		//"Periodo :"
	Li+=2
	@Li,00 PSAY STR0039	//"Descricao das Nao Conformidades"
	Li+=2

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁMontagem do Cabe┤alho das NAO CONFORMIDADES                   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	SetRegua(Len(aNaoConf))
	For nC := 1 To Len(aNaoConf)
		IncRegua()
		If Li > 58
			If lImp
				@Li,00 PSAY Replicate("-",132)
			Endif
            Cabec(cTitulo,Cabec1,Cabec2,cNomeProg,cTamanho,nTipo)
		EndIf
		
		If cLaud != aNaoConf[nC,1]
			cLaud := aNaoConf[nC,1]
			If lRoda
				@Li,00 PSAY Replicate("-",132)
				Li+=2
			EndIf
			dbSelectArea("QED")
			dbSetOrder(1)
			dbSeek(xFilial("QED")+aNaoConf[nC,1])
			@Li,00 PSAY QED_DESCPO +STR0045+ aNaoConf[nC,1]		//" - Fator "
			Li++
			@Li,00 PSAY Replicate("-",132)
			Li++
			@Li,00 PSAY STR0040+Pad(Subs(cTitProd,1,43),42)+STR0041
			//"| Fornecedor           | Produto                                  |Data Entr.| N. Lote         | Tam.Lote | No. NNC      | N/C     |"
			Li++
			@Li,00 PSAY "|"+Replicate("-",130)+"|"
			Li++
			lImpCab:=.F.
		EndIf

		SA2->( dbSeek( xFilial("SA2")+aNaoConf[nC,2]+aNaoConf[nC,10]))
		QE6->( dbSeek( xFilial("QE6") + aNaoConf[nC,3]))
		@Li,000 PSAY "| "+SA2->A2_NREDUZ
		@Li,023 PSAY "| "+Subs(QE6->QE6_DESCPO,1,39)
		@Li,066 PSAY "|"+Dtoc(aNaoConf[nC,4])
		@Li,077 PSAY "| "+aNaoConf[nC,5]
		@Li,095 PSAY "| "+aNaoConf[nC,6]
		@Li,106 PSAY "| "+aNaoConf[nC,7]
		
		nPos:=Ascan(aNC,{|x|x[3] == aNaoConf[nC,2]+aNaoConf[nC,10]+aNaoConf[nC,3]+aNaoConf[nC,8]+aNaoConf[nC,9] })
		If nPos <> 0
			nX	:= 0
			For nCt:= nPos To Len(aNC)
				If aNC[nCt,3]==aNaoConf[nC,2]+aNaoConf[nC,10]+aNaoConf[nC,3]+	aNaoConf[nC,8]+aNaoConf[nC,9]
					nX++
					If nX == 1
						@Li,121 PSAY "| "+aNC[nCt,1]
						@Li,131 PSAY "|"
						Li++
					ElseIf nX == 2
						@Li,000 PSAY "| "+aNaoConf[nC,2]+" - "+aNaoConf[nC,10]
						@Li,023 PSAY "| "+aNaoConf[nC,3]
						@Li,066 PSAY "|"
						@Li,077 PSAY "|"
						@Li,095 PSAY "|"
						@Li,106 PSAY "|"
						@Li,121 PSAY "| "+aNC[nCt,1]
						@Li,131 PSAY "|"
						Li++
					Else
						@Li,000 PSAY "|"
						@Li,023 PSAY "|"
						@Li,066 PSAY "|"
						@Li,077 PSAY "|"
						@Li,095 PSAY "|"
						@Li,106 PSAY "|"
						@Li,121 PSAY "| "+aNC[nCt,1]
						@Li,131 PSAY "|"
						Li++
					EndIf

					If Li > 60
						@Li,00 PSAY Replicate("-",132)
                        Cabec(cTitulo,Cabec1,Cabec2,cNomeProg,cTamanho,nTipo)
						@Li,00 PSAY Posicione("QED",1,xFilial("QED")+aNaoConf[nC,1],"QED_DESCPO") +STR0045+ aNaoConf[nC,1]//" - Fator "
						Li++
						@Li,00 PSAY Replicate("-",132)
						Li++
						@Li,00 PSAY STR0040+Pad(Subs(cTitProd,1,43),42)+STR0041
						//"| Fornecedor           | Produto                                  |Data Entr.| N. Lote         | Tam.Lote | No. NNC      | N/C     |"
						Li++
						@Li,00 PSAY "|"+Replicate("-",130)+"|"
						Li++
					EndIf
				Else
					Exit
				EndIf
			Next nCt

         If nX < 2	// Nao imprimiu os codigos Produto / Fornecedor
				@Li,000 PSAY "| "+aNaoConf[nC,2]+" - "+aNaoConf[nC,10]
				@Li,023 PSAY "| "+aNaoConf[nC,3]
				@Li,066 PSAY "|"
				@Li,077 PSAY "|"
				@Li,095 PSAY "|"
				@Li,106 PSAY "|"
				@Li,121 PSAY "|"
				@Li,131 PSAY "|"
				Li++
			EndIf
		Else
			@Li,121 PSAY "|"
			@Li,131 PSAY "|"
			Li++
			@Li,000 PSAY "| "+aNaoConf[nC,2]+" - "+aNaoConf[nC,10]
			@Li,023 PSAY "| "+aNaoConf[nC,3]
			@Li,066 PSAY "|"
			@Li,077 PSAY "|"
			@Li,095 PSAY "|"
			@Li,106 PSAY "|"
			@Li,121 PSAY "|"
			@Li,131 PSAY "|"
			Li++
		EndIf
		lRoda	:= .T.
		lImp	:= .T.
	Next nC

	@Li,00 PSAY Replicate("-",132)
	Li+=2

EndIf
lImp	:= .F.

If Li > 60
	Cabec(cTitulo,Cabec1,Cabec2,cNomeProg,cTamanho,nTipo)
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁMontagem do RESUMO DOS IQIs / IQF's                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If mv_par03 == 1
	@Li,00 PSAY STR0042 //"Resumo dos IQIs"
Else
	@Li,00 PSAY STR0052 //"Resumo dos IQFs"
Endif		
Li+=2

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁMontagem do Cabe┤alho do Resumo dos IQIs                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
@Li,00 PSAY Replicate("-",132)
Li++
If mv_par03 == 1	// Classif. pelo IQI
	@Li,00 PSAY STR0043+" "+Pad(Subs(cTitProd,1,40),40," ")+STR0044 // "| Fornecedor          | Produto                                 | IQPm  |  IQS  |  IQIm | IQIac | Classif. Atual | Classif.Cadast. |"
Else	// Classif. pelo IQF
	@Li,00 PSAY STR0043+" "+Pad(Subs(cTitProd,1,40),40," ")+STR0047 // "| Fornecedor          | Produto                                 | IQPm  |  IQS  |  IQFm | IQFac | Classif. Atual | Classif.Cadast. |"
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё  Lay-out do Quadro de Resumo de IQIs.                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//"| Fornecedor          | Produto                                 | IQPm  |  IQS  |  IQIm | IQIac | Classif. Atual | Classif.Cadast. |"
// | 12345678901234567890| 1234567890123456789012345678901234567890| 123456| 123456| 123456| 123456| 123456789012345| 123456789012345 |
// 0         1         2         3         4         5         6         7         8         9        10        11        12        13
// 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901

Li++
@Li,00 PSAY "| "+Replicate("-",129)+"|"
Li++

//Aadd(aResIQI,{QEV_FORNEC,QEV_PRODUT,QEV_IQP,QEV_IQS,QEV_IQFA,SA5->A5_LOJA,QEV_IQF})

dbSelectArea("TRB02")
dbGoTop()
While TRB02->(!EOF())
	
	If Li > 58
		If lImp
			@Li,00 PSAY Replicate("-",132)
		EndIf
		
		Cabec(cTitulo,Cabec1,Cabec2,cNomeProg,cTamanho,nTipo)
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁMontagem do RESUMO DOS IQIs                                   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If mv_par03 == 1
			@Li,00 PSAY STR0042 //"Resumo dos IQIs"
		Else 
			@Li,00 PSAY STR0052 //"Resumo dos IQFs"		
		Endif	
		Li+=2
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁMontagem do Cabe┤alho do Resumo dos IQIs                      Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		@Li,00 PSAY Replicate("-",132)
		Li++
		If mv_par03 == 1	// Classif. pelo IQI
			@Li,00 PSAY STR0043+" "+Pad(Subs(cTitProd,1,40),40," ")+STR0044 // "| Fornecedor          | Produto                                 | IQPm  |  IQS  |  IQIm | IQIac | Classif. Atual | Classif.Cadast. |"
		Else	// Classif. pelo IQF
			@Li,00 PSAY STR0043+" "+Pad(Subs(cTitProd,1,40),40," ")+STR0047 // "| Fornecedor          | Produto                                 | IQPm  |  IQS  |  IQFm | IQFac | Classif. Atual | Classif.Cadast. |"
		EndIf
		Li++
		@Li,00 PSAY "| "+Replicate("-",129)+"|"
		Li++
	EndIf

	If SA2->( dbSeek( xFilial("SA2") + TRB02->FORNEC))	// Fornecedor
		cStrUsado := SA2->A2_NREDUZ
	Else
		cStrUsado := ""  // se nao encontra nao imprime nada.
	EndIf
	QE6->( dbSeek( xFilial("QE6") + TRB02->PRODUT))	// Produto

	SA5->(DbSetOrder(2))
	SA5->(MsSeek(xFilial("SA5")+TRB02->PRODUT+TRB02->FORNEC)) // Pesquisa Produto x Fornecedor para capturar a loja correta
	while SA5->(!EOF()) .and. SA5->A5_FILIAL+SA5->A5_PRODUTO+SA5->A5_FORNECE == xFilial("SA5")+TRB02->PRODUT+TRB02->FORNEC
		If SA5->A5_ATUAL == 'S'
			Exit
		EndIF
	    SA5->(DBSKIP())
	EndDo
	cStrUsado := AllTrim(cStrUsado)
	cStrUsado := If(Len(cStrUsado) > 0, cStrUsado + "-", cStrUsado)
	cStrUsado := cStrUsado + AllTrim(TRB02->FORNEC) + "/" + AllTrim(SA5->A5_LOJA)
	nTamUsado := Len(cStrUsado)
	@Li,000 PSAY "| "+ AllTrim(Subs(cStrUsado,1,20))
	@Li,022 PSAY "| "+Subs(QE6->QE6_DESCPO,1,39)
	@Li,064 PSAY "| "+If(TRB02->IQP==999.99,"  N/A",Str(TRB02->IQP,6,2))	// IQPm //  .Or. aResIQI[nC,3]==0 - Comentei
	
	If TRB02->IQS == 999.99	// .Or. aResIQI[nC,4] == 0 // IQS - Comentei
		If cQEIQSNA == "S"	// Utiliza menor fator como IQS
			QA8->(dbSeek(xFilial("QA8")+Str(0.00,6,2),.T.))
			@Li,072 PSAY "| "+Str(QA8->QA8_FATSUP,6,2)
		Else
			@Li,072 PSAY "| "+"  N/A"
		EndIf
	Else
		@Li,072 PSAY "| "+Str(TRB02->IQS,6,2)
	EndIf

	If MV_PAR03 == 2
		@Li,080 PSAY "| "+If(TRB02->IQF==999.99,"  N/A",Str(TRB02->IQF,6,2)) // IQIm - //.Or. aResIQI[nC,7]==0
		@Li,088 PSAY "| "+If(TRB02->IQFA==999.99,"  N/A",Str(TRB02->IQFA,6,2))	// IQIac -  // .Or. aResIQI[nC,7]==0
	Else
		@Li,080 PSAY "| "+If(TRB02->IQI==999.99,"  N/A",Str(TRB02->IQI,6,2)) // IQIm - //.Or. aResIQI[nC,7]==0
		@Li,088 PSAY "| "+If(TRB02->IQIA==999.99,"  N/A",Str(TRB02->IQIA,6,2))	// IQIac -  // .Or. aResIQI[nC,7]==0
	EndIf

	// Classificacao Atual
	dbSelectArea("QEG")
	dbSetOrder(2)
	if MV_PAR03 == 1
		dbSeek(xFilial("QEG")+Str(TRB02->IQIA,6,2),.T.) //aResIQI[nC,5] - Comentado
	Else
		dbSeek(xFilial("QEG")+Str(TRB02->IQFA,6,2),.T.) //aResIQI[nC,5] - Comentado
	EndiF
	If QEG_CATEG == "1" .And. TRB02->IQS == 0 .And. cQassIqs == "N" //(aResIQI[nC,4] == 999.99 .Or. 
		dbSetOrder(1)
		dbSeek(xFilial("QEG"))
		While !Eof() .And. QEG_FILIAL == xFilial("QEG")
			If QEG_CATEG > "1"
				cSitu := QEG_NIVEL
				Exit
			EndIf
			dbSkip()
		EndDo
	Else
		cSitu := QEG->QEG_NIVEL 
	EndIf
    
	@Li,096 PSAY "| "+cSitu

	// Classificacao cadastrada
	dbSelectArea("SA5")
	dbSetOrder(2)
	dbSeek(xFilial("SA5")+TRB02->PRODUT+TRB02->FORNEC)  // Pesquisa Produto x Fornecedor para capturar a loja correta
	while !EOF() .and. A5_FILIAL+A5_PRODUTO+A5_FORNECE == xFilial("SA5")+TRB02->PRODUT+TRB02->FORNEC
		If A5_ATUAL == 'S'
			Exit
		EndIF
	    SA5->(DBSKIP())
	EndDo

	dbSelectArea("QEG")
	dbSetOrder(1)
	dbSeek(xFilial("QEG")+SA5->A5_SITU)
	@Li,113 PSAY "| "+QEG->QEG_NIVEL
	@Li,131 PSAY "|"
	Li++

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Esta segunda linha sempre ┌ escrita para imprimir aResIQI[nC,2].  Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	@Li,000 PSAY "| "+AllTrim(Subs(cStrUsado,21,20))
	@Li,022 PSAY "| "+TRB02->PRODUT
	@Li,064 PSAY "|"
	@Li,072 PSAY "|"
	@Li,080 PSAY "|"
	@Li,088 PSAY "|"
	@Li,096 PSAY "|"
	@Li,113 PSAY "|"
	@Li,131 PSAY "|"
	Li++
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Se o tamanho necess═rio para imprimir toda string for maior    Ё
	//Ё  do que o espa┤o dispon║vel, quebra a string em + linhas.      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды		
	If nTamUsado > (20 * 2)  // Equivalente as duas linhas j═ utilizadas.
		
		@Li,000 PSAY "| "+ AllTrim(Substr(cStrUsado,	(20 * 2) + 1 , 20))
		@Li,022 PSAY "| "
		@Li,064 PSAY "|"
		@Li,072 PSAY "|"
		@Li,080 PSAY "|"
		@Li,088 PSAY "|"
		@Li,096 PSAY "|"
		@Li,113 PSAY "|"
		@Li,131 PSAY "|"
		Li++
	EndIf
	lImp := .T.
	
	TRB02->(dbSkip())
EndDo

@Li,00 PSAY Replicate("-",132)
Li++

If Li != 80
	Roda(nCbCont,cCbtxt)
EndIf

TRB01->(dbCloseArea())
TRB02->(dbCloseArea())

Set device to Screen
If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o	 ЁQER140TRB01Ё Autor Ё Cleber Souza         Ё Data Ё 23/09/03 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Armazenamento e Tratamento arquivo de trabalho - para QEK  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso 	 Ё SIGAQIE                       				              Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/ 

Static Function Q140TRB01()
Local cArq		:= ""
Local aCampos	:= {}
Local cQuery	:= ""
Local cCond		:= ""			
Local cNomArq	:= ""
Local cTamLABOR	:= Space(TamSX3("QEL_LABOR")[1])
Local cDbMs     := ""
Local cKey      := "QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT"
Local cNiseri	:= ""
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Cria Arquivo de Trabalho			       				     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

cDbMs := Alltrim(TcGetDb())
	

If !Empty(cDbMs) .and. cDbMs <> "POSTGRES" .AND. TcSrvType() != "AS/400"
	
	cQuery := "SELECT DISTINCT"
		cQuery += " QEK.QEK_FORNEC, QEK.QEK_LOJFOR, QEK.QEK_PRODUT,  QEK.QEK_REVI,   QEK.QEK_DTENTR,"
		cQuery += " QEK.QEK_LOTE,   QEK.QEK_VERIFI, QEK.QEK_NNC,     SA2.A2_FATAVA,  QEK.QEK_LOTINV,"
		cQuery += " QEK.QEK_ENTINV, QEK.QEK_TAMLOT, QEK.QEK_SITENT,  QEK.QEK_SKLDOC, SA5.A5_FABREV,"
		cQuery += " QEL.QEL_LAUDO,  QEL.QEL_DTENLA, QEL.QEL_DTLAUD"  
	
		cQuery += " FROM "	
			cQuery += RetSqlName("QEK")+" QEK "
			cQuery += "LEFT JOIN " + RetSqlName("SA5")+" SA5 " 
			cQuery += "  ON SA5.A5_PRODUTO = QEK.QEK_PRODUT "
			cQuery += " AND SA5.A5_FORNECE = QEK.QEK_FORNEC "
			cQuery += " AND SA5.A5_LOJA    = QEK.QEK_LOJFOR "
			cQuery += " AND SA5.D_E_L_E_T_ = ' ' "   
			
			cQuery += "LEFT JOIN " + RetSqlName("SA2")+" SA2 "
			cQuery += "  ON SA2.A2_COD     = QEK.QEK_FORNEC "
			cQuery += " AND SA2.A2_LOJA    = QEK.QEK_LOJFOR "
			cQuery += " AND SA2.D_E_L_E_T_ = ' ' "    
			
			cQuery += "LEFT JOIN " + RetSqlName("QEL")+" QEL "
			cQuery += "  ON QEL.QEL_FORNEC = QEK.QEK_FORNEC "
			cQuery += " AND QEL.QEL_LOJFOR = QEK.QEK_LOJFOR "
			cQuery += " AND QEL.QEL_PRODUT = QEK.QEK_PRODUT "
			cQuery += " AND QEL.QEL_DTENTR = QEK.QEK_DTENTR "
			cQuery += " AND QEL.QEL_LOTE   = QEK.QEK_LOTE "
			cQuery += " AND QEL.QEL_NISERI = QEK.QEK_NTFISC||QEK.QEK_SERINF||QEK.QEK_ITEMNF "
			cQuery += " AND QEL.QEL_TIPONF = QEK.QEK_TIPONF "
			cQuery += " AND QEL.QEL_LABOR = ' '" 
			cQuery += " AND QEL.D_E_L_E_T_ = ' ' "

		cQuery += "WHERE "               
			cQuery += " QEK.QEK_FILIAL = '"  + xFilial("QEK") + "' and "
			cQuery += " SA5.A5_FILIAL  = '"  + xFilial("SA5") + "' and "
			cQuery += " SA2.A2_FILIAL  = '"  + xFilial("SA2") + "' and "
			cQuery += " QEL.QEL_FILIAL = '"  + xFilial("QEL") + "' and "
			cQuery += " QEK.QEK_DTENTR LIKE '" + Str(mv_par01,4,0)+StrZero(mv_par02,2,0) + "%' AND "
			cQuery += " SA5.D_E_L_E_T_ <> '*' AND "
			cQuery += " SA2.D_E_L_E_T_ <> '*' AND "
			cQuery += " QEL.D_E_L_E_T_ <> '*' AND "
			cQuery += " QEK.D_E_L_E_T_ <> '*'"
	
	cQuery += " ORDER BY " + SqlOrder(cKey)
	
	cQuery := ChangeQuery(cQuery) 
	
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRB01", .F., .T.)
	TcSetField( "TRB01", "QEK_DTENTR", "D")
	TcSetField( "TRB01", "QEL_DTENLA", "D")
	TcSetField( "TRB01", "QEL_DTLAUD", "D")
	
ELSE

	Aadd(aCampos,{"QEK_FORNEC"	,"C",TamSX3("QEK_FORNEC")[1],0})
	Aadd(aCampos,{"QEK_LOJFOR"	,"C",TamSX3("QEK_LOJFOR")[1],0})
	Aadd(aCampos,{"QEK_PRODUT"	,"C",TamSX3("QEK_PRODUT")[1],0})
	Aadd(aCampos,{"QEK_REVI"	,"C",TamSX3("QEK_REVI")[1],0})
	Aadd(aCampos,{"QEK_DTENTR"	,"D",TamSX3("QEK_DTENTR")[1],0})
	Aadd(aCampos,{"QEK_SITENT"	,"C",TamSX3("QEK_SITENT")[1],0})
	Aadd(aCampos,{"QEK_SKLDOC"	,"L",TamSX3("QEK_SKLDOC")[1],0})
	Aadd(aCampos,{"QEK_NNC"	    ,"C",TamSX3("QEK_NNC")[1],0})
	Aadd(aCampos,{"QEK_VERIFI"	,"N",TamSX3("QEK_VERIFI")[1],0})
	Aadd(aCampos,{"QEK_LOTE"	,"C",TamSX3("QEK_LOTE")[1],0})
	Aadd(aCampos,{"QEK_ENTINV"	,"C",TamSX3("QEK_ENTINV")[1],0})
	Aadd(aCampos,{"QEK_LOTINV"	,"C",TamSX3("QEK_LOTINV")[1],0})
	Aadd(aCampos,{"QEK_TAMLOT"	,"C",TamSX3("QEK_TAMLOT")[1],0})
	Aadd(aCampos,{"A5_FABREV"	,"C",TamSX3("A5_FABREV")[1],0})
	Aadd(aCampos,{"A2_FATAVA"	,"N",TamSX3("A2_FATAVA")[1],0})
	Aadd(aCampos,{"QEL_DTENLA"	,"D",TamSX3("QEL_DTENLA")[1],0})
	Aadd(aCampos,{"QEL_DTLAUD"	,"D",TamSX3("QEL_DTLAUD")[1],0})
	Aadd(aCampos,{"QEL_LAUDO"	,"C",TamSX3("QEL_LAUDO")[1],0})
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁFiltra tabela QEK conforme parametros especificados pelo usuario.Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("QEK")
	dbSetOrder(1)
	cArq  := CriaTrab(NIL,.F.)
	cCond := 'QEK_FILIAL == "'+xFilial("QEK") +'"'
	cCond += '.And. Str(Year(QEK_DTENTR),4,0)=="'+Str(mv_par01,4,0)+;
	'" .And. Substr(DTOS(QEK_DTENTR),5,2)=="'+StrZero(mv_par02,2,0)+'"'
	IndRegua("QEK",cArq,"QEK_FILIAL+QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT",,cCond,STR0046) //"Selecionando Registros..."
	
	oTempTable := FWTemporaryTable():New( "TRB01" )
	oTempTable:SetFields( aCampos )
	oTempTable:AddIndex("indice1", {"QEK_FORNEC","QEK_LOJFOR","QEK_PRODUT","QEK_REVI"} )
	oTempTable:Create()

	QEK->(dbGoTop())
	While QEK->(!EOF())
   		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁPesquisa dados tabela SA5 - Forn x Produto.                Ё 
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   		dbSelectArea("SA5")
		dbSetOrder(2)
		IF dbSeek(xFilial("SA5")+QEK->QEK_PRODUT+QEK->QEK_FORNEC+QEK->QEK_LOJFOR)
            
    		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁPesquisa dados tabela SA2 - Cadastro de Fornecedores.      Ё 
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   			dbSelectArea("SA2")
			dbSetOrder(1)
			dbSeek(xFilial("SA2")+QEK->QEK_FORNEC+QEK->QEK_LOJFOR)
	                          
	   	 	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁPesquisa dados tabela QEL - Laudo dos Resultados.         Ё	
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	   		dbSelectArea("QEL")
			cNiseri := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
			dbSetOrder(3)
			dbSeek(xFilial("QEL")+QEK->QEK_FORNEC+QEK->QEK_LOJFOR+QEK->QEK_PRODUT+cNiseri+QEK->QEK_TIPONF+DTOS(QEK->QEK_DTENTR)+QEK->QEK_LOTE+cTamLABOR)

		 	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁAtualiza tabela de trabalho com informaГУes do QEK.        Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   			dbSelectArea("TRB01")
			RecLock("TRB01",.t.)
			TRB01->QEK_FORNEC  := QEK->QEK_FORNEC        
			TRB01->QEK_LOJFOR  := QEK->QEK_LOJFOR  
			TRB01->QEK_PRODUT  := QEK->QEK_PRODUT
			TRB01->QEK_REVI    := QEK->QEK_REVI		
			TRB01->QEK_DTENTR  := QEK->QEK_DTENTR
			TRB01->QEK_SITENT  := QEK->QEK_SITENT 
			TRB01->QEK_SKLDOC  := QEK->QEK_SKLDOC
			TRB01->QEK_NNC     := QEK->QEK_NNC
			TRB01->QEK_VERIFI  := QEK->QEK_VERIFI
			TRB01->QEK_LOTE    := QEK->QEK_LOTE
			TRB01->QEK_ENTINV  := QEK->QEK_ENTINV
			TRB01->QEK_LOTINV  := QEK->QEK_LOTINV
			TRB01->QEK_TAMLOT  := QEK->QEK_TAMLOT
		
			If SA5->(!EOF())
				TRB01->A5_FABREV   := SA5->A5_FABREV
			EndIf
		
			If SA2->(!EOF())
				TRB01->A2_FATAVA   := SA2->A2_FATAVA 
			EndIF
		
			If QEL->(!EOF()) .and. Empty(QEL->QEL_LABOR)
				TRB01->QEL_DTENLA  := QEL->QEL_DTENLA
				TRB01->QEL_DTLAUD  := QEL->QEL_DTLAUD
				TRB01->QEL_LAUDO   := QEL->QEL_LAUDO
		    EndIF
	    
			MsUnlock()

		EndIf
		
		QEK->(dbSkip())		
	EndDo      
	
	RetIndex("QEK")	

ENDIF      

Return  

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o	 ЁQ140TRB02 Ё Autor Ё Cleber Souza          Ё Data Ё 23/09/03 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Armazenamento e Tratamento arquivo de trabalho - para QEV  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso 	 Ё SIGAQIE                       				              Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function Q140TRB02()
Local cArq  		:= ""
Local aCampos		:= {}
Local cQuery		:= ""
Local cCond 		:= ""			
Local cNomArq		:= ""
Local cDbMs     := ""

cDbMs := Alltrim(TcGetDb())
	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Cria Arquivo de Trabalho			       				     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !Empty(cDbMs) .and. cDbMs <> "POSTGRES" .AND. TcSrvType() != "AS/400"

 	cQuery := "SELECT "
	 	cQuery += " QEV.QEV_ANO ANO,   QEV.QEV_MES MES,   QEV.QEV_FORNEC FORNEC, QEV.QEV_IQS IQS,  QEV.QEV_IQF IQF,"
 		cQuery += " QEV.QEV_IQI IQI,   QEV.QEV_IQIA IQIA, QEV.QEV_IQFA IQFA, QEV.QEV_PRODUT PRODUT, QEV.QEV_IQP IQP "

	cQuery += "FROM " 						
		cQuery += "	" + RetSQLName("QEV") + " QEV "

	cQuery += "WHERE " 
		cQuery += " QEV.QEV_FILIAL  =  '" + xFilial("QEV")	    +"'and "
		cQuery += " QEV.QEV_ANO     =  '" + Str(mv_par01,4)		+"'and "
		cQuery += " QEV.QEV_MES     =  '" + StrZero(mv_par02,2) +"'and "
		cQuery += " QEV.D_E_L_E_T_  <> '*' "					 
				
	cQuery += "ORDER BY "+SqlOrder(QEV->(IndexKey(1)))
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRB02", .F., .T.)

Else

	Aadd(aCampos,{"ANO"		,"C",4,0})
	Aadd(aCampos,{"MES"		,"C",2,0})
	Aadd(aCampos,{"FORNEC"	,"C",TamSX3("QEV_FORNEC")[1],0})
	Aadd(aCampos,{"PRODUT"	,"C",TamSX3("QEV_PRODUT")[1],0})
	Aadd(aCampos,{"IQS"		,"N",6,2})
	Aadd(aCampos,{"IQIA"	,"N",6,2})
	Aadd(aCampos,{"IQFA"	,"N",6,2})
	Aadd(aCampos,{"IQI"		,"N",6,2})
	Aadd(aCampos,{"IQF"		,"N",6,2})
	Aadd(aCampos,{"IQP"		,"N",6,2})

	oTempTable1 := FWTemporaryTable():New( "TRB02" )
	oTempTable1:SetFields( aCampos )
	oTempTable1:AddIndex("indice1", {"ANO","MES","FORNEC","PRODUT"} )
	oTempTable1:Create()
	
	dbSelectArea("QEV")
	dbSetOrder(1)
	cArq	:= CriaTrab(NIL,.F.)
	cCond	:='QEV_FILIAL == "'+xFilial("QEV")+'"'
	cCond	+='.And.QEV_ANO == "'+Str(mv_par01,4)+'"'
	cCond	+='.And.QEV_MES == "'+StrZero(mv_par02,2)+'"'
	IndRegua("QEV",cArq,"QEV_ANO+QEV_MES+QEV_FORNEC+QEV_PRODUT",,cCond,STR0046) //"Selecionando Registros..."
	                                   
	QEV->(dbGoTop())
	While QEV->(!Eof())
		dbSelectArea("TRB02")
		Reclock("TRB02",.T.)
		TRB02->ANO	    := QEV->QEV_ANO 
		TRB02->MES	    := QEV->QEV_MES
		TRB02->FORNEC	:= QEV->QEV_FORNEC
		TRB02->PRODUT	:= QEV->QEV_PRODUT
		TRB02->IQS	    := QEV->QEV_IQS
		TRB02->IQIA	    := QEV->QEV_IQIA
		TRB02->IQFA	    := QEV->QEV_IQFA
		TRB02->IQI	    := QEV->QEV_IQI
		TRB02->IQF	    := QEV->QEV_IQF
		TRB02->IQP	    := QEV->QEV_IQP
		MsUnlock()
		QEV->(dbSkip())
	EndDo
	
	RetIndex("QEV")
ENDIF

Return

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o	 ЁQER140TRB01Ё Autor Ё Cleber Souza         Ё Data Ё 23/09/03 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Armazenamento e Tratamento arquivo de trabalho - para QER  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso 	 Ё SIGAQIE                       				              Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/ 

Static Function Q140TRB03(cQEK_PRODUT,cQEK_REVI,cQEK_FORNEC,cQEK_LOJFOR,dQEK_DTENTR,cQEK_LOTE,cQEL_LAUDO,;
				cQEK_LOTINV,cQEK_ENTINV,cQEK_NNC,cQEK_TAMLOT)

Local aArea		:= {}
Local cChav		:= ""
Local cChvEnt	:= ""
Local cDbMs     := ""


cDbMs := Alltrim(TcGetDb())	

If !Empty(cDbMs) .and. cDbMs <> "POSTGRES" .AND. TcSrvType() != "AS/400"

	aArea := GetArea()
 	cQuery := "SELECT "  
	 	cQuery += " QER.QER_PRODUT PRODUT,  QER.QER_FORNEC FORNEC,  QER.QER_LOJFOR LOJFOR, QER.QER_DTENTR DTENTR, "
 		cQuery += " QER.QER_LOTE LOTE,      QER.QER_REVI REVI ,     QER.QER_CHAVE CHAVE"									

	cQuery += "FROM "																						
		cQuery += " " + RetSqlName("QER")+" QER "																
	
	cQuery += "WHERE " 
		cQuery += " QER.QER_FILIAL='"	+xFilial("QER")		+"' AND "
		cQuery += " QER.QER_PRODUT='"	+cQEK_Produt		+"' AND "
		cQuery += " QER.QER_REVI='"		+cQEK_Revi			+"' AND "
		cQuery += " QER.QER_FORNEC='"	+cQEK_Fornec		+"' AND "
		cQuery += " QER.QER_LOJFOR='"	+cQEK_LojFor		+"' AND "
		cQuery += " QER.QER_DTENTR='"	+Dtos(dQEK_DtEntr)	+"' AND "
		cQuery += " QER.QER_LOTE='"		+cQEK_Lote			+"' AND "
		cQuery += " QER.D_E_L_E_T_ <> '*'"							 
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"TRB03", .F., .T.)
	TcSetField( "TRB03", "DTENTR", "D")
	dbSelectArea("TRB03")
	dbGoTop()
	While !Eof()
		QEU->(dbSetOrder(1))
		QEU->(dbSeek(xFilial("QEU")+TRB03->CHAVE))
		While QEU->(!Eof()).And.xFilial("QEU") == QEU->QEU_FILIAL .And. TRB03->CHAVE == QEU->QEU_CODMED

			//здддддддддддддддддддддддддддддддддддддддд©
			//Ё Guarda as nao conformidades da entrega Ё
			//юдддддддддддддддддддддддддддддддддддддддды
			cChav:=TRB03->FORNEC+TRB03->LOJFOR+TRB03->PRODUT+cQEK_ENTINV+cQEK_LOTINV
			Aadd(aNC,{QEU->QEU_NAOCON,QEU->QEU_NUMNC,cChav})
    	
			If	cChvEnt <> TRB03->PRODUT+TRB03->FORNEC+TRB03->LOJFOR+Dtos(TRB03->DTENTR)+TRB03->LOTE
				cChvEnt := TRB03->PRODUT+TRB03->FORNEC+TRB03->LOJFOR+Dtos(TRB03->DTENTR)+TRB03->LOTE
                                      
				Aadd(aNaoConf,{cQEL_LAUDO,TRB03->FORNEC,TRB03->PRODUT,TRB03->DTENTR,TRB03->LOTE,cQEK_TAMLOT,cQEK_NNC,cQEK_ENTINV,cQEK_LOTINV,TRB03->LOJFOR})
			EndIf
			QEU->(dbSkip())
		EndDo
		TRB03->(dbSkip())
	EndDo
	dbSelectArea("TRB03")
	dbCloseArea()
	RestArea(aArea)
ELSE
	dbSelectArea("QER")
	dbSetOrder(1)
	dbSeek(xFilial("QER")+cQEK_PRODUT+cQEK_REVI+cQEK_FORNEC+cQEK_LOJFOR+Dtos(dQEK_DTENTR)+cQEK_LOTE)
	While !Eof() .And. xFilial("QER") == QER_FILIAL .And. ;
		QER->QER_PRODUT+QER->QER_REVI+QER->QER_FORNEC+QER->QER_LOJFOR+;
		Dtos(QER->QER_DTENTR)+QER->QER_LOTE == cQEK_PRODUT+cQEK_REVI+;
		cQEK_FORNEC+cQEK_LOJFOR+Dtos(dQEK_DTENTR)+cQEK_LOTE
        
		dbSelectArea("QEU")
		dbSetOrder(1)
		dbSeek(xFilial("QEU")+QER->QER_CHAVE)
		While !Eof().And.xFilial("QEU") == QEU_FILIAL .And. QER->QER_CHAVE == QEU_CODMED
			//здддддддддддддддддддддддддддддддддддддддд©
			//Ё Guarda as nao conformidades da entrega Ё
			//юдддддддддддддддддддддддддддддддддддддддды
			cChav:=QEK->QEK_FORNEC+QEK->QEK_LOJFOR+QEK->QEK_PRODUT+QEK->QEK_ENTINV+QEK->QEK_LOTINV
			Aadd(aNC,{QEU_NAOCON,QEU_NUMNC,cChav})

			If cChvEnt <> QEK->QEK_PRODUT+QEK->QEK_FORNEC+QEK->QEK_LOJFOR+Dtos(QEK->QEK_DTENTR)+QEK->QEK_LOTE
				cChvEnt := QEK->QEK_PRODUT+QEK->QEK_FORNEC+QEK->QEK_LOJFOR+Dtos(QEK->QEK_DTENTR)+QEK->QEK_LOTE
				Aadd(aNaoConf,{cQEL_LAUDO,cQEK_FORNEC,cQEK_PRODUT,dQEK_DTENTR,cQEK_LOTE,cQEK_TAMLOT,cQEK_NNC,cQEK_ENTINV,cQEK_LOTINV,cQEK_LOJFOR})
			EndIf
			dbSkip()
		EndDo

		dbSelectArea("QER")
		dbSkip()
	EndDo
ENDIF

Return  

/*/
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o    ЁDiaUtil   Ё Autor Ё Marcelo Pimentel      Ё Data Ё 01.07.98 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o ЁRetorna o numero de dias uteis no per║odo                   Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      ЁDiaUtil()                                                   Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static FuncTion DiaUtil(dDtEntr,dDtSai)
Local nDia:=0
Local nDat:=0
Local nC
Local dDt

nDat := dDtSai-dDtEntr
dDtEntr:= dDtEntr-1

For nC := 1 To nDat
	dDt:= DataValida(dDtEntr+nC,.T.)
	If dDt <> dDtEntr+nC
		Loop
	ElseIf dDt <= dDtSai
		nDia++
	EndIf
Next nC

Return(nDia) 
