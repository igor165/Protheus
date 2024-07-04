#INCLUDE "HSPAHP23.ch"
#include "protheus.CH"
#include "colors.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHP23  º Autor ³ Manoel             º Data ³  27/05/2002 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Geracao do Arquivo do Boletim                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHP23()


If MsgYesNo(STR0001,STR0002) //"Confirma início da Geracao?"###"Atenção"
   Processa({|| FS_GerArqs() },STR0003) //"Processando..."
Endif

return      

//------------------------------------------------------------------------------------
Static Function FS_GerArqs()

Local i := 0
//cCCvSUS := GetMv("MV_CCVSUS") // Codigo de Convenio do SUS
cCCvSus := AllTim(GetMV("MV_SIHSUS")) + "/" + AllTrim(GetMV("MV_SIASUS"))

//01o Elemento - CGC Hospital                  C 14
//02o Elemento - Nome do Paciente              C 60
//03o Elemento - Logradouro                    C 25
//04o Elemento - Numero                        C 05
//05o Elemento - Complemento                   C 15
//06o Elemento - Codigo do Municipio           C 06
//07o Elemento - Unidade Federativa            C 02
//08o Elemento - CEP                           C 08
//09o Elemento - Data de Nascimento            C 08
//10o Elemento - Sexo                          C 01 Se F = 3,M = 1
//11o Elemento - CNS                           C 11
//12o Elemento - Procedimento Principal        C 08
//13o Elemento - Diagnostico Principal         C 04
//14o Elemento - Diagnostico Secundario        C 04
//15o Elemento - Data da Internacao            C 08
//16o Elemento - Data da Alta                  C 08
//17o Elemento - Tipo da Alta                  C 02
//18o Elemento - Fonte Pagadora                C 01 Se Particular = 1, Se Convenio ( se SUS = 5, senao = 2)
//19o Elemento - Unidade Federativa Hospital   C 02
//20o Elemento - Competencia                   C 06 MMAAAA

aCmpArq := {{"CGC"   , "C", 14, 00}, ;
            {"NOMPAC", "C", 60, 00}, ;
            {"LOGRAD", "C", 25, 00}, ;
            {"NUMERO", "C", 05, 00}, ;
            {"COMPLE", "C", 15, 00}, ;
            {"CIDADE", "C", 06, 00}, ;
            {"UNIDAF", "C", 02, 00}, ;
            {"CEP"   , "C", 08, 00}, ;
            {"DTNASC", "C", 08, 00}, ;
            {"SEXO"  , "C", 01, 00}, ;
            {"CNS"   , "C", 11, 00}, ;
            {"PROPRI", "C", 08, 00}, ;
            {"DIAPRI", "C", 04, 00}, ;
            {"DIASEC", "C", 04, 00}, ;
            {"DATINT", "C", 08, 00}, ;
            {"DATALT", "C", 08, 00}, ;
            {"TIPALT", "C", 02, 00}, ;
            {"FNTPAG", "C", 01, 00}, ;
            {"UFHOSP", "C", 02, 00}, ;
            {"COMPET", "C", 06, 00}}

DbCreate("ARQBOL.DBF",aCmpArq)
DbUseArea(.T., "DBFCDX", "ARQBOL.DBF", "ARQBOL", .T., .F.)

ValidPerg()
while .t.
   if !Pergunte("HSPR30",.t.)
      Return(Nil)
   Endif     
   If Mv_Par01 >= 1 .and. Mv_Par01 <= 12
      If Mv_Par02 >= 2002
         exit
      Else   
	     MsgStop(STR0004,STR0002) //"Ano Inválido"###"Atenção"
      Endif              
   Else   
	  MsgStop(STR0005,STR0002) //"Mes Inválido"###"Atenção"
   Endif     
Enddo


