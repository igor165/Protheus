#INCLUDE "HSPAHF02.ch"
#include "protheus.CH"
#include "colors.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±   	
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHF02  º Autor ³ Gilson da Silva    º Data ³  06/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Emite Ficha de Termo de Responsabilidade                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ EXPc1 = Codigo do termo de Responsabilidade                ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±  
±±ºAlterações³ L.Gustavo Caloi 28/03/06 -> Padronização da HS_MsgInf()    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HSPAHF02(cCodter)
 Local nCont     := 0    
 
 nLin      := 0 
 cNomeRel  := "HSPAHF02"
 cTitulo   := STR0004 ////"Termo de Responsabilidade"
	
	GDW->(DbSetOrder(1))
	If !(GDW->(DbSeek(xFilial("GDW")+ cCodTer)))
	 HS_MsgInf(STR0008, STR0022, STR0004) //"Termo de Responsabilidade não encontrado, Verifique na Tabela <GDW>"###"Atenção"###"Termo de Resp."
	EndIf 

	GBH->(DbSetOrder(1))
	GBH->(DbSeek(xFilial("GBH")+ GCY->GCY_REGGER))

	GCZ->(DbSetOrder(2))
	GCZ->(DbSeek(xFilial("GCZ")+ GCY->GCY_REGATE))
	
	GAV->(DbSetOrder(1))
	GAV->(DbSeek(xFilial("GAV") + GCY->GCY_CODLOC + GCY->GCY_QUAINT + GCY->GCY_LEIINT))    

 If nLastKey == 27
  Return(nil)
 Endif

 Cabec(cTitulo,GDW->GDW_DESCRI, "", cNomeRel, H44GetTam(), H44GetTip()) 
 nLin:=8  

 @ nLin,000 psay STR0010  //"Nome do Paciente" 
 @ nLin,070 psay STR0013 //"Data de Nascimento"
 nLin++
 @ nLin,000 psay GBH->GBH_NOME   
 @ nLin,070 psay Dtoc(GBH->GBH_DTNASC)    
 nLin := nLin + 2

 @ nLin,000 psay STR0019  //"Endereco"
 @ nLin,070 psay STR0020  //"Numero" 
	@ nLin,100 psay STR0021  //"Bairro"
	nLin++
 @ nLin,000 psay GBH->GBH_END
 @ nLin,070 psay GBH->GBH_NUM      
 @ nLin,100 psay GBH->GBH_BAIRRO
 nLin := nLin + 2
    
 @ nLin,000 psay STR0006  //"CEP"   
 @ nLin,070 psay STR0001  //"Municipio"
 @ nLin,100 psay STR0002  //"UF"  
 nLin++ 
 @ nLin,000 psay GBH->GBH_CEP  
 @ nLin,070 psay GBH->GBH_MUN
 @ nLin,100 psay GBH->GBH_EST  
 nLin := nLin + 2 
 
 @ nLin,000 psay STR0003  //"Telefone"
 @ nLin,070 psay STR0016  //"CPF"
 @ nLin,100 psay STR0017  //"Identidade"
 nLin++ 
 @ nLin,000 psay GBH->GBH_TEL
 @ nLin,070 psay GBH->GBH_CPF
 @ nLin,100 psay GBH->GBH_RG 
 nLin := nLin + 2  
 
 @ nLin,000 psay STR0011 //"Data Internacao"  
	@ nLin,040 psay STR0014 //"Prontuario"
 @ nLin,070 psay STR0012 //"Plano" 
 @ nLin,100 psay STR0015 //"Apto" 
	nLin++ 
 @ nLin,000 psay Dtoc(GCY->GCY_DATATE)    
 @ nLin,040 psay GBH->GBH_CODPAC
 @ nLin,070 psay Substr(Posicione("GCM",2, xFilial("GCM") + GCZ->GCZ_CODPLA, "GCM_DESPLA"),1,27)
 @ nLin,100 psay Substr(HS_RDescrB("GAV_MODELO", GAV->GAV_MODELO),1,31)    
 
 nLin ++     
 @ nLin,000 psay Repl("-", 132)  
 nLin := nLin + 2   

 If !Empty(GDW->GDW_TEXTO)
  For nCont := 1 to MLCount(GDW->GDW_TEXTO, 130)
    If nCont > 21
     Exit
    EndIf 
    @ nLin,000 psay MemoLine(GDW->GDW_TEXTO, 130, nCont)
    nLin++
  Next
 EndIf    

 nLin++
 If nLin < 47
  nLin := 47
 EndIf 
 @ nLin,000 psay Repl("-", 132)
 nLin := nLin +2
   
 @ nLin,000 psay STR0005 //"Responsavel"              
 @ nLin,050 psay STR0003 //"Telefone" 
 @ nLin,068 psay STR0016  //"CPF"  
 nLin++
 @ nLin,000 psay Posicione("GFD",1,xFilial("GFD")+GCY->GCY_CODRES, "GFD_NOME") 
 @ nLin,050 psay GFD->GFD_TEL 
 @ nLin,068 psay GFD->GFD_CPF
 nLin ++

 nLin := nLin + 3 
           
 @ nLin,000 psay STR0018 //"_____________________________________"                
 @ nLin,060 psay STR0018 //"_____________________________________"   
 nLin++
 @ nLin,007 psay STR0007 //"Assinatura Responsavel"   
 @ nLin,069 psay STR0009 //"HOSPITAL -  CARIMBO" 
Return(nil)
