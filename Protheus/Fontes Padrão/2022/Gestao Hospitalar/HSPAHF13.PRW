#INCLUDE "HSPAHF13.ch"
#include "protheus.CH"
#include "colors.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HSPAHF13 º Autor ³ Gilson da Silva    º Data ³Maio/2005    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ficha atendimento ambulatorial                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Modulo Gestao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HSPAHF13()
  
 Local cCab01    := ""    
 Local nCont     := 0
 Local aVetor    := {}  
 Local nRecno    := 0
 Local nIndGcy   := 0 
 Local cImpNeg    := chr(27)+chr(69)           //             negrito
 Local cImpCneg   := chr(27)+chr(70)           //             cancela negrito

 cTitulo   := STR0031 //"FICHAMB"
 cNomeRel  := "HSPAHF13"  
 nLin      := 0 
 
	GBH->(DbSetOrder(1))
	GBH->(DbSeek(xFilial("GBH")+ GCY->GCY_REGGER))

	GCZ->(DbSetOrder(2))
	GCZ->(DbSeek(xFilial("GCZ")+ GCY->GCY_REGATE))
	
 If nLastKey == 27
  Return(nil)
 Endif

 nTipo := If(aReturn[4]==1,15,18)    
 
 cCAB01 := STR0001 //"Ficha de Atendimento Ambulatorial"
  
 Cabec(cTitulo,	cCab01, "", cNomeRel, H44GetTam(), H44GetTip()) 

 @ PROW()+01,00  PSAY Padc(Alltrim(SM0->M0_NOMECOM),132)
 @ PROW()   ,00  PSAY Padc(Alltrim(SM0->M0_NOMECOM),132)

 @ PROW()+01,00  PSAY REPLICATE("-",132)
 @ PROW()+01,00  PSAY STR0004 + GCY->GCY_REGATE  //"No.Atend.: " 
 @ PROW()   ,70  	PSAY STR0005 + SUBSTR((HS_RDescrB("GCY_ATENDI", GCY->GCY_ATENDI)),1,20) //"TP ATENDIMENTO: "

 @ PROW()+01,00  PSAY STR0011 + GCY->GCY_CODCRM + "-" + POSICIONE("SRA", 11, XFILIAL("SRA") + GCY->GCY_CODCRM,"RA_NOME") //"Medico...: "
 @ PROW()   ,70  PSAY STR0012 //"Data:"
 @ PROW()   ,76  PSAY GCY->GCY_DATATE
 
 @ PROW()+01,00  PSAY STR0013 + GCZ->GCZ_CODCON + "-" + SUBSTR(Posicione("GA9",1, xFilial("GA9") + GCZ->GCZ_CODCON, "GA9_NOME"),1,30) //"Convenio.: "
 @ PROW()   ,70  PSAY STR0032 + SUBSTR(Posicione("GCM",2, xFilial("GCM") + GCZ->GCZ_CODPLA, "GCM_DESPLA"),1,30) //"Plano:  "
 @ PROW(),PCOL()+05 PSAY STR0014 + GCY->GCY_HORATE    //PICTURE "99:99"//"Hora: "
 
 @ PROW()+01,00  PSAY STR0033
 While !GCZ->(Eof()) .And. GCZ->GCZ_FILIAL == xFilial("GCZ") .AND. GCZ->GCZ_REGATE == GCY->GCY_REGATE
   @ PROW()+01,00  PSAY GCZ->GCZ_NRSEQG+" - "+Hs_IniPadr("GCU", 1, GCZ->GCZ_CODTPG, "GCU_DESTPG",,.F.)
   GCZ->(DbSkip())
 EndDo                                                         
  
 @ PROW()+01,00  PSAY REPLICATE("-",132)
 @ PROW()+01,00  PSAY STR0015 + GCY->GCY_REGGER + "-" + GCY->GCY_NOME //"Paciente.: "
 @ PROW()   ,70  PSAY STR0016  + DTOC(GBH->GBH_DTNASC) //"Dt.Nasc.: "
 @ PROW()+01,00  PSAY STR0017 + Posicione("GFD",1,xFilial("GFD")+GCY->GCY_CODRES, "GFD_NOME")  //"Resp.....: "
 @ PROW()   ,70  PSAY STR0018  + Alltrim(str(Calc_anos(GBH->GBH_DTNASC, GCY->GCY_DATATE))) //"Idade...: "
 @ PROW()+01,00  PSAY STR0019  + POSICIONE("GBH",1,XFILIAL("GBH")+GCY->GCY_REGGER,"GBH_END") //"Endereco.: "
 @ PROW()   ,70  PSAY STR0020   //"Sexo....: "
                 
 IF GBH->GBH_SEXO=="0"                             
  @ PROW(),PCOL() PSAY STR0021 //"Masculino"
 ELSEIF GBH->GBH_SEXO=="1"
  @ PROW(),PCOL() PSAY STR0022 //"Feminino"
 ELSE
  @ PROW(),PCOL() PSAY "         "
 ENDIF
 
 @ PROW()+01,00  PSAY STR0023 + POSICIONE("GBH",1,XFILIAL("GBH")+GCY->GCY_REGGER,"GBH_BAIRRO") //"Bairro...: "
 @ PROW()   ,70  PSAY STR0024 + POSICIONE("GBH",1,XFILIAL("GBH")+GCY->GCY_REGGER,"GBH_TEL") //"Tel.....: "
 
 @ PROW()+01,00  PSAY STR0025 + AllTrim(POSICIONE("GBH",1,XFILIAL("GBH")+GCY->GCY_REGGER,"GBH_MUN")) + "/" + POSICIONE("GBH",1,XFILIAL("GBH")+GCY->GCY_REGGER,"GBH_EST") //"Cidade/UF: "
 @ PROW()   ,70  PSAY STR0026 + POSICIONE("GBH",1,XFILIAL("GBH")+GCY->GCY_REGGER,"GBH_RG") //"No. Doc.: "
 @ PROW()+01,00  PSAY REPLICATE("-",132)
                                //0         1         2         3         4         5         6         7         8         9        10
                               // 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
 @ PROW()+01,00  PSAY STR0027 //"Data      Dias   Conta   Medico                      CID      Descricao"
                        
 nRecno  := GCY->(Recno())
 nIndGcy := GCY->(INDEXORD())
 cRegGer := GCY->GCY_REGGER
 DbSelectArea("GCY")  // Tabela de Atendimentos.
	DbSetOrder(2)             
			
	If (DbSeek(xFilial("GCY") + cRegGer))   //Monta Vetor Para Imprimir a Cid dos 3 ultimos atendimentos
	 While !Eof() .And. cRegGer == GCY_REGGER
	 	AADD(aVetor,{GCY_REGATE,GCY_DATATE,GCY_CIDALT,Posicione("GAS",1,xFilial("GAS")+GCY->GCY_CIDALT,"GAS_PATOLO"),GCY_CIDCMP,Posicione("SRA",11,xFilial("SRA")+GCY->GCY_CODCRM,"RA_NOME")})
   DBSkip()
	 End
	EndIf 	
			
 DbSelectArea("GCY")  // Tabela de Atendimentos.
	DbSetOrder(nIndGcy)             
	DBGoto(nRecno)
	
	aSort(aVetor,,,{|x,y| x[2] > y[2]})    // Classifica por Data de Atendimento em ordem decrescente.
 For nCont := 1 To Len(aVetor)
  If nCont > 3
   Exit
  EndIf   
  @ PROW()+01,00  PSAY aVetor[nCont,2]
  @ PROW()   ,12  PSAY dDataBase - aVetor[nCont,2]
  @ PROW()   ,16  PSAY aVetor[nCont,1]
  @ PROW()   ,25  PSAY Substr(aVetor[nCont,6],1,26)
  @ PROW()   ,53  PSAY aVetor[nCont,3]             
  @ PROW()   ,62  PSAY Substr(aVetor[nCont,4],1,30)  
  @ PROW()   ,92  PSAY "/"
  @ PROW()   ,93  PSAY Substr(aVetor[nCont,5],1,30)

  nCont := 06 - nCont
   
  @ PROW()+nCont,00  PSAY STR0028 //"Queixa Principal"

  @ PROW()+08,00  PSAY STR0029 //"Exame Fisico"

  @ PROW()+08,00  PSAY STR0030 //"Prescricao Medica"

  @ PROW()+13,00  PSAY STR0002 //"Declaro para os devidos fins que realizei a consulta medica acima"

  @ PROW()+05,00  PSAY "_______________________________                    _____________________________"
  @ PROW()+01,00  PSAY STR0003 //"   Assinatura do Responsavel                           Assinatura do Medico"
 Next
 
 Return(Nil)