aVetor := {} 
//01o Elemento - CGC Hospital                  C 14
//02o Elemento - Nome do Paciente              C 60
//03o Elemento - Logradouro                    C 25
//04o Elemento - Numero                        C 05
//05o Elemento - Complemento                   C 15
//06o Elemento - Codigo do Municipio           C 06
//07o Elemento - Unidade Federativa            C 02
//08o Elemento - CEP                           C 08
//09o Elemento - Data de Nascimento            C 08
//10o Elemento - Sexo                          C 01 Se F = 3,M = 1
//11o Elemento - CNS                           C 11
//12o Elemento - Procedimento Principal        C 08
//13o Elemento - Diagnostico Principal         C 04
//14o Elemento - Diagnostico Secundario        C 04
//15o Elemento - Data da Internacao            C 08
//16o Elemento - Data da Alta                  C 08
//17o Elemento - Tipo da Alta                  C 02
//18o Elemento - Fonte Pagadora                C 01 Se Particular = 1, Se Convenio ( se SUS = 5, senao = 2)
//19o Elemento - Unidade Federativa Hospital   C 02
//20o Elemento - Competencia                   C 06 MMAAAA

cData   := Strzero(Mv_Par02,4) + StrZero(Mv_Par01,2) + "01"
cData1  := Strzero(Mv_Par02,4) + StrZero(Mv_Par01,2) + "31" // Nao Importa se ha meses sem 31 dias - serve apenas 
cMesAno := StrZero(Mv_Par01,2) + StrZero(Mv_Par02,4)

DbSelectArea("GAD")                                        
DbGoTop()
dbsetorder(14)
DbSeek(xFilial("GAD")+cData,.t.)

//nOrdem := 0

ProcRegua(100)  

