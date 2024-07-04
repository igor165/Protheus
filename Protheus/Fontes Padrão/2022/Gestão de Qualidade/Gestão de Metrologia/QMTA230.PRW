#Include "PROTHEUS.ch"
#Include "Colors.ch" 
#include "font.ch"  
#include "QMTA230.CH"
                                                                                                   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QMTA230   ³ Autor ³ Cleber L. Souza       ³ data ³15/04/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de Movimentação de Instrumentos					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAQMT													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³STR 	     ³ Ultimo utilizado ->                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMTA230() 

Local cTpMov:=GetMV("MV_QMTPMOV",.F.,"2")

Local aCpoBrw	:= {}
Local cPesquisa := ""
Local cText		:= ""

Private oTmpTable1 := NIL
Private oTmpTable2 := NIL
Private oTmpTable3 := NIL

Private cUserMat :=  QAXUser(__cUserId,5) 
 
If cTpMov == "1" 
	Help (" ",1,"QM_QMTPMOV" )
	Return .T.
EndIf

If !(FWModeAccess("QN4") == "E" .And. FWModeAccess("QN5") == "E" .And. FWModeAccess("QML") == "E")
	MsgAlert(OemToAnsi(STR0146)) // Para utilizar essa rotina é necessário que o compartilhamento das tabelas QML, QN4 e QN5 estejam em modo exclusivo.
	Return .T.
Endif

dbSelectArea("QML")
dbSetOrder(1)
cCond := "QML->QML_FLAGB == 'A'"
QML->(dbSetFilter({||&cCond},cCond))
QML->(dbGoTop())

DbSelectArea("QN4")
QN4->(DbSetOrder(1)) //-- QN4_FILIAL+QN4_INSTR+QN4_REVINS+QN4_FILINS+QN4_ULTMOV
QN4->(DbGoTop())

If QML->(!Eof())
	While QML->(!Eof())
		If !Empty(cText)
			cText := cText + ", "
		Endif
		cText := cText + Alltrim(QML->QML_INSTR)+" "+QML->QML_REVINS
		QML->(dbSkip())
	Enddo	
Endif

If Len(Alltrim(cText)) > 1
	MsgAlert(OemToAnsi(STR0144)+chr(13)+cText+chr(13)+OemToAnsi(STR0145),OemToAnsi(STR0143))
	Return .T.
Endif		

QML->(DbClearFilter())		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//³    6 - Altera determinados campos sem incluir novos Regs     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cPesquisa := "QM230Psq"

Private aRotina :=  {{STR0001  , cPesquisa    , 0, 1},; //Pesquisa
				     {STR0002  , "QM230Empre" , 0, 7},; //Emprestimo 
			   		 {STR0003  , "QM230Devol" , 0, 7},; //Devolucao 
				 	 {STR0004  , "QM230Calib" , 0, 7},; //Calibracao  
				 	 {STR0005  , "QM230Aprov" , 0, 7},; //Confirmacao  
				 	 {STR0006  , "QM230LegOp" , 0, 7,,.F.}}  //Legenda
                                                                       
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemtoAnsi(STR0007) //"Movimentacao de Instrumentos"
Private aSitIns   := {}     
Private lQM230Brow := ExistBlock("QM230BROW")

//As variaveis cF230Fil,cD230Fil sao utilizadas juntamente com o ponto de entrada QM230BROW

Private cF230Fil := ""               
Private cD230Fil := ""
Private cCond 	 := ""
Private nOrdPesq := 1
Aadd(aSitIns,{"QN5->QN5_STATUS=='1'","BR_CINZA"})    										// Instrumento da propria filial Liberado 
Aadd(aSitIns,{"QN5->QN5_STATUS=='2'","BR_AMARELO"})  										// Instrumento de outra filial Liberado
Aadd(aSitIns,{"QN5->QN5_STATUS=='3'","BR_LARANJA"})  										// Instrumento com Devolucao Obrigatoria Liberado   
Aadd(aSitIns,{"QN5->QN5_STATUS=='4' .AND. QN5->QN5_FILIAL <> QN5->QN5_ULFILL","BR_AZUL"})	// Instrumento aguardando calibracao   
Aadd(aSitIns,{"QN5->QN5_STATUS=='5'","BR_VERMELHO"}) 										// Instrumento aguardando confirmacao   
Aadd(aSitIns,{"QN5->QN5_STATUS=='6'","BR_VERDE"})    										// Emprestimo entre departamento
Aadd(aSitIns,{"QN5->QN5_STATUS=='4' .AND. QN5->QN5_FILIAL == QN5->QN5_ULFILL","BR_PINK"})  // Emprestimo entre departamento para Calibração

If lQM230Brow
	cCond := ExecBlock("QM230BROW",.F.,.F.,{.F.,""})
	dbSelectArea("QAA")
	dbSelectArea("QN5")
	DbSetorder(1)
	If !Empty(cCond)
		Set Filter to &(cCond)
	EndIf

	mBrowse(6,1 ,22 ,75 ,"QN5",,,,,,aSitIns)

	dbSelectArea('QN5') 
	QN5->(dbSetOrder(1))
	If !Empty(cCond)
		Set Filter to
	Endif	
Else
	dbSelectArea("QN4")
	DbSetorder(1)		
	dbSelectArea("QN5")
	DbSetorder(1)
               
	QMTA230TRB()			
	DbSelectArea("TRB")
	dbGoTop()
	
	Aadd(aCpoBrw,{TitSx3("QN5_INSTR")[1] ,"TRB_INSTR" ,TamSx3("QN5_INSTR")[3] ,TamSx3("QN5_INSTR")[1] ,TamSx3("QN5_INSTR")[2] ,"@!"}) // "Instrumento"
	Aadd(aCpoBrw,{TitSx3("QN5_REVINS")[1],"TRB_REVINS",TamSx3("QN5_REVINS")[3],TamSx3("QN5_REVINS")[1],TamSx3("QN5_REVINS")[2],"@!"}) // "Rev. Instrum"
	Aadd(aCpoBrw,{TitSx3("QN5_FILINS")[1],"TRB_FILINS",TamSx3("QN5_FILINS")[3],TamSx3("QN5_FILINS")[1],TamSx3("QN5_FILINS")[2],"@!"}) // "Filial Instr"
	Aadd(aCpoBrw,{TitSx3("QN5_TPDEV")[1] ,"TRB_TPDEV" ,TamSx3("QN5_TPDEV")[3] ,TamSx3("QN5_TPDEV")[1] ,TamSx3("QN5_TPDEV")[2] ,"@!"}) // "Tipo Devoluc"
	Aadd(aCpoBrw,{TitSx3("QN5_DTADEV")[1],"TRB_DTADEV",TamSx3("QN5_DTADEV")[3],TamSx3("QN5_DTADEV")[1],TamSx3("QN5_DTADEV")[2],"@!"}) // "Data Devoluc"
	Aadd(aCpoBrw,{TitSx3("QN5_STATUS")[1],"TRB_STATUS",TamSx3("QN5_STATUS")[3],TamSx3("QN5_STATUS")[1],TamSx3("QN5_STATUS")[2],"@!"}) // "Status"
	Aadd(aCpoBrw,{TitSx3("QN5_TIPO")[1]  ,"TRB_TIPO"  ,TamSx3("QN5_TIPO")[3]  ,TamSx3("QN5_TIPO")[1]  ,TamSx3("QN5_TIPO")[2]  ,"@!"}) // "Familia"
	Aadd(aCpoBrw,{TitSx3("QN5_RESOBR")[1],"TRB_RESOBR",TamSx3("QN5_RESOBR")[3],TamSx3("QN5_RESOBR")[1],TamSx3("QN5_RESOBR")[2],"@!"}) // "Resp. Obriga"
	Aadd(aCpoBrw,{TitSx3("QN5_FILOBR")[1],"TRB_FILOBR",TamSx3("QN5_FILOBR")[3],TamSx3("QN5_FILOBR")[1],TamSx3("QN5_FILOBR")[2],"@!"}) // "Fil Res Obri"
	Aadd(aCpoBrw,{TitSx3("QN5_DEPOBR")[1],"TRB_DEPOBR",TamSx3("QN5_DEPOBR")[3],TamSx3("QN5_DEPOBR")[1],TamSx3("QN5_DEPOBR")[2],"@!"}) // "Dep Res Obri"
	Aadd(aCpoBrw,{TitSx3("QN5_ULFILL")[1],"TRB_ULFILL",TamSx3("QN5_ULFILL")[3],TamSx3("QN5_ULFILL")[1],TamSx3("QN5_ULFILL")[2],"@!"}) // "Ult. Fil"
	
	aSitIns := {}
	Aadd(aSitIns,{"TRB->TRB_STATUS=='1'","BR_CINZA"})    										// Instrumento da propria filial Liberado 
	Aadd(aSitIns,{"TRB->TRB_STATUS=='2'","BR_AMARELO"})  										// Instrumento de outra filial Liberado
	Aadd(aSitIns,{"TRB->TRB_STATUS=='3'","BR_LARANJA"})  										// Instrumento com Devolucao Obrigatoria Liberado   
	Aadd(aSitIns,{"TRB->TRB_STATUS=='4' .AND. TRB->TRB_FILIAL <> TRB->TRB_ULFILL","BR_AZUL"})	// Instrumento aguardando calibracao
	Aadd(aSitIns,{"TRB->TRB_STATUS=='5'","BR_VERMELHO"}) 										// Instrumento aguardando confirmacao   
	Aadd(aSitIns,{"TRB->TRB_STATUS=='6'","BR_VERDE"})   	 									// Emprestimo entre departamento
	Aadd(aSitIns,{"TRB->TRB_STATUS=='4' .AND. TRB->TRB_FILIAL == TRB->TRB_ULFILL","BR_PINK"})   // Emprestimo entre departamento para calibracao           
            
	mBrowse(6,1 ,22 ,75 ,"TRB",aCpoBrw,,,,,aSitIns,,,,,,.T.,.T.)
EndIf

If oTmpTable1 <> NIL
	oTmpTable1:Delete()
EndIf

If oTmpTable2 <> NIL
	oTmpTable2:Delete()
EndIf

If oTmpTable3 <> NIL
	oTmpTable3:Delete()
EndIf

Return(NIL)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QM230LegOp ³ Autor ³Cleber L. Souza 		³ Data ³15/04/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Define as Legendas utilizadas nos Instrumentos		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QM230LegOp()					     						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM230LegOp() 

Local aLegenda := {}
Local ny       := 0
Local nx       := 0
Local aBmp[8]
Local aSays[8]
Local oDlgLeg
Local oBrw		:= GetObjBrow()

Aadd(aLegenda,{"BR_CINZA"	, OemToAnsi(STR0008)}) //"Instrumento da propria filial Liberado "
Aadd(aLegenda,{"BR_AMARELO"	, OemToAnsi(STR0009)}) //"Instrumento de outra filial Liberado"  
Aadd(aLegenda,{"BR_LARANJA"	, OemToAnsi(STR0010)}) //"Instrumento com Devol.Obrigatoria Liberado "     
Aadd(aLegenda,{"BR_AZUL"	, OemToAnsi(STR0011)}) //"Instrumento aguardando calibracao"   
Aadd(aLegenda,{"BR_VERMELHO", OemToAnsi(STR0012)}) //"Instrumento aguardando Confirmação"   
Aadd(aLegenda,{"BR_VERDE"	, OemToAnsi(STR0130)}) //"Emprestimo de instrumento entre areas"   
Aadd(aLegenda,{"BR_PINK"	, OemToAnsi(STR0131)}) //"Emprestimo de instrumento entre areas para Calibração"


DEFINE MSDIALOG oDlgLeg FROM 0,0 TO 200,410 TITLE cCadastro Of oMainWnd PIXEL
oDlgLeg:bLClicked:= {||oDlgLeg:End()}
DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
@ 00,00 BITMAP oBmp RESNAME "PROJETOAP" oF oDlgLeg SIZE 35,155 NOBORDER WHEN .F. PIXEL
@ 11,35 TO 013,400 LABEL '' OF oDlgLeg PIXEL
@ 03,37 SAY STR0013 OF oDlgLeg PIXEL SIZE 100,009 FONT oBold
For nx := 1 to Len(aLegenda)
	@ 19+((nx-1)*10),44 BITMAP aBmp[nx] RESNAME aLegenda[nx][1] of oDlgLeg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 19+((nx-1)*10),(14/2) + 47 SAY If((ny+=1)==ny,aLegenda[ny][2]+If(ny==Len(aLegenda),If((ny:=0)==ny,"",""),""),"") of oDlgLeg PIXEL
Next
ny := 0


ACTIVATE MSDIALOG oDlgLeg CENTERED

If ValType(oBrw) != "U"
	oBrw:GoTop()
	oBrw:Refresh()
EndIf

Return(NIL)       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QM230Empre ³ Autor ³Cleber L. Souza 		³ Data ³15/04/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rotina de Emprestimo de Instrumentos.				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QM230Empre()					     						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM230Empre()

Local oDlg                         
Local oFont
Local oFont2
Local oGroup1
Local oGroup2
Local oGroup3
Local oGroup4
Local oBmp 
Local oResEnv 
Local oFilEnv  
Local oDepEnv  
Local oDtaDev 

Local oDesRE      
Local oDesFE      
Local oDesDE
      
Local oBtn1
Local oBtn2
Local oBtn3
Local oBtn4 

Local cDesRE  := CriaVar("QAA_NOME") 
Local cDesFE  := CriaVar("QAA_NOME") 
Local cDesDE  := CriaVar("QAD_DESC")  


Local c1Lbx    := ""
Local c1Lbx2   := ""
Local nOpcA    := 0 
             
Local bOk     := {||IIF(QM230VTOK(cResEnv,cFilEnv,cDepEnv),(nOpcA:=1,oDlg:End()),.F.)}
Local bCancel := {||nOpcA:=0,oDlg:End()}    

Local oSta1 	:= LoadBitmap( GetResources(), "BR_CINZA" )
Local oSta2 	:= LoadBitmap( GetResources(), "BR_AMARELO" )
Local oSta3 	:= LoadBitmap( GetResources(), "BR_AZUL" )  
Local oSta4 	:= LoadBitmap( GetResources(), "BRANCO" )  
Local oSta5  	:= LoadBitmap( GetResources(), "BR_LARANJA" )  
Local aSts 		:= {}
Local nOpc      := 4 
Local oBrw 		:= GetObjBrow()
Local nL 		  := 20

Private oRad1
Private oRad2
Private nItem1   := 1
Private o1Lbx 
Private o1Lbx2
Private lWhenDev := .T. 

Private oResSai  
Private oFilSai  
Private oDepSai  

Private oDesRS      
Private oDesFS      
Private oDesDS      

Private cResEnv := CriaVar("QN4_RESSAI")
Private cFilEnv := CriaVar("QN4_FILRSA")
Private cDepEnv := CriaVar("QN4_DEPRSA")   

Private cResSai := CriaVar("QN4_RESSAI")
Private cFilSai := CriaVar("QN4_FILRSA")
Private cDepSai := CriaVar("QN4_DEPRSA")  

Private cDesRS  := CriaVar("QAA_NOME")
Private cDesFS  := CriaVar("QAA_NOME") 
Private cDesDS  := CriaVar("QAD_DESC") 

Private dDtaDev := CriaVar("QN4_DTADEV")  
Private nItem2  := 1  
Private oStats  
Private cStatts := CriaVar("QM2_STATUS")
Private oPesqIn 
Private cPesIn  := CriaVar("QM2_INSTR")                                        
Private n_freq  := 0                                       
Private lQM230Brow := ExistBlock("QM230BROW")

SetKey( VK_F5, { || QM230SInD(.F.) } )                                        
SetKey( VK_F6, { || QM230SInE(.F.) } )                    
SetKey( VK_F7, { || QM230SInD(.T.) } )                                       
SetKey( VK_F8, { || QM230SInE(.T.) } )                                        

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega dos dados do Responsavel pelo envio.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QAA")
dbSetOrder(6)
If QAA->(DbSeek(TRIM(UPPER(cUserName))))
	cResEnv   := QAA->QAA_MAT
	cDesRE    := QAA->QAA_NOME
	cFilEnv   := SM0->M0_CODFIL
	cDesFE    := SM0->M0_NOME
	cDepEnv   := QAA->QAA_CC  
	cDesDE    := Posicione("QAD",1,XFILIAL("QAD")+QAA->QAA_CC,"QAD_DESC")
	
Else
    Messagedlg(STR0014)
   //	Help("",1,"QM230001",,OemToAnsi(STR0014),1) //"Usuario logado nao esta cadastrado como usuario, favor atualizar informações !!" 
	dbSelectArea("QN5")
	Return 
EndIf

QM230CriaArq()   

DEFINE MSDIALOG oDlg TITLE STR0015 From 54,000 To 640,840 OF GetWndDefault() PIXEL //"Movimentações entre Filiais"
DEFINE FONT oFont  NAME "Arial" SIZE 0,-11 BOLD
DEFINE FONT oFont2 NAME "Arial" SIZE 0,-11 

//Grupo com os dados do responsavel pelo envio do Instrumento.
@ 16+nL , 3 GROUP oGroup1 TO 92,215	LABEL STR0016 OF oDlg PIXEL  //"Responsavel pelo Envio"
oGroup1:oFont:= oFont

//Grupo com os dados do responsavel pelo recebimento do Instrumento.
@ 16+nL , 218 GROUP oGroup2 TO 92,420	LABEL STR0017 OF oDlg PIXEL  //"Responsavel pelo Recebimento"
oGroup2:oFont:= oFont

//Dados Referentes ao Responsavel do Envio do Instrumento                                                    
@ 27+nL, 7 SAY STR0018  OF oDlg PIXEL SIZE 100,009 FONT oFont2 //"Responsavel Envio : "
@ 40+nL, 7 SAY STR0019  OF oDlg PIXEL SIZE 100,009 FONT oFont2 //"Filial  : "
@ 53+nL, 7 SAY STR0020  OF oDlg PIXEL SIZE 100,009 FONT oFont2 //"Departamento : " 
@ 66+nL, 7 SAY STR0021  OF oDlg PIXEL SIZE 100,009 FONT oFont2 //"Tipo de Movimentacao : " 

