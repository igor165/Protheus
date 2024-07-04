#INCLUDE "HSPAHF01.ch"
#include "protheus.CH"
#include "colors.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±   	
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHF01  º Autor ³ Gilson da Silva    º Data ³  04/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Emite Ficha de Prontuário do Paciente                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHF01()
 Local nCont     := 0  
 Local cCab01    := ""    
 Local cProfissao := ""
 Local aCampos := {}
  
 cTitulo   := STR0004 ////"Prontuario do Paciente" 
 cNomeRel  := "HSPAHF01"  
 nLin      := 0 
    
	GBH->(DbSetOrder(1))
	GBH->(DbSeek(xFilial("GBH")+ GCY->GCY_REGGER))

	GCZ->(DbSetOrder(2))
	GCZ->(DbSeek(xFilial("GCZ")+ GCY->GCY_REGATE))
	
	GD4->(DbSetOrder(1))
	GD4->(DbSeek(xFilial("GD4") + GCY->GCY_REGGER + GCZ->GCZ_CODPLA))    
	
	GAV->(DbSetOrder(1))
	GAV->(DbSeek(xFilial("GAV") + GCY->GCY_CODLOC + GCY->GCY_QUAINT + GCY->GCY_LEIINT))    

 If nLastKey == 27
  Return(nil)
 Endif

 nTipo := If(aReturn[4]==1,15,18)    
 
 cCAB01 := STR0009 +  GBH->GBH_CODPAC //"Registro de Admissao: "
  
 Cabec(cTitulo,	cCab01, "", cNomeRel, H44GetTam(), H44GetTip()) 
 nLin:=7  
 
 @ nLin,00 psay Repl("-", 132)
 nLin := nLin + 2
 
 @ nLin,000 psay STR0010  //"Paciente......: "
 @ nLin,016 psay GBH->GBH_NOME      
 @ nLin,065 psay STR0011 //"Atend.....: "   
 @ nLin,077 psay GCY->GCY_REGATE 
 @ nLin,092 psay STR0012 // "Plano..: "
 @ nLin,101 psay Posicione("GCM",2, xFilial("GCM") + GCZ->GCZ_CODPLA, "GCM_DESPLA")
 nLin ++
 
 @ nLin,000 psay STR0013 //"Nascimento....: "
 @ nLin,016 psay Dtoc(GBH->GBH_DTNASC) 
 @ nLin,065 psay STR0014  //"Est. Civil: "
 @ nLin,077 psay Substr(HS_RDescrB("GBH_ESTCIV", GBH->GBH_ESTCIV),1,14) 
 @ nLin,092 psay STR0015 //"Sexo...: "
 @ nLin,101 psay Substr(HS_RDescrB("GBH_SEXO", GBH->GBH_SEXO),1,29)
 nLin++
 
 @ nLin,000 psay STR0016  //"C. P. F.......: "
 @ nLin,016 psay GBH->GBH_CPF
 @ nLin,065 psay STR0017  //"RG........: "
 @ nLin,077 psay GBH->GBH_RG
 nLin++
 
 @ nLin,000 psay STR0019  //"Endereco......: "
 @ nLin,016 psay GBH->GBH_END
 @ nLin,065 psay STR0020  //"N§:.......: "
 @ nLin,077 psay GBH->GBH_NUM  
 nLin++
 
 @ nLin,000 psay STR0021  //"Bairro........: "
 @ nLin,016 psay GBH->GBH_END
 @ nLin,065 psay STR0018  //"C.E.P.....: "
 @ nLin,077 psay GBH->GBH_CEP  
 nLin++                      
 
 @ nLin,000 psay STR0022  //"Cidade........: "
 @ nLin,016 psay GBH->GBH_MUN
 @ nLin,065 psay STR0023  //"U.F.......: "  
 @ nLin,077 psay GBH->GBH_EST  
 nLin++  
 
  
 aCampos := {{"C", "GBH_DSPROF"}}

 If HS_ExisDic(aCampos, .F.)
  cProfissao := HS_IniPadr("GH2", 1, GBH->GBH_PROFIS, "GH2_DESCBO")
 Else
  cProfissao := GBH->GBH_PROFIS
 EndIf

 @ nLin,000 psay STR0024  //"Telefone......: "
 @ nLin,016 psay GBH->GBH_TEL
 @ nLin,065 psay STR0025  //"Profissao.: "
 @ nLin,077 psay AllTrim(cProfissao)
 nLin++                                
 
 @ nLin,000 psay STR0028  //"Titular.......: " 
 @ nLin,016 psay GD4->GD4_NOMTIT 
 @ nLin,065 psay STR0029  //"Matr: "    
 @ nLin,071 psay GD4->GD4_MATRIC
 @ nLin,092 psay STR0031 //"Acompanhante: |  |Sim    |  |Nao"
 nLin++   
 
 @ nLin,000 psay STR0026  //"Entrada.......: "
 @ nLin,016 psay GCY->GCY_DATATE
 @ nLin,065 psay STR0027  //"Hora......:
 @ nLin,077 psay GCY->GCY_HORATE 
 nLin++                         
 
 @ nLin,000 psay STR0030  //"Apto..........: "  
 @ nLin,016 psay Substr(HS_RDescrB("GAV_MODELO", GAV->GAV_MODELO),1,45) 
 @ nLin,065 psay STR0033  //"Acomodacao..: |  |Apto   |  |Suite"
 nLin++     
 
 @ nLin,000 psay STR0032 //"Observacao....: " 
 If !Empty(GCY->GCY_TIPOBS)
  For nCont := 1 to MLCount(GCY->GCY_TIPOBS, 115)
    If nCont > 4
     Exit
    EndIf 
    @ nLin,016 psay MemoLine(GCY->GCY_TIPOBS,115, nCont)
    nLin++
  Next
 EndIf    
 
 nLin:=nLin+2
 @ nLin,005 psay STR0034 //"____________________________"
 @ nLin,075 psay STR0034 //"___________________________ " 
 nLin++
 
 @ nLin,005 psay STR0035 //"  Paciente ou Responsavel" 
 @ nLin,081 psay GCY->GCY_ATENDE  
 nLin:=nLin+2
 
 @ nLin,000 psay Repl("-", 132)
 nLin++
 
 @ nLin,000 psay STR0036 //"QPD "
 @ nLin,004 psay  Repl("_",128)
 nLin++    
 
 @ nLin,000 psay Repl("-", 132)
 nLin++
 
 @ nLin,000 psay STR0037 //"MDA/Antecedentes "
 @ nLin,017 psay  Repl("_",115)
 nLin++    
 
 @ nLin,000 psay Repl("-", 132)
 nLin++
 
 @ nLin,000 psay Repl("-", 132)
 nLin++
 
 @ nLin,000 psay STR0038 //"Exame "
 @ nLin,006 psay  Repl("_",126)
 nLin++    
 
 @ nLin,000 psay Repl("-", 132)
 nLin++
 
 @ nLin,000 psay STR0039 //"Tratamento.: " 
 @ nLin,013 psay  Repl("_",119)
 nLin++                  
         
 @ nLin,000 psay STR0040 //"HD "
 @ nLin,003 psay  Repl("_",129)
 nLin++    
 
 @ nLin,000 psay Repl("-", 132)
 nLin++
 
 @ nLin,000 psay Repl("-", 132)
 nLin++

 @ nLin,000 psay STR0041 //"Diagnostico "
 @ nLin,012 psay  Repl("_",120)
 nLin++    
 
 @ nLin,000 psay Repl("-", 132)
 nLin++
 
 @ nLin,000 psay Repl("-", 132)
 nLin++      
 
 @ nLin,000 psay STR0042 //"Equipe.......: "
 @ nLin,065 psay STR0043 //"Instrumentador: "
 @ nLin,081 psay Repl("_",51)
 nLin++
 
 @ nLin,006 psay STR0044 //"Medico.: " 					
 @ nLin,016 psay Posicione("SRA", 11, xFilial("SRA") + GCY->GCY_CODCRM, "RA_NOME") 
 @ nLin,065 psay STR0045 //"Anestesista: " 	
 @ nLin,080 psay Repl("_",52)
 nLin++

 @ nLin,006 psay STR0046 //"1- Aux.: " 	
 @ nLin,016 psay Repl("_",45)
 @ nLin,065 psay STR0047 //"Pediatra: "
 @ nLin,080 psay Repl("_",52)
 nLin++
 
 @ nLin,006 psay STR0048 //"2§ Aux.: " 	
 @ nLin,016 psay Repl("_",45)
 @ nLin,065 psay STR0049 //"Cardiologista: "
 @ nLin,080 psay Repl("_",52)
 nLin++

 @ nLin,006 psay STR0050 //"3§ Aut.: " 	
 @ nLin,016 psay Repl("_",45)
 @ nLin,065 psay STR0001 //"Outros: "
 @ nLin,080 psay Repl("_",52)
 nLin:=nLin+2
 
 @ nLin,000 psay STR0002 //"Procedimento: "
 @ nLin,014 psay  Repl("_",118)
 nLin++    
 
 @ nLin,000 psay Repl("-", 132)
 nLin++     
 
 @ nLin,000 psay STR0003 //"Descricao Cirurgica: " 		
 @ nLin,021 psay  Repl("_",111)
 nLin++    
 
 For nCont := 1 To 9
  @ nLin,000 psay Repl("-", 132)
  nLin++    
 Next
 
 nLin++
 @ nLin, 000 psay STR0005 //"Condicoes:    |  |Curado         |  |Melhorado         |  |Transferido         |  |Obito         |  |_______________________________ "
 nLin:=nLin+2
 
 @ nLin, 000 psay STR0006 //"Data Alta:______/_______/_________ " 	
 @ nLin, 045 psay STR0007 //"Hora:______:______ "
 nLin:=nLin+2                                                    

 @ nLin, 000 psay STR0008 //"Medico Responsavel: " 		
 @ nLin,020 psay  Repl("_",112)			       
 nLin++
 
 @ nLin,000 psay Repl("-", 132)  
Return(nil)
