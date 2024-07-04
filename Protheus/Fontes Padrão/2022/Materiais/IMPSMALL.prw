#INCLUDE "IMPSMALL.ch"
#include "Dbstruct.ch"
#Include "Protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ IMPSMALL()  ณ Autorณ Paulo Carnelossi    ณ Data ณ 14.05.2003 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Funcao update da versao Small 6 para a versao Apx Master/PyMEณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SmallERP                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function IMPSMALL()
Local cDirAtu	:= SPACE(254)
Local nOpc		:= 0
Local nHandFile,cFile
Local oDlg, oBmp

OpenSm0Excl()

If !File("SMUPDMAS.DAT")
	DEFINE MSDIALOG oDlg FROM 102,98  TO 355,584 TITLE STR0001 PIXEL //"Update SmallERP x Master/PyME"
	DEFINE FONT oBold NAME "Arial" SIZE 0, -14 BOLD
	
	@ 13 ,43  TO 15 ,270 LABEL '' OF oDlg PIXEL
	@ 0, 0 BITMAP oBmp RESNAME "PROJETOAP" oF oDlg SIZE 40,140 NOBORDER WHEN .F. PIXEL
	@ 5  ,47  SAY STR0002 FONT oBold Of oDlg PIXEL SIZE 184,9 //"Assistente de atualiza็ใo SmallERP x Master/PyME"
	@ 22 ,47  SAY STR0003 Of oDlg PIXEL SIZE 182,40 //"Bem Vindo ao assistente de atualiza็ใo do SmallERP para Master/PyME. Esta rotina permite que todos os dados e as configura็๕es da versao SmallERP sejam importados para a versao Master/PyME. Para prosseguir com a atualiza็ใo informe o diret๓rio onde foram gerados os pacotes de atualiza็ใo do SmallERP."
	
	
	@ 66 ,47  SAY STR0004 Of oDlg PIXEL SIZE 37 ,9 //"Diretorio"
	@ 65 ,74  MSGET cDirAtu  OF oDlg PIXEL SIZE 95 ,9
	
	@ 64,168 BUTTON STR0005 SIZE 28 ,12   FONT oDlg:oFont ACTION  {|| cDirAtu := cGetFile("",; //"Procurar"
	STR0006,0,"",.T.,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY)  } OF oDlg PIXEL //"Selecione o Arquivo"
	
	
	@113,50 BUTTON STR0007 SIZE 65 ,11  FONT oDlg:oFont ACTION (oDlg:End())  OF oDlg PIXEL //"Importar mais &tarde"
	@113,118 BUTTON STR0008 SIZE 70 ,11  FONT oDlg:oFont ACTION (nOpc:=1,oDlg:End())  OF oDlg PIXEL //"Nao perguntar novamente"
	@113,190 BUTTON STR0009 SIZE 45 ,11  FONT oDlg:oFont ACTION If(ChkDir(cDirAtu),(nOpc:=2,oDlg:End()),Nil)  OF oDlg PIXEL //"&Continuar >>"
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
	If nOpc == 2
		Processa({||Migra(cDirAtu)})
		cFile			:= STR0010 //"IMPORTACAO SMALL PARA MASTER/PYME NAO APAGAR"
		nHandFile	:= MSfCreate("SMUPDMAS.DAT")
		fWrite(nHandFile,cFile,Len(cFile))
		fClose(nHandFile)
		Final(STR0011) //"Importacao efetuada com sucesso."
	EndIf
	If nOpc == 1
		cFile			:= STR0012 //"IMPORTACAO SMALL PARA MASTER/PYME CANCELADA NAO APAGAR"
		nHandFile	:= MSfCreate("SMUPDMAS.DAT")
		fWrite(nHandFile,cFile,Len(cFile))
		fClose(nHandFile)
	EndIf
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMigra()   บAutor  ณPaulo Carnelossi    บ Data ณ  05/16/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina importacao dos dados do SmallERP / Master ou PYME    บฑฑ
ฑฑบ          ณRecebe parametro cDirAtu (diretorio pacote small)           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Migra(cDirAtu)
Local aStru := {}
Local cArqTrab4, cArqTrab5 := CriaTrab(,.F.)
Local cArqTrab6 := CriaTrab(,.F.)
Local cArqTrab7 := CriaTrab(,.F.)
Local cArqTrab8 := CriaTrab(,.F.)
Local cArqTrab9 := CriaTrab(,.F.)
Local cArqTrab0 := CriaTrab(,.F.)
Local cArqTrabA := CriaTrab(,.F.)
Local cArqTrabB := CriaTrab(,.F.)
Local cArqImp
Local nOpcRel
Local cArqTab, cArqCam, cArqCpo, cArqCbo

// estrutura para gravar ocorrencia caso nao grave campo obrigatorio
aAdd(aStru,{"ALIAS","C",3,0})
aAdd(aStru,{"NOMECPO","C",10,0})
cArqTrab4 := CriaTrab(aStru)

DbUseArea(.T.,__LocalDriver,cArqTrab4,"OCO",.T.,.F.)
IndRegua("OCO",cArqTrab4,"ALIAS+NOMECPO",,,STR0013) //"Criando Indํce Temporแrio"

ProcRegua(4)

cArqTab := Ttabela()  // tabela contendo os alias do small/master e se migra os dados para master
IncProc()

cArqCam := Tcampos() // tabela contendo os campos small e indicador se serao migrados para master
IncProc()

cArqCpo := Tcpos() // tabela contendo os campos (small) e os respectivos campos (master)
IncProc()

cArqCbo := Tcombo() // tabela contendo valores small combobox e respectivos master
IncProc()

DbSelectArea("TAB")
ProcRegua(TAB->(LASTREC())*2+4)

dbGoTop()

While ! EOF()
	
	IncProc()
	
	cArqImp := Alltrim(TAB->ALIAS)
	
	If File(cDirAtu+cArqImp+"IMP.PAK")
		//copia e abre o arquivo a ser importado
		__CopyFile( cDirAtu+cArqImp+"IMP.PAK", cArqImp+"IMP.PAK" )
		
      //verifica se existe o FPT. Se existir, copia 
      
		If File(cDirAtu+cArqImp+"IMP.FPT")
			__CopyFile( cDirAtu+cArqImp+"IMP.FPT", cArqImp+"IMP.FPT" )		      
		EndIf 
		
      dbUseArea( .T., __localdriver, cArqImp+"IMP.PAK", "TMP"+cArqImp, .F., .F.)
		
		If cArqImp == "SA2"  //Enderecos alternativos small
			IndRegua("TMPSA2",cArqTrab5,"A2_PESSOA",,,STR0013) //"Criando Indํce Temporแrio"
			
		ElseIf cArqImp == "SC1"  //solicitacao compras cabecalho
			IndRegua("TMPSC1",cArqTrab6,"C1_NUMSOL+C1_ITEM+C1_CODPROD",,,STR0013) //"Criando Indํce Temporแrio"
		
		ElseIf cArqImp == "SC8"  //Pedido de compras cabecalho
			IndRegua("TMPSC8",cArqTrab8,"C8_NUMPED+C8_ITEM",,,STR0013) //"Criando Indํce Temporแrio"
		EndIf
		
	EndIf
	
	DbSelectArea("TAB")
	dbSkip()
	
End

If Select("TMPSC5") > 0
   dbSelectArea("TMPSC5")
   IndRegua("TMPSC5",cArqTrab9,"C5_PESSOA",,,STR0013) //"Criando Indํce Temporแrio"
EndIf

If Select("TMPSF2") > 0
   dbSelectArea("TMPSF2")
	IndRegua("TMPSF2",cArqTrab0,"F2_PESSOA",,,STR0013) //"Criando Indํce Temporแrio"
EndIf

If Select("TMPSC7") > 0
   dbSelectArea("TMPSC7")
	IndRegua("TMPSC7",cArqTrabA,"C7_PESSOA",,,STR0013) //"Criando Indํce Temporแrio"
EndIf

If Select("TMPSF1") > 0
   dbSelectArea("TMPSF1")
	IndRegua("TMPSF1",cArqTrabB,"F1_PESSOA",,,STR0013) //"Criando Indํce Temporแrio"
Endif

DbSelectArea("TAB")
dbGoTop()

While ! EOF()
	IncProc()
	
	If TAB->MIGRA == "S"
		If TAB->REGRA == "R01"
			MigraSA1()
		ElseIf TAB->REGRA == "R02" .OR. TAB->REGRA == "R03"
			MigraNormal("TMP"+TAB->ALIAS, TAB->ALIAS, TAB->ALIASMASTE, .T.)
			//ElseIf TAB->REGRA == "R04" //-codigo fiscal de operacao
			//ElseIf TAB->REGRA == "R05" //-tabela 12 SX5 (Estados)
		ElseIf TAB->REGRA == "R06"
			MigraNormal("TMP"+TAB->ALIAS, TAB->ALIAS, TAB->ALIASMASTE, .T.)
		ElseIf TAB->REGRA == "R07"
			MigraSA7() // Cadastro de Feriados
		Else
			MigraNormal("TMP"+TAB->ALIAS, TAB->ALIAS, TAB->ALIASMASTE, .T.)
		EndIf
	EndIf
	
	DbSelectArea("TAB")
	dbSkip()
	
End

//altera os parametros SX6 
dbSelectArea("TMPSX6")
IndRegua("TMPSX6",cArqTrab7,"X6_VAR",,,STR0013) //"Criando Indํce Temporแrio"
IncProc()

dbSelectArea("TMPSX6")
If dbSeek("MV_ULMES")
   dbSelectArea("SX6")
	If dbSeek(xFilial("SX6")+"MV_ULMES")
	   RecLock("SX6", .F.)
	   X6_CONTEUD := TMPSX6->X6_CONTEUD
	   MsUnLock()
	EndIf
EndIf	

dbSelectArea("TMPSX6")
If dbSeek("MV_DOCSEQ")
   dbSelectArea("SX6")
	If dbSeek(xFilial("SX6")+"MV_DOCSEQ")
	   RecLock("SX6", .F.)
	   X6_CONTEUD := TMPSX6->X6_CONTEUD
	   MsUnLock()
	EndIf
EndIf	

//Cria tabelas de Precos de acordo com SB5
IncProc()
SB5SmallUpdate()

//apaga os arquivos copiados para importacao apos processamento
IncProc()

DbSelectArea("TAB")
dbGoTop()

While ! EOF()
	
	IncProc()
	
	cArqImp := Alltrim(TAB->ALIAS)
	
	If File(cArqImp+"IMP.PAK") .And. Select("TMP"+cArqImp) > 0
		dbSelectArea("TMP"+cArqImp)
		dbCloseArea()
		Ferase(cArqImp+"IMP.PAK")
		
		If cArqImp == "SA2"
				Ferase(cArqTrab5+OrdBagExt())
		ElseIf cArqImp == "SC1" 
				Ferase(cArqTrab6+OrdBagExt())
		
		ElseIf cArqImp == "SC8" 
				Ferase(cArqTrab8+OrdBagExt())
				
		ElseIf cArqImp == "SX6" 
				Ferase(cArqTrab7+OrdBagExt())
				
		ElseIf cArqImp == "SC5" 
			   Ferase(cArqTrab9+OrdBagExt())

		ElseIf cArqImp == "SF2" 
			   Ferase(cArqTrab0+OrdBagExt())

		ElseIf cArqImp == "SC7" 
			   Ferase(cArqTrabA+OrdBagExt())

		ElseIf cArqImp == "SF1" 
			   Ferase(cArqTrabB+OrdBagExt())
		
		EndIf
		
	EndIf
	
	DbSelectArea("TAB")
	dbSkip()
	
End

dbSelectArea("TAB")
dbCloseArea()
Ferase(cArqTab+GetDbExtension())

dbSelectArea("TCP")
dbCloseArea()
Ferase(cArqCam+GetDbExtension())
Ferase(cArqCam+OrdBagExt())

dbSelectArea("CPO")
dbCloseArea()
Ferase(cArqCpo+GetDbExtension())
Ferase(cArqCpo+OrdBagExt())

dbSelectArea("TCB")
dbCloseArea()
Ferase(cArqCbo+GetDbExtension())
Ferase(cArqCbo+OrdBagExt())

dbSelectArea("OCO")
IncProc()

If LastRec() > 0

   dbCloseArea()
   If File("OCORREN.LOG")
   	Frename("OCORREN.LOG", "OCORREN1.LOG")
   EndIf
	Frename(cArqTrab4+GetDbExtension(),"OCORREN.LOG")

	nOpcRel := Aviso( STR0014, STR0015, { STR0016, STR0017 }, 2 ) //"Campos Obrigat๓rios - Atencao"###"Campos obrigat๓rios nใo foram preenchidos - Verifique o arquivo OCORREN.LOG no diret๓rio \SIGAADV !"###"Ok"###"Imprime"
	
	If nOpcRel == 2
      Rel_Obrigat()
   EndIf
      
EndIf	

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMigraNormal บAutor  ณPaulo Carnelossi  บ Data ณ  15/05/03   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Programa para importacao small para Master/PyME            บฑฑ
ฑฑบ          ณ (Default para maior parte das tabelas)                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MigraNormal(cAliasImp, cAliasSmall, cAliasMaster, lInclui)
Local aSC1, aSC7, nCtd, lFirst := .T.

dbSelectArea(cAliasMaster)
dbCloseArea()
ChkFile(cAliasMaster,.T.)

dbSelectArea(cAliasImp)  //Tabela Originario do Small
dbGoTop()

While (cAliasImp)->(! EOF())
	
	GrvTabela(cAliasImp, cAliasSmall, cAliasMaster, .T.)
	
	If cAliasMaster == "SC6"
		dbSelectArea("SC5")
		dbSetOrder(1)
		If dbSeek(xFilial("SC5")+SC6->C6_NUM)
			dbSelectArea("SC6")
			RecLock("SC6",.F.) //altera็ao
			SC6->C6_CLI := SC5->C5_CLIENTE
			MsUnLock()
		EndIf

	ElseIf cAliasSmall == "SC0" // solicitacao compras cabecalho small
		
		dbSelectArea("SC1")
		lFirst := .T.
		aSC1 := {}
		For nCtd :=1 TO FCOUNT()
			aAdd(aSC1, FieldGet(nCtd))
		Next
		
		dbSelectArea("TMPSC1")
		dbSeek(SC1->C1_NUM)
		While TMPSC1->(C1_NUMSOL == SC1->C1_NUM .And. ! EOF())
			
			dbSelectArea("SC1")
			If lFirst
				lFirst := .F.
				RecLock("SC1",.F.) //altera็ao
			Else
				RecLock("SC1",.T.) //Inclusใo
				For nCtd := 1 TO Len(aSC1)
					FieldPut(nCtd, aSC1[nCtd])
				Next
			EndIf
			C1_ITEM    	:= TMPSC1->C1_ITEM
			C1_PRODUTO 	:= TMPSC1->C1_CODPROD
			C1_DESCRI  	:= TMPSC1->C1_DESCRI
			C1_UM 		:= TMPSC1->C1_CODUM
			C1_QUANT   	:= TMPSC1->C1_QUANT
			C1_DATPRF  	:= TMPSC1->C1_DATPRF
			C1_LOCAL   	:= TMPSC1->C1_LOCAL
			C1_OBS     	:= TMPSC1->C1_OBS
			C1_OP      	:= TMPSC1->C1_OP
			C1_QUJE   	:= TMPSC1->C1_QUJE
			MsUnLock()
			
			
			dbSelectArea("TMPSC1")
			dbSkip()
			
		End
		
		ElseIf cAliasSmall == "SC7" // Pedido de compras cabecalho small
		
		dbSelectArea("SC7")
		lFirst := .T.
		aSC7 := {}
		For nCtd :=1 TO FCOUNT()
			aAdd(aSC7, FieldGet(nCtd))
		Next
		
		dbSelectArea("TMPSC8")
		dbSeek(SC7->C7_NUM)
		While TMPSC8->(C8_NUMPED == SC7->C7_NUM .And. ! EOF())
			
			dbSelectArea("SC7")
			If lFirst
				lFirst := .F.
				RecLock("SC7",.F.) //altera็ao
			Else
				RecLock("SC7",.T.) //Inclusใo
				For nCtd := 1 TO Len(aSC7)
					FieldPut(nCtd, aSC7[nCtd])
				Next
			EndIf
			
			C7_ITEM    	:= TMPSC8->C8_ITEM
			C7_PRODUTO 	:= TMPSC8->C8_CODPROD
			C7_UM     	:= TMPSC8->C8_CODUM
			C7_QUANT   	:= TMPSC8->C8_QUANT
			C7_PRECO   	:= TMPSC8->C8_PRCUNI
			C7_TOTAL   	:= TMPSC8->C8_TOTAL
			C7_DATPRF  	:= TMPSC8->C8_DATPRF
			C7_LOCAL 	:= TMPSC8->C8_LOCAL
			C7_OBS     	:= TMPSC8->C8_OBS
			C7_DESCRI  	:= TMPSC8->C8_DESCRI
			C7_QUJE    	:= TMPSC8->C8_QUJE
			C7_NUMSC    := TMPSC8->C8_NUMSC
			C7_ITEMSC   := TMPSC8->C8_ITEMSC
			C7_QTDSOL   := TMPSC8->C8_QTDSC
			C7_OP      	:= TMPSC8->C8_OP
			C7_FILENT  	:= xFilial("SC7")
			C7_TIPO     := 1
			C7_IPIBRUT  := "B"
			C7_TPFRET   := "C"
			C7_MOEDA    := 1
			MsUnLock()
			
			
			dbSelectArea("TMPSC8")
			dbSkip()
			
		End
		

	ElseIf cAliasMaster == "SB1"
	   If (cAliasImp)->(FieldPos("B1_PRV2")) > 0 .And. ;
	   	(cAliasImp)->(FieldPos("B1_PRV3")) > 0
			If (cAliasImp)->B1_PRV2 != 0 .OR. (cAliasImp)->B1_PRV3 != 0
				dbSelectArea("SB5")
				RecLock("SB5",.T.)
				SB5->B5_COD 	:= (cAliasImp)->B1_CODPROD
				SB5->B5_CEME	:= (cAliasImp)->B1_DESCRI
				SB5->B5_PRV2 	:= (cAliasImp)->B1_PRV2
				SB5->B5_PRV3 	:= (cAliasImp)->B1_PRV3
				MsUnLock()
			EndIf
		EndIf
	EndIf
	
	If cAliasMaster $ "SC1/SC7"
		VerObrigat(cAliasMaster)
	EndIf	
	
	dbSelectArea(cAliasImp)
	dbSkip()
	
End

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMigraSA1  บAutor  ณPaulo Carnelossi    บ Data ณ  15/05/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณprograma para migrar tabela sa1 small (cad. pessoas)        บฑฑ
ฑฑบ          ณe popular tabelas master sa1/sa2/sa3                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MigraSA1()
Local lCliente, lFornec

dbSelectArea("SA1")
dbCloseArea()
ChkFile("SA1",.T.)

dbSelectArea("SA2")
dbCloseArea()
ChkFile("SA2",.T.)

dbSelectArea("SA3")
dbCloseArea()
ChkFile("SA3",.T.)

dbSelectArea("TMPSA1")  //SA1 ORIGINARIO DO SMALL
dbGoTop()

While TMPSA1->(! EOF())

	lCliente := If(TMPSA1->A1_IDENT = "3",  VerVendas(TMPSA1->A1_PESSOA, .F.), VerCompras(TMPSA1->A1_PESSOA, .T.))
	lFornec  := If(TMPSA1->A1_IDENT = "3", VerCompras(TMPSA1->A1_PESSOA, .F.),  VerVendas(TMPSA1->A1_PESSOA, .T.))
	
	If lCliente .OR. TMPSA1->A1_IDENT = "1"    //Clientes
		GrvTabela("TMPSA1", "SA1", "SA1", .T.)
		
		dbSelectArea("TMPSA2")
		If dbSeek(TMPSA1->A1_PESSOA)
			While TMPSA2->(A2_PESSOA == TMPSA1->A1_PESSOA .And. ! EOF())
				//GRAVAR ENDERECO DE COBRANCA / ENTREGA
				dbSelectArea("SA1")
				dbSetOrder(1)
				If dbSeek(xFilial("SA1")+TMPSA1->A1_PESSOA)
					RecLock("SA1", .F.)
					If TMPSA2->A2_TIPO = "1"
						SA1->A1_ENDCOB		:= TMPSA2->A2_END
						SA1->A1_CEPC		:= TMPSA2->A2_CEP
						SA1->A1_BAIRROC	:= TMPSA2->A2_BAIRRO
						SA1->A1_MUNC		:= TMPSA2->A2_MUN
						SA1->A1_ESTC		:= TMPSA2->A2_EST
						SA1->A1_EMAIL		:= If(Empty(SA1->A1_EMAIL),TMPSA2->A2_EMAIL,SA1->A1_EMAIL)
						SA1->A1_TEL			:= ALLTRIM(SA1->A1_TEL+TMPSA2->A2_FONE)
					Else
						SA1->A1_ENDENT		:= TMPSA2->A2_END
						SA1->A1_CEPE		:= TMPSA2->A2_CEP
						SA1->A1_BAIRROE	:= TMPSA2->A2_BAIRRO
						SA1->A1_MUNE		:= TMPSA2->A2_MUN
						SA1->A1_ESTE		:= TMPSA2->A2_EST
						SA1->A1_EMAIL		:= If(Empty(SA1->A1_EMAIL),TMPSA2->A2_EMAIL,SA1->A1_EMAIL)
						SA1->A1_TEL			:= ALLTRIM(SA1->A1_TEL+TMPSA2->A2_FONE)
					EndIf
					MsUnLock()
				EndIf
				
				dbSelectArea("TMPSA2")
				dbSkip()
				
			End
			
		EndIf
	
	EndIf
		
	If lFornec .OR. TMPSA1->A1_IDENT = "2" //Fornecedores
		GrvTabela("TMPSA1", "SA1", "SA2", .T.)
	EndIf
		
	If TMPSA1->A1_IDENT = "3" //Vendedores
		GrvTabela("TMPSA1", "SA1", "SA3", .T.)
	EndIf
	
	dbSelectArea("TMPSA1")
	dbSkip()
	
End

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGrvTabela บAutor  ณPaulo Carnelossi    บ Data ณ  15/05/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPrograma para gravar as tabelas importadas                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcoes MigraNormal / MigraSA1                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GrvTabela(cAliasImp,cAliasSmall, cAliasMaster, lInclui)
Local aRegistro := {}
Local nCtd, cNomeCpo
Local nCpoMaster

dbSelectArea("TCP")
dbSeek(cAliasSmall)

While TCP->(! EOF() .And. ALIAS == cAliasSmall)
	
	If TCP->MIGRA == "S"      // carrega campo no array aregistro
		cNomeCpo := TCP->NOMECPO
		If ! Empty(cNomeCpo)
			CarCampo(aRegistro, cAliasImp, cAliasSmall, cAliasMaster, cNomeCpo)
		EndIf
	EndIf
	
	dbSelectArea("TCP")
	dbSkip()
	
End

//gravacao do registro    
If Len(aRegistro) > 0
	dbSelectArea(cAliasMaster)
	RecLock(cAliasMaster, lInclui)
	
	FieldPut(FieldPos(Subs(cAliasMaster,2,2)+"_FILIAL"), xFilial(cAliasMaster) )
	
	If cAliasMaster $ "SA1/SA2/SE1/SE2/SE5/SC7/SF1/SD1/SF2/SD2/SC6"
		FieldPut(FieldPos(Subs(cAliasMaster,2,2)+"_LOJA"), "01" )
	EndIf
	
	If cAliasMaster $ "SC5"
		FieldPut(FieldPos(Subs(cAliasMaster,2,2)+"_LOJACLI"), "01" )
	EndIf
	
	//grava os campos armazenados no array aregistro
	FOR nCtd := 1 TO LEN(aRegistro)
		nCpoMaster := FieldPos(aRegistro[nCtd][1])
		If nCpoMaster > 0
		   If ValType(FieldGet(nCpoMaster)) == "N" .And.;
		      ValType(aRegistro[nCtd][2]) == "C"
		      aRegistro[nCtd][2] := VAL(aRegistro[nCtd][2])
		   ElseIf ValType(FieldGet(nCpoMaster)) == "C" .And.;
		      ValType(aRegistro[nCtd][2]) == "N"
		      aRegistro[nCtd][2] := STR(aRegistro[nCtd][2])
		   EndIf   
			FieldPut(nCpoMaster, aRegistro[nCtd][2])
		EndIf
	NEXT
	
	//se campo e5_moeda nใo estiver preenchido, define como "M1"
	If cAliasMaster == "SE5" .And. EMPTY(SE5->E5_MOEDA)
		FieldPut(FieldPos("E5_TIPODOC"), "VL")
		FieldPut(FieldPos("E5_MOTBX"), "NOR")		
		
	ElseIf cAliasMaster == "SE5" .And. ! EMPTY(SE5->E5_MOEDA) // se nใo vazio
		FieldPut(FieldPos("E5_TIPODOC"), "TR")                 // transferencia
		
	ElseIf cAliasMaster == "SA1"	
		FieldPut(FieldPos("A1_NREDUZ"),SA1->A1_NOME)
		
	ElseIf cAliasMaster == "SA2"	
		FieldPut(FieldPos("A2_NREDUZ"),SA2->A2_NOME)
		If Empty(SA2->A2_TIPO) .OR. (! Empty(SA2->A2_TIPO) .And. ! SA2->A2_TIPO $ "FX")
			FieldPut(FieldPos("A2_TIPO"),"J")
		EndIf
		
		FieldPut(FieldPos("A2_ID_FBFN"),"2")
		
	ElseIf cAliasMaster == "SA3"	
		FieldPut(FieldPos("A3_NREDUZ"),SA3->A3_NOME)
		FieldPut(FieldPos("A3_TIPO"),"I") 
		
	ElseIf cAliasMaster == "SF1"	
		FieldPut(FieldPos("F1_ESPECIE"),"NF")
		FieldPut(FieldPos("F1_STATUS"),"A")

	ElseIf cAliasMaster == "SF2"	
		FieldPut(FieldPos("F2_ESPECIE"),"NF")

	ElseIf cAliasMaster == "SC6"	
		FieldPut(FieldPos("C6_PRUNIT"),FieldGet(FieldPos("C6_PRCVEN")))

	ElseIf cAliasMaster == "SC2"	
		FieldPut(FieldPos("C2_TPOP"), "F")
		
	ElseIf cAliasMaster == "SE1"	
		FieldPut(FieldPos("E1_VLCRUZ"), Round(NoRound(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,1,SE1->E1_EMISSAO,3),3),2))
		FieldPut(FieldPos("E1_VENCORI"), SE1->E1_VENCTO )

	ElseIf cAliasMaster == "SE2"	
		FieldPut(FieldPos("E2_VLCRUZ"), Round(NoRound(xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,1,SE2->E2_EMISSAO,3),3),2))
		FieldPut(FieldPos("E2_VENCORI"), SE2->E2_VENCTO )

	EndIf

	MsUnLock()
	
EndIf

//verificacao obrigatoriedade
If ! cAliasMaster $ "SC1/SC7"
	VerObrigat(cAliasMaster)
EndIf	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCarCampo  บAutor  ณPaulo Carnelossi    บ Data ณ  15/05/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega campos do arquivo de importacao para array aregistroบฑฑ
ฑฑบ          ณque sera utilizado pela funcao grvtabela()                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CarCampo(aRegistro, cAliasImp, cAliasSmall, cAliasMaster, cNomeCpo)
Local xContSmall, nCpoSmall

dbSelectArea("CPO")
If dbSeek(cAliasSmall+cNomeCpo+cAliasMaster) .And. ! EMPTY(CPO->CPOMASTER)

	nCpoSmall := (cAliasImp)->(FieldPos(cNomeCpo))

	If nCpoSmall > 0
		xContSmall := (cAliasImp)->(FieldGet(nCpoSmall))
		
		If ! EMPTY(TCP->COMBCPO)
			
			dbSelectArea("TCB")
			If dbSeek(cAliasSmall+cNomeCpo+xContSmall) .And. ;
				! EMPTY(TCB->CONTMASTER)
				xContSmall := TCB->CONTMASTER
			EndIf
			
		EndIf
		
		If xContSmall != NIL
			aAdd(aRegistro, { CPO->CPOMASTER, xContSmall } )
		EndIf
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMigraSA7  บAutor  ณPaulo Carnelossi    บ Data ณ  15/05/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImporta arquivo small sa7-cadastro de feriados para tabela  บฑฑ
ฑฑบ          ณ63 do SX5                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณfuncao MIgra()                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MigraSA7()
Local aFeriado := {}, lInclui := .T., nCtd, cDataFer, nX
Local cX5Chave

dbSelectArea("TMPSA7")

dbSelectArea("SX5")
dbSetOrder(1)
dbSeek(xFilial("SX5")+"63") // Tabela de Feriados

While SX5->(X5_FILIAL == xFilial("SX5") .And. X5_TABELA == "63" .And. ! EOF())
	aAdd(aFeriado, Alltrim(Subs(X5_DESCRI,1,12)))
	cX5Chave := Alltrim(X5_CHAVE)
	dbSkip()
End


dbSelectArea("TMPSA7")
dbGoTop()

While TMPSA7->(! EOF())
	
	lInclui := .T.
	
	For nX := 1 TO 2
		
		If nX == 1
			cDataFer := TMPSA7->(A7_DIA+"/"+A7_MES)
		Else
			cDataFer := TMPSA7->(A7_DIA+"/"+A7_MES+"/"+Subs(A7_ANO,3,2))
		EndIf
		
		For nCtd := 1 TO LEN(aFeriado)
			
			If cDataFer == aFeriado[nCtd]
				lInclui := .F.
				EXIT
			EndIf
			
		Next  // nCtd
		
		If ! lInclui
			EXIT
		EndIf
		
	Next    // nX
	
	If lInclui
		dbSelectArea("SX5")
		RecLock("SX5", .T.)
		X5_FILIAL := "  "
		X5_TABELA := "63"
		X5_CHAVE  := Soma1(cX5Chave,3)
		cX5Chave  := Alltrim(X5_CHAVE)
		X5_DESCRI := PADR(cDataFer,12)+PADR(TMPSA7->A7_DESCRI,30)
	EndIf
	
	dbSelectArea("TMPSA7")
	dbSkip()
	
End

Return

//-----------------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณChkDir    บAutor  ณPaulo Carnelossi    บ Data ณ  15/05/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCheca se diretorio do pacote small para importacao esta     บฑฑ
ฑฑบ          ณcorreto                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ImpSmall()                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ChkDir(cDirAtu)

If Empty(cDirAtu)
	Aviso( STR0018, STR0019, { STR0016 }, 2 ) //"DIRERRO - Diretorio ou caminho invแlido."###"Verifique o diretorio informado."###"Ok"
	Return .F.
EndIf

If !File(cDirAtu+"SMPSS.PAK")
	Aviso( STR0020, STR0021, { STR0016 }, 2 ) //"ARQERRO - Diretorio ou caminho invแlido."###"Os arquivos para importa็ใo nใo foram encontrados neste diret๓rio. Verifique o diret๓rio informado."###"Ok"
	Return .F.