@ 25+nL,45  MSGET oResEnv VAR cResEnv PICTURE "@!" SIZE 80, 8 OF oDlg PIXEL When .F.
@ 25+nL,133 MSGET oDesRE  VAR cDesRE  PICTURE "@!" SIZE 74, 8 OF oDlg PIXEL When .F.
@ 38+nL,45  MSGET oFilEnv VAR cFilEnv PICTURE "@!" SIZE 65, 8 OF oDlg PIXEL When .F.
@ 38+nL,115 MSGET oDesFE  VAR cDesFE  PICTURE "@!" SIZE 92, 8 OF oDlg PIXEL When .F.
@ 51+nL,45  MSGET oDepEnv VAR cDepEnv PICTURE "@!" SIZE 80, 8 OF oDlg PIXEL When .F.  
@ 51+nL,133 MSGET oDesDE  VAR cDesDE  PICTURE "@!" SIZE 74, 8 OF oDlg PIXEL When .F.
@ 66+nL,80  RADIO oRad1   VAR nItem1 ON CLICK qm230ch() 3D SIZE 65, 11 ;
			PROMPT STR0022,;              //"Emprestimo"
				   STR0023 OF oDlg PIXEL  //"Calibracao"


//Dados Referentes ao Responsavel do Envio do Instrumento
@ 27+nL, 222 SAY STR0019 OF oDlg PIXEL SIZE 100,009 FONT oFont2 //"Filial  : "
@ 40+nL, 222 SAY STR0024 OF oDlg PIXEL SIZE 100,009 FONT oFont2 //"Responsavel Recebimento : "
@ 53+nL, 222 SAY STR0020 OF oDlg PIXEL SIZE 100,009 FONT oFont2 //"Departamento : "
@ 66+nL, 222 SAY STR0025 OF oDlg PIXEL SIZE 100,009 FONT oFont2 //"Tipo da Devolução: " 

@ 25+nL,273 MSGET oFilSai VAR cFilSai PICTURE "@!" SIZE 55, 8 OF oDlg PIXEL F3 "SM0" Valid QM230ValF(cFilSai)
@ 25+nL,331 MSGET oDesFS  VAR cDesFS  PICTURE "@!" SIZE 87, 8 OF oDlg PIXEL When .F.
@ 38+nL,273 MSGET oResSai VAR cResSai PICTURE "@!" SIZE 70, 8 OF oDlg PIXEL F3 "QAA1  " Valid QM230ValA(@cResSai,@cFilSai,@cDepSai,@oDepSai)
@ 38+nL,344 MSGET oDesRS  VAR cDesRS  PICTURE "@!" SIZE 74, 8 OF oDlg PIXEL When .F.
@ 51+nL,273 MSGET oDepSai VAR cDepSai PICTURE "@!" SIZE 70, 8 OF oDlg PIXEL When .F.
@ 51+nL,344 MSGET oDesDS  VAR cDesDS  PICTURE "@!" SIZE 74, 8 OF oDlg PIXEL When .F.
@ 66+nL,271 RADIO oRad2   VAR nItem2  3D 	SIZE 74, 11 ;
			PROMPT STR0027,;              //"Devolucao Obrigatoria"
				   STR0028 OF oDlg PIXEL  //"Devolucao nao Obrigatoria"
				oRad2:bChange := {|| QM230ChgR2(nItem2,@oRad2) } 

aSts := {}
@ 66+nL,352 SAY "Status:" OF oDlg PIXEL SIZE 100,009 FONT oFont2 //"Status"
dbSelectArea("QMP")
dbSetOrder(1) 
dbGoTop()
While QMP->(!Eof())
    If QMP->QMP_STATUS <> "0" //Status diferente de Malha...
	    Aadd(aSts,QMP->QMP_DESCR)
	Endif	   		 
	dbSkip()
Enddo
@ 66+nL,370 ComboBox oStats Var cStatts  Items aSts WHEN (Alltrim(cFilEnv) == Alltrim(cFilSai)) Size 40, 8 Of oDlg Pixel

//Grupo com os instrumentos disponiveis para envio.
@ 94+nL , 3 GROUP oGroup3 TO 240,205	LABEL STR0029 OF oDlg PIXEL //"Instrumento Disponiveis"
oGroup3:oFont:= oFont

//Grupo com os Instrumentos que serao enviados.
@ 94+nL , 223 GROUP oGroup4 TO 240,420	LABEL STR0030 OF oDlg PIXEL //"Instrumentos Enviados"
oGroup4:oFont:= oFont                                                                

@ 255+nL,415 BTNBMP oBtn1 RESOURCE "NEXT"   SIZE 25,25 PIXEL DESIGN ACTION QM230SInD(.F.) OF oDlg 
oBtn1:CTOOLTIP := STR0031 //"Envia Instrumento"


@ 305+nL,415 BTNBMP oBtn2 RESOURCE "PREV"   SIZE 25,25 PIXEL DESIGN ACTION QM230SInE(.F.) OF oDlg 
oBtn2:CTOOLTIP := STR0032 //"Retorna Instrumento"

@ 355+nL,415 BTNBMP oBtn3 RESOURCE "PGNEXT" SIZE 25,25 PIXEL DESIGN ACTION Processa({||QM230SInD(.T.)},STR0035) OF oDlg 
oBtn3:CTOOLTIP := STR0033 //"Envia Todos os Instrumento"

@ 405+nL,415 BTNBMP oBtn4 RESOURCE "PGPREV" SIZE 25,25 PIXEL DESIGN ACTION Processa({||QM230SInE(.T.)},STR0035) OF oDlg 
oBtn4:CTOOLTIP := STR0034 //"Retorna Todos os Instrumento"

@ 102+nL,6 LISTBOX o1Lbx VAR c1Lbx FIELDS ALIAS "TMP";
		 HEADER    						    "",; 
							OemtoAnsi(STR0036),; //"Instrumento"
							OemtoAnsi(STR0037),; //"Revisao"
							OemtoAnsi(STR0038),;  //"Filial"
							OemtoAnsi(STR0078);  //"Familia"
		COLSIZES 			GetTextWidth(0,"W"),;
							GetTextWidth(0,"BBBBBBBBBBBBBBBBB"),;
							GetTextWidth(0,"BB"),;
							GetTextWidth(0,"BB"),;
							GetTextWidth(0,"BBBBBBBBBBBBBBBB");
					        SIZE 195,133 OF oDlg PIXEL
	  
	o1Lbx:bLine:= {||{			IIf(TMP->TMP_STATUS=="1",oSta1,IIF(TMP->TMP_STATUS=="2",oSta2,IIF(TMP->TMP_STATUS=="4",oSta3,IIF(TMP->TMP_STATUS=="3",oSta5,IIF(TMP->TMP_STATUS=="6",oSta1,""))))),;
	                            TMP->TMP_INSTR,;
								TMP->TMP_REVINS,;
								TMP->TMP_FILINS,;
								TMP->TMP_TIPO}}

@ 102+nL,226 LISTBOX o1Lbx2 VAR c1Lbx2 FIELDS ALIAS "TMP2";
		 HEADER    						    "",; 
							OemtoAnsi(STR0036),; //"Instrumento"
							OemtoAnsi(STR0037),; //"Revisao"
							OemtoAnsi(STR0038),;  //"Filial"
							OemtoAnsi(STR0078);  //"Familia"
		COLSIZES 			GetTextWidth(0,"W"),;
							GetTextWidth(0,"BBBBBBBBBBBBBBBBB"),;
							GetTextWidth(0,"BB"),;
							GetTextWidth(0,"BB"),;
							GetTextWidth(0,"BBBBBBBBBBBBBBBB");
					        SIZE 190,133 OF oDlg PIXEL
	  
	o1Lbx2:bLine:= {||{		 IIf(TMP2->TMP2_STATU=="1",oSta1,IIF(TMP2->TMP2_STATU=="2",oSta2,IIF(TMP2->TMP2_STATU=="6",oSta1,oSta4))),;	
	                             TMP2->TMP2_INSTR,;   
								TMP2->TMP2_REVIN,;
								TMP2->TMP2_FILIN,;
								TMP2->TMP2_TIPO}}

@ 240+nL,04 SAY "Pesquisar: " OF oDlg PIXEL SIZE 80,08 FONT oFont  //"Pesquisar"								
@ 240+nL,35 MSGET oPesqIn VAR cPesIn PICTURE "@!" SIZE 68,  8 OF oDlg PIXEL //Valid QM230ValF(cFilSai)
oPesqIn:bLostFocus := {|| QM230TR1(cPesIn)}

@ 250+nL, 10 BITMAP oBmp RESNAME "BR_CINZA" oF oDlg SIZE 35,155 NOBORDER WHEN .F. PIXEL
@ 250+nL, 17 SAY STR0039 OF oDlg PIXEL SIZE 150,009 FONT oFont  //" - Instrumento Disponivel da Própria Filial "

@ 250+nL, 140 BITMAP oBmp RESNAME "BR_AMARELO" oF oDlg SIZE 35,155 NOBORDER WHEN .F. PIXEL
@ 250+nL, 147 SAY STR0040 OF oDlg PIXEL SIZE 150,009 FONT oFont //" - Instrumento Disponivel de Outra Filial "

@ 250+nL, 270 BITMAP oBmp RESNAME "BR_AZUL" oF oDlg SIZE 35,155 NOBORDER WHEN .F. PIXEL
@ 250+nL, 277 SAY STR0041 OF oDlg PIXEL SIZE 150,009 FONT oFont //" - Instrumento aguardando Calibração "                                  

oStats:lreadonly:=.T.


ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bOk,bCancel)) CENTERED  

If nOpcA==1
   QM230GrvAll(cResEnv,cFilEnv,cDepEnv,cResSai,cFilSai,cDepSai,nItem1,nItem2,cDesDe)
EndIf

SetKey( VK_F5, { || NIL } )                                        
SetKey( VK_F6, { || NIL } )                    
SetKey( VK_F7, { || NIL } )                                       
SetKey( VK_F8, { || NIL } )                                        

//Posiciona Instrumentos disponivels da filial corrente.
dbSelectArea("QN5")
dbSeek(xFilial("QN5"))

// Para atualizar o mBrowse customizado com arquivo de trabalho
If !lQm230Brow
	If oTmpTable3 <> NIL
		oTmpTable3:Delete()
	EndIf
	QMTA230TRB()
Endif

If ValType(oBrw) != "U"
	oBrw:GoTop()
	oBrw:Refresh()
EndIf

Return(NIL)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QM230CriaArq³ Autor ³Cleber L. Souza 		³ Data ³15/04/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gera Arquivos temporarios para os ListBox dos Instrumentos.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QM230CriaArq					     						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM230CriaArq()
Local aSaveArea	:= GetArea()
Local a1Stru	:= {}
Local a2Stru	:= {}
Local cCond		:= "" 
Local cQuery    := "" 
Local cAlias    := "" 
Local cIndex    := "" 
Local cFiltro   := "" 
Local cUsr      := QAXUser(__cUserId,5)
Local aTam		:= {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8¿
//³Arquivo do ListBox 1.						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8Ù
aTam := TamSX3("QN5_INSTR")
Aadd(a1Stru,{"TMP_INSTR"	,"C",aTam[1],aTam[2]})

aTam := TamSX3("QN5_REVINS")  
Aadd(a1Stru,{"TMP_REVINS"	,"C",aTam[1],aTam[2]})

aTam := TamSX3("QN5_FILINS")
Aadd(a1Stru,{"TMP_FILINS"	,"C",aTam[1],aTam[2]})

aTam := TamSX3("QN5_TIPO")
Aadd(a1Stru,{"TMP_TIPO"  	,"C",aTam[1],aTam[2]})

aTam := TamSX3("QN5_STATUS")
Aadd(a1Stru,{"TMP_STATUS"	,"C",aTam[1],aTam[2]})

oTmpTable1 := FWTemporaryTable():New( "TMP" )
oTmpTable1:SetFields( a1Stru )
oTmpTable1:AddIndex("indice1", {"TMP_INSTR","TMP_REVINS"} )
oTmpTable1:Create()		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8¿
//³Arquivo do ListBox 2.						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8Ù
aTam := TamSX3("QN5_INSTR")
Aadd(a2Stru,{"TMP2_INSTR"	,"C",aTam[1],aTam[2]})  

aTam := TamSX3("QN5_REVINS")
Aadd(a2Stru,{"TMP2_REVIN"	,"C",aTam[1],aTam[2]})

aTam := TamSX3("QN5_FILINS")
Aadd(a2Stru,{"TMP2_FILIN"	,"C",aTam[1],aTam[2]})

aTam := TamSX3("QN5_TIPO")
Aadd(a2Stru,{"TMP2_TIPO"  	,"C",aTam[1],aTam[2]})

aTam := TamSX3("QN5_STATUS")
Aadd(a2Stru,{"TMP2_STATU"	,"C",aTam[1],aTam[2]})

aTam := TamSX3("QN5_TPDEV")
Aadd(a2Stru,{"TMP2_TPDEV"    ,"C",aTam[1],aTam[2]})

oTmpTable2 := FWTemporaryTable():New( "TMP2" )
oTmpTable2:SetFields( a2Stru )
oTmpTable2:AddIndex("indice1", {"TMP2_INSTR","TMP2_REVIN"} )
oTmpTable2:Create()			 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8¿
//³Carrega TR1 com os Instrumentos disponiveis.	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8Ù

cAlias := "QN5TRB"
cQuery := "SELECT DISTINCT QN5.QN5_INSTR,QN5.QN5_REVINS,QN5.QN5_FILINS,QN5.QN5_TIPO, QN5.QN5_STATUS,"
cQuery += "QM2.QM2_FILIAL,QM2.QM2_DEPTO,QM2.QM2_INSTR,QM2.QM2_REVINS,QM2.QM2_FLAG,"
cQuery += "QN4.QN4_FILIAL,QN4.QN4_INSTR,QN4.QN4_REVINS,QN4.QN4_ULTMOV "
cQuery += "FROM " + RetSqlName("QN5")+" QN5, " 
cQuery += RetSqlName("QN4") + " QN4, " 
cQuery += RetSqlName("QM2") + " QM2 " 
cQuery += "WHERE QN5.QN5_FILIAL = '"+xFilial("QN5")+"' AND "
cQuery += "QN5.QN5_INSTR = QM2.QM2_INSTR  AND QN5.QN5_REVINS = QM2.QM2_REVINS AND "
cQuery += "QN5.QN5_INSTR = QN4.QN4_INSTR  AND QN5.QN5_REVINS = QN4.QN4_REVINS AND "
If !Empty(xFilial("QM2"))
	//cQuery += "QN5.QN5_FILINS = QM2.QM2_FILIAL AND "
Endif            
cQuery += "QN4.QN4_FILIAL = '" + Xfilial("QN4") + "' AND " 
cQuery += "QN4.QN4_ULTMOV = 'S'  AND "  
   		If !lQM230Brow
        	cQuery += "QN4.QN4_RESENT = '"+cUsr+ "' AND "
   		EndIf
cQuery += "QN5.QN5_STATUS <> '5 '  AND "
cQuery += "QN5.QN5_STATUS <> '4 '  AND "
cQuery += "QM2.QM2_FLAG = '1'  AND "
cQuery += "QM2.D_E_L_E_T_<>'*' AND " 
cQuery += "QN4.D_E_L_E_T_<>'*' AND "		
cQuery += "QN5.D_E_L_E_T_<>'*' "

If lQM230Brow
	cQuery += ExecBlock("QM230BROW",.F.,.F.,{.F.,"TOP"})
Endif	
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"QN5TRB", .F., .T.)

dbSelectArea(cAlias)
&(cAlias+"->(dbGoTop())")

While &(cAlias+"->(!EOF())")
	dbSelectArea("QM2")
	dbSetOrder(1)
	If dbSeek(xFilial()+&(cAlias+"->QN5_INSTR")+Inverte(&(cAlias+"->QN5_REVINS")))	            
		If QM2->QM2_FLAG == "2"
			dbSelectArea(cAlias)
			dbSkip()
			loop
		Endif	
	Endif
	If QN4->(DbSeek(xFilial("QN4")+&(cAlias+"->QN5_INSTR")+&(cAlias+"->QN5_REVINS")+&(cAlias+"->QN5_FILINS")+"S"))
	     If QN4->QN4_RESENT <> QAXUser(__cUserId,5) 
			dbSelectArea(cAlias)
			dbSkip()
			Loop    
		Endif	
	Endif
	dbSelectArea("TMP")                                                              
	RecLock("TMP",.T.)
   	TMP->TMP_INSTR  := &(cAlias+"->QN5_INSTR")
   	TMP->TMP_REVINS := &(cAlias+"->QN5_REVINS")
   	TMP->TMP_FILINS := &(cAlias+"->QN5_FILINS")
	TMP->TMP_TIPO   := &(cAlias+"->QN5_TIPO")
	TMP->TMP_STATUS := &(cAlias+"->QN5_STATUS")
	
	MsUnlock()    

	dbSelectArea(cAlias)
	dbSkip()
EndDo         
TMP->(dbGoTop())

QN5TRB->(dbCloseArea())		

RestArea(aSaveArea)
Return Nil   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QM230SInD³ Autor ³Cleber L. Souza 		³ Data ³15/04/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Movimentacao de Instrum. Diponiveis para Emprestar		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QM230SInD(ExpL1)				     						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 : Se True movimenta todos para Instrum a Emprestar.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function QM230SInD(lTodos)                

Local aSaveArea	:= GetArea()
Local nInicio	:= 0
Local nFim		:= 0
Local nRec		:= 0
Local nRecno	:= 0
Local lRet		:= .T.
Local lExIns 	:= .T.
Local lMaDtV 	:= .F.								
Local cTpDev:= space(1)

Default lTodos	:= .F.

//Verifica se foi escolhido filial + responsavel
If Empty(cFilSai) .or. Empty(cResSai)
    Messagedlg(STR0132)
   //	Help("",1,"QM230018",,STR0132,1) //"Antes de selecionar o instrumento, escolha a filial e o responsavel pelo emprestimo."
	lRet := .f.	
Endif

dbSelectArea("TMP") 

lMaDtV := .f.								

