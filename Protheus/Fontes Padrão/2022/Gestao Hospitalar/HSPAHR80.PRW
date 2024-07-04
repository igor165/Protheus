#INCLUDE "HSPAHR80.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "Report.ch" 
#INCLUDE "Protheus.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR80 บ       ณ Bruno Santos       บ Data ณ 28/04/2006  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Ordem de Servi็o                                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Function HSPAHR80(cAtendimento, cPedidoIni, cPedidoFim, aSolic)
 Local nx := 0

 Private cRegAte := ""
 Private cCodPedIni := ""
 Private cCodPedFim := "" 
 Private cSolic     := ""
 
 Default cAtendimento    := ""
 Default cPedidoIni := ""
 Default cPedidoFim := ""
 Default aSolic       := {}
 
 cRegAte    := IIF(Empty(cAtendimento),"",cAtendimento)
 cCodPedIni := IIF(Empty(cPedidoIni)  ,"",cPedidoIni  )
 cCodPedFim := IIF(Empty(cPedidoFim)  ,"",cPedidoFim  )
 
 If !Empty(aSolic)
  For nX := 1 To Len(aSolic)
   cSolic += IIF(!Empty(cSolic),",","")+"'"+aSolic[nX]+"'"
  Next
 EndIf   
 
	HSPAHR80R3()

Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |HSPAHR80R3บ       ณ Bruno Santos       บ Data ณ 28/04/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Ordem de Servi็o                                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function HSPAHR80R3()

 Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relat๓rio "
 Local cDesc2         := STR0002 //"de acordo com os parโmetros informados pelo usuแrio."
 Local cDesc3         := ""
 Local cPict          := ""
 Local imprime        := .T.
 Local aOrd           := {}
 Local nLinTotal      := 60
 Local nLin           := 80
 
 Private cTitulo      := "Ordem de Servi็o"                                         
 Private cCabec1      := "Proced.   Descricao                     Qtd. Complemento "
 Private cCabec2      := ""
 Private lEnd         := .F.
 Private lAbortPrint  := .F.
 Private Tamanho      := "P"
 Private limite       := 80
 Private m_pag        := 01
 Private nomeprog     := "HSPAHR80R3"
 Private nTipo        := 18
 Private aReturn      := {STR0005, 1, STR0006, 2, 2, 1, "", 1}  //"Zebrado"###"Administra็ใo"
 Private nLastKey     := 0
 Private wnrel        := "HSPAHR80R3"

 Private cCodImp      := ""
 Private nMaxLin      := 0 // quantidade maxima de linhas p/ impressao
 
 //If !Pergunte(cPerg, .T.)
 // Return()
 //EndIf

 nMaxLin := HS_MaxLin(cCodImp)
 nLin    := nMaxLin * 2
       
 wnrel := SetPrint("GCY", NomeProg, "", @cTitulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .T., Tamanho,, .F.)

 If nLastKey == 27
  Return()
  EndIf                           

 SetDefault(aReturn, "GCY")
  
 If nLastKey == 27
  Return()
 EndIf
 
 RptStatus({|| RunRepRel(cCabec1, cCabec2, cTitulo, nLin, nLinTotal)}, cTitulo)
Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function RunRepRel(cCabec1, cCabec2, cTitulo, nLin, nLinTotal)
 
 Local cSql         := ""
 Local cCodSetor    := ""
 Local cRegAteAnt   := "", cCodPedAnt := ""
 Local nCont        := 0
 Local nTotLin      := 0
 
 cSql := "  SELECT GNJ_REGATE, GCY.GCY_DATATE, GCY_HORATE, GNJ_REGGER, GBY.GBY_NOMPAC, GCY_IDADE, GCY_SEXO, GBY_COMPTO, "
 cSql += "         GCM_CODCON, GCM_CODPLA, GCM_DESPLA, GBY_LOCSOL, GAV_CODLOC, GAV_QUARTO, GAV_LEITO, "
 cSql += "         GBY_CODLOC, GNJ_SOLCRM, GNJ_CODSEQ, GNJ_DATPED, GBY_PROSOL, GA7_DESC, GCY_CODLOC, GNJ_SOLCRM "
 cSql += "    FROM "+RetSqlName("GNJ")+" GNJ "
 cSql += "    JOIN "+RetSqlName("GCY")+" GCY ON GCY_REGATE = GNJ_REGATE AND GCY.GCY_FILIAL = '"+xFilial("GCY")+"' AND GCY.D_E_L_E_T_ <> '*'"
 cSql += "    JOIN "+RetSqlName("GBY")+" GBY ON GBY_CODPED = GNJ_CODSEQ AND GBY.GBY_FILIAL = '"+xFilial("GBY")+"' AND GBY.D_E_L_E_T_ <> '*'"
 cSql += "    JOIN "+RetSqlName("GD4")+" GD4 ON GD4_REGGER = GBY_REGGER AND GD4.GD4_FILIAL = '"+xFilial("GD4")+"' AND GD4.D_E_L_E_T_ <> '*' "
 cSql += "     AND GD4_IDPADR = '1' AND GD4_IDEATI = '1'"
 cSql += "    JOIN "+RetSqlName("GCM")+" GCM ON GCM_CODPLA = GD4_CODPLA AND GCM.GCM_FILIAL = '"+xFilial("GCM")+"' AND GCM.D_E_L_E_T_ <> '*'  "
 cSql += "    LEFT JOIN "+RetSqlName("GAV")+" GAV ON GAV_REGATE = GBY_REGATE AND GAV.GAV_FILIAL = '"+xFilial("GAV")+"' AND GAV.D_E_L_E_T_ <> '*'"
 cSql += "     AND GAV_RESERV = GBY_RESERV"
 cSql += "    JOIN "+RetSqlName("GA7")+" GA7 ON GA7_CODPRO = GBY_PROSOL AND GA7.GA7_FILIAL = '"+xFilial("GA7")+"' AND GA7.D_E_L_E_T_ <> '*'"
 cSql += "   WHERE GNJ_FILIAL = '"+xFilial("GNJ")+"' AND GNJ.D_E_L_E_T_ <> '*' "
 
 IF(!Empty(cRegAte))
  cSql += "     AND GNJ_REGATE = '"+cRegAte+"'"  
 EndIf 
 IF !Empty(cCodPedIni) .And. !Empty(cCodPedFim)
  cSql += "     AND GNJ_CODSEQ >= '"+cCodPedIni+"' AND GNJ_CODSEQ <= '"+cCodPedFim+"' "
 ElseIf !Empty(cCodPedIni)
  cSql += "     AND GNJ_CODSEQ = '"+cCodPedIni+"' " 
 EndIf

 IF(!Empty(cSolic))
  cSql += "     AND GBY_SOLICI IN ("+cSolic+")"
 EndIf
 
 cSql += "   ORDER BY GNJ_CODSEQ, GBY_CODLOC"

 cSql := ChangeQuery(cSql)
 TCQUERY cSql NEW ALIAS "QRY"
 
 DbSelectArea("QRY")
 
 If Eof() //Valida dados
  Hs_MsgInf(STR0020, STR0021, STR0022) //"Nใo hแ dados para a impressใo!"###"Aten็ใo"###"Valida็ใo de Impressใo"
  DbCloseArea()
  Return(Nil)
    EndIf 

	While !Eof()
                                                    
 	If lAbortPrint
   @nLin, 000 PSAY STR0007 //"INTERROMPIDO PELO USUมRIO"
   Exit
     EndIf
 
 	If cCodSetor <> QRY->GBY_CODLOC .Or. cRegAteAnt <> QRY->GNJ_REGATE .Or. cCodPedAnt <> QRY->GNJ_CODSEQ
	  nLin := FS_Cabec(,.T.)

   @nLin, 000 Psay "Hospital "
   @nLin, 060 Psay "Impressใo "+dToC(dDataBase)

      nLin++
   @nLin, 000 Psay "Atendimento: "+QRY->GNJ_REGATE 
   @nLin, 022 Psay "Data: "+ DtoC(StoD(QRY->GCY_DATATE))
   @nLin, 040 Psay "Hora: "+QRY->GCY_HORATE
   @nLin, 054 Psay "Prontuario: "+QRY->GNJ_REGGER           
 
     nLin++
   @nLin, 000 Psay "Paciente: "+QRY->GBY_NOMPAC
   @nLin, 040 Psay "Sexo: "+IIF(QRY->GCY_SEXO == '1', "Feminino", "Masculino")
   @nLin, 060 Psay "Idade: "+QRY->GCY_IDADE
 
     nLin++
   @nLin, 000 Psay "Convenio/Plano: "+QRY->GCM_CODCON+" - "+AllTrim(SubStr(Hs_IniPadr("GA9", 1, QRY->GCM_CODCON,"GA9_NOME",,.F.),1,25))+"/"+QRY->GCM_CODPLA+" - "+AllTrim(SubStr(QRY->GCM_DESPLA,1,25))

     nLin++                                                                 
   @nLin, 000 Psay "Setor Rec: "+QRY->GCY_CODLOC
   @nLin, 015 Psay SUBSTR(HS_IniPadr("GCS", 1, QRY->GCY_CODLOC, "GCS_NOMLOC"),1,30)
   @nLin, 047 Psay "Posto/Quarto/Leito: "+QRY->GAV_CODLOC+"-"+QRY->GAV_QUARTO+"-"+QRY->GAV_LEITO
 
     nLin++
   @nLin, 000 Psay "Medico Solic.: "+QRY->GNJ_SOLCRM+" - " + HS_IniPadr("SRA", 11, QRY->GNJ_SOLCRM, "RA_NOME") 
                                                    
    nLin++     
   @nLin, 000 Psay "Setor Executante: "+QRY->GBY_CODLOC
   @nLin, 021 Psay  Substr(HS_IniPadr("GCS", 1, QRY->GBY_CODLOC, "GCS_NOMLOC"),1,30)
   @nLin, 053 Psay  "N๚mero OS: "+GNJ_CODSEQ
           
   nLin++  
   @nLin, 000 Psay Replicate("-",80)
   cCodSetor  := QRY->GBY_CODLOC 	   
   cRegAteAnt := QRY->GNJ_REGATE
   cCodPedAnt := QRY->GNJ_CODSEQ    	   
  Endif
    
  nLin := FS_Cabec(nLin +1)	 
      
  @nLin, 000 Psay QRY->GBY_PROSOL
  @nLin, 010 Psay SUBSTR(QRY->GA7_DESC, 1, 30)
  @nLin, 041 Psay "1"  

  If !Empty(QRY->GBY_COMPTO)
	  nTotLin := MLCount(Trim(QRY->GBY_COMPTO), 20)  
	  For nCont := 1 To nTotLin
		  cLinha  := MemoLine(Trim(QRY->GBY_COMPTO), 20, nCont)
		  @nLin, 045 Psay cLinha   

		  If nTotLin > 1 
 		  nLin := FS_Cabec(nLin+1)
    EndIf
		 Next nCont
  EndIf               

  DbSkip() 	   	  
 EndDo 

 DbCloseArea()

 Set Printer To
 Set Device To Screen

 If aReturn[5]==1
  DbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 EndIf

 MS_FLUSH()

Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_Cabec  บAutor  ณLuiz Gustavo Caloi  บ Data ณ  30/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprimi Cabe็alho                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function FS_Cabec(nLin, lQuebra)        
 Default nLin    := 8
 Default lQuebra := .F.
 
 If nLin > nMaxLin .Or. lQuebra
   Cabec(cTitulo, cCabec1, cCabec2, NomeProg, Tamanho, nTipo)
  nLin := 8
  Endif
Return(nLin)