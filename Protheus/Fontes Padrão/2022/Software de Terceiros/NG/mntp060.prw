#INCLUDE "MNTP060.ch"
#INCLUDE "PROTHEUS.CH"    
#include "msgraphi.ch"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �MNTP060   � Autor � Elisangela Costa      � Data � 07/03/2007 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Monta array para Painel de Gestao On-Line tipo 4: % Atendi-   ���
���          �mento da O.s                                                  ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �MNTP060()                                                     ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Array = {cText1,nPosIni,nPosFim,{cValor,cLegenda,nColorValor,���
���          � cClick,nPos},{cValor,cLegenda,nColorValor,cClick,nPos}}      ���
���          � cText1      = Texto da Barra                            	    ���
���          � nPosIni     = Valor Inicial                      		    ���
���          � nPosFim     = Valor Final                                    ���
���          � cValor      = Valor a ser exibido                            ���
���          � cLegenda    = Nome da Legenda                                ���
���          � nColorValor = Cor do Valor no formato RGB (opcional)         ���
���          � cClick      = Funcao executada no click do valor (opcional)  ���
���          � nPos        = Valor da Barra                                 ���
���������������������������������������������������������������������������Ĵ��
���Uso       �SIGAMDI                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function MNTP060() 

Local aArea     := GetArea()
Local aAreaSTJ  := STJ->(GetArea())
Local aAreaSTS  := STS->(GetArea())
Local aRetPanel := {}          
Local cMensagem1 := ""
Local cMensagem2 := ""

Private nMesAtual := Month(dDataBase)
Private nAnoAtual := Year(dDataBase)  
Private nMesAnter := Month(dDataBase)
Private nAnoAter  := Year(dDataBase)   
Private dPerIni   := CTOD("  /  /  ")
Private dPerFim   := CTOD(StrZero(F_ULTDIA(dDataBase),2)+"/"+StrZero(nMesAtual,2)+"/"+StrZero(nAnoAtual,4)) 
Private nPerAnMAn := 0, nPerAnMAtu := 0
Private aVetOs  := {0,0,0,0}

nMesAnter -= 1
If nMesAnter = 0
   nMesAnter := 12
   nAnoAter  -= 1
EndIf 
dPerIni := CTOD("01"+"/"+StrZero(nMesAnter,2)+"/"+StrZero(nAnoAter,4))

BeginSql Alias "TRBSTJ"
   Select STJ.TJ_SITUACA,STJ.TJ_TERMINO,STJ.TJ_DTMRFIM,STJ.TJ_DTMPFIM
   From %table:STJ% STJ
   Where STJ.TJ_FILIAL = %xFilial:STJ%
         And (STJ.TJ_DTMPFIM >= %Exp:Dtos(dPerIni)% And STJ.TJ_DTMPFIM <= %Exp:Dtos(dPerFim)%)
         And STJ.TJ_SITUACA = "L" And STJ.%NotDel%						 
   Order by STJ.TJ_SITUACA,STJ.TJ_TERMINO
EndSql
   
BeginSql Alias "TRBSTS"
   Select STS.TS_SITUACA,STS.TS_TERMINO,STS.TS_DTMRFIM,STS.TS_DTMPFIM
   From %table:STS% STS
   Where STS.TS_FILIAL = %xFilial:STS%
         And (STS.TS_DTMPFIM >= %Exp:Dtos(dPerIni)% And STS.TS_DTMPFIM <= %Exp:Dtos(dPerFim)%)
         And STS.TS_SITUACA = "L" And STS.%NotDel%						 
   Order by STS.TS_SITUACA,STS.TS_TERMINO
EndSql
      
dbSelectArea("TRBSTJ")
dbGotop()
While !Eof()
   MNTP60GAR(TRBSTJ->TJ_SITUACA,TRBSTJ->TJ_TERMINO,Stod(TRBSTJ->TJ_DTMRFIM),Stod(TRBSTJ->TJ_DTMPFIM)) 
   dbSkip()
End  
dbSelectArea("TRBSTJ")
dbCloseArea()
   
dbSelectArea("TRBSTS")
dbGotop()
While !Eof()
   MNTP60GAR(TRBSTS->TS_SITUACA,TRBSTS->TS_TERMINO,Stod(TRBSTS->TS_DTMRFIM),Stod(TRBSTS->TS_DTMPFIM)) 
   dbSkip()
