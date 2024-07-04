#INCLUDE "MATA911.CH"
#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMATA911   บAutor  ณRegina Stanquevis   บ Data ณ  18/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDispoe sobre o regime tributario simplificado da            บฑฑ
ฑฑบ          ณMicroempresa e da Empresa de Pequeno Porte (MPEs) no        บฑฑ
ฑฑบ          ณEstado de Sao Paulo (SIMPLES PAULISTA)                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaFis                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function MATA911()

Local aICMSDev 		:= {}
Local aReceita		:= {}
Local nRecBruta		:= 0
Local nRecBrutm		:= 0
Local dDataIni		:= CtoD("//")
Local dDataFim		:= CtoD("//")
Local dDtRecIni		:= CtoD("//")
Local dDtRecFim		:= CtoD("//")


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica as perguntas selecionadas                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Pergunte("MTA911",.T.)    

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas para parametros                                    ณ
//ณ mv_par01        // Data Inicial                                         ณ
//ณ mv_par02        // Data Final                                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dDataIni	:= mv_par01
dDataFim	:= mv_par02

dDtRecIni	:= Ctod("01/01/"+ Str(Year(mv_par01)-1,4))
dDtRecFim	:= Ctod("31/12/"+ Str(Year(mv_par01)-1,4))

nRecBruta 	:= CalcRecBru(dDtRecIni, dDtRecFim)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณReceita Bruta Acumulada informada manualmente     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(GetNewPar("MV_RBACSP",""))
	aReceita := &(GetNewPar("MV_RBACSP",{0,0})) 
	If aReceita[1] == Year(dDtRecFim)		
		nRecBruta := aReceita[2]
	Endif
Endif

nRecBrutm	:= CalcRecBru(dDataIni, dDataFim)

aICMSDev	:= Tributa(nRecBruta,nRecBrutm)

Tela (nRecBruta, nRecBrutm, aICMSDev[1][1], dDataIni, dDataFim, aICMSDev[1][2], aICMSDev[1][3])           

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณCalcRecBruบAutor  ณRegina Stanquevis   บ Data ณ  18/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalcula a receita bruta no periodo selecionado              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFis                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                  

Function CalcRecBru(dDataIni, dDataFim)                                                                     
                         
Local aAreaAnt := GetArea()
Local cAlias		:= "SF2"
Local nTotRecBru 	:= 0

