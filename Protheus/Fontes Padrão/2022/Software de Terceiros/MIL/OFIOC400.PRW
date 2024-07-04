#INCLUDE "OFIOC400.ch"
#INCLUDE "Protheus.ch"                                      
   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ OFIOC400 ³ Autor ³Antonio Carlos Damaceno³ Data ³ 06/08/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Compras Por Cliente Mes a Mes                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                HISTORICO DE ATUALIZACOES DA ROTINA                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³Solic.³ Descricao                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±³            ³        ³      ³                                          ³±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function OFIOC400()

Local cDesc1  := STR0001 //"Este programa tem como objetivo imprimir relatório" 
Local cDesc2  := STR0002 //"de acordo com os parâmetros informados pelo usuário."
Local cDesc3  := STR0003 //"Compras Por Cliente Mês a Mês"
Local cString := " "
Local wnRel	  := " "
Local nLin    := 80
Local cPergMil:= "OFOC400"

Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 220

Private aReturn     := {STR0004 , 1, STR0005 , 2, 2, 1, "",1 } //"Zebrado"###"Administra‡„o"
Private aLinha      := {}
Private nLastKey    := 0
Private m_pag       := 1

Private cTitulo     := STR0003 //"Compras Por Cliente Mês a Mês"
Private cTamanho    := "G"
Private cNomeProg   := "OFIOC400"

ValidPerg(cPergMil)
IF !Pergunte(cPergMil,.T.)
	Return
EndIf

dPeriodo  := mv_par01
cQtdCliLis:= mv_par02
dPeriodo2 := mv_par01-365
nPrefixo  := mv_par03

wnrel := cNomeProg
wnrel := SetPrint( cString, wnRel, cPergMil, cTitulo, cDesc1, cDesc2, cDesc3, .F., , , cTamanho )

If nLastKey == 27
	Return Nil
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return Nil
Endif

RptStatus( { || PRINTREL(nLin,wnRel) } , STR0006 + cTitulo ) //"Imprimindo "

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PrintRel ³ Autor ³ Antonio C Damaceno    ³ Data ³ 06/08/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Imprime Resumo Anual Faturamento por Cliente               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Uso Generico.                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PrintRel(nLin,wnRel )

Local cQuery1  := ""
Local cQuery2  := ""
Local cQAlias1 := "TMP1"
Local cQAlias  := "TMP"
Local cQtdCli  := ""
Local cQtdLoj  := ""
Local aCliTotal:= {}
Local aCliente := {}
Local nCont    := 0
Local nMesCor  := 0
Local nTotPor  := 0
Local nTotAD   := ""
Local nMes01   := 0
Local nMes02   := 0
Local nMes03   := 0
Local nMes04   := 0
Local nMes05   := 0
Local nMes06   := 0
Local nMes07   := 0
Local nMes08   := 0
Local nMes09   := 0
Local nMes10   := 0
Local nMes11   := 0
Local nMes12   := 0
Local cCabec1  := "" 
Local cCabec2  := ""
Local aPeriodo := {}
Local nAno     := 0
Local nMes     := 0
Local n        := 1
Local cPrefixo := ""
Local cPrefBal := GetNewPar("MV_PREFBAL","BAL")
Local cPrefOfi := GetNewPar("MV_PREFOFI","OFI")
Local cPrefVei := GetNewPar("MV_PREFVEI","VEI")

cBDMes := "" + FG_CONVSQL("SUBS") + "(SD2.D2_EMISSAO,5,2) "
cBDAno := "" + FG_CONVSQL("SUBS") + "(SD2.D2_EMISSAO,1,4) "

Aadd( aPeriodo,( Strzero(Month(dPeriodo),2)+"/"+Strzero(Year(dPeriodo),4))    )        
nAno := Val(Left(Dtos(dPeriodo),4))            
nMes := Val(Substr(Dtos(dPeriodo),5,2)) 

cAno:="'"+Str(nAno,4)+"',"               // Ano a selecionar na select