End  
dbSelectArea("TRBSTS")
dbCloseArea()

nPerAnMAtu :=  Round(((aVetOs[2]/ aVetOs[1]) * 100),0)
nPerAnMAn  :=  Round(((aVetOs[4]/ aVetOs[3]) * 100),0)

//������������������������������������������������������������������������Ŀ
//�Monta mensagens apresentadas ao clicar no percentual                    �
//��������������������������������������������������������������������������
cMensagem1 := STR0001 + chr(13)+chr(10) //"Calculo (% M�s Anterior)"
cMensagem1 += chr(13) + chr(10)
cMensagem1 += STR0002 + Alltrim(Str(aVetOs[3]))+ chr(13)+chr(10) //"Qtd OS Prevista p/ Concluir M�s Anterior: "
cMensagem1 += STR0003 + Alltrim(Str(aVetOs[4]))+ chr(13)+chr(10) //"Qtd OS Prevista Conclu�da M�s Anterior: "
cMensagem1 += STR0004 + Transform(nPerAnMAn,"@E 999.99") + chr(13)+chr(10) //"% M�s Anterior: "
cMensagem1 += STR0005  //"Formula: (Qtd OS Conclu�da / Qtd OS p/ Concluir) * 100"

cMensagem2 := STR0006 + chr(13)+chr(10) //"Calculo (% M�s Atual)"
cMensagem2 += chr(13) + chr(10)
cMensagem2 += STR0007 + Alltrim(Str(aVetOs[1]))+ chr(13)+chr(10) //"Qtd OS Prevista p/ Concluir M�s Atual: "
cMensagem2 += STR0008 + Alltrim(Str(aVetOs[2]))+ chr(13)+chr(10) //"Qtd OS Prevista Conclu�da M�s Atual: "
cMensagem2 += STR0009 + Transform(nPerAnMAtu,"@E 999.99")+ chr(13)+chr(10) //"% M�s Atual: "
cMensagem2 += STR0005 //"Formula: (Qtd OS Conclu�da / Qtd OS p/ Concluir) * 100"

//������������������������������������������������������������������������Ŀ
//�Preenche array do Painel de Gestao                                      �
//��������������������������������������������������������������������������
aRetPanel := {STR0010,0,100,; //"% Atendimento OS"
		     {{AllTrim(Str(nPerAnMAn))+" %",STR0011,CLR_RED ,{ || MsgInfo(cMensagem1) },nPerAnMAn},;	 //"% M�s Anterior"
	      	 {AllTrim(Str(nPerAnMAtu))+" %",STR0012,CLR_BLUE,{ || MsgInfo(cMensagem2) },nPerAnMAtu}}}	 //"% M�s Atual"
	      	 
RestArea(aAreaSTJ)
RestArea(aAreaSTS)
RestArea(aArea) 

Return aRetPanel 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MNTP60GAR � Autor � Elisangela Costa      � Data �07/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Grava valores na array                                      ��� 
�������������������������������������������������������������������������Ĵ��
���Parametros�cSituac   => Situacao da O.s                                ��� 
���          �cTermin   => Termino da O.s                                 ��� 
���          �dDatMrfi  => Data de manutencao real fim                    ���  
���          �dDatMpFim => Data de manutencao prevista fim                ��� 
�������������������������������������������������������������������������Ĵ��
��� Uso      �MNTP060                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/ 
Function MNTP60GAR(cSituac,cTermin,dDatMrfi,dDatMpFim)  

//Mes Atual
If Month(dDatMpFim) = nMesAtual
   aVetOs[1] += 1  //Qtd O.s prevista para concluir no mes atual  
  
   If cSituac = "L" .And. cTermin = "S" .And. Month(dDatMrfi) = nMesAtual
      aVetOs[2] += 1 //Qtd O.s previstas concluidas no mes atual  
   EndIf 
EndIf 
           
//Mes Aterior
If Month(dDatMpFim) = nMesAnter
   aVetOs[3] += 1  //Qtd O.s prevista para concluir no mes anterior  
  
   If cSituac = "L" .And. cTermin = "S" .And. Month(dDatMrfi) = nMesAnter
      aVetOs[4] += 1 //Qtd O.s previstas concluidas no mes anterior  
   EndIf 
EndIf  

Return .T.