#IFDEF TOP

	Local nX	:= 0
	cAlias		:= "SF2QUERY"

	aStru	:= SF2->(dbStruct())	
	cQuery	:= "SELECT SF2.F2_VALBRUT,SF2.F2_EMISSAO "		
	cQuery	+= "FROM " + RetSqlName("SF2")+" SF2 "                                    	
	cQuery	+= "WHERE SF2.F2_FILIAL = '" + xFilial("SF2") + "' AND "    		
	cQuery 	+= "SF2.F2_EMISSAO >= '" + DtoS(dDataIni) + "' AND "
	cQuery 	+= "SF2.F2_EMISSAO <= '" + DtoS(dDataFim) + "' AND "
	cQuery 	+= "SF2.D_E_L_E_T_ = ' ' "		
    cQuery 	+= "ORDER BY SF2.F2_EMISSAO"		
    cQuery 	:= ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	For nX := 1 To len(aStru)
		If aStru[nX][2] <> "C" .And. FieldPos(aStru[nX][1])<>0
		   TcSetField(cAlias,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
		EndIf
	Next nX
	dbSelectArea(cAlias) 
#Else
	dbSelectArea("SF2")
	nIndex	:=	RetIndex("SF2")
	cArqInd	:=	CriaTrab(NIL,.F.)
   	cChave	:=	"DTOS(F2_EMISSAO)+F2_FILIAL"		
	cFiltro :=	"F2_FILIAL == '" + xFilial("SF2") + "' .AND. "	    
	cFiltro	+=	"DTOS(F2_EMISSAO) >= '" + DtoS(dDataIni) + "' .AND. DTOS(F2_EMISSAO) <= '" + DtoS(dDataFim) + "'"
	IndRegua(cAlias,cArqInd,cChave,,cFiltro,STR0002) //Selecionando registros...	
	dbGotop()
#ENDIF
		
While !(cAlias)->(Eof())
	nTotRecBru += (cAlias)->F2_VALBRUT
    (cAlias)->(dbSkip())
EndDo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Exclui as areas de trabalho                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#IFDEF TOP 
    dbSelectArea(cAlias)
	dbCloseArea()
#ELSE
  	dbSelectArea(cAlias)
	RetIndex(cAlias)
	dbClearFilter()
	Ferase(cArqInd+OrdBagExt())
#ENDIF 	 
	                      
RestArea(aAreaAnt)
	         
Return nTotRecBru	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTributa   บAutor  ณRegina Stanquevis   บ Data ณ  20/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalcula o ICMS devido de acordo com o regime tributario     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMATA911                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Tributa(nRecBruta,nRecBrutm)

Local cRegTrib		:= ""
Local cICMSDev		:= ""
Local nICMS			:= 0
Local aICMSDev		:= {}     
Local aMVFXREC01 	:= &(GetNewPar("MV_FXREC01","{0,240000}"))
Local aMVFXREC02 	:= &(GetNewPar("MV_FXREC02","{240000,2400000}"))
                                         
if aMVFXREC01[1]==0 .And. aMVFXREC01[2]==0
	xMagHelpFis(STR0004, STR0011, STR0012) //parametro [MV_FXREC01] nao encontrado
endif

if aMVFXREC02[1]==0 .And. aMVFXREC02[2]==0
	xMagHelpFis(STR0004, STR0013, STR0014) //parametro [MV_FXREC02] nao encontrado
endif
      
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCalculo do ICMS de acordo com a receita bruta anualณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Do Case
	Case ( nRecBruta <= aMVFXREC01[2] ) 
		nICMS	:= 0       
		cRegTrib:= STR0034 // "Microempresa"
	Case ( nRecBruta > aMVFXREC02[1] .and. nRecBruta <= aMVFXREC02[2] ) 
	    nICMS 	:= FxTrib02(nRecBrutm)
		cRegTrib:= STR0035 // "Empresa de Pequeno Porte"
	Case ( nRecBruta > aMVFXREC02[2] )
		nICMS 	:= 1 // retorna '1' no caso de nao se enquadrar no simples
EndCase			           

Do Case
	Case nICMS == 0
		cICMSDev := STR0044 //"Isento do ICMS."
	Case nICMS > 0 .and. nICMS <> 1
		cICMSDev := STR0039 + Transform(nICMS,"@E 999,999,999.99") //"R$" 
	Case nICMS == 1
		cICMSDev := STR0045 //"Empresa sujeita เs normas gerais de tributa็ใo."
EndCase		
					
AADD(aICMSDev,{nICMS,cRegTrib,cICMSDev})

Return (aICMSDev)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณFxTrib02  บAutor  ณRegina Stanquevis   บ Data ณ  27/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalcula o ICMS devido para empresas de pequeno porte 		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMATA911                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FxTrib02(nRecBruAux)

Local nICMSDev		:= 0  
Local aMVFXMENA 	:= &(GetNewPar("MV_FXMENA","{0.01,60000.00,2.1526,430.53}"))  // {Faixa De, Faixa At้, Tributa็ao, Dedu็ใo (em reais)}
Local aMVFXMENB 	:= &(GetNewPar("MV_FXMENB","{60000.01,100000.00,3.1008,999.44}"))
Local aMVFXMENC 	:= &(GetNewPar("MV_FXMENC","{100000.01,200000.00,4.0307,1929.34}"))  
                                 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCalculo do ICMS de acordo com a receita bruta mensalณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Do Case
	Case (nRecBruAux <= aMVFXMENA[2]) 
		nICMSDev 	:= (nRecBruAux * aMVFXMENA[3]) / 100 - (aMVFXMENA[4])
	Case (nRecBruAux >= aMVFXMENB[1] .and. nRecBruAux <= aMVFXMENB[2]) 
	    nICMSDev 	:= (nRecBruAux * aMVFXMENB[3]) / 100 - (aMVFXMENB[4])
	Case (nRecBruAux >= aMVFXMENC[1])
		nICMSDev 	:= (nRecBruAux * aMVFXMENC[3]) / 100 - (aMVFXMENC[4])
EndCase			

Return nICMSDev

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTela      บAutor  ณRegina Stanquevis   บ Data ณ  31/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณApresenta as informacoes na tela                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMATA911                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Tela (nRecBruta, nRecBrutm, nICMSDev, dDataIni, dDataFim, cRegTrib, cICMSDev)
Local aICMSDev := {} 
Local oDlg
Local oGet
Local nOpca
Local lMsgYesNo 
Local ofont                        
Local ofont2

DEFINE FONT oFont NAME "Arial" SIZE 0, -11 BOLD
DEFINE FONT oFont2 NAME "Arial" SIZE 0, -11

DEFINE MSDIALOG oDlg TITLE STR0001 OF oMainWnd PIXEL FROM 0,0 TO 373,500 //"Simples Paulista"
@03, 05 To 27, 246 OF oDlg PIXEL
@07, 10 SAY OemToAnsi (STR0036) FONT oFont  SIZE 180, 8 OF oDlg PIXEL //"Razใo Social:"
@17, 10 SAY OemToAnsi (Upper (AllTrim (SM0->M0_NOMECOM))) FONT oFont2 SIZE 180, 8 OF oDlg PIXEL
@30, 05 To 54, 246 OF oDlg PIXEL
@34, 10 SAY OemToAnsi (STR0037) FONT oFont SIZE 180, 8 OF oDlg PIXEL //"Regime de Tributa็ใo:"
@44, 10 SAY OemToAnsi (cRegTrib) FONT oFont2 SIZE 180, 8 OF oDlg PIXEL
@57, 05 To 81, 246 OF oDlg PIXEL
@61, 10 SAY OemToAnsi (STR0038) FONT oFont SIZE 180, 8 OF oDlg PIXEL //"Receita Bruta Anual (Ano Anterior):"
@71, 10 SAY OemToAnsi (STR0039 + Transform(nRecBruta,"@E 999,999,999,999.99")) FONT oFont2 SIZE 180, 8 OF oDlg PIXEL //"R$"
@84, 05 To 108, 246 OF oDlg PIXEL
@88, 10 SAY OemToAnsi (STR0040) FONT oFont SIZE 180, 8 OF oDlg PIXEL //"Receita Bruta Mensal:"
@98, 10 SAY OemToAnsi (STR0039 + Transform(nRecBrutm,"@E 999,999,999,999.99")) FONT oFont2 SIZE 180, 8 OF oDlg PIXEL //"R$"
@111, 05 To 135, 246 OF oDlg PIXEL
@115, 10 SAY OemToAnsi (STR0041) FONT oFont SIZE 180, 8 OF oDlg PIXEL //"Perํodo:"
@125, 10 SAY OemToAnsi (FormDate(dDataIni) + STR0042 + FormDate(dDataFim)) FONT oFont2 SIZE 180, 8 OF oDlg PIXEL //" เ "
@138, 05 To 162, 246 OF oDlg PIXEL
@142, 10 SAY OemToAnsi (STR0043) FONT oFont SIZE 180, 8 OF oDlg PIXEL //"ICMS Devido:"
@152, 10 SAY OemToAnsi (cICMSDev) FONT oFont2 SIZE 180, 8 OF oDlg PIXEL
                                                  
DEFINE SBUTTON FROM 172, 160 TYPE 1 ACTION (oDlg:End(), nOpca:=2) ENABLE OF oDlg PIXEL
DEFINE SBUTTON FROM 172, 190 TYPE 5 ACTION (Pergunte ("MTA911", .T.), Atualiza(@nRecBruta, @nRecBrutm, @cICMSDev, @nICMSDev, @cRegTrib, @dDataIni, @dDataFim), nOpca:=3) ENABLE OF oDlg PIXEL2
DEFINE SBUTTON FROM 172, 220 TYPE 6 ACTION (ImpTela (nRecBruta,nRecBrutm,cICMSDev,nICMSDev,cRegTrib,dDataIni,dDataFim), nOpca:=4) ENABLE OF oDlg PIXEL
ACTIVATE MSDIALOG oDlg CENTERED

Return .T. 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณAtualiza  บAutor  ณRegina Stanquevis   บ Data ณ  31/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza os valores da receita e do ICMS devido e o regime  บฑฑ
ฑฑบ          ณtributario da empresa de acordo com o periodo selecionado   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMATA911                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Atualiza(nRecBruta, nRecBrutm, cICMSDev, nICMSDev, cRegTrib, dDataIni, dDataFim)

dDataIni	:= mv_par01
dDataFim	:= mv_par02

dDtRecIni	:= Ctod("01/01/"+ Str(Year(mv_par01)-1,4))
dDtRecFim	:= Ctod("31/12/"+ Str(Year(mv_par01)-1,4))

//ฺฤฤฤฤฤฤฤฤฤฟ
//ณRecalculoณ
//ภฤฤฤฤฤฤฤฤฤู

nRecBrutA 	:= CalcRecBru(dDtRecIni, dDtRecFim)     

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณReceita Bruta Acumulada informada manualmente     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(GetNewPar("MV_RBACSP",""))
	aReceita := &(GetNewPar("MV_RBACSP",{0,0})) 
	If aReceita[1] == Year(dDtRecFim)		
		nRecBrutA := aReceita[2]
	Endif
Endif

nRecBrutM	:= CalcRecBru(dDataIni, dDataFim)       
aICMSDev	:= Tributa(nRecBrutA, nRecBrutM)
                                      
nICMSDev	:= (aICMSDev[1][1])
cRegTrib	:= (aICMSDev[1][2])              
cICMSDev	:= (aICMSDev[1][3])                             

Return .T.                                           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณFormDate  บAutor  ณRegina Stanquevis   บ Data ณ  31/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConverte data no formato dd/mm/aaaa                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMATA911                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FormDate(dData)

Return StrZero(Day(dData),2)+ "/" + StrZero(Month(dData),2)+ "/" + StrZero(Year(dData),4)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณImpTela   บAutor  ณRegina Stanquevis   บ Data ณ  02/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณChama impressao das informacoes da tela                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMATA911                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ImpTela(nRecBruta,nRecBrutm,cICMSDev,nICMSDev,cRegTrib,dDataIni,dDataFim)

Local aArea		:= GetArea()
Local Titulo	:= STR0003				// Impressao das informacoes do Simples Paulista"
Local lDic     	:= .F. 					// Habilita/Desabilita Dicionario      
Local lComp    	:= .T. 					// Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro  	:= .T. 					// Habilita/Desabilita o Filtro
Local wnrel    	:= "MATA911"  			// Nome do Arquivo utilizado no Spool
Local nomeprog 	:= "MATA911"  			// nome do programa
Local cString	:= "SF2"

Private Tamanho := "P"					// P/M/G
Private Limite  := 80  				// 80/132/220
Private aOrdem  := {}  				// Ordem do Relatorio
Private aReturn := {"Zebrado",1,"Adminis",1,2,1,"",1}	

Private lEnd    := .F.					// Controle de cancelamento do relatorio
Private m_pag   := 1  					// Contador de Paginas
Private nLastKey:= 0  					// Controla o cancelamento da SetPrint e SetDefault

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEnvia para a SetPrint                                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
wnrel := SetPrint(cString,wnrel,"",@titulo,"","","",lDic,aOrdem,lComp,,lFiltro)
If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	dbClearFilter()
	Return
Endif
SetDefault(aReturn,cString)
If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	dbClearFilter()
	Return
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณImprime o relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RptStatus({|lEnd| ImpDet(nRecBruta,nRecBrutm,cICMSDev,nICMSDev,cRegTrib,dDataIni,dDataFim)},Titulo)

dbSelectArea(cString)
dbClearFilter()
Set Device To Screen
Set Printer To

If (aReturn[5] = 1)
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()

Return .T. 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpDet     บAutor  ณRegina Stanquevis   บ Data ณ 03/02/2005  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpressao do relatorio                                       บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMATA911                                                      บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ImpDet(nRecBruta,nRecBrutm,cICMSDev,nICMSDev,cRegTrib,dDataIni,dDataFim)

Local nLinha	:= 0
Local aLay		:= RetLayOut()

nLinha 	:= SIMPCabec()

@ nLinha,000 PSAY AvalImp(Limite)                

FmtLin({},aLay[01],,,@nLinha)                              
FmtLin({PadC(AllTrim(SM0->M0_NOMECOM),80)},aLay[02],,,@nLinha)                              
FmtLin({Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),SM0->M0_INSC},aLay[03],,,@nLinha)                              
FmtLin({},aLay[04],,,@nLinha)                              
FmtLin({},aLay[05],,,@nLinha)
FmtLin({},aLay[06],,,@nLinha)
FmtLin({AllTrim(cRegTrib)},aLay[07],,,@nLinha)
FmtLin({},aLay[08],,,@nLinha)                              
FmtLin({},aLay[09],,,@nLinha)                              
FmtLin({},aLay[10],,,@nLinha)                              
FmtLin({STR0039 + TransForm(nRecBruta,"@E 999,999,999,999.99")},aLay[11],,,@nLinha)  //"R$"
FmtLin({},aLay[12],,,@nLinha)
FmtLin({},aLay[13],,,@nLinha)
FmtLin({},aLay[14],,,@nLinha)
FmtLin({STR0039 + TransForm(nRecBrutm,"@E 999,999,999,999.99")},aLay[15],,,@nLinha) //"R$"
FmtLin({},aLay[16],,,@nLinha)
FmtLin({},aLay[17],,,@nLinha)
FmtLin({},aLay[18],,,@nLinha)
FmtLin({dtoc(dDataIni) + STR0042 + dtoc(dDataFim)},aLay[19],,,@nLinha) //" เ "
FmtLin({},aLay[20],,,@nLinha)
FmtLin({},aLay[21],,,@nLinha)
FmtLin({},aLay[22],,,@nLinha)
FmtLin({STR0039 + TransForm(nICMSDev,"@E 999,999,999,999.99")},aLay[23],,,@nLinha) //"R$"
FmtLin({},aLay[24],,,@nLinha)                
                                 
