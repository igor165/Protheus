#INCLUDE "HSPAHR25.ch"
#INCLUDE "PROTHEUS.ch"

Function HSPAHR25(aAnamneses, cMedico)
 Local aArea := GetArea()
 Local aResp := {}
 Local nFor  := 0
 Local cDesc1       	:= STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2       	:= STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3       	:= ""
 Local cPict        	:= ""
 Local titulo       	:= ""
 Local nLin         	:= 80
 Local Cabec1       	:= ""
 Local Cabec2       	:= STR0003 //"     Respostas"
 Local imprime      	:= .T.
 Local aOrd 									:= {}
 Private lEnd       	:= .F.
 Private lAbortPrint	:= .F.
 Private limite     	:= 132
 Private tamanho    	:= "M"
 Private nomeprog   	:= "HSPAHR25" // Coloque aqui o nome do programa para impressao no cabecalho
 Private nTipo      	:= 18
 Private aReturn    	:= { STR0004, 1, STR0005, 2, 2, 1, "", 1} //"Zebrado"###"Administracao" //"Zebrado"###"Administracao"
 Private nLastKey   	:= 0
 Private cbtxt      := Space(10)
 Private cbcont     := 00
 Private CONTFL     := 01
 Private m_pag      := 01
 Private wnrel      := "HSPAHR25" // Coloque aqui o nome do arquivo usado para impressao em disco
 Private cString 				:= "GFU"
 Private nMaxLin 				:= 0 // quantidade maxima de linhas p/ impressao
 Private cCODIMP					:= ""
 
 If Pergunte("HSPR25", .F.)
		cCODIMP		:= MV_PAR01
	EndIf
	
	Titulo := STR0006 + cMedico + " - " + HS_IniPadr("SRA", 11, cMedico, "RA_NOME") //"RELATORIO DE ANAMNESES - MEDICO: "

 nMaxLin := HS_MaxLin(cCODIMP)

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Monta a interface padrao com o usuario...                           ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

 wnrel := SetPrint(cString,NomeProg,"HSPR25",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

 If nLastKey == 27
 	Return
 Endif

 SetDefault(aReturn,cString)

 If nLastKey == 27
  Return
 Endif

 nTipo := If(aReturn[4]==1,15,18)

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

 RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin,aAnamneses) },Titulo)
Return()

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin,aAnamneses)

 Local aArea := GetArea()
 Local nFor := 0, nForResp := 0, nForImp := 0, nLinTotal := 0
 
 If Empty(aAnamneses)
	 HS_MsgInf(STR0007,STR0008, STR0009) //"Nenhum registro encontrado para impressão."###"Atenção"###"Seleção de Registros" //"Nenhum registro encontrado para impressão."###"Atenção"###"Seleção de Registros"
	 RestArea(aArea)
	 Return(Nil)
 EndIf 
 
 SetRegua(Len(aAnamneses))
 
 For nFor := 1 To Len(aAnamneses)
  IncRegua()
  If lAbortPrint
   @nLin,00 PSAY STR0010 //"*** CANCELADO PELO OPERADOR ***"
   Exit
  Endif
  
  If nLin > nMaxLin
		          //"										1									2									3									4									5									6									7									8	        9         0         1         2         3
		          //"0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.
			Cabec1 := 	STR0011 //"Anamnese  Prontuario                                                  Questionario      "
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
  Endif
  
  DbSelectArea("GFU")
  DbSetOrder(1) //GFU_FILIAL+GFU_CDANAM
  DbSeek(xFilial("GFU") + aAnamneses[nFor, 1])
  
  DbSelectArea("GCY")
  DbSetOrder(1) //GCY_FILIAL+GCY_REGATE
  DbSeek(xFilial("GCY") + GFU->GFU_REGATE)
  
  DbSelectArea("GBH")
  DbSetOrder(1) //GCY_FILIAL+GCY_REGATE
  DbSeek(xFilial("GBH") + GFU->GFU_REGGER)

  /*@nLin,000 PSAY "										1									2									3									4									5									6									7									8	        9         0         1         2         3
  nLin++
		@nLin,000 PSAY "0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.  
		nLin++*/
  @nLin,000 PSAY ALLTRIM(GFU->GFU_CDANAM)
  @nLin,010 PSAY GFU->GFU_REGGER + '-' + AllTrim(GBH->GBH_NOME) + STR0012 + Padr(HS_RDescrB("GBH_SEXO  " , GBH->GBH_SEXO), 10) + STR0013 + GCY->GCY_IDADE //" - Sexo: "###" - Idade:"
  @nLin,090 PSAY ALLTRIM(GFU->GFU_CDQUES)
  nLin += 2
  
  aResp := HS_BusResp("GFK", {{"GFK->GFK_CDANAM", aAnamneses[nFor, 1]}, {"GFK->GFK_CDQUES", aAnamneses[nFor, 2]}}, "GFK")

  If Empty(aResp)
   @nLin,005 PSAY STR0014 //"Nenhum resposta foi encontrada para esta anamnese"
   nlin+=2
  Else   
  
   For nForResp := 1 To Len(aResp)
   
    @nLin,005 PSAY aResp[nForResp][3] + " : "
    
    If ValType(aResp[nForResp][2]) == "C"
     cCodPer := SubStr(aResp[nForResp][1], 8,Len(GCH->GCH_CODPER))
     
     If !Empty(HS_IniPadr("GCH", 1, cCodPer, "GCH_CBOX"))
      aResp[nForResp][2] := HS_MA7RDes(cCodPer, AllTrim(aResp[nForResp][2]))
     EndIf
    
    aResp[nForResp][2] := Trim(aResp[nForResp][2])
 
    aResp[nForResp][2] := StrTran(aResp[nForResp][2],Chr(13), " ")
    aResp[nForResp][2] := StrTran(aResp[nForResp][2],Chr(10), "")
    
    If Len(aResp[nForResp][2]) > 100
		   nLinTotal  := Len(aResp[nForResp][2])

		   For nForImp := 1 to nLinTotal Step 100
		   
 			   @nLin, 8 + Len(aResp[nForResp][3]) PSAY Substr(aResp[nForResp][2], nForImp, 100)
 		   nlin += 2

			   If nlin > nMaxLin
			    Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
    			nLin := 9
			   Endif

   		Next nForImp

    Else
		    @nLin, 8 + Len(aResp[nForResp][3]) PSAY aResp[nForResp][2]
    EndIf
    ElseIf ValType(aResp[nForResp][2]) == "N"
     @nLin, 8 + Len(aResp[nForResp][3]) PSAY Str(aResp[nForResp][2])
    ElseIf ValType(aResp[nForResp][2]) == "D"
     @nLin, 8 + Len(aResp[nForResp][3]) PSAY DTOC(aResp[nForResp][2])
    EndIf
    nlin += 2
   Next nForResp
   
  EndIf  
 Next nFor
 
 SET DEVICE TO SCREEN

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Se impressao em disco, chama o gerenciador de impressao...          ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

 If aReturn[5] == 1
  dbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 Endif

 MS_FLUSH()
 
 RestArea(aArea)
Return()
