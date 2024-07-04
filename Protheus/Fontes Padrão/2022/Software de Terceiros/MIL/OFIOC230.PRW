#INCLUDE "OFIOC230.CH"
#INCLUDE "PROTHEUS.CH" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOFIOC230  บAutor  ณFabio               บ Data ณ  02/02/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProgresso de Pedidos Veiculos - GM                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIOC230()
                                              
Local nOpcOk := 0
          
Private aRotina := { { STR0002 ,"axPesqui", 0 , 1},;    //"Pesquisar"
                     { STR0003 ,"OC230V",    0 , 2},;    //"Visualizar"
                     { STR0004 ,"OC230E",    0 , 5} }    //Exclusao
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define o cabecalho da tela de atualizacoes                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private cCadastro := OemToAnsi(STR0001) 
PRIVATE aCampos := {}
Private cIndex , cChave , cCond , nIndex := 0
Private nTipPed := 0, nTipoOpcao := 0, dDataPer := Ctod("  /  /  "), cFamilia := "", cModelo := ""
Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
Private aData := {}, aFamilia := {}, aModelo := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Endereca a funcao de BROWSE                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

/*cPerg := "OFC23A"
AValidPerg()
If !Pergunte("OFC23A",.t.)
   Return .t.
EndIf
*/                                            

If Len(aData) == 0
	Aadd( aData, { .f., Ctod("  /  /  ")})                  
EndIf
If Len(aFamilia) == 0
	Aadd( aFamilia, { .f., "", ""})
EndIf
If Len(aModelo) == 0
	Aadd( aModelo, { .f., "", ""})
EndIf

DEFINE MSDIALOG oFilProg TITLE STR0005 From 7,08 to 24,78      of oMainWnd  //Progresso do Veiculo - Filtro...

   @ 001,001 SAY STR0006 OF oFilProg PIXEL //Tipo Pedido 
   @ 001,035 MSGET oTipPed VAR nTipPed VALID FS_VALTIK(1) PICTURE "99" SIZE 10,4 OF oFilProg PIXEL

   @ 001,070 SAY STR0007 OF oFilProg PIXEL  //"Status "
	@ 001,095 MSCOMBOBOX oTipoOpcao VAR nTipoOpcao ITEMS {STR0008,STR0009,STR0010} SIZE 065, 65 OF oFilProg PIXEL    //Disponivel # Direcionado # Desativado

   @ 015,001 LISTBOX oLbData FIELDS HEADER  OemToAnsi(""),OemToAnsi(STR0011) ;  //Data
		    SIZE 90,091 OF oFilProg ON DBLCLICK FS_VALTIK(2) PIXEL

   oLbData:SetArray(aData)
   oLbData:bLine := { || { If(aData[oLbData:nAt,1],oOk,oNo) ,; 
                               Transform( aData[oLbData:nAt,2], "@D" ) }}

   @ 015,92 LISTBOX oLbFamilia FIELDS HEADER  OemToAnsi(""),OemToAnsi(STR0012),OemToAnsi(STR0013) ; //Familia # Descricao
			 COLSIZES 10,25,50;
		    SIZE 90,091 OF oFilProg ON DBLCLICK FS_VALTIK(3) PIXEL

   oLbFamilia:SetArray(aFamilia)
   oLbFamilia:bLine := { || { If(aFamilia[oLbFamilia:nAt,1],oOk,oNo) ,; 
                               aFamilia[oLbFamilia:nAt,2] ,;
                               aFamilia[oLbFamilia:nAt,3] }}

   @ 015,183 LISTBOX oLbModelo FIELDS HEADER  OemToAnsi(""),OemToAnsi(STR0014),OemToAnsi(STR0013) ;  //Modelo # Descricao
			 COLSIZES 10,20,50;
		    SIZE 94,091 OF oFilProg ON DBLCLICK FS_VALTIK(4) PIXEL

   oLbModelo:SetArray(aModelo)
   oLbModelo:bLine := { || { If(aModelo[oLbModelo:nAt,1],oOk,oNo) ,; 
                               Substr(aModelo[oLbModelo:nAt,2],1,15) ,;
                               aModelo[oLbModelo:nAt,3] }}

   DEFINE SBUTTON FROM 112,200 TYPE 1 ACTION (nOpcOk := 1,oFilProg:End()) ENABLE OF oFilProg
   DEFINE SBUTTON FROM 112,240 TYPE 2 ACTION (nOpcOk := 0,oFilProg:End()) ENABLE OF oFilProg