Return nLinha
                                                                                               
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณRetLayOut | Autor ณ Regina Stanquevis     ณ Data ณ 03.02.05 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Retorna o LayOut a ser impresso                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao Efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function RetLayOut()

Local aLay := Array(24)      
                                     
aLay[01] :=            "                                                                               "  
aLay[02] :=            "###############################################################################"  
aLay[03] := STR0017 // "  C.N.P.J.:   ##################               I.E.:     ##################### "
aLay[04] :=            "                                                                               "
aLay[05] :=            "+-----------------------------------------------------------------------------+"
aLay[06] := STR0018 // "| Regime de Tributacao:                                                       |"
aLay[07] := STR0019 // "| ###################################                                         |"
aLay[08] :=            "+-----------------------------------------------------------------------------+"
aLay[09] :=            "+-----------------------------------------------------------------------------+"
aLay[10] := STR0020 // "| Receita Bruta:                                                              |"
aLay[11] := STR0021 // "| #################                                                           |"
aLay[12] :=            "+-----------------------------------------------------------------------------+"
aLay[13] :=            "+-----------------------------------------------------------------------------+"
aLay[14] := STR0032 // "| Receita Bruta Mensal                                                        |"
aLay[15] := STR0033 // "| #################                                                           |"	
aLay[16] :=            "+-----------------------------------------------------------------------------+"
aLay[17] :=            "+-----------------------------------------------------------------------------+"
aLay[18] := STR0022 // "| Periodo:                                                                    |"
aLay[19] := STR0023 // "| ###################                                                         |"
aLay[20] :=            "+-----------------------------------------------------------------------------+"
aLay[21] :=            "+-----------------------------------------------------------------------------+"
aLay[22] := STR0024 // "| ICMS Devido:                                                                |"
aLay[23] := STR0025 // "| #################                                                           |"
aLay[24] :=            "+-----------------------------------------------------------------------------+"

Return aLay
                           
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณ SIMPCabec      ณ Autor ณ Regina Stanquevis ณDataณ 04.02.05 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Imprime o cabecalho                                        ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  

Static Function SIMPCabec

Local Titulo	:= STR0001 // Simples Paulista
Local nomeprog	:= "MATA911"
Local Tamanho	:= 'P'
Local nTipo		:= 18
Local cabec1	:= ""
Local cabec2	:= ""
Local nLin 		
                
nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)

nLin++

Return nLin

