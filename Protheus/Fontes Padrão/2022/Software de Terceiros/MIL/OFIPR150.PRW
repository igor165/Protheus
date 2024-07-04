#Include "PROTHEUS.Ch"
#Include "OFIPR150.Ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIPR150 ³ Autor ³ Andre Luis Almeida    ³ Data ³ 25/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relacao dos Titulos Periodicos                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function OFIPR150()

Private cTipTit := Left(Alltrim(GetNewPar("MV_TIPPER","TP"))+space(3),Len(SE1->E1_TIPO)) // Tipo de Titulo Provisorio
Private cDesc1 := STR0001
Private cDesc2 := ""
Private cDesc3 := ""
Private tamanho:= "P"
Private limite := 80 
Private cString:= "SE1"
Private titulo := STR0002
Private cabec1 := STR0005
Private cabec2 := ""
Private cNomeArq
Private aReturn := { STR0003, 1,STR0004, 1, 2, 1, "",1 }  
Private nomeprog:= "OFIPR150"
Private aLinha  := { },nLastKey := 0
Private cPerg   := "OFP150"
///// PERGUNTE - OFP150 /////
//  01 Data Inicial  D  8  //
//  02 Data Final    D  8  //
/////////////////////////////
nomeprog := SetPrint(cString,nomeprog,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,,tamanho)
If nLastKey == 27
	Return
EndIf     
Pergunte(cPerg,.f.)
SetDefault(aReturn,cString)
RptStatus( { |lEnd| FS_OFIPR150(@lEnd,nomeprog,cString) } , Titulo )
If aReturn[5] == 1
   OurSpool( nomeprog )
EndIf
MS_Flush()
Return

Static Function FS_OFIPR150()
Local nTotQtd := nTotVal := 0
nLin  := 0
m_pag := 1       
Set Printer to &nomeprog
Set Printer On
Set Device  to Printer
nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
DbSelectArea("SE1")
DbSetOrder(6)
DbSeek(xFilial("SE1")+Dtos(mv_par01),.T.)
SetRegua( RecCount() )       
While !Eof() .and. xFilial("SE1") == SE1->E1_FILIAL .and. ( SE1->E1_EMISSAO <= mv_par02 )
	IncRegua()
	If ( ( ( SE1->E1_FATPREF == "PER" ) .and. ( Alltrim(SE1->E1_TIPO) $ "CD/DP" ) ) .or. ( SE1->E1_TIPO == cTipTit ) )
	  If nLin >= 60
  	     nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
     EndIf
     DbSelectArea("SA1")
  	  DbSetOrder(1)
     DbSeek(xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA )
     nTotQtd++ 
     nTotVal += SE1->E1_VALOR
     @nLin++, 00 PSAY Transform(SE1->E1_EMISSAO,"@D")+" "+SE1->E1_PREFORI+" "+SE1->E1_PREFIXO+" "+SE1->E1_NUM+"-"+SE1->E1_PARCELA+" "+left(SA1->A1_NOME,23)+;
		                 Transform(SE1->E1_VALOR,"@E 99999,999.99")+" "+Transform(SE1->E1_VENCTO,"@D")+" "+SE1->E1_TIPO
	EndIf
	DbSelectArea("SE1") 
	DbSkip()
EndDo
nLin += 2
@nLin++, 08 PSAY STR0006+"  ( "+Transform(nTotQtd,"@E 99,999,999")+STR0007+" )  "+Transform(nTotVal,"@E 99999,999,999.99")
Set Printer to
Set Device  to Screen
Return