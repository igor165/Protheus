#INCLUDE "HSPAHF03.ch"
#include "protheus.CH"
#include "colors.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±   	
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHF03  º Autor ³ Gilson da Silva    º Data ³  04/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Imprime Ficha de Solicitacao de Procedimento               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHF03()
 Local nCont     := 0  
 Local cCab01    := ""    
  
 cTitulo   := STR0019 //"SOLICITACAO DE PROCEDIMENTOS"
 cNomeRel  := "HSPAHF03"  
 nLin      := 0 
    
	GBH->(DbSetOrder(1))
	GBH->(DbSeek(xFilial("GBH")+ GCY->GCY_REGGER))

	GCZ->(DbSetOrder(2))
	GCZ->(DbSeek(xFilial("GCZ")+ GCY->GCY_REGATE))
	
 If nLastKey == 27
  Return(nil)
 Endif

 nTipo := If(aReturn[4]==1,15,18)    
 
 cCAB01 := STR0001 //"FORMULARIO DE SOLICITACAO DE PROCEDIMENTOS QUE NECESSITAM AUTORIZACAO PREVIA" 
  
 Cabec(cTitulo,	cCab01, "", cNomeRel, H44GetTam(), H44GetTip()) 
 nLin:=7 
 
 @ nLin,00 psay Repl("-", 132)     // A variavel cLin foi declarada como private no fonte HSPAHP44.
 nLin ++

 @ nLin,000 psay STR0002//"Paciente......: "
 @ nLin,016 psay GBH->GBH_NOME      
 @ nLin,064 psay STR0003 //"Registro de Atendto: "   
 @ nLin,085 psay GCY->GCY_REGATE     
 @ nLin,105 psay STR0020 //"Prontuario: "
 @ nLin,116 psay GCY->GCY_REGGER 
 nLin ++
 
 @ nLin,000 psay STR0004 //"Convenio......:
 @ nLin,016 psay Posicione("GA9",1, xFilial("GA9") + GCZ->GCZ_CODCON, "GA9_NOME")
 @ nLin,073 psay STR0005 //"Plano.....: "
 @ nLin,085 psay Posicione("GCM",2, xFilial("GCM") + GCZ->GCZ_CODPLA, "GCM_DESPLA")
 nLin ++
 @ nLin,000 psay STR0006//"Medico........: " 					
 @ nLin,016 psay Posicione("SRA", 11, xFilial("SRA") + GCY->GCY_CODCRM, "RA_NOME") 
 nLin ++

 @ nLin,000 psay Repl("-", 132)                    
 nLin ++
 
 @ nLin,000 psay STR0007 //"1 - Materia(l)(is) de alto custo - Especificar:" 
 nLin := nLin + 2
 
 @ nLin,000 psay STR0008 //"    Justificativa: "
 @ nLin,018 psay Replicate("_",113)
 nLin := nLin + 2 
 
 For nCont:= 1 To 3
  @ nLin,000 psay Repl("-", 132)                    
  nLin := nLin + 2
 Next
 
 @ nLin,000 psay STR0009 // "Data: _______/_______/__________      Medico Solicitante:                                     Auditor: "  
 nLin++
 
 @ nLin,000 psay Repl("-", 132)  
 nLin++ 
   
 @ nLin,000 psay STR0010 //"2 - Mudanca de Procedimento:"  
 nLin++
 
 @ nLin,000 psay STR0008 //"    Justificativa: "
 @ nLin,018 psay Replicate("_",113)
 nLin := nLin + 2  
 
 For nCont:= 1 To 3
  @ nLin,000 psay Repl("-", 132)                    
  nLin := nLin + 2
 Next
 
 @ nLin,000 psay STR0009 // "Data: _______/_______/__________      Medico Solicitante:                                     Auditor: "  
 nLin++
 
 @ nLin,000 psay Repl("-", 132)  
 nLin++ 

 @ nLin,000 psay STR0011 //"3 - Consulta Especialista - Especificar:"
 nLin++
 
 @ nLin,000 psay STR0008 //"    Justificativa: "
 @ nLin,018 psay Replicate("_",113)
 nLin := nLin + 2   
 
 For nCont:= 1 To 3
  @ nLin,000 psay Repl("-", 132)                    
  nLin := nLin + 2
 Next
 
 @ nLin,000 psay STR0009 // "Data: _______/_______/__________      Medico Solicitante:                                     Auditor: "  
 @ nLin++
 
 @ nLin,000 psay Repl("-", 132)  
 nLin++ 
 
 @ nLin,000 psay STR0012 //"4 - Consulta Especialista - Especificar:"
 nLin++
 
 @ nLin,000 psay STR0008 //"    Justificativa: "
 @ nLin,018 psay Replicate("_",113)
 nLin := nLin + 2   
 
 For nCont:= 1 To 3
  @ nLin,000 psay Repl("-", 132)                    
  nLin := nLin + 2
 Next
 
 @ nLin,000 psay STR0009 // "Data: _______/_______/__________      Medico Solicitante:                                     Auditor: "  
 nLin++
 
 @ nLin,000 psay Repl("-", 132)  
 nLin++
 
 @ nLin,000 psay STR0013 //"Para os Convenios abaixo, utilizar formularios proprios"
 nLin ++
 
 @ nLin,000 psay STR0014 //"Amil (Exames Especiais)"
 nLin++
 
 @ nLin,000 psay STR0015 //"Unimed Federacao (Todos Exames e Mudanca de Procedimento"
 nLin++
 
 @ nLin,000 psay STR0016 //"HapVida (Todos os exames e procedimentos)"
 nLin++
 
 @ nLin,000 psay STR0017 //"Saude Bradesco (Mudanca de Procedimento)"
 nLin++
 
 @ nLin,000 psay STR0018 //"Petrobras (Procedimentos)" 
 
Return(nil)