While !eof() .and. Dtos(GAD->GAD_DATFEC) >= cData .and. Dtos(GAD->GAD_DATFEC) <= cData1

 	IncProc(STR0006 + AllTrim(GAD->GAD_NOME))	 	 //"Aguarde... Paciente "

    If GAD->GAD_TPALTA $ "99#  " .or. GAD->GAD_ATENDI <> "0" .or. GAD->GAD_EXCLUI == "1"
       DbSkip()
       Loop
    Endif                                          

    cCodPro := Space(08)
    DbSelectArea("GAX")
   	If DbSeek(xFilial("GAX")+GAD->GAD_REGATE)
       DbSelectArea("GAR")
       DbSeek(xFilial("GAR")+GAX->GAX_CODAIH)
       cCodpro := GAR->GAR_CODPRO
    Endif

    cDiag1 := Alltrim(GAD->GAD_CIDALT)
    cDiag1 := If(Len(cDiag1)==0,Space(4),cDiag1)
    cDiag2 := Substring(GAD->GAD_CIDCMP,1,4)
    
    DbSelectArea("SA1")
    DbSetOrder(1)       
    DbSeek(xFilial("SA1")+GAD->GAD_REGGER)
    DbSelectArea("GBH")
    DbSetOrder(1)       
    DbSeek(xFilial("GBH")+GAD->GAD_REGGER)
    cSexo   := If(GBH->GBH_SEXO=="1","3","1")
    cCNS    := Space(11) // Campo exclusivo do SUS

    DbSelectArea("GAM")
    DbSetOrder(1)       
    cCodMun := Space(6)
    If DbSeek(xFilial("GAM")+Alltrim(GBH->GBH_MUN))
       cCodMun := Substring(GAM->GAM_CODIGO,1,6)
    Endif   

    DbSelectArea("GA9")
   	DbSeek(xFilial("GA9")+GAD->GAD_CODCON)
	   If HS_RCfgCP(GAD->GAD_CODCON, GAD->GAD_CODPLA, "_TIPCON") == "0" // Convenios
	    If GA9->GA9_CODCON $ cCCvSUS
	     cFntRem := "5" // SUS
	    Else
	     cFntRem := "2" // Convenios
	    Endif
	   Else 
	    cFntRem := "1" // Particular
	   Endif
    
    If Alltrim(GAD->GAD_NOME) == ""
       MsgStop(STR0007+GAD->GAD_REGGER+STR0008,STR0002) //"Nome de Paciente Inválido para o RGP "###"! Impossível continuar a Geração do Arquivo!"###"Atenção"
       DbSelectArea("ARQBOL")
       DbCloseArea()
       dele file ("ARQBOL.DBF") 
       Return
    Endif                 
    If Alltrim(cCodMun) == ""
       MsgStop(STR0009+GAD->GAD_REGGER+STR0008,STR0002) //"Código do Município Inválido para o RGP "###"! Impossível continuar a Geração do Arquivo!"###"Atenção"
       DbSelectArea("ARQBOL")
       DbCloseArea()
       dele file ("ARQBOL.DBF") 
       Return
    Endif                 
    If Alltrim(GBH->GBH_EST) == ""
       MsgStop(STR0010+GAD->GAD_REGGER+STR0008,STR0002) //"Unidade Federativa Inválida para o RGP "###"! Impossível continuar a Geração do Arquivo!"###"Atenção"
       DbSelectArea("ARQBOL")
       DbCloseArea()
       dele file ("ARQBOL.DBF") 
       Return
    Endif                 
    If Alltrim(GBH->GBH_CEP) == ""
       MsgStop(STR0011+GAD->GAD_REGGER+STR0008,STR0002) //"C.E.P. Inválido para o RGP "###"! Impossível continuar a Geração do Arquivo!"###"Atenção"
       DbSelectArea("ARQBOL")
       DbCloseArea()
       dele file ("ARQBOL.DBF") 
       Return
    Endif                 
    If GBH->GBH_DTNASC == Ctod("")
       MsgStop(STR0012+GAD->GAD_REGGER+STR0008,STR0002) //"Data de Nascimento Inválida para o RGP "###"! Impossível continuar a Geração do Arquivo!"###"Atenção"
       DbSelectArea("ARQBOL")
       DbCloseArea()
       dele file ("ARQBOL.DBF") 
       Return
    Endif                 
    If Alltrim(GBH->GBH_SEXO) == ""
       MsgStop(STR0013+GAD->GAD_REGGER+STR0008,STR0002) //"Sexo Inválido para o RGP "###"! Impossível continuar a Geração do Arquivo!"###"Atenção"
       DbSelectArea("ARQBOL")
       DbCloseArea()
       dele file ("ARQBOL.DBF") 
       Return
    Endif                 
    If Alltrim(cCodPro) == ""
       MsgStop(STR0014+GAD->GAD_REGATE+STR0008,STR0002) //"Código de Procedimento Inválido para o Paciente "###"! Impossível continuar a Geração do Arquivo!"###"Atenção"
       DbSelectArea("ARQBOL")
       DbCloseArea()
       dele file ("ARQBOL.DBF") 
       Return
    Endif                 
    If Alltrim(cDiag1) == ""
       MsgStop(STR0015+GAD->GAD_REGATE+STR0008,STR0002) //"Código CID Principal Inválido para o Paciente "###"! Impossível continuar a Geração do Arquivo!"###"Atenção"
       DbSelectArea("ARQBOL")
       DbCloseArea()
       dele file ("ARQBOL.DBF") 
       Return
    Endif                 
    If GAD->GAD_DATATE == Ctod("")
       MsgStop(STR0016+GAD->GAD_REGATE+STR0008,STR0002) //"Data de Atendimento Inválida para o Paciente "###"! Impossível continuar a Geração do Arquivo!"###"Atenção"
       DbSelectArea("ARQBOL")
       DbCloseArea()
       dele file ("ARQBOL.DBF") 
       Return
    Endif                 
    If GAD->GAD_DATALT == Ctod("")
       MsgStop(STR0017+GAD->GAD_REGATE+STR0008,STR0002) //"Data de Alta Inválida para o Paciente "###"! Impossível continuar a Geração do Arquivo!"###"Atenção"
       DbSelectArea("ARQBOL")
       DbCloseArea()
       dele file ("ARQBOL.DBF") 
       Return
    Endif                 
    If GAD->GAD_TPALTA == ""
       MsgStop(STR0018+GAD->GAD_REGATE+STR0008,STR0002) //"Tipo de Alta Inválido para o Paciente "###"! Impossível continuar a Geração do Arquivo!"###"Atenção"
       DbSelectArea("ARQBOL")
       DbCloseArea()
       dele file ("ARQBOL.DBF") 
       Return
    Endif                 

    aadd(aVetor,{SM0->M0_CGC,GAD->GAD_NOME+Space(15),Substring(GBH->GBH_END,1,25),Strzero(Val(GBH->GBH_NUM),5),Space(15),cCodMun,GBH->GBH_EST,GBH->GBH_CEP,Dtos(GBH->GBH_DTNASC),cSexo,cCNS,cCodPro,;
                 cDiag1,cDiag2,Dtos(GAD->GAD_DATATE),Dtos(GAD->GAD_DATALT),GAD->GAD_TPALTA,cFntRem,"SP",cMesAno})

    DbSelectArea("GAD")
    
    DbSkip()
    