For n:=1 To 13
	If nMes==1
		nAno--
		nMes := 12
		cAno+="'"+Str(nAno,4)+"'"
	Else
		nMes--
	EndIf
	Aadd(aPeriodo, (Strzero(nMes,2) +"/"+ Str(nAno,4)) ) 
Next                 

cQuery1 := "SELECT SD2.D2_CLIENTE, SD2.D2_LOJA, SUM(SD2.D2_TOTAL-SD2.D2_VALDEV) D2_VALBRUT "
cQuery1 += "  FROM " + RetSqlName("SD2") + " SD2 "
If !Empty(MV_PAR04)
	cQuery1 += "  JOIN " + RetSqlName("SA1") + " SA1 ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND "
	cQuery1 += "       SD2.D2_CLIENTE  = SA1.A1_COD           AND "
	cQuery1 += "       ( SA1.A1_SATIV1 = '" + MV_PAR04 + "'   OR  "
	cQuery1 += "         SA1.A1_SATIV2 = '" + MV_PAR04 + "'   OR  "
	cQuery1 += "         SA1.A1_SATIV3 = '" + MV_PAR04 + "'   OR  "
	cQuery1 += "         SA1.A1_SATIV4 = '" + MV_PAR04 + "'   OR  "
	cQuery1 += "         SA1.A1_SATIV5 = '" + MV_PAR04 + "'   OR  "
	cQuery1 += "         SA1.A1_SATIV6 = '" + MV_PAR04 + "'   OR  "
	cQuery1 += "         SA1.A1_SATIV7 = '" + MV_PAR04 + "'   OR  "
	cQuery1 += "         SA1.A1_SATIV8 = '" + MV_PAR04 + "' ) AND "
	cQuery1 += "         SA1.D_E_L_E_T_ = ' ' "
EndIf
cQuery1 += "  JOIN " + RetSqlName("SF2") + " SF2 ON SF2.F2_FILIAL = '" + xFilial("SF2") + "' AND "
cQuery1 += "         SD2.D2_DOC     = SF2.F2_DOC     AND "
cQuery1 += "         SD2.D2_SERIE   = SF2.F2_SERIE   AND "
cQuery1 += "         SD2.D2_CLIENTE = SF2.F2_CLIENTE AND "
cQuery1 += "         SD2.D2_LOJA    = SF2.F2_LOJA    AND "
cQuery1 += "         SF2.D_E_L_E_T_ = ' ' "
cQuery1 += " WHERE SD2.D2_FILIAL  = '" + xFilial("SD2") + "' AND "
cQuery1 += "       SD2.D2_TIPO    = 'N' AND "
cQuery1 += "       SD2.D_E_L_E_T_ = ' ' AND "
cQuery1 += "       SD2.D2_EMISSAO BETWEEN '" + DtoS(dPeriodo2) + "' AND '" + DtoS(dPeriodo) + "' " 
cPrefixo:=IIf(nPrefixo==1,cPrefBal, IIf(nPrefixo==2, cPrefOfi, IIf(nPrefixo==3, cPrefVei, "") ) )
If nPrefixo <> 4
	cQuery1 += "   AND SF2.F2_PREFORI = '" + cPrefixo + "'  "
EndIf
cQuery1 += "  GROUP BY SD2.D2_CLIENTE, SD2.D2_LOJA"
cQuery1 += "  ORDER BY D2_VALBRUT DESC  "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery1 ), cQAlias1 , .F., .T. )

cQtdCli+="'"
cQtdLoj+="'"

For n:=1 to cQtdCliLis

	AADD(aCliTotal,{(cQAlias1)->(D2_CLIENTE),(cQAlias1)->(D2_LOJA),(cQAlias1)->(D2_VALBRUT)} )
    cQtdLoj += (cQAlias1)->(D2_LOJA)    + "','"
    cQtdCli += (cQAlias1)->(D2_CLIENTE) + "','"

	(cQAlias1)->( DbSkip() ) 