If lRet
	nRecno	:= nInicio	:= TMP->(Recno())
	If lTodos
		dbGoTop()
		nInicio	:= 1
		nFim		:= TMP->(LastRec())
		ProcRegua(nFim)
	Else
		nFim := TMP->(Recno())
	Endif
	
	If TMP->(!EOF())
		For nRec := nInicio To nFim
			IF TMP->(!EOF())
				If lTodos
					IncProc()
				Endif
				
				//Para movimentacoes entre departamentos verificar se a familia permite movimentacao
				if lExIns
					QM1->(DbSetOrder(1))
					if QM1->(DbSeek(xFilial("QM1")+TMP->TMP_TIPO))
							If !QM1->(Eof())
								If QM1->QM1_LOCAL == "N"
									 lExIns:=.F.
								EndIf
							EndIf
					Endif 
				Endif
				If Alltrim(cFilSai) == Alltrim(cFilEnv)
					//Verificar se para o instrumento + revisao pode-se realizar a movimentacao
					
					
					/*If !lRet .and. !lTodos
						MessageDlg(STR0118,,3)//"Familia do instrumento nao permite movimentacao. Verifique a configuracao do campo QM1_LOCAL."
						lRet := .F.
					Endif
					 */
					If lRet
						dbSelectArea("QM2")
						dbSetOrder(1)
						If dbSeek(TMP->TMP_FILINS+TMP->TMP_INSTR+Inverte(TMP->TMP_REVINS))
//							If mv_par02 == 1
								n_Freq := QM2->QM2_VALDAF - dDataBase
								If n_Freq < 0
									Help(" ",1,"QMTA160VLD",,QM2->QM2_INSTR,3,1) // A data de afericao vencera antes do retorno do Instrumento	
									lRet :=MsgYesNo(STR0133)								//"Deseja efetuar o empréstimo?"
									
								Endif
//							Else
//								n_Freq := mv_par01
//							Endif	
							
							/*If QM2->QM2_VALDAF < dDataBase .and. lRet
								If lTodos
									Help(" ",1,"QMTA160VLD",,QM2->QM2_INSTR,3,1) // A data de afericao vencera antes do retorno do Instrumento
									lRet :=MsgYesNo("Deseja efetuar o empréstimo?")
								Endif					
								lMaDtV := .T.								
							Endif*/ 																			
						Endif
					Endif
				Endif                   
				If Alltrim(cFilSai) <> Alltrim(cFilEnv)
					dbSelectArea("QM2")
					dbSetOrder(1)
					If dbSeek(TMP->TMP_FILINS+TMP->TMP_INSTR+Inverte(TMP->TMP_REVINS))
						n_Freq := QM2->QM2_VALDAF - dDataBase
						If n_Freq < 0
							Help(" ",1,"QMTA160VLD",,QM2->QM2_INSTR,3,1) // A data de afericao vencera antes do retorno do Instrumento	
							lRet :=MsgYesNo(STR0133)	//"Deseja efetuar o empréstimo?"							
							
						Endif
						
						/*If QM2->QM2_VALDAF < dDataBase .and. lRet
							If lTodos
								Help(" ",1,"QMTA160VLD",,QM2->QM2_INSTR,3,1) // A data de afericao vencera antes do retorno do Instrumento
								lRet :=MsgYesNo("Deseja efetuar o empréstimo?")
							Endif					
							lMaDtV := .T.								
						Endif*/ 																				
					Endif
						
					DbSelectArea("QN5")  
					DbGotop()
					DbSetOrder(1)
					If DbSeek(Xfilial("QN5")+TMP->TMP_INSTR+TMP->TMP_REVINS+TMP->TMP_FILINS)
						IF Alltrim(cFilSai) == Alltrim(QN5->QN5_FILINS)
							messagedlg(STR0134,,2)   //"Não poderá efetuar empréstimo para a filial do instrumento. Utilize a rotina de devolução"
							lRet:=.F.
						Else
							IF !EMPTY(QN5->QN5_DTADEV) .and. ddatabase  > QN5->QN5_DTADEV  
								messagedlg(STR0135)       //"Não poderá efetuar empréstimo porque já ultrapassou a data de devolução do instrumento"
								lRet:=.F.
							Else	
								If  FwModeAccess("QN5")=="E" .AND. !Empty(QN5->QN5_FILOBR)  .and. 	 nItem2 == 1
									messagedlg(STR0136,,2)//"O tipo de devolução foi selecionado como Obrigatória, porém esse instrumento já foi transferido com esse status, será alterado para não Obrigatória"
									cTpDev:="2" 
									nItem2:=2
									QM230ChgR2(nItem2,@oRad2)
								Else 
									cTpDev:=str(nitem2,1)
								Endif
							Endif
						Endif
					Endif
				Else
					cTpDev:=str(nitem2,1)
				Endif			
				If lRet
					dbSelectArea("TMP2")
					RecLock("TMP2",.T.)
					TMP2->TMP2_INSTR	:= TMP->TMP_INSTR
					TMP2->TMP2_REVIN	:= TMP->TMP_REVINS
					TMP2->TMP2_FILIN	:= TMP->TMP_FILINS
					TMP2->TMP2_TIPO 	:= TMP->TMP_TIPO
					TMP2->TMP2_STATU	:= TMP->TMP_STATUS
					TMP2->TMP2_TPDEV := cTpDev
					TMP2->( MsUnlock() )
					
					dbSelectArea("TMP")
					RecLock("TMP",.F.)
					dbDelete()
					TMP->( MsUnlock() )
				Endif
				lRet := .T.
				
				TMP->(DbSkip())
			Else
				Exit
			EndIf
		Next nRec
		
		dbSelectArea("TMP2")
		dbGoTop()
		o1Lbx2:Refresh(.T.)
		
		TMP->(DbGotop())
		o1Lbx:Refresh(.T.)
		
//		If !lExIns .and. lTodos 
//			MessageDlg(STR0119,,1)	//"Existe(m) instrumento(s) que nao foi/foram movimentado(s). Sua(s) respectiva(s) familia(s) do(s) instrumento(s) nao permite(m) movimentacao(oes)
//		Endif                       
		
//		If lMaDtV .and. lRet
//			MessageDlg("Existe(m) instrumento(s) com validade de afericao menor que a data do retorno do instrumento, portanto nao sera(ao) imprestado(s)",,1)											
//		Endif
	EndIf
Endif

RestArea(aSaveArea)
oRad1:Disable()
Return lRet  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QM230SInE³ Autor ³Cleber L. Souza 		³ Data ³15/04/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Movimentacao de Instrum. a Emprestar para disponivel		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QM230SInE(ExpL1)				     						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 : Se True movimenta todos para Instrum a Emprestar.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
function QM230SInE(lTodos)     
           
Local aSaveArea	:= GetArea()
Local nInicio	:= 0
Local nFim		:= 0
Local nRec		:= 0
Local nRecno	:= 0
Local lRet		:= .T.
Default lTodos	:= .F.

dbSelectArea("TMP2") 
nRecno	:= nInicio	:= TMP2->(Recno())

If lTodos
   dbGoTop()               
   nInicio	:= 1
   nFim		:= TMP2->(LastRec())
   ProcRegua(nFim)
Else
   nFim := TMP2->(Recno())
Endif     

If TMP2->(!EOF())
	For nRec := nInicio To nFim
		If TMP2->(!EOF())
			If lTodos
				IncProc()
			Endif
			
			dbSelectArea("TMP")
			RecLock("TMP",.T.)
			TMP->TMP_INSTR	:= TMP2->TMP2_INSTR
			TMP->TMP_REVINS	:= TMP2->TMP2_REVIN
			TMP->TMP_FILINS	:= TMP2->TMP2_FILIN
			TMP->TMP_TIPO	:= TMP2->TMP2_TIPO
			TMP->TMP_STATUS	:= TMP2->TMP2_STATU
			TMP->( MsUnlock() )
			
			dbSelectArea("TMP2")
			RecLock("TMP2",.F.)
			dbDelete()
			TMP2->( MsUnlock() )
			
			lRet := .T.
			TMP2->(DbSkip())
		Else
			Exit
		EndIF
	Next nRec
	
	dbSelectArea("TMP")
	dbGoTop()
	o1Lbx:Refresh(.T.)
	
	TMP2->(DbGotop())
	o1Lbx2:Refresh(.T.)
	
EndIf

RestArea(aSaveArea)
oRad1:Enable()
Return lRet  
       
                          
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QM230ChgR2 ³ Autor ³Cleber L. Souza 		³ Data ³15/04/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Bloqueia ou Libera digitação na campo de Data da Devolucao ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QM230ChgR2					     						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Indica se é uma Devolucao Obrigatoria			  ³±±
±±³			 ³ EXPO1 = Objeto MsGet da Data da Devolução				  ³±±
±±³			 ³ EXPO2 = Objeto RADIO da Opcao de Devolução Obrigatoria	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM230ChgR2(nItem2,oRad2)

IF nItem2==1
	lWhenDev:=.T.
Else
	lWhenDev:=.F.
EndIF          

oRad2:SetFocus()

Return  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QM230F3A  ³ Autor ³Cleber L. Souza 		³ Data ³15/04/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Pesquisa especifica dos Responsaveis existentes na empresa. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QM230F3A()					     						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM230F3A()

Local lRet      := .T.
Local cTitulo	:= STR0043  //"Responsaveis por Filial / Departamento"

lRet := QM230ConA(cTitulo,"QAA")

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QM230ConA ³ Autor ³Cleber L. Souza 		³ Data ³15/04/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta Tela da Consulta Especifica de Responsaveis		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QM230ConA					     						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 - Titulo da Pesquisa								  ³±±
±±³			 ³ EXPC2 - Alias do Arquivo									  ³±±
±±³          ³ EXPA1 - Array com os campos da pesquisa					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM230ConA( cTitulo, cAlias )
Local oDlg
Local oBtn1
Local oBtn2  
Local oCol
Local nOpc			:= 0
Local nY            := 0
Local cConteudo		:= ''
Local nPos			:= 0 
Local nAlias        := 0  
Local cKey          := "" 
Local aStru	        := {}
Local aCpos         := {"QAA_FILIAL","QAA_DESFIL","QAA_MAT","QAA_NOME","QAA_CC","QAD_DESC"} 
Local cVar          := ""
Local cPesquisa     := Space(100)
Local oPesquisa
Local oCbx   
Local aIndice       := {STR0110} //"Nome + Matricula"
Private oBrowse

aAdd(aStru,{"QAA_FILIAL","C",2,0}) 
aAdd(aStru,{"QAA_DESFIL","C",15,0}) 
aAdd(aStru,{"QAA_MAT","C",10,0})
aAdd(aStru,{"QAA_NOME","C",30,0})
aAdd(aStru,{"QAA_CC","C",13,0})
aAdd(aStru,{"QAD_DESC","C",25,0})

oTmpTable := FWTemporaryTable():New( "TMP" )
oTmpTable:SetFields( aStru )
oTmpTable:AddIndex("indice1", {"QAA_NOME","QAA_MAT"} )
oTmpTable:Create()

DbSelectArea("QAA")
DbSetOrder(3)
DbSeek(cFilSai)
While !Eof() .And. Alltrim(QAA->QAA_FILIAL) == Alltrim(cFilSai) 

	If (QAA->QAA_MAT == cResEnv .and. Alltrim(QAA->QAA_FILIAL) == Alltrim(cFilEnv))
		QAA->(dbSkip())
		Loop
    EndIf
    
	DbSelectArea("QAD")
	DbSetOrder(1)
	DbSeek(QAA->QAA_FILIAL+QAA->QAA_CC)
		
	dbSelectArea("TMP")
	RecLock("TMP",.T.)
	TMP->QAA_FILIAL := QAA->QAA_FILIAL
	TMP->QAA_DESFIL := QA_CHKFIL(QAA->QAA_FILIAL,,.T.)
	TMP->QAA_MAT    := QAA->QAA_MAT
	TMP->QAA_NOME   := QAA->QAA_NOME
	TMP->QAA_CC     := QAA->QAA_CC
	TMP->QAD_DESC   := QAD->QAD_DESC
	MsUnlock()	
	dbSelectArea("QAA")
	DbSkip()
EndDo

nAlias	 := Select("TMP")
DbGoTop()

QAA->(dbSetOrder(1))
QAD->(dbSetOrder(1))

DEFINE MSDIALOG oDlg TITLE STR0044+cTitulo From 9,0 To 26,60 OF oMainWnd  //"Consulta - "

oBrowse := TcBrowse():New( 2, 2, 205, 90, , , , oDlg, ,,,,,,,,,,, .F.,"TMP", .T.,, .F., , ,.f. )

For nY:=1 to Len(aCpos)	
	If aCpos[nY] == "QAA_DESFIL"
		oCol := TCColumn():New("Dec.Filial",If( ValType(FieldWBlock("QAA_DESFIL",nAlias))=="B", FieldWBlock("QAA_DESFIL",nAlias), {|| FieldWBlock("QAA_DESFIL",nAlias)} ),,,, "LEFT",,.F.,.F.,,,,.F.)
		oBrowse:ADDCOLUMN(oCol)
    Else		
		If GetSx3Cache(aCpos[nY],"X3_TIPO") != "N"
			oCol := TCColumn():New(Trim(QAGetX3Tit(aCpos[nY])),If( ValType(FieldWBlock(aCpos[nY],nAlias))=="B", FieldWBlock(aCpos[nY],nAlias), {|| FieldWBlock(aCpos[nY],nAlias)} ),,,, "LEFT",,.F.,.F.,,,,.F.)
		Else	
			oCol := TCColumn():New(Trim(QAGetX3Tit(aCpos[nY])),If( ValType(FieldWBlock(aCpos[nY],nAlias))=="B", FieldWBlock(aCpos[nY],nAlias), {|| FieldWBlock(aCpos[nY],nAlias)} ),GetSx3Cache(aCpos[nY],"X3_PICTURE"),,,Upper("RIGHT"),,.F.,.F.,,,,.F.)
		Endif
		oBrowse:ADDCOLUMN(oCol)
    EndIF
Next nY
oBrowse:bLDblClick := {||nOpc := 1,QM230RREC(),oDlg:End()} 

dbSelectArea("TMP")
dbGoTop()
oBrowse:Refresh()

@ 100, 004 SAY STR0106	OF oDlg PIXEL  //"Pesquisa por :"
@ 112, 004 SAY STR0107  OF oDlg PIXEL  //"Conteudo :"

@ 099,050 COMBOBOX oCbx VAR cVar ITEMS aIndice	SIZE 95, 8 OF oDlg PIXEL
@ 111,050 MSGET oPesquisa  VAR cPesquisa SIZE 095,8 PIXEL Of oDlg Valid QM230PESQUI(cPesquisa)