Enddo


If Len(aVetor) > 0                 

   If  MsgYesNo(STR0019) //"Insira o Disquete no Drive A e tecle OK para gravar o Arquivo!"

	   DbSelectArea("ARQBOL")
       For i := 1 to Len(aVetor)
		    RecLock("ARQBOL",.t.)
			CGC    := aVetor[i,01]
			NOMPAC := aVetor[i,02]
			LOGRAD := aVetor[i,03]
			NUMERO := aVetor[i,04]
			COMPLE := aVetor[i,05]
			CIDADE := aVetor[i,06]
			UNIDAF := aVetor[i,07]
			CEP    := aVetor[i,08]
			DTNASC := aVetor[i,09]
			SEXO   := aVetor[i,10]
			CNS    := aVetor[i,11]
			PROPRI := aVetor[i,12]
			DIAPRI := aVetor[i,13]
			DIASEC := aVetor[i,14]
			DATINT := aVetor[i,15]
			DATALT := aVetor[i,16]
			TIPALT := aVetor[i,17]
			FNTPAG := aVetor[i,18]
			UFHOSP := aVetor[i,19]
			COMPET := aVetor[i,20]
		    MsUnlock()
	   Next
	   
	   cArquivo := "A:\"+Substring(cMesAno,1,2)+Substring(cMesAno,5,2)+"1501.CIH"
	   Copy TO &cArquivo SDF
	   
   Endif
   
   DbSelectArea("ARQBOL")
   DbCloseArea()
   dele file ("ARQBOL.DBF")  
   
Else 

    MsgStop(STR0020,STR0002) //"Não há Dados a serem gerados neste Periodo!"###"Atenção"
    DbSelectArea("ARQBOL")
    DbCloseArea()
    dele file ("ARQBOL.DBF") 
    Return
    
Endif


Return(nil)


/*-----------------------------------------------------------------------------
	Função   VALIDPERG    
    Descrição Verifica e inclui as perguntas no sx1   
------------------------------------------------------------------------------*/
Static Function ValidPerg
 Local j :=0, i:= 0
_sAlias := Alias()                                                                                                                                              
dbSelectArea("SX1")
dbSetOrder(1)
aRegs :={}

AADD(aRegs,{"HSPR30","01"	,STR0021	,"                "		,"                "		,"mv_ch1"	,"N"	,2			,0			,0		,"G"	,""		,"mv_par01"		,""		,""		,""		,""		,""		,""		,""		,""		,""		,""		,""		,""		,""		,""		,"","","","","","","","","","","",""}) //"Informe o Mes "
AADD(aRegs,{"HSPR30","02"	,STR0022	,"                "		,"                "		,"mv_ch2"	,"N"	,4			,0			,0		,"G"	,""		,"mv_par02"		,""		,""		,""		,""		,""		,""		,""		,""		,""		,""		,""		,""		,""		,""		,"","","","","","","","","","","",""}) //"Informe o Ano "

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