Next

cQtdCli+="'"
cQtdLoj+="'"

//                      10        20        30        40        50        60        70        80        90        100       110       120       130       140       150       160       170       180       190       200       210       220
//            01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
  cCabec1 := STR0007+aPeriodo[2]+"    "+aPeriodo[3]+"    "+aPeriodo[4]+"    "+aPeriodo[5]+"    "+aPeriodo[6]+"    "+aPeriodo[7]+"    "+aPeriodo[8]+"    "+aPeriodo[9]+"    "+aPeriodo[10]+"    "+aPeriodo[11]+"    "+aPeriodo[12]+"    "+aPeriodo[13] //"Cliente   Nome                             Ranking A/D   %     Mes Atual  Total Periodo     "
           // xxxxxx xx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  x   xxx  9.999.999,99   99.999.999,99   999.999,99 999.999,99 999.999,99 999.999,99 999.999,99 999.999,99 999.999,99 999.999,99 999.999,99 999.999,99 999.999,99 999.999,99

  cCabec2 := IIf(nPrefixo==1,"BALCAO", IIf(nPrefixo==2, "OFICINA", IIf(nPrefixo==3, "VEICULOS", "") ) )

cQuery2 := "SELECT SD2.D2_CLIENTE        , "
cQuery2 += "       SD2.D2_LOJA           , "
cQuery2 += "       " + cBDMes + " D2_MES , "
cQuery2 += "       " + cBDAno + " D2_ANO , "
cQuery2 += "       SUM(SD2.D2_TOTAL-SD2.D2_VALDEV) D2_VALBRUT "
cQuery2 += "  FROM " + RetSqlName("SD2") + " SD2 "

If !Empty(MV_PAR04)
	cQuery2 += "  JOIN " + RetSqlName("SA1") + " SA1 ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND "
	cQuery2 += "       SD2.D2_CLIENTE  = SA1.A1_COD           AND "
	cQuery2 += "       ( SA1.A1_SATIV1 = '" + MV_PAR04 + "'   OR  "
	cQuery2 += "         SA1.A1_SATIV2 = '" + MV_PAR04 + "'   OR  "
	cQuery2 += "         SA1.A1_SATIV3 = '" + MV_PAR04 + "'   OR  "
	cQuery2 += "         SA1.A1_SATIV4 = '" + MV_PAR04 + "'   OR  "
	cQuery2 += "         SA1.A1_SATIV5 = '" + MV_PAR04 + "'   OR  "
	cQuery2 += "         SA1.A1_SATIV6 = '" + MV_PAR04 + "'   OR  "
	cQuery2 += "         SA1.A1_SATIV7 = '" + MV_PAR04 + "'   OR  "
	cQuery2 += "         SA1.A1_SATIV8 = '" + MV_PAR04 + "' ) AND "
	cQuery2 += "         SA1.D_E_L_E_T_ = ' ' "
EndIf
cQuery2 += "  JOIN " + RetSqlName("SF2") + " SF2 ON SF2.F2_FILIAL = '" + xFilial("SF2") + "' AND "
cQuery2 += "         SF2.F2_DOC     = SD2.D2_DOC     AND "
cQuery2 += "         SF2.F2_SERIE   = SD2.D2_SERIE   AND "
cQuery2 += "         SF2.F2_CLIENTE = SD2.D2_CLIENTE AND "
cQuery2 += "         SF2.F2_LOJA    = SD2.D2_LOJA    AND "
cQuery2 += "         SF2.D_E_L_E_T_ = ' ' "
cPrefixo:=IIf(nPrefixo==1,cPrefBal, IIf(nPrefixo==2, cPrefOfi, IIf(nPrefixo==3, cPrefVei, "") ) )
If nPrefixo <> 4
	cQuery2 += "   AND SF2.F2_PREFORI = '" + cPrefixo + "' "
EndIf