DEFINE SBUTTON oBtn1 FROM	4.0,210 TYPE	1	ACTION (nOpc := 1,QM230RREC(),oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON oBtn2 FROM  18.5,210 TYPE	2	ACTION (nOpc := 0,oDlg:End())	ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

oTmpTable:Delete()

Return(nOpc == 1)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QM230PESQUI ºAutor  ³Cleber Souza      º Data ³  05/17/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pesquisa o usuario na tela de consulta dos usuarios        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM230PESQUI(cPesquisa)

dbSelectArea("TMP")
dbSetOrder(1)
dbSeek(Alltrim(cPesquisa),.T.)
oBrowse:Refresh()

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QM230RREC ³ Autor ³Cleber L. Souza 		³ Data ³15/04/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza os campos de Responsaveis pela Saida do Instrum.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QM230RREC					     						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM230RREC() 

cResSai := TMP->QAA_MAT
cFilSai := TMP->QAA_FILIAL
cDepSai := TMP->QAA_CC          

cDesRS  := Posicione("QAA",1,cFilSai+cResSai,"Alltrim(QAA_NOME)")
cDesFS  := QA_CHKFIL(cFilSai,,.T.)    
DbSelectArea("SX2")
DbSetOrder(1)
if DbSeek("QAD")
	If FWModeAccess("QAD",1) == "C"
		cDesDS  := Posicione("QAD",1,xfilial("QAD")+cDepSai,"QAD_DESC")
	Else                                                                                                             
		cDesDS  := Posicione("QAD",1,cFilSai+cDepSai,"QAD_DESC")
	Endif                                                                          
Endif 

oResSai:Refresh()
oFilSai:Refresh()
oDepSai:Refresh()
oDesRS:Refresh()
oDesFS:Refresh()
oDesDS:Refresh()

Return    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QM230ValA ³ Autor ³Cleber L. Souza 		³ Data ³15/04/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validação do campo de Responsavel.						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QM230ValA					     						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo do Responsavel							  ³±±
±±³			 ³ EXPC2 = Filial do Responsavel							  ³±±
±±³			 ³ EXPC3 = Departamento do Responsavel						  ³±±
±±³			 ³ EXPO1 = Objeto do MsGet do Departamento					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = Confirmacao da Validacao							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QM230ValA(cResSai,cFilSai,cDepSai,oDepSai)

Local lRet    := .T.               
Local aArea   := GetArea()  
                
If lRet .and. !Empty(cResSai)
	If Alltrim(cFilSai)+Alltrim(cResSai) == Alltrim(cFilEnv)+Alltrim(cResEnv)
		Help("",1,"QM230017",,STR0137,1) //"Usuario destino igual ao usuario origem"
		lRet := .f.
	Endif

	If lRet
		dbSelectArea("QAA")
		dbSetOrder(1)
		If dbSeek(cFilSai+cResSai) 
	    	cDepSai:= QAA->QAA_CC 
	    	cDesRS := QAA->QAA_NOME
		DbSelectArea("SX2")
		DbSetOrder(1)
    	if DbSeek("QAD")
			If FWModeAccess("QAD",1) == "C"
				cDesDS  := Posicione("QAD",1,xfilial("QAD")+cDepSai,"QAD_DESC")
			Else                                                                                                             
				cDesDS  := Posicione("QAD",1,cFilSai+cDepSai,"QAD_DESC")
			Endif                                                                          
		Endif 

	    	oDepSai:Refresh()  
	    	oDesRS:Refresh()  
	    	oDesDS:Refresh()  
		Else               
			Messagedlg(STR0046)
		   //	Help("",1,"QM230003",,OemToAnsi(STR0046),1) //"Usuário não foi encontrado na filial selecionada !!"  
			lRet := .F.
		EndIF	
	Endif
EndIf	



RestArea(aArea)
	
Return(lRet)
      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QM230ValF ³ Autor ³Cleber L. Souza 		³ Data ³05/08/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validação da Filial do Responsavel.						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QM230ValA					     						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Filial do Respnsavel								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = Confirmacao da Validacao							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QM230ValF(cFilSai)
               
Local lRet  := .T.
Local aArea := SM0->(GetArea()) 

//Retirado para que possa ser possivel o emprestimo entre filiais. - DENIS
/*
If cFilSai == cFilAnt 
	Pergunte("QMT231",.t.)
	//Help("",1,"QM230015",,OemToAnsi(STR0111),1) //"A filial de destino nao pode ser a mesma da origem."
//	lRet := .F. 
EndIf                                                                                         
*/

//Caso o emprestimo seja da mesma filial, nao permitir a opcao "Calibracao"

/*
- comentei para poder tratar calibracao na mesma filial
nItem1 := 1
oRad1:nOption := 1
oRad2:nOption := 1

If cFilSai == cFilEnv
	oRad1:Disable() 
	oRad2:Disable()
Else
	oRad1:Enable()
	oRad2:Enable()
Endif
*/

oRad1:Refresh(.T.)
oRad2:Refresh(.T.)

If lRet
	Posicione("SM0",1,cEmpAnt+cFilSai,"M0_NOME")
	cDesFS := SM0->M0_FILIAL 
	If Empty(cDesFS)
	    QN5->(dbSetOrder(1))
    	QN5->(dbSeek(xFilial("QN5")))
		Return(.f.)	
	Endif
	oDesFS:Refresh()
EndIF

RestArea(aArea)

Return(lRet)

/*                                                                                                
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QM230CriaArq³ Autor ³Cleber L. Souza 		³ Data ³15/04/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gera Arquivos temporarios para os ListBox dos Instrumentos.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QM230CriaArq					     						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Responsavel pelo Envio							  ³±±
±±³			 ³ EXPC2 = Filial do Resp. Envio		  					  ³±±
±±³			 ³ EXPC3 = Depto do Resp. Envio			  					  ³±±
±±³			 ³ EXPC4 = Respnsavel pelo Recebimento	  					  ³±±
±±³			 ³ EXPC5 = Filial do Reso Recebimento	  					  ³±±
±±³			 ³ EXPC6 = Depto do Resp. Recebimento	  					  ³±±
±±³			 ³ EXPN1 = Tipo de Movimentacao			  					  ³±±
±±³			 ³ EXPN2 = Tipo de Devolucao			  					  ³±±
±±³			 ³ EXPD1 = Data da Devolução			  					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM230GrvAll(cResEnv,cFilEnv,cDepEnv,cResSai,cFilSai,cDepSai,nItem1,nItem2,cDesDe)   

Local nSeq   := 0 
Local aInstr := {}
Local lRet	 := .t.
Local cFamis := ""        
Local lGr5Fill := .F.                                  
Local cFilObr                                             
Local dDataDev
Local cResObr:= ""
Local cDepObr:= ""

dbSelectArea("TMP2")
TMP2->(dbGoTop())
While TMP2->(!EOF())

	//Caso seja movimentacao interna, grava tambem o QML
	If Alltrim(cFilSai) == Alltrim(cFilEnv)
		//Procurar pelo instrumento movimentado no QML, caso exista regravar o FLAGB
		//Busca pela ultima revisao da familia
		dbSelectArea("QM1")
		dbSetOrder(1)
		If !dbSeek(xFilial("QM1")+cFamis)
			MessageDlg(STR0120)//"Familia/Revisao nao cadastrada. Verifique as integridades de arquivos - Tabela QM1"
			lRet := .f.
		Endif
		
		//Bloqueio o Emprestimo para o Responsável pelo Instrumento
		If cResSai == QM2->QM2_RESP
			MessageDlg("Não é possivel re-emprestar o instrumento para o seu Responsável, use a opção de Devolução!")//"Não é  possivel re-emprestar o instrumento para o Responsável por ele use a Devolução!"
			TMP2->(dbSkip())
			Loop
		Endif
		
		If lRet
			cRvFam := QM1->QM1_REVTIP		
			//Garantir a validade de afericao do instrumento
		   /*	dbSelectArea("QM2")
			dbSetOrder(1)
			dbSeek(TR2->TR2_FILINS+TR2->TR2_INSTR+Inverte(TR2->TR2_REVINS))
			If mv_par02 == 1
				n_Freq := QM2->QM2_VALDAF - dDataBase
				If n_Freq < 0
					Help(" ",1,"QMTA160VLD",,QM2->QM2_INSTR,3,1) // A data de afericao vencera antes do retorno do Instrumento
				Endif	
			Else
				n_freq := mv_par01
			Endif	
            */
			dbSelectArea("QML")
			dbSetOrder(1)
			RecLock("QML",.T.)
			QML->QML_FILIAL := xFilial("QML")
			QML->QML_INSTR  := TMP2->TMP2_INSTR
			QML->QML_REVINS := TMP2->TMP2_REVIN
			QML->QML_TIPO   := TMP2->TMP2_TIPO
			QML->QML_REVTIP := cRvFam
			QML->QML_DTRET  := dDataBase
			QML->QML_HRRET  := Time()
			QML->QML_FILRET := cFilSai
			QML->QML_FILREL := cFilEnv
			QML->QML_RESRET := cResSai
			QML->QML_DEPTO  := cDepSai
			QML->QML_LOCAL  := QM2->QM2_DEPTO    
			QML->QML_DTLIM  := QM2->QM2_VALDAF
			QML->QML_FREQ   := n_Freq
			QML->QML_FLAGB  := "A"
			QML->QML_DTCOL  := dDataBase+n_Freq
			QML->QML_STATUS := cStatts
		Endif            

		/*
		// Segundo o Angelo é uma falha no sistema pois deixa o usuário alterar o cadastro de instrumentos
		// sem ser o responsável por ele.
		If lRet
			DbSelectArea("QM2")
			dbSetOrder(1)
			If dbSeek(xFilial()+TR2->TR2_INSTR+Inverte(TR2->TR2_REVINS))
				RecLock("QM2",.F.)
				QM2->QM2_DEPTO := cDepSai
				QM2->QM2_RESP  := cResSai
				QM2->QM2_LOCAL := mv_par03
				QM2->QM2_STATUS:= cStatts
				MsUnlock()
			Endif
		Endif
		*/
	Endif	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui Instrumento Disponivel do Departamento\Filial envio.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
    dbSelectArea("QN5")
    dbSetOrder(1)
    If dbSeek(xFilial("QN5")+TMP2->TMP2_INSTR+TMP2->TMP2_REVIN+TMP2->TMP2_FILIN)
    	cFilobr:= QN5->QN5_FILOBR
    	dDataDev:=QN5->QN5_DTADEV
    	If dbSeek(xFilial("QN4")+TMP2->TMP2_INSTR+TMP2->TMP2_REVIN+TMP2->TMP2_FILIN+"S")
	    	cResObr:=QN4->QN4_RESSAI
	    	cDepObr:= QN4->QN4_DEPRSA
	    Endif 
	    	
    	RecLock("QN5",.F.)
        dbDelete()
        MsUnlock()
    EndIF          
	
    lGr5Fill := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gera Instrum. Disponivel para Dep/Filial que esta recebendo.	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QN5")
    RecLock("QN5",.T.)
    QN5->QN5_FILIAL  := cFilSai     //cFilSai
   	QN5->QN5_INSTR   := TMP2->TMP2_INSTR
	QN5->QN5_REVINS  := TMP2->TMP2_REVIN
	QN5->QN5_FILINS  := TMP2->TMP2_FILIN
	QN5->QN5_TIPO    := TMP2->TMP2_TIPO
	QN5->QN5_TPDEV   := TMP2->TMP2_TPDEV
	QN5->QN5_STATUS  := "5"
	QN5->QN5_FILOBR  := Iif(TMP2->TMP2_TPDEV == "1",cFilEnv,cFilObr)
	QN5->QN5_DTADEV  := Iif(TMP2->TMP2_TPDEV == "1",CTOD("  /  /  "),dDataDev) 
	QN5->QN5_RESOBR  := Iif(TMP2->TMP2_TPDEV == "1",cResEnv,cResObr)
	QN5->QN5_DEPOBR  := Iif(TMP2->TMP2_TPDEV == "1",cDepEnv,cDepObr)
		
	If lGr5Fill
		QN5->QN5_ULFILL	:= cFilEnv
	Endif
	MsUnlock()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza historico da Movimentação.	 						 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dbSelectArea("QN4")
	dbSetOrder(1)
	If dbSeek(xFilial("QN4")+TMP2->TMP2_INSTR+TMP2->TMP2_REVIN+TMP2->TMP2_FILIN+"S")
		RecLock("QN4", .F. )
		QN4->QN4_ULTMOV	:= ""               
		nSeq            := Val(QN4->QN4_SEQUEN)
		MsUnlock()
	EndIf			
	
	RecLock("QN4", .T. )
	QN4->QN4_FILIAL  := cFilSai // Mantenho a regra da TAM
	QN4->QN4_INSTR   := TMP2->TMP2_INSTR
	QN4->QN4_REVINS  := TMP2->TMP2_REVIN
	QN4->QN4_FILINS  := TMP2->TMP2_FILIN
	QN4->QN4_TIPO    := TMP2->TMP2_TIPO
	QN4->QN4_DTASAI  := dDataBase
	QN4->QN4_HORSAI	 := Time()
	QN4->QN4_RESSAI	 := cResEnv
	QN4->QN4_FILRSA  := cFilEnv
	QN4->QN4_DEPRSA  := cDepEnv
	QN4->QN4_DTAENT	 := CTOD("  /  /  ")
	QN4->QN4_HORENT	 := Space(5)
	QN4->QN4_RESENT	 := cResSai
	QN4->QN4_FILREN  := cFilSai
	QN4->QN4_DEPREN	 := cDepSai
	QN4->QN4_TPMOV	 := Alltrim(Str(nItem1))
	QN4->QN4_TPDEV 	 := TMP2->TMP2_TPDEV
	QN4->QN4_ULTMOV	 := "S"
	QN4->QN4_SEQUEN	 := StrZero(nSeq+1,10)
	MsUnlock()

	AADD(aInstr,{TMP2->TMP2_INSTR,TMP2->TMP2_REVIN,TMP2->TMP2_FILIN,Posicione("QM2",1,Iif(lQM230Brow,TMP2->TMP2_INSTR,xFilial("QM2"))+TMP2->TMP2_INSTR+INVERTE(TMP2->TMP2_REVIN),"QM2_DESCR")})
	
	TMP2->(dbSkip())
	
EndDo           

QM230Email(Posicione("QAA",1,cFilEnv+cResEnv,"Alltrim(QAA_NOME)"),;
		   cFilEnv,;
		   cDepEnv+" - " +cdesDE,;
		   Posicione("QAA",1,cFilSai+cResSai,"Alltrim(QAA_EMAIL)"),;
		   Posicione("QAA",1,cFilSai+cResSai,"Alltrim(QAA_NOME)"),;
		   aInstr,;
		   STR0081 + IIF(QN4->QN4_TPMOV=="1",STR0082,STR0083),; //"Instrumentos Enviados para "###"Emprestimo"###"Calibração"
		   STR0084 + IIF(QN4->QN4_TPMOV=="1",STR0082,STR0083),; //"Segue relacao do instrumento(s) enviado(s) para "
		   Posicione("QAA",1,cFilSai+cResSai,"Alltrim(QAA_TPMAIL)"))
		
//Posiciona Instrumentos disponivels da filial corrente.
dbSelectArea("QN5")
dbSeek(xFilial("QN5"))

Return(Nil)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QM230VTOK³ Autor ³Cleber L. Souza 		³ Data ³15/04/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao da tela de Emprestimo de Instrumentos.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QM230VTOK					     						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Responsavel pelo envio							  ³±±
±±³			 ³ EXPC2 = Filial do Responsavel pelo envio					  ³±±
±±³			 ³ EXPC3 = Departamento do Responsavel pelo envio			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM230VTOK(cResEnv,cFilEnv,cDepEnv)

Local lRet := .T.
         
If Empty(cResSai) .or. Empty(cFilSai) .or. Empty(cDepSai) 
	Messagedlg(STR0047)
	//Help("",1,"QM230004",,OemToAnsi(STR0047),1) //"As Informações referentes ao responsavel pelo recebimento são obrigatorias!!" 
	lRet := .F.
EndIf

If lRet
	dbSelectArea("TMP2")
	dbGoTop()
	If TMP2->(EOF())
	     Messagedlg(STR0049)
		//Help("",1,"QM230006",,OemToAnsi(STR0049),1) //"Não foram selecionados itens para emprestimo ou calibracao."  
		lRet := .F.	
	EndIf
EndIf    

If lRet
	If (Alltrim(cResEnv)+Alltrim(cFilEnv)+Alltrim(cDepEnv)) == ;
	   (Alltrim(cResSai)+Alltrim(cFilSai)+Alltrim(cDepSai))
		Messagedlg(STR0050)
	   //	Help("",1,"QM230007",,OemToAnsi(STR0050),1) //"Não é permitido enviar instrumento para o mesmo Departamento e Filial." 
		lRet := .F.
    EndIf
EndIf

Return (lRet)   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QM230Aprov ³ Autor ³Cleber L. Souza 		³ Data ³15/04/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rotina de confirmação do Recebimento dos Instrumentos.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QM230Aprov					     						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM230Aprov() 

Local oDlgApr 
Local oRadio  
Local nOpcA    := 1
Local nItAprov := 1      

Local oResp
Local oFilRes
Local oDepto
Local oEmail
Local oJustif        
Local oGroupA
Local oGroupB

Local cResp
Local cFilRes
Local cDepto
Local cEmail
Local cJustif 

Local aColsAux := {}
Local aHeadAux := {} 
Local lFecha   := .F.
Local oBrw	   := GetObjBrow()	

Private hOk     := LoadBitmap(GetResources(),"LBOK")  //OK
Private hNo     := LoadBitmap(GetResources(),"LBNO")  //Nao OK 
Private oGetApr
Private lQM230Brow := ExistBlock("QM230BROW")

QM230Load(@aColsAux,@aHeadAux)
         
         
If Len(aColsAux) == 0
	Messagedlg(STR0105)
	//Help("",1,"QM230014",,OemToAnsi(STR0105),1) //"Nao existem equipamentos aguardando confirmação !!"	
    QN5->(dbSetOrder(1))
    QN5->(dbSeek(xFilial("QN5")))
 	If lQM230Brow
		ExecBlock("QM230BROW",.F.,.F.,{.T.,""})
	Endif 
	Return(.f.)
EndIf	
          
DEFINE MSDIALOG oDlgApr TITLE STR0051 From 54,000 To 520,650 OF GetWndDefault() PIXEL //"Confirmação dos Instrumentos Recebidos"
DEFINE FONT oFont  NAME "Arial" SIZE 0,-11 BOLD
DEFINE FONT oFont2 NAME "Arial" SIZE 0,-11 

@ 16 , 3 GROUP oGroupA TO 211,325 LABEL STR0051 OF oDlgApr PIXEL //"Confirmação dos Instrumentos Recebidos"
oGroupA:oFont:= oFont
oGetApr := MsNewGetDados():New(30,7,208,318,GD_UPDATE,,,"",,,,,,,oDlgApr,aHeadAux,aColsAux)

ACTIVATE MSDIALOG oDlgApr ON INIT (EnchoiceBar(oDlgApr,{||IIF(QM230TudOk(),(lFecha := .T.,;
QM230GRVAPR(),oDlgApr:End()),.f.)},{||lFecha := .T.,oDlgApr:End()})) VALID lFecha CENTERED

If lFecha
    QN5->(dbSetOrder(1))
   	QN5->(dbSeek(xFilial("QN5")))
	If lQM230Brow
		ExecBlock("QM230BROW",.F.,.F.,{.T.,""})
	Endif 
Endif

// Para atualizar o mBrowse customizado com arquivo de trabalho
If !lQm230Brow
	If oTmpTable3 <> NIL
		oTmpTable3:Delete()
	EndIf
	QMTA230TRB()
Endif

If ValType(oBrw) != "U"
	oBrw:GoTop()
	oBrw:Refresh()
EndIf

Return(Nil) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QM230Load³ Autor   ³Cleber L. Souza 		³ Data ³15/04/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta aHeader e aCols com os instrumentos para confirmacao ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QM230Load					     						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM230Load(aCols,aHeader)

Local cAlias
Local cQuery
Local cIndex
Local nY
Local cUsr      := QAXUser(__cUserId,5)

Private lQM230Brow := ExistBlock("QM230BROW")

//Monta aHeader    

//Aadd(aHeader,{STR0079,"OK1","@BMP",2,0,,"€€€€€€€€€€€€€€ ","C",,,,})
//Aadd(aHeader,{STR0080,"OK2","@BMP",2,0,,"€€€€€€€€€€€€€€ ","C",,,,})
			
//Dados padronizados da Getdados das Medicoes

//MsSeek("QN5_OK1") 
//Eval(bHeadMed)

//MsSeek("QN5_OK2") 
//Eval(bHeadMed)

Aadd(aHeader,Q230GetSX3("QN5_CONFIT", "", ""))//Confirmacao / Reprovacao
Aadd(aHeader,Q230GetSX3("QN5_INSTR", "", ""))//Instrumento
Aadd(aHeader,Q230GetSX3("QN5_REVINS", "", ""))//Revisao do Instrumento
Aadd(aHeader,Q230GetSX3("QN5_FILINS", "", ""))//Filial a que pertence o Instrumento
Aadd(aHeader,Q230GetSX3("QN5_TIPO", "", ""))//Filial a que pertence o Instrumento
Aadd(aHeader,Q230GetSX3("QN5_TPDEV", "", ""))//Tipo de devolucao do instrumento
Aadd(aHeader,Q230GetSX3("QN5_DTADEV", "", ""))//Data da devolucao do Instrumento      
Aadd(aHeader,{STR0052,"EMAIL","@!",100,0,,,"C",,,,})  //"Email Responsavel" 
Aadd(aHeader,{STR0053,"JUSTIFICA","@!",50,0,,,"M",,,,})  //"Justificativa" 

//MsSeek("QN5_ULFILL") 
//Eval(bHeadMed)    

//Monta dados da aCols

cAlias := "QN5TRB"
cQuery := "SELECT * "
cQuery += "FROM " + RetSqlName("QN5")+" QN5, "
cQuery += RetSqlName("QN4") + " QN4 " 
cQuery += "WHERE QN5.QN5_FILIAL = '"+xFilial("QN5")+"' AND "
cQuery += "QN5.QN5_STATUS = '5'  AND "
cQuery += "QN5.QN5_INSTR = QN4.QN4_INSTR AND "
cQuery += "QN5.QN5_REVINS = QN4.QN4_REVINS AND "
cQuery += "QN4.QN4_FILIAL = '"+ xFilial("QN4") + "' AND "
cQuery += "QN4.QN4_ULTMOV = 'S'  AND " 
If !lQM230Brow
    	cQuery += "QN4.QN4_RESENT = '"+cUsr+ "' AND "
EndIf
cQuery += "QN4.QN4_DTAENT = ' ' AND "
cQuery += "QN4.D_E_L_E_T_<> '*' AND " 
cQuery += "QN5.D_E_L_E_T_<> '*' "

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"QN5TRB", .F., .T.) 
TcSetField( "QN5TRB", "QN5_DTADEV", "D")

