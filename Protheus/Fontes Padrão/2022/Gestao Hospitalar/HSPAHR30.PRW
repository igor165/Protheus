#INCLUDE "HSPAHR30.ch"
#INCLUDE "RWMAKE.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HSPAHR30 º Autor ³ Equipe G. Hospitalar º Data ³ 11/08/03  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Resumo do Boletim                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GESTAO HOSPITALAR                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*---------------------------------------------------------------------------
 01/08/2003 - RODRIGO - Adicionei a variável nPacDia que nao estava declarada
*/
Function HSPAHR30()

 ValidPerg()
 while .t.
  if !Pergunte("HSPR30",.t.)
   Return(Nil)
  Endif     
  If Mv_Par01 >= 1 .and. Mv_Par01 <= 12
   If Mv_Par02 >= 2002
    exit
   Else   
    HS_MsgInf(STR0001,STR0002,STR0004) //"Ano Inválido"###"Atenção"###"Resumo do Boletim"
   Endif              
  Else   
   HS_MsgInf(STR0003,STR0002,STR0004) //"Mes Inválido"###"Atenção"###"Resumo do Boletim"
  Endif     
 Enddo

 cTitulo  := STR0004 //"Resumo do Boletim"

 M_Pag    := 1
 cTamanho := "G"           // P/M/G
 nCaracter:= 15
 Limite   := 220            // 80/132/220
 aOrdem   := {}            // Ordem do Relatorio
 nLastKey := 0
 aReturn  := { STR0005, 1,STR0006,1, 1, 1, "",1 } //"Zebrado"###"Administracao"
 cNomProg := "HSPAHR30"
 cNomeRel := "HSPAHR30"
 cDrive   := "Epson.drv"
 cNomeImp := "LPT1"
 cAlias   := "GAD"

 cCabec1  := PadC(STR0004,220) //"Resumo do Boletim"
 cCabec2  := Padc(STR0007 + Strzero(Mv_Par01,2) + "/" + StrZero(Mv_Par02,4),220)                  //"Mes/Ano "
 cCab1    := "+--------+-------+---------+-----+----+-------------+---------------------+----+-----+-----------------------------------+-----------------------------------------------------------+---------------+"
 cCab2    := STR0008 //"| Numero | Nro   |Iniciais |     |    |             |        Datas        |Tipo|Total|            Diagnostico            |                       Procedimento                        |Fonte Pagadora |"
 cCab3    := STR0009 //"| de     | do    |do       |Idade|Sexo|Residencia   +----------+----------+de  |Dias +----------------------------+------+--------------------------------------------------+--------+-----------+---+"
 cCab4    := STR0010 //"| Ordem  | Pront |Nome     |     |    |             | Entrada  | Saida    |Alta|Hosp | Principal                  |Codigo| Principal                                        | Codigo | Nome      |Cod|"
 cCab5    := "+--------+-------+---------+-----+----+-------------+----------+----------+----+-----+----------------------------+------+--------------------------------------------------+--------+-----------+---+"
 //              123456   123456  1234567890  123 4   1   12345678901234  99/99/9999 | 99/99/9999   1    123   1234567890123456789012345678901   1234  12345678901234567890123456789012345678901234567890123456  12345678  12345678901  123
 
 cNomeRel := SetPrint(cAlias,cNomeRel,nil ,@cTitulo,"","","",.F.,"",.T.,cTamanho,nil    ,nil    ,nil)
 
 If nLastKey == 27
  Return(nil)
 Endif
 
 SetDefault(aReturn,cAlias)
 
 Set Printer to &cNomeRel
 Set Printer On
 Set Device  to Printer

 Processa({|| RptProc() } )  //Gera e imprime o relatorio

Return(nil)