cQuery2 += " WHERE SD2.D2_FILIAL  = '" + xFilial("SD2") + "' AND "
cQuery2 += "       SD2.D2_CLIENTE IN(" + cQtdCli + ") AND "
cQuery2 += "       SD2.D2_LOJA    IN(" + cQtdLoj + ") AND"
cQuery2 += "       SD2.D2_TIPO    = 'N' AND "          //SO TRAZ NF FATURADA
cQuery2 += "       SD2.D_E_L_E_T_ = ' ' AND "
cQuery2 += "       SD2.D2_EMISSAO BETWEEN '" + DtoS(dPeriodo2) + "' AND '" + DtoS(dPeriodo) + "' " 

cQuery2 += " GROUP BY SD2.D2_CLIENTE , "
cQuery2 += "          SD2.D2_LOJA    , "
cQuery2 += "          " + cBDMes + " , "
cQuery2 += "          " + cBDAno + "   "
cQuery2 += " ORDER BY SD2.D2_CLIENTE , "
cQuery2 += "          SD2.D2_LOJA    , "
cQuery2 += "          D2_ANO    DESC , "
cQuery2 += "          D2_MES    DESC   "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery2 ), cQAlias , .F., .T. )
                          
If (cQAlias)->(Eof())
	HS_MsgInf(STR0008,STR0009,STR0003) //"Não foram encontrados registros para os parâmetros selecionados."###"Atenção"###"Compras Por Cliente Mês a Mês"
	(cQAlias1)->( DbCloseArea() )
	(cQAlias)->( DbCloseArea() )
	Return Nil
EndIf

ProcRegua(RECCOUNT()) // Numero de registros a processar