dbSelectArea(cAlias)
&(cAlias+"->(dbGoTop())")

While &(cAlias+"->(!EOF())") 

	//Posiciona arquivo de movimentação
	dbSelectArea("QN4")
	dbSetOrder(1)
	If dbSeek(xFilial("QN4")+&(cAlias+"->QN5_INSTR")+&(cAlias+"->QN5_REVINS")+&(cAlias+"->QN5_FILINS")+"S")   //dbSeek(&(cAlias+"->QN5_ULFILL")+&(cAlias+"->QN5_INSTR")+&(cAlias+"->QN5_REVINS")+&(cAlias+"->QN5_FILINS")+"S")

	    //Posiciona no cadastro do Funcionario
	    dbSelectArea("QAA")
	    dbSetOrder(1)
	    dbSeek(QN4->QN4_FILRSA+QN4->QN4_RESSAI)
	                    
		aadd(aCols,Array(Len(aHeader)+1))
		
		For nY:=1 to Len(aHeader)
		
		    If Substr(aHeader[nY,2],1,2) == "QN" //.and. Substr(aHeader[nY,2],1,6) <> "QN5_OK"
		    	aCols[Len(aCols),nY] := &(cAlias+"->"+Alltrim(aHeader[nY,2]))
	//	    ElseIf  Substr(aHeader[nY,2],1,6) == "QN5_OK"
	//	   		aCols[Len(aCols),nY] := hNo
		    ElseIf Alltrim(aHeader[nY,2]) == "EMAIL"                               
				aCols[Len(aCols),nY] := QAA->QAA_EMAIL
		    Else
		    	aCols[Len(aCols),nY] := Space(aHeader[nY,4])
		    EndIf	
	    
	    Next nY
		aCols[Len(aCols),Len(aHeader)+1] := .F.   
	Endif
		
	dbSelectArea(cAlias)
	dbSkip()
EndDo 
        
QN5TRB->(dbCloseArea())		

Return  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QM230ACEOK³ Autor ³Cleber L. Souza 		³ Data ³15/04/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza os BMPs de marcado e desmarcado.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QM230ACEOK					     						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM230ACEOK(nPos) 
   
//Local lAltera := .t.

If nPos==1
	If oGetApr:aCols[oGetApr:nAT,2] == hOk
		oGetApr:aCols[oGetApr:nAT,2] := hNo
		oGetApr:aCols[oGetApr:nAT,nPos] := hOk
	Else
		If oGetApr:aCols[oGetApr:nAT,nPos] == hOk
			oGetApr:aCols[oGetApr:nAT,nPos] := hNo
		Else 
			oGetApr:aCols[oGetApr:nAT,nPos] := hOk
		EndIF
	EndIf	
Else
	If oGetApr:aCols[oGetApr:nAT,1] == hOk
		oGetApr:aCols[oGetApr:nAT,1] := hNo
		oGetApr:aCols[oGetApr:nAT,nPos] := hOk
	Else
		If oGetApr:aCols[oGetApr:nAT,nPos] == hOk
			oGetApr:aCols[oGetApr:nAT,nPos] := hNo
		Else 
			oGetApr:aCols[oGetApr:nAT,nPos] := hOk
		EndIf	
	EndIF	
EndIf                            
oGetApr:Refresh()                                       

Return(Nil)  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QM230TudOk³ Autor ³Cleber L. Souza 		³ Data ³15/04/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao Geral da tela de confirmacao de instrumentos.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QM230TudOk					     						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM230TudOk()
           
Local lRet     := .T.
Local nY       := 1               
Local nPosJus  := Ascan(oGetApr:aHeader,{|x|Alltrim(x[2])=="JUSTIFICA"})
Local nPosEma  := Ascan(oGetApr:aHeader,{|x|Alltrim(x[2])=="EMAIL"})
Local nPosIns  := Ascan(oGetApr:aHeader,{|x|Alltrim(x[2])=="QN5_INSTR"})
Local nPosTdev := Ascan(oGetApr:aHeader,{|x|Alltrim(x[2])=="QN5_TPDEV"})
Local nPosDdev := Ascan(oGetApr:aHeader,{|x|Alltrim(x[2])=="QN5_DTADEV"})
Local nPosCfIn := Ascan(oGetApr:aHeader,{|x|Alltrim(x[2])=="QN5_CONFIT"})

For nY:=1 to Len(oGetApr:aCols)
	If 	(oGetApr:aCols[nY,nPosTdev] == "1" .AND. Empty(oGetApr:aCols[nY,nPosDdev]) .AND. oGetApr:aCols[nY,nPosCfIn] == "1")// Se o tipo de emprestimo for calibracao obrigatoria verificar 
		Help("",1,"QM230016")//,,OemToAnsi(STR0112)+Alltrim(oGetApr:aCols[nY,nPosINs])+".",2)//"Favor informar a data de devolução do instrumento "
		lRet := .F.	
		Exit
	ElseIf (oGetApr:aCols[nY,nPosTdev] == "1" .AND. !Empty(oGetApr:aCols[nY,nPosDdev]) .AND. oGetApr:aCols[nY,nPosCfIn] == "1") .AND. (oGetApr:aCols[nY,nPosDdev] < dDataBase)  //Se a data estiver preenchida eu valido ela
		MsgAlert("ATENCAO: Data(s) invalida(s) informada!")	
		lRet := .F.	
		Exit
	Endif
/*	
	If (Empty(oGetApr:aCols[nY,nPosJus]) .OR. Empty(oGetApr:aCols[nY,nPosEma])) .AND. Empty(oGetApr:aCols[nY,nPosCfIn])//.AND. oGetApr:aCols[nY,2]==hOK
//		Help("",1,"QM230008",,OemToAnsi( STR0054 + Alltrim(oGetApr:aCols[nY,nPosINs]) + STR0055),1)//"O Instrumento " ### " esta reprovado e não possui Email e/ou Justificativa da reprovação." 
		MessageDlg("ATENCAO: Existe(m) instrumento(s) que nao foi/foram confirmado(s) ou rejeitado(s) !",,3)
//		lRet := .F. 
//		Exit
	EndIf  
*/	                                                                  
	If 	( oGetApr:aCols[nY,nPosCfIn] == "2" .AND. Empty(oGetApr:aCols[nY,nPosJus]) )//.and. Empty(oGetApr:aCols[nY,nPosEma]))
		MessageDlg(STR0121+Alltrim(oGetApr:aCols[nY,nPosINs])+".",,3)//"Favor verificar falta de justificativa para o instrumento "
//		Help("",1,"QM230016",,OemToAnsi(STR0112)+Alltrim(oGetApr:aCols[nY,nPosINs])+".",1)//"Favor informar a data de devolução do instrumento "
		lRet := .F. 
		Exit
	EndIF

	If  (oGetApr:aCols[nY,nPosCfIn] == "2" .AND. Empty(oGetApr:aCols[nY,nPosEma]))
		MessageDlg(STR0122+Alltrim(oGetApr:aCols[nY,nPosINs])+".",,3)
//		Help("",1,"QM230016",,OemToAnsi(STR0112)+Alltrim(oGetApr:aCols[nY,nPosINs])+".",1)//"Favor informar a data de devolução do instrumento "
		lRet := .F. 
		Exit
	EndIF

	
Next nY

If lRet
	dbSelectArea("QAA")
	dbSetOrder(6)	
	If !QAA->(DbSeek(TRIM(UPPER(cUserName))))
		Messagedlg(STR0056)
		//Help("",1,"QM230011",,OemToAnsi(STR0056),1) //"Usuario logado nao esta cadastrado como usuario, favor atualizar informações !!" 
		lRet  := .F. 
	EndIf
EndIf

If lRet
	If Alltrim(QAA->QAA_FILIAL)<>Alltrim(SM0->M0_CODFIL)
		Messagedlg(STR0057)
		//Help("",1,"QM230012",,OemToAnsi(STR0057),1) //"Usuario não esta cadastrado como responsavel para essa filial !!"
		lRet  := .F. 
	EndIF
EndIf 

Return(lRet)  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QM230GRVAPR³ Autor ³Cleber L. Souza 		³ Data ³15/04/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rotina de gravação da rotina de Confirmacao.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QM230GRVAPR					     						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM230GRVAPR()

Local nY := 0
Local nPosCfIn := Ascan(oGetApr:aHeader,{|x|Alltrim(x[2])=="QN5_CONFIT"})
Local nPosIns  := Ascan(oGetApr:aHeader,{|x|Alltrim(x[2])=="QN5_INSTR"})
Local nPosRIn  := Ascan(oGetApr:aHeader,{|x|Alltrim(x[2])=="QN5_REVINS"})
Local nPosFIn  := Ascan(oGetApr:aHeader,{|x|Alltrim(x[2])=="QN5_FILINS"})
Local nPosTip  := Ascan(oGetApr:aHeader,{|x|Alltrim(x[2])=="QN5_TIPO"})
Local nPosJus  := Ascan(oGetApr:aHeader,{|x|Alltrim(x[2])=="JUSTIFICA"})
Local nPosEma  := Ascan(oGetApr:aHeader,{|x|Alltrim(x[2])=="EMAIL"}) 
Local nPosTdev := Ascan(oGetApr:aHeader,{|x|Alltrim(x[2])=="QN5_TPDEV"})
Local nPosDdev := Ascan(oGetApr:aHeader,{|x|Alltrim(x[2])=="QN5_DTADEV"}) 
Local nPosFil5 := Ascan(oGetApr:aHeader,{|x|Alltrim(x[2])=="QN5_ULFILL"})
Local cStatus  := ""
Local cResSai  := ""
Local cFilSai  := ""
Local cDepSai  := ""  
Local aInstr   := {}  
Local cMsg     := ""
Local nSeq     := 0                
Local cfilObr:= ""
Local cResObr:= ""
Local cDepObr:=""
Local cVarPesq := ""
Local cVarPsq1 :=""
Local cVarPsq2 :=""
Local cVarPsq3 :=""

 
For nY:=1 to Len(oGetApr:aCols)           
	
	If oGetApr:aCols[nY,1] == "1" //hOk
		//Recebimento do Instrumento - Aprovado.
		
		//If Empty(oGetApr:aCols[nY,nPosFil5])
		//	oGetApr:aCols[nY,nPosFil5] := xFilial("QN4")					
		//Endif                       
		DbSelectArea("QN5")
		DbSetOrder(1)    
		cVarPesq := oGetApr:aCols[nY,nPosIns]+oGetApr:aCols[nY,nPosRIn]+oGetApr:aCols[nY,nPosFIn]  	
	
		if DbSeek(XFILIAL("QN5")+cVarPesq)
			               
			//Posiciona QN4 - Movimentacao do Instrumento
			dbSelectArea("QN4")	
			dbSetOrder(1)
			if dbSeek(xFilial("QN4")+cVarPesq+"S")		        
	//		If dbSeek(oGetApr:aCols[nY,nPosFIn]+oGetApr:aCols[nY,nPosIns]+oGetApr:aCols[nY,nPosRIn]+oGetApr:aCols[nY,nPosFIn]+"S")		        
	        	
	    		//Atualiza Hora e Data da Entrada
	    		RecLock("QN4",.F.)
	    		QN4->QN4_FILIAL := xFilial("QN4") 
	    		QN4->QN4_HORENT := TIME()
		   		QN4->QN4_DTAENT := dDataBase
		   		If !Empty(oGetApr:aCols[nY,nPosJus])
					MSMM(QN4->QN4_CODJUS,,,oGetApr:aCols[nY,nPosJus],1,,,"QN4","QN4_CODJUS")
				Endif
		   		MsUnlock()
	
			    //Processa Status do Instrumento.
			    If QN4->QN4_TPMOV == "2"
			    	cStatus := "4" 
			    Else
			    	If QN4->QN4_TPDEV == "1"
						If Alltrim(SM0->M0_CODFIL) == Alltrim(QN4->QN4_FILINS)
					    	cStatus := "6"             
					    Else	
					    	cStatus := "3" 			    	
					    Endif	
	    			Else
	    				If Alltrim(SM0->M0_CODFIL) == Alltrim(QN4->QN4_FILINS) .AND. QN4->QN4_RESENT == Posicione("QM2",1,Iif(FwModeAccess("QM2")=="E",QN4->QN4_FILINS,xFilial("QM2"))+QN4->QN4_INSTR,"QM2_RESP")//!Empty(AllTrim(xFilial("QM2"))),QN4->QN4_FILINS,xFilial("QM2"))+QN4->QN4_INSTR,"QM2_RESP")
	    					cStatus := "1" 
						ElseIf Alltrim(SM0->M0_CODFIL) == Alltrim(QN4->QN4_FILINS) 
	    					cStatus := "6" 
	    			    Else 
	    			    	cStatus := "2" 
	    			    EndIF
	    			EndIf
	    		EndIf	                 
	    		                  
				//Posiciona QN5 - Instrumentos Disponiveis
				dbSelectArea("QN5")	
				dbSetOrder(1)
				cVarPesq := oGetApr:aCols[nY,nPosIns]+oGetApr:aCols[nY,nPosRIn]+oGetApr:aCols[nY,nPosFIn]  	
	            
				If dbSeek(xFilial("QN5")+cVarPesq)
		    		RecLock("QN5",.F.)
	    			QN5->QN5_FILIAL := xFilial("QN5")
	    			QN5->QN5_STATUS := cStatus
	    			QN5->QN5_DTADEV := oGetApr:aCols[nY,nPosDdev]
	    			QN5->QN5_CONFIT	 := oGetApr:aCols[nY,nPosCfIn]
		   			MsUnlock()       
		   		Endif	
		   		
		   		If cStatus == "4"
		   			If MsgYesNo(OemToAnsi( STR0058 + Alltrim(oGetApr:aCols[nY,nPosIns])+;  //"Deseja Realizar a Calibração do Instrumento :"
		   							       STR0059 + oGetApr:aCols[nY,nPosRIn] + STR0060 + ;  //" - Revisão: " ### " pertencente a filial :"
		   							       oGetApr:aCols[nY,nPosFIn] ),OemToAnsi(STR0061)) //"Atenção"
						QM230Calib()	
					EndIf
				EndIF
				
			EndIf	
	Endif
	
	ElseIf oGetApr:aCols[nY,1] == "2"
		//If  oGetApr:aCols[nY,2] == hOk
		//Recebimento do Instrumento Reprovado.
        
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8¿
		//³Carrega dos dados do Responsavel pelo envio.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8Ù
		dbSelectArea("QAA")
		dbSetOrder(6)
		If !QAA->(DbSeek(TRIM(UPPER(cUserName))))
			MsgAlert(STR0062) //"Usuario logado nao esta cadastrado como usuario, favor atualizar informações !!"
			Loop 
		EndIf
        
		//Posiciona QN5 - Instrumentos Disponiveis
		dbSelectArea("QN5")	
		dbSetOrder(1)
		cVarPesq := oGetApr:aCols[nY,nPosIns]+oGetApr:aCols[nY,nPosRIn]+oGetApr:aCols[nY,nPosFIn]  	
		
		if dbSeek(xFilial("QN5")+cVarPesq)
				cResObr         := QN5->QN5_RESOBR
				cFilObr			:= QN5->QN5_FILOBR
				cDepObr			:= QN5->QN5_DEPOBR
			
	    	/*dbSelectArea("QN4")	
			dbSetOrder(1)
			if dbSeek(	QN5->QN5_ULFILL+oGetApr:aCols[nY,nPosIns]+oGetApr:aCols[nY,nPosRIn]+oGetApr:aCols[nY,nPosFIn]+"S")		
			//Verifica se o instrumento eh fruto de outra reprovação.
	       		If SM0->M0_CODFIL == QN5->QN5_FILINS
					MsgAlert(STR0108 + Alltrim(QN5->QN5_INSTR) + STR0109 + " Contate o responsável pelo empréstimo " + posicione("QAA",1,xfilial("QAA")+QN4->QN4_RESSAI,"QAA_NOME")) // "O Instrumento " ###" nao pode ser reprovado pois pertence a essa filial." 
					Loop 
				EndIf
			Endif*/
			//Posiciona QN4 - Movimentacao do Instrumento
			dbSelectArea("QN4")	
			dbSetOrder(1)
			If dbSeek(xFilial("QN4")+cVarPesq+"S")		        
				cResSai         := QN4->QN4_RESSAI
				cFilSai			:= QN4->QN4_FILRSA
				cDepSai			:= QN4->QN4_DEPRSA 
				//ver se funciona pois na rejeiçãpo da devolução não esta  levando a devolução obrigatória
				cTpMov          := QN4->QN4_TPMOV
				cTPDev          := QN4->QN4_TPDEV
				cDatDev         := DTOC(QN4->QN4_DTADEV) // ALTERAR 
	            
				cStatus := "5"
	        	
	        	//Atualiza Hora e Data da Entrada
	    		RecLock("QN4",.F.)
	    		QN4->QN4_HORENT := TIME()
		   		QN4->QN4_DTAENT := dDataBase
		   		QN4->QN4_ULTMOV := " "  
		   		nSeq            := Val(QN4->QN4_SEQUEN)
		   		MsUnlock()
			
	        	//Movimentação de Devolução do Instrumento
	        	RecLock("QN4", .T. )
				QN4->QN4_FILIAL  := cFilSai //QN5->QN5_ULFILL
				QN4->QN4_INSTR   := oGetApr:aCols[nY,nPosIns] 
				QN4->QN4_REVINS  := oGetApr:aCols[nY,nPosRIn] 
				QN4->QN4_FILINS  := oGetApr:aCols[nY,nPosFIn]
				QN4->QN4_TIPO    := oGetApr:aCols[nY,nPosTIp]
	 			QN4->QN4_DTASAI  := dDataBase
				QN4->QN4_HORSAI	 := Time()
				QN4->QN4_RESSAI	 := QAA->QAA_MAT
				QN4->QN4_FILRSA  := QAA->QAA_FILIAL
				QN4->QN4_DEPRSA  := QAA->QAA_CC
				QN4->QN4_DTAENT	 := dDataBase
				QN4->QN4_HORENT	 := Time()
				QN4->QN4_RESENT	 := cResSai
				QN4->QN4_FILREN  := cFilSai
				QN4->QN4_DEPREN	 := cDepSai
				QN4->QN4_TPMOV	 := cTpMov //"1"
				QN4->QN4_TPDEV 	 := cTPDev //"2"
				QN4->QN4_DTADEV	 := CTOD(cDatDev) //CTOD("  /  /  ") // ALTERAR 
				QN4->QN4_ULTMOV	 := "S" 
				QN4->QN4_SEQUEN  := StrZero(nSeq+1,10)
				If !Empty(oGetApr:aCols[nY,nPosJus])
					MSMM(QN4->QN4_CODJUS,,,oGetApr:aCols[nY,nPosJus],1,,,"QN4","QN4_CODJUS")
				Endif
				MsUnlock()                                
				
				//Posiciona QN5 - Instrumentos Disponiveis
				dbSelectArea("QN5")	
				dbSetOrder(1)
				cVarPesq := oGetApr:aCols[nY,nPosIns]+oGetApr:aCols[nY,nPosRIn]+oGetApr:aCols[nY,nPosFIn]  	
	            
				If dbSeek(xFilial("QN5")+cVarPesq)
					RecLock("QN5",.F.)
					dbDelete()
					MsUnlock()
	            Endif
	            //Cria Intrumento Disponivel na filial que foi feita a devolução
		        RecLock("QN5",.T.) 
		        QN5->QN5_FILIAL  := cFilSai
		        QN5->QN5_CONFIT	 := oGetApr:aCols[nY,nPosCfIn]
	   			QN5->QN5_INSTR   := oGetApr:aCols[nY,nPosIns]
				QN5->QN5_REVINS  := oGetApr:aCols[nY,nPosRIn]
				QN5->QN5_FILINS  := oGetApr:aCols[nY,nPosFIn]
				QN5->QN5_TIPO    := oGetApr:aCols[nY,nPosTip]
				QN5->QN5_TPDEV   := "2"
				QN5->QN5_DTADEV  := CTOD("  /  /  ")
				QN5->QN5_STATUS  := cStatus                                             
				QN5->QN5_ULFILL  := QN4->QN4_FILRSA 
				QN5->QN5_FILOBR  := cFilObr
				QN5->QN5_RESOBR  := cResObr
				QN5->QN5_DEPOBR  := cDepObr  
			    MsUnlock() 
			    
			   	AADD(aInstr,{cVarPsq1:=oGetApr:aCols[nY,nPosIns],cVarPsq2:=oGetApr:aCols[nY,nPosRIn],; 
			             	 cVarPsq3:=oGetApr:aCols[nY,nPosFIn],Posicione("QM2",1,Iif(lQM230Brow,cVarPsq3,xFilial("QM2"))+cVarPsq1+INVERTE(cVarPsq2),"QM2_DESCR")})
			                                                   //Posicione("QM2",1,oGetApr:aCols[nY,nPosFIn]+oGetApr:aCols[nY,nPosIns],"QM2_DESCR")})
			    
			    cMsg := STR0085+CHR(13)+CHR(10)+CHR(13)+CHR(10) //"Instrumentos Devolvidos por Motivo de Reprovação"
			    cMsg += STR0066+CHR(13)+CHR(10)
			    cMsg += oGetApr:aCols[nY,nPosJus]+CHR(13)+CHR(10)+CHR(13)+CHR(10)
			    cMsg += STR0086    //"Segue relacao do instrumento(s) devolvidos(s) : "

				QM230Email(Posicione("QAA",1,QN4->QN4_FILRSA+QN4->QN4_RESSAI,"Alltrim(QAA_NOME)"),;
						   QN4->QN4_FILRSA,;
       					   Alltrim(QN4->QN4_DEPRSA)+" - "+Posicione("QAD",1,QN4->QN4_FILRSA+QN4->QN4_DEPRSA,"QAD_DESC"),;
						   IIf(Empty(oGetApr:aCols[nY,nPosEma]), Posicione("QAA",1,QN4->QN4_FILREN+QN4->QN4_RESENT,"Alltrim(QAA_EMAIL)"), oGetApr:aCols[nY,nPosEma]),;
						   Posicione("QAA",1,QN4->QN4_FILREN+QN4->QN4_RESENT,"Alltrim(QAA_NOME)"),;
						   aInstr,;
						   STR0085,; //"Instrumentos Devolvidos por Motivo de Reprovação"
    					   cMsg,;
						   Posicione("QAA",1,QN4->QN4_FILREN+QN4->QN4_RESENT,"QAA_TPMAIL"))
			Endif
        EndIf
	EndIf
	