ACTIVATE MSDIALOG oFilProg CENTER
               
If nOpcOk == 1
                                           
	VV2->(DbSetOrder(1))

	DbSelectArea("VJ1")
	DbSetOrder(1)
	
	cIndex  := CriaTrab(nil,.f.)
	cChave  := IndexKey()
	cCond   := "( Empty(nTipPed) .Or. VJ1_TIPPED == nTipPed ) .And. " ;
					+ "( Empty(dDataPer) .Or. Dtos(VJ1_DATPGD) =='"+dtos(dDataPer)+"' ) .And. " ;
					+ "( Empty(cFamilia) .Or. ( VV2->(DbSeek( xFilial('VV2')+VJ1->VJ1_CODMAR+VJ1->VJ1_MODVEI )) .And. VV2->VV2_GRUMOD == '"+cFamilia+"' ) ) .And. " ;
					+ "( Empty(cModelo) .Or. VJ1_MODVEI =='"+cModelo+"' )"
	IndRegua("VJ1",cIndex,cChave,,cCond,STR0015) //Selecionando Registros
	
	DbSelectArea("VJ1")
	nIndex := RetIndex("VJ1")
	#IFNDEF TOP
	   dbSetIndex(cIndex+ordBagExt())
	#ENDIF
	dbSetOrder(nIndex+1)
	
	mBrowse( 6, 1,22,75,"VJ1")
	
	dbSelectArea("VJ1")
	
	RetIndex()
	DbsetOrder(1)
	#IFNDEF TOP
	   If File(cIndex+OrdBagExt())
	      fErase(cIndex+OrdBagExt())
	   Endif
	#ENDIF

EndIf

Return             

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOC230V    บAutor  ณFabio               บ Data ณ  08/24/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVisualiza                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OC230V(cAlias,nReg,nOpc)

CAMPOC230()
AxVisual(cAlias,nReg,nOpc,aCampos)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOC230V    บAutor  ณFabio               บ Data ณ  08/24/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVisualiza                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OC230E(cAlias,nReg,nOpc)

cPerg := "OFC230"
//ValidPerg()
PERGUNTE(cPerg,.t.)

dbSelectArea("VJ1")
dbSetOrder(1)
dbSeek(xFilial("VJ1"))
while !EOF()        
   if MV_PAR01 == 1 
      if VJ1->VJ1_DATPED >= MV_PAR02 .and. VJ1->VJ1_DATPED <= MV_PAR03
	      RecLock("VJ1",.F.,.T.)
	      dbdelete()
	      MsUnlock()
	      WriteSx2("VJ1")
      Endif
   Else
      if VJ1->VJ1_DATFAT >= MV_PAR02 .and. VJ1->VJ1_DATFAT <= MV_PAR03
	      RecLock("VJ1",.F.,.T.)
	      dbdelete()
	      MsUnlock()
	      WriteSx2("VJ1")
      Endif
   Endif   
	dbSelectArea("VJ1")
	dbSkip()   
EndDo

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCAMPOC230 บAutor  ณFabio               บ Data ณ  08/24/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta campo p/ Mostra na tela                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CAMPOC230()

DbSelectArea("SX3")
dbseek("VJ1")
aCampos := {}

do While !eof() .and. x3_arquivo == "VJ1"
   If X3USO(x3_usado).and.cNivel>=x3_nivel
       aadd(aCampos,x3_campo)
   EndIf
       
   dbskip()
Enddo
DbSelectArea("VJ1")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณVALIDPERG บ Autor ณ Valdir F. Silva    บ Data ณ  03/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Verifica a existencia das perguntas criando-as caso seja   บฑฑ
ฑฑบ          ณ necessario (caso nao existam).                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
Static Function ValidPerg

Local _sAlias := Alias()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