For n:=1 to Len(aCliTotal)
    (cQAlias)->(dBGoTop())
	While (cQAlias)->(!Eof())
	
		If (cQAlias)->(D2_CLIENTE) <> aCliTotal[n,1]
			(cQAlias)->( DbSkip() ) 
		    IncProc()
			Loop
		EndIf
	
		While .T.  
		
			If (cQAlias)->(D2_CLIENTE) <> aCliTotal[n,1]
				Exit
			EndIf		

			IIf( (cQAlias)->(D2_MES) == SubStr(aPeriodo[2] ,1,2) .AND. (cQAlias)->(D2_ANO) == SubStr(aPeriodo[2] ,4,4) ,nMes01:=(cQAlias)->(D2_VALBRUT),IIF(nMes01==0,nMes01:=0,nMes01:=nMes01))
			IIf( (cQAlias)->(D2_MES) == SubStr(aPeriodo[3] ,1,2) .AND. (cQAlias)->(D2_ANO) == SubStr(aPeriodo[3] ,4,4) ,nMes02:=(cQAlias)->(D2_VALBRUT),IIF(nMes02==0,nMes02:=0,nMes02:=nMes02))
			IIf( (cQAlias)->(D2_MES) == SubStr(aPeriodo[4] ,1,2) .AND. (cQAlias)->(D2_ANO) == SubStr(aPeriodo[4] ,4,4) ,nMes03:=(cQAlias)->(D2_VALBRUT),IIF(nMes03==0,nMes03:=0,nMes03:=nMes03))
			IIf( (cQAlias)->(D2_MES) == SubStr(aPeriodo[5] ,1,2) .AND. (cQAlias)->(D2_ANO) == SubStr(aPeriodo[5] ,4,4) ,nMes04:=(cQAlias)->(D2_VALBRUT),IIF(nMes04==0,nMes04:=0,nMes04:=nMes04))
			IIf( (cQAlias)->(D2_MES) == SubStr(aPeriodo[6] ,1,2) .AND. (cQAlias)->(D2_ANO) == SubStr(aPeriodo[6] ,4,4) ,nMes05:=(cQAlias)->(D2_VALBRUT),IIF(nMes05==0,nMes05:=0,nMes05:=nMes05))
			IIf( (cQAlias)->(D2_MES) == SubStr(aPeriodo[7] ,1,2) .AND. (cQAlias)->(D2_ANO) == SubStr(aPeriodo[7] ,4,4) ,nMes06:=(cQAlias)->(D2_VALBRUT),IIF(nMes06==0,nMes06:=0,nMes06:=nMes06))
			IIf( (cQAlias)->(D2_MES) == SubStr(aPeriodo[8] ,1,2) .AND. (cQAlias)->(D2_ANO) == SubStr(aPeriodo[8] ,4,4) ,nMes07:=(cQAlias)->(D2_VALBRUT),IIF(nMes07==0,nMes07:=0,nMes07:=nMes07))
			IIf( (cQAlias)->(D2_MES) == SubStr(aPeriodo[9] ,1,2) .AND. (cQAlias)->(D2_ANO) == SubStr(aPeriodo[9] ,4,4) ,nMes08:=(cQAlias)->(D2_VALBRUT),IIF(nMes08==0,nMes08:=0,nMes08:=nMes08))
			IIf( (cQAlias)->(D2_MES) == SubStr(aPeriodo[10],1,2) .AND. (cQAlias)->(D2_ANO) == SubStr(aPeriodo[10],4,4) ,nMes09:=(cQAlias)->(D2_VALBRUT),IIF(nMes09==0,nMes09:=0,nMes09:=nMes09))
			IIf( (cQAlias)->(D2_MES) == SubStr(aPeriodo[11],1,2) .AND. (cQAlias)->(D2_ANO) == SubStr(aPeriodo[11],4,4) ,nMes10:=(cQAlias)->(D2_VALBRUT),IIF(nMes10==0,nMes10:=0,nMes10:=nMes10))
			IIf( (cQAlias)->(D2_MES) == SubStr(aPeriodo[12],1,2) .AND. (cQAlias)->(D2_ANO) == SubStr(aPeriodo[12],4,4) ,nMes11:=(cQAlias)->(D2_VALBRUT),IIF(nMes11==0,nMes11:=0,nMes11:=nMes11))
			IIf( (cQAlias)->(D2_MES) == SubStr(aPeriodo[13],1,2) .AND. (cQAlias)->(D2_ANO) == SubStr(aPeriodo[13],4,4) ,nMes12:=(cQAlias)->(D2_VALBRUT),IIF(nMes12==0,nMes12:=0,nMes12:=nMes12))
	
			IIf( (cQAlias)->(D2_MES) == StrZero(Month(dPeriodo),2) .AND. (cQAlias)->(D2_ANO) == Alltrim(Str(Year(dPeriodo))),nMesCor:=(cQAlias)->(D2_VALBRUT),0)
		
			(cQAlias)->( DbSkip() ) 

		End
	
		nTotPor:= (nMesCor*100)/(aCliTotal[n,3]/12)     // Porcentagem Mes Atual 
                                                      // Descendente/Ascendente
		nTotAD := IIf(nTotPor<100,"D","A")              // Faturamento Mes Atual em ralação a Media mes 
//                           1            2       3   4      5       6           7
		AADD(aCliente,{aCliTotal[n,1],aCliTotal[n,2],,nTotAD,nTotPor,nMesCor,aCliTotal[n,3],;
    	               nMes01,nMes02,nMes03,nMes04,nMes05,nMes06,nMes07,nMes08,nMes09,nMes10,nMes11,nMes12})
//                        8     9       10     11    12     13     14     15     16     17     18     19

		nMes01  := 0
		nMes02  := 0
		nMes03  := 0
		nMes04  := 0
		nMes05  := 0
		nMes06  := 0
		nMes07  := 0
		nMes08  := 0
		nMes09  := 0
		nMes10  := 0
		nMes11  := 0
		nMes12  := 0

		Exit

	End	

    IncProc()

Next



For nCont := 1 to Len(aCliente)