Next nY           

//Posiciona Instrumentos disponivels da filial corrente.
dbSelectArea("QN5")
dbSeek(xFilial("QN5"))
     
Return(Nil)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QM230Devol ³ Autor ³Cleber L. Souza 		³ Data ³15/04/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rotina de Devolução Rapida do Instrumento.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QM230Devol					     						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM230Devol()
                      
Local oDlgDev 
Local oMark 
Local oGroupA         
Local oFilDev  
Local oDesFil 
Local nOpcA    := 0
Local aStru    := {} 
Local aCpos    := {} 
Local cArqTrab := ""   
Local lInverte := .F.
Local cMarca   := GetMark()
Local cDesFil  := Space(30)
Local oBrw	   := GetObjBrow()
Local oTmpTable := NIL
Private cFilDev:= Space(TAMSX3("QN5_FILIAL")[1])   
Private aNecCa := {}
Private lQM230Brow := ExistBlock("QM230BROW")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8¿
//³Carrega dos dados do Responsavel pelo envio.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8Ù
dbSelectArea("QAA")
dbSetOrder(6)
If !QAA->(DbSeek(TRIM(UPPER(cUserName))))  
	Messagedlg(STR0068)
	//Help("",1,"QM230009",,OemToAnsi(STR0068),1)  //"Usuario logado nao esta cadastrado como responsavel, favor atualizar informações !!"
	Return()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo de Trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd( aStru,{ "TB_OK"   	, 	"C",02,0} )
Aadd( aStru,{ "TB_FILINS"	,	"C",TamSX3("QN5_FILINS")[1],0} )
Aadd( aStru,{ "TB_DESFIL"	,	"C",25,0} )
Aadd( aStru,{ "TB_INSTR"	,	"C",TamSX3("QN5_INSTR")[1],0} )
Aadd( aStru,{ "TB_REVINS"	,	"C",TamSX3("QN5_REVINS")[1],0} )
Aadd( aStru,{ "TB_TIPO" 	,	"C",TamSX3("QN5_TIPO")[1],0} )
Aadd( aStru,{ "TB_RESSAI" 	,	"C",TamSX3("QN4_RESSAI")[1],0} )
Aadd( aStru,{ "TB_DESRES" 	,	"C",25,0} )

oTmpTable := FWTemporaryTable():New( "TRB1" )
oTmpTable:SetFields( aStru )
oTmpTable:AddIndex("indice1", {"TB_FILINS","TB_RESSAI","TB_INSTR"} )
oTmpTable:Create()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Redefinicao do aCpos para utilizar no MarkBrow               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCpos := {{"TB_OK"		,"",OemToAnsi("Ok")},;
		  {"TB_FILINS"  ,"",OemToAnsi(STR0038)},; //"Filial"
		  {"TB_DESFIL"  ,"",OemToAnsi(STR0113)},; //"Descricao"
		  {"TB_INSTR"   ,"",OemToAnsi(STR0036)},; //"Instrumento"
		  {"TB_REVINS"  ,"",OemToAnsi(STR0089)},; //"Revisao"
		  {"TB_TIPO"    ,"",OemToAnsi(STR0078)},; //"Familia"
		  {"TB_RESSAI"  ,"",OemToAnsi(STR0114)},; //"Responsavel"
		  {"TB_DESRES"  ,"",OemToAnsi(STR0115)}}  //"Nome"
		  
DEFINE MSDIALOG oDlgDev TITLE OemToAnsi(STR0116) From 54,000 To 520,650 OF GetWndDefault() PIXEL  //"Devolução dos Instrumentos"
DEFINE FONT oFont  NAME "Arial" SIZE 0,-11 BOLD
DEFINE FONT oFont2 NAME "Arial" SIZE 0,-11 

@ 19,7   SAY OemToAnsi(STR0117) OF oDlgDev PIXEL SIZE 70,009 FONT oFont //"Selecione a Filial : "
@ 18,65  MSGET oFilDev VAR cFilDev PICTURE "@!" F3 "SM0" SIZE 52,8 OF oDlgDev PIXEL Valid QM230CrDev(cFilDev,@oMark,@oDesFil,@CDesFil)   
@ 18,122 MSGET oDesFil VAR cDesFil PICTURE "@!" SIZE 120,8 OF oDlgDev PIXEL When .F.

@ 36 ,3   GROUP oGroupA TO 211,325 LABEL OemToAnsi(STR0116) OF oDlgDev PIXEL  //"Devolução dos Instrumentos"
oGroupA:oFont:= oFont                        
oMark := MsSelect():New("TRB1","TB_OK",,aCpos,lInverte,cMarca,{45,7,208,318})

ACTIVATE MSDIALOG oDlgDev ON INIT (EnchoiceBar(oDlgDev,{||nOpcA:=1,oDlgDev:End()},{||nOpcA:=0,oDlgDev:End()})) CENTERED

If nOpcA==1
	QM230GrvDev()
EndIF


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta Arquivo Temporario                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTmpTable:Delete()

QN5->(dbSetOrder(1))
QN5->(dbSeek(xFilial("QN5")))
		  
// Para atualizar o mBrowse customizado com arquivo de trabalho
If !lQm230Brow
	If oTmpTable3 <> NIL
		oTmpTable3:Delete()
	EndIf
	QMTA230TRB()
Endif

If ValType(oBrw) != "U"
	oBrw:GoTop()
	oBrw:Refresh()
EndIf
		  
Return()  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QM230CrDev³ Autor ³Cleber L. Souza 		³ Data ³06/08/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rotina Carga dos Instrumentos para Devolução.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QM230Devol					     						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Filial do Instrumento a ser devolvido.			  ³±±
±±³			 ³ EXPO1 = Objeto com os Objetos.							  ³±±
±±³			 ³ EXPO2 = Objeto Get com a descricao da filial do Instrumento³±±
±±³			 ³ EXPC2 = Descricao da filial do Instrumento.	    		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM230CrDev(cFilDev,oMark,oDesFil,cDesFil)
Local lTins  := .F.                    
Local lJaPer := .F.
Local lNecCa := .F.
Local lQM230DVOL := ExistBlock("QM230DVOL")
Private lDevoc := .T.

dbSelectArea("TRB1")
dbGoTop()
If TRB1->(!eof())
	While TRB1->(!eof())
    	RecLock("TRB1",.F.)
		dbDelete()
		MsUnlock()
 		TRB1->(dbSkip())
    EndDo
EndIf

//Se a filial de devolucao for a mesma da filial logada.
//If cFilDev == cFilAnt
//	Pergunte("QMT232",.t.)
//	dbSelectArea("QML")
//Endif

dbSelectArea("QN5")
dbSetOrder(2)
dbSeek(xFilial("QN5"),.t.)
dbGoTop()
While QN5->(!EOF())  
      
    If (Alltrim(QN5->QN5_FILIAL) == Alltrim(cfilAnt) .and. (Alltrim(QN5->QN5_FILOBR) == Alltrim(cFildev);
      .OR.  (EMPTY(QN5->QN5_FILOBR) .AND. Alltrim(QN5->QN5_ULFILL) == Alltrim(cFildev))))
	    If QN5->QN5_STATUS $("3/2/4/6") 
			If Alltrim(QN5->QN5_STATUS) == "4"
				lNecCa := .T.
				If !lJaPer 
					If MsgYesNo(STR0124)  //"Existe(m) instrumento(s) a calibrar, deseja devolve-lo(s) sem calibracao ?"
						lTIns := .T.
					Endif
				Endif	   
				lJaPer := .t.
			Endif    
	    
	    	If lTins .or. QN5->QN5_STATUS $("3/2/6")
		    	dbSelectArea("QN4")
				dbSetOrder(1)
				If dbSeek(xFilial("QN4")+QN5->QN5_INSTR+QN5->QN5_REVINS+QN5->QN5_FILINS)//+"S")
	//			  	If QN4->QN4_FILINS == cFilDev
						If lQM230DVOL
							lDevoc := ExecBlock("QM230DVOL",.F.,.F.,{QN5->QN5_INSTR,QN5->QN5_REVINS,QN4->QN4_FILRSA,QN4->QN4_RESSAI,QN4->QN4_DEPRSA,QN4->QN4_FILREN,QN4->QN4_RESENT,QN4->QN4_DEPREN})			
			            Endif
		                
						If lNecCa
							Aadd(aNecCa,{QN5->QN5_INSTR,QN5->QN5_REVINS})
						Endif
						
						If lDevoc
						    dbSelectArea("QN4")
				            dbSetOrder(1)
				          If dbSeek(xFilial("QN4")+QN5->QN5_INSTR+QN5->QN5_REVINS+QN5->QN5_FILINS+"S")
						    dbSelectArea("TRB1")
				   		    RecLock("TRB1",.t.)
							TB_FILINS := QN5->QN5_FILINS
							TB_DESFIL := QA_CHKFIL(QN5->QN5_FILINS,,.T.)
							TB_INSTR  := QN5->QN5_INSTR
							TB_REVINS := QN5->QN5_REVINS
							TB_TIPO   := QN5->QN5_TIPO  
							TB_RESSAI := QN4->QN4_RESSAI
							TB_DESRES := Posicione("QAA",1,QN4->QN4_FILRSA+QN4->QN4_RESSAI,"Alltrim(QAA_NOME)")
				   		    MsUnlock()
				   		  Endif  
			   		    Endif 
//		   		    Endif
		    	EndIF
	    	Endif
	    EndIf
	Endif
	lNecCa := .F.    
	
	QN5->(dbSkip())
EndDo

TRB1->(dbGoTop()) 
cDesFil := QA_CHKFIL(cFilDev,,.T.)
oDesFil:Refresh()
oMark:oBrowse:Refresh()

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QM230GrvDev³ Autor ³Cleber L. Souza 		³ Data ³06/08/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rotina de Gravação da Devolução do Instrumento.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QM230GrvDev()				     						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM230GrvDev()

Local cResSai  := ""
Local cFilSai  := ""
Local cDepSai  := ""   
Local nSeq     := 0 
Local aInstr   := {}      
//Local lAltLoc  := GetMV("MV_QMLTLOC",.F.,"1") == "1" 
Local cDeppt   := ""
Local cRespt   := ""    
Local cResAnt  := ""
Local cFilQN4  := "" 
Local lQMT160BX := ExistBlock("QMT160BX")

TRB1->(dbGoTop())