///////////////////////////////////////////////////////////////
//   Funcao.:   RptProc                                      //
//   Objetivo.: Enviar o Relatorio para Tela ou Impressora   //
///////////////////////////////////////////////////////////////
Static Function RptProc() 
 Local i:= 0
 Local nPacDia := 0  // 01/08/2003  RODRIGO

 aVetor := {} 
 /*
 01o Elemento - Numero de Ordem
 02o Elemento - Numero do Prontuario
 03o Elemento - Iniciais do Nome
 04o Elemento - Idade
 05o Elemento - Sexo
 06o Elemento - Residencia
 07o Elemento - Data de Entrada 
 08o Elemento - Data da Alta
 09o Elemento - Tipo de Alta
 10o Elemento - Dias Internados
 11o Elemento - Descricao do Diagnostico
 12o Elemento - Codigo do Diagnostico
 13o Elemento - Descricao do Procedimento
 14o Elemento - Codigo do Procedimento
 15o Elemento - Nome da Fonte Pagadora
 16o Elemento - Codigo da Fonte Pagadora
 17o Elemento - Numero de Diarias do Paciente
 18o Elemento - Melhorados
 19o Elemento - Obitos
 20o Elemento - 
 21o Elemento - 
 22o Elemento - 
 23o Elemento - 
 24o Elemento - 
 */ 
 cAnoAnt := StrZero(Mv_Par02,4)
 cMesAnt := StrZero(Mv_Par01-1,2)
 If cMesAnt == "00"
  cMesAnt := "12"
  cAnoAnt := StrZero(Mv_Par02-1,4)
 Endif
 cDtAnt := cAnoAnt+cMesAnt+"01"
 cUltDia:= StrZero(Day(Ctod("01/"+StrZero(Mv_Par01,2)+"/"+cAnoAnt) - 1),2)
 cDtAnt1:= cAnoAnt+cMesAnt+cUltDia
 
 cData  := Strzero(Mv_Par02,4) + StrZero(Mv_Par01,2) + "01"
 cData1 := Strzero(Mv_Par02,4) + StrZero(Mv_Par01,2) + "31" // Nao Importa se ha meses sem 31 dias - serve apenas 
 
 DbSelectArea("GAD")                                        
 DbGoTop()
 dbsetorder(4)
 DbSeek(xFilial("GAD")+cDtAnt,.t.)

 nPasMes := 0

 ProcRegua(100)  
 
 While !eof() .and. Dtos(GAD->GAD_DATATE) >= cDtAnt .and. Dtos(GAD->GAD_DATATE) <= cDtAnt1
  IncProc(STR0011) //"Aguarde... Lendo Passadas de Mes..."
   If GAD->GAD_TPALTA == "99" .or. GAD->GAD_ATENDI <> "0" .or. GAD->GAD_EXCLUI == "1"
    DbSkip()
    Loop
   Endif                                          
                                          
   If GAD->GAD_DATALT == Ctod("") .or. Month(GAD->GAD_DATALT) == Mv_Par01
    nPasMes++
   Endif
   DbSkip()
 Enddo
														   // para comparacao
 DbSelectArea("GAD")                                        
 DbGoTop()
 dbsetorder(4)
 DbSeek(xFilial("GAD")+cData,.t.)

 aEntDia := {}

 ProcRegua(100)  

 While !eof() .and. Dtos(GAD->GAD_DATATE) >= cData .and. Dtos(GAD->GAD_DATATE) <= cData1
  IncProc(STR0012) //"Aguarde... Lendo Entradas por Dia..."
  If GAD->GAD_TPALTA == "99" .or. GAD->GAD_ATENDI <> "0" .or. GAD->GAD_EXCLUI == "1"
   DbSkip()
   Loop
  Endif                                          

  nPos := Ascan(aEntDia,{|x| x[1] == Day(GAD->GAD_DATATE)})

  If nPos > 0
   aEntDia[nPos,2] := aEntDia[nPos,2] + 1
  Else
   aadd(aEntDia,{Day(GAD->GAD_DATATE),1})
  Endif
    
  DbSkip()
 Enddo

 DbSelectArea("GAD")                                        
 DbGoTop()
 //dbsetorder(14) 
 dbsetorder(5)
 DbSeek(xFilial("GAD")+cData,.t.)

 //nOrdem := 0
 nAlta   := 0
 nDiar   := 0
 nDiaSUS := 0
 nDiaCnv := 0
 nObit   := 0
 nMelh   := 0
 cTDia   := 0
 nPasDia := 0

 ProcRegua(100)  

 While !eof() .and. Dtos(GAD->GAD_DATALT) >= cData .and. Dtos(GAD->GAD_DATALT) <= cData1
  IncProc(STR0013 + AllTrim(GAD->GAD_NOME))	 	 //"Aguarde... Paciente "
  If GAD->GAD_TPALTA $ "99#  " .or. GAD->GAD_ATENDI <> "0" .or. GAD->GAD_EXCLUI == "1"
   DbSkip()
   Loop
  Endif                                          

  If Dtoc(GAD->GAD_DATALT) <> ""
   nAlta++                    
   If GAD->GAD_TPALTA == "53"
    nObit := 1
    nMelh := 0
   Else         
    nMelh := 1
    nObit := 0
   Endif
  Endif     

  nDiar := If(Dtoc(GAD->GAD_DATALT) <> "",GAD->GAD_DATALT-GAD->GAD_DATATE,dDataBase-GAD->GAD_DATATE)
  cTDia := StrZero(If(Dtoc(GAD->GAD_DATALT) <> "",GAD->GAD_DATALT-GAD->GAD_DATATE,dDataBase-GAD->GAD_DATATE),3)
  If(nDiar==0,nDiar:=1,nDiar:=nDiar)
  If(cTDia=="000",cTDia:="001",cTDia:=cTDia)
  cIniNome := Substring(GAD->GAD_NOME,1,1)
  for i = 1 to len(Alltrim(GAD->GAD_NOME))
   If Substring(Alltrim(GAD->GAD_NOME),i,1) == " "
    cIniNome += Substring(GAD->GAD_NOME,i+1,1)
   Endif   
  Next
  cIniNome := cIniNome+Space(8-len(cIniNome))
  DbSelectArea("GBH")
  DbSetOrder(1)       
  DbSeek(xFilial("GBH")+GAD->GAD_REGGER)
  cIdade := StrZero(Int(dDataBase - GBH->GBH_DTNASC)/365,3) + " A"
  If Val(cIdade) < 0
   cIdade := StrZero(Int( (dDataBase - GBH->GBH_DTNASC)/30 ),3) + " M"
  Endif
  //    nOrdem++

  cTpAlta := If(GAD->GAD_TPALTA=="53","O","-")                                                                                                      
  cCidAlt := Alltrim(GAD->GAD_CIDALT)
  cCidAlt := If(Len(cCidAlt)==0,Space(4),cCidAlt)
  cDesCid := Substring(Posicione("GAS",1,xFilial("GAS")+GAD->GAD_CIDALT,"GAS_PATOLO"),1,26)
                                
  cCodPro := Space(08)
  cDesPro := Space(47)
  DbSelectArea("GAX")
  If DbSeek(xFilial("GAX")+GAD->GAD_REGATE)
   DbSelectArea("GAR")
   DbSeek(xFilial("GAR")+GAX->GAX_CODAIH)
   cCodpro := GAR->GAR_CODPRO
   cDespro := Substring(GAR->GAR_DESC,1,47)
  Endif   

  DbSelectArea("GA9")
  DbSeek(xFilial("GA9")+GAD->GAD_CODCON)
  cCodCon := GAD->GAD_CODCON
  cNomCon := Substring(GA9->GA9_NREDUZ,1,11)
        
  aadd(aVetor,{"",GAD->GAD_REGATE,cIniNome,cIdade,GBH->GBH_SEXO,Substring(GBH->GBH_MUN,1,12),Dtoc(GAD->GAD_DATATE),Dtoc(GAD->GAD_DATALT),cTpALta,cTDia,cDesCid,cCidAlt,;
                cDesPro,cCodPro,cNomCon,cCodCon,nDiar,nMelh,nObit})
  DbSelectArea("GAD")
  DbSkip()
 Enddo

 aSort(aVetor,,,{|x,y| x[8] < y[8]})

 If Len(aVetor) > 0
  setprc(0,0)
  nLin := cabec(ctitulo,cCabec1,cCabec2,cNomProg,cTamanho,nCaracter)+1
  @ nLin++,09 psay cCab1 
  @ nLin++,09 psay cCab2
  @ nLin++,09 psay cCab3
  @ nLin++,09 psay cCab4
  @ nLin++,09 psay cCab5
  nDia := Day(cTod(aVetor[1,8]))
  nAlta    := 0
  nDiarias := 0
  nObitos  := 0
  nMelhora := 0
  
  For i := 1 to Len(aVetor)
   If  nLin > 56
    Eject
    setprc(0,0)
    nLin := cabec(ctitulo,cCabec1,cCabec2,cNomProg,cTamanho,nCaracter)+1
    @ nLin++,09 psay cCab1
    @ nLin++,09 psay cCab2
    @ nLin++,09 psay cCab3
    @ nLin++,09 psay cCab4
    @ nLin++,09 psay cCab5
   Endif
         
   If  Day(cTod(aVetor[i,8])) <> nDia                  
    nPos := Ascan(aEntDia,{|x| x[1] == nDia})  
    If nPos > 0
 	 nEntDia := aEntDia[nPos,2]
	 if nDia == 1
	  nPacDia := nPasMes + aEntDia[nPos,2] - nAlta
      nPasDia := nPacDia
     Else
      nPacDia := nPacDia + aEntDia[nPos,2] - nAlta
     endif   
    Else
  	 nEntDia := 0
	 nPacDia := 0
	Endif   
    @ nLin++,09 psay cCab5
    @ nLin,09 psay STR0014+StrZero(nAlta,4)   +STR0015+StrZero(nDiarias,4)+STR0016+StrZero(nPasMes,4) //"|  Altas       --->  "###"        Diarias   --->  "###"       Passadas de Mes   --->  "
    @ nLin++,206 psay "|"
    @ nLin,09 psay STR0017+StrZero(nObitos,4) +Space(27)+STR0018+StrZero(nEntDia,4) //"|  Obitos      --->  "###"        Entradas do Dia   --->  "
    @ nLin++,206 psay "|"
    @ nLin,09 psay STR0019+StrZero(nMelhora,4)+Space(27)+STR0020+StrZero(nPacDia,4) //"|  Melhorados  --->  "###"        Pacientes-Dia     --->  "
    @ nLin++,206 psay "|"
    @ nLin++,09 psay "+"+replicate("-",196)+"+"
    nLin := nLin + 2
    nLin := cabec(ctitulo,cCabec1,cCabec2,cNomProg,cTamanho,nCaracter)+1
    @ nLin++,09 psay cCab1
    @ nLin++,09 psay cCab2
    @ nLin++,09 psay cCab3
    @ nLin++,09 psay cCab4
    @ nLin++,09 psay cCab5
    nDia := Day(cTod(aVetor[i,8])) 
    nAlta    := 0
    nDiarias := 0
    nMelhora := 0
    nObitos  := 0
   Endif

   nAlta++
   nDiarias += aVetor[i,17]
   nMelhora += aVetor[i,18]
   nObitos  += aVetor[i,19]
	     
   @ nLin++,09 psay "| "+StrZero(i,6)+" | "+aVetor[i,2]+"| "+aVetor[i,3]+"|"+aVetor[i,4]+"|  "+aVetor[i,5]+" | "+aVetor[i,6]+;
                    "|" +aVetor[i,7]+"|"+aVetor[i,8]+"|  "+aVetor[i,9]+" | "+aVetor[i,10]+" | "+aVetor[i,11]+" | "+aVetor[i,12]+" |"+;
                         aVetor[i,13]+"   |"+aVetor[i,14]+"|"+aVetor[i,15]+"|"+aVetor[i,16]+"|"
  Next

  nPos := Ascan(aEntDia,{|x| x[1] == nDia})  
  If nPos > 0
   nEntDia := aEntDia[nPos,2]
   if nDia == 1
    nPacDia := nPasMes + aEntDia[nPos,2] - nAlta
    nPasDia := nPacDia
   Else
    nPacDia := nPacDia + aEntDia[nPos,2] - nAlta
   endif   
  Else
   nEntDia := 0
   nPacDia := 0
  Endif     
        
  @ nLin++,09 psay cCab5
  @ nLin,09 psay STR0014+StrZero(nAlta,4)   +STR0015+StrZero(nDiarias,4)+STR0016+StrZero(nPasMes,4) //"|  Altas       --->  "###"        Diarias   --->  "###"       Passadas de Mes   --->  "
  @ nLin++,206 psay "|"
  @ nLin,09 psay STR0017+StrZero(nObitos,4) +Space(27)+STR0018+StrZero(nEntDia,4) //"|  Obitos      --->  "###"        Entradas do Dia   --->  "
  @ nLin++,206 psay "|"
  @ nLin,09 psay STR0019+StrZero(nMelhora,4)+Space(27)+STR0020+StrZero(nPacDia,4) //"|  Melhorados  --->  "###"        Pacientes-Dia     --->  "
  @ nLin++,206 psay "|"
  @ nLin++,09 psay "+"+replicate("-",196)+"+"
  nLin := nLin + 2
  eject	
 Else 
  HS_MsgInf(STR0021,STR0002,STR0004) //"Não há Dados a serem impressos neste Periodo!"###"Atenção"###"Resumo do Boletim"
  Return
 Endif

 Ms_Flush()                                                    
	
 Set Printer to
 Set Device  to Screen

 if aReturn[5] == 1
  OurSpool(cNomeRel)
 Endif  