// Imprime dados 

	If nLastKey == 27
	    @ ++nLin, 000 PSay STR0010 //"******** CANCELADO PELO OPERADOR ********"
		(cQAlias1)->( DbCloseArea() )
		(cQAlias)->( DbCloseArea() )
		Return Nil
	EndIf

	If nLin > 60	
		nLin := Cabec( cTitulo, cCabec1, cCabec2, cNomeProg, cTamanho, 15 ) + 1  //  Cria cabeçalho do relatório
	Endif

	@ nLin, 000 PSay aCliente[nCont,1]                                       // Cod Cliente
	@ nLin, 007 PSay aCliente[nCont,2]                                       // Loja
	
	@ nLin, 010 PSay substr(Posicione('SA1',1,xFilial('SA1') + aCliente[nCont,1]+aCliente[nCont,2] , 'A1_NOME' ),1,32)                          // Nome
	@ nLin, 045 PSay Transform(nCont, "@E 999")                              // Colocacao/Ranking
	@ nLin, 052 PSay aCliente[nCont,4]                                       // Ascendente/Descendente
	@ nLin, 055 PSay Transform(aCliente[nCont,5],   "@E          9999")      // Porcentagem Media Mensal
	@ nLin, 060 PSay Transform(aCliente[nCont,6],   "@E  9,999,999.99")      // Total Mes Atual
	@ nLin, 073 PSay Transform(aCliente[nCont,7],  "@E 999,999,999.99")      // Total Ano
	@ nLin, 090 PSay Transform(aCliente[nCont,8] /1000, "@E 999,999.9")      // Total Mes -12
	@ nLin, 101 PSay Transform(aCliente[nCont,9] /1000, "@E 999,999.9")      // Total Mes -11
	@ nLin, 112 PSay Transform(aCliente[nCont,10]/1000, "@E 999,999.9")      // Total Mes -10
	@ nLin, 123 PSay Transform(aCliente[nCont,11]/1000, "@E 999,999.9")      // Total Mes - 9
	@ nLin, 134 PSay Transform(aCliente[nCont,12]/1000, "@E 999,999.9")      // Total Mes - 8
	@ nLin, 145 PSay Transform(aCliente[nCont,13]/1000, "@E 999,999.9")      // Total Mes - 7
	@ nLin, 156 PSay Transform(aCliente[nCont,14]/1000, "@E 999,999.9")      // Total Mes - 6
	@ nLin, 167 PSay Transform(aCliente[nCont,15]/1000, "@E 999,999.9")      // Total Mes - 5
	@ nLin, 178 PSay Transform(aCliente[nCont,16]/1000, "@E 999,999.9")      // Total Mes - 4
	@ nLin, 189 PSay Transform(aCliente[nCont,17]/1000, "@E 999,999.9")      // Total Mes - 3
	@ nLin, 200 PSay Transform(aCliente[nCont,18]/1000, "@E 999,999.9")      // Total Mes - 2
	@ nLin, 211 PSay Transform(aCliente[nCont,19]/1000, "@E 999,999.9")      // Total Mes - 1
	
	nLin ++
	
	IncProc()

Next

(cQAlias)->( DbCloseArea() )
(cQAlias1)->( DbCloseArea() )
  
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Finaliza a execucao do relatorio...                                 ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
SET DEVICE TO SCREEN
	
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Se impressao em disco, chama o gerenciador de impressao...          ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
If aReturn[5] == 1 
	DbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
EndIf

MS_FLUSH()

Return(Nil)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GeraX1    ºAutor  ³                    º Data ³  04/08/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera arquivo no SX1                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
0           1           2           3           4           5           6           7           8           9
0             X1_GRUPO    X1_ORDEM    X1_PERGUNT  X1_PERSPA   X1_PERENG   X1_VARIAVL  X1_TIPO     X1_TAMANHO  X1_DECIMAL
1 X1_PRESEL   X1_GSC      X1_VALID    X1_VAR01    X1_DEF01    X1_DEFSPA1  X1_DEFENG1  X1_CNT01    X1_VAR02    X1_DEF02
2 X1_DEFSPA2  X1_DEFENG2  X1_CNT02    X1_VAR03    X1_DEF03    X1_DEFSPA3  X1_DEFENG3  X1_CNT03    X1_VAR04    X1_DEF04
3 X1_DEFSPA4  X1_DEFENG4  X1_CNT04    X1_VAR05    X1_DEF05    X1_DEFSPA5  X1_DEFENG5  X1_CNT05    X1_F3       X1_PYME
4 X1_GRPSXG   X1_HELP     X1_PICTURE  X1_IDFIL
*/
Static Function ValidPerg( cPergMil )