While TRB1->(!EOF())
	If !Empty(TRB1->TB_OK)
		//Posiciona QN5 - Movimentacao do Instrumento
		dbSelectArea("QN5")
		dbSetOrder(1)
		If dbSeek(xFilial("QN5")+TRB1->TB_INSTR+TRB1->TB_REVINS+TRB1->TB_FILINS)
			If FwModeAccess("QN5")=="E" .AND. !EMPTY(QN5->QN5_FILOBR) .AND. QN5->QN5_TPDEV == '2'
				cResSai         := QN5->QN5_RESOBR
				cFilSai			:= QN5->QN5_FILOBR
				cDepSai			:= QN5->QN5_DEPOBR
			Else
			//Posiciona QN4 - Movimentacao do Instrumento
				dbSelectArea("QN4")
				dbSetOrder(1)
				If dbSeek(xFilial("QN4")+QN5->QN5_INSTR+QN5->QN5_REVINS+QN5->QN5_FILINS+"S")
					
						cResSai         := QN4->QN4_RESSAI
						cFilSai			:= QN4->QN4_FILRSA
						cDepSai			:= QN4->QN4_DEPRSA 
					
				Endif	
			Endif	                                      
			Dbselectarea("QAA")                                              
			dbsetorder(6)
			If QAA->(DbSeek(TRIM(UPPER(cUserName))))
				DbSelectArea("QN4")
				dbSetOrder(1)  
			
				If dbSeek(xFilial("QN4")+QN5->QN5_INSTR+QN5->QN5_REVINS+QN5->QN5_FILINS+"S")
					RecLock("QN4",.F.)
					QN4->QN4_ULTMOV := " "
					nSeq            := Val(QN4->QN4_SEQUEN)
					MsUnlock()
				Endif
				
					
					//Movimentação de Devolução do Instrumento
					RecLock("QN4", .T. )
					QN4->QN4_FILIAL  := cFilSai  //xFilial("QN4")
					QN4->QN4_INSTR   := QN5->QN5_INSTR
					QN4->QN4_REVINS  := QN5->QN5_REVINS
					QN4->QN4_FILINS  := QN5->QN5_FILINS
					QN4->QN4_TIPO    := QN5->QN5_TIPO
					QN4->QN4_DTASAI  := dDataBase
					QN4->QN4_HORSAI	 := Time()
					QN4->QN4_RESSAI	 := QAA->QAA_MAT
					QN4->QN4_FILRSA  := QAA->QAA_FILIAL
					QN4->QN4_DEPRSA  := QAA->QAA_CC
					QN4->QN4_RESENT	 := cResSai
					QN4->QN4_FILREN  := cFilSai
					QN4->QN4_DEPREN	 := cDepSai
					QN4->QN4_TPMOV	 := "1"
					QN4->QN4_TPDEV 	 := "2"
					QN4->QN4_DTADEV	 := CTOD("  /  /  ")
					QN4->QN4_ULTMOV	 := "S"
					QN4->QN4_SEQUEN  := StrZero(nSeq+1,10)
					MsUnlock()
					
					//Posiciona QN5 - Instrumentos Disponiveis
					dbSelectArea("QN5")
					culfill:=QN5->QN5_ULFILL
					RecLock("QN5",.F.)
					
					dbDelete()
					MsUnlock()
					
					//Cria Intrumento Disponivel na filial que foi feita a devolução
					RecLock("QN5",.T.)
					QN5->QN5_FILIAL  := cFilSai
					QN5->QN5_INSTR   := QN4->QN4_INSTR
					QN5->QN5_REVINS  := QN4->QN4_REVINS
					QN5->QN5_FILINS  := QN4->QN4_FILINS
					QN5->QN5_TIPO    := QN4->QN4_TIPO
					QN5->QN5_TPDEV   := "2"
					QN5->QN5_DTADEV  := CTOD("  /  /  ")
					QN5->QN5_STATUS  := "5"
					QN5->QN5_ULFILL  := cFilSai
					QN5->QN5_FILOBR  := "  "
					MsUnlock()
		
					If Alltrim(cFilDev) == Alltrim(cFilAnt)
		                //Localiza a familia do instrumento
						dbSelectArea("QM2")                 
						dbSetOrder(1)
						If dbSeek(xFilial("QM2")+QN5->QN5_INSTR+Inverte(QN5->QN5_REVINS))
							
							//Localiza o departamento / responsavel da filial para a devolucao...a partir da ultima revisao do instrumento	
							dbSelectArea("QM1")
							dbSetOrder(1)
							dbSeek(xFilial("QM1")+QM2->QM2_TIPO)
							cDeppt := QM1->QM1_DISTR  //1
							cRespt := QM1->QM1_RDISTR //2
							
							/*If !Empty(mv_par01)
								cDeppt := mv_par01
							Endif
							
							If !Empty(mv_par02)
								cRespt := mv_par02
							Endif*/
							
							dbSelectArea("QML")
							dbSetOrder(1)
							If dbSeek(xFilial()+QN4->QN4_INSTR+QN4->QN4_REVINS+"A")
								RecLock("QML",.F.)
								QML->QML_FILIAL := xFilial("QML")
								QML->QML_DTCOL  := dDataBase
								QML->QML_HRCOL  := Time()
								QML->QML_FLAGB  := "B"                                
								/*If lAltLoc 
									QML->QML_LOCAL  := MV_PAR03 //Localizacao
								Endif */	
								MsUnLock()
							Endif
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Atualiza Cadastro de Instrumentos                  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							// DbSelectArea("QM2")
							// DbSetOrder(1)
							// Segundo o Angelo é uma falha no sistema pois deixa o usuário alterar o cadastro de instrumentos
							// sem ser o responsável por ele.
							/* If dbSeek(xFilial("QM2")+QN4->QN4_INSTR+Inverte(QN4->QN4_REVINS))
									RecLock("QM2",.F.)
									If !Empty(mv_par01) //Novo Departamento
										QM2->QM2_DEPTO := mv_par01
									Else
										QM2->QM2_DEPTO := QM1->QM1_DISTR
									Endif
					
									If !Empty(mv_par02) //Novo Responsavel
										QM2->QM2_RESP  := mv_par02
									Else
										QM2->QM2_RESP  := QM1->QM1_RDISTR
									Endif
					
									QM2->QM2_LOCAL := MV_PAR03
									MsUnLock()        
							   Endif
							*/
				    	Endif	
						If lQMT160BX
							ExecBlock("QMT160BX",.F.,.F.,{QML->QML_INSTR,QML->QML_REVINS})
						EndIf				
				Endif
			Endif
		
			QM2->(DbGoTop())
			QM2->(DbSetOrder(1))
			cFilQN4 :=  Iif(Empty(Alltrim(xFilial("QM2"))),xFilial("QM2"),QN4->QN4_FILINS)
			If QM2->(DbSeek(cFilQN4+QN4->QN4_INSTR))
				
				// Verifico se o Responsavel pelo Instrumento mudou
				If QM2->QM2_RESP#QN4->QN4_RESENT 
					RecLock("QN4",.F.)
					Replace QN4_FILREN With QM2->QM2_FILRES
					Replace QN4_DEPREN With QM2->QM2_DEPTO
					Replace QN4_RESENT With QM2->QM2_RESP
					MsUnLock()				     
				EndIf	
				
				If Len(aInstr)>0 
				
					If AllTrim(QM2->QM2_RESP)<>AllTrim(cResAnt)
				        
				   		DbSelectArea("SX2")
						DbSetOrder(1)
						If DbSeek("QAD")
							If FWModeAccess("QAD",1) == "C"
								cDesReceb := Posicione("QAD",1,xfilial("QAD")+QN4->QN4_DEPRSA,"QAD_DESC")
							Else                                                                                                             
								cDesReceb :=Posicione("QAD",1,QN4->QN4_FILRSA+QN4->QN4_DEPRSA,"QAD_DESC")
							Endif                                                                          
						Endif    
					
						QM230Email(Posicione("QAA",1,QN4->QN4_FILRSA+QN4->QN4_RESSAI,"Alltrim(QAA_NOME)"),;
						QN4->QN4_FILRSA,;
						Alltrim(QN4->QN4_DEPRSA)+" - "+	cDesReceb ,;
						Posicione("QAA",1,cResFiA+cResAnt,"Alltrim(QAA_EMAIL)"),;
						Posicione("QAA",1,cResFiA+cResAnt,"Alltrim(QAA_NOME)"),;
						aInstr,;
						STR0087,; //"Instrumentos Devolvidos por Motivo de Reprovação"
						STR0086,; //"Segue relacao do instrumento(s) devolvidos(s) : "
						Posicione("QAA",1,cResFiA+cResAnt,"QAA_TPMAIL"),aNecCa)
		
						aInstr := {}          
						cResAnt := QM2->QM2_RESP
						cResFiA := QM2->QM2_FILRES
						cResDeA := QM2->QM2_DEPTO
					Endif
					AADD(aInstr,{QN4->QN4_INSTR,QN4->QN4_REVINS,;
					QN4->QN4_FILINS,QM2->QM2_DESCR})   //Posicione("QM2",1,Iif(lQM230Brow,QN4->QN42_INSTR,xFilial("QM2"))+QN4->QN4_INSTR+INVERTE(QN4->QN4_REVINS),"QM2_DESCR")})  
                Else
                	AADD(aInstr,{QN4->QN4_INSTR,QN4->QN4_REVINS,;
					QN4->QN4_FILINS,QM2->QM2_DESCR})   //Posicione("QM2",1,Iif(lQM230Brow,QN4->QN42_INSTR,xFilial("QM2"))+QN4->QN4_INSTR+INVERTE(QN4->QN4_REVINS),"QM2_DESCR")})  //QM2->QM2_DESCR })
					cResAnt := QM2->QM2_RESP
					cResFiA := QM2->QM2_FILRES
					cResDeA := QM2->QM2_DEPTO
                EndIf
			EndIf	
		EndIf
	EndIf
	TRB1->(dbSkip())
EndDo  

//A Devolução ocorre para o usuário Responsável pelo Instrumento.	
If Len(aInstr)>0  

	QM2->(DbSetOrder(1))
	cFilQN4 := Iif(Empty(Alltrim(xFilial("QM2"))),xFilial("QM2"),QN4->QN4_FILINS)
	If QM2->(DbSeek(cFilQN4+QN4->QN4_INSTR))
		// Verifico se o Responsavel pelo Instrumento mudou
		If QM2->QM2_RESP#QN4->QN4_RESENT 
			RecLock("QN4",.F.)
			Replace QN4_FILREN With QM2->QM2_FILRES
			Replace QN4_DEPREN With QM2->QM2_DEPTO
			Replace QN4_RESENT With QM2->QM2_RESP
			MsUnLock()				     
		EndIf
				
		DbSelectArea("SX2")
		DbSetOrder(1)
		DbGotop()
		IF DbSeek("QAD")
			If FWModeAccess("QAD",1) == "C"
				cDesReceb := Posicione("QAD",1,xfilial("QAD")+QN4->QN4_DEPRSA,"QAD_DESC")
			Else                                                                                                             
				cDesReceb :=Posicione("QAD",1,QN4->QN4_FILRSA+QN4->QN4_DEPRSA,"QAD_DESC")
			Endif                                                                          
		Endif    

		QM230Email(Posicione("QAA",1,QN4->QN4_FILRSA+QN4->QN4_RESSAI,"Alltrim(QAA_NOME)"),;
		QN4->QN4_FILRSA,;
		Alltrim(QN4->QN4_DEPRSA)+" - "+	cDesReceb ,;
		Posicione("QAA",1,QN4->QN4_FILREN+QN4->QN4_RESENT,"Alltrim(QAA_EMAIL)"),;
		Posicione("QAA",1,QN4->QN4_FILREN+QN4->QN4_RESENT,"Alltrim(QAA_NOME)"),;
		aInstr,;
		STR0087,; //"Instrumentos Devolvidos por Motivo de Reprovação"
		STR0086,; //"Segue relacao do instrumento(s) devolvidos(s) : "
		Posicione("QAA",1,QN4->QN4_FILREN+QN4->QN4_RESENT,"QAA_TPMAIL"),aNecCa)  
	EndIf
	
EndIf

//Posiciona Instrumentos disponivels da filial corrente.
dbSelectArea("QN5")
dbSeek(xFilial("QN5"))

Return(Nil)   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QM230Calib ³ Autor ³Cleber L. Souza 		³ Data ³15/04/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rotina de Calibração do Instrumento.			  			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QM230Calib					     						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM230Calib()  

Local   cFilBack  := cFilAnt
Local 	oBrw	  := GetObjBrow()

Private	lBlkGrv		:= .T.
Private	dDataVal
Private	cPertMt140	:= " "
Private	cMtRespQM2	:= ""
Private	lInteg		:= .F.
Private	cNomin		:= ""
Private	nCoef			:= 1
Private	cUniMed		:= ""
Private  aTitEsc		:= {} 
Private  aPagEsc		:= {}
Private  aTitPad		:= {} 
Private  aPagPad		:= {}
Private  aHeadQMS		:= {}					
Private lQM230Brow := ExistBlock("QM230BROW")
If QN5->QN5_STATUS <> "4" 
	Messagedlg(STR0077)
	//Help("",1,"QM230013",,OemToAnsi(STR0077),1) //"Eh obrigatorio que o instrumento esteja com status de calibracao !!"	
    QN5->(dbSetOrder(1))
    QN5->(dbSeek(xFilial("QN5")))
    Return(.F.)
EndIF    

cFilAnt := QN5->QN5_FILINS

// Posiciona o registro da QM6 pois a chamada é de rotina externa
//QM6->(DbSelectArea("QM6"))
//QM6->(DbSetOrder(1))
//QM6->(DbSeek(xFilial("QM6")+))
 
if QMTA140(.T.) == 1//A140Mae("QM6",0,3) == 1
	cFilAnt := cFilBack
	DbSelectArea("QN5") 
	If Alltrim(QN5->QN5_FILINS) == Alltrim(cFilAnt) 
		Reclock("QN5",.f.)
		QN5->QN5_STATUS:= "6"
		msunlock()
	Else
		reclock("QN5",.f.)
		QN5->QN5_STATUS:= "2"
		msunlock()                         
	Endif
Else
	cFilAnt := cFilBack
Endif

// Para atualizar o mBrowse customizado com arquivo de trabalho
If !lQm230Brow
	If oTmpTable3 <> NIL
		oTmpTable3:Delete()
	EndIf
	QMTA230TRB()
Endif

If ValType(oBrw) != "U"
	oBrw:GoTop()
	oBrw:Refresh()
EndIf		
	                         
Return()          


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QM230Email ³ Autor ³Cleber L. Souza 		³ Data ³06/08/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rotina de Envio de Email de devolução do Instrumento.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QM230Email(cResSai,cFilRsa,cDepRsa,cEmail,cResEnv,aInstr,; ³±±
±±³     	 ³            cTitulo1,cTitulo2,cTipo)					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1=Responsavel pelo recebto do Instrumento.			  ³±±
±±³          ³ EXPC2=Filial do Responsavel pelo recebto.   				  ³±±
±±³          ³ EXPC3=Departamento do Responsavel pelo recebto.			  ³±±
±±³          ³ EXPC4=Email do  Responsavel pelo recebto.			      ³±±
±±³          ³ EXPC5=Responsavel pelo envio do Instrumento.				  ³±±
±±³          ³ EXPA1=Array com os instrumentos enviados.				  ³±±
±±³          ³ EXPC6=Titulo 1 do email.									  ³±±
±±³          ³ EXPC7=Titulo 1 do email.									  ³±±
±±³          ³ EXPC8=Tipo do email (Texto\HTML)							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA230													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM230Email(cResSai,cFilRsa,cDepRsa,cEmail,cResEnv,aInstr,cTitulo1,cTitulo2,cTipo,aNec)

Local cMsg   := ""
Local nY     := 0   
Local aEmail := {}
Local lEnvMa := .F.
Local nd 	 := 1
Local lTmIns := .F.
Default aNeC := {}

If ExistBlock("QMT230Mai")
	ExecBlock("QMT230Mai",.F.,.F.,{cEmail,cResEnv,aInstr})
Else
	If cTipo == "1"
		lEnvMa := .T.		
		cMsg := '<html>'
		cMsg += '<head>'
		cMsg += '<body>'
		cMsg += '<p></p>'
		cMsg += '<table borderColor="#0099cc" height="29" cellSpacing="1" width="679" borderColorLight="#0099CC" border="1">'
		cMsg += '<tr>'
		cMsg += '<td borderColor="#0099cc" borderColorLight="#0099cc" align="left" width="640" bgColor="#0099cc" borderColorDark="#0099cc" height="1"> '
		cMsg += '<p align="center"><font face="Courier New" color="#ffffff" size="3">'+cTitulo1
		cMsg += '</tr>'
		cMsg += '</table>'
		cMsg += '<p align="justify"><font face="Arial" size="2">'+ 'Sr(a) ' + cResEnv+'</font></p>'
		cMsg += '<p align="justify"><font face="Arial" size="2">'+ cTitulo2 +'</font></p>'
		cMsg += '<div align="left">'
		cMsg += '<table border="1" cellspacing="1" bordercolor="#0099CC" width="678" id="AutoNumber1" bordercolorlight="#0099CC" bordercolordark="#0099CC">'
		cMsg += '<tr>'
		cMsg += '<td width="134" bordercolorlight="#0099CC" bgcolor="#0099CC" height="1">'
		cMsg += '<font face="Courier New" color="#FFFFFF"><b>&nbsp;' + STR0088 + '</b></font></td> ' //'Codigo'
		cMsg += '<td width="93" bgcolor="#0099CC"><font face="Courier New" color="#FFFFFF">'
		cMsg += '<b>&nbsp;' + STR0089 + '</b></font></td>'    //'Revisao'
		cMsg += '<td width="92" bgcolor="#0099CC" bordercolorlight="#0099CC">'
		cMsg += '<font face="Courier New" color="#FFFFFF"><b>&nbsp;' + STR0090 + '</b></font></td>' //'Filial'
		cMsg += '<td width="354" height="0" bgcolor="#0099CC">'
		cMsg += '<font face="Courier New" color="#FFFFFF"><b>&nbsp;' + STR0091 + '</b></font></td>' //'Instrumento'
		cMsg += '</tr>'
		cMsg += '</table>'
		cMsg += '</div>'
		cMsg += '<div align="left">'
		
		For nY:=1 to Len(aInstr)
			cMsg += '<table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" width="97%" id="AutoNumber2" height="0">'
			cMsg += '<tr>'
			nANec := Ascan(aNeC,{|x|Alltrim(x[1])==Alltrim(aInstr[ny,1])})			
			If nANec > 0
				cMsg += '<td width="18%">&nbsp;<font size="2">&nbsp;&nbsp; ' + Alltrim(aInstr[nY,1]) + '</font></td>' //PadR(aInstr[nY,1],16)
			Else
				cMsg += '<td width="18%">&nbsp;<font size="2">&nbsp;&nbsp; ' + Alltrim(aInstr[nY,1]) + " *" + '</font></td>'	//PadR(aInstr[nY,1],16)		
				lTmIns := .T.
			Endif	
			cMsg += '<td width="13%"><font size="2">' + Alltrim(aInstr[nY,2]) + '</td>' //PadR(aInstr[nY,2],2)
			cMsg += '<td width="13%"><font size="2">' + Alltrim(aInstr[nY,3]) + '</td>'  //PadR(aInstr[nY,3],2)
			cMsg += '<td width="57%"><font size="2">' + Alltrim(aInstr[nY,4]) + '</td>' //PadR(aInstr[nY,4],30)
			cMsg += '</tr>'
			cMsg += '</table> '
		Next nY
		
		cMsg += '</div>'
		cMsg += '<p>&nbsp;</p>'
		cMsg += '<table border="0" cellspacing="1" width="98%" id="AutoNumber3" bordercolorlight="#0099CC" bordercolordark="#0099CC">'
		cMsg += '<tr>'
		cMsg += '<td width="26%" bordercolorlight="#0099CC" bordercolordark="#0099CC"><b><i>'
		cMsg += STR0092 +'<br>'          //'Responsavel pelo Envio:'
		cMsg += STR0093 +'<br>'          //'Departamento :'
		cMsg += STR0094+'</i></b></td>'  //'Filial :'
		cMsg += '<td width="174%" bordercolorlight="#0099CC" bordercolordark="#0099CC">&nbsp;<font size="2">'+cResSai +'<br>'
		cMsg += '<b><i>&nbsp;</i></b><font size="2">'+cDepRsa +'<br>'
		cMsg += '<b><i>&nbsp;</i></b><font size="2">'+cFilRsa +" - " + QA_CHKFIL(cFilRsa,,.T.)+'</td>'
		cMsg += '</tr>'

		If Len(aNeC) > 0
			cMsg += '<p>&nbsp;</p>' 
			cMsg += '<p>&nbsp;</p>'
			For nd := 1 to Len(aNeC)
				nANec := Ascan(aInstr,{|x|Alltrim(x[1])==Alltrim(aNeC[nd,1])})
                If nANec > 0
					cMsg +=STR0125 +'<br>'// O(s) instrumento(s) abaixo descrito(s) foi(ram) devolvido(s) sem a respectiva calibracao"
				Endif	
			Next nd
		Endif			

		cMsg += '</table>'
		cMsg += '<p><br>'
		cMsg += '&nbsp;</p>'
	Else
		lEnvMa := .T.		
		cMsg := cTitulo1 +CHR(13)+CHR(10)+CHR(13)+CHR(10)
		cMsg += STR0095 + cResEnv +CHR(13)+CHR(10)  //"Sr.(a) "
		cMsg += cTitulo2 +CHR(13)+CHR(10)+CHR(13)+CHR(10)
		For nY:=1 to Len(aInstr)
			cMsg += STR0101 + aInstr[nY,1]+CHR(13)+CHR(10) //"Código : "
			cMsg += STR0102 + aInstr[nY,2]+CHR(13)+CHR(10) //"Revisao : "
			cMsg += STR0103 + aInstr[nY,3]+CHR(13)+CHR(10) //"Filial : "
			cMsg += STR0104 + aInstr[nY,4]+CHR(13)+CHR(10) //"Instrumento : "
			cMsg += CHR(13)+CHR(10)+CHR(13)+CHR(10)
		Next nY
		cMsg += CHR(13)+CHR(10)
		cMsg += STR0097 + cResSai + CHR(13)+CHR(10) //"Responsável pelo Envio: "
		cMsg += STR0098 + cDepRsa + CHR(13)+CHR(10) //"Departamento: "
		cMsg += STR0099 + cFilRsa +" - " + QA_CHKFIL(cFilRsa,,.T.) + CHR(13)+CHR(10) //"Filial: "
	EndIF
	
	aMsg:= { { STR0100,cMsg, "" } }  //" - Notificação de Envio de Instrumento."
	AADD(aEmail,{Alltrim(cResEnv),cEmail,aMsg})
	
	If Len(aEmail)>0 .and. 	Len(aInstr)>0
		QAEnvMail(aEmail,,,,)
	EndIf