Return(nil)

/*-----------------------------------------------------------------------------
	Função   VALIDPERG    
    Descrição Verifica e inclui as perguntas no sx1   
------------------------------------------------------------------------------*/
Static Function ValidPerg
 Local i:=0, j:=0
 _sAlias := Alias()                                                                                                                                              
 dbSelectArea("SX1")
 dbSetOrder(1)
 aRegs :={}

 // Versao Ap7
 AADD(aRegs,{"HSPR30","01"	,STR0022	,"                "		,"                "		,"mv_ch1"	,"N"	,2			,0			,0		,"G"	,""		,"mv_par01"		,""		,""		,""		,""		,""		,""		,""		,""		,""		,""		,""		,""		,""		,""		,"","","","","","","","","","","","N",""}) //"Informe o Mes "
 AADD(aRegs,{"HSPR30","02"	,STR0023	,"                "		,"                "		,"mv_ch2"	,"N"	,4			,0			,0		,"G"	,""		,"mv_par02"		,""		,""		,""		,""		,""		,""		,""		,""		,""		,""		,""		,""		,""		,""		,"","","","","","","","","","","","N",""}) //"Informe o Ano "
 
 cPerg :=aRegs[1,1]
 
 For i:=1 to Len(aRegs)
  dbSeek(cPerg+aRegs[i,2])
  if !found()
   RecLock("SX1",.T.)
   For j:=1 to FCount()
    If j <= Len(aRegs[i])
     FieldPut(j,aRegs[i,j])
    Endif
   Next
   MsUnlock()		
  endif
 Next
 dbSelectArea(_sAlias)
Return