Aadd(aRegs,{cPerg,"01","Tipo"        ,"","","mv_ch1","N", 01,0,0,"C","NaoVazio()","mv_par01","Data Pedido","","","","","Data Faturamento","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Data Inicial","","","mv_ch2","D", 08,0,0,"G",""          ,"mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""}) //"Data Inicial      ?"
aAdd(aRegs,{cPerg,"03","Data Final"  ,"","","mv_ch3","D", 08,0,0,"G",""          ,"mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""}) //"Data Final        ?"

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

dbSelectArea(_sAlias)

Return
*/

/*
Static Function AValidPerg

Local _sAlias := Alias()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

Aadd(aRegs,{cPerg,"01","Tipo Pedido"    ,"","","mv_ch1","N", 02,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Dt Prog Inicial","","","mv_ch2","D", 08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Dt Prog Final"  ,"","","mv_ch3","D", 08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

dbSelectArea(_sAlias)

Return
*/


Static Function FS_VALTIK(nOpc)

Local cAliasVJ1 := "LEVVJ1"
Local cQuery    := ""
Local nTik := 0

If nOpc == 1

	dDataPer := Ctod("  /  /  ")
	cFamilia := ""
	cModelo  := ""
	aData    := {}	
	aFamilia := {}	
	aModelo  := {}	

	cQuery    += "SELECT VJ1_DATPGD "
	cQuery    += "FROM "+RetSqlName("VJ1")+" VJ1 "
	cQuery    += "WHERE VJ1.VJ1_FILIAL='"+xFilial("VJ1")+"' AND "
	cQuery    += "VJ1.VJ1_TIPPED="+Str(nTipPed,2)+" AND "
	cQuery    += "VJ1.D_E_L_E_T_=' ' "
	cQuery    += "GROUP BY VJ1_DATPGD"

	cQuery := ChangeQuery( cQuery ) 
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasVJ1, .F., .T. ) 

	Do While !( cAliasVJ1 )->( Eof() ) 

		Aadd( aData, { .f., Stod( ( cAliasVJ1 )->( VJ1_DATPGD ) ) })
		
	   ( cAliasVJ1 )->( DbSkip() )

	EndDo

	( cAliasVJ1 )->( dbCloseArea() ) 

ElseIf nOpc == 2

	For nTik := 1 to Len(aData)    
		If nTik # oLbData:nAt
			aData[nTik,1]	 := .f.
		EndIf	
	Next
                                        
	aData[oLbData:nAt,1] := !aData[oLbData:nAt,1]
	cFamilia := ""
	cModelo  := ""
	aFamilia := {}	
	aModelo  := {}	

	If aData[oLbData:nAt,1]

		dDataPer := aData[oLbData:nAt,2]

		cQuery    += "SELECT VJ1_CODMAR,VJ1_MODVEI "
		cQuery    += "FROM "+RetSqlName("VJ1")+" VJ1 "
		cQuery    += "WHERE VJ1.VJ1_FILIAL='"+xFilial("VJ1")+"' AND "
		cQuery    += "VJ1.VJ1_TIPPED="+Str(nTipPed,2)+" AND "
		cQuery    += "VJ1.VJ1_DATPGD='"+Dtos(dDataPer)+"' AND "
		cQuery    += "VJ1.D_E_L_E_T_=' '"
		cQuery    += "GROUP BY VJ1_CODMAR,VJ1_MODVEI"
	
		cQuery := ChangeQuery( cQuery ) 
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasVJ1, .F., .T. ) 
	
		Do While !( cAliasVJ1 )->( Eof() ) 
	                                                             
			VV2->(DbSetOrder(1))
			VV2->(DbSeek( xFilial("VV2") + ( cAliasVJ1 )->( VJ1_CODMAR ) + ( cAliasVJ1 )->( VJ1_MODVEI ) ))
                                                                         
			If !Empty(VV2->VV2_GRUMOD)

				VVR->(DbSetOrder(2))
				If VVR->(DbSeek( xFilial("VVR") + ( cAliasVJ1 )->( VJ1_CODMAR ) + VV2->VV2_GRUMOD ))
	
					If ( Len(aFamilia) == 0 .Or. Ascan(aFamilia, { |x| x[2] == VV2->VV2_GRUMOD } ) == 0 )
						Aadd( aFamilia, { .f., VV2->VV2_GRUMOD, VVR->VVR_DESCRI })
					EndIf

				EndIf

			EndIf
			
		   ( cAliasVJ1 )->( DbSkip() )
	
		EndDo
	
		( cAliasVJ1 )->( dbCloseArea() ) 
		
		oLbFamilia:SetFocus()

	Else   

		dDataPer := Ctod("  /  /  ")

	EndIf

ElseIf nOpc == 3

	For nTik := 1 to Len(aFamilia)    
		If nTik # oLbFamilia:nAt
			aFamilia[nTik,1]	 := .f.
		EndIf	
	Next
                                        
	aFamilia[oLbFamilia:nAt,1] := !aFamilia[oLbFamilia:nAt,1]
	cModelo  := ""
	aModelo  := {}	

	If aFamilia[oLbFamilia:nAt,1]

		cFamilia := aFamilia[oLbFamilia:nAt,2]

		cQuery    += "SELECT VJ1_CODMAR,VJ1_MODVEI "
		cQuery    += "FROM "+RetSqlName("VJ1")+" VJ1 "
		cQuery    += "WHERE VJ1.VJ1_FILIAL='"+xFilial("VJ1")+"' AND "
		cQuery    += "VJ1.VJ1_TIPPED="+Str(nTipPed,2)+" AND "
		cQuery    += "VJ1.VJ1_DATPGD='"+Dtos(dDataPer)+"' AND "

		cQuery    += "VJ1.VJ1_MODVEI IN "
		cQuery    += "( SELECT VV2_MODVEI FROM "+RetSqlName("VV2")+" VV2 "
		cQuery    += "WHERE VV2.VV2_GRUMOD = '"+cFamilia+"' ) AND "

		cQuery    += "VJ1.D_E_L_E_T_=' '"
		cQuery    += "GROUP BY VJ1_CODMAR,VJ1_MODVEI"
	
		cQuery := ChangeQuery( cQuery ) 
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasVJ1, .F., .T. ) 
	
		Do While !( cAliasVJ1 )->( Eof() )
	                                                             
			VV2->(DbSetOrder(1))
			VV2->(DbSeek( xFilial("VV2") + ( cAliasVJ1 )->( VJ1_CODMAR ) + ( cAliasVJ1 )->( VJ1_MODVEI ) ))
                                                                         
			Aadd( aModelo, { .f., ( cAliasVJ1 )->( VJ1_MODVEI ), VV2->VV2_DESMOD })
			
		   ( cAliasVJ1 )->( DbSkip() )
	
		EndDo
	
		( cAliasVJ1 )->( dbCloseArea() ) 
		
		oLbModelo:SetFocus()

	Else   

		cFamilia := ""

	EndIf

ElseIf nOpc == 4

	For nTik := 1 to Len(aModelo)
		If nTik # oLbModelo:nAt
			aModelo[nTik,1]	 := .f.
		EndIf	
	Next
                                        
	aModelo[oLbModelo:nAt,1] := !aModelo[oLbModelo:nAt,1]

	If aModelo[oLbModelo:nAt,1]
		
		cModelo := aModelo[oLbModelo:nAt,2]
		
	Else	

		cModelo := ""

	EndIf

EndIf
      
If Len(aData) == 0
	Aadd( aData, { .f., Ctod("  /  /  ")})                  
EndIf
If Len(aFamilia) == 0
	Aadd( aFamilia, { .f., "", ""})
EndIf
If Len(aModelo) == 0
	Aadd( aModelo, { .f., "", ""})
EndIf
      
oLbData:SetArray(aData)
oLbData:bLine := { || { If(aData[oLbData:nAt,1],oOk,oNo) ,; 
                            Transform( aData[oLbData:nAt,2], "@D" ) }}
oLbData:Refresh()

oLbFamilia:SetArray(aFamilia)
oLbFamilia:bLine := { || { If(aFamilia[oLbFamilia:nAt,1],oOk,oNo) ,; 
                            aFamilia[oLbFamilia:nAt,2] ,;
                            aFamilia[oLbFamilia:nAt,3] }}
oLbFamilia:Refresh()
           
oLbModelo:SetArray(aModelo)
oLbModelo:bLine := { || { If(aModelo[oLbModelo:nAt,1],oOk,oNo) ,; 
                             Substr(aModelo[oLbModelo:nAt,2],1,15) ,;
                             aModelo[oLbModelo:nAt,3] }}
oLbModelo:Refresh()

Return(.T.)