EndIF

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QM230TR1  ºAutor  ³Denis Martins 		 º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Pesquisa se o instrumento existe na coluna de disponivel p/ º±±
±±º          ³emprestimo                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA230                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM230TR1(cInns)   
Local nRec := 0      
Local lAchou := .F.
dbSelectArea("TMP")
dbSetOrder(1)
dbGoTop()
While TMP->(!Eof())
	nRec++
	If Alltrim(TMP->TMP_INSTR) == Alltrim(cInns)
		o1Lbx:nAt := nRec	
		o1Lbx:Refresh()
		lAchou := .T.
		Exit
	Endif 
dbSkip()
Enddo

//Caso perca o foco e nao tenha instrumento na pesquisa
If !lAchou .and. !Empty(cInns)
	MessageDlg(STR0123,,3)//"Codigo do Instrumento nao esta disponivel na lista"
	oPesqIn:SetFocus() 
Endif

cPesIn := CriaVar("QM2_INSTR")

Return                                                                                                                                                        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QMTA230   ³ Autor ³ Renata Cavalcante       ³ data ³01/06/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Função para aviso de Inst p/ verncer/devolução vencida 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAQMT													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³STR 	     ³ Ultimo utilizado ->                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/             

Function QMTINVEN                          

Local nDias			:= GETMV("MV_QQTDIAS",.t.,5)                             
Local lRet         	:= .F.
Local cAlias     	:=""

Local cFiltro		:=""
Local cArqFil		:=""
Local aPend			:= {}

cAlias:="TRB2"
cQuery := "SELECT QN5.QN5_FILIAL,QN5.QN5_INSTR,QN5.QN5_REVINS,QN5.QN5_FILINS,QN5.QN5_DTADEV,QN5.QN5_FILOBR,QN4.QN4_FILREN, QN4.QN4_RESENT,QAA.QAA_MAT,QAA.QAA_LOGIN"
cQuery += " FROM " + RetSqlName("QN5") +" QN5, " + RetSqlName("QN4")+" QN4," + RetSqlName("QAA")+" QAA"
cQuery += " WHERE QN5.QN5_FILIAL = '"	+ xFilial("QN5") + "' AND "  + "QN4.QN4_FILIAL = '"	+ xFilial("QN4") + "' AND "  +"QAA.QAA_FILIAL = '"	+ xFilial("QAA")+ "' AND " 
cQuery += " QN4.QN4_DTASAI <= '" + DtoS(dDataBase-nDias) + "' AND " 
cQuery += " QN5.QN5_INSTR = QN4.QN4_INSTR  AND  QN5.QN5_REVINS = QN4.QN4_REVINS AND QN5.QN5_FILINS = QN4.QN4_FILINS AND" 
cQuery += " QN4.QN4_ULTMOV = 'S'  AND "
cQuery += " QAA.QAA_MAT = QN4.QN4_RESENT  AND  QAA.QAA_LOGIN ='" + UPPER(SUBSTR(CUSUARIO,7,15)) +  "' AND "
cQuery += " QN5.D_E_L_E_T_<>'*' AND "
cQuery += " QN5.QN5_STATUS <> '1' "                                                                


dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"TRB2", .F., .T.)

TcSetField("TRB2","QN5_DTADEV","D",8,0)

dbSelectArea("TRB2")

cArqFil := CriaTrab(,.F.)
cAlias:="QN5"
dbSelectArea("QN5")
cFiltro:= "QN5_FILIAL == '"+xFilial("QN5")+"' .And. "
cFiltro+= "(DTOS(QN5_DTADEV) <='" +DtoS(dDataBase+nDias)+ "' .AND. "
cFiltro+= "DTOS(QN5_DTADEV) >='" +DtoS(dDataBase-nDias)+"')"
cChave := "QN5_FILIAL+QN5_INSTR+QN5_REVINS+QN5_FILINS"
IndRegua("QN5",cArqFil,cChave,,cFiltro)
nIndex := RetIndex("QN5")

#IFNDEF TOP
	dbSetIndex(cArqFil+OrdBagExt())
#ENDIF

dbSetOrder(nIndex+1)
      	
DbSelectarea(cAlias)
dbGoTop()    

IF TRB2->(!Eof())	
	lRet:= MsgYesNo(OemToAnsi(STR0126),OemToAnsi(STR0127)) //"Existem instrumentos com data de devolução a vencer"  # "Deseja Visualizá-los?"
Endif  

While TRB2->(!EOF())
	AADD(aPend,{TRB2->QN5_INSTR, TRB2->QN5_REVINS, TRB2->QN5_FILINS, TRB2->QN5_DTADEV, TRB2->QN5_FILOBR})
	TRB2->(DbSkip())
EndDo

If lRet
            
	DEFINE MSDIALOG oDlgIns FROM 0,0 TO 210,430 TITLE STR0128 Of oMainWnd PIXEL

	@ 2,6 LISTBOX o1Lbx VAR c1Lbx FIELDS ALIAS "TRB2";
			  HEADER            OemtoAnsi(STR0036),; //"Instrumento"
								OemtoAnsi(STR0037),; //"Revisao"
								OemtoAnsi(STR0138),;  //"Filial Instrumento"
								OemtoAnsi(STR0139);  //"Data Devolução"
								OemtoAnsi(STR0140);  //"Filial para Dev."                        
		      COLSIZES 	        GetTextWidth(0,"W"),;
								GetTextWidth(0,"BBBBBBBBBBBBBBBBB"),;
								GetTextWidth(0,"BB"),;
								GetTextWidth(0,"BB"),;
							    GetTextWidth(0,"BBBBBBBBBBBBBBBB");
						        SIZE 180,100 OF oDlgIns PIXEL
	  
	 		 o1Lbx:SetArray(aPend)

		     o1Lbx:bLine:= {||{ aPend[o1Lbx:nAt,1],;
			   				    aPend[o1Lbx:nAt,2],;
							    aPend[o1Lbx:nAt,3],;
							    aPend[o1Lbx:nAt,4],;
							    aPend[o1Lbx:nAt,5]}}
	
	DEFINE SBUTTON  FROM 05,188 TYPE 1 ACTION (QM230Devol(),oDlgIns:End()) ENABLE OF oDlgins PIXEL   
	DEFINE SBUTTON  FROM 15,188 TYPE 2 ACTION (TRB2->(DBCLOSEAREA()),oDlgIns:End()) ENABLE OF oDlgins PIXEL	
	ACTIVATE MSDIALOG oDlgIns CENTERED                       
	
Endif 

If Select("TRB2") > 1
	TRB2->(DBCLOSEAREA())
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QMTA230   ³ Autor ³ Renata Cavalcante       ³ data ³01/06/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Função para Habilitar ou desabilitar o radiobutton   	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAQMT													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³STR 	     ³ Ultimo utilizado ->                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/      

Static Function qm230ch(nRad)
	If nitem1== 2
		nitem2:=2
		orad2:refresh()
		orad2:disable()
	Else
		nitem2:=1
		orad2:refresh()
		orad2:enable()    
	Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMTA230   ºAutor  ³Microsiga           º Data ³  12/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Criado o filtro para permitir somente os registros no browse
de acordo com o usuário logado/responsavel                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QM230FIL(cInst,cRev,cFilIns,cUFill)
Local lRetv := .F.
If QAXUser(__cUserId,1) == "000000"
    Return lRetv
Endif

QN4->(DbSetOrder(1))
If QN4->(DbSeek(xFilial("QN4")+cInst+cRev+cFilIns+"S"))
     If QN4->QN4_RESENT == QAXUser(__cUserId,5) 
		lRetv := .T.     
	 EndIf
EndIf	

Return lRetv


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMTA230   ºAutor  ³Microsiga           º Data ³  12/16/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Function QM230FCAL
Local cTpMov

QN4->(DbSetOrder(1)) 
                             //QN5->QN5_INSTR,QN5->QN5_REVINS,QN5->QN5_FILINS,QN5->QN5_ULFILL
If QN4->(DbSeek(xFilial("QN4")+QN5->QN5_INSTR+QN5->QN5_REVINS+QN5->QN5_FILINS+"S"))
   If QN4->QN4_TPMOV == "2"
          cTpMov:="2"
   Endif
Endif 
    
Return cTpMov


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMTA230TRBºAutor  ³Rafael Duram Santos º Data ³  15/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Montagem de alias temporario para melhoria de performance  º±±
±±º          ³ na exibicao dos intrumentos a movimentar			          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QMTA230TRB()

Local aTam		:= {}
Local aCampos	:= {}
Local cQuery	:= ""
Local cMat		:= QAXUser(__cUserId,5)

aTam:= TamSX3("QN5_FILIAL")
Aadd(aCampos,{"TRB_FILIAL","C",aTam[1],aTam[2]})

aTam:= TamSX3("QN5_INSTR")
Aadd(aCampos,{"TRB_INSTR","C",aTam[1],aTam[2]})

aTam:= TamSX3("QN5_REVINS")
Aadd(aCampos,{"TRB_REVINS","C",aTam[1],aTam[2]})

aTam:= TamSX3("QN5_FILINS")
Aadd(aCampos,{"TRB_FILINS","C",aTam[1],aTam[2]})

aTam:= TamSX3("QN5_TPDEV")
Aadd(aCampos,{"TRB_TPDEV","C",aTam[1],aTam[2]})

aTam:= TamSX3("QN5_DTADEV")
Aadd(aCampos,{"TRB_DTADEV","C",aTam[1],aTam[2]})

aTam:= TamSX3("QN5_STATUS")
Aadd(aCampos,{"TRB_STATUS","C",aTam[1],aTam[2]})

aTam:= TamSX3("QN5_TIPO")
Aadd(aCampos,{"TRB_TIPO","C",aTam[1],aTam[2]})

aTam:= TamSX3("QN5_RESOBR")
Aadd(aCampos,{"TRB_RESOBR","C",aTam[1],aTam[2]})

aTam:= TamSX3("QN5_FILOBR")
Aadd(aCampos,{"TRB_FILOBR","C",aTam[1],aTam[2]})

aTam:= TamSX3("QN5_DEPOBR")
Aadd(aCampos,{"TRB_DEPOBR","C",aTam[1],aTam[2]})

aTam:= TamSX3("QN5_ULFILL")
Aadd(aCampos,{"TRB_ULFILL","C",aTam[1],aTam[2]})

oTmpTable3 := FWTemporaryTable():New( "TRB" )
oTmpTable3:SetFields( aCampos )
oTmpTable3:AddIndex("indice1", {"TRB_INSTR","TRB_REVINS","TRB_FILINS"} )
oTmpTable3:AddIndex("indice2", {"TRB_TIPO"} )
oTmpTable3:Create()

cQuery := "SELECT QN5.QN5_FILIAL,QN5.QN5_INSTR, QN5.QN5_REVINS, QN5.QN5_FILINS, QN5.QN5_TPDEV, QN5.QN5_DTADEV, QN5.QN5_STATUS,  "
cQuery += "QN5.QN5_TIPO, QN5.QN5_RESOBR, QN5.QN5_FILOBR, QN5.QN5_DEPOBR, QN5.QN5_ULFILL "  
cQuery += "FROM "+RetSqlName("QN5")+" QN5, "+RetSqlName("QN4")+" QN4 "
cQuery += "WHERE "
cQuery += "QN5.QN5_INSTR = QN4.QN4_INSTR AND "
cQuery += "QN5.QN5_REVINS = QN4.QN4_REVINS AND "
cQuery += "QN5.QN5_FILINS = QN4.QN4_FILINS AND "
cQuery += "QN5.D_E_L_E_T_ = ' ' AND QN4.D_E_L_E_T_ = ' ' AND "
cQuery += "QN4.QN4_RESENT = '"+Iif(Empty(cMat),'ZZZZZZZZZZ',cMat)+"' AND "
cQuery += "QN4.QN4_ULTMOV = 'S' AND "
cQuery += "QN4.QN4_FILIAL = '"+xFilial("QN4")+"' AND QN5.QN5_FILIAL = '"+xFilial("QN5")+"'"
			
cQuery := ChangeQuery(cQuery)

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'QN5BRW', .F., .T.)

DbSelectArea("QN5BRW")
DbGotop()
While ("QN5BRW")->(!Eof())
	RecLock("TRB",.T.)
	TRB->TRB_FILIAL:= ("QN5BRW")->QN5_FILIAL
	TRB->TRB_INSTR := ("QN5BRW")->QN5_INSTR
	TRB->TRB_REVINS:= ("QN5BRW")->QN5_REVINS
	TRB->TRB_FILINS:= ("QN5BRW")->QN5_FILINS
	TRB->TRB_TPDEV := ("QN5BRW")->QN5_TPDEV
	TRB->TRB_DTADEV:= ("QN5BRW")->QN5_DTADEV
	TRB->TRB_STATUS:= ("QN5BRW")->QN5_STATUS
	TRB->TRB_TIPO  := ("QN5BRW")->QN5_TIPO
	TRB->TRB_RESOBR:= ("QN5BRW")->QN5_RESOBR
	TRB->TRB_FILOBR:= ("QN5BRW")->QN5_FILOBR
	TRB->TRB_DEPOBR:= ("QN5BRW")->QN5_DEPOBR
	TRB->TRB_ULFILL:= ("QN5BRW")->QN5_ULFILL	
	TRB->(MsUnLock())
	QN5BRW->(DbSkip())
EndDo
QN5BRW->(dbCloseArea())

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QM230Psq  ºAutor  ³Rafael Duram Santos º Data ³  15/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pesquisa no Arquivo temporario							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM230Psq()

Local oDlg
Local oBtn1
Local oBtn2
Local oOrd
Local cOrd    := " "
Local nOpcao  := 0
Local cTexto  := Space(20)
Local aOrd    := {TitSx3("QN5_INSTR")[1]+" + "+TitSx3("QN5_REVINS")[1]+" + "+TitSx3("QN5_FILINS")[1],;// "Instrumento" ### "Rev. Instr." ### "Fil. Instr."
						 TitSx3("QN5_TIPO")[1]} // "Tipo"


DEFINE MSDIALOG oDlg FROM 000,000 TO 100,490 PIXEL TITLE OemToAnsi(STR0001) // "Pesquisar"

@ 005,005 COMBOBOX oOrd VAR cOrd ITEMS aOrd SIZE 206,36 PIXEL OF oDlg ;
				ON CHANGE (nOrdPesq:= oOrd:nAt)

@ 022,005 MSGET cTexto SIZE 206,010 OF oDlg PIXEL

DEFINE SBUTTON oBtn1 FROM 005,215 TYPE 1 PIXEL ENABLE OF oDlg ;
			ACTION ( nOpcao:=1,oDlg:End() )

DEFINE SBUTTON oBtn2 FROM 020,215 TYPE 2 PIXEL ENABLE OF oDlg ;
			ACTION oDlg:End()

oOrd:nAt:= nOrdPesq

ACTIVATE MSDIALOG oDlg CENTERED

If nOpcao == 1
	If TRB->(IndexOrd()) <> nOrdPesq
		TRB->(DbSetOrder(nOrdPesq))
	EndIf
	If !Empty(AllTrim(cTexto))
		TRB->(DbSeek(RTrim(cTexto)))
	EndIf
EndIf

Return			

//----------------------------------------------------------------------
/*/{Protheus.doc} Q230GetSX3 
Busca dados da SX3 
@author Brunno de Medeiros da Costa
@since 11/04/2018
@version 1.0
@return aHeaderTmp
/*/
//---------------------------------------------------------------------- 
Static Function Q230GetSX3(cCampo, cTitulo, cWhen)
Local aHeaderTmp := {}
aHeaderTmp:= {IIf(Empty(cTitulo), QAGetX3Tit(cCampo), cTitulo),;
	              GetSx3Cache(cCampo,'X3_CAMPO'),;
	              GetSx3Cache(cCampo,'X3_PICTURE'),;
	              GetSx3Cache(cCampo,'X3_TAMANHO'),;
	              GetSx3Cache(cCampo,'X3_DECIMAL'),;
	              GetSx3Cache(cCampo,'X3_VALID'),;              
	              GetSx3Cache(cCampo,'X3_USADO'),;
	              GetSx3Cache(cCampo,'X3_TIPO'),;
	              GetSx3Cache(cCampo,'X3_F3'),;
	              GetSx3Cache(cCampo,'X3_CONTEXT'),;
	              QAGetX3Cmb(cCampo),;
	              GetSx3Cache(cCampo,'X3_RELACAO')} 
Return aHeaderTmp