EndIf

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณSB5SmallUpdate บAutor  ณPaulo Carnelossi บ Data ณ 15/05/03  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณGera Tabela de Precos a partir do SB5                       บฑฑ
ฑฑบ          ณ(copia da funcao SB5Update1() - SB5UPDATE.PRW V. 609        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFuncao Migra()                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SB5SmallUpdate()

Local aTabela:= {}
Local lQuery := .F.
Local cAlias := "SB5"
Local cTabela:= "2"
Local cFilDA0:= xFilial("DA0")
Local nX     := 0

#IFDEF TOP
	Local cQuery := ""
#ENDIF

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica a fiial do DA0/DA1                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty(xFilial("SB1")+xFilial("SB5"))
	cFilDA0 := Space(2)
	dbSelectArea("SX2")
	dbSetOrder(1)
	If dbSeek("DA0")
		RecLock("SX2")
		SX2->X2_MODO := "C"
		MsUnLock()
	EndIf
	If dbSeek("DA1")
		RecLock("SX2")
		SX2->X2_MODO := "C"
		MsUnLock()
	EndIf
Else
	cFilDA0 := cFilAnt
	dbSelectArea("SX2")
	dbSetOrder(1)	
	If dbSeek("DA0")
		RecLock("SX2")
		SX2->X2_MODO := "E"
		MsUnLock()
	EndIf
	If dbSeek("DA1")
		RecLock("SX2")
		SX2->X2_MODO := "E"
		MsUnLock()
	EndIf
EndIf
If !(Empty(cFilDA0) .And. DA0->(LastRec())<>0)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica as tabelas de preco existentes                                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("SB5")
	dbSetOrder(1)
	While SB5->(FieldPos("B5_PRV"+cTabela))<>0
		aadd(aTabela,{cTabela,"B5_PRV"+cTabela,"0001","B5_DTREFP"+cTabela})
		cTabela := Soma1(cTabela,1)
	EndDo
	#IFDEF TOP
		If TcSrvType()<>"AS/400"
			cAlias := "SB5UPDATE"
			cQuery := "SELECT * "
			cQuery += "FROM "+RetSqlName("SB5")+" SB5 "
			cQuery += "WHERE "
			cQuery += "SB5.B5_FILIAL='"+xFilial("SB5")+"' AND "
			cQuery += "SB5.D_E_L_E_T_=' ' "
			
			cQuery := ChangeQuery(cQuery)
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
			For nX := 1 To Len(aStru)
				If aStru[nX][2]<>"C"
					TcSetField(cAlias,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
				EndIf
			Next nX
	    Else
	#ENDIF
			dbSeek(xFilial("SB5"))
	#IFDEF TOP
		EndIf
	#ENDIF
	dbSelectArea(cAlias)
	While ( !Eof() .And. (cAlias)->B5_FILIAL==xFilial("SB5") )
		For nX := 1 To Len(aTabela)
			If (cAlias)->(FieldGet(FieldPos(aTabela[nX][2])))<>0
				cTabela := PadR(aTabela[nX][1],Len(DA0->DA0_CODTAB))
				dbSelectArea("DA0")
				dbSetOrder(1)
				If !dbSeek(cFilDA0+cTabela)
					RecLock("DA0",.T.)
					DA0->DA0_FILIAL := cFilDA0
					DA0->DA0_CODTAB := cTabela
					DA0->DA0_DESCRI := RetTitle("DA0_ATIVO")+" "+cTabela
					DA0->DA0_DATDE  := Ctod("01/01/1980")
					DA0->DA0_HORADE := "00:00"
					DA0->DA0_HORATE := "23:59"
					DA0->DA0_ATIVO  := "1"
					MsUnLock()
				EndIf
				dbSelectArea("DA1")
				dbSetOrder(2)
				If !dbSeek(cFilDA0+(cAlias)->B5_COD+cTabela)
					RecLock("DA1",.T.)
					DA1->DA1_FILIAL := cFilDA0
					DA1->DA1_ITEM   := aTabela[nX][3]
					DA1->DA1_CODTAB := cTabela
					DA1->DA1_CODPRO := (cAlias)->B5_COD
					DA1->DA1_PRCVEN := (cAlias)->(FieldGet(FieldPos(aTabela[nX][2])))
					DA1->DA1_ATIVO  := "1"
					DA1->DA1_TPOPER := "4"
					DA1->DA1_QTDLOT := 999999.99
					DA1->DA1_INDLOT := StrZero(DA1->DA1_QTDLOT,18,2)
					DA1->DA1_MOEDA  := 1				
					MsUnLock()
					aTabela[nX][3] := Soma1(aTabela[nX][3])
				EndIf
			EndIf		
		Next nX
		dbSelectArea(cAlias)
		dbSkip()
	EndDo
	If lQuery
		dbSelectArea(cAlias)
		dbCloseArea()
		dbSelectArea("SB1")	
	EndIf
EndIf
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVerObrigatบAutor  ณPaulo Carnelossi    บ Data ณ  15/05/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณverifica se campos obrigatorios foram preenchidos na tabela บฑฑ
ฑฑบ          ณimportada e grava arquivo ocorrencias para listagem         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMigraNormal() - GrvTabela()                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VerObrigat(cAliasMaster)
Local nCtd, xConteudo, cCampo, lValid

dbSelectArea("SX3")
dbSetOrder(2)

dbSelectArea(cAliasMaster)
For nCtd :=1 TO FCOUNT()
	xConteudo := FieldGet(nCtd)
	cCampo    := FieldName(nCtd)
	dbSelectArea("SX3")
	If dbSeek(cCampo) .And. X3Obrigat(cCampo)
		
		lValid := If( ValType(xConteudo) == "N", xConteudo <> 0, ! Empty(xConteudo) )
		
		If ! lValid     // caso algum campo obrigatorio nao preecnhido gravar tab.ocorr.
			dbSelectArea("OCO")
			If !dbSeek(cAliasMaster+cCampo)
				RecLock("OCO", .T.)
				OCO->ALIAS 		:= cAliasMaster
				OCO->NOMECPO 	:= cCampo
				MsUnLock()
			EndIf
		EndIf
		
	EndIf
	
	dbSelectArea(cAliasMaster)
	
Next

dbSelectArea("SX3")
dbSetOrder(1)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVerVendas บAutor  ณPaulo Carnelossi    บ Data ณ  15/05/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณverifica nos arquivos a ser importado se ocorreram vendas p/บฑฑ
ฑฑบ          ณpessoa a ser importado                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMigraSA1()                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VerVendas(cPessoa, lChkDev)
Local lRetorno := .F., lContinua := .T.

If Select("TMPSC5") > 0
   dbSelectArea("TMPSC5")
   dbSeek(cPessoa)
   If Found() .And. ! lChkDev
   	lRetorno := .T.
	   lContinua := .F.
   EndIf

   While lChkDev .And. TMPSC5->(C5_PESSOA == cPessoa .And. ! EOF())
	   If TMPSC5->C5_TIPO <> "2"
	   	lRetorno := .T.
	   	lContinua := .F.
	      EXIT
	   EndIf
	   
	   dbSelectArea("TMPSC5")
		dbSkip()
		
	End	   
EndIf

If lContinua .And. Select("TMPSF2") > 0
   dbSelectArea("TMPSF2")
	dbSeek(cPessoa)
	If Found() .And. ! lChkDev
   	lRetorno := .T.
	   lContinua := .F.
   EndIf

	While lChkDev .And. TMPSF2->(F2_PESSOA == cPessoa .And. ! EOF())

	   If TMPSF2->F2_TIPO <> "2"
	   	lRetorno := .T.
      	EXIT
	   EndIf

   	dbSelectArea("TMPSF2")
		dbSkip()

	End	
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVerComprasบAutor  ณPaulo Carnelossi    บ Data ณ  15/05/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณverifica nos arquivos a ser importado se ocorreram compras  บฑฑ
ฑฑบ          ณda pessoa a ser importada                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMigraSA1()                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VerCompras(cPessoa, lChkDev)
Local lRetorno := .F., lContinua := .T.

If Select("TMPSC7") > 0
   dbSelectArea("TMPSC7")
   If dbSeek(cPessoa)
	 	lRetorno := .T.
	  	lContinua := .F.
	EndIf
EndIf

If lContinua .And. Select("TMPSF1") > 0
   dbSelectArea("TMPSF1")
	dbSeek(cPessoa)
   
   If Found() .And. ! lChkDev
   	lRetorno := .T.
   EndIf	
   
	While lChkDev .And. TMPSF1->(F1_PESSOA == cPessoa .And. ! EOF())

	   If TMPSF1->F1_TIPO <> "2"
	   	lRetorno := .T.
      	EXIT
	   EndIf

   	dbSelectArea("TMPSF1")
		dbSkip()

	End	
EndIf

Return(lRetorno)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRel_ObrigatบAutor  ณPaulo Carnelossi   บ Data ณ  05/15/03   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime relacao com campos obrigatorios sem preencher       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Rel_Obrigat()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local wnrel
Local cDesc1 := STR0026 //"Este programa tem como objetivo imprimir os campos"
Local cDesc2 := STR0027 //"obrigatorios que nao estao preenchidos apos a carga"
Local cDesc3 := STR0028 //"dos arquivos para verificacao."
Local cString := "SA1"
Local Tamanho := "P"

PRIVATE cTitulo:= STR0022 //"Campos Obrigatorios nao Preenchidos"
PRIVATE cabec1
PRIVATE cabec2
Private aReturn := { STR0024, 1,STR0025, 2, 2, 1, "",1 }   //"Zebrado"###"Administracao"
Private cPerg   := ""
Private nomeprog:= "CPOSOBRG" 
Private nLastKey:=0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao dos cabecalhos                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cabec1:= STR0023 //"  Alias   Campo"
cabec2:= ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Envia controle para a funcao SETPRINT                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
wnrel := "CPOSOBRG"
wnrel := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho,,.F.)

If nLastKey == 27
   Return
End

SetDefault(aReturn,cString)

If nLastKey == 27
   Return ( NIL )
End

RptStatus({|lEnd| ObrigImp(@lEnd,wnRel,cString)},cTitulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณ Fun…o    ณ ObrigImp ณ Autor ณ Paulo Carnelossi      ณ Data ณ 15/05/03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Descri…o ณ Impressao Campos Obrigat๓rios sem preenchimento            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Sintaxe   ณ ObrigImp(lEnd,wnRel,cString                                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso       ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ObrigImp(lEnd,wnRel,cString)
Local cbcont,cbtxt
Local tamanho:= "P"
Local nTipo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

nTipo:=Iif(aReturn[4]==1,GetMv("MV_COMP"),GetMv("MV_NORM"))

DbUseArea(.T.,__LocalDriver,"OCORREN.LOG","OCO",.T.,.F.)

dbSelectArea("OCO")
SetRegua(RecCount())
dbGotop()

While OCO->(! Eof())
	
	IncRegua()

	IF li > 58
		cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	End

	@li,002 PSAY OCO->ALIAS
	@li,010 PSAY OCO->NOMECPO
	li++

	OCO->(dbSkip( ))
	
End

IF li != 80
	roda(cbcont,cbtxt,tamanho)
End
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Recupera a Integridade dos dados                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("OCO")
dbCloseArea()

Set Device To Screen

If aReturn[5] = 1
   Set Printer To
	dbCommitAll()
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTtabela   บAutor  ณPaulo Carnelossi    บ Data ณ  15/05/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria arquivo das tabelas a ser importada a partir do array  บฑฑ
ฑฑบ          ณfonte gerado a partir do DBF pela funcao Cr_Tab_Dados()     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Migra()                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ttabela()
Local aDbfCria,aStruDbf
Local cArqCpos, x, nCtd

aDbfCria := {}
aAdd(aDbfCria, {'S','R01','SA1','',''} )
aAdd(aDbfCria, {'S','','SA6','SA6',''} )
aAdd(aDbfCria, {'S','','SED','SED',''} )
aAdd(aDbfCria, {'N','R01','SA2','',''} )
aAdd(aDbfCria, {'S','','SE1','SE1',''} )
aAdd(aDbfCria, {'S','','SE2','SE2',''} )
aAdd(aDbfCria, {'N','','SEP','',''} )
aAdd(aDbfCria, {'S','','SM2','SM2',''} )
aAdd(aDbfCria, {'S','','SE5','SE5',''} )
aAdd(aDbfCria, {'N','','SE9','',''} )
aAdd(aDbfCria, {'S','R07','SA7','SP3',''} )
aAdd(aDbfCria, {'S','','SE8','SE8',''} )
aAdd(aDbfCria, {'S','R06','SB1','SB1',''} )
aAdd(aDbfCria, {'N','','SAH','SAH',''} )
aAdd(aDbfCria, {'S','','SBM','SBM',''} )
aAdd(aDbfCria, {'S','','SE6','SE4',''} )
aAdd(aDbfCria, {'S','R02','SC0','SC1',''} )
aAdd(aDbfCria, {'N','R02','SC1','',''} )
aAdd(aDbfCria, {'S','R03','SC7','SC7',''} )
aAdd(aDbfCria, {'N','R03','SC8','',''} )
aAdd(aDbfCria, {'S','','SB2','SB2',''} )
aAdd(aDbfCria, {'S','','SF1','SF1',''} )
aAdd(aDbfCria, {'S','','SD1','SD1',''} )
aAdd(aDbfCria, {'S','','SF4','SF4',''} )
aAdd(aDbfCria, {'N','R04','SFF','',''} )
aAdd(aDbfCria, {'N','','SFC','SFC','ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/SAL/EQU'} )
aAdd(aDbfCria, {'S','','SD3','SD3',''} )
aAdd(aDbfCria, {'S','','SF5','SF5',''} )
aAdd(aDbfCria, {'S','','SB9','SB9',''} )
aAdd(aDbfCria, {'S','','SD2','SD2',''} )
aAdd(aDbfCria, {'S','','SC5','SC5',''} )
aAdd(aDbfCria, {'S','','SC6','SC6',''} )
aAdd(aDbfCria, {'N','','SEA','SEA',''} )
aAdd(aDbfCria, {'N','','SFB','SFB','ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/SAL/EQU'} )
aAdd(aDbfCria, {'N','','SEK','SEK','ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/SAL/EQU'} )
aAdd(aDbfCria, {'N','','SEL','SEL','ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/SAL/EQU'} )
aAdd(aDbfCria, {'N','','SFE','SFE','ARG'} )
aAdd(aDbfCria, {'N','','SFG','SFG','ARG/PAR/URU/MEX/EUA/COL'} )
aAdd(aDbfCria, {'N','','SFH','SFH','ARG'} )
aAdd(aDbfCria, {'S','','SF2','SF2',''} )
aAdd(aDbfCria, {'S','','SG1','SG1',''} )
aAdd(aDbfCria, {'N','','SX6','SX6',''} )
aAdd(aDbfCria, {'N','','SF7','SF7','DOM'} )
aAdd(aDbfCria, {'N','R05','SA8','',''} )
aAdd(aDbfCria, {'S','','SC2','SC2',''} )
aAdd(aDbfCria, {'N','','SX1','SX1',''} )
aAdd(aDbfCria, {'S','','SD4','SD4',''} )
aAdd(aDbfCria, {'N','','SFI','SFI','DOM/URU'} )
aAdd(aDbfCria, {'N','','SAA','SAA',''} )
aAdd(aDbfCria, {'N','','SAB','SAB',''} )
aAdd(aDbfCria, {'N','','SEB','SEB',''} )
aAdd(aDbfCria, {'N','','SEC','SEC',''} )
aAdd(aDbfCria, {'N','','SEE','SEE',''} )
aAdd(aDbfCria, {'N','','SEF','SEF',''} )
aAdd(aDbfCria, {'N','','SBX','SBX',''} )
aAdd(aDbfCria, {'N','','SBZ','SBZ',''} )

aStruDbf := {}
aAdd(aStruDbf,{ 'MIGRA', 'C', 1, 0})
aAdd(aStruDbf,{ 'REGRA', 'C', 3, 0})
aAdd(aStruDbf,{ 'ALIAS', 'C', 3, 0})
aAdd(aStruDbf,{ 'ALIASMASTE', 'C', 3, 0})
aAdd(aStruDbf,{ 'PAISLOC', 'C', 100, 0})

cArqCpos := CriaTrab(aStruDbf)
DbUseArea(.T.,,cArqCpos,'TAB',.F.,.F.)

For x := 1 TO Len(aDbfCria)
   RecLock("TAB",.T.)
      For nCtd := 1 TO Len(aStruDbf)
         FieldPut(nCtd, aDbfCria[x][nCtd])
     Next
   MsUnLock()
Next

Return(cArqCpos)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTCampos() บAutor  ณPaulo Carnelossi    บ Data ณ  15/05/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria arquivo dos campos  a ser importada a partir do array  บฑฑ
ฑฑบ          ณfonte gerado a partir do DBF pela funcao Cr_Tab_Dados()     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Migra()                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tcampos()
Local aDbfCria,aStruDbf
Local cArqCpos, x, nCtd

aDbfCria := {}

aAdd(aDbfCria, {'S','SA1','','A1_PESSOA','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SA1','','A1_NOME','C', 40,  0,''} )
aAdd(aDbfCria, {'S','SA1','','A1_IDENT','C',  1,  0,'1=STR00011;2=STR00012;3=STR00013'} )
aAdd(aDbfCria, {'S','SA1','','A1_CGC','C', 14,  0,''} )
aAdd(aDbfCria, {'S','SA1','','A1_TIPO','C',  1,  0,'1=STR00076;2=STR00077;3=STR00078;4=STR00079;5=STR00080;6=STR00081;7=STR00032#POR'} )
aAdd(aDbfCria, {'S','SA1','','A1_INSCR','C', 18,  0,''} )
aAdd(aDbfCria, {'S','SA1','','A1_END','C', 50,  0,''} )
aAdd(aDbfCria, {'S','SA1','','A1_CEP','C',  8,  0,''} )
aAdd(aDbfCria, {'S','SA1','','A1_BAIRRO','C', 30,  0,''} )
aAdd(aDbfCria, {'S','SA1','','A1_MUN','C', 15,  0,''} )
aAdd(aDbfCria, {'S','SA1','','A1_EST','C',  2,  0,''} )
aAdd(aDbfCria, {'N','SA1','ARG','A1_PORGAN','N',  6,  2,''} )
aAdd(aDbfCria, {'N','SA1','DOM','A1_PERCIVA','C',  1,  0,'1=STR00089;2=STR00090'} )
aAdd(aDbfCria, {'N','SA1','ARG','A1_PERCIB','C',  1,  0,'1=STR00095;2=STR00096'} )
aAdd(aDbfCria, {'N','SA1','ARG','A1_NROIB','C', 10,  0,''} )
aAdd(aDbfCria, {'N','SA1','ARG','A1_AGREGAN','C',  2,  0,''} )
aAdd(aDbfCria, {'N','SA1','ARG','A1_RETIB','C',  1,  0,'1=STR00100;2=STR00101'} )
aAdd(aDbfCria, {'N','SA1','PAR','A1_RETIR','C',  1,  0,'1=STR00103;2=STR00104'} )
aAdd(aDbfCria, {'N','SA1','PAR/POR/EUA/COL/DOM','A1_RETIVA','C',  1,  0,'1=STR00106;2=STR00107'} )
aAdd(aDbfCria, {'N','SA1','POR/DOM','A1_RECISS','C',  1,  0,'1=STR00110;2=STR00111'} )
aAdd(aDbfCria, {'N','SA1','COL','A1_RETICA','C',  1,  0,'1=STR00113;2=STR00114'} )
aAdd(aDbfCria, {'N','SA1','MEX/PAR','A1_ATIVIDA','C',  5,  0,''} )
aAdd(aDbfCria, {'N','SA1','POR','A1_CARTREL','C',  1,  0,'1=STR00117;2=STR00118;3=STR00119'} )
aAdd(aDbfCria, {'N','SA1','EUA','A1_CODZON','C',  6,  0,''} )
aAdd(aDbfCria, {'N','SA1','COL','A1_CONTRBE','C',  1,  0,'1=STR00122;2=STR00123'} )
aAdd(aDbfCria, {'N','SA1','COL','A1_CODICA','C',  3,  0,''} )
aAdd(aDbfCria, {'N','SA1','COL','A1_RETFUEN','C',  1,  0,'1=STR00126;2=STR00127'} )
aAdd(aDbfCria, {'N','SA1','DOM','A1_GRPTRIB','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SA1','','A1_COMISS','N',  5,  2,''} )
aAdd(aDbfCria, {'N','SA1','','A1_COMEMIS','N',  3,  0,''} )
aAdd(aDbfCria, {'N','SA1','','A1_COMBX','N',  3,  0,''} )
aAdd(aDbfCria, {'S','SA1','','A1_FONE','C', 15,  0,''} )
aAdd(aDbfCria, {'S','SA1','','A1_EMAIL','C', 35,  0,''} )
aAdd(aDbfCria, {'N','SA1','','A1_HPAGE','C', 55,  0,''} )
aAdd(aDbfCria, {'N','SA1','','A1_FTP','C', 55,  0,''} )
aAdd(aDbfCria, {'N','SA1','','A1_TABELA','C',  1,  0,'1=&GetMv("MV_PRCVEN1");2=&GetMv("MV_PRCVEN2");3=&GetMv("MV_PRCVEN3")'} )
aAdd(aDbfCria, {'N','SA1','ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/SAL/EQU','A1_COMIMP','C',  1,  0,'1=STR00089;2=STR00090'} )
aAdd(aDbfCria, {'S','SA6','','A6_BANCO','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SA6','','A6_AGENCIA','C',  5,  0,''} )
aAdd(aDbfCria, {'S','SA6','','A6_CONTA','C', 10,  0,''} )
aAdd(aDbfCria, {'S','SA6','','A6_NOME','C', 40,  0,''} )
aAdd(aDbfCria, {'S','SA6','','A6_END','C', 40,  0,''} )
aAdd(aDbfCria, {'S','SA6','','A6_BAIRRO','C', 20,  0,''} )
aAdd(aDbfCria, {'S','SA6','','A6_MUN','C', 15,  0,''} )
aAdd(aDbfCria, {'S','SA6','','A6_CEP','C',  8,  0,''} )
aAdd(aDbfCria, {'S','SA6','','A6_EST','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SA6','','A6_TEL','C', 15,  0,''} )
aAdd(aDbfCria, {'S','SA6','','A6_CONTATO','C', 40,  0,''} )
aAdd(aDbfCria, {'S','SA6','','A6_FLUXO','C',  1,  0,'1=STR00149;2=STR00150'} )
aAdd(aDbfCria, {'N','SA6','','A6_MOEDA','C',  1,  0,'1=&GetMv("MV_MOEDA1");2=&GetMv("MV_MOEDA2");3=&GetMv("MV_MOEDA3");4=&GetMv("MV_MOEDA4");5=&GetMv("MV'} )
aAdd(aDbfCria, {'S','SED','','ED_CODCAT','C', 10,  0,''} )
aAdd(aDbfCria, {'S','SED','','ED_DESCRI','C', 40,  0,''} )
aAdd(aDbfCria, {'N','SED','','ED_TPCART','C',  1,  0,'1=STR00159;2=STR00160'} )
aAdd(aDbfCria, {'N','SA2','','A2_PESSOA','C',  6,  0,''} )
aAdd(aDbfCria, {'N','SA2','','A2_TIPO','C',  1,  0,'1=STR00169;2=STR00170'} )
aAdd(aDbfCria, {'N','SA2','','A2_END','C', 40,  0,''} )
aAdd(aDbfCria, {'N','SA2','','A2_CEP','C',  8,  0,''} )
aAdd(aDbfCria, {'N','SA2','','A2_BAIRRO','C', 30,  0,''} )
aAdd(aDbfCria, {'N','SA2','','A2_MUN','C', 30,  0,''} )
aAdd(aDbfCria, {'N','SA2','','A2_EST','C',  2,  0,''} )
aAdd(aDbfCria, {'N','SA2','','A2_FONE','C', 15,  0,''} )
aAdd(aDbfCria, {'N','SA2','','A2_CONTATO','C', 40,  0,''} )
aAdd(aDbfCria, {'N','SA2','','A2_EMAIL','C', 40,  0,''} )
aAdd(aDbfCria, {'S','SE1','','E1_NUM','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SE1','','E1_PARCELA','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SE1','','E1_TIPO','C',  1,  0,'1=STR00198;2=STR00199;3=STR00200;4=STR00201;5=STR00202;6=STR00203;7=STR00204;8=STR00205;9=STR00560#A'} )
aAdd(aDbfCria, {'S','SE1','','E1_PESSOA','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SE1','','E1_NOME','C', 40,  0,''} )
aAdd(aDbfCria, {'S','SE1','','E1_SERIE','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SE1','','E1_EMISSAO','D',  8,  0,''} )
aAdd(aDbfCria, {'S','SE1','','E1_CODCAT','C', 10,  0,''} )
aAdd(aDbfCria, {'S','SE1','','E1_VENCTO','D',  8,  0,''} )
aAdd(aDbfCria, {'S','SE1','','E1_VENCREA','D',  8,  0,''} )
aAdd(aDbfCria, {'S','SE1','','E1_VALOR','N', 17,  2,''} )
aAdd(aDbfCria, {'S','SE1','','E1_BANCO','C',  3,  0,''} )
aAdd(aDbfCria, {'N','SE1','','E1_AGENCIA','C',  5,  0,''} )
aAdd(aDbfCria, {'N','SE1','','E1_CONTA','C', 10,  0,''} )
aAdd(aDbfCria, {'N','SE1','','E1_DESCRI','C', 30,  0,''} )
aAdd(aDbfCria, {'S','SE1','','E1_SALDO','N', 17,  2,''} )
aAdd(aDbfCria, {'S','SE1','','E1_MOEDA','C',  1,  0,'1=&GetMv("MV_MOEDA1");2=&GetMv("MV_MOEDA2");3=&GetMv("MV_MOEDA3");4=&GetMv("MV_MOEDA4");5=&GetMv("MV'} )
aAdd(aDbfCria, {'N','SE1','','E1_RECIBO','C',  6,  0,''} )
aAdd(aDbfCria, {'N','SE1','ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/SAL/EQU','E1_ORDPAGO','C',  6,  0,''} )
aAdd(aDbfCria, {'N','SE1','ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/SAL/EQU','E1_DTACRED','D',  8,  0,''} )
aAdd(aDbfCria, {'N','SE1','ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/SAL/EQU','E1_VLCRUZ','N', 17,  2,''} )
aAdd(aDbfCria, {'S','SE2','','E2_NUM','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SE2','','E2_PARCELA','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SE2','','E2_TIPO','C',  1,  0,'1=STR00242;2=STR00243;3=STR00244;4=STR00245;5=STR00246;6=STR00247;7=STR00248;8=STR00249;9=STR00560#A'} )
aAdd(aDbfCria, {'S','SE2','','E2_PESSOA','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SE2','','E2_NOME','C', 40,  0,''} )
aAdd(aDbfCria, {'S','SE2','','E2_SERIE','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SE2','','E2_EMISSAO','D',  8,  0,''} )
aAdd(aDbfCria, {'S','SE2','','E2_CODCAT','C', 10,  0,''} )
aAdd(aDbfCria, {'S','SE2','','E2_VENCTO','D',  8,  0,''} )
aAdd(aDbfCria, {'S','SE2','','E2_VENCREA','D',  8,  0,''} )
aAdd(aDbfCria, {'S','SE2','','E2_VALOR','N', 17,  2,''} )
aAdd(aDbfCria, {'S','SE2','','E2_BANCO','C',  3,  0,''} )
aAdd(aDbfCria, {'N','SE2','','E2_AGENCIA','C',  5,  0,''} )
aAdd(aDbfCria, {'N','SE2','','E2_CONTA','C', 10,  0,''} )
aAdd(aDbfCria, {'N','SE2','','E2_DESCRI','C', 30,  0,''} )
aAdd(aDbfCria, {'S','SE2','','E2_SALDO','N', 17,  2,''} )
aAdd(aDbfCria, {'S','SE2','','E2_MOEDA','C',  1,  0,'1=&GetMv("MV_MOEDA1");2=&GetMv("MV_MOEDA2");3=&GetMv("MV_MOEDA3");4=&GetMv("MV_MOEDA4");5=&GetMv("MV'} )
aAdd(aDbfCria, {'S','SE2','','E2_EMISS1','D',  8,  0,''} )
aAdd(aDbfCria, {'N','SE2','ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/SAL/EQU','E2_ORDPAGO','C',  6,  0,''} )
aAdd(aDbfCria, {'N','SE2','','E2_DTDIGIT','D',  8,  0,''} )
aAdd(aDbfCria, {'N','SE2','ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/SAL/EQU','E2_VLCRUZ','N', 17,  2,''} )
aAdd(aDbfCria, {'N','SEP','','EP_BANCO','C',  3,  0,''} )
aAdd(aDbfCria, {'N','SEP','','EP_AGENCIA','C',  5,  0,''} )
aAdd(aDbfCria, {'N','SEP','','EP_CONTA','C', 10,  0,''} )
aAdd(aDbfCria, {'N','SEP','','EP_TPCART','C',  1,  0,'1=STR00276;2=STR00277'} )
aAdd(aDbfCria, {'N','SEP','','EP_DESCRI','C', 30,  0,''} )
aAdd(aDbfCria, {'N','SEP','','EP_PROXDAT','D',  8,  0,''} )
aAdd(aDbfCria, {'N','SEP','','EP_CODCAT','C', 10,  0,''} )
aAdd(aDbfCria, {'N','SEP','','EP_VALOR','N', 17,  2,''} )
aAdd(aDbfCria, {'N','SEP','','EP_FREQUEN','C',  1,  0,'1=STR00283;2=STR00284;3=STR00285;4=STR00286'} )
aAdd(aDbfCria, {'N','SEP','','EP_NUMPAG','N',  3,  0,''} )
aAdd(aDbfCria, {'N','SEP','','EP_INCLUI','C',  1,  0,'1=STR00289;2=STR00290'} )
aAdd(aDbfCria, {'N','SEP','','EP_DIASANT','N',  1,  0,''} )
aAdd(aDbfCria, {'N','SEP','','EP_MOEDA','C',  1,  0,'1=&GetMv("MV_MOEDA1");2=&GetMv("MV_MOEDA2");3=&GetMv("MV_MOEDA3");4=&GetMv("MV_MOEDA4");5=&GetMv("MV'} )
aAdd(aDbfCria, {'N','SEP','','EP_PESSOA','C',  6,  0,''} )
aAdd(aDbfCria, {'N','SEP','','EP_TIPO','C',  1,  0,'1=STR00198;2=STR00199;3=STR00200;4=STR00201;5=STR00202;6=STR00203;7=STR00204;8=STR00205;9=STR00560#A'} )
aAdd(aDbfCria, {'N','SEP','','EP_PROXFLX','D',  8,  0,''} )
aAdd(aDbfCria, {'N','SEP','','EP_NPAGFLX','N',  3,  0,''} )
aAdd(aDbfCria, {'S','SM2','','M2_DATA','D',  8,  0,''} )
aAdd(aDbfCria, {'S','SM2','','M2_MOEDA2','N', 11,  4,''} )
aAdd(aDbfCria, {'S','SM2','','M2_MOEDA3','N', 11,  4,''} )
aAdd(aDbfCria, {'S','SM2','','M2_MOEDA4','N', 11,  4,''} )
aAdd(aDbfCria, {'S','SM2','','M2_MOEDA5','N', 11,  4,''} )
aAdd(aDbfCria, {'S','SE5','','E5_SERIE','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SE5','','E5_NUM','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SE5','','E5_PARCELA','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SE5','','E5_TIPO','C',  1,  0,'1=STR00325;2=STR00326;3=STR00327;4=STR00328;5=STR00329;6=STR00330;7=STR00331;8=STR00332;9=STR01169;A'} )
aAdd(aDbfCria, {'S','SE5','','E5_PESSOA','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SE5','','E5_DATA','D',  8,  0,''} )
aAdd(aDbfCria, {'S','SE5','','E5_CODCAT','C', 10,  0,''} )
aAdd(aDbfCria, {'S','SE5','','E5_HISTORI','C', 50,  0,''} )
aAdd(aDbfCria, {'S','SE5','','E5_VALPAG','N', 17,  2,''} )
aAdd(aDbfCria, {'N','SE5','ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/SAL/EQU','E5_VALBCO','N', 17,  2,''} )
aAdd(aDbfCria, {'S','SE5','','E5_BANCO','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SE5','','E5_AGENCIA','C',  5,  0,''} )
aAdd(aDbfCria, {'S','SE5','','E5_CONTA','C', 10,  0,''} )
aAdd(aDbfCria, {'S','SE5','','E5_NUMCHEQ','C', 15,  0,''} )
aAdd(aDbfCria, {'S','SE5','','E5_RECPAG','C',  1,  0,''} )
aAdd(aDbfCria, {'S','SE5','','E5_JUROS','N', 17,  2,''} )
aAdd(aDbfCria, {'S','SE5','','E5_MULTA','N', 17,  2,''} )
aAdd(aDbfCria, {'S','SE5','','E5_DESC','N', 17,  2,''} )
aAdd(aDbfCria, {'S','SE5','','E5_TPMOV','C',  1,  0,'1=STR00352;2=STR00353;3=STR00354;4=STR00355#ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/'} )
aAdd(aDbfCria, {'S','SE5','','E5_SITUACA','C',  1,  0,''} )
aAdd(aDbfCria, {'S','SE5','','E5_ORDREC','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SE5','','E5_DTDIGIT','D',  8,  0,''} )
aAdd(aDbfCria, {'N','SE5','','E5_MOVBCO','C',  1,  0,'1=STR00360;2=STR00361'} )
aAdd(aDbfCria, {'N','SE9','','E9_CODCAT','C', 10,  0,''} )
aAdd(aDbfCria, {'N','SE9','','E9_DTINIC','D',  8,  0,''} )
aAdd(aDbfCria, {'N','SE9','','E9_DTFINAL','D',  8,  0,''} )
aAdd(aDbfCria, {'N','SE9','','E9_VALOR','N', 17,  2,''} )
aAdd(aDbfCria, {'N','SE9','','E9_MOEDA','C',  1,  0,'1=&GetMv("MV_MOEDA1");2=&GetMv("MV_MOEDA2");3=&GetMv("MV_MOEDA3");4=&GetMv("MV_MOEDA4");5=&GetMv("MV'} )
aAdd(aDbfCria, {'N','SA7','','A7_DIA','C',  2,  0,''} )
aAdd(aDbfCria, {'N','SA7','','A7_MES','C',  2,  0,''} )
aAdd(aDbfCria, {'N','SA7','','A7_ANO','C',  4,  0,''} )
aAdd(aDbfCria, {'N','SA7','','A7_DESCRI','C', 30,  0,''} )
aAdd(aDbfCria, {'S','SE8','','E8_BANCO','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SE8','','E8_AGENCIA','C',  5,  0,''} )
aAdd(aDbfCria, {'S','SE8','','E8_CONTA','C', 10,  0,''} )
aAdd(aDbfCria, {'S','SE8','','E8_DATA','D',  8,  0,''} )
aAdd(aDbfCria, {'S','SE8','','E8_VALOR','N', 17,  2,''} )
aAdd(aDbfCria, {'S','SB1','','B1_CODPROD','C', 15,  0,''} )
aAdd(aDbfCria, {'S','SB1','','B1_DESCRI','C', 30,  0,''} )
aAdd(aDbfCria, {'S','SB1','','B1_TIPO','C',  1,  0,'1=STR00397;2=STR00398;3=STR00399;4=STR00400;5=STR00401'} )
aAdd(aDbfCria, {'S','SB1','','B1_CODUM','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SB1','','B1_LOCAL','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SB1','','B1_CODGRP','C',  4,  0,''} )
aAdd(aDbfCria, {'S','SB1','','B1_PRV1','N', 12,  2,''} )
aAdd(aDbfCria, {'S','SB1','','B1_UPRC','N', 12,  2,''} )
aAdd(aDbfCria, {'S','SB1','','B1_UCOM','D',  8,  0,''} )
aAdd(aDbfCria, {'S','SB1','','B1_EMIN','N', 12,  0,''} )
aAdd(aDbfCria, {'S','SB1','','B1_ESTSEG','N', 12,  2,''} )
aAdd(aDbfCria, {'S','SB1','','B1_PE','N',  5,  0,''} )
aAdd(aDbfCria, {'S','SB1','','B1_TIPE','C',  1,  0,'1=STR00412;2=STR00413;3=STR00414;4=STR00415;5=STR00416'} )
aAdd(aDbfCria, {'S','SB1','','B1_LE','N', 12,  2,''} )
aAdd(aDbfCria, {'S','SB1','','B1_LM','N', 12,  2,''} )
aAdd(aDbfCria, {'S','SB1','','B1_TIPODEC','C',  1,  0,'1=STR00420;2=STR00421'} )
aAdd(aDbfCria, {'S','SB1','','B1_PICM','N',  5,  2,''} )
aAdd(aDbfCria, {'S','SB1','','B1_IPI','N',  5,  2,''} )
aAdd(aDbfCria, {'S','SB1','','B1_ALIQISS','N',  5,  2,''} )
aAdd(aDbfCria, {'S','SB1','','B1_PICMENT','N',  6,  2,''} )
aAdd(aDbfCria, {'S','SB1','','B1_PICMRET','N',  6,  2,''} )
aAdd(aDbfCria, {'N','SB1','ARG','B1_CONCGAN','C',  2,  0,''} )
aAdd(aDbfCria, {'N','SB1','DOM','B1_PERCIVA','C',  1,  0,'1=STR00432;2=STR00433'} )
aAdd(aDbfCria, {'S','SB1','','B1_QB','N',  7,  0,''} )
aAdd(aDbfCria, {'N','SB1','POR','B1_CONVACE','N',  5,  2,''} )
aAdd(aDbfCria, {'N','SB1','COL','B1_BSGRAV','C',  1,  0,'0=STR00437;1=STR00438;2=STR00439'} )
aAdd(aDbfCria, {'N','SB1','URU/DOM','B1_GRTRIB','C',  3,  0,''} )
aAdd(aDbfCria, {'N','SB1','URU','B1_VLFICTO','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SB1','','B1_NCM','C', 10,  0,''} )
aAdd(aDbfCria, {'N','SB1','','B1_PRV2','N', 12,  2,''} )
aAdd(aDbfCria, {'N','SB1','','B1_PRV3','N', 12,  2,''} )
aAdd(aDbfCria, {'S','SB1','','B1_CUSTD','N', 12,  2,''} )
aAdd(aDbfCria, {'S','SB1','','B1_DATREF','D',  8,  0,''} )
aAdd(aDbfCria, {'S','SB1','','B1_MCUSTD','C',  1,  0,'1=&GetMv("MV_MOEDA1");2=&GetMv("MV_MOEDA2");3=&GetMv("MV_MOEDA3");4=&GetMv("MV_MOEDA4");5=&GetMv("MV'} )
aAdd(aDbfCria, {'S','SB1','','B1_UCALSTD','D',  8,  0,''} )
aAdd(aDbfCria, {'S','SB1','','B1_TE','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SB1','','B1_TS','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SB1','','B1_FORAEST','C',  1,  0,'1=STR00719;2=STR00720'} )
aAdd(aDbfCria, {'S','SAH','','AH_CODUM','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SAH','','AH_DESCRI','C', 30,  0,''} )
aAdd(aDbfCria, {'S','SBM','','BM_CODGRP','C',  4,  0,''} )
aAdd(aDbfCria, {'S','SBM','','BM_DESCRI','C', 30,  0,''} )
aAdd(aDbfCria, {'S','SE6','','E6_CODCND','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SE6','','E6_TIPO','C',  1,  0,''} )
aAdd(aDbfCria, {'N','SE6','','E6_DESCTP','C',110,  0,''} )
aAdd(aDbfCria, {'S','SE6','','E6_COND','C', 40,  0,''} )
aAdd(aDbfCria, {'S','SE6','','E6_DESCRI','C', 20,  0,''} )
aAdd(aDbfCria, {'S','SE6','','E6_DDD','C',  1,  0,'1=STR00465;2=STR00466;3=STR00467;4=STR00468;5=STR00469;6=STR00470'} )
aAdd(aDbfCria, {'S','SC0','','C0_NUMSOL','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SC0','','C0_SOLICIT','C', 20,  0,''} )
aAdd(aDbfCria, {'S','SC0','','C0_EMISSAO','D',  8,  0,''} )
aAdd(aDbfCria, {'N','SC0','','C0_STATUS','C',  1,  0,''} )
aAdd(aDbfCria, {'N','SC1','','C1_NUMSOL','C',  6,  0,''} )
aAdd(aDbfCria, {'N','SC1','','C1_ITEM','C',  2,  0,''} )
aAdd(aDbfCria, {'N','SC1','','C1_CODPROD','C', 15,  0,''} )
aAdd(aDbfCria, {'N','SC1','','C1_DESCRI','C', 30,  0,''} )
aAdd(aDbfCria, {'N','SC1','','C1_CODUM','C',  2,  0,''} )
aAdd(aDbfCria, {'N','SC1','','C1_QUANT','N', 12,  2,''} )
aAdd(aDbfCria, {'N','SC1','','C1_DATPRF','D',  8,  0,''} )
aAdd(aDbfCria, {'N','SC1','','C1_LOCAL','C',  2,  0,''} )
aAdd(aDbfCria, {'N','SC1','','C1_OBS','C', 30,  0,''} )
aAdd(aDbfCria, {'N','SC1','','C1_OP','C', 11,  0,''} )
aAdd(aDbfCria, {'N','SC1','','C1_QUJE','N', 12,  2,''} )
aAdd(aDbfCria, {'S','SC7','','C7_NUMPED','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SC7','','C7_EMISSAO','D',  8,  0,''} )
aAdd(aDbfCria, {'S','SC7','','C7_CONTATO','C', 20,  0,''} )
aAdd(aDbfCria, {'S','SC7','','C7_PESSOA','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SC7','','C7_COND','C',  3,  0,''} )
aAdd(aDbfCria, {'N','SC7','','C7_STATUS','C',  1,  0,''} )
aAdd(aDbfCria, {'N','SC7','ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/SAL/EQU','C7_MOEDA','C',  1,  0,'1=&GetMv("MV_MOEDA1");2=&GetMv("MV_MOEDA2");3=&GetMv("MV_MOEDA3");4=&GetMv("MV_MOEDA4");5=&GetMv("MV'} )
aAdd(aDbfCria, {'N','SC7','ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/SAL/EQU','C7_TXMOEDA','N', 11,  4,''} )
aAdd(aDbfCria, {'N','SC8','','C8_NUMPED','C',  6,  0,''} )
aAdd(aDbfCria, {'N','SC8','','C8_ITEM','C',  2,  0,''} )
aAdd(aDbfCria, {'N','SC8','','C8_CODPROD','C', 15,  0,''} )
aAdd(aDbfCria, {'N','SC8','','C8_CODUM','C',  2,  0,''} )
aAdd(aDbfCria, {'N','SC8','','C8_QUANT','N', 12,  2,''} )
aAdd(aDbfCria, {'N','SC8','','C8_PRCUNI','N', 12,  2,''} )
aAdd(aDbfCria, {'N','SC8','','C8_TOTAL','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC8','','C8_DATPRF','D',  8,  0,''} )
aAdd(aDbfCria, {'N','SC8','','C8_LOCAL','C',  2,  0,''} )
aAdd(aDbfCria, {'N','SC8','','C8_OBS','C', 30,  0,''} )
aAdd(aDbfCria, {'N','SC8','','C8_DESCRI','C', 30,  0,''} )
aAdd(aDbfCria, {'N','SC8','','C8_QUJE','N', 12,  2,''} )
aAdd(aDbfCria, {'N','SC8','','C8_NUMSC','C',  6,  0,''} )
aAdd(aDbfCria, {'N','SC8','','C8_ITEMSC','C',  2,  0,''} )
aAdd(aDbfCria, {'N','SC8','','C8_QTDSC','N', 12,  2,''} )
aAdd(aDbfCria, {'N','SC8','','C8_PESSOA','C',  6,  0,''} )
aAdd(aDbfCria, {'N','SC8','','C8_OP','C', 11,  0,''} )
aAdd(aDbfCria, {'S','SB2','','B2_CODPROD','C', 15,  0,''} )
aAdd(aDbfCria, {'N','SB2','','B2_DESCRI','C', 30,  0,''} )
aAdd(aDbfCria, {'S','SB2','','B2_LOCAL','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SB2','','B2_QATU','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SB2','','B2_QFIM','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SB2','','B2_SALSC','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SB2','','B2_SALPC','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SB2','','B2_SALOPE','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SB2','','B2_SALOPS','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SB2','','B2_SALPV','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SB2','','B2_CM1','N', 14,  4,''} )
aAdd(aDbfCria, {'S','SB2','','B2_CM2','N', 14,  4,''} )
aAdd(aDbfCria, {'S','SB2','','B2_CM3','N', 14,  4,''} )
aAdd(aDbfCria, {'S','SB2','','B2_CM4','N', 14,  4,''} )
aAdd(aDbfCria, {'S','SB2','','B2_CM5','N', 14,  4,''} )
aAdd(aDbfCria, {'S','SB2','','B2_VFIM1','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SB2','','B2_VFIM2','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SB2','','B2_VFIM3','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SB2','','B2_VFIM4','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SB2','','B2_VFIM5','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SB2','','B2_VATU1','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SB2','','B2_VATU2','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SB2','','B2_VATU3','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SB2','','B2_VATU4','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SB2','','B2_VATU5','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF1','','F1_TIPO','C',  1,  0,'1=STR00552;2=STR00553;3=STR00554;4=STR00555;5=STR00556#ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/C'} )
aAdd(aDbfCria, {'S','SF1','','F1_FORMUL','C',  1,  0,'1=STR00558;2=STR00559'} )
aAdd(aDbfCria, {'S','SF1','','F1_DOC','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SF1','','F1_SERIE','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SF1','','F1_PESSOA','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SF1','','F1_EMISSAO','D',  8,  0,''} )
aAdd(aDbfCria, {'S','SF1','','F1_COND','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SF1','','F1_EST','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SF1','','F1_FRETE','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF1','','F1_DESPESA','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF1','','F1_VALDESC','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF1','','F1_BASEICM','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF1','','F1_VALICM','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF1','','F1_BASEIPI','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF1','','F1_VALIPI','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF1','','F1_VALMERC','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF1','','F1_VALBRUT','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF1','','F1_BRICMS','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF1','','F1_ICMSRET','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF1','','F1_IRRF','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF1','','F1_INSS','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF1','','F1_ISS','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SF1','ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/SAL/EQU','F1_ESPECIE','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SF1','','F1_BASIMP1','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF1','','F1_BASIMP2','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF1','','F1_BASIMP3','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF1','','F1_BASIMP4','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF1','','F1_BASIMP5','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF1','','F1_BASIMP6','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SF1','ARG','F1_BASIMP7','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SF1','ARG','F1_BASIMP8','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SF1','ARG','F1_BASIMP9','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF1','','F1_VALIMP1','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF1','','F1_VALIMP2','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF1','','F1_VALIMP3','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF1','','F1_VALIMP4','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF1','','F1_VALIMP5','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF1','','F1_VALIMP6','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SF1','ARG','F1_VALIMP7','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SF1','ARG','F1_VALIMP8','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SF1','ARG','F1_VALIMP9','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SF1','ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/SAL/EQU','F1_MOEDA','C',  1,  0,'1=&GetMv("MV_MOEDA1");2=&GetMv("MV_MOEDA2");3=&GetMv("MV_MOEDA3");4=&GetMv("MV_MOEDA4");5=&GetMv("MV'} )
aAdd(aDbfCria, {'N','SF1','ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/SAL/EQU','F1_TXMOEDA','N', 11,  4,''} )
aAdd(aDbfCria, {'S','SD1','','D1_TIPO','C',  1,  0,'1=STR00610;2=STR00611;3=STR00612'} )
aAdd(aDbfCria, {'S','SD1','','D1_DOC','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SD1','','D1_SERIE','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SD1','','D1_PESSOA','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SD1','','D1_ITEM','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SD1','','D1_CODPROD','C', 15,  0,''} )
aAdd(aDbfCria, {'S','SD1','','D1_CODUM','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SD1','','D1_QUANT','N', 12,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_PRCUNI','N', 12,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_TOTAL','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_VALIPI','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_VALICM','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_TES','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SD1','','D1_CFOP','C',  5,  0,''} )
aAdd(aDbfCria, {'S','SD1','','D1_VALDESC','N', 12,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_IPI','N',  5,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_PICM','N',  5,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_BASEIPI','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_BASEICM','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_LOCAL','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SD1','','D1_NUMPED','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SD1','','D1_ITEMPC','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SD1','','D1_QTDPC','N', 12,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_ICMSRET','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_BRICMS','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_BASEISS','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_ALIQISS','N',  5,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_VALISS','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_BASEINS','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_ALIQINS','N',  5,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_VALINS','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_VALCMP','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_FRETE','N', 12,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_DESPESA','N', 12,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_QTDDEV','N', 12,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_DTDIGIT','D',  8,  0,''} )
aAdd(aDbfCria, {'S','SD1','','D1_EMISSAO','D',  8,  0,''} )
aAdd(aDbfCria, {'S','SD1','','D1_NFORI','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SD1','','D1_SERIORI','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SD1','','D1_ITEMORI','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SD1','','D1_BASIMP1','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_BASIMP2','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_BASIMP3','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_BASIMP4','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_BASIMP5','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_BASIMP6','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SD1','ARG','D1_BASIMP7','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SD1','ARG','D1_BASIMP8','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SD1','ARG','D1_BASIMP9','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_VALIMP1','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_VALIMP2','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_VALIMP3','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_VALIMP4','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_VALIMP5','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_VALIMP6','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SD1','ARG','D1_VALIMP7','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SD1','ARG','D1_VALIMP8','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SD1','ARG','D1_VALIMP9','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_ALQIMP1','N',  6,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_ALQIMP2','N',  6,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_ALQIMP3','N',  6,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_ALQIMP4','N',  6,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_ALQIMP5','N',  6,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_ALQIMP6','N',  6,  2,''} )
aAdd(aDbfCria, {'N','SD1','ARG','D1_ALQIMP7','N',  6,  2,''} )
aAdd(aDbfCria, {'N','SD1','ARG','D1_ALQIMP8','N',  6,  2,''} )
aAdd(aDbfCria, {'N','SD1','ARG','D1_ALQIMP9','N',  6,  2,''} )
aAdd(aDbfCria, {'N','SD1','ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/SAL/EQU','D1_REMITO','C',  6,  0,''} )
aAdd(aDbfCria, {'N','SD1','ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/SAL/EQU','D1_SERIREM','C',  3,  0,''} )
aAdd(aDbfCria, {'N','SD1','ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/SAL/EQU','D1_ITEMREM','C',  2,  0,''} )
aAdd(aDbfCria, {'N','SD1','ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/SAL/EQU','D1_QTDCLAS','N', 12,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_CUSTO1','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_CUSTO2','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_CUSTO3','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_CUSTO4','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_CUSTO5','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD1','','D1_NUMSEQ','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SD1','','D1_SEQCALC','C', 14,  0,''} )
aAdd(aDbfCria, {'S','SF4','','F4_COD','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SF4','','F4_TIPO','C',  1,  0,'1=STR00712;2=STR00713'} )
aAdd(aDbfCria, {'S','SF4','','F4_DESCRI','C', 30,  0,''} )
aAdd(aDbfCria, {'S','SF4','','F4_DUPLIC','C',  1,  0,'1=STR00716;2=STR00717'} )
aAdd(aDbfCria, {'S','SF4','','F4_ESTOQUE','C',  1,  0,'1=STR00719;2=STR00720'} )
aAdd(aDbfCria, {'S','SF4','','F4_CF','C',  5,  0,''} )
aAdd(aDbfCria, {'S','SF4','','F4_TESDV','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SF4','','F4_ICM','C',  1,  0,'1=STR00724;2=STR00725'} )
aAdd(aDbfCria, {'S','SF4','','F4_IPI','C',  1,  0,'1=STR00727;2=STR00728;3=STR00729'} )
aAdd(aDbfCria, {'S','SF4','','F4_INCIDE','C',  1,  0,'1=STR00731;2=STR00732'} )
aAdd(aDbfCria, {'S','SF4','','F4_COMPL','C',  1,  0,'1=STR00734;2=STR00735'} )
aAdd(aDbfCria, {'S','SF4','','F4_IPIFRET','C',  1,  0,'1=STR00737;2=STR00738'} )
aAdd(aDbfCria, {'S','SF4','','F4_ISS','C',  1,  0,'1=STR00740;2=STR00741'} )
aAdd(aDbfCria, {'S','SF4','','F4_INCSOL','C',  1,  0,'1=STR00743;2=STR00744'} )
aAdd(aDbfCria, {'S','SF4','','F4_DESPIPI','C',  1,  0,'1=STR00746;2=STR00747'} )
aAdd(aDbfCria, {'S','SF4','','F4_CREDICM','C',  1,  0,'1=STR00724;2=STR00725'} )
aAdd(aDbfCria, {'S','SF4','','F4_CREDIPI','C',  1,  0,'1=STR00724;2=STR00725'} )
aAdd(aDbfCria, {'S','SF4','','F4_BASEIPI','N',  6,  2,''} )
aAdd(aDbfCria, {'S','SF4','','F4_BASEICM','N',  6,  2,''} )
aAdd(aDbfCria, {'N','SFF','','FF_COD','C',  5,  0,''} )
aAdd(aDbfCria, {'N','SFF','','FF_DESCRI','C', 50,  0,''} )
aAdd(aDbfCria, {'N','SFC','','FC_COD','C',  3,  0,''} )
aAdd(aDbfCria, {'N','SFC','','FC_ITEM','C',  2,  0,''} )
aAdd(aDbfCria, {'N','SFC','','FC_IMPOSTO','C',  3,  0,''} )
aAdd(aDbfCria, {'N','SFC','','FC_INCDUPL','C',  1,  0,'1=STR00762;2=STR00763;3=STR00764'} )
aAdd(aDbfCria, {'N','SFC','','FC_INCNOTA','C',  1,  0,'1=STR00766;2=STR00767;3=STR00768'} )
aAdd(aDbfCria, {'N','SFC','','FC_CREDITA','C',  1,  0,'1=STR00762;2=STR00763;3=STR00764'} )
aAdd(aDbfCria, {'N','SFC','','FC_INCIMP','C',  3,  0,''} )
aAdd(aDbfCria, {'N','SFC','','FC_BASE','N',  5,  2,''} )
aAdd(aDbfCria, {'N','SFC','','FC_CALCULO','C',  1,  0,'1=STR00772;2=STR00773'} )
aAdd(aDbfCria, {'N','SFC','','FC_LIQUIDO','C',  1,  0,'1=STR00775;2=STR00776'} )
aAdd(aDbfCria, {'S','SD3','','D3_CODTM','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SD3','','D3_CODPROD','C', 15,  0,''} )
aAdd(aDbfCria, {'S','SD3','','D3_DESCRI','C', 30,  0,''} )
aAdd(aDbfCria, {'S','SD3','','D3_LOCAL','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SD3','','D3_CODUM','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SD3','','D3_EMISSAO','D',  8,  0,''} )
aAdd(aDbfCria, {'S','SD3','','D3_OP','C', 11,  0,''} )
aAdd(aDbfCria, {'S','SD3','','D3_QUANT','N', 11,  2,''} )
aAdd(aDbfCria, {'S','SD3','','D3_PARCTOT','C',  1,  0,'1=STR00792;2=STR00793'} )
aAdd(aDbfCria, {'S','SD3','','D3_DOC','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SD3','','D3_ESTORNO','C',  1,  0,''} )
aAdd(aDbfCria, {'S','SD3','','D3_CF','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SD3','','D3_CUSTO1','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD3','','D3_CUSTO2','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD3','','D3_CUSTO3','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD3','','D3_CUSTO4','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD3','','D3_CUSTO5','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD3','','D3_NUMSEQ','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SD3','','D3_SEQCALC','C', 14,  0,''} )
aAdd(aDbfCria, {'N','SD3','','D3_VALOR','C',  1,  0,'1=STR00727;2=STR00728'} )
aAdd(aDbfCria, {'S','SD3','','D3_IDENT','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SD3','','D3_TRT','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SF5','','F5_CODTM','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SF5','','F5_TIPO','C',  1,  0,'1=STR00802;2=STR00803;3=STR00804'} )
aAdd(aDbfCria, {'S','SF5','','F5_DESCRI','C', 20,  0,''} )
aAdd(aDbfCria, {'S','SF5','','F5_ATUEMP','C',  1,  0,'1=STR00807;2=STR00808'} )
aAdd(aDbfCria, {'S','SB9','','B9_CODPROD','C', 15,  0,''} )
aAdd(aDbfCria, {'S','SB9','','B9_LOCAL','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SB9','','B9_QINI','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SB9','','B9_DATA','D',  8,  0,''} )
aAdd(aDbfCria, {'S','SB9','','B9_VINI1','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SB9','','B9_VINI2','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SB9','','B9_VINI3','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SB9','','B9_VINI4','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SB9','','B9_VINI5','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_TIPO','C',  1,  0,'1=STR00828;2=STR00829;3=STR00830;4=STR00831;5=STR00832#ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/C'} )
aAdd(aDbfCria, {'S','SD2','','D2_DOC','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SD2','','D2_SERIE','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SD2','','D2_PESSOA','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SD2','','D2_ITEM','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SD2','','D2_CODPROD','C', 15,  0,''} )
aAdd(aDbfCria, {'S','SD2','','D2_CODUM','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SD2','','D2_QUANT','N', 12,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_PRCUNI','N', 12,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_TOTAL','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_VALIPI','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_VALICM','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_TES','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SD2','','D2_CFOP','C',  5,  0,''} )
aAdd(aDbfCria, {'S','SD2','','D2_VALDESC','N', 12,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_IPI','N',  5,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_PICM','N',  5,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_BASEIPI','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_BASEICM','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_LOCAL','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SD2','','D2_NUMPED','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SD2','','D2_ITEMPV','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SD2','','D2_ICMSRET','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_BRICMS','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_BASEISS','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_ALIQISS','N',  5,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_VALISS','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_BASEINS','N', 14,  2,''} )

Cont_Tcampos(aDbfCria)  //quebrado em outra funcao continuacacao
                        //pois compilacao dava erro memory overbook

aStruDbf := {}
aAdd(aStruDbf,{ 'MIGRA', 'C', 1, 0})
aAdd(aStruDbf,{ 'ALIAS', 'C', 3, 0})
aAdd(aStruDbf,{ 'PAISLOC', 'C', 100, 0})
aAdd(aStruDbf,{ 'NOMECPO', 'C', 10, 0})
aAdd(aStruDbf,{ 'TIPOCPO', 'C', 1, 0})
aAdd(aStruDbf,{ 'TAMCPO', 'N', 3, 0})
aAdd(aStruDbf,{ 'DECCPO', 'N', 3, 0})
aAdd(aStruDbf,{ 'COMBCPO', 'C', 100, 0})

cArqCpos := CriaTrab(aStruDbf)
DbUseArea(.T.,,cArqCpos,'TCP',.F.,.F.)
IndRegua("TCP",cArqCpos,"ALIAS+NOMECPO",,,STR0013) //"Criando Indํce Temporแrio"

For x := 1 TO Len(aDbfCria)
   RecLock("TCP",.T.)
      For nCtd := 1 TO Len(aStruDbf)
         FieldPut(nCtd, aDbfCria[x][nCtd])
      Next
   MsUnLock()
Next

Return(cArqCpos)
//----------------------------------------------------------
Function Cont_Tcampos(aDbfCria)
aAdd(aDbfCria, {'S','SD2','','D2_ALIQINS','N',  5,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_VALINS','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_VALCMP','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_FRETE','N', 12,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_DESPESA','N', 12,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_QTDDEV','N', 12,  2,''} )
aAdd(aDbfCria, {'N','SD2','','D2_DTDIGIT','D',  8,  0,''} )
aAdd(aDbfCria, {'S','SD2','','D2_EMISSAO','D',  8,  0,''} )
aAdd(aDbfCria, {'N','SD2','ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/SAL/EQU','D2_REMITO','C',  6,  0,''} )
aAdd(aDbfCria, {'N','SD2','ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/SAL/EQU','D2_SERIREM','C',  3,  0,''} )
aAdd(aDbfCria, {'N','SD2','ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/SAL/EQU','D2_ITEMREM','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SD2','','D2_BASIMP1','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_BASIMP2','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_BASIMP3','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_BASIMP4','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_BASIMP5','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_BASIMP6','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SD2','ARG','D2_BASIMP7','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SD2','ARG','D2_BASIMP8','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SD2','ARG','D2_BASIMP9','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_VALIMP1','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_VALIMP2','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_VALIMP3','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_VALIMP4','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_VALIMP5','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_VALIMP6','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SD2','ARG','D2_VALIMP7','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SD2','ARG','D2_VALIMP8','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SD2','ARG','D2_VALIMP9','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_ALQIMP1','N',  6,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_ALQIMP2','N',  6,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_ALQIMP3','N',  6,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_ALQIMP4','N',  6,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_ALQIMP5','N',  6,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_ALQIMP6','N',  6,  2,''} )
aAdd(aDbfCria, {'N','SD2','ARG','D2_ALQIMP7','N',  6,  2,''} )
aAdd(aDbfCria, {'N','SD2','ARG','D2_ALQIMP8','N',  6,  2,''} )
aAdd(aDbfCria, {'N','SD2','ARG','D2_ALQIMP9','N',  6,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_NFORI','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SD2','','D2_SERIORI','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SD2','','D2_ITEMORI','C',  2,  0,''} )
aAdd(aDbfCria, {'N','SD2','ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/SAL/EQU','D2_QTDCLAS','N', 12,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_CUSTO1','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_CUSTO2','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_CUSTO3','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_CUSTO4','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_CUSTO5','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SD2','','D2_NUMSEQ','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SD2','','D2_SEQCALC','C', 14,  0,''} )
aAdd(aDbfCria, {'S','SC5','','C5_NUM','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SC5','','C5_TIPO','C',  1,  0,'1=STR00930;2=STR00931;3=STR00932'} )
aAdd(aDbfCria, {'S','SC5','','C5_PESSOA','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SC5','','C5_TIPOCLI','C',  1,  0,'1=STR00984;2=STR00985;3=STR00986;4=STR00987;5=STR00988;6=STR00989#POR'} )
aAdd(aDbfCria, {'S','SC5','','C5_COND','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SC5','','C5_EMISSAO','D',  8,  0,''} )
aAdd(aDbfCria, {'N','SC5','','C5_NUMNF','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SC5','','C5_FRETE','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC5','','C5_DESPESA','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC5','','C5_VALDESC','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC5','','C5_BASEICM','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC5','','C5_VALICM','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC5','','C5_BASEIPI','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC5','','C5_VALIPI','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC5','','C5_VALMERC','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC5','','C5_VALBRUT','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC5','','C5_BRICMS','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC5','','C5_ICMSRET','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC5','','C5_IRRF','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC5','','C5_INSS','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC5','','C5_ISS','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC5','','C5_SERNF','C',  3,  0,''} )
aAdd(aDbfCria, {'N','SC5','','C5_REVENC','C',  1,  0,'1=STR01009;2=STR01010'} )
aAdd(aDbfCria, {'N','SC5','','C5_STATUS','C',  1,  0,'1=STR01015;2=STR01016;3=STR01017;4=STR01018#ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/'} )
aAdd(aDbfCria, {'N','SC5','','C5_BASEDUP','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC5','','C5_BASIMP1','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC5','','C5_BASIMP2','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC5','','C5_BASIMP3','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC5','','C5_BASIMP4','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC5','','C5_BASIMP5','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC5','','C5_BASIMP6','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC5','ARG','C5_BASIMP7','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC5','ARG','C5_BASIMP8','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC5','ARG','C5_BASIMP9','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC5','','C5_VALIMP1','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC5','','C5_VALIMP2','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC5','','C5_VALIMP3','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC5','','C5_VALIMP4','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC5','','C5_VALIMP5','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC5','','C5_VALIMP6','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC5','ARG','C5_VALIMP7','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC5','ARG','C5_VALIMP8','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC5','ARG','C5_VALIMP9','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC5','','C5_VEND1','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SC5','','C5_COMIS1','N',  5,  2,''} )
aAdd(aDbfCria, {'S','SC5','','C5_VEND2','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SC5','','C5_COMIS2','N',  5,  2,''} )
aAdd(aDbfCria, {'N','SC5','ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/SAL/EQU','C5_MOEDA','C',  1,  0,'1=&GetMv("MV_MOEDA1");2=&GetMv("MV_MOEDA2");3=&GetMv("MV_MOEDA3");4=&GetMv("MV_MOEDA4");5=&GetMv("MV'} )
aAdd(aDbfCria, {'N','SC5','ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/SAL/EQU','C5_TXMOEDA','N', 11,  4,''} )
aAdd(aDbfCria, {'S','SC5','','C5_MENNOTA','C', 60,  0,''} )
aAdd(aDbfCria, {'S','SC5','','C5_TABELA','C',  1,  0,'1=&GetMv("MV_PRCVEN1");2=&GetMv("MV_PRCVEN2");3=&GetMv("MV_PRCVEN3")'} )
aAdd(aDbfCria, {'S','SC6','','C6_NUM','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SC6','','C6_ITEM','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SC6','','C6_CODPROD','C', 15,  0,''} )
aAdd(aDbfCria, {'S','SC6','','C6_CODUM','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SC6','','C6_QUANT','N', 12,  2,''} )
aAdd(aDbfCria, {'S','SC6','','C6_PRCUNI','N', 12,  2,''} )
aAdd(aDbfCria, {'S','SC6','','C6_TOTAL','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_VALIPI','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_VALICM','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC6','','C6_TES','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SC6','','C6_CFOP','C',  5,  0,''} )
aAdd(aDbfCria, {'S','SC6','','C6_VALDESC','N', 12,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_IPI','N',  5,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_PICM','N',  5,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_BASEIPI','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_BASEICM','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC6','','C6_LOCAL','C',  2,  0,''} )
aAdd(aDbfCria, {'N','SC6','','C6_ICMSRET','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_BRICMS','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_BASEISS','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_ALIQISS','N',  5,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_VALISS','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_BASEINS','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_ALIQINS','N',  5,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_VALINS','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_VALCMP','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_FRETE','N', 12,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_DESPESA','N', 12,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_BASIMP1','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_BASIMP2','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_BASIMP3','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_BASIMP4','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_BASIMP5','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_BASIMP6','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC6','ARG','C6_BASIMP7','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC6','ARG','C6_BASIMP8','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC6','ARG','C6_BASIMP9','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_VALIMP1','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_VALIMP2','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_VALIMP3','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_VALIMP4','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_VALIMP5','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_VALIMP6','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC6','ARG','C6_VALIMP7','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC6','ARG','C6_VALIMP8','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC6','ARG','C6_VALIMP9','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_ALQIMP1','N',  6,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_ALQIMP2','N',  6,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_ALQIMP3','N',  6,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_ALQIMP4','N',  6,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_ALQIMP5','N',  6,  2,''} )
aAdd(aDbfCria, {'N','SC6','','C6_ALQIMP6','N',  6,  2,''} )
aAdd(aDbfCria, {'N','SC6','ARG','C6_ALQIMP7','N',  6,  2,''} )
aAdd(aDbfCria, {'N','SC6','ARG','C6_ALQIMP8','N',  6,  2,''} )
aAdd(aDbfCria, {'N','SC6','ARG','C6_ALQIMP9','N',  6,  2,''} )
aAdd(aDbfCria, {'S','SC6','','C6_NFORI','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SC6','','C6_SERIORI','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SC6','','C6_ITEMORI','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SC6','','C6_ENTREG','D',  8,  0,''} )
aAdd(aDbfCria, {'N','SEA','','EA_NUM','C',  6,  0,''} )
aAdd(aDbfCria, {'N','SEA','','EA_PARCELA','C',  2,  0,''} )
aAdd(aDbfCria, {'N','SEA','','EA_VENCTO','D',  8,  0,''} )
aAdd(aDbfCria, {'N','SEA','','EA_VENCREA','D',  8,  0,''} )
aAdd(aDbfCria, {'N','SEA','','EA_VALOR','N', 17,  2,''} )
aAdd(aDbfCria, {'N','SEA','','EA_MOEDA','C',  1,  0,'1=&GetMv("MV_MOEDA1");2=&GetMv("MV_MOEDA2");3=&GetMv("MV_MOEDA3");4=&GetMv("MV_MOEDA4");5=&GetMv("MV'} )
aAdd(aDbfCria, {'N','SEA','','EA_CODCAT','C', 10,  0,''} )
aAdd(aDbfCria, {'N','SFB','','FB_CODIGO','C',  3,  0,''} )
aAdd(aDbfCria, {'N','SFB','','FB_DESCR','C', 30,  0,''} )
aAdd(aDbfCria, {'N','SFB','','FB_CPOIMP','C',  1,  0,''} )
aAdd(aDbfCria, {'N','SFB','','FB_FORMENT','C', 20,  0,''} )
aAdd(aDbfCria, {'N','SFB','','FB_FORMSAI','C', 20,  0,''} )
aAdd(aDbfCria, {'N','SFB','','FB_ALIQ','N',  6,  3,''} )
aAdd(aDbfCria, {'N','SFB','','FB_PESSOA','C',  6,  0,''} )
aAdd(aDbfCria, {'N','SFB','COL/EUA','FB_TABELA','C',  1,  0,'1=STR01128;2=STR01129'} )
aAdd(aDbfCria, {'N','SEK','','EK_ORDPAGO','C',  6,  0,''} )
aAdd(aDbfCria, {'N','SEK','','EK_TIPODOC','C',  1,  0,'1=STR01138;2=STR01139#CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/SAL/EQU'} )
aAdd(aDbfCria, {'N','SEK','','EK_SERIE','C',  3,  0,''} )
aAdd(aDbfCria, {'N','SEK','','EK_NUM','C',  6,  0,''} )
aAdd(aDbfCria, {'N','SEK','','EK_PARCELA','C',  2,  0,''} )
aAdd(aDbfCria, {'N','SEK','','EK_TIPO','C',  1,  0,'1=STR01144;2=STR01145;3=STR01146;4=STR01147;5=STR01442;6=STR01443#ARG'} )
aAdd(aDbfCria, {'N','SEK','','EK_VALOR','N', 17,  2,''} )
aAdd(aDbfCria, {'N','SEK','','EK_MOEDA','C',  1,  0,''} )
aAdd(aDbfCria, {'N','SEK','','EK_PESSOA','C',  6,  0,''} )
aAdd(aDbfCria, {'N','SEK','','EK_BANCO','C',  3,  0,''} )
aAdd(aDbfCria, {'N','SEK','','EK_AGENCIA','C',  5,  0,''} )
aAdd(aDbfCria, {'N','SEK','','EK_CONTA','C', 10,  0,''} )
aAdd(aDbfCria, {'N','SEK','','EK_EMISSAO','D',  8,  0,''} )
aAdd(aDbfCria, {'N','SEK','','EK_VENCTO','D',  8,  0,''} )
aAdd(aDbfCria, {'N','SEK','','EK_DESCONT','N', 17,  2,''} )
aAdd(aDbfCria, {'N','SEK','','EK_JUROS','N', 17,  2,''} )
aAdd(aDbfCria, {'N','SEK','','EK_VLMOED1','N', 17,  2,''} )
aAdd(aDbfCria, {'N','SEL','','EL_RECIBO','C',  6,  0,''} )
aAdd(aDbfCria, {'N','SEL','','EL_PESSOA','C',  6,  0,''} )
aAdd(aDbfCria, {'N','SEL','','EL_TIPO','C',  1,  0,'1=STR00198;2=STR00199;3=STR00200;4=STR00201;5=STR00202;6=STR00203;7=STR00204;8=STR00205;9=STR01169;A'} )
aAdd(aDbfCria, {'N','SEL','','EL_TIPODOC','C',  1,  0,'1=STR01174;2=STR01175;3=STR01176;4=STR01177;5=STR00202;6=STR01576;7=STR01577;8=STR01578;9=STR01579#A'} )
aAdd(aDbfCria, {'N','SEL','','EL_SERIE','C',  3,  0,''} )
aAdd(aDbfCria, {'N','SEL','','EL_NUMERO','C',  6,  0,''} )
aAdd(aDbfCria, {'N','SEL','','EL_PARCELA','C',  2,  0,''} )
aAdd(aDbfCria, {'N','SEL','','EL_VALOR','N', 17,  2,''} )
aAdd(aDbfCria, {'N','SEL','','EL_MOEDA','C',  1,  0,''} )
aAdd(aDbfCria, {'N','SEL','','EL_EMISSAO','D',  8,  0,''} )
aAdd(aDbfCria, {'N','SEL','','EL_VENCTO','D',  8,  0,''} )
aAdd(aDbfCria, {'N','SEL','','EL_TPCRED','C',  1,  0,'1=STR01186;2=STR01187;3=STR01188#CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/SAL/EQU'} )
aAdd(aDbfCria, {'N','SEL','','EL_BANCO','C',  3,  0,''} )
aAdd(aDbfCria, {'N','SEL','','EL_AGENCIA','C',  5,  0,''} )
aAdd(aDbfCria, {'N','SEL','','EL_CONTA','C', 10,  0,''} )
aAdd(aDbfCria, {'N','SEL','','EL_BCOCHQ','C',  3,  0,''} )
aAdd(aDbfCria, {'N','SEL','','EL_AGECHQ','C',  5,  0,''} )
aAdd(aDbfCria, {'N','SEL','','EL_CTACHQ','C', 10,  0,''} )
aAdd(aDbfCria, {'N','SEL','','EL_DESCONT','N', 17,  2,''} )
aAdd(aDbfCria, {'N','SEL','','EL_VLMOED1','N', 17,  2,''} )
aAdd(aDbfCria, {'N','SFE','','FE_NROCERT','C',  6,  0,''} )
aAdd(aDbfCria, {'N','SFE','','FE_EMISSAO','D',  8,  0,''} )
aAdd(aDbfCria, {'N','SFE','','FE_PESSOA','C',  6,  0,''} )
aAdd(aDbfCria, {'N','SFE','','FE_TIPO','C',  1,  0,''} )
aAdd(aDbfCria, {'N','SFE','','FE_ORDPAGO','C',  6,  0,''} )
aAdd(aDbfCria, {'N','SFE','','FE_NFISCAL','C',  6,  0,''} )
aAdd(aDbfCria, {'N','SFE','','FE_SERIE','C',  3,  0,''} )
aAdd(aDbfCria, {'N','SFE','','FE_VALBASE','N', 16,  2,''} )
aAdd(aDbfCria, {'N','SFE','','FE_ALIQ','N',  6,  2,''} )
aAdd(aDbfCria, {'N','SFE','','FE_VALIMP','N', 16,  2,''} )
aAdd(aDbfCria, {'N','SFE','','FE_RETENC','N', 16,  2,''} )
aAdd(aDbfCria, {'N','SFE','','FE_DEDUC','N', 16,  2,''} )
aAdd(aDbfCria, {'N','SFE','','FE_PORCRET','N',  6,  2,''} )
aAdd(aDbfCria, {'N','SFE','','FE_CONCEPT','C',  2,  0,''} )
aAdd(aDbfCria, {'N','SFE','','FE_PARCELA','C',  1,  0,''} )
aAdd(aDbfCria, {'N','SFG','','FG_IMPOSTO','C',  3,  0,''} )
aAdd(aDbfCria, {'N','SFG','','FG_ITEM','C',  2,  0,''} )
aAdd(aDbfCria, {'N','SFG','','FG_ALIQ','N',  6,  2,''} )
aAdd(aDbfCria, {'N','SFG','ARG','FG_ALQINSC','N',  6,  2,''} )
aAdd(aDbfCria, {'N','SFG','ARG','FG_ALQNOIN','N',  6,  2,''} )
aAdd(aDbfCria, {'N','SFG','','FG_CFO','C',  5,  0,''} )
aAdd(aDbfCria, {'N','SFG','','FG_CFO_C','C',  5,  0,''} )
aAdd(aDbfCria, {'N','SFG','','FG_CFO_V','C',  5,  0,''} )
aAdd(aDbfCria, {'N','SFG','','FG_IMPORTE','N', 16,  2,''} )
aAdd(aDbfCria, {'N','SFG','ARG/EUA','FG_CONCEPT','C',150,  0,''} )
aAdd(aDbfCria, {'N','SFG','','FG_FXDE','N', 16,  2,''} )
aAdd(aDbfCria, {'N','SFG','','FG_FXATE','N', 16,  2,''} )
aAdd(aDbfCria, {'N','SFG','ARG','FG_RETENC','N', 16,  2,''} )
aAdd(aDbfCria, {'N','SFG','','FG_PERC','N',  6,  2,''} )
aAdd(aDbfCria, {'N','SFG','','FG_SERIENF','C',  3,  0,''} )
aAdd(aDbfCria, {'N','SFG','','FG_TIPO','C',  1,  0,'1=STR01251;2=STR01252'} )
aAdd(aDbfCria, {'N','SFG','','FG_ZONFIS','C',  2,  0,''} )
aAdd(aDbfCria, {'N','SFG','MEX/URU','FG_GRUPO','C',  4,  0,''} )
aAdd(aDbfCria, {'N','SFG','MEX','FG_ATIVIDA','C',  5,  0,''} )
aAdd(aDbfCria, {'N','SFG','EUA','FG_NUM','C',  6,  0,''} )
aAdd(aDbfCria, {'N','SFG','COL','FG_COD_TAB','C',  3,  0,''} )
aAdd(aDbfCria, {'N','SFG','MEX','FG_DTDE','D',  8,  0,''} )
aAdd(aDbfCria, {'N','SFG','MEX','FG_DTATE','D',  8,  0,''} )
aAdd(aDbfCria, {'N','SFH','','FH_AGENTE','C',  1,  0,'1=STR01264;2=STR01265'} )
aAdd(aDbfCria, {'N','SFH','','FH_ZONFIS','C',  2,  0,''} )
aAdd(aDbfCria, {'N','SFH','','FH_NOME','C', 20,  0,''} )
aAdd(aDbfCria, {'N','SFH','','FH_PESSOA','C',  6,  0,''} )
aAdd(aDbfCria, {'N','SFH','','FH_IMPOSTO','C',  3,  0,''} )
aAdd(aDbfCria, {'N','SFH','','FH_PERCIBI','C',  1,  0,'1=STR01271;2=STR01272'} )
aAdd(aDbfCria, {'N','SFH','','FH_ISENTO','C',  1,  0,'1=STR01274;2=STR01275'} )
aAdd(aDbfCria, {'N','SFH','','FH_PERCENT','N',  6,  2,''} )
aAdd(aDbfCria, {'N','SFH','','FH_APERIB','C',  1,  0,'1=STR01278;2=STR01279'} )
aAdd(aDbfCria, {'S','SF2','','F2_TIPO','C',  1,  0,'1=STR01294;2=STR01295;3=STR01296;4=STR01297;5=STR01298#ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/C'} )
aAdd(aDbfCria, {'S','SF2','','F2_DOC','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SF2','','F2_SERIE','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SF2','','F2_PESSOA','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SF2','','F2_EMISSAO','D',  8,  0,''} )
aAdd(aDbfCria, {'S','SF2','','F2_COND','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SF2','','F2_EST','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SF2','','F2_FRETE','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF2','','F2_DESPESA','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF2','','F2_VALDESC','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF2','','F2_BASEICM','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF2','','F2_VALICM','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF2','','F2_BASEIPI','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF2','','F2_VALIPI','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF2','','F2_VALMERC','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF2','','F2_VALBRUT','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF2','','F2_BRICMS','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF2','','F2_ICMSRET','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF2','','F2_IRRF','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF2','','F2_INSS','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF2','','F2_ISS','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SF2','ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/SAL/EQU','F2_ESPECIE','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SF2','','F2_BASIMP1','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF2','','F2_BASIMP2','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF2','','F2_BASIMP3','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF2','','F2_BASIMP4','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF2','','F2_BASIMP5','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF2','','F2_BASIMP6','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SF2','ARG','F2_BASIMP7','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SF2','ARG','F2_BASIMP8','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SF2','ARG','F2_BASIMP9','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF2','','F2_VALIMP1','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF2','','F2_VALIMP2','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF2','','F2_VALIMP3','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF2','','F2_VALIMP4','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF2','','F2_VALIMP5','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF2','','F2_VALIMP6','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SF2','ARG','F2_VALIMP7','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SF2','ARG','F2_VALIMP8','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SF2','ARG','F2_VALIMP9','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SF2','','F2_BASEDUP','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SF2','','F2_VEND1','C',  6,  0,''} )
aAdd(aDbfCria, {'N','SF2','','F2_COMIS1','N',  5,  2,''} )
aAdd(aDbfCria, {'S','SF2','','F2_VEND2','C',  6,  0,''} )
aAdd(aDbfCria, {'N','SF2','','F2_COMIS2','N',  5,  2,''} )
aAdd(aDbfCria, {'N','SF2','ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/SAL/EQU','F2_MOEDA','C',  1,  0,'1=&GetMv("MV_MOEDA1");2=&GetMv("MV_MOEDA2");3=&GetMv("MV_MOEDA3");4=&GetMv("MV_MOEDA4");5=&GetMv("MV'} )
aAdd(aDbfCria, {'N','SF2','ARG/CHI/PAR/MEX/URU/POR/DOM/EUA/COL/VEN/PER/COS/BOL/PAN/SAL/EQU','F2_TXMOEDA','N', 11,  4,''} )
aAdd(aDbfCria, {'N','SF2','','F2_MENNOTA','C', 60,  0,''} )
aAdd(aDbfCria, {'N','SF2','','F2_TABELA','C',  1,  0,'1=&GetMv("MV_PRCVEN1");2=&GetMv("MV_PRCVEN2");3=&GetMv("MV_PRCVEN3")'} )
aAdd(aDbfCria, {'S','SG1','','G1_CODPROD','C', 15,  0,''} )
aAdd(aDbfCria, {'S','SG1','','G1_COMP','C', 15,  0,''} )
aAdd(aDbfCria, {'S','SG1','','G1_DESCRI','C', 30,  0,''} )
aAdd(aDbfCria, {'S','SG1','','G1_TRT','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SG1','','G1_QUANT','N', 12,  6,''} )
aAdd(aDbfCria, {'S','SG1','','G1_PERDA','N',  5,  0,''} )
aAdd(aDbfCria, {'S','SG1','','G1_INI','D',  8,  0,''} )
aAdd(aDbfCria, {'S','SG1','','G1_FIM','D',  8,  0,''} )
aAdd(aDbfCria, {'S','SG1','','G1_OBSERV','C', 45,  0,''} )
aAdd(aDbfCria, {'S','SG1','','G1_FIXVAR','C',  1,  0,'1=STR01360;2=STR01361'} )
aAdd(aDbfCria, {'S','SG1','','G1_NIV','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SG1','','G1_NIVINV','C',  2,  0,''} )
aAdd(aDbfCria, {'N','SX6','','X6_FIL','C',  2,  0,''} )
aAdd(aDbfCria, {'N','SX6','','X6_TIPO','C',  1,  0,'C=STR01368;N=STR01369;L=STR01370;D=STR01371'} )
aAdd(aDbfCria, {'N','SX6','','X6_DESCRIC','C',150,  0,''} )
aAdd(aDbfCria, {'N','SX6','','X6_DSCSPA','C',150,  0,''} )
aAdd(aDbfCria, {'N','SX6','','X6_DSCENG','C',150,  0,''} )
aAdd(aDbfCria, {'N','SX6','','X6_VAR','C', 10,  0,''} )
aAdd(aDbfCria, {'N','SX6','','X6_CONTEUD','C',250,  0,''} )
aAdd(aDbfCria, {'N','SX6','','X6_CONTSPA','C',250,  0,''} )
aAdd(aDbfCria, {'N','SX6','','X6_CONTENG','C',250,  0,''} )
aAdd(aDbfCria, {'N','SX6','','X6_PROPRI','C',  1,  0,''} )
aAdd(aDbfCria, {'N','SF7','','F7_GRTRIB','C',  3,  0,''} )
aAdd(aDbfCria, {'N','SF7','','F7_SEQUEN','C',  2,  0,''} )
aAdd(aDbfCria, {'N','SF7','','F7_EST','C',  2,  0,''} )
aAdd(aDbfCria, {'N','SF7','','F7_TIPOCLI','C',  2,  0,'1=STR01385;2=STR01386;3=STR01387'} )
aAdd(aDbfCria, {'N','SF7','','F7_ALIQINT','N',  5,  2,''} )
aAdd(aDbfCria, {'N','SF7','','F7_ALIQEXT','N',  5,  2,''} )
aAdd(aDbfCria, {'N','SF7','','F7_MARGEM','N',  5,  2,''} )
aAdd(aDbfCria, {'N','SF7','','F7_IMPOSTO','C',  3,  0,''} )
aAdd(aDbfCria, {'N','SA8','','A8_SIGLA','C',  2,  0,''} )
aAdd(aDbfCria, {'N','SA8','','A8_DESCRI','C', 55,  0,''} )
aAdd(aDbfCria, {'S','SC2','','C2_NUM','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SC2','','C2_ITEM','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SC2','','C2_SEQUEN','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SC2','','C2_CODPROD','C', 15,  0,''} )
aAdd(aDbfCria, {'S','SC2','','C2_LOCAL','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SC2','','C2_QUANT','N', 12,  2,''} )
aAdd(aDbfCria, {'S','SC2','','C2_CODUM','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SC2','','C2_DATPRI','D',  8,  0,''} )
aAdd(aDbfCria, {'S','SC2','','C2_DATPRF','D',  8,  0,''} )
aAdd(aDbfCria, {'S','SC2','','C2_OBS','C', 30,  0,''} )
aAdd(aDbfCria, {'S','SC2','','C2_EMISSAO','D',  8,  0,''} )
aAdd(aDbfCria, {'S','SC2','','C2_QUJE','N', 12,  2,''} )
aAdd(aDbfCria, {'S','SC2','','C2_DATRF','D',  8,  0,''} )
aAdd(aDbfCria, {'S','SC2','','C2_NIVEL','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SC2','','C2_DATAJI','D',  8,  0,''} )
aAdd(aDbfCria, {'S','SC2','','C2_DATAJF','D',  8,  0,''} )
aAdd(aDbfCria, {'S','SC2','','C2_AGLUT','C',  1,  0,''} )
aAdd(aDbfCria, {'S','SC2','','C2_PERDA','N', 12,  2,''} )
aAdd(aDbfCria, {'S','SC2','','C2_OK','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SC2','','C2_SEQPAI','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SC2','','C2_PEDIDO','C',  6,  0,''} )
aAdd(aDbfCria, {'S','SC2','','C2_ITEMPV','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SC2','','C2_VINI1','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC2','','C2_VINI2','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC2','','C2_VINI3','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC2','','C2_VINI4','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC2','','C2_VINI5','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC2','','C2_VATU1','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC2','','C2_VATU2','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC2','','C2_VATU3','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC2','','C2_VATU4','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC2','','C2_VATU5','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC2','','C2_VFIM1','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC2','','C2_VFIM2','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC2','','C2_VFIM3','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC2','','C2_VFIM4','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC2','','C2_VFIM5','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC2','','C2_APRINI1','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC2','','C2_APRINI2','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC2','','C2_APRINI3','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC2','','C2_APRINI4','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC2','','C2_APRINI5','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC2','','C2_APRATU1','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC2','','C2_APRATU2','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC2','','C2_APRATU3','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC2','','C2_APRATU4','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC2','','C2_APRATU5','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC2','','C2_APRFIM1','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC2','','C2_APRFIM2','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC2','','C2_APRFIM3','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC2','','C2_APRFIM4','N', 14,  2,''} )
aAdd(aDbfCria, {'S','SC2','','C2_APRFIM5','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SX1','','X1_GRUPO','C',  6,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_ORDEM','C',  2,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_PERGUNT','C', 20,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_PERSPA','C', 20,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_PERENG','C', 20,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_VARIAVL','C',  6,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_TIPO','C',  1,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_TAMANHO','N',  2,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_DECIMAL','N',  1,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_PRESEL','N',  1,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_GSC','C',  1,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_VALID','C', 60,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_VAR01','C', 15,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_DEF01','C', 15,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_DEFSPA1','C', 15,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_DEFENG1','C', 15,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_CNT01','C', 40,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_VAR02','C', 15,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_DEF02','C', 15,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_DEFSPA2','C', 15,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_DEFENG2','C', 15,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_CNT02','C', 40,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_VAR03','C', 15,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_DEF03','C', 15,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_DEFSPA3','C', 15,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_DEFENG3','C', 15,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_CNT03','C', 40,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_VAR04','C', 15,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_DEF04','C', 15,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_DEFSPA4','C', 15,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_DEFENG4','C', 15,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_CNT04','C', 40,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_VAR05','C', 15,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_DEF05','C', 15,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_DEFSPA5','C', 15,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_DEFENG5','C', 10,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_CNT05','C', 40,  0,''} )
aAdd(aDbfCria, {'N','SX1','','X1_F3','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SD4','','D4_CODPROD','C', 15,  0,''} )
aAdd(aDbfCria, {'S','SD4','','D4_LOCAL','C',  2,  0,''} )
aAdd(aDbfCria, {'S','SD4','','D4_OP','C', 11,  0,''} )
aAdd(aDbfCria, {'S','SD4','','D4_DATA','D',  8,  0,''} )
aAdd(aDbfCria, {'S','SD4','','D4_QTDEORI','N', 11,  2,''} )
aAdd(aDbfCria, {'S','SD4','','D4_QUANT','N', 11,  2,''} )
aAdd(aDbfCria, {'S','SD4','','D4_TRT','C',  3,  0,''} )
aAdd(aDbfCria, {'S','SD4','','D4_OPORIG','C', 11,  0,''} )
aAdd(aDbfCria, {'N','SFI','','FI_GRTRIB','C',  3,  0,''} )
aAdd(aDbfCria, {'N','SFI','','FI_DESCRI','C', 40,  0,''} )
aAdd(aDbfCria, {'N','SAA','','AA_CODOCO','C',  3,  0,''} )
aAdd(aDbfCria, {'N','SAA','','AA_DESCOCO','C', 30,  0,''} )
aAdd(aDbfCria, {'N','SAB','','AB_ID','C',  6,  0,''} )
aAdd(aDbfCria, {'N','SAB','','AB_DATAOCO','D',  8,  0,''} )
aAdd(aDbfCria, {'N','SAB','','AB_TIPOCO','C',  3,  0,''} )
aAdd(aDbfCria, {'N','SAB','','AB_DESCOCO','C', 30,  0,''} )
aAdd(aDbfCria, {'N','SAB','','AB_OBSOCO','M', 80,  0,''} )
aAdd(aDbfCria, {'N','SAB','','AB_PATH','C', 60,  0,''} )
aAdd(aDbfCria, {'N','SEB','','EB_CODIGO','C', 10,  0,''} )
aAdd(aDbfCria, {'N','SEB','','EB_DESCRI','C', 30,  0,''} )
aAdd(aDbfCria, {'N','SEC','','EC_CODIGO','C', 10,  0,''} )
aAdd(aDbfCria, {'N','SEC','','EC_ITEM','C',  2,  0,''} )
aAdd(aDbfCria, {'N','SEC','','EC_DESCRI','C', 30,  0,''} )
aAdd(aDbfCria, {'N','SEC','','EC_INICIO','D',  8,  0,''} )
aAdd(aDbfCria, {'N','SEC','','EC_FINAL','D',  8,  0,''} )
aAdd(aDbfCria, {'N','SEE','','EE_CODIGO','C', 10,  0,''} )
aAdd(aDbfCria, {'N','SEE','','EE_CODCAT','C', 10,  0,''} )
aAdd(aDbfCria, {'N','SEE','','EE_MOEDA','C',  1,  0,'1=&GetMv("MV_MOEDA1");2=&GetMv("MV_MOEDA2");3=&GetMv("MV_MOEDA3");4=&GetMv("MV_MOEDA4");5=&GetMv("MV'} )
aAdd(aDbfCria, {'N','SEF','','EF_CODIGO','C', 10,  0,''} )
aAdd(aDbfCria, {'N','SEF','','EF_ITEM','C',  2,  0,''} )
aAdd(aDbfCria, {'N','SEF','','EF_CODCAT','C', 10,  0,''} )
aAdd(aDbfCria, {'N','SEF','','EF_MOEDA','C',  1,  0,'1=&GetMv("MV_MOEDA1");2=&GetMv("MV_MOEDA2");3=&GetMv("MV_MOEDA3");4=&GetMv("MV_MOEDA4");5=&GetMv("MV'} )
aAdd(aDbfCria, {'N','SEF','','EF_VALOR','N', 14,  2,''} )
aAdd(aDbfCria, {'N','SBX','','BX_CODPROD','C', 15,  0,''} )
aAdd(aDbfCria, {'N','SBX','','BX_DESCRI','C', 30,  0,''} )
aAdd(aDbfCria, {'N','SBX','','BX_PRV1','N', 12,  2,''} )
aAdd(aDbfCria, {'N','SBX','','BX_PRV2','N', 12,  2,''} )
aAdd(aDbfCria, {'N','SBX','','BX_PRV3','N', 12,  2,''} )
aAdd(aDbfCria, {'N','SBX','','BX_CUSREP','N', 12,  2,''} )
aAdd(aDbfCria, {'N','SBX','','BX_BASEPRC','C',  1,  0,'1=STR01488;2=STR01489'} )
aAdd(aDbfCria, {'N','SBX','','BX_ATUSB1','C',  1,  0,''} )
aAdd(aDbfCria, {'N','SBZ','','BZ_CODPROD','C', 15,  0,''} )
aAdd(aDbfCria, {'N','SBZ','','BZ_TPFORM','C',  1,  0,''} )
aAdd(aDbfCria, {'N','SBZ','','BZ_DESCRI','C', 15,  0,''} )
aAdd(aDbfCria, {'N','SBZ','','BZ_VALOR','N', 12,  2,''} )
aAdd(aDbfCria, {'N','SBZ','','BZ_INDIC','C',  1,  0,'%=STR01494;$=STR00213'} )
aAdd(aDbfCria, {'N','SBZ','','BZ_OPER','C',  1,  0,'*=STR01495;/=STR01496;+=STR00762;-=STR00763'} )
aAdd(aDbfCria, {'N','SBZ','','BZ_TABELA','C',  1,  0,'1=&GetMv("MV_PRCVEN1");2=&GetMv("MV_PRCVEN2");3=&GetMv("MV_PRCVEN3")'} )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTCpos()   บAutor  ณPaulo Carnelossi    บ Data ณ  15/05/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria arquivo dos campos  a ser importada a partir do array  บฑฑ
ฑฑบ          ณcom a correlacao entre campo small e Master                 บฑฑ
ฑฑบ          ณfonte gerado a partir do DBF pela funcao Cr_Tab_Dados()     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Migra()                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tcpos()
Local aDbfCria,aStruDbf
Local cArqCpos, x, nCtd

aDbfCria := {}

aAdd(aDbfCria, {'SA1','SA1','A1_PESSOA','A1_COD'} )
aAdd(aDbfCria, {'SA1','SA1','A1_NOME','A1_NOME'} )
aAdd(aDbfCria, {'SA1','SA1','A1_IDENT',''} )
aAdd(aDbfCria, {'SA1','SA1','A1_CGC','A1_CGC'} )
aAdd(aDbfCria, {'SA1','SA1','A1_TIPO','A1_TIPO'} )
aAdd(aDbfCria, {'SA1','SA1','A1_INSCR','A1_INSCR'} )
aAdd(aDbfCria, {'SA1','SA1','A1_END','A1_END'} )
aAdd(aDbfCria, {'SA1','SA1','A1_CEP','A1_CEP'} )
aAdd(aDbfCria, {'SA1','SA1','A1_BAIRRO','A1_BAIRRO'} )
aAdd(aDbfCria, {'SA1','SA1','A1_MUN','A1_MUN'} )
aAdd(aDbfCria, {'SA1','SA1','A1_EST','A1_EST'} )
aAdd(aDbfCria, {'SA1','SA1','A1_COMISS','A1_COMIS'} )
aAdd(aDbfCria, {'SA1','SA1','A1_COMEMIS',''} )
aAdd(aDbfCria, {'SA1','SA1','A1_COMBX',''} )
aAdd(aDbfCria, {'SA1','SA1','A1_FONE','A1_TEL'} )
aAdd(aDbfCria, {'SA1','SA1','A1_EMAIL','A1_EMAIL'} )
aAdd(aDbfCria, {'SA1','SA1','A1_HPAGE',''} )
aAdd(aDbfCria, {'SA1','SA1','A1_FTP',''} )
aAdd(aDbfCria, {'SA1','SA1','A1_TABELA',''} )
aAdd(aDbfCria, {'SA6','SA6','A6_BANCO','A6_COD'} )
aAdd(aDbfCria, {'SA6','SA6','A6_AGENCIA','A6_AGENCIA'} )
aAdd(aDbfCria, {'SA6','SA6','A6_CONTA','A6_NUMCON'} )
aAdd(aDbfCria, {'SA6','SA6','A6_NOME','A6_NOME'} )
aAdd(aDbfCria, {'SA6','SA6','A6_END','A6_END'} )
aAdd(aDbfCria, {'SA6','SA6','A6_BAIRRO','A6_BAIRRO'} )
aAdd(aDbfCria, {'SA6','SA6','A6_MUN','A6_MUN'} )
aAdd(aDbfCria, {'SA6','SA6','A6_CEP','A6_CEP'} )
aAdd(aDbfCria, {'SA6','SA6','A6_EST','A6_EST'} )
aAdd(aDbfCria, {'SA6','SA6','A6_TEL','A6_TEL'} )
aAdd(aDbfCria, {'SA6','SA6','A6_CONTATO','A6_CONTATO'} )
aAdd(aDbfCria, {'SA6','SA6','A6_FLUXO','A6_FLUXCAI'} )
aAdd(aDbfCria, {'SA6','SA6','A6_MOEDA',''} )
aAdd(aDbfCria, {'SED','SED','ED_CODCAT','ED_CODIGO'} )
aAdd(aDbfCria, {'SED','SED','ED_DESCRI','ED_DESCRIC'} )
aAdd(aDbfCria, {'SED','SED','ED_TPCART',''} )
aAdd(aDbfCria, {'SE1','SE1','E1_NUM','E1_NUM'} )
aAdd(aDbfCria, {'SE1','SE1','E1_PARCELA','E1_PARCELA'} )
aAdd(aDbfCria, {'SE1','SE1','E1_TIPO','E1_TIPO'} )
aAdd(aDbfCria, {'SE1','SE1','E1_PESSOA','E1_CLIENTE'} )
aAdd(aDbfCria, {'SE1','SE1','E1_NOME','E1_NOMCLI'} )
aAdd(aDbfCria, {'SE1','SE1','E1_SERIE','E1_PREFIXO'} )
aAdd(aDbfCria, {'SE1','SE1','E1_EMISSAO','E1_EMISSAO'} )
aAdd(aDbfCria, {'SE1','SE1','E1_CODCAT','E1_NATUREZ'} )
aAdd(aDbfCria, {'SE1','SE1','E1_VENCTO','E1_VENCTO'} )
aAdd(aDbfCria, {'SE1','SE1','E1_VENCREA','E1_VENCREA'} )
aAdd(aDbfCria, {'SE1','SE1','E1_VALOR','E1_VALOR'} )
aAdd(aDbfCria, {'SE1','SE1','E1_BANCO','E1_PORTADO'} )
aAdd(aDbfCria, {'SE1','SE1','E1_AGENCIA',''} )
aAdd(aDbfCria, {'SE1','SE1','E1_CONTA',''} )
aAdd(aDbfCria, {'SE1','SE1','E1_DESCRI',''} )
aAdd(aDbfCria, {'SE1','SE1','E1_SALDO','E1_SALDO'} )
aAdd(aDbfCria, {'SE1','SE1','E1_MOEDA','E1_MOEDA'} )
aAdd(aDbfCria, {'SE1','SE1','E1_RECIBO','E1_RECIBO'} )
aAdd(aDbfCria, {'SE2','SE2','E2_NUM','E2_NUM'} )
aAdd(aDbfCria, {'SE2','SE2','E2_PARCELA','E2_PARCELA'} )
aAdd(aDbfCria, {'SE2','SE2','E2_TIPO','E2_TIPO'} )
aAdd(aDbfCria, {'SE2','SE2','E2_PESSOA','E2_FORNECE'} )
aAdd(aDbfCria, {'SE2','SE2','E2_NOME','E2_NOMFOR'} )
aAdd(aDbfCria, {'SE2','SE2','E2_SERIE','E2_PREFIXO'} )
aAdd(aDbfCria, {'SE2','SE2','E2_EMISSAO','E2_EMISSAO'} )
aAdd(aDbfCria, {'SE2','SE2','E2_CODCAT','E2_NATUREZ'} )
aAdd(aDbfCria, {'SE2','SE2','E2_VENCTO','E2_VENCTO'} )
aAdd(aDbfCria, {'SE2','SE2','E2_VENCREA','E2_VENCREA'} )
aAdd(aDbfCria, {'SE2','SE2','E2_VALOR','E2_VALOR'} )
aAdd(aDbfCria, {'SE2','SE2','E2_BANCO','E2_PORTADO'} )
aAdd(aDbfCria, {'SE2','SE2','E2_AGENCIA',''} )
aAdd(aDbfCria, {'SE2','SE2','E2_CONTA',''} )
aAdd(aDbfCria, {'SE2','SE2','E2_DESCRI',''} )
aAdd(aDbfCria, {'SE2','SE2','E2_SALDO','E2_SALDO'} )
aAdd(aDbfCria, {'SE2','SE2','E2_MOEDA','E2_MOEDA'} )
aAdd(aDbfCria, {'SE2','SE2','E2_EMISS1','E2_EMIS1'} )
aAdd(aDbfCria, {'SE2','SE2','E2_DTDIGIT',''} )
aAdd(aDbfCria, {'SEP','SEP','EP_BANCO','EP_BANCO'} )
aAdd(aDbfCria, {'SEP','SEP','EP_AGENCIA','EP_AGENCIA'} )
aAdd(aDbfCria, {'SEP','SEP','EP_CONTA','EP_CONTA'} )
aAdd(aDbfCria, {'SEP','SEP','EP_TPCART','EP_TPCART'} )
aAdd(aDbfCria, {'SEP','SEP','EP_DESCRI','EP_DESCRI'} )
aAdd(aDbfCria, {'SEP','SEP','EP_PROXDAT','EP_PROXDAT'} )
aAdd(aDbfCria, {'SEP','SEP','EP_CODCAT','EP_CODCAT'} )
aAdd(aDbfCria, {'SEP','SEP','EP_VALOR','EP_VALOR'} )
aAdd(aDbfCria, {'SEP','SEP','EP_FREQUEN','EP_FREQUEN'} )
aAdd(aDbfCria, {'SEP','SEP','EP_NUMPAG','EP_NUMPAG'} )
aAdd(aDbfCria, {'SEP','SEP','EP_INCLUI','EP_INCLUI'} )
aAdd(aDbfCria, {'SEP','SEP','EP_DIASANT','EP_DIASANT'} )
aAdd(aDbfCria, {'SEP','SEP','EP_MOEDA','EP_MOEDA'} )
aAdd(aDbfCria, {'SEP','SEP','EP_PESSOA','EP_PESSOA'} )
aAdd(aDbfCria, {'SEP','SEP','EP_TIPO','EP_TIPO'} )
aAdd(aDbfCria, {'SEP','SEP','EP_PROXFLX','EP_PROXFLX'} )
aAdd(aDbfCria, {'SEP','SEP','EP_NPAGFLX','EP_NPAGFLX'} )
aAdd(aDbfCria, {'SM2','SM2','M2_DATA','M2_DATA'} )
aAdd(aDbfCria, {'SM2','SM2','M2_MOEDA2','M2_MOEDA2'} )
aAdd(aDbfCria, {'SM2','SM2','M2_MOEDA3','M2_MOEDA3'} )
aAdd(aDbfCria, {'SM2','SM2','M2_MOEDA4','M2_MOEDA4'} )
aAdd(aDbfCria, {'SM2','SM2','M2_MOEDA5','M2_MOEDA5'} )
aAdd(aDbfCria, {'SE5','SE5','E5_SERIE','E5_PREFIXO'} )
aAdd(aDbfCria, {'SE5','SE5','E5_NUM','E5_NUMERO'} )
aAdd(aDbfCria, {'SE5','SE5','E5_PARCELA','E5_PARCELA'} )
aAdd(aDbfCria, {'SE5','SE5','E5_TIPO','E5_TIPO'} )
aAdd(aDbfCria, {'SE5','SE5','E5_PESSOA','E5_CLIFOR'} )
aAdd(aDbfCria, {'SE5','SE5','E5_DATA','E5_DATA'} )
aAdd(aDbfCria, {'SE5','SE5','E5_CODCAT','E5_NATUREZ'} )
aAdd(aDbfCria, {'SE5','SE5','E5_HISTORI','E5_HISTOR'} )
aAdd(aDbfCria, {'SE5','SE5','E5_VALPAG','E5_VALOR'} )
aAdd(aDbfCria, {'SE5','SE5','E5_BANCO','E5_BANCO'} )
aAdd(aDbfCria, {'SE5','SE5','E5_AGENCIA','E5_AGENCIA'} )
aAdd(aDbfCria, {'SE5','SE5','E5_CONTA','E5_CONTA'} )
aAdd(aDbfCria, {'SE5','SE5','E5_NUMCHEQ','E5_NUMCHEQ'} )
aAdd(aDbfCria, {'SE5','SE5','E5_RECPAG','E5_RECPAG'} )
aAdd(aDbfCria, {'SE5','SE5','E5_JUROS','E5_VLJUROS'} )
aAdd(aDbfCria, {'SE5','SE5','E5_MULTA','E5_VLMULTA'} )
aAdd(aDbfCria, {'SE5','SE5','E5_DESC','E5_VLDESCO'} )
aAdd(aDbfCria, {'SE5','SE5','E5_TPMOV','E5_MOEDA'} )
aAdd(aDbfCria, {'SE5','SE5','E5_SITUACA','E5_SITUACA'} )
aAdd(aDbfCria, {'SE5','SE5','E5_ORDREC','E5_ORDREC'} )
aAdd(aDbfCria, {'SE5','SE5','E5_DTDIGIT','E5_DTDIGIT'} )
aAdd(aDbfCria, {'SE5','SE5','E5_MOVBCO',''} )
aAdd(aDbfCria, {'SE9','SE9','E9_CODCAT','E9_CODCAT'} )
aAdd(aDbfCria, {'SE9','SE9','E9_DTINIC','E9_DTINIC'} )
aAdd(aDbfCria, {'SE9','SE9','E9_DTFINAL','E9_DTFINAL'} )
aAdd(aDbfCria, {'SE9','SE9','E9_VALOR','E9_VALOR'} )
aAdd(aDbfCria, {'SE9','SE9','E9_MOEDA','E9_MOEDA'} )
aAdd(aDbfCria, {'SA7','SA7','A7_DIA','A7_DIA'} )
aAdd(aDbfCria, {'SA7','SA7','A7_MES','A7_MES'} )
aAdd(aDbfCria, {'SA7','SA7','A7_ANO','A7_ANO'} )
aAdd(aDbfCria, {'SA7','SA7','A7_DESCRI','A7_DESCRI'} )
aAdd(aDbfCria, {'SE8','SE8','E8_BANCO','E8_BANCO'} )
aAdd(aDbfCria, {'SE8','SE8','E8_AGENCIA','E8_AGENCIA'} )
aAdd(aDbfCria, {'SE8','SE8','E8_CONTA','E8_CONTA'} )
aAdd(aDbfCria, {'SE8','SE8','E8_DATA','E8_DTSALAT'} )
aAdd(aDbfCria, {'SE8','SE8','E8_VALOR','E8_SALATUA'} )
aAdd(aDbfCria, {'SB1','SB1','B1_CODPROD','B1_COD'} )
aAdd(aDbfCria, {'SB1','SB1','B1_DESCRI','B1_DESC'} )
aAdd(aDbfCria, {'SB1','SB1','B1_TIPO','B1_TIPO'} )
aAdd(aDbfCria, {'SB1','SB1','B1_CODUM','B1_UM'} )
aAdd(aDbfCria, {'SB1','SB1','B1_LOCAL','B1_LOCPAD'} )
aAdd(aDbfCria, {'SB1','SB1','B1_CODGRP','B1_GRUPO'} )
aAdd(aDbfCria, {'SB1','SB1','B1_PRV1','B1_PRV1'} )
aAdd(aDbfCria, {'SB1','SB1','B1_UPRC','B1_UPRC'} )
aAdd(aDbfCria, {'SB1','SB1','B1_UCOM','B1_UCOM'} )
aAdd(aDbfCria, {'SB1','SB1','B1_EMIN','B1_EMIN'} )
aAdd(aDbfCria, {'SB1','SB1','B1_ESTSEG','B1_ESTSEG'} )
aAdd(aDbfCria, {'SB1','SB1','B1_PE','B1_PE'} )
aAdd(aDbfCria, {'SB1','SB1','B1_TIPE','B1_TIPE'} )
aAdd(aDbfCria, {'SB1','SB1','B1_LE','B1_LE'} )
aAdd(aDbfCria, {'SB1','SB1','B1_LM','B1_LM'} )
aAdd(aDbfCria, {'SB1','SB1','B1_TIPODEC','B1_TIPODEC'} )
aAdd(aDbfCria, {'SB1','SB1','B1_PICM','B1_PICM'} )
aAdd(aDbfCria, {'SB1','SB1','B1_IPI','B1_IPI'} )
aAdd(aDbfCria, {'SB1','SB1','B1_ALIQISS','B1_ALIQISS'} )
aAdd(aDbfCria, {'SB1','SB1','B1_PICMENT','B1_PICMENT'} )
aAdd(aDbfCria, {'SB1','SB1','B1_PICMRET','B1_PICMRET'} )
aAdd(aDbfCria, {'SB1','SB1','B1_QB','B1_QB'} )
aAdd(aDbfCria, {'SB1','SB1','B1_NCM','B1_POSIPI'} )
aAdd(aDbfCria, {'SB1','SB1','B1_PRV2',''} )
aAdd(aDbfCria, {'SB1','SB1','B1_PRV3',''} )
aAdd(aDbfCria, {'SB1','SB1','B1_CUSTD','B1_CUSTD'} )
aAdd(aDbfCria, {'SB1','SB1','B1_DATREF','B1_DATREF'} )
aAdd(aDbfCria, {'SB1','SB1','B1_MCUSTD','B1_MCUSTD'} )
aAdd(aDbfCria, {'SB1','SB1','B1_UCALSTD','B1_UCALSTD'} )
aAdd(aDbfCria, {'SB1','SB1','B1_TE','B1_TE'} )
aAdd(aDbfCria, {'SB1','SB1','B1_TS','B1_TS'} )
aAdd(aDbfCria, {'SB1','SB1','B1_FORAEST','B1_FORAEST'} )
aAdd(aDbfCria, {'SAH','SAH','AH_CODUM','AH_UNIMED'} )
aAdd(aDbfCria, {'SAH','SAH','AH_DESCRI','AH_DESCPO'} )
aAdd(aDbfCria, {'SBM','SBM','BM_CODGRP','BM_GRUPO'} )
aAdd(aDbfCria, {'SBM','SBM','BM_DESCRI','BM_DESC'} )
aAdd(aDbfCria, {'SE6','SE4','E6_CODCND','E4_CODIGO'} )
aAdd(aDbfCria, {'SE6','SE4','E6_TIPO','E4_TIPO'} )
aAdd(aDbfCria, {'SE6','SE4','E6_DESCTP',''} )
aAdd(aDbfCria, {'SE6','SE4','E6_COND','E4_COND'} )
aAdd(aDbfCria, {'SE6','SE4','E6_DESCRI','E4_DESCRI'} )
aAdd(aDbfCria, {'SE6','SE4','E6_DDD','E4_DDD'} )
aAdd(aDbfCria, {'SC0','SC1','C0_NUMSOL','C1_NUM'} )
aAdd(aDbfCria, {'SC0','SC1','C0_SOLICIT','C1_SOLICIT'} )
aAdd(aDbfCria, {'SC0','SC1','C0_EMISSAO','C1_EMISSAO'} )
aAdd(aDbfCria, {'SC0','SC1','C0_STATUS',''} )
aAdd(aDbfCria, {'SC1','SC1','C1_NUMSOL','C1_NUM'} )
aAdd(aDbfCria, {'SC1','SC1','C1_ITEM','C1_ITEM'} )
aAdd(aDbfCria, {'SC1','SC1','C1_CODPROD','C1_PRODUTO'} )
aAdd(aDbfCria, {'SC1','SC1','C1_DESCRI','C1_DESCRI'} )
aAdd(aDbfCria, {'SC1','SC1','C1_CODUM','C1_UM'} )
aAdd(aDbfCria, {'SC1','SC1','C1_QUANT','C1_QUANT'} )
aAdd(aDbfCria, {'SC1','SC1','C1_DATPRF','C1_DATPRF'} )
aAdd(aDbfCria, {'SC1','SC1','C1_LOCAL','C1_LOCAL'} )
aAdd(aDbfCria, {'SC1','SC1','C1_OBS','C1_OBS'} )
aAdd(aDbfCria, {'SC1','SC1','C1_OP','C1_OP'} )
aAdd(aDbfCria, {'SC1','SC1','C1_QUJE','C1_QUJE'} )
aAdd(aDbfCria, {'SC7','SC7','C7_NUMPED','C7_NUM'} )
aAdd(aDbfCria, {'SC7','SC7','C7_EMISSAO','C7_EMISSAO'} )
aAdd(aDbfCria, {'SC7','SC7','C7_CONTATO','C7_CONTATO'} )
aAdd(aDbfCria, {'SC7','SC7','C7_PESSOA','C7_FORNECE'} )
aAdd(aDbfCria, {'SC7','SC7','C7_COND','C7_COND'} )
aAdd(aDbfCria, {'SC7','SC7','C7_STATUS',''} )
aAdd(aDbfCria, {'SC8','SC8','C8_NUMPED','C7_NUM'} )
aAdd(aDbfCria, {'SC8','SC8','C8_ITEM','C7_ITEM'} )
aAdd(aDbfCria, {'SC8','SC8','C8_CODPROD','C7_PRODUTO'} )
aAdd(aDbfCria, {'SC8','SC8','C8_CODUM','C7_UM'} )
aAdd(aDbfCria, {'SC8','SC8','C8_QUANT','C7_QUANT'} )
aAdd(aDbfCria, {'SC8','SC8','C8_PRCUNI','C7_PRECO'} )
aAdd(aDbfCria, {'SC8','SC8','C8_TOTAL','C7_TOTAL'} )
aAdd(aDbfCria, {'SC8','SC8','C8_DATPRF','C7_DATPRF'} )
aAdd(aDbfCria, {'SC8','SC8','C8_LOCAL','C7_LOCAL'} )
aAdd(aDbfCria, {'SC8','SC8','C8_OBS','C7_OBS'} )
aAdd(aDbfCria, {'SC8','SC8','C8_DESCRI','C7_DESCRI'} )
aAdd(aDbfCria, {'SC8','SC8','C8_QUJE','C7_QUJE'} )
aAdd(aDbfCria, {'SC8','SC8','C8_NUMSC','C7_NUMSC'} )
aAdd(aDbfCria, {'SC8','SC8','C8_ITEMSC','C7_ITEMSC'} )
aAdd(aDbfCria, {'SC8','SC8','C8_QTDSC','C7_QTDSOL'} )
aAdd(aDbfCria, {'SC8','SC8','C8_OP','C7_OP'} )
aAdd(aDbfCria, {'SB2','SB2','B2_CODPROD','B2_COD'} )
aAdd(aDbfCria, {'SB2','SB2','B2_DESCRI',''} )
aAdd(aDbfCria, {'SB2','SB2','B2_LOCAL','B2_LOCAL'} )
aAdd(aDbfCria, {'SB2','SB2','B2_QATU','B2_QATU'} )
aAdd(aDbfCria, {'SB2','SB2','B2_QFIM','B2_QFIM'} )
aAdd(aDbfCria, {'SB2','SB2','B2_SALSC',''} )
aAdd(aDbfCria, {'SB2','SB2','B2_SALPC',''} )
aAdd(aDbfCria, {'SB2','SB2','B2_SALOPE',''} )
aAdd(aDbfCria, {'SB2','SB2','B2_SALOPS',''} )
aAdd(aDbfCria, {'SB2','SB2','B2_SALPV',''} )
aAdd(aDbfCria, {'SB2','SB2','B2_CM1','B2_CM1'} )
aAdd(aDbfCria, {'SB2','SB2','B2_CM2','B2_CM2'} )
aAdd(aDbfCria, {'SB2','SB2','B2_CM3','B2_CM3'} )
aAdd(aDbfCria, {'SB2','SB2','B2_CM4','B2_CM4'} )
aAdd(aDbfCria, {'SB2','SB2','B2_CM5','B2_CM5'} )
aAdd(aDbfCria, {'SB2','SB2','B2_VFIM1','B2_VFIM1'} )
aAdd(aDbfCria, {'SB2','SB2','B2_VFIM2','B2_VFIM2'} )
aAdd(aDbfCria, {'SB2','SB2','B2_VFIM3','B2_VFIM3'} )
aAdd(aDbfCria, {'SB2','SB2','B2_VFIM4','B2_VFIM4'} )
aAdd(aDbfCria, {'SB2','SB2','B2_VFIM5','B2_VFIM5'} )
aAdd(aDbfCria, {'SB2','SB2','B2_VATU1','B2_VATU1'} )
aAdd(aDbfCria, {'SB2','SB2','B2_VATU2','B2_VATU2'} )
aAdd(aDbfCria, {'SB2','SB2','B2_VATU3','B2_VATU3'} )
aAdd(aDbfCria, {'SB2','SB2','B2_VATU4','B2_VATU4'} )
aAdd(aDbfCria, {'SB2','SB2','B2_VATU5','B2_VATU5'} )
aAdd(aDbfCria, {'SF1','SF1','F1_TIPO','F1_TIPO'} )
aAdd(aDbfCria, {'SF1','SF1','F1_FORMUL','F1_FORMUL'} )
aAdd(aDbfCria, {'SF1','SF1','F1_DOC','F1_DOC'} )
aAdd(aDbfCria, {'SF1','SF1','F1_SERIE','F1_SERIE'} )
aAdd(aDbfCria, {'SF1','SF1','F1_PESSOA','F1_FORNECE'} )
aAdd(aDbfCria, {'SF1','SF1','F1_EMISSAO','F1_EMISSAO'} )
aAdd(aDbfCria, {'SF1','SF1','F1_COND','F1_COND'} )
aAdd(aDbfCria, {'SF1','SF1','F1_EST','F1_EST'} )
aAdd(aDbfCria, {'SF1','SF1','F1_FRETE','F1_FRETE'} )
aAdd(aDbfCria, {'SF1','SF1','F1_DESPESA','F1_DESPESA'} )
aAdd(aDbfCria, {'SF1','SF1','F1_VALDESC','F1_DESCONT'} )
aAdd(aDbfCria, {'SF1','SF1','F1_BASEICM','F1_BASEICM'} )
aAdd(aDbfCria, {'SF1','SF1','F1_VALICM','F1_VALICM'} )
aAdd(aDbfCria, {'SF1','SF1','F1_BASEIPI','F1_BASEIPI'} )
aAdd(aDbfCria, {'SF1','SF1','F1_VALIPI','F1_VALIPI'} )
aAdd(aDbfCria, {'SF1','SF1','F1_VALMERC','F1_VALMERC'} )
aAdd(aDbfCria, {'SF1','SF1','F1_VALBRUT','F1_VALBRUT'} )
aAdd(aDbfCria, {'SF1','SF1','F1_BRICMS','F1_BRICMS'} )
aAdd(aDbfCria, {'SF1','SF1','F1_ICMSRET','F1_ICMSRET'} )
aAdd(aDbfCria, {'SF1','SF1','F1_IRRF','F1_IRRF'} )
aAdd(aDbfCria, {'SF1','SF1','F1_INSS','F1_INSS'} )
aAdd(aDbfCria, {'SF1','SF1','F1_ISS','F1_ISS'} )
aAdd(aDbfCria, {'SF1','SF1','F1_BASIMP1','F1_BASIMP1'} )
aAdd(aDbfCria, {'SF1','SF1','F1_BASIMP2','F1_BASIMP2'} )
aAdd(aDbfCria, {'SF1','SF1','F1_BASIMP3','F1_BASIMP3'} )
aAdd(aDbfCria, {'SF1','SF1','F1_BASIMP4','F1_BASIMP4'} )
aAdd(aDbfCria, {'SF1','SF1','F1_BASIMP5','F1_BASIMP5'} )
aAdd(aDbfCria, {'SF1','SF1','F1_BASIMP6','F1_BASIMP6'} )
aAdd(aDbfCria, {'SF1','SF1','F1_VALIMP1','F1_VALIMP1'} )
aAdd(aDbfCria, {'SF1','SF1','F1_VALIMP2','F1_VALIMP2'} )
aAdd(aDbfCria, {'SF1','SF1','F1_VALIMP3','F1_VALIMP3'} )
aAdd(aDbfCria, {'SF1','SF1','F1_VALIMP4','F1_VALIMP4'} )
aAdd(aDbfCria, {'SF1','SF1','F1_VALIMP5','F1_VALIMP5'} )
aAdd(aDbfCria, {'SF1','SF1','F1_VALIMP6','F1_VALIMP6'} )
aAdd(aDbfCria, {'SD1','SD1','D1_TIPO','D1_TIPO'} )
aAdd(aDbfCria, {'SD1','SD1','D1_DOC','D1_DOC'} )
aAdd(aDbfCria, {'SD1','SD1','D1_SERIE','D1_SERIE'} )
aAdd(aDbfCria, {'SD1','SD1','D1_PESSOA','D1_FORNECE'} )
aAdd(aDbfCria, {'SD1','SD1','D1_ITEM','D1_ITEM'} )
aAdd(aDbfCria, {'SD1','SD1','D1_CODPROD','D1_COD'} )
aAdd(aDbfCria, {'SD1','SD1','D1_CODUM','D1_UM'} )
aAdd(aDbfCria, {'SD1','SD1','D1_QUANT','D1_QUANT'} )
aAdd(aDbfCria, {'SD1','SD1','D1_PRCUNI','D1_VUNIT'} )
aAdd(aDbfCria, {'SD1','SD1','D1_TOTAL','D1_TOTAL'} )
aAdd(aDbfCria, {'SD1','SD1','D1_VALIPI','D1_VALIPI'} )
aAdd(aDbfCria, {'SD1','SD1','D1_VALICM','D1_VALICM'} )
aAdd(aDbfCria, {'SD1','SD1','D1_TES','D1_TES'} )
aAdd(aDbfCria, {'SD1','SD1','D1_CFOP','D1_CF'} )
aAdd(aDbfCria, {'SD1','SD1','D1_VALDESC','D1_VALDESC'} )
aAdd(aDbfCria, {'SD1','SD1','D1_IPI','D1_IPI'} )
aAdd(aDbfCria, {'SD1','SD1','D1_PICM','D1_PICM'} )
aAdd(aDbfCria, {'SD1','SD1','D1_BASEIPI','D1_BASEIPI'} )
aAdd(aDbfCria, {'SD1','SD1','D1_BASEICM','D1_BASEICM'} )
aAdd(aDbfCria, {'SD1','SD1','D1_LOCAL','D1_LOCAL'} )
aAdd(aDbfCria, {'SD1','SD1','D1_NUMPED','D1_PEDIDO'} )
aAdd(aDbfCria, {'SD1','SD1','D1_ITEMPC','D1_ITEMPC'} )
aAdd(aDbfCria, {'SD1','SD1','D1_QTDPC','D1_QTDPEDI'} )
aAdd(aDbfCria, {'SD1','SD1','D1_ICMSRET','D1_ICMSRET'} )
aAdd(aDbfCria, {'SD1','SD1','D1_BRICMS','D1_BRICMS'} )
aAdd(aDbfCria, {'SD1','SD1','D1_BASEISS','D1_BASEISS'} )
aAdd(aDbfCria, {'SD1','SD1','D1_ALIQISS','D1_ALIQISS'} )
aAdd(aDbfCria, {'SD1','SD1','D1_VALISS','D1_VALISS'} )
aAdd(aDbfCria, {'SD1','SD1','D1_BASEINS','D1_BASEINS'} )
aAdd(aDbfCria, {'SD1','SD1','D1_ALIQINS','D1_ALIQINS'} )
aAdd(aDbfCria, {'SD1','SD1','D1_VALINS','D1_VALINS'} )
aAdd(aDbfCria, {'SD1','SD1','D1_VALCMP','D1_ICMSCOM'} )
aAdd(aDbfCria, {'SD1','SD1','D1_FRETE','D1_VALFRE'} )
aAdd(aDbfCria, {'SD1','SD1','D1_DESPESA','D1_DESPESA'} )
aAdd(aDbfCria, {'SD1','SD1','D1_QTDDEV','D1_QTDEDEV'} )
aAdd(aDbfCria, {'SD1','SD1','D1_DTDIGIT','D1_DTDIGIT'} )
aAdd(aDbfCria, {'SD1','SD1','D1_EMISSAO','D1_EMISSAO'} )
aAdd(aDbfCria, {'SD1','SD1','D1_NFORI','D1_NFORI'} )
aAdd(aDbfCria, {'SD1','SD1','D1_SERIORI','D1_SERIORI'} )
aAdd(aDbfCria, {'SD1','SD1','D1_ITEMORI','D1_ITEMORI'} )
aAdd(aDbfCria, {'SD1','SD1','D1_BASIMP1','D1_BASIMP1'} )
aAdd(aDbfCria, {'SD1','SD1','D1_BASIMP2','D1_BASIMP2'} )
aAdd(aDbfCria, {'SD1','SD1','D1_BASIMP3','D1_BASIMP3'} )
aAdd(aDbfCria, {'SD1','SD1','D1_BASIMP4','D1_BASIMP4'} )
aAdd(aDbfCria, {'SD1','SD1','D1_BASIMP5','D1_BASIMP5'} )
aAdd(aDbfCria, {'SD1','SD1','D1_BASIMP6','D1_BASIMP6'} )
aAdd(aDbfCria, {'SD1','SD1','D1_VALIMP1','D1_VALIMP1'} )
aAdd(aDbfCria, {'SD1','SD1','D1_VALIMP2','D1_VALIMP2'} )
aAdd(aDbfCria, {'SD1','SD1','D1_VALIMP3','D1_VALIMP3'} )
aAdd(aDbfCria, {'SD1','SD1','D1_VALIMP4','D1_VALIMP4'} )
aAdd(aDbfCria, {'SD1','SD1','D1_VALIMP5','D1_VALIMP5'} )
aAdd(aDbfCria, {'SD1','SD1','D1_VALIMP6','D1_VALIMP6'} )
aAdd(aDbfCria, {'SD1','SD1','D1_ALQIMP1','D1_ALQIMP1'} )
aAdd(aDbfCria, {'SD1','SD1','D1_ALQIMP2','D1_ALQIMP2'} )
aAdd(aDbfCria, {'SD1','SD1','D1_ALQIMP3','D1_ALQIMP3'} )
aAdd(aDbfCria, {'SD1','SD1','D1_ALQIMP4','D1_ALQIMP4'} )
aAdd(aDbfCria, {'SD1','SD1','D1_ALQIMP5','D1_ALQIMP5'} )
aAdd(aDbfCria, {'SD1','SD1','D1_ALQIMP6','D1_ALQIMP6'} )
aAdd(aDbfCria, {'SD1','SD1','D1_CUSTO1','D1_CUSTO'} )
aAdd(aDbfCria, {'SD1','SD1','D1_CUSTO2','D1_CUSTO2'} )
aAdd(aDbfCria, {'SD1','SD1','D1_CUSTO3','D1_CUSTO3'} )
aAdd(aDbfCria, {'SD1','SD1','D1_CUSTO4','D1_CUSTO4'} )
aAdd(aDbfCria, {'SD1','SD1','D1_CUSTO5','D1_CUSTO5'} )
aAdd(aDbfCria, {'SD1','SD1','D1_NUMSEQ','D1_NUMSEQ'} )
aAdd(aDbfCria, {'SD1','SD1','D1_SEQCALC','D1_SEQCALC'} )
aAdd(aDbfCria, {'SF4','SF4','F4_COD','F4_CODIGO'} )
aAdd(aDbfCria, {'SF4','SF4','F4_TIPO','F4_TIPO'} )
aAdd(aDbfCria, {'SF4','SF4','F4_DESCRI','F4_TEXTO'} )
aAdd(aDbfCria, {'SF4','SF4','F4_DUPLIC','F4_DUPLIC'} )
aAdd(aDbfCria, {'SF4','SF4','F4_ESTOQUE','F4_ESTOQUE'} )
aAdd(aDbfCria, {'SF4','SF4','F4_CF','F4_CF'} )
aAdd(aDbfCria, {'SF4','SF4','F4_TESDV','F4_TESDV'} )
aAdd(aDbfCria, {'SF4','SF4','F4_ICM','F4_ICM'} )
aAdd(aDbfCria, {'SF4','SF4','F4_IPI','F4_IPI'} )
aAdd(aDbfCria, {'SF4','SF4','F4_INCIDE','F4_INCIDE'} )
aAdd(aDbfCria, {'SF4','SF4','F4_COMPL','F4_COMPL'} )
aAdd(aDbfCria, {'SF4','SF4','F4_IPIFRET','F4_IPIFRET'} )
aAdd(aDbfCria, {'SF4','SF4','F4_ISS','F4_ISS'} )
aAdd(aDbfCria, {'SF4','SF4','F4_INCSOL','F4_INCSOL'} )
aAdd(aDbfCria, {'SF4','SF4','F4_DESPIPI','F4_DESPIPI'} )
aAdd(aDbfCria, {'SF4','SF4','F4_CREDICM','F4_CREDICM'} )
aAdd(aDbfCria, {'SF4','SF4','F4_CREDIPI','F4_CREDIPI'} )
aAdd(aDbfCria, {'SF4','SF4','F4_BASEIPI','F4_BASEIPI'} )
aAdd(aDbfCria, {'SF4','SF4','F4_BASEICM','F4_BASEICM'} )
aAdd(aDbfCria, {'SFF','SFF','FF_COD','FF_COD'} )
aAdd(aDbfCria, {'SFF','SFF','FF_DESCRI','FF_DESCRI'} )
aAdd(aDbfCria, {'SFC','SFC','FC_COD','FC_COD'} )
aAdd(aDbfCria, {'SFC','SFC','FC_ITEM','FC_ITEM'} )
aAdd(aDbfCria, {'SFC','SFC','FC_IMPOSTO','FC_IMPOSTO'} )
aAdd(aDbfCria, {'SFC','SFC','FC_INCDUPL','FC_INCDUPL'} )
aAdd(aDbfCria, {'SFC','SFC','FC_INCNOTA','FC_INCNOTA'} )
aAdd(aDbfCria, {'SFC','SFC','FC_CREDITA','FC_CREDITA'} )
aAdd(aDbfCria, {'SFC','SFC','FC_INCIMP','FC_INCIMP'} )
aAdd(aDbfCria, {'SFC','SFC','FC_BASE','FC_BASE'} )
aAdd(aDbfCria, {'SFC','SFC','FC_CALCULO','FC_CALCULO'} )
aAdd(aDbfCria, {'SFC','SFC','FC_LIQUIDO','FC_LIQUIDO'} )
aAdd(aDbfCria, {'SD3','SD3','D3_CODTM','D3_TM'} )
aAdd(aDbfCria, {'SD3','SD3','D3_CODPROD','D3_COD'} )
aAdd(aDbfCria, {'SD3','SD3','D3_DESCRI','D3_DESCRI'} )
aAdd(aDbfCria, {'SD3','SD3','D3_LOCAL','D3_LOCAL'} )
aAdd(aDbfCria, {'SD3','SD3','D3_CODUM','D3_UM'} )
aAdd(aDbfCria, {'SD3','SD3','D3_EMISSAO','D3_EMISSAO'} )
aAdd(aDbfCria, {'SD3','SD3','D3_OP','D3_OP'} )
aAdd(aDbfCria, {'SD3','SD3','D3_QUANT','D3_QUANT'} )
aAdd(aDbfCria, {'SD3','SD3','D3_PARCTOT','D3_PARCTOT'} )
aAdd(aDbfCria, {'SD3','SD3','D3_DOC','D3_DOC'} )
aAdd(aDbfCria, {'SD3','SD3','D3_ESTORNO','D3_ESTORNO'} )
aAdd(aDbfCria, {'SD3','SD3','D3_CF','D3_CF'} )
aAdd(aDbfCria, {'SD3','SD3','D3_CUSTO1','D3_CUSTO1'} )
aAdd(aDbfCria, {'SD3','SD3','D3_CUSTO2','D3_CUSTO2'} )
aAdd(aDbfCria, {'SD3','SD3','D3_CUSTO3','D3_CUSTO3'} )
aAdd(aDbfCria, {'SD3','SD3','D3_CUSTO4','D3_CUSTO4'} )
aAdd(aDbfCria, {'SD3','SD3','D3_CUSTO5','D3_CUSTO5'} )
aAdd(aDbfCria, {'SD3','SD3','D3_NUMSEQ','D3_NUMSEQ'} )
aAdd(aDbfCria, {'SD3','SD3','D3_SEQCALC','D3_SEQCALC'} )
aAdd(aDbfCria, {'SD3','SD3','D3_VALOR',''} )
aAdd(aDbfCria, {'SD3','SD3','D3_IDENT','D3_IDENT'} )
aAdd(aDbfCria, {'SD3','SD3','D3_TRT','D3_TRT'} )
aAdd(aDbfCria, {'SF5','SF5','F5_CODTM','F5_CODIGO'} )
aAdd(aDbfCria, {'SF5','SF5','F5_TIPO','F5_TIPO'} )
aAdd(aDbfCria, {'SF5','SF5','F5_DESCRI','F5_TEXTO'} )
aAdd(aDbfCria, {'SF5','SF5','F5_ATUEMP','F5_ATUEMP'} )
aAdd(aDbfCria, {'SB9','SB9','B9_CODPROD','B9_COD'} )
aAdd(aDbfCria, {'SB9','SB9','B9_LOCAL','B9_LOCAL'} )
aAdd(aDbfCria, {'SB9','SB9','B9_QINI','B9_QINI'} )
aAdd(aDbfCria, {'SB9','SB9','B9_DATA','B9_DATA'} )
aAdd(aDbfCria, {'SB9','SB9','B9_VINI1','B9_VINI1'} )
aAdd(aDbfCria, {'SB9','SB9','B9_VINI2','B9_VINI2'} )
aAdd(aDbfCria, {'SB9','SB9','B9_VINI3','B9_VINI3'} )
aAdd(aDbfCria, {'SB9','SB9','B9_VINI4','B9_VINI4'} )
aAdd(aDbfCria, {'SB9','SB9','B9_VINI5','B9_VINI5'} )
aAdd(aDbfCria, {'SD2','SD2','D2_TIPO','D2_TIPO'} )
aAdd(aDbfCria, {'SD2','SD2','D2_DOC','D2_DOC'} )
aAdd(aDbfCria, {'SD2','SD2','D2_SERIE','D2_SERIE'} )
aAdd(aDbfCria, {'SD2','SD2','D2_PESSOA','D2_CLIENTE'} )
aAdd(aDbfCria, {'SD2','SD2','D2_ITEM','D2_ITEM'} )
aAdd(aDbfCria, {'SD2','SD2','D2_CODPROD','D2_COD'} )
aAdd(aDbfCria, {'SD2','SD2','D2_CODUM','D2_UM'} )
aAdd(aDbfCria, {'SD2','SD2','D2_QUANT','D2_QUANT'} )
aAdd(aDbfCria, {'SD2','SD2','D2_PRCUNI','D2_PRCVEN'} )
aAdd(aDbfCria, {'SD2','SD2','D2_TOTAL','D2_TOTAL'} )
aAdd(aDbfCria, {'SD2','SD2','D2_VALIPI','D2_VALIPI'} )
aAdd(aDbfCria, {'SD2','SD2','D2_VALICM','D2_VALICM'} )
aAdd(aDbfCria, {'SD2','SD2','D2_TES','D2_TES'} )
aAdd(aDbfCria, {'SD2','SD2','D2_CFOP','D2_CF'} )
aAdd(aDbfCria, {'SD2','SD2','D2_VALDESC','D2_DESCON'} )
aAdd(aDbfCria, {'SD2','SD2','D2_IPI','D2_IPI'} )
aAdd(aDbfCria, {'SD2','SD2','D2_PICM','D2_PICM'} )
aAdd(aDbfCria, {'SD2','SD2','D2_BASEIPI','D2_BASEIPI'} )
aAdd(aDbfCria, {'SD2','SD2','D2_BASEICM','D2_BASEICM'} )
aAdd(aDbfCria, {'SD2','SD2','D2_LOCAL','D2_LOCAL'} )
aAdd(aDbfCria, {'SD2','SD2','D2_NUMPED','D2_PEDIDO'} )
aAdd(aDbfCria, {'SD2','SD2','D2_ITEMPV','D2_ITEMPV'} )
aAdd(aDbfCria, {'SD2','SD2','D2_ICMSRET','D2_ICMSRET'} )
aAdd(aDbfCria, {'SD2','SD2','D2_BRICMS','D2_BRICMS'} )
aAdd(aDbfCria, {'SD2','SD2','D2_BASEISS','D2_BASEISS'} )
aAdd(aDbfCria, {'SD2','SD2','D2_ALIQISS','D2_ALIQISS'} )
aAdd(aDbfCria, {'SD2','SD2','D2_VALISS','D2_VALISS'} )
aAdd(aDbfCria, {'SD2','SD2','D2_BASEINS','D2_BASEINS'} )
aAdd(aDbfCria, {'SD2','SD2','D2_ALIQINS','D2_ALIQINS'} )
aAdd(aDbfCria, {'SD2','SD2','D2_VALINS','D2_VALINS'} )
aAdd(aDbfCria, {'SD2','SD2','D2_VALCMP','D2_VALCMP'} )
aAdd(aDbfCria, {'SD2','SD2','D2_FRETE','D2_VALFRE'} )
aAdd(aDbfCria, {'SD2','SD2','D2_DESPESA','D2_DESPESA'} )
aAdd(aDbfCria, {'SD2','SD2','D2_QTDDEV','D2_QTDEDEV'} )
aAdd(aDbfCria, {'SD2','SD2','D2_DTDIGIT',''} )
aAdd(aDbfCria, {'SD2','SD2','D2_EMISSAO','D2_EMISSAO'} )
aAdd(aDbfCria, {'SD2','SD2','D2_BASIMP1','D2_BASIMP1'} )
aAdd(aDbfCria, {'SD2','SD2','D2_BASIMP2','D2_BASIMP2'} )
aAdd(aDbfCria, {'SD2','SD2','D2_BASIMP3','D2_BASIMP3'} )
aAdd(aDbfCria, {'SD2','SD2','D2_BASIMP4','D2_BASIMP4'} )
aAdd(aDbfCria, {'SD2','SD2','D2_BASIMP5','D2_BASIMP5'} )
aAdd(aDbfCria, {'SD2','SD2','D2_BASIMP6','D2_BASIMP6'} )
aAdd(aDbfCria, {'SD2','SD2','D2_VALIMP1','D2_VALIMP1'} )
aAdd(aDbfCria, {'SD2','SD2','D2_VALIMP2','D2_VALIMP2'} )
aAdd(aDbfCria, {'SD2','SD2','D2_VALIMP3','D2_VALIMP3'} )
aAdd(aDbfCria, {'SD2','SD2','D2_VALIMP4','D2_VALIMP4'} )
aAdd(aDbfCria, {'SD2','SD2','D2_VALIMP5','D2_VALIMP5'} )
aAdd(aDbfCria, {'SD2','SD2','D2_VALIMP6','D2_VALIMP6'} )
aAdd(aDbfCria, {'SD2','SD2','D2_ALQIMP1','D2_ALQIMP1'} )
aAdd(aDbfCria, {'SD2','SD2','D2_ALQIMP2','D2_ALQIMP2'} )
aAdd(aDbfCria, {'SD2','SD2','D2_ALQIMP3','D2_ALQIMP3'} )
aAdd(aDbfCria, {'SD2','SD2','D2_ALQIMP4','D2_ALQIMP4'} )
aAdd(aDbfCria, {'SD2','SD2','D2_ALQIMP5','D2_ALQIMP5'} )
aAdd(aDbfCria, {'SD2','SD2','D2_ALQIMP6','D2_ALQIMP6'} )
aAdd(aDbfCria, {'SD2','SD2','D2_NFORI','D2_NFORI'} )
aAdd(aDbfCria, {'SD2','SD2','D2_SERIORI','D2_SERIORI'} )
aAdd(aDbfCria, {'SD2','SD2','D2_ITEMORI','D2_ITEMORI'} )
aAdd(aDbfCria, {'SD2','SD2','D2_CUSTO1','D2_CUSTO1'} )
aAdd(aDbfCria, {'SD2','SD2','D2_CUSTO2','D2_CUSTO2'} )
aAdd(aDbfCria, {'SD2','SD2','D2_CUSTO3','D2_CUSTO3'} )
aAdd(aDbfCria, {'SD2','SD2','D2_CUSTO4','D2_CUSTO4'} )
aAdd(aDbfCria, {'SD2','SD2','D2_CUSTO5','D2_CUSTO5'} )
aAdd(aDbfCria, {'SD2','SD2','D2_NUMSEQ','D2_NUMSEQ'} )
aAdd(aDbfCria, {'SD2','SD2','D2_SEQCALC','D2_SEQCALC'} )
aAdd(aDbfCria, {'SC5','SC5','C5_NUM','C5_NUM'} )
aAdd(aDbfCria, {'SC5','SC5','C5_TIPO','C5_TIPO'} )
aAdd(aDbfCria, {'SC5','SC5','C5_PESSOA','C5_CLIENTE'} )
aAdd(aDbfCria, {'SC5','SC5','C5_TIPOCLI','C5_TIPOCLI'} )
aAdd(aDbfCria, {'SC5','SC5','C5_COND','C5_CONDPAG'} )
aAdd(aDbfCria, {'SC5','SC5','C5_EMISSAO','C5_EMISSAO'} )
aAdd(aDbfCria, {'SC5','SC5','C5_NUMNF','C5_NOTA'} )
aAdd(aDbfCria, {'SC5','SC5','C5_SERNF','C5_SERIE'} )
aAdd(aDbfCria, {'SC5','SC5','C5_FRETE','C5_FRETE'} )
aAdd(aDbfCria, {'SC5','SC5','C5_DESPESA','C5_DESPESA'} )
aAdd(aDbfCria, {'SC5','SC5','C5_VALDESC','C5_DESCONT'} )
aAdd(aDbfCria, {'SC5','SC5','C5_BASEICM',''} )
aAdd(aDbfCria, {'SC5','SC5','C5_VALICM',''} )
aAdd(aDbfCria, {'SC5','SC5','C5_BASEIPI',''} )
aAdd(aDbfCria, {'SC5','SC5','C5_VALIPI',''} )
aAdd(aDbfCria, {'SC5','SC5','C5_VALMERC','C5_VALMERC'} )
aAdd(aDbfCria, {'SC5','SC5','C5_VALBRUT',''} )
aAdd(aDbfCria, {'SC5','SC5','C5_BRICMS',''} )
aAdd(aDbfCria, {'SC5','SC5','C5_ICMSRET',''} )
aAdd(aDbfCria, {'SC5','SC5','C5_IRRF',''} )
aAdd(aDbfCria, {'SC5','SC5','C5_INSS',''} )
Cont_Tcpos(aDbfCria)

aStruDbf := {}
aAdd(aStruDbf,{ 'ALIAS', 'C', 3, 0})
aAdd(aStruDbf,{ 'ALIASMAST', 'C', 3, 0})
aAdd(aStruDbf,{ 'NOMECPO', 'C', 10, 0})
aAdd(aStruDbf,{ 'CPOMASTER', 'C', 10, 0})

cArqCpos := CriaTrab(aStruDbf)
DbUseArea(.T.,,cArqCpos,'CPO',.F.,.F.)
IndRegua("CPO",cArqCpos,"ALIAS+NOMECPO+ALIASMAST",,,STR0013)//"Criando Indํce Temporแrio"

For x := 1 TO Len(aDbfCria)
   RecLock("CPO",.T.)
      For nCtd := 1 TO Len(aStruDbf)
         FieldPut(nCtd, aDbfCria[x][nCtd])
     Next
   MsUnLock()
Next

Return(cArqCpos)
//----------------------------------------------------------------
Function Cont_Tcpos(aDbfCria)

aAdd(aDbfCria, {'SC5','SC5','C5_ISS',''} )
aAdd(aDbfCria, {'SC5','SC5','C5_SERNF',''} )
aAdd(aDbfCria, {'SC5','SC5','C5_REVENC',''} )
aAdd(aDbfCria, {'SC5','SC5','C5_STATUS',''} )
aAdd(aDbfCria, {'SC5','SC5','C5_BASEDUP',''} )
aAdd(aDbfCria, {'SC5','SC5','C5_BASIMP1',''} )
aAdd(aDbfCria, {'SC5','SC5','C5_BASIMP2',''} )
aAdd(aDbfCria, {'SC5','SC5','C5_BASIMP3',''} )
aAdd(aDbfCria, {'SC5','SC5','C5_BASIMP4',''} )
aAdd(aDbfCria, {'SC5','SC5','C5_BASIMP5',''} )
aAdd(aDbfCria, {'SC5','SC5','C5_BASIMP6',''} )
aAdd(aDbfCria, {'SC5','SC5','C5_VALIMP1',''} )
aAdd(aDbfCria, {'SC5','SC5','C5_VALIMP2',''} )
aAdd(aDbfCria, {'SC5','SC5','C5_VALIMP3',''} )
aAdd(aDbfCria, {'SC5','SC5','C5_VALIMP4',''} )
aAdd(aDbfCria, {'SC5','SC5','C5_VALIMP5',''} )
aAdd(aDbfCria, {'SC5','SC5','C5_VALIMP6',''} )
aAdd(aDbfCria, {'SC5','SC5','C5_VEND1','C5_VEND1'} )
aAdd(aDbfCria, {'SC5','SC5','C5_COMIS1','C5_COMIS1'} )
aAdd(aDbfCria, {'SC5','SC5','C5_VEND2','C5_VEND2'} )
aAdd(aDbfCria, {'SC5','SC5','C5_COMIS2','C5_COMIS2'} )
aAdd(aDbfCria, {'SC5','SC5','C5_MENNOTA','C5_MENNOTA'} )
aAdd(aDbfCria, {'SC5','SC5','C5_TABELA','C5_TABELA'} )
aAdd(aDbfCria, {'SC6','SC6','C6_NUM','C6_NUM'} )
aAdd(aDbfCria, {'SC6','SC6','C6_ITEM','C6_ITEM'} )
aAdd(aDbfCria, {'SC6','SC6','C6_CODPROD','C6_PRODUTO'} )
aAdd(aDbfCria, {'SC6','SC6','C6_CODUM','C6_UM'} )
aAdd(aDbfCria, {'SC6','SC6','C6_QUANT','C6_QTDVEN'} )
aAdd(aDbfCria, {'SC6','SC6','C6_PRCUNI','C6_PRCVEN'} )
aAdd(aDbfCria, {'SC6','SC6','C6_TOTAL','C6_VALOR'} )
aAdd(aDbfCria, {'SC6','SC6','C6_VALIPI',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_VALICM',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_TES','C6_TES'} )
aAdd(aDbfCria, {'SC6','SC6','C6_CFOP','C6_CF'} )
aAdd(aDbfCria, {'SC6','SC6','C6_VALDESC','C6_VALDESC'} )
aAdd(aDbfCria, {'SC6','SC6','C6_IPI',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_PICM',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_BASEIPI',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_BASEICM',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_LOCAL','C6_LOCAL'} )
aAdd(aDbfCria, {'SC6','SC6','C6_ICMSRET',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_BRICMS',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_BASEISS',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_ALIQISS',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_VALISS',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_BASEINS',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_ALIQINS',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_VALINS',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_VALCMP',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_FRETE',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_DESPESA',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_BASIMP1',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_BASIMP2',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_BASIMP3',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_BASIMP4',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_BASIMP5',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_BASIMP6',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_VALIMP1',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_VALIMP2',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_VALIMP3',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_VALIMP4',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_VALIMP5',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_VALIMP6',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_ALQIMP1',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_ALQIMP2',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_ALQIMP3',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_ALQIMP4',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_ALQIMP5',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_ALQIMP6',''} )
aAdd(aDbfCria, {'SC6','SC6','C6_NFORI','C6_NFORI'} )
aAdd(aDbfCria, {'SC6','SC6','C6_SERIORI','C6_SERIORI'} )
aAdd(aDbfCria, {'SC6','SC6','C6_ITEMORI','C6_ITEMORI'} )
aAdd(aDbfCria, {'SC6','SC6','C6_ENTREG','C6_ENTREG'} )
aAdd(aDbfCria, {'SEA','SEA','EA_NUM','EA_NUM'} )
aAdd(aDbfCria, {'SEA','SEA','EA_PARCELA','EA_PARCELA'} )
aAdd(aDbfCria, {'SEA','SEA','EA_VENCTO','EA_VENCTO'} )
aAdd(aDbfCria, {'SEA','SEA','EA_VENCREA','EA_VENCREA'} )
aAdd(aDbfCria, {'SEA','SEA','EA_VALOR','EA_VALOR'} )
aAdd(aDbfCria, {'SEA','SEA','EA_MOEDA','EA_MOEDA'} )
aAdd(aDbfCria, {'SEA','SEA','EA_CODCAT','EA_CODCAT'} )
aAdd(aDbfCria, {'SFB','SFB','FB_CODIGO','FB_CODIGO'} )
aAdd(aDbfCria, {'SFB','SFB','FB_DESCR','FB_DESCR'} )
aAdd(aDbfCria, {'SFB','SFB','FB_CPOIMP','FB_CPOIMP'} )
aAdd(aDbfCria, {'SFB','SFB','FB_FORMENT','FB_FORMENT'} )
aAdd(aDbfCria, {'SFB','SFB','FB_FORMSAI','FB_FORMSAI'} )
aAdd(aDbfCria, {'SFB','SFB','FB_ALIQ','FB_ALIQ'} )
aAdd(aDbfCria, {'SFB','SFB','FB_PESSOA','FB_PESSOA'} )
aAdd(aDbfCria, {'SEK','SEK','EK_ORDPAGO','EK_ORDPAGO'} )
aAdd(aDbfCria, {'SEK','SEK','EK_TIPODOC','EK_TIPODOC'} )
aAdd(aDbfCria, {'SEK','SEK','EK_SERIE','EK_SERIE'} )
aAdd(aDbfCria, {'SEK','SEK','EK_NUM','EK_NUM'} )
aAdd(aDbfCria, {'SEK','SEK','EK_PARCELA','EK_PARCELA'} )
aAdd(aDbfCria, {'SEK','SEK','EK_TIPO','EK_TIPO'} )
aAdd(aDbfCria, {'SEK','SEK','EK_VALOR','EK_VALOR'} )
aAdd(aDbfCria, {'SEK','SEK','EK_MOEDA','EK_MOEDA'} )
aAdd(aDbfCria, {'SEK','SEK','EK_PESSOA','EK_PESSOA'} )
aAdd(aDbfCria, {'SEK','SEK','EK_BANCO','EK_BANCO'} )
aAdd(aDbfCria, {'SEK','SEK','EK_AGENCIA','EK_AGENCIA'} )
aAdd(aDbfCria, {'SEK','SEK','EK_CONTA','EK_CONTA'} )
aAdd(aDbfCria, {'SEK','SEK','EK_EMISSAO','EK_EMISSAO'} )
aAdd(aDbfCria, {'SEK','SEK','EK_VENCTO','EK_VENCTO'} )
aAdd(aDbfCria, {'SEK','SEK','EK_DESCONT','EK_DESCONT'} )
aAdd(aDbfCria, {'SEK','SEK','EK_JUROS','EK_JUROS'} )
aAdd(aDbfCria, {'SEK','SEK','EK_VLMOED1','EK_VLMOED1'} )
aAdd(aDbfCria, {'SEL','SEL','EL_RECIBO','EL_RECIBO'} )
aAdd(aDbfCria, {'SEL','SEL','EL_PESSOA','EL_PESSOA'} )
aAdd(aDbfCria, {'SEL','SEL','EL_TIPO','EL_TIPO'} )
aAdd(aDbfCria, {'SEL','SEL','EL_TIPODOC','EL_TIPODOC'} )
aAdd(aDbfCria, {'SEL','SEL','EL_SERIE','EL_SERIE'} )
aAdd(aDbfCria, {'SEL','SEL','EL_NUMERO','EL_NUMERO'} )
aAdd(aDbfCria, {'SEL','SEL','EL_PARCELA','EL_PARCELA'} )
aAdd(aDbfCria, {'SEL','SEL','EL_VALOR','EL_VALOR'} )
aAdd(aDbfCria, {'SEL','SEL','EL_MOEDA','EL_MOEDA'} )
aAdd(aDbfCria, {'SEL','SEL','EL_EMISSAO','EL_EMISSAO'} )
aAdd(aDbfCria, {'SEL','SEL','EL_VENCTO','EL_VENCTO'} )
aAdd(aDbfCria, {'SEL','SEL','EL_TPCRED','EL_TPCRED'} )
aAdd(aDbfCria, {'SEL','SEL','EL_BANCO','EL_BANCO'} )
aAdd(aDbfCria, {'SEL','SEL','EL_AGENCIA','EL_AGENCIA'} )
aAdd(aDbfCria, {'SEL','SEL','EL_CONTA','EL_CONTA'} )
aAdd(aDbfCria, {'SEL','SEL','EL_BCOCHQ','EL_BCOCHQ'} )
aAdd(aDbfCria, {'SEL','SEL','EL_AGECHQ','EL_AGECHQ'} )
aAdd(aDbfCria, {'SEL','SEL','EL_CTACHQ','EL_CTACHQ'} )
aAdd(aDbfCria, {'SEL','SEL','EL_DESCONT','EL_DESCONT'} )
aAdd(aDbfCria, {'SEL','SEL','EL_VLMOED1','EL_VLMOED1'} )
aAdd(aDbfCria, {'SFE','SFE','FE_NROCERT','FE_NROCERT'} )
aAdd(aDbfCria, {'SFE','SFE','FE_EMISSAO','FE_EMISSAO'} )
aAdd(aDbfCria, {'SFE','SFE','FE_PESSOA','FE_PESSOA'} )
aAdd(aDbfCria, {'SFE','SFE','FE_TIPO','FE_TIPO'} )
aAdd(aDbfCria, {'SFE','SFE','FE_ORDPAGO','FE_ORDPAGO'} )
aAdd(aDbfCria, {'SFE','SFE','FE_NFISCAL','FE_NFISCAL'} )
aAdd(aDbfCria, {'SFE','SFE','FE_SERIE','FE_SERIE'} )
aAdd(aDbfCria, {'SFE','SFE','FE_VALBASE','FE_VALBASE'} )
aAdd(aDbfCria, {'SFE','SFE','FE_ALIQ','FE_ALIQ'} )
aAdd(aDbfCria, {'SFE','SFE','FE_VALIMP','FE_VALIMP'} )
aAdd(aDbfCria, {'SFE','SFE','FE_RETENC','FE_RETENC'} )
aAdd(aDbfCria, {'SFE','SFE','FE_DEDUC','FE_DEDUC'} )
aAdd(aDbfCria, {'SFE','SFE','FE_PORCRET','FE_PORCRET'} )
aAdd(aDbfCria, {'SFE','SFE','FE_CONCEPT','FE_CONCEPT'} )
aAdd(aDbfCria, {'SFE','SFE','FE_PARCELA','FE_PARCELA'} )
aAdd(aDbfCria, {'SFG','SFG','FG_IMPOSTO','FG_IMPOSTO'} )
aAdd(aDbfCria, {'SFG','SFG','FG_ITEM','FG_ITEM'} )
aAdd(aDbfCria, {'SFG','SFG','FG_ALIQ','FG_ALIQ'} )
aAdd(aDbfCria, {'SFG','SFG','FG_CFO','FG_CFO'} )
aAdd(aDbfCria, {'SFG','SFG','FG_CFO_C','FG_CFO_C'} )
aAdd(aDbfCria, {'SFG','SFG','FG_CFO_V','FG_CFO_V'} )
aAdd(aDbfCria, {'SFG','SFG','FG_IMPORTE','FG_IMPORTE'} )
aAdd(aDbfCria, {'SFG','SFG','FG_FXDE','FG_FXDE'} )
aAdd(aDbfCria, {'SFG','SFG','FG_FXATE','FG_FXATE'} )
aAdd(aDbfCria, {'SFG','SFG','FG_PERC','FG_PERC'} )
aAdd(aDbfCria, {'SFG','SFG','FG_SERIENF','FG_SERIENF'} )
aAdd(aDbfCria, {'SFG','SFG','FG_TIPO','FG_TIPO'} )
aAdd(aDbfCria, {'SFG','SFG','FG_ZONFIS','FG_ZONFIS'} )
aAdd(aDbfCria, {'SFH','SFH','FH_AGENTE','FH_AGENTE'} )
aAdd(aDbfCria, {'SFH','SFH','FH_ZONFIS','FH_ZONFIS'} )
aAdd(aDbfCria, {'SFH','SFH','FH_NOME','FH_NOME'} )
aAdd(aDbfCria, {'SFH','SFH','FH_PESSOA','FH_PESSOA'} )
aAdd(aDbfCria, {'SFH','SFH','FH_IMPOSTO','FH_IMPOSTO'} )
aAdd(aDbfCria, {'SFH','SFH','FH_PERCIBI','FH_PERCIBI'} )
aAdd(aDbfCria, {'SFH','SFH','FH_ISENTO','FH_ISENTO'} )
aAdd(aDbfCria, {'SFH','SFH','FH_PERCENT','FH_PERCENT'} )
aAdd(aDbfCria, {'SFH','SFH','FH_APERIB','FH_APERIB'} )
aAdd(aDbfCria, {'SF2','SF2','F2_TIPO','F2_TIPO'} )
aAdd(aDbfCria, {'SF2','SF2','F2_DOC','F2_DOC'} )
aAdd(aDbfCria, {'SF2','SF2','F2_SERIE','F2_SERIE'} )
aAdd(aDbfCria, {'SF2','SF2','F2_PESSOA','F2_CLIENTE'} )
aAdd(aDbfCria, {'SF2','SF2','F2_EMISSAO','F2_EMISSAO'} )
aAdd(aDbfCria, {'SF2','SF2','F2_COND','F2_COND'} )
aAdd(aDbfCria, {'SF2','SF2','F2_EST','F2_EST'} )
aAdd(aDbfCria, {'SF2','SF2','F2_FRETE','F2_FRETE'} )
aAdd(aDbfCria, {'SF2','SF2','F2_DESPESA','F2_DESPESA'} )
aAdd(aDbfCria, {'SF2','SF2','F2_VALDESC','F2_DESCONT'} )
aAdd(aDbfCria, {'SF2','SF2','F2_BASEICM','F2_BASEICM'} )
aAdd(aDbfCria, {'SF2','SF2','F2_VALICM','F2_VALICM'} )
aAdd(aDbfCria, {'SF2','SF2','F2_BASEIPI','F2_BASEIPI'} )
aAdd(aDbfCria, {'SF2','SF2','F2_VALIPI','F2_VALIPI'} )
aAdd(aDbfCria, {'SF2','SF2','F2_VALMERC','F2_VALMERC'} )
aAdd(aDbfCria, {'SF2','SF2','F2_VALBRUT','F2_VALBRUT'} )
aAdd(aDbfCria, {'SF2','SF2','F2_BRICMS','F2_BRICMS'} )
aAdd(aDbfCria, {'SF2','SF2','F2_ICMSRET','F2_ICMSRET'} )
aAdd(aDbfCria, {'SF2','SF2','F2_IRRF','F2_VALIRRF'} )
aAdd(aDbfCria, {'SF2','SF2','F2_INSS','F2_VALINSS'} )
aAdd(aDbfCria, {'SF2','SF2','F2_ISS','F2_VALISS'} )
aAdd(aDbfCria, {'SF2','SF2','F2_BASIMP1','F2_BASIMP1'} )
aAdd(aDbfCria, {'SF2','SF2','F2_BASIMP2','F2_BASIMP2'} )
aAdd(aDbfCria, {'SF2','SF2','F2_BASIMP3','F2_BASIMP3'} )
aAdd(aDbfCria, {'SF2','SF2','F2_BASIMP4','F2_BASIMP4'} )
aAdd(aDbfCria, {'SF2','SF2','F2_BASIMP5','F2_BASIMP5'} )
aAdd(aDbfCria, {'SF2','SF2','F2_BASIMP6','F2_BASIMP6'} )
aAdd(aDbfCria, {'SF2','SF2','F2_VALIMP1','F2_VALIMP1'} )
aAdd(aDbfCria, {'SF2','SF2','F2_VALIMP2','F2_VALIMP2'} )
aAdd(aDbfCria, {'SF2','SF2','F2_VALIMP3','F2_VALIMP3'} )
aAdd(aDbfCria, {'SF2','SF2','F2_VALIMP4','F2_VALIMP4'} )
aAdd(aDbfCria, {'SF2','SF2','F2_VALIMP5','F2_VALIMP5'} )
aAdd(aDbfCria, {'SF2','SF2','F2_VALIMP6','F2_VALIMP6'} )
aAdd(aDbfCria, {'SF2','SF2','F2_BASEDUP',''} )
aAdd(aDbfCria, {'SF2','SF2','F2_VEND1','F2_VEND1'} )
aAdd(aDbfCria, {'SF2','SF2','F2_COMIS1',''} )
aAdd(aDbfCria, {'SF2','SF2','F2_VEND2','F2_VEND2'} )
aAdd(aDbfCria, {'SF2','SF2','F2_COMIS2',''} )
aAdd(aDbfCria, {'SF2','SF2','F2_MENNOTA',''} )
aAdd(aDbfCria, {'SF2','SF2','F2_TABELA',''} )
aAdd(aDbfCria, {'SG1','SG1','G1_CODPROD','G1_COD'} )
aAdd(aDbfCria, {'SG1','SG1','G1_COMP','G1_COMP'} )
aAdd(aDbfCria, {'SG1','SG1','G1_DESCRI','G1_DESC'} )
aAdd(aDbfCria, {'SG1','SG1','G1_TRT','G1_TRT'} )
aAdd(aDbfCria, {'SG1','SG1','G1_QUANT','G1_QUANT'} )
aAdd(aDbfCria, {'SG1','SG1','G1_PERDA','G1_PERDA'} )
aAdd(aDbfCria, {'SG1','SG1','G1_INI','G1_INI'} )
aAdd(aDbfCria, {'SG1','SG1','G1_FIM','G1_FIM'} )
aAdd(aDbfCria, {'SG1','SG1','G1_OBSERV','G1_OBSERV'} )
aAdd(aDbfCria, {'SG1','SG1','G1_FIXVAR','G1_FIXVAR'} )
aAdd(aDbfCria, {'SG1','SG1','G1_NIV','G1_NIV'} )
aAdd(aDbfCria, {'SG1','SG1','G1_NIVINV','G1_NIVINV'} )
aAdd(aDbfCria, {'SX6','SX6','X6_FIL','X6_FIL'} )
aAdd(aDbfCria, {'SX6','SX6','X6_TIPO','X6_TIPO'} )
aAdd(aDbfCria, {'SX6','SX6','X6_DESCRIC','X6_DESCRIC'} )
aAdd(aDbfCria, {'SX6','SX6','X6_DSCSPA','X6_DSCSPA'} )
aAdd(aDbfCria, {'SX6','SX6','X6_DSCENG','X6_DSCENG'} )
aAdd(aDbfCria, {'SX6','SX6','X6_VAR','X6_VAR'} )
aAdd(aDbfCria, {'SX6','SX6','X6_CONTEUD','X6_CONTEUD'} )
aAdd(aDbfCria, {'SX6','SX6','X6_CONTSPA','X6_CONTSPA'} )
aAdd(aDbfCria, {'SX6','SX6','X6_CONTENG','X6_CONTENG'} )
aAdd(aDbfCria, {'SX6','SX6','X6_PROPRI','X6_PROPRI'} )
aAdd(aDbfCria, {'SF7','SF7','F7_GRTRIB','F7_GRTRIB'} )
aAdd(aDbfCria, {'SF7','SF7','F7_SEQUEN','F7_SEQUEN'} )
aAdd(aDbfCria, {'SF7','SF7','F7_EST','F7_EST'} )
aAdd(aDbfCria, {'SF7','SF7','F7_TIPOCLI','F7_TIPOCLI'} )
aAdd(aDbfCria, {'SF7','SF7','F7_ALIQINT','F7_ALIQINT'} )
aAdd(aDbfCria, {'SF7','SF7','F7_ALIQEXT','F7_ALIQEXT'} )
aAdd(aDbfCria, {'SF7','SF7','F7_MARGEM','F7_MARGEM'} )
aAdd(aDbfCria, {'SF7','SF7','F7_IMPOSTO','F7_IMPOSTO'} )
aAdd(aDbfCria, {'SA8','SA8','A8_SIGLA','A8_SIGLA'} )
aAdd(aDbfCria, {'SA8','SA8','A8_DESCRI','A8_DESCRI'} )
aAdd(aDbfCria, {'SC2','SC2','C2_NUM','C2_NUM'} )
aAdd(aDbfCria, {'SC2','SC2','C2_ITEM','C2_ITEM'} )
aAdd(aDbfCria, {'SC2','SC2','C2_SEQUEN','C2_SEQUEN'} )
aAdd(aDbfCria, {'SC2','SC2','C2_CODPROD','C2_PRODUTO'} )
aAdd(aDbfCria, {'SC2','SC2','C2_LOCAL','C2_LOCAL'} )
aAdd(aDbfCria, {'SC2','SC2','C2_QUANT','C2_QUANT'} )
aAdd(aDbfCria, {'SC2','SC2','C2_CODUM','C2_UM'} )
aAdd(aDbfCria, {'SC2','SC2','C2_DATPRI','C2_DATPRI'} )
aAdd(aDbfCria, {'SC2','SC2','C2_DATPRF','C2_DATPRF'} )
aAdd(aDbfCria, {'SC2','SC2','C2_OBS','C2_OBS'} )
aAdd(aDbfCria, {'SC2','SC2','C2_EMISSAO','C2_EMISSAO'} )
aAdd(aDbfCria, {'SC2','SC2','C2_QUJE','C2_QUJE'} )
aAdd(aDbfCria, {'SC2','SC2','C2_DATRF','C2_DATRF'} )
aAdd(aDbfCria, {'SC2','SC2','C2_NIVEL','C2_NIVEL'} )
aAdd(aDbfCria, {'SC2','SC2','C2_DATAJI','C2_DATAJI'} )
aAdd(aDbfCria, {'SC2','SC2','C2_DATAJF','C2_DATAJF'} )
aAdd(aDbfCria, {'SC2','SC2','C2_AGLUT','C2_AGLUT'} )
aAdd(aDbfCria, {'SC2','SC2','C2_PERDA','C2_PERDA'} )
aAdd(aDbfCria, {'SC2','SC2','C2_OK','C2_OK'} )
aAdd(aDbfCria, {'SC2','SC2','C2_SEQPAI','C2_SEQPAI'} )
aAdd(aDbfCria, {'SC2','SC2','C2_PEDIDO','C2_PEDIDO'} )
aAdd(aDbfCria, {'SC2','SC2','C2_ITEMPV','C2_ITEMPV'} )
aAdd(aDbfCria, {'SC2','SC2','C2_VINI1','C2_VINI1'} )
aAdd(aDbfCria, {'SC2','SC2','C2_VINI2','C2_VINI2'} )
aAdd(aDbfCria, {'SC2','SC2','C2_VINI3','C2_VINI3'} )
aAdd(aDbfCria, {'SC2','SC2','C2_VINI4','C2_VINI4'} )
aAdd(aDbfCria, {'SC2','SC2','C2_VINI5','C2_VINI5'} )
aAdd(aDbfCria, {'SC2','SC2','C2_VATU1','C2_VATU1'} )
aAdd(aDbfCria, {'SC2','SC2','C2_VATU2','C2_VATU2'} )
aAdd(aDbfCria, {'SC2','SC2','C2_VATU3','C2_VATU3'} )
aAdd(aDbfCria, {'SC2','SC2','C2_VATU4','C2_VATU4'} )
aAdd(aDbfCria, {'SC2','SC2','C2_VATU5','C2_VATU5'} )
aAdd(aDbfCria, {'SC2','SC2','C2_VFIM1','C2_VFIM1'} )
aAdd(aDbfCria, {'SC2','SC2','C2_VFIM2','C2_VFIM2'} )
aAdd(aDbfCria, {'SC2','SC2','C2_VFIM3','C2_VFIM3'} )
aAdd(aDbfCria, {'SC2','SC2','C2_VFIM4','C2_VFIM4'} )
aAdd(aDbfCria, {'SC2','SC2','C2_VFIM5','C2_VFIM5'} )
aAdd(aDbfCria, {'SC2','SC2','C2_APRINI1','C2_APRINI1'} )
aAdd(aDbfCria, {'SC2','SC2','C2_APRINI2','C2_APRINI2'} )
aAdd(aDbfCria, {'SC2','SC2','C2_APRINI3','C2_APRINI3'} )
aAdd(aDbfCria, {'SC2','SC2','C2_APRINI4','C2_APRINI4'} )
aAdd(aDbfCria, {'SC2','SC2','C2_APRINI5','C2_APRINI5'} )
aAdd(aDbfCria, {'SC2','SC2','C2_APRATU1','C2_APRATU1'} )
aAdd(aDbfCria, {'SC2','SC2','C2_APRATU2','C2_APRATU2'} )
aAdd(aDbfCria, {'SC2','SC2','C2_APRATU3','C2_APRATU3'} )
aAdd(aDbfCria, {'SC2','SC2','C2_APRATU4','C2_APRATU4'} )
aAdd(aDbfCria, {'SC2','SC2','C2_APRATU5','C2_APRATU5'} )
aAdd(aDbfCria, {'SC2','SC2','C2_APRFIM1','C2_APRFIM1'} )
aAdd(aDbfCria, {'SC2','SC2','C2_APRFIM2','C2_APRFIM2'} )
aAdd(aDbfCria, {'SC2','SC2','C2_APRFIM3','C2_APRFIM3'} )
aAdd(aDbfCria, {'SC2','SC2','C2_APRFIM4','C2_APRFIM4'} )
aAdd(aDbfCria, {'SC2','SC2','C2_APRFIM5','C2_APRFIM5'} )
aAdd(aDbfCria, {'SX1','SX1','X1_GRUPO','X1_GRUPO'} )
aAdd(aDbfCria, {'SX1','SX1','X1_ORDEM','X1_ORDEM'} )
aAdd(aDbfCria, {'SX1','SX1','X1_PERGUNT','X1_PERGUNT'} )
aAdd(aDbfCria, {'SX1','SX1','X1_PERSPA','X1_PERSPA'} )
aAdd(aDbfCria, {'SX1','SX1','X1_PERENG','X1_PERENG'} )
aAdd(aDbfCria, {'SX1','SX1','X1_VARIAVL','X1_VARIAVL'} )
aAdd(aDbfCria, {'SX1','SX1','X1_TIPO','X1_TIPO'} )
aAdd(aDbfCria, {'SX1','SX1','X1_TAMANHO','X1_TAMANHO'} )
aAdd(aDbfCria, {'SX1','SX1','X1_DECIMAL','X1_DECIMAL'} )
aAdd(aDbfCria, {'SX1','SX1','X1_PRESEL','X1_PRESEL'} )
aAdd(aDbfCria, {'SX1','SX1','X1_GSC','X1_GSC'} )
aAdd(aDbfCria, {'SX1','SX1','X1_VALID','X1_VALID'} )
aAdd(aDbfCria, {'SX1','SX1','X1_VAR01','X1_VAR01'} )
aAdd(aDbfCria, {'SX1','SX1','X1_DEF01','X1_DEF01'} )
aAdd(aDbfCria, {'SX1','SX1','X1_DEFSPA1','X1_DEFSPA1'} )
aAdd(aDbfCria, {'SX1','SX1','X1_DEFENG1','X1_DEFENG1'} )
aAdd(aDbfCria, {'SX1','SX1','X1_CNT01','X1_CNT01'} )
aAdd(aDbfCria, {'SX1','SX1','X1_VAR02','X1_VAR02'} )
aAdd(aDbfCria, {'SX1','SX1','X1_DEF02','X1_DEF02'} )
aAdd(aDbfCria, {'SX1','SX1','X1_DEFSPA2','X1_DEFSPA2'} )
aAdd(aDbfCria, {'SX1','SX1','X1_DEFENG2','X1_DEFENG2'} )
aAdd(aDbfCria, {'SX1','SX1','X1_CNT02','X1_CNT02'} )
aAdd(aDbfCria, {'SX1','SX1','X1_VAR03','X1_VAR03'} )
aAdd(aDbfCria, {'SX1','SX1','X1_DEF03','X1_DEF03'} )
aAdd(aDbfCria, {'SX1','SX1','X1_DEFSPA3','X1_DEFSPA3'} )
aAdd(aDbfCria, {'SX1','SX1','X1_DEFENG3','X1_DEFENG3'} )
aAdd(aDbfCria, {'SX1','SX1','X1_CNT03','X1_CNT03'} )
aAdd(aDbfCria, {'SX1','SX1','X1_VAR04','X1_VAR04'} )
aAdd(aDbfCria, {'SX1','SX1','X1_DEF04','X1_DEF04'} )
aAdd(aDbfCria, {'SX1','SX1','X1_DEFSPA4','X1_DEFSPA4'} )
aAdd(aDbfCria, {'SX1','SX1','X1_DEFENG4','X1_DEFENG4'} )
aAdd(aDbfCria, {'SX1','SX1','X1_CNT04','X1_CNT04'} )
aAdd(aDbfCria, {'SX1','SX1','X1_VAR05','X1_VAR05'} )
aAdd(aDbfCria, {'SX1','SX1','X1_DEF05','X1_DEF05'} )
aAdd(aDbfCria, {'SX1','SX1','X1_DEFSPA5','X1_DEFSPA5'} )
aAdd(aDbfCria, {'SX1','SX1','X1_DEFENG5','X1_DEFENG5'} )
aAdd(aDbfCria, {'SX1','SX1','X1_CNT05','X1_CNT05'} )
aAdd(aDbfCria, {'SX1','SX1','X1_F3','X1_F3'} )
aAdd(aDbfCria, {'SD4','SD4','D4_CODPROD','D4_COD'} )
aAdd(aDbfCria, {'SD4','SD4','D4_LOCAL','D4_LOCAL'} )
aAdd(aDbfCria, {'SD4','SD4','D4_OP','D4_OP'} )
aAdd(aDbfCria, {'SD4','SD4','D4_DATA','D4_DATA'} )
aAdd(aDbfCria, {'SD4','SD4','D4_QTDEORI','D4_QTDEORI'} )
aAdd(aDbfCria, {'SD4','SD4','D4_QUANT','D4_QUANT'} )
aAdd(aDbfCria, {'SD4','SD4','D4_TRT','D4_TRT'} )
aAdd(aDbfCria, {'SD4','SD4','D4_OPORIG','D4_OPORIG'} )
aAdd(aDbfCria, {'SFI','SFI','FI_GRTRIB','FI_GRTRIB'} )
aAdd(aDbfCria, {'SFI','SFI','FI_DESCRI','FI_DESCRI'} )
aAdd(aDbfCria, {'SAA','SAA','AA_CODOCO','AA_CODOCO'} )
aAdd(aDbfCria, {'SAA','SAA','AA_DESCOCO','AA_DESCOCO'} )
aAdd(aDbfCria, {'SAB','SAB','AB_ID','AB_ID'} )
aAdd(aDbfCria, {'SAB','SAB','AB_DATAOCO','AB_DATAOCO'} )
aAdd(aDbfCria, {'SAB','SAB','AB_TIPOCO','AB_TIPOCO'} )
aAdd(aDbfCria, {'SAB','SAB','AB_DESCOCO','AB_DESCOCO'} )
aAdd(aDbfCria, {'SAB','SAB','AB_OBSOCO','AB_OBSOCO'} )
aAdd(aDbfCria, {'SAB','SAB','AB_PATH','AB_PATH'} )
aAdd(aDbfCria, {'SEB','SEB','EB_CODIGO','EB_CODIGO'} )
aAdd(aDbfCria, {'SEB','SEB','EB_DESCRI','EB_DESCRI'} )
aAdd(aDbfCria, {'SEC','SEC','EC_CODIGO','EC_CODIGO'} )
aAdd(aDbfCria, {'SEC','SEC','EC_ITEM','EC_ITEM'} )
aAdd(aDbfCria, {'SEC','SEC','EC_DESCRI','EC_DESCRI'} )
aAdd(aDbfCria, {'SEC','SEC','EC_INICIO','EC_INICIO'} )
aAdd(aDbfCria, {'SEC','SEC','EC_FINAL','EC_FINAL'} )
aAdd(aDbfCria, {'SEE','SEE','EE_CODIGO','EE_CODIGO'} )
aAdd(aDbfCria, {'SEE','SEE','EE_CODCAT','EE_CODCAT'} )
aAdd(aDbfCria, {'SEE','SEE','EE_MOEDA','EE_MOEDA'} )
aAdd(aDbfCria, {'SEF','SEF','EF_CODIGO','EF_CODIGO'} )
aAdd(aDbfCria, {'SEF','SEF','EF_ITEM','EF_ITEM'} )
aAdd(aDbfCria, {'SEF','SEF','EF_CODCAT','EF_CODCAT'} )
aAdd(aDbfCria, {'SEF','SEF','EF_MOEDA','EF_MOEDA'} )
aAdd(aDbfCria, {'SEF','SEF','EF_VALOR','EF_VALOR'} )
aAdd(aDbfCria, {'SBX','SBX','BX_CODPROD','BX_CODPROD'} )
aAdd(aDbfCria, {'SBX','SBX','BX_DESCRI','BX_DESCRI'} )
aAdd(aDbfCria, {'SBX','SBX','BX_PRV1','BX_PRV1'} )
aAdd(aDbfCria, {'SBX','SBX','BX_PRV2','BX_PRV2'} )
aAdd(aDbfCria, {'SBX','SBX','BX_PRV3','BX_PRV3'} )
aAdd(aDbfCria, {'SBX','SBX','BX_CUSREP','BX_CUSREP'} )
aAdd(aDbfCria, {'SBX','SBX','BX_BASEPRC','BX_BASEPRC'} )
aAdd(aDbfCria, {'SBX','SBX','BX_ATUSB1','BX_ATUSB1'} )
aAdd(aDbfCria, {'SBZ','SBZ','BZ_CODPROD','BZ_CODPROD'} )
aAdd(aDbfCria, {'SBZ','SBZ','BZ_TPFORM','BZ_TPFORM'} )
aAdd(aDbfCria, {'SBZ','SBZ','BZ_DESCRI','BZ_DESCRI'} )
aAdd(aDbfCria, {'SBZ','SBZ','BZ_VALOR','BZ_VALOR'} )
aAdd(aDbfCria, {'SBZ','SBZ','BZ_INDIC','BZ_INDIC'} )
aAdd(aDbfCria, {'SBZ','SBZ','BZ_OPER','BZ_OPER'} )
aAdd(aDbfCria, {'SBZ','SBZ','BZ_TABELA','BZ_TABELA'} )
aAdd(aDbfCria, {'SA1','SA2','A1_PESSOA','A2_COD'} )
aAdd(aDbfCria, {'SA1','SA2','A1_NOME','A2_NOME'} )
aAdd(aDbfCria, {'SA1','SA2','A1_IDENT',''} )
aAdd(aDbfCria, {'SA1','SA2','A1_CGC','A2_CGC'} )
aAdd(aDbfCria, {'SA1','SA2','A1_TIPO','A2_TIPO'} )
aAdd(aDbfCria, {'SA1','SA2','A1_INSCR','A2_INSCR'} )
aAdd(aDbfCria, {'SA1','SA2','A1_END','A2_END'} )
aAdd(aDbfCria, {'SA1','SA2','A1_CEP','A2_CEP'} )
aAdd(aDbfCria, {'SA1','SA2','A1_BAIRRO','A2_BAIRRO'} )
aAdd(aDbfCria, {'SA1','SA2','A1_MUN','A2_MUN'} )
aAdd(aDbfCria, {'SA1','SA2','A1_EST','A2_EST'} )
aAdd(aDbfCria, {'SA1','SA2','A1_COMISS',''} )
aAdd(aDbfCria, {'SA1','SA2','A1_COMEMIS',''} )
aAdd(aDbfCria, {'SA1','SA2','A1_COMBX',''} )
aAdd(aDbfCria, {'SA1','SA2','A1_FONE','A2_TEL'} )
aAdd(aDbfCria, {'SA1','SA2','A1_EMAIL','A2_EMAIL'} )
aAdd(aDbfCria, {'SA1','SA2','A1_HPAGE','A2_HPAGE'} )
aAdd(aDbfCria, {'SA1','SA2','A1_FTP',''} )
aAdd(aDbfCria, {'SA1','SA2','A1_TABELA',''} )
aAdd(aDbfCria, {'SA1','SA3','A1_PESSOA','A3_COD'} )
aAdd(aDbfCria, {'SA1','SA3','A1_NOME','A3_NOME'} )
aAdd(aDbfCria, {'SA1','SA3','A1_IDENT',''} )
aAdd(aDbfCria, {'SA1','SA3','A1_CGC','A3_CGC'} )
aAdd(aDbfCria, {'SA1','SA3','A1_TIPO','A3_TIPO'} )
aAdd(aDbfCria, {'SA1','SA3','A1_INSCR','A3_INSCR'} )
aAdd(aDbfCria, {'SA1','SA3','A1_END','A3_END'} )
aAdd(aDbfCria, {'SA1','SA3','A1_CEP','A3_CEP'} )
aAdd(aDbfCria, {'SA1','SA3','A1_BAIRRO','A3_BAIRRO'} )
aAdd(aDbfCria, {'SA1','SA3','A1_MUN','A3_MUN'} )
aAdd(aDbfCria, {'SA1','SA3','A1_EST','A3_EST'} )
aAdd(aDbfCria, {'SA1','SA3','A1_COMISS','A3_COMIS'} )
aAdd(aDbfCria, {'SA1','SA3','A1_COMEMIS','A3_ALEMISS'} )
aAdd(aDbfCria, {'SA1','SA3','A1_COMBX','A3_ALBAIXA'} )
aAdd(aDbfCria, {'SA1','SA3','A1_FONE','A3_TEL'} )
aAdd(aDbfCria, {'SA1','SA3','A1_EMAIL','A3_EMAIL'} )
aAdd(aDbfCria, {'SA1','SA3','A1_HPAGE','A3_HPAGE'} )
aAdd(aDbfCria, {'SA1','SA3','A1_FTP',''} )
aAdd(aDbfCria, {'SA1','SA3','A1_TABELA',''} )
aAdd(aDbfCria, {'SAH','SAH','AH_DESCRI','AH_UMRES'} )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTCombo()  บAutor  ณPaulo Carnelossi    บ Data ณ  15/05/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria arquivo dos campos  a ser importada a partir do array  บฑฑ
ฑฑบ          ณcom a correlacao entre combos dos campos small e Master     บฑฑ
ฑฑบ          ณfonte gerado a partir do DBF pela funcao Cr_Tab_Dados()     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Migra()                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tcombo()

Local aDbfCria,aStruDbf
Local cArqCpos, x, nCtd

aDbfCria := {}

aAdd(aDbfCria, {'SA1','A1_IDENT','1',''} )
aAdd(aDbfCria, {'SA1','A1_IDENT','2',''} )
aAdd(aDbfCria, {'SA1','A1_IDENT','3',''} )
aAdd(aDbfCria, {'SA1','A1_TIPO',' ','R'} )
aAdd(aDbfCria, {'SA1','A1_TIPO','1','F'} )
aAdd(aDbfCria, {'SA1','A1_TIPO','2','L'} )
aAdd(aDbfCria, {'SA1','A1_TIPO','3','R'} )
aAdd(aDbfCria, {'SA1','A1_TIPO','4','S'} )
aAdd(aDbfCria, {'SA1','A1_TIPO','5','X'} )
aAdd(aDbfCria, {'SA1','A1_TIPO','6','X'} )
aAdd(aDbfCria, {'SA1','A1_TIPO','7','I'} )
aAdd(aDbfCria, {'SA1','A1_TABELA','1',''} )
aAdd(aDbfCria, {'SA1','A1_TABELA','2',''} )
aAdd(aDbfCria, {'SA1','A1_TABELA','3',''} )
aAdd(aDbfCria, {'SA6','A6_FLUXO','1','S'} )
aAdd(aDbfCria, {'SA6','A6_FLUXO','2','N'} )
aAdd(aDbfCria, {'SA6','A6_MOEDA','1',''} )
aAdd(aDbfCria, {'SA6','A6_MOEDA','2',''} )
aAdd(aDbfCria, {'SA6','A6_MOEDA','3',''} )
aAdd(aDbfCria, {'SA6','A6_MOEDA','4',''} )
aAdd(aDbfCria, {'SA6','A6_MOEDA','5',''} )
aAdd(aDbfCria, {'SED','ED_TPCART','1',''} )
aAdd(aDbfCria, {'SED','ED_TPCART','2',''} )
aAdd(aDbfCria, {'SA2','A2_TIPO','1',''} )
aAdd(aDbfCria, {'SA2','A2_TIPO','2',''} )
aAdd(aDbfCria, {'SE1','E1_TIPO','1','NF'} )
aAdd(aDbfCria, {'SE1','E1_TIPO','2','NF'} )
aAdd(aDbfCria, {'SE1','E1_TIPO','3','DP'} )
aAdd(aDbfCria, {'SE1','E1_TIPO','4','CN'} )
aAdd(aDbfCria, {'SE1','E1_TIPO','5','FT'} )
aAdd(aDbfCria, {'SE1','E1_TIPO','6','NP'} )
aAdd(aDbfCria, {'SE1','E1_TIPO','7','CH'} )
aAdd(aDbfCria, {'SE1','E1_TIPO','8','DP'} )
aAdd(aDbfCria, {'SE1','E1_TIPO','9','RC'} )
aAdd(aDbfCria, {'SE1','E1_MOEDA','1',''} )
aAdd(aDbfCria, {'SE1','E1_MOEDA','2',''} )
aAdd(aDbfCria, {'SE1','E1_MOEDA','3',''} )
aAdd(aDbfCria, {'SE1','E1_MOEDA','4',''} )
aAdd(aDbfCria, {'SE1','E1_MOEDA','5',''} )
aAdd(aDbfCria, {'SE2','E2_TIPO','1','NF'} )
aAdd(aDbfCria, {'SE2','E2_TIPO','2','NF'} )
aAdd(aDbfCria, {'SE2','E2_TIPO','3','DP'} )
aAdd(aDbfCria, {'SE2','E2_TIPO','4','CN'} )
aAdd(aDbfCria, {'SE2','E2_TIPO','5','FT'} )
aAdd(aDbfCria, {'SE2','E2_TIPO','6','NP'} )
aAdd(aDbfCria, {'SE2','E2_TIPO','7','CH'} )
aAdd(aDbfCria, {'SE2','E2_TIPO','8','DP'} )
aAdd(aDbfCria, {'SE2','E2_TIPO','9','RC'} )
aAdd(aDbfCria, {'SE2','E2_MOEDA','1',''} )
aAdd(aDbfCria, {'SE2','E2_MOEDA','2',''} )
aAdd(aDbfCria, {'SE2','E2_MOEDA','3',''} )
aAdd(aDbfCria, {'SE2','E2_MOEDA','4',''} )
aAdd(aDbfCria, {'SE2','E2_MOEDA','5',''} )
aAdd(aDbfCria, {'SEP','EP_TPCART','1',''} )
aAdd(aDbfCria, {'SEP','EP_TPCART','2',''} )
aAdd(aDbfCria, {'SEP','EP_FREQUEN','1',''} )
aAdd(aDbfCria, {'SEP','EP_FREQUEN','2',''} )
aAdd(aDbfCria, {'SEP','EP_FREQUEN','3',''} )
aAdd(aDbfCria, {'SEP','EP_FREQUEN','4',''} )
aAdd(aDbfCria, {'SEP','EP_INCLUI','1',''} )
aAdd(aDbfCria, {'SEP','EP_INCLUI','2',''} )
aAdd(aDbfCria, {'SEP','EP_MOEDA','1',''} )
aAdd(aDbfCria, {'SEP','EP_MOEDA','2',''} )
aAdd(aDbfCria, {'SEP','EP_MOEDA','3',''} )
aAdd(aDbfCria, {'SEP','EP_MOEDA','4',''} )
aAdd(aDbfCria, {'SEP','EP_MOEDA','5',''} )
aAdd(aDbfCria, {'SEP','EP_TIPO','1',''} )
aAdd(aDbfCria, {'SEP','EP_TIPO','2',''} )
aAdd(aDbfCria, {'SEP','EP_TIPO','3',''} )
aAdd(aDbfCria, {'SEP','EP_TIPO','4',''} )
aAdd(aDbfCria, {'SEP','EP_TIPO','5',''} )
aAdd(aDbfCria, {'SEP','EP_TIPO','6',''} )
aAdd(aDbfCria, {'SEP','EP_TIPO','7',''} )
aAdd(aDbfCria, {'SEP','EP_TIPO','8',''} )
aAdd(aDbfCria, {'SEP','EP_TIPO','9',''} )
aAdd(aDbfCria, {'SE5','E5_TIPO','1','NF'} )
aAdd(aDbfCria, {'SE5','E5_TIPO','2','NF'} )
aAdd(aDbfCria, {'SE5','E5_TIPO','3','DP'} )
aAdd(aDbfCria, {'SE5','E5_TIPO','4','CN'} )
aAdd(aDbfCria, {'SE5','E5_TIPO','5','FT'} )
aAdd(aDbfCria, {'SE5','E5_TIPO','6','NP'} )
aAdd(aDbfCria, {'SE5','E5_TIPO','7','CH'} )
aAdd(aDbfCria, {'SE5','E5_TIPO','8','DP'} )
aAdd(aDbfCria, {'SE5','E5_TIPO','9','RC'} )
aAdd(aDbfCria, {'SE5','E5_TPMOV','1','CH'} )
aAdd(aDbfCria, {'SE5','E5_TPMOV','2','DOC'} )
aAdd(aDbfCria, {'SE5','E5_TPMOV','3','R$'} )
aAdd(aDbfCria, {'SE5','E5_TPMOV','4','TB'} )
aAdd(aDbfCria, {'SE5','E5_MOVBCO','1',''} )
aAdd(aDbfCria, {'SE5','E5_MOVBCO','2',''} )
aAdd(aDbfCria, {'SE9','E9_MOEDA','1',''} )
aAdd(aDbfCria, {'SE9','E9_MOEDA','2',''} )
aAdd(aDbfCria, {'SE9','E9_MOEDA','3',''} )
aAdd(aDbfCria, {'SE9','E9_MOEDA','4',''} )
aAdd(aDbfCria, {'SE9','E9_MOEDA','5',''} )
aAdd(aDbfCria, {'SB1','B1_TIPO','1','MC'} )
aAdd(aDbfCria, {'SB1','B1_TIPO','2','MP'} )
aAdd(aDbfCria, {'SB1','B1_TIPO','3','PA'} )
aAdd(aDbfCria, {'SB1','B1_TIPO','4','PI'} )
aAdd(aDbfCria, {'SB1','B1_TIPO','5','PA'} )
aAdd(aDbfCria, {'SB1','B1_TIPE','1','H'} )
aAdd(aDbfCria, {'SB1','B1_TIPE','2','D'} )
aAdd(aDbfCria, {'SB1','B1_TIPE','3','S'} )
aAdd(aDbfCria, {'SB1','B1_TIPE','4','M'} )
aAdd(aDbfCria, {'SB1','B1_TIPE','5','A'} )
aAdd(aDbfCria, {'SB1','B1_TIPODEC','1','N'} )
aAdd(aDbfCria, {'SB1','B1_TIPODEC','2','A'} )
aAdd(aDbfCria, {'SB1','B1_MCUSTD','1',''} )
aAdd(aDbfCria, {'SB1','B1_MCUSTD','2',''} )
aAdd(aDbfCria, {'SB1','B1_MCUSTD','3',''} )
aAdd(aDbfCria, {'SB1','B1_MCUSTD','4',''} )
aAdd(aDbfCria, {'SB1','B1_MCUSTD','5',''} )
aAdd(aDbfCria, {'SB1','B1_FORAEST','1','S'} )
aAdd(aDbfCria, {'SB1','B1_FORAEST','2','N'} )
aAdd(aDbfCria, {'SE6','E6_DDD','1','D'} )
aAdd(aDbfCria, {'SE6','E6_DDD','2','L'} )
aAdd(aDbfCria, {'SE6','E6_DDD','3','S'} )
aAdd(aDbfCria, {'SE6','E6_DDD','4','Q'} )
aAdd(aDbfCria, {'SE6','E6_DDD','5','F'} )
aAdd(aDbfCria, {'SE6','E6_DDD','6','Z'} )
aAdd(aDbfCria, {'SF1','F1_TIPO','1','N'} )
aAdd(aDbfCria, {'SF1','F1_TIPO','2','D'} )
aAdd(aDbfCria, {'SF1','F1_TIPO','3','C'} )
aAdd(aDbfCria, {'SF1','F1_TIPO','4',''} )
aAdd(aDbfCria, {'SF1','F1_TIPO','5',''} )
aAdd(aDbfCria, {'SF1','F1_FORMUL','1','S'} )
aAdd(aDbfCria, {'SF1','F1_FORMUL','2','N'} )
aAdd(aDbfCria, {'SD1','D1_TIPO','1','N'} )
aAdd(aDbfCria, {'SD1','D1_TIPO','2','D'} )
aAdd(aDbfCria, {'SD1','D1_TIPO','3','C'} )
aAdd(aDbfCria, {'SF4','F4_TIPO','1','E'} )
aAdd(aDbfCria, {'SF4','F4_TIPO','2','S'} )
aAdd(aDbfCria, {'SF4','F4_DUPLIC','1','S'} )
aAdd(aDbfCria, {'SF4','F4_DUPLIC','2','N'} )
aAdd(aDbfCria, {'SF4','F4_ESTOQUE','1','S'} )
aAdd(aDbfCria, {'SF4','F4_ESTOQUE','2','N'} )
aAdd(aDbfCria, {'SF4','F4_ICM','1','S'} )
aAdd(aDbfCria, {'SF4','F4_ICM','2','N'} )
aAdd(aDbfCria, {'SF4','F4_IPI','1','S'} )
aAdd(aDbfCria, {'SF4','F4_IPI','2','N'} )
aAdd(aDbfCria, {'SF4','F4_IPI','3','R'} )
aAdd(aDbfCria, {'SF4','F4_INCIDE','1','S'} )
aAdd(aDbfCria, {'SF4','F4_INCIDE','2','N'} )
aAdd(aDbfCria, {'SF4','F4_COMPL','1','S'} )
aAdd(aDbfCria, {'SF4','F4_COMPL','2','N'} )
aAdd(aDbfCria, {'SF4','F4_IPIFRET','1','S'} )
aAdd(aDbfCria, {'SF4','F4_IPIFRET','2','N'} )
aAdd(aDbfCria, {'SF4','F4_ISS','1','S'} )
aAdd(aDbfCria, {'SF4','F4_ISS','2','N'} )
aAdd(aDbfCria, {'SF4','F4_INCSOL','1','S'} )
aAdd(aDbfCria, {'SF4','F4_INCSOL','2','N'} )
aAdd(aDbfCria, {'SF4','F4_DESPIPI','1','S'} )
aAdd(aDbfCria, {'SF4','F4_DESPIPI','2','N'} )
aAdd(aDbfCria, {'SF4','F4_CREDICM','1','S'} )
aAdd(aDbfCria, {'SF4','F4_CREDICM','2','N'} )
aAdd(aDbfCria, {'SF4','F4_CREDIPI','1','S'} )
aAdd(aDbfCria, {'SF4','F4_CREDIPI','2','N'} )
aAdd(aDbfCria, {'SFC','FC_INCDUPL','1',''} )
aAdd(aDbfCria, {'SFC','FC_INCDUPL','2',''} )
aAdd(aDbfCria, {'SFC','FC_INCDUPL','3',''} )
aAdd(aDbfCria, {'SFC','FC_INCNOTA','1',''} )
aAdd(aDbfCria, {'SFC','FC_INCNOTA','2',''} )
aAdd(aDbfCria, {'SFC','FC_INCNOTA','3',''} )
aAdd(aDbfCria, {'SFC','FC_CREDITA','1',''} )
aAdd(aDbfCria, {'SFC','FC_CREDITA','2',''} )
aAdd(aDbfCria, {'SFC','FC_CREDITA','3',''} )
aAdd(aDbfCria, {'SFC','FC_CALCULO','1',''} )
aAdd(aDbfCria, {'SFC','FC_CALCULO','2',''} )
aAdd(aDbfCria, {'SFC','FC_LIQUIDO','1',''} )
aAdd(aDbfCria, {'SFC','FC_LIQUIDO','2',''} )
aAdd(aDbfCria, {'SD3','D3_PARCTOT','1','P'} )
aAdd(aDbfCria, {'SD3','D3_PARCTOT','2','T'} )
aAdd(aDbfCria, {'SD3','D3_VALOR','1',''} )
aAdd(aDbfCria, {'SD3','D3_VALOR','2',''} )
aAdd(aDbfCria, {'SF5','F5_TIPO','1','P'} )
aAdd(aDbfCria, {'SF5','F5_TIPO','2','R'} )
aAdd(aDbfCria, {'SF5','F5_TIPO','3','D'} )
aAdd(aDbfCria, {'SF5','F5_ATUEMP','1','S'} )
aAdd(aDbfCria, {'SF5','F5_ATUEMP','2','N'} )
aAdd(aDbfCria, {'SD2','D2_TIPO','1','N'} )
aAdd(aDbfCria, {'SD2','D2_TIPO','2','D'} )
aAdd(aDbfCria, {'SD2','D2_TIPO','3','C'} )
aAdd(aDbfCria, {'SD2','D2_TIPO','4',''} )
aAdd(aDbfCria, {'SD2','D2_TIPO','5',''} )
aAdd(aDbfCria, {'SC5','C5_TIPO','1','N'} )
aAdd(aDbfCria, {'SC5','C5_TIPO','2','D'} )
aAdd(aDbfCria, {'SC5','C5_TIPO','3','C'} )
aAdd(aDbfCria, {'SC5','C5_TIPOCLI',' ','R'} )
aAdd(aDbfCria, {'SC5','C5_TIPOCLI','1','F'} )
aAdd(aDbfCria, {'SC5','C5_TIPOCLI','2','L'} )
aAdd(aDbfCria, {'SC5','C5_TIPOCLI','3','R'} )
aAdd(aDbfCria, {'SC5','C5_TIPOCLI','4','S'} )
aAdd(aDbfCria, {'SC5','C5_TIPOCLI','5','X'} )
aAdd(aDbfCria, {'SC5','C5_TIPOCLI','6','X'} )
aAdd(aDbfCria, {'SC5','C5_REVENC','1',''} )
aAdd(aDbfCria, {'SC5','C5_REVENC','2',''} )
aAdd(aDbfCria, {'SC5','C5_STATUS','1',''} )
aAdd(aDbfCria, {'SC5','C5_STATUS','2',''} )
aAdd(aDbfCria, {'SC5','C5_STATUS','3',''} )
aAdd(aDbfCria, {'SC5','C5_STATUS','4',''} )
aAdd(aDbfCria, {'SC5','C5_TABELA','1',''} )
aAdd(aDbfCria, {'SC5','C5_TABELA','2',''} )
aAdd(aDbfCria, {'SC5','C5_TABELA','3',''} )
aAdd(aDbfCria, {'SEA','EA_MOEDA','1',''} )
aAdd(aDbfCria, {'SEA','EA_MOEDA','2',''} )
aAdd(aDbfCria, {'SEA','EA_MOEDA','3',''} )
aAdd(aDbfCria, {'SEA','EA_MOEDA','4',''} )
aAdd(aDbfCria, {'SEA','EA_MOEDA','5',''} )
aAdd(aDbfCria, {'SEK','EK_TIPODOC','1',''} )
aAdd(aDbfCria, {'SEK','EK_TIPODOC','2',''} )
aAdd(aDbfCria, {'SEK','EK_TIPO','1',''} )
aAdd(aDbfCria, {'SEK','EK_TIPO','2',''} )
aAdd(aDbfCria, {'SEK','EK_TIPO','3',''} )
aAdd(aDbfCria, {'SEK','EK_TIPO','4',''} )
aAdd(aDbfCria, {'SEK','EK_TIPO','5',''} )
aAdd(aDbfCria, {'SEK','EK_TIPO','6',''} )
aAdd(aDbfCria, {'SEL','EL_TIPO','1',''} )
aAdd(aDbfCria, {'SEL','EL_TIPO','2',''} )
aAdd(aDbfCria, {'SEL','EL_TIPO','3',''} )
aAdd(aDbfCria, {'SEL','EL_TIPO','4',''} )
aAdd(aDbfCria, {'SEL','EL_TIPO','5',''} )
aAdd(aDbfCria, {'SEL','EL_TIPO','6',''} )
aAdd(aDbfCria, {'SEL','EL_TIPO','7',''} )
aAdd(aDbfCria, {'SEL','EL_TIPO','8',''} )
aAdd(aDbfCria, {'SEL','EL_TIPO','9',''} )
aAdd(aDbfCria, {'SEL','EL_TIPODOC','1',''} )
aAdd(aDbfCria, {'SEL','EL_TIPODOC','2',''} )
aAdd(aDbfCria, {'SEL','EL_TIPODOC','3',''} )
aAdd(aDbfCria, {'SEL','EL_TIPODOC','4',''} )
aAdd(aDbfCria, {'SEL','EL_TIPODOC','5',''} )
aAdd(aDbfCria, {'SEL','EL_TIPODOC','6',''} )
aAdd(aDbfCria, {'SEL','EL_TIPODOC','7',''} )
aAdd(aDbfCria, {'SEL','EL_TIPODOC','8',''} )
aAdd(aDbfCria, {'SEL','EL_TIPODOC','9',''} )
aAdd(aDbfCria, {'SEL','EL_TPCRED','1',''} )
aAdd(aDbfCria, {'SEL','EL_TPCRED','2',''} )
aAdd(aDbfCria, {'SEL','EL_TPCRED','3',''} )
aAdd(aDbfCria, {'SFG','FG_TIPO','1',''} )
aAdd(aDbfCria, {'SFG','FG_TIPO','2',''} )
aAdd(aDbfCria, {'SFH','FH_AGENTE','1',''} )
aAdd(aDbfCria, {'SFH','FH_AGENTE','2',''} )
aAdd(aDbfCria, {'SFH','FH_PERCIBI','1',''} )
aAdd(aDbfCria, {'SFH','FH_PERCIBI','2',''} )
aAdd(aDbfCria, {'SFH','FH_ISENTO','1',''} )
aAdd(aDbfCria, {'SFH','FH_ISENTO','2',''} )
aAdd(aDbfCria, {'SFH','FH_APERIB','1',''} )
aAdd(aDbfCria, {'SFH','FH_APERIB','2',''} )
aAdd(aDbfCria, {'SF2','F2_TIPO','1','F'} )
aAdd(aDbfCria, {'SF2','F2_TIPO','2','L'} )
aAdd(aDbfCria, {'SF2','F2_TIPO','3','R'} )
aAdd(aDbfCria, {'SF2','F2_TIPO','4','S'} )
aAdd(aDbfCria, {'SF2','F2_TIPO','5','X'} )
aAdd(aDbfCria, {'SF2','F2_TABELA','1',''} )
aAdd(aDbfCria, {'SF2','F2_TABELA','2',''} )
aAdd(aDbfCria, {'SF2','F2_TABELA','3',''} )
aAdd(aDbfCria, {'SG1','G1_FIXVAR','1','V'} )
aAdd(aDbfCria, {'SG1','G1_FIXVAR','2','F'} )
aAdd(aDbfCria, {'SX6','X6_TIPO','C',''} )
aAdd(aDbfCria, {'SX6','X6_TIPO','N',''} )
aAdd(aDbfCria, {'SX6','X6_TIPO','L',''} )
aAdd(aDbfCria, {'SX6','X6_TIPO','D',''} )
aAdd(aDbfCria, {'SF7','F7_TIPOCLI','1',''} )
aAdd(aDbfCria, {'SF7','F7_TIPOCLI','2',''} )
aAdd(aDbfCria, {'SF7','F7_TIPOCLI','3',''} )
aAdd(aDbfCria, {'SEE','EE_MOEDA','1',''} )
aAdd(aDbfCria, {'SEE','EE_MOEDA','2',''} )
aAdd(aDbfCria, {'SEE','EE_MOEDA','3',''} )
aAdd(aDbfCria, {'SEE','EE_MOEDA','4',''} )
aAdd(aDbfCria, {'SEE','EE_MOEDA','5',''} )
aAdd(aDbfCria, {'SEF','EF_MOEDA','1',''} )
aAdd(aDbfCria, {'SEF','EF_MOEDA','2',''} )
aAdd(aDbfCria, {'SEF','EF_MOEDA','3',''} )
aAdd(aDbfCria, {'SEF','EF_MOEDA','4',''} )
aAdd(aDbfCria, {'SEF','EF_MOEDA','5',''} )
aAdd(aDbfCria, {'SBX','BX_BASEPRC','1',''} )
aAdd(aDbfCria, {'SBX','BX_BASEPRC','2',''} )
aAdd(aDbfCria, {'SBZ','BZ_INDIC','%',''} )
aAdd(aDbfCria, {'SBZ','BZ_INDIC','$',''} )
aAdd(aDbfCria, {'SBZ','BZ_OPER','*',''} )
aAdd(aDbfCria, {'SBZ','BZ_OPER','/',''} )
aAdd(aDbfCria, {'SBZ','BZ_OPER','+',''} )
aAdd(aDbfCria, {'SBZ','BZ_OPER','-',''} )
aAdd(aDbfCria, {'SBZ','BZ_TABELA','1',''} )
aAdd(aDbfCria, {'SBZ','BZ_TABELA','2',''} )
aAdd(aDbfCria, {'SBZ','BZ_TABELA','3',''} )

aStruDbf := {}
aAdd(aStruDbf,{ 'ALIAS', 'C', 3, 0})
aAdd(aStruDbf,{ 'NOMECPO', 'C', 10, 0})
aAdd(aStruDbf,{ 'CONTSMALL', 'C', 1, 0})
aAdd(aStruDbf,{ 'CONTMASTER', 'C', 10, 0})

cArqCpos := CriaTrab(aStruDbf)
DbUseArea(.T.,,cArqCpos,'TCB',.F.,.F.)
IndRegua("TCB",cArqCpos,"ALIAS+NOMECPO+CONTSMALL",,,STR0013)//"Criando Indํce Temporแrio"

For x := 1 TO Len(aDbfCria)
   RecLock("TCB",.T.)
      For nCtd := 1 TO Len(aStruDbf)
         FieldPut(nCtd, aDbfCria[x][nCtd])
     Next
   MsUnLock()
Next

Return(cArqCpos)

//---------------------------------------------------------------------------------//
// as funcoes abaixo somente foram utilizadas como auxiliar na geracao das tabelas //
// gravadas acima e base para o trabalho de levantamento dos dados a ser migrado p///
// a versao MASTER.  (Paulo Carnelossi)                                            //
//---------------------------------------------------------------------------------//

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAuxMigraMaster บAutorณPaulo Carnelossi บ Data ณ  15/05/03   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPrograma para auxiliar na migracao - levantamento dos camposบฑฑ
ฑฑบ          ณa serem importados para versao master a partir do small     บฑฑ
ฑฑบ          ณgerando arquivo DBF a partir do SMALLDIC.INI (DIC. SMALL)   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAuxMigraMaster("SMALLDIC.INI")                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AuxMigraMaster(cArqDic)

Local aTabelas
Local cTabela, cPais
Local nPosTab, cLinAux, nPosPais
Local aStruA := {}, cArqAlias
Local aStruB := {}, cArqCpos
Local nCtd, cChave, lContinua := .T.
Local nPosIgual, nPosCerca, cField
Local nY 	:=0

aAdd(aStruA,{"ALIAS","C",3,0})
aAdd(aStruA,{"PAISLOC","C",100,0})

aAdd(aStruB,{"ALIAS","C",3,0})
aAdd(aStruB,{"PAISLOC","C",100,0})
aAdd(aStruB,{"NOMECPO","C",10,0})
aAdd(aStruB,{"TIPOCPO","C",1,0})
aAdd(aStruB,{"TAMCPO","N",3,0})
aAdd(aStruB,{"DECCPO","N",3,0})
aAdd(aStruB,{"COMBCPO","C",100,0})

cArqCpos := CriaTrab(aStruB)
DbUseArea(.T.,,cArqCpos,"TRC",.F.,.F.)

cArqAlias := CriaTrab(aStruA)
DbUseArea(.T.,,cArqAlias,"TRA",.F.,.F.)

If Empty(cArqDic)
	HELP(2,"ARQINV","Arquivo Invalido.","Escolha o Arquivo Correto.")
	
ElseIf FT_FUSE(cArqDic) == -1
	HELP(2,"ABRARQ","Falha na abertura do arquivo.", "Verifique se o mesmo nใo estแ em uso.")
	
Else
	
	// carregar as tabelas
	aTabelas := {}
	FT_FGOTOP()
	
	While ! FT_FEOF()
		
		cLinha := FT_FREADLN()
		
		If "TABLE" $ Alltrim(cLinha) .And. Alltrim(cLinha) != "[TABLES]"
			
			While "TABLE" $ Alltrim(cLinha) .And. ! FT_FEOF()
				
				nPosTab := At("#", cLinha)-3
				
				cTabela := Subs(cLinha, nPosTab,3)
				
				cLinAux := Subs(cLinha, nPosTab+3+1)
				
				nPosPais := At("#", cLinAux)
				
				cPais := ""
				If nPosPais > 0
					cPais := Subs(cLinAux, nPosPais+1)
				EndIf
				
				aAdd(aTabelas, { cTabela, cPais } )
				
				FT_FSKIP()
				
				cLinha  := FT_FREADLN()
				
			End
			
			DbSelectArea("TRA")
			For nY := 1 TO Len(aTabelas)
				RecLock("TRA", .T.)
				TRA->ALIAS   := aTabelas[nY][1]
				TRA->PAISLOC := aTabelas[nY][2]
				MsUnLock()
			Next
			// apos carregar todas as tabelas no arquivo sai do laco
			EXIT
			
		EndIf
		
		FT_FSKIP()
		
	End
	
	// carregar os campos no arquivo
	DbSelectArea("TRA")
	dbGotop()
	
	While TRA->(! EOF())
		
		cChave := "["+Alltrim(TRA->ALIAS)+"]"
		lContinua := .T.
		
		FT_FGOTOP()
		
		While ! FT_FEOF()
			
			cLinha := FT_FREADLN()
			
			If cChave $ Alltrim(cLinha)
				
				nCtd := 1
				cField    := "FIELD"+Str(nCtd,If( nCtd < 10, 1, If( nCtd < 100, 2, 3) ) )
				
				While .T.
					
					nPosIgual := AT("=",cLinha)
					nPosCerca := AT("#",cLinha)
					
					// quando mudar o campo - grava e define novo campo
					If "FIELD" $ Alltrim(cLinha) .And. nPosIgual > 0 .And. ;
						nPosCerca == 0 .And. Alltrim(Subs(cLinha,1,nPosIgual-1)) != cField
						GravaCpo(TRA->ALIAS, cPaisLoc, cNomeCpo, cTipoCpo, nTamCpo, nDecCpo, cComboBox)
						nCtd++
						cField    := "FIELD"+Str(nCtd,If( nCtd < 10, 1, If( nCtd < 100, 2, 3) ) )
					EndIf
					
					// novo campo
					If "FIELD" $ Alltrim(cLinha) .And. nPosIgual > 0 .And. ;
						nPosCerca == 0 .And. Alltrim(Subs(cLinha,1,nPosIgual-1)) == cField
						cNomeCpo := Alltrim(Subs(cLinha, nPosIgual+1))
						cPaisLoc := ""
						cTipoCpo := ""
						nTamCpo  := 0
						nDecCpo  := 0
						cComboBox:= ""
					Else
						If 		"VLD_TYPE" $ Alltrim(cLinha)
							cTipoCpo := Alltrim(Subs(cLinha, nPosCerca+1))
							
						ElseIf 	"VLD_SIZE" $ Alltrim(cLinha)
							nTamCpo  := Val(Alltrim(Subs(cLinha, nPosCerca+1)))
							
						ElseIf 	"VLD_DECIMAL" $ Alltrim(cLinha)
							nDecCpo  := Val(Alltrim(Subs(cLinha, nPosCerca+1)))
							
						ElseIf 	"PAISLOC" $ Alltrim(cLinha)
							cPaisLoc := Alltrim(Subs(cLinha, nPosIgual+1))
							
						ElseIf 	"VLD_COMBOBOX" $ Alltrim(cLinha)
							cComboBox:= Alltrim(Subs(cLinha, nPosCerca+1))
							
						EndIf
						
						
					EndIf
					
					FT_FSKIP()
					
					cLinha  := FT_FREADLN()
					
					If At("[", cLinha) > 0 .And. At("]", cLinha) > 0
						//Grava o ultimo campo da tabela
						GravaCpo(TRA->ALIAS, cPaisLoc, cNomeCpo, cTipoCpo, nTamCpo, nDecCpo, cComboBox)
						lContinua := .F.
						EXIT
					EndIf
					
				End
				
			EndIf
			
			If ! lContinua
				EXIT
			EndIf
			
			FT_FSKIP()
			
		End
		
		DbSelectArea("TRA")
		dbSkip()
		
	End  // TRA->(! EOF())
	
	
	FT_FUSE()
	
EndIf
/*
dbSelectArea("")
dbCloseArea()
FRename(cArqCombo+GetDbExtension(), "arq.dbf")
*/
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGravaCpo  บAutor  ณPaulo Carnelossi    บ Data ณ  15/05/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณgrava campos do arquivo gerado partir do smalldic.ini       บฑฑ
ฑฑบ          ณarquivo somente para levantamento dos campos a importar     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AuxMigraMaster()                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GravaCpo(cAlias, cPaisLoc, cNomeCpo, cTipoCpo, nTamCpo, nDecCpo, cComboBox)

DbSelectArea("TRC")
RecLock("TRC", .T.)
TRC->ALIAS   := cAlias
TRC->PAISLOC := cPaisLoc
TRC->NOMECPO := cNomeCpo
TRC->TIPOCPO := cTipoCpo
TRC->TAMCPO  := nTamCpo
TRC->DECCPO  := nDecCpo
TRC->COMBCPO  := cComboBox
MsUnLock()

Return

//-------------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณComboBox  บAutor  ณPaulo Carnelossi    บ Data ณ  05/16/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ popula arquivo tcombo.dbf para servir de base para         บฑฑ
ฑฑบ          ณ compatibilizar os valores dos combos da versao small       บฑฑ
ฑฑบ          ณ com a Master                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ComboBox()

Local aStru := {}
Local cArqCombo
Local cContSmall

aAdd(aStru,{"ALIAS","C",3,0})
aAdd(aStru,{"NOMECPO","C",10,0})
aAdd(aStru,{"CONTSMALL","C",10,0})
aAdd(aStru,{"CONTMASTER","C",10,0})

cArqCombo := CriaTrab(aStru)
DbUseArea(.T.,,cArqCombo,"TRZ",.F.,.F.)

DbUseArea(.T.,__LocalDriver,"TCAMPOS.DBF","TRW",.T.,.F.)

bSelectArea("TRW")
dbGoTop()

While TRW->(! EOF())
	If ! Empty(COMBCPO) .And. TRW->MIGRA = "S"
		
		cComboBox := TRW->COMBCPO
		nPosIgual := AT("=",cComboBox)
		nPosPonto := AT(";",cComboBox)
		
		While nPosIgual > 0
			cContSmall := Subs(cComboBox, 1, nPosIgual-1)
			
			dbSelectArea("TRZ")
			RecLock("TRZ",.T.)
			TRZ->ALIAS			:= TRW->ALIAS
			TRZ->NOMECPO		:= TRW->NOMECPO
			TRZ->CONTSMALL		:= cContSmall
			TRZ->CONTMASTER	:= ""
			MsUnLock()
			
			If nPosPonto > 0
				cComboBox := Subs(cComboBox, nPosPonto+1)
				nPosIgual := AT("=",cComboBox)
				nPosPonto := AT(";",cComboBox)
			Else
				EXIT
			EndIf
			
		End
		
	EndIf
	
	dbSelectArea("TRW")
	dbSkip()
	
End

dbSelectArea("TRZ")
dbCloseArea()
FRename(cArqCombo+GetDbExtension(), "TCOMBO.DBF")

dbSelectArea("TRW")

RETURN

//-----------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCr_Tab_Dados  บAutor ณPaulo Carnelossi บ Data ณ  15/05/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria Arquivo .TXT com fonte gerado a partir de arquivo DBF  บฑฑ
ฑฑบ          ณpara ser agregado ao fonte do programa principal.           บฑฑ
ฑฑบ          ณBase para funcoes ttabela() /tcampos() / tcpos() tcombo()   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Cr_Tab_Dados(cNomArq, cAliasDest)
LOCAL aStruct
LOCAL cArqTxt
LOCAL cString, nCtd
LOCAL cNomeArray := "aDbfCria"
Local cAStruct := "aStruDbf"
Local xConteudo, nTamanho, nDecimal

cNomArq := Upper(Alltrim(cNomArq))
cArqTxt := STRTRAN(cNomArq, ".DBF", ".TXT")

nHdlTxt	:= FCREATE(cArqTxt,0)

If NHdlTxt < 0
	Return
Endif

GravaLin(nHdlTxt, '#include "Dbstruct.ch"')
GravaLin(nHdlTxt, '#Include "Protheus.ch"')
GravaLin(nHdlTxt, 'Static Function [[[NomeTab]]]()')

DbUseArea(.T.,__LocalDriver,cNomArq,"ARQ",.F.,.F.)

aStruct := ARQ->(DBSTRUCT())
//     1            cName          DBS_NAME
//     2            cType          DBS_TYPE
//     3            nLength        DBS_LEN
//     4            nDecimals      DBS_DEC
For nCtd := 1 TO LEN(aStruct)
	GravaLin(nHdlTxt, "// Posicao Array ("+cNomeArray+") --> "+Str(nCtd,3)+" - "+aStruct[nCtd][DBS_NAME])
Next
GravaLin(nHdlTxt, "")

cString := "Local "+cNomeArray+","+cAStruct
GravaLin(nHdlTxt, cString)
cString := "Local cArqCpos, x, nCtd, xConteudo"
GravaLin(nHdlTxt, cString)

GravaLin(nHdlTxt, "")

GravaLin(nHdlTxt, cNomeArray+" := {}")
GravaLin(nHdlTxt, "")

dbSelectArea("ARQ")
dbGoTop()

While ! Eof()
	
	cString := ""
	cString += "aAdd("+cNomeArray+", {"
	For nCtd := 1 TO FCOUNT()
		xConteudo := FieldGet(nCtd)
		nTamanho  := aStruct[nCtd][DBS_LEN]
		nDecimal  := aStruct[nCtd][DBS_DEC]
		If Valtype(xConteudo) == "C"
			cString += "'"+Alltrim(xConteudo)+"'"
		ElseIf Valtype(xConteudo) == "D"
			cString += "'"+DTOS(xConteudo)+"'"
		ElseIf Valtype(xConteudo) == "N"
			cString += Str(xConteudo, nTamanho,nDecimal)
		EndIf
		
		If nCtd == FCOUNT()
			cString += "} )"
		Else
			cString += ","
		Endif
		
	Next
	
	GravaLin(nHdlTxt, cString)
	
	dbSkip()
	
End
// cria estrutura do arquivo
GravaLin(nHdlTxt, "")

GravaLin(nHdlTxt, cAStruct+" := {}")
For nCtd := 1 TO Len(aStruct)
	cString := "aAdd("+cAStruct+",{ '"+aStruct[nCtd][DBS_NAME]+"', '"+aStruct[nCtd][DBS_TYPE]+"', "+Alltrim(Str(aStruct[nCtd][DBS_LEN]))+", "+Alltrim(Str(aStruct[nCtd][DBS_DEC]))+"})"
	GravaLin(nHdlTxt, cString)
Next
GravaLin(nHdlTxt, "")

cString := "cArqCpos := CriaTrab("+cAStruct+")"
GravaLin(nHdlTxt, cString)
cString := "DbUseArea(.T.,,cArqCpos,'"+cAliasDest+"',.F.,.F.)"
GravaLin(nHdlTxt, cString)

//carrega arquivo com array conteudo
GravaLin(nHdlTxt, "")

cString := "For x := 1 TO Len("+cNomeArray+")"
GravaLin(nHdlTxt, cString)
cString := '   RecLock("'+cAliasDest+'",.T.)'
GravaLin(nHdlTxt, cString)

cString := "      For nCtd := 1 TO Len("+cAStruct+")"
GravaLin(nHdlTxt, cString)

cString := "         xConteudo := If("+cAStruct+'[nCtd][DBS_TYPE] == "D", STOD('+cNomeArray+"[x][nCtd]),"+cNomeArray+"[x][nCtd])"
GravaLin(nHdlTxt, cString)

cString := "         FieldPut(nCtd, xConteudo)"
GravaLin(nHdlTxt, cString)

cString := "     Next"
GravaLin(nHdlTxt, cString)


cString := "   MsUnLock()"
GravaLin(nHdlTxt, cString)

cString := "Next"
GravaLin(nHdlTxt, cString)

GravaLin(nHdlTxt, "")
cString := "Return(cArqCpos)"
GravaLin(nHdlTxt, cString)

FClose(nHdlTxt)

Return

//---------------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGravaLin  บAutor  ณPaulo Carnelossi    บ Data ณ  15/05/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava linha no arquivo texto                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ funcao Cr_Tab_Dados                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GravaLin(nHdlTxt, cString)

FWrite(nHdlTxt,cString,Len(cString))
FWrite(nHdlTxt,Chr(13)+Chr(10),2)

Return
