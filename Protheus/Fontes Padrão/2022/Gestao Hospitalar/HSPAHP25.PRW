#INCLUDE "HSPAHP25.ch"
#include "protheus.CH"
#include "colors.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHP25  º Autor ³ Manoel             º Data ³  28/06/2002 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Geracao do Arquivo para Avaliacao de custos X receitas     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHP25()

aVetCodG := {}

ValidPerg()
if !Pergunte("HSPP25",.t.)
	Return(Nil)
Endif

Processa({||Fs_P25()})

Return

Static Function FS_P25()


// Limpa Arquivo
IF Ma280Flock("GBR")
//IF AbreExcl("GBR")
	DbClearFilter()
	DbClearInd()
	OpenIndx("GBR",.F.)
	Zap
	DbCloseArea()
Endif

// Seleciona arquivo de resultado
DbSelectArea("GBR")

ChkFile("GBR",.F.)


DbSelectArea("GAD")
dbsetorder(16)
dbseek(xFilial("GAD")+Dtos(Mv_Par01),.t.)

nTreg := Reccount()

ProcRegua(nTReg)

While !eof() .and. GAD->GAD_FILIAL == xFilial("GAD") .and. (GAD->GAD_DATFAT >= Mv_Par01 .and. GAD->GAD_DATFAT <= Mv_Par02)
	
	DbSelectArea("GA9")
	dbsetorder(1)
	dbseek(xFilial("GA9")+GAD->GAD_CODCON)
	
	IncProc(STR0001 + GAD->GAD_NOME) //"Paciente "
	
	// Levanta Valores de Procedimentos e Honorarios Medicos (nao Faturados)
	DbSelectArea("GAO")
	dbsetorder(6)
	dbseek(xFilial("GAO")+GAD->GAD_REGATE)
	While !eof() .and. GAO->GAO_FILIAl+GAO->GAO_REGATE == xFilial("GAO")+GAD->GAD_REGATE
		
		If  HS_RCfgCP(GAD->GAD_CODCON, GAD->GAD_CODPLA, "_TIPCON", GAO->GAO_DATDES) <> "0" // PARTICULAR
			If !GAO->GAO_GLODES $ "2/3/0"
				DbSkip()
				Loop
			Endif
		Else
			If GAO->GAO_GLODES <> "0"
				DbSkip()
				Loop
			Endif
		Endif
		
		DbSelectArea("GA7")
		DbSetOrder(1)
		DbSeek(xFilial("GA7")+GAO->GAO_CODPRO)
		
		DbSelectArea("GAW")
		DbSetOrder(1)
		DbSeek(xFilial("GAW")+GA7->GA7_CODGDE)
		
		cMedico := If(Empty(GAO->GAO_CODCRM),GAD->GAD_CODCRM,GAO->GAO_CODCRM)
		
		DbSelectArea("SRA")
		DbSetOrder(11)
		DbSeek(xFilial("SRA")+cMedico)
		
		DbSelectArea("GBR")
		DbSetOrder(1)
		wProcura := DbSeek(xFilial("GBR") + GAD->GAD_REGATE + GA7->GA7_CODGDE + cMedico + GAO->GAO_CODCCU)
		RecLock("GBR",If(wProcura,.f.,.t.))
		GBR->GBR_FILIAL := xFilial("GBR")
		GBR->GBR_REGATE := GAD->GAD_REGATE
		GBR->GBR_NOME   := GAD->GAD_NOME
		GBR->GBR_DTIFAT := Mv_Par01
		GBR->GBR_DTFFAT := Mv_Par02
		GBR->GBR_DATFAT := GAD->GAD_DATFAT
		GBR->GBR_CODGDE := GA7->GA7_CODGDE
		GBR->GBR_GRUDES := GAW->GAW_DESC
		GBR->GBR_CODCON := GAD->GAD_CODCON
		GBR->GBR_NOMCON := GA9->GA9_NREDUZ
		GBR->GBR_CODCCU := GAO->GAO_CODCCU
		GBR->GBR_DESCCU := HS_RDescCC(GAO->GAO_CODCCU)
		GBR->GBR_CODCRM := cMedico
		GBR->GBR_NOMMED := SRA->RA_NOME
		GBR->GBR_VLCUSH := GBR->GBR_VLCUSH + (GAO->GAO_PCUPRO*GAO->GAO_QTDPRO)
		MsUnlock()
		
		DbSelectArea("GAO")
		DbSkip()
		
	Enddo
	
	// Levanta Valores de Medicamentos e Materiais (nao Faturados)
	DbSelectArea("GAK")
	dbsetorder(7)
	dbseek(xFilial("GAK")+GAD->GAD_REGATE)
	while !eof() .and. GAK->GAK_FILIAl+GAK->GAK_REGATE == xFilial("GAK")+GAD->GAD_REGATE
		
		If  HS_RCfgCP(GAD->GAD_CODCON, GAD->GAD_CODPLA, "_TIPCON", GAK->GAK_DATMAT) <> "0" // PARTICULAR
			If !GAK->GAK_GLOMAT $ "2/3/0"
				DbSkip()
				Loop
			Endif
		Else
			If GAK->GAK_GLOMAT <> "0"
				DbSkip()
				Loop
			Endif
		Endif
		
		DbSelectArea("GBI")
		DbSetOrder(1)
		DbSeek(xFilial("GBI")+GAK->GAK_CODMAT)
		
		DbSelectArea("GAW")
		DbSetOrder(1)
		DbSeek(xFilial("GAW")+GBI->GBI_CODGDE)
		
		DbSelectArea("SRA")
		DbSetOrder(11)
		DbSeek(xFilial("SRA")+GAD->GAD_CODCRM)
		
		DbSelectArea("GBR")
		DbSetOrder(1)
		wProcura := DbSeek(xFilial("GBR") + GAD->GAD_REGATE + GBI->GBI_CODGDE + GAD->GAD_CODCRM + GAK->GAK_CODCCU)
		RecLock("GBR",If(wProcura,.f.,.t.))
		GBR->GBR_FILIAL := xFilial("GBR")
		GBR->GBR_REGATE := GAD->GAD_REGATE
		GBR->GBR_NOME   := GAD->GAD_NOME
		GBR->GBR_DTIFAT := Mv_Par01
		GBR->GBR_DTFFAT := Mv_Par02
		GBR->GBR_DATFAT := GAD->GAD_DATFAT
		GBR->GBR_CODGDE := GBI->GBI_CODGDE
		GBR->GBR_GRUDES := GAW->GAW_DESC
		GBR->GBR_CODCON := GAD->GAD_CODCON
		GBR->GBR_NOMCON := GA9->GA9_NREDUZ
		GBR->GBR_CODCCU := GAK->GAK_CODCCU
		GBR->GBR_DESCCU := HS_RDescCC(GAK->GAK_CODCCU)
		GBR->GBR_CODCRM := GAD->GAD_CODCRM
		GBR->GBR_NOMMED := SRA->RA_NOME
		GBR->GBR_VLCUSM := GBR->GBR_VLCUSM + (GAK->GAK_PCUMAT*GAK->GAK_QTDMAT)
		MsUnlock()
		
		DbSelectArea("GAK")
		DbSkip()
		
	Enddo
	
	// Levanta Valores de Taxas e Diarias (nao Faturados)
	DbSelectArea("GAL")
	dbsetorder(6)
	dbseek(xFilial("GAL")+GAD->GAD_REGATE)
	while !eof() .and. GAL->GAL_FILIAl+GAL->GAL_REGATE == xFilial("GAL")+GAD->GAD_REGATE
		
		If  HS_RCfgCP(GAD->GAD_CODCON, GAD->GAD_CODPLA, "_TIPCON", GAL->GAL_DATDES) <> "0" // PARTICULAR
			If !GAL->GAL_GLOTAX $ "2/3/0"
				DbSkip()
				Loop
			Endif
		Else
			If GAL->GAL_GLOTAX <> "0"
				DbSkip()
				Loop
			Endif
		Endif
		
		DbSelectArea("GAA")
		DbSetOrder(1)
		DbSeek(xFilial("GAA")+GAL->GAL_CODTAX)
		
		DbSelectArea("GAW")
		DbSetOrder(1)
		DbSeek(xFilial("GAW")+GAA->GAA_CODGDE)
		
		DbSelectArea("SRA")
		DbSetOrder(11)
		DbSeek(xFilial("SRA")+GAD->GAD_CODCRM)
		
		DbSelectArea("GBR")
		DbSetOrder(1)
		wProcura := DbSeek(xFilial("GBR") + GAD->GAD_REGATE + GAA->GAA_CODGDE + GAD->GAD_CODCRM + GAL->GAL_CODCCU)
		RecLock("GBR",If(wProcura,.f.,.t.))
		GBR->GBR_FILIAL := xFilial("GBR")
		GBR->GBR_REGATE := GAD->GAD_REGATE
		GBR->GBR_NOME   := GAD->GAD_NOME
		GBR->GBR_DTIFAT := Mv_Par01
		GBR->GBR_DTFFAT := Mv_Par02
		GBR->GBR_DATFAT := GAD->GAD_DATFAT
		GBR->GBR_CODGDE := GAA->GAA_CODGDE
		GBR->GBR_GRUDES := GAW->GAW_DESC
		GBR->GBR_CODCON := GAD->GAD_CODCON
		GBR->GBR_NOMCON := GA9->GA9_NREDUZ
		GBR->GBR_CODCCU := GAL->GAL_CODCCU
		GBR->GBR_DESCCU := HS_RDescCC(GAL->GAL_CODCCU)
		GBR->GBR_CODCRM := GAD->GAD_CODCRM
		GBR->GBR_NOMMED := SRA->RA_NOME
		GBR->GBR_VLCUST := GBR->GBR_VLCUST + (GAL->GAL_PCUTAX*GAL->GAL_QTDTAX)
		MsUnlock()
		
		DbSelectArea("GAL")
		DbSkip()
		
	Enddo
	
	*****************************************************
	
	// Levanta Valores de Procedimentos e Honorarios Medicos (Faturados)
	DbSelectArea("GBO")
	dbsetorder(6)
	dbseek(xFilial("GBO")+GAD->GAD_REGATE)
	while !eof() .and. GBO->GBO_FILIAl+GBO->GBO_REGATE == xFilial("GBO")+GAD->GAD_REGATE
		
		If  HS_RCfgCP(GAD->GAD_CODCON, GAD->GAD_CODPLA, "_TIPCON", GBO->GBO_DATDES) <> "0" // Particular
			If !GBO->GBO_GLODES $ "2/3/0"
				DbSkip()
				Loop
			Endif
		Else
			If GBO->GBO_GLODES <> "0"
				DbSkip()
				Loop
			Endif
		Endif
		
		DbSelectArea("GA7")
		DbSetOrder(1)
		DbSeek(xFilial("GA7")+GBO->GBO_CODPRO)
		
		DbSelectArea("GAW")
		DbSetOrder(1)
		DbSeek(xFilial("GAW")+GA7->GA7_CODGDE)
		
		nValGlo := 0
		nPos := Ascan(aVetCodG,{|x| x[1] == GA7->GA7_CODGDE})
		If  !nPos > 0
			DbSelectArea("GBG")
			dbsetorder(1)
			If dbseek(xFilial("GBG")+GAD->GAD_REGATE+GA7->GA7_CODGDE)
				nValGlo := GBG->GBG_VALGLO
			Endif
			aadd(aVetCodG,{GA7->GA7_CODGDE})
		Endif
		
		cMedico := If(Empty(GBO->GBO_CODCRM),GAD->GAD_CODCRM,GBO->GBO_CODCRM)
		DbSelectArea("SRA")
		DbSetOrder(11)
		DbSeek(xFilial("SRA")+cMedico)
		//		    DbSeek(xFilial("SRA")+cMedico+'1')
		
		DbSelectArea("GBR")
		DbSetOrder(1)
		wProcura := DbSeek(xFilial("GBR")+GAD->GAD_REGATE+GA7->GA7_CODGDE+cMedico+GBO->GBO_CODCCU)
		MsUnlock()
		RecLock("GBR",If(wProcura,.f.,.t.))
		GBR->GBR_FILIAL := xFilial("GBR")
		GBR->GBR_REGATE := GAD->GAD_REGATE
		GBR->GBR_NOME   := GAD->GAD_NOME
		GBR->GBR_DTIFAT := Mv_Par01
		GBR->GBR_DTFFAT := Mv_Par02
		GBR->GBR_DATFAT := GAD->GAD_DATFAT
		GBR->GBR_CODGDE := GA7->GA7_CODGDE
		GBR->GBR_GRUDES := GAW->GAW_DESC
		GBR->GBR_CODCON := GAD->GAD_CODCON
		GBR->GBR_NOMCON := GA9->GA9_NREDUZ
		GBR->GBR_CODCCU := GBO->GBO_CODCCU
		GBR->GBR_DESCCU := HS_RDescCC(GBO->GBO_CODCCU)
		GBR->GBR_CODCRM := cMedico
		GBR->GBR_NOMMED := SRA->RA_NOME
		GBR->GBR_VLRECH := GBR->GBR_VLRECH + (GBO->GBO_VALPRO*GBO->GBO_QTDPRO)
		GBR->GBR_VLGLOH := GBR->GBR_VLGLOH + nValGlo
		GBR->GBR_VLRESH := GBR->GBR_VLRECH - (GBR->GBR_VLCUSH+GBR->GBR_VLGLOH)
		//              GBR->GBR_VLTGLO := GBR->GBR_VLGLOH
		//              GBR->GBR_VLTREC := GBR->GBR_VLRECH
		MsUnlock()
		
		DbSelectArea("GBO")
		DbSkip()
		
	Enddo
	
	// Levanta Valores de Medicamentos e Materiais (Faturados)
	DbSelectArea("GBK")
	dbsetorder(7)
	dbseek(xFilial("GBK")+GAD->GAD_REGATE)
	while !eof() .and. GBK->GBK_FILIAl+GBK->GBK_REGATE == xFilial("GBK")+GAD->GAD_REGATE
		
		If  HS_RCfgCP(GAD->GAD_CODCON, GAD->GAD_CODPLA, "_TIPCON", GBK->GBK_DATMAT) <> "0" // PARTICULAR
			If !GBK->GBK_GLOMAT $ "2/3/0"
				DbSkip()
				Loop
			Endif
		Else
			If GBK->GBK_GLOMAT <> "0"
				DbSkip()
				Loop
			Endif
		Endif
		
		DbSelectArea("GBI")
		DbSetOrder(1)
		DbSeek(xFilial("GBI")+GBK->GBK_CODMAT)
		
		DbSelectArea("GAW")
		DbSetOrder(1)
		DbSeek(xFilial("GAW")+GBI->GBI_CODGDE)
		
		DbSelectArea("SRA")
		DbSetOrder(11)
		DbSeek(xFilial("SRA")+GAD->GAD_CODCRM)
		
		nValGlo := 0
		nPos := Ascan(aVetCodG,{|x| x[1] == GBI->GBI_CODGDE})
		If  !nPos > 0
			DbSelectArea("GBG")
			dbsetorder(1)
			If dbseek(xFilial("GBG")+GAD->GAD_REGATE+GBI->GBI_CODGDE)
				nValGlo := GBG->GBG_VALGLO
			Endif
			aadd(aVetCodG,{GBI->GBI_CODGDE})
		Endif
		
		DbSelectArea("GBR")
		DbSetOrder(1)
		wProcura := DbSeek(xFilial("GBR")+GAD->GAD_REGATE+GBI->GBI_CODGDE+GAD->GAD_CODCRM+GBK->GBK_CODCCU)
		RecLock("GBR",If(wProcura,.f.,.t.))
		GBR->GBR_FILIAL := xFilial("GBR")
		GBR->GBR_REGATE := GAD->GAD_REGATE
		GBR->GBR_NOME   := GAD->GAD_NOME
		GBR->GBR_DTIFAT := Mv_Par01
		GBR->GBR_DTFFAT := Mv_Par02
		GBR->GBR_DATFAT := GAD->GAD_DATFAT
		GBR->GBR_CODGDE := GBI->GBI_CODGDE
		GBR->GBR_GRUDES := GAW->GAW_DESC
		GBR->GBR_CODCON := GAD->GAD_CODCON
		GBR->GBR_NOMCON := GA9->GA9_NREDUZ
		GBR->GBR_CODCCU := GBK->GBK_CODCCU
		GBR->GBR_DESCCU := HS_RDescCC(GBK->GBK_CODCCU)
		GBR->GBR_CODCRM := GAD->GAD_CODCRM
		GBR->GBR_NOMMED := SRA->RA_NOME
		GBR->GBR_VLRECM := GBR->GBR_VLRECM + (GBK->GBK_VALREA*GBK->GBK_QTDMAT)
		GBR->GBR_VLGLOM := GBR->GBR_VLGLOM + nValGlo
		GBR->GBR_VLRESM := GBR->GBR_VLRECM - (GBR->GBR_VLCUSM+GBR->GBR_VLGLOM)
		//              GBR->GBR_VLTGLO := GBR->GBR_VLGLOM
		//              GBR->GBR_VLTREC := GBR->GBR_VLRECM
		MsUnlock()
		
		DbSelectArea("GBK")
		DbSkip()
		
	Enddo
	
	// Levanta Valores de Taxas e Diarias (nao Faturados)
	DbSelectArea("GBL")
	dbsetorder(6)
	dbseek(xFilial("GBL")+GAD->GAD_REGATE)
	while !eof() .and. GBL->GBL_FILIAl+GBL->GBL_REGATE == xFilial("GBL")+GAD->GAD_REGATE
		
		If  HS_RCfgCP(GAD->GAD_CODCON, GAD->GAD_CODPLA, "_TIPCON", GBL->GBL_DATTAX) <> "0" // PARTICULAR
			If !GBL->GBL_GLOTAX $ "2/3/0"
				DbSkip()
				Loop
			Endif
		Else
			If GBL->GBL_GLOTAX <> "0"
				DbSkip()
				Loop
			Endif
		Endif
		
		DbSelectArea("GAA")
		DbSetOrder(1)
		DbSeek(xFilial("GAA")+GBL->GBL_CODTAX)
		
		DbSelectArea("GAW")
		DbSetOrder(1)
		DbSeek(xFilial("GAW")+GAA->GAA_CODGDE)
		
		DbSelectArea("SRA")
		DbSetOrder(11)
		DbSeek(xFilial("SRA")+GAD->GAD_CODCRM)
		
		nValGlo := 0
		nPos := Ascan(aVetCodG,{|x| x[1] == GAA->GAA_CODGDE})
		If  !nPos > 0
			DbSelectArea("GBG")
			dbsetorder(1)
			If dbseek(xFilial("GBG")+GAD->GAD_REGATE+GAA->GAA_CODGDE)
				nValGlo := GBG->GBG_VALGLO
			Endif
			aadd(aVetCodG,{GAA->GAA_CODGDE})
		Endif
		
		
		DbSelectArea("GBR")
		DbSetOrder(1)
		wProcura := DbSeek(xFilial("GBR")+GAD->GAD_REGATE+GAA->GAA_CODGDE+GAD->GAD_CODCRM+GBL->GBL_CODCCU)
		RecLock("GBR",If(wProcura,.f.,.t.))
		GBR->GBR_FILIAL := xFilial("GBR")
		GBR->GBR_REGATE := GAD->GAD_REGATE
		GBR->GBR_NOME   := GAD->GAD_NOME
		GBR->GBR_DTIFAT := Mv_Par01
		GBR->GBR_DTFFAT := Mv_Par02
		GBR->GBR_DATFAT := GAD->GAD_DATFAT
		GBR->GBR_CODGDE := GAA->GAA_CODGDE
		GBR->GBR_GRUDES := GAW->GAW_DESC
		GBR->GBR_CODCON := GAD->GAD_CODCON
		GBR->GBR_NOMCON := GA9->GA9_NREDUZ
		GBR->GBR_CODCCU := GBL->GBL_CODCCU
		GBR->GBR_DESCCU := HS_RDescCC(GBL->GBL_CODCCU)
		GBR->GBR_CODCRM := GAD->GAD_CODCRM
		GBR->GBR_NOMMED := SRA->RA_NOME
		GBR->GBR_VLRECT := GBR->GBR_VLRECT + (GAL->GAL_VALTAX*GAL->GAL_QTDTAX)
		GBR->GBR_VLGLOT := GBR->GBR_VLGLOT + nValGlo
		GBR->GBR_VLREST := GBR->GBR_VLRECT - (GBR->GBR_VLCUST+GBR->GBR_VLGLOT)
		//              GBR->GBR_VLTGLO := GBR->GBR_VLTGLO + GBR->GBR_VLGLOT
		//              GBR->GBR_VLTREC := GBR->GBR_VLTREC + GBR->GBR_VLRECT
		MsUnlock()
		
		DbSelectArea("GBL")
		DbSkip()
		
	Enddo
	
	DbSelectArea("GAD")
	DbSkip()
	
Enddo

Return

/*-----------------------------------------------------------------------------
Função   VALIDPERG
Descrição Verifica e inclui as perguntas no sx1
------------------------------------------------------------------------------*/
Static Function ValidPerg
Local j := 0, i := 0
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
aRegs :={}

AADD(aRegs,{"HSPP25","01"	,STR0002	  ,"                "		,"                "		,"mv_ch2"	,"D"	,8			,0			,0		,"G"	,""		,"mv_par02"		,""		,""		,""		,""		,""		,""		,""		,""		,""		,""		,""		,""		,""		,""		,"","","","","","","","","","","",""}) //"Dt Inicial FAT "
AADD(aRegs,{"HSPP25","02"	,STR0003	  ,"                "		,"                "		,"mv_ch3"	,"D"	,8			,0			,0		,"G"	,""		,"mv_par03"		,""		,""		,""		,""		,""		,""		,""		,""		,""		,""		,""		,""		,""		,""		,"","","","","","","","","","","",""}) //"Dt Final   FAT "

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