Local aArea    := GetArea()
Local aRegs    := {}
Local i        := 0
Local j        := 0
Local aHelpPor := {}
Local aHelpSpa := {}
Local aHelpEng := {}

// Cria grupo de perguntas
cPergMil := PADR(cPergMil, Len(SX1->X1_GRUPO))
aRegs := {}

//                                                                                                   1                                                2                                       3                                             4
//                 1       2     3                       4   5    6         7    8   9   0   1    2     3           4     5   6   7   8     9    0   1   2   3     4     5   6   7   8      9   0   1   2   3   4   5   6   7   8         9   0   1   2   3                          2  3
//                               123456789012345678901234567890
AAdd( aRegs, { cPergMil, "01", "Período ?            ", "Período ? ", "Período ? ", "mv_ch1", "D", 08, 00, 00, "G", "", "mv_par01", "   ", "", "", "", "", "   ", "", "", "", "", "   ", "", "", "", "", "     ", "", "", "", "", "", "", "", "", "      ", "", "", "", "", "" } )
AAdd( aRegs, { cPergMil, "02", "Qtde de Clientes ?   ", "Qtde de Clientes ?", "Qtde de Clientes ?", "mv_ch2", "N", 03, 00, 00, "G", "", "mv_par02", "   ", "", "", "", "", "   ", "", "", "", "", "   ", "", "", "", "", "     ", "", "", "", "", "", "", "", "", "      ", "", "", "", "", "" } )
AAdd( aRegs, { cPergMil, "03", "Informe o Prefixo ?  ", "Informe o Prefixo ?", "Informe o Prefixo ?", "mv_ch3", "N", 01, 00, 00, "C", "", "mv_par03", "BAL", "", "", "", "", "OFI", "", "", "", "", "VEI", "", "", "", "", "TODOS", "", "", "", "", "", "", "", "", "      ", "", "", "", "", "" } )
AAdd( aRegs, { cPergMil, "04", "Segmento do Cliente ?", "Segmento do Cliente ?", "Segmento do Cliente ?", "mv_ch4", "C", 06, 00, 00, "G", "", "mv_par04", "   ", "", "", "", "", "   ", "", "", "", "", "   ", "", "", "", "", "     ", "", "", "", "", "", "", "", "", "T3    ", "", "", "", "", "" } )

DbSelectArea("SX1")
DbSetOrder(1)
For i := 1 To Len(aRegs)
	If !dbSeek(cPergMil + aRegs[i,2])
		RecLock("SX1", .T.)
		For j := 1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	EndIf
		
	aHelpPor := aHelpSpa := aHelpEng := {}

	If i == 1
		AADD(aHelpPor,"Informe a Data Inicial de Partida")
	ElseIf i == 2
		AAdd(aHelpPor,"Informe a Qtde de Clientes a Listar")
	ElseIf i == 3
		AAdd(aHelpPor,"Informe o Prefixo")
		AAdd(aHelpPor,"(BAL)Balcão (OFI)Oficina (VEI)Veículos")
	ElseIf i == 4
		AAdd(aHelpPor,"Informe o Segmento do Cliente")
		AAdd(aHelpPor,"Tecla <F3> Disponível Para Consulta do")
		AAdd(aHelpPor,"Cadastro do Segmento de Clientes")
  	EndIf

	PutSX1Help("P."+cPergMil+strzero(i,2)+".",aHelpPor,aHelpEng,aHelpSpa)
	
Next
	
RestArea(aArea)

Return
